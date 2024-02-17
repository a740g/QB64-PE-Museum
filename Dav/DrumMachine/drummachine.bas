'=======================
'DRUMMACHINE.BAS - v0.1d
'=======================
'QB64 Drum machine
'Make drum beats using 16 drum sounds.
'Coded by Dav for QB64, MAY/2022

'===================================================================
'New in v0.1d...

'fixed: clicking mouse doesn't stutter/pause playback anymore.

'===================================================================
''NOTE: You need "\drummachine-data\" and all of its data files!
'===================================================================

'=====
'ABOUT:
'=====

'This is a very basic drum machine with limited capabilities.
'With it you can program beats (limited to 2 bars of 4/4 now).
'It uses 16 real drum sounds to make a real sound drum beat.
'Drum patterns can be saved and loaded by file DRUMMACHINE.SAV.
'I just wanted to see if QB64 can handle something like this,
'and it looks like it can.  So a more serious program can be tackled.
'The real drum sound samples were all found in public domain.

'==========
'HOW TO USE:
'==========

'The grid represents bars and notes that you can click on.
'Click on squares in a row to to add sound for that beat.
'Click an square again to turn it back off or change it's volume.
'A bright red square is loudest, a darker red is softer volume.

'Click on the instrument name on left screen to mute/unmute it.

'The following keys can be used as well:

'* +/- keys:  Speeds up and slow down tempo (shown upper left)
'* SPACE key: Will pause and resume the playback.
'* ENTER:     Resets current playback marker to the beginning.
'* M:         Turns on/off metonome click sound (default is on)
'* C:         Clears the playing grid (starts over).
'* L:         Loads last saved grid pattern from DRUMMACHINE.SAV
'* S:         Saves current grid pattern to DRUMMACHINE.SAV.
'* D:         Enters drawing mode (fast filling of boxes.
'             (While in it, enter ESC to exit drawing mode)
'* ESC:       Exits program. DOES NOT ATUMATICALLY SAVE ON EXIT.

'======================================================================

$EXEICON:'.\drummachine.ico'
_ICON

'define playing grid and button deminsions
DIM SHARED row: row = 16 'rows in playing grid
DIM SHARED col: col = 8 * 4 'columns in grid (8 beats, 4 boxes per beat)
DIM SHARED size: size = 30 ' pixel size of buttons
DIM SHARED buttons: buttons = row * col ' total number of buttons on playing grid

'define button data
DIM SHARED buttonv(row * col) ' num data for button
DIM SHARED buttonx(row * col), buttony(row * col) 'top x/y cords of buttons
DIM SHARED buttonx2(row * col), buttony2(row * col) ' bottom x/y cords of buttons

'define intrument name data
DIM SHARED instv(row * col) 'value for is intrument on or off
DIM SHARED instx(row * col), insty(row * col) 'top x/y cords of instr names

'share these sound files
DIM SHARED crash&, crash2&, ride&, ride2&, hhopen&, hhclosed&, snare&, kick&, tamb&, gong2&
DIM SHARED tomhigh&, tommid&, tomlow&, cowbell&, shaker&, gong&, vibraslap&, vibraslap2&
DIM SHARED clave&, trianglelong&, triangleshort&

'====================================================

'Set screen based on grid deminsions

SCREEN _NEWIMAGE(size * col + 100, size * row + 100, 32)
DO: LOOP UNTIL _SCREENEXISTS 'Make sure window exists before TITLE used.

_TITLE "QB64 Drum Machine"

'===================================================

CLS , _RGB(42, 42, 42)

'Load title top area.
ttmp = _LOADIMAGE("drummachine-data\title.png")
_PUTIMAGE (5, 5), ttmp: _FREEIMAGE ttmp

'Load media sounds used
click& = _SNDOPEN("drummachine-data\click.ogg")
hhopen& = _SNDOPEN("drummachine-data\hhopen.ogg")
hhclosed& = _SNDOPEN("drummachine-data\hhclosed.ogg")
kick& = _SNDOPEN("drummachine-data\kick.ogg")
snare& = _SNDOPEN("drummachine-data\snare.ogg")
crash& = _SNDOPEN("drummachine-data\crash.ogg")
crash2& = _SNDOPEN("drummachine-data\crash.ogg")
ride& = _SNDOPEN("drummachine-data\ride.ogg")
ride2& = _SNDOPEN("drummachine-data\ride.ogg")
tomhigh& = _SNDOPEN("drummachine-data\tomhigh.ogg")
tommid& = _SNDOPEN("drummachine-data\tommid.ogg")
tomlow& = _SNDOPEN("drummachine-data\tomlow.ogg")
cowbell& = _SNDOPEN("drummachine-data\cowbell.ogg")
shaker& = _SNDOPEN("drummachine-data\shaker.ogg")
vibraslap& = _SNDOPEN("drummachine-data\vibraslap.ogg")
gong& = _SNDOPEN("drummachine-data\gong.ogg")
vibraslap2& = _SNDOPEN("drummachine-data\vibraslap.ogg")
gong2& = _SNDOPEN("drummachine-data\gong.ogg")
tamb& = _SNDOPEN("drummachine-data\tamb.ogg")
clave& = _SNDOPEN("drummachine-data\clave.ogg")
trianglelong& = _SNDOPEN("drummachine-data\trianglelong.ogg")
triangleshort& = _SNDOPEN("drummachine-data\triangleshort.ogg")

'Load special number font images fro BMP display
DIM SHARED num&(0 TO 9)
FOR t = 0 TO 9
    n$ = LTRIM$(RTRIM$(STR$(t)))
    num&(t) = _LOADIMAGE("drummachine-data\font\" + n$ + ".png")
NEXT


'===================================================

'Set program defaults

beats = 8 'number of beats in pattern
tempo = 80 'tempo of drum pattern
curbeat = 1 'start at bar 1
clickon = 1 'turn on click sound, on the beat
playing = 1 'Pattern is playing
firstlaunch = 1 'flag to know when program first launches


'=========================================================
START:
'========

'Init the grids button values (x/y, data)
bc = 1 'counter
FOR r = 1 TO row
    FOR c = 1 TO col
        x = (c * size) + 100: y = (r * size) + 100
        buttonx(bc) = x - size: buttonx2(bc) = x ' generate x/y values
        buttony(bc) = y - size: buttony2(bc) = y
        buttonv(bc) = 0 'default button is OFF
        bc = bc + 1
    NEXT
NEXT

'Show metronome on/off
Metronome clickon

'Show the grid buttons
bc = 1
FOR r = 1 TO row
    FOR c = 1 TO col
        Show "drummachine-data\off.jpg", buttonx(bc), buttony(bc), 0
        bc = bc + 1
    NEXT
NEXT


'Draw beat lines, every 4 squares ...
bc = 1
FOR c = 1 TO col STEP 4
    LINE (buttonx(bc), buttony(bc))-(buttonx(bc), buttony(bc) + (size * row)), _RGB(128, 128, 0), B
    bc = bc + 4
NEXT

'====================================

'Init Instrument name data
FOR c = 1 TO 16
    instv(c) = 1 'all instruments on by default
NEXT
bc = 1
FOR c = 1 TO col * row STEP col
    instx(bc) = 0: insty(bc) = 70 + (bc * 30)
    bc = bc + 1
NEXT
'show the nstrument names
FOR c = 1 TO 16
    ShowInst c, instx(c), insty(c)
NEXT

'==============================================

'Show current TEMPO (BMP) on upper left
FPRINT 140, 15, 20, 40, LTRIM$(RTRIM$(STR$(tempo)))

'================================================

'If firstlaunch, load the saved pattern file
IF firstlaunch = 1 THEN
    firstlaunch = 0
    GOSUB loadfile
END IF

'============================================================

MAIN:
'=====

'Main Loop here
DO

    mi = _MOUSEINPUT: IF _MOUSEBUTTON(1) = 0 THEN stilldown = 0

    GOSUB GetUserInput

    IF playing THEN

        IF clickon THEN
            SELECT CASE curbeat
                CASE 1, 2, 3, 4, 5, 6, 7, 8: _SNDPLAY click&
            END SELECT
        END IF

        IF curbeat = 1 THEN PlayBeat (1)
        IF curbeat = 1.25 THEN PlayBeat (2)
        IF curbeat = 1.50 THEN PlayBeat (3)
        IF curbeat = 1.75 THEN PlayBeat (4)
        IF curbeat = 2 THEN PlayBeat (5)
        IF curbeat = 2.25 THEN PlayBeat (6)
        IF curbeat = 2.50 THEN PlayBeat (7)
        IF curbeat = 2.75 THEN PlayBeat (8)
        IF curbeat = 3 THEN PlayBeat (9)
        IF curbeat = 3.25 THEN PlayBeat (10)
        IF curbeat = 3.50 THEN PlayBeat (11)
        IF curbeat = 3.75 THEN PlayBeat (12)
        IF curbeat = 4 THEN PlayBeat (13)
        IF curbeat = 4.25 THEN PlayBeat (14)
        IF curbeat = 4.50 THEN PlayBeat (15)
        IF curbeat = 4.75 THEN PlayBeat (16)
        IF curbeat = 5 THEN PlayBeat (17)
        IF curbeat = 5.25 THEN PlayBeat (18)
        IF curbeat = 5.50 THEN PlayBeat (19)
        IF curbeat = 5.75 THEN PlayBeat (20)
        IF curbeat = 6 THEN PlayBeat (21)
        IF curbeat = 6.25 THEN PlayBeat (22)
        IF curbeat = 6.50 THEN PlayBeat (23)
        IF curbeat = 6.75 THEN PlayBeat (24)
        IF curbeat = 7 THEN PlayBeat (25)
        IF curbeat = 7.25 THEN PlayBeat (26)
        IF curbeat = 7.50 THEN PlayBeat (27)
        IF curbeat = 7.75 THEN PlayBeat (28)
        IF curbeat = 8 THEN PlayBeat (29)
        IF curbeat = 8.25 THEN PlayBeat (30)
        IF curbeat = 8.50 THEN PlayBeat (31)
        IF curbeat = 8.75 THEN PlayBeat (32)

        curbeat = curbeat + .25
        IF curbeat > beats + .75 THEN curbeat = 1

        'Delay routine, based on TEMP
        d1 = TIMER
        DO
            d2 = TIMER

            mi = _MOUSEINPUT
            IF _MOUSEBUTTON(1) = 0 THEN stilldown = 0

            'still get user input while delaying....
            GOSUB GetUserInput

        LOOP UNTIL d2 - d1 >= (60 / 4 / tempo)

    END IF

LOOP

'===============================

EndProgram:

_SNDCLOSE click&
_SNDCLOSE hhopen&
_SNDCLOSE hhclosed&
_SNDCLOSE kick&
_SNDCLOSE snare&
_SNDCLOSE crash&
_SNDCLOSE crash2&
_SNDCLOSE ride&
_SNDCLOSE ride2&
_SNDCLOSE tomhigh&
_SNDCLOSE tommid&
_SNDCLOSE tomlow&
_SNDCLOSE cowbell&
_SNDCLOSE shaker&
_SNDCLOSE vibraslap&
_SNDCLOSE gong&
_SNDCLOSE vibraslap2&
_SNDCLOSE gong2&
_SNDCLOSE tamb&
_SNDCLOSE clave&
_SNDCLOSE trianglelong&
_SNDCLOSE triangleshort&

END



'================================================
GetUserInput:
'============

IF stilldown = 0 THEN

    trap = _MOUSEINPUT

    'if left mouse button clicked
    IF _MOUSEBUTTON(1) OR _MOUSEBUTTON(2) THEN

        stilldown = 1

        mx = _MOUSEX: my = _MOUSEY 'current mouse position

        'see if a grid button was pressed
        FOR t = 1 TO buttons
            bx = buttonx(t): bx2 = buttonx2(t)
            by = buttony(t): by2 = buttony2(t)

            'If clicked on a grid button...
            IF mx >= bx AND mx <= bx2 AND my >= by AND my <= by2 THEN
                IF _MOUSEBUTTON(1) THEN

                    'change its value...
                    buttonv(t) = buttonv(t) + 1
                    IF buttonv(t) > 2 THEN buttonv(t) = 0
                    'LOCATE 1, 1: PRINT t   'for testing purposes...
                    SELECT CASE buttonv(t)
                        CASE 0: Show "drummachine-data\off.jpg", buttonx(t), buttony(t), 0
                        CASE 1: Show "drummachine-data\hot.jpg", buttonx(t), buttony(t), 0
                        CASE 2: Show "drummachine-data\med.jpg", buttonx(t), buttony(t), 0
                    END SELECT
                ELSE
                    buttonv(t) = 0
                    Show "drummachine-data\off.jpg", buttonx(t), buttony(t), 0
                END IF

            END IF
        NEXT

        'see if a instrument name was pressed
        FOR t = 1 TO 16
            bx = instx(t): bx2 = instx(t) + 100
            by = insty(t): by2 = insty(t) + 30

            'If clicked on an instrument name...
            IF mx >= bx AND mx <= bx2 AND my >= by AND my <= by2 THEN
                IF _MOUSEBUTTON(1) THEN

                    'change its value...
                    instv(t) = instv(t) + 1
                    IF instv(t) > 1 THEN instv(t) = 0
                    'redraw instrument name here
                    ShowInst t, instx(t), insty(t)
                END IF

            END IF
        NEXT


        'IF _MOUSEBUTTON(1) THEN
        '    'wait until mouse button up to continue
        'WHILE _MOUSEBUTTON(1) <> 0: n = _MOUSEINPUT: WEND
        'END IF

    END IF

END IF


'check is user made a keypress

SELECT CASE UCASE$(INKEY$)

    CASE "D": 'd enters drawing mode
        DO
            trap = _MOUSEINPUT
            IF _MOUSEBUTTON(1) OR _MOUSEBUTTON(2) THEN
                mx = _MOUSEX: my = _MOUSEY
                'see if a button was pressed
                FOR t = 1 TO buttons
                    bx = buttonx(t): bx2 = buttonx2(t)
                    by = buttony(t): by2 = buttony2(t)
                    IF mx >= bx AND mx <= bx2 AND my >= by AND my <= by2 THEN
                        IF _MOUSEBUTTON(1) THEN
                            buttonv(t) = 1
                            Show "drummachine-data\hot.jpg", buttonx(t), buttony(t), 0
                        ELSE
                            buttonv(t) = 0
                            Show "drummachine-data\off.jpg", buttonx(t), buttony(t), 0
                        END IF
                    END IF
                NEXT
            END IF
        LOOP UNTIL INKEY$ = CHR$(27)

    CASE "C": GOTO START 'C clears playing grid, starts over

    CASE "S": 's = saves current pattern to file
        backtmp& = _COPYIMAGE(_DISPLAY)
        f$ = "drummachine-data\savingpattern.png"
        ttmp = _LOADIMAGE(f$)
        _PUTIMAGE (350, 250), ttmp: _FREEIMAGE ttmp
        _DELAY 1
        OPEN "drummachine.sav" FOR OUTPUT AS #3
        PRINT #3, MKI$(tempo);
        PRINT #3, MKI$(buttons);
        FOR fs = 1 TO buttons
            PRINT #3, MKI$(buttonv(fs));
        NEXT
        CLOSE #3
        _PUTIMAGE (0, 0), backtmp&

    CASE "L"
        backtmp& = _COPYIMAGE(_DISPLAY)
        f$ = "drummachine-data\loadingpattern.png"
        ttmp = _LOADIMAGE(f$)
        _PUTIMAGE (350, 250), ttmp: _FREEIMAGE ttmp
        _DELAY .5
        _PUTIMAGE (0, 0), backtmp&
        GOSUB loadfile

    CASE " " 'SPACE pauses and resumes playing
        IF playing = 1 THEN
            playing = 0
        ELSE
            playing = 1
        END IF

    CASE CHR$(13) 'ENTER resets marker to beginning
        'erase all marker positions
        FOR e = 1 TO 32
            SELECT CASE e
                CASE 1, 5, 9, 13, 17, 21, 25, 29
                    LINE (buttonx(e), buttony(e))-(buttonx(e), buttony(e) + (size * row)), _RGB(128, 128, 0), B
                CASE ELSE
                    LINE (buttonx(e), buttony(e))-(buttonx(e), buttony(e) + (size * row)), _RGB(0, 0, 0), B
            END SELECT
        NEXT
        LINE (buttonx(1), buttony(1))-(buttonx(1), buttony(1) + (size * row)), _RGB(0, 255, 128), B
        curbeat = 1: GOTO MAIN

    CASE "M" 'm = turn metronome click on/off
        IF clickon = 1 THEN
            clickon = 0
        ELSE
            clickon = 1
        END IF
        Metronome clickon

    CASE "+": tempo = tempo + 1: IF tempo > 280 THEN tempo = 280
        FPRINT 140, 15, 20, 40, LTRIM$(RTRIM$(STR$(tempo)))

    CASE "-": tempo = tempo - 1: IF tempo < 40 THEN tempo = 40
        FPRINT 140, 15, 20, 40, LTRIM$(RTRIM$(STR$(tempo)))
    CASE CHR$(27): GOTO EndProgram

END SELECT

RETURN


'=================================================================

loadfile: 'Loads pattern from save file
'=======

fil$ = "drummachine.sav"
IF _FILEEXISTS(fil$) THEN
    OPEN fil$ FOR BINARY AS #3
    IF LOF(3) <= 1028 THEN
        tempo = CVI(INPUT$(2, 3))
        bb = CVI(INPUT$(2, 3))
        FOR b = 1 TO bb
            buttonv(b) = CVI(INPUT$(2, 3))
            SELECT CASE buttonv(b)
                CASE 0: Show "drummachine-data\off.jpg", buttonx(b), buttony(b), 0
                CASE 1: Show "drummachine-data\hot.jpg", buttonx(b), buttony(b), 0
                CASE 2: Show "drummachine-data\med.jpg", buttonx(b), buttony(b), 0
            END SELECT
        NEXT
        CLOSE 3
        'Show current TEMPO (BMP) on upper left
        FPRINT 140, 15, 20, 40, LTRIM$(RTRIM$(STR$(tempo)))
        GOTO MAIN
    ELSE
        CLOSE 3
        'print error message here
    END IF
END IF

RETURN

'========================================================

SUB Show (nam$, x, y, dly)
    'Loads & puts image filename img$ on screen at x,y
    'dly is optional delay after putting image on screen
    'SUB frees up image handle after loading file.
    ttmp = _LOADIMAGE(nam$)
    _PUTIMAGE (x + 1, y + 1)-(x - 1 + size - 1, y - 1 + size - 1), ttmp: _FREEIMAGE ttmp
    IF dly <> 0 THEN _DELAY dly
END SUB

'===============================================

SUB ShowInst (num, x, y)
    'This SUB loads the instrumet name image files
    src$ = "drummachine-data\"
    IF instv(num) = 1 THEN pre$ = "_" ELSE pre$ = ""
    IF num = 1 THEN n$ = pre$ + "crash.png"
    IF num = 2 THEN n$ = pre$ + "ride.png"
    IF num = 3 THEN n$ = pre$ + "hhopen.png"
    IF num = 4 THEN n$ = pre$ + "hhclosed.png"
    IF num = 5 THEN n$ = pre$ + "tomhigh.png"
    IF num = 6 THEN n$ = pre$ + "tommid.png"
    IF num = 7 THEN n$ = pre$ + "tomlow.png"
    IF num = 8 THEN n$ = pre$ + "snare.png"
    IF num = 9 THEN n$ = pre$ + "kick.png"
    IF num = 10 THEN n$ = pre$ + "cowbell.png"
    IF num = 11 THEN n$ = pre$ + "shaker.png"
    IF num = 12 THEN n$ = pre$ + "tambourine.png"
    IF num = 13 THEN n$ = pre$ + "vibraslap.png"
    IF num = 14 THEN n$ = pre$ + "gong.png"
    IF num = 15 THEN n$ = pre$ + "triangle.png"
    IF num = 16 THEN n$ = pre$ + "clave.png"

    fil$ = src$ + n$
    ttmp = _LOADIMAGE(fil$)
    _PUTIMAGE (x, y), ttmp: _FREEIMAGE ttmp
END SUB

'===============================================

SUB PlayBeat (num)
    'This SUB plays the sounds on current beat position.
    'It also shows the playing marker moving across the grid

    'erase previous marker pos displayed first, and redraw the 4 beat lines...
    IF num = 1 THEN
        'erase the end playing position on grid
        LINE (buttonx(col), buttony(col))-(buttonx(col), buttony(col) + (size * row)), _RGB(0, 0, 0), B
    ELSE
        'erase the last beat position
        LINE (buttonx(num - 1), buttony(num - 1))-(buttonx(num - 1), buttony(num - 1) + (size * row)), _RGB(0, 0, 0), B
        'if last position was one of the 4 beat lines, redraw it
        SELECT CASE (num - 1)
            CASE 1, 5, 9, 13, 17, 21, 25, 29
                LINE (buttonx(num - 1), buttony(num - 1))-(buttonx(num - 1), buttony(num - 1) + (size * row)), _RGB(128, 128, 0), B
        END SELECT
    END IF

    'Show curreny marker position
    'Now Draw current playing position beat line
    LINE (buttonx(num), buttony(num))-(buttonx(num), buttony(num) + (size * row)), _RGB(0, 255, 128), B

    'Play sounds on the current beat position, if inst not muted
    'play crash
    IF instv(1) = 1 THEN
        IF buttonv(num) = 1 THEN _SNDVOL crash&, 6: _SNDPLAY crash& '1
        IF buttonv(num) = 2 THEN _SNDVOL crash2&, .2: _SNDPLAY crash2& '1
    END IF
    'play ride
    IF instv(2) = 1 THEN
        IF buttonv(num + (col * 1)) = 1 THEN _SNDVOL ride&, 5: _SNDPLAY ride& '2
        IF buttonv(num + (col * 1)) = 2 THEN _SNDVOL ride2&, .2: _SNDPLAY ride2& '2
    END IF
    'play hhopen
    IF instv(3) = 1 THEN
        IF buttonv(num + (col * 2)) = 1 THEN _SNDSETPOS hhopen&, 0: _SNDVOL hhopen&, 5: _SNDPLAY hhopen& '3
        IF buttonv(num + (col * 2)) = 2 THEN _SNDSETPOS hhopen&, 0: _SNDVOL hhopen&, .15: _SNDPLAY hhopen& '3
    END IF
    'play hhclosed
    IF instv(4) = 1 THEN
        IF buttonv(num + (col * 3)) = 1 THEN _SNDSTOP hhopen&: _SNDVOL hhclosed&, 1: _SNDPLAY hhclosed& '4
        IF buttonv(num + (col * 3)) = 2 THEN _SNDSTOP hhopen&: _SNDVOL hhclosed&, .2: _SNDPLAY hhclosed& '4
    END IF
    'play tom high
    IF instv(5) THEN
        IF buttonv(num + (col * 4)) = 1 THEN _SNDVOL tomhigh&, 9: _SNDPLAY tomhigh& '5
        IF buttonv(num + (col * 4)) = 2 THEN _SNDVOL tomhigh&, .1: _SNDPLAY tomhigh& '5
    END IF
    'play tom mid
    IF instv(6) THEN
        IF buttonv(num + (col * 5)) = 1 THEN _SNDVOL tommid&, 9: _SNDPLAY tommid& '6
        IF buttonv(num + (col * 5)) = 2 THEN _SNDVOL tommid&, .1: _SNDPLAY tommid& '6
    END IF
    'play tom low
    IF instv(7) THEN
        IF buttonv(num + (col * 6)) = 1 THEN _SNDVOL tomlow&, 9: _SNDPLAY tomlow& '7
        IF buttonv(num + (col * 6)) = 2 THEN _SNDVOL tomlow&, .1: _SNDPLAY tomlow& '7
    END IF
    'play snare
    IF instv(8) THEN
        IF buttonv(num + (col * 7)) = 1 THEN _SNDVOL snare&, 1: _SNDPLAY snare& '8
        IF buttonv(num + (col * 7)) = 2 THEN _SNDVOL snare&, .1: _SNDPLAY snare& '8
    END IF
    'play kick
    IF instv(9) THEN
        IF buttonv(num + (col * 8)) = 1 THEN _SNDVOL kick&, 1: _SNDPLAY kick& '9
        IF buttonv(num + (col * 8)) = 2 THEN _SNDVOL kick&, .1: _SNDPLAY kick& '9
    END IF
    'play cowbell
    IF instv(10) THEN
        IF buttonv(num + (col * 9)) = 1 THEN _SNDVOL cowbell&, .3: _SNDPLAY cowbell& '10
        IF buttonv(num + (col * 9)) = 2 THEN _SNDVOL cowbell&, .02: _SNDPLAY cowbell& '10
    END IF
    'play shaker
    IF instv(11) THEN
        IF buttonv(num + (col * 10)) = 1 THEN _SNDVOL shaker&, .6: _SNDPLAY shaker& '11
        IF buttonv(num + (col * 10)) = 2 THEN _SNDVOL shaker&, .1: _SNDPLAY shaker& '11
    END IF
    'play tambourine
    IF instv(12) THEN
        IF buttonv(num + (col * 11)) = 1 THEN _SNDVOL tamb&, 1: _SNDPLAY tamb& '12
        IF buttonv(num + (col * 11)) = 2 THEN _SNDVOL tamb&, .1: _SNDPLAY tamb& '12
    END IF
    'play vibraslap
    IF instv(13) THEN
        IF buttonv(num + (col * 12)) = 1 THEN _SNDVOL vibraslap&, .1: _SNDPLAY vibraslap& '13
        IF buttonv(num + (col * 12)) = 2 THEN _SNDVOL vibraslap2&, .05: _SNDPLAY vibraslap2& '13
    END IF
    'play gong
    IF instv(14) THEN
        IF buttonv(num + (col * 13)) = 1 THEN _SNDVOL gong&, .1: _SNDPLAY gong& '14
        IF buttonv(num + (col * 13)) = 2 THEN _SNDVOL gong2&, .03: _SNDPLAY gong2& '14
    END IF
    'play triangle
    IF instv(15) THEN
        IF buttonv(num + (col * 14)) = 1 THEN _SNDVOL trianglelong&, .3: _SNDPLAY trianglelong& '15
        IF buttonv(num + (col * 14)) = 2 THEN _SNDVOL triangleshort&, .3: _SNDPLAY triangleshort& '15
    END IF
    'play clave
    IF instv(16) THEN
        IF buttonv(num + (col * 15)) = 1 THEN _SNDVOL clave&, .6: _SNDPLAY clave& '16
        IF buttonv(num + (col * 15)) = 2 THEN _SNDVOL clave&, .02: _SNDPLAY clave& '16
    END IF
END SUB

SUB FPRINT (x, y, xsize, ysize, num$)
    LINE (x, y)-(x + 100, y + ysize), _RGB(42, 42, 42), BF
    FOR t = 1 TO LEN(num$)
        n = VAL(MID$(num$, t, 1))
        _PUTIMAGE (x, y)-(x + xsize, y + ysize), num&(n)
        x = x + xsize: y = y + zsize
    NEXT
END SUB

SUB Metronome (way)
    IF way = 1 THEN
        f$ = "drummachine-data\metron.png"
    ELSE
        f$ = "drummachine-data\metroff.png"
    END IF
    ttmp = _LOADIMAGE(f$)
    _PUTIMAGE (875, 72), ttmp: _FREEIMAGE ttmp
END SUB


