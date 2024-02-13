' Plasma demo - a740g
' C version - 2003
' QB64-PE port - 2024

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

RANDOMIZE TIMER

' Switch to graphics mode
SCREEN _NEWIMAGE(640, 400, 256)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

' Setup a gradient palette (b->r->g->b)
Graphics_SetGradientPalette _DEST, 0, 85, 0, 0, 255, 255, 0, 0
Graphics_SetGradientPalette _DEST, 85, 170, 255, 0, 0, 0, 255, 0
Graphics_SetGradientPalette _DEST, 170, 255, 0, 255, 0, 0, 0, 255

PlasmaSubDivide 0, 0, _WIDTH - 1, _HEIGHT - 1

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


' Plots the correct plasma pixels with the correct color
SUB SetColor (xa AS LONG, ya AS LONG, x AS LONG, y AS LONG, xb AS LONG, yb AS LONG)
    IF POINT(x, y) = 0 THEN
        DIM clr AS LONG: clr = ABS(xa - xb) + ABS(ya - yb)
        clr = RND * (clr * 2) - clr
        clr = clr + ((POINT(xa, ya) + POINT(xb, yb)) \ 2)
        IF clr < 1 THEN clr = 1
        IF clr > 255 THEN clr = 255
        PSET (x, y), clr
    END IF
END SUB


' Recursive fractal plasma
SUB PlasmaSubDivide (x1 AS LONG, y1 AS LONG, x2 AS LONG, y2 AS LONG)
    IF (x2 - x1) < 2 AND (y2 - y1) < 2 THEN EXIT SUB

    DIM x AS LONG: x = (x1 + x2) \ 2
    DIM y AS LONG: y = (y1 + y2) \ 2

    SetColor x1, y1, x, y1, x2, y1
    SetColor x2, y1, x2, y, x2, y2
    SetColor x1, y2, x, y2, x2, y2
    SetColor x1, y1, x1, y, x1, y2

    IF POINT(x, y) = 0 THEN
        DIM clr AS LONG: clr = (POINT(x1, y1) + POINT(x2, y1) + POINT(x2, y2) + POINT(x1, y2)) \ 4
        IF clr < 1 THEN clr = 1
        IF clr > 255 THEN clr = 255
        PSET (x, y), clr
    END IF

    PlasmaSubDivide x1, y1, x, y
    PlasmaSubDivide x, y1, x2, y
    PlasmaSubDivide x, y, x2, y2
    PlasmaSubDivide x1, y, x, y2
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
