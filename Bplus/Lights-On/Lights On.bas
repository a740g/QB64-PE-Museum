OPTION _EXPLICIT ' avoid typo's
_TITLE "Lights On - all the [x, y] cells lit up." ' b+ 2022-04-27 trans Felixp7
' 2022-05-01 Mod for n levels levels

DIM SHARED AS LONG n ' used in most all procedures
DIM AS LONG x, y, moves, xx, yy
DIM answer$

restart:
INPUT "Please enter n for n x n board to run, < 2 quits"; n
IF n < 2 OR n > 10 THEN GOTO restart
REDIM SHARED AS LONG board(1 TO n, 1 TO n)
moves = 0
FOR y = 1 TO n 'setup puzzle
    FOR x = 1 TO n
        IF (INT(RND * 2) MOD 2) = 0 THEN
            toggle x, y
        END IF
    NEXT
NEXT
DO 'run the game
    CLS
    showBoard
    PRINT "Moves: "; moves;
    INPUT " Your move x,y "; xx, yy ' get user choice, laugh moo ha, ha
    IF ((xx > 0) AND (xx <= n)) AND ((yy > 0) AND (yy <= n)) THEN ' input OK
        toggle xx, yy
        moves = moves + 1
    ELSE 'bad input see if want to quit
        INPUT "Quit game? "; answer$
        answer$ = UCASE$(LEFT$(answer$, 1))
        IF answer$ <> "N" THEN
            PRINT "Thanks for playing!"
            END
        END IF
    END IF
LOOP UNTIL lightsOn
CLS
showBoard
PRINT "You win in"; moves; "moves."
GOTO restart

SUB showBoard () ' default color is 7,0 white on black background unless a lit cell
    DIM AS LONG x, y
    FOR y = 1 TO n
        FOR x = 1 TO n
            PRINT " ";
            IF board(x, y) THEN COLOR 0, 7 ' light up cell
            PRINT "["; ns$(x); ","; ns$(y); "]";
            COLOR 7, 0
        NEXT
        PRINT
        PRINT
    NEXT
END SUB

SUB toggle (x, y) ' toogle 4 lites around point up, down, left right
    board(x, y) = NOT board(x, y) ' switch  x, y
    IF x > 1 THEN board(x - 1, y) = NOT board(x - 1, y)
    IF x < n THEN board(x + 1, y) = NOT board(x + 1, y)
    IF y > 1 THEN board(x, y - 1) = NOT board(x, y - 1)
    IF y < n THEN board(x, y + 1) = NOT board(x, y + 1)
END SUB

FUNCTION lightsOn () ' check if lights are all through board return -1 = true if so
    DIM AS LONG x, y
    FOR y = 1 TO n
        FOR x = 1 TO n
            IF board(x, y) = 0 THEN EXIT FUNCTION 'something still off
        NEXT
    NEXT
    lightsOn = -1
END FUNCTION

FUNCTION ns$ (num) ' formated number string for 2 digit integers
    ns$ = RIGHT$("  " + _TRIM$(STR$(num)), 2) ' trim because QB64 adds space to pos integers
END FUNCTION
