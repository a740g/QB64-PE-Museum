SCREEN 12
DIM o
DO
    CLS
    o = o + _PI / 180
    drawc _WIDTH / 2, _HEIGHT / 2, _WIDTH / 5, .25, 4, o
    _DISPLAY
    _LIMIT 30
LOOP

SUB drawc (x, y, r, a, n, o)
    DIM t, xx, yy
    IF n > 0 THEN
        FOR t = 0 TO _PI(2) STEP _PI(1 / 3)
            xx = x + r * COS(t + o)
            yy = y + r * SIN(t + o)
            CIRCLE (xx, yy), r
            drawc xx, yy, a * r, a, n - 1, -o - n * _PI / 180
        NEXT
    END IF
END SUB
