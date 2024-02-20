OPTION _EXPLICIT
'Air Hockey v2-1.bas for QB64
' Started in QB64 Walter fork version (B+=MGA) 2017-09-05
' The first version was a direct translation from SmallBASIC,
' Now v2.0 add some more graphic image handling, try new things.
' 2020-03-11 v2-1 (QB64 v1.4 now) cleanup some code:
' Fix _MOUSEINPUT block too newbie ;)
' Fix flat spots on strikers how long have they been there?
' Increase frames per sec and slow puck speed for less double images.
' Oh that sped up the AI player! Nice.
' Do start shots to the side instead of directly at goal. MUCH BETTER!
' Update opening screen with this info. Now pause the puck at start.
' Ran OPTION _EXPLICIT and found a type-O that has been 0 all this time!

' v2020-03-23 Dark Theme as suggested by Danlin also fix fill circle with color
' also lighten color around the puck, oh fix the rest of the _rgb to rgb32.

RANDOMIZE TIMER
CONST xmax = 1200, ymax = 700 'screen dimensions
SCREEN _NEWIMAGE(xmax, ymax, 32)
_TITLE "Air Hockey v2020-03-23 Dark Theme"
_DELAY .25
_SCREENMOVE _MIDDLE

CONST pr = 16 '              puck radius
CONST pr2 = 2 * pr '         puck diameter = bumper width = radius of strikers
CONST tl = xmax '            table length
CONST tw = tl / 2 '          table width
CONST tw13 = .3333 * tw \ 1 'goal end point
CONST tw23 = .6667 * tw \ 1 'goal end point
CONST speed = 15 '           puck speed also see _limit in main loop
CONST midC = 316 '           (tl - 2 * pr2) \ 4 + pr2   'mid line of computer's sin field
CONST rangeC = 252 '         316 - 252 = 64 (bumper + pr2)  316 + 252 = 568 (mid screen - pr2)

COMMON SHARED f&, table&, computer, player, s$, tx, px, py, pa, psx, psy, c1, csx, csy, strkr&

f& = _LOADFONT(_DIR$("font") + "arial.ttf", 25) ' arial normal style  if you have windows
_FONT f& '                                         arial is pretty common if you don't have Windows

table& = _NEWIMAGE(xmax, tw, 32)
_DEST table&
drawTable

strkr& = _NEWIMAGE(2 * pr2 + 1, 2 * pr2 + 1, 32) ' more space to avoid right and bottom flat edges
_DEST strkr&
striker pr2, pr2

_DEST 0 '                                                    Opening screen
cp 7, "Air Hockey, first to score 21 goals wins!"
cp 9, "Player you will be defending the goal on the right (a black slot)."
cp 10, "Your goal is on the left, defended by the computer."
cp 12, "The puck will be started going up and down in the middle of"
cp 13, "the screen at slight angle towards a randomly selected goal."
cp 16, "Press any when ready..."
SLEEP
_DELAY 1
_MOUSEHIDE
CLS
updateScore
_PUTIMAGE (0, 0), table&, 0
drawComputerStriker
WHILE _MOUSEINPUT: WEND
psx = _MOUSEX: psy = _MOUSEY
drawPlayerStriker
initball
WHILE player < 21 AND computer < 21 '        play until someone scores 21
    CLS
    updateScore
    _PUTIMAGE (0, 0), table&, 0
    drawComputerStriker
    WHILE _MOUSEINPUT: WEND
    psx = _MOUSEX: psy = _MOUSEY
    drawPlayerStriker
    drawPuck
    _DISPLAY
    _LIMIT 60 '<<<<<<<<<<<<<  slow down, speeed up as needed for good game
WEND
IF computer > player THEN '                                    last report
    s$ = "Game Won by Computer."
    tx = 450
ELSE
    s$ = "Game Won by Player!"
    tx = 470
END IF
COLOR _RGB32(200, 240, 140)
_PRINTSTRING (tx, tw + 30), s$
_DISPLAY
_DELAY 3

SUB initball 'toss puck out to side slightly angled to one goal or the other
    DIM pao
    px = tl / 2: py = tw / 2: pao = _PI(1 / 10) * RND
    puck px, py
    _DISPLAY
    _DELAY .3
    IF RND < .5 THEN pa = _PI(.5) ELSE pa = _PI(1.5)
    IF RND < .5 THEN pa = pa + pao ELSE pa = pa - pao
END SUB

SUB updateScore
    COLOR _RGB32(40, 255, 255)
    s$ = "Computer: " + STR$(computer) + SPACE$(67) + "Player: " + STR$(player)
    _PRINTSTRING (200, tw + 30), s$
END SUB

SUB drawTable
    DIM i, shade
    FOR i = 0 TO pr2 STEP 4
        shade = 64 + i / pr2 * 100
        COLOR _RGB32(shade, shade, shade)
        LINE (i, i)-(tl - i, tw - i), , BF
    NEXT
    LINE (pr2, pr2)-(tl - pr2, tw - pr2), _RGB32(190, 230, 255), BF 'field
    LINE (pr2, pr2)-(tl - pr2, tw - pr2), _RGB32(50, 0, 50), BF 'field
    LINE (pr, tw13)-(pr2, tw23), _RGB32(60, 60, 60), BF
    LINE (tl - pr2, tw13)-(tl - pr, tw23), _RGB32(60, 60, 60), BF
    LINE (tl \ 2 - 1, pr2)-(tl \ 2 + 1, tw - pr2), _RGB32(128, 128, 128), BF
END SUB

SUB drawPlayerStriker
    IF psx - pr2 < tl / 2 THEN psx = tl / 2 + pr2
    IF psx + pr2 > tl - pr2 THEN psx = tl - 2 * pr2
    IF psy - pr2 < pr2 THEN psy = 2 * pr2
    IF psy + pr2 > tw - pr2 THEN psy = tw - 2 * pr2
    _PUTIMAGE (psx - pr2, psy - pr2), strkr&, 0
END SUB

SUB drawComputerStriker
    c1 = c1 + _PI(1 / 80)
    csx = midC + rangeC * SIN(c1)
    IF px > csx THEN csy = py + pr2 * 1.5 * SIN(c1)
    IF csy - pr2 < pr2 THEN csy = 2 * pr2
    IF csy + pr2 > tw - pr2 THEN csy = tw - 2 * pr2
    _PUTIMAGE (csx - pr2, csy - pr2), strkr&, 0
END SUB

SUB drawPuck
    'update ball x, y and see if hit anything
    DIM i, shade
    px = px + speed * COS(pa)
    py = py + speed * SIN(pa)

    IF px - pr < pr2 THEN
        IF tw13 < py - pr AND py + pr < tw23 THEN 'through computer slot, player scores
            player = player + 1
            CLS
            updateScore
            drawTable
            striker csx, csy
            striker psx, psy
            puck pr, py
            FOR i = 0 TO pr STEP 4
                shade = 64 + i / pr2 * 100
                COLOR _RGB32(shade, shade, shade)
                LINE (i, tw13)-(pr, tw23), , BF ' wow tw13 has been 0
            NEXT
            snd 1200, 200
            snd 2200, 300
            _DISPLAY
            initball
            _DELAY .5
            EXIT SUB
        ELSE
            snd 2600, 8
            pa = _PI(1) - pa
            px = pr2 + pr
        END IF
    END IF

    IF px + pr > tl - pr2 THEN
        IF tw13 < py - pr AND py + pr < tw23 THEN
            computer = computer + 1
            CLS
            updateScore
            drawTable
            striker csx, csy
            striker psx, psy
            puck tl - pr, py
            FOR i = 0 TO pr STEP 4
                shade = 64 + i / pr2 * 100
                COLOR _RGB32(shade, shade, shade)
                LINE (tl - pr, tw13)-(tl - i, tw23), , BF 't13 again!
            NEXT
            snd 2200, 300
            snd 1200, 200
            _DISPLAY
            initball
            _DELAY .5
            EXIT SUB
        ELSE
            snd 2600, 5
            pa = _PI(1) - pa
            px = tl - pr2 - pr
        END IF
    END IF

    IF py - pr < pr2 THEN ' hit top boundry
        snd 2600, 8
        pa = -pa
        py = pr2 + pr
    END IF

    IF py + pr > tw - pr2 THEN ' hit bottom boundry
        snd 2600, 8
        pa = -pa
        py = tw - pr2 - pr
    END IF

    IF SQR((px - psx) ^ 2 + (py - psy) ^ 2) < (pr + pr2) THEN 'contact player striker
        pa = _ATAN2(py - psy, px - psx)
        'boost puck away
        px = px + .5 * speed * COS(pa)
        py = py + .5 * speed * SIN(pa)
        snd 2200, 4
    END IF
    IF SQR((px - csx) ^ 2 + (py - csy) ^ 2) < (pr + pr2) THEN 'contact computer striker
        pa = _ATAN2(py - csy, px - csx)
        'boost puck away
        px = px + .5 * speed * COS(pa)
        py = py + .5 * speed * SIN(pa)
        snd 2200, 4
    END IF
    puck px, py ' here it is!
END SUB

SUB puck (x, y)
    fillcirc x, y, pr, _RGB32(160, 160, 160)
    fillcirc x, y, pr - 4, _RGB32(190, 100, 0)
END SUB

SUB striker (x, y)
    DIM i, shade
    FOR i = pr2 TO pr STEP -1
        shade = 164 - 90 * SIN(i * _PI(2) / pr)
        fillcirc x, y, i, _RGB32(shade, shade, shade)
    NEXT
    FOR i = pr TO 0 STEP -1
        shade = 185 + 70 * (pr - i) / pr
        fillcirc x, y, i, _RGB32(shade, shade, shade)
    NEXT
END SUB

'Steve McNeil's  copied from his forum   note: Radius is too common a name
SUB fillcirc (CX AS LONG, CY AS LONG, R AS LONG, C AS _UNSIGNED LONG)
    DIM subRadius AS LONG, RadiusError AS LONG
    DIM X AS LONG, Y AS LONG

    subRadius = ABS(R)
    RadiusError = -subRadius
    X = subRadius
    Y = 0

    IF subRadius = 0 THEN PSET (CX, CY), C: EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), C, BF

    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    WEND
END SUB

SUB snd (frq, dur)
    SOUND frq / 2.2, dur * .01
END SUB

SUB cp (lineNum, s$)
    DIM x, y
    '1200 pixels / 85 characters = 14.11 pixels/char wide
    '700 pixels / 28 lines = 18.42 pixels / char high
    x = (xmax - 11 * LEN(s$)) \ 2
    y = lineNum * 25
    _PRINTSTRING (x, y), s$
END SUB
