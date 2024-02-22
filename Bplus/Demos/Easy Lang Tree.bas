'_Title "Easy Lang Tree, sorta" 'b+ 2022-03-17
SCREEN _NEWIMAGE(500, 500, 32)
COLOR , &HFFFFFFFF
CLS
tree 240, 475, -90, 11
SLEEP

SUB tree (x, y, angle, depth)
    DIM x1, y1, linewidth
    linewidth = depth * .8
    'move x y
    x1 = x + COS(_D2R(angle)) * 8 * depth * 1.4 * RND + 0.5
    y1 = y + SIN(_D2R(angle)) * 8 * depth * 1.4 * RND + 0.5
    tLine x, y, x1, y1, linewidth
    IF depth > 1 THEN
        tree x1, y1, angle - 20, depth - 1
        tree x1, y1, angle + 20, depth - 1
    END IF
END SUB

SUB tLine (x1, y1, x2, y2, rThick)
    DIM stepx, stepy, lengthh, i
    'x1, y1 is one endpoint of line
    'x2, y2 is the other endpoint of the line
    'rThick is the radius of the tiny circles that will be drawn
    '  from one end point to the other to create the thick line
    'Yes, the line will then extend beyond the endpoints with circular ends.

    rThick = INT(rThick / 2): stepx = x2 - x1: stepy = y2 - y1
    lengthh = INT((stepx ^ 2 + stepy ^ 2) ^ .5)
    IF lengthh THEN
        dx = stepx / lengthh: dy = stepy / lengthh
        FOR i = 0 TO lengthh
            fcirc x1 + dx * i, y1 + dy * i, rThick, &HFF884422
        NEXT
    ELSE
        fcirc x1, y1, rThick, &HFF884422
    END IF
END SUB

SUB fcirc (CX AS LONG, CY AS LONG, R AS LONG, C AS _UNSIGNED LONG)
    DIM Radius AS LONG, RadiusError AS LONG
    DIM X AS LONG, Y AS LONG
    Radius = ABS(R): RadiusError = -Radius: X = Radius: Y = 0
    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB
    LINE (CX - X, CY)-(CX + X, CY), C
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
End Sub
