Option _Explicit

Const true = -1, false = 0

Dim Shared As Long boardX, boardY
boardX = 0
boardY = _FontHeight

Randomize Timer

Type blocks
    As Integer x, y, w, h
    As _Unsigned Long low, high
    As String note
End Type

Dim Shared As blocks block(1 To 4)
Dim Shared As Long canvas, gameScreen

Dim i As Long

gameScreen = _NewImage(400, 400 + _FontHeight, 32)
canvas = _NewImage(400, 400, 32)

Screen gameScreen
Do Until _ScreenExists: Loop
_Title "Genius"

For i = 1 To 4
    block(i).w = _Width(canvas) \ 2
    block(i).h = _Height(canvas) \ 2
Next

i = 0
i = i + 1: block(i).x = 0: block(i).y = 0
block(i).note = "o3c" 'green
block(i).high = _RGB32(0, 155, 0)
block(i).low = _RGB32(0, 78, 0)

i = i + 1: block(i).x = 0: block(i).y = _Height(canvas) \ 2
block(i).note = "o2e" 'red
block(i).high = _RGB32(227, 0, 0)
block(i).low = _RGB32(78, 0, 0)

i = i + 1: block(i).x = _Width(canvas) \ 2: block(i).y = 0
block(i).note = "o2g" 'yellow
block(i).high = _RGB32(194, 194, 0)
block(i).low = _RGB32(161, 116, 0)

i = i + 1: block(i).x = _Width(canvas) \ 2: block(i).y = _Height(canvas) \ 2
block(i).note = "o2b" 'blue
block(i).high = _RGB32(0, 105, 233)
block(i).low = _RGB32(0, 0, 78)


Dim Shared As _Byte gameOver, inGame
Dim Shared sequence$, goal As Integer
Const initialGoal = 3
goal = initialGoal

Do
    If gameOver Then
        gameOver = false
        inGame = false
        goal = initialGoal
    End If

    If inGame Then
        resetSequence
        Do 'main game
            Dim As Integer x, y

            If Len(sequence$) \ 2 = goal Then
                Color _RGB32(0, 222, 0)
                _PrintString (x, y), String$(goal, 1)
                _Display
                goal = goal + 2
                Exit Do
            End If

            Cls
            addNote
            y = boardY - _FontHeight
            x = (_Width - _PrintWidth(String$(goal, 254))) \ 2
            Color _RGB32(78)
            _PrintString (x, y), String$(goal, 254)
            Color _RGB32(255)
            _PrintString (x, y), String$(Len(sequence$) \ 2, 254)
            playSequence
            getSequence
        Loop Until gameOver
        If gameOver Then resetSequence
    Else
        showMenu
    End If
Loop

Sub showMenu
    Dim m$
    Dim As Long x, y, mx, my
    Dim As _Byte mouseIsDown, mouseDownOnStart, startButtonHovered

    m$ = "< Start >"
    y = boardY - _FontHeight
    x = (_Width - _PrintWidth(m$)) \ 2
    Do
        Cls
        drawBoard

        While _MouseInput: Wend
        mx = _MouseX: my = _MouseY

        startButtonHovered = (mx >= x And mx <= x + _PrintWidth(m$) And my >= y And my <= y + _FontHeight)

        If startButtonHovered Then
            Color _RGB32(0), _RGB32(255)
        Else
            Color _RGB32(255), _RGB32(0)
        End If

        _PrintString (x, y), m$
        Color , _RGB32(0)

        If _MouseButton(1) Then
            If mouseIsDown = false Then
                mouseIsDown = true
                mouseDownOnStart = false
                If startButtonHovered Then mouseDownOnStart = true
            Else
            End If
        Else
            If mouseIsDown Then
                If mouseDownOnStart And startButtonHovered Then
                    inGame = true
                    Cls
                    Exit Sub
                End If
            End If
            mouseIsDown = false
        End If
        _Display
        _Limit 30
    Loop Until _KeyHit
End Sub

Sub getSequence Static
    Dim As Long i, index, mouseDownOn, mx, my, check
    Dim As Integer x, y
    Dim As _Byte mouseIsDown
    Dim start!

    x = (_Width - _PrintWidth(String$(goal, 254))) \ 2
    y = boardY - _FontHeight
    index = 0
    mouseIsDown = false
    mouseDownOn = 0
    start! = Timer
    Do
        If timeElapsedSince(start!) > 3 Then
            gameOver = true
            Color _RGB32(127, 0, 0)
            _PrintString (x, y), String$(goal, 254)
            Exit Do
        End If

        drawBoard
        While _MouseInput: Wend
        mx = _MouseX - boardX: my = _MouseY - boardY
        If _MouseButton(1) Then
            start! = Timer
            If mouseIsDown = false Then
                mouseIsDown = true
                For i = 1 To 4
                    If mx >= block(i).x And mx <= block(i).x + block(i).w And my >= block(i).y And my <= block(i).y + block(i).h Then
                        mouseDownOn = i
                        Exit For
                    End If
                Next
            Else
                For i = 1 To 4
                    If mx >= block(i).x And mx <= block(i).x + block(i).w And my >= block(i).y And my <= block(i).y + block(i).h Then
                        If mouseDownOn = i Then drawSquare mouseDownOn, 2
                        Exit For
                    End If
                Next
            End If
        Else
            If mouseIsDown = true Then
                For i = 1 To 4
                    If mx >= block(i).x And mx <= block(i).x + block(i).w And my >= block(i).y And my <= block(i).y + block(i).h Then
                        If i = mouseDownOn Then
                            'click
                            index = index + 1
                            If index < Len(sequence$) \ 2 Then
                                Color _RGB32(238, 166, 0)
                            Else
                                Color _RGB32(0, 166, 238)
                            End If
                            _PrintString (x, y), String$(index, 254)

                            check = CVI(Mid$(sequence$, index * 2 - 1, 2))
                            drawBoard
                            drawSquare i, 2
                            Play "l16" + block(i).note + "l4"
                            _Display
                            If i = check Then
                                If index = Len(sequence$) \ 2 Then
                                    drawBoard
                                    _Display
                                    _Delay .5
                                    Exit Do
                                End If
                            Else
                                'error - restart
                                gameOver = true
                                Color _RGB32(127, 0, 0)
                                _PrintString (x, y), String$(goal, 254)
                                Exit Do
                            End If
                        End If
                        Exit For
                    End If
                Next
            Else
                'hover
                'FOR i = 1 TO 4
                '    IF mx >= block(i).x AND mx <= block(i).x + block(i).w AND my >= block(i).y AND my <= block(i).y + block(i).h THEN
                '        LINE (boardX + block(i).x, boardY + block(i).y)-STEP(block(i).w - 1, block(i).h - 1), _RGB32(255, 50), BF
                '        EXIT FOR
                '    END IF
                'NEXT
            End If
            mouseIsDown = false
        End If
        _Display
    Loop
End Sub

Sub addNote
    Dim i As Long
    i = _Ceil(Rnd * 4)
    sequence$ = sequence$ + MKI$(i)
End Sub

Sub playSequence
    Dim As Long j, i
    For j = 1 To Len(sequence$) \ 2
        drawBoard
        _Display
        _Delay .05
        i = CVI(Mid$(sequence$, j * 2 - 1, 2))
        drawSquare i, 2
        _Display
        _Delay .2
        Play block(i).note
    Next
End Sub

Sub resetSequence
    Dim As Long j, i
    sequence$ = ""

    If Not gameOver Then
        Play "mbT240l16aebcbedfcaebl4"
        'animation
        For j = 1 To 12
            i = i + 1
            If i = 5 Then i = 1
            drawBoard
            drawSquare i, 2
            _Display
            _Limit 20
        Next
        Play "T120mf"
    Else
        For i = 1 To 4
            drawSquare i, 2
        Next
        _Display
        Play "t120mfl2o1cl4"
    End If
    drawBoard
    _Display
    _Delay .5
End Sub

Sub drawBoard
    Static board As Long
    Dim As Long i

    If board = 0 Then
        board = _NewImage(_Width(canvas), _Height(canvas), 32)
        For i = 1 To 4
            drawSquare i, 1
        Next
        _PutImage (0, 0), , board, (boardX, boardY)-Step(_Width(canvas) - 1, _Height(canvas) - 1)
    Else
        _PutImage (boardX, boardY), board
    End If

End Sub

Sub drawSquare (this As Integer, c As Integer)
    Dim thisColor As _Unsigned Long
    If c = 1 Then thisColor = block(this).low Else thisColor = block(this).high
    Line (boardX + block(this).x, boardY + block(this).y)-Step(block(this).w - 1, block(this).h - 1), thisColor, BF
End Sub

Function timeElapsedSince! (startTime!)
    If startTime! > Timer Then startTime! = startTime! - 86400
    timeElapsedSince! = Timer - startTime!
End Function

