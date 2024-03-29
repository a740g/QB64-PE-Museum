' Vertex rotation test

SCREEN 7

' The end coordinates for the line segment representing a "wall"
vx1 = 70: vy1 = 20
vx2 = 70: vy2 = 70

' Coordinates of the player
px = 50
py = 50
angle = 0

DO
    ' Draw the absolute map
    VIEW (4, 40)-(103, 149), 0, 1

    LINE (px, py)-(px + 5 * COS(angle), py + 5 * SIN(angle)), 8
    LINE (vx1, vy1)-(vx2, vy2), 14
    PSET (px, py), 15

    ' Draw the transformed map
    VIEW (109, 40)-(208, 149), 0, 2

    ' Transform the vertexes relative to the player
    tx1 = vx1 - px: ty1 = vy1 - py
    tx2 = vx2 - px: ty2 = vy2 - py
    ' Rotate them around the player's view
    tz1 = tx1 * COS(angle) + ty1 * SIN(angle)
    tz2 = tx2 * COS(angle) + ty2 * SIN(angle)
    tx1 = tx1 * SIN(angle) - ty1 * COS(angle)
    tx2 = tx2 * SIN(angle) - ty2 * COS(angle)

    LINE (50 - tx1, 50 - tz1)-(50 - tx2, 50 - tz2), 14
    LINE (50, 50)-(50, 45), 8
    PSET (50, 50), 15

    ' Draw the perspective-transformed map
    VIEW (214, 40)-(315, 149), 0, 3

    IF tz1 > 0 OR tz2 > 0 THEN
        ' If tz1 is behind viewer, scale: e = (b-a)*(f-d)/(c-a)+d     with b=0.1, a=tz1, c=tz2, d=tx1, f=tx2

        CALL Intersect(tx1, tz1, tx2, tz2, -.0001, .0001, -20, 5, ix1, iz1)
        CALL Intersect(tx1, tz1, tx2, tz2, .0001, .0001, 20, 5, ix2, iz2)
        IF tz1 <= 0 THEN IF iz1 > 0 THEN tx1 = ix1: tz1 = iz1 ELSE tx1 = ix2: tz1 = iz2
        IF tz2 <= 0 THEN IF iz1 > 0 THEN tx2 = ix1: tz2 = iz1 ELSE tx2 = ix2: tz2 = iz2

        x1 = -tx1 * 16 / tz1: y1a = -50 / tz1: y1b = 50 / tz1
        x2 = -tx2 * 16 / tz2: y2a = -50 / tz2: y2b = 50 / tz2

        FOR x = x1 TO x2
            ya = y1a + (x - x1) * CLNG(y2a - y1a) / (x2 - x1)
            yb = y1b + (x - x1) * CLNG(y2b - y1b) / (x2 - x1)

            LINE (50 + x, 0)-(50 + x, 50 + -ya), 8
            LINE (50 + x, 50 + yb)-(50 + x, 140), 1

            LINE (50 + x, 50 + ya)-(50 + x, 50 + yb), 14
        NEXT
        LINE (50 + x1, 50 + y1a)-(50 + x1, 50 + y1b), 6
        LINE (50 + x2, 50 + y2a)-(50 + x2, 50 + y2b), 6
    END IF

    inputs:

    ' Wait for screen refresh and swap page
    SCREEN , , page%, 1 - page%: page% = 1 - page%
    WAIT &H3DA, &H8, &H8: WAIT &H3DA, &H8

    SELECT CASE INP(&H60)
    CASE &H48: up = 1: CASE &HC8: up = 0
    CASE &H50: up = -1: CASE &HD8: up = 0
    CASE &H4B: lt = 1: CASE &HCB: lt = 0
    CASE &H4D: lt = -1: CASE &HCD: lt = 0
    CASE &H1E: st = 1: CASE &H9E: st = 0
    CASE &H20: st = -1: CASE &HA0: st = 0
    END SELECT
    SELECT CASE INKEY$
        'CASE CHR$(0) + "H": px = px + COS(angle): py = py + SIN(angle)
        'CASE CHR$(0) + "P": px = px - COS(angle): py = py - SIN(angle)
        'CASE CHR$(0) + "K": angle = angle - .1
        'CASE CHR$(0) + "M": angle = angle + .1
        'CASE "a", "A": px = px + SIN(angle): py = py - COS(angle)
        'CASE "d", "D": px = px - SIN(angle): py = py + COS(angle)
        CASE "q", "Q", CHR$(27): EXIT DO
    END SELECT
    IF up THEN px = px + up * COS(angle) * .3: py = py + up * SIN(angle) * .3
    angle = angle - .02 * lt
    IF st THEN px = px + st * SIN(angle) * .3: py = py - st * COS(angle) * .3
LOOP

SYSTEM


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
