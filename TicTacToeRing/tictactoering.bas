OPTION _EXPLICIT

$EXEICON:'./assets/images/tttr.ico'

$VERSIONINFO:FILEVERSION#=1,0,0,0
$VERSIONINFO:PRODUCTVERSION#=1,0,0,0
$VERSIONINFO:CompanyName=Fellippe Heitor
$VERSIONINFO:ProductName=Tic Tac Toe Ring
$VERSIONINFO:ProductVersion=1.0
$VERSIONINFO:Comments=Based on 'Rings.' by Gamezaur; Created with QB64.
$VERSIONINFO:Web=https://github.com/FellippeHeitor/TicTacToeRing
$VERSIONINFO:InternalName=tictactoering.bas

CONST true = -1, false = 0

'Required shared variables for printLarge
DIM SHARED charSet(255, 1 TO 16, 1 TO 8) AS _BYTE

initializeCharSetPrintLarge

TYPE object
    x AS SINGLE
    y AS SINGLE
    xv AS SINGLE
    yv AS SINGLE
    xa AS SINGLE
    ya AS SINGLE
    set AS STRING * 6
    size AS SINGLE
    start AS SINGLE
    duration AS SINGLE
    state AS _BYTE
    text AS INTEGER
    w AS INTEGER
    h AS INTEGER
    r AS INTEGER
    g AS INTEGER
    b AS INTEGER
END TYPE

DIM canvas AS LONG
canvas = _NEWIMAGE(600, 600, 32)

SCREEN canvas
_DELAY .1
_SCREENMOVE _MIDDLE
_TITLE "Tic Tac Toe Ring"
_PRINTMODE _KEEPBACKGROUND

DIM peg(0 TO 12) AS object
DIM del(1 TO 9) AS object

DIM emptySet$
emptySet$ = MKI$(-1) + MKI$(-1) + MKI$(-1)
peg(0).set = emptySet$

'set pegs positions
DIM spacing AS INTEGER
DIM i AS INTEGER, j AS SINGLE, k AS SINGLE
setPegs

'set combo messages
DIM megaComboMsg$(1 TO 6)
setComboMessages

DIM c(8) AS _UNSIGNED LONG
setRingColors

DIM circleImage(1 TO i, 1 TO 3) AS LONG
generateRingImages

DIM crownIcon AS LONG
generateCrownIcon

_DEST _DISPLAY
DIM bg AS LONG, bgWithoutShelf AS LONG
generateBG

'flash warning
_DEST _DISPLAY
_DONTBLEND
_PUTIMAGE (0, 0), bg
_BLEND
centerLarge (_HEIGHT / 2) - fontHeightLarge(2) / 2, "This game contains bright,", 2
centerLarge (_HEIGHT / 2) + fontHeightLarge(2) / 2, "rapidly flashing colors.", 2

DIM music AS _BYTE, sfx AS _BYTE
music = true
sfx = true

loadGame

'load sounds
j = TIMER
DIM selectSound AS LONG
selectSound = _SNDOPEN("assets/sounds/select.ogg")
IF selectSound > 0 THEN _SNDVOL selectSound, .3

DIM wooshSound AS LONG
wooshSound = _SNDOPEN("assets/sounds/woosh.ogg")
IF wooshSound > 0 THEN _SNDVOL wooshSound, .5

DIM woodblock AS LONG
woodblock = _SNDOPEN("assets/sounds/woodblock.wav")

DIM track(1 TO 1) AS LONG, mainTrackVolume AS SINGLE
track(1) = _SNDOPEN("assets/music/track1.ogg")
mainTrackVolume = 1
IF track(1) > 0 THEN _SNDVOL track(1), mainTrackVolume

DIM comboSound(1 TO 8) AS LONG, a$
RESTORE comboSoundFiles
FOR i = 1 TO 8
    READ a$
    comboSound(i) = _SNDOPEN("assets/sounds/" + a$)
NEXT

comboSoundFiles:
DATA do.ogg,re.ogg,mi.ogg,fa.ogg,sol.ogg,la.ogg,si.ogg,do2.ogg

'if loading sounds took more than 2 seconds, no need to pause
j = TIMER - j
IF j < 2 THEN pause 2 - j

DIM thisColor AS INTEGER
doIntro

RANDOMIZE TIMER

'add divs to bg
bgWithoutShelf = _COPYIMAGE(bg)
_DEST bg
LINE (_WIDTH / 2 - (_WIDTH / spacing) * 2, _HEIGHT / 2 - (_HEIGHT / spacing) * 2)-STEP(_WIDTH / spacing * 4, _HEIGHT / spacing * 4), _RGB32(0, 50), BF
LINE (3 + peg(10).x - (_WIDTH / spacing / 2), 3 + peg(10).y - (_WIDTH / spacing / 2))-(3 + peg(12).x + (_WIDTH / spacing / 2), 3 + peg(12).y + (_WIDTH / spacing / 2)), _RGB32(255, 15), BF
LINE (peg(10).x - (_WIDTH / spacing / 2), peg(10).y - (_WIDTH / spacing / 2))-(peg(12).x + (_WIDTH / spacing / 2), peg(12).y + (_WIDTH / spacing / 2)), _RGB32(255, 15), BF

'game
DIM score AS _UNSIGNED LONG, visibleScore AS _UNSIGNED LONG
DIM highscore AS _UNSIGNED LONG, visibleHighScore AS _UNSIGNED LONG
DIM level AS _UNSIGNED LONG, maxColors AS INTEGER
DIM animation(0 TO 8) AS object, gameOver AS _BYTE
DIM particle(5000) AS object, pauseGame AS _BYTE

animation(0).duration = .25 'board flash
FOR i = 1 TO 5
    animation(i).duration = .5 'matches
NEXT
animation(6).duration = 1 'new set spawn
animation(7).duration = 1 'combo info

DIM multiplier AS INTEGER
multiplier = 1

visibleScore = score
visibleHighScore = highscore
_DEST _DISPLAY

DIM button(100) AS object
DIM caption(100) AS STRING
DIM totalButtons AS INTEGER
DIM currentButton AS INTEGER

DO
    DO 'main game loop
        'read mouse data
        WHILE _MOUSEINPUT: WEND

        'read keyboard
        DIM keyb AS LONG
        keyb = _KEYHIT

        IF mainTrackVolume > .5 AND music THEN
            mainTrackVolume = mainTrackVolume - .05
            IF track(1) > 0 THEN _SNDVOL track(1), mainTrackVolume
        END IF
        'redraw board
        _DONTBLEND
        _PUTIMAGE (0, 0), bg
        _BLEND

        'print osd
        DIM enterSettings AS _BYTE
        createMainScreenButtons
        IF ABS(keyb) <> 27 AND pauseGame = false AND enterSettings = false THEN doButtons

        _PUTIMAGE (25, 28), crownIcon
        COLOR _RGB32(200)
        _PRINTSTRING (52, 28), STR$(visibleHighScore)

        COLOR _RGB32(255)
        printLarge 0, 45, STR$(visibleScore), 6

        IF multiplier > 1 THEN
            _PRINTSTRING (52, 132), "x" + LTRIM$(STR$(multiplier))
        END IF

        drawPegs
        generateNewSets

        IF ABS(keyb) <> 27 AND pauseGame = false AND enterSettings = false THEN checkButtons

        DIM prevbt AS INTEGER
        IF currentButton <> prevbt THEN
            IF currentButton > 0 AND sfx AND selectSound > 0 THEN _SNDPLAYCOPY selectSound
            prevbt = currentButton
        END IF

        IF _MOUSEBUTTON(1) THEN
            'drag?
            DIM dragging AS INTEGER
            DIM mouseDown AS _BYTE
            IF NOT mouseDown THEN
                'are we beginning to drag a ring or set of rings?
                dragging = 0
                FOR i = 10 TO 12
                    IF dist(peg(i).x, peg(i).y, _MOUSEX, _MOUSEY) <= 40 AND peg(i).set <> emptySet$ THEN
                        dragging = i
                        EXIT FOR
                    END IF
                NEXT

                mouseDown = true
            END IF
        ELSE
            IF mouseDown THEN
                IF dragging = 0 THEN
                    IF enterSettings = false AND currentButton = 1 THEN
                        enterSettings = true
                        _CONTINUE
                    END IF

                    IF pauseGame = false AND currentButton = 2 THEN 'pause
                        pauseGame = true
                        _CONTINUE
                    END IF
                END IF

                'place rings
                DIM placed AS _BYTE
                placed = false

                IF dragging THEN
                    FOR i = 1 TO 9
                        IF dist(peg(i).x, peg(i).y, _MOUSEX, _MOUSEY) <= 40 THEN
                            'check that the chosen peg can hold the current set of rings
                            placed = true
                            FOR j = 1 TO 3
                                IF CVI(MID$(peg(dragging).set, j * 2 - 1, 2)) > 0 AND CVI(MID$(peg(i).set, j * 2 - 1, 2)) > 0 THEN
                                    placed = false
                                    EXIT FOR
                                END IF
                            NEXT
                            IF placed THEN
                                IF woodblock > 0 AND sfx THEN _SNDPLAYCOPY woodblock
                                FOR j = 1 TO 3
                                    IF CVI(MID$(peg(dragging).set, j * 2 - 1, 2)) > 0 THEN
                                        MID$(peg(i).set, j * 2 - 1, 2) = MID$(peg(dragging).set, j * 2 - 1, 2)
                                    END IF
                                NEXT
                                peg(dragging).set = emptySet$
                                EXIT FOR
                            ELSE
                                EXIT FOR
                            END IF
                        END IF
                    NEXT
                END IF

                FOR j = 1 TO 9
                    'prepare backup copies for deletion tagging
                    del(j) = peg(j)
                NEXT

                'check matches
                DIM r(1 TO 3) AS INTEGER, previousScore AS _UNSIGNED LONG
                DIM s$, found1 AS INTEGER, found2 AS INTEGER, scored AS _BYTE
                DIM totalMatches AS INTEGER
                totalMatches = 0
                previousScore = score
                IF placed THEN
                    'look for 3 same-color rings on peg(i) --> ((o))
                    FOR j = 1 TO 3
                        r(j) = CVI(MID$(peg(i).set, j * 2 - 1, 2))
                    NEXT
                    IF r(1) = r(2) AND r(2) = r(3) THEN
                        score = score + 3 * multiplier
                        animation(0).start = TIMER
                        animation(5).start = TIMER
                        animation(5).x = peg(i).x
                        animation(5).y = peg(i).y
                        animation(5).r = _RED32(c(r(1)))
                        animation(5).g = _GREEN32(c(r(1)))
                        animation(5).b = _BLUE32(c(r(1)))
                        animation(8).r = _RED32(c(r(1)))
                        animation(8).g = _GREEN32(c(r(1)))
                        animation(8).b = _BLUE32(c(r(1)))
                        del(i).set = emptySet$
                        addParticles peg(i).x, peg(i).y, 70, c(r(1))
                        addParticles peg(i).x, peg(i).y, 30, _RGB32(_RED32(c(r(1))) + 30, _GREEN32(c(r(1))) + 30, _BLUE32(c(r(1))) + 30)
                        totalMatches = totalMatches + 1
                    END IF

                    'look for line matches |, -, /, \
                    DIM m AS INTEGER, checks AS INTEGER
                    DIM nextPeg(0 TO 2) AS INTEGER
                    FOR m = 1 TO 4
                        SELECT CASE m
                            CASE 1 'across
                                checks = 3
                                r(1) = 1
                                r(2) = 4
                                r(3) = 7
                                nextPeg(1) = 1
                                nextPeg(2) = 2
                            CASE 2 'down
                                checks = 3
                                r(1) = 1
                                r(2) = 2
                                r(3) = 3
                                nextPeg(1) = 3
                                nextPeg(2) = 6
                            CASE 3 'diagonal \
                                checks = 1
                                r(1) = 1
                                nextPeg(1) = 4
                                nextPeg(2) = 8
                            CASE 4 'diagonal /
                                checks = 1
                                r(1) = 3
                                nextPeg(1) = 2
                                nextPeg(2) = 4
                        END SELECT

                        FOR i = 1 TO checks
                            'look at each ring on the first peg of each row
                            FOR j = 1 TO 3
                                scored = false
                                s$ = MID$(peg(r(i)).set, j * 2 - 1, 2)
                                IF s$ = MKI$(-1) THEN _CONTINUE
                                found1 = INSTR(peg(r(i) + nextPeg(1)).set, s$)
                                found2 = INSTR(peg(r(i) + nextPeg(2)).set, s$)
                                IF found1 > 0 AND found2 > 0 THEN
                                    'match! clear all rings of the same color in this group of pegs
                                    FOR k = 0 TO 2
                                        found1 = INSTR(del(r(i) + nextPeg(k)).set, s$)
                                        DO WHILE found1
                                            MID$(del(r(i) + nextPeg(k)).set, found1, 2) = MKI$(-1)
                                            addParticles del(r(i) + nextPeg(k)).x, del(r(i) + nextPeg(k)).y, 23, c(CVI(s$))
                                            addParticles del(r(i) + nextPeg(k)).x, del(r(i) + nextPeg(k)).y, 10, _RGB32(_RED32(c(CVI(s$))) + 30, _GREEN32(c(CVI(s$))) + 30, _BLUE32(c(CVI(s$))) + 30)
                                            score = score + multiplier
                                            found1 = INSTR(del(r(i) + nextPeg(k)).set, s$)
                                        LOOP
                                    NEXT
                                    scored = true
                                    totalMatches = totalMatches + 1
                                    animation(0).start = TIMER
                                    animation(m).start = TIMER
                                    animation(m).x = peg(r(i)).x
                                    animation(m).y = peg(r(i)).y
                                    animation(m).r = _RED32(c(CVI(s$)))
                                    animation(m).g = _GREEN32(c(CVI(s$)))
                                    animation(m).b = _BLUE32(c(CVI(s$)))
                                    animation(8).r = _RED32(c(CVI(s$)))
                                    animation(8).g = _GREEN32(c(CVI(s$)))
                                    animation(8).b = _BLUE32(c(CVI(s$)))
                                END IF

                                IF scored THEN MID$(del(r(i)).set, j * 2 - 1, 2) = MKI$(-1)
                            NEXT
                        NEXT
                    NEXT

                    FOR j = 1 TO 9
                        'perform deletion, if any items were marked = MKI$(-1)
                        peg(j) = del(j)
                    NEXT

                    IF previousScore < score THEN
                        IF wooshSound > 0 AND sfx THEN _SNDPLAYCOPY wooshSound

                        multiplier = multiplier + 1

                        IF sfx THEN
                            IF multiplier - 1 <= UBOUND(combosound) THEN
                                IF comboSound(multiplier - 1) > 0 THEN
                                    _SNDPLAYCOPY comboSound(multiplier - 1)
                                END IF
                            ELSE
                                IF comboSound(UBOUND(combosound)) > 0 THEN
                                    _SNDPLAYCOPY comboSound(UBOUND(combosound))
                                END IF
                            END IF
                        END IF

                        DIM m$(1 TO 2)
                        m$(1) = megaComboMsg$(_CEIL(RND * UBOUND(megaComboMsg$)))
                        m$(2) = LTRIM$(STR$(multiplier)) + "x combo!"
                        animation(7).start = TIMER
                        animation(8).start = TIMER
                        animation(8).x = _MOUSEX
                        animation(8).y = _MOUSEY
                        animation(8).xa = score - previousScore
                        animation(8).ya = dist(_MOUSEX, _MOUSEY, printWidthLarge(STR$(visibleScore), 6) / 2, 45)
                        animation(8).duration = 5
                    ELSE
                        multiplier = 1
                    END IF
                    IF score > highscore THEN highscore = score
                END IF
            END IF
            mouseDown = false
            dragging = 0
        END IF

        hoverHighlight
        checkAvailableMoves
        drawRings
        doAnimations
        updateScore
        updateParticles

        'update display
        _DISPLAY

        IF enterSettings THEN
            addParticles _MOUSEX, _MOUSEY, 30, _RGB32(255)
            addParticles _MOUSEX, _MOUSEY, 30, _RGB32(67, 172, 183)
            settingsScreen
            enterSettings = false
        END IF

        IF pauseGame THEN
            addParticles _MOUSEX, _MOUSEY, 30, _RGB32(255)
            addParticles _MOUSEX, _MOUSEY, 30, _RGB32(67, 172, 183)
            keyb = -27
            pauseGame = false
        END IF

        'limit fps
        _LIMIT 60

        DIM userQuit AS _BYTE
        userQuit = _EXIT
        IF keyb = -27 THEN EXIT DO
    LOOP UNTIL gameOver OR userQuit

    saveGame

    IF userQuit THEN SYSTEM

    endScreen

LOOP

SUB setPegs
    SHARED spacing AS INTEGER
    SHARED peg() AS object
    SHARED emptySet$

    DIM l AS SINGLE, i AS INTEGER, j AS SINGLE, k AS SINGLE
    spacing = 6
    l = -(_HEIGHT / spacing)
    FOR i = 1 TO 12
        j = j + 1
        IF j > 3 THEN j = 1: l = l + (_HEIGHT / spacing)
        SELECT CASE j
            CASE 1: k = -_WIDTH / spacing
            CASE 2: k = 0
            CASE 3: k = _WIDTH / spacing
        END SELECT
        peg(i).x = _WIDTH / 2 + k
        peg(i).y = _HEIGHT / 2 + l
        peg(i).set = emptySet$
    NEXT
END SUB

SUB setComboMessages
    SHARED megaComboMsg$()
    DIM i AS INTEGER

    RESTORE megaComboMsgs
    FOR i = 1 TO UBOUND(megaComboMsg$)
        READ megaComboMsg$(i)
    NEXT
    megaComboMsgs:
    DATA Fantastic,Outstanding,Amazing,Awesome,MEGA,SUPER
END SUB

SUB setRingColors
    SHARED i AS INTEGER
    SHARED c() AS _UNSIGNED LONG

    i = i + 1: c(i) = _RGB32(0, 78, 249) 'blue
    i = i + 1: c(i) = _RGB32(0, 100, 0) 'green
    i = i + 1: c(i) = _RGB32(222, 61, 44) 'red
    i = i + 1: c(i) = _RGB32(216, 216, 44) 'yellow
    i = i + 1: c(i) = _RGB32(233, 139, 17) 'orange
    i = i + 1: c(i) = _RGB32(222, 105, 161) 'pink
    i = i + 1: c(i) = _RGB32(139, 11, 205) 'purple
    i = i + 1: c(i) = _RGB32(55, 211, 211) 'cyan
END SUB

SUB generateRingImages
    DIM j AS INTEGER, k AS INTEGER
    SHARED c() AS _UNSIGNED LONG
    SHARED circleImage() AS LONG

    FOR j = 1 TO UBOUND(c)
        FOR k = 1 TO 3
            circleImage(j, k) = _NEWIMAGE(k * 29, k * 29, 32)
            _DEST circleImage(j, k)
            PAINT (0, 0), _RGB32(255, 0, 255)
            CircleFill _WIDTH / 2, _HEIGHT / 2, k * 14, c(j)
            CircleFill _WIDTH / 2, _HEIGHT / 2, k * (8 + k), _RGB32(255, 0, 255)
            _CLEARCOLOR _RGB32(255, 0, 255)
        NEXT
    NEXT
END SUB

SUB generateCrownIcon
    SHARED crownIcon AS LONG
    DIM i AS INTEGER, j AS INTEGER
    DIM px AS INTEGER

    RESTORE crownIconData
    crownIcon = _NEWIMAGE(24, 14, 32)
    _DEST crownIcon
    FOR i = 0 TO 13
        FOR j = 0 TO 23
            READ px
            SELECT CASE px
                CASE 1
                    PSET (j, i), _RGB32(0)
                CASE 2
                    PSET (j, i), _RGB32(205, 161, 0)
            END SELECT
        NEXT
    NEXT

    crownIconData:
    DATA 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,1,2,2,1,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,1,2,2,1,0,0,0,0,0,0,0,0,0,0
    DATA 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0
    DATA 1,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0,0,0,0,0,1,2,2,1
    DATA 1,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0,0,0,0,0,1,2,2,1
    DATA 0,1,1,2,1,1,0,0,0,1,2,2,2,2,1,0,0,0,1,1,2,1,1,0
    DATA 0,0,1,2,2,2,1,1,0,1,2,2,2,2,1,0,1,1,2,2,2,1,0,0
    DATA 0,0,1,2,2,2,2,2,1,2,2,2,2,2,2,1,2,2,2,2,2,1,0,0
    DATA 0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0
    DATA 0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0
    DATA 0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0,0
    DATA 0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0,0
    DATA 0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
END SUB

SUB generateBG
    SHARED bg AS LONG
    DIM i AS SINGLE

    bg = _NEWIMAGE(_WIDTH, _HEIGHT, 32)
    _DEST bg
    FOR i = 0 TO _HEIGHT - 1 STEP _HEIGHT / 60
        LINE (0, 0)-(_WIDTH - 1, i), _RGB32(139, 116, 177, 5), BF
    NEXT
END SUB

SUB doIntro
    SHARED thisColor AS INTEGER
    SHARED c() AS _UNSIGNED LONG
    SHARED circleImage() AS LONG
    SHARED track() AS LONG
    SHARED bg AS LONG
    SHARED music AS _BYTE

    DIM x AS SINGLE, y AS SINGLE, j AS INTEGER
    DIM introRings(1 TO 30) AS object
    DIM i AS INTEGER

    FOR i = 1 TO UBOUND(introRings)
        introRings(i).xa = RND * _PI(2)
        introRings(i).xv = RND * 5
        introRings(i).r = RND * 30 + 50
        introRings(i).set = MKI$(-1) + MKI$(-1) + MKI$(_CEIL(RND * UBOUND(c)))
    NEXT

    addParticles _WIDTH / 2, _HEIGHT / 2, 5000, _RGB32(255)

    DIM introTimer AS SINGLE
    introTimer = TIMER
    IF track(1) > 0 AND music THEN _SNDLOOP track(1)
    DO
        _DONTBLEND
        _PUTIMAGE (0, 0), bg
        _BLEND

        FOR i = 1 TO UBOUND(introRings)
            introRings(i).xa = introRings(i).xa + .01
            introRings(i).r = introRings(i).r + introRings(i).xv
            x = _WIDTH / 2 + COS(introRings(i).xa) * introRings(i).r
            y = _HEIGHT / 2 + SIN(introRings(i).xa) * introRings(i).r

            FOR j = 1 TO 3
                thisColor = CVI(MID$(introRings(i).set, j * 2 - 1, 2))
                IF thisColor > 0 THEN
                    _PUTIMAGE (x - (_WIDTH(circleImage(thisColor, j)) / 2), y - (_HEIGHT(circleImage(thisColor, j)) / 2)), circleImage(thisColor, j)
                END IF
            NEXT
        NEXT

        updateParticles

        LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - introTimer, 4, 6, 0, 255)), BF

        COLOR _RGB32(0)
        centerLarge (_HEIGHT / 2) - fontHeightLarge(2) + 3, "Tic Tac Toe", 2
        centerLarge (_HEIGHT / 2) + 3, "Rings", 7
        centerLarge _HEIGHT - fontHeightLarge(2) + 3, "Fellippe Heitor, 2020", 1

        COLOR _RGB32(255)
        centerLarge (_HEIGHT / 2) - fontHeightLarge(2), "Tic Tac Toe", 2
        centerLarge (_HEIGHT / 2), "Rings", 7
        centerLarge _HEIGHT - fontHeightLarge(2), "Fellippe Heitor, 2020", 1

        LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - introTimer, 0, 1.5, 255, 0)), BF
        LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - introTimer, 4, 5, 0, 255)), BF
        LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(0, map(TIMER - introTimer, 5, 6, 0, 255)), BF

        WHILE _MOUSEINPUT: WEND
        _DISPLAY
        _LIMIT 60
    LOOP UNTIL TIMER - introTimer > 6 OR _KEYHIT OR _MOUSEBUTTON(1)
END SUB


SUB drawPegs
    SHARED peg() AS object

    DIM i AS INTEGER
    FOR i = 1 TO 9
        CircleFill peg(i).x, peg(i).y, 3, _RGB32(255)
    NEXT
END SUB

SUB generateNewSets
    SHARED peg() AS object
    SHARED animation() AS object
    SHARED c() AS _UNSIGNED LONG
    SHARED emptySet$
    SHARED level AS _UNSIGNED LONG, maxColors AS INTEGER

    DIM i AS INTEGER
    DIM j AS INTEGER

    'new sets must be generated according to
    'current board's available positions
    IF peg(10).set + peg(11).set + peg(12).set = emptySet$ + emptySet$ + emptySet$ THEN
        level = level + 1
        maxColors = map(level, 1, 30, 3, UBOUND(c)) 'as level goes up, add more colors
        IF maxColors < 3 THEN maxColors = 3
        IF maxColors > UBOUND(c) THEN maxColors = UBOUND(c)

        DIM pegsUsed AS STRING, thisPeg AS INTEGER, newPeg AS INTEGER
        pegsUsed = ""
        FOR i = 10 TO 12
            'reset this peg
            peg(i).set = emptySet$

            'choose an existing peg randomly
            newPeg = _CEIL(RND * 9)
            thisPeg = newPeg
            DO
                IF INSTR(peg(thisPeg).set, MKI$(-1)) > 0 AND INSTR(pegsUsed, MKI$(thisPeg)) = 0 THEN
                    'found a peg with an empty slot or more
                    EXIT DO
                END IF
                thisPeg = thisPeg + 1
                IF thisPeg > 9 THEN thisPeg = 1
                IF thisPeg = newPeg THEN
                    'full circle
                    thisPeg = 0
                    EXIT DO
                END IF
            LOOP

            'store the chosen peg's id
            IF thisPeg > 0 THEN pegsUsed = pegsUsed + MKI$(thisPeg)

            'generate a set, with random colors
            DO
                FOR j = 1 TO 3
                    IF MID$(peg(thisPeg).set, j * 2 - 1, 2) = MKI$(-1) THEN
                        IF RND * 100 < 30 THEN
                            MID$(peg(i).set, j * 2 - 1, 2) = MKI$(_CEIL(RND * maxColors))
                        END IF
                    END IF
                NEXT
            LOOP WHILE peg(i).set = emptySet$ 'can't be empty
            IF INSTR(peg(i).set, MKI$(-1)) = 0 THEN 'can't be full
                j = _CEIL(RND * 3)
                MID$(peg(i).set, j * 2 - 1, 2) = MKI$(-1)
            END IF
        NEXT
        animation(6).start = TIMER
    END IF
END SUB

SUB doAnimations
    DIM i AS INTEGER, j AS SINGLE, k AS SINGLE, l AS SINGLE
    SHARED animation() AS object
    SHARED peg() AS object
    SHARED totalMatches AS INTEGER
    SHARED m$(), spacing AS INTEGER
    SHARED visibleScore AS _UNSIGNED LONG

    FOR i = 0 TO UBOUND(animation)
        IF TIMER - animation(i).start <= animation(i).duration THEN
            DIM animSize AS SINGLE
            animSize = map(TIMER - animation(i).start, 0, animation(i).duration, 50, 0)
            SELECT CASE i
                CASE 0 'board flash
                    LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - animation(i).start, 0, animation(i).duration, 100, 0)), BF
                CASE 1 'across
                    FOR j = 0 TO _WIDTH STEP _WIDTH / 30
                        FOR k = 1 TO animSize STEP 5
                            CircleFill j, animation(i).y, k, _RGB32(animation(i).r, animation(i).g, animation(i).b, 20)
                        NEXT
                    NEXT
                CASE 2 'down
                    FOR j = 0 TO _WIDTH STEP _WIDTH / 30
                        FOR k = 1 TO animSize STEP 5
                            CircleFill animation(i).x, j, k, _RGB32(animation(i).r, animation(i).g, animation(i).b, 20)
                        NEXT
                    NEXT
                CASE 3 'diagonal \
                    FOR j = 0 TO _WIDTH STEP _WIDTH / 30
                        FOR k = 1 TO animSize STEP 5
                            CircleFill j, j, k, _RGB32(animation(i).r, animation(i).g, animation(i).b, 20)
                        NEXT
                    NEXT
                CASE 4 'diagonal /
                    FOR j = 0 TO _WIDTH STEP _WIDTH / 30
                        FOR k = 1 TO animSize STEP 5
                            CircleFill j, _HEIGHT - j, k, _RGB32(animation(i).r, animation(i).g, animation(i).b, 20)
                        NEXT
                    NEXT
                CASE 5 'single peg ((o))
                    FOR k = 1 TO animSize * 2
                        CircleFill animation(i).x, animation(i).y, k, _RGB32(animation(i).r, animation(i).g, animation(i).b, 20)
                    NEXT
                CASE 6 'new peg set
                    FOR k = 10 TO 12
                        CIRCLE (peg(k).x, peg(k).y), animSize * 1.5, _RGB32(255, animSize / 2)
                        CIRCLE (peg(k).x, peg(k).y), animSize, _RGB32(255, animSize)
                    NEXT
                CASE 7 'combo info
                    k = INT(map(animSize, 50, 40, 1, 4))
                    IF k < 1 THEN k = 1
                    IF k > 4 THEN k = 4
                    COLOR _RGB32(0.80)
                    FOR l = -4 TO 4 STEP 8
                        IF totalMatches > 1 THEN
                            printLarge (l + _WIDTH - printWidthLarge(m$(1), k)) / 2, (l + _HEIGHT - fontHeightLarge(k)) / 2 - fontHeightLarge(k), m$(1), k
                        END IF
                        printLarge (l + _WIDTH - printWidthLarge(m$(2), k)) / 2, (l + _HEIGHT - fontHeightLarge(k)) / 2, m$(2), k
                    NEXT
                    COLOR _RGB32(255)
                    IF totalMatches > 1 THEN
                        printLarge (_WIDTH - printWidthLarge(m$(1), k)) / 2, (_HEIGHT - fontHeightLarge(k)) / 2 - fontHeightLarge(k), m$(1), k
                    END IF
                    printLarge (_WIDTH - printWidthLarge(m$(2), k)) / 2, (_HEIGHT - fontHeightLarge(k)) / 2, m$(2), k
                CASE 8 'score increase
                    DIM a AS SINGLE
                    animation(8).x = lerp(animation(8).x, printWidthLarge(STR$(visibleScore), 6) / 2, .06)
                    animation(8).y = lerp(animation(8).y, 45, .06)
                    a = dist(animation(8).x, animation(8).y, printWidthLarge(STR$(visibleScore), 6) / 2, 45)
                    IF a <= 30 THEN
                        animation(8).start = 0
                    END IF
                    a = map(a, 0, animation(8).ya, 0, 1024)
                    COLOR _RGB32(animation(8).r, animation(8).g, animation(8).b, a)
                    printLarge 2 + animation(8).x, 2 + animation(8).y, LTRIM$(STR$(animation(8).xa)), 4
                    COLOR _RGB32(255, a)
                    printLarge animation(8).x, animation(8).y, LTRIM$(STR$(animation(8).xa)), 4
            END SELECT
        END IF
    NEXT
END SUB

SUB saveGame
    SHARED score AS _UNSIGNED LONG, highscore AS _UNSIGNED LONG
    SHARED level AS _UNSIGNED LONG
    SHARED gameOver AS _BYTE
    SHARED peg() AS object
    SHARED music AS _BYTE, sfx AS _BYTE

    DIM i AS INTEGER

    OPEN "tictactoering.dat" FOR BINARY AS #1
    DIM signature AS STRING
    signature = "tttring"
    PUT #1, 1, signature
    PUT #1, , music
    PUT #1, , sfx
    PUT #1, , score
    PUT #1, , highscore
    PUT #1, , level
    PUT #1, , gameOver
    FOR i = 1 TO 12
        PUT #1, , peg(i)
    NEXT
    CLOSE #1
END SUB

SUB loadGame
    SHARED score AS _UNSIGNED LONG, highscore AS _UNSIGNED LONG
    SHARED level AS _UNSIGNED LONG
    SHARED gameOver AS _BYTE
    SHARED peg() AS object
    SHARED music AS _BYTE, sfx AS _BYTE

    DIM i AS INTEGER

    OPEN "tictactoering.dat" FOR BINARY AS #1
    IF LOF(1) THEN
        DIM signature AS STRING
        signature = SPACE$(7)
        GET #1, 1, signature
        IF signature <> "tttring" THEN
            CLOSE #1
            EXIT SUB
        END IF
        GET #1, , music
        GET #1, , sfx
        GET #1, , score
        GET #1, , highscore
        GET #1, , level
        GET #1, , gameOver

        IF gameOver = false THEN
            FOR i = 1 TO 12
                GET #1, , peg(i)
            NEXT
        ELSE
            gameOver = false
            score = 0
            level = 0
        END IF
    ELSE
        'user just upgraded from first versions?
        'retrieve their highscore and kill old file
        CLOSE #1
        IF _FILEEXISTS("tictactoering.score") THEN
            OPEN "tictactoering.score" FOR BINARY AS #1
            IF LOF(1) THEN
                GET #1, 1, score
                GET #1, , highscore
                GET #1, , level
                GET #1, , gameOver

                IF gameOver = false THEN
                    FOR i = 1 TO 12
                        GET #1, , peg(i)
                    NEXT
                ELSE
                    gameOver = false
                    score = 0
                    level = 0
                END IF
            END IF
            CLOSE #1
            KILL "tictactoering.score"
        END IF
    END IF
    CLOSE #1
END SUB

SUB addParticles (x AS SINGLE, y AS SINGLE, total AS INTEGER, c AS _UNSIGNED LONG)
    DIM addedP AS INTEGER, p AS INTEGER
    DIM a AS SINGLE
    SHARED particle() AS object

    addedP = 0: p = 0
    DO
        p = p + 1
        IF p > UBOUND(particle) THEN EXIT DO
        IF particle(p).state = true THEN _CONTINUE
        addedP = addedP + 1
        particle(p).state = true
        particle(p).x = x
        particle(p).y = y
        a = RND * _PI(2)
        particle(p).xv = COS(a) * (RND * 10)
        particle(p).yv = SIN(a) * (RND * 10)
        particle(p).r = _RED32(c)
        particle(p).g = _GREEN32(c)
        particle(p).b = _BLUE32(c)
        particle(p).size = _CEIL(RND * 3)
        particle(p).start = TIMER
        particle(p).duration = RND
    LOOP UNTIL addedP >= total
END SUB

SUB updateScore
    STATIC lastScoreUpdate AS SINGLE, lastHighScoreUpdate AS SINGLE
    SHARED visibleScore AS _UNSIGNED LONG, score AS _UNSIGNED LONG
    SHARED visibleHighScore AS _UNSIGNED LONG, highscore AS _UNSIGNED LONG
    SHARED animation() AS object, woodblock AS LONG
    SHARED sfx AS _BYTE

    IF visibleScore < score AND TIMER - lastScoreUpdate > .05 AND animation(8).start = 0 THEN
        visibleScore = visibleScore + 1
        IF woodblock > 0 AND sfx THEN _SNDPLAYCOPY woodblock
        lastScoreUpdate = TIMER
    END IF

    IF visibleHighScore < highscore AND TIMER - lastHighScoreUpdate > .05 AND animation(8).start = 0 THEN
        visibleHighScore = visibleHighScore + 1
        lastHighScoreUpdate = TIMER
    END IF
END SUB

SUB updateParticles
    DIM i AS INTEGER
    SHARED particle() AS object

    FOR i = 1 TO UBOUND(particle)
        CONST gravity = .1
        IF particle(i).state THEN
            particle(i).xv = particle(i).xv + particle(i).xa
            particle(i).x = particle(i).x + particle(i).xv
            particle(i).yv = particle(i).yv + particle(i).ya + gravity
            particle(i).y = particle(i).y + particle(i).yv

            IF particle(i).x > _WIDTH OR particle(i).x < 0 OR particle(i).y > _HEIGHT OR particle(i).y < 0 THEN
                particle(i).state = false
            ELSE
                CircleFill particle(i).x, particle(i).y, particle(i).size, _RGB32(particle(i).r, particle(i).g, particle(i).b, map(TIMER - particle(i).start, 0, particle(i).duration, 255, 0))
            END IF
        END IF
    NEXT
END SUB

SUB hoverHighlight
    SHARED peg() AS object
    SHARED emptySet$
    SHARED dragging AS INTEGER

    STATIC highLit AS INTEGER, glow AS SINGLE, glowStep AS SINGLE
    DIM halo AS INTEGER
    DIM i AS INTEGER, k AS SINGLE, j AS SINGLE

    IF dragging THEN EXIT SUB

    FOR i = 10 TO 12
        IF peg(i).set = emptySet$ THEN _CONTINUE
        IF dist(peg(i).x, peg(i).y, _MOUSEX, _MOUSEY) <= 40 THEN
            k = 0
            IF MID$(peg(i).set, 5, 2) <> MKI$(-1) THEN
                halo = 40
            ELSEIF MID$(peg(i).set, 3, 2) <> MKI$(-1) THEN
                halo = 25
            ELSE
                halo = 12
            END IF

            IF highLit <> i THEN
                highLit = i
                glow = 10
                glowStep = .2
            END IF

            IF glowStep = 0 THEN glowStep = .2
            glow = glow + glowStep
            IF glow < 8 THEN glow = 8: glowStep = glowStep * -1
            IF glow > 16 THEN glow = 16: glowStep = glowStep * -1

            FOR j = glow TO 8 STEP -.5
                k = k + .8
                CircleFill peg(i).x, peg(i).y, halo + k, _RGB32(255, j)
                CircleFill peg(i).x, peg(i).y, (halo / 2) + k, _RGB32(0, j)
            NEXT

            EXIT FOR
        END IF
    NEXT
END SUB

SUB checkAvailableMoves
    SHARED dragging AS INTEGER
    SHARED peg() AS object
    SHARED emptySet$
    SHARED gameOver AS _BYTE
    SHARED placed AS _BYTE

    DIM i AS INTEGER, j AS INTEGER, k AS INTEGER

    IF dragging = 0 THEN
        IF peg(10).set <> emptySet$ OR peg(11).set <> emptySet$ OR peg(12).set <> emptySet$ THEN
            gameOver = true 'glass is half empty; consider no more moves
            FOR i = 10 TO 12
                IF peg(i).set <> emptySet$ THEN
                    'can this set fit the board?
                    FOR j = 1 TO 9
                        placed = true
                        FOR k = 1 TO 3
                            IF CVI(MID$(peg(i).set, k * 2 - 1, 2)) > 0 AND CVI(MID$(peg(j).set, k * 2 - 1, 2)) > 0 THEN
                                placed = false
                                EXIT FOR
                            END IF
                        NEXT
                        IF placed THEN gameOver = false: EXIT FOR
                    NEXT
                END IF
                IF gameOver = false THEN EXIT FOR 'no need to test further, there's still hope
            NEXT
        END IF

        IF gameOver = false THEN
            'is board full?
            'that means we used all sets and no matches were found = game over
            DIM board$
            board$ = ""
            FOR i = 1 TO 9
                board$ = board$ + peg(i).set
            NEXT
            IF INSTR(board$, MKI$(-1)) = 0 THEN gameOver = true
        END IF
    END IF
END SUB

SUB drawRings
    DIM i AS INTEGER
    SHARED peg() AS object
    SHARED circleImage() AS LONG
    SHARED dragging AS INTEGER
    SHARED thisColor AS INTEGER

    DIM x AS SINGLE, y AS SINGLE
    DIM j AS INTEGER

    FOR i = 1 TO 12
        IF i = dragging THEN
            x = _MOUSEX
            y = _MOUSEY
        ELSE
            x = peg(i).x
            y = peg(i).y
        END IF

        FOR j = 1 TO 3
            thisColor = CVI(MID$(peg(i).set, j * 2 - 1, 2))
            IF thisColor > 0 THEN
                _PUTIMAGE (x - (_WIDTH(circleImage(thisColor, j)) / 2), y - (_HEIGHT(circleImage(thisColor, j)) / 2)), circleImage(thisColor, j)
            END IF
        NEXT
    NEXT
END SUB

SUB CircleFill (x AS LONG, y AS LONG, R AS LONG, C AS _UNSIGNED LONG)
    DIM x0 AS SINGLE, y0 AS SINGLE
    DIM e AS SINGLE

    x0 = R
    y0 = 0
    e = -R
    DO WHILE y0 < x0
        IF e <= 0 THEN
            y0 = y0 + 1
            LINE (x - x0, y + y0)-(x + x0, y + y0), C, BF
            LINE (x - x0, y - y0)-(x + x0, y - y0), C, BF
            e = e + 2 * y0
        ELSE
            LINE (x - y0, y - x0)-(x + y0, y - x0), C, BF
            LINE (x - y0, y + x0)-(x + y0, y + x0), C, BF
            x0 = x0 - 1
            e = e - 2 * x0
        END IF
    LOOP
    LINE (x - R, y)-(x + R, y), C, BF
END SUB

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

FUNCTION lerp! (start!, stp!, amt!)
    DIM mult AS INTEGER
    IF start! < stp! THEN mult = -1 ELSE mult = 1
    lerp! = (mult * amt!) * (stp! - start!) + start!
END FUNCTION

FUNCTION dist! (x1!, y1!, x2!, y2!)
    dist! = _HYPOT((x2! - x1!), (y2! - y1!))
END FUNCTION

SUB printLarge (x AS SINGLE, y AS SINGLE, text$, fontSize AS INTEGER)
    DIM i AS LONG, j AS LONG, c AS LONG, char AS _UNSIGNED _BYTE

    IF fontSize = 0 THEN fontSize = 1

    FOR c = 1 TO LEN(text$)
        char = ASC(text$, c)
        FOR i = 1 TO 16
            FOR j = 1 TO 8
                IF charSet(char, i, j) THEN
                    IF _PRINTMODE <> 2 THEN
                        LINE ((x - fontSize) + j * fontSize + ((c - 1) * (fontSize * 8)), (y - fontSize) + i * fontSize)-STEP(fontSize - 1, fontSize - 1), _DEFAULTCOLOR, BF
                    END IF
                ELSE
                    IF _PRINTMODE = 3 OR _PRINTMODE = 2 THEN
                        LINE ((x - fontSize) + j * fontSize + ((c - 1) * (fontSize * 8)), (y - fontSize) + i * fontSize)-STEP(fontSize - 1, fontSize - 1), _BACKGROUNDCOLOR, BF
                    END IF
                END IF
            NEXT
        NEXT
    NEXT
END SUB

SUB centerLarge (y AS SINGLE, text$, fontSize AS INTEGER)
    printLarge (_WIDTH - printWidthLarge(text$, fontSize)) / 2, y, text$, fontSize
END SUB

FUNCTION fontHeightLarge (fontSize AS INTEGER)
    fontHeightLarge = fontSize * 16
END FUNCTION

FUNCTION fontWidthLarge (fontSize AS INTEGER)
    fontWidthLarge = fontSize * 8
END FUNCTION

FUNCTION printWidthLarge (text$, fontSize AS INTEGER)
    printWidthLarge = fontWidthLarge(fontSize) * LEN(text$)
END FUNCTION

SUB initializeCharSetPrintLarge
    DIM char, row, column
    RESTORE charSet8x16
    FOR char = 0 TO 255
        FOR row = 1 TO 16
            FOR column = 1 TO 8
                READ charSet(char, row, column)
            NEXT
        NEXT
    NEXT

    charSet8x16:
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,-1,0,0,0,0,0,0,-1,-1,0,-1,0,0,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
    DATA -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,0,0,0,0,-1,0,0,-1,0,0,0,0,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,0,0,0,-1,-1,0,0,-1,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0
    DATA -1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1
    DATA 0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,0,0,-1,-1,-1,0,0,-1,-1,-1,0,0,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1
    DATA -1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1
    DATA 0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1
    DATA -1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0
    DATA -1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1
    DATA -1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1
    DATA -1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,0
    DATA 0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0
    DATA 0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0
    DATA -1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0
    DATA -1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1
    DATA -1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0
    DATA 0,-1,-1,0,0,0,-1,0,0,-1,-1,0,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,0,0,-1,-1,0,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0
    DATA -1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0
    DATA 0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1
    DATA -1,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0
    DATA -1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1
    DATA -1,-1,-1,-1,0,0,-1,0,-1,-1,0,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1
    DATA -1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0
    DATA 0,-1,-1,0,-1,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0
    DATA 0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1
    DATA 0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1
    DATA 0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1
    DATA 0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0
    DATA -1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1
    DATA -1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,0,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0
    DATA 0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1
    DATA 0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA -1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1
    DATA -1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0
    DATA -1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0
    DATA -1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1
    DATA -1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1
    DATA -1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1
    DATA 0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1
    DATA -1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1
    DATA -1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0
    DATA -1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,0,-1,0,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,0,0,-1,0,0,0,-1,0,-1,0,0,0,-1,0,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,0,-1,0,-1,0,-1,0,-1,-1,0,-1,0,-1,0,-1,0,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1
    DATA -1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,-1,-1,0,-1,-1,-1,0,-1,0,-1,-1,-1,0,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0
    DATA 0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1
    DATA 0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1
    DATA -1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1
    DATA -1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0
    DATA -1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0
    DATA 0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1
    DATA -1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0
    DATA -1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1
    DATA -1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1
    DATA 0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
    DATA -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1
    DATA -1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,0,0,0,-1,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1
    DATA 0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,-1,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,0,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,-1,-1,-1,-1,-1,-1,0,-1
    DATA -1,0,-1,-1,0,-1,-1,-1,-1,0,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,-1,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1
    DATA -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,-1,-1,0,-1,-1,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,0,0,0,0,-1,-1,0,0,-1,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,-1,-1,0,0,0,0,0,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,0,0,0,0,-1,-1,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,0,0,0,-1,-1,0,0,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
END SUB

SUB pause (duration AS SINGLE)
    DIM j AS SINGLE
    j = TIMER
    DO
        _DISPLAY
        _LIMIT 30
    LOOP UNTIL TIMER - j > duration OR _KEYHIT
END SUB

SUB endScreen
    SHARED gameOver AS _BYTE, keyb AS LONG
    SHARED animation() AS object, peg() AS object
    SHARED bg AS LONG, bgWithoutShelf AS LONG
    SHARED m$(), emptySet$
    SHARED userQuit AS _BYTE
    SHARED score AS _UNSIGNED LONG, visibleScore AS _UNSIGNED LONG
    SHARED level AS _UNSIGNED LONG

    DIM k AS INTEGER, i AS INTEGER

    IF gameOver OR keyb = -27 THEN
        'flash and screenshot
        DIM screenshot AS LONG, screenshot2 AS LONG
        screenshot = _COPYIMAGE(_DISPLAY)

        animation(0).start = TIMER
        DO
            DIM screenshotSize AS INTEGER, zoomOut AS INTEGER
            zoomOut = 200
            screenshotSize = map(TIMER - animation(0).start, 0, .5, _WIDTH, _WIDTH - zoomOut)
            IF screenshotSize < _WIDTH - zoomOut THEN screenshotSize = _WIDTH - zoomOut
            CLS
            _PUTIMAGE (0, 0), bgWithoutShelf
            _PUTIMAGE ((_WIDTH - screenshotSize) / 2, 0)-STEP(screenshotSize, screenshotSize), screenshot
            IF TIMER - animation(0).start < .3 THEN
                LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - animation(0).start, 0, .3, 0, 255)), BF
            END IF
            updateParticles
            _DISPLAY
            _LIMIT 60
        LOOP UNTIL TIMER - animation(0).start > .75

        IF gameOver THEN
            m$(1) = "Game Over"
            COLOR _RGB32(255)
            k = 4
            printLarge (_WIDTH - printWidthLarge(m$(1), k)) / 2, _HEIGHT - fontHeightLarge(k) * 2.5, m$(1), k
        END IF

        screenshot2 = _COPYIMAGE(_DISPLAY)

        'end screen buttons
        SHARED currentButton AS INTEGER
        SHARED totalButtons AS INTEGER
        SHARED button() AS object, caption() AS STRING

        currentButton = 0
        totalButtons = 2
        FOR i = 1 TO 2
            button(i).h = _FONTHEIGHT + 10
            button(i).w = _PRINTWIDTH("  Continue  ")
        NEXT

        DIM startX AS INTEGER
        startX = (_WIDTH - button(1).w * totalButtons) / 2
        FOR i = 1 TO totalButtons
            button(i).y = _HEIGHT - fontHeightLarge(3) * 2
            button(i).x = startX
            startX = startX + button(i).w
        NEXT

        IF gameOver THEN
            caption(1) = "Restart"
            caption(2) = "Quit"
        ELSE
            caption(1) = "Continue"
            caption(2) = "Restart"
        END IF

        DO
            SHARED mainTrackVolume AS SINGLE, track() AS LONG, music AS _BYTE
            IF music THEN
                IF mainTrackVolume < 1 THEN
                    mainTrackVolume = mainTrackVolume + .05
                    IF track(1) > 0 THEN _SNDVOL track(1), mainTrackVolume
                END IF
            END IF

            keyb = _KEYHIT
            WHILE _MOUSEINPUT: WEND
            DIM mx AS INTEGER, my AS INTEGER
            mx = _MOUSEX
            my = _MOUSEY

            _PUTIMAGE (0, 0), screenshot2
            doButtons
            DIM mouseDown AS _BYTE
            checkButtons

            DIM prevbt AS INTEGER
            IF currentButton <> prevbt THEN
                SHARED selectSound AS LONG, sfx AS _BYTE
                IF currentButton > 0 AND sfx AND selectSound > 0 THEN _SNDPLAYCOPY selectSound
                prevbt = currentButton
            END IF

            SELECT CASE keyb
                CASE 19200 'left
                    currentButton = 1
                CASE 19712 'right
                    currentButton = 2
                CASE -13
                    mouseDown = true
                CASE -27
                    EXIT DO
            END SELECT

            IF _MOUSEBUTTON(1) THEN
                mouseDown = true
            ELSE
                IF mouseDown THEN
                    SELECT CASE currentButton
                        CASE 1
                            keyb = -121
                            EXIT DO
                        CASE 2
                            keyb = -110
                            EXIT DO
                    END SELECT
                    addParticles mx, my, 30, _RGB32(255)
                    addParticles mx, my, 30, _RGB32(122, 89, 144)
                END IF
                mouseDown = false
            END IF

            updateParticles

            userQuit = _EXIT
            _DISPLAY
            _LIMIT 30
        LOOP UNTIL keyb = -13 OR keyb = -27 OR keyb = -110 OR keyb = -78 OR keyb = -121 OR keyb = -89 OR userQuit

        IF (gameOver AND (keyb = -110 OR keyb = -78)) OR userQuit THEN SYSTEM

        IF (gameOver AND (keyb = -13 OR keyb = -121 OR keyb = -89)) OR (gameOver = false AND (keyb = -110 OR keyb = -78)) THEN
            IF track(1) > 0 AND music THEN _SNDSTOP track(1): _SNDLOOP track(1) 'restart main track
            gameOver = false
            score = 0
            visibleScore = 0
            level = 0
            animation(0).start = TIMER
            FOR i = 1 TO 12
                peg(i).set = emptySet$
            NEXT
        ELSE
            'bring screenshot back to front
            animation(0).start = TIMER
            DO
                zoomOut = 200
                screenshotSize = map(TIMER - animation(0).start, 0, .5, _WIDTH - zoomOut, _WIDTH)
                IF screenshotSize > _WIDTH THEN screenshotSize = _WIDTH
                CLS
                _PUTIMAGE (0, 0), bgWithoutShelf
                _PUTIMAGE ((_WIDTH - screenshotSize) / 2, 0)-STEP(screenshotSize, screenshotSize), screenshot
                IF TIMER - animation(0).start <= .3 THEN
                    LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - animation(0).start, 0, .3, 0, 255)), BF
                END IF
                _DISPLAY
                _LIMIT 60
            LOOP UNTIL TIMER - animation(0).start > .5
        END IF

        _FREEIMAGE screenshot
        _FREEIMAGE screenshot2
        _KEYCLEAR
        currentButton = 0
    END IF
END SUB

SUB settingsScreen
    SHARED gameOver AS _BYTE, keyb AS LONG
    SHARED animation() AS object, peg() AS object
    SHARED bg AS LONG, bgWithoutShelf AS LONG
    SHARED m$(), emptySet$
    SHARED userQuit AS _BYTE
    SHARED score AS _UNSIGNED LONG, visibleScore AS _UNSIGNED LONG
    SHARED level AS _UNSIGNED LONG

    'flash and screenshot
    DIM screenshot AS LONG
    screenshot = _COPYIMAGE(_DISPLAY)

    animation(0).start = TIMER
    DO
        DIM screenshotSize AS INTEGER, zoomOut AS INTEGER
        zoomOut = 400
        screenshotSize = map(TIMER - animation(0).start, 0, .5, _WIDTH, _WIDTH - zoomOut)
        IF screenshotSize < _WIDTH - zoomOut THEN screenshotSize = _WIDTH - zoomOut
        CLS
        _PUTIMAGE (0, 0), bgWithoutShelf
        _PUTIMAGE (0, (_HEIGHT - screenshotSize) / 2)-STEP(screenshotSize, screenshotSize), screenshot
        IF TIMER - animation(0).start < .3 THEN
            LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - animation(0).start, 0, .3, 0, 255)), BF
        END IF

        updateParticles
        _DISPLAY
        _LIMIT 60
    LOOP UNTIL TIMER - animation(0).start > .75

    SHARED button() AS object
    SHARED caption() AS STRING
    SHARED totalButtons AS INTEGER
    SHARED currentButton AS INTEGER

    'settings buttons
    SHARED music AS _BYTE, sfx AS _BYTE
    DIM i AS INTEGER
    currentButton = 0
    totalButtons = 4
    FOR i = 1 TO totalButtons - 1
        button(i).h = _FONTHEIGHT + 10
        button(i).w = _PRINTWIDTH("  ENOUGH WIDTH FOR ALL CHOICES  ")
    NEXT

    caption(3) = "Return to game"

    DIM startY AS INTEGER
    startY = (_HEIGHT - button(1).h * totalButtons - 1) / 2
    FOR i = 1 TO totalButtons - 1
        button(i).y = startY
        button(i).x = _WIDTH - _WIDTH / 3 - button(i).w / 2
        startY = startY + button(i).h
    NEXT

    button(4).x = 0
    button(4).y = (_HEIGHT - screenshotSize) / 2
    button(4).w = screenshotSize
    button(4).h = screenshotSize

    DO
        CLS
        _PUTIMAGE (0, 0), bgWithoutShelf
        _PUTIMAGE (0, (_HEIGHT - screenshotSize) / 2)-STEP(screenshotSize, screenshotSize), screenshot

        DIM mx AS INTEGER, my AS INTEGER
        WHILE _MOUSEINPUT: WEND
        mx = _MOUSEX
        my = _MOUSEY
        keyb = _KEYHIT
        userQuit = _EXIT

        IF music THEN
            caption(1) = "Music: ON"
        ELSE
            caption(1) = "Music: OFF"
        END IF

        IF sfx THEN
            caption(2) = "Sound effects: ON"
        ELSE
            caption(2) = "Sound effects: OFF"
        END IF

        doButtons
        DIM mouseDown AS _BYTE
        checkButtons

        DIM prevbt AS INTEGER
        IF currentButton <> prevbt THEN
            SHARED selectSound AS LONG
            IF currentButton > 0 AND sfx AND selectSound > 0 THEN _SNDPLAYCOPY selectSound
            prevbt = currentButton
        END IF

        SELECT CASE keyb
            CASE 18432 'up
                currentButton = currentButton - 1
                IF currentButton < 1 THEN currentButton = 1
            CASE 20480 'down
                currentButton = currentButton + 1
                IF currentButton > totalButtons THEN currentButton = totalButtons
            CASE 19200 'left
                IF currentButton < 4 THEN currentButton = 4
            CASE 19712 'right
                IF currentButton = 4 THEN currentButton = 1
            CASE -13
                mouseDown = true
                IF currentButton > 0 THEN
                    mx = button(currentButton).x + button(currentButton).w / 2
                    my = button(currentButton).y + button(currentButton).h / 2
                END IF
            CASE -27
                EXIT DO
        END SELECT

        IF _MOUSEBUTTON(1) THEN
            mouseDown = true
        ELSE
            IF mouseDown THEN
                SELECT CASE currentButton
                    CASE 1
                        music = NOT music
                        SHARED track() AS LONG
                        IF track(1) > 0 AND music THEN _SNDLOOP track(1)
                        IF track(1) > 0 AND music = false THEN _SNDSTOP track(1)
                    CASE 2
                        sfx = NOT sfx
                        SHARED wooshSound AS LONG
                        IF wooshSound > 0 AND sfx THEN _SNDPLAYCOPY wooshSound
                    CASE 3, 4
                        EXIT DO
                END SELECT
                addParticles mx, my, 30, _RGB32(255)
                addParticles mx, my, 30, _RGB32(67, 172, 183)
            END IF
            mouseDown = false
        END IF

        'game title
        COLOR _RGB32(0)
        centerLarge (_HEIGHT / 7) + 3, "Settings", 4
        centerLarge (_HEIGHT - _HEIGHT / 4) - fontHeightLarge(2) + 3, "Tic Tac Toe", 2
        centerLarge (_HEIGHT - _HEIGHT / 4) + 3, "Rings", 7

        COLOR _RGB32(255)
        centerLarge (_HEIGHT / 7), "Settings", 4
        centerLarge (_HEIGHT - _HEIGHT / 4) - fontHeightLarge(2), "Tic Tac Toe", 2
        centerLarge (_HEIGHT - _HEIGHT / 4), "Rings", 7

        updateParticles

        _DISPLAY
        _LIMIT 30
    LOOP UNTIL userQuit

    IF (gameOver AND (keyb = -110 OR keyb = -78)) OR userQuit THEN SYSTEM

    'bring screenshot back to front
    animation(0).start = TIMER
    DO
        zoomOut = 200
        screenshotSize = map(TIMER - animation(0).start, 0, .5, _WIDTH - zoomOut, _WIDTH)
        IF screenshotSize > _WIDTH THEN screenshotSize = _WIDTH
        CLS
        _PUTIMAGE (0, 0), bgWithoutShelf
        _PUTIMAGE (0, (_HEIGHT - screenshotSize) / 2)-STEP(screenshotSize, screenshotSize), screenshot
        IF TIMER - animation(0).start <= .3 THEN
            LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(255, map(TIMER - animation(0).start, 0, .3, 0, 255)), BF
        END IF
        _DISPLAY
        _LIMIT 60
    LOOP UNTIL TIMER - animation(0).start > .5

    _FREEIMAGE screenshot
    _KEYCLEAR
    currentButton = 0
END SUB

SUB createMainScreenButtons
    SHARED totalButtons AS INTEGER
    SHARED caption() AS STRING
    SHARED button() AS object
    SHARED currentButton AS INTEGER

    totalButtons = 1
    caption(1) = "Settings"
    button(1).h = _FONTHEIGHT + 10
    button(1).w = _PRINTWIDTH(caption(1) + "    ")
    button(1).y = _HEIGHT - button(1).h - 1
    button(1).x = _WIDTH - button(1).w - 1

    'caption(2) = CHR$(221) + CHR$(222)
    'button(2).h = _FONTHEIGHT + 10
    'button(2).w = _PRINTWIDTH(caption(2) + "    ")
    'button(2).y = 0
    'button(2).x = button(1).x - button(2).w
END SUB

SUB doButtons
    SHARED totalButtons AS INTEGER
    SHARED caption() AS STRING
    SHARED button() AS object
    SHARED currentButton AS INTEGER
    DIM i AS INTEGER

    FOR i = 1 TO totalButtons
        LINE (button(i).x, button(i).y)-STEP(button(i).w, button(i).h), _RGB32(255), B
        IF i = currentButton THEN
            LINE (button(currentButton).x, button(currentButton).y)-STEP(button(currentButton).w, button(currentButton).h), _RGB32(255, 80), BF
            COLOR _RGB32(0)
            DIM shadowDepth AS INTEGER
            shadowDepth = 2
            _PRINTSTRING (button(i).x + (button(i).w - _PRINTWIDTH(caption(i))) / 2 + shadowDepth, button(i).y + button(i).h / 2 - _FONTHEIGHT / 2 + shadowDepth), caption(i)
        END IF
        COLOR _RGB32(255)
        _PRINTSTRING (button(i).x + (button(i).w - _PRINTWIDTH(caption(i))) / 2, button(i).y + button(i).h / 2 - _FONTHEIGHT / 2), caption(i)
    NEXT
END SUB

SUB checkButtons
    SHARED totalButtons AS INTEGER
    SHARED caption() AS STRING
    SHARED button() AS object
    SHARED currentButton AS INTEGER
    DIM i AS INTEGER
    STATIC lastMouseX AS INTEGER, lastMouseY AS INTEGER

    IF _MOUSEX <> lastMouseX OR _MOUSEY <> lastMouseY THEN
        lastMouseX = _MOUSEX
        lastMouseY = _MOUSEY

        currentButton = 0
        FOR i = 1 TO totalButtons
            IF _MOUSEX > button(i).x AND _MOUSEX < button(i).x + button(i).w AND _MOUSEY > button(i).y AND _MOUSEY < button(i).y + button(i).h THEN
                currentButton = i
                EXIT FOR
            END IF
        NEXT
    END IF
END SUB
