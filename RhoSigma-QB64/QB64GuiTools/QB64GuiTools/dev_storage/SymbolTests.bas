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
'| === SymbolTests.bas ===                                           |
'|                                                                   |
'| == Test environment for SymbolC class's scalable polygon symbols. |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'--- set Symbol and behavior ---
which$ = "MediaDisk" 'symbol name as used in SymbolC class
keep% = -1 'keep aspect ratio: yes = -1, no = 0
bgimg% = -1 'background image: use image = -1, blank screen = 0

'-----------------------------------------------
'--- DON'T CHANGE ANYTHING BEYOND THIS POINT ---
'-----------------------------------------------
DECLARE LIBRARY "..\dev_framework\GuiAppFrame" 'Do not add .h here !!
    FUNCTION FindColor& (BYVAL r&, BYVAL g&, BYVAL b&, BYVAL i&, BYVAL mi&, BYVAL ma&)
    'This is a replacement for the _RGB function. It works for up to 8-bit
    '(256 colors) images only and needs a valid image. It can limit the
    'number of pens to search and uses a better color matching algorithm.
END DECLARE
CONST guiReservedPens% = 0 'no reserved pens
REDIM SHARED fsNearCol%(&HFFFFFF)

IF _FILEEXISTS("qb64.exe") OR _FILEEXISTS("qb64pe.exe") THEN
    path$ = "QB64GuiTools\dev_storage\" 'compiled to qb64 folder
ELSE
    path$ = "" 'compiled to source folder
END IF

appScreen& = _NEWIMAGE(480, 336, 256)
SCREEN appScreen&
'$INCLUDE: '..\dev_framework\GuiAppPalette.bm'
DIM SHARED guiBackPen%: guiBackPen% = 9 'regular background pen
DIM SHARED guiTextPen%: guiTextPen% = 1 'regular text (foreground) pen
DIM SHARED guiHighPen%: guiHighPen% = 6 'regular text pen for highlighted (important) text
DIM SHARED guiFillPen%: guiFillPen% = 17 'background pen for currently selected objects
DIM SHARED guiFillTextPen%: guiFillTextPen% = 13 'text pen for text in selected objects
DIM SHARED guiShinePen%: guiShinePen% = 3 'used for light edges of any rulers/frames
DIM SHARED guiShadowPen%: guiShadowPen% = 2 'used for dark edges of any rulers/frames
DIM SHARED guiSolidPen%: guiSolidPen% = 0 'used for solid fills in any rulers/frames
DIM SHARED guiGreenPen%: guiGreenPen% = 7 'green condition pen (eg. Checkmark in "Ok" buttons)
DIM SHARED guiRedPen%: guiRedPen% = 4 'red condition pen (eg. Cross in "Cancel" buttons)
'--- FileSelect$() pens ---
DIM SHARED guiLoadBack%: guiLoadBack% = 11 'background pens for FileSelect$() dialog to quickly
DIM SHARED guiSaveBack%: guiSaveBack% = 13 'show the user if in load/open mode or save mode
DIM SHARED guiMediaDisk%: guiMediaDisk% = 12 'main colors of the respective media symbols used
DIM SHARED guiMediaDrawer%: guiMediaDrawer% = 22 'in the file listings and buttons
DIM SHARED guiMediaFile%: guiMediaFile% = 18
_DELAY 0.2
_SCREENMOVE _MIDDLE

img& = _LOADIMAGE(path$ + "BeachGirl.jpg", 32)
scl& = _NEWIMAGE(480, 336, 32)
_PUTIMAGE , img&, scl& 'scale image
rma& = RemapImageFS&(scl&, appScreen&)
_FREEIMAGE scl&
_FREEIMAGE img&

_TITLE "Esc = Exit / CsrLft = shrink / CsrRgt = expand"

left% = 10: topp% = 10
widt% = 460: heig% = 85
WHILE -1
    COLOR guiTextPen%, guiBackPen%
    CLS
    IF bgimg% THEN FillRectImage 0, 0, 480, 336, rma&

    '--- preselect drawing colors ---
    back% = guiBackPen%: shad% = guiShadowPen%
    shin% = guiShinePen%: bord% = guiTextPen%
    '--- select symbol to draw, adjust default colors ---
    SELECT CASE LCASE$(which$)
        CASE "tapepause": RESTORE SymbolClass_TapePause
        CASE "tapestop": RESTORE SymbolClass_TapeStop
        CASE "taperecord": RESTORE SymbolClass_TapeRecord
        CASE "tapeplay": RESTORE SymbolClass_TapePlay
        CASE "tapeprevch": RESTORE SymbolClass_TapePrevCh
        CASE "taperewind": RESTORE SymbolClass_TapeRewind
        CASE "tapeforward": RESTORE SymbolClass_TapeForward
        CASE "tapenextch": RESTORE SymbolClass_TapeNextCh
        CASE "tapeeject": RESTORE SymbolClass_TapeEject
        CASE "arrowup": RESTORE SymbolClass_ArrowUp
        CASE "arrowdown": RESTORE SymbolClass_ArrowDown
        CASE "arrowleft": RESTORE SymbolClass_ArrowLeft
        CASE "arrowright": RESTORE SymbolClass_ArrowRight
        CASE "cycle": RESTORE SymbolClass_Cycle
        CASE "checkmark": RESTORE SymbolClass_Checkmark: shad% = guiGreenPen%
        CASE "cross": RESTORE SymbolClass_Cross: shad% = guiRedPen%
        CASE "star": RESTORE SymbolClass_Star
        CASE "pentagon": RESTORE SymbolClass_Pentagon
        CASE "octagon": RESTORE SymbolClass_Octagon
        CASE "increment": RESTORE SymbolClass_Increment
        CASE "decrement": RESTORE SymbolClass_Decrement
        CASE "mediadisk": RESTORE SymbolClass_MediaDisk: shad% = guiMediaDisk%
        CASE "mediadrawer": RESTORE SymbolClass_MediaDrawer: shin% = guiMediaDrawer%
        CASE "mediafile": RESTORE SymbolClass_MediaFile: shin% = guiMediaFile%
        CASE ELSE: RESTORE SymbolClass_RhoSigma
    END SELECT
    '--- draw object ---
    READ nomx%, nomy%, poly%, ppoi%
    sclx# = (widt% - 1) / (nomx% - 1): scly# = (heig% - 1) / (nomy% - 1)
    IF keep% THEN
        IF sclx# < scly# THEN scly# = sclx#: ELSE sclx# = scly#
    END IF
    '--- show dimensions ---
    iwi% = ((nomx% - 1) * sclx#) + 1: ihe% = ((nomy% - 1) * scly#) + 1
    LOCATE 21, 1
    PRINT "WIDTH ="; STR$(iwi%); " / HEIGHT ="; STR$(ihe%); " / SIZE ="; STR$(INT(100 / nomy% * ihe%)); "%";
    LINE (left% - 2, topp% - 2)-(left% + widt% + 1, topp% + heig% + 1), guiHighPen%, B
    LINE (left% - 2, topp% - 2)-(left% + iwi% + 1, topp% + ihe% + 1), guiFillPen%, B
    '--- regular polygon filling ---
    FOR i% = 1 TO poly%
        READ corn%, colo$
        REDIM xarr%(corn% - 1)
        REDIM yarr%(corn% - 1)
        FOR j% = 0 TO corn% - 1
            READ poix%, poiy%
            xarr%(j%) = poix% * sclx# + left%
            yarr%(j%) = poiy% * scly# + topp%
        NEXT j%
        fill% = -1
        SELECT CASE LCASE$(colo$)
            CASE "back": fill% = back%
            CASE "shadow": fill% = shad%
            CASE "shine": fill% = shin%
        END SELECT
        FillPolygon xarr%(), yarr%(), fill%, bord%
    NEXT i%
    ERASE yarr%
    ERASE xarr%
    '--- PAINT polygon filling ---
    FOR i% = 1 TO ppoi%
        READ poix%, poiy%, colo$
        SELECT CASE LCASE$(colo$)
            CASE "back": fill% = back%
            CASE "shadow": fill% = shad%
            CASE "shine": fill% = shin%
        END SELECT
        poix% = poix% * sclx# + left%
        poiy% = poiy% * scly# + topp%
        PAINT (poix%, poiy%), fill%, bord%
    NEXT i%

    _DISPLAY
    SLEEP
    i$ = INKEY$
    WHILE INKEY$ <> "": WEND
    IF i$ = CHR$(27) THEN EXIT WHILE
    IF i$ = CHR$(0) + "K" THEN
        IF heig% > 4 THEN heig% = heig% - 1
    END IF
    IF i$ = CHR$(0) + "M" THEN
        IF heig% < 300 THEN heig% = heig% + 1
    END IF
WEND

SCREEN 0
_FREEIMAGE rma&
_FREEIMAGE appScreen&
ERASE fsNearCol%
SYSTEM

'----------------------------------
'1st DATA: designed width, designed height, num. polygons, num. PAINT points
'2nd DATA: num. corners in following polygon, "fill color" ("none" for no fill)
'3rd DATA: X/Y corner coordinate pairs (trace clockwise)
'now repeat 2nd/3rd DATA for number of polygons specified in 1st DATA
'IF PAINT points > 0 THEN define points
'    DATA: X/Y coordinate pair for PAINT, "fill color"
'    repeat for number of PAINT points specified in 1st DATA
'END IF
SymbolClass_TapePause:
DATA 15,17,2,0
DATA 4,"shine"
DATA 0,16,0,0,5,0,5,16
DATA 4,"shine"
DATA 9,16,9,0,14,0,14,16
'----------------
SymbolClass_TapeStop:
DATA 15,17,1,0
DATA 4,"shine"
DATA 0,16,0,0,14,0,14,16
'----------------
SymbolClass_TapeRecord:
DATA 17,17,1,0
DATA 12,"shine"
DATA 0,8,1,4,4,1,8,0,12,1,15,4,16,8,15,12,12,15,8,16,4,15,1,12
'----------------
SymbolClass_TapePlay:
DATA 15,17,1,0
DATA 3,"shine"
DATA 0,16,0,0,14,8
'----------------
SymbolClass_TapePrevCh:
DATA 23,17,3,0
DATA 4,"shine"
DATA 0,16,0,0,4,0,4,16
DATA 3,"shine"
DATA 5,8,13,0,13,16
DATA 3,"shine"
DATA 14,8,22,0,22,16
'----------------
SymbolClass_TapeRewind:
DATA 18,17,2,0
DATA 3,"shine"
DATA 0,8,8,0,8,16
DATA 3,"shine"
DATA 9,8,17,0,17,16
'----------------
SymbolClass_TapeForward:
DATA 18,17,2,0
DATA 3,"shine"
DATA 0,16,0,0,8,8
DATA 3,"shine"
DATA 9,16,9,0,17,8
'----------------
SymbolClass_TapeNextCh:
DATA 23,17,3,0
DATA 3,"shine"
DATA 0,16,0,0,8,8
DATA 3,"shine"
DATA 9,16,9,0,17,8
DATA 4,"shine"
DATA 18,16,18,0,22,0,22,16
'----------------
SymbolClass_TapeEject:
DATA 19,17,2,0
DATA 4,"shine"
DATA 0,16,0,13,18,13,18,16
DATA 3,"shine"
DATA 0,10,9,0,18,10
'----------------
SymbolClass_ArrowUp:
DATA 17,17,1,0
DATA 4,"shine"
DATA 0,16,8,0,16,16,8,10
'----------------
SymbolClass_ArrowDown:
DATA 17,17,1,0
DATA 4,"shine"
DATA 0,0,8,6,16,0,8,16
'----------------
SymbolClass_ArrowLeft:
DATA 17,17,1,0
DATA 4,"shine"
DATA 0,8,16,0,10,8,16,16
'----------------
SymbolClass_ArrowRight:
DATA 17,17,1,0
DATA 4,"shine"
DATA 0,16,6,8,0,0,16,8
'----------------
SymbolClass_Cycle:
DATA 17,17,1,0
DATA 23,"shadow"
DATA 0,13,0,3,3,0,11,0,14,3,14,5,16,5,13,8,10,5,12,5,12,4,10,2,4,2,2,4,2,12,4,14,10,14,12,12,12,11,14,11,14,13,11,16,3,16
'----------------
SymbolClass_Checkmark:
DATA 13,17,1,0
DATA 6,"shadow"
DATA 0,8,2,7,4,10,9,0,12,0,4,16
'----------------
SymbolClass_Cross:
DATA 17,17,1,0
DATA 12,"shadow"
DATA 0,14,6,8,0,2,2,0,8,6,14,0,16,2,10,8,16,14,14,16,8,10,2,16
'----------------
SymbolClass_Star:
DATA 17,17,1,0
DATA 10,"shine"
DATA 0,7,6,7,8,0,10,7,16,7,11,10,13,16,8,12,3,16,5,10
'----------------
SymbolClass_Pentagon:
DATA 17,17,1,0
DATA 5,"shine"
DATA 8,0,16,6,13,16,3,16,0,6
'----------------
SymbolClass_Octagon:
DATA 17,17,1,0
DATA 8,"shine"
DATA 5,0,11,0,16,5,16,11,11,16,5,16,0,11,0,5
'----------------
SymbolClass_Increment:
DATA 17,17,1,0
DATA 12,"shine"
DATA 0,10,0,6,6,6,6,0,10,0,10,6,16,6,16,10,10,10,10,16,6,16,6,10
'----------------
SymbolClass_Decrement:
DATA 17,17,1,0
DATA 4,"shine"
DATA 0,10,0,6,16,6,16,10
'----------------
SymbolClass_MediaDisk:
DATA 17,17,5,0
DATA 5,"shadow"
DATA 0,15,0,0,16,0,16,16,1,16
DATA 4,"shine"
DATA 2,8,2,0,14,0,14,8
DATA 4,"back"
DATA 2,16,2,10,10,10,10,16
DATA 4,"shadow"
DATA 10,16,10,10,14,10,14,16
DATA 4,"shadow"
DATA 4,15,4,12,5,12,5,15
'----------------
SymbolClass_MediaDrawer:
DATA 21,17,5,0
DATA 4,"shine"
DATA 0,16,0,9,20,9,20,16
DATA 4,"shine"
DATA 2,5,2,0,18,0,18,5
DATA 4,"back"
DATA 1,9,3,5,17,5,19,9
DATA 4,"shadow"
DATA 7,13,7,12,13,12,13,13
DATA 4,"shadow"
DATA 8,3,8,2,12,2,12,3
'----------------
SymbolClass_MediaFile:
DATA 21,17,8,0
DATA 4,"back"
DATA 0,16,0,3,20,3,20,16
DATA 4,"shine"
DATA 1,16,1,5,20,5,20,16
DATA 4,"shadow"
DATA 0,16,0,5,1,5,1,16
DATA 4,"shadow"
DATA 4,9,4,8,9,8,9,9
DATA 4,"shadow"
DATA 11,9,11,8,17,8,17,9
DATA 4,"shadow"
DATA 4,13,4,12,10,12,10,13
DATA 4,"shadow"
DATA 12,13,12,12,16,12,16,13
DATA 6,"shine"
DATA 10,3,10,1,11,0,19,0,20,1,20,3
'----------------
SymbolClass_RhoSigma:
DATA 21,17,3,1
DATA 12,"none"
DATA 0,16,0,0,6,0,8,1,9,2,10,4,10,6,9,8,8,9,6,10,3,10,3,16
DATA 6,"none"
DATA 3,7,3,3,6,3,7,4,7,6,6,7
DATA 16,"shadow"
DATA 10,16,10,14,14,8,10,2,10,0,20,0,20,4,18,4,18,3,14,3,17,8,14,13,18,13,18,12,20,12,20,16
DATA 1,15,"shadow"

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

'=== RS:COPYFROM:GuiAppFrame.bm/RemapImageRS& (original) =============
FUNCTION RemapImageFS& (ohan&, dhan&)
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
                        npen% = FindColor&(sr%, sg%, sb%, nhan&, 24, 255 - guiReservedPens%) 'not known, find one
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
                    '------------------------------------------
                    '--- End of FS ----------------------------
                    '------------------------------------------
                    noff%& = noff%& + 1 'next dest pixel
                    soff%& = soff%& + 4 'next source pixel
                NEXT x%
                tmp% = cro%: cro% = nro%: nro% = tmp% 'exchange distribution array row offsets
            NEXT y%
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

'$INCLUDE: '..\dev_framework\support\PolygonSupport.bm'
