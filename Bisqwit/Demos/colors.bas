DEFINT A-Z
DECLARE SUB lbl (x, y, c, h)
DECLARE SUB Speak(x,y, e$, f$)
DECLARE SUB rainbow(x,y, c, radius)

' The whole program will revolve around the
' graphics produced by these two lines of code.
SCREEN 13
_FULLSCREEN _SQUAREPIXELS

FOR a = 0 TO 319: LINE (a, 0)-(a, 199), a: NEXT

ti# = TIMER: WHILE TIMER < ti# + 1: WEND 'Wait 1 second before continuing.
Speak 160,140, _
  "To many Q-Basic programmers,~this color table is a familiar sight.", _
  "Monelle kuubeisik-ohjelmoijalle~t{m{ v{ritaulukko on tuttu n{ky."
a$ = INPUT$(1): CLS

FOR a = 0 TO 255
    x = (a MOD 16) * 20: y = (a \ 16) * 11 + 24
    LINE (x, y)-(x + 18, y + 9), a, BF
    lbl x + 2, y + 2, a, 0
NEXT

Speak 160,0, _
  "It is the default VGA palette in MODE 13.", _
  "Se on oletuspaletti veegeeaann moodi kolmessatoista."
a$ = INPUT$(1)

LINE (0, 0)-(319, 23), 0, BF
Speak 160,0, _
  "Often programmers saw it useless for their purposes, and~they replaced it with something that would be easier to work with.", _
  "Usein ohjelmoijat kokivat sen tarkoituksiinsa kelpaamattomaksi,~ja he korvasivat sen jollain mit{ olisi helpompi k{ytt{{."
a$ = INPUT$(1)

LINE (0, 0)-(319, 23), 0, BF
Speak 160,0, _
  "But what does this palette really contain?~Random colors? Obviously not. Let's find out.", _
  "Mutta mik{ juju t{ss{ paletissa sitten on?~Ei se selv{stik{{n ole sattumanvarainen. Otetaanpa selv{{."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "Colors 0-15"
FOR a = 0 TO 15
    x = (a MOD 4) * 80: y = (a \ 4) * 40 + 10
    LINE (x, y)-(x + 75, y + 35), a, BF
    lbl x + 2, y + 2, a, 1
NEXT
Speak 160,170, _
  "The first 16 colours comprise the standard EGA palette.", _
  "Ensimm{iset 16 v{ri{ muodostavat vakioidun eegeeaa-paletin."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "No blue";
LOCATE 1, 21: PRINT "With blue";
FOR a = 0 TO 15
    x = (a MOD 2) * 160: y = (a \ 2) * 24 + 10
    LINE (x, y)-(x + 155, y + 21), a, BF
    lbl x + 2, y + 2, a, -1
NEXT
Speak 160,200, "Odd indexes have a blue component.", _
               "Parittomissa on sininen komponentti."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "No green";
LOCATE 1, 21: PRINT "With green";
FOR a = 0 TO 15
    x = (a AND 2) * 80: y = ((a \ 4) * 2 + (a AND 1)) * 24 + 10
    LINE (x, y)-(x + 155, y + 21), a, BF
    lbl x + 2, y + 2, a, -2
NEXT

Speak 160,200, "Those that have bit with value two, on, have a green component.", _
               "Ne miss{ kakkosbitti on p{{ll{, vihert{v{t."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "No red";
LOCATE 1, 21: PRINT "With red";
FOR a = 0 TO 15
    x = (a AND 4) * 40: y = ((a \ 8) * 4 + (a AND 3)) * 24 + 10
    LINE (x, y)-(x + 155, y + 21), a, BF
    lbl x + 2, y + 2, a, -3
NEXT
Speak 160,200, "Those that have bit with value four, on, have a red component.", _
               "Kolmas bitti, arvoltaan 4, lis{{ v{ris{vyyn punaisen."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "Low intensity";
LOCATE 1, 21: PRINT "High intensity";
FOR a = 0 TO 15
    x = (a AND 8) * 20: y = ((a AND 7)) * 24 + 10
    LINE (x, y)-(x + 155, y + 21), a, BF
    lbl x + 2, y + 2, a, -4
NEXT
Speak 160,200, "And the ones that possess a certain eightness, shine brighter.", _
               "Loput kahdeksan ovat kirkkaita versioita edellisist{."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "Colors 16..31";
LOCATE 2, 1: PRINT "Linear, non-gammacorrected grayscale";
FOR a = 0 TO 15
    x = (a MOD 4) * 80: y = (a \ 4) * 38 + 20
    LINE (x, y)-(x + 75, y + 34), a + 16, BF
    lbl x + 2, y + 2, a + 16, 1
NEXT
Speak 160,172, _
  "The next 16 colors comprise a linear gray scale. If the color 17~appears black to you, please verify the color settings of your monitor.", _
  "Seuraavat 16 v{ri{ muodostavat tasaisen harmaas{vyskaalan.~Jos v{ri 17 n{ytt{{ mustalta, tarkista monitorisi v{ris{{d|t."

a$ = INPUT$(1): CLS



LOCATE 1, 1: PRINT "Hue-Mix:100-0   75-25   50-50   25-75";
FOR y = 0 TO 5
    LOCATE 3 + y * 4, 1
    PRINT MID$("Blue   MagentaRed    Yellow Green  Cyan   ", y * 7 + 1, 7);
NEXT
FOR a = 0 TO 23
    x = 64 + (a MOD 4) * 64: y = (a \ 4) * 32 + 10
    LINE (x, y)-(x + 60, y + 28), a + 32, BF
    lbl x, y, a + 32, 1
NEXT

Speak 160, 200, "This is how the following 24 colors work. It is a rainbow through all primary colors of the RGB system.", ""
a$ = INPUT$(1)
Speak 160, 200, "", "Seuraavat 24 v{ri{ v{rist{ 32 alkaen toimivat n{in. Niist{ muodostuu tasainen v{riliukuma, joka k{y l{pi kaikki {rgeebeen p{{v{rit."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "White-Mix:0%      49%         72%";
FOR a = 0 TO 71
    x = ((a \ 24) MOD 3) * 104: y = (a MOD 24) * 8 + 10
    LINE (x, y)-(x + 102, y + 6), a + 32, BF
    lbl x + 16, y, a + 32, 2
NEXT

Speak 160, 200, "The next 48 colors are progressively less saturated versions of those 24, created by mixing the color with white. The end result looks pastel.", ""
a$ = INPUT$(1)
Speak 160, 200, "", "Seuraavissa nelj{ss{kymmeness{kahdeksassa esiintyv{t samat v{rit, mutta niihin on sekoitettu enemm{n valkoista, jolloin v{rit muuttuvat pastellimaisemmiksi."

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "Black-Mix:0%      56%          75%  ";
FOR a = 0 TO 215
    x = ((a \ 24) MOD 3) * 34 + (a \ 72) * 106: y = (a MOD 24) * 8 + 10
    LINE (x + 33, y)-(x + 33, y + 7), 0, BF
    LINE (x, y)-(x + 32, y + 6), a + 32, BF
    lbl x, y, a + 32, 0
NEXT


Speak 160, 200, "Then the remaining colors do the same, except add progressively more black, creating darker colors.", ""
a$ = INPUT$(1)
Speak 160, 200, "", "Lopuissa v{reiss{ on vastaavasti lis{tty enenev{ss{ m{{rin mustaa. Tuloksena on tummempia v{rej{."

a$ = INPUT$(1)
FOR a = 0 TO 215
    x = ((a \ 24) MOD 3) * 34 + (a \ 72) * 104: y = (a MOD 24) * 8 + 10
    'LINE (x+33, y)-(x + 33, y + 7), 0, BF
    LINE (x, y)-(x + 32, y + 6), a + 32, BF
    lbl x, y, a + 32, 3
NEXT
LOCATE 1, 1: PRINT "100% bright  44% bright   25% bright";

a$ = INPUT$(1): CLS

LOCATE 1, 1: PRINT "    White-Mix:  0%       49%      72%";
LOCATE 4, 1: PRINT "Black-Mix:"
LOCATE 6, 4: PRINT "0% black": LOCATE 7, 2: PRINT "100% bright"
LOCATE 12, 3: PRINT "56% black": LOCATE 13, 3: PRINT "44% bright"
LOCATE 18, 3: PRINT "75% black": LOCATE 19, 3: PRINT "25% bright"

LOCATE 23, 1: COLOR 8: PRINT "-Disclaimer-":
LOCATE 24, 1: PRINT "No implied ra-";: LOCATE 25, 1: PRINT "cism intended.";: COLOR 15
r = 0
Speak 220,184, _
  "Here is a summary of the 216 colors.", _
  "T{ss{ viel{ tiivistelm{ n{ist{ v{reist{."
WHILE INKEY$ = ""
    FOR b = 0 TO 2
        FOR w = 0 TO 2
            x = w * 74 + 134
            y = b * 56 + 36
            rainbow x, y, 32 + w * 24 + b * 72, 27
            IF r = 0 THEN
                lbl x - 7, y - 7, 32 + w * 24 + b * 72, 0
                lbl x - 1, y - 1, 32 + w * 24 + b * 72 + 23, 0
            END IF
    NEXT w, b
    r = 1
WEND
CLS

LOCATE 1, 1: PRINT "Colors 248..255";
LOCATE 2, 1: PRINT "All black!";
FOR a = 0 TO 7
    x = (a AND 1) * 160: y = (a \ 2) * 32 + 32
    LINE (x, y)-(x + 156, y + 29), a + 248, BF
    LINE (x, y)-(x + 156, y + 29), 15, B
    lbl x + 2, y + 2, a + 248, 1
NEXT

Speak 160,160, "The last 8 colors are all black for some reason.", _
               "Viimeiset 8 v{ri{ ovat jostain kumman syyst{ kaikki mustia."

a$ = INPUT$(1): CLS

Speak 160, 200, "Thus, this is what the standard VGA palette was made of.", ""

FOR a = 0 TO 31
    x = (a MOD 16) * 20: y = (a \ 16) * 10
    LINE (x, y)-(x + 18, y + 8), a, BF
    lbl x + 2, y + 2, a, 0
NEXT

FOR a = 0 TO 215
    x = 1 + (a \ 24) * 35: y = 20 + (a MOD 24) * 7
    x = x + 2 * (a \ 72)
    LINE (x, y)-(x + 33, y + 5), a + 32, BF
    lbl x + 2, y + 1, a + 32, 0
NEXT

FOR a = 0 TO 7
    x = a * 40: y = 189
    LINE (x, y)-(x + 38, y + 9), a + 248, BF
    LINE (x, y)-(x + 38, y + 9), 20, B
    lbl x + 2, y + 2, a + 248, 0
NEXT

a$ = INPUT$(1)
Speak 160,200, "", _
               "N{in siis oli veegeeaa-paletti rakennettu. Nyt sen siis tied{t."

a$ = INPUT$(1): CLS

Speak 160,200, "Thank you for watching this video! Speech by u s 3, mbrola.", _
               "Kiitos kun katsoit t{m{n videon. Suomeksi puhui suopuhe."
END

FUNCTION DrawChar1 (x, y, ch, c) STATIC
    ' Draw a character ch at given coordinates using color c.
    ' No dithering. No kerning. Return value: Width.
    DIM Font6x5(0 TO 96, -1 TO 4)
    IF w = 0 THEN
        ' 6x5 font data, originally designed by Juha Nieminen for use in Joed:
        DATA 4,0,0,0,0,0,3,64,64,64,0,64,5,80,80,0,0,0: REM 32
        DATA 6,80,248,80,248,80,6,112,160,112,40,240,6,136,16,32,64,136: REM 35
        DATA 6,96,96,104,144,104,3,64,64,0,0,0,4,32,64,64,64,32: REM 38
        DATA 4,64,32,32,32,64,7,72,48,252,48,72,6,32,32,248,32,32: REM 41
        DATA 3,0,0,0,64,128,5,0,0,240,0,0,3,0,0,0,0,64: REM 44
        DATA 6,8,16,32,64,128,6,112,152,168,200,112,4,64,192,64,64,224: REM 47
        DATA 5,96,144,32,64,240,5,240,16,96,16,224,5,80,144,240,16,16: REM 50
        DATA 5,240,128,224,16,224,5,96,128,224,144,96,5,240,16,32,32,64: REM 53
        DATA 5,96,144,96,144,96,5,96,144,112,16,96,3,0,64,0,64,0: REM 56
        DATA 3,0,64,0,64,128,4,32,64,128,64,32,4,0,224,0,224,0: REM 59
        DATA 4,128,64,32,64,128,5,96,144,32,0,32,5,96,144,176,128,96: REM 62
        DATA 5,96,144,240,144,144,5,224,144,224,144,224,5,112,128,128,128,112: REM ABC
        DATA 5,224,144,144,144,224,5,240,128,224,128,240,5,240,128,224,128,128: REM DEF
        DATA 5,112,128,176,144,112,5,144,144,240,144,144,4,224,64,64,64,224: REM GHI
        DATA 5,16,16,16,144,96,5,144,160,192,160,144,5,128,128,128,128,240: REM JKL
        DATA 6,136,216,168,136,136,6,136,200,168,152,136,5,96,144,144,144,96: REM MNO
        DATA 5,224,144,224,128,128,5,96,144,144,176,112,5,224,144,224,160,144: REM PQR
        DATA 5,96,128,96,16,224,6,248,32,32,32,32,5,144,144,144,144,96: REM STU
        DATA 6,136,136,80,80,32,6,136,136,136,168,80,6,136,80,32,80,136: REM VWX
        DATA 6,136,80,32,32,32,6,248,16,32,64,248,3,192,128,128,128,192: REM YZ[
        DATA 6,128,64,32,16,8,3,192,64,64,64,192,4,64,160,0,0,0: REM \]^
        DATA 5,0,0,0,0,240,3,128,64,0,0,0,5,96,16,112,144,112: REM _`a
        DATA 5,128,128,224,144,224,4,0,96,128,128,96,5,16,16,112,144,112: REM bcd
        DATA 5,0,96,240,128,96,4,96,128,192,128,128,4,0,96,160,96,192: REM efg
        DATA 5,128,128,224,144,144,4,64,0,192,64,224,3,64,0,64,64,192: REM hij
        DATA 5,128,160,192,160,144,4,192,64,64,64,224,6,0,208,168,168,136: REM klm
        DATA 5,0,224,144,144,144,5,0,96,144,144,96,5,0,224,144,224,128: REM nop
        DATA 5,0,112,144,112,16,4,0,96,128,128,128,5,0,112,192,48,224: REM qrs
        DATA 4,64,224,64,64,32,5,0,144,144,144,112,6,0,136,136,80,32: REM tuv
        DATA 6,0,136,136,168,80,5,0,144,96,96,144,5,0,144,112,16,96: REM wxy
        DATA 5,0,240,32,64,240,5,80,0,96,160,240,5,80,0,96,144,96: REM z{|
        DATA 5,96,0,96,160,240,5,80,160,0,0,0: REM                       }~
        FOR y = 0 TO 94: FOR x = -1 TO 4: READ Font6x5(y, x): NEXT x, y
    END IF

    DEF SEG = &HA000 ' VGA display memory segment
    w = Font6x5(ch, -1)
    IF c >= 0 THEN
        FOR py = 0 TO 4
            p = Font6x5(ch, py)
            o& = (y + py) * 320& + x
            m = 128
            FOR px = 1 TO w
                IF p AND m THEN POKE o&, c
                o& = o& + 1
                m = m \ 2
        NEXT px, py
    END IF
    DrawChar1 = w
END FUNCTION

FUNCTION DrawText (x, y, s$, c2, which)
    'Draw a text string. Return value: pixel width of the text.
    IF which < 0 THEN which = -LEN(s$) - which
    fy = 0
    IF y >= 200 THEN fy = -1
    FOR c = fy TO 15 STEP 15
        xp = x
        yp = y
        FOR a = 1 TO LEN(s$)
            ch = ASC(MID$(s$, a, 1)) - 32
            IF c = 0 THEN
                FOR m = -1 TO 1: FOR n = -1 TO 1
                        w = DrawChar1(xp + m, yp + n, ch, c)
                NEXT n, m
                xp = xp + w
            ELSE
                cc = c
                IF which < 0 AND a = -which THEN cc = c2
                xp = xp + DrawChar1(xp, yp, ch, cc)
            END IF
        NEXT
        IF c < 0 THEN EXIT FOR
    NEXT
    DrawText = xp - x
END FUNCTION

SUB lbl (x, y, c, h)
    'Draw a text label
    IF h < 0 THEN
        s$ = ""
        p = 1
        FOR n = 0 TO 3 ' Convert to 4-digit binary number
            s$ = MID$("01", 1 + ((c AND p) \ p), 1) + s$
            p = p + p
        NEXT
        c2 = 8 + 2 ^ (-h - 1)
        IF c2 >= 16 THEN c2 = 8
        dummy = DrawText(x, y, LTRIM$(STR$(c)) + " (" + s$ + ")", c2, h)
    ELSEIF h <> 3 THEN
        dummy = DrawText(x, y, LTRIM$(STR$(c)), 0, 0) 'Display decimal number
    END IF
    IF h = 0 THEN EXIT SUB
    h$ = "#"
    IF h = 1 OR h < 0 THEN y = y + 8 ELSE IF h = 2 THEN x = x + 24 ELSE h$ = ""
    OUT &H3C7, c ' Display RGB color (read directly from VGA palette)
    r = INP(&H3C9): r = r * 4 + r \ 16: r$ = RIGHT$("0" + HEX$(r), 2)
    g = INP(&H3C9): g = g * 4 + g \ 16: g$ = RIGHT$("0" + HEX$(g), 2)
    b = INP(&H3C9): b = b * 4 + b \ 16: b$ = RIGHT$("0" + HEX$(b), 2)
    dummy = DrawText(x, y, h$ + r$ + g$ + b$, 0, 0)
END SUB

SUB rainbow (x, y, c, radius)
    ' Draws a circular rainbow. Our rainbow is a circle with thickness,
    ' where color is defined by the angle (determined using arctangent).
    ' In order to draw a thick circle, we simply draw a box and ignore
    ' those pixels that are not part of the arc. The selection is done
    ' by measuring the distance from the origo. Only pixels that fall
    ' within the certain range are accepted.
    minr = radius * 0.6
    minr2 = minr * minr ' minimum radius ^ 2
    maxr2 = radius * radius ' maximum radius ^ 2
    pi! = 3.14159!
    xradius = radius * 4 / 3 ' aspect ratio correction
    FOR py = -radius TO radius
        py2 = py * py
        FOR px = -xradius TO xradius
            pxr! = px * 3 / 4
            r = pxr! * pxr! + py2
            IF r >= minr2 AND r <= maxr2 THEN
                ' angle! = ATAN2(py, px) -- only QBasic does not have ATAN2.
                IF px = 0 THEN angle! = SGN(py) * pi! * 0.5 ELSE angle! = ATN(py / pxr!)
                IF px < 0 THEN angle! = angle! + pi!
                IF py < 0 THEN angle! = angle! + pi! + pi!
                ' Convert angle into a color and place the pixel.
                cc! = angle! * 12 / pi! + 6
                cc = INT(cc! + RND) ' Quantize with random dithering
                PSET (x + px, y + py), c + (cc + 24) MOD 24
            END IF
        NEXT
    NEXT
END SUB

SUB Speak (x, y, e$, f$) STATIC
    'IF f = 0 THEN f = FREEFILE: OPEN "VOX" AS f
    'IOCTL f, e$ + "~~" + f$ + "$"
    ' ^Speak text. This is something I added to my copy of DOSBox.
    ' Feel free to comment out those two lines if it does not work for you.
    IF y >= 200 THEN EXIT SUB

    sep$ = "~"
    'IF INSTR(e$+f$, "~") = 0 THEN sep$ = "~"
    s$ = e$ + sep$ + f$
    DO
        i = INSTR(s$, "~") ' Split text to lines with ~ as a delimiter
        ' For each line, figure out the width, and use that width
        ' to center the dialog text around the given X coordinate.
        IF i = 0 THEN
            w = DrawText(0, 200, s$, 0, 0)
            dummy = DrawText(x - w \ 2, y, s$, 0, 0)
            EXIT DO
        END IF
        y$ = MID$(s$, 1, i - 1)
        w = DrawText(0, 200, y$, 0, 0)
        dummy = DrawText(x - w \ 2, y, y$, 0, 0)
        s$ = MID$(s$, i + 1)
        IF LEN(y$) = 0 THEN y = y + 3 ELSE y = y + 6
    LOOP
END SUB
