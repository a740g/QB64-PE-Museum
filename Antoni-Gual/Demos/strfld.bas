'Starfield by Antoni gual
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM a AS STRING
DIM AS SINGLE j

a = STRING$(400 * 6, CHR$(0))

DO
    IF CVI(MID$(a, j + 5, 2)) = 0 THEN MID$(a, j + 1, 6) = MKI$(RND * 20000 - 10000) + MKI$(RND * 20000 - 10000) + MKI$(100 * RND + 1)
    PSET (160 + CVI(MID$(a, j + 1, 2)) / CVI(MID$(a, j + 5, 2)), 100 + CVI(MID$(a, j + 3, 2)) / CVI(MID$(a, j + 5, 2))), 0
    MID$(a, j + 5, 2) = MKI$(CVI(MID$(a, j + 5, 2)) - 1)
    IF CVI(MID$(a, j + 5, 2)) > 0 THEN PSET (160 + CVI(MID$(a, j + 1, 2)) / CVI(MID$(a, j + 5, 2)), 100 + CVI(MID$(a, j + 3, 2)) / CVI(MID$(a, j + 5, 2))), 32 - CVI(MID$(a, j + 5, 2)) \ 8
    j = (j + 6) MOD (LEN(a))
    _LIMIT 16384
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
