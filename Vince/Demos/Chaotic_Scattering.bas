_TITLE "*** Chaotic Scattering *** by vince and mod by bplus 2018-02-15                     click mouse to reset LASER"
DEFINT A-Z
RANDOMIZE TIMER
CONST sw = 1200
CONST sh = 700

DIM SHARED qb(15) AS _INTEGER64
qb(0) = &HFF000000
qb(1) = &HFF000088
qb(2) = &HFF008800
qb(3) = &HFF008888
qb(4) = &HFF880000
qb(5) = &HFF880088
qb(6) = &HFF888800
qb(7) = &HFFCCCCCC
qb(8) = &HFF888888
qb(9) = &HFF0000FF
qb(10) = &HFF00FF00
qb(11) = &HFF00FFFF
qb(12) = &HFFFF0000
qb(13) = &HFFFF00FF
qb(14) = &HFFFFFF00
qb(15) = &HFFFFFFFF

CONST nCircs = 25
CONST r = 150
CONST maxr = 100
TYPE circles
    x AS INTEGER
    y AS INTEGER
    r AS INTEGER
    c AS _INTEGER64
END TYPE
DIM SHARED cs(nCircs) AS circles
DIM i AS INTEGER
DIM c AS INTEGER
DIM ck AS INTEGER
FOR i = 1 TO nCircs
    cs(i).r = RND * (maxr - 20) + 20
    cs(i).c = qb(INT(RND * 15) + 1)
    IF i > 1 THEN
        ck = 0
        WHILE ck = 0
            cs(i).x = INT(RND * (sw - 2 * cs(i).r)) + cs(i).r
            cs(i).y = INT(RND * (sh - 2 * cs(i).r)) + cs(i).r
            ck = 1
            FOR c = 1 TO i - 1
                IF ((cs(i).x - cs(c).x) ^ 2 + (cs(i).y - cs(c).y) ^ 2) ^ .5 < cs(i).r + cs(c).r THEN ck = 0: EXIT FOR
            NEXT
        WEND
    ELSE
        cs(i).x = INT(RND * (sw - 2 * cs(i).r)) + cs(i).r
        cs(i).y = INT(RND * (sh - 2 * cs(i).r)) + cs(i).r
    END IF
NEXT

DIM t AS DOUBLE
DIM a AS DOUBLE, b AS DOUBLE
DIM a1 AS DOUBLE, a2 AS DOUBLE

DIM x AS DOUBLE, y AS DOUBLE
DIM x0 AS DOUBLE, y0 AS DOUBLE
DIM x1 AS DOUBLE, y1 AS DOUBLE


SCREEN _NEWIMAGE(sw, sh, 32)
_SCREENMOVE 100, 20

'find a place not inside a circle
xx = sw / 2
yy = sh / 2
WHILE checkxy%(xx, yy) = 0
    xx = INT(RND * (sw - 2 * maxr)) + maxr
    yy = INT(RND * (sh - 2 * maxr)) + maxr
WEND

DO
    IF LEN(INKEY$) THEN
        _DELAY 5 'to get dang screen shot
    ELSE
        'get mouse x, y if click
        DO
            mx = _MOUSEX
            my = _MOUSEY
            mb = _MOUSEBUTTON(1)
        LOOP WHILE _MOUSEINPUT
    END IF

    'cls with Fellippes suggestion
    LINE (0, 0)-(sw, sh), _RGBA32(0, 0, 0, 30), BF

    'draw circles
    FOR c = 1 TO nCircs
        COLOR cs(c).c
        fcirc cs(c).x, cs(c).y, cs(c).r
    NEXT

    'if click make sure click was not inside one of the circles
    IF mb THEN
        DO WHILE mb
            DO
                mb = _MOUSEBUTTON(1)
            LOOP WHILE _MOUSEINPUT
        LOOP
        f = checkxy%(mx, my)
        IF f THEN
            xx = mx
            yy = my
            f = -1
        END IF
    END IF

    x0 = xx
    y0 = yy
    a = _ATAN2(my - yy, mx - xx)
    t = 0
    DO
        t = t + 1
        x = t * COS(a) + x0
        y = t * SIN(a) + y0
        IF x < 0 OR x > sw OR y < 0 OR y > sh THEN EXIT DO
        FOR c = 1 TO nCircs
            IF (x - cs(c).x) ^ 2 + (y - cs(c).y) ^ 2 < cs(c).r * cs(c).r THEN
                a1 = _ATAN2(y - cs(c).y, x - cs(c).x)
                a2 = 2 * a1 - a - _PI
                LINE (x0, y0)-(x, y), qb(14)
                x0 = x
                y0 = y
                a = a2
                t = 0
                EXIT FOR
            END IF
        NEXT
    LOOP
    LINE (x0, y0)-(x, y), qb(14)
    _DISPLAY
    _LIMIT 50
LOOP UNTIL _KEYHIT = 27
SYSTEM

FUNCTION checkxy% (x, y)
    DIM c AS INTEGER
    FOR c = 1 TO nCircs
        IF (x - cs(c).x) ^ 2 + (y - cs(c).y) ^ 2 < cs(c).r * cs(c).r THEN checkxy% = 0: EXIT FUNCTION
    NEXT
    checkxy% = 1
END FUNCTION

'Steve McNeil's  copied from his forum   note: Radius is too common a name
SUB fcirc (CX AS LONG, CY AS LONG, R AS LONG)
    DIM subRadius AS LONG, RadiusError AS LONG
    DIM X AS LONG, Y AS LONG

    subRadius = ABS(R)
    RadiusError = -subRadius
    X = subRadius
    Y = 0

    IF subRadius = 0 THEN PSET (CX, CY): EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), , BF

    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), , BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), , BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), , BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), , BF
    WEND
END SUB
