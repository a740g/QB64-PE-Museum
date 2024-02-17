'+---------------+---------------------------------------------------+
'| ###### ###### |     .--. .         .-.                            |
'| ##  ## ##   # |     |   )|        (   ) o                         |
'| ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
'| ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
'| ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
'| ##     ##   # |                            ._.'                   |
'| ##     ###### | Sources & Documents placed under the MIT License. |
'+---------------+---------------------------------------------------+
'|                                                                   |
'| === FSRemapTests.bas ===                                          |
'|                                                                   |
'| == Test environment for the Floyd-Steinberg remapper function.    |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

DECLARE LIBRARY "QB64GuiTools\dev_framework\GuiAppFrame" 'Do not add .h here !!
    FUNCTION FindColor& (BYVAL r&, BYVAL g&, BYVAL b&, BYVAL i&, BYVAL mi&, BYVAL ma&)
    'This is a replacement for the _RGB function. It works for up to 8-bit
    '(256 colors) images only and needs a valid image. It can limit the
    'number of pens to search and uses a better color matching algorithm.
END DECLARE
REDIM SHARED fsNearCol%(&HFFFFFF)

IF _FILEEXISTS("qb64.exe") THEN
    path$ = "QB64GuiTools\dev_storage\" 'qb64 folder
ELSE
    path$ = "" 'source folder
END IF

wid% = 800
hei% = 558
file$ = "BeachGirl.jpg"
' wid% = 1280
' hei% = 720
' file$ = "KoreanGirl.png"

loops% = 10
DIM SHARED img&(loops%, 1)
DIM SHARED tim#(loops%, 1)
DIM SHARED sum#(1)
DIM SHARED avr#(1)

DIM SHARED appScreen&
DIM SHARED st#
DIM SHARED en#

appScreen& = _NEWIMAGE(wid%, hei%, 256)
SCREEN appScreen&
'$INCLUDE: 'QB64GuiTools\dev_framework\GuiAppPalette.bm'
_DELAY 0.2
_SCREENMOVE _MIDDLE

COLOR 1, 0: CLS
PRINT "please wait ("; SPACE$(loops% + 3); ")"
LOCATE 1, 14

ihan& = _LOADIMAGE(path$ + file$, 32)
IF ihan& < -1 THEN
    wi% = _WIDTH(ihan&): he% = _HEIGHT(ihan&)
    pix& = wi% * he%
    '--- 1st run is slower, as fsNearCol%() is not populated yet ---
    PRINT "X";
    img&(0, 0) = RemapImageFS&(ihan&, appScreen&, 0)
    tim#(0, 0) = (en# - st#)
    IF img&(0, 0) < -1 THEN _FREEIMAGE img&(0, 0)
    REDIM SHARED fsNearCol%(&HFFFFFF) 'destroy it once again
    img&(0, 1) = RemapImageFS&(ihan&, appScreen&, -1)
    tim#(0, 1) = (en# - st#)
    IF img&(0, 1) < -1 THEN _FREEIMAGE img&(0, 1)
    '--- do some loops to catch enough best/worst case scenarios ---
    FOR i% = 1 TO loops%
        PRINT "X";
        img&(i%, 0) = RemapImageFS&(ihan&, appScreen&, 0)
        tim#(i%, 0) = (en# - st#)
        img&(i%, 1) = RemapImageFS&(ihan&, appScreen&, -1)
        tim#(i%, 1) = (en# - st#)
    NEXT i%
    '--- calculate average timings & free new images ---
    sum#(0) = 0: sum#(1) = 0
    FOR i% = 1 TO loops%
        sum#(0) = sum#(0) + tim#(i%, 0)
        IF img&(i%, 0) < -1 THEN _FREEIMAGE img&(i%, 0)
        sum#(1) = sum#(1) + tim#(i%, 1)
        IF img&(i%, 1) < -1 THEN _FREEIMAGE img&(i%, 1)
    NEXT i%
    avr#(0) = sum#(0) / loops%
    avr#(1) = sum#(1) / loops%
    '--- now for display, one w/o FS and one w/ FS ---
    PRINT "X";
    fsoff& = RemapImageFS&(ihan&, appScreen&, 0)
    PRINT "X";
    fson& = RemapImageFS&(ihan&, appScreen&, -1)
    '--- display results ---
    fss$ = "Floyd-Steinberg remapped"
    IF fson& < -1 AND fsoff& < -1 THEN
        WHILE INKEY$ <> CHR$(27)
            IF fss$ = "Floyd-Steinberg remapped" THEN
                FillRectImage 0, 0, _WIDTH, _HEIGHT, fson&
            ELSE
                FillRectImage 0, 0, _WIDTH, _HEIGHT, fsoff&
            END IF
            LOCATE 1, 1
            PRINT "Image Size:"; STR$(wi%); " x"; STR$(he%); " ="; STR$(pix&); " Pixels"
            PRINT
            PRINT "Remap timings without FS processing:"
            PRINT "------------------------------------"
            PRINT "Timings w/o populated fsNearCol%() array:"
            PRINT USING "1st Run Time for Image: #.######## sec."; tim#(0, 0)
            PRINT USING "1st Run Time per Pixel: #.######## sec."; tim#(0, 0) / pix&
            PRINT
            PRINT "Timings w/ populated fsNearCol%() array:"
            PRINT USING "Average Time for Image: #.######## sec."; avr#(0)
            PRINT USING "Average Time per Pixel: #.######## sec."; avr#(0) / pix&
            PRINT
            PRINT "Remap Timings with FS processing:"
            PRINT "---------------------------------"
            PRINT "Timings w/o populated fsNearCol%() array:"
            PRINT USING "1st Run Time for Image: #.######## sec."; tim#(0, 1)
            PRINT USING "1st Run Time per Pixel: #.######## sec."; tim#(0, 1) / pix&
            PRINT
            PRINT "Timings w/ populated fsNearCol%() array:"
            PRINT USING "Average Time for Image: #.######## sec."; avr#(1)
            PRINT USING "Average Time per Pixel: #.######## sec."; avr#(1) / pix&
            PRINT
            PRINT "Display: "; fss$
            PRINT
            PRINT "press any key to switch Display..."
            PRINT "press Esc key to quit..."
            IF fss$ = "Floyd-Steinberg remapped" THEN
                fss$ = "Simple nearest color remapped"
            ELSE
                fss$ = "Floyd-Steinberg remapped"
            END IF
            SLEEP
        WEND
    END IF
    IF fson& < -1 THEN _FREEIMAGE fson&
    IF fsoff& < -1 THEN _FREEIMAGE fsoff&
    _FREEIMAGE ihan&
END IF

ERASE fsNearCol%
SYSTEM

'=== RS:COPYFROM:GuiAppFrame.bm/FillRectImage (original) =============
SUB FillRectImage (xs%, ys%, wi%, he%, ihan&)
tcol% = _CLEARCOLOR(ihan&): _CLEARCOLOR _NONE, ihan&
than& = _NEWIMAGE(ABS(wi%), ABS(he%), 256)
IF than& < -1 THEN
    FOR y% = 0 TO ABS(he%) - 1 STEP _HEIGHT(ihan&)
        FOR x% = 0 TO ABS(wi%) - 1 STEP _WIDTH(ihan&)
            _PUTIMAGE (x%, y%)-(x% + _WIDTH(ihan&) - 1, y% + _HEIGHT(ihan&) - 1), ihan&, than&
        NEXT x%
    NEXT y%
    IF tcol% > -1 THEN _CLEARCOLOR tcol%, than&
    _PUTIMAGE (xs%, ys%)-(xs% + wi% - 1, ys% + he% - 1), than&
    _FREEIMAGE than&
END IF
END SUB

'=== RS:COPYFROM:GuiAppFrame.bm/RemapImageRS& (++RS:CHG) =============
FUNCTION RemapImageFS& (ohan&, dhan&, fs%) 'RS:CHG fs% added
RemapImageFS& = -1 'so far return invalid handle
shan& = ohan& 'avoid side effect on given argument
IF shan& < -1 THEN
    '--- check/adjust source image & get new 8-bit image ---
    swid% = _WIDTH(shan&): shei% = _HEIGHT(shan&)
    IF _PIXELSIZE(shan&) <> 4 THEN
        than& = _NEWIMAGE(swid%, shei%, 32)
        IF than& >= -1 THEN EXIT FUNCTION
        _PUTIMAGE , shan&, than&
        shan& = than&
    ELSE
        than& = -1 'avoid freeing below
    END IF
    nhan& = _NEWIMAGE(swid%, shei%, 256)
    '--- Floyd-Steinberg error distribution arrays ---
    rhan& = _NEWIMAGE(swid%, 2, 32) 'these are missused as LONG arrays,
    ghan& = _NEWIMAGE(swid%, 2, 32) 'with CHECKING:OFF this is much faster
    bhan& = _NEWIMAGE(swid%, 2, 32) 'than real QB64 arrays
    '--- curr/next row offsets (for distribution array access) ---
    cro% = 0: nro% = swid% * 4 'will be swapped after each pixel row
    '--- the matrix values are extended by 16384 to avoid slow floating ---
    '--- point ops and to allow for integer storage in the above arrays ---
    '--- also it's a power of 2, which may be optimized into a bitshift ---
    seven% = (7 / 16) * 16384 'X+1,Y+0 error fraction
    three% = (3 / 16) * 16384 'X-1,Y+1 error fraction
    five% = (5 / 16) * 16384 'X+0,Y+1 error fraction
    one% = (1 / 16) * 16384 'X+1,Y+1 error fraction
    '--- if all is good, then start remapping ---
    $CHECKING:OFF
    IF nhan& < -1 AND rhan& < -1 AND ghan& < -1 AND bhan& < -1 THEN
        _COPYPALETTE dhan&, nhan& 'dest palette to new image
        '--- for speed we do direct memory access ---
        DIM sbuf AS _MEM: sbuf = _MEMIMAGE(shan&): soff%& = sbuf.OFFSET
        DIM nbuf AS _MEM: nbuf = _MEMIMAGE(nhan&): noff%& = nbuf.OFFSET
        DIM rbuf AS _MEM: rbuf = _MEMIMAGE(rhan&): roff%& = rbuf.OFFSET
        DIM gbuf AS _MEM: gbuf = _MEMIMAGE(ghan&): goff%& = gbuf.OFFSET
        DIM bbuf AS _MEM: bbuf = _MEMIMAGE(bhan&): boff%& = bbuf.OFFSET
        '--- iterate through pixels ---
        st# = TIMER(0.001) 'RS:CHG line added
        FOR y% = 0 TO shei% - 1
            FOR x% = 0 TO swid% - 1
                '--- curr/prev/next pixel offsets ---
                cpo% = x% * 4: ppo% = cpo% - 4: npo% = cpo% + 4
                '--- get pixel ARGB value from source ---
                srgb~& = _MEMGET(sbuf, soff%&, _UNSIGNED LONG)
                '--- add distributed error, shrink by 16384, clear error ---
                '--- current pixel X+0, Y+0 (= cro% (current row offset)) ---
                poff% = cro% + cpo% 'pre-calc full pixel offset
                sr% = ((srgb~& AND &HFF0000~&) \ 65536) + (_MEMGET(rbuf, roff%& + poff%, LONG) \ 16384) 'red
                sg% = ((srgb~& AND &HFF00~&) \ 256) + (_MEMGET(gbuf, goff%& + poff%, LONG) \ 16384) 'green
                sb% = (srgb~& AND &HFF~&) + (_MEMGET(bbuf, boff%& + poff%, LONG) \ 16384) 'blue
                _MEMPUT rbuf, roff%& + poff%, 0 AS LONG 'clearing each single pixel error using _MEMPUT
                _MEMPUT gbuf, goff%& + poff%, 0 AS LONG 'turns out even faster than clearing the entire
                _MEMPUT bbuf, boff%& + poff%, 0 AS LONG 'pixel row using _MEMFILL at the end of the loop
                '--- find nearest color ---
                crgb~& = _RGBA32(sr%, sg%, sb%, 0) 'used for fast value clipping + channel merge
                IF fsNearCol%(crgb~&) > 0 THEN
                    npen% = fsNearCol%(crgb~&) - 1 'already known
                ELSE
                    npen% = FindColor&(sr%, sg%, sb%, nhan&, -1, -1) 'RS:CHG -1, -1 ('not known, find one)
                    fsNearCol%(crgb~&) = npen% + 1 'save for later use
                END IF
                '--- put colormapped pixel to dest ---
                _MEMPUT nbuf, noff%&, npen% AS _UNSIGNED _BYTE
                '------------------------------------------
                '--- Floyd-Steinberg error distribution ---
                '------------------------------------------
                '--- You may comment this block out, to see the
                '--- result without applied FS matrix.
                '-----
                IF fs% THEN 'RS:CHG line added
                    '--- get dest palette RGB value, calc error to clipped source ---
                    nrgb~& = _PALETTECOLOR(npen%, nhan&)
                    er% = ((crgb~& AND &HFF0000~&) - (nrgb~& AND &HFF0000~&)) \ 65536
                    eg% = ((crgb~& AND &HFF00~&) - (nrgb~& AND &HFF00~&)) \ 256
                    eb% = (crgb~& AND &HFF~&) - (nrgb~& AND &HFF~&)
                    '--- distribute error according to FS matrix ---
                    IF x% > 0 THEN
                        '--- X-1, Y+1 (= nro% (next row offset)) ---
                        poff% = nro% + ppo% 'pre-calc full pixel offset
                        _MEMPUT rbuf, roff%& + poff%, _MEMGET(rbuf, roff%& + poff%, LONG) + (er% * three%) AS LONG 'red
                        _MEMPUT gbuf, goff%& + poff%, _MEMGET(gbuf, goff%& + poff%, LONG) + (eg% * three%) AS LONG 'green
                        _MEMPUT bbuf, boff%& + poff%, _MEMGET(bbuf, boff%& + poff%, LONG) + (eb% * three%) AS LONG 'blue
                    END IF
                    '--- X+0, Y+1 (= nro% (next row offset)) ---
                    poff% = nro% + cpo% 'pre-calc full pixel offset
                    _MEMPUT rbuf, roff%& + poff%, _MEMGET(rbuf, roff%& + poff%, LONG) + (er% * five%) AS LONG 'red
                    _MEMPUT gbuf, goff%& + poff%, _MEMGET(gbuf, goff%& + poff%, LONG) + (eg% * five%) AS LONG 'green
                    _MEMPUT bbuf, boff%& + poff%, _MEMGET(bbuf, boff%& + poff%, LONG) + (eb% * five%) AS LONG 'blue
                    IF x% < (swid% - 1) THEN
                        '--- X+1, Y+0 (= cro% (current row offset)) ---
                        poff% = cro% + npo% 'pre-calc full pixel offset
                        _MEMPUT rbuf, roff%& + poff%, _MEMGET(rbuf, roff%& + poff%, LONG) + (er% * seven%) AS LONG 'red
                        _MEMPUT gbuf, goff%& + poff%, _MEMGET(gbuf, goff%& + poff%, LONG) + (eg% * seven%) AS LONG 'green
                        _MEMPUT bbuf, boff%& + poff%, _MEMGET(bbuf, boff%& + poff%, LONG) + (eb% * seven%) AS LONG 'blue
                        '--- X+1, Y+1 (= nro% (next row offset)) ---
                        poff% = nro% + npo% 'pre-calc full pixel offset
                        _MEMPUT rbuf, roff%& + poff%, _MEMGET(rbuf, roff%& + poff%, LONG) + (er% * one%) AS LONG 'red
                        _MEMPUT gbuf, goff%& + poff%, _MEMGET(gbuf, goff%& + poff%, LONG) + (eg% * one%) AS LONG 'green
                        _MEMPUT bbuf, boff%& + poff%, _MEMGET(bbuf, boff%& + poff%, LONG) + (eb% * one%) AS LONG 'blue
                    END IF
                END IF 'RS:CHG line added
                '------------------------------------------
                '--- End of FS ----------------------------
                '------------------------------------------
                noff%& = noff%& + 1 'next dest pixel
                soff%& = soff%& + 4 'next source pixel
            NEXT x%
            tmp% = cro%: cro% = nro%: nro% = tmp% 'exchange distribution array row offsets
        NEXT y%
        en# = TIMER(0.001) 'RS:CHG line added
        '--- memory cleanup ---
        _MEMFREE bbuf
        _MEMFREE gbuf
        _MEMFREE rbuf
        _MEMFREE nbuf
        _MEMFREE sbuf
        '--- set result ---
        RemapImageFS& = nhan&
        nhan& = -1 'avoid freeing below
    END IF
    $CHECKING:ON
    '--- remapping done or error, cleanup remains ---
    IF bhan& < -1 THEN _FREEIMAGE bhan&
    IF ghan& < -1 THEN _FREEIMAGE ghan&
    IF rhan& < -1 THEN _FREEIMAGE rhan&
    IF nhan& < -1 THEN _FREEIMAGE nhan&
    IF than& < -1 THEN _FREEIMAGE than&
END IF
END FUNCTION

