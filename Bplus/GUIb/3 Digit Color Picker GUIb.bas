Option _Explicit
'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 410: Ymax = 540: GuiTitle$ = "3 Digit Color Picker GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "Arial.ttf" ' need to do this before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long lblC, TBC, btnC, picC, btnR0, btnG0, btnB0, btnR5, btnG5, btnB5, btnR9, btnG9, btnB9, btnRP, btnGP, btnBP, btnRM, btnGM, btnBM
lblC = NewControl(6, 10, 25, 200, 30, "3 Digit Color:", "")
con(lblC).Align = 2: drwLbl lblC
TBC = NewControl(2, 215, 25, 40, 30, "000", "")
btnC = NewControl(1, 290, 25, 110, 30, "Color", "")
picC = NewControl(5, 10, 70, 390, 210, "Color Sample", "")
btnR0 = NewControl(1, 10, 290, 110, 40, "Red 0", "")
btnG0 = NewControl(1, 150, 290, 110, 40, "Green 0", "")
btnB0 = NewControl(1, 290, 290, 110, 40, "Blue 0", "")
btnR5 = NewControl(1, 10, 340, 110, 40, "Red 5", "")
btnG5 = NewControl(1, 150, 340, 110, 40, "Green 5", "")
btnB5 = NewControl(1, 290, 340, 110, 40, "Blue 5", "")
btnR9 = NewControl(1, 10, 390, 110, 40, "Red 9", "")
btnG9 = NewControl(1, 150, 390, 110, 40, "Green 9", "")
btnB9 = NewControl(1, 290, 390, 110, 40, "Blue 9", "")
btnRP = NewControl(1, 10, 440, 110, 40, "Red +1", "")
btnGP = NewControl(1, 150, 440, 110, 40, "Green +1", "")
btnBP = NewControl(1, 290, 440, 110, 40, "Blue +1", "")
btnRM = NewControl(1, 10, 490, 110, 40, "Red -1", "")
btnGM = NewControl(1, 150, 490, 110, 40, "Green -1", "")
btnBM = NewControl(1, 290, 490, 110, 40, "Blue -1", "")
' End GUI Controls

Dim Shared As _Unsigned Long SampleC
MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    Dim t3$
    Select Case i
        Case btnC ' update Color Sample from TB text
            SampleC = c3S~&(con(TBC).Text)
            _Dest con(picC).ImgHnd
            Color , SampleC
            Cls
            _Dest 0
            drwPic picC
        Case btnR0
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 1, 1) = "0"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnG0
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 2, 1) = "0"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnB0
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 3, 1) = "0"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnRP
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            If Val(Mid$(t3$, 1, 1)) < 9 Then
                Mid$(t3$, 1, 1) = _Trim$(Str$(Val(Mid$(t3$, 1, 1)) + 1))
                con(TBC).Text = t3$
                drwTB TBC
                BtnClickEvent btnC
            End If
        Case btnRM
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            If Val(Mid$(t3$, 1, 1)) > 0 Then
                Mid$(t3$, 1, 1) = _Trim$(Str$(Val(Mid$(t3$, 1, 1)) - 1))
                con(TBC).Text = t3$
                drwTB TBC
                BtnClickEvent btnC
            End If
        Case btnGP
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            If Val(Mid$(t3$, 2, 1)) < 9 Then
                Mid$(t3$, 2, 1) = _Trim$(Str$(Val(Mid$(t3$, 2, 1)) + 1))
                con(TBC).Text = t3$
                drwTB TBC
                BtnClickEvent btnC
            End If
        Case btnGM
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            If Val(Mid$(t3$, 2, 1)) > 0 Then
                Mid$(t3$, 2, 1) = _Trim$(Str$(Val(Mid$(t3$, 2, 1)) - 1))
                con(TBC).Text = t3$
                drwTB TBC
                BtnClickEvent btnC
            End If
        Case btnBP
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            If Val(Mid$(t3$, 3, 1)) < 9 Then
                Mid$(t3$, 3, 1) = _Trim$(Str$(Val(Mid$(t3$, 3, 1)) + 1))
                con(TBC).Text = t3$
                drwTB TBC
                BtnClickEvent btnC
            End If
        Case btnBM
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            If Val(Mid$(t3$, 3, 1)) > 0 Then
                Mid$(t3$, 3, 1) = _Trim$(Str$(Val(Mid$(t3$, 3, 1)) - 1))
                con(TBC).Text = t3$
                drwTB TBC
                BtnClickEvent btnC
            End If
        Case btnR9
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 1, 1) = "9"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnG9
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 2, 1) = "9"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnB9
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 3, 1) = "9"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnR5
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 1, 1) = "5"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnG5
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 2, 1) = "5"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
        Case btnB5
            t3$ = Right$("000" + _Trim$(con(TBC).Text), 3) ' make sure we are right size
            Mid$(t3$, 3, 1) = "5"
            con(TBC).Text = t3$
            drwTB TBC
            BtnClickEvent btnC
    End Select
End Sub

' this is to keep MainRouter in, vs GUI.BM, happy =========================================
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

Sub lblClickevent (i As Long)
    i = i
End Sub

Function c3S~& (digit3$) ' parameter as a string of 3 digits
    Dim s3$
    Dim As Long r, g, b
    s3$ = Right$("000" + digit3$, 3)
    r = Val(Mid$(s3$, 1, 1)): If r Then r = 28 * r + 3
    g = Val(Mid$(s3$, 2, 1)): If g Then g = 28 * g + 3
    b = Val(Mid$(s3$, 3, 1)): If b Then b = 28 * b + 3
    c3S~& = _RGB32(r, g, b)
End Function

' not used in this app but is c3s~& partner in Coloring from 3 digits
Function c3I~& (i As Long) 'parameter as an integer up 0-999 noi red until 3rd digit!
    Dim s3$
    Dim As Long r, g, b
    s3$ = Right$("000" + _Trim$(Str$(i)), 3)
    r = Val(Mid$(s3$, 1, 1)): If r Then r = 28 * r + 3
    g = Val(Mid$(s3$, 2, 1)): If g Then g = 28 * g + 3
    b = Val(Mid$(s3$, 3, 1)): If b Then b = 28 * b + 3
    c3I~& = _RGB32(r, g, b)
End Function


'$include:'GUIb.BM'
