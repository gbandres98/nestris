spawnX = $80
spawnY = $1f
nextX = $c8
nextY = $3f
savedX = $c8
savedY = $a8

.segment "CODE"

.proc LoadNextPiece
:  
    JSR RollSeed
    LDA seed
    AND #%00000111
    CMP #$07
    BEQ :-
    STA nextPieceIndex
    ASL
    ASL
    ASL
    ASL
    TAX
    LDY #0
:
    LDA Sprites, x
    CLC
    ADC #nextY
    STA nextPiece1, y
    LDA Sprites+1, x
    STA nextPiece1+1, y
    LDA Sprites+2, x
    STA nextPiece1+2, y
    LDA Sprites+3, x
    CLC
    ADC #nextX
    STA nextPiece1+3, y
    INX
    INX
    INX
    INX
    INY
    INY
    INY
    INY
    CPY #(4*4)
    BNE :-
    RTS
.endproc

.proc SpawnNextPiece
    LDA nextPieceIndex
    STA pieceIndex
    ASL
    ASL
    ASL
    ASL
    TAX
    LDY #0
:
    LDA Sprites, x
    CLC
    ADC #spawnY
    STA currentPiece1, y
    LDA Sprites+1, x
    STA currentPiece1+1, y
    LDA Sprites+2, x
    STA currentPiece1+2, y
    LDA Sprites+3, x
    CLC
    ADC #spawnX
    STA currentPiece1+3, y
    INX
    INX
    INX
    INX
    INY
    INY
    INY
    INY
    CPY #(4*4)
    BNE :-
    LDA #0
    STA rotationIndex
    JSR LoadNextPiece
    RTS
.endproc

.proc SwapSavedPiece

    LDA savedPieceCooldown
    BEQ :+
    RTS
:
    INC savedPieceCooldown

    LDA pieceIndex
    STA tempIndex
    ASL
    ASL
    ASL
    ASL
    TAX
    LDY #0
:
    LDA Sprites, x
    CLC
    ADC #savedY
    STA savedPiece1, y
    LDA Sprites+1, x
    STA savedPiece1+1, y
    LDA Sprites+2, x
    STA savedPiece1+2, y
    LDA Sprites+3, x
    CLC
    ADC #savedX
    STA savedPiece1+3, y
    INX
    INX
    INX
    INX
    INY
    INY
    INY
    INY
    CPY #(4*4)
    BNE :-

    LDA savedPieceIndex
    CMP #$FF
    BNE :+
    JSR SpawnNextPiece
    JMP End
:

    ASL
    ASL
    ASL
    ASL
    TAX
    LDY #0
:
    LDA Sprites, x
    CLC
    ADC #spawnY
    STA currentPiece1, y
    LDA Sprites+1, x
    STA currentPiece1+1, y
    LDA Sprites+2, x
    STA currentPiece1+2, y
    LDA Sprites+3, x
    CLC
    ADC #spawnX
    STA currentPiece1+3, y
    INX
    INX
    INX
    INX
    INY
    INY
    INY
    INY
    CPY #(4*4)
    BNE :-
    LDA savedPieceIndex
    STA pieceIndex
    JMP End

End:
    LDA tempIndex
    STA savedPieceIndex
    LDA #0
    STA rotationIndex

    RTS
    
.endproc

.segment "RODATA"

Sprites:
            ;vert tile attr horiz L
     .byte -8, $01, $20, 0
     .byte 0, $01, $20, 0
     .byte 8, $01, $20, 0
     .byte 8, $01, $20, 8
  
            ;vert tile attr horiz J
    .byte -8, $03, $20, 8
    .byte $0, $03, $20, 8
    .byte 8, $03, $20, 8
    .byte 8, $03, $20, 0

            ;vert tile attr horiz Z
    .byte -8, $02, $20, 0
    .byte -8, $02, $20, 8
    .byte 0, $02, $20, 8
    .byte 0, $02, $20, 16

            ;vert tile attr horiz S
    .byte -8, $04, $20, 8
    .byte -8, $04, $20, 16
    .byte 0, $04, $20, 8
    .byte 0, $04, $20, 0

            ;vert tile attr horiz T
    .byte -8, $02, $20, 0
    .byte -8, $02, $20, 8
    .byte -8, $02, $20, 16
    .byte 0, $02, $20, 8

            ;vert tile attr horiz O
    .byte -8, $04, $20, 0
    .byte -8, $04, $20, 8
    .byte 0, $04, $20, 0
    .byte 0, $04, $20, 8

            ;vert tile attr horiz I
    .byte -8, $01, $20, -8
    .byte -8, $01, $20, 0
    .byte -8, $01, $20, 8
    .byte -8, $01, $20, 16