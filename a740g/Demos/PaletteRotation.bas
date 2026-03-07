' Palette rotation demo - a740g
' C version - 2003
' QB64-PE port - 2024

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

RANDOMIZE TIMER

' Switch to graphics mode
SCREEN _NEWIMAGE(800, 400, 256)
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH

' Setup a gradient palette (b->r->g->b)
Graphics_SetGradientPalette _DEST, 0, 85, 0, 0, 255, 255, 0, 0
Graphics_SetGradientPalette _DEST, 85, 170, 255, 0, 0, 0, 255, 0
Graphics_SetGradientPalette _DEST, 170, 255, 0, 255, 0, 0, 0, 255

' Draw random pixels
DIM y AS LONG: FOR y = 0 TO _HEIGHT - 1
    DIM x AS LONG: FOR x = 0 TO _WIDTH - 1
        PSET (x, y), RND * 255
    NEXT x
NEXT y

' Draw a few concentric circles
FOR x = 256 TO 1 STEP -1
    CIRCLE (_WIDTH \ 2, _HEIGHT \ 2), 2 * x, x - 1
NEXT x

FOR x = 0 TO 4
    Graphics_Blur _DEST
NEXT x

_KEYCLEAR

DO
    Graphics_RotatePalette _DEST, -1, 0, 255
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

_KEYCLEAR

DO
    Graphics_RotatePalette _DEST, 0, 0, 255
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

SYSTEM

SUB Graphics_Blur (img AS LONG)
    DIM oldDest AS LONG: oldDest = _DEST
    _DEST img

    DIM w AS LONG: w = _WIDTH
    DIM h AS LONG: h = _HEIGHT

    DIM x AS LONG, y AS LONG
    DIM a AS _UNSIGNED LONG, b AS _UNSIGNED LONG, c AS _UNSIGNED LONG

    FOR y = 0 TO h - 1
        a = POINT(0, y)
        b = a
        c = POINT(1, y)

        PSET (0, y), (a + b + c) \ 3

        FOR x = 1 TO w - 2
            a = b
            b = c
            c = POINT(x + 1, y)
            PSET (x, y), (a + b + c) \ 3
        NEXT

        a = b
        b = c
        PSET (w - 1, y), (a + b + c) \ 3
    NEXT

    FOR x = 0 TO w - 1
        a = POINT(x, 0)
        b = a
        c = POINT(x, 1)

        PSET (x, 0), (a + b + c) \ 3

        FOR y = 1 TO h - 2
            a = b
            b = c
            c = POINT(x, y + 1)
            PSET (x, y), (a + b + c) \ 3
        NEXT

        a = b
        b = c
        PSET (x, h - 1), (a + b + c) \ 3
    NEXT

    _DEST oldDest
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

' Rotates an image palette left or right
SUB Graphics_RotatePalette (dstImage AS LONG, isForward AS _BYTE, startIndex AS _UNSIGNED _BYTE, stopIndex AS _UNSIGNED _BYTE)
    IF stopIndex > startIndex THEN
        DIM tempColor AS _UNSIGNED LONG, i AS LONG

        IF isForward THEN
            ' Save the last color
            tempColor = _PALETTECOLOR(stopIndex, dstImage)

            ' Shift places for the remaining colors
            FOR i = stopIndex TO startIndex + 1 STEP -1
                _PALETTECOLOR i, _PALETTECOLOR(i - 1, dstImage), dstImage
            NEXT i

            ' Set first to last
            _PALETTECOLOR startIndex, tempColor, dstImage
        ELSE
            ' Save the first color
            tempColor = _PALETTECOLOR(startIndex, dstImage)

            ' Shift places for the remaining colors
            FOR i = startIndex TO stopIndex - 1
                _PALETTECOLOR i, _PALETTECOLOR(i + 1, dstImage), dstImage
            NEXT i

            ' Set last to first
            _PALETTECOLOR stopIndex, tempColor, dstImage
        END IF
    END IF
END SUB
