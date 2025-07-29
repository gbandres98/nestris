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

.include "zeropage.s"

.segment "CHARS"
.incbin "nestris_spr.chr"
.incbin "nestris_bg.chr"

.segment "CODE"

.include "reset.s"
.include "main.s"
.include "nmi.s"
.include "movement.s"
.include "pieces.s"
.include "score.s"

.segment "RODATA"

Palettes:
.incbin "nestris_palettes.dat"

BG:
.incbin "nestris_nt.nam"
