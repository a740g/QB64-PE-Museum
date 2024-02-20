'$include:'GUIb.BI'
' 2022-12-23 Check Memory Game with latest GUIb Dang! I hand to create ImgHnd2 and ImgHnd3 and use toggle for buttons
'   Set Globals from BI
Xmax = 740: Ymax = 500: GuiTitle$ = "Xmas Memory Game GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "ARLRDBD.TTF" ' need to do this before drawing anything from NewControls
Randomize Timer
Dim Shared As Long Btn(1 To 24) ' our 24 buttons for the game
Dim Shared As Long ClickNum, saveNum
initGame
MainRouter ' just wait for player to fire
System

Sub BtnClickEvent (i As Long)
    Dim j, allMatched, ans$
    ClickNum = ClickNum + 1
    con(Btn(i)).ImgHnd = con(Btn(i)).ImgHnd2 ' copy image handle to button for drawing
    drwBtn Btn(i)
    If ClickNum = 1 Then
        saveNum = i
    ElseIf ClickNum = 2 Then
        If con(Btn(saveNum)).ImgHnd3 = con(Btn(i)).ImgHnd3 Then ' have match
            con(Btn(saveNum)).Toggle = -1 ' record buttons have been matched
            con(Btn(i)).Toggle = -1
            allMatched = -1
            For j = 1 To 24
                If con(Btn(j)).Toggle <> -1 Then
                    allMatched = 0
                    'mBox "Not Matched", "Btn" + Str$(j)
                    Exit For
                End If
            Next
            If allMatched Then
                ans$ = _InputBox$("Congratulations", "You've completed this Game, would you like to do another? Enter y for yes", "y")
                If ans$ = "y" Then initGame Else System
            End If
        Else ' hide them  after a time
            _Delay 2
            con(Btn(i)).ImgHnd = 0
            con(Btn(saveNum)).ImgHnd = 0
            drwBtn Btn(i)
            drwBtn Btn(saveNum)
        End If
        ClickNum = 0
        saveNum = 0
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

Sub lblClickEvent (i As Long)
    i = i
End Sub

' For memory Game
Sub initGame
    Dim As Long x, y, i
    Dim t$
    ReDim As Long shuffle(1 To 17)
    ' choose 12 images from 1 to 17 d#.png
    For i = 1 To 17
        shuffle(i) = i
    Next
    For i = 17 To 2 Step -1
        Swap shuffle(i), shuffle(Int(Rnd * i) + 1)
    Next
    ReDim As Long shuffle2(0 To 23)
    For i = 1 To 12 ' load numbers pairs to assign to buttons
        shuffle2((i - 1) * 2) = shuffle(i)
        shuffle2((i - 1) * 2 + 1) = shuffle(i)
    Next
    For i = 23 To 1 Step -1
        Swap shuffle2(i), shuffle2(Int(Rnd * i) + 1)
    Next
    NControls = 0: ReDim con(0) As Control
    i = 1
    For y = 0 To 3
        For x = 0 To 5
            t$ = ExePath$ + OSslash$ + "Images" + OSslash$ + "d" + TS$(shuffle2(i - 1)) + ".png"
            Btn(i) = NewControl(1, x * 120 + 20, y * 120 + 20, 100, 100, "?", "")
            con(Btn(i)).FontH = 70
            con(Btn(i)).FC = C3(889)
            con(Btn(i)).BC = C3(3)
            con(Btn(i)).ImgHnd = 0: con(Btn(i)).Toggle = 0
            con(Btn(i)).ImgHnd2 = _LoadImage(t$)
            con(Btn(i)).ImgHnd3 = shuffle2(i - 1) ' save these numbers for checking matches
            drwBtn Btn(i)
            i = i + 1
        Next
    Next
    saveNum = 0: ClickNum = 0
End Sub

'$include:'GUIb.BM'

