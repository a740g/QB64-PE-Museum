'$include:'vs GUI.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 1280: Ymax = 700: GuiTitle$ = "GUI Form Designer"
OpenWindow Xmax, Ymax, GuiTitle$, "ARLRDBD.TTF" ' need to do this before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long lblAngle, tbAngle, lblPower, tbPower, btnFire, lblPlayerS, lblComputerS, lblC, lblWind, lblScorePlayer, Pic
lblAngle = NewControl(4, 10, 660, 100, 30, 30, 0, 0, "Angle:")
tbAngle = NewControl(2, 110, 660, 80, 30, 28, 0, 0, "45")
lblPower = NewControl(4, 200, 660, 120, 30, 30, 0, 0, "Power:")
tbPower = NewControl(2, 320, 660, 80, 30, 28, 0, 0, "75")
btnFire = NewControl(1, 410, 660, 100, 30, 28, 0, 0, "Fire!")
lblPlayerS = NewControl(4, 1010, 660, 40, 30, 30, 0, 0, "0")
lblComputerS = NewControl(4, 1220, 660, 50, 30, 30, 0, 0, "0")
lblC = NewControl(4, 1050, 660, 170, 30, 30, 0, 0, "Computer:")
lblWind = NewControl(4, 520, 660, 270, 30, 30, 0, 0, "<<< Wind at: 15")
lblScorePlayer = NewControl(4, 800, 660, 210, 30, 30, 0, 0, "Score  Player:")
Pic = NewControl(5, 10, 0, 1260, 650, 16, 0, 0, "Ken's Artillery b+ mod")
' End GUI Controls

' Now for the app declares!
_Title "Test bas file" '  without GUI controls label  pick a bas file with some code to make GUI
' lets try an actual application! b+ 2022-06-25
Option _Explicit

'Ken:
'I've always wanted to make this game ever since I started programming in the 80's.
'This was made using the BASIC and compile language QB64 from QB64.org
'This was created by Ken G. with much help from others below.
'Thank you to B+ for posting much of this math code on the QB64.org forum!
'Also thank you to johnno56 for a little help on the explosions, from the QB64.org forum.
'It takes the computer a little time to learn how to hit your base.
'Created on June 25, 2019.

'Hi Ken, I made a couple of changes to the game. Do you recognize it :D  MOD 2019-07-01 B+
' 2019-07-03 fix items mentioned by Pete label Computer Power and Angle display, apply constant wind change.
'2022-05-04 fix again because color const dont work??? as _unsigned long

Randomize Timer

Type ball
    x As Single
    y As Single
    dx As Single
    dy As Single
End Type

Type Contestent
    baseX As Integer 'butt end of cannon
    baseY As Integer
    baseC As _Unsigned Long
    cannonAngle As Single
    velocity As Single
    points As Integer
End Type

Const groundY = 640
Const gravity = .05
Const cannonLength = 100
Const baseLength = 100
Const baseHeight = 30
Const ballRadius = 5

Dim Shared As _Unsigned Long skyC, ballC, groundC, cannonC '  fix color const for v 2.0, maybe 1.5 broken too
skyC = &HFF9988FF~&
ballC = &HFF000000~&
groundC = &HFF405020~&
cannonC = &HFF884422~&

Dim Shared BG As Long, c As Contestent, p As Contestent, b As ball, airX, turn, lastWind

' one time only
BG = _NewImage(con(Pic).W, con(Pic).H, 32) 'get bg snap shot area ready
setPlayerConstants
initGame
MainRouter ' just wait for player to fire

Sub BtnClickEvent (i As Long)
    Select Case i
        Case btnFire
            p.cannonAngle = Val(con(tbAngle).Text)
            p.cannonAngle = 360 - p.cannonAngle
            p.cannonAngle = _D2R(p.cannonAngle)
            _Dest con(Pic).N1
            _PutImage , BG, con(Pic).N1
            drawCannon cannonC
            p.velocity = Val(con(tbPower).Text)
            p.velocity = p.velocity / 10 ' between 0 and 10
            b.x = p.baseX + baseLength * Cos(p.cannonAngle)
            b.y = p.baseY + baseLength * Sin(p.cannonAngle)
            b.dx = p.velocity * Cos(p.cannonAngle)
            b.dy = p.velocity * Sin(p.cannonAngle)
            playBall
            turn = 1
            _Delay 1
            ComputerFire
    End Select
End Sub

Sub LstSelectEvent (control As Long)
    Select Case control
    End Select
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    Select Case i
    End Select
End Sub

Sub PicFrameUpdate (i As Long)
    Select Case i
    End Select
End Sub

' game routines

Sub setPlayerConstants
    p.baseX = 10: c.baseX = con(Pic).W - 10
    p.baseY = groundY - baseHeight: c.baseY = groundY - baseHeight
    p.baseC = &HFF880000~&: c.baseC = &HFF000088~&
    p.cannonAngle = _D2R(360 - 45)
    p.velocity = 7
End Sub

Sub initGame 'sets or resets
    p.points = 0: c.points = 0: turn = 1 ' player has to start things off for now
    MakeBG con(Pic).W / 2, rrnd(200, (con(Pic).W - 220) / 2.3), con(Pic).H
    _PutImage , BG, con(Pic).N1
    airX = rrnd(-20, 20)
    SetDisplayWind 'shift wind slightly, just do this here for now
    drwPic Pic, 0
    showScore
End Sub

Sub ComputerFire
    If Abs(airX - lastWind) > 2 Or c.cannonAngle <= _D2R(5 + 180) Then 'new cannon settings
        c.cannonAngle = _D2R(180 + 50 - airX / 7)
        c.velocity = 7.2 + airX / 20
        lastWind = airX
    End If
    _Dest con(Pic).N1
    drawCannon cannonC

    b.x = c.baseX + baseLength * Cos(c.cannonAngle)
    b.y = c.baseY + baseLength * Sin(c.cannonAngle)
    b.dx = c.velocity * Cos(c.cannonAngle)
    b.dy = c.velocity * Sin(c.cannonAngle)
    playBall ' moved up above next calcs   oh much better!
    If b.x - (p.baseX + .5 * baseLength) > 0 Then
        c.velocity = c.velocity + (b.x - p.baseX + .5 * baseLength) / 1000
    Else
        c.velocity = c.velocity - ((groundY - b.y) + (p.baseX + .5 * baseLength - b.x)) / 1000
    End If
    ' playBall
    turn = 0
End Sub

Sub drawCannon (K As _Unsigned Long)
    If turn = 0 Then 'players
        Line (p.baseX, p.baseY)-Step(baseLength * Cos(p.cannonAngle), baseLength * Sin(p.cannonAngle)), K
    Else
        Line (c.baseX, c.baseY)-Step(baseLength * Cos(c.cannonAngle), baseLength * Sin(c.cannonAngle)), K
    End If
End Sub

Sub playBall
    Dim explosion
    While _KeyHit <> 27
        _PutImage , BG, con(Pic).N1 'clear last
        _Dest con(Pic).N1
        drawCannon cannonC
        b.dx = b.dx + airX / 1000
        b.dy = b.dy + gravity
        b.x = b.x + b.dx
        b.y = b.y + b.dy
        fcirc b.x, b.y, 5, ballC 'draw new
        If b.y >= 0 Then
            _Source BG 'oh! need this to read point(x, y) off bg !!!!!!!!!1
            If Point(b.x, b.y) <> skyC Then 'explosions
                For explosion = 0 To 14.5 Step .25
                    fcirc b.x, b.y, explosion, _RGB32(Rnd * 255, Rnd * 255, 0)
                    Sound 100 + explosion, .25
                    '_Delay .01
                Next
                If Point(b.x, b.y) = c.baseC Then ' computer base hit
                    p.points = p.points + 1
                    con(lblPlayerS).Text = TS$(p.points)

                    Sound 500, 1: Sound 550, 1: Sound 600, 1: Sound 650, 1: Sound 700, 1
                    '_Delay .2
                ElseIf Point(b.x, b.y) = p.baseC Then ' player base hit
                    c.points = c.points + 1
                    con(lblComputerS).Text = TS$(p.points)

                    Sound 700, 1: Sound 650, 1: Sound 600, 1: Sound 550, 1: Sound 500, 1
                    '_Delay .2
                End If
                fcirc b.x, b.y, 3 * ballRadius, skyC
                Exit While
            End If
        End If
        _Dest 0
        drwPic Pic, -1
        showScore
        _Display ' yeah after I found out I needed it, try to find another, it's in MainRouter of BM
        _Limit 300
    Wend
    _Dest con(Pic).N1
    drawCannon skyC
    _PutImage , con(Pic).N1, BG ' bg with the holes added
    _Dest 0
    drwPic Pic, 0
End Sub

Sub showScore
    con(lblPlayerS).Text = TS$(p.points)
    drwLbl lblPlayerS
    con(lblComputerS).Text = TS$(c.points)
    drwLbl lblComputerS
    If p.points = 5 Then mBox "Winner!", "Is YOU!": initGame
    If c.points = 5 Then mBox "Winner", "Is NOT you.": initGame
End Sub

Sub SetDisplayWind ' drw in con(pic).N1 drwPic
    airX = Int(airX + rrnd(-1.5, 1.5)) ' change air gradually
    If airX < -20 Then airX = -19.99
    If airX > 20 Then airX = 19.99
    If airX < 0 Then con(lblWind).Text = "<<< Wind at: " + TS$(airX)
    If airX > 0 Then con(lblWind).Text = "Wind at: " + TS$(airX) + " >>>"
    drwLbl lblWind
End Sub

Sub MakeBG (xcenter, maxHeight, mountainbaseY)
    Dim centerDist, i, xc, yc, xl, xr, dir, sd&
    sd& = _Dest
    _Dest BG
    Line (0, 0)-(con(Pic).W, con(Pic).H), skyC, BF ' clear old
    centerDist = 15 * Rnd + 15
    For i = 1 To 5
        If Rnd < .5 Then dir = -1 Else dir = 1
        xc = xcenter + dir * centerDist: yc = maxHeight - centerDist - Rnd * 25
        xl = xc - rrnd(1.15 * yc, yc): xr = xc + rrnd(1.15 * yc, yc)
        If mountainbaseY - yc < mountainbaseY Then
            ftri xl, mountainbaseY, xc, mountainbaseY - yc, xr, mountainbaseY, _RGB32(110 - i * 4, Rnd * 20 + 100 - i * 2, 100 - i * 8)
        Else
            Exit For
        End If
        centerDist = centerDist + 40 * Rnd + 30
    Next
    Line (0, groundY)-(con(Pic).W, con(Pic).H), groundC, BF 'ground
    Line (p.baseX, p.baseY)-Step(baseLength, baseHeight), p.baseC, BF 'bases
    Line (c.baseX, c.baseY)-Step(-baseLength, baseHeight), c.baseC, BF
    _Dest sd&
End Sub

Function rrnd (n1, n2) 'return real number between n1, n2
    rrnd = (n2 - n1) * Rnd + n1
End Function

'$include:'vs GUI.BM'
