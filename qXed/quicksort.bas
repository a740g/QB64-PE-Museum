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

Call QuickSort(TextArray(), 1, UBound(TextArray))

Open Command$(2) For Output As #1
For k = 1 To UBound(TextArray)
    Print #1, TextArray(k)
Next
Close #1

System

Sub QuickSort (arr() As String, LowLimit As Long, HighLimit As Long)
    Dim As Long piv
    If (LowLimit < HighLimit) Then
        piv = Partition(arr(), LowLimit, HighLimit)
        Call QuickSort(arr(), LowLimit, piv - 1)
        Call QuickSort(arr(), piv + 1, HighLimit)
    End If
End Sub

Function Partition (arr() As String, LowLimit As Long, HighLimit As Long)
    Dim As Long i, j
    Dim As Integer pivot, tmp
    pivot = Asc(arr(HighLimit))
    i = LowLimit - 1
    For j = LowLimit To HighLimit - 1
        tmp = Asc(arr(j)) - pivot
        If (tmp <= 0) Then
            i = i + 1
            Swap arr(i), arr(j)
        End If
    Next
    Swap arr(i + 1), arr(HighLimit)
    Partition = i + 1
End Function




