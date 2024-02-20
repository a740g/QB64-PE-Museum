Option _Explicit ' Kens Artillery GUIb
Randomize Timer

'Ken:
'I've always wanted to make this game ever since I started programming in the 80's.
'This was made using the BASIC and compile language QB64 from QB64.org
'This was created by Ken G. with much help from others below.
'Thank you to B+ for posting much of this math code on the QB64.org forum!
'Also thank you to johnno56 for a little help on the explosions, from the QB64.org forum.
'It takes the computer a little time to learn how to hit your base.
'Created on June 25, 2019.

'Hi Ken, I made a couple of changes to the game. Do you recognize it :D  MOD 2019-07-01 B+
' 2019-07-03 fix items mentioned by Pete label Computer Power and Angle display,
'            apply constant wind change.
' 2022-05-04 fix again because color const dont work??? as _unsigned long
' 2022-08-01 Check in with latest GUI BI/BM
' 2022-08-13 Check in now with Sliders!
' 2022-12-16 updated slider variables

'$include:'GUIb.BI'

Xmax = 1280: Ymax = 720: GuiTitle$ = "Kens Artillery GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf"

'Dim Shared As Long lblAngle, tbAngle, lblPower, tbPower ' replace these with 2 sliders

Dim Shared As Long Pic, sldAngle, sldPower, btnFire, lblWind, lblScore
Pic = NewControl(5, 10, 23, 1260, 647, "", "b+ mod of Ken's Artillery with sliders")
sldAngle = NewControl(4, 10, 695, 280, 22, "(40-80) Angle = ", "") 'slider 0
con(sldAngle).SldLow = 40
con(sldAngle).sldHigh = 80
con(sldAngle).SldValue = 50
con(sldAngle).DecPts = -1
drwSld sldAngle, -1
sldPower = NewControl(4, 300, 695, 280, 22, "(50-100) Power = ", "") 'slider 0
con(sldPower).SldLow = 50
con(sldPower).sldHigh = 100
con(sldPower).SldValue = 70
con(sldPower).DecPts = -1
drwSld sldPower, -1

btnFire = NewControl(1, 590, 675, 100, 40, "Fire!", "")
con(btnFire).FontH = 30
drwBtn btnFire
lblWind = NewControl(6, 700, 690, 280, 30, "", "")
lblScore = NewControl(6, 990, 690, 280, 30, "", "")

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

Dim Shared As _Unsigned Long skyC, ballC, groundC, cannonC
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
System

Sub BtnClickEvent (i As Long)
    Select Case i
        Case btnFire
            p.cannonAngle = con(sldAngle).SldValue
            p.cannonAngle = 360 - p.cannonAngle
            p.cannonAngle = _D2R(p.cannonAngle)
            _Dest con(Pic).ImgHnd
            _PutImage , BG, con(Pic).ImgHnd
            drawCannon cannonC
            p.velocity = con(sldPower).SldValue ' 0 to 100 easier to gauge
            p.velocity = p.velocity / 10 ' between 0 and 10
            b.x = p.baseX + baseLength * Cos(p.cannonAngle)
            b.y = p.baseY + baseLength * Sin(p.cannonAngle)
            b.dx = p.velocity * Cos(p.cannonAngle)
            b.dy = p.velocity * Sin(p.cannonAngle)
            playBall
            If p.points = 5 Then _MessageBox "Winner!", "Is YOU!": initGame: Exit Sub
            turn = 1
            _Delay 1
            ComputerFire
            If c.points = 5 Then _MessageBox "Winner", "Is NOT you.": initGame
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
    _PutImage , BG, con(Pic).ImgHnd
    airX = rrnd(-20, 20)
    SetDisplayWind 'shift wind slightly, just do this here for now
    drwPic Pic
    drwSld sldAngle, -1
    drwSld sldPower, -1
    showScore
End Sub

Sub ComputerFire
    If Abs(airX - lastWind) > 2 Or c.cannonAngle <= _D2R(5 + 180) Then 'new cannon settings
        c.cannonAngle = _D2R(180 + 50 - airX / 7)
        c.velocity = 7.2 + airX / 20
        lastWind = airX
    End If
    _Dest con(Pic).ImgHnd
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
        _PutImage , BG, con(Pic).ImgHnd 'clear last
        _Dest con(Pic).ImgHnd
        drawCannon cannonC
        b.dx = b.dx + airX / 1000
        b.dy = b.dy + gravity
        b.x = b.x + b.dx
        b.y = b.y + b.dy
        fcirc b.x, b.y, 5, ballC 'draw new
        If b.y <> 0 And b.y < con(Pic).H - 60 Then Sound 6000 - 10 * b.y, .6
        If b.y >= 0 Then
            _Source BG 'oh! need this to read point(x, y) off bg !!!!!!!!!1
            If Point(b.x, b.y) <> skyC Then 'explosions
                For explosion = 0 To 14.5 Step 1
                    fcirc b.x, b.y, explosion, _RGB32(Rnd * 255, Rnd * 255, 0)
                    Sound 100 + explosion, .25
                    _Limit 600
                Next
                If Point(b.x, b.y) = c.baseC Then ' computer base hit
                    p.points = p.points + 1
                    showScore
                    Sound 500, 1: Sound 550, 1: Sound 600, 1: Sound 650, 1: Sound 700, 1
                    '_Delay .2
                ElseIf Point(b.x, b.y) = p.baseC Then ' player base hit
                    c.points = c.points + 1
                    showScore
                    Sound 700, 1: Sound 650, 1: Sound 600, 1: Sound 550, 1: Sound 500, 1
                    '_Delay .2
                End If
                fcirc b.x, b.y, 3 * ballRadius, skyC
                Exit While
            End If
        End If
        _Dest 0
        drwPic Pic
        showScore
        _Display ' yeah after I found out I needed it, try to find another, it's in MainRouter of BM
        _Limit 300
    Wend
    _Dest con(Pic).ImgHnd
    drawCannon skyC
    _PutImage , con(Pic).ImgHnd, BG ' bg with the holes added
    _Dest 0
    showScore
    drwPic Pic
End Sub

Sub showScore
    con(lblScore).Text = "Player: " + TS$(p.points) + "  Computer: " + TS$(c.points)
    drwLbl lblScore
    _Display
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

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
End Sub

Sub lblClickEvent (i)
    i = i
End Sub

'$include:'GUIb.BM'
