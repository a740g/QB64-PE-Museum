'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'**********************************************************************************************
'   Vector Math Ahead
'**********************************************************************************************
$IF VECTORINCLUDE = UNDEFINED THEN
    $LET VECTORINCLUDE = TRUE

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

    SUB vectorOrbitVector (o AS tVECTOR2d, position AS tVECTOR2d, dist AS _FLOAT, angle AS _FLOAT)
        o.x = COS(angle) * dist + position.x
        o.y = SIN(angle) * dist + position.y
    END SUB

$END IF
