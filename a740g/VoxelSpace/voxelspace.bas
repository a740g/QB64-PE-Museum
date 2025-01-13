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

'$LET TOASTY = TRUE

CONST SCREEN_WIDTH& = 1280&
CONST SCREEN_HEIGHT& = 800&
CONST SCREEN_HALF_WIDTH& = SCREEN_WIDTH \ 2&
CONST SCREEN_HALF_HEIGHT& = SCREEN_HEIGHT \ 2&
CONST SCREEN_MAX_X& = SCREEN_WIDTH - 1&
CONST SCREEN_MAX_Y& = SCREEN_HEIGHT - 1&
CONST SCREEN_MODE& = 32&
CONST RENDER_FPS& = 60&
CONST MAP_ID_MIN~%% = 1~%%
CONST MAP_ID_MAX~%% = 29~%%
CONST MAP_ID_DEFAULT~%% = MAP_ID_MIN
CONST MAP_COLOR& = 0&
CONST MAP_HEIGHT& = 1&
CONST SKY_COUNT& = 5&
CONST PLAYER_FOV& = 60&
CONST PLAYER_HALF_FOV& = PLAYER_FOV \ 2&
CONST PLAYER_MOVE_SPEED! = 1!
CONST PLAYER_LOOK_SPEED! = 0.1!
CONST PLAYER_HEIGHT_OFFSET& = 10&
CONST AUTOMAP_SIZE& = 64&
CONST AUTOMAP_MAX_XY& = AUTOMAP_SIZE - 1&
CONST AUTOMAP_PLAYER_RADIUS& = 2&
CONST AUTOMAP_PLAYER_COLOR~& = White
CONST AUTOMAP_PLAYER_CAMERA_COLOR~& = Yellow
CONST AUTOMAP_BORDER_COLOR~& = Cyan
$IF TOASTY = TRUE THEN
    CONST RENDER_DISTANCE& = 2048&
    CONST RENDER_DELTA_Z_INCREMENT! = 0.001!
$ELSE
    CONST RENDER_DISTANCE& = 1024& ' the higher this is, the farther you will be able to see at the cost of CPU load
    CONST RENDER_DELTA_Z_INCREMENT! = 0.005! ' the smaller this is, the the more detail you will be able to see at the cost of CPU load
$END IF
CONST RENDER_SCALE_HEIGHT& = 255& * (SCREEN_WIDTH / SCREEN_HEIGHT)

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

RANDOMIZE TIMER

$RESIZE:SMOOTH
SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_MODE)
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND

DIM mapId AS _UNSIGNED _BYTE
mapId = MAP_ID_DEFAULT

REDIM map(0, 0, 0) AS _UNSIGNED LONG
LoadWorld map(), mapId

DIM environment AS LONG
environment = LoadEnvironment
_ASSERT environment < -1

DIM player AS Player
player.position.x = 64!
player.position.y = 64!
player.height = map(MAP_HEIGHT, player.position.x, player.position.y) + PLAYER_HEIGHT_OFFSET
player.camera.angle = 90!
player.camera.horizon = 120!
UpdatePlayerCamera player

_MOUSEHIDE

DIM k AS LONG

DO
    HandleInput player, map()
    RenderFrame player, map(), environment

    k = _KEYHIT

    IF k = _ASC_SPACE THEN
        mapId = mapId + 1
        IF mapId > MAP_ID_MAX THEN
            mapId = MAP_ID_MIN
        END IF

        LoadWorld map(), mapId

        _FREEIMAGE environment
        environment = LoadEnvironment
        _ASSERT environment < -1
    END IF

    _DISPLAY
    _LIMIT RENDER_FPS
LOOP UNTIL k = _KEY_ESC

SYSTEM

SUB LoadWorld (map( , ,) AS _UNSIGNED LONG, mapid AS _UNSIGNED _BYTE)
    DIM mapFileName AS STRING: mapFileName = "maps/c" + _TOSTR$(mapid) + "w.png"
    IF NOT _FILEEXISTS(mapFileName) THEN
        mapFileName = "maps/c" + _TOSTR$(mapid) + ".png"
    END IF

    _TITLE mapFileName

    DIM mapImg AS LONG: mapImg = _LOADIMAGE(mapFileName, 32)
    _ASSERT mapImg < -1

    REDIM map(0 TO 1, 0 TO _WIDTH(mapImg) - 1, 0 TO _HEIGHT(mapImg) - 1) AS _UNSIGNED LONG

    DIM oldSrc AS LONG: oldSrc = _SOURCE
    _SOURCE mapImg

    DIM p AS Vector2i

    FOR p.y = 0 TO _HEIGHT(mapImg) - 1
        FOR p.x = 0 TO _WIDTH(mapImg) - 1
            map(MAP_COLOR, p.x, p.y) = POINT(p.x, p.y)
        NEXT p.x
    NEXT p.y

    DIM hgtImg AS LONG: hgtImg = _LOADIMAGE("maps/d" + _TOSTR$(mapid) + ".png", 32)
    _ASSERT hgtImg < -1

    _PUTIMAGE , hgtImg, mapImg
    _FREEIMAGE hgtImg

    FOR p.y = 0 TO _HEIGHT(mapImg) - 1
        FOR p.x = 0 TO _WIDTH(mapImg) - 1
            map(MAP_HEIGHT, p.x, p.y) = _RED32(POINT(p.x, p.y))
        NEXT p.x
    NEXT p.y

    _SOURCE oldSrc
    _FREEIMAGE mapImg
END SUB

FUNCTION LoadEnvironment&
    DIM skyFileName AS STRING: skyFileName = "pics/sky" + _TOSTR$(_CAST(LONG, RND * SKY_COUNT)) + ".jpeg"
    _TITLE _TITLE$ + " | " + skyFileName + " - Voxel Space Demo"
    LoadEnvironment = _LOADIMAGE(skyFileName, 32)
END FUNCTION

SUB UpdatePlayerCamera (player AS Player)
    DIM ra AS SINGLE: ra = _D2R(player.camera.angle)
    player.camera.direction.x = COS(ra)
    player.camera.direction.y = SIN(ra)
END SUB

SUB HandleInput (player AS Player, map( , ,) AS _UNSIGNED LONG)
    DIM mouseUsed AS _BYTE

    DIM m AS Vector2i
    WHILE _MOUSEINPUT
        m.x = m.x + _MOUSEMOVEMENTX
        m.y = m.y + _MOUSEMOVEMENTY
        mouseUsed = _TRUE
    WEND

    _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT

    IF _KEYDOWN(_KEY_LEFT) THEN
        m.x = m.x - PLAYER_MOVE_SPEED * 10
        mouseUsed = _TRUE
    END IF

    IF _KEYDOWN(_KEY_RIGHT) THEN
        m.x = m.x + PLAYER_MOVE_SPEED * 10
        mouseUsed = _TRUE
    END IF

    IF mouseUsed THEN
        player.camera.angle = (player.camera.angle + m.x * PLAYER_LOOK_SPEED)
        IF player.camera.angle >= 360! THEN player.camera.angle = player.camera.angle - 360!
        IF player.camera.angle < 0! THEN player.camera.angle = player.camera.angle + 360!

        player.camera.horizon = _CLAMP(player.camera.horizon - m.y, -SCREEN_HALF_HEIGHT, SCREEN_HEIGHT + SCREEN_HALF_HEIGHT)

        UpdatePlayerCamera player
    END IF

    DIM keyboardUsed AS _BYTE, position AS Vector2f

    IF _KEYDOWN(87) _ORELSE _KEYDOWN(119) _ORELSE _KEYDOWN(_KEY_UP) THEN
        position.x = player.position.x - player.camera.direction.x * PLAYER_MOVE_SPEED
        position.y = player.position.y - player.camera.direction.y * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(83) _ORELSE _KEYDOWN(115) _ORELSE _KEYDOWN(_KEY_DOWN) THEN
        position.x = player.position.x + player.camera.direction.x * PLAYER_MOVE_SPEED
        position.y = player.position.y + player.camera.direction.y * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(65) _ORELSE _KEYDOWN(97) THEN
        position.x = player.position.x - player.camera.direction.y * PLAYER_MOVE_SPEED
        position.y = player.position.y + player.camera.direction.x * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(68) _ORELSE _KEYDOWN(100) THEN
        position.x = player.position.x + player.camera.direction.y * PLAYER_MOVE_SPEED
        position.y = player.position.y - player.camera.direction.x * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF keyboardUsed THEN
        IF position.x < 0 THEN position.x = position.x + UBOUND(map, 2) + 1
        IF position.y < 0 THEN position.y = position.y + UBOUND(map, 3) + 1
        IF position.x > UBOUND(map, 2) THEN position.x = position.x - (UBOUND(map, 2) + 1)
        IF position.y > UBOUND(map, 3) THEN position.y = position.y - (UBOUND(map, 3) + 1)

        player.position = position

        m.x = _CAST(LONG, position.x)
        m.y = _CAST(LONG, position.y)

        player.height = map(MAP_HEIGHT, m.x, m.y) + PLAYER_HEIGHT_OFFSET
    END IF
END SUB

SUB DrawAutomap (player AS Player, map( , ,) AS _UNSIGNED LONG)
    DIM mapSize AS LONG: mapSize = UBOUND(map, 2) + 1
    DIM amScale AS SINGLE: amScale = AUTOMAP_SIZE / mapSize
    DIM amStep AS SINGLE: amStep = mapSize / AUTOMAP_SIZE
    DIM AS Vector2i p, o
    DIM c AS _UNSIGNED LONG

    FOR p.y = 0 TO mapSize - 1 STEP amStep
        FOR p.x = 0 TO mapSize - 1 STEP amStep
            c = map(MAP_HEIGHT, p.x, p.y)
            PSET (p.x * amScale, p.y * amScale), _RGB32(c, 255 - c)
        NEXT p.x
    NEXT p.y

    p.x = player.position.x * amScale
    p.y = player.position.y * amScale

    o.x = p.x - player.camera.direction.x * AUTOMAP_PLAYER_RADIUS * 2
    o.y = p.y - player.camera.direction.y * AUTOMAP_PLAYER_RADIUS * 2

    LINE (0, 0)-(AUTOMAP_SIZE - 1, AUTOMAP_SIZE - 1), AUTOMAP_BORDER_COLOR, B
    CIRCLE (p.x, p.y), AUTOMAP_PLAYER_RADIUS, AUTOMAP_PLAYER_COLOR
    LINE (p.x, p.y)-(o.x, o.y), AUTOMAP_PLAYER_CAMERA_COLOR
END SUB

SUB DrawBackground (player AS Player, environmentImg AS LONG)
    DIM AS Vector2i skyPos, skySize

    skySize.x = _WIDTH(environmentImg)
    skySize.y = _HEIGHT(environmentImg)

    skyPos.x = (player.camera.angle / 360!) * skySize.x
    skyPos.y = skySize.y - player.camera.horizon - SCREEN_HALF_HEIGHT

    IF skyPos.x + SCREEN_WIDTH > skySize.x THEN
        DIM partialWidth AS LONG: partialWidth = skySize.x - skyPos.x

        _PUTIMAGE (0, 0)-(partialWidth - 1, SCREEN_MAX_Y), environmentImg, , (skyPos.x, skyPos.y)-(skySize.x - 1, skyPos.y + SCREEN_MAX_Y)
        _PUTIMAGE (partialWidth, 0)-(SCREEN_MAX_X, SCREEN_MAX_Y), environmentImg, , (0, skyPos.y)-(SCREEN_WIDTH - partialWidth - 1, skyPos.y + SCREEN_MAX_Y)
    ELSE
        _PUTIMAGE (0, 0)-(SCREEN_MAX_X, SCREEN_MAX_Y), environmentImg, , (skyPos.x, skyPos.y)-(skyPos.x + SCREEN_MAX_X, skyPos.y + SCREEN_MAX_Y)
    END IF
END SUB

SUB RenderFrame (player AS Player, map( , ,) AS _UNSIGNED LONG, environmentImg AS LONG)
    DrawBackground player, environmentImg

    DIM hiddenY(0 TO SCREEN_MAX_X) AS LONG

    DIM i AS LONG
    FOR i = 0 TO SCREEN_MAX_X
        hiddenY(i) = SCREEN_HEIGHT
    NEXT i

    DIM mapSize AS Vector2i
    mapSize.x = UBOUND(map, 2) + 1
    mapSize.y = UBOUND(map, 3) + 1

    DIM AS Vector2f pLeft, pRight, d
    DIM mapPos AS Vector2i, heightOnScreen AS SINGLE
    DIM invZ AS SINGLE
    DIM deltaZ AS SINGLE: deltaZ = 1!
    DIM z AS SINGLE: z = 1!

    WHILE z < RENDER_DISTANCE
        pLeft.x = player.position.x + (-player.camera.direction.y * z - player.camera.direction.x * z)
        pLeft.y = player.position.y + (player.camera.direction.x * z - player.camera.direction.y * z)

        pRight.x = player.position.x + (player.camera.direction.y * z - player.camera.direction.x * z)
        pRight.y = player.position.y + (-player.camera.direction.x * z - player.camera.direction.y * z)

        d.x = (pRight.x - pLeft.x) / SCREEN_WIDTH
        d.y = (pRight.y - pLeft.y) / SCREEN_WIDTH

        invZ = 1! / z * RENDER_SCALE_HEIGHT

        FOR i = 0 TO SCREEN_MAX_X
            mapPos.x = (_CAST(LONG, pLeft.x) MOD mapSize.x + mapSize.x) MOD mapSize.x
            mapPos.y = (_CAST(LONG, pLeft.y) MOD mapSize.y + mapSize.y) MOD mapSize.y

            heightOnScreen = (player.height - map(MAP_HEIGHT, mapPos.x, mapPos.y)) * invZ + player.camera.horizon

            IF heightOnScreen < hiddenY(i) THEN
                LINE (i, heightOnScreen)-(i, hiddenY(i)), map(MAP_COLOR, mapPos.x, mapPos.y)
                hiddenY(i) = heightOnScreen
            END IF

            pLeft.x = pLeft.x + d.x
            pLeft.y = pLeft.y + d.y
        NEXT i

        z = z + deltaZ
        deltaZ = deltaZ + RENDER_DELTA_Z_INCREMENT
    WEND

    DrawAutomap player, map()

    _PRINTSTRING (0, SCREEN_HEIGHT - _FONTHEIGHT), STR$(GetHertz) + " FPS"
END SUB

FUNCTION GetHertz~&
    DECLARE LIBRARY
        FUNCTION GetTicks~&&
    END DECLARE

    STATIC AS _UNSIGNED LONG counter, finalFPS
    STATIC lastTime AS _UNSIGNED _INTEGER64

    DIM currentTime AS _UNSIGNED _INTEGER64: currentTime = GetTicks

    IF currentTime >= lastTime + 1000 THEN
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    END IF

    counter = counter + 1

    GetHertz = finalFPS
END FUNCTION
