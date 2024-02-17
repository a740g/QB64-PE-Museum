'******************************************************************************
'* RITCHIE'S QB64 BUTTON LIBRARY Demo Program                                 *
'*                                                                            *
'* Highlights some of the ways to use the button library                      *
'*                                                                            *
'* This program is just a very quick hack to show some of the features.       *
'******************************************************************************

'$INCLUDE: 'RQBLTOP.BI'

CONST false = 0, true = NOT false
CONST turnoff = false, turnon = true

DIM buttonarray%(20)
DIM background&
DIM font&
DIM button%
DIM x%, y%, xdir%, ydir%
DIM count%

SCREEN _NEWIMAGE(800, 600, 32)
_SCREENMOVE _MIDDLE
_MOUSESHOW
background& = _LOADIMAGE("backg.png", 32)
_PUTIMAGE (0, 0), background&
font& = _LOADFONT("lucon.ttf", 32, "MONOSPACE")
_FONT font&
'_PRINTMODE _KEEPBACKGROUND
COLOR _RGB(0, 0, 0), _RGB(255, 230, 146)
CenterText "To move onto the next screen while in", "this demo program simply press any key."
DO: LOOP UNTIL INKEY$ <> ""
_PUTIMAGE (0, 0), background&
CenterText "A single button loaded from a file set.", "Use your mouse to interact with it."
button% = BUTTONNEW("big", 225, 225, _RGB(127, 127, 127))
x% = (800 - BUTTONWIDTH(button%)) \ 2
y% = (600 - BUTTONHEIGHT(button%)) \ 2
BUTTONPUT x%, y%, button%
DO
    BUTTONUPDATE
    SELECT CASE BUTTONEVENT(button%)
        CASE 0
            LOCATE 5, 14
            PRINT "NO INTERACTION";
            BUTTONOFF button%
        CASE 1
            LOCATE 5, 14
            PRINT " LEFT BUTTON  ";
            BUTTONON button%
        CASE 2
            LOCATE 5, 14
            PRINT " RIGHT BUTTON ";
            BUTTONON button%
        CASE 3
            LOCATE 5, 14
            PRINT "   HOVERING   ";
            BUTTONOFF button%
    END SELECT
    _DISPLAY
LOOP UNTIL INKEY$ <> ""
_AUTODISPLAY
BUTTONFREE button%
_PUTIMAGE (0, 0), background&
CenterText "You can interact while its moving.", "Use your mouse to interact with it."
button% = BUTTONNEW("bigt", 225, 255, _RGB(127, 127, 127))
xdir% = 1: ydir% = 1
BUTTONCHECKING turnon
DO
    _LIMIT 128
    BUTTONPUT x%, y%, button%
    x% = x% + xdir%
    IF x% = 0 OR x% = 799 - BUTTONWIDTH(button%) THEN xdir% = -xdir%
    y% = y% + ydir%
    IF y% = 0 OR y% = 599 - BUTTONHEIGHT(button%) THEN ydir% = -ydir%
    SELECT CASE BUTTONEVENT(button%)
        CASE 0
            LOCATE 5, 14
            PRINT "NO INTERACTION";
            BUTTONOFF button%
        CASE 1
            LOCATE 5, 14
            PRINT " LEFT BUTTON  ";
            BUTTONON button%
        CASE 2
            LOCATE 5, 14
            PRINT " RIGHT BUTTON ";
            BUTTONON button%
        CASE 3
            LOCATE 5, 14
            PRINT "   HOVERING   ";
            BUTTONOFF button%
    END SELECT
    _DISPLAY
LOOP UNTIL INKEY$ <> ""
_AUTODISPLAY
BUTTONCHECKING turnoff
BUTTONFREE button%
_PUTIMAGE (0, 0), background&
button% = BUTTONNEW("goldt", 0, 0, 0)
FOR count% = 1 TO 18
    buttonarray%(count%) = BUTTONCOPY(button%)
NEXT count%
BUTTONFREE button%
FOR count% = 1 TO 6
    BUTTONPUT 10 + ((count% - 1) * 130), 100, buttonarray%(count%)
    BUTTONPUT 10 + ((count% - 1) * 130), 230, buttonarray%(count% + 6)
    BUTTONPUT 10 + ((count% - 1) * 130), 360, buttonarray%(count% + 12)
NEXT count%
CenterText "Button arrays can easily be created", "with the use of BUTTONCOPY."
BUTTONCHECKING turnon
DO
    FOR count% = 1 TO 18
        IF BUTTONEVENT(buttonarray%(count%)) = 0 THEN
            BUTTONOFF buttonarray%(count%)
        ELSE
            BUTTONON buttonarray%(count%)
        END IF
    NEXT count%
    _DISPLAY
LOOP UNTIL INKEY$ <> ""
BUTTONCHECKING turnoff
_AUTODISPLAY
_MOUSEHIDE
FOR count% = 18 TO 1 STEP -1
    BUTTONFREE buttonarray%(count%)
NEXT count%
SYSTEM

'##############################################################################

SUB CenterText (text1$, text2$)

_PRINTSTRING ((800 - _PRINTWIDTH(text1$)) \ 2, 530), text1$
_PRINTSTRING ((800 - _PRINTWIDTH(text2$)) \ 2, 565), text2$

END SUB

'##############################################################################

'$INCLUDE: 'RQBL.BI'
