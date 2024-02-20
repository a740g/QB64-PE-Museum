DEFDBL A-Z

DIM SHARED pi, a1, a2, a, b, w1, w2, h

pi = 4 * ATN(1)

a1 = 14
a2 = 4

w = 30 * 7
w1 = w * 5 / 7
w2 = w - w1
h = w * 2 / 7

a = -h / a2 / SIN(pi * w / w1)
a = EXP(LOG(a) / w)
b = a1 * pi / w1 / w2

sw = w * 4 + w2
sh = h * 8 + 114

SCREEN _NEWIMAGE(sw, sh, 32)

LINE (0, 0)-(sw, sh), _RGB(255, 255, 255), BF

FOR i = -1 TO 4
    FOR j = -1 TO 4
        fish w2 + i * w, 50 + h * j * 2, w, i AND 1
        fish sw - w2 - i * w, 50 + h * j * 2 + h, -w, i AND 1
    NEXT
NEXT

SLEEP
SYSTEM

FUNCTION f (x, aa)
    f = aa * (a ^ x) * SIN(pi * x / w1)
END FUNCTION

FUNCTION g (x, v)
    g = b * x * (x - v)
END FUNCTION

SUB fish (x0, y0, ww, u)
    DIM c1 AS _UNSIGNED LONG
    DIM c2 AS _UNSIGNED LONG

    c1 = _RGB(200, 200, 200)
    c2 = _RGB(255, 255, 255)
    IF u THEN SWAP c1, c2

    w = ABS(ww)
    s = SGN(ww)

    'background
    COLOR c1
    FOR x = w TO w1 STEP -1
        LINE (x0 + s * (x - w), y0 - f(x, a2))-(x0 + s * (x - w), y0 - g(x - w, -w2))
    NEXT
    FOR x = 0 TO w1
        LINE (x0 + s * x, y0 - f(x, a2))-(x0 + s * x, y0 + h - f(w1 - x, a1))
    NEXT
    FOR x = 0 TO w2
        LINE (x0 + s * (w - x), y0 + h - g(-x, -w2))-(x0 + s * (w - x), y0 - f(w - x, a2))
    NEXT
    FOR xx = 0 TO w1 / 3 / 7
        IF xx > 0 AND xx < w1 / 3 / 7 THEN
            x = xx * 3 * 7 + 3
            ox = x0 + s * x
            oy = y0 - f(x, a1)
            oy2 = y0 + h - f(w1 - x, a2)
            FOR zz = 0 TO 3 * 7 + 2
                z = xx * 3 * 7 + zz
                LINE (ox, oy)-(x0 + s * z, y0 - f(z, a2))
                LINE (ox, oy2)-(x0 + s * z, y0 + h - f(w1 - z, a1))
            NEXT
        END IF
    NEXT

    COLOR _RGB(0, 0, 0)
    'closed shape
    PSET (x0, y0)
    FOR x = 0 TO w
        LINE -(x0 + s * x, y0 - f(x, a2))
    NEXT
    FOR x = 0 TO w2
        LINE -(x0 + s * (w - x), y0 + h - g(-x, -w2))
    NEXT
    FOR x = 0 TO w1
        LINE -(x0 + s * (w1 - x), y0 + h - f(x, a1))
    NEXT
    FOR x = w TO w1 STEP -1
        LINE -(x0 + s * (x - w), y0 - f(x, a2))
    NEXT
    FOR x = 0 TO w2
        LINE -(x0 - s * (w2 - x), y0 - g(x, w2))
    NEXT
    FOR x = 0 TO w1
        LINE -(x0 + s * x, y0 - f(x, a1))
    NEXT


    'flourish
    CIRCLE (x0 + s * w1, y0 + 21), 3, c2
    PAINT (x0 + s * w1, y0 + 21), c2
    CIRCLE (x0 + s * w1, y0 + 21), 3

    FOR xx = 0 TO w1 / 3 / 7
        IF xx = 1 THEN
            x = xx * 3 * 7 + 3
            PSET (x0 + s * x, y0 - f(x, a1))
        ELSEIF xx > 1 AND xx < w1 / 3 / 7 - 1 THEN
            x = xx * 3 * 7
            LINE -(x0 + s * x, y0 - f(x, a2))
            x = x + 3
            LINE -(x0 + s * x, y0 - f(x, a1))
        END IF
    NEXT

    FOR xx = 0 TO w1 / 3 / 7
        IF xx = 0 THEN
            x = (xx + 1) * 3 * 7 + 3
            PSET (x0 + s * x, y0 + h - f(w1 - x, a2))
        ELSEIF xx > 0 AND xx < w1 / 3 / 7 THEN
            x = xx * 3 * 7
            LINE -(x0 + s * x, y0 + h - f(w1 - x, a1))
            x = x + 3
            LINE -(x0 + s * x, y0 + h - f(w1 - x, a2))
        END IF
    NEXT

    FOR xx = 1 TO w2 / 8 - 1
        x = w - xx * 8
        x2 = w - xx * 6.5 - 7
        LINE (x0 + s * (x - w), y0 - f(x, a2))-(x0 + s * (x2 + 2 * 7 - w), y0 - f(x2, a2))
    NEXT
END SUB
