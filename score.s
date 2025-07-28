.segment "CODE"

.proc CheckLineClears
    LDA #$17
    STA tempY
Row:
    LDA #$58
    STA tempX
    LDA tempY
    CLC
    ADC #$08
    CMP #$BF
    STA tempY
    BNE Column
    LDA #$0
    STA completedLineIndex
    JMP End
Column:
    LDA tempX
    CLC
    ADC #$08
    CMP #$B0
    STA tempX
    BEQ LineFound

    LDX tempX
    LDY tempY
    JSR SpriteToPieceMap
    BEQ Row
    JMP Column

LineFound:
    LDA tempY
    STA completedLineIndex
    LDY waitingLineClear
    STA completedLines, y
    INC waitingLineClear
    INC waitingLineClearFirstFrame
    JSR ClearLine

End:
    RTS
.endproc

.proc ClearLine
    LDY completedLineIndex
    LDX #$60

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

    LDX #$0
    LDA #$0
Column:
    LDA tempPtr
    CMP #$8C
    BNE :+
    LDA tempPtr+1
    CMP #$03
    BEQ End
:
    LDA tempPtr
    SEC
    SBC #$20 ;; Pointer to the row above
    STA tempPtr1
    LDA tempPtr+1
    SBC #0 ;; Apply borrow
    STA tempPtr1+1
    LDY #$9 ;;; Start with last piece of the row
Row:
    LDA (tempPtr1), y
    STA (tempPtr), y
    DEY
    BPL Row
    LDA tempPtr1
    STA tempPtr
    LDA tempPtr1+1
    STA tempPtr+1
    JMP Column
End:
    RTS
.endproc

.proc WaitForLineClear
    LDA waitingLineClear
    BNE WaitForLineClear
    RTS
.endproc

.proc Score

;;;; Lines

    LDA #$0
    STA tempCounter

    LDA completedLines
    BEQ :+
    INC tempCounter
:
    LDA completedLines+1
    BEQ :+
    INC tempCounter
:
    LDA completedLines+2
    BEQ :+
    INC tempCounter
:
    LDA completedLines+3
    BEQ :+
    INC tempCounter
:

    LDA lines
    CLC
    ADC tempCounter
    CMP #10
    BMI :+
    SEC
    SBC #10
    JSR ChangeLevel
    SEC
:
    STA lines

    LDA lines+1
    ADC #0
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA lines+1

    LDA lines+2
    ADC #0
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA lines+2

    LDA lines
    CLC
    ADC #$10
    STA linesDisplay+1

    LDA lines+1
    CLC
    ADC #$10
    STA linesDisplay+5
    CLC
    ADC #1
    STA levelDisplay+1

    LDA lines+2
    CLC
    ADC #$10
    STA linesDisplay+9
    STA levelDisplay+5

;;;;;;; Score

    LDA #0
    STA addDigits
    STA addDigits+1
    STA addDigits+2
    STA addDigits+3

    LDA tempCounter

    CMP #1
    BNE :+
    LDX #4
    STX addDigits+1
:
    CMP #2
    BNE :+
    LDX #1
    STX addDigits+2
:
    CMP #3
    BNE :+
    LDX #3
    STX addDigits+2
:
    CMP #4
    BNE :+
    LDX #1
    STX addDigits+3
    LDX #2
    STX addDigits+2
:

    LDX level
    INX
Loop:
    CPX #0
    BEQ EndScoring

    LDA score
    CLC
    ADC addDigits
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA score

    LDA score+1
    ADC addDigits+1
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA score+1

    LDA score+2
    ADC addDigits+2
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA score+2

    LDA score+3
    ADC addDigits+3
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA score+3

    LDA score+4
    ADC #0
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA score+4

    LDA score+5
    ADC #0
    CMP #10
    BMI :+
    SEC
    SBC #10
    SEC
:
    STA score+5
    DEX
    JMP Loop

EndScoring:

    LDA score
    CLC
    ADC #$10
    STA scoreDisplay+1

    LDA score+1
    CLC
    ADC #$10
    STA scoreDisplay+5

    LDA score+2
    CLC
    ADC #$10
    STA scoreDisplay+9

    LDA score+3
    CLC
    ADC #$10
    STA scoreDisplay+13

    LDA score+4
    CLC
    ADC #$10
    STA scoreDisplay+17

    LDA score+5
    CLC
    ADC #$10
    STA scoreDisplay+21

    RTS

.endproc

.proc ChangeLevel
    PHA

    INC level
    LDY level
    CPY #$9
    BPL :+
    LDA FallSpeedPerLevel, y
    STA fallSpeed
:

    LDA #1
    STA levelChangeFlag

    PLA
    RTS

.endproc

.proc PrintGameOver

    LDX #$57
:
    LDA GameOver, x
    STA centerText, x
    DEX
    BPL :-

    LDA #0
    STA tempCounter

    LDA #1
    STA gameOverBGFlag

    LDA #2
    STA state

    RTS

.endproc

.segment "RODATA"

LevelColors:
    .byte $28,$22,$32,$00
    .byte $1B,$15,$35,$00
    .byte $26,$2C,$36,$00
    .byte $1C,$27,$3C,$00
    .byte $13,$17,$33,$00

GameOverRows:
    .byte $01,$2C, $01,$4C, $01,$6C, $01,$8C
    .byte $01,$AC, $01,$CC, $01,$EC, $02,$0C
    .byte $FF

FallSpeedPerLevel:
    .byte 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 1 

lineClearAnimation:
    .byte $0,  $0
    .byte $80, $88
    .byte $78, $90
    .byte $70, $98
    .byte $68, $A0
    .byte $60, $A8

GameOver:
  .byte $4F,$26,$01,$78
  .byte $4F,$20,$01,$80
  .byte $4F,$2C,$01,$88
  .byte $4F,$24,$01,$90
  .byte $5A,$2E,$01,$78
  .byte $5A,$35,$01,$80
  .byte $5A,$24,$01,$88
  .byte $5A,$31,$01,$90
  .byte $6F,$2F,$01,$75
  .byte $6F,$31,$01,$7D
  .byte $6F,$24,$01,$85
  .byte $6F,$32,$01,$8D
  .byte $6F,$32,$01,$95
  .byte $79,$32,$01,$75
  .byte $79,$33,$01,$7D
  .byte $79,$20,$01,$85
  .byte $79,$31,$01,$8D
  .byte $79,$33,$01,$95
  .byte $5A,$3A,$01,$98