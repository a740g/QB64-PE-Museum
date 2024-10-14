DEFLNG A-Z
OPTION _EXPLICIT

TYPE vector
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Particle
    pos AS vector
    vel AS vector
    fade AS SINGLE
    active AS _BYTE
    b AS SINGLE
END TYPE

TYPE rocket
    x AS SINGLE
    y AS SINGLE
    xs AS SINGLE
    ys AS SINGLE
    dead AS _BYTE
END TYPE

CONST MaxExplosion = 60

DIM rockets(5) AS rocket
DIM particles(UBOUND(rockets) * MaxExplosion * 100) AS Particle
DIM AS LONG i, n, v, k

RANDOMIZE TIMER

$RESIZE:SMOOTH
SCREEN _NEWIMAGE(1280, 800, 32)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

FOR i = 1 TO UBOUND(particles)
    particles(i).vel.x = RND * 2
    particles(i).vel.y = RND * 2
    particles(i).fade = RND * 3 + 1
    particles(i).b = 255
    IF RND * 2 > 1 THEN particles(i).vel.x = -particles(i).vel.x
    IF RND * 2 > 1 THEN particles(i).vel.y = -particles(i).vel.y
NEXT

FOR i = 1 TO UBOUND(rockets)
    rockets(i).y = _HEIGHT
    rockets(i).x = RND * _WIDTH
    rockets(i).dead = -1
    rockets(i).xs = RND * 4
    rockets(i).ys = RND * 4
NEXT

DO WHILE _KEYHIT <> 27
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, 50), BF

    FOR i = 1 TO UBOUND(rockets)
        IF rockets(i).dead THEN

            rockets(i).dead = 0
            rockets(i).x = RND * _WIDTH
            rockets(i).y = _HEIGHT
            rockets(i).xs = RND * 4
            rockets(i).ys = RND * 4
        ELSE
            n = 0
            WHILE n < MaxExplosion
                v = v + 1
                IF v > UBOUND(particles) THEN v = 0: EXIT WHILE
                IF NOT particles(v).active THEN particles(v).pos.x = rockets(i).x: particles(v).pos.y = rockets(i).y: particles(v).active = -1: n = n + 1
            WEND
            rockets(i).x = rockets(i).x + rockets(i).xs
            rockets(i).y = rockets(i).y - rockets(i).ys
            rockets(i).ys = rockets(i).ys + .1
            rockets(i).xs = rockets(i).xs - .05
            PSET (rockets(i).x, rockets(i).y)
            IF rockets(i).y < 0 THEN rockets(i).dead = -1: k = k + 1
        END IF
    NEXT
    FOR i = 1 TO UBOUND(particles)
        IF particles(i).active THEN
            PSET (particles(i).pos.x, particles(i).pos.y), _RGB(particles(i).b, particles(i).b, 0)
            particles(i).pos.x = particles(i).pos.x + particles(i).vel.x
            particles(i).pos.y = particles(i).pos.y + particles(i).vel.y
            particles(i).vel.y = particles(i).vel.y + .05
            IF particles(i).b > 0 THEN particles(i).b = particles(i).b - particles(i).fade
        END IF
        IF particles(i).b < 0 THEN
            particles(i).active = 0
            particles(i).vel.x = RND * 2
            particles(i).vel.y = RND * 2
            particles(i).b = 255
            IF RND * 2 > 1 THEN particles(i).vel.x = -particles(i).vel.x
            IF RND * 2 > 1 THEN particles(i).vel.y = -particles(i).vel.y
        END IF
    NEXT
    _DISPLAY
    _LIMIT 120
LOOP

END

