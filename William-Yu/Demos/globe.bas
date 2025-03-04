'{A little rotating sphere, by Glen Jeh, 8/12/1994, use freely}
'{Try messing with the constants...code is squished a little}
' Converted to BASIC by William Yu (05-28-96)
'
' Uncomment the delay if you compile the program
' The screen updates too fast

DEFLNG A-Z
OPTION _EXPLICIT

CONST Scale = 50 ' x and y are multiplied by scale and divided by distance
CONST Radius = 80 ' mystery constant
CONST DelayTime = 1 ' Delay(DelayTime) to slow it down..
CONST Slices = 12 ' number of slices
CONST PPS = 20 ' points per slice

TYPE PointType
    x AS INTEGER
    y AS INTEGER
    Z AS INTEGER
END TYPE

DIM SHARED points(1 TO Slices, 1 TO PPS) AS PointType
DIM SHARED Ball(1 TO Slices, 1 TO PPS) AS PointType
DIM SHARED XAngle, YAngle, ZAngle
DIM SHARED SinTable(0 TO 255) AS INTEGER
DIM SHARED CosTable(0 TO 255) AS INTEGER
DIM SHARED Distance, Dir

DIM AS LONG i

FOR i = 0 TO 255
    SinTable(i) = INT(SIN(2 * _PI / 255 * i) * 128)
    CosTable(i) = INT(COS(2 * _PI / 255 * i) * 128)
NEXT

RANDOMIZE TIMER

$RESIZE:SMOOTH
SCREEN 7
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

i = 0
Distance = 100
Dir = -3
SetupBall
XAngle = 0
YAngle = 0
ZAngle = 0
DO
    i = 1 - i
    PCOPY 3, 2
    SCREEN , , 2, 0
    Rotate
    DrawPoints 14 + i
    XAngle = XAngle + 3
    YAngle = YAngle + 2
    ZAngle = ZAngle + 1
    Distance = Distance + Dir
    IF XAngle > 250 THEN XAngle = 0
    IF YAngle > 250 THEN YAngle = 0
    IF ZAngle > 250 THEN ZAngle = 0
    IF Distance >= 300 THEN Dir = -3
    IF Distance <= 30 THEN Dir = 2
    PCOPY 2, 0
    SCREEN , , 2, 0
    _LIMIT 60
LOOP UNTIL INKEY$ <> ""

SYSTEM 0

'{mystery procedure}
SUB DrawPoints (Colour)
    DIM AS LONG i, i2
    FOR i = 1 TO Slices
        FOR i2 = 1 TO PPS
            IF (points(i, i2).Z >= 0) AND (points(i, i2).x <= 319) AND (points(i, i2).x >= 0) AND (points(i, i2).y >= 0) AND (points(i, i2).y < 199) THEN
                PSET (points(i, i2).x, points(i, i2).y), Colour
            END IF
        NEXT i2
    NEXT i
END SUB

SUB Rotate
    'UPDATES all (X,Y,Z) coordinates according to XAngle,YAngle,ZAngle
    DIM AS LONG i, i2, TempY, TempZ, TempX, OldTempX
    FOR i = 1 TO Slices
        FOR i2 = 1 TO PPS
            '{rotate on X-axis}
            TempY = (Ball(i, i2).y * CosTable(XAngle) - Ball(i, i2).Z * SinTable(XAngle)) / 128
            TempZ = (Ball(i, i2).y * SinTable(XAngle) + Ball(i, i2).Z * CosTable(XAngle)) / 128
            ' {rotate on y-anis}
            TempX = (Ball(i, i2).x * CosTable(YAngle) - TempZ * SinTable(YAngle)) / 128
            TempZ = (Ball(i, i2).x * SinTable(YAngle) + TempZ * CosTable(YAngle)) / 128
            '{rotate on z-axis}
            OldTempX = TempX
            TempX = (TempX * CosTable(ZAngle) - TempY * SinTable(ZAngle)) / 128
            TempY = (OldTempX * SinTable(ZAngle) + TempY * CosTable(ZAngle)) / 128
            points(i, i2).x = (TempX * Scale) / Distance + 320 / 2
            points(i, i2).y = (TempY * Scale) / Distance + 200 / 2
            points(i, i2).Z = TempZ
        NEXT i2
    NEXT i
END SUB

'{sets up the ball's data..}
SUB SetupBall ' {set up the points}
    DIM AS LONG SliceLoop, PPSLoop
    DIM AS SINGLE Phi, Theta

    FOR SliceLoop = 1 TO Slices
        Phi! = _PI / Slices * SliceLoop ' 0 <= Phi <= Pi
        FOR PPSLoop = 1 TO PPS
            Theta! = 2 * _PI / PPS * PPSLoop ' 0 <= Theta <= 2*Pi
            '{convert Radius,Thetha,Phi to (x,y,z) coordinates}
            Ball(SliceLoop, PPSLoop).y = INT(Radius * SIN(Phi!) * COS(Theta!))
            Ball(SliceLoop, PPSLoop).x = INT(Radius * SIN(Phi!) * SIN(Theta!))
            Ball(SliceLoop, PPSLoop).Z = INT(Radius * COS(Phi!))
        NEXT PPSLoop
    NEXT SliceLoop
END SUB
