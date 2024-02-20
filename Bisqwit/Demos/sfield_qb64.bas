DEFINT A-Z

'*************************
'** From video demonstration: "256 colors is enough for everyone"
'** Presented at: http://www.youtube.com/watch?v=VL0oGct1S4Q
'** Copyright (C) 2011 Joel Yliluoma - http://iki.fi/bisqwit/
'** Originally written for QuickBASIC, this version is ported for QB64.
SCREEN 13

'Define an optimal palette (generated with NeuQuant). The colors
' are sorted by luminosity (for reasons that become apparent later).
DIM Pal(253, 3) AS SINGLE, PalG(253, 3) AS SINGLE 'Palette in range 0..1
DATA 000000,000001,010101,010102,020101,010201,010202,030102,020202,020203
DATA 030201,040104,020205,030302,010404,020402,060202,030305,050206,040304
DATA 030309,040402,020505,050404,040407,080303,050502,06030A,030603,070405
DATA 04040E,090307,040605,020707,060508,060605,060703,0B030B,0C0404,04070A
DATA 030903,070707,090609,050614,090705,08060D,0B0411,04090D,060A06,070909
DATA 0F0509,09080A,040B09,0B0807,10040F,090B03,090B07,0D080C,040E05,07081C
DATA 0F0517,150507,0F0904,090A10,080C0C,050D0F,0E0B08,0B0C0B,0F0910,11090B
DATA 0C0A14,080F09,14051E,140810,0A0928,0C0F05,080E16,0E0D0D,05120B,180617
DATA 09100E,0C0E11,130A16,1C070E,0E0C1A,140D06,061212,100F0A,120D11,081505
DATA 0F100F,1C0B07,150E0C,110F14,0C140A,110D21,101305,081220,1F0818,180D11
DATA 0F0B36,1B0826,0D1315,0B1512,081619,141210,190D1C,260A0C,161017,09132D
DATA 181306,13150A,101610,0A1A0D,1E100E,11141C,051C12,200930,260921,131515
DATA 170F2C,0F1B07,19150D,1A1316,0E1724,220F1A,0E1A18,2D0B16,171423,082108
DATA 171813,131B0F,0A1D1D,141919,2C0A2B,19171C,251313,231608,1F141F,191C07
DATA 231127,081F26,0D2110,131B1F,380C10,1D1A10,2A0B3C,2E130A,1F1817,0E1A3C
DATA 171F10,121C2D,1D172B,191D17,1E143B,122118,072817,132508,2E131F,102222
DATA 1E1C1D,1B1C25,3A0D23,25191E,271531,380D33,0B2D09,19221F,1F2211,2F1915
DATA 271A26,1F2408,291E0D,0C282A,261F16,172329,1F1E31,321629,182814,14291F
DATA 232122,3C1813,20251A,112738,20222A,112E15,083121,3D113E,231F3B,30183E
DATA 2C1E2B,3D1820,2E201F,1A2930,1B300A,1F2A24,242B13,3E192E,28281C,262531
DATA 38230C,0B3238,2F2714,1F283B,15302B,1C301C,312135,292827,322428,2A2E09
DATA 103C0C,0F3B1D,2D263D,232F2E,3E2327,17333B,0B3D2A,3D271A,193B16,3E213D
DATA 302E1F,263422,2B3416,2F2D30,223C0C,3B2832,3D2E0E,28303C,1D3C22,1A3B30
DATA 123E3D,30332A,3E2A3E,3A331B,33303D,273834,3D3026,293D1B,303C0F,263D29
DATA 213D3D,3A3433,323D24,3D3D0E,323D31,2B3F3E,3F363F,3D3F1A,3F3E23,353E3F
DATA 3E3E2D,3E3E36,3F3F3F
CONST gamma = 2.2, ungamma = 1 / gamma
OUT &H3C8, 0
FOR p = 0 TO 252
    READ s$
    s& = VAL("&H" + s$): R = s& \ 65536: G = (s& \ 256) AND 255: B = s& AND 255
    OUT &H3C9, R: OUT &H3C9, G: OUT &H3C9, B
    Pal(p, 0) = (R / 63): PalG(p, 0) = Pal(p, 0) ^ gamma
    Pal(p, 1) = (G / 63): PalG(p, 1) = Pal(p, 1) ^ gamma
    Pal(p, 2) = (B / 63): PalG(p, 2) = Pal(p, 2) ^ gamma
NEXT

' Define color candidate count for dithering
CONST candcount = 64
DIM colortab(candcount)

' Set up a 8x8 bayer-dithering matrix.
DIM dither8x8(8, 8)
FOR y = 0 TO 7: FOR x = 0 TO 7
        q = x XOR y
        p = (x AND 4) \ 4 + (x AND 2) * 2 + (x AND 1) * 16
        q = (q AND 4) \ 2 + (q AND 2) * 4 + (q AND 1) * 32
        dither8x8(y, x) = 1 + (p + q) * candcount \ 64
NEXT x, y

'Generate stars
CONST N = 25000
REDIM starx(N), stary(N), starz(N), starR!(N), starG!(N), starB!(N)
' REDIM makes the arrays $DYNAMIC (far allocation) -> no 64k limit
FOR c = 1 TO N
    'Random RGB color        'Random 3D position
    starR!(c) = RND + .01: starx(c) = CINT(RND * 1000) - 500
    starG!(c) = RND + .01: stary(c) = CINT(RND * 1000) - 500
    starB!(c) = RND + .01: starz(c) = CINT(RND * 400) + 1
    ' normalize hue (maximize brightness)
    maxhue! = starR!(c)
    IF starG!(c) > maxhue! THEN maxhue! = starG!(c)
    IF starB!(c) > maxhue! THEN maxhue! = starB!(c)
    starR!(c) = starR!(c) * (1 / maxhue!)
    starG!(c) = starG!(c) * (1 / maxhue!)
    starB!(c) = starB!(c) * (1 / maxhue!)
NEXT

'Main loop
REDIM px!(N), py!(N), radius!(N), radsquared!(N), szfactor!(N)
REDIM blur(0 TO 63999, 0 TO 2) AS SINGLE ' Blur buffer
ambient! = .05 / SQR(N)
WHILE INKEY$ = ""
    ' Move each star
    FOR c = 1 TO N
        newz = starz(c) - 2
        IF newz <= 1 THEN
            rerandomize:
            newz = 1000 - RND * 10
            starx(c) = CINT(RND * 1000) - 500
            stary(c) = CINT(RND * 1000) - 500
        END IF
        starz(c) = newz
        ' Do perspective transformation
        px!(c) = starx(c) * 200! / starz(c)
        py!(c) = stary(c) * 180! / starz(c)
        radius!(c) = 900 / (starz(c) - 1)
        IF ABS(px!(c) + radius!(c)) > 230 THEN GOTO rerandomize
        IF ABS(py!(c) + radius!(c)) > 180 THEN GOTO rerandomize
        radsquared!(c) = radius!(c) * radius!(c)
        szfactor!(c) = (1 - starz(c) / 400!)
        IF szfactor!(c) < 0 THEN szfactor!(c) = 0 ELSE szfactor!(c) = szfactor!(c) ^ 2
    NEXT
    ' Render each pixel
    c& = 0
    FOR y = -99 TO 100 STEP 1
        FOR x = -159 TO 160 STEP 1
            R! = blur(c&, 0)
            G! = blur(c&, 1)
            B! = blur(c&, 2)
            FOR c = 1 TO N
                'Determine how much this star affects the pixel color
                distx! = x - px!(c)
                disty! = y - py!(c)
                distsquared! = distx! * distx! + disty! * disty!
                IF distsquared! < radsquared!(c) THEN
                    distance! = SQR(distsquared!)
                    scaleddist! = distance! / radius!(c)
                    sz! = (1 - SQR(scaleddist!)) * szfactor!(c)
                    R! = R! + starR!(c) * sz! + ambient!
                    G! = G! + starG!(c) * sz! + ambient!
                    B! = B! + starB!(c) * sz! + ambient!
                END IF
            NEXT
            ' Save the color for motion blur (fade it a little)
            blur(c&, 0) = R! * .83
            blur(c&, 1) = G! * .83
            blur(c&, 2) = B! * .83
            ' Leak (some of) possible excess brightness to other color channels
            ' (Note: This algorithm was fixed and improved after the Youtube video)
            luma! = R! * 0.299 + G! * 0.298 + B! * 0.114
            IF luma! >= 1 THEN
                R! = 1: G! = 1: B! = 1
            ELSEIF luma! <= 0 THEN
                R! = 0: G! = 0: B! = 0
            ELSE
                sat! = 1
                IF R! > 1 THEN
                    sat! = min!(sat!, (luma! - 1) / (luma! - R!))
                ELSEIF R! < 0 THEN
                    sat! = min!(sat!, luma! / (luma! - R!))
                END IF
                IF G! > 1 THEN
                    sat! = min!(sat!, (luma! - 1) / (luma! - G!))
                ELSEIF G! < 0 THEN
                    sat! = min!(sat!, luma! / (luma! - G!))
                END IF
                IF B! > 1 THEN
                    sat! = min!(sat!, (luma! - 1) / (luma! - B!))
                ELSEIF B! < 0 THEN
                    sat! = min!(sat!, luma! / (luma! - B!))
                END IF
                IF sat! < 1 THEN
                    R! = (R! - luma!) * sat! + luma!
                    G! = (G! - luma!) * sat! + luma!
                    B! = (B! - luma!) * sat! + luma!
                END IF
            END IF
            ' Quantize (use gamma-aware Knoll-Yliluoma positional dithering)
            errorR! = 0: gammaR! = R! ^ gamma
            errorG! = 0: gammaG! = G! ^ gamma
            errorB! = 0: gammaB! = B! ^ gamma
            ' Create color candidate table.
            FOR c = 1 TO candcount
                tryR! = clamp01!(gammaR! + errorR!) ^ ungamma
                tryG! = clamp01!(gammaG! + errorG!) ^ ungamma
                tryB! = clamp01!(gammaB! + errorB!) ^ ungamma
                ' Find out which palette color is the best match
                chosen = 0: best! = 0
                FOR p = 0 TO 252
                    eR! = Pal(p, 0) - tryR!
                    eG! = Pal(p, 1) - tryG!
                    eB! = Pal(p, 2) - tryB!
                    test! = eR! * eR! + eG! * eG! + eB! * eB!
                    IF p = 0 OR test! < best! THEN best! = test!: chosen = p
                NEXT
                colortab(c) = chosen
                ' Find out how much it differs from the desired value
                errorR! = gammaR! - PalG(chosen, 0)
                errorG! = gammaG! - PalG(chosen, 1)
                errorB! = gammaB! - PalG(chosen, 2)
            NEXT
            ' Sort the color candidate table by luma.
            ' Since palette colors are already sorted by luma,
            ' we can simply sort by palette indices.
            ' Use insertion sort. (A bug was fixed here after publication.)
            FOR j = 2 TO candcount
                k = colortab(j)
                FOR i = j TO 2 STEP -1
                    IF colortab(i) <= k THEN EXIT FOR
                    colortab(i) = colortab(i - 1)
                NEXT
                colortab(i) = k
            NEXT
            ' Plot the pixel to the screen
            ' (Note: Double-buffering was removed for QB64
            '  because it does not support the assembler function.)
            DEF SEG = &HA000
            POKE c&, colortab(dither8x8(x AND 7, y AND 7))
            c& = c& + 1
    NEXT x, y
WEND

PRINT "Done"
END

' Allright! Time for a show.

' Enjoyed it? :)

' Define a function for clamping a value to 0..1 range
FUNCTION clamp01! (v!)
    IF v! < 0 THEN
        clamp01! = 0
    ELSEIF v! > 1 THEN
        clamp01! = 1
    ELSE
        clamp01! = v!
    END IF
END FUNCTION

FUNCTION min! (a!, b!)
    min! = b!
    IF a! < b! THEN min! = a!
END FUNCTION
