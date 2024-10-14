DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH

CONST NUMDISCS = 9 ' alter this line to change number of discs

DIM SHARED TOWERS(0 TO 2, 1 TO NUMDISCS), TOP(0 TO 2), COLORS(1 TO NUMDISCS), NUMMOVES AS LONG
DIM AS LONG i, choice

TOP(0) = NUMDISCS: TOP(1) = 0: TOP(2) = 0
FOR i = 1 TO NUMDISCS
    TOWERS(0, i) = NUMDISCS - i + 1
    READ COLORS(i)
NEXT
DATA 6,9,4,10,11,12,13,14
DATA 6,9,4,10,11,12,13,14
LOCATE 1, 26
PRINT CHR$(218); STRING$(14, CHR$(196)); CHR$(191)
LOCATE 2, 26
PRINT CHR$(179); "TOWER OF HANOI"; CHR$(179)
LOCATE 3, 26
PRINT CHR$(192); STRING$(14, CHR$(196)); CHR$(217)
PRINT STRING$(80, CHR$(196))
PRINT
PRINT "1: AUTO"
PRINT "2: HUMAN"
PRINT STRING$(20, CHR$(196))
WHILE choice <> 1 AND choice <> 2
    INPUT "CHOOSE ONE: ", choice
WEND
IF choice = 1 THEN CALL AUTO ELSE CALL PLAYGAME

SUB AUTO
    CALL SHOWDISCS
    CALL MOVEPILE(NUMDISCS, 0, 2)
END SUB

SUB INSTRUCT
    DIM null AS STRING

    PRINT "The TOWER OF HANOI is a mathematical game or puzzle. It consists"
    PRINT "of three pegs and a number of discs which can slide onto any peg."
    PRINT "The puzzle starts with the discs stacked in order of size on one peg."
    PRINT
    PRINT "The object of the game is to move the entire stack onto another peg,"
    PRINT "obeying the following rules:"
    PRINT TAB(2); CHR$(248); " Only one disc may be moved at a time."
    PRINT TAB(2); CHR$(248); " Each move consists of taking the upper disc from"
    PRINT TAB(4); "one peg and sliding it onto another peg, on top of any discs"
    PRINT TAB(4); "that may already be on that peg."
    PRINT TAB(2); CHR$(248); " No disc may be placed on top of another disc."
    PRINT "PRESS ANY KEY TO CONTINUE..."
    null$ = INPUT$(1)
END SUB

SUB MOVEDISC (START, FINISH)
    TOWERS(FINISH, TOP(FINISH) + 1) = TOWERS(START, TOP(START))
    TOP(FINISH) = TOP(FINISH) + 1
    TOWERS(START, TOP(START)) = 0
    TOP(START) = TOP(START) - 1
    NUMMOVES = NUMMOVES + 1
    CALL SHOWDISCS
    _DELAY .1
    IF INKEY$ = CHR$(27) THEN END
END SUB

SUB MOVEPILE (N, START, FINISH)
    IF N > 1 THEN CALL MOVEPILE(N - 1, START, 3 - START - FINISH)
    CALL MOVEDISC(START, FINISH)
    IF N > 1 THEN CALL MOVEPILE(N - 1, 3 - START - FINISH, FINISH)
END SUB

SUB PLAYGAME
    DIM null AS STRING, k AS STRING
    DIM AS LONG start, finish

    DO
        INPUT "WOULD YOU LIKE INSTRUCTIONS"; null$
        null$ = UCASE$(LEFT$(LTRIM$(null$), 1))
        IF null$ = "Y" THEN CALL INSTRUCT: EXIT DO
        IF null$ = "N" THEN EXIT DO
    LOOP
    CALL SHOWDISCS
    DO
        LOCATE 1, 1
        COLOR 7
        PRINT "TYPE NUMBER OF START PEG FOLLOWED BY NUMBER OF END PEG"
        PRINT "LEFT = 1", "MIDDLE = 2", "RIGHT=3"
        DO
            k$ = INKEY$
            SELECT CASE k$
                CASE CHR$(27)
                    END
                CASE "1"
                    start = 0
                    EXIT DO
                CASE "2"
                    start = 1
                    EXIT DO
                CASE "3"
                    start = 2
                    EXIT DO
            END SELECT
        LOOP
        DO
            k$ = INKEY$
            SELECT CASE k$
                CASE CHR$(27)
                    END
                CASE "1"
                    finish = 0
                    EXIT DO
                CASE "2"
                    finish = 1
                    EXIT DO
                CASE "3"
                    finish = 2
                    EXIT DO
            END SELECT
        LOOP
        IF TOP(start) = 0 THEN PRINT "There are no discs on that peg.": GOTO 1
        IF start = finish THEN PRINT "The start peg is the same as the end peg.": GOTO 1
        IF TOP(finish) > 0 THEN
            IF TOWERS(start, TOP(start)) > TOWERS(finish, TOP(finish)) THEN PRINT "You may not put a larger disc on top of a smaller disc.": GOTO 1
        END IF
        CALL MOVEDISC(start, finish)
        IF TOP(0) = 0 AND TOP(1) = 0 THEN EXIT DO
        IF TOP(0) = 0 AND TOP(2) = 0 THEN EXIT DO
    1 LOOP
END SUB

SUB SHOWDISCS
    DIM AS LONG i, x

    CLS
    LOCATE 1, 60: PRINT "MOVES: "; NUMMOVES
    LOCATE 25, 1
    PRINT STRING$(80, CHR$(196));
    FOR i = 1 TO TOP(0)
        LOCATE 25 - i, i + 1
        x = TOWERS(0, i)
        IF x = 0 THEN EXIT FOR
        COLOR COLORS(x): PRINT STRING$(x * 2, CHR$(219));
    NEXT
    FOR i = 1 TO TOP(1)
        LOCATE 25 - i, i + NUMDISCS * 3
        x = TOWERS(1, i)
        IF x = 0 THEN EXIT FOR
        COLOR COLORS(x): PRINT STRING$(x * 2, CHR$(219));
    NEXT
    FOR i = 1 TO TOP(2)
        LOCATE 25 - i, i + NUMDISCS * 6
        x = TOWERS(2, i)
        IF x = 0 THEN EXIT FOR
        COLOR COLORS(x): PRINT STRING$(x * 2, CHR$(219));
    NEXT
END SUB
