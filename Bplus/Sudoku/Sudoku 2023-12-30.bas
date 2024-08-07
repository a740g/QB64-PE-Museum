_TITLE "Sudoku 2020-08-08" 'B+ restart 2019-05-04 from

'2019-05-03 Unigue

'2019-05-02 Worksheet

'2018-01-23 QB3 Sudoku App.bas
' + add recursive solver from JB forum, sub resolve() by cassiope01 on 18 Nov 2011
' - dump all other solver code, nothing compares as resolve will "solve" a blank board!
' + add all improvements made to Sudoku in SB version
' + navigate the keyboard with arrow keys and/or input numbers by keyboard
' + 6 functions menu > 7 with a Fill Menu item for Solving puzzle
'     and Help menu to toggle numbers available for spaces so that
'     all numbers legal for a space are displaced for you in small font!!!
'     all menu buttons have equivalent keypresses, just use first letter.

'from;  SB3 Sudoku Game and Solver.bas for SmallBASIC 0.12.11 (B+=MGA) 2018-01-17

'from: SB1 Sudoku Game.bas for SmallBASIC 0.12.11 (B+=MGA) 2018-01-17
' some edits of game posted 2018-01-17, better quit code with level
' more debug code removed

'from: sudoku mod bplus.bas SmallBASIC 0.12.11 (B+=MGA) 2018-01-06
' add whole new makeGrid (maybe faster) and hideCells code (not so random)

'Sudoku Game from SB.bas SmallBASIC 0.12.9 (B+=MGA) 2018-01-04
' fix color at start so can see the grid!
' add solved function!!! and loop around when solved
' removed cell notes, to store in corners option

'2019-05-01 Goal is to make Sudoku Worksheet for human to solve puzzles.
' Main improvement planned is to "pencil" in small number notes.
'  checkCellFill or Hint menu offers anything that can possible go into a cell,
' too much information and clutter!
' "pencil notes" will come in through right mouse click or shift + number key.
' If the number is penciled in and 2nd key or click will erase it and vice versa.
' So need string array to hold notes for all the cells notes$(8, 8)

' We will also change the function of checkCellFill, if checkCellFill is on, a beep will sound
' if you try to fill a cell with a bad number, otherwise, no checkCellFill will allow
' bad number fills.

' OK load and save are doing the notes$() now.
'2019-05-03 most recent changes
' fix handle number, it was allowing clues to be changed
' start app with checkCellFill mode on, which reminds me change checkCellFill to Check except it is 5 letters
'I have played a number of games level 5 and damn it is not leaving ambiguous x/y number pairs
' so two solutions dpending if you decide x or y in one place so it is y, x in the other.
' HideCell2 is no better than hideCells though much more random scatter
'change hideCells2 to just random hide


'Unique Puzzle make a 2nd resolve that starts at different n's
' I think if the puzzle is not unique a different puzzle will be created for at least 1 of the n Starts
' that would indicate not to hide that cell
' 1. so save the solution after makeGrid
' 2. hide a cell
' 3. test 9 different startNs   resolve2(startN)
' 4. if any produce a different solution than puzzle grid solution, don't hide that cell
'    else hide that cell and find another in loop until the required number of cells to hide is met.
' Man that is allot of coding and I am not sure it will work

'2019-05-04 OK I think Unique code is working, it is harder and harder to get back to solution
' made in makeGrid code. Nearly impossible to hide more than 54+ cells, but I don't know if puzzles
' created are still solvable nor do I know for sure that there is only one unique solution.

' Next To Do's create and save the SHARED soln() currently made in HideCells2
' to be made in makeGrid code just copy the grid created.
' THEN I can show the intended solution anytime by super imposing it in alpha colors on grid,
' if a showSoln mode is toggled ON. So change the function of Fill Menu button to toggle
' show soln mode ON /OFF. This will allow me to check if legal moves made are staying consistent with
' the soluntion generated by code.
'  More Menu Button changes:
' Mode toggle between Make and Play, this needs solnFlag to signal if soln >> nope do not toggle
' checkCellFill changed to Check ON/OFF
' Menu Button old Fill now ON/OFF toggle for display of soln transparent overlay

' changes  DIM SHARED soln(), solnFlag 0 signals no soln, 1 signals soln  for toggle and display of soln overlay
' soln() created in makeGrid now, remember this is intended soln and may not be unique.
' SHARED solnF showSolnF flags added to work with displaying a transparent overlay of Soln (if one, solnF)
' menu Button Fill changed to ON/OFF for showing soln
' Menu buttons moved to display labels underneath for show soln toggle ON/OFF and check cell fill ON/OFF
' Good going from Make mode to Puzzle Mode with a Soln determined from Make Puzzle.

'2019-05-05 no longer need a 0 cell to change a number guess
'2019-05-06 use Cyberbit.ttf for large Font for easier portability
' start cleanup code,
' experiment hideCell without random cell pick of hideCell2 by same algo to prevent ambiguous puzzles

'2019-05-07 a few tests with: Sudoku Unique Solution Test.exe, prove to my satisfaction the App code is coming up
' with a puzzle with a unique solution. Note: the tests here are not as extensive as in that code but it takes a long
' time already to hide over 54 cells and still keep puzzle with unique solution.

'2019-07-13 fix the ability to change from 1 cell fill number to another without having to 0 first
' I thought I had protection from changing a clue cell? When I load a saved file I can change clue cells? clue cells are blue not white.
' Can I also change clue cells while playing from an original? NO! good then the problem is saving and loading!
' Oh keypresses work for numbers too, shift + number for notes, just number fills cell.
' Need to start notes for manual.  OK I can change a numbered cell to another without 0 first.
' Blue are clues, that can't be changed, white are guesses that can be changed.

'2019-07-15 change main loop _limit to 30 as fan was running allot. 30 too slow clicks not registering, 100 no
' 200 eh?? 400, down from 500.

'2019-08-21 I am noticing a problem after loading a puzzle, if I am in make mode, load a puzzle
' I assume I am in puzzle mode but I am still in Make mode, should be reminder after the load.

' 2020-08-07 develop game from Game folder now try Arial Font and Icon file

CONST xmax = 440
CONST ymax = 570
SCREEN _NEWIMAGE(xmax, ymax, 32)
_SCREENMOVE 320, 20

DEFINT A-Z
RANDOMIZE TIMER

CONST TextSize = 8
CONST CellSize = TextSize * 5

CONST xMinBoard = CellSize
CONST yMinBoard = CellSize
CONST xMaxBoard = xMinBoard + 9 * CellSize
CONST yMaxBoard = yMinBoard + 9 * CellSize
CONST xMidBoard = xMinBoard + xMaxBoard / 2 - xMinBoard / 2
CONST yMidBoard = yMinBoard + yMaxBoard / 2 - yMinBoard / 2
CONST xMinKeyPad = xMinBoard - 20
CONST xMaxKeyPad = xMinKeyPad + CellSize * 10
CONST yMinKeyPad = yMaxBoard + 10
CONST yMaxKeyPad = yMinKeyPad + CellSize
CONST funcWide = xmax / 7
CONST yMinFunc = yMaxKeyPad + 25
CONST yMaxFunc = yMinFunc + CellSize

CONST redl = &HFF880000~&
CONST bluel = &HFF000040~&
CONST greyh = &HFFB0B0B0~&
CONST blueh = &HFF5555FF~&
CONST greenh = &HFF00FF00~&
CONST cyanh = &HFF00FFFF~&
CONST redh = &HFFFF0000~&
CONST purpleh = &HFFFF00FF~&
CONST yellowh = &HFFFFFF00~&
CONST whiteh = &HFFFFFFFF~&

COMMON SHARED bx, by, mkey, update, level, mode$, checkCellFill, solnF, showSolnF
COMMON SHARED bCyberbit&
DIM SHARED grid(8, 8), temp(8, 8), notes$(8, 8), soln(8, 8)
$EXEICON:'./ico sudoku.ico'
temp& = _LOADIMAGE("ico sudoku.png")
_ICON temp&
_FREEIMAGE temp&

'load and check Big size font
'see if we can pickup file for porting to other OS
bCyberbit& = _LOADFONT("arial.ttf", 30, "BOLD") '<<<<< copy from QB64 folder or path to it
IF bCyberbit& <= 0 THEN PRINT "Trouble with arial.ttf, size 30, file, goodbye.": SLEEP: END
'_FONT bCyberbit&
'LOCATE 1, 1: PRINT "This is BIG font."
'_FONT 16
'SLEEP

'main loop sets up game puzzle, mainly gets level and clears variables from last puzzle run
WHILE 1
    getLevel
    'globals  SETUP for Game or Make Puzzle
    bx = 0: by = 0 '      current highlighted location on board
    mkey = 1 '            current key highlighted on keyPad, key = 0 clears cell
    update = 1 '          when to show game board
    mode$ = "p" '         2 modes: p for puzzle and m for make puzzle
    checkCellFill = 1 '            checkCellFill mode will check cell fills for blunders ie already in row, col or block
    '                     the h key or the checkCellFill Menu function will Toggle this feature on/off
    ERASE grid '          9x9 board positive values are puzzle clues
    '                     0 value in grid is blank cell to fill out
    '                     neg values in grid are players guesses to solve puzzle
    ERASE notes$
    makeGrid
    hideCells2

    WHILE 1
        IF update THEN showGrid
        k$ = INKEY$
        IF LEN(k$) THEN
            update = 1
            IF LEN(k$) = 1 THEN
                IF k$ = " " THEN '<<<<<<<<<<<<< letter for this?
                    IF showSolnF THEN
                        showSolnF = 0
                    ELSE
                        showSolnF = 1
                    END IF
                    'resolve
                ELSEIF k$ = "c" THEN
                    IF checkCellFill THEN checkCellFill = 0 ELSE checkCellFill = 1
                ELSEIF k$ = "m" OR k$ = "p" THEN
                    mode$ = k$: update = 1
                    IF k$ = "m" THEN 'convert grid to all positive values
                        FOR row = 0 TO 8
                            FOR col = 0 TO 8
                                grid(col, row) = ABS(grid(col, row))
                            NEXT
                        NEXT
                        solnF = 0
                        showSolnF = 0
                        ERASE soln
                    END IF
                    IF k$ = "p" THEN ' do we have a soln?, we should
                        checkSoln
                    END IF
                ELSEIF k$ = "s" THEN
                    savePZ
                ELSEIF k$ = "l" THEN
                    loadPZ
                ELSEIF k$ = "x" THEN
                    EXIT WHILE
                ELSEIF INSTR("0123456789", k$) THEN
                    handleNumber VAL(k$)
                ELSEIF ASC(k$) = 27 THEN
                    CLS: END
                ELSE
                    kpos = INSTR("!@#$%^&*()", k$)
                    IF kpos > 0 THEN
                        handleNote _TRIM$(STR$(kpos MOD 10))
                    ELSE
                        update = 0
                    END IF
                END IF
            ELSEIF LEN(k$) = 2 THEN
                SELECT CASE ASC(RIGHT$(k$, 1))
                    CASE 72: IF by > 0 THEN by = by - 1 'up arrow
                    CASE 80: IF by < 8 THEN by = by + 1 'down arrow
                    CASE 75: IF bx > 0 THEN bx = bx - 1 'left arrow
                    CASE 77: IF bx < 8 THEN bx = bx + 1 'right arrow
                    CASE ELSE: update = 0
                END SELECT
            END IF
        END IF

        'get next mouse click, check if in board and if so update x, y
        m = _MOUSEINPUT: mb1 = _MOUSEBUTTON(1): mb2 = _MOUSEBUTTON(2): mx = _MOUSEX: my = _MOUSEY
        mb = mb1 OR mb2
        IF mb THEN 'get last place mouse button was down
            mb = _MOUSEBUTTON(1) OR _MOUSEBUTTON(2): mx = _MOUSEX: my = _MOUSEY
            mb1 = _MOUSEBUTTON(1): mb2 = _MOUSEBUTTON(2):
            WHILE mb 'left button down, wait for mouse button release
                m = _MOUSEINPUT: mx = _MOUSEX: my = _MOUSEY
                mb = _MOUSEBUTTON(1) OR _MOUSEBUTTON(2)
            WEND
            'clicked inside Board?
            IF xMinBoard <= mx AND mx <= xMaxBoard AND yMinBoard <= my AND my <= yMaxBoard THEN
                bx = INT((mx - xMinBoard) / CellSize): by = INT((my - yMinBoard) / CellSize)
                IF mb1 THEN handleNumber mkey: update = 1
                IF mb2 THEN handleNote _TRIM$(STR$(mkey)): update = 1
            END IF
            'clicked inside keyPad?
            IF xMinKeyPad <= mx AND mx <= xMaxKeyPad AND yMinKeyPad <= my AND my <= yMaxKeyPad THEN
                mkey = INT((mx - xMinKeyPad) / CellSize)
                update = 1
            END IF
            'clicked inside Func menu:
            IF 0 <= mx AND mx <= xmax THEN
                IF yMinFunc < my AND my < yMaxFunc THEN
                    update = 1
                    xf# = mx / funcWide
                    IF xf# <= 1 THEN ' toggle solution overlay on / off
                        IF showSolnF THEN
                            showSolnF = 0
                        ELSE
                            showSolnF = 1
                        END IF
                    ELSEIF xf# <= 2 THEN 'toggle checkCellFill on/off
                        IF checkCellFill THEN checkCellFill = 0 ELSE checkCellFill = 1
                    ELSEIF xf# <= 3 THEN 'play mode
                        mode$ = "p"
                        checkSoln
                    ELSEIF xf# <= 4 THEN 'make mode
                        mode$ = "m"
                        FOR row = 0 TO 8
                            FOR col = 0 TO 8
                                grid(col, row) = ABS(grid(col, row))
                            NEXT
                        NEXT
                        solnF = 0
                        showSolnF = 0
                        ERASE soln
                    ELSEIF xf# <= 5 THEN 'save file
                        savePZ
                    ELSEIF xf# <= 6 THEN 'load file
                        loadPZ
                    ELSEIF xf# <= 7 THEN 'exit
                        EXIT WHILE
                    END IF
                END IF
            END IF
        END IF
        _DISPLAY
        _LIMIT 400 '? save fan?
    WEND
WEND

SUB handleNumber (ky)
    IF mode$ = "m" AND ky = 0 THEN
        grid(bx, by) = 0
    ELSEIF mode$ = "m" AND ky <> 0 THEN
        temp = grid(bx, by)
        grid(bx, by) = 0 'aok needs to see an emptry cell to check if a is OK
        IF aok(ky, bx, by) THEN
            grid(bx, by) = ky
        ELSE
            BEEP: grid(bx, by) = temp
        END IF
    ELSEIF mode$ = "p" AND grid(bx, by) <= 0 THEN 'don't change clues!
        temp = grid(bx, by)
        grid(bx, by) = 0 'aok needs to see an emptry cell to check if a is OK
        IF ky = 0 THEN
            grid(bx, by) = 0
        ELSEIF checkCellFill <> 0 THEN 'checkCellFill on
            IF aok(ky, bx, by) THEN
                grid(bx, by) = -ky
            ELSE
                BEEP: grid(bx, by) = temp
            END IF
        ELSEIF checkCellFill = 0 THEN 'allow blunders
            grid(bx, by) = -ky
        END IF
    ELSEIF mode$ = "p" AND grid(bx, by) > 0 THEN 'don't change clues!
        BEEP
    END IF
END SUB

SUB handleNote (ky$)
    IF ky$ = "0" THEN 'clear notes for cell
        notes$(bx, by) = ""
    ELSE 'toggle numbers
        find = INSTR(notes$(bx, by), ky$)
        IF find > 0 THEN 'if find it erase
            IF find = 1 THEN
                notes$(bx, by) = MID$(notes$(bx, by), find + 1)
            ELSEIF find > 1 THEN
                notes$(bx, by) = MID$(notes$(bx, by), 1, find - 1) + MID$(notes$(bx, by), find + 1)
            END IF
        ELSE 'if don't find it add it
            notes$(bx, by) = notes$(bx, by) + ky$
        END IF
    END IF
END SUB

FUNCTION solved ()
    solved = 0 'n must be found in every column, row and 3x3 cell
    FOR n = 1 TO 9
        'check columns for n
        FOR col = 0 TO 8
            found = 0
            FOR row = 0 TO 8
                IF ABS(grid(col, row)) = n THEN found = 1: EXIT FOR
            NEXT
            IF found = 0 THEN EXIT FUNCTION
        NEXT
        'check rows for n
        FOR row = 0 TO 8
            found = 0
            FOR col = 0 TO 8
                IF ABS(grid(col, row)) = n THEN found = 1: EXIT FOR
            NEXT
            IF found = 0 THEN EXIT FUNCTION
        NEXT
        'check 3x3 cells for n
        FOR cell = 0 TO 8
            cellcol = cell MOD 3
            cellrow = INT(cell / 3)
            found = 0
            FOR col = 0 TO 2
                FOR row = 0 TO 2
                    IF ABS(grid(cellcol * 3 + col, cellrow * 3 + row)) = n THEN found = 1: EXIT FOR
                NEXT
                IF found = 1 THEN EXIT FOR
            NEXT
            IF found = 0 THEN EXIT FUNCTION
        NEXT
    NEXT
    solved = 1
END FUNCTION

SUB showGrid ()
    update = 0 'global calls for this display
    COLOR whiteh, bluel: CLS
    IF mode$ = "p" THEN s$ = " Puzzle:    Puzzle Mode" ELSE s$ = " Puzzle:      Make Mode"
    IF level = -1 THEN
        LOCATE 2, 8: PRINT "Sudoku Loaded File"; s$
    ELSE
        LOCATE 2, 10: PRINT "Sudoku Level "; RIGHT$(STR$(level), 1); s$
    END IF
    'draw line segments
    i = xMinBoard
    FOR x = 0 TO 9
        LINE (i, yMinBoard)-(i, yMaxBoard), purpleh
        i = i + CellSize
    NEXT x
    j = yMinBoard
    FOR y = 0 TO 9
        LINE (xMinBoard, j)-(xMaxBoard, j), purpleh
        j = j + CellSize
    NEXT y
    'draw heavy 3x3 cell borders
    LINE (xMinBoard + 1, yMinBoard + 1)-(xMaxBoard + 1, yMaxBoard + 1), whiteh, B
    i = xMinBoard + (CellSize * 3) + 1
    LINE (i, yMinBoard)-(i, yMaxBoard), whiteh
    i = xMinBoard + (CellSize * 6) + 1
    LINE (i, yMinBoard)-(i, yMaxBoard), whiteh
    j = yMinBoard + (CellSize * 3) + 1
    LINE (xMinBoard, j)-(xMaxBoard, j), whiteh
    j = yMinBoard + (CellSize * 6) + 1
    LINE (xMinBoard, j)-(xMaxBoard, j), whiteh
    FOR y = 0 TO 8
        FOR x = 0 TO 8
            'highlite?
            IF x = bx AND y = by THEN
                COLOR bluel, 10
                LINE (xMinBoard + x * CellSize + 3, yMinBoard + y * CellSize + 3)-STEP(CellSize - 5, CellSize - 5), greenh, BF
            ELSE
                IF grid(x, y) > 0 THEN COLOR blueh, bluel ELSE COLOR greyh, bluel
            END IF
            IF grid(x, y) <> 0 THEN
                _FONT bCyberbit&
                _PRINTSTRING (xMinBoard + (x * CellSize) + TextSize + 5, yMinBoard + (y * CellSize) + 9), RIGHT$(STR$(ABS(grid(x, y))), 1)
                _FONT 16
            ELSEIF notes$(x, y) <> "" THEN
                _FONT 8
                IF LEN(notes$(x, y)) > 4 THEN
                    _PRINTSTRING (xMinBoard + x * CellSize + 3, yMinBoard + y * CellSize + 3), MID$(notes$(x, y), 1, 4)
                    _PRINTSTRING (xMinBoard + x * CellSize + 3, yMinBoard + y * CellSize + 12), MID$(notes$(x, y), 5)
                ELSE
                    _PRINTSTRING (xMinBoard + x * CellSize + 3, yMinBoard + y * CellSize + 3), notes$(x, y)
                END IF
                _FONT 16
            END IF
        NEXT
    NEXT
    'show a keypad key with highlite
    i = xMinKeyPad
    FOR x = 0 TO 9
        IF x = mkey THEN
            LINE (i + 3, yMinKeyPad + 3)-STEP(CellSize - 5, CellSize - 5), greenh, BF
            COLOR bluel, greenh
        ELSE
            COLOR cyanh, bluel
        END IF
        LINE (i, yMinKeyPad)-(i, yMaxKeyPad), greyh
        _PRINTSTRING (i + (TextSize * 2), yMinKeyPad + TextSize + 4), RIGHT$(STR$(x), 1)
        i = i + CellSize
    NEXT
    LINE (xMinKeyPad, yMinKeyPad)-(xMaxKeyPad, yMaxKeyPad), greyh, B
    'function menu
    COLOR cyanh, redh
    FOR i = 0 TO 6
        LINE (i * funcWide + 5, yMinFunc + 5)-((i + 1) * funcWide - 5, yMaxFunc - 5), redh, BF
        SELECT CASE i
            CASE 0
                IF showSolnF THEN
                    COLOR cyanh, redh
                    _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), " ON "

                    IF solnF THEN 'show it
                        FOR y = 0 TO 8
                            FOR x = 0 TO 8
                                'highlite?
                                IF grid(x, y) <= 0 THEN
                                    COLOR _RGBA32(255, 180, 0, 150), _RGBA(0, 0, 40, 0)
                                    _FONT bCyberbit&
                                    xx = xMinBoard + (x * CellSize) + TextSize + 5
                                    yy = yMinBoard + (y * CellSize) + 9
                                    _PRINTSTRING (xx, yy), RIGHT$(STR$(ABS(soln(x, y))), 1)
                                    _FONT 16
                                    COLOR cyanh, redh
                                END IF
                            NEXT
                        NEXT
                    END IF
                ELSE
                    _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), " OFF"
                END IF
            CASE 1: IF checkCellFill THEN
                    _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), " ON "
                ELSE
                    _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), " OFF"
                END IF
            CASE 2: _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), "Play"
            CASE 3: _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), "Make"
            CASE 4: _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), "Save"
            CASE 5: _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), "Load"
            CASE 6: _PRINTSTRING (i * funcWide + 17, yMinFunc + 13), "Main"
        END SELECT
    NEXT
    COLOR whiteh, bluel
    _PRINTSTRING (0 * funcWide + 17, yMaxFunc + 5), "Show"
    _PRINTSTRING (0 * funcWide + 17, yMaxFunc + 21), "Soln"
    _PRINTSTRING (0 * funcWide + 17, yMaxFunc + 37), "<sp>"
    _PRINTSTRING (1 * funcWide + 17, yMaxFunc + 5), "Check"
    _PRINTSTRING (1 * funcWide + 17, yMaxFunc + 21), "Cell"
    _PRINTSTRING (1 * funcWide + 17, yMaxFunc + 37), "Fill"
    _PRINTSTRING (6 * funcWide + 17, yMaxFunc + 5), " <x>"
    IF solved THEN
        COLOR blueh, cyanh
        s$ = "Puzzle Solved!"
        _PRINTSTRING ((xmax - LEN(s$) * 8) / 2, 28.5 * 16), s$
    END IF
    _DISPLAY

END SUB

SUB makeGrid 'this version requires the assistance of loadBox sub routine
    DO
        ERASE grid, temp
        startOver = 0
        FOR n = 1 TO 9
            FOR r = 0 TO 8
                FOR c = 0 TO 8
                    temp(c, r) = grid(c, r)
                NEXT
            NEXT
            cnt = 0
            DO
                FOR cellBlock = 0 TO 8
                    success = loadBox(n, cellBlock)
                    IF success = 0 THEN
                        cnt = cnt + 1 'EDIT remove the counters used to test code tCnt and tStartOver
                        IF cnt >= 20 THEN startOver = 1: EXIT FOR
                        FOR r = 0 TO 8
                            FOR c = 0 TO 8
                                grid(c, r) = temp(c, r)
                            NEXT
                        NEXT
                        EXIT FOR
                    END IF
                NEXT
                IF startOver THEN EXIT DO
            LOOP UNTIL success
            IF startOver THEN EXIT FOR
        NEXT
    LOOP UNTIL startOver = 0
    'make a copy of grid as soln()
    FOR r = 0 TO 8
        FOR c = 0 TO 8
            soln(c, r) = grid(c, r)
        NEXT
    NEXT
    solnFlag = 1
END SUB

SUB hideCells2
    'Unique Puzzle make a 2nd resolve that starts at different n's
    ' I think if the puzzle is not unique a different puzzle will be created for at least 1 of the n Starts
    ' that would indicate not to hide that cell
    ' 1. so save the solution after makeGrid (makeGrid does that now)
    ' 2. hide a cell
    ' 3. test 9 different startNs   resolve2(startN)
    ' 4. if any produce a different solution than puzzle grid solution, don't hide that cell
    '    else hide that cell and find another in loop until the required number of cells to hide is met.
    ' Man that is allot of coding and I am not sure it will work


    'CLS
    'PRINT "level * 9"; level * 9
    'INPUT "OK press enter... "; wate$

    IF level = 9 THEN
        ERASE grid
        ERASE soln
        solnF = 0
        showSolnF = 0
        mode$ = "m"
    ELSE
        'make copy of grid/soln
        IF level = 8 THEN
            stopHiding = 57
        ELSEIF level = 7 THEN
            stopHiding = 54
        ELSEIF level = 6 THEN
            stopHiding = 50
        ELSE
            stopHiding = level * 9
        END IF

        startOver:
        startOver = startOver + 1
        IF startOver MOD 2 = 0 THEN
            stopHiding = stopHiding - 1
        END IF
        FOR r = 0 TO 8
            FOR c = 0 TO 8
                grid(c, r) = soln(c, r)
            NEXT
        NEXT
        hidden = 0
        fails = 0
        'debug
        'CLS
        'PRINT "Level:"; level
        'PRINT "Start Overs"; startOver
        'PRINT "Number of cells hiding:"; stopHiding
        'INPUT "OK press enter.. "; wate$

        WHILE hidden < stopHiding
            hr = INT(RND * 9): hc = INT(RND * 9)
            WHILE grid(hc, hr) = 0
                hr = INT(RND * 9): hc = INT(RND * 9)
            WEND
            saveCellValue = grid(hc, hr)
            grid(hc, hr) = 0
            hideCellFail = 0
            FOR ns = 1 TO 9
                resolve2 ns 'this sould solve everytime no matter where start N
                IF solved THEN 'compare to solution
                    FOR r = 0 TO 8
                        FOR c = 0 TO 8
                            IF soln(c, r) <> ABS(grid(c, r)) THEN
                                hideCellFail = 1: EXIT FOR
                            END IF
                        NEXT
                        IF hideCellFail THEN EXIT FOR
                    NEXT
                    'restore grid to pretest conditions
                    FOR r = 0 TO 8
                        FOR c = 0 TO 8
                            IF grid(c, r) < 0 THEN grid(c, r) = 0
                        NEXT
                    NEXT
                    IF hideCellFail THEN EXIT FOR
                ELSE 'this has never happened in all my testing
                    'big error
                    CLS
                    PRINT "Resolve2 failed to get to a solution while hiding cells. bye!"
                    INPUT "Press enter to end... "; wate$
                    END
                END IF
            NEXT
            IF hideCellFail THEN
                grid(hc, hr) = saveCellValue 'restore value
                fails = fails + 1
                'PRINT fails
                IF fails > 50 THEN
                    GOTO startOver
                END IF
                'PRINT "Hide Cell Failed."
                'INPUT " OK press enter to cont... "; wate$
            ELSE
                hidden = hidden + 1 'yeah a cell is hidden
                'PRINT "Hidden "; hidden
                'INPUT "OK press enter... "; wate$
            END IF

        WEND
        solnF = 1
    END IF
END SUB

FUNCTION loadBox (n, box) 'this one uses aok function to help load boxes
    xoff = 3 * (box MOD 3): yoff = 3 * INT(box / 3)
    'make a list of free cells in cellblock
    DIM clist(8)
    FOR y = 0 TO 2 'make list of cells available
        FOR x = 0 TO 2 'find open cell in cellBlock first
            IF aok(n, xoff + x, yoff + y) THEN available = available + 1: clist(3 * y + x) = 1
        NEXT
    NEXT
    IF available = 0 THEN
        EXIT FUNCTION
    END IF
    DIM cell(1 TO available): pointer = 1
    FOR i = 0 TO 8
        IF clist(i) THEN cell(pointer) = i: pointer = pointer + 1
    NEXT
    'OK our list has cells available to load, pick one randomly
    IF available > 1 THEN 'shuffle cells
        FOR i = available TO 2 STEP -1
            r = INT(RND * i) + 1
            SWAP cell(i), cell(r)
        NEXT
    END IF
    'load the first one listed
    grid(xoff + (cell(1) MOD 3), yoff + INT(cell(1) / 3)) = n
    loadBox = 1
END FUNCTION

SUB savePZ
    fName$ = "Temp Saved Puzzle.txt"
    OPEN fName$ FOR OUTPUT AS #1
    FOR r = 0 TO 8
        FOR c = 0 TO 8
            PRINT #1, notes$(r, c)
        NEXT
    NEXT
    PRINT #1, "---"
    FOR r = 0 TO 8
        s$ = ""
        FOR c = 0 TO 8
            s$ = s$ + RIGHT$("   " + STR$(grid(c, r)), 3)
        NEXT
        PRINT #1, s$
    NEXT
    PRINT #1, "---"
    IF solnF THEN
        FOR r = 0 TO 8
            s$ = ""
            FOR c = 0 TO 8
                s$ = s$ + RIGHT$("   " + STR$(soln(c, r)), 3)
            NEXT
            PRINT #1, s$
        NEXT
    END IF
    CLOSE #1
    showGrid
    COLOR blueh, cyanh
    s$ = "Puzzle Saved to: " + fName$
    _PRINTSTRING ((xmax - LEN(s$) * 8) / 2, 28.5 * 16), s$
END SUB

SUB loadPZ ()
    OPEN "Temp Saved Puzzle.txt" FOR INPUT AS #1
    FOR r = 0 TO 8
        FOR c = 0 TO 8
            INPUT #1, notes$(r, c)
        NEXT
    NEXT
    INPUT #1, dum$
    FOR row = 0 TO 8
        INPUT #1, fl$
        FOR i = 0 TO 8
            n = VAL(MID$(fl$, 3 * i, 3))
            grid(i, row) = n
        NEXT
    NEXT
    CLOSE #1
    solnF = 0
    checkSoln
    level = -1 'signal no longer using the puzzle setup from getLevel intro
END SUB

' resolve sub written by cassiope01 on 18 Nov 2011,
' modified very slightly by TyCamden on 19 Nov 2011,
' modified more by me for testing code at JB in mainwin code:
' use aok() function in place of ok() as it does
' the same thing without string processing.

' Now modified by me more, to use in SB but too many stack
' overflow errors in SB, try QB64, Oh yeah!!! Nice...
SUB resolve2 (startN)
    FOR r = 0 TO 8
        FOR c = 0 TO 8
            IF grid(c, r) = 0 THEN
                FOR nMod = startN TO startN + 8
                    IF nMod > 9 THEN n = nMod - 9 ELSE n = nMod
                    IF aok(n, c, r) THEN
                        temp = grid(c, r)
                        grid(c, r) = -n
                        resolve2 startN
                        IF solved THEN EXIT SUB 'try solved instead of complete
                        grid(c, r) = temp
                    END IF
                NEXT
                EXIT SUB
            END IF
        NEXT
    NEXT
END SUB

FUNCTION aok (a, c, r) 'check to see if a is OK to place at (c, r)
    aok = 0
    IF grid(c, r) = 0 THEN 'check cell empty
        FOR i = 0 TO 8 'check row and column
            IF ABS(grid(i, r)) = a OR ABS(grid(c, i)) = a THEN EXIT FUNCTION
        NEXT
        cbase = INT(c / 3) * 3: rbase = INT(r / 3) * 3
        FOR rr = 0 TO 2
            FOR cc = 0 TO 2
                IF ABS(grid(cbase + cc, rbase + rr)) = a THEN EXIT FUNCTION
            NEXT
        NEXT
        aok = 1
    END IF
END FUNCTION

SUB getLevel () 'isolated to work on independently
    'get desired level of difficulty set
    COLOR greyh, redl: CLS

    cp 2, "*** Sudoku Application for QB64 by bplus ***"

    cp 4, "Features 7 Function Menu:"
    lp 1, 5, "1 Show Soln - ON/OFF toggle to overlay solution."
    lp 1, 6, "2 Check Cell Fill - ON toggle will beep blunders."
    lp 1, 7, "3 Play - normal Puzzle mode (guesses are neg)."
    lp 1, 8, "4 Make - for puzzle creation (clues are pos)."
    lp 1, 9, "5 Save - file a puzzle at any stage."
    lp 1, 10, "6 Load - load the filed puzzle back."
    lp 1, 11, "7 Main - comes back here for new level or quit."

    cp 13, "Levels 1 to 3 are good for developing"
    cp 14, "'flash card' automatic skills."
    cp 15, "Levels 4, 5 are pretty easy."
    cp 16, "6, 7 intermediate, 8 difficult puzzles."
    cp 17, "The puzzles might not be unique or solvable,"
    cp 18, "but some effort has gone into making them so."

    cp 20, "Use level 9 to blank a puzzle and input your own."
    cp 21, "Remember, switch to Play mode after entering clues."

    lp 2, 23, "spacebar <sp> to toggle solution display."
    lp 2, 24, "<c> to toggle Check Cell Fill ON/OFF."
    lp 2, 25, "<p> for Play mode (changable grey numbers in grid)."
    lp 2, 26, "<m> for Make mode (blue numbered clues in grid)."
    lp 2, 27, "<s> to Save to file: Temp Saved Puzzle.txt"
    lp 2, 28, "<l> to Load that puzzle up again."
    lp 2, 29, "<x> to eXit back to this screen for new puzzle."

    COLOR yellowh, redl
    cp 31, "Now about that level? Enter 0 to 9 any else quits"
    lvl$ = ""
    LOCATE 33, 25: INPUT ; lvl$
    IF lvl$ = "" THEN
        CLS: END
    ELSE
        IF INSTR("0123456789", lvl$) THEN level = VAL(lvl$) ELSE CLS: END
    END IF
END SUB

SUB cp (cpRow, text$)
    _PRINTSTRING ((xmax - 8 * LEN(text$)) / 2, cpRow * 16), text$
END SUB

SUB lp (spacer, lpRow, text$)
    _PRINTSTRING (spacer * 8, lpRow * 16), text$
END SUB

SUB checkSoln
    IF solnF = 0 THEN
        'make copy of grid
        FOR rrow = 0 TO 8
            FOR ccol = 0 TO 8
                temp(ccol, rrow) = grid(ccol, rrow)
            NEXT
        NEXT
        'clear negs to get soln for clues only!
        FOR rrow = 0 TO 8
            FOR ccol = 0 TO 8
                IF grid(ccol, rrow) < 0 THEN grid(ccol, rrow) = 0
            NEXT
        NEXT
        'resolve it
        resolve2 1
        'save it to soln array
        IF solved THEN
            FOR rrow = 0 TO 8
                FOR ccol = 0 TO 8
                    soln(ccol, rrow) = grid(ccol, rrow)
                NEXT
            NEXT
            'set flag
            solnF = 1
        ELSE
            ERASE soln 'if not already done
            'set flag
            solnF = 0
        END IF
        'restore grid
        FOR rrow = 0 TO 8
            FOR ccol = 0 TO 8
                grid(ccol, rrow) = temp(ccol, rrow)
            NEXT
        NEXT
    END IF
END SUB
