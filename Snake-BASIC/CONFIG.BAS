
Open "CONFIG.DAT" For Random As #1
If LOF(1) <= 0 Then
    Close #1
    Shell "DEL CONFIG.DAT"
    Print "The configuration file is not found."
    Print "Please run the main program to create a new configuration file."
    End
End If

Cls
CreateFancyBox
Locate 7, 25
Print "*"
Locate 7, 28
Print "DO WRAP AROUND:"
Locate 7, 45
Print Chr$(17)
Locate 8, 28
Print "INITIAL LENGTH:"
Locate 8, 45
Print Chr$(17)
Locate 9, 28
Print "INCREASE BY   :"
Locate 9, 45
Print Chr$(17)
Locate 10, 28
Print "FOOD WAIT TIME:"
Locate 10, 45
Print Chr$(17)
Locate 11, 28
Print "PROGRAM DELAY :"
Locate 11, 45
Print Chr$(17)

Locate 12, 28
Print "POINT VALUE   :"
Locate 12, 45
Print Chr$(17)

Locate 13, 28
Print "SOUND         :"
Locate 13, 45
Print Chr$(17)

Locate 14, 28
Print "SAVE AND EXIT"
Locate 15, 28
Print "EXIT WITHOUT SAVING"

Get #1, 1, wrap%
Get #1, 2, init%
Get #1, 3, incr%
Get #1, 4, time%
Get #1, 5, dela%
Get #1, 6, pval%
Get #1, 7, snd%

ChangeWrap wrap%
ChangeInit init%
ChangeIncr incr%
ChangeTime time%
ChangeDela dela%
ChangePval pval%
ChangeSound snd%

Locate 7, 51
Print Chr$(16)
Locate 8, 51
Print Chr$(16)
Locate 9, 51
Print Chr$(16)
Locate 10, 51
Print Chr$(16)
Locate 11, 51
Print Chr$(16)
Locate 12, 51
Print Chr$(16)
Locate 13, 51
Print Chr$(16)
selected = 0

While 1
    c$ = InKey$
    Select Case c$

        Case Chr$(27)
            Close #1
            End

        Case Chr$(0) + "K", Chr$(0) + "M", Chr$(13)
            GoTo CheckSelection

        Case Chr$(0) + "P"
            Locate 7 + selected, 25
            Print " "
            selected = selected + 1
            If selected > 8 Then
                selected = 0
            End If
            Locate 7 + selected, 25
            Print "*"
        Case Chr$(0) + "H"
            Locate 7 + selected, 25
            Print " "
            selected = selected - 1
            If selected < 0 Then
                selected = 8
            End If
            Locate 7 + selected, 25
            Print "*"
    End Select
    ToLoop:
Wend

CheckSelection:

Select Case selected
    Case 0
        wrap% = (wrap% + 1) Mod 2
        ChangeWrap wrap%
        If pval% > GetMaxPV(incr%, init%, wrap%) Then
            pval% = GetMaxPV(incr%, init%, wrap%)
            ChangePval pval%
        End If
    Case 1
        If c$ = Chr$(0) + "K" Then
            init% = init% - 1
            If init% < 4 Then
                init% = 9
            End If
        Else
            init% = init% + 1
            If init% > 9 Then
                init% = 4
            End If
        End If
        If pval% > GetMaxPV(incr%, init%, wrap%) Then
            pval% = GetMaxPV(incr%, init%, wrap%)
            ChangePval pval%
        End If
        ChangeInit init%
    Case 2
        If c$ = Chr$(0) + "K" Then
            incr% = incr% - 1
            If incr% < 1 Then
                incr% = 10
            End If
        Else
            incr% = incr% + 1
            If incr% > 10 Then
                incr% = 1
            End If
        End If
        If pval% > GetMaxPV(incr%, init%, wrap%) Then
            pval% = GetMaxPV(incr%, init%, wrap%)
            ChangePval pval%
        End If
        ChangeIncr incr%
    Case 3
        If c$ = Chr$(0) + "K" Then
            time% = time% - 1
            If time% < 1 Then
                time% = 9
            End If
        Else
            time% = time% + 1
            If time% > 9 Then
                time% = 1
            End If
        End If
        ChangeTime time%
    Case 4
        If c$ = Chr$(0) + "K" Then
            dela% = dela% - 1
            If dela% < 0 Then
                dela% = 9
            End If
        Else
            dela% = dela% + 1
            If dela% > 9 Then
                dela% = 0
            End If
        End If
        ChangeDela dela%
    Case 5
        If c$ = Chr$(0) + "K" Then
            pval% = pval% - 1
            If pval% < 1 Then
                pval% = GetMaxPV(incr%, init%, wrap%)
            End If
        Else
            pval% = pval% + 1
            If pval% > GetMaxPV(incr%, init%, wrap%) Then
                pval% = 1
            End If
        End If
        ChangePval pval%
    Case 6
        snd% = (snd% + 1) Mod 2
        ChangeSound snd%
    Case 7
        Put #1, 1, wrap%
        Put #1, 2, init%
        Put #1, 3, incr%
        Put #1, 4, time%
        Put #1, 5, dela%
        Put #1, 6, pval%
        Put #1, 7, snd%
        Close #1
        End
    Case 8
        Close #1
        End
End Select

GoTo ToLoop

Sub ChangeDela (delay%)
    Locate 11, 47
    Print "  "
    Locate 11, 47
    Print delay%
End Sub

Sub ChangeIncr (incr%)
    Locate 9, 47
    Print "  "
    Locate 9, 47
    Print incr%
End Sub

Sub ChangeInit (init%)
    Locate 8, 47
    Print "  "
    Locate 8, 47
    Print init% + 1
End Sub

Sub ChangePval (pval%)
    Locate 12, 47
    Print "  "
    Locate 12, 47
    Print pval%
End Sub

Sub ChangeSound (snd%)
    Locate 13, 47
    If snd% = 0 Then
        Print "OFF"
    Else
        Print "ON "
    End If
End Sub

Sub ChangeTime (time%)
    Locate 10, 47
    Print "  "
    Locate 10, 47
    Print time%
    Locate 10, 49
    Print "s"
End Sub

Sub ChangeWrap (wrap%)

    Locate 7, 47
    If wrap% = 0 Then
        Print "NO "
    Else
        Print "YES"
    End If

End Sub

Sub CreateFancyBox ()
    Locate 6, 22
    Print Chr$(201)
    Locate 6, 54
    Print Chr$(183)
    Locate 16, 22
    Print Chr$(200)
    Locate 16, 55
    Print Chr$(188)

    For i% = 0 To 31
        Locate 6, 23 + i%
        Print Chr$(205)
        Locate 16, 23 + i%
        Print Chr$(205)
    Next

    Locate 6, 55
    Print Chr$(187)

    For i% = 0 To 8
        Locate 7 + i%, 22
        Print Chr$(186)
        Locate 7 + i%, 55
        Print Chr$(186)
    Next

End Sub

Function GetMaxPV% (incr%, init%, wrap%)
    ret% = incr% + (2 * (incr% - 1)) + (init% - 6)
    If wrap% <> 0 Then ret% = ret% - 5
    If ret% < 1 Then ret% = 1
    GetMaxPV% = ret%
End Function

