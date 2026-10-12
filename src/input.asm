INCLUDE "hardware.inc"

;;==============================================================================
;; input.asm: read the joypad once per frame.
;;
;;   Other files only READ input_held and input_pressed. Each bit is one
;;   button; use the PADF_* masks (hardware.inc) to test them:
;;     input_held    = buttons down right now
;;     input_pressed = buttons that went down in this very frame
;;==============================================================================

SECTION "Input data", WRAM0

input_held::    ds 1
input_pressed:: ds 1

SECTION "Input", ROM0

;;------------------------------------------------------------------------------
;; input_init: no buttons down.
;;   MODIFIES: AF
;;------------------------------------------------------------------------------
input_init::
   xor a
   ld [input_held], a
   ld [input_pressed], a
   ret

;;------------------------------------------------------------------------------
;; input_update: read the joypad. Call it once per frame.
;;   MODIFIES: AF, BC
;;------------------------------------------------------------------------------
input_update::
   ld a, [input_held]
   ld c, a                         ;; C = buttons down in the previous frame

   ld a, P1F_GET_DPAD              ;; \ select the D-pad (a 0 means "pressed")
   ldh [rP1], a                    ;; | the lines need some time to settle,
   ldh a, [rP1]                    ;; | so we read several times
   ldh a, [rP1]                    ;; |
   ldh a, [rP1]                    ;; |
   cpl                             ;; | now 1 means "pressed"
   and $0F                         ;; | keep the 4 direction bits
   swap a                          ;; | and move them to the high nibble
   ld b, a                         ;; /

   ld a, P1F_GET_BTN               ;; \ select the buttons (A, B, Select, Start)
   ldh [rP1], a                    ;; |
   ldh a, [rP1]                    ;; |
   ldh a, [rP1]                    ;; |
   ldh a, [rP1]                    ;; |
   ldh a, [rP1]                    ;; |
   cpl                             ;; |
   and $0F                         ;; |
   or b                            ;; | join them with the D-pad bits
   ld b, a                         ;; /

   ld a, P1F_GET_NONE              ;; Deselect everything
   ldh [rP1], a

   ld a, b                         ;; \ held = what is down now
   ld [input_held], a              ;; /

   ld a, c                         ;; \ pressed = down now AND NOT down before
   cpl                             ;; |
   and b                           ;; |
   ld [input_pressed], a           ;; /
   ret
