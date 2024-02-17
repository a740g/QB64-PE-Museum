'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'$include:'/../../fzxNGN/rendering/camera.bas'
'**********************************************************************************************
'   Rendering Stuff Ahead
'**********************************************************************************************
$IF RENDERINCLUDE = UNDEFINED THEN
    $LET RENDERINCLUDE = TRUE


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
$END IF
