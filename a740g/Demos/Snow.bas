' Snow demo - a740g
' C version - 2003
' QB64-PE port - 2024

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST FALSE = 0, TRUE = NOT FALSE
CONST NUMFLAKE = 1024
CONST MESSAGE = "Merry Christmas & Happy New Year!"

TYPE SnowFlakeType
    x AS LONG
    y AS LONG
    c AS _UNSIGNED LONG
END TYPE

DIM flake(1 TO NUMFLAKE) AS SnowFlakeType

RANDOMIZE TIMER

' Switch to graphics mode
SCREEN _NEWIMAGE(640, 400, 256)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

' Setup the palette
Graphics_SetGradientPalette _DEST, 2, 255, 128, 128, 128, 255, 255, 255
_PALETTECOLOR 1, _RGB32(63, 127, 255)

COLOR 1
_PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(MESSAGE) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2), MESSAGE

DIM mX AS LONG: mX = _WIDTH - 1
DIM mY AS LONG: mY = _HEIGHT - 1

' Init the flakes
DIM i AS LONG: FOR i = 1 TO NUMFLAKE
    flake(i).x = RND * mX
    flake(i).y = -(RND * mY)
    flake(i).c = 2 + RND * 253
NEXT i

_KEYCLEAR

DO
    FOR i = 1 TO NUMFLAKE
        DIM hasMoved AS _BYTE: hasMoved = FALSE
        DIM oy AS LONG: oy = flake(i).y
        DIM ox AS LONG: ox = flake(i).x
        DIM ty AS LONG: ty = oy
        DIM tx AS LONG: tx = ox

        ' Find an 'empty' space to move the flake and move it
        IF POINT(tx, ty + 1) = 0 THEN
            ty = ty + FIX(RND * 2)
            hasMoved = TRUE
        ELSEIF POINT(tx - 1, ty + 1) = 0 THEN
            ty = ty + 1
            tx = tx - 1
            hasMoved = TRUE
        ELSEIF POINT(tx + 1, ty + 1) = 0 THEN
            ty = ty + 1
            tx = tx + 1
            hasMoved = TRUE
        END IF

        IF NOT hasMoved OR ty >= mY THEN
            flake(i).x = RND * mX
            flake(i).y = -(RND * mY)
            flake(i).c = 2 + RND * 253
            _CONTINUE
        END IF

        IF oy <> ty THEN
            PSET (ox, oy), 0
            PSET (tx, ty), flake(i).c
        END IF

        flake(i).x = tx
        flake(i).y = ty
    NEXT i

    _DISPLAY

    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

END

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
