.segment "CODE"

RESET:
    SEI             ; disable IRQs
    CLD             ; disable decimal mode
    LDX #$40
    STX $4017       ; disable APU frame counter interrupt
    LDX #$ff
    TXS             ; setup stack starting at FF as it decrements instead if increments
    LDA #$00
    STA $2000       ; disable NMI - PPUCTRL reg
    STA $2001       ; disable rendering - PPUMASK reg
    STA $4010       ; disable DMC IRQs

vblankwait1:        ; wait for vblank to make sure PPU is ready
    BIT $2002       ; returns bit 7 of ppustatus reg, which holds the vblank status with 0 being no vblank, 1 being vblank
    BPL vblankwait1

clearmem:
    LDA #$00
    STA $0000, x
    STA $0100, x
    STA $0200, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    INX 
    BNE clearmem

vblankwait2:        ; PPU is ready after this
    BIT $2002
    BPL vblankwait2

    LDA $2002 ; PPUSTATUS Read to reset latch
    LDA #$3F
    STA $2006 ; PPUADDR
    LDA #$00
    STA $2006

    LDA #$C4
    STA seed

    JSR GameInit

    LDA #%10010000 ; Enable NMI
    STA $2000 ; PPUCTRL
    STA ppuctrl

    LDA #%00011000
    STA $2001       ; PPUMASK

    JMP Main

.proc GameInit

;;;;;;;;;; Clear sprites

    LDX #$FF
    LDA #0
:
    STA centerText, x
    DEX
    CPX #$FF
    BNE :-

;;;;;;;;; Clear piece map

    LDA #>pieceMap
    CLC
    ADC #$04
    STA tempPtr+1
    LDA #<pieceMap
    STA tempPtr
    LDY #0
:
    LDA #0
    STA (tempPtr), y
    CMP tempPtr
    BNE :+
    DEC tempPtr+1
:
    DEC tempPtr
    LDA #2
    CMP tempPtr+1
    BEQ :+
    JMP :--
:

;;;;;;; Palettes

    LDX #$00
:
    LDA Palettes, x
    STA $2007
    INX
    CPX #$20
    BNE :-

;;;;;;;; Load Background

    LDA $2002
    LDA #$20
    STA nametableHi
    STA $2006
    LDA #$00
    STA $2006

    LDA #<BG
    STA tempPtr
    lda #>BG
    STA tempPtr+1

    LDX #4
    LDY #0
:
    LDA (tempPtr), y
    STA $2007
    INY
    BNE :-

    DEX
    BEQ :+
    INC tempPtr+1
    JMP :-
:

;;;;;;;; Load Background in second nametable

    LDA $2002
    LDA #$28
    STA hiddenNametableHi
    STA $2006
    LDA #$00
    STA $2006

    LDA #<BG
    STA tempPtr
    lda #>BG
    STA tempPtr+1

    LDX #4
    LDY #0
:
    LDA (tempPtr), y
    STA $2007
    INY
    BNE :-

    DEX
    BEQ :+
    INC tempPtr+1
    JMP :-
:

;;;;;;;;;;; Press Start message

    LDX #$2B
:
    LDA pressStart, x
    STA centerText, x
    DEX
    BPL :-

;;;;;;;;;;; Init variables
    LDA FallSpeedPerLevel
    STA fallSpeed
    STA fallTimer

    LDA #0
    STA level
    STA moveTimer 
    STA pieceIndex
    STA nextPieceIndex

    RTS

.endproc

.segment "RODATA"

pressStart:
    .byte $2F,$2F,$01,$70
    .byte $2F,$31,$01,$78
    .byte $2F,$24,$01,$80
    .byte $2F,$32,$01,$88
    .byte $2F,$32,$01,$90
    .byte $3F,$32,$01,$70
    .byte $3F,$33,$01,$78
    .byte $3F,$20,$01,$80
    .byte $3F,$31,$01,$88
    .byte $3F,$33,$01,$90
    .byte $3F,$3A,$01,$98