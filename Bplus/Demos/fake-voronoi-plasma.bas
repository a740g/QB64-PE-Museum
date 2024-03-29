OPTION _EXPLICIT
_TITLE "Real Plasma and Voronoi, press key for new scheme" '2023-10-19  b+ overhaul of
'fake-voronoi-plasma.bas Dav, OCT/2023

SCREEN _NEWIMAGE(600, 600, 32)

RANDOMIZE TIMER

' cap all shared variables
DIM SHARED AS LONG CX, CY, Radius
' modified by Setup
DIM SHARED AS SINGLE Rd, Gn, Bl ' plasma colorsfor RGB
DIM SHARED AS LONG NP ' voronoi pt count mod in setup
DIM SHARED AS SINGLE Angle ' mod in setup
DIM SHARED AS LONG Direction ' mod random turning clockwise or counter

' local
DIM AS LONG x, y ' from screen
REDIM AS SINGLE px(1 TO NP), py(1 TO NP) ' voronoi points hopefully a spinning polygon
DIM AS SINGLE px, py, d, dist ' Voronoi calcs point and distance
DIM AS SINGLE da ' is polygon animating index
DIM AS LONG i, t ' indexes i a regular one and t for plasma color
DIM k$ ' polling keypresses
DIM c AS _UNSIGNED LONG ' plasma color line is soooooo long! save it in c container

'once and for all time
CX = _WIDTH / 2: CY = _HEIGHT / 2: Radius = _HEIGHT / 3

Setup
DO
    FOR y = 0 TO _HEIGHT - 1 STEP 4
        FOR x = 0 TO _WIDTH - 1 STEP 4
            d = 100000 ' too big!
            FOR i = 1 TO NP
                px = CX + Radius * COS(i * Angle + da)
                py = CY + Radius * SIN(i * Angle + da)
                dist = SQR(((x - px) ^ 2) + ((y - py) ^ 2))
                IF dist < d THEN d = dist
            NEXT
            d = d + t
            c = _RGB32(127 + 127 * SIN(Rd * d), 127 + 127 * SIN(Gn * d), 127 + 127 * SIN(Bl * d))
            FCirc x, y, 3, c
        NEXT
    NEXT

    'animate!
    t = t + 2: da = da + _PI(2 / 90) * Direction
    k$ = INKEY$
    IF LEN(k$) THEN
        IF ASC(k$) = 27 THEN
            END
        ELSE 'reset plasma
            Setup: t = 0
        END IF
    END IF
    _DISPLAY
    _LIMIT 30 'ha!
LOOP UNTIL INKEY$ = CHR$(27)

SUB Setup ' reset shared
    'setup plasma for RGB color
    Rd = RND * RND: Gn = RND * RND: Bl = RND * RND

    'setup voronoi variables for calcs
    NP = INT(RND * 10) + 3 ' 9 + 3 max    number of poly points
    Angle = _PI(2 / NP) ' angle between
    Direction = 2 * INT(RND * 2) - 1 ' turn clockwise or the other wise
END SUB

' this sub for circle fill so can use code in QBJS wo mod
SUB FCirc (CX AS LONG, CY AS LONG, R AS LONG, C AS _UNSIGNED LONG)
    $IF WEB THEN
        G2D.FillCircle CX, CY, R, C
    $ELSE
        DIM Radius AS LONG, RadiusError AS LONG
        DIM X AS LONG, Y AS LONG
        Radius = ABS(R): RadiusError = -Radius: X = Radius: Y = 0
        IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB
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
    $END IF
END SUB
