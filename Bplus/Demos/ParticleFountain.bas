' Created by QB64 community member bplus

OPTION _EXPLICIT

_TITLE "Particle Fountain"

CONST nP = 30000

TYPE particle
    x AS SINGLE
    y AS SINGLE
    dx AS SINGLE
    dy AS SINGLE
    r AS SINGLE
    c AS _UNSIGNED LONG
END TYPE

DIM SHARED p(nP) AS particle

SCREEN _NEWIMAGE(600, 600, 32)

DIM AS LONG i, lp
FOR i = 0 TO nP
    new i
NEXT

DO
    _LIMIT 90
    CLS
    IF lp < nP THEN
        lp = lp + 100
    END IF
    FOR i = 0 TO lp
        p(i).dy = p(i).dy + .1
        p(i).x = p(i).x + p(i).dx
        p(i).y = p(i).y + p(i).dy
        IF p(i).x < 0 OR p(i).x > _WIDTH THEN
            new i
        END IF
        IF p(i).y > _HEIGHT AND p(i).dy > 0 THEN
            p(i).dy = -.75 * p(i).dy
            p(i).y = _HEIGHT - 5
        END IF
        CIRCLE (p(i).x, p(i).y), p(i).r, p(i).c
    NEXT
    _DISPLAY
LOOP WHILE LEN(INKEY$) = 0

SYSTEM 0

SUB new (i)
    p(i).x = _WIDTH / 2 + RND * 20 - 10
    p(i).y = _HEIGHT + RND * 5
    p(i).dx = RND * 1 - .5
    p(i).dy = -10
    p(i).r = RND * 3
    p(i).c = _RGB32(100 * RND + 155, 100 * RND + 155, 200 + RND * 55)
END SUB
