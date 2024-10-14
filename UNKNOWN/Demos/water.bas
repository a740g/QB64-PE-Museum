DEFSNG A-Z

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

RANDOMIZE TIMER

DIM SHARED Buffer%(32001)
Buffer%(0) = 320 * 8
Buffer%(1) = 200

DIM SHARED buffer1(320, 200) AS SINGLE
DIM SHARED buffer2(320, 200) AS SINGLE

DIM SHARED wave_nr
wave_nr = 1
set_palette 0, 0.24, 0
fade = 0.0
DO
    set_random_pixels 1, 256
    wave
    water
    update_screen
    swap_buffers

    IF (fade < 0.24) THEN
        fade = fade + 0.002
        set_palette 0, fade, 0
    END IF

    _LIMIT 60
LOOP UNTIL INKEY$ <> ""

SYSTEM


SUB water
    DIM c AS SINGLE

    FOR x = 319 TO 1 STEP -1
        FOR y = 1 TO 199

            c = ((buffer2(x - 1, y) + buffer2(x + 1, y) + buffer2(x, y - 1) + buffer2(x, y + 1)) / 2) - buffer1(x, y)
            c = c * 0.99
            IF (c > 256) THEN c = 256
            IF (c < 0) THEN c = 0

            buffer1(x, y) = c * 0.95

        NEXT
    NEXT
END SUB

SUB wave
    buffer2(160 + SIN(wave_nr / 20) * 60, 100 + COS(wave_nr / 20) * 40) = 256
    wave_nr = wave_nr + 1
END SUB

SUB set_random_pixels (nr, col)
    FOR a = 0 TO nr
        x = 1 + RND * 318
        y = 1 + RND * 198
        buffer2(x, y) = col
    NEXT
END SUB

SUB swap_buffers
    DIM tmp(320, 200) AS SINGLE
    FOR a = 1 TO 320
        FOR b = 1 TO 200
            tmp(a, b) = buffer1(a, b)
            buffer1(a, b) = buffer2(a, b)
            buffer2(a, b) = tmp(a, b)
            set_pixel a, b, CINT(buffer1(a, b))
        NEXT
    NEXT
END SUB

SUB update_screen
    PUT (0, 0), Buffer%(), PSET
END SUB

SUB set_pixel (x%, y%, col%)
    DEF SEG = VARSEG(Buffer%(32001))
    POKE 320& * y% + x% + 4, col% + 50
    DEF SEG
END SUB

FUNCTION get_pixel (x%, y%)
    DEF SEG = VARSEG(Buffer%(32001))
    get_pixel = PEEK(320& * y% + x% + 4)
    DEF SEG
END FUNCTION


SUB clear_screen
    FOR a = 4 TO 32001
        Buffer%(a) = 0
    NEXT
END SUB

SUB set_palette (r, b, g)
    cr = 0.0
    cb = 0.0
    cg = 0.0
    FOR p = 0 TO 255
        cr = cr + r
        cb = cb + b
        cg = cg + g
        pal_col = (CINT(cb) * 65536) + (CINT(cg) * 256) + CINT(cr)
        PALETTE p, pal_col
    NEXT
END SUB

