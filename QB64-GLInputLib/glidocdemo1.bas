'$INCLUDE:'glinputtop.bi'

CONST FALSE = 0, TRUE = NOT FALSE

DIM helloworld%
DIM helloworld$
DIM wallpaper&
DIM x%, y%

wallpaper& = _NEWIMAGE(640, 528, 32) ' create image to use as background
_DEST wallpaper&
LINE (0, 0)-(639, 527), _RGB32(0, 0, 127), BF
FOR y% = 1 TO 11
    FOR x% = 1 TO 13
        CIRCLE (x% * 48 - 17, y% * 48 - 24), 24, _RGB32(0, 0, 0)
        PAINT (x% * 48 - 17, y% * 48 - 24), _RGB32(0, 0, 96), _RGB32(0, 0, 0)
    NEXT x%
NEXT y%
SCREEN _NEWIMAGE(640, 480, 32)
_PUTIMAGE (0, 0), wallpaper& '         show background image
y% = 0
helloworld% = GLIINPUT(100, 100, GLIALPHA, "Hello World: ", TRUE)
DO
    GLICLEAR '  must be first command in any loop
    _LIMIT 32
    y% = y% - 1
    IF y% = -48 THEN y% = 0
    _PUTIMAGE (0, y%), wallpaper&
    LOCATE 1, 1
    PRINT "Real time: "; GLIOUTPUT$(helloworld%); " "

    GLIUPDATE ' must be the second to last command in any loop
    _DISPLAY '  must be the last command in any loop to display results
LOOP UNTIL GLIENTERED(helloworld%)
helloworld$ = GLIOUTPUT$(helloworld%)
LOCATE 2, 1
PRINT "Final    : "; helloworld$
GLICLOSE helloworld%, TRUE

'$INCLUDE:'glinput.bi'

