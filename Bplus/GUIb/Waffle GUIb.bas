Option _Explicit
' Pretty good Article on Waffle:
' https://nerdschalk.com/waffle-wordle-game-spinoff-how-to-play-where-to-play-gameplay-rules-strategies-and-more/

'$include:'GUIb.BI'
Randomize Timer
Dim Shared As String Dict(1 To 3146), TheWaffle(1 To 6)
Dim Shared As Long TopWordN, BT(1 To 21), Turn, B1Click, NSwaps, lblSwaps
_Title "Waffle GUIb"
Intro

'   Set Globals from BI
Xmax = 620: Ymax = 620: GuiTitle$ = "Waffle GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' need to do this before drawing anything from NewControls"
Init ' calls ColorMyWorld to show puzzle
MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    If con(BT(i)).BC = C3(60) Then Beep: Exit Sub ' ignore green button clicks!
    Turn = Turn + 1
    If Turn = 1 Then
        B1Click = i ' save the place
        ActiveControl = i
        drwBtn BT(i) ' high light
    ElseIf Turn = 2 Then
        If i = B1Click Then ' Cancel the first click
            drwBtn BT(i) ' turn off high light
        Else
            Swap con(BT(i)).Text, con(BT(B1Click)).Text
            NSwaps = NSwaps - 1
            ColorMyWorld
        End If
        Turn = 0 'resets
        ActiveControl = 0
        B1Click = 0
    End If
End Sub

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
End Sub

Sub lblclickevent (i As Long)
    i = i
End Sub

Sub Intro
    Screen _NewImage(600, 400, 32) ' leave room for Editor window next to this QB64 app
    _ScreenMove 200, 200
    Color _RGB32(200, 200, 200), _RGB32(0, 0, 0) ' not too bright white on black for normal print
    '      123456789012345678901234567890123456789012345678901234567890123456789012345
    Locate 6, 1
    Print "                          The Syrup on Waffle:"
    Print
    Print "      6 5-Letter Words have been laid out: 3 across and 3 down in a"
    Print "        Waffle pattern. Their letters have been swapped around and"
    Print "        your job is to get them back in order in 15 swaps or less."
    Print
    Print "            Clues: Green background letters are in right spot,"
    Print "              Yellow backgrounds are in right row or column"
    Print "         (be careful, could be either word at an intersections),"
    Print "            White backgrounds are totally out of their words."
    Print
    Print
    Print "               ... zzz   Press a key to continue  ...zzz"
    LoadDictionary
    Sleep
End Sub

Sub Init ' create controls and variables to start first game
    Dim As Long i, y, x
    i = 1
    For y = 0 To 4
        For x = 0 To 4
            If (x = 1 Or x = 3) And (y = 1 Or y = 3) Then
                ' skip
            Else
                BT(i) = NewControl(1, x * 120 + 20, y * 120 + 20, 100, 100, "", "")
                con(BT(i)).FontH = 45
                drwBtn BT(i)
                i = i + 1
            End If
        Next
    Next
    lblSwaps = NewControl(6, 381, 381, 98, 98, "", "")
    con(lblSwaps).FontH = 40
    con(lblSwaps).FC = White
    con(lblSwaps).BC = C3(669)
    drwLbl lblSwaps
    ResetGame
End Sub

Sub ResetGame ' reset Controls and Variables for new game
    Dim As Long i
    NSwaps = 15
    Turn = 0
    B1Click = 0
    MakeWaffle
    For i = 1 To 5
        con(BT(i)).Text = Mid$(TheWaffle(1), i, 1)
    Next
    For i = 9 To 13
        con(BT(i)).Text = Mid$(TheWaffle(2), i - 8, 1)
    Next
    For i = 17 To 21
        con(BT(i)).Text = Mid$(TheWaffle(3), i - 16, 1)
    Next
    con(BT(6)).Text = Mid$(TheWaffle(4), 2, 1)
    con(BT(14)).Text = Mid$(TheWaffle(4), 4, 1)

    con(BT(7)).Text = Mid$(TheWaffle(5), 2, 1)
    con(BT(15)).Text = Mid$(TheWaffle(5), 4, 1)

    con(BT(8)).Text = Mid$(TheWaffle(6), 2, 1)
    con(BT(16)).Text = Mid$(TheWaffle(6), 4, 1)
    Dim scramble(1 To 21) As Long
    For i = 1 To 21
        scramble(i) = i
    Next
    For i = 21 To 2 Step -1
        Swap scramble(i), scramble(Int(Rnd * i) + 1)
    Next
    For i = 1 To 8
        Swap con(BT(scramble(i))).Text, con(BT(scramble(i + 8))).Text
    Next
    ColorMyWorld
End Sub

Sub ColorMyWorld ' after swaps redraw board with color codes, check for win or loss
    Dim As Long c(1 To 21), i, hits, p ' hits by green count
    Dim soln$(1 To 6)

    ' make a copy of the solution
    For i = 1 To 6
        soln$(i) = TheWaffle(i) ' copy TheWaffle (soln) and blank out letters colored
    Next
    For i = 1 To 21 ' set Green buttons
        If c(i) <> 3 Then ' all 21 cases?
            Select Case i
                Case 1
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(1), 1, 1) Then c(i) = 3: Mid$(soln$(1), 1, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(4), 1, 1) Then c(i) = 3: Mid$(soln$(4), 1, 1) = " "
                Case 2
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(1), 2, 1) Then c(i) = 3: Mid$(soln$(1), 2, 1) = " "
                Case 3
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(1), 3, 1) Then c(i) = 3: Mid$(soln$(1), 3, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(5), 1, 1) Then c(i) = 3: Mid$(soln$(5), 1, 1) = " "
                Case 4
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(1), 4, 1) Then c(i) = 3: Mid$(soln$(1), 4, 1) = " "
                Case 5
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(1), 5, 1) Then c(i) = 3: Mid$(soln$(1), 5, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(6), 1, 1) Then c(i) = 3: Mid$(soln$(6), 1, 1) = " "

                Case 6
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(4), 2, 1) Then c(i) = 3: Mid$(soln$(4), 2, 1) = " "
                Case 7
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(5), 2, 1) Then c(i) = 3: Mid$(soln$(5), 2, 1) = " "
                Case 8
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(6), 2, 1) Then c(i) = 3: Mid$(soln$(6), 2, 1) = " "

                Case 9
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(2), 1, 1) Then c(i) = 3: Mid$(soln$(2), 1, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(4), 3, 1) Then c(i) = 3: Mid$(soln$(4), 3, 1) = " "
                Case 10
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(2), 2, 1) Then c(i) = 3: Mid$(soln$(2), 2, 1) = " "
                Case 11
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(2), 3, 1) Then c(i) = 3: Mid$(soln$(2), 3, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(5), 3, 1) Then c(i) = 3: Mid$(soln$(5), 3, 1) = " "
                Case 12
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(2), 4, 1) Then c(i) = 3: Mid$(soln$(2), 4, 1) = " "
                Case 13
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(2), 5, 1) Then c(i) = 3: Mid$(soln$(2), 5, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(6), 3, 1) Then c(i) = 3: Mid$(soln$(6), 3, 1) = " "

                Case 14
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(4), 4, 1) Then c(i) = 3: Mid$(soln$(4), 4, 1) = " "
                Case 15
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(5), 4, 1) Then c(i) = 3: Mid$(soln$(5), 4, 1) = " "
                Case 16
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(6), 4, 1) Then c(i) = 3: Mid$(soln$(6), 4, 1) = " "

                Case 17
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(3), 1, 1) Then c(i) = 3: Mid$(soln$(3), 1, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(4), 5, 1) Then c(i) = 3: Mid$(soln$(4), 5, 1) = " "
                Case 18
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(3), 2, 1) Then c(i) = 3: Mid$(soln$(3), 2, 1) = " "
                Case 19
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(3), 3, 1) Then c(i) = 3: Mid$(soln$(3), 3, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(5), 5, 1) Then c(i) = 3: Mid$(soln$(5), 5, 1) = " "
                Case 20
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(3), 4, 1) Then c(i) = 3: Mid$(soln$(3), 4, 1) = " "
                Case 21
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(3), 5, 1) Then c(i) = 3: Mid$(soln$(3), 5, 1) = " "
                    If _Trim$(con(BT(i)).Text) = Mid$(soln$(6), 5, 1) Then c(i) = 3: Mid$(soln$(6), 5, 1) = " "
            End Select
        End If
    Next

    ' That was for Green now for yellow
    For i = 1 To 21
        If c(i) <> 3 Then ' all 21 cases?
            Select Case i
                Case 1
                    p = InStr(soln$(1), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(1), p, 1) = " "
                    p = InStr(soln$(4), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(4), p, 1) = " "
                Case 2
                    p = InStr(soln$(1), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(1), p, 1) = " "
                Case 3
                    p = InStr(soln$(1), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(1), p, 1) = " "
                    p = InStr(soln$(5), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(5), p, 1) = " "
                Case 4
                    p = InStr(soln$(1), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(1), p, 1) = " "
                Case 5
                    p = InStr(soln$(1), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(1), p, 1) = " "
                    p = InStr(soln$(6), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(6), p, 1) = " "

                Case 6
                    p = InStr(soln$(4), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(4), p, 1) = " "
                Case 7
                    p = InStr(soln$(5), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(5), p, 1) = " "
                Case 8
                    p = InStr(soln$(6), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(6), p, 1) = " "

                Case 9
                    p = InStr(soln$(2), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(2), p, 1) = " "
                    p = InStr(soln$(4), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(4), p, 1) = " "
                Case 10
                    p = InStr(soln$(2), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(2), p, 1) = " "
                Case 11
                    p = InStr(soln$(2), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(2), p, 1) = " "
                    p = InStr(soln$(5), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(5), p, 1) = " "
                Case 12
                    p = InStr(soln$(2), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(2), p, 1) = " "
                Case 13
                    p = InStr(soln$(2), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(2), p, 1) = " "
                    p = InStr(soln$(6), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(6), p, 1) = " "

                Case 14
                    p = InStr(soln$(4), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(4), p, 1) = " "
                Case 15
                    p = InStr(soln$(5), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(5), p, 1) = " "
                Case 16
                    p = InStr(soln$(6), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(6), p, 1) = " "

                Case 17
                    p = InStr(soln$(3), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(3), p, 1) = " "
                    p = InStr(soln$(4), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(4), p, 1) = " "
                Case 18
                    p = InStr(soln$(3), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(3), p, 1) = " "
                Case 19
                    p = InStr(soln$(3), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(1), p, 3) = " "
                    p = InStr(soln$(5), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(5), p, 1) = " "
                Case 20
                    p = InStr(soln$(3), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(3), p, 1) = " "
                Case 21
                    p = InStr(soln$(3), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(3), p, 1) = " "
                    p = InStr(soln$(6), _Trim$(con(BT(i)).Text))
                    If p > 0 Then c(i) = 2: Mid$(soln$(6), p, 1) = " "
            End Select
        End If
    Next
    con(lblSwaps).Text = TS$(NSwaps)
    drwLbl lblSwaps
    For i = 1 To 21 'update buttons
        If c(i) = 3 Then
            con(BT(i)).FC = C3(999): con(BT(i)).BC = C3(60): hits = hits + 1
        ElseIf c(i) = 2 Then
            con(BT(i)).FC = C3(0): con(BT(i)).BC = C3(990) ' yellow backs row or column or both
        Else
            con(BT(i)).FC = C3(0): con(BT(i)).BC = C3(999) ' complete miss row and column
        End If
        drwBtn BT(i)
    Next

    If hits = 21 Then
        _MessageBox "Congratulations!", "You ate the Waffle."
        ResetGame ' of course you want to play again!
    End If
    If NSwaps <= 0 Then
        _messageBox "So sorry", "You've used your 15 Swaps, the puzzle was:" + Chr$(10)+_
        "   3 Across:"+ chr$(10) + TheWaffle(1) + chr$(10)  +TheWaffle(2) + chr$(10)+_
        TheWaffle(3) + chr$(10)+"   3 Down:" + chr$(10) + TheWaffle(4) + chr$(10)+_
        TheWaffle(5) + chr$(10) + TheWaffle(6)
        ResetGame ' of course you want to play again!
    End If

End Sub

Sub MakeWaffle
    Erase TheWaffle 'clear whatever
    Dim As Long i, j, r, flag, saveR
    startOver:
    For i = 1 To 3
        rewaff:
        TheWaffle(i) = Dict$(Int(Rnd * TopWordN) + 1)
        For j = 1 To i - 1
            If TheWaffle(i) = TheWaffle(j) Then GoTo rewaff
        Next
    Next
    For i = 1 To 3
        r = Int(Rnd * TopWordN) + 1
        saveR = r
        Select Case i
            Case 1
                rewaff2:
                TheWaffle(4) = Dict$(r)
                flag = 0
                If Mid$(TheWaffle(4), 1, 1) = Mid$(TheWaffle(1), 1, 1) Then
                    If Mid$(TheWaffle(4), 3, 1) = Mid$(TheWaffle(2), 1, 1) Then
                        If Mid$(TheWaffle(4), 5, 1) = Mid$(TheWaffle(3), 1, 1) Then
                            flag = -1
                        End If
                    End If
                End If
                If flag = 0 Then
                    r = r + 1
                    If r > TopWordN Then r = 1
                    If r = saveR Then GoTo startOver ' damn it!
                    GoTo rewaff2
                End If
            Case 2
                rewaff3:
                TheWaffle(5) = Dict$(r)
                flag = 0
                If Mid$(TheWaffle(5), 1, 1) = Mid$(TheWaffle(1), 3, 1) Then
                    If Mid$(TheWaffle(5), 3, 1) = Mid$(TheWaffle(2), 3, 1) Then
                        If Mid$(TheWaffle(5), 5, 1) = Mid$(TheWaffle(3), 3, 1) Then
                            flag = -1
                        End If
                    End If
                End If
                If flag = 0 Then
                    r = r + 1
                    If r > TopWordN Then r = 1
                    If r = saveR Then GoTo startOver ' damn it!
                    GoTo rewaff3
                End If
            Case 3
                rewaff4:
                TheWaffle(6) = Dict$(r)
                flag = 0
                If Mid$(TheWaffle(6), 1, 1) = Mid$(TheWaffle(1), 5, 1) Then
                    If Mid$(TheWaffle(6), 3, 1) = Mid$(TheWaffle(2), 5, 1) Then
                        If Mid$(TheWaffle(6), 5, 1) = Mid$(TheWaffle(3), 5, 1) Then
                            flag = -1
                        End If
                    End If
                End If
                If flag = 0 Then
                    r = r + 1
                    If r > TopWordN Then r = 1
                    If r = saveR Then GoTo startOver ' damn it!
                    GoTo rewaff4
                End If
        End Select
    Next
End Sub

Sub LoadDictionary
    ' W3 version allows repeated letters, allot of 5 letter 1st names in here
    Open ExePath + OSslash + "Word Lists" + OSslash + "5l_words.txt" For Input As #1
    While Not EOF(1)
        TopWordN = TopWordN + 1
        Input #1, Dict$(TopWordN)
    Wend
    Close #1
End Sub

'$include:'GUIb.BM'

