' Easy spiral
SCREEN _NEWIMAGE(700, 700, 32)
'_ScreenMove 300, 100
DIM tick, s, c, h, x, y, lastX, lastY
'pi = 3.14159265
s = 7
DO
    CLS
    FOR c = 1 TO 2000
        h = c + tick
        x = SIN(6 * h / _PI) + SIN(3 * h)
        h = c + tick * 2
        y = COS(6 * h / _PI) + COS(3 * h)
        fcirc s * (20 * x + 50), s * (20 * y + 50), 2, _RGB32(255, 255, 255)
    NEXT
    _DISPLAY
    _LIMIT 120
    tick = tick + .001
LOOP

SUB fcirc (CX AS LONG, CY AS LONG, R AS LONG, C AS _UNSIGNED LONG) '      SMcNeill's fill circle
    DIM subRadius AS LONG, RadiusError AS LONG, X AS LONG, Y AS LONG
    subRadius = ABS(R): RadiusError = -subRadius: X = subRadius: Y = 0
    IF subRadius = 0 THEN PSET (CX, CY): EXIT SUB
    LINE (CX - X, CY)-(CX + X, CY), C, BF
    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C
    WEND
END SUB
