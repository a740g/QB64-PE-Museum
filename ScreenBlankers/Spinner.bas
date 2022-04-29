'+---------------+---------------------------------------------------+
'| ###### ###### |     .--. .         .-.                            |
'| ##  ## ##   # |     |   )|        (   ) o                         |
'| ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
'| ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
'| ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
'| ##     ##   # |                            ._.'                   |
'| ##     ###### |  Sources & Documents placed in the Public Domain. |
'+---------------+---------------------------------------------------+
'|                                                                   |
'| === Spinner.bas ===                                               |
'|                                                                   |
'| == This is a program originally posted by forum member bplus here |
'| == http://www.qb64.org/forum/index.php?topic=1431.0, I just made  |
'| == it compatible with the old QB64-SDL version and turned it into |
'| == screen blanker, hence ending itself after user activity.       |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

_ScreenMove -32000, -32000
_Delay 0.2

di& = _ScreenImage
pdi& = _ScreenImage
Dim Shared scrX%, scrY%
scrX% = _Width(di&)
scrY% = _Height(di&)
Screen di&
_Delay 0.2: _ScreenMove _Middle
_Delay 0.2: _FullScreen

Const MAX_SPINNERS = 100

Type Spinner
    x As Single
    y As Single
    dx As Single
    dy As Single
    sz As Single
    c As _Unsigned Long
End Type
Dim Shared Spinners(1 To MAX_SPINNERS) As Spinner

Randomize Timer
For i = 1 To MAX_SPINNERS
    newSpinner i
Next
i2 = 1: lc = 0

_MouseHide
While InKey$ = "" And mx% = 0 And my% = 0
    _PutImage , pdi&
    lc = lc + 1
    If lc Mod 100 = 99 Then
        lc = 0
        If i2 < MAX_SPINNERS Then i2 = i2 + 1
    End If
    For i = 1 To i2
        drawSpinner Spinners(i).x, Spinners(i).y, Spinners(i).sz, ARCTAN2(Spinners(i).dy, Spinners(i).dx), Spinners(i).c
        Spinners(i).x = Spinners(i).x + Spinners(i).dx: Spinners(i).y = Spinners(i).y + Spinners(i).dy
        If Spinners(i).x < -100 Or Spinners(i).x > scrX% + 100 Or Spinners(i).y < -100 Or Spinners(i).y > scrY% + 100 Then newSpinner i
    Next

    _Limit 20
    _Display
    Do While _MouseInput
        mx% = mx% + _MouseMovementX
        my% = my% + _MouseMovementY
    Loop
Wend

_FullScreen _Off
_Delay 0.2: Screen 0
_Delay 0.2: _FreeImage pdi&: _FreeImage di&
System

'======================================================================
Sub newSpinner (i As Integer) 'set Spinners dimensions start angles, color?
    Dim r
    Spinners(i).sz = Rnd * .25 + .5
    If Rnd < .5 Then r = -1 Else r = 1
    Spinners(i).dx = (Spinners(i).sz * Rnd * 8) * r * 2: Spinners(i).dy = (Spinners(i).sz * Rnd * 8) * r * 2
    r = Int(Rnd * 4)
    Select Case r
        Case 0: Spinners(i).x = Rnd * (scrX% - 120) + 60: Spinners(i).y = 0: If Spinners(i).dy < 0 Then Spinners(i).dy = -Spinners(i).dy
        Case 1: Spinners(i).x = Rnd * (scrX% - 120) + 60: Spinners(i).y = scrY%: If Spinners(i).dy > 0 Then Spinners(i).dy = -Spinners(i).dy
        Case 2: Spinners(i).x = 0: Spinners(i).y = Rnd * (scrY% - 120) + 60: If Spinners(i).dx < 0 Then Spinners(i).dx = -Spinners(i).dx
        Case 3: Spinners(i).x = scrX%: Spinners(i).y = Rnd * (scrY% - 120) + 60: If Spinners(i).dx > 0 Then Spinners(i).dx = -Spinners(i).dx
    End Select
    r = Rnd * 120
    Spinners(i).c = _RGB32(r, Rnd * .5 * r, Rnd * .25 * r)
End Sub

'======================================================================
Sub drawSpinner (x As Integer, y As Integer, scale As Single, heading As Single, c As _Unsigned Long)
    Dim x1, x2, x3, x4, y1, y2, y3, y4, r, a, a1, a2, lg, d, rd, red, blue, green
    Static switch As Integer
    switch = switch + 2
    switch = switch Mod 16 + 1
    red = _Red32(c): green = _Green32(c): blue = _Blue32(c)
    r = 10 * scale
    x1 = x + r * Cos(heading): y1 = y + r * Sin(heading)
    r = 2 * r 'lg lengths
    For lg = 1 To 8
        If lg < 5 Then
            a = heading + .9 * lg * MultPI(1 / 5) + (lg = switch) * MultPI(1 / 10)
        Else
            a = heading - .9 * (lg - 4) * MultPI(1 / 5) - (lg = switch) * MultPI(1 / 10)
        End If
        x2 = x1 + r * Cos(a): y2 = y1 + r * Sin(a)
        drawLink x1, y1, 3 * scale, x2, y2, 2 * scale, _RGB32(red + 20, green + 10, blue + 5)
        If lg = 1 Or lg = 2 Or lg = 7 Or lg = 8 Then d = -1 Else d = 1
        a1 = a + d * MultPI(1 / 12)
        x3 = x2 + r * 1.5 * Cos(a1): y3 = y2 + r * 1.5 * Sin(a1)
        drawLink x2, y2, 2 * scale, x3, y3, scale, _RGB32(red + 35, green + 17, blue + 8)
        rd = Int(Rnd * 8) + 1
        a2 = a1 + d * MultPI(1 / 8) * rd / 8
        x4 = x3 + r * 1.5 * Cos(a2): y4 = y3 + r * 1.5 * Sin(a2)
        drawLink x3, y3, scale, x4, y4, scale, _RGB32(red + 50, green + 25, blue + 12)
    Next
    r = r * .5
    fcirc x1, y1, r, _RGB32(red - 20, green - 10, blue - 5)
    x2 = x1 + (r + 1) * Cos(heading - MultPI(1 / 12)): y2 = y1 + (r + 1) * Sin(heading - MultPI(1 / 12))
    fcirc x2, y2, r * .2, &HFF000000
    x2 = x1 + (r + 1) * Cos(heading + MultPI(1 / 12)): y2 = y1 + (r + 1) * Sin(heading + MultPI(1 / 12))
    fcirc x2, y2, r * .2, &HFF000000
    r = r * 2
    x1 = x + r * .9 * Cos(heading + ConstPI): y1 = y + r * .9 * Sin(heading + ConstPI)
    TiltedEllipseFill 0, x1, y1, r, .7 * r, heading + ConstPI, _RGB32(red, green, blue)
End Sub

'======================================================================
Sub drawLink (x1, y1, r1, x2, y2, r2, c As _Unsigned Long)
    Dim a, a1, a2, x3, x4, x5, x6, y3, y4, y5, y6
    a = ARCTAN2(y2 - y1, x2 - x1)
    a1 = a + MultPI(1 / 2)
    a2 = a - MultPI(1 / 2)
    x3 = x1 + r1 * Cos(a1): y3 = y1 + r1 * Sin(a1)
    x4 = x1 + r1 * Cos(a2): y4 = y1 + r1 * Sin(a2)
    x5 = x2 + r2 * Cos(a1): y5 = y2 + r2 * Sin(a1)
    x6 = x2 + r2 * Cos(a2): y6 = y2 + r2 * Sin(a2)
    fquad x3, y3, x4, y4, x5, y5, x6, y6, c
    fcirc x1, y1, r1, c
    fcirc x2, y2, r2, c
End Sub

'======================================================================
'need 4 non linear points (not all on 1 line) list them clockwise so x2, y2 is opposite of x4, y4
Sub fquad (x1 As Integer, y1 As Integer, x2 As Integer, y2 As Integer, x3 As Integer, y3 As Integer, x4 As Integer, y4 As Integer, c As _Unsigned Long)
    ftri x1, y1, x2, y2, x4, y4, c
    ftri x3, y3, x4, y4, x1, y1, c
End Sub

'======================================================================
Sub ftri (x1, y1, x2, y2, x3, y3, K As _Unsigned Long)
    Dim a&
    a& = _NewImage(1, 1, 32)
    _Dest a&
    PSet (0, 0), K
    _Dest 0
    _MapTriangle _Seamless(0, 0)-(0, 0)-(0, 0), a& To(x1, y1)-(x2, y2)-(x3, y3)
    _FreeImage a& '<<< this is important!
End Sub

'======================================================================
Sub fcirc (CX As Integer, CY As Integer, R As Integer, C As _Unsigned Long)
    Dim Radius As Integer, RadiusError As Integer
    Dim X As Integer, Y As Integer
    Radius = Abs(R): RadiusError = -Radius: X = Radius: Y = 0
    If Radius = 0 Then PSet (CX, CY), C: Exit Sub
    Line (CX - X, CY)-(CX + X, CY), C, BF
    While X > Y
        RadiusError = RadiusError + Y * 2 + 1
        If RadiusError >= 0 Then
            If X <> Y + 1 Then
                Line (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                Line (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            End If
            X = X - 1
            RadiusError = RadiusError - X * 2
        End If
        Y = Y + 1
        Line (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        Line (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    Wend
End Sub

'======================================================================
Sub TiltedEllipseFill (destHandle&, x0, y0, a, b, ang, c As _Unsigned Long)
    Dim max As Integer, mx2 As Integer, i As Integer, j As Integer, k As Single, lasti As Single, lastj As Single
    Dim prc As _Unsigned Long, tef As Long
    prc = _RGBA32(255, 255, 255, 255)
    If a > b Then max = a + 1 Else max = b + 1
    mx2 = max + max
    tef = _NewImage(mx2, mx2)
    _Dest tef
    _Source tef 'point wont read without this!
    For k = 0 To 6.2832 + .05 Step .1
        i = max + a * Cos(k) * Cos(ang) + b * Sin(k) * Sin(ang)
        j = max + a * Cos(k) * Sin(ang) - b * Sin(k) * Cos(ang)
        If k <> 0 Then
            Line (lasti, lastj)-(i, j), prc
        Else
            PSet (i, j), prc
        End If
        lasti = i: lastj = j
    Next
    Dim xleft(mx2) As Integer, xright(mx2) As Integer, x As Integer, y As Integer
    For y = 0 To mx2
        x = 0
        While Point(x, y) <> prc And x < mx2
            x = x + 1
        Wend
        xleft(y) = x
        While Point(x, y) = prc And x < mx2
            x = x + 1
        Wend
        While Point(x, y) <> prc And x < mx2
            x = x + 1
        Wend
        If x = mx2 Then xright(y) = xleft(y) Else xright(y) = x
    Next
    _Dest destHandle&
    For y = 0 To mx2
        If xleft(y) <> mx2 Then Line (xleft(y) + x0 - max, y + y0 - max)-(xright(y) + x0 - max, y + y0 - max), c, BF
    Next
    _FreeImage tef
End Sub

'=== SDL replacement for _ATAN2 =======================================
Function ARCTAN2# (y#, x#)
    If y# = 0 Then
        If x# >= 0 Then r# = 0: Else r# = 3.141592653589793
    Else
        If x# = 0 Then r# = 1.570796326794896 * Sgn(y#): Else r# = 2 * Atn(y# / (Sqr((x# * x#) + (y# * y#)) + x#))
    End If
    ARCTAN2# = r#
End Function

'=== SDL replacement for _PI ==========================================
Function ConstPI#
    ConstPI# = 3.141592653589793
End Function

'=== SDL replacement for _PI(multiplier) ==============================
Function MultPI# (m#)
    MultPI# = 3.141592653589793 * m#
End Function

