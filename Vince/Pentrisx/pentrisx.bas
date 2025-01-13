RANDOMIZE TIMER

DIM SHARED piece(17, 2, 4)
DIM SHARED piece_color(17)
DIM SHARED size, sw, sh

'big x and y
DIM SHARED xx, yy

size = 25
sw = 12
sh = 25

REDIM SHARED board(sw - 1, sh - 1)

piece(0, 0, 0) = 0: piece(0, 1, 0) = 1: piece(0, 2, 0) = 0
piece(0, 0, 1) = 0: piece(0, 1, 1) = 1: piece(0, 2, 1) = 0
piece(0, 0, 2) = 0: piece(0, 1, 2) = 1: piece(0, 2, 2) = 0
piece(0, 0, 3) = 0: piece(0, 1, 3) = 1: piece(0, 2, 3) = 0
piece(0, 0, 4) = 0: piece(0, 1, 4) = 1: piece(0, 2, 4) = 0

piece(1, 0, 0) = 0: piece(1, 1, 0) = 0: piece(1, 2, 0) = 0
piece(1, 0, 1) = 0: piece(1, 1, 1) = 0: piece(1, 2, 1) = 0
piece(1, 0, 2) = 0: piece(1, 1, 2) = 1: piece(1, 2, 2) = 1
piece(1, 0, 3) = 1: piece(1, 1, 3) = 1: piece(1, 2, 3) = 0
piece(1, 0, 4) = 0: piece(1, 1, 4) = 1: piece(1, 2, 4) = 0

piece(2, 0, 0) = 0: piece(2, 1, 0) = 0: piece(2, 2, 0) = 0
piece(2, 0, 1) = 0: piece(2, 1, 1) = 0: piece(2, 2, 1) = 0
piece(2, 0, 2) = 1: piece(2, 1, 2) = 1: piece(2, 2, 2) = 0
piece(2, 0, 3) = 0: piece(2, 1, 3) = 1: piece(2, 2, 3) = 1
piece(2, 0, 4) = 0: piece(2, 1, 4) = 1: piece(2, 2, 4) = 0

piece(3, 0, 0) = 0: piece(3, 1, 0) = 0: piece(3, 2, 0) = 0
piece(3, 0, 1) = 0: piece(3, 1, 1) = 1: piece(3, 2, 1) = 0
piece(3, 0, 2) = 0: piece(3, 1, 2) = 1: piece(3, 2, 2) = 0
piece(3, 0, 3) = 0: piece(3, 1, 3) = 1: piece(3, 2, 3) = 0
piece(3, 0, 4) = 1: piece(3, 1, 4) = 1: piece(3, 2, 4) = 0

piece(4, 0, 0) = 0: piece(4, 1, 0) = 0: piece(4, 2, 0) = 0
piece(4, 0, 1) = 0: piece(4, 1, 1) = 1: piece(4, 2, 1) = 0
piece(4, 0, 2) = 0: piece(4, 1, 2) = 1: piece(4, 2, 2) = 0
piece(4, 0, 3) = 0: piece(4, 1, 3) = 1: piece(4, 2, 3) = 0
piece(4, 0, 4) = 0: piece(4, 1, 4) = 1: piece(4, 2, 4) = 1

piece(5, 0, 0) = 0: piece(5, 1, 0) = 0: piece(5, 2, 0) = 0
piece(5, 0, 1) = 0: piece(5, 1, 1) = 0: piece(5, 2, 1) = 0
piece(5, 0, 2) = 1: piece(5, 1, 2) = 1: piece(5, 2, 2) = 0
piece(5, 0, 3) = 1: piece(5, 1, 3) = 1: piece(5, 2, 3) = 0
piece(5, 0, 4) = 0: piece(5, 1, 4) = 1: piece(5, 2, 4) = 0

piece(6, 0, 0) = 0: piece(6, 1, 0) = 0: piece(6, 2, 0) = 0
piece(6, 0, 1) = 0: piece(6, 1, 1) = 0: piece(6, 2, 1) = 0
piece(6, 0, 2) = 0: piece(6, 1, 2) = 1: piece(6, 2, 2) = 1
piece(6, 0, 3) = 0: piece(6, 1, 3) = 1: piece(6, 2, 3) = 1
piece(6, 0, 4) = 0: piece(6, 1, 4) = 1: piece(6, 2, 4) = 0

piece(7, 0, 0) = 0: piece(7, 1, 0) = 0: piece(7, 2, 0) = 0
piece(7, 0, 1) = 0: piece(7, 1, 1) = 1: piece(7, 2, 1) = 0
piece(7, 0, 2) = 0: piece(7, 1, 2) = 1: piece(7, 2, 2) = 0
piece(7, 0, 3) = 1: piece(7, 1, 3) = 1: piece(7, 2, 3) = 0
piece(7, 0, 4) = 1: piece(7, 1, 4) = 0: piece(7, 2, 4) = 0

piece(8, 0, 0) = 0: piece(8, 1, 0) = 0: piece(8, 2, 0) = 0
piece(8, 0, 1) = 0: piece(8, 1, 1) = 1: piece(8, 2, 1) = 0
piece(8, 0, 2) = 0: piece(8, 1, 2) = 1: piece(8, 2, 2) = 0
piece(8, 0, 3) = 0: piece(8, 1, 3) = 1: piece(8, 2, 3) = 1
piece(8, 0, 4) = 0: piece(8, 1, 4) = 0: piece(8, 2, 4) = 1

piece(9, 0, 0) = 0: piece(9, 1, 0) = 0: piece(9, 2, 0) = 0
piece(9, 0, 1) = 0: piece(9, 1, 1) = 0: piece(9, 2, 1) = 0
piece(9, 0, 2) = 1: piece(9, 1, 2) = 1: piece(9, 2, 2) = 1
piece(9, 0, 3) = 0: piece(9, 1, 3) = 1: piece(9, 2, 3) = 0
piece(9, 0, 4) = 0: piece(9, 1, 4) = 1: piece(9, 2, 4) = 0

piece(10, 0, 0) = 0: piece(10, 1, 0) = 0: piece(10, 2, 0) = 0
piece(10, 0, 1) = 0: piece(10, 1, 1) = 0: piece(10, 2, 1) = 0
piece(10, 0, 2) = 0: piece(10, 1, 2) = 0: piece(10, 2, 2) = 0
piece(10, 0, 3) = 1: piece(10, 1, 3) = 0: piece(10, 2, 3) = 1
piece(10, 0, 4) = 1: piece(10, 1, 4) = 1: piece(10, 2, 4) = 1

piece(11, 0, 0) = 0: piece(11, 1, 0) = 0: piece(11, 2, 0) = 0
piece(11, 0, 1) = 0: piece(11, 1, 1) = 0: piece(11, 2, 1) = 0
piece(11, 0, 2) = 0: piece(11, 1, 2) = 0: piece(11, 2, 2) = 1
piece(11, 0, 3) = 0: piece(11, 1, 3) = 0: piece(11, 2, 3) = 1
piece(11, 0, 4) = 1: piece(11, 1, 4) = 1: piece(11, 2, 4) = 1

piece(12, 0, 0) = 0: piece(12, 1, 0) = 0: piece(12, 2, 0) = 0
piece(12, 0, 1) = 0: piece(12, 1, 1) = 0: piece(12, 2, 1) = 0
piece(12, 0, 2) = 0: piece(12, 1, 2) = 0: piece(12, 2, 2) = 1
piece(12, 0, 3) = 0: piece(12, 1, 3) = 1: piece(12, 2, 3) = 1
piece(12, 0, 4) = 1: piece(12, 1, 4) = 1: piece(12, 2, 4) = 0

piece(13, 0, 0) = 0: piece(13, 1, 0) = 0: piece(13, 2, 0) = 0
piece(13, 0, 1) = 0: piece(13, 1, 1) = 0: piece(13, 2, 1) = 0
piece(13, 0, 2) = 0: piece(13, 1, 2) = 1: piece(13, 2, 2) = 0
piece(13, 0, 3) = 1: piece(13, 1, 3) = 1: piece(13, 2, 3) = 1
piece(13, 0, 4) = 0: piece(13, 1, 4) = 1: piece(13, 2, 4) = 0

piece(14, 0, 0) = 0: piece(14, 1, 0) = 0: piece(14, 2, 0) = 0
piece(14, 0, 1) = 0: piece(14, 1, 1) = 1: piece(14, 2, 1) = 0
piece(14, 0, 2) = 1: piece(14, 1, 2) = 1: piece(14, 2, 2) = 0
piece(14, 0, 3) = 0: piece(14, 1, 3) = 1: piece(14, 2, 3) = 0
piece(14, 0, 4) = 0: piece(14, 1, 4) = 1: piece(14, 2, 4) = 0

piece(15, 0, 0) = 0: piece(15, 1, 0) = 0: piece(15, 2, 0) = 0
piece(15, 0, 1) = 0: piece(15, 1, 1) = 1: piece(15, 2, 1) = 0
piece(15, 0, 2) = 0: piece(15, 1, 2) = 1: piece(15, 2, 2) = 1
piece(15, 0, 3) = 0: piece(15, 1, 3) = 1: piece(15, 2, 3) = 0
piece(15, 0, 4) = 0: piece(15, 1, 4) = 1: piece(15, 2, 4) = 0

piece(16, 0, 0) = 0: piece(16, 1, 0) = 0: piece(16, 2, 0) = 0
piece(16, 0, 1) = 0: piece(16, 1, 1) = 0: piece(16, 2, 1) = 0
piece(16, 0, 2) = 0: piece(16, 1, 2) = 1: piece(16, 2, 2) = 1
piece(16, 0, 3) = 0: piece(16, 1, 3) = 1: piece(16, 2, 3) = 0
piece(16, 0, 4) = 1: piece(16, 1, 4) = 1: piece(16, 2, 4) = 0

piece(17, 0, 0) = 0: piece(17, 1, 0) = 0: piece(17, 2, 0) = 0
piece(17, 0, 1) = 0: piece(17, 1, 1) = 0: piece(17, 2, 1) = 0
piece(17, 0, 2) = 1: piece(17, 1, 2) = 1: piece(17, 2, 2) = 0
piece(17, 0, 3) = 0: piece(17, 1, 3) = 1: piece(17, 2, 3) = 0
piece(17, 0, 4) = 0: piece(17, 1, 4) = 1: piece(17, 2, 4) = 1

SCREEN _NEWIMAGE(sw * size, sh * size, 32)

piece_color(0) = _RGB(255, 0, 0)
piece_color(1) = _RGB(255, 145, 0)
piece_color(2) = _RGB(255, 200, 211)
piece_color(3) = _RGB(0, 255, 220)
piece_color(4) = _RGB(0, 230, 255)
piece_color(5) = _RGB(0, 170, 10)
piece_color(6) = _RGB(0, 250, 20)
piece_color(7) = _RGB(128, 230, 0)
piece_color(8) = _RGB(80, 150, 0)
piece_color(9) = _RGB(0, 200, 0)
piece_color(10) = _RGB(50, 160, 170)
piece_color(11) = _RGB(50, 110, 175)
piece_color(12) = _RGB(50, 50, 175)
piece_color(13) = _RGB(110, 50, 175)
piece_color(14) = _RGB(210, 0, 255)
piece_color(15) = _RGB(110, 0, 130)
piece_color(16) = _RGB(255, 0, 140)
piece_color(17) = _RGB(170, 0, 100)

DIM t AS DOUBLE
 

redraw = -1

speed = 3
lines = 0
pause = 0
putpiece = 0
startx = (sw - 4) / 2

pn = INT(RND * 18)
px = startx
py = -2
rot = 0

DIM title$
title$ = "lines=" + LTRIM$(STR$(lines)) + ",speed=" + LTRIM$(STR$(speed))
_TITLE title$

t = TIMER


DIM mb_state, ox, oy
mb_state = 0
ox = 0
oy = 0


DO
    IF _RESIZE THEN
        size = (_RESIZEHEIGHT - 20) / sh
        SCREEN _NEWIMAGE(sw * size, sh * size, 32)
        redraw = -1
    END IF


    IF (TIMER - t) > (1 / speed) AND NOT pause THEN
        IF valid(pn, px, py + 1, rot) THEN py = py + 1 ELSE putpiece = 1

        t = TIMER
        redraw = -1
    END IF

    IF putpiece THEN
        IF valid(pn, px, py, rot) THEN
            n = place(pn, px, py, rot)
            IF n THEN
                lines = lines + n
                title$ = "lines=" + LTRIM$(STR$(lines)) + ",speed=" + LTRIM$(STR$(speed))
                _TITLE title$
            END IF
        END IF

        pn = INT(RND * 18)
        px = startx
        py = -2
        rot = 0

        putpiece = 0
        redraw = -1

        IF NOT valid(pn, px, py, rot) THEN
            FOR y = 0 TO sh - 1
                FOR x = 0 TO sw - 1
                    board(x, y) = 0
                NEXT
            NEXT
            lines = 0
            title$ = "lines=" + LTRIM$(STR$(lines)) + ",speed=" + LTRIM$(STR$(speed))
            _TITLE title$
        END IF
    END IF

    IF redraw THEN
        LINE (0, 0)-(sw * size, sh * size), _RGB(0, 0, 0), BF
        FOR y = 0 TO sh - 1
            FOR x = 0 TO sw - 1
                IF board(x, y) <> 0 THEN
                    LINE (x * size, y * size)-STEP(size - 2, size - 2), piece_color(board(x, y) - 1), BF
                ELSE
                    LINE (x * size, y * size)-STEP(size - 2, size - 2), _RGB(50, 50, 50), B
                END IF
            NEXT
        NEXT

        FOR y = 0 TO 4
            FOR x = 0 TO 2
                rotate x, y, pn, rot
                IF piece(pn, x, y) THEN LINE ((px + xx) * size, (py + yy) * size)-STEP(size - 2, size - 2), piece_color(pn), BF
            NEXT
        NEXT


        LOCATE 1, 1
        COLOR _RGB(88, 88, 88)
        PRINT title$

        _DISPLAY
        redraw = 0
    END IF

    'mouse state
    k = _KEYHIT 'override keyboard
    shift = _KEYDOWN(100304) OR _KEYDOWN(100303)

    mx = _MOUSEX
    my = _MOUSEY
    mb = _MOUSEBUTTON(1)
    IF mb AND mb_state = 0 THEN
        mb_state = -1
        ox = mx
        oy = my
    END IF
    IF mb AND mb_state THEN
        a = atan2(my - oy, mx - ox)
        r = sw * size / 4
        dist = SQR((my - oy) ^ 2 + (mx - ox) ^ 2)

        CIRCLE (sw * size / 2, sh * size / 2), r, rgb(255, 255, 0)
        'if dist > 2.5*r then
        '    line -step(r*cos(a), r*sin(a)), rgb(255,0,0)
        IF dist > r / 2 THEN

            aa = a
            IF a >= -pi / 4 AND a < pi / 4 THEN aa = 0
            IF a >= -pi AND a < -3 * pi / 4 THEN aa = pi
            IF a <= pi AND a > 3 * pi / 4 THEN aa = pi
            IF a >= -3 * pi / 4 AND a < -pi / 4 THEN aa = -pi / 2
            IF a <= 3 * pi / 4 AND a >= pi / 4 THEN aa = pi / 2

            IF dist > r * 2 THEN c = rgb(255, 0, 0) ELSE c = rgb(255, 255, 0)

            LINE -STEP(r * COS(aa), r * SIN(aa)), c
        END IF
    END IF
    IF mb = 0 AND mb_state THEN
        IF a >= -pi / 4 AND a < pi / 4 THEN k = 19712 'right
        IF a >= -pi AND a < -3 * pi / 4 THEN k = 19200 'left
        IF a <= pi AND a > 3 * pi / 4 THEN k = 19200 'left
        IF a >= -3 * pi / 4 AND a < -pi / 4 THEN k = 18432 'up
        IF a <= 3 * pi / 4 AND a >= pi / 4 THEN k = 20480 'down

        IF dist > r * 2 THEN shift = -1 ELSE shift = 0

        mb_state = 0
        redraw = -1
    END IF
    '''

    'keyboard
    'k = _keyhit
    IF k THEN
        'shift = _keydown(100304) or _keydown(100303)
        SELECT CASE k
            CASE 18432 'up
                IF valid(pn, px, py, (rot + 1) MOD 4) THEN rot = (rot + 1) MOD 4
                pause = 0
            CASE 19200 'left
                IF shift THEN
                    FOR x2 = 0 TO sw - 1
                        IF NOT valid(pn, px - x2, py, rot) THEN EXIT FOR
                    NEXT
                    px = px - x2 + 1
                ELSE
                    IF valid(pn, px - 1, py, rot) THEN px = px - 1
                END IF
                pause = 0
            CASE 19712 'right
                IF shift THEN
                    FOR x2 = px TO sw - 1
                        IF NOT valid(pn, x2, py, rot) THEN EXIT FOR
                    NEXT
                    px = x2 - 1
                ELSE
                    IF valid(pn, px + 1, py, rot) THEN px = px + 1
                END IF
                pause = 0
            CASE 20480, 32 'down
                IF shift OR k = 32 THEN
                    FOR y2 = py TO sh - 1
                        IF NOT valid(pn, px, y2, rot) THEN EXIT FOR
                    NEXT
                    py = y2 - 1
                    putpiece = -1
                ELSE
                    IF valid(pn, px, py + 1, rot) THEN py = py + 1
                END IF
                pause = 0
            CASE 112 'p
                pause = NOT pause
            CASE 13 'enter
                FOR y = 0 TO sh - 1
                    FOR x = 0 TO sw - 1
                        board(x, y) = 0
                    NEXT
                NEXT
                pn = INT(RND * 18)
                px = startx
                py = -2
                rot = 0
                putpiece = 0
                lines = 0
                title$ = "lines=" + LTRIM$(STR$(lines)) + ",speed=" + LTRIM$(STR$(speed))
                _TITLE title$
            CASE 43, 61 'plus
                IF speed < 100 THEN
                    speed = speed + 1
                    title$ = "lines=" + LTRIM$(STR$(lines)) + ",speed=" + LTRIM$(STR$(speed))
                    _TITLE title$
                END IF
            CASE 95, 45
                IF speed > 1 THEN
                    speed = speed - 1
                    title$ = "lines=" + LTRIM$(STR$(lines)) + ",speed=" + LTRIM$(STR$(speed))
                    _TITLE title$
                END IF
            CASE 27
                EXIT DO
        END SELECT

        redraw = -1
    END IF
    
    _LIMIT 60
LOOP
SYSTEM

SUB rotate (x, y, pn, rot)
    SELECT CASE pn
        CASE 0
            rot_new = rot MOD 2
        CASE ELSE
            rot_new = rot
    END SELECT

    SELECT CASE rot_new
        CASE 0
            xx = x
            yy = y
        CASE 1
            IF pn = 0 THEN
                xx = y - 1
                yy = 3 - x
            ELSEIF pn = 14 OR pn = 15 THEN
                xx = y - 1
                yy = 3 - x
            ELSE
                xx = y - 2
                yy = 4 - x
            END IF
        CASE 2
            IF pn = 14 OR pn = 15 THEN
                xx = 2 - x
                yy = 4 - y
            ELSE
                xx = 2 - x
                yy = 6 - y
            END IF
        CASE 3
            IF pn = 14 OR pn = 15 THEN
                xx = 3 - y
                yy = x + 1
            ELSE
                xx = 4 - y
                yy = x + 2
            END IF
    END SELECT
END SUB

FUNCTION valid (pn, px, py, rot)
    FOR y = 0 TO 4
        FOR x = 0 TO 2
            rotate x, y, pn, rot
            IF py + yy >= 0 THEN
                IF piece(pn, x, y) THEN
                    IF (px + xx >= sw) OR (px + xx < 0) THEN
                        valid = 0
                        EXIT FUNCTION
                    END IF
                    IF (py + yy >= sh) THEN
                        valid = 0
                        EXIT FUNCTION
                    END IF
                    'if (py >= 0) then
                    IF board(px + xx, py + yy) THEN
                        valid = 0
                        EXIT FUNCTION
                    END IF
                    'end if
                END IF
            END IF
        NEXT
    NEXT
    valid = -1
END FUNCTION

FUNCTION place (pn, px, py, rot)
    lines2 = 0

    FOR y = 0 TO 4
        FOR x = 0 TO 2
            rotate x, y, pn, rot
            IF py + yy >= 0 THEN
                IF piece(pn, x, y) THEN board(px + xx, py + yy) = pn + 1
            END IF
        NEXT
    NEXT

    'clear lines
    FOR y = py - 5 TO py + 5
        IF y >= 0 AND y < sh THEN
            clr = -1
            FOR x = 0 TO sw - 1
                IF board(x, y) = 0 THEN
                    clr = 0
                    EXIT FOR
                END IF
            NEXT

            IF clr THEN
                lines2 = lines2 + 1
                FOR y2 = y TO 1 STEP -1
                    FOR x = 0 TO sw - 1
                        board(x, y2) = board(x, y2 - 1)
                    NEXT
                NEXT
            END IF
        END IF
    NEXT

    place = lines2
END FUNCTION
