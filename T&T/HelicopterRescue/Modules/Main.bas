'
'  Copyright 2023 Arnold Kramer, T&T WARE
'
'  Contact:   tijdelijkkistjeskerel@gmail.com
'
'  VERSION 20240707 1.6.19
'
$EXEICON:'./../Resources/HRexe.ico'
_TITLE "Helicopter Rescue - Main"
DECLARE SUB Mouse (Funk)
DEFINT A-Z

OPEN "..\TXTFiles\ZOOM.TXT" FOR INPUT AS #1
INPUT #1, Zoom#
CLOSE #1




OPEN "..\TXTFiles\VOLUME.TXT" FOR INPUT AS #1
INPUT #1, Volume
CLOSE #1

OPEN "..\TXTFiles\SKY.TXT" FOR INPUT AS #1
INPUT #1, Sky$
CLOSE #1
'
OPEN "..\TXTFiles\BIRDS.TXT" FOR INPUT AS #1
INPUT #1, AantalVogels
CLOSE #1

Pct$ = LTRIM$(STR$(Volume))
'
ostipkleur = 163
'        *************************************************
SkyColor = 6
GrondColor = 173

'*************************************************************

Buitenmarge = 400 '

'
Basisdx# = 0
Basisdy# = 0
Basisdz# = 0

MaxObjects = 60


SchadeTailRotor = 0
SchadeFuel = 0

tar = 0 'totaal aantal raak
tak = 0 'totaal aantal kogels

RandomSeed = 48
ShowBlades = 1

Rotorcolor = 120




VmaxLanding = 25
KantelmaxLanding# = .06

tk1 = 0: tk2 = 1















RFileNr = 0 '     START RESCUES = LEVEL 1

griddensity = 100

FOR k = 1 TO RandomSeed: l = RND: NEXT

ThrottleDeadZone! = .25 '      25% deadzone
StickDeadZone! = .1

BaseBullets = 0
BaseFuel = 0 '         Gallons

CONST FPSTarget = 50

CONST pi# = 3.14159265358979323846264338327950288
CONST pf# = (180 / pi#)
CONST worldx# = 5000 '           '\
'                                  | Afmetingen raster-wereld
CONST worldz# = 5000 '            /
CONST maxkogelweg# = 5000
CONST gravitatie# = .00025 '     [Feet^2 per (n-cycles)^2]
CONST MaxKogels = 50
CONST kogelsnelheid# = 24
CONST camspeed# = 2.75
CONST camhoekspeed# = .125
CONST helgrensvooruit# = .55 '     BEPALEN MEDE DE MAXIMUM SNELHEID VOOR- EN ACHTERUIT
CONST helgrensachteruit# = .35 '
CONST aantalsterren = 50

CONST vogelspeed# = .4 'approx. 20 KTS
CONST vogelstijgspeed# = 1 / 40



CONST hoekjesstap = 3 '                             radar stap, grafisch
CONST straaltje = 32 '               radar-
CONST straaltje2 = 64 '                    cirkels
Knippert1 = 1: Knippert2 = 0
Knipper1 = 1: Knipper2 = 0
KnipperTR1 = 1: KnipperTR2 = 0
KnipperFL1 = 1: KnipperFL2 = 0
Knipper3 = 1: Knipper4 = 0

KnipperTellerMax& = FPSTarget / 4

'
AantalObjecten = 28 'LET OP!!! komt 4 bij aan het begin



MaximaleObjectAfstand = 2000

REDIM bulk1(0 TO 150000)
REDIM bulk2(0 TO 150000)
REDIM pauseback(0 TO 100000)
REDIM Pause(0 TO 100000)
REDIM PauseMask(0 TO 100000)


REDIM xlo0#(0 TO 499): REDIM ylo0#(0 TO 499): REDIM zlo0#(0 TO 499)
REDIM xlo1#(0 TO 499): REDIM ylo1#(0 TO 499): REDIM zlo1#(0 TO 499)
REDIM xlo2#(0 TO 499): REDIM ylo2#(0 TO 499): REDIM zlo2#(0 TO 499)
REDIM xlo3#(0 TO 499): REDIM ylo3#(0 TO 499): REDIM zlo3#(0 TO 499)
REDIM xlo4#(0 TO 499): REDIM ylo4#(0 TO 499): REDIM zlo4#(0 TO 499)
REDIM klo(0 TO 499)

REDIM xlp0#(1 TO 4, 0 TO 99): REDIM ylp0#(1 TO 4, 0 TO 99): REDIM zlp0#(1 TO 4, 0 TO 99)
REDIM xlp1#(1 TO 4, 0 TO 99): REDIM ylp1#(1 TO 4, 0 TO 99): REDIM zlp1#(1 TO 4, 0 TO 99)
REDIM xlp2#(1 TO 4, 0 TO 99): REDIM ylp2#(1 TO 4, 0 TO 99): REDIM zlp2#(1 TO 4, 0 TO 99)
REDIM xlp3#(1 TO 4, 0 TO 99): REDIM ylp3#(1 TO 4, 0 TO 99): REDIM zlp3#(1 TO 4, 0 TO 99)
REDIM xlp4#(1 TO 4, 0 TO 99): REDIM ylp4#(1 TO 4, 0 TO 99): REDIM zlp4#(1 TO 4, 0 TO 99)
REDIM klp(1 TO 4, 0 TO 99)
af = 1

REDIM rescue(0 TO 100)
REDIM afstandwp#(0 TO 100)
REDIM xwp#(0 TO 100)
REDIM ywp#(0 TO 100)
REDIM zwp#(0 TO 100)
REDIM txt$(0 TO 100)

REDIM xk#(0 TO MaxKogels - 1)
REDIM yk#(0 TO MaxKogels - 1)
REDIM zk#(0 TO MaxKogels - 1)
REDIM sxk#(0 TO MaxKogels - 1)
REDIM syk#(0 TO MaxKogels - 1)
REDIM szk#(0 TO MaxKogels - 1)
REDIM schietstatus(0 TO MaxKogels - 1)
REDIM x#(0 TO 1999, 0 TO 4)
REDIM y#(0 TO 1999, 0 TO 4)
REDIM z#(0 TO 1999, 0 TO 4)
REDIM kleur(0 TO 1999)



OPEN "..\TXTFiles\HITBALLS.TXT" FOR INPUT AS #1
'
INPUT #1, HitHightPerson
INPUT #1, HitBallPerson

INPUT #1, HithoogteOmax
INPUT #1, Object1HitBall
INPUT #1, Object2HitBall
INPUT #1, Object3HitBall
'
INPUT #1, Hithoogtemax
INPUT #1, HitBallSportscar
INPUT #1, HitBallJeep
INPUT #1, HitBallTank
INPUT #1, HitBallSupplytruck
CLOSE #1



OPEN "..\TXTFiles\RADAR.TXT" FOR INPUT AS #1
INPUT #1, radar$
CLOSE #1


OPEN "..\TXTFiles\DIFF.TXT" FOR INPUT AS #8
INPUT #8, NumberOfEnemiesActive
CLOSE #8

OPEN "..\TXTFiles\MODE.TXT" FOR INPUT AS #1
INPUT #1, Mode$
CLOSE #1

OPEN "..\TXTFiles\DEVICES.TXT" FOR INPUT AS #1
INPUT #1, NoDevicesConnected
CLOSE #1

OPEN "..\TXTFiles\" + "SPEED.TXT" FOR INPUT AS #1
INPUT #1, fastslow$
CLOSE #1

OPEN "..\TXTFiles\" + "RECDEMO.TXT" FOR INPUT AS #1
INPUT #1, RecDemo$
CLOSE #1
'
'OPEN "..\TXTFiles\" + "RECDEMO.TXT" FOR OUTPUT AS #1
'PRINT #1, "OFF"
'CLOSE #1

IF LEFT$(UCASE$(RecDemo$), 2) = "ON" THEN
    RecordDemo = 1
    controller$ = "MOUSE" 'Default control type when recording REPLAY.mcr
ELSE
    RecordDemo = 0
    OPEN "..\TXTFiles\CONTROL.TXT" FOR INPUT AS #1
    INPUT #1, controller$ 'Default control type when NOT recording REPLAY.mcr     MOUSE/KEYBOARD/JOYSTICK
    CLOSE #1
END IF

IF controller$ = "MOUSE" THEN ShowCursor = 1 ELSE ShowCursor = 0


Invert = 1

AEN = 1
AENmax = 19

REDIM xvijand#(1 TO AENmax, 0 TO 1999, 0 TO 4)
REDIM yvijand#(1 TO AENmax, 0 TO 1999, 0 TO 4)
REDIM zvijand#(1 TO AENmax, 0 TO 1999, 0 TO 4)
REDIM kleurvijand(1 TO AENmax, 0 TO 1999)

REDIM xITMZwaartepunt#(1 TO AENmax)
REDIM yITMZwaartepunt#(1 TO AENmax)
REDIM zITMZwaartepunt#(1 TO AENmax)
REDIM HitAfstand#(1 TO AENmax)
REDIM vijanddx#(1 TO AENmax)
REDIM vijanddy#(1 TO AENmax)
REDIM vijanddz#(1 TO AENmax)
REDIM vijandType(1 TO AENmax)
REDIM sxvijand#(1 TO AENmax)
REDIM syvijand#(1 TO AENmax)
REDIM szvijand#(1 TO AENmax)
REDIM jndamage(1 TO AENmax)
REDIM yU(1 TO AENmax)
REDIM enemydamage(1 TO AENmax)
REDIM firstTimeWarnNOT(1 TO AENmax)
REDIM l(1 TO AENmax)
REDIM hoek(1 TO AENmax)
REDIM VijandSpeed#(1 TO AENmax)
REDIM VijandAfstand#(1 TO AENmax)
REDIM VijandHoek#(1 TO AENmax)
REDIM RadarDotType(1 TO AENmax)
REDIM vijand$(1 TO AENmax)
REDIM Distance#(1 TO AENmax)
REDIM Radarhoek#(1 TO AENmax)
REDIM xRadar(1 TO AENmax)
REDIM yRadar(1 TO AENmax)
REDIM Wreck(1 TO AENmax)
REDIM roodflits(1 TO AENmax)
REDIM xobject#(0 TO MaxObjects, 0 TO 499, 0 TO 4)
REDIM yobject#(0 TO MaxObjects, 0 TO 499, 0 TO 4)
REDIM zobject#(0 TO MaxObjects, 0 TO 499, 0 TO 4)
REDIM kleurobject(0 TO MaxObjects, 0 TO 499)
REDIM v(0 TO 10000)
REDIM xster#(1 TO aantalsterren)
REDIM yster#(1 TO aantalsterren)
REDIM zster#(1 TO aantalsterren)
REDIM sterkleur(1 TO aantalsterren)
'
REDIM xvogel#(1 TO AantalVogels)
REDIM yvogel#(1 TO AantalVogels)
REDIM zvogel#(1 TO AantalVogels)
REDIM xv1#(1 TO AantalVogels)
REDIM yv1#(1 TO AantalVogels)
REDIM xv2#(1 TO AantalVogels)
REDIM yv2#(1 TO AantalVogels)
REDIM vogelyspeed#(1 TO AantalVogels)




REDIM PlayerName$(1 TO 10)
REDIM PlayerScore&(1 TO 10)
REDIM PlayerLevel(1 TO 10)
REDIM PlayerSeconds&(1 TO 10)
REDIM PS$(1 TO 10)
REDIM min$(1 TO 10)
REDIM sec$(1 TO 10)
REDIM FuelTotal#(1 TO 10)
REDIM RoosMask(0 TO 5000)
REDIM Roos(0 TO 5000)
REDIM rec(0 TO 1000) '
REDIM recMask(0 TO 1000)
REDIM recBackground(0 TO 1000)
REDIM moon(0 TO 5000)
REDIM VinkMask(0 TO 200)
REDIM Vink(0 TO 200)
REDIM mux(0 TO 2500)
REDIM muxMask(0 TO 2500)



REDIM objectdx#(1 TO MaxObjects)
REDIM objectdy#(1 TO MaxObjects)
REDIM objectdz#(1 TO MaxObjects)
REDIM ObjectYesNo(1 TO MaxObjects)
REDIM ObjectDistance#(1 TO MaxObjects)
REDIM ObjectRadarhoek#(1 TO MaxObjects)


'
'SheepFactor# = .01
'NumberOfSheep = 20

'REDIM xSheep#(1 TO NumberOfSheep)
'REDIM ySheep#(1 TO NumberOfSheep)
'REDIM zSheep#(1 TO NumberOfSheep)
'REDIM sxSheep#(1 TO NumberOfSheep)
'REDIM sySheep#(1 TO NumberOfSheep)
'REDIM szSheep#(1 TO NumberOfSheep)
'REDIM SheepDistance#(1 TO NumberOfSheep)
'REDIM SheepRadarhoek#(1 TO NumberOfSheep)


FOR SheepNr = 1 TO NumberOfSheep
    angl# = 2 * pi# * RND
    dist# = 1000 * RND

    xSheep#(SheepNr) = dist# * SIN(angl#)
    ySheep#(SheepNr) = 0
    zSheep#(SheepNr) = dist# * COS(angl#)
NEXT


























GOSUB NewObjects

GOSUB loadperson

DamageTextElevation = 24

ShowCoordinates = 1

Damage = 0
DelayTime# = .002 '              sec. Delay
vertraging = 0 '                      DELAY ja of nee
full = 0 '                       Fullscreen=off (1=on)
'
FOR avnu = 1 TO 7: LLock(avnu) = 1: NEXT

OPEN "..\TXTFiles\CURRENT.TXT" FOR INPUT AS #8
INPUT #8, Bestand$
CLOSE #8

OPEN "..\TXTFiles\" + "FPS.TXT" FOR INPUT AS #1
INPUT #1, OverallFramerate
CLOSE #1
muxer! = 1

NumberOfBullets = 0

FuelTotalUsed# = 0

fuelmax# = 230 '                230 gallon max.

itmscale = 4 '                   Schaal Item        (zie 'loaditm:')
itmdx = -14 * itmscale '         Item offset              \
itmdy = 0 * itmscale '           van                       } BJC.exe Geldt voor Scene en Enemy
itmdz = -14 * itmscale '         item                     /

xoffset# = 10
yoffset# = 0
zoffset# = 10

verbruik# = .005
schaaly# = 5
schaalx# = 8
cambreedte# = 2
camhoogte# = 1.125

levelhoogte$ = "off"
os# = .048 '                     versnelling up
ds# = .008 '                     versnelling down
refuelspeed# = 300

ymin = 6 '                                  grondlevel
yc3ondergrens# = ymin + .1

landingstolerantie# = 25
waypointstolerantie# = 50
grootte = 50 '                              array karakters
hoekje = 0
hoekje2 = 45
maan = 1 '                            maan aan of uit
maankleur = 11
maanstraal = 7
frames = 0
FPSShow = 0
s1 = 1: s0 = 0

GOSUB LoadRescues

waypoint = 0
xland# = xwp#(waypoint) + .00000001 '        \   <>0 (vervorming bij start)
yland# = ywp#(waypoint) '                    | Thuisbasis (zonder hitbox)
zland# = zwp#(waypoint) '                    /

FOR S = 1 TO aantalsterren
    hulp:
    xster#(S) = 50000000 - 100000000 * RND
    yster#(S) = 50000000 * RND
    zster#(S) = 50000000 - 100000000 * RND
    sterkleur(S) = 9 + 4 * RND
    IF SQR((xster#(S) - worldx# / 2) ^ 2 + (yster#(S) - 0) ^ 2 + (zster#(S) - worldz# / 2) ^ 2) < 10000000 GOTO hulp
NEXT




'  vogelcoordinaten

'For vnr = 1 To AantalVogels
'    vogelyspeed#(vnr) = vogelstijgspeed#
'    xvogel#(vnr) = -1503 - 6 * Rnd
'    zvogel#(vnr) = -1503 - 6 * Rnd
'    yvogel#(vnr) = 250.3 - .6 * Rnd
'Next

FOR vnr = 1 TO AantalVogels
    vogelyspeed#(vnr) = vogelstijgspeed#
    xvogel#(vnr) = -1500 + (AantalVogels - 1) * RND
    zvogel#(vnr) = -1500 + (AantalVogels - 1) * RND
    yvogel#(vnr) = 250.3 - .6 * RND
NEXT



xmaan# = -300000
ymaan# = 150000
zmaan# = 700000
''
'xzon# = -300000
'yzon# = 150000
'zzon# = 700000

xc1# = xland# - cambreedte# / 2: yc1# = ymin + camhoogte#: zc1# = zland#
xc2# = xland# + cambreedte# / 2: yc2# = ymin + camhoogte#: zc2# = zland#
xc3# = xland# + cambreedte# / 2: yc3# = ymin: zc3# = zland#
xc4# = xland# - cambreedte# / 2: yc4# = ymin: zc4# = zland#

xc5# = (xc1# + xc2#) / 2: yc5# = (yc2# + yc3#) / 2: zc5# = zland# - Zoom# * camhoogte# 'ZOOM

Gun& = _SNDOPEN("..\OGGFiles\" + "Gun.ogg", "VOL,SYNC")
HitEnemy& = _SNDOPEN("..\OGGFiles\" + "HitEnemy.ogg", "VOL,SYNC")
HitPlay& = _SNDOPEN("..\OGGFiles\" + "HitPlay.ogg", "VOL,SYNC")
Bonus1& = _SNDOPEN("..\OGGFiles\" + "Bonus1.ogg", "VOL,SYNC")
Bonus2& = _SNDOPEN("..\OGGFiles\" + "Bonus2.ogg", "VOL,SYNC")
Bonus3& = _SNDOPEN("..\OGGFiles\" + "Bonus3.ogg", "VOL,SYNC")
Bonus4& = _SNDOPEN("..\OGGFiles\" + "Bonus4.ogg", "VOL,SYNC")
Bonus5& = _SNDOPEN("..\OGGFiles\" + "Bonus5.ogg", "VOL,SYNC")
Bonus6& = _SNDOPEN("..\OGGFiles\" + "Bonus6.ogg", "VOL,SYNC")
Fail& = _SNDOPEN("..\OGGFiles\" + "Fail.ogg", "VOL,SYNC")
Dingdong& = _SNDOPEN("..\OGGFiles\" + "Dingdong.ogg", "VOL,SYNC")
Rescue& = _SNDOPEN("..\OGGFiles\" + "Rescue.ogg", "VOL,SYNC")
Blades& = _SNDOPEN("..\OGGFiles\" + "Blades.ogg", "VOL,SYNC")
Damage& = _SNDOPEN("..\OGGFiles\" + "Damage.ogg", "VOL,SYNC")
Garage& = _SNDOPEN("..\OGGFiles\" + "Garage.ogg", "VOL,SYNC")
ThemeA& = _SNDOPEN("..\OGGFiles\" + "ThemeA.ogg", "VOL,SYNC")
ThemeB& = _SNDOPEN("..\OGGFiles\" + "ThemeB.ogg", "VOL,SYNC")
ThemeC& = _SNDOPEN("..\OGGFiles\" + "ThemeC.ogg", "VOL,SYNC")




_SNDVOL Gun&, Volume / 100
_SNDVOL HitEnemy&, Volume / 100
_SNDVOL HitPlay&, Volume / 100
_SNDVOL Bonus1&, Volume / 100
_SNDVOL Bonus2&, Volume / 100
_SNDVOL Bonus3&, Volume / 100
_SNDVOL Bonus4&, Volume / 100
_SNDVOL Bonus5&, Volume / 100
_SNDVOL Bonus6&, Volume / 100
_SNDVOL Fail&, Volume / 100
_SNDVOL Dingdong&, Volume / 100
_SNDVOL Rescue&, Volume / 100
_SNDVOL Blades&, Volume / 100
_SNDVOL Damage&, Volume / 100
_SNDVOL Garage&, Volume / 100
_SNDVOL ThemeA&, Volume / 100
_SNDVOL ThemeB&, Volume / 100
_SNDVOL ThemeC&, Volume / 100



'_Delay .25
SCREEN _NEWIMAGE(800, 450, 256)
_SCREENMOVE _MIDDLE
'_Delay .25

FOR altco = 0 TO 255: PALETTE altco, 0: NEXT

OPEN "..\TXTFiles\DISPLAY.TXT" FOR INPUT AS #4
INPUT #4, screen$
CLOSE #4
IF screen$ = "FULLSCREEN" THEN full = 1
IF screen$ = "WINDOWED" THEN full = 0
IF full = 1 THEN
    _FULLSCREEN _SQUAREPIXELS , _SMOOTH

ELSE
    _FULLSCREEN _OFF
    _SCREENMOVE _MIDDLE
END IF
CLS

RESTORE vink
FOR y = 0 TO 7
    READ line$
    FOR x = 0 TO 8
        Column$ = MID$(line$, x + 1, 1)
        SELECT CASE Column$
            CASE "1": PSET (x, y), 8
        END SELECT
    NEXT
NEXT
GET (0, 0)-(8, 7), Vink(0)
FOR y = 0 TO 7
    FOR x = 0 TO 8
        IF POINT(x, y) = 0 THEN PSET (x, y), 255 ELSE PSET (x, y), 0
    NEXT
NEXT
GET (0, 0)-(8, 7), VinkMask(0)
CLS

RESTORE MuxerData '
FOR nrr = 0 TO 4
    FOR y = 0 TO 7
        READ line$
        FOR x = 0 TO LEN(line$) - 1
            IF MID$(line$, x + 1, 1) = "1" THEN PSET (x, y + nrr * 8), 163 ELSE PSET (x, y + nrr * 8 + 100), 255
        NEXT
    NEXT
NEXT

GET (0, 0)-(17, 7), mux(0)
GET (0, 8)-(17, 15), mux(500)
GET (0, 16)-(17, 23), mux(1000)
GET (0, 24)-(17, 31), mux(1500)
GET (0, 32)-(17, 39), mux(2000)
GET (0, 100)-(17, 107), muxMask(0)
GET (0, 108)-(17, 115), muxMask(500)
GET (0, 116)-(17, 123), muxMask(1000)
GET (0, 124)-(17, 131), muxMask(1500)
GET (0, 132)-(17, 139), muxMask(2000)

CLS

'
RESTORE PauseData
FOR y = 0 TO 33
    READ line$
    FOR x = 0 TO LEN(line$) - 1
        IF MID$(line$, x + 1, 1) <> "0" THEN PSET (x, y), 18 ELSE PSET (x, y + 100), 255
    NEXT
NEXT
GET (0, 0)-(120, 33), Pause(0)
GET (0, 100)-(120, 133), PauseMask(0)
CLS






RESTORE roos
FOR y = 0 TO 55
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (x, y), 164
            CASE ELSE: PSET (x, y), 0
        END SELECT
    NEXT
NEXT
GET (0, 0)-(55, 55), Roos(0)
LINE (0, 0)-(55, 55), 0, BF
RESTORE roos
FOR y = 0 TO 55
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, y), 255
            CASE ELSE: PSET (x, y), 0
        END SELECT
    NEXT
NEXT
GET (0, 0)-(55, 55), RoosMask(0)
CLS

RESTORE rec
FOR y = 0 TO 2
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (x, y), 8
            CASE ELSE: PSET (x, y), 0: PSET (x + 20, y), 255
        END SELECT
    NEXT
NEXT
'
GET (0, 0)-(17, 2), rec(0)
GET (20, 0)-(37, 2), recMask(0)
LINE (0, 0)-(37, 2), 0, BF

RESTORE Set2 '                           Character set (2 of 2)          ******************************************************
FOR nch = 32 TO 38
    dxch = (nch - 32) * 6
    dych = 10
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 255
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), v(nch * grootte)
NEXT
FOR nch = 40 TO 41
    dxch = (nch - 32) * 6
    dych = 10
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 255
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), v(nch * grootte)
NEXT
FOR nch = 43 TO 58
    dxch = (nch - 43) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 255
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), v(nch * grootte)
NEXT
FOR nch = 64 TO 92
    dxch = (nch - 45) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 255
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), v(nch * grootte)
NEXT

RESTORE moondata
FOR yyy = 0 TO 15
    READ aaa$
    FOR xxx = 0 TO LEN(aaa$) - 1
        bbb$ = MID$(aaa$, xxx + 1, 1)
        SELECT CASE bbb$
            CASE "a": PSET (xxx, yyy), 200
            CASE "b": PSET (xxx, yyy), 201
            CASE "c": PSET (xxx, yyy), 202
            CASE "d": PSET (xxx, yyy), 203
            CASE "e": PSET (xxx, yyy), 204
            CASE "f": PSET (xxx, yyy), 205
            CASE "g": PSET (xxx, yyy), 206
            CASE "h": PSET (xxx, yyy), 207
            CASE "i": PSET (xxx, yyy), 208
            CASE "j": PSET (xxx, yyy), 209
            CASE "k": PSET (xxx, yyy), 210
            CASE "l": PSET (xxx, yyy), 211
            CASE "m": PSET (xxx, yyy), 212
            CASE "n": PSET (xxx, yyy), 213
            CASE "o": PSET (xxx, yyy), 214
            CASE "p": PSET (xxx, yyy), 215
            CASE "q": PSET (xxx, yyy), 216
            CASE "r": PSET (xxx, yyy), 217
            CASE ELSE: PSET (xxx, yyy), 0
        END SELECT
    NEXT
NEXT
GET (0, 0)-(15, 15), moon(0)
CLS





FOR altAEN = 1 TO AENmax: roodflits(altAEN) = 249: NEXT

GOSUB loaditm

OPEN "..\TXTFiles\VEHICLES.TXT" FOR INPUT AS #7
FOR altAEN = 1 TO NumberOfEnemiesActive
    AEN = altAEN: GOSUB NextEnemy
NEXT
sec& = 0
resec& = 0

OPEN "..\TXTFiles\TCOCKPIT.TXT" FOR INPUT AS #1
INPUT #1, TotalCockpitTime&
CLOSE #1

HMuisK = 400: VMuisK = 225
'
_SNDPLAY Damage&

ON TIMER(1) GOSUB pulse
TIMER ON
IF ShowCursor = 0 THEN _MOUSEHIDE
OPEN "..\TXTFiles\BLACKBOX.TXT" FOR OUTPUT AS #1
IF RecordDemo = 1 THEN GOSUB StartDemoRecording '  VOORWAAREN QUA CONTROLLER HIER VOOR

PALETTE 1, 65536 * 10 + 256 * 10 + 10 '-
PALETTE 2, 65536 * 20 + 256 * 20 + 20 ' |
PALETTE 3, 65536 * 30 + 256 * 30 + 30 ' |grijstinten tot bijna wit
PALETTE 4, 65536 * 40 + 256 * 40 + 40 ' |
PALETTE 5, 65536 * 50 + 256 * 50 + 50 '-
PALETTE 6, 65536 * 47 + 256 * 23 + 23 '  blauw
PALETTE 7, 65536 * 0 + 256 * 63 + 0 '  groen
PALETTE 8, 65536 * 0 + 256 * 0 + 63 '  rood
PALETTE 9, 65536 * 0 + 256 * 31 + 0 '  HighScoreBox Groen
PALETTE 10, 65536 * 0 + 256 * 50 + 55 ' |
PALETTE 11, 65536 * 0 + 256 * 45 + 50 ' |vlamtinten
PALETTE 12, 65536 * 0 + 256 * 35 + 45 ' |
PALETTE 13, 65536 * 0 + 256 * 25 + 63 '-
'
PALETTE 14, 65536 * 0 + 256 * 31 + 0 ' donkergroen
PALETTE 15, 65536 * 0 + 256 * 63 + 0 'hoofdkleur


PALETTE 18, 65536 * 63 + 256 * 63 + 63 'PAUSE Kleur
PALETTE 19, 65536 * 0 + 256 * 0 + 0 'Alternatief (vogel-) zwart




FOR grey = 100 TO 163
    PALETTE grey, 65536 * (grey - 100) + 256 * (grey - 100) + (grey - 100)
NEXT
PALETTE 170, 65536 * 0 + 256 * 0 + 0 ' zwart
PALETTE 171, 65536 * 63 + 256 * 63 + 63 ' wit
PALETTE 172, 65536 * 0 + 256 * 15 + 31 ' l-bruin
PALETTE 173, 65536 * 0 + 256 * 7 + 15 ' d-bruin
PALETTE 174, 65536 * 50 + 256 * 25 + 25
PALETTE 164, 65536 * 0 + 256 * 31 + 0 'midden-groen
PALETTE 255, 65536 * 0 + 256 * 63 + 0 'Maxkleur

'Maanpalet  bgr
PALETTE 200, 65536 * 40 + 256 * 42 + 48 'a
PALETTE 201, 65536 * 32 + 256 * 42 + 48 'b
PALETTE 202, 65536 * 48 + 256 * 58 + 63 'c
PALETTE 203, 65536 * 48 + 256 * 55 + 63 'd
PALETTE 204, 65536 * 40 + 256 * 50 + 48 'e
PALETTE 205, 65536 * 48 + 256 * 50 + 48 'f
PALETTE 206, 65536 * 24 + 256 * 34 + 32 'g
PALETTE 207, 65536 * 32 + 256 * 42 + 32 'h
PALETTE 208, 65536 * 48 + 256 * 58 + 48 'i
PALETTE 209, 65536 * 32 + 256 * 34 + 32 'j
PALETTE 210, 65536 * 16 + 256 * 18 + 16 'k
PALETTE 211, 65536 * 16 + 256 * 26 + 32 'l
PALETTE 212, 65536 * 24 + 256 * 26 + 32 'm
PALETTE 213, 65536 * 48 + 256 * 58 + 48 'n
PALETTE 214, 65536 * 16 + 256 * 26 + 32 'o
PALETTE 215, 65536 * 16 + 256 * 18 + 32 'p
PALETTE 216, 65536 * 8 + 256 * 18 + 32 'q
PALETTE 217, 65536 * 21 + 256 * 34 + 50 'r
FOR altroodflits = 218 TO 248
    rwrd = altroodflits - 218
    PALETTE altroodflits, 2 * rwrd
NEXT
PALETTE 249, 65536 * 31 + 256 * 31 + 63
IF DayNight$ = "NIGHT" THEN PALETTE 0, 65536 * 0 + 256 * 0 + 0 '   zwart
IF DayNight$ = "DAY" THEN PALETTE 0, 65536 * 0 + 256 * 7 + 15 ' d-bruin      '

'*****************************************************************************
'                                                BESTURING
startlabel:
_LIMIT OverallFramerate '  HOOFD-SNELHEIDSBEGRENZING IN Frames Per Second

'

i$ = INKEY$
IF i$ = CHR$(9) THEN GOSUB swapScreen

IF devmode = 1 THEN
    IF i$ = "0" THEN Bestand$ = "SCENE00.ITM": GOSUB loaditm
    IF i$ = "1" THEN Bestand$ = "SCENE01.ITM": GOSUB loaditm
    IF i$ = "2" THEN Bestand$ = "SCENE02.ITM": GOSUB loaditm
    IF i$ = "3" THEN Bestand$ = "SCENE03.ITM": GOSUB loaditm
    IF i$ = "4" THEN Bestand$ = "SCENE04.ITM": GOSUB loaditm
    IF i$ = "5" THEN Bestand$ = "SCENE05.ITM": GOSUB loaditm
    IF i$ = "6" THEN Bestand$ = "SCENE06.ITM": GOSUB loaditm
END IF


IF UCASE$(i$) = "S" THEN DepotPrint = 1
IF UCASE$(i$) = "T" THEN ShowRescue = 1
'If UCase$(i$) = "D" Then GoSub swapVertraging   '
IF UCASE$(i$) = "O" THEN GOSUB ShowObjectsLeft
IF UCASE$(i$) = "I" THEN GOSUB ShowInvert
IF UCASE$(RecDemo$) <> "ON" THEN
    IF UCASE$(i$) = "C" AND _DEVICES > NoDevicesConnected AND controller$ = "KEYBOARD" THEN Shot1& = 0: PLAY "v" + Pct$ + "MBl32o5a": controller$ = "JOYSTICK": i$ = "": ShowCursor = 0: GOSUB ShowController
    IF UCASE$(i$) = "C" AND _DEVICES = NoDevicesConnected AND controller$ = "KEYBOARD" THEN Shot1& = 0: PLAY "v" + Pct$ + "MBl32o5a": controller$ = "MOUSE": ShowCursor = 1: i$ = "": GOSUB ShowController
    IF UCASE$(i$) = "C" AND controller$ = "MOUSE" THEN Shot1& = 0: PLAY "v" + Pct$ + "MBl32o5a": controller$ = "KEYBOARD": ShowCursor = 0: i$ = "": GOSUB ShowController
    IF UCASE$(i$) = "C" AND controller$ = "JOYSTICK" THEN Shot1& = 0: PLAY "v" + Pct$ + "MBl32o5a": controller$ = "MOUSE": ShowCursor = 1: i$ = "": GOSUB ShowController
END IF
'

IF UCASE$(i$) = "G" THEN GOSUB SwapShowCoordinates
IF UCASE$(i$) = "Q" THEN GOSUB SwapCursor
IF UCASE$(i$) = "B" THEN GOSUB swapBlades
IF i$ = "!" THEN GOSUB UitroepTeken
'   *************************************************************
IF i$ = "@" AND DayNight$ = "DAY" AND devmode = 1 THEN
    i$ = ""
    DayNight$ = "NIGHT"
    PALETTE 0, 65536 * 0 + 256 * 0 + 0 '   zwart
END IF
IF i$ = "@" AND DayNight$ = "NIGHT" AND devmode = 1 THEN
    i$ = ""
    DayNight$ = "DAY"
    PALETTE 0, 65536 * 0 + 256 * 7 + 15 ' d-bruin      '
END IF
'********************************************************************



IF status$ = "CRASHED" THEN GOSUB place: GOTO startlabel

'
IF i$ = "+" AND RecordDemo = 0 AND muxer! < 4 THEN yesss = 1: _SNDPLAY Click&: muxer! = muxer! * 2: ShowSpeed = 1: OverallFramerate = OverallFramerate * 2: yesssteller& = 0
IF i$ = "-" AND RecordDemo = 0 AND muxer! > 1 / 4 THEN yesss = 1: _SNDPLAY Click&: muxer! = muxer! / 2: ShowSpeed = 1: OverallFramerate = OverallFramerate / 2: yesssteller& = 0






SELECT CASE controller$
    CASE "MOUSE"
        Mouse 3 '  VMuis en HMuis
        TR = INP(96)
        IF RecordDemo = 1 THEN
            PRINT #13, HMuis; VMuis; BMuis; TR
        END IF
        ' d& = _DEVICEINPUT
        ' IF d& THEN
        '     IF _BUTTON(2) THEN TR = 57
        ' END IF
        IF status$ <> "LANDED" THEN
            SELECT CASE SchadeTailRotor
                CASE 0
                    w1 = .9 * (w1 + .05 * ((HMuis - 400) / 3.2))
                    w2 = Invert * (VMuis - 225) / 4.8
                CASE 1
                    w1 = .9 * (w1 + .05 * ((HMuis - 100) / 3.2)) '
                    w2 = Invert * (VMuis - 225) / 4.8
            END SELECT
        END IF
        IF TR = 57 THEN GOSUB schiet

    CASE "KEYBOARD"
        TR = INP(96)
        IF _KEYDOWN(32) AND TR <> 57 THEN TR = 57 ' nodig omdat door _KEYDOWN de INP wordt geledigd
        IF _KEYDOWN(19200) THEN HMuisK = HMuisK - 20
        IF _KEYDOWN(19712) THEN HMuisK = HMuisK + 20
        IF _KEYDOWN(18432) THEN VMuisK = VMuisK - 20 * Invert
        IF _KEYDOWN(20480) THEN VMuisK = VMuisK + 20 * Invert
        IF HMuisK < 0 THEN HMuisK = 0
        IF HMuisK > 799 THEN HMuisK = 799
        IF VMuisK < 0 THEN VMuisK = 0
        IF VMuisK > 449 THEN VMuisK = 449
        IF RecordDemo = 1 THEN
            PRINT #13, HMuisK; VMuisK; BMuisK; TR
        END IF
        IF status$ <> "LANDED" THEN
            SELECT CASE SchadeTailRotor
                CASE 0
                    w1 = .9 * (w1 + .05 * ((HMuisK - 400) / 3.2))
                    w2 = (VMuisK - 225) / 4.8
                CASE 1
                    w1 = .9 * (w1 + .05 * ((HMuisK - 100) / 3.2)) '
                    w2 = (VMuisK - 225) / 4.8
            END SELECT
        END IF
        IF TR = 57 THEN GOSUB schiet
        '
        VMuisK = .9 * (VMuisK - 225) + 225
        HMuisK = .99 * (HMuisK - 400) + 400
    CASE "JOYSTICK" '
        d& = _DEVICEINPUT
        IF d& = 3 THEN
            trigger = -_BUTTON(1)
            XStick! = _AXIS(1)
            YStick! = Invert * _AXIS(2)
            IF ABS(XStick!) < StickDeadZone! THEN XStick! = 0
            IF ABS(YStick!) < StickDeadZone! THEN YStick! = 0
        END IF
        IF trigger = 1 THEN TR = 57 ELSE TR = 0
        IF SGN(XStick!) = -1 THEN HMuisK = HMuisK - 20
        IF SGN(XStick!) = 1 THEN HMuisK = HMuisK + 20
        IF SGN(YStick!) = -1 THEN VMuisK = VMuisK - 20
        IF SGN(YStick!) = 1 THEN VMuisK = VMuisK + 20
        IF HMuisK < 0 THEN HMuisK = 0
        IF HMuisK > 799 THEN HMuisK = 799
        IF VMuisK < 0 THEN VMuisK = 0
        IF VMuisK > 449 THEN VMuisK = 449
        IF RecordDemo = 1 THEN
            PRINT #13, HMuisK; VMuisK; BMuisK; TR
        END IF
        IF status$ <> "LANDED" THEN
            SELECT CASE SchadeTailRotor
                CASE 0
                    w1 = .9 * (w1 + .05 * ((HMuisK - 400) / 3.2))
                    w2 = (VMuisK - 225) / 4.8
                CASE 1
                    w1 = .9 * (w1 + .05 * ((HMuisK - 100) / 3.2)) '
                    w2 = (VMuisK - 225) / 4.8
            END SELECT
        END IF
        IF TR = 57 THEN GOSUB schiet

        VMuisK = .9 * (VMuisK - 225) + 225
        HMuisK = .99 * (HMuisK - 400) + 400

END SELECT

speedfactor# = -helhoek# * 1.5
IF speedfactor# < -.75 THEN speedfactor# = -.75
IF speedfactor# > .75 THEN speedfactor# = .75

'
SELECT CASE controller$
    CASE "MOUSE"
        IF fuel# > 0 AND BMuis = 1 THEN w4 = 1: levelhoogte$ = "off" ELSE w4 = 0
        IF BMuis = 2 THEN w4 = 0: power$ = "on": levelhoogte$ = "off"
    CASE "KEYBOARD"
        TR = INP(96)
        BMuisK = 0
        IF fuel# > 0 AND _KEYDOWN(65) THEN w4 = 1: levelhoogte$ = "off": BMuisK = 1: ELSE w4 = 0
        IF fuel# > 0 AND _KEYDOWN(97) THEN w4 = 1: levelhoogte$ = "off": BMuisK = 1: ELSE w4 = 0
        IF _KEYDOWN(90) THEN w4 = 0: power$ = "on": BMuisK = 2: levelhoogte$ = "off"
        IF _KEYDOWN(122) THEN w4 = 0: power$ = "on": BMuisK = 2: levelhoogte$ = "off"

    CASE "JOYSTICK" '
        d& = _DEVICEINPUT
        IF d& = 3 THEN Throttle! = -_AXIS(3)

        IF ABS(Throttle!) < ThrottleDeadZone! THEN Throttle! = 0: BMuisK = 0: w4 = 0: levelhoogte$ = "on"
        IF fuel# > 0 AND Throttle! >= ThrottleDeadZone! THEN w4 = 1: levelhoogte$ = "off": BMuisK = 1 ELSE w4 = 0
        IF Throttle! <= -ThrottleDeadZone! THEN w4 = 0: levelhoogte$ = "off": BMuisK = 2
END SELECT



IF levelhoogte$ = "on" THEN
    IF yc0# <= yl# THEN w4 = 1 ELSE w4 = 0
END IF
IF w1 < -100 THEN w1 = -100
IF w1 > 100 THEN w1 = 100
IF w2 < -100 THEN w2 = -100
IF w2 > 100 THEN w2 = 100
IF w3 < 0 THEN w3 = 0
IF w3 > 100 THEN w3 = 100
IF w4 = 1 THEN
    stijgkracht# = stijgkracht# + os#
    GOSUB stijgendalen
END IF
IF w4 = 0 AND levelhoogte$ = "off" THEN
    stijgkracht# = stijgkracht# - ds#
    GOSUB stijgendalen
END IF
IF yc3# > ymin THEN var1# = w1 / 400 ELSE
IF w1 <> 0 THEN
    IF yc3# > yc3ondergrens# THEN GOSUB linksrechts
END IF
kantel# = var1#

IF status$ = "LANDED" THEN
    _MOUSESHOW: yh1 = 225: yh2 = 225: yh3 = 225: kantel# = 0
END IF

SELECT CASE ShowCursor
    CASE 0: _MOUSEHIDE
    CASE 1: _MOUSESHOW
END SELECT

IF kantel# > .15 THEN kantel# = .15
IF kantel# < -.15 THEN kantel# = -.15
IF w2 <> 0 AND hh# >= 0 THEN
    var2# = w2 / 400
    GOSUB omhoogomlaag
END IF
GOSUB vooruit
status$ = ""

IF yc3# <= ymin OR yc4# <= ymin THEN
    IF ABS(INT(210 * speedfactor# * .54)) > VmaxLanding THEN Speedcrash = 1 ELSE Speedcrash = 0 'maximale landsnelheid VmaxLanding
    IF ABS(kantel#) > KantelmaxLanding# THEN Kantelcrash = 1
    yc1# = ymin + camhoogte#: yc2# = ymin + camhoogte#: yc3# = ymin: yc4# = ymin: yc5# = ymin + .5 * camhoogte#
    speedfactor# = 0: helhoek# = 0: kantel# = 0: stijgkracht# = 0: spy# = ymin: hh# = 0
    GOSUB landcheck
END IF
xc0# = (xc1# + xc2# + xc3# + xc4#) / 4: yc0# = (yc1# + yc2# + yc3# + yc4#) / 4: zc0# = (zc1# + zc2# + zc3# + zc4#) / 4

'*****************************************************************************
GOSUB HorizonPaint '

'
'*****************************************************************************
'                                                     GRID
FOR xp# = -worldx# / 2 + (xc0# \ 100) * 100 TO worldx# / 2 + (xc0# \ 100) * 100 STEP griddensity
    FOR zp# = -worldz# / 2 + (zc0# \ 100) * 100 TO worldz# / 2 + (zc0# \ 100) * 100 STEP griddensity
        diast = (SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2))
        yp# = 0
        jnplaat = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel

        IF qx# >= 0 AND qx# <= 799 AND qy# >= 0 AND qy# <= 449 THEN
            '  If qx# >= 0 - Buitenmarge And qx# <= 799 + Buitenmarge And qy# >= 0 - Buitenmarge And qy# <= 449 + Buitenmarge Then
            xplaat# = qx#: yplaat# = qy#: jnplaat = 1
        END IF
        '
        IF DayNight$ = "NIGHT" THEN
            gridcolor = 163 - INT(diast / 40)
            IF gridcolor < 100 THEN gridcolor = 100
            IF gridcolor > 163 THEN gridcolor = 163
        ELSE
            gridcolor = 150
        END IF

        '
        'If gridcolor > 100 And jnplaat = 1 Then PSet (xplaat#, yplaat#), gridcolor: jnplaat = 0
        IF DayNight$ = "DAY" THEN
            IF gridcolor > 100 AND jnplaat = 1 AND diast < 2000 THEN LINE (xplaat#, yplaat#)-(xplaat# + 1, yplaat#), gridcolor: jnplaat = 0
        END IF

        IF DayNight$ = "NIGHT" THEN
            IF gridcolor > 100 AND jnplaat = 1 THEN LINE (xplaat#, yplaat#)-(xplaat# + 1, yplaat#), gridcolor: jnplaat = 0
        END IF
    NEXT
NEXT

'*****************************************************************************
'                                                BIRDS
IF DayNight$ = "DAY" THEN
    IF Sky$ = "OFF" GOTO NoBirdsLabel
    FOR vnr = 1 TO AantalVogels

        yvogel#(vnr) = yvogel#(vnr) + vogelyspeed#(vnr)
        IF yvogel#(vnr) >= 250.3 THEN yvogel#(vnr) = 250.3: vogelyspeed#(vnr) = -vogelstijgspeed#
        IF yvogel#(vnr) <= 249.7 THEN yvogel#(vnr) = 249.7: vogelyspeed#(vnr) = vogelstijgspeed#
        xv1#(vnr) = xvogel#(vnr) - .5
        xv2#(vnr) = xvogel#(vnr) + .5


        IF vogelyspeed#(vnr) > 0 THEN yv1#(vnr) = yvogel#(vnr) - .3: yv2#(vnr) = yvogel#(vnr) - .3
        IF vogelyspeed#(vnr) <= 0 THEN yv1#(vnr) = yvogel#(vnr) + .3: yv2#(vnr) = yvogel#(vnr) + .3




        zvogel#(vnr) = zvogel#(vnr) + vogelspeed#
        IF zvogel#(vnr) > 2500 THEN zvogel#(vnr) = -2500: xvogel#(vnr) = xvogel#(vnr) + 200
        IF xvogel#(vnr) > 2500 THEN xvogel#(vnr) = -2500

        zvogelKop# = zvogel#(vnr) + 1
        zvogelStaart# = zvogel#(vnr) - .8

        xp# = xvogel#(vnr)
        yp# = yvogel#(vnr)
        zp# = zvogelKop#
        jnvogel = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xKop# = qx#: yKop# = qy#: jnKop = 1
        END IF

        xp# = xvogel#(vnr)
        yp# = yvogel#(vnr)
        zp# = zvogelStaart#
        jnvogel = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xStaart# = qx#: yStaart# = qy#: jnStaart = 1
        END IF
        '*************************


        xp# = xvogel#(vnr)
        yp# = yvogel#(vnr)
        zp# = zvogel#(vnr)
        jnvogel = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xvogel# = qx#: yvogel# = qy#: jnvogel = 1
        END IF

        xp# = xv1#(vnr)
        yp# = yv1#(vnr)
        zp# = zvogel#(vnr)
        jn1 = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xEast# = qx#: yEast# = qy#: jn1 = 1
        END IF

        xp# = xv2#(vnr)
        yp# = yv2#(vnr)
        zp# = zvogel#(vnr)
        jn2 = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xWest# = qx#: yWest# = qy#: jn2 = 1
        END IF


        IF jnvogel = 1 AND jn1 = 1 AND jn2 = 1 AND jnKop = 1 AND jnStaart = 1 THEN
            PSET (xvogel#, yvogel#), 19: jnvogel = 0
            LINE -(xEast#, yEast#), 19: jn1 = 0
            PSET (xvogel#, yvogel#), 19: jnvogel = 0
            LINE -(xWest#, yWest#), 19: jn2 = 0
            LINE (xKop#, yKop#)-(xStaart#, yStaart#), 19: jnStaart = 0: jnKop = 0
        END IF

    NEXT
    NoBirdsLabel:
END IF
'If DayNight$ = "DAY" Then '   geel:10  wit:163
'    xp# = xzon#
'    yp# = yzon#
'    zp# = zzon#
'    jnzon = 0: GoSub BepaalBeeld
'    qx# = 400 + schaalx# * pf# * horhoek#
'    qy# = 225 - schaaly# * pf# * verhoek#
'    khoek# = kantel# * 3: GoSub kantel
'    If qx# >= -zonstraal And qx# <= 799 + zonstraal And qy# >= -zonstraal And qy# <= 449 + zonstraal Then
'          xzt# = qx#: yzt# = qy#: jnzon = 1
'    End If
'    If jnzon = 1 Then
'          Circle (xzt#, yzt#), zonstraal, 163
'          Paint (xzt#, yzt#), 163
'          jnzon = 0
'    End If
'End If

'**************************************************************************************************************************************




'*****************************************************************************
'                                                STARS
IF DayNight$ = "NIGHT" THEN
    IF Sky$ = "OFF" GOTO NoSkyLabel
    FOR S = 1 TO aantalsterren
        xp# = xster#(S)
        yp# = yster#(S)
        zp# = zster#(S)
        jnster = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xster# = qx#: yster# = qy#: jnster = 1
        END IF
        IF jnster = 1 THEN PSET (xster#, yster#), sterkleur(S): jnster = 0
    NEXT
    NoSkyLabel:
    '*****************************************************************************
    '                                               MOON
    IF maan = 1 THEN
        xp# = xmaan#
        yp# = ymaan#
        zp# = zmaan#
        jnmaan = 0: GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= -maanstraal AND qx# <= 799 + maanstraal AND qy# >= -maanstraal AND qy# <= 449 + maanstraal THEN
            xmt# = qx#: ymt# = qy#: jnmaan = 1
        END IF
        IF jnmaan = 1 THEN
            PUT (xmt# - maanstraal, ymt# - maanstraal), moon(0), _CLIP OR
            jnmaan = 0
        END IF
    END IF
END IF
'****************************************************************************************



'*****************************************************************************
'                                                 FRIENDLY BULLETS
FOR akn = 0 TO MaxKogels - 1
    syk#(akn) = syk#(akn) - gravitatie#
    gunkogelafstand# = SQR((xk#(akn) - xc0#) ^ 2 + (yk#(akn) - yc0#) ^ 2 + (zk#(akn) - zc0#) ^ 2)
    IF schietstatus(akn) = 1 THEN
        FOR AEN = 1 TO NumberOfEnemiesActive
            DoelAfstand# = SQR((xk#(akn) - xITMZwaartepunt#(AEN)) ^ 2 + (yk#(akn) - yITMZwaartepunt#(AEN)) ^ 2 + (zk#(akn) - zITMZwaartepunt#(AEN)) ^ 2)
            IF DoelAfstand# < HitAfstand#(AEN) AND yk#(akn) < Hithoogtemax THEN schietstatus(akn) = 0: GOSUB raak: tar = tar + 1 '
        NEXT
        '
        IF yk#(akn) < 10 THEN
            FOR ObjectNummer = 1 TO AantalObjecten
                d# = _HYPOT(objectdx#(ObjectNummer) - xk#(akn), objectdz#(ObjectNummer) - zk#(akn))
                IF d# < ObjectHitBall AND yk#(akn) < HithoogteOmax AND ObjectYesNo(ObjectNummer) = 1 THEN
                    ObjectYesNo(ObjectNummer) = 0
                    _SNDPLAY HitEnemy&
                    ObjectsHit = ObjectsHit + 1: score& = score& + 5: tar = tar + 1 '
                    ShowObjects = 1
                    '
                    IF ObjectsHit = 1 * (AantalObjecten \ 4) AND Bonus1 = 0 THEN score& = score& + 100: Bonus1 = 1: _SNDPLAY Bonus1&
                    IF ObjectsHit = 2 * (AantalObjecten \ 4) AND Bonus2 = 0 THEN score& = score& + 100: Bonus2 = 1: _SNDPLAY Bonus2&
                    IF ObjectsHit = 3 * (AantalObjecten \ 4) AND Bonus3 = 0 THEN score& = score& + 100: Bonus3 = 1: _SNDPLAY Bonus3&
                    IF ObjectsHit = 4 * (AantalObjecten \ 4) AND Bonus4 = 0 THEN


                        Tempsec& = Tempsec& + 1 '  correctie
                        '
                        score& = score& + 500
                        Bonus4 = 1
                        _SNDPLAY Bonus4&
                        GOSUB UnlockObjects
                        GOSUB NewObjects

                    END IF
                END IF
            NEXT
            FOR altpsn = 1 TO waypoints
                IF rescue(altpsn) = 0 THEN
                    d# = _HYPOT(xwp#(altpsn) - xk#(akn), zwp#(altpsn) - zk#(akn))
                    IF d# < HitBallPerson AND yk#(akn) < HitHightPerson THEN
                        Exit$ = "- YOU KILLED A REFUGEE -": gameover = 1 '
                    END IF
                END IF
            NEXT
        END IF
        xk#(akn) = xk#(akn) + sxk#(akn)
        yk#(akn) = yk#(akn) + syk#(akn)
        zk#(akn) = zk#(akn) + szk#(akn)
        xp# = xk#(akn): yp# = yk#(akn): zp# = zk#(akn): GOSUB BepaalBeeld
        qx# = 400 + schaalx# * pf# * horhoek#
        qy# = 225 - schaaly# * pf# * verhoek#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xkprojectie = qx#: ykprojectie = qy#
        END IF

        IF gunkogelafstand# > maxkogelweg# OR yk#(akn) < 0 THEN

            'Easteregg2: Boompjes of rocks bij Nacht
            IF TypeObjecten MOD 2 = 1 AND POINT(xkprojectie, ykprojectie) >= 200 AND POINT(xkprojectie, ykprojectie) <= 217 AND EasterEgg2 = 0 THEN '  Moon easteregg
                EasterEgg2 = 1
                score& = score& + 500: _SNDPLAY Bonus6&
            END IF

            sxk#(akn) = 0: syk#(akn) = 0: szk#(akn) = 0: schietstatus(akn) = 0: yk#(akn) = 0
        END IF
        IF gunkogelafstand# < maxkogelweg# / 2 THEN
            LINE (xkprojectie, ykprojectie)-(xkprojectie + 1, ykprojectie + 1), 8, BF
        ELSE
            PSET (xkprojectie, ykprojectie), 8
        END IF

    END IF
NEXT
'*****************************************************************************
'                                                   ENEMY BULLETS
FOR AEN = 1 TO NumberOfEnemiesActive
    DistancePlayerEnemy = SQR((xc0# - vijanddx#(AEN)) ^ 2 + (yc0# - vijanddy#(AEN)) ^ 2 + (zc0# - vijanddz#(AEN)) ^ 2)
    SELECT CASE vijandType(AEN)
        CASE 2 '                                                    SPORTSCAR
            Grens = 800 'FT
            IF DistancePlayerEnemy <= Grens THEN
                raakkans = 800 * (DistancePlayerEnemy / Grens) * RND
                IF raakkans <= 2 THEN
                    IF devmode = 0 THEN _SNDPLAY HitPlay&: PlayerDamage = PlayerDamage + 1: flits = 1
                END IF
            END IF
        CASE 3 '                                                    JEEP
            Grens = 1200 'FT
            IF DistancePlayerEnemy <= Grens THEN
                raakkans = 200 * (DistancePlayerEnemy / Grens) * RND
                IF raakkans <= 2 THEN
                    IF devmode = 0 THEN _SNDPLAY HitPlay&: PlayerDamage = PlayerDamage + 1: flits = 1
                END IF
            END IF
        CASE 4 '                                                    TANK
            Grens = 1500 'FT
            IF DistancePlayerEnemy <= Grens THEN
                raakkans = 140 * (DistancePlayerEnemy / Grens) * RND
                IF raakkans <= 3 THEN
                    IF devmode = 0 THEN _SNDPLAY HitPlay&: PlayerDamage = PlayerDamage + 2: flits = 1
                END IF
            END IF
        CASE 1 '                                                    SUPPLY UCK
    END SELECT
NEXT
'  DAMAGE Gevolgen ********************************************************
IF PlayerDamage >= 100 THEN
    IF SchadeTailRotor = 1 AND SchadeFuel = 1 THEN Totalloss = 1
    IF SchadeTailRotor = 1 THEN SchadeFuel = 1
    IF SchadeFuel = 1 THEN SchadeTailRotor = 1
    SchadeType = INT(2 * RND)
    SELECT CASE SchadeType
        CASE 0
            SchadeTailRotor = 1
        CASE 1
            SchadeFuel = 1
    END SELECT
    PlayerDamage = 0
END IF
'
IF DamSound = 0 AND (SchadeTailRotor = 1 OR SchadeFuel = 1) THEN _SNDLOOP Damage&: DamSound = 1
IF SchadeTailRotor = 0 AND SchadeFuel = 0 THEN DamSound = 0: _SNDSTOP Damage&

'                                              *SCENE*
FOR V = 0 TO kVlakken - 1
    jn0 = 0: jn1 = 0: jn2 = 0: jn3 = 0: jn4 = 0
    xp# = itmdx + itmscale * x#(V, 0): yp# = itmdy + itmscale * y#(V, 0): zp# = itmdz + itmscale * z#(V, 0): GOSUB BepaalBeeld

    diast = (SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2))




    gridcolor = 163 - INT((SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2)) / 40)
    IF gridcolor < 100 THEN gridcolor = 100
    IF gridcolor > 163 THEN gridcolor = 163
    horhoek0# = horhoek#: verhoek0# = verhoek#
    xp# = itmdx + itmscale * x#(V, 1): yp# = itmdy + itmscale * y#(V, 1): zp# = itmdz + itmscale * z#(V, 1): GOSUB BepaalBeeld
    horhoek1# = horhoek#: verhoek1# = verhoek#
    xp# = itmdx + itmscale * x#(V, 2): yp# = itmdy + itmscale * y#(V, 2): zp# = itmdz + itmscale * z#(V, 2): GOSUB BepaalBeeld
    horhoek2# = horhoek#: verhoek2# = verhoek#
    xp# = itmdx + itmscale * x#(V, 3): yp# = itmdy + itmscale * y#(V, 3): zp# = itmdz + itmscale * z#(V, 3): GOSUB BepaalBeeld
    horhoek3# = horhoek#: verhoek3# = verhoek#
    xp# = itmdx + itmscale * x#(V, 4): yp# = itmdy + itmscale * y#(V, 4): zp# = itmdz + itmscale * z#(V, 4): GOSUB BepaalBeeld
    horhoek4# = horhoek#: verhoek4# = verhoek#
    qx# = 400 + schaalx# * pf# * horhoek0#
    qy# = 225 - schaaly# * pf# * verhoek0#
    khoek# = kantel# * 3: GOSUB kantel
    IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
        xkprojectie0 = qx#: ykprojectie0 = qy#: jn0 = 1
    END IF
    qx# = 400 + schaalx# * pf# * horhoek1#
    qy# = 225 - schaaly# * pf# * verhoek1#
    khoek# = kantel# * 3: GOSUB kantel
    IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
        xkprojectie1 = qx#: ykprojectie1 = qy#: jn1 = 1
    END IF
    qx# = 400 + schaalx# * pf# * horhoek2#
    qy# = 225 - schaaly# * pf# * verhoek2#
    khoek# = kantel# * 3: GOSUB kantel
    IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
        xkprojectie2 = qx#: ykprojectie2 = qy#: jn2 = 1
    END IF
    qx# = 400 + schaalx# * pf# * horhoek3#
    qy# = 225 - schaaly# * pf# * verhoek3#
    khoek# = kantel# * 3: GOSUB kantel
    IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
        xkprojectie3 = qx#: ykprojectie3 = qy#: jn3 = 1
    END IF
    qx# = 400 + schaalx# * pf# * horhoek4#
    qy# = 225 - schaaly# * pf# * verhoek4#
    khoek# = kantel# * 3: GOSUB kantel
    IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
        xkprojectie4 = qx#: ykprojectie4 = qy#: jn4 = 1
    END IF

    IF DayNight$ = "NIGHT" THEN

        IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
            LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
            LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
            LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
            LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
        END IF
    ELSE
        '
        IF diast <= 2000 THEN
            gridcolor = 163
            IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
            END IF
        END IF
    END IF
NEXT






'*****************************************************************************
'                                             PERSONS
'af:       ANIMATIEFRAME DRENKELING 1-4
animatieteller = animatieteller + 1
IF animatieteller = 20 THEN af = af + 1: animatieteller = 0
IF af = 5 THEN af = 1
'
TotalPersonsRescued = 0
FOR persoonnummer = 1 TO waypoints

    IF rescue(persoonnummer) = 0 THEN

        'teken persoon persoonnummer
        persoondx# = xwp#(persoonnummer)
        persoondy# = ywp#(persoonnummer)
        persoondz# = zwp#(persoonnummer)
        '
        FOR pV = 0 TO apv - 1
            jn0 = 0: jn1 = 0: jn2 = 0: jn3 = 0: jn4 = 0
            xp# = persoondx# + itmscale * xlp0#(af, pV): yp# = persoondy# + itmscale * ylp0#(af, pV): zp# = persoondz# + itmscale * zlp0#(af, pV): GOSUB BepaalBeeld

            diast = (SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2))





            gridcolor = 163 - INT((SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2)) / 40)
            IF gridcolor < 100 THEN gridcolor = 100
            IF gridcolor > 163 THEN gridcolor = 163
            horhoek0# = horhoek#: verhoek0# = verhoek#
            xp# = persoondx# + itmscale * xlp1#(af, pV): yp# = persoondy# + itmscale * ylp1#(af, pV): zp# = persoondz# + itmscale * zlp1#(af, pV): GOSUB BepaalBeeld
            horhoek1# = horhoek#: verhoek1# = verhoek#
            xp# = persoondx# + itmscale * xlp2#(af, pV): yp# = persoondy# + itmscale * ylp2#(af, pV): zp# = persoondz# + itmscale * zlp2#(af, pV): GOSUB BepaalBeeld
            horhoek2# = horhoek#: verhoek2# = verhoek#
            xp# = persoondx# + itmscale * xlp3#(af, pV): yp# = persoondy# + itmscale * ylp3#(af, pV): zp# = persoondz# + itmscale * zlp3#(af, pV): GOSUB BepaalBeeld
            horhoek3# = horhoek#: verhoek3# = verhoek#
            xp# = persoondx# + itmscale * xlp4#(af, pV): yp# = persoondy# + itmscale * ylp4#(af, pV): zp# = persoondz# + itmscale * zlp4#(af, pV): GOSUB BepaalBeeld
            horhoek4# = horhoek#: verhoek4# = verhoek#
            qx# = 400 + schaalx# * pf# * horhoek0#
            qy# = 225 - schaaly# * pf# * verhoek0#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie0 = qx#: ykprojectie0 = qy#: jn0 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek1#
            qy# = 225 - schaaly# * pf# * verhoek1#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie1 = qx#: ykprojectie1 = qy#: jn1 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek2#
            qy# = 225 - schaaly# * pf# * verhoek2#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie2 = qx#: ykprojectie2 = qy#: jn2 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek3#
            qy# = 225 - schaaly# * pf# * verhoek3#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie3 = qx#: ykprojectie3 = qy#: jn3 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek4#
            qy# = 225 - schaaly# * pf# * verhoek4#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie4 = qx#: ykprojectie4 = qy#: jn4 = 1
            END IF
            IF DayNight$ = "NIGHT" THEN

                IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                    LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                    LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                    LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                    LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                END IF
            ELSE
                IF diast <= 2000 THEN
                    gridcolor = 163
                    IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                        LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                        LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                        LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                        LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                    END IF
                END IF
            END IF




        NEXT pV
    ELSE
        '
        TotalPersonsRescued = TotalPersonsRescued + 1
    END IF
NEXT
'*****************************************************************************
'                                             REMOTE OBJECTS (TREES, ROCKS, ETC.)
FOR ObjectNummer = 1 TO AantalObjecten
    IF ObjectYesNo(ObjectNummer) = 1 THEN
        FOR V = 0 TO aov - 1
            jn0 = 0: jn1 = 0: jn2 = 0: jn3 = 0: jn4 = 0
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 0): yp# = objectdy#(ObjectNummer) + itmscale * yobject#(ObjectNummer, V, 0): zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 0): GOSUB BepaalBeeld
            '    *************************************

            diast = (SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2))

            gridcolor = 163 - INT((SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2)) / 40)
            '*****************************************


            IF gridcolor < 100 THEN gridcolor = 100
            IF gridcolor > 163 THEN gridcolor = 163
            horhoek0# = horhoek#: verhoek0# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 1): yp# = objectdy#(ObjectNummer) + itmscale * yobject#(ObjectNummer, V, 1): zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 1): GOSUB BepaalBeeld
            horhoek1# = horhoek#: verhoek1# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 2): yp# = objectdy#(ObjectNummer) + itmscale * yobject#(ObjectNummer, V, 2): zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 2): GOSUB BepaalBeeld
            horhoek2# = horhoek#: verhoek2# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 3): yp# = objectdy#(ObjectNummer) + itmscale * yobject#(ObjectNummer, V, 3): zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 3): GOSUB BepaalBeeld
            horhoek3# = horhoek#: verhoek3# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 4): yp# = objectdy#(ObjectNummer) + itmscale * yobject#(ObjectNummer, V, 4): zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 4): GOSUB BepaalBeeld
            horhoek4# = horhoek#: verhoek4# = verhoek#
            qx# = 400 + schaalx# * pf# * horhoek0#
            qy# = 225 - schaaly# * pf# * verhoek0#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie0 = qx#: ykprojectie0 = qy#: jn0 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek1#
            qy# = 225 - schaaly# * pf# * verhoek1#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie1 = qx#: ykprojectie1 = qy#: jn1 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek2#
            qy# = 225 - schaaly# * pf# * verhoek2#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie2 = qx#: ykprojectie2 = qy#: jn2 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek3#
            qy# = 225 - schaaly# * pf# * verhoek3#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie3 = qx#: ykprojectie3 = qy#: jn3 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek4#
            qy# = 225 - schaaly# * pf# * verhoek4#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie4 = qx#: ykprojectie4 = qy#: jn4 = 1
            END IF
            SELECT CASE DayNight$ '
                CASE "NIGHT"
                    IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                        LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                        LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                        LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                        LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                    END IF
                CASE "DAY"

                    IF diast <= 2000 THEN
                        gridcolor = 163
                        IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                            LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                            LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                            LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                            LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                        END IF
                    END IF
            END SELECT

        NEXT
    ELSE
        FOR V = 0 TO aov - 1 '
            jn0 = 0: jn1 = 0: jn2 = 0: jn3 = 0: jn4 = 0
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 0): yp# = 0: zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 0): GOSUB BepaalBeeld
            diast = SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2) 'TOEGEVOEGD


            gridcolor = 163 - INT((SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2)) / 40)
            IF gridcolor < 100 THEN gridcolor = 100
            IF gridcolor > 163 THEN gridcolor = 163
            horhoek0# = horhoek#: verhoek0# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 1): yp# = 0: zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 1): GOSUB BepaalBeeld
            horhoek1# = horhoek#: verhoek1# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 2): yp# = 0: zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 2): GOSUB BepaalBeeld
            horhoek2# = horhoek#: verhoek2# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 3): yp# = 0: zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 3): GOSUB BepaalBeeld
            horhoek3# = horhoek#: verhoek3# = verhoek#
            xp# = objectdx#(ObjectNummer) + itmscale * xobject#(ObjectNummer, V, 4): yp# = 0: zp# = objectdz#(ObjectNummer) + itmscale * zobject#(ObjectNummer, V, 4): GOSUB BepaalBeeld
            horhoek4# = horhoek#: verhoek4# = verhoek#
            qx# = 400 + schaalx# * pf# * horhoek0#
            qy# = 225 - schaaly# * pf# * verhoek0#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie0 = qx#: ykprojectie0 = qy#: jn0 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek1#
            qy# = 225 - schaaly# * pf# * verhoek1#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie1 = qx#: ykprojectie1 = qy#: jn1 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek2#
            qy# = 225 - schaaly# * pf# * verhoek2#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie2 = qx#: ykprojectie2 = qy#: jn2 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek3#
            qy# = 225 - schaaly# * pf# * verhoek3#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie3 = qx#: ykprojectie3 = qy#: jn3 = 1
            END IF
            qx# = 400 + schaalx# * pf# * horhoek4#
            qy# = 225 - schaaly# * pf# * verhoek4#
            khoek# = kantel# * 3: GOSUB kantel
            IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
                xkprojectie4 = qx#: ykprojectie4 = qy#: jn4 = 1
            END IF
            SELECT CASE DayNight$ '
                CASE "NIGHT"
                    IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                        LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                        LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                        LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                        LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                    END IF
                CASE "DAY"

                    IF diast <= 2000 THEN
                        gridcolor = 163
                        IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                            LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                            LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                            LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                            LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                        END IF
                    END IF
            END SELECT

        NEXT

    END IF
NEXT
'*****************************************************************************


'*****************************************************************************
'                                       ROTOR BLADES
IF ShowBlades = 1 THEN
    'CIRCLE (400, -100), 600, Rotorcolor, 3.2, 6.2, .25
    SELECT CASE Blade
        CASE 0: LINE (600, 0)-(800, 12), Rotorcolor: LINE (0, 12)-(25, 21), Rotorcolor
        CASE 1: LINE (550, 0)-(700, 29), Rotorcolor: LINE -(725, 25), Rotorcolor
        CASE 2: LINE (500, 0)-(600, 41), Rotorcolor: LINE -(625, 38), Rotorcolor
        CASE 3: LINE (450, 0)-(500, 48), Rotorcolor: LINE -(525, 47), Rotorcolor
        CASE 4: LINE (400, 0)-(400, 50), Rotorcolor: LINE -(425, 50), Rotorcolor
        CASE 5: LINE (350, 0)-(300, 48), Rotorcolor: LINE -(325, 49), Rotorcolor
        CASE 6: LINE (300, 0)-(200, 41), Rotorcolor: LINE -(225, 43), Rotorcolor
        CASE 7: LINE (250, 0)-(100, 29), Rotorcolor: LINE -(125, 32), Rotorcolor
        CASE 8: LINE (200, 0)-(0, 12), Rotorcolor: LINE -(25, 17), Rotorcolor
    END SELECT
    IF bladesturn$ = "on" THEN Blade = Blade + 1
    IF Blade = 9 THEN Blade = 0
END IF

'*****************************************************************************
'                                       ENEMY-MOVEMENT AND DAMAGE-COUNTER


FOR AEN = 1 TO NumberOfEnemiesActive
    'If devmode = 0 Then '

    vijanddx#(AEN) = vijanddx#(AEN) + sxvijand#(AEN)
    vijanddy#(AEN) = vijanddy#(AEN) + syvijand#(AEN)
    vijanddz#(AEN) = vijanddz#(AEN) + szvijand#(AEN)
    xITMZwaartepunt#(AEN) = xITMZwaartepunt#(AEN) + sxvijand#(AEN)
    yITMZwaartepunt#(AEN) = yITMZwaartepunt#(AEN) + syvijand#(AEN)
    zITMZwaartepunt#(AEN) = zITMZwaartepunt#(AEN) + szvijand#(AEN)
    'End If
    xp# = xITMZwaartepunt#(AEN)
    yp# = yITMZwaartepunt#(AEN)
    zp# = zITMZwaartepunt#(AEN)
    jndamage(AEN) = 0
    GOSUB BepaalBeeld
    qx# = 400 + schaalx# * pf# * horhoek#
    qy# = 225 - schaaly# * pf# * verhoek#
    khoek# = kantel# * 3: GOSUB kantel
    dx = qx#
    dy = yU(AEN) - DamageTextElevation: jndamage(AEN) = 1
    IF jndamage(AEN) = 1 AND enemydamage(AEN) < 100 AND enemydamage(AEN) > 0 AND firstTimeWarnNOT(AEN) = 1 THEN
        IF enemydamage(AEN) > 100 THEN EenemyDamage(AEN) = 100
        waarde$ = STR$(100 - enemydamage(AEN)) + "%"
        GOSUB PlaatsTekstCentered
    END IF
    '                                                    ENEMY
    yU(AEN) = 450 'voorlopige y-waarde Elevation

    FOR V = 0 TO l(AEN) - 1
        jn0 = 0: jn1 = 0: jn2 = 0: jn3 = 0: jn4 = 0
        xp# = vijanddx#(AEN) + itmscale * xvijand#(AEN, V, 0): yp# = vijanddy#(AEN) + itmscale * yvijand#(AEN, V, 0): zp# = vijanddz#(AEN) + itmscale * zvijand#(AEN, V, 0): GOSUB BepaalBeeld

        diast = (SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2))

        gridcolor = 163 - INT((SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2)) / 40)
        IF gridcolor < 100 THEN gridcolor = 100
        IF gridcolor > 163 THEN gridcolor = 163
        horhoek0# = horhoek#: verhoek0# = verhoek#
        xp# = vijanddx#(AEN) + itmscale * xvijand#(AEN, V, 1): yp# = vijanddy#(AEN) + itmscale * yvijand#(AEN, V, 1): zp# = vijanddz#(AEN) + itmscale * zvijand#(AEN, V, 1): GOSUB BepaalBeeld
        horhoek1# = horhoek#: verhoek1# = verhoek#
        xp# = vijanddx#(AEN) + itmscale * xvijand#(AEN, V, 2): yp# = vijanddy#(AEN) + itmscale * yvijand#(AEN, V, 2): zp# = vijanddz#(AEN) + itmscale * zvijand#(AEN, V, 2): GOSUB BepaalBeeld
        horhoek2# = horhoek#: verhoek2# = verhoek#
        xp# = vijanddx#(AEN) + itmscale * xvijand#(AEN, V, 3): yp# = vijanddy#(AEN) + itmscale * yvijand#(AEN, V, 3): zp# = vijanddz#(AEN) + itmscale * zvijand#(AEN, V, 3): GOSUB BepaalBeeld
        horhoek3# = horhoek#: verhoek3# = verhoek#
        xp# = vijanddx#(AEN) + itmscale * xvijand#(AEN, V, 4): yp# = vijanddy#(AEN) + itmscale * yvijand#(AEN, V, 4): zp# = vijanddz#(AEN) + itmscale * zvijand#(AEN, V, 4): GOSUB BepaalBeeld
        horhoek4# = horhoek#: verhoek4# = verhoek#
        qx# = 400 + schaalx# * pf# * horhoek0#
        qy# = 225 - schaaly# * pf# * verhoek0#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xkprojectie0 = qx#: ykprojectie0 = qy#: jn0 = 1
        END IF
        qx# = 400 + schaalx# * pf# * horhoek1#
        qy# = 225 - schaaly# * pf# * verhoek1#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xkprojectie1 = qx#: ykprojectie1 = qy#: jn1 = 1
        END IF
        qx# = 400 + schaalx# * pf# * horhoek2#
        qy# = 225 - schaaly# * pf# * verhoek2#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xkprojectie2 = qx#: ykprojectie2 = qy#: jn2 = 1
        END IF
        qx# = 400 + schaalx# * pf# * horhoek3#
        qy# = 225 - schaaly# * pf# * verhoek3#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xkprojectie3 = qx#: ykprojectie3 = qy#: jn3 = 1
        END IF
        qx# = 400 + schaalx# * pf# * horhoek4#
        qy# = 225 - schaaly# * pf# * verhoek4#
        khoek# = kantel# * 3: GOSUB kantel
        IF qx# >= 0 - Buitenmarge AND qx# <= 799 + Buitenmarge AND qy# >= 0 - Buitenmarge AND qy# <= 449 + Buitenmarge THEN
            xkprojectie4 = qx#: ykprojectie4 = qy#: jn4 = 1
        END IF


        IF DayNight$ = "NIGHT" THEN



            IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
            END IF
        ELSE
            IF diast <= 2000 THEN
                gridcolor = 163
                IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
                    LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
                    LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
                    LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
                    LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
                END IF
            END IF
        END IF
        '   Aanpassen grens Elevation
        IF ykprojectie0 < yU(AEN) THEN yU(AEN) = ykprojectie0
        IF ykprojectie1 < yU(AEN) THEN yU(AEN) = ykprojectie1
        IF ykprojectie2 < yU(AEN) THEN yU(AEN) = ykprojectie2
        IF ykprojectie3 < yU(AEN) THEN yU(AEN) = ykprojectie3
        IF ykprojectie4 < yU(AEN) THEN yU(AEN) = ykprojectie4


    NEXT
NEXT AEN

'*****************************************************************************
'                                           CROSSHAIR
'Horizontaal
LINE (393, 225)-(398, 225), 15
LINE (402, 225)-(407, 225), 15

'Verticaal
LINE (400, 223)-(400, 218), 15
LINE (400, 227)-(400, 232), 15

'*****************************************************************************
'                                               HUD
GOSUB gumviewtekenHUD
'************************************************************************************************************
'                                                                                         Rescues Op Radar
IF radar$ = "ON" THEN
    FOR altpsn = 1 TO waypoints
        IF rescue(altpsn) = 0 THEN
            dRes# = _HYPOT(xwp#(altpsn) - xc0#, zwp#(altpsn) - zc0#)
            RAlpha# = 2 * pi# - Koers#
            RBeta# = _ATAN2((zwp#(altpsn) - zc0#), (xwp#(altpsn) - xc0#))
            RescueRadarhoek# = .5 * pi# - (RAlpha# + RBeta#)
            WHILE RescueRadarhoek# > 2 * pi#: RescueRadarhoek# = RescueRadarhoek# - 2 * pi#: WEND
            WHILE RescueRadarhoek# < 0: RescueRadarhoek# = RescueRadarhoek# + 2 * pi#: WEND

            IF dRes# <= 4000 AND dRes# > 2000 THEN '                        Voorwaarden
                IF RescueRadarhoek# > 1.75 * pi# OR RescueRadarhoek# < .25 * pi# THEN '        grote radar
                    xRadar = 740 + (SIN(RescueRadarhoek#) * dRes# / 62.5)
                    yRadar = 410 - (COS(RescueRadarhoek#) * dRes# / 62.5)
                    LINE (xRadar - 1, yRadar - 1)-(xRadar + 1, yRadar + 1), 15
                    LINE (xRadar - 1, yRadar + 1)-(xRadar + 1, yRadar - 1), 15
                END IF
            END IF
            IF dRes# <= 2000 THEN '                                                      Voorwaarden kleine radar
                xRadar = 740 + (SIN(RescueRadarhoek#) * dRes# / 62.5)
                yRadar = 410 - (COS(RescueRadarhoek#) * dRes# / 62.5)
                LINE (xRadar - 1, yRadar - 1)-(xRadar + 1, yRadar + 1), 15
                LINE (xRadar - 1, yRadar + 1)-(xRadar + 1, yRadar - 1), 15
            END IF
        END IF
    NEXT
END IF

'
IF radar$ = "ON" THEN
    FOR ojn = 1 TO AantalObjecten
        IF ObjectYesNo(ojn) = 1 THEN
            '
            ObjectDistance#(ojn) = _HYPOT(objectdx#(ojn) - xc0#, objectdz#(ojn) - zc0#)
            Alpha# = 2 * pi# - Koers#
            Beta# = _ATAN2((objectdz#(ojn) - zc0#), (objectdx#(ojn) - xc0#))

            ObjectRadarhoek#(ojn) = .5 * pi# - (Alpha# + Beta#)
            WHILE ObjectRadarhoek#(ojn) > 2 * pi#: ObjectRadarhoek#(ojn) = ObjectRadarhoek#(ojn) - 2 * pi#: WEND
            WHILE ObjectRadarhoek#(ojn) < 0: ObjectRadarhoek#(ojn) = ObjectRadarhoek#(ojn) + 2 * pi#: WEND
            '
            IF ObjectDistance#(ojn) <= 4000 AND ObjectDistance#(ojn) > 2000 THEN '                        Voorwaarden
                IF ObjectRadarhoek#(ojn) > 1.75 * pi# OR ObjectRadarhoek#(ojn) < .25 * pi# THEN '        grote radar
                    xRadar = 740 + (SIN(ObjectRadarhoek#(ojn)) * ObjectDistance#(ojn) / 62.5)
                    yRadar = 410 - (COS(ObjectRadarhoek#(ojn)) * ObjectDistance#(ojn) / 62.5)
                    PSET (xRadar, yRadar), ostipkleur '
                END IF
            END IF
            IF ObjectDistance#(ojn) <= 2000 THEN '                                                      Voorwaarden kleine radar
                xRadar = 740 + (SIN(ObjectRadarhoek#(ojn)) * ObjectDistance#(ojn) / 62.5)
                yRadar = 410 - (COS(ObjectRadarhoek#(ojn)) * ObjectDistance#(ojn) / 62.5)
                PSET (xRadar, yRadar), ostipkleur
            END IF
        END IF
    NEXT
    '************************************************************************************************************
    'Basis op radar
    '
    BasisDistance# = _HYPOT(Basisdx# - xc0#, Basisdz# - zc0#)
    Alpha# = 2 * pi# - Koers#
    Beta# = _ATAN2((Basisdz# - zc0#), (Basisdx# - xc0#))

    BasisRadarhoek# = .5 * pi# - (Alpha# + Beta#)
    WHILE BasisRadarhoek# > 2 * pi#: BasisRadarhoek# = BasisRadarhoek# - 2 * pi#: WEND
    WHILE BasisRadarhoek# < 0: BasisRadarhoek# = BasisRadarhoek# + 2 * pi#: WEND

    IF BasisDistance# <= 4000 AND BasisDistance# > 2000 THEN '                        Voorwaarden
        IF BasisRadarhoek# > 1.75 * pi# OR BasisRadarhoek# < .25 * pi# THEN '        grote radar
            xRadar = 740 + (SIN(BasisRadarhoek#) * BasisDistance# / 62.5)
            yRadar = 410 - (COS(BasisRadarhoek#) * BasisDistance# / 62.5)
            LINE (xRadar - 1, yRadar - 1)-(xRadar + 1, yRadar + 1), 140, BF
        END IF
    END IF
    IF BasisDistance# <= 2000 THEN '                                                      Voorwaarden kleine radar
        xRadar = 740 + (SIN(BasisRadarhoek#) * BasisDistance# / 62.5)
        yRadar = 410 - (COS(BasisRadarhoek#) * BasisDistance# / 62.5)
        LINE (xRadar - 1, yRadar - 1)-(xRadar + 1, yRadar + 1), 140, BF
    END IF
END IF



'*****SOMMIGE DINGEN VOOR LANDCHECK
IF status$ = "LANDED" AND afstand# < landingstolerantie# THEN
    IF fuel# < fuelmax# THEN GOSUB fuelplus
    IF didammo = 0 THEN didammo = 1: GOSUB VulWapensAan
    'If TotalPersonsRescued = 1 Then '
    '
    IF TotalPersonsRescued = ToBeRescued THEN '
        score& = score& + 5000
        _SNDPLAY Bonus4& '
        GOSUB TimeBonus
        GOSUB LoadRescues
        TotalPersonsRescued = 0
        FOR apsn = 1 TO waypoints
            rescue(apsn) = 0
        NEXT
        rescue(0) = 1
        Tempsec& = 0
    END IF
END IF
'****************************************************************
IF status$ <> "LANDED" THEN
    didammo = 0
    GOSUB fuelmin
    'ROTORSOUND MAAKT ENKEL GELUID ALS status$ <> "LANDED"
    IF rsf = 0 THEN _SNDLOOP Blades&: rsf = 1: bladesturn$ = "on"
ELSE
    IF rsf = 1 AND fuel# <= 0 THEN _SNDSTOP Blades&: rsf = 0: bladesturn$ = "off"
    '**************
END IF
'**************

'*****************************************************************************
'                                               BESTURING
_DISPLAY
IF gameover = 1 GOTO gameover 'Pas naar gameover: bij ververst scherm
IF i$ = CHR$(27) THEN Exit$ = "- ABORTED -": gameover = 1
IF Totalloss = 1 THEN Exit$ = "- DESTROYED -": gameover = 1
IF i$ = "#" THEN CLOSE #1: SYSTEM
IF UCASE$(i$) = "P" THEN GOSUB Pause
IF UCASE$(i$) = "H" THEN GOSUB help
IF UCASE$(i$) = "M" THEN GOSUB map

IF devmode = 0 AND Tempsec& >= AllowedSec& GOTO TimeUp
'********************************************************************************
' Voorwaarde INVASIE (xITMZwaartepunt#,...,zITMZwaartepunt#)   en   (0,...,0)
FOR AEN = 1 TO NumberOfEnemiesActive
    d& = _HYPOT(xITMZwaartepunt#(AEN), zITMZwaartepunt#(AEN))
    IF d& < 24 AND vijandType(AEN) <> 1 THEN Exit$ = "- YOUR BASE GOT OVERRUN -": gameover = 1
    IF d& < 24 AND vijandType(AEN) = 1 THEN Exit$ = "SUPPLIES:": GOTO Delivered
NEXT
'********************************************************************************
IF Speedcrash = 1 THEN
    Exit$ = "- YOU CRASHED -": gameover = 1
END IF
IF Kantelcrash = 1 THEN
    Exit$ = "- YOU CRASHED -": gameover = 1: Kantelcrash = 0
END IF

'********************************************************************************

IF vertraging = 1 THEN _DELAY (DelayTime#)
IF flits = 0 THEN
    CLS
ELSE
    LINE (0, 0)-(799, 449), 131, BF: 'de grote gummer
    flits = 0
END IF



IF i$ = "." THEN
    PLAY "v" + Pct$ + "MBl32o5a"
    waypoint = waypoint + 1
    IF waypoint = waypoints + 1 THEN waypoint = 0
END IF
IF i$ = "," THEN
    PLAY "v" + Pct$ + "MBl32o5a"
    waypoint = waypoint - 1
    IF waypoint = -1 THEN waypoint = waypoints
END IF

rescue(0) = 1
FOR altwaypoint = 0 TO waypoints
    afstandwp#(altwaypoint) = _HYPOT(xc0# - xwp#(altwaypoint), zc0# - zwp#(altwaypoint))
    IF afstandwp#(altwaypoint) < waypointstolerantie# AND status$ = "LANDED" AND rescue(altwaypoint) = 0 THEN
        rescue(altwaypoint) = 1
        score& = score& + 1000
        _SNDPLAY Rescue&
        '
        ShowRescue = 1
    END IF
NEXT



'Easteregg1: Huisjes op coordinaat 1313,1313

IF TypeObjecten MOD 2 = 0 AND INT(xc0#) = 1313 AND INT(zc0#) = 1313 AND EasterEgg1 = 0 THEN EasterEgg1 = 1: score& = score& + 2000: _SNDPLAY Bonus5& '  1313 easteregg

frames = frames + 1
IF frames > 999 THEN frames = 0
GOTO startlabel
'*****************************************************************************
HorizonPaint: '
'*************************************************************************************    HORIZON
IF Sky$ = "OFF" THEN RETURN
IF DayNight$ <> "NIGHT" THEN
    '
    altheading = heading MOD 360
    IF altheading <= -180 THEN altheading = altheading + 360
    IF altheading >= 180 THEN altheading = altheading - 360
    camerahoek# = altheading / pf#
    starthoek# = camerahoek# - 1.25
    stophoek# = camerahoek# + 1.25

    xp# = 50000 * SIN(starthoek#)
    yp# = 0
    zp# = 50000 * COS(starthoek#)
    GOSUB BepaalBeeld
    qx# = 400 + schaalx# * pf# * horhoek#
    qy# = 225 - schaaly# * pf# * verhoek#
    khoek# = kantel# * 3: GOSUB kantel
    xSky1 = qx#: ySky1 = qy# + (printhoogte / 4)

    xp# = 50000 * SIN(stophoek#)
    yp# = 0
    zp# = 50000 * COS(stophoek#)
    GOSUB BepaalBeeld
    qx# = 400 + schaalx# * pf# * horhoek#
    qy# = 225 - schaaly# * pf# * verhoek#
    khoek# = kantel# * 3: GOSUB kantel
    xSky2 = qx#: ySky2 = qy# + (printhoogte / 4)


    aFactor# = (ySky2 - ySky1) / (xSky2 - xSky1)
    bFactor# = ySky1 - (aFactor# * xSky1)

    yLINKS = bFactor#
    yRECHTS = aFactor# * 799 + bFactor#
    LINE (0, yLINKS)-(799, yRECHTS), SkyColor
    IF ySky1 > 2 OR ySky2 > 2 THEN
        IF yLINKS >= yRECHTS AND yLINKS > 0 THEN PAINT (0, 0), SkyColor
        IF yLINKS <= yRECHTS AND yRECHTS > 0 THEN PAINT (799, 0), SkyColor
    END IF
    ''Locate 5, 15: Print xSky1
    '''fLocate 6, 15: Print ySky1
    ''Locate 5, 80: Print xSky2
    ''Locate 6, 80: Print ySky2


END IF
RETURN
'****************************************************************************************************
UnlockObjects:
'
IF TypeObjecten = 1 THEN LLock(5) = 0
IF TypeObjecten = 2 THEN LLock(6) = 0
IF TypeObjecten = 3 THEN LLock(7) = 0

RETURN
'*****************************************************************************
'
'   Fuel reeds afgewikkeld, nu de wapens
VulWapensAan:
IF BaseBullets >= 1200 THEN
    NumberOfBullets = 1200
    BaseBullets = BaseBullets - 1200
    ammo = NumberOfBullets
END IF
RETURN

'
UitroepTeken:

ammo = 1200: fuel# = fuelmax#: DevModeEver = 1: GOSUB SwapDevMode
'If RecordDemo = 1 Then Put (773, 26), recBackground(0), PSet
RecordDemo = 0
IF uitroeptekenooit = 0 THEN
    IF UCASE$(RecDemo$) = "ON" THEN PRINT #13, 9999, 9999, 9999, 9999: CLOSE #13
    uitroeptekenooit = 1
END IF

RETURN
'
StartDemoRecording:
PLAY "v" + Pct$ + "MBl32o5e"
OPEN "..\REPLAY.mcr" FOR OUTPUT AS #13
RecordDemo = 1
RETURN

gameover:
_SNDSTOP Damage&
_SNDSTOP Blades&
bladesturn$ = "off"

TIMER OFF
'
IF uitroeptekenooit = 0 THEN
    IF UCASE$(RecDemo$) = "ON" THEN
        PRINT #13, 9999, 9999, 9999, 9999
        CLOSE #13
        'Put (773, 26), recBackground(0), PSet
    END IF
END IF

IF secbooks& < 1 THEN
    secbooks& = 1
    PRINT #1, dummy&, xc0#, yc0#, zc0#, fuel#, ammo, heading, snelheid
END IF

CLOSE #1 'QWEQWE
_SNDPLAY Fail&
_MOUSESHOW
x1 = 255: y1 = 115: x2 = 544: y2 = 319: GOSUB TekenBlok
x1 = 260: y1 = 120: x2 = 539: y2 = 314: GOSUB TekenGat
waarde$ = "GAME OVER": dx = 400: dy = 130: GOSUB PlaatsTekstCentered
waarde$ = "---------------------------------------": dx = 400: dy = 140: GOSUB PlaatsTekstCentered
waarde$ = Exit$: dx = 400: dy = 160: GOSUB PlaatsTekstCentered
w1$ = LTRIM$(STR$(score&))
WHILE LEN(w1$) < 6: w1$ = "0" + w1$: WEND
waarde$ = "SCORE: " + w1$: dx = 400: dy = 180: GOSUB PlaatsTekstCentered
OPEN "..\TXTFiles\TMPSCORE.TXT" FOR OUTPUT AS #1
PRINT #1, score&
CLOSE #1
waarde$ = "YOU HAVE REACHED LEVEL " + LTRIM$(STR$(RFileNr)): dx = 400: dy = 200: GOSUB PlaatsTekstCentered
min$ = LTRIM$(STR$(sec& \ 60))
sec$ = LTRIM$(STR$(sec& MOD 60))
WHILE LEN(min$) < 2: min$ = "0" + min$: WEND
WHILE LEN(sec$) < 2: sec$ = "0" + sec$: WEND
waarde$ = "TIME: " + min$ + ":" + sec$: dx = 400: dy = 220: GOSUB PlaatsTekstCentered
waarde$ = "FUEL: " + LTRIM$(STR$(INT(FuelTotalUsed#))): dx = 400: dy = 240: GOSUB PlaatsTekstCentered
IF tak > 0 THEN
    waarde$ = "HIT/MISS: " + LEFT$(LTRIM$(STR$(100 * (tar / tak))), 5) + " %": dx = 400: dy = 260: GOSUB PlaatsTekstCentered
ELSE
    waarde$ = "HIT/MISS: " + "0.000 %": dx = 400: dy = 260: GOSUB PlaatsTekstCentered
END IF
waarde$ = "CLICK HERE": dx = 400: dy = 290: GOSUB PlaatsTekstCentered
'Line (356, 286)-(443, 300), 9, B

_DISPLAY
_DELAY .2
WHILE INKEY$ <> "": WEND 'Flush buffer

_DELAY .2
'
_SNDPLAY ThemeC&
_AUTODISPLAY
totalteller = 0
WHILE INKEY$ = ""
    _LIMIT OverallFramerate
    Mouse 3
    IF BMuis = 1 AND VMuis >= 286 AND VMuis <= 300 AND HMuis >= 356 AND HMuis <= 443 THEN _DISPLAY: GOTO ExitMenu
    totalteller = totalteller + 1
    '  If totalteller > 22.5 * OverallFramerate Then _Display: GoTo ExitMenu
WEND

GOTO ExitMenu
'**************************************************************************
'
TimeUp:
Exit$ = "- TIME UP -"
TIMER OFF
IF UCASE$(RecDemo$) = "ON" THEN
    PRINT #13, 9999, 9999, 9999, 9999
    CLOSE #13
END IF

IF secbooks& < 1 THEN
    secbooks& = 1
    PRINT #1, dummy&, xc0#, yc0#, zc0#, fuel#, ammo, heading, snelheid
END IF

CLOSE #1 'QWEQWE
_SNDSTOP Damage&
_SNDSTOP Blades&
_SNDPLAY Fail&
_MOUSESHOW
x1 = 255: y1 = 115: x2 = 544: y2 = 319: GOSUB TekenBlok
x1 = 260: y1 = 120: x2 = 539: y2 = 314: GOSUB TekenGat
waarde$ = "GAME OVER": dx = 400: dy = 130: GOSUB PlaatsTekstCentered
waarde$ = "---------------------------------------": dx = 400: dy = 140: GOSUB PlaatsTekstCentered
waarde$ = Exit$: dx = 400: dy = 160: GOSUB PlaatsTekstCentered
w1$ = LTRIM$(STR$(score&))
WHILE LEN(w1$) < 6: w1$ = "0" + w1$: WEND
waarde$ = "SCORE: " + w1$: dx = 400: dy = 180: GOSUB PlaatsTekstCentered
waarde$ = "YOU HAVE REACHED LEVEL " + LTRIM$(STR$(RFileNr)): dx = 400: dy = 200: GOSUB PlaatsTekstCentered
min$ = LTRIM$(STR$(sec& \ 60))
sec$ = LTRIM$(STR$(sec& MOD 60))
WHILE LEN(min$) < 2: min$ = "0" + min$: WEND
WHILE LEN(sec$) < 2: sec$ = "0" + sec$: WEND
waarde$ = "TIME: " + min$ + ":" + sec$: dx = 400: dy = 220: GOSUB PlaatsTekstCentered
waarde$ = "FUEL: " + LTRIM$(STR$(INT(FuelTotalUsed#))): dx = 400: dy = 240: GOSUB PlaatsTekstCentered

IF tak > 0 THEN
    waarde$ = "HIT/MISS: " + LEFT$(LTRIM$(STR$(100 * (tar / tak))), 5) + " %": dx = 400: dy = 260: GOSUB PlaatsTekstCentered
ELSE
    waarde$ = "HIT/MISS: " + "0.000 %": dx = 400: dy = 260: GOSUB PlaatsTekstCentered
END IF
waarde$ = "CLICK HERE": dx = 400: dy = 290: GOSUB PlaatsTekstCentered
'Line (356, 286)-(443, 300), 9, B
_DISPLAY
_DELAY .2
WHILE INKEY$ <> ""
WEND
_DELAY .2
WHILE INKEY$ = ""
    _LIMIT OverallFramerate
    Mouse 3
    ' If BMuis = 1 And VMuis >= 286 And VMuis <= 300 And HMuis >= 356 And HMuis <= 443 Then Line (356, 286)-(443, 300), 15, B: _Display: GoTo ExitMenu
    IF BMuis = 1 AND VMuis >= 286 AND VMuis <= 300 AND HMuis >= 356 AND HMuis <= 443 THEN _DISPLAY: GOTO ExitMenu
WEND
'Line (356, 286)-(443, 300), 15, B
GOTO ExitMenu

'**************************************************************************



Delivered:
'
_SNDPLAY Dingdong&
LLock(1) = 0
BaseFuel = BaseFuel + TransportFuel
BaseBullets = BaseBullets + TransportBullets
GOSUB NextEnemy '
TIMER ON
ShowCargo = 1
GOTO startlabel


ExtraLabel:
WHILE BMuis <> 0
    _LIMIT OverallFramerate
    Mouse 3
WEND
didammo = 0 '              Check opnieuw de stash
GOTO startlabel

NextEnemy:
level = level + 1 '! Level is niet het rescuelevel maar het voertuignummer,  rescuelevel = RFileNr  !!!!!
firstTimeWarnNOT(AEN) = 0 'RESET RADAR STIP OP 'NOOIT GEZIEN '
'
vijanddx#(AEN) = 0
vijanddy#(AEN) = 0
vijanddz#(AEN) = 0

Herstel:

INPUT #7, vijandType(AEN), hoek(AEN), VijandAfstand#(AEN), VijandSpeed#(AEN)
VijandHoek#(AEN) = (90 - hoek(AEN)) / pf#


IF vijandType(AEN) = 1 THEN
    INPUT #7, TransportFuel, TransportBullets
END IF

IF vijandType(AEN) = 99 THEN
    CLOSE #7
    Exit$ = "- CONGRATULATIONS! -": gameover = 1
END IF



SELECT CASE vijandType(AEN) '
    CASE 2 'SPORTSCAR
        RadarDotType(AEN) = 1 '***************** 1 is enemy, 0 is friend
        SELECT CASE fastslow$
            CASE "FASTCPU": vijand$(AEN) = "ENEMY02.ITM": HitAfstand#(AEN) = HitBallSportscar: enemydamage(AEN) = 0
            CASE "SLOWCPU": vijand$(AEN) = "ENEMY02A.ITM": HitAfstand#(AEN) = HitBallSportscar: enemydamage(AEN) = 0
        END SELECT
    CASE 3 'JEEP
        RadarDotType(AEN) = 1
        SELECT CASE fastslow$
            CASE "FASTCPU": vijand$(AEN) = "ENEMY03.ITM": HitAfstand#(AEN) = HitBallJeep: enemydamage(AEN) = 0
            CASE "SLOWCPU": vijand$(AEN) = "ENEMY03A.ITM": HitAfstand#(AEN) = HitBallJeep: enemydamage(AEN) = 0
        END SELECT
    CASE 4 'TANK
        RadarDotType(AEN) = 1

        '
        _SNDPLAY ThemeB&

        SELECT CASE fastslow$
            CASE "FASTCPU": vijand$(AEN) = "ENEMY04.ITM": HitAfstand#(AEN) = HitBallTank: enemydamage(AEN) = 0
            CASE "SLOWCPU": vijand$(AEN) = "ENEMY04A.ITM": HitAfstand#(AEN) = HitBallTank: enemydamage(AEN) = 0
        END SELECT
    CASE 1 'SUPPLY TRUCK
        RadarDotType(AEN) = 0
        SELECT CASE fastslow$
            CASE "FASTCPU": vijand$(AEN) = "ENEMY01.ITM": HitAfstand#(AEN) = HitBallSupplytruck: enemydamage(AEN) = 0
            CASE "SLOWCPU": vijand$(AEN) = "ENEMY01A.ITM": HitAfstand#(AEN) = HitBallSupplytruck: enemydamage(AEN) = 0
        END SELECT
END SELECT

vijanddx#(AEN) = VijandAfstand#(AEN) * COS(VijandHoek#(AEN))
vijanddy#(AEN) = 0
vijanddz#(AEN) = VijandAfstand#(AEN) * SIN(VijandHoek#(AEN))

sxvijand#(AEN) = -VijandSpeed#(AEN) * COS(VijandHoek#(AEN))
syvijand#(AEN) = 0
szvijand#(AEN) = -VijandSpeed#(AEN) * SIN(VijandHoek#(AEN))

GOSUB loadvijand

'ROTEER VIJAND

xb# = xITMZwaartepunt#(AEN)
yb# = yITMZwaartepunt#(AEN)
zb# = zITMZwaartepunt#(AEN)


FOR vn = 0 TO l(AEN) - 1
    FOR pn = 0 TO 4 '
        hs# = -VijandHoek#(AEN)
        xa# = itmscale * xvijand#(AEN, vn, pn): ya# = itmscale * yvijand#(AEN, vn, pn): za# = itmscale * zvijand#(AEN, vn, pn)
        GOSUB DraaiY
        xvijand#(AEN, vn, pn) = xa# / itmscale: yvijand#(AEN, vn, pn) = ya# / itmscale: zvijand#(AEN, vn, pn) = za# / itmscale
    NEXT
NEXT
xITMZwaartepunt#(AEN) = 0
yITMZwaartepunt#(AEN) = 0
zITMZwaartepunt#(AEN) = 0
FOR vn = 0 TO l(AEN) - 1
    xITMZwaartepunt#(AEN) = xITMZwaartepunt#(AEN) + xvijand#(AEN, vn, 0)
    yITMZwaartepunt#(AEN) = yITMZwaartepunt#(AEN) + yvijand#(AEN, vn, 0)
    zITMZwaartepunt#(AEN) = zITMZwaartepunt#(AEN) + zvijand#(AEN, vn, 0)
NEXT
xITMZwaartepunt#(AEN) = vijanddx#(AEN) + itmscale * (xITMZwaartepunt#(AEN) / l(AEN))
yITMZwaartepunt#(AEN) = vijanddy#(AEN) + itmscale * (yITMZwaartepunt#(AEN) / l(AEN))
zITMZwaartepunt#(AEN) = vijanddz#(AEN) + itmscale * (zITMZwaartepunt#(AEN) / l(AEN))
Wreck(AEN) = 0

RETURN

'****************************************8
loadvijand:
''PRINT "..\ITMFiles\" + vijand$(AEN)
''SLEEP
OPEN "..\ITMFiles\" + vijand$(AEN) FOR INPUT AS #3
INPUT #3, a$
INPUT #3, l(AEN)
FOR vn = 0 TO l(AEN) - 1
    FOR pn = 0 TO 4 '                                  pn=0  -->  zwaartepunt
        INPUT #3, xvijand#(AEN, vn, pn), yvijand#(AEN, vn, pn), zvijand#(AEN, vn, pn) ' 1-4   -->  hoekpunten
        xvijand#(AEN, vn, pn) = xvijand#(AEN, vn, pn) - xoffset#
        yvijand#(AEN, vn, pn) = yvijand#(AEN, vn, pn) - yoffset#
        zvijand#(AEN, vn, pn) = zvijand#(AEN, vn, pn) - zoffset#
    NEXT
    INPUT #3, kleurvijand(AEN, vn)
NEXT
INPUT #3, a$
CLOSE #3

xITMZwaartepunt#(AEN) = 0
yITMZwaartepunt#(AEN) = 0
zITMZwaartepunt#(AEN) = 0
FOR vn = 0 TO l(AEN) - 1
    xITMZwaartepunt#(AEN) = xITMZwaartepunt#(AEN) + xvijand#(AEN, vn, 0)
    yITMZwaartepunt#(AEN) = yITMZwaartepunt#(AEN) + yvijand#(AEN, vn, 0)
    zITMZwaartepunt#(AEN) = zITMZwaartepunt#(AEN) + zvijand#(AEN, vn, 0)
NEXT
xITMZwaartepunt#(AEN) = itmscale * (xITMZwaartepunt#(AEN) / l(AEN))
yITMZwaartepunt#(AEN) = itmscale * (yITMZwaartepunt#(AEN) / l(AEN))
zITMZwaartepunt#(AEN) = itmscale * (zITMZwaartepunt#(AEN) / l(AEN))

RETURN
'*************************************

ShowObjectsLeft:
ShowObjects = 1
RETURN

ShowInvert:
ShowInvert = 1
Shoti& = 0
IF Invert = 1 THEN Invert = -1: RETURN
IF Invert = -1 THEN Invert = 1: RETURN
RETURN

ShowController:
ShowController = 1
RETURN

TimeBonus:
TIMER OFF '
_SNDSTOP Blades&
_MOUSESHOW
WHILE INKEY$ <> "": WEND
x1 = 255: y1 = 175: x2 = 544: y2 = 278: GOSUB TekenBlok
x1 = 260: y1 = 180: x2 = 539: y2 = 273: GOSUB TekenGat
waarde$ = "LEVEL " + LTRIM$(STR$(RFileNr)) + " COMPLETED": dx = 400:: dy = 190: GOSUB PlaatsTekstCentered
waarde$ = "---------------------------------------": dx = 400: dy = 200: GOSUB PlaatsTekstCentered
waarde$ = "BONUS: 5000 + " + LTRIM$(STR$((AllowedSec& - Tempsec&) * 10))
dx = 400: dy = 220
GOSUB PlaatsTekstCentered

waarde$ = "PRESS BUTTON": dx = 400: dy = 245: GOSUB PlaatsTekstCentered
'Line (356, 236)-(443, 250), 9, B
WHILE INKEY$ = ""
    Mouse 3
    IF BMuis = 1 GOTO exwh2
    _LIMIT OverallFramerate
    _DISPLAY
WEND
exwh2:
' Line (356, 236)-(443, 250), 15, B
_DISPLAY
_DELAY .2
WHILE INKEY$ <> "": WEND
WHILE BMuis <> 0: Mouse 3: _LIMIT OverallFramerate: WEND
IF ShowCursor = 0 THEN _MOUSEHIDE
TIMER ON
score& = score& + (AllowedSec& - Tempsec&) * 10
IF fuel# > 0 OR status$ <> "LANDED" THEN _SNDLOOP Blades&: rsf = 1: bladesturn$ = "on"
IF DamSound = 1 THEN _SNDLOOP Damage&
RETURN

loadperson:
FOR animatieframe = 1 TO 4
    animatiefile$ = "..\ITMFiles\PERSON" + LTRIM$(STR$(animatieframe)) + ".ITM"
    OPEN animatiefile$ FOR INPUT AS #10
    INPUT #10, a$
    INPUT #10, apv 'aantal person-vlakken
    FOR pvn = 0 TO apv - 1
        INPUT #10, xlp0#(animatieframe, pvn), ylp0#(animatieframe, pvn), zlp0#(animatieframe, pvn)
        INPUT #10, xlp1#(animatieframe, pvn), ylp1#(animatieframe, pvn), zlp1#(animatieframe, pvn)
        INPUT #10, xlp2#(animatieframe, pvn), ylp2#(animatieframe, pvn), zlp2#(animatieframe, pvn)
        INPUT #10, xlp3#(animatieframe, pvn), ylp3#(animatieframe, pvn), zlp3#(animatieframe, pvn)
        INPUT #10, xlp4#(animatieframe, pvn), ylp4#(animatieframe, pvn), zlp4#(animatieframe, pvn)
        INPUT #10, klp(animatieframe, pvn)
    NEXT
    INPUT #10, a$
    CLOSE #10
NEXT
RETURN


NewObjects:

'
AantalObjecten = AantalObjecten + 4
IF AantalObjecten > 60 THEN AantalObjecten = 60


TypeObjecten = TypeObjecten + 1
IF TypeObjecten = 4 THEN TypeObjecten = 1






object$ = "OBJECT0" + LTRIM$(STR$(TypeObjecten)) + ".ITM"

'  Object HitBalls
IF TypeObjecten = 1 THEN ObjectHitBall = Object1HitBall
IF TypeObjecten = 2 THEN ObjectHitBall = Object2HitBall
IF TypeObjecten = 3 THEN ObjectHitBall = Object3HitBall







OPEN "..\ITMFiles\" + object$ FOR INPUT AS #9
INPUT #9, a$
INPUT #9, aov 'aantal object-vlakken
FOR vn = 0 TO aov - 1
    INPUT #9, xlo0#(vn), ylo0#(vn), zlo0#(vn)
    INPUT #9, xlo1#(vn), ylo1#(vn), zlo1#(vn)
    INPUT #9, xlo2#(vn), ylo2#(vn), zlo2#(vn)
    INPUT #9, xlo3#(vn), ylo3#(vn), zlo3#(vn)
    INPUT #9, xlo4#(vn), ylo4#(vn), zlo4#(vn)
    INPUT #9, klo(vn)
NEXT
INPUT #9, a$
CLOSE #9
FOR obn = 1 TO AantalObjecten 'Roteren object
    hs# = 2 * pi# * RND
    xb# = 0: yb# = 0: zb# = 0
    FOR vn = 0 TO aov - 1
        xa# = xlo0#(vn): ya# = ylo0#(vn): za# = zlo0#(vn): GOSUB DraaiY: xlo0#(vn) = xa#: ylo0#(vn) = ya#: zlo0#(vn) = za#
        xa# = xlo1#(vn): ya# = ylo1#(vn): za# = zlo1#(vn): GOSUB DraaiY: xlo1#(vn) = xa#: ylo1#(vn) = ya#: zlo1#(vn) = za#
        xa# = xlo2#(vn): ya# = ylo2#(vn): za# = zlo2#(vn): GOSUB DraaiY: xlo2#(vn) = xa#: ylo2#(vn) = ya#: zlo2#(vn) = za#
        xa# = xlo3#(vn): ya# = ylo3#(vn): za# = zlo3#(vn): GOSUB DraaiY: xlo3#(vn) = xa#: ylo3#(vn) = ya#: zlo3#(vn) = za#
        xa# = xlo4#(vn): ya# = ylo4#(vn): za# = zlo4#(vn): GOSUB DraaiY: xlo4#(vn) = xa#: ylo4#(vn) = ya#: zlo4#(vn) = za#
    NEXT
    FOR vn = 0 TO aov - 1
        xobject#(obn, vn, 0) = xlo0#(vn): yobject#(obn, vn, 0) = ylo0#(vn): zobject#(obn, vn, 0) = zlo0#(vn)
        xobject#(obn, vn, 1) = xlo1#(vn): yobject#(obn, vn, 1) = ylo1#(vn): zobject#(obn, vn, 1) = zlo1#(vn)
        xobject#(obn, vn, 2) = xlo2#(vn): yobject#(obn, vn, 2) = ylo2#(vn): zobject#(obn, vn, 2) = zlo2#(vn)
        xobject#(obn, vn, 3) = xlo3#(vn): yobject#(obn, vn, 3) = ylo3#(vn): zobject#(obn, vn, 3) = zlo3#(vn)
        xobject#(obn, vn, 4) = xlo4#(vn): yobject#(obn, vn, 4) = ylo4#(vn): zobject#(obn, vn, 4) = zlo4#(vn)
        kleurobject(obn, vn) = klo(vn)
    NEXT
NEXT

FOR ojn = 1 TO AantalObjecten
    objectdx#(ojn) = -MaximaleObjectAfstand + 2 * MaximaleObjectAfstand * RND
    objectdy#(ojn) = 0
    objectdz#(ojn) = -MaximaleObjectAfstand + 2 * MaximaleObjectAfstand * RND
    ObjectYesNo(ojn) = 1
NEXT
ObjectsHit = 0
Bonus1 = 0
Bonus2 = 0
Bonus3 = 0
Bonus4 = 0
EasterEgg1 = 0
EasterEgg2 = 0

RETURN

SwapShowCoordinates:
IF ShowCoordinates = 1 THEN ShowCoordinates = 0: RETURN
IF ShowCoordinates = 0 THEN ShowCoordinates = 1: RETURN

SwapCursor:
IF ShowCursor = 0 THEN ShowCursor = 1: _MOUSESHOW: RETURN
IF ShowCursor = 1 THEN ShowCursor = 0: _MOUSEHIDE: RETURN

swapBlades:
IF ShowBlades = 0 THEN ShowBlades = 1: RETURN
IF ShowBlades = 1 THEN ShowBlades = 0: RETURN

place:
waarde$ = "PRESS ESCAPE KEY": dx = 400: dy = 260: GOSUB PlaatsTekstCentered
RETURN

landcheck:

xx1# = (xc3# + xc4#) / 2
zz1# = (zc3# + zc4#) / 2
afstand# = _HYPOT(xx1# - xland#, zz1# - zland#)
IF status$ <> "CRASHED" THEN '
    '   dx = 400: dy = 370: waarde$ = "LANDED": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 80: waarde$ = "KEEP THE MOUSE CURSOR NEAR THE CROSSHAIR": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 90: waarde$ = "AND HOLD LEFT MOUSEBUTTON": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 100: waarde$ = "FOR VERTICAL TAKE-OFF": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 110: waarde$ = "RELEASE TO LEVEL": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 120: waarde$ = "START DESCENDING WITH RIGHT MOUSEBUTTON": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 140: waarde$ = "PRESS \H\ FOR IN-GAME KEYS": GoSub PlaatsTekstCentered
    '   dx = 400: dy = 150: waarde$ = "PRESS ESC TO ABORT GAME": GoSub PlaatsTekstCentered
    status$ = "LANDED"
END IF
RETURN

linksrechts:
GOSUB bepalenkoers
hs# = var1# * camhoekspeed# * (1 - speedfactor#)
xb# = xc0#: yb# = yc0#: zb# = zc0#
xa# = xc1#: ya# = yc1#: za# = zc1#: GOSUB DraaiY: xc1# = xa#: yc1# = ya#: zc1# = za#
xa# = xc2#: ya# = yc1#: za# = zc2#: GOSUB DraaiY: xc2# = xa#: yc1# = ya#: zc2# = za#
xa# = xc3#: ya# = yc3#: za# = zc3#: GOSUB DraaiY: xc3# = xa#: yc3# = ya#: zc3# = za#
xa# = xc4#: ya# = yc3#: za# = zc4#: GOSUB DraaiY: xc4# = xa#: yc3# = ya#: zc4# = za#
xa# = xc5#: ya# = yc5#: za# = zc5#: GOSUB DraaiY: xc5# = xa#: yc5# = ya#: zc5# = za#
RETURN

omhoogomlaag:
GOSUB bepalenkoers
hs# = Koers#
xb# = xc0#: yb# = yc0#: zb# = zc0#
xa# = xc1#: ya# = yc1#: za# = zc1#: GOSUB DraaiY: xc1# = xa#: yc1# = ya#: zc1# = za#
xa# = xc2#: ya# = yc2#: za# = zc2#: GOSUB DraaiY: xc2# = xa#: yc2# = ya#: zc2# = za#
xa# = xc3#: ya# = yc3#: za# = zc3#: GOSUB DraaiY: xc3# = xa#: yc3# = ya#: zc3# = za#
xa# = xc4#: ya# = yc4#: za# = zc4#: GOSUB DraaiY: xc4# = xa#: yc4# = ya#: zc4# = za#
xa# = xc5#: ya# = yc5#: za# = zc5#: GOSUB DraaiY: xc5# = xa#: yc5# = ya#: zc5# = za#
hs# = SGN(xc2# - xc1#) * var2# * camhoekspeed#
helhoek# = helhoek# + hs#
'IF helhoek# <= -helgrensvooruit# THEN helhoek# = -helgrensvooruit#: hs# = 0 '
'IF helhoek# >= helgrensachteruit# THEN helhoek# = helgrensvooruit#: hs# = 0
IF helhoek# <= -helgrensvooruit# THEN helhoek# = helhoek# - hs#: hs# = 0 '
IF helhoek# >= helgrensachteruit# THEN helhoek# = helhoek# - hs#: hs# = 0
xb# = xc0#: yb# = yc0#: zb# = zc0#
xa# = xc1#: ya# = yc1#: za# = zc1#: GOSUB draaix: xc1# = xa#: yc1# = ya#: zc1# = za#
xa# = xc2#: ya# = yc2#: za# = zc2#: GOSUB draaix: xc2# = xa#: yc2# = ya#: zc2# = za#
xa# = xc3#: ya# = yc3#: za# = zc3#: GOSUB draaix: xc3# = xa#: yc3# = ya#: zc3# = za#
xa# = xc4#: ya# = yc4#: za# = zc4#: GOSUB draaix: xc4# = xa#: yc4# = ya#: zc4# = za#
xa# = xc5#: ya# = yc5#: za# = zc5#: GOSUB draaix: xc5# = xa#: yc5# = ya#: zc5# = za#
hs# = -Koers#
xb# = xc0#: yb# = yc0#: zb# = zc0#
xa# = xc1#: ya# = yc1#: za# = zc1#: GOSUB DraaiY: xc1# = xa#: yc1# = ya#: zc1# = za#
xa# = xc2#: ya# = yc2#: za# = zc2#: GOSUB DraaiY: xc2# = xa#: yc2# = ya#: zc2# = za#
xa# = xc3#: ya# = yc3#: za# = zc3#: GOSUB DraaiY: xc3# = xa#: yc3# = ya#: zc3# = za#
xa# = xc4#: ya# = yc4#: za# = zc4#: GOSUB DraaiY: xc4# = xa#: yc4# = ya#: zc4# = za#
xa# = xc5#: ya# = yc5#: za# = zc5#: GOSUB DraaiY: xc5# = xa#: yc5# = ya#: zc5# = za#
RETURN

vooruit:
spx# = ((xc0# - xc5#) / Zoom#) * camspeed# * speedfactor#
spz# = ((zc0# - zc5#) / Zoom#) * camspeed# * speedfactor#
xc1# = xc1# + spx#: xc2# = xc2# + spx#: xc3# = xc3# + spx#: xc4# = xc4# + spx#: xc5# = xc5# + spx#
zc1# = zc1# + spz#: zc2# = zc2# + spz#: zc3# = zc3# + spz#: zc4# = zc4# + spz#: zc5# = zc5# + spz#
RETURN

stijgendalen:
IF stijgkracht# > .15 THEN stijgkracht# = .15
IF stijgkracht# < -.15 THEN stijgkracht# = -.15
spy# = camspeed# * stijgkracht#
IF stijgkracht# <= .8 * os# AND stijgkracht# >= 0 THEN
    IF power$ = "on" AND levelhoogte$ = "off" THEN yl# = yc0#: mbh = 0: levelhoogte$ = "on"
END IF
yc1# = yc1# + spy#: yc2# = yc2# + spy#: yc3# = yc3# + spy#: yc4# = yc4# + spy#: yc5# = yc5# + spy#
RETURN

bepalenkoers:
Koers# = _ATAN2((zc2# - zc1#), (xc2# - xc1#))
RETURN

gumviewtekenHUD:
waarde$ = "WP " + RIGHT$(STR$(waypoint), LEN(STR$(waypoint)) - 1)
dx = 32: dy = 410: GOSUB PlaatsTekstCentered
waarde$ = RIGHT$(STR$(INT(afstandwp#(waypoint) / 10) * 10), LEN(STR$(afstandwp#(waypoint))) - 1) + " FT"
dx = 32: dy = 430: GOSUB PlaatsTekstCentered

IF FPSPrint = 1 THEN dx = 8: dy = 45: waarde$ = LTRIM$(STR$(framespark)) + " FPS": GOSUB PlaatsTekstLinksUitlijn

IF devmode = 1 THEN
    dx = 8: dy = 35: waarde$ = "DEVMODE": GOSUB PlaatsTekstLinksUitlijn
    w1$ = RIGHT$(STR$(tiles), LEN(STR$(tiles)) - 1) '
    WHILE LEN(w1$) < 5: w1$ = "0" + w1$: WEND
    waarde$ = w1$ + " TILES"
    dx = 600: dy = 15: GOSUB PlaatsTekstCentered
    dx = 200: dy = 15: waarde$ = UCASE$(Bestand$): GOSUB PlaatsTekstCentered
END IF

IF DepotPrint = 1 THEN
    waarde$ = "DEPOT:": dx = 20: dy = 80: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(BaseFuel)) + " GL": dx = 20: dy = 100: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(BaseBullets)) + " RNDS": dx = 20: dy = 110: GOSUB PlaatsTekstLinksUitlijn
END IF

IF txt$(waypoint) <> "@" THEN dx = 10: dy = 540: waarde$ = txt$(waypoint): GOSUB PlaatsTekstLinksUitlijn
LINE (398, 16)-(402, 16), 15
LINE (400, 16)-(400, 12), 15
horizon = 225 + 576 * helhoek#
IF horizon <= 30 THEN
    LINE (390, 225)-(400, 215), 15
    LINE (400, 215)-(410, 225), 15
END IF
IF horizon >= 590 THEN
    LINE (390, 225)-(400, 235), 15
    LINE (400, 235)-(410, 225), 15
END IF
IF horizon > 30 AND horizon < 420 THEN
    LINE (398, horizon)-(402, horizon), 15
END IF
yh1 = ((18 * kantel# * pf#) + 10 * helhoek# * pf# + 240 + hh# * .1) + ABS(kantel# * 90) - (1 * yc0#)
yh2 = ((-18 * kantel# * pf#) + 10 * helhoek# * pf# + 240 + hh# * .1) + ABS(kantel# * 90) - (1 * yc0#)
yh3 = (yh1 + yh2) / 2
hh# = (yc0# * 5) - 2
dx = 513: dy = 370: waarde$ = STR$(INT(210 * speedfactor# * .54)) + " KTS": snelheid = VAL(waarde$)
GOSUB PlaatsTekstCentered

'
heading = 360 - INT(Koers# * pf#) MOD 360
IF heading >= 360 THEN heading = heading - 360
waarde$ = LTRIM$(STR$(heading))
IF waarde$ = "360" THEN waarde$ = "0"
dx = 401: dy = 21: GOSUB PlaatsTekstCentered

'
IF INT(fuel#) <= 20 AND status$ <> "LANDED" THEN
    IF FuelWarned = 0 THEN _SNDPLAY Damage&: FuelWarned = 1
    FuelLow = 1
ELSE
    FuelWarned = 0
    FuelLow = 0
END IF

IF INT(fuel#) > 20 THEN FuelWarned = 0




SELECT CASE FuelLow
    CASE 0
        waarde$ = STR$(INT(fuel#)) + " GL"
        dx = 300: dy = 370: GOSUB PlaatsTekstCentered
    CASE 1
        KnipperTeller& = KnipperTeller& + 1
        IF KnipperTeller& > KnipperTellerMax& THEN SWAP Knipper1, Knipper2: KnipperTeller& = 0
        IF Knipper1 = 1 THEN
            waarde$ = STR$(INT(fuel#)) + " GL"
            dx = 300: dy = 370: GOSUB PlaatsTekstCentered
        END IF
END SELECT

IF ammo < 100 THEN AmmoLow = 1 ELSE AmmoLow = 0
SELECT CASE AmmoLow
    CASE 0
        waarde$ = STR$(ammo) + " 30MM"
        dx = 300: dy = 410: GOSUB PlaatsTekstCentered
    CASE 1
        KnipperTellert& = KnipperTellert& + 1
        IF KnipperTellert& > KnipperTellerMax& THEN SWAP Knippert1, Knippert2: KnipperTellert& = 0
        IF Knippert1 = 1 THEN
            waarde$ = STR$(ammo) + " 30MM"
            dx = 300: dy = 410: GOSUB PlaatsTekstCentered
        END IF
END SELECT

SELECT CASE SchadeTailRotor
    CASE 0 '
    CASE 1
        KnipperTellerTR& = KnipperTellerTR& + 1
        IF KnipperTellerTR& > KnipperTellerMax& THEN SWAP KnipperTR1, KnipperTR2: KnipperTellerTR& = 0
        IF KnipperTR1 = 1 THEN
            waarde$ = "TAIL ROTOR"
            dx = 220: dy = 390: GOSUB PlaatsTekstCentered
        END IF
END SELECT
SELECT CASE SchadeFuel
    CASE 0 '
    CASE 1
        KnipperTellerFL& = KnipperTellerFL& + 1
        IF KnipperTellerFL& > KnipperTellerMax& THEN SWAP KnipperFL1, KnipperFL2: KnipperTellerFL& = 0
        IF KnipperFL1 = 1 THEN
            waarde$ = "FUEL LEAK"
            dx = 220: dy = 410: GOSUB PlaatsTekstCentered
        END IF
END SELECT

'
waarde$ = STR$(INT((hh# + 1) / 5) - ymin): printhoogte = VAL(waarde$) '
dx = 500: dy = 410: GOSUB PlaatsTekstCentered

IF hh# < 150 THEN
    yonder = 470 - (hh# / 1.5)
    IF yonder < 371 THEN yonder = 371
    IF yonder < 410 THEN LINE (468, yonder)-(470, 449), 15, BF ELSE LINE (468, yonder)-(470, 449), 8, BF
    LINE (467, 370)-(471, 450), 14, B
END IF

IF levelhoogte$ = "on" THEN LINE (484, 407)-(514, 419), 15, B

waarde$ = "FT"
dx = 528: dy = 410: GOSUB PlaatsTekstCentered
'
'  Grafisch Radar Blok
'


Anglecorrection# = .02
CIRCLE (740, 410), 32, 14
CIRCLE (740, 410), 16, 14
CIRCLE (740, 410), 64, 14, .25 * pi# + Anglecorrection#, .75 * pi# - Anglecorrection#
hoekje = hoekje - hoekjesstap
WHILE hoekje < 0: hoekje = hoekje + 360: WEND
LINE (740, 410)-(740 + straaltje * COS(hoekje / pf#), 410 - straaltje * SIN(hoekje / pf#)), 14
IF s1 = 1 THEN hoekje2 = hoekje2 + hoekjesstap
IF s1 = 0 THEN hoekje2 = hoekje2 - hoekjesstap
IF hoekje2 > 134 OR hoekje2 < 46 THEN SWAP s1, s0
LINE (740, 410)-(740 + straaltje2 * COS(hoekje2 / pf#), 410 - straaltje2 * SIN(hoekje2 / pf#)), 14
LINE (737, 407)-(695, 365), 14
LINE (743, 407)-(785, 365), 14
LINE (740, 408)-(740, 412), 14
LINE (738, 410)-(742, 410), 14
LINE (740, 381)-(740, 346), 14
LINE (740, 391)-(740, 397), 14
LINE (708, 410)-(711, 410), 14
LINE (772, 410)-(769, 410), 14
LINE (721, 410)-(727, 410), 14
LINE (753, 410)-(759, 410), 14
LINE (740, 439)-(740, 442), 14
LINE (740, 423)-(740, 429), 14

'xITMZwaartepunt#    xc0# \
'yITMZwaartepunt#    yc0# |   We nemen slechts de x- en de z-waarden
'zITMZwaartepunt#    zc0# /       Verticale radar is voor later.
IF radar$ = "ON" THEN
    FOR AEN = 1 TO NumberOfEnemiesActive
        Distance#(AEN) = _HYPOT(xITMZwaartepunt#(AEN) - xc0#, zITMZwaartepunt#(AEN) - zc0#)
        Alpha# = 2 * pi# - Koers#
        Beta# = _ATAN2((zITMZwaartepunt#(AEN) - zc0#), (xITMZwaartepunt#(AEN) - xc0#))

        Radarhoek#(AEN) = .5 * pi# - (Alpha# + Beta#)
        WHILE Radarhoek#(AEN) > 2 * pi#: Radarhoek#(AEN) = Radarhoek#(AEN) - 2 * pi#: WEND
        WHILE Radarhoek#(AEN) < 0: Radarhoek#(AEN) = Radarhoek#(AEN) + 2 * pi#: WEND

        IF Distance#(AEN) <= 4000 AND Distance#(AEN) > 2000 THEN '                        Voorwaarden
            IF Radarhoek#(AEN) > 1.75 * pi# OR Radarhoek#(AEN) < .25 * pi# THEN '        grote radar
                xRadar(AEN) = 740 + (SIN(Radarhoek#(AEN)) * Distance#(AEN) / 62.5)
                yRadar(AEN) = 410 - (COS(Radarhoek#(AEN)) * Distance#(AEN) / 62.5)

                roodflits(AEN) = roodflits(AEN) - 1
                IF roodflits(AEN) = 225 THEN roodflits(AEN) = 249

                SELECT CASE RadarDotType(AEN) ' 0=friend 1=enemy ************************
                    CASE 0
                        IF Wreck(AEN) = 0 THEN CIRCLE (xRadar(AEN), yRadar(AEN)), 2, 15 '    was 164
                    CASE 1
                        IF Wreck(AEN) = 0 THEN LINE (xRadar(AEN) - 1, yRadar(AEN) - 1)-(xRadar(AEN) + 1, yRadar(AEN) + 1), roodflits(AEN), BF
                END SELECT
                IF Wreck(AEN) = 0 AND firstTimeWarnNOT(AEN) = 0 THEN PLAY "v" + Pct$ + "MBl32o4a": firstTimeWarnNOT(AEN) = 1: roodflits(AEN) = 249
            END IF
        END IF

        IF Distance#(AEN) <= 2000 THEN '                 Voorwaarden kleine radar
            xRadar(AEN) = 740 + (SIN(Radarhoek#(AEN)) * Distance#(AEN) / 62.5)
            yRadar(AEN) = 410 - (COS(Radarhoek#(AEN)) * Distance#(AEN) / 62.5)

            roodflits(AEN) = roodflits(AEN) - 1
            IF roodflits(AEN) = 225 THEN roodflits(AEN) = 249

            SELECT CASE RadarDotType(AEN)
                CASE 0
                    IF Wreck(AEN) = 0 THEN CIRCLE (xRadar(AEN), yRadar(AEN)), 2, 15 '    was 164
                CASE 1
                    IF Wreck(AEN) = 0 THEN LINE (xRadar(AEN) - 1, yRadar(AEN) - 1)-(xRadar(AEN) + 1, yRadar(AEN) + 1), roodflits(AEN), BF
            END SELECT
            IF Wreck(AEN) = 0 AND firstTimeWarnNOT(AEN) = 0 THEN PLAY "v" + Pct$ + "MBl32o4a": firstTimeWarnNOT(AEN) = 1: roodflits(AEN) = 249
        END IF

        IF Distance#(AEN) <= 4000 AND Distance#(AEN) > 2000 THEN '                        Voorwaarden
            IF Radarhoek#(AEN) <= 1.75 * pi# AND Radarhoek#(AEN) >= .25 * pi# THEN '        grote radar
                firstTimeWarnNOT(AEN) = 0
            END IF
        END IF
        IF Distance#(AEN) > 4000 THEN firstTimeWarnNOT(AEN) = 0
    NEXT
END IF
'
'***************************************
'
xp# = xwp#(waypoint)
yp# = ywp#(waypoint)
zp# = zwp#(waypoint)
GOSUB BepaalBeeld
qx# = 400 + schaalx# * pf# * horhoek#
qy# = 225 - schaaly# * pf# * verhoek#
khoek# = kantel# * 3: GOSUB kantel

IF qx# >= 0 AND qx# <= 799 THEN
    LINE (qx# - 5, 0)-(qx#, 10)
    LINE (qx#, 9)-(qx# + 5, 0)
    arrows = 0
ELSE
    arrows = 1
END IF
w1# = _HYPOT(xwp#(waypoint) - xc1#, zwp#(waypoint) - zc1#)
w2# = _HYPOT(xwp#(waypoint) - xc2#, zwp#(waypoint) - zc2#)
IF w1# < w2# AND arrows = 1 THEN
    LINE (5, 0)-(0, 5)
    LINE -(5, 10)
    LINE (6, 0)-(1, 5)
    LINE -(6, 10)
    LINE (7, 0)-(2, 5)
    LINE -(7, 10)
END IF
IF w1# > w2# AND arrows = 1 THEN
    LINE (794, 0)-(799, 5)
    LINE -(794, 10)
    LINE (793, 0)-(798, 5)
    LINE -(793, 10)
    LINE (792, 0)-(797, 5)
    LINE -(792, 10)
END IF
IF ShowObjects = 1 THEN
    Shot& = Shot& + 1
    IF Shot& > FPSTarget THEN Shot& = 0: ShowObjects = 0 '       ONE SECOND
    waarde$ = STR$(AantalObjecten - ObjectsHit) + " LEFT": dx = 400: dy = 200
    GOSUB PlaatsTekstCentered
END IF

'
muxer$ = LTRIM$(RTRIM$(STR$(muxer!) + "x"))
SELECT CASE muxer$
    CASE ".25x": PUT (750, 60), muxMask(0), AND: PUT (750, 60), mux(0), XOR
    CASE ".5x":: PUT (750, 60), muxMask(500), AND: PUT (750, 60), mux(500), XOR
    CASE "1x"
        IF yesss = 1 THEN PUT (750, 60), muxMask(1000), AND: PUT (750, 60), mux(1000), XOR: yesssteller& = yesssteller& + 1
    CASE "2x":: PUT (750, 60), muxMask(1500), AND: PUT (750, 60), mux(1500), XOR
    CASE "4x":: PUT (750, 60), muxMask(2000), AND: PUT (750, 60), mux(2000), XOR
END SELECT
IF yesssteller& > OverallFramerate * 2 THEN yesss = 0: yesssteller& = 0






IF ShowInvert = 1 THEN
    Shoti& = Shoti& + 1
    IF Shoti& > FPSTarget THEN Shoti& = 0: ShowInvert = 0 '       ONE SECOND
    IF Invert = -1 THEN waarde$ = "INVERTED" ELSE waarde$ = "NORMAL"
    dx = 400: dy = 190
    GOSUB PlaatsTekstCentered
END IF

IF DepotPrint = 1 THEN
    ShowDteller& = ShowDteller& + 1
    IF ShowDteller& > 2 * FPSTarget THEN ShowDteller& = 0: DepotPrint = 0 ' DEPOT  TWO SECONDS
END IF

IF ShowRescue = 1 THEN '!@#!@#
    ShowRteller& = ShowRteller& + 1
    IF ShowRteller& > 4 * FPSTarget THEN ShowRteller& = 0: ShowRescue = 0 ' RESCUES GEVINKT  TWO SECONDS
    FOR awp = 1 TO waypoints
        dx = 20: dy = 140 + (awp - 1) * 10
        waarde$ = "RESCUE " + LTRIM$(STR$(awp))
        GOSUB PlaatsTekstLinksUitlijn
        LINE (90, dy)-(96, dy + 6), , B
        IF rescue(awp) = 1 THEN
            PUT (89, dy - 1), VinkMask(0), AND
            PUT (89, dy - 1), Vink(0), XOR
        END IF
    NEXT
END IF

IF ShowCargo = 1 THEN
    waarde$ = Exit$: dx = 600: dy = 80: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = "FUEL:": dx = 600: dy = 100: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = "M230:": dx = 600: dy = 110: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(BaseFuel)) + " GL": dx = 635: dy = 100: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(BaseBullets)) + " RNDS": dx = 635: dy = 110: GOSUB PlaatsTekstLinksUitlijn
    waarde$ = "AVAILABLE AT BASE": dx = 600: dy = 130: GOSUB PlaatsTekstLinksUitlijn
    ShowCteller& = ShowCteller& + 1
    IF ShowCteller& > 3 * FPSTarget THEN ShowCteller& = 0: ShowCargo = 0 ' Cargo 3 SECONDS
END IF

IF ShowController = 1 THEN
    Shot1& = Shot1& + 1
    IF Shot1& > FPSTarget THEN Shot1& = 0: ShowController = 0 '       one SECOND
    waarde$ = controller$: dx = 400: dy = 200
    GOSUB PlaatsTekstCentered
END IF

IF ShowCoordinates = 1 THEN
    waarde$ = "GPS"
    dx = 400: dy = 400
    GOSUB PlaatsTekstCentered
    waarde$ = LTRIM$(STR$(INT(xc0#))) + "," + LTRIM$(STR$(INT(zc0#)))
    dx = 400: dy = 410
    GOSUB PlaatsTekstCentered
END IF

score$ = LTRIM$(STR$(score&))
WHILE LEN(score$) < 6: score$ = "0" + score$: WEND
waarde$ = "SCORE:" + score$
dx = 708: dy = 15
GOSUB PlaatsTekstLinksUitlijn

level$ = LTRIM$(STR$(RFileNr))
WHILE LEN(level$) < 2: level$ = "0" + level$: WEND
waarde$ = "LEVEL:" + level$
dx = 708: dy = 25
GOSUB PlaatsTekstLinksUitlijn

waarde$ = "DAMAGE:" + LTRIM$(STR$(PlayerDamage)) + " %"
dx = 8: dy = 15
GOSUB PlaatsTekstLinksUitlijn

min$ = LTRIM$(STR$((AllowedSec& - Tempsec&) \ 60))
sec$ = LTRIM$(STR$((AllowedSec& - Tempsec&) MOD 60))
WHILE LEN(min$) < 2: min$ = "0" + min$: WEND
WHILE LEN(sec$) < 2: sec$ = "0" + sec$: WEND
waarde$ = min$ + ":" + sec$
dx = 43: dy = 25
GOSUB PlaatsTekstLinksUitlijn


'  2 minuten
IF min$ <= "01" THEN
    IF TimeWarned = 0 THEN _SNDPLAY Damage&: TimeWarned = 1
    tijdknipper& = tijdknipper& + 1
    IF tijdknipper& >= FPSTarget / 4 THEN tijdknipper& = 0: SWAP tk1, tk2
    IF tk1 = 0 THEN
        waarde$ = "TIME:"
        dx = 8: dy = 25
        GOSUB PlaatsTekstLinksUitlijn
    END IF
ELSE
    TimeWarned = 0
    waarde$ = "TIME:"
    dx = 8: dy = 25
    GOSUB PlaatsTekstLinksUitlijn
END IF


'

IF RecordDemo = 1 THEN

    KnipperREC = KnipperREC + 1
    IF KnipperREC < 20 THEN
        '
        GET (773, 26)-(790, 29), recBackground(0)
        PUT (773, 26), recMask(0), AND
        PUT (773, 26), rec(0), XOR

    END IF
    IF KnipperREC > 40 THEN KnipperREC = 0
END IF


RETURN

BepaalBeeld:
'in :xc0#,yc0#,zc0#   Midden tafereel
'    xc5#,yc5#,zc5#   Oog
'    xp#,yp#,zp#      Te projecteren punt
'    pi#
'uit:horhoek#
'    verhoek#
'
'HORIZONTAAL
k1# = 2 * pi# - Koers#
koers1# = _ATAN2((zp# - zc0#), (xp# - xc0#))
k2# = 2 * pi# - koers1#
horhoek# = k2# - k1#
WHILE horhoek# < 0: horhoek# = horhoek# + 2 * pi#: WEND
WHILE horhoek# > 2 * pi#: horhoek# = horhoek# - 2 * pi#: WEND
horhoek# = horhoek# - 1.5 * pi#
'VERTICAAL
overstaande# = yp# - yc5#
aanliggende# = _HYPOT(xp# - xc5#, zp# - zc5#)
k1# = helhoek#
k2# = ATN(overstaande# / aanliggende#)
verhoek# = 2 * (k2# - k1#)
RETURN

kantel:
IF Mode$ = "EASY" THEN RETURN
IF qx# = 400 AND qy# <= 225 THEN qalpha# = .5 * pi#: GOTO hu
IF qx# = 400 AND qy# > 225 THEN qalpha# = 1.5 * pi#: GOTO hu
IF qx# >= 400 THEN qalpha# = ATN((225 - qy#) / (qx# - 400))
IF qx# < 400 THEN qalpha# = pi# + ATN((225 - qy#) / (qx# - 400))
ql# = _HYPOT(qx# - 400, 225 - qy#)
hu:
qalpha# = qalpha# + khoek#
qx# = 400 + ql# * COS(qalpha#)
qy# = 225 - ql# * SIN(qalpha#)
RETURN

fuelplus:
IF ammo < 1200 THEN GOSUB VulWapensAan
IF PlayerDamage > 0 THEN
    _SNDPLAY Garage&
    PlayerDamage = 0
END IF
SchadeFuel = 0
SchadeTailRotor = 0
Totalloss = 0
IF fuel# >= 0 AND fuel# < fuelmax# THEN
    KnipperTeller& = KnipperTeller& + 1
    IF KnipperTeller& > KnipperTellerMax& THEN SWAP Knipper3, Knipper4: KnipperTeller& = 0
    IF Knipper3 = 1 AND BaseFuel > 0 THEN ' KNIPPERT ALS DE CAPACITEIT NIET HELEMAAL BENUT IS EN DE BASE-VOORRAAD>0 IS!!!
        waarde$ = "REFUELING"
        dx = 220: dy = 370: GOSUB PlaatsTekstCentered
    END IF
END IF
power$ = "on": levelhoogte$ = "off"
IF BaseFuel > 0 THEN fuel# = fuel# + 1: FuelTotalUsed# = FuelTotalUsed# + 1: BaseFuel = BaseFuel - 1
IF fuel# >= fuelmax# THEN
    fuel# = fuelmax#
END IF
RETURN

fuelmin:
'                           verbruik# = .004
'                           speedfactor# [-.75, .75]
'                           hh# [0, 5000]
'
SELECT CASE SchadeFuel '****** Verbruik * 5 bij schade
    CASE 0
        fuel# = fuel# - (verbruik# + ABS(speedfactor#) * .008 + hh# * .0000002)
        IF fuel# < 0 THEN fuel# = 0: power$ = "off": levelhoogte$ = "off"
    CASE 1
        fuel# = fuel# - 5 * (verbruik# + ABS(speedfactor#) * .008 + hh# * .0000002)
        IF fuel# < 0 THEN fuel# = 0: power$ = "off": levelhoogte$ = "off"
END SELECT
IF devmode = 1 THEN fuel# = 230
RETURN

schiet:
IF ammo <= 0 THEN ammo = 0: RETURN
kn = kn + 1
tak = tak + 1
IF kn > MaxKogels - 1 THEN kn = 0
_SNDPLAY Gun&
schietstatus(kn) = 1


xk#(kn) = xc5#
yk#(kn) = yc5#
zk#(kn) = zc5#

sxk#(kn) = spx# + (xc0# - xc5#) * kogelsnelheid#
syk#(kn) = spy# + (yc0# - yc5#) * kogelsnelheid#
szk#(kn) = spz# + (zc0# - zc5#) * kogelsnelheid#
ammo = ammo - 1
IF devmode = 1 THEN ammo = 1200
RETURN

draaix: 'Draai a om b (x-as) met hoek hs#
hoekx# = 0
aa# = xa#
bb# = ya#
cc# = za#
r# = _HYPOT(bb# - yb#, cc# - zb#)
hoekx# = _ATAN2((cc# - zb#), (bb# - yb#))
hoekx# = hoekx# - hs#
bb# = r# * COS(hoekx#) + yb#
cc# = r# * SIN(hoekx#) + zb#
xa# = aa#
ya# = bb#
za# = cc#
RETURN

DraaiY: 'Draai a om b (y-as) met hoek hs#
hoeky# = 0
aa# = xa#
bb# = ya#
cc# = za#
r# = _HYPOT(aa# - xb#, cc# - zb#)
hoeky# = _ATAN2((cc# - zb#), (aa# - xb#))
hoeky# = hoeky# - hs#
aa# = r# * COS(hoeky#) + xb#
cc# = r# * SIN(hoeky#) + zb#
xa# = aa#
ya# = bb#
za# = cc#
RETURN

TekenBlok:
LINE (x1, y1)-(x2 - 1, y1), 4
LINE (x2, y1)-(x2, y2 - 1), 4
LINE (x2, y2)-(x1 + 1, y2), 2
LINE (x1, y2)-(x1, y1 + 1), 2
LINE (x1 + 1, y1 + 1)-(x2 - 2, y1 + 1), 4
LINE (x2 - 1, y1 + 1)-(x2 - 1, y2 - 2), 4
LINE (x2 - 1, y2 - 1)-(x1 + 2, y2 - 1), 2
LINE (x1 + 1, y2 - 1)-(x1 + 1, y1 + 2), 2
LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 3, BF
RETURN

TekenGat:
LINE (x1, y1)-(x2 - 1, y1), 2
LINE (x2, y1)-(x2, y2 - 1), 2
LINE (x2, y2)-(x1 + 1, y2), 4
LINE (x1, y2)-(x1, y1 + 1), 4
LINE (x1 + 1, y1 + 1)-(x2 - 2, y1 + 1), 2
LINE (x2 - 1, y1 + 1)-(x2 - 1, y2 - 2), 2
LINE (x2 - 1, y2 - 1)-(x1 + 2, y2 - 1), 4
LINE (x1 + 1, y2 - 1)-(x1 + 1, y1 + 2), 4
'
IF DayNight$ = "NIGHT" THEN LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 0, BF
IF DayNight$ = "DAY" THEN LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 100, BF
RETURN

loaditm:
OPEN "..\ITMFiles\" + Bestand$ FOR INPUT AS #2
INPUT #2, a$
INPUT #2, kVlakken: tiles = kVlakken
FOR vn = 0 TO kVlakken - 1
    FOR pn = 0 TO 4 '                                  pn=0  -->  zwaartepunt
        INPUT #2, x#(vn, pn), y#(vn, pn), z#(vn, pn) ' 1-4   -->  hoekpunten
    NEXT
    INPUT #2, kleur(vn)
NEXT
INPUT #2, a$
CLOSE #2
'
OPEN "..\TXTFiles\CURRENT.TXT" FOR OUTPUT AS #21
PRINT #21, Bestand$
CLOSE #21
RETURN

swapVertraging:
PLAY "v" + Pct$ + "MBl32o3a"
IF vertraging = 1 THEN vertraging = 0: RETURN
IF vertraging = 0 THEN vertraging = 1: RETURN

swapScreen:
PLAY "v" + Pct$ + "MBl32o3a"
OPEN "..\TXTFiles\DISPLAY.TXT" FOR INPUT AS #4
INPUT #4, screen$
CLOSE #4
IF screen$ = "WINDOWED" THEN screen$ = "FULLSCREEN": GOSUB WriteSettings: GOTO label
IF screen$ = "FULLSCREEN" THEN screen$ = "WINDOWED": GOSUB WriteSettings: GOTO label
label:
IF full = 1 THEN _FULLSCREEN _OFF: _SCREENMOVE _MIDDLE: full = 0: RETURN
IF full = 0 THEN _FULLSCREEN _SQUAREPIXELS , _SMOOTH: full = 1: RETURN
WriteSettings:
OPEN "..\TXTFiles\DISPLAY.TXT" FOR OUTPUT AS #4
PRINT #4, screen$
CLOSE #4
RETURN

swapFPSShow:
IF FPSShow = 1 THEN FPSPrint = 0: FPSShow = 0: RETURN
IF FPSShow = 0 THEN FPSPrint = 1: FPSShow = 1: RETURN

'
SwapDevMode:
GOSUB swapFPSShow
IF devmode = 1 THEN DevModePrint = 0: devmode = 0: RETURN
IF devmode = 0 THEN DevModePrint = 1: devmode = 1: RETURN

pulse:
'
TotalCockpitTime& = TotalCockpitTime& + 1
IF FPSShow = 1 THEN
    framespark = frames: frames = 0
END IF

IF DevModeEver = 0 THEN PRINT #1, secbooks&, xc0#, yc3# - ymin, zc0#, fuel#, ammo, heading, snelheid
secbooks& = secbooks& + 1
IF devmode = 1 THEN RETURN
sec& = sec& + 1
resec& = resec& + 1
Tempsec& = Tempsec& + 1
RETURN

raak:
IF enemydamage(AEN) >= 100 THEN RETURN
SELECT CASE vijandType(AEN)
    CASE 2: enemydamage(AEN) = enemydamage(AEN) + 4: score& = score& + 4: _SNDPLAY HitEnemy&
    CASE 3: enemydamage(AEN) = enemydamage(AEN) + 2: score& = score& + 3: _SNDPLAY HitEnemy&
    CASE 4: enemydamage(AEN) = enemydamage(AEN) + 1: score& = score& + 2: _SNDPLAY HitEnemy&
    CASE 1: enemydamage(AEN) = enemydamage(AEN) + 10: _SNDPLAY Fail&
END SELECT
IF enemydamage(AEN) >= 100 AND vijandType(AEN) <> 1 THEN
    '
    LLock(vijandType(AEN)) = 0
    sxvijand#(AEN) = 0
    syvijand#(AEN) = 0
    szvijand#(AEN) = 0
    enemydamage(AEN) = 0
    GOSUB NextEnemy '
END IF
IF enemydamage(AEN) >= 100 AND vijandType(AEN) = 1 THEN
    sxvijand#(AEN) = 0
    syvijand#(AEN) = 0
    szvijand#(AEN) = 0
    enemydamage(AEN) = 0
    GOSUB NextEnemy
END IF
RETURN

map:
TIMER OFF
_SNDSTOP Damage&
_SNDSTOP Blades&
_MOUSESHOW
WHILE INKEY$ <> "": WEND
x1 = 195: y1 = 25: x2 = 604: y2 = 434: GOSUB TekenBlok
x1 = 200: y1 = 30: x2 = 599: y2 = 429: GOSUB TekenGat
FOR ystip = -2400 TO 2400 STEP 100
    FOR xstip = -2400 TO 2400 STEP 100
        PSET (400 + (400 / 5000) * xstip, 230 + (400 / 5000) * ystip) '     RASTER
    NEXT
NEXT


' Teken "..\ITMFiles\"+Bestand$ in Map
FOR vn = 0 TO kVlakken - 1
    'ITMscale is niet zeker weten
    xvlakinmap1# = 400 + (400 / 5000) * (itmscale * x#(vn, 1) + itmdx)
    yvlakinmap1# = 230 - (400 / 5000) * (itmscale * z#(vn, 1) + itmdz)
    xvlakinmap2# = 400 + (400 / 5000) * (itmscale * x#(vn, 2) + itmdx)
    yvlakinmap2# = 230 - (400 / 5000) * (itmscale * z#(vn, 2) + itmdz)
    xvlakinmap3# = 400 + (400 / 5000) * (itmscale * x#(vn, 3) + itmdx)
    yvlakinmap3# = 230 - (400 / 5000) * (itmscale * z#(vn, 3) + itmdz)
    xvlakinmap4# = 400 + (400 / 5000) * (itmscale * x#(vn, 4) + itmdx)
    yvlakinmap4# = 230 - (400 / 5000) * (itmscale * z#(vn, 4) + itmdz)
    LINE (xvlakinmap1#, yvlakinmap1#)-(xvlakinmap2#, yvlakinmap2#), 5
    LINE -(xvlakinmap3#, yvlakinmap3#), 5
    LINE -(xvlakinmap4#, yvlakinmap4#), 5
    LINE -(xvlakinmap1#, yvlakinmap1#), 5
NEXT


'teken kompasroos
'
PUT (230, 60), RoosMask(0), AND
PUT (230, 60), Roos(0), XOR
dx = 205: dy = 35: waarde$ = "INTEL": GOSUB PlaatsTekstLinksUitlijn

FOR awp = 0 TO waypoints
    xdraw# = 400 + (400 / 5000) * xwp#(awp)
    ydraw# = 230 - (400 / 5000) * zwp#(awp)
    ddx# = xdraw# - 3
    ddy# = ydraw# - 3
    LINE (ddx#, ddy#)-(ddx# + 6, ddy# + 6), , B '                               RESCUES
    waarde$ = LTRIM$(STR$(awp))
    dx = ddx# + 4: dy = ddy# + 9
    GOSUB PlaatsTekstCentered
    IF awp = 0 THEN
        waarde$ = "BASE"
        dx = ddx# + 4: dy = ddy# - 9
        GOSUB PlaatsTekstCentered
    END IF
    IF rescue(awp) = 1 AND awp <> 0 THEN
        PUT (ddx# - 1, ddy# - 1), VinkMask(0), AND
        PUT (ddx# - 1, ddy# - 1), Vink(0), XOR
    END IF
NEXT

'
'************************************************************************************************************
FOR ojn = 1 TO AantalObjecten
    IF ObjectYesNo(ojn) = 1 THEN
        'teken object im map
        xdraw# = 400 + (400 / 5000) * objectdx#(ojn)
        ydraw# = 230 - (400 / 5000) * objectdz#(ojn)
        CIRCLE (xdraw#, ydraw#), 1, 163
        PSET (xdraw#, ydraw#), 163
    END IF
NEXT
'************************************************************************************************************
FOR AEN = 1 TO NumberOfEnemiesActive
    xredcircle = 400 + (400 / 5000) * xITMZwaartepunt#(AEN)
    yredcircle = 230 - (400 / 5000) * zITMZwaartepunt#(AEN)
    IF xredcircle > 205 AND xredcircle < 592 AND yredcircle > 35 AND yredcircle < 422 THEN
        IF vijandType(AEN) = 1 THEN
            '
            CIRCLE (xredcircle, yredcircle), 2, 7, BF
            PAINT (xredcircle, yredcircle), 7
            PSET (xredcircle + 1, yredcircle - 1), 5
        ELSE
            CIRCLE (xredcircle, yredcircle), 2, 8, BF
            PAINT (xredcircle, yredcircle), 8
            PSET (xredcircle + 1, yredcircle - 1), 5
        END IF
    END IF
NEXT

xcopter# = 400 + (400 / 5000) * xc0#
ycopter# = 230 - (400 / 5000) * zc0#

IF xcopter# > 205 AND xcopter# < 592 AND ycopter# > 35 AND ycopter# < 422 THEN
    '
    CIRCLE (xcopter#, ycopter#), 2, 10
    PAINT (xcopter#, ycopter#), 10
    xcopter2# = xcopter# - 16 * SIN(Koers#)
    ycopter2# = ycopter# - 16 * COS(Koers#)
    IF xcopter2# > 205 AND xcopter2# < 592 AND ycopter2# > 35 AND ycopter2# < 422 THEN
        LINE (xcopter#, ycopter#)-(xcopter2#, ycopter2#), 10
    END IF
END IF
WHILE INKEY$ = ""
    Mouse 3
    IF BMuis = 1 GOTO exwh1
    _LIMIT OverallFramerate
    _DISPLAY
WEND
exwh1:
WHILE INKEY$ <> "": WEND
WHILE BMuis <> 0: Mouse 3: _LIMIT OverallFramerate: WEND
IF ShowCursor = 0 THEN _MOUSEHIDE
IF fuel# > 0 OR status$ <> "LANDED" THEN _SNDLOOP Blades&: rsf = 1: bladesturn$ = "on"
IF DamSound = 1 THEN _SNDLOOP Damage&
TIMER ON
RETURN


help:
TIMER OFF
_SNDSTOP Damage&
_SNDSTOP Blades&
_MOUSESHOW
x1 = 205: y1 = 35: x2 = 594: y2 = 419: GOSUB TekenBlok
x1 = 210: y1 = 40: x2 = 589: y2 = 414: GOSUB TekenGat


dx = 400: dy = 49

waarde$ = "IN-GAME KEYS / CONTROL"
GOSUB PlaatsTekstCentered
dx = 400: dy = 60
waarde$ = "-----------------------------------------------------"
GOSUB PlaatsTekstCentered
dx = 400: dy = 80
waarde$ = "MOUSE CONTROLS"
GOSUB PlaatsTekstCentered
dx = 400: dy = 100
waarde$ = "       LEFT BUTTON .......... COLLECTIVE UP          "
GOSUB PlaatsTekstCentered
dx = 400: dy = 110
waarde$ = "       RIGHT BUTTON ......... COLLECTIVE DOWN        "
GOSUB PlaatsTekstCentered
dx = 400: dy = 120
waarde$ = "       MOUSE MOVEMENT ....... CYCLIC                 "
GOSUB PlaatsTekstCentered
dx = 400: dy = 140
waarde$ = "KEYBOARD"
GOSUB PlaatsTekstCentered
dx = 400: dy = 160
waarde$ = "       \A\ .................. COLLECTIVE UP          "
GOSUB PlaatsTekstCentered
dx = 400: dy = 170
waarde$ = "       \Z\ .................. COLLECTIVE DOWN        "
GOSUB PlaatsTekstCentered
dx = 400: dy = 180
waarde$ = "       ARROW KEYS ........... CYCLIC                 "
GOSUB PlaatsTekstCentered
dx = 400: dy = 190
waarde$ = "       SPACEBAR ............. FIRE CANNON            "
GOSUB PlaatsTekstCentered
dx = 400: dy = 200
waarde$ = "       \H\ .................. HELP                   "
GOSUB PlaatsTekstCentered
dx = 400: dy = 210
waarde$ = "       \M\ .................. SHOW MAP               "
GOSUB PlaatsTekstCentered
dx = 400: dy = 220
waarde$ = "       \.\ .................. NEXT WAYPOINT          "
GOSUB PlaatsTekstCentered
dx = 400: dy = 230
waarde$ = "       \,\ .................. PREVIOUS WAYPOINT      "
GOSUB PlaatsTekstCentered
dx = 400: dy = 240
waarde$ = "       \T\ .................. VIEW RESCUE TASKS      "
GOSUB PlaatsTekstCentered
dx = 400: dy = 250
waarde$ = "       \S\ .................. VIEW SUPPLIES          "
GOSUB PlaatsTekstCentered
dx = 400: dy = 260
waarde$ = "       \O\ .................. VIEW OBJECTS REMAINING "
GOSUB PlaatsTekstCentered
dx = 400: dy = 270
waarde$ = "       \G\ .................. HIDE/SHOW GPS          "
GOSUB PlaatsTekstCentered
dx = 400: dy = 280
waarde$ = "       \Q\ .................. HIDE/SHOW CURSOR       "
GOSUB PlaatsTekstCentered
dx = 400: dy = 290
waarde$ = "       \B\ .................. HIDE/SHOW ROTOR BLADES "
GOSUB PlaatsTekstCentered
dx = 400: dy = 300
waarde$ = "       TAB .................. TOGGLE FULLSCREEN      "
GOSUB PlaatsTekstCentered
dx = 400: dy = 310
waarde$ = "       \C\ .................. TOGGLE CONTROL TYPE    "
GOSUB PlaatsTekstCentered
dx = 400: dy = 320
waarde$ = "       \I\ .................. INVERT CONTROLS        "
GOSUB PlaatsTekstCentered
dx = 400: dy = 330
waarde$ = "       \P\ .................. PAUSE                  "
GOSUB PlaatsTekstCentered
dx = 400: dy = 340
waarde$ = "       ESC .................. ABORT GAME             "
GOSUB PlaatsTekstCentered
dx = 400: dy = 370
waarde$ = "PRESS BUTTON TO RETURN TO GAME": GOSUB PlaatsTekstCentered
'Line (286, 366)-(513, 380), 9, B
dx = 400: dy = 390
waarde$ = "-----------------------------------------------------"
GOSUB PlaatsTekstCentered
dx = 400: dy = 400
waarde$ = "                                        V1.6.19 #2023"
GOSUB PlaatsTekstCentered

_DISPLAY
WHILE INKEY$ = ""
    Mouse 3
    IF BMuis = 1 GOTO exwh
    _LIMIT OverallFramerate
    _DISPLAY
WEND
exwh:
WHILE INKEY$ <> "": WEND
' Line (286, 366)-(513, 380), 15, B
_DISPLAY
_DELAY .2
WHILE BMuis <> 0: Mouse 3: _LIMIT OverallFramerate: WEND
IF ShowCursor = 0 THEN _MOUSEHIDE
IF fuel# > 0 OR status$ <> "LANDED" THEN _SNDLOOP Blades&: rsf = 1: bladesturn$ = "on"
IF DamSound = 1 THEN _SNDLOOP Damage&
TIMER ON
RETURN



'Pause: '
'i$ = ""
'Timer Off
'_SndStop Damage&
'_SndStop Blades&
'pauseteller = 0
'Get (339, 160)-(459, 193), pauseback(0)
'
'While BMuis <> 0: _Limit OverallFramerate: Mouse 3: Wend
'While UCase$(i$) <> "P" And i$ <> Chr$(27)
'    i$ = InKey$
'    _Limit OverallFramerate
'    pauseteller = pauseteller + 1
'    If pauseteller > 40 Then pauseteller = 0
'    If pauseteller > 20 Then
'        Put (339, 160), pauseback(0), PSet
'        _Display
'    Else
'        Put (339, 160), PauseMask(0), And
'        Put (339, 160), Pause(0), Xor
'        _Display
'    End If
'Wend
'If fuel# > 0 Or status$ <> "LANDED" Then _SndLoop Blades&: rsf = 1: bladesturn$ = "on"
'If DamSound = 1 Then _SndLoop Damage&
'Timer On
'Return

Pause:
i$ = ""
TIMER OFF
_SNDSTOP Damage&
_SNDSTOP Blades&
PUT (339, 160), PauseMask(0), AND
PUT (339, 160), Pause(0), XOR

gtt = 63
gts = -1
WHILE UCASE$(i$) <> "P" AND i$ <> CHR$(27)
    i$ = INKEY$
    _LIMIT OverallFramerate / 2
    PALETTE 18, 65536 * gtt + 256 * gtt + gtt
    _DISPLAY
    gtt = gtt + gts
    IF gtt = 32 THEN gts = 1
    IF gtt = 63 THEN gts = -1
WEND
PUT (339, 160), pauseback(0), PSET
IF fuel# > 0 OR status$ <> "LANDED" THEN _SNDLOOP Blades&: rsf = 1: bladesturn$ = "on"
IF DamSound = 1 THEN _SNDLOOP Damage&
TIMER ON
RETURN





ExitMenu:

'Palette 0, 0
WHILE INKEY$ <> "": WEND 'Flush keyboard
OPEN "..\TXTFiles\SCORES.TXT" FOR INPUT AS #1
FOR k = 1 TO 10
    INPUT #1, k
    INPUT #1, PlayerName$(k)
    INPUT #1, PlayerScore&(k)
    INPUT #1, PlayerLevel(k)
    INPUT #1, FuelTotal#(k)
    INPUT #1, PlayerSeconds&(k)
    min$(k) = LTRIM$(STR$(PlayerSeconds&(k) \ 60))
    sec$(k) = LTRIM$(STR$(PlayerSeconds&(k) MOD 60))
    WHILE LEN(min$(k)) < 2: min$(k) = "0" + min$(k): WEND
    WHILE LEN(sec$(k)) < 2: sec$(k) = "0" + sec$(k): WEND
    PS$(k) = min$(k) + ":" + sec$(k)
NEXT
CLOSE #1
IF DevModeEver = 1 OR score& < PlayerScore&(10) OR score& = 0 GOTO InvoegenKlaar
IF score& > 999999 THEN score& = 999999
Phrase$ = "            "
NewPos = 0
' INVOEGEN score& IN ARRAY: ****************************
IF score& > PlayerScore&(1) OR (score& = PlayerScore&(1) AND sec& < PlayerSeconds&(1)) OR (score& = PlayerScore&(1) AND sec& = PlayerSeconds&(1) AND FuelTotalUsed# < FuelTotal#(1)) THEN '                           Plek 1:  1=P 2=1 3=2 4=3 5=4 6=5 7=6 8=7 9=8 10=9
    NewPos = 1
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    FuelTotal#(7) = FuelTotal#(6): PlayerName$(7) = PlayerName$(6): PlayerScore&(7) = PlayerScore&(6): PlayerLevel(7) = PlayerLevel(6): PlayerSeconds&(7) = PlayerSeconds&(6): PS$(7) = PS$(6)
    FuelTotal#(6) = FuelTotal#(5): PlayerName$(6) = PlayerName$(5): PlayerScore&(6) = PlayerScore&(5): PlayerLevel(6) = PlayerLevel(5): PlayerSeconds&(6) = PlayerSeconds&(5): PS$(6) = PS$(5)
    FuelTotal#(5) = FuelTotal#(4): PlayerName$(5) = PlayerName$(4): PlayerScore&(5) = PlayerScore&(4): PlayerLevel(5) = PlayerLevel(4): PlayerSeconds&(5) = PlayerSeconds&(4): PS$(5) = PS$(4)
    FuelTotal#(4) = FuelTotal#(3): PlayerName$(4) = PlayerName$(3): PlayerScore&(4) = PlayerScore&(3): PlayerLevel(4) = PlayerLevel(3): PlayerSeconds&(4) = PlayerSeconds&(3): PS$(4) = PS$(3)
    FuelTotal#(3) = FuelTotal#(2): PlayerName$(3) = PlayerName$(2): PlayerScore&(3) = PlayerScore&(2): PlayerLevel(3) = PlayerLevel(2): PlayerSeconds&(3) = PlayerSeconds&(2): PS$(3) = PS$(2)
    FuelTotal#(2) = FuelTotal#(1): PlayerName$(2) = PlayerName$(1): PlayerScore&(2) = PlayerScore&(1): PlayerLevel(2) = PlayerLevel(1): PlayerSeconds&(2) = PlayerSeconds&(1): PS$(2) = PS$(1)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF '

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(1) = INT(FuelTotalUsed#): PlayerName$(1) = Phrase$: PlayerScore&(1) = score&: PlayerLevel(1) = RFileNr: PS$(1) = min$ + ":" + sec$: PlayerSeconds&(1) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(2) OR (score& = PlayerScore&(2) AND sec& < PlayerSeconds&(2)) OR (score& = PlayerScore&(2) AND sec& = PlayerSeconds&(2) AND FuelTotalUsed# < FuelTotal#(2)) THEN '                           Plek 2:  2=P 3=2 4=3 5=4 6=5 7=6 8=7 9=8 10=9
    NewPos = 2
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    FuelTotal#(7) = FuelTotal#(6): PlayerName$(7) = PlayerName$(6): PlayerScore&(7) = PlayerScore&(6): PlayerLevel(7) = PlayerLevel(6): PlayerSeconds&(7) = PlayerSeconds&(6): PS$(7) = PS$(6)
    FuelTotal#(6) = FuelTotal#(5): PlayerName$(6) = PlayerName$(5): PlayerScore&(6) = PlayerScore&(5): PlayerLevel(6) = PlayerLevel(5): PlayerSeconds&(6) = PlayerSeconds&(5): PS$(6) = PS$(5)
    FuelTotal#(5) = FuelTotal#(4): PlayerName$(5) = PlayerName$(4): PlayerScore&(5) = PlayerScore&(4): PlayerLevel(5) = PlayerLevel(4): PlayerSeconds&(5) = PlayerSeconds&(4): PS$(5) = PS$(4)
    FuelTotal#(4) = FuelTotal#(3): PlayerName$(4) = PlayerName$(3): PlayerScore&(4) = PlayerScore&(3): PlayerLevel(4) = PlayerLevel(3): PlayerSeconds&(4) = PlayerSeconds&(3): PS$(4) = PS$(3)
    FuelTotal#(3) = FuelTotal#(2): PlayerName$(3) = PlayerName$(2): PlayerScore&(3) = PlayerScore&(2): PlayerLevel(3) = PlayerLevel(2): PlayerSeconds&(3) = PlayerSeconds&(2): PS$(3) = PS$(2)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(2) = INT(FuelTotalUsed#): PlayerName$(2) = Phrase$: PlayerScore&(2) = score&: PlayerLevel(2) = RFileNr: PS$(2) = min$ + ":" + sec$: PlayerSeconds&(2) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(3) OR (score& = PlayerScore&(3) AND sec& < PlayerSeconds&(3)) OR (score& = PlayerScore&(3) AND sec& = PlayerSeconds&(3) AND FuelTotalUsed# < FuelTotal#(3)) THEN '                           Plek 3:  3=P 4=3 5=4 6=5 7=6 8=7 9=8 10=9
    NewPos = 3
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    FuelTotal#(7) = FuelTotal#(6): PlayerName$(7) = PlayerName$(6): PlayerScore&(7) = PlayerScore&(6): PlayerLevel(7) = PlayerLevel(6): PlayerSeconds&(7) = PlayerSeconds&(6): PS$(7) = PS$(6)
    FuelTotal#(6) = FuelTotal#(5): PlayerName$(6) = PlayerName$(5): PlayerScore&(6) = PlayerScore&(5): PlayerLevel(6) = PlayerLevel(5): PlayerSeconds&(6) = PlayerSeconds&(5): PS$(6) = PS$(5)
    FuelTotal#(5) = FuelTotal#(4): PlayerName$(5) = PlayerName$(4): PlayerScore&(5) = PlayerScore&(4): PlayerLevel(5) = PlayerLevel(4): PlayerSeconds&(5) = PlayerSeconds&(4): PS$(5) = PS$(4)
    FuelTotal#(4) = FuelTotal#(3): PlayerName$(4) = PlayerName$(3): PlayerScore&(4) = PlayerScore&(3): PlayerLevel(4) = PlayerLevel(3): PlayerSeconds&(4) = PlayerSeconds&(3): PS$(4) = PS$(3)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(3) = INT(FuelTotalUsed#): PlayerName$(3) = Phrase$: PlayerScore&(3) = score&: PlayerLevel(3) = RFileNr: PS$(3) = min$ + ":" + sec$: PlayerSeconds&(3) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(4) OR (score& = PlayerScore&(4) AND sec& < PlayerSeconds&(4)) OR (score& = PlayerScore&(4) AND sec& = PlayerSeconds&(4) AND FuelTotalUsed# < FuelTotal#(4)) THEN '                           Plek 4:  4=P 5=4 6=5 7=6 8=7 9=8 10=9
    NewPos = 4
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    FuelTotal#(7) = FuelTotal#(6): PlayerName$(7) = PlayerName$(6): PlayerScore&(7) = PlayerScore&(6): PlayerLevel(7) = PlayerLevel(6): PlayerSeconds&(7) = PlayerSeconds&(6): PS$(7) = PS$(6)
    FuelTotal#(6) = FuelTotal#(5): PlayerName$(6) = PlayerName$(5): PlayerScore&(6) = PlayerScore&(5): PlayerLevel(6) = PlayerLevel(5): PlayerSeconds&(6) = PlayerSeconds&(5): PS$(6) = PS$(5)
    FuelTotal#(5) = FuelTotal#(4): PlayerName$(5) = PlayerName$(4): PlayerScore&(5) = PlayerScore&(4): PlayerLevel(5) = PlayerLevel(4): PlayerSeconds&(5) = PlayerSeconds&(4): PS$(5) = PS$(4)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(4) = INT(FuelTotalUsed#): PlayerName$(4) = Phrase$: PlayerScore&(4) = score&: PlayerLevel(4) = RFileNr: PS$(4) = min$ + ":" + sec$: PlayerSeconds&(4) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(5) OR (score& = PlayerScore&(5) AND sec& < PlayerSeconds&(5)) OR (score& = PlayerScore&(5) AND sec& = PlayerSeconds&(5) AND FuelTotalUsed# < FuelTotal#(5)) THEN '                           Plek 5:  5=P 6=5 7=6 8=7 9=8 10=9
    NewPos = 5
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    FuelTotal#(7) = FuelTotal#(6): PlayerName$(7) = PlayerName$(6): PlayerScore&(7) = PlayerScore&(6): PlayerLevel(7) = PlayerLevel(6): PlayerSeconds&(7) = PlayerSeconds&(6): PS$(7) = PS$(6)
    FuelTotal#(6) = FuelTotal#(5): PlayerName$(6) = PlayerName$(5): PlayerScore&(6) = PlayerScore&(5): PlayerLevel(6) = PlayerLevel(5): PlayerSeconds&(6) = PlayerSeconds&(5): PS$(6) = PS$(5)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(5) = INT(FuelTotalUsed#): PlayerName$(5) = Phrase$: PlayerScore&(5) = score&: PlayerLevel(5) = RFileNr: PS$(5) = min$ + ":" + sec$: PlayerSeconds&(5) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(6) OR (score& = PlayerScore&(6) AND sec& < PlayerSeconds&(6)) OR (score& = PlayerScore&(6) AND sec& = PlayerSeconds&(6) AND FuelTotalUsed# < FuelTotal#(6)) THEN '                           Plek 6:  6=P 7=6 8=7 9=8 10=9
    NewPos = 6
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    FuelTotal#(7) = FuelTotal#(6): PlayerName$(7) = PlayerName$(6): PlayerScore&(7) = PlayerScore&(6): PlayerLevel(7) = PlayerLevel(6): PlayerSeconds&(7) = PlayerSeconds&(6): PS$(7) = PS$(6)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(6) = INT(FuelTotalUsed#): PlayerName$(6) = Phrase$: PlayerScore&(6) = score&: PlayerLevel(6) = RFileNr: PS$(6) = min$ + ":" + sec$: PlayerSeconds&(6) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(7) OR (score& = PlayerScore&(7) AND sec& < PlayerSeconds&(7)) OR (score& = PlayerScore&(7) AND sec& = PlayerSeconds&(7) AND FuelTotalUsed# < FuelTotal#(7)) THEN '                           Plek 7:  7=P 8=7 9=8 10=9
    NewPos = 7
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    FuelTotal#(8) = FuelTotal#(7): PlayerName$(8) = PlayerName$(7): PlayerScore&(8) = PlayerScore&(7): PlayerLevel(8) = PlayerLevel(7): PlayerSeconds&(8) = PlayerSeconds&(7): PS$(8) = PS$(7)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(7) = INT(FuelTotalUsed#): PlayerName$(7) = Phrase$: PlayerScore&(7) = score&: PlayerLevel(7) = RFileNr: PS$(7) = min$ + ":" + sec$: PlayerSeconds&(7) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(8) OR (score& = PlayerScore&(8) AND sec& < PlayerSeconds&(8)) OR (score& = PlayerScore&(8) AND sec& = PlayerSeconds&(8) AND FuelTotalUsed# < FuelTotal#(8)) THEN '                           Plek 8:  8=P 9=8 10=9
    NewPos = 8
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    FuelTotal#(9) = FuelTotal#(8): PlayerName$(9) = PlayerName$(8): PlayerScore&(9) = PlayerScore&(8): PlayerLevel(9) = PlayerLevel(8): PlayerSeconds&(9) = PlayerSeconds&(8): PS$(9) = PS$(8)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(8) = INT(FuelTotalUsed#): PlayerName$(8) = Phrase$: PlayerScore&(8) = score&: PlayerLevel(8) = RFileNr: PS$(8) = min$ + ":" + sec$: PlayerSeconds&(8) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(9) OR (score& = PlayerScore&(9) AND sec& < PlayerSeconds&(9)) OR (score& = PlayerScore&(9) AND sec& = PlayerSeconds&(9) AND FuelTotalUsed# < FuelTotal#(9)) THEN '                           Plek 9:  9=P 10=9
    NewPos = 9
    FuelTotal#(10) = FuelTotal#(9): PlayerName$(10) = PlayerName$(9): PlayerScore&(10) = PlayerScore&(9): PlayerLevel(10) = PlayerLevel(9): PlayerSeconds&(10) = PlayerSeconds&(9): PS$(10) = PS$(9)
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(9) = INT(FuelTotalUsed#): PlayerName$(9) = Phrase$: PlayerScore&(9) = score&: PlayerLevel(9) = RFileNr: PS$(9) = min$ + ":" + sec$: PlayerSeconds&(9) = sec&
    GOTO InvoegenKlaar
END IF
IF score& > PlayerScore&(10) OR (score& = PlayerScore&(10) AND sec& < PlayerSeconds&(10)) OR (score& = PlayerScore&(10) AND sec& = PlayerSeconds&(10) AND FuelTotalUsed# < FuelTotal#(10)) THEN '                          Plek10:  10=P
    NewPos = 10
    x = 238: y = 150 + (NewPos - 1) * 20: MaxLength = 12: GOSUB TekenLijst
    LINE (x, y)-(584, y + 7), 170, BF

    dy = 150 + (NewPos - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(NewPos)): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(score&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(RFileNr)): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotalUsed#))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = min$ + ":" + sec$: GOSUB PlaatsTekstLinksUitlijn

    GOSUB invoer
    FuelTotal#(10) = INT(FuelTotalUsed#): PlayerName$(10) = Phrase$: PlayerScore&(10) = score&: PlayerLevel(10) = RFileNr: PS$(10) = min$ + ":" + sec$: PlayerSeconds&(10) = sec&
    GOTO InvoegenKlaar
END IF

InvoegenKlaar:
CURHISCO = NewPos
'  Palette 0,0
'IF CURHISCO = 0 THEN CURHISCO = 10
OPEN "..\TXTFiles\CURHISCO.TXT" FOR OUTPUT AS #19
PRINT #19, CURHISCO
CLOSE #19
'
SELECT CASE NewPos
    CASE 0
        OPEN "..\TXTFiles\LOCKS00.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 1
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"
        NAME "..\TXTFiles\BB06.TXT" AS "..\TXTFiles\BB07.TXT"
        NAME "..\TXTFiles\BB05.TXT" AS "..\TXTFiles\BB06.TXT"
        NAME "..\TXTFiles\BB04.TXT" AS "..\TXTFiles\BB05.TXT"
        NAME "..\TXTFiles\BB03.TXT" AS "..\TXTFiles\BB04.TXT"
        NAME "..\TXTFiles\BB02.TXT" AS "..\TXTFiles\BB03.TXT"
        NAME "..\TXTFiles\BB01.TXT" AS "..\TXTFiles\BB02.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB01.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"
        NAME "..\TXTFiles\LOCKS06.TXT" AS "..\TXTFiles\LOCKS07.TXT"
        NAME "..\TXTFiles\LOCKS05.TXT" AS "..\TXTFiles\LOCKS06.TXT"
        NAME "..\TXTFiles\LOCKS04.TXT" AS "..\TXTFiles\LOCKS05.TXT"
        NAME "..\TXTFiles\LOCKS03.TXT" AS "..\TXTFiles\LOCKS04.TXT"
        NAME "..\TXTFiles\LOCKS02.TXT" AS "..\TXTFiles\LOCKS03.TXT"
        NAME "..\TXTFiles\LOCKS01.TXT" AS "..\TXTFiles\LOCKS02.TXT"

        OPEN "..\TXTFiles\LOCKS01.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 2
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"
        NAME "..\TXTFiles\BB06.TXT" AS "..\TXTFiles\BB07.TXT"
        NAME "..\TXTFiles\BB05.TXT" AS "..\TXTFiles\BB06.TXT"
        NAME "..\TXTFiles\BB04.TXT" AS "..\TXTFiles\BB05.TXT"
        NAME "..\TXTFiles\BB03.TXT" AS "..\TXTFiles\BB04.TXT"
        NAME "..\TXTFiles\BB02.TXT" AS "..\TXTFiles\BB03.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB02.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"
        NAME "..\TXTFiles\LOCKS06.TXT" AS "..\TXTFiles\LOCKS07.TXT"
        NAME "..\TXTFiles\LOCKS05.TXT" AS "..\TXTFiles\LOCKS06.TXT"
        NAME "..\TXTFiles\LOCKS04.TXT" AS "..\TXTFiles\LOCKS05.TXT"
        NAME "..\TXTFiles\LOCKS03.TXT" AS "..\TXTFiles\LOCKS04.TXT"
        NAME "..\TXTFiles\LOCKS02.TXT" AS "..\TXTFiles\LOCKS03.TXT"

        OPEN "..\TXTFiles\LOCKS02.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 3
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"
        NAME "..\TXTFiles\BB06.TXT" AS "..\TXTFiles\BB07.TXT"
        NAME "..\TXTFiles\BB05.TXT" AS "..\TXTFiles\BB06.TXT"
        NAME "..\TXTFiles\BB04.TXT" AS "..\TXTFiles\BB05.TXT"
        NAME "..\TXTFiles\BB03.TXT" AS "..\TXTFiles\BB04.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB03.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"
        NAME "..\TXTFiles\LOCKS06.TXT" AS "..\TXTFiles\LOCKS07.TXT"
        NAME "..\TXTFiles\LOCKS05.TXT" AS "..\TXTFiles\LOCKS06.TXT"
        NAME "..\TXTFiles\LOCKS04.TXT" AS "..\TXTFiles\LOCKS05.TXT"
        NAME "..\TXTFiles\LOCKS03.TXT" AS "..\TXTFiles\LOCKS04.TXT"

        OPEN "..\TXTFiles\LOCKS03.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 4
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"
        NAME "..\TXTFiles\BB06.TXT" AS "..\TXTFiles\BB07.TXT"
        NAME "..\TXTFiles\BB05.TXT" AS "..\TXTFiles\BB06.TXT"
        NAME "..\TXTFiles\BB04.TXT" AS "..\TXTFiles\BB05.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB04.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"
        NAME "..\TXTFiles\LOCKS06.TXT" AS "..\TXTFiles\LOCKS07.TXT"
        NAME "..\TXTFiles\LOCKS05.TXT" AS "..\TXTFiles\LOCKS06.TXT"
        NAME "..\TXTFiles\LOCKS04.TXT" AS "..\TXTFiles\LOCKS05.TXT"

        OPEN "..\TXTFiles\LOCKS04.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 5
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"
        NAME "..\TXTFiles\BB06.TXT" AS "..\TXTFiles\BB07.TXT"
        NAME "..\TXTFiles\BB05.TXT" AS "..\TXTFiles\BB06.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB05.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"
        NAME "..\TXTFiles\LOCKS06.TXT" AS "..\TXTFiles\LOCKS07.TXT"
        NAME "..\TXTFiles\LOCKS05.TXT" AS "..\TXTFiles\LOCKS06.TXT"

        OPEN "..\TXTFiles\LOCKS05.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 6
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"
        NAME "..\TXTFiles\BB06.TXT" AS "..\TXTFiles\BB07.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB06.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"
        NAME "..\TXTFiles\LOCKS06.TXT" AS "..\TXTFiles\LOCKS07.TXT"

        OPEN "..\TXTFiles\LOCKS06.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 7
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"
        NAME "..\TXTFiles\BB07.TXT" AS "..\TXTFiles\BB08.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB07.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"
        NAME "..\TXTFiles\LOCKS07.TXT" AS "..\TXTFiles\LOCKS08.TXT"

        OPEN "..\TXTFiles\LOCKS07.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 8
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB08.TXT" AS "..\TXTFiles\BB09.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB08.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS08.TXT" AS "..\TXTFiles\LOCKS09.TXT"

        OPEN "..\TXTFiles\LOCKS08.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 9
        KILL "..\TXTFiles\BB10.TXT"
        NAME "..\TXTFiles\BB09.TXT" AS "..\TXTFiles\BB10.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB09.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"
        NAME "..\TXTFiles\LOCKS09.TXT" AS "..\TXTFiles\LOCKS10.TXT"

        OPEN "..\TXTFiles\LOCKS09.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
    CASE 10
        KILL "..\TXTFiles\BB10.TXT"

        OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #9
        OPEN "..\TXTFiles\BB10.TXT" FOR OUTPUT AS #8
        WHILE NOT EOF(9)
            INPUT #9, n, x#, y#, z#, fuel#, ammo, heading, snelheid
            PRINT #8, n, x#, y#, z#, fuel#, ammo, heading, snelheid
        WEND
        CLOSE #8
        CLOSE #9

        KILL "..\TXTFiles\LOCKS10.TXT"

        OPEN "..\TXTFiles\LOCKS10.TXT" FOR OUTPUT AS #1 '
        PRINT #1, LLock(1) 'SUPPLY TRUCK
        PRINT #1, LLock(2) 'SPORTSCAR
        PRINT #1, LLock(3) 'JEEP
        PRINT #1, LLock(4) 'TANK
        PRINT #1, LLock(5) 'TREE
        PRINT #1, LLock(6) 'SHED
        PRINT #1, LLock(7) 'HEAP
        CLOSE #1
END SELECT

PLAY "v" + Pct$ + "MBl32o5a"
OPEN "..\TXTFiles\SCORES.TXT" FOR OUTPUT AS #1
FOR k = 1 TO 10
    PRINT #1, k
    PRINT #1, PlayerName$(k)
    PRINT #1, PlayerScore&(k)
    PRINT #1, PlayerLevel(k)
    PRINT #1, FuelTotal#(k)
    PRINT #1, PlayerSeconds&(k)
NEXT
CLOSE #1

CLOSE #7
_DISPLAY
GOSUB systeemeinde2
'
OPEN "..\TXTFiles\TCOCKPIT.TXT" FOR OUTPUT AS #1
PRINT #1, TotalCockpitTime&
CLOSE #1
OPEN "..\TXTFiles\CONTROL.TXT" FOR OUTPUT AS #1
PRINT #1, controller$
CLOSE #1


CHAIN "Menu.exe"

' ******************************************************

invoer:
LINE (x - 2, y - 2)-(x + 7 * MaxLength, y + 8), 9, B

_DISPLAY
BCteller& = 0
TellerSpeed = 2
BoxColor = 9
Phrase$ = ""

DO
    _LIMIT OverallFramerate
    BCteller& = BCteller& + TellerSpeed
    IF BCteller& > 63 THEN TellerSpeed = -2: BCteller& = 63
    IF BCteller& < 0 THEN TellerSpeed = 2: BCteller& = 0
    PALETTE 9, 0 + 256 * BCteller& + 0
    _DISPLAY

    i$ = ""

    WHILE i$ = "" OR i$ = CHR$(27): i$ = UCASE$(RIGHT$(INKEY$, 1))

        _LIMIT OverallFramerate
        BCteller& = BCteller& + TellerSpeed
        IF BCteller& > 63 THEN TellerSpeed = -2: BCteller& = 63
        IF BCteller& < 0 THEN TellerSpeed = 2: BCteller& = 0
        PALETTE 9, 0 + 256 * BCteller& + 0
        _DISPLAY

    WEND

    SELECT CASE ASC(i$)
        CASE 13: PLAY "v" + Pct$ + "l64a": LINE (x - 1, y - 1)-(x + 7 * MaxLength - 1, y + 7), 0, B: PALETTE 9, 65536 * 0 + 256 * 31 + 0: RETURN
        CASE 27 '                                         ESC
            Phrase$ = ""
            LINE (x - 1, y - 1)-(x + 7 * MaxLength - 1, y + 7), 19, BF:
            dx = x: dy = y: waarde$ = SPACE$(MaxLength): GOSUB PlaatsTekstLinksUitlijnInvoer
        CASE 8 '                                          BACKSPACE
            IF LEN(Phrase$) > 0 THEN
                PLAY "v" + Pct$ + "l64a"
                Phrase$ = LEFT$(Phrase$, LEN(Phrase$) - 1)
                LINE (x - 1, y - 1)-(x + 7 * MaxLength - 1, y + 7), 19, BF:
                dx = x + 7 * LEN(Phrase$): dy = y: waarde$ = " ": GOSUB PlaatsTekstLinksUitlijnInvoer
            END IF
    END SELECT
    IF ASC(i$) <> 8 AND ASC(i$) <> 44 AND LEN(Phrase$) < MaxLength THEN LINE (x - 1, y - 1)-(x + 7 * MaxLength - 1, y + 7), 19, BF: Phrase$ = Phrase$ + i$: PLAY "v" + Pct$ + "l64a" '
    dx = x: dy = y: waarde$ = Phrase$: GOSUB PlaatsTekstLinksUitlijnInvoer
    _DISPLAY
LOOP
LINE (x - 1, y - 1)-(x + 7 * MaxLength - 1, y + 7), 0, B
PALETTE 9, 65536 * 0 + 256 * 31 + 0 '  HighScoreBox Groen
'
PALETTE 14, 256 * 31

RETURN

TekenLijst:
'******************************************************
x1 = 205: y1 = 75: x2 = 593: y2 = 359
LINE (x1 + 3, y1 + 3)-(x2 - 3, y2 - 3), 3, BF: GOSUB TekenBlok
x1 = 210: y1 = 80: x2 = 588: y2 = 354
LINE (x1 + 3, y1 + 3)-(x2 - 3, y2 - 3), 18, BF: GOSUB TekenGat '


dx = 400: dy = 98: waarde$ = "--- HALL OF FAME ---": GOSUB PlaatsTekstCentered
dx = 400: dy = 120: waarde$ = "-----------------------------------------------------": GOSUB PlaatsTekstCentered
dx = 400: dy = 130: waarde$ = "      PILOT:      SCORE:    LEVEL:    FUEL:    TIME: ": GOSUB PlaatsTekstCentered '
dx = 400: dy = 140: waarde$ = "-----------------------------------------------------": GOSUB PlaatsTekstCentered
FOR Position = 1 TO 10
    dy = 150 + (Position - 1) * 20
    dx = 220: waarde$ = LTRIM$(STR$(Position)): GOSUB PlaatsTekstLinksUitlijn
    dx = 238: waarde$ = PlayerName$(Position): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(PlayerScore&(Position)))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 337: GOSUB PlaatsTekstLinksUitlijn
    dx = 425: waarde$ = LTRIM$(STR$(PlayerLevel(Position))): GOSUB PlaatsTekstCentered
    dx = 488: waarde$ = LTRIM$(STR$(INT(FuelTotal#(Position)))): GOSUB PlaatsTekstCentered
    dx = 540: waarde$ = PS$(Position): GOSUB PlaatsTekstLinksUitlijn
NEXT
dx = 400: dy = 340: waarde$ = "-----------------------------------------------------": GOSUB PlaatsTekstCentered
RETURN



'
PlaatsTekstCentered:
IF LEFT$(waarde$, 1) = " " THEN waarde$ = RIGHT$(waarde$, LEN(waarde$) - 1)
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx - LEN(waarde$) * 3.5
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + (strp - 1) * 7, dy), v(nch * grootte), _CLIP OR
NEXT
waarde$ = ""
RETURN

PlaatsTekstLinksUitlijn:
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (dx + (strp - 1) * 7, dy), v(nch * grootte), _CLIP OR
NEXT
waarde$ = ""
RETURN

PlaatsTekstLinksUitlijnInvoer: '

FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (dx + (strp - 1) * 7, dy), v(nch * grootte), _CLIP OR
NEXT
waarde$ = ""
RETURN




LoadRescues:
'
'
'    DAY:   1,3,6,7
'  NIGHT:   2,4,5,8,9
'
'
'
'
'
'
'
RFileNr = RFileNr + 1

IF RFileNr = 10 GOTO Uitgespeeld
'
IF RFileNr = 1 OR RFileNr = 3 OR RFileNr = 6 OR RFileNr = 7 THEN
    DayNight$ = "DAY"
    PALETTE 0, 65536 * 0 + 256 * 7 + 15 ' d-bruin      '
ELSE
    DayNight$ = "NIGHT"
    PALETTE 0, 65536 * 0 + 256 * 0 + 0 '   zwart
END IF

PlusTime& = AllowedSec& - resec&
OPEN "..\TXTFiles\LEVEL" + LTRIM$(STR$(RFileNr)) + ".TXT" FOR INPUT AS #5
INPUT #5, test$
INPUT #5, AllowedSec&
INPUT #5, waypoints
ToBeRescued = waypoints
FOR waypoint = 0 TO waypoints
    INPUT #5, xwp#(waypoint)
    INPUT #5, ywp#(waypoint)
    INPUT #5, zwp#(waypoint)
    INPUT #5, txt$(waypoint)
NEXT
INPUT #5, test$
CLOSE #5
waypoint = 0

AllowedSec& = AllowedSec& + PlusTime&
resec& = 0
RETURN

Uitgespeeld:
TIMER OFF
IF secbooks& < 1 THEN
    secbooks& = 1
    PRINT #1, dummy&, xc0#, yc0#, zc0#, fuel#, ammo, heading, snelheid
END IF


CLOSE #1 'QWEQWE
_MOUSESHOW
x1 = 255: y1 = 115: x2 = 544: y2 = 319: GOSUB TekenBlok
x1 = 260: y1 = 120: x2 = 539: y2 = 314: GOSUB TekenGat
waarde$ = "- THE END -": dx = 400: dy = 130: GOSUB PlaatsTekstCentered
waarde$ = "---------------------------------------": dx = 400: dy = 140: GOSUB PlaatsTekstCentered
waarde$ = Exit$: dx = 400: dy = 170: GOSUB PlaatsTekstCentered
w1$ = LTRIM$(STR$(score&))
WHILE LEN(w1$) < 6: w1$ = "0" + w1$: WEND
waarde$ = "SCORE: " + w1$: dx = 400: dy = 190: GOSUB PlaatsTekstCentered
waarde$ = "YOU HAVE REACHED LEVEL " + LTRIM$(STR$(RFileNr)): dx = 400: dy = 210: GOSUB PlaatsTekstCentered
min$ = LTRIM$(STR$(sec& \ 60))
sec$ = LTRIM$(STR$(sec& MOD 60))
WHILE LEN(min$) < 2: min$ = "0" + min$: WEND
WHILE LEN(sec$) < 2: sec$ = "0" + sec$: WEND
waarde$ = "TIME: " + min$ + ":" + sec$: dx = 400: dy = 230: GOSUB PlaatsTekstCentered
waarde$ = "FUEL: " + LTRIM$(STR$(INT(FuelTotalUsed#))): dx = 400: dy = 250: GOSUB PlaatsTekstCentered
waarde$ = "CLICK HERE": dx = 400: dy = 280: GOSUB PlaatsTekstCentered
'Line (356, 276)-(443, 290), 9, B
_DISPLAY
_DELAY .2
WHILE INKEY$ <> ""
WEND
_DELAY .2
WHILE INKEY$ = ""
    _LIMIT OverallFramerate
    Mouse 3
    ' If BMuis = 1 And VMuis >= 276 And VMuis <= 290 And HMuis >= 356 And HMuis <= 443 Then Line (356, 276)-(443, 290), 15, B: _Display: GoTo ExitMenu
    IF BMuis = 1 AND VMuis >= 276 AND VMuis <= 290 AND HMuis >= 356 AND HMuis <= 443 THEN _DISPLAY: GOTO ExitMenu
WEND
GOTO ExitMenu
'
systeemeinde2:
_AUTODISPLAY
PALETTE 0, 0
TIMER OFF
dikte = 8
LINE (400 - dikte, 0)-(400 + dikte, 449), 0, BF
FOR k = 1 TO 50
    _LIMIT 10 * OverallFramerate
    GET (400, 0)-(799 - dikte, 449), bulk1(0)
    GET (dikte, 0)-(399, 449), bulk2(0)
    PUT (0, 0), bulk2(0), PSET
    PUT (400 + dikte, 0), bulk1(0), PSET
    LINE (399 - (k - 1) * dikte, 0)-(399 - (k - 1) * dikte, 449), 0
    LINE (400 + (k - 1) * dikte, 0)-(400 + (k - 1) * dikte, 449), 0
    _DISPLAY
NEXT
RETURN

vink:
DATA 000000011
DATA 000000110
DATA 000000110
DATA 110001100
DATA 011001100
DATA 001111000
DATA 000110000
DATA 000010000

roos:
DATA 00000000000000000000000001000010000000000000000000000000
DATA 00000000000000000000000001100010000000000000000000000000
DATA 00000000000000000000000001010010000000000000000000000000
DATA 00000000000000000000000001001010000000000000000000000000
DATA 00000000000000000000000001000110000000000000000000000000
DATA 00000000000000000000000001000010000000000000000000000000
DATA 00000000000000000000000001000010000000000000000000000000
DATA 00000000000000000000000000000000000000000000000000000000
DATA 00000000000000000000000000011000000000000000000000000000
DATA 00000000000000000000000000011000000000000000000000000000
DATA 00000000000000000000000000011000000000000000000000000000
DATA 00000000000000000000000000110100000000000000000000000000
DATA 00000000000000000000000000110100000000000000000000000000
DATA 00000000000000000000000000110100000000000000000000000000
DATA 00000000000000000000000001110010000000000000000000000000
DATA 00000000000000000000000001110010000000000000000000000000
DATA 00000000000000001110000001110010000001110000000000000000
DATA 00000000000000001101110011110001001111110000000000000000
DATA 00000000000000001110001111110001111111010000000000000000
DATA 00000000000000000111000011110001111110100000000000000000
DATA 00000000000000000111100111110000111100100000000000000000
DATA 00000000000000000111110111110000111000100000000000000000
DATA 00000000000000000011111111110000110001000000000000000000
DATA 00000000000000000011111111110000111101000000000000000000
DATA 00000000000000000111000011110001111111100000000000000000
DATA 01000010000000111000000001110011111111111100000001111110
DATA 01000010000111000000000000110111111111111111100001000000
DATA 01000010111000000000000000011111111111111111111101000000
DATA 01000010111111111111111111111000000000000000011101111000
DATA 01011010000111111111111111101100000000000011100001000000
DATA 01011010000000111111111111001110000000011100000001000000
DATA 01100110000000000111111110001111000011100000000001111110
DATA 00000000000000000010111100001111111111000000000000000000
DATA 00000000000000000010001100001111111111000000000000000000
DATA 00000000000000000100011100001111101111100000000000000000
DATA 00000000000000000100111100001111100111100000000000000000
DATA 00000000000000000101111110001111000011100000000000000000
DATA 00000000000000001011111110001111110001110000000000000000
DATA 00000000000000001111110010001111001110110000000000000000
DATA 00000000000000001110000001001110000001110000000000000000
DATA 00000000000000000000000001001110000000000000000000000000
DATA 00000000000000000000000001001110000000000000000000000000
DATA 00000000000000000000000000101100000000000000000000000000
DATA 00000000000000000000000000101100000000000000000000000000
DATA 00000000000000000000000000101100000000000000000000000000
DATA 00000000000000000000000000011000000000000000000000000000
DATA 00000000000000000000000000011000000000000000000000000000
DATA 00000000000000000000000000011000000000000000000000000000
DATA 00000000000000000000000000000000000000000000000000000000
DATA 00000000000000000000000000111100000000000000000000000000
DATA 00000000000000000000000001000010000000000000000000000000
DATA 00000000000000000000000001000000000000000000000000000000
DATA 00000000000000000000000000111100000000000000000000000000
DATA 00000000000000000000000000000010000000000000000000000000
DATA 00000000000000000000000001000010000000000000000000000000
DATA 00000000000000000000000000111100000000000000000000000000
MuxerData:
DATA 010000000000000000
DATA 110000100001100011
DATA 010001000000110110
DATA 111010000000011100
DATA 000101000000011100
DATA 001001010000110110
DATA 010001111001100011
DATA 000000010000000000

DATA 010000000000000000
DATA 110000100001100011
DATA 010001000000110110
DATA 111010000000011100
DATA 000101100000011100
DATA 001000010000110110
DATA 010000100001100011
DATA 000001110000000000

DATA 000011000000000000
DATA 000111000001100011
DATA 000011000000110110
DATA 000011000000011100
DATA 000011000000011100
DATA 000011000000110110
DATA 000011000001100011
DATA 000111100000000000

DATA 000111110000000000
DATA 001100011001100011
DATA 000000011000110110
DATA 000011110000011100
DATA 000110000000011100
DATA 001100000000110110
DATA 001100000001100011
DATA 001111111000000000

DATA 001100000000000000
DATA 001100000001100011
DATA 001100000000110110
DATA 001100110000011100
DATA 001111111000011100
DATA 000000110000110110
DATA 000000110001100011
DATA 000000110000000000

'
rec:
DATA 011000011101110011
DATA 111100010001100100
DATA 011000010001110011

moondata: '
DATA .....befebo.....
DATA ...bifeaabeep...
DATA ..aeeaaefeaafo..
DATA .ghehjhaehhefeq.
DATA .ahhjjheejhheeg.
DATA ghehhhhaehhjgeak
DATA bjbbeeebbbagjhbl
DATA ejheafabenfbaagm
DATA nhhaaeeeenncefhg
DATA eahhaaeefnncfael
DATA gnaabaaannnnnfnk
DATA .dnfbeahfccnnnn.
DATA .rdcaefndccnnnp.
DATA ..ecnnncdccncg..
DATA ...gcnccdccco...
DATA .....gefneg.....


'               121 breed        34 hoog
PauseData:
DATA 0000000000000000000000000000000000000000000000000000000000000000000000000000000000012345546780000000000000000000000000000
DATA 09abbbbbbbbcade00000000000000fgbbbgf000000000000hijbkl800000000000006kbcmh00000008nbopqrrqstkn80000000uvbbbbbbbbbbbbbbju0
DATA wxyzzzzzzzzArptjeh0000000000hdszzzyB0000000000008CyzAkD0000000000000brzAEw000000DgoAzzzzzzzzAF51000000Gyzzzzzzzzzzzzzzqn0
DATA 1HrzzzzzzzzzzzzqI3D0000000001JAzzzzbK000000000008vqzALD0000000000000MAzzg1000008gszzzrNoOsrzzzPQ0000005rzzzzzzzzzzzzzzrB0
DATA 1HrzzFRSSSIOqzzzAo6800000000iOzzzzzNu000000000008vqzALD0000000000000MAzzg100000TOzzzovlUU35JyzOm0000005rzzFRSSSSSSSSSSLu0
DATA 1HrzAkQeee9mlSrzzzRu00000000aqzrpAzzEw00000000008vqzALD0000000000000MAzzg100001HAzzVBwh0hhhWTIR90000005rzzc9eeeeeeeeeeXh0
DATA 1HrzAx10000009brzzrY8000000DZzzoHyzzZf00000000008vqzALD0000000000000MAzzg10000iozzqYh0000000hWW80000005rzzx80000000000000
DATA 1HrzAx1000000hmPzzz!X0000003szzxiozzpUh0000000008vqzALD0000000000000MAzzg100006szzFi0000000000000000005rzzx80000000000000
DATA 1HrzAx10000000h@rzzFu00000hcAzyBDHAzAa10000000008vqzALD0000000000000MAzzg10000YpzzOm0000000000000000005rzzx80000000000000
DATA 1HrzAx100000000Eqzzsu00000QPzzZuh3pzzRe0000000008vqzALD0000000000000MAzzg10000YyzzNi0000000000000000005rzzx80000000000000
DATA 1HrzAx1000000005yzzsu00000YpzAvw07Vzzs6h000000008vqzALD0000000000000MAzzg10000TNzzAx1000000000000000005rzzx80000000000000
DATA 1HrzAx100000000CqzzNu0000KcAzNlh0XbAzAxw000000008vqzALD0000000000000MAzzg10000uIzzzsGK00000000000000005rzzx80000000000000
DATA 1HrzAx10000000wLAzzPW00007tzzRe000dyzzI9000000008vqzALD0000000000000MAzzg10000hCqzzzFj7h000000000000005rzzx80000000000000
DATA 1HrzAx10000000Uozzzv1000hdpzAj10007tzzqn000000008vqzALD0000000000000MAzzg100000XSAzzzqPxe00000000000005rzzHnUUUUUUUUiD000
DATA 1HrzAx100000huHAzzsU00001MAzyBh0008LAzzkK00000008vqzALD0000000000000MAzzg10000009SrzzzzqPCe800000000005rzzqNFFFFFFFFOCw00
DATA 1HrzA@uXXXeQlSqzzr@K00009ozzPW00000dyzzNQ00000008vqzALD0000000000000MAzzg100000007bpzzzzzyI59h000000005rzzzzzzzzzzzzALD00
DATA 1HrzzoMHHH!tsAzzAJmh0000vqzzx100000Wtzzzdw0000008vqzALD0000000000000MAzzg10000000heGRqzzzzAySl100000005rzzzzzzzzzzzzA@100
DATA 1HrzzzAAAAAzzzzAJ7h0000wRzzyih000000crzzRX0000008vqzALD0000000000000MAzzg1000000000huGPAzzzzAoY80000005rzzJ6llllllllT9h00
DATA 1HrzzzzzzzzzAytdWh000006szzSf0000000nNzzpUh000008vqzALD0000000000000MAzzg1000000000008WEtrzzzzOU0000005rzzx80000000000000
DATA 1HrzzFR!!!Jba3ew0000008cAzAd80000000KZAzAx1000008vqzALD0000000000000MAzzg10000000000000wevoAzzzSf000005rzzx80000000000000
DATA 1HrzA@WKKKDD1800000000QPzzrLE5555555gVAzzSe000008vqzALD0000000000000MAzzg1000000000000000DlPzzzqT800005rzzx80000000000000
DATA 1HrzAx1000000000000000YpzzzArrrrrrrrrzzzzN6h00008vqzALD0000000000000MAzzg100000000000000008GpzzzkK00005rzzx80000000000000
DATA 1HrzAx100000000000000KkAzzzzzzzzzzzzzzzzzAv800008gqzzMD0000000000000!AzzCw000000000000000001RzzzRX00005rzzx80000000000000
DATA 1HrzAx1000000000000007tzzqIS!!!!!!!!!!oAzzI900000lpzzIu0000000000001PzzAi0000000000000000000MAzzPf00005rzzx80000000000000
DATA 1HrzAx10000000000000hdpzzR7KKKKKKKKKKKYszzqT00000iFzzNlh00000000000BNzzp90000000000000000000MAzzSX00005rzzx80000000000000
DATA 1HrzAx100000000000001MAzAj100000000000fRzzzkD00009ZzzAjD00000000008cAzzRf000000000000000000wZzzzkD00005rzzx80000000000000
DATA 1HrzAx100000000000009ozzp2h000000000000arzzN90000wxrzzFnh00000000hTOzzr3h0000W@jeh00000000hYpzzAl800005rzzx80000000000000
DATA 1HrzAx10000000000000vqzzZf0000000000000nFzzz4w0000UozzztTK0000001TIAzzSu000007VqR6Wh00000wUZAzzIe000005rzz@WXXXXXXXXXXKh0
DATA 1HrzAx10000000000001RzzzCw00000000000008!AzzRX0000wgyzzAFkY2QQ23aVAzzOl8000007tzANJ5TmQ7TgtrzzsY8000005rzzoHHHHHHHHHHHc90
DATA 1HrzAx1000000000000lszzp7000000000000000gyzzs2h0000XkrzzzApoPPoprzzzyED000000XLAzzAqNVPtNqzzzqxK0000005rzzzAAAAAAAAAAAAEw
DATA 1Hrzrx1000000000000jAzzSf000000000000000eVzzrv100000fgFAzzzzzzzzzzro3D0000000h7MyzzzzzzzzzzANvf00000004qzzzzzzzzzzzzzzzCw
DATA 8GH!HB8000000000000GJ!MB800000000000000085M!JYw0000001BktprzzzAqsZx78000000000hKdHVyrzzzryVbTK000000007c!!!!!!!!!!!!!!Ji0
DATA 0wDKD80000000000000wDKD800000000000000000wDKDw000000008DiYEvxxg5391h000000000000wX2GEvxxEGiK8000000000h1KKKKKKKKKKKKKKDh0
DATA 000000000000000000000000000000000000000000000000000000000hh888hhh000000000000000000hh888hh0000000000000000000000000000000




Set2:

'        (32 - 38) SPC-&
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
'
DATA 001100
DATA 011110
DATA 011110
DATA 001100
DATA 001100
DATA 000000
DATA 001100

DATA 010100
DATA 010100
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

DATA 011110
DATA 100001
DATA 101101
DATA 101001
DATA 101101
DATA 100001
DATA 011110

DATA 011110
DATA 101000
DATA 101000
DATA 011100
DATA 001010
DATA 001010
DATA 111100

DATA 110001
DATA 110011
DATA 000110
DATA 001100
DATA 011000
DATA 110011
DATA 100011

DATA 001000
DATA 010100
DATA 010100
DATA 001001
DATA 010110
DATA 100010
DATA 011101


'  ()    (40-41)
DATA 000110
DATA 001000
DATA 010000
DATA 010000
DATA 010000
DATA 001000
DATA 000110

DATA 011000
DATA 000100
DATA 000010
DATA 000010
DATA 000010
DATA 000100
DATA 011000

'  -     (43-47)

DATA 000000
DATA 001000
DATA 001000
DATA 111110
DATA 001000
DATA 001000
DATA 000000

DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000100
DATA 001000


DATA 000000
DATA 000000
DATA 000000
DATA 011110
DATA 000000
DATA 000000
DATA 000000

DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 001100
DATA 001100

DATA 000000
DATA 000001
DATA 000010
DATA 000100
DATA 001000
DATA 010000
DATA 100000
'  0 - : (48-58)
DATA 011110
DATA 100011
DATA 100101
DATA 100001
DATA 101001
DATA 110001
DATA 011110

DATA 000100
DATA 001100
DATA 000100
DATA 000100
DATA 000100
DATA 000100
DATA 001110

DATA 011110
DATA 100001
DATA 000001
DATA 001110
DATA 010000
DATA 100000
DATA 111111

DATA 011110
DATA 100001
DATA 000001
DATA 001110
DATA 000001
DATA 100001
DATA 011110

DATA 100000
DATA 100000
DATA 100100
DATA 111111
DATA 000100
DATA 000100
DATA 000100

DATA 111111
DATA 100000
DATA 111100
DATA 000010
DATA 000001
DATA 100001
DATA 011110

DATA 000110
DATA 001000
DATA 010000
DATA 111110
DATA 100001
DATA 100001
DATA 011110

DATA 111111
DATA 000001
DATA 000001
DATA 000110
DATA 001000
DATA 001000
DATA 001000

DATA 011110
DATA 100001
DATA 100001
DATA 011110
DATA 100001
DATA 100001
DATA 011110

DATA 011110
DATA 100001
DATA 100001
DATA 011111
DATA 000010
DATA 000100
DATA 001000

DATA 000000
DATA 001100
DATA 001100
DATA 000000
DATA 001100
DATA 001100
DATA 000000

'  @ - Z (64-90)
DATA 001110
DATA 110001
DATA 100101
DATA 101011
DATA 100111
DATA 110000
DATA 001111

DATA 001100
DATA 010010
DATA 100001
DATA 111111
DATA 100001
DATA 100001
DATA 100001

DATA 111110
DATA 100001
DATA 100001
DATA 111110
DATA 100001
DATA 100001
DATA 111110

DATA 011111
DATA 100000
DATA 100000
DATA 100000
DATA 100000
DATA 100000
DATA 011111

DATA 111110
DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 111110

DATA 111111
DATA 100000
DATA 100000
DATA 111100
DATA 100000
DATA 100000
DATA 111111

DATA 111111
DATA 100000
DATA 100000
DATA 111100
DATA 100000
DATA 100000
DATA 100000

DATA 011110
DATA 100001
DATA 100000
DATA 100110
DATA 100001
DATA 100001
DATA 011110

DATA 100001
DATA 100001
DATA 100001
DATA 111111
DATA 100001
DATA 100001
DATA 100001

DATA 011100
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 011100

DATA 111111
DATA 000001
DATA 000001
DATA 000001
DATA 100001
DATA 100001
DATA 011110

DATA 100001
DATA 100010
DATA 100100
DATA 111000
DATA 100100
DATA 100010
DATA 100001

DATA 100000
DATA 100000
DATA 100000
DATA 100000
DATA 100000
DATA 100000
DATA 111111

DATA 100001
DATA 110011
DATA 101101
DATA 100001
DATA 100001
DATA 100001
DATA 100001

DATA 100001
DATA 110001
DATA 101001
DATA 100101
DATA 100011
DATA 100001
DATA 100001

DATA 011110
DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 011110

DATA 111110
DATA 100001
DATA 100001
DATA 111110
DATA 100000
DATA 100000
DATA 100000

DATA 011110
DATA 100001
DATA 100001
DATA 100001
DATA 100101
DATA 100011
DATA 011111

DATA 111110
DATA 100001
DATA 100001
DATA 111110
DATA 100001
DATA 100001
DATA 100001

DATA 011110
DATA 100001
DATA 100000
DATA 011110
DATA 000001
DATA 100001
DATA 011110

DATA 111110
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000

DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 011110

DATA 100001
DATA 100001
DATA 100001
DATA 010010
DATA 010010
DATA 010010
DATA 001100

DATA 100001
DATA 100001
DATA 100001
DATA 100001
DATA 101101
DATA 110011
DATA 100001

DATA 100001
DATA 100001
DATA 010010
DATA 001100
DATA 010010
DATA 100001
DATA 100001

DATA 100010
DATA 100010
DATA 100010
DATA 010100
DATA 001000
DATA 001000
DATA 001000

DATA 111111
DATA 000001
DATA 000010
DATA 000100
DATA 001000
DATA 010000
DATA 111111

DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

DATA 000100
DATA 000100
DATA 001000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

'        "MOUSE" Sub-Routine Copyright 1999 by: Daryl R. Dubbs
SUB Mouse (Funk) STATIC '                   Define sub & parameter(s) passed.
    SHARED BMuis, HMuis, VMuis '                            Share variables with main sub.
    IF Funk = 1 THEN Crsr = 1 '                 Show Cursor.
    IF Funk = 2 AND Crsr = 0 THEN EXIT SUB '    Don't hide Cursor more than once.
    IF Funk = 2 AND Crsr = 1 THEN Crsr = 0 '    Hide Cursor.
    POKE 100, 184: POKE 101, Funk: POKE 102, 0 'Poke machine code necessary for
    POKE 103, 205: POKE 104, 51: POKE 105, 137 'using the mouse into memory
    POKE 106, 30: POKE 107, 170: POKE 108, 10 ' starting at offset 100 in the
    POKE 109, 137: POKE 110, 14: POKE 111, 187 'current segment.  This code is
    POKE 112, 11: POKE 113, 137: POKE 114, 22 ' then executed as a unit, via the
    POKE 115, 204: POKE 116, 12: POKE 117, 203 'statement " Call Absolute ".
    CALL ABSOLUTE(100) '                        Call machine code.
    BMuis = PEEK(&HAAA) '                           Get values for: Buttons
    HMuis = PEEK(&HBBB) + PEEK(&HBBC) * 256 '       Horizontal position ( 2 bytes )
    VMuis = PEEK(&HCCC) + PEEK(&HCCD) * 256 '       Vertical position ( 2 bytes )
END SUB '                                   End of sub-program.
