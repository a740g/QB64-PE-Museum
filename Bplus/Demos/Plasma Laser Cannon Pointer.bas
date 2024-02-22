OPTION _EXPLICIT
'_Title "Plasma Laser Cannon Pointer" ' for QBJS b+ 2023-09-21
' start mod from Plasma Laser Canon demo prep for GUI 2020-11-11

SCREEN _NEWIMAGE(1200, 600, 32)
RANDOMIZE TIMER
SCREEN _NEWIMAGE(_RESIZEWIDTH - 5, _RESIZEHEIGHT - 5, 32)
DIM SHARED AS LONG ShipLights
DIM SHARED AS _UNSIGNED LONG ShipColor
DIM AS LONG cx, cy, mx, my, mb, sx, sy
DIM AS SINGLE ma, md, dx, dy
cy = _HEIGHT / 2: cx = _WIDTH / 2
ShipColor = &HFF3366AA
'  _MouseHide '??? not supported and bad idea anyway
DO
    CLS
    WHILE _MOUSEINPUT: WEND
    mx = _MOUSEX: my = _MOUSEY: mb = _MOUSEBUTTON(1)
    dx = mx - cx ' ship avoids collision with mouse
    dy = my - cy
    ma = _ATAN2(dy, dx)
    md = SQR(dy * dy + dx * dx)
    IF md < 80 THEN md = 80
    sx = cx + md * COS(ma + 3.1415)
    sy = cy + md * SIN(ma + 3.1415)
    drawShip sx, sy, ShipColor
    IF mb THEN
        PLC sx, sy, mx, my, 10 ' Fire!
        ShipColor = _RGB32(INT(RND * 256), INT(RND * 136) + 120, INT(RND * 156) + 100)
    END IF
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27)

SUB PLC (baseX, baseY, targetX, targetY, targetR) ' PLC for PlasmaLaserCannon
    DIM r, g, b, hp, ta, dist, dr, x, y, c, rr
    r = RND ^ 2 * RND: g = RND ^ 2 * RND: b = RND ^ 2 * RND: hp = _PI(.5) ' red, green, blue, half pi
    ta = _ATAN2(targetY - baseY, targetX - baseX) ' angle of target to cannon base
    dist = _HYPOT(targetY - baseY, targetX - baseX) ' distance cannon to target
    dr = targetR / dist
    FOR r = 0 TO dist STEP .25
        x = baseX + r * COS(ta)
        y = baseY + r * SIN(ta)
        c = c + .3
        COLOR _RGB32(128 + 127 * SIN(r * c), 128 + 127 * SIN(g * c), 128 + 127 * SIN(b * c))
        fcirc x, y, dr * r
    NEXT
    FOR rr = dr * r TO 0 STEP -.5
        c = c + 1
        COLOR _RGB32(128 + 127 * SIN(r * c), 128 + 127 * SIN(g * c), 128 + 127 * SIN(b * c))
        fcirc x, y, rr
    NEXT
END SUB

SUB drawShip (x, y, colr AS _UNSIGNED LONG) 'shipType     collisions same as circle x, y radius = 30
    ' shared here ShipLights

    DIM light AS LONG, r AS LONG, g AS LONG, b AS LONG
    r = _RED32(colr): g = _GREEN32(colr): b = _BLUE32(colr)
    COLOR _RGB32(r, g - 120, b - 100)
    fEllipse x, y, 6, 15
    COLOR _RGB32(r, g - 60, b - 50)
    fEllipse x, y, 18, 11
    COLOR _RGB32(r, g, b)
    fEllipse x, y, 30, 7
    FOR light = 0 TO 5
        COLOR _RGB32(ShipLights * 50, ShipLights * 50, ShipLights * 50)
        fcirc x - 30 + 11 * light + ShipLights, y, 1
    NEXT
    ShipLights = ShipLights + 1
    IF ShipLights > 5 THEN ShipLights = 0
END SUB

' these do work in QBJS without mod see le bombe
SUB fcirc (CX AS LONG, CY AS LONG, R AS LONG)
    DIM subRadius AS LONG, RadiusError AS LONG
    DIM X AS LONG, Y AS LONG

    subRadius = ABS(R)
    RadiusError = -subRadius
    X = subRadius
    Y = 0

    IF subRadius = 0 THEN PSET (CX, CY): EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), , BF

    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), , BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), , BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), , BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), , BF
    WEND
END SUB

SUB fEllipse (CX AS LONG, CY AS LONG, xRadius AS LONG, yRadius AS LONG)
    DIM scale AS SINGLE, x AS LONG, y AS LONG
    scale = yRadius / xRadius
    LINE (CX, CY - yRadius)-(CX, CY + yRadius), , BF
    FOR x = 1 TO xRadius
        y = scale * SQR(xRadius * xRadius - x * x)
        LINE (CX + x, CY - y)-(CX + x, CY + y), , BF
        LINE (CX - x, CY - y)-(CX - x, CY + y), , BF
    NEXT
END SUB
