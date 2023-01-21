Option _Explicit

$ScreenHide
$Console
_Dest _Console
$Console:Only

Dim As Long k
Dim As String a
ReDim As String TextArray(256 ^ 2)

If (_CommandCount > 0) Then
    Open Command$(1) For Input As #1
    k = 0
    Do While Not EOF(1)
        Line Input #1, a
        If (a <> "") Then
            k = k + 1
            TextArray(k) = a
        End If
    Loop
    Close #1
End If

ReDim _Preserve TextArray(k) As String

Call BubbleSort(TextArray())

Open Command$(2) For Output As #1
For k = 1 To UBound(TextArray)
    Print #1, TextArray(k)
Next
Close #1

System

Sub BubbleSort (arr() As String)
    Dim As Integer i, j
    Dim As String u, v
    For j = UBound(arr) To 1 Step -1
        For i = 2 To UBound(arr)
            u = arr(i - 1)
            v = arr(i)
            If (Asc(u) > Asc(v)) Then
                Swap arr(i - 1), arr(i)
            End If
        Next
    Next
End Sub




