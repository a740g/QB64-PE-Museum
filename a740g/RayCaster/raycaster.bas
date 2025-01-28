' Solid-wall raycaster by a740g
' Does not use DDA-based optimizations (yet)
' Performance may suffer on potato hardware
'
' Bibliography:
'   https://lodev.org/cgtutor/raycasting.html
'   https://github.com/vinibiavatti1/RayCastingTutorial
'   https://wynnliam.github.io/raycaster/news/tutorial/2019/03/23/raycaster-part-01.html

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST SCREEN_WIDTH& = 640&
CONST SCREEN_HEIGHT& = 400&
CONST SCREEN_HALF_WIDTH& = SCREEN_WIDTH \ 2&
CONST SCREEN_HALF_HEIGHT& = SCREEN_HEIGHT \ 2&
CONST SCREEN_MAX_X& = SCREEN_WIDTH - 1&
CONST SCREEN_MAX_Y& = SCREEN_HEIGHT - 1&
CONST SCREEN_MODE& = 256&
CONST RENDER_FPS& = 60&
CONST PLAYER_FOV& = 60&
CONST PLAYER_HALF_FOV& = PLAYER_FOV \ 2&
CONST RAYCAST_INCREMENT_ANGLE! = PLAYER_FOV / SCREEN_WIDTH
CONST RAYCAST_PRECISION! = 64!
CONST MAP_DEFAULT_BOUNDARY_COLOR~& = 7
CONST PLAYER_MOVE_SPEED! = 0.1!
CONST PLAYER_LOOK_SPEED! = 0.1!
CONST AUTOMAP_SCALE& = 4
CONST AUTOMAP_PLAYER_RADIUS& = 2
CONST AUTOMAP_PLAYER_COLOR~& = 15
CONST AUTOMAP_PLAYER_CAMERA_COLOR~& = 14

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
END TYPE

TYPE Player
    position AS Vector2f
    camera AS Camera
END TYPE

RANDOMIZE TIMER

$RESIZE:SMOOTH
SCREEN _NEWIMAGE(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_MODE)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND
_TITLE "Raycaster Demo"

REDIM map(0, 0) AS _UNSIGNED LONG
RESTORE level_data
Map_Load map()

DIM environment AS LONG
environment = Sky_Initialize

DIM player AS Player
player.position.x = 2!
player.position.y = 2!
player.camera.angle = 0!
Camera_Update player

DIM automap AS LONG
automap = Automap_Initialize(map())

Input_Initialize

DO
    Input_Update player, map()
    Game_RenderFrame player, map(), environment, automap

    _DISPLAY
    _LIMIT RENDER_FPS
LOOP UNTIL _KEYHIT = _KEY_ESC

Input_Shutdown

SYSTEM

' Level data:
' Width,Height
' Wall colors in hexadecimal
level_data:
DATA 24,20
DATA 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
DATA 7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7
DATA 7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7
DATA 7,0,0,B,0,B,B,B,B,0,0,0,0,0,0,9,0,9,9,9,9,0,0,7
DATA 7,0,0,B,0,0,0,0,B,0,0,0,0,0,0,9,0,0,0,9,9,0,0,7
DATA 7,0,0,B,0,0,0,0,B,0,0,0,0,0,0,9,9,9,9,0,0,0,0,7
DATA 7,0,0,B,0,0,0,0,B,0,0,0,0,0,0,9,9,9,9,0,0,0,0,7
DATA 7,0,0,B,B,B,B,B,B,0,0,0,0,0,0,9,0,0,0,9,9,0,0,7
DATA 7,0,0,0,0,B,B,0,0,0,0,0,0,0,0,9,0,9,9,9,9,0,0,7
DATA 7,0,0,0,0,0,0,0,0,0,0,8,F,0,0,0,0,0,0,0,0,0,0,7
DATA 7,0,0,0,0,0,0,0,0,0,0,F,8,0,0,0,0,0,0,0,0,0,0,7
DATA 7,0,0,E,E,E,E,E,E,0,0,0,0,0,0,C,0,0,0,0,C,0,0,7
DATA 7,0,0,E,0,0,0,0,0,0,0,0,0,0,0,C,0,0,0,0,C,0,0,7
DATA 7,0,0,E,0,0,0,0,0,0,0,0,0,0,0,C,C,C,C,C,C,0,0,7
DATA 7,0,0,E,0,E,E,E,E,0,0,0,0,0,0,0,0,0,0,0,C,0,0,7
DATA 7,0,0,E,0,0,0,0,E,0,0,0,0,0,0,0,0,0,0,0,C,0,0,7
DATA 7,0,0,E,E,E,E,E,E,0,0,0,0,0,0,0,0,0,0,0,C,0,0,7
DATA 7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7
DATA 7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7
DATA 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7


SUB Map_Load (map( ,) AS _UNSIGNED LONG)
    DIM AS Vector2i m, mapMax
    READ mapMax.x, mapMax.y
    mapMax.x = mapMax.x - 1
    mapMax.y = mapMax.y - 1

    REDIM map(0 TO mapMax.x, 0 TO mapMax.y) AS _UNSIGNED LONG

    DIM d AS STRING

    FOR m.y = 0 TO mapMax.y
        FOR m.x = 0 TO mapMax.x
            READ d
            map(m.x, mapMax.y - m.y) = VAL("&H" + d)
        NEXT m.x
    NEXT m.y
END SUB


FUNCTION Sky_Initialize&
    CONST PANORAMA_WIDTH& = SCREEN_WIDTH * 4
    CONST SUN_RADIUS& = 20
    CONST SUN_COLOR& = 14
    CONST CLOUD_COUNT& = 10
    CONST CLOUD_COLOR& = 15
    CONST BUILDING_COLOR& = 8

    DIM oldDest AS LONG: oldDest = _DEST
    DIM img AS LONG: img = _NEWIMAGE(PANORAMA_WIDTH, SCREEN_HEIGHT, SCREEN_MODE)
    _DEST img

    LINE (0, 0)-(PANORAMA_WIDTH - 1, SCREEN_HALF_HEIGHT - 1), 3, BF

    DIM x AS LONG: x = SUN_RADIUS + (PANORAMA_WIDTH - 2 * SUN_RADIUS - 1) * RND
    DIM y AS LONG: y = SUN_RADIUS + (SCREEN_HALF_HEIGHT - 2 * SUN_RADIUS - 1) * RND
    CIRCLE (x, y), SUN_RADIUS, SUN_COLOR
    PAINT (x, y), SUN_COLOR, SUN_COLOR

    DIM AS LONG i, j

    FOR i = 1 TO CLOUD_COUNT
        j = (PANORAMA_WIDTH \ 8) * RND
        x = j + (PANORAMA_WIDTH - 2 * j) * RND
        y = j + (SCREEN_HALF_HEIGHT - 2 * j) * RND
        CIRCLE (x, y), j, CLOUD_COLOR, , , RND / 10!
        PAINT (x, y), CLOUD_COLOR
    NEXT i

    x = (PANORAMA_WIDTH - 80) * RND

    LINE (x, 40)-(x + 40, 30), BUILDING_COLOR
    LINE (x + 40, 30)-(x + 80, 40), BUILDING_COLOR
    LINE (x, 40)-(x, SCREEN_HALF_HEIGHT - 1), BUILDING_COLOR
    LINE (x + 80, 40)-(x + 80, SCREEN_HALF_HEIGHT - 1), BUILDING_COLOR
    LINE (x, SCREEN_HALF_HEIGHT - 1)-(x + 80, SCREEN_HALF_HEIGHT - 1), BUILDING_COLOR
    PAINT (x + 24, 100), BUILDING_COLOR

    FOR i = 1 TO 20
        PSET (2 + x + RND * 76, 40 + RND * 160), SUN_COLOR
    NEXT i

    LINE (x, 40)-(x + 40, 30), 0
    LINE (x + 40, 30)-(x + 80, 40), 0
    LINE (x + 38, 30)-(x + 38, SCREEN_HALF_HEIGHT - 1), 0
    LINE (x, 40)-(x, SCREEN_HALF_HEIGHT - 1), 0
    LINE (x + 80, 40)-(x + 80, SCREEN_HALF_HEIGHT - 1), 0

    FOR i = SCREEN_HALF_HEIGHT TO SCREEN_MAX_Y
        LINE (0, i)-(PANORAMA_WIDTH, i), 6, , _IIF(i AND 1, &B1010101010101010, &B0101010101010101)
        LINE (0, i)-(PANORAMA_WIDTH, i), 8, , _IIF(i AND 1, &B0101010101010101, &B1010101010101010)
    NEXT i

    _DEST oldDest

    Sky_Initialize = img
END FUNCTION


SUB Camera_Update (player AS Player)
    DIM ra AS SINGLE: ra = _D2R(player.camera.angle)
    player.camera.direction.x = COS(ra)
    player.camera.direction.y = -SIN(ra)
END SUB


SUB Input_Initialize
    $IF MACOSX AND VERSION < 4.1.0 THEN
        DECLARE LIBRARY
            SUB CGAssociateMouseAndMouseCursorPosition (BYVAL connected AS _BYTE)
        END DECLARE
    $END IF

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
END SUB


SUB Input_Update (player AS Player, map( ,) AS _UNSIGNED LONG)
    DIM mouseUsed AS _BYTE, m AS Vector2i

    WHILE _MOUSEINPUT
        $IF WINDOWS OR MACOSX THEN
            m.x = m.x + _MOUSEMOVEMENTX
            m.y = m.y + _MOUSEMOVEMENTY
        $END IF

        mouseUsed = _TRUE
    WEND

    IF mouseUsed THEN
        $IF WINDOWS OR MACOSX THEN
            IF m.x _ORELSE m.y THEN
                _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT
            END IF
        $ELSEIF LINUX THEN
            m.x = _MOUSEX - SCREEN_HALF_WIDTH
            m.y = _MOUSEY - SCREEN_HALF_HEIGHT

            IF m.x _ORELSE m.y THEN
                _MOUSEMOVE SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT
            END IF
        $END IF
    END IF

    IF _KEYDOWN(_KEY_LEFT) THEN
        m.x = m.x - PLAYER_MOVE_SPEED * 100
        mouseUsed = _TRUE
    END IF

    IF _KEYDOWN(_KEY_RIGHT) THEN
        m.x = m.x + PLAYER_MOVE_SPEED * 100
        mouseUsed = _TRUE
    END IF

    IF mouseUsed THEN
        player.camera.angle = (player.camera.angle + m.x * PLAYER_LOOK_SPEED)
        IF player.camera.angle >= 360! THEN player.camera.angle = player.camera.angle - 360!
        IF player.camera.angle < 0! THEN player.camera.angle = player.camera.angle + 360!
        Camera_Update player
    END IF

    DIM keyboardUsed AS _BYTE, position AS Vector2f

    IF _KEYDOWN(87) _ORELSE _KEYDOWN(119) _ORELSE _KEYDOWN(_KEY_UP) THEN
        position.x = player.position.x + player.camera.direction.x * PLAYER_MOVE_SPEED
        position.y = player.position.y + player.camera.direction.y * PLAYER_MOVE_SPEED
        keyboardUsed = _TRUE
    END IF

    IF _KEYDOWN(83) _ORELSE _KEYDOWN(115) _ORELSE _KEYDOWN(_KEY_DOWN) THEN
        position.x = player.position.x - player.camera.direction.x * PLAYER_MOVE_SPEED
        position.y = player.position.y - player.camera.direction.y * PLAYER_MOVE_SPEED
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
        m.x = _CAST(LONG, position.x)
        m.y = _CAST(LONG, position.y)

        IF m.x >= 0 _ANDALSO m.y >= 0 _ANDALSO m.x <= UBOUND(map, 1) _ANDALSO m.y <= UBOUND(map, 2) THEN
            IF map(m.x, _CAST(LONG, player.position.y)) = 0 THEN
                player.position.x = position.x
            END IF

            IF map(_CAST(LONG, player.position.x), m.y) = 0 THEN
                player.position.y = position.y
            END IF
        END IF
    END IF
END SUB


FUNCTION Automap_Initialize& (map( ,) AS _UNSIGNED LONG)
    DIM img AS LONG: img = _NEWIMAGE((UBOUND(map, 1) + 1) * AUTOMAP_SCALE, (UBOUND(map, 2) + 1) * AUTOMAP_SCALE, SCREEN_MODE)
    _CLEARCOLOR 0, img
    Automap_Initialize = img
END FUNCTION


SUB Automap_Draw (player AS Player, map( ,) AS _UNSIGNED LONG, automapImg AS LONG)
    DIM oldDest AS LONG: oldDest = _DEST
    _DEST automapImg

    CLS

    DIM AS Vector2i p, o
    DIM mapHeight AS LONG: mapHeight = UBOUND(map, 2)

    FOR p.y = 0 TO mapHeight
        FOR p.x = 0 TO UBOUND(map, 1)
            o.x = p.x * AUTOMAP_SCALE
            o.y = (mapHeight - p.y) * AUTOMAP_SCALE
            LINE (o.x + 1, o.y + 1)-(o.x + AUTOMAP_SCALE - 1, o.y + AUTOMAP_SCALE - 1), map(p.x, p.y), BF
            LINE (o.x, o.y)-(o.x + AUTOMAP_SCALE, o.y + AUTOMAP_SCALE), 7, B
        NEXT p.x
    NEXT p.y

    p.x = AUTOMAP_PLAYER_RADIUS + _CAST(LONG, player.position.x) * AUTOMAP_SCALE
    p.y = AUTOMAP_PLAYER_RADIUS + (mapHeight - _CAST(LONG, player.position.y)) * AUTOMAP_SCALE
    o.x = p.x + player.camera.direction.x * AUTOMAP_SCALE
    o.y = p.y - player.camera.direction.y * AUTOMAP_SCALE

    CIRCLE (p.x, p.y), AUTOMAP_PLAYER_RADIUS, AUTOMAP_PLAYER_COLOR
    LINE (p.x, p.y)-(o.x, o.y), AUTOMAP_PLAYER_CAMERA_COLOR

    _DEST oldDest

    _PUTIMAGE (0, 0), automapImg
END SUB


SUB Sky_Draw (player AS Player, environmentImg AS LONG)
    DIM AS Vector2i skyPos, skySize

    skySize.x = _WIDTH(environmentImg)
    skySize.y = _HEIGHT(environmentImg)

    skyPos.x = (player.camera.angle * skySize.x) \ 360

    IF skyPos.x + SCREEN_WIDTH > skySize.x THEN
        DIM partialWidth AS LONG: partialWidth = skySize.x - skyPos.x

        _PUTIMAGE (0, 0), environmentImg, , (skyPos.x, skyPos.y)-STEP(partialWidth - 1, SCREEN_MAX_Y), _SMOOTH
        _PUTIMAGE (partialWidth, 0), environmentImg, , (0, skyPos.y)-STEP(SCREEN_WIDTH - partialWidth - 1, SCREEN_MAX_Y), _SMOOTH
    ELSE
        _PUTIMAGE (0, 0), environmentImg, , (skyPos.x, skyPos.y)-STEP(SCREEN_MAX_X, SCREEN_MAX_Y), _SMOOTH
    END IF
END SUB


FUNCTION Time_GetHertz~&
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

    Time_GetHertz = finalFPS
END FUNCTION


SUB Game_RenderFrame (player AS Player, map( ,) AS _UNSIGNED LONG, environmentImg AS LONG, automapImg AS LONG)
    Sky_Draw player, environmentImg

    DIM rayAngle AS SINGLE
    rayAngle = player.camera.angle - PLAYER_HALF_FOV
    IF rayAngle < 0! THEN rayAngle = rayAngle + 360!

    DIM i AS LONG, wallColor AS _UNSIGNED LONG, wallHeight AS LONG
    DIM AS Vector2f rayPosition, rayDirection
    DIM rayAngleRadian AS SINGLE, mapPosition AS Vector2i, distance AS SINGLE

    FOR i = 0 TO SCREEN_MAX_X
        rayAngleRadian = _D2R(rayAngle)
        rayDirection.x = COS(rayAngleRadian) / RAYCAST_PRECISION
        rayDirection.y = -SIN(rayAngleRadian) / RAYCAST_PRECISION
        rayPosition = player.position

        DO
            rayPosition.x = rayPosition.x + rayDirection.x
            rayPosition.y = rayPosition.y + rayDirection.y
            mapPosition.x = _CAST(LONG, rayPosition.x)
            mapPosition.y = _CAST(LONG, rayPosition.y)

            IF mapPosition.x < 0 _ORELSE mapPosition.y < 0 _ORELSE mapPosition.x > UBOUND(map, 1) _ORELSE mapPosition.y > UBOUND(map, 2) THEN
                wallColor = MAP_DEFAULT_BOUNDARY_COLOR
                EXIT DO
            END IF

            wallColor = map(mapPosition.x, mapPosition.y)
        LOOP WHILE wallColor = 0

        IF wallColor THEN
            distance = SQR((player.position.x - rayPosition.x) ^ 2! + (player.position.y - rayPosition.y) ^ 2!) * COS(_D2R(player.camera.angle - rayAngle))
            wallHeight = SCREEN_HALF_HEIGHT / distance
            LINE (i, SCREEN_HALF_HEIGHT - wallHeight)-(i, SCREEN_HALF_HEIGHT + wallHeight), wallColor, BF
        END IF

        rayAngle = rayAngle + RAYCAST_INCREMENT_ANGLE
        IF rayAngle >= 360! THEN rayAngle = rayAngle - 360!
    NEXT i

    Automap_Draw player, map(), automapImg

    _PRINTSTRING (0, SCREEN_HEIGHT - _FONTHEIGHT), STR$(Time_GetHertz) + " FPS"
END SUB
