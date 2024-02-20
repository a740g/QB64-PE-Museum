' https://qb64phoenix.com/forum/showthread.php?tid=2451

DEFDBL A-Z

CONST d = 300
CONST z0 = 550
CONST oy = 0

DIM SHARED pi
pi = 4 * ATN(1)

DIM x(5), y(5), z(5)
x(0) = 0: y(0) = 70: z(0) = 0
x(1) = 70: y(1) = -70: z(1) = 70
x(2) = -70: y(2) = -70: z(2) = 70
x(3) = -70: y(3) = -70: z(3) = -70
x(4) = 70: y(4) = -70: z(4) = -70
x(5) = 70: y(5) = -70: z(5) = 70

zoom = 4

sw = 640
sh = 480

SCREEN _NEWIMAGE(sw, sh, 32)

a = 0
DO
    CLS

    a = a + 0.01

    xx = x(0)
    yy = y(0)
    zz = z(0)

    rot yy, zz, a
    rot xx, zz, a

    proj p0, q0, xx, yy, zz

    'draw all triangles
    FOR i = 1 TO 4
        x1 = x(i)
        y1 = y(i)
        z1 = z(i)

        rot y1, z1, a
        rot x1, z1, a


        x2 = x(i + 1)
        y2 = y(i + 1)
        z2 = z(i + 1)

        rot y2, z2, a
        rot x2, z2, a

        c = _RGB32(35, 35, 35)

        proj p, q, x1, y1, z1
        PSET (sw / 2 + zoom * p0, sh / 2 - zoom * q0 + oy), c
        LINE -(sw / 2 + zoom * p, sh / 2 - zoom * q + oy), c

        proj p, q, x2, y2, z2
        LINE -(sw / 2 + zoom * p, sh / 2 - zoom * q + oy), c
        LINE -(sw / 2 + zoom * p0, sh / 2 - zoom * q0 + oy), c
    NEXT

    'draw the visible triangles
    FOR i = 1 TO 4
        x1 = x(i)
        y1 = y(i)
        z1 = z(i)

        rot y1, z1, a
        rot x1, z1, a

        x2 = x(i + 1)
        y2 = y(i + 1)
        z2 = z(i + 1)

        rot y2, z2, a
        rot x2, z2, a

        'vector cross product
        cz = (x1 - xx) * (y2 - yy) - (y1 - yy) * (x2 - xx)

        IF cz > 0 THEN
            c = _RGB32(255, 255, 255)

            proj p, q, x1, y1, z1
            PSET (sw / 2 + zoom * p0, sh / 2 - zoom * q0 + oy), c
            LINE -(sw / 2 + zoom * p, sh / 2 - zoom * q + oy), c

            proj p, q, x2, y2, z2
            LINE -(sw / 2 + zoom * p, sh / 2 - zoom * q + oy), c
            LINE -(sw / 2 + zoom * p0, sh / 2 - zoom * q0 + oy), c
        END IF
    NEXT

    'draw the base
    xx = x(1)
    yy = y(1)
    zz = z(1)
    rot yy, zz, a
    rot xx, zz, a

    x1 = x(2)
    y1 = y(2)
    z1 = z(2)
    rot y1, z1, a
    rot x1, z1, a

    x2 = x(3)
    y2 = y(3)
    z2 = z(3)
    rot y2, z2, a
    rot x2, z2, a

    cz = (x1 - xx) * (y2 - yy) - (y1 - yy) * (x2 - xx)

    IF cz < 0 THEN
        c = _RGB32(255, 255, 255)
        proj p0, q0, xx, yy, zz
        PSET (sw / 2 + zoom * p0, sh / 2 - zoom * q0 + oy), c
        FOR i = 2 TO 5
            xx = x(i)
            yy = y(i)
            zz = z(i)

            rot yy, zz, a
            rot xx, zz, a

            proj p, q, xx, yy, zz
            LINE -(sw / 2 + zoom * p, sh / 2 - zoom * q + oy), c
        NEXT
    END IF

    _DISPLAY
    _LIMIT 30
LOOP UNTIL _KEYHIT = 27
SLEEP
SYSTEM

'rotate
SUB rot (x, y, a)
    xx = x * COS(a) - y * SIN(a)
    yy = x * SIN(a) + y * COS(a)
    x = xx
    y = yy
END SUB

'perspective projection
SUB proj (p, q, x, y, z)
    dz = z0 + z
    p = x * d / dz
    q = y * d / dz
END SUB
