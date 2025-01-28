'digital reality by plasma
'.........................
'
'[11-01-2004] updated final release
'[07-16-2002] final release
'[11-01-2001] contest release
'
'created for Toshi's Fall 2001 "Pure QB" demo competition
'placed 3rd out of 6 entries
'
'www.phatcode.net

_DEFINE A-Z AS INTEGER
'$STATIC

CONST NONE = 0
CONST ADLIB = 1
CONST MPU401 = 2
CONST FALSE = 0
CONST TRUE = NOT FALSE

CONST Compiled = TRUE 'change this to FALSE to run in the QB IDE
'change this to TRUE when compiling for extra speed

DIM SHARED Pack
DIM SHARED PackFile$

PackFile$ = "DIGIREAL.BIN"
Pack = FREEFILE
OPEN "DIGIREAL.BIN" FOR BINARY AS #Pack
IF LOF(Pack) = 0 THEN
    CLOSE #Pack
    KILL PackFile$
    PRINT "Cannot find " + PackFile$
    END
END IF

DIM SHARED Gfx.OldSkool
DIM SHARED Gfx.WaitSync

DIM SHARED Pal.FadeBuffer(767)
DIM SHARED Font.Buffer(Font.Size("DEMOFONT.BMF"))

DIM SHARED Music.Mode
DIM SHARED Music.Port
DIM SHARED Music.NoteFreq(11) AS INTEGER

DIM SHARED Music.NumTracks
DIM SHARED Music.PattLen
DIM SHARED Music.Channel(7) AS STRING * 11
DIM SHARED Music.TrackList(255) AS STRING * 1
DIM SHARED Music.Delay(255) AS INTEGER
'$DYNAMIC
DIM SHARED Music.Pattern(0, 0, 0) AS STRING * 1
'$STATIC
DIM SHARED Music.Drums(7)

DIM SHARED Music.CurTrack
DIM SHARED Music.CurPatt
DIM SHARED Music.CurPos
DIM SHARED Music.Time&
DIM SHARED Music.TimeDelay
DIM SHARED Music.Playing

DIM SHARED Music.LastNote(7)

DIM SHARED Lookup.Cosine(360) AS SINGLE
DIM SHARED Lookup.Sine(360) AS SINGLE
DIM SHARED Lookup.Sine160(0 TO 360) AS SINGLE
DIM SHARED Lookup.Cosine160(0 TO 360) AS SINGLE

RANDOMIZE 357

Do.Startup
Lookup.GenTables

Font.Load "DEMOFONT.BMF", VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0))

SCREEN 13

IF NOT Music.Init THEN
    PRINT "Couldn't init music device!"
    END
END IF

Music.File$ = "DIGIREAL.FMT"
REDIM SHARED Music.Pattern(Music.Size(Music.File$, 0), Music.Size(Music.File$, 1), 7) AS STRING * 1

Music.Load Music.File$

SCREEN 13
Do.Title
Do.Space
Do.VectorBalls
Do.Fire
Do.FloorMapper
Do.Plasma
Do.Flag
Do.End

SUB Do.End

    Music.Stop

    SCREEN 0, , 0, 0
    WIDTH 80
    COLOR 7, 0
    CLS

    FOR WaitRetrace = 0 TO 59
        WAIT &H3DA, 8, 8
        WAIT &H3DA, 8
    NEXT

    DIM buffer1(1999)
    DIM buffer2(1999)

    SEEK #Pack, Pack.Offset&(Pack, "END.SCR")

    Byte$ = " "
    FOR x = 0 TO 3999
        GET #Pack, , Byte$
        DEF SEG = VARSEG(buffer2(0))
        POKE VARPTR(buffer2(0)) + x, ASC(Byte$)
        DEF SEG = &HB800
        POKE x + 8192, ASC(Byte$)
    NEXT

    Gfx.Text.Scroll VARSEG(buffer1(0)), VARPTR(buffer1(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0))

    PCOPY 2, 0

    DO WHILE INKEY$ <> ""
    LOOP

    LOCATE 23, 1
    END

END SUB

SUB Do.Fire

    CLS

    DIM buffer1(9600)
    DIM buffer2(9600)

    DIM pal(383)
    Gfx.Pal.Load "TITLE.PAL", VARSEG(pal(0)), VARPTR(pal(0))
    Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    Music.Play

    DIM Rand(8191)
    FOR x = 0 TO 8191
        Rand(x) = INT(RND * 2)
    NEXT

    DIM TopBuffer(8001)
    DIM BottomBuffer(8001)
    TopBuffer(0) = 2560
    BottomBuffer(0) = 2560

    DIM WhitePal(383)

    FOR i = 0 TO 383
        WhitePal(i) = &H3F3F
    NEXT

    waitfire = 768
    FOR flame = 0 TO waitfire

        DEF SEG = VARSEG(buffer1(0))

        IF Compiled THEN

            FOR x = 0 TO 319
                IF INT(Rand(seed)) = 0 THEN
                    POKE VARPTR(buffer1(0)) + (49 * 320) + x, 32
                ELSE
                    POKE VARPTR(buffer1(0)) + (49 * 320) + x, 255
                END IF
                seed = seed + 1
                IF seed = 8192 THEN seed = 0
            NEXT

        ELSE

            FOR x = 0 TO 319
                IF INT(Rand(seed)) = 0 THEN
                    POKE VARPTR(buffer1(0)) + (49 * 320&) + x, 32
                ELSE
                    POKE VARPTR(buffer1(0)) + (49 * 320&) + x, 255
                END IF
                seed = seed + 1
                IF seed = 8192 THEN seed = 0
            NEXT

        END IF

        Music.Play

        IF Compiled THEN

            FOR y = 1 TO 49
                IF y < 32 THEN
                    FOR x = 0 TO 319
                        DEF SEG = VARSEG(buffer1(0))
                        NewPixel = (PEEK(y * 320 + x) + PEEK((y + 1) * 320 + x - 1) + PEEK((y + 1) * 320 + x + 1) + PEEK((y + 1) * 320 + x)) \ 4 - 2
                        IF NewPixel < 32 THEN NewPixel = 32
                        DEF SEG = VARSEG(buffer2(0))
                        POKE y * 320 + x, NewPixel
                        IF NewPixel <> 32 THEN
                            IF y < 47 THEN
                                DEF SEG = VARSEG(BottomBuffer(0))
                                offset = VARPTR(BottomBuffer(0)) + 4
                                POKE offset + x + y * 320, NewPixel
                                DEF SEG = VARSEG(TopBuffer(0))
                                offset = VARPTR(TopBuffer(0)) + 4
                                POKE offset + x + (46 - y) * 320, NewPixel
                            END IF
                        END IF
                    NEXT
                ELSE
                    FOR x = 0 TO 319
                        DEF SEG = VARSEG(buffer1(0))
                        NewPixel = (PEEK(y * 320 + x) + PEEK((y + 1) * 320 + x - 1) + PEEK((y + 1) * 320 + x + 1) + PEEK((y + 1) * 320 + x)) \ 4 - 1
                        IF NewPixel < 32 THEN NewPixel = 32
                        DEF SEG = VARSEG(buffer2(0))
                        POKE y * 320 + x, NewPixel
                        IF NewPixel <> 32 THEN
                            IF y < 47 THEN
                                DEF SEG = VARSEG(BottomBuffer(0))
                                offset = VARPTR(BottomBuffer(0)) + 4
                                POKE offset + x + y * 320, NewPixel
                                DEF SEG = VARSEG(TopBuffer(0))
                                offset = VARPTR(TopBuffer(0)) + 4
                                POKE offset + x + (46 - y) * 320, NewPixel
                            END IF
                        END IF
                    NEXT
                END IF
            NEXT

        ELSE

            FOR y = 1 TO 49
                IF y < 32 THEN
                    FOR x = 0 TO 319
                        DEF SEG = VARSEG(buffer1(0))
                        NewPixel = (PEEK(y * 320& + x) + PEEK((y + 1) * 320& + x - 1) + PEEK((y + 1) * 320& + x + 1) + PEEK((y + 1) * 320& + x)) \ 4 - 2
                        IF NewPixel < 32 THEN NewPixel = 32
                        DEF SEG = VARSEG(buffer2(0))
                        POKE y * 320& + x, NewPixel
                        IF NewPixel <> 32 THEN
                            IF y < 47 THEN
                                DEF SEG = VARSEG(BottomBuffer(0))
                                offset = VARPTR(BottomBuffer(0)) + 4
                                POKE offset + x + y * 320&, NewPixel
                                DEF SEG = VARSEG(TopBuffer(0))
                                offset = VARPTR(TopBuffer(0)) + 4
                                POKE offset + x + (46 - y) * 320&, NewPixel
                            END IF
                        END IF
                    NEXT
                ELSE
                    FOR x = 0 TO 319
                        DEF SEG = VARSEG(buffer1(0))
                        NewPixel = (PEEK(y * 320& + x) + PEEK((y + 1) * 320& + x - 1) + PEEK((y + 1) * 320& + x + 1) + PEEK((y + 1) * 320& + x)) \ 4 - 1
                        IF NewPixel < 32 THEN NewPixel = 32
                        DEF SEG = VARSEG(buffer2(0))
                        POKE y * 320& + x, NewPixel
                        IF NewPixel <> 32 THEN
                            IF y < 47 THEN
                                DEF SEG = VARSEG(BottomBuffer(0))
                                offset = VARPTR(BottomBuffer(0)) + 4
                                POKE offset + x + y * 320&, NewPixel
                                DEF SEG = VARSEG(TopBuffer(0))
                                offset = VARPTR(TopBuffer(0)) + 4
                                POKE offset + x + (46 - y) * 320&, NewPixel
                            END IF
                        END IF
                    NEXT
                END IF
            NEXT

        END IF

        TopBuffer(1) = 46
        BottomBuffer(1) = 46

        IF flame >= waitfire - 255 THEN
            Gfx.Pal.sFade 255, flame - (waitfire - 255), VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(WhitePal(0)), VARPTR(WhitePal(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        END IF

        Music.Play

        IF Gfx.WaitSync > 2 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        PUT (0, 0), TopBuffer(0), PSET
        PUT (0, 199 - 46), BottomBuffer(0), PSET

        FOR x = 0 TO 8191
            buffer1(x) = buffer2(x)
        NEXT

    NEXT

END SUB

SUB Do.Flag

    DIM buffer(12841)

    DIM SineShift(63)
    DIM Flag(199, 103)
    DIM SineFlag(-8 TO 205, -8 TO 111)

    buffer(0) = 1712
    buffer(1) = 120

    FOR x = 0 TO 63
        Music.Play
        SineShift(x) = SIN(x * (6.28318531# / 64)) * 3
    NEXT

    SEEK #Pack, Pack.Offset&(Pack, "FLAG.GFX")

    FOR y = 0 TO 103
        Music.Play
        FOR x = 0 TO 199
            GET #Pack, , Flag(x, y)
        NEXT
    NEXT

    CLS

    DIM buffer1(2559)
    DIM buffer2(2559)
    DIM buffer3(2559)

    DIM FlagPal(383)
    DIM FadeTo(383)
    DIM FadeFrom(383)
    DIM pal(383)

    Music.Play
    Font.Print "in memory of the victims", 80, 0, -1, -1, 320, 16, 192, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer1(0)), VARPTR(buffer1(0))
    Font.Print "september 11, 2001", 100, 8, -1, -1, 320, 16, 192, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer1(0)), VARPTR(buffer1(0))
    Font.Print "united we stand", 107, 0, -1, -1, 320, 16, 192, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0))
    Font.Print "united we fight", 109, 8, -1, -1, 320, 16, 192, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0))

    Gfx.Pal.Load "FLAG.PAL", VARSEG(FlagPal(0)), VARPTR(FlagPal(0))
    Music.Play
  Gfx.xFade.Setup 64, 5120, VARSEG(buffer1(0)), VARPTR(buffer1(0)), VARSEG(FlagPal(0)), VARPTR(FlagPal(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0)), VARSEG(FlagPal(0)), VARPTR(FlagPal(0)), VARSEG(buffer3(0)), VARPTR(buffer3(0)), VARSEG(FadeTo(0)),  _
VARPTR(FadeTo(0)), VARSEG(FadeFrom(0)), VARPTR(FadeFrom(0))

    DEF SEG = VARSEG(buffer3(0))
    FOR x = 0 TO 5119
        colr = PEEK(VARPTR(buffer3(0)) + x)
        POKE VARPTR(buffer3(0)) + x, colr + 192
    NEXT

    Music.Play
    FOR x = 0 TO 63
        Gfx.Pal.GetAttr VARSEG(FadeFrom(0)), VARPTR(FadeFrom(0)), x, r, g, b
        Gfx.Pal.SetAttr VARSEG(FadeFrom(0)), VARPTR(FadeFrom(0)), x + 192, r, g, b
        Gfx.Pal.GetAttr VARSEG(FadeTo(0)), VARPTR(FadeTo(0)), x, r, g, b
        Gfx.Pal.SetAttr VARSEG(FadeTo(0)), VARPTR(FadeTo(0)), x + 192, r, g, b
    NEXT

    Music.Play
    FOR x = 0 TO 191
        Gfx.Pal.GetAttr VARSEG(FlagPal(0)), VARPTR(FlagPal(0)), x, r, g, b
        Gfx.Pal.SetAttr VARSEG(FadeFrom(0)), VARPTR(FadeFrom(0)), x, r, g, b
        Gfx.Pal.SetAttr VARSEG(FadeTo(0)), VARPTR(FadeTo(0)), x, r, g, b
    NEXT

    ERASE buffer1, buffer2
    DIM TopBuffer(1281)
    DIM BottomBuffer(1281)
    Music.Play
    FOR x = 0 TO 1279
        TopBuffer(x + 2) = buffer3(x)
        BottomBuffer(x + 2) = buffer3(x + 1280)
    NEXT
    TopBuffer(0) = 2560
    TopBuffer(1) = 8
    BottomBuffer(0) = 2560
    BottomBuffer(1) = 8

    FOR x = 0 TO 383
        pal(x) = 0
    NEXT
    Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    PUT (0, 10), TopBuffer(0), PSET
    PUT (0, 180), BottomBuffer(0), PSET

    FOR i = 1 TO 2

        FOR fade = 0 TO 255
            Music.Play
            Gfx.Pal.sFade 255, fade, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))

            wave = (255 - fade) MOD 64
            GOSUB Flag

            IF Gfx.WaitSync > 2 THEN
                WAIT &H3DA, 8, 8
                WAIT &H3DA, 8
            END IF

            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
            PUT (52, 39), buffer(0), PSET

        NEXT

        FOR x = 0 TO 383
            FadeTo(x) = FadeFrom(x)
        NEXT

        FOR WaitRetrace = 0 TO 255
            Music.Play

            wave = (255 - WaitRetrace) MOD 64
            GOSUB Flag

            IF Gfx.WaitSync > 2 THEN
                WAIT &H3DA, 8, 8
                WAIT &H3DA, 8
            END IF

            PUT (52, 39), buffer(0), PSET

        NEXT

    NEXT

    FOR x = 0 TO 383
        FadeTo(x) = 0
    NEXT

    FOR fade = 0 TO 255
        Music.Play
        Gfx.Pal.sFade 255, fade, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))

        wave = (255 - fade) MOD 64
        GOSUB Flag

        IF Gfx.WaitSync > 2 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        PUT (52, 39), buffer(0), PSET

    NEXT

    CLS
    EXIT SUB

    Flag:
    IF Compiled THEN

        FOR x = 0 TO 199
            shift = SineShift(x + wave AND 63)
            FOR y = 0 TO 103
                SineFlag(x, y + shift) = Flag(x, y) - shift * 4
            NEXT
        NEXT

        DEF SEG = VARSEG(buffer(0))
        offset = VARPTR(buffer(0)) + 4

        FOR y = -8 TO 111
            shift = SineShift(y + wave AND 63)
            FOR x = 0 TO 8 + shift
                POKE offset + x + ((y + 8) * 214), 0
                POKE offset + 210 - x + ((y + 8) * 214), 0
            NEXT
            FOR x = 0 TO 199
                colr = SineFlag(x, y)
                POKE offset + x + 8 + shift + ((y + 8) * 214), colr
                SineFlag(x, y) = 0
            NEXT
        NEXT

    ELSE

        FOR x = 0 TO 199
            shift = SineShift(x + wave AND 63)
            FOR y = 0 TO 103
                SineFlag(x, y + shift) = Flag(x, y) - shift * 4
            NEXT
        NEXT

        DEF SEG = VARSEG(buffer(0))
        offset = VARPTR(buffer(0)) + 4

        FOR y = -8 TO 111
            shift = SineShift(y + wave AND 63)
            FOR x = 0 TO 8 + shift
                POKE offset + x + ((y + 8) * 214&), 0
                POKE offset + 210 - x + ((y + 8) * 214&), 0
            NEXT
            FOR x = 0 TO 199
                colr = SineFlag(x, y)
                POKE offset + x + 8 + shift + ((y + 8) * 214&), colr
                SineFlag(x, y) = 0
            NEXT
        NEXT

    END IF

    RETURN

END SUB

SUB Do.FloorMapper

    CLS

    DIM buffer(32001)
    DIM Texture(4095)

    DIM Floor(1 TO 100)

    DIM FloorPal(383)
    DIM pal(383)
    DIM BlackPal(383)

    FOR i = 0 TO 383
        pal(i) = &H3F3F
    NEXT
    FOR i = 0 TO 383
        BlackPal(i) = 0
    NEXT

    Music.Play
    Gfx.Pal.Load "FLOOR.PAL", VARSEG(FloorPal(0)), VARPTR(FloorPal(0))

    Pack.BLoad Pack, "FLOOR.GFX", VARSEG(Texture(0)), VARPTR(Texture(0))

    FOR i = 0 TO 99
        Floor(i + 1) = (5000 / (101 - (i - 1)))
    NEXT

    Music.Play
    GET (0, 0)-(319, 199), buffer(0)

    DEF SEG = VARSEG(buffer(2))

    IF Compiled THEN

        FOR move = 0 TO 400

            IF move < 128 THEN
                Gfx.Pal.sFade 127, move, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FloorPal(0)), VARPTR(FloorPal(0))
                Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
                DEF SEG = VARSEG(buffer(2))
            ELSEIF move > 400 - 129 THEN
                Gfx.Pal.sFade 127, move - (400 - 128), VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(BlackPal(0)), VARPTR(BlackPal(0))
                Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
                DEF SEG = VARSEG(buffer(2))
            END IF

            StartPtr = 160 + VARPTR(buffer(2))
            StartPtr2 = 63840 + VARPTR(buffer(2))
            Music.Play

            FOR i = -160 TO 159 STEP 2
                Music.Play
                DEF SEG = VARSEG(buffer(2))
                Dx! = Lookup.Cosine(angle) - i * Lookup.Sine160(angle)
                Dy! = i * Lookup.Cosine160(angle) + Lookup.Sine(angle)
                Ptr = StartPtr + i
                Ptr2 = StartPtr2 + i
                FOR j = 1 TO 90
                    xt = x + Floor(j) * Dx! AND 63
                    yt = 64 * (Floor(j) * Dy! + y AND 63)
                    offset = xt + yt
                    colr = Texture(offset)
                    IF j > 70 THEN
                        colr = colr - j + 70
                        IF colr < 0 THEN colr = 0
                    END IF
                    POKE Ptr, colr
                    POKE Ptr + 1, colr
                    POKE Ptr2, colr
                    POKE Ptr2 + 1, colr
                    Ptr = Ptr + 320
                    Ptr2 = Ptr2 - 320
                NEXT
            NEXT

            Music.Play
            IF Gfx.WaitSync > 2 THEN
                WAIT &H3DA, 8, 8
                WAIT &H3DA, 8
            END IF

            PUT (0, 0), buffer(0), PSET

            y = y + 2
            x = x + 2
            angle = angle + 2
            IF angle = 360 THEN angle = 0

        NEXT

    ELSE

        FOR move = 0 TO 400

            IF move < 128 THEN
                Gfx.Pal.sFade 127, move, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FloorPal(0)), VARPTR(FloorPal(0))
                Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
                DEF SEG = VARSEG(buffer(2))
            ELSEIF move > 400 - 129 THEN
                Gfx.Pal.sFade 127, move - (400 - 128), VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(BlackPal(0)), VARPTR(BlackPal(0))
                Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
                DEF SEG = VARSEG(buffer(2))
            END IF

            StartPtr& = 160 + VARPTR(buffer(2))
            StartPtr2& = 63840 + VARPTR(buffer(2))
            Music.Play

            FOR i = -160 TO 159 STEP 2
                Music.Play
                DEF SEG = VARSEG(buffer(2))
                Dx! = Lookup.Cosine(angle) - i * Lookup.Sine160(angle)
                Dy! = i * Lookup.Cosine160(angle) + Lookup.Sine(angle)
                Ptr& = StartPtr& + i
                Ptr2& = StartPtr2& + i
                FOR j = 1 TO 90
                    xt = x + Floor(j) * Dx! AND 63
                    yt = 64 * (Floor(j) * Dy! + y AND 63)
                    offset = xt + yt
                    colr = Texture(offset)
                    IF j > 70 THEN
                        colr = colr - j + 70
                        IF colr < 0 THEN colr = 0
                    END IF
                    POKE Ptr&, colr
                    POKE Ptr& + 1, colr
                    POKE Ptr2&, colr
                    POKE Ptr2& + 1, colr
                    Ptr& = Ptr& + 320
                    Ptr2& = Ptr2& - 320
                NEXT
            NEXT

            Music.Play
            IF Gfx.WaitSync > 2 THEN
                WAIT &H3DA, 8, 8
                WAIT &H3DA, 8
            END IF

            PUT (0, 0), buffer(0), PSET

            y = y + 2
            x = x + 2
            angle = angle + 2
            IF angle = 360 THEN angle = 0

        NEXT

    END IF

END SUB

SUB Do.Plasma

    DIM buffer(32001)
    DIM Plasma(32001)
    DIM PlasmaPal(383)
    DIM pal(383)
    DIM FadeTo(383)

    Gfx.Pal.Load "PLASMA.PAL", VARSEG(PlasmaPal(0)), VARPTR(PlasmaPal(0))

    DEF SEG = VARSEG(PlasmaPal(0))
    FOR colr = 0 TO 191
        r = PEEK(colr * 3)
        g = PEEK(colr * 3 + 1)
        b = PEEK(colr * 3 + 2)
        POKE colr * 3, r \ 4
        POKE colr * 3 + 1, g \ 4
        POKE colr * 3 + 2, b \ 4
    NEXT

    Plasma.Gen VARSEG(Plasma(0)), VARPTR(Plasma(0)) + 4
    Plasma(0) = 2560
    Plasma(1) = 200

    FOR i = 0 TO 383
        pal(i) = 0
    NEXT

    Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    x = 30
    x2 = 60
    y = x
    y2 = x2

    DEF SEG = VARSEG(Plasma(0))
    offset = VARPTR(Plasma(0)) + 4
    colr = 192 + 16 + 15
    colr2 = colr - 10

    FOR i = x2 TO 319 - x
        POKE offset + i + y * 320&, colr
        POKE offset + i + (y - 1) * 320&, colr2
        POKE offset + i + (y + 1) * 320&, colr2
    NEXT
    FOR i = y2 TO 199 - y
        POKE offset + x + i * 320&, colr
        POKE offset + x + 1 + i * 320&, colr2
        POKE offset + x - 1 + i * 320&, colr2
    NEXT
    FOR i = y TO 199 - y2
        POKE offset + 319 - x + i * 320&, colr
        POKE offset + 319 - x + 1 + i * 320&, colr2
        IF i > y + 1 THEN POKE offset + 319 - x - 1 + i * 320&, colr2
    NEXT
    FOR i = x TO 319 - x2
        POKE offset + i + (199 - y) * 320&, colr
        IF i > x + 1 THEN POKE offset + i + (199 - y - 1) * 320&, colr2
        POKE offset + i + (199 - y + 1) * 320&, colr2
    NEXT
    FOR i = x TO x2
        POKE offset + i + (y2 - (i - x)) * 320&, colr
        IF i > x + 1 THEN POKE offset + i + (y2 - (i - x) + 1) * 320&, colr2
        POKE offset + i + (y2 - (i - x) - 1) * 320&, colr2
    NEXT
    FOR i = 319 - x2 TO 319 - x
        POKE offset + i + (199 - y - (i - (319 - x2))) * 320&, colr
        POKE offset + i + (199 - y - (i - (319 - x2)) + 1) * 320&, colr2
        IF i < 319 - x THEN POKE offset + i + (199 - y - (i - (319 - x2)) - 1) * 320&, colr2
    NEXT

    Plasma(0) = 2560
    Plasma(1) = 200
    PUT (0, 0), Plasma(0), PSET

    FOR y = 0 TO 255
        Music.Play
        Gfx.Pal.sFade 255, y, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(PlasmaPal(0)), VARPTR(PlasmaPal(0))

        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    NEXT

    SEEK #Pack, Pack.Offset&(Pack, "GREETZ.DAT")

    GET #Pack, , lines
    DIM Greetz(1 TO lines) AS STRING * 28
    FOR x = 1 TO lines
        GET #Pack, , Greetz(x)
    NEXT

    Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    FOR move = 199 TO lines * -10 + 110 STEP -1

        Music.Play

        FOR z = 0 TO 32001
            buffer(z) = Plasma(z)
        NEXT

        FOR i = 1 TO lines
            y = i * 10 + move - 10
            IF y < 169 AND y > 30 - 10 THEN
                Font.Print Greetz(i), 60 + 16, y, 60 + 15, 31, 319 - 60 - 16, 168, 192 + 16, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer(0)), VARPTR(buffer(0)) + 4
            END IF
        NEXT

        Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), 1, c1, c2, c3
        FOR c = 1 TO 191
            Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), c + 1, r, g, b
            Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), c, r, g, b
        NEXT
        Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), 192, c1, c2, c3

        Music.Play
        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

        PUT (0, 0), buffer(0), PSET

        Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), 1, c1, c2, c3
        FOR c = 1 TO 191
            Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), c + 1, r, g, b
            Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), c, r, g, b
        NEXT
        Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), 192, c1, c2, c3

        Music.Play
        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    NEXT

    FOR WaitRetrace = 0 TO 255

        Music.Play

        Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), 1, c1, c2, c3

        FOR c = 1 TO 191
            Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), c + 1, r, g, b
            Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), c, r, g, b
        NEXT

        Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), 192, c1, c2, c3

        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    NEXT

    FOR x = 0 TO 383
        FadeTo(x) = 0
    NEXT

    FOR y = 0 TO 63
        Music.Play
        Gfx.Pal.Fade 0, 255, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))

        Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), 1, c1, c2, c3
        FOR c = 1 TO 191
            Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), c + 1, r, g, b
            Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), c, r, g, b
        NEXT
        Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), 192, c1, c2, c3
        Music.Play
        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

        Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), 1, c1, c2, c3
        FOR c = 1 TO 191
            Gfx.Pal.GetAttr VARSEG(pal(0)), VARPTR(pal(0)), c + 1, r, g, b
            Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), c, r, g, b
        NEXT
        Gfx.Pal.SetAttr VARSEG(pal(0)), VARPTR(pal(0)), 192, c1, c2, c3
        Music.Play
        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    NEXT

END SUB

SUB Do.Space

    DIM Screen.Buffer(32001)
    Screen.Buffer(0) = 2560
    Screen.Buffer(1) = 192

    DIM buffer1(1279)
    DIM buffer2(1279)
    DIM buffer3(1279)
    DIM TextBuffer1(1281)
    DIM TextBuffer2(1281)

    DIM SpacePal(383)
    DIM Text1Pal1(383)
    DIM Text1Pal2(383)
    DIM Text2Pal1(383)
    DIM Text2Pal2(383)

    Font.Print "somewhere between space and time", 43, 0, -1, -1, 320, 200, 0, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer1(0)), VARPTR(buffer1(0))
    Font.Print "there lies a dimension with no limits", 40, 0, -1, -1, 320, 200, 0, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0))
    Font.Print "where imagination becomes reality", 49, 0, -1, -1, 320, 200, 0, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer3(0)), VARPTR(buffer3(0))

    Gfx.Pal.Load "SPACE.PAL", VARSEG(SpacePal(0)), VARPTR(SpacePal(0))

    Music.Play
  Gfx.xFade.Setup 64, 2560, VARSEG(buffer1(0)), VARPTR(buffer1(0)), VARSEG(SpacePal(0)), VARPTR(SpacePal(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0)), VARSEG(SpacePal(0)), VARPTR(SpacePal(0)), VARSEG(TextBuffer1(0)), VARPTR(TextBuffer1(2)), VARSEG( _
Text1Pal1(0)), VARPTR(Text1Pal1(0)), VARSEG(Text1Pal2(0)), VARPTR(Text1Pal2(0))
  Gfx.xFade.Setup 64, 2560, VARSEG(buffer2(0)), VARPTR(buffer2(0)), VARSEG(SpacePal(0)), VARPTR(SpacePal(0)), VARSEG(buffer3(0)), VARPTR(buffer3(0)), VARSEG(SpacePal(0)), VARPTR(SpacePal(0)), VARSEG(TextBuffer2(0)), VARPTR(TextBuffer2(2)), VARSEG( _
Text2Pal1(0)), VARPTR(Text2Pal1(0)), VARSEG(Text2Pal2(0)), VARPTR(Text2Pal2(0))
    Music.Play
    TextBuffer1(0) = 2560
    TextBuffer1(1) = 8
    TextBuffer2(0) = 2560
    TextBuffer2(1) = 8

    REDIM SpacePal(383)
    DEF SEG = VARSEG(SpacePal(0))
    FOR i = 0 TO 63
        FOR j = 0 TO 2
            POKE VARPTR(Text1Pal1(0)) + (i + 64) * 3 + j, i
        NEXT
    NEXT
    DEF SEG = VARSEG(Text1Pal1(0))
    FOR i = 0 TO 63
        FOR j = 0 TO 2
            POKE VARPTR(Text1Pal1(0)) + (i + 64) * 3 + j, i
        NEXT
    NEXT
    DEF SEG = VARSEG(Text1Pal2(0))
    FOR i = 0 TO 63
        FOR j = 0 TO 2
            POKE VARPTR(Text1Pal2(0)) + (i + 64) * 3 + j, i
        NEXT
    NEXT
    DEF SEG = VARSEG(Text2Pal1(0))
    FOR i = 0 TO 63
        FOR j = 0 TO 2
            POKE VARPTR(Text2Pal1(0)) + (i + 64) * 3 + j, i
        NEXT
    NEXT
    DEF SEG = VARSEG(Text2Pal2(0))
    FOR i = 0 TO 63
        FOR j = 0 TO 2
            POKE VARPTR(Text2Pal2(0)) + (i + 64) * 3 + j, i
        NEXT
    NEXT
    Music.Play

    DIM Ball(191) AS INTEGER

    Pack.BLoad Pack, "BALL.GFX", VARSEG(Ball(0)), VARPTR(Ball(0))

    DIM pal(383)
    Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    NumStars = 300

    DIM Star(NumStars - 1, 2)
    DIM Pixels(1, NumStars - 1, 2)

    PUT (160 - 9, 100 - 8), Ball(0), PSET
    i = 0
    FOR x = 160 - 9 TO 160 + 9
        FOR y = 100 - 8 TO 100 + 8
            IF POINT(x, y) <> 0 THEN
                Pixels(1, i, 0) = x
                Pixels(1, i, 1) = y
                Pixels(1, i, 2) = POINT(x, y)
                i = i + 1
            END IF
        NEXT
    NEXT

    FOR j = i TO NumStars - 1
        Pixels(1, j, 0) = Pixels(1, i - 1, 0)
        Pixels(1, j, 1) = Pixels(1, i - 1, 1)
    NEXT

    DIM Morph(NumStars - 1, 1)

    CLS
    Distance = 0

    FOR i = 0 TO NumStars - 1

        Music.Play
        DO
            Star(i, 0) = INT(RND(1) * 500) - 250
            Star(i, 1) = INT(RND(1) * 500) - 250
            Star(i, 2) = INT(RND(1) * 500) - 250

            IF Star(i, 0) < -100 OR Star(i, 0) > 100 THEN
                EXIT DO
            ELSEIF Star(i, 1) < -100 OR Star(i, 1) > 100 THEN
                EXIT DO
            ELSEIF Star(i, 2) < -100 OR Star(i, 2) > 100 THEN
                EXIT DO
            END IF
        LOOP

    NEXT

    PUT (0, 192), TextBuffer1(0), PSET

    Spin = 0
    DO

        IF Spin < 256 THEN
            Gfx.Pal.sFade 255, Spin, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(SpacePal(0)), VARPTR(SpacePal(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        ELSEIF Spin > 255 AND Spin < 256 + 255 THEN
            Gfx.Pal.sFade 255, Spin - 256, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(Text1Pal1(0)), VARPTR(Text1Pal1(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        ELSEIF Spin > 575 AND Spin < 575 + 256 THEN
            Gfx.Pal.sFade 255, Spin - 576, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(Text1Pal2(0)), VARPTR(Text1Pal2(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        ELSEIF Spin = 831 THEN
            Gfx.Pal.Set VARSEG(Text2Pal1(0)), VARPTR(Text2Pal1(0))
            PUT (0, 192), TextBuffer2(0), PSET
            FOR i = 0 TO 383
                pal(i) = Text2Pal1(i)
            NEXT
        ELSEIF Spin > 895 AND Spin < 895 + 256 THEN
            Gfx.Pal.sFade 255, Spin - 896, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(Text2Pal2(0)), VARPTR(Text2Pal2(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        ELSEIF Spin = 1215 THEN
            FOR i = 0 TO 95
                SpacePal(i) = 0
            NEXT
        ELSEIF Spin > 1215 THEN
            Gfx.Pal.sFade 255, Spin - 1216, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(SpacePal(0)), VARPTR(SpacePal(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        END IF

        Music.Play
        IF Gfx.WaitSync > 1 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Spin = Spin + 1
        IF Spin > 1000 THEN
            Thrust = (Spin - 1000) \ 100
            Distance = Distance - Thrust
            IF Spin = 1000 + 800 THEN EXIT DO
        END IF

        AngleX = AngleX + 1
        IF AngleX = 360 THEN AngleX = 0
        AngleY = AngleY + 1
        IF AngleY = 360 THEN AngleY = 0
        AngleZ = AngleZ + 1
        IF AngleZ = 360 THEN AngleZ = 0

        DEF SEG = VARSEG(Screen.Buffer(0))

        IF Compiled THEN

            FOR i = 0 TO NumStars - 1

                TempX = Star(i, 0)
                TempY = Star(i, 1)
                TempZ = Star(i, 2)

                'rotate around the x-axis
                NewY = TempY * Lookup.Cosine(AngleX) - TempZ * Lookup.Sine(AngleX)
                NewZ = TempY * Lookup.Sine(AngleX) + TempZ * Lookup.Cosine(AngleX)
                NewX = TempX
                TempX = NewX
                TempY = NewY
                TempZ = NewZ

                'rotate around the y-axis
                NewX = TempX * Lookup.Cosine(AngleY) + TempZ * Lookup.Sine(AngleY)
                NewZ = -TempX * Lookup.Sine(AngleY) + TempZ * Lookup.Cosine(AngleY)
                TempX = NewX
                TempZ = NewZ

                'rotate around the z-axis
                NewX = TempX * Lookup.Cosine(AngleZ) - TempY * Lookup.Sine(AngleZ)
                NewY = TempX * Lookup.Sine(AngleZ) + TempY * Lookup.Cosine(AngleZ)
                TempX = NewX
                TempY = NewY

                TempZ = TempZ - Distance

                IF TempZ > 1 THEN
                    x = TempX / TempZ * 90 + 160
                    y = TempY / TempZ * 90 + 100
                    IF Spin = 1000 + 799 THEN
                        Pixels(0, i, 0) = x
                        Pixels(0, i, 1) = y
                    END IF
                    IF x >= 0 AND y >= 0 AND x <= 319 AND y <= 191 THEN
                        colr = 64 - (TempZ \ 5.5)
                        IF colr < 10 THEN colr = 10
                        colr = colr + 64
                        POKE VARPTR(Screen.Buffer(0)) + y * 320 + x + 4, colr
                    END IF
                END IF

            NEXT

        ELSE

            FOR i = 0 TO NumStars - 1

                TempX = Star(i, 0)
                TempY = Star(i, 1)
                TempZ = Star(i, 2)

                'rotate around the x-axis
                NewY = TempY * Lookup.Cosine(AngleX) - TempZ * Lookup.Sine(AngleX)
                NewZ = TempY * Lookup.Sine(AngleX) + TempZ * Lookup.Cosine(AngleX)
                NewX = TempX
                TempX = NewX
                TempY = NewY
                TempZ = NewZ

                'rotate around the y-axis
                NewX = TempX * Lookup.Cosine(AngleY) + TempZ * Lookup.Sine(AngleY)
                NewZ = -TempX * Lookup.Sine(AngleY) + TempZ * Lookup.Cosine(AngleY)
                TempX = NewX
                TempZ = NewZ

                'rotate around the z-axis
                NewX = TempX * Lookup.Cosine(AngleZ) - TempY * Lookup.Sine(AngleZ)
                NewY = TempX * Lookup.Sine(AngleZ) + TempY * Lookup.Cosine(AngleZ)
                TempX = NewX
                TempY = NewY

                TempZ = TempZ - Distance

                IF TempZ > 1 THEN
                    x = TempX / TempZ * 90 + 160
                    y = TempY / TempZ * 90 + 100
                    IF Spin = 1000 + 799 THEN
                        Pixels(0, i, 0) = x
                        Pixels(0, i, 1) = y
                    END IF
                    IF x >= 0 AND y >= 0 AND x <= 319 AND y <= 191 THEN
                        colr = 64 - (TempZ \ 5.5)
                        IF colr < 10 THEN colr = 10
                        colr = colr + 64
                        POKE VARPTR(Screen.Buffer(0)) + y * 320& + x + 4, colr
                    END IF
                END IF

            NEXT

        END IF

        Music.Play
        IF Gfx.WaitSync > 1 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        PUT (0, 0), Screen.Buffer(0), PSET

        REDIM Screen.Buffer(32001)
        Screen.Buffer(0) = 2560
        Screen.Buffer(1) = 192

    LOOP

    LINE (0, 191)-(319, 199), 0, BF

    FOR i = 0 TO NumStars - 1
        startX = Pixels(0, i, 0)
        startY = Pixels(0, i, 1)
        endX = Pixels(1, i, 0)
        endY = Pixels(1, i, 1)
        Morph(i, 0) = endX - startX
        Morph(i, 1) = endY - startY
    NEXT

    FOR i = 3 TO 383
        SpacePal(i) = 10 + 256 * 10
    NEXT
    Gfx.Pal.Set VARSEG(SpacePal(0)), VARPTR(SpacePal(0))

    Screen.Buffer(0) = 2560
    Screen.Buffer(1) = 192

    FOR j = 0 TO 128
        FOR i = 0 TO NumStars - 1
            Pixels(1, i, 0) = Pixels(0, i, 0) + (Morph(i, 0) / 128) * j
            Pixels(1, i, 1) = Pixels(0, i, 1) + (Morph(i, 1) / 128) * j
        NEXT
        DEF SEG = VARSEG(Screen.Buffer(0))

        IF Compiled THEN

            FOR i = 0 TO NumStars - 1
                colr = Pixels(1, i, 2)
                POKE VARPTR(Screen.Buffer(2)) + Pixels(1, i, 0) + Pixels(1, i, 1) * 320, colr
            NEXT

        ELSE

            FOR i = 0 TO NumStars - 1
                colr = Pixels(1, i, 2)
                POKE VARPTR(Screen.Buffer(2)) + Pixels(1, i, 0) + Pixels(1, i, 1) * 320&, colr
            NEXT

        END IF

        Music.Play
        IF Gfx.WaitSync > 1 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        PUT (0, 0), Screen.Buffer(0), PSET
        REDIM Screen.Buffer(32001)

        Screen.Buffer(0) = 2560
        Screen.Buffer(1) = 192

    NEXT

END SUB

SUB Do.Startup

    $RESIZE:SMOOTH
    _TITLE "Digital Reality"
    _ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH

    DIM Choose(2)

    ComLine$ = LCASE$(LTRIM$(RTRIM$(COMMAND$)))

    FOR x = 1 TO LEN(ComLine$)
        IF MID$(ComLine$, x, 1) = "/" OR MID$(ComLine$, x, 1) = "\" THEN
            MID$(ComLine$, x, 1) = "-"
        END IF
    NEXT

    IF INSTR(ComLine$, "?") OR INSTR(ComLine$, "-h") THEN
        CLS
        PRINT "digireal.exe [sound] [vsync] [other]                             ";
        COLOR 15
        PRINT "digital reality"
        COLOR 7
        PRINT "                                                            by Plasma/Nemesis QB"
        PRINT "                                                         (updated final release)"
        PRINT "options for [sound]    (### indicates base port in hex)"
        PRINT
        PRINT "-nosound               For benchmarking purposes or no sound card"
        PRINT "-adlib                 For legacy ISA sound cards that are Adlib-compatible"
        PRINT "-sb or -sb:###         For legacy ISA sound cards with an OPL2/3 FM chip"
        PRINT "-mpu401 or mpu401:###  For PCI Sound Blaster cards without an FM chip"
        PRINT
        PRINT "options for [vsync]"
        PRINT
        PRINT "-vsync0  Never wait              For benchmarking purposes only"
        PRINT "-vsync1  Wait during fades only  For 66 - 200 MHz CPUs"
        PRINT "-vsync2  Wait when necessary     For 200 - 400 MHz CPUs"
        PRINT "-vsync3  Always wait             For 400+ MHz CPUs "
        PRINT
        PRINT "options for [other]  (may be combined)"
        PRINT
        PRINT "-oldskool   Try it and see..."
        PRINT "-noconfig   Skips UI config screen"
        END
    END IF

    com.nosound = INSTR(ComLine$, "-nosound")
    com.adlib = INSTR(ComLine$, "-adlib")
    com.sb = INSTR(ComLine$, "-sb")
    com.mpu401 = INSTR(ComLine$, "-mpu401")

    IF com.nosound THEN
        Choose(0) = 0
    ELSEIF com.mpu401 THEN
        Choose(0) = 3
    ELSEIF com.sb THEN
        Choose(0) = 2
    ELSE
        Choose(0) = 1
    END IF

    bw1 = INSTR(ComLine$, "-oldsk00l")
    bw2 = INSTR(ComLine$, "-oldskool")
    bw3 = INSTR(ComLine$, "-oldsch00l")
    bw4 = INSTR(ComLine$, "-oldschool")
    IF bw1 OR bw2 OR bw3 OR bw4 THEN
        Choose(2) = 1
    ELSE
        Choose(2) = 0
    END IF

    IF INSTR(ComLine$, "-benchmark") THEN Benchmark = TRUE

    VSync = INSTR(ComLine$, "-vsync")
    IF VSync AND LEN(ComLine$) >= VSync + 6 THEN
        Sync$ = MID$(ComLine$, VSync + 6, 1)
        IF Sync$ = " " THEN Sync$ = "2"
        Choose(1) = VAL(Sync$)
        IF Choose(1) < 0 OR Choose(1) > 3 THEN
            DetectVSync = TRUE
        END IF
    ELSE
        DetectVSync = TRUE
    END IF

    IF DetectVSync = TRUE THEN
        StartTime! = TIMER
        FOR x = 1 TO 32000
            y& = x ^ 2 \ SQR(x)
        NEXT
        EndTime! = TIMER
        TotalTime! = EndTime! - StartTime!
        IF TotalTime! <= .5 THEN
            Choose(1) = 3
        ELSEIF TotalTime! <= 1 THEN
            Choose(1) = 2
        ELSEIF TotalTime! <= 2 THEN
            Choose(1) = 1
        ELSE
            Choose(1) = 0
        END IF
    END IF

    IF INSTR(ComLine$, "-noconfig") = 0 THEN

        DIM buffer1(1999)
        DIM buffer2(1999)

        FOR x = 0 TO 3999
            DEF SEG = &HB800
            Byte = PEEK(x)
            DEF SEG = VARSEG(buffer1(0))
            POKE VARPTR(buffer1(0)) + x, Byte
        NEXT

        SEEK #Pack, Pack.Offset&(Pack, "CONFIG.SCR")

        Byte$ = " "
        FOR x = 0 TO 3999
            GET #Pack, , Byte$
            DEF SEG = VARSEG(buffer2(0))
            POKE VARPTR(buffer2(0)) + x, ASC(Byte$)
            DEF SEG = &HB800
            POKE x + 8192, ASC(Byte$)
        NEXT

        SCREEN 0, , 0, 0
        CLS
        LOCATE 1, 1, 0

        Gfx.Text.Scroll VARSEG(buffer1(0)), VARPTR(buffer1(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0))

        PCOPY 2, 0

        Cat = 3
        DO

            IF Cat = 0 THEN COLOR 0, 2 ELSE COLOR 10, 0
            LOCATE 5, 6
            PRINT " Music Device "
            LOCATE , 4
            IF Choose(0) = 0 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "None"
            LOCATE , 4
            IF Choose(0) = 1 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "Adlib"
            LOCATE , 4
            IF Choose(0) = 2 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "Sound Blaster"
            LOCATE , 4
            IF Choose(0) = 3 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "MPU-401 (MIDI)"

            IF Cat = 1 THEN COLOR 0, 2 ELSE COLOR 10, 0
            LOCATE 12, 6
            PRINT " Wait for Vertical Retrace "
            LOCATE , 4
            IF Choose(1) = 0 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "Never"
            LOCATE , 4
            IF Choose(1) = 1 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "During Fades Only"
            LOCATE , 4
            IF Choose(1) = 2 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "When Necessary"
            LOCATE , 4
            IF Choose(1) = 3 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "Always"

            IF Cat = 2 THEN COLOR 0, 2 ELSE COLOR 10, 0
            LOCATE 18, 6
            PRINT " Enable OldSk00L Graphics "
            LOCATE , 4
            IF Choose(2) = 0 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "No"
            LOCATE , 4
            IF Choose(2) = 1 THEN COLOR 15, 0 ELSE COLOR 2, 0
            PRINT "Yes"

            IF Cat = 3 THEN COLOR 0, 2 ELSE COLOR 10, 0
            LOCATE 23, 31
            PRINT " Enter the Reality ";

            DO
                KeyPress$ = INKEY$
            LOOP WHILE KeyPress$ = ""

            SELECT CASE KeyPress$
                CASE CHR$(0) + "H"
                    Cat = Cat - 1
                    IF Cat = -1 THEN Cat = 3
                CASE CHR$(0) + "P"
                    Cat = Cat + 1
                    IF Cat = 4 THEN Cat = 0
                CASE CHR$(13), " "
                    IF Cat = 0 OR Cat = 1 THEN
                        Choose(Cat) = Choose(Cat) + 1
                        IF Choose(Cat) = 4 THEN Choose(Cat) = 0
                    ELSEIF Cat = 2 THEN
                        Choose(Cat) = Choose(Cat) + 1
                        IF Choose(Cat) = 2 THEN Choose(Cat) = 0
                    ELSEIF Cat = 3 THEN
                        EXIT DO
                    END IF
                CASE CHR$(27)
                    COLOR 7, 0
                    CLS
                    END
            END SELECT

        LOOP

        REDIM buffer1(1999)
        Gfx.Text.Scroll VARSEG(buffer2(0)), VARPTR(buffer2(0)), VARSEG(buffer1(0)), VARPTR(buffer1(0))

    ELSE

        CLS

    END IF

    SELECT CASE Choose(0)
        CASE 0
            Music.Mode = NONE
            Music.Port = 0
        CASE 1
            Music.Mode = ADLIB
            Music.Port = &H388
        CASE 2
            Music.Mode = ADLIB
            IF LEN(ComLine$) >= com.sb + 6 AND MID$(ComLine$, com.sb + 3, 1) = ":" THEN
                Music.Port = VAL("&H" + MID$(ComLine$, com.sb + 4, 3)) + 8
            END IF
            IF Music.Port = 0 OR Music.Port = 18 THEN
                FoundBaseAddr = 0
                FOR BaseAddr = &H200 TO &H2F0 STEP &H10
                    OUT BaseAddr + &H6, 1
                    OUT BaseAddr + &H6, 0
                    FOR ResetDSP& = 1 TO 65535
                        IF INP(BaseAddr + &HA) = &HAA THEN
                            FoundBaseAddr = 1
                            EXIT FOR
                        ELSEIF ResetDSP& = 65535 THEN
                            FoundBaseAddr = 0
                            EXIT FOR
                        END IF
                    NEXT
                    IF FoundBaseAddr = 1 THEN
                        BasePort = BaseAddr
                        EXIT FOR
                    END IF
                NEXT
                IF FoundBaseAddr = 0 THEN BasePort = &H220
                Music.Port = BasePort + 8
            END IF
        CASE 3
            Music.Mode = MPU401
            IF LEN(ComLine$) >= com.mpu401 + 10 AND MID$(ComLine$, com.mpu401 + 7, 1) = ":" THEN
                Music.Port = VAL("&H" + MID$(ComLine$, com.mpu401 + 8, 3))
            END IF
            IF Music.Port = 0 OR Music.Port = 10 THEN
                Music.Port = &H330
            END IF
    END SELECT

    Gfx.WaitSync = Choose(1)
    Gfx.OldSkool = Choose(2)

END SUB

SUB Do.Title

    DIM Screen.Buffer(32001)
    DIM BinNum(43)
    DIM BinArray(0 TO 24, 1 TO 64)
    DIM startX(0 TO 19)
    DIM pal(383)
    DIM TitlePal(383)
    DIM FadeFrom(383)
    DIM FadeTo(383)

    DIM buffer1(31999)
    DIM buffer2(31999)

    FOR x = 0 TO 19
        startX(x) = 0 - INT(RND(1) * 8)
        FOR y = 1 TO 64
            BinArray(x, y) = INT(RND(1) * 2)
        NEXT
    NEXT

    CLS

    Font.Print "a Nemesis QB production", 74, 95, -1, -1, 320, 200, 0, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer1(0)), VARPTR(buffer1(0))
    Font.Print "graphics, music, and coding by Plasma", 40, 95, -1, -1, 320, 200, 0, 0, 1, VARSEG(Font.Buffer(0)), VARPTR(Font.Buffer(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0))

    Gfx.Pal.Load "TITLE.PAL", VARSEG(TitlePal(0)), VARPTR(TitlePal(0))
  Gfx.xFade.Setup 256, 64000, VARSEG(buffer1(0)), VARPTR(buffer1(0)), VARSEG(TitlePal(0)), VARPTR(TitlePal(0)), VARSEG(buffer2(0)), VARPTR(buffer2(0)), VARSEG(TitlePal(0)), VARPTR(TitlePal(0)), VARSEG(Screen.Buffer(0)), VARPTR(Screen.Buffer(0)) + 4 _
, VARSEG(FadeTo(0)), VARPTR(FadeTo(0)), VARSEG(FadeFrom(0)), VARPTR(FadeFrom(0))

    FOR x = 0 TO 383
        pal(x) = 0
    NEXT
    Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))

    Screen.Buffer(0) = 2560
    Screen.Buffer(1) = 200
    PUT (0, 0), Screen.Buffer(0), PSET

    Music.StartPlay 0, 0
    Music.Playing = TRUE

    FOR i = 1 TO 2

        FOR y = 0 TO 255
            Music.Play
            Gfx.Pal.sFade 255, y, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))

            IF Gfx.WaitSync > 0 THEN
                WAIT &H3DA, 8, 8
                WAIT &H3DA, 8
            END IF

            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        NEXT

        FOR x = 0 TO 383
            FadeTo(x) = FadeFrom(x)
        NEXT

        FOR WaitRetrace = 0 TO 255
            Music.Play
            IF Gfx.WaitSync > 1 THEN
                WAIT &H3DA, 8, 8
                WAIT &H3DA, 8
            END IF
        NEXT

    NEXT

    FOR x = 0 TO 383
        FadeTo(x) = 0
    NEXT

    FOR y = 0 TO 255
        Music.Play
        Gfx.Pal.sFade 255, y, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))

        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    NEXT

    CLS

    Pack.BLoad Pack, "BINARY.GFX", VARSEG(BinNum(0)), VARPTR(BinNum(0))
    Pack.BLoad Pack, "TITLE.GFX", VARSEG(Screen.Buffer(0)), VARPTR(Screen.Buffer(0))

    fadein = 0
    DO

        FOR y = 0 TO 19
            Music.Play
            LineX = startX(y) MOD -5 - 5
            FOR x = (startX(y) \ -5 + 1) TO 64
                Gfx.Put.Mask LineX, y * 8 + 24, VARSEG(BinNum(BinArray(y, x) * 22)), VARPTR(BinNum(BinArray(y, x) * 22)), VARSEG(Screen.Buffer(0)), 4, 0
                LineX = LineX + 5
            NEXT
            FOR x = 1 TO (startX(y) \ -5 + 1)
                Gfx.Put.Mask LineX, y * 8 + 24, VARSEG(BinNum(BinArray(y, x) * 22)), VARPTR(BinNum(BinArray(y, x) * 22)), VARSEG(Screen.Buffer(0)), 4, 0
                LineX = LineX + 5
            NEXT
            startX(y) = startX(y) - 1
            IF startX(y) <= -320 THEN startX(y) = 0
        NEXT

        IF Gfx.WaitSync > 1 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        IF fadein < 127 THEN
            Gfx.Pal.sFade 127, fadein, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(TitlePal(0)), VARPTR(TitlePal(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        ELSEIF fadein = 191 THEN
            FOR x = 0 TO 383
                FadeTo(x) = &H3F3F
            NEXT
        ELSEIF fadein > 191 AND fadein < 319 THEN
            Gfx.Pal.sFade 127, fadein - 192, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))
            Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
        END IF
        fadein = fadein + 1

        PUT (0, 0), Screen.Buffer(0), PSET

    LOOP UNTIL fadein = 320

    Pack.BLoad Pack, "TITLE.GFX", VARSEG(Screen.Buffer(0)), VARPTR(Screen.Buffer(0))
    PUT (0, 0), Screen.Buffer(0), PSET

    FOR y = 0 TO 255
        Music.Play
        Gfx.Pal.sFade 255, y, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(TitlePal(0)), VARPTR(TitlePal(0))

        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    NEXT

    FOR x = 0 TO 383
        FadeTo(x) = 0
    NEXT

    FOR WaitRetrace = 0 TO 255
        Music.Play
        IF Gfx.WaitSync > 1 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF
    NEXT

    FOR y = 0 TO 255
        Music.Play
        Gfx.Pal.sFade 255, y, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(FadeTo(0)), VARPTR(FadeTo(0))

        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    NEXT

    CLS

END SUB

SUB Do.VectorBalls

    SEEK #Pack, Pack.Offset&(Pack, "VECTORS.DAT")

    GET #Pack, , NumShapes
    GET #Pack, , NumBalls

    DIM Vector(NumShapes, NumBalls - 1, 2)
    DIM Temp(NumBalls - 1, 2)
    Distance = 256

    DIM Morph(NumShapes, NumBalls - 1, 2)

    FOR i = 1 TO NumShapes
        FOR j = 0 TO NumBalls - 1
            GET #Pack, , x
            GET #Pack, , y
            GET #Pack, , z
            Vector(i, j, 0) = x
            Vector(i, j, 1) = y
            Vector(i, j, 2) = z
        NEXT
    NEXT

    DIM Screen.Buffer(32001)
    Screen.Buffer(0) = 2560
    Screen.Buffer(1) = 200

    FOR i = 1 TO NumShapes - 1
        FOR j = 0 TO NumBalls - 1
            startX = Vector(i, j, 0)
            startY = Vector(i, j, 1)
            startZ = Vector(i, j, 2)
            endX = Vector(i + 1, j, 0)
            endY = Vector(i + 1, j, 1)
            endZ = Vector(i + 1, j, 2)
            Morph(i, j, 0) = endX - startX
            Morph(i, j, 1) = endY - startY
            Morph(i, j, 2) = endZ - startZ
        NEXT
    NEXT

    Music.Play

    FOR i = 0 TO NumBalls - 1
        Vector(0, i, 0) = Vector(1, i, 0)
        Vector(0, i, 1) = Vector(1, i, 1)
        Vector(0, i, 2) = Vector(1, i, 2)
    NEXT

    DIM Ball(191) AS INTEGER
    DIM BallPal(2, 383) AS INTEGER

    Gfx.Pal.Load "BALL.PAL", VARSEG(BallPal(0, 0)), VARPTR(BallPal(0, 0))

    DIM pal(383)

    FOR i = 3 TO 383
        pal(i) = 10 + 256 * 10
    NEXT

    FOR i = 0 TO 255
        Gfx.Pal.sFade 255, i, VARSEG(pal(0)), VARPTR(pal(0)), VARSEG(BallPal(0, 0)), VARPTR(BallPal(0, 0))
        Music.Play
        IF Gfx.WaitSync > 0 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF
        Gfx.Pal.Set VARSEG(pal(0)), VARPTR(pal(0))
    NEXT

    Pack.BLoad Pack, "BALL.GFX", VARSEG(Ball(0)), VARPTR(Ball(0))

    DEF SEG = VARSEG(Screen.Buffer(0))

    steps = 0
    shape = 1
    DO

        IF steps < 128 THEN
            FOR i = 0 TO NumBalls - 1
                Vector(0, i, 0) = Vector(shape, i, 0) + (Morph(shape, i, 0) / 128) * steps
                Vector(0, i, 1) = Vector(shape, i, 1) + (Morph(shape, i, 1) / 128) * steps
                Vector(0, i, 2) = Vector(shape, i, 2) + (Morph(shape, i, 2) / 128) * steps
            NEXT
            steps = steps + 1
        ELSEIF steps < 512 THEN
            steps = steps + 1
        ELSEIF steps = 512 AND shape < NumShapes - 1 THEN
            steps = 0
            shape = shape + 1
        END IF

        IF shape = NumShapes - 1 AND steps > 128 AND AngleX >= 0 AND AngleX <= 5 AND AngleY >= 0 AND AngleY <= 0 AND AngleZ >= 0 AND AngleZ <= 5 THEN
            AngleX = 0
            AngleY = 0
            AngleZ = 0
            Distance = Distance - 1
            IF Distance = 0 THEN EXIT DO
        ELSE
            AngleX = AngleX + 1
            IF AngleX >= 360 THEN AngleX = 0
            AngleY = AngleY + 1
            IF AngleY >= 360 THEN AngleY = 0
            AngleZ = AngleZ - 1
            IF AngleZ < 0 THEN AngleZ = 359
        END IF

        Music.Play

        FOR i = 0 TO NumBalls - 1

            TempX = Vector(0, i, 0)
            TempY = Vector(0, i, 1)
            TempZ = Vector(0, i, 2)

            'rotate around the x-axis
            NewY = TempY * Lookup.Cosine(AngleX) - TempZ * Lookup.Sine(AngleX)
            NewZ = TempY * Lookup.Sine(AngleX) + TempZ * Lookup.Cosine(AngleX)
            NewX = TempX
            TempX = NewX
            TempY = NewY
            TempZ = NewZ

            'rotate around the y-axis
            NewX = TempX * Lookup.Cosine(AngleY) + TempZ * Lookup.Sine(AngleY)
            NewZ = -TempX * Lookup.Sine(AngleY) + TempZ * Lookup.Cosine(AngleY)
            TempX = NewX
            TempZ = NewZ

            'rotate around the z-axis
            NewX = TempX * Lookup.Cosine(AngleZ) - TempY * Lookup.Sine(AngleZ)
            NewY = TempX * Lookup.Sine(AngleZ) + TempY * Lookup.Cosine(AngleZ)
            TempX = NewX
            TempY = NewY

            'push the z coordinates into the view area
            TempZ = TempZ - Distance

            Temp(i, 0) = TempX * 256 \ TempZ + 160
            Temp(i, 1) = TempY * 256 \ TempZ + 100
            Temp(i, 2) = TempZ

        NEXT

        FOR j = 0 TO NumBalls - 2
            FOR k = j + 1 TO NumBalls - 1
                a = Temp(j, 2)
                b = Temp(k, 2)
                IF a >= b THEN
                    SWAP Temp(j, 0), Temp(k, 0)
                    SWAP Temp(j, 1), Temp(k, 1)
                    SWAP Temp(j, 2), Temp(k, 2)
                END IF
            NEXT
        NEXT

        FOR i = 0 TO NumBalls - 1
            Gfx.Put Temp(i, 0) - 10, Temp(i, 1) - 8, VARSEG(Ball(0)), VARPTR(Ball(0)), VARSEG(Screen.Buffer(0)), 4
        NEXT

        Music.Play
        IF Gfx.WaitSync > 1 THEN
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
        END IF

        PUT (0, 0), Screen.Buffer(0), PSET
        REDIM Screen.Buffer(32001)
        Screen.Buffer(0) = 2560
        Screen.Buffer(1) = 200

    LOOP


END SUB

SUB Font.Load (Filename$, font.seg, font.off)

    SEEK #Pack, Pack.Offset&(Pack, Filename$)

    ID$ = SPACE$(3)
    GET #Pack, , ID$
    IF ID$ <> "BMF" THEN EXIT SUB

    Ver$ = SPACE$(2)
    GET #Pack, , Ver$
    IF Ver$ <> CHR$(1) + CHR$(0) THEN EXIT SUB

    SizeX$ = SPACE$(1)
    GET #Pack, , SizeX$

    SizeY$ = SPACE$(1)
    GET #Pack, , SizeY$

    StartChar$ = SPACE$(1)
    GET #Pack, , StartChar$

    EndChar$ = SPACE$(1)
    GET #Pack, , EndChar$

    DEF SEG = font.seg
    POKE font.off, ASC(SizeX$)
    POKE font.off + 1, ASC(SizeY$)
    POKE font.off + 2, ASC(StartChar$)
    POKE font.off + 3, ASC(EndChar$)

    Pixel$ = SPACE$(1)
    offset = font.off + 4
    FOR Char = ASC(StartChar$) TO ASC(EndChar$)
        FOR x = 0 TO ASC(SizeX$)
            FOR y = 0 TO ASC(SizeY$)
                GET #Pack, , Pixel$
                POKE offset, ASC(Pixel$)
                offset = offset + 1
            NEXT
        NEXT
    NEXT

END SUB

SUB Font.Print (Text$, x.pos, y.pos, x1.clip, y1.clip, x2.clip, y2.clip, color.off, color.inv, spacing, font.seg, font.off, dest.seg, dest.off)

    DEF SEG = font.seg
    SizeX = PEEK(font.off)
    SizeY = PEEK(font.off + 1)
    StartChar = PEEK(font.off + 2)
    EndChar = PEEK(font.off + 3)
    CharSize = SizeX * SizeY
    SizeX = SizeX - 1
    SizeY = SizeY - 1

    IF Compiled THEN

        FOR Char = 1 TO LEN(Text$)
            CharNum = ASC(MID$(Text$, Char, 1))
            IF CharNum >= StartChar AND CharNum <= EndChar THEN
                offset = font.off + (CharNum - StartChar) * CharSize + 4
                FOR x = 0 TO SizeX
                    XLoc = x.pos + x + Char * SizeX - SizeX
                    PixelHere = 0
                    FOR y = 0 TO SizeY
                        YLoc = y.pos + y
                        DEF SEG = font.seg
                        Pixel = PEEK(offset)
                        IF Pixel <> color.inv THEN
                            PixelHere = 1
                            IF YLoc > y1.clip AND YLoc < y2.clip AND XLoc > x1.clip AND XLoc < x2.clip THEN
                                DEF SEG = dest.seg
                                POKE dest.off + YLoc * 320 + XLoc, Pixel + color.off
                            END IF
                        END IF
                        offset = offset + 1
                    NEXT
                    IF PixelHere = 0 AND CharNum <> 32 THEN
                        x.pos = x.pos + x - SizeX + spacing
                        GOTO NextCharCompiled
                    END IF
                NEXT
            END IF
            NextCharCompiled:
        NEXT

    ELSE

        FOR Char = 1 TO LEN(Text$)
            CharNum = ASC(MID$(Text$, Char, 1))
            IF CharNum >= StartChar AND CharNum <= EndChar THEN
                offset = font.off + (CharNum - StartChar) * CharSize + 4
                FOR x = 0 TO SizeX
                    XLoc = x.pos + x + Char * SizeX - SizeX
                    PixelHere = 0
                    FOR y = 0 TO SizeY
                        YLoc = y.pos + y
                        DEF SEG = font.seg
                        Pixel = PEEK(offset)
                        IF Pixel <> color.inv THEN
                            PixelHere = 1
                            IF YLoc > y1.clip AND YLoc < y2.clip AND XLoc > x1.clip AND XLoc < x2.clip THEN
                                DEF SEG = dest.seg
                                POKE dest.off + YLoc * 320& + XLoc, Pixel + color.off
                            END IF
                        END IF
                        offset = offset + 1
                    NEXT
                    IF PixelHere = 0 AND CharNum <> 32 THEN
                        x.pos = x.pos + x - SizeX + spacing
                        GOTO NextChar
                    END IF
                NEXT
            END IF
            NextChar:
        NEXT

    END IF

END SUB

FUNCTION Font.Size (Filename$)

    SEEK #Pack, Pack.Offset&(Pack, Filename$)

    ID$ = SPACE$(3)
    GET #Pack, , ID$
    IF ID$ <> "BMF" THEN EXIT FUNCTION

    Ver$ = SPACE$(2)
    GET #Pack, , Ver$
    IF Ver$ <> CHR$(1) + CHR$(0) THEN EXIT FUNCTION

    SizeX$ = SPACE$(1)
    GET #Pack, , SizeX$
    SizeX = ASC(SizeX$)

    SizeY$ = SPACE$(1)
    GET #Pack, , SizeY$
    SizeY = ASC(SizeY$)

    StartChar$ = SPACE$(1)
    GET #Pack, , StartChar$
    StartChar = ASC(StartChar$) + 1

    EndChar$ = SPACE$(1)
    GET #Pack, , EndChar$
    EndChar = ASC(EndChar$) + 1

    Font.Size = (SizeX * SizeY) * (EndChar - StartChar + 1) + 3

END FUNCTION

SUB Gfx.Pal.Fade (colr.start, colr.end, pal.seg, pal.off, topal.seg, topal.off)

    FOR x = colr.start * 3 TO colr.end * 3

        DEF SEG = topal.seg
        target = PEEK(topal.off + x)
        DEF SEG = pal.seg
        current = PEEK(pal.off + x)
        IF current < target THEN
            IF current < 32 THEN
                current = current + 2
            ELSE
                current = current + 1
            END IF
        ELSEIF current > target THEN
            IF current > 32 THEN
                current = current - 2
            ELSE
                current = current - 1
            END IF
        END IF
        POKE pal.off + x, current
    NEXT

END SUB

SUB Gfx.Pal.GetAttr (pal.seg, pal.off, Reg, r, g, b)

    DEF SEG = pal.seg
    r = PEEK(pal.off + Reg * 3)
    g = PEEK(pal.off + Reg * 3 + 1)
    b = PEEK(pal.off + Reg * 3 + 2)

END SUB

SUB Gfx.Pal.Load (Filename$, pal.seg, pal.off)

    SEEK #Pack, Pack.Offset&(Pack, Filename$)
    Byte$ = " "

    DEF SEG = pal.seg
    FOR x = 0 TO 767
        GET #Pack, , Byte$
        POKE pal.off + x, ASC(Byte$)
    NEXT

END SUB

SUB Gfx.Pal.Set (pal.seg, pal.off)

    DEF SEG = pal.seg
    OUT &H3C8, 0

    FOR x = 0 TO 255
        red = PEEK(pal.off + x * 3)
        green = PEEK(pal.off + x * 3 + 1)
        blue = PEEK(pal.off + x * 3 + 2)
        IF Gfx.OldSkool THEN
            gray = (red * 30 + green * 59 + blue * 11) \ 100
            OUT &H3C9, gray
            OUT &H3C9, gray
            OUT &H3C9, gray
        ELSE
            OUT &H3C9, red
            OUT &H3C9, green
            OUT &H3C9, blue
        END IF
    NEXT

END SUB

SUB Gfx.Pal.SetAttr (pal.seg, pal.off, Reg, r, g, b)

    DEF SEG = pal.seg
    POKE pal.off + Reg * 3, r
    POKE pal.off + Reg * 3 + 1, g
    POKE pal.off + Reg * 3 + 2, b

END SUB

SUB Gfx.Pal.sFade (steps, frame, pal.seg, pal.off, topal.seg, topal.off)

    FOR x = 0 TO 767
        DEF SEG = topal.seg
        target = PEEK(topal.off + x)
        DEF SEG = pal.seg
        current = PEEK(pal.off + x)
        IF frame = 0 THEN
            Pal.FadeBuffer(x) = current
            original = current
        ELSE
            original = Pal.FadeBuffer(x)
        END IF

        IF current < target THEN
            current = original + ((target - original) / steps) * frame
        ELSEIF current > target THEN
            current = target + ((original - target) / steps) * (steps - frame)
        END IF

        POKE pal.off + x, current

    NEXT

END SUB

SUB Gfx.Put (x.pos, y.pos, src.seg, src.off, dest.seg, dest.off)

    DEF SEG = src.seg
    xsize = (PEEK(src.off) + PEEK(src.off + 1) * 256) / 8
    ysize = PEEK(src.off + 2)

    IF Compiled THEN

        FOR y = 0 TO ysize - 1
            FOR x = 0 TO xsize - 1
                DEF SEG = src.seg
                Byte = PEEK(src.off + 4 + y * xsize + x)
                IF Byte <> 0 THEN
                    IF y.pos + y > 0 AND y.pos + y < 200 AND x.pos + x > 0 AND x.pos + x < 320 THEN
                        DEF SEG = dest.seg
                        POKE dest.off + (y.pos + y) * 320 + x.pos + x, Byte
                    END IF
                END IF
            NEXT
        NEXT

    ELSE

        FOR y = 0 TO ysize - 1
            FOR x = 0 TO xsize - 1
                DEF SEG = src.seg
                Byte = PEEK(src.off + 4 + y * xsize + x)
                IF Byte <> 0 THEN
                    IF y.pos + y > 0 AND y.pos + y < 200 AND x.pos + x > 0 AND x.pos + x < 320 THEN
                        DEF SEG = dest.seg
                        POKE dest.off + (y.pos + y) * 320& + x.pos + x, Byte
                    END IF
                END IF
            NEXT
        NEXT

    END IF

END SUB

SUB Gfx.Put.Mask (x.pos, y.pos, src.seg, src.off, dest.seg, dest.off, clip.color)

    DEF SEG = src.seg
    xsize = PEEK(src.off) / 8
    ysize = PEEK(src.off + 2)

    IF Compiled THEN

        FOR y = 0 TO ysize - 1
            FOR x = 0 TO xsize - 1
                DEF SEG = src.seg
                Byte = PEEK(src.off + 4 + y * xsize + x)
                DEF SEG = dest.seg
                IF y.pos + y > 0 AND y.pos + y < 320 AND x.pos + x > 0 AND x.pos + x < 320 THEN
                    IF PEEK(dest.off + (y.pos + y) * 320 + x.pos + x) <> clip.color THEN
                        POKE dest.off + (y.pos + y) * 320 + x.pos + x, Byte
                    END IF
                END IF
            NEXT
        NEXT

    ELSE

        FOR y = 0 TO ysize - 1
            FOR x = 0 TO xsize - 1
                DEF SEG = src.seg
                Byte = PEEK(src.off + 4 + y * xsize + x)
                DEF SEG = dest.seg
                IF y.pos + y > 0 AND y.pos + y < 320 AND x.pos + x > 0 AND x.pos + x < 320 THEN
                    IF PEEK(dest.off + (y.pos + y) * 320& + x.pos + x) <> clip.color THEN
                        POKE dest.off + (y.pos + y) * 320& + x.pos + x, Byte
                    END IF
                END IF
            NEXT
        NEXT

    END IF

END SUB

SUB Gfx.Text.Scroll (buffer1.seg, buffer1.off, buffer2.seg, buffer2.off)

    FOR x = 0 TO 3999
        DEF SEG = buffer1.seg
        Byte = PEEK(buffer1.off + x)
        DEF SEG = &HB800
        POKE x, Byte
    NEXT

    FOR scroll = 0 TO 24

        FOR x = 0 TO 159
            DEF SEG = buffer2.seg
            Byte = PEEK(buffer2.off + x + (scroll * 160))
            DEF SEG = &HB800
            POKE x + 4000, Byte
        NEXT

        FOR shift = 1 TO 15
            WAIT &H3DA, 8, 8
            WAIT &H3DA, 8
            OUT &H3D4, 8
            OUT &H3D5, shift
        NEXT

        WAIT &H3DA, 8, 8
        WAIT &H3DA, 8
        OUT &H3D4, 8
        OUT &H3D5, 0

        offset1 = (scroll + 1) * 160
        offset2 = 0

        FOR x = 0 TO 3999
            IF offset1 < 4000 THEN
                DEF SEG = buffer1.seg
                Byte = PEEK(buffer1.off + offset1)
                DEF SEG = &HB800
                POKE x, Byte
                offset1 = offset1 + 1
            ELSE
                DEF SEG = buffer2.seg
                Byte = PEEK(buffer2.off + offset2)
                DEF SEG = &HB800
                POKE x, Byte
                offset2 = offset2 + 1
            END IF
        NEXT

    NEXT

END SUB

SUB Gfx.xFade.Setup (max.colors, bufferlen&, p1.image.seg, p1.image.off, p1.pal.seg, p1.pal.off, p2.image.seg, p2.image.off, p2.pal.seg, p2.pal.off, final.image.seg, final.image.off, final.pal1.seg, final.pal1.off, final.pal2.seg, final.pal2.off)

    DIM ColorList(1 TO 2, 0 TO 255)

    FOR x = 1 TO 2
        FOR y = 0 TO 255
            ColorList(x, y) = -1
        NEXT
    NEXT

    NextFreeColor = 1
    FOR offset& = 0 TO bufferlen& - 1

        DEF SEG = p1.image.seg
        p1pixel = PEEK(p1.image.off + offset&)
        DEF SEG = p2.image.seg
        p2pixel = PEEK(p2.image.off + offset&)

        PixelUsed = 0
        FOR colr = 0 TO NextFreeColor
            IF colr = max.colors THEN
                'too many colors!!
                EXIT SUB
            END IF
            IF ColorList(1, colr) = p1pixel AND ColorList(2, colr) = p2pixel THEN
                DEF SEG = final.image.seg
                POKE final.image.off + offset&, colr
                PixelUsed = 1
                EXIT FOR
            END IF
        NEXT

        IF PixelUsed = 0 THEN

            ColorList(1, NextFreeColor) = p1pixel
            ColorList(2, NextFreeColor) = p2pixel

            DEF SEG = final.image.seg
            POKE final.image.off + offset&, NextFreeColor

            DEF SEG = p1.pal.seg
            r = PEEK(p1.pal.off + (p1pixel * 3))
            g = PEEK(p1.pal.off + (p1pixel * 3) + 1)
            b = PEEK(p1.pal.off + (p1pixel * 3) + 2)
            DEF SEG = final.pal1.seg
            POKE (final.pal1.off + (NextFreeColor * 3)), r
            POKE (final.pal1.off + (NextFreeColor * 3) + 1), g
            POKE (final.pal1.off + (NextFreeColor * 3) + 2), b

            DEF SEG = p2.pal.seg
            r = PEEK(p2.pal.off + (p2pixel * 3))
            g = PEEK(p2.pal.off + (p2pixel * 3) + 1)
            b = PEEK(p2.pal.off + (p2pixel * 3) + 2)
            DEF SEG = final.pal2.seg
            POKE (final.pal2.off + (NextFreeColor * 3)), r
            POKE (final.pal2.off + (NextFreeColor * 3) + 1), g
            POKE (final.pal2.off + (NextFreeColor * 3) + 2), b

            NextFreeColor = NextFreeColor + 1
        END IF
    NEXT

END SUB

SUB Lookup.GenTables

    FOR x = 0 TO 359
        Lookup.Cosine(x) = COS(x * 3.14159265# / 180)
        Lookup.Sine(x) = SIN(x * 3.14159265# / 180)
        Lookup.Sine160(x) = Lookup.Sine(x) / 160
        Lookup.Cosine160(x) = Lookup.Cosine(x) / 160
    NEXT

END SUB

FUNCTION Music.Init

    IF Music.Mode = ADLIB THEN
        Adlib_Handler

        'Detect FM chip
        Adlib_WriteRegister 4, &H60
        Adlib_WriteRegister 4, &H80
        Data1 = INP(Music.Port)
        Adlib_WriteRegister 2, &HFF
        Adlib_WriteRegister 4, &H21
        FOR x = 1 TO 150
            Temp = INP(Music.Port)
        NEXT
        Data2 = INP(Music.Port)
        Adlib_WriteRegister 4, &H60
        Adlib_WriteRegister 4, &H80

        FOR x = 0 TO &HF5
            Adlib_WriteRegister x, 0
        NEXT

        Music.NoteFreq(0) = &H16B
        Music.NoteFreq(1) = &H181
        Music.NoteFreq(2) = &H198
        Music.NoteFreq(3) = &H1B0
        Music.NoteFreq(4) = &H1CA
        Music.NoteFreq(5) = &H1E5
        Music.NoteFreq(6) = &H202
        Music.NoteFreq(7) = &H220
        Music.NoteFreq(8) = &H241
        Music.NoteFreq(9) = &H263
        Music.NoteFreq(10) = &H287
        Music.NoteFreq(11) = &H2AE

    ELSEIF Music.Mode = MPU401 THEN

        FOR x = 255 TO 0 STEP -1
            OUT Music.Port + 1, x + 2
        NEXT
        OUT Music.Port, &HFF
        OUT Music.Port, &H3F

    END IF

    Music.Init = -1

END FUNCTION

SUB Music.Load (Filename$)

    SEEK #Pack, Pack.Offset&(Pack, Filename$)

    Header$ = SPACE$(63)
    GET #Pack, , Header$

    DIM ChanName(7) AS STRING * 8

    FOR x = 0 TO 7
        GET #Pack, , ChanName(x)
        FOR y = 1 TO 8
            IF MID$(ChanName(x), y, 1) = CHR$(0) THEN
                MID$(ChanName(x), y, 1) = " "
            END IF
        NEXT
        GET #Pack, , Music.Channel(x)
    NEXT

    Byte$ = " "
    GET #Pack, , Byte$
    TrackMode = ASC(Byte$) + 1

    Music.PattLen = TrackMode - 1

    GET #Pack, , Byte$
    Music.NumTracks = ASC(Byte$) + 1

    GET #Pack, , Byte$
    Pats = ASC(Byte$) + 1

    FOR x = 0 TO Music.NumTracks - 1
        GET #Pack, , Music.TrackList(x)
    NEXT

    FOR x = 0 TO Music.NumTracks - 1
        GET #Pack, , Byte$
        Music.Delay(x) = ASC(Byte$)
    NEXT

    PatList$ = SPACE$(Pats)
    GET #Pack, , PatList$
    FOR x = 1 TO LEN(PatList$)
        pn = ASC(MID$(PatList$, x, 1))
        FOR ChNum = 0 TO 7
            FOR IPos = 0 TO Music.PattLen
                GET #Pack, , Byte$
                XVal = ASC(Byte$)
                IF XVal AND 128 THEN
                    IPos = IPos + (XVal AND 127)
                ELSE
                    Music.Pattern(pn, IPos, ChNum) = CHR$(XVal)
                END IF
            NEXT
        NEXT
    NEXT

    IF Music.Mode = ADLIB THEN

        FOR Chan = 0 TO 7
            ChanX = (Chan MOD 3) + 8 * INT(Chan / 3)
            Inst$ = Music.Channel(Chan)
            Adlib_WriteRegister &H20 + ChanX, ASC(MID$(Inst$, 1, 1))
            Adlib_WriteRegister &H23 + ChanX, ASC(MID$(Inst$, 2, 1))
            Adlib_WriteRegister &H40 + ChanX, ASC(MID$(Inst$, 3, 1))
            Adlib_WriteRegister &H43 + ChanX, ASC(MID$(Inst$, 4, 1))
            Adlib_WriteRegister &H60 + ChanX, ASC(MID$(Inst$, 5, 1))
            Adlib_WriteRegister &H63 + ChanX, ASC(MID$(Inst$, 6, 1))
            Adlib_WriteRegister &H80 + ChanX, ASC(MID$(Inst$, 7, 1))
            Adlib_WriteRegister &H83 + ChanX, ASC(MID$(Inst$, 8, 1))
            Adlib_WriteRegister &HE0 + ChanX, ASC(MID$(Inst$, 9, 1))
            Adlib_WriteRegister &HE3 + ChanX, ASC(MID$(Inst$, 10, 1))
            Adlib_WriteRegister &HC0 + Chan, ASC(MID$(Inst$, 11, 1))
        NEXT

    ELSEIF Music.Mode = MPU401 THEN

        FOR Chan = 0 TO 7
            SELECT CASE ChanName(Chan)
                CASE "BDRUM2  "
                    Music.Drums(Chan) = 35
                CASE "SNARE1  "
                    Music.Drums(Chan) = 40
                CASE "HIHAT1  "
                    Music.Drums(Chan) = 42
                CASE ELSE
                    Music.Drums(Chan) = 0
            END SELECT
        NEXT

        OUT Music.Port, &HC0 + 0
        OUT Music.Port, 46
        OUT Music.Port, &HC0 + 1
        OUT Music.Port, 118
        OUT Music.Port, &HC0 + 2
        OUT Music.Port, 120
        OUT Music.Port, &HC0 + 3
        OUT Music.Port, 117
        OUT Music.Port, &HC0 + 4
        OUT Music.Port, 98
        OUT Music.Port, &HC0 + 5
        OUT Music.Port, 38
        OUT Music.Port, &HC0 + 6
        OUT Music.Port, 39
        OUT Music.Port, &HC0 + 7
        OUT Music.Port, 38

        OUT Music.Port, &HB0 + 0
        OUT Music.Port, 7
        OUT Music.Port, 96

        OUT Music.Port, &HB0 + 9
        OUT Music.Port, 7
        OUT Music.Port, 50

        OUT Music.Port, &HB0 + 5
        OUT Music.Port, 7
        OUT Music.Port, 110

        OUT Music.Port, &HB0 + 4
        OUT Music.Port, 7
        OUT Music.Port, 127

    END IF

END SUB

SUB Music.Play

    DEF SEG = 0
    TimeNow& = PEEK(&H46D)
    TimeNow& = (PEEK(&H46C) + TimeNow& * 256) MOD 65536
    IF TimeNow& < Music.Time& THEN EXIT SUB

    Music.Time& = (Music.Time& + Music.TimeDelay) MOD 65536

    IF Music.Mode = ADLIB THEN

        FOR Chan = 0 TO 7
            Note = ASC(Music.Pattern(Music.CurPatt, Music.CurPos, Chan)) - 2
            IF Note > -2 THEN
                Adlib_WriteRegister &HA0 + Chan, 0
                Adlib_WriteRegister &HB0 + Chan, 0
            END IF
            IF Note >= 0 THEN
                Octv = INT(Note / 12)
                Freq = Music.NoteFreq(Note MOD 12)
                Adlib_WriteRegister &HA0 + Chan, Freq AND &HFF
                Adlib_WriteRegister &HB0 + Chan, INT(Freq / 256) OR 32 OR (Octv * 4)
            END IF
        NEXT

    ELSEIF Music.Mode = MPU401 THEN

        FOR Chan = 0 TO 7
            Note = ASC(Music.Pattern(Music.CurPatt, Music.CurPos, Chan)) - 2
            IF Music.Drums(Chan) = 0 THEN

                IF Note > -2 THEN
                    OUT Music.Port, &H80 + Chan
                    OUT Music.Port, Music.LastNote(Chan)
                    OUT Music.Port, 127 'Velocity
                END IF
                IF Note >= 0 THEN
                    IF Chan = 0 THEN Note = Note + 16
                    IF Chan = 5 THEN Note = Note + 16

                    OUT Music.Port, &H90 + Chan
                    OUT Music.Port, Note
                    OUT Music.Port, 127 'Velocity
                    Music.LastNote(Chan) = Note

                END IF

            ELSE

                IF Note >= 0 THEN
                    OUT Music.Port, &H90 + 9
                    OUT Music.Port, Music.Drums(Chan)
                    OUT Music.Port, 127 'Velocity
                END IF

            END IF

        NEXT

    END IF

    Music.CurPos = Music.CurPos + 1
    IF Music.CurPos = Music.PattLen THEN
        Music.CurPos = 0
        Music.CurTrack = Music.CurTrack + 1
        IF Music.CurTrack = Music.NumTracks THEN Music.CurTrack = 0
        Music.CurPatt = ASC(Music.TrackList(Music.CurTrack))

        Music.TimeDelay = Music.Delay(Music.CurTrack)
        Music.Time& = Music.Time& + Music.TimeDelay
    END IF

END SUB

FUNCTION Music.Size (Filename$, Which)

    SEEK #Pack, Pack.Offset&(Pack, Filename$)

    Header$ = SPACE$(215)
    GET #Pack, , Header$

    Byte$ = " "
    GET #Pack, , Byte$
    TrackMode = ASC(Byte$) + 1

    IF Which = 0 THEN
        PatN = 4096 \ TrackMode - 1
        IF PatN > 255 THEN PatN = 255
        Music.Size = PatN + 1
    ELSE
        Music.Size = TrackMode - 1
    END IF

END FUNCTION

SUB Music.StartPlay (StartTrack, StartPos)

    Music.CurTrack = StartTrack
    Music.CurPos = StartPos
    Music.CurPatt = ASC(Music.TrackList(Music.CurTrack))

    DEF SEG = 0
    Music.Time& = PEEK(&H46D)
    Music.Time& = (PEEK(&H46C) + Music.Time& * 256) MOD 65536

    Music.Time& = (Music.Time& + Music.TimeDelay) MOD 65536
    Music.TimeDelay = Music.Delay(Music.CurTrack)

END SUB

SUB Music.Stop

    IF Music.Mode = ADLIB THEN

        FOR Chan = 0 TO 7
            Adlib_WriteRegister &HA0 + Chan, 0
            Adlib_WriteRegister &HB0 + Chan, 0
        NEXT Chan

    ELSEIF Music.Mode = MPU401 THEN

        FOR Chan = 0 TO 15
            FOR Note = 0 TO 127
                OUT Music.Port, &H80 + Chan
                OUT Music.Port, Note
                OUT Music.Port, 0 'Velocity
            NEXT
        NEXT

    END IF

END SUB

SUB Pack.BLoad (PakFile, Filename$, segment, offset)

    buffer = 8000

    SEEK #PakFile, 6
    GET #PakFile, , NumFiles

    FOR x = 1 TO NumFiles

        Name$ = SPACE$(8)
        GET #PakFile, , Name$

        Ext$ = SPACE$(3)
        GET #PakFile, , Ext$

        IF Filename$ = LTRIM$(RTRIM$(Name$)) + "." + LTRIM$(RTRIM$(Ext$)) THEN
            FileNum = x
            EXIT FOR
        END IF

    NEXT

    IF x = 0 THEN
        CLOSE #PakFile
        EXIT SUB
    END IF

    SEEK #PakFile, 11 + NumFiles * 11 + (FileNum - 1) * 8
    GET #PakFile, , FileLoc&
    GET #PakFile, , FileLen&

    FileLoc& = FileLoc& + 7
    FileLen& = FileLen& - 7
    SEEK #PakFile, FileLoc& + 1

    offset& = offset - 1
    Block = buffer
    DO
        IF LOC(PakFile) = FileLoc& + FileLen& + 1 THEN EXIT DO
        IF LOC(PakFile) + Block > FileLoc& + FileLen& + 1 THEN
            Block = (FileLoc& + FileLen& + 1) - LOC(PakFile)
        END IF
        IF Music.Playing THEN Music.Play
        buffer$ = INPUT$(Block, # PakFile)
        IF Music.Playing THEN Music.Play
        DEF SEG = segment
        FOR x = 1 TO LEN(buffer$)
            POKE offset& + x, ASC(MID$(buffer$, x, 1))
        NEXT
        offset& = offset& + LEN(buffer$)
    LOOP UNTIL EOF(PakFile)
    buffer$ = ""

END SUB

FUNCTION Pack.Offset& (PakFile, Filename$)

    SEEK #PakFile, 6
    GET #PakFile, , NumFiles

    FOR x = 1 TO NumFiles

        Name$ = SPACE$(8)
        GET #PakFile, , Name$

        Ext$ = SPACE$(3)
        GET #PakFile, , Ext$

        IF Filename$ = LTRIM$(RTRIM$(Name$)) + "." + LTRIM$(RTRIM$(Ext$)) THEN
            FileNum = x
            EXIT FOR
        END IF

    NEXT

    IF x = 0 THEN EXIT FUNCTION

    SEEK #PakFile, 11 + NumFiles * 11 + (FileNum - 1) * 8
    GET #PakFile, , FileLoc&
    GET #PakFile, , FileLen&

    Pack.Offset& = FileLoc& + 1

END FUNCTION

SUB Plasma.Adjust (xa, ya, x, y, xb, yb, buffer.seg, buffer.off)

    DEF SEG = buffer.seg

    IF Compiled THEN

        a = PEEK(buffer.off + x + y * 320)
        IF a THEN EXIT SUB

        r! = RND / 1 - .5
        D = ABS(xa - xb) + ABS(ya - yb)

        a = PEEK(buffer.off + xa + ya * 320)
        b = PEEK(buffer.off + xb + yb * 320)

        V! = (a + b) / 2 + D * r! * 4

        IF V! < 1 THEN V! = 1
        IF V! > 192 THEN V! = 192

        POKE buffer.off + x + y * 320, INT(V!)

    ELSE

        a = PEEK(buffer.off + x + y * 320&)
        IF a THEN EXIT SUB

        r! = RND / 1 - .5
        D = ABS(xa - xb) + ABS(ya - yb)

        a = PEEK(buffer.off + xa + ya * 320&)
        b = PEEK(buffer.off + xb + yb * 320&)

        V! = (a + b) / 2 + D * r! * 4

        IF V! < 1 THEN V! = 1
        IF V! > 192 THEN V! = 192

        POKE buffer.off + x + y * 320&, INT(V!)

    END IF

END SUB

SUB Plasma.Gen (buffer.seg, buffer.off)

    DEF SEG = buffer.seg
    POKE buffer.off, 1 + (RND * 192)
    POKE buffer.off + 319, 1 + (RND * 192)
    POKE buffer.off + 199 * 320&, 1 + (RND * 192)
    POKE buffer.off + 319 + 199 * 320&, 1 + (RND * 192)

    Plasma.SplitBox 0, 0, 319, 199, buffer.seg, buffer.off

END SUB

SUB Plasma.SplitBox (x1, y1, x2, y2, buffer.seg, buffer.off)

    Music.Play

    diffx = x2 - x1
    diffy = y2 - y1

    IF diffx < 2 AND diffy < 2 THEN EXIT SUB

    x = (x1 + x2) \ 2
    y = (y1 + y2) \ 2

    Plasma.Adjust x1, y1, x, y1, x2, y1, buffer.seg, buffer.off
    Plasma.Adjust x2, y1, x2, y, x2, y2, buffer.seg, buffer.off
    Plasma.Adjust x1, y2, x, y2, x2, y2, buffer.seg, buffer.off
    Plasma.Adjust x1, y1, x1, y, x1, y2, buffer.seg, buffer.off

    DEF SEG = buffer.seg

    IF Compiled THEN

        c1 = PEEK(buffer.off + x + y * 320)
        IF c1 = 0 THEN
            c1 = PEEK(buffer.off + x1 + y1 * 320)
            c2 = PEEK(buffer.off + x2 + y1 * 320)
            c3 = PEEK(buffer.off + x1 + y2 * 320)
            c4 = PEEK(buffer.off + x2 + y2 * 320)
            POKE buffer.off + x + y * 320, (c1 + c2 + c3 + c3) \ 4
        END IF

    ELSE

        c1 = PEEK(buffer.off + x + y * 320&)
        IF c1 = 0 THEN
            c1 = PEEK(buffer.off + x1 + y1 * 320&)
            c2 = PEEK(buffer.off + x2 + y1 * 320&)
            c3 = PEEK(buffer.off + x1 + y2 * 320&)
            c4 = PEEK(buffer.off + x2 + y2 * 320&)
            POKE buffer.off + x + y * 320&, (c1 + c2 + c3 + c3) \ 4
        END IF

    END IF

    Plasma.SplitBox x1, y1, x, y, buffer.seg, buffer.off
    Plasma.SplitBox x, y1, x2, y, buffer.seg, buffer.off
    Plasma.SplitBox x, y, x2, y2, buffer.seg, buffer.off
    Plasma.SplitBox x1, y, x, y2, buffer.seg, buffer.off

END SUB

'$INCLUDE:'include/adlib.bas'
