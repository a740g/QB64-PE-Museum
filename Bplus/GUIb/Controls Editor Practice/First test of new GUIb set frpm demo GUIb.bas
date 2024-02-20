'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 1280: Ymax = 720: GuiTitle$ = "untitled_GUIb.bas"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long Pic1, Lst1, Tb1, Btn1, Tb2, Btn2
Pic1 = NewControl(5, 10, 40, 260, 360, "", "Picture 1")
Lst1 = NewControl(3, 280, 40, 370, 200, "", "List Box 1")
Tb1 = NewControl(2, 320, 280, 120, 30, "", "Text Box 1")
Btn1 = NewControl(1, 460, 280, 200, 30, "Btn 1 Here", "Btn 1 Label")
Tb2 = NewControl(2, 320, 360, 120, 30, "", "Text Box 2")
Btn2 = NewControl(1, 460, 360, 200, 30, "Btn 2 Here", "BTN 2 Label")
' End GUI Controls

MainRouter ' after all controls setup, YOU MUST HANDLE USERS ATTEMPT TO EXIT!
System

Sub BtnClickEvent (i As Long)
    i = i
    '   Select Case i
    '   End Select
End Sub

Sub LstSelectEvent (control As Long)
    control = control
    '   Select Case control
    '   End Select
End Sub

Sub SldClickEvent (i As Long)
    i = i
    '   Select Case i
    '   End Select
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
    '   Select Case i
    '   End Select
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
    '   Select Case i
    '   End Select
End Sub

Sub LblClickEvent (i As Long)
    i = i
End Sub
'$include:'GUIb.BM'
