.segment "CODE"

SpriteToBG:
    LDA #%00001000
    ORA ppuctrl
    STA tempPtr
    TYA
    CLC
    ADC #$01
    AND #%11111000
    ASL
    ROL tempPtr
    ASL
    ROL tempPtr

    STA tempPtr+1
    TXA
    LSR
    LSR
    LSR
    ORA tempPtr+1
    STA tempPtr+1

    RTS

;;;;;;;; Sprite to Piece Map 000000YY YYYXXXXX
SpriteToPieceMap:
    LDA #%00000000
    STA tempPtr+1
    TYA
    CLC
    ADC #$01
    AND #%11111000
    ASL
    ROL tempPtr+1
    ASL
    ROL tempPtr+1

    STA tempPtr
    TXA
    LSR
    LSR
    LSR
    ORA tempPtr
    STA tempPtr

    LDA #<pieceMap
    CLC
    ADC tempPtr
    STA tempPtr

    LDA #>pieceMap
    ADC tempPtr+1
    STA tempPtr+1

    LDY #0
    LDA (tempPtr), y

    RTS

;;;;;;;;;; Collision check
.proc CollisionCheck
    LDA #$00
    STA tempIndex
Loop:
    LDY tempIndex
    LDX collisionCheck1, y
    LDA collisionCheck1+1, y
    TAY
    LDA #$01
    CPX #$A9
    BCC :+
    RTS
:
    CPX #$60
    BCS :+
    RTS
:
    CPY #$B8
    BCC :+
    RTS
:
    JSR SpriteToPieceMap
    BEQ :+
    RTS
:
    LDY tempIndex
    INY
    INY
    CPY #$08
    BEQ :+
    STY tempIndex
    JMP Loop
:
    JSR ApplyMovement
    LDA #$00
    RTS
.endproc

;;;;;;;;;;;; ApplyMovement
ApplyMovement:
    LDA collisionCheck1
    STA currentPiece1+3
    LDA collisionCheck1+1
    STA currentPiece1
    LDA collisionCheck2
    STA currentPiece2+3
    LDA collisionCheck2+1
    STA currentPiece2
    LDA collisionCheck3
    STA currentPiece3+3
    LDA collisionCheck3+1
    STA currentPiece3
    LDA collisionCheck4
    STA currentPiece4+3
    LDA collisionCheck4+1
    STA currentPiece4
    RTS

RotateRight:
    LDA rotationIndex
    CMP #32
    BNE :+
    LDA #0
    STA rotationIndex
:
    LDA pieceIndex
    ASL
    ASL
    ASL
    ASL
    ASL
    ORA rotationIndex
    TAX

    LDA currentPiece1+3
    CLC
    ADC TurnTable, x
    STA collisionCheck1
    INX

    LDA currentPiece1
    CLC
    ADC TurnTable, x
    STA collisionCheck1+1
    INX

    LDA currentPiece2+3
    CLC
    ADC TurnTable, x
    STA collisionCheck2
    INX

    LDA currentPiece2
    CLC
    ADC TurnTable, x
    STA collisionCheck2+1
    INX
    
    LDA currentPiece3+3
    CLC
    ADC TurnTable, x
    STA collisionCheck3
    INX

    LDA currentPiece3
    CLC
    ADC TurnTable, x
    STA collisionCheck3+1
    INX

    LDA currentPiece4+3
    CLC
    ADC TurnTable, x
    STA collisionCheck4
    INX

    LDA currentPiece4
    CLC
    ADC TurnTable, x
    STA collisionCheck4+1
    INX

    JSR CollisionCheck
    BNE :+
    LDA rotationIndex
    CLC
    ADC #8
    STA rotationIndex
:
    RTS

RotateLeft:
    LDA rotationIndex
    CMP #0
    BNE :+
    LDA #32
    STA rotationIndex
:
    LDA rotationIndex
    SEC
    SBC #1
    STA tempIndex
    LDA pieceIndex
    ASL
    ASL
    ASL
    ASL
    ASL
    ORA tempIndex
    TAX

    LDA currentPiece4
    SEC
    SBC TurnTable, x
    STA collisionCheck4+1
    DEX

    LDA currentPiece4+3
    SEC
    SBC TurnTable, x
    STA collisionCheck4
    DEX

    LDA currentPiece3
    SEC
    SBC TurnTable, x
    STA collisionCheck3+1
    DEX

    LDA currentPiece3+3
    SEC
    SBC TurnTable, x
    STA collisionCheck3
    DEX
    
    LDA currentPiece2
    SEC
    SBC TurnTable, x
    STA collisionCheck2+1
    DEX

    LDA currentPiece2+3
    SEC
    SBC TurnTable, x
    STA collisionCheck2
    DEX

    LDA currentPiece1
    SEC
    SBC TurnTable, x
    STA collisionCheck1+1
    DEX

    LDA currentPiece1+3
    SEC
    SBC TurnTable, x
    STA collisionCheck1
    DEX

    JSR CollisionCheck
    BNE :+
    LDA rotationIndex
    SEC
    SBC #8

    STA rotationIndex
:
    RTS

.segment "RODATA"

TurnTable: ; 3 bit piece index, 4 bit turn index PPPT TTTT
.feature force_range
    ; L
    .byte 8,8,      0,0,    -8,-8,  -16,0
    .byte -8,8,     0,0,    8,-8,   0,-16
    .byte -8,-8,    0,0,    8,8,    16,0
    .byte 8,-8,     0,0,    -8,8,   0,16
    ; J
    .byte 8,8,      0,0,    -8,-8,  0,-16
    .byte -8,8,     0,0,    8,-8,   16,0
    .byte -8,-8,    0,0,    8,8,    0,16
    .byte 8,-8,     0,0,    -8,8,   -16,0
    ; Z
    .byte 16,-8,    0,0,    0,0,    0,-8
    .byte -16,8,    0,0,    0,0,    0,8
    .byte 16,-8,    0,0,    0,0,    0,-8
    .byte -16,8,    0,0,    0,0,    0,8
    ; S
    .byte 0,0,      0,0,    8,0,    8,-16
    .byte 0,0,      0,0,    -8,0,   -8,16
    .byte 0,0,      0,0,    8,0,    8,-16
    .byte 0,0,      0,0,    -8,0,   -8,16
    ; T
    .byte 8,-8,     0,0,    -8,8,   -8,-8
    .byte 8,8,      0,0,    -8,-8,  8,-8
    .byte -8,8,     0,0,    8,-8,   8,8
    .byte -8,-8,    0,0,    8,8,   -8,8
    ; O
    .byte 0,0,      0,0,    0,0,    0,0
    .byte 0,0,      0,0,    0,0,    0,0
    .byte 0,0,      0,0,    0,0,    0,0
    .byte 0,0,      0,0,    0,0,    0,0
    ; I
    .byte 16,-16,   8,-8,   0,0,    -8,8
    .byte -16,16,   -8,8,   0,0,    8,-8
    .byte 16,-16,   8,-8,   0,0,    -8,8
    .byte -16,16,   -8,8,   0,0,    8,-8