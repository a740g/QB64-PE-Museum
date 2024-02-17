Sub ToFrom (ddir, what$, tmatch) Static '                   To/From, Dodo/Minimax chess interface
    Dim i, f, ip$, host, tstart!, t$, el%, port$, lastm$

    tstart! = Timer
    port$ = "50001" ' user 1024-49151, dynamic 49152-65535

    If ipfile = 0 Then
        Shell _Hide "cmd /c ipconfig > temp.txt"
        If _FileExists("temp.txt") Then
            f = FreeFile
            Open "temp.txt" For Input As #f
            While Not (EOF(f))
                Line Input #f, t$
                If InStr(t$, "IPv4") Then ip$ = RTrim$(Mid$(t$, 40, 12))
            Wend
            Close #f
        End If
        If Len(ip$) = 0 Then ip$ = "localhost"

        If (tmatch = 1) Or ((tmatch = 3) And (tbmax = 128)) Then ' chess host (defined constant in chess.bas)
            host = _OpenHost("TCP/IP:" + port$)
            Do: _Limit 10
                ipfile = _OpenConnection(host)
                GoSub tcheck
            Loop Until ipfile <> 0
        Else '                                             minimax client (tbmax a common var with 0)
            Do: _Limit 10
                t$ = "TCP/IP:" + port$ + ":" + ip$
                ipfile = _OpenClient(t$)
                GoSub tcheck
            Loop Until ipfile
        End If
    End If

    If tbmax = 0 Then '                                    if Minimax, show where connected
        Locate 24, 6
        Print ip$;
    End If

    If ddir = 0 Then '                                     send
        GoSub ccheck '                                     connection exists?
        Put #ipfile, , what$
    Else '                                                 receive
        Do: _Limit 20
            GoSub ccheck '                                 connection exists?
            GoSub tcheck '                                 timeout?
            m$ = ""
            Get #ipfile, , m$
            If lastm$ = "*" Then
                t$ = "Pause"
                tstart! = Timer
            Else
                t$ = Space$(20)
            End If
            If tbmax = 0 Then Locate 2, 6: Print t$;
            If Len(m$) Then lastm$ = m$
        Loop Until Len(m$) > 1
        If m$ = "EN" Then Close: System
    End If
    Exit Sub

    ccheck:
    If _Connected(ipfile) = 0 Then
        For i = 1 To 2
            Sound 1000, 1
            _Delay .3
        Next i
        Locate 1, 6: Print "Lost connection"
        _Display
        Sleep
        System
    End If
    Return

    tcheck:
    el% = Timer - tstart!
    If tmatch = 3 Then
        If el% > (30 * 60) Then
            Sound 100, 1
            Locate 1, 6: Print "Timeout";
            _Display
            Sleep
            System
        End If
        If tbmax = 0 Then _AutoDisplay
    Else
        If el% > 1 Then
            m$ = ""
            If tbmax = 0 Then _AutoDisplay
            Exit Sub
        End If
    End If
    Return
End Sub
