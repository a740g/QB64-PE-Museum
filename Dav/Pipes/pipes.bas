'================
'PIPES.BAS v1.0
'================
'Connect the pipes puzzle game
'Coded by Dav for QB64-GL 1.5 in SEP/2021

'NOTE: Formally called MazeConnect Prototype on the forum.

'============
'HOW TO PLAY:
'============

'Click on pipes to rotate them and connect them as one.
'Object is to make all pipes on board connected to leader.
'Top left pipe is always on, the leader, so start from it.
'When pipes are all connected, you advance to next level.
'There are currently 20 levels.  ESC key exits game.

'SPACE  = restarts level
'RIGHT ARROW = goto next level
'LEFT ARROW = go back a level
'ESC = Quits game

'         VVVVVVV     blus fixed next line to work from his downloaded zip
$EXEICON:'.\icon.ico'
_ICON


RANDOMIZE TIMER

DIM SHARED GridSize, Level, MaxLevel, LD$, LU$, RD$, RU$, HZ$, VT$, BM$

Level = 1: MaxLevel = 13

GridSize = 3 'default starting GridSize is 3x3 (its level 1)
MaxGridSize = 15 'The last GridSize level so far (13 levels right now)

'Declare image names: angle characters, right up, left up, etc
LD$ = "ld": LU$ = "lu"
RD$ = "rd": RU$ = "ru"
HZ$ = "hz": VT$ = "vt"
BM$ = "bm"

'Sound files
new& = _SNDOPEN("sfx_magic.ogg")
move& = _SNDOPEN("sfx_click1.mp3"):
click& = _SNDOPEN("sfx_click2.mp3"):
clap& = _SNDOPEN("sfx_clap.ogg")

'image file
DIM SHARED Solved&
Solved& = _LOADIMAGE("solved.png", 32) '<  thank bplus for this

'For game state saving...to be added later
loaded = 0: fil$ = "pipe.dat"
IF _FILEEXISTS(fil$) THEN
    loaded = 1
END IF

'=======
newlevel:
'=======

SCREEN _NEWIMAGE(640, 640, 32)
'Do: Loop Until _ScreenExists ' <<<<<<<<<< sorry Dav this aint working on my system
_DELAY .25 ' <<<<<<<<<<<<<<<<<<<<<<<<<<<<< does this work for you?
'            No? increase delay time really nice to have centered on screen
_SCREENMOVE _MIDDLE ' <  thank bplus for this , ahhhh that's better
CLS ', _RGB(32, 32, 77)

IF Level = 1 THEN
    back& = _LOADIMAGE("hz-grn.png")
    _PUTIMAGE (0, 0)-(640, 640), back&
    _FREEIMAGE back&
    title& = _LOADIMAGE("title.png")
    _PUTIMAGE (84, 140), title&
    _FREEIMAGE title&
    w$ = INPUT$(1)
    FOR a = 0 TO 64
        LINE (0, 0)-(640, 640), _RGBA(0, 0, 0, a), BF
        _DELAY .02
    NEXT
END IF

PPRINT 100, 300, 30, _RGB(200, 200, 200), 0, "Level:" + STR$(Level) + " of" + STR$(MaxLevel)
_DELAY 2

_SNDPLAY new&

Title$ = "Pipes: Level " + STR$(Level) + " of" + STR$(MaxLevel)
_TITLE Title$

'Make space for variables
REDIM SHARED TileVal$(GridSize * GridSize)
REDIM SHARED TileX(GridSize * GridSize), TileY(GridSize * GridSize)
REDIM SHARED TileClr(GridSize * GridSize), TileClr2(GridSize * GridSize)

TileSize = INT(640 / GridSize) 'The width/height of tiles, in pixels

'set tile values, and generate x/y values...
bb = 1
FOR r = 1 TO GridSize
    FOR c = 1 TO GridSize
        x = (r * TileSize): y = (c * TileSize)
        IF RND(GridSize * 2) = GridSize THEN br = 0
        TileX(bb) = x - TileSize: TileY(bb) = y - TileSize
        TileVal$(bb) = RD$
        TileClr(bb) = 0
        TileClr2(bb) = 0
        bb = bb + 1
    NEXT c
NEXT r

TileClr(1) = 1 'turn on top left leader tile
TileClr2(1) = 1 'make a copy

setmaze 'Load level maze data, it's already scrambled up

firstdraw = 1
GOSUB updatebuttons

DO

    _LIMIT 300

    'wait until mouse button up to continue
    WHILE _MOUSEBUTTON(1) <> 0: n = _MOUSEINPUT: WEND

    trap = _MOUSEINPUT
    IF _MOUSEBUTTON(1) THEN
        mx = _MOUSEX: my = _MOUSEY

        FOR b = 1 TO (GridSize * GridSize)

            tx = TileX(b): tx2 = TileX(b) + TileSize
            ty = TileY(b): ty2 = TileY(b) + TileSize

            IF mx >= tx AND mx <= tx2 THEN
                IF my >= ty AND my <= ty2 THEN
                    'skip any black blocks clicked on
                    IF TileVal$(b) = BM$ THEN GOTO skip

                    _SNDPLAY move&

                    bv2$ = TileVal$(b) 'see what tile it is

                    'rotate right angle tiles
                    IF bv2$ = RD$ THEN TileVal$(b) = LD$
                    IF bv2$ = LD$ THEN TileVal$(b) = LU$
                    IF bv2$ = LU$ THEN TileVal$(b) = RU$
                    IF bv2$ = RU$ THEN TileVal$(b) = RD$

                    'rotate horiz/vert lines
                    IF bv2$ = HZ$ THEN TileVal$(b) = VT$
                    IF bv2$ = VT$ THEN TileVal$(b) = HZ$

                    'show tile
                    IF TileClr(b) = 1 THEN
                        tag$ = "-grn.png"
                    ELSE
                        tag$ = "-wht.png"
                    END IF

                    SHOW TileVal$(b) + tag$, TileX(b), TileY(b), TileX(b) + TileSize, TileY(b) + TileSize

                    GOSUB updatebuttons
                    GOSUB checkforwin

                END IF
            END IF
        NEXT b
    END IF
    skip:

    ink$ = UCASE$(INKEY$)

    IF ink$ = CHR$(32) THEN GOTO newlevel

    'Right arrows advance to next level
    IF ink$ = CHR$(0) + CHR$(77) THEN
        GridSize = GridSize + 1
        Level = Level + 1
        IF Level > MaxLevel THEN Level = 1
        IF GridSize > MaxGridSize THEN
            GridSize = 3 'MaxGridSize  'restart
        END IF
        GOTO newlevel
    END IF

    'Left Arrows go back a level
    IF ink$ = CHR$(0) + CHR$(75) THEN
        GridSize = GridSize - 1
        IF GridSize < 3 THEN GridSize = MaxGridSize
        Level = Level - 1
        IF Level < 1 THEN Level = MaxLevel
        GOTO newlevel
    END IF

LOOP UNTIL ink$ = CHR$(27)

SYSTEM

'============
updatebuttons:
'============

'first tile always on, draw it green
SHOW TileVal$(1) + "-grn.png", TileX(1), TileY(1), TileX(1) + TileSize, TileY(1) + TileSize


'turn all off tile colors first, except 1st
FOR g = 2 TO GridSize * GridSize
    TileClr(g) = 0
NEXT g


'set leader tile flow direction
IF TileVal$(1) = HZ$ THEN direction = 1 'going right
IF TileVal$(1) = VT$ THEN direction = 2 'going down

cur = 1 'start with 1st tile always

'do until can't flow anymore (direction blocked)
DO

    IF direction = 1 THEN 'heading right
        'see if already on the right edge of board
        'if so, it can't go right anymore, so end flow...
        FOR j = (GridSize * GridSize) - GridSize + 1 TO GridSize * GridSize
            IF cur = j THEN GOTO flowdone
        NEXT j
        'now see if one to the right can connect with it.
        'if not connectable, end flow here.
        con = 0 'default is not connectable
        nv$ = TileVal$(cur + GridSize)
        IF nv$ = HZ$ THEN con = 1
        IF nv$ = LU$ THEN con = 1
        IF nv$ = LD$ THEN con = 1
        'if not, end flow here
        IF con = 0 THEN GOTO flowdone
        'looks like it is connectable, so turn it on
        TileClr(cur + GridSize) = 1 'turn piece to the right on.
        'Make new pieve the new current flow position
        tc = (cur + GridSize): cur = tc
        'find/set new direction based on that character
        IF nv$ = HZ$ THEN direction = 1 'right
        IF nv$ = LU$ THEN direction = 4 'up
        IF nv$ = LD$ THEN direction = 2 'down
    END IF

    IF direction = 2 THEN 'heading down
        'see if this one is on the bottom edge
        FOR j = GridSize TO (GridSize * GridSize) STEP GridSize
            IF cur = j THEN GOTO flowdone
        NEXT j
        'now see if new one can connect with this one.
        'if not, end flow here.
        con = 0 'default is not connectable
        nv$ = TileVal$(cur + 1)
        IF nv$ = VT$ THEN con = 1
        IF nv$ = LU$ THEN con = 1
        IF nv$ = RU$ THEN con = 1
        'if not, end flow here
        IF con = 0 THEN GOTO flowdone
        'looks like it must be connectable
        TileClr(cur + 1) = 1 'turn the next piece on too
        'Make it the new current char position
        tc = (cur + 1): cur = tc
        'find/set new direction based on character
        IF nv$ = LU$ THEN direction = 3 'left
        IF nv$ = RU$ THEN direction = 1 'right
        IF nv$ = VT$ THEN direction = 2 'down
    END IF

    IF direction = 3 THEN 'heading left
        'see if this one is on the bottom edge
        FOR j = 1 TO GridSize
            IF cur = j THEN GOTO flowdone
        NEXT j

        'now see if new one can connect with this one.
        'if not, end flow here.
        con = 0 'default is not connectable
        nv$ = TileVal$(cur - GridSize)
        IF nv$ = HZ$ THEN con = 1
        IF nv$ = RU$ THEN con = 1
        IF nv$ = RD$ THEN con = 1
        'if not, end flow here
        IF con = 0 THEN GOTO flowdone
        'looks like it must be connectable
        TileClr(cur - GridSize) = 1 'turn the next piece on too
        'Make it the new current char position
        tc = (cur - GridSize): cur = tc
        'find/set new direction based on character
        IF nv$ = HZ$ THEN direction = 3 'left
        IF nv$ = RU$ THEN direction = 4 'up
        IF nv$ = RD$ THEN direction = 2 'down
    END IF

    IF direction = 4 THEN 'going up
        'see if this one is on the edge of board
        'if so, it can't go up, so end flow...
        FOR j = 1 TO (GridSize * GridSize) STEP GridSize
            IF cur = j THEN GOTO flowdone
        NEXT j
        'now see if new one can connect with this one.
        'if not, end flow here.
        con = 0 'default is not connectable
        nv$ = TileVal$(cur - 1)
        IF nv$ = VT$ THEN con = 1
        IF nv$ = LD$ THEN con = 1
        IF nv$ = RD$ THEN con = 1
        'if not, end flow here
        IF con = 0 THEN GOTO flowdone
        'looks like it must be connectable
        TileClr(cur - 1) = 1 'turn the next piece on too
        'Make it the new current char position
        tc = (cur - 1): cur = tc
        'find/set new direction based on character
        IF nv$ = VT$ THEN direction = 4 'up
        IF nv$ = LD$ THEN direction = 3 'left
        IF nv$ = RD$ THEN direction = 1 'right
    END IF

LOOP

flowdone:

IF firstdraw = 0 THEN

    'draw/colorize board
    FOR t = 2 TO (GridSize * GridSize)
        IF TileClr(t) = 1 AND TileClr2(t) = 0 THEN
            'show green...
            SHOW TileVal$(t) + "-grn.png", TileX(t), TileY(t), TileX(t) + TileSize, TileY(t) + TileSize
        END IF
        IF TileClr(t) = 0 AND TileClr2(t) = 1 THEN
            'show white...
            SHOW TileVal$(t) + "-wht.png", TileX(t), TileY(t), TileX(t) + TileSize, TileY(t) + TileSize
        END IF
    NEXT t

ELSE

    'draw/colorize board
    FOR t = 2 TO (GridSize * GridSize)
        IF TileClr(t) = 1 THEN
            tag$ = "-grn.png"
        ELSE
            tag$ = "-wht.png"
        END IF
        SHOW TileVal$(t) + tag$, TileX(t), TileY(t), TileX(t) + TileSize, TileY(t) + TileSize
    NEXT t

    firstdraw = 0

END IF


'copy current color values
FOR t = 1 TO GridSize * GridSize
    TileClr2(t) = TileClr(t)
NEXT t


'===========
checkforwin:
'===========

all = 0
FOR w = 1 TO (GridSize * GridSize)
    IF TileClr(w) = 1 THEN all = all + 1
    IF TileVal$(w) = BM$ THEN all = all + 1 'add any blocks
NEXT w

IF all = (GridSize * GridSize) THEN

    ' bplus rewrote this section to fade in the You did it! sign over the gameboard =======================
    ' Solved& has already been loaded after sounds at start of program
    _SNDPLAY clap&
    snap& = _NEWIMAGE(_WIDTH, _HEIGHT, 32)
    _PUTIMAGE , 0, snap&
    FOR alph = 0 TO 255
        CLS
        _PUTIMAGE , snap&, 0 'background
        _SETALPHA alph, , Solved&
        _PUTIMAGE (166, 258), Solved&
        _LIMIT 40 ' 255 frames in 2 secs
        _DISPLAY ' damn blinking!!! without this
    NEXT
    _AUTODISPLAY '<<<<<< back to not needing _display
    _FREEIMAGE snap&
    ' end of bplus meddling ================================================================================

    Level = Level + 1

    GridSize = GridSize + 1

    IF Level > MaxLevel THEN Level = 1

    IF GridSize > MaxGridSize THEN
        GridSize = 3 'MaxGridSize  'restart
    END IF

    GOTO newlevel

END IF

RETURN


SUB setmaze ()

    IF Level = 1 THEN
        GridSize = 3
        a$ = "" '3x3 MazeConnect GridSize
        a$ = a$ + "hzrdru"
        a$ = a$ + "hzhzhz"
        a$ = a$ + "ldluld"
    END IF

    IF Level = 2 THEN
        GridSize = 4
        a$ = "" '4x4 MazeConnect GridSize
        a$ = a$ + "vtvtruru"
        a$ = a$ + "rdvtluhz"
        a$ = a$ + "hzrdruhz"
        a$ = a$ + "ldluldlu"
    END IF

    IF Level = 3 THEN
        GridSize = 5
        a$ = "" '5x5 MazeConnect GridSize
        a$ = a$ + "hzrdvtvtld"
        a$ = a$ + "hzhzrdrdhz"
        a$ = a$ + "hzhzldhzhz"
        a$ = a$ + "hzldvtluhz"
        a$ = a$ + "ldvtvtvtlu"
    END IF

    IF Level = 4 THEN
        GridSize = 6
        a$ = "" '6x6 MazeConnect GridSize
        a$ = a$ + "hzrdrurdvtru"
        a$ = a$ + "hzhzhzhzrdlu"
        a$ = a$ + "ldluhzhzldru"
        a$ = a$ + "rdvtluhzbmhz"
        a$ = a$ + "hzrdruldruhz"
        a$ = a$ + "ldluldvtlulu"
    END IF

    IF Level = 5 THEN
        GridSize = 7
        a$ = "" '7x7 MazeConnect GridSize
        a$ = "vtruvtvtrurdru"
        a$ = a$ + "rdlurdruldluhz"
        a$ = a$ + "ldvtluldrurdlu"
        a$ = a$ + "rdvtrurdluldru"
        a$ = a$ + "ldruldlurdvtlu"
        a$ = a$ + "rdlurdruldvtru"
        a$ = a$ + "ldvtluldvtvtlu"
    END IF

    IF Level = 6 THEN
        GridSize = 8
        a$ = "" '8x8 MazeConnect GridSize
        a$ = a$ + "hzvtrurdrurdrubm"
        a$ = a$ + "hzbmldluhzhzldru"
        a$ = a$ + "ldvtrurdluhzrdlu"
        a$ = a$ + "rdvtluldvtluldru"
        a$ = a$ + "ldrurdvtrurdvtlu"
        a$ = a$ + "bmhzhzbmldlurdru"
        a$ = a$ + "rdluldvtvtvtluhz"
        a$ = a$ + "ldvtvtvtvtvtvtlu"
    END IF

    IF Level = 7 THEN
        GridSize = 9
        a$ = "" '9x9 MazeConnect GridSize
        a$ = a$ + "hzrdvtvtrurdrurdru"
        a$ = a$ + "hzldvtruldluldluhz"
        a$ = a$ + "ldvtruldrubmrdvtlu"
        a$ = a$ + "rdruldruldruldrubm"
        a$ = a$ + "hzldruldruldruldru"
        a$ = a$ + "ldruhzbmldruhzbmhz"
        a$ = a$ + "rdluldvtvtluldruhz"
        a$ = a$ + "hzrdrurdvtrurdluhz"
        a$ = a$ + "ldluldlubmldluvtlu"
    END IF

    IF Level = 8 THEN
        GridSize = 10
        a$ = "" '10x10 MazeConnect GridSize
        a$ = a$ + "vtvtvtrurdrurdvtrubm"
        a$ = a$ + "hzrdvtluhzhzldruldru"
        a$ = a$ + "hzldvtvtluldruhzrdlu"
        a$ = a$ + "hzbmrdvtvtruldluldru"
        a$ = a$ + "hzrdlurdruhzrdvtvtlu"
        a$ = a$ + "hzhzrdluhzldlurdrubm"
        a$ = a$ + "hzhzhzbmldrubmhzldru"
        a$ = a$ + "hzldlurdruldvtlurdlu"
        a$ = a$ + "hzrdruhzldrurdruldru"
        a$ = a$ + "ldluldlubmldluldvtlu"
    END IF

    IF Level = 9 THEN
        GridSize = 11
        a$ = "" '11x11 MazeConnect GridSize
        a$ = a$ + "hzvtrubmrdvtrubmrdvtru"
        a$ = a$ + "ldruldruldruldruldruhz"
        a$ = a$ + "bmldruldruldruldruhzhz"
        a$ = a$ + "rdruldruldruldruldluhz"
        a$ = a$ + "hzldruldruldruldrurdlu"
        a$ = a$ + "ldruldruldruldruhzldru"
        a$ = a$ + "bmldruldruldruldlurdlu"
        a$ = a$ + "rdruldruldruldrurdlubm"
        a$ = a$ + "hzldruldruldvtluldvtru"
        a$ = a$ + "ldruldvtlurdrurdrurdlu"
        a$ = a$ + "bmldvtvtvtluldluldlubm"
    END IF

    IF Level = 10 THEN
        GridSize = 12
        a$ = "" '12x12 MazeConnect GridSize
        a$ = a$ + "vtvtrubmbmrdrurdrurdvtru"
        a$ = a$ + "bmbmhzbmrdluldluhzhzrdlu"
        a$ = a$ + "bmrdlurdlurdrurdluhzldru"
        a$ = a$ + "rdlurdlurdluhzhzrdlurdlu"
        a$ = a$ + "ldruldvtlurdluhzhzbmldru"
        a$ = a$ + "bmldvtvtruhzbmldlurdvtlu"
        a$ = a$ + "rdvtvtvtluhzrdvtvtlurdru"
        a$ = a$ + "ldrurdvtvtluhzrdvtvtluhz"
        a$ = a$ + "rdluhzbmbmbmldlurdrurdlu"
        a$ = a$ + "hzrdlurdrurdrubmhzhzhzbm"
        a$ = a$ + "ldlurdluhzhzhzrdluhzldru"
        a$ = a$ + "vtvtlubmldluldlubmldvtlu"
    END IF

    IF Level = 11 THEN
        GridSize = 13
        a$ = "" '13x13 MazeConnect GridSize
        a$ = a$ + "hzvtvtvtvtvtrurdrurdrurdru"
        a$ = a$ + "hzrdrurdvtruldluhzhzldluhz"
        a$ = a$ + "hzhzhzhzspldvtruhzhzrdruhz"
        a$ = a$ + "hzhzhzldrubmrdluldluhzhzhz"
        a$ = a$ + "hzhzldvtlurdlurdvtvtluldlu"
        a$ = a$ + "hzldrubmrdlubmldvtvtrurdru"
        a$ = a$ + "ldruldruhzbmbmbmrdruhzhzhz"
        a$ = a$ + "rdlurdluldrubmrdluhzldluhz"
        a$ = a$ + "hzrdlurdruldvtlurdlubmrdlu"
        a$ = a$ + "hzldruhzldrurdvtlurdruldru"
        a$ = a$ + "hzrdluhzbmldlurdvtluhzrdlu"
        a$ = a$ + "hzhzrdlurdvtruhzrdvtluldru"
        a$ = a$ + "ldluldvtlubmldluldvtvtvtlu"
    END IF

    IF Level = 12 THEN
        GridSize = 14
        a$ = "" '14x14 MazeConnect GridSize
        a$ = a$ + "hzrdrurdvtvtrurdrurdvtvtrubm"
        a$ = a$ + "hzhzhzldvtruhzhzhzhzrdruhzbm"
        a$ = a$ + "ldluhzrdruhzldluldluhzhzhzbm"
        a$ = a$ + "rdruhzhzhzldvtvtvtruhzldlubm"
        a$ = a$ + "hzhzhzhzhzrdrurdruhzldvtrubm"
        a$ = a$ + "hzhzhzhzhzhzhzhzhzhzrdruldru"
        a$ = a$ + "hzhzldluhzhzhzhzhzhzhzldvtlu"
        a$ = a$ + "hzldvtruhzhzhzhzhzhzldrurdru"
        a$ = a$ + "hzrdruhzldluhzhzhzhzbmldluhz"
        a$ = a$ + "ldluhzldvtruhzhzhzhzrdrurdlu"
        a$ = a$ + "rdruhzrdvtluhzhzldluhzhzhzbm"
        a$ = a$ + "hzldluldvtvtluhzrdvtluhzhzbm"
        a$ = a$ + "hzvtvtvtvtvtvtluldrurdluhzbm"
        a$ = a$ + "ldvtvtvtvtvtvtvtvtluldvtlubm"
    END IF

    IF Level = 13 THEN
        GridSize = 15
        a$ = "" '15x15 MazeConnect GridSize
        a$ = a$ + "vtvtrurdrurdrurdrubmrdvtvtvtru"
        a$ = a$ + "vtruldluhzhzldluldvtlurdvtruhz"
        a$ = a$ + "rdlubmbmhzldvtvtrurdvtlubmldlu"
        a$ = a$ + "ldrurdruhzbmrdruhzldrurdvtvtru"
        a$ = a$ + "bmhzhzldlurdluhzldruldlurdvtlu"
        a$ = a$ + "rdluldrurdlubmhzrdlurdruldrubm"
        a$ = a$ + "ldrubmldlurdruldlubmhzhzbmldru"
        a$ = a$ + "rdlurdvtvtluldrurdruhzhzrdvtlu"
        a$ = a$ + "ldvtlurdvtvtvtluhzldluhzldvtru"
        a$ = a$ + "rdvtvtlurdvtvtruldrurdlurdruhz"
        a$ = a$ + "ldvtrurdlubmrdlurdluhzrdluldlu"
        a$ = a$ + "rdvtluldrurdlurdlurdluhzbmrdru"
        a$ = a$ + "ldvtrurdluhzbmldruldruldvtluhz"
        a$ = a$ + "rdvtluldruhzrdruldruldvtrurdlu"
        a$ = a$ + "ldvtvtvtluldluldvtlubmbmldlubm"
    END IF

    dd = 1
    FOR s = 1 TO LEN(a$) STEP 2
        b$ = MID$(a$, s, 2)
        IF b$ = "vt" THEN rotate dd, 1
        IF b$ = "hz" THEN rotate dd, 1
        IF b$ = "ld" THEN rotate dd, 2
        IF b$ = "lu" THEN rotate dd, 2
        IF b$ = "rd" THEN rotate dd, 2
        IF b$ = "ru" THEN rotate dd, 2
        IF b$ = "bm" THEN TileVal$(dd) = BM$

        dd = dd + 1
    NEXT s

END SUB

SUB rotate (num, typ)

    'there are only two types of rotating characters,
    'straight lines, or right angles...

    'randomly rotate straight character
    IF typ = 1 THEN
        IF INT(RND * 2) = 0 THEN
            TileVal$(num) = VT$
        ELSE
            TileVal$(num) = HZ$
        END IF
    END IF

    'randomly rotate right angles...
    IF typ = 2 THEN
        rn = INT(RND * 4) + 1
        IF rn = 1 THEN TileVal$(num) = LD$
        IF rn = 2 THEN TileVal$(num) = LU$
        IF rn = 3 THEN TileVal$(num) = RD$
        IF rn = 4 THEN TileVal$(num) = RU$
    END IF

END SUB

SUB SHOW (i$, x1, y1, x2, y2)
    'Just a little sub to load & put an image at x1/y1
    ttmp = _LOADIMAGE(i$)
    _PUTIMAGE (x1, y1)-(x2, y2), ttmp
    _FREEIMAGE ttmp
END SUB

SUB PPRINT (x, y, size, clr&, trans&, text$)
    'This sub outputs to the current _DEST set
    'It makes trans& the transparent color

    'x/y is where to print text
    'size is the font size to use
    'clr& is the color of your text
    'trans& is the background transparent color
    'text$ is the string to print

    '=== get users current write screen
    orig& = _DEST

    '=== if you are using an 8 or 32 bit screen
    bit = 32: IF _PIXELSIZE(0) = 1 THEN bit = 256

    '=== step through your text
    FOR t = 0 TO LEN(text$) - 1
        '=== make a temp screen to use
        pprintimg& = _NEWIMAGE(16, 16, bit)
        _DEST pprintimg&
        '=== set colors and print text
        CLS , trans&: COLOR clr&
        PRINT MID$(text$, t + 1, 1);
        '== make background color the transprent one
        _CLEARCOLOR _RGB(0, 0, 0), pprintimg&
        '=== go back to original screen  to output
        _DEST orig&
        '=== set it and forget it
        x1 = x + (t * size): x2 = x1 + size
        y1 = y: y2 = y + size
        _PUTIMAGE (x1 - (size / 2), y1)-(x2, y2 + (size / 3)), pprintimg&
        _FREEIMAGE pprintimg&
    NEXT
END SUB
