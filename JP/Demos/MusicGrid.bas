OPTION _EXPLICIT

CONST MAXX = 512
CONST MAXY = 512

DIM SHARED AS LONG grid(16, 16), grid2(16, 16), cur

SCREEN _NEWIMAGE(MAXX, MAXY, 32)
_TITLE "MusicGrid"
cleargrid

DIM t AS DOUBLE, oldCur AS LONG, in AS STRING

DO
    IF TIMER(0.001) - t > 1 / 8 THEN
        cur = (cur + 1) AND 15
        t = TIMER(0.001)
    END IF

    IF cur <> oldCur THEN
        figuregrid
        drawgrid
        playgrid
        oldCur = cur
    END IF
    domousestuff
    in = INKEY$
    IF in = "C" OR in = "c" THEN cleargrid
LOOP UNTIL in = CHR$(27)

SUB drawgrid
    DIM scale AS SINGLE, scale2 AS LONG
    DIM AS LONG y, y1, x, x1
    DIM AS _UNSIGNED LONG c

    scale = MAXX / 16
    scale2 = MAXX \ 16 - 2
    FOR y = 0 TO 15
        y1 = y * scale!
        FOR x = 0 TO 15
            x1 = x * scale!
            c = _RGB32(grid2(x, y) * 64 + 64, 0, 0)
            LINE (x1, y1)-(x1 + scale2, y1 + scale2), c, BF
        NEXT x
    NEXT y
END SUB

SUB figuregrid
    DIM AS LONG y, x

    FOR y = 0 TO 15
        FOR x = 0 TO 15
            grid2(x, y) = grid(x, y)
        NEXT x
    NEXT y
    FOR y = 1 TO 14
        FOR x = 1 TO 14
            IF grid(x, y) = 1 AND cur = x THEN
                grid2(x, y) = 2
                IF grid(x - 1, y) = 0 THEN grid2(x - 1, y) = 1
                IF grid(x + 1, y) = 0 THEN grid2(x + 1, y) = 1
                IF grid(x, y - 1) = 0 THEN grid2(x, y - 1) = 1
                IF grid(x, y + 1) = 0 THEN grid2(x, y + 1) = 1
            END IF
        NEXT x
    NEXT y
END SUB

SUB domousestuff
    DIM AS LONG x, y

    DO WHILE _MOUSEINPUT
        IF _MOUSEBUTTON(1) THEN
            x = _MOUSEX \ (MAXX \ 16)
            y = _MOUSEY \ (MAXY \ 16)
            grid(x, y) = 1 - grid(x, y)
        END IF
    LOOP
END SUB

SUB playgrid
    CONST NOTE_SIZE = 10
    'Const scale = "O1CO1DO1EO1FO1GO1AO1BO2CO2DO2EO2FO2GO2AO2BO3CO3D"
    CONST scale = "o1@5c,@1f  o1@2g     o1@3a     o2@3c     o2@3d     o2@3f     o2@3g     o2@3a     o3@3c     o3@3d     o3@3f     o3@3g     o3@3a     o4@3c     o4@3d     o4@3f     "

    DIM y AS LONG, note AS STRING, n AS STRING

    n = "L16 "

    FOR y = 15 TO 0 STEP -1
        IF grid(cur, y) = 1 THEN
            note$ = MID$(scale$, 1 + (15 - y) * NOTE_SIZE, NOTE_SIZE)
            n$ = n$ + note$ + "," 'comma plays 2 or more column notes simultaneously
        END IF
    NEXT y
    n$ = LEFT$(n$, LEN(n$) - 1)
    PLAY n$
END SUB

SUB cleargrid
    DIM AS LONG y, x

    FOR y = 0 TO 15
        FOR x = 0 TO 15
            grid(x, y) = 0
        NEXT x
    NEXT y
END SUB
