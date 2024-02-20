'$include:'GUIb.BI'

'   Set Globals from BI
Xmax = 1200: Ymax = 700: GuiTitle$ = "Test textbox"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' << arial works well for pixel sizes 6 to 128 .FontH

' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long tb1
tb1 = NewControl(2, 10, 30, 168, 20, "", "Test Text Box")
MainRouter ' after all controls setup
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
    '   Select Case i
    '   End Select
End Sub

'$include:'GUIb.BM'
