TYPE BALL
    X AS DOUBLE
    Y AS DOUBLE
    U AS DOUBLE
    V AS DOUBLE
    XA AS DOUBLE
    YA AS DOUBLE
END TYPE

DIM SHARED nBall AS INTEGER
DIM SHARED balls(20) AS BALL
DIM SHARED dt AS DOUBLE
DIM SHARED radius AS INTEGER
DIM SHARED diam AS INTEGER
DIM SHARED elastic AS DOUBLE
DIM SHARED fric AS DOUBLE
DIM SHARED isCollision AS INTEGER
DIM SHARED grav AS DOUBLE
DIM SHARED attract AS DOUBLE
DIM SHARED bg AS INTEGER
DIM SHARED fg AS INTEGER
DIM SHARED dela AS INTEGER
DIM SHARED gw AS INTEGER
DIM SHARED gh AS INTEGER
DIM SHARED sBall AS INTEGER
DIM SHARED isStart AS INTEGER
gw = 640
gh = 480
radius = 15
diam = 2 * radius
dt = 1
nBall = 10
elastic = 1
fric = 0
grav = 0
attract = 0
isCollision = 0
bg = 1
fg = 15
dela = 0
sBall = 1
isStart = 1

SETUP

SCREEN 12
PAINT (0, 0), bg
LINE (0, gh + 1)-(gw, gh + 1), 0
PAINT (0, gh + 2), 0

WHILE 1
    FOR i% = 1 TO nBall
        CIRCLE (balls(i%).X, balls(i%).Y), radius, bg
        REDRAW i%
        IF i% = sBall THEN
            CIRCLE (balls(i%).X, balls(i%).Y), radius, 0
        ELSE
            CIRCLE (balls(i%).X, balls(i%).Y), radius, fg
        END IF
    NEXT
    k$ = INKEY$
    SELECT CASE k$
        CASE CHR$(27)
            CLS
            SETUP
            SCREEN 12
            PAINT (0, 0), bg
            LINE (0, gh + 1)-(gw, gh + 1), 0
            PAINT (0, gh + 2), 0
        CASE "=", "+"
            sBall = sBall + 1
            IF sBall > nBall THEN sBall = 1
        CASE "-"
            sBall = sBall - 1
            IF sBall < 1 THEN sBall = nBall
        CASE " "
            WHILE INKEY$ <> " ": WEND
        CASE CHR$(13)
            balls(sBall).U = 0
            balls(sBall).V = 0
        CASE CHR$(0) + "P"
            balls(sBall).V = balls(sBall).V + 1
        CASE CHR$(0) + "H"
            balls(sBall).V = balls(sBall).V - 1
        CASE CHR$(0) + "M"
            balls(sBall).U = balls(sBall).U + 1
        CASE CHR$(0) + "K"
            balls(sBall).U = balls(sBall).U - 1
    END SELECT

    _LIMIT 60
WEND


SUB ATTRACTION (i%)
    IF attract <> 0 THEN
        FOR j% = i% + 1 TO nBall
            xm = balls(j%).X - balls(i%).X
            ym = balls(j%).Y - balls(i%).Y
            dist = xm ^ 2 + ym ^ 2
            IF dist < (radius ^ 2) THEN dist = radius ^ 2
            balls(i%).U = attract * xm / dist + balls(i%).U
            balls(i%).V = attract * ym / dist + balls(i%).V
            balls(j%).U = attract * xm / dist + balls(j%).U
            balls(j%).V = -attract * ym / dist + balls(j%).V
        NEXT
    END IF
END SUB

SUB ChangeValue (selected, k$)
    SELECT CASE selected
        CASE 0
            sBall = nBall
            IF k$ = CHR$(0) + "M" THEN
                nBall = nBall + 1
                IF nBall > 20 THEN nBall = 1
            END IF
            IF k$ = CHR$(0) + "K" THEN
                nBall = nBall - 1
                IF nBall < 1 THEN nBall = 20
            END IF

            IF nBall > 9 THEN
                LOCATE 8, 50
            ELSE
                LOCATE 8, 51
            END IF
            PRINT nBall
            IF nBall <> sBall THEN
                COLOR 8, 1
                LOCATE 16, 25
                PRINT "{R}     TO RESUME SIMULATION"
                COLOR 15, 1
                isStart = 1
            END IF
        CASE 8
            IF k$ = CHR$(0) + "M" THEN
                elastic = elastic + .1
                IF elastic >= 10 THEN elastic = .1
            END IF
            IF k$ = CHR$(0) + "K" THEN
                elastic = elastic - .1
                IF elastic < -9.99 THEN elastic = 9.9
            END IF
            LOCATE 9, 46
            PRINT "       "
            LOCATE 9, 50
            IF elastic >= 1 THEN LOCATE 9, 49
            PRINT elastic
        CASE 1
            IF k$ = CHR$(0) + "M" THEN
                elastic = elastic + .1
                IF elastic > 9.91 THEN elastic = .1
            END IF
            IF k$ = CHR$(0) + "K" THEN
                elastic = elastic - .1
                IF elastic < .09 THEN elastic = 9.91
            END IF
            iattract% = (elastic - INT(elastic)) * 10
            IF iattract% > 9 THEN
                LOCATE 9, 50
                PRINT iattract%
                LOCATE 9, 50
            ELSE
                LOCATE 9, 51
                PRINT iattract%
                LOCATE 9, 51
            END IF
            LOCATE 9, 49
            PRINT INT(elastic)
            LOCATE 9, 51
            PRINT "."
        CASE 2
            IF k$ = CHR$(0) + "M" THEN
                fric = fric + .001
                IF fric >= 1 THEN fric = -1
            END IF
            IF k$ = CHR$(0) + "K" THEN
                fric = fric - .001
                IF fric <= -1 THEN fric = 1
            END IF
            LOCATE 10, 46
            PRINT "       "
            LOCATE 10, 48
            IF fric = 0 THEN LOCATE 10, 51
            PRINT fric
        CASE 9
            IF k$ = CHR$(0) + "M" THEN
                fric = fric + .001
                IF fric > .099 THEN fric = 0
            END IF
            IF k$ = CHR$(0) + "K" THEN
                fric = fric - .001
                IF fric < 0 THEN fric = .099
            END IF
            ifric% = fric * 1000
            IF ifric% > 9 THEN
                LOCATE 10, 50
                PRINT ifric%
                LOCATE 10, 50
                PRINT "0"
            ELSE
                LOCATE 10, 51
                PRINT ifric%
                LOCATE 10, 51
                PRINT "0"
            END IF
        CASE 3
            IF k$ = CHR$(0) + "M" THEN
                grav = grav + .001
                IF grav >= 1 THEN grav = -1
            END IF
            IF k$ = CHR$(0) + "K" THEN
                grav = grav - .001
                IF grav <= -1 THEN grav = 1
            END IF
            LOCATE 11, 46
            PRINT "       "
            LOCATE 11, 48
            IF grav = 0 THEN LOCATE 11, 51
            PRINT grav

        CASE 10
            IF k$ = CHR$(0) + "M" THEN
                grav = grav + .001
                IF grav > .099 THEN grav = 0
            END IF
            IF k$ = CHR$(0) + "K" THEN
                grav = grav - .001
                IF grav < 0 THEN grav = .099
            END IF
            igrav% = grav * 1000
            IF igrav% > 9 THEN
                LOCATE 11, 50
                PRINT igrav%
                LOCATE 11, 50
                PRINT "0"
            ELSE
                LOCATE 11, 51
                PRINT igrav%
                LOCATE 11, 51
                PRINT "0"
            END IF
        CASE 4
            IF k$ = CHR$(0) + "M" THEN
                attract = attract + .01
                IF attract >= 10 THEN attract = -9.99
            END IF
            IF k$ = CHR$(0) + "K" THEN
                attract = attract - .01
                IF attract < -9.99 THEN attract = 9.99
            END IF
            LOCATE 12, 48
            PRINT "      "
            LOCATE 12, 49
            IF attract = 0 THEN LOCATE 12, 51
            IF attract >= 1 OR attract <= -1 THEN LOCATE 12, 48
            PRINT attract
        CASE 7
            IF k$ = CHR$(0) + "M" THEN
                attract = attract + .01
                IF attract >= 10 THEN attract = -9.99
            END IF
            IF k$ = CHR$(0) + "K" THEN
                attract = attract - .01
                IF attract < -9.99 THEN attract = 9.99
            END IF
            iattract% = INT((attract - INT(attract)) * 100)
            IF iattract% > 9 THEN
                LOCATE 12, 50
                PRINT iattract%
            ELSE
                LOCATE 12, 51
                PRINT iattract%
                LOCATE 12, 51
                PRINT "0"
            END IF
            LOCATE 12, 48
            PRINT INT(attract)
            LOCATE 12, 50
            PRINT "."
        CASE 5
            IF k$ = CHR$(0) + "M" THEN
                dt = dt + .1
                IF dt > 9.9 THEN dt = .1
            END IF
            IF k$ = CHR$(0) + "K" THEN
                dt = dt - .1
                IF dt <= 0 THEN dt = 9.9
            END IF
            iattract% = dt * 10
            IF iattract% > 9 THEN
                LOCATE 13, 50
                PRINT iattract%
                LOCATE 13, 50
            ELSE
                LOCATE 13, 51
                PRINT iattract%
                LOCATE 13, 51
            END IF
            LOCATE 13, 49
            PRINT INT(dt)
            LOCATE 13, 51
            PRINT "."
        CASE 6
            IF k$ = CHR$(0) + "M" THEN
                dela = dela + 1
                IF dela > 9 THEN dela = 0
            END IF
            IF k$ = CHR$(0) + "K" THEN
                dela = dela - 1
                IF dela < 0 THEN dela = 9
            END IF
            
            IF dela > 9 THEN
                LOCATE 14, 50
                PRINT dela
            ELSE
                LOCATE 14, 51
                PRINT dela
            END IF
    END SELECT
END SUB

SUB COLLISION (i%)
    FOR j% = i% + 1 TO nBall
        xi = balls(i%).X
        yi = balls(i%).Y
        xj = balls(j%).X
        yj = balls(j%).Y
        dx = xi - xj
        dy = yi - yj
        dist = SQR(dx ^ 2 + dy ^ 2)
        IF (dist < diam) THEN
            isCollision = 1
            CIRCLE (balls(i%).X, balls(i%).Y), radius, bg
            CIRCLE (balls(j%).X, balls(j%).Y), radius, bg
            ui = balls(i%).U
            vi = balls(i%).V
            uj = balls(j%).U
            vj = balls(j%).V

            CoefA = (ui - uj) ^ 2 + (vi - vj) ^ 2
            CoefB = 2 * ((ui - uj) * (xi - xj) + (vi - vj) * (yi - yj))
            CoefC = (xi - xj) ^ 2 + (yi - yj) ^ 2 - diam ^ 2

            IF (CoefA = 0) THEN
                t = -CoefC / CoefB
            ELSE
                IF (dt >= 0) THEN
                    t = (-CoefB - SQR(CoefB ^ 2 - 4 * CoefA * CoefC)) / (2 * CoefA)
                ELSE
                    t = (-CoefB + SQR(CoefB ^ 2 - 4 * CoefA * CoefC)) / (2 * CoefA)
                END IF
            END IF
            xi = xi + t * ui
            yi = yi + t * vi
            xj = xj + t * uj
            yj = yj + t * vj

            mx = (ui + uj) / 2
            my = (vi + vj) / 2
            ui = ui - mx
            vi = vi - my
            uj = uj - mx
            vj = vj - my

            dx = xi - xj
            dy = yi - yj
            dist = SQR(dx ^ 2 + dy ^ 2)
            dx = dx / dist
            dy = dy / dist

            foo = -(dx * ui + dy * vi)
            ui = ui + 2 * foo * dx
            vi = vi + 2 * foo * dy
            bar = -(dx * uj + dy * vj)
            uj = uj + 2 * bar * dx
            vj = vj + 2 * bar * dy

            e = SQR(elastic)
            ui = e * (ui + mx)
            vi = e * (vi + my)
            uj = e * (uj + mx)
            vj = e * (vj + my)

            xi = xi - t * ui
            yi = yi - t * vi
            xj = xj - t * uj
            yj = yj - t * vj

            balls(i%).U = ui
            balls(i%).V = vi
            balls(j%).U = uj
            balls(j%).V = vj

            balls(i%).X = xi
            balls(i%).Y = yi
            balls(j%).X = xj
            balls(j%).Y = yj
        END IF
    NEXT
END SUB

SUB CreateFancyBox ()

    COLOR 15, 1

    LOCATE 3, 23
    PRINT CHR$(201)
    LOCATE 18, 23
    PRINT CHR$(200)
    LOCATE 18, 56
    PRINT CHR$(188)
    LOCATE 3, 56
    PRINT CHR$(187)

    COLOR 1, 0

    FOR i% = 0 TO 13
        FOR j% = 0 TO 32
            LOCATE 4 + i%, 24 + j%
            PRINT CHR$(219)
        NEXT
    NEXT

    COLOR 15, 1

    FOR i% = 0 TO 31
        LOCATE 3, 24 + i%
        PRINT CHR$(205)
        LOCATE 18, 24 + i%
        PRINT CHR$(205)
    NEXT

    FOR i% = 0 TO 13
        LOCATE 4 + i%, 23
        PRINT CHR$(186)
        LOCATE 4 + i%, 56
        PRINT CHR$(186)
    NEXT

END SUB

SUB CreateOtherFancyBox ()

    COLOR 2, 0

    FOR i% = 0 TO 3
        FOR j% = 0 TO 43
            LOCATE 20 + i%, 18 + j%
            PRINT CHR$(219)
        NEXT
    NEXT

    COLOR 15, 2

    FOR i% = 0 TO 41
        LOCATE 20, 19 + i%
        PRINT CHR$(205)
        LOCATE 23, 19 + i%
        PRINT CHR$(205)
    NEXT

    FOR i% = 0 TO 1
        LOCATE 21 + i%, 18
        PRINT CHR$(186)
        LOCATE 21 + i%, 61
        PRINT CHR$(186)

    NEXT

    LOCATE 20, 18
    PRINT CHR$(201)
    LOCATE 23, 18
    PRINT CHR$(200)
    LOCATE 23, 61
    PRINT CHR$(188)
    LOCATE 20, 61
    PRINT CHR$(187)

    LOCATE 21, 20
    PRINT "CHANGE SELECTED: +/-"

    LOCATE 21, 46
    PRINT "STOP:  {ENTER}"
    LOCATE 22, 46
    PRINT "PAUSE: {SPACE}"


    LOCATE 22, 20
    PRINT "CHANGE VELOCITY:"

    FOR i% = 0 TO 1
        LOCATE 22, 37 + (2 * i%)
        PRINT CHR$(24 + i%)
    NEXT

    FOR i% = 1 TO 0 STEP -1
        LOCATE 22, 43 - (2 * i%)
        PRINT CHR$(26 + i%)
    NEXT


    COLOR 15, 1

END SUB

SUB delay (ticks%)

    FOR i% = 1 TO ticks%
        st# = TIMER
        WHILE TIMER = st#: WEND
    NEXT i%

END SUB

SUB GRAVITY (i%)
    U = balls(i%).U
    V = balls(i%).V
    fricscale = (1 - fric / SQR(1 + U ^ 2 + V ^ 2))
    balls(i%).U = fricscale * U
    balls(i%).V = fricscale * V + grav
END SUB

SUB PAUSE ()
    WHILE INKEY$ = "": WEND
END SUB

FUNCTION Rand% (Bottom AS INTEGER, Top AS INTEGER)
    RANDOMIZE TIMER
    RANDOMIZE RND
    Rand% = INT((Top - Bottom + 1) * RND + Bottom)
END FUNCTION

SUB REDRAW (i%)
    balls(i%).X = balls(i%).X + (balls(i%).U * dt)
    balls(i%).Y = balls(i%).Y + (balls(i%).V * dt)
    X = balls(i%).X
    Y = balls(i%).Y
    IF X < radius THEN
        balls(i%).U = -balls(i%).U
        balls(i%).X = radius
    END IF
    IF X > (gw - radius) THEN
        balls(i%).U = -balls(i%).U
        balls(i%).X = (gw - radius)
    END IF
    IF Y < radius THEN
        balls(i%).V = -balls(i%).V
        balls(i%).Y = radius
    END IF
    IF Y > (gh - radius) THEN
        balls(i%).V = -balls(i%).V
        balls(i%).Y = gh - radius
    END IF
    COLLISION i%
    GRAVITY i%
    ATTRACTION i%
END SUB

SUB SETUP ()
    SCREEN 0
    CLS

    'LOCATE 1, 1
    'PRINT sBall

    CreateFancyBox
    CreateOtherFancyBox

    LOCATE 4, 28
    PRINT "COLLIDING BALL SIMULATION"
    LOCATE 5, 31
    PRINT "Copyright (c) 2013"
    LOCATE 6, 32
    PRINT "Timothy Baxendale"

    LOCATE 8, 25
    PRINT "NUMBER OF BALLS"
    COLOR 6, 1
    LOCATE 8, 45
    PRINT CHR$(17)
    COLOR 15, 1
    LOCATE 9, 25
    PRINT "ELASTIC"
    LOCATE 9, 45
    PRINT CHR$(17)
    LOCATE 10, 25
    PRINT "FRICTION"
    LOCATE 10, 45
    PRINT CHR$(17)
    LOCATE 11, 25
    PRINT "GRAVITY"
    LOCATE 11, 45
    PRINT CHR$(17)
    LOCATE 12, 25
    PRINT "ATTRACTION"
    LOCATE 12, 45
    PRINT CHR$(17)
    LOCATE 13, 25
    PRINT "SPEED"
    LOCATE 13, 45
    PRINT CHR$(17)

    ChangeValue 0, ""
    LOCATE 10, 48
    PRINT "0.000"
    ChangeValue 1, ""
    LOCATE 11, 48
    PRINT "0.000"
    ChangeValue 2, ""
    ChangeValue 3, ""
    ChangeValue 4, ""
    ChangeValue 5, ""

    LOCATE 15, 25
    PRINT "{ENTER} TO RUN SIMULATION"

    IF isStart = 1 THEN COLOR 8, 1
    LOCATE 16, 25
    PRINT "{R}     TO RESUME SIMULATION"
    IF isStart = 1 THEN COLOR 15, 1

    LOCATE 17, 25
    PRINT "{ESC}   TO EXIT"

    COLOR 6, 1
    LOCATE 8, 54
    PRINT CHR$(16)
    COLOR 15, 1

    LOCATE 9, 54
    PRINT CHR$(16)
    LOCATE 10, 54
    PRINT CHR$(16)
    LOCATE 11, 54
    PRINT CHR$(16)
    LOCATE 12, 54
    PRINT CHR$(16)
    LOCATE 13, 54
    PRINT CHR$(16)

    selected = 0

    WHILE 1
        k$ = INKEY$
        SELECT CASE k$
            CASE CHR$(27)
                COLOR 7, 0
                CLS
                END
            CASE CHR$(0) + "P"
                LOCATE 8 + selected, 54
                PRINT CHR$(16)
                LOCATE 8 + selected, 45
                PRINT CHR$(17)
                selected = selected + 1
                IF selected > 5 THEN selected = 0
                COLOR 6, 1
                LOCATE 8 + selected, 54
                PRINT CHR$(16)
                LOCATE 8 + selected, 45
                PRINT CHR$(17)
                COLOR 15, 1
            CASE CHR$(0) + "H"
                LOCATE 8 + selected, 54
                PRINT CHR$(16)
                LOCATE 8 + selected, 45
                PRINT CHR$(17)
                selected = selected - 1
                IF selected < 0 THEN selected = 5
                COLOR 6, 1
                LOCATE 8 + selected, 54
                PRINT CHR$(16)
                LOCATE 8 + selected, 45
                PRINT CHR$(17)
                COLOR 15, 1
            CASE CHR$(0) + "K"
                ChangeValue selected, k$
            CASE CHR$(0) + "M"
                ChangeValue selected, k$
            CASE CHR$(13)
                r = 0
                isStart = 0
                GOTO START
            CASE "r", "R"
                IF isStart = 0 THEN
                    r = 1
                    GOTO START
                END IF
        END SELECT
    WEND

    START:
    IF r = 0 THEN
        sBall = 1
        FOR i% = 1 TO nBall
            balls(i%).X = Rand(1, gw)
            balls(i%).Y = Rand(1, gh)
            balls(i%).U = Rand(1, 500) / 100 - 3
            balls(i%).V = Rand(1, 500) / 100 - 3
        NEXT
    END IF
END SUB
