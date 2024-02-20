'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 1280: Ymax = 720: GuiTitle$ = "untitled_GUIb.bas"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long Pic1, Lst1, Tb1, Btn1, Sld1
Pic1 = NewControl(5, 10, 40, 400, 400, "", "Picture 1")
Lst1 = NewControl(3, 420, 40, 390, 400, "", "List Box 1")
Tb1 = NewControl(2, 10, 470, 400, 30, "", "Text Box 1")
Btn1 = NewControl(1, 420, 450, 390, 50, "Btn 1 Here", "")
Sld1 = NewControl(4, 10, 530, 800, 30, "[0 - 100] Slider = ", "")
' End GUI Controls
con(Sld1).SldLow = 0
con(Sld1).sldHigh = 100
con(Sld1).SldValue = 50
con(Sld1).DecPts = 0
drwSld Sld1, -1
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
