'******************************************************************************
'*                                                                            *
'* GLINPUT Library demo by Terry Ritchie 06/12/12                             *
'*                                                                            *
'* Written using GLINPUT library V2.01                                        *
'*                                                                            *
'******************************************************************************

'$INCLUDE:'glinputtop.bi'

CONST FALSE = 0, TRUE = NOT FALSE

WallPaper& = _NEWIMAGE(640, 528, 32)
_DEST WallPaper&
LINE (0, 0)-(639, 527), _RGB32(0, 0, 127), BF
FOR y% = 1 TO 11
    FOR x% = 1 TO 13
        CIRCLE (x% * 48 - 17, y% * 48 - 24), 24, _RGB32(0, 0, 0)
        PAINT (x% * 48 - 17, y% * 48 - 24), _RGB32(0, 0, 96), _RGB32(0, 0, 0)
    NEXT x%
NEXT y%
SCREEN _NEWIMAGE(640, 480, 32)
CLS
_SCREENMOVE _MIDDLE
_TITLE "Graphics Line Input Demo"
_PUTIMAGE (0, 0), WallPaper&
COLOR _RGB32(192, 192, 0)
LOCATE 2, 23
PRINT "PLEASE ENTER YOUR INFORMATION BELOW"
LOCATE 4, 23
PRINT "First Name: "
LOCATE 6, 23
PRINT "Last Name : "
LOCATE 8, 23
PRINT "Address   : "
LOCATE 10, 23
PRINT "City      : "
LOCATE 12, 23
PRINT "State     : "
LOCATE 14, 23
PRINT "Zip Code  : "
LOCATE 16, 23
PRINT "Phone     : "
LOCATE 18, 23
PRINT "Email     : "
LOCATE 20, 23
PRINT "Password  : "
LOCATE 22, 1
PRINT " Ah, the good old tried and true LINE INPUT command, what would we do without   "
PRINT " you? The way you force the rest of our programs to stop everything they are    "
PRINT " doing to do your bidding is just priceless. Go ahead, get the full experience  "
PRINT " now by entering some information and pressing ENTER after each and every line  "
PRINT " of input. The program will wait for you ... trust me :)                        "
LOCATE 28, 26
PRINT "You have entered 0 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT "  Notice how you can't even edit the line of text using the arrow keys? Shame.  ";
COLOR _RGB32(192, 192, 0)
LOCATE 4, 35
LINE INPUT FirstName$
LOCATE 28, 26
PRINT "You have entered 1 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " Why can't you use the UP/DOWN arrow keys to move between inputs? Would be nice.";
COLOR _RGB32(192, 192, 0)
LOCATE 6, 35
LINE INPUT LastName$
LOCATE 28, 26
PRINT "You have entered 2 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " Wouldn't it be handy if you could just press ESC to leave the inputs right now?";
COLOR _RGB32(192, 192, 0)
LOCATE 8, 35
LINE INPUT Address$
LOCATE 28, 26
PRINT "You have entered 3 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " The TAB key has been a staple of moving between inputs in Windows. Not here. :(";
COLOR _RGB32(192, 192, 0)
LOCATE 10, 35
LINE INPUT City$
LOCATE 28, 26
PRINT "You have entered 4 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " Pressing the INSERT key should change the cursor between INSERT and OVERWRITE! ";
COLOR _RGB32(192, 192, 0)
LOCATE 12, 35
LINE INPUT State$
LOCATE 28, 26
PRINT "You have entered 5 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " ZIP codes are only supposed to contain numbers. I dare you to enter a letter!  ";
COLOR _RGB32(192, 192, 0)
LOCATE 14, 35
LINE INPUT ZipCode$
LOCATE 28, 26
PRINT "You have entered 6 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " What a dull, boring, background image. It would look cool animated! Oh well. :(";
COLOR _RGB32(192, 192, 0)
LOCATE 16, 35
LINE INPUT Phone$
LOCATE 28, 26
PRINT "You have entered 7 of 9 lines"
COLOR _RGB32(255, 255, 255)
LOCATE 29, 1
PRINT " Ho-Hum, are you bored with this yet? There has got to be a better way, right?  ";
COLOR _RGB32(192, 192, 0)
LOCATE 18, 35
LINE INPUT Email$
LOCATE 28, 26
PRINT "You have entered 8 of 9 lines"
LOCATE 29, 1
COLOR _RGB32(255, 0, 0)
PRINT " CAREFUL! Make sure no one is looking while you type your super secret password!";
COLOR _RGB32(192, 192, 0)
LOCATE 20, 35
LINE INPUT Password$
FOR count% = 22 TO 29
    LOCATE count%, 1
    PRINT STRING$(80, 32);
NEXT count%
COLOR _RGB32(255, 255, 255)
LOCATE 23, 1
PRINT " PHEW! Now that that's over with let's apply a little bit of QB64 magic to LINE "
PRINT " INPUT shall we?"
PRINT
PRINT " Press any key when you are ready. Oh, by the way, I think someone saw your"
PRINT " super secret password THAT IS STILL ON THE SCREEN!"
DO: LOOP UNTIL INKEY$ = ""
DO: LOOP UNTIL INKEY$ <> ""
DO: LOOP UNTIL _KEYHIT = 0 ' ** GLI routines use _KEYHIT, clear it periodically
COLOR _RGB32(0, 255, 255)
Wow1% = GLIINPUT(248, 252, 7, "First Name: ", TRUE)
Wow2% = GLIINPUT(248, 272, 2, "Zip Code  : ", TRUE)
Wow3% = GLIINPUT(248, 292, 135, "Password  : ", TRUE)
count% = 0
DO
    _LIMIT 32
    IF count% > 511 THEN GLICLEAR '   *** MUST be at the top of each loop before any screen changes
    count% = count% + 1
    y% = y% - 1
    IF y% = -48 THEN y% = 0
    _PUTIMAGE (0, y%), WallPaper&
    COLOR _RGB32(255, 255, 255)
    IF count% > 63 THEN
        LOCATE 5, 34
        PRINT " ANIMATION! "
    END IF
    IF count% > 159 THEN
        LOCATE 7, 27
        PRINT "Ya, ok, easy to do in QB64"
    END IF
    IF count% > 255 THEN
        COLOR _RGB32(192, 192, 0)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 9, 24
        PRINT "Preserving the background image!"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF count% > 319 THEN
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 11, 12
        PRINT "I know, that's easy too with _PRINTMODE _KEEPBACKGROUND"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF count% > 415 THEN
        COLOR _RGB32(255, 255, 255)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 13, 26
        PRINT "Maybe this will impress you?"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF count% > 639 THEN
        COLOR _RGB32(255, 255, 255)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 21, 32
        PRINT "Pretty cool huh?"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF count% > 703 THEN
        COLOR _RGB32(255, 255, 0)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 23, 1
        PRINT "  Go ahead and type some text into each field. You can use the following keys:"
        PRINT "        HOME, END, INSERT, DELETE, ARROW KEYS, TAB, BACKSPACE, ENTER"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF count% > 1023 THEN
        COLOR _RGB32(255, 255, 0)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 29, 15
        PRINT "Press ESC when you are ready to leave this screen.";
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF GLIOUTPUT$(Wow3%) <> "" THEN
        COLOR _RGB32(0, 255, 255)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 26, 23
        PRINT "Your password will remain secret!!"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF GLIOUTPUT$(Wow2%) <> "" THEN
        COLOR _RGB32(0, 255, 255)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 28, 14
        PRINT "Notice how numbers can only be entered for ZIP code?"
        _PRINTMODE _FILLBACKGROUND
    END IF
    IF count% > 511 THEN
        COLOR _RGB32(255, 255, 255)
        _PRINTMODE _KEEPBACKGROUND
        LOCATE 15, 34
        PRINT "LINE INPUT!!"
        _PRINTMODE _FILLBACKGROUND
        GLIUPDATE '                   *** MUST be second to last line in any loop
    END IF
    _DISPLAY '                        *** MUST be last line in any loop
LOOP UNTIL INKEY$ = CHR$(27)
SuperSecretPassword$ = GLIOUTPUT$(Wow3%)
GLICLOSE 0, TRUE
DO: LOOP UNTIL INKEY$ = ""
DO: LOOP UNTIL _KEYHIT = 0 ' ** GLI routines use _KEYHIT, clear it periodically
Times26& = _LOADFONT("times.ttf", 26)
Times52& = _LOADFONT("times.ttf", 52)
Lucon16& = _LOADFONT("lucon.ttf", 16)
COLOR _RGB32(0, 255, 255)
_FONT Times26&
Wow1% = GLIINPUT(200, 242, 7, "First Name: ", TRUE)
COLOR _RGB32(255, 255, 0)
_FONT Lucon16&
Wow2% = GLIINPUT(200, 272, 2, "Zip Code  : ", TRUE)
COLOR _RGB(255, 0, 255)
_FONT Times52&
Wow3% = GLIINPUT(200, 292, 135, "Password  : ", TRUE)
count% = 0
DO
    _LIMIT 32
    IF count% > 191 THEN GLICLEAR
    count% = count% + 1
    y% = y% + 1
    IF y% = 1 THEN y% = -47
    _PUTIMAGE (0, y%), WallPaper&
    IF count% > 63 THEN
        COLOR _RGB32(255, 255, 255)
        _PRINTMODE _KEEPBACKGROUND
        _FONT Times52&
        LOCATE 2, 1
        PRINT "        But wait! That's not all!"
    END IF
    IF count% > 255 THEN
        COLOR _RGB32(255, 127, 0)
        _PRINTMODE _KEEPBACKGROUND
        _FONT Lucon16&
        LOCATE 28, 1
        PRINT " Press ESC or press ENTER on all three inputs to leave screen."
    END IF
    IF count% > 191 THEN
        COLOR _RGB32(0, 255, 0)
        _PRINTMODE _KEEPBACKGROUND
        _FONT Times26&
        LOCATE 6, 1
        PRINT "          Multiple fonts and colors supported at the same time!"
        GLIUPDATE
    END IF
    _DISPLAY
LOOP UNTIL INKEY$ = CHR$(27) OR GLIENTERED(0)
GLICLOSE 0, TRUE
count% = 0
_FONT 16
_FREEFONT Times26&
_FREEFONT Times52&
_FREEFONT Lucon16&
COLOR _RGB32(127, 255, 255)
_PRINTMODE _KEEPBACKGROUND
IF SuperSecretPassword$ = "" THEN
    SuperSecretPassword$ = "You didn't enter one! Good thing because I think Clippy was watching!"
END IF
passlocation% = 40 - LEN(SuperSecretPassword$) \ 2
DO
    _LIMIT 32
    count% = count% + 1
    y% = y% - 1
    IF y% = -48 THEN y% = 0
    _PUTIMAGE (0, y%), WallPaper&
    IF count% > 31 THEN
        LOCATE 2, 35
        PRINT "FEATURES"
    END IF
    IF count% > 63 THEN
        LOCATE 5, 2
        PRINT "- Multiple inputs, fonts and colors on the screen at the same time (GLIINPUT)"
    END IF
    IF count% > 95 THEN
        LOCATE 7, 2
        PRINT "- Inputs can stay on screen or disappear when finished with them (GLICLOSE)"
    END IF
    IF count% > 127 THEN
        LOCATE 9, 2
        PRINT "- Real-time monitoring of input fields (GLIOUTPUT$)"
    END IF
    IF count% > 159 THEN
        LOCATE 11, 2
        PRINT "- Inputs can save the background image or use solid background color"
    END IF
    IF count% > 191 THEN
        LOCATE 13, 2
        PRINT "- Monitor when the ENTER key has been pressed on one or all inputs (GLIENTERED)"
    END IF
    IF count% > 223 THEN
        LOCATE 15, 2
        PRINT "- Force the cursor to either the next or specific input field (GLIFORCE)"
    END IF
    IF count% > 351 THEN
        LOCATE 18, 35
        PRINT "BY THE WAY"
    END IF
    IF count% > 383 THEN
        LOCATE 20, 24
        PRINT "Your super secret password was:"
    END IF
    IF count% > 415 THEN
        LOCATE 22, passlocation%
        PRINT SuperSecretPassword$
    END IF
    IF count% > 479 THEN
        LOCATE 28, 12
        PRINT "Press ESC to exit this demo. Thank you for watching!  :)"
    END IF
    _DISPLAY
LOOP UNTIL INKEY$ = CHR$(27)
SYSTEM

'$INCLUDE:'glinput.bi'
