_TITLE "Psychedelic Star Swirl bplus 2018-03-04"
' translated from
' Psychedelic Star Swirl.bas SmallBASIC 0.12.8 [B+=MGA] 2017-03-03
' Spiral Pearl Swirl 4 SB.bas  SmallBASIC 0.12.8 [B+=MGA] 2017-03-01
' from Spiral Pearl Swirl.bas for FreeBASIC [B+=MGA] 2017-02-28
' from SdlBasic 3d version 2017-02-28
' inspired by spiral Bang
CONST xmax = 1200
CONST ymax = 760
SCREEN _NEWIMAGE(xmax, ymax, 32)
_SCREENMOVE 70, 0

DIM SHARED r, g, b, clr
'whatever screen size your device here is middle
cx = xmax / 2: cy = ymax / 2: r = RND: g = RND: b = RND: k$ = " "
WHILE 1
    size = 1
    radius = .06
    angle = sangle
    CLS
    WHILE radius < 800
        x = COS(angle) * radius
        y = SIN(angle) * radius
        r2 = (x ^ 2 + y ^ 2) ^ .5
        size = 4 * r2 ^ .25
        FOR r = size TO 1 STEP -4
            'cc = 160 + 95 * radius/400 - r/size*120
            chColor
            star cx + x, cy + y, r / 3, r * 1.6, 5, RND * 360
        NEXT
        angle = angle - .4
        radius = radius + 1
    WEND
    _DISPLAY ' update screen with new image
    _LIMIT 15 '<<<<<<<<<<<<<<<<<<<<<<<<<< adjust to higher speeds if you dare
    sangle = sangle + _PI(1 / 18)
WEND

SUB star (x, y, rInner, rOuter, nPoints, angleOffset)
    ' x, y are same as for circle,
    ' rInner is center circle radius
    ' rOuter is the outer most point of star
    ' nPoints is the number of points,
    ' angleOffset = angle offset IN DEGREES, it will be converted to radians in sub
    ' this is to allow us to spin the polygon of n sides
    pAngle = RAD(360 / nPoints): radAngleOffset = RAD(angleOffset)
    x1 = x + rInner * COS(radAngleOffset)
    y1 = y + rInner * SIN(radAngleOffset)
    FOR i = 0 TO nPoints - 1
        x2 = x + rOuter * COS(i * pAngle + radAngleOffset + .5 * pAngle)
        y2 = y + rOuter * SIN(i * pAngle + radAngleOffset + .5 * pAngle)
        x3 = x + rInner * COS((i + 1) * pAngle + radAngleOffset)
        y3 = y + rInner * SIN((i + 1) * pAngle + radAngleOffset)
        LINE (x1, y1)-(x2, y2)
        LINE (x2, y2)-(x3, y3)
        x1 = x3: y1 = y3
    NEXT
END SUB

SUB chColor ()
    clr = clr + 1
    COLOR _RGB32(127 + 127 * SIN(r * clr), 127 + 127 * SIN(g * clr), 127 + 127 * SIN(b * clr))
    IF clr > 100000 THEN r = RND * RND: g = RND * RND: b = RND * RND: clr = 0
END SUB
FUNCTION RAD (dA)
    RAD = _PI(dA / 180)
END FUNCTION
