'Spaceship, by @FellippeHeitor (2016)
'Expanded campaign edition (2026)
'--------------------------------------------------------------------------
'Source layout:
'  Spaceship.bas      this file: startup, main loop, logo
'  src/*.bi, src/*.bm engine modules (see ROADMAP.md)
'  data/              sprites, enemy definitions, campaign and level scripts
'  Audio/             music and sound effects
'This file is pure ASCII on purpose: CP437 characters are always written with CHR$().
'--------------------------------------------------------------------------
$RESIZE:SMOOTH
$EXEICON:'./ship.ico'
OPTION _EXPLICIT

DECLARE LIBRARY
    FUNCTION GetUptime~&& ALIAS GetTicks
END DECLARE

'$INCLUDE: 'src/types.bi'

DIM fh AS LONG, i AS INTEGER, exeDir AS STRING, p AS INTEGER

_TITLE "Spaceship"
_CONTROLCHR OFF
ON ERROR GOTO ErrHandler

$IF WIN THEN
    Sep = "\"
$ELSE
    Sep = "/"
$END IF

'Find the game folder: the current folder, or the folder of the executable
BasePath = ""
IF _FILEEXISTS("data" + Sep + "campaign.txt") = 0 THEN
    exeDir = COMMAND$(0)
    p = _INSTRREV(exeDir, Sep)
    IF p > 0 THEN BasePath = LEFT$(exeDir, p)
END IF

LoadConfig
ParseArgs
IF Test.Active THEN
    _SCREENHIDE
    IF LEN(RTRIM$(Test.LogFile)) = 0 THEN Test.LogFile = BasePath + "autotest.log"
    fh = FREEFILE
    OPEN RTRIM$(Test.LogFile) FOR OUTPUT AS #fh
    CLOSE #fh
    LogMsg "=== AUTOTEST" + COMMAND$
ELSE
    _SCREENMOVE _MIDDLE
END IF

_PALETTECOLOR 0, _RGBA32(0, 0, 0, 0)
_PALETTECOLOR 1, _RGB32(55, 55, 55)
_DISPLAYORDER _HARDWARE , _SOFTWARE
RANDOMIZE TIMER

BoomChars = CHR$(219) + CHR$(178) + CHR$(177) + CHR$(176) + CHR$(15) + CHR$(7) + CHR$(249) + CHR$(250)
SpecialName(SP_FREEZE) = "FREEZE": SpecialMax(SP_FREEZE) = 3
SpecialName(SP_BOMB) = "BOMB": SpecialMax(SP_BOMB) = 3
SpecialName(SP_MISSILE) = "MISSILES": SpecialMax(SP_MISSILE) = 3
SpecialName(SP_OVERDRIVE) = "OVERDRIVE": SpecialMax(SP_OVERDRIVE) = 2

'Logo in 16 fade steps (pre-rendered once)
FOR i = 1 TO 16
    RESTORE SpaceshipLogo
    LogoImages(i) = RestoreImage&(_RGBA32(233, 200, 94, i * 16 - 1))
NEXT

CLS
DrawLogo 100, 16
COLOR 15
CenterText 12, "LOADING"
_DISPLAY

InitInput
LoadSprites DataPath$("sprites.txt")
LoadDefs DataPath$("enemies.txt")
LoadCampaign DataPath$("campaign.txt")
LoadZenScenes DataPath$("zen.txt")
LoadScores
CreateImages
LoadAudio
ApplyFullscreen
IF Test.Active THEN LogMsg "Loaded" + STR$(SpriteCount) + " sprites," + STR$(DefCount) + " enemy types," + STR$(ChapterCount) + " chapters"

IF (Test.Active AND LEN(TestMenuScript) = 0) OR Game.StartChapter > 0 THEN
    IF Game.StartChapter < 1 OR Game.StartChapter > ChapterCount THEN Game.StartChapter = 1
    NewGame Game.StartChapter
ELSE
    GoTitle
END IF

DO
    RunFrame
    IF Game.State = ST_QUIT THEN EXIT DO
    IF NOT Test.Fast THEN
        _DISPLAY
        _LIMIT 60
    END IF
LOOP
SaveConfig
SYSTEM

ErrHandler:
Test.Errors = Test.Errors + 1
IF Test.Errors < 200 THEN LogMsg "RUNTIME ERROR" + STR$(ERR) + " at line" + STR$(_ERRORLINE) + " (" + _INCLERRORFILE$ + ":" + STR$(_INCLERRORLINE) + ")"
RESUME NEXT

'Images: ---------------------------------------------------------------------------
SpaceshipLogo:
DATA 313,56,15B,34W,188B,5W,32B,6W,33B,*
DATA 13B,37W,185B,8W,30B,8W,32B,*
DATA 11B,39W,185B,8W,30B,8W,32B,*
DATA 11B,40W,183B,9W,29B,9W,32B,*
DATA 10B,41W,183B,9W,29B,9W,32B,*
DATA 9B,42W,183B,9W,29B,9W,32B,*
DATA 9B,42W,182B,9W,30B,8W,33B,*
DATA 8B,43W,182B,9W,30B,8W,33B,*
DATA 8B,42W,183B,9W,30B,7W,34B,*
DATA 8B,42W,183B,9W,31B,4W,36B,*
DATA 7B,10W,24B,9W,182B,9W,72B,*
DATA 7B,9W,25B,9W,3B,26W,11B,23W,14B,26W,13B,20W,14B,28W,4B,26W,15B,3W,6B,26W,5B,*
DATA 7B,9W,25B,8W,4B,28W,8B,26W,9B,31W,8B,25W,9B,32W,3B,28W,11B,7W,4B,28W,3B,*
DATA 7B,8W,26B,8W,3B,30W,6B,28W,7B,33W,6B,27W,7B,33W,3B,29W,9B,8W,3B,30W,2B,*
DATA 6B,9W,26B,7W,4B,31W,4B,29W,6B,34W,5B,28W,6B,34W,2B,31W,7B,9W,3B,31W,1B,*
DATA 6B,9W,28B,2W,7B,31W,4B,30W,5B,35W,4B,28W,5B,35W,2B,31W,7B,9W,3B,31W,1B,*
DATA 6B,9W,37B,32W,3B,30W,4B,36W,3B,30W,3B,36W,2B,32W,6B,9W,3B,32W,*
DATA 5B,37W,9B,33W,3B,30W,4B,36W,3B,30W,3B,36W,1B,33W,5B,9W,3B,33W,*
DATA 5B,39W,7B,33W,3B,29W,4B,36W,3B,30W,3B,36W,2B,33W,5B,9W,3B,33W,*
DATA 5B,40W,6B,33W,3B,29W,4B,36W,3B,30W,3B,36W,2B,33W,5B,9W,3B,33W,*
DATA 5B,40W,6B,33W,3B,29W,4B,36W,3B,30W,3B,34W,4B,33W,5B,9W,3B,33W,*
DATA 5B,41W,4B,9W,15B,10W,22B,10W,3B,10W,18B,9W,2B,10W,12B,9W,2B,9W,29B,9W,15B,10W,4B,9W,3B,9W,15B,10W,*
DATA 5B,41W,4B,9W,15B,9W,23B,9W,4B,9W,19B,9W,2B,9W,12B,9W,3B,9W,29B,9W,15B,9W,5B,9W,3B,9W,15B,9W,1B,*
DATA 6B,40W,4B,9W,15B,9W,5B,27W,4B,9W,19B,8W,3B,30W,3B,32W,6B,9W,15B,9W,5B,9W,3B,9W,15B,9W,1B,*
DATA 6B,40W,4B,9W,15B,9W,4B,28W,4B,9W,19B,7W,4B,30W,3B,33W,5B,9W,15B,9W,5B,9W,3B,9W,15B,9W,1B,*
DATA 7B,39W,3B,9W,16B,9W,3B,29W,3B,9W,21B,5W,4B,31W,3B,34W,3B,9W,16B,9W,4B,9W,3B,9W,16B,9W,1B,*
DATA 9B,37W,3B,9W,15B,9W,3B,29W,4B,9W,30B,30W,4B,34W,3B,9W,15B,9W,5B,9W,3B,9W,15B,9W,2B,*
DATA 36B,9W,4B,9W,15B,9W,2B,30W,4B,9W,30B,30W,4B,34W,3B,9W,15B,9W,5B,9W,3B,9W,15B,9W,2B,*
DATA 6B,2W,28B,9W,3B,9W,16B,9W,2B,30W,3B,9W,30B,30W,5B,34W,2B,9W,16B,9W,4B,9W,3B,9W,16B,9W,2B,*
DATA 3B,7W,26B,9W,3B,9W,16B,9W,1B,31W,3B,9W,22B,2W,6B,30W,5B,34W,2B,9W,16B,9W,4B,9W,3B,9W,16B,9W,2B,*
DATA 2B,8W,26B,9W,3B,9W,15B,9W,2B,30W,4B,9W,19B,7W,4B,29W,7B,33W,2B,9W,15B,9W,5B,9W,3B,9W,15B,9W,3B,*
DATA 2B,8W,25B,9W,4B,9W,15B,9W,2B,30W,4B,9W,19B,7W,4B,27W,10B,32W,2B,9W,15B,9W,5B,9W,3B,9W,15B,9W,3B,*
DATA 1B,9W,25B,9W,3B,9W,16B,9W,1B,31W,3B,9W,19B,9W,2B,26W,15B,29W,1B,9W,16B,9W,4B,9W,3B,9W,16B,9W,3B,*
DATA 1B,9W,24B,10W,3B,9W,15B,9W,2B,9W,13B,8W,4B,9W,19B,8W,3B,9W,52B,9W,1B,9W,16B,9W,4B,9W,3B,9W,15B,9W,4B,*
DATA 1B,42W,4B,33W,2B,30W,4B,36W,3B,28W,7B,34W,2B,9W,15B,9W,5B,9W,3B,33W,4B,*
DATA 1B,42W,4B,33W,2B,30W,4B,36W,3B,29W,4B,36W,2B,9W,15B,9W,5B,9W,3B,33W,4B,*
DATA 43W,3B,33W,2B,31W,3B,37W,2B,30W,4B,36W,1B,9W,16B,9W,4B,9W,3B,33W,5B,*
DATA 42W,4B,33W,2B,30W,4B,36W,3B,30W,3B,36W,2B,9W,16B,8W,5B,9W,3B,33W,5B,*
DATA 42W,4B,32W,3B,30W,4B,36W,3B,30W,3B,36W,2B,9W,15B,9W,5B,9W,3B,32W,6B,*
DATA 41W,5B,31W,4B,30W,4B,36W,3B,30W,3B,35W,3B,9W,15B,9W,5B,9W,3B,31W,7B,*
DATA 40W,5B,32W,4B,30W,4B,35W,4B,30W,2B,35W,3B,9W,16B,9W,4B,9W,3B,32W,7B,*
DATA 1B,38W,6B,31W,6B,28W,6B,33W,6B,28W,3B,34W,4B,9W,16B,8W,5B,9W,3B,31W,8B,*
DATA 1B,37W,7B,29W,8B,28W,6B,32W,7B,27W,5B,32W,6B,7W,17B,8W,6B,7W,4B,29W,10B,*
DATA 2B,34W,8B,28W,11B,27W,7B,29W,10B,25W,6B,30W,8B,6W,19B,5W,8B,6W,4B,28W,12B,*
DATA 44B,9W,220B,9W,31B,*
DATA 44B,9W,220B,9W,31B,*
DATA 44B,9W,220B,9W,31B,*
DATA 43B,9W,220B,9W,32B,*
DATA 43B,9W,220B,9W,32B,*
DATA 43B,9W,220B,9W,32B,*
DATA 43B,9W,220B,9W,32B,*
DATA 42B,9W,220B,9W,33B,*
DATA 42B,9W,220B,9W,33B,*
DATA 42B,8W,221B,8W,34B,*
DATA 43B,6W,223B,6W,35B,*
DATA 44B,3W,226B,3W,37B,*

'$INCLUDE: 'src/util.bm'
'$INCLUDE: 'src/sprites.bm'
'$INCLUDE: 'src/input.bm'
'$INCLUDE: 'src/audio.bm'
'$INCLUDE: 'src/render.bm'
'$INCLUDE: 'src/world.bm'
'$INCLUDE: 'src/fx.bm'
'$INCLUDE: 'src/pickups.bm'
'$INCLUDE: 'src/player.bm'
'$INCLUDE: 'src/bullets.bm'
'$INCLUDE: 'src/enemies.bm'
'$INCLUDE: 'src/bosses.bm'
'$INCLUDE: 'src/levels.bm'
'$INCLUDE: 'src/config.bm'
'$INCLUDE: 'src/states.bm'
'$INCLUDE: 'src/demo.bm'
'$INCLUDE: 'src/zen.bm'
'$INCLUDE: 'src/test.bm'
