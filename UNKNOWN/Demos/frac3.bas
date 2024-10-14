DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 12
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM AS SINGLE x, y

WINDOW (-5, 0)-(5, 10)
RANDOMIZE TIMER
COLOR 10
DO
    SELECT CASE RND
        CASE IS < .01
            x = 0
            y = .16 * y
        CASE .01 TO .08
            x = .2 * x - .26 * y
            y = .23 * x + .22 * y + 1.6
        CASE .08 TO .15
            x = -.15 * x + .28 * y
            y = .26 * x + .24 * y + .44
        CASE ELSE
            x = .85 * x + .04 * y
            y = -.04 * x + .85 * y + 1.6
    END SELECT
    PSET (x, y)
LOOP UNTIL INKEY$ = CHR$(27)

SYSTEM
