'
'Copyright 2023 Arnold Kramer   T&T WARE tijdelijkkistjeskerel@gmail.com
'
'ver. 20240707 1.6.19
$EXEICON:'./../Resources/HRExe.ico'
_TITLE "Helicopter Rescue - Menu"
DEFINT A-Z

OPEN "..\TXTFiles\VOLUME.TXT" FOR INPUT AS #1
INPUT #1, Volume
CLOSE #1

SlideSpeed& = 1280

Pct$ = LTRIM$(STR$(Volume))

Click& = _SNDOPEN("..\OGGFiles\" + "Click.ogg", "VOL,SYNC")

Warningkje& = _SNDOPEN("..\OGGFiles\" + "HitEnemy.ogg", "VOL,SYNC")


controller$ = "MOUSE"


_SNDVOL Click&, Volume / 100

_SNDVOL HitEnemy&, Volume / 100





CONST FeetPerSecondToKnots! = 0.592483801
CONST pi# = 4 * ATN(1)
CONST pf# = (180 / pi#)
CONST worldx# = 5000
CONST worldz# = 5000
CONST MaxScenes = 10
CONST LichtkrantPulseTijd# = 1 / 75 'sec.

MPSeconds& = 3600 '1800 seconden voor CHAIN i.v.m. oplopende Stack
'

OPEN "..\TXTFiles\CURHISCO.TXT" FOR INPUT AS #19
INPUT #19, CURHISCO
CLOSE #19

locknr = CURHISCO


REDIM Page1(0 TO 500)
REDIM Page2(0 TO 500)

REDIM LLock(0 TO 10, 0 TO 10)
REDIM aantallocked(0 TO 10)
REDIM Aantalvrij(0 TO 10)
REDIM Enemynummer(0 TO 10)

FOR locknr = 0 TO 10
    lnr$ = LTRIM$(STR$(locknr))
    IF LEN(lnr$) < 2 THEN lnr$ = "0" + lnr$
    OPEN "..\TXTFiles\" + "LOCKS" + lnr$ + ".TXT" FOR INPUT AS #1 '
    aantallocked(locknr) = 0
    INPUT #1, LLock(locknr, 1) 'SUPPLY TRUCK
    IF LLock(locknr, 1) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    INPUT #1, LLock(locknr, 2) 'SPORTSCAR
    IF LLock(locknr, 2) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    INPUT #1, LLock(locknr, 3) 'JEEP
    IF LLock(locknr, 3) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    INPUT #1, LLock(locknr, 4) 'TANK
    IF LLock(locknr, 4) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    INPUT #1, LLock(locknr, 5) 'TREE
    IF LLock(locknr, 5) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    INPUT #1, LLock(locknr, 6) 'SHED
    IF LLock(locknr, 6) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    INPUT #1, LLock(locknr, 7) 'HEAP
    IF LLock(locknr, 7) = 1 THEN aantallocked(locknr) = aantallocked(locknr) + 1
    CLOSE #1

    FOR k = 0 TO 7
        IF LLock(locknr, k) = 0 THEN Aantalvrij(locknr) = Aantalvrij(locknr) + 1
    NEXT

NEXT

DECLARE SUB Mouse (Funk)
'

Blades& = _SNDOPEN("..\OGGFiles\" + "Blades.ogg", "VOL,SYNC")


_SNDVOL Click&, Volume / 100
_SNDVOL Blades&, Volume / 100
grootte = 50 '                              array karakters
kmax = 99
dotstraal! = 2 '                            afmeting gele stip bij analyse
straaltje = 14 '                            lengte van de gele heading-lijn bij analyse en dus de get array (max 16)
naaldlengte = 13
maxseconds = 9999
grafiekkeuze = 1
onetoseventeller = 0
NumberOfFlashes = 3

REDIM bulk1(0 TO 100000)
REDIM bulk2(0 TO 100000)
REDIM bulk3(0 TO 50000)

REDIM cPxl(0 TO 187, 0 TO 145)
REDIM stukje(0 TO 200)
REDIM stukjepark(0 TO 200)

'
REDIM xNader(0 TO maxseconds)
REDIM zNader(0 TO maxseconds)

REDIM xxx#(0 TO maxseconds)
REDIM yyy#(0 TO maxseconds)
REDIM zzz#(0 TO maxseconds)
REDIM fuel#(0 TO maxseconds)
REDIM ammo(0 TO maxseconds)
REDIM heading(0 TO maxseconds)
REDIM snelheid(0 TO maxseconds)
REDIM PlayerName$(0 TO 10)
REDIM PlayerScore&(0 TO 10)
REDIM PlayerLevel(0 TO 10)
REDIM FuelTotal#(0 TO 10)
REDIM PlayerSeconds&(0 TO 10)
REDIM min$(0 TO 10)
REDIM sec$(0 TO 10)
REDIM PS$(0 TO 10)
REDIM tiles(1 TO MaxScenes)
REDIM tiles$(1 TO MaxScenes)
REDIM xx#(1 TO 9, 0 TO kmax)
REDIM yy#(1 TO 9, 0 TO kmax)
REDIM zz#(1 TO 9, 0 TO kmax)
REDIM b$(1 TO 9, 0 TO kmax)
REDIM t(0 TO 10000)
REDIM v(0 TO 10000)
REDIM vglow(0 TO 10000)
REDIM w(0 TO 10000)
REDIM logo(0 TO 90000)
REDIM Accolade(1000)
REDIM SliderPark(8000) '
REDIM DontShoot(0 TO 5000)
REDIM DontShootMask(0 TO 5000)
REDIM DontShootBackground(0 TO 5000)
REDIM DontShoottext(0 TO 5000)
REDIM DontShoottextMask(0 TO 5000)
REDIM DontShoottextBackground(0 TO 5000)

'
REDIM Muis(0 TO 5000)
REDIM MuisMask(0 TO 5000)
'ReDim MuisBackground(0 To 5000)

REDIM Roos(0 TO 5000)
REDIM RoosMask(0 TO 5000)

REDIM tekstachtergrond(0 TO 13000)
REDIM balparkL(0 TO 2000)
REDIM balparkR(0 TO 50)

OPEN "..\TXTFiles\" + "ENDTEXT.TXT" FOR INPUT AS #1
INPUT #1, EndText$
CLOSE #1


OPEN "..\TXTFiles\" + "FPS.TXT" FOR INPUT AS #1
INPUT #1, OverallFramerate
CLOSE #1

OPEN "..\TXTFiles\" + "SPEED.TXT" FOR INPUT AS #1
INPUT #1, fastslow$
CLOSE #1

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

REDIM x#(0 TO 1999, 0 TO 4)
REDIM y#(0 TO 1999, 0 TO 4)
REDIM z#(0 TO 1999, 0 TO 4)
REDIM kleur(0 TO 1999)
REDIM Big&(0 TO 45000)
REDIM Bigger&(0 TO 90000)
REDIM LedOn(0 TO 500)
REDIM LedOff(0 TO 500)
REDIM LedHalf(0 TO 500)
REDIM balknul(0 TO 1000)
REDIM balk(0 TO 1000)
REDIM balkpark(0 TO 1000)
REDIM balkhalf(0 TO 1000)

RESTORE Lichtkrant

PS$ = LTRIM$(STR$(PlayerScore&(1)))
WHILE LEN(PS$) < 6: PS$ = "0" + PS$: WEND
totaal$ = "                                 *** HELICOPTER RESCUE ***                                                                                   "
totaal$ = totaal$ + "             WELCOME PILOT                                                                                         "
totaal$ = totaal$ + "  HIGHSCORE: " + PS$ + " BY " + PlayerName$(1) + "                                                                                                "
terug:
READ regel$
IF regel$ <> "13131313" THEN
    totaal$ = totaal$ + regel$ + " "
    GOTO terug
END IF
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


















'
IF _FILEEXISTS("..\REPLAY.mcr") = 0 GOTO WeiterReiter
OPEN "..\REPLAY.mcr" FOR INPUT AS #23

AantalElementen = 0
DO
    INPUT #23, CheckWaarde: AantalElementen = AantalElementen + 1
LOOP UNTIL EOF(23)
CLOSE #23

IF AantalElementen MOD 4 <> 0 THEN
    CLS: LOCATE 10, 9: PRINT "'REPLAY.mcr' broken, can't be repaired. It will be deleted. <ANY KEY>";
    WHILE INKEY$ = "": _LIMIT OverallFramerate: WEND
    KILL "..\REPLAY.mcr": GOTO WeiterReiter
END IF
IF CheckWaarde <> 9999 THEN
    CLS: LOCATE 10, 18: PRINT "'REPLAY.mcr' File Broken. (R)epair or (D)elete?";
ELSE
    GOTO WeiterReiter
END IF
CheckL000:
i$ = INKEY$
_LIMIT OverallFramerate
IF i$ = "r" OR i$ = "R" GOTO RepairMCR
IF i$ = "d" OR i$ = "D" THEN KILL "..\REPLAY.mcr": CLS: LOCATE 10, 24: PRINT "'REPLAY.mcr' deleted. <ANY KEY>";: WHILE INKEY$ = "": WEND: GOTO WeiterReiter
GOTO CheckL000
RepairMCR:
OPEN "..\REPLAY.mcr" FOR APPEND AS #23
PRINT #23, 9999, 9999, 9999, 9999
CLOSE #23
CLS: LOCATE 10, 24: PRINT "'REPLAY.mcr' repaired. <ANY KEY>";
WHILE INKEY$ = "": _LIMIT OverallFramerate: WEND
WeiterReiter:




FOR altco = 0 TO 255: PALETTE altco, 0: NEXT

LINE (0, 0)-(639, 19), 0, BF

RESTORE Accolade
FOR Y = 0 TO 22
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (x, Y), 15
        END SELECT
    NEXT
NEXT
GET (0, 0)-(5, 22), Accolade(0)

'
RESTORE pages
FOR Y = 0 TO 9
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (100 + x, Y), 15
        END SELECT
    NEXT
NEXT
GET (100, 0)-(111, 4), Page1(0)
GET (100, 5)-(111, 9), Page2(0)





RESTORE Led
FOR Y = 0 TO 11
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "A": PSET (x, Y), 9 '
            CASE "B": PSET (x, Y), 3 '
            CASE "C": PSET (x, Y), 8 '
            CASE ".": PSET (x, Y), 3
            CASE ELSE: PSET (x, Y), VAL(b$)
        END SELECT
    NEXT
NEXT
GET (0, 0)-(11, 11), LedOff(0)
FOR Y = 0 TO 11
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "A": PSET (x, Y), 9 '
            CASE "B": PSET (x, Y), 16 '
            CASE "C": PSET (x, Y), 8 '
            CASE ".": PSET (x, Y), 3
            CASE ELSE: PSET (x, Y), VAL(b$)
        END SELECT
    NEXT
NEXT
GET (0, 0)-(11, 11), LedOn(0)
FOR Y = 0 TO 11
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "A": PSET (x, Y), 9 '
            CASE "B": PSET (x, Y), 16 '
            CASE "C": PSET (x, Y), 165 '
            CASE ".": PSET (x, Y), 3
            CASE ELSE: PSET (x, Y), VAL(b$)
        END SELECT
    NEXT
NEXT
GET (0, 0)-(11, 11), LedHalf(0)

'roos       kleuren: wit: 170  lichtbruin:173 bruin:172 donkerbruin:171
RESTORE roos

FOR Y = 0 TO 55
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (x, Y), 164
            CASE ELSE: PSET (x, Y), 0
        END SELECT
    NEXT
NEXT
GET (0, 0)-(55, 55), Roos(0)
LINE (0, 0)-(55, 55), 0, BF
RESTORE roos
FOR Y = 0 TO 55
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 255
            CASE ELSE: PSET (x, Y), 0
        END SELECT
    NEXT
NEXT
GET (0, 0)-(55, 55), RoosMask(0)
LINE (0, 0)-(55, 55), 0, BF


RESTORE dontshoot
FOR Y = 0 TO 31
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (x, Y), 9 '
            CASE "2": PSET (x, Y), 8 '
            CASE ELSE: PSET (x, Y), 0 '
        END SELECT
    NEXT
NEXT
GET (0, 0)-(31, 31), DontShoot(0)
LINE (0, 0)-(31, 31), 0, BF
RESTORE dontshoot
FOR Y = 0 TO 31
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 255
            CASE ELSE: PSET (x, Y), 0 '
        END SELECT
    NEXT
NEXT
GET (0, 0)-(31, 31), DontShootMask(0)
LINE (0, 0)-(639, 31), 0, BF
'









RESTORE dontshoottext
FOR Y = 0 TO 12
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE IS <> "0": PSET (x, Y), 8 '
                'Case "2": PSet (x, Y), 8 '
            CASE ELSE: PSET (x, Y), 0 '
        END SELECT
    NEXT
NEXT
GET (0, 0)-(91, 12), DontShoottext(0)
LINE (0, 0)-(91, 12), 0, BF
RESTORE dontshoottext
FOR Y = 0 TO 12
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 255
            CASE ELSE: PSET (x, Y), 0 '
        END SELECT
    NEXT
NEXT
GET (0, 0)-(91, 12), DontShoottextMask(0)
LINE (0, 0)-(91, 12), 0, BF





'
RESTORE Muis
FOR Y = 0 TO 10
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "1": PSET (x, Y), 9 '
            CASE "2": PSET (x, Y), 8 '
            CASE ELSE: PSET (x, Y), 0 '
        END SELECT
    NEXT
NEXT
GET (0, 0)-(10, 10), Muis(0)
LINE (0, 0)-(10, 10), 0, BF
RESTORE Muis
FOR Y = 0 TO 10
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 255
            CASE ELSE: PSET (x, Y), 0 '
        END SELECT
    NEXT
NEXT
GET (0, 0)-(10, 10), MuisMask(0)
LINE (0, 0)-(639, 31), 0, BF

RESTORE Balknul
FOR Y = 0 TO 7
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 0
            CASE ELSE: PSET (x, Y), 5
        END SELECT
    NEXT
NEXT
GET (0, 0)-(39, 7), balknul(0)
LINE (0, 0)-(39, 7), 0, BF

RESTORE Balk
FOR Y = 0 TO 7
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 0
            CASE ELSE: PSET (x, Y), 5
        END SELECT
    NEXT
NEXT
GET (0, 0)-(39, 7), balk(0)
LINE (0, 0)-(39, 7), 0, BF

RESTORE Balkhalf
FOR Y = 0 TO 7
    READ a$
    FOR x = 0 TO LEN(a$) - 1
        b$ = MID$(a$, x + 1, 1)
        SELECT CASE b$
            CASE "0": PSET (x, Y), 0
            CASE ELSE: PSET (x, Y), 5
        END SELECT
    NEXT
NEXT
GET (0, 0)-(39, 7), balkhalf(0)
LINE (0, 0)-(39, 7), 0, BF


FOR y1 = 441 TO 467
    LINE (0, y1)-(639, y1), y1 - 241
NEXT
GOSUB graphics

x1 = 0: y1 = 0: x2 = 639: y2 = 479: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
x1 = 10: y1 = 11: x2 = 429: y2 = 429: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat
x1 = 436: y1 = 11: x2 = 629: y2 = 162: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat
x1 = 10: y1 = 439: x2 = 629: y2 = 469: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat
FOR y1 = 441 TO 467
    LINE (12, y1)-(627, y1), y1 - 241
NEXT



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
PALETTE 15, 65526 * 0 + 256 * 63 + 0 'hoofdkleur
PALETTE 16, 65536 * 0 + 256 * 31 + 0 'mediumgroen
PALETTE 164, 65536 * 0 + 256 * 31 + 0 'mediumgroen
PALETTE 165, 65536 * 0 + 256 * 0 + 43 'mediumrood

'
PALETTE 170, 65536 * 0 + 256 * 0 + 0 ' zwart
PALETTE 171, 65536 * 63 + 256 * 63 + 63 ' wit
PALETTE 172, 65536 * 0 + 256 * 15 + 31 ' l-bruin
PALETTE 173, 65536 * 0 + 256 * 7 + 15 ' d-bruin
PALETTE 174, 65536 * 50 + 256 * 25 + 25


FOR grey = 100 TO 163
    PALETTE grey, 65536 * (grey - 100) + 256 * (grey - 100) + (grey - 100)
NEXT
PALETTE 32, 65536 * 0 + 256 * 0 + 0
PALETTE 33, 65536 * 63 + 256 * 63 + 63 'Lichtkrant-letters, witte letters
FOR kleu = 200 TO 226 'zwart
    hulpwaarde = INT((kleu - 200) * 2.4)
    PALETTE kleu, 0
NEXT

waardeToev$ = LTRIM$(STR$(PlayerScore&(1)))
WHILE LEN(waardeToev$) < 6: waardeToev$ = "0" + waardeToev$: WEND

RFileNr = 1
OPEN "..\TXTFiles\LEVEL" + LTRIM$(STR$(RFileNr)) + ".TXT" FOR INPUT AS #4
INPUT #4, a$
INPUT #4, AllowedSec&
INPUT #4, max
FOR k = 0 TO max
    INPUT #4, xx#(RFileNr, k)
    INPUT #4, yy#(RFileNr, k)
    INPUT #4, zz#(RFileNr, k)
    INPUT #4, b$(RFileNr, k)
NEXT

'*******************************

hulp6:

vakafmeting = 8
dxmap = 20: dymap = 20
LINE (-9 + dxmap, -8 + dymap)-(8 + dxmap + 50 * vakafmeting, 8 + dymap + 50 * vakafmeting), 14, BF
FOR xmap = 0 TO 50
    FOR ymap = 0 TO 50
        PSET (dxmap + vakafmeting * xmap, dymap + vakafmeting * ymap), 7
    NEXT
NEXT
'
GET (200, 140)-(239, 147), balkpark(0)
PUT (200, 140), balknul(0), PSET
'
FOR t = 0 TO maxseconds
    xxx#(t) = 0: yyy#(t) = 0: zzz#(t) = 0: fuel#(t) = 0: ammo(t) = 0
NEXT
t = 0
FOR N = 1 TO MaxScenes
    nummer$ = RIGHT$(STR$(N), LEN(STR$(N)) - 1)
    IF LEN(nummer$) < 2 THEN nummer$ = "0" + nummer$
    vergelijk$ = "SCENE" + nummer$ + ".ITM"
    IF _FILEEXISTS("..\ITMFiles\" + vergelijk$) = -1 THEN
        OPEN "..\ITMFiles\" + vergelijk$ FOR INPUT AS #7
        INPUT #7, start$
        INPUT #7, tiles(N)
        CLOSE #7
        nummer$ = RIGHT$(STR$(tiles(N)), LEN(STR$(tiles(N))) - 1)
        WHILE LEN(nummer$) < 5: nummer$ = "0" + nummer$: WEND
        tiles$(N) = nummer$
    END IF
NEXT

OPEN "..\TXTFiles\CURRENT.TXT" FOR INPUT AS #5
INPUT #5, CurrentITM$
CLOSE #5

'
OPEN "..\TXTFiles\CURHISCO.TXT" FOR INPUT AS #19
INPUT #19, CURHISCO
CLOSE #19

locknr = CURHISCO


GOSUB loaditm
GOSUB DrawITMMap

x1 = 436: y1 = 400: x2 = 629: y2 = 428: GOSUB tekenblok
waarde$ = "EXIT"
dx = 440: dy = 411: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 409), LedOff(0), PSET
x1 = 436: y1 = 362: x2 = 629: y2 = 390: GOSUB tekenblok
waarde$ = "RESET FILES"
dx = 440: dy = 373: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 371), LedOff(0), PSET
x1 = 436: y1 = 324: x2 = 629: y2 = 352: GOSUB tekenblok
waarde$ = "ANALYSIS"
dx = 440: dy = 335: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 333), LedOff(0), PSET
x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok
waarde$ = "FLY"
dx = 440: dy = 297: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 295), LedOff(0), PSET
x1 = 436: y1 = 248: x2 = 629: y2 = 276: GOSUB tekenblok
waarde$ = "INFO"
dx = 440: dy = 259: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 257), LedOff(0), PSET
x1 = 436: y1 = 210: x2 = 629: y2 = 238: GOSUB tekenblok
waarde$ = "ACHIEVEMENTS"
dx = 440: dy = 221: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 219), LedOff(0), PSET
x1 = 436: y1 = 172: x2 = 629: y2 = 200: GOSUB tekenblok
waarde$ = "HALL OF FAME":
dx = 440: dy = 183: GOSUB PlaatsZwartOpGrijs
LO = 0: PUT (608, 181), LedOff(0), PSET


'
PUT (200, 140), balk(0), PSET

OPEN "..\Resources\Logo.pxl" FOR INPUT AS #3
FOR yPxl = 0 TO 145
    FOR xPxl = 0 TO 187
        INPUT #3, cPxl(xPxl, yPxl)
    NEXT
NEXT
CLOSE #3

PUT (200, 140), balkhalf(0), PSET

LINE (437, 12)-(628, 161), 1, B
LINE (438, 13)-(627, 160), 1, B
FOR yPxl = 0 TO 145
    FOR xPxl = 0 TO 187
        PSET (xPxl + 439, yPxl + 14), cPxl(xPxl, yPxl)
    NEXT
NEXT

PUT (200, 140), balkpark(0), PSET
'

GET (439, 14)-(626, 159), logo(0)

TIMER OFF
'teken kompasroos
'
PUT (40, 40), RoosMask(0), AND
PUT (40, 40), Roos(0), XOR
'
GOSUB drawCurrentBlackbox
'GOSUB drawCurrentBB

k = 0
x = 220 + 8 * xx#(RFileNr, k) / 100
Y = 220 - 8 * zz#(RFileNr, k) / 100
IF x < 14 THEN x = 14
IF x > 425 THEN x = 425
IF Y < 15 THEN Y = 15
IF Y > 425 THEN Y = 425

waarde$ = RIGHT$(STR$(k), LEN(STR$(k)) - 1)
dx = x + 1: dy = Y + 5
GOSUB PlaatsTekstCentered

GOSUB CalculateDistance

IF Tmax > 0 THEN
    AverageSpeed = (Distance& / Tmax) * FeetPerSecondToKnots!
    waarde$ = LTRIM$(STR$(AverageSpeed)) + " KTS"
    'dx = 16: dy = 417: GOSUB PlaatsTekstLinksUitlijn
END IF

waarde$ = LTRIM$(STR$(Distance&)) + " FT"
' dx = 425: dy = 417: GOSUB PlaatsTekstRechtsUitlijn

IF k = 0 THEN
    waarde$ = "BASE"
    dx = x + 1: dy = Y - 11
    GOSUB PlaatsTekstCentered
END IF

LINE (x - 3, Y - 3)-(x + 3, Y + 3), 15, B
'
IF CURHISCO <> 0 THEN
    waarde$ = LTRIM$(STR$(PlayerScore&(CURHISCO)))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 425: dy = 17: GOSUB PlaatsTekstRechtsUitlijn
    waarde$ = "(" + LTRIM$(STR$(CURHISCO)) + ")" + " " + PlayerName$(CURHISCO): dx = 16: dy = 17: GOSUB PlaatsTekstLinksUitlijn
ELSE


    OPEN "..\TXTFiles\TMPSCORE.TXT" FOR INPUT AS #1
    INPUT #1, tempscore&
    CLOSE #1
    waarde$ = LTRIM$(STR$(tempscore&))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 425: dy = 17: GOSUB PlaatsTekstRechtsUitlijn

END IF
xx1 = 220
zz1 = 220
GET (xx1 - straaltje, zz1 - straaltje)-(xx1 + straaltje, zz1 + straaltje), balparkL(0)
GET (629, 451)-(639, 457), stukje(0)

WHILE INKEY$ <> "": WEND
'
ON TIMER(LichtkrantPulseTijd#) GOSUB pulse

TIMER ON

'*********************************************************** Hoofdlus ****
hl0:
_LIMIT OverallFramerate
Mouse 3
i$ = INKEY$
'If UCase$(i$) = "R" Then GoSub ReadMe
IF i$ = CHR$(9) THEN GOSUB swapScreen '
IF i$ = CHR$(27) THEN TIMER OFF: GOTO Systeemeinde
IF i$ = "#" THEN _CLIPBOARD$ = "https://www.youtube.com/@ttware7430": SYSTEM
IF i$ = "-" OR i$ = "+" THEN GOSUB Volume
'
IF b = 1 AND _FILEEXISTS("..\REPLAY.MCR") AND h > 10 AND h < 629 AND v > 439 AND v < 469 THEN
    IF _FILEEXISTS("Replay.exe") = 0 THEN
        'GoSub systeemeinde2
        WHILE INKEY$ <> "": WEND
        TIMER OFF
        CLS
        waarde$ = "CONTACT TTWAREHELICOPTERRESCUE@GMAIL.COM FOR MISSING FILES"
        dx = 319: dy = 230: GOSUB PlaatsTekstCentered
        CIRCLE (105, 233), 10, , .5 * pi#, 1.5 * pi#
        CIRCLE (530, 233), 10, , 1.5 * pi#, .5 * pi#
        LINE (104, 223)-(531, 223)
        LINE (104, 243)-(531, 243)

        _DISPLAY
        b = 0
        WHILE INKEY$ = "" AND b = 0
            _LIMIT OverallFramerate
            Mouse 3
        WEND
        GOSUB systeemeinde2
        '
        CLEAR: CLS

        CHAIN "Menu.exe"
    END IF
    GOSUB systeemeinde2
    CHAIN "Replay.exe"
END IF
'
d& = _DEVICEINPUT
IF d& = 3 THEN trigger = -_BUTTON(1)
IF trigger <> 0 THEN _SNDPLAY Click&: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekengat: dwt = 0: controller$ = "JOYSTICK": GOTO eindeFLY
IF b = 1 THEN x = h: Y = v: GOTO hl1
GOTO hl0
' *************************************************************************
hl1:
IF x > 438 AND x < 627 AND Y > 402 AND Y < 426 THEN _SNDPLAY Click&: x1 = 436: y1 = 400: x2 = 629: y2 = 428: GOSUB tekengat: LO = 1: PUT (608, 409), LedOn(0), PSET: _DELAY (.05): GOTO Systeemeinde
IF x > 438 AND x < 627 AND Y > 364 AND Y < 388 THEN _SNDPLAY Click&: x1 = 436: y1 = 362: x2 = 629: y2 = 390: GOSUB tekengat: dwt = 0: GOSUB ResetFiles
IF x > 438 AND x < 627 AND Y > 326 AND Y < 350 THEN _SNDPLAY Click&: x1 = 436: y1 = 324: x2 = 629: y2 = 352: GOSUB tekengat: dwt = 0: GOSUB Analysis
IF x > 438 AND x < 627 AND Y > 288 AND Y < 312 THEN _SNDPLAY Click&: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekengat: dwt = 0: GOTO eindeFLY
IF x > 438 AND x < 627 AND Y > 250 AND Y < 274 THEN _SNDPLAY Click&: x1 = 436: y1 = 248: x2 = 629: y2 = 276: GOSUB tekengat: dwt = 0: GOSUB Info
' If x > 438 And x < 627 And Y > 250 And Y < 274 Then _SndPlay Click&: x1 = 436: y1 = 248: x2 = 629: y2 = 276: GoSub tekengat: dwt = 0: GoSub ReadMe
IF x > 438 AND x < 627 AND Y > 212 AND Y < 236 THEN _SNDPLAY Click&: x1 = 436: y1 = 210: x2 = 629: y2 = 238: GOSUB tekengat: dwt = 0: GOSUB ViewAchievements
IF x > 438 AND x < 627 AND Y > 174 AND Y < 198 THEN _SNDPLAY Click&: x1 = 436: y1 = 172: x2 = 629: y2 = 200: GOSUB tekengat: dwt = 0: GOSUB HallOfFame
GOTO hl0

swapScreen: '
PLAY "v" + Pct$ + "MBl32o3a"
OPEN "..\TXTFiles\DISPLAYM.TXT" FOR INPUT AS #11
INPUT #11, screen$
CLOSE #11
IF screen$ = "WINDOWED" THEN screen$ = "FULLSCREEN": GOSUB WriteSettings: GOTO label
IF screen$ = "FULLSCREEN" THEN screen$ = "WINDOWED": GOSUB WriteSettings: GOTO label
label:
IF full = 1 THEN _FULLSCREEN _OFF: _SCREENMOVE _MIDDLE: full = 0: RETURN
IF full = 0 THEN _FULLSCREEN _SQUAREPIXELS , _SMOOTH: full = 1: RETURN
WriteSettings:
OPEN "..\TXTFiles\DISPLAYM.TXT" FOR OUTPUT AS #11
PRINT #11, screen$
CLOSE #11
RETURN





'
drawCurrentBlackbox:
OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #1 '                    Blackbox
IF EOF(1) THEN CLOSE #1: Tmax = 0: RETURN '
DO WHILE NOT EOF(1)
    INPUT #1, N, x#, y#, z#, fuel#, ammo, heading, snelheid
    xxx#(N) = x#: yyy#(N) = y#: zzz#(N) = z#: fuel#(N) = fuel#: ammo(N) = ammo: heading(N) = heading: snelheid(N) = snelheid
    xx = 220 + 8 * x# / 100: xNader(N) = xx
    zz = 220 - 8 * z# / 100: zNader(N) = zz
    IF xx < 14 THEN xx = 14
    IF xx > 425 THEN xx = 425
    IF zz < 15 THEN zz = 15
    IF zz > 425 THEN zz = 425
    IF N = 0 THEN
        PSET (xx, zz), 13
    ELSE
        LINE -(xx, zz), 13
    END IF
LOOP
Tmax = N
CLOSE #1

RETURN

drawCurrentBB:

bbbb$ = LTRIM$(STR$(CURHISCO))
IF LEN(bbbb$) < 2 THEN bbbb$ = "0" + bbbb$
OPEN "..\TXTFiles\BB" + bbbb$ + ".TXT" FOR INPUT AS #1 '                    Blackbox
IF EOF(1) THEN CLOSE #1: Tmax = 0: RETURN '
DO WHILE NOT EOF(1)
    INPUT #1, N, x#, y#, z#, fuel#, ammo, heading, snelheid
    xxx#(N) = x#: yyy#(N) = y#: zzz#(N) = z#: fuel#(N) = fuel#: ammo(N) = ammo: heading(N) = heading: snelheid(N) = snelheid
    xx = 220 + 8 * x# / 100: xNader(N) = xx
    zz = 220 - 8 * z# / 100: zNader(N) = zz
    IF xx < 14 THEN xx = 14
    IF xx > 425 THEN xx = 425
    IF zz < 15 THEN zz = 15
    IF zz > 425 THEN zz = 425
    IF N = 0 THEN
        PSET (xx, zz), 13
    ELSE
        LINE -(xx, zz), 13
    END IF
LOOP
Tmax = N
CLOSE #1
RETURN

OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #1 '                    Blackbox
IF EOF(1) THEN CLOSE #1: Tmax = 0: RETURN '
DO WHILE NOT EOF(1)
    INPUT #1, N, x#, y#, z#, fuel#, ammo, heading, snelheid
    xxx#(N) = x#: yyy#(N) = y#: zzz#(N) = z#: fuel#(N) = fuel#: ammo(N) = ammo: heading(N) = heading: snelheid(N) = snelheid
    xx = 220 + 8 * x# / 100: xNader(N) = xx
    zz = 220 - 8 * z# / 100: zNader(N) = zz
    IF xx < 14 THEN xx = 14
    IF xx > 425 THEN xx = 425
    IF zz < 15 THEN zz = 15
    IF zz > 425 THEN zz = 425
    IF N = 0 THEN
        PSET (xx, zz), 13
    ELSE
        LINE -(xx, zz), 13
    END IF
LOOP
Tmax = N
CLOSE #1
RETURN

OPEN "..\TXTFiles\BLACKBOX.TXT" FOR INPUT AS #1 '                    Blackbox
DO WHILE NOT EOF(1)
    INPUT #1, N, x#, y#, z#, fuel#, ammo, heading, snelheid
    xxx#(N) = x#: yyy#(N) = y#: zzz#(N) = z#: fuel#(N) = fuel#: ammo(N) = ammo: heading(N) = heading: snelheid(N) = snelheid
    xx = 220 + 8 * x# / 100: xNader(N) = xx
    zz = 220 - 8 * z# / 100: zNader(N) = zz
    IF xx < 14 THEN xx = 14
    IF xx > 425 THEN xx = 425
    IF zz < 15 THEN zz = 15
    IF zz > 425 THEN zz = 425
    IF N = 0 THEN
        PSET (xx, zz), 13
    ELSE
        LINE -(xx, zz), 13
    END IF
LOOP
Tmax = N
CLOSE #1
RETURN

CalculateDistance:
Distance& = 0
FOR talt = 1 TO Tmax
    Distance& = Distance& + _HYPOT(xxx#(talt) - xxx#(talt - 1), zzz#(talt) - zzz#(talt - 1))
NEXT
RETURN

Analysis:
'
LO = 1: PUT (608, 333), LedOn(0), PSET
IF Tmax = 0 THEN
    TIMER OFF
    waarde$ = "NO FLIGHT DATA": dx = 533: dy = 80: GOSUB PlaatsTekstCentered
    TIMER ON
    WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
    WHILE b = 0: Mouse 3: _LIMIT OverallFramerate: WEND
    '  _SndPlay Click&
    TIMER OFF
    PUT (439, 14), logo(0), PSET
    x1 = 436: y1 = 324: x2 = 629: y2 = 352: GOSUB tekenblok
    LO = 0: PUT (608, 333), LedOff(0), PSET
    PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
    TIMER ON
    WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
    RETURN
END IF



t = 0
GET (439, 92)-(626, 130), tekstachtergrond(0)

WHILE INKEY$ <> "": WEND '                  Flush keyboard
TIMER OFF
LINE (443, 18)-(443, 86), 15 '              Grafiek
LINE -(622, 86), 15
LINE -(622, 18), 15
TIMER ON
LINE (444, 18)-(621, 18), 16
LINE (444, 35)-(621, 35), 16
LINE (444, 52)-(621, 52), 16
LINE (444, 69)-(621, 69), 16
FOR xg = 461 TO 605 STEP 18
    LINE (xg, 18)-(xg, 85), 16
NEXT

'                                         Knoppen
x1 = 442: x2 = 482: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
x1 = 488: x2 = 530: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
x1 = 536: x2 = 577: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
x1 = 583: x2 = 623: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
TIMER OFF
waarde$ = "-10S": dx = 462: dy = 142: GOSUB PlaatsTekstCentered
waarde$ = "-1S": dx = 509: dy = 142: GOSUB PlaatsTekstCentered
waarde$ = "+1S": dx = 556: dy = 142: GOSUB PlaatsTekstCentered
waarde$ = "+10S": dx = 604: dy = 142: GOSUB PlaatsTekstCentered

m$ = LTRIM$(STR$(t \ 60))
s$ = LTRIM$(STR$(t MOD 60))
WHILE LEN(m$) < 2: m$ = "0" + m$: WEND
WHILE LEN(s$) < 2: s$ = "0" + s$: WEND
t$ = m$ + ":" + s$
yy# = yyy#(t)

PUT (439, 92), tekstachtergrond(0), PSET
waarde$ = "TIME: " + t$: dx = 468: dy = 97: GOSUB PlaatsTekstLinksUitlijn
LINE (453, 110)-(455, 110), 13: LINE (457, 110)-(459, 110), 13: LINE (461, 110)-(463, 110), 13
a$ = LTRIM$(STR$(INT(yy#)))
WHILE LEN(a$) < 4: a$ = "0" + a$: WEND
waarde$ = "ALT.: " + a$ + " FT": dx = 468: dy = 107: GOSUB PlaatsTekstLinksUitlijn
LINE (453, 120)-(455, 120), 3: LINE (457, 120)-(459, 120), 3: LINE (461, 120)-(463, 120), 3
a$ = LTRIM$(STR$(INT(fuel#(t))))
WHILE LEN(a$) < 4: a$ = "0" + a$: WEND
waarde$ = "FUEL: " + a$ + " GL": dx = 468: dy = 117: GOSUB PlaatsTekstLinksUitlijn

FOR talt = 0 TO Tmax
    xdot = 444 + 176 * talt / Tmax
    yfueldot = 85 - 68 / 400 * fuel#(talt)
    ydot = 85 - 68 / 400 * yyy#(talt)
    IF ydot < 18 THEN ydot = 18
    PSET (xdot, yfueldot), 3
    PSET (xdot, ydot), 13
NEXT
TIMER ON

heuh:
xdot = 444 + 177 * t / Tmax
ydot = 85 - 68 / 400 * yyy#(t)
IF xdot < 444 THEN xdot = 444
IF ydot < 18 THEN ydot = 18
GET (xdot - 2, ydot - 2)-(xdot + 2, ydot + 2), balparkR(0)
CIRCLE (xdot, ydot), dotstraal!, 10: PAINT (xdot, ydot), 10
PSET (xdot + 1, ydot - 1), 5
xx1 = 220 + 8 * xxx#(t) / 100
zz1 = 220 - 8 * zzz#(t) / 100
IF xx1 < 16 THEN xx1 = 16
IF xx1 > 423 THEN xx1 = 423
IF zz1 < 17 THEN zz1 = 17
IF zz1 > 423 THEN zz1 = 423
GET (xx1 - straaltje, zz1 - straaltje)-(xx1 + straaltje, zz1 + straaltje), balparkL(0)
CIRCLE (xx1, zz1), dotstraal!, 10: PAINT (xx1, zz1), 10
PSET (xx1 + 1, zz1 - 1), 5
xx2 = xx1 + (straaltje - 1) * SIN(heading(t) / pf#)
zz2 = zz1 - (straaltje - 1) * COS(heading(t) / pf#)
LINE (xx1, zz1)-(xx2, zz2), 10
m$ = LTRIM$(STR$(t \ 60))
s$ = LTRIM$(STR$(t MOD 60))
WHILE LEN(m$) < 2: m$ = "0" + m$: WEND
WHILE LEN(s$) < 2: s$ = "0" + s$: WEND
t$ = m$ + ":" + s$
yy# = yyy#(t)
PUT (439, 92), tekstachtergrond(0), PSET
TIMER OFF
waarde$ = "TIME: " + t$: dx = 468: dy = 97: GOSUB PlaatsTekstLinksUitlijn
LINE (453, 110)-(455, 110), 13: LINE (457, 110)-(459, 110), 13: LINE (461, 110)-(463, 110), 13
a$ = LTRIM$(STR$(INT(yy#)))
WHILE LEN(a$) < 4: a$ = "0" + a$: WEND
waarde$ = "ALT.: " + a$ + " FT": dx = 468: dy = 107: GOSUB PlaatsTekstLinksUitlijn
LINE (453, 120)-(455, 120), 3: LINE (457, 120)-(459, 120), 3: LINE (461, 120)-(463, 120), 3
a$ = LTRIM$(STR$(INT(fuel#(t))))
WHILE LEN(a$) < 4: a$ = "0" + a$: WEND
waarde$ = "FUEL: " + a$ + " GL": dx = 468: dy = 117: GOSUB PlaatsTekstLinksUitlijn
' ****************************
CIRCLE (596, 113), naaldlengte + 4, 15, 1.75 * pi#, 1.25 * pi#
LINE (596, 113 - (naaldlengte + 1))-(596, 113 - (naaldlengte + 4)), 15
Alpha# = snelheid(t) / 38.197
LINE (596, 113)-(596 + naaldlengte * SIN(Alpha#), 113 - naaldlengte * COS(Alpha#)), 10
waarde$ = "V": dx = 593: dy = 117: GOSUB PlaatsTekstLinksUitlijn
'********************************
TIMER ON

DO
    _LIMIT OverallFramerate
    IF INKEY$ = CHR$(27) THEN MouseRelease = 0: GOTO label2 '                exit
    Mouse 3
    SELECT CASE b
        CASE 0
            MouseRelease = 1
        CASE 1
            'SndPlay
            IF MouseRelease = 1 THEN
                IF h > 438 AND v > 160 THEN
                    'MouseRelease = 0
                    GOTO label2 '                exit
                END IF
            END IF
            IF MouseRelease = 1 THEN
                'MouseRelease = 0
                GOSUB CheckButtonsAndScreen
                GOTO label2
            END IF
    END SELECT
LOOP

label2:
IF MinibuttonChoice <> 0 THEN

    SELECT CASE MinibuttonChoice
        CASE 2
            IF t <= 0 THEN

                PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
                PUT (xdot - 2, ydot - 2), balparkR(0), PSET

                GOSUB tekenNP

            ELSE
                PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
                PUT (xdot - 2, ydot - 2), balparkR(0), PSET
                t = t - 1
                GOSUB tekenNP
            END IF
        CASE 3
            IF t >= Tmax THEN

                PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
                PUT (xdot - 2, ydot - 2), balparkR(0), PSET

                GOSUB tekenNP
            ELSE
                PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
                PUT (xdot - 2, ydot - 2), balparkR(0), PSET
                t = t + 1
                GOSUB tekenNP
            END IF
    END SELECT
END IF

label21:
PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
PUT (xdot - 2, ydot - 2), balparkR(0), PSET
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
MouseRelease = 0
PUT (439, 14), logo(0), PSET
x1 = 436: y1 = 324: x2 = 629: y2 = 352: GOSUB tekenblok
LO = 0: PUT (608, 333), LedOff(0), PSET
PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
WHILE INKEY$ <> "": WEND '                  Flush keyboard
RETURN

'



CheckButtonsAndScreen:
MinibuttonChoice = 0
IF h > 442 AND h < 482 AND v > 134 AND v < 156 THEN '-10
    x1 = 442: x2 = 482: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 15, B
    _SNDPLAY Click&
    WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
    MinibuttonChoice = 1
    '_SndPlay Click&
    t = t - 10
    IF t < 0 THEN t = 0
    x1 = 442: x2 = 482: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
END IF
IF h > 488 AND h < 530 AND v > 134 AND v < 156 THEN '- 1
    x1 = 488: x2 = 530: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 15, B
    _SNDPLAY Click&
    WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
    MinibuttonChoice = 2
    '_SndPlay Click&
    t = t - 1
    IF t < 0 THEN t = 0
    x1 = 488: x2 = 530: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
END IF
IF h > 536 AND h < 577 AND v > 134 AND v < 156 THEN '+ 1
    x1 = 536: x2 = 577: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 15, B
    _SNDPLAY Click&
    WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
    MinibuttonChoice = 3
    '_SndPlay Click&
    t = t + 1
    IF t > Tmax THEN t = Tmax
    x1 = 536: x2 = 577: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
END IF
IF h > 583 AND h < 623 AND v > 134 AND v < 156 THEN '+ 10
    x1 = 583: x2 = 623: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 15, B
    _SNDPLAY Click&
    WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
    MinibuttonChoice = 4
    '_SndPlay Click&
    t = t + 10
    IF t > Tmax THEN t = Tmax
    x1 = 583: x2 = 623: y1 = 134: y2 = 156: LINE (x1 + 2, y1 + 2)-(x2 - 2, y2 - 2), 16, B
END IF
IF h > 443 AND h < 622 AND v > 18 AND v < 86 THEN 'In Grafiek
    t = INT(((h - 444) / 177) * Tmax)
    IF t < 0 THEN t = 0
    IF t > Tmax THEN t = Tmax
END IF

IF h > 12 AND h < 428 AND v > 12 AND v < 428 THEN ' Op kaart
    record# = 1000
    FOR tNieuw = 0 TO Tmax
        Nieuw# = _HYPOT(h - xNader(tNieuw), v - zNader(tNieuw))
        IF Nieuw# < record# THEN t = tNieuw: record# = Nieuw#
    NEXT
    IF t < 0 THEN t = 0
    IF t > Tmax THEN t = Tmax
END IF
TIMER OFF
PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
PUT (xdot - 2, ydot - 2), balparkR(0), PSET
TIMER ON

RETURN heuh

tekenNP:
xdot = 444 + 177 * t / Tmax
ydot = 85 - 68 / 400 * yyy#(t)
IF ydot < 18 THEN ydot = 18
GET (xdot - 2, ydot - 2)-(xdot + 2, ydot + 2), balparkR(0)
CIRCLE (xdot, ydot), dotstraal!, 10: PAINT (xdot, ydot), 10
PSET (xdot + 1, ydot - 1), 5
xx1 = 220 + 8 * xxx#(t) / 100
zz1 = 220 - 8 * zzz#(t) / 100
IF xx1 < 16 THEN xx1 = 16
IF xx1 > 423 THEN xx1 = 423
IF zz1 < 17 THEN zz1 = 17
IF zz1 > 423 THEN zz1 = 423
GET (xx1 - straaltje, zz1 - straaltje)-(xx1 + straaltje, zz1 + straaltje), balparkL(0)
CIRCLE (xx1, zz1), dotstraal!, 10: PAINT (xx1, zz1), 10
PSET (xx1 + 1, zz1 - 1), 5
RETURN

Info:
TIMER OFF
WHILE INKEY$ <> "": WEND '                  Flush keyboard
'
LO = 1: PUT (608, 257), LedHalf(0), PSET

'

x1 = 25: y1 = 35: x2 = 415: y2 = 419
GET (x1 - 3, y1 - 3)-(x2 + 3, y2 + 3), Bigger&(0)


x1 = 65: x2 = 375: y1 = 103: y2 = 335
GOSUB tekenblok

LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF
x1 = 70: x2 = 370: y1 = 108: y2 = 330
GOSUB tekengat
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF



'
dx = 221: dy = 120: waarde$ = "SCORE TABLE": GOSUB PlaatsTekstCentered
dx = 221: dy = 136: waarde$ = "------------------------------------------": GOSUB PlaatsTekstCentered
dx = 110: dy = 156: waarde$ = "RESCUES            1,000 PTS": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 166: waarde$ = "             BONUS 5,000 PTS / ALL": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 186: waarde$ = "                     100 PTS": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 196: waarde$ = "ENEMIES              150 PTS": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 206: waarde$ = "                     ... PTS": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 226: waarde$ = "OBJECTS                5 PTS": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 236: waarde$ = "             BONUS   100 PTS / 25%": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 246: waarde$ = "             BONUS   500 PTS / ALL": GOSUB PlaatsTekstLinksUitlijn
dx = 110: dy = 266: waarde$ = "TIME BONUS            10 PTS / SEC": GOSUB PlaatsTekstLinksUitlijn
dx = 221: dy = 294: waarde$ = "------------------------------------------": GOSUB PlaatsTekstCentered
dx = 221: dy = 311: waarde$ = "PRESS BUTTON": GOSUB PlaatsTekstCentered
PUT (236, 188), Accolade(0), PSET
'
PUT (357, 324), Page1(0), PSET


















MouseRelease = 0
TIMER ON
DO
    _LIMIT OverallFramerate
    Mouse 3
    IF INKEY$ <> "" GOTO label3
    SELECT CASE b
        CASE 0
            MouseRelease = 1
        CASE 1
            IF MouseRelease = 1 THEN
                MouseRelease = 0
                GOTO label3 '                exit
            END IF
    END SELECT
LOOP
label3:
_SNDPLAY Click&
helptekst:
'
LO = 1: PUT (608, 257), LedOn(0), PSET
'
TIMER OFF
x1 = 25: y1 = 32: x2 = 415: y2 = 416: GOSUB tekenblok
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF

x1 = 30: y1 = 37: x2 = 410: y2 = 411
LINE (x1, y1)-(x2, y2), 0, BF
GOSUB tekengat

'afmetingen background: (213,113)-(586,481)  ----> 374 x 369
dx = 221: dy = 46
waarde$ = "IN-GAME KEYS / CONTROL"
GOSUB PlaatsTekstCentered
dx = 221: dy = 58
waarde$ = "-----------------------------------------------------"
GOSUB PlaatsTekstCentered
dx = 221: dy = 78
waarde$ = "MOUSE CONTROLS"
GOSUB PlaatsTekstCentered
dx = 221: dy = 98
waarde$ = "       LEFT BUTTON .......... COLLECTIVE UP          "
GOSUB PlaatsTekstCentered
dx = 221: dy = 108
waarde$ = "       RIGHT BUTTON ......... COLLECTIVE DOWN        "
GOSUB PlaatsTekstCentered
dx = 221: dy = 118
waarde$ = "       MOUSE MOVEMENT ....... CYCLIC                 "
GOSUB PlaatsTekstCentered
dx = 221: dy = 138
waarde$ = "KEYBOARD"
GOSUB PlaatsTekstCentered
dx = 221: dy = 158
waarde$ = "       \A\ .................. COLLECTIVE UP          "
GOSUB PlaatsTekstCentered
dx = 221: dy = 168
waarde$ = "       \Z\ .................. COLLECTIVE DOWN        "
GOSUB PlaatsTekstCentered
dx = 221: dy = 178
waarde$ = "       ARROW KEYS ........... CYCLIC                 "
GOSUB PlaatsTekstCentered
dx = 221: dy = 188
waarde$ = "       SPACEBAR ............. FIRE CANNON            "
GOSUB PlaatsTekstCentered
dx = 221: dy = 198
waarde$ = "       \H\ .................. HELP                   "
GOSUB PlaatsTekstCentered
dx = 221: dy = 208
waarde$ = "       \M\ .................. SHOW MAP               "
GOSUB PlaatsTekstCentered
dx = 221: dy = 218
waarde$ = "       \.\ .................. NEXT WAYPOINT          "
GOSUB PlaatsTekstCentered
dx = 221: dy = 228
waarde$ = "       \,\ .................. PREVIOUS WAYPOINT      "
GOSUB PlaatsTekstCentered
dx = 221: dy = 238
waarde$ = "       \T\ .................. VIEW RESCUE TASKS      "
GOSUB PlaatsTekstCentered
dx = 221: dy = 248
waarde$ = "       \S\ .................. VIEW SUPPLIES          "
GOSUB PlaatsTekstCentered
dx = 221: dy = 258
waarde$ = "       \O\ .................. VIEW OBJECTS REMAINING "
GOSUB PlaatsTekstCentered
dx = 221: dy = 268
waarde$ = "       \G\ .................. HIDE/SHOW GPS          "
GOSUB PlaatsTekstCentered
dx = 221: dy = 278
waarde$ = "       \Q\ .................. HIDE/SHOW CURSOR       "
GOSUB PlaatsTekstCentered
dx = 221: dy = 288
waarde$ = "       \B\ .................. HIDE/SHOW ROTOR BLADES "
GOSUB PlaatsTekstCentered
dx = 221: dy = 298
waarde$ = "       TAB .................. TOGGLE FULLSCREEN      "
GOSUB PlaatsTekstCentered
dx = 221: dy = 308
waarde$ = "       \C\ .................. TOGGLE CONTROL TYPE    "
GOSUB PlaatsTekstCentered
dx = 221: dy = 318
waarde$ = "       \I\ .................. INVERT CONTROLS        "
GOSUB PlaatsTekstCentered
dx = 221: dy = 328
waarde$ = "       \P\ .................. PAUSE GAME             "
GOSUB PlaatsTekstCentered
dx = 221: dy = 338
waarde$ = "       ESC .................. ABORT GAME             "
GOSUB PlaatsTekstCentered
dx = 358: dy = 371
waarde$ = "V1.6.19"
GOSUB PlaatsTekstLinksUitlijn
dx = 221: dy = 378
waarde$ = "-----------------------------------------------------"
GOSUB PlaatsTekstCentered
dx = 221: dy = 393
waarde$ = "PRESS BUTTON TO RETURN"
GOSUB PlaatsTekstCentered
'
PUT (397, 405), Page2(0), PSET






















TIMER ON
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
WHILE b = 0 AND INKEY$ = "": Mouse 3: _LIMIT OverallFramerate: WEND
TIMER OFF
PUT (22, 32), Bigger&(0), PSET
x1 = 436: y1 = 248: x2 = 629: y2 = 276: GOSUB tekenblok
LO = 0: PUT (608, 257), LedOff(0), PSET
WHILE INKEY$ <> "": WEND
MouseRelease = 0
TIMER ON
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
RETURN

ViewAchievements:
'
vv = 1
TIMER OFF
LO = 1: PUT (608, 219), LedOn(0), PSET
waarde$ = "ACHIEVEMENTS"
dx = 440: dy = 221: GOSUB PlaatsZwartOpGrijs
_DISPLAY
_DELAY (.1)
GET (439, 14)-(626, 159), Big&(0)
'
IF aantallocked(locknr) = 7 THEN
    waarde$ = "INSUFFICIENT INTEL": dx = 533: dy = 80: GOSUB PlaatsTekstCentered
    TIMER ON
    WHILE b = 1: Mouse 3: _LIMIT OverallFramerate: _DISPLAY: WEND '       Flush Mouse
    WHILE b <> 1 AND INKEY$ <> CHR$(27): Mouse 3: _LIMIT OverallFramerate: _DISPLAY: WEND
    GOTO BackFurtherlabel
END IF

FOR k = 7 TO 1 STEP -1
    IF LLock(locknr, k) = 0 THEN Enemynummer(locknr) = k
NEXT


BackBack: '
SELECT CASE Enemynummer(locknr)

    CASE 1 '                                                Truck
        schaaly# = 2 * .625
        schaalx# = 2
        xc0# = 10: yc0# = 1: zc0# = 0 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 2: zc5# = -1 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                       roteercentrum

    CASE 2 '                                                Sportscar
        schaaly# = 3 * .625
        schaalx# = 3
        xc0# = 10: yc0# = 1: zc0# = 1 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 1: zc5# = 0 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                       roteercentrum

    CASE 3 '                                                Jeep
        schaaly# = 3 * .625
        schaalx# = 3
        xc0# = 10: yc0# = 1: zc0# = 1 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 1: zc5# = 0 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                       roteercentrum

    CASE 4 '                                                Tank
        schaaly# = 2 * .625
        schaalx# = 2
        xc0# = 10: yc0# = 1: zc0# = 1 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 2: zc5# = 0 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                       roteercentrum

    CASE 5 '                                                Tree
        schaaly# = 3 * .625
        schaalx# = 3
        xc0# = 10: yc0# = 1: zc0# = -6 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 2: zc5# = -7 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                         roteercentrum

    CASE 6 '                                                Shed
        schaaly# = 3 * .625
        schaalx# = 3
        xc0# = 10: yc0# = 1: zc0# = -10 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 2: zc5# = -11 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                         roteercentrum

    CASE 7 '                                                Heap
        schaaly# = 2 * .625
        schaalx# = 2
        xc0# = 10: yc0# = 1: zc0# = -6 'in :xc0#,yc0#,zc0#   Midden tafereel
        xc5# = 10: yc5# = 2: zc5# = -7 '    xc5#,yc5#,zc5#   Oog
        xb# = 10: yb# = 2: zb# = 10 '                         roteercentrum

END SELECT



'
Bestand$ = "..\ITMFiles\ENEMY" + "0" + LTRIM$(STR$(Enemynummer(locknr))) + ".ITM"

IF Enemynummer(locknr) = 5 THEN Bestand$ = "..\ITMFiles\OBJECT01.ITM"
IF Enemynummer(locknr) = 6 THEN Bestand$ = "..\ITMFiles\OBJECT02.ITM"
IF Enemynummer(locknr) = 7 THEN Bestand$ = "..\ITMFiles\OBJECT03.ITM"

GOSUB LoadEnemy

hs# = pi# '
FOR Vlak = 0 TO Vlakken - 1
    FOR pn = 1 TO 4
        xa# = x#(Vlak, pn): ya# = y#(Vlak, pn): za# = z#(Vlak, pn)
        GOSUB draaiy
        x#(Vlak, pn) = xa#: y#(Vlak, pn) = ya#: z#(Vlak, pn) = za#
    NEXT
NEXT

TIMER ON
Backlabel:
_LIMIT OverallFramerate / 2
PUT (439, 14), Big&(0), PSET 'Achtergronheli

IF LLock(locknr, Enemynummer(locknr)) = 0 THEN GOSUB TekenVijand '


IF INKEY$ = CHR$(27) GOTO BackFurtherlabel
TIMER OFF
SELECT CASE Enemynummer(locknr)
    CASE 1 AND LLock(locknr, 1) = 0
        waarde$ = "SUPPLY TRUCK": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
        GET (487, 72)-(517 + 91, 72 + 12), DontShoottextBackground(0)
        PUT (487, 72), DontShoottextMask(0), AND
        PUT (487, 72), DontShoottext(0), XOR
    CASE 2 AND LLock(locknr, 2) = 0
        waarde$ = "SPORTSCAR DRONE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 3 AND LLock(locknr, 3) = 0
        waarde$ = "JEEP DRONE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 4 AND LLock(locknr, 4) = 0
        waarde$ = "TANK DRONE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 5 AND LLock(locknr, 5) = 0
        waarde$ = "DEAD TREE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 6 AND LLock(locknr, 6) = 0
        waarde$ = "SHED": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 7 AND LLock(locknr, 7) = 0
        waarde$ = "HEAP": dx = 533: dy = 135: GOSUB PlaatsTekstCentered





END SELECT
TIMER ON
_DISPLAY
WHILE b = 1: Mouse 3: _LIMIT OverallFramerate: _DISPLAY: WEND '       Flush Mouse
Mouse 3
IF b = 1 GOTO Verderlabel '
'   IF b = 1 THEN _SndPlay Click&: GOTO Verderlabel '
hs# = pi# / 128
'

FOR Vlak = 0 TO Vlakken - 1
    FOR pn = 1 TO 4
        xa# = x#(Vlak, pn): ya# = y#(Vlak, pn): za# = z#(Vlak, pn)
        GOSUB draaiy
        x#(Vlak, pn) = xa#: y#(Vlak, pn) = ya#: z#(Vlak, pn) = za#
    NEXT
NEXT
LINE (439, 14)-(626, 159), 0, BF
GOTO Backlabel

Verderlabel:
'
IF h >= 439 AND h <= 626 AND v >= 14 AND v <= 159 THEN _SNDPLAY Click& '
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: _DISPLAY: WEND '       Flush Mouse
IF h >= 439 AND h <= 626 AND v >= 14 AND v <= 159 THEN

    '    Aantalvrij     (=2)
    tjap:
    Enemynummer(locknr) = Enemynummer(locknr) + 1
    IF Enemynummer(locknr) = 8 THEN Enemynummer(locknr) = 1
    IF LLock(locknr, Enemynummer(locknr)) = 1 GOTO tjap

    GOTO BackBack
END IF

BackFurtherlabel:

_AUTODISPLAY
PUT (439, 14), Big&(0), PSET
x1 = 436: y1 = 210: x2 = 629: y2 = 238: GOSUB tekenblok
LO = 0: PUT (608, 219), LedOff(0), PSET
_DELAY .1
_AUTODISPLAY
WHILE INKEY$ <> "": WEND
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: _DISPLAY: WEND '       Flush Mouse
vv = 0
RETURN

ResetFiles:
_AUTODISPLAY
TIMER OFF
LO = 1: PUT (608, 371), LedOn(0), PSET
waarde$ = "RESET FILES"
dx = 440: dy = 373: GOSUB PlaatsZwartOpGrijs
_DELAY (.1)

GOSUB systeemeinde2

CHAIN "Reset.exe"


waarde$ = "SELECT SCENERY"
dx = 533: dy = 20: GOSUB PlaatsTekstCentered
waarde$ = "-------------------------"
dx = 533: dy = 30: GOSUB PlaatsTekstCentered
FOR N = 1 TO MaxScenes
    nummer$ = RIGHT$(STR$(N), LEN(STR$(N)) - 1)
    WHILE LEN(nummer$) < 2: nummer$ = "0" + nummer$: WEND
    vergelijk$ = "SCENE" + nummer$ + ".ITM"
    IF _FILEEXISTS("..\ITMFiles\" + vergelijk$) = -1 THEN
        waarde$ = vergelijk$ + " " + tiles$(N) + " TILES": dx = 535: dy = 40 + (N - 1) * 10
        GOSUB PlaatsTekstCentered
    END IF
NEXT
waarde$ = "-------------------------"
dx = 533: dy = 140: GOSUB PlaatsTekstCentered
TIMER ON
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND '       Flush Mouse
DO
    _LIMIT OverallFramerate
    IF INKEY$ = CHR$(27) GOTO hulp5 '          exit
    Mouse 3
    SELECT CASE b
        CASE 0
            MouseRelease = 1
        CASE 1
            IF MouseRelease = 1 THEN

                IF h < 439 OR h > 626 OR v < 37 OR v > 135 THEN
                    MouseRelease = 0
                    GOTO hulp5 '                exit
                END IF
            END IF
            IF MouseRelease = 1 THEN
                MouseRelease = 0
                nummer$ = RIGHT$(STR$(AspirantNr), LEN(STR$(AspirantNr)) - 1)
                IF LEN(nummer$) < 2 THEN nummer$ = "0" + nummer$
                vergelijk$ = "SCENE" + nummer$ + ".ITM"
                CurrentITM$ = vergelijk$
                GOTO hulp4
            END IF
    END SELECT
    AspirantNr = (v - 16) \ 10 - 1
LOOP
hulp4:
GOSUB Glow1
IF _FILEEXISTS("..\ITMFiles\" + CurrentITM$) = 0 GOTO hulp5
OPEN "..\TXTFiles\CURRENT.TXT" FOR OUTPUT AS #5
PRINT #5, CurrentITM$
CLOSE #5
OPEN "..\TXTFiles\BLACKBOX.TXT" FOR OUTPUT AS #1
CLOSE #1
FOR t = 0 TO maxseconds
    xxx#(t) = 0: yyy#(t) = 0: zzz#(t) = 0: fuel#(t) = 0: ammo(t) = 0
NEXT
t = 0
_DELAY .1
PUT (xx1 - straaltje, zz1 - straaltje), balparkL(0), PSET
RETURN hulp6
hulp5:
PUT (439, 14), logo(0), PSET
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND
x1 = 436: y1 = 210: x2 = 629: y2 = 238: GOSUB tekenblok
LO = 0: PUT (608, 219), LedOff(0), PSET
RETURN

PlaatsTekstCentered:
'
IF LEFT$(waarde$, 1) = " " THEN waarde$ = RIGHT$(waarde$, LEN(waarde$) - 1)
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx - LEN(waarde$) * 3.5
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + (strp - 1) * 7, dy), v(nch * grootte), OR
NEXT
waarde$ = ""
RETURN

PlaatsTekstRechtsUitlijn:
waarde$ = LTRIM$(waarde$)
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx - LEN(waarde$) * 7
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + (strp - 1) * 7, dy), v(nch * grootte), OR
NEXT
waarde$ = ""
RETURN

PlaatsZwartOpGrijs:
IF LEFT$(waarde$, 1) = " " THEN waarde$ = RIGHT$(waarde$, LEN(waarde$) - 1)
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + strp * 7, dy), w(nch * grootte), PSET
NEXT
waarde$ = ""
RETURN

PlaatsZwartOpGrijsCentered:
IF LEFT$(waarde$, 1) = " " THEN waarde$ = RIGHT$(waarde$, LEN(waarde$) - 1)
IF waarde$ = "" THEN waarde$ = "TEXT ERROR"
ddx = dx - LEN(waarde$) * 3.5
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (ddx + (strp - 1) * 7, dy), w(nch * grootte), PSET
NEXT
waarde$ = ""
RETURN



tekenblok:
LINE (x1, y1)-(x2 - 1, y1), 4
LINE (x2, y1)-(x2, y2 - 1), 4
LINE (x2, y2)-(x1 + 1, y2), 2
LINE (x1, y2)-(x1, y1 + 1), 2
RETURN

tekengat:
LINE (x1, y1)-(x2 - 1, y1), 2
LINE (x2, y1)-(x2, y2 - 1), 2
LINE (x2, y2)-(x1 + 1, y2), 4
LINE (x1, y2)-(x1, y1 + 1), 4
RETURN

pulse: '
memoryprotection& = memoryprotection& + 1
IF memoryprotection& >= MPSeconds& / LichtkrantPulseTijd# THEN CHAIN "Menu.exe" '
IF stp1st = 1 THEN PUT (629, 451), stukjepark(0), PSET
dx = 633 - onetoseventeller
dy = 451
IF stp1st = 0 THEN waardeLK$ = " ": dx = 628
GOSUB PlaatsTekstLinksUitlijnLichtkrant
stp1st = 1
onetoseventeller = onetoseventeller + 1
IF onetoseventeller = 7 THEN
    onetoseventeller = 0
    pointer = pointer + 1
    IF pointer = 2 THEN dwt = 0
    IF pointer > LEN(totaal$) THEN

        pointer = 1
        totaalkeerlichtkrant = totaalkeerlichtkrant + 1
        dwt = 1
        '
        IF totaalkeerlichtkrant = 9 THEN CHAIN "MENU.EXE"

    END IF
    '
    IF dwt = 1 AND LO = 0 THEN dwt = 0
    waardeLK$ = MID$(totaal$, pointer, 1)
END IF
GET (12, 451)-(639, 457), t(0)
PUT (11, 451), t(0), PSET
GET (629, 451)-(639, 457), stukjepark(0)
PUT (629, 451), stukje(0), PSET
IF vv = 0 THEN _DISPLAY '
IF waardeLK$ = "^" THEN waardeLK$ = " ": GOSUB lichtkrantpause

RETURN

lichtkrantpause:
PUT (439, 14), Big&(0), PSET 'Achtergronheli

IF LLock(locknr, Enemynummer(locknr)) = 0 THEN GOSUB TekenVijand '





TIMER OFF
SELECT CASE Enemynummer(locknr)
    CASE 1
        waarde$ = "SUPPLY TRUCK": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
        GET (517, 61)-(517 + 31, 61 + 31), DontShootBackground(0)
        PUT (517, 61), DontShootMask(0), AND
        PUT (517, 61), DontShoot(0), XOR
    CASE 2
        waarde$ = "SPORTSCAR DRONE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 3
        waarde$ = "JEEP DRONE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 4
        waarde$ = "TANK DRONE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 5
        waarde$ = "DEAD TREE": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 6
        waarde$ = "SHED": dx = 533: dy = 135: GOSUB PlaatsTekstCentered
    CASE 7
        waarde$ = "HEAP": dx = 533: dy = 135: GOSUB PlaatsTekstCentered

END SELECT
TIMER ON

FOR Flash = 1 TO NumberOfFlashes
    FOR witwaarde = 63 TO 0 STEP -2
        _LIMIT OverallFramerate * 2
        PALETTE 33, 65536 * witwaarde + 256 * witwaarde + witwaarde
        _DISPLAY
    NEXT
    FOR witwaarde = 0 TO 63 STEP 2
        _LIMIT OverallFramerate * 2
        PALETTE 33, 65536 * witwaarde + 256 * witwaarde + witwaarde
        _DISPLAY
    NEXT
NEXT
RETURN


PlaatsTekstLinksUitlijnLichtkrant:
FOR strp = 1 TO LEN(waardeLK$)
    nch = ASC(MID$(waardeLK$, strp, 1))
    PUT (dx + (strp - 1) * 7, dy), vglow(nch * grootte), _CLIP PSET
NEXT
RETURN

loaditm:
Bestand$ = CurrentITM$
OPEN "..\ITMFiles\" + Bestand$ FOR INPUT AS #2
INPUT #2, a$
INPUT #2, k
FOR vn = 0 TO k - 1
    FOR pn = 0 TO 4 '                                  pn=0  -->  zwaartepunt
        INPUT #2, x#(vn, pn), y#(vn, pn), z#(vn, pn) ' 1-4   -->  hoekpunten
    NEXT
    INPUT #2, kleur(vn)
NEXT
INPUT #2, a$
CLOSE #2
'

RETURN

LoadEnemy: '

GOTO verder1
SCREEN 0: _AUTODISPLAY
LOCATE 1, 1: PRINT Bestand$
LOCATE 2, 1: PRINT locknr
LOCATE 3, 1: PRINT Enemynummer(locknr)
WHILE INKEY$ = "": WEND
_CLIPBOARD$ = "https://www.youtube.com/@ttware7430"
SYSTEM
verder1:


_AUTODISPLAY
OPEN Bestand$ FOR INPUT AS #2
INPUT #2, a$
INPUT #2, Vlakken
FOR vn = 0 TO Vlakken - 1
    FOR pn = 0 TO 4 '                                  pn=0  -->  zwaartepunt
        INPUT #2, x#(vn, pn), y#(vn, pn), z#(vn, pn) ' 1-4   -->  hoekpunten
        '
        IF Enemynummer(locknr) >= 5 THEN
            x#(vn, pn) = x#(vn, pn) + 10 'offset
            z#(vn, pn) = z#(vn, pn) + 10
        END IF
    NEXT
    INPUT #2, kleur(vn)
NEXT
INPUT #2, a$
CLOSE #2
RETURN

DrawITMMap:
TIMER OFF
FOR vn = 0 TO k - 1
    pn = 1
    PSET (216 + (16 / 50) * x#(vn, pn), 224 - (16 / 50) * z#(vn, pn)), 5
    FOR pn = 2 TO 4
        LINE -(216 + (16 / 50) * x#(vn, pn), 224 - (16 / 50) * z#(vn, pn)), 5
    NEXT
NEXT
TIMER ON
RETURN

'
graphics:
RESTORE set2 ' !@#!@#                         Character set (2 of 2)
dych = 0
FOR nch = 32 TO 38
    dxch = (nch - 32) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 15: PSET (dxch + xch, dych + ych + 451), 33
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), v(nch * grootte)
    GET (dxch, 451)-(dxch + 6, 457), vglow(nch * grootte)
NEXT
FOR nch = 40 TO 43
    dxch = (nch - 32) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, dych + ych), 15: PSET (dxch + xch, dych + ych + 451), 33
        NEXT
    NEXT
    GET (dxch, dych)-(dxch + 5, dych + 6), v(nch * grootte)
    GET (dxch, 451)-(dxch + 6, 457), vglow(nch * grootte)
NEXT
FOR nch = 44 TO 58
    dxch = (nch - 32) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 15: PSET (dxch + xch, dych + ych + 451), 33
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), v(nch * grootte)
    GET (dxch, 451)-(dxch + 6, 457), vglow(nch * grootte)
NEXT
FOR nch = 62 TO 92
    dxch = (nch - 32) * 6
    FOR ych = 0 TO 6
        READ pch$
        FOR xch = 0 TO 5
            flag$ = MID$(pch$, xch + 1, 1)
            IF flag$ = "1" THEN PSET (dxch + xch, ych), 15: PSET (dxch + xch, dych + ych + 451), 33
        NEXT
    NEXT
    GET (dxch, 0)-(dxch + 5, 6), v(nch * grootte)
    GET (dxch, 451)-(dxch + 6, 457), vglow(nch * grootte)
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
' 63 was 64
FOR nch = 63 TO 92
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

HallOfFame:
TIMER OFF

WHILE INKEY$ <> "": WEND
LO = 1: PUT (608, 181), LedOn(0), PSET '

GET (20, 60)-(421, 371), Big&(0)
x1 = 25: y1 = 65: x2 = 415: y2 = 366
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok

x1 = 30: y1 = 70: x2 = 410: y2 = 361
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat

dx = 222: dy = 83: waarde$ = "--- HALL OF FAME ---": GOSUB PlaatsTekstCentered
dx = 222: dy = 100: waarde$ = "-----------------------------------------------------": GOSUB PlaatsTekstCentered
dx = 222: dy = 110: waarde$ = "        PILOT:        SCORE:  LEVEL:   FUEL:   TIME: ": GOSUB PlaatsTekstCentered '
dx = 222: dy = 120: waarde$ = "-----------------------------------------------------": GOSUB PlaatsTekstCentered
FOR position = 1 TO 10
    dy = 130 + (position - 1) * 20
    dx = 50: waarde$ = LTRIM$(STR$(position)): GOSUB PlaatsTekstCentered
    dx = 72: waarde$ = PlayerName$(position): GOSUB PlaatsTekstLinksUitlijn
    waarde$ = LTRIM$(STR$(PlayerScore&(position)))
    WHILE LEN(waarde$) < 6: waarde$ = "0" + waarde$: WEND
    dx = 186: GOSUB PlaatsTekstLinksUitlijn
    dx = 262: waarde$ = LTRIM$(STR$(PlayerLevel(position))): GOSUB PlaatsTekstCentered
    dx = 322: waarde$ = LTRIM$(STR$(INT(FuelTotal#(position)))): GOSUB PlaatsTekstCentered
    dx = 360: waarde$ = PS$(position): GOSUB PlaatsTekstLinksUitlijn
NEXT
dx = 222: dy = 320: waarde$ = "-----------------------------------------------------": GOSUB PlaatsTekstCentered

dx = 222: dy = 339: waarde$ = "PRESS BUTTON TO RETURN": GOSUB PlaatsTekstCentered

TIMER ON
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND
WHILE b = 0
    Mouse 3
    IF b <> 0 GOTO hulp
    IF INKEY$ = CHR$(27) GOTO huulp
    _LIMIT OverallFramerate
WEND
hulp:
positie = 0
'
IF h >= 30 AND h <= 410 AND v >= 124 AND v <= 143 THEN _SNDPLAY Click&: positie = 1: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 144 AND v <= 163 THEN _SNDPLAY Click&: positie = 2: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 164 AND v <= 183 THEN _SNDPLAY Click&: positie = 3: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 184 AND v <= 203 THEN _SNDPLAY Click&: positie = 4: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 204 AND v <= 223 THEN _SNDPLAY Click&: positie = 5: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 224 AND v <= 243 THEN _SNDPLAY Click&: positie = 6: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 244 AND v <= 263 THEN _SNDPLAY Click&: positie = 7: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 264 AND v <= 283 THEN _SNDPLAY Click&: positie = 8: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 284 AND v <= 303 THEN _SNDPLAY Click&: positie = 9: GOSUB glow
IF h >= 30 AND h <= 410 AND v >= 304 AND v <= 323 THEN _SNDPLAY Click&: positie = 10: GOSUB glow
IF positie = 0 THEN huuulp = 1: GOTO huulp
IF positie <> 0 THEN
    CURHISCO = positie

    OPEN "..\TXTFiles\CURHISCO.TXT" FOR OUTPUT AS #19
    PRINT #19, CURHISCO
    CLOSE #19

    a1$ = LTRIM$(STR$(positie))
    IF LEN(a1$) < 2 THEN a1$ = "0" + a1$
    '
    OPEN "..\TXTFiles\BB" + a1$ + ".TXT" FOR INPUT AS #9 'copy BB**.TXT naar Blackbox.TXT
    OPEN "..\TXTFiles\BLACKBOX.TXT" FOR OUTPUT AS #8
    WHILE NOT EOF(9)
        INPUT #9, N, x#, y#, z#, fuel#, ammo, heading, snelheid
        PRINT #8, N, x#, y#, z#, fuel#, ammo, heading, snelheid
    WEND
    CLOSE #8
    CLOSE #9
END IF

huulp:
PUT (20, 60), Big&(0), PSET
x1 = 436: y1 = 172: x2 = 629: y2 = 200: GOSUB tekenblok
LO = 0: PUT (608, 181), LedOff(0), PSET
WHILE b <> 0: Mouse 3: _LIMIT OverallFramerate: WEND
IF huuulp = 1 THEN huuulp = 0: RETURN hl0
RETURN hulp6

glow:
helderheid = 0
PALETTE 32, 0
yglow = 127 + 20 * (positie - 1)
LINE (35, yglow)-(405, yglow + 12), 32, B
DO WHILE helderheid <= 60
    _LIMIT OverallFramerate
    PALETTE 32, 256 * helderheid
    helderheid = helderheid + 3
LOOP
helderheid = 63
PALETTE 32, 256 * 63
RETURN

Glow1:
helderheid = 31
PALETTE 32, 256 * helderheid
yglow = 8 + 10 * (AspirantNr - 1) '
LINE (342, 8 + 10 * AspirantNr)-(525, 18 + 10 * AspirantNr), 32, B
DO WHILE helderheid <= 60
    _LIMIT 2 * OverallFramerate
    PALETTE 32, 256 * helderheid
    helderheid = helderheid + 3
LOOP
helderheid = 63
PALETTE 32, 256 * 63
RETURN

PlaatsTekstLinksUitlijn:
FOR strp = 1 TO LEN(waarde$)
    nch = ASC(MID$(waarde$, strp, 1))
    PUT (dx + (strp - 1) * 7, dy), v(nch * grootte), _CLIP OR
NEXT
RETURN

TekenVijand:
FOR Vlak = 0 TO Vlakken - 1
    jn0 = 0: jn1 = 0: jn2 = 0: jn3 = 0: jn4 = 0
    xp# = x#(Vlak, 0): yp# = y#(Vlak, 0): zp# = z#(Vlak, 0): GOSUB BepaalBeeld
    gridcolor = 163 - INT((SQR((xc0# - xp#) ^ 2 + (yc0# - yp#) ^ 2 + (zc0# - zp#) ^ 2)) / 1)
    IF gridcolor < 100 THEN gridcolor = 100
    IF gridcolor > 163 THEN gridcolor = 163
    horhoek0# = horhoek#: verhoek0# = verhoek#
    xp# = x#(Vlak, 1): yp# = y#(Vlak, 1): zp# = z#(Vlak, 1): GOSUB BepaalBeeld
    horhoek1# = horhoek#: verhoek1# = verhoek#
    xp# = x#(Vlak, 2): yp# = y#(Vlak, 2): zp# = z#(Vlak, 2): GOSUB BepaalBeeld
    horhoek2# = horhoek#: verhoek2# = verhoek#
    xp# = x#(Vlak, 3): yp# = y#(Vlak, 3): zp# = z#(Vlak, 3): GOSUB BepaalBeeld
    horhoek3# = horhoek#: verhoek3# = verhoek#
    xp# = x#(Vlak, 4): yp# = y#(Vlak, 4): zp# = z#(Vlak, 4): GOSUB BepaalBeeld
    horhoek4# = horhoek#: verhoek4# = verhoek#
    qx# = 533 + schaalx# * pf# * horhoek0#
    qy# = 77 - schaaly# * pf# * verhoek0#
    IF qx# >= 439 AND qx# <= 626 AND qy# >= 14 AND qy# <= 159 THEN
        xkprojectie0 = qx#: ykprojectie0 = qy#: jn0 = 1
    END IF
    qx# = 533 + schaalx# * pf# * horhoek1#
    qy# = 77 - schaaly# * pf# * verhoek1#
    IF qx# >= 439 AND qx# <= 626 AND qy# >= 14 AND qy# <= 159 THEN
        xkprojectie1 = qx#: ykprojectie1 = qy#: jn1 = 1
    END IF
    qx# = 533 + schaalx# * pf# * horhoek2#
    qy# = 77 - schaaly# * pf# * verhoek2#
    IF qx# >= 439 AND qx# <= 626 AND qy# >= 14 AND qy# <= 159 THEN
        xkprojectie2 = qx#: ykprojectie2 = qy#: jn2 = 1
    END IF
    qx# = 533 + schaalx# * pf# * horhoek3#
    qy# = 77 - schaaly# * pf# * verhoek3#
    IF qx# >= 439 AND qx# <= 626 AND qy# >= 14 AND qy# <= 159 THEN
        xkprojectie3 = qx#: ykprojectie3 = qy#: jn3 = 1
    END IF
    qx# = 533 + schaalx# * pf# * horhoek4#
    qy# = 77 - schaaly# * pf# * verhoek4#
    IF qx# >= 439 AND qx# <= 626 AND qy# >= 14 AND qy# <= 159 THEN
        xkprojectie4 = qx#: ykprojectie4 = qy#: jn4 = 1
    END IF
    IF jn0 = 1 AND jn1 = 1 AND jn2 = 1 AND jn3 = 1 AND jn4 = 1 AND gridcolor > 100 THEN
        LINE (xkprojectie1, ykprojectie1)-(xkprojectie2, ykprojectie2), gridcolor
        LINE (xkprojectie2, ykprojectie2)-(xkprojectie3, ykprojectie3), gridcolor
        LINE (xkprojectie3, ykprojectie3)-(xkprojectie4, ykprojectie4), gridcolor
        LINE (xkprojectie4, ykprojectie4)-(xkprojectie1, ykprojectie1), gridcolor
    END IF
NEXT
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
IF (xp# - xc0#) > 0 AND (zp# - zc0#) >= 0 THEN koers1# = (ATN((zp# - zc0#) / (xp# - xc0#)))
IF (xp# - xc0#) < 0 AND (zp# - zc0#) >= 0 THEN koers1# = (pi# - ATN((zp# - zc0#) / -(xp# - xc0#)))
IF (xp# - xc0#) < 0 AND (zp# - zc0#) < 0 THEN koers1# = (pi# + ATN(-(zp# - zc0#) / -(xp# - xc0#)))
IF (xp# - xc0#) > 0 AND (zp# - zc0#) < 0 THEN koers1# = (2 * pi# - ATN(-(zp# - zc0#) / (xp# - xc0#)))
IF (xp# - xc0#) = 0 AND (zp# - zc0#) >= 0 THEN koers1# = (.5 * pi#)
IF (xp# - xc0#) = 0 AND (zp# - zc0#) <= 0 THEN koers1# = (1.5 * pi#)
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

draaix:
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

draaiy:
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

'
Volume:
tellerslide = 0
x1 = 290: y1 = 150: x2 = 349: y2 = 295
GET (x1, y1)-(x2, y2), SliderPark(0)
PLAY "v" + Pct$ + "MBl32o3a"
_SNDVOL Click&, Volume / 100
_SNDVOL Blades&, Volume / 100
_SNDLOOP Blades&
TIMER OFF
GOSUB tekenblok
LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF
waarde$ = "SOUND": dx = 320: dy = 157: GOSUB PlaatsZwartOpGrijsCentered
LINE (298, 277)-(341, 289), 0, BF
x1 = 298: y1 = 277: x2 = 341: y2 = 289: GOSUB tekengat
waarde$ = Pct$ + " %": dx = 320: dy = 280: GOSUB PlaatsTekstCentered
x1 = 309: y1 = 169: x2 = 330: y2 = 271: GOSUB tekengat
x1 = 290: y1 = 150: x2 = 349: y2 = 290


LINE (310, 170)-(329, 270), 0, BF
GET (304, 204)-(304 + 31, 204 + 31), DontShootBackground(0)
LINE (310, 270 - Volume)-(329, 270 - Volume)

TIMER ON
DO
    tellerslide = tellerslide + 1
    _LIMIT 20
    i$ = INKEY$
    IF i$ = "+" AND Volume <= 95 THEN
        PUT (304, 204), DontShootBackground(0), PSET
        tellerslide = 0
        Volume = Volume + 5
        _SNDVOL Click&, Volume / 100
        _SNDVOL Blades&, Volume / 100

        Pct$ = LTRIM$(STR$(Volume))
        TIMER OFF
        LINE (310, 170)-(329, 270), 0, BF
        LINE (310, 270 - Volume)-(329, 270 - Volume)
        PLAY "v" + Pct$ + "MBl32o3a"
        LINE (298, 277)-(341, 289), 0, BF
        x1 = 298: y1 = 277: x2 = 341: y2 = 289: GOSUB tekengat
        waarde$ = Pct$ + " %": dx = 320: dy = 280: GOSUB PlaatsTekstCentered
        TIMER ON
    END IF
    IF i$ = "-" AND Volume >= 5 THEN
        tellerslide = 0
        Volume = Volume - 5
        _SNDVOL Click&, Volume / 100
        _SNDVOL Blades&, Volume / 100

        Pct$ = LTRIM$(STR$(Volume))
        TIMER OFF
        LINE (310, 170)-(329, 270), 0, BF
        LINE (310, 270 - Volume)-(329, 270 - Volume)
        PLAY "v" + Pct$ + "MBl32o3a"
        LINE (298, 277)-(341, 289), 0, BF
        x1 = 298: y1 = 277: x2 = 341: y2 = 289: GOSUB tekengat
        waarde$ = Pct$ + " %": dx = 320: dy = 280: GOSUB PlaatsTekstCentered
        TIMER ON
    END IF
    IF Volume = 0 THEN
        PUT (304, 204), DontShootMask(0), AND
        PUT (304, 204), DontShoot(0), XOR
    END IF
    _DISPLAY
LOOP WHILE i$ <> CHR$(27) AND tellerslide < 40 '2x20= 2 seconden
_SNDSTOP Blades&
OPEN "..\TXTFiles\VOLUME.TXT" FOR OUTPUT AS #1
PRINT #1, Volume
CLOSE #1
TIMER OFF
'
_SNDVOL Click&, Volume / 100
_SNDVOL Blades&, Volume / 100
_SNDVOL HitEnemy&, Volume / 100



PUT (290, 150), SliderPark(0), PSET
TIMER ON
WHILE INKEY$ <> "": WEND
_SNDVOL Click&, Volume / 100
_SNDVOL Blades&, Volume / 100
_SNDVOL HitEnemy&, Volume / 100


RETURN




eindeFLY:
'

OPEN "..\TXTFiles\CONTROL.TXT" FOR OUTPUT AS #1
PRINT #1, controller$ 'Default control type when NOT recording REPLAY.mcr     MOUSE/KEYBOARD/JOYSTICK
CLOSE #1




PUT (608, 295), LedOn(0), PSET
WHILE b <> 0: Mouse 3: WEND
KeusXxx$ = ""
TIMER OFF: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekengat: TIMER ON
_SNDPLAY HitEnemy&


'


TIMER OFF
GET (140, 170)-(300, 250), bulk3(0)
x1 = 140: y1 = 170: x2 = 300: y2 = 250: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
x1 = 150: y1 = 180: x2 = 290: y2 = 200: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat
waarde$ = "--- SELECT --- "
dx = 222: dy = 187: GOSUB PlaatsTekstCentered
x1 = 150: y1 = 220: x2 = 215: y2 = 240: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
x1 = 224: y1 = 220: x2 = 289: y2 = 240: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
waarde$ = "PRACTICE"
dx = 148: dy = 227: GOSUB PlaatsZwartOpGrijs
waarde$ = "RESCUE"
dx = 229: dy = 227: GOSUB PlaatsZwartOpGrijs

TIMER ON




WHILE b <> 0: Mouse 3: WEND
'*********************************************************** Hoofdlus ****
kl10:
_LIMIT OverallFramerate
Mouse 3
i$ = INKEY$
IF i$ = CHR$(27) THEN TIMER OFF: PUT (140, 170), bulk3(0), PSET: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok: LO = 0: PUT (608, 295), LedOff(0), PSET: TIMER ON: GOTO hl0

IF b = 1 THEN x = h: Y = v: GOTO kl11
GOTO kl10
' *************************************************************************
kl11:
KeusXxx$ = "GoBack"
IF x > 151 AND x < 214 AND Y > 221 AND Y < 239 THEN _SNDPLAY Click&: TIMER OFF: x1 = 150: y1 = 220: x2 = 215: y2 = 240: GOSUB tekengat: TIMER ON: KeusXxx$ = "Practice"
IF x > 225 AND x < 288 AND Y > 221 AND Y < 239 THEN _SNDPLAY Click&: TIMER OFF: x1 = 224: y1 = 220: x2 = 289: y2 = 240: GOSUB tekengat: TIMER ON: KeusXxx$ = "Play"

WHILE b <> 0: Mouse 3: WEND

TIMER OFF
PUT (140, 170), bulk3(0), PSET
TIMER ON
WHILE b <> 0: Mouse 3: WEND
WHILE INKEY$ <> "": WEND

IF KeusXxx$ = "GoBack" THEN TIMER OFF: PUT (140, 170), bulk3(0), PSET: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok: LO = 0: PUT (608, 295), LedOff(0), PSET: TIMER ON: GOTO hl0
WHILE Bmuis <> 0: Mouse 3: _LIMIT OverallFramerate: WEND

IF KeusXxx$ <> "Practice" THEN

    OPEN "..\TXTFiles\RECDEMO.TXT" FOR INPUT AS #1
    INPUT #1, RCD$
    CLOSE #1
    TIMER OFF: LO = 1: PUT (608, 295), LedOn(0), PSET: TIMER ON
    IF _FILEEXISTS("..\REPLAY.mcr") AND RCD$ <> "OFF" THEN
        WHILE b <> 0: Mouse 3: WEND
        KeusX$ = ""

        TIMER OFF: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekengat: TIMER ON
        _SNDPLAY HitEnemy&

        TIMER OFF
        GET (140, 170)-(300, 250), bulk3(0)
        x1 = 140: y1 = 170: x2 = 300: y2 = 250: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
        x1 = 150: y1 = 180: x2 = 290: y2 = 200: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat

        waarde$ = "OVERWRITE REPLAY"
        dx = 222: dy = 187: GOSUB PlaatsTekstCentered
        x1 = 150: y1 = 220: x2 = 215: y2 = 240: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
        x1 = 224: y1 = 220: x2 = 289: y2 = 240: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
        waarde$ = "OK"
        dx = 169: dy = 227: GOSUB PlaatsZwartOpGrijs
        waarde$ = "CANCEL"
        dx = 230: dy = 227: GOSUB PlaatsZwartOpGrijs
        TIMER ON

        WHILE b <> 0: Mouse 3: WEND
        '*********************************************************** Hoofdlus ****
        hl10:
        _LIMIT OverallFramerate
        Mouse 3
        i$ = INKEY$
        IF i$ = CHR$(27) THEN TIMER OFF: PUT (240, 170), bulk3(0), PSET: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok: LO = 0: PUT (608, 295), LedOff(0), PSET: TIMER ON: GOTO hl0
        IF b = 1 THEN x = h: Y = v: GOTO hl11
        GOTO hl10
        ' *************************************************************************
        hl11:
        IF x > 151 AND x < 214 AND Y > 221 AND Y < 239 THEN _SNDPLAY Click&: TIMER OFF: x1 = 150: y1 = 220: x2 = 215: y2 = 240: GOSUB tekengat: TIMER ON: KeusX$ = "YES" ELSE _SNDPLAY Click&: TIMER OFF: x1 = 224: y1 = 220: x2 = 289: y2 = 240: GOSUB tekengat: KeusX$ = "NO": TIMER ON
        WHILE b <> 0: Mouse 3: WEND

        IF KeusX$ = "NO" THEN
            TIMER OFF
            PUT (140, 170), bulk3(0), PSET
            x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok
            LO = 0: PUT (608, 295), LedOff(0), PSET
            TIMER ON
            WHILE b <> 0: Mouse 3: WEND
            WHILE INKEY$ <> "": WEND


            GOTO hl0
        END IF


    END IF


    '*****************************************************************************
    OPEN "..\TXTFiles\CONTROL.TXT" FOR OUTPUT AS #1
    PRINT #1, controller$
    CLOSE #1
    LO = 1: PUT (608, 295), LedOn(0), PSET
    _AUTODISPLAY
    _DELAY .5
    TIMER OFF

    dikte = 8
    LINE (320 - dikte, 0)-(320 + dikte, 479), 0, BF
    FOR k = 1 TO 40
        GET (320, 0)-(639 - dikte, 479), bulk1(0)
        GET (dikte, 0)-(319, 479), bulk2(0)
        _LIMIT SlideSpeed&
        PUT (0, 0), bulk2(0), PSET
        PUT (320 + dikte, 0), bulk1(0), PSET
        _DISPLAY
    NEXT
    IF _FILEEXISTS("..\Modules\Main.exe") THEN CHAIN "Main.exe"
END IF

'

IF KeusXxx$ = "Practice" AND _FILEEXISTS("..\Modules\Practice.exe") THEN GOSUB DayNight: GOSUB systeemeinde2: CHAIN "Practice.exe"

WHILE INKEY$ <> "": WEND
TIMER OFF
CLS
waarde$ = "CONTACT TTWAREHELICOPTERRESCUE@GMAIL.COM FOR MISSING FILES"
dx = 319: dy = 230: GOSUB PlaatsTekstCentered
CIRCLE (105, 233), 10, , .5 * pi#, 1.5 * pi#
CIRCLE (530, 233), 10, , 1.5 * pi#, .5 * pi#
LINE (104, 223)-(531, 223)
LINE (104, 243)-(531, 243)

_DISPLAY
b = 0
WHILE INKEY$ = "" AND b = 0
    _LIMIT OverallFramerate
    Mouse 3
WEND
GOSUB systeemeinde2
'
CLEAR: CLS

CHAIN "Menu.exe"

'



Systeemeinde:

_AUTODISPLAY
'
TIMER OFF
dikte = 8
LINE (320 - dikte, 0)-(320 + dikte, 479), 0, BF
FOR k = 1 TO 40
    GET (320, 0)-(639 - dikte, 479), bulk1(0)
    GET (dikte, 0)-(319, 479), bulk2(0)
    _LIMIT SlideSpeed&
    PUT (0, 0), bulk2(0), PSET
    PUT (320 + dikte, 0), bulk1(0), PSET
    LINE (319 - (k - 1) * dikte, 0)-(319 - (k - 1) * dikte, 479), 0
    LINE (320 + (k - 1) * dikte, 0)-(320 + (k - 1) * dikte, 479), 0
    _DISPLAY
NEXT

_AUTODISPLAY
PALETTE 15, 0
waarde$ = EndText$: dx = 319: dy = 170: GOSUB PlaatsTekstCentered
OPEN "..\TXTFiles\TCOCKPIT.TXT" FOR INPUT AS #1
INPUT #1, TotalCockpitTime&
CLOSE #1

OPEN "..\TXTFiles\" + "DATETIME.TXT" FOR INPUT AS #1
INPUT #1, InstallDate$
INPUT #1, InstallTime$
CLOSE #1
MO1 = VAL(MID$(InstallDate$, 1, 2))
DD1 = VAL(MID$(InstallDate$, 4, 2))
YY1 = VAL(MID$(InstallDate$, 7, 4))
Days1 = 365! * YY1 + DD1 + 31 * (MO1 - 1)
IF MO1 < 3 THEN
    Days1 = Days1 + INT((YY1 - 1) / 4) - INT(3 / 4 * (INT((YY1 - 1) / 100) + 1))
ELSE
    Days1 = Days1 - INT(.4 * MO1 + 2.3) + INT(YY1 / 4) - INT(3 / 4 * (INT(YY1 / 100) + 1))
END IF

AltDate$ = DATE$
MO2 = VAL(MID$(AltDate$, 1, 2))
DD2 = VAL(MID$(AltDate$, 4, 2))
YY2 = VAL(MID$(AltDate$, 7, 4))
Days2 = 365! * YY2 + DD2 + 31 * (MO2 - 1)
IF MO2 < 3 THEN
    Days2 = Days2 + INT((YY2 - 1) / 4) - INT(3 / 4 * (INT((YY2 - 1) / 100) + 1))
ELSE
    Days2 = Days2 - INT(.4 * MO2 + 2.3) + INT(YY2 / 4) - INT(3 / 4 * (INT(YY2 / 100) + 1))
END IF

uren = TotalCockpitTime& \ 3600
TotalCockpitTime& = TotalCockpitTime& - uren * 3600
minuten = TotalCockpitTime& \ 60
TotalCockpitTime& = TotalCockpitTime& - minuten * 60
seconden = TotalCockpitTime&
uren$ = LTRIM$(STR$(uren))
IF LEN(uren$) > 2 THEN
    WHILE LEN(uren$) < 4: uren$ = "0" + uren$: WEND
ELSE
    WHILE LEN(uren$) < 2: uren$ = "0" + uren$: WEND
END IF
minuten$ = LTRIM$(STR$(minuten))
WHILE LEN(minuten$) < 2: minuten$ = "0" + minuten$: WEND
seconden$ = LTRIM$(STR$(seconden))
WHILE LEN(seconden$) < 2: seconden$ = "0" + seconden$: WEND

waarde$ = "DAY " + LTRIM$(STR$(1 + (Days2 - Days1))): dx = 319: dy = 210: GOSUB PlaatsTekstCentered
waarde$ = "TOTAL FLIGHT TIME: " + uren$ + ":" + minuten$ + ":" + seconden$: dx = 319: dy = 230: GOSUB PlaatsTekstCentered

CIRCLE (257, 173), 11, , .5 * pi#, 1.5 * pi#
CIRCLE (378, 173), 11, , 1.5 * pi#, .5 * pi#
LINE (256, 162)-(379, 162)
LINE (256, 184)-(379, 184)

FOR w = 0 TO 63 STEP 7
    _LIMIT 120
    PALETTE 15, 65536 * w + 256 * w + w
NEXT
SLEEP 1

GOSUB VuurPalet

x1 = 245: x2 = 389
y1 = 80: y2 = 186

LINE (256, 160)-(379, 162), , BF

b = 0
teller& = 0
DO WHILE INKEY$ = "" AND b = 0
    Mouse 3
    _LIMIT 20000
    xp = x1 + (x2 - x1) * RND
    yp = y1 + (y2 - y1) * RND
    p = POINT(xp, yp)
    IF p = 0 THEN p = 149
    IF p < 50 THEN p = 50
    p2 = p + 4
    IF p2 > 149 THEN p2 = 149
    IF yp > y1 AND xp > x1 + 1 AND yp < y2 AND xp < x2 THEN
        LINE (xp - 1, yp - 1)-(xp + 1, yp - 3), p2, BF
        LINE (xp, yp - 4)-(xp, yp - 5), p2, BF
    END IF
    teller& = teller& + 1
    IF teller& >= 60000 THEN EXIT DO
LOOP
FOR w = 63 TO 0 STEP -1
    _LIMIT 120
    PALETTE 15, 65536 * w + 256 * w + w
NEXT
_CLIPBOARD$ = "https://www.youtube.com/@ttware7430"
SYSTEM

VuurPalet:
ac = 16
b1! = 63
g1! = 63
r1! = 63
b2! = 16
g2! = 40
r2! = 63
bst! = (b2! - b1!) / ac: gst! = (g2! - g1!) / ac: rst! = (r2! - r1!) / ac
b! = b1!: g! = g1!: r! = r1!
FOR cc = 50 TO 50 + ac
    PALETTE cc, 65536 * INT(b!) + 256 * INT(g!) + INT(r!)
    b! = b! + bst!: g! = g! + gst!: r! = r! + rst!
NEXT
delta = delta + ac
ac = 64
b1! = 16
g1! = 40
r1! = 63
b2! = 0
g2! = 0
r2! = 31
bst! = (b2! - b1!) / ac: gst! = (g2! - g1!) / ac: rst! = (r2! - r1!) / ac
b! = b1!: g! = g1!: r! = r1!
FOR cc = 50 + delta TO 50 + ac + delta
    PALETTE cc, 65536 * INT(b!) + 256 * INT(g!) + INT(r!)
    b! = b! + bst!: g! = g! + gst!: r! = r! + rst!
NEXT
delta = delta + ac
ac = 19
b1! = 0
g1! = 0
r1! = 31
b2! = 0
g2! = 0
r2! = 0
bst! = (b2! - b1!) / ac: gst! = (g2! - g1!) / ac: rst! = (r2! - r1!) / ac
b! = b1!: g! = g1!: r! = r1!
FOR cc = 50 + delta TO 50 + ac + delta
    PALETTE cc, 65536 * INT(b!) + 256 * INT(g!) + INT(r!)
    b! = b! + bst!: g! = g! + gst!: r! = r! + rst!
NEXT
delta = delta + ac
RETURN

systeemeinde2:
_AUTODISPLAY
TIMER OFF

dikte = 8
LINE (320 - dikte, 0)-(320 + dikte, 479), 0, BF
FOR k = 1 TO 40
    GET (320, 0)-(639 - dikte, 479), bulk1(0)
    GET (dikte, 0)-(319, 479), bulk2(0)
    _LIMIT SlideSpeed&
    PUT (0, 0), bulk2(0), PSET
    PUT (320 + dikte, 0), bulk1(0), PSET
    LINE (319 - (k - 1) * dikte, 0)-(319 - (k - 1) * dikte, 479), 0
    LINE (320 + (k - 1) * dikte, 0)-(320 + (k - 1) * dikte, 479), 0
    _DISPLAY
NEXT
RETURN

ReadMe: '
'
TIMER OFF
CLS
_AUTODISPLAY
OPEN "..\ReadMe.txt" FOR INPUT AS #20
FOR yyR = 0 TO 19
    INPUT #20, aaa$
    PRINT aaa$
NEXT
CLOSE #20
WHILE INKEY$ = "": WEND
CHAIN "Menu.exe"

WHILE INKEY$ = "": WEND
TIMER ON
RETURN

'
DayNight:
TIMER OFF
GET (140, 170)-(300, 250), bulk3(0)
x1 = 140: y1 = 170: x2 = 300: y2 = 250: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
x1 = 150: y1 = 180: x2 = 290: y2 = 200: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 0, BF: GOSUB tekengat
waarde$ = "--- SELECT --- "
dx = 222: dy = 187: GOSUB PlaatsTekstCentered
x1 = 150: y1 = 220: x2 = 215: y2 = 240: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
x1 = 224: y1 = 220: x2 = 289: y2 = 240: LINE (x1 + 1, y1 + 1)-(x2 - 1, y2 - 1), 3, BF: GOSUB tekenblok
waarde$ = "DAY"
dx = 166: dy = 227: GOSUB PlaatsZwartOpGrijs
waarde$ = "NIGHT"
dx = 233: dy = 227: GOSUB PlaatsZwartOpGrijs

TIMER ON
WHILE b <> 0: Mouse 3: WEND
'*********************************************************** Hoofdlus ****
kll10:
_LIMIT OverallFramerate
Mouse 3
i$ = INKEY$
IF i$ = CHR$(27) THEN TIMER OFF: PUT (140, 170), bulk3(0), PSET: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok: LO = 0: PUT (608, 295), LedOff(0), PSET: TIMER ON: GOTO hl0

IF b = 1 THEN x = h: Y = v: GOTO kll11
GOTO kll10
' *************************************************************************
kll11:
IF x > 151 AND x < 214 AND Y > 221 AND Y < 239 THEN _SNDPLAY Click&: TIMER OFF: x1 = 150: y1 = 220: x2 = 215: y2 = 240: GOSUB tekengat: TIMER ON: DayNight$ = "DAY": GOTO kll12
IF x > 225 AND x < 288 AND Y > 221 AND Y < 239 THEN _SNDPLAY Click&: TIMER OFF: x1 = 224: y1 = 220: x2 = 289: y2 = 240: GOSUB tekengat: TIMER ON: DayNight$ = "NIGHT": GOTO kll12
WHILE b <> 0: Mouse 3: WEND


TIMER OFF: PUT (140, 170), bulk3(0), PSET: x1 = 436: y1 = 286: x2 = 629: y2 = 314: GOSUB tekenblok: LO = 0: PUT (608, 295), LedOff(0), PSET: TIMER ON: GOTO hl0
kll12:
WHILE b <> 0: Mouse 3: WEND

OPEN "..\TXTFiles\DAYNIGHT.TXT" FOR OUTPUT AS #1
PRINT #1, DayNight$
CLOSE #1


RETURN


Accolade:
DATA 000011
DATA 000100
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 010000
DATA 100000
DATA 010000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 001000
DATA 000100
DATA 000011

Led:
'Led off
DATA ............
DATA ....2222....
DATA ...2AAAA2...
DATA ..4AAABBA2..
DATA .4AAAAAABA2.
DATA .4AAAAAABA2.
DATA .4AAAAAAAA2.
DATA .4AAAAAAAA2.
DATA ..4AAAAAA2..
DATA ...4AAAA4...
DATA ....4444....
DATA ............
'Led on
DATA ............
DATA ....2222....
DATA ...2CCCC2...
DATA ..4CCC55C2..
DATA .4CCCCCC5C2.
DATA .4CCCCCC5C2.
DATA .4CCCCCCCC2.
DATA .4CCCCCCCC2.
DATA ..4CCCCCC2..
DATA ...4CCCC4...
DATA ....4444....
DATA ............
'Ledhalf
DATA ............
DATA ....2222....
DATA ...2CCCC2...
DATA ..4CCC55C2..
DATA .4CCCCCC5C2.
DATA .4CCCCCC5C2.
DATA .4CCCCCCCC2.
DATA .4CCCCCCCC2.
DATA ..4CCCCCC2..
DATA ...4CCCC4...
DATA ....4444....
DATA ............

roos: '  56x56
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
dontshoot: 'DontShoot
DATA 00000000000011111111000000000000
DATA 00000000011122222222111000000000
DATA 00000001122222222222222110000000
DATA 00000012222222222222222221000000
DATA 00000122222222222222222222100000
DATA 00001222222222222222222222210000
DATA 00012222222221111112222222221000
DATA 00122222222110000001112222222100
DATA 00122222222210000000001222222100
DATA 01222222222221000000000122222210
DATA 01222222222222100000000012222210
DATA 01222221222222210000000012222210
DATA 12222221122222221000000012222221
DATA 12222210012222222100000001222221
DATA 12222210001222222210000001222221
DATA 12222210000122222221000001222221
DATA 12222210000012222222100001222221
DATA 12222210000001222222210001222221
DATA 12222210000000122222221001222221
DATA 12222221000000012222222112222221
DATA 01222221000000001222222212222210
DATA 01222221000000000122222222222210
DATA 01222222100000000012222222222210
DATA 00122222210000000001222222222100
DATA 00122222221110000001122222222100
DATA 00012222222221111112222222221000
DATA 00001222222222222222222222210000
DATA 00000122222222222222222222100000
DATA 00000012222222222222222221000000
DATA 00000001122222222222222110000000
DATA 00000000011122222222111000000000
DATA 00000000000011111111000000000000

dontshoottext: '92x13
DATA 00000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000
DATA 03445600000007450000084100065009a0b433334c000000dec000bf0000b700000g4700000008336000443334e8
DATA chijkhl0000mnhhhko000phq0004hm0rs0thhhhhhu0000vwhxhy00ay0000tz0009ihhhwm0006phhhhA0vhhhhhhhB
DATA bh302ChD006Et4vfAhr00ujhb004km0CF0282aG2820000Hjf6bI00tG0000Jl00KhL78IsM600NxO8mKhP08vch9681
DATA bhd000Ch40Qhm0000us00RlSu004i80Ou0000tH0000000Su000000tq0000Fl06iH00003hT0Ch30000lh1002hU000
DATA bhb0000hV0Nw00000Wh70nlghe04i80180000tH0000000VhX00000JY877mtA03hb00000EG0qj00000dh300vhT000
DATA bhb0000Jp0MG00000bhd0nq0RJ03i80000000tH00000001YhtC000NhhhhhhP0Zh600000nu0nn000001hC00vhT000
DATA bhb0000ay0My00000ghc0nq0bhCgi80000000tH000000000eDhH00JDb5ggMA0Zh200000wD0nw000006hO00vhT000
DATA bhb0000hQ0Fw00000Uhv0nq00Gt4i80000000tH00000000000Qhg0tq0000Fl04hb00000xP0yx00000ghc00vhT000
DATA bhd000Xhb0Ah80000Nn00nq00mkpj80000000tH00000000000bhe0tG0000Jl02hl0000Ohe0Th50000pE000vhT000
DATA bh417Qhy00vht46cDh500nq000Phi80000000aq000000vDU2fnj20tG0000Jl00PhLmvThD001MxO27qhZ000vhT000
DATA fhhhhEQ0000dwhhhJe000nG0002shv0000000aq0000000zkhhFg00ay0000tl000Lxhhil0000vDhhhMZ0000vhT000
DATA 0888v00000000282000002600001v00000000v60000000018v0000v60000v600000880000000068v000000081000



pages:
DATA 001000000110
DATA 011000101001
DATA 001000100010
DATA 001001000100
DATA 011101001111

DATA 011000000110
DATA 100100101001
DATA 001000100010
DATA 010001000100
DATA 111101001111




'
Muis: 'Muis
DATA 00001110000
DATA 00000000000
DATA 00000100000
DATA 00000100000
DATA 10000100001
DATA 10111011101
DATA 10000100001
DATA 00000100000
DATA 00000100000
DATA 00000000000
DATA 00001110000



Balknul:
DATA 1111111111111111111111111111111111111111
DATA 1010101000000000000000000000000000000001
DATA 1101010100000000000000000000000000000001
DATA 1010101000000000000000000000000000000001
DATA 1101010100000000000000000000000000000001
DATA 1010101000000000000000000000000000000001
DATA 1101010100000000000000000000000000000001
DATA 1111111111111111111111111111111111111111

Balk:
DATA 1111111111111111111111111111111111111111
DATA 1010101010101010101000000000000000000001
DATA 1101010101010101010100000000000000000001
DATA 1010101010101010101000000000000000000001
DATA 1101010101010101010100000000000000000001
DATA 1010101010101010101000000000000000000001
DATA 1101010101010101010100000000000000000001
DATA 1111111111111111111111111111111111111111
Balkhalf:
DATA 1111111111111111111111111111111111111111
DATA 1010101010101010101010101010101010101011
DATA 1101010101010101010101010101010101010101
DATA 1010101010101010101010101010101010101011
DATA 1101010101010101010101010101010101010101
DATA 1010101010101010101010101010101010101011
DATA 1101010101010101010101010101010101010101
DATA 1111111111111111111111111111111111111111


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

' &     (38)
DATA 001000
DATA 110100
DATA 110100
DATA 001001
DATA 010110
DATA 110010
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

'       ? (63)
'
DATA 011110
DATA 110011
DATA 000011
DATA 000110
DATA 001100
DATA 000000
DATA 001100





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
'        (32 - 38) SPC-&
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000

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

'  ()*+   (40-43)      '!@#
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

DATA 000000
DATA 001100
DATA 111111
DATA 001100
DATA 111111
DATA 001100
DATA 000000

DATA 000000
DATA 001000
DATA 001000
DATA 111110
DATA 001000
DATA 001000
DATA 000000

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


'  > - Z (62-90)


DATA 000000
DATA 001000
DATA 001000
DATA 000000
DATA 001000
DATA 001000
DATA 000000


DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000
DATA 000000



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

Lichtkrant:
'Dakje ^ voor 'THE GOAL' doet Highscore knipperen   (error bij analysescherm)
DATA YOUR MISSION IS TO RESCUE AS MANY REFUGEES AS YOU CAN -IN A SEQUENCE THAT FITS THE SITUATION-
DATA BY LANDING IN THEIR VICINITY WHILE ENEMY DRONES ARE CLOSING IN -------- PREVENT THE DRONES FROM
DATA OVERRUNNING YOUR BASE (WAYPOINT 0) BY STOPPING THEM WITH THE 30MM GUN -------- BE CAREFUL NOT TO SHOOT AT FRIENDLY TRUCKS
DATA BECAUSE THEY BRING IN FUEL AND AMMUNITION -------- DON\T COME TOO CLOSE TO THE DRONES OR THEY WILL
DATA DO DAMAGE TO YOUR HELICOPTER (IT CAN BE REPAIRED AT THE BASE) -------- IN THE MENU PRESS \+\ OR \-\ TO ADJUST THE SOUND LEVEL -------- IN THE \HALL OF FAME\ CLICK ON THE SLOTS TO
DATA REVIEW THE CORRESPONDING FLIGHTRECORDERS AND ACHIEVEMENTS (CLICK \ANALYSIS\ TO VIEW THE FLIGHT DETAILS) -------- WHILE
DATA IN THE GAME PRESS \M\ FOR MAP OR \H\ FOR OTHER IN-GAME KEYS -------- IN THE MENU CLICK IN THIS TEXT BOX TO PLAY A
DATA RECORDED REPLAY -------- SPECIAL THANKS GO OUT TO THE QB64 COMMUNITY FOR KEEPING
DATA QB64 ON LIFE SUPPORT -------- B.SCOTCH# AND ED-EQUIPMENT -------- THE KRAMER FAMILY -------- PETER QUISTGARD AND MARCO HARDMEIER -------- THEME MUSIC WRITTEN BY VIDEO-GAME-MUSIC-EXPLORERS
DATA -------- GUITARS BY KEES ATTINGA -------- PROGRAMMING AND ADDITIONAL GUITARS BY ARNOLD
DATA KRAMER                                                                                                   VISIT \HTTPS>//WWW.YOUTUBE.COM/@TTWARE7430\ FOR MORE T&T WARE GAMES (COPIED TO CLIPBOARD)                                                            ?
DATA 13131313

'        "Mouse" Sub-Routine Copyright 1999 by: Daryl R. Dubbs
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
