'----------------------------------------------------------------------------
'RIPPLES, by Antoni Gual 26/1/2001   agual@eic.ictnet.es
'Simulates water reflection in a SCREEN 13 image
'----------------------------------------------------------------------------
'Who said QBasic is obsolete?
'This is a remake of the popular LAKE Java applet.
'You can experiment with different images and different values of the
'parameters passed to RIPPLES sub.
'----------------------------------------------------------------------------
'PCX Loader modified from Kurt Kuzba.
'Timber Wolf came with PaintShopPro 5, I rescaned it to fit SCREEN13
'----------------------------------------------------------------------------
'WARNING!: PCX MUST be 256 colors and 320x 200.The loader does'nt check it!!
'----------------------------------------------------------------------------
'Use as you want, only give me credit.
'E-mail me to tell me about!
'----------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

CONST FALSE = 0, TRUE = NOT FALSE

IF NOT LoadPCX("twolf.pcx") THEN
    PRINT "File twolf.pcx not Found!"
    END
END IF

ripples 150, .1, 2, 1

SYSTEM 0

'LOADS A 320x200x256 PCX. Modified from Kurt Kuzba
FUNCTION LoadPCX%% (PCX$)
    DIM AS LONG bseg, f, fin, t, BOFS, RLE, fpos, l, pn, dat
    DIM AS STRING p
    DIM done AS _BYTE

    LoadPCX = FALSE
    bseg& = &HA000

    f = FREEFILE
    OPEN PCX$ FOR BINARY AS #f
    IF LOF(f) = 0 THEN
        CLOSE #f
        KILL PCX$
        EXIT FUNCTION
    END IF

    fin& = LOF(1) - 767: SEEK #f, fin&
    p$ = INPUT$(768, 1)
    'p% = 1
    fin& = fin& - 1
    OUT &H3C8, 0: DEF SEG = VARSEG(p$)

    FOR t& = SADD(p$) TO SADD(p$) + 767
        OUT &H3C9, PEEK(t&) \ 4
    NEXT

    SEEK #f, 129
    t& = BOFS&
    RLE = 0
    DO
        p$ = INPUT$(256, f)
        fpos& = SEEK(f)
        l = LEN(p$)
        IF fpos& > fin& THEN
            l = l - (fpos& - fin&)
            done = TRUE
        END IF
        FOR pn = SADD(p$) TO SADD(p$) + l - 1
            DEF SEG = VARSEG(p$)
            dat = PEEK(pn)
            DEF SEG = bseg&
            IF RLE THEN
                FOR RLE = RLE TO 1 STEP -1:
                    POKE t&, dat: t& = t& + 1
                NEXT
            ELSE
                IF (dat AND 192) = 192 THEN
                    RLE = dat AND 63
                ELSE
                    POKE t&, dat
                    t& = t& + 1
                END IF
            END IF
        NEXT
    LOOP UNTIL done
    CLOSE f

    LoadPCX = TRUE
END FUNCTION

'----------------------------------------------------------------------------
'Ripples SUB, by Antoni Gual  26/1/2001   agual@eic.ictnet.es
'Simulates water reflection in a SCREEN 13 image
'----------------------------------------------------------------------------
'PARAMETERS:
'waterheight     in pixels from top
'dlay!           delay between two recalcs in seconds
'amplitude!      amplitude of the distortion in pixels
'wavelength!     distance between two ripples
'----------------------------------------------------------------------------
SUB ripples (waterheight, dlay!, amplitude!, wavelength!)
    DIM AS LONG widh, hght
    DIM AS SINGLE i, j, temp

    'these are screen size constants, don't touch it!
    widh = 319
    hght = 199

    REDIM a%(162)
    DIM r(0 TO 200) AS INTEGER

    'precalc a sinus table for speed
    FOR i! = 0 TO 200
        r(i!) = CINT(SIN(i! / wavelength!) * amplitude!)
    NEXT
    j = 0

    'the loop!
    DO
        'it must be slowed down to look real!
        _DELAY dlay!

        FOR i = 1 TO hght - waterheight
            temp = waterheight - i + r((j + i) MOD 200)
            GET (1, temp)-(widh, temp), a%()
            PUT (1, waterheight + i), a%(), PSET
        NEXT
        IF j = 200 THEN j = 0 ELSE j = j + 1
    LOOP UNTIL LEN(INKEY$)
END SUB
