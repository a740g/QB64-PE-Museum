Option _Explicit
'$include:'GUIb.BI'
'   Set Globals from BI              your Title here VVV
Xmax = 1070: Ymax = 700: GuiTitle$ = "Color Clipper GUIb - Click a picture box."
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long sR, sG, sB, sA, p1, p2
sR = NewControl(4, 20, 30, 1030, 40, "[0 to 255]   Red = ", "")
sG = NewControl(4, 20, 100, 1030, 40, "[0 to 255] Green = ", "")
sB = NewControl(4, 20, 170, 1030, 40, "[0 to 255]  Blue = ", "")
sA = NewControl(4, 20, 240, 1030, 40, "[0 to 255] Alpha = ", "")
p1 = NewControl(5, 10, 310, 520, 380, "", "Blended")
p2 = NewControl(5, 540, 310, 520, 380, "", "Not Blended")
' End GUI Controls

con(sR).SldLow = 0
con(sR).sldHigh = 255
con(sR).SldValue = 128
con(sR).DecPts = 0
drwSld sR, -1

con(sG).SldLow = 0
con(sG).sldHigh = 255
con(sG).SldValue = 128
con(sG).DecPts = 0
drwSld sG, -1

con(sB).SldLow = 0
con(sB).sldHigh = 255
con(sB).SldValue = 128
con(sB).DecPts = 0
drwSld sB, -1

con(sA).SldLow = 0
con(sA).sldHigh = 255
con(sA).SldValue = 128
con(sA).DecPts = 0
drwSld sA, -1

Dim Shared As _Unsigned Long SldColor
Dim Shared Rot
_DontBlend con(p2).ImgHnd
MainRouter ' after all controls setup, YOU MUST HANDLE USERS ATTEMPT TO EXIT!
System

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
    Dim cb$
    cb$ = "_RGB32(" + TS$(con(sR).sldvalue) + ", " + TS$(con(sG).sldvalue) + ", " + TS$(con(sB).sldvalue) + ", " +_
           TS$(con(sA).sldvalue) + ")"

    _Clipboard$ = cb$
    _MessageBox "next GUI Color Clipper:", "Has Clipped: " + cb$ + " for you in clipboard."
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
    SldColor = _RGB32(con(sR).SldValue, con(sG).SldValue, con(sB).SldValue, con(sA).SldValue)
    Rot = Rot + .005
    _Dest con(p1).ImgHnd
    drwVenn Rot
    Line (0, 0)-(520, 380), SldColor, BF
    _Dest con(p2).ImgHnd
    'drwVenn Rot ' dont draw not blended!
    Line (0, 0)-(520, 380), SldColor, BF
    _Dest 0
    drwPic p1
    drwPic p2
End Sub

Sub drwVenn (rot)
    Dim As Long cx, cy, r, r2, i
    Dim a, x, y
    cx = 260: cy = 190: r = 150: r2 = 75: a = _Pi(2 / 3)
    Line (0, 0)-(520, 380), Black, BF
    Line (0, 0)-(cx, cy), White, BF
    Line (cx, cy)-(520, 380), White, BF
    For i = 1 To 3
        x = cx + r2 * Cos(i * a + rot): y = cy + r2 * Sin(i * a + rot)
        Select Case i
            Case 1: fcirc x, y, r, &H80800000
            Case 2: fcirc x, y, r, &H80008000
            Case 3: fcirc x, y, r, &H80000080
        End Select
    Next
End Sub

' keeping MainRouter Happy ====================================================
Sub BtnClickEvent (i As Long)
    i = i
End Sub

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub lblClickevent (i As Long)
    i = 1
End Sub

'$include:'GUIb.BM'
