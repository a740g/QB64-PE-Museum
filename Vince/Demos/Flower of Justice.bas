'blossoming flower of justice
CONST sw = 800
CONST sh = 600

DIM SHARED pi AS DOUBLE
pi = 4 * ATN(1)

SCREEN _NEWIMAGE(sw, sh, 32)

r = 100

DO
    FOR a = 0 TO 1 STEP 0.01
        CLS
        fcirc sw / 2, sh / 2, a * r + (1 - a) * 1.5 * r, a, 3
        _DISPLAY
        _LIMIT 5
    NEXT
    _DELAY 3

    FOR a = 1 TO 0 STEP -0.01
        CLS
        fcirc sw / 2, sh / 2, a * r + (1 - a) * 1.5 * r, a, 3
        _DISPLAY
        _LIMIT 5
    NEXT
    _DELAY 3
LOOP
SYSTEM

SUB fcirc (x, y, r, a, n)
    IF NOT n > 0 THEN EXIT SUB
    FOR t = 0 TO 2 * pi STEP 2 * pi / 6
        xx = x + r * COS(t)
        yy = y + r * SIN(t)

        CIRCLE (xx, yy), r
        fcirc xx, yy, a * r, a, n - 1
    NEXT
END SUB
