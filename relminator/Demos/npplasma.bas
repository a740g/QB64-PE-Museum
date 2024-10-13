' Non Palette rotated plasma
' Relsoft 2003
' Compile and see the speed.  Didn't optimize it as much as I want though...

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM Lsin1%(-1024 TO 1024), Lsin2%(-1024 TO 1024), Lsin3%(-1024 TO 1024)
FOR I% = -1024 TO 1024
    Lsin1%(I%) = SIN(I% / (128)) * 256 'Play with these values
    Lsin2%(I%) = SIN(I% / (64)) * 128 'for different types of fx
    Lsin3%(I%) = SIN(I% / (32)) * 64 ';*)
    IF I% > -1 AND I% < 256 THEN PALETTE I%, 65536 * (INT(32 - 31 * SIN(I% * 3.14151693# / 128))) + 256 * (INT(32 - 31 * SIN(I% * 3.14151693# / 64))) + (INT(32 - 31 * SIN(I% * 3.14151693# / 32)))
NEXT
DEF SEG = &HA000
Dir% = 1
DO
    Counter& = (Counter& + Dir%)
    IF Counter& > 600 THEN Dir% = -Dir%
    IF Counter& < -600 THEN Dir% = -Dir%
    Rot% = 64 * (((Counter& AND 1) = 1) OR 1)
    StartOff& = 0
    FOR y% = 0 TO 199
        FOR x% = 0 TO 318
            Rot% = -Rot%
            C% = Lsin3%(x% + Rot% - Counter&) + Lsin1%(x% + Rot% + Counter&) + Lsin2%(y% + Rot%)
            POKE StartOff& + x%, C%
        NEXT
        StartOff& = StartOff& + 320
    NEXT
    _LIMIT 60
LOOP UNTIL INKEY$ <> ""

SYSTEM
