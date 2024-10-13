'-----------------------------------------------------------------------
'GUJERO2.BAS by Antoni Gual 2/2004
'For the QBNZ 1/2004 9 liner contest
'-----------------------------------------------------------------------
'Tunnel effect (more or less)
'FFIX recommended. It does compile.
'-----------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

DIM AS LONG i, x, y
DIM AS SINGLE a

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DO
    IF i = 1 THEN OUT &H3C8, 0 ELSE IF i <= 194 THEN OUT &H3C9, INT((i - 2) / 3)
    IF i <= 194 THEN GOTO 8
    FOR y = -100 TO 99
        FOR x = -160 TO 159
            IF x >= 0 THEN IF y < 0 THEN a = 1.57079632679# + ATN(x / (y + .000001)) ELSE a = -ATN(y / (x + .000001)) ELSE IF y < 0 THEN a = 1.57079632679# + ATN(x / (y + .000001)) ELSE a = -1.57079632679# + ATN(x / (y + .000001))
            PSET (x + 160, y + 100), (x * x + y * y) * .00003 * ((INT(-10000 * i + 5.2 * SQR(x * x + y * y)) AND &H3F) XOR (INT((191 * a) + 10 * i) AND &H3F))
        NEXT
    NEXT
    8 i = i + 1
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
