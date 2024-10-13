DEFLNG A-Z
OPTION _EXPLICIT
OPTION BASE 1
'$STATIC

CONST FALSE = 0, true = NOT FALSE

RANDOMIZE TIMER

$RESIZE:SMOOTH
DIM gameArea AS LONG: gameArea = _NEWIMAGE(800, 600, 32)
SCREEN gameArea
_TITLE "Blockout"
_PRINTMODE _KEEPBACKGROUND
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH

TYPE Block
    x AS INTEGER
    y AS INTEGER
    c AS _UNSIGNED LONG
    state AS _BYTE
    special AS _BYTE
    kind AS _BYTE
END TYPE

TYPE Ball
    x AS SINGLE
    y AS SINGLE
    c AS _UNSIGNED LONG
    radius AS INTEGER
    state AS _BYTE
    xDir AS _BYTE
    yDir AS _BYTE
    xVel AS SINGLE
    yVel AS SINGLE
END TYPE

TYPE Particle
    x AS SINGLE
    y AS SINGLE
    xAcc AS SINGLE
    yAcc AS SINGLE
    xVel AS SINGLE
    yVel AS SINGLE
    r AS _UNSIGNED _BYTE
    g AS _UNSIGNED _BYTE
    b AS _UNSIGNED _BYTE
    state AS _BYTE
    size AS INTEGER
    lifeSpan AS SINGLE
    birth AS SINGLE
    special AS _BYTE
    kind AS _BYTE
END TYPE

TYPE Special
    start AS SINGLE
    span AS INTEGER
END TYPE

CONST gravity = .03

CONST blockWidth = 80
CONST blockHeight = 30
CONST paddleHeight = 15

CONST s_round = 0
CONST s_square = 1
CONST specialPower = 2

CONST left = -1
CONST right = 1
CONST up = -1
CONST down = 1

CONST regular = 0
CONST hitTwice = 1
CONST unbreakable = 2

CONST bullet = 1

DIM SHARED block(1 TO 100) AS Block, ball AS Ball
DIM SHARED particle(1 TO 10000) AS Particle
DIM SHARED win AS _BYTE, quit AS STRING * 1
DIM SHARED paddleX AS INTEGER, paddleY AS INTEGER
DIM SHARED paddleWidth AS SINGLE, magneticOffset AS INTEGER
DIM SHARED score AS INTEGER, lives AS INTEGER
DIM SHARED paused AS _BYTE, stillImage&

DIM SHARED electricColor(1 TO 2) AS _UNSIGNED LONG
electricColor(1) = _RGB32(255)
electricColor(2) = _RGB32(50, 211, 255)

CONST FireBall = 1
CONST Shooter = 2
CONST BreakThrough = 3
CONST Magnetic = 4
CONST StretchPaddle = 5
CONST StretchPaddle2 = 6
CONST totalSpecialPowers = 6

DIM SHARED special(1 TO totalSpecialPowers) AS Special

DIM i AS LONG
FOR i = 1 TO totalSpecialPowers
    special(i).span = 15
NEXT

CONST defaultPaddleWidth = 150

paddleY = _HEIGHT - blockHeight - paddleHeight - 1

DO
    IF lives = 0 THEN score = 0: lives = 3
    win = FALSE
    paused = FALSE
    generateBlocks
    paddleWidth = defaultPaddleWidth
    ball.state = FALSE
    ball.c = _RGB32(161, 161, 155)
    ball.radius = 10
    ball.xDir = right
    ball.yDir = up
    ball.xVel = 5
    ball.yVel = 5
    FOR i = 1 TO totalSpecialPowers
        special(i).start = 0
    NEXT
    magneticOffset = paddleWidth / 2

    FOR i = 1 TO UBOUND(particle)
        resetParticle particle(i)
    NEXT

    _MOUSEHIDE

    DIM AS _BYTE noFocus, showFullScreenMessage
    DIM k AS LONG
    DIM AS DOUBLE pauseStart, pauseDiff
    DIM AS STRING m
    DIM AS LONG bAlpha

    DO
        k& = _KEYHIT
        'remove before release:
        IF k& = ASC("s") THEN special(Shooter).start = TIMER
        IF k& = ASC("m") THEN special(Magnetic).start = TIMER
        IF k& = ASC("b") THEN special(BreakThrough).start = TIMER
        IF k& = ASC("f") THEN special(FireBall).start = TIMER
        IF k& = ASC("p") THEN special(StretchPaddle).start = TIMER
        IF k& = ASC("P") THEN special(StretchPaddle2).start = TIMER
        IF k& = ASC("r") THEN EXIT DO

        noFocus%% = lostFocus
        IF (paused = true AND k& = 13) OR k& = 27 OR noFocus%% THEN
            IF paused THEN
                _FREEIMAGE stillImage&
                paused = FALSE
                showFullScreenMessage%% = FALSE
                pauseDiff = TIMER - pauseStart
                FOR i = 1 TO totalSpecialPowers
                    IF special(i).start > 0 THEN
                        special(i).start = special(i).start + pauseDiff
                    END IF
                NEXT
                FOR i = 1 TO UBOUND(particle)
                    IF particle(i).birth > 0 THEN
                        particle(i).birth = particle(i).birth + pauseDiff
                    END IF
                NEXT
            ELSE
                paused = true
                IF noFocus%% THEN showFullScreenMessage%% = true
                pauseStart = TIMER
                stillImage& = _COPYIMAGE(0)
            END IF
        END IF

        IF paused THEN
            _PUTIMAGE , stillImage&
            m$ = "Paused (ENTER to continue)"
            COLOR _RGB32(0)
            _PRINTSTRING ((_WIDTH - _PRINTWIDTH(m$)) / 2 + 1, (_HEIGHT - _FONTHEIGHT) / 2 + 1 + _FONTHEIGHT), m$
            COLOR _RGB32(255)
            _PRINTSTRING ((_WIDTH - _PRINTWIDTH(m$)) / 2, (_HEIGHT - _FONTHEIGHT) / 2 + _FONTHEIGHT), m$

            IF showFullScreenMessage%% THEN
                m$ = "(Hit Alt+Enter to switch to fullscreen)"
                COLOR _RGB32(0)
                _PRINTSTRING ((_WIDTH - _PRINTWIDTH(m$)) / 2 + 1, (_HEIGHT - _FONTHEIGHT) / 2 + 1 + _FONTHEIGHT * 2), m$
                COLOR _RGB32(255)
                _PRINTSTRING ((_WIDTH - _PRINTWIDTH(m$)) / 2, (_HEIGHT - _FONTHEIGHT) / 2 + _FONTHEIGHT * 2), m$
            END IF
        ELSE
            IF TIMER - special(BreakThrough).start < special(BreakThrough).span THEN
                bAlpha = map(ball.xVel, 5, 10, 80, 30)
            ELSE
                bAlpha = 255
            END IF
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, bAlpha), BF

            showBlocks
            doPaddle
            doBall
            doParticles

            m$ = "Score:" + STR$(score) + " Lives:" + STR$(lives)
            COLOR _RGB32(0)
            _PRINTSTRING (1, 1), m$
            COLOR _RGB32(255)
            _PRINTSTRING (0, 0), m$

            'remove before release:
            IF TIMER - special(FireBall).start < special(FireBall).span THEN
                _PRINTSTRING (0, 350), "fireball: " + STR$(INT(TIMER - special(FireBall).start))
            END IF

            IF TIMER - special(BreakThrough).start < special(BreakThrough).span THEN
                _PRINTSTRING (0, 370), "breakthrough: " + STR$(INT(TIMER - special(BreakThrough).start))
            END IF

            IF TIMER - special(Shooter).start < special(Shooter).span THEN
                _PRINTSTRING (0, 388), "shooter: " + STR$(INT(TIMER - special(Shooter).start))
            END IF

            IF TIMER - special(Magnetic).start < special(Magnetic).span THEN
                _PRINTSTRING (0, 406), "magnetic: " + STR$(INT(TIMER - special(Magnetic).start))
            END IF

            IF TIMER - special(StretchPaddle).start < special(StretchPaddle).span THEN
                'remove before release:
                _PRINTSTRING (0, 422), "stretch: " + STR$(INT(TIMER - special(StretchPaddle).start))
                paddleWidth = defaultPaddleWidth * 1.5
            ELSE
                paddleWidth = defaultPaddleWidth
            END IF

            IF TIMER - special(StretchPaddle2).start < special(StretchPaddle2).span THEN
                'remove before release:
                _PRINTSTRING (0, 438), "stretch2: " + STR$(INT(TIMER - special(StretchPaddle2).start))
                paddleWidth = defaultPaddleWidth * 2
            ELSE
                IF TIMER - special(StretchPaddle).start > special(StretchPaddle).span OR special(StretchPaddle).start = 0 THEN
                    paddleWidth = defaultPaddleWidth
                END IF
            END IF

        END IF

        _DISPLAY
        _LIMIT 60
    LOOP UNTIL win OR lives = 0

    _MOUSESHOW

    CLS
    IF win THEN
        PRINT "Good job, you win."
        PRINT "Continue (y/n)?"
    ELSE
        PRINT "You lose."
        PRINT "Restart (y/n)?"
    END IF

    _AUTODISPLAY
    _KEYCLEAR

    DO
        quit = LCASE$(INPUT$(1))
    LOOP UNTIL quit = "y" OR quit = "n"

LOOP WHILE quit = "y"

SYSTEM

FUNCTION lostFocus%%
    STATIC Focused AS _BYTE

    IF _WINDOWHASFOCUS = FALSE THEN
        IF Focused THEN
            Focused = FALSE
            lostFocus%% = true
        END IF
    ELSE
        Focused = true
    END IF
END FUNCTION

SUB doParticles
    DIM thisColor AS _UNSIGNED LONG, bAlpha AS _UNSIGNED _BYTE
    DIM AS LONG i, l, size, j, k
    DIM AS _BYTE specialDrawn
    DIM AS STRING m

    FOR i = 1 TO UBOUND(particle)
        IF particle(i).state = FALSE THEN _CONTINUE
        IF particle(i).lifeSpan > 0 AND TIMER - particle(i).birth > particle(i).lifeSpan THEN particle(i).state = FALSE: _CONTINUE

        'move
        particle(i).xVel = particle(i).xVel + particle(i).xAcc
        particle(i).yVel = particle(i).yVel + particle(i).yAcc + gravity
        particle(i).x = particle(i).x + particle(i).xVel
        particle(i).y = particle(i).y + particle(i).yVel

        IF particle(i).kind = bullet THEN
            l = newParticle
            IF l THEN
                particle(l).r = 222 + (RND * 30)
                particle(l).g = 100 + (RND * 70)
                particle(l).x = particle(i).x
                particle(l).y = particle(i).y
                particle(l).lifeSpan = 0.05
            END IF
        END IF

        'check visibility
        IF particle(i).x - particle(i).size / 2 < 0 OR particle(i).x + particle(i).size / 2 > _WIDTH OR particle(i).y - particle(i).size / 2 < 0 OR particle(i).y + particle(i).size / 2 > _HEIGHT THEN
            particle(i).state = FALSE
            _CONTINUE
        END IF

        'show
        IF particle(i).lifeSpan > 0 THEN
            bAlpha = map(TIMER - particle(i).birth, 0, particle(i).lifeSpan, 255, 0)
        ELSE
            bAlpha = 255
        END IF

        thisColor = _RGBA32(particle(i).r, particle(i).g, particle(i).b, bAlpha)

        IF particle(i).size > 0 THEN
            SELECT CASE particle(i).kind
                CASE s_round, bullet
                    CircleFill particle(i).x, particle(i).y, particle(i).size, thisColor
                CASE s_square
                    LINE (particle(i).x - size / 2, particle(i).y - size / 2)-STEP(particle(i).size, particle(i).size), thisColor, BF
                CASE specialPower
                    SELECT CASE particle(i).special
                        'CONST FireBall = 1
                        'CONST Shooter = 2
                        'CONST BreakThrough = 3
                        'CONST Magnetic = 4
                        'CONST StretchPaddle = 5
                        'CONST StretchPaddle2 = 6
                        CASE FireBall
                            FOR j = 1 TO 10
                                l = newParticle
                                IF l = 0 THEN EXIT FOR
                                particle(l).r = 222 + (RND * 30)
                                particle(l).g = 100 + (RND * 70)
                                particle(l).x = particle(i).x + COS(RND * _PI(2)) * (ball.radius * RND)
                                particle(l).y = particle(i).y + SIN(RND * _PI(2)) * (ball.radius * RND)
                                particle(l).lifeSpan = .1
                            NEXT
                            CircleFill particle(i).x, particle(i).y, particle(i).size, _RGBA32(222 + (RND * 30), 100 + (RND * 70), 0, RND * 255)
                            specialDrawn = true
                        CASE Shooter
                            LINE (particle(i).x - 7, particle(i).y + 1)-STEP(15, 8), _RGB32(89, 161, 255), BF
                            CircleFill particle(i).x - 7, particle(i).y + 5, 4, _RGB32(194, 89, 61)
                            CircleFill particle(i).x - 7, particle(i).y + 2, 3, _RGB32(194, 133, 61)
                            CircleFill particle(i).x - 7, particle(i).y, 3, _RGB32(194, 188, 61)

                            l = newParticle
                            IF l > 0 THEN
                                particle(l).r = 222 + (RND * 30)
                                particle(l).g = 100 + (RND * 70)
                                particle(l).x = particle(i).x - 7
                                particle(l).y = particle(i).y
                                particle(l).lifeSpan = .1
                            END IF

                            specialDrawn = true
                        CASE BreakThrough
                            CircleFill particle(i).x - 8, particle(i).y + 8, 3, _RGB32(177, 30)
                            CircleFill particle(i).x - 6, particle(i).y + 6, 3, _RGB32(177, 50)
                            CircleFill particle(i).x - 3, particle(i).y + 3, 4, _RGB32(177, 100)
                            CircleFill particle(i).x, particle(i).y, 4, _RGB32(177, 200)
                            specialDrawn = true
                        CASE Magnetic
                            FOR j = 1 TO 2
                                PSET (particle(i).x + COS(0) * (particle(i).size + particle(i).size * RND), particle(i).y + SIN(0) * (particle(i).size + particle(i).size * RND)), electricColor(j)
                                FOR k = 0 TO _PI(2) STEP .2
                                    LINE -(particle(i).x + COS(k) * (particle(i).size + particle(i).size * RND), particle(i).y + SIN(k) * (particle(i).size + particle(i).size * RND)), electricColor(j)
                                NEXT
                                LINE -(particle(i).x + COS(0) * (particle(i).size + particle(i).size * RND), particle(i).y + SIN(0) * (particle(i).size + particle(i).size * RND)), electricColor(j)
                            NEXT
                            specialDrawn = true
                        CASE StretchPaddle
                            LINE (particle(i).x - 7, particle(i).y + 1)-STEP(15, 8), _RGB32(89, 161, 255), BF
                            CircleFill particle(i).x - 7, particle(i).y + 5, 4, _RGB32(194, 89, 61)
                            _FONT 8
                            COLOR _RGB32(255, 150)
                            _PRINTSTRING (particle(i).x - 16, particle(i).y - 10), "1.5x"
                            _FONT 16
                            specialDrawn = true
                        CASE StretchPaddle2
                            LINE (particle(i).x - 3, particle(i).y + 1)-STEP(15, 8), _RGB32(89, 161, 255), BF
                            CircleFill particle(i).x - 3, particle(i).y + 5, 4, _RGB32(194, 89, 61)
                            _FONT 8
                            COLOR _RGB32(255, 150)
                            _PRINTSTRING (particle(i).x + 8, particle(i).y - 10), "2x"
                            _FONT 16
                            specialDrawn = true
                    END SELECT
            END SELECT
        ELSE
            PSET (particle(i).x, particle(i).y), thisColor
        END IF

        'check collision with paddle if this particle contains a special power
        IF particle(i).special THEN
            'remove before release:
            IF specialDrawn = FALSE THEN
                m$ = LTRIM$(STR$(particle(i).special))
                COLOR _RGB32(0)
                _PRINTSTRING (particle(i).x + 1, particle(i).y + 1), m$
                COLOR _RGB32(255)
                _PRINTSTRING (particle(i).x, particle(i).y), m$
            END IF

            IF particle(i).x - particle(i).size / 2 > paddleX AND particle(i).x + particle(i).size / 2 < paddleX + paddleWidth AND particle(i).y + particle(i).size / 2 >= paddleY THEN
                particle(i).state = FALSE
                special(particle(i).special).start = TIMER
            END IF
        END IF

        'check collision with blocks if this particle is a bullet
        IF particle(i).kind = bullet THEN
            FOR j = 1 TO UBOUND(block)
                IF block(j).state = FALSE THEN _CONTINUE
                IF particle(i).x > block(j).x AND particle(i).x < block(j).x + blockWidth AND particle(i).y < block(j).y + blockHeight THEN
                    destroyBlock j, FALSE
                    IF TIMER - special(BreakThrough).start > special(BreakThrough).span OR special(BreakThrough).start = 0 THEN
                        particle(i).state = FALSE
                    END IF
                    EXIT FOR
                END IF
            NEXT
        END IF
    NEXT
END SUB

SUB resetParticle (this AS Particle)
    DIM empty AS Particle
    this = empty
END SUB

SUB generateBlocks
    DIM AS LONG i, j, b, minRGB, cRed, cGreen, cBlue, r

    FOR i = 1 TO 10
        FOR j = 1 TO 10
            b = b + 1
            block(b).x = (i - 1) * blockWidth
            block(b).y = (j - 1) * blockHeight
            minRGB = 50
            DO
                cRed = 255 * RND
                cGreen = 255 * RND
                cBlue = 255 * RND
            LOOP UNTIL cRed > minRGB AND cGreen > minRGB AND cBlue > minRGB
            block(b).c = _RGB32(cRed, cGreen, cBlue)
            block(b).state = RND
            r = RND * 1000
            IF r > 150 AND r < 200 THEN
                block(b).special = RND * totalSpecialPowers
            END IF

            r = RND * 1000
            IF r > 150 AND r < 200 THEN
                block(b).kind = RND * 2
            END IF
        NEXT
    NEXT
END SUB

SUB showBlocks
    DIM AS LONG i, activeBlocks, x, y, j

    FOR i = 1 TO UBOUND(block)
        IF block(i).state = FALSE THEN _CONTINUE
        activeBlocks = activeBlocks + 1
        IF block(i).kind <> unbreakable THEN
            LINE (block(i).x, block(i).y)-STEP(blockWidth - 1, blockHeight - 1), block(i).c, BF
        END IF

        IF block(i).kind = hitTwice THEN
            FOR x = block(i).x TO block(i).x + blockWidth - 1 STEP 5
                LINE (x, block(i).y)-(x, block(i).y + blockHeight - 1), _RGB32(188)
            NEXT
        ELSEIF block(i).kind = unbreakable THEN
            activeBlocks = activeBlocks - 1
            FOR x = block(i).x TO block(i).x + blockWidth - 1 STEP 5
                LINE (x, block(i).y)-(x, block(i).y + blockHeight - 1), _RGB32(72)
            NEXT
            FOR y = block(i).y TO block(i).y + blockHeight - 1 STEP 5
                LINE (block(i).x, y)-(block(i).x + blockWidth - 1, y), _RGB32(72)
            NEXT
        END IF

        LINE (block(i).x, block(i).y)-STEP(blockWidth - 1, blockHeight - 1), _RGB32(255), B
        LINE (block(i).x + 1, block(i).y + 1)-STEP(blockWidth - 3, blockHeight - 3), _RGB32(0), B

        IF block(i).special THEN
            FOR j = 1 TO 6 STEP 2
                LINE (block(i).x + j, block(i).y + j)-STEP(blockWidth - j * 2, blockHeight - j * 2), _RGB32(255, 166, 0), B
                LINE (block(i).x + j + 1, block(i).y + j + 1)-STEP(blockWidth - j * 3, blockHeight - j * 3), _RGB32(255, 238, 0), B
            NEXT

            'remove before release:
            COLOR _RGB32(0)
            _PRINTSTRING (block(i).x + 1, block(i).y + 1), STR$(block(i).special)
            COLOR _RGB32(255)
            _PRINTSTRING (block(i).x, block(i).y), STR$(block(i).special)
        END IF
    NEXT
    win = (activeBlocks = 0)
END SUB

SUB doPaddle
    STATIC lastX AS INTEGER
    DIM AS LONG j, i, l

    WHILE _MOUSEINPUT: WEND

    IF _MOUSEX <> lastX THEN
        lastX = _MOUSEX
        paddleX = _MOUSEX - paddleWidth / 2
    END IF

    IF _KEYDOWN(19200) THEN paddleX = paddleX - 5
    IF _KEYDOWN(19712) THEN paddleX = paddleX + 5

    IF paddleX < 0 THEN paddleX = 0
    IF paddleX + paddleWidth > _WIDTH - 1 THEN paddleX = _WIDTH - 1 - paddleWidth

    LINE (paddleX + paddleHeight / 2, paddleY)-STEP(paddleWidth - paddleHeight, paddleHeight), _RGB32(89, 161, 255), BF
    CircleFill paddleX + paddleHeight / 2, paddleY + paddleHeight / 2, paddleHeight / 2, _RGB32(194, 89, 61)
    CircleFill paddleX + paddleWidth - paddleHeight / 2, paddleY + paddleHeight / 2, paddleHeight / 2, _RGB32(194, 89, 61)

    IF TIMER - special(Magnetic).start < special(Magnetic).span THEN
        FOR j = 1 TO 2
            PSET (paddleX + paddleHeight / 2, paddleY), electricColor(j)
            FOR i = paddleX + paddleHeight TO paddleX + paddleWidth - paddleHeight STEP paddleWidth / 10
                LINE -(i, paddleY - (RND * 10)), electricColor(j)
            NEXT
            LINE -(paddleX + paddleWidth - paddleHeight / 2, paddleY), electricColor(j)

        NEXT
    END IF

    IF _MOUSEBUTTON(1) OR _KEYDOWN(13) THEN ball.state = true

    IF _MOUSEBUTTON(1) THEN
        STATIC mouseWasDown AS _BYTE
        mouseWasDown = true
    END IF

    IF TIMER - special(Shooter).start < special(Shooter).span THEN
        CircleFill paddleX + paddleHeight / 2, paddleY, paddleHeight / 3, _RGB32(194, 133, 61)
        CircleFill paddleX + paddleWidth - paddleHeight / 2, paddleY, paddleHeight / 3, _RGB32(194, 133, 61)

        CircleFill paddleX + paddleHeight / 2, paddleY - paddleHeight / 4, paddleHeight / 4, _RGB32(194, 188, 61)
        CircleFill paddleX + paddleWidth - paddleHeight / 2, paddleY - paddleHeight / 4, paddleHeight / 4, _RGB32(194, 188, 61)

        IF _MOUSEBUTTON(1) = FALSE AND mouseWasDown THEN
            mouseWasDown = FALSE

            FOR i = 1 TO 2
                l = newParticle
                particle(l).r = 100
                particle(l).g = 100
                particle(l).b = 100
                IF i = 1 THEN particle(l).x = paddleX + paddleHeight / 2 ELSE particle(l).x = paddleX + paddleWidth - paddleHeight / 2
                particle(l).y = paddleY
                particle(l).yVel = -4.5
                particle(l).yAcc = -gravity * 1.5
                particle(l).size = 2
                particle(l).kind = bullet
            NEXT
        END IF
    END IF

END SUB

SUB doBall
    DIM AS LONG j, l

    IF ball.state = FALSE THEN
        ball.x = paddleX + magneticOffset
        ball.y = paddleY - (ball.radius)
    ELSE
        ball.x = ball.x + ball.xDir * ball.xVel
        ball.y = ball.y + ball.yDir * ball.yVel

        ballCollision
    END IF

    IF TIMER - special(FireBall).start < special(FireBall).span THEN
        FOR j = 1 TO 10
            l = newParticle
            IF l = 0 THEN EXIT FOR
            particle(l).r = 222 + (RND * 30)
            particle(l).g = 100 + (RND * 70)
            particle(l).x = ball.x + COS(RND * _PI(2)) * (ball.radius * RND)
            particle(l).y = ball.y + SIN(RND * _PI(2)) * (ball.radius * RND)
            particle(l).lifeSpan = RND
        NEXT
    END IF

    CircleFill ball.x, ball.y, ball.radius, ball.c
END SUB

FUNCTION newParticle&
    DIM AS LONG i

    FOR i = 1 TO UBOUND(particle)
        IF particle(i).state = FALSE THEN
            newParticle& = i
            resetParticle particle(i)
            particle(i).state = true
            particle(i).birth = TIMER
            EXIT FUNCTION
        END IF
    NEXT
END FUNCTION

SUB ballCollision
    DIM AS LONG i

    'paddle
    IF ball.x > paddleX AND ball.x < paddleX + paddleWidth AND ball.y > paddleY AND ball.y < paddleY + paddleHeight THEN
        IF TIMER - special(Magnetic).start < special(Magnetic).span THEN
            ball.state = FALSE
            magneticOffset = ball.x - paddleX
        END IF

        IF ball.x < paddleX + paddleWidth / 2 THEN
            ball.xDir = left
            ball.xVel = map(ball.x, paddleX, paddleX + paddleWidth / 3, 10, 5)
        ELSE
            ball.xDir = right
            ball.xVel = map(ball.x, paddleX + paddleWidth / 3, paddleX + paddleWidth, 5, 10)
        END IF
        IF ball.xVel < 5 THEN ball.xVel = 5

        IF ball.yDir = 1 AND ball.y < paddleY + paddleHeight / 2 THEN ball.yDir = -1
        EXIT SUB
    END IF

    'blocks
    FOR i = 1 TO UBOUND(block)
        IF block(i).state = FALSE THEN _CONTINUE
        IF ball.x > block(i).x AND ball.x < block(i).x + blockWidth AND ball.y > block(i).y AND ball.y < block(i).y + blockHeight THEN
            destroyBlock i, true
            EXIT SUB
        END IF
    NEXT

    'walls
    IF ball.x < ball.radius THEN ball.xDir = right
    IF ball.x > _WIDTH - ball.radius THEN ball.xDir = left
    IF ball.y > _HEIGHT + ball.radius THEN
        lives = lives - 1
        magneticOffset = paddleWidth / 2
        ball.state = FALSE
        ball.xDir = right
        ball.yDir = up
        ball.xVel = 5
        ball.yVel = 5
    END IF
    IF ball.y < 0 THEN ball.yDir = down
END SUB

SUB destroyBlock (i AS LONG, ballHit AS _BYTE)
    DIM AS LONG maxJ, maxK, j, k, l, a, points

    SELECT CASE block(i).kind
        CASE regular
            block(i).state = FALSE

            IF TIMER - special(BreakThrough).start < special(BreakThrough).span THEN
                maxJ = 10
                maxK = 3
                FOR j = 1 TO maxJ
                    FOR k = 1 TO maxK
                        l = newParticle
                        IF l = 0 THEN EXIT FOR
                        a = RND * 1000
                        IF a < 100 THEN
                            particle(l).r = _RED32(block(i).c)
                            particle(l).g = _GREEN32(block(i).c)
                            particle(l).b = _BLUE32(block(i).c)
                        ELSE
                            particle(l).r = map(a, 0, 1000, 50, 255)
                            particle(l).g = map(a, 0, 1000, 50, 255)
                            particle(l).b = map(a, 0, 1000, 50, 255)
                        END IF
                        particle(l).x = block(i).x + ((blockWidth / maxJ) * (j - 1))
                        particle(l).y = block(i).y + ((blockHeight / maxK) * (k - 1))
                        a = RND
                        IF ball.xDir = right AND ball.yDir = up THEN
                            particle(l).xAcc = COS(map(a, 0, 1, _PI(1.5), _PI(2)))
                            particle(l).yAcc = SIN(map(a, 0, 1, _PI(1.5), _PI(2)))
                        ELSEIF ball.xDir = right AND ball.yDir = down THEN
                            particle(l).xAcc = COS(map(a, 0, 1, 0, _PI(.5)))
                            particle(l).yAcc = SIN(map(a, 0, 1, 0, _PI(.5)))
                        ELSEIF ball.xDir = left AND ball.yDir = up THEN
                            particle(l).xAcc = COS(map(a, 0, 1, _PI, _PI(1.5)))
                            particle(l).yAcc = SIN(map(a, 0, 1, _PI, _PI(1.5)))
                        ELSEIF ball.xDir = left AND ball.yDir = down THEN
                            particle(l).xAcc = COS(map(a, 0, 1, _PI(.5), _PI))
                            particle(l).yAcc = SIN(map(a, 0, 1, _PI(.5), _PI))
                        END IF
                        particle(l).lifeSpan = .5
                        particle(l).size = 1
                    NEXT
                NEXT
            END IF

            IF block(i).special THEN
                STATIC lastSpecialGiven AS SINGLE
                IF TIMER - lastSpecialGiven > 3 THEN
                    lastSpecialGiven = TIMER
                    l = newParticle
                    IF l THEN
                        particle(l).size = 6
                        particle(l).x = block(i).x + blockWidth / 2
                        particle(l).y = block(i).y + blockHeight / 2
                        particle(l).r = 255
                        particle(l).g = 255
                        particle(l).b = 255
                        particle(l).kind = specialPower
                        particle(l).special = block(i).special
                    END IF
                END IF
            END IF

            points = ((_RED32(block(i).c) + _GREEN32(block(i).c) + _BLUE32(block(i).c)) / 3) / 10
            score = score + points
        CASE hitTwice
            block(i).kind = regular
            IF ballHit THEN
                IF TIMER - special(FireBall).start < special(FireBall).span THEN destroyBlock i, ballHit
            END IF
        CASE unbreakable
            'check if the ball is trapped between two unbreakable blocks
            STATIC lastBlock(1 TO 3) AS Block
            lastBlock(3) = lastBlock(2)
            lastBlock(2) = lastBlock(1)
            lastBlock(1) = block(i)
            IF (lastBlock(1).x = lastBlock(3).x AND lastBlock(1).y = lastBlock(3).y) OR lastBlock(1).x = lastBlock(2).x AND lastBlock(1).y = lastBlock(2).y THEN
                IF ball.xVel > 7.5 AND ball.xVel < 10 THEN
                    ball.xVel = 10
                ELSEIF ball.xVel = 10 THEN
                    ball.xVel = 8
                END IF

                IF ball.xVel <= 7.5 AND ball.xVel > 5 THEN
                    ball.xVel = 5
                ELSEIF ball.xVel = 5 THEN
                    ball.xVel = 6
                END IF
            END IF
    END SELECT

    IF ballHit THEN
        IF (block(i).kind = unbreakable OR block(i).kind = hitTwice) THEN
            FOR j = 1 TO map(ball.xVel, 5, 10, 10, 30)
                l = newParticle
                IF l = 0 THEN EXIT FOR
                particle(l).r = 222 + (RND * 30)
                particle(l).g = 100 + (RND * 70)
                particle(l).x = ball.x + COS(RND * _PI(2)) * (ball.radius * RND)
                particle(l).y = ball.y + SIN(RND * _PI(2)) * (ball.radius * RND)
                particle(l).lifeSpan = RND

                a = RND
                IF ball.xDir = right AND ball.yDir = up THEN
                    particle(l).xVel = COS(map(a, 0, 1, _PI(1.5), _PI(2)))
                    particle(l).yVel = SIN(map(a, 0, 1, _PI(1.5), _PI(2)))
                ELSEIF ball.xDir = right AND ball.yDir = down THEN
                    particle(l).xVel = COS(map(a, 0, 1, 0, _PI(.5)))
                    particle(l).yVel = SIN(map(a, 0, 1, 0, _PI(.5)))
                ELSEIF ball.xDir = left AND ball.yDir = up THEN
                    particle(l).xVel = COS(map(a, 0, 1, _PI, _PI(1.5)))
                    particle(l).yVel = SIN(map(a, 0, 1, _PI, _PI(1.5)))
                ELSEIF ball.xDir = left AND ball.yDir = down THEN
                    particle(l).xVel = COS(map(a, 0, 1, _PI(.5), _PI))
                    particle(l).yVel = SIN(map(a, 0, 1, _PI(.5), _PI))
                END IF
            NEXT
        END IF

        IF TIMER - special(BreakThrough).start > special(BreakThrough).span OR special(BreakThrough).start = 0 THEN
            IF ball.x < block(i).x + blockWidth / 2 THEN ball.xDir = left ELSE ball.xDir = right
            IF ball.y < block(i).y + blockHeight / 2 THEN ball.yDir = up ELSE ball.yDir = down
        END IF
    END IF
END SUB

SUB CircleFill (CX AS INTEGER, CY AS INTEGER, R AS INTEGER, C AS _UNSIGNED LONG)
    ' CX = center x coordinate
    ' CY = center y coordinate
    '  R = radius
    '  C = fill color
    DIM Radius AS INTEGER, RadiusError AS INTEGER
    DIM X AS INTEGER, Y AS INTEGER
    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0
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
END SUB

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION
