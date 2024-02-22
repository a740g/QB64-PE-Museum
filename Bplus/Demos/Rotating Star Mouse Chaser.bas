OPTION _EXPLICIT
_TITLE "Rotating Star Mouse Chaser" 'b+ 2022-07-19 trans from:
'Rotating Stars Mouse Chaser.bas for SmallBASIC 0.12.0 2015-11-09 MGA/B+
'code is based on code: mouse chaser by tsh73
'for the Just Basic contest, November 2008, I am 7 years later

CONST nPoints = 20, xMax = 1280, yMax = 700, pi = _PI
SCREEN _NEWIMAGE(xMax, yMax, 32)
_FULLSCREEN
DIM SHARED x(nPoints), y(nPoints), i, twist

DIM AS LONG mx, my
DIM AS SINGLE dx, dy, v, r, dxN, dyN

FOR i = 1 TO nPoints
    x(i) = xMax
    y(i) = yMax 'set it offscreen
NEXT

WHILE _KEYDOWN(27) = 0
    CLS
    twist = twist + .05
    WHILE _MOUSEINPUT: WEND
    mx = _MOUSEX: my = _MOUSEY
    FOR i = 1 TO nPoints
        IF i = 1 THEN 'first sees mouse
            dx = mx - x(i)
            dy = my - y(i)
            v = 4
        ELSE 'others see previous
            dx = x(i - 1) - x(i)
            dy = y(i - 1) - y(i)
            v = 0.6 * v + 0.2 * 3 * (2 - i / nPoints) 'use 0.8 v of previous, to pick up speed
        END IF
        r = SQR(dx ^ 2 + dy ^ 2)
        dxN = dx / r
        dyN = dy / r
        x(i) = x(i) + v * dxN
        y(i) = y(i) + v * dyN
        drawstar
    NEXT i
    _DISPLAY
    _LIMIT 60
WEND

SUB drawstar ()
    DIM sp, s, t, u, j, b, v, w
    sp = (nPoints + 1 - i) * 2 + 3 'star points when i is low, points are high
    s = 5 * (50 ^ (1 / nPoints)) ^ (nPoints + 1 - i)
    t = x(i) + s * COS(0 + twist)
    u = y(i) + s * SIN(0 + twist)
    FOR j = 1 TO sp
        b = b + INT(sp / 2) * 2 * pi / sp
        v = x(i) + s * COS(b + twist)
        w = y(i) + s * SIN(b + twist)
        LINE (t, u)-(v, w), _RGB32(255, 255, 100)
        t = v: u = w
    NEXT
END SUB
