_TITLE "Morph Curve" 'b+ 2022-07-19 trans from
' Morph Curve on Plasma.bas  SmallBASIC 0.12.8 [B+=MGA] 2017-04-11
'from SpecBAS version Paul Dunn Dec 2, 2015
'https://www.youtube.com/watch?v=j2rmBRLEVms
' mods draw lines segments with drawpoly, add plasma, play with numbers

OPTION _EXPLICIT
CONST xmax = 1200, ymax = 700, pts = 500, interps = 30, pi = _PI
DIM SHARED plasmaR, plasmaG, plasmaB, plasmaN
RANDOMIZE TIMER
SCREEN _NEWIMAGE(xmax, ymax, 32)
_FULLSCREEN

DIM p(pts + 1, 1), q(pts + 1, 1), s(pts + 1, 1), i(interps)
DIM AS LONG L, c, j
DIM AS SINGLE cx, cy, sc, st, n, m, t, lastx, lasty
L = 0: cx = xmax / 2: cy = ymax / 2: sc = cy * .5: st = 2 * pi / pts
FOR n = 1 TO interps
    i(n) = SIN(n / interps * (pi / 2))
NEXT
WHILE _KEYDOWN(27) = 0
    resetPlasma
    n = INT(RND * 75) + 2: m = INT(RND * 500) - 250: c = 0
    FOR t = 0 TO 2 * pi STEP st
        IF _KEYDOWN(27) THEN SYSTEM
        q(c, 0) = cx + sc * (COS(t) + COS(n * t) / 2 + SIN(m * t) / 3)
        q(c, 1) = cy + sc * (SIN(t) + SIN(n * t) / 2 + COS(m * t) / 3)
        setPlasma
        IF t > 0 THEN pline lastx, lasty, q(c, 0), q(c, 1), 10
        lastx = q(c, 0): lasty = q(c, 1)
        c = c + 1
    NEXT
    q(c, 0) = q(0, 0): q(c, 1) = q(0, 1)
    IF L = 0 THEN
        L = L + 1
        _DISPLAY
        _LIMIT 30
    ELSE
        FOR t = 1 TO interps
            CLS
            FOR n = 0 TO pts
                IF _KEYDOWN(27) THEN SYSTEM
                s(n, 0) = q(n, 0) * i(t) + p(n, 0) * (1 - i(t))
                s(n, 1) = q(n, 1) * i(t) + p(n, 1) * (1 - i(t))
                setPlasma
                IF n > 0 THEN pline lastx, lasty, s(n, 0), s(n, 1), 10
                lastx = s(n, 0): lasty = s(n, 1)
            NEXT
            s(n, 0) = s(0, 0)
            s(n, 1) = s(0, 1)
            _DISPLAY
            _LIMIT 30
        NEXT
    END IF
    FOR j = 0 TO pts + 1 'copy q into p
        IF _KEYDOWN(27) THEN SYSTEM
        p(j, 0) = q(j, 0)
        p(j, 1) = q(j, 1)
    NEXT
    _DISPLAY
    SLEEP 4
WEND

'fast thick line!!!
SUB pline (x1, y1, x2, y2, thick) 'this draws a little rectangle
    DIM r, dx, dy, perpA1, perpA2, x3, y3, x4, y4, x5, y5, x6, y6

    r = thick / 2
    dx = x2 - x1
    dy = y2 - y1
    perpA1 = _ATAN2(dy, dx) + pi / 2
    perpA2 = perpA1 - pi
    x3 = x1 + r * COS(perpA1) 'corner 1
    y3 = y1 + r * SIN(perpA1)
    x4 = x2 + r * COS(perpA1) 'corner 2
    y4 = y2 + r * SIN(perpA1)
    x5 = x2 + r * COS(perpA2) 'corner 3
    y5 = y2 + r * SIN(perpA2)
    x6 = x1 + r * COS(perpA2) 'corner 4
    y6 = y1 + r * SIN(perpA2)
    LINE (x3, y3)-(x4, y4)
    LINE (x4, y4)-(x5, y5)
    LINE (x5, y5)-(x6, y6)
    LINE (x6, y6)-(x3, y3)
END SUB

SUB resetPlasma () 'all globals
    plasmaR = RND ^ 2: plasmaG = RND ^ 2: plasmaB = RND ^ 2: plasmaN = 0
END SUB

SUB setPlasma () 'all globals
    plasmaN = plasmaN + .37
    COLOR _RGB32(120 + 84 * SIN(plasmaR * plasmaN), 120 + 84 * SIN(plasmaG * plasmaN), 120 + 84 * SIN(plasmaB * plasmaN))
END SUB
