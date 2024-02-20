DIM x(200), y(200)
scr = _SCREENIMAGE
Hpix = _WIDTH(scr)
Vpix = _HEIGHT(scr)
_FREEIMAGE scr
x(0) = 0
y(0) = 0
FOR i = 1 TO 100
    x(i) = x(i - 1) + .4
    y(i) = y(i - 1) + .2
NEXT i
_TITLE "Telephone Poles"
SCREEN _NEWIMAGE(Hpix, Vpix, 12)
_FULLSCREEN
DO WHILE INKEY$ <> CHR$(27)
    FOR i = 1 TO 7
        CALL Centerline(Hpix, Vpix)
        CALL PoleLeft(x(i), Hpix, Vpix)
        CALL PoleRight(y(i), Hpix, Vpix)
    NEXT i
    CALL throttle
LOOP
END

SUB throttle
    _DELAY .07
END SUB

SUB Centerline (Hpix, Vpix)
    LINE (Hpix / 2, Vpix / 2)-(.1 * Hpix, Vpix), 14
    LINE (Hpix / 2, Vpix / 2)-(.125 * Hpix, Vpix), 14
    LINE (Hpix / 2, Vpix / 2)-(0, .8 * Vpix), 7
    LINE (Hpix / 2, Vpix / 2)-(Hpix, .8333 * Vpix), 7
END SUB

SUB PoleLeft (x, Hpix, Vpix)
    IF x >= Hpix THEN x = 5
    IF x >= 0 THEN
        a = Hpix / 2 - x
        b = Vpix / 2 - x / 2
        c = Vpix / 2 + x / 3
        d = Vpix / 2 - x / 3
        LINE (a, b)-(a, c), 0
        CIRCLE (a, (b + c) / 2), x / 35, 0
        CIRCLE (a, (b + c) / 2), x / 45, 0
        CIRCLE (a, (b + c) / 2), x / 55, 0
        CIRCLE (a, (b + c) / 2), x / 65, 0
        CIRCLE (a, (b + c) / 2), x / 75, 0
        LINE (a - x / 8, b)-(a + x / 8, b), 0
        LINE (a - x / 8, d)-(a + x / 8, d), 0
    END IF
    x = x ^ 1.02 + .005
    IF x >= 0 THEN
        a = Hpix / 2 - x
        b = Vpix / 2 - x / 2
        c = Vpix / 2 + x / 3
        d = Vpix / 2 - x / 3
        LINE (a, b)-(a, c), 8
        CIRCLE (a, (b + c) / 2), x / 35, 15
        CIRCLE (a, (b + c) / 2), x / 45, 15
        CIRCLE (a, (b + c) / 2), x / 55, 15
        CIRCLE (a, (b + c) / 2), x / 65, 15
        CIRCLE (a, (b + c) / 2), x / 75, 15
        LINE (a - x / 8, b)-(a + x / 8, b), 8
        LINE (a - x / 8, d)-(a + x / 8, d), 8
    END IF
END SUB

SUB PoleRight (x, Hpix, Vpix)
    REM IF x >= Hpix THEN x = 6
    IF x >= Hpix THEN x = 4
    IF x >= 0 THEN
        a = Hpix / 2 + x
        b = Vpix / 2 - x / 2
        c = Vpix / 2 + x / 3
        d = Vpix / 2 - x / 3
        LINE (a, b)-(a, c), 0
        CIRCLE (a, (b + c) / 2), x / 35, 0
        CIRCLE (a, (b + c) / 2), x / 45, 0
        CIRCLE (a, (b + c) / 2), x / 55, 0
        CIRCLE (a, (b + c) / 2), x / 65, 0
        CIRCLE (a, (b + c) / 2), x / 75, 0
        LINE (a - x / 8, b)-(a + x / 8, b), 0
        LINE (a - x / 8, d)-(a + x / 8, d), 0
    END IF
    x = x ^ 1.02 + .005
    IF x >= 0 THEN
        a = Hpix / 2 + x
        b = Vpix / 2 - x / 2
        c = Vpix / 2 + x / 3
        d = Vpix / 2 - x / 3
        LINE (a, b)-(a, c), 8
        CIRCLE (a, (b + c) / 2), x / 35, 12
        CIRCLE (a, (b + c) / 2), x / 45, 12
        CIRCLE (a, (b + c) / 2), x / 55, 12
        CIRCLE (a, (b + c) / 2), x / 65, 12
        CIRCLE (a, (b + c) / 2), x / 75, 12
        LINE (a - x / 8, b)-(a + x / 8, b), 8
        LINE (a - x / 8, d)-(a + x / 8, d), 8
    END IF
END SUB
