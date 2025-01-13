OPTION _EXPLICIT
_TITLE "Another Particle Fountain" ' bplus mod Steve mod NakedApe  2024-10-13
SCREEN _NEWIMAGE(600, 600, 32)
_SCREENMOVE 250, 20
RANDOMIZE TIMER: _MOUSEHIDE
_DELAY .25: _SCREENMOVE _MIDDLE

TYPE particle
    AS SINGLE x, y, Vx, Vy
    AS _UNSIGNED LONG c
    AS INTEGER flag
END TYPE
DIM AS LONG i, top, s
DIM AS SINGLE r, g, b
restart:
REDIM AS particle p(15000)
r = RND * RND: g = RND * RND: b = RND * RND: top = 1
DO
    CLS
    FOR i = 0 TO top
        IF p(i).flag = 0 THEN
            p(i).x = _WIDTH / 2 + 20 * (SIN(_D2R(i MOD 360)))
            p(i).y = _HEIGHT - 1
            p(i).Vx = 0
            p(i).Vy = -7
            p(i).flag = 1
            p(i).c = _RGB32(127 * 127 * SIN(r * i * .5), 127 * 127 * SIN(g * i * .5), 127 * 127 * SIN(b * i * .5))
        END IF
        p(i).Vy = p(i).Vy + .032
        p(i).Vx = p(i).Vx + .1 * RND - .1 * RND
        p(i).x = p(i).x + p(i).Vx
        p(i).y = p(i).y + p(i).Vy + 2 * RND
        IF p(i).y > _HEIGHT THEN p(i).flag = 0
        CIRCLE (p(i).x, p(i).y), 1, p(i).c
        s = s + 1
        IF s MOD 100 = 0 THEN
            IF top < UBOUND(p) THEN top = top + 1
        END IF
    NEXT
    _DISPLAY
    _LIMIT 60
    IF s > 20000000 THEN
        s = 0
        GOTO restart
    END IF
LOOP UNTIL _KEYDOWN(27)
SYSTEM
