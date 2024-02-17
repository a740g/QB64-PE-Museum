'K2.BAS: Creates graphics files for KONG.BAS, -chained by K1.BAS
'---------------------------------------------------------------
DefInt A-Z
DECLARE SUB SaveINSTR (FileNAME$)
DECLARE SUB HighLIGHT (x1%, y1%, x2%, y2%, Colr%)
DECLARE SUB PrintSTRING (x, y, Prnt$)
DECLARE SUB SaveBUILDING (x, UpSET, Building)

Dim Shared Box(1 To 26000)
Dim Shared FontBOX(5000)
Screen 12
GoSub Instructions
GoSub Buildings
GoSub TitleBAR
GoSub WinBOXES
GoSub ControlPANEL
GoSub DrawSCREEN

Cls
Out &H3C8, 7
Out &H3C9, 63
Out &H3C9, 32
Out &H3C9, 0
Line (5, 5)-(634, 474), 6, B
Line (8, 8)-(631, 471), 6, B
Line (200, 180)-(439, 290), 6, B
Line (197, 177)-(442, 293), 6, B
PrintSTRING 254, 212, "The graphics files for KONG"
PrintSTRING 243, 226, "have been successfully created."
PrintSTRING 246, 250, "You can now run the program."

a$ = Input$(1)
End

TitleBAR:
Line (0, 300)-(639, 340), 1, BF
For x = -6 To 660 Step 21
    Line (x, 309)-(x + 18, 331), 2, BF
Next x
For x = -1 To 660 Step 7
    Line (x, 302)-(x + 2, 306), 10, BF
    Line (x, 306)-(x + 2, 306), 2
    Line (x, 334)-(x + 2, 338), 10, BF
    Line (x, 338)-(x + 2, 338), 2
Next x
Line (0, 300)-(639, 300), 2
Line (0, 340)-(639, 340), 10
For x = 140 To 498
    For y = 0 To 18
        If Point(x, y) <> 0 Then
            If y > 9 Then Colr = 8 Else Colr = 15
            PSet (x, y + 314), 10
            PSet (x, y + 311), Colr
        End If
    Next y
Next x
PrintSTRING 20, 216, "Instructions"
PrintSTRING 595, 216, "EXIT"
For x = 20 To 620
    For y = 216 To 230
        If y > 222 Then Colr = 8 Else Colr = 15
        If Point(x, y) <> 0 Then PSet (x, y + 100), Colr
        PSet (x, y), 0
    Next y
Next x
Return

ControlPANEL:
Line (0, 446)-(639, 479), 7, BF
Line (0, 446)-(639, 446), 9
PSet (115, 446), 7
Draw "U10 E4 R399 F4 D10 L407 BE6 P7,7"
PSet (115, 446), 9
Draw "U10 c15 E4 c9R399 C6 F4 D10"
PSet (0, 435), 7
Draw "R52 F4 D10 L56 BE4 P7,7"
PSet (0, 435), 9
Draw "R52 c6 F4 D6"
PSet (639, 435), 7
Draw "L52 G4 D10 R56 BH4 P7,7"
PSet (639, 435), 9
Draw "L52 c15 G4 c9 D6"
PSet (215, 432), 7
Draw "U10 E4 R199 F4 D10 L207 BE5 P7,7"
PSet (215, 432), 9
Draw "U10 c15 E4 R199 c6 F4 D10"
PSet (5, 440), 4
Draw "R42 F3 D8 R70 U11 E3 R97 U11 E3 R191"
Draw "F3 D11 R97 F3 D11 R70 U8 E3 R42 D20 L628 U20 bF4 P4,4"
For y = 424 To 460 Step 5
    For x = 5 To 634
        If Point(x, y) = 4 Then PSet (x, y), 8
        If Point(x, y - 1) = 4 Then PSet (x, y - 1), 6
    Next x
Next y
For y = 424 To 460
    For x = 4 To 634
        If Point(x, y) = 4 Then PSet (x, y), 7
    Next x
Next y
'Banana Button
Line (305, 424)-(334, 450), 7, BF
Line (305, 424)-(334, 451), 9, B
Line (334, 424)-(334, 450), 6
Line (309, 428)-(330, 446), 1, BF
Line (309, 428)-(330, 446), 2, B
Line (309, 446)-(330, 446), 10
Line (330, 428)-(330, 446), 10
Line (305, 451)-(334, 451), 10
Line (305, 425)-(305, 451), 8
For x = 0 To 16
    For y = 0 To 16
        If Point(x, y) <> 0 Then
            PSet (x + 312, y + 432), 10
            PSet (x + 312, y + 430), Point(x, y)
        End If
    Next y
Next x
'Transfer KONG
For x = 198 To 256
    For y = 0 To 18
        If y > 9 Then Colr = 8 Else Colr = 15
        If Point(x, y) <> 0 Then
            PSet (x - 141, y + 452), 10
            PSet (x - 141, y + 450), Colr
        End If
    Next y
Next x
'Transfer YOUNG
For x = 424 To 500
    For y = 0 To 18
        If y > 9 Then Colr = 8 Else Colr = 15
        If Point(x, y) <> 0 Then
            PSet (x + 92, y + 452), 10
            PSet (x + 92, y + 450), Colr
        End If
    Next y
Next x
'Player LED's
Line (70, 470)-(100, 477), 8, B
Line (70, 470)-(70, 477), 6
Line (70, 470)-(100, 470), 6
Line (72, 472)-(98, 475), 10, B
Line (98, 472)-(98, 475), 8
Line (72, 475)-(98, 475), 8
Get (70, 470)-(100, 477), Box()
Put (537, 470), Box(), PSet
'Slider grooves
Line (359, 469)-(489, 475), 7, BF
Line (359, 472)-(489, 472), 10
Line (359, 471)-(489, 473), 9, B
Line (359, 471)-(359, 473), 6
Line (359, 471)-(489, 471), 6
'Get/place slider grooves
Get (354, 462)-(494, 479), Box()
Line (354, 462)-(494, 479), 7, BF
Put (135, 442), Box(), PSet
Put (364, 442), Box(), PSet
Get (245, 442)-(274, 456), Box()
Put (227, 442), Box(), PSet
Line (256, 442)-(272, 456), 7, BF
PrintSTRING 185, 462, "Force"
PrintSTRING 436, 462, "Angle"
For x = 140 To 500
    For y = 462 To 478
        If y > 468 Then Colr = 9 Else Colr = 15
        If Point(x, y) <> 7 Then PSet (x, y), Colr
    Next y
Next x
For x = 146 To 246 Step 5
    Line (x, 446)-(x, 449), 8
    Line (x, 456)-(x, 459), 8
Next x
Get (365, 440)-(380, 460), Box()
Line (365, 440)-(395, 460), 7, BF
Put (394, 440), Box(), PSet
For x = 404 To 494 Step 5
    Line (x, 446)-(x, 449), 8
    Line (x, 456)-(x, 459), 8
Next x
Line (255, 442)-(278, 460), 7, BF
Line (255, 442)-(276, 460), 10, BF
Line (255, 442)-(276, 460), 9, B
Line (255, 442)-(276, 442), 6
Line (255, 442)-(255, 460), 6
PrintSTRING 260, 446, "00"
Line (362, 442)-(385, 460), 7, BF
Line (364, 442)-(385, 460), 10, BF
Line (364, 442)-(385, 460), 9, B
Line (364, 442)-(364, 460), 6
Line (364, 442)-(385, 442), 6
PrintSTRING 369, 446, "00"
'Transfer Cupola
For x = 61 To 95
    For y = 48 To 74
        If Point(x, y) <> 0 Then
            PSet (x - 52, y + 360), Point(x, y)
            PSet (690 - x, y + 360), Point(x, y)
        End If
    Next y
Next x
Circle (123, 440), 5, 4
Paint Step(0, 0), 4
Circle Step(0, 0), 5, 9
Paint Step(0, 0), 7, 9
Circle Step(0, 0), 5, 6, 3.1, 0
Circle (513, 440), 5, 4
Paint Step(0, 0), 4
Circle Step(0, 0), 5, 9
Paint Step(0, 0), 7, 9
Circle Step(0, 0), 5, 6, 3.1, 0
Circle (223, 426), 5, 4
Paint Step(0, 0), 4
Circle Step(0, 0), 5, 9
Paint Step(0, 0), 7, 9
Circle Step(0, 0), 5, 6, 3.1, 0
Circle (413, 426), 5, 4
Paint Step(0, 0), 4
Circle Step(0, 0), 5, 9
Paint Step(0, 0), 7, 9
Circle Step(0, 0), 5, 6, 3.1, 0
Line (290, 461)-(350, 477), 9, B
Line (350, 461)-(350, 477), 6
Line (290, 477)-(350, 477), 6
Line (290, 478)-(350, 478), 10
Line (290, 461)-(290, 477), 8
'Score boxes
Line (12, 444)-(42, 474), 0, BF
Line (12, 444)-(42, 474), 9, B
Line (12, 444)-(12, 474), 6
Line (12, 444)-(42, 444), 6
Line (597, 444)-(627, 474), 0, BF
Line (597, 444)-(627, 474), 9, B
Line (597, 444)-(597, 474), 6
Line (597, 444)-(627, 444), 6
Get (438, 20)-(452, 38), Box()
Put (19, 450), Box()
Put (604, 450), Box()
For x = 0 To 639
    For y = 362 To 404
        If Point(x, y) = 0 Then PSet (x, y), 12
    Next y
Next x
PrintSTRING 298, 464, "NO WIND"
For x = 298 To 342
    For y = 465 To 473
        If y > 469 Then Colr = 9 Else Colr = 15
        If Point(x, y) <> 7 Then PSet (x, y), Colr
    Next y
Next x
Get (298, 465)-(342, 473), Box()
Def Seg = VarSeg(Box(1))
BSave "kongwind.bsv", VarPtr(Box(1)), 240
Def Seg
Dim SliderBOX(1 To 440)
Def Seg = VarSeg(SliderBOX(1))
BLoad "kongsldr.bsv", VarPtr(SliderBOX(1))
Def Seg
Get (141, 443)-(151, 461), SliderBOX(281)
Get (489, 443)-(499, 461), SliderBOX(361)
Def Seg = VarSeg(SliderBOX(1))
BSave "kongsldr.bsv", VarPtr(SliderBOX(1)), 880
Def Seg
Return

DrawSCREEN:
Get (16, 47)-(56, 87), Box(25000)
Get (0, 300)-(639, 340), Box()
Line (0, 0)-(639, 350), 0, BF
Line (0, 0)-(639, 43), 7, BF
Line (0, 44)-(639, 44), 10
Put (0, 1), Box(), PSet
Put (299, 70), Box(25000), PSet
PrintSTRING 2, 46, "Freeware - Copyright 2005 by Bob Seguin"
PrintSTRING 497, 46, "email: BOBSEG@sympatico.ca"
For x = 0 To 639
    For y = 46 To 58
        If Point(x, y) <> 0 Then PSet (x, y), 2
    Next y
Next x

PSet (0, 154), 12
Draw "r7 U24 R35 NU20 R30 F20 D20 R30 F20 D30 R5 U50 R20 NU20 R20 D60"
Draw "R5 U30 R5 U4 R20 NU20 R20 D4 R5 D20 R4 U30 R3 U40 R3"
Draw "U3ru3ru3ru3ru3ru3r2Nu20R2D3rd3rd3rd3rd3rd3r3d40r3d20R4"
Draw "U30 R30d20r3U60r3u4r25nu12r25d4r3d80r5U30r15Nu12r15d30r5u50r30d40"
Draw "r5U30 r6U2r34nu12r34d2r6d30r4u20r20d20r5U30e12r20U18e23r"
Draw "r12nu12r22d108L639U81bfp12,12"
Line (0, 235)-(639, 400), 12, BF
Circle (605, 198), 200, 12, 2.8, 3.2
Circle (235, 198), 200, 12, 0, .34
Line (416, 123)-(424, 136), 12, BF
Line (419, 100)-(421, 125), 12, BF
Line (420, 80)-(420, 100), 12
Paint Step(0, 40), 12

PSet (0, 390), 10
Draw "R10 U10 R100 D5 R10 U10 R80 D30 R20 U20 R60 U8rd8r62 D10"
Draw "R80 U20 LU10R20 U6lu2r16d2ld6r60d10ld10r118d26L639"
Draw "U14 BF4 P10,10"
For y = 401 To 440
    For x = 0 To 639
        If Point(x, y) = 0 Then PSet (x, y), 10
    Next x
Next y
Paint (60, 396), 10
Paint (460, 396), 10
Get (80, 340)-(539, 400), Box()
Put (80, 345), Box(), PSet
Randomize 123
For Reps = 1 To 48
    x = Fix(Rnd * 640)
    y = Fix(Rnd * 60) + 45
    If Point(x, y) = 0 Then PSet (x, y), 7
Next Reps
For x = 0 To 639
    For y = 362 To 404
        If Point(x, y) <> 10 Then PSet (x, y), 0
    Next y
Next x
Get (0, 362)-(639, 404), Box() '7000
For x = 0 To 639
    For y = 362 To 404
        If Point(x, y) = 0 Then PSet (x, y), 15 Else PSet (x, y), 0
    Next y
Next x
For x = 45 To 595
    For y = 430 To 460
        If Point(x, y) = 0 Then PSet (x, y), 10
    Next y
Next x
Get (0, 362)-(639, 404), Box(7000) 'Get foreground building mask
Put (0, 362), Box(), PSet
Line (80, 410)-(88, 422), 5, BF
Line (80, 410)-(88, 418), 3, BF
Line (180, 410)-(188, 422), 0, BF
Line (480, 390)-(488, 402), 5, BF
Line (480, 390)-(488, 394), 3, BF
Line (460, 390)-(468, 402), 0, BF
Line (440, 412)-(448, 424), 0, BF
Get (0, 362)-(639, 404), Box() '7000 'Get/Save foreground buildings
Def Seg = VarSeg(Box(1))
BSave "kongfbld.bsv", VarPtr(Box(1)), 28000
Def Seg
Line (0, 340)-(639, 404), 12, BF
Put (0, 362), Box(7000), And
Put (0, 362), Box()

'Get/Save main screen
FileCOUNT = 0
Def Seg = VarSeg(Box(1))
For y = 0 To 320 Step 160
    Get (0, y)-(639, y + 159), Box()
    FileCOUNT = FileCOUNT + 1
    FileNAME$ = "kongscr" + LTrim$(Str$(FileCOUNT)) + ".bsv"
    BSave FileNAME$, VarPtr(Box(1)), 52000
Next y
Def Seg
Return

Buildings:
'Government building?
PSet (97, 200), 11
Draw "E16 R33 F16 L65 R32 BU2 P11,11"
For x = 102 To 159 Step 4
    For y = 184 To 200
        If Point(x, y) = 11 Then PSet (x, y), 3
    Next y
Next x
PSet (97, 200), 3
Draw "E16 R33 U3 L33 D3 BE P11,3 BG C3 R33 F16 L67 D3 R69 U3 L30 BD P11,3"
Line (90, 204)-(169, 208), 7, BF
Line (90, 204)-(169, 204), 8
Line (60, 200)-(68, 212), 3, B
Line (61, 201)-(67, 211), 1, BF
Line (61, 201)-(67, 211), 7, B
Line (61, 206)-(67, 206), 7
Get (60, 200)-(68, 212), Box()
Put (60, 200), Box()
For x = 112 To 140 Step 14
    Put (x, 191), Box(), PSet
Next x
PSet (130, 180), 7
Draw "U20 C15 d"
For x = 114 To 146 Step 2
    Line (x, 177)-(x, 180), 6
    PSet (x, 177), 8
    If x < 146 Then PSet (x + 1, 179), 6
Next x
FlagDATA:
Data 1,2,3,2,2,2,3,4,5,4,3,2
Restore FlagDATA
For x = 129 To 119 Step -1
    Read Down
    Line (x, 162 + Down)-(x, 168 + Down), 4
Next x
Line (90, 210)-(169, 479), 7, BF
For y = 210 To 470 Step 2
    Line (95, y)-(164, y), 6
Next y
Randomize 145678
For y = 220 To 420 Step 20
    For x = 99 To 157 Step 11
        Line (x - 1, y)-(x + 7, y + 12), 7, BF
        If Fix(Rnd * 12) = 0 Then
            Colr1 = 3: Colr2 = 5
        Else
            Colr1 = 1: Colr2 = 2
        End If
        Line (x + 1, y + 1)-(x + 5, y + 12), Colr1, BF
        Line (x + 1, y + 3)-(x + 5, y + 12), Colr2, BF
        Line (x, y + 13)-(x + 6, y + 13), 8
        Line (x, y + 7)-(x + 5, y + 7), 7
    Next x
Next y
Get (80, 150)-(180, 479), Box()
Put (80, 146), Box(), PSet
SaveBUILDING 90, 24, 1

'Modern building
Line (300, 200)-(379, 204), 6, BF
Line (300, 205)-(379, 479), 7, BF
PSet (321, 195), 2
Draw "E4 R30 F4 L38 R10 BU P2,2"
PSet (321, 195), 8
Draw "E4 ND4 R5 ND4 R5 ND4 R5 ND4 R5 ND4 R5 ND4 R5 ND4 F4 L38"
Line (321, 195)-(359, 199), 8, BF
Circle (308, 200), 6, 6, 0, 3.14
Paint Step(0, -1), 6
PSet Step(0, -4), 8
Circle (372, 200), 6, 6, 0, 3.14
Paint Step(0, -1), 6
PSet Step(0, -4), 8
For x = 300 To 379
    For y = 194 To 197
        If Point(x, y) = 6 Then PSet (x, y), 2
    Next y
Next x
Line (300, 200)-(379, 204), 7, BF
Line (300, 200)-(379, 200), 8
Line (300, 205)-(379, 206), 10, B
Line (317, 184)-(317, 199), 7
PSet Step(0, -15), 8
Line (363, 184)-(363, 199), 7
PSet Step(0, -15), 8
For y = 210 To 440 Step 16
    Line (300, y)-(379, y + 8), 2, BF
    Line (300, y)-(379, y + 3), 1, BF
    Line (300, y + 8)-(379, y + 8), 8
    For x = 305 To 379 Step 14
        Line (x, y)-(x, y + 8), 7
    Next x
Next y
SaveBUILDING 300, 0, 2 '*************************************************

'Hotel --------------------------------------------------------------------
Line (400, 200)-(479, 479), 3, BF
Line (420, 195)-(459, 199), 6, BF
Line (420, 195)-(459, 195), 7
Line (460, 174)-(460, 199), 7
Line (454, 176)-(464, 176), 7
Line (457, 177)-(467, 177), 7
PSet (454, 176), 9
Line (410, 192)-(414, 199), 6, BF
Line (410, 192)-(414, 192), 7
Line (465, 192)-(469, 199), 6, BF
Line (465, 192)-(469, 192), 7
For x = 421 To 454 Step 4
    For y = 186 To 193 Step 3
        Line (x, y)-(x + 4, y + 3), 6, B
    Next y
Next x
PrintSTRING 425, 162, "HOTEL"
For x = 425 To 500
    For y = 162 To 174
        If Point(x, y) <> 0 Then PSet (x, y + 20), 4
        PSet (x, y), 0
    Next y
Next x
Get (100, 50)-(111, 76), Box()
For x = 404 To 468 Step 15
    Put (x, 215), Box(), PSet
Next x
Get (100, 54)-(111, 76), Box()
For x = 404 To 464 Step 15
    Put (x, 248), Box(), PSet
    If x = 419 Then
        For xx = x To x + 12
            For yy = 248 To 267
                If Point(xx, yy) = 2 Then PSet (xx, yy), 5
            Next yy
        Next xx
    End If
Next x
For x = 404 To 464 Step 15
    For y = 290 To 479 Step 32
        Put (x, y), Box(), PSet
        If Fix(Rnd * 12) = 2 Then
            Line (x + 2, y + 8)-(x + 9, y + 15), 1, BF
            Line (x + 2, y + 16)-(x + 9, y + 16), 7
            Line (x + 2, y + 17)-(x + 9, y + 17), 10
        End If
        If Fix(Rnd * 15) = 0 Then
            For xx = x To x + 12
                For yy = y To y + 19
                    If Point(xx, yy) = 2 Then PSet (xx, yy), 5
                Next yy
            Next xx
        End If
    Next y
Next x
Get (88, 84)-(93, 91), Box()
For x = 401 To 480 Step 5
    Put (x, 200), Box(), PSet
    Put (x, 276), Box(), PSet
Next x
Line (480, 200)-(484, 310), 0, BF
Line (395, 200)-(399, 310), 0, BF
For y = 202 To 479 Step 2
    For x = 400 To 480
        If Point(x, y) = 3 Then PSet (x, y), 1
    Next x
Next y
Get (478, 200)-(478, 210), Box()
Put (479, 200), Box(), PSet
Put (400, 200), Box(), PSet
Put (479, 276), Box(), PSet
Put (400, 276), Box(), PSet
SaveBUILDING 400, 0, 3 '*************************************************

'Buff Apartment Block -------------------------------------------------------
Get (608, 44)-(619, 67), Box()
Get (621, 44)-(632, 67), Box(500)
Line (500, 200)-(579, 479), 11, BF
For x = 504 To 574 Step 15
    For y = 216 To 460 Step 32
        If Fix(Rnd * 6) = 0 Then
            Put (x, y), Box(500), PSet
        Else
            Put (x, y), Box(), PSet
        End If
        Line (500, y + 27)-(579, y + 27), 9
        Line (500, y + 28)-(579, y + 28), 8
    Next y
Next x
Line (500, 200)-(579, 204), 7, BF
Line (500, 200)-(579, 200), 9
Line (500, 205)-(579, 205), 10
Line (520, 189)-(559, 199), 11, BF
Line (520, 189)-(559, 192), 7, BF
Line (520, 189)-(559, 189), 9
Line (520, 193)-(559, 193), 6
PSet (539, 188), 8
Draw "U16 C14 D"
SaveBUILDING 500, 0, 4 '*************************************************

'Factory --------------------------------------------------------------------
Line (0, 150)-(639, 479), 0, BF
Line (100, 200)-(179, 479), 3, BF
Circle (120, 220), 10, 15, , , .85
Circle (120, 219), 12, 15, , , .83
Line (105, 222)-(135, 240), 3, BF
Get (120, 206)-(150, 230), Box()
Put (119, 206), Box(), PSet
PSet (110, 217), 3
PSet (129, 217), 3
Line (129, 220)-(129, 228), 15
Line (110, 220)-(110, 228), 15
Draw "R19"
Line (110, 236)-(129, 252), 15, B
PSet (108, 220), 15
Draw "D34 R23 U34"
Paint (119, 220), 2, 15
Paint (119, 244), 2, 15
For x = 100 To 140
    For y = 200 To 260
        If Point(x, y) = 15 Then PSet (x, y), 1
    Next y
Next x
For x = 120 To 140
    For y = 216 To 260
        If Point(x, y) = 1 Then PSet (x, y), 11
    Next y
Next x
Line (111, 228)-(120, 228), 11
Line (111, 236)-(129, 236), 1
Line (111, 252)-(129, 252), 11
Line (109, 254)-(129, 254), 11
Line (124, 213)-(124, 227), 1
Line (115, 213)-(115, 227), 1
Line (111, 219)-(129, 219), 1
Line (115, 236)-(115, 251), 1
Line (124, 236)-(124, 251), 1
Line (111, 244)-(129, 244), 1

Get (120, 205)-(133, 256), Box()
Put (118, 205), Box(), PSet
Get (106, 229)-(131, 253), Box()
For y = 254 To 450 Step 25
    Put (106, y), Box(), PSet
Next y
Get (106, 202)-(132, 470), Box()
Line (106, 202)-(132, 470), 3, BF
For x = 102 To 158 Step 25
    Put (x, 202), Box(), PSet
Next x
For y = 255 To 455 Step 50
    Line (100, y)-(179, y + 3), 3, BF
    Line (100, y)-(179, y), 11
    Line (100, y + 3)-(179, y + 3), 1
Next y
Line (100, 230)-(104, 234), 3, BF
Line (100, 230)-(104, 230), 11
Line (100, 234)-(104, 234), 1
Get (100, 230)-(104, 234), Box()
For x = 100 To 175 Step 25
    For y = 230 To 430 Step 50
        Put (x, y), Box(), PSet
    Next y
Next x
Line (120, 190)-(159, 199), 3, BF
Line (120, 190)-(159, 193), 6, BF
Line (120, 190)-(159, 190), 7
Line (120, 194)-(159, 194), 10
Line (100, 200)-(179, 204), 6, BF
Line (100, 200)-(179, 200), 7
Line (100, 205)-(179, 205), 10

For y = 180 To 479 Step 2
    For x = 100 To 179
        If Point(x, y) = 3 Then PSet (x, y), 6
    Next x
Next y

For Reps = 1 To 30
    x = Fix(Rnd * 80) + 100
    y = Fix(Rnd * 280) + 200
    Colr = Fix(Rnd * 3)
    Select Case Colr
        Case 0: Colr = 6
        Case 1: Colr = 7
        Case 2: Colr = 8
    End Select
    For xx = x - 6 To x + 6
        For yy = y - 6 To y + 6
            If Point(xx, yy) = 2 Then PSet (xx, yy), Colr
        Next yy
    Next xx
Next Reps
PrintSTRING 212, 184, "B-Bomb Mfg"
For x = 204 To 280
    For y = 184 To 196
        If Point(x, y) <> 0 Then PSet (x - 100, y), 4
        PSet (x, y), 0
    Next y
Next x
For x = 208 To 270 Step 5
    For y = 185 To 194 Step 3
        Line (x, y)-(x + 5, y + 4), 2, B
    Next y
Next x
For x = 208 To 275
    For y = 178 To 200
        If Point(x, y) <> 0 Then
            If Point(x - 101, y + 1) <> 4 Then PSet (x - 101, y + 1), 6
            PSet (x, y), 0
        End If
    Next y
Next x
SaveBUILDING 100, 0, 5 '*************************************************

'Apescape building -------------------------------------------------------------
Line (200, 200)-(279, 479), 8, BF
Line (210, 180)-(269, 299), 8, BF
Line (220, 180)-(259, 180), 9
Line (207, 200)-(272, 200), 9
Circle (209, 209), 10, 0, 3.14159 * .5, 3.14159
Paint (201, 201), 0
Circle (270, 209), 10, 0, 0, 3.14159 * .5
Paint (278, 201), 0
Circle (219, 190), 10, 0, 3.14159 * .5, 3.14159
Paint (211, 181), 0
Circle (260, 190), 10, 0, 0, 3.14159 * .5
Paint (268, 181), 0
For x = 203 To 277 Step 4
    For y = 180 To 479
        If Point(x, y) = 8 Then PSet (x, y), 7
        If Point(x + 1, y) = 8 Then PSet (x + 1, y), 7
    Next y
Next x
For x = 206 To 270 Step 10
    For y = 220 To 460 Step 36
        Line (x, y)-(x + 7, y + 26), 8, BF
        Line (x + 1, y + 1)-(x + 6, y + 22), 2, BF
        Line (x + 1, y + 1)-(x + 6, y + 6), 1, BF
    Next y
Next x
Line (239, 158)-(239, 179), 8
PSet (236, 162), 4
PSet (242, 162), 4
For x = 217 To 260 Step 8
    Line (x, 190)-(x + 4, 198), 2, BF
    Line (x, 190)-(x + 4, 193), 1, BF
Next x
PSet (200, 205), 6
PSet (205, 200), 6
PSet (210, 186), 6
PSet (215, 181), 6
PSet (219, 180), 8
PSet (218, 180), 7

PSet (279, 205), 6
PSet (274, 200), 6
PSet (269, 186), 6
PSet (264, 181), 6

PSet (260, 180), 8
PSet (261, 180), 7

Get (200, 180)-(279, 214), Box()
Put (200, 176), Box(), PSet
Get (200, 180)-(279, 214), Box()
Put (200, 175), Box(), PSet
Line (206, 200)-(273, 200), 9
Line (206, 193)-(206, 200), 6
Line (273, 193)-(273, 200), 6
Line (214, 175)-(265, 175), 9
Line (212, 203)-(267, 216), 8, BF
Line (212, 217)-(267, 217), 6
Line (212, 203)-(267, 203), 9
PrintSTRING 217, 203, "apescape"
For x = 217 To 267
    For y = 203 To 217
        If Point(x, y) = 15 Then PSet (x, y), 1
    Next y
Next x
SaveBUILDING 200, 26, 6

'Tenement building ---------------------------------------------------------
Line (200, 150)-(279, 479), 0, BF
Randomize 4
Circle (220, 198), 10, 2, 0, 3.14159
Circle (259, 198), 10, 2, 0, 3.14159
Circle (220, 198), 7, 2, 0, 3.14159
Circle (259, 198), 7, 2, 0, 3.14159
Line (207, 198)-(210, 198), 2: Draw "bl3D3r6u3"
Line (230, 198)-(233, 198), 2: Draw "D3l6u3"
Line (246, 198)-(249, 198), 2: Draw "bl3D3r6u3"
Line (269, 198)-(272, 198), 2: Draw "D3l6u3"
Circle (182, 166), 35, 2, 5.3, 6
Circle (297, 166), 35, 2, 3.42, 4.16
Line (215, 176)-(264, 176), 2
PSet (200, 195), 2
Draw "D4 R7 BR26 R12 BR27 R7 U4 l10 Bl20 l18 Bl20 l11"
Paint (240, 190), 1, 2
Paint (240, 197), 1, 2
Paint (202, 197), 1, 2
Paint (277, 197), 1, 2
For y = 168 To 195 Step 2
    For x = 200 To 279
        If Point(x, y) = 1 Then PSet (x, y), 2
    Next x
Next y
Paint (220, 190), 1, 2
Paint (259, 190), 1, 2
Line (215, 176)-(264, 176), 7
Circle (220, 198), 10, 7, .5, 2.64159
Circle (259, 198), 10, 7, .5, 2.64159
PSet (200, 195), 7
Draw "bD4 bR7 BR26 bR12 bBR27 bR7 bU4 l9 Bl22 l17 Bl22 l9"
For x = 215 To 263 Step 2
    PSet (x, 174), 7
    PSet (x, 175), 6
Next x
Line (213, 198)-(227, 198), 2
Paint (220, 197), 1, 2
Circle (220, 195), 1, 8
Line (215, 198)-(225, 217), 2, B
Line (216, 199)-(224, 216), 1, BF
Line (216, 199)-(224, 216), 6, B
Line (220, 199)-(220, 211), 6: Draw "nL3nR3"
Paint (220, 215), 10, 6
Circle (220, 199), 7, 10, .14, 3, 1.1
Line (217, 200)-(219, 201), 10, B
Line (221, 200)-(223, 201), 10, B
Line (214, 218)-(226, 218), 7
Get (210, 190)-(230, 220), Box()
Put (249, 190), Box(), PSet
PSet (200, 200), 10: Draw "R6 D2 R6 BR16 R6 U2 R11 D2 R6 BR16 R6 U2 R6"
For x = 200 To 279
    For y = 200 To 479 Step 2
        If Point(x, y) = 0 Then PSet (x, y), 3
        If Point(x, y + 1) = 0 Then PSet (x, y + 1), 1
    Next y
Next x
Line (236, 202)-(243, 212), 2, B
Paint (238, 210), 7, 2
Line (237, 203)-(242, 211), 6, B
Line (237, 207)-(242, 207), 6
Paint (238, 206), 3, 6
Paint (238, 208), 5, 6
Line (235, 213)-(244, 213), 7
Line (238, 204)-(241, 204), 10
Line (202, 230)-(220, 234), 10, BF
Line (218, 230)-(220, 254), 10, BF
Line (259, 230)-(279, 234), 10, BF
Line (200, 228)-(279, 229), 2, B
Line (200, 229)-(201, 254), 2, B
Line (278, 229)-(279, 254), 2, B
Line (207, 232)-(212, 242), 6, B
Line (208, 233)-(211, 233), 10
Line (200, 245)-(220, 254), 2, B
Paint (210, 235), 7, 6
Paint (210, 235), 3, 6
Line (207, 237)-(212, 237), 6
Paint (210, 238), 5, 6
Line (208, 233)-(211, 233), 10
Line (200, 244)-(220, 254), 2, B
Line (202, 244)-(220, 244), 7
Line (202, 252)-(218, 253), 10, BF
For x = 202 To 218 Step 2
    Line (x, 245)-(x, 254), 2
Next x
Line (226, 232)-(236, 246), 1, BF
Line (226, 232)-(236, 246), 6, B
Line (226, 239)-(236, 239), 6
Line (225, 247)-(237, 247), 7
For x = 200 To 239
    For y = 200 To 279
        PSet (479 - x, y), Point(x, y)
    Next y
Next x
Get (200, 228)-(279, 258), Box()
For y = 224 To 450 Step 32
    Put (200, y), Box(), PSet
    If Fix(Rnd * 12) = 0 Then
        Paint (230, y + 6), 3, 6
        Paint (230, y + 14), 5, 6
    End If
    If Fix(Rnd * 2) = 0 Then
        Paint (249, y + 6), 3, 6
        Paint (249, y + 14), 5, 6
    End If
    If Fix(Rnd * 5) = 0 Then
        Paint (210, y + 8), 1, 6
        Paint (210, y + 11), 7, 6
    End If
    If Fix(Rnd * 2) = 0 Then
        Paint (269, y + 8), 1, 6
        Paint (269, y + 11), 7, 6
    End If
    Line (227, y + 5)-(235, y + 5), 10
    Line (244, y + 5)-(252, y + 5), 10
    Line (268, y + 5)-(271, y + 5), 10
    Line (208, y + 5)-(211, y + 5), 10
Next y
SaveBUILDING 200, 25, 7

'Balcony Apartment ----------------------------------------------------------
Line (0, 150)-(400, 479), 0, BF
Get (118, 50)-(133, 76), Box()
Put (118, 250), Box()
Line (300, 200)-(379, 479), 4, BF
Get (118, 240)-(133, 260), Box()
Put (118, 246), Box(), PSet
Get (118, 256)-(133, 276), Box(6000)
Put (218, 256), Box(6000)
For x = 218 To 233
    For y = 256 To 276
        If Point(x, y) = 1 Or Point(x, y) = 10 Then PSet (x, y), 3
        If Point(x, y) = 2 Then PSet (x, y), 5
    Next y
Next x
Get (219, 257)-(232, 276), Box(5000)
For x = 304 To 360 Step 18
    If x = 340 Then x = 360
    Put (x, 212), Box(6000), PSet
Next x
Get (118, 50)-(133, 76), Box()
Put (341, 212), Box(), PSet
Get (340, 224)-(359, 235), Box()
Put (340, 230), Box(), PSet
Line (329, 242)-(368, 243), 9, B
Line (329, 232)-(368, 243), 8, B
For x = 330 To 368 Step 2
    Line (x, 232)-(x, 242), 8
Next x
Line (300, 242)-(328, 243), 8, BF
Line (369, 242)-(379, 243), 8, BF
Line (300, 244)-(379, 244), 6
For x = 301 To 379 Step 18
    If x = 355 Then x = 357
    Line (x, 214)-(x + 3, 228), 8, BF
    For y = 216 To 226 Step 2
        Line (x + 1, y)-(x + 2, y), 7
    Next y
Next x
Get (300, 212)-(379, 244), Box()
For y = 212 To 440 Step 38
    Put (300, y), Box(), PSet
Next y
Line (300, 200)-(379, 204), 8, BF
Line (300, 200)-(379, 200), 9
Line (300, 205)-(379, 205), 6
Line (320, 188)-(359, 199), 11, BF
Line (319, 188)-(360, 190), 8, BF
Line (320, 191)-(359, 191), 10
For x = 300 To 379
    For y = 200 To 479
        If Point(x, y) = 4 Then PSet (x, y), 11
    Next y
Next x
For y = 188 To 478 Step 2
    For x = 300 To 379
        If Point(x, y) = 11 Then PSet (x, y), 3
    Next x
Next y
PSet (363, 199), 7
Draw "U24 C15 D"
For x = 305 To 360 Step 18
    If x = 341 Then x = 361
    For y = 213 To 440 Step 38
        If Fix(Rnd * 10) = 0 Then Put (x, y), Box(5000), PSet
        Line (329, 232)-(368, 232), 15
    Next y
Next x
For y = 232 To 470 Step 38
    Line (329, y)-(368, y), 15
Next y
SaveBUILDING 300, 0, 8
Line (0, 150)-(639, 479), 0, BF
Return

SetPALETTE:
Data 0,4,16,0,10,21,0,16,32,32,10,0
Data 63,0,0,63,32,0,18,18,24,30,30,37
Data 42,42,50,55,55,63,0,0,0,43,27,19
Data 8,8,21,0,63,21,63,63,21,63,63,63

Restore SetPALETTE
Out &H3C8, 0
For n = 1 To 48
    Read Intensity
    Out &H3C9, Intensity
Next n
Return

WinBOXES:
Get (140, 0)-(256, 18), Box()
Get (376, 0)-(500, 18), Box(5000)
Get (520, 0)-(580, 18), Box(10000)
Put (198, 200), Box()
Put (320, 200), Box(10000)
PrintSTRING 220, 223, "To play again, press ENTER"
PrintSTRING 219, 236, "Press any other key to EXIT"
For x = 174 To 400
    For y = 192 To 254
        If y > 210 Then Colr = 8 Else Colr = 15
        If y > 222 Then Colr = 9
        If Point(x, y) = 0 Then PSet (x, y), 1 Else PSet (x, y), Colr
    Next y
Next x
For y = 224 To 200 Step -1
    For x = 174 To 400
        If Point(x, y - 2) <> 1 And Point(x, y) = 1 Then PSet (x, y), 10
    Next x
Next y
Line (176, 194)-(398, 252), 6, B
Line (174, 192)-(400, 254), 6, B
Get (174, 192)-(400, 254), Box()
Line (170, 188)-(404, 258), 8, BF
Line (170, 188)-(404, 258), 15, B
Line (170, 258)-(404, 258), 10
Line (404, 188)-(404, 258), 10
Put (174, 192), Box(), PSet
Get (170, 188)-(404, 258), Box()
Def Seg = VarSeg(Box(1))
BSave "kongwink.bsv", VarPtr(Box(1)), 9000
Def Seg
Line (177, 197)-(394, 222), 1, BF
Put (196, 200), Box(5000)
Put (324, 200), Box(10000)
For y = 224 To 200 Step -1
    For x = 190 To 382
        If y > 210 Then Colr = 8 Else Colr = 15
        If Point(x, y - 2) <> 1 Then PSet (x, y - 2), Colr
    Next x
Next y
For y = 224 To 200 Step -1
    For x = 174 To 400
        If Point(x, y - 2) <> 1 And Point(x, y) = 1 Then PSet (x, y), 10
    Next x
Next y
Get (196, 200)-(386, 220), Box()
Put (195, 200), Box(), PSet
Get (170, 188)-(404, 258), Box()
Put (170, 188), Box()
Def Seg = VarSeg(Box(1))
BSave "kongwiny.bsv", VarPtr(Box(1)), 9000
Def Seg
Return

Instructions:
Line (192, 160)-(447, 310), 8, BF
Line (192, 160)-(447, 310), 15, B
Line (192, 310)-(447, 310), 10
Line (447, 160)-(447, 310), 10
Line (202, 164)-(436, 305), 1, BF
Line (202, 164)-(436, 305), 6, B
Line (204, 166)-(434, 303), 6, B
Line (400, 175)-(424, 187), 7, BF
PrintSTRING 216, 176, "INSTRUCTIONS"
PrintSTRING 216, 194, "The object of the game is to be the first"
PrintSTRING 216, 206, "player to achieve a score of 3. You gain"
PrintSTRING 216, 218, "1"
PrintSTRING 225, 218, "point each time you blow up the other"
PrintSTRING 216, 230, "player's gorilla with an exploding banana."
PrintSTRING 216, 248, "Unless playing the computer, begin by"
PrintSTRING 216, 260, "deciding which player will control which"
PrintSTRING 216, 272, "gorilla, then click the"
PrintSTRING 340, 272, "button to begin."
PrintSTRING 216, 284, "The starting gorilla is chosen at random."
For x = 207 To 431
    For y = 167 To 295
        If y < 194 Then Colr = 9 Else Colr = 8
        If y < 181 Then Colr = 15
        If Point(x, y) <> 1 Then PSet (x, y), Colr
    Next y
Next x
HighLIGHT 354, 206, 362, 217, 9
HighLIGHT 216, 218, 222, 229, 9
PSet (404, 184), 6
Draw "U6 R12 U2 F5 G5 U2 L12 BE2 P6,6"
Line (321, 275)-(332, 281), 8, BF
Line (321, 282)-(332, 282), 10
Line (323, 278)-(330, 278), 1: Draw "NH2G2"
SaveINSTR "kongins1.bsv"
Line (205, 193)-(433, 295), 1, BF
PrintSTRING 216, 194, "When a player's gorilla is the thrower,"
PrintSTRING 216, 206, "the LED will be green under his name (and"
PrintSTRING 216, 218, "he'll be holding a banana). Click on the"
PrintSTRING 216, 230, "Angle slider and drag it to adjust the initial"
PrintSTRING 216, 242, "throwing angle (0 degrees is a horizontal"
PrintSTRING 216, 254, "throw in the other gorilla's direction). Set"
PrintSTRING 216, 266, "the Force slider in the same way. To toss"
PrintSTRING 216, 278, "the banana, click the Banana button"
PrintSTRING 410, 278, "."
HighLIGHT 216, 194, 434, 295, 8
HighLIGHT 234, 206, 254, 217, 9
HighLIGHT 216, 230, 244, 241, 9
HighLIGHT 236, 266, 264, 277, 9
HighLIGHT 322, 278, 360, 299, 9
Line (204, 166)-(434, 303), 6, B
Get (99, 80)-(109, 90), Box()
Put (397, 279), Box(), PSet
SaveINSTR "kongins2.bsv"
Line (205, 193)-(433, 295), 1, BF
PrintSTRING 216, 194, "Be sure to check the Wind arrow (bottom"
PrintSTRING 216, 206, "center of the screen). The arrow shows both"
PrintSTRING 216, 218, "the direction and strength of the wind (the"
PrintSTRING 216, 230, "longer the arrow, the stronger the wind). A"
PrintSTRING 216, 242, "strong opposing wind can actually blow the"
PrintSTRING 216, 254, "banana backwards if the Force of the toss"
PrintSTRING 216, 266, "isn't strong enough!"
PrintSTRING 348, 282, "Good Luck!"
HighLIGHT 216, 194, 434, 295, 8
HighLIGHT 320, 194, 348, 205, 9
HighLIGHT 348, 282, 420, 294, 15
Line (400, 175)-(424, 187), 15, BF
Line (400, 182)-(424, 187), 9, BF
PSet (406, 177), 4
Draw "F8rH8rF8rH8rF8 BU8 G8lE8lG8lE8lG8"
For x = 400 To 424
    For y = 175 To 187
        If Point(x, y) <> 15 And Point(x, y) <> 9 Then PSet (x, y), 6
    Next y
Next x
Line (204, 166)-(434, 303), 6, B
SaveINSTR "kongins3.bsv"
Put (192, 160), Box()
Line (180, 194)-(400, 270), 7, BF
Line (180, 194)-(400, 270), 9, B
Line (180, 270)-(400, 270), 6
Line (400, 194)-(400, 270), 6
Line (194, 198)-(384, 266), 1, BF
Line (196, 200)-(382, 264), 6, B
PrintSTRING 238, 208, "Click Your Preference"
PrintSTRING 252, 227, "2 players"
PrintSTRING 252, 243, "1 player (play computer)"
HighLIGHT 238, 208, 380, 255, 9
HighLIGHT 238, 208, 380, 214, 15
Line (215, 227)-(241, 239), 10, B
Line (216, 228)-(240, 238), 8, BF
Line (216, 228)-(240, 238), 15, B
Line (240, 228)-(240, 238), 6
Line (216, 238)-(240, 238), 6
Line (215, 243)-(241, 255), 10, B
Line (216, 244)-(240, 254), 8, BF
Line (216, 244)-(240, 254), 15, B
Line (240, 244)-(240, 254), 6
Line (216, 254)-(240, 254), 6
Get (180, 194)-(400, 270), Box()
Put (180, 194), Box()
Def Seg = VarSeg(Box(1))
BSave "kong1pl2.bsv", VarPtr(Box(1)), 8800
Def Seg
Line (180, 194)-(400, 270), 7, BF
Line (180, 194)-(400, 270), 9, B
Line (180, 270)-(400, 270), 6
Line (400, 194)-(400, 270), 6
Line (194, 198)-(384, 266), 1, BF
Line (196, 200)-(382, 264), 6, B
PrintSTRING 256, 207, "Your gorilla is"
PrintSTRING 236, 243, "Click to begin"
HighLIGHT 233, 207, 380, 257, 9
For x = 138 To 256
    For y = 0 To 20
        If y > 9 Then Colr = 8 Else Colr = 15
        If Point(x, y) <> 0 Then
            PSet (x + 92, y + 223), 10
            PSet (x + 92, y + 221), Colr
        End If
    Next y
Next x
Line (311, 244)-(337, 253), 10, B
Line (312, 245)-(336, 255), 8, BF
Line (312, 245)-(336, 255), 15, B
Line (336, 245)-(336, 255), 6
Line (312, 255)-(336, 255), 6
PSet (318, 249), 1
Draw "R9 U2 F3 G3 U2 L9 U2 BF P1,1"
Get (180, 194)-(400, 270), Box()
Put (180, 194), Box()
Def Seg = VarSeg(Box(1))
BSave "kong1plr.bsv", VarPtr(Box(1)), 8800
Def Seg
Line (180, 194)-(400, 270), 7, BF
Line (180, 194)-(400, 270), 9, B
Line (180, 270)-(400, 270), 6
Line (400, 194)-(400, 270), 6
Line (194, 198)-(384, 266), 1, BF
Line (196, 200)-(382, 264), 6, B
PrintSTRING 234, 214, "Decide who will control"
PrintSTRING 234, 226, "which gorilla and then..."
PrintSTRING 236, 243, "Click to begin"
HighLIGHT 225, 212, 380, 257, 9
Line (311, 244)-(337, 253), 10, B
Line (312, 245)-(336, 255), 8, BF
Line (312, 245)-(336, 255), 15, B
Line (336, 245)-(336, 255), 6
Line (312, 255)-(336, 255), 6
PSet (318, 249), 1
Draw "R9 U2 F3 G3 U2 L9 U2 BF P1,1"
Get (180, 194)-(400, 270), Box()
Put (180, 194), Box()
Def Seg = VarSeg(Box(1))
BSave "kongopen.bsv", VarPtr(Box(1)), 8800
Def Seg
Return

Sub HighLIGHT (x1, y1, x2, y2, Colr)
    For x = x1 To x2
        For y = y1 To y2
            If Point(x, y) <> 1 Then PSet (x, y), Colr
        Next y
    Next x
End Sub

Sub PrintSTRING (x, y, Prnt$)

    Def Seg = VarSeg(FontBOX(0))
    BLoad "kong.fbs", VarPtr(FontBOX(0))
    Def Seg

    For i = 1 To Len(Prnt$)
        Char$ = Mid$(Prnt$, i, 1)
        If Char$ = " " Then
            x = x + FontBOX(1)
        Else
            Index = (Asc(Char$) - 33) * FontBOX(0) + 2

            Put (x, y), FontBOX(Index)
            x = x + FontBOX(Index)
        End If
    Next i

End Sub

Sub SaveBUILDING (x, UpSET, Building)

    Box(1) = UpSET
    Line (x, 155)-(x, 479), 0
    Line (x + 79, 155)-(x + 79, 479), 0
    Get (x, 155)-(x + 79, 199), Box(2)
    For xx = x To x + 79
        For yy = 155 To 199
            If Point(xx, yy) = 0 Then PSet (xx, yy), 15 Else PSet (xx, yy), 0
        Next yy
    Next xx
    Get (x, 155)-(x + 79, 199), Box(1000)
    Get (x, 200)-(x + 79, 479), Box(2000)
    FileNAME$ = "kongbld" + LTrim$(Str$(Building)) + ".bsv"
    Def Seg = VarSeg(Box(1))
    BSave FileNAME$, VarPtr(Box(1)), 16000
    Def Seg

End Sub

Sub SaveINSTR (FileNAME$)
    Get (192, 160)-(447, 310), Box()
    Def Seg = VarSeg(Box(1))
    BSave FileNAME$, VarPtr(Box(1)), 20000
    Def Seg
End Sub

