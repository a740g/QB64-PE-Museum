_Title "Calling the Tabulator" 'b+ 2020-10-23
' mod "Write Compile Run Kill test2 clip.bas" 'b+ 2020-10-17

' Can we "Evaluate" FUNCTIONs from just a string???
If _FileExists("TableOut.txt") Then
    Kill "TableOut.txt"
End If
start = 1: finish = 10: increment = 1: a = 2: b = 6: c = _Pi
For X = start To finish Step increment
    If r$ = "" Then
        r$ = TS$(X) + " " + TS$(a * X ^ 2 + b * X + c)
    Else
        r$ = r$ + Chr$(10) + TS$(X) + " " + TS$(a * X ^ 2 + b * X + c)
    End If
Next
Print r$
Print " and now the hard way ;-))"

f$ = "a*X^2+b*X+pi" ' our formula
v$ = "a=2" + Chr$(10) + "b=6" + Chr$(10) + "c= pi" 'some variables
ReDim result$(0) ' output array, notice it's dynamic

'   Make the call...
' start, finish, step increment, formula$, degreeFlag True (radians = 0 or False), variables list in formula$, outputArray$()
forXEqual 1, 10, 1, f$, 0, v$, result$()

' show results
For i = LBound(result$) To UBound(result$)
    Print result$(i)
Next
Print "Run is done."

Sub forXEqual (start, toFinish, incStep, formula$, dFlag%, variablesCHR10$, outputArr$())
    Open "TableIn.txt" For Output As #1
    Print #1, TS$(start)
    Print #1, TS$(toFinish)
    Print #1, TS$(incStep)
    Print #1, formula$
    Print #1, TS$(dFlag)
    Print #1, variablesCHR10$
    Close #1
    ReDim outputArr$(0)
    Shell _Hide "Tabulator.exe"
    _Delay .5 ' sometimes it compiles in time sometimes not, 3 reduces the nots
    If _FileExists("TableOut.txt") Then
        Open "TableOut.txt" For Input As #1
        While Not EOF(1)
            Line Input #1, fline$
            sAppend outputArr$(), fline$
        Wend
    End If
End Sub

''append to the string array the string item
Sub sAppend (arr() As String, addItem$)
    ReDim _Preserve arr(LBound(arr) To UBound(arr) + 1) As String
    arr(UBound(arr)) = addItem$
End Sub

Function TS$ (n)
    TS$ = _Trim$(Str$(n))
End Function


