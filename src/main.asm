INCLUDE "hardware.inc"

;;==============================================================================
;; main.asm: entry point. Initialize everything, then loop forever.
;;==============================================================================

SECTION "Entry point", ROM0[$150]

main::
   ld sp, $FFFE                    ;; Stack at the end of the internal RAM

   call screen_init
   call input_init
   call game_init

.frame:                            ;; Main loop: one iteration = one frame (60 per second)
   call screen_wait_vblank         ;; \ Everything that touches the screen
   call input_update               ;; | must happen right after the VBLANK begins
   call game_update                ;; /
   jr .frame
