'===============
'PHOENIXTEST.BAS
'===============
'Are you using QB64 Phoenix, or the Bee?
'Run this code to see...
'Coded by Dav, JUL/2023


_ICON 'Single line added by Steve to add an icon which will become image handle #11


dh = _DESKTOPHEIGHT * .85
SCREEN _NEWIMAGE(dh, dh, 32)

'safety test...
IF _WIDTH(-11) <> 32 OR _HEIGHT(-11) <> 32 THEN END

bird& = _NEWIMAGE(dh, dh, 32): _DEST bird&
_PUTIMAGE (0, 0)-(dh, dh), -11: _DEST 0

row = 15: col = 15
xsize = _WIDTH / row
ysize = _HEIGHT / col
rise = _HEIGHT

DIM SHARED piece&(row * col), piecex(row * col), piecey(row * col)
DIM risespeed(row * col)

bc = 1
FOR c = 1 TO col
    FOR r = 1 TO row
        x1 = (r * xsize) - xsize: x2 = x1 + xsize
        y1 = (c * ysize) - ysize: y2 = y1 + ysize
        piecex(bc) = x1: piecey(bc) = y1
        piece&(bc) = _NEWIMAGE(ABS(x2 - x1) + 1, ABS(y2 - y1) + 1, 32)
        _PUTIMAGE (0, 0), bird&, piece&(bc), (x1, y1)-(x2, y2)
        risespeed(bc) = RND * 2 + 1
        bc = bc + 1
    NEXT
NEXT

_DEST 0

DO
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, 55), BF

    FOR t = 1 TO row * col
        tx = piecex(t): tx2 = piecex(t) + xsize
        ty = piecey(t): ty2 = piecey(t) + ysize
        RotoZoom3 piecex(t) + (xsize / 2), piecey(t) + (ysize / 2) + (rise * risespeed(t)), piece&(t), 1, 1, 0
        rise = rise - .025
        _LIMIT 3000
    NEXT
    _DISPLAY

LOOP WHILE rise > 0

FOR t = 1 TO row * col
    RotoZoom3 piecex(t) + (xsize / 2), piecey(t) + (ysize / 2), piece&(t), 1, 1, 0
    _DISPLAY
NEXT

SLEEP

SUB RotoZoom3 (X AS LONG, Y AS LONG, Image AS LONG, xScale AS SINGLE, yScale AS SINGLE, radianRotation AS SINGLE)
    DIM px(3) AS SINGLE: DIM py(3) AS SINGLE ' simple arrays for x, y to hold the 4 corners of image
    DIM W&, H&, sinr!, cosr!, i&, x2&, y2& '  variables for image manipulation
    W& = _WIDTH(Image&): H& = _HEIGHT(Image&)
    px(0) = -W& / 2: py(0) = -H& / 2 'left top corner
    px(1) = -W& / 2: py(1) = H& / 2 ' left bottom corner
    px(2) = W& / 2: py(2) = H& / 2 '  right bottom
    px(3) = W& / 2: py(3) = -H& / 2 ' right top
    sinr! = SIN(-radianRotation): cosr! = COS(-radianRotation) ' rotation helpers
    FOR i& = 0 TO 3 ' calc new point locations with rotation and zoom
        x2& = xScale * (px(i&) * cosr! + sinr! * py(i&)) + X: y2& = yScale * (py(i&) * cosr! - px(i&) * sinr!) + Y
        px(i&) = x2&: py(i&) = y2&
    NEXT
    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, H& - 1)-(W& - 1, H& - 1), Image TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2))
    _MAPTRIANGLE _SEAMLESS(0, 0)-(W& - 1, 0)-(W& - 1, H& - 1), Image TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2))
END SUB
