_TITLE "Fake 3D demo" 'b+ 2020- 01-30

CONST xmax = 700, ymax = 300, xc = 300, yc = 300
SCREEN _NEWIMAGE(xmax, ymax, 32)
_DELAY .25 'need time for screen to load before attempting to move it.
_SCREENMOVE _MIDDLE
REDIM colr AS _UNSIGNED LONG
FOR i = 1 TO 50
    colr = _RGB32(0 + 5 * i, 0, 0)
    Text 60 + i, 20 + i, 256, colr, "QB64"
NEXT
SLEEP

SUB Text (x, y, textHeight, K AS _UNSIGNED LONG, txt$)
    DIM fg AS _UNSIGNED LONG, cur&, I&, multi, xlen
    fg = _DEFAULTCOLOR
    'screen snapshot
    cur& = _DEST
    I& = _NEWIMAGE(8 * LEN(txt$), 16, 32)
    _DEST I&
    COLOR K, _RGBA32(0, 0, 0, 0)
    _PRINTSTRING (0, 0), txt$
    multi = textHeight / 16
    xlen = LEN(txt$) * 8 * multi
    _PUTIMAGE (x, y)-STEP(xlen, textHeight), I&, cur&
    COLOR fg
    _FREEIMAGE I&
END SUB
