'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/physics/impulse.bas'

'**********************************************************************************************
'   Manifold Stuff Ahead
'**********************************************************************************************
$IF MANIFOLDINCLUDE = UNDEFINED THEN
    $LET MANIFOLDINCLUDE = TRUE

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

$end if
