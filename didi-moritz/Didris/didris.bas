'                        This is the unbelievable
'        ‹‹‹   ‹‹         ‹‹‹            ‹‹
'       €   € ﬂ‹‹ﬂ       €   €          ﬂ‹‹ﬂ                         ‹  ‹
'       €   €  ‹‹        €   €  ‹‹‹ ‹‹   ‹‹    ‹‹‹‹                ‹ﬂ ‹ﬂ  ‹
'  ‹ﬂﬂﬂﬂ    € €  €  ‹ﬂﬂﬂﬂ    € €   ﬂ  € €  € ‹ﬂ    ﬂ‹          ‹‹ ‹‹    ‹ﬂ
' €         € €  € €         € €   ‹ﬂﬂ  €  € ﬂ‹  ﬂ‹‹ﬂ         €‹ €‹ €
' €         € €  € €         € €  €     €  € ‹ﬂﬂ‹  ﬂ‹  ‹ﬂﬂﬂﬂﬂﬂ    ﬂﬂ
' ﬂ‹        € €  € ﬂ‹        € €  €     €  € ﬂ‹    ‹ﬂ  €              ‹ﬂﬂ‹
'   ﬂﬂﬂﬂﬂﬂﬂﬂ   ﬂﬂ    ﬂﬂﬂﬂﬂﬂﬂﬂ   ﬂﬂ       ﬂﬂ    ﬂﬂﬂﬂ     ﬂﬂﬂﬂﬂ€      ‹   ‹ﬂ
'                                      ver 2.2               ﬂ‹‹‹‹‹ﬂ  ‹  €
'                                  by Dietmar Moritz         €         ﬂﬂ
'                                                            ﬂ‹‹‹‹‹‹
'
' I started this program in summer '97 and finished November '98.
'
' I've done this with Quick Basic 4.5, but you can also run it under QBasic!
' I still have some good ideas for this game, but I wanted to write a game
' which I can compile in only one EXE-File, so I shortened the source code.
' Maybe I will write a new, much more bigger DIDRIS for Quick Basic 4.5 only!
' ---------------------------------------------------------------------------
' Please do NOT run this program under Windows!!!
' It's not as fast as in good old DOS!!!
' I also recommend Quick Basic 4.5!!!
' ---------------------------------------------------------------------------
' Please read the READ ME!!!
' ---------------------------------------------------------------------------
' If you want to e-mail me: didi@forfree.at
'                       or: didi_op@hotmail.com
' ---------------------------------------------------------------------------
' Have fun!!! :-)

' a740g - changes
'   - Replaced Play(x) on/off with Timer(x) on/off
'   - Added delays wherever animations were too fast
'   - Using QB64 defined _Pi

$RESIZE:SMOOTH
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM SHARED bst(1 TO 41, 1 TO 10, 1 TO 10)
DIM SHARED buch(1 TO 5, 1 TO 19, 1 TO 19) AS INTEGER

DIM SHARED bomb AS INTEGER
DIM SHARED nextbomb AS INTEGER

DIM SHARED hf1(1 TO 14, 2 TO 14) AS INTEGER
DIM SHARED hf2(1 TO 14, 2 TO 14) AS INTEGER
DIM SHARED helion AS INTEGER
DIM SHARED blowheli AS INTEGER
DIM SHARED helix AS INTEGER
DIM SHARED heliy AS INTEGER
DIM SHARED helilt
DIM SHARED rotor AS INTEGER

DIM SHARED leiter(1 TO 14, 1 TO 14) AS INTEGER

DIM SHARED tropfen(1 TO 14, 1 TO 14) AS INTEGER

DIM SHARED boom(1 TO 14, 1 TO 14) AS INTEGER

DIM SHARED para(1 TO 14, 1 TO 14) AS INTEGER
DIM SHARED paraon

DIM SHARED maxfeld(1 TO 14, 1 TO 28) AS INTEGER
DIM SHARED bc AS INTEGER
DIM SHARED maxframe AS INTEGER
DIM SHARED maxstill AS INTEGER

CONST linienpunkte = 15

CONST maxacid = 100
CONST acidplus = 4
DIM SHARED acid AS INTEGER
DIM SHARED showallacid AS INTEGER

CONST belegt% = 1
CONST Frei% = 0
CONST maxlinie = 4

CONST fb = 12
CONST fh = 23
CONST bg = 14

DIM SHARED maxposx AS INTEGER
DIM SHARED maxposy AS INTEGER
DIM SHARED maxlt

DIM SHARED feld%(-1 TO fb + 3, -1 TO fh + 2)
DIM SHARED farb%(-1 TO fb + 3, -1 TO fh + 2)
DIM SHARED blockx%(4)
DIM SHARED blocky%(4)

CONST Musikanzahl = 3
DIM SHARED Musiklaenge(Musikanzahl) AS INTEGER
DIM SHARED Musik$(50, Musikanzahl)
DIM SHARED Musikstueck%
DIM SHARED musi%
DIM SHARED nomusik

DIM SHARED punkte AS INTEGER
DIM SHARED Linienweg AS INTEGER
DIM SHARED Level AS INTEGER

DIM SHARED nstr%

DIM SHARED endeundaus

DIM SHARED hoho%(4)

DIM SHARED already AS INTEGER

DIM SHARED yn(1 TO 4) AS INTEGER
FOR I = 1 TO 4
    yn(I) = 1
NEXT I

getsprites

init
init.ffont


RANDOMIZE TIMER

DO

    SCREEN 12

    CLS
    IF already = 0 THEN
        Intro
        CLS
        Titel
        CLS
    END IF

    menu
    main

    PALETTE
    COLOR
    clear.var
    already = 1
LOOP

keine:
h = 1
RESUME NEXT



hinter:
IF PLAY(-1) > 1 THEN RETURN ' avoid queueing music if we have enough to play

IF musi% < Musiklaenge(Musikstueck%) THEN
    musi% = musi% + 1
ELSE
    musi% = 1:
    m% = Musikstueck%
    DO
        Musikstueck% = INT(RND * (Musikanzahl)) + 1
    LOOP UNTIL Musikstueck% <> m%
    PLAY "mb p1"
END IF
PLAY "mb" + Musik$(musi%, Musikstueck%)
RETURN

'Fallschirm
DATA ,,,,2,2,1,1,2,2,,,,
DATA ,,2,2,1,2,2,2,2,1,2,2,,
DATA 1,2,2,2,2,1,2,2,1,2,2,2,2,1
DATA 2,1,2,2,,,,,,2,2,2,1,2
DATA 2,2,1,7,,,,,,,7,1,2,2
DATA 7,,,7,,,,,,,7,,,7
DATA ,7,,,7,,,,,7,,,7,
DATA ,7,,,7,,,,,7,,,7,
DATA ,,7,,,7,,,7,,,7,,
DATA ,,7,,,7,,,7,,,7,,
DATA ,,,7,,7,,,7,,7,,,
DATA ,,,7,,,7,7,,,7,,,
DATA ,,,,7,,7,7,,7,,,,
DATA ,,,,7,,7,7,,7,,,,

'Explosion
DATA 4,,,,,,4,4,,,,,4,4
DATA 4,4,,,,4,4,4,4,,,4,4,4
DATA 4,4,4,,,4,12,12,4,4,4,4,4,4
DATA 4,4,4,4,4,4,12,12,12,12,12,12,4,
DATA ,4,4,12,12,12,12,12,14,14,12,12,4,
DATA ,,4,12,14,14,14,14,14,14,14,12,4,4
DATA ,4,4,12,12,14,14,14,14,12,12,12,12,4
DATA ,4,12,12,14,14,14,14,14,14,12,12,4,4
DATA 4,4,12,12,12,14,14,14,14,14,12,4,4,
DATA 4,12,12,12,14,14,12,12,14,14,12,4,,
DATA 4,4,4,12,12,12,12,12,12,12,12,4,,
DATA ,,4,12,12,4,4,4,4,12,12,4,4,
DATA ,4,4,12,4,4,,,4,4,4,4,4,4
DATA ,4,4,4,4,,,,,4,,,4,4

'Tropfen
DATA ,,,,,,1,,,,,,,
DATA ,,,,,,1,1,,,,,,
DATA ,,,,,,1,1,1,,,,,
DATA ,,,,,,1,2,1,,,,,
DATA ,,,,,1,1,2,1,1,,,,
DATA ,,,,,1,2,2,2,1,,,,
DATA ,,,,1,1,2,10,2,1,1,,,
DATA ,,,1,1,2,2,10,2,2,1,,,
DATA ,,1,1,2,2,3,10,10,2,1,1,,
DATA ,,1,2,2,3,10,10,10,2,2,1,,
DATA ,,1,2,2,10,10,10,10,2,2,1,,
DATA ,,1,1,2,2,10,10,2,2,1,,,
DATA ,,,1,1,2,2,2,2,1,1,,,
DATA ,,,,1,1,1,1,1,1,,,,

'Leiter
DATA ,6,,,,,,,,,,6,,
DATA ,6,,,,,,,,,6,6,,
DATA 6,7,6,6,6,6,6,6,6,6,7,,,
DATA 6,6,,,,,,,,,6,6,,
DATA ,6,,,,,,,,,,6,,
DATA ,7,6,6,6,6,6,6,6,6,6,7,,
DATA ,6,,,,,,,,,,6,,
DATA ,6,,,,,,,,,,6,,
DATA ,6,,,,,,,,,,6,,
DATA 6,7,6,6,6,6,6,6,6,6,6,7,,
DATA 6,,,,,,,,,,6,,,
DATA 6,,,,,,,,,,6,,,
DATA 6,7,6,6,6,6,6,6,6,6,7,6,,
DATA ,6,,,,,,,,,,6,,

'max
DATA ,,,,,8,8,8,8,,,,,
DATA ,,,,8,8,8,8,8,8,,,,
DATA ,,,,,12,9,9,12,,,,,
DATA ,,,,,12,12,12,12,,,,,
DATA ,,,,,,12,12,,,,,,
DATA ,,,,2,2,2,8,7,2,,,,
DATA ,,,8,2,8,2,2,2,2,7,,,
DATA ,,2,7,,7,8,2,2,,8,2,,
DATA ,,13,,,2,2,7,8,,,13,,
DATA ,,,,,8,2,2,2,,,,,
DATA ,,,,,7,2,8,2,,,,,
DATA ,,,,8,2,,,7,2,,,,
DATA ,,,,7,2,,,2,8,,,,
DATA ,,,6,6,6,,,6,6,6,,,

DATA ,,,,,8,8,8,8,,,,,
DATA ,,,,8,8,8,8,8,8,,,,
DATA ,,,,,12,9,9,12,,,,,
DATA ,,13,,,12,12,12,12,,,13,,
DATA ,,2,7,,,12,12,,,8,2,,
DATA ,,,8,2,2,2,8,7,2,7,,,
DATA ,,,8,2,8,2,2,2,2,,,,
DATA ,,,,,7,8,2,2,,,,,
DATA ,,,,,2,2,7,8,,,,,
DATA ,,,,,8,2,2,2,,,,,
DATA ,,,,,7,2,8,2,,,,,
DATA ,,,,8,2,,,7,2,,,,
DATA ,,,,7,2,,,2,8,,,,
DATA ,,,6,6,6,,,6,6,6,,,

'heli
DATA ,,,,,,,,,,,,,,,15,15,,,,,,,,,,,
DATA ,,,,,,,,,,,,,,4,4,4,4,4,4,4,4,,,,,,
DATA 2,4,,,,,,,,,,,4,4,4,4,4,4,4,4,4,4,1,1,,,,
DATA 4,4,7,,,,,,,,,,4,4,4,4,4,,,,4,4,1,1,1,,,
DATA 4,7,7,7,,,,,,,,4,4,4,4,4,4,,,,4,4,4,1,1,1,,
DATA 7,7,8,7,7,,,,,,,4,4,4,4,4,4,,,,4,4,4,1,1,1,,
DATA 4,7,7,7,4,4,4,4,4,4,4,4,4,4,4,4,4,,,,,4,4,4,1,1,,
DATA 4,4,7,4,4,4,4,4,4,4,4,4,4,4,4,4,4,,,,,4,4,4,4,4,,
DATA ,,,,,,,,,,,4,4,4,4,4,4,,,,,4,4,8,8,8,8,8
DATA ,,,,,,,,,,,,4,4,4,4,4,4,4,4,4,4,4,4,4,4,,
DATA ,,,,,,,,,,,,,4,4,4,4,4,4,4,4,4,4,4,4,,,
DATA ,,,,,,,,,,,,,,,4,,,,,,,4,,,,8,
DATA ,,,,,,,,,,,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,

'Font
DATA 1,1,1,1,,,1,,,1,,1,1,1,,,1,,,1,1,1,1,1,,,1,1,1,,1,,,,,1,,,,,1,,,,1,,1,1,1,
DATA 1,1,1,1,,,1,,,1,,1,,,1,,1,,,1,1,1,1,1,,1,1,1,1,1,1,,,,,1,1,1,1,,1,,,,,1,1,1,1,1
DATA 1,,,,1,1,1,,,1,1,,1,,1,1,,,1,1,1,,,,1,,1,1,1,,1,,,,1,1,,,,1,1,,,,1,,1,1,1,
DATA 1,1,1,1,,1,,,,1,1,1,1,1,,1,,,,,1,,,,,,1,1,1,,1,,,,1,1,,1,,1,1,,,1,1,,1,1,1,1
DATA 1,1,1,1,,1,,,,1,1,1,1,1,,1,,,1,,1,,,,1,,1,1,1,1,1,,,,,,1,1,1,,,,,,1,1,1,1,1,
DATA 1,1,1,1,1,,,1,,,,,1,,,,,1,,,,,1,,,1,,,,1,1,,,,1,1,,,,1,1,,,,1,,1,1,1,
DATA 1,,,,1,,1,,1,,,,1,,,,,1,,,,,1,,,,1,1,1,,1,,,1,1,1,,1,,1,1,1,,,1,,1,1,1,
DATA ,,1,,,,1,1,,,,,1,,,,,1,,,,1,1,1,,,1,1,1,,1,,,,1,,,1,1,,,1,,,,1,1,1,1,1
DATA 1,1,1,1,,,,,,1,,1,1,1,,,,,,1,1,1,1,1,,,,,1,,,,1,1,,,1,,1,,1,1,1,1,1,,,,1,
DATA 1,1,1,1,,1,,,,,1,1,1,1,,,,,,1,1,1,1,1,,,1,1,1,,1,,,,,1,1,1,1,,1,,,,1,,1,1,1,
DATA 1,1,1,1,1,,,,,1,,,,1,,,,1,,,,,1,,,,1,1,1,,1,,,,1,,1,1,1,,1,,,,1,,1,1,1,
DATA ,1,1,1,,1,,,,1,,1,1,1,1,,,,,1,,1,1,1,,,,,,,,1,,,,,,,,,,1,,,,,,,,
DATA ,,,,,,,,,,1,1,1,1,,,,,,,,,,,

'READY
DATA 7,3,13,,3,,12,,3,,12,,3,,11,,5,,10,,5,,10,,5,,9,,7,,9,5,2,,x,,2,,7,6,3,,6,,9,,6,,9,,6,,9,,5,,11,,4,,11,,4,,11,,4,,11,,2,2,13,2,2,10,6,,10,2,4,,12,,3,,13,,2,
DATA 13,,2,,x,,,,x,,,,x,,,,x,,,,x,,,,x,,,,x,,,,x,,,,13,2,,,13,,2,,12,,3,,10,2,4,,9,,5,,11,5,3,12,4,,12,,3,,2,10,4,,,,x,,,,x,,,,x,,,,x,,,,x,,2,8
DATA 6,,10,,5,,2,8,6,,,,x,,,,x,,,,x,,,,x,,,,x,,2,10,4,,12,,,2,x,,3,7,9,,7,2,7,,9,,6,,10,,5,,10,,5,,10,,5,,10,,5,,9,,6,,7,2,7,,4,3,9,,3,,12,,3,,12,,4,,11,,5,
DATA 10,,6,,9,,7,,8,,8,,7,,9,,4,2,11,4,3,,9,,5,,,,7,,,,4,,2,,5,,2,,5,,,,5,,,,6,,2,,3,,2,,7,,,,3,,,,8,,2,,,,2,,9,,2,,2,,11,,3,,13,,,,x,,,,x,,,,x,,,,x,,,,x,,,,x,,,,x,,,,x,,,,7,7,3,7

DATA "T240l8n38n39n40l4n48l8n40l4n48l8n40l4n48p64p64l8n48n50"
DATA "l8n51n52n48n50l4n52l8n47l4n50l3n48l8n38n39"
DATA "l8n40l4n48l8n40l4n48l8n40l4n48p64p64l8n45n43n42l8n45"
DATA "l8n48l4n52l8n50l8n48l8n45l3n50l8n38n39n40l4n48"
DATA "l8n40l4n48l8n40l4n48p64p64l8n48n50n51n52n48n50"
DATA "l4n52l8n47l4n50n48p64l8n48n50n52n48n50l4n52"
DATA "l8n48n50n48n52n48l8n50l4n52l8n48n50n48"
DATA "l8n52n48n50l4n52l8n47l4n50l4n48p64l8n40l8n41l8n42"
DATA "l4n43l8n45l4n43l8n40l8n41l8n42l4n43l8n45l4n43l8n52"
DATA "l8n48l8n43l8n45l8n47l8n48l8n50l8n52l8n50l8n48l8n50"
DATA "l4n43p64l8n43l8n40l8n41l4n43l8n45l4n43l8n40l8n41l8n42"
DATA "l4n43l8n45l8n43p64l8n43l8n45l8n46l8n47l8n47p64l4n47l8n45"
DATA "l8n42l8n38l4n43"
DATA "MUSIKENDE"

DATA "T110l6n35l16n36l3n38l16n35l8n33l16n35l2n31l6n35l16n35"
DATA "l6n33l16n31l3n28l16n28l6n35l16n35l2n33l6n35l16n36l3n38"
DATA "l16n35l8n33l16n35l2n31l6n35l16n35l6n33l16n31l3n28l16n28"
DATA "l6n35l16n35l2n33l6n35l16n36l3n38l16n35l8n33l16n35l2n31"
DATA "l6n35l16n35l6n33l16n31l3n28l16n28l6n35l16n35l2n33l6n35"
DATA "l16n36l3n38l16n35l8n33l16n35l2n31l6n35l16n35l6n33l16n31"
DATA "l3n28l16n28l6n35l16n35l2n33p64p64l5n38l5n38l5n38l6n38l16n40"
DATA "l6n33l16n33l6n33l16n33l2n33l6n33l16n33l6n33l16n33l2n33"
DATA "l6n31l16n31l6n31l16n31l2n31l5n38l5n38l5n38l6n38l16n40"
DATA "l6n33l16n33l6n33l16n33l2n33l6n33l16n33l6n33l16n33l2n33"
DATA "l6n31l16n31l6n31l16n31l2n31"
DATA "MUSIKENDE"

DATA "T220MSl3n40l8n40l4n43l4n47l4n46n46l2n42l4n33l4n33"
DATA "l4n33n33n35n35l2n35l3n40l8n40l4n43l4n47l4n49"
DATA "l4n49n46n49n51n48n43n45l2n47l8n47n45"
DATA "l8n43n42l2n40l4n31l7n43l8n47l4n52n52n51n54"
DATA "l2n52l4n31l8n43l8n47l4n52l4n52n51n54l2n52l8n47"
DATA "l8n45n43n42l3n40l8n40l4n43n47n46n46l2n42"
DATA "l4n33n33n33n33n35n35l2n35l3n40l8n40l4n43"
DATA "l4n47n49n49n46n49n51n48n43n45l2n47l8n47n45n43n42l2n40"
DATA "l4n31l7n43l8n47l4n52n52n51n54l2n52l4n31l8n43"
DATA "l8n47l4n52n52n51n54l2n52l8n47n45n43n42"
DATA "MUSIKENDE"

SUB acidrain
    maxar = fb
    DIM ar(maxar) AS INTEGER
    DIM armax(maxar) AS INTEGER
    FOR x% = 1 TO fb
        FOR y% = 1 TO fh - 1
            IF feld%(x%, y%) = belegt% THEN EXIT FOR
        NEXT y%
        armax(x%) = y%
        IF feld%(x%, y%) = belegt% THEN
            feld%(x%, y%) = Frei%
            farb%(x%, y%) = 0
        END IF
    NEXT x%
    FOR I% = 1 TO maxar
        ar(I%) = INT(RND * (3)) - 3
    NEXT I%
    DO
        FOR I% = 1 TO maxar
            IF ar(I%) < armax(I%) THEN
                ar(I%) = ar(I%) + 1
                kastl I%, ar(I%), 33
            END IF
        NEXT I%
        t = TIMER
        DO
        LOOP UNTIL TIMER >= t + .15
        FOR I% = 1 TO maxar
            kastl I%, ar(I%), 0
        NEXT I%
        chk = 0
        FOR I% = 1 TO maxar
            IF ar(I%) >= armax(I%) THEN chk = chk + 1
        NEXT I%
        IF chk = maxar THEN EXIT DO
    LOOP
    nichtganzalles
    IF yn(4) = 1 THEN
        acid = 0
        show.acidometer
    END IF
END SUB

SUB alles

    FOR x% = -480 TO 640 STEP 20
        FOR I% = 0 TO 2
            LINE (x% + I%, 0)-(x% + 480 + I%, 480), 8
            LINE (x% - I%, 0)-(x% + 480 - I%, 480), 7
            LINE (x% - I% + 480, 0)-(x% - I%, 480), 7
            LINE (x% + 480 + I%, 0)-(x% + I%, 480), 8
        NEXT I%
    NEXT x%

    LINE (320 + 1 - fb * bg / 2, 240 + 1 - fh * bg / 2 + bg)-(321 - 1 + fb * bg / 2, 240 - 1 + fh * bg / 2 + 1 + bg), 0, BF

    x1% = ((320 - fb * bg / 2) + ((-4) * bg) + 1)
    y1% = ((240 - fh * bg / 2) + ((1) * bg) + 1)
    x2% = ((320 - fb * bg / 2 - 1) + ((-1) * bg) + 1)
    y2% = ((240 - fh * bg / 2) + (5) * bg)
    LINE (x1%, y1%)-(x2%, y2%), 0, BF
    LINE (x1% - 1, y1% - 1)-(x2% + 1, y2% + 1), 2, B

    COLOR 8
    u = 10

    DRAW "c1 bm190,70 u40 r 20 F30 d10 l30 u10 r13 h17 l3 d27 l13"
    PAINT (191, 68), 2, 1
    DRAW "c1 bm250,70 u40 r13 d40 l13"
    PAINT (253, 68), 2, 1
    DRAW "c1 bm275,70 u40 r 20 F30 d10 l30 u10 r13 h17 l3 d27 l13"
    PAINT (277, 68), 2, 1
    DRAW "c1 bm335,70 u40 r22"
    LINE -STEP(20, 15), 1
    LINE -STEP(-16, 10), 1
    DRAW "f15 l13 h12 u7"
    LINE -STEP(9, -6), 1
    LINE -STEP(-8, -5), 1
    DRAW "l4 d30 l12"
    PAINT (337, 68), 2, 1
    DRAW "c1 bm385,70 u40 r13 d40 l13"
    PAINT (387, 68), 2, 1
    DRAW "c1 bm410,70 u10 r23 e5 l27 u15 e10 r30 d10 l23 g5 r27 d15 g10 l30"
    PAINT (413, 68), 2, 1

    Tasten
    Punktezahl
    nichtganzalles

    IF yn(4) = 1 THEN
        COLOR 11
        LOCATE 26, 10: PRINT "Acid-O-Meter"
        showallacid = 1
        show.acidometer
        showallacid = 0
    END IF

    IF yn(3) = 1 THEN
        LINE (220, 440)-(420, 470), 0, BF
        LINE (220, 440)-(420, 470), 15, B
        show.font2 "BODY-COUNT:", 2, 0, 1, 235, 448
        show.bodycount
    END IF
 
END SUB

SUB ausis
    'TODO
    TIMER OFF
    IF PLAY(1) <> 0 THEN BEEP

    showpoints
    showhiscore

    endeundaus = 1
END SUB

SUB ausss
    show.verynicegraphic

    SCREEN 0
    COLOR 1, 4
    PRINT "Freeware                                                      by Dietmar Moritz"
    PRINT
    COLOR 2, 0
    PRINT "Thanks for playing"
    COLOR 15, 0
    PRINT
    PRINT "         /±±±±±      /±±    /±±±±±      /±±±±±±     /±±     /±±±±±"
    PRINT "        ≥ ±±_/±±    ≥ ±±   ≥ ±±_/±±    ≥ ±±__/±±   ≥ ±±    /±±__/±±"
    PRINT "        ≥ ±±≥//±±   ≥ ±±   ≥ ±±≥//±±   ≥ ±±±±±±/   ≥ ±±   ≥/_/±±/_/"
    PRINT "        ≥ ±± ≥ ±±   ≥ ±±   ≥ ±± ≥ ±±   ≥ ±±/±±/    ≥ ±±     ≥//±±"
    PRINT "        ≥ ±± /±±/   ≥ ±±   ≥ ±± /±±/   ≥ ±±//±±    ≥ ±±    /±±/_/±±"
    PRINT "        ≥ ±±±±±/    ≥ ±±   ≥ ±±±±±/    ≥ ±±≥//±±   ≥ ±±   ≥//±±±±±/"
    PRINT "        ≥/___/      ≥/_/   ≥/____/     ≥/_/ ≥/_/   ≥/_/    ≥/____/  ";
    COLOR 3
    PRINT " v2.2"
    PRINT SPC(67); "(22.11.98)"
    COLOR 8, 0
    FOR y% = 2 TO 25
        FOR x% = 1 TO 80
            IF SCREEN(y%, x%) = 179 THEN LOCATE y%, x%: PRINT "≥"
            IF SCREEN(y%, x%) = ASC("/") THEN LOCATE y%, x%: PRINT "/"
            IF SCREEN(y%, x%) = ASC("_") THEN LOCATE y%, x%: PRINT "_"
        NEXT x%
    NEXT y%
    END
END SUB

SUB clear.var

    bomb = 0
    nextbomb = 0

    helion = 0
    blowheli = 0
    helix = 0
    heliy = 0
    helilt = 0
    rotor = 0
    bc = 0
    maxframe = 0
    maxstill = 0

    acid = 0
    showallacid = 0

    maxposx = 0
    maxposy = 0
    maxlt = 0

    FOR x% = -1 TO fb + 3
        FOR y% = -1 TO fh + 2
            feld%(x%, y%) = 0
            farb%(x%, y%) = 0
        NEXT y%
    NEXT x%

    punkte = 0
    Linienweg = 0
    Level = 0

    nstr% = 0

    endeundaus = 0
END SUB

SUB drehen (struktur%)
    SELECT CASE struktur%
        CASE 1
            IF (blockx%(2) + 1 = blockx%(1)) AND (feld%(blockx%(1) + 1, blocky%(1)) <> belegt%) THEN
                blockx%(3) = blockx%(3) - 1: blocky%(3) = blocky%(2)
                blockx%(2) = blockx%(4): blocky%(2) = blocky%(4)
                blockx%(4) = blockx%(1) + 1: blocky%(4) = blocky%(1)
                HE = 1
            END IF
            IF (blockx%(4) + 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(1) - 1) <> belegt%) THEN
                blockx%(3) = blockx%(2): blocky%(3) = blocky%(2)
                blockx%(2) = blockx%(4): blocky%(2) = blocky%(4)
                blockx%(4) = blockx%(1): blocky%(4) = blocky%(1) - 1
            END IF
            IF (blockx%(1) + 1 = blockx%(2)) AND (feld%(blockx%(1) - 1, blocky%(1)) <> belegt%) THEN
                blockx%(3) = blockx%(2): blocky%(3) = blocky%(2)
                blockx%(2) = blockx%(4): blocky%(2) = blocky%(4)
                blockx%(4) = blockx%(1) - 1: blocky%(4) = blocky%(1)
            END IF
            IF (HE <> 1) AND (blockx%(3) + 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(1) + 1) <> belegt%) THEN
                blockx%(3) = blockx%(2): blocky%(3) = blocky%(2)
                blockx%(2) = blockx%(4): blocky%(2) = blocky%(4)
                blockx%(4) = blockx%(1): blocky%(4) = blocky%(1) + 1
            END IF
        CASE 3
            IF (blocky%(3) + 1 = blocky%(1)) AND (feld%(blockx%(1), blocky%(4)) <> belegt%) AND (feld%(blockx%(1) - 1, blocky%(4)) <> belegt%) THEN
                blockx%(4) = blockx%(1)
                blockx%(3) = blockx%(1) - 1: blocky%(3) = blocky%(4)
                HE = 1
            END IF
            IF (HE <> 1) AND (blocky%(3) - 1 = blocky%(1)) AND (feld%(blockx%(1), blocky%(2) - 1) <> belegt%) AND (feld%(blockx%(2), blocky%(4)) <> belegt%) THEN
                blockx%(4) = blockx%(2)
                blockx%(3) = blockx%(1): blocky%(3) = blocky%(1) - 1
            END IF
        CASE 4
            IF (blocky%(3) + 1 = blocky%(1)) AND (feld%(blockx%(2), blocky%(4)) <> belegt%) AND (feld%(blockx%(2) + 1, blocky%(4)) <> belegt%) THEN
                blockx%(4) = blockx%(2)
                blockx%(3) = blockx%(2) + 1: blocky%(3) = blocky%(4)
                HE = 1
            END IF
            IF (HE <> 1) AND (blocky%(3) - 1 = blocky%(1)) AND (feld%(blockx%(2), blocky%(2) - 1) <> belegt%) AND (feld%(blockx%(1), blocky%(4)) <> belegt%) THEN
                blockx%(4) = blockx%(1)
                blockx%(3) = blockx%(2): blocky%(3) = blocky%(1) - 1
            END IF
        CASE 5
            IF (blocky%(2) + 1 = blocky%(1)) AND (feld%(blockx%(3), blocky%(1)) <> belegt%) AND (feld%(blockx%(3), blocky%(1) + 1) <> belegt%) AND (feld%(blockx%(1) - 1, blocky%(1)) <> belegt%) THEN
                blockx%(2) = blockx%(3): blocky%(2) = blocky%(1)
                blocky%(3) = blocky%(4)
                blockx%(4) = blockx%(4) - 1: blocky%(4) = blocky%(1)
                HE = 1
            END IF
            IF (HE <> 1) AND (blockx%(2) - 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(3)) <> belegt%) AND (feld%(blockx%(4), blocky%(3)) <> belegt%) AND (feld%(blockx%(1), blocky%(1) - 1) <> belegt%) THEN
                blockx%(2) = blockx%(1): blocky%(2) = blocky%(3)
                blockx%(3) = blockx%(4)
                blockx%(4) = blockx%(1): blocky%(4) = blocky%(1) - 1
                HE = 1
            END IF
            IF (HE <> 1) AND (blocky%(2) - 1 = blocky%(1)) AND (feld%(blockx%(3), blocky%(1)) <> belegt%) AND (feld%(blockx%(2) + 1, blocky%(1)) <> belegt%) AND (feld%(blockx%(3), blocky%(4)) <> belegt%) THEN
                blockx%(2) = blockx%(3): blocky%(2) = blocky%(1)
                blocky%(3) = blocky%(4)
                blockx%(4) = blockx%(4) + 1: blocky%(4) = blocky%(1)
                HE = 1
            END IF
            IF (HE <> 1) AND (blockx%(2) + 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(3)) <> belegt%) AND (feld%(blockx%(4), blocky%(3)) <> belegt%) AND (feld%(blockx%(1), blocky%(1) + 1) <> belegt%) THEN
                blockx%(2) = blockx%(1): blocky%(2) = blocky%(3)
                blockx%(3) = blockx%(4)
                blockx%(4) = blockx%(1): blocky%(4) = blocky%(1) + 1
                HE = 1
            END IF
        CASE 6
            IF (blocky%(2) + 1 = blocky%(1)) AND (feld%(blockx%(3), blocky%(1)) <> belegt%) AND (feld%(blockx%(3), blocky%(4)) <> belegt%) AND (feld%(blockx%(1) + 1, blocky%(1)) <> belegt%) THEN
                blockx%(2) = blockx%(3) + 2: blocky%(2) = blocky%(1)
                blockx%(3) = blockx%(2)
                blockx%(4) = blockx%(4) - 1: blocky%(4) = blocky%(1)
                HE = 1
            END IF
            IF (HE <> 1) AND (blockx%(2) - 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(3)) <> belegt%) AND (feld%(blockx%(3), blocky%(2) + 1) <> belegt%) AND (feld%(blockx%(1), blocky%(1) + 1) <> belegt%) THEN
                blockx%(2) = blockx%(1): blocky%(2) = blocky%(1) + 1
                blocky%(3) = blocky%(2)
                blockx%(4) = blockx%(1): blocky%(4) = blocky%(1) - 1
                HE = 1
            END IF
            IF (HE <> 1) AND (blocky%(2) - 1 = blocky%(1)) AND (feld%(blockx%(3), blocky%(1)) <> belegt%) AND (feld%(blockx%(2) - 1, blocky%(1)) <> belegt%) AND (feld%(blockx%(2) - 1, blocky%(2)) <> belegt%) THEN
                blockx%(2) = blockx%(2) - 1: blocky%(2) = blocky%(1)
                blockx%(3) = blockx%(2)
                blockx%(4) = blockx%(4) + 1: blocky%(4) = blocky%(1)
                HE = 1
            END IF
            IF (HE <> 1) AND (blockx%(2) + 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(3)) <> belegt%) AND (feld%(blockx%(2), blocky%(2) - 1) <> belegt%) AND (feld%(blockx%(1), blocky%(1) - 1) <> belegt%) THEN
                blockx%(2) = blockx%(1): blocky%(2) = blocky%(2) - 1
                blocky%(3) = blocky%(2)
                blockx%(4) = blockx%(1): blocky%(4) = blocky%(1) + 1
                HE = 1
            END IF
        CASE 7
            IF (blocky%(2) + 1 = blocky%(1)) AND (feld%(blockx%(1) - 1, blocky%(1)) <> belegt%) AND (feld%(blockx%(1) + 1, blocky%(1)) <> belegt%) AND (feld%(blockx%(1) + 2, blocky%(1)) <> belegt%) THEN
                FOR I% = 2 TO 4
                    blocky%(I%) = blocky%(1)
                NEXT I%
                blockx%(2) = blockx%(1) - 1
                blockx%(3) = blockx%(1) + 1
                blockx%(4) = blockx%(1) + 2
                HE = 1
            END IF
            IF (HE <> 1) AND (blockx%(2) + 1 = blockx%(1)) AND (feld%(blockx%(1), blocky%(1) - 1) <> belegt%) AND (feld%(blockx%(1), blocky%(1) + 1) <> belegt%) AND (feld%(blockx%(1), blocky%(1) + 2) <> belegt%) THEN
                FOR I% = 2 TO 4
                    blockx%(I%) = blockx%(1)
                NEXT I%
                blocky%(2) = blocky%(1) - 1
                blocky%(3) = blocky%(1) + 1
                blocky%(4) = blocky%(1) + 2
            END IF
    END SELECT
END SUB

FUNCTION fax (x, z, zx, zz)
    fax = (zx * z - zz * x) / (z - zz)
END FUNCTION

FUNCTION fay (y, z, zy, zz)
    fay = (zy * z - zz * y) / (z - zz)
END FUNCTION

SUB fire (x%, y%)
    DO
        IF INKEY$ <> "" THEN EXIT DO
        ax% = x%
        ay% = y%
        select.case oldi%, ax%, ay%
        IF POINT(ax%, ay%) <> 10 THEN
            FOR I% = 1 TO 9
                ax% = x%
                ay% = y%
                select.case I%, ax%, ay%
                IF I% = 9 THEN EXIT DO
                IF POINT(ax%, ay%) = 10 THEN EXIT FOR
            NEXT I%
        ELSE
            I% = oldi%
        END IF

        oldi% = I%
        x% = ax%
        y% = ay%
        PSET (x%, y%), 4
        FOR w = 0 TO 2 * _PI STEP .8
            FOR I% = 1 TO 4
                IF POINT(x% + SIN(w) * I%, y% + COS(w) * I%) = 0 THEN
                    PSET (x% + SIN(w) * I%, y% + COS(w) * I%), 4
                END IF
            NEXT I%
        NEXT w
        SELECT CASE INT(RND * (1))
            CASE 0: COLOR 0
        END SELECT
        IF INKEY$ <> "" THEN EXIT DO
        PSET (x%, y%)
        FOR w = 0 TO 2 * _PI STEP .8
            FOR I% = 1 TO 4
                IF POINT(x% + SIN(w) * I%, y% + COS(w) * I%) = 4 THEN
                    PSET (x% + SIN(w) * I%, y% + COS(w) * I%), 0
                END IF
            NEXT I%
        NEXT w
        _LIMIT 60
    LOOP
    LINE (265, 200)-STEP(120, 50), 0, BF
END SUB

SUB getsprites
    FOR I% = 1 TO 6
        FOR y% = 1 TO 14
            FOR x% = 1 TO 14
                READ a
                SELECT CASE I%
                    CASE 1: IF a = 2 THEN a = 15
                        para(x%, y%) = a
                    CASE 2: boom(x%, y%) = a
                    CASE 3: tropfen(x%, y%) = a
                    CASE 4: leiter(x%, y%) = a
                    CASE 5: IF a = 2 THEN a = 10
                        maxfeld(x%, y%) = a
                    CASE 6: IF a = 2 THEN a = 10
                        maxfeld(x%, y% + 14) = a
                END SELECT
            NEXT x%
        NEXT y%
    NEXT I%

    FOR y% = 2 TO 14
        FOR x% = 1 TO 28
            READ a
            IF a = 4 THEN a = INT(RND * (2)) * 8 + 2
            IF x% < 15 THEN
                hf1(x%, y%) = a
            ELSE
                hf2(x% - 14, y%) = a
            END IF
        NEXT x%
    NEXT y%
END SUB

SUB gettaste (z$, posit%, max)
    DO
        z$ = INKEY$
    LOOP UNTIL z$ <> ""
    SELECT CASE RIGHT$(z$, 1)
        CASE "8", "H": IF posit% > 1 THEN posit% = posit% - 1
        CASE "2", "P": IF posit% < max THEN posit% = posit% + 1
    END SELECT
END SUB

SUB grey
    setgrey 1, 4
    setgrey 2, 24
    setgrey 3, 28
    setgrey 4, 12
    setgrey 5, 17
    setgrey 6, 24
    setgrey 7, 41
    setgrey 8, 20
    setgrey 9, 25
    setgrey 10, 45
    setgrey 11, 49
    setgrey 12, 33
    setgrey 13, 37
    setgrey 14, 57
    setgrey 15, 62
END SUB

SUB heli
    show.heli 0

    I% = INT(RND * (9)) - 1
    ii% = INT(RND * (9)) - 1

    IF I% >= 2 THEN
        IF maxposx <= helix THEN
            I% = -1
        ELSE
            I% = 1
        END IF
        IF maxposx = helix + 1 THEN I% = 0
    END IF

    IF ii% >= 2 THEN
        IF maxposy > heliy THEN
            ii% = 1
        ELSE
            ii% = -1
        END IF
        IF maxposy = heliy - 1 THEN ii% = 0
    END IF


    chk1% = 1
    chk2% = 1

    FOR u% = 1 TO 4
        IF blockx%(u%) = helix + I% AND blocky%(u%) = heliy THEN chk1% = 0
        IF blockx%(u%) = helix + I% + 1 AND blocky%(u%) = heliy THEN chk1% = 0
        IF blockx%(u%) = helix AND blocky%(u%) = heliy + ii% THEN chk2% = 0
        IF blockx%(u%) = helix + 1 AND blocky%(u%) = heliy + ii% THEN chk2% = 0
    NEXT u%

    IF feld%(helix + I%, heliy) = Frei% AND chk1% AND feld%(helix + I% + 1, heliy) = Frei% THEN
        helix = helix + I%
    END IF

    IF feld%(helix, heliy + ii%) = Frei% AND chk2% AND feld%(helix + 1, heliy + ii%) = Frei% THEN
        heliy = heliy + ii%
    END IF


    IF helix = 0 THEN maxposx = 2
    IF helix + 1 >= fb + 1 THEN helix = fb - 1

    IF heliy = 0 THEN heliy = 1
    IF heliy = fh THEN heliy = fh - 1
 
    helilt = TIMER
    show.heli 1

    IF helix + 1 = maxposx AND heliy + 1 = maxposy THEN heligetsmax
END SUB

SUB heligetsmax
    x1% = ((320 - fb * bg / 2) + ((helix) * bg) + 1)
    y1% = ((240 - fh * bg / 2) + ((heliy + 1) * bg) + 1)

    FOR u% = 1 TO 4
        kastl blockx%(u%), blocky%(u%), 0
    NEXT u%

    kastl maxposx, maxposy, 0
    maxframe = 2
    kastl maxposx, maxposy, 55
 
    FOR y% = 1 TO 14
        FOR x% = 1 TO 14
            IF leiter(x%, y%) > 0 THEN PSET (x% + x1% - 1, y% + y1% - 1), leiter(x%, y%)
        NEXT x%
    NEXT y%

    t = TIMER
    DO
    LOOP UNTIL TIMER >= t + 2

    kastl helix + 1, heliy + 1, 0
    FOR y% = 1 TO 14
        FOR x% = 1 TO 14
            IF leiter(x%, y%) > 0 THEN PSET (x% + x1% - 1, y% + y1% - 1), leiter(x%, y%)
        NEXT x%
    NEXT y%

    t = TIMER
    DO
    LOOP UNTIL TIMER >= t + 1

    kastl maxposx, maxposy, 0

    DO

        t = TIMER
        DO
        LOOP UNTIL TIMER >= t + .2

        show.heli 0
        heliy = heliy - 1
        IF heliy = 0 THEN helion = 0: bc = bc - 1: nichtganzalles: killmax: EXIT DO
        show.heli 1
 
    LOOP

    punkte = punkte - 100
    IF punkte < 0 THEN punkte = 0
    Punktezahl
END SUB

SUB init

    FOR I% = 2 TO 5
        GOSUB ini
    NEXT I%

    FOR I% = 14 TO 21
        GOSUB ini
    NEXT I%

    I% = 25
    GOSUB ini

    FOR I% = 30 TO 41
        GOSUB ini
    NEXT I%

    EXIT SUB

    ini:

    FOR y% = 1 TO 5
        FOR x% = 1 TO 5
            READ a
            bst(I%, x%, y%) = a
        NEXT x%
    NEXT y%
    RETURN

END SUB

SUB init.ffont
    I% = 1
    x% = 1
    y% = 1
    u% = 1
    a = 1

    DO
        READ aa$

        IF aa$ = "x" THEN aa$ = "14"
        IF aa$ = "" THEN aa$ = "1"

        IF a THEN
            a = 0
        ELSE
            a = 1
        END IF

        num = VAL(aa$)

        FOR k = u% TO (u% + num - 1)
            x% = x% + 1
            IF x% = 19 THEN x% = 2: y% = y% + 1
            IF y% = 20 THEN y% = 1: I% = I% + 1: x% = 2

            buch(I%, x%, y%) = a
 
        NEXT k

        u% = k

        IF k >= 1616 THEN EXIT DO

    LOOP


    FOR I% = 1 TO 5
        buch(I%, 19, 19) = 1
        buch(I%, 1, 19) = 1
    NEXT I%

END SUB

SUB Intro
    IF INKEY$ = CHR$(27) THEN EXIT SUB
    SLEEP 1
    DIM d(5) AS STRING
    DIM I(5) AS STRING
    DIM dx(1) AS SINGLE
    DIM dy(1) AS SINGLE
    DIM ix(1) AS SINGLE
    DIM iy(1) AS SINGLE
    dx(0) = 1
    dy(0) = 1
    dx(1) = 80 - 6
    dy(1) = 1
    ix(0) = 1
    iy(0) = 23
    ix(1) = 80 - 4
    iy(1) = 23
    d(0) = "DDDDDD"
    d(1) = "DD   DD"
    d(2) = "DD   DD"
    d(3) = "DD   DD"
    d(4) = "DD   DD"
    d(5) = "DDDDDD"
    I(0) = "IIII"
    I(1) = " II"
    I(2) = " II"
    I(3) = " II"
    I(4) = " II"
    I(5) = "IIII"
    DO
        COLOR 0
        FOR u% = 0 TO 5
            LOCATE INT(dy(0)) + u%, INT(dx(0)): PRINT d(u%)
            LOCATE INT(dy(1)) + u%, INT(dx(1)): PRINT d(u%)
            LOCATE INT(iy(0)) + u%, INT(ix(0)): PRINT I(u%)
            LOCATE INT(iy(1)) + u%, INT(ix(1)): PRINT I(u%)
        NEXT u%
        IF dy(0) < 12 THEN dy(0) = dy(0) + 1: dx(0) = dx(0) + 2
        IF iy(0) > 12 THEN iy(0) = iy(0) - 1: ix(0) = ix(0) + 3
        IF dy(1) < 12 THEN dy(1) = dy(1) + 1: dx(1) = dx(1) - 2.75
        IF iy(1) > 12 THEN iy(1) = iy(1) - 1: ix(1) = ix(1) - 2
        COLOR 15
        FOR u% = 0 TO 5
            LOCATE INT(dy(0)) + u%, INT(dx(0)): PRINT d(u%)
            LOCATE INT(dy(1)) + u%, INT(dx(1)): PRINT d(u%)
            LOCATE INT(iy(0)) + u%, INT(ix(0)): PRINT I(u%)
            LOCATE INT(iy(1)) + u%, INT(ix(1)): PRINT I(u%)
        NEXT u%
        t = TIMER
        DO
            IF INKEY$ = CHR$(27) THEN EXIT SUB
        LOOP UNTIL TIMER >= t + .08
    LOOP UNTIL iy(1) = 12
    setpal 14, 0, 0, 0
    COLOR 14

    LINE (171, 172)-STEP(43, 0)
    LINE (171, 172)-STEP(0, 100)
    LINE -STEP(43, 0)
    r = 20
    CIRCLE (214, 192), 20, , 0, _PI / 2
    CIRCLE (214, 252), 20, , _PI * 3 / 2, 0
    LINE (234, 192)-STEP(0, 60)

    LINE (193, 192)-STEP(12, 0)
    LINE (193, 192)-STEP(0, 61)
    LINE -STEP(12, 0)
    CIRCLE (205, 200), 8, , 0, _PI / 2
    CIRCLE (205, 245), 8, , _PI * 3 / 2.1, 0
    LINE (213, 200)-STEP(0, 45)

    IF INKEY$ = CHR$(27) THEN EXIT SUB

    LINE (331, 172)-STEP(43, 0)
    LINE (331, 172)-STEP(0, 100)
    LINE -STEP(43, 0)
    CIRCLE (374, 192), 20, , 0, _PI / 2
    CIRCLE (374, 252), 20, , _PI * 3 / 2, 0
    LINE (394, 192)-STEP(0, 60)

    LINE (353, 192)-STEP(12, 0)
    LINE (353, 192)-STEP(0, 61)
    LINE -STEP(12, 0)
    CIRCLE (365, 200), 8, , 0, _PI / 2
    CIRCLE (365, 245), 8, , _PI * 3 / 2.1, 0
    LINE (373, 200)-STEP(0, 45)

    IF INKEY$ = CHR$(27) THEN EXIT SUB

    LINE (261, 172)-STEP(37, 0)
    LINE (261, 172)-STEP(0, 19)
    LINE (298, 172)-STEP(0, 19)
    LINE (261, 191)-STEP(7, 0)
    LINE (298, 191)-STEP(-7, 0)
    LINE (268, 191)-STEP(0, 62)
    LINE (291, 191)-STEP(0, 62)
    LINE (268, 253)-STEP(-7, 0)
    LINE (291, 253)-STEP(7, 0)
    LINE (261, 253)-STEP(0, 19)
    LINE (298, 253)-STEP(0, 19)
    LINE -STEP(-37, 0)

    IF INKEY$ = CHR$(27) THEN EXIT SUB

    LINE (421, 172)-STEP(37, 0)
    LINE (421, 172)-STEP(0, 19)
    LINE (458, 172)-STEP(0, 19)
    LINE (421, 191)-STEP(7, 0)
    LINE (458, 191)-STEP(-7, 0)
    LINE (428, 191)-STEP(0, 62)
    LINE (451, 191)-STEP(0, 62)
    LINE (428, 253)-STEP(-7, 0)
    LINE (451, 253)-STEP(7, 0)
    LINE (421, 253)-STEP(0, 19)
    LINE (458, 253)-STEP(0, 19)
    LINE -STEP(-37, 0)

    t = TIMER
    DO
        IF INKEY$ = CHR$(27) THEN EXIT SUB
    LOOP UNTIL TIMER >= t + 2

    FOR w = 0 TO _PI / 2 STEP .05
        setpal 14, ABS(SIN(w) * 63), ABS(SIN(w) * 63), 0
        WAIT &H3DA, 8
        IF INKEY$ = CHR$(27) THEN EXIT SUB
    NEXT w

    t = TIMER
    DO
        IF INKEY$ = CHR$(27) THEN EXIT SUB
    LOOP UNTIL TIMER >= t + 1

    FOR w = 0 TO _PI / 2 STEP .1
        IF INKEY$ = CHR$(27) THEN EXIT SUB
        setpal 0, ABS(SIN(w) * 63), ABS(SIN(w) * 63), ABS(SIN(w) * 63)
        WAIT &H3DA, 8
    NEXT w

    t = TIMER
    DO
        IF INKEY$ = CHR$(27) THEN EXIT SUB
    LOOP UNTIL TIMER >= t + .3

    setpal 2, 0, 63 / 2, 0
    PAINT (173, 173), 2, 14
    PAINT (333, 173), 2, 14
    PAINT (263, 173), 2, 14
    PAINT (423, 173), 2, 14
    setpal 0, 0, 0, 0

    t = TIMER
    DO
        IF INKEY$ = CHR$(27) THEN EXIT SUB
    LOOP UNTIL TIMER >= t + 1
    setpal 1, 0, 0, 0

    COLOR 0
    LOCATE 23, 36: PRINT "PRESENTS"

    COLOR 1

    show.font "PRESENTS", 4, 0, 1, 220, 360

    w = 1.0472
    h = 0
    t = TIMER
    DO
        w = w + .04
        setpal 14, ABS(SIN(w) * 63), ABS(SIN(w) * 63), 0
        setpal 2, 0, ABS(COS(w) * 63), 0
        WAIT &H3DA, 8
        IF w > 8 AND h < 50 THEN
            IF h MOD 5 = 0 THEN PRINT
            h = h + 1
        END IF
        IF w >= _PI * 2 * 2 THEN
            setpal 1, 0, 0, ABS(SIN(w / 3) * 50) + 13
        ELSE
            setpal 5, 0, 0, ABS(SIN(w / 3) * 50) + 13
        END IF
        _LIMIT 60
    LOOP UNTIL INKEY$ <> "" OR TIMER >= t + 15

    FOR ii% = 0 TO 20
        FOR y% = 50 TO 400 STEP 20
            FOR x% = 170 TO 500 STEP 20
                LINE (x% + ii%, y%)-(x%, y% + ii%), 0
                LINE (x% - ii% + 20, y% + 20)-(x% + 20, y% - ii% + 20), 0
            NEXT x%
        NEXT y%
        WAIT &H3DA, 8
    NEXT ii%

END SUB

SUB kastl (kastlx%, kastly%, farbe%)

    IF farbe% = 7 THEN farbe% = 8
    IF farbe% >= 9 AND farbe% <= 15 THEN farbe% = farbe% - 8

    farbe2% = farbe% + 8
    IF farbe% = 8 THEN: farbe2% = 7

    IF farbe% > 0 AND farbe% <> 55 THEN
        IF maxposx = kastlx% AND maxposy = kastly% THEN
            killmax
        END IF
    END IF

    IF helion AND farbe% > 0 THEN
        IF (helix = kastlx% AND heliy = kastly%) OR (helix + 1 = kastlx% AND heliy = kastly%) THEN
            killheli
        END IF
    END IF

    IF kastly% > 0 THEN
        x1% = ((320 - fb * bg / 2) + ((kastlx% - 1) * bg) + 1)
        y1% = ((240 - fh * bg / 2) + ((kastly%) * bg) + 1)

        x2% = ((320 - fb * bg / 2 - 1) + ((kastlx%) * bg) + 1)
        y2% = ((240 - fh * bg / 2) + (kastly% + 1) * bg)

        IF farbe% = 0 THEN

            LINE (x1%, y1%)-(x2%, y2%), farbe%, BF
        ELSE

            IF farbe% = 20 THEN
                CIRCLE (x1% + bg / 2 - .5, y2% - bg / 3), bg / 3, 8, _PI, 0
                LINE (x1% + bg / 6, y2% - bg / 3)-STEP(0, -bg / 3), 8
                LINE (x2% - bg / 6 + 1, y2% - bg / 3)-STEP(0, -bg / 3), 8
                LINE -STEP(-bg * 2 / 3, 0), 8
                LINE (x1% + bg / 2 - .5, y1%)-STEP(0, bg / 5), 8
                LINE (x1% + bg / 6, y1%)-(x2% - bg / 6 + 1, y1%), 8
                PAINT (x1% + bg / 2, y1% + bg / 2), 4, 8
                CIRCLE (x1% + bg / 2 - .5, y2% - bg / 3), bg / 3.5, 12, 3 * _PI / 2 + .3, 2 * _PI
            ELSE

                IF farbe% = 44 THEN
                    FOR y% = 1 TO 14
                        FOR x% = 1 TO 14
                            IF boom(x%, y%) > 0 THEN PSET (x% + x1% - 1, y% + y1% - 1), boom(x%, y%)
                        NEXT x%
                    NEXT y%

                ELSE

                    IF farbe% = 33 THEN
                        FOR y% = 1 TO 14
                            FOR x% = 1 TO 14
                                PSET (x% + x1% - 1, y% + y1% - 1), tropfen(x%, y%)
                            NEXT x%
                        NEXT y%

                    ELSE

                        IF farbe% = 55 THEN

                            IF maxframe = 1 THEN
                                FOR y% = 1 TO 14
                                    FOR x% = 1 TO 14
                                        IF maxfeld(x%, y%) > 0 THEN PSET (x% + x1% - 1, y% + y1% - 1), maxfeld(x%, y%)
                                    NEXT x%
                                NEXT y%

                            ELSE

                                FOR y% = 1 TO 14
                                    FOR x% = 1 TO 14
                                        IF maxfeld(x%, y% + 14) > 0 THEN PSET (x% + x1% - 1, y% + y1% - 1), maxfeld(x%, y% + 14)
                                    NEXT x%
                                NEXT y%

                                IF paraon AND feld%(maxposx, maxposy - 1) = Frei% AND maxposy > 1 THEN
                                    FOR y% = 1 TO 14
                                        FOR x% = 1 TO 14
                                            IF para(x%, y%) > 0 THEN PSET (x% + x1% - 1, y% + y1% - 15), para(x%, y%)
                                        NEXT x%
                                    NEXT y%
                                END IF


                            END IF

                        ELSE

                            in% = bg / 5

                            LINE (x1%, y1%)-(x2%, y2%), farbe%, BF
                            LINE (x1% + in%, y1% + in%)-(x2% - in%, y2% - in%), farbe2%, BF
                            LINE (x1%, y1%)-(x1% + in%, y1% + in%), farbe2%
                            LINE (x2%, y2%)-(x2% - in%, y2% - in%), farbe2%
                            LINE (x2%, y1%)-(x2% - in%, y1% + in%), farbe2%
                            LINE (x1%, y2%)-(x1% + in%, y2% - in%), farbe2%
                        END IF
                    END IF
                END IF
            END IF
        END IF
    END IF

END SUB

SUB killheli

    helion = 0
    kastl helix, heliy, 44
    kastl helix + 1, heliy, 44

    blowheli = 1
END SUB

SUB killmax
    kastl maxposx, maxposy, 0
    IF paraon THEN kastl maxposx, maxposy - 1, 0

    IF maxposx >= fb / 2 THEN
        maxposx = maxposx - 5
    ELSE
        maxposx = maxposx + 5
    END IF

    maxposy = 1

    bc = bc + 1
    punkte = punkte + 2
    show.bodycount
    Punktezahl
    paraon = 1
END SUB

SUB main
    SCREEN 12
    PALETTE
    COLOR

    IF yn(1) = 2 THEN
        nomusik = 1
    ELSE
        nomusik = 0
    END IF

    IF yn(3) = 1 THEN
        maxposx = INT(fb / 2)
        maxposy = fh
        maxlt = TIMER
    ELSE
        maxposx = 0
        maxposy = 0
    END IF



    verzug = .35
    verzugplus = .025

    'Level = 1


    DEF SEG = 64
    POKE 23, 32
    DEF SEG

    FOR I% = 0 TO fh + 1
        feld%(0, I%) = belegt%
        feld%(fb + 1, I%) = belegt%
    NEXT I%

    FOR I% = 0 TO fb
        feld%(I%, fh + 1) = belegt%
    NEXT I%


    alles

    nstr% = INT(RND * (7)) + 1

    show.ffont "DCABE", 10, 273, 220
    z$ = INPUT$(1)
    fire 273, 220 + 19

    Musikladen

    ON TIMER(1) GOSUB hinter ' check the music queue every one second
    TIMER ON

    nextbomb = INT(RND * (30)) + 8

    helix = INT(fb / 2)

    DO

        IF yn(2) = 1 THEN nextbomb = nextbomb - 1

        struktur% = nstr%
        nstr% = INT(RND * (7)) + 1
        IF nextbomb = 0 THEN nstr% = 99: nextbomb = INT(RND * (30)) + 8
        strukturstart nstr%
        IF endeundaus = 1 THEN EXIT SUB
        nextes

        IF struktur% = 99 THEN bomb = 1
        strukturstart struktur%
        IF endeundaus = 1 THEN EXIT SUB
        farbe% = INT(RND * (15)) + 1
        IF bomb THEN farbe% = 20


        DO
            show.stone farbe%
            t = TIMER
            DO

                a$ = INKEY$


                IF a$ <> "" THEN
                    show.stone 0
                    IF a$ <> "" THEN woswasi = 0
                    SELECT CASE a$
                        CASE CHR$(0) + "K", "4"
                            k% = 0
                            FOR i1% = 1 TO 4
                                IF feld%(blockx%(i1%) - 1, blocky%(i1%)) <> belegt% THEN k% = k% + 1
                            NEXT i1%
                            IF k% = 4 THEN
                                FOR i2% = 1 TO 4
                                    blockx%(i2%) = blockx%(i2%) - 1
                                NEXT i2%
                            END IF
                        CASE CHR$(0) + "M", "6"
                            k% = 0
                            FOR i3% = 1 TO 4
                                IF feld%(blockx%(i3%) + 1, blocky%(i3%)) <> belegt% THEN k% = k% + 1
                            NEXT i3%
                            IF k% = 4 THEN
                                FOR i4% = 1 TO 4
                                    blockx%(i4%) = blockx%(i4%) + 1
                                NEXT i4%
                            END IF
                        CASE CHR$(0) + "P", "5": t = t - 1
                        CASE CHR$(0) + "D": SCREEN 0
                            ' TODO
                            TIMER OFF
                            PRINT "C:\DOS>"
                            DO
                                LOCATE 1, 8, 1
                            LOOP WHILE INKEY$ = ""
                            SCREEN 12
                            alles
                            'PLAY ON
                        CASE CHR$(0) + CHR$(133): SCREEN 0
                            ' TODO
                            TIMER OFF
                            SHELL
                            SCREEN 12
                            alles
                            'PLAY ON
                        CASE "s", "S"
                            TIMER OFF
                        CASE "m", "M"
                            TIMER ON
                        CASE CHR$(13), CHR$(0) + "H", "8", "+": drehen struktur%
                        CASE CHR$(27): ausis: IF endeundaus = 1 THEN EXIT SUB
                        CASE "P", "p": grey: a$ = INPUT$(1): PALETTE
                        CASE CHR$(0) + CHR$(59)
                            ' TODO
                            TIMER OFF
                            show.helpscreen
                            alles
                        CASE "1", "2", "3", "4", "5", "6", "7", "8", "9"
                            IF VAL(a$) <= Musikanzahl THEN
                                musi% = 0
                                Musikstueck% = VAL(a$)
                            END IF
                        CASE "0": woswasi = verzug - .01
                        CASE " ": IF acid >= maxacid THEN acidrain
                        CASE "t": END
                    END SELECT

                    show.stone farbe%
                END IF
                meanwhile


            LOOP UNTIL TIMER >= t + verzug - woswasi

            check% = 0
            FOR m% = 1 TO 4
                IF feld%(blockx%(m%), blocky%(m%) + 1) = belegt% THEN check% = 1: EXIT FOR
            NEXT m%

            IF check% = 1 THEN EXIT DO

            show.stone 0
            FOR i6% = 1 TO 4
                blocky%(i6%) = blocky%(i6%) + 1
            NEXT i6%

        LOOP

        woswasi = 0

        IF yn(4) = 1 THEN
            IF acid <= maxacid THEN acid = acid + acidplus
            show.acidometer
            punkte = punkte + 1
            Punktezahl
        END IF

        check% = 0
        FOR i7% = 1 TO 4
            farb%(blockx%(i7%), blocky%(i7%)) = farbe%
            feld%(blockx%(i7%), blocky%(i7%)) = belegt%
        NEXT i7%

        reichweite = INT(RND * (3)) + 1 'Bombe knallt auf

        IF bomb THEN
            bomb = 0
            FOR y% = -reichweite + blocky%(1) TO reichweite + blocky%(1)
                FOR x% = -reichweite + blockx%(1) TO reichweite + blockx%(1)
                    IF x% > 0 AND x% <= fb AND y% <= fh THEN
                        feld%(x%, y%) = Frei%
                        farb%(x%, y%) = 0
                        kastl x%, y%, 44
                    END IF
                NEXT x%
            NEXT y%

            t = TIMER
            DO
            LOOP UNTIL TIMER >= t + .3

            FOR y% = -reichweite + blocky%(1) TO reichweite + blocky%(1)
                FOR x% = -reichweite + blockx%(1) TO reichweite + blockx%(1)
                    IF x% > 0 AND x% <= fb AND y% <= fh THEN
                        kastl x%, y%, 0
                    END IF
                NEXT x%
            NEXT y%

        END IF

        FOR I% = 1 TO 4
            hoho%(I%) = 0
        NEXT I%
        j% = 0

        FOR y% = 1 TO fh
            FOR x% = 1 TO fb
                IF feld%(x%, y%) = Frei% THEN EXIT FOR
                IF x% = fb THEN

                    FOR I% = 1 TO fb
                        kastl I%, y%, 0
                    NEXT I%
                    j% = j% + 1
                    hoho%(j%) = y%
                END IF
            NEXT x%
        NEXT y%

        IF j% > 0 THEN
            tim = TIMER: DO: LOOP UNTIL TIMER >= tim + .1

            FOR l% = 1 TO j%
                FOR I% = 1 TO fb
                    kastl I%, hoho%(l%), 15
                NEXT I%
            NEXT l%

            tim = TIMER: DO: LOOP UNTIL TIMER >= tim + .5



            FOR l% = 1 TO j%
                FOR iy% = hoho%(l%) TO 2 STEP -1
                    FOR ix% = 1 TO fb
                        feld%(ix%, iy%) = feld%(ix%, iy% - 1)
                        farb%(ix%, iy%) = farb%(ix%, iy% - 1)
                    NEXT ix%
                NEXT iy%
            NEXT l%

            check% = j%
            Linienweg = Linienweg + j%

            punkte = punkte + linienpunkte * j%


            IF INT(Linienweg / 10) <> INT((Linienweg - j%) / 10) THEN
                Level = Level + 1
                verzug = verzug - verzugplus
            END IF

            nichtganzalles

        END IF


        IF check% > 0 THEN
            punkte = punkte + (check% - 1) * (linienpunkte / 4 * 3)
            Punktezahl
        END IF

        _LIMIT 60
    LOOP

END SUB

SUB meanwhile

    IF TIMER >= helilt + .2 AND yn(3) = 1 THEN

        IF helion THEN
            heli
        ELSE
            IF INT(RND * (40)) = 5 AND blowheli = 0 THEN
                helion = 1
                heliy = 1
                IF heliy <= 1 THEN heliy = 1
                show.heli 1

                helilt = TIMER
            ELSE
                helilt = TIMER

            END IF
        END IF

    END IF

    IF TIMER >= maxlt + .1 AND yn(3) = 1 THEN

        IF paraon THEN kastl maxposx, maxposy - 1, farb%(maxposx, maxposy - 1)
        kastl maxposx, maxposy, farb%(maxposx, maxposy)

        I% = INT(RND * (3)) - 1
        IF I% = 0 THEN m = maxstill

        chk1% = 1
        chk2% = 1
        chk3% = 1

        FOR u% = 1 TO 4
            IF blockx%(u%) = maxposx AND blocky%(u%) = maxposy + 1 THEN chk1% = 0
            IF blockx%(u%) = maxposx + I% AND blocky%(u%) = maxposy THEN chk2% = 0
            IF blockx%(u%) = maxposx + I% AND blocky%(u%) = maxposy - 1 THEN chk3% = 0
        NEXT u%

        IF feld%(maxposx, maxposy + 1) = Frei% AND chk1% THEN
            maxposy = maxposy + 1
            maxframe = 2
            maxstill = 0
            IF feld%(maxposx, maxposy + 1) = Frei% AND feld%(maxposx, maxposy + 2) = Frei% AND maxposy < fh THEN paraon = 1
        ELSE
   
            paraon = 0
            maxframe = 1

            IF feld%(maxposx + I%, maxposy) = Frei% AND chk2% THEN
                maxposx = maxposx + I%
                maxstill = 0
            ELSE
                IF feld%(maxposx + I%, maxposy - 1) = Frei% AND chk3% THEN
                    maxposx = maxposx + I%
                    maxposy = maxposy - 1
                    maxstill = 0
                ELSE
                    maxstill = maxstill + 1
                END IF
            END IF

        END IF

        IF maxposx = 0 THEN maxposx = 2
        IF maxposx = fb + 1 THEN maxposx = fb - 1

        IF maxstill > 15 THEN
            IF maxframe = 1 THEN
                maxframe = 2
            ELSE
                maxframe = 1
            END IF
            maxstill = 15
        END IF

        IF I% = 0 THEN maxstill = m

        kastl maxposx, maxposy, 55
        maxlt = TIMER
    END IF

    IF blowheli > 0 THEN
        kastl helix, heliy, 44
        kastl helix + 1, heliy, 44
        blowheli = blowheli + 1
    END IF

    IF blowheli = 200 THEN
        blowheli = 0
        chk1% = 1
        chk2% = 1

        IF chk1% THEN kastl helix, heliy, farb%(helix, heliy)
        IF chk2% THEN kastl helix + 1, heliy, farb%(helix + 1, heliy)

        helix = INT(RND * (fb - 1)) + 1
        IF helix >= (fb / 2) THEN
            helix = 1
        ELSE
            helix = fb - 1
        END IF
    END IF
END SUB

SUB menu
    DIM s$(5)

    posit% = 1

    show.menu

    s$(1) = "   START   "
    s$(2) = "   SETUP   "
    s$(3) = "  READ ME  "
    s$(4) = " HIGHSCORE "
    s$(5) = "    END    "

    DO
        COLOR 5, 0
        FOR I% = 1 TO 5
            LOCATE 16 + I%, 33: PRINT " "; s$(I%); " "
        NEXT I%

        COLOR 11, 9

        LOCATE 16 + posit%, 33: PRINT "["; s$(posit%); "]"

        gettaste z$, posit%, 5
        SELECT CASE z$
            CASE CHR$(13), " ", "5"
                SELECT CASE posit%
                    CASE 1: EXIT SUB
                    CASE 2: setup
                    CASE 3: show.helpscreen: show.menu
                    CASE 4: score = 0: SCREEN 12: showhiscore: show.menu
                    CASE 5: ausss
                END SELECT
            CASE CHR$(27): ausss
        END SELECT
    LOOP
END SUB


SUB Musikladen
    IF already = 0 THEN
        FOR I% = 1 TO Musikanzahl

            x% = 0
            DO
                x% = x% + 1
                READ a$
                Musik$(x%, I%) = a$
                IF Musik$(x%, I%) = "MUSIKENDE" THEN EXIT DO
            LOOP
            Musiklaenge(I%) = x% - 1
        NEXT I%
    END IF

    Musikstueck% = INT(RND * (Musikanzahl)) + 1
    musi% = 1
    IF nomusik = 0 THEN PLAY "mb" + Musik$(musi%, Musikstueck%)
END SUB


SUB nextes
    FOR y% = 1 TO 4
        FOR x% = 0 TO 2
            kastl x% - 3, y%, 0
            kastl x% - 3, y%, 9
        NEXT x%
    NEXT y%

    IF nstr% = 99 THEN
        kastl blockx%(1) - fb / 2 - 3, 2, 20
    ELSE

        FOR I% = 1 TO 4
            kastl blockx%(I%) - fb / 2 - 3, blocky%(I%), 10
        NEXT I%

    END IF
END SUB

SUB nichtganzalles
    FOR I% = 0 TO maxlinie - 1
        LINE (320 - I% - fb * bg / 2, 240 - I% - fh * bg / 2 + bg)-(321 + I% + fb * bg / 2, 240 + I% + fh * bg / 2 + 1 + bg), INT(RND * (15)) + 1, B
    NEXT I%

    FOR x% = 1 TO fb
        FOR y% = 1 TO fh
            kastl x%, y%, farb%(x%, y%)
        NEXT y%
    NEXT x%

    IF yn(4) = 1 THEN
        show.acidometer
    END IF
END SUB

SUB Punktezahl
    LOCATE 10, 10: COLOR 2: PRINT "Points..";
    COLOR 9: PRINT STR$(punkte)
    LOCATE 12, 10: COLOR 14: PRINT "Lines...";
    COLOR 11: PRINT Linienweg
    LOCATE 14, 10: COLOR 4: PRINT "LEVEL...";
    COLOR 8: PRINT Level
END SUB

SUB select.case (I%, ax%, ay%)
    SELECT CASE I%
        CASE 1: ax% = ax% + 1
        CASE 2: ax% = ax% - 1
        CASE 3: ay% = ay% + 1
        CASE 4: ay% = ay% - 1
        CASE 5: ax% = ax% - 1: ay% = ay% + 1
        CASE 6: ax% = ax% + 1: ay% = ay% - 1
        CASE 7: ax% = ax% - 1: ay% = ay% - 1
        CASE 8: ax% = ax% + 1: ay% = ay% + 1
    END SELECT
END SUB

SUB setgrey (nr, value)
    setpal nr, value, value, value
END SUB

SUB setpal (nr, r, g, B)
    OUT &H3C8, nr
    OUT &H3C9, r
    OUT &H3C9, g
    OUT &H3C9, B
END SUB

SUB setup

    COLOR 5, 0
    FOR I% = 1 TO 5
        LOCATE 16 + I%, 33: PRINT "             "
    NEXT I%

    max = 4

    DIM p(1 TO max, 2) AS STRING

    p(1, 0) = " MUSIC    "
    p(2, 0) = " BOMBS    "
    p(3, 0) = " ARMY     "
    p(4, 0) = " ACIDRAIN "

    p(1, 1) = "YES"
    p(2, 1) = " OF COURSE"
    p(3, 1) = " WAY COOL"
    p(4, 1) = " YEP"

    p(1, 2) = " NO"
    p(2, 2) = "BETTER NOT"
    p(3, 2) = "NO CHANCE"
    p(4, 2) = "NOPE"

    positi% = 1

    DO

        FOR I% = 1 TO max
            COLOR 5, 0
            LOCATE 16 + I%, 29: PRINT " "; p(I%, 0); " "
            IF yn(I%) = 1 THEN COLOR 2, 0 ELSE COLOR 4, 0
            LOCATE 16 + I%, 51 - LEN(p(I%, yn(I%))): PRINT " "; p(I%, yn(I%)); " "
        NEXT I%

        COLOR 5, 0
        LOCATE 18 + max, 37: PRINT "  BACK  "

        COLOR 11, 9
        IF positi% = max + 1 THEN
            LOCATE 18 + max, 37: PRINT "[ BACK ]"
        ELSE
            LOCATE 16 + positi%, 29: PRINT "["; p(positi%, 0); "]"
        END IF

        gettaste z$, positi%, max + 1
        SELECT CASE z$
            CASE CHR$(13), " ", "5"
                IF positi% = max + 1 THEN
                    EXIT DO
                ELSE
                    yn(positi%) = yn(positi%) + 1
                    IF yn(positi%) = 3 THEN yn(positi%) = 1
                END IF
            CASE CHR$(27): EXIT DO
        END SELECT
    LOOP

    FOR I% = 1 TO max
        COLOR 0, 0
        LOCATE 16 + I%, 29: PRINT " "; p(I%, 0); " "
        LOCATE 16 + I%, 51 - LEN(p(I%, yn(I%))): PRINT " "; p(I%, yn(I%)); " "
    NEXT I%

    LOCATE 18 + max, 37: PRINT "  BACK  "
END SUB

SUB show.acidometer
    x1% = ((320 - fb * bg / 2) + ((-3) * bg) + 1)
    x2% = ((320 - fb * bg / 2 - 1) + ((-1) * bg) + 1)
    y2% = ((240 - fh * bg / 2) + (fh + 1) * bg)
    y1% = y2% - maxacid


    IF acid <= maxacid OR showallacid THEN

        LINE (x1% - 1, y1% - 1)-(x2% + 1, y2% + 1), 4, B
        LINE (x1% - 2, y1% - 2)-(x2% + 2, y2% + 2), 4, B

        IF acid = 0 OR showallacid THEN LINE (x1%, y1%)-(x2%, y2%), 0, BF
        IF acid > 0 AND acid <= maxacid THEN
            LINE (x1%, y2% - acid + 1)-(x2%, y2% - acid + 1 + acidplus), 1, BF
        END IF

        IF showallacid THEN
            IF acid < maxacid THEN
                LINE (x1%, y2%)-(x2%, y2% - acid + 1), 1, BF
            ELSE
                LINE (x1%, y2%)-(x2%, y1%), 1, BF
            END IF
        END IF

        IF acid = maxacid OR (acid > maxacid AND showallacid) THEN
            LINE (x1% - 1, y1% - 1)-(x2% + 1, y2% + 1), 2, B
            LINE (x1% - 2, y1% - 2)-(x2% + 2, y2% + 2), 2, B
        END IF

    END IF



END SUB

SUB show.bodycount
    show.font2 STR$(bc), 2, 0, 2, 360, 448
END SUB

SUB show.ffont (word$, fa, ax, ay)

    FOR I% = 1 TO LEN(word$)
        a$ = MID$(word$, I%, 1)
        nr% = ASC(a$) - 64

        IF nr% > 0 AND nr% < 27 THEN
            FOR y% = 1 TO 19
                FOR x% = 1 TO 19
                    IF buch(nr%, x%, y%) = 1 THEN
                        PSET (x% + ax + (I% - 1) * 19, y% + ay), fa
                    END IF
                NEXT x%
            NEXT y%
        END IF

    NEXT I%

END SUB

SUB show.font (word$, scale, bgc, fgc, xa, ya)
    FOR I% = 1 TO LEN(word$)
        nr = ASC(UCASE$(MID$(word$, I%, 1))) - 64
        IF nr >= 1 AND nr <= 26 THEN

            FOR y% = 1 TO 5
                FOR x% = 1 TO 5
    
                    ax = ((I% - 1) * scale * 6 + (x% - 1) * scale + xa)
                    ay = ((y% - 1) * scale * 3 / 2 + ya)

                    IF bst(nr, x%, y%) THEN
                        col = fgc
                    ELSE
                        col = bgc
                    END IF
                    LINE (ax, ay)-STEP(scale / 4, scale * 3 / 8), col, BF
                NEXT x%
            NEXT y%

        END IF
    NEXT I%
END SUB

SUB show.font2 (word$, scale, bgc, fgc, xa, ya)

    FOR I% = 1 TO LEN(word$)
        nr = ASC(UCASE$(MID$(word$, I%, 1))) - 64

        IF VAL((MID$(word$, I%, 1))) > 0 THEN
            nr = VAL((MID$(word$, I%, 1))) + 30
        END IF

        IF MID$(word$, I%, 1) = "0" THEN nr = 30
        IF MID$(word$, I%, 1) = ":" THEN nr = 40
        IF MID$(word$, I%, 1) = "-" THEN nr = 41

        IF nr >= 1 AND nr <= 41 THEN
            FOR y% = 1 TO 5
                FOR x% = 1 TO 5
   
                    ax = ((I% - 1) * scale * 6 + (x% - 1) * scale + xa)
                    ay = ((y% - 1) * scale * 3 / 2 + ya)

                    IF bst(nr, x%, y%) THEN
                        col = fgc
                    ELSE
                        col = bgc
                    END IF
                    LINE (ax, ay)-STEP(scale * 2 / 3, scale), col, BF
                NEXT x%
            NEXT y%

        END IF
    NEXT I%
END SUB

SUB show.heli (farbe%)
    IF farbe% THEN
        x1% = ((320 - fb * bg / 2) + ((helix - 1) * bg) + 1)
        y1% = ((240 - fh * bg / 2) + ((heliy) * bg) + 1)

        FOR y% = 2 TO 14
            FOR x% = 1 TO 14
                IF hf1(x%, y%) > 0 THEN
                    PSET (x% + x1% - 1, y% + y1% - 1), hf1(x%, y%)
                END IF
                IF hf2(x%, y%) > 0 THEN
                    PSET (x% + x1% + 13, y% + y1% - 1), hf2(x%, y%)
                END IF
            NEXT x%
        NEXT y%

        IF rotor THEN
            LINE (x1% + 3, y1%)-STEP(12, 0), 8
            LINE -STEP(12, 0), 7
            rotor = 0
        ELSE
            LINE (x1% + 3, y1%)-STEP(12, 0), 7
            LINE -STEP(12, 0), 8
            rotor = 1
        END IF


    ELSE
        kastl helix, heliy, farb%(helix, heliy)
        kastl helix + 1, heliy, farb%(helix + 1, heliy)
    END IF
END SUB

SUB show.helpscreen
    SCREEN 13

    COLOR 1
    FOR I = 1 TO 255
        setpal I, 0, 0, 0
    NEXT I

    LOCATE 3, 1
    PRINT "Try to catch the soldier who's jumping"
    PRINT
    PRINT " around before the AH-64D Apache gets "
    PRINT
    PRINT SPACE$(14) + "him!!!!!!!"
    LOCATE 11, 2
    PRINT "If the ACID-O-METER is full press the"
    PRINT
    PRINT "   SPACE BAR to activate an acidrain"
    PRINT
    PRINT " which will eat away the highest stones."
    LOCATE 19, 1
    PRINT "Sometimes you can control a falling bomb"
    PRINT
    PRINT " with which you can destroy some stones."
    LOCATE 24, 1

    GOSUB action

    setpal 1, 0, 0, 0
    COLOR 1

    u$ = ""
    FOR I% = 1 TO 9
        u$ = u$ + " " + CHR$(1) + " " + CHR$(2)
    NEXT I%
    u$ = u$ + " " + CHR$(1)

    PRINT
    PRINT u$
    PRINT
    PRINT " If you think that this program is not"
    PRINT
    PRINT "   so bad, then please please please"
    PRINT
    PRINT "  write a postcard or a letter to me!!"
    PRINT
    PRINT "       I would be very happy! :-)"
    PRINT
    PRINT u$
    PRINT: PRINT
    PRINT "       …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª"
    PRINT "       ∫   Dietmar MORITZ       ∫"
    PRINT "       ∫   Ungargasse 43        ∫"
    PRINT "       ∫   7350 Oberpullendorf  ∫"
    PRINT "       ∫     A U S T R I A      ∫"
    PRINT "       ∫      E U R O P E       ∫"
    PRINT "       »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº"

    GOSUB action
    SCREEN 12
    EXIT SUB

    action:
    FOR y% = 0 TO 200
        FOR x% = 0 TO 320
            IF POINT(x%, y%) <> 0 THEN
                c = SQR((x% - 160) ^ 2 + (y% - 100) ^ 2)
                PSET (x%, y%), c
            END IF
        NEXT x%
    NEXT y%

    DO
        w = w + .01
        FOR u = 1 TO 255
            I = u / 35
            r = ABS(SIN(w + I + 4 * _PI / 3) ^ 2 * 63)
            g = ABS(SIN(w + I + 2 * _PI / 3) ^ 2 * 63)
            B = ABS(SIN(w + I) ^ 2 * 63)
            setpal u, r, g, B
        NEXT u
        _LIMIT 60
    LOOP UNTIL INKEY$ <> ""
    RETURN

    SCREEN 12
END SUB

SUB show.menu
    SCREEN 0
    CLS

    LOCATE 3, 13
    COLOR 1
    PRINT "⁄ƒ         t h e     u n b e l i e v a b l e         ƒø"

    PRINT

    COLOR 2, 0

    LOCATE 5, 15: PRINT "       ‹‹‹   ‹‹         ‹‹‹            ‹‹          "
    LOCATE 6, 15: PRINT "      €   € ﬂ‹‹ﬂ       €   €          ﬂ‹‹ﬂ         "
    LOCATE 7, 15: PRINT "      €   €  ‹‹        €   €  ‹‹‹ ‹‹   ‹‹    ‹‹‹‹  "
    LOCATE 8, 15: PRINT " ‹ﬂﬂﬂﬂ    € €  €  ‹ﬂﬂﬂﬂ    € €   ﬂ  € €  € ‹ﬂ    ﬂ‹"
    COLOR 2, 0
    LOCATE 9, 15: PRINT "€         € €  € €         € €   ‹ﬂﬂ  €  € ﬂ‹  ﬂ‹‹ﬂ"
    LOCATE 10, 15: PRINT "€         € €  € €         € €  €     €  € ‹ﬂﬂ‹  ﬂ‹"
    LOCATE 11, 15: PRINT "ﬂ‹        € €  € ﬂ‹        € €  €     €  € ﬂ‹    ‹ﬂ"
    LOCATE 12, 15: PRINT "  ﬂﬂﬂﬂﬂﬂﬂﬂ   ﬂﬂ    ﬂﬂﬂﬂﬂﬂﬂﬂ   ﬂﬂ       ﬂﬂ    ﬂﬂﬂﬂ  "
    PRINT: COLOR 1, 0
    PRINT SPC(12); "¿ƒ                                                   ƒŸ"

END SUB

SUB show.stone (farbe%)
    FOR I% = 1 TO 4
        kastl blockx%(I%), blocky%(I%), farbe%
        farb%(blockx%(I%), blocky%(I%)) = farbe%
    NEXT I%
END SUB

SUB show.verynicegraphic

    SCREEN 13

    fa = 14
    ast = 5
    smooth = 70
    v = .01

    DIM w AS DOUBLE
    w = 1
    FOR u = 0 TO 255
        I = u / 81
        r = ABS(SIN(w + I + 4 * _PI / 3) * 63)
        g = ABS(SIN(w + I + 2 * _PI / 3) * 63)
        B = ABS(SIN(w + I) * 63)

        setpal u, r, g, B

    NEXT u
    COLOR 1
    LOCATE 15, 8: PRINT "Programming:"
    LOCATE 16, 20: PRINT "Dietmar Moritz"
    LOCATE 18, 8: PRINT "Testing:"
    LOCATE 19, 20: PRINT "Dietmar Moritz"
    LOCATE 21, 8: PRINT "Graphics:"
    LOCATE 22, 20: PRINT "Dietmar Moritz"

    DRAW "c251"
    COLOR 251

    DRAW "bm20,80 u40 r 20 F30 d10 l30 u10 r13 h17 l3 d27 l13"
    PAINT (23, 78), 252, 251

    DRAW "c251 bm80,80 u40 r13 d40 l13"
    PAINT (83, 78), 252, 251

    DRAW "c251 bm105,80 u40 r 20 F30 d10 l30 u10 r13 h17 l3 d27 l13"
    PAINT (108, 78), 252, 251

    DRAW "c251 bm165,80 u40 r22"
    LINE -STEP(20, 15), 251
    LINE -STEP(-16, 10), 251
    DRAW "f15 l13 h12 u7"
    LINE -STEP(9, -6), 251
    LINE -STEP(-8, -5), 251
    DRAW "l4 d30 l12"
    PAINT (167, 78), 252, 251

    DRAW "c251 bm215,80 u40 r13 d40 l13"
    PAINT (220, 78), 252, 251

    DRAW "c251 bm240,80 u10 r23 e5 l27 u15 e10 r30 d10 l23 g5 r27 d15 g10 l30"
    PAINT (243, 78), 252, 251


    FOR y% = 0 TO 200
        FOR x% = 0 TO 160
            a = SQR(((x% - 160)) ^ 2 + (y% - 100) ^ 2)

            IF x% <> 160 THEN
                w = ATN((y% - 100) / (x% - 160))
            ELSE
                w = ATN((y% - 100) / (.1))
            END IF

            c = SIN(a / fa) ^ 2 * smooth + (w * ast) * 81.5
            c = c MOD 256

            IF INKEY$ = CHR$(27) THEN SCREEN 12: EXIT SUB

            SELECT CASE POINT(x%, y%)
                CASE 251: PSET (x%, y%), c + 128
                CASE 252: PSET (x%, y%), c + 80
                CASE 1: PSET (x%, y%), c + 50
                CASE ELSE: PSET (x%, y%), c
            END SELECT

            IF x% < 160 THEN
                SELECT CASE POINT(320 - x%, 200 - y%)
                    CASE 251: PSET (320 - x%, 200 - y%), c + 128
                    CASE 252: PSET (320 - x%, 200 - y%), c + 80
                    CASE 1: PSET (320 - x%, 200 - y%), c + 50
                    CASE ELSE: PSET (320 - x%, 200 - y%), c
                END SELECT
            END IF

        NEXT x%
    NEXT y%

    w = 1
    DO
        w = w + v
        FOR u = 0 TO 255
            I = u / 81
            r = ABS(SIN(w + I + 4 * _PI / 3) * 63)
            g = ABS(SIN(w + I + 2 * _PI / 3) * 63)
            B = ABS(SIN(w + I) * 63)
            setpal u, r, g, B
        NEXT u
        _LIMIT 60
    LOOP UNTIL INKEY$ <> ""

    SCREEN 12
END SUB

SUB showhiscore
    PALETTE
    DIM n$(10)
    DIM s(10)
    CLS

    score = punkte

    ON ERROR GOTO keine

    OPEN "I", #1, "didris.hsc"

    IF h = 0 THEN

        FOR I% = 1 TO 10
            IF EOF(1) THEN GOTO weiter
            INPUT #1, n$(I%)
            INPUT #1, s(I%)
        NEXT I%
    END IF

    weiter:
    CLOSE #1

    COLOR 6
    setpal 6, 10, 43, 63
    FOR I% = 1 TO 10
        IF score > s(I%) THEN
            LOCATE 10, 30: INPUT "Name: ", name$
            IF LEN(name$) > 12 THEN name$ = LEFT$(name$, 12)
            IF name$ = "" THEN name$ = "anonymous"
            FOR u% = 9 TO I% STEP -1
                n$(u% + 1) = n$(u%)
                s(u% + 1) = s(u%)
            NEXT u%
            n$(I%) = name$
            s(I%) = score
            position% = I%
            EXIT FOR
        END IF
    NEXT I%

    CLS

    FOR I = 0 TO 15
        setpal I, 0, 0, 0
    NEXT I

    FOR x% = 0 TO 82
        FOR y% = 0 TO 82
            c = INT(RND * (5)) + 1
            PSET (x%, y%), c
        NEXT y%
    NEXT x%

    FOR x% = 0 TO 80
        FOR y% = 0 TO 80
            c = POINT(x%, y%) + POINT(x% + 1, y%) + POINT(x%, y% + 1) + POINT(x% - 1, y%) + POINT(x%, y% - 1)
            PSET (x%, y%), c / 5
        NEXT y%
    NEXT x%

    DIM hh(2000) AS INTEGER
    GET (1, 1)-(80, 80), hh()

    FOR y% = 0 TO 480 STEP 80
        FOR x% = 0 TO 640 STEP 80
            PUT (x%, y%), hh(), PSET
        NEXT x%
    NEXT y%

    ax = 177
    ay = 50
    bx = 390 + INT(LEN(STR$(s(1))) / 2) * 9 * 2
    by = 430

    LINE (ax, ay)-(bx, by), 0, BF
    LINE (ax, ay)-(bx, by), 7, B

    setpal 0, 20, 20, 20
    setpal 1, 0, 0, 20
    setpal 2, 0, 0, 31
    setpal 3, 0, 0, 42
    setpal 4, 0, 0, 53
    setpal 5, 0, 0, 63
    setpal 7, 20, 20, 20
    setpal 8, 22, 22, 22
    setpal 9, 18, 18, 18
    setpal 10, 16, 16, 16
    setpal 11, 24, 24, 24
    setpal 12, 10, 10, 10
    setpal 13, 5, 5, 5
    setpal 15, 0, 0, 0

    COLOR 7

    LINE (171, 44)-(bx + 6, 44)
    LINE -(bx, ay)
    LINE (171, 44)-(171, 436)
    LINE -(ax, by)
    PAINT (175, ay), 11, 7
    LINE (ax, ay)-(171, 44)

    LINE (171, 436)-(bx + 6, 436)
    LINE -(bx + 6, 44)
    PAINT (bx + 2, by), 12, 7
    LINE (bx + 6, 436)-(bx, by), 13

    LINE (171, 44)-(bx + 6, 436), 15, B

    COLOR 6
    setpal 6, 10, 43, 63
    FOR I% = 1 TO 10
        LOCATE I% * 2 + 6, 30
        IF s(I%) > 0 THEN
            PRINT n$(I%), s(I%)
        END IF
    NEXT I%

    LOCATE 5, 25 + INT(LEN(STR$(s(1))) / 2)
    COLOR 1: PRINT "-";
    COLOR 2: PRINT "=";
    COLOR 3: PRINT " H I ";
    COLOR 4: PRINT "G H ";
    COLOR 5: PRINT "S ";
    COLOR 4: PRINT "C O ";
    COLOR 3: PRINT "R E ";
    COLOR 2: PRINT "=";
    COLOR 1: PRINT "-";

    IF position% > 0 THEN
        LOCATE position% * 2 + 6, 30
        COLOR 14
        PRINT name$, punkte
    END IF

    FOR I% = 1 TO 100
        x% = INT(RND * (bx - ax)) + ax
        y% = INT(RND * (by - ay)) + ay
        c% = INT(RND * (5)) + 8
        FOR u% = 1 TO 20
            x% = INT(RND * (3)) + x% - 1
            y% = INT(RND * (3)) + y% - 1
            IF POINT(x%, y%) = 0 THEN PSET (x%, y%), c%
        NEXT u%
    NEXT I%

    OPEN "O", #1, "didris.hsc"
    FOR I% = 1 TO 10
        PRINT #1, n$(I%)
        PRINT #1, s(I%)
    NEXT I%
    CLOSE #1

    DO
        x = x + .01
        c1 = ABS(INT(SIN(x) * 63))
        c2 = ABS(INT(SIN(x + 2 * _PI / 3) * 63))
        c3 = ABS(INT(SIN(x + 4 * _PI / 3) * 63))
        setpal 14, c1, c2, c3
        WAIT &H3DA, 8
    LOOP UNTIL INKEY$ <> ""

END SUB

SUB showpoints
    FOR I% = 2 TO 0 STEP -1
        LINE (320 - (130 + I% * 10), 240 - (50 + I% * 10))-(320 + (130 + I% * 10), 190 + (50 + I% * 10)), I% + 11, BF
        LINE (320 - 120, 240 - 40)-(320 + 120, 190 + 40), 0, BF
    NEXT I%
    COLOR 14
    LOCATE 14, 40 - INT((7 + LEN(STR$(punkte))) / 2)
    PRINT "SCORE: " + STR$(punkte)

    DO
        x = x + .009
        c1 = ABS(INT(SIN(x) * 63))
        c2 = ABS(INT(SIN(x + 2 * _PI / 3) * 63)) * 256
        c3 = ABS(INT(SIN(x + 4 * _PI / 3) * 63)) * 256 ^ 2
        PALETTE 11, c1 + c2
        PALETTE 12, c1 + c3
        PALETTE 13, c2 + c3
        PALETTE 14, c1 + c2 + c3
    LOOP UNTIL INKEY$ = CHR$(13)
END SUB

SUB strukturstart (struktur%)
    SELECT CASE struktur%
        CASE 1
            blockx%(1) = INT(fb / 2) + 1
            blocky%(1) = 2
            blockx%(2) = blockx%(1)
            blocky%(2) = 1
            blockx%(3) = blockx%(1) - 1
            blocky%(3) = 2
            blockx%(4) = blockx%(1) + 1
            blocky%(4) = 2
        CASE 2
            blockx%(1) = INT(fb / 2)
            blocky%(1) = 1
            blockx%(2) = blockx%(1)
            blocky%(2) = 2
            blockx%(3) = blockx%(1) + 1
            blocky%(3) = 1
            blockx%(4) = blockx%(1) + 1
            blocky%(4) = 2
        CASE 3
            blockx%(1) = INT(fb / 2) + 1
            blocky%(1) = 1
            blockx%(2) = blockx%(1) + 1
            blocky%(2) = 1
            blockx%(3) = blockx%(1) - 1
            blocky%(3) = 2
            blockx%(4) = blockx%(1)
            blocky%(4) = 2
        CASE 4
            blockx%(1) = INT(fb / 2)
            blocky%(1) = 1
            blockx%(2) = blockx%(1) + 1
            blocky%(2) = 1
            blockx%(3) = blockx%(2) + 1
            blocky%(3) = 2
            blockx%(4) = blockx%(2)
            blocky%(4) = 2
        CASE 5
            blockx%(1) = INT(fb / 2)
            blocky%(1) = 2
            blockx%(2) = blockx%(1)
            blocky%(2) = 1
            blockx%(3) = blockx%(1) + 1
            blocky%(3) = 1
            blockx%(4) = blockx%(1)
            blocky%(4) = 3
        CASE 6
            blockx%(1) = INT(fb / 2) + 1
            blocky%(1) = 2
            blockx%(2) = blockx%(1)
            blocky%(2) = 1
            blockx%(3) = blockx%(1) - 1
            blocky%(3) = 1
            blockx%(4) = blockx%(1)
            blocky%(4) = 3
        CASE 7
            blockx%(1) = INT(fb / 2) + 1
            blocky%(1) = 2
            blockx%(2) = blockx%(1)
            blocky%(2) = 1
            blockx%(3) = blockx%(1)
            blocky%(3) = 3
            blockx%(4) = blockx%(1)
            blocky%(4) = 4
        CASE 99
            blockx%(1) = INT(fb / 2) + 1
            blocky%(1) = 1
            blockx%(2) = blockx%(1)
            blocky%(2) = 1
            blockx%(3) = blockx%(1)
            blocky%(3) = 1
            blockx%(4) = blockx%(1)
            blocky%(4) = 1
    END SELECT

    FOR I% = 1 TO 4
        IF feld%(blockx%(I%), blocky%(I%)) = belegt% THEN
            farb% = INT(RND * (15)) + 1
            FOR i2% = 1 TO 4
                kastl blockx%(i2%), blocky%(i2%), farb%
            NEXT i2%
            ausis
            EXIT SUB
        END IF
    NEXT I%
END SUB

SUB Tasten
    DIM a$(15)
    a$(1) = "Left......... Left      "
    a$(2) = "Right........ Right     "
    a$(3) = "Rotate....... Up / Enter"
    a$(4) = "Drop......... Down / 0  "
    a$(5) = "Acidrain..... Space bar "
    a$(7) = "Music on/off. m / s"
    a$(8) = "Music #1..... 1    "
    a$(9) = "Music #2..... 2    "
    a$(10) = "Music #3..... 3    "
    a$(12) = "Info......... F1 "
    a$(13) = "Pause........ p  "
    a$(14) = "Boss Key..... F10"
    a$(15) = "End.......... ESC"


    IF yn(1) = 2 THEN
        FOR I% = 7 TO 10
            a$(I%) = a$(I% + 5)
            a$(I% + 5) = ""
        NEXT I%
    END IF

    IF yn(4) = 2 THEN
        FOR I% = 5 TO 14
            a$(I%) = a$(I% + 1)
            a$(15) = ""
        NEXT I%
    END IF

    FOR I% = 1 TO 15
        FOR x% = 1 TO LEN(a$(I%)) STEP 2
            LOCATE 7 + I%, 54 + x%: COLOR INT(RND * (15)) + 1: PRINT MID$(a$(I%), x%, 2)
        NEXT x%
    NEXT I%
END SUB

SUB Titel
    PALETTE
    a$ = "DIDI's"
    B$ = "DIDRIS"
    c$ = "1 9 9 8"

    zx = 320
    zy = 240
    zz = 60
    h = 5
    f = 5
    ff = 0
    fff = 100

    FOR ii% = 1 TO 3
        SELECT CASE ii%
            CASE 1: xx$ = a$
            CASE 2: xx$ = B$
            CASE 3: xx$ = c$
        END SELECT
        LOCATE 1, 1: PRINT xx$ + "  "
        FOR y% = 1 TO 15
            FOR I% = 1 TO LEN(xx$) * 8
                IF POINT(I%, y%) > 0 THEN
                    farb% = INT(RND * (15)) + 1
                    LINE (fax(320 - LEN(xx$) * 20 + I% * 40 / 8, 0, zx, zz), fay(y% * f - ff + ii% * fff, 0, zy, zz))-(fax(320 - LEN(xx$) * 20 + I% * 40 / 8, h, zx, zz), fay(y% * f - ff + ii% * fff, h, zy, zz)), farb%
                END IF
            NEXT I%
        NEXT y%
    NEXT ii%
    LOCATE 1, 1: PRINT "                    "
    t = TIMER
    DO
        x = x + .01
        c1 = ABS(INT(SIN(x) * 63))
        c2 = ABS(INT(SIN(x + 2 * _PI / 3) * 63)) * 256
        c3 = ABS(INT(SIN(x + 4 * _PI / 3) * 63)) * 256 ^ 2
        c4 = ABS(INT(COS(x) * 63))
        c5 = ABS(INT(COS(x + 2 * _PI / 3) * 63)) * 256
        c6 = ABS(INT(COS(x + 4 * _PI / 3) * 63)) * 256 ^ 2
        PALETTE 7, c4 + c5
        PALETTE 8, c4 + c6
        PALETTE 9, c5 + c6
        PALETTE 10, c4 + c5 + c6
        PALETTE 11, c1 + c2
        PALETTE 12, c1 + c3
        PALETTE 13, c2 + c3
        PALETTE 14, c1 + c2 + c3
        z$ = INKEY$
        _LIMIT 60
    LOOP UNTIL z$ <> "" OR TIMER >= t + 15
    IF UCASE$(z$) = "M" THEN yn(1) = 2

    DIM verz(3000)

    fa = 40
    fa2 = 2
    t = TIMER
    DO
        x = INT(RND * (530 - fa)) + 100
        y = INT(RND * (370 - fa)) + 70
        GET (x, y)-(x + fa, y + fa), verz()
        PUT (x, y + fa2), verz(), PSET
        z$ = INKEY$
        WAIT &H3DA, 8
    LOOP UNTIL z$ <> "" OR TIMER >= t + 20

    IF UCASE$(z$) = "M" THEN yn(1) = 2

    PALETTE
END SUB

