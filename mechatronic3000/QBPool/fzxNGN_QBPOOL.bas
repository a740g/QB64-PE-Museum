OPTION _EXPLICIT
'$dynamic
'**********************************************************************************************
'   FzxNGN written by justsomeguy
'   Physics code ported from RandyGaul's Impulse Engine
'   https://github.com/RandyGaul/ImpulseEngine
'   http://RandyGaul.net
'**********************************************************************************************
'/*
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
'    Port to QB64 by justsomeguy
'*/
'

'**********************************************************************************************
'   Setup Types and Variables
'**********************************************************************************************
TYPE tVECTOR2d
    x AS _FLOAT
    y AS _FLOAT
END TYPE

TYPE tLINE2d ' Not used
    a AS tVECTOR2d
    b AS tVECTOR2d
END TYPE

TYPE tFACE2d ' Not used
    f0 AS tVECTOR2d
    f1 AS tVECTOR2d
END TYPE

TYPE tTRIANGLE ' Not used
    a AS tVECTOR2d
    b AS tVECTOR2d
    c AS tVECTOR2d
END TYPE

TYPE tMATRIX2d
    m00 AS _FLOAT
    m01 AS _FLOAT
    m10 AS _FLOAT
    m11 AS _FLOAT
END TYPE

TYPE tSHAPE
    ty AS INTEGER ' cSHAPE_CIRCLE = 1, cSHAPE_POLYGON = 2
    radius AS _FLOAT ' Only necessary for circle shapes
    u AS tMATRIX2d ' Only necessary for polygons
    texture AS LONG
    flipTexture AS INTEGER 'flag for flipping texture depending on direction
    scaleTextureX AS _FLOAT
    scaleTextureY AS _FLOAT
    offsetTextureX AS _FLOAT
    offsetTextureY AS _FLOAT
END TYPE

TYPE tPOLY 'list of vertices for all objects in simulation
    vert AS tVECTOR2d
    norm AS tVECTOR2d
END TYPE

TYPE tPOLYATTRIB 'keep track of polys in monlithic list of vertices
    start AS INTEGER ' starting vertex of the polygon
    count AS INTEGER ' number of vertices in polygon
END TYPE

TYPE tBODY
    objectName AS STRING * 64
    objectHash AS _INTEGER64
    position AS tVECTOR2d
    velocity AS tVECTOR2d
    force AS tVECTOR2d
    angularVelocity AS _FLOAT
    torque AS _FLOAT
    orient AS _FLOAT
    mass AS _FLOAT
    invMass AS _FLOAT
    inertia AS _FLOAT
    invInertia AS _FLOAT
    staticFriction AS _FLOAT
    dynamicFriction AS _FLOAT
    restitution AS _FLOAT
    shape AS tSHAPE
    pa AS tPOLYATTRIB
    c AS LONG ' color
    enable AS INTEGER 'Hide a body ;)
    collisionMask AS _UNSIGNED INTEGER
END TYPE

TYPE tMANIFOLD
    A AS INTEGER
    B AS INTEGER
    penetration AS _FLOAT
    normal AS tVECTOR2d
    contactCount AS INTEGER
    e AS _FLOAT
    df AS _FLOAT
    sf AS _FLOAT
    cv AS _FLOAT 'contact velocity
END TYPE

TYPE tHIT
    A AS INTEGER
    B AS INTEGER
    position AS tVECTOR2d
    cv AS _FLOAT
END TYPE

TYPE tJOINT
    jointName AS STRING * 64
    jointHash AS _INTEGER64
    M AS tMATRIX2d
    localAnchor1 AS tVECTOR2d
    localAnchor2 AS tVECTOR2d
    r1 AS tVECTOR2d
    r2 AS tVECTOR2d
    bias AS tVECTOR2d
    P AS tVECTOR2d
    body1 AS INTEGER
    body2 AS INTEGER
    biasFactor AS _FLOAT
    softness AS _FLOAT
END TYPE

TYPE tCAMERA
    position AS tVECTOR2d
    zoom AS _FLOAT
END TYPE

TYPE tWORLD
    plusLimit AS tVECTOR2d
    minusLimit AS tVECTOR2d
    gravity AS tVECTOR2d
    spawn AS tVECTOR2d
    terrainPosition AS tVECTOR2d
END TYPE

TYPE tVEHICLE
    vehicleName AS STRING * 64
    vehicleHash AS _INTEGER64
    body AS INTEGER
    wheelOne AS INTEGER
    wheelTwo AS INTEGER
    axleJointOne AS INTEGER
    axleJointTwo AS INTEGER
    auxBodyOne AS INTEGER
    auxJointOne AS INTEGER
    wheelOneOffset AS tVECTOR2d
    wheelTwoOffset AS tVECTOR2d
    auxOneOffset AS tVECTOR2d
    torque AS _FLOAT
END TYPE

TYPE tOBJECTMANAGER
    objectCount AS INTEGER
    jointCount AS INTEGER
END TYPE

TYPE tINPUTDEVICE
    x AS INTEGER
    y AS INTEGER
    b1 AS INTEGER
    lb1 AS INTEGER
    b2 AS INTEGER
    lb2 AS INTEGER
    b3 AS INTEGER
    lb3 AS INTEGER
    w AS INTEGER
    wCount AS INTEGER
    keyHit AS LONG
    lastKeyHit AS LONG
END TYPE

CONST cSHAPE_CIRCLE = 1
CONST cSHAPE_POLYGON = 2
CONST cPRECISION = 100
CONST cMAXNUMOFTRIANGLES = 100
CONST cMAXNUMBEROFOBJECTS = 1000 ' Max number of objects at one time
CONST cMAXNUMBEROFPOLYGONS = 10000 ' Max number of total vertices included in all objects
CONST cMAXNUMBEROFJOINTS = 100
CONST cMAXNUMBEROFHITS = 10000
CONST cPI = 3.14159
CONST cEPSILON = 0.0001
CONST cEPSILON_SQ = cEPSILON * cEPSILON
CONST cBIAS_RELATIVE = 0.95
CONST cBIAS_ABSOLUTE = 0.01
CONST cDT = 1.0 / 120.0
CONST cITERATIONS = 100
CONST cPENETRATION_ALLOWANCE = 0.05
CONST cPENETRATION_CORRECTION = 0.4 ' misspelled in original code
CONST cGLOBAL_FRICTION = .992
CONST cPARAMETER_POSITION = 1
CONST cPARAMETER_VELOCITY = 2
CONST cPARAMETER_FORCE = 3
CONST cPARAMETER_ANGULARVELOCITY = 4
CONST cPARAMETER_TORQUE = 5
CONST cPARAMETER_ORIENT = 6
CONST cPARAMETER_STATICFRICTION = 7
CONST cPARAMETER_DYNAMICFRICTION = 8
CONST cPARAMETER_RESTITUTION = 9
CONST cPARAMETER_COLOR = 10
CONST cPARAMETER_ENABLE = 11
CONST cPARAMETER_STATIC = 12
CONST cPARAMETER_TEXTURE = 13
CONST cPARAMETER_FLIPTEXTURE = 14
CONST cPARAMETER_COLLISIONMASK = 15
CONST cRENDER_JOINTS = 0
CONST cRENDER_COLLISIONS = 0
CONST cPLAYER_FORCE = 600000

DIM SHARED sRESTING AS _FLOAT
DIM SHARED sNUMBEROFBODIES AS INTEGER: sNUMBEROFBODIES = 10 ' 0 is included
DIM SHARED sNUMBEROFJOINTS AS INTEGER: sNUMBEROFJOINTS = 3 ' if zero then no joints at all
DIM SHARED sNUMBEROFVEHICLES AS INTEGER: sNUMBEROFVEHICLES = 1
DIM SHARED sTIMER AS LONG: sTIMER = TIMER

DIM poly(cMAXNUMBEROFPOLYGONS) AS tPOLY
DIM body(sNUMBEROFBODIES) AS tBODY
DIM joints(cMAXNUMBEROFJOINTS) AS tJOINT
DIM hits(cMAXNUMBEROFHITS) AS tHIT
DIM veh(sNUMBEROFVEHICLES) AS tVEHICLE
DIM camera AS tCAMERA
DIM inputDevice AS tINPUTDEVICE


DIM texture(100) AS LONG

TYPE tPOOL
    status AS INTEGER
    rackposition AS tVECTOR2d
    objId AS _INTEGER64
END TYPE
TYPE tGENPOOL
    instructions AS INTEGER
    instructionImage AS LONG
    mode AS INTEGER
    english AS tVECTOR2d
END TYPE
TYPE tSENSORS
    objId AS _INTEGER64
END TYPE


DIM timerOne AS INTEGER
DIM SHARED fps AS INTEGER
DIM SHARED fpsLast AS INTEGER
DIM SHARED world AS tWORLD
DIM SHARED objectManager AS tOBJECTMANAGER
DIM SHARED pool(17) AS tPOOL
DIM SHARED genPool AS tGENPOOL
DIM SHARED poolSensors(10) AS tSENSORS


'**********************************************************************************************
_TITLE "FzxNGN POOL"
SCREEN _NEWIMAGE(1024, 768, 32)
timerOne = _FREETIMER
ON TIMER(timerOne, 1) renderFps
TIMER(timerOne) ON
camera.zoom = .25
'RANDOMIZE TIMER
CALL buildSimpleScene(poly(), body(), joints(), texture(), veh())
'**********************************************************************************************
_PRINTMODE _KEEPBACKGROUND
DO: fps = fps + 1
    CLS , _RGB32(67, 39, 0)
    LOCATE 1, 55: PRINT "FPS:"; (fpsLast)

    CALL renderBodies(poly(), body(), joints(), hits(), camera)
    CALL animateScene(poly(), body(), joints(), hits(), texture(), camera, veh(), inputDevice)
    CALL impulseStep(poly(), body(), joints(), hits(), cDT, cITERATIONS)

    _DISPLAY
    _LIMIT 120
LOOP UNTIL _KEYHIT = 27
SYSTEM
'**********************************************************************************************
'   End of Main loop
'**********************************************************************************************


'**********************************************************************************************
'   Scene Creation and Handling Ahead
'**********************************************************************************************
SUB animateScene (poly() AS tPOLY, body() AS tBODY, joints() AS tJOINT, hits() AS tHIT, textureMap() AS LONG, camera AS tCAMERA, veh() AS tVEHICLE, iDevice AS tINPUTDEVICE)
    ' Cache some widely used ID's
    DIM cueBall AS _INTEGER64: cueBall = objectManagerID(body(), "cSCENE_BALL16")
    DIM cue AS _INTEGER64: cue = objectManagerID(body(), "cSCENE_CUE")

    DIM AS INTEGER index, ballCount
    DIM AS _FLOAT cueAngle, cueDistance, cueDrawingDistance
    DIM AS tVECTOR2d cueNormal, cuePos, cueBall2Camera, cuePower, mousePosVector
    DIM guideLine AS tLINE2d
    DIM AS LONG ghostImg

    ' Ignore this
    veh(0).vehicleName = "Nothing" 'this is just to clear the warnings

    ' Mouse and keyboard handling, mainly mouse, keyboard is too slow for indirect
    CALL handleInputDevice(iDevice)
    ' Change cueball to camera coordinate system.
    CALL worldToCamera(body(), camera, cueBall, cueBall2Camera)
    CALL vectorSet(mousePosVector, iDevice.x, iDevice.y)

    ' Some Maths
    cueNormal.x = cueBall2Camera.x - iDevice.x ' x-Component of Distance
    cueNormal.y = cueBall2Camera.y - iDevice.y ' y-Component of Distance
    cueAngle = _ATAN2(-cueNormal.y, -cueNormal.x) ' Use mouse to control the cue angle
    cueDistance = vectorDistance(mousePosVector, cueBall2Camera)
    cueDrawingDistance = (cueDistance * .25) + 450 ' Use this to guage power
    cuePos.x = COS(cueAngle) * cueDrawingDistance + body(cueBall).position.x ' Use these to calculate cue position
    cuePos.y = SIN(cueAngle) * cueDrawingDistance + body(cueBall).position.y
    cuePower.x = cueNormal.x * cPLAYER_FORCE
    cuePower.y = cueNormal.y * cPLAYER_FORCE

    guideLine.a.x = COS(cueAngle + _PI) * (25 * camera.zoom) + cueBall2Camera.x
    guideLine.a.y = SIN(cueAngle + _PI) * (25 * camera.zoom) + cueBall2Camera.y
    guideLine.b.x = COS(cueAngle + _PI) * (1000 * camera.zoom) + cueBall2Camera.x
    guideLine.b.y = SIN(cueAngle + _PI) * (1000 * camera.zoom) + cueBall2Camera.y

    ' Aim the Stick
    IF bodyAtRest(body(cueBall)) THEN ' AIM
        CALL setBody(body(), cPARAMETER_ENABLE, cue, 1, 0)
        CALL setBody(body(), cPARAMETER_ORIENT, cue, cueAngle, 0)
        CALL setBody(body(), cPARAMETER_POSITION, cue, cuePos.x, cuePos.y)
        LINE (guideLine.a.x, guideLine.a.y)-(guideLine.b.x, guideLine.b.y)
        camera.position = body(cueBall).position
    ELSE
        CALL setBody(body(), cPARAMETER_ENABLE, cue, 0, 0)
    END IF

    ' Camera Zoom
    camera.zoom = camera.zoom + (iDevice.wCount * .01): iDevice.wCount = 0
    IF camera.zoom < .125 THEN camera.zoom = .125

    ' Hit the ball
    ' Verify cue ball is not moving - I really need to check that all balls are not moving.
    IF bodyAtRest(body(cueBall)) THEN
        IF iDevice.lb1 = -1 AND iDevice.b1 = 0 THEN ' only fire once
            'Apply hitting Force and English
            CALL setBody(body(), cPARAMETER_FORCE, cueBall, cuePower.x, cuePower.y)
            CALL setBody(body(), cPARAMETER_ANGULARVELOCITY, cueBall, genPool.english.x, 0)
            ' Reset English
            genPool.english.x = 0
            genPool.english.y = 0
        END IF
    END IF

    IF _KEYDOWN(19200) THEN ' Left English
        genPool.english.x = genPool.english.x + 1
        IF genPool.english.x > 200 THEN genPool.english.x = 200
    END IF

    IF _KEYDOWN(19712) THEN ' Right English
        genPool.english.x = genPool.english.x - 1
        IF genPool.english.x < -200 THEN genPool.english.x = -200
    END IF

    ' Instruction GUI
    IF _KEYDOWN(ASC("I")) OR _KEYDOWN(ASC("i")) THEN ' Show instructions
        genPool.instructionImage = _COPYIMAGE(textureMap(22))
        genPool.instructions = 1
        sTIMER = TIMER
    END IF
    IF TIMER - sTIMER > 20 THEN genPool.instructions = 0 ' instruction timeout 20 sec
    IF genPool.instructions THEN
        genPool.instructionImage = _COPYIMAGE(textureMap(22))
        IF TIMER - sTIMER > 15 THEN 'After 15 seconds fade it out
            _SETALPHA INT((20 - (TIMER - sTIMER)) * 50), _RGB(255, 255, 255), genPool.instructionImage
        END IF
        _PUTIMAGE (0, 0), genPool.instructionImage, 0 ' INSTRUCTIONS
        _FREEIMAGE genPool.instructionImage
    END IF

    IF _KEYDOWN(ASC("R")) OR _KEYDOWN(ASC("r")) THEN ' ReRack balls
        ' Put all balls back in their rack positions
        CALL reRackBalls(body())
    END IF

    IF _KEYDOWN(32) THEN ' Spacebar  - For break
        ' Verify cue ball is not moving - I really need to check that all balls are not moving.
        IF bodyAtRest(body(cueBall)) THEN
            CALL setBody(body(), cPARAMETER_ANGULARVELOCITY, cueBall, genPool.english.x, 0)
            CALL setBody(body(), cPARAMETER_FORCE, cueBall, cuePower.x * 2, cuePower.y * 2)
            genPool.english.x = 0
            genPool.english.y = 0
        END IF
    END IF

    ' Check your shot feature
    IF _KEYDOWN(9) AND bodyAtRest(body(cueBall)) THEN 'TAB - LOOK ahead
        DIM ghostBody(UBOUND(body)) AS tBODY ' Create a new list of bodies
        CALL copyBodies(body(), ghostBody()) ' Copy all the bodies to the new list
        ' Apply Forces to the Cue Ball in the Bodies
        CALL setBody(ghostBody(), cPARAMETER_FORCE, cueBall, cuePower.x, cuePower.y)
        CALL setBody(ghostBody(), cPARAMETER_ANGULARVELOCITY, cueBall, genPool.english.x, 0)
        ' Create a Ghost Image Overlay
        ghostImg = _NEWIMAGE(_WIDTH(0), _HEIGHT(0), 32)
        _DEST ghostImg
        _SETALPHA 127, 0 TO 255, ghostImg
        ' Hide the table since we only car abou the balls
        CALL setBodyEx(ghostBody(), cPARAMETER_ENABLE, "cSCENE_TABLE", 0, 0)
        CALL setBody(ghostBody(), cPARAMETER_ENABLE, cue, 0, 0)
        ' Run Simulation for about 2 secs
        FOR index = 0 TO 240 ' number of frames for look ahead .. 240 / 120 fps = 2 sec
            CALL impulseStep(poly(), ghostBody(), joints(), hits(), cDT, cITERATIONS)
            CALL handlePocketSensors(ghostBody(), hits(), cueBall)
            CALL renderBodies(poly(), ghostBody(), joints(), hits(), camera)
        NEXT
        ' Return Screen to normal
        _DEST 0
        ' Display overlay
        _PUTIMAGE (0, 0), ghostImg, 0
        _DISPLAY
        ' Free up overlay
        _FREEIMAGE ghostImg
    END IF

    ballCount = 0
    FOR index = 1 TO 16 'Make balls roll across ball return
        ' check if balls are off the table and then give it "gravity"
        IF body(pool(index).objId).position.y > 750 THEN
            CALL setBody(body(), cPARAMETER_FORCE, pool(index).objId, 200000, 100000)
            ballCount = ballCount + 1
        END IF
        ' rerack table if all the balls are in the ball return
        IF ballCount > 14 AND bodyAtRest(body(cueBall)) THEN CALL reRackBalls(body())
    NEXT

    ' Show english Indicator - Only Left and Right are supported
    _PUTIMAGE (0, _HEIGHT(0) - 140), textureMap(16), 0,
    CIRCLE (70 - genPool.english.x / 4, _HEIGHT(0) - 70), 10, _RGB(72, 111, 183)


    CALL handlePocketSensors(body(), hits(), cueBall)
    CALL cleanUpInputDevice(iDevice)
END SUB

SUB handlePocketSensors (body() AS tBODY, hits() AS tHIT, cueBallId AS _INTEGER64)
    DIM AS LONG index, ballId
    FOR index = 0 TO 5 ' check if ball has been pocketed
        ballId = isBodyTouching(hits(), poolSensors(index).objId)
        IF ballId > 0 THEN
            IF ballId = cueBallId THEN
                body(ballId).position = pool(16).rackposition ' Move to break position
            ELSE
                body(ballId).position = pool(17).rackposition ' Move to ball return
            END IF
            CALL bodyStop(body(ballId))
        END IF
    NEXT
END SUB

SUB reRackBalls (body() AS tBODY)
    DIM AS INTEGER index
    FOR index = 1 TO 16
        body(pool(index).objId).position = pool(index).rackposition
        CALL bodyStop(body(pool(index).objId))
    NEXT
END SUB

SUB handleInputDevice (iDevice AS tINPUTDEVICE)
    ' iDevice.keyHit = _KEYHIT ' --- THIS IS TOO SLOW
    DO WHILE _MOUSEINPUT
        iDevice.x = _MOUSEX
        iDevice.y = _MOUSEY
        iDevice.b1 = _MOUSEBUTTON(1)
        iDevice.b2 = _MOUSEBUTTON(2)
        iDevice.b3 = _MOUSEBUTTON(3)
        iDevice.w = _MOUSEWHEEL
        iDevice.wCount = iDevice.wCount + iDevice.w
    LOOP
END SUB

SUB cleanUpInputDevice (iDevice AS tINPUTDEVICE)
    iDevice.lb1 = iDevice.b1
    iDevice.lb2 = iDevice.b2
    iDevice.lb3 = iDevice.b3
    iDevice.lastKeyHit = iDevice.keyHit
END SUB

FUNCTION bodyAtRest (body AS tBODY)
    bodyAtRest = (body.velocity.x < 1 AND body.velocity.x > -1 AND body.velocity.y < 1 AND body.velocity.y > -1)
END FUNCTION

SUB copyBodies (body() AS tBODY, newBody() AS tBODY)
    DIM AS LONG index
    FOR index = 0 TO UBOUND(body)
        newBody(index) = body(index)
    NEXT
END SUB

SUB buildSimpleScene (p() AS tPOLY, body() AS tBODY, j() AS tJOINT, textureMap() AS LONG, v() AS tVEHICLE)
    DIM AS INTEGER trans, index, ballSize
    DIM AS LONG iD
    DIM b AS STRING
    DIM AS _FLOAT bumperRestitution, bumperSF, bumperDF

    trans = 0 ' Adjust <0-255> to see the hidden rail bodies
    ballSize = 36
    bumperRestitution = .5
    bumperSF = .01 '.5
    bumperDF = .01 '.3
    j(0).jointName = "Nothing" ' this is just to clear the warning and does nothing
    v(0).vehicleName = "Nothing" ' Clear Warning
    CALL loadBitmap(textureMap())

    '********************************************************
    '   Setup World
    '********************************************************

    CALL vectorSet(world.minusLimit, -6500, -2000)
    CALL vectorSet(world.plusLimit, 70000, 10000)
    CALL vectorSet(world.spawn, -5000, -800)
    CALL vectorSet(world.gravity, 0.0, 0.0)
    CALL vectorSet(world.terrainPosition, -7000.0, 1000.0)
    DIM o AS tVECTOR2d: CALL vectorMultiplyScalarND(o, world.gravity, cDT): sRESTING = vectorLengthSq(o) + cEPSILON

    '********************************************************
    '   Build Table
    '********************************************************


    iD = createBoxBodiesEx(p(), body(), "cSCENE_TABLE", 1000, 600)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_TABLE", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_TABLE", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_COLLISIONMASK, "cSCENE_TABLE", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_TEXTURE, "cSCENE_TABLE", textureMap(19), 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BALLRETURN", 600, 100)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BALLRETURN", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BALLRETURN", 0, 800)
    CALL setBodyEx(body(), cPARAMETER_COLLISIONMASK, "cSCENE_BALLRETURN", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_TEXTURE, "cSCENE_BALLRETURN", textureMap(21), 0)


    '********************************************************
    '   Build Bumpers
    '********************************************************

    ' These are hidden using transparent colors

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BUMPER1", 370, 100)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BUMPER1", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BUMPER1", -445, -565)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BUMPER1", _RGBA32(0, 0, 255, trans), 0) ' blue
    CALL setBodyEx(body(), cPARAMETER_RESTITUTION, "cSCENE_BUMPER1", bumperRestitution, 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BUMPER1", bumperSF, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BUMPER1", bumperDF, 0)


    iD = createBoxBodiesEx(p(), body(), "cSCENE_BUMPER2", 370, 100)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BUMPER2", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BUMPER2", -445, 565)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BUMPER2", _RGBA32(255, 0, 0, trans), 0) ' red
    CALL setBodyEx(body(), cPARAMETER_RESTITUTION, "cSCENE_BUMPER2", bumperRestitution, 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BUMPER2", bumperSF, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BUMPER2", bumperDF, 0)


    iD = createBoxBodiesEx(p(), body(), "cSCENE_BUMPER3", 370, 100)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BUMPER3", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BUMPER3", 425, -565)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BUMPER3", _RGBA32(0, 255, 0, trans), 0) ' green
    CALL setBodyEx(body(), cPARAMETER_RESTITUTION, "cSCENE_BUMPER3", bumperRestitution, 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BUMPER3", bumperSF, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BUMPER3", bumperDF, 0)


    iD = createBoxBodiesEx(p(), body(), "cSCENE_BUMPER4", 370, 100)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BUMPER4", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BUMPER4", 425, 565)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BUMPER4", _RGBA32(255, 255, 0, trans), 0) ' red and green
    CALL setBodyEx(body(), cPARAMETER_RESTITUTION, "cSCENE_BUMPER4", bumperRestitution, 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BUMPER4", bumperSF, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BUMPER4", bumperDF, 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BUMPER5", 100, 390)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BUMPER5", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BUMPER5", -970, 0)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BUMPER5", _RGBA32(255, 0, 255, trans), 0) 'red and blue
    CALL setBodyEx(body(), cPARAMETER_RESTITUTION, "cSCENE_BUMPER5", bumperRestitution, 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BUMPER5", bumperSF, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BUMPER5", bumperDF, 0)


    iD = createBoxBodiesEx(p(), body(), "cSCENE_BUMPER6", 100, 390)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BUMPER6", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BUMPER6", 970, 0)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BUMPER6", _RGBA32(0, 255, 255, trans), 0) ' green and blue
    CALL setBodyEx(body(), cPARAMETER_RESTITUTION, "cSCENE_BUMPER6", bumperRestitution, 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BUMPER6", bumperSF, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BUMPER6", bumperDF, 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BORDER1", 50, 600)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BORDER1", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BORDER1", 970, 0)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BORDER1", _RGBA32(255, 255, 255, trans), 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BORDER2", 50, 600)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BORDER2", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BORDER2", -970, 0)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BORDER2", _RGBA32(255, 255, 255, trans), 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BORDER3", 1000, 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BORDER3", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BORDER3", 0, -560)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BORDER3", _RGBA32(255, 255, 255, trans), 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BORDER4", 1000, 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BORDER4", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BORDER4", 0, 560)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BORDER4", _RGBA32(255, 255, 255, trans), 0)


    '********************************************************
    '   Build Ball Return hidden surfaces
    '********************************************************
    ' These are hidden using transparent colors

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BALLRETURNBOTTOM", 600, 10)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BALLRETURNBOTTOM", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BALLRETURNBOTTOM", 0, 850)
    CALL setBodyEx(body(), cPARAMETER_ORIENT, "cSCENE_BALLRETURNBOTTOM", 0.01, 0)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BALLRETURNBOTTOM", _RGBA32(255, 255, 255, trans), 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BALLRETURNBOTTOM", 10, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BALLRETURNBOTTOM", 10, 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_BALLRETURNTOP", 600, 10)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BALLRETURNTOP", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BALLRETURNTOP", 0, 750)
    CALL setBodyEx(body(), cPARAMETER_ORIENT, "cSCENE_BALLRETURNTOP", 0.01, 0)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BALLRETURNTOP", _RGBA32(255, 255, 255, trans), 0)
    CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, "cSCENE_BALLRETURNTOP", 10, 0)
    CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, "cSCENE_BALLRETURNTOP", 10, 0)




    iD = createBoxBodiesEx(p(), body(), "cSCENE_BALLRETURNEND", 10, 40)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_BALLRETURNEND", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_BALLRETURNEND", 550, 800)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_BALLRETURNEND", _RGBA32(255, 255, 255, trans), 0)


    '********************************************************
    '   Pocket sensors
    '********************************************************

    iD = createCircleBodyEx(body(), "cSCENE_SENSOR1", 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_SENSOR1", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_SENSOR1", -5, 525)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_SENSOR1", _RGBA32(255, 255, 255, trans), 0)
    poolSensors(0).objId = objectManagerID(body(), "cSCENE_SENSOR1")

    iD = createCircleBodyEx(body(), "cSCENE_SENSOR2", 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_SENSOR2", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_SENSOR2", -5, -525)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_SENSOR2", _RGBA32(255, 255, 255, trans), 0)
    poolSensors(1).objId = objectManagerID(body(), "cSCENE_SENSOR2")

    iD = createCircleBodyEx(body(), "cSCENE_SENSOR3", 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_SENSOR3", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_SENSOR3", -900, -490)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_SENSOR3", _RGBA32(255, 255, 255, trans), 0)
    poolSensors(2).objId = objectManagerID(body(), "cSCENE_SENSOR3")

    iD = createCircleBodyEx(body(), "cSCENE_SENSOR4", 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_SENSOR4", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_SENSOR4", 900, -490)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_SENSOR4", _RGBA32(255, 255, 255, trans), 0)
    poolSensors(3).objId = objectManagerID(body(), "cSCENE_SENSOR4")

    iD = createCircleBodyEx(body(), "cSCENE_SENSOR5", 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_SENSOR5", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_SENSOR5", -900, 490)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_SENSOR5", _RGBA32(255, 255, 255, trans), 0)
    poolSensors(4).objId = objectManagerID(body(), "cSCENE_SENSOR5")

    iD = createCircleBodyEx(body(), "cSCENE_SENSOR6", 50)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_SENSOR6", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_SENSOR6", 900, 490)
    CALL setBodyEx(body(), cPARAMETER_COLOR, "cSCENE_SENSOR6", _RGBA32(255, 255, 255, trans), 0)
    poolSensors(5).objId = objectManagerID(body(), "cSCENE_SENSOR6")

    '********************************************************
    '   Place Balls
    '********************************************************
    DIM AS _FLOAT rX, rY

    FOR index = 1 TO 17
        READ rX, rY
        CALL vectorSet(pool(index).rackposition, rX, rY)
    NEXT

    FOR index = 1 TO 16
        b = "cSCENE_BALL" + LTRIM$(STR$(index))
        iD = createCircleBodyEx(body(), b, ballSize)
        CALL setBodyEx(body(), cPARAMETER_TEXTURE, b, textureMap(index), 0)
        CALL setBodyEx(body(), cPARAMETER_RESTITUTION, b, 1.00, 0)
        CALL setBodyEx(body(), cPARAMETER_STATICFRICTION, b, .50, 0) '.5
        CALL setBodyEx(body(), cPARAMETER_DYNAMICFRICTION, b, .30, 0) '.3
        CALL setBodyEx(body(), cPARAMETER_POSITION, b, pool(index).rackposition.x, pool(index).rackposition.y)
        pool(index).objId = iD
        pool(index).status = 0
    NEXT

    '********************************************************
    '   Cue Stick
    '********************************************************

    DIM tv AS tVECTOR2d
    CALL vectorSet(tv, 500, 0)

    iD = createBoxBodiesEx(p(), body(), "cSCENE_CUE", 400, 10)
    CALL setBodyEx(body(), cPARAMETER_STATIC, "cSCENE_CUE", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_POSITION, "cSCENE_CUE", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_COLLISIONMASK, "cSCENE_CUE", 0, 0)
    CALL setBodyEx(body(), cPARAMETER_TEXTURE, "cSCENE_CUE", textureMap(18), 0)

    DATA -475,0
    DATA -548,38
    DATA -494,-19
    DATA -530,-19
    DATA -548,-38
    DATA -512,38
    DATA -548,75
    DATA -512,0
    DATA -530,-57
    DATA -548,0
    DATA -494,19
    DATA -548,-75
    DATA -530,57
    DATA -512,-38
    DATA -530,19
    DATA 525,0
    DATA -500,800

    textureMap(22) = _NEWIMAGE(_WIDTH(0) / 2, _HEIGHT(0) / 2, 32) 'GUI
    _DEST textureMap(22)
    _PRINTMODE _KEEPBACKGROUND
    LOCATE 1, 1
    PRINT "QB Pool: No rules."
    PRINT "Instructions:"
    PRINT "- 'I' or 'i' to show these instructions."
    PRINT "- Use Mouse to Aim."
    PRINT "- Mouse also controls power."
    PRINT "- Mousewheel to adjust zoom."
    PRINT "- LEFT and RIGHT arrow keys for English."
    PRINT "- 'R' or 'r' to rerack balls."
    PRINT "- <SPACE> to hit harder. Example for a break."
    PRINT "- <TAB> to test your shot. ;)"
    PRINT "- <ESC> to quit."
    genPool.instructions = 1
    _DEST 0

END SUB

SUB bodyStop (body AS tBODY)
    CALL vectorSet(body.velocity, 0, 0)
    body.angularVelocity = 0
END SUB

SUB bodyOffset (body() AS tBODY, p() AS tPOLY, index AS LONG, vec AS tVECTOR2d)
    DIM i AS INTEGER
    FOR i = 0 TO body(index).pa.count
        CALL vectorAddVector(p(body(index).pa.start + i).vert, vec)
    NEXT
END SUB


FUNCTION objectContainsString (body() AS tBODY, start AS INTEGER, s AS STRING)
    objectContainsString = -1
    DIM AS INTEGER j
    FOR j = start TO objectManager.objectCount
        IF INSTR(body(j).objectName, s) THEN
            objectContainsString = j
            EXIT FUNCTION
        END IF
    NEXT
END FUNCTION
'**********************************************************************************************
'   Collision Helper Tools
'**********************************************************************************************

FUNCTION isBodyTouchingBody (hits() AS tHIT, A AS INTEGER, B AS INTEGER)
    DIM hitcount AS INTEGER: hitcount = 1
    isBodyTouchingBody = 0
    DO WHILE hits(hitcount).A <> hits(hitcount).B
        IF hits(hitcount).A = A AND hits(hitcount).B = B THEN
            isBodyTouchingBody = hitcount
            EXIT FUNCTION
        END IF
        hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
    LOOP
END FUNCTION

FUNCTION isBodyTouchingStatic (body() AS tBODY, hits() AS tHIT, A AS INTEGER)
    DIM hitcount AS INTEGER: hitcount = 1
    isBodyTouchingStatic = 0
    DO WHILE hits(hitcount).A <> hits(hitcount).B
        IF hits(hitcount).A = A THEN
            IF body(hits(hitcount).B).mass = 0 THEN
                isBodyTouchingStatic = hitcount
                EXIT FUNCTION
            END IF
        ELSE
            IF hits(hitcount).B = A THEN
                IF body(hits(hitcount).A).mass = 0 THEN
                    isBodyTouchingStatic = hitcount
                    EXIT FUNCTION
                END IF
            END IF
        END IF
        hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
    LOOP
END FUNCTION

FUNCTION isBodyTouching (hits() AS tHIT, A AS INTEGER)
    DIM hitcount AS INTEGER: hitcount = 1
    isBodyTouching = 0
    DO WHILE hits(hitcount).A <> hits(hitcount).B
        IF hits(hitcount).A = A THEN
            isBodyTouching = hits(hitcount).B
            EXIT FUNCTION
        END IF
        IF hits(hitcount).B = A THEN
            isBodyTouching = hits(hitcount).A
            EXIT FUNCTION
        END IF

        hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
    LOOP
END FUNCTION

FUNCTION highestCollisionVelocity (hits() AS tHIT, A AS INTEGER) ' this function is a bit dubious and may not do as you think
    DIM hitcount AS INTEGER: hitcount = 1
    DIM hiCv AS _FLOAT: hiCv = 0
    highestCollisionVelocity = 0
    DO WHILE hits(hitcount).A <> hits(hitcount).B
        IF hits(hitcount).A = A AND ABS(hits(hitcount).cv) > hiCv AND hits(hitcount).cv < 0 THEN
            hiCv = ABS(hits(hitcount).cv)
        END IF
        hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
    LOOP
    highestCollisionVelocity = hiCv
END FUNCTION

'**********************************************************************************************
'   Physics and Collision Stuff Ahead
'**********************************************************************************************

SUB impulseIntegrateForces (b AS tBODY, dt AS _FLOAT)
    IF b.invMass = 0.0 THEN EXIT SUB
    DIM dts AS _FLOAT
    dts = dt * .5
    CALL vectorAddVectorScalar(b.velocity, b.force, b.invMass * dts)
    CALL vectorAddVectorScalar(b.velocity, world.gravity, dts)
    b.angularVelocity = b.angularVelocity + (b.torque * b.invInertia * dts)
END SUB

SUB impulseIntegrateVelocity (body AS tBODY, dt AS _FLOAT)
    IF body.invMass = 0.0 THEN EXIT SUB
    body.velocity.x = body.velocity.x * (1 - dt)
    body.velocity.y = body.velocity.y * (1 - dt)
    body.angularVelocity = body.angularVelocity * (1 - dt)
    CALL vectorAddVectorScalar(body.position, body.velocity, dt)
    body.orient = body.orient + (body.angularVelocity * dt)
    CALL matrixSetRadians(body.shape.u, body.orient)
    CALL impulseIntegrateForces(body, dt)
END SUB

SUB impulseStep (p() AS tPOLY, body() AS tBODY, j() AS tJOINT, hits() AS tHIT, dt AS _FLOAT, iterations AS INTEGER)
    DIM A AS tBODY
    DIM B AS tBODY
    DIM c(cMAXNUMBEROFOBJECTS) AS tVECTOR2d
    DIM m AS tMANIFOLD
    DIM manifolds(sNUMBEROFBODIES * sNUMBEROFBODIES) AS tMANIFOLD
    DIM collisions(sNUMBEROFBODIES * sNUMBEROFBODIES, cMAXNUMBEROFOBJECTS) AS tVECTOR2d
    DIM manifoldCount AS INTEGER: manifoldCount = 0
    '    // Generate new collision info
    DIM i, j, k AS LONG
    DIM hitCount AS LONG: hitCount = 0
    DIM dHit AS tHIT 'empty
    ' // erase hitlist
    DO
        hits(hitCount) = dHit
        hitCount = hitCount + 1
    LOOP UNTIL hitCount > UBOUND(hits)
    hitCount = 0

    FOR i = 0 TO objectManager.objectCount ' number of bodies
        A = body(i)
        IF A.enable THEN
            FOR j = i + 1 TO objectManager.objectCount
                B = body(j)
                IF (A.collisionMask AND B.collisionMask) THEN
                    IF A.invMass = 0.0 AND B.invMass = 0.0 THEN _CONTINUE
                    'Mainfold solve - handle collisions
                    IF AABBOverlapVector(A.position, 2000, 2000, B.position, 2000, 2000) THEN
                        IF A.shape.ty = cSHAPE_CIRCLE AND B.shape.ty = cSHAPE_CIRCLE THEN
                            CALL collisionCCHandle(m, c(), A, B)
                        ELSE
                            IF A.shape.ty = cSHAPE_POLYGON AND B.shape.ty = cSHAPE_POLYGON THEN
                                CALL collisionPPHandle(p(), body(), m, c(), i, j)
                            ELSE
                                IF A.shape.ty = cSHAPE_CIRCLE AND B.shape.ty = cSHAPE_POLYGON THEN
                                    CALL collisionCPHandle(p(), body(), m, c(), i, j)
                                ELSE
                                    IF B.shape.ty = cSHAPE_CIRCLE AND A.shape.ty = cSHAPE_POLYGON THEN
                                        CALL collisionPCHandle(p(), body(), m, c(), i, j)
                                    END IF
                                END IF
                            END IF
                        END IF

                        IF m.contactCount > 0 THEN
                            m.A = i 'identify the index of objects
                            m.B = j
                            manifolds(manifoldCount) = m
                            FOR k = 0 TO m.contactCount
                                hits(hitCount).A = i
                                hits(hitCount).B = j
                                hits(hitCount).position = c(k)
                                collisions(manifoldCount, k) = c(k)
                                hitCount = hitCount + 1
                                IF hitCount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitCount * 1.5) AS tHIT
                            NEXT
                            manifoldCount = manifoldCount + 1
                            IF manifoldCount > UBOUND(manifolds) THEN REDIM _PRESERVE manifolds(manifoldCount * 1.5) AS tMANIFOLD
                        END IF
                    END IF
                END IF
            NEXT
        END IF
    NEXT

    '   // Integrate forces
    FOR i = 0 TO objectManager.objectCount
        IF body(i).enable THEN CALL impulseIntegrateForces(body(i), dt)
    NEXT
    '   // Initialize collision
    FOR i = 0 TO manifoldCount - 1
        ' this is the stupidest thing ever since QB will not let you split arrays
        FOR k = 0 TO manifolds(i).contactCount - 1
            c(k) = collisions(i, k)
        NEXT
        CALL manifoldInit(manifolds(i), body(), c())
    NEXT
    ' joint pre Steps

    FOR i = 1 TO sNUMBEROFJOINTS
        CALL jointPrestep(j(i), body(), dt)
    NEXT

    '// Solve collisions
    FOR j = 0 TO iterations - 1
        FOR i = 0 TO manifoldCount - 1
            FOR k = 0 TO manifolds(i).contactCount - 1
                c(k) = collisions(i, k)
            NEXT
            CALL manifoldApplyImpulse(manifolds(i), body(), c())
            'store the hit speed for later
            FOR k = 0 TO hitCount - 1
                IF manifolds(i).A = hits(k).A AND manifolds(i).B = hits(k).B THEN
                    hits(k).cv = manifolds(i).cv
                END IF
            NEXT
        NEXT
        FOR i = 1 TO sNUMBEROFJOINTS
            CALL jointApplyImpulse(j(i), body())
        NEXT
    NEXT

    '// Integrate velocities
    FOR i = 0 TO objectManager.objectCount
        IF body(i).enable THEN CALL impulseIntegrateVelocity(body(i), dt)
    NEXT
    '// Correct positions
    FOR i = 0 TO manifoldCount - 1
        CALL manifoldPositionalCorrection(manifolds(i), body())
    NEXT
    '// Clear all forces
    FOR i = 0 TO objectManager.objectCount
        CALL vectorSet(body(i).force, 0, 0)
        body(i).torque = 0
    NEXT
END SUB

SUB bodyApplyImpulse (body AS tBODY, impulse AS tVECTOR2d, contactVector AS tVECTOR2d)
    CALL vectorAddVectorScalar(body.velocity, impulse, body.invMass)
    body.angularVelocity = body.angularVelocity + body.invInertia * vectorCross(contactVector, impulse)
END SUB

SUB bodySetStatic (body AS tBODY)
    body.inertia = 0.0
    body.invInertia = 0.0
    body.mass = 0.0
    body.invMass = 0.0
END SUB

SUB manifoldInit (m AS tMANIFOLD, body() AS tBODY, contacts() AS tVECTOR2d)
    DIM ra AS tVECTOR2d
    DIM rb AS tVECTOR2d
    DIM rv AS tVECTOR2d
    DIM tv1 AS tVECTOR2d 'temporary Vectors
    DIM tv2 AS tVECTOR2d
    m.e = scalarMin(body(m.A).restitution, body(m.B).restitution)
    m.sf = SQR(body(m.A).staticFriction * body(m.A).staticFriction)
    m.df = SQR(body(m.A).dynamicFriction * body(m.A).dynamicFriction)
    DIM i AS INTEGER
    FOR i = 0 TO m.contactCount - 1
        CALL vectorSubVectorND(contacts(i), body(m.A).position, ra)
        CALL vectorSubVectorND(contacts(i), body(m.B).position, rb)

        CALL vectorCrossScalar(tv1, rb, body(m.B).angularVelocity)
        CALL vectorCrossScalar(tv2, ra, body(m.A).angularVelocity)
        CALL vectorAddVector(tv1, body(m.B).velocity)
        CALL vectorSubVectorND(tv2, body(m.A).velocity, tv2)
        CALL vectorSubVectorND(rv, tv1, tv2)

        IF vectorLengthSq(rv) < sRESTING THEN
            m.e = 0.0
        END IF
    NEXT
END SUB

SUB manifoldApplyImpulse (m AS tMANIFOLD, body() AS tBODY, contacts() AS tVECTOR2d)
    DIM ra AS tVECTOR2d
    DIM rb AS tVECTOR2d
    DIM rv AS tVECTOR2d
    DIM tv1 AS tVECTOR2d 'temporary Vectors
    DIM tv2 AS tVECTOR2d
    DIM contactVel AS _FLOAT

    DIM raCrossN AS _FLOAT
    DIM rbCrossN AS _FLOAT
    DIM invMassSum AS _FLOAT
    DIM i AS INTEGER
    DIM j AS _FLOAT
    DIM impulse AS tVECTOR2d

    DIM t AS tVECTOR2d
    DIM jt AS _FLOAT
    DIM tangentImpulse AS tVECTOR2d

    IF impulseEqual(body(m.A).invMass + body(m.B).invMass, 0.0) THEN
        CALL manifoldInfiniteMassCorrection(body(m.A), body(m.B))
        EXIT SUB
    END IF

    FOR i = 0 TO m.contactCount - 1
        '// Calculate radii from COM to contact
        '// Vec2 ra = contacts[i] - A->position;
        '// Vec2 rb = contacts[i] - B->position;
        CALL vectorSubVectorND(ra, contacts(i), body(m.A).position)
        CALL vectorSubVectorND(rb, contacts(i), body(m.B).position)

        '// Relative velocity
        '// Vec2 rv = B->velocity + Cross( B->angularVelocity, rb ) - A->velocity - Cross( A->angularVelocity, ra );
        CALL vectorCrossScalar(tv1, rb, body(m.B).angularVelocity)
        CALL vectorCrossScalar(tv2, ra, body(m.A).angularVelocity)
        CALL vectorAddVectorND(rv, tv1, body(m.B).velocity)
        CALL vectorSubVector(rv, body(m.A).velocity)
        CALL vectorSubVector(rv, tv2)

        '// Relative velocity along the normal
        '// real contactVel = Dot( rv, normal );
        contactVel = vectorDot(rv, m.normal)

        '// Do not resolve if velocities are separating
        IF contactVel > 0 THEN EXIT SUB
        m.cv = contactVel
        '// real raCrossN = Cross( ra, normal );
        '// real rbCrossN = Cross( rb, normal );
        '// real invMassSum = A->im + B->im + Sqr( raCrossN ) * A->iI + Sqr( rbCrossN ) * B->iI;
        raCrossN = vectorCross(ra, m.normal)
        rbCrossN = vectorCross(rb, m.normal)
        invMassSum = body(m.A).invMass + body(m.B).invMass + (raCrossN * raCrossN) * body(m.A).invInertia + (rbCrossN * rbCrossN) * body(m.B).invInertia

        '// Calculate impulse scalar
        j = -(1.0 + m.e) * contactVel
        j = j / invMassSum
        j = j / m.contactCount

        '// Apply impulse
        CALL vectorMultiplyScalarND(impulse, m.normal, j)
        CALL vectorNegND(tv1, impulse)
        CALL bodyApplyImpulse(body(m.A), tv1, ra)
        CALL bodyApplyImpulse(body(m.B), impulse, rb)

        '// Friction impulse
        '// rv = B->velocity + Cross( B->angularVelocity, rb ) - A->velocity - Cross( A->angularVelocity, ra );
        CALL vectorCrossScalar(tv1, rb, body(m.B).angularVelocity)
        CALL vectorCrossScalar(tv2, ra, body(m.A).angularVelocity)
        CALL vectorAddVectorND(rv, tv1, body(m.B).velocity)
        CALL vectorSubVector(rv, body(m.A).velocity)
        CALL vectorSubVector(rv, tv2)

        '// Vec2 t = rv - (normal * Dot( rv, normal ));
        '// t.Normalize( );
        CALL vectorMultiplyScalarND(t, m.normal, vectorDot(rv, m.normal))
        CALL vectorSubVectorND(t, rv, t)
        CALL vectorNormalize(t)

        '// j tangent magnitude
        jt = -vectorDot(rv, t)
        jt = jt / invMassSum
        jt = jt / m.contactCount

        '// Don't apply tiny friction impulses
        IF impulseEqual(jt, 0.0) THEN EXIT SUB

        '// Coulumb's law
        IF ABS(jt) < j * m.sf THEN
            CALL vectorMultiplyScalarND(tangentImpulse, t, jt)
        ELSE
            CALL vectorMultiplyScalarND(tangentImpulse, t, -j * m.df)
        END IF

        '// Apply friction impulse
        '// A->ApplyImpulse( -tangentImpulse, ra );
        '// B->ApplyImpulse( tangentImpulse, rb );
        CALL vectorNegND(tv1, tangentImpulse)
        CALL bodyApplyImpulse(body(m.A), tv1, ra)
        CALL bodyApplyImpulse(body(m.B), tangentImpulse, rb)
    NEXT i
END SUB

SUB manifoldPositionalCorrection (m AS tMANIFOLD, body() AS tBODY)
    DIM correction AS _FLOAT
    correction = scalarMax(m.penetration - cPENETRATION_ALLOWANCE, 0.0) / (body(m.A).invMass + body(m.B).invMass) * cPENETRATION_CORRECTION
    CALL vectorAddVectorScalar(body(m.A).position, m.normal, -body(m.A).invMass * correction)
    CALL vectorAddVectorScalar(body(m.B).position, m.normal, body(m.B).invMass * correction)
END SUB

SUB manifoldInfiniteMassCorrection (A AS tBODY, B AS tBODY)
    CALL vectorSet(A.velocity, 0, 0)
    CALL vectorSet(B.velocity, 0, 0)
END SUB

'**********************************************************************************************
'   Collision Stuff Ahead
'**********************************************************************************************

SUB collisionCCHandle (m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS tBODY, B AS tBODY)
    DIM normal AS tVECTOR2d
    DIM dist_sqr AS _FLOAT
    DIM radius AS _FLOAT

    CALL vectorSubVectorND(normal, B.position, A.position) ' Subtract two vectors position A and position B
    dist_sqr = vectorLengthSq(normal) ' Calculate the distance between the balls or circles
    radius = A.shape.radius + B.shape.radius ' Add both circle A and circle B radius

    IF (dist_sqr >= radius * radius) THEN
        m.contactCount = 0
    ELSE
        DIM distance AS _FLOAT
        distance = SQR(dist_sqr)
        m.contactCount = 1

        IF distance = 0 THEN
            m.penetration = A.shape.radius
            CALL vectorSet(m.normal, 1.0, 0.0)
            CALL vectorSetVector(contacts(0), A.position)
        ELSE
            m.penetration = radius - distance
            CALL vectorDivideScalarND(m.normal, normal, distance)

            CALL vectorMultiplyScalarND(contacts(0), m.normal, A.shape.radius)
            CALL vectorAddVector(contacts(0), A.position)
        END IF
    END IF
END SUB

SUB collisionPCHandle (p() AS tPOLY, body() AS tBODY, m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS INTEGER, B AS INTEGER)
    CALL collisionCPHandle(p(), body(), m, contacts(), B, A)
    IF m.contactCount > 0 THEN
        CALL vectorNeg(m.normal)
    END IF
END SUB

SUB collisionCPHandle (p() AS tPOLY, body() AS tBODY, m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS INTEGER, B AS INTEGER)
    'A is the Circle
    'B is the POLY
    m.contactCount = 0
    DIM center AS tVECTOR2d
    DIM tm AS tMATRIX2d
    DIM tv AS tVECTOR2d
    DIM ARadius AS _FLOAT: ARadius = body(A).shape.radius

    CALL vectorSubVectorND(center, body(A).position, body(B).position)
    CALL matrixTranspose(body(B).shape.u, tm)
    CALL matrixMultiplyVector(tm, center, center)

    DIM separation AS _FLOAT: separation = -9999999
    DIM faceNormal AS INTEGER: faceNormal = 0
    DIM i AS INTEGER
    DIM s AS _FLOAT
    FOR i = 0 TO body(B).pa.count
        CALL vectorSubVectorND(tv, center, p(body(B).pa.start + i).vert)
        s = vectorDot(p(body(B).pa.start + i).norm, tv)
        IF s > ARadius THEN EXIT SUB
        IF s > separation THEN
            separation = s
            faceNormal = i
        END IF
    NEXT
    DIM v1 AS tVECTOR2d
    v1 = p(body(B).pa.start + faceNormal).vert
    DIM i2 AS INTEGER
    i2 = body(B).pa.start + arrayNextIndex(faceNormal, body(B).pa.count)
    DIM v2 AS tVECTOR2d
    v2 = p(i2).vert

    IF separation < cEPSILON THEN
        m.contactCount = 1
        CALL matrixMultiplyVector(body(B).shape.u, p(body(B).pa.start + faceNormal).norm, m.normal)
        CALL vectorNeg(m.normal)
        CALL vectorMultiplyScalarND(contacts(0), m.normal, ARadius)
        CALL vectorAddVector(contacts(0), body(A).position)
        m.penetration = ARadius
        EXIT SUB
    END IF

    DIM dot1 AS _FLOAT
    DIM dot2 AS _FLOAT

    DIM tv1 AS tVECTOR2d
    DIM tv2 AS tVECTOR2d
    DIM n AS tVECTOR2d
    CALL vectorSubVectorND(tv1, center, v1)
    CALL vectorSubVectorND(tv2, v2, v1)
    dot1 = vectorDot(tv1, tv2)
    CALL vectorSubVectorND(tv1, center, v2)
    CALL vectorSubVectorND(tv2, v1, v2)
    dot2 = vectorDot(tv1, tv2)
    m.penetration = ARadius - separation
    IF dot1 <= 0.0 THEN
        IF vectorSqDist(center, v1) > ARadius * ARadius THEN EXIT SUB
        m.contactCount = 1
        CALL vectorSubVectorND(n, v1, center)
        CALL matrixMultiplyVector(body(B).shape.u, n, n)
        CALL vectorNormalize(n)
        m.normal = n
        CALL matrixMultiplyVector(body(B).shape.u, v1, v1)
        CALL vectorAddVectorND(v1, v1, body(B).position)
        contacts(0) = v1
    ELSE
        IF dot2 <= 0.0 THEN
            IF vectorSqDist(center, v2) > ARadius * ARadius THEN EXIT SUB
            m.contactCount = 1
            CALL vectorSubVectorND(n, v2, center)
            CALL matrixMultiplyVector(body(B).shape.u, v2, v2)
            CALL vectorAddVectorND(v2, v2, body(B).position)
            contacts(0) = v2
            CALL matrixMultiplyVector(body(B).shape.u, n, n)
            CALL vectorNormalize(n)
            m.normal = n
        ELSE
            n = p(body(B).pa.start + faceNormal).norm
            CALL vectorSubVectorND(tv1, center, v1)
            IF vectorDot(tv1, n) > ARadius THEN EXIT SUB
            m.contactCount = 1
            CALL matrixMultiplyVector(body(B).shape.u, n, n)
            CALL vectorNeg(n)
            m.normal = n
            CALL vectorMultiplyScalarND(contacts(0), m.normal, ARadius)
            CALL vectorAddVector(contacts(0), body(A).position)
        END IF
    END IF
END SUB

FUNCTION collisionPPClip (n AS tVECTOR2d, c AS _FLOAT, face() AS tVECTOR2d)
    DIM sp AS INTEGER: sp = 0
    DIM o(cMAXNUMBEROFPOLYGONS) AS tVECTOR2d

    o(0) = face(0)
    o(1) = face(1)

    DIM d1 AS _FLOAT: d1 = vectorDot(n, face(0)) - c
    DIM d2 AS _FLOAT: d2 = vectorDot(n, face(1)) - c

    IF d1 <= 0.0 THEN
        o(sp) = face(0)
        sp = sp + 1
    END IF

    IF d2 <= 0.0 THEN
        o(sp) = face(1)
        sp = sp + 1
    END IF

    IF d1 * d2 < 0.0 THEN
        DIM alpha AS _FLOAT: alpha = d1 / (d1 - d2)
        DIM tempv AS tVECTOR2d
        'out[sp] = face[0] + alpha * (face[1] - face[0]);
        CALL vectorSubVectorND(tempv, face(1), face(0))
        CALL vectorMultiplyScalar(tempv, alpha)
        CALL vectorAddVectorND(o(sp), tempv, face(0))
        sp = sp + 1
    END IF
    face(0) = o(0)
    face(1) = o(1)
    collisionPPClip = sp
END FUNCTION

SUB collisionPPFindIncidentFace (p() AS tPOLY, b() AS tBODY, v() AS tVECTOR2d, RefPoly AS INTEGER, IncPoly AS INTEGER, referenceIndex AS INTEGER)
    DIM referenceNormal AS tVECTOR2d
    DIM uRef AS tMATRIX2d: uRef = b(RefPoly).shape.u
    DIM uInc AS tMATRIX2d: uInc = b(IncPoly).shape.u
    DIM uTemp AS tMATRIX2d
    DIM i AS INTEGER
    referenceNormal = p(b(RefPoly).pa.start + referenceIndex).norm

    '        // Calculate normal in incident's frame of reference
    '        // referenceNormal = RefPoly->u * referenceNormal; // To world space
    CALL matrixMultiplyVector(uRef, referenceNormal, referenceNormal)
    '        // referenceNormal = IncPoly->u.Transpose( ) * referenceNormal; // To incident's model space
    CALL matrixTranspose(uInc, uTemp)
    CALL matrixMultiplyVector(uTemp, referenceNormal, referenceNormal)

    DIM incidentFace AS INTEGER: incidentFace = 0
    DIM minDot AS _FLOAT: minDot = 9999999
    DIM dot AS _FLOAT
    FOR i = 0 TO b(IncPoly).pa.count
        dot = vectorDot(referenceNormal, p(b(IncPoly).pa.start + i).norm)
        IF (dot < minDot) THEN
            minDot = dot
            incidentFace = i
        END IF
    NEXT

    '// Assign face vertices for incidentFace
    '// v[0] = IncPoly->u * IncPoly->m_vertices[incidentFace] + IncPoly->body->position;
    CALL matrixMultiplyVector(uInc, p(b(IncPoly).pa.start + incidentFace).vert, v(0))
    CALL vectorAddVector(v(0), b(IncPoly).position)

    '// incidentFace = incidentFace + 1 >= (int32)IncPoly->m_vertexCount ? 0 : incidentFace + 1;
    incidentFace = arrayNextIndex(incidentFace, b(IncPoly).pa.count)

    '// v[1] = IncPoly->u * IncPoly->m_vertices[incidentFace] +  IncPoly->body->position;
    CALL matrixMultiplyVector(uInc, p(b(IncPoly).pa.start + incidentFace).vert, v(1))
    CALL vectorAddVector(v(1), b(IncPoly).position)
END SUB

SUB collisionPPHandle (p() AS tPOLY, body() AS tBODY, m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS INTEGER, B AS INTEGER)
    m.contactCount = 0

    DIM faceA(100) AS INTEGER

    DIM penetrationA AS _FLOAT
    penetrationA = collisionPPFindAxisLeastPenetration(p(), body(), faceA(), A, B)
    IF penetrationA >= 0.0 THEN EXIT SUB

    DIM faceB(100) AS INTEGER

    DIM penetrationB AS _FLOAT
    penetrationB = collisionPPFindAxisLeastPenetration(p(), body(), faceB(), B, A)
    IF penetrationB >= 0.0 THEN EXIT SUB


    DIM referenceIndex AS INTEGER
    DIM flip AS INTEGER

    DIM RefPoly AS INTEGER
    DIM IncPoly AS INTEGER

    IF impulseGT(penetrationA, penetrationB) THEN
        RefPoly = A
        IncPoly = B
        referenceIndex = faceA(0)
        flip = 0
    ELSE
        RefPoly = B
        IncPoly = A
        referenceIndex = faceB(0)
        flip = 1
    END IF

    DIM incidentFace(2) AS tVECTOR2d

    CALL collisionPPFindIncidentFace(p(), body(), incidentFace(), RefPoly, IncPoly, referenceIndex)
    DIM v1 AS tVECTOR2d
    DIM v2 AS tVECTOR2d
    DIM v1t AS tVECTOR2d
    DIM v2t AS tVECTOR2d

    v1 = p(body(RefPoly).pa.start + referenceIndex).vert
    referenceIndex = arrayNextIndex(referenceIndex, body(RefPoly).pa.count)
    v2 = p(body(RefPoly).pa.start + referenceIndex).vert
    '// Transform vertices to world space
    '// v1 = RefPoly->u * v1 + RefPoly->body->position;
    '// v2 = RefPoly->u * v2 + RefPoly->body->position;
    CALL matrixMultiplyVector(body(RefPoly).shape.u, v1, v1t)
    CALL vectorAddVectorND(v1, v1t, body(RefPoly).position)
    CALL matrixMultiplyVector(body(RefPoly).shape.u, v2, v2t)
    CALL vectorAddVectorND(v2, v2t, body(RefPoly).position)

    '// Calculate reference face side normal in world space
    '// Vec2 sidePlaneNormal = (v2 - v1);
    '// sidePlaneNormal.Normalize( );
    DIM sidePlaneNormal AS tVECTOR2d
    CALL vectorSubVectorND(sidePlaneNormal, v2, v1)
    CALL vectorNormalize(sidePlaneNormal)

    '// Orthogonalize
    '// Vec2 refFaceNormal( sidePlaneNormal.y, -sidePlaneNormal.x );
    DIM refFaceNormal AS tVECTOR2d
    CALL vectorSet(refFaceNormal, sidePlaneNormal.y, -sidePlaneNormal.x)

    '// ax + by = c
    '// c is distance from origin
    '// real refC = Dot( refFaceNormal, v1 );
    '// real negSide = -Dot( sidePlaneNormal, v1 );
    '// real posSide = Dot( sidePlaneNormal, v2 );
    DIM refC AS _FLOAT: refC = vectorDot(refFaceNormal, v1)
    DIM negSide AS _FLOAT: negSide = -vectorDot(sidePlaneNormal, v1)
    DIM posSide AS _FLOAT: posSide = vectorDot(sidePlaneNormal, v2)


    '// Clip incident face to reference face side planes
    '// if(Clip( -sidePlaneNormal, negSide, incidentFace ) < 2)
    DIM negSidePlaneNormal AS tVECTOR2d
    CALL vectorNegND(negSidePlaneNormal, sidePlaneNormal)

    IF collisionPPClip(negSidePlaneNormal, negSide, incidentFace()) < 2 THEN EXIT SUB
    IF collisionPPClip(sidePlaneNormal, posSide, incidentFace()) < 2 THEN EXIT SUB

    CALL vectorSet(m.normal, refFaceNormal.x, refFaceNormal.y)
    IF flip THEN CALL vectorNeg(m.normal)

    '// Keep points behind reference face
    DIM cp AS INTEGER: cp = 0 '// clipped points behind reference face
    DIM separation AS _FLOAT
    separation = vectorDot(refFaceNormal, incidentFace(0)) - refC
    IF separation <= 0.0 THEN
        contacts(cp) = incidentFace(0)
        m.penetration = -separation
        cp = cp + 1
    ELSE
        m.penetration = 0
    END IF

    separation = vectorDot(refFaceNormal, incidentFace(1)) - refC
    IF separation <= 0.0 THEN
        contacts(cp) = incidentFace(1)
        m.penetration = m.penetration + -separation
        cp = cp + 1
        m.penetration = m.penetration / cp
    END IF
    m.contactCount = cp
END SUB

FUNCTION collisionPPFindAxisLeastPenetration (p() AS tPOLY, body() AS tBODY, faceIndex() AS INTEGER, A AS INTEGER, B AS INTEGER)
    DIM bestDistance AS _FLOAT: bestDistance = -9999999
    DIM bestIndex AS INTEGER: bestIndex = 0

    DIM n AS tVECTOR2d
    DIM nw AS tVECTOR2d
    DIM buT AS tMATRIX2d
    DIM s AS tVECTOR2d
    DIM nn AS tVECTOR2d
    DIM v AS tVECTOR2d
    DIM tv AS tVECTOR2d
    DIM d AS _FLOAT
    DIM i, k AS INTEGER

    FOR i = 0 TO body(A).pa.count
        k = body(A).pa.start + i

        '// Retrieve a face normal from A
        '// Vec2 n = A->m_normals[i];
        '// Vec2 nw = A->u * n;
        n = p(k).norm
        CALL matrixMultiplyVector(body(A).shape.u, n, nw)


        '// Transform face normal into B's model space
        '// Mat2 buT = B->u.Transpose( );
        '// n = buT * nw;
        CALL matrixTranspose(body(B).shape.u, buT)
        CALL matrixMultiplyVector(buT, nw, n)

        '// Retrieve support point from B along -n
        '// Vec2 s = B->GetSupport( -n );
        CALL vectorNegND(nn, n)
        CALL vectorGetSupport(p(), body(), B, nn, s)

        '// Retrieve vertex on face from A, transform into
        '// B's model space
        '// Vec2 v = A->m_vertices[i];
        '// v = A->u * v + A->body->position;
        '// v -= B->body->position;
        '// v = buT * v;

        v = p(k).vert
        CALL matrixMultiplyVector(body(A).shape.u, v, tv)
        CALL vectorAddVectorND(v, tv, body(A).position)

        CALL vectorSubVector(v, body(B).position)
        CALL matrixMultiplyVector(buT, v, tv)

        CALL vectorSubVector(s, tv)
        d = vectorDot(n, s)

        IF d > bestDistance THEN
            bestDistance = d
            bestIndex = i
        END IF

    NEXT i

    faceIndex(0) = bestIndex

    collisionPPFindAxisLeastPenetration = bestDistance
END FUNCTION

'**********************************************************************************************
'   Shape Creation Ahead
'**********************************************************************************************

SUB shapeCreate (sh AS tSHAPE, ty AS INTEGER, radius AS _FLOAT)
    DIM u AS tMATRIX2d
    CALL matrixSetScalar(u, 1, 0, 0, 1)
    sh.ty = ty
    sh.radius = radius
    sh.u = u
    sh.scaleTextureX = 1.0
    sh.scaleTextureY = 1.0
END SUB

'**********************************************************************************************
'   Scene Creation Tools ahead
'**********************************************************************************************

SUB setBody (body() AS tBODY, Parameter AS INTEGER, Index AS INTEGER, arg1 AS _FLOAT, arg2 AS _FLOAT)
    SELECT CASE Parameter
        CASE cPARAMETER_POSITION:
            CALL vectorSet(body(Index).position, arg1, arg2)
        CASE cPARAMETER_VELOCITY:
            CALL vectorSet(body(Index).velocity, arg1, arg2)
        CASE cPARAMETER_FORCE:
            CALL vectorSet(body(Index).force, arg1, arg2)
        CASE cPARAMETER_ANGULARVELOCITY:
            body(Index).angularVelocity = arg1
        CASE cPARAMETER_TORQUE:
            body(Index).torque = arg1
        CASE cPARAMETER_ORIENT:
            body(Index).orient = arg1
            CALL matrixSetRadians(body(Index).shape.u, body(Index).orient)
        CASE cPARAMETER_STATICFRICTION:
            body(Index).staticFriction = arg1
        CASE cPARAMETER_DYNAMICFRICTION:
            body(Index).dynamicFriction = arg1
        CASE cPARAMETER_RESTITUTION:
            body(Index).restitution = arg1
        CASE cPARAMETER_COLOR:
            body(Index).c = arg1
        CASE cPARAMETER_ENABLE:
            body(Index).enable = arg1
        CASE cPARAMETER_STATIC:
            CALL bodySetStatic(body(Index))
        CASE cPARAMETER_TEXTURE:
            body(Index).shape.texture = arg1
        CASE cPARAMETER_FLIPTEXTURE: 'does the texture flip directions when moving left or right
            body(Index).shape.flipTexture = arg1
        CASE cPARAMETER_COLLISIONMASK:
            body(Index).collisionMask = arg1
    END SELECT
END SUB

SUB setBodyEx (body() AS tBODY, Parameter AS INTEGER, objName AS STRING, arg1 AS _FLOAT, arg2 AS _FLOAT)
    DIM index AS INTEGER
    index = objectManagerID(body(), objName)

    IF index > -1 THEN
        CALL setBody(body(), Parameter, index, arg1, arg2)
    END IF
END SUB


FUNCTION createCircleBody (body() AS tBODY, index AS INTEGER, radius AS _FLOAT)
    DIM shape AS tSHAPE
    CALL shapeCreate(shape, cSHAPE_CIRCLE, radius)
    CALL bodyCreate(body(), index, shape)
    'no vertices have to created for circles
    CALL circleInitialize(body(), index)
    ' Even though circles do not have vertices, they still must be included in the vertices list
    IF index = 0 THEN
        body(index).pa.start = 0
    ELSE
        body(index).pa.start = body(index - 1).pa.start + body(index - 1).pa.count + 1
    END IF
    body(index).pa.count = 1
    body(index).c = _RGB32(255, 255, 255)
    createCircleBody = index
END FUNCTION

FUNCTION createCircleBodyEx (body() AS tBODY, objName AS STRING, radius AS _FLOAT)
    DIM shape AS tSHAPE
    DIM index AS INTEGER
    CALL shapeCreate(shape, cSHAPE_CIRCLE, radius)
    CALL bodyCreateEx(body(), objName, shape, index)
    'no vertices have to created for circles
    CALL circleInitialize(body(), index)
    ' Even though circles do not have vertices, they still must be included in the vertices list
    IF index = 0 THEN
        body(index).pa.start = 0
    ELSE
        body(index).pa.start = body(index - 1).pa.start + body(index - 1).pa.count + 1
    END IF
    body(index).pa.count = 1
    body(index).c = _RGB32(255, 255, 255)
    createCircleBodyEx = index
END FUNCTION


FUNCTION createBoxBodies (p() AS tPOLY, body() AS tBODY, index AS INTEGER, xs AS _FLOAT, ys AS _FLOAT)
    DIM shape AS tSHAPE
    CALL shapeCreate(shape, cSHAPE_POLYGON, 0)
    CALL bodyCreate(body(), index, shape)
    CALL boxCreate(p(), body(), index, xs, ys)
    CALL polygonInitialize(body(), p(), index)
    body(index).c = _RGB32(255, 255, 255)
    createBoxBodies = index
END FUNCTION

FUNCTION createBoxBodiesEx (p() AS tPOLY, body() AS tBODY, objName AS STRING, xs AS _FLOAT, ys AS _FLOAT)
    DIM shape AS tSHAPE
    DIM index AS INTEGER
    CALL shapeCreate(shape, cSHAPE_POLYGON, 0)
    CALL bodyCreateEx(body(), objName, shape, index)
    CALL boxCreate(p(), body(), index, xs, ys)
    CALL polygonInitialize(body(), p(), index)
    body(index).c = _RGB32(255, 255, 255)
    createBoxBodiesEx = index
END FUNCTION

SUB createTrapBody (p() AS tPOLY, body() AS tBODY, index AS INTEGER, xs AS _FLOAT, ys AS _FLOAT, yoff1 AS _FLOAT, yoff2 AS _FLOAT)
    DIM shape AS tSHAPE
    CALL shapeCreate(shape, cSHAPE_POLYGON, 0)
    CALL bodyCreate(body(), index, shape)
    CALL trapCreate(p(), body(), index, xs, ys, yoff1, yoff2)
    CALL polygonInitialize(body(), p(), index)
    body(index).c = _RGB32(255, 255, 255)
END SUB

SUB createTrapBodyEx (p() AS tPOLY, body() AS tBODY, objName AS STRING, xs AS _FLOAT, ys AS _FLOAT, yoff1 AS _FLOAT, yoff2 AS _FLOAT)
    DIM shape AS tSHAPE
    DIM index AS INTEGER
    CALL shapeCreate(shape, cSHAPE_POLYGON, 0)
    CALL bodyCreateEx(body(), objName, shape, index)
    CALL trapCreate(p(), body(), index, xs, ys, yoff1, yoff2)
    CALL polygonInitialize(body(), p(), index)
    body(index).c = _RGB32(255, 255, 255)
END SUB


FUNCTION objectManagerAdd (body() AS tBODY)
    objectManagerAdd = objectManager.objectCount
    objectManager.objectCount = objectManager.objectCount + 1
    IF objectManager.objectCount > sNUMBEROFBODIES THEN
        sNUMBEROFBODIES = sNUMBEROFBODIES * 1.5
        REDIM _PRESERVE body(sNUMBEROFBODIES) AS tBODY
    END IF
END FUNCTION

FUNCTION objectManagerID (body() AS tBODY, objName AS STRING)
    DIM i AS INTEGER
    DIM uID AS _INTEGER64
    uID = computeHash(RTRIM$(LTRIM$(objName)))
    objectManagerID = -1

    FOR i = 0 TO objectManager.objectCount
        IF body(i).objectHash = uID THEN
            objectManagerID = i
            EXIT FUNCTION
        END IF
    NEXT
END FUNCTION

SUB bodyCreateEx (body() AS tBODY, objName AS STRING, shape AS tSHAPE, index AS INTEGER)
    index = objectManagerAdd(body())
    body(index).objectName = objName
    body(index).objectHash = computeHash(objName)
    CALL bodyCreate(body(), index, shape)
END SUB


SUB bodyCreate (body() AS tBODY, index AS INTEGER, shape AS tSHAPE)
    CALL vectorSet(body(index).position, 0, 0)
    CALL vectorSet(body(index).velocity, 0, 0)
    body(index).angularVelocity = 0.0
    body(index).torque = 0.0
    body(index).orient = 0.0

    CALL vectorSet(body(index).force, 0, 0)
    body(index).staticFriction = 0.5
    body(index).dynamicFriction = 0.3
    body(index).restitution = 0.2
    body(index).shape = shape
    body(index).collisionMask = 255
    body(index).enable = 1
END SUB

SUB boxCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, sizex AS _FLOAT, sizey AS _FLOAT)
    DIM vertlength AS INTEGER: vertlength = 3
    DIM verts(vertlength) AS tVECTOR2d

    CALL vectorSet(verts(0), -sizex, -sizey)
    CALL vectorSet(verts(1), sizex, -sizey)
    CALL vectorSet(verts(2), sizex, sizey)
    CALL vectorSet(verts(3), -sizex, sizey)

    CALL vertexSet(p(), body(), index, verts(), vertlength)
END SUB

SUB trapCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, sizex AS _FLOAT, sizey AS _FLOAT, yOff1 AS _FLOAT, yOff2 AS _FLOAT)
    DIM vertlength AS INTEGER: vertlength = 3
    DIM verts(vertlength) AS tVECTOR2d

    CALL vectorSet(verts(0), -sizex, -sizey - yOff2)
    CALL vectorSet(verts(1), sizex, -sizey - yOff1)
    CALL vectorSet(verts(2), sizex, sizey)
    CALL vectorSet(verts(3), -sizex, sizey)

    CALL vertexSet(p(), body(), index, verts(), vertlength)
END SUB

SUB createTerrianBody (p() AS tPOLY, body() AS tBODY, index AS INTEGER, slices AS INTEGER, sliceWidth AS _FLOAT, nominalHeight AS _FLOAT)
    DIM shape AS tSHAPE
    DIM elevation(slices) AS _FLOAT

    DIM AS INTEGER i, j
    FOR j = 0 TO slices
        elevation(j) = RND * 500
    NEXT

    CALL shapeCreate(shape, cSHAPE_POLYGON, 0)

    FOR i = 0 TO slices - 1
        CALL bodyCreate(body(), index + i, shape)
        CALL terrainCreate(p(), body(), index + i, elevation(i), elevation(i + 1), sliceWidth, nominalHeight)
        CALL polygonInitialize(body(), p(), index + i)
        body(index + i).c = _RGB32(255, 255, 255)
        CALL bodySetStatic(body(index + i))
    NEXT i

END SUB

SUB createTerrianBodyEx (p() AS tPOLY, body() AS tBODY, objName AS STRING, elevation() AS _FLOAT, slices AS INTEGER, sliceWidth AS _FLOAT, nominalHeight AS _FLOAT)
    DIM shape AS tSHAPE

    DIM AS INTEGER i, index

    CALL shapeCreate(shape, cSHAPE_POLYGON, 0)

    FOR i = 0 TO slices - 1
        CALL bodyCreateEx(body(), objName + "_" + LTRIM$(STR$(i)), shape, index)
        CALL terrainCreate(p(), body(), index, elevation(i), elevation(i + 1), sliceWidth, nominalHeight)
        CALL polygonInitialize(body(), p(), index)
        body(index).c = _RGB32(255, 255, 255)
        CALL bodySetStatic(body(index))
    NEXT i

    DIM AS _FLOAT p1, p2
    DIM start AS _INTEGER64

    FOR i = 0 TO slices - 1
        start = objectManagerID(body(), objName + "_" + LTRIM$(STR$(i)))
        p1 = (sliceWidth / 2) - p(body(start).pa.start).vert.x
        p2 = nominalHeight - p(body(start).pa.start + 1).vert.y
        CALL setBody(body(), cPARAMETER_POSITION, start, world.terrainPosition.x + p1 + (sliceWidth * i), world.terrainPosition.y + p2)
    NEXT
END SUB


SUB terrainCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, ele1 AS _FLOAT, ele2 AS _FLOAT, sliceWidth AS _FLOAT, nominalHeight AS _FLOAT)
    DIM AS INTEGER vertLength
    vertLength = 3 ' numOfslices + 1
    DIM verts(vertLength) AS tVECTOR2d

    CALL vectorSet(verts(0), 0, nominalHeight)
    CALL vectorSet(verts(1), (0) * sliceWidth, -nominalHeight - ele1)
    CALL vectorSet(verts(2), (1) * sliceWidth, -nominalHeight - ele2)
    CALL vectorSet(verts(3), (1) * sliceWidth, nominalHeight)
    CALL vertexSet(p(), body(), index, verts(), vertLength)
END SUB



SUB vShapeCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, sizex AS _FLOAT, sizey AS _FLOAT)
    DIM vertlength AS INTEGER: vertlength = 7
    DIM verts(vertlength) AS tVECTOR2d

    CALL vectorSet(verts(0), -sizex, -sizey)
    CALL vectorSet(verts(1), sizex, -sizey)
    CALL vectorSet(verts(2), sizex, sizey)
    CALL vectorSet(verts(3), -sizex, sizey)
    CALL vectorSet(verts(4), -sizex, sizey / 2)
    CALL vectorSet(verts(5), sizex / 2, sizey / 2)
    CALL vectorSet(verts(6), sizex / 2, -sizey / 2)
    CALL vectorSet(verts(7), -sizex, sizey / 2)

    CALL vertexSet(p(), body(), index, verts(), vertlength)
END SUB

SUB vertexSet (p() AS tPOLY, body() AS tBODY, index AS INTEGER, verts() AS tVECTOR2d, vertLength AS INTEGER)
    DIM rightMost AS INTEGER: rightMost = 0
    DIM highestXCoord AS _FLOAT: highestXCoord = verts(0).x
    DIM i AS INTEGER
    DIM x AS _FLOAT
    FOR i = 1 TO vertLength
        x = verts(i).x
        IF x > highestXCoord THEN
            highestXCoord = x
            rightMost = i
        ELSE
            IF x = highestXCoord THEN
                IF verts(i).y < verts(rightMost).y THEN
                    rightMost = i
                END IF
            END IF
        END IF
    NEXT
    DIM hull(cMAXNUMBEROFPOLYGONS) AS INTEGER
    DIM outCount AS INTEGER: outCount = 0
    DIM indexHull AS INTEGER: indexHull = rightMost
    DIM nextHullIndex AS INTEGER
    DIM e1 AS tVECTOR2d
    DIM e2 AS tVECTOR2d
    DIM c AS _FLOAT
    DO
        hull(outCount) = indexHull
        nextHullIndex = 0
        FOR i = 1 TO vertLength
            IF nextHullIndex = indexHull THEN
                nextHullIndex = i
                _CONTINUE
            END IF
            CALL vectorSubVectorND(e1, verts(nextHullIndex), verts(hull(outCount)))
            CALL vectorSubVectorND(e2, verts(i), verts(hull(outCount)))
            c = vectorCross(e1, e2)
            IF c < 0.0 THEN nextHullIndex = i
            IF c = 0.0 AND (vectorLengthSq(e2) > vectorLengthSq(e1)) THEN
                nextHullIndex = i
            END IF
        NEXT
        outCount = outCount + 1
        indexHull = nextHullIndex
        IF nextHullIndex = rightMost THEN
            body(index).pa.count = outCount - 1
            EXIT DO
        END IF
    LOOP

    IF index = 0 THEN
        body(index).pa.start = 0
    ELSE
        body(index).pa.start = body(index - 1).pa.start + body(index - 1).pa.count + 1
    END IF

    FOR i = 0 TO vertLength
        p(body(index).pa.start + i).vert = verts(hull(i))
    NEXT

    DIM face AS tVECTOR2d
    FOR i = 0 TO vertLength
        CALL vectorSubVectorND(face, p(body(index).pa.start + arrayNextIndex(i, body(index).pa.count)).vert, p(body(index).pa.start + i).vert)
        CALL vectorSet(p(body(index).pa.start + i).norm, face.y, -face.x)
        CALL vectorNormalize(p(body(index).pa.start + i).norm)
    NEXT
END SUB

FUNCTION arrayNextIndex (i AS INTEGER, count AS INTEGER)
    arrayNextIndex = ((i + 1) MOD (count + 1))
END FUNCTION

'**********************************************************************************************
'   Rendering Stuff Ahead
'**********************************************************************************************

SUB renderFps
    fpsLast = fps
    fps = 0
END SUB

FUNCTION AABBOverlap (Ax AS _FLOAT, Ay AS _FLOAT, Aw AS _FLOAT, Ah AS _FLOAT, Bx AS _FLOAT, By AS _FLOAT, Bw AS _FLOAT, Bh AS _FLOAT)
    AABBOverlap = Ax < Bx + Bw AND Ax + Aw > Bx AND Ay < By + Bh AND Ay + Ah > By
END FUNCTION

FUNCTION AABBOverlapVector (A AS tVECTOR2d, Aw AS _FLOAT, Ah AS _FLOAT, B AS tVECTOR2d, Bw AS _FLOAT, Bh AS _FLOAT)
    AABBOverlapVector = AABBOverlap(A.x, A.y, Aw, Ah, B.x, B.y, Bw, Bh)
END FUNCTION


SUB renderBodies (p() AS tPOLY, body() AS tBODY, j() AS tJOINT, hits() AS tHIT, camera AS tCAMERA)
    DIM i AS INTEGER
    DIM hitcount AS INTEGER
    DIM camoffset AS tVECTOR2d
    DIM AS _FLOAT cx, cy, cwx, cwy, ox, oy, owx, owy, ccw, cch
    ccw = _WIDTH / 2
    cch = _HEIGHT / 2
    FOR i = 0 TO objectManager.objectCount
        IF body(i).enable THEN
            'AABB to cut down on rendering objects out of camera view
            cx = camera.position.x - ccw
            cy = camera.position.y - cch
            cwx = _WIDTH
            cwy = _HEIGHT
            ox = body(i).position.x - 2000
            oy = body(i).position.y - 2000
            owx = 4000
            owy = 4000
            IF AABBOverlap(cx, cy, cwx, cwy, ox, oy, owx, owy) THEN
                IF body(i).shape.ty = cSHAPE_CIRCLE THEN
                    IF body(i).shape.texture = 0 THEN
                        CALL renderWireframeCircle(body(), i, camera)
                    ELSE
                        CALL renderTexturedCircle(body(), i, camera)
                    END IF
                ELSE IF body(i).shape.ty = cSHAPE_POLYGON THEN
                        IF body(i).shape.texture = 0 THEN
                            CALL renderWireframePoly(p(), body(), i, camera)
                        ELSE
                            CALL renderTexturedBox(p(), body(), i, camera)
                        END IF
                    END IF
                END IF
            END IF
        END IF
    NEXT
    IF cRENDER_JOINTS THEN
        FOR i = 1 TO sNUMBEROFJOINTS
            CALL renderJoints(j(i), body(), camera)
        NEXT
    END IF
    IF cRENDER_COLLISIONS THEN
        hitcount = 0
        DO WHILE hits(hitcount).A <> hits(hitcount).B
            CALL vectorSubVectorND(camoffset, hits(hitcount).position, camera.position)
            CIRCLE (camoffset.x, camoffset.y), 5, _RGB(255, 6, 11)
            hitcount = hitcount + 1
        LOOP
    END IF

END SUB

SUB renderJoints (j AS tJOINT, b() AS tBODY, camera AS tCAMERA)
    DIM b1 AS tBODY: b1 = b(j.body1)
    DIM b2 AS tBODY: b2 = b(j.body2)
    DIM R1 AS tMATRIX2d: R1 = b1.shape.u
    DIM R2 AS tMATRIX2d: R2 = b2.shape.u

    DIM x1 AS tVECTOR2d: x1 = b1.position
    DIM p1 AS tVECTOR2d: CALL matrixMultiplyVector(R1, j.localAnchor1, p1)

    CALL vectorAddVectorND(p1, p1, x1)

    DIM x2 AS tVECTOR2d: x2 = b2.position
    DIM p2 AS tVECTOR2d: CALL matrixMultiplyVector(R2, j.localAnchor2, p2)

    CALL vectorAddVectorND(p2, p2, x2)

    CALL vectorSubVector(p1, camera.position)
    CALL vectorSubVector(x2, camera.position)

    LINE (p1.x, p1.y)-(x2.x, x2.y), _RGB(255, 255, 127) 'yellow
END SUB

SUB renderWireframePoly (p() AS tPOLY, b() AS tBODY, index AS INTEGER, camera AS tCAMERA)
    DIM a AS tVECTOR2d ' dummy vertices
    DIM b AS tVECTOR2d
    DIM tv AS tVECTOR2d
    CALL vectorSet(tv, _WIDTH / 2, _HEIGHT / 2)

    DIM i, element, element_next AS INTEGER
    FOR i = 0 TO b(index).pa.count
        element = b(index).pa.start + i
        element_next = b(index).pa.start + arrayNextIndex(i, b(index).pa.count)
        a = p(element).vert
        b = p(element_next).vert
        CALL worldToCamera(b(), camera, index, a)
        CALL worldToCamera(b(), camera, index, b)
        LINE (a.x, a.y)-(b.x, b.y), b(index).c
    NEXT
END SUB

SUB renderTexturedBox (p() AS tPOLY, b() AS tBODY, index AS INTEGER, camera AS tCAMERA)
    DIM vert(3) AS tVECTOR2d

    DIM AS INTEGER W, H
    DIM bm AS LONG ' Texture map
    bm = b(index).shape.texture
    W = _WIDTH(bm): H = _HEIGHT(bm)

    DIM i AS INTEGER
    FOR i = 0 TO 3
        vert(i) = p(b(index).pa.start + i).vert
        vert(i).x = vert(i).x + b(index).shape.offsetTextureX
        vert(i).y = vert(i).y + b(index).shape.offsetTextureY
        vert(i).x = vert(i).x * b(index).shape.scaleTextureX
        vert(i).y = vert(i).y * b(index).shape.scaleTextureY
        CALL worldToCamera(b(), camera, index, vert(i))
    NEXT
    IF b(index).velocity.x > 1 OR b(index).shape.flipTexture = 0 THEN
        _MAPTRIANGLE (0, 0)-(W - 1, 0)-(W - 1, H - 1), bm TO(vert(3).x, vert(3).y)-(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)
        _MAPTRIANGLE (0, 0)-(0, H - 1)-(W - 1, H - 1), bm TO(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y)-(vert(1).x, vert(1).y)
    ELSE
        _MAPTRIANGLE (0, 0)-(W - 1, 0)-(W - 1, H - 1), bm TO(vert(0).x, vert(0).y)-(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y)
        _MAPTRIANGLE (0, 0)-(0, H - 1)-(W - 1, H - 1), bm TO(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)-(vert(2).x, vert(2).y)
    END IF

END SUB

SUB renderWireframeCircle (b() AS tBODY, index AS INTEGER, camera AS tCAMERA)
    DIM tv AS tVECTOR2d: tv = b(index).position
    tv.x = tv.x * camera.zoom
    tv.y = tv.y * camera.zoom
    CALL worldToCameraNR(b(), camera, index, tv)
    CIRCLE (tv.x, tv.y), b(index).shape.radius * camera.zoom, b(index).c
    LINE (tv.x, tv.y)-(tv.x + COS(b(index).orient) * (b(index).shape.radius * camera.zoom), tv.y + SIN(b(index).orient) * (b(index).shape.radius) * camera.zoom), b(index).c
END SUB

SUB renderTexturedCircle (b() AS tBODY, index AS INTEGER, camera AS tCAMERA)
    DIM vert(3) AS tVECTOR2d
    DIM W, H AS INTEGER
    DIM bm AS LONG
    'DIM tv AS tVECTOR2d
    ' CALL vectorSet(tv, _WIDTH / 2 * (1 / camera.zoom), _HEIGHT / 2 * (1 / camera.zoom))

    bm = b(index).shape.texture
    W = _WIDTH(bm): H = _HEIGHT(bm)
    CALL vectorSet(vert(0), -b(index).shape.radius, -b(index).shape.radius)
    CALL vectorSet(vert(1), -b(index).shape.radius, b(index).shape.radius)
    CALL vectorSet(vert(2), b(index).shape.radius, b(index).shape.radius)
    CALL vectorSet(vert(3), b(index).shape.radius, -b(index).shape.radius)
    DIM i AS INTEGER
    FOR i = 0 TO 3
        CALL worldToCamera(b(), camera, index, vert(i))
    NEXT
    _MAPTRIANGLE (0, 0)-(0, H - 1)-(W - 1, H - 1), bm TO(vert(0).x, vert(0).y)-(vert(1).x, vert(1).y)-(vert(2).x, vert(2).y)
    _MAPTRIANGLE (0, 0)-(W - 1, 0)-(W - 1, H - 1), bm TO(vert(0).x, vert(0).y)-(vert(3).x, vert(3).y)-(vert(2).x, vert(2).y)

END SUB

SUB worldToCamera (body() AS tBODY, camera AS tCAMERA, index AS INTEGER, vert AS tVECTOR2d)
    DIM tv AS tVECTOR2d
    CALL vectorSet(tv, _WIDTH / 2 * (1 / camera.zoom), _HEIGHT / 2 * (1 / camera.zoom)) ' Camera Center
    CALL matrixMultiplyVector(body(index).shape.u, vert, vert) ' Rotate body
    CALL vectorAddVector(vert, body(index).position) ' Add Position
    CALL vectorSubVector(vert, camera.position) 'Sub Camera Position
    CALL vectorAddVector(vert, tv) ' Add to camera Center
    CALL vectorMultiplyScalar(vert, camera.zoom) 'Zoom everything
END SUB

SUB worldToCameraNR (body() AS tBODY, camera AS tCAMERA, index AS INTEGER, vert AS tVECTOR2d)
    DIM tv AS tVECTOR2d
    CALL vectorSet(tv, _WIDTH / 2 * (1 / camera.zoom), _HEIGHT / 2 * (1 / camera.zoom)) ' Camera Center
    CALL vectorSetVector(vert, body(index).position) ' Add Position
    CALL vectorSubVector(vert, camera.position) 'Sub Camera Position
    CALL vectorAddVector(vert, tv) ' Add to camera Center
    CALL vectorMultiplyScalar(vert, camera.zoom) 'Zoom everything
END SUB


SUB polygonSetOrient (b AS tBODY, radians AS _FLOAT)
    CALL matrixSetRadians(b.shape.u, radians)
END SUB

'**********************************************************************************************
'   Object initialization Ahead
'**********************************************************************************************

SUB circleInitialize (b() AS tBODY, index AS INTEGER)
    CALL circleComputeMass(b(), index, .10)
END SUB

SUB circleComputeMass (b() AS tBODY, index AS INTEGER, density AS _FLOAT)
    b(index).mass = cPI * b(index).shape.radius * b(index).shape.radius * density
    IF b(index).mass <> 0 THEN
        b(index).invMass = 1.0 / b(index).mass
    ELSE
        b(index).invMass = 0.0
    END IF

    b(index).inertia = b(index).mass * b(index).shape.radius * b(index).shape.radius

    IF b(index).inertia <> 0 THEN
        b(index).invInertia = 1.0 / b(index).inertia
    ELSE
        b(index).invInertia = 0.0
    END IF
END SUB

SUB polygonInitialize (body() AS tBODY, p() AS tPOLY, index AS INTEGER)
    CALL polygonComputeMass(body(), p(), index, .10)
END SUB

SUB polygonComputeMass (b() AS tBODY, p() AS tPOLY, index AS INTEGER, density AS _FLOAT)
    DIM c AS tVECTOR2d ' centroid
    DIM p1 AS tVECTOR2d
    DIM p2 AS tVECTOR2d
    DIM area AS _FLOAT
    DIM I AS _FLOAT
    DIM k_inv3 AS _FLOAT
    DIM D AS _FLOAT
    DIM triangleArea AS _FLOAT
    DIM weight AS _FLOAT
    DIM intx2 AS _FLOAT
    DIM inty2 AS _FLOAT
    DIM ii AS INTEGER

    k_inv3 = 1.0 / 3.0

    FOR ii = 0 TO b(index).pa.count
        p1 = p(b(index).pa.start + ii).vert
        p2 = p(b(index).pa.start + arrayNextIndex(ii, b(index).pa.count)).vert
        D = vectorCross(p1, p2)
        triangleArea = .5 * D
        area = area + triangleArea
        weight = triangleArea * k_inv3
        CALL vectorAddVectorScalar(c, p1, weight)
        CALL vectorAddVectorScalar(c, p2, weight)
        intx2 = p1.x * p1.x + p2.x * p1.x + p2.x * p2.x
        inty2 = p1.y * p1.y + p2.y * p1.y + p2.y * p2.y
        I = I + (0.25 * k_inv3 * D) * (intx2 + inty2)
    NEXT ii

    CALL vectorMultiplyScalar(c, 1.0 / area)

    FOR ii = 0 TO b(index).pa.count
        CALL vectorSubVector(p(b(index).pa.start + ii).vert, c)
    NEXT

    b(index).mass = density * area
    IF b(index).mass <> 0.0 THEN
        b(index).invMass = 1.0 / b(index).mass
    ELSE
        b(index).invMass = 0.0
    END IF

    b(index).inertia = I * density
    IF b(index).inertia <> 0 THEN
        b(index).invInertia = 1.0 / b(index).inertia
    ELSE
        b(index).invInertia = 0.0
    END IF
END SUB
'**********************************************************************************************
'   Joint Stuff Ahead
'**********************************************************************************************
SUB jointSet (j AS tJOINT, body() AS tBODY, b1 AS INTEGER, b2 AS INTEGER, x AS _FLOAT, y AS _FLOAT)
    DIM anchor AS tVECTOR2d
    CALL vectorSet(anchor, x, y)
    DIM Rot1 AS tMATRIX2d: Rot1 = body(b1).shape.u
    DIM Rot2 AS tMATRIX2d: Rot2 = body(b2).shape.u
    DIM Rot1T AS tMATRIX2d: CALL matrixTranspose(Rot1, Rot1T)
    DIM Rot2T AS tMATRIX2d: CALL matrixTranspose(Rot2, Rot2T)
    DIM tv AS tVECTOR2d

    j.body1 = b1
    j.body2 = b2

    CALL vectorSubVectorND(tv, anchor, body(b1).position)
    CALL matrixMultiplyVector(Rot1T, tv, j.localAnchor1)

    CALL vectorSubVectorND(tv, anchor, body(b2).position)
    CALL matrixMultiplyVector(Rot2T, tv, j.localAnchor2)

    CALL vectorSet(j.P, 0, 0)

    j.softness = 0.001
    j.biasFactor = 100

END SUB

SUB jointPrestep (j AS tJOINT, body() AS tBODY, inv_dt AS _FLOAT)
    DIM Rot1 AS tMATRIX2d: Rot1 = body(j.body1).shape.u
    DIM Rot2 AS tMATRIX2d: Rot2 = body(j.body2).shape.u
    DIM b1invMass AS _FLOAT
    DIM b2invMass AS _FLOAT

    DIM b1invInertia AS _FLOAT
    DIM b2invInertia AS _FLOAT

    CALL matrixMultiplyVector(Rot1, j.localAnchor1, j.r1)
    CALL matrixMultiplyVector(Rot2, j.localAnchor2, j.r2)

    b1invMass = body(j.body1).invMass
    b2invMass = body(j.body2).invMass

    b1invInertia = body(j.body1).invInertia
    b2invInertia = body(j.body2).invInertia

    DIM K1 AS tMATRIX2d
    Call matrixSetScalar(K1, b1invMass + b2invMass, 0,_
                                                 0, b1invMass + b2invMass)
    DIM K2 AS tMATRIX2d
    Call matrixSetScalar(K2, b1invInertia * j.r1.y * j.r1.y, -b1invInertia * j.r1.x * j.r1.y,_
                            -b1invInertia * j.r1.x * j.r1.y,  b1invInertia * j.r1.x * j.r1.x)

    DIM K3 AS tMATRIX2d
    Call matrixSetScalar(K3,  b2invInertia * j.r2.y * j.r2.y, - b2invInertia * j.r2.x * j.r2.y,_
                             -b2invInertia * j.r2.x * j.r2.y,   b2invInertia * j.r2.x * j.r2.x)

    DIM K AS tMATRIX2d
    CALL matrixAddMatrix(K1, K2, K)
    CALL matrixAddMatrix(K3, K, K)
    K.m00 = K.m00 + j.softness
    K.m11 = K.m11 + j.softness
    CALL matrixInvert(K, j.M)

    DIM p1 AS tVECTOR2d: CALL vectorAddVectorND(p1, body(j.body1).position, j.r1)
    DIM p2 AS tVECTOR2d: CALL vectorAddVectorND(p2, body(j.body2).position, j.r2)
    DIM dp AS tVECTOR2d: CALL vectorSubVectorND(dp, p2, p1)

    CALL vectorMultiplyScalarND(j.bias, dp, -j.biasFactor * inv_dt)
    'Call vectorSet(j.bias, 0, 0)
    CALL vectorSet(j.P, 0, 0)
END SUB

SUB jointApplyImpulse (j AS tJOINT, body() AS tBODY)
    DIM dv AS tVECTOR2d
    DIM impulse AS tVECTOR2d
    DIM cross1 AS tVECTOR2d
    DIM cross2 AS tVECTOR2d
    DIM tv AS tVECTOR2d


    'Vec2 dv = body2->velocity + Cross(body2->angularVelocity, r2) - body1->velocity - Cross(body1->angularVelocity, r1);
    CALL vectorCrossScalar(cross2, j.r2, body(j.body2).angularVelocity)
    CALL vectorCrossScalar(cross1, j.r1, body(j.body1).angularVelocity)
    CALL vectorAddVectorND(dv, body(j.body2).velocity, cross2)
    CALL vectorSubVectorND(dv, dv, body(j.body1).velocity)
    CALL vectorSubVectorND(dv, dv, cross1)

    ' impulse = M * (bias - dv - softness * P);
    CALL vectorMultiplyScalarND(tv, j.P, j.softness)
    CALL vectorSubVectorND(impulse, j.bias, dv)
    CALL vectorSubVectorND(impulse, impulse, tv)
    CALL matrixMultiplyVector(j.M, impulse, impulse)

    ' body1->velocity -= body1->invMass * impulse;

    CALL vectorMultiplyScalarND(tv, impulse, body(j.body1).invMass)
    CALL vectorSubVectorND(body(j.body1).velocity, body(j.body1).velocity, tv)

    ' body1->angularVelocity -= body1->invI * Cross(r1, impulse);
    DIM crossScalar AS _FLOAT
    crossScalar = vectorCross(j.r1, impulse)
    body(j.body1).angularVelocity = body(j.body1).angularVelocity - body(j.body1).invInertia * crossScalar

    CALL vectorMultiplyScalarND(tv, impulse, body(j.body2).invMass)
    CALL vectorAddVectorND(body(j.body2).velocity, body(j.body2).velocity, tv)

    crossScalar = vectorCross(j.r2, impulse)
    body(j.body2).angularVelocity = body(j.body2).angularVelocity + body(j.body2).invInertia * crossScalar

    CALL vectorAddVectorND(j.P, j.P, impulse)

END SUB

'**********************************************************************************************
'   Vector Math Ahead
'**********************************************************************************************

SUB vectorSet (v AS tVECTOR2d, x AS _FLOAT, y AS _FLOAT)
    v.x = x
    v.y = y
END SUB

SUB vectorSetVector (o AS tVECTOR2d, v AS tVECTOR2d)
    o.x = v.x
    o.y = v.y
END SUB

SUB vectorNeg (v AS tVECTOR2d)
    v.x = -v.x
    v.y = -v.y
END SUB

SUB vectorNegND (o AS tVECTOR2d, v AS tVECTOR2d)
    o.x = -v.x
    o.y = -v.y
END SUB

SUB vectorMultiplyScalar (v AS tVECTOR2d, s AS _FLOAT)
    v.x = v.x * s
    v.y = v.y * s
END SUB

SUB vectorMultiplyScalarND (o AS tVECTOR2d, v AS tVECTOR2d, s AS _FLOAT)
    o.x = v.x * s
    o.y = v.y * s
END SUB

SUB vectorDivideScalar (v AS tVECTOR2d, s AS _FLOAT)
    v.x = v.x / s
    v.y = v.y / s
END SUB

SUB vectorDivideScalarND (o AS tVECTOR2d, v AS tVECTOR2d, s AS _FLOAT)
    o.x = v.x / s
    o.y = v.y / s
END SUB

SUB vectorAddScalar (v AS tVECTOR2d, s AS _FLOAT)
    v.x = v.x + s
    v.y = v.y + s
END SUB

SUB vectorAddScalarND (o AS tVECTOR2d, v AS tVECTOR2d, s AS _FLOAT)
    o.x = v.x + s
    o.y = v.y + s
END SUB

SUB vectorMultiplyVector (v AS tVECTOR2d, m AS tVECTOR2d)
    v.x = v.x * m.x
    v.y = v.y * m.y
END SUB

SUB vectorMultiplyVectorND (o AS tVECTOR2d, v AS tVECTOR2d, m AS tVECTOR2d)
    o.x = v.x * m.x
    o.y = v.y * m.y
END SUB

SUB vectorDivideVector (v AS tVECTOR2d, m AS tVECTOR2d)
    v.x = v.x / m.x
    v.y = v.y / m.y
END SUB

SUB vectorAddVector (v AS tVECTOR2d, m AS tVECTOR2d)
    v.x = v.x + m.x
    v.y = v.y + m.y
END SUB

SUB vectorAddVectorND (o AS tVECTOR2d, v AS tVECTOR2d, m AS tVECTOR2d)
    o.x = v.x + m.x
    o.y = v.y + m.y
END SUB

SUB vectorAddVectorScalar (v AS tVECTOR2d, m AS tVECTOR2d, s AS _FLOAT)
    v.x = v.x + m.x * s
    v.y = v.y + m.y * s
END SUB

SUB vectorAddVectorScalarND (o AS tVECTOR2d, v AS tVECTOR2d, m AS tVECTOR2d, s AS _FLOAT)
    o.x = v.x + m.x * s
    o.y = v.y + m.y * s
END SUB

SUB vectorSubVector (v AS tVECTOR2d, m AS tVECTOR2d)
    v.x = v.x - m.x
    v.y = v.y - m.y
END SUB

SUB vectorSubVectorND (o AS tVECTOR2d, v AS tVECTOR2d, m AS tVECTOR2d)
    o.x = v.x - m.x
    o.y = v.y - m.y
END SUB

FUNCTION vectorLengthSq (v AS tVECTOR2d)
    vectorLengthSq = v.x * v.x + v.y * v.y
END FUNCTION

FUNCTION vectorLength (v AS tVECTOR2d)
    vectorLength = SQR(vectorLengthSq(v))
END FUNCTION

SUB vectorRotate (v AS tVECTOR2d, radians AS _FLOAT)
    DIM c, s, xp, yp AS _FLOAT
    c = COS(radians)
    s = SIN(radians)
    xp = v.x * c - v.y * s
    yp = v.x * s + v.y * c
    v.x = xp
    v.y = yp
END SUB

SUB vectorNormalize (v AS tVECTOR2d)
    DIM lenSQ, invLen AS _FLOAT
    lenSQ = vectorLengthSq(v)
    IF lenSQ > cEPSILON_SQ THEN
        invLen = 1.0 / SQR(lenSQ)
        v.x = v.x * invLen
        v.y = v.y * invLen
    END IF
END SUB

SUB vectorMin (a AS tVECTOR2d, b AS tVECTOR2d, o AS tVECTOR2d)
    o.x = scalarMin(a.x, b.x)
    o.y = scalarMin(a.y, b.y)
END SUB

SUB vectorMax (a AS tVECTOR2d, b AS tVECTOR2d, o AS tVECTOR2d)
    o.x = scalarMax(a.x, b.x)
    o.y = scalarMax(a.y, b.y)
END SUB

FUNCTION vectorDot (a AS tVECTOR2d, b AS tVECTOR2d)
    vectorDot = a.x * b.x + a.y * b.y
END FUNCTION

FUNCTION vectorSqDist (a AS tVECTOR2d, b AS tVECTOR2d)
    DIM dx, dy AS _FLOAT
    dx = b.x - a.x
    dy = b.y - a.y
    vectorSqDist = dx * dx + dy * dy
END FUNCTION

FUNCTION vectorDistance (a AS tVECTOR2d, b AS tVECTOR2d)
    vectorDistance = SQR(vectorSqDist(a, b))
END FUNCTION

FUNCTION vectorCross (a AS tVECTOR2d, b AS tVECTOR2d)
    vectorCross = a.x * b.y - a.y * b.x
END FUNCTION

SUB vectorCrossScalar (o AS tVECTOR2d, v AS tVECTOR2d, a AS _FLOAT)
    o.x = v.y * -a
    o.y = v.x * a
END SUB

FUNCTION vectorArea (a AS tVECTOR2d, b AS tVECTOR2d, c AS tVECTOR2d)
    vectorArea = (((b.x - a.x) * (c.y - a.y)) - ((c.x - a.x) * (b.y - a.y)))
END FUNCTION

FUNCTION vectorLeft (a AS tVECTOR2d, b AS tVECTOR2d, c AS tVECTOR2d)
    vectorLeft = vectorArea(a, b, c) > 0
END FUNCTION

FUNCTION vectorLeftOn (a AS tVECTOR2d, b AS tVECTOR2d, c AS tVECTOR2d)
    vectorLeftOn = vectorArea(a, b, c) >= 0
END FUNCTION

FUNCTION vectorRight (a AS tVECTOR2d, b AS tVECTOR2d, c AS tVECTOR2d)
    vectorRight = vectorArea(a, b, c) < 0
END FUNCTION

FUNCTION vectorRightOn (a AS tVECTOR2d, b AS tVECTOR2d, c AS tVECTOR2d)
    vectorRightOn = vectorArea(a, b, c) <= 0
END FUNCTION

FUNCTION vectorCollinear (a AS tVECTOR2d, b AS tVECTOR2d, c AS tVECTOR2d, thresholdAngle AS _FLOAT)
    IF (thresholdAngle = 0) THEN
        vectorCollinear = (vectorArea(a, b, c) = 0)
    ELSE
        DIM ab AS tVECTOR2d
        DIM bc AS tVECTOR2d
        DIM dot AS _FLOAT
        DIM magA AS _FLOAT
        DIM magB AS _FLOAT
        DIM angle AS _FLOAT

        ab.x = b.x - a.x
        ab.y = b.y - a.y
        bc.x = c.x - b.x
        bc.y = c.y - b.y

        dot = ab.x * bc.x + ab.y * bc.y
        magA = SQR(ab.x * ab.x + ab.y * ab.y)
        magB = SQR(bc.x * bc.x + bc.y * bc.y)
        angle = _ACOS(dot / (magA * magB))
        vectorCollinear = angle < thresholdAngle
    END IF
END FUNCTION

SUB vectorGetSupport (p() AS tPOLY, body() AS tBODY, index AS INTEGER, dir AS tVECTOR2d, bestVertex AS tVECTOR2d)
    DIM bestProjection AS _FLOAT
    DIM v AS tVECTOR2d
    DIM projection AS _FLOAT
    DIM i AS INTEGER
    bestVertex.x = -9999999
    bestVertex.y = -9999999
    bestProjection = -9999999

    FOR i = 0 TO body(index).pa.count
        v = p(i + body(index).pa.start).vert
        projection = vectorDot(v, dir)
        IF projection > bestProjection THEN
            bestVertex = v
            bestProjection = projection
        END IF
    NEXT
END SUB

'**********************************************************************************************
'   Matrix Stuff Ahead
'**********************************************************************************************

SUB matrixSetRadians (m AS tMATRIX2d, radians AS _FLOAT)
    DIM c AS _FLOAT
    DIM s AS _FLOAT
    c = COS(radians)
    s = SIN(radians)
    m.m00 = c
    m.m01 = -s
    m.m10 = s
    m.m11 = c
END SUB

SUB matrixSetScalar (m AS tMATRIX2d, a AS _FLOAT, b AS _FLOAT, c AS _FLOAT, d AS _FLOAT)
    m.m00 = a
    m.m01 = b
    m.m10 = c
    m.m11 = d
END SUB

SUB matrixAbs (m AS tMATRIX2d, o AS tMATRIX2d)
    o.m00 = ABS(m.m00)
    o.m01 = ABS(m.m01)
    o.m10 = ABS(m.m10)
    o.m11 = ABS(m.m11)
END SUB

SUB matrixGetAxisX (m AS tMATRIX2d, o AS tVECTOR2d)
    o.x = m.m00
    o.y = m.m10
END SUB

SUB matrixGetAxisY (m AS tMATRIX2d, o AS tVECTOR2d)
    o.x = m.m01
    o.y = m.m11
END SUB

SUB matrixTransposeI (m AS tMATRIX2d)
    SWAP m.m01, m.m10
END SUB

SUB matrixTranspose (m AS tMATRIX2d, o AS tMATRIX2d)
    DIM tm AS tMATRIX2d
    tm.m00 = m.m00
    tm.m01 = m.m10
    tm.m10 = m.m01
    tm.m11 = m.m11
    o = tm
END SUB

SUB matrixInvert (m AS tMATRIX2d, o AS tMATRIX2d)
    DIM a, b, c, d, det AS _FLOAT
    DIM tm AS tMATRIX2d

    a = m.m00: b = m.m01: c = m.m10: d = m.m11
    det = a * d - b * c
    IF det = 0 THEN EXIT SUB

    det = 1 / det
    tm.m00 = det * d: tm.m01 = -det * b
    tm.m10 = -det * c: tm.m11 = det * a
    o = tm
END SUB

SUB matrixMultiplyVector (m AS tMATRIX2d, v AS tVECTOR2d, o AS tVECTOR2d)
    DIM t AS tVECTOR2d
    t.x = m.m00 * v.x + m.m01 * v.y
    t.y = m.m10 * v.x + m.m11 * v.y
    o = t
END SUB

SUB matrixAddMatrix (m AS tMATRIX2d, x AS tMATRIX2d, o AS tMATRIX2d)
    o.m00 = m.m00 + x.m00
    o.m01 = m.m01 + x.m01
    o.m10 = m.m10 + x.m10
    o.m11 = m.m11 + x.m11
END SUB

SUB matrixMultiplyMatrix (m AS tMATRIX2d, x AS tMATRIX2d, o AS tMATRIX2d)
    o.m00 = m.m00 * x.m00 + m.m01 * x.m10
    o.m01 = m.m00 * x.m01 + m.m01 * x.m11
    o.m10 = m.m10 * x.m00 + m.m11 * x.m10
    o.m11 = m.m10 * x.m01 + m.m11 * x.m11
END SUB

'**********************************************************************************************
'   Mostly Unused Stuff Ahead
'**********************************************************************************************

SUB polygonMakeCCW (obj AS tTRIANGLE)
    IF vectorLeft(obj.a, obj.b, obj.c) = 0 THEN
        SWAP obj.a, obj.c
    END IF
END SUB

FUNCTION polygonIsReflex (t AS tTRIANGLE)
    polygonIsReflex = vectorRight(t.a, t.b, t.c)
END FUNCTION

FUNCTION scalarMin (a AS _FLOAT, b AS _FLOAT)
    IF a < b THEN
        scalarMin = a
    ELSE
        scalarMin = b
    END IF
END FUNCTION

FUNCTION scalarMax (a AS _FLOAT, b AS _FLOAT)
    IF a > b THEN
        scalarMax = a
    ELSE
        scalarMax = b
    END IF
END FUNCTION

SUB lineIntersection (l1 AS tLINE2d, l2 AS tLINE2d, o AS tVECTOR2d)
    DIM a1, b1, c1, a2, b2, c2, det AS _FLOAT
    o.x = 0
    o.y = 0
    a1 = l1.b.y - l1.a.y
    b1 = l1.a.x - l1.b.x
    c1 = a1 * l1.a.x + b1 * l1.a.y
    a2 = l2.b.y - l2.a.y
    b2 = l2.a.x - l2.b.x
    c2 = a2 * l2.a.x + b2 * l2.a.y
    det = a1 * b2 - a2 * b1

    IF INT(det * cPRECISION) <> 0 THEN
        o.x = (b2 * c1 - b1 * c2) / det
        o.y = (a1 * c2 - a2 * c1) / det
    END IF
END SUB

FUNCTION lineSegmentsIntersect (l1 AS tLINE2d, l2 AS tLINE2d)
    DIM dx, dy, da, db, s, t AS _FLOAT
    dx = l1.b.x - l1.a.x
    dy = l1.b.y - l1.a.y
    da = l2.b.x - l2.a.x
    db = l2.b.y - l2.a.y
    IF da * dy - db * dx = 0 THEN
        lineSegmentsIntersect = 0
    ELSE
        s = (dx * (l2.a.y - l1.a.y) + dy * (l1.a.x - l2.a.x)) / (da * dy - db * dx)
        t = (da * (l1.a.y - l2.a.y) + db * (l2.a.x - l1.a.x)) / (db * dx - da * dy)
        lineSegmentsIntersect = (s >= 0 AND s <= 1 AND t >= 0 AND t <= 1)
    END IF
END FUNCTION

'**********************************************************************************************
'   Impulse Specific Math Ahead
'**********************************************************************************************

FUNCTION impulseEqual (a AS _FLOAT, b AS _FLOAT)
    impulseEqual = ABS(a - b) <= cEPSILON
END FUNCTION

FUNCTION impulseClamp (min AS _FLOAT, max AS _FLOAT, a AS _FLOAT)
    IF a < min THEN
        impulseClamp = min
    ELSE IF a > max THEN
            impulseClamp = max
        ELSE
            impulseClamp = a
        END IF
    END IF
END FUNCTION

FUNCTION impulseRound (a AS _FLOAT)
    impulseRound = INT(a + 0.5)
END FUNCTION

FUNCTION impulseRandom_float (min AS _FLOAT, max AS _FLOAT)
    impulseRandom_float = ((max - min) * RND + min)
END FUNCTION

FUNCTION impulseRandomInteger (min AS INTEGER, max AS INTEGER)
    impulseRandomInteger = INT((max - min) * RND + min)
END FUNCTION

FUNCTION impulseGT (a AS _FLOAT, b AS _FLOAT)
    impulseGT = (a >= b * cBIAS_RELATIVE + a * cBIAS_ABSOLUTE)
END FUNCTION

'**********************************************************************************************
'   Troubleshooting Tools
'**********************************************************************************************

SUB printMatrix (u AS tMATRIX2d, n AS INTEGER)
    PRINT "---------------------------"
    PRINT n; " u:"; u.m00; "|"; u.m10
    PRINT "       "; u.m10; "|"; u.m11
    DO
    LOOP UNTIL _KEYHIT = 27
END SUB

'**********************************************************************************************
'   String Hash
'**********************************************************************************************

FUNCTION computeHash&& (s AS STRING)
    DIM p, i AS INTEGER: p = 31
    DIM m AS _INTEGER64: m = 1E9 + 9
    DIM AS _INTEGER64 hash_value, p_pow
    p_pow = 1
    FOR i = 1 TO LEN(s)
        hash_value = (hash_value + (ASC(MID$(s, i)) - 97 + 1) * p_pow)
        p_pow = (p_pow * p) MOD m
    NEXT
    computeHash = hash_value
END FUNCTION
'**********************************************************************************************
'   Load Bitmap
'**********************************************************************************************
SUB loadBitmap (textureMap() AS LONG)
    DIM AS INTEGER index
    DIM AS STRING fl
    FOR index = 1 TO 16
        fl = _CWD$ + "\Assets\ball_" + LTRIM$(STR$(index)) + ".png"
        textureMap(index) = _LOADIMAGE(fl)
        IF textureMap(index) > -2 THEN
            PRINT "Unable to load image "; fl; " with return of "; textureMap(index)
            END
        END IF
    NEXT
    textureMap(index + 1) = _LOADIMAGE(_CWD$ + "\Assets\cue.png")
    textureMap(index + 2) = _LOADIMAGE(_CWD$ + "\Assets\table.png")
    textureMap(index + 3) = _LOADIMAGE(_CWD$ + "\Assets\triangle.png")
    textureMap(index + 4) = _LOADIMAGE(_CWD$ + "\Assets\ballreturn.png")
END SUB

