'Floormaper by Antoni Gual
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

$RESIZE:SMOOTH

DIM AS LONG r, y, y1, x
DIM AS SINGLE y2

SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DO
    r = (r + 1) AND 15
    FOR y = 1 TO 99
        y1 = ((1190 / y + r) AND 15)
        y2 = 6 / y
        FOR x = 0 TO 319
            PSET (x, y + 100), CINT((159 - x) * y2) AND 15 XOR y1 + 16
        NEXT
    NEXT
    _LIMIT 60
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
