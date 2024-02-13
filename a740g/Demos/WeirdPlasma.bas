' Weird plasma - a740g, 2023

$RESIZE:SMOOTH
OPTION _EXPLICIT

SCREEN _NEWIMAGE(_DESKTOPWIDTH, _DESKTOPHEIGHT, 32)

_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_DISPLAYORDER _HARDWARE , _HARDWARE1 , _GLRENDER , _SOFTWARE
_PRINTMODE _KEEPBACKGROUND

WHILE _KEYHIT <> 27
    CLS , 0

    DrawWeirdPlasma

    _PRINTSTRING (0, 0), STR$(GetHertz) + " FPS"

    _DISPLAY

    _LIMIT 120
WEND

SYSTEM


SUB DrawWeirdPlasma
    CONST DIVIDER = 16

    STATIC AS LONG t, buffer, W, H, right, bottom
    STATIC memBuffer AS _MEM

    IF buffer = 0 THEN
        buffer = _NEWIMAGE(_WIDTH \ DIVIDER, _HEIGHT \ DIVIDER, 32)
        memBuffer = _MEMIMAGE(buffer)
        W = _WIDTH(buffer)
        right = W - 1
        H = _HEIGHT(buffer)
        bottom = H - 1
    END IF

    DIM AS LONG x, y
    DIM AS SINGLE r, g, b, r2, g2, b2

    FOR y = 0 TO bottom
        FOR x = 0 TO right
            r = 128! + 127! * SIN(x * 0.0625! - t * 0.05!)
            g = 128! + 127! * SIN(y * 0.0625! - t * 0.045455!)
            b = 128! + 127! * SIN((x + y) * 0.03125! - t * 0.041667!)
            r2 = 128! + 127! * SIN(y * 0.03125! + t * 0.038462!)
            g2 = 128! + 127! * SIN(x * 0.03125! + t * 0.035714!)
            b2 = 128! + 127! * SIN((x - y) * 0.03125! + t * 0.033333!)

            _MEMPUT memBuffer, memBuffer.OFFSET + (4& * W * y) + x * 4&, _RGB32((r + r2) * 0.5!, (g + g2) * 0.5!, (b + b2) * 0.5!, 255) AS _UNSIGNED LONG
        NEXT
    NEXT

    DIM bufferGPU AS LONG: bufferGPU = _COPYIMAGE(buffer, 33)
    _PUTIMAGE , bufferGPU
    _FREEIMAGE bufferGPU

    t = t + 1
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
