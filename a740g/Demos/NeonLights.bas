' =========================================================================
' Neon Lights
' Ported from a Haiku C++ screensaver to QB64-PE by a740g
' Original Author: Adrien Destugues (MIT License)
' https://github.com/pulkomandy/neonlights
' =========================================================================

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32

CONST SCREEN_WIDTH = 1024
CONST SCREEN_HEIGHT = 768
CONST PARTICLES = 3000
CONST CITIES = 64
CONST SPOTS = 22 ' must be <= CITIES

TYPE City
    x AS SINGLE
    y AS SINGLE
    oldX AS SINGLE
    oldY AS SINGLE
    vx AS SINGLE
    vy AS SINGLE
    other AS LONG
    r AS LONG
    g AS LONG
    b AS LONG
END TYPE

DIM SHARED cities(0 TO CITIES - 1) AS City
DIM SHARED goodColor(0 TO 5) AS _UNSIGNED LONG
goodColor(0) = Blue
goodColor(1) = Cyan
goodColor(2) = Magenta
goodColor(3) = Green
goodColor(4) = Red
goodColor(5) = Yellow

SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, 32)
_TITLE "Neon Lights"

RANDOMIZE TIMER

DIM frame AS LONG

DO
    IF (frame AND 1023) = 0 THEN
        Restart
    END IF

    DIM a AS LONG, b AS LONG, tr AS LONG
    DIM t AS SINGLE, dx AS SINGLE, dy AS SINGLE

    DIM n AS LONG
    WHILE n < PARTICLES
        a = INT(RND * SPOTS)
        tr = 0
        DO
            b = INT(RND * SPOTS)
            tr = tr + 1
        LOOP WHILE tr < 100 _ANDALSO CityDistance(a, b) < (SCREEN_WIDTH * SCREEN_HEIGHT) / (10 * (SCREEN_WIDTH + SCREEN_HEIGHT))

        IF tr < 100 THEN
            t = _PI(RND)

            dx = SIN(t) * (cities(b).x - cities(a).x) + cities(a).x
            dy = SIN(t) * (cities(b).y - cities(a).y) + cities(a).y

            dx = dx + (RND * 3!) - 1.5!
            dy = dy + (RND * 3!) - 1.5!

            DIM mixedR AS LONG: mixedR = (cities(a).r + cities(b).r) \ 2
            DIM mixedG AS LONG: mixedG = (cities(a).g + cities(b).g) \ 2
            DIM mixedB AS LONG: mixedB = (cities(a).b + cities(b).b) \ 2

            PSET (dx, dy), _RGB32(mixedR, mixedG, mixedB, 32)
        END IF

        n = n + 1
    WEND
    n = 0

    DIM c AS LONG
    WHILE c < SPOTS
        cities(c).vx = cities(c).vx + (cities(cities(c).other).x - cities(c).x) / SCREEN_WIDTH
        cities(c).vy = cities(c).vy + (cities(cities(c).other).y - cities(c).y) / SCREEN_HEIGHT

        cities(c).vx = cities(c).vx * 0.986!
        cities(c).vy = cities(c).vy * 0.979!

        IF RND < 0.01! THEN
            cities(c).other = INT(RND * SPOTS)
        END IF

        cities(c).x = cities(c).x + cities(c).vx
        cities(c).y = cities(c).y + cities(c).vy

        LINE (cities(c).oldX, cities(c).oldY)-(cities(c).x, cities(c).y), White

        cities(c).oldX = cities(c).x
        cities(c).oldY = cities(c).y

        c = c + 1
    WEND
    c = 0

    _DISPLAY
    _LIMIT 60

    frame = frame + 1
LOOP UNTIL _KEYHIT = _KEY_ESC

SYSTEM

SUB Restart
    CLS

    DIM tinc AS SINGLE: tinc = _PI(2! / SPOTS)

    DIM i AS LONG
    WHILE i < SPOTS
        cities(i).x = SCREEN_WIDTH \ 2
        cities(i).y = SCREEN_HEIGHT \ 2
        cities(i).oldX = cities(i).x
        cities(i).oldY = cities(i).y

        cities(i).vx = (1! + INT(RND * 11!)) * SIN(tinc * i)
        cities(i).vy = (1! + INT(RND * 11!)) * COS(tinc * i)

        DIM cIdx AS LONG: cIdx = INT(RND * 6!)
        cities(i).r = _RED32(goodColor(cIdx))
        cities(i).g = _GREEN32(goodColor(cIdx))
        cities(i).b = _BLUE32(goodColor(cIdx))

        DO
            cities(i).other = INT(RND * SPOTS)
        LOOP WHILE cities(i).other = i

        i = i + 1
    WEND
END SUB

FUNCTION CityDistance! (a AS LONG, b AS LONG)
    IF a <> b THEN
        DIM dx AS SINGLE: dx = cities(b).x - cities(a).x
        DIM dy AS SINGLE: dy = cities(b).y - cities(a).y
        CityDistance = SQR(dx * dx + dy * dy)
    END IF
END FUNCTION
