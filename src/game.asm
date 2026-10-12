INCLUDE "hardware.inc"
INCLUDE "gfx.inc"

;;==============================================================================
;; game.asm: the game itself, as a tiny state machine with 3 states.
;;
;;   MENU --START--> PLAY --A--> BOOM --(1 second)--> MENU
;;
;;   MENU: title and "PRESS START".
;;   PLAY: move the ship with the D-pad, always inside the walls.
;;   BOOM: the ship turns into an explosion for a moment.
;;==============================================================================

DEF STATE_MENU EQU 0
DEF STATE_PLAY EQU 1
DEF STATE_BOOM EQU 2

DEF BOOM_FRAMES EQU 60        ;; How long the explosion lasts (60 frames = 1 second)
DEF SHIP_SPEED  EQU 2         ;; Pixels per frame

;; Where the ship can be, in sprite coordinates (the screen starts at 8, 16).
;; The walls take the first and last 8 pixels of the screen, so the 8x8 ship fits
;; between X = 16 and X = 152, and between Y = 24 and Y = 144.
DEF SHIP_X_MIN EQU 8 + 8
DEF SHIP_X_MAX EQU 8 + 160 - 8 - 8
DEF SHIP_Y_MIN EQU 16 + 8
DEF SHIP_Y_MAX EQU 16 + 144 - 8 - 8

SECTION "Game data", WRAM0

game_state: ds 1              ;; STATE_MENU, STATE_PLAY or STATE_BOOM
game_timer: ds 1              ;; Frames left of the explosion
ship_x:     ds 1
ship_y:     ds 1

SECTION "Game", ROM0

;;------------------------------------------------------------------------------
;; game_init: start in the menu.
;;   MODIFIES: AF, BC, DE, HL
;;------------------------------------------------------------------------------
game_init::
   jp game_enter_menu              ;; (it will return to our caller)

;;------------------------------------------------------------------------------
;; game_update: run one frame of the game. Call it once per frame, in VBLANK.
;;   MODIFIES: AF, BC, DE, HL
;;------------------------------------------------------------------------------
game_update::
   ld a, [game_state]
   cp STATE_MENU
   jr z, game_update_menu
   cp STATE_PLAY
   jr z, game_update_play
   jp game_update_boom             ;; Any other value: STATE_BOOM

;;------------------------------------------------------------------------------
;; MENU
;;------------------------------------------------------------------------------
game_enter_menu:
   call screen_off                 ;; \ Draw a new screen with the LCD off
   call screen_clear               ;; |
   ld hl, _SCRN0 + 4 * 32 + 3      ;; | title, at row 4, column 3
   ld de, text_title               ;; |
   call screen_print               ;; |
   ld hl, _SCRN0 + 9 * 32 + 4      ;; | "PRESS START", at row 9, column 4
   ld de, text_press_start         ;; |
   call screen_print               ;; |
   call screen_on                  ;; /

   ld a, STATE_MENU
   ld [game_state], a
   ret

game_update_menu:
   ld a, [input_pressed]           ;; \ Start pressed in this frame?
   and PADF_START                  ;; |
   ret z                           ;; /
   jr game_enter_play

;;------------------------------------------------------------------------------
;; PLAY
;;------------------------------------------------------------------------------
game_enter_play:
   call screen_off                 ;; \ Draw a new screen with the LCD off
   call screen_clear               ;; |
   call screen_draw_frame          ;; |
   call screen_on                  ;; /

   ld a, (SHIP_X_MIN + SHIP_X_MAX) / 2   ;; \ The ship starts in the middle
   ld [ship_x], a                        ;; |
   ld a, (SHIP_Y_MIN + SHIP_Y_MAX) / 2   ;; |
   ld [ship_y], a                        ;; /

   ld a, STATE_PLAY
   ld [game_state], a
   ret

game_update_play:
   ld a, [input_pressed]           ;; \ A pressed in this frame? Then, boom!
   and PADF_A                      ;; |
   jr nz, game_enter_boom          ;; /

   call game_move_ship
   ld a, TILE_SHIP
   jr game_draw_ship

;; Move the ship according to the D-pad, never beyond the limits.
;; Each direction: move; if we went too far, put the ship back at the limit.
game_move_ship:
   ld a, [input_held]
   ld b, a                         ;; B = buttons down (kept for the 4 checks)

   bit PADB_LEFT, b                ;; \ Left: X = max(X - speed, X_MIN)
   jr z, .not_left                 ;; |
   ld a, [ship_x]                  ;; |
   sub SHIP_SPEED                  ;; |
   cp SHIP_X_MIN                   ;; | (we never go below X_MIN, so X - speed
   jr nc, .store_x_left            ;; |  cannot wrap around)
   ld a, SHIP_X_MIN                ;; |
.store_x_left:                     ;; |
   ld [ship_x], a                  ;; /
.not_left:

   bit PADB_RIGHT, b               ;; \ Right: X = min(X + speed, X_MAX)
   jr z, .not_right                ;; |
   ld a, [ship_x]                  ;; |
   add SHIP_SPEED                  ;; |
   cp SHIP_X_MAX + 1               ;; |
   jr c, .store_x_right            ;; |
   ld a, SHIP_X_MAX                ;; |
.store_x_right:                    ;; |
   ld [ship_x], a                  ;; /
.not_right:

   bit PADB_UP, b                  ;; \ Up: Y = max(Y - speed, Y_MIN)
   jr z, .not_up                   ;; |
   ld a, [ship_y]                  ;; |
   sub SHIP_SPEED                  ;; |
   cp SHIP_Y_MIN                   ;; |
   jr nc, .store_y_up              ;; |
   ld a, SHIP_Y_MIN                ;; |
.store_y_up:                       ;; |
   ld [ship_y], a                  ;; /
.not_up:

   bit PADB_DOWN, b                ;; \ Down: Y = min(Y + speed, Y_MAX)
   jr z, .not_down                 ;; |
   ld a, [ship_y]                  ;; |
   add SHIP_SPEED                  ;; |
   cp SHIP_Y_MAX + 1               ;; |
   jr c, .store_y_down             ;; |
   ld a, SHIP_Y_MAX                ;; |
.store_y_down:                     ;; |
   ld [ship_y], a                  ;; /
.not_down:
   ret

;;------------------------------------------------------------------------------
;; BOOM
;;------------------------------------------------------------------------------
game_enter_boom:
   ld a, STATE_BOOM
   ld [game_state], a
   ld a, BOOM_FRAMES
   ld [game_timer], a
   ret

game_update_boom:
   ld a, TILE_BOOM                 ;; The sprite stays where the ship was
   call game_draw_ship

   ld hl, game_timer               ;; \ One frame less. When the time is over,
   dec [hl]                        ;; | go back to the menu.
   ret nz                          ;; |
   jp game_enter_menu              ;; / (jp reaches farther than jr)

;;------------------------------------------------------------------------------
;; game_draw_ship: show the ship sprite with the given tile at the ship position.
;;   IN:  A = tile
;;   MODIFIES: BC, HL
;;------------------------------------------------------------------------------
game_draw_ship:
   ld hl, ship_y
   ld b, [hl]                      ;; B = Y
   ld hl, ship_x
   ld c, [hl]                      ;; C = X
   jp screen_set_sprite            ;; (it will return to our caller)
