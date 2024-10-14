' Created by QB64 community member vince.

OPTION _EXPLICIT

SCREEN _NEWIMAGE(640, 480, 32)

_TITLE "Rotating Lorenz Attractor"

DIM AS DOUBLE p, s, b, h, x, y, z, i, rot, xx, yy
p = 28
s = 10
b = 8 / 3
h = 0.01

_DISPLAY

DO
    _LIMIT 60
    CLS
    rot = rot + 0.01
    x = 0.3
    y = 0.3
    z = 0.456
    xx = x * COS(rot) - y * SIN(rot)
    yy = x * SIN(rot) + y * COS(rot)

    PSET (_WIDTH / 2 + 35 * xx * 700 / (yy + 2500), _HEIGHT - 35 * z * 700 / (yy + 2500)), _RGB(255, 255, 0)
    FOR i = 0 TO 14000
        x = x + h * s * (y - x)
        y = y + h * (x * (p - z) - y)
        z = z + h * (x * y - b * z)
        xx = x * COS(rot) - y * SIN(rot)
        yy = x * SIN(rot) + y * COS(rot)
        LINE -(_WIDTH / 2 + 35 * xx * 700 / (yy + 2500), _HEIGHT - 35 * z * 700 / (yy + 2500)), _RGB(255, 255, 0)
    NEXT
    _DISPLAY
LOOP WHILE LEN(INKEY$) = 0

SYSTEM
