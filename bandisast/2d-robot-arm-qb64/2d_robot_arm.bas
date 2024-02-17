OPTION _EXPLICIT 'No typos, m'kay?
'NOTE: THIS PROGRAM WILL MOST LIKELY NOT COMPILE ON QB 1.1. THIS PROGRAM REQUIRES QB64.
CONST SCRWIDTH = 900
CONST SCRHEIGHT = 900
SCREEN _NEWIMAGE(SCRWIDTH, SCRHEIGHT, 256)
'2021-01-01 Version - Bantis Asterios
'GNU GENERAL PUBLIC LICENSE V2
'BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. 
'EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, 
'EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
'THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, 
'REPAIR OR CORRECTION.
'IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE,
'BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO
'LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), 
'EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
CALL GENERATE_AXES(1)
CONST DURATION = 3 'Seconds
CONST FPS = 30
DIM SHARED STEPS AS INTEGER 'Section: Animation
DIM SHARED DELAYTIME AS SINGLE 'Section: Animation
DIM L1, L2 AS SINGLE 'Arms length
DIM SHARED Q1, Q2, Q3, Q4 AS SINGLE 'Angles (generally in radians, except briefly in PRGMODE = 0)
DIM SHARED EPSILON AS SINGLE 'Approx. zero
DIM INPX, INPY AS SINGLE 'Final arm, initial upper coordinates
DIM INPXTEMP, INPYTEMP AS SINGLE 'Final arm, temporary upper coordinates. Section: Animation
DIM INPXFIN, INPYFIN AS SINGLE 'Final arm, final upper coordinates. Section: Animation
DIM DIR_SOLUTION AS _UNSIGNED _BYTE 'Left or right-handed solution. Boolean.
DIM MOUSE_INPUT AS _UNSIGNED _BYTE 'Mouse input enable/disable. Boolean.
DIM ISCLICKED AS _BIT 'Section: Mouse Input. Boolean.
DIM PRGMODE AS _UNSIGNED _BYTE 'Input angles or degrees initially. Boolean.
DIM LAMBDA AS SINGLE 'y = lambda * x + beta. Line equation
DIM DELTA AS SINGLE ' delta = b^2 - 4ac
DIM BETA AS SINGLE 'Line equation
DIM XCIRC, YCIRC AS SINGLE 'Circle intersection Solutions.
DIM SHARED PI AS SINGLE
DIM SHARED SOLXANIM, SOLYANIM AS SINGLE 'Coordinates of upper-lower arm intersection. Section: animation
DIM SHARED I AS INTEGER 'Every programmer's favourite variable for loops. :)
PI = 3.14159265358979323
EPSILON = 0.0001
STEPS = DURATION * FPS
DELAYTIME = 1 / FPS
DIM SHARED ERR_COUNTER AS _UNSIGNED _BYTE 'Error counter.
CALL WATERMARK

'Mouse Input Enable/Disable
ERR_COUNTER = 0
DO
    IF ERR_COUNTER > 0 THEN
        PRINT "Invalid value."
    END IF
    INPUT "Enable Mouse Input? (0: No, 1: Yes): ", MOUSE_INPUT
    ERR_COUNTER = ERR_COUNTER + 1
LOOP UNTIL MOUSE_INPUT = 0 OR MOUSE_INPUT = 1

'Program Choice
ERR_COUNTER = 0
DO
    IF ERR_COUNTER > 0 THEN
        PRINT "Invalid value."
    END IF
    INPUT "Input Angles or Coordinates? (0: Ang, 1: Coord): ", PRGMODE
    ERR_COUNTER = ERR_COUNTER + 1
LOOP UNTIL PRGMODE = 1 OR PRGMODE = 0

'Set Length
ERR_COUNTER = 0
DO
    IF ERR_COUNTER > 0 THEN
        PRINT "Error, value too large or null"
    END IF
    INPUT "Input length of arm 1 in pixels: ", L1
    INPUT "Input length of arm 2 in pixels: ", L2
    ERR_COUNTER = ERR_COUNTER + 1
LOOP UNTIL (L1 + L2) < SCRWIDTH / 2 AND (L1 + L2) < SCRHEIGHT / 2 AND L2 > 0 AND L1 > 0

CALL GENERATE_CIRCLES(L1, L2, 5)

'Set Angle (Fwd)
ERR_COUNTER = 0
IF PRGMODE = 0 THEN
    DO
        IF ERR_COUNTER > 0 THEN
            PRINT "Error, value too large"
        END IF

        INPUT "Input angle of arm 1 in degrees: ", Q1
        INPUT "Input angle of arm 2 in degrees: ", Q2
        ERR_COUNTER = ERR_COUNTER + 1
    LOOP UNTIL Q1 < 360 AND Q2 < 360 AND Q1 >= 0 AND Q2 >= 0 AND Q2 <> 180
END IF


' =========================
'Forward kinematic problem:
IF PRGMODE = 0 THEN
    CALL GENERATE_AXES(1)
    CALL GENERATE_CIRCLES(L1, L2, 5)
    LINE (GETX(0), GETY(0))-(GETX(L1 * COS(GETPHI(Q1))), GETY(L1 * SIN(GETPHI(Q1)))), 13
    LINE (GETX(L1 * COS(GETPHI(Q1))), GETY(L1 * SIN(GETPHI(Q1))))-(GETX(L1 * COS(GETPHI(Q1)) + L2 * COS(GETPHI(Q1 + Q2))), GETY(L1 * SIN(GETPHI(Q1)) + L2 * SIN(GETPHI(Q1 + Q2)))), 13
    SOLXANIM = GETX(L1 * COS(GETPHI(Q1))) 'Degrees to coordinates, basically
    SOLYANIM = GETY(L1 * SIN(GETPHI(Q1)))
    INPX = (L1 * COS(GETPHI(Q1)) + L2 * COS(GETPHI(Q1 + Q2)))
    INPY = (L1 * SIN(GETPHI(Q1)) + L2 * SIN(GETPHI(Q1 + Q2)))
    IF Q2 < 180 THEN
        DIR_SOLUTION = 1
    ELSEIF Q2 >= 180 THEN
        DIR_SOLUTION = 0
    END IF

END IF

' =========================
'Inverse Kinematic Problem:
IF PRGMODE = 1 THEN
    'Direction Choice
    ERR_COUNTER = 0
    DO
        IF ERR_COUNTER > 0 THEN
            PRINT "Invalid value."
        END IF
        INPUT "Right-Handed or Left-Handed Solution? (0: Right, 1: Left): ", DIR_SOLUTION
    LOOP UNTIL DIR_SOLUTION = 0 OR DIR_SOLUTION = 1

    'Coordinate Selection
    ERR_COUNTER = 0
    DO
        IF ERR_COUNTER > 0 THEN
            PRINT "Error, coordinates too small or too large."
        END IF
        IF MOUSE_INPUT = 0 THEN
            INPUT "Input X coordinate in pixels: ", INPX
            INPUT "Input Y coordinate in pixels: ", INPY
        ELSEIF MOUSE_INPUT = 1 THEN
            PRINT "Click to place coordinates."
            DO
                _LIMIT 20 'So that it doesn't run too often and cause problems
                WHILE _MOUSEINPUT
                    INPX = _MOUSEX - GETX(0) 'Mouse coordinates
                    INPY = GETY(_MOUSEY)
                    ISCLICKED = _MOUSEBUTTON(1) 'Left click
                WEND
            LOOP UNTIL ISCLICKED = -1
        END IF
        ERR_COUNTER = ERR_COUNTER + 1
    LOOP UNTIL SQR(INPX ^ 2 + INPY ^ 2) > ABS(L1 - L2) AND SQR(INPX ^ 2 + INPY ^ 2) <= ABS(L1 + L2)
    CLS
    CALL GENERATE_AXES(1)
    CALL GENERATE_CIRCLES(L1, L2, 5)
    CALL GENERATE_ARMS(INPX, INPY, L1, L2, DIR_SOLUTION, 13)
    CALL WATERMARK
END IF


DELAY (0.5) 'Prevent accidental clicks
'Animation section
'=====================

'Coordinate Selection 2: Electric Boogaloo
ERR_COUNTER = 0
DO
    IF ERR_COUNTER > 0 THEN
        IF DELTA < 0 THEN
            PRINT "Error, coordinates too small or too large."
        END IF
        IF DELTA >= 0 THEN
            PRINT "Error, inner workspace limit intersection."
            LINE (GETX(INPX), GETY(INPY))-(GETX(INPXFIN), GETY(INPYFIN)), 4
        END IF
    END IF
    IF MOUSE_INPUT = 0 THEN
        INPUT "Input Final X coordinate in pixels: ", INPXFIN
        INPUT "Input Final Y coordinate in pixels: ", INPYFIN

    ELSEIF MOUSE_INPUT = 1 THEN
        PRINT "Click to place coordinates."
        DO
            _LIMIT 20
            WHILE _MOUSEINPUT
                INPXFIN = _MOUSEX - GETX(0)
                INPYFIN = GETY(_MOUSEY)
                ISCLICKED = _MOUSEBUTTON(1)
            WEND
        LOOP UNTIL ISCLICKED = -1
    END IF
    PRINT INPXFIN, " ", INPYFIN

    CLS
    CALL GENERATE_AXES(1)
    CALL GENERATE_CIRCLES(L1, L2, 5)
    CALL GENERATE_ARMS(INPX, INPY, L1, L2, DIR_SOLUTION, 13)
    CALL WATERMARK

    'Line Checking using the equation of a circle and a line
    LAMBDA = (INPYFIN - INPY) / (INPXFIN - INPX) 'dy/dx.
    BETA = INPY - LAMBDA * INPX 'line equation
    DELTA = (2 * LAMBDA * BETA) ^ 2 - 4 * ((1 + LAMBDA ^ 2) * (BETA ^ 2 - (L1 - L2) ^ 2)) 'b^2-4ac
    ERR_COUNTER = ERR_COUNTER + 1
    IF DELTA >= 0 AND SQR(INPXFIN ^ 2 + INPYFIN ^ 2) >= ABS(L1 - L2) AND SGN(INPXFIN) = SGN(INPX) AND SGN(INPYFIN) = SGN(INPY) THEN
        DELTA = -1 'Prevent pseudo-error where there equations check out but there are no actual roots
    END IF
    IF DELTA >= 0 THEN 'Show line-circle intersections
        XCIRC = (-(2 * LAMBDA * BETA) + SQR(DELTA)) / (2 * (1 + LAMBDA ^ 2))
        YCIRC = LAMBDA * XCIRC + BETA
        CIRCLE (GETX(XCIRC), GETY(YCIRC)), 2, 4
        XCIRC = (-(2 * LAMBDA * BETA) - SQR(DELTA)) / (2 * (1 + LAMBDA ^ 2))
        YCIRC = LAMBDA * XCIRC + BETA
        CIRCLE (GETX(XCIRC), GETY(YCIRC)), 2, 4
    END IF
LOOP UNTIL DELTA < 0 AND SQR(INPXFIN ^ 2 + INPYFIN ^ 2) <= ABS(L1 + L2)

'Animation Loop
CALL GENERATE_ARMS(INPX, INPY, L1, L2, DIR_SOLUTION, 0)
LINE (GETX(INPX), GETY(INPY))-(GETX(INPXFIN), GETY(INPYFIN)), 4
FOR I = 0 TO STEPS 'I'm just a simple loop trying to make my way into the galaxy
    IF I MOD 5 = 1 THEN 'Limit how often the axes and circles are renewed.
        CALL GENERATE_AXES(1)
        CALL GENERATE_CIRCLES(L1, L2, 5)
    END IF
    LINE (GETX(INPX), GETY(INPY))-(GETX(INPXFIN), GETY(INPYFIN)), 4
    INPXTEMP = (INPXFIN - INPX) * I / STEPS + INPX 'Quantise the animation line
    INPYTEMP = (INPYFIN - INPY) * I / STEPS + INPY
    CALL GENERATE_ARMS(INPXTEMP, INPYTEMP, L1, L2, DIR_SOLUTION, 13)
    CALL DELAY(DELAYTIME)
    CALL GENERATE_ARMS(INPXTEMP, INPYTEMP, L1, L2, DIR_SOLUTION, 0)
NEXT I
CALL GENERATE_ARMS(INPXFIN, INPYFIN, L1, L2, DIR_SOLUTION, 13)

CALL GENERATE_ARMS(INPXFIN, INPYFIN, L1, L2, DIR_SOLUTION, 13)




END



'This bad boy generates cartesian axes
'in the middle of your window
'(A) where A = DOS Colour
SUB GENERATE_AXES (COLOUR AS INTEGER)
    LINE (0, SCRHEIGHT / 2)-(SCRWIDTH, SCRHEIGHT / 2), COLOUR
    LINE (SCRWIDTH / 2, 0)-(SCRWIDTH / 2, SCRHEIGHT), COLOUR
END SUB

'Convert the screen's cartesian system to human-intuitive
'Cartesian coordinates at the generated axes' (0.0)
FUNCTION GETX (X_CART AS SINGLE)
    GETX = SCRWIDTH / 2 + X_CART
END FUNCTION
FUNCTION GETY (Y_CART AS SINGLE)
    GETY = SCRHEIGHT / 2 - Y_CART
END FUNCTION

'Radians to Degrees
FUNCTION GETPHI (RADIANS AS SINGLE)
    GETPHI = (RADIANS / 180) * PI
END FUNCTION

'Arctan but with with signs
FUNCTION ATAN2 (X_ATAN AS SINGLE, Y_ATAN AS SINGLE)
    IF X_ATAN > EPSILON AND Y_ATAN >= 0 THEN 'First Quadrant
        ATAN2 = ATN(Y_ATAN / X_ATAN)
    ELSEIF X_ATAN > EPSILON AND Y_ATAN < 0 THEN 'Fourth Quadrant
        ATAN2 = ATN(Y_ATAN / X_ATAN) + 2 * PI
    ELSEIF X_ATAN < (EPSILON * (-1)) AND Y_ATAN >= 0 THEN 'Second Quadrant
        ATAN2 = ATN(Y_ATAN / X_ATAN) + PI
    ELSEIF X_ATAN < (EPSILON * (-1)) AND Y_ATAN < 0 THEN 'Third Quadrant
        ATAN2 = ATN(Y_ATAN / X_ATAN) + PI
    ELSEIF X_ATAN < ABS(EPSILON) AND Y_ATAN > 0 THEN '90 Degrees
        ATAN2 = PI / 2
    ELSEIF X_ATAN < ABS(EPSILON) AND Y_ATAN < 0 THEN '270 Degrees
        ATAN2 = 3 * PI / 2
    ELSE
        PRINT "By all means, you shouldn't even be seeing this message."
        PRINT "We somehow glitched it all. Good job, I guess?"
    END IF
END FUNCTION

'Biggest and smallest working area for the 2D robotic arm
SUB GENERATE_CIRCLES (LEN1 AS INTEGER, LEN2 AS INTEGER, COLOUR AS INTEGER)
    CIRCLE (GETX(0), GETY(0)), ABS(LEN1 + LEN2), COLOUR
    CIRCLE (GETX(0), GETY(0)), ABS(LEN1 - LEN2), COLOUR
    IF ABS(LEN1 - LEN2) = 0 THEN
        CIRCLE (GETX(0), GETY(0)), 2, COLOUR 'Feels weird without it
    END IF
END SUB

SUB DELAY (TIME AS SINGLE)
    DIM START AS SINGLE
    START = TIMER
    DO WHILE START + TIME >= TIMER
        IF START > TIMER THEN START = START - 86400
    LOOP
END SUB

SUB GENERATE_ARMS (INPX AS SINGLE, INPY AS SINGLE, L1 AS SINGLE, L2 AS SINGLE, DIR_SOLUTION AS _UNSIGNED _BYTE, COLOUR AS INTEGER)
    DIM SOLX_ALPHA, SOLY_ALPHA, SOLX_BETA, SOLY_BETA AS SINGLE
    DIM XANG_ALPHA, YANG_ALPHA, XANG_BETA, YANG_BETA AS SINGLE
    DIM DET AS SINGLE
    DIM CPDF AS SINGLE

    'Geometry witchcraft
    CPDF = (INPX ^ 2 + INPY ^ 2 + L1 ^ 2 - L2 ^ 2) / 2 'c, from the PDF.
    DET = (4 * CPDF ^ 2 * INPY ^ 2) - (4 * (INPX ^ 2 + INPY ^ 2) * (CPDF ^ 2 - L1 ^ 2 * INPX ^ 2)) 'b^2 - 4ac
    IF SQR(DET) >= 0 AND ABS(INPX) >= ABS(EPSILON) THEN
        SOLY_ALPHA = ((2 * CPDF * INPY) + SQR(DET)) / (2 * ((INPY ^ 2) + (INPX ^ 2))) 'upper-lower arm intersection, y coordinate, solution one
        SOLY_BETA = ((2 * CPDF * INPY) - SQR(DET)) / (2 * ((INPY ^ 2) + (INPX ^ 2))) 'the same, but solution two
        SOLX_ALPHA = (CPDF - INPY * SOLY_ALPHA) / INPX 'the same, but for the x coordinate
        SOLX_BETA = (CPDF - INPY * SOLY_BETA) / INPX 'the same
    ELSEIF SQR(DET) >= 0 AND ABS(INPX) < ABS(EPSILON) THEN 'arctan idiomorphism (x -> 0, arctan -> inf)
        SOLY_ALPHA = CPDF / INPY 'pdf
        SOLY_BETA = SOLY_ALPHA
        SOLX_ALPHA = SQR((L1 ^ 2) - ((CPDF ^ 2) / (INPY ^ 2)))
        SOLX_BETA = (-1) * SQR((L1 ^ 2) - ((CPDF ^ 2) / (INPY ^ 2)))
    ELSE
        PRINT "Invalid movement."
    END IF

    'Let this be the hour when we draw LINEs together! Fell deeds awake. Now for wrath, now for ruin, and the red dawn! Forth Eorlingas!
    Q1 = ATAN2(SOLX_ALPHA, SOLY_ALPHA)
    Q3 = ATAN2(SOLX_BETA, SOLY_BETA)
    XANG_ALPHA = (INPX - SOLX_ALPHA) * COS(-Q1) - (INPY - SOLY_ALPHA) * SIN(-Q1) 'XANG = X coordinate after angle transformation
    YANG_ALPHA = (INPX - SOLX_ALPHA) * SIN(-Q1) + (INPY - SOLY_ALPHA) * COS(-Q1) 'The same, but for the Y coordinate
    XANG_BETA = (INPX - SOLX_BETA) * COS(-Q3) - (INPY - SOLY_BETA) * SIN(-Q3) 'The same, solution 2
    YANG_BETA = (INPX - SOLX_BETA) * SIN(-Q3) + (INPY - SOLY_BETA) * COS(-Q3) 'Same
    Q2 = ATAN2(XANG_ALPHA, YANG_ALPHA)
    Q4 = ATAN2(XANG_BETA, YANG_BETA)
    IF DIR_SOLUTION = 0 THEN
        IF Q2 >= 0 AND Q2 < PI THEN

            LINE (GETX(0), GETY(0))-(GETX(L1 * COS(Q3)), GETY(L1 * SIN(Q3))), COLOUR
            LINE (GETX(L1 * COS(Q3)), GETY(L1 * SIN(Q3)))-(GETX(L1 * COS(Q3) + L2 * COS(Q3 + Q4)), GETY(L1 * SIN(Q3) + L2 * SIN(Q3 + Q4))), COLOUR
            SOLXANIM = GETX(L1 * COS(Q3))
            SOLYANIM = GETY(L1 * SIN(Q3))
        ELSEIF Q2 >= PI AND Q2 <= 2 * PI THEN
            LINE (GETX(0), GETY(0))-(GETX(L1 * COS(Q1)), GETY(L1 * SIN(Q1))), COLOUR
            LINE (GETX(L1 * COS(Q1)), GETY(L1 * SIN(Q1)))-(GETX(L1 * COS(Q1) + L2 * COS(Q1 + Q2)), GETY(L1 * SIN(Q1) + L2 * SIN(Q1 + Q2))), COLOUR
            SOLXANIM = GETX(L1 * COS(Q1))
            SOLYANIM = GETY(L1 * SIN(Q1))
        END IF
    ELSEIF DIR_SOLUTION = 1 THEN
        IF Q4 >= 0 AND Q4 < PI THEN
            LINE (GETX(0), GETY(0))-(GETX(L1 * COS(Q3)), GETY(L1 * SIN(Q3))), COLOUR
            LINE (GETX(L1 * COS(Q3)), GETY(L1 * SIN(Q3)))-(GETX(L1 * COS(Q3) + L2 * COS(Q3 + Q4)), GETY(L1 * SIN(Q3) + L2 * SIN(Q3 + Q4))), COLOUR
        ELSEIF Q4 >= PI AND Q4 <= 2 * PI THEN
            LINE (GETX(0), GETY(0))-(GETX(L1 * COS(Q1)), GETY(L1 * SIN(Q1))), COLOUR
            LINE (GETX(L1 * COS(Q1)), GETY(L1 * SIN(Q1)))-(GETX(L1 * COS(Q1) + L2 * COS(Q1 + Q2)), GETY(L1 * SIN(Q1) + L2 * SIN(Q1 + Q2))), COLOUR
        END IF
    ELSE
        PRINT "How did we get here?"
    END IF
END SUB

SUB WATERMARK
    'R a i n b o w s
    PRINT "Robotics Lab Project, by ";
    COLOR 4: PRINT "B";
    COLOR 6: PRINT "a";
    COLOR 14: PRINT "n";
    COLOR 10: PRINT "t";
    COLOR 2: PRINT "i";
    COLOR 11: PRINT "s";
    PRINT " ";
    COLOR 3: PRINT "A";
    COLOR 9: PRINT "s";
    COLOR 1: PRINT "t";
    COLOR 13: PRINT "e";
    COLOR 5: PRINT "r";
    COLOR 12: PRINT "i";
    COLOR 4: PRINT "o";
    COLOR 6: PRINT "s"
    COLOR 15: PRINT "'GNU GENERAL PUBLIC LICENSE V2"
    COLOR 15: PRINT "900x900"
    PRINT " "
END SUB
