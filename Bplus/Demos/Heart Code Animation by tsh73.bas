_TITLE "Heart Code Animation by tsh73" 'b+ 2022-09-03 playing with Heart graphic code at JB
'    https://justbasiccom.proboards.com/thread/883/heart-shapes
SCREEN _NEWIMAGE(600, 350, 32)
COLOR &HFFFF0000, &HFFEEEEEE
M = 313
P = 100
J = 1
DIM h(1 TO 10) AS LONG
FOR k = 0 TO 9
    CLS
    J = 1
    FOR I = 0 TO 1.567 STEP 0.0005 '.5/(P*5+k/60)
        x = INT(ABS(P * (J * I + 3)))
        J = 0 - J
        CIRCLE (x, INT(P * (2 + (I ^ .01 * (ABS(COS(I)) ^ .5 * COS(M * I + k / 30)) - I ^ .3)))), 1, &HFF990000
    NEXT
    h(k + 1) = _NEWIMAGE(600, 350, 32)
    _PUTIMAGE , 0, h(k + 1)
NEXT
k = 0: dk = 1
WHILE 1
    k = (k + 1) MOD 10 + 1
    _PUTIMAGE , h(k), 0
    _LIMIT 10
WEND
