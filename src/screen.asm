INCLUDE "hardware.inc"
INCLUDE "gfx.inc"

;;==============================================================================
;; screen.asm: everything that touches the LCD, VRAM and OAM.
;;
;;   Rule of thumb: VRAM and OAM can only be written while the LCD is off or
;;   during VBLANK (lines 144-153). Outside that, the writes are lost.
;;==============================================================================

SECTION "Screen", ROM0

;;------------------------------------------------------------------------------
;; screen_init: load the tiles into VRAM and set the palettes.
;;   MODIFIES: AF, BC, DE, HL
;;------------------------------------------------------------------------------
screen_init::
   call screen_off                 ;; \ VRAM is only safe to write with the LCD off
   ld hl, gfx_tiles                ;; |
   ld de, _VRAM8000                ;; | copy all tiles to the start of VRAM
   ld bc, GFX_TILES_SIZE           ;; |
   call screen_copy                ;; /

   ld a, %11100100                 ;; \ shade 0 = lightest ... shade 3 = darkest
   ldh [rBGP], a                   ;; | one palette for the background
   ldh [rOBP0], a                  ;; / and one for the sprites
   ret

;;------------------------------------------------------------------------------
;; screen_wait_vblank: wait until the beginning of the next VBLANK.
;;   Calling it once per frame makes the game run at 60 FPS.
;;   MODIFIES: AF
;;------------------------------------------------------------------------------
screen_wait_vblank::
.leave:                            ;; If we are already in VBLANK, wait until it ends
   ldh a, [rLY]                    ;; (otherwise the game would run twice in the same VBLANK)
   cp 144
   jr nc, .leave
.enter:                            ;; Now wait for line 144: the VBLANK begins
   ldh a, [rLY]
   cp 144
   jr c, .enter
   ret

;;------------------------------------------------------------------------------
;; screen_off / screen_on: switch the LCD off (only in VBLANK) and on.
;;   MODIFIES: AF
;;------------------------------------------------------------------------------
screen_off::
   ldh a, [rLCDC]                  ;; \ LY does not advance with the LCD off:
   bit 7, a                        ;; | waiting for VBLANK would never end
   ret z                           ;; / (already off: nothing to do)

   call screen_wait_vblank
   xor a
   ldh [rLCDC], a
   ret

screen_on::
   ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_BLK01
   ldh [rLCDC], a
   ret

;;------------------------------------------------------------------------------
;; screen_copy: copy BC bytes from HL to DE.
;;   MODIFIES: AF, BC, DE, HL
;;------------------------------------------------------------------------------
screen_copy::
   ld a, [hli]
   ld [de], a
   inc de
   dec bc
   ld a, b
   or c
   jr nz, screen_copy
   ret

;;------------------------------------------------------------------------------
;; screen_fill: write A in BC bytes starting at HL.
;;   MODIFIES: AF, BC, D, HL
;;------------------------------------------------------------------------------
screen_fill::
   ld d, a
.loop:
   ld a, d
   ld [hli], a
   dec bc
   ld a, b
   or c
   jr nz, .loop
   ret

;;------------------------------------------------------------------------------
;; screen_clear: empty the background map and hide all sprites. LCD must be off.
;;   MODIFIES: AF, BC, D, HL
;;------------------------------------------------------------------------------
screen_clear::
   ld hl, _SCRN0                   ;; \ the 32x32 background map
   ld bc, 32 * 32                  ;; | filled with the blank tile
   ld a, TILE_BLANK                ;; |
   call screen_fill                ;; /

   ld hl, _OAMRAM                  ;; \ the 40 sprites (4 bytes each)
   ld bc, 40 * 4                   ;; | filled with 0: Y = 0 puts a sprite
   xor a                           ;; | outside of the screen
   call screen_fill                ;; /
   ret

;;------------------------------------------------------------------------------
;; screen_draw_frame: draw a wall around the 20x18 visible tiles. LCD must be off.
;;   MODIFIES: AF, BC, DE, HL
;;------------------------------------------------------------------------------
screen_draw_frame::
   ld hl, _SCRN0                   ;; \ top row
   ld bc, 20                       ;; |
   ld a, TILE_WALL                 ;; |
   call screen_fill                ;; /

   ld hl, _SCRN0 + 17 * 32         ;; \ bottom row
   ld bc, 20                       ;; |
   ld a, TILE_WALL                 ;; |
   call screen_fill                ;; /

   ld hl, _SCRN0 + 1 * 32          ;; \ left and right columns of rows 1 to 16
   ld b, 16                        ;; | B = rows left
.side_rows:                        ;; |
   ld [hl], TILE_WALL              ;; | wall in column 0
   ld de, 19                       ;; |
   add hl, de                      ;; | move to column 19
   ld [hl], TILE_WALL              ;; | wall in column 19
   ld de, 32 - 19                  ;; |
   add hl, de                      ;; | move to column 0 of the next row
   dec b                           ;; |
   jr nz, .side_rows               ;; /
   ret

;;------------------------------------------------------------------------------
;; screen_print: write a text (ended with TEXT_END) in the background map.
;;   IN:  HL = map address where it starts, DE = address of the text
;;   LCD must be off.
;;   MODIFIES: AF, DE, HL
;;------------------------------------------------------------------------------
screen_print::
   ld a, [de]
   cp TEXT_END
   ret z
   ld [hli], a
   inc de
   jr screen_print

;;------------------------------------------------------------------------------
;; screen_set_sprite: set sprite 0. Call it right after screen_wait_vblank.
;;   IN:  B = Y, C = X (in sprite coordinates), A = tile
;;   MODIFIES: HL
;;   Sprite coordinates start at (8, 16): that puts the sprite at (0, 0) of the
;;   screen. That is why the hardware hides sprites with Y = 0.
;;------------------------------------------------------------------------------
screen_set_sprite::
   ld hl, _OAMRAM
   ld [hl], b                      ;; Y
   inc hl
   ld [hl], c                      ;; X
   inc hl
   ld [hli], a                     ;; tile
   ld [hl], 0                      ;; attributes: none
   ret
