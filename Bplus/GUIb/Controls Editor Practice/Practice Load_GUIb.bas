Option _Explicit
'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 1280: Ymax = 720: GuiTitle$ = "next GUI Practice Load"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' need to do this before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long Pic1, Lst1, Tb1, BtnPractice, Lbl1, lblPractice, btnImage
Pic1 = NewControl(5, 10, 60, 320, 480, "Picture 1", "")
Lst1 = NewControl(3, 340, 60, 350, 480, "List Box 1", "")
Tb1 = NewControl(2, 10, 560, 320, 40, "Text Box 1", "")
BtnPractice = NewControl(1, 10, 620, 680, 40, "This is BtnPractice with the TBText fixed.", "")
Lbl1 = NewControl(6, 340, 560, 350, 40, "Label 1", "")
lblPractice = NewControl(6, 10, 10, 680, 40, "Hello World! This is the Practice Load File.", "")
btnImage = NewControl(1, 700, 30, 450, 660, "<img.jpeg", "Paris!")
' End GUI Controls
' try a left alignment on lblPractice
MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    i = i
    '   Select Case i
    '   End Select"
End Sub

Sub LstSelectEvent (control As Long)
    control = control
    '   Select Case control
    '   End Select"
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
    '   Select Case i
    '   End Select"
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
End Sub

Sub LblClickEvent (i As Long)
    i = i
End Sub

'$include:'GUIb.BM'

