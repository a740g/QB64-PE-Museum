sw = 800
sh = 600
SCREEN _NEWIMAGE(sw, sh, 32)

x = sw / 2
y = sh / 2
vx = 0
vy = 0


DO
    IF _KEYDOWN(19200) THEN vx = vx - 3
    IF _KEYDOWN(19712) THEN vx = vx + 3
    IF _KEYDOWN(18432) THEN vy = vy - 3
    IF _KEYDOWN(20480) THEN vy = vy + 3

    x = x + vx
    y = y + vy

    IF vx > 0 THEN vx = vx - 1
    IF vy > 0 THEN vy = vy - 1
    IF vx < 0 THEN vx = vx + 1
    IF vy < 0 THEN vy = vy + 1

    CLS
    LINE (x, y)-STEP(100, 100), _RGB(255, 255, 0), BF

    _LIMIT 30
    _DISPLAY

LOOP UNTIL _KEYHIT = 27
SYSTEM
