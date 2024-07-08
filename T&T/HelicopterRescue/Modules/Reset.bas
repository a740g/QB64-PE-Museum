'
'        Reset-File copyright 2023 Arnold Kramer T&T WARE
'
'        ver.20240707 1.6.19
'
'
'
$EXEICON:'./../Resources/HRExe.ico'
_TITLE "Helicopter Rescue - Reset"
DEFINT A-Z
DECLARE SUB Mouse (Funk)
grootte = 50

OPEN "..\TXTFiles\VOLUME.TXT" FOR INPUT AS #1
INPUT #1, Volume
CLOSE #1
Pct$ = LTRIM$(STR$(Volume))

Click& = _SNDOPEN("..\OGGFiles\" + "Click.ogg", "VOL,SYNC")
_SNDVOL Click&, Volume / 100
'

SCREEN _NEWIMAGE(640, 480, 256)

OPEN "..\TXTFiles\DISPLAYM.TXT" FOR INPUT AS #11
INPUT #11, screen$
CLOSE #11
IF screen$ = "FULLSCREEN" THEN full = 1
IF screen$ = "WINDOWED" THEN full = 0
IF full = 1 THEN
    _FULLSCREEN _SQUAREPIXELS , _SMOOTH
ELSE
    _FULLSCREEN _OFF
    _SCREENMOVE _MIDDLE
END IF


FOR altco = 0 TO 16: PALETTE altco, 0: NEXT
'ding...

REDIM bulk1(0 TO 100000)
REDIM bulk2(0 TO 100000)

REDIM v(0 TO 10000)
REDIM vwit(0 TO 10000)

REDIM w(0 TO 10000)
REDIM LedOn(0 TO 500)
REDIM LedOff(0 TO 500)

REDIM PlayerName$(1 TO 10)
REDIM PlayerScore&(1 TO 10)
REDIM PlayerLevel(1 TO 10)
REDIM PlayerSeconds&(1 TO 10)
REDIM cPxl(0 TO 374, 0 TO 290)

CONST pi# = 3.14159265358979323846264338327950288

PALETTE 0, 65536 * 0 + 256 * 0 + 0 '   zwart
PALETTE 1, 65536 * 12 + 256 * 12 + 12 '-
PALETTE 2, 65536 * 24 + 256 * 24 + 24 ' |
PALETTE 3, 65536 * 36 + 256 * 36 + 36 ' |grijstinten tot wit
PALETTE 4, 65536 * 48 + 256 * 48 + 48 ' |
PALETTE 5, 65536 * 63 + 256 * 63 + 63 '-
PALETTE 6, 65536 * 12 + 256 * 12 + 12 '  blauw
PALETTE 7, 65536 * 0 + 256 * 63 + 0 '  groen
PALETTE 8, 65536 * 0 + 256 * 0 + 63 '  rood
PALETTE 9, 65536 * 0 + 256 * 0 + 23 ' donker rood
PALETTE 10, 65536 * 0 + 256 * 50 + 55 '-
PALETTE 11, 65536 * 0 + 256 * 45 + 50 ' |vlamtinten
PALETTE 12, 65536 * 0 + 256 * 35 + 45 ' |
PALETTE 13, 65536 * 0 + 256 * 25 + 63 '-
PALETTE 14, 65536 * 0 + 256 * 15 + 0 '  donkergroen
PALETTE 15, 65536 * 0 + 256 * 63 + 0 'hoofdkleur
PALETTE 16, 65536 * 0 + 256 * 31 + 0 'mediumgroen
FOR grey = 100 TO 163
    PALETTE grey, 65536 * (grey - 100) + 256 * (grey - 100) + (grey - 100)
NEXT

OPEN "..\TXTFiles\" + "RECDEMO.TXT" FOR INPUT AS #1
INPUT #1, RecDemo$
CLOSE #1

b1 = 0: b2 = 0: b3 = 0: b4 = 0
IF UCASE$(RecDemo$) = "ON" THEN b5 = 1 ELSE b5 = 0

FOR grey = 100 TO 163
    PALETTE grey, 65536 * (grey - 100) + 256 * (grey - 100) + (grey - 100)
NEXT
PALETTE 32, 65536 * 0 + 256 * 0 + 0
FOR y = 0 TO 11
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "A": PSET (x, y), 9 '
            CASE "B": PSET (x, y), 3 '
            CASE "C": PSET (x, y), 8 '
            CASE ".": PSET (x, y), 3
            CASE ELSE: PSET (x, y), VAL(b$)
        END SELECT
    NEXT
NEXT
GET (0, 0)-(11, 11), LedOff(0)

FOR y = 0 TO 11
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "A": PSET (x, y), 9 '
            CASE "B": PSET (x, y), 16 '
            CASE "C": PSET (x, y), 8 '
            CASE ".": PSET (x, y), 3
            CASE ELSE: PSET (x, y), VAL(b$)
        END SELECT
    NEXT
NEXT
GET (0, 0)-(11, 11), LedOn(0)

GOSUB graphics

LINE (0, 0)-(639, 19), 0, BF
GOSUB TekenAchtergrond

waarde$ = "V1.6.19": dx = 2: dy = 2: GOSUB PlaatsTekstLinksUitlijnWit


waarde$ = "HELICOPTER RESCUE": dx = 327: dy = 417: GOSUB plaatstekstcentered

x1 = 198: y1 = 90: x2 = 442: y2 = 330: GOSUB TekenBlok
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF
x1 = 208: y1 = 100: x2 = 432: y2 = 120: GOSUB TekenGat
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF

dx = 320: dy = 107: waarde$ = "--- RESET .TXT FILES ---": GOSUB plaatstekstcentered


'
x1 = 208: y1 = 285: x2 = 316: y2 = 315: GOSUB TekenBlok
dx = 249: dy = 297: waarde$ = "OK": GOSUB PlaatsZwartOpGrijs

x1 = 324: y1 = 285: x2 = 432: y2 = 315: GOSUB TekenBlok
dx = 352: dy = 297: waarde$ = "CANCEL": GOSUB PlaatsZwartOpGrijs


Backlabel:

SELECT CASE b1
    CASE 0
        x1 = 208: y1 = 130: x2 = 432: y2 = 150: GOSUB TekenBlok
        dx = 209: dy = 137: waarde$ = "RESCUES": GOSUB PlaatsZwartOpGrijs
        PUT (416, 135), LedOff(0), PSET
    CASE 1
        x1 = 208: y1 = 130: x2 = 432: y2 = 150: GOSUB TekenGat
        dx = 209: dy = 137: waarde$ = "RESCUES": GOSUB PlaatsZwartOpGrijs
        PUT (416, 135), LedOn(0), PSET
END SELECT
SELECT CASE b2
    CASE 0
        x1 = 208: y1 = 160: x2 = 432: y2 = 180: GOSUB TekenBlok
        dx = 209: dy = 167: waarde$ = "VEHICLE MOVEMENT DATA": GOSUB PlaatsZwartOpGrijs
        PUT (416, 165), LedOff(0), PSET
    CASE 1
        x1 = 208: y1 = 160: x2 = 432: y2 = 180: GOSUB TekenGat
        dx = 209: dy = 167: waarde$ = "VEHICLE MOVEMENT DATA": GOSUB PlaatsZwartOpGrijs
        PUT (416, 165), LedOn(0), PSET
END SELECT
SELECT CASE b3
    CASE 0
        x1 = 208: y1 = 190: x2 = 432: y2 = 210: GOSUB TekenBlok
        dx = 209: dy = 197: waarde$ = "HIGHSCORES/FLIGHTRECORDERS": GOSUB PlaatsZwartOpGrijs
        PUT (416, 195), LedOff(0), PSET
    CASE 1
        x1 = 208: y1 = 190: x2 = 432: y2 = 210: GOSUB TekenGat
        dx = 209: dy = 197: waarde$ = "HIGHSCORES/FLIGHTRECORDERS": GOSUB PlaatsZwartOpGrijs
        PUT (416, 195), LedOn(0), PSET
END SELECT
SELECT CASE b4
    CASE 0
        x1 = 208: y1 = 220: x2 = 432: y2 = 240: GOSUB TekenBlok
        dx = 209: dy = 227: waarde$ = "OTHER DEFAULT .TXT FILES": GOSUB PlaatsZwartOpGrijs
        PUT (416, 225), LedOff(0), PSET
    CASE 1
        x1 = 208: y1 = 220: x2 = 432: y2 = 240: GOSUB TekenGat
        dx = 209: dy = 227: waarde$ = "OTHER DEFAULT .TXT FILES": GOSUB PlaatsZwartOpGrijs
        PUT (416, 225), LedOn(0), PSET
END SELECT
SELECT CASE b5
    CASE 0
        x1 = 208: y1 = 250: x2 = 432: y2 = 270: GOSUB TekenBlok
        dx = 209: dy = 257: waarde$ = "RECORD REPLAY": GOSUB PlaatsZwartOpGrijs
        PUT (416, 255), LedOff(0), PSET
    CASE 1
        x1 = 208: y1 = 250: x2 = 432: y2 = 270: GOSUB TekenGat
        dx = 209: dy = 257: waarde$ = "RECORD REPLAY": GOSUB PlaatsZwartOpGrijs
        PUT (416, 255), LedOn(0), PSET
END SELECT



Label1:
_LIMIT 20
i$ = INKEY$
Mouse 3
IF b = 1 AND h > 208 AND h < 432 AND v > 130 AND v < 150 THEN _SNDPLAY Click&: GOSUB rescuecoordinates
IF b = 1 AND h > 208 AND h < 432 AND v > 160 AND v < 180 THEN _SNDPLAY Click&: GOSUB vehicles
IF b = 1 AND h > 208 AND h < 432 AND v > 190 AND v < 210 THEN _SNDPLAY Click&: GOSUB blackboxeshighscores
IF b = 1 AND h > 208 AND h < 432 AND v > 220 AND v < 240 THEN _SNDPLAY Click&: GOSUB defaultfiles
IF b = 1 AND h > 208 AND h < 432 AND v > 250 AND v < 270 THEN _SNDPLAY Click&: GOSUB recorddemo

IF (b = 1 AND h > 208 AND h < 316 AND v > 285 AND v < 315) OR i$ = " " THEN _SNDPLAY Click&: GOTO OK
IF (b = 1 AND h > 324 AND h < 432 AND v > 285 AND v < 315) OR i$ = CHR$(27) THEN _SNDPLAY Click&: GOTO cancel
IF i$ = "#" THEN SYSTEM
IF i$ = "!" AND b = 1 AND h > 1 AND h < 36 AND v > 1 AND v < 8 THEN TurboHS = 1: _SNDPLAY Click&: GOSUB blackboxeshighscores

IF i$ = CHR$(9) THEN GOSUB swapScreen '


GOTO Label1

rescuecoordinates:
x1 = 208: y1 = 130: x2 = 432: y2 = 150: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
IF b1 = 1 THEN b1 = 0: RETURN Backlabel
IF b1 = 0 THEN b1 = 1: RETURN Backlabel

vehicles:
x1 = 208: y1 = 160: x2 = 432: y2 = 180: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
IF b2 = 1 THEN b2 = 0: RETURN Backlabel
IF b2 = 0 THEN b2 = 1: RETURN Backlabel

blackboxeshighscores:
x1 = 208: y1 = 190: x2 = 432: y2 = 210: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
IF b3 = 1 THEN b3 = 0: TurboHS = 0: RETURN Backlabel
IF b3 = 0 THEN b3 = 1: RETURN Backlabel

defaultfiles:
x1 = 208: y1 = 220: x2 = 432: y2 = 240: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
IF b4 = 1 THEN b4 = 0: RETURN Backlabel
IF b4 = 0 THEN b4 = 1: RETURN Backlabel

recorddemo:
x1 = 208: y1 = 250: x2 = 432: y2 = 270: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
IF b5 = 1 THEN b5 = 0: RETURN Backlabel
IF b5 = 0 THEN b5 = 1: RETURN Backlabel

cancel:
x1 = 324: y1 = 285: x2 = 432: y2 = 315: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
_DELAY .2
GOSUB Systeemeinde2
CHAIN "Menu.exe"


OK:
x1 = 208: y1 = 285: x2 = 316: y2 = 315: GOSUB TekenGat
WHILE b <> 0: Mouse 3: _LIMIT 20: WEND '       Flush Mouse
_DELAY .2
'*********************************************************************************************
'RESCUES
'*********************************************************************************************
IF b1 = 1 THEN
    RescueDistance = 2200
    FOR rescue = 1 TO 9
        OPEN "..\TXTFiles\" + "LEVEL" + LTRIM$(STR$(rescue)) + ".TXT" FOR OUTPUT AS #1
        PRINT #1, "START"
        AllowedSec& = 360 + 120 * rescue '
        arescues = rescue + 3
        PRINT #1, AllowedSec&
        PRINT #1, arescues
        PRINT #1, " 0      0  0 BASE"
        FOR nn = 0 TO arescues - 1
            angle# = ((2 * pi#) / arescues) * nn
            xk = RescueDistance * SIN(angle#)
            yk = 0
            zk = RescueDistance * COS(angle#)
            PRINT #1, xk, yk, zk, "RESCUE " + LTRIM$(STR$(nn + 1))
        NEXT
        PRINT #1, "STOP"
        CLOSE #1
    NEXT
END IF
'*********************************************************************************************
'VEHICLES FILES HITBALLS
'*********************************************************************************************
IF b2 = 1 THEN
    RESTORE VehiclePlacement
    OPEN "..\TXTFiles\VEHICLES.TXT" FOR OUTPUT AS #11
    herstel:
    READ VijandType
    READ Hoek
    READ VijandAfstand#
    READ VijandSpeed#
    PRINT #11, VijandType, Hoek, VijandAfstand#, VijandSpeed#
    IF VijandType = 4 THEN
        READ TransportFuel: READ TransportBullets
        PRINT #11, TransportFuel, TransportBullets
    END IF
    IF VijandType = 99 THEN CLOSE #11: GOTO verder
    GOTO herstel
    verder:


    '
    OPEN "..\TXTFiles\HITBALLS.TXT" FOR OUTPUT AS #1
    PRINT #1, 5 'HitHightPerson
    PRINT #1, 10 'HitBallPerson

    PRINT #1, 16 'HithoogteOmax
    PRINT #1, 12 'Object1HitBall
    PRINT #1, 16 'Object2HitBall
    PRINT #1, 10 'Object3HitBall

    PRINT #1, 10 'HitHoogtemax
    PRINT #1, 16 'HitBallSportscar
    PRINT #1, 16 'HitBallJeep
    PRINT #1, 20 'HitBallTank
    PRINT #1, 20 'HitBallSupplyTruck
    CLOSE #1




END IF
'*********************************************************************************************
'BLACKBOXES AND HIGHSCORES
'*********************************************************************************************
IF b3 = 1 THEN

    OPEN "..\TXTFiles\" + "TMPSCORE.TXT" FOR OUTPUT AS #1
    PRINT #1, 0
    CLOSE #1

    OPEN "..\TXTFiles\" + "BLACKBOX.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB01.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB02.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB03.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB04.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB05.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB06.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB07.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB08.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB09.TXT" FOR OUTPUT AS #1
    CLOSE #1
    OPEN "..\TXTFiles\" + "BB10.TXT" FOR OUTPUT AS #1
    CLOSE #1

    SELECT CASE TurboHS
        CASE 0
            PlayerName$(1) = "------------": PlayerScore&(1) = 1000: PlayerLevel(1) = 0: FuelTotal#(1) = 0: PlayerSeconds&(1) = 0
            PlayerName$(2) = "------------": PlayerScore&(2) = 900: PlayerLevel(2) = 0: FuelTotal#(2) = 0: PlayerSeconds&(2) = 0
            PlayerName$(3) = "------------": PlayerScore&(3) = 800: PlayerLevel(3) = 0: FuelTotal#(3) = 0: PlayerSeconds&(3) = 0
            PlayerName$(4) = "------------": PlayerScore&(4) = 700: PlayerLevel(4) = 0: FuelTotal#(4) = 0: PlayerSeconds&(4) = 0
            PlayerName$(5) = "------------": PlayerScore&(5) = 600: PlayerLevel(5) = 0: FuelTotal#(5) = 0: PlayerSeconds&(5) = 0
            PlayerName$(6) = "------------": PlayerScore&(6) = 500: PlayerLevel(6) = 0: FuelTotal#(6) = 0: PlayerSeconds&(6) = 0
            PlayerName$(7) = "------------": PlayerScore&(7) = 400: PlayerLevel(7) = 0: FuelTotal#(7) = 0: PlayerSeconds&(7) = 0
            PlayerName$(8) = "------------": PlayerScore&(8) = 300: PlayerLevel(8) = 0: FuelTotal#(8) = 0: PlayerSeconds&(8) = 0
            PlayerName$(9) = "------------": PlayerScore&(9) = 200: PlayerLevel(9) = 0: FuelTotal#(9) = 0: PlayerSeconds&(9) = 0
            PlayerName$(10) = "------------": PlayerScore&(10) = 100: PlayerLevel(10) = 0: FuelTotal#(10) = 0: PlayerSeconds&(10) = 0
        CASE 1
            PlayerName$(1) = "------------": PlayerScore&(1) = 0: PlayerLevel(1) = 0: FuelTotal#(1) = 0: PlayerSeconds&(1) = 0
            PlayerName$(2) = "------------": PlayerScore&(2) = 0: PlayerLevel(2) = 0: FuelTotal#(2) = 0: PlayerSeconds&(2) = 0
            PlayerName$(3) = "------------": PlayerScore&(3) = 0: PlayerLevel(3) = 0: FuelTotal#(3) = 0: PlayerSeconds&(3) = 0
            PlayerName$(4) = "------------": PlayerScore&(4) = 0: PlayerLevel(4) = 0: FuelTotal#(4) = 0: PlayerSeconds&(4) = 0
            PlayerName$(5) = "------------": PlayerScore&(5) = 0: PlayerLevel(5) = 0: FuelTotal#(5) = 0: PlayerSeconds&(5) = 0
            PlayerName$(6) = "------------": PlayerScore&(6) = 0: PlayerLevel(6) = 0: FuelTotal#(6) = 0: PlayerSeconds&(6) = 0
            PlayerName$(7) = "------------": PlayerScore&(7) = 0: PlayerLevel(7) = 0: FuelTotal#(7) = 0: PlayerSeconds&(7) = 0
            PlayerName$(8) = "------------": PlayerScore&(8) = 0: PlayerLevel(8) = 0: FuelTotal#(8) = 0: PlayerSeconds&(8) = 0
            PlayerName$(9) = "------------": PlayerScore&(9) = 0: PlayerLevel(9) = 0: FuelTotal#(9) = 0: PlayerSeconds&(9) = 0
            PlayerName$(10) = "------------": PlayerScore&(10) = 0: PlayerLevel(10) = 0: FuelTotal#(10) = 0: PlayerSeconds&(10) = 0
    END SELECT

    OPEN "..\TXTFiles\" + "SCORES.TXT" FOR OUTPUT AS #1
    FOR k = 1 TO 10
        PRINT #1, k
        PRINT #1, PlayerName$(k)
        PRINT #1, PlayerScore&(k)
        PRINT #1, PlayerLevel(k)
        PRINT #1, FuelTotal#(k)
        PRINT #1, PlayerSeconds&(k)
    NEXT
    CLOSE #1

    FOR locknr = 0 TO 10
        lnr$ = LTRIM$(STR$(locknr))
        IF LEN(lnr$) < 2 THEN lnr$ = "0" + lnr$
        OPEN "..\TXTFiles\" + "LOCKS" + lnr$ + ".TXT" FOR OUTPUT AS #1 '
        PRINT #1, 1 'SUPPLY TRUCK
        PRINT #1, 1 'SPORTSCAR
        PRINT #1, 1 'JEEP
        PRINT #1, 1 'TANK
        PRINT #1, 1 'TREE
        PRINT #1, 1 'SHED
        PRINT #1, 1 'HEAP
        CLOSE #1
    NEXT

END IF
'*********************************************************************************************
'DEFAULT FILES
'*********************************************************************************************
IF b4 = 1 THEN
    OPEN "..\TXTFiles\" + "CURRENT.TXT" FOR OUTPUT AS #1
    PRINT #1, "SCENE01.ITM"
    CLOSE #1
    OPEN "..\TXTFiles\" + "VOLUME.TXT" FOR OUTPUT AS #1
    PRINT #1, 50
    CLOSE #1
    OPEN "..\TXTFiles\" + "DISPLAY.TXT" FOR OUTPUT AS #1
    PRINT #1, "FULLSCREEN"
    CLOSE #1
    OPEN "..\TXTFiles\" + "DISPLAYM.TXT" FOR OUTPUT AS #1
    PRINT #1, "FULLSCREEN"
    CLOSE #1
    OPEN "..\TXTFiles\" + "FPS.TXT" FOR OUTPUT AS #1
    PRINT #1, 60
    CLOSE #1
    OPEN "..\TXTFiles\" + "DIFF.TXT" FOR OUTPUT AS #1
    PRINT #1, 2
    CLOSE #1
    OPEN "..\TXTFiles\" + "SPEED.TXT" FOR OUTPUT AS #1
    PRINT #1, "FASTCPU"
    CLOSE #1
    OPEN "..\TXTFiles\" + "MODE.TXT" FOR OUTPUT AS #1
    PRINT #1, "NORMAL"
    CLOSE #1
    OPEN "..\TXTFiles\CURHISCO.TXT" FOR OUTPUT AS #1
    PRINT #1, 0
    CLOSE #1
    OPEN "..\TXTFiles\CONTROL.TXT" FOR OUTPUT AS #1
    PRINT #1, "MOUSE"
    CLOSE #1
    OPEN "..\TXTFiles\ENDTEXT.TXT" FOR OUTPUT AS #1
    PRINT #1, "#2024 T&T WARE"
    CLOSE #1
    OPEN "..\TXTFiles\DAYNIGHT.TXT" FOR OUTPUT AS #1
    PRINT #1, "DAY"
    CLOSE #1
    OPEN "..\TXTFiles\RADAR.TXT" FOR OUTPUT AS #1
    PRINT #1, "ON"
    CLOSE #1
    OPEN "..\TXTFiles\SKY.TXT" FOR OUTPUT AS #1
    PRINT #1, "ON"
    CLOSE #1
    OPEN "..\TXTFiles\BIRDS.TXT" FOR OUTPUT AS #1
    PRINT #1, 7
    CLOSE #1
    OPEN "..\TXTFiles\ZOOM.TXT" FOR OUTPUT AS #1
    PRINT #1, 1.2
    CLOSE #1

END IF
'*********************************************************************************************
'RECORD REPLAY
'*********************************************************************************************
OPEN "..\TXTFiles\" + "RECDEMO.TXT" FOR OUTPUT AS #1
SELECT CASE b5
    CASE 0: PRINT #1, "OFF"
    CASE 1: PRINT #1, "ON"
END SELECT
CLOSE #1
'*********************************************************************************************
IF b1 = 1 THEN PLAY "v" + Pct$ + "MBl32o4c"
IF b2 = 1 THEN PLAY "v" + Pct$ + "MBl32o4e"
IF b3 = 1 THEN PLAY "v" + Pct$ + "MBl32o4g"
IF b4 = 1 THEN PLAY "v" + Pct$ + "MBl32o5c"
IF b5 = 1 THEN PLAY "v" + Pct$ + "MBl32o5e"

GOSUB Systeemeinde2
'CHDIR "..\": CHAIN "Helicopter Rescue.exe"
CHAIN "Menu.exe"

'*********************************************************************************************
plaatstekstcentered:
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx - LEN(waarde$) * 3.5
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + (strp - 1) * 7, dy), v(nch * grootte), OR
NEXT
waarde$ = ""
RETURN

PlaatsTekstLinksUitlijn:
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (dx + (strp - 1) * 7, dy), v(nch * grootte), OR
NEXT
waarde$ = ""
RETURN

PlaatsTekstLinksUitlijnWit:
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (dx + (strp - 1) * 7, dy), vwit(nch * grootte), OR
NEXT
waarde$ = ""
RETURN


PlaatsZwartOpGrijs:
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + strp * 7, dy), w(nch * grootte), PSET
NEXT
waarde$ = ""
RETURN

TekenBlok:
LINE (x1, y1)-(x2 - 1, y1), 4
LINE (x2, y1)-(x2, y2 - 1), 4
LINE (x2, y2)-(x1 + 1, y2), 2
LINE (x1, y2)-(x1, y1 + 1), 2
RETURN

TekenGat:
LINE (x1, y1)-(x2 - 1, y1), 2
LINE (x2, y1)-(x2, y2 - 1), 2
LINE (x2, y2)-(x1 + 1, y2), 4
LINE (x1, y2)-(x1, y1 + 1), 4
RETURN

graphics:
CLS
RESTORE set2 '                          Character set (2 of 2)   enkele dikte
FOR nch = 32 TO 38
    dxch = (nch - 32) * 6
    dych = 10
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 15
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych + 40), 5
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), v(nch * grootte)
    GET (dxch, dych + 40)-(dxch + 5, dych + 6 + 40), vwit(nch * grootte)
NEXT
FOR nch = 40 TO 41
    dxch = (nch - 32) * 6
    dych = 10
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 15
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych + 40), 5
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), v(nch * grootte)
    GET (dxch, dych + 40)-(dxch + 5, dych + 6 + 40), vwit(nch * grootte)
NEXT
FOR nch = 44 TO 58
    dxch = (nch - 44) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 15
            IF flag$ = "1" THEN PSET (dxch + xch, ych + 40), 5
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), v(nch * grootte)
    GET (dxch, 40)-(dxch + 5, 6 + 40), vwit(nch * grootte)
NEXT
FOR nch = 64 TO 92
    dxch = (nch - 45) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 15
            IF flag$ = "1" THEN PSET (dxch + xch, ych + 40), 5
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), v(nch * grootte)
    GET (dxch, 40)-(dxch + 5, 6 + 40), vwit(nch * grootte)
NEXT

CLS
LINE (0, 0)-(639, 19), 3, BF
RESTORE Set1 '                          Character set (1 of 2)
nch = 32
dxch = (nch - 32) * 6
dych = 10
FOR ych = 0 TO 6
    READ pch$
    FOR xch = 0 TO 5
        flag$ = MID$(pch$, xch + 1, 1)
        IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 0
    NEXT
NEXT
GET (dxch, dych)-(dxch + 5, dych + 6), w(nch * grootte)
nch = 37
dxch = (nch - 32) * 6
dych = 10
FOR ych = 0 TO 6
    READ pch$
    FOR xch = 0 TO 5
        flag$ = MID$(pch$, xch + 1, 1)
        IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 0
    NEXT
NEXT
GET (dxch, dych)-(dxch + 5, dych + 6), w(nch * grootte)
nch = 38
dxch = (nch - 32) * 6
dych = 10
FOR ych = 0 TO 6
    READ pch$
    FOR xch = 0 TO 5
        flag$ = MID$(pch$, xch + 1, 1)
        IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 0
    NEXT
NEXT
GET (dxch, dych)-(dxch + 5, dych + 6), w(nch * grootte)
FOR nch = 40 TO 41
    dxch = (nch - 32) * 6
    dych = 10
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 0
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), w(nch * grootte)
NEXT

nch = 43
dxch = (nch - 32) * 6
dych = 10
FOR ych = 0 TO 6
    READ pch$
    FOR xch = 0 TO 5
        flag$ = MID$(pch$, xch + 1, 1)
        IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 0
    NEXT
NEXT
GET (dxch, dych)-(dxch + 5, dych + 6), w(nch * grootte)

FOR nch = 45 TO 58
    dxch = (nch - 45) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 0
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), w(nch * grootte)
NEXT
FOR nch = 64 TO 92
    dxch = (nch - 45) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 0
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), w(nch * grootte)
NEXT
CLS
PALETTE 15, 65536 * 0 + 256 * 63 + 0 'hoofdkleur
RETURN

TekenAchtergrond:
dx = 320 - 374 / 2
dy = 190 - 290 / 2
LINE (0, 0)-(639, 479), 1, BF
OPEN "..\Resources\Logo.pxl" FOR INPUT AS #3 '                  Logo
FOR yPxl = 0 TO 145
    FOR xPxl = 0 TO 187
        INPUT #3, cPxl(xPxl, yPxl)
    NEXT
NEXT
CLOSE #3
FOR yPxl = 0 TO 145
    FOR xPxl = 0 TO 187
        LINE (dx + 2 * xPxl, dy + 2 * yPxl)-(dx + 2 * xPxl + 1, dy + 2 * yPxl + 1), cPxl(xPxl, yPxl), BF
    NEXT
NEXT
LINE (0, 400)-(639, 440), 0, BF
RETURN



swapScreen: '
PLAY "v" + Pct$ + "MBl32o3a"
OPEN "..\TXTFiles\DISPLAYM.TXT" FOR INPUT AS #11
INPUT #11, screen$
CLOSE #11
IF screen$ = "WINDOWED" THEN screen$ = "FULLSCREEN": GOSUB WriteSettings: GOTO labello
IF screen$ = "FULLSCREEN" THEN screen$ = "WINDOWED": GOSUB WriteSettings: GOTO labello
labello:
IF full = 1 THEN _FULLSCREEN _OFF: _SCREENMOVE _MIDDLE: full = 0: RETURN
IF full = 0 THEN _FULLSCREEN _SQUAREPIXELS , _SMOOTH: full = 1: RETURN
WriteSettings:
OPEN "..\TXTFiles\DISPLAYM.TXT" FOR OUTPUT AS #11
PRINT #11, screen$
CLOSE #11
RETURN


'
Systeemeinde:
_AUTODISPLAY
TIMER OFF

dikte = 8
LINE (320 - dikte, 0)-(320 + dikte, 479), 0, BF
FOR k = 1 TO 40
    GET (320, 0)-(639 - dikte, 479), bulk1(0)
    GET (dikte, 0)-(319, 479), bulk2(0)
    _LIMIT 1280
    PUT (0, 0), bulk2(0), PSET
    PUT (320 + dikte, 0), bulk1(0), PSET
    _DISPLAY
NEXT
SYSTEM

Systeemeinde2:
_AUTODISPLAY
TIMER OFF

dikte = 8
LINE (320 - dikte, 0)-(320 + dikte, 479), 0, BF
FOR k = 1 TO 40
    GET (320, 0)-(639 - dikte, 479), bulk1(0)
    GET (dikte, 0)-(319, 479), bulk2(0)
    _LIMIT 1280
    PUT (0, 0), bulk2(0), PSET
    PUT (320 + dikte, 0), bulk1(0), PSET
    _DISPLAY
NEXT
RETURN



'LedOff
DATA ............
DATA ............
DATA ....2222....
DATA ...4AAAA2...
DATA ..4AAAABA2..
DATA ..4AAAAAA2..
DATA ..4AAAAAA2..
DATA ..4AAAAAA2..
DATA ...4AAAA2...
DATA ....4444....
DATA ............
DATA ............
'LedOn
DATA ............
DATA ............
DATA ....2222....
DATA ...4CCCC2...
DATA ..4CCCC5C2..
DATA ..4CCCCCC2..
DATA ..4CCCCCC2..
DATA ..4CCCCCC2..
DATA ...4CCCC2...
DATA ....4444....
DATA ............
DATA ............

Set1:
'        (32)
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

'  %     (37)
DATA 110001
DATA 110011
DATA 000110
DATA 001100
DATA 011000
DATA 110011
DATA 100011

' &
DATA 001000
DATA 110100
DATA 110100
DATA 001001
DATA 010110
DATA 110010
DATA 011101


'  ()    (40-41)       !@#
DATA 000110
DATA 001100
DATA 011000
DATA 011000
DATA 011000
DATA 001100
DATA 000110

DATA 011000
DATA 001100
DATA 000110
DATA 000110
DATA 000110
DATA 001100
DATA 011000

'+   (43)
DATA 000000
DATA 001100
DATA 001100
DATA 011110
DATA 001100
DATA 001100
DATA 000000


'  -     (45-47)
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

DATA 000001
DATA 000011
DATA 000110
DATA 001100
DATA 011000
DATA 110000
DATA 100000

'  0 - : (48-58)
DATA 011110
DATA 110111
DATA 110111
DATA 111011
DATA 111011
DATA 111011
DATA 011110

DATA 001100
DATA 011100
DATA 001100
DATA 001100
DATA 001100
DATA 001100
DATA 011110

DATA 011110
DATA 110011
DATA 000011
DATA 001100
DATA 110000
DATA 110000
DATA 111111

DATA 011110
DATA 110011
DATA 000011
DATA 001100
DATA 000011
DATA 110011
DATA 011110

DATA 110000
DATA 110000
DATA 110110
DATA 111111
DATA 000110
DATA 000110
DATA 000110

DATA 111111
DATA 110000
DATA 110000
DATA 001100
DATA 000011
DATA 110011
DATA 011110

DATA 000110
DATA 001100
DATA 011000
DATA 111110
DATA 110011
DATA 110011
DATA 011110

DATA 111111
DATA 000011
DATA 000011
DATA 001100
DATA 011000
DATA 011000
DATA 011000

DATA 011110
DATA 110011
DATA 110011
DATA 011110
DATA 110011
DATA 110011
DATA 011110

DATA 011110
DATA 110011
DATA 110011
DATA 011111
DATA 000110
DATA 001100
DATA 011000

DATA 000000
DATA 001100
DATA 001100
DATA 000000
DATA 001100
DATA 001100
DATA 000000

'  @ - Z (65-90)
DATA 001110
DATA 110011
DATA 110011
DATA 110111
DATA 110111
DATA 111000
DATA 001111

DATA 001100
DATA 011110
DATA 110011
DATA 111111
DATA 110011
DATA 110011
DATA 110011

DATA 111110
DATA 110011
DATA 110011
DATA 111110
DATA 110011
DATA 110011
DATA 111110

DATA 011110
DATA 110011
DATA 110000
DATA 110000
DATA 110000
DATA 110011
DATA 011110

DATA 111110
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 111110

DATA 111111
DATA 110000
DATA 110000
DATA 111100
DATA 110000
DATA 110000
DATA 111111

DATA 111111
DATA 110000
DATA 110000
DATA 111100
DATA 110000
DATA 110000
DATA 110000

DATA 011110
DATA 110011
DATA 110000
DATA 110110
DATA 110011
DATA 110011
DATA 011110

DATA 110011
DATA 110011
DATA 110011
DATA 111111
DATA 110011
DATA 110011
DATA 110011

DATA 011110
DATA 001100
DATA 001100
DATA 001100
DATA 001100
DATA 001100
DATA 011110

DATA 111111
DATA 000011
DATA 000011
DATA 110011
DATA 110011
DATA 110011
DATA 011110

DATA 110011
DATA 110011
DATA 110110
DATA 111100
DATA 110110
DATA 110011
DATA 110011

DATA 110000
DATA 110000
DATA 110000
DATA 110000
DATA 110000
DATA 110000
DATA 111111

DATA 110011
DATA 111111
DATA 111111
DATA 110011
DATA 110011
DATA 110011
DATA 110011

DATA 110011
DATA 111011
DATA 111011
DATA 110111
DATA 110111
DATA 110011
DATA 110011

DATA 011110
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 011110

DATA 111110
DATA 110011
DATA 110011
DATA 111110
DATA 110000
DATA 110000
DATA 110000

DATA 011110
DATA 110011
DATA 110011
DATA 110011
DATA 110111
DATA 110110
DATA 011111

DATA 111110
DATA 110011
DATA 110011
DATA 111110
DATA 110011
DATA 110011
DATA 110011

DATA 011110
DATA 110011
DATA 110000
DATA 011110
DATA 000011
DATA 110011
DATA 011110

DATA 111111
DATA 001100
DATA 001100
DATA 001100
DATA 001100
DATA 001100
DATA 001100

DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 011110

DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 011110
DATA 001100

DATA 110011
DATA 110011
DATA 110011
DATA 110011
DATA 111111
DATA 111111
DATA 110011

DATA 110011
DATA 110011
DATA 011110
DATA 001100
DATA 011110
DATA 110011
DATA 110011

DATA 110011
DATA 110011
DATA 110011
DATA 011110
DATA 001100
DATA 001100
DATA 001100

DATA 111111
DATA 000011
DATA 000110
DATA 001100
DATA 011000
DATA 110000
DATA 111111

DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

DATA 001100
DATA 001100
DATA 011000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

set2:
'        (32 - 37) SPC-%
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 000000
DATA 001000

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
DATA 001100
DATA 011000
DATA 011000
DATA 011000
DATA 001100
DATA 000110

DATA 011000
DATA 001100
DATA 000110
DATA 000110
DATA 000110
DATA 001100
DATA 011000


'  -     (44-47)
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
'  0 - 9 (48-57)
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
DATA 001000
DATA 001000
DATA 000000
DATA 001000
DATA 001000
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

VehiclePlacement:

'DATA LINE 1:     1=supply truck  ,  180 degrees  ,  distance 0020 ft  ,  speed 1.25 ft/cycle  ,  125 GL fuel  ,  1200 bullets
'DATA LINE 2:     2=sportscar     ,  350 degrees  ,  distance 4000 ft  ,  speed 1.25 ft/cycle
'
'You get it?      3=jeep, 4=tank
'
'Last DATA LINE: 99,0,0,0
'

'Starting with truck, or else: no fuel
DATA 1,180,0020,1.25,125,1200
DATA 2,350,4000,1.25
DATA 2,030,4100,1.15
DATA 2,100,4000,1.25
DATA 2,130,4100,1.30

DATA 1,170,4000,1,125,1200

DATA 3,225,4000,1
DATA 2,178,4050,1.1
DATA 3,130,4000,1.25
DATA 2,170,4050,1.2

DATA 3,315,4000,1.2
DATA 3,315,4050,1.3
DATA 2,135,4000,1.3
DATA 3,155,4000,1.2

DATA 1,170,4000,1,125,1200

DATA 4,010,4000,1
DATA 2,040,4050,1.2
DATA 3,315,4000,1.3
DATA 3,205,4050,1.25

DATA 4,010,4000,1.25
DATA 2,090,4050,1.25
DATA 4,180,4000,1.25

DATA 1,270,4050,1.25,125,1200

DATA 2,020,4000,1.35
DATA 3,350,4100,1.35
DATA 2,100,4000,1.35
DATA 4,080,4100,1.35

DATA 1,170,4000,1,125,1200

DATA 3,225,4000,1.1
DATA 4,200,4050,1.25
DATA 3,160,4000,1.35
DATA 2,170,4050,1.35

DATA 3,045,4000,1.35
DATA 3,025,4050,1.35
DATA 2,135,4000,1.35
DATA 2,115,4000,1.35

DATA 1,170,4000,1,125,1200

DATA 4,010,4000,1.1
DATA 4,020,4050,1.1
DATA 3,315,4000,1.35
DATA 3,315,4050,1.35

DATA 3,010,4000,1.35
DATA 3,100,4050,1.35
DATA 2,190,4000,1.35
DATA 3,280,4050,1.35

DATA 1,190,4000,1,125,1200

DATA 99,0,0,0


SUB Mouse (Funk) STATIC 'Define sub & parameter(s) passed.
    SHARED b, h, v 'Share variables with main sub.
    IF Funk = 1 THEN Crsr = 1 'Show Cursor.
    IF Funk = 2 AND Crsr = 0 THEN EXIT SUB 'Don't hide Cursor more than once.
    IF Funk = 2 AND Crsr = 1 THEN Crsr = 0 'Hide Cursor.
    POKE 100, 184: POKE 101, Funk: POKE 102, 0 'Poke machine code necessary for
    POKE 103, 205: POKE 104, 51: POKE 105, 137 'using the mouse into memory
    POKE 106, 30: POKE 107, 170: POKE 108, 10 'starting at offset 100 in the
    POKE 109, 137: POKE 110, 14: POKE 111, 187 'current segment.  This code is
    POKE 112, 11: POKE 113, 137: POKE 114, 22 'then executed as a unit, via the
    POKE 115, 204: POKE 116, 12: POKE 117, 203 'statement " Call Absolute ".
    CALL ABSOLUTE(100) 'Call machine code.
    b = PEEK(&HAAA) 'Get values for: Buttons
    h = PEEK(&HBBB) + PEEK(&HBBC) * 256 'Horizontal position ( 2 bytes )
    v = PEEK(&HCCC) + PEEK(&HCCD) * 256 'Vertical position ( 2 bytes )
END SUB 'End of sub-program.
