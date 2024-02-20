DEFLNG A-Z

sw = 640
sh = 480

DIM SHARED pi AS DOUBLE
pi = 4 * ATN(1)

SCREEN _NEWIMAGE(sw * 2, sh, 32)

h = 300
w = 1.9 * h
a = h / 7

img = _NEWIMAGE(w, h, 32)
_DEST img
x0 = 0
y0 = 0

LINE (0, 0)-STEP(w, h), _RGB(255, 255, 255), BF
FOR i = 0 TO 6
    LINE (0, i * h * 2 / 13)-STEP(w, h / 13), _RGB(255 * 0.698, 255 * 0.132, 255 * 0.203), BF
NEXT
LINE (0, 0)-STEP(w * 2 / 5, h * 7 / 13), _RGB(255 * 0.234, 255 * 0.233, 255 * 0.430), BF

FOR i = 0 TO 4
    FOR j = 0 TO 5
        starf (j * 2 + 1) * w * 2 / (5 * 12), (i * 2 + 1) * h * 7 / 130, h * 4 / (13 * 5 * 2), _RGB(255, 255, 255)
    NEXT
NEXT

FOR i = 1 TO 4
    FOR j = 1 TO 5
        starf (j * 2) * w * 2 / (5 * 12), (i * 2) * h * 7 / 130, h * 4 / (13 * 5 * 2), _RGB(255, 255, 255)
    NEXT
NEXT

_DEST 0
_PUTIMAGE (sw / 2 - w / 2, sh / 2 - h / 2), img
_SOURCE img

x0 = sw / 2 - w / 2 + sw
y0 = sh / 2 - h / 2 '+ sh

DIM t AS DOUBLE
DIM z AS DOUBLE

DIM xx AS DOUBLE, yy AS DOUBLE
DIM dx AS DOUBLE, dy AS DOUBLE
DO
    t = t + 0.2

    LINE (sw, 0)-STEP(sw, sh), _RGB(0, 0, 0), BF

    FOR y = 0 TO h + a * 0.707 STEP 1
        FOR x = 0 TO w + a * 0.707 STEP 1
            z = (0.1 + 0.4 * (x / w)) * a * SIN(x / 35 - y / 70 - t) + 0.5 * a
            dz = 50 * a * COS(x / 35 - y / 70 - t) / 35

            xx = x + z * 0.707 - a * 0.707
            yy = y - z * 0.707

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

                r = r + dz
                g = g + dz
                b = b + dz

                IF r < 0 THEN r = 0
                IF r > 255 THEN r = 255
                IF g < 0 THEN g = 0
                IF g > 255 THEN g = 255
                IF b < 0 THEN b = 0
                IF b > 255 THEN b = 255

                PSET (x0 + x, y0 - a * 0.707 + y), _RGB(r, g, b)
            END IF
        NEXT
    NEXT

    _DISPLAY
    _LIMIT 50
LOOP UNTIL _KEYHIT = 27

SLEEP
SYSTEM

SUB starf (x, y, r, c)
    PSET (x + r * COS(pi / 2), y - r * SIN(pi / 2)), c
    FOR i = 0 TO 5
        xx = r * COS(i * 4 * pi / 5 + pi / 2)
        yy = r * SIN(i * 4 * pi / 5 + pi / 2)
        LINE -(x + xx, y - yy), c
    NEXT
    PAINT (x, y), c
    FOR i = 0 TO 5
        xx = r * COS(i * 4 * pi / 5 + pi / 2) / 2
        yy = r * SIN(i * 4 * pi / 5 + pi / 2) / 2
        PAINT (x + xx, y - yy), c
    NEXT
END SUB
