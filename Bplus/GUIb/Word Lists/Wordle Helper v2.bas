Option _Explicit
_Title "Wordle Helper v2" ' b+ 2022-08-09
' use yellow - where letter is NOT
' put in a loop to eliminate as play Wordle

Dim Shared green$, yellow$
Dim nope$, k$
Dim w$(1 To 3145), wLeft$(1 To 3145), bw$
Dim As Long topWL, i, j, flag, top

restart:
Open "5l_words.txt" For Input As #1
For i = 1 To 3145
    Input #1, w$(i)
Next
Close #1
top = 3145
topWL = 0
Do
    ' new round
    Input "  Enter 5 letters Green (* for non green) from newest round "; green$
    Input "Enter 5 letters Yellow (* for non yellow) from newest round "; yellow$
    Print "If letters appear as green or yellow then they are in word."
    Input "   Enter letters NOT in word (any length) from newest round "; nope$
    For i = 1 To top ' eliminate words that have letters known not to be in word
        flag = -1
        For j = 1 To Len(nope$)
            If InStr(w$(i), Mid$(nope$, j, 1)) Then flag = 0: Exit For
        Next
        If flag Then 'candidate
            topWL = topWL + 1
            wLeft$(topWL) = w$(i)
        End If
    Next
    Print "After nope$, number of words left are"; topWL

    ' now
    top = topWL
    topWL = 0
    For i = 1 To top
        w$(i) = wLeft$(i) ' put the words left back into w$()
    Next

    For i = 1 To top
        If match&(w$(i), bw$) Then ' bw$ is the word to check with green matches removed
            If m2&(bw$) Then ' check yellow matches
                topWL = topWL + 1
                wLeft$(topWL) = w$(i)
            End If
        End If
    Next

    ' now
    top = topWL
    topWL = 0
    For i = 1 To top
        w$(i) = wLeft$(i) ' put the words left back into w$()
    Next

    Print "Word candidates:"; top
    For i = 1 To top
        Print w$(i); " ";
    Next
    Print
    Print " ...ZZZ press space bar to continue round, x to start over, esc to quit"
    While 1
        k$ = InKey$
        If Len(k$) Then
            If Asc(k$) = 27 Then End
            If k$ = " " Or k$ = "x" Then Exit While
        End If
        _Limit 30
    Wend
    If k$ = "x" Then GoTo restart
    _KeyClear
Loop

Function match& (w2$, bw$) ' replace matching greenies with spaces in bw$ and use bw$ for checking yellow
    Dim As Long i
    bw$ = w2$
    For i = 1 To 5
        If Mid$(green$, i, 1) <> "*" Then
            If Mid$(green$, i, 1) <> Mid$(w2$, i, 1) Then
                Exit Function
            Else
                Mid$(bw$, i, 1) = " "
            End If
        End If
        'else pass the word untouched as bw$
    Next
    match& = -1
End Function

Function m2& (w$)
    Dim bw$, i As Long, p As Long
    bw$ = w$
    For i = 1 To 5
        If Mid$(yellow$, i, 1) <> "*" Then ' there is a letter here we have to find in candidate words but not at i!
            p = InStr(bw$, Mid$(yellow$, i, 1))
            If p Then ' use the info if letter yellow at spot it is not word it would be green
                If p <> i Then Mid$(bw$, p, 1) = " " Else Exit Function
            Else ' no p means the letter is not in word so dont pass word
                Exit Function
            End If
        End If
    Next
    m2& = -1
End Function

