Option _Explicit

$ScreenHide
$Console
_Dest _Console
$Console:Only

Dim As Integer k
Dim As String t

If (_CommandCount > 0) Then
    For k = 1 To _CommandCount
        If _FileExists(Command$(k)) Then
            Open Command$(k) For Input As #1
            Do While Not EOF(1)
                Line Input #1, t
                Print t
            Loop
            Close #1
        Else
            Print "Error"
        End If
    Next
End If

System


