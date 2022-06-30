'$DYNAMIC
'defines type for LoadPcx
'defines map and tile dimensions
Common Shared xmat As Integer, ymat As Integer
Common Shared Mouse$
Common Shared map() As Integer, tiles()
Common Shared door(), littledoor()
Common Shared boxes(), arrows(), blue(), red()
Common Shared font(), chrcodes() As Integer
Common Shared A As Integer, b As Integer
Common Shared adda As Integer, addb As Integer
Common Shared pathsa() As Integer, pathsb() As Integer
Common Shared phantoms As Integer, bugs As Integer
Common Shared phantom(), bug(), pac()
Common Shared stagename$, stagetext$
Common Shared addlife As Integer
Common Shared xdatabase As Integer, ydatabase As Integer
Common Shared aghost As Integer, bghost As Integer
Common Shared xprison As Integer, yprison As Integer
Common Shared badpactime As Integer
Common Shared ega(), seestock As Integer
Common Shared selection As Integer, material As Integer
Common Shared resopt(), noerase()
Common kind As Integer, border As Integer
Common i%, arrows%
Common TIMERbefore As Single
Common file$, MouseIcon$(), changeicon As Integer
Common xx As Integer, yy As Integer
Common xx2 As Integer, yy2 As Integer
Common Lb As Integer, Rb As Integer

Type TH
    MAN As String * 1
    VER As String * 1
    ENC As String * 1
    BIT As String * 1
    XLS As Integer
    YLS As Integer
    XMS As Integer
    YMS As Integer
    HRE As Integer
    VRE As Integer
    col As String * 48
    res As String * 1
    PLA As String * 1
    BYT As Integer
    pal As Integer
    FIL As String * 58
End Type

On Error GoTo errortrapping
'defines map and tile dimensions
Dim Shared map(34, 30) As Integer, tiles(50, 65)
Dim Shared door(50, 8), littledoor(40, 2)
Dim Shared boxes(8, 9), arrows(20, 4), blue(80), red(80)
Dim Shared font(8, 53), chrcodes(256) As Integer
Dim Shared pathsa(4) As Integer, pathsb(4) As Integer
Dim Shared phantom(54, 2), bug(48, 2), pac(54, 9)
Dim Shared ega(16)
Dim Shared resopt(400), noerase(2500)
Dim MouseIcon$(9)
Mouse$ = Space$(57)

changeicon = 1 'if the mouse is too slow change this to 0

For i% = 1 To 47: Read OBJ$
    h$ = Chr$(Val("&H" + OBJ$))
    Mid$(Mouse$, i%, 1) = h$
Next i%

Data 55,8B,EC,56,8B,76,0C,56,8B,04,8B,76,0A,56,8B,1C
Data 8B,76,08,56,8B,0C,8B,76,06,8B,14,1E,07,CD,33,89
Data 14,5E,89,0C,5E,89,1C,5E,89,04,5E,5D,CA,08,00

For arrows% = 0 To 8
    MouseIcon$(arrows%) = Space$(64)
    For i% = 1 To 64
        Read q$: q$ = Chr$(Val("&H" + q$))
        Mid$(MouseIcon$(arrows%), i%, 1) = q$
    Next i%
Next arrows%

'pointer
Data FF,FE,7F,FC,7F,FC,7F,FC,7F,FC,7F,FC,83,82,01,01
Data 83,82,FF,FC,7F,FC,7F,FC,7F,FC,7F,FC,FF,FE,FF,FF
Data 00,00,00,01,00,01,00,01,00,01,00,01,00,00,7C,7C
Data 00,00,00,01,00,01,00,01,00,01,00,01,00,00,00,00
'DATA 7F,FF,3F,FF,1F,FF,0F,FF,07,FF,03,FF,01,FF,01,FF
'DATA C3,FF,C3,FF,E3,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF
'DATA 80,00,C0,00,A0,00,90,00,88,00,84,00,82,00,EE,00
'DATA 24,00,34,00,1C,00,00,00,00,00,00,00,00,00,00,00
'up arrow
Data FF,FB,FF,F1,FF,E0,7F,C0,3F,80,1F,00,FF,E0,FF,E0
Data FF,E0,FF,E0,FF,E0,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF
Data 00,04,00,0A,00,11,80,20,40,40,E0,F1,00,11,00,11
Data 00,11,00,11,00,1F,00,00,00,00,00,00,00,00,00,00
'down arrow
Data FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,E0,FF,E0,FF,E0
Data FF,E0,FF,E0,1F,00,3F,80,7F,C0,FF,E0,FF,F1,FF,FB
Data 00,00,00,00,00,00,00,00,00,00,00,1F,00,11,00,11
Data 00,11,00,11,E0,F1,40,40,80,20,00,11,00,0A,00,04
'left arrow
Data FF,FB,FF,F3,FF,E3,1F,C0,1F,80,1F,00,1F,80,1F,C0
Data FF,E3,FF,F3,FF,FB,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF
Data 00,04,00,0C,00,14,E0,27,20,40,20,80,20,40,E0,27
Data 00,14,00,0C,00,04,00,00,00,00,00,00,00,00,00,00
'right arrow
Data DF,FF,CF,FF,C7,FF,03,F8,01,F8,00,F8,01,F8,03,F8
Data C7,FF,CF,FF,DF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF
Data 20,00,30,00,28,00,E4,07,02,04,01,04,02,04,E4,07
Data 28,00,30,00,20,00,00,00,00,00,00,00,00,00,00,00
'up-left arrow
Data FF,00,FF,01,FF,03,FF,01,FF,00,7F,20,3F,70,7F,F8
Data FF,FC,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF
Data 00,FF,00,82,00,84,00,82,00,A1,80,D0,40,88,80,04
Data 00,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00
'down-left arrow
Data FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FC
Data 7F,F8,3F,70,7F,20,FF,00,FF,01,FF,03,FF,01,FF,00
Data 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,03
Data 80,04,40,88,80,D0,00,A1,00,82,00,84,00,82,00,FF
'up-right arrow
Data 00,FF,80,FF,C0,FF,80,FF,00,FF,04,FE,0E,FC,1F,FE
Data 3F,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF
Data FF,00,41,00,21,00,41,00,85,00,0B,01,11,02,20,01
Data C0,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
'down-right arrow
Data FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,FF,3F,FF
Data 1F,FE,0E,FC,04,FE,00,FF,80,FF,C0,FF,80,FF,00,FF
Data 00,00,00,00,00,00,00,00,00,00,00,00,00,00,C0,00
Data 20,01,11,02,0B,01,85,00,41,00,21,00,41,00,FF,00

For kind = 0 To 15 'this is for LoadPcx sub. makes my own ega palette
    Read ega(kind)
Next kind

Data 11,0,0,14,10,12,8,7,3,0,0,0,0,0,0,0

'this is for LoadMap and RandomMove subs. defines pac direction
pathsa(0) = -1: pathsa(1) = 0: pathsa(2) = 0: pathsa(3) = 1
pathsb(0) = 0: pathsb(1) = -1: pathsb(2) = 1: pathsb(3) = 0

For kind = 0 To 255 'these codes identify which graphic letter must be printed
    Read chrcodes(kind)
Next kind
                                                                                                   
'<SPACE>'()�,-./0123456789:;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\
Data 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,49,50,50,36,50,50,50,39,42,43,51,50,44,45,37,40,00,01,02,03,04,05,06,07,08,09,38,46,50,50,50,41,47,10,11,12,13,14,15,16
Data 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,50,48,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
Data 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,52,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
Data 50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50
                                                                                         
If Not MouseInit% Then
    Screen 0: Width 80: Cls
    Print "MOUSE IS REQUIRED"
    End
End If

Screen 7, , 0, 1 '320x200 16 colors mode initialization

LoadPcx "default.pcx" 'graphics loading

Get (68, 92)-(83, 107), tiles(0, 3) 'red face tile getting

Get (86, 124)-(95, 137), tiles(0, 4) 'food tile getting

Get (52, 109)-(65, 121), tiles(0, 5) 'arrow tiles getting
Get (69, 109)-(81, 121), tiles(0, 6)
Get (86, 109)-(99, 121), tiles(0, 7)
Get (103, 109)-(116, 121), tiles(0, 8)

Get (86, 58)-(101, 71), tiles(0, 9) 'phantom prison door tiles getting
Get (69, 75)-(84, 90), tiles(0, 10)

Get (35, 75)-(50, 90), tiles(0, 11) 'first map tiles getting
Get (52, 92)-(67, 107), tiles(0, 12)
Get (1, 109)-(16, 122), tiles(0, 13)
Get (18, 109)-(33, 122), tiles(0, 14)
Get (1, 58)-(16, 71), tiles(0, 15)
Get (18, 58)-(33, 71), tiles(0, 16)
Get (35, 58)-(50, 71), tiles(0, 17)
Get (52, 58)-(67, 73), tiles(0, 18)
Get (1, 75)-(16, 90), tiles(0, 19)
Get (18, 75)-(33, 90), tiles(0, 20)
Get (52, 75)-(67, 90), tiles(0, 21)
Get (1, 92)-(16, 107), tiles(0, 22)
Get (18, 92)-(33, 107), tiles(0, 23)
Get (35, 92)-(50, 105), tiles(0, 24)
Get (35, 109)-(48, 122), tiles(0, 25)

Get (230, 18)-(245, 33), tiles(0, 26) 'second map tiles getting
Get (247, 35)-(262, 50), tiles(0, 27)
Get (196, 52)-(211, 65), tiles(0, 28)
Get (213, 52)-(228, 65), tiles(0, 29)
Get (196, 1)-(211, 14), tiles(0, 30)
Get (213, 1)-(228, 14), tiles(0, 31)
Get (230, 1)-(245, 14), tiles(0, 32)
Get (247, 1)-(262, 16), tiles(0, 33)
Get (196, 18)-(211, 33), tiles(0, 34)
Get (213, 18)-(228, 33), tiles(0, 35)
Get (247, 18)-(262, 33), tiles(0, 36)
Get (196, 35)-(211, 50), tiles(0, 37)
Get (213, 35)-(228, 50), tiles(0, 38)
Get (230, 35)-(245, 48), tiles(0, 39)
Get (230, 52)-(243, 65), tiles(0, 40)

Get (230, 84)-(245, 99), tiles(0, 41) 'third map tiles getting
Get (247, 101)-(262, 116), tiles(0, 42)
Get (196, 118)-(211, 131), tiles(0, 43)
Get (213, 118)-(228, 131), tiles(0, 44)
Get (196, 67)-(211, 80), tiles(0, 45)
Get (213, 67)-(228, 80), tiles(0, 46)
Get (230, 67)-(245, 80), tiles(0, 47)
Get (247, 67)-(262, 82), tiles(0, 48)
Get (196, 84)-(211, 99), tiles(0, 49)
Get (213, 84)-(228, 99), tiles(0, 50)
Get (247, 84)-(262, 99), tiles(0, 51)
Get (196, 101)-(211, 116), tiles(0, 52)
Get (213, 101)-(228, 116), tiles(0, 53)
Get (230, 101)-(245, 114), tiles(0, 54)
Get (230, 118)-(243, 131), tiles(0, 55)

Get (103, 58)-(118, 73), tiles(0, 56) 'common tiles getting
Get (103, 75)-(116, 90), tiles(0, 57)
Get (86, 92)-(101, 105), tiles(0, 58)
Get (103, 92)-(116, 105), tiles(0, 59)
Get (69, 58)-(84, 71), tiles(0, 60)
Get (86, 75)-(101, 90), tiles(0, 61)
Get (267, 101)-(282, 116), tiles(0, 62)
Get (284, 101)-(299, 116), tiles(0, 63)
Get (301, 101)-(316, 116), tiles(0, 64)

Get (196, 142)-(211, 155), door(0, 0) 'L door graphics getting
Get (212, 142)-(227, 155), door(0, 1)
Get (196, 156)-(211, 171), door(0, 2)
Get (212, 156)-(227, 171), door(0, 3)
Get (261, 142)-(276, 155), door(0, 4)
Get (277, 142)-(286, 155), door(0, 5)
Get (261, 156)-(276, 171), door(0, 6)
Get (277, 156)-(286, 171), door(0, 7)

Get (267, 118)-(279, 131), littledoor(0, 0)
Get (281, 118)-(293, 131), littledoor(0, 1)

Get (196, 133)-(203, 140), boxes(0, 0) 'window boxes graphics getting
Get (205, 133)-(212, 140), boxes(0, 1)
Get (214, 133)-(221, 140), boxes(0, 2)
Get (223, 133)-(230, 140), boxes(0, 3)
Get (232, 133)-(239, 140), boxes(0, 4)
Get (241, 133)-(248, 140), boxes(0, 5)
Get (250, 133)-(257, 140), boxes(0, 6)
Get (259, 133)-(266, 140), boxes(0, 7)
Get (268, 133)-(275, 140), boxes(0, 8)

Get (2, 124)-(8, 131), font(0, 0) 'font graphics getting
Get (10, 124)-(16, 131), font(0, 1)
Get (18, 124)-(24, 131), font(0, 2)
Get (26, 124)-(32, 131), font(0, 3)
Get (34, 124)-(40, 131), font(0, 4)
Get (42, 124)-(48, 131), font(0, 5)
Get (50, 124)-(56, 131), font(0, 6)
Get (58, 124)-(64, 131), font(0, 7)
Get (66, 124)-(72, 131), font(0, 8)
Get (74, 124)-(80, 131), font(0, 9)
Get (2, 133)-(9, 140), font(0, 10)
Get (10, 133)-(17, 140), font(0, 11)
Get (18, 133)-(25, 140), font(0, 12)
Get (26, 133)-(33, 140), font(0, 13)
Get (34, 133)-(41, 140), font(0, 14)
Get (42, 133)-(49, 140), font(0, 15)
Get (50, 133)-(57, 140), font(0, 16)
Get (58, 133)-(65, 140), font(0, 17)
Get (66, 133)-(73, 140), font(0, 18)
Get (74, 133)-(81, 140), font(0, 19)
Get (2, 142)-(9, 149), font(0, 20)
Get (10, 142)-(17, 149), font(0, 21)
Get (18, 142)-(25, 149), font(0, 22)
Get (26, 142)-(33, 149), font(0, 23)
Get (34, 142)-(41, 149), font(0, 36)
Get (42, 142)-(49, 149), font(0, 24)
Get (50, 142)-(57, 149), font(0, 25)
Get (58, 142)-(65, 149), font(0, 26)
Get (66, 142)-(73, 149), font(0, 27)
Get (74, 142)-(81, 149), font(0, 28)
Get (2, 151)-(9, 158), font(0, 29)
Get (10, 151)-(17, 158), font(0, 30)
Get (18, 151)-(25, 158), font(0, 31)
Get (26, 151)-(33, 158), font(0, 32)
Get (34, 151)-(41, 158), font(0, 33)
Get (42, 151)-(49, 158), font(0, 34)
Get (50, 151)-(57, 158), font(0, 35)
Get (58, 151)-(65, 158), font(0, 37)
Get (66, 151)-(73, 158), font(0, 38)
Get (74, 151)-(81, 158), font(0, 39)
Get (2, 160)-(9, 167), font(0, 40)
Get (10, 160)-(17, 167), font(0, 41)
Get (18, 160)-(25, 167), font(0, 42)
Get (26, 160)-(33, 167), font(0, 43)
Get (34, 160)-(41, 167), font(0, 44)
Get (42, 160)-(49, 167), font(0, 45)
Get (50, 160)-(57, 167), font(0, 46)
Get (58, 160)-(65, 167), font(0, 47)
Get (66, 160)-(73, 167), font(0, 48)
Get (74, 160)-(81, 167), font(0, 49)
Get (2, 169)-(9, 176), font(0, 50)
Get (10, 169)-(17, 176), font(0, 51)
Get (19, 169)-(26, 176), font(0, 52)

Get (40, 2)-(55, 17), pac(0, 0) 'good pac graphics getting
Get (21, 21)-(36, 36), pac(0, 1)
Get (2, 40)-(17, 55), pac(0, 2)
Get (21, 40)-(36, 55), pac(0, 3)

Get (158, 58)-(168, 65), pac(0, 4) 'bad pac graphics getting
Get (39, 1)-(47, 8), pac(0, 5) 'good pac graphics getting
Get (49, 1)-(49, 8), pac(0, 6) 'good pac graphics getting
Get (51, 1)-(51, 8), pac(0, 7) 'good pac graphics getting
Get (53, 1)-(53, 8), pac(0, 8) 'good pac graphics getting

Get (77, 1)-(86, 8), phantom(0, 0) 'bad phantom graphics getting
Get (116, 2)-(131, 17), phantom(0, 1)

Get (120, 153)-(129, 161), bug(0, 0) 'bug graphics getting
Get (139, 154)-(154, 169), bug(0, 1)
                                     
Get (59, 114)-(65, 120), arrows(0, 0) 'menu arrows graphics getting
Get (75, 114)-(81, 120), arrows(0, 1)
Get (93, 114)-(99, 120), arrows(0, 2)
Get (110, 114)-(116, 120), arrows(0, 3)

Get (267, 82)-(282, 97), blue() 'blue square
Get (289, 82)-(304, 97), red() 'red square

''''''''''''''

View

addlife = 0: phantoms = 0: bugs = 0: badpactime = 59
A = -1: b = -1: aghost = -1: bghost = -1
stagename$ = "": stagetext$ = ""

xmat = 0: ymat = 0: Erase map: ReDim map(34, 30) As Integer
seestock = 0: selection = 2: material = 0

''''''''''''''

Call WorkPaper

''''''''''''''

MouseRange 0, 0, 639, 199
Call MoveScreen
If changeicon Then MouseDriver 9, 7, 7, SAdd(MouseIcon$(0))
'MouseShow

''''''''''''''

'palette initialization

Palette 13, 8
Palette 15, 8
Palette 6, 2
Palette 9, 8
Palette 0, 2
Palette 3, 0
Palette 11, 2

''''''''''''''

Alert ("EDIMIX,THE MADMIX EDITOR      BETA VERSION      ")

Start:
MouseStatus Lb, Rb, xx, yy
'IF Lb = -1 THEN MouseHide: MousePut 412, MP - 4
Call MouseHide
If (Lb = -1 Or Rb = -1) And yy < 25 And yy > 6 And xx > 13 And xx < 626 Then
    If Choice(Int((xx - 14) / 34), Int(Lb)) = 1 Then
        GoSub Menu
    End If
    xx2 = xx: yy2 = yy
    Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0 And Rb = 0)
    MousePut xx2, yy2
End If
If Lb = -1 And yy < 195 And yy > 26 And xx > 13 And xx < 626 Then
    Call PutObject(Int((xx - 14) / 34), Int((yy - 27) / 17)): 'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Lb = 0)
End If
If Rb = -1 And yy < 195 And yy > 26 And xx > 13 And xx < 626 Then
    Call AIobject(Int((xx - 14) / 34), Int((yy - 27) / 17)): 'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Rb = 0)
End If
'IF Rb = -1 AND yy > 196 AND xx > 13 AND xx < 626 THEN CALL AIobject(INT((xx - 14) / 34), 9): 'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Rb = 0)
'IF Rb = -1 AND yy < 27 AND xx > 13 AND xx < 626 THEN CALL AIobject(INT((xx - 14) / 34), 0): 'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Rb = 0)
'IF Rb = -1 AND yy < 195 AND yy > 26 AND xx < 14 THEN CALL AIobject(0, INT((yy - 27) / 17)): 'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Rb = 0)
'IF Rb = -1 AND yy < 195 AND yy > 26 AND xx > 625 THEN CALL AIobject(17, INT((yy - 27) / 17)): 'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Rb = 0)
Select Case xx
    Case Is < 4
        border = 1
        xmat = xmat - 1: If xmat < -17 Then xmat = 14
        Select Case yy
            Case Is > 194
                If changeicon Then MouseDriver 9, 0, 15, SAdd(MouseIcon$(6))
                ymat = ymat + 1: If ymat > 20 Then ymat = 20
            Case Is < 4
                If changeicon Then MouseDriver 9, 0, 0, SAdd(MouseIcon$(5))
                ymat = ymat - 1: If ymat < 0 Then ymat = 0
            Case Else
                If changeicon Then MouseDriver 9, 0, 5, SAdd(MouseIcon$(3))
        End Select
        Call MoveScreen
    Case Is > 630
        border = 1
        xmat = xmat + 1: If xmat > 31 Then xmat = 0
        Select Case yy
            Case Is > 194
                If changeicon Then MouseDriver 9, 15, 15, SAdd(MouseIcon$(8))
                ymat = ymat + 1: If ymat > 20 Then ymat = 20
            Case Is < 4
                If changeicon Then MouseDriver 9, 15, 0, SAdd(MouseIcon$(7))
                ymat = ymat - 1: If ymat < 0 Then ymat = 0
            Case Else
                If changeicon Then MouseDriver 9, 15, 5, SAdd(MouseIcon$(4))
        End Select
        Call MoveScreen
    Case Else
        Select Case yy
            Case Is < 4
                border = 1
                If changeicon Then MouseDriver 9, 5, 0, SAdd(MouseIcon$(1))
                ymat = ymat - 1: If ymat < 0 Then ymat = 0 Else Call MoveScreen
            Case Is > 194
                border = 1
                If changeicon Then MouseDriver 9, 5, 15, SAdd(MouseIcon$(2))
                ymat = ymat + 1: If ymat > 20 Then ymat = 20 Else Call MoveScreen
            Case Else
                If border And changeicon Then MouseDriver 9, 7, 7, SAdd(MouseIcon$(0)): border = 0
        End Select
End Select
Call MouseShow
PCopy 0, 1
GoTo Start

Menu:
xx2 = xx: yy2 = yy
Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0)
MousePut xx2, yy2
Call MenuShow
Call MouseShow
Do
    MouseStatus Lb, Rb, xx, yy
    Call MouseHide
    If Lb = -1 And yy > 50 And yy < 69 And xx > 401 And xx < 437 Then
        TIMERbefore = Timer
        Put (202, 52), blue()
        Call MouseShow: PCopy 0, 1: Call MouseHide
        xx2 = xx: yy2 = yy
        Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0)
        MousePut xx2, yy2: xx = xx2: yy = yy2
        Put (96, 48), noerase(), PSet
        Do: Loop Until Timer > TIMERbefore
        Return
    End If
    If Lb = -1 And yy > 69 And yy < 171 And xx > 201 And xx < 437 Then
        TIMERbefore = Timer
        Put (101, (Int((yy - 69) / 17)) * 17 + 70), resopt()
        Call MouseShow: PCopy 0, 1: Call MouseHide
        xx2 = xx: yy2 = yy
        Put (101, (Int((yy - 69) / 17)) * 17 + 70), resopt()
        Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0)
        MousePut xx2, yy2
        Do: Loop Until Timer > TIMERbefore
        Call MenuOpt(Int((yy2 - 69) / 17))
    End If
    If Rb = -1 Then
        changeicon = 1 - changeicon
        If changeicon Then MouseDriver 9, 7, 7, SAdd(MouseIcon$(0)) Else xx2 = xx: yy2 = yy: MouseDriver 0, 7, 7, SAdd(Mouse$): MousePut xx2, yy2
        Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Rb = 0)
    End If
    Call MouseShow
    PCopy 0, 1
Loop

errortrapping:
Close
Select Case Err
    Case Else:
        Alert ("ERROR" + Str$(Err) + ":CANNOT CONTINUE")
        Screen 0: Width 80: Cls
        End
End Select

Rem $DYNAMIC
Sub Alert (txt$)
    Dim acceptcancel(400)
    Dim xx As Integer, yy As Integer
    Dim xx2 As Integer, yy2 As Integer
    Dim Lb As Integer, Rb As Integer
    'PCOPY 1, 0
    txtlen = Len(txt$)
    If txtlen > 24 Then midwidth = 12 Else midwidth = txtlen / 2
    ViewWindow 19 - midwidth, 11, 21 + midwidth, 17 + Int(txtlen / 25)
    Line (117, 119 + Int(txtlen / 25) * 8)-(204, 136 + Int(txtlen / 25) * 8), 8, B
    Get (117, 119 + Int(txtlen / 25) * 8)-(204, 136 + Int(txtlen / 25) * 8), acceptcancel()
    ViewText 129, 124 + Int(txtlen / 25) * 8, "ACCEPT"
    For F = 0 To Int(txtlen / 24)
        ViewText 156 - midwidth * 8, 104 + F * 9, Mid$(txt$, F * 24 + 1, 24)
    Next F
    Do: Loop Until InKey$ = "" 'clears keyboard buffer
    While LookForKey$ <> Chr$(13) And LookForKey$ <> Chr$(27)
        LookForKey$ = UCase$(InKey$)
        MouseStatus Lb, Rb, xx, yy
        If Lb = -1 And yy > (118 + Int(txtlen / 25) * 8) And yy < (137 + Int(txtlen / 25) * 8) And xx > 232 And xx < 410 Then
            Put (117, 119 + Int(txtlen / 25) * 8), acceptcancel()
            Call MouseShow: PCopy 0, 1: Call MouseHide
            xx2 = xx: yy2 = yy
            Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0)
            MousePut xx2, yy2
            TIMERbefore = Timer: Do: Loop Until Timer > TIMERbefore
            LookForKey$ = Chr$(13)
        End If
        Call MouseShow: PCopy 0, 1: Call MouseHide
    Wend
    Call MoveScreen: Call MouseShow
End Sub

Rem $STATIC
Function Choice (region, Lbyn)
    Choice = 0
    TIMERbefore = Timer
    View
    If Lbyn Then
        Select Case region
            Case 15, 16
                badpactime = badpactime + 10: If badpactime > 499 Then badpactime = 59
                Line (263, 8)-(286, 15), 0, BF
                ViewText 256, 8, Right$(Str$(badpactime), Len(Str$(badpactime)) - 1)
                Put (15 * 17 + 8, 8), blue(): Put (16 * 17 + 8, 8), blue(): shut = 2
            Case 12
                addlife = addlife + 1: If addlife > 20 Then addlife = 0
                Line (263 - 17 * 3, 8)-(278 - 17 * 3, 15), 0, BF
                ViewText 205, 8, Right$(Str$(addlife), Len(Str$(addlife)) - 1)
                Put (region * 17 + 8, 8), blue(): shut = 1
            Case 14
                bugs = bugs + 1: If phantoms + bugs > 20 Or aghost = -1 Then bugs = 0
                Line (263 - 17 * 1, 8)-(278 - 17 * 1, 15), 0, BF
                ViewText 239, 8, Right$(Str$(bugs), Len(Str$(bugs)) - 1)
                Put (region * 17 + 8, 8), blue(): shut = 1
            Case 17
                Put (region * 17 + 8, 8), blue(): Choice = 1: shut = 1 'EXIT FUNCTION
            Case 13
                phantoms = phantoms + 1: If phantoms + bugs > 20 Or aghost = -1 Then phantoms = 0
                Line (263 - 17 * 2, 8)-(278 - 17 * 2, 15), 0, BF
                ViewText 222, 8, Right$(Str$(phantoms), Len(Str$(phantoms)) - 1)
                Put (region * 17 + 8, 8), blue(): shut = 1
            Case 11
                seestock = seestock + 1: If seestock > 69 Then seestock = 0
                For stock = 3 To 11
                    Line (stock * 17 - 9, 8)-(stock * 17 - 9 + 15, 8 + 15), 0, BF
                    takethis = Repeat(stock + seestock)
                    Select Case takethis
                        Case 65 'CASE 62
                            Put (stock * 17 - 9, 8), pac(0, 0), PSet
                        Case 66 'CASE 63
                            Put (stock * 17 - 9, 8), pac(0, 1), PSet
                        Case 67 'CASE 64
                            Put (stock * 17 - 9, 8), pac(0, 2), PSet
                        Case 68 'CASE 65
                            Put (stock * 17 - 9, 8), pac(0, 3), PSet
                        Case 69 'CASE 66
                            Put (stock * 17 - 9, 8), phantom(0, 1), PSet
                        Case 70 'CASE 67
                            Put (stock * 17 - 3, 16), phantom(0, 0)
                            Put (stock * 17 - 13, 5), tiles(0, 4)
                        Case 71
                            Put (stock * 17 - 8, 9), littledoor(0, 0)
                        Case 72
                            Put (stock * 17 - 7, 9), littledoor(0, 1)
                        Case Else
                            Put (stock * 17 - 9, 8), tiles(0, takethis), PSet
                    End Select
                Next stock
                Put (region * 17 + 8, 8), blue(): shut = 1
                If Repeat(selection - seestock + 1) - 1 < 11 And Repeat(selection - seestock + 1) - 1 > 1 And selection > -1 Then Put ((Repeat(selection - seestock + 1) - 1) * 17 + 8, 8), red()
            Case 1
                seestock = seestock - 1: If seestock < -8 Then seestock = 61
                For stock = 3 To 11
                    Line (stock * 17 - 9, 8)-(stock * 17 - 9 + 15, 8 + 15), 0, BF
                    takethis = Repeat(stock + seestock)
                    Select Case takethis
                        Case 65 'CASE 62
                            Put (stock * 17 - 9, 8), pac(0, 0), PSet
                        Case 66 'CASE 63
                            Put (stock * 17 - 9, 8), pac(0, 1), PSet
                        Case 67 'CASE 64
                            Put (stock * 17 - 9, 8), pac(0, 2), PSet
                        Case 68 'CASE 65
                            Put (stock * 17 - 9, 8), pac(0, 3), PSet
                        Case 69 'CASE 66
                            Put (stock * 17 - 9, 8), phantom(0, 1), PSet
                        Case 70 'CASE 67
                            Put (stock * 17 - 3, 16), phantom(0, 0)
                            Put (stock * 17 - 13, 5), tiles(0, 4)
                        Case 71
                            Put (stock * 17 - 8, 9), littledoor(0, 0)
                        Case 72
                            Put (stock * 17 - 7, 9), littledoor(0, 1)
                        Case Else
                            Put (stock * 17 - 9, 8), tiles(0, takethis), PSet
                    End Select
                Next stock
                Put (region * 17 + 8, 8), blue(): shut = 1
                If Repeat(selection - seestock + 1) - 1 < 11 And Repeat(selection - seestock + 1) - 1 > 1 And selection > -1 Then Put ((Repeat(selection - seestock + 1) - 1) * 17 + 8, 8), red()
            Case 0
                If selection > -1 Then
                    If Repeat(selection - seestock + 1) - 1 < 11 And Repeat(selection - seestock + 1) - 1 > 1 And selection > -1 Then Put ((Repeat(selection - seestock + 1) - 1) * 17 + 8, 8), red()
                    Put (8, 8), blue(): selection = -1 ': material = 0
                End If
            Case Is < 11 ''''''''''''''''
                If Repeat(selection - seestock + 1) - 1 < 11 And Repeat(selection - seestock + 1) - 1 > 1 And selection > -1 Then Put ((Repeat(selection - seestock + 1) - 1) * 17 + 8, 8), red()
                If selection = -1 Then Put (8, 8), blue()
                Put (region * 17 + 8, 8), red()
                selection = Repeat(region + seestock + 1) - 1
                Select Case selection
                    Case 61: material = 0
                    Case 62: material = 15
                    Case 63: material = 30
                    Case Else:
                        If selection < 55 And Int((selection - 10) / 15) * 15 >= 0 Then material = Int((selection - 10) / 15) * 15
                        'IF selection > 54 OR material < 0 THEN material = 0
                End Select
        End Select
    Else
        Select Case region
            Case 15, 16
                badpactime = badpactime - 10: If badpactime < 59 Then badpactime = 499
                Line (263, 8)-(286, 15), 0, BF
                ViewText 256, 8, Right$(Str$(badpactime), Len(Str$(badpactime)) - 1)
                Put (15 * 17 + 8, 8), blue(): Put (16 * 17 + 8, 8), blue(): shut = 2
            Case 12
                addlife = addlife - 1: If addlife < 0 Then addlife = 20
                Line (263 - 17 * 3, 8)-(278 - 17 * 3, 15), 0, BF
                ViewText 205, 8, Right$(Str$(addlife), Len(Str$(addlife)) - 1)
                Put (region * 17 + 8, 8), blue(): shut = 1
            Case 14
                If aghost > -1 Then
                    bugs = bugs - 1
                    If bugs < 0 Then bugs = 20 - phantoms
                End If
                Line (263 - 17 * 1, 8)-(278 - 17 * 1, 15), 0, BF
                ViewText 239, 8, Right$(Str$(bugs), Len(Str$(bugs)) - 1)
                Put (region * 17 + 8, 8), blue(): shut = 1
            Case 13
                If aghost > -1 Then
                    phantoms = phantoms - 1
                    If phantoms < 0 Then phantoms = 20 - bugs
                End If
                Line (263 - 17 * 2, 8)-(278 - 17 * 2, 15), 0, BF
                ViewText 222, 8, Right$(Str$(phantoms), Len(Str$(phantoms)) - 1)
                Put (region * 17 + 8, 8), blue(): shut = 1
        End Select
    End If
    Call MouseShow: PCopy 0, 1: Call MouseHide
    Select Case shut
        Case 1: Put (region * 17 + 8, 8), blue()
        Case 2: Put (15 * 17 + 8, 8), blue(): Put (16 * 17 + 8, 8), blue()
    End Select
    View Screen(6, 26)-(314, 198)
    Do: Loop Until Timer > TIMERbefore
End Function

Rem $DYNAMIC
Sub EraseDoorAround (numx, numy, regionx, regiony, remind)
    Select Case map(regionx + xmat + remind + numx + 1, regiony + ymat + numy)
        Case 99, -5:
                IF regionx + numx < 18 THEN LINE ((regionx + numx + 1) * 17 + 8, (regiony + numy) * 17 + 28)-((regionx + numx + 1) * 17 + 8 + 15, (regiony + numy) * 17 + 28 + 15), 0, BF: LINE ((regionx + numx) * 17 + 8, (regiony + numy) * 17 + 28)-( _
(regionx + numx) * 17 + 8 + 15, (regiony + numy) * 17 + 28 + 15), 0, BF
            If regionx + numx < 17 And regiony + numy > 0 And map(regionx + xmat + remind + 1 + numx, regiony + ymat + numy) = 99 Then Put ((regionx + numx + 1) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 5)
            If regiony + numy > 0 And regionx + numx < 17 And map(regionx + xmat + remind + 1 + numx, regiony + ymat + numy) = 99 Then Put ((regionx + numx) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 4)
            If regionx + numx < 18 And regiony + numy > 0 And map(regionx + xmat + remind + numx + 1, regiony + ymat + numy) = -5 Then Put ((regionx + numx + 1) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 1)
            If regiony + numy > 0 And map(regionx + xmat + remind + numx + 1, regiony + ymat + numy) = -5 Then Put ((regionx + numx) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 0)
            map(regionx + xmat + remind + 1 + numx, regiony + ymat + numy) = 0
            Select Case (regionx + xmat + remind + 1 + numx)
                Case 33: map(1, regiony + ymat + numy) = 0: map(2, regiony + ymat + numy) = 0
                Case 1: map(33, regiony + ymat + numy) = 0: map(2, regiony + ymat + numy) = 0
                Case 32: map(0, regiony + ymat + numy) = 0: map(33, regiony + ymat + numy) = 0: map(1, regiony + ymat + numy) = 0
                Case 31: map(32, regiony + ymat + numy) = 0: map(0, regiony + ymat + numy) = 0
                Case Else: map(regionx + xmat + remind + 1 + numx + 1, regiony + ymat + numy) = 0
            End Select
        Case 98, -6:
                IF regionx + numx > -1 THEN LINE ((regionx + numx - 1) * 17 + 8, (regiony + numy) * 17 + 28)-((regionx + numx - 1) * 17 + 8 + 15, (regiony + numy) * 17 + 28 + 15), 0, BF: LINE ((regionx + numx) * 17 + 8, (regiony + numy) * 17 + 28)-( _
(regionx + numx) * 17 + 8 + 15, (regiony + numy) * 17 + 28 + 15), 0, BF
            If regionx + numx > -1 And regiony + numy > 0 And map(regionx + xmat + remind + numx + 1, regiony + ymat + numy) = -6 Then Put ((regionx + numx - 1) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 4)
            If regiony + numy > 0 And map(regionx + xmat + remind + numx + 1, regiony + ymat + numy) = -6 Then Put ((regionx + numx) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 5)
            If regionx + numx > 0 And regiony + numy > 0 And map(regionx + xmat + remind + numx + 1, regiony + ymat + numy) = 98 Then Put ((regionx + numx - 1) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 0)
            If regiony + numy > 0 And regionx + numx > 0 And map(regionx + xmat + remind + numx + 1, regiony + ymat + numy) = 98 Then Put ((regionx + numx) * 17 + 8, (regiony + numy - 1) * 17 + 30), door(0, 1)
            map(regionx + xmat + remind + 1 + numx, regiony + ymat + numy) = 0
            Select Case (regionx + xmat + remind + 1 + numx)
                Case 0: map(32, regiony + ymat + numy) = 0: map(31, regiony + ymat + numy) = 0
                Case 1: map(33, regiony + ymat + numy) = 0: map(0, regiony + ymat + numy) = 0: map(32, regiony + ymat + numy) = 0
                Case 32: map(0, regiony + ymat + numy) = 0: map(31, regiony + ymat + numy) = 0
                Case 2: map(1, regiony + ymat + numy) = 0: map(33, regiony + ymat + numy) = 0
                Case Else: map(regionx + xmat + remind + 1 + numx - 1, regiony + ymat + numy) = 0
            End Select
    End Select
End Sub

Function FileBrowser$ (txt$, txtmax, before$)
    Dim acceptcancel(400)
    Dim xx As Integer, yy As Integer
    Dim xx2 As Integer, yy2 As Integer
    Dim Lb As Integer, Rb As Integer
    ViewWindow 7, 10, 32, 16
    Line (71, 111)-(158, 128), 8, B: Line (161, 111)-(248, 128), 8, B
    Get (71, 111)-(158, 128), acceptcancel()
    ViewText 83, 116, "ACCEPT": ViewText 173, 116, "CANCEL"
    ViewText 64, 96, txt$
    ViewText 64, 86, before$
    Do: Loop Until InKey$ = "" 'clears keyboard buffer
    While LookForKey$ <> Chr$(13) And LookForKey$ <> Chr$(27)
        Do
            MouseStatus Lb, Rb, xx, yy
            LookForKey$ = UCase$(InKey$)
            If Lb = -1 And yy > 110 And yy < 129 And xx > 141 And xx < 317 Then
                Put (71, 111), acceptcancel()
                Call MouseShow: PCopy 0, 1: Call MouseHide
                xx2 = xx: yy2 = yy
                Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0)
                MousePut xx2, yy2
                TIMERbefore = Timer: Do: Loop Until Timer > TIMERbefore
                LookForKey$ = Chr$(13)
            End If
            If Lb = -1 And yy > 110 And yy < 129 And xx > 321 And xx < 497 Then
                Put (161, 111), acceptcancel()
                Call MouseShow: PCopy 0, 1: Call MouseHide
                xx2 = xx: yy2 = yy
                Do: MouseStatus Lb, Rb, xx, yy: Loop Until (Lb = 0)
                MousePut xx2, yy2
                TIMERbefore = Timer: Do: Loop Until Timer > TIMERbefore
                LookForKey$ = Chr$(27)
            End If
            Call MouseShow: PCopy 0, 1: Call MouseHide
        Loop While ((Len(txtwrote$) = 0 And LookForKey$ = Chr$(8)) Or LookForKey$ = "")
        Select Case Asc(LookForKey$)
            Case 8:
                txtwrote$ = Left$(txtwrote$, Len(txtwrote$) - 1)
                ViewText 143, 96, Right$(txtwrote$, 12) + Right$(txt$, 1) + Chr$(32)
            Case 13:
                FileBrowser$ = txtwrote$
            Case 27:
                FileBrowser$ = Chr$(27)
            Case Is <> 13:
                Select Case Len(txtwrote$)
                    Case Is >= txtmax
                    Case Is < 12:
                        txtwrote$ = txtwrote$ + LookForKey$
                        ViewText 143, 96, Right$(txtwrote$, Len(txtwrote$)) + Right$(txt$, 1) + Chr$(32)
                    Case Is < txtmax:
                        txtwrote$ = txtwrote$ + LookForKey$
                        ViewText 143, 96, Right$(txtwrote$, 12) + Right$(txt$, 1) + Chr$(32)
                End Select
        End Select
    Wend
End Function

Sub LoadMap (file$)
    Open file$ For Input As #1
    Input #1, maxlev
    Input #1, stagename$, stagetext$
    Input #1, addlife, phantoms, bugs, badpactime
    For ydatabase = 0 To 29
        For xdatabase = 0 To 33
            Input #1, map(xdatabase, ydatabase)
            Select Case map(xdatabase, ydatabase)
                'Phantoms Start Over Point
                Case -8: aghost = xdatabase: bghost = ydatabase
                    'Phantom Variables Initialization
                Case 2: aghost = xdatabase: bghost = ydatabase
                    'Pac Variables Initialization
                Case -1, -2, -3, -4: A = xdatabase: b = ydatabase
                    'Phantom Prison Door /*
                    'CASE 10: xprison = xdatabase: yprison = ydatabase': prisons = prisons + 1
            End Select
        Next xdatabase
    Next ydatabase
    Close #1
End Sub

Sub LoadPcx (txt$)
    Dim h As TH
    Dim dat As String * 1
    Open txt$ For Binary As #1
    Get #1, 1, h
    C = 1
    y = 0: x = 0
    While C <= 64000
        Get #1, , dat
        If Asc(dat) > 192 And Asc(dat) <= 255 Then
            LPS = Asc(dat) - 192
            Get #1, , dat
            value = Asc(dat)
            While LPS > 0
                PSet (x, y), ega(value - 241)
                If x = 320 Then x = 1: y = y + 1 Else x = x + 1
                C = C + 1
                LPS = LPS - 1
            Wend
        Else
            value = Asc(dat)
            PSet (x, y), value
            If x = 320 Then x = 1: y = y + 1 Else x = x + 1
            C = C + 1
        End If
    Wend
    Close #1
End Sub

Sub MenuOpt (region)
    Dim noerasemenu(1500)
    Get (56, 80)-(263, 135), noerasemenu()
    Select Case region
        Case 0
            'IF Alert$("ARE YOU SURE?") = "Y" THEN
            addlife = 0: phantoms = 0: bugs = 0: badpactime = 59
            A = -1: b = -1: aghost = -1: bghost = -1
            stagename$ = "": stagetext$ = ""
            xmat = 0: ymat = 0: Erase map: ReDim map(34, 30) As Integer
            seestock = 0: selection = 2: material = 0
            Call WorkPaper: Call MoveScreen: Call MenuShow
            Exit Sub
            'END IF
        Case 1
            answer$ = FileBrowser$("OPEN FILE:�", 40, "")
            If answer$ <> "" And answer$ <> Chr$(27) Then
                A = -1: b = -1: aghost = -1: bghost = -1
                xmat = 0: ymat = 0: Erase map: ReDim map(34, 30) As Integer
                seestock = 0: selection = 2: material = 0
                LoadMap answer$
                Call WorkPaper: Call MoveScreen: Call MenuShow
                Exit Sub
            Else
                Put (56, 80), noerasemenu(), PSet
            End If
        Case 2
            answer$ = FileBrowser$("SAVE FILE:�", 40, "")
            If answer$ <> "" And answer$ <> Chr$(27) Then SaveMap answer$
            Put (56, 80), noerasemenu(), PSet
        Case 3
            answer$ = FileBrowser$("FRST TEXT:�", 20, stagename$)
            If answer$ <> Chr$(27) Then stagename$ = answer$
            Put (56, 80), noerasemenu(), PSet
        Case 4
            answer$ = FileBrowser$("SCND TEXT:�", 20, stagetext$)
            If answer$ <> Chr$(27) Then stagetext$ = answer$
            Put (56, 80), noerasemenu(), PSet
        Case 5
            Screen 0: Width 80: Cls
            Print "FOR MORE FUN VISIT MY OWN PAGE HTTP://WWW11.BRINKSTER.COM/FREESOURCE"
            End
    End Select
End Sub

Sub MenuShow
    Get (96, 48)-(223, 175), noerase()
    ViewWindow 12, 6, 27, 21 'LINE (100, 50)-(219, 173), 7, BF
    Line (201, 51)-(218, 68), 8, B: Put (207, 56), arrows(0, 2)
    For squares = 0 To 5
        Line (101, 70 + squares * 17)-(218, 87 + squares * 17), 8, B
    Next squares
    Get (101, 70)-(218, 87), resopt()
    ViewText 124, 55, "OPTIONS"
    ViewText 124, 75, "NEW MAP"
    ViewText 120, 92, "OPEN MAP"
    ViewText 120, 109, "SAVE MAP"
    ViewText 112, 126, "FIRST TEXT"
    ViewText 108, 143, "SECOND TEXT"
    ViewText 108, 160, "EXIT EDITOR"
    'DO: MouseStatus Lb, Rb, xx, yy: LOOP UNTIL (Lb = 0)
    'PUT (297, 8), blue
    'VIEW SCREEN (6, 26)-(314, 198)
End Sub

DefLng A-Z
Sub MouseDriver (ax%, bx%, cx%, dx%)
    Def Seg = VarSeg(Mouse$)
    Mouse% = SAdd(Mouse$)
    Call Absolute(ax%, bx%, cx%, dx%, Mouse%)
End Sub

Sub MouseHide
    ax% = 2
    MouseDriver ax%, 0, 0, 0
End Sub

Function MouseInit%
    ax% = 0
    MouseDriver ax%, 0, 0, 0
    MouseInit% = ax%
End Function

Sub MousePut (x%, y%)
    ax% = 4
    cx% = x%
    dx% = y%
    MouseDriver ax%, 0, cx%, dx%
End Sub

Sub MouseRange (x1%, y1%, x2%, y2%)
    ax% = 7
    cx% = x1%
    dx% = x2%
    MouseDriver ax%, 0, cx%, dx%
    ax% = 8
    cx% = y1%
    dx% = y2%
    MouseDriver ax%, 0, cx%, dx%
End Sub

Sub MouseShow
    ax% = 1
    MouseDriver ax%, 0, 0, 0
End Sub

Sub MouseStatus (Lb%, Rb%, xMouse%, yMouse%)
    ax% = 3
    MouseDriver ax%, bx%, cx%, dx%
    Lb% = ((bx% And 1) <> 0)
    Rb% = ((bx% And 2) <> 0)
    xMouse% = cx%
    yMouse% = dx%
End Sub

DefSng A-Z
Sub MoveScreen

    TIMERbefore = Timer

    Cls

    For sx = 7 To 314 Step 17
        Line (sx, 27)-(sx, 197), 7, , &HAAAA
    Next sx

    For sy = 27 To 197 Step 17
        Line (7, sy)-(314, sy), 7, , &HAAAA
    Next sy

    For xmap = xmat To 17 + xmat
        If xmap = 0 Then Line ((17 - ((17 + xmat) - xmap)) * 17 + 7, 27)-((17 - ((17 + xmat) - xmap)) * 17 + 7, 197), 4, , &HAAAA
        If xmap = 31 Then Line ((17 - ((17 + xmat) - xmap)) * 17 + 24, 27)-((17 - ((17 + xmat) - xmap)) * 17 + 24, 197), 4, , &HAAAA
        Select Case xmap
            Case Is > 31: remind = -32
            Case Is < 0: remind = 32
            Case Else: remind = 0
        End Select
        For ymap = ymat To 9 + ymat
            If ymap = 4 Then Line (7, (9 - ((9 + ymat) - ymap)) * 17 + 27)-(313, (9 - ((9 + ymat) - ymap)) * 17 + 27), 4, , &HAAAA
            If ymap = 25 Then Line (7, (9 - ((9 + ymat) - ymap)) * 17 + 44)-(313, (9 - ((9 + ymat) - ymap)) * 17 + 44), 4, , &HAAAA
            Select Case map(xmap + remind + 1, ymap)
                Case -5
                    If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 0)
                    If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 2), PSet
                Case 98
                    If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 1)
                    If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 3), PSet
                Case 99
                    If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 4)
                    If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 6), PSet
                Case -6
                    If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 5)
                    If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 7), PSet
                Case 2
                    Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), phantom(0, 1)
                Case -8
                    Put (xmap * 17 + 14 - xmat * 17, ymap * 17 + 36 - ymat * 17), phantom(0, 0)
                    Put (xmap * 17 + 4 - xmat * 17, ymap * 17 + 25 - ymat * 17), tiles(0, 4)
                Case -1
                    Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), pac(0, 0)
                Case -2
                    Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), pac(0, 3)
                Case -3
                    Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), pac(0, 1)
                Case -4
                    Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), pac(0, 2)
                Case Is > 2
                    Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), tiles(0, map(xmap + remind + 1, ymap))
            End Select
        Next ymap
        Select Case map(xmap + remind + 1, ymap)
            Case -5
                If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 0)
                If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 2), PSet
            Case 98
                If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 1)
                If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 3), PSet
            Case 99
                If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 4)
                If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 6), PSet
            Case -6
                If ymap > ymat Then Put (xmap * 17 + 8 - xmat * 17, (ymap - 1) * 17 + 28 - ymat * 17 + 2), door(0, 5)
                If ymap < 10 + ymat Then Put (xmap * 17 + 8 - xmat * 17, ymap * 17 + 28 - ymat * 17), door(0, 7), PSet
        End Select
    Next xmap
    Do: Loop Until Timer > TIMERbefore
End Sub

Function MyFormat$ (txt$)
    If Left$(txt$, 1) = "-" Then MyFormat$ = txt$: Exit Function
    If Len(txt$) = 2 Then MyFormat$ = "0" + Right$(txt$, Len(txt$) - 1) Else MyFormat$ = Right$(txt$, Len(txt$) - 1)
End Function

Function Repeat (til)
    Select Case til
        Case Is < 3: Repeat = 70 + til
        Case Is > 72: Repeat = til - 70
        Case Else: Repeat = til
    End Select
End Function

Sub SaveMap (file$)
    Open file$ For Output As #2
    Print #2, Right$(Str$(1), 1)
    Print #2, stagename$
    Print #2, stagetext$
    Print #2, MyFormat$(Str$(addlife)) + "," + MyFormat$(Str$(phantoms)) + "," + MyFormat$(Str$(bugs)) + "," + MyFormat$(Str$(badpactime))
    For ydatabase = 0 To 29
        For xdatabase = 0 To 33
            If xdatabase = 33 Then coma$ = "" Else coma$ = ","
            Print #2, MyFormat$(Str$(map(xdatabase, ydatabase))) + coma$;
        Next xdatabase
        If ydatabase < 29 Then Print #2,
    Next ydatabase
    Close #2
End Sub

Sub ViewText (x, y, txt$)
    For stepbystep = 1 To Len(txt$)
        Put (x + stepbystep * 8, y), font(0, chrcodes(Asc(Mid$(txt$, stepbystep, 1)))), PSet
    Next stepbystep
End Sub

Sub ViewWindow (fromx, fromy, tox, toy)
    For y = fromy To toy
        For x = fromx To tox
            If x = fromx And y = fromy Then Put (x * 8, y * 8), boxes(0, 2), PSet: GoTo nextfor
            If x = tox And y = fromy Then Put (x * 8, y * 8), boxes(0, 3), PSet: GoTo nextfor
            If x = fromx And y = toy Then Put (x * 8, y * 8), boxes(0, 0), PSet: GoTo nextfor
            If x = tox And y = toy Then Put (x * 8, y * 8), boxes(0, 1), PSet: GoTo nextfor
            If x = fromx Then Put (x * 8, y * 8), boxes(0, 4), PSet: GoTo nextfor
            If x = tox Then Put (x * 8, y * 8), boxes(0, 5), PSet: GoTo nextfor
            If y = fromy Then Put (x * 8, y * 8), boxes(0, 6), PSet: GoTo nextfor
            If y = toy Then Put (x * 8, y * 8), boxes(0, 7), PSet: GoTo nextfor
            Put (x * 8, y * 8), boxes(0, 8), PSet
            nextfor:
        Next x
    Next y
End Sub

Sub WorkPaper
    View: Cls
    For squares = 0 To 18
        Line (7, 7)-(squares * 17 + 7, 24), 8, B
    Next squares
    Paint (29, 12), 7, 8: Paint (199, 12), 7, 8
    Put (29, 12), arrows(0, 1): Put (199, 12), arrows(0, 0)
    Paint (301, 12), 7, 8: Put (301, 12), arrows(0, 3)
    Put (235, 16), phantom(0, 0): Put (252, 15), bug(0, 0)
    ViewText 205, 8, Right$(Str$(addlife), Len(Str$(addlife)) - 1)
    ViewText 204, 16, "*&": Line (263, 8)-(295, 23), 0, BF
    Put (285, 16), pac(0, 4): Put (270, 16), pac(0, 5)
    Put (280, 16), pac(0, 6): Put (282, 16), pac(0, 7): Put (284, 16), pac(0, 8)
    ViewText 256, 8, Right$(Str$(badpactime), Len(Str$(badpactime)) - 1)
    Paint (10, 10), Chr$(&HAA) + Chr$(&HAA) + Chr$(&HAA) + Chr$(&HA) + Chr$(&H55) + Chr$(&H55) + Chr$(&H55) + Chr$(&H5), 8
    ViewText 222, 8, Right$(Str$(phantoms), Len(Str$(phantoms)) - 1)
    ViewText 239, 8, Right$(Str$(bugs), Len(Str$(bugs)) - 1)
    For stock = 3 To 11
        Put (stock * 17 - 9, 8), tiles(0, stock)
    Next stock
    Paint (0, 0), 3, 8
    Put (selection * 17 + 8, 8), red()
    View Screen(6, 26)-(314, 198)
End Sub

Sub AIobject (regionx, regiony)
    Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
    Select Case regionx + xmat
        Case Is > 31: remind = -32
        Case Is < 0: remind = 32
        Case Else: remind = 0
    End Select
    If regionx + xmat + remind + 1 = A And regiony + ymat = b Then A = -1: b = -1
    If regionx + xmat + remind + 1 = aghost And regiony + ymat = bghost Then
        aghost = -1: bghost = -1: phantoms = 0: bugs = 0
        View
        Line (263 - 17 * 2, 8)-(278 - 17 * 2, 15), 0, BF
        ViewText 222, 8, Right$(Str$(phantoms), Len(Str$(phantoms)) - 1)
        Line (263 - 17 * 1, 8)-(278 - 17 * 1, 15), 0, BF
        ViewText 239, 8, Right$(Str$(bugs), Len(Str$(bugs)) - 1)
        View Screen(6, 26)-(314, 198)
    End If
    If (regiony + ymat - 1) > -1 Then
                IF map(regionx + xmat + remind + 1, regiony + ymat - 1) > 10 + material AND map(regionx + xmat + remind + 1, regiony + ymat - 1) < 26 + material OR map(regionx + xmat + remind + 1, regiony + ymat - 1) = 62 + material / 15 THEN Around _
 = Around + 1
    End If
    If (regiony + ymat + 1) < 30 Then
                IF map(regionx + xmat + remind + 1, regiony + ymat + 1) > 10 + material AND map(regionx + xmat + remind + 1, regiony + ymat + 1) < 26 + material OR map(regionx + xmat + remind + 1, regiony + ymat + 1) = 62 + material / 15 THEN Around _
 = Around + 2
    End If
        IF map(regionx + xmat + remind + 1 - 1, regiony + ymat) > 10 + material AND map(regionx + xmat + remind + 1 - 1, regiony + ymat) < 26 + material OR map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 62 + material / 15 THEN Around =  _
Around + 4
        IF map(regionx + xmat + remind + 1 + 1, regiony + ymat) > 10 + material AND map(regionx + xmat + remind + 1 + 1, regiony + ymat) < 26 + material OR map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 62 + material / 15 THEN Around =  _
Around + 8
    Select Case map(regionx + xmat + remind + 1, regiony + ymat)
        Case 99, -5:
            If regionx < 17 Then Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            If regionx < 17 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 99 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 99 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
            If regionx < 17 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -5 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -5 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat) = 0: map(2, regiony + ymat) = 0
                Case 32: map(0, regiony + ymat) = 0: map(33, regiony + ymat) = 0: map(1, regiony + ymat) = 0
                Case 31: map(32, regiony + ymat) = 0: map(0, regiony + ymat) = 0
                Case Else: map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 0
            End Select
        Case -6, 98:
            If regionx > 0 Then Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            If regionx > 0 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -6 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -6 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
            If regionx > 0 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 98 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 98 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat) = 0: map(0, regiony + ymat) = 0: map(32, regiony + ymat) = 0
                Case 32: map(0, regiony + ymat) = 0: map(31, regiony + ymat) = 0
                Case 2: map(1, regiony + ymat) = 0: map(33, regiony + ymat) = 0
                Case Else: map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 0
            End Select
    End Select
    Select Case Around
        Case 0
            map(regionx + xmat + remind + 1, regiony + ymat) = 25 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 25 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 25 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 25 + material)
        Case 1
            map(regionx + xmat + remind + 1, regiony + ymat) = 15 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 15 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 15 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 15 + material)
            Call Watchabove(regionx, regiony, remind)
        Case 2
            map(regionx + xmat + remind + 1, regiony + ymat) = 18 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 18 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 18 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 18 + material)
            Call Watchbelow(regionx, regiony, remind)
        Case 4
            map(regionx + xmat + remind + 1, regiony + ymat) = 17 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 17 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 17 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 17 + material)
            Call Watchleft(regionx, regiony, remind)
        Case 8
            map(regionx + xmat + remind + 1, regiony + ymat) = 16 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 16 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 16 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 16 + material)
            Call Watchright(regionx, regiony, remind)
        Case 3
            map(regionx + xmat + remind + 1, regiony + ymat) = 19 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 19 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 19 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 19 + material)
            Call Watchabove(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
        Case 5
            map(regionx + xmat + remind + 1, regiony + ymat) = 14 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 14 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 14 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 14 + material)
            Call Watchabove(regionx, regiony, remind)
            Call Watchleft(regionx, regiony, remind)
        Case 9
            map(regionx + xmat + remind + 1, regiony + ymat) = 13 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 13 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 13 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 13 + material)
            Call Watchabove(regionx, regiony, remind)
            Call Watchright(regionx, regiony, remind)
        Case 6
            map(regionx + xmat + remind + 1, regiony + ymat) = 12 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 12 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 12 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 12 + material)
            Call Watchleft(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
        Case 10
            map(regionx + xmat + remind + 1, regiony + ymat) = 21 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 21 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 21 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 21 + material)
            Call Watchright(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
        Case 12
            map(regionx + xmat + remind + 1, regiony + ymat) = 20 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 20 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 20 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 20 + material)
            Call Watchleft(regionx, regiony, remind)
            Call Watchright(regionx, regiony, remind)
        Case 7
            map(regionx + xmat + remind + 1, regiony + ymat) = 23 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 23 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 23 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 23 + material)
            Call Watchabove(regionx, regiony, remind)
            Call Watchleft(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
        Case 11
            map(regionx + xmat + remind + 1, regiony + ymat) = 22 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 22 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 22 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 22 + material)
            Call Watchabove(regionx, regiony, remind)
            Call Watchright(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
        Case 13
            map(regionx + xmat + remind + 1, regiony + ymat) = 24 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 24 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 24 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 24 + material)
            Call Watchabove(regionx, regiony, remind)
            Call Watchleft(regionx, regiony, remind)
            Call Watchright(regionx, regiony, remind)
        Case 14
            map(regionx + xmat + remind + 1, regiony + ymat) = 11 + material
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 11 + material
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 11 + material
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 11 + material)
            Call Watchleft(regionx, regiony, remind)
            Call Watchright(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
        Case 15
            map(regionx + xmat + remind + 1, regiony + ymat) = 62 + material / 15
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 62 + material / 15
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 62 + material / 15
            Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, 62 + material / 15)
            Call Watchabove(regionx, regiony, remind)
            Call Watchleft(regionx, regiony, remind)
            Call Watchright(regionx, regiony, remind)
            Call Watchbelow(regionx, regiony, remind)
    End Select
    Select Case map(regionx + xmat + remind + 1, regiony + ymat + 1)
        Case -5: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 0)
        Case 98: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 1)
        Case 99: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 4)
        Case -6: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 5)
    End Select
End Sub

Sub PutObject (regionx, regiony)
    Select Case regionx + xmat
        Case Is > 31: remind = -32
        Case Is < 0: remind = 32
        Case Else: remind = 0
    End Select
    If regionx + xmat + remind + 1 = A And regiony + ymat = b Then A = -1: b = -1
    If regionx + xmat + remind + 1 = aghost And regiony + ymat = bghost And selection + 1 <> 69 And selection + 1 <> 70 Then
        aghost = -1: bghost = -1: phantoms = 0: bugs = 0
        View
        Line (263 - 17 * 2, 8)-(278 - 17 * 2, 15), 0, BF
        ViewText 222, 8, Right$(Str$(phantoms), Len(Str$(phantoms)) - 1)
        Line (263 - 17 * 1, 8)-(278 - 17 * 1, 15), 0, BF
        ViewText 239, 8, Right$(Str$(bugs), Len(Str$(bugs)) - 1)
        View Screen(6, 26)-(314, 198)
    End If
    If selection + 1 < 71 Then
        If (regionx + xmat + remind + 1) = 1 Then
            If selection + 1 > 8 And selection + 1 < 65 Then
                map(33, regiony + ymat) = selection + 1
            Else If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then map(33, regiony + ymat) = 0
            End If
        End If
        If (regionx + xmat + remind + 1) = 32 Then
            If selection + 1 > 8 And selection + 1 < 65 Then
                map(0, regiony + ymat) = selection + 1
            Else If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then map(0, regiony + ymat) = 0
            End If
        End If
    End If
    Select Case map(regionx + xmat + remind + 1, regiony + ymat)
        Case 99, -5:
            If regionx < 17 Then Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            If regionx < 17 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 99 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 99 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
            If regionx < 17 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -5 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -5 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat) = 0: map(2, regiony + ymat) = 0
                Case 32: map(0, regiony + ymat) = 0: map(33, regiony + ymat) = 0: map(1, regiony + ymat) = 0
                Case 31: map(32, regiony + ymat) = 0: map(0, regiony + ymat) = 0
                Case Else: map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 0
            End Select
        Case -6, 98:
            If regionx > 0 Then Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            If regionx > 0 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -6 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = -6 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
            If regionx > 0 And regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 98 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
            If regiony > 0 And map(regionx + xmat + remind + 1, regiony + ymat) = 98 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat) = 0: map(0, regiony + ymat) = 0: map(32, regiony + ymat) = 0
                Case 32: map(0, regiony + ymat) = 0: map(31, regiony + ymat) = 0
                Case 2: map(1, regiony + ymat) = 0: map(33, regiony + ymat) = 0
                Case Else: map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 0
            End Select
    End Select
    Select Case selection + 1
        Case 0
            Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            map(regionx + xmat + remind + 1, regiony + ymat) = 0
            If (regionx + xmat + remind + 1) = 1 Then map(33, regiony + ymat) = 0
            If (regionx + xmat + remind + 1) = 32 Then map(0, regiony + ymat) = 0
        Case 65
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then
                If A > -1 Then
                    Select Case A - xmat
                        Case Is > 31: remind2 = -32
                        Case Is < 0: remind2 = 32
                        Case Else: remind2 = 0
                    End Select
                    Line ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 28)-((A - xmat + remind2 - 1) * 17 + 8 + 15, (b - ymat) * 17 + 28 + 15), 0, BF
                    map(A, b) = 0
                    Select Case map(A, b + 1)
                        Case -5: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 0)
                        Case 98: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 1)
                        Case 99: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 4)
                        Case -6: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 5)
                    End Select
                End If
                map(regionx + xmat + remind + 1, regiony + ymat) = -1
                A = regionx + xmat + remind + 1: b = regiony + ymat
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), pac(0, 0)
            Else Beep: Exit Sub
            End If
        Case 66
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then
                If A > -1 Then
                    Select Case A - xmat
                        Case Is > 31: remind2 = -32
                        Case Is < 0: remind2 = 32
                        Case Else: remind2 = 0
                    End Select
                    Line ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 28)-((A - xmat + remind2 - 1) * 17 + 8 + 15, (b - ymat) * 17 + 28 + 15), 0, BF
                    map(A, b) = 0
                    Select Case map(A, b + 1)
                        Case -5: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 0)
                        Case 98: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 1)
                        Case 99: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 4)
                        Case -6: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 5)
                    End Select
                End If
                map(regionx + xmat + remind + 1, regiony + ymat) = -3
                A = regionx + xmat + remind + 1: b = regiony + ymat
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), pac(0, 1)
            Else Beep: Exit Sub
            End If
        Case 67
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then
                If A > -1 Then
                    Select Case A - xmat
                        Case Is > 31: remind2 = -32
                        Case Is < 0: remind2 = 32
                        Case Else: remind2 = 0
                    End Select
                    Line ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 28)-((A - xmat + remind2 - 1) * 17 + 8 + 15, (b - ymat) * 17 + 28 + 15), 0, BF
                    map(A, b) = 0
                    Select Case map(A, b + 1)
                        Case -5: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 0)
                        Case 98: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 1)
                        Case 99: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 4)
                        Case -6: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 5)
                    End Select
                End If
                map(regionx + xmat + remind + 1, regiony + ymat) = -4
                A = regionx + xmat + remind + 1: b = regiony + ymat
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), pac(0, 2)
            Else Beep: Exit Sub
            End If
        Case 68
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then
                If A > -1 Then
                    Select Case A - xmat
                        Case Is > 31: remind2 = -32
                        Case Is < 0: remind2 = 32
                        Case Else: remind2 = 0
                    End Select
                    Line ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 28)-((A - xmat + remind2 - 1) * 17 + 8 + 15, (b - ymat) * 17 + 28 + 15), 0, BF
                    map(A, b) = 0
                    Select Case map(A, b + 1)
                        Case -5: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 0)
                        Case 98: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 1)
                        Case 99: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 4)
                        Case -6: Put ((A - xmat + remind2 - 1) * 17 + 8, (b - ymat) * 17 + 30), door(0, 5)
                    End Select
                End If
                map(regionx + xmat + remind + 1, regiony + ymat) = -2
                A = regionx + xmat + remind + 1: b = regiony + ymat
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), pac(0, 3)
            Else Beep: Exit Sub
            End If
        Case 69
            If aghost > -1 Then
                Select Case aghost - xmat
                    Case Is > 31: remind2 = -32
                    Case Is < 0: remind2 = 32
                    Case Else: remind2 = 0
                End Select
                Line ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 28)-((aghost - xmat + remind2 - 1) * 17 + 8 + 15, (bghost - ymat) * 17 + 28 + 15), 0, BF
                map(aghost, bghost) = 0
                Select Case map(aghost, bghost + 1)
                    Case -5: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 0)
                    Case 98: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 1)
                    Case 99: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 4)
                    Case -6: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 5)
                End Select
            End If
            map(regionx + xmat + remind + 1, regiony + ymat) = 2
            aghost = regionx + xmat + remind + 1: bghost = regiony + ymat
            Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            Put (regionx * 17 + 8, regiony * 17 + 28), phantom(0, 1)
        Case 70
            If aghost > -1 Then
                Select Case aghost - xmat
                    Case Is > 31: remind2 = -32
                    Case Is < 0: remind2 = 32
                    Case Else: remind2 = 0
                End Select
                Line ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 28)-((aghost - xmat + remind2 - 1) * 17 + 8 + 15, (bghost - ymat) * 17 + 28 + 15), 0, BF
                map(aghost, bghost) = 0
                Select Case map(aghost, bghost + 1)
                    Case -5: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 0)
                    Case 98: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 1)
                    Case 99: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 4)
                    Case -6: Put ((aghost - xmat + remind2 - 1) * 17 + 8, (bghost - ymat) * 17 + 30), door(0, 5)
                End Select
            End If
            map(regionx + xmat + remind + 1, regiony + ymat) = -8
            aghost = regionx + xmat + remind + 1: bghost = regiony + ymat
            Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
            Put (regionx * 17 + 14, regiony * 17 + 36), phantom(0, 0)
            Put (regionx * 17 + 4, regiony * 17 + 25), tiles(0, 4)
        Case 71
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then
                Select Case map(regionx + xmat + remind + 1 + 1, regiony + ymat)
                    Case 99, -5:
                                        IF regionx + 1 < 17 THEN LINE ((regionx + 1 + 1) * 17 + 8, (regiony) * 17 + 28)-((regionx + 1 + 1) * 17 + 8 + 15, (regiony) * 17 + 28 + 15), 0, BF: LINE ((regionx + 1) * 17 + 8, (regiony) * 17 + 28)-((regionx  _
+ 1) * 17 + 8 + 15, (regiony) * 17 + 28 + 15), 0, BF
                        If regionx + 1 < 17 And regiony > 0 And map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 99 Then Put ((regionx + 1 + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
                        If regiony > 0 And regionx < 17 And map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 99 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
                        If regionx + 1 < 17 And regiony > 0 And map(regionx + xmat + remind + 1 + 1, regiony + ymat) = -5 Then Put ((regionx + 1 + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
                        If regiony > 0 And map(regionx + xmat + remind + 1 + 1, regiony + ymat) = -5 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
                        Select Case (regionx + xmat + remind + 1 + 1)
                            Case 33: map(1, regiony + ymat) = 0: map(2, regiony + ymat) = 0
                            Case 1: map(33, regiony + ymat) = 0: map(2, regiony + ymat) = 0
                            Case 32: map(0, regiony + ymat) = 0: map(33, regiony + ymat) = 0: map(1, regiony + ymat) = 0
                            Case 31: map(32, regiony + ymat) = 0: map(0, regiony + ymat) = 0
                            Case Else: map(regionx + xmat + remind + 1 + 1 + 1, regiony + ymat) = 0
                        End Select
                End Select
                Call EraseDoorAround(0, -1, regionx, regiony, remind)
                Call EraseDoorAround(1, -1, regionx, regiony, remind)
                Call EraseDoorAround(0, 1, regionx, regiony, remind)
                Call EraseDoorAround(1, 1, regionx, regiony, remind)
                Select Case (regionx + xmat + remind + 1)
                    Case 1: map(33, regiony + ymat) = 99: map(2, regiony + ymat) = -6
                    Case 32: map(0, regiony + ymat) = 99: map(33, regiony + ymat) = -6: map(1, regiony + ymat) = -6
                    Case 31: map(32, regiony + ymat) = -6: map(0, regiony + ymat) = -6
                    Case Else: map(regionx + xmat + remind + 1 + 1, regiony + ymat) = -6
                End Select
                map(regionx + xmat + remind + 1, regiony + ymat) = 99
                If map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 99 Or map(regionx + xmat + remind + 1 + 1, regiony + ymat) = -5 Then
                End If
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), door(0, 6)
                If regiony > 0 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
                If regionx < 17 Then
                    Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                    Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), door(0, 7)
                    If regiony > 0 Then Put ((regionx + 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
                End If
            Else Beep: Exit Sub
            End If
        Case 72
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Then
                Select Case map(regionx + xmat + remind + 1 - 1, regiony + ymat)
                    Case -6, 98:
                                        IF regionx - 1 > 0 THEN LINE ((regionx - 1 - 1) * 17 + 8, (regiony) * 17 + 28)-((regionx - 1 - 1) * 17 + 8 + 15, (regiony) * 17 + 28 + 15), 0, BF: LINE ((regionx - 1) * 17 + 8, (regiony) * 17 + 28)-((regionx - _
 1) * 17 + 8 + 15, (regiony) * 17 + 28 + 15), 0, BF
                        If regionx - 1 > 0 And regiony > 0 And map(regionx + xmat + remind - 1 + 1, regiony + ymat) = -6 Then Put ((regionx - 1 - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
                        If regiony > 0 And map(regionx + xmat + remind - 1 + 1, regiony + ymat) = -6 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
                        If regionx - 1 > 0 And regiony > 0 And map(regionx + xmat + remind - 1 + 1, regiony + ymat) = 98 Then Put ((regionx - 1 - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
                        If regiony > 0 And regionx > 0 And map(regionx + xmat + remind - 1 + 1, regiony + ymat) = 98 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
                        Select Case (regionx + xmat + remind + 1 - 1)
                            Case 0: map(32, regiony + ymat) = 0: map(31, regiony + ymat) = 0
                            Case 1: map(33, regiony + ymat) = 0: map(0, regiony + ymat) = 0: map(32, regiony + ymat) = 0
                            Case 32: map(0, regiony + ymat) = 0: map(31, regiony + ymat) = 0
                            Case 2: map(1, regiony + ymat) = 0: map(33, regiony + ymat) = 0
                            Case Else: map(regionx + xmat + remind + 1 - 2, regiony + ymat) = 0
                        End Select
                End Select
                Call EraseDoorAround(0, -1, regionx, regiony, remind)
                Call EraseDoorAround(-1, -1, regionx, regiony, remind)
                Call EraseDoorAround(0, 1, regionx, regiony, remind)
                Call EraseDoorAround(-1, 1, regionx, regiony, remind)
                Select Case (regionx + xmat + remind + 1)
                    Case 1: map(33, regiony + ymat) = 98: map(0, regiony + ymat) = -5: map(32, regiony + ymat) = -5
                    Case 32: map(0, regiony + ymat) = 98: map(31, regiony + ymat) = -5
                    Case 2: map(1, regiony + ymat) = -5: map(33, regiony + ymat) = -5
                    Case Else: map(regionx + xmat + remind + 1 - 1, regiony + ymat) = -5
                End Select
                map(regionx + xmat + remind + 1, regiony + ymat) = 98
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), door(0, 3)
                If regiony > 0 Then Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
                If regionx > 0 Then
                    Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                    Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), door(0, 2)
                    If regiony > 0 Then Put ((regionx - 1) * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
                End If
            Else Beep: Exit Sub
            End If
        Case Else
            If (regiony + ymat) > 4 And (regiony + ymat) < 25 Or selection + 1 > 8 Then
                map(regionx + xmat + remind + 1, regiony + ymat) = selection + 1
                Line (regionx * 17 + 8, regiony * 17 + 28)-(regionx * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, regiony * 17 + 28), tiles(0, selection + 1)
            Else Beep: Exit Sub
            End If
    End Select
    Select Case map(regionx + xmat + remind + 1, regiony + ymat + 1)
        Case -5: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 0)
        Case 98: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 1)
        Case 99: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 4)
        Case -6: Put (regionx * 17 + 8, regiony * 17 + 30), door(0, 5)
    End Select
End Sub

Sub Watchabove (regionx, regiony, remind)
    Select Case map(regionx + xmat + remind + 1, regiony + ymat - 1)
        Case 13 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 22 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 22 + material
                Case 32: map(0, regiony + ymat - 1) = 22 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 22 + material)
            End If
        Case 14 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 23 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 23 + material
                Case 32: map(0, regiony + ymat - 1) = 23 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 23 + material)
            End If
        Case 15 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 19 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 19 + material
                Case 32: map(0, regiony + ymat - 1) = 19 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 19 + material)
            End If
        Case 16 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 21 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 21 + material
                Case 32: map(0, regiony + ymat - 1) = 21 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 21 + material)
            End If
        Case 17 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 12 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 12 + material
                Case 32: map(0, regiony + ymat - 1) = 12 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 12 + material)
            End If
        Case 20 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 11 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 11 + material
                Case 32: map(0, regiony + ymat - 1) = 11 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 11 + material)
            End If
        Case 25 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 18 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 18 + material
                Case 32: map(0, regiony + ymat - 1) = 18 + material
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 18 + material)
            End If
        Case 24 + material
            map(regionx + xmat + remind + 1, regiony + ymat - 1) = 62 + material / 15
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat - 1) = 62 + material / 15
                Case 32: map(0, regiony + ymat - 1) = 62 + material / 15
            End Select
            If (regiony - 1) > -1 Then
                Line (regionx * 17 + 8, (regiony - 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony - 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony - 1) * 17 + 28), tiles(0, 62 + material / 15)
            End If
        Case Else: Exit Sub
    End Select
    Select Case map(regionx + xmat + remind + 1, regiony + ymat)
        Case -5: Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 0)
        Case 98: Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 1)
        Case 99: Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 4)
        Case -6: Put (regionx * 17 + 8, (regiony - 1) * 17 + 30), door(0, 5)
    End Select
End Sub

Sub Watchbelow (regionx, regiony, remind)
    Select Case map(regionx + xmat + remind + 1, regiony + ymat + 1)
        Case 12 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 23 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 23 + material
                Case 32: map(0, regiony + ymat + 1) = 23 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 23 + material)
            End If
        Case 16 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 13 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 13 + material
                Case 32: map(0, regiony + ymat + 1) = 13 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 13 + material)
            End If
        Case 17 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 14 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 14 + material
                Case 32: map(0, regiony + ymat + 1) = 14 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 14 + material)
            End If
        Case 18 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 19 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 19 + material
                Case 32: map(0, regiony + ymat + 1) = 19 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 19 + material)
            End If
        Case 20 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 24 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 24 + material
                Case 32: map(0, regiony + ymat + 1) = 24 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 24 + material)
            End If
        Case 21 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 22 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 22 + material
                Case 32: map(0, regiony + ymat + 1) = 22 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 22 + material)
            End If
        Case 25 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 15 + material
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 15 + material
                Case 32: map(0, regiony + ymat + 1) = 15 + material
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 15 + material)
            End If
        Case 11 + material
            map(regionx + xmat + remind + 1, regiony + ymat + 1) = 62 + material / 15
            Select Case (regionx + xmat + remind + 1)
                Case 1: map(33, regiony + ymat + 1) = 62 + material / 15
                Case 32: map(0, regiony + ymat + 1) = 62 + material / 15
            End Select
            If (regiony + 1) < 10 Then
                Line (regionx * 17 + 8, (regiony + 1) * 17 + 28)-(regionx * 17 + 8 + 15, (regiony + 1) * 17 + 28 + 15), 0, BF
                Put (regionx * 17 + 8, (regiony + 1) * 17 + 28), tiles(0, 62 + material / 15)
            End If
        Case Else: Exit Sub
    End Select
    Select Case map(regionx + xmat + remind + 1, regiony + ymat + 2)
        Case -5: Put (regionx * 17 + 8, (regiony + 1) * 17 + 30), door(0, 0)
        Case 98: Put (regionx * 17 + 8, (regiony + 1) * 17 + 30), door(0, 1)
        Case 99: Put (regionx * 17 + 8, (regiony + 1) * 17 + 30), door(0, 4)
        Case -6: Put (regionx * 17 + 8, (regiony + 1) * 17 + 30), door(0, 5)
    End Select
End Sub

Sub Watchleft (regionx, regiony, remind)
    Select Case map(regionx + xmat + remind + 1 - 1, regiony + ymat)
        Case 12 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 11 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 11 + material
                Case 32: map(0, regiony + ymat) = 11 + material
                Case 0: map(32, regiony + ymat) = 11 + material
                Case 33: map(1, regiony + ymat) = 11 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 11 + material)
            End If
        Case 14 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 24 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 24 + material
                Case 32: map(0, regiony + ymat) = 24 + material
                Case 0: map(32, regiony + ymat) = 24 + material
                Case 33: map(1, regiony + ymat) = 24 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 24 + material)
            End If
        Case 15 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 13 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 13 + material
                Case 32: map(0, regiony + ymat) = 13 + material
                Case 0: map(32, regiony + ymat) = 13 + material
                Case 33: map(1, regiony + ymat) = 13 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 13 + material)
            End If
        Case 17 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 20 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 20 + material
                Case 32: map(0, regiony + ymat) = 20 + material
                Case 0: map(32, regiony + ymat) = 20 + material
                Case 33: map(1, regiony + ymat) = 20 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 20 + material)
            End If
        Case 18 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 21 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 21 + material
                Case 32: map(0, regiony + ymat) = 21 + material
                Case 0: map(32, regiony + ymat) = 21 + material
                Case 33: map(1, regiony + ymat) = 21 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 21 + material)
            End If
        Case 19 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 22 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 22 + material
                Case 32: map(0, regiony + ymat) = 22 + material
                Case 0: map(32, regiony + ymat) = 22 + material
                Case 33: map(1, regiony + ymat) = 22 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 22 + material)
            End If
        Case 25 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 16 + material
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 16 + material
                Case 32: map(0, regiony + ymat) = 16 + material
                Case 0: map(32, regiony + ymat) = 16 + material
                Case 33: map(1, regiony + ymat) = 16 + material
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 16 + material)
            End If
        Case 23 + material
            map(regionx + xmat + remind + 1 - 1, regiony + ymat) = 62 + material / 15
            Select Case (regionx + xmat + remind + 1 - 1)
                Case 1: map(33, regiony + ymat) = 62 + material / 15
                Case 32: map(0, regiony + ymat) = 62 + material / 15
                Case 0: map(32, regiony + ymat) = 62 + material / 15
                Case 33: map(1, regiony + ymat) = 62 + material / 15
            End Select
            If (regionx - 1) > -1 Then
                Line ((regionx - 1) * 17 + 8, regiony * 17 + 28)-((regionx - 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx - 1) * 17 + 8, regiony * 17 + 28), tiles(0, 62 + material / 15)
            End If
        Case Else: Exit Sub
    End Select
    Select Case map(regionx + xmat + remind + 1 - 1, regiony + ymat + 1)
        Case -5: Put ((regionx - 1) * 17 + 8, regiony * 17 + 30), door(0, 0)
        Case 98: Put ((regionx - 1) * 17 + 8, regiony * 17 + 30), door(0, 1)
        Case 99: Put ((regionx - 1) * 17 + 8, regiony * 17 + 30), door(0, 4)
        Case -6: Put ((regionx - 1) * 17 + 8, regiony * 17 + 30), door(0, 5)
    End Select
End Sub

Sub Watchright (regionx, regiony, remind)
    Select Case map(regionx + xmat + remind + 1 + 1, regiony + ymat)
        Case 13 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 24 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 24 + material
                Case 32: map(0, regiony + ymat) = 24 + material
                Case 0: map(32, regiony + ymat) = 24 + material
                Case 33: map(1, regiony + ymat) = 24 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 24 + material)
            End If
        Case 15 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 14 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 14 + material
                Case 32: map(0, regiony + ymat) = 14 + material
                Case 0: map(32, regiony + ymat) = 14 + material
                Case 33: map(1, regiony + ymat) = 14 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 14 + material)
            End If
        Case 16 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 20 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 20 + material
                Case 32: map(0, regiony + ymat) = 20 + material
                Case 0: map(32, regiony + ymat) = 20 + material
                Case 33: map(1, regiony + ymat) = 20 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 20 + material)
            End If
        Case 18 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 12 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 12 + material
                Case 32: map(0, regiony + ymat) = 12 + material
                Case 0: map(32, regiony + ymat) = 12 + material
                Case 33: map(1, regiony + ymat) = 12 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 12 + material)
            End If
        Case 19 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 23 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 23 + material
                Case 32: map(0, regiony + ymat) = 23 + material
                Case 0: map(32, regiony + ymat) = 23 + material
                Case 33: map(1, regiony + ymat) = 23 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 23 + material)
            End If
        Case 21 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 11 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 11 + material
                Case 32: map(0, regiony + ymat) = 11 + material
                Case 0: map(32, regiony + ymat) = 11 + material
                Case 33: map(1, regiony + ymat) = 11 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 11 + material)
            End If
        Case 25 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 17 + material
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 17 + material
                Case 32: map(0, regiony + ymat) = 17 + material
                Case 0: map(32, regiony + ymat) = 17 + material
                Case 33: map(1, regiony + ymat) = 17 + material
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 17 + material)
            End If
        Case 22 + material
            map(regionx + xmat + remind + 1 + 1, regiony + ymat) = 62 + material / 15
            Select Case (regionx + xmat + remind + 1 + 1)
                Case 1: map(33, regiony + ymat) = 62 + material / 15
                Case 32: map(0, regiony + ymat) = 62 + material / 15
                Case 0: map(32, regiony + ymat) = 62 + material / 15
                Case 33: map(1, regiony + ymat) = 62 + material / 15
            End Select
            If (regionx + 1) < 18 Then
                Line ((regionx + 1) * 17 + 8, regiony * 17 + 28)-((regionx + 1) * 17 + 8 + 15, regiony * 17 + 28 + 15), 0, BF
                Put ((regionx + 1) * 17 + 8, regiony * 17 + 28), tiles(0, 62 + material / 15)
            End If
        Case Else: Exit Sub
    End Select
    Select Case map(regionx + xmat + remind + 1 + 1, regiony + ymat + 1)
        Case -5: Put ((regionx + 1) * 17 + 8, regiony * 17 + 30), door(0, 0)
        Case 98: Put ((regionx + 1) * 17 + 8, regiony * 17 + 30), door(0, 1)
        Case 99: Put ((regionx + 1) * 17 + 8, regiony * 17 + 30), door(0, 4)
        Case -6: Put ((regionx + 1) * 17 + 8, regiony * 17 + 30), door(0, 5)
    End Select
End Sub

