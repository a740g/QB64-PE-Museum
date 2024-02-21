DIM AS LONG CircleScreen, LineScreen
$COLOR:32

SCREEN _NEWIMAGE(640, 480, 32)
_DISPLAYORDER _SOFTWARE , _HARDWARE
CircleScreen = _NEWIMAGE(640, 480, 32)
_DEST CircleScreen
FOR i = 1 TO 100
    kolor&& = _RGB32(RND * 255, RND * 255, RND * 255)
    r = RND * 100 + 50
    x = RND * _WIDTH
    y = RND * _HEIGHT
    FOR j = 1 TO r
        CIRCLE (x, y), j, kolor&&
    NEXT
NEXT
_DEST 0

LineScreen = _NEWIMAGE(640, 480, 32)
_DEST LineScreen
FOR i = 1 TO 100
    LINE (RND * _WIDTH, RND * _HEIGHT)-(RND * _WIDTH, RND * _HEIGHT), _RGB32(RND * 255, RND * 255, RND * 255), BF
NEXT
_DEST 0

DO
    CLS , DarkBlue
    Pause
    Rotate 2, Red
    Pause
    Squares 2, Silver
    Pause
    Squares 2, LineScreen
    Pause
    Circles 2, Gold
    Pause
    Circles 2, CircleScreen
    Pause
    FadeTo 2, LineScreen
    Pause
    FadeTo 2, SkyBlue
    Pause
    FadeTo 2, CircleScreen
    Pause
    Transition 4, LineScreen, 1
    Pause
    Transition 0.1, CircleScreen, 2
    Pause
    Transition 2, Pink, 3
    Pause
    Transition 2, Blue, 4
    Pause
LOOP


SUB Pause
    IF _KEYHIT THEN SYSTEM ELSE _DELAY 2: IF _KEYHIT THEN SYSTEM
END SUB


SUB Rotate (overtime AS _FLOAT, toWhat AS _INTEGER64)
    D = _DEST: S = _SOURCE
    A = _AUTODISPLAY
    tempscreen = _COPYIMAGE(_DISPLAY)
    whichScreen = _COPYIMAGE(_DISPLAY)
    IF toWhat >= 0 THEN 'it's a color
        _DEST whichScreen
        CLS , toWhat
        _DEST D
    ELSE
        _PUTIMAGE , toWhat, whichScreen
    END IF

    scale! = 1
    DO
        scale! = scale! - .01
        angle! = angle! + 3.6
        CLS , 0
        DisplayImage tempscreen, _WIDTH / 2, _HEIGHT / 2, scale!, scale!, angle!, 0
        _LIMIT 100## / overtime
        _DISPLAY
    LOOP UNTIL scale! <= 0
    scale! = 0: angle! = 0
    DO
        scale! = scale! + .01
        angle! = angle! - 3.6
        CLS , 0
        DisplayImage whichScreen, _WIDTH / 2, _HEIGHT / 2, scale!, scale!, angle!, 0
        _LIMIT 100## / overtime
        _DISPLAY
    LOOP UNTIL scale! >= 1
    _DEST D: _SOURCE S
    IF A THEN _AUTODISPLAY
    _PUTIMAGE , whichScreen, _DISPLAY
    _FREEIMAGE whichScreen
END SUB


SUB Squares (overTime AS _FLOAT, toWhat AS _INTEGER64)
    STATIC P(100) AS LONG
    IF P(0) = 0 AND P(1) = 0 THEN 'initialize our static array on the first run
        FOR i = 0 TO 100: P(i) = i: NEXT
    END IF
    D = _DEST: S = _SOURCE
    A = _AUTODISPLAY
    whichScreen = _COPYIMAGE(_DISPLAY)
    IF toWhat >= 0 THEN 'it's a color
        _DEST whichScreen
        CLS , toWhat
        _DEST D
    ELSE
        _PUTIMAGE , toWhat, whichScreen
    END IF

    FOR i = 0 TO 100: SWAP P(i), P(RND * 100): NEXT 'shuffle our restore order
    w = _WIDTH / 10
    h = _HEIGHT / 10
    FOR i = 0 TO 100
        x = P(i) \ 10
        y = P(i) MOD 10
        _PUTIMAGE (x * w, y * h)-STEP(w, h), whichScreen, _DISPLAY, (x * w, y * h)-STEP(w, h)
        _LIMIT 100## / overTime
        _DISPLAY
    NEXT

    _DEST D: _SOURCE S
    IF A THEN _AUTODISPLAY
    _PUTIMAGE , whichScreen, _DISPLAY
    _FREEIMAGE whichScreen
END SUB


SUB Circles (overTime AS _FLOAT, toWhat AS _INTEGER64)
    DIM AS _MEM M, M2, M3
    DIM AS _OFFSET count
    DIM AS _UNSIGNED LONG KolorPoint
    D = _DEST: S = _SOURCE
    A = _AUTODISPLAY: B = _BLEND
    tempScreen = _COPYIMAGE(_DISPLAY)
    whichScreen = _COPYIMAGE(_DISPLAY)
    tempCircleScreen = _COPYIMAGE(_DISPLAY)
    IF toWhat >= 0 THEN 'it's a color
        _DEST whichScreen
        CLS , toWhat
        _DEST D
    ELSE
        _PUTIMAGE , toWhat, whichScreen
    END IF
    M = _MEMIMAGE(tempCircleScreen)
    M2 = _MEMIMAGE(whichScreen)
    M3 = _MEMIMAGE(_DISPLAY)

    _DEST tempCircleScreen: _SOURCE tempCircleScreen
    _DONTBLEND
    FOR i = 1 TO 1000
        _PUTIMAGE , tempScreen, _DISPLAY
        CircleFill RND * _WIDTH, RND * _HEIGHT, _WIDTH / 20, &H12345678&&
        count = 0
        $CHECKING:OFF
        DO
            _MEMGET M, M.OFFSET + count, KolorPoint
            IF KolorPoint = &H12345678&& THEN
                _MEMGET M2, M2.OFFSET + count, KolorPoint
                _MEMPUT M3, M3.OFFSET + count, KolorPoint
            END IF
            count = count + 4
        LOOP UNTIL count >= M.SIZE
        _LIMIT 1000## / overTime
        $CHECKING:ON
        _DISPLAY
    NEXT

    _DEST D: _SOURCE S
    IF A THEN _AUTODISPLAY
    IF B THEN _BLEND
    _PUTIMAGE , whichScreen, _DISPLAY
    _FREEIMAGE tempScreen: _FREEIMAGE whichScreen: _FREEIMAGE tempCircleScreen
END SUB


SUB FadeTo (overTime AS _FLOAT, toWhat AS _INTEGER64)
    D = _DEST: S = _SOURCE
    A = _AUTODISPLAY

    FOR i = 0 TO 255
        tempScreen = _COPYIMAGE(_DISPLAY)
        _DEST tempScreen
        IF toWhat >= 0 THEN
            r = _RED32(toWhat)
            g = _GREEN32(toWhat)
            b = _BLUE32(toWhat)
            alpha = _ALPHA32(toWhat) / 255 * i
            CLS , _RGBA32(r, g, b, alpha)
        ELSE
            _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), toWhat, tempScreen
            _SETALPHA i
        END IF
        tempHardwareScreen = _COPYIMAGE(tempScreen, 33)
        _PUTIMAGE , tempHardwareScreen
        _DISPLAY
        _LIMIT 255## / overTime
        _FREEIMAGE tempHardwareScreen
        _FREEIMAGE tempScreen
    NEXT
    _DEST D: _SOURCE S
    IF toWhat > 0 THEN
        LINE (0, 0)-(_WIDTH, _HEIGHT), toWhat, BF
    ELSE
        _PUTIMAGE , toWhat, _DISPLAY
    END IF
    IF A THEN _AUTODISPLAY
END SUB


SUB Transition (overTime AS _FLOAT, toWhat AS _INTEGER64, Direction AS LONG)
    'Direction is: 1 = Left, 2 = Right, 3 = Up, 4 = Down
    IF Direction < 1 OR Direction > 4 THEN EXIT SUB
    D = _DEST: S = _SOURCE
    A = _AUTODISPLAY
    tempScreen = _COPYIMAGE(_DISPLAY)
    whichScreen = _COPYIMAGE(_DISPLAY)
    IF toWhat >= 0 THEN 'it's a color
        _DEST whichScreen
        CLS , toWhat
        _DEST D
    ELSE
        _PUTIMAGE , toWhat, whichScreen
    END IF
    SELECT CASE Direction
        CASE 1
            FOR x = _WIDTH TO 0 STEP -1
                CLS , 0
                _PUTIMAGE (0, 0)-(x, _HEIGHT), tempScreen, _DISPLAY, (_WIDTH - x, 0)-(_WIDTH, _HEIGHT)
                _PUTIMAGE (x, 0)-(_WIDTH, _HEIGHT), whichScreen, _DISPLAY, (0, 0)-(_WIDTH - x, _HEIGHT)
                _LIMIT _WIDTH / overTime
                _DISPLAY
            NEXT
        CASE 2
            FOR x = 0 TO _WIDTH
                CLS , 0
                _PUTIMAGE (x, 0)-(_WIDTH, _HEIGHT), tempScreen, _DISPLAY, (0, 0)-(_WIDTH - x, _HEIGHT)
                _PUTIMAGE (0, 0)-(x, _HEIGHT), whichScreen, _DISPLAY, (_WIDTH - x, 0)-(_WIDTH, _HEIGHT)
                _LIMIT _WIDTH / overTime
                _DISPLAY
            NEXT
        CASE 3
            FOR y = _HEIGHT TO 0 STEP -1
                CLS , 0
                _PUTIMAGE (0, y)-(_WIDTH, _HEIGHT), whichScreen, _DISPLAY, (0, 0)-(_WIDTH, _HEIGHT - y)
                _PUTIMAGE (0, 0)-(_WIDTH, y), tempScreen, _DISPLAY, (0, _HEIGHT - y)-(_WIDTH, _HEIGHT)
                _LIMIT _HEIGHT / overTime
                _DISPLAY
            NEXT
        CASE 4
            FOR y = 0 TO _HEIGHT
                CLS , 0
                _PUTIMAGE (0, y)-(_WIDTH, _HEIGHT), tempScreen, _DISPLAY, (0, 0)-(_WIDTH, _HEIGHT - y)
                _PUTIMAGE (0, 0)-(_WIDTH, y), whichScreen, _DISPLAY, (0, _HEIGHT - y)-(_WIDTH, _HEIGHT)
                _LIMIT _HEIGHT / overTime
                _DISPLAY
            NEXT

    END SELECT
    _DEST D: _SOURCE S
    IF A THEN _AUTODISPLAY
    _FREEIMAGE tempScreen
    _FREEIMAGE whichScreen
END SUB


SUB CircleFill (CX AS LONG, CY AS LONG, R AS LONG, C AS LONG)
    DIM Radius AS LONG, RadiusError AS LONG
    DIM X AS LONG, Y AS LONG

    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0

    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), C, BF

    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    WEND

END SUB


SUB DisplayImage (Image AS LONG, x AS INTEGER, y AS INTEGER, xscale AS SINGLE, yscale AS SINGLE, angle AS SINGLE, mode AS _BYTE)
    'Image is the image handle which we use to reference our image.
    'x,y is the X/Y coordinates where we want the image to be at on the screen.
    'angle is the angle which we wish to rotate the image.
    'mode determines HOW we place the image at point X,Y.
    'Mode 0 we center the image at point X,Y
    'Mode 1 we place the Top Left corner of oour image at point X,Y
    'Mode 2 is Bottom Left
    'Mode 3 is Top Right
    'Mode 4 is Bottom Right


    DIM px(3) AS INTEGER, py(3) AS INTEGER, w AS INTEGER, h AS INTEGER
    DIM sinr AS SINGLE, cosr AS SINGLE, i AS _BYTE
    w = _WIDTH(Image): h = _HEIGHT(Image)
    SELECT CASE mode
        CASE 0 'center
            px(0) = -w \ 2: py(0) = -h \ 2: px(3) = w \ 2: py(3) = -h \ 2
            px(1) = -w \ 2: py(1) = h \ 2: px(2) = w \ 2: py(2) = h \ 2
        CASE 1 'top left
            px(0) = 0: py(0) = 0: px(3) = w: py(3) = 0
            px(1) = 0: py(1) = h: px(2) = w: py(2) = h
        CASE 2 'bottom left
            px(0) = 0: py(0) = -h: px(3) = w: py(3) = -h
            px(1) = 0: py(1) = 0: px(2) = w: py(2) = 0
        CASE 3 'top right
            px(0) = -w: py(0) = 0: px(3) = 0: py(3) = 0
            px(1) = -w: py(1) = h: px(2) = 0: py(2) = h
        CASE 4 'bottom right
            px(0) = -w: py(0) = -h: px(3) = 0: py(3) = -h
            px(1) = -w: py(1) = 0: px(2) = 0: py(2) = 0
    END SELECT
    sinr = SIN(angle / 57.2957795131): cosr = COS(angle / 57.2957795131)
    FOR i = 0 TO 3
        x2 = xscale * (px(i) * cosr + sinr * py(i)) + x: y2 = yscale * (py(i) * cosr - px(i) * sinr) + y
        px(i) = x2: py(i) = y2
    NEXT
    _MAPTRIANGLE (0, 0)-(0, h - 1)-(w - 1, h - 1), Image TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2))
    _MAPTRIANGLE (0, 0)-(w - 1, 0)-(w - 1, h - 1), Image TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2))
END SUB
