CONST xmax = 600 ' not working!!!
CONST ymax = 600

DIM AS INTEGER i, j, s, sq
DIM AS DOUBLE x, y, c, d
DIM AS _UNSIGNED LONG cc

SCREEN _NEWIMAGE(xmax, ymax, 32)

s = 1
sq = 5
DO
    FOR j = 0 TO ymax / sq
        FOR i = 0 TO xmax / sq
            x = i * s / 600
            y = j * s / 600
            c = x * x + y * y
            d = c / 2
            d = d - INT(d)
            d = INT(d * 1000)
            IF d < 250 THEN
                cc = _RGB32(d, 0, 0)
            ELSEIF d < 500 THEN
                cc = _RGB32(0, d - 250, 0)
            ELSEIF d < 750 THEN
                cc = _RGB32(0, 0, d - 500)
            ELSE
                cc = _RGB32(255, 255, 255)
            END IF
            LINE (i * sq, j * sq)-STEP(sq, sq), cc, BF
        NEXT
    NEXT
    _DELAY 2
    'Color _RGB32(255, 255, 255)
    'Locate 1, 1
    'Print s
    s = s + 15
    IF s > 1000 THEN
        s = 1
    END IF
LOOP
