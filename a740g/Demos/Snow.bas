' Snow demo - a740g
' C version - 2003
' QB64-PE port - 2024

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32

CONST MESSAGE = "Merry Christmas & Happy New Year!"
CONST SCREEN_WIDTH = 1280
CONST SCREEN_HEIGHT = 720
CONST NUMFLAKE = 10000

TYPE Particle
    x AS SINGLE
    y AS SINGLE
    c AS _UNSIGNED LONG
END TYPE

DIM p(1 TO NUMFLAKE) AS Particle
DIM bg AS _UNSIGNED LONG

DIM currentWind AS SINGLE: currentWind = 0!
DIM targetWind AS SINGLE: targetWind = 1.0!
DIM plowRadius AS LONG: plowRadius = 15

DIM prevMx AS LONG, prevMy AS LONG, prevMr AS LONG
DIM prevDrawCircle AS _BYTE: prevDrawCircle = _FALSE
DIM searchIndex AS LONG: searchIndex = 1

RANDOMIZE TIMER

SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, 32)
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH
_TITLE MESSAGE

bg = Black
CLS

DIM i AS LONG
DIM shade AS LONG

FOR i = 1 TO NUMFLAKE
    p(i).x = RND * SCREEN_WIDTH
    p(i).y = RND * SCREEN_HEIGHT
    shade = 192 + INT(RND * 64)
    p(i).c = _RGB32(shade)
NEXT i

_KEYCLEAR

DIM mCurX AS LONG
DIM mCurY AS LONG

DO
    WHILE _MOUSEINPUT
        mCurX = _MOUSEX
        mCurY = _MOUSEY
        plowRadius = _CLAMP(plowRadius + _MOUSEWHEEL, 5, 100)
    WEND

    IF RND < 0.05! THEN
        IF RND < 0.05! THEN
            targetWind = (RND * 6!) - 3!
        ELSE
            targetWind = _CLAMP(targetWind + (RND * 2! - 1!), -3!, 3!)
        END IF
    END IF
    currentWind = currentWind + (targetWind - currentWind) * 0.02!

    FOR i = 1 TO NUMFLAKE
        DIM ex AS LONG: ex = INT(p(i).x)
        DIM ey AS LONG: ey = INT(p(i).y)
        IF ey >= 0 _ANDALSO ey < SCREEN_HEIGHT _ANDALSO ex >= 0 _ANDALSO ex < SCREEN_WIDTH THEN
            PSET (ex, ey), bg
        END IF
    NEXT i

    IF prevDrawCircle THEN CIRCLE (prevMx, prevMy), prevMr, bg

    DrawNeonText
    DrawTree

    FOR i = 1 TO NUMFLAKE
        DIM oy AS LONG: oy = INT(p(i).y)
        DIM ox AS LONG: ox = INT(p(i).x)
        DIM settled AS _BYTE: settled = _FALSE

        IF _MOUSEBUTTON(1) _ORELSE _MOUSEBUTTON(2) THEN
            DIM mDx AS SINGLE: mDx = p(i).x - mCurX
            DIM mDy AS SINGLE: mDy = p(i).y - mCurY
            DIM distSq AS SINGLE: distSq = mDx * mDx + mDy * mDy

            IF distSq < (plowRadius * plowRadius * 2) _ANDALSO distSq > 0 THEN
                DIM dist AS SINGLE: dist = SQR(distSq)
                DIM force AS SINGLE: force = _MAX(0, ((plowRadius * 1.5!) - dist) / 5!)
                p(i).x = p(i).x + (mDx / dist) * force
                p(i).y = p(i).y + (mDy / dist) * force
            END IF
        END IF

        p(i).x = p(i).x + currentWind
        DIM speedVar AS SINGLE: speedVar = (p(i).c AND 3) * 0.25!
        p(i).y = p(i).y + 1 + speedVar

        IF p(i).x < 0 THEN p(i).x = p(i).x + SCREEN_WIDTH
        IF p(i).x >= SCREEN_WIDTH THEN p(i).x = p(i).x - SCREEN_WIDTH

        DIM tx AS LONG: tx = INT(p(i).x)
        DIM ty AS LONG: ty = INT(p(i).y)

        IF ty >= 0 _ANDALSO ty < SCREEN_HEIGHT THEN
            IF POINT(tx, ty) <> bg THEN
                IF POINT(ox, ty) = bg THEN
                    p(i).x = ox
                    tx = ox
                ELSE
                    DIM drift AS LONG: drift = _IIF(currentWind >= 0, 1, -1)

                    DIM dx AS LONG: dx = ox + drift
                    IF dx < 0 THEN dx = dx + SCREEN_WIDTH
                    IF dx >= SCREEN_WIDTH THEN dx = dx - SCREEN_WIDTH

                    IF POINT(dx, ty) = bg THEN
                        p(i).x = dx
                        tx = dx
                    ELSE
                        dx = ox - drift
                        IF dx < 0 THEN dx = dx + SCREEN_WIDTH
                        IF dx >= SCREEN_WIDTH THEN dx = dx - SCREEN_WIDTH
                        IF POINT(dx, ty) = bg THEN
                            p(i).x = dx
                            tx = dx
                        ELSE
                            p(i).y = oy
                            ty = oy
                            p(i).x = ox
                            tx = ox
                            settled = _TRUE
                        END IF
                    END IF
                END IF
            END IF
        ELSEIF ty >= SCREEN_HEIGHT THEN
            ty = SCREEN_HEIGHT - 1
            p(i).y = ty
            p(i).x = ox
            tx = ox
            settled = _TRUE
        END IF

        IF settled THEN
            IF ty >= 0 _ANDALSO ty < SCREEN_HEIGHT _ANDALSO tx >= 0 _ANDALSO tx < SCREEN_WIDTH THEN PSET (tx, ty), p(i).c
            p(i).x = RND * SCREEN_WIDTH
            p(i).y = -(RND * 50!) - 10!
            shade = 128 + INT(RND * 128)
            p(i).c = _RGB32(shade)
        END IF
    NEXT i

    FOR i = 1 TO NUMFLAKE
        DIM px AS LONG: px = INT(p(i).x)
        DIM py AS LONG: py = INT(p(i).y)
        IF py >= 0 _ANDALSO py < SCREEN_HEIGHT _ANDALSO px >= 0 _ANDALSO px < SCREEN_WIDTH THEN
            PSET (px, py), p(i).c
        END IF
    NEXT i

    IF _MOUSEBUTTON(1) _ORELSE _MOUSEBUTTON(2) THEN
        CIRCLE (mCurX, mCurY), plowRadius, SteelBlue
        prevMx = mCurX
        prevMy = mCurY
        prevMr = plowRadius
        prevDrawCircle = _TRUE

        DIM startY AS LONG: startY = _MAX(0, mCurY - plowRadius)
        DIM endY AS LONG: endY = _MIN(SCREEN_HEIGHT - 1, mCurY + plowRadius)
        DIM startX AS LONG: startX = _MAX(0, mCurX - plowRadius)
        DIM endX AS LONG: endX = _MIN(SCREEN_WIDTH - 1, mCurX + plowRadius)

        DIM bY AS LONG, bX AS LONG
        FOR bY = startY TO endY
            FOR bX = startX TO endX
                IF (bX - mCurX) * (bX - mCurX) + (bY - mCurY) * (bY - mCurY) <= plowRadius * plowRadius THEN
                    DIM ptCol AS _UNSIGNED LONG: ptCol = POINT(bX, bY)
                    IF ptCol <> bg THEN
                        DIM cR AS LONG: cR = _RED32(ptCol)
                        DIM cG AS LONG: cG = _GREEN32(ptCol)
                        DIM cB AS LONG: cB = _BLUE32(ptCol)

                        IF cR = cG _ANDALSO cG = cB THEN
                            PSET (bX, bY), bg

                            DIM tries AS LONG: tries = 0
                            DO WHILE tries < 5
                                searchIndex = searchIndex + 1
                                IF searchIndex > NUMFLAKE THEN searchIndex = 1

                                IF p(searchIndex).y < 0 THEN
                                    p(searchIndex).x = bX + (RND * 4 - 2)
                                    p(searchIndex).y = bY - 2 - (RND * 5)
                                    EXIT DO
                                END IF
                                tries = tries + 1
                            LOOP
                        END IF
                    END IF
                END IF
            NEXT bX
        NEXT bY
    ELSE
        prevDrawCircle = _FALSE
    END IF

    IF ABS(currentWind) > 1.2! THEN
        DIM w AS LONG
        FOR w = 1 TO 30
            DIM rx AS LONG: rx = INT(RND * SCREEN_WIDTH)
            DIM ry AS LONG: ry = INT(RND * SCREEN_HEIGHT)

            DIM wCol AS _UNSIGNED LONG: wCol = POINT(rx, ry)
            IF wCol <> bg THEN
                IF _RED32(wCol) = _GREEN32(wCol) _ANDALSO _GREEN32(wCol) = _BLUE32(wCol) THEN
                    IF ry > 0 THEN
                        IF POINT(rx, ry - 1) = bg THEN
                            PSET (rx, ry), bg

                            DIM triesW AS LONG: triesW = 0
                            DO WHILE triesW < 10
                                searchIndex = searchIndex + 1
                                IF searchIndex > NUMFLAKE THEN searchIndex = 1
                                IF p(searchIndex).y < 0 THEN
                                    p(searchIndex).x = rx
                                    p(searchIndex).y = ry - 1
                                    EXIT DO
                                END IF
                                triesW = triesW + 1
                            LOOP
                        END IF
                    END IF
                END IF
            END IF
        NEXT w
    END IF

    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYHIT = _KEY_ESC

SYSTEM

SUB DrawNeonText
    DIM msgX AS LONG: msgX = SCREEN_WIDTH \ 2 - _PRINTWIDTH(MESSAGE) \ 2
    DIM msgY AS LONG: msgY = SCREEN_HEIGHT \ 2 - _FONTHEIGHT \ 2
    DIM gx AS LONG, gy AS LONG

    COLOR Blue, 0
    FOR gx = -2 TO 2
        FOR gy = -2 TO 2
            _PRINTSTRING (msgX + gx, msgY + gy), MESSAGE
        NEXT gy
    NEXT gx

    COLOR DodgerBlue, 0
    FOR gx = -1 TO 1
        FOR gy = -1 TO 1
            _PRINTSTRING (msgX + gx, msgY + gy), MESSAGE
        NEXT gy
    NEXT gx

    COLOR AliceBlue, 0
    _PRINTSTRING (msgX, msgY), MESSAGE
END SUB

SUB DrawTree
    DIM cx AS LONG: cx = SCREEN_WIDTH \ 2
    DIM bottom AS LONG: bottom = SCREEN_HEIGHT - 1

    LINE (cx - 15, bottom - 50)-(cx + 15, bottom), SaddleBrown, BF

    DrawTreeTriangle cx, bottom - 20, bottom - 130, 100, DarkGreen
    DrawTreeTriangle cx, bottom - 80, bottom - 180, 80, Green
    DrawTreeTriangle cx, bottom - 140, bottom - 240, 60, ForestGreen

    LINE (cx - 3, bottom - 245)-(cx + 3, bottom - 239), Gold, BF
    LINE (cx - 6, bottom - 243)-(cx + 6, bottom - 241), Gold, BF
    LINE (cx - 1, bottom - 248)-(cx + 1, bottom - 236), Gold, BF

    DrawOrnament cx - 30, bottom - 50, Red
    DrawOrnament cx + 40, bottom - 60, Gold
    DrawOrnament cx - 20, bottom - 100, DeepSkyBlue
    DrawOrnament cx + 30, bottom - 130, Red
    DrawOrnament cx, bottom - 160, Magenta
    DrawOrnament cx - 15, bottom - 200, Gold
END SUB

SUB DrawTreeTriangle (cx AS LONG, bottomY AS LONG, topY AS LONG, halfW AS LONG, c AS _UNSIGNED LONG)
    DIM y AS LONG
    DIM h AS SINGLE: h = bottomY - topY
    IF h <= 0 THEN EXIT SUB

    FOR y = bottomY TO topY STEP -1
        DIM w AS LONG: w = INT(halfW * ((y - topY) / h))
        LINE (cx - w, y)-(cx + w, y), c
    NEXT y
END SUB

SUB DrawOrnament (cx AS LONG, cy AS LONG, c AS _UNSIGNED LONG)
    LINE (cx - 3, cy - 3)-(cx + 3, cy + 3), c, BF
END SUB
