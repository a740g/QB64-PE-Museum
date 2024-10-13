'Mandala by Antoni gual
'for Rel's 9 LINER contest at QBASICNEWS.COM  1/2003
'------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 12
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM AS LONG v, d1, d2

DO
    v = RND * 20 + 10
    REDIM VX%(v), VY%(v)
    FOR d1 = -1 TO v
        FOR d2 = d1 + 1 TO v
            IF d1 = -1 THEN VX%(d2) = 320 + (SIN(6.283185 * (d2 / v)) * 239) ELSE LINE (VX%(d1), VY%(d1))-(VX%(d2), VY%(d2)), (v MOD 16) + 1
            IF d1 = -1 THEN VY%(d2) = 240 + (COS(6.283185 * (d2 / v)) * 239)
        NEXT
    NEXT
    _LIMIT 60
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
