DEFDBL A-Z
' Vertex rotation test

SCREEN 7

' The end coordinates for the line segment representing a "wall"
DIM vx1(20), vx2(20), vy1(20), vy2(20)
DIM tx1(20), tz1(20), tx2(20), tz2(20), wc(20) AS INTEGER

DIM w AS INTEGER, nw AS INTEGER
READ nw
FOR w = 1 TO nw: READ vx1(w), vy1(w), vx2(w), vy2(w), wc(w): NEXT


' Coordinates of the player
px = 80
py = 15
angle = 0
dir% = 0

DO
    ' Draw the absolute map
    VIEW (4, 40)-(103, 149), 0, 1

    LINE (px, py)-(px + 5 * COS(angle), py + 5 * SIN(angle)), 8
    FOR w = 1 TO nw
        LINE (vx1(w), vy1(w))-(vx2(w), vy2(w)), wc(w)
    NEXT
    PSET (px, py), 15

    ' Draw the transformed map
    VIEW (109, 40)-(208, 149), 0, 2

    FOR w = 1 TO nw
        ' Transform the vertexes relative to the player
        tx1(w) = vx1(w) - px: ty1(w) = vy1(w) - py
        tx2(w) = vx2(w) - px: ty2(w) = vy2(w) - py
        ' Rotate them around the player's view
        tz1(w) = tx1(w) * COS(angle) + ty1(w) * SIN(angle)
        tz2(w) = tx2(w) * COS(angle) + ty2(w) * SIN(angle)
        tx1(w) = tx1(w) * SIN(angle) - ty1(w) * COS(angle)
        tx2(w) = tx2(w) * SIN(angle) - ty2(w) * COS(angle)

        LINE (50 - tx1(w), 50 - tz1(w))-(50 - tx2(w), 50 - tz2(w)), wc(w)
    NEXT

    LINE (50, 50)-(50, 45), 8
    PSET (50, 50), 15

    ' Draw the perspective-transformed map
    VIEW (214, 40)-(315, 149), 0, 3

    IF dir% = 0 THEN
        FOR w = 1 TO nw: GOSUB r: NEXT
    ELSE
        FOR w = nw TO 1 STEP -1: GOSUB r: NEXT
    END IF

    inputs:

    ' Wait for screen refresh and swap page
    SCREEN , , page%, 1 - page%: page% = 1 - page%
    FOR w = 1 TO 1000: GOSUB k: NEXT
    WAIT &H3DA, &H8, &H8: WAIT &H3DA, &H8

    GOSUB k
    SELECT CASE INKEY$
        'CASE CHR$(0) + "H": px = px + COS(angle): py = py + SIN(angle)
        'CASE CHR$(0) + "P": px = px - COS(angle): py = py - SIN(angle)
        'CASE CHR$(0) + "K": angle = angle - .1
        'CASE CHR$(0) + "M": angle = angle + .1
        'CASE "a", "A": px = px + SIN(angle): py = py - COS(angle)
        'CASE "d", "D": px = px - SIN(angle): py = py + COS(angle)
        CASE "q", "Q", CHR$(27): EXIT DO
        CASE "R": dir% = 1 - dir%
        CASE " ": up = 0: st = 0: lt = 0
    END SELECT
    IF up THEN px = px + up * COS(angle) * .3: py = py + up * SIN(angle) * .3
    angle = angle - .02 * lt
    IF st THEN px = px + st * SIN(angle) * .3: py = py - st * COS(angle) * .3
LOOP

SYSTEM

r:
IF tz1(w) > 0 OR tz2(w) > 0 THEN
    ' If tz1 is behind viewer, scale: e = (b-a)*(f-d)/(c-a)+d     with b=0.1, a=tz1, c=tz2, d=tx1, f=tx2

    CALL Intersect(tx1(w), tz1(w), tx2(w), tz2(w), -.0001, .0001, -10, 5, ix1, iz1)
    CALL Intersect(tx1(w), tz1(w), tx2(w), tz2(w), .0001, .0001, 10, 5, ix2, iz2)
    IF tz1(w) <= 0 THEN IF iz1 > 0 THEN tx1(w) = ix1: tz1(w) = iz1 ELSE tx1(w) = ix2: tz1(w) = iz2
    IF tz2(w) <= 0 THEN IF iz1 > 0 THEN tx2(w) = ix1: tz2(w) = iz1 ELSE tx2(w) = ix2: tz2(w) = iz2
    IF tz1(w) < 0 OR tz2(w) < 0 THEN RETURN

    x1& = -tx1(w) * 74 / tz1(w): y1a = -140 / tz1(w): y1b = 140 / tz1(w)
    x2& = -tx2(w) * 74 / tz2(w): y2a = -140 / tz2(w): y2b = 140 / tz2(w)

    'IF y1a < -50 AND y1b > 50 AND y2a < -50 AND y2b > 50 THEN RETURN
    IF x2 >= x1 THEN
        mix& = x1&: IF mix& < -50 THEN mix& = -50
        max& = x2&: IF max& > 50 THEN max& = 50
        FOR x& = mix& TO max&
            ya = y1a + (x& - x1&) * CDBL(y2a - y1a) / (x2& - x1& + 1)
            yb = y1b + (x& - x1&) * CDBL(y2b - y1b) / (x2& - x1& + 1)
            LINE (50 + x&, 50 + ya)-(50 + x&, 50 + yb), wc(w)
            GOSUB k
        NEXT
        LINE (50 + x1&, 50 + y1a)-(50 + x1&, 50 + y1b), wc(w) AND 7
        LINE (50 + x2&, 50 + y2a)-(50 + x2&, 50 + y2b), wc(w) AND 7
    END IF
END IF
RETURN
k:
SELECT CASE INP(&H60)
CASE &H48: up = 1: CASE &HC8: up = 0
CASE &H50: up = -1: CASE &HD8: up = 0
CASE &H4B: lt = 1: CASE &HCB: lt = 0
CASE &H4D: lt = -1: CASE &HCD: lt = 0
CASE &H1E: st = 1: CASE &H9E: st = 0
CASE &H20: st = -1: CASE &HA0: st = 0
END SELECT
RETURN


DATA 7
DATA 63,20,63,60,14
DATA 63,60,20,50,13
DATA 20,50,36,40,12
DATA 36,40,60,0,11
'DATA 60,10, 70,20, 10
DATA 60,0,90,10,10
DATA 90,20,63,20,9
DATA 90,10,90,20,4


FUNCTION FNcross (x1, y1, x2, y2)
    FNcross = x1 * y2 - y1 * x2
END FUNCTION

SUB Intersect (x1, y1, x2, y2, x3, y3, x4, y4, x, y)
    x = FNcross(x1, y1, x2, y2)
    y = FNcross(x3, y3, x4, y4)
    det = FNcross(x1 - x2, y1 - y2, x3 - x4, y3 - y4)
    x = FNcross(x, x1 - x2, y, x3 - x4) / det
    y = FNcross(x, y1 - y2, y, y3 - y4) / det
END SUB
