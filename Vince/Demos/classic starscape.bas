RANDOMIZE TIMER
DIM SHARED pi, d, zz, sw, sh
pi = 4 * ATN(1)
d = 700
zz = 2100
sw = 1280
sh = 720

TYPE stype
    x AS DOUBLE
    y AS DOUBLE
    z AS DOUBLE
END TYPE
DIM SHARED star(2000) AS stype

TYPE gtype
    x AS DOUBLE
    y AS DOUBLE
    z AS DOUBLE

    r AS DOUBLE
    r1 AS DOUBLE
    r2 AS DOUBLE

    a1 AS DOUBLE
    a2 AS DOUBLE
    a3 AS DOUBLE
END TYPE
DIM SHARED galaxy(100) AS gtype


SCREEN _NEWIMAGE(sw, sh, 32)

FOR i = 0 TO 2000
    star(i).x = 5000 * RND - 2500
    star(i).y = 5000 * RND - 2500
    star(i).z = 5000 * RND - 2500
NEXT
FOR i = 0 TO 30
    galaxy(i).x = 4000 * RND - 2000
    galaxy(i).y = 4000 * RND - 2000
    galaxy(i).z = 4000 * RND - 2000
    galaxy(i).r = 150 * RND
    galaxy(i).r1 = RND
    galaxy(i).r2 = RND
    galaxy(i).a1 = 2 * pi * RND
    galaxy(i).a2 = 2 * pi * RND
    galaxy(i).a3 = 4 * pi * RND - 2.5 * pi * RND
NEXT

DO
    CLS

    FOR i = 0 TO 2000
        star(i).z = star(i).z - 100
        IF star(i).z < 0 THEN
            star(i).x = 4000 * RND - 2000
            star(i).y = 4000 * RND - 2000
            star(i).z = 4000 * RND - 2000
        END IF
        x1 = star(i).x
        y1 = star(i).y
        z1 = star(i).z
        FOR z0 = 0 TO 3
            PSET (sw / 2 + x1 * d / (z1 + zz + z0 * 10), sh / 2 - y1 * d / (z1 + zz + z0 * 10)), _RGB(255 - 50 * z0, 255 - 50 * z0, 0)
        NEXT
    NEXT

    FOR i = 0 TO 30
        galaxy(i).z = galaxy(i).z - 100
        IF galaxy(i).z < -zz THEN
            galaxy(i).x = 4000 * RND - 2000
            galaxy(i).y = 4000 * RND - 2000
            galaxy(i).z = 8000 * RND '-2000
            galaxy(i).r = 10 * RND + 30
            galaxy(i).r1 = RND
            galaxy(i).r2 = RND
            galaxy(i).a1 = 2 * pi * RND
            galaxy(i).a2 = 2 * pi * RND
            galaxy(i).a3 = 4 * pi * RND - 2.5 * pi * RND
        END IF
        x1 = galaxy(i).x
        y1 = galaxy(i).y
        z1 = galaxy(i).z
        r = galaxy(i).r
        r1 = galaxy(i).r1
        r2 = galaxy(i).r2
        a1 = galaxy(i).a1
        a2 = galaxy(i).a2
        a3 = galaxy(i).a3
        drawgalaxy x1, y1, z1, r, r1, r2, a1, a2, a3
    NEXT

    _DISPLAY
    _LIMIT 30
LOOP UNTIL _KEYHIT = 27
SLEEP
SYSTEM

SUB drawgalaxy (x1, y1, z1, r, r1, r2, a1, a2, u)
    DIM c AS _UNSIGNED LONG

    FOR a = 0 TO u STEP 0.1
        FOR i = 0 TO 0.001 * r * (u - a) ^ 3.5
            x0 = (RND - 0.5) * 0.2 * r * (u - a)
            y0 = (RND - 0.5) * 0.2 * r * (u - a)
            z0 = (RND - 0.5) * 0.2 * r * (u - a)

            IF x0 * x0 + y0 * y0 + z0 * z0 < 2000 THEN
                FOR k = 0 TO 1
                    x = x0 + r1 * r * a * COS(a + k * pi)
                    y = y0 + r2 * r * a * SIN(a + k * pi)
                    z = z0 + 1

                    rot x, y, a1
                    rot y, z, a2

                    c = 255 * (u - a) / 2
                    rr = c + RND * 50
                    gg = 0.2 * c + RND * 50
                    bb = 0
                    IF rr < 0 THEN rr = 0
                    IF gg < 0 THEN gg = 0
                    IF bb < 0 THEN bb = 0
                    IF rr > 255 THEN rr = 255
                    IF gg > 255 THEN gg = 255
                    IF bb > 255 THEN bb = 255
                    rr = rr - z1 / 100
                    gg = gg - z1 / 100
                    bb = bb - z1 / 100

                    PSET (sw / 2 + (x + x1) * d / (z + z1 + zz), sh / 2 - (y + y1) * d / (z + z1 + zz)), _RGB(rr, gg, bb)
                NEXT
            END IF
        NEXT
    NEXT
END SUB

SUB rot (xx, yy, a)
    x = xx
    y = yy
    xx = x * COS(a) - y * SIN(a)
    yy = x * SIN(a) + y * COS(a)
END SUB
