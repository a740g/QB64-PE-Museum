'Cloned Shades - by @FellippeHeitor - fellippeheitor@gmail.com
'
'(a clone of 'Shades' which was originally developed by
'UOVO - http://www.uovo.dk/ - for iOS)
'
'The goal of this game is to use the arrow keys to choose where
'to lay the next block falling down. If you align 4 blocks of
'the same color shade horizontally, you erase a line. If you
'pile two identical blocks, they will merge to become darker,
'unless they are already the darkest shade available (of 5).
'
'It has a tetris feeling to it, but it's not tetris at all.
'
'The idea is not original, since it's a clone, but I coded it
'from the ground up.
'
'Changes:
'- Beta 1
'       - So far I got the game to work, but I'm running into issues
'         trying to show scores on the screen, mainly because I relied
'         on POINT to check whether I could move blocks down or not.
'       - There's no interface except for the actual gameboard.
'
'- Beta 2
'       - Been discarded. At some point everything was working well but
'         I managed to screw it all up, to the point I made the decision
'         to go back to beta 1 and start over. I like to mention it here
'         because even failure can teach you a lesson, and this one is
'         not one to forget.
'
'- Beta 3
'       - Converted all audio files to .OGG for smaller files and faster
'         loading.
'       - Game window now has an appropriate icon, generated at runtime.
'       - Block movement has been coded again, and now it doesn't rely
'         on POINT to detect blocks touching each other, but it actually
'         evaluates the current Y position. Like it should have been from
'         the start, to be honest.
'       - Redone the merge animation. Still looks the same, but it had to
'         be redone after the new movement routines have been implemented.
'       - Added a background image to the game board ("bg.png"), but uses
'         a gray background in case it cannot be loaded for some reason.
'       - Code is a bit easier to read, after I moved most of the main
'         loop code into separate subroutines.
'       - SCORES ON THE SCREEN!
'
' - Beta 4
'       - Adaptative resolution when the desktop isn't at least 900px tall.
'       - New shades, which are alternated every time a new game is started.
'       - Visual intro, mimicking the original game's.
'       - Improved game performance by selectively limiting the layering of
'         images in SUB UpdateScreen.
'       - Added a "danger mode" visual indication, by turning on a TIMER that
'         overlays a shade of red over the game play, similar to a security
'         alarm.
'       - Added a menu to start the game or change setting or leave.
'       - Settings are now saved to "shades.dat", and include switches for
'         sound and music, as well as a highscore.
'       - Added an end screen, that shows the score, number of merges and
'         number of lines destroyed during game.
'
' - Beta 5
'       - Fixed game starting with the blocks that were put during the menu
'         demonstration.
'       - Fixed the 'danger' warning coming back from the previous game.
'       - Added an option to select shades (GREEN, ORANGE, BLUE, PINK) or
'         to have it AUTOmatically rotate everytime you start the game.
'         (thanks to Clippy for suggesting it)
'       - Added a confirmation message before clearing highscore.
'       - Added a confirmation message before closing the game with ESC.
'       - Fixed a bug with page _DEST that caused scores to be put in
'         OverlayGraphics page instead of InfoScreen while InDanger
'         triggered the ShowAlert sub.
'
' - Beta 6
'       - ESC during the game shows a menu asking user to confirm QUIT or
'         RESUME. The previous behaviour (in beta 5) was to quit to main
'         menu after ESC was hit twice. Now ESC is interpreted as 'oops,
'         I didn't mean to hit ESC'.
'       - A new sound for when a line is destroyed ("line.ogg"); "wind.ogg"
'         is no longer used/needed.
'       - Added a sound to the game over screen ("gameover.ogg").
'       - Fixed menu alignment issues when showing disabled choices.
'       - Changed code to selectively NOT do what can't be done in MAC OS X
'         (so that now we can compile in MAC OS X, tested in El Capitan).
'       - Three lines of code changed to make the code backward compatible
'         with QB64 v0.954 (SDL): BackgroundColor goes back to being a shared
'         LONG instead of a CONST (since SDL won't allow _RGB32 in a CONST)
'         and inside SUB CheckMerge we no longer clear the background using
'         a patch from BgImage using _PUTIMAGE with STEP. Turns out the bug
'         was in QB64, not in my code.
'
' - Beta 7
'       - Fixed a bug that prevented the end screen to be shown because of
'         the InDanger timer still being on.
'       - Added three levels of difficulty, which affect gravity.
'       - Since speed is different, a new soundtrack was added for faster
'         modes ("Crowd_Hammer.ogg" and "Upbeat_Forever.ogg")
'       - Added FILL mode (thanks to Pete for the suggestion), in which instead
'         of an infinite game your goal is to fill the screen with blocks,
'         avoiding merges at all costs, since they make you lose points (which
'         is indicated by a "shock.ogg" sound and visual warning.
'       - Added a new parameter to FUNCTION Menu, Info(), that holds descriptions
'         for menu items. The goal is to be able to show highscores even
'         before starting a game.
'       - Clicking and dragging emulates keystrokes, allowing basic mouse
'         controls (code courtesy of Steve McNeill - Thanks again!)
'
' - Version 1.0
'       - Fixed: Disabling music through settings didn't stop the music. Duh.
'       - Fixed: Shock sound during Fill mode sounded weird because it was being
'         played inside the animation loop, and not once, before animation.
'       - Fixed: BgMusic selection while in Fill mode.
'       - Added: If player takes more than 3 seconds to choose a game mode,
'         a brief description is shown on the screen.
'       - Added: Quick end screen animation.
'       - Countdown to game start with "GET READY" on the screen.
'
$EXEICON:'./shades.ico'
'Game constants -------------------------------------------------------
'General Use:
CONST False = 0
CONST True = NOT False

'Game definitions:
CONST BlockWidth = 150
CONST BlockHeight = 64
CONST ZENINCREMENT = 1
CONST NORMALINCREMENT = 5
CONST FLASHINCREMENT = 10
CONST ZENMODE = 1
CONST NORMALMODE = 2
CONST FLASHMODE = 3
CONST FILLMODE = 4

'Animations:
CONST TopAnimationSteps = 15
CONST MergeSteps = 32

'Colors:
CONST MaxShades = 4

'Menu actions:
CONST PLAYGAME = 3
CONST PLAYFILL = 4
CONST SETTINGSMENU = 5
CONST LEAVEGAME = 7
CONST SWITCHSOUND = 1
CONST SWITCHMUSIC = 2
CONST COLORSWITCH = 3
CONST RESETHIGHSCORES = 4
CONST MAINMENU = 5

'Misc:
CONST FileID = "CLONEDSHADES"

'Type definitions: ----------------------------------------------------
TYPE ColorRGB
    R AS LONG
    G AS LONG
    B AS LONG
END TYPE

TYPE BoardType
    State AS LONG
    Shade AS LONG
END TYPE

TYPE SettingsFile
    ID AS STRING * 13 '   CLONEDSHADES + CHR$(# of the latest version/beta with new .dat format)
    ColorMode AS LONG '0 = Automatic, 1 = Green, 2 = Orange, 3 = Blue, 4 = Pink
    SoundOn AS _BYTE
    MusicOn AS _BYTE
    HighscoreZEN AS LONG
    HighscoreNORMAL AS LONG
    HighscoreFLASH AS LONG
    HighscoreFILL AS LONG
END TYPE

'Variables ------------------------------------------------------------
'Variables for game control:
DIM SHARED Board(1 TO 12, 1 TO 4) AS BoardType
DIM SHARED Shades(1 TO 5) AS ColorRGB, FadeStep AS LONG
DIM SHARED BlockPos(1 TO 4) AS LONG
DIM SHARED BlockRows(1 TO 12) AS LONG, BgImage AS LONG
DIM SHARED i AS LONG, Increment AS LONG
DIM SHARED CurrentRow AS LONG, CurrentColumn AS LONG
DIM SHARED BlockPut AS _BIT, Y AS LONG, PrevY AS LONG
DIM SHARED CurrentShade AS LONG, NextShade AS LONG
DIM SHARED AlignedWithRow AS _BIT, InDanger AS _BIT
DIM SHARED GameOver AS _BIT, GameEnded AS _BIT
DIM SHARED PreviousScore AS LONG, Score AS LONG
DIM SHARED GlobalShade AS LONG, DemoMode AS _BIT
DIM SHARED AlertTimer AS LONG, TotalMerges AS LONG
DIM SHARED TotalLines AS LONG, Setting AS LONG
DIM SHARED InGame AS _BYTE, InitialIncrement AS LONG
DIM SHARED GameMode AS _BYTE, InWatchOut AS _BIT

'Variables for screen pages:
DIM SHARED InfoScreen AS LONG
DIM SHARED OverlayGraphics AS LONG
DIM SHARED GameScreen AS LONG
DIM SHARED MenuTip AS LONG
DIM SHARED MainScreen AS LONG
DIM SHARED UIWidth AS LONG
DIM SHARED UIHeight AS LONG

'Variable for sound:
DIM SHARED DropSound(1 TO 3) AS LONG, Alarm AS LONG
DIM SHARED LineSound AS LONG, SplashSound(1 TO 4) AS LONG, Whistle AS LONG
DIM SHARED BgMusic(1 TO 4) AS LONG, GameOverSound AS LONG
DIM SHARED ShockSound AS LONG

'Other variables
DIM SHARED InMenu AS _BIT, QuitGame AS _BIT
DIM SHARED Settings AS SettingsFile
DIM SHARED BackgroundColor AS LONG
DIM SettingChoice AS LONG

'Screen initialization: ------------------------------------------------
'Default window size is 600x800. If the desktop resolution is smaller
'than 900px tall, resize the UI while keeping the aspect ratio.
UIWidth = 600
UIHeight = 800
IF INSTR(_OS$, "WIN") THEN
    IF _HEIGHT(_SCREENIMAGE) < 900 THEN
        UIHeight = _HEIGHT(_SCREENIMAGE) - 150
        UIWidth = UIHeight * .75
    END IF
END IF

InfoScreen = _NEWIMAGE(300, 400, 32)
OverlayGraphics = _NEWIMAGE(150, 200, 32)
GameScreen = _NEWIMAGE(600, 800, 32)
MainScreen = _NEWIMAGE(UIWidth, UIHeight, 32)

BgImage = _LOADIMAGE("bg.png", 32)
IF BgImage < -1 THEN _DONTBLEND BgImage

BackgroundColor = _RGB32(170, 170, 170)

SCREEN MainScreen

_TITLE "Cloned Shades"

IF BgImage < -1 THEN _PUTIMAGE , BgImage, MainScreen

'Coordinates for block locations in the board: ------------------------
RESTORE BlockPositions
FOR i = 1 TO 4
    READ BlockPos(i)
NEXT i

RESTORE RowCoordinates
FOR i = 1 TO 12
    READ BlockRows(i)
NEXT i

InDanger = False
GameOver = False
GameEnded = False

'Read settings from file "shades.dat", if it exists: ------------------
IF _FILEEXISTS("shades.dat") THEN
    OPEN "shades.dat" FOR BINARY AS #1
    GET #1, , Settings
    CLOSE #1
END IF

IF Settings.ID <> FileID + CHR$(7) THEN
    'Invalid settings file or file doesn't exist: use defaults
    Settings.ID = FileID + CHR$(7)
    Settings.ColorMode = 0
    Settings.SoundOn = True
    Settings.MusicOn = True
    Settings.HighscoreZEN = 0
    Settings.HighscoreNORMAL = 0
    Settings.HighscoreFLASH = 0
    Settings.HighscoreFILL = 0
END IF

'RGB data for shades: --------------------------------------------------
SelectGlobalShade

'Since now we already have read the shades' rgb data,
'let's generate the window icon (Windows only):
IF INSTR(_OS$, "WIN") THEN MakeIcon

PrepareIntro

'Load sounds: ---------------------------------------------------------
LoadAssets

Intro

NextShade = _CEIL(RND * 3) 'Randomly chooses a shade for the next block

AlertTimer = _FREETIMER
ON TIMER(AlertTimer, .005) ShowAlert
TIMER(AlertTimer) OFF

_DEST GameScreen
IF BgImage < -1 THEN _PUTIMAGE , BgImage, GameScreen ELSE CLS , BackgroundColor
UpdateScreen

RANDOMIZE TIMER

'Main game loop: ------------------------------------------------------
DO
    _KEYCLEAR 'Clears keyboard buffer to avoid unwanted ESCs - Thanks, Steve.
    SelectGlobalShade
    ERASE Board
    InitialIncrement = 1
    REDIM Choices(1 TO 7) AS STRING
    REDIM Info(1 TO 7) AS STRING
    REDIM Tips(1 TO 7) AS LONG
    REDIM Tip(1 TO 8) AS STRING

    Choices(1) = "Cloned Shades" + CHR$(0)
    Choices(2) = " " + CHR$(0)
    Choices(3) = "Classic Mode"
    HighestOfHighest = Settings.HighscoreZEN
    IF Settings.HighscoreNORMAL > HighestOfHighest THEN HighestOfHighest = Settings.HighscoreNORMAL
    IF Settings.HighscoreFLASH > HighestOfHighest THEN HighestOfHighest = Settings.HighscoreFLASH
    IF HighestOfHighest > 0 THEN Info(3) = "Best: " + TRIM$(HighestOfHighest)
    Tips(3) = _NEWIMAGE(320, 130, 32)
    _DEST Tips(3)
    LINE (0, 0)-(319, 129), _RGBA32(255, 255, 255, 235), BF
    LINE (0, 0)-(319, 129), _RGB32(0, 0, 0), B
    Tip(1) = "Your goal in Classic Mode is to make"
    Tip(2) = "as many points as you can by merging"
    Tip(3) = "same color blocks and by creating"
    Tip(4) = "lines of four blocks of the same shade."
    Tip(5) = "There are three different skills to"
    Tip(6) = "choose from: ZEN, NORMAL and FLASH."
    Tip(8) = "Can you believe your eyes?"
    FOR i = 1 TO UBOUND(Tip)
        IF LEN(Tip(i)) THEN PrintShadow _WIDTH(Tips(3)) \ 2 - _PRINTWIDTH(Tip(i)) \ 2, (i - 1) * _FONTHEIGHT, Tip(i), _RGB32(0, 0, 0)
    NEXT i
    _DEST GameScreen

    Choices(4) = "Fill Mode"
    IF Settings.HighscoreFILL > 0 THEN Info(4) = "Best: " + TRIM$(Settings.HighscoreFILL)
    Tips(4) = _NEWIMAGE(400, 130, 32)
    _DEST Tips(4)
    LINE (0, 0)-(399, 129), _RGBA32(255, 255, 255, 235), BF
    LINE (0, 0)-(399, 129), _RGB32(0, 0, 0), B
    Tip(1) = "In Fill Mode you have to tweak your brain"
    Tip(2) = "to do the opposite of what you did in Classic:"
    Tip(3) = "now it's time to pile blocks up and avoid"
    Tip(4) = "merging them at all costs. If you happen"
    Tip(5) = "to forget your goal and end up connecting"
    Tip(6) = "them, an electric response is triggered."
    Tip(8) = "Do you have what it takes?"
    FOR i = 1 TO UBOUND(Tip)
        IF LEN(Tip(i)) THEN PrintShadow _WIDTH(Tips(4)) \ 2 - _PRINTWIDTH(Tip(i)) \ 2, (i - 1) * _FONTHEIGHT, Tip(i), _RGB32(0, 0, 0)
    NEXT i
    _DEST GameScreen

    Choices(5) = "Settings"
    Choices(6) = " " + CHR$(0)
    Choices(7) = "Quit"

    IF Settings.MusicOn AND BgMusic(1) THEN _SNDVOL BgMusic(1), .2: _SNDLOOP BgMusic(1)
    Choice = Menu(3, 7, Choices(), Info(), Tips(), 3)
    SELECT CASE Choice
        CASE PLAYGAME
            REDIM Choices(1 TO 6) AS STRING
            REDIM Info(1 TO 6) AS STRING
            REDIM Tips(1 TO 6) AS LONG

            Choices(1) = "SKILLS" + CHR$(0)
            Choices(2) = "Zen"
            IF Settings.HighscoreZEN > 0 THEN Info(2) = "Best: " + TRIM$(Settings.HighscoreZEN)
            Choices(3) = "Normal"
            IF Settings.HighscoreNORMAL > 0 THEN Info(3) = "Best: " + TRIM$(Settings.HighscoreNORMAL)
            Choices(4) = "Flash"
            IF Settings.HighscoreFLASH > 0 THEN Info(4) = "Best: " + TRIM$(Settings.HighscoreFLASH)
            Choices(5) = " " + CHR$(0)
            Choices(6) = "Go back"

            GameMode = 1 'Default = Zen mode
            SELECT CASE Menu(2, 6, Choices(), Info(), Tips(), 3)
                CASE 2: GameMode = ZENMODE: InitialIncrement = ZENINCREMENT
                CASE 3: GameMode = NORMALMODE: InitialIncrement = NORMALINCREMENT
                CASE 4: GameMode = FLASHMODE: InitialIncrement = FLASHINCREMENT
                CASE 6: GameEnded = True
            END SELECT

            ERASE Board
            Score = 0
            PreviousScore = -1
            TotalMerges = 0
            TotalLines = 0
            NextShade = _CEIL(RND * 3)
            RedrawBoard

            IF Settings.MusicOn AND BgMusic(1) THEN _SNDSTOP BgMusic(1)
            IF NOT GameEnded THEN ShowGetReady 3
            IF Settings.MusicOn AND BgMusic(GameMode) THEN _SNDVOL BgMusic(GameMode), .3: _SNDLOOP BgMusic(GameMode)

            InDanger = False
            InGame = True
            DO WHILE NOT GameOver AND NOT GameEnded
                GenerateNewBlock
                MoveBlock
                CheckDanger
                CheckMerge
                CheckConnectedLines
            LOOP
            InGame = False
            IF BgMusic(GameMode) THEN _SNDSTOP BgMusic(GameMode)
            IF BgMusic(4) THEN _SNDSTOP BgMusic(4)
            IF GameOver THEN
                IF Settings.SoundOn AND GameOverSound THEN _SNDPLAYCOPY GameOverSound
                SELECT CASE GameMode
                    CASE ZENMODE: IF Settings.HighscoreZEN < Score THEN Settings.HighscoreZEN = Score
                    CASE NORMALMODE: IF Settings.HighscoreNORMAL < Score THEN Settings.HighscoreNORMAL = Score
                    CASE FLASHMODE: IF Settings.HighscoreFLASH < Score THEN Settings.HighscoreFLASH = Score
                END SELECT
                ShowEndScreen
            END IF
            GameOver = False
            GameEnded = False
        CASE PLAYFILL
            'Fill mode is actually just a hack. We play in ZENMODE conditions, but the points are
            'calculated differently. Also, DANGER mode displays a different message/color warning.
            GameMode = FILLMODE
            InitialIncrement = ZENINCREMENT

            ERASE Board
            Score = 0
            PreviousScore = -1
            TotalMerges = 0
            TotalLines = 0
            NextShade = _CEIL(RND * 3)
            RedrawBoard

            IF Settings.MusicOn AND BgMusic(1) THEN _SNDSTOP BgMusic(1)
            ShowGetReady 3
            IF Settings.MusicOn AND BgMusic(ZENMODE) THEN _SNDVOL BgMusic(ZENMODE), .3: _SNDLOOP BgMusic(ZENMODE)

            InDanger = False
            InGame = True
            IF Settings.MusicOn AND BgMusic(ZENMODE) THEN
                IF BgMusic(1) THEN _SNDSTOP BgMusic(1)
                _SNDVOL BgMusic(ZENMODE), .3: _SNDLOOP BgMusic(ZENMODE)
            END IF
            DO WHILE NOT GameOver AND NOT GameEnded
                GenerateNewBlock
                MoveBlock
                CheckDanger
                CheckMerge
                CheckConnectedLines
            LOOP
            InGame = False
            IF BgMusic(ZENMODE) THEN _SNDSTOP BgMusic(ZENMODE)
            IF BgMusic(4) THEN _SNDSTOP BgMusic(4)
            IF GameOver THEN
                IF Settings.SoundOn AND LineSound THEN _SNDPLAYCOPY LineSound
                IF Settings.HighscoreFILL < Score THEN Settings.HighscoreFILL = Score
                ShowEndScreen
            END IF
            GameOver = False
            GameEnded = False
        CASE SETTINGSMENU
            SettingChoice = 1
            DO
                REDIM Choices(1 TO 5) AS STRING
                REDIM Info(1 TO 5) AS STRING
                REDIM Tips(1 TO 5) AS LONG
                IF Settings.SoundOn THEN Choices(1) = "Sound: ON" ELSE Choices(1) = "Sound: OFF"
                IF Settings.MusicOn THEN Choices(2) = "Music: ON" ELSE Choices(2) = "Music: OFF"
                SELECT CASE Settings.ColorMode
                    CASE 0: Choices(3) = "Color: AUTO"
                    CASE 1: Choices(3) = "Color: GREEN"
                    CASE 2: Choices(3) = "Color: ORANGE"
                    CASE 3: Choices(3) = "Color: BLUE"
                    CASE 4: Choices(3) = "Color: PINK"
                END SELECT
                Choices(4) = "Reset Highscores"
                HighestOfHighest = Settings.HighscoreZEN
                IF Settings.HighscoreNORMAL > HighestOfHighest THEN HighestOfHighest = Settings.HighscoreNORMAL
                IF Settings.HighscoreFLASH > HighestOfHighest THEN HighestOfHighest = Settings.HighscoreFLASH
                IF Settings.HighscoreFILL > HighestOfHighest THEN HighestOfHighest = Settings.HighscoreFILL
                IF HighestOfHighest = 0 THEN Choices(4) = Choices(4) + CHR$(0)

                Info(4) = "Can't be undone."
                Choices(5) = "Return"

                SettingChoice = Menu(SettingChoice, 5, Choices(), Info(), Tips(), 3)
                SELECT CASE SettingChoice
                    CASE SWITCHSOUND
                        Settings.SoundOn = NOT Settings.SoundOn
                    CASE SWITCHMUSIC
                        Settings.MusicOn = NOT Settings.MusicOn
                        IF Settings.MusicOn THEN
                            IF BgMusic(1) THEN _SNDLOOP BgMusic(1)
                        ELSE
                            IF BgMusic(1) THEN _SNDSTOP BgMusic(1)
                        END IF
                    CASE COLORSWITCH
                        Settings.ColorMode = Settings.ColorMode + 1
                        IF Settings.ColorMode > 4 THEN Settings.ColorMode = 0
                        SelectGlobalShade
                    CASE RESETHIGHSCORES
                        REDIM Choices(1 TO 2) AS STRING
                        REDIM Info(1 TO 2)
                        REDIM Tips(1 TO 2) AS LONG
                        Choices(1) = "Reset"
                        Choices(2) = "Cancel"
                        IF Menu(1, 2, Choices(), Info(), Tips(), 3) = 1 THEN
                            Settings.HighscoreZEN = 0
                            Settings.HighscoreNORMAL = 0
                            Settings.HighscoreFLASH = 0
                            Settings.HighscoreFILL = 0
                            SettingChoice = SWITCHSOUND
                        END IF
                END SELECT
            LOOP UNTIL SettingChoice = MAINMENU
        CASE LEAVEGAME
            QuitGame = True
    END SELECT
LOOP UNTIL QuitGame

ON ERROR GOTO DontSave
OPEN "shades.dat" FOR BINARY AS #1
PUT #1, , Settings
CLOSE #1

DontSave:
SYSTEM

Greens:
DATA 245,245,204
DATA 158,255,102
DATA 107,204,51
DATA 58,153,0
DATA 47,127,0

Oranges:
DATA 255,193,153
DATA 255,162,102
DATA 255,115,26
DATA 230,89,0
DATA 128,49,0

Blues:
DATA 204,229,255
DATA 128,190,255
DATA 26,138,255
DATA 0,87,179
DATA 0,50,102

Pinks:
DATA 255,179,255
DATA 255,128,255
DATA 255,26,255
DATA 179,0,178
DATA 77,0,76

BlockPositions:
DATA 0,151,302,453

RowCoordinates:
DATA 735,670,605,540,475,410,345,280,215,150,85,20

'SUBs and FUNCTIONs ----------------------------------------------------

SUB GenerateNewBlock
    DIM LineSize AS LONG
    DIM LineStart AS LONG
    DIM LineEnd AS LONG
    DIM TargetLineStart AS LONG
    DIM TargetLineEnd AS LONG
    DIM LeftSideIncrement AS LONG
    DIM RightSideIncrement AS LONG

    'Randomly chooses where the next block will start falling down
    CurrentColumn = _CEIL(RND * 4)
    CurrentShade = NextShade

    'Randomly chooses the next shade. It is done at this point so
    'that the "next" bar will be displayed correctly across the game screen.
    NextShade = _CEIL(RND * 3)

    'Block's Y coordinate starts offscreen
    Y = -48: PrevY = Y

    IF DemoMode THEN EXIT SUB

    'Animate the birth of a new block:
    IF Whistle AND Settings.SoundOn THEN
        _SNDPLAYCOPY Whistle
    END IF

    LineSize = 600
    LineStart = 0
    LineEnd = 599
    TargetLineStart = (CurrentColumn * BlockWidth) - BlockWidth
    TargetLineEnd = CurrentColumn * BlockWidth
    LeftSideIncrement = (TargetLineStart - LineStart) / TopAnimationSteps
    RightSideIncrement = (LineEnd - TargetLineEnd) / TopAnimationSteps

    FOR i = 1 TO TopAnimationSteps
        _LIMIT 120
        IF BgImage < -1 THEN _PUTIMAGE (0, 0)-(599, 15), BgImage, GameScreen, (0, 0)-(599, 15) ELSE LINE (0, 0)-(599, 15), BackgroundColor, BF
        LINE (LineStart, 0)-(LineEnd, 15), Shade&(CurrentShade), BF
        LineStart = LineStart + LeftSideIncrement
        LineEnd = LineEnd - RightSideIncrement
        IF INKEY$ <> "" THEN EXIT FOR
        UpdateScreen
    NEXT i
    IF BgImage < -1 THEN _PUTIMAGE (0, 0)-(599, 15), BgImage, GameScreen, (0, 0)-(599, 15) ELSE LINE (0, 0)-(599, 15), BackgroundColor, BF
END SUB

SUB MoveBlock
    DIM MX AS LONG, MY AS LONG, MB AS LONG 'Mouse X, Y and Button

    DIM k$

    FadeStep = 0
    Increment = InitialIncrement
    IF NOT DemoMode THEN BlockPut = False

    DO: _LIMIT 60
        'Before moving the block using Increment, check if the movement will
        'cause the block to move to another row. If so, check if such move will
        'cause to block to be put down.
        IF ConvertYtoRow(Y + Increment) <> ConvertYtoRow(Y) AND NOT AlignedWithRow THEN
            Y = BlockRows(ConvertYtoRow(Y))
            AlignedWithRow = True
        ELSE
            Y = Y + Increment
            AlignedWithRow = False
        END IF

        CurrentRow = ConvertYtoRow(Y)

        IF AlignedWithRow THEN
            IF CurrentRow > 1 THEN
                IF Board(CurrentRow - 1, CurrentColumn).State THEN BlockPut = True
            ELSEIF CurrentRow = 1 THEN
                BlockPut = True
            END IF
        END IF

        IF BlockPut THEN
            IF GameMode = FILLMODE THEN Score = Score + 5 ELSE Score = Score + 2
            DropSoundI = _CEIL(RND * 3)
            IF DropSound(DropSoundI) AND Settings.SoundOn AND NOT DemoMode THEN
                _SNDPLAYCOPY DropSound(DropSoundI)
            END IF
            Board(CurrentRow, CurrentColumn).State = True
            Board(CurrentRow, CurrentColumn).Shade = CurrentShade
        END IF

        IF Board(12, CurrentColumn).State = True AND Board(12, CurrentColumn).Shade <> Board(11, CurrentColumn).Shade THEN
            GameOver = True
            EXIT DO
        END IF

        'Erase previous block put on screen
        IF BgImage < -1 THEN
            _PUTIMAGE (BlockPos(CurrentColumn), PrevY)-(BlockPos(CurrentColumn) + BlockWidth, PrevY + Increment), BgImage, GameScreen, (BlockPos(CurrentColumn), PrevY)-(BlockPos(CurrentColumn) + BlockWidth, PrevY + Increment)
        ELSE
            LINE (BlockPos(CurrentColumn), PrevY)-(BlockPos(CurrentColumn) + BlockWidth, PrevY + Increment), BackgroundColor, BF
        END IF
        PrevY = Y

        'Show the next shade on the top bar unless in DemoMode
        IF FadeStep < 255 AND NOT DemoMode THEN
            FadeStep = FadeStep + 1
            LINE (0, 0)-(599, 15), _RGBA32(Shades(NextShade).R, Shades(NextShade).G, Shades(NextShade).B, FadeStep), BF
        END IF

        'Draw the current block
        LINE (BlockPos(CurrentColumn), Y)-STEP(BlockWidth, BlockHeight), Shade&(CurrentShade), BF

        UpdateScreen

        IF NOT DemoMode AND Increment < BlockHeight THEN k$ = INKEY$

        'Emulate arrow keys if mouse was clicked+held+moved on screen
        'Code courtesy of Steve McNeill:
        WHILE _MOUSEINPUT: WEND
        STATIC OldX, OldY
        MX = _MOUSEX: MY = _MOUSEY: MB = _MOUSEBUTTON(1)


        IF MB THEN
            IF ABS(OldX - MX) > 100 THEN
                IF OldX < MX THEN k$ = CHR$(0) + CHR$(77) ELSE k$ = CHR$(0) + CHR$(75)
                OldX = MX
            END IF
            IF ABS(OldY - MY) > 100 THEN
                IF OldY < MY THEN k$ = CHR$(0) + CHR$(80)
                OldY = MY
            END IF
        ELSE
            OldX = MX
            OldY = MY
        END IF

        SELECT CASE k$
            CASE CHR$(0) + CHR$(80) 'Down arrow
                Increment = BlockHeight
            CASE CHR$(0) + CHR$(75) 'Left arrow
                IF CurrentColumn > 1 THEN
                    IF Board(CurrentRow, CurrentColumn - 1).State = False THEN
                        IF BgImage < -1 THEN _PUTIMAGE (BlockPos(CurrentColumn), Y)-(BlockPos(CurrentColumn) + BlockWidth, Y + BlockHeight), BgImage, GameScreen, (BlockPos(CurrentColumn), Y)-(BlockPos(CurrentColumn) + BlockWidth, Y + BlockHeight) ELSE LINE (BlockPos(CurrentColumn), Y)-(BlockPos(CurrentColumn) + BlockWidth, Y + BlockHeight), BackgroundColor, BF
                        CurrentColumn = CurrentColumn - 1
                    END IF
                END IF
            CASE CHR$(0) + CHR$(77) 'Right arrow
                IF CurrentColumn < 4 THEN
                    IF Board(CurrentRow, CurrentColumn + 1).State = False THEN
                        IF BgImage < -1 THEN _PUTIMAGE (BlockPos(CurrentColumn), Y)-(BlockPos(CurrentColumn) + BlockWidth, Y + BlockHeight), BgImage, GameScreen, (BlockPos(CurrentColumn), Y)-(BlockPos(CurrentColumn) + BlockWidth, Y + BlockHeight) ELSE LINE (BlockPos(CurrentColumn), Y)-(BlockPos(CurrentColumn) + BlockWidth, Y + BlockHeight), BackgroundColor, BF
                        CurrentColumn = CurrentColumn + 1
                    END IF
                END IF
            CASE CHR$(27)
                IF GameMode <> FILLMODE THEN
                    IF BgMusic(GameMode) THEN _SNDSTOP BgMusic(GameMode)
                ELSE
                    IF BgMusic(ZENMODE) THEN _SNDSTOP BgMusic(ZENMODE)
                END IF
                IF BgMusic(4) THEN _SNDSTOP BgMusic(4)
                REDIM Choices(1 TO 2) AS STRING
                REDIM Info(1 TO 2) AS STRING
                REDIM Tips(1 TO 2) AS LONG
                Choices(1) = "Quit"
                Choices(2) = "Resume"
                IF Menu(1, 2, Choices(), Info(), Tips(), 3) = 1 THEN
                    GameEnded = True
                ELSE
                    IF GameMode <> FILLMODE THEN
                        IF Settings.MusicOn AND BgMusic(GameMode) AND NOT InDanger THEN _SNDLOOP BgMusic(GameMode)
                        IF Settings.MusicOn AND BgMusic(4) AND InDanger THEN _SNDLOOP BgMusic(4)
                    ELSE
                        IF Settings.MusicOn AND BgMusic(ZENMODE) AND NOT InDanger THEN _SNDLOOP BgMusic(ZENMODE)
                        IF Settings.MusicOn AND BgMusic(4) AND InDanger THEN _SNDLOOP BgMusic(4)
                    END IF
                END IF
                RedrawBoard
                'CASE " "
                '    GameOver = True
        END SELECT
        IF DemoMode THEN EXIT SUB
    LOOP UNTIL BlockPut OR GameEnded OR GameOver
END SUB

SUB CheckMerge
    'Check if a block merge will be required:
    DIM YStep AS LONG, AnimationLimit AS LONG
    DIM WatchOutColor AS _BIT, PreviousDest AS LONG
    DIM DangerMessage$

    Merged = False

    AnimationLimit = 60 'Default for NORMALINCREMENT
    SELECT CASE InitialIncrement
        CASE ZENINCREMENT: AnimationLimit = 30
        CASE FLASHINCREMENT: AnimationLimit = 90
    END SELECT

    IF BlockPut AND CurrentRow > 1 THEN
        DO
            IF Board(CurrentRow, CurrentColumn).Shade = Board(CurrentRow - 1, CurrentColumn).Shade THEN
                'Change block's color and the one touched to a darker shade, if it's not the darkest yet
                IF GameMode = FILLMODE THEN Score = Score - 5 - CurrentShade * 2 ELSE Score = Score + CurrentShade * 2
                IF Score < 0 THEN Score = 0
                IF CurrentShade < 5 THEN
                    Merged = True
                    TotalMerges = TotalMerges + 1
                    i = CurrentShade
                    RStep = (Shades(i).R - Shades(i + 1).R) / MergeSteps
                    GStep = (Shades(i).G - Shades(i + 1).G) / MergeSteps
                    BStep = (Shades(i).B - Shades(i + 1).B) / MergeSteps
                    YStep = (BlockHeight) / MergeSteps

                    RToGo = Shades(i).R
                    GToGo = Shades(i).G
                    BToGo = Shades(i).B

                    ShrinkingHeight = BlockHeight * 2

                    IF SplashSound(CurrentShade) AND Settings.SoundOn AND NOT DemoMode AND NOT GameMode = FILLMODE THEN
                        _SNDPLAYCOPY SplashSound(CurrentShade)
                    ELSEIF Settings.SoundOn AND GameMode = FILLMODE THEN
                        IF ShockSound THEN _SNDPLAYCOPY ShockSound
                    END IF

                    FOR Merge = 0 TO MergeSteps: _LIMIT AnimationLimit
                        RToGo = RToGo - RStep
                        GToGo = GToGo - GStep
                        BToGo = BToGo - BStep

                        ShrinkingHeight = ShrinkingHeight - YStep

                        IF BgImage < -1 THEN
                            _PUTIMAGE (BlockPos(CurrentColumn), BlockRows(CurrentRow))-(BlockPos(CurrentColumn) + BlockWidth, BlockRows(CurrentRow) + BlockHeight * 2 + 1), BgImage, GameScreen, (BlockPos(CurrentColumn), BlockRows(CurrentRow))-(BlockPos(CurrentColumn) + BlockWidth, BlockRows(CurrentRow) + BlockHeight * 2 + 1)
                        ELSE
                            LINE (BlockPos(CurrentColumn), BlockRows(CurrentRow))-STEP(BlockWidth, BlockHeight * 2 + 1), BackgroundColor, BF
                        END IF

                        'Draw the merging blocks:
                        LINE (BlockPos(CurrentColumn), BlockRows(CurrentRow) + (BlockHeight * 2) - ShrinkingHeight - 1)-STEP(BlockWidth, ShrinkingHeight + 2), _RGB32(RToGo, GToGo, BToGo), BF
                        IF GameMode = FILLMODE THEN
                            InWatchOut = True
                            PreviousDest = _DEST
                            _DEST OverlayGraphics
                            IF WatchOutColor THEN CLS , _RGB(255, 255, 0) ELSE CLS , _RGBA32(0, 0, 0, 100)
                            WatchOutColor = NOT WatchOutColor
                            DangerMessage$ = "WATCH OUT!"
                            PrintShadow _WIDTH \ 2 - _PRINTWIDTH(DangerMessage$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2, DangerMessage$, _RGB32(255, 255, 255)
                            _DEST PreviousDest
                        END IF
                        UpdateScreen
                    NEXT Merge
                    InWatchOut = False

                    Board(CurrentRow, CurrentColumn).State = False
                    Board(CurrentRow - 1, CurrentColumn).Shade = i + 1
                ELSE
                    EXIT DO
                END IF
            ELSE
                EXIT DO
            END IF
            CurrentRow = CurrentRow - 1
            CurrentShade = CurrentShade + 1
            Y = BlockRows(CurrentRow)
            PrevY = Y
            CheckDanger
        LOOP UNTIL CurrentRow = 1 OR CurrentShade = 5
    END IF
    _KEYCLEAR
END SUB

SUB CheckConnectedLines
    'Check for connected lines with the same shade and
    'compute the new score, besides generating the disappearing
    'animation:
    DIM WatchOutColor AS _BIT, PreviousDest AS LONG
    DIM DangerMessage$

    Matched = False
    DO
        CurrentMatch = CheckMatchingLine%
        IF CurrentMatch = 0 THEN EXIT DO

        Matched = True
        IF GameMode = FILLMODE THEN Score = Score - 40 ELSE Score = Score + 40
        IF Score < 0 THEN Score = 0

        MatchLineStart = BlockRows(CurrentMatch) + BlockHeight \ 2

        IF LineSound AND Settings.SoundOn AND NOT DemoMode AND NOT GameMode = FILLMODE THEN
            _SNDPLAYCOPY LineSound
        ELSEIF Settings.SoundOn AND GameMode = FILLMODE THEN
            IF ShockSound THEN _SNDPLAYCOPY ShockSound
        END IF

        FOR i = 1 TO BlockHeight \ 2
            _LIMIT 60
            IF BgImage < -1 THEN
                _PUTIMAGE (0, MatchLineStart - i)-(599, MatchLineStart + i), BgImage, GameScreen, (0, MatchLineStart - i)-(599, MatchLineStart + i)
            ELSE
                LINE (0, MatchLineStart - i)-(599, MatchLineStart + i), BackgroundColor, BF
            END IF
            IF GameMode = FILLMODE THEN
                InWatchOut = True
                PreviousDest = _DEST
                _DEST OverlayGraphics
                IF WatchOutColor THEN CLS , _RGB(255, 255, 0) ELSE CLS , _RGBA32(0, 0, 0, 100)
                WatchOutColor = NOT WatchOutColor
                DangerMessage$ = "ARE YOU CRAZY?!"
                PrintShadow _WIDTH \ 2 - _PRINTWIDTH(DangerMessage$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2, DangerMessage$, _RGB32(255, 255, 255)
                _DEST PreviousDest
            END IF
            UpdateScreen
        NEXT i
        InWatchOut = False

        DestroyLine CurrentMatch
        TotalLines = TotalLines + 1
        RedrawBoard

        DropSoundI = _CEIL(RND * 3)
        IF DropSound(DropSoundI) AND Settings.SoundOn AND NOT DemoMode THEN
            _SNDPLAYCOPY DropSound(DropSoundI)
        END IF
        IF DemoMode THEN DemoMode = False
    LOOP
END SUB

FUNCTION ConvertYtoRow (CurrentY)
    'Returns the row on the board through which the block is currently
    'passing.

    IF CurrentY >= -48 AND CurrentY <= 20 THEN
        ConvertYtoRow = 12
    ELSEIF CurrentY > 20 AND CurrentY <= 85 THEN
        ConvertYtoRow = 11
    ELSEIF CurrentY > 85 AND CurrentY <= 150 THEN
        ConvertYtoRow = 10
    ELSEIF CurrentY > 150 AND CurrentY <= 215 THEN
        ConvertYtoRow = 9
    ELSEIF CurrentY > 215 AND CurrentY <= 280 THEN
        ConvertYtoRow = 8
    ELSEIF CurrentY > 280 AND CurrentY <= 345 THEN
        ConvertYtoRow = 7
    ELSEIF CurrentY > 345 AND CurrentY <= 410 THEN
        ConvertYtoRow = 6
    ELSEIF CurrentY > 410 AND CurrentY <= 475 THEN
        ConvertYtoRow = 5
    ELSEIF CurrentY > 475 AND CurrentY <= 540 THEN
        ConvertYtoRow = 4
    ELSEIF CurrentY > 540 AND CurrentY <= 605 THEN
        ConvertYtoRow = 3
    ELSEIF CurrentY > 605 AND CurrentY <= 670 THEN
        ConvertYtoRow = 2
    ELSEIF CurrentY > 670 AND CurrentY <= 735 THEN
        ConvertYtoRow = 1
    END IF
END FUNCTION

FUNCTION ConvertXtoCol (CurrentX)
    'Returns the column on the board being currently hovered

    IF CurrentX >= BlockPos(1) AND CurrentX < BlockPos(2) THEN
        ConvertXtoCol = 1
    ELSEIF CurrentX >= BlockPos(2) AND CurrentX < BlockPos(3) THEN
        ConvertXtoCol = 2
    ELSEIF CurrentX >= BlockPos(3) AND CurrentX < BlockPos(4) THEN
        ConvertXtoCol = 3
    ELSEIF CurrentX >= BlockPos(4) THEN
        ConvertXtoCol = 4
    END IF
END FUNCTION


FUNCTION Shade& (CurrentShade)
    Shade& = _RGB32(Shades(CurrentShade).R, Shades(CurrentShade).G, Shades(CurrentShade).B)
END FUNCTION

FUNCTION CheckMatchingLine%

    DIM i AS LONG
    DIM a.s AS LONG, b.s AS LONG, c.s AS LONG, d.s AS LONG
    DIM a AS LONG, b AS LONG, c AS LONG, d AS LONG

    FOR i = 1 TO 12
        a.s = Board(i, 1).State
        b.s = Board(i, 2).State
        c.s = Board(i, 3).State
        d.s = Board(i, 4).State

        a = Board(i, 1).Shade
        b = Board(i, 2).Shade
        c = Board(i, 3).Shade
        d = Board(i, 4).Shade

        IF a.s AND b.s AND c.s AND d.s THEN
            IF a = b AND b = c AND c = d THEN
                CheckMatchingLine% = i
                EXIT FUNCTION
            END IF
        END IF

    NEXT i
    CheckMatchingLine% = 0

END FUNCTION

SUB DestroyLine (LineToDestroy AS LONG)

    DIM i AS LONG
    SELECT CASE LineToDestroy
        CASE 1 TO 11
            FOR i = LineToDestroy TO 11
                Board(i, 1).State = Board(i + 1, 1).State
                Board(i, 2).State = Board(i + 1, 2).State
                Board(i, 3).State = Board(i + 1, 3).State
                Board(i, 4).State = Board(i + 1, 4).State

                Board(i, 1).Shade = Board(i + 1, 1).Shade
                Board(i, 2).Shade = Board(i + 1, 2).Shade
                Board(i, 3).Shade = Board(i + 1, 3).Shade
                Board(i, 4).Shade = Board(i + 1, 4).Shade
            NEXT i
            FOR i = 1 TO 4
                Board(12, i).State = False
                Board(12, i).Shade = 0
            NEXT i
        CASE 12
            FOR i = 1 TO 4
                Board(12, i).State = False
                Board(12, i).Shade = 0
            NEXT i
    END SELECT

END SUB

SUB RedrawBoard
    DIM i AS LONG, CurrentColumn AS LONG
    DIM StartY AS LONG, EndY AS LONG

    IF BgImage < -1 THEN _PUTIMAGE , BgImage, GameScreen ELSE CLS , BackgroundColor

    FOR i = 1 TO 12
        FOR CurrentColumn = 4 TO 1 STEP -1
            StartY = BlockRows(i)
            EndY = StartY + BlockHeight

            IF Board(i, CurrentColumn).State = True THEN
                LINE (BlockPos(CurrentColumn), StartY)-(BlockPos(CurrentColumn) + BlockWidth, EndY), Shade&(Board(i, CurrentColumn).Shade), BF
            END IF
        NEXT CurrentColumn
    NEXT i

END SUB

SUB ShowScore
    DIM ScoreString AS STRING
    DIM ModeHighScore AS LONG

    IF Score = PreviousScore THEN EXIT SUB
    PreviousScore = Score

    ScoreString = "Score:" + STR$(Score)

    SELECT CASE GameMode
        CASE ZENMODE: ModeHighScore = Settings.HighscoreZEN
        CASE NORMALMODE: ModeHighScore = Settings.HighscoreNORMAL
        CASE FLASHMODE: ModeHighScore = Settings.HighscoreFLASH
        CASE FILLMODE: ModeHighScore = Settings.HighscoreFILL
    END SELECT

    _DEST InfoScreen
    CLS , _RGBA32(0, 0, 0, 0)

    '_FONT 16
    PrintShadow 15, 15, ScoreString, _RGB32(255, 255, 255)

    _FONT 8
    IF Score < ModeHighScore THEN
        PrintShadow 15, 32, "Highscore: " + TRIM$(ModeHighScore), _RGB32(255, 255, 255)
    ELSEIF Score > ModeHighScore AND ModeHighScore > 0 THEN
        PrintShadow 15, 32, "You beat the highscore!", _RGB32(255, 255, 255)
    END IF
    _FONT 16
    _DEST GameScreen

END SUB

SUB MakeIcon
    'Generates the icon that will be placed on the window title of the game
    DIM Icon AS LONG
    DIM PreviousDest AS LONG
    DIM i AS LONG
    CONST IconSize = 16

    Icon = _NEWIMAGE(IconSize, IconSize, 32)
    PreviousDest = _DEST
    _DEST Icon

    FOR i = 1 TO 5
        LINE (0, i * (IconSize / 5) - (IconSize / 5))-(IconSize, i * (IconSize / 5)), Shade&(i), BF
    NEXT i

    _ICON Icon
    _FREEIMAGE Icon

    _DEST PreviousDest
END SUB

SUB CheckDanger
    'Checks if any block pile is 11 blocks high, which
    'means danger, which means player needs to think faster,
    'which means we'll make him a little bit more nervous by
    'switching our soothing bg song to a fast paced circus
    'like melody.
    IF Board(11, 1).State OR Board(11, 2).State OR Board(11, 3).State OR Board(11, 4).State THEN
        IF Settings.SoundOn AND NOT InDanger AND NOT DemoMode THEN
            IF Alarm THEN _SNDPLAYCOPY Alarm
            IF Settings.MusicOn THEN
                IF GameMode <> FILLMODE THEN
                    IF BgMusic(GameMode) THEN _SNDSTOP BgMusic(GameMode)
                ELSE
                    IF BgMusic(ZENMODE) THEN _SNDSTOP BgMusic(ZENMODE)
                END IF
                IF BgMusic(4) THEN _SNDLOOP BgMusic(4)
            END IF
            TIMER(AlertTimer) ON
        END IF
        InDanger = True
    ELSE
        IF Settings.MusicOn AND InDanger AND NOT DemoMode THEN
            IF BgMusic(4) THEN _SNDSTOP BgMusic(4)
            IF GameMode <> FILLMODE THEN
                IF BgMusic(GameMode) THEN _SNDLOOP BgMusic(GameMode)
            ELSE
                IF BgMusic(ZENMODE) THEN _SNDLOOP BgMusic(ZENMODE)
            END IF
            TIMER(AlertTimer) OFF
            _DEST OverlayGraphics
            CLS , _RGBA32(0, 0, 0, 0)
            _DEST GameScreen
        END IF
        InDanger = False
    END IF
END SUB

SUB LoadAssets
    'Loads sound files at startup.
    DIM i AS _BYTE

    LineSound = _SNDOPEN("line.ogg", "SYNC")
    GameOverSound = _SNDOPEN("gameover.ogg", "SYNC")
    Whistle = _SNDOPEN("whistle.ogg", "SYNC,VOL")
    IF Whistle THEN _SNDVOL Whistle, 0.02

    Alarm = _SNDOPEN("alarm.ogg", "SYNC")
    ShockSound = _SNDOPEN("shock.ogg", "SYNC")

    FOR i = 1 TO 3
        IF NOT DropSound(i) THEN DropSound(i) = _SNDOPEN("drop" + TRIM$(i) + ".ogg", "SYNC")
    NEXT i

    FOR i = 1 TO 4
        IF NOT SplashSound(i) THEN SplashSound(i) = _SNDOPEN("water" + TRIM$(i) + ".ogg", "SYNC")
    NEXT i

    BgMusic(1) = _SNDOPEN("Water_Prelude.ogg", "SYNC,VOL")
    BgMusic(2) = _SNDOPEN("Crowd_Hammer.ogg", "SYNC,VOL")
    BgMusic(3) = _SNDOPEN("Upbeat_Forever.ogg", "SYNC,VOL")
    BgMusic(4) = _SNDOPEN("quick.ogg", "SYNC,VOL")
    IF BgMusic(1) THEN _SNDVOL BgMusic(1), .2
    IF BgMusic(4) THEN _SNDVOL BgMusic(4), .8

END SUB

SUB UpdateScreen
    'Display the gamescreen, overlay and score layers
    IF NOT DemoMode THEN ShowScore

    _PUTIMAGE , GameScreen, MainScreen
    IF InMenu OR InDanger OR InWatchOut THEN
        _PUTIMAGE , OverlayGraphics, MainScreen
        IF MenuTip THEN
            _PUTIMAGE (_WIDTH(MainScreen) \ 2 - _WIDTH(MenuTip) \ 2, _HEIGHT(MainScreen) \ 2 - _HEIGHT(MenuTip) \ 2), MenuTip, MainScreen
        END IF
    END IF

    IF NOT InMenu THEN _PUTIMAGE , InfoScreen, MainScreen
    _DISPLAY
END SUB

SUB PrintShadow (x%, y%, Text$, ForeColor&)
    'Shadow:
    COLOR _RGBA32(170, 170, 170, 170), _RGBA32(0, 0, 0, 0)
    _PRINTSTRING (x% + 1, y% + 1), Text$

    'Text:
    COLOR ForeColor&, _RGBA32(0, 0, 0, 0)
    _PRINTSTRING (x%, y%), Text$
END SUB

SUB SelectGlobalShade
    IF Settings.ColorMode = 0 THEN
        GlobalShade = (GlobalShade) MOD MaxShades + 1
    ELSE
        GlobalShade = Settings.ColorMode
    END IF
    SELECT CASE GlobalShade
        CASE 1: RESTORE Greens
        CASE 2: RESTORE Oranges
        CASE 3: RESTORE Blues
        CASE 4: RESTORE Pinks
    END SELECT

    FOR i = 1 TO 5
        READ Shades(i).R
        READ Shades(i).G
        READ Shades(i).B
    NEXT i

END SUB

SUB PrepareIntro
    'The intro shows the board about to be cleared,
    'which then happens after assets are loaded. The intro
    'is generated using the game engine.

    'DemoMode prevents sounds to be played
    DemoMode = True

    _DEST InfoScreen
    _FONT 16
    LoadingMessage$ = "Cloned Shades"
    PrintShadow _WIDTH \ 2 - _PRINTWIDTH(LoadingMessage$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT, LoadingMessage$, _RGB32(255, 255, 255)

    _FONT 8
    LoadingMessage$ = "loading..."
    PrintShadow _WIDTH \ 2 - _PRINTWIDTH(LoadingMessage$) \ 2, _HEIGHT \ 2, LoadingMessage$, _RGB32(255, 255, 255)

    _FONT 16
    _DEST GameScreen

    'Setup the board to show an "about to merge" group of blocks
    'which will end up completing a dark line at the bottom.
    Board(1, 1).State = True
    Board(1, 1).Shade = 5
    Board(1, 2).State = True
    Board(1, 2).Shade = 5
    Board(1, 3).State = True
    Board(1, 3).Shade = 4
    Board(1, 4).State = True
    Board(1, 4).Shade = 5
    Board(2, 3).State = True
    Board(2, 3).Shade = 3
    Board(3, 3).State = True
    Board(3, 3).Shade = 2
    Board(4, 3).State = True
    Board(4, 3).Shade = 2

    CurrentColumn = 3
    CurrentRow = 4
    CurrentShade = 2
    Y = BlockRows(CurrentRow)
    PrevY = Y
    BlockPut = True

    RedrawBoard
    Board(4, 3).State = False

    UpdateScreen
    IF INSTR(_OS$, "WIN") THEN _SCREENMOVE _MIDDLE
END SUB

SUB Intro
    'The current board setup must have been prepared using PrepareIntro first.

    'Use the game engine to show the intro:
    CheckMerge
    CheckConnectedLines

    'Clear the "loading..." text
    _DEST InfoScreen
    CLS , _RGBA32(0, 0, 0, 0)
    _DEST GameScreen

END SUB

SUB HighLightCol (Col AS LONG)

    _DEST OverlayGraphics
    CLS , _RGBA32(0, 0, 0, 0)
    LINE (BlockPos(Col), 16)-STEP(BlockWidth, _HEIGHT(0)), _RGBA32(255, 255, 255, 150), BF
    _DEST GameScreen

END SUB

SUB ShowAlert
    STATIC FadeLevel
    DIM DangerMessage$
    DIM PreviousDest AS LONG

    IF InMenu OR InWatchOut THEN EXIT SUB

    IF FadeLevel > 100 THEN FadeLevel = 0
    FadeLevel = FadeLevel + 1
    PreviousDest = _DEST
    _DEST OverlayGraphics
    IF GameMode = FILLMODE THEN CLS , _RGBA32(0, 255, 0, FadeLevel) ELSE CLS , _RGBA32(255, 0, 0, FadeLevel)
    IF GameMode = FILLMODE THEN DangerMessage$ = "BE EXTRA CAREFUL!" ELSE DangerMessage$ = "DANGER!"
    PrintShadow _WIDTH \ 2 - _PRINTWIDTH(DangerMessage$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2, DangerMessage$, _RGB32(255, 255, 255)
    _DEST PreviousDest
END SUB

SUB ShowGetReady (CountDown AS _BYTE)
    DIM Message$, i AS _BYTE, i$, iSnd AS _BYTE
    DIM PreviousDest AS LONG

    PreviousDest = _DEST
    DemoMode = True: InMenu = True
    _DEST OverlayGraphics
    Message$ = "GET READY"
    FOR i = CountDown TO 1 STEP -1
        CLS , _RGBA32(255, 255, 255, 200)
        PrintShadow _WIDTH \ 2 - _PRINTWIDTH(Message$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2, Message$, _RGB32(0, 0, 0)
        IF i = 1 THEN i$ = "GO!" ELSE i$ = TRIM$(i)
        PrintShadow _WIDTH \ 2 - _PRINTWIDTH(i$) \ 2, _HEIGHT \ 2 - _FONTHEIGHT \ 2 + _FONTHEIGHT, i$, Shade&(5)
        UpdateScreen
        iSnd = _CEIL(RND * 3): IF DropSound(iSnd) THEN _SNDPLAYCOPY DropSound(iSnd)
        _DELAY .5
    NEXT i
    _DEST PreviousDest
    DemoMode = False: InMenu = False
END SUB

FUNCTION Menu (CurrentChoice AS _BYTE, MaxChoice AS _BYTE, Choices() AS STRING, Info() AS STRING, Tips() AS LONG, TipTime AS DOUBLE)
    'Displays Choices() on the screen and lets the player choose one.
    'Uses OverlayGraphics page to display options.
    'Player must use arrow keys to make a choice then ENTER.

    DIM Choice AS _BYTE, PreviousChoice AS _BYTE
    DIM ChoiceWasMade AS _BIT
    DIM k$, i AS LONG
    DIM ChooseColorTimer AS LONG
    DIM ItemShade AS LONG
    DIM ThisItemY AS LONG
    DIM ThisTime AS DOUBLE, StartTime AS DOUBLE, TipShown AS _BIT

    DemoMode = True
    InMenu = True
    Choice = CurrentChoice

    IF NOT InGame THEN
        ChooseColorTimer = _FREETIMER
        ON TIMER(ChooseColorTimer, 3.5) SelectGlobalShade
        TIMER(ChooseColorTimer) ON
    END IF

    IF NOT InGame THEN ERASE Board: BlockPut = True

    StartTime = TIMER
    DO
        _LIMIT 30

        'Use the game engine while the menu is displayed, except while InGame:
        IF NOT InGame THEN
            IF BlockPut THEN
                GenerateNewBlock: BlockPut = False
            ELSE
                MoveBlock
            END IF
        END IF

        GOSUB ShowCurrentChoice
        ThisTime = TIMER
        IF ThisTime - StartTime >= TipTime AND NOT TipShown THEN
            'TipTime has passed since the user selected the current choice, so
            'if Tips(Choice) contains an image, it is _PUTIMAGEd on the screen.
            IF Tips(Choice) < -1 THEN
                MenuTip = Tips(Choice)
                TipShown = True
            END IF
        END IF

        k$ = INKEY$
        SELECT CASE k$
            CASE CHR$(0) + CHR$(80) 'Down arrow
                DO
                    Choice = (Choice) MOD MaxChoice + 1
                LOOP WHILE RIGHT$(Choices(Choice), 1) = CHR$(0)
                StartTime = TIMER
                TipShown = False
                MenuTip = False
            CASE CHR$(0) + CHR$(72) 'Up arrow
                DO
                    Choice = (Choice + MaxChoice - 2) MOD MaxChoice + 1
                LOOP WHILE RIGHT$(Choices(Choice), 1) = CHR$(0)
                StartTime = TIMER
                TipShown = False
                MenuTip = False
            CASE CHR$(13) 'Enter
                ChoiceWasMade = True
                MenuTip = False
            CASE CHR$(27) 'ESC
                ChoiceWasMade = True
                Choice = MaxChoice
        END SELECT
    LOOP UNTIL ChoiceWasMade

    IF NOT InGame THEN TIMER(ChooseColorTimer) FREE
    InMenu = False
    DemoMode = False
    _DEST OverlayGraphics
    CLS , _RGBA32(255, 255, 255, 100)
    _DEST GameScreen

    MenuTip = False
    FOR i = 1 TO MaxChoice
        IF Tips(i) < -1 THEN _FREEIMAGE Tips(i)
    NEXT i

    Menu = Choice
    EXIT FUNCTION

    ShowCurrentChoice:
    IF Choice = PreviousChoice THEN RETURN
    _DEST OverlayGraphics
    CLS , _RGBA32(255, 255, 255, 100)

    'Choices ending with CHR$(0) are shown as unavailable/grey.
    ThisItemY = (_HEIGHT(OverlayGraphics) / 2) - (((_FONTHEIGHT * MaxChoice) + _FONTHEIGHT) / 2)
    FOR i = 1 TO MaxChoice
        ThisItemY = ThisItemY + _FONTHEIGHT
        IF i = Choice THEN
            ItemShade = Shade&(5)
            PrintShadow (_WIDTH(OverlayGraphics) \ 2) - (_PRINTWIDTH("> " + Choices(i)) \ 2), ThisItemY, CHR$(16) + Choices(i), ItemShade
        ELSE
            IF RIGHT$(Choices(i), 1) = CHR$(0) THEN
                ItemShade = _RGB32(255, 255, 255)
                PrintShadow (_WIDTH(OverlayGraphics) \ 2) - (_PRINTWIDTH(LEFT$(Choices(i), LEN(Choices(i)) - 1)) \ 2), ThisItemY, LEFT$(Choices(i), LEN(Choices(i)) - 1), ItemShade
            ELSE
                ItemShade = Shade&(4)
                PrintShadow (_WIDTH(OverlayGraphics) \ 2) - (_PRINTWIDTH(Choices(i)) \ 2), ThisItemY, Choices(i), ItemShade
            END IF
        END IF
        IF LEN(Info(i)) AND i = Choice THEN
            _FONT 8
            COLOR Shade&(5)
            _PRINTSTRING ((_WIDTH(OverlayGraphics) \ 2) - (_PRINTWIDTH(Info(i)) \ 2), _HEIGHT(OverlayGraphics) - 8), Info(i)
            _FONT 16
        END IF
    NEXT i
    _DEST GameScreen
    UpdateScreen
    PreviousChoice = Choice
    RETURN

END FUNCTION

SUB ShowEndScreen
    DIM Message$(1 TO 10), k$, i AS LONG
    DIM MessageColor AS LONG

    IF InDanger THEN
        TIMER(AlertTimer) OFF
        InDanger = False
    END IF

    _DEST OverlayGraphics
    CLS , _RGBA32(255, 255, 255, 150)

    IF GameMode = FILLMODE AND Score > 0 THEN Message$(1) = "YOU WIN!" ELSE Message$(1) = "GAME OVER"
    Message$(3) = "Your score:"
    Message$(4) = TRIM$(Score)
    Message$(5) = "Merged blocks:"
    Message$(6) = TRIM$(TotalMerges)
    Message$(7) = "Lines destroyed:"
    Message$(8) = TRIM$(TotalLines)
    Message$(10) = "Press ENTER..."

    MessageColor = Shade&(5)
    FOR i = 1 TO UBOUND(message$)
        IF i > 1 THEN _FONT 8: MessageColor = _RGB(0, 0, 0)
        IF i = UBOUND(message$) THEN _FONT 16: MessageColor = Shade&(5)
        PrintShadow (_WIDTH(OverlayGraphics) \ 2) - (_PRINTWIDTH(Message$(i)) \ 2), i * 16, Message$(i), MessageColor
    NEXT i

    _DEST MainScreen

    FOR i = 1 TO _HEIGHT(MainScreen) / 2 STEP BlockHeight / 2
        _LIMIT 60
        _PUTIMAGE , GameScreen
        _PUTIMAGE (0, _HEIGHT(MainScreen) / 2 - i)-(599, _HEIGHT(MainScreen) / 2 + i), OverlayGraphics
        _DISPLAY
    NEXT i

    _PUTIMAGE , GameScreen
    _PUTIMAGE , OverlayGraphics
    _DISPLAY
    _DEST GameScreen

    _KEYCLEAR
    k$ = "": WHILE k$ <> CHR$(13): _LIMIT 30: k$ = INKEY$: WEND

END SUB

FUNCTION TRIM$ (Number)
    TRIM$ = LTRIM$(RTRIM$(STR$(Number)))
END FUNCTION

