$RESIZE:ON
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
'*/
'

'**********************************************************************************************
'   Setup Engine Types and Variables
'**********************************************************************************************
'$include:'fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'fzxNGN/typesAndConstants/fzxNGNConst.bas'
'$include:'fzxNGN/typesAndConstants/fzxNGNShared.bas'
'$include:'fzxNGN/typesAndConstants/fzxNGNArrays.bas'
'**********************************************************************************************
'   Game specific Variables
'**********************************************************************************************
'$include:'Pool/poolTypesConstArrays.bas'
'**********************************************************************************************
'
DIM AS LONG scr, oldScr
initScreen scr
initFPS


'RANDOMIZE TIMER


'**********************************************************************************************
' 05-22-21 : Added resize
' 05-22-21 : Consolidated shooting the ball into shootBall function
' 05-22-21 : Added Mouse PoseEdge and NegEdge, tidyied up the code
' 05-23-21 : Push Screen Init and FPS init to functions
' 05-23-21 : Auto Center FPS Counter
' 05-23-21 : Realized that you dont need to use CALL if you dont use () around the arguments
'            Purged CALL's from main program
' 05-26-21 : Purged CALL's from impulse.bas
' 05-27-21 : More purging of CALL's

'**********************************************************************************************
'TODO: GUI
'TODO: Fine tune controls.
'TODO: Space bar to shoot.
'TODO: Counter balance english indicator with power and angle indicator.
'TODO: Work on draw and follow english
'TODO: Network scratch bug

buildScene poly(), body(), joints(), camera, texture(), veh(), network
'**********************************************************************************************

DO: fps = fps + 1
    _PRINTMODE _KEEPBACKGROUND
    CLS , _RGB32(67, 39, 0)
    DIM fpss AS STRING
    fpss = "FPS:" + STR$(fpsLast)
    _PRINTSTRING ((_WIDTH / 2) - (_PRINTWIDTH(fpss) / 2), 0), fpss

    renderBodies poly(), body(), joints(), hits(), camera
    runScene poly(), body(), joints(), hits(), texture(), camera, veh(), inputDevice, network
    IF network.SorC <> cNET_CLIENT THEN 'trust the physics coming from the server
        impulseStep poly(), body(), joints(), hits(), cDT, cITERATIONS
    END IF

    IF _RESIZE THEN
        oldScr = scr
        scr = _NEWIMAGE(_RESIZEWIDTH, _RESIZEHEIGHT, 32)
        SCREEN scr
        _FREEIMAGE oldScr
    END IF

    _DISPLAY
    _LIMIT 120
LOOP UNTIL _KEYHIT = 27
networkClose network
SYSTEM



'**********************************************************************************************
'   End of Main loop
'**********************************************************************************************
'$include:'/fzxNGN/math/vector.bas'
'$include:'/fzxNGN/math/matrix2d.bas'
'$include:'/fzxNGN/math/impulseMath.bas'
'$include:'/fzxNGN/math/misc.bas'
'$include:'/fzxNGN/body/bodyInit.bas'
'$include:'/fzxNGN/body/bodyCreate.bas'
'$include:'/fzxNGN/body/shape.bas'
'$include:'/fzxNGN/body/bodyTools.bas'
'$include:'/fzxNGN/body/misc.bas'


'$include:'/fzxNGN/physics/impulse.bas'
'$include:'/fzxNGN/physics/joint.bas'
'$include:'/fzxNGN/physics/collisionQuery.bas'
'$include:'/fzxNGN/objectManager/objectManager.bas'
'$include:'/fzxNGN/network/network.bas'
'$include:'/fzxNGN/inputDevices/inputDevices.bas'
'$include:'/fzxNGN/rendering/rendering.bas'
'$include:'/fzxNGN/rendering/textureLoad.bas'
'$include:'/fzxNGN/rendering/camera.bas'



'$include:'Pool/poolMethods.bas'
'$include:'Pool/poolSceneBuild.bas'

SUB initScreen (scr AS LONG)
    _TITLE "FzxNGN POOL"
    scr = _NEWIMAGE(1024, 768, 32)
    SCREEN scr
END SUB

SUB initFPS
    DIM timerOne AS INTEGER
    timerOne = _FREETIMER
    ON TIMER(timerOne, 1) renderFps
    TIMER(timerOne) ON
END SUB

SUB renderFps
    fpsLast = fps
    fps = 0
END SUB


'**********************************************************************************************
'   Scene Creation and Handling Ahead
'**********************************************************************************************

SUB runScene (poly() AS tPOLY, body() AS tBODY, joints() AS tJOINT, hits() AS tHIT, textureMap() AS LONG, camera AS tCAMERA, veh() AS tVEHICLE, iDevice AS tINPUTDEVICE, net AS tNETWORK)
    ' Cache some widely used ID's
    DIM cueBall AS _INTEGER64: cueBall = objectManagerID(body(), "cSCENE_BALL16")
    DIM cue AS _INTEGER64: cue = objectManagerID(body(), "cSCENE_CUE")

    STATIC AS _FLOAT cueAngle, cueDistance, cueDrawingDistance
    DIM AS tVECTOR2d cueNormal, cuePos, cueBall2Camera, cuePower, mousePosVector
    DIM guideLine AS tLINE2d


    ' Ignore this
    veh(0).vehicleName = "Nothing" 'this is just to clear the warnings

    ' Mouse and keyboard handling, mainly mouse, keyboard is too slow for indirect
    handleInputDevice iDevice
    ' Change cueball to camera coordinate system.
    worldToCamera body(), camera, cueBall, cueBall2Camera


    ' Some Maths
    vectorSet mousePosVector, iDevice.x, iDevice.y
    cueNormal.x = cueBall2Camera.x - iDevice.x ' x-Component of Distance
    cueNormal.y = cueBall2Camera.y - iDevice.y ' y-Component of Distance
    cueAngle = _ATAN2(-cueNormal.y, -cueNormal.x) ' Use mouse to control the cue angle
    cueDistance = vectorDistance(mousePosVector, cueBall2Camera)
    cueDrawingDistance = (cueDistance * .25) + 450 ' Use this to guage power
    vectorOrbitVector cuePos, body(cueBall).position, cueDrawingDistance, cueAngle ' calculate cue position
    cuePower.x = cueNormal.x * cPLAYER_FORCE
    cuePower.y = cueNormal.y * cPLAYER_FORCE
    vectorOrbitVector guideLine.a, cueBall2Camera, (25 * camera.zoom), cueAngle + _PI
    vectorOrbitVector guideLine.b, cueBall2Camera, (1000 * camera.zoom), cueAngle + _PI


    ' Aim the Stick
    IF bodyAtRest(body(cueBall)) THEN ' AIM
        setBody body(), cPARAMETER_ENABLE, cue, 1, 0
        setBody body(), cPARAMETER_ORIENT, cue, cueAngle, 0
        setBody body(), cPARAMETER_POSITION, cue, cuePos.x, cuePos.y
        IF net.SorC <> cNET_CLIENT THEN LINE (guideLine.a.x, guideLine.a.y)-(guideLine.b.x, guideLine.b.y)
        camera.position = body(cueBall).position
    ELSE
        setBody body(), cPARAMETER_ENABLE, cue, 0, 0
    END IF

    ' Camera Zoom
    camera.zoom = camera.zoom + (iDevice.wCount * .01)
    IF camera.zoom < .125 THEN camera.zoom = .125

    ' Hit the ball
    ' Verify cue ball is not moving - I really need to check that all balls are not moving.
    IF bodyAtRest(body(cueBall)) THEN
        IF iDevice.b1PosEdge THEN ' only fire once
            shootBall body(), cueBall, cuePower, 1
        END IF
    END IF

    IF _KEYDOWN(cKEY_ARROW_LEFT) THEN ' Left English
        genPool.english.x = genPool.english.x + 1
        IF genPool.english.x > 200 THEN genPool.english.x = 200
    END IF

    IF _KEYDOWN(cKEY_ARROW_RIGHT) THEN ' Right English
        genPool.english.x = genPool.english.x - 1
        IF genPool.english.x < -200 THEN genPool.english.x = -200
    END IF

    IF _KEYDOWN(ASC("R")) OR _KEYDOWN(ASC("r")) THEN ' ReRack balls
        ' Put all balls back in their rack positions
        reRackBalls body()
    END IF

    IF _KEYDOWN(cKEY_SPACE) THEN ' Spacebar  - For break
        ' Verify cue ball is not moving - I really need to check that all balls are not moving.
        IF bodyAtRest(body(cueBall)) THEN
            shootBall body(), cueBall, cuePower, 2
        END IF
    END IF

    ' Check your shot feature
    IF _KEYDOWN(cKEY_TAB) AND bodyAtRest(body(cueBall)) THEN 'TAB - LOOK ahead
        checkShot poly(), body(), joints(), hits(), camera, cue, cueBall, cuePower
    END IF

    ' Instruction GUI
    IF _KEYDOWN(ASC("I")) OR _KEYDOWN(ASC("i")) THEN ' Show instructions
        genPool.instructionImage = _COPYIMAGE(textureMap(22))
        genPool.instructions = 1
        sTIMER = TIMER
    END IF

    IF _KEYDOWN(ASC("H")) OR _KEYDOWN(ASC("h")) AND net.SorC <> cNET_SERVER THEN
        net.SorC = cNET_SERVER
    END IF

    IF _KEYDOWN(ASC("C")) OR _KEYDOWN(ASC("c")) AND net.SorC <> cNET_CLIENT THEN
        IF net.SorC = cNET_SERVER THEN networkClose net
        net.SorC = cNET_CLIENT
    END IF

    IF _KEYDOWN(ASC("D")) OR _KEYDOWN(ASC("d")) AND net.SorC <> cNET_NONE THEN
        networkClose net
        net.SorC = cNET_NONE
    END IF

    IF _KEYDOWN(ASC("B")) OR _KEYDOWN(ASC("b")) THEN
        changeTableToBlue textureMap()
    END IF

    handleInstructions textureMap() ' Player instruction fade out
    handleNetwork body(), net
    handlePocketSensors body(), hits(), 0 ' Check for pocketed balls
    handleBallReturn body(), cueBall ' roll the balls down the ball return
    renderEnglishIndicator textureMap() ' English Indicator
    checkForScratch body(), 16, 0 ' check for a scratch

END SUB

SUB shootBall (body() AS tBODY, cueBall AS INTEGER, pwr AS tVECTOR2d, multiplier AS INTEGER)
    'Apply hitting Force and English
    setBody body(), cPARAMETER_ANGULARVELOCITY, cueBall, genPool.english.x, 0
    setBody body(), cPARAMETER_FORCE, cueBall, pwr.x * multiplier, pwr.y * multiplier
    ' Reset English
    genPool.english.x = 0
    genPool.english.y = 0
END SUB


SUB renderEnglishIndicator (textureMap() AS LONG)
    ' Show english Indicator - Only Left and Right are supported
    _PUTIMAGE (0, _HEIGHT(0) - 140), textureMap(16), 0,
    CIRCLE (70 - genPool.english.x / 4, _HEIGHT(0) - 70), 10, _RGB(72, 111, 183)
END SUB

SUB handleInstructions (textureMap() AS LONG)
    IF TIMER - sTIMER > 20 THEN genPool.instructions = 0 ' instruction timeout 20 sec
    IF genPool.instructions THEN
        genPool.instructionImage = _COPYIMAGE(textureMap(22))
        IF TIMER - sTIMER > 15 THEN 'After 15 seconds fade it out
            _SETALPHA INT((20 - (TIMER - sTIMER)) * 50), _RGB(255, 255, 255), genPool.instructionImage
        END IF
        _PUTIMAGE (0, 0), genPool.instructionImage, 0 ' INSTRUCTIONS
        _FREEIMAGE genPool.instructionImage
    END IF
END SUB

SUB changeTableToBlue (textureMap() AS LONG)
    _SOURCE textureMap(19)
    _DEST textureMap(19)
    DIM AS INTEGER x, y, r, g, b
    DIM AS LONG c
    FOR x = 0 TO _WIDTH
        FOR y = 0 TO _HEIGHT
            c = POINT(x, y): r = _RED(c): g = _GREEN(c): b = _BLUE(c)
            IF g > 96 THEN
                PSET (x, y), _RGB32(r, b, g)
            END IF
        NEXT
    NEXT
    _SOURCE 0
    _DEST 0
END SUB

SUB handleBallReturn (body() AS tBODY, cueBall AS LONG)
    DIM AS INTEGER ballCount, index
    ballCount = 0
    FOR index = 1 TO 16 'Make balls roll across ball return
        ' check if balls are off the table and then give it "gravity"
        IF body(pool(index).objId).position.y > 750 THEN
            setBody body(), cPARAMETER_FORCE, pool(index).objId, 200000, 100000
            ballCount = ballCount + 1
        END IF
        ' rerack table if all the balls are in the ball return
        IF ballCount > 14 AND bodyAtRest(body(cueBall)) THEN reRackBalls body()
    NEXT
END SUB

SUB checkShot (poly() AS tPOLY, body() AS tBODY, joints() AS tJOINT, hits() AS tHIT, camera AS tCAMERA, cue AS LONG, cueball AS LONG, cuePower AS tVECTOR2d)
    DIM ghostBody(UBOUND(body)) AS tBODY ' Create a new list of bodies
    DIM AS LONG ghostImg
    DIM AS INTEGER index
    copyBodies body(), ghostBody() ' Copy all the bodies to the new list
    ' Apply Forces to the Cue Ball in the Bodies
    shootBall ghostBody(), cueball, cuePower, 1
    ' Create a Ghost Image Overlay
    ghostImg = _NEWIMAGE(_WIDTH(0), _HEIGHT(0), 32)
    _DEST ghostImg
    _SETALPHA 127, 0 TO 255, ghostImg
    ' Hide the table since we only car abou the balls
    setBodyEx ghostBody(), cPARAMETER_ENABLE, "cSCENE_TABLE", 0, 0
    setBody ghostBody(), cPARAMETER_ENABLE, cue, 0, 0
    ' Run Simulation for about 2 secs
    FOR index = 0 TO 120 ' number of frames for look ahead .. 120 fps = 1 sec
        impulseStep poly(), ghostBody(), joints(), hits(), cDT, cITERATIONS
        handlePocketSensors ghostBody(), hits(), 1
        checkForScratch ghostBody(), 16, 0
        renderBodies poly(), ghostBody(), joints(), hits(), camera
    NEXT
    ' Return Screen to normal
    _DEST 0
    ' Display overlay
    _PUTIMAGE (0, 0), ghostImg, 0
    _DISPLAY
    ' Free up overlay
    _FREEIMAGE ghostImg
END SUB

