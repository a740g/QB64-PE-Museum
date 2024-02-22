DIM grid(32, 20, 5) AS INTEGER
'(x, y, [Gcost, Hcost, Fcost, Opened/Block, parent])
DIM done AS INTEGER
DIM startX, startY, endX, endY AS INTEGER
DIM colors(5) AS INTEGER

colors(0) = 0: colors(1) = 2: colors(2) = 4: colors(3) = 15: colors(4) = 14

SCREEN 7
'$ExeIcon:'C:\Users\ondra\Documents\Programming\bas\astar.ico'
_ICON
_TITLE "A* Algorithm"
_FULLSCREEN

COLOR 10
PRINT: PRINT: PRINT
PRINT "          Input starting cords"
INPUT "                ", startX, startY
PRINT "         Input finishing cords"
INPUT "                ", endX, endY

IF startX > 31 OR startX < 0 THEN
    startX = 0
END IF
IF startY > 19 OR startY < 0 THEN
    startY = 0
END IF
IF endX > 31 OR endX < 0 THEN
    endX = 31
END IF
IF endY > 19 OR endY < 0 THEN
    endY = 19
END IF

CLS
done = 0

FOR X = 0 TO 32: FOR Y = 0 TO 20
        LINE (X * 10, Y * 10)-((X + 1) * 10, (Y + 1) * 10), 15, B
NEXT: NEXT
LINE (startX * 10 + 3, startY * 10 + 3)-(startX * 10 + 7, startY * 10 + 7), 14, BF
LINE (endX * 10 + 3, endY * 10 + 3)-(endX * 10 + 7, endY * 10 + 7), 9, BF

DO
    DO WHILE _MOUSEINPUT AND _MOUSEBUTTON(1) = -1
        X = INT(_MOUSEX / 10)
        Y = INT(_MOUSEY / 10)
        IF NOT X + Y * 100 = startX + startY * 100 AND NOT X + Y * 100 = endX + endY * 100 THEN
            grid(X, Y, 3) = 3
            LINE (X * 10, Y * 10)-((X + 1) * 10, (Y + 1) * 10), colors(grid(X, Y, 3)), BF
        END IF
    LOOP
    pause .5
LOOP UNTIL INKEY$ <> ""

grid(startX, startY, 3) = 1
grid(startX, startY, 1) = getHCost(startX, startY, endX, endY)
grid(startX, startY, 2) = 0

DO
    bestValue = 9999999
    bestX = -1: bestY = -1

    done = done * 2

    FOR X = 0 TO 31
        FOR Y = 0 TO 19
            IF grid(X, Y, 3) = 1 AND grid(X, Y, 2) < bestValue THEN
                bestValue = grid(X, Y, 2)
                bestX = X: bestY = Y

            END IF
            LINE (X * 10, Y * 10)-((X + 1) * 10, (Y + 1) * 10), colors(grid(X, Y, 3)), BF
            LINE (X * 10, Y * 10)-((X + 1) * 10, (Y + 1) * 10), 15, B
        NEXT
    NEXT


    IF bestX = endX AND bestY = endY THEN
        done = 1
        xx = endX: yy = endY
        DO
            grid(xx, yy, 3) = 4
            xxx = grid(xx, yy, 4) MOD 32
            yy = INT(grid(xx, yy, 4) / 32)
            xx = xxx
        LOOP UNTIL xx = startX AND yy = startY
    END IF

    IF bestX < 0 THEN
        done = 2
        COLOR 4
        PRINT "no possible path"
    END IF

    IF done = 0 THEN
        X = bestX
        Y = bestY
        FOR i = -1 TO 1
            FOR j = -1 TO 1
                IF NOT i + j * 2 = 0 THEN
                    IF X + i > -1 AND Y + j > -1 AND X + i < 32 AND Y + j < 20 THEN
                        'Print X + i, Y + j
                        suggestedGcost = 0
                        IF ABS(i) = ABS(j) THEN
                            suggestedGcost = grid(X, Y, 0) + 14
                        ELSE:
                            suggestedGcost = grid(X, Y, 0) + 10
                        END IF

                        IF grid(X + i, Y + j, 3) = 0 OR ((grid(X + i, Y + j, 3) = 1 AND grid(X + i, Y + j, 0) > suggestedGcost)) THEN

                            grid(X + i, Y + j, 0) = suggestedGcost
                            grid(X + i, Y + j, 1) = getHCost(X + i, Y + j, endX, endY)
                            grid(X + i, Y + j, 2) = grid(X + i, Y + j, 0) + grid(X + i, Y + j, 1)
                            grid(X + i, Y + j, 3) = 1
                            grid(X + i, Y + j, 4) = X + Y * 32
                        END IF
                    END IF
                END IF
            NEXT
        NEXT
    END IF

    IF (done < 2) THEN
        grid(bestX, bestY, 3) = 2
    END IF

    LINE (startX * 10 + 3, startY * 10 + 3)-(startX * 10 + 7, startY * 10 + 7), 14, BF
    LINE (endX * 10 + 3, endY * 10 + 3)-(endX * 10 + 7, endY * 10 + 7), 9, BF

    pause 5
LOOP WHILE done < 2

'Do: Loop

SUB pause (time AS LONG)
    FOR i = 0 TO time * 1000000
    NEXT i
END SUB

FUNCTION getHCost (xx AS INTEGER, yy AS INTEGER, endX, endY)
    IF ABS(xx - endX) > ABS(yy - endY) THEN
        getHCost = ABS(endY - yy) * 14 + ABS(endX - xx - ABS(endY - yy)) * 10
    ELSE
        getHCost = ABS(endX - xx) * 14 + ABS(endY - yy - ABS(endX - xx)) * 10
    END IF

    'pause 500000
END FUNCTION
