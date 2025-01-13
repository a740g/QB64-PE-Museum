' 2023 Haggarman
' 2/28/2023 Version 6
Option _Explicit
_Title "Near Frustum Clip Triangle Attributes - press ESC to exit."
Screen _NewImage(1024, 720, 32)

Dim cx As Single, cy As Single, scale As Single
cx = _Width / 2
cy = _Height / 2
scale = 10.0

Type vec3d
    x As Single
    y As Single
    z As Single
End Type

Type triangle
    x0 As Single
    y0 As Single
    z0 As Single
    x1 As Single
    y1 As Single
    z1 As Single
    x2 As Single
    y2 As Single
    z2 As Single

    u0 As Single
    v0 As Single
    u1 As Single
    v1 As Single
    u2 As Single
    v2 As Single
    texture As _Unsigned Long
    options As _Unsigned Long
End Type

Type vertex8
    x As Single
    y As Single
    w As Single
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
End Type

Type vertex_attribute5
    u As Single
    v As Single
    r As Single
    g As Single
    b As Single
End Type

' Projection Matrix
Dim Shared Frustum_Near As Single ' The star of the show here. Where the triangle is being clipped to.
Dim Frustum_Far As Single
Dim Frustum_FOV_deg As Single
Dim Frustum_Aspect_Ratio As Single
Dim Frustum_FOV_ratio As Single

Frustum_Near = 0.5
Frustum_Far = 1000.0
Frustum_FOV_deg = 60.0
Frustum_Aspect_Ratio = _Height / _Width
Frustum_FOV_ratio = 1.0 / Tan(_D2R(Frustum_FOV_deg * 0.5))

' 3 points of the input triangle
Dim p0 As vec3d
Dim p1 As vec3d
Dim p2 As vec3d
p0.x = 0: p0.y = -10: p0.z = 10
p1.x = 0: p1.y = 25: p1.z = 10
p2.x = 0: p2.y = 0: p2.z = -32

' View Space quadrangle
Dim Shared numTriangles As Integer
Dim Shared pointView0 As vec3d
Dim Shared pointView1 As vec3d
Dim Shared pointView2 As vec3d
Dim Shared pointView3 As vec3d
Dim Shared vattb0 As vertex_attribute5
Dim Shared vattb1 As vertex_attribute5
Dim Shared vattb2 As vertex_attribute5
Dim Shared vattb3 As vertex_attribute5

' Graphing colorization and animation
Dim grid_color As _Unsigned Long: grid_color = _RGB32(28, 28, 28)
Dim rgbBefore As _Unsigned Long: rgbBefore = _RGB32(83, 94, 105)
Dim rgbAfter1 As _Unsigned Long: rgbAfter1 = _RGB32(211, 216, 155)
Dim rgbAfter2 As _Unsigned Long: rgbAfter2 = _RGB32(144, 200, 216)
Dim animateDash As _Unsigned Integer
Dim animateDash1 As _Unsigned Integer, carryDash1 As _Unsigned Integer
Dim animateDash2 As _Unsigned Integer, carryDash2 As _Unsigned Integer

main:
' Loop dependent vars
Dim spinAngleDegX As Single
spinAngleDegX = 120

Do
    pointView0.x = p0.x
    pointView0.y = p0.y * Cos(_D2R(spinAngleDegX)) - p0.z * Sin(_D2R(spinAngleDegX))
    pointView0.z = p0.y * Sin(_D2R(spinAngleDegX)) + p0.z * Cos(_D2R(spinAngleDegX))

    pointView1.x = p1.x
    pointView1.y = p1.y * Cos(_D2R(spinAngleDegX)) - p1.z * Sin(_D2R(spinAngleDegX))
    pointView1.z = p1.y * Sin(_D2R(spinAngleDegX)) + p1.z * Cos(_D2R(spinAngleDegX))

    pointView2.x = p2.x
    pointView2.y = p2.y * Cos(_D2R(spinAngleDegX)) - p2.z * Sin(_D2R(spinAngleDegX))
    pointView2.z = p2.y * Sin(_D2R(spinAngleDegX)) + p2.z * Cos(_D2R(spinAngleDegX))

    Cls
    Line (cx + scale * Frustum_Near, 0)-(cx + scale * Frustum_Near, _Height), grid_color

    Line (cx + scale * pointView0.z, cy + scale * pointView0.y)-(cx + scale * pointView1.z, cy + scale * pointView1.y), _RGB32(227, 67, 67), , animateDash
    Line (cx + scale * pointView1.z, cy + scale * pointView1.y)-(cx + scale * pointView2.z, cy + scale * pointView2.y), _RGB32(67, 227, 67), , animateDash
    Line (cx + scale * pointView2.z, cy + scale * pointView2.y)-(cx + scale * pointView0.z, cy + scale * pointView0.y), _RGB32(167, 167, 227), , animateDash

    NearClip pointView0, pointView1, pointView2, pointView3, vattb0, vattb1, vattb2, vattb3, numTriangles

    Print "n ="; numTriangles

    If numTriangles >= 1 Then
        ' Triangle A B C A
        Line (cx + scale * pointView0.z, cy + scale * pointView0.y)-(cx + scale * pointView1.z, cy + scale * pointView1.y), rgbAfter1, , animateDash1
        Line (cx + scale * pointView1.z, cy + scale * pointView1.y)-(cx + scale * pointView2.z, cy + scale * pointView2.y), rgbAfter1, , animateDash1
        Line (cx + scale * pointView2.z, cy + scale * pointView2.y)-(cx + scale * pointView0.z, cy + scale * pointView0.y), rgbAfter1, , animateDash1
    End If

    If numTriangles >= 2 Then
        ' Triangle A C D A
        Line (cx + scale * pointView0.z, cy + scale * pointView0.y)-(cx + scale * pointView2.z, cy + scale * pointView2.y), rgbAfter2, , animateDash2
        Line (cx + scale * pointView2.z, cy + scale * pointView2.y)-(cx + scale * pointView3.z, cy + scale * pointView3.y), rgbAfter2, , animateDash2
        Line (cx + scale * pointView3.z, cy + scale * pointView3.y)-(cx + scale * pointView0.z, cy + scale * pointView0.y), rgbAfter2, , animateDash2
    End If

    _Limit 20
    _Display

    animateDash = _ShR(animateDash, 1)
    If animateDash = 0 Then
        spinAngleDegX = spinAngleDegX + 5
        animateDash = &H8000
        animateDash1 = &H0FE0
        animateDash2 = &H008F
    Else
        carryDash1 = animateDash1 And 1
        animateDash1 = _ShR(animateDash1, 1) Or _ShL(carryDash1, 15)

        carryDash2 = animateDash2 And 1
        animateDash2 = _ShR(animateDash2, 1) Or _ShL(carryDash2, 15)
    End If
Loop Until InKey$ = Chr$(27)

End


Sub vec3dprint (p As vec3d)
    Print Using "(+##.##, +##.##, +##.##)  "; p.x; p.y; p.z;

End Sub

Sub NearClip (A As vec3d, B As vec3d, C As vec3d, D As vec3d, TA As vertex_attribute5, TB As vertex_attribute5, TC As vertex_attribute5, TD As vertex_attribute5, result As Integer)
    ' result:
    ' 0 = do not draw
    ' 1 = only draw ABCA
    ' 2 = draw both ABCA and ACDA

    Static d_A_near_z As Single
    Static d_B_near_z As Single
    Static d_C_near_z As Single
    Static clip_score As _Unsigned Integer
    Static ratio1 As Single
    Static ratio2 As Single

    d_A_near_z = A.z - Frustum_Near
    d_B_near_z = B.z - Frustum_Near
    d_C_near_z = C.z - Frustum_Near

    clip_score = 0
    If d_A_near_z < 0.0 Then clip_score = clip_score Or 1
    If d_B_near_z < 0.0 Then clip_score = clip_score Or 2
    If d_C_near_z < 0.0 Then clip_score = clip_score Or 4

    Print "Case:"; clip_score

    Select Case clip_score
        Case &B000
            Print "no clip"
            result = 1


        Case &B001
            Print "A is out"
            result = 2

            ' C to new D (using C to A)
            ratio1 = d_C_near_z / (C.z - A.z)
            D.x = (A.x - C.x) * ratio1 + C.x
            D.y = (A.y - C.y) * ratio1 + C.y
            D.z = Frustum_Near
            TD.u = (TA.u - TC.u) * ratio1 + TC.u
            TD.v = (TA.v - TC.v) * ratio1 + TC.v
            TD.r = (TA.r - TC.r) * ratio1 + TC.r
            TD.g = (TA.g - TC.g) * ratio1 + TC.g
            TD.b = (TA.b - TC.b) * ratio1 + TC.b

            ' new A to B, going backward from B
            ratio2 = d_B_near_z / (B.z - A.z)
            A.x = (A.x - B.x) * ratio2 + B.x
            A.y = (A.y - B.y) * ratio2 + B.y
            A.z = Frustum_Near
            TA.u = (TA.u - TB.u) * ratio2 + TB.u
            TA.v = (TA.v - TB.v) * ratio2 + TB.v
            TA.r = (TA.r - TB.r) * ratio2 + TB.r
            TA.g = (TA.g - TB.g) * ratio2 + TB.g
            TA.b = (TA.b - TB.b) * ratio2 + TB.b


        Case &B010
            Print "B is out"
            result = 2

            ' the oddball case
            D = C
            TD = TC

            ' old B to new C, going backward from C to B
            ratio1 = d_C_near_z / (C.z - B.z)
            C.x = (B.x - C.x) * ratio1 + C.x
            C.y = (B.y - C.y) * ratio1 + C.y
            C.z = Frustum_Near
            TC.u = (TB.u - TC.u) * ratio1 + TC.u
            TC.v = (TB.v - TC.v) * ratio1 + TC.v
            TC.r = (TB.r - TC.r) * ratio1 + TC.r
            TC.g = (TB.g - TC.g) * ratio1 + TC.g
            TC.b = (TB.b - TC.b) * ratio1 + TC.b

            ' A to new B, going forward from A
            ratio2 = d_A_near_z / (A.z - B.z)
            B.x = (B.x - A.x) * ratio2 + A.x
            B.y = (B.y - A.y) * ratio2 + A.y
            B.z = Frustum_Near
            TB.u = (TB.u - TA.u) * ratio2 + TA.u
            TB.v = (TB.v - TA.v) * ratio2 + TA.v
            TB.r = (TB.r - TA.r) * ratio2 + TA.r
            TB.g = (TB.g - TA.g) * ratio2 + TA.g
            TB.b = (TB.b - TA.b) * ratio2 + TA.b


        Case &B011
            Print "C is in"
            result = 1

            ' new B to C
            ratio1 = d_C_near_z / (C.z - B.z)
            B.x = (B.x - C.x) * ratio1 + C.x
            B.y = (B.y - C.y) * ratio1 + C.y
            B.z = Frustum_Near
            TB.u = (TB.u - TC.u) * ratio1 + TC.u
            TB.v = (TB.v - TC.v) * ratio1 + TC.v
            TB.r = (TB.r - TC.r) * ratio1 + TC.r
            TB.g = (TB.g - TC.g) * ratio1 + TC.g
            TB.b = (TB.b - TC.b) * ratio1 + TC.b

            ' C to new A
            ratio2 = d_C_near_z / (C.z - A.z)
            A.x = (A.x - C.x) * ratio2 + C.x
            A.y = (A.y - C.y) * ratio2 + C.y
            A.z = Frustum_Near
            TA.u = (TA.u - TC.u) * ratio2 + TC.u
            TA.v = (TA.v - TC.v) * ratio2 + TC.v
            TA.r = (TA.r - TC.r) * ratio2 + TC.r
            TA.g = (TA.g - TC.g) * ratio2 + TC.g
            TA.b = (TA.b - TC.b) * ratio2 + TC.b


        Case &B100
            Print "C is out"
            result = 2

            ' new D to A
            ratio1 = d_A_near_z / (A.z - C.z)
            D.x = (C.x - A.x) * ratio1 + A.x
            D.y = (C.y - A.y) * ratio1 + A.y
            D.z = Frustum_Near
            TD.u = (TC.u - TA.u) * ratio1 + TA.u
            TD.v = (TC.v - TA.v) * ratio1 + TA.v
            TD.r = (TC.r - TA.r) * ratio1 + TA.r
            TD.g = (TC.g - TA.g) * ratio1 + TA.g
            TD.b = (TC.b - TA.b) * ratio1 + TA.b

            ' B to new C
            ratio2 = d_B_near_z / (B.z - C.z)
            C.x = (C.x - B.x) * ratio2 + B.x
            C.y = (C.y - B.y) * ratio2 + B.y
            C.z = Frustum_Near
            TC.u = (TC.u - TB.u) * ratio2 + TB.u
            TC.v = (TC.v - TB.v) * ratio2 + TB.v
            TC.r = (TC.r - TB.r) * ratio2 + TB.r
            TC.g = (TC.g - TB.g) * ratio2 + TB.g
            TC.b = (TC.b - TB.b) * ratio2 + TB.b


        Case &B101
            Print "B is in"
            result = 1

            ' new A to B
            ratio1 = d_B_near_z / (B.z - A.z)
            A.x = (A.x - B.x) * ratio1 + B.x
            A.y = (A.y - B.y) * ratio1 + B.y
            A.z = Frustum_Near
            TA.u = (TA.u - TB.u) * ratio1 + TB.u
            TA.v = (TA.v - TB.v) * ratio1 + TB.v
            TA.r = (TA.r - TB.r) * ratio1 + TB.r
            TA.g = (TA.g - TB.g) * ratio1 + TB.g
            TA.b = (TA.b - TB.b) * ratio1 + TB.b

            ' B to new C
            ratio2 = d_B_near_z / (B.z - C.z)
            C.x = (C.x - B.x) * ratio2 + B.x
            C.y = (C.y - B.y) * ratio2 + B.y
            C.z = Frustum_Near
            TC.u = (TC.u - TB.u) * ratio2 + TB.u
            TC.v = (TC.v - TB.v) * ratio2 + TB.v
            TC.r = (TC.r - TB.r) * ratio2 + TB.r
            TC.g = (TC.g - TB.g) * ratio2 + TB.g
            TC.b = (TC.b - TB.b) * ratio2 + TB.b


        Case &B110
            Print "A is in"
            result = 1

            ' A to new B
            ratio1 = d_A_near_z / (A.z - B.z)
            B.x = (B.x - A.x) * ratio1 + A.x
            B.y = (B.y - A.y) * ratio1 + A.y
            B.z = Frustum_Near
            TB.u = (TB.u - TA.u) * ratio1 + TA.u
            TB.v = (TB.v - TA.v) * ratio1 + TA.v
            TB.r = (TB.r - TA.r) * ratio1 + TA.r
            TB.g = (TB.g - TA.g) * ratio1 + TA.g
            TB.b = (TB.b - TA.b) * ratio1 + TA.b

            ' new C to A
            ratio2 = d_A_near_z / (A.z - C.z)
            C.x = (C.x - A.x) * ratio2 + A.x
            C.y = (C.y - A.y) * ratio2 + A.y
            C.z = Frustum_Near
            TC.u = (TC.u - TA.u) * ratio2 + TA.u
            TC.v = (TC.v - TA.v) * ratio2 + TA.v
            TC.r = (TC.r - TA.r) * ratio2 + TA.r
            TC.g = (TC.g - TA.g) * ratio2 + TA.g
            TC.b = (TC.b - TA.b) * ratio2 + TA.b


        Case &B111
            Print "discard"
            result = 0

    End Select

End Sub

