.segment "CODE"

Main:
    JSR ReadControllers

;;;;;;;;; RNG
    JSR RollSeed

    LDA state
    CMP #0
    BEQ :+ 
    JMP startMenuEnd
:

;;;;;;;;;;; Start Menu ;;;;;;;;;;;;;
    LDA inputStart
    CMP #1
    BEQ :+
    JMP MainEnd
:
    INC inputStart

;;;;; Remove Press Start message

    LDX #$2B
    LDA #$0
:
    STA centerText, x
    DEX
    BPL :-

;;;;; Load line display

    LDY #$0
    LDX #$30
:
    LDA #$47
    STA linesDisplay, y
    LDA #$10
    STA linesDisplay+1, y
    LDA #$01
    STA linesDisplay+2, y
    TXA
    STA linesDisplay+3, y
    SEC
    SBC #$08
    TAX
    INY
    INY
    INY
    INY
    CPY #12
    BNE :-

;;;;; Load score display

    LDY #$0
    LDX #$48
:
    LDA #$2F
    STA scoreDisplay, y
    LDA #$10
    STA scoreDisplay+1, y
    LDA #$01
    STA scoreDisplay+2, y
    TXA
    STA scoreDisplay+3, y
    SEC
    SBC #$08
    TAX
    INY
    INY
    INY
    INY
    CPY #24
    BNE :-

;;;;; Load level display

    LDA #$6F
    STA levelDisplay
    LDA #$11
    STA levelDisplay+1
    LDA #$01
    STA levelDisplay+2
    LDA #$E0
    STA levelDisplay+3
    LDA #$6F
    STA levelDisplay+4
    LDA #$10
    STA levelDisplay+5
    LDA #$01
    STA levelDisplay+6
    LDA #$D8
    STA levelDisplay+7

;;;;; Load next piece
    JSR LoadNextPiece
    JSR SpawnNextPiece

    LDA #1
    STA state
    LDA #$FF
    STA savedPieceIndex
    JMP MainEnd

startMenuEnd:

    CMP #2
    BNE gameOverEnd
;;;;;;;;;;;;;;;;;; Game Over ;;;;;;;;;;;;;;;;;;
    LDA inputStart
    CMP #1
    BEQ :+
    JMP MainEnd
:
    INC inputStart
    JSR DisableRendering 

    JSR GameInit

    LDA #0
    STA state

    INC enableRendering

    JMP MainEnd

gameOverEnd:

;;;;;;;;; RotateRight
    LDA inputRotateRight
    CMP #1
    BNE :+
    INC inputRotateRight
    JSR RotateRight
:
;;;;;;;;; RotateLeft
    LDA inputRotateLeft
    CMP #1
    BNE :+
    INC inputRotateLeft
    JSR RotateLeft
:

    LDA moveTimer
    BEQ :+
    JMP NoMove
:

;;;;;;;;; MoveRight

    LDA inputRight
    BNE :+
    JMP NoMoveRight
:

    LDA currentPiece1
    STA collisionCheck1+1
    LDA currentPiece1+3
    CLC
    ADC #$08
    STA collisionCheck1

    LDA currentPiece2
    STA collisionCheck2+1
    LDA currentPiece2+3
    CLC
    ADC #$08
    STA collisionCheck2

    LDA currentPiece3
    STA collisionCheck3+1
    LDA currentPiece3+3
    CLC
    ADC #$08
    STA collisionCheck3

    LDA currentPiece4
    STA collisionCheck4+1
    LDA currentPiece4+3
    CLC
    ADC #$08
    STA collisionCheck4

    JSR CollisionCheck
    BNE :+
    LDA #08
    STA moveTimer
:

NoMoveRight:

;;;;;;;;; MoveLeft

    LDA inputLeft
    BNE :+
    JMP NoMove
:

    LDA currentPiece1
    STA collisionCheck1+1
    LDA currentPiece1+3
    SEC
    SBC #$08
    STA collisionCheck1

    LDA currentPiece2
    STA collisionCheck2+1
    LDA currentPiece2+3
    SEC
    SBC #$08
    STA collisionCheck2

    LDA currentPiece3
    STA collisionCheck3+1
    LDA currentPiece3+3
    SEC
    SBC #$08
    STA collisionCheck3

    LDA currentPiece4
    STA collisionCheck4+1
    LDA currentPiece4+3
    SEC
    SBC #$08
    STA collisionCheck4

    JSR CollisionCheck
    BNE :+
    LDA #08
    STA moveTimer
:

NoMove:

    LDA inputSave
    BEQ :+
    JSR SwapSavedPiece
:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fall
    LDA fallTimer
    BEQ :+
    JMP MainEnd
:
    
    LDA currentPiece1
    CLC
    ADC #8
    STA collisionCheck1+1
    LDA currentPiece1+3
    STA collisionCheck1

    LDA currentPiece2
    CLC
    ADC #8
    STA collisionCheck2+1
    LDA currentPiece2+3
    STA collisionCheck2

    LDA currentPiece3
    CLC
    ADC #8
    STA collisionCheck3+1
    LDA currentPiece3+3
    STA collisionCheck3

    LDA currentPiece4
    CLC
    ADC #8
    STA collisionCheck4+1
    LDA currentPiece4+3
    STA collisionCheck4

    JSR CollisionCheck
    BNE :+
    LDA fallSpeed
    STA fallTimer
    JMP MainEnd
:

;;;;;;;;; Check for game over


    LDA currentPiece1
    CMP #$1f
    BCS :+
    JSR PrintGameOver
    JMP MainEnd
:

    LDA currentPiece2
    CMP #$1f
    BCS :+
    JSR PrintGameOver
    JMP MainEnd
:

    LDA currentPiece3
    CMP #$1f
    BCS :+
    JSR PrintGameOver
    JMP MainEnd
:

    LDA currentPiece4
    CMP #$1f
    BCS :+
    JSR PrintGameOver
    JMP MainEnd
:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Move piece to BG

    INC bgUpdateLock

    LDY currentPiece1
    LDX currentPiece1+3
    JSR SpriteToBG
    
    LDX bgUpdateIndex
    LDA tempPtr
    STA bgUpdateArray, x
    INX
    LDA tempPtr+1
    STA bgUpdateArray, x
    INX
    LDA currentPiece1+1
    STA bgUpdateArray, x
    INX
    STX bgUpdateIndex

    LDY currentPiece2
    LDX currentPiece2+3
    JSR SpriteToBG
    
    LDX bgUpdateIndex
    LDA tempPtr
    STA bgUpdateArray, x
    INX
    LDA tempPtr+1
    STA bgUpdateArray, x
    INX
    LDA currentPiece2+1
    STA bgUpdateArray, x
    INX
    STX bgUpdateIndex

    LDY currentPiece3
    LDX currentPiece3+3
    JSR SpriteToBG
    
    LDX bgUpdateIndex
    LDA tempPtr
    STA bgUpdateArray, x
    INX
    LDA tempPtr+1
    STA bgUpdateArray, x
    INX
    LDA currentPiece3+1
    STA bgUpdateArray, x
    INX
    STX bgUpdateIndex

    LDY currentPiece4
    LDX currentPiece4+3
    JSR SpriteToBG
    
    LDX bgUpdateIndex
    LDA tempPtr
    STA bgUpdateArray, x
    INX
    LDA tempPtr+1
    STA bgUpdateArray, x
    INX
    LDA currentPiece4+1
    STA bgUpdateArray, x
    INX
    STX bgUpdateIndex

    DEC bgUpdateLock
    LDA #$0
    STA savedPieceCooldown

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Save piece in piece table

    LDY currentPiece1
    LDX currentPiece1+3
    JSR SpriteToPieceMap
    LDY #$0
    LDA currentPiece1+1
    STA (tempPtr), y

    LDY currentPiece2
    LDX currentPiece2+3
    JSR SpriteToPieceMap
    LDY #$0
    LDA currentPiece2+1
    STA (tempPtr), y

    LDY currentPiece3
    LDX currentPiece3+3
    JSR SpriteToPieceMap
    LDY #$0
    LDA currentPiece3+1
    STA (tempPtr), y

    LDY currentPiece4
    LDX currentPiece4+3
    JSR SpriteToPieceMap
    LDY #$0
    LDA currentPiece4+1
    STA (tempPtr), y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check piece table for completed lines

;; 60 1F - A8 B7 - 10x20
:
    JSR CheckLineClears
    LDA completedLineIndex
    BNE :-
    JSR WaitForLineClear

;;;;;;;; Load Sprite

    JSR SpawnNextPiece

MainEnd:

    JMP Main     ; an infinite loop when init code is run

.proc RollSeed
    LDX #0
    LDA seed
:
    ROR
    BCC :+
    EOR frame
:   
    DEX
    BNE :--
    STA seed
    RTS
.endproc

.proc ReadControllers
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016 ; Controller ready to read

    LDA $4016 ; A
    AND #1
    BEQ :+
    LDA inputRotateRight
    BNE HandleAEnd
    LDA #1
    STA inputRotateRight
    JMP HandleAEnd
:
    LDA #0
    STA inputRotateRight

HandleAEnd:

    LDA $4016 ; B
    AND #1
    BEQ :+
    LDA inputRotateLeft
    BNE HandleBEnd
    LDA #1
    STA inputRotateLeft
    JMP HandleBEnd
:
    LDA #0
    STA inputRotateLeft

HandleBEnd:

    LDA $4016 ; Select

    LDA $4016 ; Start
    AND #1
    BEQ :+
    LDA inputStart
    BNE HandleStartEnd
    LDA #1
    STA inputStart
    JMP HandleStartEnd
:
    LDA #0
    STA inputStart

HandleStartEnd:

    LDA $4016 ; Up
    AND #1
    STA inputSave

    LDA $4016 ; Down
    AND #1
    STA inputDown

    LDA $4016 ; Left
    AND #1
    STA inputLeft

    LDA $4016 ; Right
    AND #1
    STA inputRight

    RTS
.endproc