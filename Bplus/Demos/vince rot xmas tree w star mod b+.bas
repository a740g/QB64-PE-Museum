_TITLE "vince rot xmas tree w star mod b+" ' 2024-02-16
DIM SHARED pi, sw, sh, d, z0, p, q
pi = 4 * ATN(1)
d = 700
z0 = 2500

sw = 800
sh = 600

DIM AS DOUBLE a, b, x, y, z, xx, yy, zz, r2
SCREEN _NEWIMAGE(sw, sh, 32)
DIM AS _UNSIGNED LONG clr
'tree
COLOR , &HFF000000
CLS
FOR a = 0 TO 20 * 2 * pi STEP 0.1
    x = 5 * a * COS(a)
    y = -a * 10
    z = 5 * a * SIN(a)

    yy = (y + 350) * COS(b) - z * SIN(b)
    zz = (y + 350) * SIN(b) + z * COS(b)
    y = yy - 350
    z = zz

    xx = x * COS(b) - z * SIN(b)
    zz = x * SIN(b) + z * COS(b)
    x = xx
    z = zz

    xx = x * COS(b) - (y + 350) * SIN(b)
    yy = x * SIN(b) + (y + 350) * COS(b)
    x = xx
    y = yy - 350

    proj x, y, z
    IF a = 0 THEN PSET (p, q), _RGB(0, 155, 0) ELSE LINE -(p, q), _RGB(0, 155, 0)
    IF RND > .9 THEN
        clr = _RGB32(100 + RND * 155, (RND < .35) * -255, (RND < .35) * -255)
        FOR r2 = 0 TO 5 STEP .25
            CIRCLE (p, q), r2, clr
        NEXT
    END IF
NEXT

' star stuff
sx = 400: sy = 120
DIM SHARED top&
top& = _NEWIMAGE(64, 64, 32) ' copy tree top wo star
_PUTIMAGE , 0, top&, (sx - 32, sy - 32)-(sx + 32, sy + 32)
DIM TheStar&
TheStar& = _NEWIMAGE(64, 64, 32)
_DEST TheStar&
FOR ir = 9 TO 0 STEP -1
    star 32, 32, ir, 30, 5, 0, _RGB32(100 + (10 - ir) * 15, 200 + (10 - ir) * 5, (10 - ir) * 20)
NEXT
_DEST 0
dx = .02: dy = .1: rot = 0
xscale = 1: yscale = 1
WHILE _KEYDOWN(27) = 0
    _PUTIMAGE (sx - 32, sy - 32)-(sx + 32, sy + 32), top&, 0
    xscale = xscale + dx
    IF xscale > 1 THEN xscale = 1: dx = -dx
    IF xscale < .2 THEN xscale = .2: dx = -dx
    yscale = yscale + dy
    IF yscale > 1 THEN yscale = 1: dy = -dy
    IF yscale < .2 THEN yscale = .2: dy = -dy
    RotoZoom23r sx, sy, TheStar&, xscale, yscale, rot
    rot = rot + pi / 60
    _LIMIT 30
WEND

SUB proj (x, y, z)
    p = sw / 2 + x * d / (z + z0)
    q = sh / 2 - (100 + y) * d / (z + z0) - 150
END SUB
SUB star (x, y, rInner, rOuter, nPoints, angleOffset, K AS _UNSIGNED LONG)
    ' x, y are same as for circle,
    ' rInner is center circle radius
    ' rOuter is the outer most point of star
    ' nPoints is the number of points,
    ' angleOffset = angle offset IN DEGREES, it will be converted to radians in sub
    ' this is to allow us to spin the polygon of n sides
    DIM pAngle, radAngleOffset, x1, y1, x2, y2, x3, y3, i AS LONG

    pAngle = _D2R(360 / nPoints): radAngleOffset = _D2R(angleOffset)
    x1 = x + rInner * COS(radAngleOffset)
    y1 = y + rInner * SIN(radAngleOffset)
    FOR i = 0 TO nPoints - 1
        x2 = x + rOuter * COS(i * pAngle + radAngleOffset + .5 * pAngle)
        y2 = y + rOuter * SIN(i * pAngle + radAngleOffset + .5 * pAngle)
        x3 = x + rInner * COS((i + 1) * pAngle + radAngleOffset)
        y3 = y + rInner * SIN((i + 1) * pAngle + radAngleOffset)
        FillTriangle x1, y1, x2, y2, x3, y3, K
        'triangles leaked
        LINE (x1, y1)-(x2, y2), K
        LINE (x2, y2)-(x3, y3), K
        LINE (x3, y3)-(x1, y1), K
        x1 = x3: y1 = y3
    NEXT
    PAINT (x, y), K, K
END SUB
SUB FillTriangle (x1, y1, x2, y2, x3, y3, K AS _UNSIGNED LONG)
    $CHECKING:OFF
    STATIC a&, m AS _MEM
    IF a& = 0 THEN a& = _NEWIMAGE(1, 1, 32): m = _MEMIMAGE(a&)
    _MEMPUT m, m.OFFSET, K
    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, 0)-(0, 0), a& TO(x1, y1)-(x2, y2)-(x3, y3)
    $CHECKING:ON
END SUB
' best  rev 2023-01-20 Jarvis with Steve change for eff  might need _Seamless next to _MapTriangle calls
SUB RotoZoom23r (centerX AS LONG, centerY AS LONG, Image AS LONG, xScale AS SINGLE, yScale AS SINGLE, radRotation AS SINGLE)
    'uses radians
    DIM AS LONG W, H, Wp, Hp, i, x2, y2
    DIM sinr!, cosr!
    DIM px(3) AS SINGLE: DIM py(3) AS SINGLE
    W& = _WIDTH(Image&): H& = _HEIGHT(Image&)
    Wp& = W& / 2 * xScale
    Hp& = H& / 2 * yScale
    px(0) = -Wp&: py(0) = -Hp&: px(1) = -Wp&: py(1) = Hp&
    px(2) = Wp&: py(2) = Hp&: px(3) = Wp&: py(3) = -Hp&
    sinr! = SIN(-radRotation): cosr! = COS(radRotation)
    FOR i& = 0 TO 3
        ' x2& = (px(i&) * cosr! + sinr! * py(i&)) * xScale + centerX: y2& = (py(i&) * cosr! - px(i&) * sinr!) * yScale + centerY
        x2& = (px(i&) * cosr! + sinr! * py(i&)) + centerX: y2& = (py(i&) * cosr! - px(i&) * sinr!) + centerY
        px(i&) = x2&: py(i&) = y2&
    NEXT ' _Seamless? below
    _MAPTRIANGLE (0, 0)-(0, H& - 1)-(W& - 1, H& - 1), Image& TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2))
    _MAPTRIANGLE (0, 0)-(W& - 1, 0)-(W& - 1, H& - 1), Image& TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2))
END SUB

