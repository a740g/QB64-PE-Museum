Screen 12

xorig = 0
yorig = 0

Call cline(xorig, yorig, xorig + _Width, yorig, 8)
Call cline(xorig, yorig, xorig + -_Width, yorig, 8)
Call cline(xorig, yorig, xorig, yorig + _Height, 8)
Call cline(xorig, yorig, xorig, yorig - _Height, 8)

xzoom = 20
yzoom = 20

' Initialize line
b = -2
d = 2
lineang = .1
vx = Cos(lineang)
vy = Sin(lineang)
m = vy / vx

' Initialize ellipse
x0 = 2
y0 = -2
ellipsearg = .2
amag = 10
ax = amag * Cos(ellipsearg)
ay = amag * Sin(ellipsearg)
bmag = 5
bx = bmag * Cos(ellipsearg + 3.14 / 2)
by = bmag * Sin(ellipsearg + 3.14 / 2)

Do

    Do While _MouseInput
        x = _MouseX
        y = _MouseY
        If ((x > 0) And (x < _Width) And (y > 0) And (y < _Height)) Then
            If _MouseButton(1) Then
                x = _MouseX
                y = _MouseY
                x0 = (x - _Width / 2) / xzoom
                y0 = (-y + _Height / 2) / yzoom
            End If
            If _MouseButton(2) Then
                x = _MouseX
                y = _MouseY
                d = (x - _Width / 2) / xzoom
                b = (-y + _Height / 2) / yzoom
            End If
            If _MouseWheel > 0 Then
                lineang = lineang + .01
                vx = Cos(lineang)
                vy = Sin(lineang)
                m = vy / vx
            End If
            If _MouseWheel < 0 Then
                lineang = lineang - .01
                vx = Cos(lineang)
                vy = Sin(lineang)
                m = vy / vx
            End If
        End If
    Loop

    Select Case _KeyHit
        Case 18432
            bmag = bmag + .1
            bx = bmag * Cos(ellipsearg + 3.14 / 2)
            by = bmag * Sin(ellipsearg + 3.14 / 2)
        Case 20480
            bmag = bmag - .1
            bx = bmag * Cos(ellipsearg + 3.14 / 2)
            by = bmag * Sin(ellipsearg + 3.14 / 2)
        Case 19200
            ellipsearg = ellipsearg - .1
            ax = amag * Cos(ellipsearg)
            ay = amag * Sin(ellipsearg)
            bx = bmag * Cos(ellipsearg + 3.14 / 2)
            by = bmag * Sin(ellipsearg + 3.14 / 2)
        Case 19712
            ellipsearg = ellipsearg + .1
            ax = amag * Cos(ellipsearg)
            ay = amag * Sin(ellipsearg)
            bx = bmag * Cos(ellipsearg + 3.14 / 2)
            by = bmag * Sin(ellipsearg + 3.14 / 2)
    End Select

    ' Intersections
    a2 = ax ^ 2 + ay ^ 2
    b2 = bx ^ 2 + by ^ 2
    av = ax * vx + ay * vy
    bv = bx * vx + by * vy
    rbx = d - x0
    rby = b - y0
    adbr = ax * rbx + ay * rby
    bdbr = bx * rbx + by * rby
    aa = av ^ 2 / a2 ^ 2 + bv ^ 2 / b2 ^ 2
    bb = 2 * (av * adbr / a2 ^ 2 + bv * bdbr / b2 ^ 2)
    cc = adbr ^ 2 / a2 ^ 2 + bdbr ^ 2 / b2 ^ 2 - 1
    arg = bb ^ 2 - 4 * aa * cc
    If (arg > 0) Then
        alpha1 = (-bb + Sqr(arg)) / (2 * aa)
        alpha2 = (-bb - Sqr(arg)) / (2 * aa)
        x1 = alpha1 * vx + d
        x2 = alpha2 * vx + d
        y1 = alpha1 * vy + b
        y2 = alpha2 * vy + b
    Else
        x1 = -999
        y1 = -999
        x2 = -999
        y2 = -999
    End If

    GoSub draweverything

    _Limit 60
    _Display
Loop

End

draweverything:
Cls
Paint (1, 1), 15
Color 0, 15
Locate 1, 1: Print "LClick=Move ellipse, RClick=Move line, Scroll=Tilt line, Arrows=Shift ellipse"
For alpha = -20 To 20 Step .001
    x = alpha * vx + d
    y = alpha * vy + b
    Call ccircle(xorig + x * xzoom, yorig + y * yzoom, 1, 1)
Next
For t = 0 To 6.284 Step .001
    x = x0 + ax * Cos(t) + bx * Sin(t)
    y = y0 + ay * Cos(t) + by * Sin(t)
    Call ccircle(xorig + x * xzoom, yorig + y * yzoom, 1, 4)
Next
Call ccircle(xorig + x1 * xzoom, yorig + y1 * yzoom, 10, 1)
Call ccircle(xorig + x2 * xzoom, yorig + y2 * yzoom, 10, 1)
Return

Sub cline (x1, y1, x2, y2, col)
    Line (_Width / 2 + x1, -y1 + _Height / 2)-(_Width / 2 + x2, -y2 + _Height / 2), col
End Sub

Sub ccircle (x1, y1, r, col)
    Circle (_Width / 2 + x1, -y1 + _Height / 2), r, col
End Sub
