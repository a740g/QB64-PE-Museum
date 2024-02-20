DEFLNG A-Z

'const sw = 800
'const sh = 600

DIM SHARED pi AS DOUBLE
pi = 4 * ATN(1)

img = _LOADIMAGE("nefertiti.jpg", 32)
w = _WIDTH(img)
h = _HEIGHT(img)

DIM zoom AS DOUBLE
DIM a AS DOUBLE
zoom = 2.5

a = 2 * SQR(w * w / 4 + h * h / 4) * zoom

IF h < a THEN h = a

SCREEN _NEWIMAGE(w + a * 2, h, 32)

_PUTIMAGE (0, 0), img

DIM rot AS DOUBLE
DO
    rot = rot + 0.1

    LINE (w, 0)-STEP(a * 2, a), _RGB(0, 0, 0), BF
    rotzoom img, w + a / 2, a / 2, rot, zoom
    rotzoomb img, w + a + a / 2, a / 2, rot, zoom

    _DISPLAY
    _LIMIT 30
LOOP UNTIL _KEYHIT = 27

SLEEP
SYSTEM

SUB rotzoomb (img, x0, y0, rot AS DOUBLE, zoom AS DOUBLE)
    DIM a AS DOUBLE
    DIM xx AS DOUBLE, yy AS DOUBLE
    DIM dx AS DOUBLE, dy AS DOUBLE

    w = _WIDTH(img)
    h = _HEIGHT(img)

    IF zoom = 0 THEN zoom = 1
    a = 2 * SQR(w * w / 4 + h * h / 4) * zoom

    _SOURCE img

    FOR y = 0 TO a
        FOR x = 0 TO a
            xx = (x - a / 2) * COS(rot) / zoom - (y - a / 2) * SIN(rot) / zoom + w / 2
            yy = (x - a / 2) * SIN(rot) / zoom + (y - a / 2) * COS(rot) / zoom + h / 2

            IF (INT(xx) >= 0 AND INT(xx) < w - 1 AND INT(yy) >= 0 AND INT(yy) < h - 1) THEN
                tl = POINT(INT(xx), INT(yy))
                tr = POINT(INT(xx) + 1, INT(yy))
                bl = POINT(INT(xx), INT(yy) + 1)
                br = POINT(INT(xx) + 1, INT(yy) + 1)

                dx = xx - INT(xx)
                dy = yy - INT(yy)

                r = _ROUND((1 - dy) * ((1 - dx) * _RED(tl) + dx * _RED(tr)) + dy * ((1 - dx) * _RED(bl) + dx * _RED(br)))
                g = _ROUND((1 - dy) * ((1 - dx) * _GREEN(tl) + dx * _GREEN(tr)) + dy * ((1 - dx) * _GREEN(bl) + dx * _GREEN(br)))
                b = _ROUND((1 - dy) * ((1 - dx) * _BLUE(tl) + dx * _BLUE(tr)) + dy * ((1 - dx) * _BLUE(bl) + dx * _BLUE(br)))

                PSET (x0 - a / 2 + x, y0 - a / 2 + y), _RGB(r, g, b)

            ELSEIF (INT(xx) >= 0 AND INT(xx) < w - 1 AND INT(yy) >= 0 AND INT(yy) < h - 1) THEN
                PSET (x0 - a / 2 + x, y0 - a / 2 + y), POINT(INT(xx), INT(yy))
            END IF
        NEXT
    NEXT
END SUB


SUB rotzoom (img, x0, y0, rot AS DOUBLE, zoom AS DOUBLE)
    DIM a AS DOUBLE

    w = _WIDTH(img)
    h = _HEIGHT(img)

    IF zoom = 0 THEN zoom = 1
    a = 2 * SQR(w * w / 4 + h * h / 4) * zoom

    _SOURCE img

    FOR y = 0 TO a
        FOR x = 0 TO a
            xx = (x - a / 2) * COS(rot) / zoom - (y - a / 2) * SIN(rot) / zoom + w / 2
            yy = (x - a / 2) * SIN(rot) / zoom + (y - a / 2) * COS(rot) / zoom + h / 2

            IF ((xx) >= 0 AND (xx) < w AND (yy) >= 0 AND (yy) < h) THEN
                PSET (x0 - a / 2 + x, y0 - a / 2 + y), POINT(INT(xx), INT(yy))
            END IF
        NEXT
    NEXT
END SUB
