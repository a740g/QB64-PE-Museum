' Created by QB64 community member DANILIN

OPTION _EXPLICIT

DIM AS LONG n, q, y, x, t, i, j

n = 200
q = 15
SCREEN 12

DIM a(q + 1, n) 'relup.bas 5d relief up

FOR x = 1 TO q
    FOR y = 1 TO n - 5
        IF INT(RND * 100) MOD 7 = 5 THEN
            a(x, y) = 5
            a(x, y + 1) = 10
            a(x, y + 2) = 20
            a(x, y + 3) = 40
            a(x, y + 4) = 80
            y = y + 5
        END IF
    NEXT
NEXT

FOR t = 1 TO n - q
    FOR i = 1 TO q - 1
        FOR j = 1 TO q - 1
            a(i, j) = a(i, j + t)
        NEXT
    NEXT

    _DELAY 0.1
    CLS

    FOR y = 1 TO q - 1
        FOR x = 1 TO q - 2
            LINE (30 + 20 * x + 20 * y, 400 - 20 * y - a(x, y))-(30 + 20 * (x + 1) + 20 * y, 400 - 20 * y - a(x + 1, y)), (y + t MOD 7) + 1
        NEXT
    NEXT

    FOR x = 1 TO q - 1
        FOR y = 1 TO q - 2
            LINE (30 + 20 * x + 20 * y, 400 - 20 * y - a(x, y))-(30 + 20 * (x + 1) + 20 * y, 400 - 20 * (y + 1) - a(x, y + 1)), 7
        NEXT
    NEXT

    _DISPLAY
NEXT

END
