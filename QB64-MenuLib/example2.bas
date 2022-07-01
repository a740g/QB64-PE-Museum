'$INCLUDE:'menutop.bi'

Const FALSE = 0, TRUE = Not FALSE
Dim Menu%
Dim Menushowing%
Screen _NewImage(640, 480, 32)
Cls , _RGB32(50, 100, 200)
_ScreenMove _Middle
_MouseShow
MAKEMENU
Do
    While _MouseInput: Wend
    If (_MouseY < 2) And (GETMENUSHOWING% = FALSE) Then SHOWMENU
    If (_MouseY > GETMENUHEIGHT%) And (GETMENUACTIVE% = FALSE) And (GETMENUSHOWING% = TRUE) Then HIDEMENU
    Menu% = CHECKMENU%(TRUE)
Loop Until Menu% = 103
HIDEMENU
Data "&File","&Open...#CTRL+O","&Save#CTRL+S","-E&xit#CTRL+Q","*"
Data "&Help","&About...","*"
Data "!"

'$INCLUDE:'menu.bi'
