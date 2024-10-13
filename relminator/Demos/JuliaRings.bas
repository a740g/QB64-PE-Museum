' The Lord of the Julia Rings
' The Fellowship of the Julia Ring
' Free Basic
' Relsoft
' Rel.BetterWebber.com
' Converted to QB64 format by Galleon
' Optimized for QB64-PE by a740g

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST FALSE = 0, TRUE = NOT FALSE
CONST SCR_SCALE = 3
CONST SCR_WIDTH = 320 * SCR_SCALE
CONST SCR_HEIGHT = 200 * SCR_SCALE
CONST SCR_MAXX = SCR_WIDTH - 1
CONST SCR_MAXY = SCR_HEIGHT - 1
CONST SCR_MIDX = SCR_WIDTH \ 2
CONST SCR_MIDY = SCR_HEIGHT \ 2
CONST MAXITER = 20
CONST MAXSIZE = 4
CONST XMIN! = -1! * 2.0!
CONST XMAX! = 2.0!
CONST YMIN! = -1! * 1.5!
CONST YMAX! = 1.5!
CONST DELTAX! = (XMAX - XMIN) / SCR_MAXX
CONST DELTAY! = (YMAX - YMIN) / SCR_MAXY

$RESIZE:SMOOTH
SCREEN _NEWIMAGE(SCR_WIDTH, SCR_HEIGHT, 32)
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH
_TITLE "QB64-PE Julia (Relsoft)"

DIM px AS LONG, py AS LONG
DIM p AS SINGLE, q AS SINGLE
DIM theta AS SINGLE
DIM x AS SINGLE, y AS SINGLE
DIM xsquare AS SINGLE, ysquare AS SINGLE
DIM ytemp AS SINGLE
DIM i AS LONG, pixel AS LONG
DIM frame AS _UNSIGNED LONG
DIM ty AS SINGLE
DIM red AS LONG, grn AS LONG, blu AS LONG
DIM tmp AS LONG, i_last AS LONG
DIM cmag AS SINGLE
DIM cmagsq AS SINGLE
DIM zmag AS SINGLE
DIM drad AS SINGLE
DIM ztot AS SINGLE
DIM drad_l AS SINGLE, drad_h AS SINGLE
DIM lx(0 TO SCR_MAXX) AS SINGLE, ly(0 TO SCR_MAXY) AS SINGLE

FOR i = 0 TO SCR_MAXX
    lx(i) = XMIN + i * DELTAX
NEXT i

FOR i = 0 TO SCR_MAXY
    ly(i) = YMAX - i * DELTAY
NEXT i

DIM stime AS LONG, fps AS SINGLE, fps2 AS SINGLE

stime = TIMER

DO
    frame = (frame + 1) AND &H7FFFFFFF
    theta = frame * _PI(0.01!)

    p = COS(theta) * SIN(theta * 0.7!) * 0.6!
    q = (SIN(theta) + SIN(theta)) * 0.6!
    cmagsq = p * p + q * q
    cmag = SQR(cmagsq)
    drad = 0.04!
    drad_l = (cmag - drad) * (cmag - drad)
    drad_h = (cmag + drad) * (cmag + drad)

    FOR py = 0 TO SCR_MIDY - 1
        ty = ly(py)
        FOR px = 0 TO SCR_MAXX
            x = lx(px)
            y = ty
            xsquare = 0!
            ysquare = 0!
            ztot = 0!
            i = 0
            i_last = 0

            WHILE (i < MAXITER) _ANDALSO ((xsquare + ysquare) < MAXSIZE)
                xsquare = x * x
                ysquare = y * y
                ytemp = 2! * x * y
                x = xsquare - ysquare + p
                y = ytemp + q
                zmag = x * x + y * y

                IF zmag < drad_h _ANDALSO zmag > drad_l _ANDALSO i > 0 THEN
                    ztot = ztot + (1! - (ABS(zmag - cmagsq) / drad))
                    i_last = i
                END IF

                i = i + 1

                IF zmag > 4.0! THEN EXIT WHILE
            WEND

            IF ztot > 0! THEN
                i = SQR(ztot) * 500!
            ELSE
                i = 0
            END IF

            IF i < 256 THEN
                red = i
            ELSE
                red = 255
            END IF

            IF i >= 256 _ANDALSO i < 512 THEN
                grn = i - 256
            ELSEIF i >= 512 THEN
                grn = 255
            ELSE
                grn = 0
            END IF

            IF i >= 512 _ANDALSO i <= 768 THEN
                blu = i - 512
            ELSEIF i > 768 THEN
                blu = 255
            ELSE
                blu = 0
            END IF

            tmp = ((red + grn + blu) \ 3)
            red = ((red + grn + tmp) \ 3)
            grn = ((grn + blu + tmp) \ 3)
            blu = ((blu + red + tmp) \ 3)

            tmp = red
            SELECT CASE (i_last MOD 3)
                CASE 1
                    red = grn: grn = blu: blu = tmp
                CASE 2
                    red = blu: blu = grn: grn = tmp
            END SELECT

            pixel = _RGB32(red, grn, blu)
            PSET (px, py), pixel
            PSET (SCR_MAXX - px, SCR_MAXY - py), pixel
        NEXT px
    NEXT py

    fps = fps + 1
    IF stime + 1 < TIMER THEN
        fps2 = fps
        fps = 0
        stime = TIMER
    END IF

    LOCATE 1, 1: PRINT "FPS:" + STR$(fps2);

    _DISPLAY

    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

SYSTEM
