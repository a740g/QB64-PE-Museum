'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'**********************************************************************************************
'   Mostly Unused Stuff Ahead
'**********************************************************************************************
$IF MISCINCLUDE = UNDEFINED THEN
    $LET MISCINCLUDE = TRUE

    SUB polygonMakeCCW (obj AS tTRIANGLE)
        IF vectorLeft(obj.a, obj.b, obj.c) = 0 THEN
            SWAP obj.a, obj.c
        END IF
    END SUB

    FUNCTION polygonIsReflex (t AS tTRIANGLE)
        polygonIsReflex = vectorRight(t.a, t.b, t.c)
    END FUNCTION

    FUNCTION scalarMin (a AS _FLOAT, b AS _FLOAT)
        IF a < b THEN
            scalarMin = a
        ELSE
            scalarMin = b
        END IF
    END FUNCTION

    FUNCTION scalarMax (a AS _FLOAT, b AS _FLOAT)
        IF a > b THEN
            scalarMax = a
        ELSE
            scalarMax = b
        END IF
    END FUNCTION

    SUB lineIntersection (l1 AS tLINE2d, l2 AS tLINE2d, o AS tVECTOR2d)
        DIM a1, b1, c1, a2, b2, c2, det AS _FLOAT
        o.x = 0
        o.y = 0
        a1 = l1.b.y - l1.a.y
        b1 = l1.a.x - l1.b.x
        c1 = a1 * l1.a.x + b1 * l1.a.y
        a2 = l2.b.y - l2.a.y
        b2 = l2.a.x - l2.b.x
        c2 = a2 * l2.a.x + b2 * l2.a.y
        det = a1 * b2 - a2 * b1

        IF INT(det * cPRECISION) <> 0 THEN
            o.x = (b2 * c1 - b1 * c2) / det
            o.y = (a1 * c2 - a2 * c1) / det
        END IF
    END SUB

    FUNCTION lineSegmentsIntersect (l1 AS tLINE2d, l2 AS tLINE2d)
        DIM dx, dy, da, db, s, t AS _FLOAT
        dx = l1.b.x - l1.a.x
        dy = l1.b.y - l1.a.y
        da = l2.b.x - l2.a.x
        db = l2.b.y - l2.a.y
        IF da * dy - db * dx = 0 THEN
            lineSegmentsIntersect = 0
        ELSE
            s = (dx * (l2.a.y - l1.a.y) + dy * (l1.a.x - l2.a.x)) / (da * dy - db * dx)
            t = (da * (l1.a.y - l2.a.y) + db * (l2.a.x - l1.a.x)) / (db * dx - da * dy)
            lineSegmentsIntersect = (s >= 0 AND s <= 1 AND t >= 0 AND t <= 1)
        END IF
    END FUNCTION

    FUNCTION AABBOverlap (Ax AS _FLOAT, Ay AS _FLOAT, Aw AS _FLOAT, Ah AS _FLOAT, Bx AS _FLOAT, By AS _FLOAT, Bw AS _FLOAT, Bh AS _FLOAT)
        AABBOverlap = Ax < Bx + Bw AND Ax + Aw > Bx AND Ay < By + Bh AND Ay + Ah > By
    END FUNCTION

    FUNCTION AABBOverlapVector (A AS tVECTOR2d, Aw AS _FLOAT, Ah AS _FLOAT, B AS tVECTOR2d, Bw AS _FLOAT, Bh AS _FLOAT)
        AABBOverlapVector = AABBOverlap(A.x, A.y, Aw, Ah, B.x, B.y, Bw, Bh)
    END FUNCTION

    SUB polygonSetOrient (b AS tBODY, radians AS _FLOAT)
        matrixSetRadians b.shape.u, radians
    END SUB
$END IF



