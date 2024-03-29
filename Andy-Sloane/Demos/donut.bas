' QB64-PE port of https://www.a1k0n.net/2011/07/20/donut-math.html
' a740g, 2024

OPTION _EXPLICIT

CONST TWO_PI! = _PI(2!)
CONST THETA_SPACING! = 0.07!
CONST PHI_SPACING! = 0.02!
CONST R1! = 1!
CONST R2! = 2!
CONST K2_DEFAULT! = 5!
CONST A_STEP! = 0.035!
CONST B_STEP! = 0.015!

SCREEN 0: _FONT 8: WIDTH 80, 50

DIM AS LONG screenWidth: screenWidth = _WIDTH
DIM AS LONG screenHeight: screenHeight = _HEIGHT

DIM k2 AS SINGLE: k2 = K2_DEFAULT
DIM k1 AS SINGLE: k1 = screenWidth * k2 * 3! / (8! * (R1 + R2))

REDIM frame(0 TO screenWidth - 1, 0 TO screenHeight - 1) AS _UNSIGNED _BYTE
REDIM zbuffer(0 TO screenWidth - 1, 0 TO screenHeight - 1) AS SINGLE

DO
    DIM k AS LONG: k = _KEYHIT

    SELECT CASE k
        CASE 18432
            k2 = k2 + 0.1!

        CASE 20480
            k2 = k2 - 0.1!
            IF k2 <= 1! THEN k2 = 1!

    END SELECT

    DIM a AS SINGLE: a = a + A_STEP
    DIM b AS SINGLE: b = b + B_STEP

    DIM cosA AS SINGLE: cosA = COS(a)
    DIM sinA AS SINGLE: sinA = SIN(a)
    DIM cosB AS SINGLE: cosB = COS(b)
    DIM sinB AS SINGLE: sinB = SIN(b)

    DIM theta AS SINGLE: theta = 0!
    WHILE theta < TWO_PI
        DIM costheta AS SINGLE: costheta = COS(theta)
        DIM sintheta AS SINGLE: sintheta = SIN(theta)

        DIM phi AS SINGLE: phi = 0!
        WHILE phi < TWO_PI
            DIM cosphi AS SINGLE: cosphi = COS(phi)
            DIM sinphi AS SINGLE: sinphi = SIN(phi)

            DIM circlex AS SINGLE: circlex = R2 + R1 * costheta
            DIM circley AS SINGLE: circley = R1 * sintheta

            DIM x AS SINGLE: x = circlex * (cosB * cosphi + sinA * sinB * sinphi) - circley * cosA * sinB
            DIM y AS SINGLE: y = circlex * (sinB * cosphi - sinA * cosB * sinphi) + circley * cosA * cosB
            DIM z AS SINGLE: z = k2 + cosA * circlex * sinphi + circley * sinA
            DIM ooz AS SINGLE: ooz = 1! / z

            DIM xp AS LONG: xp = screenWidth \ 2 + k1 * ooz * x
            DIM yp AS LONG: yp = screenHeight \ 2 - k1 * ooz * y

            IF xp >= 0 AND xp < screenWidth AND yp >= 0 AND yp < screenHeight THEN
                DIM L AS SINGLE: L = cosphi * costheta * sinB - cosA * costheta * sinphi - sinA * sintheta + cosB * (cosA * sintheta - costheta * sinA * sinphi)
                IF ooz > zbuffer(xp, yp) THEN
                    zbuffer(xp, yp) = ooz
                    DIM luminanceIndex AS LONG: luminanceIndex = L * 8!
                    IF luminanceIndex > 0 THEN
                        frame(xp, yp) = ASC(".,-~:;=!*#$@", luminanceIndex)
                    ELSE
                        frame(xp, yp) = 32
                    END IF
                END IF
            END IF

            phi = phi + PHI_SPACING
        WEND
        theta = theta + THETA_SPACING
    WEND

    FOR yp = 1 TO screenHeight
        FOR xp = 1 TO screenWidth
            _PRINTSTRING (xp, yp), CHR$(frame(xp - 1, yp - 1))
        NEXT xp
    NEXT yp

    REDIM frame(0 TO screenWidth - 1, 0 TO screenHeight - 1) AS _UNSIGNED _BYTE
    REDIM zbuffer(0 TO screenWidth - 1, 0 TO screenHeight - 1) AS SINGLE

    _DISPLAY

    _LIMIT 60
LOOP UNTIL k = 27

SYSTEM
