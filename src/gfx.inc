;;==============================================================================
;; gfx.inc: tile numbers and text constants shared by all files.
;;   The tile numbers are the position of each tile inside `gfx_tiles` (gfx.asm).
;;==============================================================================

DEF TILE_BLANK EQU 0   ;; Empty background tile
DEF TILE_WALL  EQU 1   ;; Border of the playfield
DEF TILE_SHIP  EQU 2   ;; Sprite you move around
DEF TILE_BOOM  EQU 3   ;; Sprite that replaces the ship when you press A
DEF TILE_FONT  EQU 4   ;; First letter of the font (see the charmap in gfx.asm)

DEF TEXT_END   EQU $FF ;; Marks the end of a text (tile 0 is a space, so 0 cannot be used)
