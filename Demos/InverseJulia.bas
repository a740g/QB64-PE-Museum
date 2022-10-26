DefSng A-Z

Dim Shared px, py, cx, cy

Screen _NewImage(1024, 768, 256)

Color 255
For i% = 0 To 255
    r% = Int((i% / 255) ^ .9323335 * 255)
    g% = Int((i% / 255) ^ 1.576838 * 255)
    b% = Int((i% / 255) ^ 3.484859 * 255)
    _PaletteColor i%, _RGB32(r%, g%, b%)
Next

'####################################################################################################################

setSeed _MouseX, _MouseY

Do
    If _MouseInput Then
        n% = 0
        _Display
        Cls
        setSeed _MouseX, _MouseY
    End If

    Do 'Marsaglia polar method for random gaussian
        u = Rnd * 2 - 1
        v = RND2 * 2 - 1
        s = u * u + v * v
    Loop While s >= 1 Or s = 0
    s = Sqr(-2 * Log(s) / s) * 0.5
    u = u * s * 2
    v = v * s * 2

    calcInverseJulia u, v, 1

    n% = n% + 1
    If n% = 300 Then
        n% = 0
        _Display
    End If
Loop

'####################################################################################################################

Sub setSeed (x, y)
    cx = (x / _Width - 0.5) * 4
    cy = (0.5 - y / _Height) * 3
End Sub

'####################################################################################################################

Sub calcInverseJulia (x, y, depth%)
    re = x - cx
    im = y - cy

    a = Sqr(re * re + im * im)
    x = Sqr((a + re) * 0.5)
    If im < 0 Then y = -Sqr((a - re) * 0.5) Else y = Sqr((a - re) * 0.5)

    PSET2 (x / 4 + 0.5) * _Width, (0.5 - y / 3) * _Height, 0.02
    PSET2 (x / -4 + 0.5) * _Width, (0.5 + y / 3) * _Height, 0.02
    If depth% < 32 Then
        If Rnd < 0.5 Then calcInverseJulia x, y, depth% + 1 Else calcInverseJulia -x, -y, depth% + 1
    End If
End Sub

'####################################################################################################################

Sub PSET2 (x, y, i)
    x% = Int(x)
    y% = Int(y)
    dx = x - x%
    dy = y - y%

    q3 = dx * dy
    q2 = (1 - dx) * dy
    q1 = dx * (1 - dy)
    q0 = (1 - dx) * (1 - dy)

    PSet (x%, y%), (1 - (1 - q0 * i) * (1 - Point(x%, y%) / 255)) * 255
    PSet (x% + 1, y%), (1 - (1 - q1 * i) * (1 - Point(x% + 1, y%) / 255)) * 255
    PSet (x%, y% + 1), (1 - (1 - q2 * i) * (1 - Point(x%, y% + 1) / 255)) * 255
    PSet (x% + 1, y% + 1), (1 - (1 - q3 * i) * (1 - Point(x% + 1, y% + 1) / 255)) * 255
End Sub

'####################################################################################################################

Function RND2 Static
    seed&& = (25214903917&& * seed&& + 11&&) Mod 281474976710656&&
    RND2 = seed&& / 281474976710656&&
End Function

