$Debug
' Sean Weeks
' Assignment: MOVE21
'
' ---------------------------
'      Breakout 2002
' ---------------------------
'
$Resize:Smooth

' --- Dimentianize arrays:
' --- System arrays:
' Palette array!
Dim Shared pal(255, 2)
Dim Shared grid$(32, 21, 2)
Dim oldplace(20, 2)
' --- Sprites
Dim Shared letter(20)
Dim Shared letter2(20)
Dim Shared bv(50)
Dim Shared wv(50)
Dim Shared bh(100)
Dim Shared wh(100)
Dim Shared g8(100)
Dim Shared g2(100)
Dim Shared guy(2000)
Dim Shared objects(1680)
Dim Shared box(100)
Dim Shared man(2)
Dim Shared fruit(735)
Dim Shared elevator(100)
Dim Shared updown(4, 5)
Dim Shared keys(2, 5)
Dim Shared bullit(4)
Dim Shared bull(20)
Dim Shared robot(400)
Dim Shared robot2(4, 6)
Dim Shared explosion(100)
Dim Shared fade(9)
Dim Shared dead(100)
Dim Shared monster(1)

Const gravity = .08
Const pi = 3.1415926435#

' -------------------- Set up variables -----------------
Randomize Timer
'--- Mouse setup
Dim mouse1(0 To 45) As Integer
Restore DataForMouse
Def Seg = VarSeg(mouse1(0))
For i% = 0 To 52
    Read Byte$
    Poke VarPtr(mouse1(0)) + i%, Val("&H" + Byte$)
Next

Screen 13
_FullScreen _SquarePixels , _Smooth

Palette
Cls

Locate 12, 10
Color 15
Play "mb t200 o2 l64 ccc"

radio$ = "t230 o5 l8 c l5 c l4 c l10 c c"

' --- Set nice blue to white gradiant
For l = 0 To 255
    a = l
    b = Int(l / 3)
    c = Int(l / 4)
    d = Int(l / 1.5)
    If b > 63 Then b = 63
    If c > 63 Then c = 63
    If d > 63 Then d = 63
    Out &H3C8, a
    Out &H3C9, b
    Out &H3C9, c
    Out &H3C9, d
    pal(a, 0) = b
    pal(a, 1) = c
    pal(a, 2) = d
Next l

GoSub nulpal
pnt1x = Int(Rnd * 320)
pnt1y = Int(Rnd * 200)
pnt2x = Int(Rnd * 320)
pnt2y = Int(Rnd * 200)
For y = 0 To 100
    For x = 0 To 320
        dst1 = Sqr(Abs(x - pnt1x) ^ 2 + Abs(y - pnt1y) ^ 2)
        dst = dst1
        dst2 = Sqr(Abs(x - pnt2x) ^ 2 + Abs(y - pnt2y) ^ 2)
        If dst2 < dst1 Then dst = dst2
        PSet (x, y), Int(dst / 1.3)
        y = 200 - y
        dst1 = Sqr(Abs(x - pnt1x) ^ 2 + Abs(y - pnt1y) ^ 2)
        dst = dst1
        dst2 = Sqr(Abs(x - pnt2x) ^ 2 + Abs(y - pnt2y) ^ 2)
        If dst2 < dst1 Then dst = dst2
        PSet (x, y), Int(dst / 1.3)
        y = 200 - y
    Next x
Next y
fade = 1
GoSub fastfade
Play "mb " + radio$
_KeyClear
For ii = 1 To 20
    Play "mb t225 o3 l64 acdgegdccdcdgdegaf+"
    For i = 2 To 255
        Out &H3C8, i
        Out &H3C9, 63
        Out &H3C9, 63
        Out &H3C9, 63 - Int(i / 4)
        a = i - 2
        b = Int(pal(i - 2, 0))
        c = Int(pal(i - 2, 1))
        d = Int(pal(i - 2, 2))
        Out &H3C8, a
        Out &H3C9, b
        Out &H3C9, c
        Out &H3C9, d
        If InKey$ <> "" Then GoTo skipintro
        _Limit 60
    Next i
Next ii
skipintro:
fade = 0
GoSub fastfade

' --- Set general variables
GoSub SubTime
movespeed = 10 '(seconds)
movespeed = movespeed - 1
' - Get # of names
Restore namesdata
maxname = -1
Do
    maxname = maxname + 1
    Read name$
Loop Until name$ = "end"
' ************* Music! **************
explode$ = "t255 l64 o1 adgefcgebefgcc o2 a"
crash$ = "t255 l64 o1 abgedeg o2 ed o1 eegb"
launch$ = "t254 l10 o1 l64 c o1 ebcd o4 cd o1 dcccbb o1 g p64 g p40 g"
eerie$ = "t225 l4 o3 cg p4 cg p5 cg"
select$ = "t225 l12 o3 ce"
die$ = "t225 l4 o3 d+ec o2 b o3 c o2 c l2 o1 l2 c l20 o5 c"
win$ = "t225 l4 o3 c c p4 c l2 d l2 e f l6 c p3 f"
lose$ = "t225 l4 o2 bbb p4 o3 c o2 b b l7 o3 c o2 a+b"
land$ = "t254 l10 o1 l64 cdcccdco3cdo1cdc"
eject$ = "t225 l64 o3 cedo2dceo2cdfo1egfacegbadgdbafg"
crashplane$ = "t255 l64 o1 abgedegbedgedccd o3 ed o1 edegbecdededegbed"


GoTo mainprogram

'############################## Main Gosubs ###########################

' --- Input text by Sean!:
textinput:
blinker = -1
char = 0
Locate y1, x1
Print String$(maxlength, " ")
text$ = ""
Do
    a$ = InKey$
    blinker = blinker + 40
    Color Int(131 + 114 * Cos(blinker))
    Locate y1, x1 + char: Print Chr$(219)
    Color 15
    If Len(a$) > 0 Then
        If Asc(a$) > 32 And Asc(a$) < 123 Or a$ = " " Then
            If char < maxlength Then
                char = char + 1
                text$ = text$ + a$
                Locate y1, x1: Print text$
            End If
        End If
        If Asc(a$) = 27 Then Print "enter"
        If Asc(a$) = 13 And char > 0 Then GoTo textdone
        If Asc(a$) = 8 And char > 0 Then
            text$ = Left$(text$, Len(text$) - 1)
            Locate y1, x1 + char: Print " "
            char = char - 1
        End If
    End If

    _Limit 60
Loop
textdone:
Return

nulpal:
' --- Make image invisible
For i = 1 To 256
    Out &H3C8, i
    Out &H3C9, 0
    Out &H3C9, 0
    Out &H3C9, 0
Next i
Return

shade:
For y = y1 To y2 Step 2
    For x = x1 To x2 Step 2
        PSet (x, y), 0
    Next x
Next y
Return

' --- Load palette for any graphic
' --- a$ is palette file
fadepal:
' --- Open palette file
Open a$ For Input As #1
' --- Loop through each color
For l = 0 To 255
    Input #1, s$
    pal(l, 0) = Int(Val(Mid$(s$, 1, 3)))
    pal(l, 1) = Int(Val(Mid$(s$, 4, 3)))
    pal(l, 2) = Int(Val(Mid$(s$, 8, 3)))
Next l
' --- Close palette file
Close #1
fastfade:
' --- fade >> -1=instant 0=fade out, 1=fade in 2=fade white 3=fade white2normal
fadd = 0
If fade = -1 Then
    fin = 1
    fout = 1
    fstep = 1
End If
If fade = 0 Then
    fin = 1
    fout = 0
    fstep = -.02
End If
If fade = 1 Then
    fin = 0
    fout = 1
    fstep = .02
End If
If fade = 2 Then
    fin = 1
    fout = 2
    fstep = .02
    fadd = 1
End If
If fade = 3 Then
    fin = 2
    fout = 1
    fstep = -.02
    fadd = 1
End If

For intensity = fin To fout Step fstep
    For l = 0 To 255
        add = ((intensity - 1) * 63) * fadd
        a = l
        b = Int(pal(l, 0) * intensity + add)
        c = Int(pal(l, 1) * intensity + add)
        d = Int(pal(l, 2) * intensity + add)
        If b > 63 Then b = 63
        If c > 63 Then c = 63
        If d > 63 Then d = 63
        Out &H3C8, a
        Out &H3C9, b
        Out &H3C9, c
        Out &H3C9, d
    Next l
    _Limit 60
Next intensity
Return

SubTime:
' Get current time:
houres = Val(Left$(Time$, 2))
minutes = Val(Mid$(Time$, 4, 2))
seconds = Val(Mid$(Time$, 7))
picotime = houres * 60 * 60 + minutes * 60 + seconds + impatient
Return

' --- down-arrow transition
clearphoto:
For y = 0 To 200
    Line (0, y)-(160, y + 200), 0
    Line (160, y + 200)-(320, y), 0
    Line (0, y - 200)-(160, y), 0
    Line (160, y)-(320, y - 200), 0
    For x = 1 To 999
    Next x
Next y
Return

' Transition
liftoff:
Line (0, 180)-(640, 200), 0, BF
Locate 25, 1
For x = 1 To 50
    For delay = 1 To 30
    Next delay
    Print
Next x
Return

' --- Create any size of shaded area
areashade:
For y = y1 To y2
    For x = x1 To x2
        If Point(x, y) = areacatch Then PSet (x, y), areachange
    Next x
Next y
Return

' --- Create any size of window
basicwindow:
bgcolor = 1
bordercolor = 12
shadowcolor = 8
windowshadow = 1
borderwidth = 7
' --- Custom window routine
customwindow:
Line (x1 + borderwidth, y1 + borderwidth)-(x2 - borderwidth, y2 - borderwidth), bgcolor, BF
GoSub rectangle
If windowshadow = 1 Then
    Line (x1 + borderwidth, y2 + 1)-(x2 + borderwidth, y2 + borderwidth), shadowcolor, BF
    Line (x2 + 1, y1 + borderwidth)-(x2 + borderwidth, y2 + borderwidth), shadowcolor, BF
End If
Return

'--- Draw any size ractangle with cool shadows!
rectangle:
darkcolor = 8
lightcolor = 15
If bordercolor > 9 Then darkcolor = bordercolor - 8
If bordercolor < 10 Then lightcolor = bordercolor + 8
' --- Draw main window elements
Line (x1, y1)-(x2, y1 + borderwidth), bordercolor, BF
Line (x2 - borderwidth, y1)-(x2, y2), bordercolor, BF
Line (x2, y2)-(x1, y2 - borderwidth), bordercolor, BF
Line (x1, y2)-(x1 + borderwidth, y1), bordercolor, BF
Line (x1, y1)-(x2, y1), lightcolor
Line (x2, y1)-(x2, y2), darkcolor
Line (x2, y2)-(x1, y2), darkcolor
Line (x1, y2)-(x1, y1), lightcolor
Line (x1 + borderwidth, y1 + borderwidth)-(x2 - borderwidth, y1 + borderwidth), darkcolor
Line (x2 - borderwidth, y1 + borderwidth)-(x2 - borderwidth, y2 - borderwidth), lightcolor
Line (x2 - borderwidth, y2 - borderwidth)-(x1 + borderwidth, y2 - borderwidth), lightcolor
Line (x1 + borderwidth, y2 - borderwidth)-(x1 + borderwidth, y1 + borderwidth), darkcolor
Return

' --- Draw any shaded box
box:
edgecolor = 8
lightcolor = 15
If bgcolor > 9 Then edgecolor = bgcolor - 8
If bgcolor < 10 Then lightcolor = bgcolor + 8
Line (x1, y1)-(x2, y2), bgcolor, BF
Line (x1, y1)-(x2, y1), lightcolor
Line (x2, y1)-(x2, y2), edgecolor
Line (x2, y2)-(x1, y2), edgecolor
Line (x1, y2)-(x1, y1), lightcolor
Return

' --- Show sprite type text
showtext:
Get (0, 0)-(8, 8), letter()
Palette 240, 65536 * blue + 256 * green + red
For c = 1 To Len(text$)
    Locate 1, 1
    Print Mid$(text$, c, 1)
    Get (0, 0)-(7, 7), letter2()
    Put (x1 + 8 * (c - 1), y1), letter2(), PReset
    Put (0, 0), letter(), PSet
    _Limit 60
Next c
Return


infotext:
Locate 1, 1
Print String$(39, " ")
Locate 1, 20 - Int(Len(text$) / 2)
Color 15
Print text$
Return

coolbox:
For i = 0 To -8
    Line (x1 + i, y1 + i)-(x2 - i, y2 - i), fade(9 + i)
Next i
Return

'############################## Main Program #########################
mainprogram:

' --- Show main menu background
GoSub nulpal
Def Seg = &HA000
BLoad "main.spr", 0
Def Seg
fade = 1
a$ = "main.pal"
GoSub fadepal
mainmenu:
Def Seg = &HA000
BLoad "main.spr", 0
Def Seg
Get (0, 121)-(8, 192), robot()
' --- Set color
clr = 0
clradd = .1
' --- Move in menu
For x = -1.57 To 1.5707 Step .02
    Put (Int(80 * Sin(x)) + 80, 121), robot(), PSet
    _Limit 60
    GoSub colorchange
Next x

Color 250
Locate 18, 4: Print "New Game"
Locate 19, 4: Print "Instructions"
Locate 20, 4: Print "Credits"
Locate 21, 4: Print "Quit"

Do: Loop Until InKey$ = ""
menu = 1
clradd = .0001
GoSub showchange
menuloop:
a$ = InKey$
oldmenu = menu
If a$ <> "" Then
    If Asc(a$) = 27 Then GoTo gamequit
    If Asc(a$) = 13 Then GoTo menuselect
    If a$ = Chr$(0) + "H" Then menu = menu - 1
    If a$ = Chr$(0) + "P" Then menu = menu + 1
    If menu = 0 Then menu = 4
    If menu = 5 Then menu = 1
End If
If menu <> oldmenu Then GoSub showchange
GoSub colorchange
GoTo menuloop

' --- Draw little selection circles
showchange:
Line (6, 128 + oldmenu * 8)-(14, 138 + oldmenu * 8), 0, BF
Line (126, 128 + oldmenu * 8)-(134, 138 + oldmenu * 8), 0, BF
Circle (10, 132 + menu * 8), 4, 255
Paint (10, 132 + menu * 8), 186, 255
Circle (130, 132 + menu * 8), 4, 255
Paint (130, 132 + menu * 8), 186, 255
Return

' --- Change text color
colorchange:
clr = clr + clradd
Out &H3C8, 186
Out &H3C9, Int(31 + 30 * Sin(.6 * clr))
Out &H3C9, Int(31 + 30 * Sin(1.5 * clr + 1.5))
Out &H3C9, Int(31 + 30 * Sin(2 * clr + 2.2))
Return

menuselect:
If menu = 4 Then GoTo gamequit
a$ = "main.pal"
fade = 2
GoSub fadepal
If menu = 1 Then GoTo newgame
If menu = 2 Then GoTo instructions
If menu = 3 Then GoTo credits

instructions:
Def Seg = &HA000
BLoad "help.spr", 0
Def Seg
a$ = "help.pal"
fade = 3
GoSub fadepal
GoTo backtomenu

credits:
Def Seg = &HA000
BLoad "credits.spr", 0
Def Seg
a$ = "credits.pal"
fade = 3
GoSub fadepal
GoTo backtomenu

backtomenu:
Do: Loop Until InKey$ = ""
Do: Loop Until InKey$ <> ""
fade = 0
GoSub fadepal
GoTo mainprogram

newgame:
' ----- Do story -------
Def Seg = &HA000
BLoad "story0.spr", 0
Def Seg
' --- Fade in
a$ = "story0.pal"
fade = 3
GoSub fadepal
Sleep 1
Do: Loop Until InKey$ <> ""
' --- Fade out
a$ = "story0.pal"
fade = 0
GoSub fadepal
Def Seg = &HA000
BLoad "story1.spr", 0
Def Seg
' --- Fade in
a$ = "story1.pal"
fade = 1
GoSub fadepal
Sleep 1
Get (96, 52)-(124, 62), robot()
For x = -1.6 To 0 Step .01
    xv = Int(190 * Sin(x)) + 288
    Put (xv, 52), robot(), PSet
    _Limit 60
Next x
Put (xv, 52), robot()
Do: Loop Until InKey$ <> ""
' --- Fade out
a$ = "story1.pal"
fade = 0
GoSub fadepal
Def Seg = &HA000
BLoad "story2.spr", 0
Def Seg
' --- Fade in
a$ = "story2.pal"
fade = 1
GoSub fadepal
Sleep 1
Do: Loop Until InKey$ <> ""
' --- Fade out
a$ = "story2.pal"
fade = 0
GoSub fadepal
Def Seg = &HA000
BLoad "level.spr", 0
Def Seg
' --- Fade in
a$ = "level.pal"
fade = 1
GoSub fadepal
Locate 20, 3: Print "(1) Acid Mayhem"
Locate 21, 3: Print "(2) Mind Boggle"
Locate 23, 3: Print "Press the number of your choice"
Sleep 1
level1 = 0
level2 = 0
keyloop:
a$ = InKey$
If a$ <> "" Then
    If a$ = "1" Then level1 = 1: GoTo level1
    If a$ = "2" Then level2 = 1: GoTo level2
    If Asc(a$) = 27 Then a$ = "level.pal": GoTo mainprogram
End If
GoTo keyloop

level1:
Erase updown
Erase robot2
readlevel 1, 1
GoTo leveldone

level2:
Erase updown
Erase robot2
readlevel 2, 1

leveldone:
' --- Fade out
a$ = "level.pal"
fade = 2
GoSub fadepal

' ---- Get all sprites !! ----------

'--- Get sprites
'GOSUB nulpal
Def Seg = &HA000
BLoad "final.spr", 0
Def Seg
bc = Point(0, 48)
' --- Small walls etc...
Get (0, 0)-(19, 9), bh()
Get (0, 10)-(19, 19), wh()
Get (20, 0)-(29, 19), bv()
Get (30, 0)-(39, 19), wv()
Get (80, 60)-(99, 69), g8()
Get (80, 70)-(99, 79), g2()
Get (40, 0)-(59, 19), box()
Get (40, 100)-(59, 119), fruit(0)
Get (60, 100)-(79, 119), fruit(105)
Get (40, 120)-(59, 139), fruit(210)
Get (60, 120)-(79, 139), fruit(315)
Get (0, 40)-(19, 59), fruit(420)
Get (20, 40)-(39, 59), fruit(525)
Get (60, 160)-(79, 179), fruit(630)
Get (40, 76)-(79, 79), elevator()
Get (60, 0)-(68, 5), bull()
Get (40, 20)-(56, 48), robot()
Get (56, 20)-(72, 48), robot(150)
Get (63, 58)-(77, 70), robot(300)
Get (42, 51)-(60, 66), explosion()
Get (64, 82)-(78, 100), dead()
elesave = Point(45, 76)

Put (200, 160), elevator(), PSet

' --- All other objects
For ii = 0 To 7
    Get (0, 20 + ii * 20)-(19, 39 + ii * 20), objects(ii * 210)
    Get (20, 20 + ii * 20)-(39, 39 + ii * 20), objects(ii * 210 + 105)
Next ii

' --- Character
For x = 0 To 4
    Get (85, 4 + x * 40)-(98, 39 + x * 40), guy(x * 200)
Next x
For x = 0 To 4
    Get (101, 4 + x * 40)-(114, 39 + x * 40), guy(x * 200 + 1000)
Next x

' --- Get fading colors
For x = 81 To 89
    fade(x - 80) = Point(49, x)
Next x

' --- Begin game ------------------------ >>>>>>>>>>>>>

viewx = 0
viewy = 0
manx = 1.3
many = 1.1
xdir = 0
Erase oldplace

drawlevel viewx, viewy, manx, many, manpos

' --- Fade in
a$ = "final.pal"
fade = 3
GoSub fadepal

olddir = 1
mantimer = 0
jumpdir = 1
manpos = 1
anti = 0
sidestep = 0
redkey = 0
yellowkey = 0
shootwait = 0
fini = 0
SCORE = 0

' ------------------- Main Action loop ----------------
Do
    a$ = InKey$
    If mantimer > 3 Then mantimer = 0
    mantimer = mantimer + .2
    If mantimer > 0 Then manpos = 0
    If mantimer > 1 Then manpos = 3
    If mantimer > 2 Then manpos = 4
    manpos = manpos + (xdir + 1) / 2 * 5
    If xdir = 0 Then manpos = Int(4.5 + olddir * 2.5)
    If ydir <> 0 Then manpos = Int(2.5 + xdir * 2.5)
    If ydir <> 0 And xdir = 0 Then manpos = Int(2.5 + olddir * 2.5)
    shoot = shoot * 2
    xdir2 = xdir
    If xdir = 0 Then xdir2 = olddir
    If shoot > 0 Then manpos = 3.5 + 2.5 * xdir2
    If shoot > 10000 Then shoot = 0
    jump = 0
    If a$ <> "" Then
        If Asc(a$) = 27 Then GoTo dead
        If a$ = Chr$(0) + "K" Then GoSub guyleft
        If a$ = Chr$(0) + "M" Then GoSub guyright
        If a$ = "j" Or a$ = "J" Then GoSub guyjump
        If a$ = " " Then GoSub guyshoot
    End If
    p4 = Point(man(1) - 1, man(2) + 20)
    p6 = Point(man(1) + 14, man(2) + 20)
    p7 = Point(man(1) - 1, man(2) - 2)
    p9 = Point(man(1) + 14, man(2) - 2)
    p7s = Point(man(1) - 2, man(2) - 1)
    p9s = Point(man(1) + 15, man(2) - 1)
    p7z = Point(man(1) - 1, man(2) - 3)
    p9z = Point(man(1) + 14, man(2) - 3)
    p1 = Point(man(1) - 2, man(2) + 35)
    p3 = Point(man(1) + 14, man(2) + 35)
    p1z = Point(man(1) - 2, man(2) + 36)
    p3z = Point(man(1) + 14, man(2) + 36)
    p1s = Point(man(1) - 2, man(2) + 30)
    p3s = Point(man(1) + 15, man(2) + 30)

    ' --- Check to see if dead
    If p4 = 154 Or p6 = 145 Or p1 = 154 Or p3 = 154 Or p1z = 154 Or p3z = 154 Then GoTo dead

    ' --- Hit side
    If p7s + p4 + p1s <> 3 * bc Then olddir = -1: xdir = 0: manx = manx + .1: anti = -1
    If p9s + p6 + p3s <> 3 * bc Then olddir = 1: xdir = 0: manx = manx - .1: anti = 1
    sidestep = sidestep + 1
    If sidestep > 8 Then anti = 0: sidestep = 0
    ' --- Hit feet
    If p1z = bc And p3z = bc Then 'Fall
        fall = fall + 1
        If fall > 3 Then
            ydir = ydir + gravity
        Else
            many = many + .08
        End If
    Else ' Ground
        If jump = 0 Then ydir = 0
        fall = 0
    End If
    ' --- anti Ground stick
    If p1 + p3 <> 2 * bc Then many = many - .05
    ' --- Hit head
    If p7z + p9z <> 2 * bc Then ydir = 0: many = many + .05

    ' --- Assign move variables
    oldplace(2, 1) = manx
    oldplace(2, 2) = many
    For x = 1 To 19
        oldplace(x, 1) = oldplace(x + 1, 1)
        oldplace(x, 2) = oldplace(x + 1, 2)
    Next x
    many = many + ydir * .05
    manx = manx + xdir * .07

    ' --- Move elevator(s)
    For x = 1 To 4
        updown(x, 2) = updown(x, 2) + updown(x, 5)
        If updown(x, 2) > updown(x, 4) Or updown(x, 2) < updown(x, 3) Then updown(x, 5) = -updown(x, 5)
    Next x

    ' --- Move robot(s)
    For x = 1 To 4
        robot2(x, 1) = robot2(x, 1) + robot2(x, 5)
        If robot2(x, 1) > robot2(x, 4) Or robot2(x, 1) < robot2(x, 3) Then robot2(x, 5) = -robot2(x, 5)
    Next x

    ' --- Move bullit
    If bullit(1) > 0 Then
        bullit(1) = bullit(1) + bullit(3)
        If bullit(4) <> bc * 2 Then
            ' --- Check to see if monster was hit
            For i = 1 To 4
                If Abs(bullit(1) + .1 - robot2(i, 1) + .4) < 1.5 And Abs(bullit(2) + .1 - robot2(i, 2) + .8) < 1.5 Then
                    Play "mb " + explode$
                    robot2(i, 5) = 0
                End If
            Next i

            bullit(1) = 0
        End If
    End If
    shootwait = shootwait - 1

    ' --- Test for fruit get
    oldgx = gx
    oldgy = gy
    gx = Int(manx - .1)
    gy = Int(many)
    If gx <> oldgx Or gy <> oldgy Then GoSub check4fruit

    ' --- Test for key activiation and liquid kill
    manfx = manx + .2
    manfy = many + 1.9
    '--- Check ground
    If Int(manfx) = keys(1, 1) And Int(manfy) = keys(1, 2) And redkey = 1 Then GoSub movedoor1
    If Int(manfx) = keys(2, 1) And Int(manfy) = keys(2, 2) And yellowkey = 1 Then GoSub movedoor2
    'LOCATE 1, 1: PRINT INT(manfx), INT(manfy)

    ' --- Draw screen
    viewx = oldplace(1, 1) - 7
    viewy = oldplace(1, 2) - 5
    If viewx < 0 Then viewx = 0
    If viewy < 0 Then viewy = 0
    If viewx > 17 Then viewx = 17
    If viewy > 12 Then viewy = 12

    drawlevel viewx, viewy, manx, many, manpos

    _Limit 60
Loop
'                                                      ---------------

' --- Make guy die
dead:
Play "mb " + dies$
For x = 0 To 17
    Put (man(1), man(2) + x), dead(), PSet
    _Limit 60
Next x
Sleep 2
Do: Loop Until InKey$ = ""
GoTo fini

guyshoot:
If bullit(1) <> 0 Or shootwait > 0 Then Return
shoot = 1
bullit(1) = manx + xdir2 * .8 - .2
bullit(2) = many + .6
bullit(3) = xdir2 * .1
bullit(4) = bc * 2
shootwait = 50
Return

movedoor1:
Play "mb t225 o5 l40 bagfedc o4 bagfedc"
For y = keys(1, 4) To keys(1, 5)
    grid$(keys(1, 3), y, 1) = "12"
    keys(1, 1) = 0
Next y
Return

movedoor2:
Play "mb t225 o5 l40 bagfedc o4 bagfedc"
For y = keys(2, 4) To keys(2, 5)
    grid$(keys(2, 3), y, 1) = "12"
    keys(2, 1) = 0
Next y
Return

'--- Move subs
guyleft:
If anti = -1 Then Return
p1s2 = Point(man(1) - 3, man(2) + 30)
If xdir > -1 And p1s2 = bc Then olddir = xdir: xdir = xdir - 1
anti = 0
Return

guyright:
If anti = 1 Then Return
p3s2 = Point(man(1) + 15, man(2) + 30)
If xdir < 1 And p3s2 = bc Then olddir = xdir: xdir = xdir + 1
anti = 0
Return

guyjump:
If ydir <> 0 Then Return
ydir = -3
jump = 1
Return

check4fruit:
If Left$(grid$(gx, gy, 1), 1) = "f" Then GoSub getfruit0
If Left$(grid$(gx + 1, gy, 1), 1) = "f" Then GoSub getfruit1
If Left$(grid$(gx, gy + 1, 1), 1) = "f" Then GoSub getfruit2
If Left$(grid$(gx + 1, gy + 1, 1), 1) = "f" Then GoSub getfruit3
Return

getfruit0:
num = Val(Right$(grid$(gx, gy, 1), 1))
grid$(gx, gy, 1) = "12"
GoSub points
Return

getfruit1:
num = Val(Right$(grid$(gx + 1, gy, 1), 1))
grid$(gx + 1, gy, 1) = "12"
GoSub points
Return

getfruit2:
num = Val(Right$(grid$(gx, gy + 1, 1), 1))
grid$(gx, gy + 1, 1) = "12"
GoSub points
Return

getfruit3:
num = Val(Right$(grid$(gx + 1, gy + 1, 1), 1))
grid$(gx + 1, gy + 1, 1) = "12"
GoSub points
Return

points:
If num < 4 Then
    SCORE = SCORE + 10 * num + 10
    Play "mb t220 L60 o3co4c"
Else
    If num = 4 Then redkey = 1
    If num = 5 Then yellowkey = 1
    If num = 6 Then GoTo win
    Play "mb t220 l10 cdefgab"
End If
Return

fini:
fini = 1
win:
' --- Fade out
a$ = "final.pal"
fade = 0
GoSub fadepal
Def Seg = &HA000
BLoad "results.spr", 0
Def Seg
Line (129, 0)-(286, 30), 0, BF
Line (2, 30)-(239, 57), 0, BF
a$ = "results.pal"
fade = 1
GoSub fadepal
Locate 16, 2
If fini = 1 Then
    Play "mb " + lose$
    Print "You are unconscious and"
    Locate 17, 2: Print "the world is taken over!"
    level1 = 0
    level2 = 0
Else
    Play "mb " + win$
    Print "Congratulations!"
    Locate 17, 2: Print "You beat the the level."
    Locate 18, 2: Print "Your score totaled"; SCORE; "."
    level1 = level1 + 1
    level2 = level2 + 1
End If
Do: Loop Until InKey$ = ""
Do: Loop Until InKey$ <> ""
If level1 = 1 Then GoTo level1
If level2 = 1 Then GoTo level2
If level1 >= 2 And level2 >= 2 Then Locate 20, 2: Print "You've saved the earth!": Play "mb " + select$
GoTo backtomenu

' ------------

gameexit:
gamequit:
System

DataForMouse:
Data 55,8b,ec,56,57,8b,76,0c,8b,04,8b,76,0a,8b,1c,8b,76,08,8b,0c,8b,76,06,8b
Data 14,cd,21,8b,76,0c,89,04,8b,76,0a,89,1c,8b,76,08,89,0c,8b,76,06,89,14,5f
Data 5e,5d,ca,08,00

namesdata:
Data Sean Weeks,Kevin,Troy,Chris Igaz,Adrien,Eric,Alan,Micheal,Jason
Data Maranatha,Brittany,Melissa,Mr. Hirsch,Arianna,Brittany,Matthew
Data Mr. Smith,Danny,Nancy,Anthony,Pamela,Mark,Matthew,Timothy
Data Marita,Amy Joe,Nathan,Bob,Billy,William,Jonathan,Charles,end

leveldata:
Data 152
Data 161
Data 5,16,6,14,15
Data 16,19,17,17,18
Data .,.,.,.,.,.,.,f0,f0,f1,f1,.,.,8,f6,.,.,.,.,.,.,f3,.,.,.,.,.,.,.,.,5,5
Data .,.,.,.,.,.,.,.,.,.,.,.,.,8,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.
Data 7,7,7,7,.,.,.,.,.,.,.,.,.,8,6,6,.,.,.,.,.,8,.,.,.,8,.,.,.,.,.,.
Data f4,.,.,8,.,.,1,.,.,.,.,$,.,.,.,l,g,.,.,.,.,8,8,8,8,8,.,.,.,.,.,.
Data .,.,.,8,6,6,6,6,6,6,6,.,.,.,.,l,8,8,.,.,.,.,.,.,.,.,.,e,.,.,.,.
Data 6,.,.,.,.,.,.,.,.,.,.,.,.,.,.,l,8,8,8,.,.,.,.,.,.,.,.,.,.,.,.,.
Data 8,.,.,.,.,.,.,.,.,.,.,.,.,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,e,.,.
Data 8,6,.,.,.,.,.,e,e,f3,.,.,.,.,.,8,f1,f1,.,.,.,.,.,.,.,.,.,.,.,.,.,e
Data 8,.,.,.,8,8,9,9,9,9,8,a,a,a,a,8,f1,f1,.,.,.,.,.,.,.,.,.,.,.,.,.,.
Data 8,.,.,6,8,8,d,d,d,d,8,8,8,8,8,8,8,8,8,8,.,.,6,6,6,6,6,6,6,6,6,6
Data 8,.,.,8,8,8,d,d,d,d,8,.,.,.,.,.,f5,.,.,8,8,.,.,.,.,.,.,.,.,.,f3,.
Data 8,6,.,.,.,8,d,d,d,d,8,.,.,.,.,.,2,.,.,8,.,.,.,.,.,.,.,.,.,.,f3,.
Data 8,.,.,.,.,8,8,8,8,8,8,.,.,.,8,8,8,.,.,8,6,6,6,6,.,.,.,.,.,.,.,.
Data 8,.,.,.,.,b,.,.,.,.,.,.,.,#,.,.,.,.,.,8,8,8,8,8,.,.,.,.,.,e,.,.
Data 8,6,6,.,.,b,.,.,.,.,.,.,8,.,.,.,.,.,.,8,8,8,8,8,8,$,.,.,.,.,.,.
Data 8,8,8,6,6,6,6,.,.,.,6,5,5,6,6,6,6,6,6,8,8,8,8,8,8,.,.,.,.,.,e,.
Data 8,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,b,.,.,.,.,.,.,.,.,.,.,8,.,.,.,.
Data 8,#,.,.,.,.,.,.,e,.,.,.,.,.,.,.,b,.,.,.,.,.,.,.,.,.,.,.,.,e,.,.
Data 8,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,6,6,6,6,6,6,6,6,6,.,.,6,.,.,.,.
Data 8,6,6,6,6,6,6,6,6,6,6,9,9,6,6,6,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
Data .,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.

Data 151
Data 161
Data 9,14,10,10,13
Data 9,5,8,1,4
Data .,.,.,l,.,.,.,b,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,l,f3,f3,.
Data .,.,.,l,.,.,.,b,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,l,f3,f3,.
Data 6,6,.,l,.,f6,.,b,.,.,.,.,.,.,e,e,.,.,.,.,.,.,.,.,.,.,.,.,l,.,.,.
Data .,.,.,l,.,.,.,b,.,.,e,e,e,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,l,.,.,.
Data .,.,.,l,6,6,6,6,6,6,a,a,a,a,a,a,6,6,6,6,6,6,6,6,6,6,.,.,l,.,8,.
Data .,6,6,6,.,.,.,.,.,8,8,8,8,8,8,8,8,.,.,.,.,.,.,.,.,.,.,.,l,.,.,.
Data .,.,f3,l,.,.,.,.,.,8,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,$,.,l,.,.,.
Data .,.,.,.,.,.,.,.,.,8,.,.,.,.,.,.,.,.,.,.,.,.,1,.,.,.,.,.,.,8,.,.
Data e,.,.,.,.,.,.,.,.,8,.,.,$,.,6,6,6,6,6,.,.,5,5,5,5,5,.,.,.,.,.,.
Data a,a,6,6,.,.,.,.,.,b,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,f5,.
Data 8,8,8,8,.,.,.,.,.,b,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,6,6,6,.
Data .,.,.,.,.,.,.,.,.,b,.,.,.,.,.,.,5,$,.,5,5,5,5,.,f3,f3,.,.,.,.,.,.
Data .,.,.,.,.,.,.,.,.,b,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,f1,f2,.
Data .,.,.,.,5,5,5,5,5,8,.,.,.,.,.,.,.,f3,f3,.,.,.,.,.,.,.,.,.,.,f1,f2,.
Data .,.,$,.,f4,.,.,.,l,5,5,5,.,.,.,.,.,.,.,.,.,.,.,.,#,.,.,.,.,.,.,.
Data .,.,.,.,.,.,.,.,l,.,.,.,.,.,f1,.,.,f2,.,.,f3,.,.,.,.,.,.,.,.,.,.,.
Data .,.,.,.,f2,.,.,.,.,.,.,.,.,e,.,e,e,.,e,e,.,e,e,5,5,5,5,5,5,5,5,5
Data .,.,.,.,.,.,.,.,2,.,.,.,e,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.
Data .,.,.,.,8,.,.,.,8,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.
Data 7,7,7,7,7,a,a,a,7,7,7,7,7,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,.
Data .,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.

Sub drawlevel (viewx, viewy, manx, many, manpos)

    elenum = Int(updown(1, 2))
    robonum = Int(robot2(1, 2))

    monster(1) = monster(1) + .5
    If monster(1) > 10 Then monster(1) = 0

    xt = (viewx - Int(viewx)) * 20
    yt = (viewy - Int(viewy)) * 20

    obj1 = 0
    xzb = bullit(1) * 20 - xt - Int(viewx) * 20
    yzb = bullit(2) * 20 - yt - Int(viewy) * 20
    If xzb > 0 And xzb < 280 And yzb > 0 And yzb < 180 Then obj1 = 1

    obj2 = 0
    xz = manx * 20 - xt - Int(viewx) * 20
    yz = many * 20 - yt - Int(viewy) * 20
    If xz > 0 And xz < 300 And yz > 0 And yz < 162 Then obj2 = 1
    man(1) = xz
    man(2) = yz

    ' --- Read each line of data
    For y = 1 To 9
        For x = 1 To 15
            item$ = grid$(x + Int(viewx), y + Int(viewy), 1)
            xc = x * 20
            yc = y * 20
            xd = xc - xt
            yd = yc - yt
            Select Case item$
                Case "w4"
                    Put (xd, yd), bv(), PSet
                Case "w6"
                    Put (xd + 10, yd), bv(), PSet
                Case "w8"
                    Put (xd, yd), bh(), PSet
                Case "w2"
                    Put (xd, yd + 10), bh(), PSet
                Case "wq"
                    Put (xd, yd), g8(), PSet
                Case "wa"
                    Put (xd, yd), g2(), PSet
            End Select
            If Left$(item$, 1) = "f" Then Put (xd, yd), fruit(105 * Val(Right$(item$, 1))), PSet

            If Val(item$) > 0 And Val(item$) < 17 Then
                Put (xd, yd), objects((Val(item$) - 1) * 105), PSet
            End If

            If y = 1 Then Put (xc - 20, 0), box(), PSet
            If y = 9 Then Put (xc - 20, 180), box(), PSet
            If x = 1 Then Put (0, yc - 20), box(), PSet
            If x = 15 Then Put (300, yc - 20), box(), PSet
        Next x
        If y + viewy > Int(many) - 1 Then GoSub man
        If y + viewy > elenum - 1 Then GoSub elevator
        If y + viewy > robonum - 1 Then GoSub robot
        bull = 0
        If obj1 = 1 Then Put (xzb, yzb), bull(), PSet: bull = 1
        If bull = 0 Then bullit(1) = 0
    Next y

    Put (300, 180), box(), PSet
    GoTo done

    man:
    xz = manx * 20 - xt - Int(viewx) * 20
    yz = many * 20 - yt - Int(viewy) * 20
    If obj2 = 1 Then Put (xz, yz), guy(manpos * 200), PSet
    man(1) = xz
    man(2) = yz
    Return

    elevator:
    For i = 1 To 4
        xz = updown(i, 1) * 20 - xt - Int(viewx) * 20
        yz = updown(i, 2) * 20 - yt - Int(viewy) * 20
        If xz > 0 And xz < 280 And yz > 0 And yz < 180 Then Put (xz, yz), elevator(), PSet
    Next i
    Return

    robot:
    For i = 1 To 4
        xz = robot2(i, 1) * 20 - xt - Int(viewx) * 20
        yz = robot2(i, 2) * 20 - yt - Int(viewy) * 20
        If xz > 15 And xz < 290 And yz > 0 And yz < 165 Then
            If robot2(i, 5) = 0 Then
                Put (xz, yz + 16), robot(300), PSet
            Else
                If monster(1) > 4 Then Put (xz, yz), robot(), PSet
                If monster(1) < 5 Then Put (xz, yz), robot(150), PSet
            End If
        End If
    Next i
    Return

    done:
    If bull = 1 Then bullit(4) = Point(xzb - 1, yzb) + Point(xzb + 10, yzb + 6)
    'PRINT POINT(zxb - 1, yzb); POINT(xzb + 10, yxb + 6)


End Sub

Sub readlevel (level, section)

    Restore leveldata
    ' --- Find Level
    Do
        Read n$
    Loop Until Val(n$) = 15 * 10 + level
    ' --- Find section
    Do
        Read n$
    Loop Until Val(n$) = 16 * 10 + section
    elevator.num = 0
    robot.num = 0

    For i = 1 To 2
        For ii = 1 To 5
            Read keys(i, ii)
        Next ii
    Next i

    For y = 1 To 21
        For x = 1 To 32
            Read item$
            If item$ = "a" Then item$ = "10"
            If item$ = "b" Then item$ = "11"
            If item$ = "d" Then item$ = "13"
            If item$ = "e" Then item$ = "14"
            If item$ = "l" Then item$ = "15"
            If item$ = "g" Then item$ = "16"
            If item$ = "$" Then
                elevator.num = elevator.num + 1
                updown(elevator.num, 1) = x
                updown(elevator.num, 2) = y
                updown(elevator.num, 3) = y
                updown(elevator.num, 4) = y + 4.8
                updown(elevator.num, 5) = .04
            End If
            If item$ = "#" Then
                robot.num = robot.num + 1
                robot2(robot.num, 1) = x
                robot2(robot.num, 2) = y + .55
                robot2(robot.num, 3) = x
                robot2(robot.num, 4) = x + 5
                robot2(robot.num, 5) = .05
                robot2(robot.num, 6) = 1
            End If
            If item$ = "." Or item$ = "$" Or item$ = "#" Then item$ = "12"
            grid$(x, y, 1) = item$
        Next x
    Next y

End Sub

