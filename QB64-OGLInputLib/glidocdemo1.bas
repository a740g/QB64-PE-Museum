'$INCLUDE:'glinputtop.bi'

Const FALSE = 0, TRUE = Not FALSE

Dim helloworld%
Dim helloworld$
Dim wallpaper&
Dim x%, y%

wallpaper& = _NewImage(640, 528, 32) ' create image to use as background
_Dest wallpaper&
Line (0, 0)-(639, 527), _RGB32(0, 0, 127), BF
For y% = 1 To 11
    For x% = 1 To 13
        Circle (x% * 48 - 17, y% * 48 - 24), 24, _RGB32(0, 0, 0)
        Paint (x% * 48 - 17, y% * 48 - 24), _RGB32(0, 0, 96), _RGB32(0, 0, 0)
    Next x%
Next y%
Screen _NewImage(640, 480, 32)
_PutImage (0, 0), wallpaper& '         show background image
y% = 0
helloworld% = GLIINPUT(100, 100, GLIALPHA, "Hello World: ", TRUE)
Do
    GLICLEAR '  must be first command in any loop
    _Limit 32
    y% = y% - 1
    If y% = -48 Then y% = 0
    _PutImage (0, y%), wallpaper&
    Locate 1, 1
    Print "Real time: "; GLIOUTPUT$(helloworld%); " "

    GLIUPDATE ' must be the second to last command in any loop
    _Display '  must be the last command in any loop to display results
Loop Until GLIENTERED(helloworld%)
helloworld$ = GLIOUTPUT$(helloworld%)
Locate 2, 1
Print "Final    : "; helloworld$
GLICLOSE helloworld%, TRUE

'$INCLUDE:'glinput.bi'

