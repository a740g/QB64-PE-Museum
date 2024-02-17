Screen 12

C1x = -100
C1y = 50
C2x = 100
C2y = 100
r1 = 150
r2 = 100

Do
    Do While _MouseInput
        If _MouseButton(1) Then
            C2x = _MouseX - 320
            C2y = 240 - _MouseY
        End If
        If _MouseButton(2) Then
            C1x = _MouseX - 320
            C1y = 240 - _MouseY
        End If
    Loop

    Cls
    Circle (320 + C1x, C1y * -1 + 240), r1, 8
    Circle (320 + C2x, C2y * -1 + 240), r2, 7

    ''' Toggle between the two functions here.
    Call IntersectTwoCircles(C1x, C1y, r1, C2x, C2y, r2, i1x, i1y, i2x, i2y)
    'CALL intersect2circs(C1x, C1y, r1, C2x, C2y, r2, i1x, i1y, i2x, i2y)
    '''
    Locate 1, 1: Print i1x, i1y, i2x, i2y

    If (i1x Or i1y Or i2x Or i2y) Then
        Circle (320 + i1x, i1y * -1 + 240), 3, 14
        Circle (320 + i2x, i2y * -1 + 240), 3, 15
    End If

    _Display
    _Limit 30
Loop

Sub IntersectTwoCircles (c1x, c1y, r1, c2x, c2y, r2, i1x, i1y, i2x, i2y)
    i1x = 0: i1y = 0: i2x = 0: i2y = 0
    Dx = c1x - c2x
    Dy = c1y - c2y
    D2 = Dx ^ 2 + Dy ^ 2
    If (D2 ^ .5 < (r1 + r2)) Then
        F = (-D2 + r2 ^ 2 - r1 ^ 2) / (2 * r1)
        a = Dx / F
        b = Dy / F
        g = a ^ 2 + b ^ 2
        If (g > 1) Then
            h = Sqr(g - 1)
            i1x = c1x + r1 * (a + b * h) / g
            i1y = c1y + r1 * (b - a * h) / g
            i2x = c1x + r1 * (a - b * h) / g
            i2y = c1y + r1 * (b + a * h) / g
        End If
    End If
End Sub

Sub intersect2circs (c1x, c1y, r1, c2x, c2y, r2, i1x, i1y, i2x, i2y)
    d = ((c1x - c2x) ^ 2 + (c1y - c2y) ^ 2) ^ .5
    alpha = _Acos((r1 ^ 2 + d ^ 2 - r2 ^ 2) / (2 * r1 * d))
    x1 = r1 * Cos(alpha)
    l = r1 * Sin(alpha)
    angle = _Atan2(c2y - c1y, c2x - c1x)
    p3x = c1x + x1 * Cos(angle)
    p3y = c1y + x1 * Sin(angle)
    i1x = p3x + l * Cos(angle - _Pi / 2)
    i1y = p3y + l * Sin(angle - _Pi / 2)
    i2x = p3x + l * Cos(angle + _Pi / 2)
    i2y = p3y + l * Sin(angle + _Pi / 2)
End Sub


