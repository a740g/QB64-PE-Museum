DEFINT A-Z

CONST sw = 800
CONST sh = 600

DIM SHARED pi AS DOUBLE
pi = 4 * ATN(1)

DIM SHARED mx, my, mbl, mbr, mw

DIM u AS DOUBLE, v AS DOUBLE
DIM uu AS DOUBLE, vv AS DOUBLE
DIM xx AS DOUBLE, yy AS DOUBLE
DIM x0 AS DOUBLE, y0 AS DOUBLE
DIM z AS DOUBLE, zz AS DOUBLE
DIM c AS SINGLE
z = 0.004
zz = 0.1
x0 = -0.5

DIM p1 AS LONG
p1 = _NEWIMAGE(sw, sh, 32)
SCREEN _NEWIMAGE(sw, sh, 32)

redraw = -1
iter = 100

DO
    mw = 0
    getmouse

    IF redraw THEN
        FOR y = 0 TO sh - 1
            FOR x = 0 TO sw - 1
                u = 0
                v = 0

                xx = (x - sw / 2) * z + x0
                yy = (y - sh / 2) * z + y0

                FOR i = 0 TO iter
                    '''mandelbrot
                    uu = u * u - v * v + xx
                    vv = 2 * u * v + yy
                    '''

                    '''burning ship
                    'u = abs(u)
                    'v = abs(v)
                    'uu = u*u - v*v + xx
                    'vv = 2*u*v + yy
                    '''

                    '''tricorn
                    'u = u
                    'v = -v
                    'uu = u*u - v*v + xx
                    'vv = 2*u*v + yy
                    '''

                    u = uu
                    v = vv

                    IF (u * u + v * v) > 4 THEN EXIT FOR
                NEXT
                IF i > iter THEN
                    PSET (x, y), _RGB32(0, 0, 0)
                ELSE
                    c = i / iter
                    r = 80 - 80 * SIN(2 * pi * c - pi / 2)
                    g = (114 + 114 * SIN(2 * pi * c * 1.5 - pi / 2)) * -(c < 0.66)
                    b = (114 + 114 * SIN(2 * pi * c * 1.5 + pi / 2)) * -(c > 0.33)

                    PSET (x, y), _RGB32(r, g, b)
                END IF
            NEXT
        NEXT

        'locate 1,1
        'print "iter =";iter
        _TITLE STR$(iter)

        _DEST p1
        _PUTIMAGE , 0
        _DEST 0

        _PUTIMAGE , p1
        _AUTODISPLAY

        redraw = 0
    END IF

    IF mw < 0 THEN
        zz = zz + 0.01
    ELSEIF mw > 0 THEN
        IF zz > 0.01 THEN zz = zz - 0.01
    END IF

    'draw box
    IF omx <> mx OR omy <> my OR mw <> 0 THEN
        _PUTIMAGE , p1
        LINE (mx - (sw * zz / 2), my - (sh * zz / 2))-STEP(sw * zz, sh * zz), _RGB32(255, 255, 255), B
        _AUTODISPLAY

        omx = mx
        omy = my
    END IF

    IF mbl THEN
        DO
            getmouse
        LOOP WHILE mbl

        x0 = x0 + (mx - sw / 2) * z
        y0 = y0 - (sh / 2 - my) * z
        z = z * zz

        iter = iter + 100

        redraw = -1
    ELSEIF mbr THEN
        DO
            getmouse
        LOOP WHILE mbr

        x0 = x0 + (mx - sw / 2) * z
        y0 = y0 - (sh / 2 - my) * z
        z = z / zz

        iter = iter - 100

        redraw = -1
    END IF

    k = _KEYHIT
    IF k = 43 THEN
        iter = iter + 50
        redraw = -1
    ELSEIF k = 45 THEN
        IF iter > 50 THEN iter = iter - 50
        redraw = -1
    END IF

LOOP UNTIL k = 27
SYSTEM

SUB getmouse ()
    DO
        mx = _MOUSEX
        my = _MOUSEY
        mbl = _MOUSEBUTTON(1)
        mbr = _MOUSEBUTTON(2)
        mw = mw + _MOUSEWHEEL
    LOOP WHILE _MOUSEINPUT
END SUB
