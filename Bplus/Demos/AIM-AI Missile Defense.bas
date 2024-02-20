W = 800: H = 600
SCREEN _NEWIMAGE(800, 600, 32)
RANDOMIZE TIMER
COLOR &HFFFFFFFF, &HFF6666DD
CLS
a:
a = RND * W: b = 0: c = RND * 6 - 3: d = RND * 3 + 3: x = 400: y = H: lastx = x: lasty = y: lasta = a: lastb = b: l = 5
l = l * 10
DO
    _TITLE "AIM-AI Missile Defense - Hits:" + STR$(t) + ", Misses:" + STR$(m)
    a = a + c: b = b + d: ang = _ATAN2(b - y, a - x)
    x = x + 7 * COS(ang): y = y + 7 * SIN(ang)
    IF x < 0 OR y < 0 OR a < 0 OR b < 0 OR x > W OR a > W OR b > H THEN
        IF b > H OR x < 0 OR y < 0 OR x > W THEN m = m + 1
        GOTO a:
    END IF
    IF ((x - a) ^ 2 + (y - b) ^ 2) ^ .5 < 10 THEN
        FOR r = 1 TO 20 STEP 4
            CIRCLE ((x + a) / 2, (y + b) / 2), r, &HFFFF0000
            _LIMIT 10
        NEXT
        t = t + 1: GOTO a:
    ELSE
        LINE (x, y)-(lastx, lasty), &HFF006600: LINE (a, b)-(lasta, lastb), &HFFDDDDFF
        lastx = x: lasty = y: lasta = a: lastb = b
    END IF
    _LIMIT l
LOOP UNTIL t = 50
SLEEP
