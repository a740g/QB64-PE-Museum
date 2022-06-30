'Rem - written for QBasic / QuickBasic (freeware) -
'Rem - V.26
'Rem - by Daniel Kupfer
'Rem - for more info look at the end / press f1 in title
'Rem - any problems / questions ? mail: dk1000000@aol.com

$Resize:Smooth

Screen 7
_FullScreen _SquarePixels , _Smooth

DefInt A-Z
scx = 159: scy = 99
xp = scx: yp = 172: vp = 6: vsh = 6
xpmin = 0: xpmax = 319: shmax = 15: emax = 7: esmax = 3: fmax = 15
stmax = 31: exmax = 7
SND = 1: bonplay& = 20000
pi! = 3.14158: pi2! = pi! / 2: pi4! = pi! / 4
cts1 = 0: cts2 = 4: cts3 = 10

Dim tae(201), tne(201): n = shmax
Dim xsh(n), ysh(n): n = stmax
Dim xst(n), yst(n), xst!(n), yst!(n), cst(n), vst(n): n = emax
Dim xe!(n), ye!(n), ae(n), dae(n), ne(n), ce(n), ste(n)
Dim ze(n), zze(n), tpe(n), tce(n): n = exmax
Dim xex(n), yex(n), stex(n), zex(n), tex(n): n = esmax
Dim xes!(n), yes!(n), dxes!(n), dyes!(n), stes(n), tes(n)
Dim aes(n), des(n): n = fmax
Dim fx!(n), fy!(n), dfx!(n), dfy!(n), fc(n), ft(n): n = 11
Dim ptse(n), dble(n), anie(n), adde(n), zoome(n)
Dim table(n), c1e(n), c2e(n), expe(n), c1ee(2, n), c2ee(2, n): n = 7
Dim tce0(n), xec(n), yec(n), aec(n): n = 12
Dim xc!(n), yc!(n), zc!(n), cc(n), ac(n), nc(n)
Dim ENEMY$(20, 3), CRASH$(4), bin(4), CH$(42): n = 7
Dim vbos(n), vsbos(n), tsbos(n), fsbos(n), ptsbos(n), hrbos(n)
Dim BOSS$(n), STAGE$(n)
Dim cp(95), SFINAL$(2, 9), CREDIT$(50)
A5$ = String$(4, Chr$(170)) + String$(4, Chr$(85))
     
For e = 1 To 11: Read p, d, m, a, z, T, ex
    ptse(e) = p: dble(e) = d: anie(e) = m: adde(e) = a: zoome(e) = z
table(e) = T: expe(e) = ex: Next e
Data 10,0,0,0,64,1,1,20,0,0,0,64,2,1,25,0,0,0,64,2,1
Data 40,0,0,0,64,5,1,50,0,0,0,64,4,1,200,0,0,0,64,6,1
Data 250,0,0,0,64,7,1,100,1,0,1,64,2,1,120,0,0,0,64,3,1
Data 120,1,3,1,64,2,1,160,0,2,0,48,3,1

For s = 0 To 2
For e = 1 To 11: Read c1, c2: c1ee(s, e) = c1: c2ee(s, e) = c2: Next e: Next s
Data 7,13,6,14,5,15,5,11,3,15,2,10,2,10,4,12,1,14,2,14,9,15
Data 4,13,2,10,1,4,7,15,4,14,3,11,3,11,5,13,2,15,2,14,9,15
Data 5,14,3,11,2,14,12,14,14,4,4,12,4,12,6,14,3,15,6,14,4,12

Rem  - - - - BOSS SETUP - - - - - -

For n = 1 To 7: Read a$, s$: BOSS$(n) = a$: STAGE$(n) = s$: Next n
Data "MYKOR MASTER","VEGA SYSTEM","PHOENIX","ALPHA CENTAURI"
Data "EVIL BATSY","DARK PLANET","QUARRIOR","AQUARUIS"
Data "MC FISHKING","NEPTUN","BEEBOP QUEEN","MOONBASE"
Data "MOTHERSHIP","EARTH"
For n = 1 To 7: Read v, ts, f, p, r: vbos(n) = v: tsbos(n) = ts
fsbos(n) = f: ptsbos(n) = p: hrbos(n) = r: Next n
Data 1,1,4,1000,20,1,4,6,2500,20,2,1,8,4000,20,1,5,10,7500,20
Data 1,3,100,10000,24,2,2,10,16000,20,1,0,0,25000,40
For n = 0 To 3: Read c: csb(n) = c: Next n
Data 4,12,14,10

Rem  - - - - ESHOT SETUP - - - -
For n = 1 To 5: Read v, d: ves(n) = v: ses(n) = d: Next n
Data 5,2,4,2,2,4,3,2,3,2

n = 1
Do: Read a, T: tae(n) = a: tne(n) = T: n = n + 1
Loop Until a = -1 And T = -1
nte = n - 1
PATTERN1:
Data 0,100,-900,1,0,32,-900,1,0,50,-900,1,0,8,-900,1
Data 0,70,900,1,0,10,900,1,0,50,-900,1,30,60,0,90
Data 30,30,0,50,900,1,0,14,900,1,0,20,900,1,0,16
Data 900,1,0,20,900,1,0,14,900,1,0,20,900,1,0,16
Data 900,1,0,20,900,1,0,14,900,1,0,40,900,2,0,0
PATTERN2:
Data -30,30,30,75,0,34,-30,95,0,34,30,95,0,34,-30,95
Data 0,34,30,95,0,34,-30,95,0,34,30,50,0,25,30,30
Data 0,60,60,30,0,110,-60,31,0,90,60,31,0,60,-60,32
Data 0,30,60,32,30,28,0,20,0,0,0,0,0,0,0,0
PATTERN3:
Data -90,20,90,30,-90,30,90,20,-90,20,90,40,90,10,-90,20
Data 90,20,-90,30,90,20,-90,20,90,20,-90,21,0,20,0,0
Data 90,20,-90,30,90,30,-90,20,90,20,-90,40,-90,10,90,20
Data -90,20,90,30,-90,20,90,20,-90,20,90,21,0,20,0,0
PATTERN4:
Data 30,60,-30,-30,30,60,0,40,30,20,0,30,30,90,-30,90
Data -30,90,30,45,0,20,-30,15,0,10,30,15,-30,15,30,15
Data 0,80,30,5,0,40,30,5,0,40,30,5,0,40,30,5
Data 0,40,30,180,0,120,0,0,0,0,0,0,0,0,0,0
PATTERN5:
Data 0,130,30,60,0,105,90,20,0,60,-90,20,0,20,90,20
Data 0,60,90,10,0,80,90,20,0,80,-90,20,0,80,90,20
Data 0,60,30,270,0,50,0,0,0,0,0,0,0,0,0,0
PATTERN6:
Data -30,85,0,50,30,0,-30,80,0,60,30,80,0,60,-30,80
Data 0,60,30,80,0,60,-30,80,0,60,30,50,0,25,30,30
Data 0,60,60,30,0,110,-60,31,0,90,60,31,0,60,-60,32
Data 0,30,60,32,30,28,0,20,0,0,0,0,0,0,0,0
PATTERN7:
Data -30,60,0,80,0,0,0,0,30,60,0,80,0,0,0,0
Data -1,-1

For n = 1 To 7: Read T, x, y, a, v, c: tce0(n) = T: xec(n) = x: yec(n) = y
aec(n) = a: vec(n) = v: crec(n) = c: Next n
Data 0,0,20,0,4,7,40,159,119,900,4,7
Data 72,159,119,900,4,7,104,149,109,900,4,7
Data 136,320,20,1800,4,7
Data 160,159,50,900,4,7,192,159,50,900,4,7

For n = 0 To 9: Read x, y: pcx(n) = x: pcy(n) = y: Next n
Data 0,-2,-10,-2,10,-2,-10,3,10,3
Data 0,-5,-14,-4,14,-4,-14,3,14,3

Randomize Timer
GoSub LOAD.SPRITES
GoSub LOAD.SOUNDS
GoSub LOAD.CHARSET

For n = 0 To shmax: ysh(n) = -1: Next n
For n = 0 To stmax: GoSub CREATE.STAR: Next n
For n = 0 To emax: ste(n) = -1: ce(n) = 2: Next n
For n = 0 To esmax: stes(n) = -1: Next n


Rem - - - - - - - - TITLE SCREEN - - - - - - - -
x = -40: zmax = 40
For n = 0 To 7: Read nc, cc
    xc!(n) = x: yc!(n) = 26: zc!(n) = 200: nc(n) = nc: cc(n) = cc
x = x + 7: Next n
For n = 8 To 9: Read nc, cc
    xc!(n) = x + 55: yc!(n) = yc!(1) + 30: zc!(n) = zmax: nc(n) = nc: cc(n) = cc
x = x + 7: Next n
Data 29,15,31,15,31,15,30,15,19,15,34,15,17,15,32,15,9,15,9,15

Rem  - - - LEVEL SETUP - - -
For n = 1 To 9: Read T, r, s, h
ltpe(n) = T: lrad(n) = r: lsum(n) = s: lhit(n) = h: Next n
Data 1,14,1,1,1,14,2,1,2,12,2,1,3,12,2,1
Data 4,12,2,1,5,14,2,1,8,16,1,3,10,14,1,3
Data 6,12,4,1

Restore CREDITS
For n = 1 To 34: Read a$: CREDIT$(n) = a$: Next n

x = 100: y = 100: c1 = 6: c2 = 14: a = 0: z = 4
e = 6: f = 0: GoSub DRAW.ESPRITE
Rem END
 
GoSub WAITKEY0: GoSub TITLE

STAGE = 1: LEVEL = 1: stbos = -1: tbos = 1
GoSub LOAD.LEVEL
Rem                        ---> player setup
ssec(1) = 1: ssec(2) = 0: ssec(3) = 0: GoSub SETUP.SHIP
stp = 0: Rem status player
score& = 0
GoSub DRAW.PLAYER1
n = Int(2 * Rnd)
If n = 0 And SND = 1 Then Play SLAUNCH$
If n = 1 And SND = 1 Then Play SNEWPL1$
GoSub WAITFIRE: Rem GOTO GAME.FINISH
GoSub ENTER.STAGE

MAIN:
Do
    k0 = k: k = Inp(96): k$ = InKey$
    If k = 1 Then System
    If k = 31 Then SND = 1 - SND: GoSub WAITKEY0
    If k = 25 Then GoSub PAUSE.MODE
    If k = 29 And k0 <> 29 Then GoSub FIRE.SHOT
    GoSub KEYS
    GoSub MOVE.PLAYER
    GoSub MOVE.SHOT
    GoSub MOVE.ENEMY
    GoSub MOVE.BOSS
    GoSub MOVE.ESHOT
    GoSub REFR.SCREEN
    Wait &H3DA, 8: Wait &H3DA, 8, 8
    GoSub DRAW.ESHOT
    GoSub DRAW.ENEMY
    GoSub DRAW.BOSS
    GoSub TEST.HIT.SHOT
    GoSub TEST.HIT.PLAYER
    GoSub DRAW.SHOT
    GoSub DRAW.EVENT
    GoSub DRAW.PLAYER
    GoSub DRAW.EXP
    GoSub DRAW.STAR
    Locate 1, 30: Print score&
    GoSub CREATE.ESHOT
    crec1 = crec1 - 1: If crec1 = 0 Then crec1 = crec0: GoSub CREATE.ENEMY
    cnt1 = (cnt1 + 1) And 255
    GoSub BINARY.CNT
    GoSub TEST.LEVELEND
    Rem GOSUB DOCKING

    _Limit 60
Loop


MOVE.BOSS:
If stbos < 0 Then Return
xbos! = xbos! + dxbos!: ybos! = ybos! + dybos!
If hbos = 1 And ybos! > 10 And tbos < 7 Then ybos! = ybos! - 3
If xbos! < 10 Then dxbos! = 1
If xbos! > 309 Then dxbos! = -1
If ybos! < 10 Then dybos! = 1
If ybos! > 99 Then dybos! = -1
GoSub SHOT.BOSS
If Int(100 * Rnd) < 1 Then GoSub ACTIV.BOSS
Return

SHOT.BOSS:
If tbos = 7 Then GoTo SHOT.SUPERBOSS
r = fsbos(tbos) * STAGE
If Int(1000 * Rnd) > r Then Return
x = xbos!: y = ybos!: T = tsbos(tbos): s = ses(T)
If T = 3 Then s = 2 + Int(5 * Rnd)
GoSub FIRE.ESHOT
Return

SHOT.SUPERBOSS:
GoSub CREATE.SUPERENEMY
Return

CREATE.SUPERENEMY:
If Int(8 * Rnd) > 0 Then Return
n = (eptr + 1) And emax: If ste(n) <> -1 Then Return
T = tpe + 1: mt = table(T)
ye!(n) = ybos!: ae(n) = 900 + 180 * Rnd - 90
xe!(n) = xbos!
ze(n) = 64: zze(n) = zoome(T)
ste(n) = 0: tpe(n) = T
tce(n) = tce0(mt) + Int(2 * Rnd) * 4
GoSub LOADPTR.ENEMY
Return

ACTIV.BOSS:
a! = Int(8 * Rnd) * pi4!
dxbos! = Cos(a!) * vbos(tbos): dybos! = Sin(a!) * vbos(tbos)
If tbos = 7 Then dybos! = 0
Return

DRAW.BOSS:
If stbos = -1 Then Return
If stbos < 0 Then GoTo DRAW.BOSS1
x = xbos!: y = ybos!
On tbos GOSUB DBOSS1, DBOSS2, DBOSS3, DBOSS4, DBOSS5, DBOSS6, DBOSS7
If bin(1) = 0 Then hbos = 0
Return
DRAW.BOSS1:
stbos = stbos + 1: GoSub DRAW.BDOTS
If stbos < -100 And SND = 1 Then Sound 37 + 120 * Rnd, .4
If stbos = -90 Then GoTo DRAW.BOSS2
If stbos > -96 And stbos < -48 And Play(0) = 0 And SND = 1 Then Play SBOSPTS$
Return
DRAW.BOSS2:
For e = 0 To emax: ste(e) = -1: Next e: cresum = 0
pts& = ptsbos(tbos): GoSub LOAD.SCORE
evcnt = 50: evpts = pts&: evtpe = 1
Return
                   
DRAW.BDOTS:
For m = 0 To fmax
    x = fx!(m): y = fy!(m)
    Line (x, y)-(x + 1, y + 1), fc(m), BF
    fx!(m) = fx!(m) + dfx!(m): fy!(m) = fy!(m) + dfy!(m)
Next m
Return

DRAW.EVENT:
If evcnt <= 0 Then Return
evcnt = evcnt - 1: yc! = 70: ac = 0: sc = 4: T$ = evtxt$
If evtpe = 1 Then xc! = 160: i = evpts: cc = 15 * Rnd: GoSub DRAW.INTF
If evtpe = 2 Then xc! = 159 - Len(T$) * 4: cc = 15: GoSub DRAW.TXTZ
Return

BINARY.CNT:
bin(1) = 1 - bin(1): b2 = bin(2): b3 = bin(3)
If bin(1) = 0 Then bin(2) = 1 - bin(2)
If bin(2) < b2 Then bin(3) = 1 - bin(3)
If bin(3) < b3 Then bin(4) = 1 - bin(4)
Return

TEST.LEVELEND:
If emovcnt > 0 Or expcnt > 0 Or stbos <> -1 Then etimer = 0: Return
etimer = etimer + 1: If etimer < 25 Then Return
etimer = 0
If (LEVEL And 7) = 5 Then GoSub DOCKING: Rem level 3 + 7
GoSub ADVANCE.LEVEL
GoTo MAIN

PAUSE:
Do: Wait &H3DA, 8: Wait &H3DA, 8, 8: c = c - 1: Loop Until c = 0
Return

WAITFIRE:
GoSub WAITKEY0
t0! = Timer
Do
    k = Inp(96): k$ = InKey$
    t1! = Timer - t0!
Loop Until k = 29 Or t1! > 4
GoSub WAITKEY0
Return

KEYS:
Rem IF k0 = 75 OR k0 = 77 THEN RETURN
If k = 75 Then dxp = -vp: k1 = 203
If k = 77 Then dxp = vp: k1 = 205
If k = k1 Then dxp = 0
Return

MOVE.PLAYER:
If stp < 0 Then GoTo CREATE.PLAYER
xp = xp + dxp
If xp > xpmax Then xp = xpmax
If xp < xpmin Then xp = xpmin
Return

CREATE.PLAYER:
If stp < -1 Then Return
stp = 0: f = 0
For q = 1 To 3
    If ssec(q) > -1 Then f = 1
    If ssec(q) = 0 Then ssec(q) = 1: f = 1: Exit For
Next q
If f = 0 Then stp = 1
If f = 1 And SND = 1 Then Play SNEWPL2$
GoSub SETUP.SHIP
Return

SETUP.SHIP:
sss0 = 0: sss1 = 0: s = 0
If ssec(1) = 1 Then s = s Or 1
If ssec(2) = 1 Then s = s Or 2
If ssec(3) = 1 Then s = s Or 2
If s = 3 Then sss0 = 1
If s = 2 Then sss1 = 1
Return

FIRE.SHOT:
If stp > 0 Then Return
If sss0 = 1 Then sss1 = 1 - sss1
If sss1 = 0 And ssec(1) = 1 Then GoSub FIRE.SHOT1: s = 1
If sss1 = 1 And ssec(2) = 1 Then GoSub FIRE.SHOT2: s = 2
If sss1 = 1 And ssec(3) = 1 Then GoSub FIRE.SHOT3: s = 2
Return
FIRE.SHOT1:
If ysh(cts1) > 0 Then Return
xsh(cts1) = xp: ysh(cts1) = yp - 4
cts1 = cts1 + 1: If cts1 = 4 Then cts1 = 0
If Play(0) = 0 And SND = 1 Then Play SLASER1$
Return
FIRE.SHOT2:
If ysh(cts2) > 0 Or ysh(cts2 + 1) > 0 Then Return
xsh(cts2) = xp - 9: ysh(cts2) = yp + 3
xsh(cts2 + 1) = xp + 9: ysh(cts2 + 1) = yp + 3
cts2 = cts2 + 2: If cts2 = 10 Then cts2 = 4
If Play(0) = 0 And SND = 1 Then Play SLASER2$
Return
FIRE.SHOT3:
If ysh(cts3) > 0 Or ysh(cts3 + 1) > 0 Then Return
xsh(cts3) = xp - 14: ysh(cts3) = yp + 10
xsh(cts3 + 1) = xp + 14: ysh(cts3 + 1) = yp + 10
cts3 = cts3 + 2: If cts3 = 16 Then cts3 = 10
If Play(0) = 0 And SND = 1 Then Play SLASER2$
Return

REFR.SCREEN:
Wait &H3DA, 8, 8: Wait &H3DA, 8
scr = 1 - scr: Screen 7, 0, 1 - scr, scr: Cls
Return
REFR.DOCKSCREEN:
Wait &H3DA, 8, 8: Wait &H3DA, 8
scr = 1 - scr: Screen 7, 0, 1 - scr, scr
View (1, 25)-(318, 198), 0, 0: View
Return

MOVE.SHOT:
For n = 0 To shmax: ys = ysh(n)
    If ys < 0 Then GoTo MOVE.SHOT1
    ys = ys - vsh: ysh(n) = ys
    MOVE.SHOT1:
Next n

MOVE.ENEMY:
emovcnt = 0
For n = 0 To emax
    If ste(n) < 0 Then GoTo MOVE.ENEMY1
    ne(n) = ne(n) - 1: If ne(n) <= 0 Then GoSub LOADPTR.ENEMY
    a! = ae(n) * (pi! / 1800): emovcnt = emovcnt + 1
    dx! = Cos(a!) * vec: dy! = -Sin(a!) * vec
    xe!(n) = xe!(n) + dx! / 2: ye!(n) = ye!(n) + dy! / 2
    ae(n) = (ae(n) + dae(n)) Mod 3600
    If ze(n) < zze(n) Then ze(n) = ze(n) + 1
    If Abs(xe!(n) - scx) > 180 Or Abs(ye!(n) - scy) > 120 Then GoSub RESET.ENEMY
    MOVE.ENEMY1:
Next n
Return
 
MOVE.ESHOT:
For n = 0 To esmax
    If stes(n) < 0 Then GoTo MOVE.ESHOT1
    xes!(n) = xes!(n) + dxes!(n): yes!(n) = yes!(n) + dyes!(n)
    aes(n) = aes(n) + 1
    If Abs(xes!(n) - scx) > 160 Or Abs(yes!(n) - scy) > 100 Then stes(n) = -1
    MOVE.ESHOT1:
Next n
Return

DRAW.ESHOT:
For n = 0 To esmax
    If stes(n) < 0 Then GoTo DRAW.ESHOT1
    x = xes!(n): y = yes!(n): a = aes(n): d = des(n)
    T = tes(n)
    On T GOSUB DESHOT1, DESHOT2, DESHOT3, DESHOT4, DESHOT5
    DRAW.ESHOT1:
Next n
Return

DESHOT1:
c = 1
Line (x - 1, y - 2)-(x + 1, y + 2), c, B
Line (x, y - 3)-(x, y + 3), c
Line (x, y - 2)-(x, y + 2), 15
Return
DESHOT2:
Circle (x, y), d, 4: Paint (x, y), 10, 4
Return
DESHOT3:
f! = 1 + Sin(a / 4) * .4: f2! = d * .7
Circle (x, y), d + .5, 7, , , f!
Circle (x, y), d, 15, , , f!
Line (x - d * .1 / f! - 1, y - d * .3 * f!)-(x - 1, y), 7, B
Return
DESHOT4:
a = (a * 30) Mod 360: z = 4: c = 15: e = 1: GoSub DRAW.SSPRITE
Return
DESHOT5:
a = (a * 9) Mod 360: z = 4: c = 15: e = 2: GoSub DRAW.SSPRITE
Return

CREATE.ESHOT:
If STAGE <= 1 Then Return
r = (20 / STAGE) * Rnd: If r > 0 Then Return
e = Int((emax + 1) * Rnd)
If ye!(e) > 80 Or ste(e) < 0 Then Return
x = xe!(e): y = ye!(e)
T = 1 - (tpe = 10): s = ses(T): GoSub FIRE.ESHOT
Return
FIRE.ESHOT:
escnt = (escnt + 1) And esmax: n = escnt
If stes(n) > -1 Then Return
xes!(n) = x: yes!(n) = y: v = ves(T)
a! = pi2! - (pi! / 8) * Rnd + pi4!: dx! = Cos(a!) * v: dy! = Sin(a!) * v
If Sgn(xp - x) <> Sgn(dx!) Then dx! = -dx!
dxes!(n) = dx!: dyes!(n) = dy!
stes(n) = 0: tes(n) = T: aes(n) = 0: des(n) = s
If Play(0) > 0 Or SND = 0 Then Return
On T GOSUB SESHOT1, SESHOT2, SESHOT3, SESHOT3, SESHOT3
Return

SESHOT1:
Play SSHOOT2$: Return
SESHOT2:
Play SSHOOT2$: Return
SESHOT3:
Play SSHOOT3$: Return

RESET.STAR:
xst(n) = 320 * Rnd: yst(n) = 0 * Rnd: cst(n) = Int(15 * Rnd) + 1
Return
CREATE.STAR:
xst(n) = 320 * Rnd: yst(n) = 200 * Rnd: cst(n) = Int(8 * Rnd)
Return

RESET.ENEMY:
If tbos = 7 Then GoSub RESET.SUPERENEMY
mt = table(tpe)
xe!(n) = xec(mt): ye!(n) = yec(mt): ze(n) = 9
Return
RESET.SUPERENEMY:
If (n And 1) = 1 Then ste(n) = -1
Return

CREATE.ENEMY:
n = eptr: eptr = (eptr + 2) And emax
If ste(n) <> -1 Then Return
crecnt = crecnt + 1: If crecnt > cresum Then Return
T = tpe: mt = table(T)
xe!(n) = xec(mt): ye!(n) = yec(mt): ae(n) = aec(mt)
ze(n) = 9: zze(n) = zoome(T)
ste(n) = 0: tpe(n) = T: tce(n) = tce0(mt)
GoSub LOADPTR.ENEMY
If Play(0) = 0 And SND = 1 Then Play SNEW1$
Return

LOADPTR.ENEMY:
c = tce(n): dae(n) = tae(c): ne(n) = tne(c)
c = c + 1: If tae(c) = 0 And tne(c) = 0 Then c = tce0(mt)
tce(n) = c
Return

DRAW.STAR:
dy = (cnt1 And 1)
For n = 0 To stmax
    x = xst(n): y = yst(n): c = cst(n): y = y + dy
    If Point(x, y) = 0 Then PSet (x, y), c
    yst(n) = y: If y > 200 Then GoSub RESET.STAR
Next n
stcnt = (stcnt + 1) And stmax: n = stcnt
If Int(2 * Rnd) = 0 Then n = stmax * Rnd: GoSub CREATE.STAR
Return

DRAW.PLAYER:
If stp > 0 Then GoTo DRAW.GAMEOVER
If stp < 0 Then GoTo DRAW.SHIPEXPLODE
If ssec(1) = 1 Then x = xp: y = yp + 0: c = 4: GoSub DRAW.SHIP1
If ssec(2) = 1 Then x = xp: y = yp + 6: c = 9: GoSub DRAW.SHIP2
If ssec(3) = 1 Then x = xp: y = yp + 15: c = 5: GoSub DRAW.SHIP3
Return

DRAW.ESTAR:
For n = 0 To stmax
    x = xst(n): y = yst(n): c = cst(n)
    x = x + 1: If x > 320 Then x = 0: yst(n) = 10 + 180 * Rnd
    PSet (x, y), c: xst(n) = x
Next n
c = 12 + Int(4 * Rnd): If c = 13 Or c < 12 Then c = 0
n = stmax * Rnd: cst(n) = c
Return


DRAW.SHIPEXPLODE:
stp = stp + 1: If stp > -10 Then Return
x0 = xp: y0 = yp + 6
If SND = 1 Then Sound 37 + f1! * Rnd, .5
f1! = f1! * .85
For n = 1 To 5
    x = fx!(n): y = fy!(n): a = ft(n): c = fc(n): z = dfx!(n)
    e$ = CRASH$(1): GoSub DRAW.SPRITE
Next n
If bin(2) = 1 Then GoSub CREATE.SHIPEXPLODE
Return

CREATE.SHIPEXPLODE:
For n = 1 To 5
    fx!(n) = x0 + 24 * Rnd - 12: fy!(n) = y0 + 14 * Rnd - 7
    ft(n) = 360 * Rnd: c = 12 + Int(4 * Rnd): If c = 13 Then c = 15
    fc(n) = c: dfx!(n) = Int(3 * Rnd) + 2
Next n
Return

DRAW.SHIP1:
Line (x, y - 3)-(x - 6, y + 3), c
Line (x, y - 3)-(x + 6, y + 3), c
Line (x - 6, y + 4)-(x + 6, y + 4), c
Paint (x, y), c, c
Rem c = SGN(cnt1 AND 8) * 14
Line (x, y + 0)-(x, y + 2), 14
Line (x - 5, y + 5)-(x - 5, y + 5), c
Line (x + 5, y + 5)-(x + 5, y + 5), c
Return
DRAW.SHIP2:
Line (x - 4, y - 1)-(x + 4, y + 4), c, BF
Line (x - 10, y - 2)-(x - 9, y + 3), c, B
Line (x + 9, y - 2)-(x + 10, y + 3), c, B
Line (x - 9, y + 4)-(x + 9, y + 4), c
Line (x - 1, y + 0)-(x - 1, y + 2), 14
Line (x + 1, y + 0)-(x + 1, y + 2), 14
Return
DRAW.SHIP3:
Line (x - 8, y)-(x - 4, y - 4), c
Line (x - 4, y - 4)-(x + 4, y - 4), c
Line (x + 4, y - 4)-(x + 8, y), c
Line (x - 8, y)-(x - 4, y + 4), c
Line (x - 4, y + 4)-(x + 4, y + 4), c
Line (x + 4, y + 4)-(x + 8, y), c
Paint (x, y), c, c
Line (x - 13, y)-(x + 13, y), c
Line (x - 14, y - 4)-(x - 13, y + 3), c, B
Line (x + 13, y - 4)-(x + 14, y + 3), c, B
PSet (x - 13, y + 3), 0: PSet (x + 13, y + 3), 0
Line (x - 2, y - 1)-(x - 2, y + 1), 14
Line (x, y - 1)-(x, y + 1), 14
Line (x + 2, y - 1)-(x + 2, y + 1), 14
Return

DRAW.SHOT:
For n = 0 To shmax: xs = xsh(n): ys = ysh(n)
    If ys < 0 Then GoTo DRAW.SHOT1
    Line (xs, ys)-(xs, ys + 3), 14
    DRAW.SHOT1:
Next n
Return

DRAW.EXP:
expcnt = 0
For n = 0 To exmax
    If stex(n) = 0 Then GoTo DRAW.EXP1
    T = tex(n): c = 12 + (cnt1 And 1) * 4: a = ae(n) / 10
    x = xex(n): y = yex(n): z = zex(n) / 16
    e$ = CRASH$(T): GoSub DRAW.SPRITE
    ae(n) = (ae(n) + 0) Mod 3600: stex(n) = stex(n) - 1
    expcnt = expcnt + 1
    DRAW.EXP1:
Next n
Return

DRAW.ENEMY:
For n = 0 To emax
    s = ste(n): If s < 0 Then GoTo DRAW.ENEMY1
    a = ae(n) / 10: z = ze(n) / 16
    x = xe!(n): y = ye!(n)
    e = tpe(n): f = bin(anie(e)) * 2
    c1 = c1e(e): c2 = c2e(e): GoSub DRAW.ESPRITE
    DRAW.ENEMY1:
Next n
Return

DRAW.GAMEOVER:
stp = stp + 1
If k = 29 And stp > 50 Then GoTo GAME.OVER
If stp > 400 Then GoTo GAME.OVER
ac = 0: sc = 4: cc = 15
yc! = 90
xc! = 120: T$ = "GAME": GoSub DRAW.TXTF
xc! = 168: T$ = "OVER": GoSub DRAW.TXTF
Return

GAME.OVER:
If SND = 1 Then Play SEND$
GoSub WAITKEY0
sc = 8: ac = 0
Do
    k = Inp(96): k$ = InKey$
    GoSub DRAW.ESTAR
    cc = 16 * Rnd
    T$ = "WELL DONE": xc! = 80: yc! = 60: GoSub DRAW.TXTZ
    Locate 14, 11
    Print "SCORE: "; score&; "PTS"
    GoSub REFR.SCREEN
Loop Until k = 29
Run

DRAW.SPRITE:
x$ = LTrim$(Str$(x)): y$ = LTrim$(Str$(y))
a$ = LTrim$(Str$(a)): c$ = LTrim$(Str$(c))
z$ = LTrim$(Str$(z))
s$ = "S" + z$ + "TA" + a$ + "C" + c$ + "bm" + x$ + "," + y$ + e$
If z > 1 Then s$ = s$ + "P" + c$ + "," + c$
Draw s$
Return
DRAW.SSPRITE:
x$ = LTrim$(Str$(x)): y$ = LTrim$(Str$(y))
a$ = LTrim$(Str$(a)): c$ = LTrim$(Str$(c)): z$ = LTrim$(Str$(z))
s$ = "S" + z$ + "TA" + a$ + "C" + c$ + "bm" + x$ + "," + y$ + SHOT$(e)
Draw s$
Return
DRAW.ESPRITE:
x$ = LTrim$(Str$(x)): y$ = LTrim$(Str$(y))
a$ = LTrim$(Str$(a)): c1$ = LTrim$(Str$(c1)): c2$ = LTrim$(Str$(c2))
z$ = LTrim$(Str$(z))
e1$ = ENEMY$(e, f): e2$ = ENEMY$(e, f + 1)
s$ = "S" + z$ + "TA" + a$ + "C" + c1$ + "bm" + x$ + "," + y$ + e1$
If z > 1 Then s$ = s$ + "P" + c1$ + "," + c1$
s$ = s$ + "C" + c2$ + e2$
If z > 1 Then s$ = s$ + "P" + c2$ + "," + c2$
Draw s$
Return

DRAW.PLAYER1:
Screen 7, 0, 0, 0: Cls
cc = 15: yc! = 90
xc! = 120: T$ = "PLAYER": GoSub DRAW.TXT
xc! = 182: i = 1: GoSub DRAW.INTF
Return

TEST.HIT.SHOT:
For n = 0 To shmax: xs = xsh(n): ys = ysh(n)
    If ys < 0 Then GoTo TEST.HIT.SHOT1
    c = Point(xs, ys) + Point(xs, ys + 1) + Point(xs, ys + 2)
    If c > 0 Then GoSub HIT.SHOT
    TEST.HIT.SHOT1:
Next n
Return

TEST.HIT.PLAYER:
If stp <> 0 Then Return
c = Point(xp, yp - 3) + Point(xp, yp + 2) + Point(xp - 3, yp) + Point(xp + 3, yp)
If c <= 0 Then Return
c1 = Point(319, 199) * 4
c2 = Point(0, 0) + Point(319, 0) + Point(0, 199) + Point(319, 199)
If c1 = c2 And c1 > 0 Then Return
GoSub HIT.PLAYER
Return

HIT.SHOT:
x! = xs: y! = ys: r1! = hitrad
For e = 0 To emax
    If ste(e) <> 0 Then GoTo HIT.SHOT1
    dx! = xe!(e) - x!: dy! = ye!(e) - y!
    r! = Sqr(dx! * dx! + dy! * dy!)
    If r! < r1! Then ysh(n) = -1: GoSub HIT.ENEMY: Exit For
    HIT.SHOT1:
Next e
If stbos < 0 Then Return
dx! = xbos! - x!: dy! = ybos! - y!
rr! = Sqr(dx! * dx! + dy! * dy!)
If rr! < hrbos(tbos) Then ysh(n) = -1: GoSub HIT.BOSS
Return

HIT.BOSS:
If Play(0) = 0 And SND = 1 Then Play SHITBOS1$
If stbos < 0 Then Return
If stbos = 0 Then GoTo EXP.BOSS
stbos = stbos - 1: hbos = 1
xex(0) = x!: yex(0) = y!: stex(0) = 12
zex(0) = 32: tex(0) = 2
GoSub ACTIV.BOSS
Return

EXP.BOSS:
stbos = -160: dx = 48: d = 2
If tbos = 7 Then dx = 120: d = 4
For m = 0 To exmax
    xex(m) = xbos! + dx * Rnd - dx * .5: yex(m) = ybos! + 32 * Rnd - 16
    stex(m) = 30 + 30 * Rnd
    zex(m) = (3 + Int(d * Rnd)) * 16: tex(m) = 1
Next m
For m = 0 To fmax
    fx!(m) = xbos!: fy!(m) = ybos!: a! = pi! * 2 * Rnd
    dfx!(m) = Cos(a!) * 4: dfy!(m) = Sin(a!) * 4
    fc(m) = 15
Next m
Return

PLAY.ENEMY.CRASH:
If T = 1 Then Play SETYPE1$
If T = 2 Then Play SETYPE2$
If T = 3 Then Play SETYPE3$
If T = 4 Then Play SETYPE4$
If T = 5 Then Play SETYPE1$
If T = 6 Then Play SETYPE1$
If T = 7 Then Play SETYPE1$
If T = 8 Then Play SETYPE8$
If T = 9 Then Play SETYPE9$
If T = 10 Then Play SETYPE10$
If T = 11 Then Play SETYPE11$
Return

HIT.ENEMY:
If Play(0) = 0 And SND = 1 Then T = tpe(e): GoSub PLAY.ENEMY.CRASH
ste(e) = -1: GoSub CREATE.EXP
hitcnt = hitcnt + 1: pts& = ptse(tpe(e)) * STAGE: GoSub LOAD.SCORE
T = tpe(e)
If dble(T) = 0 Then Return ' unteilbar/teilbar
SPLIT.ENEMY:
f = e + 1
ste(e) = 0: ae(e) = 900: ze(e) = zoome(T + 1): zze(e) = ze(e)
ste(f) = 0: ae(f) = 900: ze(f) = zoome(T + 1): zze(f) = ze(f)
tpe(e) = T + 1: tpe(f) = T + 1
mt1 = table(T + 1): mt2 = table(T + 1)
tce(e) = tce0(mt1): tce(f) = tce0(mt2): tce(e) = 72: tce(f) = 88
dae(e) = tae(tce(e)): ne(e) = tne(tce(e))
dae(f) = tae(tce(f)): ne(f) = tne(tce(f))
xe!(f) = xe!(e): ye!(f) = ye!(e)
If Play(0) = 0 And SND = 1 Then Play SSPLIT$
Return

HIT.PLAYER:
Rem LOCATE 2, 1: PRINT "HIT ON PLAYER!"
stp = -35: f1! = 600
For q = 1 To 3
    If ssec(q) = 1 Then ssec(q) = -1: Exit For
Next q
GoSub SETUP.SHIP
x0 = xp: y0 = yp + 6: GoSub CREATE.SHIPEXPLODE
Return

CREATE.EXP:
exptr = (exptr + 1) And exmax
If stex(exptr) > 0 Then Return
xex(e) = xe!(e): yex(e) = ye!(e): stex(e) = 30
zex(e) = ze(e): tex(e) = 1
Return

LOAD.SCORE:
B& = bonplay&
s& = score&: score& = score& + pts&
If (score& Mod B&) > (s& Mod B&) Then Return
Screen 7, 0, scr, scr
For q = 1 To 3: If ssec(q) = -1 Then ssec(q) = 0: Exit For
Next q
x = 160: y = 20: c = 4
On q GOSUB DRAW.SHIP1, DRAW.SHIP2, DRAW.SHIP3
sc = 4: ac = 0: cc = 15
T$ = "BONUS PLAYER": xc! = 178: yc! = 17: GoSub DRAW.TXTZ
If ssec(1) = 0 Then ssec(1) = 1: ssec(2) = 0: ssec(3) = 0: GoSub SETUP.SHIP
If SND = 1 Then Play SBONPLAY$
c = 50: GoSub PAUSE: Screen 7, 0, 1 - scr, scr
Return

Rem  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DOCKING:
Rem REM PLAY SDOCK1$: DO: LOOP UNTIL PLAY(0) = 0
ss1 = 0: ss2 = 0
If ssec(1) = 1 Then ss1 = ss1 Or 1
If ssec(2) = 1 Then ss1 = ss1 Or 2
If ssec(3) = 1 Then GoTo DOCK.END
If ssec(3) = 0 Then ss2 = 4: dp = 5
If ssec(2) = 0 Then ss2 = 2: dp = 0
If ss2 = 0 Then GoTo DOCK.END
xb = scx: yb = 172
xp! = xb - 30 + 60 * Rnd: yp! = 100: vxp! = 0: vyp! = 0
dyp! = 0: If ss1 = 3 Then dyp! = 6
fcnt = 0: For n = 0 To fmax: ft(n) = -1: Next n
grav! = .01 + ss1 * .006
dfuel = 1000: dtime! = 10
For n = 0 To 1: Screen 7, 0, n, n: Cls
    Locate 4, 9: Print "Time": Locate 4, 27: Print "Fuel"
    GoSub DRAW.VALUES: Locate 9, 12: Print "Docking Sequence"
Next n
GoSub WAITFIRE: timer0! = Timer + dtime!

DOCK.MAIN:
k0 = k: k = Inp(96): k$ = InKey$
If k = 1 Then System
If k = 29 Then GoSub THRUST
If k = 75 Then vxp! = vxp! - .03
If k = 77 Then vxp! = vxp! + .03
vyp! = vyp! + grav!
GoSub MOVE.SECTION
GoSub MOVE.FIRE
GoSub REFR.DOCKSCREEN
Wait &H3DA, 8: Wait &H3DA, 8, 8
GoSub DRAW.SECTION
GoTo TEST.HIT.BASE
DOCK.MAIN1:
dtime! = timer0! - Timer
GoSub DRAW.DSTAR
GoSub DRAW.VALUES: GoSub DRAW.FIRE
GoSub DRAW.BASE: GoSub DRAW.SECTION
cnt1 = (cnt1 + 1) And 255
GoTo TEST.DOCK.OUT
GoTo DOCK.MAIN

THRUST:
If dfuel = 0 Then Return
vyp! = vyp! - .07: dfuel = dfuel - 8: If dfuel < 0 Then dfuel = 0
If SND = 1 Then Sound 37 + 80 * Rnd, .3
GoSub CREATE.FIRE
Return

DRAW.DSTAR:
For n = 0 To stmax
    x = xst(n): y = yst(n): c = cst(n)
    If Point(x, y) = 0 Then PSet (x, y), c
Next n
If cnt1 = 0 Then Return
n = stmax * Rnd: xst(n) = 300 * Rnd + 10: yst(n) = 180 * Rnd + 10
Return

TEST.DOCK.OUT:
If xp! < 0 Or xp! > 319 Or yp! < 32 Or yp! > 199 Then GoTo DOCK.OUT
If dtime! < .1 Then GoTo DOCK.OUT
GoTo DOCK.MAIN

DRAW.VALUES:
Locate 6, 8: Print Int(dtime! * 10) / 10
Locate 6, 26: Print Int(dfuel / 10)
Return

DOCK.END:
Return

MOVE.FIRE:
For n = 0 To fmax: If ft(n) < 0 Then GoTo MOVE.FIRE1
    fx!(n) = fx!(n) + dfx!(n): fy!(n) = fy!(n) + dfy!(n): ft(n) = ft(n) - 1
    If Point(fx!(n), fy!(n)) = 9 Then dfy!(n) = -dfy!(n) / 2
    MOVE.FIRE1:
Next n
Return
CREATE.FIRE:
If ft(fcnt) >= 0 Then Return
a! = pi2! + 1 * Rnd - .5: dv! = Abs(pi2! - a!) * 2: v! = 2 - dv!
fx!(fcnt) = xp!: fy!(fcnt) = yp! + 4
dfx!(fcnt) = Cos(a!) * v! + vxp!: dfy!(fcnt) = Sin(a!) * v! + vyp!
ft(fcnt) = 8: fc(fcnt) = 14 - Int(2 * Rnd) * 8
fcnt = (fcnt + 1) And fmax
Return
DRAW.FIRE:
For n = 0 To fmax: If ft(n) < 0 Then GoTo DRAW.FIRE1
    x = fx!(n): y = fy!(n): PSet (x, y), fc(n)
    DRAW.FIRE1:
Next n

MOVE.SECTION:
xp! = xp! + vxp!: yp! = yp! + vyp!
Return

DRAW.SECTION:
If (ss1 And 1) = 1 Then x = xp!: y = yp! - dyp!: c = 4: GoSub DRAW.SHIP1
If (ss1 And 2) = 2 Then x = xp!: y = yp!: c = 9: GoSub DRAW.SHIP2
Return
DRAW.BASE:
If ss2 = 2 Then x = xb: y = yb: c = 9: GoSub DRAW.SHIP2
If ss2 = 4 Then x = xb: y = yb: c = 5: GoSub DRAW.SHIP3
Return

TEST.HIT.BASE:
n = dp
x = xb + pcx(n): y = yb + pcy(n)
If Point(x, y) > 0 Then GoTo TEST.DOCK.OK
c = 14: If (cnt1 And 16) = 0 Then c = 0
PSet (x, y), c
For n = dp + 1 To dp + 4
    x = xb + pcx(n): y = yb + pcy(n)
    If Point(x, y) > 0 Then GoTo DOCK.CRASH
    Rem PSET (x, y), 14
Next n
GoTo DOCK.MAIN1

TEST.DOCK.OK:
If Abs(xp! - xb) > 3 Then GoTo DOCK.CRASH
If vyp! > .8 Then GoTo DOCK.CRASH
GoTo DOCK.OK

DOCK.OK:
xp! = xb: yp! = yb + pcy(db) - 4
If (ss1 And 2) = 2 Then yp! = yp! - 3
GoSub REFR.DOCKSCREEN: Screen 7, 0, scr, scr: Cls
GoSub DRAW.VALUES
GoSub DRAW.BASE: GoSub DRAW.SECTION
Locate 9, 15: Print "Right On !"
If ss2 = 2 Then ssec(2) = 1: GoSub SETUP.SHIP
If ss2 = 4 Then ssec(3) = 1: GoSub SETUP.SHIP
If SND = 1 Then Play SDOCK2$
Do: Loop While Play(0) > 0: c = 20: GoSub PAUSE
T = Int(dtime! * 10) / 10: f = dfuel / 10: s = 200 * T + 10 * f
Locate 13, 6: Print "Bonus = 200 x"; T
Locate 15, 6: Print "      +  10 x"; f; " ="; s; "x"; STAGE
pts& = s * STAGE: GoSub LOAD.SCORE
If SND = 1 Then Play SRGTON$
GoSub WAITFIRE
Return

DOCK.OUT:
Screen 7, 0, scr, scr
Locate 9, 10: Print "Section Out of Range"
GoSub WAITFIRE
Return

DOCK.CRASH:
s = 0: z1 = 4: f1! = 40
For n = 1 To 200
    a1 = 3600 * Rnd: c1 = (s And 1) * 3 + 12
    c2 = 15 - (s And 1) * 3
    If s = 0 Then z2 = 3 + 4 * Rnd: a2 = 3600 * Rnd: c2 = 15
    GoSub REFR.DOCKSCREEN: GoSub DRAW.VALUES
    Locate 9, 13: Print "Sorry, no Bonus"
    x = xp!: y = yp!: a = a1 / 10: c = c1: z = z1
    e$ = CRASH$(1): GoSub DRAW.SPRITE
    x = xb: y = yb: a = a2 / 10: c = c2: z = z2
    e$ = CRASH$(1): GoSub DRAW.SPRITE
    s = (s + 1) And 7
    GoSub DOCK.CRASH.SND
Next n
GoSub WAITFIRE
Return

DOCK.CRASH.SND:
f2! = f1! * Rnd: f1! = f1! * .98
If n < 150 And SND = 1 Then Sound 37 + f2! * f2!, .3
Return

Rem - - - - - - - - - - - - - - - - - - - - - - - -


ADVANCE.LEVEL:
LEVEL = LEVEL + 1
If STAGE = 6 And LEVEL = 10 Then GoTo SUPER.LEVEL
If LEVEL = 9 Then GoTo BOSS.LEVEL
If LEVEL = 10 Then GoTo WARP.LEVEL
If LEVEL = 11 Then GoTo GAME.FINISH
GoSub LOAD.LEVEL
Return

SUPER.LEVEL:
STAGE = 7: GoSub ENTER.STAGE
tbos = tbos + 1: GoSub BOSS.LEVEL
stbos = 50
LEVEL = 9: GoSub LOAD.LEVEL
LEVEL = 10: cresum = 24: hitsum = 24
c1e(6) = 4: c2e(6) = 12
c1e(7) = 12: c2e(7) = 14
Return

BOSS.LEVEL:
evcnt = 70: evtpe = 2: evtxt$ = BOSS$(STAGE)
stbos = 8 + tbos * 4: abos = 0
xbos! = scx: ybos! = 50: dxbos! = 0: dybos! = 0
cresum = 0: crecnt = 0: hitcnt = 0: hitsum = 0
Return

LOAD.LEVEL:
n = LEVEL
hitrad = lrad(n): tpe = ltpe(n): mt = table(tpe)
vec = vec(mt)
cresum = lsum(n) + (STAGE - 1) * 2
crecnt = 0: hitcnt = 0: hitsum = cresum * lhit(n)
crec0 = crec(mt): crec1 = crec0
s = (STAGE - 1) Mod 3: Rem LOAD COLOR TABLE
For e = 1 To 11: c1e(e) = c1ee(s, e): c2e(e) = c2ee(s, e): Next e
Return

WARP.LEVEL:
dyp! = .5: dys! = .5: ypp = yp: yp! = yp
f1! = 0
GoSub SAVE.PALETTE
For o = 1 To 260
    If Inp(96) = 1 Then System
    GoSub DRAW.WARPSTAR
    GoSub DRAW.PLAYER
    yp = yp!: yp! = yp! - dyp!: dyp! = dyp! * 1.01: dys! = dys! + .1
    Wait &H3DA, 8, 8: Wait &H3DA, 8
    Screen 7, 0, 1 - scr, scr: scr = 1 - scr: Cls
    If o > 30 And o < 150 Then Locate 10, 14: Print " WARP OUT ! "
    If o < 180 Then f1! = f1! + 3
    If o = 180 Then f1! = 5000
    If o > 60 Then c1 = 1: c2 = 31: c3 = 2: GoSub INC.PALETTE
    If o > 180 Then c1 = 0: c2 = 0: c3 = 4: GoSub INC.PALETTE: f1! = f1! * .92
    If SND = 1 Then Sound 37 + f1! * Rnd, .3
Next o
Screen 7, 0, scr, scr: Cls
c1 = 0: c2 = 0: c3 = 4
For o = 1 To 16: Wait &H3DA, 8: Wait &H3DA, 8, 8: GoSub DEC.PALETTE: Next o
GoSub LOAD.PALETTE
yp = ypp
Rem IF SND = 1 THEN PLAY SFAROUT2$: PLAY SFAROUT2$
Rem c = 70: GOSUB PAUSE
Rem DO: LOOP UNTIL PLAY(0) < 4
LEVEL = 2: STAGE = STAGE + 1
GoSub LOAD.LEVEL
tbos = tbos + 1: If tbos > 6 Then tbos = 1
c = 20: GoSub PAUSE
GoSub ENTER.STAGE
Return

ENTER.STAGE:
evcnt = 70: evtpe = 2: evtxt$ = "STAGE " + LTrim$(Str$(STAGE))
GoSub LOAD.3DSTAR
Screen 7, 0, 2, 0: Cls
xs! = 159: ys! = 160: rs! = 20
On STAGE GOSUB DSTG1, DSTG2, DSTG3, DSTG4, DSTG5, DSTG6, DSTG7
Rem IF SND = 1 THEN PLAY SSTAGE1$

ENTER.STAGE1:
xs! = 159: ys! = 99: rs! = 8: rsmax! = 40: cnt = 0
u$ = "STAGE " + LTrim$(Str$(STAGE)): tptr = 0: mode = 0
sss = -(STAGE > 2 And STAGE < 7): fs! = 1.02: cnt1 = 10: cnt2 = 0
Do
    k = Inp(96): k$ = InKey$
    rs! = rs! * fs!: vs! = 1.08
    If rs! >= rsmax! And mode = 0 Then rs! = rsmax!: vs! = 1.02
    GoSub ENTER.STAGE2
    If cnt < 160 And mode = 0 Then GoSub ENTER.STAGE3
    If (cnt And 7) = 7 Then GoSub ENTER.STAGE5
    cnt = cnt + 1: If cnt > 300 Then GoSub ENTER.STAGE4
    GoSub REFR.SCREEN
    If mode = 1 And sss = 1 And SND = 1 Then Sound 37 + cnt1 * Rnd, 1: cnt1 = (cnt1 * 1.2) Mod 32000
    If cnt2 = 4 And SND = 1 Then Play SSTAGE2$
    If k = 29 And rs! >= rsmax! Then GoSub ENTER.STAGE4
Loop While rs! < 200
Return

ENTER.STAGE2:
If sss = 0 Then PCopy 2, 1 - scr: Return
GoSub DRAW.3DSTAR
On STAGE - 2 GOSUB DSTG3, DSTG4, DSTG5, DSTG6
Return
ENTER.STAGE3:
T$ = Left$(u$, tptr)
xc! = 136: yc! = 24: ac = 0: sc = 4: cc = 15
GoSub DRAW.TXTZ
T$ = STAGE$(STAGE)
xc! = 159 - Len(T$) * 4: yc! = 44: ac = 0: sc = 4: cc = 15
s = (cnt And 8)
If tptr <= 8 Or s > 0 And cnt2 < 24 Then Return
GoSub DRAW.TXTZ: cnt2 = cnt2 + 1
Return
ENTER.STAGE4: Rem launch
mode = 1: fs! = 1.04: Return
ENTER.STAGE5:
tptr = tptr + 1: If tptr < 8 Then Sound 622, 1
Return


SAVE.PALETTE:
Out &H3C7, 0
For c = 0 To 95: cp(c) = Inp(&H3C9): Next c
Return
LOAD.PALETTE:
Out &H3C8, 0
For c = 0 To 95: Out &H3C9, cp(c): Next c
Return
INC.PALETTE:
For c = c1 To c2: Out &H3C7, c
    a = Inp(&H3C9): a = a + c3: If a > 63 Then a = 63
    B = Inp(&H3C9): B = B + c3: If B > 63 Then B = 63
    d = Inp(&H3C9): d = d + c3: If d > 63 Then d = 63
    Out &H3C8, c: Out &H3C9, a: Out &H3C9, B: Out &H3C9, d
Next c
Return
DEC.PALETTE:
For c = c1 To c2: Out &H3C7, c
    a = Inp(&H3C9): a = a - c3: If a < 0 Then a = 0
    B = Inp(&H3C9): B = B - c3: If B < 0 Then B = 0
    d = Inp(&H3C9): d = d - c3: If d < 0 Then d = 0
    Out &H3C8, c: Out &H3C9, a: Out &H3C9, B: Out &H3C9, d
Next c
Return

DRAW.WARPSTAR:
dys = dys!
For n = 0 To stmax
    x = xst(n): y = yst(n)
    Line (x, y)-(x, y + dys), cst(n)
    y = y + dys: yst(n) = y: If y > 200 Then yst(n) = -20: xst(n) = 320 * Rnd
Next n
Return


Rem - - - - - - - - - - - - - - - - - - - - -
Rem - - - - - - CREDITS - - - - - - -

GAME.FINISH:
GoSub WAITKEY0
sc = 8: ac = 0: s = 1: GoSub LOAD.SONG: GoSub LOAD.3DSTAR
tcnt = 24: tptr = 0: cnt1 = -100: dy = 24: vs! = 1.06: cnt2 = 120
Do
    k = Inp(96): k$ = InKey$
    GoSub DRAW.3DSTAR
    d = 2: cc = 13
    If cnt1 < 0 Then cnt1 = cnt1 + 1: cc = 16 * Rnd: d = 0
    If tptr > 28 Then d = 0: cnt2 = cnt2 - 1
    If cnt2 = 0 Then s = 2: GoSub LOAD.SONG
    tcnt = tcnt - d
    If tcnt = 0 Then tcnt = dy: tptr = tptr + 1
    yc! = tcnt - dy
    For n = 1 To 11
        T$ = CREDIT$(n + tptr)
        xc! = 20: GoSub DRAW.TXTZ
        yc! = yc! + dy
    Next n
    Wait &H3DA, 8: Wait &H3DA, 8, 8
    GoSub REFR.SCREEN: GoSub PLAY.SONG
Loop Until (k = 29 And cnt1 >= 0)
GoTo GAME.OVER

LOAD.SONG:
nsong = s: stsong = 1: tsong = 1: Return

PLAY.SONG:
If stsong < 1 Then Return
If Play(0) > 0 Then Return
Play SFINAL$(nsong, tsong)
tsong = tsong + 1: If tsong > 7 Then stsong = 0
Return

LOAD.3DSTAR:
For n = 0 To stmax
    x = 26 * Rnd - 13: y = 20 * Rnd - 10
    xst!(n) = x * x * Sgn(x): yst!(n) = y * y * Sgn(y)
Next n
Return
DRAW.3DSTAR:
For n = 0 To stmax
    x! = xst!(n): y! = yst!(n): c = cst(n)
    r! = Sqr(x! * x! + y! * y!)
    x! = x! * vs!: y! = y! * vs!
    If r! > 160 Then r! = 2 + 6 * Rnd: a! = pi! * 2 * Rnd: x! = Cos(a!) * r!: y! = Sin(a!) * r!
    PSet (scx + x!, scy - y!), 15
    xst!(n) = x!: yst!(n) = y!
Next n
Return




Rem - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TITLE:
a = 0: CH = 0: mode1 = 1: mode2 = 6: cnt = 35
TITLE.MAIN:
k = Inp(96): k$ = InKey$: If k = 1 Then System
If k = 29 Then Return
If k = 31 Then SND = 1 - SND: GoSub WAITKEY0
If k = 59 Then GoSub TITLE.HELP
GoSub CARE.TITLE
GoSub CARE.MENU
GoTo TITLE.MAIN

CARE.TITLE:
GoSub MOVE.TITLE: If mode1 > 4 Then Return
cc = 15: GoSub DRAW.TITLE: GoSub DRAW.YEAR
Wait &H3DA, 8, 8: Wait &H3DA, 8
GoSub REFR.TITLE
Return

DRAW.TITLE:
For n = 0 To 7
    nc = nc(n): ac = 0
    xc! = xc!(n): yc! = yc!(n): zc! = zc!(n)
    GoSub DRAW.CHAR3D
Next n
Return
DRAW.YEAR:
If CH < 8 Then Return
For n = 8 To 9
    nc = nc(n): ac = 0
    xc! = xc!(n): yc! = yc!(n): zc! = zc!(n)
    GoSub DRAW.CHAR3D
Next n
Return

MOVE.TITLE:
On mode1 GOTO MTIT1, MTIT2, MTIT3, MTIT4
Return
MTIT1:
zc!(CH) = zc!(CH) - 12: If zc!(CH) <= zmax And SND = 1 Then Play SCRASH8$
If zc!(CH) <= zmax Then CH = CH + 1
If CH > 7 Then mode1 = mode1 + 1: cnt = 2000
Return
MTIT2:
xc!(8) = xc!(8) - 2: yc!(8) = yc!(8) - 1
xc!(9) = xc!(9) - 2: yc!(9) = yc!(9) - 1
Sound cnt, .4: cnt = cnt - 44
If yc!(8) <= yc!(7) + 8 Then mode1 = mode1 + 1: cnt = 35
Return
MTIT3:
cnt = cnt - 1: If cnt = 34 And SND = 1 Then Play SCRASH9$
If cnt = 0 Then cnt = 35: mode1 = mode1 + 1
Return
MTIT4:
Screen 7, 0, scr, scr
scx = scx - 1: cc = 14: GoSub DRAW.TITLE
scx = scx + 2: cc = 14: GoSub DRAW.TITLE: scx = scx - 1
scy = scy - 1: cc = 14: GoSub DRAW.TITLE
scy = scy + 2: cc = 14: GoSub DRAW.TITLE: scy = scy - 1
cc = 4: GoSub DRAW.TITLE
mode1 = mode1 + 1: mode2 = 1
sss = scx
For scx = sss - 2 To sss + 2: cc = 15: GoSub DRAW.YEAR: Next scx
x = 214: y = 15
Circle (x, y), 5, 15: Paint (x, y), 15, 15
Circle (x - 3, y - 1), 5, 1: Paint (x - 3, y - 1), 1, 1
Return

REFR.TITLE:
Screen 7, 0, scr, 1 - scr: scr = 1 - scr
Line (0, 0)-(319, 120), 0, BF
Return

CARE.MENU:
If mode2 < 6 Then GoTo DRAW.MENU
Return
DRAW.MENU:
Wait &H3DA, 8, 8: Wait &H3DA, 8
On mode2 GOTO DMEN1, DMEN2, DMEN3, DMEN4, DMEN5
Return
DMEN1:
cnt = cnt - 1: If cnt = 0 Then cnt = 35: mode2 = mode2 + 1
Return
DMEN2:
Screen 7, 0, scr, scr
x = 40: y = 66: a = 90: c1 = 8: c2 = 15: f = 0: z = 4
For e = 1 To 5: GoSub DRAW.ESPRITE: Rem PSET (x, y), 10
y = y + 18: Next e
mode2 = mode2 + 1: x = 58
Return
DMEN3:
If (x And 7) > 0 Then GoTo DMEN31
y = 70: c1 = 15
For e = 1 To 5
    Rem LINE (x, y)-(x + 1, y + 1), 7, BF
    Rem PSET (x, y + 1), 15: PSET (x + 1, y), 8
    Line (x, y)-(x + 1, y), 8
    Line (x, y + 1)-(x + 1, y + 1), 15
y = y + 18: Next e
DMEN31:
x = x + 1: If x >= 208 Then mode2 = mode2 + 1
Return
DMEN4:
ac = 0: sc = 4: cc = 15: yc! = 64
For e = 1 To 5
    i = ptse(e): xc! = 220: GoSub DRAW.INTF
    T$ = "PTS": xc! = 234: GoSub DRAW.TXTF: yc! = yc! + 18
Next e
ac = 0: sc = 4: cc = 7
xc! = 54: yc! = 162: T$ = "PRESS F1 FOR BRIEFING": GoSub DRAW.TXTZ
mode2 = mode2 + 1
Return
DMEN5:
ac = 0: sc = 4: cc = 16 * Rnd
xc! = 100: yc! = 180: T$ = "PRESS FIRE": GoSub DRAW.TXTZ
Return


Rem - - - - - - - - - - - - - - - - -

DRAW.CHAR3D:
zf! = 100 / zc!: sc = zf! * 4
xd = Int(scx + xc! * zf!): yd = Int(scy - yc! * zf!)
x$ = LTrim$(Str$(xd)): y$ = LTrim$(Str$(yd))
ta$ = LTrim$(Str$(ac)): c$ = LTrim$(Str$(cc))
zs$ = LTrim$(Str$(sc))
s$ = "TA" + ta$ + "S" + zs$ + "C" + c$ + "bm" + x$ + "," + y$ + CH$(nc)
Draw s$
Return

DRAW.CHAR:
xd = xc!: yd = yc!
x$ = LTrim$(Str$(xd)): y$ = LTrim$(Str$(yd))
ta$ = LTrim$(Str$(ac)): c$ = LTrim$(Str$(cc))
zs$ = LTrim$(Str$(sc))
s$ = "TA" + ta$ + "S" + zs$ + "C" + c$ + "bm" + x$ + "," + y$ + CH$(nc)
Draw s$
Return

DRAW.FCHAR:
xd = xc!: yd = yc!
x$ = LTrim$(Str$(xd)): y$ = LTrim$(Str$(yd))
ta$ = LTrim$(Str$(ac)): c$ = LTrim$(Str$(cc))
zs$ = LTrim$(Str$(sc))
s$ = "TA" + ta$ + "S" + zs$ + "C" + c$ + "bm" + x$ + "," + y$ + CH$(nc)
Draw s$: x$ = LTrim$(Str$(xd - 1))
s$ = "TA" + ta$ + "S" + zs$ + "C" + c$ + "bm" + x$ + "," + y$ + CH$(nc)
Draw s$: x$ = LTrim$(Str$(xd + 1))
s$ = "TA" + ta$ + "S" + zs$ + "C" + c$ + "bm" + x$ + "," + y$ + CH$(nc)
Draw s$
Return

DRAW.INTF:
sc = 4: x! = xc!: ac = 0: sc = 4
For m = 0 To 5
    nc = i Mod 10
    GoSub DRAW.FCHAR
    xc! = xc! - 10: i = Int(i / 10): If i = 0 Then Exit For
Next m: xc! = x!
Return

DRAW.TXTF:
sc = 4: l = Len(T$)
For m = 1 To l
    nc = Asc(Mid$(T$, m, 1)) - 48
    GoSub DRAW.FCHAR
    xc! = xc! + 9
Next m
Return

DRAW.TXT:
sc = 4: l = Len(T$)
For m = 1 To l
    nc = Asc(Mid$(T$, m, 1)) - 48
    GoSub DRAW.CHAR
    xc! = xc! + 9
Next m
Return

DRAW.TXTZ:
l = Len(T$)
For m = 1 To l: nc = Asc(Mid$(T$, m, 1)) - 48
    If nc >= 0 Then GoSub DRAW.CHAR
    xc! = xc! + sc * 2
Next m
Return

WAITKEY0:
Do: k = Inp(96): k$ = InKey$: Loop While k < 128
Return

PAUSE.MODE:
GoSub WAITKEY0: Screen 7, 0, scr, scr
Locate 11, 16: Color 14: Print "- PAUSE -"
Do: k$ = InKey$: k = Inp(96): Loop Until k = 25
GoSub WAITKEY0
Return

Rem - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DBOSS1:
c1 = 13: c2 = 12: If hbos = 1 Then c1 = 15: c2 = 15
Line (x - 10, y - 25)-(x, y - 32), 1
Line (x, y - 32)-(x + 10, y - 25), 1
Line (x - 10, y - 25)-(x + 10, y - 25), 1
Paint (x, y - 30), c1, 1
Line (x - 16, y)-(x, y + 16), 5
Line (x, y + 16)-(x + 16, y), 5
Line (x - 16, y)-(x + 16, y), 5
Paint (x, y + 8), c1, 5
Line (x, y + 15)-(x + 15, y), 5
Line (x - 15, y)-(x, y + 15), 5
Circle (x, y), 30, 5, -pi! * 2, -pi!, .85
Paint (x, y - 10), c2, 5
Circle (x - 11, y - 17), 4, 14: Paint (x - 11, y - 17), 15, 14
Circle (x + 10, y - 12), 8, 14: Paint (x + 10, y - 12), 15, 14
Circle (x - 15, y), 8, 14, -pi! * 2, -pi!, .85: Paint (x - 15, y - 4), 15, 14
Circle (x + 30, y), 8, 14, -pi! * .55, -pi!, .85: Paint (x + 26, y - 3), 15, 14
s = Sin(cnt1 / 1) * 20 + 30
If Play(0) = 0 And s > 37 Then Sound s, .2
Return

DBOSS2:
c1 = 6: c2 = 14: If hbos = 1 Then c1 = 15
s = Sgn(dybos!)
If s > 0 Then abos = abos + 2
If s = 0 Then abos = abos + 15
If s < 0 Then abos = abos + 30
dy1 = Sin(abos / 100) * 5: dy2 = Sin(abos / 100) * 10
Line (x, y - 9)-(x + 20, y - 6 + dy1), c1
Line (x + 20, y - 6 + dy1)-(x + 32, y - 1 + dy2), c1
Line (x + 32, y - 1 + dy2)-(x + 32, y + 3 + dy2), c1
Line (x + 32, y + 3 + dy2)-(x, y + 7), c1
Line (x, y + 7)-(x - 32, y + 3 + dy2), c1
Line (x - 32, y + 3 + dy2)-(x - 32, y - 1 + dy2), c1
Line (x - 32, y - 1 + dy2)-(x - 20, y - 6 + dy1), c1
Line (x - 20, y - 6 + dy1)-(x, y - 9), c1
Paint (x, y), c1, c1
yy! = y + 4: dy! = dy2 / 7
For xx = 2 To 32 Step 4
    x1 = x + xx: x2 = x - xx
    Line (x1, yy!)-(x1 + 1, yy! + 5), c1, B
    Line (x2 - 1, yy!)-(x2, yy! + 5), c1, B
    yy! = yy! + dy!
Next xx
Line (x, y - 9)-(x - 6, y - 3), c2
Line (x - 6, y - 3)-(x, y + 12), c2
Line (x, y + 12)-(x + 6, y - 3), c2
Line (x + 6, y - 3)-(x, y - 9), c2
Paint (x, y), c2, c2
Circle (x, y - 13), 4, c1, , , 1: Paint (x, y - 13), c2, c1
Line (x, y + 11)-(x - 11, y + 23), c1
Line (x - 11, y + 23)-(x, y + 19), c1
Line (x, y + 19)-(x + 11, y + 23), c1
Line (x + 11, y + 23)-(x, y + 11), c1
Paint (x, y + 16), c2, c1
Line (x - 1, y - 11)-(x + 1, y - 11), c1
PSet (x - 4, y - 17), c1
PSet (x + 4, y - 17), c1
Line (x - 2, y - 14)-(x + 2, y - 14), c1
Line (x - 2, y - 11)-(x - 2, y - 10), 0
Line (x + 2, y - 11)-(x + 2, y - 10), 0
Return

DBOSS3:
c1 = 6: c2 = 14: If hbos = 1 Then c1 = 15: c2 = 15
c3 = 4: abos = abos + 1: d = abos And 63
If d < 4 Then c3 = 15 - d / 2
Line (x, y - 6)-(x + 7, y - 7), c1
Line (x + 7, y - 7)-(x + 12, y - 10), c1
Line (x + 12, y - 10)-(x + 20, y - 7), c1
Line (x + 20, y - 7)-(x + 24, y + 1), c1
Line (x + 24, y + 1)-(x + 25, y + 9), c1
Line (x + 25, y + 9)-(x + 20, y + 16), c1
Line (x + 19, y + 16)-(x + 15, y + 7), c1
Line (x + 15, y + 7)-(x + 6, y + 2), c1
Line (x + 6, y + 2)-(x, y + 6), c1
Line (x, y - 6)-(x - 7, y - 7), c1
Line (x - 7, y - 7)-(x - 12, y - 10), c1
Line (x - 12, y - 10)-(x - 20, y - 7), c1
Line (x - 20, y - 7)-(x - 24, y + 1), c1
Line (x - 24, y + 1)-(x - 25, y + 9), c1
Line (x - 25, y + 9)-(x - 20, y + 16), c1
Line (x - 19, y + 16)-(x - 15, y + 7), c1
Line (x - 15, y + 7)-(x - 6, y + 2), c1
Line (x - 6, y + 2)-(x, y + 6), c1

Line (x + 18, y + 11)-(x + 24, y + 9), c1
Paint (x + 20, y + 13), c2, c1
Line (x - 18, y + 11)-(x - 24, y + 9), c1
Paint (x - 20, y + 13), c2, c1
Paint (x, y), 2, c1
Line (x + 3, y)-(x + 5, y - 2), c3
Line (x - 3, y)-(x - 5, y - 2), c3
Line (x + 6, y + 2)-(x, y + 6), 4
Line (x - 6, y + 2)-(x, y + 6), 4
Return

DBOSS4:
c1 = 9: c2 = 11: c3 = 15: If hbos = 1 Then c1 = 15
Circle (x, y), 30, c1, 0, pi!, .85
Circle (x, y), 30, c1, pi!, pi! * 2, .1
Paint (x, y - 10), 0, c1
abos = (abos + 1) And 255
For xx = x - 24 To x + 24 Step 5
    a1! = abos + xx + 1: r1! = Sin(a1! / 4.33)
    a2! = abos + xx + 2: r2! = Sin(a2! / 3.97)
    a3! = abos + xx + 3: r3! = Sin(a3! / 3.67)
    yy = y - 4 - r2!: f1 = 40 - Abs(xx - x): f2 = f1 / 5
    x1 = xx + f2 * r1!: x2 = xx + f2 * r2!: x3 = xx + f2 * r3!
    Line (xx, yy)-(x1, yy + 16), c2
    Line (x1, yy + 16)-(x2, yy + 30), c2
    Line (x2, yy + 30)-(x3, yy + 30 + f2 * 2), c2
Next xx
Circle (x, y), 30, c3, 0, pi!, .1
Return

DBOSS5:
c1 = 9: dy = 0: abos = abos + 1
If (abos And 63) > 40 Then dy = 1
If hbos = 1 Then c1 = 15: dy = -2
Circle (x, y), 20, c1, , , .6
Paint (x, y), c1, c1
Line (x - 6, y - 12)-(x + 11, y - 24), c1
Line (x + 11, y - 24)-(x + 8, y - 14), c1
Line (x + 8, y - 14)-(x + 16, y - 8), c1
Paint (x + 3, y - 16), c1, c1
Line (x - 7, y + 12)-(x + 2, y + 20), c1
Line (x + 2, y + 20)-(x + 7, y + 12), c1
Paint (x, y + 16), c1, c1
Line (x + 18, y)-(x + 40, y - 12), c1
Line (x + 18, y)-(x + 40, y + 12), c1
Line (x + 40, y - 12)-(x + 36, y), c1
Line (x + 36, y)-(x + 40, y + 12), c1
Paint (x + 24, y), c1, c1
Circle (x - 7, y - 4), 5, 15, , , .9: Paint (x - 7, y - 4), 15, 15
Circle (x - 7, y - 4 + dy), 2, 0, , , .9: Paint (x - 7, y - 4 + dy), 0, 0
Return

DBOSS6:
a = ((abos Mod 7) - 3) * 12: abos = abos + 1
c1 = 6: c2 = 14: c3 = 11: If hbos = 1 Then c1 = 15
a! = a * pi! / 180: r = 20: s = 1
For q = -2 To 1
    s = Sgn(q + .5): a! = -a!
    x1 = Cos(a!) * r * s: y1 = Sin(a!) * r
    Circle (x + x1, y - y1), 8, c3: Paint (x + x1, y - y1), c3, c3
    x2 = Cos(a! - .36) * r * s: y2 = Sin(a! - .36) * r
    Line (x, y)-(x + x2, y - y2), c3
    x3 = Cos(a! + .36) * r * s: y3 = Sin(a! + .36) * r
    Line (x, y)-(x + x3, y - y3), c3
    Paint (x + x1 * .4, y - y1 * .4), c3, c3
Next q
Circle (x, y), 11, c1, , , 1.2: Paint (x, y), c1, c1
Circle (x, y - 12), 8, c1, -pi! * 1.9, -pi! * 1.1, .8
Paint (x, y - 14), c1, c1
Circle (x - 5, y - 14), 4, 7, , , .8
Paint (x - 5, y - 14), A5$, 7
Circle (x + 5, y - 14), 4, 7, , , .8
Paint (x + 5, y - 14), A5$, 7
Line (x - 8, y - 3)-(x + 8, y - 1), c2, BF
Line (x - 7, y + 4)-(x + 7, y + 6), c2, BF
c = cnt1 And 127
If Play(0) = 0 And SND = 1 And c < 32 Then Sound 1600 + 200 * Rnd, .6
Return

DBOSS7:
c1 = 4: c2 = 12: abos = abos + 1: s = Sgn(abos And 16) * 10
c3 = 4: If hbos = 1 Then c3 = 15
If stbos < 12 Then c3 = 1
c4 = csb(stbos / 16)
Circle (x - 32, y - 14), 4, 2, , , 1
Circle (x, y - 12), 20, 15
Circle (x + 32, y - 14), 4, 2, , , 1
Circle (x, y - 13), 7, 15, -pi! * 2, -pi!
Paint (x, y - 14), c4, 15
Paint (x - 32, y - 15), s, 2
Paint (x + 32, y - 15), 10 - s, 2
Line (x - 50, y - 10)-(x + 50, y - 10), c1
Line (x - 25, y + 10)-(x + 25, y + 10), c1
Line (x - 50, y - 10)-(x - 80, y), c1
Line (x - 80, y)-(x - 80, y + 4), c1
Line (x - 80, y + 4)-(x - 25, y + 10), c1
Line (x + 50, y - 10)-(x + 80, y), c1
Line (x + 80, y)-(x + 80, y + 4), c1
Line (x + 80, y + 4)-(x + 25, y + 10), c1
Paint (x, y), c1, c1
Paint (x - 40, y), c1, c1: Paint (x + 40, y), c1, c1
Line (x - 40, y - 13)-(x - 43, y - 11), c1
Line (x - 40, y - 13)-(x + 40, y - 13), c1
Line (x + 40, y - 13)-(x + 43, y - 11), c1
Paint (x, y - 12), c2, c1
Line (x - 80, y - 1)-(x + 80, y + 3), 14, BF
xx = x - 88 + (abos Mod 24)
For q = 1 To 7
    Line (xx, y - 1)-(xx + 11, y + 3), 0, BF
    xx = xx + 24
Next q
Line (x - 80, y + 4)-(x - 25, y + 10), c3
Line (x - 25, y + 10)-(x + 25, y + 10), c3
Line (x + 80, y + 4)-(x + 25, y + 10), c3
Return

Rem  - - - - - - - - - - - - - - - - - - - - - - - - - - -

DSTG1:
a1! = pi! - .7
For n = 1 To 21
    r1 = 400 + 20 * Rnd
    x1 = Cos(a1!) * r1 + 300: y1 = 450 - Sin(a1!) * r1
    For m = 1 To 20
        a2! = pi! * 2 * Rnd
        r = 36 * Rnd: x2 = x1 + Cos(a2!) * r: y2 = y1 + Sin(a2!) * r
        PSet (x2, y2), 1
        r = 28 * Rnd: x2 = x1 + Cos(a2!) * r: y2 = y1 + Sin(a2!) * r
        PSet (x2, y2), 9
        r = 16 * Rnd: x2 = x1 + Cos(a2!) * r: y2 = y1 + Sin(a2!) * r
        PSet (x2, y2), 11
        r = 12 * Rnd: x2 = x1 + Cos(a2!) * r: y2 = y1 + Sin(a2!) * r
        PSet (x2, y2), 15
    Next m
    a1! = a1! - .05
Next n
Return

DSTG2:
c1 = 11: c2 = 9: c3 = 1
For n = 1 To 32
    x = 320 * Rnd: y = 200 * Rnd
    c = 12 + Int(4 * Rnd): If c = 13 Then c = 4
    PSet (x, y), c
Next n
x = 169: y = 109
Circle (x, y), 36, 9, , , 1
Circle (x, y), 37, 1, , , .94
Circle (x - 19, y - 16), 18, c1, pi2! * 3, pi2! * 4
Circle (x + 19, y - 16), 18, c1, pi2! * 2, pi2! * 3
Circle (x - 19, y + 16), 18, c1, pi2! * 0, pi2! * 1
Circle (x + 19, y + 16), 18, c1, pi2! * 1, pi2! * 2
Line (x, y - 17)-(x, y - 50), c1
Line (x, y + 17)-(x, y + 42), c1
Line (x - 20, y)-(x - 48, y), c1
Line (x + 20, y)-(x + 44, y), c1
Line (x, y - 40)-(x, y - 50), c2
Line (x, y + 40)-(x, y + 45), c2
Line (x - 34, y)-(x - 48, y), c2
Line (x + 34, y)-(x + 44, y), c2
Line (x, y - 50)-(x, y - 54), c3
Line (x, y + 45)-(x, y + 50), c3
Line (x - 48, y)-(x - 52, y), c3
Line (x + 44, y)-(x + 48, y), c3
Paint (x, y), 15, c1
Return

DSTG3:
x = xs!: y = ys!: r1 = rs!: rsmax! = 30
c1 = 4: c2 = 14: c3 = 4: a2! = 0

a2! = a2! + .03
r2 = 0: n = 0: a! = 0
For a! = 0 To pi! * 2 Step .2
    x0 = x1: y0 = y1
    f = (r1 / 6) * Rnd: a1! = a! + .1 * Rnd
    r = r1 + r2 * f: r2 = 1 - r2
    x1 = Sin(a1! + a2!) * r + x: y1 = Cos(a1! + a2!) * r + y
    If n = 0 Then x2 = x1: y2 = y1
    If n > 0 Then Line (x0, y0)-(x1, y1), c1
    n = n + 1
Next a!
Line (x1, y1)-(x2, y2), c1
Paint (x, y), c2, c1
Circle (x, y), r1 - 2, c3, , , 1
Paint (x, y), 0, c3
Return


DSTG4:
x = xs!: y = ys!: r1 = rs!: rsmax! = 60
c1 = 1: c2 = 9: c3 = 11: c4 = 11

Circle (x, y), r1, c1
Circle (x, y), r1, c2, pi2! * 3, pi2!

Circle (x, y), r1 * .84, c1, pi2!, pi2! * 3, 3
Paint (x - r1 * .5, y), c1, c1
Circle (x, y), r1 * .84, c2, pi2!, pi2! * 3, 3
Paint (x + r1 * .5, y), c2, c2

x1 = x - r1 * .36: y1 = y - r1 * .16
Circle (x1, y1), r1 * .16, c2, , , .7: Paint (x1, y1), c2, c2
x1 = x - r1 * .8: y1 = y - r1 * .05
Circle (x1, y1), r1 * .16, c2, , , 1.8: Paint (x1, y1), c2, c2
x1 = x - r1 * .6: y1 = y + r1 * .05
Circle (x1, y1), r1 * .2, c2, , , 1: Paint (x1, y1), c2, c2
x1 = x - r1 * .3: y1 = y + r1 * .1
Circle (x1, y1), r1 * .3, c2: Paint (x1, y1), c2, c2
x1 = x - r1 * .3: y1 = y + r1 * .1
Circle (x1, y1), r1 * .3, c3, -pi2! * 3.1, -pi2! * .95
Paint (x1 + r1 * .1, y1), c3, c3

x1 = x + r1 * .24: y1 = y - r1 * .5
Circle (x1, y1), r1 * .16, c3, , , .8: Paint (x1, y1), c3, c3
x1 = x + r1 * .33: y1 = y - r1 * .3
Circle (x1, y1), r1 * .2, c3, , , .9: Paint (x1, y1), c3, c3
x1 = x + r1 * .46: y1 = y - r1 * .46
Circle (x1, y1), r1 * .14, c3, , , .9: Paint (x1, y1), c3, c3

x1 = x + r1 * .02: y1 = y + r1 * .75
Circle (x1, y1), r1 * .12, c3, , , .4: Paint (x1, y1), c3, c3
x1 = x + r1 * .07: y1 = y + r1 * .67
Circle (x1, y1), r1 * .15, c3, , , .4: Paint (x1, y1), c3, c3
x1 = x + r1 * .2: y1 = y + r1 * .6
Circle (x1, y1), r1 * .15, c3, , , .66: Paint (x1, y1), c3, c3

x1 = x + r1 * .9: y1 = y + r1 * .02
Circle (x1, y1), r1 * .14, c3, , , 3: Paint (x1, y1), c3, c3
x1 = x + r1 * .7: y1 = y + r1 * .13
Circle (x1, y1), r1 * .17, c3, , , 1.2: Paint (x1, y1), c3, c3

x1 = x - r1 * .01: y1 = y - r1 * .8
Circle (x1, y1), r1 * .12, c3, -pi2! * 2.5, -pi2! * 1.3, .2: Paint (x1 + r1 * .06, y1), c3, c3
x1 = x - r1 * .08: y1 = y - r1 * .8
Circle (x1, y1), r1 * .12, c2, -pi2! * 1, -pi2! * 2.8, .2
Paint (x1 - r1 * .04, y1), c2, c2

Circle (x, y), r1, c4, pi2! * .28, pi2! * .7
Return


DSTG5:
x = xs!: y = ys!: r1 = rs!: rsmax! = 50
c1 = 6: c2 = 4: c3 = 12: c4 = 4
a1! = pi2! * 2: a2! = pi2! * 4: f! = .2
Circle (x, y), r1, c2
Paint (x, y), c1, c2
Circle (x, y - r1 * .8), r1 * .2, c2, a1!, a2!, f!
Circle (x, y - r1 * .7), r1 * .5, c2, a1!, a2!, f!
Circle (x, y - r1 * .56), r1 * .74, c2, a1!, a2!, f!
Circle (x, y - r1 * .4), r1 * .89, c2, a1!, a2!, f!
Circle (x, y - r1 * .32), r1 * .93, c2, a1!, a2!, f!
Circle (x, y - r1 * .16), r1 * .98, c2, a1!, a2!, f!
Circle (x, y + r1 * .06), r1 * 1, c2, a1!, a2!, f!
Circle (x, y + r1 * .29), r1 * .94, c2, a1!, a2!, f!
Circle (x, y + r1 * .42), r1 * .87, c2, a1!, a2!, f!
Circle (x, y + r1 * .6), r1 * .69, c2, a1!, a2!, f!
Paint (x, y - r1 * .16), c2, c2
Paint (x, y + r1 * .38), c2, c2
Paint (x, y + r1 * .78), c2, c2
Circle (x, y), r1, c3, pi2! * .2, pi2! * 1.4
a1! = pi2! * 1.5: a2! = pi2! * .5
Circle (x, y + r1 * .04), r1 * 1.6, c4, pi2! * 1.42, pi2! * .58, f!
Circle (x, y + r1 * .04), r1 * 1.76, c1, pi2! * 1.36, pi2! * .64, f!
Circle (x, y + r1 * .04), r1 * 1.8, c4, pi2! * 1.36, pi2! * .64, f!
Return


DSTG6:
x = xs!: y = ys!: r1 = rs!: rsmax! = 60
c1 = 8: c2 = 7: c3 = 15: c4 = 8
a1! = -pi2! * 1.1: a2! = -pi2! * 3 * .9

Circle (x, y), r1, c1
Circle (x, y), r1, c2, pi2!, pi2! * 3

Circle (x, y), r1 * .84, c2, pi2! * 3, pi2!, 1.6
Paint (x - r1 * .5, y), c2, c2
Circle (x, y), r1 * .84, c1, pi2! * 3, pi2!, 1.6
Paint (x + r1 * .8, y), c1, c1

x1 = x - r1 * .25: y1 = y - r1 * .2
Circle (x1, y1), r1 * .24, c1: Paint (x1, y1), c1, c1
Circle (x1, y1), r1 * .24, c3, a1!, a2!: Paint (x1 - r1 * .05, y1), c3, c3
Circle (x1 - r1 * .02, y1), r1 * .18, c2: Paint (x1, y1), c2, c2
x1 = x - r1 * .8: y1 = y - r1 * .04
Circle (x1, y1), r1 * .13, c1, , , 1.6: Paint (x1, y1), c1, c1
Circle (x1, y1), r1 * .13, c3, a1!, a2!, 1.6: Paint (x1 - r1 * .05, y1), c3, c3
Circle (x1 - r1 * .01, y1), r1 * .08, c2, , , 1.6: Paint (x1, y1), c2, c2
x1 = x - r1 * .5: y1 = y + r1 * .3
Circle (x1, y1), r1 * .1, c1, , , 1: Paint (x1, y1), c1, c1
Circle (x1, y1), r1 * .1, c3, -a1!, -a2!, 1

x1 = x + r1 * .14: y1 = y - r1 * .55
Circle (x1, y1), r1 * .13, c1, , , .66: Paint (x1, y1), c1, c1
x1 = x + r1 * .3: y1 = y + r1 * .1
Circle (x1, y1), r1 * .2, c1, , , .9: Paint (x1, y1), c1, c1
x1 = x + r1 * .02: y1 = y + r1 * .75
Circle (x1, y1), r1 * .12, c1, , , .4: Paint (x1, y1), c1, c1
x1 = x - r1 * .07: y1 = y + r1 * .5
Circle (x1, y1), r1 * .15, c1, , , .8: Paint (x1, y1), c1, c1
x1 = x - r1 * .01: y1 = y - r1 * .8
Circle (x1, y1), r1 * .12, c1, , , .2: Paint (x1 + r1 * .06, y1), c1, c1
Circle (x1, y1), r1 * .12, c3, -a1!, -a2!, .2

x1 = x + r1 * .9: y1 = y + r1 * .05
Circle (x1, y1), r1 * .1, c4, , , 3: Paint (x1, y1), c4, c4
Circle (x1, y1), r1 * .1, c2, -a1!, -a2!, 3
Circle (x1 + r1 * .02, y1), r1 * .1, c2, -a1!, -a2!, 3
x1 = x + r1 * .7: y1 = y + r1 * .2
Circle (x1, y1), r1 * .15, c4, , , 1.5: Paint (x1, y1), c4, c4
Circle (x1, y1), r1 * .15, c2, -a1!, -a2!, 1.5
Circle (x1 + r1 * .02, y1), r1 * .15, c2, -a1!, -a2!, 1.5
x1 = x + r1 * .62: y1 = y - r1 * .35
Circle (x1, y1), r1 * .05, c4, , , 1.2: Paint (x1, y1), c4, c4
Circle (x1, y1), r1 * .05, c2, -a1!, -a2!, 1.2
Circle (x1 + r1 * .02, y1), r1 * .05, c2, -a1!, -a2!, 1.2
Return

DSTG7:
c1 = 1: c2 = 9: c3 = 11: c4 = 15: c5 = 2: c6 = 10
For n = 1 To 32
    x = 320 * Rnd: y = 200 * Rnd: c = 7 + Int(2 * Rnd) * 8
    PSet (x, y), c
Next n
x = -20: y = 330: r1 = 300
Circle (x, y), r1, c1: Paint (0, 199), c1, c1
Circle (x, y), r1 * .985, c2: Paint (0, 199), c2, c2
Circle (x, y), r1 * .97, c3: Paint (0, 199), c3, c3
Circle (x, y), r1 * .955, c4: Paint (0, 199), c4, c4
Circle (x, y), r1 * .94, c3: Paint (0, 199), c3, c3
Circle (x, y), r1 * .925, c2: Paint (0, 199), c2, c2
Circle (x, y), r1 * .91, c1: Paint (0, 199), c1, c1
y1 = 0
Restore EARTH
Do
    x0 = x1: y0 = y1: Read x1, y1
    If y0 > 0 And y1 > 0 Then Line (x0, y0)-(x1, y1), c5
Loop Until x1 = -1 And y1 = -1
Paint (0, 199), c6, c5
Paint (130, 199), c6, c5
Return

EARTH:
Data 0,119,24,121,40,124,70,134,69,138,62,140,79,148,73,148,84,155
Data 82,154,86,157,88,162,80,161,70,158,73,164,88,172,70,182
Data 52,180,48,183,52,187,51,193,46,193,62,199,0,0
Data 108,199,114,186,124,177,123,172,131,172,138,185,144,186,147,192
Data 154,194,161,195,165,199
Data -1,-1

Rem  - - - - - - - - - - - - - - - - - - - - - - - - - - -

LOAD.SPRITES:
ENEMY$(1, 0) = "br5h8d4g4f4d4e8bl5"
ENEMY$(1, 1) = "br4h5d3g2f2d3e5bl4"
ENEMY$(1, 2) = "br6h5l2d10r2e5bl2"
ENEMY$(1, 3) = "bl1h7d5g2f2d5e7bl3"
ENEMY$(2, 0) = "br4e2h8g6f4g4f6e8h2bl4"
ENEMY$(2, 1) = "bl4e4f4g4h4br4"
ENEMY$(3, 0) = "e7l14f3d8g3r14h7bl1"
ENEMY$(3, 1) = "br6bu5l10bd10r10"
ENEMY$(4, 0) = "bu3br5d6g6l6e6u6h6r6f6bd3bl3"
ENEMY$(4, 1) = "bl5d3g5r4e5u6h5l4f5d3br2"
ENEMY$(5, 0) = "br3f3g3h3g5h3e5h5e3f5e3f3g3bl2"
ENEMY$(5, 1) = "br2e3d6h3br1"
ENEMY$(6, 0) = "g9l5e3u3e3h3u3h3r5f9bl4"
ENEMY$(6, 1) = "bl7e2r8f2g2l8h2br7"
ENEMY$(7, 0) = "h5l5f5g5r5e5bl3"
ENEMY$(7, 1) = "bl4u2r16f1r4f1g1l4g1l16u2l3br8"
ENEMY$(8, 0) = "bu4br7d8g4l6h5u8e4r6 f5"
ENEMY$(8, 1) = "bl1bd1g5l8e5r8bl7bd3"
ENEMY$(9, 0) = "bd5br6g2l4h5u7e4r2 l1"
ENEMY$(9, 1) = "bd10bl4e3r5g4l4u1br3bu2"
ENEMY$(10, 0) = "br7g9l3h3u3e3h3u3e3r3f9bl7"
ENEMY$(10, 1) = "br7g3l6h3e3r6f3bl8"
ENEMY$(10, 2) = "br6g4l10h2u4e2r10f4bl6"
ENEMY$(10, 3) = "br7g3l6h3e3r6f3bl7"
ENEMY$(11, 0) = "br7g9l3h3u3e3h3u3e3r3f9bl7"
ENEMY$(11, 1) = "br7g3l6h3e3r6f3bl8"
ENEMY$(11, 2) = "br6g4l10h2u4e2r10f4bl6"
ENEMY$(11, 3) = "br7g3l6h3e3r6f3bl7"

CRASH$(1) = "br4bu4h8d8g8r8f8u8e8l8bd4"
CRASH$(2) = "br4f4l4d4h4g4u4l4e4h4r4u4f4e4d4r4g4bl4"
CRASH$(3) = "br4d8h4l8e4u8f4r8g4bl4"

SHOT$(1) = "bl2bu2r2d4r2"
SHOT$(2) = "bl2bu2r4d4l4u4"
Return

LOAD.CHARSET:
CH$(0) = "br1r3f2d4g1l3h2u4e1"
CH$(1) = "br3ng1d7nl2r2"
CH$(2) = "bd2u1e1r3f1d1g2l1g2d1r5"
CH$(3) = "r5g3r2f1d2g1l3h1"
CH$(4) = "br4bd7u7g4d1r5"
CH$(5) = "br5l5d2r4f1d3g1l3h1"
CH$(6) = "br5l2g3d2f2r3e1u1h2l3g1"
CH$(7) = "r5d1g3d3"
CH$(8) = "br2r2f1d1g1l3g1d2f1r4e1u1h2l2h2e1r1"
CH$(9) = "bd7br1r2e3u2h2l3g1d1f2r3e1"
CH$(17) = "bd7u3nr5u2e2r1f2d5"
CH$(18) = "nd7r3f1d1g1bl3r4f1d2g1l4"
CH$(19) = "br4l2g2d4f1r3e1"
CH$(20) = "bd7u7r4f1d4g2l3"
CH$(21) = "nr4d3nr3d3f1r4"
CH$(22) = "br5l4g1d2nr3d4"
CH$(23) = "br4l2g2d4f1r3e1u3l2"
CH$(24) = "d7bu4r5bu3d7"
CH$(25) = "br2r2bl1d7bl1r2"
CH$(26) = "br1r4d5g2l2u1"
CH$(27) = "d7bu4r1ne3nf4"
CH$(28) = "d7r5"
CH$(29) = "bd7u6e1f2e2f1d6"
CH$(30) = "bd7u7f5nd2u5"
CH$(31) = "br2r2f1d4g2l2h1u4e2"
CH$(32) = "bd7u7r4f1d2g1l4"
CH$(33) = "br1r2f2d4nh2nf1g1l2h2u4e1"
CH$(34) = "bd7u7r4f1d1g1l4br1f4"
CH$(35) = "br5l3g2f1r3f1d2g1l5"
CH$(36) = "r6bl3d7"
CH$(37) = "d5f2r3e1u6"
CH$(38) = "d6f1e4u3"
CH$(39) = "d6f1e2nu2f2e1u6"
CH$(40) = "r1f2d3f2r1bl6r1e2bu3e2r1"
CH$(41) = "d2f3nd2e3u2"
CH$(42) = "r6d1g6r6"
Return

LOAD.SOUNDS:
Rem 2,7,10,13,15,19,22,25,27,31,34,39,43,46,58
SLASER1$ = "MBT255l64n58n57n56n55n54"
SLASER2$ = "MBT255l48n58n56n54n52n58n56n54n52"
SSHOOT1$ = "MBT255l64n63n61n58n55n58"
SSHOOT2$ = "MBT255l64n61n58n55"
SSHOOT3$ = "MBT255l48n7n10n7"
SETYPE1$ = "MBT255l32n39n34n31n27n25n22n19n15n13n10n7n2"
SETYPE2$ = "MBT255l40n60n59n58n57n19n13n10n7n2n7n5n1n3n1n2n1"
SETYPE3$ = "MBT255l32n36n24n1n17n2n19n0n11n1n15n3n17n2n9n1n6n2n4n1n3n1"
SETYPE4$ = "MBT255l64n50n48n45n41n36n50n47n43n37n33n26n19n12n1n9n1n7n1n5n1n3n1"
SETYPE6$ = "MBT255l40n39n31n25n19n13n7n2n7n10n7n13n15n19n15n22n25n27n25n31n34n39n34n43n46"
SETYPE8$ = "MBT255l32n2n7n10n13n15n19n22n25n27n31n34n39n43n46n58"
SETYPE9$ = "MBT255l40n58n46n43n39n34n31n27n25n22n19n15n13"
SETYPE10$ = "MBT255l32n56n55n53n50n45n43n41n40n41n43n45n50n53n55n56"
SETYPE11$ = "MBT255l64n70n69n68n67n66n65n64n63n62n61n60"
SCRASH8$ = "MBT255l64n58n25n19n13n10n7n2n7n5n1n3n1n2n1"
SCRASH9$ = "MBT255l32n30n1n23n2n19n3n14n2n15n1n11n1n7n1n4n1n5n1n3n1n2n1n0n1n3n1n2n1"
SNEW1$ = "MBT255l24n58n57n58n53n57n58"
SNEWPL1$ = "MBT255l3n25n32"
SNEWPL2$ = "MBT255l8n25n32"
SDOCK2$ = "MBT255l32n15n17n15n17n20n25n29n32n37"
SRGTON$ = "MBT80l24n27n0l24n27n29n34n31n34n31l12n29l24n29n32l6n36l24n38n34n31n38n34n31n38n34l12n39l24n38l8n39"
SLAUNCH$ = "MBT96l64n27l8n22l16n22l4n27n34l16n0n22MLl4n27n34MSl24n39n0n0l32n39n0l48n39n0l64n39n0n39n0l32n39n0n39n0l48n39n0n39n0l24n51MN"
SFAROUT1$ = "MBT80l8n22l12n22l8n26l12n26l8n29l12n29l8n34l12n34l8n22l12n22l8n26l12n26l8n29l12n29l8n34l12n34"
SFAROUT2$ = "MBT80l64n17l8n22l12n22l64n17l8n26l12n26l64n17l8n29l12n29l64n17l8n34l12n34"
SEND$ = "MBT96l6n22l16n27l2n25l16n27l8n25n27n29l16n25n27l48n25n27l12n29l32n27n29n27n29l4n34"
SBONPLAY$ = "MBT64l64n15n22n19n22n19n22n27l32n34"
SHITBOS1$ = "MBT255l64n63n62n61n60n50n40n30n20n13n10n8n7n5n4n3n2n1n1n1"
SBOSPTS$ = "MBT255l64n46n45n44n43n42n41n40n39n38n37n36n35n34"
SSTAGE1$ = "MBMST64l32n40n0n40n40n0n40n40n40n40n0n40n40n0n40n0n40n0n40n40n40n0n40n0MN"
SSTAGE2$ = "MBT255l32n19n22n25n27n31n34n39n43n46"

SFINAL$(1, 1) = "MBMNT64l4n25l24n18n18l4n25l24n18n18l24n25n0n30n0l4n25"
SFINAL$(1, 2) = "MBMNT64l24n18n18l24n25n0n30n0l3n32"
SFINAL$(1, 3) = "MBMNT64l24n23n23l24n28n0n30n0l8n32l24n34l4n35"
SFINAL$(1, 4) = "MBMNT64l6n37l6n34l8n30n28n32n35"
SFINAL$(1, 5) = "MBMLT64l8n39l6n37l6n34l8n30n28n32n35n39l6n42"
SFINAL$(1, 6) = "MBMLT64l64n37n42n49n37n42n49n37n42n49n37n42n49n37n42n49n37n42n49l16n42"
SFINAL$(1, 7) = "MBMLT64"
SFINAL$(2, 1) = "MBMNT64l6n13n15n18n20n25l24n23n22l12n20l6n23l24n22n20l12n18n22n18l6n20"
SFINAL$(2, 2) = "MBMLT64l64n25n30n37MNl16n0l24n13n13n18n0n18n18n20n0n20n20n25n0n25n25n23n22n20n0"
SFINAL$(2, 3) = "MBMNT64l24n23n0n23n23n22n20n18n0l12n22l24n23n0n18n0n22n0l4n20"
SFINAL$(2, 4) = "MBMNT64l16n8n8n8n0n8n0n8n0n8n8n8n0n8n0"
SFINAL$(2, 5) = "MBMNT48l64n20l4n32MLl12n32n30n29n27n25l4n30l24n32n34l4n32"
SFINAL$(2, 6) = "MBMNT48l12n8l4n32MLl12n32n30n29n27T64n25l4n35l24n37n39"
SFINAL$(2, 7) = "MBMLT64l64n25n37n25n37n25n37n25n37n25n37n25n37n25n37n25n37l8n37"
Return

CREDITS:
Data " "," "," "
Data "   YOU SAVED","   THE GALAXY"," "," "," "," "
Data " CONGRATULATIONS"," ","  THE MISSION","IS ACCOMPLISHED"
Data " ","THE ALIENS HAVE","     LEFT"," AND THE EARTH"
Data "  IS NOW FREE"," ","YOU HAVE BROUGHT"," BACK PEACE TO"
Data "   OUR GALAXY"," ","WE WILL THANK"," YOU FOREVER"
Data " ","    THE FORCE","WILL BE WITH YOU","     ALWAYS"
Data " "," "," "," ","     THE END"


TITLE.HELP:
Restore THELP.TEXT
Screen 7, 0, 2, 2: tcnt = 0: tpos = 0: sss = 0
Cls: Color 15, 1

THELP.MAIN:
k = Inp(96): k$ = InKey$: da = 0
If k = 1 Then Color 15, 0: Screen 7, 0, scr, scr: GoTo WAITKEY0
Wait &H3DA, 8: Wait &H3DA, 8, 8
If tcnt < 22 Then GoSub THELP.SOFT
If k = 80 Or k = 77 Or tcnt < 22 Then GoSub THELP.SCROLL
If k = 72 Then Restore THELP.TEXT: Cls: tcnt = 0: tpos = 0: sss = 0
GoTo THELP.MAIN

THELP.SOFT:
a = 16024 + (tpos) * 80
Out &H3D4, 12: Out &H3D5, Int(a / 256)
Out &H3D4, 13: Out &H3D5, a And 255
Return

THELP.SCROLL:
tpos = (tpos + 1) And 3
If tpos <> 2 Or sss > 0 Then Return
Locate 24, 1: Read T$: Print T$: tcnt = tcnt + 1
If T$ = "XXX" Then sss = 1
If SND = 1 Then Sound 600, .2
Return

THELP.TEXT:
Data "- INCOMING MESSAGE -"
Data ""
Data "                        16.Dec. 2011"
Data ""
Data "THE UNITED EARTH ADMINISTRATION"
Data "- - - - - - - - - - - - - - - -"
Data ""
Data ""
Data "ALIENS HAVE INVADED TO OUR GALAXY."
Data "THEY BUILD BASES TO NEARBY STARS "
Data "IN RANGE OF SEVERAL LIGHT YEARS."
Data "BEFORE WE COULD START ANY COUNTER"
Data "MEASURES TO PROTECT OURSELF,"
Data "THEY NOTICED OUR TELEMITRY SIGNALS,"
Data "SENT BETWEEN THE EARTH AND OUR"
Data "SATELLITES "
Data ""
Data "THEY REACHED OUR SOLAY SYSTEM AND"
Data "INSTANTLY OCCUPIED ONE PLANET"
Data "AFTER ANOTHER, STARTING WITH PLUTO"
Data "OVER TO NEPTUN, SATURN, JUPITER AND"
Data "FINALLY THE EARTH MOON, WHERE THEY  >>"
Data "LOCATED THEIR GIANT NEXUS MOTHERSHIP"
Data ""
Data "WITH DESTROYING OUR SPACE STATION"
Data "AND SEVERAL ORBIT SHUTTLES, COSTING"
Data "OVER 10.000 HUMAN LIFES, THEYïVE"
Data "DEMONSTRATED THEIR EXTREMELY AGRESSIVE"
Data "INTENTIONS"
Data ""
Data "ITS ASSUMED FOR CLEAR THAT THE"
Data "MOTHERSHIP PREPARES FOR THE FINAL"
Data "ATTACK ON THE EARTH"
Data "AND IF THIS HAPPENS MANKIND CAN KISS"
Data "THE DAYïS GOODBYE, THATS FOR SURE"
Data ""
Data "GOD, WE NEED SOMEONE WHO BLOWS THESE"
Data "BASTARDS TO PIECES !"
Data "WE NEED TO DESTROY ALL THEIR HOMEBASES"
Data "TO BREAK UP THEIR SUPPLY LINE,"
Data "STARTING AT THE VEGA CONSTELLATION"
Data "37 LIGHTYEARS AWAY"
Data ""
Data ">> So, fine, but what has all this"
Data "to do with me ? << YOU ASK"
Data ""
Data "CAUSE ALL OUR ASTRONAUTS HAVE SUDDENLY"
Data "GONE ON VACATION 3 DAYS AGO,"
Data "WE ENGAGED YOU. YOUïRE OUR LAST HOPE !"
Data ""
Data "ALTHOUGH YOURE NO ASTRONAUT, NOT EVEN"
Data "A PILOT, THAT DOESNïT REALLY MATTER."
Data ""
Data "WEïVE SIMPLIFIED THE SHIPïS CONTROLS SO"
Data "THAT EVEN AN AVERAGE CLEVER SPACE-COW"
Data "CAN FLY IT"
Data "LOOK, ITS REALLY EASY:"
Data "","",""
Data "- - - - - - - - - - - - - - - - - - -"
Data "Lunar Module Control Keys"
Data "","",""
Data "Arrow Left / Num 4    = Move Left "
Data "Arrow Left / Num 6    = Move Right"
Data "Left Strg             = Fire / Thrust"
Data "S                     = Sound On/Off"
Data "P                     = Pause"
Data ""
Data "Hint:"
Data "Use the Num-Keys for better control"
Data "","",""
Data "Bonus Ship given every 20000 Pts"
Data "Successful Docking increases Firepower"
Data "Hitpoints increase every Stage"
Data ""
Data "- - - - - - - - - - - - - - - - - - -"
Data "","","",""
Data "YOU ARE SUPPLIED WITH 3 SEPERATE LUNAR"
Data "MODULES, OUTFITTET WITH A STAR-DRIVE"
Data "AND HIGH-VOLTAGE PLASMA LAUNCHERS"
Data ""
Data "THE MODULES CAN BE FLOWN SEPERATLY OR"
Data "CONNECTED, WHICH GIVES AN EXTRA"
Data "FIRE-POWER."
Data "HOWEVER, TO SAVE MODULES, THEY ARE"
Data "DISCONNECTED AUTOMATICALLY WHEN POSSIBLE"
Data "OR WHEN ONE OF THEM GETS DESTROYED."
Data ""
Data "IF THIS HAPPENS, YOU SHOULD BE EJECTED"
Data "AND WHEN YOUïVE BEEN EJECTED, YOU"
Data "SHOULD ENTER THE NEXT INTACT SECTION"
Data "AUTOMATICALLY."
Data ""
Data "- Why SHOULD ?"
Data ""
Data "THE SYSTEMïS NOT PERFECT YET, CAUSE"
Data "THE SHIPïS COMPUTER CRASHES FROM"
Data "TIME TO TIME. BUT DONïT PANIC,"
Data "OUR ENGINEERS WILL FIX THAT BY SENDING"
Data "YOU UPDATE VERSIONS OF THE SHIPïS"
Data "COMPUTERïS OPERATING SYSTEM"
Data "(Windows 2011 v4.1.0.2.1-beta-beta)"
Data ""
Data ""
Data "THE EARTH BASE WILL TRY TO SUPPLY YOU"
Data "CONSTANTLY WITH NEW MODULES"
Data ""
Data "BUT PLEASE HANDLE WITH CARE,"
Data "WE CANïT BAKE THEM LIKE BREADS"
Data ""
Data "GOOD LUCK!"
Data "","","","",""
Data "END OF MESSAGE."
Data "","","","","","","","","","","",""
Data "GAME INFO"
Data ""
Data "This programm was intended as a tutorial"
Data "for beginners who want to learn"
Data "programming in Qbasic, demonstrating"
Data "some of its capabillities for making"
Data "sound and graphics."
Data "It uses PLAY and SOUND for music and"
Data "most of the Graphic functions,"
Data "exspecially the DRAW Command for Sprites"
Data "(which lets you rotate and scale)."
Data "Even if some of the letters look like"
Data "vectors, but they are all DRAW-Sprites"
Data ""
Data "The inspiration and ideas i lend"
Data "(took, stole) from following games:"
Data "Mooncresta arcade game (1983)"
Data "Galaga 88 arcade"
Data "Space Pilot I-II (C64)"
Data "(They belong to my all-time favorite"
Data "shoot-em-ups)"
Data ""
Data "In the beginning i just wanted to make"
Data "a simple shooter (what it still is) but"
Data "then those old shooting games came to"
Data "mind, exspecially Mooncresta (obviously"
Data "you can see where i got the title),"
Data "which i played as a kid totally"
Data "fascinated me."
Data "Those games had great graphics and"
Data "sound (for this time) and where FUN"
Data "to play."
Data "So i also wanted to put in something of"
Data "these games, and as the programm grew"
Data "bigger and bigger, i decided to make a"
Data "complete game of it, and hereïs whats"
Data "the result."
Data "(hope you like this piece of ïcrapï)"
Data "",""
Data "Mooncr.99 made by Daniel Kupfer"
Data "in Nov.1999"
Data "Mail me if U like"
Data "EMail dk1000000@aol.com"
Data "   or dku1000000@cs.com"
Data "","","",""
Data "Machine Requirements:"
Data "",""
Data "Qbasic:   Pentium 200"
Data "Compiled: 486-66 / Pentium 66"
Data ""
Data "As its Qbasic you need decent computer"
Data "power to run at full speed (35 frames)"
Data "It works just fine on my P-II 233"
Data "Iïve never tried to compile this"
Data "with Quick Basic"
Data "ïcause i donït own Quick Basic, but if"
Data "it works, i guess its gonna be 5 times"
Data "faster or so (however it never runs"
Data "more than 35 frames)"
Data "",""
Data "Enjoy !"
Data "If you liked it, ask for upcoming"
Data "mooncr.2000"
Data ""
Data "SEE YA!"
Data "","",""
Data "PRESS ESC"
Data "XXX"

