_TITLE "Basic Tree from branch"
'Randomize Timer
SCREEN _NEWIMAGE(800, 600, 32)
'_ScreenMove 300, 20
COLOR _RGB32(0, 255, 0)

'just test call to sub
'       x,   y,  270, .2*height, 1  start a tree with 270 degrees to point up, and about 1/5 the height you want to grow the tree
branch 400, 500, 270, 100, 1
PRINT "press any to see the forest..."
SLEEP
CLS

DIM horizon, i, y
horizon = .35 * _HEIGHT
FOR i = 0 TO horizon
    LINE (0, i)-(_WIDTH, i), _RGB(0, 0, .25 * i + 100)
NEXT
FOR i = horizon TO _HEIGHT
    LINE (0, i)-(_WIDTH, i), _RGB(0, 255 - .25 * i - 50, 0)
NEXT
FOR i = 1 TO 250
    y = randWeight(horizon, _HEIGHT, 3)
    branch _WIDTH * RND, y, 270, (.015 * RND + .027) * y, 1
NEXT
SLEEP

SUB branch (x, y, angD, lngth, lev)
    DIM x2, y2, l
    x2 = x + COS(_D2R(angD)) * lngth
    y2 = y + SIN(_D2R(angD)) * lngth
    LINE (x, y)-(x2, y2), _RGB32(RND * 100, RND * 170 + 80, RND * 50)
    IF lev > 6 OR lngth < 2 THEN EXIT SUB
    l = lev + 1
    branch x2, y2, angD + 10 + 30 * RND, .7 * lngth + .2 * RND * lngth, l
    branch x2, y2, angD - 10 - 30 * RND, .7 * lngth + .2 * RND * lngth, l
    IF RND < .65 THEN branch x2, y2, angD + 20 * RND - 10, .7 * lngth + .2 * RND * lngth, l
END SUB

FUNCTION randWeight (manyValue, fewValue, power)
    randWeight = manyValue + RND ^ power * (fewValue - manyValue)
END FUNCTION
