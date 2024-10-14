DEFLNG A-Z

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

RANDOMIZE TIMER

DIM SHARED Buffer%(32001)
Buffer%(0) = 320 * 8
Buffer%(1) = 200

b = 0
g = 0
FOR a = 150 TO 100 STEP -1
    r = a / 5
    set_pal a, b, g, r
NEXT

FOR a = 100 TO 0 STEP -1
    g = g - 1
    b = b - 1
    r = r - 1
    set_pal a, b, g, r
NEXT

g = 0
FOR a = 150 TO 255 STEP 1

    b = 0
    g = g + 1
    r = a / 5
    IF (g > 62) THEN
        g = 62
    END IF
    set_pal a, b, g, r
NEXT

DO
    l = l + 1
    fire
    update_screen

    IF (l > 1) THEN
        IF b = 0 THEN
            a = a + 1
        END IF
        IF b = 1 THEN
            a = a - 1
        END IF
        set_random_pixels a, 255
        IF (a < 50) THEN
            b = 0
        END IF
        IF (a > 200) THEN
            b = 1
        END IF
        l = 0
    END IF

LOOP UNTIL INKEY$ <> ""

SYSTEM 0


SUB fire
    FOR y = 200 TO 1 STEP -1
        FOR x = 1 TO 320 STEP 1
            med_col = 0
            med_col = med_col + get_pixel(x - 1, y + 1)
            med_col = med_col + get_pixel(x + 1, y + 1)
            med_col = med_col + get_pixel(x, y + 1)
            med_col = med_col + get_pixel(x, y)
            med_col = med_col + RND * 3
            med_col = med_col / 4.04
            set_pixel x, y, med_col
        NEXT
    NEXT
END SUB

SUB set_random_pixels (nr, col)
    row = 201
    FOR x = 1 TO 320
        set_pixel x, row, 0
    NEXT
    FOR a = 0 TO nr
        x = RND * 320
        set_pixel x, row, col
        set_pixel x + 1, row, col
        set_pixel x - 1, row, col
    NEXT
END SUB

SUB update_screen
    PUT (0, 0), Buffer%(), PSET
END SUB

SUB set_pixel (x%, y%, col%)
    DEF SEG = VARSEG(Buffer%(32001))
    POKE 320& * y% + x% + 4, col%
    DEF SEG
END SUB

FUNCTION get_pixel (x%, y%)
    DEF SEG = VARSEG(Buffer%(32001))
    get_pixel = PEEK(320& * y% + x% + 4)
    DEF SEG
END FUNCTION

SUB set_pal (p, b, g, r)
    b = CINT(b)
    g = CINT(g)
    r = CINT(r)

    IF (b > 62) THEN b = 62
    IF (g > 62) THEN g = 62
    IF (r > 62) THEN r = 62
    IF (b < 0) THEN b = 0
    IF (g < 0) THEN g = 0
    IF (r < 0) THEN r = 0
    PALETTE p, 65536 * b + 256 * g + r
END SUB

