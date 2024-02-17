'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'$include:'/../../fzxNGN/objectManager/objectManager.bas'

'**********************************************************************************************
'   Body Tools ahead
'**********************************************************************************************
$IF BODYTOOLSINCLUDE = UNDEFINED THEN
    $LET BODYTOOLSINCLUDE = TRUE


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

    SUB bodySetStatic (body AS tBODY)
        body.inertia = 0.0
        body.invInertia = 0.0
        body.mass = 0.0
        body.invMass = 0.0
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

$END IF



