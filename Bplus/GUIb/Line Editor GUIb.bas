Option _Explicit
'$include:'GUIb.BI'
'   Set Globals from BI your Title here VVV
Xmax = 1230: Ymax = 720: GuiTitle$ = "Line Editor GUIb ---> "
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControls

Dim Shared As Long Saved, BL(0 To 96)
Dim Shared WorkFile$

Dim As Long r, c, i ' make keyboard letters
Dim L$
i = 0
BL(i) = NewControl(1, 820, 600, 398, 28, "Spacebar", "")
For r = 0 To 5
    For c = 0 To 15
        i = i + 1
        If i = 95 Then
            L$ = Chr$(27)
        ElseIf i = 96 Then
            L$ = Chr$(178)
        Else
            L$ = Chr$(i + 32)
        End If
        BL(i) = NewControl(1, 820 + c * 25, 420 + r * 30, 22, 28, L$, "")
    Next
Next

' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long LstF, TbL, BtnA, BNew, BOpen, BSav, BSaveAs, BReplace, BInsert, BCopy, BDelete, BExit
LstF = NewControl(3, 10, 30, 800, 600, "", ".txt File:")
TbL = NewControl(2, 10, 670, 1100, 30, "", "Edit Line:")
BtnA = NewControl(1, 1120, 670, 100, 30, "plus", "")
BNew = NewControl(1, 820, 50, 400, 24, "New", "File:")
BOpen = NewControl(1, 820, 75, 400, 24, "Open", "")
BSav = NewControl(1, 820, 100, 400, 24, "Save", "")
BSaveAs = NewControl(1, 820, 125, 400, 24, "Save As", "")
BReplace = NewControl(1, 820, 190, 400, 24, "Replace Highlighted", "Edit Line:")
BInsert = NewControl(1, 820, 215, 400, 24, "Insert at Highlight", "")
BCopy = NewControl(1, 820, 280, 400, 24, "Copy to Edit", "File Item:")
BDelete = NewControl(1, 820, 305, 400, 24, "Delete", "")
BExit = NewControl(1, 820, 350, 400, 24, "Exit", "")
' End GUI Controls

SetActiveControl TbL
Saved = -1
_Title GuiTitle$ + "new"
MainRouter ' after all controls setup, YOU MUST HANDLE USERS ATTEMPT TO EXIT!
CheckSaved
System

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub BtnClickEvent (ctrl As Long)
    Dim As Long i, j
    Dim test$
    If ctrl = 1 Then ' spacebar
        TBKeyEvent TbL, 32, 0
        SetActiveControl TbL
    ElseIf ctrl > 1 And ctrl < 95 Then
        TBKeyEvent TbL, ctrl + 31, 0
        SetActiveControl TbL
    ElseIf ctrl = 96 Then ' backspace
        TBKeyEvent TbL, 8, 0
        SetActiveControl TbL
    ElseIf ctrl = 97 Then ' delete
        TBKeyEvent TbL, 21248, 0
        SetActiveControl TbL

    ElseIf ctrl = BtnA Then ' add / append line from tbl
        If con(LstF).Text = "" Then
            con(LstF).Text = con(TbL).Text
        Else
            con(LstF).Text = con(LstF).Text + "~" + con(TbL).Text
        End If
        drwLst LstF
        ClearLine
        Saved = 0

    ElseIf ctrl = BNew Then
        _Title GuiTitle$ + "new"
        CheckSaved
        WorkFile$ = ""
        con(LstF).Text = ""
        con(LstF).CurPage = 1
        con(LstF).CurRow = 1
        drwLst LstF
        ClearLine
        Saved = -1

    ElseIf ctrl = BOpen Then
        CheckSaved
        test$ = _OpenFileDialog$("Select .txt File to Edit", ExePath$ + OSslash$ +_
         "*.txt", "*.txt", ".txt files")

        If test$ <> "" Then ' load it
            WorkFile$ = test$
            _Title GuiTitle$ + WorkFile$
            ReDim FileLines$(1 To 1) ' zero out
            Open WorkFile$ For Input As #1
            i = 0
            While Not EOF(1)
                i = i + 1
                ReDim _Preserve FileLines$(1 To i)
                Line Input #1, FileLines$(i)
            Wend
            Close #1
            con(LstF).Text = Join$(FileLines$(), "~")
            con(LstF).CurPage = 1
            con(LstF).CurRow = 1
            drwLst LstF
            ClearLine
            Saved = -1
        End If

    ElseIf ctrl = BSav Then
        SaveWork
        ClearLine

    ElseIf ctrl = BSaveAs Then
        WorkFile$ = "" ' like a new file
        _Title GuiTitle$ + WorkFile$
        SaveWork
        ClearLine

    ElseIf ctrl = BReplace Then
        j = LstHighliteNum(LstF)
        ReDim T$(1 To 1)
        Split con(LstF).Text, "~", T$()
        T$(j) = con(TbL).Text
        con(LstF).Text = Join$(T$(), "~")
        drwLst LstF
        ClearLine
        Saved = 0

    ElseIf ctrl = BInsert Then
        j = LstHighliteNum(LstF)
        ReDim T$(1 To 1)
        Split con(LstF).Text, "~", T$()
        ReDim _Preserve T$(1 To UBound(T$) + 1)
        For i = UBound(T$) To j + 1 Step -1
            T$(i) = T$(i - 1)
        Next
        T$(j) = con(TbL).Text
        con(LstF).Text = Join$(T$(), "~")
        drwLst LstF
        ClearLine
        Saved = 0

    ElseIf ctrl = BCopy Then
        LstSelectEvent LstF

    ElseIf ctrl = BDelete Then
        j = LstHighliteNum(LstF)
        ReDim T$(1 To 1)
        Split con(LstF).Text, "~", T$()
        For i = j To UBound(T$) - 1
            T$(i) = T$(i + 1)
        Next
        ReDim _Preserve T$(1 To UBound(T$) - 1)
        con(LstF).Text = Join$(T$(), "~")
        drwLst LstF
        ClearLine
        Saved = 0

    ElseIf ctrl = BExit Then
        CheckSaved
        System

    End If

End Sub

Sub ClearLine
    con(TbL).Text = ""
    con(TbL).CurSec = 1
    con(TbL).CurCol = 1
    SetActiveControl TbL
End Sub

Sub CheckSaved
    Dim As Long a
    If Saved = 0 Then
        a = _MessageBox("Save work?", "Do you want to save changes to " + WorkFile$,_
         "yesno", "question")

        If a = 1 Then SaveWork
    End If
End Sub

Sub SaveWork
    Dim answer$, f$
    Dim As Long yn
    If WorkFile$ = "" Then ' get a name going
        answer$ = _SaveFileDialog$("Save File As:", ExePath$ + OSslash$ + "*.txt", "*.txt", "txt file")
        If answer$ <> "" Then
            If _FileExists(answer$) Then
                yn = _MessageBox("Write Over Existing File?", answer$ +_
                 ", File already exists. Do you wish to Start Over?", "yesno", "warning")
                If yn <> 1 Then Exit Sub
            End If
            WorkFile$ = answer$
            _Title GuiTitle$ + WorkFile$
        End If
    End If
    ReDim t$(1 To 1)
    Split con(LstF).Text, "~", t$()
    f$ = Join$(t$(), Chr$(13) + Chr$(10))
    Open WorkFile$ For Output As #1
    Print #1, f$
    Close
    Saved = -1
    _MessageBox "Saved", WorkFile$
End Sub

' keep MainRouter Happy :) =============================================
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

'$include:'GUIb.BM'
