' Plasma demo - a740g
' C version - 2003
' QB64-PE port - 2024
' https://lodev.org/cgtutor/plasma.html

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

RANDOMIZE TIMER

DIM cosTbl(0 TO 255) AS LONG

' Switch to graphics mode
SCREEN _NEWIMAGE(640, 400, 256)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND

' Initialize cos table
DIM i AS LONG: FOR i = 0 TO 255
    cosTbl(i) = 27! * COS(i * _PI(0.0078125!))
NEXT i

' Set up a gradient like palette
FOR i = 0 TO 31
    _PALETTECOLOR i, _RGB32(0, 0, 8 * i - 1)
    _PALETTECOLOR i + 32, _RGB32(8 * i - 1, 0, 255)
    _PALETTECOLOR i + 64, _RGB32(255, 8 * i - 1, 255)
    _PALETTECOLOR i + 96, _RGB32(255, 255, 255)

    _PALETTECOLOR i + 128, _RGB32(255, 255, 255)
    _PALETTECOLOR i + 160, _RGB32(255, 255, 256 - 8 * i)
    _PALETTECOLOR i + 192, _RGB32(255, 256 - 8 * i, 0)
    _PALETTECOLOR i + 224, _RGB32(256 - 8 * i, 0, 0)
NEXT i

_KEYCLEAR

DIM mX AS LONG: mX = _WIDTH - 1
DIM mY AS LONG: mY = _HEIGHT - 1
DIM AS _UNSIGNED _BYTE a1, b1, a2, b2, a3, b3, a4, b4

COLOR 96

DO
    a1 = b1
    a2 = b2

    DIM y AS LONG: FOR y = 0 TO mY
        a3 = b3
        a4 = b4

        DIM x AS LONG: FOR x = 0 TO mX
            PSET (x, y), cosTbl(a1) + cosTbl(a2) + cosTbl(a3) + cosTbl(a4)

            ' Higher values result in many slower plasmas
            a3 = a3 + 1
            a4 = a4 + 2
        NEXT x

        ' Same as the previous comment
        a1 = a1 + 1
        a2 = a2 + 2
    NEXT y

    ' The higher these vars are incremented, the faster is the plasma. Need'nt be similar
    b1 = b1 + 3
    b2 = b2 - 5
    b3 = b3 - 3
    b4 = b4 + 2

    _PRINTSTRING (0, 0), STR$(GetHertz) + " FPS"

    _DISPLAY

    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

_KEYCLEAR

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
