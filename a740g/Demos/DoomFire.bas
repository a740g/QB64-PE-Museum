' Doom fire demo - a740g
' C version - 2003
' QB64-PE port - 2024
' Tons of optimizations are possible

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

RANDOMIZE TIMER

$RESIZE:SMOOTH
SCREEN _NEWIMAGE(320, 200, 256)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND

' Generate a 256-color palette from black -> red -> yellow -> white
DIM x AS LONG
FOR x = 0 TO 255
    ' Hue goes from 0 to 60 (Red to Yellow)
    ' Saturation is constant (100) for vivid colors
    ' Brightness increases gradually from 0 to 100 and then stays at 100
    ' Alpha is 100 for full opacity
    IF x <= 128 THEN
        ' For the first half, brightness gradually increases
        _PALETTECOLOR x, _HSBA32(x / 4.25!, 100, (x * 200 \ 255), 100)
    ELSE
        ' For the second half, brightness stays at maximum
        _PALETTECOLOR x, _HSBA32(x / 4.25!, 100, 100, 100)
    END IF

    PSET (x, _HEIGHT - 1), x

    _DISPLAY
    _DELAY 0.01!
NEXT x

DIM w AS LONG: w = _WIDTH
DIM h AS LONG: h = _HEIGHT
DIM mX AS LONG: mX = w - 1
DIM mY AS LONG: mY = h - 1

COLOR 255

DO
    ' Fill the bottom line with random values
    FOR x = 0 TO mX
        PSET (x, mY), _CAST(_UNSIGNED _BYTE, RND * 256)
    NEXT x

    ' Calculate pixel values
    FOR x = 0 TO mX
        DIM y AS LONG: FOR y = 0 TO mY - 1
            PSET (x, y), (POINT(x, y + 1 * RND) + POINT(x - 1 * RND, y + 1 * RND) + POINT(x + 1 * RND, y + 1 * RND)) \ 3
        NEXT y
    NEXT x

    _PRINTSTRING (0, 0), STR$(GetHertz) + " FPS"

    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYHIT = _KEY_ESC

SYSTEM

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
