' The IBM Personal Computer Donkey
' Version 1.10 (C)Copyright IBM Corp 1981, 1982
' Licensed Material - Program Property of IBM

' Updated by a740g to work with QB64
' TODO: Fix few graphical glitches
' Suggestions by Taylor Autumn

OPTION _EXPLICIT

' All global variables and arrays
DIM AS STRING cmd
DIM AS SINGLE i, cx, cy, y, sd, sm, z, z1
DIM AS INTEGER dx, d1x, d1y, d2x, c1x, c1y, c2x, p
DIM AS INTEGER D1(150), D2(150), C1(200), C2(200)
DIM AS INTEGER DNK(300), CAR(900), B(300)

' Welcome screen
$RESIZE:SMOOTH
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
WIDTH 40

COLOR 15, 0
CLS
LOCATE 5, 19
PRINT "IBM"
LOCATE 7, 12
PRINT "Personal Computer"
COLOR 10, 0
LOCATE 10, 9
PRINT CHR$(213) + STRING$(21, 205) + CHR$(184)
LOCATE 11, 9
PRINT CHR$(179) + "       DONKEY        " + CHR$(179)
LOCATE 12, 9
PRINT CHR$(179) + STRING$(21, 32) + CHR$(179)
LOCATE 13, 9
PRINT CHR$(179) + "    Version 1.1O     " + CHR$(179)
LOCATE 14, 9
PRINT CHR$(212) + STRING$(21, 205) + CHR$(190)
COLOR 15, 0
LOCATE 17, 4
PRINT "(C) Copyright IBM Corp 1981, 1982"
COLOR 14, 0
LOCATE 23, 7
PRINT "Press space bar to continue"

DO
    cmd = INKEY$
    IF cmd = CHR$(27) THEN SYSTEM
LOOP UNTIL cmd = CHR$(32)

' Main game code starts here
RANDOMIZE TIMER

SCREEN 1

COLOR 8, 1

' Get the donkey bitmap
CLS
DRAW "S08"
DRAW "BM14,18"
DRAW "M+2,-4R8M+1,-1U1M+1,+1M+2,-1"
DRAW "M-1,1M+1,3M-1,1M-1,-2M-1,2"
DRAW "D3L1U3M-1,1D2L1U2L3D2L1U2M-1,-1"
DRAW "D3L1U5M-2,3U1"
PAINT (21, 14), 3
PRESET (37, 10)
PRESET (40, 10)
PRESET (37, 11)
PRESET (40, 11)
GET (13, 0)-(45, 25), DNK()

' Get the car bitmap
CLS
DRAW "S8C3"
DRAW "BM12,1r3m+1,3d2R1ND2u1r2d4l2u1l1"
DRAW "d7R1nd2u2r3d6l3u2l1d3m-1,1l3"
DRAW "m-1,-1u3l1d2l3u6r3d2nd2r1u7l1d1l2"
DRAW "u4r2d1nd2R1U2"
DRAW "M+1,-3"
DRAW "BD10D2R3U2M-1,-1L1M-1,1"
DRAW "BD3D1R1U1L1BR2R1D1L1U1"
DRAW "BD2BL2D1R1U1L1BR2R1D1L1U1"
DRAW "BD2BL2D1R1U1L1BR2R1D1L1U1"
LINE (0, 0)-(40, 60), , B
PAINT (1, 1)
GET (1, 1)-(28, 45), CAR() ' Taylor Autumn - 06/30/2022 @a740g change Get (1, 1)-(29, 45), CAR() to Get (1, 1)-(28, 45), CAR()

' This is for the strips on the road
CLS
FOR i = 2 TO 300
    B(i) = -16384 + 192
NEXT
B(0) = 2
B(1) = 193

' This loops just starts a new game
DO
    cx = 110
    CLS
    LINE (0, 0)-(305, 199), , B
    LINE (6, 6)-(97, 195), 1, BF
    LINE (183, 6)-(305, 195), 1, BF
    LOCATE 3, 5
    PRINT "Donkey"
    LOCATE 3, 29
    PRINT "Driver"
    LOCATE 19, 25
    PRINT "Press Space  ";
    LOCATE 20, 25
    PRINT "Bar to switch";
    LOCATE 21, 25
    PRINT "lanes        ";
    LOCATE 23, 25
    PRINT "Press ESC    ";
    LOCATE 24, 25
    PRINT "to exit      ";
    FOR y = 4 TO 199 STEP 20
        LINE (140, y)-(140, y + 10)
    NEXT
    cy = 105
    cx = 105
    LINE (100, 0)-(100, 199)
    LINE (180, 0)-(180, 199)

    ' This is the main game loop
    DO
        LOCATE 5, 6
        PRINT sd
        LOCATE 5, 31
        PRINT sm
        cy = cy - 4

        ' Exit the main loop if donkey loses the game
        IF cy < 60 THEN
            sm = sm + 1
            LOCATE 7, 25
            PRINT "Donkey loses!"

            SLEEP 2

            EXIT DO
        END IF

        PUT (cx, cy), CAR(), PRESET
        dx = 105 + 42 * INT(RND * 2)

        FOR y = (RND * -4) * 8 TO 124 STEP 6

            SOUND 20000, 1

            cmd = INKEY$

            ' Exit to the OS if Esc is pressed
            IF cmd = CHR$(27) THEN SYSTEM

            ' Move car is a key is pressed
            IF LEN(cmd) > 0 THEN
                LINE (cx, cy)-(cx + 28, cy + 44), 0, BF
                cx = 252 - cx
                PUT (cx, cy), CAR(), PRESET
                SOUND 200, 1
            END IF

            IF y >= 3 THEN PUT (dx, y), DNK(), PSET

            ' If there is a collision then show some fancy animation and exit the main loop
            IF cx = dx AND y + 25 >= cy THEN
                sd = sd + 1
                LOCATE 14, 6
                PRINT "BOOM!"
                GET (dx, y)-(dx + 16, y + 25), D1()
                d1x = dx
                d1y = y
                d2x = dx + 17
                GET (dx + 17, y)-(dx + 31, y + 25), D2()
                GET (cx, cy)-(cx + 14, cy + 44), C1()
                GET (cx + 15, cy)-(cx + 28, cy + 44), C2()
                c1x = cx
                c1y = cy
                c2x = cx + 15

                FOR p = 6 TO 0 STEP -1
                    z = 1 / (2 ^ p)
                    z1 = 1 - z
                    PUT (c1x, c1y), C1()
                    PUT (c2x, c1y), C2()
                    PUT (d1x, d1y), D1()
                    PUT (d2x, d1y), D2()
                    c1x = cx * z1
                    d1y = y * z1
                    c2x = c2x + (291 - c2x) * z
                    d1x = dx * z1
                    c1y = c1y + (155 - c1y) * z
                    d2x = d2x + (294 - d2x) * z
                    PUT (c1x, c1y), C1()
                    PUT (c2x, c1y), C2()
                    PUT (d1x, d1y), D1()
                    PUT (d2x, d1y), D2()
                    SOUND 37 + RND * 200, 4
                    _LIMIT 17
                NEXT

                SLEEP 2

                EXIT DO
            END IF

            IF y AND 3 THEN PUT (140, 6), B()
            _LIMIT 17
        NEXT

        LINE (dx, 124)-(dx + 32, 149), 0, BF
    LOOP
LOOP
