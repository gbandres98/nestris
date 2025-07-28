;; 8bitworkshop directives:
;#resource "nes.cfg"
;#define CFGFILE nes.cfg
;#define LIBARGS
;; End of directives

.segment "HEADER"

    .byte 'N', 'E', 'S', $1A ; Signature
    .byte $02       ; 2 * 16KB PRG ROM
    .byte $01       ; 1 * 8KB CHR ROM
    .byte %00000000 ; Mapper 0 Mirror 0
    .byte $0, $0, $0, $0, $0, $0, $0, $0, $0 ; Padding

.segment "VECTORS"
    .word NMI
    .word RESET
    .word 0

.segment "BSS"
pieceMap: .res 1024

.include "src/zeropage.s"

.segment "CHARS"
.incbin "assets/nestris_spr.chr"
.incbin "assets/nestris_bg.chr"

.segment "CODE"

.include "src/reset.s"
.include "src/main.s"
.include "src/nmi.s"
.include "src/movement.s"
.include "src/pieces.s"
.include "src/score.s"

.segment "RODATA"

Palettes:
.incbin "assets/nestris_palettes.dat"

BG:
.incbin "assets/nestris_nt.nam"
