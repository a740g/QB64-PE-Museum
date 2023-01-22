$Resize:Off
Option _Explicit
'$dynamic
'$include:'RougeLikeTypes.bi'
'$include:'RougeLikeConst.bi'

'**********************************************************************************************
'   Untitled Rougelike Adventure written by Paul Martin aka justsomeguy
'**********************************************************************************************

'   Physics code ported from RandyGaul's Impulse Engine
'   https://github.com/RandyGaul/ImpulseEngine
'   http://RandyGaul.net
'**********************************************************************************************
'    Copyright (c) 2013 Randy Gaul http://RandyGaul.net

'    This software is provided 'as-is', without any express or implied
'    warranty. In no event will the authors be held liable for any damages
'    arising from the use of this software.

'    Permission is granted to anyone to use this software for any purpose,
'    including commercial applications, and to alter it and redistribute it
'    freely, subject to the following restrictions:
'      1. The origin of this software must not be misrepresented; you must not
'         claim that you wrote the original software. If you use this software
'         in a product, an acknowledgment in the product documentation would be
'         appreciated but is not required.
'      2. Altered source versions must be plainly marked as such, and must not be
'         misrepresented as being the original software.
'      3. This notice may not be removed or altered from any source distribution.
'
Dim Shared gameOptions As tGAMEOPTIONS
Dim Shared fpsCount As tFPS
Dim Shared timers(0) As tELAPSEDTIMER
Dim Shared tileFont(255) As tTILEFONT
Dim Shared sounds(0) As tSOUND
Dim Shared playList As tPLAYLIST
Dim Shared logfile As Long
Dim Shared landmark(0) As tLANDMARK
Dim Shared doors(0) As tDOOR


'**********************************************************************************************
'
'**********************************************************************************************
' 05-22-21 : Added Mouse PoseEdge and NegEdge, tidyied up the code
' 05-23-21 : Push Screen Init and FPS init to functions
' 05-23-21 : Auto Center FPS Counter
' 05-23-21 : Realized that you dont need to use  if you dont use () around the arguments
'            Purged 's from main program
' 05-26-21 : Purged 's from impulse.bas
' 05-27-21 : More purging of CALL's
' 01-07-22 : Refactor for Generic Use, Removed all CALL statements
' 01-12-22 : Integrate TMX and TSX files to make level building easier
' 01-13-22 : Optimize AABB for collision detection
' 01-17-22 : Reorganized code for easier navigation
' 01-23-22 : Refactor XML parsing (Still not happy with it.)
' 01-23-22 : Adding Waypoints to the map data
' 01-27-22 : Discovered and fixed a long term bug in the circle wireframe code
'            Added Mouse code that uses as hidden image to detect collisions with sensors
'            Laid ground work for A-star usage
' 01-31-22 : Tidy up code more. Pushed mainloop items out to the Subs and functions
'            Implemented camera movement FSM
'            Player is controllable with Mouse and A Star
' 02-01-22 : Rename objectmanager to bodyManager
'            Inserted some Perlin Noise Code
'            Reworked message handler and Added a Splash Screen
' 02-04-22 : Worked on Camera following and Character movement FSM
'            The FSM still needs work
'            Integrated Background Music for the menu
' 02-06-22 : Added in baked in lighting for the map.
'            Added FSM functioanlity for Music
'            Added Landmarks
' 02-11-22 : Now able traverse Levels.
' 02-14-22 : Added Rigid Body Functionality (SLOW!!!!)
' 04-19-22 : Added Game Options Right now only volume
'**********************************************************************************************
'TODO:
'
'**********************************************************************************************
'   ENTRY POINT
'**********************************************************************************************

main

'**********************************************************************************************
'   Main Loop
'**********************************************************************************************
Sub _______________MAIN_LOOP (): End Sub
Sub main

    '**********************************************************************************************
    '   Arrays
    '**********************************************************************************************

    Static world As tWORLD
    Static message(0) As tMESSAGE
    Static poly(0) As tPOLY
    Static entity(0) As tENTITY
    Static body(0) As tBODY
    Static joints(0) As tJOINT
    Static hits(0) As tHIT
    Static veh(0) As tVEHICLE
    Static camera As tCAMERA
    Static inputDevice As tINPUTDEVICE
    Static network As tNETWORK
    Static tileMap As tTILEMAP
    Static tile(0) As tTILE
    Static gamemap(0) As tTILE
    Static engine As tENGINE

    _Title "Untitled Rougelike Adventure"
    engine.logFileName = "Logfile.txt"
    engine.logFileNumber = 1
    logfile = engine.logFileNumber
    If _FileExists(_CWD$ + OSPathJoin$ + engine.logFileName) Then Kill _CWD$ + OSPathJoin$ + engine.logFileName
    Open _CWD$ + OSPathJoin$ + engine.logFileName For Output As engine.logFileNumber

    engine.currentMap = "Main_Menu.tmx"
    initScreen engine, 1024, 768, 32
    initFPS

    buildScene engine, world, entity(), gamemap(), poly(), body(), joints(), camera, tile(), tileMap, veh(), inputDevice, network, message()

    Do

        runScene engine, world, entity(), gamemap(), poly(), body(), joints(), hits(), tile(), tileMap, camera, veh(), inputDevice, network, message()
        handleNetwork body(), network
        handleTimers
        handleMusic playList, sounds()
        handleCamera camera
        handleEntitys entity(), body(), tileMap
        handleMessages tile(), message()
        handleInputDevice poly(), body(), inputDevice, camera
        handleFPS
        impulseStep engine, world, poly(), body(), joints(), hits(), cDT, cITERATIONS

        _Display
    Loop Until _KeyHit = 27

    shutdown tile(), network

End Sub
'**********************************************************************************************
'   Scene Build
'**********************************************************************************************
Sub _______________BUILD_SCENE (): End Sub

Sub buildScene (engine As tENGINE, world As tWORLD, entity() As tENTITY, gamemap() As tTILE, poly() As tPOLY, body() As tBODY, j() As tJOINT, camera As tCAMERA, tile() As tTILE, tilemap As tTILEMAP, v() As tVEHICLE, idevice As tINPUTDEVICE, net As tNETWORK, message() As tMESSAGE)

    _MouseHide
    gameOptions.musicVolume = .10
    ReDim body(0) As tBODY
    ReDim poly(0) As tPOLY
    ReDim j(0) As tJOINT
    ReDim v(0) As tVEHICLE
    ReDim message(0) As tMESSAGE
    ReDim context(0) As tSTRINGTUPLE

    freeAllTiles tile()

    '********************************************************
    '   Setup World
    '********************************************************
    v(0).vehicleName = "Nothing" ' Clear Warning
    tilemap.tilescale = 1
    engine.displayClearColor = _RGB32(39, 67, 55)
    '********************************************************
    '   Setup Network
    '********************************************************
    net.address = "localhost"
    net.port = 1234
    net.protocol = "TCP/IP"
    net.SorC = cNET_NONE
    '********************************************************
    '   Load Map
    '********************************************************
    XMLparse _CWD$ + OSPathJoin$ + "Assets" + OSPathJoin$, engine.currentMap, context()
    XMLapplyAttributes engine, world, gamemap(), entity(), poly(), body(), camera, tile(), tilemap, _CWD$ + OSPathJoin$ + "Assets" + OSPathJoin$, context()
    initInputDevice poly(), body(), idevice, tile(idToTile(tile(), 516 + 1)).t

    Dim As Long playerId
    playerId = entityManagerID(body(), "PLAYER")
    If playerId < 0 Then
        Print "Player does not exist!": waitkey: End
    End If

    entity(playerId).parameters.movementSpeed = .15
    entity(playerId).parameters.drunkiness = 1

    FSMChangeState engine.gameMode, cFSM_GAMEMODE_SPLASH

End Sub

'**********************************************************************************************
'   Scene Handling
'**********************************************************************************************
Sub _______________RUN_SCENE (): End Sub
Sub runScene (engine As tENGINE, world As tWORLD, entity() As tENTITY, gamemap() As tTILE, poly() As tPOLY, body() As tBODY, joints() As tJOINT, hits() As tHIT, tile() As tTILE, tilemap As tTILEMAP, camera As tCAMERA, veh() As tVEHICLE, iDevice As tINPUTDEVICE, net As tNETWORK, message() As tMESSAGE)
    Dim As Long backgroundMusic, music1, music2, door
    Dim As tVECTOR2d tempVec
    backgroundMusic = soundManagerIDClass(sounds(), "BACKGROUND")
    music1 = soundManagerIDClass(sounds(), "MUSIC_1")
    music2 = soundManagerIDClass(sounds(), "MUSIC_2")
    Select Case engine.gameMode.currentState
        Case cFSM_GAMEMODE_IDLE:
        Case cFSM_GAMEMODE_SPLASH:
            Dim As tVECTOR2d position
            vector2dSet position, 100, 100
            addMessage tile(), tilemap, message(), "Untitled RougeLike_    Adventure_  by Paul Martin _ aka  JUSTSOMEGUY", 4, position, 3.0
            playMusic playList, sounds(), "BACKGROUND"
            FSMChangeState engine.gameMode, cFSM_GAMEMODE_START
        Case cFSM_GAMEMODE_START:
            engine.gameMode.timerState.duration = 9
            clearScreen engine
            FSMChangeStateOnTimer engine.gameMode, cFSM_GAMEMODE_MAINMENU
            iDevice.mouseMode = 0
        Case cFSM_GAMEMODE_MAINMENU:
            iDevice.mouseMode = 1
            Dim As Long playerId, mouseId
            Dim As tVECTOR2d mpos

            playerId = entityManagerID(body(), "PLAYER")
            If playerId < 0 Then
                Print "Object does not exist!": waitkey: End
            End If

            mouseId = bodyManagerID(body(), "_mouse")

            ' Camera Zoom -- Mouse Scroll Wheel
            camera.zoom = camera.zoom + (iDevice.wCount * .1)
            If camera.zoom < 1.5 Then camera.zoom = 1.5

            vector2dSet mpos, iDevice.xy.x, iDevice.xy.y
            If iDevice.b2PosEdge Then
                moveCamera camera, body(mouseId).fzx.position
            End If

            door = handleDoors(entity(), body(), hits(), doors())
            If Not door Then
                stopMusic playList
                Dim tempDoor As tDOOR: tempDoor = doors(door): 'make a copy of the activated Door
                ReDim context(0) As tSTRINGTUPLE
                Erase body
                ReDim body(0) As tBODY
                Erase poly
                ReDim poly(0) As tPOLY
                Erase joints
                ReDim joints(0) As tJOINT
                Erase veh
                ReDim veh(0) As tVEHICLE
                Erase gamemap
                ReDim gamemap(0) As tTILE
                Erase tile
                ReDim tile(0) As tTILE
                Erase doors
                ReDim doors(0) As tDOOR
                Erase hits
                ReDim hits(0) As tHIT
                Erase entity
                ReDim entity(0) As tENTITY
                freeAllTiles tile()
                removeAllMusic playList, sounds()
                engine.currentMap = trim$(tempDoor.map)
                XMLparse _CWD$ + "/Assets/", trim$(engine.currentMap), context()
                XMLapplyAttributes engine, world, gamemap(), entity(), poly(), body(), camera, tile(), tilemap, _CWD$ + "/Assets/", context()
                initInputDevice poly(), body(), iDevice, tile(idToTile(tile(), 516 + 1)).t
                playerId = entityManagerID(body(), "PLAYER")
                If playerId < 0 Then
                    Print "Player does not exist!": waitkey: End
                End If
                entity(playerId).parameters.movementSpeed = .15
                entity(playerId).parameters.drunkiness = 1

                findLandmarkPositionHash landmark(), tempDoor.landmarkHash, tempVec
                setBody poly(), body(), cPARAMETER_POSITION, entity(playerId).objectID, tempVec.x, tempVec.y
                moveCamera camera, body(entity(playerId).objectID).fzx.position

                Exit Sub
            End If
            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senMUSIC_1")) Then
                playMusic playList, sounds(), "MUSIC_1"
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senMUSIC_2")) Then
                playMusic playList, sounds(), "MUSIC_2"
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senMUSIC_3")) Then
                playMusic playList, sounds(), "BACKGROUND"
            End If


            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senQUIT_N")) Then
                findLandmarkPosition landmark(), "lmNEVERMIND", tempVec
                setBody poly(), body(), cPARAMETER_POSITION, entity(playerId).objectID, tempVec.x, tempVec.y
                moveCamera camera, body(entity(playerId).objectID).fzx.position
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senQUIT_Y")) Then
                System
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senCREDITS")) Then
                moveCamera camera, body(entity(playerId).objectID).fzx.position
                FSMChangeState engine.gameMode, cFSM_GAMEMODE_CREDITSINIT
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senQUIT")) Then
                stopMusic playList
                findLandmarkPosition landmark(), "lmQUIT", tempVec
                setBody poly(), body(), cPARAMETER_POSITION, entity(playerId).objectID, tempVec.x, tempVec.y
                moveCamera camera, body(entity(playerId).objectID).fzx.position
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senOPTIONS")) Then
                findLandmarkPosition landmark(), "lmOptions", tempVec
                setBody poly(), body(), cPARAMETER_POSITION, entity(playerId).objectID, tempVec.x, tempVec.y
                moveCamera camera, body(entity(playerId).objectID).fzx.position
            End If

            If Not isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senReturnToMainMenu")) Then
                findLandmarkPosition landmark(), "lmNEVERMIND", tempVec
                setBody poly(), body(), cPARAMETER_POSITION, entity(playerId).objectID, tempVec.x, tempVec.y
                moveCamera camera, body(entity(playerId).objectID).fzx.position
            End If



            If 0 Then ' disabled for now
                If _KeyDown(32) Or _KeyDown(87) Or _KeyDown(119) Or _KeyDown(18432) Then
                    body(entity(playerId).objectID).fzx.force.y = -(entity(playerId).parameters.maxForce.y / 100)
                End If

                If _KeyDown(20480) Then
                    body(entity(playerId).objectID).fzx.force.y = (entity(playerId).parameters.maxForce.y / 100)
                End If

                If _KeyDown(65) Or _KeyDown(97) Or _KeyDown(19200) Then
                    body(entity(playerId).objectID).fzx.force.x = -(entity(playerId).parameters.maxForce.x)
                End If

                If _KeyDown(68) Or _KeyDown(100) Or _KeyDown(19712) Then
                    body(entity(playerId).objectID).fzx.force.x = entity(playerId).parameters.maxForce.x
                End If

                body(entity(playerId).objectID).fzx.velocity.x = impulseClamp(-1000, 1000, body(entity(playerId).objectID).fzx.velocity.x)
                body(entity(playerId).objectID).fzx.velocity.y = impulseClamp(-1000, 1000, body(entity(playerId).objectID).fzx.velocity.y)
            End If

            If iDevice.b1PosEdge Then
                'isOnSensor returns the body ID of the sensor
                Dim As Long volumeControlID
                volumeControlID = entityManagerID(body(), "enVOLCONTROL")
                Select Case isOnSensor(engine, mpos)
                    Case bodyManagerID(body(), "senVolumeUp"):
                        If gameOptions.musicVolume <= 1.0 Then
                            gameOptions.musicVolume = gameOptions.musicVolume + 0.1
                            body(entity(volumeControlID).objectID).fzx.position.x = body(entity(volumeControlID).objectID).fzx.position.x + tilemap.tileWidth
                        End If
                    Case bodyManagerID(body(), "senVolumeDown"):
                        If gameOptions.musicVolume >= 0.0 Then
                            gameOptions.musicVolume = gameOptions.musicVolume - 0.1
                            body(entity(volumeControlID).objectID).fzx.position.x = body(entity(volumeControlID).objectID).fzx.position.x - tilemap.tileWidth
                        End If
                    Case Else
                        moveEntity entity(playerId), body(), iDevice.mouse, gamemap(), tilemap
                        FSMChangeState camera.fsm, cFSM_CAMERA_IDLE
                End Select
            End If

            ' If entity has stopped moving, and camera was sitting still then move the camera to the player
            If entity(playerId).fsmPrimary.currentState = cFSM_ENTITY_IDLE And entity(playerId).fsmPrimary.previousState = cFSM_ENTITY_MOVE And camera.fsm.previousState <> cFSM_CAMERA_MOVING Then
                If isBodyTouchingBody(hits(), entity(playerId).objectID, bodyManagerID(body(), "senCENTER_CAMERA")) Then
                    moveCamera camera, body(entity(playerId).objectID).fzx.position
                Else
                    findLandmarkPosition landmark(), "lmCAMERA_CENTER", tempVec
                    moveCamera camera, tempVec
                End If
            End If
            renderBodies engine, poly(), body(), joints(), hits(), camera


        Case cFSM_GAMEMODE_CREDITSINIT:
            clearScreen engine
            vector2dSet position, 40, 100
            addMessage tile(), tilemap, message(), "Untitled RougeLike Adventure__by Paul Martin aka JUSTSOMEGUY_Written Using QB64___Graphics by Kenney_www.kenney.nl___Sound by Eric Matyas_soundimage.org", 4, position, 2.0
            FSMChangeState engine.gameMode, cFSM_GAMEMODE_CREDITS
        Case cFSM_GAMEMODE_CREDITS:
            engine.gameMode.timerState.duration = 9
            clearScreen engine
            FSMChangeStateOnTimer engine.gameMode, cFSM_GAMEMODE_MAINMENU
            iDevice.mouseMode = 0
            findLandmarkPosition landmark(), "lmNEVERMIND", tempVec
            setBody poly(), body(), cPARAMETER_POSITION, entity(playerId).objectID, tempVec.x, tempVec.y
    End Select
End Sub

'**********************************************************************************************
'   Entity Management Subs
'**********************************************************************************************
Sub _______________ENTITY_MANAGEMENT (): End Sub

Function entityCreate (entity() As tENTITY, p() As tPOLY, body() As tBODY, tilemap As tTILEMAP, entityName As String, position As tVECTOR2d)
    Dim As Long index, tempid
    index = UBound(entity)
    tempid = createBoxBodyEx(p(), body(), entityName, tilemap.tileWidth / 2.1, tilemap.tileHeight / 2.1)
    entity(index).objectID = tempid
    setBody p(), body(), cPARAMETER_POSITION, tempid, position.x - tilemap.tileWidth, position.y - tilemap.tileHeight
    setBody p(), body(), cPARAMETER_NOPHYSICS, tempid, 0, 0
    setBody p(), body(), cPARAMETER_ENTITYID, tempid, index, 0
    ReDim _Preserve entity(index + 1) As tENTITY
    entityCreate = index
End Function

Function entityManagerID (body() As tBODY, entityName As String)
    Dim As Long id
    id = bodyManagerID(body(), entityName)
    If id >= 0 Then
        entityManagerID = body(id).entityID
    Else
        entityManagerID = -1
    End If
End Function

'**********************************************************************************************
'   Vector Math Functions
'**********************************************************************************************
Sub _______________VECTOR_FUNCTIONS (): End Sub

Sub vector2dSet (v As tVECTOR2d, x As _Float, y As _Float)
    v.x = x
    v.y = y
End Sub

Sub vector2dSetVector (o As tVECTOR2d, v As tVECTOR2d)
    o.x = v.x
    o.y = v.y
End Sub

Sub vector2dNeg (v As tVECTOR2d)
    v.x = -v.x
    v.y = -v.y
End Sub

Sub vector2dNegND (o As tVECTOR2d, v As tVECTOR2d)
    o.x = -v.x
    o.y = -v.y
End Sub

Sub vector2dMultiplyScalar (v As tVECTOR2d, s As _Float)
    v.x = v.x * s
    v.y = v.y * s
End Sub

Sub vector2dMultiplyScalarND (o As tVECTOR2d, v As tVECTOR2d, s As _Float)
    o.x = v.x * s
    o.y = v.y * s
End Sub

Sub vector2dDivideScalar (v As tVECTOR2d, s As _Float)
    v.x = v.x / s
    v.y = v.y / s
End Sub

Sub vector2dDivideScalarND (o As tVECTOR2d, v As tVECTOR2d, s As _Float)
    o.x = v.x / s
    o.y = v.y / s
End Sub

Sub vector2dAddScalar (v As tVECTOR2d, s As _Float)
    v.x = v.x + s
    v.y = v.y + s
End Sub

Sub vector2dAddScalarND (o As tVECTOR2d, v As tVECTOR2d, s As _Float)
    o.x = v.x + s
    o.y = v.y + s
End Sub

Sub vector2dMultiplyVector (v As tVECTOR2d, m As tVECTOR2d)
    v.x = v.x * m.x
    v.y = v.y * m.y
End Sub

Sub vector2dMultiplyVectorND (o As tVECTOR2d, v As tVECTOR2d, m As tVECTOR2d)
    o.x = v.x * m.x
    o.y = v.y * m.y
End Sub

Sub vector2dDivideVector (v As tVECTOR2d, m As tVECTOR2d)
    v.x = v.x / m.x
    v.y = v.y / m.y
End Sub

Sub vector2dDivideVectorND (o As tVECTOR2d, v As tVECTOR2d, m As tVECTOR2d)
    o.x = v.x / m.x
    o.y = v.y / m.y
End Sub

Sub vector2dAddVector (v As tVECTOR2d, m As tVECTOR2d)
    v.x = v.x + m.x
    v.y = v.y + m.y
End Sub

Sub vector2dAddVectorND (o As tVECTOR2d, v As tVECTOR2d, m As tVECTOR2d)
    o.x = v.x + m.x
    o.y = v.y + m.y
End Sub

Sub vector2dAddVectorScalar (v As tVECTOR2d, m As tVECTOR2d, s As _Float)
    v.x = v.x + m.x * s
    v.y = v.y + m.y * s
End Sub

Sub vector2dAddVectorScalarND (o As tVECTOR2d, v As tVECTOR2d, m As tVECTOR2d, s As _Float)
    o.x = v.x + m.x * s
    o.y = v.y + m.y * s
End Sub

Sub vector2dSubVector (v As tVECTOR2d, m As tVECTOR2d)
    v.x = v.x - m.x
    v.y = v.y - m.y
End Sub

Sub vector2dSubVectorND (o As tVECTOR2d, v As tVECTOR2d, m As tVECTOR2d)
    o.x = v.x - m.x
    o.y = v.y - m.y
End Sub

Sub vector2dSwap (v1 As tVECTOR2d, v2 As tVECTOR2d)
    Swap v1, v2
End Sub

Function vector2dLengthSq (v As tVECTOR2d)
    vector2dLengthSq = v.x * v.x + v.y * v.y
End Function

Function vector2dLength (v As tVECTOR2d)
    vector2dLength = Sqr(vector2dLengthSq(v))
End Function

Sub vector2dRotate (v As tVECTOR2d, radians As _Float)
    Dim c, s, xp, yp As _Float
    c = Cos(radians)
    s = Sin(radians)
    xp = v.x * c - v.y * s
    yp = v.x * s + v.y * c
    v.x = xp
    v.y = yp
End Sub

Sub vector2dNormalize (v As tVECTOR2d)
    Dim lenSQ, invLen As _Float
    lenSQ = vector2dLengthSq(v)
    If lenSQ > cEPSILON_SQ Then
        invLen = 1.0 / Sqr(lenSQ)
        v.x = v.x * invLen
        v.y = v.y * invLen
    End If
End Sub

Sub vector2dMin (a As tVECTOR2d, b As tVECTOR2d, o As tVECTOR2d)
    o.x = scalarMin(a.x, b.x)
    o.y = scalarMin(a.y, b.y)
End Sub

Sub vector2dMax (a As tVECTOR2d, b As tVECTOR2d, o As tVECTOR2d)
    o.x = scalarMax(a.x, b.x)
    o.y = scalarMax(a.y, b.y)
End Sub

Function vector2dDot (a As tVECTOR2d, b As tVECTOR2d)
    vector2dDot = a.x * b.x + a.y * b.y
End Function

Function vector2dSqDist (a As tVECTOR2d, b As tVECTOR2d)
    Dim dx, dy As _Float
    dx = b.x - a.x
    dy = b.y - a.y
    vector2dSqDist = dx * dx + dy * dy
End Function

Function vector2dDistance (a As tVECTOR2d, b As tVECTOR2d)
    vector2dDistance = Sqr(vector2dSqDist(a, b))
End Function

Function vector2dCross (a As tVECTOR2d, b As tVECTOR2d)
    vector2dCross = a.x * b.y - a.y * b.x
End Function

Sub vector2dCrossScalar (o As tVECTOR2d, v As tVECTOR2d, a As _Float)
    o.x = v.y * -a
    o.y = v.x * a
End Sub

Function vector2dArea (a As tVECTOR2d, b As tVECTOR2d, c As tVECTOR2d)
    vector2dArea = (((b.x - a.x) * (c.y - a.y)) - ((c.x - a.x) * (b.y - a.y)))
End Function

Function vector2dLeft (a As tVECTOR2d, b As tVECTOR2d, c As tVECTOR2d)
    vector2dLeft = vector2dArea(a, b, c) > 0
End Function

Function vector2dLeftOn (a As tVECTOR2d, b As tVECTOR2d, c As tVECTOR2d)
    vector2dLeftOn = vector2dArea(a, b, c) >= 0
End Function

Function vector2dRight (a As tVECTOR2d, b As tVECTOR2d, c As tVECTOR2d)
    vector2dRight = vector2dArea(a, b, c) < 0
End Function

Function vector2dRightOn (a As tVECTOR2d, b As tVECTOR2d, c As tVECTOR2d)
    vector2dRightOn = vector2dArea(a, b, c) <= 0
End Function

Function vector2dCollinear (a As tVECTOR2d, b As tVECTOR2d, c As tVECTOR2d, thresholdAngle As _Float)
    If (thresholdAngle = 0) Then
        vector2dCollinear = (vector2dArea(a, b, c) = 0)
    Else
        Dim ab As tVECTOR2d
        Dim bc As tVECTOR2d
        Dim dot As _Float
        Dim magA As _Float
        Dim magB As _Float
        Dim angle As _Float

        ab.x = b.x - a.x
        ab.y = b.y - a.y
        bc.x = c.x - b.x
        bc.y = c.y - b.y

        dot = ab.x * bc.x + ab.y * bc.y
        magA = Sqr(ab.x * ab.x + ab.y * ab.y)
        magB = Sqr(bc.x * bc.x + bc.y * bc.y)
        angle = _Acos(dot / (magA * magB))
        vector2dCollinear = angle < thresholdAngle
    End If
End Function

Sub vector2dGetSupport (p() As tPOLY, body() As tBODY, index As Long, dir As tVECTOR2d, bestVertex As tVECTOR2d)
    Dim bestProjection As _Float
    Dim v As tVECTOR2d
    Dim projection As _Float
    Dim i As Long
    bestVertex.x = -9999999
    bestVertex.y = -9999999
    bestProjection = -9999999

    For i = 0 To body(index).pa.count
        v = p(i + body(index).pa.start).vert
        projection = vector2dDot(v, dir)
        If projection > bestProjection Then
            bestVertex = v
            bestProjection = projection
        End If
    Next
End Sub

Sub vector2dLERP (curr As tVECTOR2d, start As tVECTOR2d, target As tVECTOR2d, inc As _Float)
    curr.x = scalarLERP(start.x, target.x, inc)
    curr.y = scalarLERP(start.y, target.y, inc)
End Sub

Sub vector2dLERPSmooth (curr As tVECTOR2d, start As tVECTOR2d, target As tVECTOR2d, inc As _Float)
    curr.x = scalarLERPSmooth(start.x, target.x, inc)
    curr.y = scalarLERPSmooth(start.y, target.y, inc)
End Sub

Sub vector2dLERPSmoother (curr As tVECTOR2d, start As tVECTOR2d, target As tVECTOR2d, inc As _Float)
    curr.x = scalarLERPSmoother(start.x, target.x, inc)
    curr.y = scalarLERPSmoother(start.y, target.y, inc)
End Sub

Sub vector2dOrbitVector (o As tVECTOR2d, position As tVECTOR2d, dist As _Float, angle As _Float)
    o.x = Cos(angle) * dist + position.x
    o.y = Sin(angle) * dist + position.y
End Sub

Function vector2dRoughEqual (a As tVECTOR2d, b As tVECTOR2d, tolerance As _Float)
    vector2dRoughEqual = scalarRoughEqual(a.x, b.x, tolerance) And scalarRoughEqual(a.y, b.y, tolerance)
End Function

'**********************************************************************************************
'   Matrix Math Functions
'**********************************************************************************************

Sub _______________MATRIX_FUNCTIONS (): End Sub
Sub matrix2x2SetRadians (m As tMATRIX2d, radians As _Float)
    Dim c As _Float
    Dim s As _Float
    c = Cos(radians)
    s = Sin(radians)
    m.m00 = c
    m.m01 = -s
    m.m10 = s
    m.m11 = c
End Sub

Sub matrix2x2SetScalar (m As tMATRIX2d, a As _Float, b As _Float, c As _Float, d As _Float)
    m.m00 = a
    m.m01 = b
    m.m10 = c
    m.m11 = d
End Sub

Sub matrix2x2Abs (m As tMATRIX2d, o As tMATRIX2d)
    o.m00 = Abs(m.m00)
    o.m01 = Abs(m.m01)
    o.m10 = Abs(m.m10)
    o.m11 = Abs(m.m11)
End Sub

Sub matrix2x2GetAxisX (m As tMATRIX2d, o As tVECTOR2d)
    o.x = m.m00
    o.y = m.m10
End Sub

Sub matrix2x2GetAxisY (m As tMATRIX2d, o As tVECTOR2d)
    o.x = m.m01
    o.y = m.m11
End Sub

Sub matrix2x2TransposeI (m As tMATRIX2d)
    Swap m.m01, m.m10
End Sub

Sub matrix2x2Transpose (m As tMATRIX2d, o As tMATRIX2d)
    Dim tm As tMATRIX2d
    tm.m00 = m.m00
    tm.m01 = m.m10
    tm.m10 = m.m01
    tm.m11 = m.m11
    o = tm
End Sub

Sub matrix2x2Invert (m As tMATRIX2d, o As tMATRIX2d)
    Dim a, b, c, d, det As _Float
    Dim tm As tMATRIX2d

    a = m.m00: b = m.m01: c = m.m10: d = m.m11
    det = a * d - b * c
    If det = 0 Then Exit Sub

    det = 1 / det
    tm.m00 = det * d: tm.m01 = -det * b
    tm.m10 = -det * c: tm.m11 = det * a
    o = tm
End Sub

Sub matrix2x2MultiplyVector (m As tMATRIX2d, v As tVECTOR2d, o As tVECTOR2d)
    Dim t As tVECTOR2d
    t.x = m.m00 * v.x + m.m01 * v.y
    t.y = m.m10 * v.x + m.m11 * v.y
    o = t
End Sub

Sub matrix2x2AddMatrix (m As tMATRIX2d, x As tMATRIX2d, o As tMATRIX2d)
    o.m00 = m.m00 + x.m00
    o.m01 = m.m01 + x.m01
    o.m10 = m.m10 + x.m10
    o.m11 = m.m11 + x.m11
End Sub

Sub matrix2x2MultiplyMatrix (m As tMATRIX2d, x As tMATRIX2d, o As tMATRIX2d)
    o.m00 = m.m00 * x.m00 + m.m01 * x.m10
    o.m01 = m.m00 * x.m01 + m.m01 * x.m11
    o.m10 = m.m10 * x.m00 + m.m11 * x.m10
    o.m11 = m.m10 * x.m01 + m.m11 * x.m11
End Sub

'**********************************************************************************************
'   Impulse Math
'**********************************************************************************************
Sub _______________IMPULSE_MATH (): End Sub

Function impulseEqual (a As _Float, b As _Float)
    impulseEqual = Abs(a - b) <= cEPSILON
End Function

Function impulseClamp## (min As _Float, max As _Float, a As _Float)
    If a < min Then
        impulseClamp## = min
    Else If a > max Then
            impulseClamp## = max
        Else
            impulseClamp## = a
        End If
    End If
End Function

Function impulseRound## (a As _Float)
    impulseRound = Int(a + 0.5)
End Function

Function impulseRandomFloat## (min As _Float, max As _Float)
    impulseRandomFloat = ((max - min) * Rnd + min)
End Function

Function impulseRandomInteger (min As Long, max As Long)
    impulseRandomInteger = Int((max - min) * Rnd + min)
End Function

Function impulseGT (a As _Float, b As _Float)
    impulseGT = (a >= b * cBIAS_RELATIVE + a * cBIAS_ABSOLUTE)
End Function

'**********************************************************************************************
'   Misc
'**********************************************************************************************

Sub _______________MISC_HELPER_FUNCTIONS (): End Sub

Sub polygonMakeCCW (obj As tTRIANGLE)
    If vector2dLeft(obj.a, obj.b, obj.c) = 0 Then
        Swap obj.a, obj.c
    End If
End Sub

Function polygonIsReflex (t As tTRIANGLE)
    polygonIsReflex = vector2dRight(t.a, t.b, t.c)
End Function

Sub polygonSetOrient (b As tBODY, radians As _Float)
    matrix2x2SetRadians b.shape.u, radians
End Sub

Sub polygonInvertNormals (p() As tPOLY, b() As tBODY, index As Long)
    Dim As Long i
    For i = 0 To b(index).pa.count
        vector2dNeg p(b(index).pa.start + i).norm
    Next
End Sub

'**********************************************************************************************
'   Scalar helper functions
'**********************************************************************************************
Sub _______________SCALAR_HELPER_FUNCTIONS (): End Sub

Function scalarMin (a As _Float, b As _Float)
    If a < b Then
        scalarMin = a
    Else
        scalarMin = b
    End If
End Function

Function scalarMax (a As _Float, b As _Float)
    If a > b Then
        scalarMax = a
    Else
        scalarMax = b
    End If
End Function

Function scalarMap## (x As _Float, in_min As _Float, in_max As _Float, out_min As _Float, out_max As _Float)
    scalarMap## = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
End Function

Function scalarLERP## (current As _Float, target As _Float, t As _Float)
    t = impulseClamp##(0, 1, t)
    scalarLERP## = current + (target - current) * t
End Function

Function scalarLERPSmooth## (current As _Float, target As _Float, t As _Float)
    t = impulseClamp##(0, 1, t)
    scalarLERPSmooth## = scalarLERP##(current, target, t * t * (3.0 - 2.0 * t))
End Function

Function scalarLERPSmoother## (current As _Float, target As _Float, t As _Float)
    t = impulseClamp##(0, 1, t)
    scalarLERPSmoother## = scalarLERP##(current, target, t * t * t * (t * (t * 6.0 - 15.0) + 10.0))
End Function

Function scalarLERPProgress## (startTime As _Float, endTime As _Float)
    scalarLERPProgress## = impulseClamp(0, 1, (Timer(.001) - startTime) / (endTime - startTime))
End Function

Function scalarRoughEqual (a As _Float, b As _Float, tolerance As _Float)
    scalarRoughEqual = Abs(a - b) <= tolerance
End Function


'**********************************************************************************************
'   Procedural Generation Helper Functions
'**********************************************************************************************
Sub _______________PROC_GEN_HELPER_FUNCTIONS (): End Sub

Function perlinInterpolate## (a0 As _Float, a1 As _Float, w As _Float)
    perlinInterpolate## = scalarLERPSmoother##(a0, a1, w)
End Function

' Create random direction vector
Sub perlinRandomGradient (seed As _Float, ix As Integer, iy As Integer, o As tVECTOR2d)
    ' Random float. No precomputed gradients mean this works for any number of grid coordinates
    Dim As _Float prandom
    prandom = seed * Sin(ix * 21942.0 + iy * 171324.0 + 8912.0) * Cos(ix * 23157.0 * iy * 217832.0 + 9758.0)
    o.x = Cos(prandom)
    o.y = Sin(prandom)
End Sub

' Computes the dot product of the distance and gradient vectors.
Function perlinDotGridGradient## (seed As _Float, ix As Integer, iy As Integer, x As _Float, y As _Float)
    Dim As tVECTOR2d gradient
    Dim As _Float dx, dy
    ' Get gradient from integer coordinates
    perlinRandomGradient seed, ix, iy, gradient
    ' Compute the distance vector
    dx = x - ix
    dy = y - iy
    ' Compute the dot-product
    perlinDotGridGradient## = dx * gradient.x + dy * gradient.y
End Function

' Compute Perlin noise at coordinates x, y
Function perlin## (x As _Float, y As _Float, seed As _Float)
    ' Determine grid cell coordinates
    Dim As Integer x0, x1, y0, y1
    Dim As _Float sx, sy, n0, n1, ix0, ix1
    x0 = Int(x)
    x1 = x0 + 1
    y0 = Int(y)
    y1 = y0 + 1

    ' Determine interpolation weights
    ' Could also use higher order polynomial/s-curve here
    sx = x - x0
    sy = y - y0

    ' Interpolate between grid point gradients
    n0 = perlinDotGridGradient##(seed, x0, y0, x, y)
    n1 = perlinDotGridGradient##(seed, x1, y0, x, y)
    ix0 = perlinInterpolate##(n0, n1, sx)

    n0 = perlinDotGridGradient##(seed, x0, y1, x, y)
    n1 = perlinDotGridGradient##(seed, x1, y1, x, y)
    ix1 = perlinInterpolate##(n0, n1, sx)

    perlin## = perlinInterpolate##(ix0, ix1, sy)
End Function

'**********************************************************************************************
'   Line Segment Helper Functions
'**********************************************************************************************
Sub _______________LINE_SEG_HELPER_FUNCTIONS (): End Sub

Sub lineIntersection (l1 As tLINE2d, l2 As tLINE2d, o As tVECTOR2d)
    Dim a1, b1, c1, a2, b2, c2, det As _Float
    o.x = 0
    o.y = 0
    a1 = l1.b.y - l1.a.y
    b1 = l1.a.x - l1.b.x
    c1 = a1 * l1.a.x + b1 * l1.a.y
    a2 = l2.b.y - l2.a.y
    b2 = l2.a.x - l2.b.x
    c2 = a2 * l2.a.x + b2 * l2.a.y
    det = a1 * b2 - a2 * b1

    If Int(det * cPRECISION) <> 0 Then
        o.x = (b2 * c1 - b1 * c2) / det
        o.y = (a1 * c2 - a2 * c1) / det
    End If
End Sub

Function lineSegmentsIntersect (l1 As tLINE2d, l2 As tLINE2d)
    Dim dx, dy, da, db, s, t As _Float
    dx = l1.b.x - l1.a.x
    dy = l1.b.y - l1.a.y
    da = l2.b.x - l2.a.x
    db = l2.b.y - l2.a.y
    If da * dy - db * dx = 0 Then
        lineSegmentsIntersect = 0
    Else
        s = (dx * (l2.a.y - l1.a.y) + dy * (l1.a.x - l2.a.x)) / (da * dy - db * dx)
        t = (da * (l1.a.y - l2.a.y) + db * (l2.a.x - l1.a.x)) / (db * dx - da * dy)
        lineSegmentsIntersect = (s >= 0 And s <= 1 And t >= 0 And t <= 1)
    End If
End Function

'**********************************************************************************************
'   AABB helper functions
'**********************************************************************************************
Sub _______________AABB_HELPER_FUNCTIONS (): End Sub

Function AABBOverlap (Ax As _Float, Ay As _Float, Aw As _Float, Ah As _Float, Bx As _Float, By As _Float, Bw As _Float, Bh As _Float)
    AABBOverlap = Ax < Bx + Bw And Ax + Aw > Bx And Ay < By + Bh And Ay + Ah > By
End Function

Function AABBOverlapVector (A As tVECTOR2d, Aw As _Float, Ah As _Float, B As tVECTOR2d, Bw As _Float, Bh As _Float)
    AABBOverlapVector = AABBOverlap(A.x, A.y, Aw, Ah, B.x, B.y, Bw, Bh)
End Function

Function AABBOverlapObjects (body() As tBODY, a As Long, b As Long)
    Dim As tVECTOR2d am, bm, mam, mbm
    am.x = scalarMax(body(a).shape.maxDimension.x, body(a).shape.maxDimension.y) / 2
    am.y = scalarMax(body(a).shape.maxDimension.x, body(a).shape.maxDimension.y) / 2

    bm.x = scalarMax(body(b).shape.maxDimension.x, body(b).shape.maxDimension.y) / 2
    bm.y = scalarMax(body(b).shape.maxDimension.x, body(b).shape.maxDimension.y) / 2

    mam = am
    mbm = bm
    vector2dSubVectorND am, body(a).fzx.position, am
    vector2dSubVectorND bm, body(b).fzx.position, bm

    AABBOverlapObjects = AABBOverlap(am.x, am.y, mam.x * 2, mam.y * 2, bm.x, bm.y, mbm.x * 2, mbm.y * 2)
End Function


'**********************************************************************************************
'   Body Initilization
'**********************************************************************************************
Sub _______________BODY_INIT_FUNCTIONS (): End Sub

Sub circleInitialize (b() As tBODY, index As Long)
    circleComputeMass b(), index, cMASS_DENSITY
End Sub

Sub circleComputeMass (b() As tBODY, index As Long, density As _Float)
    b(index).fzx.mass = cPI * b(index).shape.radius * b(index).shape.radius * density
    If b(index).fzx.mass <> 0 Then
        b(index).fzx.invMass = 1.0 / b(index).fzx.mass
    Else
        b(index).fzx.invMass = 0.0
    End If

    b(index).fzx.inertia = b(index).fzx.mass * b(index).shape.radius * b(index).shape.radius

    If b(index).fzx.inertia <> 0 Then
        b(index).fzx.invInertia = 1.0 / b(index).fzx.inertia
    Else
        b(index).fzx.invInertia = 0.0
    End If
End Sub

Sub polygonInitialize (body() As tBODY, p() As tPOLY, index As Long)
    polygonComputeMass body(), p(), index, cMASS_DENSITY
End Sub

Sub polygonComputeMass (b() As tBODY, p() As tPOLY, index As Long, density As _Float)
    Dim c As tVECTOR2d ' centroid
    Dim p1 As tVECTOR2d
    Dim p2 As tVECTOR2d
    Dim area As _Float
    Dim I As _Float
    Dim k_inv3 As _Float
    Dim D As _Float
    Dim triangleArea As _Float
    Dim weight As _Float
    Dim intx2 As _Float
    Dim inty2 As _Float
    Dim ii As Long

    k_inv3 = 1.0 / 3.0

    For ii = 0 To b(index).pa.count
        p1 = p(b(index).pa.start + ii).vert
        p2 = p(b(index).pa.start + arrayNextIndex(ii, b(index).pa.count)).vert
        D = vector2dCross(p1, p2)
        triangleArea = .5 * D
        area = area + triangleArea
        weight = triangleArea * k_inv3
        vector2dAddVectorScalar c, p1, weight
        vector2dAddVectorScalar c, p2, weight
        intx2 = p1.x * p1.x + p2.x * p1.x + p2.x * p2.x
        inty2 = p1.y * p1.y + p2.y * p1.y + p2.y * p2.y
        I = I + (0.25 * k_inv3 * D) * (intx2 + inty2)
    Next ii

    vector2dMultiplyScalar c, 1.0 / area

    For ii = 0 To b(index).pa.count
        vector2dSubVector p(b(index).pa.start + ii).vert, c
    Next

    b(index).fzx.mass = density * area
    If b(index).fzx.mass <> 0.0 Then
        b(index).fzx.invMass = 1.0 / b(index).fzx.mass
    Else
        b(index).fzx.invMass = 0.0
    End If

    b(index).fzx.inertia = I * density
    If b(index).fzx.inertia <> 0 Then
        b(index).fzx.invInertia = 1.0 / b(index).fzx.inertia
    Else
        b(index).fzx.invInertia = 0.0
    End If
End Sub

'**********************************************************************************************
'   Body Creation
'**********************************************************************************************

Sub _______________BODY_CREATION_FUNCTIONS (): End Sub

Function createCircleBody (body() As tBODY, index As Long, radius As _Float)
    Dim shape As tSHAPE
    shapeCreate shape, cSHAPE_CIRCLE, radius
    shape.maxDimension.x = radius * cAABB_TOLERANCE
    shape.maxDimension.y = radius * cAABB_TOLERANCE
    bodyCreate body(), index, shape
    'no vertices have to created for circles
    circleInitialize body(), index
    ' Even though circles do not have vertices, they still must be included in the vertices list
    If index = 0 Then
        body(index).pa.start = 0
    Else
        body(index).pa.start = body(index - 1).pa.start + body(index - 1).pa.count + 1
    End If
    body(index).pa.count = 1
    body(index).c = _RGB32(255, 255, 255)
    createCircleBody = index
End Function

Function createCircleBodyEx (body() As tBODY, objName As String, radius As _Float)
    Dim shape As tSHAPE
    Dim index As Long
    shapeCreate shape, cSHAPE_CIRCLE, radius
    shape.maxDimension.x = radius * cAABB_TOLERANCE
    shape.maxDimension.y = radius * cAABB_TOLERANCE
    bodyCreateEx body(), objName, shape, index
    'no vertices have to created for circles
    circleInitialize body(), index
    ' Even though circles do not have vertices, they still must be included in the vertices list
    If index = 0 Then
        body(index).pa.start = 0
    Else
        body(index).pa.start = body(index - 1).pa.start + body(index - 1).pa.count + 1
    End If
    body(index).pa.count = 1
    body(index).c = _RGB32(255, 255, 255)
    createCircleBodyEx = index
End Function


Function createBoxBody (p() As tPOLY, body() As tBODY, index As Long, xs As _Float, ys As _Float)
    Dim shape As tSHAPE
    shapeCreate shape, cSHAPE_POLYGON, 0
    shape.maxDimension.x = xs * cAABB_TOLERANCE
    shape.maxDimension.y = ys * cAABB_TOLERANCE
    bodyCreate body(), index, shape
    boxCreate p(), body(), index, xs, ys
    polygonInitialize body(), p(), index
    body(index).c = _RGB32(255, 255, 255)
    createBoxBody = index
End Function

Function createBoxBodyEx (p() As tPOLY, body() As tBODY, objName As String, xs As _Float, ys As _Float)
    Dim shape As tSHAPE
    Dim index As Long
    shapeCreate shape, cSHAPE_POLYGON, 0
    shape.maxDimension.x = xs * cAABB_TOLERANCE
    shape.maxDimension.y = ys * cAABB_TOLERANCE

    bodyCreateEx body(), objName, shape, index
    boxCreate p(), body(), index, xs, ys
    polygonInitialize body(), p(), index
    body(index).c = _RGB32(255, 255, 255)
    createBoxBodyEx = index
End Function

Sub createTrapBody (p() As tPOLY, body() As tBODY, index As Long, xs As _Float, ys As _Float, yoff1 As _Float, yoff2 As _Float)
    Dim shape As tSHAPE
    shapeCreate shape, cSHAPE_POLYGON, 0
    shape.maxDimension.x = xs * cAABB_TOLERANCE
    shape.maxDimension.y = ys * cAABB_TOLERANCE

    bodyCreate body(), index, shape
    trapCreate p(), body(), index, xs, ys, yoff1, yoff2
    polygonInitialize body(), p(), index
    body(index).c = _RGB32(255, 255, 255)
End Sub

Sub createTrapBodyEx (p() As tPOLY, body() As tBODY, objName As String, xs As _Float, ys As _Float, yoff1 As _Float, yoff2 As _Float)
    Dim shape As tSHAPE
    Dim index As Long
    shapeCreate shape, cSHAPE_POLYGON, 0
    shape.maxDimension.x = xs * cAABB_TOLERANCE
    shape.maxDimension.y = ys * cAABB_TOLERANCE

    bodyCreateEx body(), objName, shape, index
    trapCreate p(), body(), index, xs, ys, yoff1, yoff2
    polygonInitialize body(), p(), index
    body(index).c = _RGB32(255, 255, 255)
End Sub

Sub bodyCreateEx (body() As tBODY, objName As String, shape As tSHAPE, index As Long)
    index = bodyManagerAdd(body())
    body(index).objectName = objName
    body(index).objectHash = computeHash&&(objName)
    bodyCreate body(), index, shape
End Sub


Sub bodyCreate (body() As tBODY, index As Long, shape As tSHAPE)
    vector2dSet body(index).fzx.position, 0, 0
    vector2dSet body(index).fzx.velocity, 0, 0
    body(index).fzx.angularVelocity = 0.0
    body(index).fzx.torque = 0.0
    body(index).fzx.orient = 0.0

    vector2dSet body(index).fzx.force, 0, 0
    body(index).fzx.staticFriction = 0.5
    body(index).fzx.dynamicFriction = 0.3
    body(index).fzx.restitution = 0.2
    body(index).shape = shape
    body(index).collisionMask = 255
    body(index).enable = 1
    body(index).noPhysics = 0
End Sub

Sub boxCreate (p() As tPOLY, body() As tBODY, index As Long, sizex As _Float, sizey As _Float)
    Dim vertlength As Long: vertlength = 3
    Dim verts(vertlength) As tVECTOR2d

    vector2dSet verts(0), -sizex, -sizey
    vector2dSet verts(1), sizex, -sizey
    vector2dSet verts(2), sizex, sizey
    vector2dSet verts(3), -sizex, sizey

    vertexSet p(), body(), index, verts()
End Sub

Sub trapCreate (p() As tPOLY, body() As tBODY, index As Long, sizex As _Float, sizey As _Float, yOff1 As _Float, yOff2 As _Float)
    Dim vertlength As Long: vertlength = 3
    Dim verts(vertlength) As tVECTOR2d

    vector2dSet verts(0), -sizex, -sizey - yOff2
    vector2dSet verts(1), sizex, -sizey - yOff1
    vector2dSet verts(2), sizex, sizey
    vector2dSet verts(3), -sizex, sizey

    vertexSet p(), body(), index, verts()
End Sub

Sub createTerrianBody (p() As tPOLY, body() As tBODY, index As Long, slices As Long, sliceWidth As _Float, nominalHeight As _Float)
    Dim shape As tSHAPE
    Dim elevation(slices) As _Float
    Dim As Long i, j

    For j = 0 To slices
        elevation(j) = Rnd * 500
    Next

    shapeCreate shape, cSHAPE_POLYGON, 0

    For i = 0 To slices - 1
        bodyCreate body(), index + i, shape
        terrainCreate p(), body(), index + i, elevation(i), elevation(i + 1), sliceWidth, nominalHeight
        polygonInitialize body(), p(), index + i
        body(index + i).c = _RGB32(255, 255, 255)
        bodySetStatic body(index + i)
    Next i
End Sub

Sub createTerrianBodyEx (p() As tPOLY, body() As tBODY, world As tWORLD, objName As String, elevation() As _Float, slices As Long, sliceWidth As _Float, nominalHeight As _Float)
    Dim shape As tSHAPE
    Dim As Long i, index

    shapeCreate shape, cSHAPE_POLYGON, 0

    For i = 0 To slices - 1
        bodyCreateEx body(), objName + "_" + LTrim$(Str$(i)), shape, index
        terrainCreate p(), body(), index, elevation(i), elevation(i + 1), sliceWidth, nominalHeight
        polygonInitialize body(), p(), index
        body(index).c = _RGB32(255, 255, 255)
        bodySetStatic body(index)
    Next i

    Dim As _Float p1, p2
    Dim start As _Integer64

    For i = 0 To slices - 1
        start = bodyManagerID(body(), objName + "_" + LTrim$(Str$(i)))
        p1 = (sliceWidth / 2) - p(body(start).pa.start).vert.x
        p2 = nominalHeight - p(body(start).pa.start + 1).vert.y
        setBody p(), body(), cPARAMETER_POSITION, start, world.terrainPosition.x + p1 + (sliceWidth * i), world.terrainPosition.y + p2
    Next
End Sub

Sub terrainCreate (p() As tPOLY, body() As tBODY, index As Long, ele1 As _Float, ele2 As _Float, sliceWidth As _Float, nominalHeight As _Float)
    Dim As Long vertLength
    vertLength = 3 ' numOfslices + 1
    Dim verts(vertLength) As tVECTOR2d

    vector2dSet verts(0), 0, nominalHeight
    vector2dSet verts(1), (0) * sliceWidth, -nominalHeight - ele1
    vector2dSet verts(2), (1) * sliceWidth, -nominalHeight - ele2
    vector2dSet verts(3), (1) * sliceWidth, nominalHeight
    vertexSet p(), body(), index, verts()
End Sub

Sub vShapeCreate (p() As tPOLY, body() As tBODY, index As Long, sizex As _Float, sizey As _Float)
    Dim vertlength As Long: vertlength = 7
    Dim verts(vertlength) As tVECTOR2d

    vector2dSet verts(0), -sizex, -sizey
    vector2dSet verts(1), sizex, -sizey
    vector2dSet verts(2), sizex, sizey
    vector2dSet verts(3), -sizex, sizey
    vector2dSet verts(4), -sizex, sizey / 2
    vector2dSet verts(5), sizex / 2, sizey / 2
    vector2dSet verts(6), sizex / 2, -sizey / 2
    vector2dSet verts(7), -sizex, sizey / 2

    vertexSet p(), body(), index, verts()
End Sub

'**********************************************************************************************
' Vertex set function
' This function verifies proper rotation to calculate Normals used in Collisions
' This function also removes Concave surfaces for collisions
'**********************************************************************************************

Sub _______________VERTEX_SET_FUNCTION (): End Sub
Sub vertexSet (p() As tPOLY, body() As tBODY, index As Long, verts() As tVECTOR2d)
    Dim rightMost As Long: rightMost = 0
    Dim highestXCoord As _Float: highestXCoord = verts(0).x
    Dim As Long i, vertLength
    Dim x As _Float
    vertLength = UBound(verts)
    For i = 1 To vertLength
        x = verts(i).x
        If x > highestXCoord Then
            highestXCoord = x
            rightMost = i
        Else
            If x = highestXCoord Then
                If verts(i).y < verts(rightMost).y Then
                    rightMost = i
                End If
            End If
        End If
    Next
    Dim hull(vertLength * 2) As Long
    Dim outCount As Long: outCount = 0
    Dim indexHull As Long: indexHull = rightMost
    Dim nextHullIndex As Long
    Dim e1 As tVECTOR2d
    Dim e2 As tVECTOR2d
    Dim c As _Float
    Do
        hull(outCount) = indexHull
        nextHullIndex = 0
        For i = 1 To vertLength
            If nextHullIndex = indexHull Then
                nextHullIndex = i
                _Continue
            End If
            vector2dSubVectorND e1, verts(nextHullIndex), verts(hull(outCount))
            vector2dSubVectorND e2, verts(i), verts(hull(outCount))
            c = vector2dCross(e1, e2)
            If c < 0.0 Then nextHullIndex = i
            If c = 0.0 And (vector2dLengthSq(e2) > vector2dLengthSq(e1)) Then
                nextHullIndex = i
            End If
        Next
        outCount = outCount + 1
        indexHull = nextHullIndex
        If nextHullIndex = rightMost Then
            body(index).pa.count = outCount - 1
            Exit Do
        End If
    Loop

    If index = 0 Then
        body(index).pa.start = 0
    Else
        body(index).pa.start = body(index - 1).pa.start + body(index - 1).pa.count + 1
    End If

    'Make sure we don't runout of room
    If body(index).pa.start + vertLength > UBound(p) Then
        ReDim _Preserve p((body(index).pa.start + vertLength) * 2) As tPOLY
    End If

    For i = 0 To vertLength
        p(body(index).pa.start + i).vert = verts(hull(i))
    Next

    Dim face As tVECTOR2d
    For i = 0 To vertLength
        vector2dSubVectorND face, p(body(index).pa.start + arrayNextIndex(i, body(index).pa.count)).vert, p(body(index).pa.start + i).vert
        vector2dSet p(body(index).pa.start + i).norm, face.y, -face.x
        vector2dNormalize p(body(index).pa.start + i).norm
    Next
End Sub
'**********************************************************************************************
'   Shape Function
'**********************************************************************************************
Sub _______________SHAPE_INIT_FUNCTION (): End Sub
Sub shapeCreate (sh As tSHAPE, ty As Long, radius As _Float)
    Dim u As tMATRIX2d
    matrix2x2SetScalar u, 1, 0, 0, 1
    sh.ty = ty
    sh.radius = radius
    sh.u = u
    sh.scaleTextureX = 1.0
    sh.scaleTextureY = 1.0
    sh.renderOrder = 1 ' 0 - will be the front most rendering
End Sub

'**********************************************************************************************
'   Body Tools
'**********************************************************************************************

Sub _______________BODY_PARAMETER_FUNCTIONS (): End Sub

Sub setBody (p() As tPOLY, body() As tBODY, Parameter As Long, Index As Long, arg1 As _Float, arg2 As _Float)
    Select Case Parameter
        Case cPARAMETER_POSITION:
            vector2dSet body(Index).fzx.position, arg1, arg2
        Case cPARAMETER_VELOCITY:
            vector2dSet body(Index).fzx.velocity, arg1, arg2
        Case cPARAMETER_FORCE:
            vector2dSet body(Index).fzx.force, arg1, arg2
        Case cPARAMETER_ANGULARVELOCITY:
            body(Index).fzx.angularVelocity = arg1
        Case cPARAMETER_TORQUE:
            body(Index).fzx.torque = arg1
        Case cPARAMETER_ORIENT:
            body(Index).fzx.orient = arg1
            matrix2x2SetRadians body(Index).shape.u, body(Index).fzx.orient
        Case cPARAMETER_STATICFRICTION:
            body(Index).fzx.staticFriction = arg1
        Case cPARAMETER_DYNAMICFRICTION:
            body(Index).fzx.dynamicFriction = arg1
        Case cPARAMETER_RESTITUTION:
            body(Index).fzx.restitution = arg1
        Case cPARAMETER_COLOR:
            body(Index).c = arg1
        Case cPARAMETER_ENABLE:
            body(Index).enable = arg1
        Case cPARAMETER_STATIC:
            bodySetStatic body(Index)
        Case cPARAMETER_TEXTURE:
            body(Index).shape.texture = arg1
        Case cPARAMETER_FLIPTEXTURE: 'does the texture flip directions when moving left or right
            body(Index).shape.flipTexture = arg1
        Case cPARAMETER_COLLISIONMASK:
            body(Index).collisionMask = arg1
        Case cPARAMETER_INVERTNORMALS:
            If arg1 Then polygonInvertNormals p(), body(), Index
        Case cPARAMETER_NOPHYSICS:
            body(Index).noPhysics = arg1
        Case cPARAMETER_SPECIALFUNCTION:
            body(Index).specFunc.func = arg1
            body(Index).specFunc.arg = arg2
        Case cPARAMETER_RENDERORDER:
            body(Index).shape.renderOrder = arg1
        Case cPARAMETER_ENTITYID:
            body(Index).entityID = arg1
    End Select
End Sub

Sub setBodyEx (p() As tPOLY, body() As tBODY, Parameter As Long, objName As String, arg1 As _Float, arg2 As _Float)
    Dim index As Long
    index = bodyManagerID(body(), objName)
    If index > -1 Then
        setBody p(), body(), Parameter, index, arg1, arg2
    End If
End Sub

Sub bodyStop (body As tBODY)
    vector2dSet body.fzx.velocity, 0, 0
    body.fzx.angularVelocity = 0
End Sub

Sub bodyOffset (body() As tBODY, p() As tPOLY, index As Long, vec As tVECTOR2d)
    Dim i As Long
    For i = 0 To body(index).pa.count
        vector2dAddVector p(body(index).pa.start + i).vert, vec
    Next
End Sub

Sub bodySetStatic (body As tBODY)
    body.fzx.inertia = 0.0
    body.fzx.invInertia = 0.0
    body.fzx.mass = 0.0
    body.fzx.invMass = 0.0
End Sub

Function bodyAtRest (body As tBODY)
    bodyAtRest = (body.fzx.velocity.x < 1 And body.fzx.velocity.x > -1 And body.fzx.velocity.y < 1 And body.fzx.velocity.y > -1)
End Function

Sub copyBodies (body() As tBODY, newBody() As tBODY)
    Dim As Long index
    For index = 0 To UBound(body)
        newBody(index) = body(index)
    Next
End Sub

'**********************************************************************************************
'   Misc
'**********************************************************************************************

Sub _______________MORE_MISC_FUNCTIONS (): End Sub

Sub shutdown (tile() As tTILE, network As tNETWORK)
    freeAllTiles tile()
    networkClose network
    Close logfile
    System
End Sub

Function arrayNextIndex (i As Long, count As Long)
    arrayNextIndex = ((i + 1) Mod (count + 1))
End Function

Function bool (b As Long)
    If b = 0 Then
        bool = 0
    Else
        bool = 1
    End If
End Function

Sub waitkey
    _Display
    Do: Loop Until InKey$ <> ""
End Sub

Function trim$ (in As String)
    trim$ = RTrim$(LTrim$(in))
End Function

'**********************************************************************************************
'   FPS Management
'**********************************************************************************************
Sub _______________FPS_MANAGEMENT (): End Sub

Sub initFPS
    Dim timerOne As Long
    timerOne = _FreeTimer
    On Timer(timerOne, 1) FPS
    Timer(timerOne) On
End Sub

Sub FPS
    fpsCount.fpsLast = fpsCount.fpsCount
    fpsCount.fpsCount = 0
End Sub

Sub handleFPS ()
    Dim fpss As String
    fpsCount.fpsCount = fpsCount.fpsCount + 1
    fpss = "FPS:" + Str$(fpsCount.fpsLast)
    _PrintString ((_Width / 2) - (_PrintWidth(fpss) / 2), 0), fpss
End Sub

'**********************************************************************************************
'   World to Gamemap Conversions
'**********************************************************************************************

Sub _______________WORLD_TO_GAMEMAP (): End Sub

Function xyToGameMapPlain (tilemap As tTILEMAP, x As Long, y As Long)
    Dim p As tVECTOR2d
    vector2dSet p, x, y
    xyToGameMapPlain = vector2dToGameMapPlain(tilemap, p)
End Function

Function vector2dToGameMapPlain (tilemap As tTILEMAP, p As tVECTOR2d)
    vector2dToGameMapPlain = p.x + (p.y * tilemap.mapWidth)
End Function

Function xyToGameMap (tilemap As tTILEMAP, x As Long, y As Long)
    Dim p As tVECTOR2d
    vector2dSet p, x, y
    xyToGameMap = vector2dToGameMap(tilemap, p)
End Function

Function vector2dToGameMap (tilemap As tTILEMAP, p As tVECTOR2d)
    vector2dToGameMap = Int((((p.x * tilemap.tilescale) / tilemap.tileWidth) + ((p.y * tilemap.tilescale) / tilemap.tileHeight) * tilemap.mapWidth))
End Function

'**********************************************************************************************
'   TIMER
'**********************************************************************************************
Sub _______________TIMER_CODE (): End Sub

Sub handleTimers
    Dim As Long i
    For i = 0 To UBound(timers)
        timers(i).last = Timer(.001)
    Next
End Sub

Function addTimer (duration As Long)
    timers(UBound(timers)).start = Timer(.001)
    timers(UBound(timers)).duration = duration
    addTimer = UBound(timers)
    ReDim _Preserve timers(UBound(timers) + 1) As tELAPSEDTIMER
End Function

Sub freeTimer (index As Long)
    Dim As Long i
    For i = index To UBound(timers) - 1
        timers(i) = timers(i + 1)
    Next
    ReDim _Preserve timers(UBound(timers) - 1) As tELAPSEDTIMER
End Sub

'**********************************************************************************************
'   Physics Collision Calculations
'**********************************************************************************************
Sub _______________COLLISION_FUNCTIONS (): End Sub

Sub collisionCCHandle (m As tMANIFOLD, contacts() As tVECTOR2d, A As tBODY, B As tBODY)
    Dim normal As tVECTOR2d
    Dim dist_sqr As _Float
    Dim radius As _Float

    vector2dSubVectorND normal, B.fzx.position, A.fzx.position ' Subtract two vectors position A and position
    dist_sqr = vector2dLengthSq(normal) ' Calculate the distance between the balls or circles
    radius = A.shape.radius + B.shape.radius ' Add both circle A and circle B radius

    If (dist_sqr >= radius * radius) Then
        m.contactCount = 0
    Else
        Dim distance As _Float
        distance = Sqr(dist_sqr)
        m.contactCount = 1

        If distance = 0 Then
            m.penetration = A.shape.radius
            vector2dSet m.normal, 1.0, 0.0
            vector2dSetVector contacts(0), A.fzx.position
        Else
            m.penetration = radius - distance
            vector2dDivideScalarND m.normal, normal, distance

            vector2dMultiplyScalarND contacts(0), m.normal, A.shape.radius
            vector2dAddVector contacts(0), A.fzx.position
        End If
    End If
End Sub

Sub collisionPCHandle (p() As tPOLY, body() As tBODY, m As tMANIFOLD, contacts() As tVECTOR2d, A As Long, B As Long)
    collisionCPHandle p(), body(), m, contacts(), B, A
    If m.contactCount > 0 Then
        vector2dNeg m.normal
    End If
End Sub

Sub collisionCPHandle (p() As tPOLY, body() As tBODY, m As tMANIFOLD, contacts() As tVECTOR2d, A As Long, B As Long)
    'A is the Circle
    'B is the POLY
    m.contactCount = 0
    Dim center As tVECTOR2d
    Dim tm As tMATRIX2d
    Dim tv As tVECTOR2d
    Dim ARadius As _Float: ARadius = body(A).shape.radius

    vector2dSubVectorND center, body(A).fzx.position, body(B).fzx.position
    matrix2x2Transpose body(B).shape.u, tm
    matrix2x2MultiplyVector tm, center, center

    Dim separation As _Float: separation = -9999999
    Dim faceNormal As Long: faceNormal = 0
    Dim i As Long
    Dim s As _Float
    For i = 0 To body(B).pa.count
        vector2dSubVectorND tv, center, p(body(B).pa.start + i).vert
        s = vector2dDot(p(body(B).pa.start + i).norm, tv)
        If s > ARadius Then Exit Sub
        If s > separation Then
            separation = s
            faceNormal = i
        End If
    Next
    Dim v1 As tVECTOR2d
    v1 = p(body(B).pa.start + faceNormal).vert
    Dim i2 As Long
    i2 = body(B).pa.start + arrayNextIndex(faceNormal, body(B).pa.count)
    Dim v2 As tVECTOR2d
    v2 = p(i2).vert

    If separation < cEPSILON Then
        m.contactCount = 1
        matrix2x2MultiplyVector body(B).shape.u, p(body(B).pa.start + faceNormal).norm, m.normal
        vector2dNeg m.normal
        vector2dMultiplyScalarND contacts(0), m.normal, ARadius
        vector2dAddVector contacts(0), body(A).fzx.position
        m.penetration = ARadius
        Exit Sub
    End If

    Dim dot1 As _Float
    Dim dot2 As _Float

    Dim tv1 As tVECTOR2d
    Dim tv2 As tVECTOR2d
    Dim n As tVECTOR2d
    vector2dSubVectorND tv1, center, v1
    vector2dSubVectorND tv2, v2, v1
    dot1 = vector2dDot(tv1, tv2)
    vector2dSubVectorND tv1, center, v2
    vector2dSubVectorND tv2, v1, v2
    dot2 = vector2dDot(tv1, tv2)
    m.penetration = ARadius - separation
    If dot1 <= 0.0 Then
        If vector2dSqDist(center, v1) > ARadius * ARadius Then Exit Sub
        m.contactCount = 1
        vector2dSubVectorND n, v1, center
        matrix2x2MultiplyVector body(B).shape.u, n, n
        vector2dNormalize n
        m.normal = n
        matrix2x2MultiplyVector body(B).shape.u, v1, v1
        vector2dAddVectorND v1, v1, body(B).fzx.position
        contacts(0) = v1
    Else
        If dot2 <= 0.0 Then
            If vector2dSqDist(center, v2) > ARadius * ARadius Then Exit Sub
            m.contactCount = 1
            vector2dSubVectorND n, v2, center
            matrix2x2MultiplyVector body(B).shape.u, v2, v2
            vector2dAddVectorND v2, v2, body(B).fzx.position
            contacts(0) = v2
            matrix2x2MultiplyVector body(B).shape.u, n, n
            vector2dNormalize n
            m.normal = n
        Else
            n = p(body(B).pa.start + faceNormal).norm
            vector2dSubVectorND tv1, center, v1
            If vector2dDot(tv1, n) > ARadius Then Exit Sub
            m.contactCount = 1
            matrix2x2MultiplyVector body(B).shape.u, n, n
            vector2dNeg n
            m.normal = n
            vector2dMultiplyScalarND contacts(0), m.normal, ARadius
            vector2dAddVector contacts(0), body(A).fzx.position
        End If
    End If
End Sub

Function collisionPPClip (n As tVECTOR2d, c As _Float, face() As tVECTOR2d)
    Dim sp As Long: sp = 0
    Dim o(10) As tVECTOR2d

    o(0) = face(0)
    o(1) = face(1)

    Dim d1 As _Float: d1 = vector2dDot(n, face(0)) - c
    Dim d2 As _Float: d2 = vector2dDot(n, face(1)) - c

    If d1 <= 0.0 Then
        o(sp) = face(0)
        sp = sp + 1
    End If

    If d2 <= 0.0 Then
        o(sp) = face(1)
        sp = sp + 1
    End If

    If d1 * d2 < 0.0 Then
        Dim alpha As _Float: alpha = d1 / (d1 - d2)
        Dim tempv As tVECTOR2d
        'out[sp] = face[0] + alpha * (face[1] - face[0]);
        vector2dSubVectorND tempv, face(1), face(0)
        vector2dMultiplyScalar tempv, alpha
        vector2dAddVectorND o(sp), tempv, face(0)
        sp = sp + 1
    End If
    face(0) = o(0)
    face(1) = o(1)
    collisionPPClip = sp
End Function

Sub collisionPPFindIncidentFace (p() As tPOLY, b() As tBODY, v() As tVECTOR2d, RefPoly As Long, IncPoly As Long, referenceIndex As Long)
    Dim referenceNormal As tVECTOR2d
    Dim uRef As tMATRIX2d: uRef = b(RefPoly).shape.u
    Dim uInc As tMATRIX2d: uInc = b(IncPoly).shape.u
    Dim uTemp As tMATRIX2d
    Dim i As Long
    referenceNormal = p(b(RefPoly).pa.start + referenceIndex).norm

    '        // Calculate normal in incident's frame of reference
    '        // referenceNormal = RefPoly->u * referenceNormal; // To world space
    matrix2x2MultiplyVector uRef, referenceNormal, referenceNormal
    '        // referenceNormal = IncPoly->u.Transpose( ) * referenceNormal; // To incident's model space
    matrix2x2Transpose uInc, uTemp
    matrix2x2MultiplyVector uTemp, referenceNormal, referenceNormal

    Dim incidentFace As Long: incidentFace = 0
    Dim minDot As _Float: minDot = 9999999
    Dim dot As _Float
    For i = 0 To b(IncPoly).pa.count
        dot = vector2dDot(referenceNormal, p(b(IncPoly).pa.start + i).norm)
        If (dot < minDot) Then
            minDot = dot
            incidentFace = i
        End If
    Next

    '// Assign face vertices for incidentFace
    '// v[0] = IncPoly->u * IncPoly->m_vertices[incidentFace] + IncPoly->body->position;
    matrix2x2MultiplyVector uInc, p(b(IncPoly).pa.start + incidentFace).vert, v(0)
    vector2dAddVector v(0), b(IncPoly).fzx.position

    '// incidentFace = incidentFace + 1 >= (int32)IncPoly->m_vertexCount ? 0 : incidentFace + 1;
    incidentFace = arrayNextIndex(incidentFace, b(IncPoly).pa.count)

    '// v[1] = IncPoly->u * IncPoly->m_vertices[incidentFace] +  IncPoly->body->position;
    matrix2x2MultiplyVector uInc, p(b(IncPoly).pa.start + incidentFace).vert, v(1)
    vector2dAddVector v(1), b(IncPoly).fzx.position
End Sub

Sub collisionPPHandle (p() As tPOLY, body() As tBODY, m As tMANIFOLD, contacts() As tVECTOR2d, A As Long, B As Long)
    m.contactCount = 0

    Dim faceA(100) As Long

    Dim penetrationA As _Float
    penetrationA = collisionPPFindAxisLeastPenetration(p(), body(), faceA(), A, B)
    If penetrationA >= 0.0 Then Exit Sub

    Dim faceB(100) As Long

    Dim penetrationB As _Float
    penetrationB = collisionPPFindAxisLeastPenetration(p(), body(), faceB(), B, A)
    If penetrationB >= 0.0 Then Exit Sub


    Dim referenceIndex As Long
    Dim flip As Long

    Dim RefPoly As Long
    Dim IncPoly As Long

    If impulseGT(penetrationA, penetrationB) Then
        RefPoly = A
        IncPoly = B
        referenceIndex = faceA(0)
        flip = 0
    Else
        RefPoly = B
        IncPoly = A
        referenceIndex = faceB(0)
        flip = 1
    End If

    Dim incidentFace(2) As tVECTOR2d

    collisionPPFindIncidentFace p(), body(), incidentFace(), RefPoly, IncPoly, referenceIndex
    Dim v1 As tVECTOR2d
    Dim v2 As tVECTOR2d
    Dim v1t As tVECTOR2d
    Dim v2t As tVECTOR2d

    v1 = p(body(RefPoly).pa.start + referenceIndex).vert
    referenceIndex = arrayNextIndex(referenceIndex, body(RefPoly).pa.count)
    v2 = p(body(RefPoly).pa.start + referenceIndex).vert
    '// Transform vertices to world space
    '// v1 = RefPoly->u * v1 + RefPoly->body->position;
    '// v2 = RefPoly->u * v2 + RefPoly->body->position;
    matrix2x2MultiplyVector body(RefPoly).shape.u, v1, v1t
    vector2dAddVectorND v1, v1t, body(RefPoly).fzx.position
    matrix2x2MultiplyVector body(RefPoly).shape.u, v2, v2t
    vector2dAddVectorND v2, v2t, body(RefPoly).fzx.position

    '// Calculate reference face side normal in world space
    '// Vec2 sidePlaneNormal = (v2 - v1);
    '// sidePlaneNormal.Normalize( );
    Dim sidePlaneNormal As tVECTOR2d
    vector2dSubVectorND sidePlaneNormal, v2, v1
    vector2dNormalize sidePlaneNormal

    '// Orthogonalize
    '// Vec2 refFaceNormal( sidePlaneNormal.y, -sidePlaneNormal.x );
    Dim refFaceNormal As tVECTOR2d
    vector2dSet refFaceNormal, sidePlaneNormal.y, -sidePlaneNormal.x

    '// ax + by = c
    '// c is distance from origin
    '// real refC = Dot( refFaceNormal, v1 );
    '// real negSide = -Dot( sidePlaneNormal, v1 );
    '// real posSide = Dot( sidePlaneNormal, v2 );
    Dim refC As _Float: refC = vector2dDot(refFaceNormal, v1)
    Dim negSide As _Float: negSide = -vector2dDot(sidePlaneNormal, v1)
    Dim posSide As _Float: posSide = vector2dDot(sidePlaneNormal, v2)


    '// Clip incident face to reference face side planes
    '// if(Clip( -sidePlaneNormal, negSide, incidentFace ) < 2)
    Dim negSidePlaneNormal As tVECTOR2d
    vector2dNegND negSidePlaneNormal, sidePlaneNormal

    If collisionPPClip(negSidePlaneNormal, negSide, incidentFace()) < 2 Then Exit Sub
    If collisionPPClip(sidePlaneNormal, posSide, incidentFace()) < 2 Then Exit Sub

    vector2dSet m.normal, refFaceNormal.x, refFaceNormal.y
    If flip Then vector2dNeg m.normal

    '// Keep points behind reference face
    Dim cp As Long: cp = 0 '// clipped points behind reference face
    Dim separation As _Float
    separation = vector2dDot(refFaceNormal, incidentFace(0)) - refC
    If separation <= 0.0 Then
        contacts(cp) = incidentFace(0)
        m.penetration = -separation
        cp = cp + 1
    Else
        m.penetration = 0
    End If

    separation = vector2dDot(refFaceNormal, incidentFace(1)) - refC
    If separation <= 0.0 Then
        contacts(cp) = incidentFace(1)
        m.penetration = m.penetration + -separation
        cp = cp + 1
        m.penetration = m.penetration / cp
    End If
    m.contactCount = cp
End Sub

Function collisionPPFindAxisLeastPenetration (p() As tPOLY, body() As tBODY, faceIndex() As Long, A As Long, B As Long)
    Dim bestDistance As _Float: bestDistance = -9999999
    Dim bestIndex As Long: bestIndex = 0

    Dim n As tVECTOR2d
    Dim nw As tVECTOR2d
    Dim buT As tMATRIX2d
    Dim s As tVECTOR2d
    Dim nn As tVECTOR2d
    Dim v As tVECTOR2d
    Dim tv As tVECTOR2d
    Dim d As _Float
    Dim i, k As Long

    For i = 0 To body(A).pa.count
        k = body(A).pa.start + i

        '// Retrieve a face normal from A
        '// Vec2 n = A->m_normals[i];
        '// Vec2 nw = A->u * n;
        n = p(k).norm
        matrix2x2MultiplyVector body(A).shape.u, n, nw


        '// Transform face normal into B's model space
        '// Mat2 buT = B->u.Transpose( );
        '// n = buT * nw;
        matrix2x2Transpose body(B).shape.u, buT
        matrix2x2MultiplyVector buT, nw, n

        '// Retrieve support point from B along -n
        '// Vec2 s = B->GetSupport( -n );
        vector2dNegND nn, n
        vector2dGetSupport p(), body(), B, nn, s

        '// Retrieve vertex on face from A, transform into
        '// B's model space
        '// Vec2 v = A->m_vertices[i];
        '// v = A->u * v + A->body->position;
        '// v -= B->body->position;
        '// v = buT * v;

        v = p(k).vert
        matrix2x2MultiplyVector body(A).shape.u, v, tv
        vector2dAddVectorND v, tv, body(A).fzx.position

        vector2dSubVector v, body(B).fzx.position
        matrix2x2MultiplyVector buT, v, tv

        vector2dSubVector s, tv
        d = vector2dDot(n, s)

        If d > bestDistance Then
            bestDistance = d
            bestIndex = i
        End If

    Next i

    faceIndex(0) = bestIndex

    collisionPPFindAxisLeastPenetration = bestDistance
End Function

'**********************************************************************************************
'   Physics Impulse Calculations
'**********************************************************************************************
Sub _______________PHYSICS_IMPULSE_MATH (): End Sub
Sub impulseIntegrateForces (world As tWORLD, b As tBODY, dt As _Float)
    If b.fzx.invMass = 0.0 Then Exit Sub
    Dim dts As _Float
    dts = dt * .5
    vector2dAddVectorScalar b.fzx.velocity, b.fzx.force, b.fzx.invMass * dts
    vector2dAddVectorScalar b.fzx.velocity, world.gravity, dts
    b.fzx.angularVelocity = b.fzx.angularVelocity + (b.fzx.torque * b.fzx.invInertia * dts)
End Sub

Sub impulseIntegrateVelocity (world As tWORLD, body As tBODY, dt As _Float)
    If body.fzx.invMass = 0.0 Then Exit Sub
    ' body.fzx.velocity.x = body.fzx.velocity.x * (1 - dt)
    ' body.fzx.velocity.y = body.fzx.velocity.y * (1 - dt)
    ' body.fzx.angularVelocity = body.fzx.angularVelocity * (1 - dt)
    vector2dAddVectorScalar body.fzx.position, body.fzx.velocity, dt
    body.fzx.orient = body.fzx.orient + (body.fzx.angularVelocity * dt)
    matrix2x2SetRadians body.shape.u, body.fzx.orient
    impulseIntegrateForces world, body, dt
End Sub

Sub impulseStep (engine As tENGINE, world As tWORLD, p() As tPOLY, body() As tBODY, j() As tJOINT, hits() As tHIT, dt As _Float, iterations As Long)
    Dim A As tBODY
    Dim B As tBODY
    Dim c(UBound(body)) As tVECTOR2d
    Dim m As tMANIFOLD
    Dim manifolds(UBound(body) * UBound(body)) As tMANIFOLD
    Dim collisions(UBound(body) * UBound(body), UBound(body)) As tVECTOR2d
    Dim As tVECTOR2d tv, tv1
    Dim As _Float d
    Dim As Long mval
    Dim manifoldCount As Long: manifoldCount = 0
    '    // Generate new collision info
    Dim i, j, k, index As Long
    Dim hitCount As Long: hitCount = 0

    ReDim hits(0) As tHIT
    hits(0).A = -1
    hits(0).B = -1
    hitCount = 0

    For i = 0 To UBound(body) ' number of bodies
        A = body(i)
        If A.enable Then
            For j = i + 1 To UBound(body)
                B = body(j)
                If B.enable Then
                    If (A.collisionMask And B.collisionMask) Then
                        If A.fzx.invMass = 0.0 And B.fzx.invMass = 0.0 Then _Continue
                        'Mainfold solve - handle collisions
                        If AABBOverlapObjects(body(), i, j) Then
                            If A.shape.ty = cSHAPE_CIRCLE And B.shape.ty = cSHAPE_CIRCLE Then
                                collisionCCHandle m, c(), A, B
                            Else
                                If A.shape.ty = cSHAPE_POLYGON And B.shape.ty = cSHAPE_POLYGON Then
                                    collisionPPHandle p(), body(), m, c(), i, j
                                Else
                                    If A.shape.ty = cSHAPE_CIRCLE And B.shape.ty = cSHAPE_POLYGON Then
                                        collisionCPHandle p(), body(), m, c(), i, j
                                    Else
                                        If B.shape.ty = cSHAPE_CIRCLE And A.shape.ty = cSHAPE_POLYGON Then
                                            collisionPCHandle p(), body(), m, c(), i, j
                                        End If
                                    End If
                                End If
                            End If

                            If m.contactCount > 0 Then
                                m.A = i 'identify the index of objects
                                m.B = j
                                manifolds(manifoldCount) = m
                                For k = 0 To m.contactCount
                                    hits(hitCount).A = i
                                    hits(hitCount).B = j
                                    hits(hitCount).position = c(k)
                                    collisions(manifoldCount, k) = c(k)
                                    hitCount = hitCount + 1
                                    If hitCount > UBound(hits) Then ReDim _Preserve hits(hitCount * 1.5) As tHIT
                                Next
                                manifoldCount = manifoldCount + 1
                                If manifoldCount > UBound(manifolds) Then ReDim _Preserve manifolds(manifoldCount * 1.5) As tMANIFOLD
                            End If
                        End If
                    End If
                End If
            Next
        End If
    Next

    '    Integrate forces
    For i = 0 To UBound(body)
        If body(i).enable And body(i).noPhysics = 0 Then impulseIntegrateForces world, body(i), dt
    Next
    '    Initialize collision
    For i = 0 To manifoldCount - 1
        For k = 0 To manifolds(i).contactCount - 1
            c(k) = collisions(i, k)
        Next
        manifoldInit engine, manifolds(i), body(), c()
    Next

    ' joint pre Steps
    For i = 1 To UBound(j)
        jointPrestep j(i), body(), dt
    Next

    ' Solve collisions
    For j = 0 To iterations - 1
        For i = 0 To manifoldCount - 1
            For k = 0 To manifolds(i).contactCount - 1
                c(k) = collisions(i, k)
            Next
            manifoldApplyImpulse manifolds(i), body(), c()
            'store the hit speed for later
            For k = 0 To hitCount - 1
                If manifolds(i).A = hits(k).A And manifolds(i).B = hits(k).B Then
                    hits(k).cv = manifolds(i).cv
                End If
            Next
        Next
        For i = 1 To UBound(j)
            jointApplyImpulse j(i), body()
        Next

        ' It appears that the joint bias is analgous to the stress the
        ' joint has on it.
        ' Lets give those wireframe joints some color.
        ' If that stress is greater than the max then break the joint

        index = 0
        Do
            If j(index).max_bias > 0 Then
                vector2dSetVector tv, j(index).bias
                vector2dSet tv1, 0, 0
                d = vector2dDistance(tv, tv1)
                mval = scalarMap(d, 0, 100000, 0, 255)
                j(index).wireframe_color = _RGB32(mval, 255 - mval, 0)
                If d > j(index).max_bias Then jointDelete j(), index
            End If
            index = index + 1
        Loop Until index > UBound(j)

    Next

    '// Integrate velocities
    For i = 0 To UBound(body)
        If body(i).enable And body(i).noPhysics = 0 Then impulseIntegrateVelocity world, body(i), dt
    Next
    '// Correct positions
    For i = 0 To manifoldCount - 1
        manifoldPositionalCorrection manifolds(i), body()
    Next
    '// Clear all forces
    For i = 0 To UBound(body)
        vector2dSet body(i).fzx.force, 0, 0
        body(i).fzx.torque = 0
    Next
End Sub

Sub bodyApplyImpulse (body As tBODY, impulse As tVECTOR2d, contactVector As tVECTOR2d)
    vector2dAddVectorScalar body.fzx.velocity, impulse, body.fzx.invMass
    body.fzx.angularVelocity = body.fzx.angularVelocity + body.fzx.invInertia * vector2dCross(contactVector, impulse)
End Sub

Sub _______________MANIFOLD_MATH_FUNCTIONS (): End Sub

Sub manifoldInit (engine As tENGINE, m As tMANIFOLD, body() As tBODY, contacts() As tVECTOR2d)
    Dim ra As tVECTOR2d
    Dim rb As tVECTOR2d
    Dim rv As tVECTOR2d
    Dim tv1 As tVECTOR2d 'temporary Vectors
    Dim tv2 As tVECTOR2d
    m.e = scalarMin(body(m.A).fzx.restitution, body(m.B).fzx.restitution)
    m.sf = Sqr(body(m.A).fzx.staticFriction * body(m.A).fzx.staticFriction)
    m.df = Sqr(body(m.A).fzx.dynamicFriction * body(m.A).fzx.dynamicFriction)
    Dim i As Long
    For i = 0 To m.contactCount - 1
        vector2dSubVectorND contacts(i), body(m.A).fzx.position, ra
        vector2dSubVectorND contacts(i), body(m.B).fzx.position, rb

        vector2dCrossScalar tv1, rb, body(m.B).fzx.angularVelocity
        vector2dCrossScalar tv2, ra, body(m.A).fzx.angularVelocity
        vector2dAddVector tv1, body(m.B).fzx.velocity
        vector2dSubVectorND tv2, body(m.A).fzx.velocity, tv2
        vector2dSubVectorND rv, tv1, tv2

        If vector2dLengthSq(rv) < engine.resting Then
            m.e = 0.0
        End If
    Next
End Sub

Sub manifoldApplyImpulse (m As tMANIFOLD, body() As tBODY, contacts() As tVECTOR2d)
    Dim ra As tVECTOR2d
    Dim rb As tVECTOR2d
    Dim rv As tVECTOR2d
    Dim tv1 As tVECTOR2d 'temporary Vectors
    Dim tv2 As tVECTOR2d
    Dim contactVel As _Float

    Dim raCrossN As _Float
    Dim rbCrossN As _Float
    Dim invMassSum As _Float
    Dim i As Long
    Dim j As _Float
    Dim impulse As tVECTOR2d

    Dim t As tVECTOR2d
    Dim jt As _Float
    Dim tangentImpulse As tVECTOR2d

    If impulseEqual(body(m.A).fzx.invMass + body(m.B).fzx.invMass, 0.0) Then
        manifoldInfiniteMassCorrection body(m.A), body(m.B)
        Exit Sub
    End If
    If (body(m.A).noPhysics Or body(m.B).noPhysics) Then
        Exit Sub
    End If

    For i = 0 To m.contactCount - 1
        '// Calculate radii from COM to contact
        '// Vec2 ra = contacts[i] - A->position;
        '// Vec2 rb = contacts[i] - B->position;
        vector2dSubVectorND ra, contacts(i), body(m.A).fzx.position
        vector2dSubVectorND rb, contacts(i), body(m.B).fzx.position

        '// Relative velocity
        '// Vec2 rv = B->velocity + Cross( B->angularVelocity, rb ) - A->velocity - Cross( A->angularVelocity, ra );
        vector2dCrossScalar tv1, rb, body(m.B).fzx.angularVelocity
        vector2dCrossScalar tv2, ra, body(m.A).fzx.angularVelocity
        vector2dAddVectorND rv, tv1, body(m.B).fzx.velocity
        vector2dSubVector rv, body(m.A).fzx.velocity
        vector2dSubVector rv, tv2

        '// Relative velocity along the normal
        '// real contactVel = Dot( rv, normal );
        contactVel = vector2dDot(rv, m.normal)

        '// Do not resolve if velocities are separating
        If contactVel > 0 Then Exit Sub
        m.cv = contactVel
        '// real raCrossN = Cross( ra, normal );
        '// real rbCrossN = Cross( rb, normal );
        '// real invMassSum = A->im + B->im + Sqr( raCrossN ) * A->iI + Sqr( rbCrossN ) * B->iI;
        raCrossN = vector2dCross(ra, m.normal)
        rbCrossN = vector2dCross(rb, m.normal)
        invMassSum = body(m.A).fzx.invMass + body(m.B).fzx.invMass + (raCrossN * raCrossN) * body(m.A).fzx.invInertia + (rbCrossN * rbCrossN) * body(m.B).fzx.invInertia

        '// Calculate impulse scalar
        j = -(1.0 + m.e) * contactVel
        j = j / invMassSum
        j = j / m.contactCount

        '// Apply impulse
        vector2dMultiplyScalarND impulse, m.normal, j
        vector2dNegND tv1, impulse
        bodyApplyImpulse body(m.A), tv1, ra
        bodyApplyImpulse body(m.B), impulse, rb

        '// Friction impulse
        '// rv = B->velocity + Cross( B->angularVelocity, rb ) - A->velocity - Cross( A->angularVelocity, ra );
        vector2dCrossScalar tv1, rb, body(m.B).fzx.angularVelocity
        vector2dCrossScalar tv2, ra, body(m.A).fzx.angularVelocity
        vector2dAddVectorND rv, tv1, body(m.B).fzx.velocity
        vector2dSubVector rv, body(m.A).fzx.velocity
        vector2dSubVector rv, tv2

        '// Vec2 t = rv - (normal * Dot( rv, normal ));
        '// t.Normalize( );
        vector2dMultiplyScalarND t, m.normal, vector2dDot(rv, m.normal)
        vector2dSubVectorND t, rv, t
        vector2dNormalize t

        '// j tangent magnitude
        jt = -vector2dDot(rv, t)
        jt = jt / invMassSum
        jt = jt / m.contactCount

        '// Don't apply tiny friction impulses
        If impulseEqual(jt, 0.0) Then Exit Sub

        '// Coulumb's law
        If Abs(jt) < j * m.sf Then
            vector2dMultiplyScalarND tangentImpulse, t, jt
        Else
            vector2dMultiplyScalarND tangentImpulse, t, -j * m.df
        End If

        '// Apply friction impulse
        '// A->ApplyImpulse( -tangentImpulse, ra );
        '// B->ApplyImpulse( tangentImpulse, rb );
        vector2dNegND tv1, tangentImpulse
        bodyApplyImpulse body(m.A), tv1, ra
        bodyApplyImpulse body(m.B), tangentImpulse, rb
    Next i
End Sub

Sub manifoldPositionalCorrection (m As tMANIFOLD, body() As tBODY)
    If body(m.A).noPhysics Or body(m.B).noPhysics Then Exit Sub
    Dim correction As _Float
    correction = scalarMax(m.penetration - cPENETRATION_ALLOWANCE, 0.0) / (body(m.A).fzx.invMass + body(m.B).fzx.invMass) * cPENETRATION_CORRECTION
    vector2dAddVectorScalar body(m.A).fzx.position, m.normal, -body(m.A).fzx.invMass * correction
    vector2dAddVectorScalar body(m.B).fzx.position, m.normal, body(m.B).fzx.invMass * correction
End Sub

Sub manifoldInfiniteMassCorrection (A As tBODY, B As tBODY)
    vector2dSet A.fzx.velocity, 0, 0
    vector2dSet B.fzx.velocity, 0, 0
End Sub

'**********************************************************************************************
'   Joint Creation
'**********************************************************************************************
Sub _______________JOINT_CREATION_FUNCTIONS (): End Sub
Function jointCreate (j() As tJOINT, body() As tBODY, b1 As Long, b2 As Long, x As _Float, y As _Float)
    ReDim _Preserve j(UBound(j) + 1) As tJOINT
    jointSet j(UBound(j)), body(), b1, b2, x, y
    'Joint name will default to a combination of the two objects that is connects.
    'If you change it you must also recompute the hash.
    j(UBound(j)).jointName = body(b1).objectName + "_" + body(b2).objectName
    j(UBound(j)).jointHash = computeHash&&(j(UBound(j)).jointName)
    j(UBound(j)).wireframe_color = _RGB32(255, 227, 127)
    jointCreate = UBound(j)
End Function

Sub jointDelete (j() As tJOINT, d As Long)
    Dim As Long index
    If d >= 0 And d <= UBound(j) And UBound(j) > 0 Then
        For index = d To UBound(j) - 1
            j(index) = j(index + 1)
        Next
        ReDim _Preserve j(UBound(j) - 1) As tJOINT
    End If
End Sub

Sub jointSet (j As tJOINT, body() As tBODY, b1 As Long, b2 As Long, x As _Float, y As _Float)
    Dim anchor As tVECTOR2d
    vector2dSet anchor, x, y
    Dim Rot1 As tMATRIX2d: Rot1 = body(b1).shape.u
    Dim Rot2 As tMATRIX2d: Rot2 = body(b2).shape.u
    Dim Rot1T As tMATRIX2d: matrix2x2Transpose Rot1, Rot1T
    Dim Rot2T As tMATRIX2d: matrix2x2Transpose Rot2, Rot2T
    Dim tv As tVECTOR2d

    j.body1 = b1
    j.body2 = b2

    vector2dSubVectorND tv, anchor, body(b1).fzx.position
    matrix2x2MultiplyVector Rot1T, tv, j.localAnchor1

    vector2dSubVectorND tv, anchor, body(b2).fzx.position
    matrix2x2MultiplyVector Rot2T, tv, j.localAnchor2

    vector2dSet j.P, 0, 0
    ' Some default Settings
    j.softness = 0.001
    j.biasFactor = 100
    j.max_bias = 100000
End Sub

'**********************************************************************************************
'   Joint Calculations
'**********************************************************************************************

Sub _______________JOINT_MATH_FUNCTIONS (): End Sub

Sub jointPrestep (j As tJOINT, body() As tBODY, inv_dt As _Float)
    Dim Rot1 As tMATRIX2d: Rot1 = body(j.body1).shape.u
    Dim Rot2 As tMATRIX2d: Rot2 = body(j.body2).shape.u
    Dim b1invMass As _Float
    Dim b2invMass As _Float

    Dim b1invInertia As _Float
    Dim b2invInertia As _Float

    matrix2x2MultiplyVector Rot1, j.localAnchor1, j.r1
    matrix2x2MultiplyVector Rot2, j.localAnchor2, j.r2

    b1invMass = body(j.body1).fzx.invMass
    b2invMass = body(j.body2).fzx.invMass

    b1invInertia = body(j.body1).fzx.invInertia
    b2invInertia = body(j.body2).fzx.invInertia

    Dim K1 As tMATRIX2d
    matrix2x2SetScalar K1, b1invMass + b2invMass, 0, 0, b1invMass + b2invMass
    Dim K2 As tMATRIX2d
matrix2x2SetScalar K2, b1invInertia * j.r1.y * j.r1.y, -b1invInertia * j.r1.x * j.r1.y,_
-b1invInertia * j.r1.x * j.r1.y,  b1invInertia * j.r1.x * j.r1.x

    Dim K3 As tMATRIX2d
matrix2x2SetScalar K3,  b2invInertia * j.r2.y * j.r2.y, - b2invInertia * j.r2.x * j.r2.y,_
-b2invInertia * j.r2.x * j.r2.y,   b2invInertia * j.r2.x * j.r2.x

    Dim K As tMATRIX2d
    matrix2x2AddMatrix K1, K2, K
    matrix2x2AddMatrix K3, K, K
    K.m00 = K.m00 + j.softness
    K.m11 = K.m11 + j.softness
    matrix2x2Invert K, j.M

    Dim p1 As tVECTOR2d: vector2dAddVectorND p1, body(j.body1).fzx.position, j.r1
    Dim p2 As tVECTOR2d: vector2dAddVectorND p2, body(j.body2).fzx.position, j.r2
    Dim dp As tVECTOR2d: vector2dSubVectorND dp, p2, p1

    vector2dMultiplyScalarND j.bias, dp, -j.biasFactor * inv_dt
    ' vectorSet j.bias, 0, 0
    vector2dSet j.P, 0, 0
End Sub

Sub jointApplyImpulse (j As tJOINT, body() As tBODY)
    Dim dv As tVECTOR2d
    Dim impulse As tVECTOR2d
    Dim cross1 As tVECTOR2d
    Dim cross2 As tVECTOR2d
    Dim tv As tVECTOR2d

    'Vec2 dv = body2->velocity + Cross(body2->angularVelocity, r2) - body1->velocity - Cross(body1->angularVelocity, r1);
    vector2dCrossScalar cross2, j.r2, body(j.body2).fzx.angularVelocity
    vector2dCrossScalar cross1, j.r1, body(j.body1).fzx.angularVelocity
    vector2dAddVectorND dv, body(j.body2).fzx.velocity, cross2
    vector2dSubVectorND dv, dv, body(j.body1).fzx.velocity
    vector2dSubVectorND dv, dv, cross1

    ' impulse = M * (bias - dv - softness * P);
    vector2dMultiplyScalarND tv, j.P, j.softness
    vector2dSubVectorND impulse, j.bias, dv
    vector2dSubVectorND impulse, impulse, tv
    matrix2x2MultiplyVector j.M, impulse, impulse

    ' body1->velocity -= body1->invMass * impulse;

    vector2dMultiplyScalarND tv, impulse, body(j.body1).fzx.invMass
    vector2dSubVectorND body(j.body1).fzx.velocity, body(j.body1).fzx.velocity, tv

    ' body1->angularVelocity -= body1->invI * Cross(r1, impulse);
    Dim crossScalar As _Float
    crossScalar = vector2dCross(j.r1, impulse)
    body(j.body1).fzx.angularVelocity = body(j.body1).fzx.angularVelocity - body(j.body1).fzx.invInertia * crossScalar

    vector2dMultiplyScalarND tv, impulse, body(j.body2).fzx.invMass
    vector2dAddVectorND body(j.body2).fzx.velocity, body(j.body2).fzx.velocity, tv

    crossScalar = vector2dCross(j.r2, impulse)
    body(j.body2).fzx.angularVelocity = body(j.body2).fzx.angularVelocity + body(j.body2).fzx.invInertia * crossScalar

    vector2dAddVectorND j.P, j.P, impulse
End Sub
'**********************************************************************************************
'   Collision Tools
'**********************************************************************************************
Sub _______________COLLISION_QUERY_TOOLS (): End Sub
Function isOnSensor (engine As tENGINE, p As tVECTOR2d)
    _Source engine.hiddenScr
    isOnSensor = _Blue(Point(p.x, p.y))
    _Source engine.displayScr
End Function

Function isBodyTouchingBody (hits() As tHIT, A As Long, B As Long)
    Dim hitcount As Long: hitcount = 0
    isBodyTouchingBody = -1
    For hitcount = 0 To UBound(hits)
        If hits(hitcount).A = A And hits(hitcount).B = B Then
            isBodyTouchingBody = hitcount
            Exit Function
        End If
    Next
End Function

Function isBodyTouchingStatic (body() As tBODY, hits() As tHIT, A As Long)
    Dim hitcount As Long: hitcount = 0
    isBodyTouchingStatic = 0
    For hitcount = 0 To UBound(hits)
        If hits(hitcount).A = A Then
            If body(hits(hitcount).B).fzx.mass = 0 Then
                isBodyTouchingStatic = hitcount
                Exit Function
            End If
        Else
            If hits(hitcount).B = A Then
                If body(hits(hitcount).A).fzx.mass = 0 Then
                    isBodyTouchingStatic = hitcount
                    Exit Function
                End If
            End If
        End If
    Next
End Function

Function isBodyTouching (hits() As tHIT, A As Long)
    Dim hitcount As Long: hitcount = 0
    isBodyTouching = -1
    For hitcount = 0 To UBound(hits)
        If hits(hitcount).A = A Then
            isBodyTouching = hits(hitcount).B
            Exit Function
        End If
        If hits(hitcount).B = A Then
            isBodyTouching = hits(hitcount).A
            Exit Function
        End If
    Next
End Function

Function highestCollisionVelocity (hits() As tHIT, A As Long) ' this function is a bit dubious and may not do as you think
    Dim hitcount As Long: hitcount = 0
    Dim hiCv As _Float: hiCv = 0
    highestCollisionVelocity = 0
    For hitcount = 0 To UBound(hits)
        If hits(hitcount).A = A And Abs(hits(hitcount).cv) > hiCv And hits(hitcount).cv < 0 Then
            hiCv = Abs(hits(hitcount).cv)
        End If
    Next
    highestCollisionVelocity = hiCv
End Function

'**********************************************************************************************
'   Body Managment Tools
'**********************************************************************************************
Sub _______________BODY_MANAGEMENT (): End Sub

Function bodyManagerAdd (body() As tBODY)
    bodyManagerAdd = UBound(body)
    ReDim _Preserve body(UBound(body) + 1) As tBODY
End Function

Function bodyWithHash (body() As tBODY, hash As _Integer64)
    Dim As Long i
    bodyWithHash = -1
    For i = 0 To UBound(body) - 1
        If body(i).objectHash = hash Then
            bodyWithHash = i
            Exit Function
        End If
    Next
End Function

Function bodyWithHashMask (body() As tBODY, hash As _Integer64, mask As Long)
    Dim As Long i
    bodyWithHashMask = -1
    For i = 0 To UBound(body) - 1
        If (body(i).objectHash And mask) = (hash And mask) Then
            bodyWithHashMask = i
            Exit Function
        End If
    Next
End Function

Function bodyManagerID (body() As tBODY, objName As String)
    Dim i As Long
    Dim uID As _Integer64
    uID = computeHash(RTrim$(LTrim$(objName)))
    bodyManagerID = -1

    For i = 0 To UBound(body)
        If body(i).objectHash = uID Then
            bodyManagerID = i
            Exit Function
        End If
    Next
End Function

Function bodyContainsString (body() As tBODY, start As Long, s As String)
    bodyContainsString = -1
    Dim As Long j
    For j = start To UBound(body)
        If InStr(body(j).objectName, s) Then
            bodyContainsString = j
            Exit Function
        End If
    Next
End Function

'**********************************************************************************************
'   String Hash
'**********************************************************************************************
Sub _______________GENERAL_STRING_HASH (): End Sub
Function computeHash&& (s As String)
    Dim p, i As Long: p = 31
    Dim m As _Integer64: m = 1E9 + 9
    Dim As _Integer64 hash_value, p_pow
    p_pow = 1
    For i = 1 To Len(s)
        hash_value = (hash_value + (Asc(Mid$(s, i)) - 97 + 1) * p_pow)
        p_pow = (p_pow * p) Mod m
    Next
    computeHash = hash_value
End Function
'**********************************************************************************************
'   Network Related Tools
'**********************************************************************************************

Sub _______________NETWORK_FUNCTIONALITY (): End Sub
Sub handleNetwork (body() As tBODY, net As tNETWORK)
    If net.SorC = cNET_SERVER Then
        If net.HCHandle = 0 Then
            networkStartHost net
        End If
        networkTransmit body(), net
    End If

    If net.SorC = cNET_CLIENT Then
        networkReceiveFromHost body(), net
    End If
End Sub

Sub networkStartHost (net As tNETWORK)
    Dim connection As String
    connection = RTrim$(net.protocol) + ":" + LTrim$(Str$(net.port))
    net.HCHandle = _OpenHost(connection)
End Sub

Sub networkReceiveFromHost (body() As tBODY, net As tNETWORK)
    Dim connection As String
    Dim As Long timeout
    connection = RTrim$(net.protocol) + ":" + LTrim$(Str$(net.port)) + ":" + RTrim$(net.address)
    net.HCHandle = _OpenClient(connection)
    timeout = Timer
    If net.HCHandle Then
        Do
            Get #net.HCHandle, , body()
            If Timer - timeout > 5 Then Exit Do ' 5 sec time out
        Loop Until EOF(net.HCHandle) = 0
        networkClose net
    End If
End Sub

Sub networkTransmit (body() As tBODY, net As tNETWORK)
    If net.HCHandle <> 0 Then
        net.connectionHandle = _OpenConnection(net.HCHandle)
        If net.connectionHandle <> 0 Then
            Put #net.connectionHandle, , body()
            Close net.connectionHandle
        End If
    End If
End Sub

Sub networkClose (net As tNETWORK)
    If net.HCHandle <> 0 Then
        Close net.HCHandle
        net.HCHandle = 0
    End If
End Sub

'**********************************************************************************************
'   Handle Input Devices
'**********************************************************************************************
Sub _______________INPUT_HANDLING (): End Sub

Sub initInputDevice (p() As tPOLY, body() As tBODY, iDevice As tINPUTDEVICE, icon As Long)
    iDevice.mouseIcon = icon
    iDevice.mouseBody = createCircleBodyEx(body(), "_mouse", 1)
    setBody p(), body(), cPARAMETER_POSITION, iDevice.mouseBody, 0, 0
    setBody p(), body(), cPARAMETER_ORIENT, iDevice.mouseBody, 0, 0
    setBody p(), body(), cPARAMETER_STATIC, iDevice.mouseBody, 0, 0
    setBody p(), body(), cPARAMETER_NOPHYSICS, iDevice.mouseBody, 1, 0
    iDevice.mouseMode = 1
End Sub

Sub handleInputDevice (p() As tPOLY, body() As tBODY, iDevice As tINPUTDEVICE, camera As tCAMERA)
    Static As tVECTOR2d mouse
    cleanUpInputDevice iDevice
    iDevice.keyHit = _KeyHit

    Do While _MouseInput
        iDevice.xy.x = _MouseX
        iDevice.xy.y = _MouseY
        iDevice.b1 = _MouseButton(1)
        iDevice.b2 = _MouseButton(2)
        iDevice.b3 = _MouseButton(3)
        iDevice.w = _MouseWheel
        iDevice.wCount = iDevice.wCount + iDevice.w
        iDevice.mouseOnScreen = iDevice.xy.x > 0 And iDevice.xy.x < _Width And iDevice.xy.y > 0 And iDevice.xy.y < _Height
    Loop
    iDevice.b1PosEdge = bool(iDevice.lb1 > iDevice.b1) ' 0 --> -1
    iDevice.b1NegEdge = bool(iDevice.lb1 < iDevice.b1) ' -1 --> 0
    iDevice.b2PosEdge = bool(iDevice.lb2 > iDevice.b2) ' 0 --> -1
    iDevice.b2NegEdge = bool(iDevice.lb2 < iDevice.b2) ' -1 --> 0
    iDevice.b3PosEdge = bool(iDevice.lb3 > iDevice.b2) ' 0 --> -1
    iDevice.b3NegEdge = bool(iDevice.lb3 < iDevice.b3) ' -1 --> 0
    If iDevice.mouseMode And iDevice.mouseOnScreen Then
        'Mouse screen position to world
        vector2dSet mouse, iDevice.xy.x, iDevice.xy.y
        cameraToWorld camera, mouse, iDevice.mouse
        setBody p(), body(), cPARAMETER_POSITION, iDevice.mouseBody, iDevice.mouse.x, iDevice.mouse.y
        alphaImage 255, iDevice.mouseIcon, iDevice.xy, camera.zoom
    End If
End Sub

Sub cleanUpInputDevice (iDevice As tINPUTDEVICE)
    iDevice.lb1 = iDevice.b1
    iDevice.lb2 = iDevice.b2
    iDevice.lb3 = iDevice.b3
    iDevice.lastKeyHit = iDevice.keyHit
    iDevice.wCount = 0
End Sub

'**********************************************************************************************
'   Entity Behavior
'**********************************************************************************************
Sub _______________ENTITY_HANDLING (): End Sub

Sub moveEntity (entity As tENTITY, body() As tBODY, endPos As tVECTOR2d, gamemap() As tTILE, tilemap As tTILEMAP)
    Dim As tVECTOR2d startPos, endPosDiv
    'Convert start and end to gamemap X and Y
    vector2dSet startPos, Int(body(entity.objectID).fzx.position.x / tilemap.tileWidth), Int(body(entity.objectID).fzx.position.y / tilemap.tileHeight)
    vector2dSet endPosDiv, Int(endPos.x / tilemap.tileWidth), Int(endPos.y / tilemap.tileHeight)
    entity.fsmSecondary.timerState.start = Timer(.001)
    entity.fsmSecondary.timerState.duration = entity.fsmSecondary.timerState.start + entity.parameters.movementSpeed
    entity.fsmSecondary.arg3 = 1 'ARG3 in this case is used to keep track of the step in the A-star path
    entity.pathString = AStarSetPath$(entity, startPos, endPosDiv, gamemap(), tilemap)
    If Len(trim$(entity.pathString)) > 0 Then ' make sure path was created
        FSMChangeState entity.fsmPrimary, cFSM_ENTITY_MOVE
        FSMChangeState entity.fsmSecondary, cFSM_ENTITY_MOVEINIT 'Calculate next tile
    End If
End Sub

Sub handleEntitys (entity() As tENTITY, body() As tBODY, tilemap As tTILEMAP)
    Dim As Long index, iD
    Dim As _Float progress
    Dim As String dir
    For index = 0 To UBound(entity)
        iD = entity(index).objectID
        ' If entity is moving then
        '  - Primary FSM is for moving the whole trip
        '  - Secondary FSM is traversing tile to tile
        'Primary State Machine
        Select Case entity(index).fsmPrimary.currentState
            Case cFSM_ENTITY_IDLE:
            Case cFSM_ENTITY_MOVEINIT:
            Case cFSM_ENTITY_MOVE: 'Move whole trip
                'Secondary State Machine
                Select Case entity(index).fsmSecondary.currentState
                    Case cFSM_ENTITY_IDLE:
                    Case cFSM_ENTITY_MOVEINIT: 'Determine next tile
                        'pathstring is always have a length of what was initialized regardless of actual length, so we have to trim it
                        If entity(index).fsmSecondary.arg3 <= Len(trim$(entity(index).pathString)) Then
                            'extract next direction from pathstring
                            dir = Mid$(entity(index).pathString, entity(index).fsmSecondary.arg3, 1)
                            'ARG 1 will be the start position
                            entity(index).fsmSecondary.arg1 = body(iD).fzx.position
                            'ARG 2 will be the finish position
                            Select Case dir
                                Case "U":
                                    vector2dSet entity(index).fsmSecondary.arg2, body(iD).fzx.position.x, body(iD).fzx.position.y - tilemap.tileHeight
                                Case "D":
                                    vector2dSet entity(index).fsmSecondary.arg2, body(iD).fzx.position.x, body(iD).fzx.position.y + tilemap.tileHeight
                                Case "L":
                                    vector2dSet entity(index).fsmSecondary.arg2, body(iD).fzx.position.x - tilemap.tileWidth, body(iD).fzx.position.y
                                Case "R":
                                    vector2dSet entity(index).fsmSecondary.arg2, body(iD).fzx.position.x + tilemap.tileWidth, body(iD).fzx.position.y
                            End Select
                            'Center Entity on destination tile
                            entity(index).fsmSecondary.arg2.x = Int(entity(index).fsmSecondary.arg2.x / tilemap.tileWidth) * tilemap.tileWidth + (tilemap.tileWidth / 2)
                            entity(index).fsmSecondary.arg2.y = Int(entity(index).fsmSecondary.arg2.y / tilemap.tileHeight) * tilemap.tileHeight + (tilemap.tileHeight / 2)
                            'Setup movement timers
                            entity(index).fsmSecondary.timerState.start = Timer(.001)
                            entity(index).fsmSecondary.timerState.duration = entity(index).fsmSecondary.timerState.start + entity(index).parameters.movementSpeed
                            FSMChangeState entity(index).fsmSecondary, cFSM_ENTITY_MOVE
                        Else
                            'finish the trip
                            FSMChangeState entity(index).fsmPrimary, cFSM_ENTITY_IDLE
                            FSMChangeState entity(index).fsmSecondary, cFSM_ENTITY_IDLE
                        End If
                    Case cFSM_ENTITY_MOVE: 'Move between individual tiles
                        progress = scalarLERPProgress(entity(index).fsmSecondary.timerState.start, entity(index).fsmSecondary.timerState.duration)
                        vector2dLERP body(iD).fzx.position, entity(index).fsmSecondary.arg1, entity(index).fsmSecondary.arg2, progress
                        If scalarRoughEqual(progress, 1.0, .1) Then 'When done move to the next step
                            'increment to next step
                            entity(index).fsmSecondary.arg3 = entity(index).fsmSecondary.arg3 + 1
                            FSMChangeState entity(index).fsmSecondary, cFSM_ENTITY_MOVEINIT
                        End If
                End Select
        End Select
    Next
End Sub

'**********************************************************************************************
'   Camera Behavior
'**********************************************************************************************
Sub _______________CAMERA_HANDLING (): End Sub

Sub moveCamera (camera As tCAMERA, targetPosition As tVECTOR2d)
    camera.fsm.timerState.duration = 1
    camera.fsm.arg1 = camera.position
    camera.fsm.arg2 = targetPosition
    camera.fsm.arg3 = 0
    FSMChangeState camera.fsm, cFSM_CAMERA_MOVING
End Sub

Sub handleCamera (camera As tCAMERA)
    Dim As _Float progress
    Select Case camera.fsm.currentState
        Case cFSM_CAMERA_IDLE:
        Case cFSM_CAMERA_MOVING:
            progress = scalarLERPProgress(camera.fsm.timerState.start, camera.fsm.timerState.start + camera.fsm.timerState.duration)
            vector2dLERPSmoother camera.position, camera.fsm.arg1, camera.fsm.arg2, progress
            If progress > .95 Then
                FSMChangeState camera.fsm, cFSM_CAMERA_IDLE
            End If
    End Select
End Sub

'**********************************************************************************************
'   FSM Handling
'**********************************************************************************************
Sub _______________FSM_HANDLING (): End Sub

Sub FSMChangeState (fsm As tFSM, newState As Long)
    fsm.previousState = fsm.currentState
    fsm.currentState = newState
    fsm.timerState.start = Timer(.001)
End Sub

Sub FSMChangeStateEx (fsm As tFSM, newState As Long, arg1 As tVECTOR2d, arg2 As tVECTOR2d, arg3 As Long)
    fsm.previousState = fsm.currentState
    fsm.currentState = newState
    fsm.arg1 = arg1
    fsm.arg2 = arg2
    fsm.arg3 = arg3
End Sub

Sub FSMChangeStateOnTimer (fsm As tFSM, newstate As Long)
    If Timer(.001) > fsm.timerState.start + fsm.timerState.duration Then
        FSMChangeState fsm, newstate
    End If
End Sub


'**********************************************************************************************
'   Rendering
'**********************************************************************************************
Sub _______________RENDERING (): End Sub
Sub renderBodies (engine As tENGINE, p() As tPOLY, body() As tBODY, j() As tJOINT, hits() As tHIT, camera As tCAMERA)
    Dim As Long i, layer
    Dim hitcount As Long
    Dim As tVECTOR2d viewPortSize, viewPortCenter, camUpLeft, BB

    clearScreen engine

    vector2dSet viewPortSize, _Width, _Height
    vector2dSet viewPortCenter, _Width / 2.0, _Height / 2.0
    vector2dSubVectorND camUpLeft, camera.position, viewPortCenter
    For layer = 3 To 0 Step -1 ' Crude layering from rear to front
        For i = 0 To UBound(body) - 1
            If body(i).shape.renderOrder = layer Then
                If body(i).enable Then
                    'AABB to cut down on rendering objects out of camera view
                    vector2dAddVectorND BB, body(i).fzx.position, camera.AABB
                    If AABBOverlap(camUpLeft.x, camUpLeft.y, viewPortSize.x, viewPortSize.y, BB.x, BB.y, camera.AABB_size.x, camera.AABB_size.y) Then
                        If body(i).shape.ty = cSHAPE_CIRCLE Then
                            If body(i).specFunc.func = 0 Then '0-normal 1-sensor
                                If body(i).shape.texture = 0 Then
                                    If cRENDER_WIREFRAME Then renderWireframeCircle body(), i, camera
                                Else
                                    renderTexturedCircle body(), i, camera
                                End If
                            Else
                                If cRENDER_WIREFRAME Then renderWireframeCircle body(), i, camera
                                _Dest engine.hiddenScr
                                renderTexturedCircle body(), i, camera
                                _Dest 0
                            End If
                        Else If body(i).shape.ty = cSHAPE_POLYGON Then
                                If body(i).specFunc.func = 0 Then
                                    If body(i).shape.texture = 0 Then
                                        If cRENDER_WIREFRAME Then renderWireframePoly p(), body(), i, camera
                                    Else
                                        renderTexturedBox p(), body(), i, camera
                                    End If
                                Else
                                    If cRENDER_WIREFRAME Then renderWireframePoly p(), body(), i, camera
                                    _Dest engine.hiddenScr
                                    renderTexturedBox p(), body(), i, camera
                                    _Dest 0
                                End If
                            End If
                        End If
                        If cRENDER_AABB Then
                            Dim As tVECTOR2d am, mm
                            am.x = scalarMax(body(i).shape.maxDimension.x, body(i).shape.maxDimension.y) / 2
                            am.y = scalarMax(body(i).shape.maxDimension.x, body(i).shape.maxDimension.y) / 2
                            vector2dNegND mm, am
                            worldToCameraBodyNR body(), camera, i, am
                            worldToCameraBodyNR body(), camera, i, mm
                            Line (am.x, am.y)-(mm.x, mm.y), _RGB(0, 255, 0), B
                            Circle (am.x, am.y), 5
                        End If
                    End If
                End If
            End If
        Next
    Next
    If cRENDER_JOINTS Then
        For i = 1 To UBound(j)
            renderJoints j(i), body(), camera
        Next
    End If
    If cRENDER_COLLISIONS Then
        hitcount = 0
        Do While hits(hitcount).A <> hits(hitcount).B
            renderWireframeCircleVector hits(hitcount).position, camera
            hitcount = hitcount + 1
            If hitcount > UBound(hits) Then Exit Do
        Loop
    End If
End Sub

Sub initScreen (engine As tENGINE, w As Long, h As Long, bbp As Long)
    _Delay .5 ' Keeps from segfaulting when starting
    engine.displayScr = _NewImage(w, h, bbp)
    engine.hiddenScr = _NewImage(w, h, bbp)
    Screen engine.displayScr
End Sub

Sub clearScreen (engine As tENGINE)
    _Dest engine.displayScr
    _PrintMode _KeepBackground
    Cls , engine.displayClearColor
    _Dest engine.hiddenScr
    Cls , 0
    _Dest engine.displayScr
End Sub

Sub renderJoints (j As tJOINT, b() As tBODY, camera As tCAMERA)
    Dim v1 As tVECTOR2d
    Dim v2 As tVECTOR2d
    worldToCameraBody b(), camera, j.body1, v1
    worldToCameraBody b(), camera, j.body2, v2
    Line (v1.x, v1.y)-(v2.x, v2.y), j.wireframe_color
End Sub

Sub renderWireframePoly (p() As tPOLY, b() As tBODY, index As Long, camera As tCAMERA)
    Dim a As tVECTOR2d ' dummy vertices
    Dim b As tVECTOR2d

    Dim i, element, element_next As Long
    For i = 0 To b(index).pa.count
        element = b(index).pa.start + i
        element_next = b(index).pa.start + arrayNextIndex(i, b(index).pa.count)
        a = p(element).vert
        b = p(element_next).vert
        worldToCameraBody b(), camera, index, a
        worldToCameraBody b(), camera, index, b
        Line (a.x, a.y)-(b.x, b.y), b(index).c
    Next
End Sub

Sub renderTexturedBox (p() As tPOLY, b() As tBODY, index As Long, camera As tCAMERA)
    Dim vert(3) As tVECTOR2d

    Dim As Single W, H
    Dim bm As Long ' Texture map
    bm = b(index).shape.texture
    W = _Width(bm): H = _Height(bm)

    Dim i As Long
    For i = 0 To 3
        vert(i) = p(b(index).pa.start + i).vert
        vert(i).x = vert(i).x + b(index).shape.offsetTextureX
        vert(i).y = vert(i).y + b(index).shape.offsetTextureY
        vert(i).x = vert(i).x * b(index).shape.scaleTextureX
        vert(i).y = vert(i).y * b(index).shape.scaleTextureY
        worldToCameraBody b(), camera, index, vert(i)
    Next

    If b(index).fzx.velocity.x > 1 Or b(index).shape.flipTexture = 0 Then
        _MapTriangle (0, 0)-(W - 1, 0)-(W - 1, H - 1), bm To(vert(3).x, vert(3).y)-(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)
        _MapTriangle (0, 0)-(0, H - 1)-(W - 1, H - 1), bm To(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y)-(vert(1).x, vert(1).y)
    Else
        _MapTriangle (0, 0)-(W - 1, 0)-(W - 1, H - 1), bm To(vert(0).x, vert(0).y)-(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y)
        _MapTriangle (0, 0)-(0, H - 1)-(W - 1, H - 1), bm To(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)-(vert(2).x, vert(2).y)
    End If

End Sub

Sub renderWireframeCircle (b() As tBODY, index As Long, camera As tCAMERA)
    Dim tv As tVECTOR2d
    worldToCameraBody b(), camera, index, tv
    Circle (tv.x, tv.y), b(index).shape.radius * camera.zoom, b(index).c
LINE (tv.x, tv.y)-(tv.x + COS(b(index).fzx.orient) * (b(index).shape.radius * camera.zoom), _
tv.y + SIN(b(index).fzx.orient) * (b(index).shape.radius) * camera.zoom), b(index).c
End Sub

Sub renderWireframeCircleVector (in As tVECTOR2d, camera As tCAMERA)
    Dim tv As tVECTOR2d
    worldToCamera camera, in, tv
    Circle (tv.x, tv.y), 2.0 * camera.zoom, _RGB(127, 127, 0)
End Sub

Sub renderTexturedCircle (b() As tBODY, index As Long, camera As tCAMERA)
    Dim vert(3) As tVECTOR2d
    Dim W, H As Long
    Dim bm As Long
    bm = b(index).shape.texture
    W = _Width(bm): H = _Height(bm)
    vector2dSet vert(0), -b(index).shape.radius, -b(index).shape.radius
    vector2dSet vert(1), -b(index).shape.radius, b(index).shape.radius
    vector2dSet vert(2), b(index).shape.radius, b(index).shape.radius
    vector2dSet vert(3), b(index).shape.radius, -b(index).shape.radius
    Dim i As Long
    For i = 0 To 3
        worldToCameraBody b(), camera, index, vert(i)
    Next
    _MapTriangle (0, 0)-(0, H - 1)-(W - 1, H - 1), bm To(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)-(vert(2).x, vert(2).y)
    _MapTriangle (0, 0)-(W - 1, 0)-(W - 1, H - 1), bm To(vert(0).x, vert(0).y)-(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y)
End Sub

Sub mapImage (src As Long, dest As Long, p As tVECTOR2d, bitmask As Long)
    Dim As tVECTOR2d srcVert(3), vert(3)
    Dim As Long w, h, bitMaskHorz, bitMaskVert, bitMaskXYYX
    w = _Width(src): h = _Height(src)
    vector2dSet vert(0), p.x, p.y
    vector2dSet vert(1), p.x + w, p.y
    vector2dSet vert(2), p.x + w, p.y + h
    vector2dSet vert(3), p.x, p.y + h

    vector2dSet srcVert(0), 0, 0
    vector2dSet srcVert(1), w - 1, 0
    vector2dSet srcVert(2), w - 1, h - 1
    vector2dSet srcVert(3), 0, h - 1

    bitMaskHorz = _ShR(bitmask, 31) And 1
    bitMaskVert = _ShR(bitmask, 30) And 1
    bitMaskXYYX = _ShR(bitmask, 29) And 1

    If bitMaskXYYX Then
        vector2dSwap srcVert(1), srcVert(3)
    End If

    If bitMaskHorz Then
        vector2dSwap srcVert(0), srcVert(1)
        vector2dSwap srcVert(2), srcVert(3)
    End If

    If bitMaskVert Then
        vector2dSwap srcVert(0), srcVert(3)
        vector2dSwap srcVert(1), srcVert(2)
    End If

_MAPTRIANGLE (srcVert(0).x, srcVert(0).y)-(srcVert(1).x, srcVert(1).y)-(srcVert(2).x, srcVert(2).y), _
src TO(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)-(vert(2).x, vert(2).y), dest
_MAPTRIANGLE (srcVert(0).x, srcVert(0).y)-(srcVert(3).x, srcVert(3).y)-(srcVert(2).x, srcVert(2).y), _
src TO(vert(0).x, vert(0).y)-(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y), dest

End Sub

Sub alphaImage (alpha As Integer, image As Long, p As tVECTOR2d, scale As _Float)
    _SetAlpha alpha, 0 To _RGB(255, 255, 255), image
    _ClearColor _RGB(0, 0, 0), image
    _PutImage (p.x, p.y)-(p.x + (_Width(image) * scale), p.y + (_Height(image) * scale)), image
End Sub

Sub createLightingMask (engine As tENGINE, tile() As tTILE, xs As Long, ys As Long)
    engine.displayMask = allocateTextureEX(tile(), _NewImage(xs, ys, 32))
    Dim As Long position, maxdist
    Dim As tVECTOR2d p, c, z
    Dim As _Unsigned _Byte dist
    Dim As _MEM buffer
    Dim As _Offset offset, lastOffset
    buffer = _MemImage(tile(engine.displayMask).t)
    offset = buffer.OFFSET
    lastOffset = buffer.OFFSET + xs * ys * 4
    position = 0
    c.x = xs / 2
    c.y = ys / 2
    z.x = 0
    z.y = 0
    maxdist = Int(vector2dDistance(c, z))
    Do
        p.x = position Mod xs
        p.y = Int(position / xs)
        dist = impulseClamp(0, 255, vector2dDistance(p, c) / maxdist * 255.0)
        _MemPut buffer, offset + 0, &H00 As _UNSIGNED _BYTE
        _MemPut buffer, offset + 1, &H00 As _UNSIGNED _BYTE
        _MemPut buffer, offset + 2, &H00 As _UNSIGNED _BYTE
        _MemPut buffer, offset + 3, dist As _UNSIGNED _BYTE 'Alpha channel
        position = position + 1
        offset = offset + 4
    Loop Until offset = lastOffset
    _MemFree buffer
End Sub

Sub colorMixBitmap (img As Long, rgb As Long, amount As _Float)
    Dim As _Unsigned _Byte r, g, b, nr, ng, nb
    Dim As _MEM buffer
    Dim As _Offset offset, lastOffset
    buffer = _MemImage(img)
    offset = buffer.OFFSET
    lastOffset = buffer.OFFSET + _Width(img) * _Height(img) * 4
    $Checking:Off
    Do
        r = _MemGet(buffer, offset + 0, _Unsigned _Byte)
        g = _MemGet(buffer, offset + 1, _Unsigned _Byte)
        b = _MemGet(buffer, offset + 2, _Unsigned _Byte)
        nr = colorChannelMixer(r, _Red(rgb), amount)
        ng = colorChannelMixer(g, _Green(rgb), amount)
        nb = colorChannelMixer(b, _Blue(rgb), amount)
        _MemPut buffer, offset + 0, nr As _UNSIGNED _BYTE
        _MemPut buffer, offset + 1, ng As _UNSIGNED _BYTE
        _MemPut buffer, offset + 2, nb As _UNSIGNED _BYTE
        offset = offset + 4
    Loop Until offset = lastOffset
    $Checking:On
    _MemFree buffer

End Sub

'**********************************************************************************************
'   Texture Loading
'**********************************************************************************************
Sub _______________TEXTURE_HANDLING (): End Sub

Function allocateTexture (tile() As tTILE)
    allocateTexture = UBound(tile)
    ReDim _Preserve tile(UBound(tile) + 1) As tTILE
End Function

Function allocateTextureEX (tile() As tTILE, img As Long)
    tile(UBound(tile)).t = img
    allocateTextureEX = UBound(tile)
    ReDim _Preserve tile(UBound(tile) + 1) As tTILE
End Function

Sub loadBitmapError (tile() As tTILE, index As Long, fl As String)
    If tile(index).t > -2 Then
        Print "Unable to load image "; fl; " with return of "; tile(index).t
        End
    End If
End Sub

Sub tileMapImagePosition (tile As Long, t As tTILEMAP, sx1 As Long, sy1 As Long, sx2 As Long, sy2 As Long)
    Dim tile_width As Long
    Dim tile_height As Long
    Dim tile_x, tile_y As Long

    tile_width = t.tileSize + t.tilePadding
    tile_height = t.tileSize + t.tilePadding

    tile_x = tile Mod t.numberOfTilesX
    tile_y = Int(tile / t.numberOfTilesX)

    sx1 = tile_x * tile_width
    sy1 = tile_y * tile_height

    sx2 = sx1 + t.tileSize - t.tilePadding
    sy2 = sy1 + t.tileSize - t.tilePadding
End Sub

Function idToTile (t() As tTILE, id As Long)
    Dim As Long index
    For index = 0 To UBound(t)
        If t(index).id = id Then
            idToTile = index
            Exit Function
        End If
    Next
    idToTile = -1
End Function

Sub freeImageEX (tile() As tTILE, img As Long)
    If img < -1 Then
        Dim As Long i, j
        For i = 0 To UBound(tile) - 1
            If tile(i).t = img Then
                For j = i To UBound(tile) - 1
                    tile(j) = tile(j + 1)
                Next
                If UBound(tile) > 0 Then ReDim _Preserve tile(UBound(tile) - 1) As tTILE
                If img < -1 Then _FreeImage img
                Exit Sub
            End If
        Next
    End If
End Sub

Sub freeAllTiles (tile() As tTILE)
    Do While UBound(tile)
        If tile(UBound(tile) - 1).t < -1 Then
            freeImageEX tile(), tile(UBound(tile) - 1).t
        Else
            ReDim _Preserve tile(UBound(tile) - 1) As tTILE
        End If
    Loop
End Sub

'**********************************************************************************************
'   TMX Loading
' Related functions are in XML Section
'**********************************************************************************************

Sub _______________TMX_FILE_HANDLING (): End Sub

Sub loadFile (fl As String, in() As String)
    fl = LTrim$(RTrim$(fl)) 'clean the filename
    Dim As Long file_num
    If _FileExists(fl) Then
        file_num = FreeFile
        Open fl For Input As #file_num
        Do Until EOF(file_num)
            Line Input #file_num, in(UBound(in))
            ReDim _Preserve in(UBound(in) + 1) As String
        Loop
        Close file_num
    Else
        Print "File not found :"; fl
        End
    End If
End Sub

Sub loadTSX (dir As String, tile() As tTILE, tilemap As tTILEMAP, firstid As Long)
    Dim As String tsx(0), i
    Dim As Long img, index, id, arg

    loadFile dir + tilemap.tsxFile, tsx()
    For index = 0 To UBound(tsx)
        i = tsx(index)
        If InStr(i, "<tileset") Then
            tilemap.numberOfTilesX = getXMLArgValue(i, "columns=")
            tilemap.tileCount = getXMLArgValue(i, "tilecount=")
            tilemap.tilePadding = 0
        End If
        If InStr(i, "<image source=") Then
            tilemap.file = getXMLArgString$(i, "<image source=")
            img = allocateTextureEX(tile(), _LoadImage(RTrim$(LTrim$(dir + tilemap.file))))
            tilemap.tileMap = tile(img).t
            loadBitmapError tile(), img, dir + tilemap.file
            loadTilesIntoBuffer tile(), tilemap, firstid
        End If
        If InStr(i, "<tile ") Then
            id = idToTile(tile(), getXMLArgValue(i, "id="))
            tile(id).class = getXMLArgString$(i, "type=")
            If InStr(tile(id).class, "CHARACTER") Then
                index = index + 1: i = tsx(index)
                If InStr(i, "<properties>") Then
                    index = index + 1: i = tsx(index)
                    Do
                        If InStr(i, "<property ") Then
                            If getXMLArgString$(i, "name=") = "CHAR" Then
                                arg = Asc(getXMLArgString$(i, "value="))
                                tileFont(arg).id = id + 2 ' No Idea why this is off
                                tileFont(arg).t = tile(idToTile(tile(), tileFont(arg).id)).t
                                tileFont(arg).c = arg
                            End If
                        End If
                        index = index + 1: i = tsx(index)
                    Loop Until InStr(i, "/")
                End If
            End If
        End If
    Next
End Sub

Sub loadTilesIntoBuffer (tile() As tTILE, tilemap As tTILEMAP, firstid As Long)
    Dim As Long textmapCount
    Dim As Long x1, y1, x2, y2, index

    For index = 0 To tilemap.tileCount - 1
        textmapCount = allocateTextureEX(tile(), _NewImage(tilemap.tileWidth, tilemap.tileHeight, 32))
        tileMapImagePosition index, tilemap, x1, y1, x2, y2
        _PutImage (0, 0), tilemap.tileMap, tile(textmapCount).t, (x1, y1)-(x2, y2)
        tile(textmapCount).id = firstid + index
    Next
    freeImageEX tile(), tilemap.tileMap
End Sub

'**********************************************************************************************
'   Construct Game Map
'**********************************************************************************************
Sub _______________CONSTRUCT_GAMEMAP (): End Sub

Sub constructGameMap (engine As tENGINE, p() As tPOLY, body() As tBODY, gamemap() As tTILE, tile() As tTILE, tilemap As tTILEMAP, lights() As tLIGHT)
    Dim As Long xs, ys, tempID, backgroundImageID
    xs = tilemap.mapWidth * tilemap.tileWidth * tilemap.tilescale
    ys = tilemap.mapHeight * tilemap.tileHeight * tilemap.tilescale

    tempID = createBoxBodyEx(p(), body(), "_BACKGROUND", xs / 2, ys / 2)
    setBody p(), body(), cPARAMETER_POSITION, tempID, xs / 2, xs / 2
    setBody p(), body(), cPARAMETER_ORIENT, tempID, 0, 0
    setBody p(), body(), cPARAMETER_STATIC, tempID, 1, 0
    setBody p(), body(), cPARAMETER_COLLISIONMASK, tempID, 0, 0
    setBody p(), body(), cPARAMETER_NOPHYSICS, tempID, 1, 0
    setBody p(), body(), cPARAMETER_RENDERORDER, tempID, 3, 0
    backgroundImageID = allocateTextureEX(tile(), _NewImage(tilemap.tileWidth * tilemap.mapWidth, tilemap.tileHeight * tilemap.mapHeight, 32))
    Cls , engine.displayClearColor

    applyGameMapToBody engine, gamemap(), tile(), tilemap, tile(backgroundImageID).t, lights()
    setBody p(), body(), cPARAMETER_TEXTURE, tempID, tile(backgroundImageID).t, 0
End Sub

Sub addLightsToGamemap (gamemap() As tTILE, tilemap As tTILEMAP, lights() As tLIGHT)
    Dim As Long index
    For index = 0 To UBound(lights) - 1
        gamemap(xyToGameMap(tilemap, lights(index).position.x, lights(index).position.y)).lightColor = lights(index).lightColor
    Next
End Sub

Function createLightingMask (engine As tENGINE, tile() As tTILE, tilemap As tTILEMAP, lights() As tLIGHT)
    Dim As Long img, index, x, y, lc, flatPos, W, dx, dy, vlq
    Dim As _Float dist, maxDist
    ' DIM AS tVECTOR2d current
    maxDist = tilemap.tileWidth * engine.mapParameters.maxLightDistance ' Maximum Light influence
    img = allocateTextureEX(tile(), _NewImage(tilemap.tileWidth * tilemap.mapWidth, tilemap.tileHeight * tilemap.mapHeight, 32))
    Dim As _MEM buffer
    Dim As _Offset offset, lastOffset
    buffer = _MemImage(tile(img).t)
    offset = buffer.OFFSET
    lastOffset = buffer.OFFSET + _Width(tile(img).t) * _Height(tile(img).t) * 4
    flatPos = 0
    Print #logfile, Timer(.001)
    $Checking:Off
    W = _Width(tile(img).t)
    Do
        x = flatPos Mod W
        y = Int(flatPos / W)
        lc = 0
        For index = 0 To UBound(lights) - 1
            dx = x - lights(index).position.x
            dy = y - lights(index).position.y
            vlq = dx * dx + dy * dy
            If vlq < maxDist * maxDist Then
                dist = Sqr(vlq)
                lc = colorMixer(lights(index).lightColor, lc, impulseClamp(0, 1, (maxDist / dist) / UBound(lights) * .2))
                _MemPut buffer, offset + 0, _Blue(lc) As _UNSIGNED _BYTE
                _MemPut buffer, offset + 1, _Green(lc) As _UNSIGNED _BYTE
                _MemPut buffer, offset + 2, _Red(lc) As _UNSIGNED _BYTE
                _MemPut buffer, offset + 3, _Alpha(lc) As _UNSIGNED _BYTE
            End If
        Next
        offset = offset + 4
        flatPos = flatPos + 1
    Loop Until offset = lastOffset
    $Checking:On
    createLightingMask = img
    _MemFree buffer
    Print #logfile, Timer(.001)
End Function

Sub refreshGameMap (engine As tENGINE, body() As tBODY, gamemap() As tTILE, tile() As tTILE, tilemap As tTILEMAP, lights() As tLIGHT)
    Dim As Long xs, ys, tempID, backgroundImageID
    xs = tilemap.mapWidth * tilemap.tileWidth * tilemap.tilescale
    ys = tilemap.mapHeight * tilemap.tileHeight * tilemap.tilescale
    tempID = bodyManagerID(body(), "_BACKGROUND")
    If tempID > -1 Then
        backgroundImageID = body(tempID).shape.texture
        _Dest backgroundImageID
        Cls , engine.displayClearColor
        _Dest 0
        applyGameMapToBody engine, gamemap(), tile(), tilemap, backgroundImageID, lights()
    End If
End Sub

Sub applyGameMapToBody (engine As tENGINE, gamemap() As tTILE, tile() As tTILE, tilemap As tTILEMAP, backGroundImageID As Long, lights() As tLIGHT)
    Dim As Long x, y
    Dim As Long lightmask, bgc, lmc

    buildMultiTileMap gamemap(), tile(), tilemap, backGroundImageID, 0

    lightmask = createLightingMask(engine, tile(), tilemap, lights())
    For y = 0 To _Height(tile(lightmask).t)
        For x = 0 To _Width(tile(lightmask).t)
            _Source tile(lightmask).t
            lmc = Point(x, y)
            _Source backGroundImageID
            _Dest backGroundImageID
            bgc = Point(x, y)
            PSet (x, y), colorMixer(lmc, bgc, .75)
        Next
    Next
    freeImageEX tile(), lightmask
    _Source 0
    _Dest 0
End Sub

Sub buildMultiTileMap (map() As tTILE, tile() As tTILE, layout As tTILEMAP, img As Long, layer As Integer)
    Dim As Long index
    Dim As Long sx, tileId, bitMaskLo, tileLayer
    Dim As tVECTOR2d p
    sx = layout.tilescale * layout.tileSize
    For index = 0 To UBound(map)
        If layer = 0 Then
            tileLayer = map(index).t
        Else
            tileLayer = map(index).t0
        End If
        If tileLayer <> 0 Then
            bitMaskLo = tileLayer And &H00FFFFFF 'Extract actual Tile ID number
            p.x = (index Mod layout.mapWidth) * sx
            p.y = Int(index / layout.mapWidth) * sx
            tileId = idToTile(tile(), bitMaskLo)
            mapImage tile(tileId).t, img, p, tileLayer
        End If
    Next
End Sub

'**********************************************************************************************
'   Camera and World Translation subs
'**********************************************************************************************
Sub _______________CAMERA_TRANSLATE_SUBS (): End Sub
Sub worldToCamera (camera As tCAMERA, iVert As tVECTOR2d, oVert As tVECTOR2d)
    Dim screenCenter As tVECTOR2d
    vector2dSet screenCenter, _Width / 2 * (1 / camera.zoom), _Height / 2 * (1 / camera.zoom) ' Camera Center
    vector2dAddVector oVert, iVert ' Add Position
    vector2dSubVector oVert, camera.position 'Sub Camera Position
    vector2dAddVector oVert, screenCenter ' Add to camera Center
    vector2dMultiplyScalar oVert, camera.zoom 'Zoom everything
End Sub

Sub worldToCameraBody (body() As tBODY, camera As tCAMERA, index As Long, vert As tVECTOR2d)
    Dim screenCenter As tVECTOR2d
    vector2dSet screenCenter, _Width / 2 * (1 / camera.zoom), _Height / 2 * (1 / camera.zoom) ' Camera Center
    matrix2x2MultiplyVector body(index).shape.u, vert, vert ' Rotate body
    vector2dAddVector vert, body(index).fzx.position ' Add Position
    vector2dSubVector vert, camera.position 'Sub Camera Position
    vector2dAddVector vert, screenCenter ' Add to Screen Center
    vector2dMultiplyScalar vert, camera.zoom 'Zoom everything
End Sub

Sub worldToCameraBodyNR (body() As tBODY, camera As tCAMERA, index As Long, vert As tVECTOR2d)
    Dim screenCenter As tVECTOR2d
    vector2dSet screenCenter, _Width / 2 * (1 / camera.zoom), _Height / 2 * (1 / camera.zoom) ' Camera Center
    vector2dAddVector vert, body(index).fzx.position ' Add Position
    vector2dSubVector vert, camera.position 'Sub Camera Position
    vector2dAddVector vert, screenCenter ' Add to camera Center
    vector2dMultiplyScalar vert, camera.zoom 'Zoom everything
End Sub

Sub cameraToWorld (camera As tCAMERA, iVec As tVECTOR2d, oVec As tVECTOR2d)
    Dim As tVECTOR2d screenCenter
    vector2dSet screenCenter, _Width / 2.0 * (1 / camera.zoom), _Height / 2.0 * (1 / camera.zoom) ' Camera Center
    vector2dSet oVec, iVec.x * (1 / camera.zoom), iVec.y * (1 / camera.zoom)
    vector2dAddVector oVec, camera.position
    vector2dSubVector oVec, screenCenter
End Sub

'**********************************************************************************************
'   GUI Handling
'**********************************************************************************************

Sub _______________GUI_MESSAGE_HANDLING (): End Sub
Sub prepMessage (tile() As tTILE, tilemap As tTILEMAP, message As tMESSAGE, messageString As String)
    Dim As Long i, numberOfLines, linelengthCount, longestLine, ch
    Dim As tVECTOR2d cursor
    numberOfLines = 1
    longestLine = 1
    'prescanline to determine dimensions
    For i = 1 To Len(messageString)
        linelengthCount = linelengthCount + 1
        ch = Asc(Mid$(messageString, i, 1))
        If ch = 95 Then ' check for underscore
            numberOfLines = numberOfLines + 1
            If linelengthCount > longestLine Then longestLine = linelengthCount
            linelengthCount = 0
        End If
    Next
    If linelengthCount > longestLine Then longestLine = linelengthCount
    message.baseImage = allocateTextureEX(tile(), _NewImage(longestLine * tilemap.tileWidth, numberOfLines * tilemap.tileHeight, 32))
    _Dest tile(message.baseImage).t
    For i = 1 To Len(messageString)
        ch = Asc(Mid$(UCase$(messageString), i, 1))
        If ch = 95 Then
            cursor.x = 0
            cursor.y = cursor.y + tilemap.tileHeight
        Else
            _PutImage (cursor.x, cursor.y), tileFont(ch).t, tile(message.baseImage).t
            cursor.x = cursor.x + tilemap.tileWidth
        End If
    Next
    _Dest 0
End Sub

Sub addMessage (tile() As tTILE, tilemap As tTILEMAP, message() As tMESSAGE, messageString As String, timeOut As Long, position As tVECTOR2d, scale As _Float)
    Dim As Long m
    ReDim _Preserve message(UBound(message) + 1) As tMESSAGE
    m = UBound(message)
    prepMessage tile(), tilemap, message(m), messageString
    message(m).fsm.timerState.duration = timeOut
    message(m).position = position
    message(m).scale = scale
    FSMChangeState message(m).fsm, cFSM_MESSAGE_INIT
End Sub

Sub handleMessages (tile() As tTILE, message() As tMESSAGE)
    Dim As Long alpha, i
    i = UBound(message)
    If i > 0 Then
        Select Case message(i).fsm.currentState
            Case cFSM_MESSAGE_IDLE:
            Case cFSM_MESSAGE_INIT:
                FSMChangeState message(i).fsm, cFSM_MESSAGE_FADEIN
            Case cFSM_MESSAGE_FADEIN:
                alpha = scalarLERPSmoother##(0, 255, scalarLERPProgress(message(i).fsm.timerState.start, message(i).fsm.timerState.start + (message(i).fsm.timerState.duration * .1)))
                alphaImage alpha, tile(message(i).baseImage).t, message(i).position, message(i).scale
                FSMChangeStateOnTimer message(i).fsm, cFSM_MESSAGE_SHINE
            Case cFSM_MESSAGE_SHINE:
                alphaImage 255, tile(message(i).baseImage).t, message(i).position, message(i).scale
                FSMChangeStateOnTimer message(i).fsm, cFSM_MESSAGE_FADEOUT
            Case cFSM_MESSAGE_FADEOUT:
                alpha = scalarLERPSmoother##(255, 0, scalarLERPProgress(message(i).fsm.timerState.start, message(i).fsm.timerState.start + (message(i).fsm.timerState.duration * .1)))
                alphaImage alpha, tile(message(i).baseImage).t, message(i).position, message(i).scale
                FSMChangeStateOnTimer message(i).fsm, cFSM_MESSAGE_CLEANUP
            Case cFSM_MESSAGE_CLEANUP:
                freeImageEX tile(), tile(message(i).baseImage).t
                removeMessage message(), i
                'No need to change back to IDLE since we are deleting this message
            Case Else
                'Nada
        End Select
    End If
End Sub

Sub removeMessage (message() As tMESSAGE, i As Long)
    Dim As Long j
    If i < UBound(message) Then
        For j = i To UBound(message) - 1
            message(j) = message(j + 1)
        Next
    End If
    If UBound(message) > 0 Then ReDim _Preserve message(UBound(message) - 1) As tMESSAGE
End Sub

'**********************************************************************************************
'   A* Path Finding
'  Needs Proper Integration
'**********************************************************************************************

Sub _______________A_STAR_PATHFINDING (): End Sub

Function AStarSetPath$ (entity As tENTITY, startPos As tVECTOR2d, TargetPos As tVECTOR2d, gamemap() As tTILE, tilemap As tTILEMAP)
IF TargetPos.x >= 0 AND TargetPos.x <= tilemap.mapWidth AND _
TargetPos.y >= 0 AND TargetPos.y <= tilemap.mapHeight AND _
AStarCollision(gamemap(), tilemap, targetpos) THEN
        Dim TargetFound As Long
        Dim PathMap(tilemap.mapWidth * tilemap.mapHeight) As tPATH
        Dim maxpathlength As Long
        Dim ix, iy, count, i As Long
        Dim NewG As Long
        Dim OpenPathCount As Long
        Dim LowF As Long
        Dim ixOptimal, iyOptimal, OptimalPath_i As Long
        Dim startreached As Long
        Dim pathlength As Long
        Dim As String pathString
        Dim As tVECTOR2d currPos, nextPos
        Dim As tVECTOR2d startPosition
        maxpathlength = tilemap.mapWidth * tilemap.mapHeight
        Dim SearchPathSet(4) As tPATH, OpenPathSet(maxpathlength) As tPATH
        startPosition = startPos

        For ix = 0 To tilemap.mapWidth - 1
            For iy = 0 To tilemap.mapHeight - 1
                PathMap(xyToGameMapPlain(tilemap, ix, iy)).position.x = ix
                PathMap(xyToGameMapPlain(tilemap, ix, iy)).position.y = iy
            Next
        Next
        TargetFound = 0

        Do
            PathMap(xyToGameMapPlain(tilemap, startPosition.x, startPosition.y)).status = 2
            count = count + 1

            If PathMap(xyToGameMapPlain(tilemap, TargetPos.x, TargetPos.y)).status = 2 Then TargetFound = 1: Exit Do
            If count > maxpathlength Then Exit Do

            SearchPathSet(0) = PathMap(xyToGameMapPlain(tilemap, startPosition.x, startPosition.y))
            If startPosition.x < tilemap.mapWidth Then SearchPathSet(1) = PathMap(xyToGameMapPlain(tilemap, startPosition.x + 1, startPosition.y))
            If startPosition.x > 0 Then SearchPathSet(2) = PathMap(xyToGameMapPlain(tilemap, startPosition.x - 1, startPosition.y))
            If startPosition.y < tilemap.mapHeight Then SearchPathSet(3) = PathMap(xyToGameMapPlain(tilemap, startPosition.x, startPosition.y + 1))
            If startPosition.y > 0 Then SearchPathSet(4) = PathMap(xyToGameMapPlain(tilemap, startPosition.x, startPosition.y - 1))

            For i = 1 To 4
                If AStarCollision(gamemap(), tilemap, SearchPathSet(i).position) Then

                    If SearchPathSet(i).status = 1 Then
                        NewG = AStarPathGCost(SearchPathSet(0).g)
                        If NewG < SearchPathSet(i).g Then SearchPathSet(i).g = NewG
                    End If

                    If SearchPathSet(i).status = 0 Then
                        SearchPathSet(i).parent = SearchPathSet(0).position
                        SearchPathSet(i).status = 1
                        SearchPathSet(i).g = AStarPathGCost(SearchPathSet(0).g)
                        SearchPathSet(i).h = AStarPathHCost(SearchPathSet(i), TargetPos, entity)
                        SearchPathSet(i).f = SearchPathSet(i).g + SearchPathSet(i).h + (AStarWalkway(gamemap(), tilemap, SearchPathSet(i).position) * 10)
                        OpenPathSet(OpenPathCount) = SearchPathSet(i)
                        OpenPathCount = OpenPathCount + 1
                    End If
                End If
            Next

            If startPosition.x < tilemap.mapWidth Then PathMap(xyToGameMapPlain(tilemap, startPosition.x + 1, startPosition.y)) = SearchPathSet(1)
            If startPosition.x > 0 Then PathMap(xyToGameMapPlain(tilemap, startPosition.x - 1, startPosition.y)) = SearchPathSet(2)
            If startPosition.y < tilemap.mapHeight Then PathMap(xyToGameMapPlain(tilemap, startPosition.x, startPosition.y + 1)) = SearchPathSet(3)
            If startPosition.y > 0 Then PathMap(xyToGameMapPlain(tilemap, startPosition.x, startPosition.y - 1)) = SearchPathSet(4)

            If OpenPathCount > (maxpathlength - 4) Then Exit Do

            LowF = 32000: ixOptimal = 0: iyOptimal = 0
            For i = 0 To OpenPathCount
                If OpenPathSet(i).status = 1 And OpenPathSet(i).f <> 0 Then
                    If OpenPathSet(i).f < LowF Then
                        LowF = OpenPathSet(i).f
                        ixOptimal = OpenPathSet(i).position.x
                        iyOptimal = OpenPathSet(i).position.y
                        OptimalPath_i = i
                    End If
                End If
            Next

            If ixOptimal = 0 And iyOptimal = 0 Then Exit Do
            startPosition = PathMap(xyToGameMapPlain(tilemap, ixOptimal, iyOptimal)).position
            OpenPathSet(OptimalPath_i).status = 2
        Loop

        If TargetFound = 1 Then

            Dim backpath(maxpathlength) As tPATH
            backpath(0).position = PathMap(xyToGameMapPlain(tilemap, TargetPos.x, TargetPos.y)).position

            startreached = 0
            For i = 1 To count
                backpath(i).position = PathMap(xyToGameMapPlain(tilemap, backpath(i - 1).position.x, backpath(i - 1).position.y)).parent
                If (startreached = 0) And (backpath(i).position.x = startPosition.x) And (backpath(i).position.y = startPosition.y) Then
                    pathlength = i: startreached = 1
                End If
            Next

            pathString = ""
            For i = count To 1 Step -1
                If backpath(i).position.x > 0 And backpath(i).position.x < tilemap.mapWidth And backpath(i).position.y > 0 And backpath(i).position.y < tilemap.mapHeight Then
                    currPos = backpath(i).position
                    nextPos = backpath(i - 1).position
                    If nextPos.x < currPos.x Then pathString = pathString + "L"
                    If nextPos.x > currPos.x Then pathString = pathString + "R"
                    If nextPos.y < currPos.y Then pathString = pathString + "U"
                    If nextPos.y > currPos.y Then pathString = pathString + "D"
                End If
            Next
        End If
        AStarSetPath = pathString
    End If
End Function

Function AStarPathGCost (ParentG)
    AStarPathGCost = ParentG + 10
End Function

Function AStarPathHCost (TilePath As tPATH, TargetPos As tVECTOR2d, entity As tENTITY)
    Dim dx, dy As Long
    Dim distance As Double
    Dim SearchIntensity As Long
    dx = Abs(TilePath.position.x - TargetPos.x)
    dy = Abs(TilePath.position.y - TargetPos.y)
    distance = Sqr(dx ^ 2 + dy ^ 2)
    SearchIntensity = Int(Rnd * entity.parameters.drunkiness)
    AStarPathHCost = ((SearchIntensity / 20) + 10) * (dx + dy + ((SearchIntensity / 10) * distance))
End Function

Function AStarCollision (gamemap() As tTILE, tilemap As tTILEMAP, Position As tVECTOR2d)
    ' This is hack that requires the block at 0 to be a collider block
    AStarCollision = Not (gamemap(vector2dToGameMapPlain(tilemap, Position)).collision = gamemap(0).collision)
End Function

Function AStarWalkway (gamemap() As tTILE, tilemap As tTILEMAP, position As tVECTOR2d)
    'This is to detect optimal paths based on using sidewalks
    'I'm using the same block as collision block except the rotated bit is set
    AStarWalkway = (gamemap(vector2dToGameMapPlain(tilemap, position)).collision And &HFFFFFF) = (gamemap(0).collision And &HFFFFFF)
End Function

'**********************************************************************************************
'   XML
'**********************************************************************************************

Sub _______________XML_HANDLING (): End Sub
Sub XMLparse (dir As String, file As String, con() As tSTRINGTUPLE)
    Dim As String xml(0), x, element_name, stack(0), context
    Dim As Long index
    Dim As Long element_start, element_ending
    Dim As Long element_first_space, element_pop
    Dim As Long element_end_of_family, element_no_family
    Dim As Long header_start, header_finish
    Dim As Long element_name_start, element_name_end
    Dim As Long comment_start, comment_end, comment_multiline_start, comment_multiline_end
    Dim As Long mute, j

    loadFile trim$(dir) + trim$(file), xml()

    mute = 0

    For index = 0 To UBound(xml) - 1
        x = RTrim$(LTrim$(xml(index)))
        header_start = InStr(x, "<?")
        header_finish = InStr(x, "?>")
        comment_start = InStr(x, "<!")
        comment_end = InStr(x, "!>")
        comment_multiline_start = InStr(x, "<!--")
        comment_multiline_end = InStr(x, "-->")
        If comment_start Or comment_multiline_start Then mute = 1
        If comment_end Or comment_multiline_end Then mute = 0

        If header_start = 0 And mute = 0 Then
            element_start = InStr(x, "<")
            element_end_of_family = InStr(x, "</")
            element_first_space = InStr(element_start, x, " ")
            element_pop = InStr(x, "/")
            element_ending = InStr(x, ">")
            element_no_family = InStr(x, "/>")
            element_name = ""
            If element_start Then
                'Get Element Name
                'Starting character
                If element_end_of_family Then
                    element_name_start = element_end_of_family + 2 'start after '</'
                Else
                    element_name_start = element_start + 1 'start after '<'
                End If
                'Ending character
                If element_first_space Then ' check for a space after the element name
                    element_name_end = element_first_space
                Else
                    If element_no_family Then ' check for no family
                        element_name_end = element_no_family
                    Else
                        If element_ending Then ' check for family name
                            element_name_end = element_ending
                        Else
                            Print "XML malformed. "; x
                            waitkey
                            System
                        End If
                    End If
                End If
                element_name = Mid$(x, element_name_start, element_name_end - element_name_start)
                ' Determine level
                If element_end_of_family = 0 Then
                    pushStackString stack(), element_name
                    ' Compile context tree
                    context = ""
                    For j = 0 To UBound(stack) - 1 'push_pop
                        context = context + stack(j)
                        If j < UBound(stack) - 1 Then
                            context = context + " "
                        End If
                    Next
                End If
                If element_pop Then popStackString stack()
            End If
            ' push onto Context tuple
            If element_end_of_family = 0 Then pushStackContextArg con(), context, x
        End If
    Next
End Sub

Sub XMLapplyAttributes (engine As tENGINE, world As tWORLD, gamemap() As tTILE, entity() As tENTITY, p() As tPOLY, body() As tBODY, camera As tCAMERA, tile() As tTILE, tilemap As tTILEMAP, dir As String, con() As tSTRINGTUPLE)
    Dim As String context, arg, elementName, elementString, objectGroupName, objectName, objectType, propertyName, propertyValueString, objectID, mapLayer, elementValueString
    Dim As Long index, firstId, start, comma, mapIndex, tempId, sensorImage, tempColor
    Dim As tVECTOR2d o, tempVec
    Dim As _Float elementValue, xp, yp, xs, ys, propertyValue, tempVal, xl, yl
    Dim As tLIGHT lights(0)
    For index = 0 To UBound(con) - 1
        context = LTrim$(RTrim$(con(index).contextName))
        arg = LTrim$(RTrim$(con(index).arg))
        Select Case context
            Case "map":
                tilemap.mapWidth = getXMLArgValue(arg, " width=")
                tilemap.mapHeight = getXMLArgValue(arg, " height=")
                tilemap.tileWidth = getXMLArgValue(arg, " tilewidth=")
                tilemap.tileHeight = getXMLArgValue(arg, " tileheight=")
                tilemap.tileSize = tilemap.tileWidth
            Case "map group":
                elementName = getXMLArgString$(arg, " name=")
            Case "map group properties property":
                Select Case elementName
                    Case "SOUNDS":
                        addMusic sounds(), getXMLArgString$(arg, " value="), getXMLArgString$(arg, " name=")
                End Select
            Case "map tileset":
                tilemap.tsxFile = RTrim$(LTrim$(getXMLArgString$(arg, " source=")))
                firstId = getXMLArgValue(arg, " firstgid=")
                loadTSX dir, tile(), tilemap, firstId
            Case "map properties property":
                elementName = getXMLArgString$(arg, " name=")
                elementValue = getXMLArgValue##(arg, " value=")
                elementValueString = getXMLArgString$(arg, " value=")
                Select Case elementName
                    Case "GRAVITY_X":
                        world.gravity.x = elementValue
                        vector2dMultiplyScalarND o, world.gravity, cDT: engine.resting = vector2dLengthSq(o) + cEPSILON
                    Case "GRAVITY_Y":
                        world.gravity.y = elementValue
                        vector2dMultiplyScalarND o, world.gravity, cDT: engine.resting = vector2dLengthSq(o) + cEPSILON
                    Case "CAMERA_ZOOM":
                        camera.zoom = elementValue
                    Case "CAMERA_FOCUS_X":
                        camera.position.x = elementValue
                    Case "CAMERA_FOCUS_Y":
                        camera.position.y = elementValue
                    Case "CAMERA_AABB_X":
                        camera.AABB.x = elementValue
                    Case "CAMERA_AABB_Y":
                        camera.AABB.y = elementValue
                    Case "CAMERA_AABB_SIZE_X":
                        camera.AABB_size.x = elementValue
                    Case "CAMERA_AABB_SIZE_Y":
                        camera.AABB_size.y = elementValue
                    Case "CAMERA_MODE"
                    Case "LIGHT_MAX_DISTANCE":
                        engine.mapParameters.maxLightDistance = elementValue
                End Select
            Case "map layer":
                mapLayer = getXMLArgString$(arg, " name=")
            Case "map layer data": ' Load GameMap
                elementString = getXMLArgString$(arg, "encoding=")
                If elementString = "csv" Then
                    mapIndex = 0
                Else
                    'Read in comma delimited gamemap data
                    start = 1
                    arg = RTrim$(LTrim$(arg))
                    Do While start <= Len(arg)
                        comma = InStr(start, arg, ",")
                        If comma = 0 Then
                            If start < Len(arg) Then ' catch the last value at the end of the list
                                tempVal = Val(Right$(arg, Len(arg) - start + 1))
                                XMLsetGameMap gamemap(), mapIndex, mapLayer, tempVal
                            End If
                            Exit Do
                        End If
                        tempVal = Val(Mid$(arg, start, comma - start))
                        XMLsetGameMap gamemap(), mapIndex, mapLayer, tempVal
                        start = comma + 1
                    Loop
                End If
            Case "map objectgroup": 'Get object group name
                objectGroupName = getXMLArgString$(arg, " name=")
            Case "map objectgroup object": 'Get object name
                Select Case objectGroupName
                    Case "Objects":
                        objectType = getXMLArgString$(arg, " type=")
                        Select Case objectType
                            Case "PLAYER":
                                objectName = getXMLArgString$(arg, " name=")
                                xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
                                yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
                                vector2dSet tempVec, xp + tilemap.tileWidth, yp + tilemap.tileHeight
                                tempId = entityCreate(entity(), p(), body(), tilemap, objectName, tempVec)
                            Case "ENTITY":
                                objectName = getXMLArgString$(arg, " name=")
                                xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
                                yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
                                vector2dSet tempVec, xp + tilemap.tileWidth, yp + tilemap.tileHeight
                                tempId = entityCreate(entity(), p(), body(), tilemap, objectName, tempVec)
                            Case "SENSOR":
                                objectName = getXMLArgString$(arg, " name=")
                                xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
                                yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
                                xs = (getXMLArgValue(arg, " width=") * tilemap.tilescale) / 2
                                ys = (getXMLArgValue(arg, " height=") * tilemap.tilescale) / 2
                                tempId = createBoxBodyEx(p(), body(), objectName, xs, ys)
                                setBody p(), body(), cPARAMETER_POSITION, tempId, xp + xs, yp + ys
                                setBody p(), body(), cPARAMETER_ORIENT, tempId, 0, 0
                                setBody p(), body(), cPARAMETER_STATIC, tempId, 1, 0
                                setBody p(), body(), cPARAMETER_COLOR, tempId, _RGBA32(0, 255, 0, 255), 0
                                setBody p(), body(), cPARAMETER_NOPHYSICS, tempId, 1, 0
                                setBody p(), body(), cPARAMETER_SPECIALFUNCTION, tempId, 1, tempId
                                'Sensors have couple of ways to trigger
                                'There is the body collision and there is the image collision
                                'There is a hidden image that is the same size as the gamemap
                                'The hidden image is black except for the images of the sensors
                                'This allows for you to detect sensor collisions with the POINT command
                                'This is useful for mouse interactions with menu items
                                'The color is embedded with bodyID to help sort which sensor got hit
                                sensorImage = allocateTextureEX(tile(), _NewImage(64, 64, 32))
                                _Dest tile(sensorImage).t
                                Line (0, 0)-(64, 64), _RGB(0, 0, tempId), BF
                                _Dest 0
                                setBody p(), body(), cPARAMETER_TEXTURE, tempId, tile(sensorImage).t, 0
                            Case "LANDMARK":
                                objectName = getXMLArgString$(arg, " name=")
                                xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
                                yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
                                landmark(UBound(landmark)).landmarkName = objectName
                                landmark(UBound(landmark)).landmarkHash = computeHash&&(objectName)
                                landmark(UBound(landmark)).position.x = xp
                                landmark(UBound(landmark)).position.y = yp
                                ReDim _Preserve landmark(UBound(landmark) + 1) As tLANDMARK
                            Case "DOOR":
                                objectName = getXMLArgString$(arg, " name=")
                                xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
                                yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
                                xs = (getXMLArgValue(arg, " width=") * tilemap.tilescale) / 2
                                ys = (getXMLArgValue(arg, " height=") * tilemap.tilescale) / 2
                                tempId = createBoxBodyEx(p(), body(), objectID, xs, ys)
                                setBody p(), body(), cPARAMETER_POSITION, tempId, xp + xs, yp + ys
                                setBody p(), body(), cPARAMETER_ORIENT, tempId, 0, 0
                                setBody p(), body(), cPARAMETER_STATIC, tempId, 1, 0
                                setBody p(), body(), cPARAMETER_NOPHYSICS, tempId, 1, 0
                                setBody p(), body(), cPARAMETER_COLOR, tempId, _RGBA32(255, 0, 0, 255), 0
                                doors(UBound(doors)).bodyId = tempId
                                doors(UBound(doors)).doorName = objectName
                                doors(UBound(doors)).doorHash = computeHash&&(objectName)
                                doors(UBound(doors)).position.x = xp
                                doors(UBound(doors)).position.y = yp
                                ReDim _Preserve doors(UBound(doors) + 1) As tDOOR
                        End Select
                    Case "Collision":
                        objectID = getXMLArgString$(arg, " id=")
                        xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
                        yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
                        xs = (getXMLArgValue(arg, " width=") * tilemap.tilescale) / 2
                        ys = (getXMLArgValue(arg, " height=") * tilemap.tilescale) / 2
                        tempId = createBoxBodyEx(p(), body(), objectID, xs, ys)
                        setBody p(), body(), cPARAMETER_POSITION, tempId, xp + xs, yp + ys
                        setBody p(), body(), cPARAMETER_ORIENT, tempId, 0, 0
                        setBody p(), body(), cPARAMETER_STATIC, tempId, 1, 0
                        setBody p(), body(), cPARAMETER_COLOR, tempId, _RGBA32(255, 0, 0, 255), 0
                    Case "Lights":
                        xl = getXMLArgValue(arg, " x=")
                        yl = getXMLArgValue(arg, " y=")
                    Case "fzxBody":
                        XMLaddRigidBody p(), body(), gamemap(), tile(), tilemap, arg
                End Select
            Case "map objectgroup object properties property":
                Select Case objectGroupName
                    Case "Objects":
                        Select Case objectType
                            Case "PLAYER":
                                propertyName = getXMLArgString$(arg, " name=")
                                propertyValue = getXMLArgValue(arg, " value=")
                                tempId = bodyManagerID(body(), objectName)
                                Select Case propertyName
                                    Case "TileID":
                                        setBody p(), body(), cPARAMETER_TEXTURE, tempId, tile(idToTile(tile(), propertyValue + 1)).t, 0
                                    Case "MAX_FORCE_X":
                                        entity(body(tempId).entityID).parameters.maxForce.x = propertyValue
                                    Case "MAX_FORCE_Y":
                                        entity(body(tempId).entityID).parameters.maxForce.y = propertyValue
                                    Case "NO_PHYSICS":
                                        setBody p(), body(), cPARAMETER_NOPHYSICS, tempId, propertyValue, 0
                                End Select
                            Case "ENTITY":
                                propertyName = getXMLArgString$(arg, " name=")
                                propertyValue = getXMLArgValue(arg, " value=")
                                tempId = bodyManagerID(body(), objectName)
                                Select Case propertyName
                                    Case "TileID":
                                        setBody p(), body(), cPARAMETER_TEXTURE, tempId, tile(idToTile(tile(), propertyValue + 1)).t, 0
                                End Select
                            Case "SENSOR": ' No properties
                            Case "WAYPOINT": ' No properties
                            Case "DOOR":
                                propertyName = getXMLArgString$(arg, " name=")
                                propertyValue = getXMLArgValue(arg, " value=")
                                propertyValueString = getXMLArgString$(arg, " value=")
                                Select Case propertyName
                                    Case "LANDMARK":
                                        doors(UBound(doors) - 1).landmarkHash = computeHash&&(propertyValueString)
                                    Case "MAP":
                                        doors(UBound(doors) - 1).map = propertyValueString
                                    Case "OPEN_CLOSED_LOCKED":
                                        doors(UBound(doors) - 1).status = propertyValue
                                    Case "TILE_CLOSED":
                                        doors(UBound(doors) - 1).tileOpen = propertyValue
                                    Case "TILE_OPEN":
                                        doors(UBound(doors) - 1).tileClosed = propertyValue
                                End Select
                        End Select
                    Case "Lights":
                        elementValueString = getXMLArgString$(arg, " value=")
                        elementValueString = UCase$("&H" + Right$(elementValueString, Len(elementValueString) - InStr(elementValueString, "#")))
                        tempColor = Val(elementValueString)
                        lights(UBound(lights)).position.x = xl
                        lights(UBound(lights)).position.y = yl
                        lights(UBound(lights)).lightColor = tempColor
                        ReDim _Preserve lights(UBound(lights) + 1) As tLIGHT
                End Select
        End Select
    Next
    constructGameMap engine, p(), body(), gamemap(), tile(), tilemap, lights()
End Sub

Sub XMLaddRigidBody (p() As tPOLY, body() As tBODY, gamemap() As tTILE, tile() As tTILE, tilemap As tTILEMAP, arg As String)
    Dim As String objectId, objectName, objectType
    Dim As _Float xp, yp, xs, ys
    Dim As Long tempId

    objectId = getXMLArgString$(arg, " id=")
    objectName = getXMLArgString$(arg, " name=")
    objectType = getXMLArgString$(arg, " type=")

    xp = getXMLArgValue(arg, " x=") * tilemap.tilescale
    yp = getXMLArgValue(arg, " y=") * tilemap.tilescale
    xs = (getXMLArgValue(arg, " width=") * tilemap.tilescale)
    ys = (getXMLArgValue(arg, " height=") * tilemap.tilescale)
    ' Create Ridid body
    If objectType = "BOX" Then
        tempId = createBoxBodyEx(p(), body(), objectName, xs / 2, ys / 2)
    Else If objectType = "CIRCLE" Then
            tempId = createCircleBodyEx(body(), objectName, xs / 2)
        End If
    End If
    setBody p(), body(), cPARAMETER_POSITION, tempId, xp + (xs / 2), yp + (ys / 2)
    setBody p(), body(), cPARAMETER_ORIENT, tempId, 0, 0
    setBody p(), body(), cPARAMETER_NOPHYSICS, tempId, 0, 0
    'build texture for Box
    Dim As tTILEMAP tempLayout
    Dim As Long tx, ty, tileStartX, tileStartY, mapSizeX, mapSizeY, gameMapX, gameMapY, tempMapPos, gameMapPos, imgId
    tileStartX = xp / tilemap.tileWidth
    tileStartY = yp / tilemap.tileHeight
    mapSizeX = xs / tilemap.tileWidth
    mapSizeY = ys / tilemap.tileHeight
    imgId = allocateTextureEX(tile(), _NewImage(xs, ys, 32))
    Dim As tTILE tempMAP(mapSizeX * mapSizeY)
    For ty = 0 To mapSizeY - 1
        For tx = 0 To mapSizeX - 1
            gameMapX = tx + tileStartX
            gameMapY = ty + tileStartY
            gameMapPos = gameMapX + (gameMapY * tilemap.mapWidth)
            tempMapPos = tx + ty * mapSizeX
            tempMAP(tempMapPos) = gamemap(gameMapPos)
        Next
    Next
    tempLayout = tilemap
    tempLayout.mapWidth = mapSizeX
    tempLayout.mapHeight = mapSizeY
    buildMultiTileMap tempMAP(), tile(), tempLayout, tile(imgId).t, 1
    setBody p(), body(), cPARAMETER_TEXTURE, tempId, tile(imgId).t, 0
End Sub

Sub XMLsetGameMap (gamemap() As tTILE, mapindex As Long, mapLayer As String, value As _Float)
    If mapindex > UBound(gamemap) Then ReDim _Preserve gamemap(mapindex) As tTILE
    Select Case mapLayer
        Case "Tile Layer 1":
            gamemap(mapindex).t = value
        Case "Tile Rigid Body":
            gamemap(mapindex).t0 = value
        Case "Tile Collision":
            gamemap(mapindex).collision = value
    End Select
    mapindex = mapindex + 1
End Sub

Function getXMLArgValue## (i As String, s As String)
    Dim As Long sp, space
    Dim As String m
    sp = InStr(i, s)
    If sp Then
        sp = sp + Len(s) + 1 ' add one for the quotes
        space = InStr(sp + 1, i, Chr$(34)) - sp
        m = Mid$(i, sp, space)
        getXMLArgValue## = Val(m)
    End If
End Function

Function getXMLArgString$ (i As String, s As String)
    Dim As Long sp, space
    Dim As String m
    sp = InStr(i, s)
    If sp Then
        sp = sp + Len(s) + 1 ' add one for the quotes
        space = InStr(sp + 1, i, Chr$(34)) - sp
        m = Mid$(i, sp, space)
        getXMLArgString$ = RTrim$(LTrim$(m))
    End If
End Function

'**********************************************************************************************
'   Stack Functions/Subs
'**********************************************************************************************
Sub _______________STACK_HANDLING (): End Sub
Sub pushStackString (stack() As String, element As String)
    stack(UBound(stack)) = element
    ReDim _Preserve stack(UBound(stack) + 1) As String
End Sub

Sub popStackString (stack() As String)
    If UBound(stack) > 0 Then ReDim _Preserve stack(UBound(stack) - 1) As String
End Sub

Function topStackString$ (stack() As String)
    If UBound(stack) > 0 Then
        topStackString$ = stack(UBound(stack) - 1)
    Else
        topStackString$ = stack(UBound(stack))
    End If
End Function

Sub pushStackVector (stack() As tVECTOR2d, element As tVECTOR2d)
    stack(UBound(stack)) = element
    ReDim _Preserve stack(UBound(stack) + 1) As tVECTOR2d
End Sub

Sub popStackVector (stack() As tVECTOR2d)
    If UBound(stack) > 0 Then ReDim _Preserve stack(UBound(stack) - 1) As tVECTOR2d
End Sub

Sub topStackVector (o As tVECTOR2d, stack() As tVECTOR2d)
    If UBound(stack) > 0 Then
        o = stack(UBound(stack) - 1)
    Else
        o = stack(UBound(stack))
    End If
End Sub

Sub pushStackContextArg (stack() As tSTRINGTUPLE, element_name As String, element As String)
    stack(UBound(stack)).contextName = element_name
    stack(UBound(stack)).arg = element
    ReDim _Preserve stack(UBound(stack) + 1) As tSTRINGTUPLE
End Sub

Sub pushStackContext (stack() As tSTRINGTUPLE, element As tSTRINGTUPLE)
    stack(UBound(stack)) = element
    ReDim _Preserve stack(UBound(stack) + 1) As tSTRINGTUPLE
End Sub

Sub popStackContext (stack() As tSTRINGTUPLE)
    If UBound(stack) > 0 Then ReDim _Preserve stack(UBound(stack) - 1) As tSTRINGTUPLE
End Sub

'**********************************************************************************************
'   SOUND Functions/Subs
'**********************************************************************************************
Sub _______________SOUND_HANDLING (): End Sub

Sub playMusic (playlist As tPLAYLIST, sounds() As tSOUND, id As String)
    Dim As Long music
    music = soundManagerIDClass(sounds(), id)
    If music > -1 Then
        If Not _SndPlaying(sounds(music).handle) Then
            If playlist.fsm.currentState = cFSM_SOUND_IDLE Then
                playlist.currentMusic = music
            Else
                playlist.nextMusic = music
            End If
        End If
    End If
End Sub

Sub stopMusic (playlist As tPLAYLIST)
    playlist.nextMusic = -1
    FSMChangeState playlist.fsm, cFSM_SOUND_LEADOUT
End Sub

Sub handleMusic (playlist As tPLAYLIST, sounds() As tSOUND)
    playlist.fsm.timerState.duration = 3
    Select Case playlist.fsm.currentState
        Case cFSM_SOUND_IDLE:
            If playlist.currentMusic > -1 Then
                FSMChangeState playlist.fsm, cFSM_SOUND_START
            End If
        Case cFSM_SOUND_START:
            _SndVol sounds(playlist.currentMusic).handle, 0
            _SndPlay sounds(playlist.currentMusic).handle
            _SndLoop sounds(playlist.currentMusic).handle
            FSMChangeState playlist.fsm, cFSM_SOUND_LEADIN
        Case cFSM_SOUND_LEADIN:
            _SndVol sounds(playlist.currentMusic).handle, gameOptions.musicVolume * scalarLERPProgress##(playlist.fsm.timerState.start, playlist.fsm.timerState.start + playlist.fsm.timerState.duration)
            FSMChangeStateOnTimer playlist.fsm, cFSM_SOUND_PLAY
        Case cFSM_SOUND_PLAY:
            _SndVol sounds(playlist.currentMusic).handle, gameOptions.musicVolume
            If playlist.currentMusic <> playlist.nextMusic And playlist.nextMusic > -1 Then
                FSMChangeState playlist.fsm, cFSM_SOUND_LEADOUT
            End If
        Case cFSM_SOUND_LEADOUT:
            If playlist.currentMusic > -1 Then
                _SndVol sounds(playlist.currentMusic).handle, gameOptions.musicVolume * (1 - scalarLERPProgress##(playlist.fsm.timerState.start, playlist.fsm.timerState.start + playlist.fsm.timerState.duration))
                FSMChangeStateOnTimer playlist.fsm, cFSM_SOUND_CLEANUP
            Else
                FSMChangeState playlist.fsm, cFSM_SOUND_CLEANUP
            End If
        Case cFSM_SOUND_CLEANUP:
            If playlist.currentMusic > -1 Then _SndStop sounds(playlist.currentMusic).handle
            If playlist.nextMusic = -1 Then
                playlist.currentMusic = -1
                FSMChangeState playlist.fsm, cFSM_SOUND_IDLE
            Else
                playlist.currentMusic = playlist.nextMusic
                playlist.nextMusic = -1
                FSMChangeState playlist.fsm, cFSM_SOUND_START
            End If
    End Select
End Sub

Sub addMusic (sounds() As tSOUND, filename As String, class As String)
    Dim As Long index
    index = UBound(sounds)
    sounds(index).handle = _SndOpen(_CWD$ + "/Assets/" + filename)
    If sounds(index).handle = 0 Then
        Print "Could not open "; _CWD$ + "/Assets/" + filename
        waitkey
        System
    End If
    sounds(index).fileName = filename
    sounds(index).fileHash = computeHash&&(filename)
    sounds(index).class = class
    sounds(index).classHash = computeHash&&(class)
    ReDim _Preserve sounds(index + 1) As tSOUND
End Sub

Sub removeAllMusic (playlist As tPLAYLIST, sounds() As tSOUND)
    Dim As Long index
    playlist.nextMusic = -1
    playlist.currentMusic = -1
    FSMChangeState playlist.fsm, cFSM_SOUND_IDLE
    For index = 0 To UBound(sounds)
        _SndStop sounds(index).handle
        _SndClose sounds(index).handle
    Next
    ReDim sounds(0) As tSOUND
End Sub

Function soundManagerIDFilename (sounds() As tSOUND, objName As String)
    Dim i As Long
    Dim uID As _Integer64
    uID = computeHash&&(RTrim$(LTrim$(objName)))
    soundManagerIDFilename = -1
    For i = 0 To UBound(sounds) - 1
        If sounds(i).fileHash = uID Then
            soundManagerIDFilename = i
            Exit Function
        End If
    Next
End Function

Function soundManagerIDClass (sounds() As tSOUND, objName As String)
    Dim i As Long
    Dim uID As _Integer64
    uID = computeHash&&(RTrim$(LTrim$(objName)))
    soundManagerIDClass = -1
    For i = 0 To UBound(sounds)
        If sounds(i).classHash = uID Then
            soundManagerIDClass = i
            Exit Function
        End If
    Next
End Function


'**********************************************************************************************
'   Color Mixer Functions/Subs
'**********************************************************************************************
Sub _______________COLOR_MIXER (): End Sub
Function colorChannelMixer (colorChannelA As _Unsigned _Byte, colorChannelB As _Unsigned _Byte, amountToMix As _Float)
    Dim As _Float channelA, channelB
    channelA = colorChannelA * amountToMix
    channelB = colorChannelB * (1 - amountToMix)
    colorChannelMixer = Int(channelA + channelB)
End Function

Function colorMixer& (rgbA As Long, rgbB As Long, amountToMix As _Float)
    Dim As _Unsigned _Byte r, g, b
    r = colorChannelMixer(_Red(rgbA), _Red(rgbB), amountToMix)
    g = colorChannelMixer(_Green(rgbA), _Green(rgbB), amountToMix)
    b = colorChannelMixer(_Blue(rgbA), _Blue(rgbB), amountToMix)
    colorMixer = _RGB(r, g, b)
End Function

'**********************************************************************************************
'     LandMarks Functions/Subs
'**********************************************************************************************
Sub _______________LANDMARK_SUBS (): End Sub

Sub findLandmarkPosition (landmarks() As tLANDMARK, id As String, o As tVECTOR2d)
    Dim As Long index
    Dim As _Integer64 hash
    hash = computeHash&&(id)
    For index = 0 To UBound(landmarks) - 1
        If landmarks(index).landmarkHash = hash Then
            o = landmarks(index).position
            Exit Sub
        End If
    Next
End Sub

Sub findLandmarkPositionHash (landmarks() As tLANDMARK, hash As _Integer64, o As tVECTOR2d)
    Dim As Long index
    For index = 0 To UBound(landmarks) - 1
        If landmarks(index).landmarkHash = hash Then
            o = landmarks(index).position
            Exit Sub
        End If
    Next
End Sub

'**********************************************************************************************
'     Door Functions/Subs
'**********************************************************************************************
Sub _______________DOOR_FUNCTION (): End Sub

Function handleDoors& (entity() As tENTITY, body() As tBODY, hits() As tHIT, doors() As tDOOR)
    Dim As Long index, playerid
    playerid = entityManagerID(body(), "PLAYER")
    handleDoors = -1
    For index = 0 To UBound(doors) - 1
        If Not isBodyTouchingBody(hits(), entity(playerid).objectID, doors(index).bodyId) Then
            handleDoors = index
            Exit Function
        End If
    Next
End Function

'**********************************************************************************************
'     Operating System Related
'**********************************************************************************************
Sub _______________OS_CONSIDERATIONS (): End Sub

Function OSPathJoin$
    $If WINDOWS = DEFINED Then
        OSPathJoin$ = "\"
    $Else
            OSPathJoin$ = "/"
    $End If
End Function

