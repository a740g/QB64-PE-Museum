
'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/typesAndConstants/fzxNGNShared.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'$include:'/../../fzxNGN/math/misc.bas'
'$include:'/../../fzxNGN/physics/collision.bas'
'$include:'/../../fzxNGN/physics/joint.bas'


'**********************************************************************************************
'   Physics and Collision Stuff Ahead
'**********************************************************************************************


$IF IMPULSEINCLUDE = UNDEFINED THEN
    $LET IMPULSEINCLUDE = TRUE


    SUB impulseIntegrateForces (b AS tBODY, dt AS _FLOAT)
        IF b.invMass = 0.0 THEN EXIT SUB
        DIM dts AS _FLOAT
        dts = dt * .5
        vectorAddVectorScalar b.velocity, b.force, b.invMass * dts
        vectorAddVectorScalar b.velocity, world.gravity, dts
        b.angularVelocity = b.angularVelocity + (b.torque * b.invInertia * dts)
    END SUB

    SUB impulseIntegrateVelocity (body AS tBODY, dt AS _FLOAT)
        IF body.invMass = 0.0 THEN EXIT SUB
        body.velocity.x = body.velocity.x * (1 - dt)
        body.velocity.y = body.velocity.y * (1 - dt)
        body.angularVelocity = body.angularVelocity * (1 - dt)
        vectorAddVectorScalar body.position, body.velocity, dt
        body.orient = body.orient + (body.angularVelocity * dt)
        matrixSetRadians body.shape.u, body.orient
        impulseIntegrateForces body, dt
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
                                collisionCCHandle m, c(), A, B
                            ELSE
                                IF A.shape.ty = cSHAPE_POLYGON AND B.shape.ty = cSHAPE_POLYGON THEN
                                    collisionPPHandle p(), body(), m, c(), i, j
                                ELSE
                                    IF A.shape.ty = cSHAPE_CIRCLE AND B.shape.ty = cSHAPE_POLYGON THEN
                                        collisionCPHandle p(), body(), m, c(), i, j
                                    ELSE
                                        IF B.shape.ty = cSHAPE_CIRCLE AND A.shape.ty = cSHAPE_POLYGON THEN
                                            collisionPCHandle p(), body(), m, c(), i, j
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
            IF body(i).enable THEN impulseIntegrateForces body(i), dt
        NEXT
        '   // Initialize collision
        FOR i = 0 TO manifoldCount - 1
            ' this is the stupidest thing ever since QB will not let you split arrays
            FOR k = 0 TO manifolds(i).contactCount - 1
                c(k) = collisions(i, k)
            NEXT
            manifoldInit manifolds(i), body(), c()
        NEXT
        ' joint pre Steps

        FOR i = 1 TO sNUMBEROFJOINTS
            jointPrestep j(i), body(), dt
        NEXT

        '// Solve collisions
        FOR j = 0 TO iterations - 1
            FOR i = 0 TO manifoldCount - 1
                FOR k = 0 TO manifolds(i).contactCount - 1
                    c(k) = collisions(i, k)
                NEXT
                manifoldApplyImpulse manifolds(i), body(), c()
                'store the hit speed for later
                FOR k = 0 TO hitCount - 1
                    IF manifolds(i).A = hits(k).A AND manifolds(i).B = hits(k).B THEN
                        hits(k).cv = manifolds(i).cv
                    END IF
                NEXT
            NEXT
            FOR i = 1 TO sNUMBEROFJOINTS
                jointApplyImpulse j(i), body()
            NEXT
        NEXT

        '// Integrate velocities
        FOR i = 0 TO objectManager.objectCount
            IF body(i).enable THEN impulseIntegrateVelocity body(i), dt
        NEXT
        '// Correct positions
        FOR i = 0 TO manifoldCount - 1
            manifoldPositionalCorrection manifolds(i), body()
        NEXT
        '// Clear all forces
        FOR i = 0 TO objectManager.objectCount
            vectorSet body(i).force, 0, 0
            body(i).torque = 0
        NEXT
    END SUB

    SUB bodyApplyImpulse (body AS tBODY, impulse AS tVECTOR2d, contactVector AS tVECTOR2d)
        vectorAddVectorScalar body.velocity, impulse, body.invMass
        body.angularVelocity = body.angularVelocity + body.invInertia * vectorCross(contactVector, impulse)
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
            vectorSubVectorND contacts(i), body(m.A).position, ra
            vectorSubVectorND contacts(i), body(m.B).position, rb

            vectorCrossScalar tv1, rb, body(m.B).angularVelocity
            vectorCrossScalar tv2, ra, body(m.A).angularVelocity
            vectorAddVector tv1, body(m.B).velocity
            vectorSubVectorND tv2, body(m.A).velocity, tv2
            vectorSubVectorND rv, tv1, tv2

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
            manifoldInfiniteMassCorrection body(m.A), body(m.B)
            EXIT SUB
        END IF

        FOR i = 0 TO m.contactCount - 1
            '// Calculate radii from COM to contact
            '// Vec2 ra = contacts[i] - A->position;
            '// Vec2 rb = contacts[i] - B->position;
            vectorSubVectorND ra, contacts(i), body(m.A).position
            vectorSubVectorND rb, contacts(i), body(m.B).position

            '// Relative velocity
            '// Vec2 rv = B->velocity + Cross( B->angularVelocity, rb ) - A->velocity - Cross( A->angularVelocity, ra );
            vectorCrossScalar tv1, rb, body(m.B).angularVelocity
            vectorCrossScalar tv2, ra, body(m.A).angularVelocity
            vectorAddVectorND rv, tv1, body(m.B).velocity
            vectorSubVector rv, body(m.A).velocity
            vectorSubVector rv, tv2

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
            vectorMultiplyScalarND impulse, m.normal, j
            vectorNegND tv1, impulse
            bodyApplyImpulse body(m.A), tv1, ra
            bodyApplyImpulse body(m.B), impulse, rb

            '// Friction impulse
            '// rv = B->velocity + Cross( B->angularVelocity, rb ) - A->velocity - Cross( A->angularVelocity, ra );
            vectorCrossScalar tv1, rb, body(m.B).angularVelocity
            vectorCrossScalar tv2, ra, body(m.A).angularVelocity
            vectorAddVectorND rv, tv1, body(m.B).velocity
            vectorSubVector rv, body(m.A).velocity
            vectorSubVector rv, tv2

            '// Vec2 t = rv - (normal * Dot( rv, normal ));
            '// t.Normalize( );
            vectorMultiplyScalarND t, m.normal, vectorDot(rv, m.normal)
            vectorSubVectorND t, rv, t
            vectorNormalize t

            '// j tangent magnitude
            jt = -vectorDot(rv, t)
            jt = jt / invMassSum
            jt = jt / m.contactCount

            '// Don't apply tiny friction impulses
            IF impulseEqual(jt, 0.0) THEN EXIT SUB

            '// Coulumb's law
            IF ABS(jt) < j * m.sf THEN
                vectorMultiplyScalarND tangentImpulse, t, jt
            ELSE
                vectorMultiplyScalarND tangentImpulse, t, -j * m.df
            END IF

            '// Apply friction impulse
            '// A->ApplyImpulse( -tangentImpulse, ra );
            '// B->ApplyImpulse( tangentImpulse, rb );
            vectorNegND tv1, tangentImpulse
            bodyApplyImpulse body(m.A), tv1, ra
            bodyApplyImpulse body(m.B), tangentImpulse, rb
        NEXT i
    END SUB

    SUB manifoldPositionalCorrection (m AS tMANIFOLD, body() AS tBODY)
        DIM correction AS _FLOAT
        correction = scalarMax(m.penetration - cPENETRATION_ALLOWANCE, 0.0) / (body(m.A).invMass + body(m.B).invMass) * cPENETRATION_CORRECTION
        vectorAddVectorScalar body(m.A).position, m.normal, -body(m.A).invMass * correction
        vectorAddVectorScalar body(m.B).position, m.normal, body(m.B).invMass * correction
    END SUB

    SUB manifoldInfiniteMassCorrection (A AS tBODY, B AS tBODY)
        vectorSet A.velocity, 0, 0
        vectorSet B.velocity, 0, 0
    END SUB

$END IF



