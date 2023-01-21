Option _Explicit

Do Until _ScreenExists: Loop
_Title "FluidCraft"

Screen _NewImage(1024, 768, 32)
'_FULLSCREEN , _SMOOTH

Randomize Timer

Type Vector
    x As Double
    y As Double
End Type

Type ShadeVector
    shadered As Double
    shadegreen As Double
    shadeblue As Double
    shadealpha As Double
End Type

Type ShadeElement
    TheName As String
    TheShade As ShadeVector
End Type

Type Pixel
    position As Vector
    velocity As Vector
    acceleration As Vector
    size As Double
    TheShade As ShadeVector
End Type

Dim Shared ShadeData(8) As ShadeElement
Dim Shared ActiveShade As ShadeVector
Dim Shared PixelCloud(3000) As Pixel
Dim Shared ObjectSize As Double
Dim Shared GridSize As Vector
ObjectSize = 6
GridSize.x = 1 + Int(_Width / ObjectSize)
GridSize.y = 1 + Int(_Height / ObjectSize)
Dim Shared Level(GridSize.x, GridSize.y) As ShadeVector

Call InitializeAll
Call LoadFile
Do
    Call UserInput
    Cls
    Call DrawBorder
    Call DrawPixels
    Call DrawLevel
    Call Dynamics
    Call DrawOverlay
    _Display
    _Limit 30
Loop

End

Sub DrawBorder
    Dim k As Integer
    Line (0, 0)-(_Width, _Height), _RGB32(255, 0, 255, 255), BF
    For k = 6 To _Height - 1 - 6
        Line (6, k)-(_Width - 6, k), _RGB32(255 * k / _Height, 0, 255 * (1 - k / _Height), 255)
    Next
    Line (12, 12)-(_Width - 12, _Height - 12), _RGB32(0, 0, 0, 255), BF
    Line (12, 12)-(18 * (UBound(ShadeData) + 1) - 1 + 6 + 12, 38 + 12), _RGB32(0, 0, 255, 255), BF
    Line (12, 12)-(18 * (UBound(ShadeData) + 1) - 1 + 6 + 6, 38 + 6), _RGB32(255, 0, 255, 255), BF
    Line (12, 12)-(18 * (UBound(ShadeData) + 1) - 1 + 6, 38), _RGB32(0, 0, 0, 255), BF
End Sub

Sub DrawPixels
    Dim k As Integer
    Dim x As Double
    Dim y As Double
    Dim s As Double
    For k = 1 To UBound(PixelCloud)
        x = PixelCloud(k).position.x
        y = PixelCloud(k).position.y
        s = PixelCloud(k).size
        Call clinebf(x - s, y - s, x + s, y + s, _RGBA(PixelCloud(k).TheShade.shadered, PixelCloud(k).TheShade.shadegreen, PixelCloud(k).TheShade.shadeblue, PixelCloud(k).TheShade.shadealpha))
    Next
End Sub

Sub DrawLevel
    Dim i As Integer
    Dim j As Integer
    Dim x As Double
    Dim y As Double
    Dim s As Double
    s = ObjectSize
    For i = 1 To GridSize.x
        For j = 1 To GridSize.y
            x = (i - 1) * s
            y = (j - 1) * s
            If (Level(i, j).shadered > 5) Or (Level(i, j).shadegreen > 5) Or (Level(i, j).shadeblue > 5) Then
                Call slinebf(x - s / 2, y - s / 2, x + s / 2 - 1, y + s / 2 - 1, _RGBA(Level(i, j).shadered, Level(i, j).shadegreen, Level(i, j).shadeblue, Level(i, j).shadealpha))
            End If
        Next
    Next
End Sub

Sub DrawOverlay
    Dim k As Integer
    If ActiveShade.shadered < 5 And ActiveShade.shadegreen < 5 And ActiveShade.shadeblue < 5 Then
        Line (ObjectSize * Int(_MouseX / ObjectSize) - ObjectSize / 2 - 1, ObjectSize * Int(_MouseY / ObjectSize) - ObjectSize / 2 - 1)-(ObjectSize * Int(_MouseX / ObjectSize) + ObjectSize / 2 - 1 + 1, ObjectSize * Int(_MouseY / ObjectSize) + ObjectSize / 2 - 1 + 1), _RGBA(255, 255, 255, 255), B
    End If
    Line (ObjectSize * Int(_MouseX / ObjectSize) - ObjectSize / 2, ObjectSize * Int(_MouseY / ObjectSize) - ObjectSize / 2)-(ObjectSize * Int(_MouseX / ObjectSize) + ObjectSize / 2 - 1, ObjectSize * Int(_MouseY / ObjectSize) + ObjectSize / 2 - 1), _RGBA(ActiveShade.shadered, ActiveShade.shadegreen, ActiveShade.shadeblue, ActiveShade.shadealpha), BF
    For k = 1 To UBound(ShadeData)
        Line (18 * k + 1, 18)-(18 * (k + 1) - 1, 32), _RGB32(ShadeData(k).TheShade.shadered, ShadeData(k).TheShade.shadegreen, ShadeData(k).TheShade.shadeblue, ShadeData(k).TheShade.shadealpha), BF
        Line (18 * k + 1, 18)-(18 * (k + 1) - 1, 32), _RGB32(255, 255, 255, 255), B
    Next
End Sub

Sub InitializeAll
    Dim k As Integer
    ShadeData(1).TheName = "Red"
    ShadeData(1).TheShade.shadered = 255
    ShadeData(1).TheShade.shadegreen = 0
    ShadeData(1).TheShade.shadeblue = 0
    ShadeData(1).TheShade.shadealpha = 255
    ShadeData(2).TheName = "Blue"
    ShadeData(2).TheShade.shadered = 0
    ShadeData(2).TheShade.shadegreen = 0
    ShadeData(2).TheShade.shadeblue = 255
    ShadeData(2).TheShade.shadealpha = 255
    ShadeData(3).TheName = "Green"
    ShadeData(3).TheShade.shadered = 0
    ShadeData(3).TheShade.shadegreen = 255
    ShadeData(3).TheShade.shadeblue = 0
    ShadeData(3).TheShade.shadealpha = 255
    ShadeData(4).TheName = "White"
    ShadeData(4).TheShade.shadered = 255
    ShadeData(4).TheShade.shadegreen = 255
    ShadeData(4).TheShade.shadeblue = 255
    ShadeData(4).TheShade.shadealpha = 255
    ShadeData(5).TheName = "Yellow"
    ShadeData(5).TheShade.shadered = 255
    ShadeData(5).TheShade.shadegreen = 255
    ShadeData(5).TheShade.shadeblue = 0
    ShadeData(5).TheShade.shadealpha = 255
    ShadeData(6).TheName = "Aqua"
    ShadeData(6).TheShade.shadered = 0
    ShadeData(6).TheShade.shadegreen = 255
    ShadeData(6).TheShade.shadeblue = 255
    ShadeData(6).TheShade.shadealpha = 255
    ShadeData(7).TheName = "Violet"
    ShadeData(7).TheShade.shadered = 255
    ShadeData(7).TheShade.shadegreen = 0
    ShadeData(7).TheShade.shadeblue = 255
    ShadeData(7).TheShade.shadealpha = 255
    ShadeData(8).TheName = "Black"
    ShadeData(8).TheShade.shadered = 0
    ShadeData(8).TheShade.shadegreen = 0
    ShadeData(8).TheShade.shadeblue = 0
    ShadeData(8).TheShade.shadealpha = 255

    For k = 1 To UBound(PixelCloud)
        PixelCloud(k).size = 3
        PixelCloud(k).acceleration.x = 0
        PixelCloud(k).acceleration.y = 0
        PixelCloud(k).velocity.x = 0
        PixelCloud(k).velocity.y = 0
        PixelCloud(k).position.x = (Rnd - .5) * _Width * .8
        PixelCloud(k).position.y = (Rnd - .5) * _Height * .8
        Call SetPixelShade(k, 0, 0, 255, 150)
    Next

    ActiveShade.shadered = 255
    ActiveShade.shadegreen = 0
    ActiveShade.shadeblue = 0
    ActiveShade.shadealpha = 255

End Sub

Sub SetPixelShade (i As Integer, r As Integer, g As Integer, b As Integer, a As Integer)
    PixelCloud(i).TheShade.shadered = r
    PixelCloud(i).TheShade.shadegreen = g
    PixelCloud(i).TheShade.shadeblue = b
    PixelCloud(i).TheShade.shadealpha = a
End Sub

Sub UserInput
    Dim mb1 As Integer
    Dim mb2 As Integer
    Dim mb3 As Integer
    Dim i As Integer
    Dim j As Integer
    Dim k As Integer
    mb1 = 0
    mb2 = 0
    mb3 = 0
    Do While _MouseInput
        If (_MouseButton(1) = -1) And (mb1 <> 1) Then
            mb1 = -1
            i = 1 + Int(_MouseX / ObjectSize)
            j = 1 + Int(_MouseY / ObjectSize)
            Level(i, j).shadered = ActiveShade.shadered
            Level(i, j).shadegreen = ActiveShade.shadegreen
            Level(i, j).shadeblue = ActiveShade.shadeblue
            Level(i, j).shadealpha = ActiveShade.shadealpha
        End If
        If ((_MouseButton(2) = -1) And (mb2 <> -1)) Then
            mb2 = -1
            i = ObjectSize * Int(_MouseX / ObjectSize)
            j = ObjectSize * Int(_MouseY / ObjectSize)
            ActiveShade.shadered = _Red32(Point(i, j))
            ActiveShade.shadegreen = _Green32(Point(i, j))
            ActiveShade.shadeblue = _Blue32(Point(i, j))
            ActiveShade.shadealpha = _Alpha32(Point(i, j))
        End If
    Loop
    Select Case _KeyHit
        Case Asc("e"), Asc("E")
            Call Export
        Case Asc("r"), Asc("R")
            For k = 1 To UBound(PixelCloud)
                PixelCloud(k).TheShade.shadered = 255
                PixelCloud(k).TheShade.shadegreen = 0
                PixelCloud(k).TheShade.shadeblue = 0
            Next
        Case Asc("b"), Asc("B")
            For k = 1 To UBound(PixelCloud)
                PixelCloud(k).TheShade.shadered = 0
                PixelCloud(k).TheShade.shadegreen = 0
                PixelCloud(k).TheShade.shadeblue = 255
            Next
        Case Asc("0")
            For k = 1 To UBound(PixelCloud)
                PixelCloud(k).position.x = (Rnd - .5) * _Width * .8
                PixelCloud(k).position.y = (Rnd - .5) * _Height * .8
            Next
        Case 27
            For i = 1 To GridSize.x
                For j = 1 To GridSize.y
                    Level(i, j).shadered = 0
                    Level(i, j).shadegreen = 0
                    Level(i, j).shadeblue = 0
                    Level(i, j).shadealpha = 0
                Next
            Next
    End Select
    'DO WHILE _MOUSEINPUT: LOOP
End Sub

Sub Export
    Dim i As Integer
    Dim j As Integer
    'Open "FluidCraft" + LTrim$(RTrim$(Str$(Int(Timer)))) + ".txt" For Output As #1
    'For i = 1 To UBound(Level, 1)
    '    For j = 1 To UBound(Level, 2)
    '        Print #1, i, j, Level(i, j).shadered, Level(i, j).shadegreen, Level(i, j).shadeblue, Level(i, j).shadealpha
    '    Next
    'Next
    'Close #1
End Sub

Sub Dynamics
    Dim k As Integer
    For k = 1 To UBound(PixelCloud)
        Call CalculateInfluence(k)
        Call UpdatePosition(k)
    Next
End Sub

Sub UpdatePosition (i As Integer)
    Dim dt As Double
    Dim damp As Double
    Dim brownian As Double
    dt = 1
    damp = 0.8
    brownian = .65
    PixelCloud(i).velocity.x = damp * PixelCloud(i).velocity.x + dt * PixelCloud(i).acceleration.x
    PixelCloud(i).velocity.y = damp * PixelCloud(i).velocity.y + dt * PixelCloud(i).acceleration.y
    PixelCloud(i).position.x = PixelCloud(i).position.x + dt * PixelCloud(i).velocity.x + (Rnd - .5) * brownian
    PixelCloud(i).position.y = PixelCloud(i).position.y + dt * PixelCloud(i).velocity.y + (Rnd - .5) * brownian
    If (PixelCloud(i).position.y <= -(_Height) / 2 + 2 * PixelCloud(i).size + 1) Then
        PixelCloud(i).position.y = (_Height) / 2 - 2 * PixelCloud(i).size
    End If
End Sub

Sub CalculateInfluence (i As Integer)
    Dim x As Double
    Dim y As Double
    Dim dx As Double
    Dim dy As Double
    Dim xr As Double
    Dim yr As Double
    Dim xg As Double
    Dim yg As Double
    Dim xb As Double
    Dim yb As Double
    Dim WPoint(9) As _Unsigned Long
    x = PixelCloud(i).position.x
    y = PixelCloud(i).position.y
    dx = 2 * PixelCloud(i).size
    dy = 2 * PixelCloud(i).size
    WPoint(7) = cpoint(x - dx, y + dy)
    WPoint(8) = cpoint(x, y + dy)
    WPoint(9) = cpoint(x + dx, y + dy)
    WPoint(4) = cpoint(x - dx, y)
    WPoint(6) = cpoint(x + dx, y)
    WPoint(1) = cpoint(x - dx, y - dy)
    WPoint(2) = cpoint(x, y - dy)
    WPoint(3) = cpoint(x + dx, y - dy)

    Dim k As Integer
    Dim WShade(9) As Double
    Dim xc As Double
    Dim yc As Double
    Dim cs As Integer
    cs = 0
    x = 0
    y = 0

    ' red
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) > 25) And (_Green32(WPoint(k)) < 5) And (_Blue32(WPoint(k)) < 25)) Then
                WShade(k) = _Red32(WPoint(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xr = (WShade(6) - WShade(4) + (WShade(9) + WShade(3)) / Sqr(2) - (WShade(7) + WShade(1)) / Sqr(2))
    yr = (WShade(8) - WShade(2) + (WShade(7) + WShade(9)) / Sqr(2) - (WShade(1) + WShade(3)) / Sqr(2))
    x = x + xr
    y = y + yr

    ' blue
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) < 25) And (_Green32(WPoint(k)) < 5) And (_Blue32(WPoint(k)) > 25)) Then
                WShade(k) = _Red32(WPoint(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xb = (WShade(6) - WShade(4) + (WShade(9) + WShade(3)) / Sqr(2) - (WShade(7) + WShade(1)) / Sqr(2))
    yb = (WShade(8) - WShade(2) + (WShade(7) + WShade(9)) / Sqr(2) - (WShade(1) + WShade(3)) / Sqr(2))
    x = x + xb
    y = y + yb

    ' green
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) < 5) And (_Green32(WPoint(k)) > 250) And (_Blue32(WPoint(k)) < 5)) Then
                WShade(k) = _Red32(WShade(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
                cs = 1
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xg = -(WShade(6) - WShade(4) + (WShade(9) + WShade(3)) / Sqr(2) - (WShade(7) + WShade(1)) / Sqr(2))
    yg = (0 - WShade(2) + (0 + 0) / Sqr(2) - (WShade(1) + WShade(3)) / Sqr(2))
    x = x + xg
    y = y + yg

    ' custom yellow
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) > 250) And (_Green32(WPoint(k)) > 250) And (_Blue32(WPoint(k)) < 5)) Then
                WShade(k) = _Red32(WShade(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
                cs = 1
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xc = (WShade(6) - 0 + (WShade(9) + WShade(3)) / Sqr(2) - (0 + 0) / Sqr(2))
    yc = 0
    x = x + xc
    y = y + yc

    ' custom aqua
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) < 5) And (_Green32(WPoint(k)) > 250) And (_Blue32(WPoint(k)) > 250)) Then
                WShade(k) = _Red32(WShade(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
                cs = 1
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xc = -(WShade(6) - 0 + (WShade(9) + WShade(3)) / Sqr(2) - (0 + 0) / Sqr(2))
    yc = 0
    x = x + xc
    y = y + yc

    ' custom white
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) > 250) And (_Green32(WPoint(k)) > 250) And (_Blue32(WPoint(k)) > 250)) Then
                WShade(k) = _Red32(WShade(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
                cs = 1
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xc = -(WShade(6) - WShade(4) + (WShade(9) + WShade(3)) / Sqr(2) - (WShade(7) + WShade(1)) / Sqr(2))
    yc = -(0 - WShade(2) + (0 + 0) / Sqr(2) - (WShade(1) + WShade(3)) / Sqr(2))
    x = x + xc
    y = y + yc

    ' custom violet
    For k = 1 To 9
        If (k <> 5) Then
            If ((_Red32(WPoint(k)) > 250) And (_Green32(WPoint(k)) < 5) And (_Blue32(WPoint(k)) > 250)) Then
                WShade(k) = _Red32(WShade(k)) + _Green32(WPoint(k)) + _Blue32(WPoint(k))
                cs = 1
            Else
                WShade(k) = 0
            End If
        End If
    Next
    xc = (WShade(6) - WShade(4) + (WShade(9) + WShade(3)) / Sqr(2) - (WShade(7) + WShade(1)) / Sqr(2))
    yc = (WShade(8) - WShade(2) + (WShade(7) + WShade(9)) / Sqr(2) - (WShade(1) + WShade(3)) / Sqr(2))
    x = x + xc
    y = y + yc

    ' Conductivity
    If (cs = 0) Then
        If ((xr * xr + yr * yr) > (xb * xb + yb * yb)) Then
            PixelCloud(i).TheShade.shadered = PixelCloud(i).TheShade.shadered + 64
            If (PixelCloud(i).TheShade.shadered >= 255) Then PixelCloud(i).TheShade.shadered = 255
            PixelCloud(i).TheShade.shadeblue = PixelCloud(i).TheShade.shadeblue - 64
            If (PixelCloud(i).TheShade.shadeblue <= 0) Then PixelCloud(i).TheShade.shadeblue = 0
        End If
        If ((xb * xb + yb * yb) > (xr * xr + yr * yr)) Then
            PixelCloud(i).TheShade.shadered = PixelCloud(i).TheShade.shadered - 64
            If (PixelCloud(i).TheShade.shadered <= 0) Then PixelCloud(i).TheShade.shadered = 0
            PixelCloud(i).TheShade.shadeblue = PixelCloud(i).TheShade.shadeblue + 64
            If (PixelCloud(i).TheShade.shadeblue >= 255) Then PixelCloud(i).TheShade.shadeblue = 255
        End If
    End If

    ' Gravity vs. levity
    If (cs = 0) Then
        y = y - (PixelCloud(i).TheShade.shadered - PixelCloud(i).TheShade.shadeblue) / 255
    End If

    ' Normalize acceleration
    If (Abs(x) < .001) Then
        PixelCloud(i).acceleration.x = 0
    Else
        PixelCloud(i).acceleration.x = -x / Sqr(x * x + y * y)
    End If
    If (Abs(y) < .001) Then
        PixelCloud(i).acceleration.y = 0
    Else
        PixelCloud(i).acceleration.y = -y / Sqr(x * x + y * y)
    End If

    ' Auto-cooling
    If (cs = 0) Then
        PixelCloud(i).TheShade.shadered = PixelCloud(i).TheShade.shadered - 2
        If (PixelCloud(i).TheShade.shadered <= 0) Then PixelCloud(i).TheShade.shadered = 0
        PixelCloud(i).TheShade.shadeblue = PixelCloud(i).TheShade.shadeblue + 2
        If (PixelCloud(i).TheShade.shadeblue >= 255) Then PixelCloud(i).TheShade.shadeblue = 255
    End If
End Sub

Function cpoint& (x1 As Double, y1 As Double)
    Dim TheReturn As _Unsigned Long
    TheReturn = Point(_Width / 2 + x1, -y1 + _Height / 2)
    cpoint = TheReturn
End Function

Sub clinebf (x1 As Double, y1 As Double, x2 As Double, y2 As Double, col As _Unsigned Long)
    Line (_Width / 2 + x1, -y1 + _Height / 2)-(_Width / 2 + x2 - 0, -y2 + _Height / 2 + 0), col, BF
End Sub

Sub slinebf (x1 As Double, y1 As Double, x2 As Double, y2 As Double, col As _Unsigned Long)
    Line (x1, y1)-(x2, y2), col, BF
End Sub

Sub cprintstring (y1 As Double, a As String)
    _PrintString (_Width / 2 - (Len(a) * 8) / 2, -y1 + _Height / 2), a
End Sub

Sub LoadFile
    Dim i As Integer
    Dim j As Integer
    Dim r As Integer
    Dim g As Integer
    Dim b As Integer
    Dim a As Integer
    If (Command$ <> "") Then
        Print "Loading..."
        'Open Command$ For Input As #1
        'Do While Not EOF(1)
        '    Input #1, i, j, r, g, b, a
        '    Level(i, j).shadered = r
        '    Level(i, j).shadegreen = g
        '    Level(i, j).shadeblue = b
        '    Level(i, j).shadealpha = a
        'Loop
        'Close #1
    End If
End Sub
