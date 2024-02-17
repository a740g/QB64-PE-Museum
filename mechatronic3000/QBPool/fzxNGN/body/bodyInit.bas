'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'**********************************************************************************************
'   Object initialization Ahead
'**********************************************************************************************
$IF BODYINITINCLUDE = UNDEFINED THEN
    $LET BODYINITINCLUDE = TRUE


    SUB circleInitialize (b() AS tBODY, index AS INTEGER)
        circleComputeMass b(), index, .10
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
        polygonComputeMass body(), p(), index, .10
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
            vectorAddVectorScalar c, p1, weight
            vectorAddVectorScalar c, p2, weight
            intx2 = p1.x * p1.x + p2.x * p1.x + p2.x * p2.x
            inty2 = p1.y * p1.y + p2.y * p1.y + p2.y * p2.y
            I = I + (0.25 * k_inv3 * D) * (intx2 + inty2)
        NEXT ii

        vectorMultiplyScalar c, 1.0 / area

        FOR ii = 0 TO b(index).pa.count
            vectorSubVector p(b(index).pa.start + ii).vert, c
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
$END IF

