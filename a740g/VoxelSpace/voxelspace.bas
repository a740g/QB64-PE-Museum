' ----------------------------------------------------------------------------------------------------------------------
' Voxel-space raycaster by a740g                                                                                                                                                      `
' Uses the render algorithm presented in https://github.com/s-macke/VoxelSpace
'
' MIT License

' Copyright (c) 2025 Samuel Gomes

' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:

' The above copyright notice and this permission notice shall be included in all
' copies or substantial portions of the Software.

' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
' SOFTWARE.
'
' Please keep in mind, that the Voxel Space technology might be still patented
' in some countries. The color and height maps are reverse engineered from the
' game Comanche and are therefore excluded from the license. The sky textures
' were found on the internet and are excluded from the license.
'
' KEYBOARD:
'   FORWARD:        W / UP
'   BACK:           S / DOWN
'   STRAFE LEFT:    A
'   STRAFE RIGHT:   D
'   TURN LEFT:      LEFT
'   TURN RIGHT:     RIGHT
'   NEXT MAP:       SPACE
'
' MOUSE: MOUSE LOOK
'
' Cheers!
' ----------------------------------------------------------------------------------------------------------------------

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

$COLOR:32

CONST SCREEN_WIDTH& = 1280&
CONST SCREEN_HEIGHT& = 800&
CONST SCREEN_HALF_WIDTH& = SCREEN_WIDTH \ 2&
CONST SCREEN_HALF_HEIGHT& = SCREEN_HEIGHT \ 2&
CONST SCREEN_MAX_X& = SCREEN_WIDTH - 1&
CONST SCREEN_MAX_Y& = SCREEN_HEIGHT - 1&
CONST SCREEN_MODE& = 32&
CONST MAP_ID_MIN~%% = 1~%%
CONST MAP_ID_MAX~%% = 29~%%
CONST MAP_ID_DEFAULT~%% = MAP_ID_MIN
CONST MAP_SCALER = _STR_EMPTY ' use something like "HQ2XA" or "SXBR2" here for some extra eye-candy
CONST MAP_HEIGHT_MULTIPLIER! = 384!
CONST SKY_COUNT& = 5&
CONST PLAYER_MOVE_SPEED! = 1!
CONST PLAYER_LOOK_SPEED! = 0.1!
CONST PLAYER_HEIGHT_OFFSET& = 10&
CONST AUTOMAP_LENGTH& = 64&
CONST AUTOMAP_PLAYER_RADIUS& = 2&
CONST AUTOMAP_PLAYER_COLOR~& = White
CONST AUTOMAP_PLAYER_CAMERA_COLOR~& = Yellow
CONST AUTOMAP_BORDER_COLOR~& = Cyan
CONST RENDERER_TARGET_FPS& = 60&
CONST RENDERER_FPS_TOLERANCE& = 5&
CONST RENDERER_DISTANCE_MAX& = 8192&
CONST RENDERER_DISTANCE_MIN& = 1024&
CONST RENDERER_DELTA_Z_INCREMENT_MIN! = 0.000625!
CONST RENDERER_DELTA_Z_INCREMENT_MAX! = 0.005!
CONST RENDERER_FADE_FACTOR! = 0.0005!
CONST EVENT_NONE& = 0&
CONST EVENT_EXIT& = 1&
CONST EVENT_MAP& = 2&

TYPE Vector2i
    x AS LONG
    y AS LONG
END TYPE

TYPE Vector2f
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Camera
    angle AS SINGLE
    direction AS Vector2f
    horizon AS SINGLE
END TYPE

TYPE Player
    position AS Vector2f
    height AS SINGLE
    camera AS Camera
END TYPE

TYPE Sky
    image AS LONG
    size AS Vector2i
END TYPE

TYPE Renderer
    distance AS LONG
    deltaZIncrement AS SINGLE
    scaleHeight AS SINGLE
    ticks AS _UNSIGNED LONG
    fpsCounter AS _UNSIGNED LONG
    fps AS _UNSIGNED LONG
END TYPE

TYPE MapPixel
    r AS _UNSIGNED _BYTE
    g AS _UNSIGNED _BYTE
    b AS _UNSIGNED _BYTE
    h AS _UNSIGNED _BYTE
END TYPE

TYPE Game
    mapId AS _UNSIGNED LONG
    mapLength AS _UNSIGNED LONG
    sky AS Sky
    player AS Player
    renderer AS Renderer
    event AS LONG
END TYPE

DIM game AS Game
REDIM game_map(0, 0) AS MapPixel

Game_Initialize
Input_Initialize

DO
    Input_Update
    Renderer_DrawFrame
    Renderer_AutoAdjustLOD

    IF game.event = EVENT_MAP THEN
        game.mapId = _IIF(game.mapId >= MAP_ID_MAX, MAP_ID_MIN, game.mapId + 1)
        Game_LoadMap
        Game_LoadSky
        Renderer_Initialize
    END IF

    _DISPLAY
    _LIMIT RENDERER_TARGET_FPS
LOOP UNTIL game.event = EVENT_EXIT

Input_Shutdown
Game_Shutdown

SYSTEM


SUB Game_Initialize
    SHARED game AS Game
    SHARED game_map() AS MapPixel

    RANDOMIZE TIMER

    $RESIZE:SMOOTH
    SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_MODE)
    _FULLSCREEN _SQUAREPIXELS , _SMOOTH
    _PRINTMODE _KEEPBACKGROUND
    _DISPLAYORDER _HARDWARE , _GLRENDER , _HARDWARE1 , _SOFTWARE

    game.mapId = MAP_ID_DEFAULT

    REDIM game_map(0, 0) AS MapPixel
    Game_LoadMap

    Game_LoadSky

    game.player.position.x = 64!
    game.player.position.y = 64!
    game.player.height = PLAYER_HEIGHT_OFFSET + game_map(game.player.position.x, game.player.position.y).h
    game.player.camera.angle = 90!
    game.player.camera.horizon = 120!
    Camera_Update

    Renderer_Initialize
END SUB


SUB Game_Shutdown
    SHARED game AS Game

    _FREEIMAGE game.sky.image
END SUB


SUB Game_LoadMap
    SHARED game AS Game
    SHARED game_map() AS MapPixel

    DIM mapFileName AS STRING: mapFileName = "maps/c" + _TOSTR$(game.mapId) + "w.png"
    IF NOT _FILEEXISTS(mapFileName) THEN
        mapFileName = "maps/c" + _TOSTR$(game.mapId) + ".png"
    END IF

    _TITLE mapFileName

    DIM mapImg AS LONG: mapImg = _LOADIMAGE(mapFileName, 32, MAP_SCALER)
    _ASSERT mapImg < -1
    _ASSERT _WIDTH(mapImg) = _HEIGHT(mapImg)

    game.mapLength = _WIDTH(mapImg)

    REDIM game_map(0 TO game.mapLength - 1, 0 TO game.mapLength - 1) AS MapPixel

    DIM oldSrc AS LONG: oldSrc = _SOURCE
    _SOURCE mapImg

    DIM p AS Vector2i, c AS _UNSIGNED LONG

    FOR p.y = 0 TO game.mapLength - 1
        FOR p.x = 0 TO game.mapLength - 1
            c = POINT(p.x, p.y)
            game_map(p.x, p.y).r = _RED32(c)
            game_map(p.x, p.y).g = _GREEN32(c)
            game_map(p.x, p.y).b = _BLUE32(c)
        NEXT p.x
    NEXT p.y

    DIM hgtImg AS LONG: hgtImg = _LOADIMAGE("maps/d" + _TOSTR$(game.mapId) + ".png", 32, MAP_SCALER)
    _ASSERT hgtImg < -1
    _ASSERT _WIDTH(mapImg) = _HEIGHT(mapImg)

    _PUTIMAGE , hgtImg, mapImg
    _FREEIMAGE hgtImg

    FOR p.y = 0 TO game.mapLength - 1
        FOR p.x = 0 TO game.mapLength - 1
            game_map(p.x, p.y).h = _RED32(POINT(p.x, p.y))
        NEXT p.x
    NEXT p.y

    _SOURCE oldSrc
    _FREEIMAGE mapImg
END SUB


SUB Game_LoadSky
    SHARED game AS Game

    IF game.sky.image < -1 THEN
        _FREEIMAGE game.sky.image
        game.sky.image = 0
    END IF

    DIM skyFileName AS STRING: skyFileName = "pics/sky" + _TOSTR$(_CAST(LONG, RND * SKY_COUNT)) + ".jpeg"

    _TITLE _TITLE$ + " | " + skyFileName + " - Voxel Space Demo"

    game.sky.image = _LOADIMAGE(skyFileName, 32, "hardware")
    _ASSERT game.sky.image < -1

    game.sky.size.x = _WIDTH(game.sky.image)
    game.sky.size.y = _HEIGHT(game.sky.image)
END SUB


SUB Camera_Update
    SHARED game AS Game

    DIM ra AS SINGLE: ra = _D2R(game.player.camera.angle)
    game.player.camera.direction.x = COS(ra)
    game.player.camera.direction.y = SIN(ra)
END SUB


SUB Input_Initialize
    $IF MACOSX AND VERSION < 4.1.0 THEN
        DECLARE LIBRARY
            SUB CGAssociateMouseAndMouseCursorPosition (BYVAL connected AS _BYTE)
        END DECLARE
    $END IF

    _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT
    _MOUSEHIDE

    $IF MACOSX AND VERSION < 4.1.0 THEN
        CGAssociateMouseAndMouseCursorPosition _FALSE ' screw you apple!
    $END IF
END SUB


SUB Input_Shutdown
    $IF MACOSX AND VERSION < 4.1.0 THEN
        CGAssociateMouseAndMouseCursorPosition _TRUE ' screw you apple!
    $END IF

    _MOUSESHOW
    _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT
END SUB


SUB Input_Update
    SHARED game AS Game
    SHARED game_map() AS MapPixel

    game.event = EVENT_NONE

    DIM mouseUsed AS _BYTE, m AS Vector2i

    WHILE _MOUSEINPUT
        $IF WINDOWS THEN
            m.x = m.x + _MOUSEMOVEMENTX
            m.y = m.y + _MOUSEMOVEMENTY
        $END IF

        mouseUsed = _TRUE
    WEND

    IF mouseUsed THEN
        $IF WINDOWS THEN
            IF _MOUSEX <> SCREEN_HALF_WIDTH _ORELSE _MOUSEY <> SCREEN_HALF_HEIGHT THEN
                _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT
            END IF
        $ELSEIF MACOSX OR LINUX THEN
            m.x = _MOUSEX - SCREEN_HALF_WIDTH
            m.y = _MOUSEY - SCREEN_HALF_HEIGHT

            IF m.x _ORELSE m.y THEN
                _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT
            END IF
        $END IF
    END IF

    IF _KEYDOWN(_KEY_LEFT) THEN
        m.x = m.x - PLAYER_MOVE_SPEED * 10
        mouseUsed = _TRUE
    END IF

    IF _KEYDOWN(_KEY_RIGHT) THEN
        m.x = m.x + PLAYER_MOVE_SPEED * 10
        mouseUsed = _TRUE
    END IF

    IF mouseUsed THEN
        game.player.camera.angle = (game.player.camera.angle + m.x * PLAYER_LOOK_SPEED)
        IF game.player.camera.angle >= 360! THEN game.player.camera.angle = game.player.camera.angle - 360!
        IF game.player.camera.angle < 0! THEN game.player.camera.angle = game.player.camera.angle + 360!

        game.player.camera.horizon = _CLAMP(game.player.camera.horizon - m.y, -SCREEN_HALF_HEIGHT, SCREEN_HEIGHT + SCREEN_HALF_HEIGHT)

        Camera_Update
    END IF

    DIM keyboardUsed AS _BYTE, position AS Vector2f

    IF _KEYDOWN(87) _ORELSE _KEYDOWN(119) _ORELSE _KEYDOWN(_KEY_UP) THEN
        position.x = game.player.position.x - game.player.camera.direction.x * PLAYER_MOVE_SPEED
        position.y = game.player.position.y - game.player.camera.direction.y * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(83) _ORELSE _KEYDOWN(115) _ORELSE _KEYDOWN(_KEY_DOWN) THEN
        position.x = game.player.position.x + game.player.camera.direction.x * PLAYER_MOVE_SPEED
        position.y = game.player.position.y + game.player.camera.direction.y * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(65) _ORELSE _KEYDOWN(97) THEN
        position.x = game.player.position.x - game.player.camera.direction.y * PLAYER_MOVE_SPEED
        position.y = game.player.position.y + game.player.camera.direction.x * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(68) _ORELSE _KEYDOWN(100) THEN
        position.x = game.player.position.x + game.player.camera.direction.y * PLAYER_MOVE_SPEED
        position.y = game.player.position.y - game.player.camera.direction.x * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF keyboardUsed THEN
        IF position.x < 0 THEN position.x = position.x + game.mapLength
        IF position.y < 0 THEN position.y = position.y + game.mapLength
        IF position.x >= game.mapLength THEN position.x = position.x - game.mapLength
        IF position.y >= game.mapLength THEN position.y = position.y - game.mapLength

        game.player.position = position

        m.x = _CAST(LONG, position.x)
        m.y = _CAST(LONG, position.y)

        game.player.height = PLAYER_HEIGHT_OFFSET + game_map(m.x, m.y).h
    END IF

    IF _KEYDOWN(_KEY_ESC) THEN
        game.event = EVENT_EXIT
    ELSEIF _KEYDOWN(_ASC_SPACE) THEN
        game.event = EVENT_MAP
    END IF
END SUB


SUB Renderer_DrawAutomap
    SHARED game AS Game
    SHARED game_map() AS MapPixel

    DIM amScale AS SINGLE: amScale = AUTOMAP_LENGTH / game.mapLength
    DIM amStep AS LONG: amStep = game.mapLength \ AUTOMAP_LENGTH
    DIM AS Vector2i p, o
    DIM c AS _UNSIGNED _BYTE

    WHILE p.y < game.mapLength
        p.x = 0
        WHILE p.x < game.mapLength
            c = game_map(p.x, p.y).h
            PSET (p.x * amScale, p.y * amScale), _RGB32(c, 255~%% - c)

            p.x = p.x + amStep
        WEND

        p.y = p.y + amStep
    WEND

    p.x = game.player.position.x * amScale
    p.y = game.player.position.y * amScale

    o.x = p.x - game.player.camera.direction.x * AUTOMAP_PLAYER_RADIUS * 2
    o.y = p.y - game.player.camera.direction.y * AUTOMAP_PLAYER_RADIUS * 2

    LINE (0, 0)-(AUTOMAP_LENGTH - 1, AUTOMAP_LENGTH - 1), AUTOMAP_BORDER_COLOR, B
    CIRCLE (p.x, p.y), AUTOMAP_PLAYER_RADIUS, AUTOMAP_PLAYER_COLOR
    LINE (p.x, p.y)-(o.x, o.y), AUTOMAP_PLAYER_CAMERA_COLOR
END SUB


SUB Renderer_DrawSky
    SHARED game AS Game

    DIM AS Vector2i skyPos
    skyPos.x = (game.player.camera.angle * game.sky.size.x) \ 360
    skyPos.y = game.sky.size.y - game.player.camera.horizon - SCREEN_HALF_HEIGHT

    IF skyPos.x + SCREEN_WIDTH > game.sky.size.x THEN
        DIM partialWidth AS LONG: partialWidth = game.sky.size.x - skyPos.x

        _PUTIMAGE (0, 0), game.sky.image, , (skyPos.x, skyPos.y)-STEP(partialWidth - 1, SCREEN_MAX_Y), _SMOOTH
        _PUTIMAGE (partialWidth, 0), game.sky.image, , (0, skyPos.y)-STEP(SCREEN_WIDTH - partialWidth - 1, SCREEN_MAX_Y), _SMOOTH
    ELSE
        _PUTIMAGE (0, 0), game.sky.image, , (skyPos.x, skyPos.y)-STEP(SCREEN_MAX_X, SCREEN_MAX_Y), _SMOOTH
    END IF
END SUB


SUB Renderer_Initialize
    DECLARE LIBRARY
        FUNCTION Renderer_GetTicks~&& ALIAS "GetTicks"
    END DECLARE

    SHARED game AS Game

    game.renderer.distance = RENDERER_DISTANCE_MAX
    game.renderer.deltaZIncrement = RENDERER_DELTA_Z_INCREMENT_MIN
    game.renderer.scaleHeight = MAP_HEIGHT_MULTIPLIER * game.mapLength / SCREEN_HEIGHT
    game.renderer.ticks = Renderer_GetTicks
    game.renderer.fpsCounter = RENDERER_TARGET_FPS
    game.renderer.fps = RENDERER_TARGET_FPS
END SUB


SUB Renderer_AutoAdjustLOD
    SHARED game AS Game

    DIM ticks AS _UNSIGNED _INTEGER64: ticks = Renderer_GetTicks

    IF ticks >= game.renderer.ticks + 1000 THEN
        game.renderer.ticks = ticks
        game.renderer.fps = game.renderer.fpsCounter
        game.renderer.fpsCounter = 0

        IF game.renderer.fps < RENDERER_TARGET_FPS - RENDERER_FPS_TOLERANCE THEN
            IF game.renderer.distance > RENDERER_DISTANCE_MIN THEN
                game.renderer.distance = game.renderer.distance - RENDERER_DISTANCE_MIN
            ELSEIF game.renderer.deltaZIncrement < RENDERER_DELTA_Z_INCREMENT_MAX THEN
                game.renderer.deltaZIncrement = game.renderer.deltaZIncrement + RENDERER_DELTA_Z_INCREMENT_MIN
            END IF
        ELSEIF game.renderer.fps > RENDERER_TARGET_FPS + RENDERER_FPS_TOLERANCE THEN
            IF game.renderer.deltaZIncrement > RENDERER_DELTA_Z_INCREMENT_MIN THEN
                game.renderer.deltaZIncrement = game.renderer.deltaZIncrement - RENDERER_DELTA_Z_INCREMENT_MIN
            ELSEIF game.renderer.distance < RENDERER_DISTANCE_MAX THEN
                game.renderer.distance = game.renderer.distance + RENDERER_DISTANCE_MIN
            END IF
        END IF
    END IF

    game.renderer.fpsCounter = game.renderer.fpsCounter + 1

    DIM fontHeight AS LONG: fontHeight = _FONTHEIGHT
    DIM debugYPos AS LONG: debugYPos = SCREEN_HEIGHT - _FONTHEIGHT
    _PRINTSTRING (0, debugYPos), "FPS:" + STR$(game.renderer.fps)
    debugYPos = debugYPos - fontHeight
    _PRINTSTRING (0, debugYPos), "Distance:" + STR$(game.renderer.distance)
    debugYPos = debugYPos - fontHeight
    _PRINTSTRING (0, debugYPos), "DZI: " + _TOSTR$(game.renderer.deltaZIncrement, 7)
END SUB


SUB Renderer_DrawFrame
    SHARED game AS Game
    SHARED game_map() AS MapPixel

    CLS 1, 0

    Renderer_DrawSky

    DIM hiddenY(0 TO SCREEN_MAX_X) AS LONG

    DIM i AS LONG
    FOR i = 0 TO SCREEN_MAX_X
        hiddenY(i) = SCREEN_HEIGHT
    NEXT i

    DIM AS Vector2f pLeft, pRight, d
    DIM mapPos AS Vector2i, pix AS MapPixel, cm AS SINGLE
    DIM AS SINGLE heightOnScreen, invZ
    DIM deltaZ AS SINGLE: deltaZ = 1!
    DIM z AS SINGLE: z = 1!

    WHILE z < game.renderer.distance
        pLeft.x = game.player.position.x + (-game.player.camera.direction.y * z - game.player.camera.direction.x * z)
        pLeft.y = game.player.position.y + (game.player.camera.direction.x * z - game.player.camera.direction.y * z)

        pRight.x = game.player.position.x + (game.player.camera.direction.y * z - game.player.camera.direction.x * z)
        pRight.y = game.player.position.y + (-game.player.camera.direction.x * z - game.player.camera.direction.y * z)

        d.x = (pRight.x - pLeft.x) / SCREEN_WIDTH
        d.y = (pRight.y - pLeft.y) / SCREEN_WIDTH

        invZ = game.renderer.scaleHeight / z

        FOR i = 0 TO SCREEN_MAX_X
            mapPos.x = (_CAST(LONG, pLeft.x) MOD game.mapLength + game.mapLength) MOD game.mapLength
            mapPos.y = (_CAST(LONG, pLeft.y) MOD game.mapLength + game.mapLength) MOD game.mapLength

            pix = game_map(mapPos.x, mapPos.y)
            heightOnScreen = (game.player.height - pix.h) * invZ + game.player.camera.horizon

            IF heightOnScreen < hiddenY(i) THEN
                cm = 1! - z * RENDERER_FADE_FACTOR
                LINE (i, heightOnScreen)-(i, hiddenY(i)), _RGB32(cm * pix.r, cm * pix.g, cm * pix.b), BF
                hiddenY(i) = heightOnScreen
            END IF

            pLeft.x = pLeft.x + d.x
            pLeft.y = pLeft.y + d.y
        NEXT i

        z = z + deltaZ
        deltaZ = deltaZ + game.renderer.deltaZIncrement
    WEND

    Renderer_DrawAutomap
END SUB
