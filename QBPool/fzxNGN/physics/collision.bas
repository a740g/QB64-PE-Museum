'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'**********************************************************************************************
'   Collision Stuff Ahead
'**********************************************************************************************
$IF COLLISIONINCLUDE = UNDEFINED THEN
    $LET COLLISIONINCLUDE = TRUE


    SUB collisionCCHandle (m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS tBODY, B AS tBODY)
        DIM normal AS tVECTOR2d
        DIM dist_sqr AS _FLOAT
        DIM radius AS _FLOAT

        CALL vectorSubVectorND(normal, B.position, A.position) ' Subtract two vectors position A and position B
        dist_sqr = vectorLengthSq(normal) ' Calculate the distance between the balls or circles
        radius = A.shape.radius + B.shape.radius ' Add both circle A and circle B radius

        IF (dist_sqr >= radius * radius) THEN
            m.contactCount = 0
        ELSE
            DIM distance AS _FLOAT
            distance = SQR(dist_sqr)
            m.contactCount = 1

            IF distance = 0 THEN
                m.penetration = A.shape.radius
                CALL vectorSet(m.normal, 1.0, 0.0)
                CALL vectorSetVector(contacts(0), A.position)
            ELSE
                m.penetration = radius - distance
                CALL vectorDivideScalarND(m.normal, normal, distance)

                CALL vectorMultiplyScalarND(contacts(0), m.normal, A.shape.radius)
                CALL vectorAddVector(contacts(0), A.position)
            END IF
        END IF
    END SUB

    SUB collisionPCHandle (p() AS tPOLY, body() AS tBODY, m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS INTEGER, B AS INTEGER)
        CALL collisionCPHandle(p(), body(), m, contacts(), B, A)
        IF m.contactCount > 0 THEN
            CALL vectorNeg(m.normal)
        END IF
    END SUB

    SUB collisionCPHandle (p() AS tPOLY, body() AS tBODY, m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS INTEGER, B AS INTEGER)
        'A is the Circle
        'B is the POLY
        m.contactCount = 0
        DIM center AS tVECTOR2d
        DIM tm AS tMATRIX2d
        DIM tv AS tVECTOR2d
        DIM ARadius AS _FLOAT: ARadius = body(A).shape.radius

        CALL vectorSubVectorND(center, body(A).position, body(B).position)
        CALL matrixTranspose(body(B).shape.u, tm)
        CALL matrixMultiplyVector(tm, center, center)

        DIM separation AS _FLOAT: separation = -9999999
        DIM faceNormal AS INTEGER: faceNormal = 0
        DIM i AS INTEGER
        DIM s AS _FLOAT
        FOR i = 0 TO body(B).pa.count
            CALL vectorSubVectorND(tv, center, p(body(B).pa.start + i).vert)
            s = vectorDot(p(body(B).pa.start + i).norm, tv)
            IF s > ARadius THEN EXIT SUB
            IF s > separation THEN
                separation = s
                faceNormal = i
            END IF
        NEXT
        DIM v1 AS tVECTOR2d
        v1 = p(body(B).pa.start + faceNormal).vert
        DIM i2 AS INTEGER
        i2 = body(B).pa.start + arrayNextIndex(faceNormal, body(B).pa.count)
        DIM v2 AS tVECTOR2d
        v2 = p(i2).vert

        IF separation < cEPSILON THEN
            m.contactCount = 1
            CALL matrixMultiplyVector(body(B).shape.u, p(body(B).pa.start + faceNormal).norm, m.normal)
            CALL vectorNeg(m.normal)
            CALL vectorMultiplyScalarND(contacts(0), m.normal, ARadius)
            CALL vectorAddVector(contacts(0), body(A).position)
            m.penetration = ARadius
            EXIT SUB
        END IF

        DIM dot1 AS _FLOAT
        DIM dot2 AS _FLOAT

        DIM tv1 AS tVECTOR2d
        DIM tv2 AS tVECTOR2d
        DIM n AS tVECTOR2d
        CALL vectorSubVectorND(tv1, center, v1)
        CALL vectorSubVectorND(tv2, v2, v1)
        dot1 = vectorDot(tv1, tv2)
        CALL vectorSubVectorND(tv1, center, v2)
        CALL vectorSubVectorND(tv2, v1, v2)
        dot2 = vectorDot(tv1, tv2)
        m.penetration = ARadius - separation
        IF dot1 <= 0.0 THEN
            IF vectorSqDist(center, v1) > ARadius * ARadius THEN EXIT SUB
            m.contactCount = 1
            CALL vectorSubVectorND(n, v1, center)
            CALL matrixMultiplyVector(body(B).shape.u, n, n)
            CALL vectorNormalize(n)
            m.normal = n
            CALL matrixMultiplyVector(body(B).shape.u, v1, v1)
            CALL vectorAddVectorND(v1, v1, body(B).position)
            contacts(0) = v1
        ELSE
            IF dot2 <= 0.0 THEN
                IF vectorSqDist(center, v2) > ARadius * ARadius THEN EXIT SUB
                m.contactCount = 1
                CALL vectorSubVectorND(n, v2, center)
                CALL matrixMultiplyVector(body(B).shape.u, v2, v2)
                CALL vectorAddVectorND(v2, v2, body(B).position)
                contacts(0) = v2
                CALL matrixMultiplyVector(body(B).shape.u, n, n)
                CALL vectorNormalize(n)
                m.normal = n
            ELSE
                n = p(body(B).pa.start + faceNormal).norm
                CALL vectorSubVectorND(tv1, center, v1)
                IF vectorDot(tv1, n) > ARadius THEN EXIT SUB
                m.contactCount = 1
                CALL matrixMultiplyVector(body(B).shape.u, n, n)
                CALL vectorNeg(n)
                m.normal = n
                CALL vectorMultiplyScalarND(contacts(0), m.normal, ARadius)
                CALL vectorAddVector(contacts(0), body(A).position)
            END IF
        END IF
    END SUB

    FUNCTION collisionPPClip (n AS tVECTOR2d, c AS _FLOAT, face() AS tVECTOR2d)
        DIM sp AS INTEGER: sp = 0
        DIM o(cMAXNUMBEROFPOLYGONS) AS tVECTOR2d

        o(0) = face(0)
        o(1) = face(1)

        DIM d1 AS _FLOAT: d1 = vectorDot(n, face(0)) - c
        DIM d2 AS _FLOAT: d2 = vectorDot(n, face(1)) - c

        IF d1 <= 0.0 THEN
            o(sp) = face(0)
            sp = sp + 1
        END IF

        IF d2 <= 0.0 THEN
            o(sp) = face(1)
            sp = sp + 1
        END IF

        IF d1 * d2 < 0.0 THEN
            DIM alpha AS _FLOAT: alpha = d1 / (d1 - d2)
            DIM tempv AS tVECTOR2d
            'out[sp] = face[0] + alpha * (face[1] - face[0]);
            CALL vectorSubVectorND(tempv, face(1), face(0))
            CALL vectorMultiplyScalar(tempv, alpha)
            CALL vectorAddVectorND(o(sp), tempv, face(0))
            sp = sp + 1
        END IF
        face(0) = o(0)
        face(1) = o(1)
        collisionPPClip = sp
    END FUNCTION

    SUB collisionPPFindIncidentFace (p() AS tPOLY, b() AS tBODY, v() AS tVECTOR2d, RefPoly AS INTEGER, IncPoly AS INTEGER, referenceIndex AS INTEGER)
        DIM referenceNormal AS tVECTOR2d
        DIM uRef AS tMATRIX2d: uRef = b(RefPoly).shape.u
        DIM uInc AS tMATRIX2d: uInc = b(IncPoly).shape.u
        DIM uTemp AS tMATRIX2d
        DIM i AS INTEGER
        referenceNormal = p(b(RefPoly).pa.start + referenceIndex).norm

        '        // Calculate normal in incident's frame of reference
        '        // referenceNormal = RefPoly->u * referenceNormal; // To world space
        CALL matrixMultiplyVector(uRef, referenceNormal, referenceNormal)
        '        // referenceNormal = IncPoly->u.Transpose( ) * referenceNormal; // To incident's model space
        CALL matrixTranspose(uInc, uTemp)
        CALL matrixMultiplyVector(uTemp, referenceNormal, referenceNormal)

        DIM incidentFace AS INTEGER: incidentFace = 0
        DIM minDot AS _FLOAT: minDot = 9999999
        DIM dot AS _FLOAT
        FOR i = 0 TO b(IncPoly).pa.count
            dot = vectorDot(referenceNormal, p(b(IncPoly).pa.start + i).norm)
            IF (dot < minDot) THEN
                minDot = dot
                incidentFace = i
            END IF
        NEXT

        '// Assign face vertices for incidentFace
        '// v[0] = IncPoly->u * IncPoly->m_vertices[incidentFace] + IncPoly->body->position;
        CALL matrixMultiplyVector(uInc, p(b(IncPoly).pa.start + incidentFace).vert, v(0))
        CALL vectorAddVector(v(0), b(IncPoly).position)

        '// incidentFace = incidentFace + 1 >= (int32)IncPoly->m_vertexCount ? 0 : incidentFace + 1;
        incidentFace = arrayNextIndex(incidentFace, b(IncPoly).pa.count)

        '// v[1] = IncPoly->u * IncPoly->m_vertices[incidentFace] +  IncPoly->body->position;
        CALL matrixMultiplyVector(uInc, p(b(IncPoly).pa.start + incidentFace).vert, v(1))
        CALL vectorAddVector(v(1), b(IncPoly).position)
    END SUB

    SUB collisionPPHandle (p() AS tPOLY, body() AS tBODY, m AS tMANIFOLD, contacts() AS tVECTOR2d, A AS INTEGER, B AS INTEGER)
        m.contactCount = 0

        DIM faceA(100) AS INTEGER

        DIM penetrationA AS _FLOAT
        penetrationA = collisionPPFindAxisLeastPenetration(p(), body(), faceA(), A, B)
        IF penetrationA >= 0.0 THEN EXIT SUB

        DIM faceB(100) AS INTEGER

        DIM penetrationB AS _FLOAT
        penetrationB = collisionPPFindAxisLeastPenetration(p(), body(), faceB(), B, A)
        IF penetrationB >= 0.0 THEN EXIT SUB


        DIM referenceIndex AS INTEGER
        DIM flip AS INTEGER

        DIM RefPoly AS INTEGER
        DIM IncPoly AS INTEGER

        IF impulseGT(penetrationA, penetrationB) THEN
            RefPoly = A
            IncPoly = B
            referenceIndex = faceA(0)
            flip = 0
        ELSE
            RefPoly = B
            IncPoly = A
            referenceIndex = faceB(0)
            flip = 1
        END IF

        DIM incidentFace(2) AS tVECTOR2d

        CALL collisionPPFindIncidentFace(p(), body(), incidentFace(), RefPoly, IncPoly, referenceIndex)
        DIM v1 AS tVECTOR2d
        DIM v2 AS tVECTOR2d
        DIM v1t AS tVECTOR2d
        DIM v2t AS tVECTOR2d

        v1 = p(body(RefPoly).pa.start + referenceIndex).vert
        referenceIndex = arrayNextIndex(referenceIndex, body(RefPoly).pa.count)
        v2 = p(body(RefPoly).pa.start + referenceIndex).vert
        '// Transform vertices to world space
        '// v1 = RefPoly->u * v1 + RefPoly->body->position;
        '// v2 = RefPoly->u * v2 + RefPoly->body->position;
        CALL matrixMultiplyVector(body(RefPoly).shape.u, v1, v1t)
        CALL vectorAddVectorND(v1, v1t, body(RefPoly).position)
        CALL matrixMultiplyVector(body(RefPoly).shape.u, v2, v2t)
        CALL vectorAddVectorND(v2, v2t, body(RefPoly).position)

        '// Calculate reference face side normal in world space
        '// Vec2 sidePlaneNormal = (v2 - v1);
        '// sidePlaneNormal.Normalize( );
        DIM sidePlaneNormal AS tVECTOR2d
        CALL vectorSubVectorND(sidePlaneNormal, v2, v1)
        CALL vectorNormalize(sidePlaneNormal)

        '// Orthogonalize
        '// Vec2 refFaceNormal( sidePlaneNormal.y, -sidePlaneNormal.x );
        DIM refFaceNormal AS tVECTOR2d
        CALL vectorSet(refFaceNormal, sidePlaneNormal.y, -sidePlaneNormal.x)

        '// ax + by = c
        '// c is distance from origin
        '// real refC = Dot( refFaceNormal, v1 );
        '// real negSide = -Dot( sidePlaneNormal, v1 );
        '// real posSide = Dot( sidePlaneNormal, v2 );
        DIM refC AS _FLOAT: refC = vectorDot(refFaceNormal, v1)
        DIM negSide AS _FLOAT: negSide = -vectorDot(sidePlaneNormal, v1)
        DIM posSide AS _FLOAT: posSide = vectorDot(sidePlaneNormal, v2)


        '// Clip incident face to reference face side planes
        '// if(Clip( -sidePlaneNormal, negSide, incidentFace ) < 2)
        DIM negSidePlaneNormal AS tVECTOR2d
        CALL vectorNegND(negSidePlaneNormal, sidePlaneNormal)

        IF collisionPPClip(negSidePlaneNormal, negSide, incidentFace()) < 2 THEN EXIT SUB
        IF collisionPPClip(sidePlaneNormal, posSide, incidentFace()) < 2 THEN EXIT SUB

        CALL vectorSet(m.normal, refFaceNormal.x, refFaceNormal.y)
        IF flip THEN CALL vectorNeg(m.normal)

        '// Keep points behind reference face
        DIM cp AS INTEGER: cp = 0 '// clipped points behind reference face
        DIM separation AS _FLOAT
        separation = vectorDot(refFaceNormal, incidentFace(0)) - refC
        IF separation <= 0.0 THEN
            contacts(cp) = incidentFace(0)
            m.penetration = -separation
            cp = cp + 1
        ELSE
            m.penetration = 0
        END IF

        separation = vectorDot(refFaceNormal, incidentFace(1)) - refC
        IF separation <= 0.0 THEN
            contacts(cp) = incidentFace(1)
            m.penetration = m.penetration + -separation
            cp = cp + 1
            m.penetration = m.penetration / cp
        END IF
        m.contactCount = cp
    END SUB

    FUNCTION collisionPPFindAxisLeastPenetration (p() AS tPOLY, body() AS tBODY, faceIndex() AS INTEGER, A AS INTEGER, B AS INTEGER)
        DIM bestDistance AS _FLOAT: bestDistance = -9999999
        DIM bestIndex AS INTEGER: bestIndex = 0

        DIM n AS tVECTOR2d
        DIM nw AS tVECTOR2d
        DIM buT AS tMATRIX2d
        DIM s AS tVECTOR2d
        DIM nn AS tVECTOR2d
        DIM v AS tVECTOR2d
        DIM tv AS tVECTOR2d
        DIM d AS _FLOAT
        DIM i, k AS INTEGER

        FOR i = 0 TO body(A).pa.count
            k = body(A).pa.start + i

            '// Retrieve a face normal from A
            '// Vec2 n = A->m_normals[i];
            '// Vec2 nw = A->u * n;
            n = p(k).norm
            CALL matrixMultiplyVector(body(A).shape.u, n, nw)


            '// Transform face normal into B's model space
            '// Mat2 buT = B->u.Transpose( );
            '// n = buT * nw;
            CALL matrixTranspose(body(B).shape.u, buT)
            CALL matrixMultiplyVector(buT, nw, n)

            '// Retrieve support point from B along -n
            '// Vec2 s = B->GetSupport( -n );
            CALL vectorNegND(nn, n)
            CALL vectorGetSupport(p(), body(), B, nn, s)

            '// Retrieve vertex on face from A, transform into
            '// B's model space
            '// Vec2 v = A->m_vertices[i];
            '// v = A->u * v + A->body->position;
            '// v -= B->body->position;
            '// v = buT * v;

            v = p(k).vert
            CALL matrixMultiplyVector(body(A).shape.u, v, tv)
            CALL vectorAddVectorND(v, tv, body(A).position)

            CALL vectorSubVector(v, body(B).position)
            CALL matrixMultiplyVector(buT, v, tv)

            CALL vectorSubVector(s, tv)
            d = vectorDot(n, s)

            IF d > bestDistance THEN
                bestDistance = d
                bestIndex = i
            END IF

        NEXT i

        faceIndex(0) = bestIndex

        collisionPPFindAxisLeastPenetration = bestDistance
    END FUNCTION
$END IF
