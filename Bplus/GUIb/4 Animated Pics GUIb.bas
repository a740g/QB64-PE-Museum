Option _Explicit
'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 950: Ymax = 730: GuiTitle$ = "4 Animated Pics GUIb.bas"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' need to do this before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long pb1, pb2, pb3, pb4
pb1 = NewControl(5, 10, 28, 330, 330, "", "3 Ship formation")
pb2 = NewControl(5, 360, 28, 580, 330, "", "Alien Trees")
pb3 = NewControl(5, 10, 388, 330, 330, "", "Crop Circles")
pb4 = NewControl(5, 360, 388, 580, 330, "", "Target Practice")
' End GUI Controls

' 3 ship colors
Dim Shared As _Unsigned Long sc1, sc2, sc3 ' ship colors
sc1 = _RGB32(255, 255, 0)
sc2 = _RGB32(200, 0, 0) ' horiontal
sc3 = _RGB32(0, 0, 160) ' vertical

' Alien Trees
Type ship
    As Double x, y, dx, dy, sl, scale, tilt
End Type
Dim Shared As Long AT ' Alien Tree screen  container
AT = _NewImage(1024, 600, 32)
Dim Shared As Long bk ' background image
bk = _NewImage(1024, 600, 32) 'container for drawings
Dim Shared As Long seed(1 To 3), start, cN ' Randomize seeds for trees and plasma starters
Dim Shared As Single RD(1 To 3), GN(1 To 3), BL(1 To 3) ' plasma colors for trees
Dim Shared As Long leaf ' indexing ends of branches
Dim Shared As Long REF ' container to put the reflection inmage into
REF = _NewImage(1024, 120, 32) 'container for reflection image
Dim Shared ships(448) As ship ' ships are tree leaves
Dim Shared leaves(448) As Long ' ship images
Dim Shared D, DS, stall ' these control the ships approaching or leaving the trees, stall is a pause wo stopping frames
makeShips ' just do this once for images and travel rates
RestartAlienTrees ' get it started, restart by click pb2

' Crop Circles
Dim Shared As Long CCircle, CCircleBG, CClight, CNum ' container for Crops and lights tracking
CCircle = _NewImage(720, 720, 32) ' with ship to go into n1
CCircleBG = _NewImage(720, 720, 32) ' made with crop#
ReDim Shared As _Unsigned Long LowColr, HighColr
HighColr = _RGB32(240, 220, 80): LowColr = _RGB32(100, 50, 10)
crop0
_PutImage , CCircleBG, con(pb3).ImgHnd
drwPic pb3

' Target Practice
Dim Shared TargetImg, TargetShipLights, TargetX, TargetY, TargetR
Dim Shared As _Unsigned Long TargetC, TargetShipC
TargetShipC = &HFF999900
NewTarget
TargetImg = _NewImage(580, 340, 32)
_Dest TargetImg
Line (0, 0)-(con(pb4).W, con(pb4).H), Black, BF
drawShip 290, 170, TargetShipLights, TargetShipC
drawBall TargetX, TargetY, TargetR, TargetC
_Dest 0
_PutImage , TargetImg, con(pb4).ImgHnd
drwPic pb4

MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    i = i
End Sub

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub lblClickevent (i As Long)
    i = 1
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    Dim As Long r
    Select Case i
        Case pb2
            RestartAlienTrees
        Case pb3
            _PutImage , CCircleBG, CCircle
            _Dest CCircle
            PLC 720 * Pmx / con(pb3).W, 720 * Pmy / con(pb3).H, 360, 360, 300
            _PutImage , CCircle, con(pb3).ImgHnd
            drwPic pb3
            _Delay .8 '   time stands still when you blast with the PLC
            Randomize Timer
            If Rnd < .5 Then 'switch crops
                crop3
            Else
                CNum = (CNum + 1) Mod 4
                Select Case CNum
                    Case 0: crop0
                    Case 1: crop1
                    Case 2: crop2
                    Case 3: crop3
                End Select
            End If
            _PutImage , CCircleBG, con(pb3).ImgHnd
            drwPic pb3
        Case pb4
            _Dest TargetImg
            PLC 290, 170, Pmx, Pmy, TargetR
            _Dest 0
            _PutImage , TargetImg, con(pb4).ImgHnd
            drwPic pb4
            _Delay .4
            If _Hypot(Pmx - TargetX, Pmy - TargetY) < TargetR Then
                For r = 0 To 255
                    _Dest TargetImg
                    fcirc TargetX, TargetY, r, _RGBA32(255, 255 - r, 0, 10)
                    _PutImage , TargetImg, con(pb4).ImgHnd
                    _Dest 0
                    drwPic pb4
                    _Limit 400
                Next
                NewTarget
                _Dest TargetImg
                Line (0, 0)-(580, 340), Black, BF
                drawShip 290, 170, TargetShipLights, TargetShipC
                drawBall TargetX, TargetY, TargetR, TargetC
                _Dest 0
                _PutImage , TargetImg, con(pb4).ImgHnd
                drwPic pb4
            Else
                _Dest TargetImg
                Line (0, 0)-(580, 340), Black, BF
                drawShip 290, 170, TargetShipLights, TargetShipC
                drawBall TargetX, TargetY, TargetR, TargetC
                _Dest 0
                _PutImage , TargetImg, con(pb4).ImgHnd
                drwPic pb4
            End If
    End Select
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    Static ship3a, ship3x, ship3y, ship3l1, ship3l2, ship3l3
    Select Case i
        Case pb1
            _Dest con(pb1).ImgHnd
            Line (0, 0)-(360, 360), &H1899BB99, BF
            ship3a = ship3a + _Pi(1 / 120)
            ship3x = 170 + 60 * Cos(ship3a): ship3y = 170 + 60 * Sin(ship3a)
            drawShip ship3x, ship3y, ship3l1, sc1
            ship3x = 170 + 120 * Cos(ship3a + _Pi(2 / 3)): ship3y = 160 + 30 * Sin(ship3a + _Pi(2 / 3))
            drawShip ship3x, ship3y, ship3l2, sc2
            ship3x = 170 + 30 * Cos(ship3a + _Pi(4 / 3)): ship3y = 160 + 120 * Sin(ship3a + _Pi(4 / 3))
            drawShip ship3x, ship3y, ship3l3, sc3
            _Dest 0
            drwPic pb1
        Case pb2
            AlienTreesLoop
            drwPic pb2
        Case pb3
            _PutImage , CCircleBG, CCircle
            _Dest CCircle
            If MXfracW <> 0 And MYfracH <> 0 Then 'draw ship where mouse is
                drawShip MXfracW * 720, MYfracH * 720, CClight, LowColr
                CClight = CClight + 1
                If CClight = 6 Then CClight = 0
            End If
            _PutImage , CCircle, con(pb3).ImgHnd
            drwPic pb3
        Case pb4
            _Dest TargetImg
            drawShip 290, 170, TargetShipLights, TargetShipC
            drawBall TargetX, TargetY, TargetR, TargetC
            _Dest 0
            _PutImage , TargetImg, con(pb4).ImgHnd
            drwPic pb4

    End Select
End Sub

Sub RestartAlienTrees
    Dim i As Long

    makeBackground
    _Dest AT
    seed(1) = Rnd * 1000 ' get new trees setup  including the Plasma generators
    seed(2) = Rnd * 1000
    seed(3) = Rnd * 1000
    For i = 1 To 3
        RD(i) = Rnd * Rnd
        GN(i) = Rnd * Rnd
        BL(i) = Rnd * Rnd
    Next
    leaf = 0
    start = 0
    cN = start
    Randomize Using seed(1)
    branch 1024 * .6 + Rnd * .3 * 1024, 600 * .8 - 30, 6, 90, 1024 / 20, 0, 1, 1
    cN = start
    Randomize Using seed(2)
    branch Rnd * .3 * 1024, 600 * .8 - 15, 7, 90, 1024 / 18, 0, 2, 1
    cN = start
    Randomize Using seed(3)
    branch 1024 / 2, 600 * .8 - 8, 8, 90, 1024 / 16, 0, 3, 1
    _Dest 0
    start = 0: D = 1300: DS = 10 ' start the show! press spacebar to start a different setting
End Sub

Sub AlienTreesLoop
    Dim i As Long
    _Dest AT
    _PutImage , bk, AT
    start = start + 1
    cN = start
    Randomize Using seed(1)
    branch 1024 * .6 + Rnd * .3 * 1024, 600 * .8 - 30, 6, 90, 1024 / 20, 0, 1, 0
    cN = start
    Randomize Using seed(2)
    branch Rnd * .3 * 1024, 600 * .8 - 15, 7, 90, 1024 / 18, 0, 2, 0
    cN = start
    Randomize Using seed(3)
    branch 1024 / 2, 600 * .8 - 8, 8, 90, 1024 / 16, 0, 3, 0
    For i = 448 To 1 Step -1
        RotoZoom ships(i).x + D * ships(i).dx, ships(i).y + D * ships(i).dy, leaves(i), ships(i).scale, 0
    Next
    D = D + DS
    If D > 1300 Then DS = -3: D = 1300
    If D < 0 Then DS = 0: D = 0: stall = 300
    If DS = 0 And D = 0 Then stall = stall - 1
    If stall < 0 Then DS = 15: stall = 0
    _PutImage , AT, REF, (0, 0)-(1024, 480)
    _PutImage (0, 480)-(1024, 600), REF, AT, (0, 120)-(1024, 0) ' flip the source for reflection
    _PutImage , AT, con(pb2).ImgHnd
    _Dest 0
End Sub

Sub makeShips
    Dim i As Long, a As Double
    Dim As Long rl
    _Dest AT
    cN = 0
    RD(1) = Rnd
    GN(1) = Rnd
    BL(1) = Rnd
    For i = 0 To 448
        leaves(i) = _NewImage(61, 31, 32) ' ship is 60 x 30 drawn in top left hand corner
        ' need black backgrounf for ship
        Color , &HFF000000 '= balck background
        Cls
        rl = Int(Rnd * 5) + 1
        drawShip 30, 15, rl, changePlasma(1)
        _PutImage , AT, leaves(i), (0, 0)-(61, 31) ' <<<< upper left corner of screen!!!
        ' make the background black of ship transparent
        _ClearColor &HFF000000, leaves(i)
        a = _Pi(2) * Rnd
        ships(i).dx = Cos(a)
        ships(i).dy = Sin(a)
        ships(i).sl = rl
    Next
    _Dest 0
End Sub

Sub makeBackground
    Dim As Long i, stars, horizon

    _Dest bk
    For i = 0 To 600
        Line (0, i)-(1024, i), _RGB32(70, 60, i / 600 * 160)
    Next
    stars = 1024 * 600 * 10 ^ -4
    horizon = .67 * 600
    For i = 1 To stars 'stars in sky
        PSet (Rnd * 1024, Rnd * horizon), _RGB32(175 + Rnd * 80, 175 + Rnd * 80, 175 + Rnd * 80)
    Next
    stars = stars / 2
    For i = 1 To stars
        fcirc Rnd * 1024, Rnd * horizon, 1, _RGB32(175 + Rnd * 80, 175 + Rnd * 80, 175 + Rnd * 80)
    Next
    stars = stars / 2
    For i = 1 To stars
        fcirc Rnd * 1024, Rnd * horizon, 2, _RGB32(175 + Rnd * 80, 175 + Rnd * 80, 175 + Rnd * 80)
    Next
    DrawTerrain 405, 25, &HFF002255
    DrawTerrain 420, 15, &HFF224444
    DrawTerrain 435, 6, &HFF448855
    DrawTerrain 450, 5, &HFF88FF66
    _Dest 0
End Sub

Sub branch (x, y, startr, angD, lngth, lev, tree, leafTF)
    Dim x2, y2, dx, dy
    Dim As Long i, lev2
    x2 = x + Cos(_D2R(angD)) * lngth
    y2 = y - Sin(_D2R(angD)) * lngth
    dx = (x2 - x) / lngth
    dy = (y2 - y) / lngth
    For i = 0 To lngth
        fcirc x + dx * i, y + dy * i, startr, changePlasma~&(tree)
    Next
    If startr <= 0 Or lev > 11 Or lngth < 5 Then
        If leafTF Then
            'fcirc x + dx * i, y + dy * i, 5, &HFF008800
            leaf = leaf + 1
            ships(leaf).x = x + dx * i
            ships(leaf).y = y + dy * i
            ships(leaf).scale = .5 - (4 - tree) * .075
        End If
        Exit Sub
    Else
        lev2 = lev + 1
        branch x2, y2, startr - 1, angD + 10 + 30 * Rnd, .8 * lngth + .2 * Rnd * lngth, lev2, tree, leafTF
        branch x2, y2, startr - 1, angD - 10 - 30 * Rnd, .8 * lngth + .2 * Rnd * lngth, lev2, tree, leafTF
    End If
End Sub

Sub DrawTerrain (h, modN, c As _Unsigned Long) ' modN for ruggedness the higher the less smooth
    Dim x, dy
    For x = 0 To _Width
        If x Mod modN = 0 Then ' adjust mod number for ruggedness the higher the number the more jagged
            If h < 600 - modN And h > 50 + modN Then
                dy = Rnd * 20 - 10
            ElseIf h >= 600 - modN Then
                dy = Rnd * -10
            ElseIf h <= 50 + modN Then
                dy = Rnd * 10
            End If
        End If
        h = h + .1 * dy
        Line (x, _Height)-(x, h), c
    Next
End Sub

Function changePlasma~& (n)
    cN = cN - 1 'dim shared cN as _Integer64, pR as long, pG as long, pB as long
    changePlasma~& = _RGB32(127 + 127 * Sin(RD(n) * cN), 127 + 127 * Sin(GN(n) * cN), 127 + 127 * Sin(BL(n) * cN))
End Function

Sub drawShip (x, y, ls, colr As _Unsigned Long) 'shipType     collisions same as circle x, y radius = 30
    Dim light As Long, r As Long, g As Long, b As Long
    r = _Red32(colr): g = _Green32(colr): b = _Blue32(colr)
    fellipse x, y, 7, 17, _RGB32(r, g - 120, b - 100)
    fellipse x, y, 18, 13, _RGB32(r, g - 60, b - 50)
    fellipse x, y, 32, 7, _RGB32(r, g, b)
    For light = 0 To 5
        fcirc x - 32 + 11 * light + ls, y, 2, _RGB32(ls * 50, ls * 50, ls * 50)
    Next
    ls = ls + 1
    If ls > 5 Then ls = 0
End Sub

Sub PLC (baseX, baseY, targetX, targetY, targetR) ' PLC for PlasmaLaserCannon
    Dim r, g, b, hp, ta, dist, dr, x, y, c, rr, gg, bb, aa
    Randomize Timer
    r = Rnd ^ 2 * Rnd: g = Rnd ^ 2 * Rnd: b = Rnd ^ 2 * Rnd: hp = _Pi(.5) ' red, green, blue, half pi
    ta = _Atan2(targetY - baseY, targetX - baseX) ' angle of target to cannon base
    dist = _Hypot(targetY - baseY, targetX - baseX) ' distance cannon to target
    dr = targetR / dist
    For r = 0 To dist Step .25
        x = baseX + r * Cos(ta)
        y = baseY + r * Sin(ta)
        c = c + .3
        fcirc x, y, dr * r, _RGB32(128 + 127 * Sin(r * c), 128 + 127 * Sin(g * c), 128 + 127 * Sin(b * c))
    Next
    For rr = dr * r To 0 Step -2
        c = c + 1
        LowColr = _RGB32(128 + 127 * Sin(r * c), 128 + 127 * Sin(g * c), 128 + 127 * Sin(b * c))
        fcirc x, y, rr, LowColr
    Next
    cAnalysis LowColr, rr, gg, bb, aa
    HighColr = _RGB32(255 - rr, 255 - gg, 255 - bb)
End Sub

Sub crop0
    Dim n, stp, br, shft, i, x, y

    _Dest CCircleBG
    Line (0, 0)-(720, 720), HighColr, BF
    n = 12: stp = -40
    For br = 360 To 0 Step stp
        shft = shft + 720 / (n * n)
        For i = 1 To n
            x = 360 + br * Cos(_D2R(i * 360 / n + shft))
            y = 360 + br * Sin(_D2R(i * 360 / n + shft))
            drawc x, y
        Next
    Next
    _Dest 0
End Sub

'crop0 uses this
Sub drawc (mx, my)
    Dim cr, m, dx, dy, dr, x, y, r
    Dim As Long i
    Dim cc As _Unsigned Long

    cr = .5 * Sqr((360 - mx) ^ 2 + (360 - my) ^ 2): m = .5 * cr
    dx = (mx - 360) / m: dy = (my - 360) / m: dr = cr / m
    For i = m To 0 Step -1
        If i Mod 2 = 0 Then cc = HighColr Else cc = LowColr
        x = 360 + dx * (m - i): y = 360 + dy * (m - i): r = dr * i
        fcirc x, y, r, cc
    Next
End Sub

Sub crop1
    Dim ga, bn, br, r, lr, dr, hc, lc, cr, n, x, y

    _Dest CCircleBG
    Line (0, 0)-(720, 720), HighColr, BF
    ga = 137.5: bn = 800
    br = 9.5: lr = .5: r = br: dr = (br - lr) / bn
    hc = 180: lc = 120: cr = (hc - lc) / bn
    For n = 1 To bn
        x = 360 + 10 * Sqr(n) * Cos(_D2R(n * ga))
        y = 360 + 10 * Sqr(n) * Sin(_D2R(n * ga))
        r = r - dr
        fcirc x, y, r, LowColr
    Next
    _Dest 0
End Sub

Sub crop2
    Dim i, y, x

    _Dest CCircleBG
    'this needs big constrast of color
    HighColr = _RGB32(Rnd * 80, Rnd * 80, Rnd * 80) ' field
    LowColr = _RGB32(175 + Rnd * 80, 175 + Rnd * 80, 175 + Rnd * 80)
    Line (0, 0)-(720, 720), HighColr, BF
    For i = 45 To 720 Step 50
        Line (i, 0)-(i + 10, 720), LowColr, BF
        Line (0, i)-(720, i + 10), LowColr, BF
    Next
    For y = 50 To 650 Step 50
        For x = 50 To 720 Step 50
            fcirc x, y, 10, LowColr
        Next
    Next
    _Dest 0
End Sub

Sub crop3
    Dim r0, r1, r2, fc, st, xol, yol, mol, i, a0, a1, x1, y1, x2, y2

    _Dest CCircleBG
    Line (0, 0)-(720, 720), HighColr, BF
    r0 = .5 + Rnd * .8: r1 = .3 + Rnd * .4: r2 = .3 + Rnd * .4
    fc = 1 + Rnd * 20: st = .4 + Rnd * .4
    xol = 0: yol = 0: mol = 0
    For i = 0 To 120 Step st
        a0 = (i / r0) * (2 * _Pi)
        a1 = ((i / r1) * (2 * _Pi)) * -1
        x1 = 360 + (Sin(a0) * ((r0 - r1) * fc)) * 30
        y1 = 360 + (Cos(a0) * ((r0 - r1) * fc)) * 30
        x2 = x1 + (Sin(a1) * ((r2) * fc)) * 30
        y2 = y1 + (Cos(a1) * ((r2) * fc)) * 30
        If mol = 0 Then
            mol = 1: xol = x2: yol = y2
        Else
            thic xol, yol, x2, y2, 1, LowColr
            xol = x2: yol = y2
        End If
    Next
    _Dest 0
End Sub

Sub NewTarget
    If Rnd < .5 Then
        If Rnd < .5 Then TargetX = Rnd * 200 + 50 Else TargetX = 580 - 250 + Rnd * 200
        TargetY = Rnd * (340 - 100) + 50
    Else
        If Rnd < .5 Then TargetY = Rnd * 200 + 50 Else TargetY = 340 - 250 + Rnd * 100
        TargetX = Rnd * (580 - 100) + 50
    End If
    TargetR = Rnd * 50 + 20
    TargetC = _RGB32(60 + Rnd * 195, Rnd * 255, Rnd * 255)
End Sub

'$include:'GUIb.BM'

