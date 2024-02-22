SCREEN _NEWIMAGE(640, 488, 32)
_ALLOWFULLSCREEN _SQUAREPIXELS
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
DIM AS INTEGER MAX, MAX2

start:
MAX = 25 + INT(RND * 25): MAX2 = MAX / 2
REDIM U(MAX, MAX, MAX) AS _BYTE
REDIM U2(MAX, MAX, MAX) AS _BYTE

MoveZ = -MAX2 / 2
rand = (RND - RND * .25) * .2
RANDOMIZE TIMER
t = 0

FOR x = 1 TO MAX - 1
    FOR y = 1 TO MAX - 1
        FOR z = 1 TO MAX - 1
            IF RND < .5 + rand THEN U(x, y, z) = 1: t = t + 1 ELSE U(x, y, z) = -1
NEXT z, y, x

DIM Shade(255) AS LONG

FOR c = 0 TO 255
    i& = _NEWIMAGE(1, 1, 32)
    _DEST i&
    LINE (0, 0)-(_WIDTH(i&), _HEIGHT(i&)), _RGB(c, c, c), BF
    Shade(c) = _COPYIMAGE(i&, 33)
    _FREEIMAGE i&
NEXT c

DO
    TEX = .4 - (MoveZ + 10.5) * .001
    IF _FULLSCREEN THEN _MOUSEHIDE ELSE _MOUSESHOW
    IF _KEYDOWN(18432) THEN MoveZ = MoveZ - 1
    IF _KEYDOWN(20480) THEN MoveZ = MoveZ + 1
    CLS
    frames% = frames% + 1
    IF oldtime$ <> TIME$ THEN
        fps = frames%
        frames% = 1
        oldtime$ = TIME$
    END IF
    _LIMIT 10
    COLOR _RGB(0, 0, 0), _RGB(200, 200, 200)
    PRINT t; " first gen cell alive "; b; "live cell at now!"
    COLOR _RGB(0, 0, 0), _RGB(227, 227, 227)
    PRINT "up down arrow key to move forward or backward"
    COLOR _RGB(0, 0, 0), _RGB(255, 255, 255)
    PRINT "space to restart || current grid:"; MAX; "^3"
    COLOR _RGB(255, 255, 255), _RGB(0, 0, 0)
    a = a + (fps) / 160
    IF a > 360 THEN a = 0
    cos1 = COS(a)
    sin1 = SIN(a)

    FOR x = 1 TO MAX - 1
        FOR y = 1 TO MAX - 1
            FOR z = 1 TO MAX - 1
                IF U(x, y, z) = 1 THEN
                    'set up cube
                    ix = (x - MAX2) - TEX: iy = (y - MAX2) - TEX: iz = (z - MAX2) - TEX
                    jx = (x - MAX2) + TEX: jy = (y - MAX2) - TEX: jz = (z - MAX2) - TEX
                    kx = (x - MAX2) + TEX: ky = (y - MAX2) + TEX: kz = (z - MAX2) - TEX
                    lx = (x - MAX2) - TEX: ly = (y - MAX2) + TEX: lz = (z - MAX2) - TEX

                    mx = (x - MAX2) - TEX: my = (y - MAX2) - TEX: mz = (z - MAX2) + TEX
                    nx = (x - MAX2) + TEX: ny = (y - MAX2) - TEX: nz = (z - MAX2) + TEX
                    ox = (x - MAX2) + TEX: oy = (y - MAX2) + TEX: oz = (z - MAX2) + TEX
                    px = (x - MAX2) - TEX: py = (y - MAX2) + TEX: pz = (z - MAX2) + TEX
                    'rotation x/z
                    ax = (ix) * cos1 - (iz) * sin1 '
                    az = (ix) * sin1 + (iz) * cos1 '
                    ay = iy
                    bx = (jx) * cos1 - (jz) * sin1
                    bz = (jx) * sin1 + (jz) * cos1 '
                    by = jy
                    cx = (kx) * cos1 - (kz) * sin1
                    cz = (kx) * sin1 + (kz) * cos1 '
                    cy = ky
                    dx = (lx) * cos1 - (lz) * sin1
                    dz = (lx) * sin1 + (lz) * cos1 '
                    dy = ly

                    ex = (mx) * cos1 - (mz) * sin1
                    ez = (mx) * sin1 + (mz) * cos1 '
                    ey = my
                    fx = (nx) * cos1 - (nz) * sin1
                    fz = (nx) * sin1 + (nz) * cos1 '
                    fy = ny
                    gx = (ox) * cos1 - (oz) * sin1 '
                    gz = (ox) * sin1 + (oz) * cos1 '
                    gy = oy
                    hx = (px) * cos1 - (pz) * sin1
                    hz = (px) * sin1 + (pz) * cos1 '
                    hy = py

                    'front
                    push = -(MAX + MAX2 + MoveZ)
                    u = checkV(ax, ay, az - push, bx, by, bz - push, dx, dy, dz - push)
                    IF u > 0 THEN
                        col% = maxi((205 - (((dz + MAX2)) / MAX) * 205) * u + 25)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(ax, ay, -az + push)-(bx, by, -bz + push)-(dx, dy, -dz + push)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(bx, by, -bz + push)-(cx, cy, -cz + push)-(dx, dy, -dz + push)
                    END IF
                    'back
                    u = checkV(hx, hy, hz - push, fx, fy, fz - push, ex, ey, ez - push)
                    IF u > 0 THEN
                        col% = maxi((205 - (((fz + MAX2)) / MAX) * 205) * u + 25)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(ex, ey, -ez + push)-(fx, fy, -fz + push)-(hx, hy, -hz + push)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(fx, fy, -fz + push)-(gx, gy, -gz + push)-(hx, hy, -hz + push)
                    END IF
                    'left
                    u = checkV(dx, dy, dz - push, ex, ey, ez - push, ax, ay, az - push)
                    IF u > 0 THEN
                        col% = maxi((205 - (((ez + MAX2)) / MAX) * 205) * (u) + 25)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(ax, ay, -az + push)-(ex, ey, -ez + push)-(dx, dy, -dz + push)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(ex, ey, -ez + push)-(hx, hy, -hz + push)-(dx, dy, -dz + push)
                    END IF
                    ''right
                    u = checkV(fx, fy, fz - push, cx, cy, cz - push, bx, by, bz - push)
                    IF u > 0 THEN
                        col% = maxi((205 - (((fz + MAX2)) / MAX) * 205) * (u) + 25)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(bx, by, -bz + push)-(cx, cy, -cz + push)-(fx, fy, -fz + push)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(cx, cy, -cz + push)-(gx, gy, -gz + push)-(fx, fy, -fz + push)
                    END IF
                    'up
                    u = checkV(bx, by, bz - push, ax, ay, az - push, ex, ey, ez - push)
                    IF u > 0 THEN
                        col% = maxi((205 - (((ez + MAX2)) / MAX) * 205) * (u) + 25)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(ax, ay, -az + push)-(bx, by, -bz + push)-(ex, ey, -ez + push)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(bx, by, -bz + push)-(ex, ey, -ez + push)-(fx, fy, -fz + push)
                    END IF
                    'down
                    u = checkV(hx, hy, hz - push, dx, dy, dz - push, cx, cy, cz - push)
                    IF u > 0 THEN
                        col% = maxi((205 - (((hz + MAX2)) / MAX) * 205) * (u) + 25)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(cx, cy, -cz + push)-(dx, dy, -dz + push)-(hx, hy, -hz + push)
                        _MAPTRIANGLE (0, 0)-(_WIDTH(Shade(col%)), 0)-(0, _HEIGHT(Shade(col%))), Shade(col%) TO(cx, cy, -cz + push)-(hx, hy, -hz + push)-(gx, gy, -gz + push)
                    END IF
                END IF
    NEXT z, y, x
    FOR x = 1 TO MAX - 1
        FOR y = 1 TO MAX - 1
            FOR z = 1 TO MAX - 1
                mm = 0
                IF U(x, y, z) = 1 THEN
                    FOR xx = x - 1 TO x + 1
                        FOR yy = y - 1 TO y + 1
                            FOR zz = z - 1 TO z + 1
                                IF x = xx AND y = yy AND z = zz THEN _CONTINUE
                                IF U(xx, yy, zz) = 1 THEN mm = mm + 1
                    NEXT zz, yy, xx
                    IF mm < 9 OR mm > 18 THEN U2(x, y, z) = -1 ELSE U2(x, y, z) = 1
                ELSE
                    FOR xx = x - 1 TO x + 1
                        FOR yy = y - 1 TO y + 1
                            FOR zz = z - 1 TO z + 1
                                IF x = xx AND y = yy AND z = zz THEN _CONTINUE
                                IF U(xx, yy, zz) = 1 THEN mm = mm + 1
                    NEXT zz, yy, xx
                    IF (mm > 12 AND mm < 18) THEN U2(x, y, z) = 1 ELSE U2(x, y, z) = -1
                END IF
    NEXT z, y, x
    _DISPLAY
    b = 0
    FOR x = 1 TO MAX - 1
        FOR y = 1 TO MAX - 1
            FOR z = 1 TO MAX - 1
                U(x, y, z) = U2(x, y, z)
                IF U(x, y, z) = 1 THEN b = b + 1
    NEXT z, y, x
    IF _KEYDOWN(32) THEN GOTO start
LOOP UNTIL _KEYDOWN(27)

FUNCTION checkV (x1, y1, z1, x2, y2, z2, x3, y3, z3)
    Xo = (y2 - y1) * (z3 - z1) - (z2 - z1) * (y3 - y1)
    Yo = (z2 - z1) * (x3 - x1) - (x2 - x1) * (z3 - z1)
    Zo = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1)
    D = SQR(Xo * Xo + Yo * Yo + Zo * Zo)
    nx = Xo / D: ny = Yo / D: nz = Zo / D
    px = x1: py = y1: pz = z1
    D = SQR(px * px + py * py + pz * pz)
    dx = px / D: dy = py / D: dz = pz / D
    uv = (nz * dz + ny * dy + nx * dx)
    IF uv < 0 OR uv > 1 THEN checkV = -1 ELSE checkV = uv
END FUNCTION

FUNCTION maxi (x)
    IF x > 255 THEN maxi = 255: EXIT FUNCTION
    IF x < 0 THEN maxi = 0: EXIT FUNCTION
    maxi = x
END FUNCTION
