'sinecube 2006 mennonite
'public domain

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 12
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM blox(40, 40, 40) AS INTEGER
DIM AS LONG l, y, x, by, bx, z
DIM AS SINGLE mm
DIM AS STRING b

LINE (0, 0)-(639, 479), , B

l = 8

b$ = b$ + "00000000..."
b$ = b$ + "llnnnnnnl.."
b$ = b$ + "l8lnnnnnnl."
b$ = b$ + "l88llllllll"
b$ = b$ + "l88l000000l"
b$ = b$ + "l88l000000l"
b$ = b$ + "l88l000000l"
b$ = b$ + "l88l000000l"
b$ = b$ + ".l8l000000l"
b$ = b$ + "..ll000000l"
b$ = b$ + "...llllllll"

blox(2, 3, 32) = 1

FOR l = 8 * 32 TO 1 STEP -8
    FOR y = 4 TO 4 * 32 STEP 4
        FOR x = 8 * 32 TO 1 STEP -8
            mm = SIN(x * y * l * 3.14): IF mm < 0 THEN mm = -1 ELSE IF mm > 0 THEN mm = 1
            IF blox(x / 8, y / 4, l / 8) = mm + 1 THEN
                FOR by = 1 TO 11
                    FOR bx = 1 TO 11
                        IF RIGHT$(LEFT$(b$, (by - 1) * 11 + bx), 1) <> "." THEN
                            z = 11
                            PSET (x + bx - 1 + y - 3, by - 1 + y + l + 4), ASC(RIGHT$(LEFT$(b$, (by - 1) * 11 + bx), 1)) MOD 16 + (y MOD 2)
                        END IF

                    NEXT bx
                NEXT by
            END IF
            IF INKEY$ = CHR$(27) THEN END
            _DELAY .001
        NEXT
    NEXT
NEXT

SLEEP

SYSTEM
