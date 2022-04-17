'///Non Palette rotated plasma
'///Relsoft 2003
'///Compile and see the speed.  Didn't optimize it as much as I want though...

$NoPrefix

$Resize:Smooth
Screen 13
FullScreen SquarePixels , Smooth

2 Dim Lsin1%(-1024 To 1024), Lsin2%(-1024 To 1024), Lsin3%(-1024 To 1024)
3 For I% = -1024 To 1024
    4 Lsin1%(I%) = Sin(I% / (128)) * 256 'Play with these values
    5 Lsin2%(I%) = Sin(I% / (64)) * 128 'for different types of fx
    6 Lsin3%(I%) = Sin(I% / (32)) * 64 ';*)
    7 If I% > -1 And I% < 256 Then Palette I%, 65536 * (Int(32 - 31 * Sin(I% * 3.14151693# / 128))) + 256 * (Int(32 - 31 * Sin(I% * 3.14151693# / 64))) + (Int(32 - 31 * Sin(I% * 3.14151693# / 32)))
8 Next I%
9 Def Seg = &HA000
10 Dir% = 1
11 Do
    12 Counter& = (Counter& + Dir%)
    13 If Counter& > 600 Then Dir% = -Dir%
    14 If Counter& < -600 Then Dir% = -Dir%
    15 Rot% = 64 * (((Counter& And 1) = 1) Or 1)
    16 StartOff& = 0
    17 For y% = 0 To 199
        18 For x% = 0 To 318
            19 Rot% = -Rot%
            20 C% = Lsin3%(x% + Rot% - Counter&) + Lsin1%(x% + Rot% + Counter&) + Lsin2%(y% + Rot%)
            21 Poke StartOff& + x%, C%
        22 Next x%
        23 StartOff& = StartOff& + 320
    24 Next y%
    Limit 60
25 Loop Until InKey$ <> ""

System 0
