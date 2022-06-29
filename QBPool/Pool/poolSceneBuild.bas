'$include:'/../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../fzxNGN/typesAndConstants/fzxNGNConst.bas'
'$include:'/../fzxNGN/typesAndConstants/fzxNGNShared.bas'
'$include:'/../fzxNGN/typesAndConstants/fzxNGNArrays.bas'

'$include:'/../Pool/poolTypesConstArrays.bas'

'$include:'/../fzxNGN/rendering/textureLoad.bas'
'$include:'/../fzxNGN/math/vector.bas'
'$include:'/../fzxNGN/body/bodyCreate.bas'
'$include:'/../fzxNGN/objectManager/objectManager.bas'
$IF SCENEBUILDINCLUDE = UNDEFINED THEN
    $LET SCENEBUILDINCLUDE = TRUE



    SUB buildScene (p() AS tPOLY, body() AS tBODY, j() AS tJOINT, camera AS tCAMERA, textureMap() AS LONG, v() AS tVEHICLE, net AS tNETWORK)
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
        camera.zoom = .25
        CALL loadBitmap(textureMap())

        '********************************************************
        '   Setup World
        '********************************************************

        CALL vectorSet(world.minusLimit, -6500, -2000) 'unused
        CALL vectorSet(world.plusLimit, 70000, 10000) 'unused
        CALL vectorSet(world.spawn, -5000, -800) ' unused
        CALL vectorSet(world.gravity, 0.0, 0.0) ' unused
        CALL vectorSet(world.terrainPosition, -7000.0, 1000.0) ' Unused
        DIM o AS tVECTOR2d: CALL vectorMultiplyScalarND(o, world.gravity, cDT): sRESTING = vectorLengthSq(o) + cEPSILON

        '********************************************************
        '   Setup Network
        '********************************************************
        net.address = "localhost"
        net.port = 1234
        net.protocol = "TCP/IP"
        net.SorC = cNET_NONE

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
        PRINT "- 'H' or 'h' to network host."
        PRINT "- 'C' or 'c' to be a network client."
        PRINT "- 'D' or 'd' to disconnect from server."
        PRINT "- <ESC> to quit."
        genPool.instructions = 1
        _DEST 0

    END SUB

$END IF
