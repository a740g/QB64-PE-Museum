''
'' Here's a quick and dirty program based on Stunt Chopper, a game by David
'' Duvenaud and James Challis. Some of the graphics (namely the guy, the
'' chopper and the wagon) have been copy/pasted from their game. The flying
'' saucer is coming from Taito's Space Invaders.
''
'' In this project, I wanted to write something that:
'' - Is self-contained. No external resources.
'' - Doesn't use CALL ABSOLUTE. No assembly, hopefuly, none required either.
'' - Doesn't use OUT or INP(). That means no DAC access, and no Mode Y.
''
'' Move the chopper around and drop a stuntman with the space bar. The guy
'' has to land on the wagon that is passing by. You get one extra life every
'' 5000 points and the fastest the stuntman is moving, the more points you
'' get (when jumping, he inherits the momentum of the chopper.) Gamepad
'' recommended.
''
'' The game could use additional obstacles, like kytes and birds, and take
'' the direction of the wind into account. But that'll do I guess.
''
'' - Mike Hawk, 2019
''

$Resize:Smooth

Const lifeUpStep = 5000 ' get a life up every 5000 points
Const helicoMaxVel = 3 ' helicopter's maximum velocity
Const tickSize = .01 ' tick duration

Const statDropGuy = &H1 ' stuntman falling
Const statGuyCrash = &H2 ' stuntman cratered
Const statGuyLand = &H4 ' stuntman landed properly
Const statTooSlow = &H8 ' wagon passed by
Const statUFOCrash = &H10 ' collided with UFO
Const statParticles = &H20 ' show/update particles
Const statGameOver = 30 ' stuntman landed/cratered, wagon is gone, UFO collision
Const statFailed = 16 + 8 + 2

Const movLeft = &H1 ' move to the left
Const movRight = &H2 ' move to the right
Const movUp = &H4 ' move up
Const movDown = &H8 ' move down

Const barStage = &H1 ' draw stage number on status bar
Const barLives = &H2 ' draw lives number on status bar
Const barScore = &H4 ' draw score value on status bar
Const barText = &H8 ' also draw text on status bar (work with 0x01, 0x02, 0x04)
Const barAll = &HF ' refresh whole status bar

Type timeStruct
    current As Single ' current game time
    elapsed As Single ' time elapsed since last rendering
    previous As Single ' previous time
    lag As Single ' how late updates are
End Type

Type moveStruct
    X As Single ' x coordinate
    Y As Single ' y coordinate
    VelX As Single ' x velocity
    VelY As Single ' y velocity
End Type

Type gameStruct
    stage As Integer ' current stage
    lives As Integer ' number of lives left
    score As Long ' current score
    lifeUp As Long ' next live up
    stat As Integer ' game status
    restart As Integer ' delay before retrying/next level

    pClr As Integer ' particles color
    saucer As moveStruct ' flying saucer
    saucerNext As Integer ' delay before next saucer
    saucerHere As Integer ' TRUE if saucer is here
    helico As moveStruct ' helicopter movement
    guy As moveStruct ' stuntman movement
    guyAngle As Integer ' stuntman current angle
    guySpin As Integer ' stuntman spin angle

    wagonX As Integer ' wagon X coordinate
End Type

Dim Shared game As gameStruct
Dim Shared joystick As Integer
Dim Shared horseClr(0 To 1 + 62 * 4) As Integer
Dim Shared horseAlf(0 To 1 + 62 * 4) As Integer
Dim Shared saucerClr(0 To 1 + 17 * 4) As Integer
Dim Shared saucerAlf(0 To 1 + 17 * 4) As Integer
Dim Shared particle(0 To 15) As moveStruct

init
Do
    mainLoop
Loop Until stageGameOver%
finish

Data "     oo     o    o   o  o       o      ggg             iggg   "
Data "   ooo     o   o  o o oo  oo   o      babbb          iggggaggg"
Data "  hhhohhohhhhohhohhhhhhooohhhhhhhhh  bbbb           iggggggggg"
Data " hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh gbbbbbb         gggggggg  "
Data " hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhggggbbbbb  iiiggggggggggg    "
Data "     ggggggg          ggggggg    ggggggggbb iigggggggggggggg  "
Data "    ggg   ggg        ggg   ggg              ggggg     ggg gg  "
Data "     ggggggg          ggggggg               ggg gg   ggg   gg "

Data "      hhhii      "
Data "     hiiiiii     "
Data "   hiiiiiiiiii   "
Data "  hiioioioioiii  "
Data " hiiiiiiiiiiiiii "
Data "hiiiiiiiiiiiiiiii"
Data "  hii  hii  hii  "
Data "   i         i   "

Sub centerPrint (Y As Integer, msg As String)
    Locate Y, 20 - Len(msg) \ 2
    Print msg
End Sub

''
'' Draw background scenery
''
Sub drawScene
    Dim X As Integer, Y As Integer
    Dim clr(0 To 5) As Integer

    clr(0) = 1
    clr(1) = 9
    clr(2) = 3
    clr(3) = 11
    clr(4) = 15
    clr(5) = 15

    ' select page 2, display page 0
    Screen , , 2, 0

    ' draw sky
    pattern = 21845
    For i% = 0 To 4
        Line (0, Y)-Step(319, 39), clr(i% + 1), BF
        For j% = 0 To 9
            Line (0, Y + j%)-Step(319, 0), clr(i%), , pattern
            pattern = pattern Xor &HFFFF
        Next j%
        For j% = 10 To 24 Step 2
            Line (0, Y + j%)-Step(319, 0), clr(i%), , pattern
            pattern = pattern Xor &HFFFF
        Next j%
        Y = Y + 40
    Next i%

    ' draw ground
    Line (0, 173)-(319, 191), 10, BF
    X = 0
    Draw "TA0"
    Do
        Y = Int(Rnd * 18) + 174
        PSet (X, Y), 2
        Draw "u2d2 r1 g-1g1 l2 h1h-1"
        X = X + Int(Rnd * 20) + 5
    Loop While (X < 320)
    Line (0, 173)-(319, 173), 2


    ' draw trees
    X = 10
    Do
        Y = (Int(Rnd * 5) + 3) * 3
        Line (X - 1, 172 - Y)-(X + 1, 172), 6, BF
        Circle (X, 162 - Y), 10, 2, , , 2
        Paint (X, 162 - Y), 2
        Circle (X + 2, 156 - Y), 1, 10
        PSet (X + 2, 156 - Y), 10
        X = X + Int(Rnd * 30) + 10
    Loop While (X < 309)

    drawStatusBar barAll

    ' back to default working page
    Screen , , 1, 0
End Sub

''
'' Update status bar
''
Sub drawStatusBar (what As Integer)
    Dim msg As String, sze As Integer

    ' select background page
    Screen , , 2, 0

    Color 7
    Locate 25

    If (what And barText) Then
        Locate , 1
        Print "STAGE ## / LIVES ###### / SCORE ########";
    End If

    ' stage
    If (what And barStage) Then
        msg = LTrim$(RTrim$(Str$(game.stage)))
        If (Len(msg) > 2) Then msg = Right$(msg, 2)
        Locate , 7
        Print String$(2 - Len(msg), "0") + msg;
    End If

    ' lives
    If (what And barLives) Then
        Select Case game.lives
            Case Is < 1
                sze = 0
            Case Is > 6
                sze = 6
            Case Else
                sze = game.lives
        End Select
        Locate , 18
        Color 4
        Print String$(6 - sze, " ");
        If (sze) Then Print String$(sze, 3);
        Color 7
    End If

    ' score
    If (what And barScore) Then
        msg = LTrim$(RTrim$(Str$(game.score)))
        If (Len(msg) > 8) Then msg = Right$(msg, 8)
        Locate , 33
        Print String$(8 - Len(msg), "0") + msg;
    End If

    ' back to default working page
    Screen , , 1, 0
End Sub

Sub dropGuy
    If (game.stat And statGameOver) Then Exit Sub
    game.stat = game.stat Or statDropGuy
    game.guy.VelX = game.helico.VelX
    game.guy.VelY = game.helico.VelY
    Select Case game.guy.VelX
        Case Is > 0
            game.guySpin = -(Int(Rnd * 24) + 4)
        Case Is < 0
            game.guySpin = Int(Rnd * 24) + 4
        Case Else
            game.guySpin = 0
    End Select
End Sub

''
'' Go back to screen 0 before exiting
''
Sub finish
    Screen 0
    Width 80, 25
    Color 7, 0
    Cls
    Print "Stunt Chopper, a terrible rewrite of"
    Print "David Duvenaud and James Challis' game."
    Print "- Mike Hawk, 2019"
End Sub

''
'' Initialize graphics
''
Sub init
    Dim picInfo As String, tmr As Single, clr(0 To 3) As Integer

    _Title "Stunt Chopper"
    Screen 7, 0, 0, 0
    _FullScreen _SquarePixels , _Smooth

    Randomize Timer
    joystick = joyFound%

    clr(1) = 8
    clr(2) = 7
    clr(3) = 15

    For i% = 1 To 3
        Color clr(i%)
        Locate 5
        centerPrint 5, "Stunt Chopper"
        centerPrint 7, "A very simple QB game"
        centerPrint 8, "2019 - Mike Hawk"
        tmr = Timer + .25
        Do: Loop While tmr > Timer
    Next i%

    tmr = Timer + 4 ' do timer now, so loading is included in pause

    Screen , , 2, 0 ' select temporary buffer

    For Y% = 0 To 15 ' read each line
        Read picInfo
        For X% = 0 To Len(picInfo) - 1
            a = Asc(Mid$(picInfo, X% + 1, 1))
            Select Case a
                Case 97 To 112
                    a = a - 97
                    b = 0
                Case Else
                    a = 0
                    b = 15
            End Select
            PSet (X%, Y%), a
            PSet (100 + X%, Y%), b
        Next X%
    Next Y%
    Get (0, 0)-Step(61, 7), horseClr()
    Get (100, 0)-Step(61, 7), horseAlf()
    Get (0, 8)-Step(16, 7), saucerClr()
    Get (100, 8)-Step(16, 7), saucerAlf()
    Do: Loop While tmr > Timer

    Screen , , 0, 0
    For i% = 0 To 3
        Color clr(3 - i%)
        Locate 5
        centerPrint 5, "Stunt Chopper"
        centerPrint 7, "A very simple QB game"
        centerPrint 8, "2019 - Mike Hawk"
        tmr = Timer + .25
        Do: Loop While tmr > Timer
    Next i%
End Sub

''
'' Joystick X,Y coordinates
''
Sub joyCoords (X As Single, Y As Single)
    Dim joy(0 To 1) As Single

    For i% = 0 To 1
        joy(i%) = Stick(i%) - 128
        If (Abs(joy(i%)) < 30) Then
            joy(i%) = 0
        Else
            If (joy(i%) > 0) Then
                joy(i%) = (joy(i%) - 30) / 97
            Else
                joy(i%) = (joy(i%) + 30) / 97
            End If
        End If
    Next i%
    X = joy(0)
    Y = joy(1)
End Sub

''
'' Joystick plugged in
''
Function joyFound%
    joyFound% = (Stick(0) <> 0) And (Stick(1) <> 0)
End Function

''
'' Game loop
''
Sub mainLoop
    Dim guyGraph As String, helicoGraph As String
    Dim gt As timeStruct
    Dim frame As Integer, moveFlag As Integer, goWagon As Integer, blade As Integer
    Dim tmpScore As Long

    ' draw statements
    guyGraph = "h2e1r1f1g1d2r2e1g1l4h1f1r2d2f2h2g2"
    helicoGraph = "l2g2d2f2r2d2l2r6l2u2l2r4e2r5e2l7h2l3u1"

    ' setup timer
    gt.previous = Timer

    ' setup first level
    stageFirst

    Do
        ''
        '' Timer update
        ''
        gt.current = Timer
        gt.elapsed = gt.current - gt.previous
        gt.previous = gt.current
        gt.lag = gt.lag + gt.elapsed

        While (gt.lag >= tickSize)
            ''
            '' Input
            ''
            moveFlag = 0
            Select Case InKey$
                Case Chr$(27) ' escape: quit game
                    Exit Do
                Case Chr$(32) ' space: drop stuntman
                    dropGuy
                Case Chr$(0) + "K", "4" ' left arrow: move chopper to the left
                    moveFlag = movLeft
                Case Chr$(0) + "M", "6" ' right arrow: move chopper to the right
                    moveFlag = movRight
                Case Chr$(0) + "H" ' up arrow: move chopper up
                    moveFlag = movUp
                Case Chr$(0) + "P" ' down arrow: move chopper down
                    moveFlag = movDown
                Case "7"
                    moveFlag = movUp Or movLeft
                Case "9"
                    moveFlag = movUp Or movRight
                Case "1"
                    moveFlag = movDown Or movLeft
                Case "3"
                    moveFlag = movDown Or movRight
            End Select
            If (joystick) Then
                joyCoords X!, Y!
                game.helico.VelX = game.helico.VelX + X! / 10
                game.helico.VelY = game.helico.VelY + Y! / 10
                If (game.helico.VelX < -helicoMaxVel) Then game.helico.VelX = -helicoMaxVel
                If (game.helico.VelX > helicoMaxVel) Then game.helico.VelX = helicoMaxVel
                If (game.helico.VelY < -helicoMaxVel) Then game.helico.VelY = -helicoMaxVel
                If (game.helico.VelY > helicoMaxVel) Then game.helico.VelY = helicoMaxVel
                If Strig(1) Then dropGuy
            End If
            If (moveFlag And movLeft) Then
                game.helico.VelX = game.helico.VelX - .3
                If (game.helico.VelX < -helicoMaxVel) Then game.helico.VelX = -helicoMaxVel
            ElseIf (moveFlag And movRight) Then
                game.helico.VelX = game.helico.VelX + .3
                If (game.helico.VelX > helicoMaxVel) Then game.helico.VelX = helicoMaxVel
            End If
            If (moveFlag And movUp) Then
                game.helico.VelY = game.helico.VelY - .3
                If (game.helico.VelY < -helicoMaxVel) Then game.helico.VelY = -helicoMaxVel
            ElseIf (moveFlag And movDown) Then
                game.helico.VelY = game.helico.VelY + .3
                If (game.helico.VelY > helicoMaxVel) Then game.helico.VelY = helicoMaxVel
            End If

            ''
            '' Game logic
            ''
            If (game.stat And statGameOver) Then
                game.restart = game.restart + 1
            End If

            If (game.restart) Then
                If (game.restart > 99) Then
                    If (game.stat And statFailed) Then
                        If (game.lives = 0) Then Exit Sub
                        game.lives = game.lives - 1
                        drawStatusBar barLives
                        stageRetry
                    Else
                        stageNext
                    End If
                End If
            Else
                If ((game.stat And statUFOCrash) = 0) Then
                    If (blade = 12) Then
                        Play "MB O1 d64"
                        blade = 0
                    Else
                        blade = blade + 1
                    End If
                End If
            End If

            If (Abs(game.helico.VelX) > .0001) Then
                If (joystick) Then
                    Select Case game.helico.VelX
                        Case Is < 0
                            game.helico.VelX = game.helico.VelX + .01
                        Case Is > 0
                            game.helico.VelX = game.helico.VelX - .01
                    End Select
                End If
                game.helico.X = game.helico.X + game.helico.VelX
                If (game.helico.X < 0) Then
                    game.helico.X = 0
                    game.helico.VelX = -game.helico.VelX / 2
                ElseIf (game.helico.X > 319) Then
                    game.helico.X = 319
                    game.helico.VelX = -game.helico.VelX / 2
                End If
            End If

            If (Abs(game.helico.VelY) > .0001) Then
                If (joystick) Then
                    Select Case game.helico.VelY
                        Case Is < 0
                            game.helico.VelY = game.helico.VelY + .01
                        Case Is > 0
                            game.helico.VelY = game.helico.VelY - .01
                    End Select
                End If
                game.helico.Y = game.helico.Y + game.helico.VelY
                If (game.helico.Y > 165) Then
                    game.helico.Y = 165
                    game.helico.VelY = -game.helico.VelY / 2
                ElseIf (game.helico.Y < 4) Then
                    game.helico.Y = 4
                    game.helico.VelY = -game.helico.VelY / 2
                End If
            End If


            ' saucer
            If (game.saucerHere = 0) Then ' there none on the screen
                If (game.saucerNext < 1) Then ' spawn one now
                    game.saucerHere = -1
                    game.saucer.VelX = stage / 3
                    game.saucer.Y = game.helico.Y
                    If game.helico.X < 160 Then
                        game.saucer.X = 319 - 17
                        game.saucer.VelX = -1
                    Else
                        game.saucer.X = 0
                        game.saucer.VelX = 1
                    End If
                Else
                    game.saucerNext = game.saucerNext - 1
                End If
            Else
                game.saucer.X = game.saucer.X + game.saucer.VelX
                ' saucer away
                If (game.saucer.X < 0) Or (game.saucer.X > 319 - 17) Then
                    game.saucerHere = 0
                    game.saucerNext = (7 - game.stage) * 100
                End If
            End If

            If (game.stat And statGameOver) = 0 Then
                goWagon = goWagon - 1
                If (goWagon < 1) Then
                    goWagon = 4 + (11 - game.stage) * 2
                    If (goWagon < 2) Then goWagon = 2
                    game.wagonX = game.wagonX + 1
                End If
            End If
            If (game.wagonX >= 255) Then
                game.wagonX = 255
                game.stat = game.stat Or statTooSlow
            End If

            If (game.stat And statDropGuy) Then
                ' landing
                If (game.guy.Y > 168) Then
                    ' landing on wagon
                    If (game.guy.X >= game.wagonX - 2) And (game.guy.X <= game.wagonX + 34) Then
                        If ((game.stat And statGuyLand) = 0) Then
                            Play "mb O2 d16d16d32 p64 f8 g16"
                            game.stat = game.stat Or statGuyLand
                            If (game.guyAngle = 0) Then tmpScore = tmpScore * 2
                            game.score = game.score + tmpScore
                            While game.score >= game.lifeUp
                                game.lives = game.lives + 1 ' add life
                                game.lifeUp = game.lifeUp + lifeUpStep ' next life in...
                            Wend
                        End If
                        ' crattering
                    Else
                        If ((game.stat And statGuyCrash) = 0) Then
                            Play "mb O1 d-32c32f64 O0g48c64"
                            game.stat = game.stat Or statGuyCrash
                            particleSpawn game.guy
                            game.pClr = 4
                        End If
                    End If
                    drawStatusBar barLives Or barScore
                    tmpScore = 0

                    ' in the air
                Else
                    game.guy.X = game.guy.X + game.guy.VelX ' update X coordinates (horizontal)
                    game.guy.Y = game.guy.Y + game.guy.VelY ' update Y coordinates (vertical)
                    If (game.guy.VelY < helicoMaxVel) Then
                        game.guy.VelY = game.guy.VelY + .01 ' increase Y velocity till cap
                    End If
                    game.guyAngle = (game.guyAngle + game.guySpin) Mod 360 ' spin
                    tmpScore = tmpScore + (Sqr((game.guy.VelX * game.guy.VelX) + (game.guy.VelY * game.guy.VelY)) * game.stage * 2) ' increase score
                End If
            Else
                game.guy.X = game.helico.X + 2
                game.guy.Y = game.helico.Y + 6
            End If

            ' check collision against UFO
            If (game.saucerHere) Then
                If ((game.stat And statUFOCrash) = 0) Then
                    If (game.helico.X + 13 >= game.saucer.X) Then
                        If (game.helico.Y + 7 >= game.saucer.Y) Then
                            If (game.helico.X - 4 <= game.saucer.X + 16) Then
                                If (game.helico.Y - 2 <= game.saucer.Y + 8) Then
                                    game.stat = game.stat Or statUFOCrash
                                    particleSpawn game.helico
                                    game.pClr = 8
                                    Play "mb o0 d40e32 o2 c64d64f64 o1 a32b64 o0 b16c8"
                                End If
                            End If
                        End If
                    End If
                End If
            End If

            ' particle effects
            If (game.stat And statParticles) Then
                For i% = LBound(particle) To UBound(particle)
                    particle(i%).X = particle(i%).X + particle(i%).VelX
                    particle(i%).Y = particle(i%).Y + particle(i%).VelY
                    particle(i%).VelY = particle(i%).VelY + .35
                Next i%
            End If

            gt.lag = gt.lag - tickSize
        Wend

        PCopy 2, 1 ' copy background to next frame

        ' draw wagon
        Put (game.wagonX, 168), horseAlf(), And
        Put (game.wagonX, 168), horseClr(), Or

        ' draw saucer
        If (game.saucerHere) Then
            Put (game.saucer.X, game.saucer.Y), saucerAlf(), And
            Put (game.saucer.X, game.saucer.Y), saucerClr(), Or
        End If

        ' draw guy
        If (((game.stat And statUFOCrash) = 0) Or ((game.stat And statDropGuy) <> 0)) And ((game.stat And statGuyCrash) = 0) Then
            pxlReloc game.guy.X, game.guy.Y
            Draw "C0 TA" + Str$(game.guyAngle) + guyGraph
        End If

        ' draw helicopter
        If ((game.stat And statUFOCrash) = 0) Then
            pxlReloc game.helico.X, game.helico.Y
            Draw "C0 TA0" + helicoGraph
            If frame Then Draw "TA180"
            frame = frame Xor 1
            pxlReloc game.helico.X + 1, game.helico.Y - 2
            Draw "C0 r7"
        End If

        ' draw particles
        If (game.stat And statParticles) Then
            For i% = LBound(particle) To UBound(particle)
                PSet (particle(i%).X, particle(i%).Y), game.pClr
            Next i%
        End If

        ' display next frame, to current
        PCopy 1, 0

        _Limit 60
    Loop
End Sub

''
'' Spawn particle above object location
''
Sub particleSpawn (item As moveStruct)
    For i% = LBound(particle) To UBound(particle)
        particle(i%).X = item.X
        particle(i%).Y = item.Y
        particle(i%).VelX = (Rnd * 3) - 1
        particle(i%).VelY = -(Rnd * 3 + 2)
    Next i%
    game.stat = game.stat Or statParticles
End Sub

''
'' The DRAW statement will skip drawing if MB coordinates are out of boundaries
''
Sub pxlReloc (X As Single, Y As Single)
    Dim cX As Integer, cY As Integer

    cX = Int(X): cY = Int(Y)
    PSet (cX, cY), Point(cX, cY)
End Sub

''
'' New game, start at level 1
''
Sub stageFirst
    game.stage = 0
    game.lives = 6
    game.score = 0
    game.lifeUp = lifeUpStep
    stageNext
End Sub

''
'' Try again prompt
''
Function stageGameOver%
    Dim msg As String, a As String

    Do: Loop While Len(InKey$)

    Screen , , 0, 0

    msg = "== SCORE:" + Str$(game.score) + " TRY AGAIN? =="
    Locate 25, 1: Print Space$(40);
    Locate 25, 20 - Len(msg) \ 2: Print msg;
    Do
        a = UCase$(InKey$)
        Select Case a
            Case "Y", "N"
                stageGameOver% = (a = "N")
                Exit Do
        End Select
    Loop

    Screen , , 1, 0
End Function

''
'' Setup next stage
''
Sub stageNext
    game.stage = game.stage + 1
    stageRetry
    drawScene
    drawStatusBar barAll
End Sub

''
'' Retry stage
''
Sub stageRetry
    game.stat = 0
    game.helico.X = 160
    game.helico.Y = 40
    game.helico.VelX = 0
    game.helico.VelY = 0
    game.guy.X = game.helico.X + 2
    game.guy.Y = game.helico.Y + 6
    game.guyAngle = 0
    game.restart = 0
    game.wagonX = 0
    game.saucerNext = (7 - game.stage) * 100
    If (game.saucerNext < 0) Then game.saucerNext = 100 ' 1st saucer takes longer to show up
    game.saucerHere = 0
End Sub

