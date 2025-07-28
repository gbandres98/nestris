.segment "OAM"
centerText:    .res 144
currentPiece1: .res 4
currentPiece2: .res 4
currentPiece3: .res 4
currentPiece4: .res 4
nextPiece1:    .res 4
nextPiece2:    .res 4
nextPiece3:    .res 4
nextPiece4:    .res 4
savedPiece1:   .res 4
savedPiece2:   .res 4
savedPiece3:   .res 4
savedPiece4:   .res 4
scoreDisplay:  .res 24
linesDisplay:  .res 12
levelDisplay:  .res 8
padding:       .res 20

.segment "CODE"

NMI:
    PHA
    TXA
    PHA
    TYA
    PHA

    INC frame

    ;;;;;; OAM
    LDA #$00
    STA $2003
    LDA #$02
    STA $4014

    LDA enableRendering
    BEQ :+
    LDA #%00011000
    STA $2001
    LDA #$0
    STA enableRendering
    STA renderingDisabled
:

    LDA disableRendering
    BEQ :+
    LDA #$0
    STA $2001
    STA disableRendering
    INC renderingDisabled
    JMP NMIEnd
:

    LDA renderingDisabled
    BEQ :+
    JMP NMIEnd
:

    LDA waitingLineClear
    BNE :+
    JMP LineClearAnimationEnd
:

    LDA waitingLineClearFirstFrame
    BEQ NoFirstFrame

    LDA #$0
    STA lineClearAnimationFrame
    STA lineClearAnimationIndex
;;;;;;;; Clear sprite
    LDX #$F
    LDA #$0
:
    STA currentPiece1, x
    DEX
    BPL :-

    LDA #$8C
    STA lineClearMapPtr
    STA lineClearNametablePtr
    LDA #$03
    STA lineClearMapPtr+1
    LDA hiddenNametableHi
    STA lineClearNametablePtr+1
    LDA #$0
    STA waitingLineClearFirstFrame

NoFirstFrame:

    INC lineClearAnimationFrame
    LDA lineClearAnimationFrame
    CMP #$5
    BEQ :+
    JMP NoAnimation
:
    LDA #0
    STA lineClearAnimationFrame
    INC lineClearAnimationIndex
    INC lineClearAnimationIndex

    LDY lineClearAnimationIndex
    CPY #$C
    BNE :+
;;;;;; Animation end
    JSR Score
    LDA #0
    STA completedLines
    STA completedLines+1
    STA completedLines+2
    STA completedLines+3

    LDA nametableHi
    STA tempIndex
    LDA hiddenNametableHi
    STA nametableHi
    LDA tempIndex
    STA hiddenNametableHi
    LDA ppuctrl
    EOR #%00000010
    STA ppuctrl
    LDA #$0
    STA waitingLineClear
    JMP LineClearAnimationEnd
:

    LDX lineClearAnimation, y
    LDY completedLines
    JSR SpriteToBG

    LDA $2002

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDY lineClearAnimationIndex
    LDX lineClearAnimation+1, y
    LDY completedLines
    JSR SpriteToBG

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDA completedLines+1
    BNE :+
    JMP NoAnimation
:

    LDY lineClearAnimationIndex
    LDX lineClearAnimation, y
    LDY completedLines+1
    JSR SpriteToBG

    LDA $2002

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDY lineClearAnimationIndex
    LDX lineClearAnimation+1, y
    LDY completedLines+1
    JSR SpriteToBG

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDA completedLines+2
    BNE :+
    JMP NoAnimation
:

    LDY lineClearAnimationIndex
    LDX lineClearAnimation, y
    LDY completedLines+2
    JSR SpriteToBG

    LDA $2002

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDY lineClearAnimationIndex
    LDX lineClearAnimation+1, y
    LDY completedLines+2
    JSR SpriteToBG

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDA completedLines+3
    BNE :+
    JMP NoAnimation
:

    LDY lineClearAnimationIndex
    LDX lineClearAnimation, y
    LDY completedLines+3
    JSR SpriteToBG

    LDA $2002

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007

    LDY lineClearAnimationIndex
    LDX lineClearAnimation+1, y
    LDY completedLines+3
    JSR SpriteToBG

    LDA tempPtr
    STA $2006
    LDA tempPtr+1
    STA $2006
    LDA #$0
    STA $2007
    
NoAnimation:

    LDA lineClearNametablePtr+1
    CMP #$23
    BEQ LineClearAnimationEnd
    CMP #$2B
    BEQ LineClearAnimationEnd

    STA $2006
    LDA lineClearNametablePtr
    STA $2006
    LDY #$0

:
    LDA (lineClearMapPtr), y
    STA $2007
    INY
    CPY #$A
    BNE :-

    LDA lineClearMapPtr
    CLC
    ADC #$20
    STA lineClearMapPtr
    LDA lineClearMapPtr+1
    ADC #$0
    STA lineClearMapPtr+1

    LDA lineClearNametablePtr
    CLC
    ADC #$20
    STA lineClearNametablePtr
    LDA lineClearNametablePtr+1
    ADC #$0
    STA lineClearNametablePtr+1

LineClearAnimationEnd:

    LDA levelChangeFlag
    BEQ ColorChangeEnd

    JSR ChangeColors

    LDA #0
    STA levelChangeFlag

ColorChangeEnd:

    LDA state
    CMP #0
    BNE :+
    JMP NMIEnd
:

    LDA inputDown
    BEQ :+
    LDA #2
    CMP fallTimer
    BCS :+
    STA fallTimer
:

    LDA fallTimer
    BEQ :+
    DEC fallTimer
:

    LDA moveTimer
    BEQ :+
    DEC moveTimer
:

;;;;;; Update background pieces
    LDA bgUpdateLock
    BNE NMIEnd

    LDA $2002

    LDX #$00
:
    CPX bgUpdateIndex
    BEQ EndBGUpdate

    LDA bgUpdateArray, x
    STA $2006
    INX
    LDA bgUpdateArray, x
    STA $2006
    INX
    LDA bgUpdateArray, x
    STA $2007
    INX
    JMP :-

EndBGUpdate:

    LDA #$00
    STA bgUpdateIndex

;;;;;;; Set Game Over background

    LDA gameOverBGFlag
    BEQ EndGameOverBG

    LDA $2002
    LDX tempCounter

    LDA GameOverRows, x
    CMP #$FF
    BNE :+
    LDA #$00
    STA gameOverBGFlag
    JMP EndGameOverBG
:

    ADC nametableHi
    STA $2006
    INX
    LDA GameOverRows, x
    INX
    STA $2006
    LDY #0
:
    CPY #$0A
    BEQ :+
    LDA #$FF
    STA $2007
    INY
    JMP :-
:
    STX tempCounter

EndGameOverBG:

    

NMIEnd:

;;;;;;; Reset scroll
    LDA ppuctrl
    STA $2000
    LDA #$00
    STA $2005
    STA $2005

    PLA
    TAY
    PLA
    TAX
    PLA

    RTI

.proc DisableRendering
    INC disableRendering
:
    LDA renderingDisabled
    BEQ :-
    RTS
.endproc

.proc ChangeColors
LDA level
:
    CMP #4
    BCC :+
    SEC
    SBC #5
    JMP :-
:

    ASL
    ASL
    TAX
    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$02
    STA $2006
    LDA LevelColors, x
    STA $2007
    LDA LevelColors+1, x
    STA $2007

    LDA #$3F
    STA $2006
    LDA #$06
    STA $2006
    LDA LevelColors+2, x
    STA $2007

    LDA #$3F
    STA $2006
    LDA #$12
    STA $2006
    LDA LevelColors, x
    STA $2007
    LDA LevelColors+1, x
    STA $2007

    RTS
.endproc