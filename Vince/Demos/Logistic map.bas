DEFLNG A-Z
DIM xx AS DOUBLE, uu AS DOUBLE
SCREEN 12
FOR u = 0 TO 640
    uu = 2.8 + 1.2 * u / 640
    FOR x = 0 TO 480
        xx = x / 480
        FOR i = 0 TO 500
            xx = uu * xx * (1 - xx)
        NEXT
        PSET (u, 480 * (1 - xx))
    NEXT
NEXT
SLEEP
SYSTEM
