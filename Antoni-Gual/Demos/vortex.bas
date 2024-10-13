' Vortex  Antoni Gual 2003
' for Rel's 9 liners contest at QBASICNEWS.COM
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM a AS STRING
DIM j AS LONG

2:
PALETTE LEN(a$) / 3, 0
a$ = a$ + CHR$(32 - 31 * SIN((LEN(a$) - 60 * ((LEN(a$) MOD 3) = 2) + 60 * ((LEN(a$) MOD 3) = 1)) * 3.14151693# / 128))
CIRCLE (160, 290 - LEN(a$) ^ .8), LEN(a$) / 2.8, LEN(a$) \ 3, , , .5
CIRCLE (160, 290 - LEN(a$) ^ .8 + 1), LEN(a$) / 2.8, LEN(a$) \ 3, , , .5
IF LEN(a$) < 256 * 3 THEN GOTO 2 ELSE OUT &H3C8, 0

DO
    j = (j + 1) MOD (LEN(a$) - 3)
    OUT &H3C9, ASC(MID$(a$, j + 1, 1))
    _LIMIT 16384
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
