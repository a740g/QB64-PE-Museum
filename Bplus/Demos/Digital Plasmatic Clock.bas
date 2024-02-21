_TITLE "Digital Plasmatic Clock   press spacebar for new coloring set" ' b+ 2020-01-20 translated and modified from SmallBASIC
'Plasma Magnifico - updated 2015-11-26 for Android
'This program creates a plasma surface, which looks oily or silky.

CONST xmax = 850, ymax = 200, sq = 25
CONST dat = "1110111000001101111100011111100101110111011101101001001111111111011011"

TYPE xy
    x AS SINGLE
    y AS SINGLE
    dx AS SINGLE
    dy AS SINGLE
END TYPE
SCREEN _NEWIMAGE(xmax, ymax, 32)
_SCREENMOVE 300, 40

DIM c(360) AS _UNSIGNED LONG, p(6) AS xy, f(6)
restart:
r = RND: g = RND: b = RND: i = 0
FOR n = 1 TO 5
    r1 = r: g1 = g: b1 = b
    DO: r = RND: LOOP UNTIL ABS(r - r1) > .2
    DO: g = RND: LOOP UNTIL ABS(g - g1) > .2
    DO: b = RND: LOOP UNTIL ABS(g - g1) > .2
    FOR m = 0 TO 17: m1 = 17 - m
        f1 = (m * r) / 18: f2 = (m * g) / 18: f3 = (m * b) / 18: c(i) = rgbf(f1, f2, f3): i = i + 1
    NEXT
    FOR m = 0 TO 17: m1 = 17 - m
        f1 = (m + m1 * r) / 18: f2 = (m + m1 * g) / 18: f3 = (m + m1 * b) / 18: c(i) = rgbf(f1, f2, f3): i = i + 1
    NEXT
    FOR m = 0 TO 17: m1 = 17 - m
        f1 = (m1 + m * r) / 18: f2 = (m1 + m * g) / 18: f3 = (m1 + m * b) / 18: c(i) = rgbf(f1, f2, f3): i = i + 1
    NEXT
    FOR m = 0 TO 17: m1 = 17 - m
        f1 = (m1 * r) / 18: f2 = (m1 * g) / 18: f3 = (m1 * b) / 18: c(i) = rgbf(f1, f2, f3): i = i + 1
    NEXT
NEXT

FOR n = 0 TO 5
    p(n).x = RND * xmax: p(n).y = RND * ymax: p(n).dx = RND * 2 - 1: p(n).dy = RND * 2 - 1
    f(n) = RND * .1
NEXT

WHILE _KEYDOWN(27) = 0
    IF INKEY$ = " " THEN GOTO restart
    FOR i = 0 TO 5
        p(i).x = p(i).x + p(i).dx
        IF p(i).x > xmax OR p(i).x < 0 THEN p(i).dx = -p(i).dx
        p(i).y = p(i).y + p(i).dy
        IF p(i).y > ymax OR p(i).y < 0 THEN p(i).dy = -p(i).dy
    NEXT
    FOR y = 0 TO ymax - 1 STEP 2
        FOR x = 0 TO xmax - 1 STEP 2
            d = 0
            FOR n = 0 TO 5
                dx = x - p(n).x: dy = y - p(n).y
                k = SQR(dx * dx + dy * dy)
                d = d + (SIN(k * f(n)) + 1) / 2
            NEXT n: d = d * 60
            LINE (x, y)-STEP(2, 2), c(d), BF
        NEXT
    NEXT
    FOR j = 1 TO 3
        IF j = 1 THEN
            c~& = &HFFFFFFFF: offset = -2
        ELSEIF j = 2 THEN
            c~& = &HFF555555: offset = 2
        ELSE
            c~& = &HFFAAAAAA: offset = 0
        END IF
        FOR n = 1 TO 8 'clock digits over background
            IF MID$(TIME$, n, 1) = ":" THEN
                LINE ((n - 1) * 4 * sq + 2 * sq + offset, sq + sq + offset)-STEP(sq, sq), c~&, BF
                LINE ((n - 1) * 4 * sq + 2 * sq + offset, sq + 4 * sq + offset)-STEP(sq, sq), c~&, BF
            ELSE
                drawC (n - 1) * 4 * sq + sq + offset, sq + offset, MID$(dat$, VAL(MID$(TIME$, n, 1)) * 7 + 1, 7), c~&
            END IF
        NEXT
    NEXT
    _DISPLAY
WEND

SYSTEM

FUNCTION rgbf~& (n1, n2, n3)
    rgbf~& = _RGB32(n1 * 255, n2 * 255, n3 * 255)
END FUNCTION

SUB drawC (x, y, c$, c AS _UNSIGNED LONG)
    FOR m = 1 TO 7
        IF VAL(MID$(c$, m, 1)) THEN
            SELECT CASE m
                CASE 1: LINE (x, y)-STEP(sq, 3 * sq), c, BF
                CASE 2: LINE (x, y + 2 * sq)-STEP(sq, 4 * sq), c, BF
                CASE 3: LINE (x, y)-STEP(3 * sq, sq), c, BF
                CASE 4: LINE (x, y + 2 * sq)-STEP(3 * sq, sq), c, BF
                CASE 5: LINE (x, y + 5 * sq)-STEP(3 * sq, sq), c, BF
                CASE 6: LINE (x + 2 * sq, y)-STEP(sq, 3 * sq), c, BF
                CASE 7: LINE (x + 2 * sq, y + 2 * sq)-STEP(sq, 4 * sq), c, BF
            END SELECT
        END IF
    NEXT
END SUB
