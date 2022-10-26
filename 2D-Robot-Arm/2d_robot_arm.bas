Option _Explicit 'No typos, m'kay?
'NOTE: THIS PROGRAM WILL MOST LIKELY NOT COMPILE ON QB 1.1. THIS PROGRAM REQUIRES QB64.
Const SCRWIDTH = 900
Const SCRHEIGHT = 900
Screen _NewImage(SCRWIDTH, SCRHEIGHT, 256)
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
Call GENERATE_AXES(1)
Const DURATION = 3 'Seconds
Const FPS = 30
Dim Shared STEPS As Integer 'Section: Animation
Dim Shared DELAYTIME As Single 'Section: Animation
Dim L1, L2 As Single 'Arms length
Dim Shared Q1, Q2, Q3, Q4 As Single 'Angles (generally in radians, except briefly in PRGMODE = 0)
Dim Shared EPSILON As Single 'Approx. zero
Dim INPX, INPY As Single 'Final arm, initial upper coordinates
Dim INPXTEMP, INPYTEMP As Single 'Final arm, temporary upper coordinates. Section: Animation
Dim INPXFIN, INPYFIN As Single 'Final arm, final upper coordinates. Section: Animation
Dim DIR_SOLUTION As _Unsigned _Byte 'Left or right-handed solution. Boolean.
Dim MOUSE_INPUT As _Unsigned _Byte 'Mouse input enable/disable. Boolean.
Dim ISCLICKED As _Bit 'Section: Mouse Input. Boolean.
Dim PRGMODE As _Unsigned _Byte 'Input angles or degrees initially. Boolean.
Dim LAMBDA As Single 'y = lambda * x + beta. Line equation
Dim DELTA As Single ' delta = b^2 - 4ac
Dim BETA As Single 'Line equation
Dim XCIRC, YCIRC As Single 'Circle intersection Solutions.
Dim Shared PI As Single
Dim Shared SOLXANIM, SOLYANIM As Single 'Coordinates of upper-lower arm intersection. Section: animation
Dim Shared I As Integer 'Every programmer's favourite variable for loops. :)
PI = 3.14159265358979323
EPSILON = 0.0001
STEPS = DURATION * FPS
DELAYTIME = 1 / FPS
Dim Shared ERR_COUNTER As _Unsigned _Byte 'Error counter.
Call WATERMARK

'Mouse Input Enable/Disable
ERR_COUNTER = 0
Do
    If ERR_COUNTER > 0 Then
        Print "Invalid value."
    End If
    Input "Enable Mouse Input? (0: No, 1: Yes): ", MOUSE_INPUT
    ERR_COUNTER = ERR_COUNTER + 1
Loop Until MOUSE_INPUT = 0 Or MOUSE_INPUT = 1

'Program Choice
ERR_COUNTER = 0
Do
    If ERR_COUNTER > 0 Then
        Print "Invalid value."
    End If
    Input "Input Angles or Coordinates? (0: Ang, 1: Coord): ", PRGMODE
    ERR_COUNTER = ERR_COUNTER + 1
Loop Until PRGMODE = 1 Or PRGMODE = 0

'Set Length
ERR_COUNTER = 0
Do
    If ERR_COUNTER > 0 Then
        Print "Error, value too large or null"
    End If
    Input "Input length of arm 1 in pixels: ", L1
    Input "Input length of arm 2 in pixels: ", L2
    ERR_COUNTER = ERR_COUNTER + 1
Loop Until (L1 + L2) < SCRWIDTH / 2 And (L1 + L2) < SCRHEIGHT / 2 And L2 > 0 And L1 > 0

Call GENERATE_CIRCLES(L1, L2, 5)

'Set Angle (Fwd)
ERR_COUNTER = 0
If PRGMODE = 0 Then
    Do
        If ERR_COUNTER > 0 Then
            Print "Error, value too large"
        End If

        Input "Input angle of arm 1 in degrees: ", Q1
        Input "Input angle of arm 2 in degrees: ", Q2
        ERR_COUNTER = ERR_COUNTER + 1
    Loop Until Q1 < 360 And Q2 < 360 And Q1 >= 0 And Q2 >= 0 And Q2 <> 180
End If


' =========================
'Forward kinematic problem:
If PRGMODE = 0 Then
    Call GENERATE_AXES(1)
    Call GENERATE_CIRCLES(L1, L2, 5)
    Line (GETX(0), GETY(0))-(GETX(L1 * Cos(GETPHI(Q1))), GETY(L1 * Sin(GETPHI(Q1)))), 13
    Line (GETX(L1 * Cos(GETPHI(Q1))), GETY(L1 * Sin(GETPHI(Q1))))-(GETX(L1 * Cos(GETPHI(Q1)) + L2 * Cos(GETPHI(Q1 + Q2))), GETY(L1 * Sin(GETPHI(Q1)) + L2 * Sin(GETPHI(Q1 + Q2)))), 13
    SOLXANIM = GETX(L1 * Cos(GETPHI(Q1))) 'Degrees to coordinates, basically
    SOLYANIM = GETY(L1 * Sin(GETPHI(Q1)))
    INPX = (L1 * Cos(GETPHI(Q1)) + L2 * Cos(GETPHI(Q1 + Q2)))
    INPY = (L1 * Sin(GETPHI(Q1)) + L2 * Sin(GETPHI(Q1 + Q2)))
    If Q2 < 180 Then
        DIR_SOLUTION = 1
    ElseIf Q2 >= 180 Then
        DIR_SOLUTION = 0
    End If

End If

' =========================
'Inverse Kinematic Problem:
If PRGMODE = 1 Then
    'Direction Choice
    ERR_COUNTER = 0
    Do
        If ERR_COUNTER > 0 Then
            Print "Invalid value."
        End If
        Input "Right-Handed or Left-Handed Solution? (0: Right, 1: Left): ", DIR_SOLUTION
    Loop Until DIR_SOLUTION = 0 Or DIR_SOLUTION = 1

    'Coordinate Selection
    ERR_COUNTER = 0
    Do
        If ERR_COUNTER > 0 Then
            Print "Error, coordinates too small or too large."
        End If
        If MOUSE_INPUT = 0 Then
            Input "Input X coordinate in pixels: ", INPX
            Input "Input Y coordinate in pixels: ", INPY
        ElseIf MOUSE_INPUT = 1 Then
            Print "Click to place coordinates."
            Do
                _Limit 20 'So that it doesn't run too often and cause problems
                While _MouseInput
                    INPX = _MouseX - GETX(0) 'Mouse coordinates
                    INPY = GETY(_MouseY)
                    ISCLICKED = _MouseButton(1) 'Left click
                Wend
            Loop Until ISCLICKED = -1
        End If
        ERR_COUNTER = ERR_COUNTER + 1
    Loop Until Sqr(INPX ^ 2 + INPY ^ 2) > Abs(L1 - L2) And Sqr(INPX ^ 2 + INPY ^ 2) <= Abs(L1 + L2)
    Cls
    Call GENERATE_AXES(1)
    Call GENERATE_CIRCLES(L1, L2, 5)
    Call GENERATE_ARMS(INPX, INPY, L1, L2, DIR_SOLUTION, 13)
    Call WATERMARK
End If


DELAY (0.5) 'Prevent accidental clicks
'Animation section
'=====================

'Coordinate Selection 2: Electric Boogaloo
ERR_COUNTER = 0
Do
    If ERR_COUNTER > 0 Then
        If DELTA < 0 Then
            Print "Error, coordinates too small or too large."
        End If
        If DELTA >= 0 Then
            Print "Error, inner workspace limit intersection."
            Line (GETX(INPX), GETY(INPY))-(GETX(INPXFIN), GETY(INPYFIN)), 4
        End If
    End If
    If MOUSE_INPUT = 0 Then
        Input "Input Final X coordinate in pixels: ", INPXFIN
        Input "Input Final Y coordinate in pixels: ", INPYFIN

    ElseIf MOUSE_INPUT = 1 Then
        Print "Click to place coordinates."
        Do
            _Limit 20
            While _MouseInput
                INPXFIN = _MouseX - GETX(0)
                INPYFIN = GETY(_MouseY)
                ISCLICKED = _MouseButton(1)
            Wend
        Loop Until ISCLICKED = -1
    End If
    Print INPXFIN, " ", INPYFIN

    Cls
    Call GENERATE_AXES(1)
    Call GENERATE_CIRCLES(L1, L2, 5)
    Call GENERATE_ARMS(INPX, INPY, L1, L2, DIR_SOLUTION, 13)
    Call WATERMARK

    'Line Checking using the equation of a circle and a line
    LAMBDA = (INPYFIN - INPY) / (INPXFIN - INPX) 'dy/dx.
    BETA = INPY - LAMBDA * INPX 'line equation
    DELTA = (2 * LAMBDA * BETA) ^ 2 - 4 * ((1 + LAMBDA ^ 2) * (BETA ^ 2 - (L1 - L2) ^ 2)) 'b^2-4ac
    ERR_COUNTER = ERR_COUNTER + 1
    If DELTA >= 0 And Sqr(INPXFIN ^ 2 + INPYFIN ^ 2) >= Abs(L1 - L2) And Sgn(INPXFIN) = Sgn(INPX) And Sgn(INPYFIN) = Sgn(INPY) Then
        DELTA = -1 'Prevent pseudo-error where there equations check out but there are no actual roots
    End If
    If DELTA >= 0 Then 'Show line-circle intersections
        XCIRC = (-(2 * LAMBDA * BETA) + Sqr(DELTA)) / (2 * (1 + LAMBDA ^ 2))
        YCIRC = LAMBDA * XCIRC + BETA
        Circle (GETX(XCIRC), GETY(YCIRC)), 2, 4
        XCIRC = (-(2 * LAMBDA * BETA) - Sqr(DELTA)) / (2 * (1 + LAMBDA ^ 2))
        YCIRC = LAMBDA * XCIRC + BETA
        Circle (GETX(XCIRC), GETY(YCIRC)), 2, 4
    End If
Loop Until DELTA < 0 And Sqr(INPXFIN ^ 2 + INPYFIN ^ 2) <= Abs(L1 + L2)

'Animation Loop
Call GENERATE_ARMS(INPX, INPY, L1, L2, DIR_SOLUTION, 0)
Line (GETX(INPX), GETY(INPY))-(GETX(INPXFIN), GETY(INPYFIN)), 4
For I = 0 To STEPS 'I'm just a simple loop trying to make my way into the galaxy
    If I Mod 5 = 1 Then 'Limit how often the axes and circles are renewed.
        Call GENERATE_AXES(1)
        Call GENERATE_CIRCLES(L1, L2, 5)
    End If
    Line (GETX(INPX), GETY(INPY))-(GETX(INPXFIN), GETY(INPYFIN)), 4
    INPXTEMP = (INPXFIN - INPX) * I / STEPS + INPX 'Quantise the animation line
    INPYTEMP = (INPYFIN - INPY) * I / STEPS + INPY
    Call GENERATE_ARMS(INPXTEMP, INPYTEMP, L1, L2, DIR_SOLUTION, 13)
    Call DELAY(DELAYTIME)
    Call GENERATE_ARMS(INPXTEMP, INPYTEMP, L1, L2, DIR_SOLUTION, 0)
Next I
Call GENERATE_ARMS(INPXFIN, INPYFIN, L1, L2, DIR_SOLUTION, 13)

Call GENERATE_ARMS(INPXFIN, INPYFIN, L1, L2, DIR_SOLUTION, 13)




End



'This bad boy generates cartesian axes
'in the middle of your window
'(A) where A = DOS Colour
Sub GENERATE_AXES (COLOUR As Integer)
    Line (0, SCRHEIGHT / 2)-(SCRWIDTH, SCRHEIGHT / 2), COLOUR
    Line (SCRWIDTH / 2, 0)-(SCRWIDTH / 2, SCRHEIGHT), COLOUR
End Sub

'Convert the screen's cartesian system to human-intuitive
'Cartesian coordinates at the generated axes' (0.0)
Function GETX (X_CART As Single)
    GETX = SCRWIDTH / 2 + X_CART
End Function
Function GETY (Y_CART As Single)
    GETY = SCRHEIGHT / 2 - Y_CART
End Function

'Radians to Degrees
Function GETPHI (RADIANS As Single)
    GETPHI = (RADIANS / 180) * PI
End Function

'Arctan but with with signs
Function ATAN2 (X_ATAN As Single, Y_ATAN As Single)
    If X_ATAN > EPSILON And Y_ATAN >= 0 Then 'First Quadrant
        ATAN2 = Atn(Y_ATAN / X_ATAN)
    ElseIf X_ATAN > EPSILON And Y_ATAN < 0 Then 'Fourth Quadrant
        ATAN2 = Atn(Y_ATAN / X_ATAN) + 2 * PI
    ElseIf X_ATAN < (EPSILON * (-1)) And Y_ATAN >= 0 Then 'Second Quadrant
        ATAN2 = Atn(Y_ATAN / X_ATAN) + PI
    ElseIf X_ATAN < (EPSILON * (-1)) And Y_ATAN < 0 Then 'Third Quadrant
        ATAN2 = Atn(Y_ATAN / X_ATAN) + PI
    ElseIf X_ATAN < Abs(EPSILON) And Y_ATAN > 0 Then '90 Degrees
        ATAN2 = PI / 2
    ElseIf X_ATAN < Abs(EPSILON) And Y_ATAN < 0 Then '270 Degrees
        ATAN2 = 3 * PI / 2
    Else
        Print "By all means, you shouldn't even be seeing this message."
        Print "We somehow glitched it all. Good job, I guess?"
    End If
End Function

'Biggest and smallest working area for the 2D robotic arm
Sub GENERATE_CIRCLES (LEN1 As Integer, LEN2 As Integer, COLOUR As Integer)
    Circle (GETX(0), GETY(0)), Abs(LEN1 + LEN2), COLOUR
    Circle (GETX(0), GETY(0)), Abs(LEN1 - LEN2), COLOUR
    If Abs(LEN1 - LEN2) = 0 Then
        Circle (GETX(0), GETY(0)), 2, COLOUR 'Feels weird without it
    End If
End Sub

Sub DELAY (TIME As Single)
    Dim START As Single
    START = Timer
    Do While START + TIME >= Timer
        If START > Timer Then START = START - 86400
    Loop
End Sub

Sub GENERATE_ARMS (INPX As Single, INPY As Single, L1 As Single, L2 As Single, DIR_SOLUTION As _Unsigned _Byte, COLOUR As Integer)
    Dim SOLX_ALPHA, SOLY_ALPHA, SOLX_BETA, SOLY_BETA As Single
    Dim XANG_ALPHA, YANG_ALPHA, XANG_BETA, YANG_BETA As Single
    Dim DET As Single
    Dim CPDF As Single

    'Geometry witchcraft
    CPDF = (INPX ^ 2 + INPY ^ 2 + L1 ^ 2 - L2 ^ 2) / 2 'c, from the PDF.
    DET = (4 * CPDF ^ 2 * INPY ^ 2) - (4 * (INPX ^ 2 + INPY ^ 2) * (CPDF ^ 2 - L1 ^ 2 * INPX ^ 2)) 'b^2 - 4ac
    If Sqr(DET) >= 0 And Abs(INPX) >= Abs(EPSILON) Then
        SOLY_ALPHA = ((2 * CPDF * INPY) + Sqr(DET)) / (2 * ((INPY ^ 2) + (INPX ^ 2))) 'upper-lower arm intersection, y coordinate, solution one
        SOLY_BETA = ((2 * CPDF * INPY) - Sqr(DET)) / (2 * ((INPY ^ 2) + (INPX ^ 2))) 'the same, but solution two
        SOLX_ALPHA = (CPDF - INPY * SOLY_ALPHA) / INPX 'the same, but for the x coordinate
        SOLX_BETA = (CPDF - INPY * SOLY_BETA) / INPX 'the same
    ElseIf Sqr(DET) >= 0 And Abs(INPX) < Abs(EPSILON) Then 'arctan idiomorphism (x -> 0, arctan -> inf)
        SOLY_ALPHA = CPDF / INPY 'pdf
        SOLY_BETA = SOLY_ALPHA
        SOLX_ALPHA = Sqr((L1 ^ 2) - ((CPDF ^ 2) / (INPY ^ 2)))
        SOLX_BETA = (-1) * Sqr((L1 ^ 2) - ((CPDF ^ 2) / (INPY ^ 2)))
    Else
        Print "Invalid movement."
    End If

    'Let this be the hour when we draw LINEs together! Fell deeds awake. Now for wrath, now for ruin, and the red dawn! Forth Eorlingas!
    Q1 = ATAN2(SOLX_ALPHA, SOLY_ALPHA)
    Q3 = ATAN2(SOLX_BETA, SOLY_BETA)
    XANG_ALPHA = (INPX - SOLX_ALPHA) * Cos(-Q1) - (INPY - SOLY_ALPHA) * Sin(-Q1) 'XANG = X coordinate after angle transformation
    YANG_ALPHA = (INPX - SOLX_ALPHA) * Sin(-Q1) + (INPY - SOLY_ALPHA) * Cos(-Q1) 'The same, but for the Y coordinate
    XANG_BETA = (INPX - SOLX_BETA) * Cos(-Q3) - (INPY - SOLY_BETA) * Sin(-Q3) 'The same, solution 2
    YANG_BETA = (INPX - SOLX_BETA) * Sin(-Q3) + (INPY - SOLY_BETA) * Cos(-Q3) 'Same
    Q2 = ATAN2(XANG_ALPHA, YANG_ALPHA)
    Q4 = ATAN2(XANG_BETA, YANG_BETA)
    If DIR_SOLUTION = 0 Then
        If Q2 >= 0 And Q2 < PI Then

            Line (GETX(0), GETY(0))-(GETX(L1 * Cos(Q3)), GETY(L1 * Sin(Q3))), COLOUR
            Line (GETX(L1 * Cos(Q3)), GETY(L1 * Sin(Q3)))-(GETX(L1 * Cos(Q3) + L2 * Cos(Q3 + Q4)), GETY(L1 * Sin(Q3) + L2 * Sin(Q3 + Q4))), COLOUR
            SOLXANIM = GETX(L1 * Cos(Q3))
            SOLYANIM = GETY(L1 * Sin(Q3))
        ElseIf Q2 >= PI And Q2 <= 2 * PI Then
            Line (GETX(0), GETY(0))-(GETX(L1 * Cos(Q1)), GETY(L1 * Sin(Q1))), COLOUR
            Line (GETX(L1 * Cos(Q1)), GETY(L1 * Sin(Q1)))-(GETX(L1 * Cos(Q1) + L2 * Cos(Q1 + Q2)), GETY(L1 * Sin(Q1) + L2 * Sin(Q1 + Q2))), COLOUR
            SOLXANIM = GETX(L1 * Cos(Q1))
            SOLYANIM = GETY(L1 * Sin(Q1))
        End If
    ElseIf DIR_SOLUTION = 1 Then
        If Q4 >= 0 And Q4 < PI Then
            Line (GETX(0), GETY(0))-(GETX(L1 * Cos(Q3)), GETY(L1 * Sin(Q3))), COLOUR
            Line (GETX(L1 * Cos(Q3)), GETY(L1 * Sin(Q3)))-(GETX(L1 * Cos(Q3) + L2 * Cos(Q3 + Q4)), GETY(L1 * Sin(Q3) + L2 * Sin(Q3 + Q4))), COLOUR
        ElseIf Q4 >= PI And Q4 <= 2 * PI Then
            Line (GETX(0), GETY(0))-(GETX(L1 * Cos(Q1)), GETY(L1 * Sin(Q1))), COLOUR
            Line (GETX(L1 * Cos(Q1)), GETY(L1 * Sin(Q1)))-(GETX(L1 * Cos(Q1) + L2 * Cos(Q1 + Q2)), GETY(L1 * Sin(Q1) + L2 * Sin(Q1 + Q2))), COLOUR
        End If
    Else
        Print "How did we get here?"
    End If
End Sub

Sub WATERMARK
    'R a i n b o w s
    Print "Robotics Lab Project, by ";
    Color 4: Print "B";
    Color 6: Print "a";
    Color 14: Print "n";
    Color 10: Print "t";
    Color 2: Print "i";
    Color 11: Print "s";
    Print " ";
    Color 3: Print "A";
    Color 9: Print "s";
    Color 1: Print "t";
    Color 13: Print "e";
    Color 5: Print "r";
    Color 12: Print "i";
    Color 4: Print "o";
    Color 6: Print "s"
    Color 15: Print "'GNU GENERAL PUBLIC LICENSE V2"
    Color 15: Print "900x900"
    Print " "
End Sub

