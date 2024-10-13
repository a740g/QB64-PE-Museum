'Twirl by Antoni Gual, from an idea  by Steve Nunnaly
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------
DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM AS SINGLE i, w, xmid, ymid

FOR i = 0 TO 199
    CIRCLE (160, 100), i, (i MOD 16) + 32, , , .8
NEXT

DIM b2%(5000)

DO
    w = (w + .3)
    xmid = 140 + SIN(7 * w / 1000) * 110
    ymid = 80 + SIN(11 * w / 1000) * 59
    GET ((xmid - (SIN(w) * 28)), (ymid - (COS(w) * 20)))-((xmid - (SIN(w) * 28)) + 40, (ymid - (COS(w) * 20)) + 40), b2%()
    PUT ((xmid - (SIN(w - .04) * 27.16)), (ymid - (COS(w - .04) * 19.4))), b2%(), PSET

    _DELAY .001
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
