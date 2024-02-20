Option _Explicit ' fix up new variable names
'$include:'GUIb.BI'

'   Set Globals from BI
Xmax = 1210: Ymax = 620: GuiTitle$ = "Vince Designer Egg GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' << arial works well for pixel sizes 6 to 128 .FontH
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long picEgg, sldw, sldD, sldL, sldB
picEgg = NewControl(5, 5, 25, 800, 590, "", "Designer Egg")
sldw = NewControl(4, 820, 64, 380, 65, "(  0 to 1 )   w = ", "") ' text has the limits and variable =
sldD = NewControl(4, 820, 203, 380, 65, "(2.8 to 3.6)  D = ", "") ' label will complete the label for sld with value added
sldL = NewControl(4, 820, 342, 380, 65, "(4.4 to 6.4)  L = ", "")
sldB = NewControl(4, 820, 481, 380, 65, "(3.6 to 4.6)  B = ", "")
' End GUI Controls

Dim Shared S, B, L, w, D ' globals for Egg drawing
S = 80: L = 5.4: B = 4.1: w = .4: D = 3.2 '< These are Vince starting parameter values for good egg

'ReDim Shared Sliders(3) As Slider
'Sliders(0).Label = "(  0 to 1 )   w = "  ' now .text
con(sldw).SldLow = 0 ' low
con(sldw).sldHigh = 1 ' high
con(sldw).SldValue = .4 ' value
con(sldw).DecPts = -2 ' dec pts

'Sliders(1).Label = "(2.8 to 3.6)  D = "
con(sldD).SldLow = 2.8
con(sldD).sldHigh = 3.6
con(sldD).SldValue = 3.2
con(sldD).DecPts = -3

'Sliders(2).Label = "(4.4 to 6.4)  L = "
con(sldL).SldLow = 4.4
con(sldL).sldHigh = 6.4
con(sldL).SldValue = 5.4
con(sldL).DecPts = -4

'Sliders(3).Label = "(3.6 to 4.6)  B = "
con(sldB).SldLow = 3.6
con(sldB).sldHigh = 4.6
con(sldB).SldValue = 4.1
con(sldB).DecPts = -4

drwEgg ' up date picEgg
drwSld sldw, -1 ' when mouse < 5 or > w - 10 then value not changed but the drawn with use N4 = value
drwSld sldD, -1
drwSld sldL, -1
drwSld sldB, -1
MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    i = i
End Sub

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    Select Case i
        Case sldw
            w = con(sldw).SldValue
            drwEgg
        Case sldD
            D = con(sldD).SldValue
            drwEgg
        Case sldL
            L = con(sldL).SldValue
            drwEgg
        Case sldB
            B = con(sldB).SldValue
            drwEgg
    End Select
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

Sub drwEgg ' makes an image the size of the picBox and give it the picEgg N1 handle
    Dim xx, x, a, y, aa, sh, sw
    Dim As Long sd
    sh = con(picEgg).H: sw = con(picEgg).W
    sd = _Dest
    _Dest con(picEgg).ImgHnd
    Line (0, 0)-(con(picEgg).W, con(picEgg).H), &HFF000000, BF ' cls

    For xx = -0.5 * L * S To 0.5 * L * S
        x = xx / S
        a = (L * L - 4 * x * x) / (L * L + 8 * w * x + 4 * w * w)
        y = 0.5 * B * Sqr(a)
        'you can stop here for p(x) = x

        a = Sqr(5.5 * L * L + 11 * L * w + 4 * w * w)
        a = a * (Sqr(3) * B * L - 2 * D * Sqr(L * L + 2 * w * L + 4 * w * w))
        a = a / (Sqr(3) * B * L * (Sqr(5.5 * L * L + 11 * L * w + 4 * w * w) - 2 *_
         Sqr(L * L + 2 * w * L + 4 * w * w)))

        aa = L * (L * L + 8 * w * x + 4 * w * w)
        aa = aa / (2 * (L - 2 * w) * x * x + (L * L + 8 * L * w - 4 * w * w) * x +_
         2 * L * w * w + L * L * w + L * L * L)
        aa = 1 - aa

        y = y * (1 - a * aa)

        Line (sw / 2 + xx, sh / 2 - S * y)-(sw / 2 + xx, sh / 2 + S * y), &HFFFFFFFF
    Next
    'ok now that N1 has been updated
    _Dest sd
    drwPic picEgg
End Sub

'$include:'GUIb.BM'

