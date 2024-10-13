'======================================================================================================================================================================================================
' Drop Slicer
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Programmed by RokCoder
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Just a game...
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' V0.1 - 03/10/2024 - First release
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' https://github.com/rokcoder-qb64/drop-slicer
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' https://www.rokcoder.com
' https://www.github.com/rokcoder
' https://www.facebook.com/rokcoder
' https://www.youtube.com/rokcoder
'======================================================================================================================================================================================================
' TODO
'======================================================================================================================================================================================================

$VERSIONINFO:CompanyName='RokSoft'
$VERSIONINFO:FileDescription='QB64 Drop Slicer'
$VERSIONINFO:InternalName='drop-slicer.exe'
$VERSIONINFO:ProductName='Drop Slicer'
$VERSIONINFO:OriginalFilename='drop-slicer.exe'
$VERSIONINFO:LegalCopyright='(c)2024 RokSoft'
$VERSIONINFO:FILEVERSION#=0,1,0,0
$VERSIONINFO:PRODUCTVERSION#=0,1,0,0

'======================================================================================================================================================================================================

OPTION _EXPLICIT
OPTION _EXPLICITARRAY

'======================================================================================================================================================================================================

CONST FALSE = 0
CONST TRUE = NOT FALSE

CONST USE_RECTANGLES = FALSE ' Unfortunately Physac doesn't handle rectangles very well so I'm defaulting to using squares

CONST SCREEN_WIDTH = 480 ' Resolution of the unscaled game area
CONST SCREEN_HEIGHT = 360

CONST VERSION = 1

CONST STATE_NEW_GAME = 0 ' Different game states used in the game
CONST STATE_GAME_OVER = 1
CONST STATE_WAIT_TO_START = 2
CONST STATE_WAIT_TO_DROP_BLOCK = 3
CONST STATE_PLAY_TURN = 4
CONST STATE_DROP_BLOCK = 5
CONST STATE_WAIT_TO_LAND = 6

CONST START_BUTTON_WIDTH = 231
CONST START_BUTTON_HEIGHT = 87
CONST START_BUTTON_Y = 200

CONST BLOCK_START_WIDTH = 240
CONST BLOCK_HEIGHT = 20
CONST MAX_BLOCKS = 50
CONST BLOCK_START_HEIGHT = SCREEN_HEIGHT - 50

CONST FLOOR_HEIGHT = SCREEN_HEIGHT / 2 - 50

CONST SLICE_FADE_FRAMES = 40

CONST SFX_FALL = 0
CONST SFX_LOSE = 1
CONST SFX_LAND = 2
CONST SFX_START = 4

'======================================================================================================================================================================================================

TYPE SCROLL
    active AS INTEGER
    count AS INTEGER
END TYPE

TYPE GAME
    fps AS INTEGER
    score AS LONG
    hiscore AS LONG
    currentWidth AS INTEGER
    blockCount AS INTEGER
    gameOver AS INTEGER
    scroll AS SCROLL
END TYPE

TYPE VECTOR2
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE STATE
    state AS INTEGER
    substate AS INTEGER
    counter AS INTEGER
END TYPE

TYPE GLDATA
    initialised AS INTEGER
    executing AS INTEGER
    background AS LONG
    normal AS LONG
    bubbleText AS LONG
END TYPE

TYPE SFX
    handle AS LONG
    oneShot AS INTEGER
    looping AS INTEGER
END TYPE

TYPE BLOCK
    positional AS INTEGER
    position AS VECTOR2
    width AS INTEGER
    yVelocity AS SINGLE
END TYPE

TYPE slice
    block AS BLOCK
    frame AS INTEGER
    active AS INTEGER
END TYPE

'======================================================================================================================================================================================================

' Not a fan of globals but this is QB64 so what can you do?

DIM SHARED state AS STATE
DIM SHARED glData AS GLDATA
DIM SHARED virtualScreen& ' Handle to virtual screen which is drawn to and then blitted/stretched to the main display
DIM SHARED game AS GAME ' General game data
DIM SHARED sfx(4) AS SFX
DIM SHARED quit AS INTEGER
DIM SHARED exitProgram AS INTEGER
DIM SHARED block(MAX_BLOCKS) AS BLOCK
DIM SHARED gravity!
DIM SHARED slice AS slice

'===== Game loop ======================================================================================================================================================================================

PrepareGame
DO: _LIMIT (game.fps%)
    UpdateFrame
    _PUTIMAGE , virtualScreen&, 0, (0, 0)-(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) ' Copy from virtual screen to target screen which allows for automatic upscaling
    _DISPLAY
    IF exitProgram THEN _FREEIMAGE virtualScreen&: SYSTEM
LOOP

'===== Error handling =================================================================================================================================================================================

fileReadError:
InitialiseHiscore
RESUME NEXT

fileWriteError:
ON ERROR GOTO 0
RESUME NEXT

'===== One time initialisations =======================================================================================================================================================================

SUB PrepareGame
    DIM m%
    quit = _EXIT
    exitProgram = FALSE
    _DISPLAYORDER _SOFTWARE
    m% = INT((_DESKTOPHEIGHT - 80) / SCREEN_HEIGHT) ' Ratio for how much we can scale the game up (integer values) whilst still fitting vertically on the screen
    virtualScreen& = _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, 32) ' This is the same resolution as the original arcade game
    SCREEN _NEWIMAGE(SCREEN_WIDTH * m%, SCREEN_HEIGHT * m%, 32) ' The screen we ultimately display is the defined size multiplied by a ratio as determined above
    DO: _DELAY 0.5: LOOP UNTIL _SCREENEXISTS
    _SCREENMOVE _MIDDLE
    $RESIZE:STRETCH
    _ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH
    _TITLE "Drop Slicer"
    $EXEICON:'./assets/icon.ico'
    _DEST virtualScreen&
    game.fps% = 60
    RANDOMIZE TIMER
    glData.executing = TRUE
    _DISPLAYORDER _HARDWARE , _GLRENDER , _SOFTWARE
    LoadAllSFX
    ReadHiscore ' Read high scores from file (or create them if the file doesn't exist or can't be read)
    SetGameState STATE_WAIT_TO_START ' Set the game state in its initial state
    gravity! = -9.82 / game.fps%
END SUB

'===== High score code ================================================================================================================================================================================

' ReadHiscores
' - Read high scores from local storage (with fallback to initialising data if there's an error while reading the file for any reason)
SUB ReadHiscore
    DIM handle&, s&, v%
    ON ERROR GOTO fileReadError
    IF NOT _FILEEXISTS("scores.txt") THEN InitialiseHiscore: EXIT SUB
    handle& = FREEFILE
    OPEN "scores.txt" FOR INPUT AS #handle&
    INPUT #handle&, s&
    IF EOF(handle&) THEN
        ' This was a high score file containing only hard level high score (before a version number was introduced)
        game.hiscore& = 0
    ELSE
        v% = s&
        INPUT #handle&, game.hiscore&
    END IF
    CLOSE #handle&
    ON ERROR GOTO 0
END SUB

' InitialiseHiscores
' - Set up default high score values
SUB InitialiseHiscore
    game.hiscore& = 0
END SUB

' WriteHiscores
' - Store high scores to local storage (trapping any errors that might occur - write-protected, out of space, etc)
SUB WriteHiscore
    DIM handle&
    ON ERROR GOTO fileWriteError
    handle& = FREEFILE
    OPEN "scores.txt" FOR OUTPUT AS #handle&
    PRINT #handle&, VERSION
    PRINT #handle&, game.hiscore&
    CLOSE #handle&
    ON ERROR GOTO 0
END SUB

'===== Simple asset loading functions =================================================================================================================================================================

SUB AssetError (fname$)
    SCREEN 0
    PRINT "Unable to load "; fname$
    PRINT "Please make sure EXE is in same folder as drop-slicer.bas"
    PRINT "(Set Run/Output EXE to Source Folder option in the IDE before compiling)"
    END
END SUB

FUNCTION LoadImage& (fname$)
    DIM asset&, f$
    f$ = "./assets/" + fname$ + ".png"
    asset& = _LOADIMAGE(f$, 32)
    IF asset& = -1 THEN AssetError (f$)
    LoadImage& = asset&
END FUNCTION

FUNCTION SndOpen& (fname$)
    DIM asset&, f$
    f$ = "./assets/" + fname$
    asset& = _SNDOPEN(f$)
    IF asset& = -1 THEN AssetError (f$)
    SndOpen& = asset&
END FUNCTION

'===== Sound manager ==================================================================================================================================================================================

SUB LoadSfx (sfx%, sfx$, oneShot%)
    sfx(sfx%).handle& = _SNDOPEN("assets/" + sfx$ + ".ogg")
    IF sfx(sfx%).handle& = 0 THEN AssetError sfx$
    sfx(sfx%).oneShot% = oneShot%
END SUB

SUB LoadAllSFX
    LoadSfx SFX_FALL, "fall", TRUE
    LoadSfx SFX_LAND, "land", TRUE
    LoadSfx SFX_LOSE, "lose", TRUE
    LoadSfx SFX_START, "start", TRUE
END SUB

SUB PlaySfx (sfx%)
    IF sfx(sfx%).oneShot% THEN
        _SNDPLAY sfx(sfx%).handle&
    ELSE
        _SNDPLAYCOPY sfx(sfx%).handle&
    END IF
END SUB

SUB PlaySfxLooping (sfx%)
    IF sfx(sfx%).oneShot% THEN
        _SNDLOOP sfx(sfx%).handle&
    END IF
END SUB

SUB StopSfx (sfx%)
    IF sfx(sfx%).oneShot% THEN _SNDSTOP sfx(sfx%).handle&
END SUB

FUNCTION IsPlayingSfx% (sfx%)
    IsPlayingSfx% = _SNDPLAYING(sfx(sfx%).handle&)
END FUNCTION

SUB SetGameState (s%)
    state.state% = s%
    state.substate% = 0
    state.counter% = 0
    IF s% = STATE_NEW_GAME THEN InitialiseGame: SetGameState STATE_PLAY_TURN
    IF s% = STATE_PLAY_TURN THEN ChooseBlockToDrop: SetGameState STATE_WAIT_TO_DROP_BLOCK
    IF s% = STATE_GAME_OVER THEN WriteHiscore: SetGameState STATE_WAIT_TO_START
END SUB

'======================================================================================================================================================================================================

SUB UpdateFrame
    DO WHILE _MOUSEINPUT: LOOP
    IF state.state% = STATE_WAIT_TO_START THEN WaitToStart
    IF state.state% = STATE_WAIT_TO_DROP_BLOCK THEN WaitToDropBlock
    IF state.state% = STATE_WAIT_TO_LAND THEN WaitToLand
    UpdateSlice
    UpdateScroll
    state.counter% = state.counter% + 1
END SUB

'======================================================================================================================================================================================================

SUB InitialiseGame
    DIM i%
    game.score& = 0
    game.currentWidth% = BLOCK_START_WIDTH
    i% = 0
    WHILE BLOCK_HEIGHT * i% < FLOOR_HEIGHT
        SetBlockWithWidth block(i%), SCREEN_WIDTH / 2, BLOCK_HEIGHT * (0.5 + i%), SCREEN_WIDTH, 0
        i% = i% + 1
    WEND
    game.blockCount% = i%
    game.gameOver% = FALSE
    slice.active% = FALSE
    game.scroll.active% = FALSE
END SUB

'======================================================================================================================================================================================================

FUNCTION mouseOverStartButton%
    DIM mousePos AS VECTOR2
    mousePos.x! = (_MOUSEX - _WIDTH(0) / 2) * SCREEN_WIDTH / _WIDTH(0)
    mousePos.y! = (_HEIGHT(0) - _MOUSEY) * SCREEN_HEIGHT / _HEIGHT(0)
    DIM w%, h%
    w% = START_BUTTON_WIDTH
    h% = START_BUTTON_HEIGHT
    mouseOverStartButton% = ABS(mousePos.x!) < w% / 2 AND ABS(mousePos.y! - START_BUTTON_Y) < h% / 2
END FUNCTION

SUB WaitToStart
    STATIC mouseUp%, selected%
    IF _MOUSEBUTTON(1) AND mouseUp% THEN
        selected% = mouseOverStartButton%
        IF selected% THEN
            PlaySfx SFX_START
            SetGameState STATE_NEW_GAME
            mouseUp% = FALSE
            selected% = FALSE
            EXIT SUB
        END IF
    END IF
    mouseUp% = NOT _MOUSEBUTTON(1)
    IF mouseUp% THEN selected% = FALSE
END SUB

'======================================================================================================================================================================================================

SUB SetBlockWithWidth (block AS BLOCK, x%, y%, w%, v!)
    block.position.x! = x%
    block.position.y! = y%
    block.width% = w%
    block.yVelocity! = v!
    block.positional% = FALSE
END SUB

SUB SetBlockWithLeftRight (block AS BLOCK, xLeft%, xRight%, y%, v!)
    DIM width%
    width% = xRight% - xLeft%
    SetBlockWithWidth block, xLeft% + width% / 2, y%, width%, v!
END SUB

SUB ChooseBlockToDrop
    SetBlockWithWidth block(game.blockCount%), BlockX%, BLOCK_START_HEIGHT, game.currentWidth%, 0
    block(game.blockCount%).positional% = TRUE
    game.blockCount% = game.blockCount% + 1
END SUB

SUB WaitToDropBlock
    STATIC mouseUp%
    block(game.blockCount% - 1).position.x! = BlockX%
    IF _MOUSEBUTTON(1) AND mouseUp% THEN
        block(game.blockCount% - 1).positional% = FALSE
        block(game.blockCount% - 1).yVelocity! = 0
        SetGameState STATE_WAIT_TO_LAND
        PlaySfx SFX_FALL
        mouseUp% = FALSE
        EXIT SUB
    END IF
    mouseUp% = NOT _MOUSEBUTTON(1)
END SUB

FUNCTION BlockX%
    BlockX% = SCREEN_WIDTH / 2 - (SCREEN_WIDTH - block(game.blockCount% - 1).width%) / 2 * SIN(TIMER / 1)
END FUNCTION

'======================================================================================================================================================================================================

SUB UpdateScroll
    DIM i%
    IF NOT game.scroll.active% THEN EXIT SUB
    game.scroll.count% = game.scroll.count% + 1
    IF game.scroll.count% = BLOCK_HEIGHT THEN
        game.scroll.active% = FALSE
    END IF
    i% = 0
    WHILE i% < game.blockCount%
        IF NOT block(i%).positional% THEN
            block(i%).position.y! = block(i%).position.y! - 1
        END IF
        i% = i% + 1
    WEND
    IF NOT block(0).position.y! < -BLOCK_HEIGHT THEN EXIT SUB
    i% = 1
    WHILE i% < game.blockCount%
        block(i% - 1) = block(i%)
        i% = i% + 1
    WEND
    game.blockCount% = game.blockCount% - 1
END SUB

SUB UpdateSlice
    IF slice.active% THEN
        slice.frame% = slice.frame% + 1
        IF slice.frame% > SLICE_FADE_FRAMES THEN
            slice.active% = FALSE
        ELSE
            slice.block.position.y! = slice.block.position.y! + slice.block.yVelocity!
            slice.block.yVelocity! = slice.block.yVelocity! + gravity!
        END IF
    END IF
END SUB

SUB SetSlices (block AS BLOCK, target AS BLOCK)
    DIM left%, right%
    left% = BlockLeft%(block)
    right% = BlockRight%(block)
    IF right% <= BlockLeft%(target) OR left% >= BlockRight%(target) THEN
        SetBlockWithLeftRight slice.block, left%, right%, block.position.y!, block.yVelocity!
        slice.active% = TRUE
        slice.frame% = 1
        game.blockCount% = game.blockCount% - 1
        game.gameOver% = TRUE
        EXIT SUB
    ELSEIF left% < BlockLeft%(target) THEN
        SetBlockWithLeftRight slice.block, left%, BlockLeft%(target) - 1, target.position.y! + BLOCK_HEIGHT, 0 'block.yVelocity!
        slice.active% = TRUE
        slice.frame% = 1
        left% = BlockLeft%(target)
    ELSEIF right% > BlockRight%(target) THEN
        SetBlockWithLeftRight slice.block, BlockRight%(target) + 1, right%, target.position.y! + BLOCK_HEIGHT, 0 'block.yVelocity!
        slice.active% = TRUE
        slice.frame% = 1
        right% = BlockRight%(target)
    END IF
    SetBlockWithLeftRight block, left%, right%, target.position.y! + BLOCK_HEIGHT, 0
    game.currentWidth% = block.width%
END SUB

SUB WaitToLand
    WaitForBlockToLand block(game.blockCount% - 1), block(game.blockCount% - 2)
END SUB

SUB WaitForBlockToLand (block AS BLOCK, target AS BLOCK)
    block.position.y! = block.position.y! + block.yVelocity!
    block.yVelocity! = block.yVelocity! + gravity!
    IF block.position.y! <= target.position.y! + BLOCK_HEIGHT THEN
        SetSlices block, target
        IF NOT game.gameOver% THEN
            SetGameState STATE_PLAY_TURN
            game.scroll.active% = TRUE
            game.scroll.count% = 0
            game.score& = game.score& + 10
            IF game.score& > game.hiscore& THEN game.hiscore& = game.score&
            PlaySfx SFX_LAND
        ELSE
            SetGameState STATE_GAME_OVER
            PlaySfx SFX_LOSE
        END IF
    END IF
END SUB

FUNCTION BlockLeft% (block AS BLOCK)
    BlockLeft% = block.position.x! - block.width% / 2
END FUNCTION

FUNCTION BlockRight% (block AS BLOCK)
    BlockRight% = block.position.x! + block.width% / 2
END FUNCTION

'======================================================================================================================================================================================================

FUNCTION Min% (val1%, val2%)
    IF val1% < val2% THEN Min% = val1% ELSE Min% = val2%
END FUNCTION

FUNCTION Max% (val1%, val2%)
    IF val1% > val2% THEN Max% = val1% ELSE Max% = val2%
END FUNCTION

'======================================================================================================================================================================================================

SUB RenderBackground
    _GLCOLOR4F 1, 1, 1, 0
    _GLENABLE _GL_TEXTURE_2D
    _GLBINDTEXTURE _GL_TEXTURE_2D, glData.background&
    _GLBEGIN _GL_QUADS
    _GLTEXCOORD2F 0, 1
    _GLVERTEX2F 0, 360
    _GLTEXCOORD2F 1, 1
    _GLVERTEX2F 480, 360
    _GLTEXCOORD2F 1, 0
    _GLVERTEX2F 480, 0
    _GLTEXCOORD2F 0, 0
    _GLVERTEX2F 0, 0
    _GLEND
    _GLDISABLE _GL_TEXTURE_2D
END SUB

SUB RenderStart
    DIM w%, h%, x%, y%
    w% = START_BUTTON_WIDTH
    h% = START_BUTTON_HEIGHT
    x% = SCREEN_WIDTH / 2
    y% = START_BUTTON_Y
    _GLCOLOR4F 1, 1, 1, 1
    _GLENABLE _GL_TEXTURE_2D
    _GLENABLE _GL_BLEND
    _GLBLENDFUNC _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    IF mouseOverStartButton% THEN _GLCOLOR3F 1, 1, 1 ELSE _GLCOLOR3F 0.5, 0.5, 0.5
    _GLBINDTEXTURE _GL_TEXTURE_2D, glData.normal&
    _GLBEGIN _GL_QUADS
    _GLTEXCOORD2F 0, 1
    _GLVERTEX2F x% - w% / 2, y% + h% / 2
    _GLTEXCOORD2F 1, 1
    _GLVERTEX2F x% + w% / 2, y% + h% / 2
    _GLTEXCOORD2F 1, 0
    _GLVERTEX2F x% + w% / 2, y% - h% / 2
    _GLTEXCOORD2F 0, 0
    _GLVERTEX2F x% - w% / 2, y% - h% / 2
    _GLEND
    _GLDISABLE _GL_BLEND
    _GLDISABLE _GL_TEXTURE_2D
END SUB

SUB RenderBlocks
    DIM i%
    i% = 0
    WHILE i% < game.blockCount%
        RenderSingleBlock block(i%), 1, 0.75, 0.25, 1
        i% = i% + 1
    WEND
    IF slice.active THEN
        RenderSingleBlock slice.block, 1, .25, 0.25, 1.0 - slice.frame% / SLICE_FADE_FRAMES
    END IF
END SUB

SUB RenderSingleBlock (block AS BLOCK, r!, g!, b!, alpha!)
    _GLPUSHMATRIX
    _GLENABLE _GL_BLEND
    _GLBLENDFUNC _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _GLTRANSLATEF block.position.x!, block.position.y!, 0
    _GLBEGIN _GL_QUADS
    _GLCOLOR4F r!, g!, b!, alpha!
    _GLVERTEX2F -block.width% / 2, BLOCK_HEIGHT / 2
    _GLVERTEX2F block.width% / 2, BLOCK_HEIGHT / 2
    _GLVERTEX2F block.width% / 2, -BLOCK_HEIGHT / 2
    _GLVERTEX2F -block.width% / 2, -BLOCK_HEIGHT / 2
    IF block.width% > 4 THEN
        _GLCOLOR4F r! - 0.25, g! - 0.25, b! - 0.25, alpha!
        _GLVERTEX2F -block.width% / 2 + 2, BLOCK_HEIGHT / 2 - 2
        _GLVERTEX2F block.width% / 2 - 2, BLOCK_HEIGHT / 2 - 2
        _GLVERTEX2F block.width% / 2 - 2, -BLOCK_HEIGHT / 2 + 2
        _GLVERTEX2F -block.width% / 2 + 2, -BLOCK_HEIGHT / 2 + 2
    END IF
    _GLEND
    _GLPOPMATRIX
    _GLDISABLE _GL_BLEND
END SUB

SUB RenderNumber (binding&, number&, leftX%, centreY%, charSize%, r!, g!, b!)
    DIM x%, d%, d$, tx!
    d$ = LTRIM$(STR$(number&))
    d% = 1
    'x% = centreX% + (d% - 1) * charSize% / 2
    x% = leftX%
    _GLCOLOR4F r!, g!, b!, 1
    _GLENABLE _GL_TEXTURE_2D
    _GLENABLE _GL_BLEND
    _GLBLENDFUNC _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _GLBINDTEXTURE _GL_TEXTURE_2D, binding&
    _GLBEGIN _GL_QUADS
    WHILE d% < LEN(d$) + 1
        tx! = VAL(MID$(d$, d%, 1)) / 10
        _GLTEXCOORD2F tx!, 1
        _GLVERTEX2F x%, centreY% + charSize% / 2
        _GLTEXCOORD2F tx! + 0.1, 1
        _GLVERTEX2F x% + charSize%, centreY% + charSize% / 2
        _GLTEXCOORD2F tx! + 0.1, 0
        _GLVERTEX2F x% + charSize%, centreY% - charSize% / 2
        _GLTEXCOORD2F tx!, 0
        _GLVERTEX2F x%, centreY% - charSize% / 2
        d% = d% + 1
        x% = x% + charSize%
    WEND
    _GLEND
    _GLDISABLE _GL_BLEND
    _GLDISABLE _GL_TEXTURE_2D
END SUB

'======================================================================================================================================================================================================

SUB RenderFrame
    RenderBackground
    RenderBlocks
    IF state.state% = STATE_WAIT_TO_START THEN RenderStart
    RenderNumber glData.bubbleText&, game.score&, 102, SCREEN_HEIGHT - 19, 20, 1, 1, 1
    RenderNumber glData.bubbleText&, game.hiscore&, 400, SCREEN_HEIGHT - 19, 20, 1, 1, 1
END SUB

'======================================================================================================================================================================================================

FUNCTION LoadTexture& (fileName$)
    LoadTexture& = LoadTextureInternal&(fileName$, FALSE, 0)
END FUNCTION

FUNCTION LoadTextureWithAlpha& (fileName$, rgb&)
    LoadTextureWithAlpha& = LoadTextureInternal&(fileName$, TRUE, rgb&)
END FUNCTION

FUNCTION LoadTextureInternal& (fileName$, useRgb%, rgb&)
    DIM img&, img2&, myTex&
    DIM m AS _MEM
    img& = _LOADIMAGE(fileName$, 32)
    img2& = _NEWIMAGE(_WIDTH(img&), _HEIGHT(img&), 32)
    _PUTIMAGE (0, _HEIGHT(img&))-(_WIDTH(img&), 0), img&, img2&
    IF useRgb% THEN _SETALPHA 0, rgb&, img2&
    _GLGENTEXTURES 1, _OFFSET(myTex&)
    _GLBINDTEXTURE _GL_TEXTURE_2D, myTex&
    m = _MEMIMAGE(img2&)
    _GLTEXIMAGE2D _GL_TEXTURE_2D, 0, _GL_RGBA, _WIDTH(img&), _HEIGHT(img&), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET
    _MEMFREE m
    _FREEIMAGE img&
    _FREEIMAGE img2&
    _GLTEXPARAMETERI _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
    _GLTEXPARAMETERI _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    LoadTextureInternal& = myTex&
END FUNCTION

'======================================================================================================================================================================================================

SUB _GL
    IF NOT glData.executing% THEN EXIT SUB
    IF NOT glData.initialised% THEN
        glData.initialised% = TRUE
        _GLVIEWPORT 0, 0, _WIDTH, _HEIGHT
        glData.background& = LoadTexture&("assets/background.png")
        glData.normal& = LoadTexture&("assets/start button.png")
        glData.bubbleText& = LoadTexture&("assets/bubble-numbers.png")
    END IF
    _GLMATRIXMODE _GL_PROJECTION
    _GLLOADIDENTITY
    _GLORTHO 0, _WIDTH, 0, _HEIGHT, -5, 5
    _GLMATRIXMODE _GL_MODELVIEW
    _GLLOADIDENTITY
    _GLCLEARCOLOR 0, 0, 0, 1
    _GLCLEAR _GL_COLOR_BUFFER_BIT
    RenderFrame
    _GLFLUSH
    IF _EXIT THEN
        exitProgram = TRUE
    END IF
END SUB

'======================================================================================================================================================================================================

