'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'**********************************************************************************************
'   Joint Stuff Ahead
'**********************************************************************************************
$IF JOINTINCLUDE = UNDEFINED THEN
    $LET JOINTINCLUDE = TRUE

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
$END IF
