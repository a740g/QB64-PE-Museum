' Doom fire demo - a740g
' C version - 2003
' QB64-PE port - 2024
' Tons of optimizations are possible

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST START_COLOR = 128
CONST COLORS = 256 - START_COLOR

RANDOMIZE TIMER

' Switch to graphics mode
SCREEN _NEWIMAGE(640, 400, 256)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

PRINT "Try pressing 'r','g' or 'b' for different colored flames."
SLEEP 2

' Start with doom red
SetPalette 1

DIM mX AS LONG: mX = _WIDTH - 1
DIM mY AS LONG: mY = _HEIGHT - 1

COLOR 255

DO
    ' Fill the bottom line with random values
    DIM x AS LONG: FOR x = 0 TO mX
        PSET (x, mY), START_COLOR + FIX(RND * COLORS)
    NEXT x

    ' Calculate pixel values
    DIM y AS LONG: FOR y = 1 TO mY
        FOR x = 0 TO mX
            DIM i AS _UNSIGNED LONG: i = POINT(x, y)
            IF i THEN
                PSET (x - RND + RND, y - 1), i - RND
            ELSE
                PSET (x, y - 1), 0
            END IF
        NEXT x
    NEXT y

    DIM k AS LONG: k = _KEYHIT

    SELECT CASE k
        CASE 27
            EXIT DO

        CASE 114, 82
            SetPalette 1

        CASE 103, 71
            SetPalette 2

        CASE 98, 66
            SetPalette 3
    END SELECT

    _PRINTSTRING (0, 3), STR$(GetHertz) + " FPS"

    _LIMIT 60
LOOP

SYSTEM


SUB SetPalette (t AS LONG)
    SELECT CASE t
        CASE 2
            ' black -> green -> cyan -> white
            Graphics_SetGradientPalette _DEST, 1, 85, 0, 0, 0, 0, 255, 0
            Graphics_SetGradientPalette _DEST, 85, 170, 0, 255, 0, 0, 255, 255
            Graphics_SetGradientPalette _DEST, 170, 255, 0, 255, 255, 255, 255, 255

        CASE 3
            ' black -> blue -> magenta -> white
            Graphics_SetGradientPalette _DEST, 1, 85, 0, 0, 0, 0, 0, 255
            Graphics_SetGradientPalette _DEST, 85, 170, 0, 0, 255, 255, 0, 255
            Graphics_SetGradientPalette _DEST, 170, 255, 255, 0, 255, 255, 255, 255

        CASE ELSE
            ' black -> red -> yellow -> white
            Graphics_SetGradientPalette _DEST, 1, 85, 0, 0, 0, 255, 0, 0
            Graphics_SetGradientPalette _DEST, 85, 170, 255, 0, 0, 255, 255, 0
            Graphics_SetGradientPalette _DEST, 170, 255, 255, 255, 0, 255, 255, 255
    END SELECT
END SUB


' Generates a gradient palette
SUB Graphics_SetGradientPalette (dstImage AS LONG, s AS _UNSIGNED _BYTE, e AS _UNSIGNED _BYTE, rs AS _UNSIGNED _BYTE, gs AS _UNSIGNED _BYTE, bs AS _UNSIGNED _BYTE, re AS _UNSIGNED _BYTE, ge AS _UNSIGNED _BYTE, be AS _UNSIGNED _BYTE)
    ' Calculate gradient height
    DIM h AS SINGLE: h = 1! + CSNG(e) - CSNG(s)

    ' Set initial rgb values
    DIM r AS SINGLE: r = rs
    DIM g AS SINGLE: g = gs
    DIM b AS SINGLE: b = bs

    ' Calculate RGB stepping
    DIM rStep AS SINGLE: rStep = (CSNG(re) - CSNG(rs)) / h
    DIM gStep AS SINGLE: gStep = (CSNG(ge) - CSNG(gs)) / h
    DIM bStep AS SINGLE: bStep = (CSNG(be) - CSNG(bs)) / h

    ' Generate palette
    DIM i AS LONG: FOR i = s TO e
        _PALETTECOLOR i, _RGB32(r, g, b), dstImage

        r = r + rStep
        g = g + gStep
        b = b + bStep
    NEXT i
END SUB

' Calculates and returns the hertz value when repeatedly called inside a loop
FUNCTION GetHertz~&
    DECLARE LIBRARY
        FUNCTION GetTicks~&&
    END DECLARE

    STATIC AS _UNSIGNED LONG counter, finalFPS
    STATIC lastTime AS _UNSIGNED _INTEGER64

    DIM currentTime AS _UNSIGNED _INTEGER64: currentTime = GetTicks

    IF currentTime >= lastTime + 1000 THEN
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    END IF

    counter = counter + 1

    GetHertz = finalFPS
END FUNCTION
