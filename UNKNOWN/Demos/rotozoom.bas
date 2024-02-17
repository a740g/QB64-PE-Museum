' OPTIMIZED  :) rotozoomer in 9 lines by Antoni Gual
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

$NoPrefix
DefLng A-Z
Option Explicit
Option ExplicitArray

$Resize:Smooth
Screen 13
FullScreen SquarePixels , Smooth


Dim midX As Long: midX = Width \ 2
Dim midY As Long: midY = Height \ 2

Dim As Single Ang
Dim As Long CS, SS, Y, X
Do
    Ang = Ang + .005
    CS = Cos(Ang) * Abs(Sin(Ang)) * 128
    SS = Sin(Ang) * Abs(Sin(Ang)) * 128
    For Y = -midY To midY
        For X = -midX To midX
            PSet (X + midX, Y + midY), (((X * CS - Y * SS) And (Y * CS + X * SS)) \ 128)
        Next
    Next

    Limit 60
Loop While Len(InKey$) = 0

System 0

