DIM SHARED pi, sw, sh, d, z0, p, q
pi = 4 * ATN(1)
d = 700
z0 = 2500

sw = 800
sh = 600

DIM AS DOUBLE a, b, x, y, z, xx, yy, zz
SCREEN _NEWIMAGE(sw, sh, 32)
DO
    b = b + 0.03
    CLS
    FOR a = 0 TO 20 * 2 * pi STEP 0.1
        x = 5 * a * COS(a)
        y = -a * 10
        z = 5 * a * SIN(a)

        yy = (y + 350) * COS(b) - z * SIN(b)
        zz = (y + 350) * SIN(b) + z * COS(b)
        y = yy - 350
        z = zz

        xx = x * COS(b) - z * SIN(b)
        zz = x * SIN(b) + z * COS(b)
        x = xx
        z = zz

        xx = x * COS(b) - (y + 350) * SIN(b)
        yy = x * SIN(b) + (y + 350) * COS(b)
        x = xx
        y = yy - 350

        proj x, y, z

        CIRCLE (p, q), 1, _RGB32(0, 155, 0)
    NEXT

    FOR a = 0 TO 6 * pi STEP 0.1
        rr = 100
        r = 60
        x = (rr - r) * COS(a + pi / 4) + 70 * COS(((rr - r) / r) * a)
        y = 50 + (rr - r) * SIN(a + pi / 4) - 70 * SIN(((rr - r) / r) * a)
        z = 0

        yy = (y + 350) * COS(b) - z * SIN(b)
        zz = (y + 350) * SIN(b) + z * COS(b)
        y = yy - 350
        z = zz

        xx = x * COS(b) - z * SIN(b)
        zz = x * SIN(b) + z * COS(b)
        x = xx
        z = zz

        xx = x * COS(b) - (y + 350) * SIN(b)
        yy = x * SIN(b) + (y + 350) * COS(b)
        x = xx
        y = yy - 350

        proj x, y, z

        CIRCLE (p, q), 1, _RGB32(255, 255, 0)
    NEXT
    _DISPLAY
    _LIMIT 50
LOOP

SUB proj (x, y, z)
    p = sw / 2 + x * d / (z + z0)
    q = sh / 2 - (100 + y) * d / (z + z0) - 150
END SUB
