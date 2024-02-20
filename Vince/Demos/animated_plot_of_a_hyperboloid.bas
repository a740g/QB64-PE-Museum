DIM SHARED pi
pi = 4 * ATN(1)

CONST d = 700
CONST z0 = 2500

CONST sw = 640
CONST sh = 480

rr = 500
h = 1200

SCREEN 12

DO
    FOR t = 0 TO h STEP 10
        CLS
        hyperb rr, t, 0, 0

        _DISPLAY
        _LIMIT 100
    NEXT

    FOR b = 0 TO 0.80 * pi / 2 STEP 0.008
        CLS
        hyperb rr, h, b, 0

        _DISPLAY
        _LIMIT 100
    NEXT

    _DELAY 0.5

    FOR rot = 0 TO 0.9 * pi / 2 STEP 0.01
        CLS
        hyperb rr, h, 0.80 * pi / 2, rot

        _DISPLAY
        _LIMIT 100
    NEXT

    _DELAY 0.5

    FOR i = 0 TO 1 STEP 0.005
        CLS
        hyperb rr, h, (1 - i) * 0.80 * pi / 2, (1 - i) * 0.9 * pi / 2

        _DISPLAY
        _LIMIT 100
    NEXT

    FOR t = 0 TO h STEP 10
        CLS
        hyperb rr, h - t, 0, 0

        _DISPLAY
        _LIMIT 100
    NEXT
LOOP
SYSTEM

'radius, height, twist, rotate
SUB hyperb (r, h, b, rot)
    a = 0
    x = r * COS(a - b)
    z = r * SIN(a - b)
    y = -h / 2 + 200

    yy = y * COS(rot) - z * SIN(rot)
    zz = y * SIN(rot) + z * COS(rot)
    y = yy
    z = zz

    ox = x
    oz = z
    oy = y


    x = r * COS(a + b)
    z = r * SIN(a + b)
    y = h / 2 + 200

    yy = y * COS(rot) - z * SIN(rot)
    zz = y * SIN(rot) + z * COS(rot)
    y = yy
    z = zz

    oxx = x
    oyy = y
    ozz = z


    FOR a = 2 * pi / 30 TO 2 * pi STEP 2 * pi / 30
        x = r * COS(a - b)
        z = r * SIN(a - b)
        y = -h / 2 + 200

        yy = y * COS(rot) - z * SIN(rot)
        zz = y * SIN(rot) + z * COS(rot)
        y = yy
        z = zz

        PSET (sw / 2 + ox * d / (oz + z0), sh / 2 - 50 + oy * d / (oz + z0))
        LINE -(sw / 2 + x * d / (z + z0), sh / 2 - 50 + y * d / (z + z0))

        ox = x
        oy = y
        oz = z


        x = r * COS(a + b)
        z = r * SIN(a + b)
        y = h / 2 + 200

        yy = y * COS(rot) - z * SIN(rot)
        zz = y * SIN(rot) + z * COS(rot)
        y = yy
        z = zz

        LINE -(sw / 2 + x * d / (z + z0), sh / 2 - 50 + y * d / (z + z0))
        LINE -(sw / 2 + oxx * d / (ozz + z0), sh / 2 - 50 + oyy * d / (ozz + z0))

        oxx = x
        oyy = y
        ozz = z
    NEXT
END SUB
