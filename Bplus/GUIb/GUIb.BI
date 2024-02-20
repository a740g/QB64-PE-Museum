' rev 2022-11-30 revised removing direntry.h need and curPath$?? no removed
' rev 2022-12-03 add Yellow for active control box color
' rev 2022-12-06 path and file helpers
' rev 2022-12-09 remove Slider Type and make Slider Control Type 4
'     Warning N2, N3, N4 had to be made Single Type because that is what sliders needed
'     Eliminated a bunch of Colors for controls, they are already set in NewControl
' rev 2022-12-10 lbl() is for Labels like con() is for controls so now NLabels, and
'     NewLabel sets up like NewControl
'     eliminatated ShiftActiveDown, now it's just SetActiveControl +/- 1 to ActivceControl
' rev 2022-12-14 new naming convention for updates
'     GUIa.bas, GUIa.BI, GUIa.BM  dump lbl idea as separate control I want labels in Cotrols editor
'     So that means labels can get focus, say you want to use a label for a check box, now you can!
'     Enter or Right Click a label will activate a toggle event. Ha! this allows labels for labels.
' rev 2022-12-17 In process of switching N1, N2, N3... for more helpful variable names
'     Sliders updated 12-16 with the 3 Single Type variables and DecPts replacing N5
'     ToggleStr is for labels to toggle bullets had to make some excuse to allow labels to be
'     control ;-)) Now you have a toggleStr for all the controls! N5 is still TF value.
'rev 2022-12-22 start GUIb add ImgHnd, CurPage, CurSec, CurRow, CurCol start removal of N1, N2, ...

' Thanks Steve and DSMan195276 for Help with _OpenFileDialog paths and files
Dim Shared As String * 1 OSslash
$If WIN Then
    OSslash = "\"
$Else
        OSslash = "/"
$End If
Dim Shared As String ExePath, ImgPath, FontPath
ExePath = _CWD$
ImgPath = ExePath + OSslash + "Images" + OSslash
FontPath = ExePath + OSslash + "Fonts" + OSslash

'reset your Default colors here   FC = ForeColor  BC = Back Color  All the RGB32() are right here in constants section!
Dim Shared As _Unsigned Long Black, White, Yellow, screenBC
Black = _RGB32(0, 0, 0)
White = _RGB32(255, 255, 255)
Yellow = _RGB32(255, 255, 0)
screenBC = C3(669) ' defaults are set in NewControl

Type Control ' all are boxes with colors, 1 is active
    As Long ConType, X, Y, W, H, FontH, DecPts, Toggle
    As Long CurSec, CurPage, CurCol, CurRow, CharsW, RowsPPg, MaxChars, MaxLines
    As Long Align, ImgHnd, ImgHnd2, ImgHnd3
    As Single SldLow, sldHigh, SldValue ' sliders needed single will this effect the other controls?
    As String Text, Label, ToggleStr, SelTxt
    ' New label is if want to give a label to a btn, tb, lst or pic it is 20 fonth, white on form color
    As _Unsigned Long FC, BC
End Type

Dim Shared GuiTitle$ ' WindowOpen
Dim Shared As Long Xmax, Ymax, NControls, ActiveControl
ReDim Shared con(0) As Control
Dim Shared FontHandle&(10 To 128) ' more range? to 128 set in OpenWindow


