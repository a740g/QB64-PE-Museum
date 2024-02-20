'$include:'GUIb.BI'
Option _Explicit
'   Set Globals from BI
Xmax = 820: Ymax = 580: GuiTitle$ = "Adding Machine GUIb"

' =============================================================================================
'
' Note: the Text Boxes used: tbN and tbT (Number and Total) are really acting as labels,
'  what you change in text is ignored.
'
'=================================================================================================

OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' need to do this before drawing anything from NewControls
Dim Shared As Long Btn(1 To 20), lblN, lblT, LB ' our 20 buttons for the adding
Dim Shared As _Integer64 Num, Total
Dim Shared B$, Tape$
init
MainRouter ' just wait for player to fire
System

Sub BtnClickEvent (i As Long)
    _Delay .2 ' because the delay isn't done until after this is processed! need to fix that in MainRouter
    '7890C
    '456o<
    '123+-
    'Key#   12345678       9 00      10 <-      12345
    'bt$ = "7890C456" + Chr$(148) + Chr$(27) + "123+-"
    Select Case i
        Case 1, 2, 3, 4, 6, 7, 8, 11, 12, 13 ' 7890 567 123
            B$ = B$ + con(i).Text: Num = Val(B$): con(lblN).Text = Dot2_17$(Num): drwLbl lblN
        Case 5 ' C
            B$ = "": Num = 0: con(lblN).Text = Dot2_17$(Num): drwLbl lblN
            Total = 0: con(lblT).Text = Dot2_17$(Total): drwLbl lblT
            Tape$ = Tape$ + "~" + " "
            GoSub updateLB
        Case 9 ' chr$(148) for 00
            B$ = B$ + "00": Num = Val(B$): con(lblN).Text = Dot2_17$(Num): drwLbl lblN
        Case 10 ' backspace <-
            If Len(B$) Then
                B$ = Left$(B$, Len(B$) - 1): Num = Val(B$): con(lblN).Text = Dot2_17$(Num)
                drwLbl lblN
            End If
        Case 14 ' +
            If B$ <> "" Then Num = Val(B$) ' Else Num = num
            Total = Total + Num
            con(lblT).Text = Dot2_17$(Total): drwLbl lblT
            B$ = "" ' my calc does not change the screen
            Tape$ = Tape$ + "~" + "+ " + Dot2_17$(Num)
            GoSub updateLB
        Case 15 ' -
            If B$ <> "" Then Num = Val(B$) ' Else Num = num
            Total = Total - Num
            con(lblT).Text = Dot2_17$(Total): drwLbl lblT
            B$ = "" ' my calc does not change the screen
            Tape$ = Tape$ + "~" + "- " + Dot2_17$(Num)
            GoSub updateLB
    End Select
    Exit Sub
    updateLB:
    Tape$ = Tape$ + "~" + "T " + Dot2_17$(Total)
    con(LB).Text = Tape$ ' sets the delimited string into lst's text for splitting
    drwLst LB ' this updates list box with new line(s) splitting out the tape$
    LstKeyEvent LB, 20224 '  this moves highlite to end and of the tape$
    Return
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

Sub lblClickEvent (i As Long)
    i = 1
End Sub

' For Adding Machine
Sub init
    Dim bt$
    Dim As Long x, y, i
    '7890C
    '456o<
    '123+-
    'Key#  12345678       9 00      10 <-      12345
    bt$ = "7890C456" + Chr$(148) + Chr$(27) + "123+-"
    i = 1
    For y = 0 To 2
        For x = 0 To 4
            Btn(i) = NewControl(1, x * 120 + 20, y * 120 + 220, 100, 100, Mid$(bt$, i, 1), "")
            con(Btn(i)).FontH = 64
            con(Btn(i)).FC = C3(99)
            con(Btn(i)).BC = C3(33)
            drwBtn Btn(i)
            i = i + 1
        Next
    Next
    lblN = NewControl(6, 20, 20, 580, 80, "", "")
    con(lblN).FontH = 54
    con(lblN).Align = 2
    con(lblN).FC = C3(0)
    con(lblN).BC = C3(444)
    drwLbl lblN

    lblT = NewControl(6, 20, 110, 580, 80, Dot2_17$(0), "")
    con(lblT).FontH = 54
    con(lblT).Align = 2
    con(lblT).FC = C3(0)
    con(lblT).BC = C3(444)
    drwLbl lblT

    LB = NewControl(3, 620, 20, 180, 540, "", "")
    con(LB).FC = C3(0)
    con(LB).BC = C3(888)
    Tape$ = "T " + Dot2_17$(0)
    con(LB).Text = Tape$
    drwLst LB
End Sub

' this formats a _integer64 type number into a right aligned 14 places and places dot 2 places in
' so fits up to 9,999,999,999.99 dollars or some other unit
Function Dot2_17$ (cents As _Integer64) ' modified for right aligned in 14 spaces
    Dim s$, rtn$, sign$
    s$ = _Trim$(Str$(cents)) ' TS$ is for long
    If Left$(s$, 1) = "-" Then sign$ = "-": s$ = Mid$(s$, 2) Else sign$ = ""
    If Len(s$) = 1 Then
        s$ = sign$ + "0.0" + s$
    ElseIf Len(s$) = 2 Then
        s$ = sign$ + "0." + s$
    Else
        s$ = sign$ + Mid$(s$, 1, Len(s$) - 2) + "." + Mid$(s$, Len(s$) - 1)
    End If
    rtn$ = Space$(17)
    s$ = _Trim$(s$)
    Mid$(rtn$, 17 - Len(s$)) = s$
    Dot2_17$ = rtn$
End Function

'$include:'GUIb.BM'
