'QBDEMO (C) 2002 Tor Myklebust

'The fractal zoomer should run at 60FPS on a 500MHz machine.  I disabled
'vsync because it runs like shit on this 300MHz machine on the higher zoom
'levels (inconsistent 20-30 fps).  I basically just packed the rest of the
'demo with really shitty effects.  There is no music because I don't know
'a damn thing about sound coding (aside from the fact that you use Fourier
'transforms a hell of a lot), and I also don't know the first thing about
'art/music.

'The fractal zoomer uses a number of cheap hacks.  First, I only render
'the fractal image once per 50 frames.  It zooms in by a factor of two
'each time.  It is rendered at a resolution of 320*200, because we don't
'want blockies to show up on our 160*100 rendered image.  I've tried
'doing the "maximal" 224*141 (or thereabouts) image and it looked bad.
'We render four scanlines per frame, drawing as few pixels as possible.
'We zoom the 160*100 in the middle of the previous frame's 320*200 to take
'up every fourth pixel in the new frame, then (ab)using the intermediate
'value theorem for the pixels in between if the neighbour pixels are the
'same colour.  This causes some minor visual artefacts which you shouldn't
'be able to see (except the one white line where the yellow is disappearing)

'This code is VERY LOOSELY based on Alex Champandard's code in his "The Art
'of Demomaking" series.  I made up the zoom hack and the IVT hack because
'QB is more than twice as slow as DJGPP.  I thought his palette-cycling
'looked really stupid, so I omitted that.

'I shouldn't need to explain the shadebob effect.  Everyone knows how to do
'shadebobs, or can at least figure it out in two or three minutes.  No
'hacking was necessary here, as the effect is trivial to begin with.

'I also shouldn't need to explain plasma.  No hacking was involved here,
'either.

'I did the flag thing because I saw an american flag flying in some past demo
'which i just looked at (15 minutes before the deadline).  I didn't have time
'to code an american flag burning (I've done this in C by just rendering less
'and less of the flag (having the fire "crawl across" the flag) each frame,
'and using the "burning" areas to seed a fire.  Besides, burning is supposed
'to be a proper way to retire a flag, and we can't have that.

'I wanted to add a (phongshaded, swept) scrolltext, but time did not permit
'it.  You can see something like this in mesha or lbd or something (however,
'because QB is QB, it probably wouldn't be half the quality).

'I started this 27 hours before the deadline, and finished it _on_ the
'deadline.  Yay for me.

DEFINT A-Z
'$DYNAMIC
$RESIZE:SMOOTH

CONST XCENTRE# = -.577816001047738#
CONST YCENTRE# = -.6311212235178052#

SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM SHARED totalframecount AS INTEGER
DIM SHARED fractal1(32000&) AS INTEGER
DIM SHARED fractal2(32000&) AS INTEGER
FOR x = 0 TO 63
    OUT &H3C8, x
    OUT &H3C9, x
    OUT &H3C9, x
    OUT &H3C9, 0
NEXT
FOR x = 64 TO 127
    OUT &H3C8, x
    OUT &H3C9, 63
    OUT &H3C9, 63
    OUT &H3C9, x
NEXT
FOR x = 128 TO 191
    OUT &H3C8, x
    OUT &H3C9, 0
    OUT &H3C9, 0
    OUT &H3C9, x
NEXT
FOR x = 191 TO 255
    OUT &H3C8, x
    OUT &H3C9, x
    OUT &H3C9, x
    OUT &H3C9, 63
NEXT
OUT &H3C8, 255: OUT &H3C9, 0: OUT &H3C9, 0: OUT &H3C9, 0
OUT &H3C8, 127: OUT &H3C9, 0: OUT &H3C9, 0: OUT &H3C9, 0
ti1! = TIMER
fractaleffect 2250
ti1! = TIMER - ti1!
COLOR 63: PRINT ti1!
ERASE fractal1
ERASE fractal2
a$ = INPUT$(1)
CLS
unwhitefade 16
DIM SHARED bobsprite(32, 32) AS INTEGER
FOR x = 0 TO 32
    FOR y = 0 TO 32
        bobsprite(x, y) = 16 - SQR((16 - x) ^ 2 + (16 - y) ^ 2)
        IF bobsprite(x, y) < 0 THEN bobsprite(x, y) = 0
    NEXT
NEXT
shadebobeffect 8192
ERASE bobsprite
CLS
unwhitefade 16
plasma 1024
CLS
ohcanada 512 'ohcanada has a transition

END 0

REM $STATIC
SUB drawbob (ofs)
    FOR y = 0 TO 31
        ofs = ofs + 288
        FOR x = 0 TO 31
            POKE ofs, PEEK(ofs) + bobsprite(x, y)
            ofs = ofs + 1
        NEXT
    NEXT
END SUB

DEFDBL A-Z
'
'distthr is 4 unless you know what you're doing
'maximum iteration number of 256 seems to be sufficient for most purposes.
'"renders" one scanline to fractal1.
'assumes that we have been DEF SEG'd to fractal1.
'
SUB fracline (y%, y1, y2, x1, x2, distthr)
    deltax = (x2 - x1) / 160
    deltay = (y2 - y1) / 160
    y = y1
    x% = 1
    y320% = y% * 320
    x = x1 + deltax / 2
    DO
        unf% = PEEK(y320% + x% - 1)
        IF unf% = PEEK(y320% + x% + 1) AND unf% > 0 THEN
            iter% = unf%
        ELSE
            re = 0: im = 0: iter% = 0
            DO
                re2 = re * re
                im2 = im * im
                im = re * im
                im = im + im + y
                re = re2 - im2 + x
                iter% = iter% + 1
            LOOP UNTIL re2 + im2 >= distthr OR iter% = 255
        END IF
        POKE x% + y320%, iter%
        x% = x% + 2
        IF x% >= 320 THEN EXIT DO
        x = x + deltax
        y = y + deltay
    LOOP
    x% = 160
    x = (x1 + x2) / 2
    re = 0: im = 0: iter% = 0
    DO
        temp = re * re - im * im
        im = re * im
        im = im + im + y
        re = temp + x
        iter% = iter% + 1
    LOOP UNTIL re * re + im * im >= distthr OR iter% = 255
    POKE x% + y320%, iter%
END SUB

'render odd scanlines like this
'just like fracline, but we cheat vertically.
SUB fracline2 (y%, y1, y2, x1, x2, distthr)
    'Dim scanline(320) As Integer
    deltax = (x2 - x1) / 320
    deltay = (y2 - y1) / 320
    y = y1
    x% = 0
    y320% = y% * 320
    x = x1
    DO
        IF PEEK(x% + y320% - 320) = PEEK(x% + y320% + 320) THEN
            iter% = PEEK(x% + y320% - 320)
        ELSE
            re = 0: im = 0: iter% = 0
            DO
                re2 = re * re
                im2 = im * im
                im = re * im
                im = im + im + y
                re = re2 - im2 + x
                iter% = iter% + 1
            LOOP UNTIL re2 + im2 >= distthr OR iter% = 255
        END IF
        POKE x% + y320%, iter%
        x% = x% + 1
        IF x% >= 320 THEN EXIT SUB
        x = x + deltax
        y = y + deltay
    LOOP

END SUB

DEFINT A-Z
SUB fractaleffect (totalframes)
    DIM tmpshit(160, 100)
    ly = -100: f# = 1
    FOR f = 1 TO totalframes
        ly0 = ly
        ly1 = ly + 1
        ly2 = ly + 2
        ly3 = ly + 3
        ly0# = ly0 / f# + YCENTRE
        ly1# = ly1 / f# + YCENTRE
        ly2# = ly2 / f# + YCENTRE
        ly3# = ly3 / f# + YCENTRE
        lx1# = XCENTRE - 160 / f#
        lx2# = XCENTRE + 160 / f#
        DEF SEG = VARSEG(fractal1(0))
        distthr# = 4
        fracline ly0 + 100, ly0#, ly0#, lx1#, lx2#, distthr#
        fracline ly2 + 100, ly2#, ly2#, lx1#, lx2#, distthr#
        fracline2 ly1 + 100, ly1#, ly1#, lx1#, lx2#, distthr#
        fracline2 ly3 + 100, ly3#, ly3#, lx1#, lx2#, distthr#
        ly = ly + 4
        IF ly >= 100 THEN
            ly = -100
            f# = f# * 2
            o = 16080
            FOR y = 0 TO 99
                FOR x = 0 TO 159
                    tmpshit(x, y) = PEEK(o)
                    o = o + 1
                NEXT
                o = o + 160
            NEXT
            o = 0
            FOR x = 0 TO 32000
                fractal2(x) = fractal1(x)
                fractal1(x) = 0
            NEXT
            FOR y = 0 TO 99
                FOR x = 0 TO 159
                    POKE x * 2 + y * 640, tmpshit(x, y)
                NEXT
            NEXT

        END IF
        DEF SEG = VARSEG(fractal2(0))
        f50 = (f) MOD 50
        x1 = f50 * 1.6: y1 = f50
        x2 = 320 - f50 * 1.6: y2 = 200 - f50
        render x1, y1, x2, y2
        IF LEN(INKEY$) THEN EXIT SUB
        totalframecount = totalframecount + 1
        _LIMIT 60
    NEXT
END SUB

SUB ohcanada (totalframes)
    FOR x = 0 TO 255
        OUT &H3C8, x
        OUT &H3C9, 63
        OUT &H3C9, 63
        OUT &H3C9, 63
    NEXT
    DEF SEG = &HA000
    BLOAD "canada.bsv", 0
    FOR x = 0 TO 255
        OUT &H3C8, x
        OUT &H3C9, 63
        OUT &H3C9, x \ 4
        OUT &H3C9, x \ 4
    NEXT
    unwhitefade 256
    totalframecount = totalframecount + 16
    FOR f = 1 TO totalframes
        WAIT &H3DA, 8, 8
        WAIT &H3DA, 8
        totalframecount = totalframecount + 1
        IF INKEY$ > "" THEN EXIT SUB
    NEXT
END SUB

SUB plasma (totalframes)
    DIM unf(320), unfunf(320)
    DIM sine(512)
    DIM fuh(128, 128)
    DEF SEG = &HA000
    FOR x = 0 TO 512
        sine(x) = SIN(x * 3.14 / 256) * 32 + 32
    NEXT
    FOR f = 1 TO totalframes
        FOR x = 0 TO 320
            unf(x) = sine((x + f) AND 511) + sine((3 * x + 7 * f + 3) AND 511)
        NEXT
        o = 0
        FOR y = 0 TO 128
            unf2 = sine((y * 7 + f * 5) AND 511) + sine((y * 14 + f * 11 + 1943) AND 511)
            FOR x = 0 TO 128
                fuh(x, y) = unf(x) + unf2
                o = o + 1
            NEXT
        NEXT
        FOR x = 0 TO 320
            unf(x) = sine((x * 11 + f * 7) AND 511) + sine((3 * x + 7 * f + 3) AND 511)
            unfunf(x) = sine((x * 4 + f * 5) AND 511) + sine((9 * x + 2 * f + 371) AND 511)
        NEXT
        o = 0
        FOR y = 0 TO 199
            unf2 = sine((y * 11 + f * 6) AND 511) + sine((y * 14 + f * 11 + 1943) AND 511)
            unf3 = sine((y * 9 + f * 4) AND 511) + sine((y * 17 + f * 23 + 1943) AND 511)
            FOR x = 0 TO 319
                POKE o, fuh((unf(x) + unf2) AND 127, (unfunf(x) + unf3) AND 127)
                o = o + 1
            NEXT
        NEXT
        updpalplasma f
        totalframecount = totalframecount + 1
        IF INKEY$ > "" THEN EXIT SUB
        _LIMIT 60
    NEXT
END SUB

'like a bf line with similar parameters. except we're "texturing"
'we are defsegged to fractal2.
SUB render (x1, y1, x2, y2)
    DIM unf(160, 100)
    deltay = y2 - y1
    deltax = x2 - x1
    yadd = deltay \ 100
    xadd = deltax \ 160
    deltax = deltax MOD 160
    deltay = deltay MOD 100
    y = y1
    FOR scry = 0 TO 99
        x = x1
        xe = 0
        y320 = y * 320
        FOR scrx = 0 TO 159
            unf(scrx, scry) = PEEK(x + y320)
            xe = xe + deltax
            IF xe > 160 THEN xe = xe - 160: x = x + 1
            x = x + xadd
        NEXT
        ye = ye + deltay
        IF ye > 100 THEN ye = ye - 100: y = y + 1
        y = y + yadd
    NEXT
    DEF SEG = &HA000
    o = 16080
    FOR y = 0 TO 99
        FOR x = 0 TO 159
            POKE o + x, unf(x, y)
        NEXT
        o = o + 320
    NEXT
    DEF SEG = VARSEG(fractal2(0))

END SUB

SUB shadebobeffect (totalframes)
    DIM bob(4096) AS INTEGER
    bobptr = 0
    DEF SEG = &HA000
    FOR f = 1 TO totalframes
        undrawbob (bob(bobptr))
        x = (SIN(f / 71) + COS(f / 47 + 2) + COS(f / 91 + 7)) * 48 + 160
        y = (COS(f / 49 + 3) + SIN(f / 41 + 2) + SIN(f / 97 + 7)) * 28 + 100
        bob(bobptr) = x + y * 320
        drawbob (bob(bobptr))
        bobmax = f \ 2 + 1
        'IF bobmax > 4095 THEN bobmax = 4095
        bobptr = bobptr + 1
        bobptr = bobptr MOD bobmax
        totalframecount = totalframecount + 1
        IF INKEY$ > "" THEN EXIT SUB
        _LIMIT 60
    NEXT
    ERASE bob
END SUB

SUB undrawbob (ofs)
    FOR y = 0 TO 31
        ofs = ofs + 288
        FOR x = 0 TO 31
            POKE ofs, PEEK(ofs) - bobsprite(x, y)
            ofs = ofs + 1
        NEXT
    NEXT
END SUB

SUB unwhitefade (totalframes)
    DIM pal(256, 3)
    FOR x = 0 TO 255
        OUT &H3C7, x
        pal(x, 0) = INP(&H3C9)
        pal(x, 1) = INP(&H3C9)
        pal(x, 2) = INP(&H3C9)
    NEXT
    FOR f = 0 TO totalframes
        f! = f / totalframes
        WAIT &H3DA, 8, 8
        WAIT &H3DA, 8
        FOR x = 0 TO 255
            OUT &H3C8, x
            OUT &H3C9, pal(x, 0) * f! + 63 * (1 - f!)
            OUT &H3C9, pal(x, 1) * f! + 63 * (1 - f!)
            OUT &H3C9, pal(x, 2) * f! + 63 * (1 - f!)
        NEXT
        totalframecount = totalframecount + 1
    NEXT

END SUB

'essentially ripped from Alex Champandard.
'the code is exactly the same, +/- variable name changes, language, and
'abstraction.
SUB updpalplasma (f)
    FOR x = 0 TO 255
        OUT &H3C8, x
        OUT &H3C9, 32 - 31 * COS(x * _PI / 128 + f * .00141)
        OUT &H3C9, 32 - 31 * COS(x * _PI / 128 + f * .0141)
        OUT &H3C9, 32 - 31 * COS(x * _PI / 64 + f * .0136)
    NEXT
END SUB

SUB whitefade (totalframes)
    DIM pal(256, 3)
    FOR x = 0 TO 255
        OUT &H3C7, x
        pal(x, 0) = INP(&H3C9)
        pal(x, 1) = INP(&H3C9)
        pal(x, 2) = INP(&H3C9)
    NEXT
    FOR f = totalframes TO 0 STEP -1
        f! = f / totalframes
        WAIT &H3DA, 8, 8
        WAIT &H3DA, 8
        FOR x = 0 TO 255
            OUT &H3C8, x
            OUT &H3C9, pal(x, 0) * f! + 63 * (1 - f!)
            OUT &H3C9, pal(x, 1) * f! + 63 * (1 - f!)
            OUT &H3C9, pal(x, 2) * f! + 63 * (1 - f!)
        NEXT
        totalframecount = totalframecount + 1
        IF LEN(INKEY$) THEN EXIT SUB
    NEXT
END SUB

