_TITLE "Eggs o Dozens" 'b+ 2022-03-29
CONST Xmax = 1200
CONST Ymax = 400
CONST Pi = _PI
SCREEN _NEWIMAGE(Xmax, Ymax, 32)
DIM scale, x, y
scale = 96
DO
    FOR y = 100 TO 300 STEP 200
        FOR x = 100 TO 1100 STEP 200
            drawEasterEgg x, y, scale, 0
        NEXT
    NEXT
    _DELAY 1
LOOP UNTIL _KEYDOWN(27)

SUB drawEasterEgg (xc, yc, scale, radianAngle)
    DIM r, g, b, x, y, c
    r = RND: g = RND: b = RND
    FOR x = -1 TO 1 STEP .01
        FOR y = -1 TO 1 STEP .01
            IF x < 0 THEN c = c + .0005 ELSE c = c - .0005
            IF (x * x + (1.4 ^ x * 1.6 * y) ^ 2 - 1) <= .01 THEN
                IF y > 0 THEN
                    COLOR _RGB32(128 * (1 - y) + 128 * (1 - y) * SIN(c * r), 128 * (1 - y) + 128 * (1 - y) * SIN(c * g), 127 * (1 - y) + 127 * (1 - y) * SIN(c * b))
                ELSE
                    COLOR _RGB32(128 + 128 * SIN(c * r), 128 + 128 * SIN(c * g), 127 + 127 * SIN(c * b))
                END IF
                a = _ATAN2(y, x)
                d = scale * SQR(x * x + y * y)
                PSET (xc + d * COS(a + radianAngle), yc + d * SIN(a + radianAngle))
            END IF
        NEXT
    NEXT
END SUB
