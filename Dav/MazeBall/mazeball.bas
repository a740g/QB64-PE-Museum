'============
'MAZEBALL.BAS v1.2
'============
'Clone of the Tilt Maze Puzzle games.
'QB64 code by Dav, AUG/2020

'New for v1.2: * Screen sizes to fit users desktop
'              * New ball, small code fixes.
'
'=====
'ABOUT:
'=====

'The goal is to move the ball to the star.
'Use arrows to move the ball.  Walls will stop
'the ball moving so navigate around them.
'There are 10 levels to complete and they get
'harder as you go.  To help you (cheat) you can
'jump to other levels by using the +/- keys.
'Press SPACE to reset level and start over.

'If you beat the last level, you will get a
'smiley face and hear a happy song.

'For those who get stuck, solutions are below.

'=======
'CREDITS:
'=======

'I didn't come up with this game - It's been around for a while.
'It's mostly a clone of a cool game posted on THE QBASIC FORUM here:
'https://www.tapatalk.com/groups/qbasic/tilting-maz-game-t39133.html
'Also some levels derived from the original tilt maze game here:
'https://www.mathsisfun.com/games/tilt-maze.html
'There's other Tilt Maze games that influenced me.

'My thanks to those original game authors for the tilt maze fun.
'Please accept this QB64 version as a compliment from a fan.

'Used the RotoZoom program from the QB64 wiki under _MAPTRIANGLE
'which was written by Galleon, the creator of QB64.  Thanks!
'=================================================================

'Solutions below, for those who get stuck...

'#1)  LURDR
'#2)  LURULDRUL
'#3)  DRULDRDLULUR
'#4)  DRURULURULDR
'#5)  URDLULDLURDLU
'#6)  RDRULDRULDRD
'#7)  DRULDLURDRULDRD
'#8)  RDLDLULDLURURULDRD
'#9)  LURULULDLDRDRURULURDLDR
'#10) DRULDLDRURULULURDLURDRULDRURD

_DELAY .25

df = (_DESKTOPHEIGHT / 640) * .85

SCREEN _NEWIMAGE(640 * df, 640 * df, 32) ': _SCREENMOVE _MIDDLE

'load images...
ball& = _NEWIMAGE(100, 100, 32): _DEST ball&
r = 255: g = 255: b = 255
FOR s = 1 TO 45 STEP .3
    CIRCLE (50, 50), s, _RGB(r, g, b)
    r = r - 1: g = g - 1: b = b - 1
NEXT

_DEST 0

blank& = BASIMAGE2&
pass& = BASIMAGE3&
star& = BASIMAGE4&
wall& = BASIMAGE5&
face& = BASIMAGE6&

_ICON ball&

puzzle = 1 'start on puzzle 1
puzzlemax = 10 'there are 10 puzzles total

'======
restart:
'======

_TITLE "Level: " + STR$(puzzle) + " of" + STR$(puzzlemax)

GOSUB SetLevel

'draw puzzle level
CLS , _RGB(51, 51, 51)
REDIM SHARED pdata$(grid, grid)
bs = INT(_WIDTH / grid)
m = 1
FOR x = 0 TO grid - 1
    FOR y = 0 TO grid - 1
        a$ = MID$(puz$, m, 1)
        pdata$(x + 1, y + 1) = a$
        IF a$ = "x" THEN _PUTIMAGE (y * bs, x * bs)-(y * bs + bs, x * bs + bs), wall&
        IF a$ = "b" THEN
            _PUTIMAGE (y * bs + 1, x * bs + 1)-(y * bs + bs - 1, x * bs + bs - 1), ball&
            ballx = y * bs: bally = x * bs
        END IF
        IF a$ = "y" THEN _PUTIMAGE (y * bs + 1, x * bs + 1)-(y * bs + bs - 1, x * bs + bs - 1), star&
        m = m + 1
    NEXT
NEXT

_DISPLAY

DO
    'get user keypress...
    DO: k$ = INKEY$: _AUTODISPLAY: LOOP UNTIL k$ <> ""

    'if right arrow....
    IF k$ = CHR$(0) + CHR$(77) THEN

        'current ball location in x,y
        cx = ballx / bs + 1: cy = bally / bs + 1

        'Move ball right...
        FOR x = cx + 1 TO grid + 1

            'move it smoothly, by pixels...
            FOR x2 = ((x - 1 - cx) * bs) TO ((x - cx) * bs) STEP 2

                'if come to star
                IF pdata$(cy, x) = "y" THEN
                    _PUTIMAGE (ballx + x2 + 1, bally + 1)-(ballx + x2 + bs - 1, bally + bs - 1), blank&
                    _PUTIMAGE (ballx + x2 + bs, bally)-(ballx + x2 + bs + bs, bally + bs), blank&
                    _PUTIMAGE (ballx + x2 + bs, bally)-(ballx + x2 + bs + bs, bally + bs), ball&

                    'fade out star
                    _DISPLAY
                    SOUND 7000, .1
                    temp& = _COPYIMAGE(_DISPLAY)
                    d = 100
                    FOR trp& = 255 TO 0 STEP -5
                        _PUTIMAGE (0, 0), temp&
                        RotoZoom ballx + x2 + bs + (bs / 2), bally + (bs / 2), star&, d / 100, angle
                        _DISPLAY: d = d + 10
                        angle = angle + 3: IF angle >= 360 THEN angle = angle - 360
                        _SETALPHA trp&, , star&
                        _DELAY .01
                    NEXT

                    GOSUB Done
                    GOTO restart
                END IF

                'if come to wall...
                IF pdata$(cy, x) = "x" THEN
                    ballx = ballx + x2
                    SOUND 500, .1: GOTO moved
                END IF

                'Draw ball image....
                _PUTIMAGE (ballx + x2 + 1, bally + 1)-(ballx + x2 + bs - 1, bally + bs - 1), blank&
                _PUTIMAGE (ballx + x2 + 1, bally + 1)-(ballx + x2 + bs - 1, bally + bs - 1), ball&
                _DISPLAY
                _LIMIT 500
            NEXT

        NEXT
    END IF

    'if left arrow...
    IF k$ = CHR$(0) + CHR$(75) THEN
        cx = ballx / bs + 1: cy = bally / bs + 1
        'Move ball left...
        FOR x = cx - 1 TO 0 STEP -1
            FOR x2 = (x + 1 - cx) * bs TO (x - cx) * bs STEP -2
                IF pdata$(cy, x) = "y" THEN
                    _PUTIMAGE (ballx + x2 + 1, bally + 1)-(ballx + x2 + bs - 1, bally + bs - 1), blank&
                    _PUTIMAGE (ballx + x2 - bs, bally)-(ballx + x2, bally + bs), blank&
                    _PUTIMAGE (ballx + x2 - bs, bally)-(ballx + x2, bally + bs), ball&
                    'fade out star
                    _DISPLAY
                    SOUND 7000, .1
                    temp& = _COPYIMAGE(_DISPLAY)
                    d = 100
                    FOR trp& = 255 TO 0 STEP -5
                        _PUTIMAGE (0, 0), temp&
                        RotoZoom ballx + x2 - (bs / 2), bally + (bs / 2), star&, d / 100, angle
                        _DISPLAY: d = d + 10
                        angle = angle + 3: IF angle >= 360 THEN angle = angle - 360
                        _SETALPHA trp&, , star&
                        _DELAY .01
                    NEXT
                    GOSUB Done
                    GOTO restart
                END IF
                IF pdata$(cy, x) = "x" THEN
                    ballx = ballx + x2
                    SOUND 500, .1
                    GOTO moved
                END IF
                _PUTIMAGE (ballx + x2 + 1, bally + 1)-(ballx + x2 + bs - 1, bally + bs - 1), blank&
                _PUTIMAGE (ballx + x2 + 1, bally + 1)-(ballx + x2 + bs - 1, bally + bs - 1), ball&
                _DISPLAY
                _LIMIT 500
            NEXT
        NEXT
    END IF

    'down arrow
    IF k$ = CHR$(0) + CHR$(80) THEN
        cx = ballx / bs + 1: cy = bally / bs + 1 'current x,y
        FOR y = cy + 1 TO grid + 1
            FOR y2 = (y - 1 - cy) * bs TO (y - cy) * bs STEP 2
                IF pdata$(y, cx) = "y" THEN
                    _PUTIMAGE (ballx + 1, bally + y2 + 1)-(ballx + bs - 1, bally + y2 + bs - 1), blank&
                    _PUTIMAGE (ballx, bally + y2 + bs)-(ballx + bs, bally + y2 + bs + bs), blank&
                    _PUTIMAGE (ballx, bally + y2 + bs)-(ballx + bs, bally + y2 + bs + bs), ball&

                    'fade out star
                    _DISPLAY
                    SOUND 7000, .1
                    temp& = _COPYIMAGE(_DISPLAY)
                    d = 100
                    FOR trp& = 255 TO 0 STEP -5
                        _PUTIMAGE (0, 0), temp&
                        RotoZoom ballx + (bs / 2), bally + y2 + bs + (bs / 2), star&, d / 100, angle
                        _DISPLAY: d = d + 10
                        angle = angle + 3: IF angle >= 360 THEN angle = angle - 360
                        _SETALPHA trp&, , star&
                        _DELAY .01
                    NEXT

                    GOSUB Done
                    GOTO restart
                END IF
                IF pdata$(y, cx) = "x" THEN
                    bally = bally + y2
                    SOUND 500, .1
                    GOTO moved
                END IF
                _PUTIMAGE (ballx + 1, bally + y2 + 1)-(ballx + bs - 1, bally + y2 + bs - 1), blank&
                _PUTIMAGE (ballx + 1, bally + y2 + 1)-(ballx + bs - 1, bally + y2 + bs - 1), ball&
                _DISPLAY
                _LIMIT 500
            NEXT
        NEXT
    END IF

    'if up arrow
    IF k$ = CHR$(0) + CHR$(72) THEN
        cx = ballx / bs + 1: cy = bally / bs + 1 'current x,y
        FOR y = cy - 1 TO 0 STEP -1
            FOR y2 = (y + 1 - cy) * bs TO (y - cy) * bs STEP -2
                IF pdata$(y, cx) = "y" THEN
                    _PUTIMAGE (ballx + 1, bally + y2 + 1)-(ballx + bs - 1, bally + y2 + bs - 1), blank&
                    _PUTIMAGE (ballx, bally + y2 - bs)-(ballx + bs, bally + y2), blank&
                    _PUTIMAGE (ballx, bally + y2 - bs)-(ballx + bs, bally + y2), ball&
                    'fade out star
                    _DISPLAY
                    SOUND 7000, .1
                    temp& = _COPYIMAGE(_DISPLAY)
                    d = 100
                    FOR trp& = 255 TO 0 STEP -5
                        _PUTIMAGE (0, 0), temp&
                        RotoZoom ballx + (bs / 2), bally + y2 - (bs / 2), star&, d / 100, angle
                        _DISPLAY: d = d + 10
                        angle = angle + 3: IF angle >= 360 THEN angle = angle - 360
                        _SETALPHA trp&, , star&
                        _DELAY .01
                    NEXT

                    GOSUB Done
                    GOTO restart
                END IF
                IF pdata$(y, cx) = "x" THEN
                    bally = bally + y2
                    SOUND 500, .1
                    GOTO moved
                END IF
                _PUTIMAGE (ballx + 1, bally + y2 + 1)-(ballx + bs - 1, bally + y2 + bs - 1), blank&
                _PUTIMAGE (ballx + 1, bally + y2 + 1)-(ballx + bs - 1, bally + y2 + bs - 1), ball&
                _DISPLAY
                _LIMIT 500
            NEXT
        NEXT
    END IF

    IF k$ = CHR$(32) THEN GOTO restart

    IF k$ = "+" THEN
        puzzle = puzzle + 1: IF puzzle > puzzlemax THEN puzzle = 1
        GOTO restart
    END IF

    IF k$ = "-" THEN
        puzzle = puzzle - 1: IF puzzle < 1 THEN puzzle = puzzlemax
        GOTO restart
    END IF


    moved:

    IF k$ <> "" THEN _KEYCLEAR

LOOP

END


'====
Done:
'====
_SETALPHA 255, , star& 'reset star&
_PUTIMAGE (160 * df, 210 * df)-(500 * df, 360 * df), pass&: _DISPLAY
_DELAY 2

puzzle = puzzle + 1

'If that was last level...
IF puzzle > puzzlemax THEN
    'show smiley face
    _PUTIMAGE (120 * df, 120 * df)-(520 * df, 520 * df), face&: _DISPLAY
    'play happy music
    PLAY "o4l8gfedcal4gl8fgabo5co4gl4el8defedefgagabl4o5co4c"
    PLAY "o3l8co2l16gf#gl8g#gpbo3c"
    _DELAY 8
    puzzle = 1
END IF

RETURN


'=======
SetLevel:
'=======

'x is the wall, b is ball. y is the star
IF puzzle = 1 THEN
    puz$ = "": grid = 8
    puz$ = puz$ + "xxxxxxxx"
    puz$ = puz$ + "x  xb x"
    puz$ = puz$ + "x  yx x"
    puz$ = puz$ + "x  xx  x"
    puz$ = puz$ + "x      x"
    puz$ = puz$ + "x      x"
    puz$ = puz$ + "x      x"
    puz$ = puz$ + "xxxxxxxx"
END IF

IF puzzle = 2 THEN
    puz$ = "": grid = 10
    puz$ = puz$ + "xxxxxxxxxx"
    puz$ = puz$ + "xx  x    x"
    puz$ = puz$ + "x  xx  x"
    puz$ = puz$ + "x  y    x"
    puz$ = puz$ + "x    xx x"
    puz$ = puz$ + "x      b x"
    puz$ = puz$ + "x        x"
    puz$ = puz$ + "x    xx x"
    puz$ = puz$ + "x x      x"
    puz$ = puz$ + "xxxxxxxxxx"
END IF

IF puzzle = 3 THEN
    puz$ = "": grid = 11
    puz$ = puz$ + "xxxxxxxxxxx"
    puz$ = puz$ + "xbx  x    x"
    puz$ = puz$ + "x    x    x"
    puz$ = puz$ + "xx  x    x"
    puz$ = puz$ + "x    y  x x"
    puz$ = puz$ + "x    x    x"
    puz$ = puz$ + "x        x"
    puz$ = puz$ + "x x    x x"
    puz$ = puz$ + "x  x      x"
    puz$ = puz$ + "x  x    xx"
    puz$ = puz$ + "xxxxxxxxxxx"
END IF

IF puzzle = 4 THEN
    bs = INT(sw / 11) 'boxsize
    puz$ = "": grid = 11
    puz$ = puz$ + "xxxxxxxxxxx"
    puz$ = puz$ + "xbx  x  x"
    puz$ = puz$ + "x xx      x"
    puz$ = puz$ + "x        x"
    puz$ = puz$ + "x      xxx"
    puz$ = puz$ + "x x      x"
    puz$ = puz$ + "x x  xx  x"
    puz$ = puz$ + "x        x"
    puz$ = puz$ + "x xx  x xxx"
    puz$ = puz$ + "x    x  yx"
    puz$ = puz$ + "xxxxxxxxxxx"
END IF

IF puzzle = 5 THEN
    puz$ = "": grid = 12
    puz$ = puz$ + "xxxxxxxxxxxx"
    puz$ = puz$ + "x x      x x"
    puz$ = puz$ + "x x xxx  x x"
    puz$ = puz$ + "x          x"
    puz$ = puz$ + "x x x x xx x"
    puz$ = puz$ + "x x xbx    x"
    puz$ = puz$ + "x  xxxxx xx"
    puz$ = puz$ + "x    xyx  x"
    puz$ = puz$ + "xx        x"
    puz$ = puz$ + "x        xx"
    puz$ = puz$ + "x  x x    x"
    puz$ = puz$ + "xxxxxxxxxxxx"
END IF

IF puzzle = 6 THEN
    puz$ = "": grid = 13
    puz$ = puz$ + "xxxxxxxxxxxxx"
    puz$ = puz$ + "x    x    x"
    puz$ = puz$ + "x  xxx  xxx"
    puz$ = puz$ + "x          x"
    puz$ = puz$ + "xxx xxx  x x"
    puz$ = puz$ + "x        xyx"
    puz$ = puz$ + "xb    x  xxx"
    puz$ = puz$ + "x x  x    x"
    puz$ = puz$ + "xxx  xx    x"
    puz$ = puz$ + "x          x"
    puz$ = puz$ + "x  x  x x x"
    puz$ = puz$ + "x  x  x x x"
    puz$ = puz$ + "xxxxxxxxxxxxx"
END IF

IF puzzle = 7 THEN
    puz$ = "": grid = 15
    puz$ = puz$ + "xxxxxxxxxxxxxxx"
    puz$ = puz$ + "xbx  x    x x"
    puz$ = puz$ + "x xx          x"
    puz$ = puz$ + "x        x  x"
    puz$ = puz$ + "xx      xx  x"
    puz$ = puz$ + "x            x"
    puz$ = puz$ + "x xx      xx x"
    puz$ = puz$ + "x    x x    x"
    puz$ = puz$ + "xx            x"
    puz$ = puz$ + "x  x        x"
    puz$ = puz$ + "x  xx      xx"
    puz$ = puz$ + "x      x    x"
    puz$ = puz$ + "x      xxx    x"
    puz$ = puz$ + "x x        xyx"
    puz$ = puz$ + "xxxxxxxxxxxxxxx"
END IF

IF puzzle = 8 THEN
    puz$ = "": grid = 15
    puz$ = puz$ + "xxxxxxxxxxxxxxx"
    puz$ = puz$ + "x x    x    x"
    puz$ = puz$ + "x    x      xx"
    puz$ = puz$ + "x        b    x"
    puz$ = puz$ + "x    x    x x"
    puz$ = puz$ + "x  x          x"
    puz$ = puz$ + "x      x x  x"
    puz$ = puz$ + "x      xx    xx"
    puz$ = puz$ + "x            x"
    puz$ = puz$ + "xx      x    x"
    puz$ = puz$ + "x  x x      x"
    puz$ = puz$ + "x  xyx      x"
    puz$ = puz$ + "x  xxx      x"
    puz$ = puz$ + "x      x  x x"
    puz$ = puz$ + "xxxxxxxxxxxxxxx"
END IF

IF puzzle = 9 THEN
    puz$ = "": grid = 19
    puz$ = puz$ + "xxxxxxxxxxxxxxxxxxx"
    puz$ = puz$ + "x x  x      x  x"
    puz$ = puz$ + "x x  xxx  x x xxx"
    puz$ = puz$ + "x          x    x"
    puz$ = puz$ + "x xxx xxxxx xxx x x"
    puz$ = puz$ + "x  x  x      x x"
    puz$ = puz$ + "xxx x  x  x  x x"
    puz$ = puz$ + "x          x    x"
    puz$ = puz$ + "x  xxx x xxx xxx x"
    puz$ = puz$ + "x    x x        x"
    puz$ = puz$ + "xxx  x xxx    x x"
    puz$ = puz$ + "x      x      x x"
    puz$ = puz$ + "x x x  x xxx  xxx"
    puz$ = puz$ + "x x x            x"
    puz$ = puz$ + "x x x xxx x  x  x"
    puz$ = puz$ + "x        x  x  x"
    puz$ = puz$ + "x xxx    x x xxx x"
    puz$ = puz$ + "x  bx      x  yx x"
    puz$ = puz$ + "xxxxxxxxxxxxxxxxxxx"
END IF

IF puzzle = 10 THEN
    puz$ = "": grid = 21
    puz$ = puz$ + "xxxxxxxxxxxxxxxxxxxxx"
    puz$ = puz$ + "xbx x    x  x    x"
    puz$ = puz$ + "x x x    x  xxx  x"
    puz$ = puz$ + "x x                x"
    puz$ = puz$ + "x x xxx x x    x  x"
    puz$ = puz$ + "x      x x    x  x"
    puz$ = puz$ + "x  x  x x    x xxx"
    puz$ = puz$ + "x  x              x"
    puz$ = puz$ + "x  x    x xxx x  x"
    puz$ = puz$ + "x        x    x  x"
    puz$ = puz$ + "xxx xxx xxxxx xxx xxx"
    puz$ = puz$ + "x        x        x"
    puz$ = puz$ + "x  xxx  x x xxx x x"
    puz$ = puz$ + "x          x    x x"
    puz$ = puz$ + "xxx xxx  x xxx  x x"
    puz$ = puz$ + "x  x    x x    x x"
    puz$ = puz$ + "x x x xxx x x  x x x"
    puz$ = puz$ + "x x            x  x"
    puz$ = puz$ + "x x    x x x  x x x"
    puz$ = puz$ + "x      x x x    xyx"
    puz$ = puz$ + "xxxxxxxxxxxxxxxxxxxxx"
END IF

RETURN


FUNCTION BASIMAGE2& 'BLANK.BMP
    v& = _NEWIMAGE(158, 159, 32)
    DIM m AS _MEM: m = _MEMIMAGE(v&)
    A$ = ""
    A$ = A$ + "haIk37D3000334BDWoefV<j78QZ;EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
    A$ = A$ + "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
    A$ = A$ + "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEMf7?=jK%%%0"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$: END IF: FOR j = 1 TO LEN(B$)
            IF MID$(B$, j, 1) = "#" THEN
        MID$(B$, j) = "@": END IF: NEXT
        FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    btemp$ = _INFLATE$(btemp$, m.SIZE)
    _MEMPUT m, m.OFFSET, btemp$: _MEMFREE m
    BASIMAGE2& = _COPYIMAGE(v&): _FREEIMAGE v&
END FUNCTION

FUNCTION BASIMAGE3& 'PASS.BMP
    v& = _NEWIMAGE(324, 155, 32)
    DIM m AS _MEM: m = _MEMIMAGE(v&)
    A$ = ""
    A$ = A$ + "haIkMN6[ED4666`2H35\0:ME`2Rm6F`^2::4kX8FA454\g[A15kPUPmJD80f"
    A$ = A$ + "kR6SXR6R]XH;Z9ZQ8AACDnoJNV9O7F>L?Wc^c^kiN^gkkKbC<8\cl=k>ckIJ"
    A$ = A$ + "k\][M];ZM2Q#8L8999eFGb?DBBBb;i7:999iUl3UTTTlBnQBBBBN9o#9999_"
    A$ = A$ + "TOXTTTTGb?DBBBb;i7:999iEJl3K^gch2Q#4:b?D84]eYm]_mAMX3MX`l3kL"
    A$ = A$ + "WkLD?kI?S6`06#df^]K[#84=\dY>eYX>fa>FHnQh5>h1?hXQ?lQ7ML7ga942"
    A$ = A$ + "A3;MY;Mae7^Rb?Tn5RGhH7kHS^P;h242QXQU^e]^5ee^fe2c?TnPR_;ieeOm"
    A$ = A$ + "G_#84=\\IKfV5]aKl6;o#Q#dV7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q"
    A$ = A$ + "7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:"
    A$ = A$ + "42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7"
    A$ = A$ + "i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42Q7i7:42QWF2nQk`>\3AMZCMZDJ6"
    A$ = A$ + "2]_m]_9Ck^e]^Uid^8Qh^A?6]h<?Ra:mL:YTgg[bJlDDaHBR[\T?iAm^lZ>A"
    A$ = A$ + "mliC;1o`]H;fRXNe[N5em^gMG\V6jJGkJD7kH7MTgYMBbk=ICfT<5gDO:[aH"
    A$ = A$ + "FRST6Wm]_m=caHeN>E?Z[DNldi>giX=JSf8GKTbQo=hGTVHKkf^]c5Om^gm>"
    A$ = A$ + "ZWm\W1G_`R[J53QL_8?ZgUGe9Z7eGJ9j7B<bmdkj^^[X7kaN\DS5;5AJG=^g"
    A$ = A$ + "kmNMe92mj]hVjU4SCKJC;CaAAE696_V[iJbD<beE]WCe[j:a;Ghk#k^\h95g"
    A$ = A$ + ";\Om[O>O#3:c?ocolA;H1;8jGnUO9Ji;Oi=IKYU^dU6mmOog7mV_iKF:^<ZF"
    A$ = A$ + "<Hg;2miPMmYmIZU6I]>A]8?Z_dBe?THlmN_g;AiMUR5NnL]GkeV[YMed?oco"
    A$ = A$ + "LdEL5GA`G_5g3LP3dE_Wj0I9>VolWO`aBeBKRa[l:_b<5S?d3m#U:_l<jj^^"
    A$ = A$ + "[[IY^BU4nEh9AjF^Wdj\>[S[ogeZ?QdG90_j?ocolPSUU]\U5=kI?kXeKmF?"
    A$ = A$ + "7E:6BCKKC_f[mJUN>\iKnV7dcDkIIF[CD;E]feb?\fa2a`UOiG^knGm`?La;"
    A$ = A$ + "NaAWciL>AoiOnW1Mmgf]MK^hnl?oc?J3g`=<jeOmG?Xdicn\?c57_d;mB1Mm"
    A$ = A$ + "ECD696?_cklLah3nP?H#YSEFQ;kb^\X[nZ_jPl4;bWWaeBFbBLnRfHfZTWX="
    A$ = A$ + "VC[?QiILmKof_5M;gb]DaH84o`OmGoeB?7fV]IK2b?cNF>a9>AGM2l7;2E]f"
    A$ = A$ + "eb?\fabX7mXMN;lkFeSf?;LQ;<j`?l3?JA;JA1MmDORhNDSJDAMY;M9j]N[g"
    A$ = A$ + ":Xdi1NP7`57?jSnX1MmECD696?jSnXSFoeOmS^WkiN2:M\b:<na?NWWH8oVO"
    A$ = A$ + "mb?ddWnYOJdJ^V[ICj7AO3]i:Ta<Bo;cKmgomOkn]SV:62a?4=Va<6gcQcl<"
    A$ = A$ + "?CgL3l`?l3WZ[gNFN2W`9hZgBm_R#E[M]l3[M\LP7h16MjWnY7M9GbUDGJo`"
    A$ = A$ + "H?jOokOdMNWgI#GoTWlTMam#6b#LN=TNQXCkd>]X1<P14=UY<UP^nZ9KlEkl"
    A$ = A$ + ">_cA[kj^^ACMZC=XdIX3MXUN>Qo?Um#nmnj]O8j5OaGdi7A\SW4nhfl5Jm=l"
    A$ = A$ + "[oj_^`bO6oaTVdTFYH8;nQGl5Oa^dQhVng=cI>cDMmfcbmN_gKgHi3mg8[UZ"
    A$ = A$ + "FkJi7FkHQf\dFkR^X;Z^dnI>cI>^igiB_d;=X[WahJcO8Ycgn]OK#Yc>]CkT"
    A$ = A$ + "c?=;cUIU4UARAJg_F[eJ5M3g`=4Dj#<J?W6a86Ad4V`4LmkYUPO8bNF1To<>"
    A$ = A$ + "IlChnb[l:_BQWo<oVWd9MB[dLZ5ZOh7mAOT;=hi9m?L6cH6Yjj]WUdfWOSl>"
    A$ = A$ + "^Sk8ea#BDeJG;o``RUR\mccn\?KdZ]J[Vkg93AWkiN^^hVnI`hPnV_iK2:MH"
    A$ = A$ + "<;\?]hgmcKAITHTiIRmX1m=:4]EKeFEji4S]WbN;9o`?h3nPBa?m?KCgd=]d"
    A$ = A$ + "J[FYe=>_e=MCgd:i9C<4RO8Z?mY?AMX3M8J3fP=8enIfcBF?6l3In4;2UWN<"
    A$ = A$ + "b?\nh7BnbHEcbecL#QOHXSibfgZ<WLi]TOh:d^]KkFYb0NQL?Qm8CmB\n:Fn"
    A$ = A$ + "cHW]H84ISiUaULcgl=WZ[EnQ5K\fBg?Tn8VU[O]GkefE_:4mn_okkB3n]NV_"
    A$ = A$ + "ilFb?L5JTSLT^hOeGmEgi5aN2Tm>HmD7fQMHU^?bjZ4ZOX]WIHnohi#JTl3;"
    A$ = A$ + "fH]U^O8]?nb_l;3:=\aOa_CWUH0o#VCYlF]fl33mi4j\>[cZd_Oam36_J8Re"
    A$ = A$ + "_Pk7\g>C[R??V43\N8Q:ROl3_`;l2Cee9o`R=FK=h7nb_l;7DJHSmQe#;4MZ"
    A$ = A$ + "WjYFZ?ZDNcKeJc?Tlo8>RS8X[UehdZWajGan^>4Ig;N^WkiBme>[I=[Bg7I]"
    A$ = A$ + "#P#e`6f`LcEch6ghBee9o`R=FKTm3]d^JPGDXk35lI`?TmbE8:^O8cgN8:YU"
    A$ = A$ + "aF;nQ0[GKJ5k5Mc7PikUeB94aeBj<fa>fDO]f_?1h9cJY5ZH<cl<mT?iC>EG"
    A$ = A$ + "GNi76_>Ae#nQYC=WnQ\>6do`#gc=l>2`JlanM>4IeY86^eKmF3:=BBMbeH=F"
    A$ = A$ + "3gh4_aKl6cDLf8h7bc\i=_iUj[elRH?f`mR#g_Wfm1fSaQ630ca2eMbRjA?j"
    A$ = A$ + "QKNACSZgnQkj^^[^mJTf_=9Ce3o#VW5f_I\FbT?6\7^0bc#4e9XNmaOl7O#G"
    A$ = A$ + "?c[_iG5jn0[FUa1=X1ijC3em3ec]Ab?TiJ=Tig`lR86`?l9NRW8hH0?i#n=D"
    A$ = A$ + "km97hi1mA<;Ra<O87bQTZ[Y8l3I^<I?MBo3RGg3_#F39NGJhnUl3cF\TGY=n"
    A$ = A$ + "43N`3>Jh3Oh^l`Pa[POFJWCJC<NGlJ2M]#\hSn7>mY?m<U6EZ<RG=cK?m5Qg"
    A$ = A$ + "Yg#DSVOH8_[hVO8[[<o68oi\43YMMMSOm0eKbZO8cabn^_kKZ^VR`?TmL=nN"
    A$ = A$ + "7caL<[DM?jG8NQdVnZ^Z[BnQI<Fb[dVn<Q?1ci3Y_1n4DW0?aokon_DWnh7B"
    A$ = A$ + "O=2I_bHmEPnJ#o3_okonCMJPZEI4_Nj7JFNgmKdl33iM5gl39oa?lINVW9Ca"
    A$ = A$ + "#Xc5[MOTj=dWn\8V7eMOggmDM=5QO8[W8]5H>4RGgSa8Co2a;<?>SKTOHn<O"
    A$ = A$ + "C<_cdG#jK#lc=D>K_i\7Tei;Tm?1_oKdf:4_<[m9mCPeT9D_ZJE6]g?=n_QN"
    A$ = A$ + "f>eJc?TkE?mCodI:6hlm9d[7XNCFm3AYM^NbKo#F[>jW[m>g4_NGU>WeTOHH"
    A$ = A$ + "aBNen1o6j3Hlc?Dk<lUg]OncL^KUFAK<BSGmEOeDO]hUJck7YAXW_=YY<:o`"
    A$ = A$ + "E\gSJ]h7nEOeGUZomi]O8S]QdQO;f>oKK[OnHgXj7bc<N?]h<8Pg7>>;?JZc"
    A$ = A$ + "9h#c3JSQ?D8W90fN]QjAD_9dig?=UAi7fhh7B<4jnh?;:_l3YN0W=4l^3bI8"
    A$ = A$ + "6Y3SaQjH\g>]bYl3CW:Bo`ZYb?WP3Ym1SaVe2Qg=ed:6[NNdn\J:_>;TUOhZ"
    A$ = A$ + "63]em3[VNWgiM:E>cbiY^l3[OnQa?WPY?JQN>`aLg5R\jU\F7IIm>[Vb[c2I"
    A$ = A$ + "i7^ZaPl3[\hk>SE>iL?D[WBbEcUOXM>1SO6[YAXe=3M>P\gc1fW<\FSl=g8_"
    A$ = A$ + "ENMF8;o`E=6TOHU5ec\b9kg1>;kdg;PTYV;o`hWicfk:0W_kYE\7G2AFNclA"
    A$ = A$ + "SghLWkL3:MZVb[c2Ii7^ZaPl3[\HnI\b9_kFlmkAO_0BVJ^l3SOV?SG8mOjW"
    A$ = A$ + "nYO:eY3WgoYEaO_]HmHXNi;l2_#ZCWJYlj\#FnQ[J<8o`:[hWS?lncLfWmIk"
    A$ = A$ + ">ogUOHfRURd?<NKLkM[Wi1>]:TcPohnQFkR#?SMZV:RmN[l3UOH]T]g9PmOo"
    A$ = A$ + "gOgkX2OSmTOHfRUj]OHXOCXB[RGOaf7J5aga3i7^29o#_TOHUog:o`Ef?\Xn"
    A$ = A$ + "FdF^>fSmH;Ugfk]EAh5;o`E8i7jUl3[loFi7^2o#XX>K<[FNK_Go_aKl65Fn"
    A$ = A$ + "8o#i7JBnQEnOK[Mo#J3D9\cJ;Pj5II?gTFAOASWg\N>Qn]=:9UAi7:o#CiUO"
    A$ = A$ + "8OkOZDm^3h0>0i7f0j7JYM]`f_=hC5bij#FR;;_Okgn]cLJE9\e`nf_mK?Xl"
    A$ = A$ + "#nQ[J<dFg?<YW7\Lfg`g^6]nb9C=2nQ<ONfgk\_kkn^Pb[T:nV85?_cbJKSB"
    A$ = A$ + "BicJkUe_I8b?DnQUW>e2nNg`n_Ako`TYjQO8Wg6KiF^UAkh>^S^cn0SmIOf7"
    A$ = A$ + "GkKnF3IO?L;RiZ<^R_GKX>5m=ThKncOn1UN9Y<Jc?J[Uc3Fi76^:2o`ndWnh"
    A$ = A$ + ">3Uhl`fZg]GkeN5MX7jQjnn^<Y9=9MN`V#E?l3iie#6b#LkEnA?jAG2VgGf["
    A$ = A$ + "XTWLf]5jij#J4N9FLAM8jK8NI5IId>3VhKZD8BnQ[J<dLh76jnY?^:2o#>CJ"
    A$ = A$ + "?bSl8MW7fFm^a<Vah6W<WA\<gQjmG>IZNh7bc^SjX>:Gofim;gPc^GNFa_MA"
    A$ = A$ + "NQWAXW1<9EaGk=NoA\_kT5IIdjkkSl8?B#iQl3GeHXi`?Tj>IiK#=Z8l3?h3"
    A$ = A$ + "nPMSaRcRmhekhlWSa9ck^LNL6g8o`R;];7b7f7PiaIdIeTM>OIo^:Wk<#AF6"
    A$ = A$ + "]kSjlnZU_OHXOS4=eX]7\TOHbSUjYO8WcndFQnZ]lU_lPb_TXheSH^m8?UOH"
    A$ = A$ + "b;[]em3gUMIG2:O=9o`:o_]Aa?\BOo?jGojWK\N5AJ7okl0ooSGF:bmLCleN"
    A$ = A$ + "SmR#Nh7F[bXMO<[nQImKUANi7^TU\TDO]Uk7bgV^\43Qh7bNf;[nQIiKH?ZN"
    A$ = A$ + "mmCYlfFb?<IbZOeDOo?hNI_kM_;Td^Yn>?HUU5\P54DnE;5ok_;`gXAb_\\^"
    A$ = A$ + "f9Y<Je?cZOHFoFIT7eEXmG8ZLo`\lmaSH84o`b?7?BkLcHcmlCmD?EZcKCeS"
    A$ = A$ + "_O:a[G#iDnQ9GD7INcKN^a0]X5]8gnoS_SR0k?4F3fR8]Q?iCnTBg;bSbBBR"
    A$ = A$ + "7;ojOok_K=i\mmHAF6Y>IFl3YO=cI>cam>F_`5^`X5_h5klf9mSOF8G?l3ik"
    A$ = A$ + "9M8:_l3YM?OS8bbHfQ#nNBQO8o^gh6ghBMNK:?OoDZDM2STF_#nQ9CggmMO^"
    A$ = A$ + "_Q[Qn^\E;m3o`?DjN1kONK?gDD[al<Wi<GYkmlmkfVgbRb3f:S<NIbolFl]Q"
    A$ = A$ + "g:CeJ]4cJMU\4ofgc#^GCoFV`4V##Y3[76m9j7oaO<hH8;nQL]3LP3<ei]Yj"
    A$ = A$ + "ak_\9[\bNhPiF<[kiVfjnQLokD>UCamk#5QnR_h;:M_Pc`Gl<XOnQ^_U[UR_"
    A$ = A$ + "GKXM5WSoh7FTm9e:Sh34jk[Ge4[;QEVZeN=[XkoMeDlkmhWai:don_oKZC7j"
    A$ = A$ + "3DXonLCM^6U6IU1jOJXcaMcQO8k1<nV1TeeKY]^OhX6eXLkcm#o^OD;m^_kk"
    A$ = A$ + "FjN1eEI\#<7L5eN^9nki>kUOfknh1GTN4FITb5k7\lFCMZC]DIZF_;2=:nQf"
    A$ = A$ + "JIlaOl7GGSQhWS7fiJDJTE6`?OjCOj153=7nQ\_HI<nDoCnQQ;n^Od[Ne[XY"
    A$ = A$ + "<UYTkY=RcXoh[e[m^R0oaOl7iNn5O?:<h1?HGmkRf?d:Sh1`gfWlFhoIUYJm"
    A$ = A$ + "^ZfLj76oN?n0h7NggmMGgbO>ocS_FJ43Qj7Bo33ikD1Zi`?Tjjl>[#O4UOHh"
    A$ = A$ + "Ri9Qj]d?kR#cJFcZdmRmH?f3gHc]a_F4kiVhm?Hof_mcM>8EdnQFITf#do]l"
    A$ = A$ + "FWaIL6[d_YD]cbTVCo#kkIX=FEPjF<_oe3egnfgEb?TaP`k^NJTi7bn[ReEI"
    A$ = A$ + "I;KIY>>J>l37dP6TKM`hmGAnQQ;NfAmFj_AAXh[g7_3jlKH5YoDlf3lMfQa#"
    A$ = A$ + "`JhD?FCKl3In7bKUVcncV;o`h[SAlnVQO8SgoOnWoY#cOjGDllWfMfi;GJTM"
    A$ = A$ + "_Vmk3[7C8Sg_i`?<?lITOHc[O8kSTlDag;^fH;I?m;o`RELO?NO3]kmfL5Kk"
    A$ = A$ + "Kboj_n[29o;OLbfh7]gCcd8kNM?jA?L];Va<VAZS7i7F\aI[Eo`lN?g4?_fj"
    A$ = A$ + "]N[S6i87YKmH[GkiafRnQ=UG8[[?eiImfi_3o#6k9SUKY;MYiJnciACiNQdV"
    A$ = A$ + "S_Igfn`?=:^O8m?<Tm<Tl3;fh\eXO8[WbdVfdbel:^_1kaLkn^l3cOanD<nJ"
    A$ = A$ + "i77RAVcC>oEH_`7gCTWo?nSohI>oi<X9nifQ1N#TofjX5ZO8#<CKSOogomDU"
    A$ = A$ + "6b?\HSchWCF\_\Vm\W]kLHVi<QecTWQQR]n33MX3e]o2hlkSm#GNTf#lf<VO"
    A$ = A$ + "8SQQijVjKL6n?gi>GghBH_2`IUHXiElegTci;lVH_VGTgoRG6I>Whlil9ObW"
    A$ = A$ + "diAbNHROWQe3>;YOlbEBl3;Rb:kE:RSJMV=_WkiNjVGOjG^]WP<?ahokhN6o"
    A$ = A$ + "mOh7nQYZmOelQiM8Wm;a9NRWXK=iINB\ci=nFcbm4f7k<7:9iN]]V#DgTmWK"
    A$ = A$ + "B[SJ]Y`?dj[1?;HnQb[j46]5m39n`kXJe3K90kcA>3;YlDNkSl6JG#m5jSB["
    A$ = A$ + "UkO0W3Nh[EYeG^iZ\>P1<0gcGl=a_Ylm<>NRE:^jI?kIYm>?kaUbKccOGl_="
    A$ = A$ + "I=5hSaIe;NQCLRCdiiTek5D7UmQHF^_`H6Z7go]kO]5FOiZEGZU4dg9f[8lK"
    A$ = A$ + "\5MIRc79FKIl=J]Lo3HOgROCUfoQecb:N#Kof_m^e^HH3KH^mJ4cgFeNoIX]"
    A$ = A$ + "6SK>_R1nn=`n^WlWmb5m;UWiToImN1[5DFSe\jWVDhg2hg>hLR]e^OHLHO2B"
    A$ = A$ + "Ja_SBK3j_0SQ:;`nBQc0OVc7l#X?LiEJ3\WiHm6Ym2eGSgFVa_Po8SOPnFPW"
    A$ = A$ + "IFb[3jP>8gIh0e=hnDi_oB5am_b;Sh9<i9?IGohhn:gOcJjCLBlBLgDU[jEM"
    A$ = A$ + "56[:Y3n?TVDgVj;llSnV`cfJm>dbkO=NV<_9QhgP?<m72OHVW7jC8eKI^AH<"
    A$ = A$ + "h=EnCna_S#lbINDJ_GCiRnMbie?oF;?_CBK:Z3P75Y1ogl\>Q1U7:GFobK;i"
    A$ = A$ + "7bcJnm?B?:oLoUiC:;`lQ`kF\MFTWWY=#O2Ym2cY3?_Xm#i]KIL]hS#\TUlR"
    A$ = A$ + "HVHWbPe?QRnnGiUAlg9?H>khnJF;C9YLE_Z[#iTbch7ohMn3Tfl\;]WIm4Kh"
    A$ = A$ + "MAm=B7BKlJ`[POG1o2lNSk3c_eQog86a8LcAYi3KgC:_NECE7SlZF??JZkeV"
    A$ = A$ + "7>o>7UM^?TTfDD7`lXioVWe9RWGD^XleFhmG^YZ;IoV5?_hiDFPdPdRdTWki"
    A$ = A$ + "IJ7?m]j5UgVQo<i;omI=?SGFZTWANOo[lb8U5[=DAl<:=WQ9iIIU[_Y:WiAM"
    A$ = A$ + "IBOl:hgC`;Rnk5gc9[n`YY>FU^GWVkUFJ4oNDNGW8NNI??bjg#UFRnQ2A[AX"
    A$ = A$ + "]LiN>V_Ain`iag>9aZRl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`"
    A$ = A$ + "Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl35"
    A$ = A$ + "2Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`S"
    A$ = A$ + "l352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352"
    A$ = A$ + "Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl352Q`Sl"
    A$ = A$ + "352Q`CAj7fnfgnX>eY>5eU^dUX^e]^ib;Q#8JDYOm[OAM_kM_#l3k#7j#D7k"
    A$ = A$ + "H7SjLWkLDGkJGMn^2Q#dX2NQmZGm:gm3UTTTJ=;i7:999iUl3UTTTlBnQBBB"
    A$ = A$ + "BN9o#9999_TOXTTTTGb?DBBBb;i7:999iUl3UTTTlbl352Q#d^Xo74NT%%h1"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$: END IF: FOR j = 1 TO LEN(B$)
            IF MID$(B$, j, 1) = "#" THEN
        MID$(B$, j) = "@": END IF: NEXT
        FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    btemp$ = _INFLATE$(btemp$, m.SIZE)
    _MEMPUT m, m.OFFSET, btemp$: _MEMFREE m
    BASIMAGE3& = _COPYIMAGE(v&): _FREEIMAGE v&
END FUNCTION


FUNCTION BASIMAGE4& 'star.bmp
    v& = _NEWIMAGE(190, 190, 32)
    DIM m AS _MEM: m = _MEMIMAGE(v&)
    A$ = ""
    A$ = A$ + "haIkMNo\DD455NnWdL>QiL>;6:4#4##PRT05I99P92FP:15D11:1D05D\0OR"
    A$ = A$ + "PB##Paj[jZ[MN3c\k<kfcdmlfc?lE_E4N_memI_cY_cmNWXGiERS42Q#842Q"
    A$ = A$ + "#842QX\<UY47=i9kog72AMbFfBLdVg\oOO84e53OhaAWndaAocoHN]_Oo84e"
    A$ = A$ + "1cKNaAaa6VkLSSNiG^mhkg_2Q;H?kYU^OGkbX]OYG:KTfG<DPgl=SSn_o[U^"
    A$ = A$ + "o2G8>j=NShXGl5=l2_P1ko]Ekkkgg2A_`ZFE;=_UU_LSFoiN^hXWmI=`[i?C"
    A$ = A$ + "jNa#1>bA^BMoQ>TAWod?MLdCnT6heBk;6:`4V`EZiQ;OISoW7oaSSNT7a0_6"
    A$ = A$ + "]ocolBg;JfliONfjNhCnThX7nQSSNP7`0_n9N2SW7[?OOonG8j6>i9cGgOlS"
    A$ = A$ + "77MogOLdMOg6he?jSJRi;_>RV:cJFi[i]<bA67M7gQ1dn?d3IljS?ORi;M_X"
    A$ = A$ + "Ya>fAWemKH3aAgj]Jh>_CC<o7ka<NM\almm_72AAQlcOncgIM?e^`]MKaAgd"
    A$ = A$ + "=InjmL?VchZcg:JR\\UeI=_Ua=^hX[ojSS^iK>>j^^[hX7l1=W_ENM4==>h1"
    A$ = A$ + ";^^OkK?>jJ_fhXKl6SS^mK?>jn^?SGWWiIdiK5=76kH=iW_XjNZQ1lfC<Oli"
    A$ = A$ + "ciK9WV?eC9_>RV3[Om5GcKIVc<>jj^>S?On<0ic?I^lU^G4j<`0UGgOP347M"
    A$ = A$ + "=GCLd=L3VcgN_g[bU_Xi`dVFielF`C?NM^UK9>JH3CibGdLHKK[kem[H5Vcg"
    A$ = A$ + "RG7^?FT;OZI7Eg2R#VGkeRS>kIkNM?nS#gKmjXLi;J2\X5emJN;lI7>OKbLi"
    A$ = A$ + ";_>R#Vm]_NGgCmKJcU?NMD^l5Q<SNdaAGjBm^^oLWc4[GibGd4PJY_GelFVh"
    A$ = A$ + "4_B_>Z^54Q8on_k>M?cK1bUObjFPLi;_>R#2VmO^Bc3hG2]^=Gnb[S84QIoW"
    A$ = A$ + ";em`lWO[LiK[K1U;OAX0cl?VmO^Fgc<H#e]P8DQInW[elF8f>W_Ee]P8dHgk"
    A$ = A$ + "^jdmOl7?hLiW\^5D?8:l5YWoO^VCM:cIK]ibGe]P848[ioW[IDSBibG4FLh3"
    A$ = A$ + "Gmjn]^Ee3RR`QgiMZN=?P?:dkZ^54Q0KLSeS^7VndE?8:23n[oZndmkOoIW;"
    A$ = A$ + "OieADWlN_GmYi]PgV\j1AieADGlMOGm[kGjBE?8:l75MnoiJ>fa6\GWTibGN"
    A$ = A$ + "M4E=UInoiJhW_j1AQ?PiLS_dmOfWMUe]PbU_XZi]Okb=ooL=Wi<6omY[K1U;"
    A$ = A$ + "OAEbjFWodlF6ohEM;8ZGnSo`ojNbUTZK1AMaDWZoel0mP8eZPj1AAM`GoenG"
    A$ = A$ + "cKI>cYmmPXdm2G#_>ooL=ol?[N#DDmhRioW[Qlf[N#DDU\gmjOMNJFmZc_74"
    A$ = A$ + "EM;8jEXOW^h5m_>?=D?X4_7_>Z745^6j]KO[acSA<2Eg2RZQSNDo[_c3VGE:"
    A$ = A$ + "Gn2GcTVToef]3Z;DlhXN#DhBfdVl_f^C<UYTM?8:_>R^1VoOomOkOMMWh7nQ"
    A$ = A$ + "Fib7_>Z745m2EilocU#mQbiICg3Rb[SXKPI#__ed5U5_H=kT5m>TO`ZLnoiJ"
    A$ = A$ + "hI>QZK1A_b:GYoebU5R[KcU_ZK1Ag`_l;nG7GFFkJc^74C>kTUfGT7d?CnF3"
    A$ = A$ + "g=LjCKliXIW\KPIT4c^Un5fi>m_6^KIi;gl\#TWgFCKJaAcNfaAcKNVj9mmO"
    A$ = A$ + "ohXU\4o_njB#KFEjnA>BcLZcgkY2AB#CRf\ZSkSoAGlL9F8j5XfHGcJ<Nfj4"
    A$ = A$ + "^Bk?SI47MbCjoOg5mWPf3oKTOZlPcaH?;S[dolmPW]=kKOnO=#dO1mnc[nZV"
    A$ = A$ + "lCU6bE;`ig9gEYeo^#gcg;nnbcUNikADeP_6NN:amO>;X6l0^G5Tk:nL0jO["
    A$ = A$ + "f_Gemf[I`g;n<5OnRjd]>W3lRn;>a9RS6cH<g;R\PjaPJCRkA7i\U?7Pf7]I"
    A$ = A$ + "bkIA_XmC[kicEfi_NEn\\DdO2iC6m<g3^\Pj#RN<SN>Pjb0m?eV1Jbdg[>G4"
    A$ = A$ + "c?IlNZi?nIaWk8OZbgSXG1O=cOnVkkLN#mgAmH#]8QnWkA7J#dRX9C7_gUnk"
    A$ = A$ + "9>?eh=N[X7OX7gh<_3<PoGk4=C#kPfRj]8?\mB?JO^_d4c7]7J#dRX9MYond"
    A$ = A$ + "NM\JOlCQ_:^V4G_QOnnhi1RXIcfg^9nmEMEG9GmEKPJ>5M?alYG38F?J>dNF"
    A$ = A$ + "_mYel^:?nIYmC7gW?3^`56VcO3AH1J4VkQIYgCZkCZi;JLNGG?BYen9?W[e_"
    A$ = A$ + "?WgPW9>bgS8?HnBSF]CJNlg#mfQg6jUBdFFol9?7KEZicb_ObcjbeJXnGiJ?"
    A$ = A$ + "LN3nZlm8BCkleHQHlXia??nJ8?>F=5J\di\\>[iDikAD6X?fJ:nJLY_W#hIW"
    A$ = A$ + "P`?dDmeh:O?Okgjom0AmbffFcfGSlm8:3h[QnOIXP_6ikAD4H_Uhc3eleD6m"
    A$ = A$ + "_lmdOAEh[9dekMS_W5\0ikIX0mCnJLU_WGoeU_WV<7ohmWnJ:Sn??O?D?Ybg"
    A$ = A$ + "Cc3le#Lk^eGCEDklQ4bgc#;`Gc\VUled=Jollm`c?Cik9L1O=\_9O=M_n_Mn"
    A$ = A$ + "NnV_aokaR13?7[KW_6K<nnEO=U=fONnNX7LT_7o3nJH>U9O=^Gkg>O?L]EO_"
    A$ = A$ + "gg_ba>VleDejoTnN\mcUeg3e`Z_e0mKlEOUleDWanccg3ckdVdcVQV:bGSod"
    A$ = A$ + "nbgSOX\nJH678O=^EoWW_7FOU_7g3nJ`[BImeT^?_U_VNGk;O?E?bGCh#Amm"
    A$ = A$ + "`L3EnNjN`G3jEi[9\XCnNhJ\bgCgQle4f8O?^5FSVi<U_VV0iik9iljDnNj<"
    A$ = A$ + "^`G3[iIi[agJTQbDDO?DS\nFS5J\e]:O==I:Z_WE\2o[e25hIKXle<dP>iki"
    A$ = A$ + "Sn8o[g25HV];O=3M8?O?4OB?GFJ1c\Ddg5YOXT_VV1IikQlEhK]FX1c`UdJN"
    A$ = A$ + "i[YiCB]ogomnGW5J\Y==H_=F=?cnSQ=<i[Y93k?l<HAiao:i2G`Xa]WQ5_=4"
    A$ = A$ + "WgZiKjc_VnMn`?doJ\#5N>LK?7;m82niaKCbWCDbGCcTSNDo[_2E>`1JiaQL"
    A$ = A$ + "g`c=7ReSOnd?C0mmnXXh<i9kO]EX3eA6jNRgS^WnI3M_=F_dl=?fbFl_^:d1"
    A$ = A$ + "OPhcQcdR?7NN8C>;9N_eSS_g7557Z=WcL6o[[2M>eY<gS:>G;WcUNiQWmgLV"
    A$ = A$ + "FicYiaRFToeD=56cHJiaWli`mY2o?b[CcSm_Oo[WJ:`Li:YG7bY3iaTkEURi"
    A$ = A$ + "gLh]N[hX;M9o[WJ:`J5eP3nM87nlJ^?]T;C^7]Bgg<H][eoJYV6cM^iW?Cie"
    A$ = A$ + "YIPVU\UWOkgJMOKY6<YNdhnG9_>=3Vndm_6ZY2jKlj#]HVll]fjACjn`5=kT"
    A$ = A$ + "kNFoj7L=;XLig<PJ[mOoGo[OJZLfcJdlIU;OMnf`UU_Lo[MJj<a9fjl]D3nD"
    A$ = A$ + "g2:GnQ=7j#nGgddI?kYE^lil]:GnQ=SOlaAGnbnGgd>>i9=hkg7]3F396_bU"
    A$ = A$ + "OcP=^Ao[IJ7kNg6O30_fg_OJ7;I93^6=E^l3G2ehXL_#C?g>8?iX]lmk]lPk"
    A$ = A$ + "oQ]obil]fLi[JE;\H>caoJU\PIh0e5JNc\3VOoQjWGiIX=alCW;OMnf`QM];"
    A$ = A$ + "o[CB3_W`CCWV?ChO>4mmlUOIneU_RikO2]n6?;O=]K6lI[mmU]<ooN?9WolV"
    A$ = A$ + "liHkgLU;o`RE_Jo[A\d9O=YW7I4;5O4X[PA>b`bg3elAjLi[N#<<PjYbgj3X"
    A$ = A$ + "XnJ\WGd>3nhO3NM0N=WOTLXkkOOPOjWD^l3AVdTl_f0O=;NaMgLFUlT#<Db?"
    A$ = A$ + ">`[i?SoOO`746g?2R_K[E=U;o`P=_IoZ9`Gc`7Name#n`C>?b`_<j:dA0_Vo"
    A$ = A$ + "<>39oM6mXm__7lAJ[E=K^lE]Zi?`7mY?]od3UeGCbWSa4G7o2fI`7a>1k<LV"
    A$ = A$ + "oOlgQo^nfgCjn>Gibg_\`5j7M0nJXWeMilS?9I=on9f?c_OOikQ[kXn>?<HO"
    A$ = A$ + "k[ngokEO=9ONoUe\5>i<L>mc[AnN<ZAi7O?lLb;M^leiK[OlAOSc<Ef5nJB>"
    A$ = A$ + "WEC[G\JoTc_o#`gc5_XicMZFel;[I=egNNEh[YMcIeRlL;2=8mJ#Mjk9_n>G"
    A$ = A$ + "NMZ?Z[n6_ZmeTg_OUagCMmLLi87AmM^?IJC[NfWaG3aeJWV?[W;>UaGCWXXn"
    A$ = A$ + "NZ[jkQ?oYn>g?De?;b[KO=5Ak7:nNFgjDOWk3XfH[bn67?3lcY^med=Jo\lm"
    A$ = A$ + "#mmDUnNH>kZn>_nY:[IaM^Cok[Y8jOOkkI2C#mMNMc1?Xkg7aG3g3\#aGCAd"
    A$ = A$ + "nndg3gWJE[Je7SKL^OOl4W`lm>dled=Jojbg3k1lmGib_NH3K8lleTnimGM_"
    A$ = A$ + "Wk;O?dG=Z_c[7LEL[VV_VRXm;R_7>KT[^Nia?N[Li[JE[jHfcfMnJHoXYi[Y"
    A$ = A$ + "KdnE]_7j9NegiE;^hi=>nJ`WBCfGCAdoeU_W_h;DOWGU<RAdKm=>nJF`26jh"
    A$ = A$ + "[Y8Joj`g3mM>G;DmMNe`ZFUleh2]OEhkIZCEmMNEa_n[bGC_XokT_7RAg]cO"
    A$ = A$ + "XOl7E^l[2NggEnJLQf_8nNFjBk>O?hYGmM^KY\m=nOnWUgG3aYJjnJj6]OFn"
    A$ = A$ + "NH6LEFO?h3EmM^kX\m=n>fQleD4mOJO?lkL_hkQnNT[KZLik6`[BAme#M3CL"
    A$ = A$ + "Li[YHJoRjkYXmb9moRjkLg`NgKWG_iJbDKb43??MOoX_V^AkWW_7b9FWf7ff"
    A$ = A$ + "fDOWk2H^EdYH=L_G\?G>8F^leDNLU_W\jkLngYcgF>nd?]mnJFi:=nDhjZLm"
    A$ = A$ + "edajU_VRS[lm`cP0U;oN3ZkY\FKIfMAO?`IW\cXJdg9embGCia5nN>lQEOWg"
    A$ = A$ + ";TGOS_omKV]1LV9f3`gBJ?>bGC_A_jk9[n>gjeAalK?L6YdnJFkJ=aO8_`LV"
    A$ = A$ + "9dc4;gNNFi[aMDDO?lli:]_7V[AZ_c;?TKVcM^1k[I6c`\fCL7Re#<7Km#aJ"
    A$ = A$ + "LbWK8bGSKXKmmXn>_kPc>IG3Yf?X^YHMW[gbJ>G[eNNFdiXg]gc4i[amD4O?"
    A$ = A$ + "L=PTe9>WoRm6egi5W3L0ce>I>]HGcImV[cbJ=GSejaQeFkc:7i[YjX8nNH]g"
    A$ = A$ + "jk1_of[mbNUZE]fcH7[iNN?cIfJmVe8FWi\A\6Kmh`J:jMkc:7bGLJO=\6;="
    A$ = A$ + "_KX<nN6H0cNU]V^]GC#ib?K`7?nJB^FcJ<[_4KQ[GbJ;[UfW5JbGCmBAmm`i"
    A$ = A$ + "dH?bf;3fLi[n>_H[_9mhHSYPF7hebGSOfK:BnNB^?YjFXh[]F?>4?Q[UbJ7a"
    A$ = A$ + "C`C3OEnJlknCWlm`N4JNn:kMfJdDNMJojZ=?>h;Te<^F9[O\VBL5b;\lehom"
    A$ = A$ + "Y\lm`N3kA\GaN6kM\7JWSRb[Cn[WFM_MMTl03LmBR[8O=Q1]cg3kEfm]TaYT"
    A$ = A$ + "^?kead[Q4W0]>`JWle4FTFkcN3kA\GaNVmIEJFaZlmkm#QT[Qf[MbJX5FgT_"
    A$ = A$ + "V`TdnN\nn]TdCZREUojW=fABD<n`V\RmWgnW_O_6JTL];;TV?\AkOmnJGFhk"
    A$ = A$ + "gK2]7:42Q#842Q#842Q#842Q#842QX#loLUV%%h1"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$: END IF: FOR j = 1 TO LEN(B$)
            IF MID$(B$, j, 1) = "#" THEN
        MID$(B$, j) = "@": END IF: NEXT
        FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    btemp$ = _INFLATE$(btemp$, m.SIZE)
    _MEMPUT m, m.OFFSET, btemp$: _MEMFREE m
    BASIMAGE4& = _COPYIMAGE(v&): _FREEIMAGE v&
END FUNCTION


FUNCTION BASIMAGE5& 'wall.bmp
    v& = _NEWIMAGE(193, 192, 32)
    DIM m AS _MEM: m = _MEMIMAGE(v&)
    A$ = ""
    A$ = A$ + "haIkMVoDKKl66?094`LK<H3H\aVS#`4P090QLA^94BPLl=9CKcdIji?eYMjd"
    A$ = A$ + "[IjOlkgmIIUA\`F]j`[TIOoQ?S5Bkka^jiaBfH3e[GWEGBU:EHC?md\A6I4f"
    A$ = A$ + "#3=4[gNkUeC?m`^jE_Z0\=1Ak6#7W;G>FnliIS?nh\5GLIFS6[b^i=_=Kmeg"
    A$ = A$ + "DXm[E[VP9VH2FYBUH3>hP\nk_OQ^_k^kF`E^bEJ^=1Ak6#;?`038Nnm:EZaV"
    A$ = A$ + "Mf5Hgh6[aFMeeIc=gLRWo_Lib2_26OWMf9[S>jPMY;M92R;<0==dfhJ3`?\`"
    A$ = A$ + "2;bFJYUIc?ol\YVJ:ae0PGibGnbYN_B#d:1JLLoAE[R[7<?oNSFT=l`3;^o7"
    A$ = A$ + "hABknSP`60]>dmhe8dXASVgo?Mo?4^2#[3=?dn[\b:Rk?2g7DJgG44f4_G[l"
    A$ = A$ + "J[]FcgoWd^W88\9N_GW[_njT7P`91_fHh38?0Q[RW7HS=fPNm04>99Q70_oB"
    A$ = A$ + "MeEGWjg7=0KC#dZ`_>3J?X1Sbk[OLm0hmF2m0nm]Q?W5hggl2;\P0\=1A[2o"
    A$ = A$ + "j<XmP64Ja`nNk77?0lL8FlkG6ONSfNk]IgkNg[9gm^gUPXUQO]6dN#32]8dT"
    A$ = A$ + "Qij1Ae3hmloS>jX\mgOOfWolWIoaOl7\oiOn7fOmGo5k?ocoTPXU3dJ#c1]7"
    A$ = A$ + "dP#;2=IH^N#Dm0`WQOgJhcGd7oh7IOogom\on_oKfon_o[XW88\5#c1]7dP#"
    A$ = A$ + ";2=IHn<o4E?0Nm7hj>GojGWmcol?cnmOogKb_mKo61Qe`_f3JAX9Qf4JdFY7"
    A$ = A$ + "0aQ?We;]dB\OjWn9f_n[oZXO`Sob_l;44F3oJ?X5QV4JCCo\?7G?0nlVn]Ok"
    A$ = A$ + "g:lONlSoh?B#H=l[mPF4JBKh1`eIll0OmGoe\Oh7nQVlMOggA#H=l[mPFdc3"
    A$ = A$ + "dZ_G8To9WLBagmV?mY?9lONlU_l522[QO]7dR#C2]Y=l0hkLl\c>;komQ?`n"
    A$ = A$ + "bgl==kY_j[n:22[ACo0G32]8dT#KJ3?#aR5Ie[ESMdQ7bn<go1nT4lNDA#dZ"
    A$ = A$ + "aC_iYoPF4JBX=]U7XVd3l9OmCJ_^#hFhYkP64JaJYP7heljn1Omd7hG?RP`F"
    A$ = A$ + "dDgaieI4?`kimUAlN52KLV>n\:ZcS0WG_GB;:oZW?Rjj\US;=m0SEL<FeJEI"
    A$ = A$ + "_ne_Fj9oXPgagf8NW2Q=>C7OF5eiAPc[g9Y5UOec7AMMfbaioJ2#;F]JEfHS"
    A$ = A$ + "=VEm07L`1Lokk?a3`gf8NW2Q=>C7OF5eiAPc[g9Y5UOec7AMMfbaiYoQ64JA"
    A$ = A$ + "[j1he1ekE_jElNoM=k5\=1Q]`_^3Jadd30Ohk5nidOMQ`M`_^;]l0_TGgSle"
    A$ = A$ + "C7MdABNW27YQP>^Yicdj5el7G2Z_ee7QMm9Yj[TNM:YGG?>Onm3I1?`KOkac"
    A$ = A$ + "a3?4l>5hkckH7iOKO7o`Sn_7WgH5K[<f33jhW3n?fAWCoN^SCGomOToSlUOe"
    A$ = A$ + "LMX_mOZOnLV?jZWGLZckPjCehdQ^eiCeg1]N4T>8Xe_cf7`30=GZk1Ni;Kj;"
    A$ = A$ + "?^_<#c5ei^AWC=8ojdfV>^4iLhoANeEW`>_3kjUANPH\NTDj0ia?BjQm^n2d"
    A$ = A$ + "Rfb3dYd3DYBEfNljNbcOmFfKhmfKNcQji#52kh2:NCc_jh3khRkl8XlZ;n`>"
    A$ = A$ + "_3KLQ]NaMM?>[O2_`KKNm8X5QV4Jc>]P7X0_>CO:?0h#f1l7?PgOJi#52kh2"
    A$ = A$ + ":NCc_jh3khRkl8XlZ;n`>_3KLQ]N1D7E=MR^n9eLNGO0JAX9;H3?#WM:m0EH"
    A$ = A$ + "_h5kM:oj1_i=Y:_BBJg7]KdZFgNS29NnmMm1X5QVDh1JaOOR5NP254oO;kI?"
    A$ = A$ + "K?f17hc3L`1Y:k;9]kSf=JGGg>AgMX#;2=9dVfd3ldWm2f[>h4O>N]iY9k;9"
    A$ = A$ + "]kSf=JGGgJZkhJ#X5C3?`CNfc>ecOPo6_##H;lOM<X5C5?`COjYNnSdN=Q`]"
    A$ = A$ + "`oeaPF<=l0?j9?Q]W_NJ_mfCbn7cn1##ScdlHJL6gGbiQ^heMlh>O=>nmT4S"
    A$ = A$ + "LIdlGCMJNN>R[36_N8[_VjdDga1JAKk1:kc3hO]i52foHf?02JLVVWPRkUB<"
    A$ = A$ + "^_Tc3MiEgaSklehhgCB<bUAcO=eYiii8^>X>Ol>oLVa8[oiD7XgNY4??#I;j"
    A$ = A$ + "1bc[cTlj]kSN4kilNkiliaa\GfSGX#Jg?49biWCmL]l]QF4Jblfd3D^laN0A"
    A$ = A$ + "_oB9HkGTmhiBBknP8i>o0?0Gc1N^W7P[9]V78ONaO7GN`^kbNjc?I>lD1?WP"
    A$ = A$ + "Xe3g7h7X5QV4JCKj1^?_^?Qg??S[m1HKR<8?CR][G[^^L]_0nfg?Ul0gk1?P"
    A$ = A$ + "mhWnDR\>?FR][W5[;dRfd3<2_>C0?`m_?kalG?>A6W7;afecRe5JAKj16VGW"
    A$ = A$ + "Blj]cm^7Kg7oh;>\[Td^?BkiEDG7fE3FX_QFdfNPRB?`3ie?fl89aMLVNLMS"
    A$ = A$ + "KG9a]?==^XV_`6O#c;MS?\mg^J8Zc_#4?dRhiU7afNPMfQgSk6?NXV]3kh<m"
    A$ = A$ + "h?DIkT^?==^XV_T:nd>o9<#;2=i`fb3<b8\RU:a^3_^?hQ?<nl09aMLVNLC["
    A$ = A$ + "GDkCCS;Zi;YR?]cO22dR#C2]YEl03?\h_YMKa[kmhe?fl09aMLVNLC[GDkCC"
    A$ = A$ + "S;Zi;YR?]cO22dR#C2]Y=m0KNWk`^k3NPiLO=4VLH3deWImn=Y6GKhiCX5C3"
    A$ = A$ + "?`]gJ;a[5aHfA3Q97f0MmIF_OCZae6Nn4JaDa3\iV\M^kMKbMDh<kO7=XKl1"
    A$ = A$ + "\oF6bnJ79jjGKeWkXP^nediEB_>MVe[#>_BRe5X5]Y7H`17V=fH5IKLkKcfV"
    A$ = A$ + "OOH0LoHK]m>\=U\U2K60j6oi^oMTH#NS:RjM>c[`fo9BO`IK99MnCjn<FW_3"
    A$ = A$ + "aiE_c?Nj?X5QV4JCKi1:8m0=e9gAfOKM2K9IC3Agh5kg;ghakhKm84i?DXNn"
    A$ = A$ + "96mOLI;5JIci4Z?SdhEeiVLni>WllD#;F`ZNP15o=\HMN\K^mf7cFKc^5Hcc"
    A$ = A$ + "bVB>_SI<KYP1aT8e=19[d?a]?DS_E=_dUGangBRDo1]8dT#KJ=?#Q27k1h_F"
    A$ = A$ + "4?fHccWK;Aga=V]THhhC\jV#TEjWhf7ZagZVGjb[gnm[m4N0^VdfNPeFOM^_"
    A$ = A$ + "LcV\n]8J_iFBBkn`<l[mPFdFNP>li1FQGg=hegSeghf6bVB<MlQ=?VVo=e##"
    A$ = A$ + "i;Xh2:OVf7jbKHSgdnL391=?<Mm:Xi_Y[oWolg_fK5ONP>\X7h6[]V_WkhF2"
    A$ = A$ + "_XIL;9V>n`V7Cco]d##i;Xh2:OVf7jbKHS?ZmIB7GDGo?oiOCM7W6L]Xel0M"
    A$ = A$ + "d1K0NM6UG_UGI5f=U?g1N4meZ6a6B<MlQ=?VVo=d##i;Xh2:OVf7jbKHS?Zm"
    A$ = A$ + "IB7GDGo?klGh3PVCB3^F4OGRQf4JDKh1#mJLSKL:MoJL_hZ>5[;iRJmbhmY?"
    A$ = A$ + "]7dRFe3<`0\lS>:K9NMGa[?^i=I[`k[EFME7QeDhRFmbhm9dJ#caeN0X5QV4"
    A$ = A$ + "JCKh1jSGWQieKa6=H;ck5lj2^1__`f;S798JehYe`SLPF4Jbn\Y78ONfehe]"
    A$ = A$ + "1_?J2oNb88\6ndN#;2=Y]m0;Lm6l[1]j9\lb44f3OJ?X5C5?`eFR]DSElA32"
    A$ = A$ + "2;b9J?X5]Z7X_n4O6EWKQ5I;^dbnH922;b9J?X5QV4JCKh1ba[cP2?`eHGKY"
    A$ = A$ + "6nH922;b9J?X5QV<WUl0mb[c0lj=kLcaFHa5KbLaTT:?IMLUiI[Nm`_f3JAX"
    A$ = A$ + "9keVNPQ6jH?`e^FCV=V<_ThVW\>^bl\E_NL:]7l0L=Y]m0eVMFnePFX9e98\"
    A$ = A$ + "8neN#;JE?#^LROWdc`[k\ljkAmiS9Nc_hVW\JOXVg\bl]=5oJ?X5QV4JC[h1"
    A$ = A$ + "j]Ga_CjY[ES=3oJ#eU<CmHbLBRKNbZmQJNc:cgfDZkCkEU[5QV4JCKi1j7NP"
    A$ = A$ + "IVAhoZ9IVjcbZ67VEBLcCF]?DcKFInf62dJ#cEGZmZ`eRYR7XJEN_DWgC7c<"
    A$ = A$ + "c`Od?N7CMo4]FJGFgSAO>S_hafC?MEQVdfNPbL?#5_iA]jL_H=FUZ0\]lW5D"
    A$ = A$ + "ohmY5Oa5YSK:ZiYV6RKMB:R#o<S29jjH2^nL^mYYioHM5dL#kQh;KI?`Eie9"
    A$ = A$ + "7_Nho3PUiG32gC4^V0f^LeI4NSSao??S62JLVVWP#=?EEfFMOA]>959el>Yb"
    A$ = A$ + "GBg?A=obS9eL#kQ]QF4Jb[JC?#omcVPGgYhmACZDABE9Zo\>2JLVVW`FW:J8"
    A$ = A$ + "^e9Y8YkWhV_FmjC8e;ndN#;2=Yel0laV;G>FYYVVkoZbV\ZTbETDERj?[SP6"
    A$ = A$ + "WYiIJ9VVW:J`dj4DmD?^^a[KLA]OdE7_l5dhdMLeh3Z_2KO7BmRW^SC9h1hJ"
    A$ = A$ + "BX=]Z7HRb\9WRg;ET0?AXXRTTJLC99^iadj4DmD?^^aKjh<]O<]_2ZO<]OSj"
    A$ = A$ + "iMCkG=WoldMCGQolaUC5?`hUVTEJbb\BUU<iTQTbBBZaI[l#T>W7DR[Y^[\#"
    A$ = A$ + ";J;?`UTN0lkSK\BC`:>iD\RC9QgGQSYTTDScFiQ8M>?X4GCMgD\a:>Q#CN\>"
    A$ = A$ + "^ek1jV?fNhe[`hU4n_CX41Q5i4]GQa:ajYgL\^kf2N0>2?0_Nh_c_SGTg3L?"
    A$ = A$ + "hh5;9Y81Q50J=XkVD0dRmdSW7`<ML\l0Mg=?VNIi;<6oJ15U<>1Q5aCgEB0d"
    A$ = A$ + "R#C2]Yml0m`6QGgAimaXlNRP`nD\9S8l0mHM?``i;`mOSkS24]ELail6nndW"
    A$ = A$ + ":NPA6UUOdah<^TA9J[`klF19YMo4M`oGR]Y7hbljd=?6lMH6n?LmPS9?AK55"
    A$ = A$ + "D8]kWX3dR#CNI;j1^Rd3<4_n3UOD9i9J[HD5Bkn9j0]hE\Y70ab[5noOf#3c"
    A$ = A$ + "k1h58R1iE8]kWf?`og1PV4JC[i1^Bg\16L8fP3=2WQma#nNllHH=KKjh<=NK"
    A$ = A$ + "A#mSoeTcKmaKoSX\FVeWGA=OaEWLni1OGRQNf^NP[8ZKb=g^hi1jG#HGOb:#"
    A$ = A$ + "N0Sl03<PhJ#3R[7L:6<0Rkh<=NKaig?m;9l[?I5Bjn=Yd9W=?#;V6NPnjK0F"
    A$ = A$ + "omc??go#:<H04gaIJlfRPjW`^nTE8YkgTBWLfl0]X=m0MaSmblHca[KOXnZd"
    A$ = A$ + "W2jf_Y7?[7Wjn3JLV^NIJOZ;_VF?CcCD?_ZKm9^eaG<#;2=IGFb3d9?f^haR"
    A$ = A$ + "oVNQ_oJWQL:XKoVNl\NLZk?XaIjjUYmY^lJJm<=?AmlZ^eWhF7Oa0]8dTMJ;"
    A$ = A$ + "?#GM9lKhc[=nklkI8W2jf_Y7?[7Wjn3JLV^NIJOZ;_VF?CcCD?_ZKm9^eaG<"
    A$ = A$ + "#;2=9dVFa3dIW\^he2OoUagS02Rd6X5QVddo7eg:l0GegSGEIOoGKWH[1:K7"
    A$ = A$ + "gj5Dl]jl[KlZ[_1]^KM]H4kWH_NVFN0lMYQ7[8N9M;akWE?^jnC:DcOL[G#a"
    A$ = A$ + "gZc_^a[^n6dj^]9ZmC\G?iJAKk1086od]2j>^jnC:DcOL[G#agZc_Y[_1]^K"
    A$ = A$ + "KRJo4gngCGJC?0nLZB#TEPl04^>YQ70O>E98b:#N02G7Kj1^4Z3l0hc<11A6"
    A$ = A$ + "1?MY=m0hmRRP8[PEm0:gC41AFP`ZO9?0a5=B3?#c[mL1Wc\FWabGH[KB=ndJ"
    A$ = A$ + "NX5b3dbe>T78K<?dBJh188JSQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl0"
    A$ = A$ + "4^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7"
    A$ = A$ + "P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl"
    A$ = A$ + "04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T"
    A$ = A$ + "7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQ"
    A$ = A$ + "l04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>"
    A$ = A$ + "T7P`eQl04^>T7P`eQl04^>T7P`eQl04^>T7P`ea_78G^L\Nk]GF7MdAZgG44"
    A$ = A$ + "fR^k^Kacm3?#nliI3?l`\>k\cD__88\1hikacmgOom;l0C<a4\a7OLae6X[5"
    A$ = A$ + "#LA7XakZ[^H3>hPRWk7NP[Om6\iWoJ\nj[?am7Ufm81A[4lLmhNP:EZ4KZYV"
    A$ = A$ + "Bh1FNiEinPUIS>J1^gH8Q?0S3gK4l<44G40?g?dehen>`038doC?md2?`=_i"
    A$ = A$ + "]I[]f]H;^hb\iVKAFQ25H3=d#Rg_8lj6PWPPXM6XSamiPko1gk?doc<c<\Je"
    A$ = A$ + "ZaFOm=hLK^?hFR[7\hR=HU;GVE\HAam:QHPW1_f12RfAPn5<b8S`_GWA5jk:"
    A$ = A$ + "EZ8doe[GWmo1OR53%%%0"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$: END IF: FOR j = 1 TO LEN(B$)
            IF MID$(B$, j, 1) = "#" THEN
        MID$(B$, j) = "@": END IF: NEXT
        FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    btemp$ = _INFLATE$(btemp$, m.SIZE)
    _MEMPUT m, m.OFFSET, btemp$: _MEMFREE m
    BASIMAGE5& = _COPYIMAGE(v&): _FREEIMAGE v&
END FUNCTION

FUNCTION BASIMAGE6& 'face.bmp
    v& = _NEWIMAGE(300, 297, 32)
    DIM m AS _MEM: m = _MEMIMAGE(v&)
    A$ = ""
    A$ = A$ + "haIkMV0eLDEU7_b>9Q\#24P<12Q\_72RA6A#1G?ZSRh9IHD>A<:PA>RkSSjX"
    A$ = A$ + "h0Z7L2<X7S:P2ZP8<jX\916A9\4PX\JRB#F2[RPAU=A7GB=m__bGjZjdOmG_"
    A$ = A$ + "lZjNOEMo>WO7dT_^CGgkmm_O_kkn^_XXXh83333333333333333333333SlS"
    A$ = A$ + "hH3333i`d[<<<25<m:33S#Q^D_j0?`3d```8gad[<<<25<m:33S#1C_b``8D"
    A$ = A$ + "`d[<<<25<m:33S#1C_bXCH:[I=aSM3K#nmb^6ka5OaaCoT>9a]9657VNUAoa"
    A$ = A$ + "B?X3:N2GiE6?XodOBL]Yf1nL>m?`7X_?gBKk<b7<m:SmmD>UhMin_OaeKbCh"
    A$ = A$ + "iSWCY]e6m6VNEeTUlBN9a3j?oW5G7ATiQEkiVWOYm16M>VNEiW3HI;CL=2]c"
    A$ = A$ + "`Oh7FLoTa0SYGENI^o;o;R[34R<WSnX5ggIdL<mZb3cl4>1a7[G6I67oa7_d"
    A$ = A$ + "U^Dam_6VNEIPioVNCR?V^:`l>bSDLOME7C_:<IZo7o7R?n]:cnnYnDfL^40C"
    A$ = A$ + "_:\h0NA_8a7[JDWU\\UIjF58VNUnIBG`58nhBS16lCVfEnRYGYCVlGj;9nh?"
    A$ = A$ + "S^WmN][ed^b1<m:mQdSe<l3ChB^4Cc:?7KHjERa^MEGUhS_<b?6ojFWYMi1<"
    A$ = A$ + "m:iI?^X;BlaC6i?kngnKKJFm8VNU<<SgmkFla?6badGmZ=][^P<fAC_Z#HA_"
    A$ = A$ + "bGYhSG<TW5lbOiVVE7B6KXYGU[<Y;l25O<RQnHg]jPX]9S]cd[:6k\QA3<[g"
    A$ = A$ + "bKad\jdaAVNUgA;m>HS`P3h0>0CgZ5TaNIjENUIO\7[hao6Q7cLU[dd\j7bH"
    A$ = A$ + "[<m:_``NRW#lHNS`WYMRWHOjFVfEMbHS<mZNRQoX?Zhah6U?6fSl8V^e1JjE"
    A$ = A$ + "nTi]RE8NL]AiUIoVOcVNe1JjEm:F_AgX8IA_PG#UFg:Sm`d[j8f_?iWDlhGS"
    A$ = A$ + "Z7kc7oSGIe\bH;<mZf2[WiIX1ZRen#6KPYGeif<33QHo>aC\bYIUa6HjEVFU"
    A$ = A$ + "A`aRGlR[<JFINf=mZn5^?PU>^d`XoH17l1G9d\blLKjE=Umll>?aS7=<68fS"
    A$ = A$ + "_fG;N9;I9UJM[<?cVNe>aX^kkFlh#3SfUMIcK^DGKYINN=mZngfHH4#\X5]X"
    A$ = A$ + "BYVEVWCC_bdZ<:=D6gk`<?SVNEl#omoNaSc<<l5CO5[XDYIUii[R[G5]m];N"
    A$ = A$ + "lUQQ_I_>eC]d<G[<?KEHm:YSY<<bCFh2GHY#c:ccE5E_J??ocGlh93SlV9L^"
    A$ = A$ + "WK`[IUiIZRZG9MLTQAA1e2?JFB?Vcd[jLfkcn\5?na`XXIgGkJ3fiIUiIYRY"
    A$ = A$ + "G9MLSQQD#mI5Rcc:ccA5A_JF7ga9NlRQQd<eE^bPKNFIN6Z8jEB7WHHX52]N"
    A$ = A$ + "k#V?oULmZUN#7Tha766JSi]`56<Wi`<Of;ijEB7GHHXE2Unj#V?gUHm:k>1d"
    A$ = A$ + "`XoIXojOMl2F`2D_VEV?gUDm:YS5<<25FhOO]QB?V]ZZG=og`K#lH03S#QYo"
    A$ = A$ + "ZNEZN?3cli]TYGIWOI3S>Wi=_iYfm=<cWebVNU2lmM=oZOELdBFBkk?nLO^T"
    A$ = A$ + "GSdO^;SPM5kKkh76cHRS>VS9Xm53K[K=NncOnZL?3clI]4YG9]?_SIlS_c\o"
    A$ = A$ + "]3SKLfL<=OAGS[W>8mHIC_BA`M_Z_7Kd8;KI1gH5A8_m31V_H^cM^Z[_:gen"
    A$ = A$ + "[D_>YO6Bc4Fgj4g??PL?gCa<fXI\lU7<SG:4>jSF>Oa?oW77mgnKbK3J1Sib"
    A$ = A$ + "^<EEKFInlE2d[Tfo>P<fa:gh37OV?CLdOm_:_]#Jn?o?UgG#n^D^VUVFGHV?"
    A$ = A$ + "K1\Ne2OE_:MgkeUNLAch`?lhXo_o_Zgl]Z5[8^]_A^_k;>j_lGTgfd46l_mg"
    A$ = A$ + "fgN6ZQl_geSYBmjTF[JWN>d67oa;ohQF1SCZ:JFBK[K5[LU9ceBQnRMod>=E"
    A$ = A$ + "\^`^fGVje9]Fe\FeZ4gOfDN^WCna0];_lGNiFgjenJUg6g^l`?\:GSX6boNV"
    A$ = A$ + "?C1ZNe`Od7ELOICYVOElHo>QohODUSCl2BKKk4F`2DigM<cJac^cHXDJFM]?"
    A$ = A$ + "=e[CB]:YmQ=U;iBT?V_Ki\>;eV7U:U_HH3;>RcX_bd]6cgok;Jng3ImZI^jE"
    A$ = A$ + ";^oKWhj_NiSekE^P;8>j?oWEehT:]_hgmkDU_Hb[LUkXng=mZ0N^EL6<T>nf"
    A$ = A$ + "GlKo]9JFBKC=OALdeMMZkk?Vm\W]8ca:De[TfOeDT>^fg\U]X^eSDYm5D_>:"
    A$ = A$ + "bG8aL\<m:?alVWladnVY>ehXWnY3_J;]\j;^gk=aGX4=;gL\:B=[#C_JYJD["
    A$ = A$ + "BjHilT=^ah8foEU<6YBk;0l5\?^BKWok`L\X^\<mZVc#9_::`?EI6S\[kJLd"
    A$ = A$ + "ML7Z;o9EBO1P_h9OBeh;VcLVCQfCB3=m:Ym?E^a7>N`7<>j?l7TgNKnRhXKl"
    A$ = A$ + "6EU_HFcJF5fj239mZ9oUobRkKb`klM:O\KAa]MK9e3TBnNm:]N5WoA5i;V`o"
    A$ = A$ + "eoEQEgkQRNeH_iKFLoBUMl1L`7LLd=MCaAoYoTJ6WTQSjXTg6ETX<OAA]^`#"
    A$ = A$ + "A_BJoAUG_2^j[>Yf5efn5nfNKbKKZhnRI<kI_SNh#EG_Ja7fQ9^oXb[EihWm"
    A$ = A$ + "cDGmF;^=AJOQdfoo>Ck0>PLoNZ84d[Tf?\C<Q98O\ZDLEGELdVg\NF;2kKYd"
    A$ = A$ + "f4Ym5:j<ZkjQ3VNUR#jhD9iB_dh8bUhcl<jHL2m<:Y]9Bk;DD?GTm:<?_WXe"
    A$ = A$ + "^NU:6C8XNe#6b#RKe?KH3KX_OW2kc4c]l:^RhX7h1RSNnWgl5=lCQZGil5KK"
    A$ = A$ + "KZ9?F<NMVcLViF_mCcjEco8?Bi]o2>6if_mKO07O8bhT_og?9g9BgoY?]C[#"
    A$ = A$ + "O^KgOF6g1>5Y_Pnk7[?GBOA:fWSh8b]jK#cjEBKgK:5`MD`Kl=n6Kka6=nCQ"
    A$ = A$ + "<6Qk3d[mJCVSUT[3AIjDRi;ZmmJA:kLO#m=T7JFVNE7bTVTJ7O`?7jQNXioH"
    A$ = A$ + "4^SO8G_BOODE0j1H?E__H3K8>jaN<i7KT2FCHNdo6dZNen`LmEPM_X7Sl5n2"
    A$ = A$ + "OQ^IXAVOhm8g7W#^N_UKAfNAZi;Bhomo=i>]D9iL7fmCnTcUngPFe[TfN;eH"
    A$ = A$ + "4OmC^?6ikmmBjOWBVg4cGT`?h747MGgUjfKZI<SIhmjaBSjEJc^KSAJ2OW_C"
    A$ = A$ + "bJ2Y^6Tjke=OA2TcMFCXfj7\e67C=_kcn=S:e[Tf>g:bah^C^fLXme?lNU[S"
    A$ = A$ + "An_o_Cf;MZ_JYnn5cGT`ocoCLdjG_ZfS#7\V#OVgMC_B?SAlm?i^N5gm<?nS"
    A$ = A$ + ";G>\<OA2<GG>?Q?kcZZLH1COjC__m:\\ZG9]me6Sd1jET3;9[m7cGDgG#>\X"
    A$ = A$ + "NhDH^DlIN\dTNeLGa:4gfJSAjPa8\>4jSOVNUln2YGKN;H:_VGCOWA7OLOjX"
    A$ = A$ + "9m:Y][fHT>L<bgmkVDcXBe?a=OAMOaUMI9e<ZF>G>=P_bSUYGISAj9mZkon="
    A$ = A$ + "m:=h;D^NU_ZOD]XG]h3o`5gV:mH4b=Y_nQg[LO<2[7L[K]D^N`PcGLiG^JG?"
    A$ = A$ + "8<eJjD^nlNI#_JDgmM;^=Eja8P_n9_oL^3mZ7jQ:UjE1W_PlGYdl]33OCKZ_"
    A$ = A$ + "l^g[eRU6d[V3WIC5HCe`HT]_m]gAS5Jf?lND8SAX>5iNOGZjDdl59XQJg]=H"
    A$ = A$ + "b_Qg#?gK\dPNe`n=o6a]UJI<b86a8jTQ3=m7N?:4m:>3QL?]D2[oZPbG#N4i"
    A$ = A$ + "<4bMlURe[6B]H5joXQ^NUdfa>Re\VL?n;8jW<lMjGiE67mD?EY\nfCSjm5^c"
    A$ = A$ + "b9mID9l3M0mJ_lCJmZUn2OQRK3k88VX0R3I]nMj?lJ:Ta8Gh5FokdO^WC^_C"
    A$ = A$ + "_8VkB8h;hL6#OAFbNUAKB_FkXB[G9]m[[X8R3okXbnQ\;gEJh<fZ8OAL1oiI"
    A$ = A$ + "7n2=d;bJCfkU_lnZ[Q^=_kVNU^7STVcol?oh]^e]6_]]]]h=^a=6?^a=^Roc"
    A$ = A$ + "aojoJmm?oF_Ei[g71l3HganSO0o1n5AR9LnROl?>Y>hDL^[L<T7kaj;7FMkL"
    A$ = A$ + "\TD_:4\_=UZlmi5S?0=d?TQ2JmiZ4W_#Qm3iFA_DkXRZGY0KGGAA\7eJ5gJ1"
    A$ = A$ + "e`m=Ag4gFV`i;Dfm=a01e?;W?W^9_kVNEGbh7_la[5=SNde[SQ]\UTnGRdnQ"
    A$ = A$ + "ZZNEJO1md7YcSH7`n_okOOejNg\V#C_Z;Y:>7;G?Tij^>MMFe^ckDNKSTn2>"
    A$ = A$ + "oVB_^l>PA_^eegL\jVNfPDjEcQkUG5Hkj9T>V]8id?mjWkSKkfdE]9bWSZVV"
    A$ = A$ + "EJOA0D73=2jEMC_B^[7oUjeEiVKUS7mAU?^]87O#=RnCn9aAojO]nfklZdlM"
    A$ = A$ + "?Wc9[_#;O_A7`N^ZEegJ2Gh2GH7]V`<_?VNEW1SIckcN_6H_f[jW_iOi_DUm"
    A$ = A$ + "MgnXZj;Tf^g5<lkj^jZm9<ckSYGeiPVUda`i9[NeecE2e`0ec^fVKEEaG0Y["
    A$ = A$ + "W4=k;J3LkCXYGEP`l<:ceSUKl1WE`kh>BbER6WKEE`G<VaD_?9ZMOAKPKO2k"
    A$ = A$ + "TkDe<_75TNE#dWfk4HObXF_U>NfgLVWImiFm;n59W]IY]eV_8>jJ^V``G<0l"
    A$ = A$ + "?lJN=Mli9<ckA1YG=A>OV:`Ni=hkh:KeImANTeo^LVK5ie=0>ooUBO1TNN^\"
    A$ = A$ + "WPQP_H0H<eNNH=QMBOM?ckA1YG9]M:ghYOjTjhCjHkNUA>bjS?hNhTljZUJ]"
    A$ = A$ + "Z:k;hkiaG`cVdfG?1[9\C>ocINm5PNed?YCBLKD^Qkkf;bnUP_I`3^nn?aM`"
    A$ = A$ + "9mS_#lkb;3nRgkk]^F5n2Za<NV2hLFe8DG3LOZbJ2eXNehi\T[0kD^>>QN4l"
    A$ = A$ + "^\;b7_gY<lQGOlajFGbj>2\JW^dh;nHO\jn2n^3l5l\4ZnRnQAMEGEOkA8eQ"
    A$ = A$ + "U6e[TfnD8`N<CmOC<Vdam];;MYIeZNT79iI#JKY_l57bQ8_=^MiKn=[GO^h;"
    A$ = A$ + "nYodTWQ0^f5J5MBMHUieJjEnML2Wa^A=:iSo78nPO`jJE\oC\oJUYa7lLPnK"
    A$ = A$ + "1d;[kILn1dZh>54O1Of;;nRV0kAHkfGgclJ=m:o2cMWmMVNYVdS3J6;NaI7O"
    A$ = A$ + "`JeY?all?_lf>O3SgiiRW_G`;#NKOSLFWEfeoAo=Vh6n<GReZP>Y^AclJ=m:"
    A$ = A$ + "o3ed7WI2nNbGj;Ena5Ya=nPJFPc>;g1TLG5EF7O`c5?OlL:]]?=oSoSem5d?"
    A$ = A$ + "[X_hC?]RhVbZ_85Y[KDC_B9#oDSe7N;gBLdGm[:gHSGl;>kgSCO=ViLlH?F`"
    A$ = A$ + "G_d]5llac9?_lLOX7ZLn2G=PjdYH?0_gk=9>Y2XCi0m:gMYj0=7[<_FC_:o7"
    A$ = A$ + "W#?MPa9[M]aA3MX5gH3ngb=f`=W:nNl=^ahX]]]4mdb^FEJO1?_lLccoQOh5"
    A$ = A$ + "[>5n2bUFjL6BO\Rh2VCE0fOHj5LjE]CM^WieVcjEUjJ_ZMaYKAM=A]omSnA9"
    A$ = A$ + "ca9?b;?_W=ZAA=7N3g#bH3b]F9[NNjHO1?o\f;\7L?cDDn2bG8oKQoWh0fOS"
    A$ = A$ + ":V>U3Z1;bQEkdKIblJcImZY`gYX0kSh`h4>KmL6GX76A<k5OanmkiimRkV^d"
    A$ = A$ + "S?XgibHB6Kn#?DbL<Z#[kXY`co_kgUH?^aK\hl5<W:ngbe3[Z2[5_OHRWbYd"
    A$ = A$ + "gL\#_JPbQEVGK>[G=HZm#5HOD34OBOg6][7l1SSfdVBfS>f7KRW9^n[meRSN"
    A$ = A$ + "[_eTLeC_7P_WVjjL\S=IO^No_oTOWdOg]K^DlN#mk`k9_gD_Q<W:>K=Eda6]"
    A$ = A$ + "dGPnMSn2\OH7aNRMnOjO:a^Sm7o0n3l;hO`?eXOXol5l_1oKQo_Rk;6dcolk"
    A$ = A$ + "hLiX9m:Y];Z4RE1dbMen0iDQlIl3n1ee^8ghXO1=K<1oi<^Plfb[QLCak1S="
    A$ = A$ + "hmd]f_ZnlYjDO1f?\SH?a^RO0kL[l3]S_`M^1ZhJE>#_ZMj?bINMVNUlhb_5"
    A$ = A$ + "OG?gGF?iCVD_PLGoA?MQebam=7e>?e81m1Ykj^BfSnkknBfg;N=lMg^ekIS9"
    A$ = A$ + "jNO1f?gl^`^blR`>_i=WHgMn1n_hG`oPObl5M4XGe>WS`<_^LD_Ja7fQ9^=9"
    A$ = A$ + "ha=n1H=MPko_mMebh7<OQGHZedYXVAYgbX1mZI]ZE9^=a``#W\g;OikhnW#3"
    A$ = A$ + "jEk>[WG1f5333maHnFO[n>gcLW4fZJJ8c[;7e[6=[eG1f5333ma8^eK]]jC3"
    A$ = A$ + "INMiXNUdf3333M3eh>kAXYGIHHXMJWn:CVGSYGIHH84LVLXV6<m:333]SYGI"
    A$ = A$ + "HH4:d>m]_<_6C_b``#8LjE]j<4VieHjE6662AkdWAclJ<m:333Q`d[<<<25<"
    A$ = A$ + "mZ^Pgck9QCl4CHe[>>jMm^RS>QC8>jh?nhXSkhRSN7_Sh8>?T_mgNLdaN\aA"
    A$ = A$ + "_]gFLd:GILdaL<boiG[#?a[EaClg;mWA=2WKj>ILi0<FEcPN5eh^YGe1d[a6"
    A$ = A$ + "Lo;IW?o^gVJf]\#ObZGS9Mm>2UKK=mZ^PN=fPnO4mVM^g0DNlQZ]UF?#=1^["
    A$ = A$ + "LjeHBjAPL?Wld?]l??]0C_Z;XGS=^X;:Y7jA_7^:g;?kekTdU\TZeMfCo1mm"
    A$ = A$ + "_N=VlJ^VTkdNjOPBold2<mZ^PN=fhSlARSnQo`TkA>VSPd??QX=<=Uik_ef1"
    A$ = A$ + "j9fmZ=Tnd<g]5dSJUniY5HjEM1mJ\1iR7m:^SVZRjE3KHnE_RkZ?^[[ZRfBP"
    A$ = A$ + "kYBOXGamLaFgZl??]0Ko1k2jeHSU]\TkYGjWjE]kC>OZCUV_dG:i>2\:>?[S"
    A$ = A$ + "jXlSNejGObMFVd??]0C_Z;XGS=fkm>i>nSkL0^[VTni9T\M]2boRk>UAjWcR"
    A$ = A$ + "TJSOkIK7gG?GoeWXi;mcC;`d[j2laH;bi0mCEbG\d??QTMKPhN^7e_7GZd^R"
    A$ = A$ + "Ne6f#bN09mcC;`d[4:nPkIL^KWZBg?\5QNe=Oc9k;OEJ>FnB_2K7gSdBold2"
    A$ = A$ + "ddiMNXQBm;kShS;iBRS^UK9iNWCjWW#b^e>fEVW0gk[E5=;OHgh^NQk8a]]="
    A$ = A$ + "iONj76L]?KJZOb4<g?>n8nPkSI^?Oin>EjWWRPCmD;6mZoioiTi^B=>DEf_`"
    A$ = A$ + "NeV=lQW4?BM<cm:]d??m3LohXYnegnlIo\RKC:Th3Pk\LfoHZ=IYON:2NY_d"
    A$ = A$ + "RA_JNc;i>NWkkJVSUd?gQ#lhRGLR=SmoiIN6iONj7VhonoNOjEJYo]7<g_cn"
    A$ = A$ + "HL5i;HM[CmeC\gH83YHd[6lPC\]olO^Z7ki=nLO^NgVM6WAbLBi<iXhlYbmk"
    A$ = A$ + "\V^OL2VL^__kK_7S#m^L5GALd3nPbolD4<bAF<jE\f6\]\g[EQeJGK^6N9FT"
    A$ = A$ + "m[VJ_BakG=k=XYGe5LSgH_7SLh7NbL`IN0EQl2CodY8d[HMW<nSL7G5F[]?\"
    A$ = A$ + "IH_hlF`I`Gae_\k\hXUkgiPA_2VlTk]HT1=XTLHA==D5b;lUMI5SNe7n3W<n"
    A$ = A$ + "kf^]b_N5[g]G]GSOl9f[[mJC\G:>FdEkEXGefJ8i\NeHI_XEP]I0Qi5iS_GS"
    A$ = A$ + "J:fb;\o0K:i_JCKZlGgXCLRm^mRLGQ=cEK=:M^nSLm[_?m:ZUQ5]X5Y6mZY\"
    A$ = A$ + "Ve8^]Y]YGSEXoSBOl`eonTniAkf[fE_RjRI;KYlGKKnbN1^JGFYaQClD>Und"
    A$ = A$ + "[XF6dTNE#]V#O4_`nb#=jYhiQk=6eXbG]ZA<RTaNGjU67mh?Nio\IjCmMjE8"
    A$ = A$ + ":?gE0eb`RGlR=m:YRGXN\YV6:kS]0>W<iYNeIMF9[5l:_bTm6\\g[6lUN5e:"
    A$ = A$ + ":kC]R]G>m:fK`U\TUHjEB5_`H\ZB]2i;KFo=^cES8\gP:N^2N1OYmS=c=7OU"
    A$ = A$ + "^F#`YGA^fKeI7dd[J1CI:mNl2e;4ijDiWcD_1eg3mG?OZEA]XjbcNEil>kSe"
    A$ = A$ + "FCnjI]Pd;fh^4#jWYF0JEDKk;LQ;\UebPYGe2>kcf?SgX?YAOM\\?63H=7\_"
    A$ = A$ + "MiaL[HM=EUn9S?\KL_cA=e#]<XhjJ7LjET[MC_Bhh6V?NEH=<>#GVLfe[eVM"
    A$ = A$ + "]HhMXEA>[Z:m[?OD73>MNFoL0D3P^JKWLGIjEm0_XGD_7g#M^CMHEU^[GXO["
    A$ = A$ + "C_\d7c[Ri8lCn9EWnQ\?dZVi<C\M\F#>Wc:?^;mm<Qfd[Va9MBRKO:dh7>S^"
    A$ = A$ + "E]NP2S?hIUiIMWgILd7mS>`ieRon?d7Z^>5iNQjVWGOEjnV`Gc]28OODk7Bo"
    A$ = A$ + "<e2f[E]ZfZ_G9UNE`=7;O4o`L\Hn1:nlVV;`jg#WVa=lMmTC#jQESM\9k51W"
    A$ = A$ + "k9nooEn:e7SidZhgWGGEknlbGjE\o4Xe[lnTY;gE3DO_BDm:U?oD_7o0To5>"
    A$ = A$ + "cYBolDdP_6MJZI:Z;MbU7em?m<0Vg9cQRo;gA7lWcO?oNlkGUF3]?Se#_:4n"
    A$ = A$ + ">bJnFgJ1WolW_Je[V8eAYdfZR>6Z:]?Q=9^\_ecanZclUh>;VN23i26m9n_D"
    A$ = A$ + "WJlWcO?oNE]kSNbaY?e[LiP#akccHZmi<miLF[jE1eJ2I<S?RQ^h;>>jV^YZ"
    A$ = A$ + "E_7_EfDFS7P^4oGncZbf5OZEij7g:OoDMe9:[5LP>7>VNE70iJYGSSXnCY?4"
    A$ = A$ + "aL7ZBiSaXm`7JE\W5XGaJ\9o3:N^E#WL>L<mZ>0O=7;N^Y_dbnM9mcTQNheo"
    A$ = A$ + "jmgL[0VK5WI#5?g:`YGAM]?#W37C_Z3aGcG?#RU<:#lE\UK_E_kkFmWIemLE"
    A$ = A$ + "[J7e9:[5\MbMUTjEk:m8B5Hg:lH:ZEKbeLEYNR<6HlYNUkn3Bck;HLmiFaN3"
    A$ = A$ + "f>ee^djE1gL\leJ21^kLX^H<=;3OZEaI1h7mSBbgPRWonX[5okZkZf]>A=mZ"
    A$ = A$ + "^P3i#lC\5iNWk[4UO>D=bIVcLlCl4g;S^l\_a=Znn]fnLH7f>F;h0MO3JjEm"
    A$ = A$ + "0nL>FD_=Eejab81O>g:h6^QTJ4EiaD^e2BMGe>m#6C_B1aHOZ?ELdML79ki\"
    A$ = A$ + "bS_<b1XnnmYNUklg40gK#Y[kZ1ZO][9mZiLd7]hf^>6OLo4j0k?mb_ZbMXSA"
    A$ = A$ + "2_jG]oRQ>eC=A[RN7cCnTZ_V[0G^[JWn9ZVd[2biHice42\gcEQN#WAMlIlC"
    A$ = A$ + "jl\[hk\;7SmL?gM\_P]CoiCKjEk>fK5H75;NSe5`mGREckE3#CaWJE0kgLPD"
    A$ = A$ + "S<YgG`>Y>6dRNe1L#7Thf`>VGl;f_JFdSg[JmRPZ:LgOkKm:fkV0Y6TC__P]"
    A$ = A$ + "CoiCKjE1kJ2Ga:l[V5WCWbnM0JE7O6_#]ehZ?DdZhNiEjW_f0gmhLW^_PJB_"
    A$ = A$ + "JXTW#5H;k8H^gn<nSNnk_jG54O7YAGR?SGLk98[5Tm4<0F;h#NRW8cmRJXZG"
    A$ = A$ + "aWKY]UR7o1oKoKZoLOId5LNWWoSE#_RNLh?kW54JE#jk][>MO1eTN5\XGf;C"
    A$ = A$ + "LkI73a9SKLn=>TJbbjAFU;lIl1g=Q^ce<mh`WjYToi[=HZeVCBgLN1eZNE#>"
    A$ = A$ + "7;dDh\JichaMMGC>KQ1#MdHd6\KkVOS?^X;ZnI_Qkc3UO^VMhZADbMEgTWM]"
    A$ = A$ + "YG]COF25lMmH1_ggKein[Z<S_S;0GN[XoV`i4<#V7NjkLn^E[BKjE3>DgO<>"
    A$ = A$ + "74n>^l[oe]JL8TQcM\_S9>cc\nN2n0?#`4K<XWmIcL7>k]id8\NE#^V#`M7`"
    A$ = A$ + "hkhc=]YTmnaVWEH1gAIialZL[3dE_NBoLfVTnl=g]iIGSjE`Tn6O3a]_M5XY"
    A$ = A$ + "hkHDPkf:jk<VVEH0g7`iALPC_j7oS3Zc3ah>kc^[kM<QPNE`>7;0MUl8FmT?"
    A$ = A$ + "iTcbJP<oo:;iAM;hdZ8WE<g:b[I0egdBWWm^il2ZMmZMjcD81eg`_hGT?a\["
    A$ = A$ + "I=FM>XInfOkla_oUobe_S^H^ELfh3Tj]2jVk0W#C_JV[JERKWkJ#?IGfUl9f"
    A$ = A$ + "mh?nhX]]=CcBKlaohiSon<>Sjc]jV_iTnbN0ikgkE\R^j>U8dd[2je42DSji"
    A$ = A$ + "Al;LD7U=?;=aaMLiSOn`>\ji\Rm3lN_gPk\?dHNf;[jE1_VEN]OQ>Vh4]lIY"
    A$ = A$ + "1VdTb?O\C[Rn=d]N[1G]]Tnn_IncOnNA[BcjEkdW]#TlDc2^_k[nMi^d?[E9"
    A$ = A$ + "h>j>_lY_WgCmcK3gmK\GP1HoLdgi]:4d[f];ob5g^gCPF2W;blDcRJ\=PboJ"
    A$ = A$ + "`3WahldOjVG5angd=UDoM1fIcJGoNO?_LfV3=m:V3i^Aob#1nP^6Rehl0VWa"
    A$ = A$ + "hSH41eIc8HITS\HdZ8OE\?c4g48eIUSAOYGJVN8Z_bKEXXG=ggdKBLO#?1aK"
    A$ = A$ + "nn<AKccB6bCogKi]DO_0I^ELoDZlkmdVaDN5_RMXGamO3SQ[:jE>=;Ym1m<4"
    A$ = A$ + "cAOoXVO<ge]8WI1fg9[NbKOfTWLmiFM]GKLdmL?1kmlFSgEGnD[:4d[P178m"
    A$ = A$ + "jeF2[GSLATgankkn6TO_\JYfl4bMOFje1B?]RhT0do=XJaM>m:fC#OVWm#B_"
    A$ = A$ + "ZD<7;PH#^_17lPcoa0\GkXc7PamZPmJ_bOO4a1>]Z[nZCjES1FM;h`e[SmA?"
    A$ = A$ + "icd[D4Lf_X?]WgS5LHiQ_cYXl=>]:^o0YOFALAP^FnY=SI\SJI??bKE8YGEj"
    A$ = A$ + "d\8VTcFQ?_KW682PkBCAI][]hl5hgMJEDWELGS`Jh3D]:`=g:j13mJ?^Z\XG"
    A$ = A$ + "]g4CY0OSGPhC>[m5eH4Pk0HK?4gI:BO0TF[RJ2=`kU\kfYOjmdM<OID_Zd=7"
    A$ = A$ + ";V[3J74[VWW[Snkkg_mK_J?O;j5R5AN4Cc4V#fe0blZ`o7`O7bDNe_jL]N[2"
    A$ = A$ + "Im:HX\g9:`?i5#_PeYEdccb1k7E0omjM=GaE8Sm>]F5e1=nm0OMjYca>WmVl"
    A$ = A$ + "D[:4e[`N<Ali:`Gi=#cPkjT?kWEVaA`LWK#?^I0IncG>K;gO8>]:jSE<gFlg"
    A$ = A$ + "1ngE<V;h2bmjG8de[LJFBk[l>4kbN7NGgULS[L`MLGX[MAO=HdSFNKYkngRj"
    A$ = A$ + "FWn]7[3]TdO[M[3dWm;VbXN5\;d?PDP?c[P6a_igDlicZoPk2f#CgjB_dhXa"
    A$ = A$ + "?Ni]M#jlZC_<n^_k4oKXICK23K;KY#G7HX[GQmIjW`98^Ock#\<m?T]^Ei7_"
    A$ = A$ + "e<nROAm<NKcK>>Ji;GNKBS`I<8mjoh^m2oIPN6KJTmjH>V2OMPU1mZBij21f"
    A$ = A$ + "_8b3;iiHh3GnaOm7TCXRn\BaoN;LQbo\gO`gQVnlel3oQ9eJGPWGmdhdZlIO"
    A$ = A$ + ">^\[GiHJT;C5h3c5X_7cnQbidXFLQhS5kDHmT7bQ47mYodaAO[_EB^K8?cTo"
    A$ = A$ + "6V[1SQOl7?i?o2_`TO_Gb;9ie9mWm>U5\PjjDT[:bO6mJ_Bfm7YC[b=gZRD["
    A$ = A$ + "Z<XGQmJHlmG:`GjMhkSILmCl4igm^SQO8M^ZXN9X76cjj3\N]G[HoZ=_fdc]"
    A$ = A$ + ":?jo2UMm:WVUdnb2AgRiVXQm?dXijDTCMl?hW2XkOifRJ??iE?I_:ZG=J^S^"
    A$ = A$ + "UfWVgJF\>:fO9jC^J>7>E1Vglb^n?ZoCl;hO`?EBbEUSY=mY_SjG`M61=mZN"
    A$ = A$ + "CcRJ0AJoJQXKA>WinaQa7B?^]ZaaN\=GW2oA9DW2B_6#jm2iE_RYZYGEjGGX"
    A$ = A$ + "3G^ZYg^m:OUb?6^:AJ]:ZEQKh6Bl3h?:AiZZIjE^J]ZXZ=db\NU3\U3Z<d?B"
    A$ = A$ + "K7X^78GlKI;9SQ6b#TOlLI4\[Oe_JMM:ZC1^_Ua^COf8P?_b]267idZBOGg8"
    A$ = A$ + "UFEID_ZB=?;PeO`nUcMY2eT8mokCmDUO<NIP?aW8klYHOoXVh`>G1jCn=k\<"
    A$ = A$ + ";YFEID_bYI]7Wci8^o^#Q_SWiEbMXj?mW:kIW^<`WlCV]O:`MF3fEbWN5X?C"
    A$ = A$ + "?ne^fLo^S`d[bZIEfSYJ:lMnd3TY><Im:GceTLVKUNlO8PCOb=O:Z?1\OH7a"
    A$ = A$ + "NFAj]dYG38WUI9c_NEB_JADCh:`oGh`H:Z=nWiIB6[aiGSi7XicfSTLJWFF]"
    A$ = A$ + ":bS>f;\KHo`>Rm\2XEUF_BC[3\\[Gid\Z4eh#[`=O;b;?kS5eY6S5GcJTGW#"
    A$ = A$ + ";JD^mjSiBMMGGbJZaNQM[TWSZnC[RJG`ggUlVNEkYI=6>cY:8F#<HN1<fSc7"
    A$ = A$ + "2g1;LFAFojSS^T;9>jMm^TGkX89miAfEGjD3EH?hN:m1O`Tml[R\f_d<Z[jZ"
    A$ = A$ + "bdKSedj0[:jE>=[5GEGKHSh>K?TcH>g8<6mj_nTko>VSa7l3:_VR?QWW6c;5"
    A$ = A$ + "?Wllbc=?oonOORmPiBEadXLT>WE\6`R^_;HjEIe[Zl[;\ALihjIOfhX7jQB>"
    A$ = A$ + "?e\FXJO7KOSWO5_2ieJj5njOmMNNDlLac7?Wllbc=?o\gZEDM:7YcI5JEJKM"
    A$ = A$ + "PE9m:7h3V;m[454OX:Le`5WW4b]<SSY>S^aK<inVRm9SakGl577=SI8_FT3f"
    A$ = A$ + "o0Z_odjBYW35O^i><SW3j]WlLaJRMmSh:^65<eJS;J<WEJLNEEAm:KNF30>M"
    A$ = A$ + ";Z5b]]]hX7mACj=EL_CA>0AkRJkVjA2=QcmLSSFdR:>m9^7bhLNONWg>[AiZ"
    A$ = A$ + "C:dXhc9[eS?gTkLN>HND^JlddYf1=Nf0ejlZZRjE>=;bShDn8O4aSE22Hl=i"
    A$ = A$ + "kRL#oD?EbHokonCda8_m\f:fG=j?MToNVG3c53m\VYYd=`k5PNTKNCl_WKol"
    A$ = A$ + "hc1md#nLai>V?WX=EBjo`i1kakkmU9WEL?WZal[Gee[LJFmE3lUYk;jR4gl`"
    A$ = A$ + "8_?X;#^Z9WeDCUdk4i^0QjFj>_chXKkfBZQ2jQ1<W7dGhNRQeY1Xi`oUo<Po"
    A$ = A$ + "NnmhgWG7_NjCklnaiPQgOZaLG>biOOnLHcKZ]IlWiI^3]:Z7DG_\BkJEEEm:"
    A$ = A$ + "WV5iEL2\V65435dhd_Hn<T3OdAHmGXY#o0VJIbYUA>T#gi1NPTi3iPoolWcO"
    A$ = A$ + "?oNlkc[SG?iLRg?bk4_oVnDGch>Wc9Hf;#C_JWe\HmjVVUAEPdJEJXg`HjEM"
    A$ = A$ + "WVUEKF6UM6oWoc7dc[bd[bZIai?ObOh?\haE66nVdgY=QjlZ<mZ\PocVWUAI"
    A$ = A$ + "S1m\?KYHNEVNEFLk?2e;g<>RS#lh<3SNUmi#>4Eeke=m:o[IQodVWUAIPdc["
    A$ = A$ + "2]:G][KjEboLhKM;d\X^DT>Vc`XC9MnZ#[Rhh#=OEVNEk[IaL]61eZX2R1=<"
    A$ = A$ + "J76nVfDVe0Zen2SYGUOJF<?JYS3=<68JLO09^]<YEIjE]WV5cUNF=J[<<D4k"
    A$ = A$ + "G=]YdJEL7<GFF3XYGeihZgQAaiKC1aW66`8GojgYk72=goZ<mZR3gj3WU]n#"
    A$ = A$ + "35#EHmOVNE_[IA]`cl]U>NeXjBSJEUeeoIjEnAc2XW1=KK^F658CKfcNWZ1d"
    A$ = A$ + "#^Ne=mZRCcb]gQSTNeT2RU=:g\;KH3IbE5cYZ<D3XVNEaZKag_aL]6j3o`R7"
    A$ = A$ + "CKDnPhZdjD<_:RgZ2[ocd[b7=;V[5OOgTinlC1ah6U3fcSkhbT[:fo?Rc:ki"
    A$ = A$ + "Egd[:HM[E^BaSe=2GB[AU>WjEEM:C_:Od[LkO8WI[Y\lU;NL_AhaTOc_i<JE"
    A$ = A$ + "\n?RW8^Z:U[:C_ZHe]LceJo[moFja06:W]_mhY^h5W9?E<W:CW:;I\IVNUG9"
    A$ = A$ + "mL]VTMoQId2J\W:`iDVhVZnjoJT<f=C_bkhnNAgN8>mJ<XWki4OlQQl#L`na"
    A$ = A$ + "l_KX?EEEgk_fQ<f#C_:g8mJ4YVIHONfS?f7Cla<65?kn7mS^CiWbE;EV>E[9"
    A$ = A$ + "S]dd[bELmj1V[5aWXI9mH7SRW6gk?R3H>E^jDgd[jObH;=mZ23gL]875T[RA"
    A$ = A$ + "OiG^hSS<b?`oJiXZgad[TQ6GO8a^\^0Y7GIhOJLnD^nnIEXO:hK<m:i9mj4i"
    A$ = A$ + "nFRhiMk<>3a7WIdmPo[IcWbMOJIiYZk`d[d1Yg7ARY9fNB__gWhSk<j<6nVg"
    A$ = A$ + "LldVi<kgiCIiXZg`d[d7^iKAl=JGT?fnF[hfg^hS7=J2el;=^V?KnDi3VNU>"
    A$ = A$ + "aYIAn=H_SHo4AcJo]n4XZHJcI>kT>U[_DU>oDVFUO`d[d?YG[8S1H\0ciJo["
    A$ = A$ + "]^3Y7_FeHdGiE6?=nNS6dX`OhdX\elUOHjEQ3^iLaIlY_NKJ]eK`HUYL47Qh"
    A$ = A$ + "SS[2PM^Im=1l3h?`_hFgWYEU?HjEQ9=CkRa>XO]G_egZhS];3PM\IeRP[g^P"
    A$ = A$ + "MWekIiVZh`d[2GLO?^;gl^J?eYKm?ljNMR?V?41kFcbO^CW2kLjLXKJE57VN"
    A$ = A$ + "EiPdJG^J#]Am;bkb^MjW^hj1J2\7=Z=UFObE3jF^ce1VNEiT6e_Lme6giFTe"
    A$ = A$ + "e`HB6Kbi_MHobOYhJ7i9llehi<^amd3]9GoA0kEjejIJDj0C_ZLSK\Vk\ohj"
    A$ = A$ + "[=^JBe=g;WfenN`7Ll#OT7ALm5O0?7lldOJD^i#Q65f3dXJ<WiV>U^`d[ZNT"
    A$ = A$ + "N^G^c1T[fDKfl_Bc4?UCY_k0MYeRPan=oVakiZFECeSJV^Tk^JPWCGM7HcO:"
    A$ = A$ + "\`d[Zfdhj6KVf5Sek?m;7CJe[>NDGmE7?d7h1lkLTZmn=n?oW__goFY;e<m9"
    A$ = A$ + "gLWLi8gYAI[c;Lad[<J6=>7\dJI\NB6oSV6j1\^BW^FJ]]6YMdKJDg9=^J9`"
    A$ = A$ + "=G9GnVhc1hbkDcdT<MYb1VNUa0AjalYe_LJHXAhf?BG>m1dBLjI>==7>MWdT"
    A$ = A$ + "n_gmJL_7^eaak?jBl_GJ]YVY?IJDU?<m:3OASJ5=CW[CXoN_Tnid#><m:33S"
    A$ = A$ + "#1C_b``8D`d[<<<25<m:33S#1C_b``8D`7jE66665>VNUQQAXPYGIHH4:d9j"
    A$ = A$ + "E6666666666666666666666666666666666666m;oo`>%%L2"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$: END IF: FOR j = 1 TO LEN(B$)
            IF MID$(B$, j, 1) = "#" THEN
        MID$(B$, j) = "@": END IF: NEXT
        FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    btemp$ = _INFLATE$(btemp$, m.SIZE)
    _MEMPUT m, m.OFFSET, btemp$: _MEMFREE m
    BASIMAGE6& = _COPYIMAGE(v&): _FREEIMAGE v&
END FUNCTION


SUB RotoZoom (X AS LONG, Y AS LONG, Image AS LONG, Scale AS SINGLE, Rotation AS SINGLE)
    DIM px(3) AS SINGLE: DIM py(3) AS SINGLE
    W& = _WIDTH(Image&): H& = _HEIGHT(Image&)
    px(0) = -W& / 2: py(0) = -H& / 2: px(1) = -W& / 2: py(1) = H& / 2
    px(2) = W& / 2: py(2) = H& / 2: px(3) = W& / 2: py(3) = -H& / 2
    sinr! = SIN(-Rotation / 57.2957795131): cosr! = COS(-Rotation / 57.2957795131)
    FOR i& = 0 TO 3
        x2& = (px(i&) * cosr! + sinr! * py(i&)) * Scale + X: y2& = (py(i&) * cosr! - px(i&) * sinr!) * Scale + Y
        px(i&) = x2&: py(i&) = y2&
    NEXT
    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, H& - 1)-(W& - 1, H& - 1), Image& TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2))
    _MAPTRIANGLE _SEAMLESS(0, 0)-(W& - 1, 0)-(W& - 1, H& - 1), Image& TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2))
END SUB
