' Created by QB64 community member STxAxTIC

$NoPrefix
Option Explicit
Option ExplicitArray

Title "Epicycles"

Screen NewImage(800, 800, 32)

Type Vector
    x As Double
    y As Double
End Type

Type MPResult
    N As Long
End Type
Dim mpr As MPResult

Dim N As Long
Dim As Integer j, kh, i
Dim As Double x0, y0, xp, yp, t
Dim As Integer m

Dim As Vector RawDataPoint(100000)

Do
    Cls
    Line (0, 0)-(Width, Height), RGB(255, 255, 255, 255), BF
    Color RGB(0, 0, 0), RGB(255, 255, 255)
    Locate 1, 1
    Print "Click & Drag to draw a curve."
    Line (0, Height / 2)-(Width, Height / 2), RGB(0, 0, 0, 255)
    Line (Width / 2, 0)-(Width / 2, Height), RGB(0, 0, 0, 255)
    Display

    GatherMousePoints RawDataPoint(), 4, mpr
    N = mpr.N

    ReDim GivenPoint(N) As Vector
    For j = 0 To N - 1
        GivenPoint(j) = RawDataPoint(j)
    Next

    ReDim As Vector Q(N - 1)
    ReDim As Double rad(N - 1)
    ReDim As Double phase(N - 1)
    ReDim As Integer omega(N - 1)
    ReDim As Double urad(N - 1)
    ReDim As Double uphase(N - 1)
    ReDim As Long uomega(N - 1)
    ReDim As Vector CalculatedPath(N)
    ReDim As Vector ProtoPath(N * 30)
    ReDim As Vector PathSegmentsA(N, N)
    ReDim As Vector PathSegmentsB(N, N)

    Dim dres As Vector
    For j = 0 To N - 1
        omega(j) = j
        If (j > N / 2) Then omega(j) = j - N
        DFT GivenPoint(), j, dres
        Q(j) = dres
        rad(j) = Sqr(Q(j).x * Q(j).x + Q(j).y * Q(j).y)
        phase(j) = Atan2(Q(j).y, Q(j).x)
    Next

    For j = 0 To N - 1
        uomega(j) = omega(j)
        urad(j) = rad(j)
        uphase(j) = phase(j)
    Next

    Call QuickSort(0, N - 1, rad(), phase(), omega())

    m = 0
    CalculatedPath(0).x = GivenPoint(0).x
    CalculatedPath(0).y = GivenPoint(0).y
    For t = 0 To 2 * Pi Step 2 * Pi / N
        x0 = 0
        y0 = 0
        For j = 0 To N - 1
            PathSegmentsA(m, j).x = x0
            PathSegmentsA(m, j).y = y0
            xp = rad(j) * Cos(phase(j) + t * omega(j))
            yp = -rad(j) * Sin(phase(j) + t * omega(j))
            x0 = x0 + xp
            y0 = y0 + yp
            PathSegmentsB(m, j).x = x0
            PathSegmentsB(m, j).y = y0
        Next
        CalculatedPath(m).x = x0
        CalculatedPath(m).y = y0
        m = m + 1
    Next

    i = 0

    KeyClear
    Do

        m = 0
        For t = 0 To (2 * Pi) Step (2 * Pi / (N * 30))
            x0 = 0
            y0 = 0
            For j = 0 To N - 1
                xp = rad(j) * Cos(phase(j) + t * omega(j))
                yp = -rad(j) * Sin(phase(j) + t * omega(j))
                x0 = x0 + xp
                y0 = y0 + yp
                If (j = i) Then
                    ProtoPath(m).x = x0
                    ProtoPath(m).y = y0
                    Exit For
                End If
            Next
            m = m + 1
        Next

        For j = 0 To N - 1
            kh = KeyHit
            Cls
            Locate 1, 1
            Print "Approximation "; Trim$(Str$(i)); " of "; Trim$(Str$(N - 1)); ". Press any key to restart."
            Line (Width / 2, Height - 100)-(Width / 2, Height - 40), RGB32(0, 0, 0, 55)
            For m = 0 To N - 1
                Call CCircle(GivenPoint(m).x, GivenPoint(m).y, 3, RGB(155, 155, 155, 255))
            Next
            For m = 0 To N - 2
                Call CLine(CalculatedPath(m).x, CalculatedPath(m).y, CalculatedPath(m + 1).x, CalculatedPath(m + 1).y, RGB32(0, 0, 0, 75))
            Next
            For m = 0 To i
                Call CCircle(PathSegmentsA(j, m).x, PathSegmentsA(j, m).y, rad(m), RGB32(0, 127, 255, 155))
                Call CLine(PathSegmentsA(j, m).x, PathSegmentsA(j, m).y, PathSegmentsB(j, m).x, PathSegmentsB(j, m).y, RGB32(28, 28, 255, 155))
            Next
            For m = 0 To (j - 0) * 30
                Call CCircle(ProtoPath(m).x, ProtoPath(m).y, 1, RGB32(255, 0, 255 * m / j, 255))
            Next
            Dim nn
            nn = N
            'IF nn > 100 THEN nn = 100
            For m = 0 To N - 1
                y0 = .9 * Width / nn
                x0 = uomega(m) * y0 - y0 / 2
                Call CLineBF(x0, -(Height) / 2 + 40, x0 + y0, -(Height) / 2 + 40 + 20 * Log(1 + urad(m)), RGB32(0, 0, 0, 55))
                If (urad(m) > .001) Then
                    Call CLineBF(x0, -(Height) / 2 + 40, x0 + y0, -(Height) / 2 + 40 + 10 * (uphase(m)), RGB32(255, 0, 0, 55))
                End If
            Next
            For m = 0 To i
                y0 = .9 * Width / nn
                x0 = omega(m) * y0 - y0 / 2
                Call CLineBF(x0, -(Height) / 2 + 40, x0 + y0, -(Height) / 2 + 40 + 20 * Log(1 + rad(m)), RGB32(0, 0, 0, 155))
                If (rad(m) > .001) Then
                    Call CLineBF(x0, -(Height) / 2 + 40, x0 + y0, -(Height) / 2 + 40 + 10 * (phase(m)), RGB32(255, 0, 0, 105))
                End If
            Next

            Display
            Limit 255
            If (kh) Then Exit Do
        Next


        i = i + 1 + Int(Sqr(i))
        If (i >= N) Then i = N - 1

        If (kh) Then
            kh = 0
            Exit Do
        End If
        Delay 1
    Loop
Loop

Sleep
System

Sub GatherMousePoints (arr() As Vector, res As Double, mpr As MPResult)
    Dim As Long i
    Dim As Double mx, my, xx, yy, delta, xold, yold
    xold = 0
    yold = 0
    i = 0
    Do
        Do While MouseInput
            mx = MouseX
            my = MouseY
            If MouseButton(1) Then
                xx = mx - (Width / 2)
                yy = -my + (Height / 2)
                delta = Sqr((xx - xold) ^ 2 + (yy - yold) ^ 2)
                If (delta > res) Then
                    Call CCircle(xx, yy, 3, RGB(0, 0, 0))
                    Display
                    arr(i).x = xx
                    arr(i).y = yy
                    xold = xx
                    yold = yy
                    i = i + 1
                End If
            End If
        Loop
        If ((i > 4) And (Not MouseButton(1))) Then Exit Do
        If (i > 999) Then Exit Do
        Limit 60
    Loop
    mpr.N = i
End Sub

Sub DFT (arr() As Vector, j0 As Integer, result As Vector)
    Dim As Long n
    Dim As Integer k
    Dim As Double u, v, arg
    Dim cres As Vector
    n = UBound(arr)
    For k = 0 To n
        arg = 2 * Pi * k * j0 / n
        cmul Cos(arg), Sin(arg), arr(k).x, arr(k).y, cres
        u = cres.x
        v = cres.y
        result.x = result.x + u
        result.y = result.y - v
    Next
    result.x = result.x / n
    result.y = result.y / n
End Sub

Sub cmul (xx As Double, yy As Double, aa As Double, bb As Double, result As Vector)
    result.x = xx * aa - yy * bb
    result.y = xx * bb + yy * aa
End Sub

Sub CCircle (x0 As Double, y0 As Double, rad As Double, shade As Unsigned Long)
    Circle (Width / 2 + x0, -y0 + Height / 2), rad, shade
End Sub

Sub CPset (x0 As Double, y0 As Double, shade As Unsigned Long)
    PSet (Width / 2 + x0, -y0 + Height / 2), shade
End Sub

Sub CLine (x0 As Double, y0 As Double, x1 As Double, y1 As Double, shade As Unsigned Long)
    Line (Width / 2 + x0, -y0 + Height / 2)-(Width / 2 + x1, -y1 + Height / 2), shade
End Sub

Sub CLineBF (x0 As Double, y0 As Double, x1 As Double, y1 As Double, shade As Unsigned Long)
    Line (Width / 2 + x0, -y0 + Height / 2)-(Width / 2 + x1, -y1 + Height / 2), shade, BF
End Sub

Sub CCircleF (x As Long, y As Long, r As Long, c As Long)
    Dim As Long xx, yy, e
    xx = r
    yy = 0
    e = -r
    Do While (yy < xx)
        If (e <= 0) Then
            yy = yy + 1
            Call CLineBF(x - xx, y + yy, x + xx, y + yy, c)
            Call CLineBF(x - xx, y - yy, x + xx, y - yy, c)
            e = e + 2 * yy
        Else
            Call CLineBF(x - yy, y - xx, x + yy, y - xx, c)
            Call CLineBF(x - yy, y + xx, x + yy, y + xx, c)
            xx = xx - 1
            e = e - 2 * xx
        End If
    Loop
    Call CLineBF(x - r, y, x + r, y, c)
End Sub

Sub QuickSort (LowLimit As Long, HighLimit As Long, rad() As Double, phase() As Double, omega() As Integer)
    Dim As Long piv
    If (LowLimit < HighLimit) Then
        piv = Partition(LowLimit, HighLimit, rad(), phase(), omega())
        Call QuickSort(LowLimit, piv - 1, rad(), phase(), omega())
        Call QuickSort(piv + 1, HighLimit, rad(), phase(), omega())
    End If
End Sub

Function Partition& (LowLimit As Long, HighLimit As Long, rad() As Double, phase() As Double, omega() As Integer)
    Dim As Long i, j
    Dim As Double pivot, tmp
    pivot = rad(HighLimit)
    i = LowLimit - 1
    For j = LowLimit To HighLimit - 1
        tmp = rad(j) - pivot
        If (tmp >= 0) Then
            i = i + 1
            Swap rad(i), rad(j)
            Swap phase(i), phase(j)
            Swap omega(i), omega(j)
        End If
    Next
    Swap rad(i + 1), rad(HighLimit)
    Swap phase(i + 1), phase(HighLimit)
    Swap omega(i + 1), omega(HighLimit)
    Partition = i + 1
End Function

