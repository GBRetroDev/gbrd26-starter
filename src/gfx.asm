INCLUDE "gfx.inc"

;;==============================================================================
;; gfx.asm: every piece of art and text of the game.
;;
;;   Each tile is 8x8 pixels, 2 bits per pixel, written as 8 rows.
;;   `01230123 is an RGBDS graphics constant: one digit per pixel (0 = lightest
;;   shade, 3 = darkest). `dw` turns each row into the 2 bytes the Game Boy needs.
;;   For sprites, shade 0 is transparent.
;;==============================================================================

SECTION "Graphics", ROM0

gfx_tiles::
   ;; TILE_BLANK
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000

   ;; TILE_WALL
   dw `33333333
   dw `32222223
   dw `32333323
   dw `32322323
   dw `32322323
   dw `32333323
   dw `32222223
   dw `33333333

   ;; TILE_SHIP
   dw `00033000
   dw `00333300
   dw `00322300
   dw `03322330
   dw `33322333
   dw `32322323
   dw `33300333
   dw `30000003

   ;; TILE_BOOM
   dw `30003003
   dw `03032030
   dw `00333300
   dw `23333332
   dw `03333330
   dw `00333300
   dw `03032030
   dw `30003003

   ;; Font: only the letters the game needs (see the charmap below)
   ;; "A"
   dw `00333000
   dw `03000300
   dw `03000300
   dw `03333300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `00000000

   ;; "B"
   dw `03333000
   dw `03000300
   dw `03000300
   dw `03333000
   dw `03000300
   dw `03000300
   dw `03333000
   dw `00000000

   ;; "D"
   dw `03333000
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03333000
   dw `00000000

   ;; "E"
   dw `03333300
   dw `03000000
   dw `03000000
   dw `03333000
   dw `03000000
   dw `03000000
   dw `03333300
   dw `00000000

   ;; "G"
   dw `00333000
   dw `03000300
   dw `03000000
   dw `03033300
   dw `03000300
   dw `03000300
   dw `00333300
   dw `00000000

   ;; "O"
   dw `00333000
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `00333000
   dw `00000000

   ;; "P"
   dw `03333000
   dw `03000300
   dw `03000300
   dw `03333000
   dw `03000000
   dw `03000000
   dw `03000000
   dw `00000000

   ;; "R"
   dw `03333000
   dw `03000300
   dw `03000300
   dw `03333000
   dw `03030000
   dw `03003000
   dw `03000300
   dw `00000000

   ;; "S"
   dw `00333300
   dw `03000000
   dw `03000000
   dw `00333000
   dw `00000300
   dw `00000300
   dw `03333000
   dw `00000000

   ;; "T"
   dw `03333300
   dw `00030000
   dw `00030000
   dw `00030000
   dw `00030000
   dw `00030000
   dw `00030000
   dw `00000000

   ;; "V"
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `03000300
   dw `00303000
   dw `00030000
   dw `00000000

   ;; "2"
   dw `00333000
   dw `03000300
   dw `00000300
   dw `00033000
   dw `00300000
   dw `03000000
   dw `03333300
   dw `00000000

   ;; "6"
   dw `00033000
   dw `00300000
   dw `03000000
   dw `03333000
   dw `03000300
   dw `03000300
   dw `00333000
   dw `00000000

   ;; "'"
   dw `00030000
   dw `00030000
   dw `00300000
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000
   dw `00000000
gfx_tiles_end:

;; Size in bytes of all the tiles; the linker makes it available to other files
DEF GFX_TILES_SIZE EQU gfx_tiles_end - gfx_tiles
EXPORT GFX_TILES_SIZE

;;------------------------------------------------------------------------------
;; Texts. A charmap tells the assembler which tile number each character has,
;; so db "PRESS START" writes tile numbers instead of ASCII codes.
;; (A charmap only affects this file; the cartridge header keeps plain ASCII.)
;;------------------------------------------------------------------------------
NEWCHARMAP gbfont
   CHARMAP " ", TILE_BLANK
   CHARMAP "A", TILE_FONT + 0
   CHARMAP "B", TILE_FONT + 1
   CHARMAP "D", TILE_FONT + 2
   CHARMAP "E", TILE_FONT + 3
   CHARMAP "G", TILE_FONT + 4
   CHARMAP "O", TILE_FONT + 5
   CHARMAP "P", TILE_FONT + 6
   CHARMAP "R", TILE_FONT + 7
   CHARMAP "S", TILE_FONT + 8
   CHARMAP "T", TILE_FONT + 9
   CHARMAP "V", TILE_FONT + 10
   CHARMAP "2", TILE_FONT + 11
   CHARMAP "6", TILE_FONT + 12
   CHARMAP "'", TILE_FONT + 13

text_title::       db "GBRETRODEV'26", TEXT_END
text_press_start:: db "PRESS START", TEXT_END

SETCHARMAP main
