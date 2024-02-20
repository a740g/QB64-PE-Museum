Option _Explicit
'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 1280: Ymax = 720: GuiTitle$ = "Test 2 add toggle label_GUIa.bas"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long B1, B2, B3, B4, B5, lb1, lbToggle
B1 = NewControl(1, 10, 30, 300, 30, "This is button1", "Menu: Buttons")
B2 = NewControl(1, 10, 70, 300, 30, "This is button 2", "")
B3 = NewControl(1, 10, 110, 300, 30, "This is button 3", "")
B4 = NewControl(1, 10, 150, 300, 30, "This is button 4", "")
B5 = NewControl(1, 10, 190, 300, 30, "This is button 5", "")
lb1 = NewControl(6, 320, 30, 490, 70, "Hello World!", "A label for a label")
lbToggle = NewControl(6, 320, 190, 490, 30, "Toggle bullet on this label.", "Below a toggle label")
' End GUI Controls
con(lbToggle).ToggleStr = con(lbToggle).Text
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
    Select Case i
        Case lbToggle
            If con(lbToggle).Toggle Then
                con(lbToggle).Text = "* " + con(lbToggle).ToggleStr
            Else
                con(lbToggle).Text = con(lbToggle).ToggleStr
            End If
            drwLbl lbToggle
    End Select
End Sub
'$include:'GUIb.BM'
