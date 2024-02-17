'$INCLUDE:'menutop.bi'

Const FALSE = 0, TRUE = Not FALSE
Dim Menu%
Screen _NewImage(640, 480, 32)
Cls , _RGB32(50, 100, 200)
_ScreenMove _Middle
SETMENUFONT "segoeui.ttf", 16
SETMENUTEXT -1
SETMENUUNDERSCORE 1
SETMENU3D FALSE, TRUE, TRUE, TRUE
SETMENUSHADOW 10
SETMENUSPACING 30
MAKEMENU
SETMENUSTATE 102, FALSE
SHOWMENU
Do
    Menu% = CHECKMENU%(TRUE)
Loop Until Menu% = 103
HIDEMENU
Data "&File","&Open...#CTRL+O","&Save#CTRL+S","-E&xit#CTRL+Q","*"
Data "&Help","&About...","*"
Data "!"

'$INCLUDE:'menu.bi'
