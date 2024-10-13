'Lissajous by Antoni Gual
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 12
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM AS LONG i, j, n
DIM AS SINGLE k, l
DO
    CLS
    i = (i + 1) AND &HFFFFF
    k = 6.3 * RND
    l = 6.3 * RND
    n = (n + 1) MOD 15
    FOR j = 0 TO 100000
        PSET (320 + 300 * SIN(.01 * SIN(k) + j), 240 + 200 * SIN(.01 * SIN(l) * j)), n + 1
    NEXT
    _LIMIT 60
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
