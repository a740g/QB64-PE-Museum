'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/body/shape.bas'
'$include:'/../../fzxNGN/body/bodyInit.bas'
'$include:'/../../fzxNGN/objectManager/objectManager.bas'
'$include:'/../../fzxNGN/body/bodyTools.bas'
$IF BODYCREATEINCLUDE = UNDEFINED THEN
    $LET BODYCREATEINCLUDE = TRUE

    FUNCTION createCircleBody (body() AS tBODY, index AS INTEGER, radius AS _FLOAT)
        DIM shape AS tSHAPE
        shapeCreate shape, cSHAPE_CIRCLE, radius
        bodyCreate body(), index, shape
        'no vertices have to created for circles
        circleInitialize body(), index
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
        shapeCreate shape, cSHAPE_CIRCLE, radius
        bodyCreateEx body(), objName, shape, index
        'no vertices have to created for circles
        circleInitialize body(), index
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
        shapeCreate shape, cSHAPE_POLYGON, 0
        bodyCreate body(), index, shape
        boxCreate p(), body(), index, xs, ys
        polygonInitialize body(), p(), index
        body(index).c = _RGB32(255, 255, 255)
        createBoxBodies = index
    END FUNCTION

    FUNCTION createBoxBodiesEx (p() AS tPOLY, body() AS tBODY, objName AS STRING, xs AS _FLOAT, ys AS _FLOAT)
        DIM shape AS tSHAPE
        DIM index AS INTEGER
        shapeCreate shape, cSHAPE_POLYGON, 0
        bodyCreateEx body(), objName, shape, index
        boxCreate p(), body(), index, xs, ys
        polygonInitialize body(), p(), index
        body(index).c = _RGB32(255, 255, 255)
        createBoxBodiesEx = index
    END FUNCTION

    SUB createTrapBody (p() AS tPOLY, body() AS tBODY, index AS INTEGER, xs AS _FLOAT, ys AS _FLOAT, yoff1 AS _FLOAT, yoff2 AS _FLOAT)
        DIM shape AS tSHAPE
        shapeCreate shape, cSHAPE_POLYGON, 0
        bodyCreate body(), index, shape
        trapCreate p(), body(), index, xs, ys, yoff1, yoff2
        polygonInitialize body(), p(), index
        body(index).c = _RGB32(255, 255, 255)
    END SUB

    SUB createTrapBodyEx (p() AS tPOLY, body() AS tBODY, objName AS STRING, xs AS _FLOAT, ys AS _FLOAT, yoff1 AS _FLOAT, yoff2 AS _FLOAT)
        DIM shape AS tSHAPE
        DIM index AS INTEGER
        shapeCreate shape, cSHAPE_POLYGON, 0
        bodyCreateEx body(), objName, shape, index
        trapCreate p(), body(), index, xs, ys, yoff1, yoff2
        polygonInitialize body(), p(), index
        body(index).c = _RGB32(255, 255, 255)
    END SUB



    SUB bodyCreateEx (body() AS tBODY, objName AS STRING, shape AS tSHAPE, index AS INTEGER)
        index = objectManagerAdd(body())
        body(index).objectName = objName
        body(index).objectHash = computeHash(objName)
        bodyCreate body(), index, shape
    END SUB


    SUB bodyCreate (body() AS tBODY, index AS INTEGER, shape AS tSHAPE)
        vectorSet body(index).position, 0, 0
        vectorSet body(index).velocity, 0, 0
        body(index).angularVelocity = 0.0
        body(index).torque = 0.0
        body(index).orient = 0.0

        vectorSet body(index).force, 0, 0
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

        vectorSet verts(0), -sizex, -sizey
        vectorSet verts(1), sizex, -sizey
        vectorSet verts(2), sizex, sizey
        vectorSet verts(3), -sizex, sizey

        vertexSet p(), body(), index, verts(), vertlength
    END SUB

    SUB trapCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, sizex AS _FLOAT, sizey AS _FLOAT, yOff1 AS _FLOAT, yOff2 AS _FLOAT)
        DIM vertlength AS INTEGER: vertlength = 3
        DIM verts(vertlength) AS tVECTOR2d

        vectorSet verts(0), -sizex, -sizey - yOff2
        vectorSet verts(1), sizex, -sizey - yOff1
        vectorSet verts(2), sizex, sizey
        vectorSet verts(3), -sizex, sizey

        vertexSet p(), body(), index, verts(), vertlength
    END SUB

    SUB createTerrianBody (p() AS tPOLY, body() AS tBODY, index AS INTEGER, slices AS INTEGER, sliceWidth AS _FLOAT, nominalHeight AS _FLOAT)
        DIM shape AS tSHAPE
        DIM elevation(slices) AS _FLOAT

        DIM AS INTEGER i, j
        FOR j = 0 TO slices
            elevation(j) = RND * 500
        NEXT

        shapeCreate shape, cSHAPE_POLYGON, 0

        FOR i = 0 TO slices - 1
            bodyCreate body(), index + i, shape
            terrainCreate p(), body(), index + i, elevation(i), elevation(i + 1), sliceWidth, nominalHeight
            polygonInitialize body(), p(), index + i
            body(index + i).c = _RGB32(255, 255, 255)
            bodySetStatic body(index + i)
        NEXT i

    END SUB

    SUB createTerrianBodyEx (p() AS tPOLY, body() AS tBODY, objName AS STRING, elevation() AS _FLOAT, slices AS INTEGER, sliceWidth AS _FLOAT, nominalHeight AS _FLOAT)
        DIM shape AS tSHAPE

        DIM AS INTEGER i, index

        shapeCreate shape, cSHAPE_POLYGON, 0

        FOR i = 0 TO slices - 1
            bodyCreateEx body(), objName + "_" + LTRIM$(STR$(i)), shape, index
            terrainCreate p(), body(), index, elevation(i), elevation(i + 1), sliceWidth, nominalHeight
            polygonInitialize body(), p(), index
            body(index).c = _RGB32(255, 255, 255)
            bodySetStatic body(index)
        NEXT i

        DIM AS _FLOAT p1, p2
        DIM start AS _INTEGER64

        FOR i = 0 TO slices - 1
            start = objectManagerID(body(), objName + "_" + LTRIM$(STR$(i)))
            p1 = (sliceWidth / 2) - p(body(start).pa.start).vert.x
            p2 = nominalHeight - p(body(start).pa.start + 1).vert.y
            setBody body(), cPARAMETER_POSITION, start, world.terrainPosition.x + p1 + (sliceWidth * i), world.terrainPosition.y + p2
        NEXT
    END SUB


    SUB terrainCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, ele1 AS _FLOAT, ele2 AS _FLOAT, sliceWidth AS _FLOAT, nominalHeight AS _FLOAT)
        DIM AS INTEGER vertLength
        vertLength = 3 ' numOfslices + 1
        DIM verts(vertLength) AS tVECTOR2d

        vectorSet verts(0), 0, nominalHeight
        vectorSet verts(1), (0) * sliceWidth, -nominalHeight - ele1
        vectorSet verts(2), (1) * sliceWidth, -nominalHeight - ele2
        vectorSet verts(3), (1) * sliceWidth, nominalHeight
        vertexSet p(), body(), index, verts(), vertLength
    END SUB



    SUB vShapeCreate (p() AS tPOLY, body() AS tBODY, index AS INTEGER, sizex AS _FLOAT, sizey AS _FLOAT)
        DIM vertlength AS INTEGER: vertlength = 7
        DIM verts(vertlength) AS tVECTOR2d

        vectorSet verts(0), -sizex, -sizey
        vectorSet verts(1), sizex, -sizey
        vectorSet verts(2), sizex, sizey
        vectorSet verts(3), -sizex, sizey
        vectorSet verts(4), -sizex, sizey / 2
        vectorSet verts(5), sizex / 2, sizey / 2
        vectorSet verts(6), sizex / 2, -sizey / 2
        vectorSet verts(7), -sizex, sizey / 2

        vertexSet p(), body(), index, verts(), vertlength
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
                vectorSubVectorND e1, verts(nextHullIndex), verts(hull(outCount))
                vectorSubVectorND e2, verts(i), verts(hull(outCount))
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
            vectorSubVectorND face, p(body(index).pa.start + arrayNextIndex(i, body(index).pa.count)).vert, p(body(index).pa.start + i).vert
            vectorSet p(body(index).pa.start + i).norm, face.y, -face.x
            vectorNormalize p(body(index).pa.start + i).norm
        NEXT
    END SUB
$END IF
