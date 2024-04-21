'################################################################
'      H U N T E R ' S    R E V E N G E    2 0 1 7 - 1 8
'                  By Ashish Kushwaha
'         **** Hit F5 and Enjoy the Game!! ****
'Note :-
'The executable should be inside Hunter-Revenge folder
'If you are facing any problem, report it at Qb64.org Forum
'
'*** Tell Me You You Think About This Game On Twitter with @KingOfCoders ***
'
'################################################################

'$CONSOLE
'_CONSOLETITLE "Hunter's Revenge [DEBUG_OUTPUT]"

IF COMMAND$(1) = "--reset" THEN
    DIM dummy AS STRING
    INPUT "Are you sure that you want to reset the game? (Y/N) ", dummy
    IF UCASE$(dummy) = "Y" THEN KILL "Save_Game/save.dat": createConfig: SYSTEM
END IF

'App icon
$EXEICON:'./Images/game.ico'
DIM tmp_icon AS LONG
tmp_icon& = _LOADIMAGE("Images/cursor.png", 32)
_CLEARCOLOR _RGB(255, 255, 255), tmp_icon&
_ICON tmp_icon&
_FREEIMAGE tmp_icon&

DO: LOOP UNTIL _SCREENEXISTS
RANDOMIZE TIMER
'$INCLUDE:'Vendor/spritetop.bi'
_DELAY 1
_MOUSEHIDE

_TITLE "Hunter's Revenge"

SCREEN _NEWIMAGE(800, 600, 32)
DO: LOOP UNTIL _SCREENEXISTS

' ON ERROR GOTO 404

_DISPLAYORDER _SOFTWARE , _HARDWARE , _GLRENDER , _HARDWARE1

'Notification Section
DIM SHARED NEvent, NFPSCount%, NImage&, NText$, NShow AS _BYTE

'Frame Rate Section
DIM SHARED FPSEvent, FPSEvt, FPSCurrent%, FPSRate%, FPSBg&

'Loader Section
DIM SHARED Loader&, LoaderX%, LoaderY%, LoaderCF%, LoaderEvt!
LoaderX% = 730: LoaderY% = 500

'Game Types
TYPE GameMenu
    click AS _BYTE
    hover AS _BYTE
    y AS INTEGER
    img AS LONG
    img2 AS LONG 'software image
END TYPE

TYPE Mousetype
    x AS INTEGER
    y AS INTEGER
    lclick AS _BYTE
    rclick AS _BYTE
    mclick AS _BYTE
    cursor AS LONG
    cursor2 AS LONG
    hovering AS _BYTE
END TYPE

TYPE fonttype
    smaller AS LONG
    normal AS LONG
    bigger AS LONG
    biggest AS LONG
END TYPE
'game objects

TYPE explosiontype
    x AS INTEGER
    y AS INTEGER
    img AS INTEGER
    active AS _BYTE
    currentFrame AS INTEGER
    totalFrames AS INTEGER
    f AS INTEGER
    n AS INTEGER
END TYPE

TYPE guntype
    name AS STRING * 32
    damage AS INTEGER
    id AS INTEGER
    img AS LONG
END TYPE

TYPE Enemies
    x AS INTEGER ' x position
    y AS INTEGER ' y position
    typ AS STRING * 16 'type of enemie
    life AS INTEGER 'life of the enemie
    life2 AS INTEGER 'backup of life
    damage AS INTEGER 'useless
    ending AS _BYTE 'enemie is dead or not
    img AS INTEGER 'sprite handle
    active AS _BYTE 'enemie is active or not
    u AS LONG 'delay (in milliseconds) after which enemie will show up in his scene in gameplay
    n AS INTEGER 'delay between change of frame of animation
    f AS INTEGER 'increment varible, if greater than above 'n', then frame is change
    m AS DOUBLE 'movement speed
    points AS INTEGER 'holds point
    scene AS INTEGER 'hold scene
    snd AS LONG 'hold sound handle
    sndPaused AS _BYTE ' = true when sound is paused.
END TYPE

TYPE Levels
    enemies AS INTEGER 'total enemies in a level
    scenes AS INTEGER 'total scenes in a level
    currentScene AS INTEGER 'current scene of the gameplay
    completed AS _BYTE 'level has been completed or not
    u AS LONG 'current frame of the gameplay (always increases during gameplay)
    over AS _BYTE ' level has been over or not
    background AS STRING * 64 'background image path of the level
    bg AS LONG 'background image handle of the level
    mode AS INTEGER 'MODs of the game. Can be either THUNDERMODE, STORMMODE, FOGMODE, THUNDERMODE+FOGMODE, THUNDERMODE+STORMMODE
    cancel AS _BYTE 'level has been cancel or not
    time AS _UNSIGNED INTEGER 'number of seconds a level has to be completed in (in seconds).
END TYPE

TYPE fog
    x AS INTEGER
    move AS INTEGER
    handle AS LONG
END TYPE

TYPE drops
    x AS INTEGER
    y AS INTEGER
    z AS INTEGER
    len AS DOUBLE
    yspeed AS DOUBLE
    gravity AS DOUBLE
END TYPE

TYPE Settings
    fullscreen AS _BYTE
    music AS _BYTE
    sfx AS _BYTE
    musicV AS DOUBLE
    sfxV AS DOUBLE
    SE AS _BYTE
    fps AS INTEGER
    done AS _BYTE
END TYPE

'score flasher
TYPE scoreFlasher
    x AS SINGLE
    y AS SINGLE
    img AS LONG
    active AS _BYTE
    sclX AS SINGLE
    sclY AS SINGLE
    __ops AS SINGLE
END TYPE

' TYPE Vector_Particles_Text_Type
' x AS SINGLE 'x position
' y AS SINGLE 'y position
' vx AS SINGLE 'visual x
' vy AS SINGLE 'visual y
' delX AS SINGLE 'delta velocity
' delY AS SINGLE 'delta velocity
' dist AS SINGLE 'distance
' distX AS SINGLE ' distance x
' distY AS SINGLE 'distance y
' k AS SINGLE
' END TYPE

'$DYNAMIC

RANDOMIZE TIMER
DIM SHARED W AS Settings
readConfig

'DIM SHARED Paused AS _BYTE

'REDIM SHARED Text_Particles(1) AS Vector_Particles_Text_Type

'DIM SHARED Text_Particles_Status, Text_Particles_Color AS _UNSIGNED LONG

DIM SHARED randomLevels AS _BYTE 'Computer chooses level! ^_*

DIM SHARED Menubg&, GlobalEvent AS SINGLE, TimerEvent, GameRenderingEvent, Minutes%, Seconds%

DIM SHARED Mouse AS Mousetype

DIM SHARED Fonts AS fonttype

DIM SHARED GameMenus(19) AS GameMenu

DIM SHARED MenuBlood%, MenuChoice

DIM SHARED ShotScore(5) AS scoreFlasher

DIM SHARED explosions(20) AS explosiontype, Gun AS guntype, Bloods(50) AS explosiontype

DIM SHARED Level AS Levels

DIM SHARED HighScore%, LevelStage%, LevelStage2%, CurrentScore%

DIM SHARED ScoreBoard&, GunImg&(1), OldScore%, OldSeconds%

DIM SHARED Musics&(2)

RANDOMIZE TIMER
'Rains
DIM SHARED Drop(700) AS drops
DIM SHARED Rainx8&, Rainx16&, RainLight&, RainSound&, RainVol#, ThunderCount, ThunderEvent



'max level
CONST MAX_LEVEL = 14
'storm
DIM SHARED StormImg&, StormX%

'Sparks
DIM SHARED ExplosionsZ(1) AS explosiontype

'MODS
CONST FOGMODE = 1
CONST THUNDERMODE = 3
CONST STORMMODE = 5
DIM SHARED Fogs AS fog

'SFXs
DIM SHARED Eagle&
DIM SHARED Bird&
DIM SHARED Crow&
DIM SHARED Expos&
DIM SHARED Jet&
DIM SHARED Gun1&
DIM SHARED Gun2&

'Enemies scores image
DIM SHARED scoresImage(5) AS LONG

REDIM SHARED Enemie(0) AS Enemies

DIM SHARED Jet1_Sheet%
DIM SHARED Jet2_Sheet%
DIM SHARED Jet3_Sheet%
DIM SHARED Bird_Sheet%
DIM SHARED Crow_Sheet%
DIM SHARED eagle_Sheet%
DIM SHARED blood_Sheet%
DIM SHARED explosion_Sheet%
DIM SHARED spark_Sheet%
DIM SHARED lifeBars(99) AS LONG

FPSEvent = _FREETIMER 'Event for showing current FPS (Frame Per Second)
FPSEvt = _FREETIMER 'Event for calculating current FPS (Frame Per Second)
GlobalEvent = _FREETIMER 'Event for game main menu
TimerEvent = _FREETIMER 'Event of timer which is displayed during gameplay
GameRenderingEvent = _FREETIMER 'Event in which level objects are rendered.
NEvent = _FREETIMER ' Global Event for notification

'Splash Screen

Splash


LoaderStart

loadComponents
'cursors
Mouse.cursor = _LOADIMAGE("Images/cursor.png", 33)
Mouse.cursor2 = _LOADIMAGE("Images/cursor2.png", 33)

'fonts
Fonts.biggest = _LOADFONT("Font/ARDESTINE.ttf", 68)
Fonts.bigger = _LOADFONT("Font/ARDESTINE.ttf", 40)
Fonts.smaller = _LOADFONT("Font/arial.ttf", 12, "dontblend")
Fonts.normal = _LOADFONT("Font/ARDESTINE.ttf", 24)

'scores image

scoresImage(0) = _LOADIMAGE("Images/10.png", 33)
scoresImage(1) = _LOADIMAGE("Images/20.png", 33)
scoresImage(2) = _LOADIMAGE("Images/35.png", 33)
scoresImage(3) = _LOADIMAGE("Images/50.png", 33)
scoresImage(4) = _LOADIMAGE("Images/75.png", 33)
scoresImage(5) = _LOADIMAGE("Images/100.png", 33)

'fogs
Fogs.x = 0
Fogs.move = 1
Fogs.handle = _LOADIMAGE("Images/fogs_.png", 33)

'rains
Rainx8& = _LOADIMAGE("Images/rainx8.png", 33)
Rainx16& = _LOADIMAGE("Images/rainx16.png", 33)


'storm
StormImg& = _LOADIMAGE("Images\storm.png", 33) 'we're using hardware image

'LifeBars
DIM i AS INTEGER, r AS INTEGER, g AS INTEGER
FOR i = 0 TO 99
    lifeBars(i) = _NEWIMAGE(100, 6, 32)
    _DEST lifeBars(i)
    r = p5map(i + 1, 1, 100, 255, 0)
    g = p5map(i + 1, 1, 100, 0, 255)
    LINE (0, 0)-(100, 6), _RGB(0, 0, 0), BF
    LINE (0, 0)-(i + 1, 6), _RGB(r, g, 0), BF
    LINE (0, 0)-(99, 5), _RGB(255, 255, 255), B
    _DEST 0
NEXT

DIM tmp&
FOR i = 0 TO 99
    tmp& = _COPYIMAGE(lifeBars(i))
    _FREEIMAGE lifeBars(i)
    lifeBars(i) = _COPYIMAGE(tmp&, 33)
    _FREEIMAGE tmp&
NEXT

Gun.damage = 3
Gun.id = 1
Gun.name = "Shot Gun"

Menubg& = _LOADIMAGE("Images\farm1.jpg")
GunImg&(0) = _LOADIMAGE("Images\gun_shot.png")
GunImg&(1) = _LOADIMAGE("Images\Gun_ak-47.png")
ScoreBoard& = _LOADIMAGE("Images\score_board.png")

blood_Sheet% = SPRITESHEETLOAD("Images\blood.png", 64, 62, _RGB(0, 0, 0))
Jet1_Sheet% = SPRITESHEETLOAD("Images\Jet.png", 120, 122, _RGB(0, 0, 0))
Jet2_Sheet% = SPRITESHEETLOAD("Images\Jet_2.png", 120, 122, _RGB(0, 0, 0))
Jet3_Sheet% = SPRITESHEETLOAD("Images\Jet_3.png", 150, 122, _RGB(0, 0, 0))
eagle_Sheet% = SPRITESHEETLOAD("Images\eagle.png", 40, 40, _RGB(0, 0, 0))
Crow_Sheet% = SPRITESHEETLOAD("Images\crow.png", 97, 120, _RGB(0, 0, 0))
Bird_Sheet% = SPRITESHEETLOAD("Images\bird.png", 180, 170, _RGB(0, 0, 0))

explosion_Sheet% = SPRITESHEETLOAD("Images\explosion.png", 100, 100, _RGB(0, 0, 0))

FOR i = 0 TO 1
    ExplosionsZ(i).img = SPRITENEW(explosion_Sheet%, 1, SAVE)
    SPRITEANIMATESET ExplosionsZ(i).img, 1, 81
    ExplosionsZ(i).y = 300
NEXT

ExplosionsZ(0).x = 100: ExplosionsZ(1).x = 700

FOR i = 0 TO 20
    Bloods(i).img = SPRITENEW(blood_Sheet%, 1, SAVE)
    SPRITEANIMATESET Bloods(i).img, 1, 6
    explosions(i).img = SPRITENEW(explosion_Sheet%, 1, SAVE)
    SPRITEANIMATESET explosions(i).img, 1, 81
    Bloods(i).totalFrames = 6
    Bloods(i).n = 5
    explosions(i).totalFrames = 81
    explosions(i).n = 4
NEXT
MenuBlood% = SPRITENEW(blood_Sheet%, 1, SAVE)
SPRITEANIMATESET MenuBlood%, 1, 6



'Setup Notificaton stuff
ON TIMER(NEvent, .013) Notify
TIMER(NEvent) ON

_FONT Fonts.bigger

tmp& = _NEWIMAGE(400, 60, 32)
_DEST tmp&
_FONT Fonts.bigger
COLOR , _RGBA(0, 0, 0, 0)
_PRINTSTRING (CenterPrintX("Play"), 0), "Play"
_DEST 0
GameMenus(0).img = _COPYIMAGE(tmp&, 33)
GameMenus(0).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(0).y = 150

tmp& = _NEWIMAGE(400, 60, 32)
_DEST tmp&
_FONT Fonts.bigger
COLOR , _RGBA(0, 0, 0, 0)
_PRINTSTRING (CenterPrintX("Options"), 0), "Options"
_DEST 0
GameMenus(1).img = _COPYIMAGE(tmp&, 33)
GameMenus(1).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(1).y = GameMenus(0).y + 60

tmp& = _NEWIMAGE(400, 60, 32)
_DEST tmp&
_FONT Fonts.bigger
COLOR , _RGBA(0, 0, 0, 0)
_PRINTSTRING (CenterPrintX("Help"), 0), "Help"
_DEST 0
GameMenus(2).img = _COPYIMAGE(tmp&, 33)
GameMenus(2).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(2).y = GameMenus(1).y + 60

tmp& = _NEWIMAGE(400, 60, 32)
_DEST tmp&
_FONT Fonts.bigger
COLOR , _RGBA(0, 0, 0, 0)
_PRINTSTRING (CenterPrintX("Credits"), 0), "Credits"
_DEST 0
GameMenus(3).img = _COPYIMAGE(tmp&, 33)
GameMenus(3).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(3).y = GameMenus(2).y + 60

tmp& = _NEWIMAGE(400, 60, 32)
_DEST tmp&
_FONT Fonts.bigger
COLOR , _RGBA(0, 0, 0, 0)
_PRINTSTRING (CenterPrintX("Exit"), 0), "Exit"
_DEST 0
GameMenus(4).img = _COPYIMAGE(tmp&, 33)
GameMenus(4).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(4).y = GameMenus(3).y + 60


tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Fullscreen"
_DEST 0
GameMenus(5).img = _COPYIMAGE(tmp&, 33)
GameMenus(5).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(5).y = 113

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Fullscreen Method "
_DEST 0
GameMenus(6).img = _COPYIMAGE(tmp&, 33)
GameMenus(6).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(6).y = GameMenus(5).y + 34

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Music "
_DEST 0
GameMenus(7).img = _COPYIMAGE(tmp&, 33)
GameMenus(7).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(7).y = GameMenus(6).y + 34

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "SFX "
_DEST 0
GameMenus(8).img = _COPYIMAGE(tmp&, 33)
GameMenus(8).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(8).y = GameMenus(7).y + 34

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Music Volume "
_DEST 0
GameMenus(9).img = _COPYIMAGE(tmp&, 33)
GameMenus(9).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(9).y = GameMenus(8).y + 34

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "SFX Volume"
_DEST 0
GameMenus(10).img = _COPYIMAGE(tmp&, 33)
GameMenus(10).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(10).y = GameMenus(9).y + 34

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "3D Sound Effect"
_DEST 0
GameMenus(11).img = _COPYIMAGE(tmp&, 33)
GameMenus(11).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(11).y = GameMenus(10).y + 34

tmp& = _NEWIMAGE(400, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Frame Rate "
_DEST 0
GameMenus(12).img = _COPYIMAGE(tmp&, 33)
GameMenus(12).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(12).y = GameMenus(11).y + 34

tmp& = _NEWIMAGE(500, 30, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (CenterPrintX("Default Settings"), 0), "Default Settings"
_DEST 0
GameMenus(13).img = _COPYIMAGE(tmp&, 33)
GameMenus(13).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(13).y = GameMenus(12).y + 34

tmp& = _NEWIMAGE(500, 200, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (CenterPrintX("Apply Settings"), 0), "Apply Settings"
_DEST 0
GameMenus(14).img = _COPYIMAGE(tmp&, 33)
GameMenus(14).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(14).y = GameMenus(13).y + 34

tmp& = _NEWIMAGE(500, 200, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (CenterPrintX("Go Back To Main Menu"), 0), "Go Back To Main Menu"
_DEST 0
GameMenus(15).img = _COPYIMAGE(tmp&, 33)
GameMenus(15).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(15).y = GameMenus(14).y + 34

tmp& = _NEWIMAGE(500, 200, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Fullscreen"
_DEST 0
GameMenus(16).img = _COPYIMAGE(tmp&, 33)
GameMenus(16).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(16).y = 232

tmp& = _NEWIMAGE(500, 200, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "Music Volume"
_DEST 0
GameMenus(17).img = _COPYIMAGE(tmp&, 33)
GameMenus(17).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(17).y = GameMenus(16).y + 34

tmp& = _NEWIMAGE(500, 200, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (20, 0), "SFX Volume"
_DEST 0
GameMenus(18).img = _COPYIMAGE(tmp&, 33)
GameMenus(18).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(18).y = GameMenus(17).y + 34

tmp& = _NEWIMAGE(500, 200, 32)
_DEST tmp&
COLOR , _RGBA(0, 0, 0, 0)
_FONT Fonts.normal
_PRINTSTRING (CenterPrintX("Exit to Main Menu"), 0), "Exit to Main Menu"
_DEST 0
GameMenus(19).img = _COPYIMAGE(tmp&, 33)
GameMenus(19).img2 = _COPYIMAGE(tmp&, 32)
_FREEIMAGE tmp&
GameMenus(19).y = GameMenus(18).y + 34






LoaderEnd

start:

COLOR _RGB(255, 255, 255), _RGBA(0, 0, 0, 0)

' echo COMMAND$(1)
' echo COMMAND$(2)
' IF COMMAND$(1) = "-loadlevel" AND VAL(COMMAND$(2)) > 0 THEN
' LevelStage% = VAL(COMMAND$(2))
' LevelStage2% = LevelStage%
' GOTO newgame
' END IF

GameMenu




IF MenuChoice = 1 THEN MenuChoice = 0: GOTO newgame
IF MenuChoice = 2 THEN
    MenuChoice = 0

    'save current settings in dummy variable :P
    DIM preConfig AS Settings
    preConfig = W ' W is a global variable which stored all game settings

    DIM on_switch&, off_switch&, bd&, cj&, gfx&, ac& 'images surface
    on_switch& = _LOADIMAGE("Images/on.png", 33)
    off_switch& = _LOADIMAGE("Images/off.png", 33)
    FOR i = 0 TO 4
        _PUTIMAGE (200, GameMenus(i).y), GameMenus(i).img2
    NEXT

    bd& = _COPYIMAGE(0)
    cj& = _COPYIMAGE(bd&)

    BLURIMAGE cj&, 5
    gfx& = _NEWIMAGE(500, 340, 32)
    _DEST gfx&
    CLS , 0 'make it transparent
    LINE (0, 0)-STEP(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, 150), BF
    FOR i = 5 TO 14
        _PUTIMAGE (0, GameMenus(i).y - 103), GameMenus(i).img2
    NEXT

    _DEST 0

    FOR i = 0 TO 255 STEP 10
        _SETALPHA i, , cj&
        _PUTIMAGE , bd&
        _PUTIMAGE , cj&
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i / 3), BF
        _PUTIMAGE (150, 103), gfx&, 0, (0, 0)-(500, p5map(i, 0, 255, 0, 340))
        _DISPLAY
    NEXT
    ac& = _COPYIMAGE(cj&)
    _DEST ac&
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, 85), BF
    _DEST 0
    DO
        WHILE _MOUSEINPUT: WEND
        Mouse.x = _MOUSEX: Mouse.y = _MOUSEY
        Mouse.lclick = 0
        Mouse.rclick = 0
        IF _MOUSEBUTTON(1) THEN
            WHILE _MOUSEBUTTON(1): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.lclick = -1
        END IF
        IF _MOUSEBUTTON(2) THEN
            WHILE _MOUSEBUTTON(2): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.rclick = -1
        END IF
        _PUTIMAGE , ac&
        LINE (150, 103)-STEP(500, 374), _RGBA(0, 0, 0, 150), BF
        FOR i = 5 TO 15
            IF Mouse.x > 150 AND Mouse.x < 650 AND Mouse.y > GameMenus(i).y - 10 AND Mouse.y < GameMenus(i).y + 24 THEN
                LINE (150, GameMenus(i).y - 10)-(650, GameMenus(i).y + 24), _RGBA(255, 100, 0, 100), BF
                IF Mouse.lclick THEN
                    SELECT CASE i
                        CASE 5
                            IF W.fullscreen > 0 THEN W.fullscreen = 0 ELSE W.fullscreen = 1
                        CASE 6
                            W.fullscreen = W.fullscreen + 1
                            IF W.fullscreen > 2 THEN W.fullscreen = 1
                        CASE 7
                            IF W.music THEN W.music = 0 ELSE W.music = -1
                        CASE 8
                            IF W.sfx THEN W.sfx = 0 ELSE W.sfx = -1
                        CASE 9
                            W.musicV = W.musicV + .1
                            IF W.musicV > 1.0 THEN W.musicV = .1
                        CASE 10
                            W.sfxV = W.sfxV + .1
                            IF W.sfxV > 1 THEN W.sfxV = 0.1
                        CASE 11
                            IF W.SE THEN W.SE = 0 ELSE W.SE = -1
                        CASE 12
                            W.fps = W.fps + 30
                            IF W.fps > 240 THEN W.fps = 30
                        CASE 13
                            W.fullscreen = 0
                            W.music = -1
                            W.sfx = -1
                            W.musicV = 1
                            W.sfxV = 1
                            W.SE = -1
                            W.fps = 30
                        CASE 14
                            writeConfig
                            loadComponents
                            showNotification "Settings have been applied."
                        CASE 15
                            EXIT DO
                    END SELECT
                END IF
            END IF
            _PUTIMAGE (150, GameMenus(i).y), GameMenus(i).img
            SELECT CASE i
                CASE 5
                    IF W.fullscreen > 0 THEN _PUTIMAGE (580, GameMenus(i).y - 3), on_switch& ELSE _PUTIMAGE (580, GameMenus(i).y - 3), off_switch&
                CASE 6
                    _FONT Fonts.normal
                    SELECT CASE W.fullscreen
                        CASE 1
                            _PRINTSTRING (630 - txtWidth("Stretch"), GameMenus(i).y), "Stretch"
                        CASE 2
                            _PRINTSTRING (630 - txtWidth("Square Pixels"), GameMenus(i).y), "Square Pixels"
                        CASE ELSE
                            _PRINTSTRING (630 - txtWidth("Disable"), GameMenus(i).y), "Disable"
                    END SELECT
                CASE 7
                    IF W.music THEN _PUTIMAGE (580, GameMenus(i).y - 3), on_switch& ELSE _PUTIMAGE (580, GameMenus(i).y - 3), off_switch&
                CASE 8
                    IF W.sfx THEN _PUTIMAGE (580, GameMenus(i).y - 3), on_switch& ELSE _PUTIMAGE (580, GameMenus(i).y - 3), off_switch&
                CASE 9
                    _FONT Fonts.normal
                    IF W.musicV > .9 THEN
                        _PRINTSTRING (630 - txtWidth(" 10"), GameMenus(i).y), " 10 "
                    ELSE
                        _PRINTSTRING (630 - txtWidth(STR$(INT(W.musicV * 10))), GameMenus(i).y), STR$(INT(W.musicV * 10))
                    END IF
                CASE 10
                    _FONT Fonts.normal
                    IF W.sfxV > .9 THEN
                        _PRINTSTRING (630 - txtWidth(" 10"), GameMenus(i).y), " 10 "
                    ELSE
                        _PRINTSTRING (630 - txtWidth(STR$(INT(W.sfxV * 10))), GameMenus(i).y), STR$(INT(W.sfxV * 10))
                    END IF
                CASE 11
                    IF W.SE THEN _PUTIMAGE (580, GameMenus(i).y - 3), on_switch& ELSE _PUTIMAGE (580, GameMenus(i).y - 3), off_switch&
                CASE 12
                    _FONT Fonts.normal
                    _PRINTSTRING (630 - txtWidth(STR$(W.fps)), GameMenus(i).y), STR$(W.fps)
            END SELECT
        NEXT
        _LIMIT W.fps
        IF Mouse.hovering THEN
            _PUTIMAGE (Mouse.x - 16, Mouse.y - 16), Mouse.cursor2
            _DISPLAY
        ELSE
            _PUTIMAGE (Mouse.x - 16, Mouse.y - 16), Mouse.cursor
            _DISPLAY
        END IF

    LOOP
    FOR i = 255 TO 0 STEP -10
        _SETALPHA i, , cj&
        _PUTIMAGE , bd&
        _PUTIMAGE , cj&
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i / 3), BF
        _PUTIMAGE (150, 103), gfx&, 0, (0, 0)-(500, p5map(i, 0, 255, 0, 340))
        _DISPLAY
    NEXT
    _FREEIMAGE bd&
    _FREEIMAGE cj&
    _FREEIMAGE ac&
    _FREEIMAGE gfx&
    _FREEIMAGE on_switch&
    _FREEIMAGE off_switch&
    GOTO start
END IF
IF MenuChoice = 3 THEN
    MenuChoice = 0
    FOR i = 0 TO 4
        _PUTIMAGE (200, GameMenus(i).y), GameMenus(i).img2
    NEXT
    bd& = _COPYIMAGE(0)
    cj& = _COPYIMAGE(bd&)

    BLURIMAGE cj&, 5
    DIM k&
    k& = _LOADIMAGE("Images\help.png")

    FOR i = 0 TO 255 STEP 10
        _SETALPHA i, , cj&
        _PUTIMAGE , bd&
        _PUTIMAGE , cj&
        _SETALPHA i / 1.25, , k&
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i / 5), BF
        centerImage k&
        _DISPLAY
    NEXT

    DO
        'mouse input
        WHILE _MOUSEINPUT: WEND
        Mouse.x = _MOUSEX: Mouse.y = _MOUSEY

        IF _MOUSEBUTTON(1) THEN
            WHILE _MOUSEBUTTON(1): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.lclick = -1
        ELSE
            Mouse.lclick = 0
        END IF

        IF _MOUSEBUTTON(2) THEN
            WHILE _MOUSEBUTTON(2): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.rclick = -1
        ELSE
            Mouse.rclick = 0
        END IF

        _LIMIT W.fps

        _DISPLAY

        IF Mouse.lclick OR Mouse.rclick OR _KEYHIT = 27 THEN EXIT DO
    LOOP

    FOR i = 255 TO 0 STEP -10
        _SETALPHA i, , cj&
        _PUTIMAGE , bd&
        _PUTIMAGE , cj&
        _SETALPHA i / 1.25, , k&
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i / 5), BF
        centerImage k&
        _DISPLAY
    NEXT

    _PUTIMAGE , bd&
    _FREEIMAGE bd&
    _FREEIMAGE cj&
    _FREEIMAGE k&
    GOTO start

END IF

IF MenuChoice = 4 THEN
    FOR i = 0 TO 4
        _PUTIMAGE (200, GameMenus(i).y), GameMenus(i).img2
    NEXT

    bd& = _COPYIMAGE(0)

    FOR i = 0 TO 255 STEP 5
        _PUTIMAGE , bd&
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF
        _DISPLAY
    NEXT

    showCredits

    FOR i = 255 TO 0 STEP -5
        _PUTIMAGE , bd&
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF
        _DISPLAY
    NEXT

    _FREEIMAGE bd&
    MenuChoice = 0
    GOTO start

END IF

IF MenuChoice = 5 THEN SYSTEM 1
MenuChoice = 0
END
newgame:


CLS

LoaderStart
SetupRain
IF COMMAND$(1) = "-loadlevel" THEN
    LoadLevel
ELSE
    IF getCurrentLevel > MAX_LEVEL THEN randomLevels = -1 ELSE randomLevels = 0: LoadLevel
END IF


_FONT Fonts.bigger

'################### Random Levels ################################
DIM F AS INTEGER
IF randomLevels THEN
    Level.completed = 0
    Level.over = 0
    LevelStage% = p5random(1, MAX_LEVEL)
    F = FREEFILE
    'LevelStage% = VAL(COMMAND$(2))
    OPEN "stages/stage" + RTRIM$(LTRIM$(STR$(LevelStage%))) + ".dat" FOR INPUT AS #F
    INPUT #F, Level.enemies
    INPUT #F, Level.scenes
    INPUT #F, Seconds%
    INPUT #F, Level.mode
    INPUT #F, Level.background
    CLOSE #F
    Level.bg = _LOADIMAGE("Images\" + RTRIM$(Level.background))
    OldSeconds% = Seconds%
END IF

IF randomLevels THEN _PRINTSTRING (CenterPrintX("Random Levels"), 300), "Random Levels" ELSE _PRINTSTRING (CenterPrintX("Stage " + LTRIM$(RTRIM$(STR$(LevelStage%)))), 300), "Stage " + LTRIM$(RTRIM$(STR$(LevelStage%)))

_DELAY RND * 3

' if randomLevels then LoaderEnd : goto game_rendering_begin
' _DELAY 0.5


'############################# Custom Levels #############################

ERASE Enemie 'clear all previous enemie data

REDIM SHARED Enemie(Level.enemies) AS Enemies

'Enemie Configuirations

F = FREEFILE
Level.completed = 0
Level.over = 0
Level.cancel = 0
CurrentScore% = 0
Level.u = 0
Level.currentScene = 1

OPEN "Stages\Stage" + LTRIM$(RTRIM$(STR$(LevelStage%))) + ".lvl" FOR INPUT AS #F

FOR i = 1 TO Level.enemies
    INPUT #F, Enemie(i).typ

    SELECT CASE RTRIM$(Enemie(i).typ)

        CASE "bird"
            Enemie(i).img = SPRITENEW(Bird_Sheet%, 1, SAVE)
            SPRITEANIMATESET Enemie(i).img, 1, 14
            SPRITEZOOM Enemie(i).img, 50
            Enemie(i).n = 6
            Enemie(i).points = 10
            Enemie(i).life = 4
            Enemie(i).life2 = Enemie(i).life
            Enemie(i).snd = _SNDCOPY(Bird&)
        CASE "crow"
            Enemie(i).img = SPRITENEW(Crow_Sheet%, 1, SAVE)
            SPRITEANIMATESET Enemie(i).img, 1, 4
            SPRITEZOOM Enemie(i).img, 70
            Enemie(i).n = 12
            Enemie(i).points = 20
            Enemie(i).life = 7
            Enemie(i).life2 = Enemie(i).life
            Enemie(i).snd = _SNDCOPY(Crow&)
        CASE "eagle"
            Enemie(i).img = SPRITENEW(eagle_Sheet%, 7, SAVE)
            SPRITEANIMATESET Enemie(i).img, 7, 9
            Enemie(i).n = 12
            Enemie(i).points = 35
            Enemie(i).life = 14
            Enemie(i).life2 = Enemie(i).life
            Enemie(i).snd = _SNDCOPY(Eagle&)
        CASE "jet1"
            Enemie(i).img = SPRITENEW(Jet1_Sheet%, 1, SAVE)
            SPRITEANIMATESET Enemie(i).img, 1, 3
            SPRITEZOOM Enemie(i).img, 70
            Enemie(i).n = 10
            Enemie(i).points = 50
            Enemie(i).life = 30
            Enemie(i).life2 = Enemie(i).life
            Enemie(i).snd = _SNDCOPY(Jet&)
        CASE "jet2"
            Enemie(i).img = SPRITENEW(Jet2_Sheet%, 1, SAVE)
            SPRITEANIMATESET Enemie(i).img, 1, 3
            SPRITEZOOM Enemie(i).img, 70
            Enemie(i).n = 10
            Enemie(i).points = 75
            Enemie(i).life = 45
            Enemie(i).life2 = Enemie(i).life
            Enemie(i).snd = _SNDCOPY(Jet&)
        CASE "jet3"
            Enemie(i).img = SPRITENEW(Jet3_Sheet%, 1, SAVE)
            SPRITEANIMATESET Enemie(i).img, 1, 3
            SPRITEZOOM Enemie(i).img, 70
            Enemie(i).n = 10
            Enemie(i).points = 100
            Enemie(i).life = 70
            Enemie(i).life2 = Enemie(i).life
            Enemie(i).snd = _SNDCOPY(Jet&)
    END SELECT
    INPUT #F, Enemie(i).u
    INPUT #F, Enemie(i).y
    INPUT #F, Enemie(i).m
    IF Enemie(i).m < 0 THEN Enemie(i).x = _WIDTH: SPRITEFLIP Enemie(i).img, HORIZONTAL ELSE Enemie(i).x = 0

    INPUT #F, Enemie(i).scene
NEXT

CLOSE #F

LoaderEnd

game_rendering_begin:::

_PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), Level.bg
_PUTIMAGE (0, 520), ScoreBoard&
_PUTIMAGE (50, 550)-(170, 590), GunImg&(Gun.id - 1)
_FONT Fonts.smaller
_PRINTSTRING (40, 580), RTRIM$(Gun.name)
_FONT Fonts.normal

IF randomLevels THEN _PRINTSTRING (CenterPrintX("Random Levels"), 560), "Random Levels" ELSE _PRINTSTRING (CenterPrintX("Stage " + STR$(LevelStage%)), 560), "Stage " + STR$(LevelStage%)
_FONT Fonts.smaller

Minutes% = (Seconds% - (Seconds% MOD 60)) / 60
DIM t AS INTEGER
t = Seconds% MOD 60

_PRINTSTRING (600, 560), "Score - " + STR$(CurrentScore%)
_PRINTSTRING (600, 580), "Time Left -" + STR$(Minutes%) + ":" + STR$(t)
StartLevel

FOR i = 1 TO Level.enemies 'free all the sound buffer stream (sound stream will reload again when next gameplay starts.
    _SNDCLOSE Enemie(i).snd
NEXT

COLOR _RGB(255, 255, 255), _RGBA(0, 0, 0, 0)
'checking if the level has benn canceled by the user.
IF Level.cancel THEN
    'free the level background image
    _FREEIMAGE Level.bg
    Level.cancel = 0
    GOTO start
END IF

'checking if game is completed

IF Level.completed THEN
    ' IF COMMAND$(1) = "-loadlevel" THEN
    ' echo "Level : " + STR$(LevelStage%)
    ' echo "Time taken to complete : " + STR$(Level.time - Seconds%)
    ' END IF

    _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), Level.bg

    'crosfading start here -
    DIM blured&

    blured& = _COPYIMAGE(Level.bg)
    BLURIMAGE blured&, 5
    FOR i = 1 TO 255 STEP 20
        _SETALPHA i, , blured&
        _PUTIMAGE , Level.bg
        _PUTIMAGE , blured&
        _DISPLAY
    NEXT

    _FREEIMAGE blured&

    LINE (200, 200)-(_WIDTH - 200, _HEIGHT - 200), _RGBA(0, 0, 0, 180), BF
    _FONT Fonts.normal
    _PRINTSTRING (CenterPrintX("Stage " + STR$(LevelStage%) + "Completed!"), 210), "Stage " + STR$(LevelStage%) + " Completed"
    _FONT Fonts.smaller
    DIM a$
    a$ = "Congratulations!! You created new high score!"

    IF CurrentScore% > HighScore% THEN _PRINTSTRING (CenterPrintX(a$), 250), a$

    _PRINTSTRING (CenterPrintX("Score - " + STR$(CurrentScore%)), 300), "Score - " + STR$(CurrentScore%)
    _PRINTSTRING (CenterPrintX("Bonus Score - " + STR$(Seconds% * 2)), 320), "Bonus Score - " + STR$(Seconds% * 2)
    _PRINTSTRING (CenterPrintX("Total Score - " + STR$(Seconds% * 2 + CurrentScore%)), 340), "Total Score - " + STR$(Seconds% * 2 + CurrentScore%)

    IF LevelStage% = MAX_LEVEL THEN a$ = "Game Completed" ELSE a$ = "Be ready for next stage. Wait a moment..."
    _PRINTSTRING (CenterPrintX(a$), 380), a$

    DO
        IF F = 1 THEN SPRITESHOW ExplosionsZ(0).img: SPRITESHOW ExplosionsZ(1).img
        FOR i = 0 TO 1
            SPRITENEXT ExplosionsZ(i).img
            SPRITEPUT ExplosionsZ(i).x, ExplosionsZ(i).y, ExplosionsZ(i).img
        NEXT
        _LIMIT W.fps
        _DISPLAY
        F = F + 1
    LOOP UNTIL F > 180
    SPRITEHIDE ExplosionsZ(0).img
    SPRITEHIDE ExplosionsZ(1).img
    
    F = 0
    IF COMMAND$(1) = "-loadlevel" THEN SYSTEM
    SaveGame

    IF LevelStage% > MAX_LEVEL THEN
        bd& = _COPYIMAGE(0)
        FOR i = 0 TO 255 STEP 5
            _PUTIMAGE , bd&
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF
            _DISPLAY
        NEXT
        showCredits

        GOTO start
    END IF
    'free the level background image
    _FREEIMAGE Level.bg

    GOTO newgame
END IF
IF Level.over THEN
    COLOR _RGB(255, 0, 0)
    ' IF COMMAND$(1) = "-loadlevel" THEN
    ' echo "Level failed to compete"
    ' END IF

    _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), Level.bg
    'crosfading start here -
    blured& = _COPYIMAGE(Level.bg)
    BLURIMAGE blured&, 5
    FOR i = 1 TO 255 STEP 20
        _SETALPHA i, , blured&
        _PUTIMAGE , Level.bg
        _PUTIMAGE , blured&
        _DISPLAY
    NEXT

    _FREEIMAGE blured&
    LINE (200, 250)-(_WIDTH - 200, _HEIGHT - 250), _RGBA(0, 0, 0, 180), BF
    _FONT Fonts.bigger
    _PRINTSTRING (CenterPrintX("Game Over"), 260), "Game Over"
    _FONT Fonts.smaller
    _PRINTSTRING (CenterPrintX("Click To Continue..."), _HEIGHT - 280), "Click to Continue..."
    _DISPLAY

    DO
        WHILE _MOUSEINPUT: WEND
        IF _MOUSEBUTTON(1) THEN
            WHILE _MOUSEBUTTON(1): WHILE _MOUSEINPUT: WEND: WEND
            EXIT DO
        END IF
        _LIMIT 30
    LOOP
    GOTO start
    'free the level background image
    _FREEIMAGE Level.bg

END IF

404
_MOUSESHOW
_FONT 16
CLS
COLOR _RGB(255, 255, 255)
CIRCLE (_WIDTH / 2, 200), 100
CIRCLE (_WIDTH / 2 - 50, 150), 5
CIRCLE (_WIDTH / 2 + 50, 150), 5
CIRCLE (_WIDTH / 2, 250), 50, , 0, _PI

centerPrint "An Error has ocurred!", 350
centerPrint "Error Code - " + STR$(ERR), 366
IF _INCLERRORFILE$ <> "" THEN
    centerPrint "Error File - " + _INCLERRORFILE$, 382
    centerPrint "Error Line - " + STR$(_INCLERRORLINE), 398
ELSE
    centerPrint "Error File - Main_File", 382
    centerPrint "Error Line - " + STR$(_ERRORLINE), 398
END IF
END







SUB echo (m$) 'always write to console
    DIM preDest AS LONG
    preDest = _DEST
    _DEST _CONSOLE
    PRINT m$
    _DEST preDest
END SUB

SUB showNotification (message$)
    NText$ = message$
    NShow = -1
END SUB

SUB Notify ()
    STATIC imgy
    IF NShow = -1 THEN
        IF NFPSCount% = 0 THEN
            _FONT 16
            DIM __w AS INTEGER, h AS INTEGER, tmp&, preDest AS LONG
            __w = LEN(NText$) * 8 + 40
            h = 36

            tmp& = _NEWIMAGE(__w, h, 32)

            preDest = _DEST
            _DEST tmp&

            COLOR _RGB(10, 10, 10), _RGB(355, 245, 245)
            CLS , _RGB(255, 245, 245)
            _PRINTSTRING (20, 10), NText$

            _DEST preDest
            NImage& = _COPYIMAGE(tmp&, 33)
            _FREEIMAGE tmp&

            imgy = -40
        END IF
        IF NFPSCount% > 0 AND NFPSCount% < 40 THEN
            imgy = imgy + 1
            _PUTIMAGE (_WIDTH / 2 - _WIDTH(NImage&) / 2, imgy), NImage&
        END IF
        IF NFPSCount% > 40 AND NFPSCount% < 160 THEN
            _PUTIMAGE (_WIDTH / 2 - _WIDTH(NImage&) / 2, imgy), NImage&
        END IF
        IF NFPSCount% > 160 AND NFPSCount% < 200 THEN
            _PUTIMAGE (_WIDTH / 2 - _WIDTH(NImage&) / 2, imgy), NImage&
            imgy = imgy - 1
        END IF
        NFPSCount% = NFPSCount% + 1
        IF NFPSCount% > 200 THEN
            _FREEIMAGE NImage&
            NFPSCount% = 0
            NShow = 0
        END IF
    END IF
END SUB


SUB readConfig ()
    DIM F AS INTEGER

    IF NOT _FILEEXISTS("Settings/settings.dat") THEN writeConfig
    F = FREEFILE
    OPEN "Settings/settings.dat" FOR INPUT AS #F
    INPUT #F, W.fullscreen
    INPUT #F, W.music
    INPUT #F, W.sfx
    INPUT #F, W.musicV
    INPUT #F, W.sfxV
    INPUT #F, W.SE
    INPUT #F, W.fps
    CLOSE #F
END SUB

SUB writeConfig ()
    DIM f AS INTEGER

    f = FREEFILE
    OPEN "Settings/settings.dat" FOR OUTPUT AS #f
    PRINT #f, W.fullscreen
    PRINT #f, W.music
    PRINT #f, W.sfx
    PRINT #f, W.musicV
    PRINT #f, W.sfxV
    PRINT #f, W.SE
    PRINT #f, W.fps
    CLOSE #f
END SUB

SUB createConfig ()
    W.fullscreen = 0
    W.music = -1
    W.sfx = -1
    W.musicV = 1
    W.sfxV = 1
    W.SE = -1
    W.fps = 90
    writeConfig
END SUB

SUB loadComponents ()
    IF W.fullscreen = 0 THEN
        IF _FULLSCREEN <> 0 THEN _FULLSCREEN _OFF
    ELSEIF W.fullscreen = 1 THEN
        IF _FULLSCREEN <> 1 THEN _FULLSCREEN _STRETCH , _SMOOTH
    ELSEIF W.fullscreen = 2 THEN
        IF _FULLSCREEN <> 2 THEN _FULLSCREEN _SQUAREPIXELS , _SMOOTH
    END IF

    'SFXs
    ' screen_conf:
    IF Gun1& = 0 THEN Gun1& = _SNDOPEN("SFX/Gun1.ogg", "sync,vol,pause")
    IF Gun2& = 0 THEN Gun2& = _SNDOPEN("SFX/Gun2.ogg", "sync,vol,pause")
    IF Bird& = 0 THEN Bird& = _SNDOPEN("SFX/bird.ogg", "sync,vol,pause")
    IF Crow& = 0 THEN Crow& = _SNDOPEN("SFX/Crow.ogg", "sync,vol,pause")
    IF Eagle& = 0 THEN Eagle& = _SNDOPEN("SFX/Eagle.ogg", "sync,vol,pause")
    IF Expos& = 0 THEN Expos& = _SNDOPEN("SFX/Explosion.mp3", "sync,vol,pause")
    IF Jet& = 0 THEN Jet& = _SNDOPEN("SFX/Jet.ogg", "sync,vol,pause")
    IF RainSound& = 0 THEN RainSound& = _SNDOPEN("SFX/Rain.mp3", "vol,sync,pause")

    IF Musics&(0) = 0 THEN Musics&(0) = _SNDOPEN("Musics/Hunter's_Revenge-Against_Evil.mp3", "sync,vol,pause")
    IF Musics&(1) = 0 THEN Musics&(1) = _SNDOPEN("Musics/Hunter's_Revenge-End_Of_Game.mp3", "sync,vol,pause")
    IF Musics&(2) = 0 THEN Musics&(2) = _SNDOPEN("Musics/Hunter's_Revenge-Who's_Next.mp3", "sync,vol,pause")

    setMusicVol W.musicV
    IF NOT W.music THEN 'if menu background music disable, then stop the musics, regardless of whether the are being played or not.
        _SNDSTOP Musics&(0)
        _SNDSTOP Musics&(1)
        _SNDSTOP Musics&(2)
    END IF

    W.done = -1
END SUB

SUB Splash ()

    CLS

    DIM stars&, x AS INTEGER, y AS INTEGER, F AS INTEGER

    stars& = _NEWIMAGE(_WIDTH * 2, _HEIGHT, 32)
    _DEST stars&
    DO
        x = INT(RND * _WIDTH(stars&))
        y = INT(RND * _HEIGHT)
        PSET (x, y), _RGB(255, 255, 255)
        F = F + 1
    LOOP UNTIL F > 700

    DIM spT&, sp&, eft1&, p AS INTEGER, a AS INTEGER, xx AS INTEGER

    _DEST 0
    spT& = _LOADIMAGE("Images\splash.png")
    _CLEARCOLOR _RGB(0, 0, 0), spT&
    sp& = _COPYIMAGE(spT&, 33)
    F = 0
    eft1& = _NEWIMAGE(_WIDTH, _HEIGHT, 32)
    _DEST eft1&
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGB(0, 0, 50), BF
    _DEST 0

    p = 6
    FPSStart
    DO
        _SETALPHA a, , eft1&: _PUTIMAGE , eft1&
        _PUTIMAGE (xx, 0), stars&
        _PUTIMAGE , sp&
        xx = xx - 1
        IF xx < -_WIDTH - 2 THEN xx = 0
        _LIMIT 60
        a = a + p
        IF a > 250 THEN p = -p
        IF a < 6 THEN p = 6
        _DISPLAY
        F% = F% + 1
        FPSCurrent% = FPSCurrent% + 1
    LOOP UNTIL F% > 360

    FPSEnd
    CLS

    _FREEIMAGE sp&
    _FREEIMAGE spT&
    _FREEIMAGE eft1&
    _FREEIMAGE stars&
END SUB

SUB FPSStart ()
    ON TIMER(FPSEvent, 1) FPS
    ON TIMER(FPSEvt, 0.01) FPSShow
    TIMER(FPSEvent) ON
    TIMER(FPSEvt) ON
END SUB

SUB FPS ()
    FPSRate% = FPSCurrent%
    FPSCurrent% = 0
END SUB

SUB FPSShow ()
    COLOR _RGB(255, 255, 255)
    _PRINTSTRING (720, 0), STR$(FPSRate%) + " FPS"
END SUB

SUB FPSEnd ()
    TIMER(FPSEvent) OFF
    TIMER(FPSEvt) OFF
END SUB

SUB LoaderStart ()
    Loader& = _LOADIMAGE("Images\loader.gif", 33)
    LoaderEvt! = _FREETIMER
    ON TIMER(LoaderEvt!, 0.1) ShowLoader
    TIMER(LoaderEvt!) ON
END SUB

SUB LoaderEnd ()
    TIMER(LoaderEvt!) OFF
    _FREEIMAGE Loader&
END SUB

SUB ShowLoader ()
    IF LoaderCF% = 0 THEN LoaderCF% = 1
    _PUTIMAGE (LoaderX%, LoaderY%), Loader&, 0, (LoaderCF% * 48 - 48, 0)-(LoaderCF% * 48 - 1, 48)
    LoaderCF% = LoaderCF% + 1
    IF LoaderCF% > 8 THEN LoaderCF% = 1
    _DISPLAY
END SUB

' SUB PlayMovie (m$)
' LoaderStart

' DIM f AS INTEGER, n AS LONG, i AS LONG, k AS INTEGER

' f = FREEFILE
' OPEN "Movies\" + m$ + "\" + m$ + ".txt" FOR INPUT AS #f
' INPUT #f, n
' CLOSE #f
' DIM Temps_Buffers&(n)
' FOR i = 1 TO n
' Temps_Buffers&(i) = _LOADIMAGE("Movies\" + m$ + "\produce" + LTRIM$(RTRIM$(STR$(i))) + ".jpg", 33)
' NEXT
' LoaderEnd
' FOR i = 1 TO n
' FOR k = 1 TO 3
' _PUTIMAGE , Temps_Buffers&(i)
' _DISPLAY
' NEXT
' _DELAY .05
' _FREEIMAGE Temps_Buffers&(i)
' NEXT
' ERASE Temps_Buffers&
' END SUB

SUB GameMenu ()
    _PUTIMAGE , Menubg&
    DIM n%
    'Menu background music
    IF W.music THEN
        n% = p5random(0, 2)
        IF NOT (_SNDPLAYING(Musics&(0)) OR _SNDPLAYING(Musics&(1)) OR _SNDPLAYING(Musics&(2))) THEN _SNDPLAY Musics&(n%)
    END IF

    ON TIMER(GlobalEvent, 0.01) GameMenu2
    TIMER(GlobalEvent) ON
    DO
        WHILE _MOUSEINPUT: WEND
        Mouse.x = _MOUSEX: Mouse.y = _MOUSEY
        Mouse.lclick = _MOUSEBUTTON(1)
        _LIMIT W.fps
        IF MenuChoice > 0 THEN EXIT DO
    LOOP
    TIMER(GlobalEvent) OFF
END SUB

SUB GameMenu2 ()
    IF _SCREENICON THEN EXIT SUB

    _PUTIMAGE , Menubg&
    LINE (200, 130)-(_WIDTH - 200, 450), _RGBA(0, 0, 0, 150), BF

    DIM i AS INTEGER

    FOR i = 0 TO 4
        COLOR _RGB(255, 255, 255), _RGBA(0, 0, 0, 0)
        IF Mouse.x > 200 AND Mouse.x < 600 AND Mouse.y > GameMenus(i).y - 20 AND Mouse.y < GameMenus(i).y + _FONTHEIGHT(Fonts.bigger) THEN
            LINE (200, GameMenus(i).y - 20)-(600, GameMenus(i).y + _FONTHEIGHT(Fonts.bigger)), _RGBA(255, 100, 0, 100), BF
            SPRITEPUT 150, GameMenus(i).y + 20, MenuBlood%
            SPRITENEXT MenuBlood%
            '       _PRINTSTRING (GameMenus(i).x, GameMenus(i).y), RTRIM$(GameMenus(i).text)
            _PUTIMAGE (200, GameMenus(i).y), GameMenus(i).img
            IF Mouse.lclick THEN
                TIMER(GlobalEvent!) OFF
                SELECT CASE i
                    CASE 0
                        MenuChoice = 1
                    CASE 1
                        MenuChoice = 2
                    CASE 2
                        MenuChoice = 3
                    CASE 3
                        MenuChoice = 4
                    CASE 4
                        MenuChoice = 5

                END SELECT
            END IF
        ELSE
            '      _PRINTSTRING (GameMenus(i).x, GameMenus(i).y), RTRIM$(GameMenus(i).text)
            _PUTIMAGE (200, GameMenus(i).y), GameMenus(i).img
        END IF
    NEXT
    IF Mouse.hovering THEN
        _PUTIMAGE (Mouse.x - 16, Mouse.y - 16), Mouse.cursor2
        _DISPLAY
    ELSE
        _PUTIMAGE (Mouse.x - 16, Mouse.y - 16), Mouse.cursor
        _DISPLAY
    END IF

END SUB


FUNCTION CenterPrintX (m$)
    DIM i AS INTEGER, a AS INTEGER
    FOR i = 1 TO LEN(m$)
        a = a + _PRINTWIDTH(MID$(m$, i, 1))
    NEXT
    CenterPrintX = (_WIDTH / 2) - (a / 2)
END FUNCTION

FUNCTION getCurrentLevel% ()
    IF NOT _FILEEXISTS("Save_Game/save.dat") THEN getCurrentLevel% = 1: EXIT FUNCTION
    DIM F AS INTEGER, tmp AS INTEGER
    F = FREEFILE
    OPEN "Save_Game\save.dat" FOR BINARY AS #F
    SEEK F, 3
    GET #F, , tmp
    getCurrentLevel% = tmp
    CLOSE #F
END FUNCTION

SUB LoadLevel ()
    Level.completed = 0
    Level.over = 0
    DIM F AS INTEGER
    F = FREEFILE
    ' IF COMMAND$(1) = "-loadlevel" THEN
    ' GOTO skip_game_save_info
    ' END IF
    IF NOT _FILEEXISTS("Save_Game\save.dat") THEN
        OPEN "Save_Game\save.dat" FOR BINARY AS #F
        LevelStage% = 1
        HighScore% = 0
        PUT #F, , HighScore%
        PUT #F, , LevelStage%
        CLOSE #F
    ELSE
        OPEN "Save_Game\save.dat" FOR BINARY AS #F
        GET #F, , HighScore%
        GET #F, , LevelStage%
        CLOSE #F
    END IF
    skip_game_save_info:::
    ' echo "loading level/stage : " + STR$(LevelStage%)
    OPEN "Stages\Stage" + RTRIM$(LTRIM$(STR$(LevelStage%))) + ".dat" FOR INPUT AS #F
    INPUT #F, Level.enemies
    INPUT #F, Level.scenes
    INPUT #F, Level.time
    INPUT #F, Level.mode
    INPUT #F, Level.background
    CLOSE #F
    LevelStage2% = LevelStage%
    Level.bg = _LOADIMAGE("Images\" + RTRIM$(Level.background))
    Seconds% = Level.time
    OldSeconds% = Seconds%
    'LevelStage% = clevel%
END SUB

SUB StartLevel ()

    'Stop music during gameplay
    DIM i AS INTEGER, k&, onn&, offf&, bd&, bd2&, ac&, gfx&
    IF W.music THEN
        FOR i = 0 TO 2
            _SNDSTOP Musics&(i)
        NEXT 'stops all musics
    END IF
    IF W.sfx THEN updateSfxVolume

    ON TIMER(GameRenderingEvent, 1 / W.fps) UpdateStatus
    ON TIMER(TimerEvent, 1) UpdateTime
    TIMER(GameRenderingEvent) ON
    TIMER(TimerEvent) ON
    Mouse.lclick = 0
    Mouse.rclick = 0
    Mouse.mclick = 0
    DO
        WHILE _MOUSEINPUT: WEND

        Mouse.x = _MOUSEX: Mouse.y = _MOUSEY
        IF _MOUSEBUTTON(1) THEN
            WHILE _MOUSEBUTTON(1): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.lclick = -1
        END IF
        IF _MOUSEBUTTON(2) THEN
            WHILE _MOUSEBUTTON(2): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.rclick = -1
        END IF
        IF _MOUSEBUTTON(3) THEN
            WHILE _MOUSEBUTTON(3): WHILE _MOUSEINPUT: WEND: WEND
            Mouse.mclick = -1
        ELSE Mouse.mclick = 0
        END IF

        k& = _KEYHIT
        IF k& = 27 OR Mouse.mclick THEN
            TIMER(GameRenderingEvent) OFF
            TIMER(TimerEvent) OFF
            IF W.sfx THEN PauseSound 'Pause the sounds

            onn& = _LOADIMAGE("Images/on.png", 33)
            offf& = _LOADIMAGE("Images/off.png", 33)

            bd& = _COPYIMAGE(0)
            bd2& = _COPYIMAGE(0)

            BLURIMAGE bd2&, 5
            gfx& = _NEWIMAGE(500, 156, 32)
            _DEST gfx&
            CLS , 0 'make it transparent
            LINE (0, 0)-STEP(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, 150), BF
            FOR i = 16 TO 19
                _PUTIMAGE (0, GameMenus(i).y - 222), GameMenus(i).img2
            NEXT
            _DEST 0

            FOR i = 0 TO 255 STEP 10
                _SETALPHA i, , bd2&
                _PUTIMAGE , bd&
                _PUTIMAGE , bd2&
                LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i / 3), BF
                _PUTIMAGE (150, 222), gfx&, 0, (0, 0)-(500, p5map(i, 0, 255, 0, 136))
                _DISPLAY
            NEXT
            ac& = _COPYIMAGE(0)
            DO
                WHILE _MOUSEINPUT: WEND
                Mouse.x = _MOUSEX: Mouse.y = _MOUSEY
                Mouse.lclick = 0
                Mouse.rclick = 0
                IF _MOUSEBUTTON(1) THEN
                    WHILE _MOUSEBUTTON(1): WHILE _MOUSEINPUT: WEND: WEND
                    Mouse.lclick = -1
                END IF
                IF _MOUSEBUTTON(2) THEN
                    WHILE _MOUSEBUTTON(2): WHILE _MOUSEINPUT: WEND: WEND
                    Mouse.rclick = -1
                END IF

                _PUTIMAGE , ac&
                LINE (150, 222)-STEP(500, 136), _RGBA(0, 0, 0, 50), BF
                FOR i = 16 TO 19
                    IF Mouse.x > 150 AND Mouse.x < 650 AND Mouse.y > GameMenus(i).y - 10 AND Mouse.y < GameMenus(i).y + 24 THEN
                        IF Mouse.lclick THEN
                            SELECT CASE i
                                CASE 16
                                    IF W.fullscreen > 0 THEN W.fullscreen = 0 ELSE W.fullscreen = 1
                                CASE 17
                                    W.musicV = W.musicV + .1
                                    IF W.musicV > 1 THEN W.musicV = .1
                                CASE 18
                                    W.sfxV = W.sfxV + .1
                                    IF W.sfxV > 1 THEN W.sfxV = .1
                                CASE 19
                                    Level.cancel = -1
                                    EXIT DO
                            END SELECT
                        END IF
                        LINE (150, GameMenus(i).y - 10)-(650, GameMenus(i).y + 24), _RGBA(255, 100, 0, 100), BF
                    END IF
                    _PUTIMAGE (150, GameMenus(i).y), GameMenus(i).img
                    SELECT CASE i
                        CASE 16
                            IF W.fullscreen > 0 THEN _PUTIMAGE (580, GameMenus(i).y - 3), onn& ELSE _PUTIMAGE (580, GameMenus(i).y - 3), offf&
                        CASE 17
                            _FONT Fonts.normal
                            IF W.musicV > .9 THEN
                                _PRINTSTRING (630 - txtWidth(" 10"), GameMenus(i).y), " 10 "
                            ELSE
                                _PRINTSTRING (630 - txtWidth(STR$(INT(W.musicV * 10))), GameMenus(i).y), STR$(INT(W.musicV * 10))
                            END IF
                        CASE 18
                            _FONT Fonts.normal
                            IF W.sfxV > .9 THEN
                                _PRINTSTRING (630 - txtWidth(" 10"), GameMenus(i).y), " 10 "
                            ELSE
                                _PRINTSTRING (630 - txtWidth(STR$(INT(W.sfxV * 10))), GameMenus(i).y), STR$(INT(W.sfxV * 10))
                            END IF
                    END SELECT
                NEXT
                IF _KEYHIT = 27 OR _MOUSEBUTTON(3) THEN EXIT DO
                _LIMIT W.fps
                _PUTIMAGE (Mouse.x - 8, Mouse.y - 8), Mouse.cursor
                _DISPLAY
            LOOP
            FOR i = 255 TO 0 STEP -10
                _SETALPHA i, , bd2&
                _PUTIMAGE , bd&
                _PUTIMAGE , bd2&
                LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i / 3), BF
                _PUTIMAGE (150, 222), gfx&, 0, (0, 0)-(500, p5map(i, 0, 255, 0, 222))
                _DISPLAY
            NEXT

            _PUTIMAGE , bd& 'Erase that menu line
            _FREEIMAGE bd&
            _FREEIMAGE bd2&
            _FREEIMAGE ac&
            _FREEIMAGE gfx&
            _FREEIMAGE onn&
            _FREEIMAGE offf&
            loadComponents

            IF W.sfx THEN 'update the sfx volume and play the paused sound.
                updateSfxVolume
                IF NOT Level.cancel THEN PlayPausedSound
            END IF

            TIMER(GameRenderingEvent) ON
            TIMER(TimerEvent) ON

            IF Level.cancel THEN EXIT DO
        END IF
        _LIMIT W.fps
    LOOP UNTIL Level.completed OR Level.over
    TIMER(GameRenderingEvent) OFF
    CloseTime
    FOR i = 0 TO 20
        IF Bloods(i).active THEN
            Bloods(i).active = 0
            SPRITEHIDE Bloods(i).img
        END IF
        IF explosions(i).active THEN
            explosions(i).active = 0
            SPRITEHIDE explosions(i).img
        END IF
    NEXT
    FOR i = 0 TO UBOUND(ShotScore)
        ShotScore(i).active = 0
    NEXT
END SUB

SUB UpdateStatus ()
    ' $checking:off
    STATIC thunder_f_count, thunder_ha_count, thunder_ha_count_limit
    DIM i AS INTEGER, t AS INTEGER, tmp&, tmp2&

    IF Seconds% < OldSeconds% OR OldScore% < CurrentScore% THEN _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), Level.bg

    IF _SCREENICON THEN EXIT SUB
    FOR i = 1 TO Level.enemies
        IF Enemie(i).u = Level.u AND Enemie(i).active = 0 AND Enemie(i).scene = Level.currentScene THEN
            Enemie(i).active = -1
            PlayEnemieMusic i
            'echo "[New Enemie] (Scene " + STR$(Level.currentScene) + ")"
            'echo "Type : " + Enemie(i).typ
            'echo "u : " + STR$(Enemie(i).u)
            'echo "Current u : " + STR$(Enemie(i).u)
            'echo " Enemie Scene : " + STR$(Enemie(i).scene)
            'echo "Enemie Movement : " + STR$(Enemie(i).m)
        END IF
    NEXT
    FOR i = 1 TO Level.enemies
        IF Enemie(i).active AND Enemie(i).scene = Level.currentScene THEN
            'IF Enemie(i).u = Level.u THEN
            '    echo "Rendered"
            '    echo "********************************************************************************"
            'END IF
            IF Enemie(i).f > Enemie(i).n THEN SPRITENEXT Enemie(i).img: Enemie(i).f = 0

            SPRITEPUT Enemie(i).x, Enemie(i).y, Enemie(i).img

            Enemie(i).x = Enemie(i).x + Enemie(i).m
            Enemie(i).f = Enemie(i).f + 1

            IF W.SE THEN _SNDBAL Enemie(i).snd, p5map(Enemie(i).x, 0, _WIDTH, -1, 1), p5map(Enemie(i).y, 0, _HEIGHT, 1, -1), , 2

            IF Enemie(i).x > _WIDTH + SPRITECURRENTWIDTH(Enemie(i).img) THEN Enemie(i).m = -Enemie(i).m: SPRITEFLIP Enemie(i).img, HORIZONTAL: PlayEnemieMusic i
            IF Enemie(i).x < -SPRITECURRENTWIDTH(Enemie(i).img) THEN Enemie(i).m = -Enemie(i).m: SPRITEFLIP Enemie(i).img, NONE: PlayEnemieMusic i

            IF Mouse.x > SPRITEX1(Enemie(i).img) AND Mouse.x < SPRITEX2(Enemie(i).img) AND Mouse.y > SPRITEY1(Enemie(i).img) AND Mouse.y < SPRITEY2(Enemie(i).img) THEN
                Mouse.hovering = -1

                IF Mouse.lclick THEN Enemie(i).life = Enemie(i).life - Gun.damage
                IF Enemie(i).life < 0 THEN Enemie(i).life = 0

                'Showing Enemie current life with life bar
                IF Enemie(i).life = 0 THEN
                    _PUTIMAGE (Enemie(i).x - SPRITECURRENTWIDTH(Enemie(i).img) / 2, Enemie(i).y - 30), lifeBars(0)
                ELSE
                    _PUTIMAGE (Enemie(i).x - SPRITECURRENTWIDTH(Enemie(i).img) / 2, Enemie(i).y - 30), lifeBars(INT(Enemie(i).life / Enemie(i).life2 * 100) - 1) 'shows life bar :)
                END IF
            END IF
            'checking if any enemie is dead :D
            IF Enemie(i).life = 0 THEN
                SPRITEHIDE Enemie(i).img
                Enemie(i).ending = -1
                Enemie(i).active = 0
                StopEnemieMusic i
                'echo "[Enemie Dead]"
                'echo "Type : " + Enemie(i).typ
                'echo "Enemie Scene" + STR$(Enemie(i).scene)
                'echo "--------------------------------------------------------------------------------------"
                'You will get more score with ShotGun :P

                IF Gun.id = 1 THEN CurrentScore% = CurrentScore% + INT(Enemie(i).points * 1.4)

                MakeScoreFlash Enemie(i).x, Enemie(i).y, Enemie(i).points
                CurrentScore% = CurrentScore% + Enemie(i).points
                MakeBloods Enemie(i).x, Enemie(i).y, Enemie(i).typ
            END IF
        END IF
    NEXT

    IF Mouse.rclick THEN
        IF Gun.id = 1 THEN Gun.id = 2: Gun.name = "Ak-47": Gun.damage = 6 ELSE Gun.id = 1: Gun.name = "Shot Gun": Gun.damage = 3
        Mouse.rclick = 0
    END IF
    FOR i = 0 TO 20
        IF Bloods(i).active THEN
            IF Bloods(i).f > Bloods(i).n THEN SPRITENEXT Bloods(i).img: Bloods(i).f = 0: Bloods(i).currentFrame = Bloods(i).currentFrame + 1
            Bloods(i).f = Bloods(i).f + 1
            SPRITEPUT Bloods(i).x, Bloods(i).y, Bloods(i).img
            IF Bloods(i).currentFrame > Bloods(i).totalFrames * 2 THEN Bloods(i).active = 0: SPRITEHIDE Bloods(i).img
        END IF
    NEXT
    FOR i = 0 TO 20
        IF explosions(i).active THEN
            IF explosions(i).f > explosions(i).n THEN SPRITENEXT explosions(i).img: explosions(i).f = 0: explosions(i).currentFrame = explosions(i).currentFrame + 1
            explosions(i).f = explosions(i).f + 1
            SPRITEPUT explosions(i).x, explosions(i).y, explosions(i).img
            IF explosions(i).currentFrame > explosions(i).totalFrames THEN explosions(i).active = 0: SPRITEHIDE explosions(i).img
        END IF
    NEXT

    IF Seconds% < OldSeconds% OR OldScore% < CurrentScore% THEN
        IF Seconds% < 1 THEN Level.over = -1
        OldSeconds% = Seconds%
        OldScore% = CurrentScore%
        IF Seconds% < 11 THEN COLOR _RGB(255, 0, 0) ELSE COLOR _RGB(255, 255, 255)
        'redraw scoreboard
        _PUTIMAGE (0, 520), ScoreBoard&
        _PUTIMAGE (50, 550)-(170, 590), GunImg&(Gun.id - 1)
        _FONT Fonts.smaller
        _PRINTSTRING (40, 580), RTRIM$(Gun.name)
        _PRINTSTRING (600, 560), "Score - " + STR$(CurrentScore%)
        IF Seconds% >= 60 THEN t = Seconds% MOD 60 ELSE t = Seconds%
        _PRINTSTRING (600, 580), "Time left - " + STR$(Minutes%) + ":" + STR$(t)
        _FONT Fonts.normal
        IF randomLevels THEN _PRINTSTRING (CenterPrintX("Random Levels"), 560), "Random Levels" ELSE _PRINTSTRING (CenterPrintX("Stage " + STR$(LevelStage%)), 560), "Stage " + STR$(LevelStage%)

    END IF

    Level.u = Level.u + 1
    'creating new game scene
    IF SceneEnd(Level.currentScene) THEN
        Level.currentScene = Level.currentScene + 1
        Level.u = 0
        'echo "Current Scene : " + STR$(Level.currentScene)
        IF Level.currentScene > Level.scenes THEN Level.completed = -1
    END IF

    'game MODS
    SELECT CASE Level.mode
        CASE FOGMODE
            Fogs.x = Fogs.x - Fogs.move
            IF Fogs.x < -1600 OR Fogs.x > 0 THEN Fogs.move = -Fogs.move
            _PUTIMAGE (Fogs.x, 0), Fogs.handle

        CASE THUNDERMODE
            FallDrops
            DrawDrops

        CASE STORMMODE
            _PUTIMAGE (StormX%, 0), StormImg&
            StormX% = StormX% - 1
            IF StormX% < -2300 THEN StormX% = 0

        CASE FOGMODE + THUNDERMODE
            Fogs.x = Fogs.x - Fogs.move
            IF Fogs.x < -1600 OR Fogs.x > 0 THEN Fogs.move = -Fogs.move
            _PUTIMAGE (Fogs.x, 0), Fogs.handle

            FallDrops
            DrawDrops

        CASE FOGMODE + THUNDERMODE + 7
            Fogs.x = Fogs.x - Fogs.move
            IF Fogs.x < -1600 OR Fogs.x > 0 THEN Fogs.move = -Fogs.move
            _PUTIMAGE (Fogs.x, 0), Fogs.handle

            FallDrops
            DrawDrops
        CASE STORMMODE + THUNDERMODE
            _PUTIMAGE (StormX%, 0), StormImg&
            StormX% = StormX% - 1
            IF StormX% < -2300 THEN StormX% = 0

            FallDrops
            DrawDrops

        CASE STORMMODE + FOGMODE + THUNDERMODE
            Fogs.x = Fogs.x - Fogs.move
            IF Fogs.x < -1600 OR Fogs.x > 0 THEN Fogs.move = -Fogs.move
            _PUTIMAGE (Fogs.x, 0), Fogs.handle

            _PUTIMAGE (StormX%, 0), StormImg&
            StormX% = StormX% - 1
            IF StormX% < -2300 THEN StormX% = 0

            FallDrops
            DrawDrops

    END SELECT

    'scores effect
    FOR i = 0 TO UBOUND(ShotScore)
        IF ShotScore(i).active = -1 THEN
            ShotScore(i).sclX = SIN(ShotScore(i).__ops) * .5 + .5
            _PUTIMAGE (ShotScore(i).x - (ShotScore(i).sclX * _WIDTH(ShotScore(i).img) / 2), ShotScore(i).y - (ShotScore(i).sclX * _HEIGHT(ShotScore(i).img)) / 2)-(ShotScore(i).x + (ShotScore(i).sclX * _WIDTH(ShotScore(i).img)) / 2, ShotScore(i).y + (ShotScore(i).sclX * _HEIGHT(ShotScore(i).img)) / 2), ShotScore(i).img
            ShotScore(i).__ops = ShotScore(i).__ops + .1
            IF ShotScore(i).__ops > _PI(1.5) THEN
                ShotScore(i).active = 0
            END IF
        END IF
    NEXT

    'countdown when game time is less or equal to 10s
    IF Seconds% < 11 THEN
        COLOR _RGB(255, 0, 0)
        _FONT Fonts.biggest
        _PRINTSTRING (CenterPrintX(RTRIM$(LTRIM$(STR$(Seconds%)))), _HEIGHT / 2 - _FONTHEIGHT / 2), RTRIM$(LTRIM$(STR$(Seconds%)))
    END IF

    'cursors
    IF Mouse.lclick THEN
        Mouse.lclick = 0
        IF W.sfx THEN
            IF Gun.id = 1 THEN _SNDPLAYCOPY Gun1& ELSE _SNDPLAYCOPY Gun2&
        END IF
    END IF
    IF Mouse.hovering THEN
        Mouse.hovering = 0
        _PUTIMAGE (Mouse.x - 16, Mouse.y - 16), Mouse.cursor2
    ELSE
        _PUTIMAGE (Mouse.x - 16, Mouse.y - 16), Mouse.cursor
    END IF

    IF Level.mode = THUNDERMODE OR Level.mode = THUNDERMODE + FOGMODE + 7 THEN
        IF thunder_ha_count_limit = 0 THEN thunder_ha_count_limit = p5random(1, 4)
        IF ThunderEvent = 0 THEN ThunderEvent = p5random(30, 340)
        ThunderCount = ThunderCount + 1
        IF ThunderCount > ThunderEvent THEN
            thunder_f_count = thunder_f_count + 1
            tmp& = _COPYIMAGE(0)
            tmp2& = _COPYIMAGE(0)
            MakeThunderImage tmp&
            _PUTIMAGE , tmp&
            _DISPLAY
            _PUTIMAGE , tmp2&
            _FREEIMAGE tmp&
            _FREEIMAGE tmp2&
            IF thunder_f_count > 3 THEN
                IF thunder_ha_count < thunder_ha_count_limit THEN
                    ' ThunderCount = 0
                    thunder_f_count = 0
                    ThunderEvent = ThunderEvent + p5random(4, 25) + 3
                    thunder_ha_count = thunder_ha_count + 1
                ELSE
                    thunder_ha_count = 0
                    thunder_f_count = 0
                    ThunderEvent = 0
                    ThunderCount = 0
                    thunder_ha_count_limit = p5random(1, 4)
                END IF
            END IF
        ELSE
            _DISPLAY
        END IF
    ELSE
        _DISPLAY
    END IF
    ' $checking:on
END SUB

SUB MakeBloods (x, y, typ AS STRING * 16)
    SELECT CASE RTRIM$(typ)
        CASE "jet1", "jet2", "jet3"
            MakeExplosions x, y
            EXIT SUB
    END SELECT
    DIM i AS INTEGER
    FOR i = 0 TO 20
        IF Bloods(i).active = 0 THEN
            Bloods(i).active = -1
            Bloods(i).x = x
            Bloods(i).y = y
            Bloods(i).currentFrame = 1
            SPRITESHOW Bloods(i).img
            EXIT SUB
        END IF
    NEXT
END SUB

SUB MakeExplosions (x, y)
    DIM i AS INTEGER
    FOR i = 0 TO 20
        IF explosions(i).active = 0 THEN
            explosions(i).active = -1
            explosions(i).x = x
            explosions(i).y = y
            explosions(i).currentFrame = 1
            SPRITESHOW explosions(i).img
            IF W.sfx THEN _SNDPLAY Expos&
            EXIT SUB
        END IF
    NEXT
END SUB

SUB MakeScoreFlash (x, y, s)
    DIM i AS INTEGER
    FOR i = 0 TO UBOUND(ShotScore)
        IF ShotScore(i).active = 0 THEN
            ShotScore(i).active = -1
            ShotScore(i).x = x
            ShotScore(i).y = y
            ShotScore(i).__ops = -_PI(.5)
            SELECT CASE s
                CASE 10
                    ShotScore(i).img = scoresImage(0)
                CASE 20
                    ShotScore(i).img = scoresImage(1)
                CASE 35
                    ShotScore(i).img = scoresImage(2)
                CASE 50
                    ShotScore(i).img = scoresImage(3)
                CASE 75
                    ShotScore(i).img = scoresImage(4)
                CASE 100
                    ShotScore(i).img = scoresImage(5)
            END SELECT
        END IF
    NEXT
END SUB

SUB UpdateTime ()
    Seconds% = Seconds% - 1
    Minutes% = (Seconds% - (Seconds% MOD 60)) / 60
END SUB

SUB CloseTime
    TIMER(TimerEvent) OFF
END SUB

SUB PlayEnemieMusic (which&)
    IF W.sfx = 0 THEN EXIT SUB

    _SNDPLAY Enemie(which&).snd
END SUB

SUB StopEnemieMusic (which&)
    _SNDSTOP Enemie(which&).snd
    Enemie(which&).sndPaused = 2 '2 for stop and 1 for paused
END SUB

SUB updateSfxVolume ()
    IF NOT W.sfx THEN EXIT SUB

    DIM i AS INTEGER
    FOR i = 1 TO Level.enemies
        _SNDVOL Enemie(i).snd, W.sfxV
    NEXT
    _SNDVOL RainSound&, W.sfxV
END SUB

SUB setMusicVol (v!)
    IF NOT W.music THEN EXIT SUB
    _SNDVOL Musics&(0), v!
    _SNDVOL Musics&(1), v!
    _SNDVOL Musics&(2), v!
END SUB

SUB PlayPausedSound ()
    DIM i AS INTEGER
    FOR i = 1 TO Level.enemies
        IF Enemie(i).sndPaused = 1 THEN Enemie(i).sndPaused = 0: _SNDPLAY Enemie(i).snd
    NEXT
    IF Level.mode = THUNDERMODE OR Level.mode = FOGMODE + THUNDERMODE THEN
        IF NOT _SNDPLAYING(RainSound&) THEN _SNDPLAY RainSound&
    END IF
END SUB

SUB PauseSound ()

    DIM i AS INTEGER
    FOR i = 1 TO Level.enemies
        IF Enemie(i).sndPaused = 0 THEN _SNDSTOP Enemie(i).snd: Enemie(i).sndPaused = 1
    NEXT

    IF _SNDPLAYING(RainSound&) THEN _SNDSTOP RainSound&

END SUB

FUNCTION SceneEnd (which%)
    DIM i AS INTEGER, d AS _BYTE

    FOR i = 1 TO Level.enemies
        IF Enemie(i).ending = 0 AND Enemie(i).scene = which% THEN d = -1: EXIT FOR
    NEXT
    IF d = 0 THEN SceneEnd = -1 ELSE SceneEnd = 0
END FUNCTION

SUB SaveGame ()
    DIM a$, F AS INTEGER
    a$ = "Save_Game\save.dat"
    KILL a$
    F = FREEFILE
    LevelStage% = LevelStage% + 1
    OPEN a$ FOR BINARY AS #F
    IF HighScore% < CurrentScore% THEN PUT #F, , CurrentScore% ELSE PUT #F, , HighScore%
    PUT #F, , LevelStage%
    CLOSE #F
END SUB

SUB SetupRain ()
    DIM i AS INTEGER
    FOR i = 0 TO UBOUND(Drop)
        Drop(i).x = RND * _WIDTH
        Drop(i).y = -(RND * (_HEIGHT * 3))
        Drop(i).z = INT(RND * 1)
        Drop(i).yspeed = Map(Drop(i).z, 0, 1, 1, 2)
        Drop(i).len = Map(Drop(i).z, 0, 1, 8, 16)
        Drop(i).gravity = Map(Drop(i).z, 0, 1, 0.1, 0.3)
    NEXT
    RainVol# = -1.0
END SUB

SUB FallDrops ()
    DIM i AS INTEGER
    FOR i = 0 TO UBOUND(Drop)
        Drop(i).y = Drop(i).y + Drop(i).yspeed
        Drop(i).yspeed = Drop(i).yspeed + Drop(i).gravity
        IF Drop(i).y > _HEIGHT THEN Drop(i).y = RND * -400: Drop(i).yspeed = Map(Drop(i).z, 0, 1, 1, 2)
    NEXT
END SUB

SUB DrawDrops ()
    DIM i AS INTEGER
    IF W.sfx THEN
        ' IF RainVol# < .98 THEN RainVol# = RainVol# + 0.01: _SNDBAL RainSound&, 0, 0, RainVol#
        IF NOT _SNDPLAYING(RainSound&) THEN _SNDPLAY RainSound&
    END IF
    FOR i = 0 TO UBOUND(Drop)
        IF Drop(i).z = 0 THEN _PUTIMAGE (Drop(i).x, Drop(i).y), Rainx8& ELSE _PUTIMAGE (Drop(i).x, Drop(i).y), Rainx16&
    NEXT

END SUB


FUNCTION Map (value, r1, r2, e1, e2)
    IF value = r1 THEN Map = e1
    IF value = r2 THEN Map = e2
END FUNCTION

SUB MakeThunderImage (original_img&)
    IF original_img& = -1 THEN EXIT SUB

    $CHECKING:OFF
    DIM buffer AS _MEM, o AS _OFFSET, o2 AS _OFFSET
    DIM b AS _UNSIGNED _BYTE, n AS _BYTE
    n = p5random(30, 120)

    buffer = _MEMIMAGE(original_img&)
    o = buffer.OFFSET
    o2 = o + _WIDTH(original_img&) * _HEIGHT(original_img&) * 4
    DO
        ' echo str$(o)
        b = _MEMGET(buffer, o, _UNSIGNED _BYTE)
        IF b + n < 256 THEN b = b + n ELSE b = 255
        _MEMPUT buffer, o, b AS _UNSIGNED _BYTE
        b = _MEMGET(buffer, o + 1, _UNSIGNED _BYTE)
        IF b + n < 256 THEN b = b + n ELSE b = 255
        _MEMPUT buffer, o + 1, b AS _UNSIGNED _BYTE
        b = _MEMGET(buffer, o + 2, _UNSIGNED _BYTE)
        IF b + n < 256 THEN b = b + n ELSE b = 255
        _MEMPUT buffer, o + 2, b AS _UNSIGNED _BYTE
        o = o + 4
    LOOP UNTIL o = o2
    _MEMFREE buffer
    $CHECKING:ON
END SUB

SUB centerImage (img&)
    _PUTIMAGE ((_WIDTH / 2) - (_WIDTH(img&) / 2), (_HEIGHT / 2) - (_HEIGHT(img&) / 2))-STEP(_WIDTH(img&), _HEIGHT(img&)), img&
END SUB

SUB showCredits ()
    DIM k&, f&, i AS INTEGER, f2&, yy AS INTEGER

    k& = _LOADIMAGE("Images/credits.png", 33)
    f& = _NEWIMAGE(_WIDTH(k&), _HEIGHT(k&), 32)
    _DEST f&
    FOR i = 0 TO 255
        LINE (0, (_HEIGHT - 255) + i)-(_WIDTH, (_HEIGHT - 255) + i), _RGBA(0, 0, 0, i)
        LINE (0, 255 - i)-(_WIDTH, 255 - i), _RGBA(0, 0, 0, i)
    NEXT
    _DEST 0
    f2& = _COPYIMAGE(f&, 33)
    SWAP f&, f2&
    _FREEIMAGE f2&
    yy = _HEIGHT + 50
    DO

        _PUTIMAGE (50, yy), k&
        _PUTIMAGE , f&
        yy = yy - 1

        _DISPLAY
        _LIMIT W.fps
    LOOP UNTIL yy < -_HEIGHT(k&)
    _FREEIMAGE f&
    _FREEIMAGE k&
END SUB

' SUB showCredits2 ()
' CLS
' _FONT Fonts.bigger
' _PRINTSTRING (CenterPrintX("Super Hunters 2017-18"), 250), "Super Hunters 2017-18"
' _FONT Fonts.normal
' _PRINTSTRING (CenterPrintX("By Ashish Kushwaha"), 290), "By Ashish Kushwaha"
' initTextParticles _RGB(255, 255, 255)
' CLS
' DO
' CLS
' moveTextParticles
' _LIMIT W.fps
' _DISPLAY
' LOOP UNTIL Text_Particles_Status = 1
' _DELAY 1
' fallTextParticles "fall"
' CLS
' _FONT Fonts.bigger
' _PRINTSTRING (CenterPrintX("Programmer"), 250), "Programmer"
' _FONT Fonts.normal
' _PRINTSTRING (CenterPrintX("Ashish Kushwaha"), 290), "Ashish Kushwaha"
' initTextParticles _RGB(255, 255, 255)
' ' _DISPLAY: SLEEP
' CLS
' DO
' CLS
' moveTextParticles
' _LIMIT W.fps
' _DISPLAY
' LOOP UNTIL Text_Particles_Status = 1
' _DELAY 1
' fallTextParticles "lessgravity"
' CLS
' _FONT Fonts.bigger
' _PRINTSTRING (CenterPrintX("Graphic Designer"), 250), "Graphic Designer"
' _FONT Fonts.normal
' _PRINTSTRING (CenterPrintX("Google Images & Ashish Kushwaha"), 290), "Google Images & Ashish Kushwaha"
' initTextParticles _RGB(255, 255, 255)
' CLS
' DO
' CLS
' moveTextParticles
' _LIMIT W.fps
' _DISPLAY
' LOOP UNTIL Text_Particles_Status = 1
' _DELAY 1
' fallTextParticles "explode"
' CLS
' _FONT Fonts.bigger
' _PRINTSTRING (CenterPrintX("Level Designer"), 250), "Level Designer"
' _FONT Fonts.normal
' _PRINTSTRING (CenterPrintX("Ashish Kushwaha"), 290), "Ashish Kushwaha"
' initTextParticles _RGB(255, 255, 255)
' CLS
' DO
' CLS
' moveTextParticles
' _LIMIT W.fps
' _DISPLAY
' LOOP UNTIL Text_Particles_Status = 1
' _DELAY 1
' fallTextParticles "horizontal"
' CLS
' _FONT Fonts.bigger
' _PRINTSTRING (CenterPrintX("Special Thanks -"), 230), "Special Thanks -"
' _FONT Fonts.normal
' _PRINTSTRING (CenterPrintX("Terry Ritchie for sprite library"), 270), "Terry Ritchie for sprite library"
' _PRINTSTRING (CenterPrintX("Unseenmachine & Waltersmind for BlurImage"), 320), "Unseenmachine & Waltersmind for BlurImage"
' _PRINTSTRING (CenterPrintX("and player of this game!"), 345), "and player of this game!"
' initTextParticles _RGB(255, 255, 255)
' CLS
' DO
' CLS
' moveTextParticles
' _LIMIT W.fps
' _DISPLAY
' LOOP UNTIL Text_Particles_Status = 1
' _DELAY 1
' fallTextParticles "boom"

' END SUB

' SUB initTextParticles (which~&)
' SHARED Text_Particles() AS Vector_Particles_Text_Type
' FOR y = 0 TO _HEIGHT - 1
' FOR x = 0 TO _WIDTH - 1
' col~& = POINT(x, y)
' IF col~& = which~& THEN n = n + 1
' NEXT x, y

' REDIM Text_Particles(n) AS Vector_Particles_Text_Type
' n = 0
' Text_Particles_Color = which~&
' FOR x = 0 TO _WIDTH - 1
' FOR y = 0 TO _HEIGHT - 1
' col~& = POINT(x, y)
' IF col~& = which~& THEN
' Text_Particles(n).x = x
' Text_Particles(n).y = y
' Text_Particles(n).vx = p5random(0, _WIDTH)
' Text_Particles(n).vy = p5random(0, _HEIGHT)
' Text_Particles(n).dist = dist(Text_Particles(n).vx, Text_Particles(n).vy, Text_Particles(n).x, Text_Particles(n).y)
' Text_Particles(n).distX = ABS(Text_Particles(n).x - Text_Particles(n).vx)
' Text_Particles(n).distY = ABS(Text_Particles(n).y - Text_Particles(n).vy)
' n = n + 1
' END IF
' NEXT y, x
' END SUB

' SUB moveTextParticles ()
' SHARED Text_Particles() AS Vector_Particles_Text_Type
' FOR i = 0 TO UBOUND(Text_Particles)
' IF Text_Particles(i).k < Text_Particles(i).dist THEN
' PSET (Text_Particles(i).vx + Text_Particles(i).delX, Text_Particles(i).vy + Text_Particles(i).delY), Text_Particles_Color
' IF Text_Particles(i).vx > Text_Particles(i).x THEN Text_Particles(i).delX = Text_Particles(i).delX - Text_Particles(i).distX / Text_Particles(i).dist ELSE Text_Particles(i).delX = Text_Particles(i).delX + Text_Particles(i).distX / Text_Particles(i).dist
' IF Text_Particles(i).vy > Text_Particles(i).y THEN Text_Particles(i).delY = Text_Particles(i).delY - Text_Particles(i).distY / Text_Particles(i).dist ELSE Text_Particles(i).delY = Text_Particles(i).delY + Text_Particles(i).distY / Text_Particles(i).dist
' Text_Particles(i).k = Text_Particles(i).k + 1
' ELSE
' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color
' check = check + 1
' END IF
' NEXT
' IF check >= UBOUND(text_particles) THEN Text_Particles_Status = 1: EXIT SUB ELSE Text_Particles_Status = 0

' END SUB

' SUB fallTextParticles (typ$)
' SHARED Text_Particles() AS Vector_Particles_Text_Type
' typ$ = LCASE$(typ$)
' SELECT CASE typ$
' CASE "explode"
' FOR i = 0 TO UBOUND(Text_Particles)
' Text_Particles(i).vx = 0
' Text_Particles(i).vy = 0
' Text_Particles(i).delX = p5random(-0.1, 0.1)
' Text_Particles(i).delY = p5random(-0.1, 0.1)
' NEXT
' DO
' CLS
' z = 0
' FOR i = 0 TO UBOUND(Text_Particles)

' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color
' IF i < array_len THEN
' Text_Particles(i).x = Text_Particles(i).x + Text_Particles(i).vx
' Text_Particles(i).y = Text_Particles(i).y + Text_Particles(i).vy
' Text_Particles(i).vx = Text_Particles(i).vx + Text_Particles(i).delX
' Text_Particles(i).vy = Text_Particles(i).vy + Text_Particles(i).delY
' END IF
' IF Text_Particles(i).x > _WIDTH OR Text_Particles(i).x < 0 OR Text_Particles(i).y > _HEIGHT OR Text_Particles(i).y < 0 THEN z = z + 1
' NEXT
' IF array_len < UBOUND(Text_Particles) THEN array_len = array_len + steps
' _DISPLAY
' _LIMIT W.fps
' steps = steps + 1
' IF z > UBOUND(Text_Particles) THEN EXIT DO
' LOOP UNTIL INKEY$ <> ""
' EXIT SUB
' CASE "fall"
' FOR i = 0 TO UBOUND(text_particles)
' Text_Particles(i).vx = 0
' Text_Particles(i).vy = 0
' Text_Particles(i).delX = p5random(-.02, .02)
' Text_Particles(i).delY = p5random(0.1, 0.2)
' NEXT
' DO
' CLS
' z = 0
' FOR i = 0 TO UBOUND(text_particles)
' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color
' IF i < array_len THEN
' Text_Particles(i).x = Text_Particles(i).x + Text_Particles(i).vx
' Text_Particles(i).y = Text_Particles(i).y + Text_Particles(i).vy
' Text_Particles(i).vx = Text_Particles(i).vx + Text_Particles(i).delX
' Text_Particles(i).vy = Text_Particles(i).vy + Text_Particles(i).delY
' END IF
' IF Text_Particles(i).x > _WIDTH OR Text_Particles(i).x < 0 OR Text_Particles(i).y > _HEIGHT OR Text_Particles(i).y < 0 THEN z = z + 1
' NEXT
' IF array_len < UBOUND(text_particles) THEN array_len = array_len + steps
' _DISPLAY
' _LIMIT W.fps
' steps = steps + 1
' IF z = UBOUND(text_particles) THEN EXIT DO
' LOOP
' EXIT SUB

' CASE "lessgravity"
' FOR i = 0 TO UBOUND(Text_Particles)
' Text_Particles(i).vx = 0
' Text_Particles(i).vy = 0
' Text_Particles(i).delX = p5random(-.02, .02)
' Text_Particles(i).delY = p5random(-0.1, -0.2)
' NEXT
' DO
' CLS
' z = 0
' FOR i = 0 TO UBOUND(Text_Particles)
' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color
' IF i < array_len THEN
' Text_Particles(i).x = Text_Particles(i).x + Text_Particles(i).vx
' Text_Particles(i).y = Text_Particles(i).y + Text_Particles(i).vy
' Text_Particles(i).vx = Text_Particles(i).vx + Text_Particles(i).delX
' Text_Particles(i).vy = Text_Particles(i).vy + Text_Particles(i).delY
' END IF
' IF Text_Particles(i).x > _WIDTH OR Text_Particles(i).x < 0 OR Text_Particles(i).y > _HEIGHT OR Text_Particles(i).y < 0 THEN z = z + 1
' NEXT
' IF array_len < UBOUND(Text_Particles) THEN array_len = array_len + steps
' _DISPLAY
' _LIMIT W.fps
' steps = steps + 1
' LOOP UNTIL INKEY$ <> "" OR z >= UBOUND(text_particles)
' EXIT SUB
' CASE "horizontal"
' FOR i = 0 TO UBOUND(Text_Particles)
' Text_Particles(i).vx = 0
' Text_Particles(i).vy = 0
' Text_Particles(i).delX = p5random(-.2, .2)
' Text_Particles(i).delY = 0
' NEXT
' DO
' CLS
' z = 0
' FOR i = 0 TO UBOUND(Text_Particles)
' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color
' Text_Particles(i).x = Text_Particles(i).x + Text_Particles(i).vx
' Text_Particles(i).y = Text_Particles(i).y + Text_Particles(i).vy
' Text_Particles(i).vx = Text_Particles(i).vx + Text_Particles(i).delX
' Text_Particles(i).vy = Text_Particles(i).vy + Text_Particles(i).delY
' IF Text_Particles(i).x > _WIDTH OR Text_Particles(i).x < 0 OR Text_Particles(i).y > _HEIGHT OR Text_Particles(i).y < 0 THEN z = z + 1
' NEXT
' _DISPLAY
' _LIMIT W.fps
' LOOP UNTIL INKEY$ <> "" OR z >= UBOUND(text_particles)
' EXIT SUB
' CASE "vertical"
' FOR i = 0 TO UBOUND(Text_Particles)
' Text_Particles(i).vx = 0
' Text_Particles(i).vy = 0
' Text_Particles(i).delX = 0
' Text_Particles(i).delY = p5random(-0.2, 0.2)
' NEXT
' DO
' CLS
' z = 0
' FOR i = 0 TO UBOUND(Text_Particles)
' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color

' Text_Particles(i).x = Text_Particles(i).x + Text_Particles(i).vx
' Text_Particles(i).y = Text_Particles(i).y + Text_Particles(i).vy
' Text_Particles(i).vx = Text_Particles(i).vx + Text_Particles(i).delX
' Text_Particles(i).vy = Text_Particles(i).vy + Text_Particles(i).delY

' IF Text_Particles(i).x > _WIDTH OR Text_Particles(i).x < 0 OR Text_Particles(i).y > _HEIGHT OR Text_Particles(i).y < 0 THEN z = z + 1
' NEXT
' _DISPLAY
' _LIMIT W.fps
' LOOP UNTIL INKEY$ <> "" OR z >= UBOUND(text_particles)
' EXIT SUB

' CASE "boom"
' FOR i = 0 TO UBOUND(Text_Particles)
' Text_Particles(i).vx = 0
' Text_Particles(i).vy = 0
' Text_Particles(i).delX = p5random(-.1, .1)
' Text_Particles(i).delY = p5random(-0.1, 0.1)
' NEXT
' DO
' CLS
' steps = 0
' FOR i = 0 TO UBOUND(Text_Particles)
' PSET (Text_Particles(i).x, Text_Particles(i).y), Text_Particles_Color
' Text_Particles(i).x = Text_Particles(i).x + Text_Particles(i).vx
' Text_Particles(i).y = Text_Particles(i).y + Text_Particles(i).vy
' Text_Particles(i).vx = Text_Particles(i).vx + Text_Particles(i).delX
' Text_Particles(i).vy = Text_Particles(i).vy + Text_Particles(i).delY
' IF Text_Particles(i).x > _WIDTH OR Text_Particles(i).x < 0 OR Text_Particles(i).y > _HEIGHT OR Text_Particles(i).y < 0 THEN steps = steps + 1
' NEXT
' _DISPLAY
' _LIMIT W.fps
' IF steps > UBOUND(Text_Particles) THEN EXIT DO
' LOOP UNTIL INKEY$ <> "" OR steps > UBOUND(text_particles)
' EXIT SUB
' END SELECT
' END SUB

SUB centerPrint (a$, b)
    DIM i AS INTEGER, v AS INTEGER
    FOR i = 1 TO LEN(a$)
        v = v + _PRINTWIDTH(MID$(a$, i, 1))
    NEXT
    _PRINTSTRING (_WIDTH / 2 - v / 2, b), a$
END SUB

FUNCTION txtWidth (a$)
    DIM i AS INTEGER, v AS INTEGER, g AS INTEGER
    FOR i = 1 TO LEN(a$)
        g = _PRINTWIDTH(MID$(a$, i, 1))
        v = v + g
    NEXT
    txtWidth = v
END FUNCTION
'these p5random(), p5map! (original map!) and dist() functions are taken from p5js.bas
FUNCTION p5random! (mn!, mx!)
    DIM tmp!

    IF mn! > mx! THEN
        tmp! = mn!
        mn! = mx!
        mx! = tmp!
    END IF
    p5random! = RND * (mx! - mn!) + mn!
END FUNCTION

FUNCTION dist! (x1!, y1!, x2!, y2!)
    dist! = SQR((x2! - x1!) ^ 2 + (y2! - y1!) ^ 2)
END FUNCTION

FUNCTION p5map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    p5map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION


'By UnseenMachine & Waltersmind
'http://www.qb64.net/forum/index.php?topic=12658
SUB BLURIMAGE (Image AS LONG, Blurs AS _UNSIGNED INTEGER)

    DIM ImageMemory AS _MEM
    DIM ImageOffsetCurrent AS _OFFSET
    DIM ImageOffsetStart AS _OFFSET
    DIM ImageOffsetEnd AS _OFFSET

    DIM TopOffset AS _OFFSET
    DIM LeftOffset AS _OFFSET
    DIM RightOffset AS _OFFSET
    DIM BottomOffset AS _OFFSET

    DIM Red1 AS _UNSIGNED _BYTE
    DIM Green1 AS _UNSIGNED _BYTE
    DIM Blue1 AS _UNSIGNED _BYTE
    DIM Alpha1 AS _UNSIGNED _BYTE

    DIM Red2 AS _UNSIGNED _BYTE
    DIM Green2 AS _UNSIGNED _BYTE
    DIM Blue2 AS _UNSIGNED _BYTE
    DIM Alpha2 AS _UNSIGNED _BYTE

    DIM Red3 AS _UNSIGNED _BYTE
    DIM Green3 AS _UNSIGNED _BYTE
    DIM Blue3 AS _UNSIGNED _BYTE
    DIM Alpha3 AS _UNSIGNED _BYTE

    DIM Red4 AS _UNSIGNED _BYTE
    DIM Green4 AS _UNSIGNED _BYTE
    DIM Blue4 AS _UNSIGNED _BYTE
    DIM Alpha4 AS _UNSIGNED _BYTE

    ImageMemory = _MEMIMAGE(Image)

    $CHECKING:OFF

    DIM iterations%

    FOR iterations% = 0 TO Blurs - 1

        ImageOffsetStart = ImageMemory.OFFSET
        ImageOffsetCurrent = ImageOffsetStart
        ImageOffsetEnd = ImageOffsetStart + _WIDTH(Image) * _HEIGHT(Image) * 4

        DO
            TopOffset = ImageOffsetCurrent - _WIDTH(Image) * 4
            LeftOffset = ImageOffsetCurrent - 4
            RightOffset = ImageOffsetCurrent + 4
            BottomOffset = ImageOffsetCurrent + _WIDTH(Image) * 4

            ' *** Let's go ahead and set the color values to zero, and only change them when required.
            Red1 = 0: Green1 = 0: Blue1 = 0: Alpha1 = 0
            Red2 = 0: Green2 = 0: Blue2 = 0: Alpha2 = 0
            Red3 = 0: Green3 = 0: Blue3 = 0: Alpha3 = 0
            Red4 = 0: Green4 = 0: Blue4 = 0: Alpha4 = 0

            ' *** Get the color values from the pixel above the current pixel, if it is with the image.
            IF TopOffset >= ImageOffsetStart THEN
                Red1 = _MEMGET(ImageMemory, TopOffset + 2, _UNSIGNED _BYTE)
                Green1 = _MEMGET(ImageMemory, TopOffset + 1, _UNSIGNED _BYTE)
                Blue1 = _MEMGET(ImageMemory, TopOffset, _UNSIGNED _BYTE)
                Alpha1 = _MEMGET(ImageMemory, TopOffset + 3, _UNSIGNED _BYTE)
            END IF

            ' *** Get the color values from the pixel to the left of the current pixel, if it is with the image.
            IF ((((LeftOffset - ImageOffsetStart) / 4) MOD _WIDTH(Image)) < (((ImageOffsetCurrent - ImageOffsetStart) / 4) MOD _WIDTH(Image))) THEN
                Red2 = _MEMGET(ImageMemory, LeftOffset + 2, _UNSIGNED _BYTE)
                Green2 = _MEMGET(ImageMemory, LeftOffset + 1, _UNSIGNED _BYTE)
                Blue2 = _MEMGET(ImageMemory, LeftOffset, _UNSIGNED _BYTE)
                Alpha2 = _MEMGET(ImageMemory, LeftOffset + 3, _UNSIGNED _BYTE)
            END IF

            ' *** Get the color values from the pixel to the right of the current pixel, if it is with the image.
            IF ((((RightOffset - ImageOffsetStart) / 4) MOD _WIDTH(Image)) > (((ImageOffsetCurrent - ImageOffsetStart) / 4) MOD _WIDTH(Image))) THEN
                Red3 = _MEMGET(ImageMemory, RightOffset + 2, _UNSIGNED _BYTE)
                Green3 = _MEMGET(ImageMemory, RightOffset + 1, _UNSIGNED _BYTE)
                Blue3 = _MEMGET(ImageMemory, RightOffset, _UNSIGNED _BYTE)
                Alpha3 = _MEMGET(ImageMemory, RightOffset + 3, _UNSIGNED _BYTE)
            END IF

            ' *** Get the color values from the pixel below the current pixel, if it is with the image.
            IF BottomOffset < ImageOffsetEnd THEN
                Red4 = _MEMGET(ImageMemory, BottomOffset + 2, _UNSIGNED _BYTE)
                Green4 = _MEMGET(ImageMemory, BottomOffset + 1, _UNSIGNED _BYTE)
                Blue4 = _MEMGET(ImageMemory, BottomOffset, _UNSIGNED _BYTE)
                Alpha4 = _MEMGET(ImageMemory, BottomOffset + 3, _UNSIGNED _BYTE)
            END IF

            ' *** draw the current pixel with a newly defined _RGBA color value.
            _MEMPUT ImageMemory, ImageOffsetCurrent, _RGBA((Red1 + Red2 + Red3 + Red4) / 4, (Green1 + Green2 + Green3 + Green4) / 4, (Blue1 + Blue2 + Blue3 + Blue4) / 4, (Alpha1 + Alpha2 + Alpha3 + Alpha4) / 4) AS _UNSIGNED LONG

            '' *** These are here for fun nd testing purposes.
            '_MEMPUT ImageMemory, ImageOffsetCurrent, _RGBA((Red1 + Red2 + Red3 + Red4) / 4, (Green1 + Green2 + Green3 + Green4) / 4, (Blue1 + Blue2 + Blue3 + Blue4) / 4, 255) AS _UNSIGNED LONG
            '_MEMPUT ImageMemory, ImageOffsetCurrent, _RGBA(0, 0, (Blue1 + Blue2 + Blue3 + Blue4) / 4, 255) AS _UNSIGNED LONG
            '_MEMPUT ImageMemory, ImageOffsetCurrent, _RGBA(0, (Green1 + Green2 + Green3 + Green4) / 4, 0, 255) AS _UNSIGNED LONG
            '_MEMPUT ImageMemory, ImageOffsetCurrent, _RGBA((Red1 + Red2 + Red3 + Red4) / 4, 0, 0, 255) AS _UNSIGNED LONG

            ImageOffsetCurrent = ImageOffsetCurrent + 4

        LOOP UNTIL ImageOffsetCurrent = ImageOffsetEnd

    NEXT

    $CHECKING:ON
    _MEMFREE ImageMemory

END SUB
'$INCLUDE:'Vendor\sprite.bi'

'End of Code ! :)
