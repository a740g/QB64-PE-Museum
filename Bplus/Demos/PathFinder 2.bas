OPTION _EXPLICIT
_TITLE "PathFinder 2, prepping maze as you read this."

'started 2018-08-11 when Colbalt asked about A* pathfinder
' He has now 2018-08-12 posted a QB64 version that is nice!

' 2018-08-11 started PathFinder 1
' 2018-08-12 almost working but buggy backtract to point A after point B is found.
' 2018-08-13 PathFinder 1a.bas I think I have a fix for buggy path BackTrack but major surgery so this new version
' 2018-08-14 Pathfinder 2:  2 parts
' Part 1: creates a map, a random Home point and backtracts all the points available to move over.
' Part 2: allows clicking variaous points of map to see if path is found.

' 2019-12-19 add Maze Generator code that converts 2 arrays for walls and ceilings to a map for PathFinder 2

DEFINT A-Z
CONST xmax = 800
CONST ymax = 600
CONST border = 0
CONST sq = 10
CONST W = 40
CONST H = 30
CONST mapw = 2 * W + 1
CONST maph = 2 * H + 1

'generator
TYPE cell
    x AS INTEGER
    y AS INTEGER
END TYPE

DIM SHARED h_walls(W, H) AS INTEGER, v_walls(W, H) AS INTEGER
DIM SHARED map(1 TO 2 * W + 1, 1 TO 2 * H + 1) AS STRING * 6

SCREEN _NEWIMAGE(xmax + 11, ymax + 11, 32)
_SCREENMOVE (1280 - xmax) / 2 + 30, (760 - ymax) / 2
RANDOMIZE TIMER

DIM ax, ay, bx, by
DIM y, x, parentF, tick, parentx, changes$, ystart, ystop, xStart, xStop, xxStart, xxStop, yyStart, yyStop, cf, xx, yy
DIM new$, newxy$, newParent$, u, v, mx, my, ps$, parenty

DO
    'this part sets up a sample map and get's the Backtracking build into map

    FOR y = 1 TO maph 'clear and initialize map
        FOR x = 1 TO mapw
            map(x, y) = " "
        NEXT
    NEXT
    'maze generator
    init_walls
    generate_maze
    fillMap 'convert walls to map and outline borders

    ax = 2 * W: ay = 2 * H ' here is the target, a for anchor that all paths must go
    map(ax, ay) = "A"
    parentF = 1: tick = 0: parentx = 0
    WHILE parentF = 1 AND parentx = 0
        parentF = 0: tick = tick + 1: changes$ = ""
        ystart = max(ay - tick, 1): ystop = min(ay + tick, maph)
        FOR y = ystart TO ystop
            xStart = max(ax - tick, 1): xStop = min(ax + tick, mapw)
            FOR x = xStart TO xStop
                'check out the neighbors
                IF x - 1 >= 1 THEN xxStart = x - 1 ELSE xxStart = x
                IF x + 1 <= mapw THEN xxStop = x + 1 ELSE xxStop = x
                IF y - 1 >= 1 THEN yyStart = y - 1 ELSE yyStart = y
                IF y + 1 <= maph THEN yyStop = y + 1 ELSE yyStop = y
                IF RTRIM$(map(x, y)) = "" THEN
                    cf = 0
                    FOR yy = yyStart TO yyStop
                        FOR xx = xxStart TO xxStop
                            IF xx <> x OR yy <> y THEN
                                IF RTRIM$(map(xx, yy)) = "A" OR INSTR(RTRIM$(map(xx, yy)), ",") > 0 THEN 'found a parent to assign to cell
                                    changes$ = changes$ + LTRIM$(STR$(x)) + "," + LTRIM$(STR$(y)) + "{" + LTRIM$(STR$(xx)) + "," + LTRIM$(STR$(yy)) + "}"
                                    parentF = 1 'so will continue looping
                                    cf = 1: EXIT FOR
                                END IF
                            END IF
                        NEXT
                        IF cf THEN EXIT FOR
                    NEXT
                END IF
            NEXT
        NEXT
        'update map with cells assigned parents
        WHILE changes$ <> ""
            new$ = leftOf$(changes$, "}")
            changes$ = rightOf$(changes$, "}")
            newxy$ = leftOf$(new$, "{")
            newParent$ = rightOf$(new$, "{")
            u = VAL(leftOf$(newxy$, ",")): v = VAL(rightOf$(newxy$, ","))
            map(u, v) = leftOf$(newParent$, ",") + "," + rightOf$(newParent$, ",")
        WEND
        _LIMIT 300
    WEND


    'this parts displays the ability to find a path to blue square anywhere in the maze

    _TITLE "Click maze to find a path to blue square (if any), c = clear, n = new map, esc = quit"
    displayM
    DO
        WHILE _MOUSEINPUT: WEND
        IF _MOUSEBUTTON(1) THEN
            mx = _MOUSEX - .5 * sq: my = _MOUSEY - .5 * sq
            bx = mx / sq + 1: by = my / sq + 1
            IF bx >= 1 AND bx <= mapw AND by >= 1 AND by <= maph THEN
                LINE ((bx - 1) * sq + 2, (by - 1) * sq + 2)-STEP(sq - 4, sq - 4), &HFFFFFF000, BF
                ps$ = map(bx, by)
                parentx = VAL(leftOf$(ps$, ","))
                parenty = VAL(rightOf$(ps$, ","))
                IF parentx THEN 'backtrack to A   note: B could be right next to A!!!
                    LINE ((parentx - 1) * sq + 3, (parenty - 1) * sq + 3)-STEP(sq - 6, sq - 6), &HFFFFFFFF, BF
                    WHILE parentx 'trace the path back
                        ps$ = map(parentx, parenty)
                        parentx = VAL(leftOf$(ps$, ","))
                        parenty = VAL(rightOf$(ps$, ","))
                        LINE ((parentx - 1) * sq + 3, (parenty - 1) * sq + 3)-STEP(sq - 6, sq - 6), &HFFFFFFFF, BF
                        _LIMIT 10
                        _DISPLAY
                    WEND
                    BEEP
                ELSE
                    COLOR &HFFFFFFFF
                    LOCATE 15, 10: PRINT "Did not connect to B"
                    _DISPLAY
                    _DELAY 3
                    displayM
                END IF
            END IF
        END IF
        IF _KEYDOWN(27) THEN END
        IF _KEYDOWN(ASC("n")) THEN EXIT DO
        IF _KEYDOWN(ASC("c")) THEN displayM
        _DISPLAY
        _LIMIT 100
    LOOP
LOOP UNTIL _KEYDOWN(27)

SUB displayM ()
    DIM y, x, k AS _UNSIGNED LONG
    FOR y = 1 TO maph
        FOR x = 1 TO mapw
            SELECT CASE RTRIM$(map(x, y))
                CASE "A": k = &HFF0000FF 'target
                CASE "B": k = &HFFFFBB00 'border
                CASE "O": k = &HFF008800 'maze wall
                CASE ELSE: k = &HFF000000
            END SELECT
            LINE ((x - 1) * sq, (y - 1) * sq)-STEP(sq, sq), k, BF
        NEXT
    NEXT
END SUB

FUNCTION rand% (lo%, hi%)
    rand% = INT(RND * (hi% - lo% + 1)) + lo%
END FUNCTION

FUNCTION min (n1, n2)
    IF n1 > n2 THEN min = n2 ELSE min = n1
END FUNCTION

FUNCTION max (n1, n2)
    IF n1 < n2 THEN max = n2 ELSE max = n1
END FUNCTION

FUNCTION leftOf$ (source$, of$)
    DIM posOf
    posOf = INSTR(source$, of$)
    IF posOf > 0 THEN leftOf$ = MID$(source$, 1, posOf - 1)
END FUNCTION

FUNCTION rightOf$ (source$, of$)
    DIM posOf
    posOf = INSTR(source$, of$)
    IF posOf > 0 THEN rightOf$ = MID$(source$, posOf + LEN(of$))
END FUNCTION

SUB init_walls ()
    DIM x AS INTEGER, y AS INTEGER
    FOR x = 0 TO W
        FOR y = 0 TO H
            v_walls(x, y) = 1
            h_walls(x, y) = 1
        NEXT
    NEXT
END SUB

'this takes the generted maze and loads the Map string array
SUB fillMap ()
    DIM y AS INTEGER, x AS INTEGER
    FOR y = 0 TO H
        FOR x = 0 TO W
            IF x < W AND h_walls(x, y) = 1 THEN
                map(2 * x + 1, 2 * y + 1) = "O": map(2 * x + 2, 2 * y + 1) = "O": map(2 * x + 3, 2 * y + 1) = "O"
            END IF
            IF y < H AND v_walls(x, y) = 1 THEN
                map(2 * x + 1, 2 * y + 1) = "O": map(2 * x + 1, 2 * y + 2) = "O": map(2 * x + 1, 2 * y + 3) = "O"
            END IF
        NEXT
    NEXT
    FOR x = 0 TO W - 1
        map(2 * x + 1, 1) = "B": map(2 * x + 2, 1) = "B": map(2 * x + 3, 1) = "B"
        map(2 * x + 1, 2 * H + 1) = "B": map(2 * x + 2, 2 * H + 1) = "B": map(2 * x + 3, 2 * H + 1) = "B"
    NEXT
    FOR y = 0 TO H - 1
        map(1, 2 * y + 1) = "B": map(1, 2 * y + 2) = "B": map(1, 2 * y + 3) = "B"
        map(2 * W + 1, 2 * y + 1) = "B": map(2 * W + 1, 2 * y + 2) = "B": map(2 * W + 1, 2 * y + 3) = "B"
    NEXT
END SUB

'   Maze Generator Code
'
' 2019-09-02 isolated and updated generator code for OPTION _EXPLICIT
' from trans 2018-06-15 for Amazing Rat.bas (QB64)
' From SmallBASIC code written by Chris WS developer
' Backtracking maze generator by chrisws 2016-06-30 now found at
' https://github.com/smallbasic/smallbasic.github.io/blob/5601c8bc1d794c5b143d863555bb7c15a5966a3c/samples/node/1623.bas
'
' Chris notes:
' https://en.wikipedia.org/wiki/Maze_generation_algorithm
' - Starting from a random cell,
' - Selects a random neighbouring cell that has not been visited.
' - Remove the wall between the two cells and marks the new cell as visited,
'   and adds it to the stack to facilitate backtracking.
' - Continues with a cell that has no unvisited neighbours being considered a dead-end.
'   When at a dead-end it backtracks through the path until it reaches a cell with an
'   unvisited neighbour, continuing the path generation by visiting this new,
'   unvisited cell (creating a new junction).
'   This process continues until every cell has been visited, backtracking all the
'   way back to the beginning cell. We can be sure every cell is visited.
'

'B+ notes for using:
' The most important item is that the maze uses 2 arrays one for vertical walls the other for horizontal
' CONST xmax, ymax is pixel size used in maze coder, using SW, SH for screen dimensions
' Maze should mount in top left corner of screen with min border space around it at left and top at least.
' CONST W, H - number of cells Wide and High you can specify.
' CONST wallThk - adjusts thickness of walls
' CONST mazeClr - colors walls made with BF in LINE statement
' CONST border - will create a space around the maze
' SHARED cellW, cellH - are pixels sizes for cell, see calcs before SCREEN command
' SHARED  h_walls(W, H) AS INTEGER, v_walls(W, H) AS INTEGER - these are your Maze, 0 no wall, 1 = wall
' When player occupies cell x, y that cell may v_wall that blocks player going left;
' a cell v_wall(x+1, y) = 1 will block a player going right;
' cell (x, y) may have an h_wall that stops player from going up;
' cell (x, y+1) may have h_wall that stops player at x, y from going down.
' Cells at (W, y) should not be occupied with W cells wide and array base 0 only W-1 can be occupied
' unless game needs something special.
' Likewise cells at (x, H) should only provide wall to stop player from going out of box.


SUB rand_cell (rWx, rHy)
    rWx = INT(RND * 1000) MOD W
    rHy = INT(RND * 1000) MOD H
END SUB

SUB get_unvisited (visited() AS INTEGER, current AS cell, unvisited() AS cell, uvi AS INTEGER)
    REDIM unvisited(0) AS cell
    DIM x AS INTEGER, y AS INTEGER
    x = current.x
    y = current.y
    uvi = 0
    IF x > 0 THEN
        IF visited(x - 1, y) = 0 THEN
            uvi = uvi + 1
            REDIM _PRESERVE unvisited(uvi) AS cell
            unvisited(uvi).x = x - 1
            unvisited(uvi).y = y
        END IF
    END IF
    IF x < W - 1 THEN
        IF visited(x + 1, y) = 0 THEN
            uvi = uvi + 1
            REDIM _PRESERVE unvisited(uvi) AS cell
            unvisited(uvi).x = x + 1
            unvisited(uvi).y = y
        END IF
    END IF
    IF y > 0 THEN
        IF visited(x, y - 1) = 0 THEN
            uvi = uvi + 1
            REDIM _PRESERVE unvisited(uvi) AS cell
            unvisited(uvi).x = x
            unvisited(uvi).y = y - 1
        END IF
    END IF
    IF y < H - 1 THEN
        IF visited(x, y + 1) = 0 THEN
            uvi = uvi + 1
            REDIM _PRESERVE unvisited(uvi) AS cell
            unvisited(uvi).x = x
            unvisited(uvi).y = y + 1
        END IF
    END IF
END SUB

SUB generate_maze ()
    DIM visited(W, H) AS INTEGER
    DIM num_visited AS INTEGER, num_cells AS INTEGER, si AS INTEGER
    DIM cnt AS INTEGER, rc AS INTEGER, x AS INTEGER, y AS INTEGER
    REDIM stack(0) AS cell
    DIM curr_cell AS cell, next_cell AS cell, cur_cell AS cell

    rand_cell cur_cell.x, cur_cell.y
    visited(curr_cell.x, curr_cell.y) = 1
    num_visited = 1
    num_cells = W * H
    si = 0
    WHILE num_visited < num_cells
        REDIM cells(0) AS cell
        cnt = 0
        get_unvisited visited(), curr_cell, cells(), cnt
        IF cnt > 0 THEN

            ' choose randomly one of the current cell's unvisited neighbours
            rc = INT(RND * 100) MOD cnt + 1
            next_cell.x = cells(rc).x
            next_cell.y = cells(rc).y

            ' push the current cell to the stack
            si = si + 1
            REDIM _PRESERVE stack(si) AS cell
            stack(si).x = curr_cell.x
            stack(si).y = curr_cell.y

            ' remove the wall between the current cell and the chosen cell
            IF next_cell.x = curr_cell.x THEN
                x = next_cell.x
                y = max(next_cell.y, curr_cell.y)
                h_walls(x, y) = 0
            ELSE
                x = max(next_cell.x, curr_cell.x)
                y = next_cell.y
                v_walls(x, y) = 0
            END IF

            ' make the chosen cell the current cell and mark it as visited
            curr_cell.x = next_cell.x
            curr_cell.y = next_cell.y
            visited(curr_cell.x, curr_cell.y) = 1
            num_visited = num_visited + 1

        ELSEIF si > 0 THEN

            ' pop a cell from the stack and make it the current cell
            curr_cell.x = stack(si).x
            curr_cell.y = stack(si).y
            si = si - 1
            REDIM _PRESERVE stack(si) AS cell

        ELSE
            EXIT WHILE
        END IF
    WEND
END SUB
