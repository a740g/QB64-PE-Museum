WORK_DIR$ = _STARTDIR$
IF MID$(_OS$, 0, 9) = "[WINDOWS]" THEN
    DIR_SEP$ = "\"
ELSE
    DIR_SEP$ = "/"
END IF
DIM C%(2, 1)
DIM E1%(2, 1)
DIM E2%(2, 1)
DIM E4%(2, 2)
DIM E8%(3, 3)
DIM F(12) AS STRING
ON ERROR GOTO 83
g% = FREEFILE
OPEN "SCH.KYS" FOR INPUT AS #g%
FOR X = 1 TO 12
    Y = X
    IF X = 11 THEN Y = 30
    IF X = 12 THEN Y = 31
    INPUT #g%, F(X)
    KEY Y, F(X)
NEXT X
CLOSE #g%
'*******************************TITLE SCREEN
83 CLS: SCREEN 0: COLOR 3, 0, 1
_FULLSCREEN 'QB64
IF _FULLSCREEN = 0 THEN _FULLSCREEN _OFF 'QB64
LOCATE 10, 1:
PRINT "                             SCHEMATIC DESIGN PROGRAM "
PRINT "                                   Version 1.0 "
PRINT "                                   GPL Edition"
PRINT "                     (C) Copyright Leif J. Burrow 1994, 2019"
PRINT "                           Licensed under GPL 3.0 or later"
LOCATE 22, 1: PRINT "                                               Press <B> to begin."
PRINT "                              Press <F> to set function key macros."
'Accept Input
84 I$ = INKEY$: IF I$ = "" THEN 84
IF I$ = "B" OR I$ = "b" THEN 85
IF I$ = "F" OR I$ = "f" THEN 99
GOTO 84

'********************************SETUP
85 S = 8
SCREEN 2
_FULLSCREEN 'QB64
IF _FULLSCREEN = 0 THEN _FULLSCREEN _OFF 'QB64
CLS
VIEW PRINT 1 TO 3
LINE (312, 103)-(314, 103)
LINE (316, 103)-(318, 103)
LINE (315, 100)-(315, 102)
LINE (315, 104)-(315, 106)
GET (312, 100)-(318, 106), C%()
CLS
LINE (312, 103)-(314, 103)
LINE (312, 104)-(314, 104)
GET (312, 103)-(314, 104), E1%()
CLS
LINE (312, 103)-(316, 103)
LINE (312, 103)-(312, 105)
LINE (316, 103)-(316, 105)
LINE (312, 105)-(316, 105)
GET (312, 103)-(316, 105), E2%()
CLS
LINE (312, 103)-(312, 107)
LINE (312, 103)-(320, 103)
LINE (320, 103)-(320, 107)
LINE (320, 107)-(312, 107)
GET (312, 103)-(320, 107), E4%()
CLS
LINE (312, 103)-(328, 103)
LINE (312, 103)-(312, 111)
LINE (328, 103)-(328, 111)
LINE (328, 111)-(312, 111)
GET (312, 103)-(328, 111), E8%()
CLS
SX = 320
SY = 100
P$ = "Vert"
F$ = "SCHEMAT"
GOSUB 10

'*******************************PLACE CURSOR
1 PUT (SX - 3, SY - 3), C%(), XOR

'**********************************COMMAND
89 I$ = INKEY$: LOCATE 2, 69: PRINT TIME$: IF I$ = "" THEN 89
PUT (SX - 3, SY - 3), C%(), XOR
IF I$ = CHR$(0) + CHR$(77) THEN GOSUB 4
IF I$ = CHR$(0) + CHR$(75) THEN GOSUB 3
IF I$ = CHR$(0) + CHR$(72) THEN GOSUB 2
IF I$ = CHR$(0) + CHR$(80) THEN GOSUB 5
IF I$ = "S" OR I$ = "s" THEN 8
IF I$ = "H" OR I$ = "h" THEN 15
IF I$ = "L" OR I$ = "l" THEN 14
IF I$ = "V" OR I$ = "v" THEN 16
IF I$ = "E" OR I$ = "e" THEN 9
IF I$ = "F" OR I$ = "f" THEN 74
IF I$ = "T" OR I$ = "t" THEN 17
IF I$ = "U" OR I$ = "u" THEN 34
IF I$ = "D" OR I$ = "d" THEN 36
IF I$ = "P" OR I$ = "p" THEN 44
IF I$ = "C" OR I$ = "c" THEN 45
IF I$ = "A" OR I$ = "a" THEN 46
IF I$ = "W" OR I$ = "w" THEN 53
IF I$ = "I" OR I$ = "i" THEN 119
IF I$ = "M" OR I$ = "m" THEN 62
IF I$ = "O" OR I$ = "o" THEN 130
IF I$ = "B" OR I$ = "b" THEN 142
GOTO 1

'******************************** FUNCTIONS ************************************
' CLEAR SCREEN
10 CLS
11 PRINT "T-Transistor V-IC A-Passive D-Diode P-Photonic C-Connection M-Misc I-Misc2"
PRINT "B-Tubes O-Logic L-Line F-File W-Write S-Step H-Hor V-Vert|Mode="; P$: RETURN
RETURN

'*********************************FILE

'Print Menu
74 PRINT: PRINT
PRINT "Working Directory: " + WORK_DIR$
PRINT "N-New O-Open S-Save A-Save as P-Print M-Main H-Shell E-End"
75 I$ = INKEY$: IF I$ = "" THEN 75
IF I$ = "N" OR I$ = "n" THEN 78
IF I$ = "O" OR I$ = "o" THEN 13
IF I$ = "S" OR I$ = "s" THEN 12
IF I$ = "A" OR I$ = "a" THEN 76
IF I$ = "P" OR I$ = "p" THEN 60
IF I$ = "M" OR I$ = "m" THEN 77
IF I$ = "H" OR I$ = "h" THEN 111
IF I$ = "E" OR I$ = "e" THEN END
GOTO 75

' SHELL
111 PRINT "Diagram will be lost if you have not saved it!"
PRINT "<C>ontinue or <M>ain Menu"
149 I$ = INKEY$: IF I$ = "" THEN 149
IF I$ = "C" OR I$ = "c" THEN
    F$ = "SCHEMAT"
    CLS
    SHELL
    GOSUB 10
    GOTO 1
ELSEIF I$ = "m" OR I$ = "m" THEN
    GOSUB 11
    GOTO 1
ELSE GOTO 149
END IF

' New
78 PRINT "Diagram will be lost if you have not saved it!"
PRINT "<C>ontinue or <M>ain Menu"
150 I$ = INKEY$: IF I$ = "" THEN 150
IF I$ = "C" OR I$ = "c" THEN
    F$ = "SCHEMAT"
    GOSUB 10
    GOTO 1
ELSE GOTO 150
END IF

'Load
13 PRINT: PRINT: PRINT
PRINT "Working Dir: " + WORK_DIR$ + ""
INPUT "File Name or <M> for Main Menu "; N$
IF N$ = "M" OR N$ = "m" THEN
    GOSUB 11
    GOTO 1
END IF
F$ = N$
ON ERROR GOTO 82
' BLOAD F$ + ".SCH" ' QuickBasic
IF _FILEEXISTS(WORK_DIR$ + DIR_SEP$ + F$ + ".BMP") = 0 THEN 82
img& = _LOADIMAGE(WORK_DIR$ + DIR_SEP$ + F$ + ".BMP")
wide% = _WIDTH(img&)
deep% = _HEIGHT(img&)
_SOURCE img&
_DEST 0
FOR Y = 0 TO deep% - 1
    FOR X = 0 TO wide% - 1
        PSET (X, Y), POINT(X, Y)
    NEXT
NEXT
_SOURCE 0
_DEST 0
PSET (0, 0), 1
GOSUB 11
GOTO 1
82 PRINT "File Not Found"
' FOR A = 1 TO 450: NEXT A ' QuickBasic
_DELAY 7
GOTO 13

' Save
12 ON ERROR GOTO 151
' PRINT F$; ".SCH": PRINT "DATE: "; DATE$; "       TIME:"; TIME$ ' QuickBasic
PRINT F$; ".BMP": PRINT "DATE: "; DATE$; "       TIME:"; TIME$ ' QB64
' DEF SEG = &HB800 'QuickBasic
' BSAVE F$ + ".SCH", 0, 32768! 'QuickBasic
SaveImage 0, WORK_DIR$ + DIR_SEP$ + F$ + ".BMP"

GOSUB 11
GOTO 1

'Save As
76 PRINT: PRINT: PRINT
PRINT "Working Dir: " + WORK_DIR$ + ""
INPUT "File Name or <M> for Main Menu "; N$
IF N$ = "M" OR N$ = "m" THEN
    GOSUB 11
    GOTO 1
END IF
F$ = N$
GOTO 12

' Print Diagram
60 ON ERROR GOTO 151
PRINT: PRINT "<M> for main menu."
INPUT "Condenced <L> or Full page <K>"; I$
IF I$ = "M" OR I$ = "m" THEN
    GOSUB 11
    GOTO 1
END IF
IF I$ = "l" THEN I$ = "L" ELSE IF I$ = "k" THEN I$ = "K"
PRINT "                               "; F$; ".SCH"
PRINT "                DATE PRINTED: "; DATE$; "   TIME: "; TIME$
DEF SEG = &HB800
OPEN "LPT1:" FOR OUTPUT AS #2
' WIDTH "LPT1:", 255 - NOT SUPPORTED QB64
PRINT #2, CHR$(27); "1";
FOR X = 16112 TO 16191
    B = X
    PRINT #2, CHR$(13);
    PRINT #2, CHR$(27); I$; CHR$(144); CHR$(1);
    54 PRINT #2, CHR$(PEEK(B)); CHR$(0);
    IF B >= 0 AND B < 80 THEN 55
    IF B < 8000 THEN B = B + 8112 ELSE B = B - 8192
    GOTO 54
55 NEXT X
CLOSE #2
FOR X = 1 TO 34
    LPRINT
NEXT X
GOSUB 11
GOTO 1
'error
151 PRINT "ERROR!"
FOR X = 1 TO 450: NEXT X
CLOSE #2
GOSUB 11
GOTO 1

'Main Menu
77 GOSUB 11
GOTO 1

'********************************MOVE CURSOR

' Move up
2 SY = SY - S: IF SY <= 24 THEN SY = 24
RETURN

'Move left
3 SX = SX - S: IF SX < 4 THEN SX = 4
RETURN

'Move right
4 SX = SX + S: IF SX >= 626 THEN SX = 626
RETURN

'Move down
5 SY = SY + S: IF SY > 196 THEN SY = 196
RETURN

'*****************************DRAW LINES
'Replace Cursor
14 PRINT: PRINT: PRINT "                              Line"
PUT (SX - 3, SY - 3), C%(), XOR

'Start Line
PSET (SX, SY)
LX = SX: LY = SY

'Accept Input
6 I$ = INKEY$: IF I$ = "" THEN 6
IF I$ = "L" OR I$ = "l" THEN 7
IF I$ = CHR$(0) + CHR$(77) THEN 'move right
    GOSUB 94
    GOSUB 4
    GOSUB 94
    GOTO 6
END IF
IF I$ = CHR$(0) + CHR$(75) THEN 'move left
    GOSUB 94
    GOSUB 3
    GOSUB 94
    GOTO 6
END IF
IF I$ = CHR$(0) + CHR$(72) THEN 'move up
    GOSUB 94
    GOSUB 2
    GOSUB 94
    GOTO 6
END IF
IF I$ = CHR$(0) + CHR$(80) THEN 'move down
    GOSUB 94
    GOSUB 5
    GOSUB 94
    GOTO 6
END IF

GOTO 6

'Cursor
94 PUT (SX - 3, SY - 3), C%(), XOR
RETURN

'Draw Line
7 PUT (SX - 3, SY - 3), C%(), XOR
LINE (LX, LY)-(SX, SY)
GOSUB 11
GOTO 1

'****************************CHANGE STEP
8 IF S < 8 THEN S = S * 2 ELSE S = 1
GOTO 1

'****************************ERASE BLOCK
'Print Menu
9 PRINT: PRINT: PRINT
PRINT "E-Erase M-Main Menu"

'Select Cursor
IF S = 1 THEN 95
IF S = 2 THEN 96
IF S = 4 THEN 97
IF S = 8 THEN 98

'Place Cursor
95 PUT (SX, SY), E1%(), XOR
GOTO 100
96 PUT (SX, SY), E2%(), XOR
GOTO 100
97 PUT (SX, SY), E4%(), XOR
GOTO 100
98 PUT (SX, SY), E8%(), XOR

'Accept Input
100 I$ = INKEY$: IF I$ = "" THEN 100
IF I$ = CHR$(0) + CHR$(77) THEN 101
IF I$ = CHR$(0) + CHR$(75) THEN 102
IF I$ = CHR$(0) + CHR$(72) THEN 103
IF I$ = CHR$(0) + CHR$(80) THEN 104
IF I$ = "M" OR I$ = "m" THEN 107
IF I$ = "E" OR I$ = "e" THEN 106
GOTO 100

'Move Right
101 GOSUB 105
GOSUB 4
GOSUB 105
GOTO 100

'Move Left
102 GOSUB 105
GOSUB 3
GOSUB 105
GOTO 100

'Move Up
103 GOSUB 105
GOSUB 2
GOSUB 105
GOTO 100

'Move Down
104 GOSUB 105
GOSUB 5
GOSUB 105
GOTO 100

'Cursor
105 IF S = 1 THEN PUT (SX, SY), E1%(), XOR
IF S = 2 THEN PUT (SX, SY), E2%(), XOR
IF S = 4 THEN PUT (SX, SY), E4%(), XOR
IF S = 8 THEN PUT (SX, SY), E8%(), XOR
RETURN

'Erase
106 LINE STEP(0, 0)-STEP(S * 2, S), 0, BF
LINE (0, 0)-(0, 0), 1
GOSUB 105
GOTO 100

'Main Menu
107 GOSUB 105
GOSUB 11
GOTO 1

'*****************************CHANGE POLARIZATION
'To Horizontal
15 P$ = "Hor"
LOCATE 2
PRINT "B-Tubes O-Logic L-Line F-File W-Write S-Step H-Hor V-Vert|Mode="; P$; ""
GOTO 1

' To Vertical
16 P$ = "Vert"
LOCATE 2
PRINT "B-Tubes O-Logic L-Line F-File W-Write S-Step H-Hor V-Vert|Mode="; P$; ""
GOTO 1

'***************************WRITE INFO
53 VIEW PRINT
LOCATE INT(SY / 8) + 1, INT(SX / 8) + 1
INPUT ; "", U$
VIEW PRINT 1 TO 3
GOSUB 11
GOTO 1

'*****************************CHANGE FUNCTION KEYS
' List Fkeys
99 CLS: SCREEN 0: COLOR 3, 0, 1
_FULLSCREEN 'QB64
IF _FULLSCREEN = 0 THEN _FULLSCREEN _OFF 'QB64
FOR X = 1 TO 12
    PRINT "                    Function Key #"; X; ": "; F(X)
NEXT X
PRINT "                   Type 13 As Key# For Help."
PRINT "                TYPE 14 As Key# To Print Fkeys"

'Get New Fkeys
INPUT "ENTER KEY# ", X
IF X = 13 THEN 110
IF X = 14 THEN 117
INPUT "ENTER KEY SEQUENCE: ", S$
F(X) = S$
INPUT "ENTER ANOTHER? (Y/N): ", R$
IF R$ = "Y" OR R$ = "y" THEN 99

'Save Fkeys To Disk
INPUT "ENTER DRIVE LETTER: ", D$ 'QuickBasic
OPEN D$ + "SCH.KYS" FOR OUTPUT AS #1 'QuickBasic
FOR X = 1 TO 12
    PRINT #1, F(X)
NEXT X
CLOSE #1

' Set Fkeys
FOR X = 1 TO 12
    Y = X
    IF X = 11 THEN Y = 30
    IF X = 12 THEN Y = 31
    KEY Y, F(X)
NEXT X
KEY OFF
GOTO 85

' Print Fkeys
117 FOR X = 1 TO 12
    LPRINT "                    Function Key #"; X; ": "; F(X)
    LPRINT
NEXT X
GOTO 99

'************************ COMPONENTS ************************

'**********************TRANSISTOR
'Print Menu
17 LOCATE 1, 1
PRINT "N-NPN P-PNP U-UJT C-CUJT D-PUT S-SCR R-CSCR W-SCS O-SUS B-SBS T-Triac J-N JFET"
PRINT "F-P JFET G-N Mosfet E-P Mosfet M-Main Menu                                    "

' Accept Input
18 I$ = INKEY$: IF I$ = "" THEN 18
IF I$ = "M" OR I$ = "m" THEN 19 'MAIN MENU
IF I$ = "N" OR I$ = "n" THEN 20 'NPN
IF I$ = "P" OR I$ = "p" THEN 21 'PNP
IF I$ = "U" OR I$ = "u" THEN 22 'UJT
IF I$ = "C" OR I$ = "c" THEN 23 'CUJT
IF I$ = "D" OR I$ = "d" THEN 24 'PUT
IF I$ = "R" OR I$ = "r" THEN 24 'CSCR
IF I$ = "S" OR I$ = "s" THEN 25 'SCR
IF I$ = "W" OR I$ = "w" THEN 26 'SCS
IF I$ = "O" OR I$ = "o" THEN 27 'SUS
IF I$ = "B" OR I$ = "b" THEN 28 'SBS
IF I$ = "T" OR I$ = "t" THEN 29 'TRIAC
IF I$ = "J" OR I$ = "j" THEN 30 'N-JFET
IF I$ = "F" OR I$ = "f" THEN 31 'P-JFET
IF I$ = "G" OR I$ = "g" THEN 32 'N-MOSFET
IF I$ = "E" OR I$ = "e" THEN 33 'P-MOSFET
GOTO 18

' Main Menu
19 GOSUB 11
GOTO 1

' NPN
20 V$ = "D3 L6 R12 L2 D6 U6 L7 D2 L2 R4 L1 D1 L2 R1 D3"
H$ = "R6 U4 D8 U2 R4 U2 D4 R1 U4 D2 R1 U1 D2 R1 U2 D1 R4 BU5 L9"
GOTO 58

' PNP
21 V$ = "D3 R10 L20 BD1 BR 16 D6 R2 BL18 R6 U3 L2 R4 L1 U1 L2 R1 U1"
H$ = "R6 U4 D8 U2 R3 U1 D2 R1 U2 R1 U1 D4 R1 U4 D2 R5 BU5 L11 R11"
GOTO 58

' Unijunction Transistor
22 V$ = "G3 D1 L2 R4 L1 D1 L2 R1 D2 L7 R14 L2 D4 BL10 U4 D4"
H$ = "F4 U1 D2 R1 U2 D1 R3 U3 D6 U1 R8 BU4 L8 R8"
GOTO 58

' Complementary Unijunction Transistor
23 V$ = "G3 D1 R1 L3 D1 L1 R5 L2 D2 R7 L14 R2 D4 U4 R10 D4"
H$ = "F3 R2 U1 D2 R1 U2 R1 U1 D4 U2 R4 U4 D1 R7 L7 D7 U1 R7"
GOTO 58

'Programmable Unijunction Transistor
24 V$ = "D3 L4 R8 E3 G3 L1 D1 L6 R1 D1 R4 L1 D1 L2 R1 D2 L2 R4 L2 D2 BR20"
H$ = "R6 U2 H2 F2 D4 R1 U4 D1 R1 D2 R1 U2 D1 R4 U1 D2 U1 R4"
GOTO 58

' SCR
25 V$ = "D3 L4 R8 L1 D1 L6 R1 D1 R4 L1 D1 L2 R1 D1 L4  R8 L2 D3 U3 L3 G3"
H$ = "R6 U2 D4 R1 U4 D1 R1 D2 R1 U2 D1 R4 U2 D4 F2 H2 U2 R4"
GOTO 58

' Silicon Controlled Switch
26 V$ = "D3 L4 R8 E3 G3 L1 D1 L6 R1 D1 R4 L1 D1 L2 R1 D2 L3 R6 L2 D3 U3 L2 G3"
H$ = "R6 U2 H2 F2 D4 R1 U4 D1 R1 D2 R1 U2 D1 R4 U2 D4 F2 H2 U2 R4"
GOTO 58

' Silicon Unilateral Switch
27 V$ = "D3 R6 G6 U6 L6 R6 D6 L3 R6 L3 D3"
H$ = "D12 H6 R12 L12 U3 D6 U3 L6"
GOTO 58

' Silicon Bilateral Switch
28 IF P$ = "Vert" THEN 59
H$ = "D12 U6 L9 R15 L6 U3 L6 R11 D1 G5 L6 E6 U3"
GOTO 58

' Triac
29 IF P$ = "Hor" THEN 59
V$ = "D4 G3 H3 R12 L3 D1 F3 L6 E3 G3 D3 U3 L6 G3"
GOTO 58

' N-jfet
30 V$ = "D3 D1 L2 R4 L1 D1 L2 R1 D2 L7 R16 D1 L16 R2 D4 U4 R11 D4"
H$ = "R6 U3 D6 R1 U6 D1 R1 D4 R1 U4 D2 R3 U5 D10 U2 R6 L6 U6 R6"
GOTO 58

' P-jfet
31 V$ = "D3 L1 R2 D1 R1 L4 R2 D2 L5 R10 D1 L10 R2 D3 L6 R6 U3 R6 D3 R6"
H$ = "R4 U1 D2 R1 U2 R1 U1 D4 R1 U4 D2 R4 U5 D10 U2 R6 L6 U6 R6"
GOTO 58

' N-mosfet
32 V$ = "D2 R7 BD2 R3 D2 L1 D5 R4 L4 U5 L2 U2 BL3 D2 L1 D2 L2 R4 L2 D1 L1 R2 L1 D2 L6 R6 U5 L2 U2 R3 BL6 D2 L3 U2 R3 D2 L2 D5 L4"
H$ = "R5 U7 BR2 U3 R3 D2 R9 U4 D4 L9 D2 L3 BD3 R3 D1 R3 U1 D2 R1 U2 R1 U1 D4 R1 U4 D2 R3 D6 U6 L9 D2 L3 U3 BD6 D3 R3 U3 L3 D3 R3 U1 R9 D4"
GOTO 58

' P-mosfet
33 V$ = "D2 R7 BD2 R3 D2 L1 D5 R4 L4 U5 L2 U2 BL3 D2 L1 D2 L2 R4 L2 D1 L1 R2 L1 D2 L6 R6 U5 L2 U2 R3 BL6 D2 L3 U2 R3 D2 L2 D5 L4"
H$ = "R5 U7 BR2 U3 R3 D2 R9 U4 D4 L9 D2 L3 BD3 R3 D1 R3 U2 D4 R1 U4 D1 R1 D2 R1 U2 D1 R3 D6 U6 L9 D2 L3 U3 BD6 D3 R3 U3 L3 D3 R3 U1 R9 D4"
GOTO 58

'***************************INTEGRATED CIRCUITS

' Information
34 PRINT: PRINT
PRINT "NUMBER OF PINS";: INPUT P
IF P <= 2 THEN 35
P = P / 2

' Position
VIEW PRINT
X = INT(SY / 8) + 1: Y = INT(SX / 8) + 1
LOCATE X, Y

' Top
PRINT "Ú";
FOR A = 1 TO P: PRINT "ÄÁ";
NEXT A
PRINT "¿"

' MIDDLE
X = X + 1
LOCATE X, Y
PRINT "³ ^";
FOR A = 1 TO P - 1: PRINT "  ";
NEXT A
PRINT "³"

' BOTTOM
X = X + 1
LOCATE X, Y
PRINT "À";
FOR A = 1 TO P
    PRINT "ÄÂ";
NEXT A

PRINT "Ù"
VIEW PRINT 1 TO 3
GOSUB 11
GOTO 1

'**************************Information Error Trap
35 IF PN$ = "N" OR PN$ = "n" THEN 24

'********************************DIODES

' PRINT MENU
36 PRINT "D-STND  Z-ZENER  T-TUNNEL  H-THYRECTOR  I-DIAC TRIGGER  M-MENU"
PRINT

'Accept Input
37 I$ = INKEY$: IF I$ = "" THEN 37
IF I$ = "D" OR I$ = "d" THEN 38
IF I$ = "Z" OR I$ = "z" THEN 39
IF I$ = "T" OR I$ = "t" THEN 40
IF I$ = "H" OR I$ = "h" THEN 41
IF I$ = "I" OR I$ = "i" THEN 42
IF I$ = "M" OR I$ = "m" THEN 43
GOTO 37

'Standard
38 V$ = "D3 L4 R8 L1 D1 L6 R1 D1 R4 L1 D1 L2 R1 D2 L3 R6 L3 D3"
H$ = "R6 U4 D8 R1 U8 D1 R1 D6 R1 U6 D1 R1 D4 R1 U4 D2 R4 U3 D6 U3 R6"
GOTO 58

'Zener
39 V$ = "D3 L4 R8 L1 D1 L6 R1 D1 R4 L1 D1 L2 R1 D2 L4 U1 D1 R8 D1 U1 L4 D3"
H$ = "R6 U4 D8 R1 U8 D1 R1 D6 R1 U6 D1 R1 D4 R1 U4 D2 R5 U3 L2 R2 D6 R2 L2 U3 R6"
GOTO 58

'Tunnel
40 V$ = "D3 L4 R8 L1 D1 L6 R1 D1 R4 L1 D1 L2 R1 D2 L4 U1 D1 R8 U1 D1 L4 D3"
H$ = "R6 U4 D8 R1 U8 D1 R1 D6 R1 U6 D1 R1 D4 R1 U4 D2 R4 U3 L2 R2 D6 L2 R2 U3 R6"
GOTO 58

'Thyrector
41 V$ = "D3 L3 R6 L3 D1 L2 R4 L2 D1 L1 R2 L1 D2 L2 BL5 U2 D2 L4 R4 BR5 R4 L2 D2 L1 R2 L1 D1 L2 R4 L2 D1 L3 R6 L3 D3"
H$ = "R6 U3 D6 R1 U6 D1 R1 D4 R1 U4 D1 R1 D2 R1 U2 D1 R4 U2 D4 BD3 L4 R4 D3 U3 BU5 R4 U1 D2 R1 U2 R1 U1 D4 R1 U4 R1 U1 D6 R1 U6 D3 R4"
GOTO 58

'Diac Trigger
42 V$ = "L8 R17 L4 D3 L3 R6 L1 D1 L4 R1 D1 R2 L1 D2 R6 BL21 R7 U2 L1 R2 U1 R1 L4 U1 L1 R6 L3 U3"
H$ = "D8 U16 D5 R4 U4 D8 R1 U8 D1 R1 D4 R1 U4 D1 R1 D2 R1 U2 D1 R5 U6 BD20 U6 L5 U1 D2 L1 U2 L1 U1 D4 L1 U4 L1 U1 D6 L1 U6 D3 L4"
GOTO 58

'Main Menu
43 GOSUB 11
GOTO 1

'****************************PASSIVE COMPONENTS

' Print menu
46 PRINT " C-Capacitor  R-Resistor  O-Coil  M-Main Menu"
PRINT
'Accept Input
47 I$ = INKEY$: IF I$ = "" THEN 47
IF I$ = "C" OR I$ = "c" THEN 48
IF I$ = "R" OR I$ = "r" THEN 49
IF I$ = "O" OR I$ = "o" THEN 50
IF I$ = "M" OR I$ = "m" THEN 52
GOTO 47

'Capacitor
48 V$ = "D3 R6 L12 BD2 D3 U3 R12 D3 U3 L6 D6"
H$ = "R6 D3 U6 BR6 R4 L4 D6 R4 L4 U3 R10"
GOTO 58

'Resistor
49 V$ = "D3 G2 F4 G4 F4 G2 D3"
H$ = "R6 E3 F6 E6 F6 E6 F6 E3 R6"
GOTO 58

'Coil
'Determine Polarization
50 IF P$ = "Vert" THEN
    'Draw Vertical Coil
    DRAW "BM " + STR$(SX) + ", " + STR$(SY) + "D3"
    SY = SY + 5
    FOR X = 1 TO 3
        CIRCLE (SX, SY), 3
        SY = SY + 3
    NEXT X
    DRAW "BM " + STR$(SX) + ", " + STR$(SY) + " D3"
    SY = SY + 3
    GOSUB 11
    GOTO 1
ELSE
    'Draw Horizontal Coil
    DRAW "BM " + STR$(SX) + ", " + STR$(SY) + " R6"
    SX = SX + 11
    FOR X = 1 TO 3
        CIRCLE (SX, SY), 6
        SX = SX + 6
    NEXT X
    SX = SX + 2
    DRAW "BM " + STR$(SX) + ", " + STR$(SY) + " R6"
    SX = SX + 6
    GOSUB 11
    GOTO 1
END IF

'Main Menu
52 GOSUB 11
GOTO 1

'*****************************     MISC PARTS

'Print Menu
62 PRINT "V-Variable Arrow  A-Antenna  B-Box  G-Ground  C-Chassis Gnd.  S-Switch  X-Xtal"
PRINT "L-Left Arrow  R-Right Arrow  U-Up Arrow  D-Down Arrow  P-Push Btn  M-Main Menu  "

'Accept Input
63 I$ = INKEY$: IF I$ = "" THEN 63
IF I$ = "V" OR I$ = "v" THEN 64
IF I$ = "A" OR I$ = "a" THEN 65
IF I$ = "B" OR I$ = "b" THEN 66
IF I$ = "G" OR I$ = "g" THEN 67
IF I$ = "C" OR I$ = "c" THEN 68
IF I$ = "S" OR I$ = "s" THEN 69
IF I$ = "L" OR I$ = "l" THEN 70
IF I$ = "R" OR I$ = "r" THEN 71
IF I$ = "U" OR I$ = "u" THEN 72
IF I$ = "D" OR I$ = "d" THEN 73
IF I$ = "X" OR I$ = "x" THEN 80
IF I$ = "M" OR I$ = "m" THEN 81
IF I$ = "P" OR I$ = "p" THEN 118
GOTO 63

'Main Menu
81 GOSUB 11
GOTO 1

'Variable Arrow
64 V$ = "H16 R3 L3 D3"
H$ = "E14 D3 U3 L3"
GOTO 58

'Antenna
65 IF P$ = "Hor" THEN 59
V$ = "U9 G6 R12 H6"
GOTO 58

'Box
66 V$ = "R96 D32 L96 U32"
H$ = V$
GOTO 58

'Ground
67 IF P$ = "Hor" THEN 59
V$ = "D3 L3 R6 L1 BD2 L4 R1 BD2 R2"
GOTO 58

'Chassis Ground
68 IF P$ = "Hor" THEN 59
V$ = "D6 U3 L6 D3 U3 R12 D3"
GOTO 58

'Switch
69 CIRCLE (SX, SY), 4
V$ = "D8"
H$ = "BU4 R16"
GOTO 58

'Left Arrow
70 V$ = "E2 G2 F2 H2 R7"
H$ = V$
GOTO 58

'Right Arrow
71 V$ = "R7 H2 F2 G2"
H$ = V$
GOTO 58

'Up Arrow
72 V$ = "U5 G2 E2 F2"
H$ = V$
GOTO 58

'Down Arrow
73 V$ = "D5 H2 F2 E2"
H$ = V$
GOTO 58

'Crystal
80 V$ = "D3 R3 L6 BD2 R6 D2 L6 U2 D2 BD2 R6 L3 D3"
H$ = "R6 U3 D6 BR4 U6 R4 D6 L4 BR8 U6 D3 R6"
GOTO 58

'Push Button
118 V$ = "D3 L6 R12"
H$ = "R6 D3 U6"
GOTO 58


'*********************  MISC PARTS #2

'Print Menu
119 PRINT "A-AC Plug  E-Meter  L-Lamp  B-Battery  S-Speaker  P-Piezo Buzzer  O-Op Amp"
PRINT "M-Main Menu"

' Accept Input
120 I$ = INKEY$: IF I$ = "" THEN 120
IF I$ = "A" OR I$ = "a" THEN 121
IF I$ = "E" OR I$ = "e" THEN 122
IF I$ = "L" OR I$ = "l" THEN 123
IF I$ = "B" OR I$ = "b" THEN 124
IF I$ = "S" OR I$ = "s" THEN 125
IF I$ = "P" OR I$ = "p" THEN 126
IF I$ = "M" OR I$ = "m" THEN 129
IF I$ = "O" OR I$ = "o" THEN 139
GOTO 120

' AC Plug
121 V$ = "BU11 D3 R2 L3 U3 D3 L5 U3 L1 D3 L3 R1 D1 F2 D5 U5 F3 R1 E3 D5 U5 E2 U1"
H$ = V$
GOTO 58

'Meter
122 V$ = "R6 U3 R14 D3 R6 L6 D6 L14 U6 D3 R14 L4 H4"
H$ = V$
GOTO 58

'Lamp
123 V$ = "D4 F6 E2 U2 L2 G6 D4"
H$ = "R7 E3 H1 L2 D1 F3 R7"
GOTO 58

'Battery
124 V$ = "D3 L4 L6 R6 D2 R6 U8 L6 D2 U2 R6 E6 D21 H6"
H$ = "R6 U3 D3 L2 D3 R8 U3 L2 R2 D3 F6 L21 E6"
GOTO 58

'Speaker
125 V$ = "R6 D4 L6 R6 D2 R6 U8 L6 D2 U2 R6 E6 D21 H6"
H$ = "D3 L4 U3 D3 L2 D3 R8 U3 L2 R2 D3 F6 L21 E6"
GOTO 58

'Piezo Buzzer
'Determine Polarization
126 IF P$ = "Hor" THEN
    'Draw Vertical
    DRAW "BD3 R6 BR22 R6"
    CX = SX + 13
    CIRCLE (SX, CY), 10
    CIRCLE (SX, CY), 3
    GOSUB 11
    GOTO 1
ELSE
    'Draw Horizontal
    DRAW "BR2 D3 BD10 D3"
    CY = SY + 5
    CIRCLE (SX, CY), 10
    CIRCLE (SX, CY), 3
    GOSUB 11
    GOTO 1
END IF

'Operational Amplifier
139 V$ = "D3 G6 R3 D3 U3 R6 D3 U3 R3 H6"
H$ = ""
GOTO 58

'Main Menu
129 GOSUB 11
GOTO 1


'****************************** LOGIC

'Display Menu
130 PRINT "A-And N-Nand I=Inverter O-Or R-Nor E-Ex-or M-Main Menu"
PRINT

'Accept Input
131 I$ = INKEY$: IF I$ = "" THEN 131
IF I$ = "A" OR I$ = "a" THEN 132
IF I$ = "N" OR I$ = "n" THEN 133
IF I$ = "I" OR I$ = "i" THEN 134
IF I$ = "O" OR I$ = "o" THEN 135
IF I$ = "R" OR I$ = "r" THEN 136
IF I$ = "E" OR I$ = "e" THEN 137
IF I$ = "M" OR I$ = "m" THEN 138
GOTO 131

'And Gate
132 V$ = "D3 G6 D3 R2 D3 U3 R8 D3 U3 R2 U3 H6 L1 U3"
H$ = "R6 U2 R10 F3 R6 L6 D1 G3 L10 U2 L6 R6 U3"
GOTO 58

'Nand Gate
133 V$ = "BD5 G6 D3 R2 D3 U3 R8 D3 U3 R2 U3 H6 L2 U2 R4 D2 L2 U5"
H$ = "R6 U2 R10 F3 R2 U1 R4 D2 L4 U1 BR4 R6 BL12 D1 G3 L10 U2 L6 R6 U3"
GOTO 58

'Inverter
134 V$ = "D3 L2 D2 R4 U2 L2 BD2 G6 R6 D3 U3 R6 H6"
H$ = ""
GOTO 58

'Or Gate
135 V$ = "D3 G8 D3 U2 R4 D3 U3 R8 D3 U3 R4 D2 U3 H8 L1 U3"
H$ = "R6 U2 L3 R3 R10 F3 R6 L6 D1 G3 L10 L3 R3 U2 L6 R6 U3"
GOTO 58

'Nor Gate
136 V$ = "D3 L2 D2 R4 U2 L2 BD2 G8 D3 U2 R4 D3 U3 R8 D3 U3 R4 D2 U3 H8"
H$ = "R6 U2 L3 R13 F3 R3 U2 R2 D2 R6 L6 D2 L2 U2 L3 D1 G3 L13 R3 U4 D2 L6"
GOTO 58

'Ex-or Gate
137 V$ = "D3 L2 D2 R4 U2 L2 BD2 G8 D3 U2 R4 D7 U3 L3 D2 U2 R14 D2 U2 L11 U4 R8 D7 U7 R4 D2 U3 H8"
H$ = "R6 U2 L3 R3 D7 L3 R3 U5 R6 U2 L3 R13 F3 R3 U2 R2 D4 L2 U2 BR2 R6 BL11 D1 G3 L13 R3 U2 L12 R12 U3"
GOTO 58

'Main Menu
138 GOSUB 11
GOTO 1

'****************************TUBES

'Print Menu
142 PRINT "F-Filament C-Cathode P-Plate G-Grid M-Main Menu"
PRINT

'Accept Input
143 I$ = INKEY$: IF I$ = "" THEN 143
IF I$ = "F" OR I$ = "f" THEN 144
IF I$ = "P" OR I$ = "p" THEN 145
IF I$ = "C" OR I$ = "c" THEN 146
IF I$ = "G" OR I$ = "g" THEN 147
IF I$ = "M" OR I$ = "m" THEN 148

'Filament
144 V$ = "U6 E3 F3 D6"
H$ = "R12 F3 G3 L12"
GOTO 58

'Cathode
145 V$ = "U6 R12 D2"
H$ = "L12 U6 R2"
GOTO 58

'Plate
146 V$ = "D6 L6 R12"
H$ = "L12 U3 D6"
GOTO 58

'Grid
147 V$ = "R2 BR4 R2 BR4 R2"
H$ = "D3 BD3 D3 BD3 D3"
GOTO 58

'Main Menu
148 GOSUB 11
GOTO 1

'*****************************PHOTONIC
44 V$ = "G2 E2 F2 E2 F2 H2 D5 BL4 U5"
H$ = "F2 G2 F2 G2 E2 L10 BU4 R10"
GOTO 58

'*****************************CONNECTION
45 CIRCLE (SX, SY), 4
GOTO 1

'*****************************DRAW SHAPE
58 IF P$ = "Hor" THEN
    DRAW "BM " + STR$(SX) + ", " + STR$(SY) + " BD3 BR3 X" + VARPTR$(H$)
ELSE
    DRAW "BM " + STR$(SX) + ", " + STR$(SY) + " BD3 BR3 X" + VARPTR$(V$)
END IF
GOSUB 11
GOTO 1

'*****************************Display Component Not Availiable In This Polarization
59 PRINT: PRINT "Sorry, this component isn't available in this mode."
' FOR A = 1 to 450 : NEXT A 'QUICK BASIC
_DELAY 7 'QB64
GOSUB 11
GOTO 1

'****************************   HELP   ***************************

'***************************** FUNCTION KEYS

' print choices
110 CLS
LOCATE 10, 1
PRINT "                                    Would you like "
PRINT "                                 <D>irections or a"
PRINT "                                 <K>ey List"
PRINT
PRINT "                       Type the letter in the <> of your choice "
112 I$ = INKEY$
IF I$ = "D" OR I$ = "d" THEN 113
IF I$ = "K" OR I$ = "k" THEN 115
GOTO 112
113 CLS
PRINT " ****************************************************************************"
PRINT " *                                   HELP                                   *"
PRINT " *                           FUNCTION KEYS MACROS                           *"
PRINT " ****************************************************************************"
PRINT "       By setting function key macros, you can save time by only having"
PRINT "    press one key for things that usually take more."
PRINT "       The computer will ask you to enter the number of the key you would"
PRINT "    like to set.  Next it will ask you for the key sequence. This is the"
PRINT "    keys you would normally have to type for whatever you want the key to"
PRINT "    do."
PRINT "       Next you will be asked for a drive letter. This is to tell the"
PRINT "    computer what drive to save the macros on, so that tyhey will be ready"
PRINT "    the next time you run the program. This must be on the same disk as"
PRINT "    Schemat."
PRINT "       The chart at the top tells you what the macros are already set at."
LOCATE 23, 1
PRINT "                                               Press <D> when done reading."
114 I$ = INKEY$
IF I$ = "D" OR I$ = "d" THEN 115
GOTO 114

'Key List
115 CLS
PRINT "                             Main Menu"
PRINT "                             ÄÄÄÄÄÄÄÄÄ"
PRINT "T-Transistor U-IC A-Passive D-Diode P-Photonic C-Connection M-Misc I-Misc2"
PRINT "B-Tubes O-Logic F-File W-Write S-Step H-Hor V-Vert"
PRINT
PRINT "                            Transistor Menu"
PRINT "                            ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
PRINT "N-NPN P-PNP C-CUJT D-PUT S-SCR R-CSR W-WCS O-SUS B-SBS T-Triac J-N JFET"
PRINT "F-P JFET G-N MOSFET E-P MOSFET"
PRINT
PRINT "                         Passive Component Menu"
PRINT "                         ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
PRINT "                      C-Capacitor R-Resistor O-Coil"
PRINT
PRINT "                           Miscellaneous"
PRINT "                           ÄÄÄÄÄÄÄÄÄÄÄÄÄ"
PRINT "V-Variable Arrow A-Antenna B-Box G-Ground C-Chassis Ground S-Switch X-XTAL"
PRINT "L-Left Arrow R-Right Arrow U-Up Arrow P-Push Button"
PRINT
PRINT "                               FILE"
PRINT "                               ÄÄÄÄ"
PRINT "N-New O-Open S-Save A-Save As P-Print M-Main Menu H-Shell E-End"
PRINT "                                                 Press <D> when done reading."
116 I$ = INKEY$: IF I$ = "" THEN 116
IF I$ = "d" OR I$ = "d" THEN 140
GOTO 116
140 CLS
PRINT
PRINT "                          Miscellaneous 2"
PRINT "                          ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
PRINT "A-Ac Plug  E-Meter  L-Lamp  B-Battery  S-Speaker  P-Piezo Buzzer  O-Op Amp"
PRINT
PRINT "                                LOGIC"
PRINT "                                ÄÄÄÄÄ"
PRINT "             A-And  N-Nand  I-Inverter  O-Or  R-Nor  E-Ex-or"
PRINT
PRINT "                                TUBES"
PRINT "                                ÄÄÄÄÄ"
PRINT "               F-Filament  C-Cathode  P-Plate  G-Grid"
PRINT
PRINT "                           ASCII SYMBOLS"
PRINT "                           ÄÄÄÄÄÄÄÄÄÄÄÄÄ"
PRINT
PRINT "Press and hold the <Alt> button, and type the numberr of the character"
PRINT "that you would like to type."
PRINT
PRINT "   Some usefull caracters are:"
PRINT "                               234 ê   179 ³   180 ´"
PRINT "                               191 ¿   192 À   193 Á"
PRINT "                               194 Â   195 Ã   196 Ä"
PRINT "                               197 Å"
LOCATE 23, 50: PRINT "Press <D> when done reading."
141 I$ = INKEY$: IF I$ = "" THEN 141
IF I$ = "D" OR I$ = "d" THEN 99
GOTO 141

' FROM https://www.qb64.org/wiki/SAVEIMAGE
' License: "This SUB program can also be Included with any program!"
SUB SaveImage (image AS LONG, filename AS STRING)
    bytesperpixel& = _PIXELSIZE(image&)
    IF bytesperpixel& = 0 THEN PRINT "Text modes unsupported!": END
    IF bytesperpixel& = 1 THEN bpp& = 8 ELSE bpp& = 24
    x& = _WIDTH(image&)
    y& = _HEIGHT(image&)
    b$ = "BM????QB64????" + MKL$(40) + MKL$(x&) + MKL$(y&) + MKI$(1) + MKI$(bpp&) + MKL$(0) + "????" + STRING$(16, 0) 'partial BMP header info(???? to be filled later)
    IF bytesperpixel& = 1 THEN
        FOR c& = 0 TO 255 ' read BGR color settings from JPG image + 1 byte spacer(CHR$(0))
            cv& = _PALETTECOLOR(c&, image&) ' color attribute to read.
            b$ = b$ + CHR$(_BLUE32(cv&)) + CHR$(_GREEN32(cv&)) + CHR$(_RED32(cv&)) + CHR$(0) 'spacer byte
        NEXT
    END IF
    MID$(b$, 11, 4) = MKL$(LEN(b$)) ' image pixel data offset(BMP header)
    lastsource& = _SOURCE
    _SOURCE image&
    IF ((x& * 3) MOD 4) THEN padder$ = STRING$(4 - ((x& * 3) MOD 4), 0)
    FOR py& = y& - 1 TO 0 STEP -1 ' read JPG image pixel color data
        r$ = ""
        FOR px& = 0 TO x& - 1
            c& = POINT(px&, py&) 'POINT 32 bit values are large LONG values
            IF bytesperpixel& = 1 THEN r$ = r$ + CHR$(c&) ELSE r$ = r$ + LEFT$(MKL$(c&), 3)
        NEXT px&
        d$ = d$ + r$ + padder$
    NEXT py&
    _SOURCE lastsource&
    MID$(b$, 35, 4) = MKL$(LEN(d$)) ' image size(BMP header)
    b$ = b$ + d$ ' total file data bytes to create file
    MID$(b$, 3, 4) = MKL$(LEN(b$)) ' size of data file(BMP header)
    IF LCASE$(RIGHT$(filename$, 4)) <> ".bmp" THEN ext$ = ".BMP"
    f& = FREEFILE
    OPEN filename$ + ext$ FOR OUTPUT AS #f&: CLOSE #f& ' erases an existing file
    OPEN filename$ + ext$ FOR BINARY AS #f&
    PUT #f&, , b$
    CLOSE #f&
END SUB
