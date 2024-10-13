'patterns
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM AS LONG t, i, j, k

DO
    t = RND * 345
    WAIT &H3DA, 8
    FOR i = 0 TO 199
        FOR j = 0 TO 319
            k = ((k + t XOR j XOR i)) AND &HFF
            PSET (j, i), k
        NEXT
    NEXT
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
