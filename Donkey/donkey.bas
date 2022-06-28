' The IBM Personal Computer Donkey
' Version 1.10 (C)Copyright IBM Corp 1981, 1982
' Licensed Material - Program Property of IBM

' Updated by a740g to work on QB64
' TODO: Fix few graphical glitches

$NoPrefix
$Resize:Smooth

Option Explicit
Option ExplicitArray

' All global variables and arrays
Dim As String cmd
Dim As Single i, cx, cy, y, sd, sm, z, z1
Dim As Integer dx, d1x, d1y, d2x, c1x, c1y, c2x, p
Dim As Integer D1(150), D2(150), C1(200), C2(200)
Dim As Integer DNK(300), CAR(300), B(300)

' Welcome screen
FullScreen SquarePixels , Smooth
Screen 0, 1
Color 15, 0
Width 40
Cls
Locate 5, 19
Print "IBM"
Locate 7, 12
Print "Personal Computer"
Color 10, 0
Locate 10, 9
Print Chr$(213) + String$(21, 205) + Chr$(184)
Locate 11, 9
Print Chr$(179) + "       DONKEY        " + Chr$(179)
Locate 12, 9
Print Chr$(179) + String$(21, 32) + Chr$(179)
Locate 13, 9
Print Chr$(179) + "    Version 1.1O     " + Chr$(179)
Locate 14, 9
Print Chr$(212) + String$(21, 205) + Chr$(190)
Color 15, 0
Locate 17, 4
Print "(C) Copyright IBM Corp 1981, 1982"
Color 14, 0
Locate 23, 7
Print "Press space bar to continue"

Do
    cmd = InKey$
    If cmd = Chr$(27) Then System
Loop Until cmd = " "

' Main game code starts here
Play "p16"
Color 0
Screen 1, 0
Color 8, 1

' Get the donkey bitmap
Cls
Draw "S08"
Draw "BM14,18"
Draw "M+2,-4R8M+1,-1U1M+1,+1M+2,-1"
Draw "M-1,1M+1,3M-1,1M-1,-2M-1,2"
Draw "D3L1U3M-1,1D2L1U2L3D2L1U2M-1,-1"
Draw "D3L1U5M-2,3U1"
Paint (21, 14), 3
PReset (37, 10)
PReset (40, 10)
PReset (37, 11)
PReset (40, 11)
Get (13, 0)-(45, 25), DNK()

' Get the car bitmap
Cls
Draw "S8C3"
Draw "BM12,1r3m+1,3d2R1ND2u1r2d4l2u1l1"
Draw "d7R1nd2u2r3d6l3u2l1d3m-1,1l3"
Draw "m-1,-1u3l1d2l3u6r3d2nd2r1u7l1d1l2"
Draw "u4r2d1nd2R1U2"
Draw "M+1,-3"
Draw "BD10D2R3U2M-1,-1L1M-1,1"
Draw "BD3D1R1U1L1BR2R1D1L1U1"
Draw "BD2BL2D1R1U1L1BR2R1D1L1U1"
Draw "BD2BL2D1R1U1L1BR2R1D1L1U1"
Line (0, 0)-(40, 60), , B
Paint (1, 1)
Get (1, 1)-(29, 45), CAR()

' This is for the strips on the road
Cls
For i = 2 To 300
    B(i) = -16384 + 192
Next
B(0) = 2
B(1) = 193

' This loops just starts a new game
Do
    cx = 110
    Cls
    Line (0, 0)-(305, 199), , B
    Line (6, 6)-(97, 195), 1, BF
    Line (183, 6)-(305, 195), 1, BF
    Locate 3, 5
    Print "Donkey"
    Locate 3, 29
    Print "Driver"
    Locate 19, 25
    Print "Press Space  ";
    Locate 20, 25
    Print "Bar to switch";
    Locate 21, 25
    Print "lanes        ";
    Locate 23, 25
    Print "Press ESC    ";
    Locate 24, 25
    Print "to exit      ";
    For y = 4 To 199 Step 20
        Line (140, y)-(140, y + 10)
    Next
    cy = 105
    cx = 105
    Line (100, 0)-(100, 199)
    Line (180, 0)-(180, 199)

    ' This is the main game loop
    Do
        Locate 5, 6
        Print sd
        Locate 5, 31
        Print sm
        cy = cy - 4

        ' Exit the main loop if donkey loses the game
        If cy < 60 Then
            sm = sm + 1
            Locate 7, 25
            Print "Donkey loses!"
            Sleep 2
            Cls
            Exit Do
        End If

        Put (cx, cy), CAR(), PReset
        dx = 105 + 42 * Int(Rnd * 2)

        For y = (Rnd * -4) * 8 To 124 Step 6

            Sound 20000, 1

            cmd = InKey$

            ' Exit to the OS if Esc is pressed
            If cmd = Chr$(27) Then System

            ' Move car is a key is pressed
            If Len(cmd) > 0 Then
                Line (cx, cy)-(cx + 28, cy + 44), 0, BF
                cx = 252 - cx
                Put (cx, cy), CAR(), PReset
                Sound 200, 1
            End If

            If y >= 3 Then Put (dx, y), DNK(), PSet

            ' If there is a collision then show some fancy animation and exit the main loop
            If cx = dx And y + 25 >= cy Then
                sd = sd + 1
                Locate 14, 6
                Print "BOOM!"
                Get (dx, y)-(dx + 16, y + 25), D1()
                d1x = dx
                d1y = y
                d2x = dx + 17
                Get (dx + 17, y)-(dx + 31, y + 25), D2()
                Get (cx, cy)-(cx + 14, cy + 44), C1()
                Get (cx + 15, cy)-(cx + 28, cy + 44), C2()
                c1x = cx
                c1y = cy
                c2x = cx + 15

                For p = 6 To 0 Step -1
                    z = 1 / (2 ^ p)
                    z1 = 1 - z
                    Put (c1x, c1y), C1()
                    Put (c2x, c1y), C2()
                    Put (d1x, d1y), D1()
                    Put (d2x, d1y), D2()
                    c1x = cx * z1
                    d1y = y * z1
                    c2x = c2x + (291 - c2x) * z
                    d1x = dx * z1
                    c1y = c1y + (155 - c1y) * z
                    d2x = d2x + (294 - d2x) * z
                    Put (c1x, c1y), C1()
                    Put (c2x, c1y), C2()
                    Put (d1x, d1y), D1()
                    Put (d2x, d1y), D2()
                    Sound 37 + Rnd * 200, 4
                    Limit 10
                Next

                Sleep 2
                Cls
                Exit Do
            End If

            If y And 3 Then Put (140, 6), B()
            Limit 10
        Next

        Line (dx, 124)-(dx + 32, 149), 0, BF
    Loop
Loop

