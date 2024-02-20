_Title "So how do you like b's, move mouse wheel" 'B+ 2019-03-06
'2020-05-13 add smile
'2022-05-19 fix eye angles , smile when dist away
Const smile = 1 / 3 * _Pi
Screen 12
Dim Shared mw, dist

Color , 3
_MouseHide
While _KeyDown(27) = 0 'until esc keypress
    Cls
    drawFace
    While _MouseInput
        mw = mw + _MouseWheel
        If mw > 100 Then mw = 100
        If mw < 5 Then mw = 5
    Wend
    mx = _MouseX: my = _MouseY
    dist = _Hypot(mx - 320, my - 240)
    angle = _Atan2(my - 240, mx - 320)
    angle1 = _Atan2(my - 240, mx - (320 - 75))
    angle2 = _Atan2(my - 240, mx - (320 + 75))
    x1 = 320 - 75 + 37 / 2 * Cos(angle1)
    y1 = 240 + 37 / 2 * Sin(angle1)
    x2 = 320 + 75 + 37 / 2 * Cos(angle2)
    y2 = 240 + 37 / 2 * Sin(angle2)
    FillCircle x1, y1, 37 / 2, 0
    FillCircle x2, y2, 37 / 2, 0

    ' bee on top
    For i = 1 To 8
        If i Mod 2 Then bc = 0 Else bc = 14
        FillCircle mx + i * 3, my + i * 3, 5, bc
    Next
    FillCircle mx - 15 + 20, my + 10, 8, 7
    FillCircle mx + 8 + 20, my + 5, 8, 7

    _Display 'prevent flicker
    _Limit 60 'save CPU fan
Wend

Sub drawFace
    FillCircle 320, 240, 150, 14 '<<<<<<<<<<<<<<<<< works for qb color numbers as well as rgb
    FillCircle 320 - 75, 240, 37, 9
    FillCircle 320 + 75, 240, 37, 9
    'FillCircle 320, 240 + 80, 20, 12
    arc 320, 240, 110, _Pi / 2 - smile * (.5 * mw / 100 + .5 * dist / 360), _Pi / 2 + smile * (.5 * mw / 100 + .5 * dist / 360), 12
End Sub

'fill circle
Sub FillCircle (CX As Integer, CY As Integer, R As Integer, C As _Unsigned Long)
    Dim Radius As Integer, RadiusError As Integer
    Dim X As Integer, Y As Integer

    Radius = Abs(R)
    RadiusError = -Radius
    X = Radius
    Y = 0

    If Radius = 0 Then PSet (CX, CY), C: Exit Sub

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
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


'use radians
Sub arc (x, y, r, raStart, raStop, c As _Unsigned Long)
    Dim al, a
    'x, y origin, r = radius, c = color

    'raStart is first angle clockwise from due East = 0 degrees
    ' arc will start drawing there and clockwise until raStop angle reached

    If raStop < raStart Then
        arc x, y, r, raStart, _Pi(2), c
        arc x, y, r, 0, raStop, c
    Else
        ' modified to easier way suggested by Steve
        'Why was the line method not good? I forgot.
        al = _Pi * r * r * (raStop - raStart) / _Pi(2)
        For a = raStart To raStop Step 1 / al
            Circle (x + r * Cos(a), y + r * Sin(a)), 3, c '<<< modify for smile
        Next
    End If
End Sub

