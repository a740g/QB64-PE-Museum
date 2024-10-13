' OPTIMIZED  :) rotozoomer in 9 lines by Antoni Gual
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH


DIM midX AS LONG: midX = _WIDTH \ 2
DIM midY AS LONG: midY = _HEIGHT \ 2

DIM AS SINGLE Ang, CS, SS
DIM AS LONG Y, X
DO
    Ang = Ang + .005
    CS = COS(Ang) * ABS(SIN(Ang)) * 128
    SS = SIN(Ang) * ABS(SIN(Ang)) * 128
    FOR Y = -midY TO midY
        FOR X = -midX TO midX
            PSET (X + midX, Y + midY), (((X * CS - Y * SS) AND (Y * CS + X * SS)) \ 128)
        NEXT
    NEXT

    _LIMIT 60
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
