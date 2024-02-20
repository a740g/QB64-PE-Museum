sw = 1024
sh = 480

DIM SHARED m
m = 20

SCREEN _NEWIMAGE(sw, sh + 1, 32)

DO
    t = t + 0.02
    m = 25 + 20 * SIN(t)
    CLS
    tri 0, sh, sw / 2, 0, sw, sh, 10
    _DISPLAY
    _LIMIT 50
LOOP

SLEEP
SYSTEM

SUB tri (x1, y1, x2, y2, x3, y3, n)

    IF n < 1 THEN EXIT SUB

    'line (x1,y1)-(x2,y2)
    'line -(x3,y3)
    'line -(x1,y1)

    cx = (x1 + x3) / 2
    cy = (y1 + y3) / 2

    'line (cx, cy) - (x2, y2), _rgb(255,0,0)

    a = _ATAN2(y3 - y1, x3 - x1)
    d = SQR((cy - y2) ^ 2 + (cx - x2) ^ 2)
    w = d * TAN(SQR(n) / m)
    nx = 1 * (w) * COS(a)
    ny = 1 * (w) * SIN(a)
    LINE (cx, cy)-STEP(nx, ny), _RGB(255, 255, 0)
    LINE -(x2, y2), _RGB(255, 255, 0)
    LINE (cx, cy)-STEP(-nx, -ny), _RGB(255, 255, 0)
    LINE -(x2, y2), _RGB(255, 255, 0)
    LINE (x1, y1)-(x3, y3), _RGB(255, 255, 0)

    tri x1, y1, cx - nx, cy - ny, x2, y2, n - 1
    tri x3, y3, cx + nx, cy + ny, x2, y2, n - 1
END SUB

