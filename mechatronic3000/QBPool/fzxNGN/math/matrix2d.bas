'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'

'**********************************************************************************************
'   Matrix Stuff Ahead
'**********************************************************************************************
$IF MATRIX2DINCLUDE = UNDEFINED THEN
    $LET MATRIX2DINCLUDE = TRUE

    SUB matrixSetRadians (m AS tMATRIX2d, radians AS _FLOAT)
        DIM c AS _FLOAT
        DIM s AS _FLOAT
        c = COS(radians)
        s = SIN(radians)
        m.m00 = c
        m.m01 = -s
        m.m10 = s
        m.m11 = c
    END SUB

    SUB matrixSetScalar (m AS tMATRIX2d, a AS _FLOAT, b AS _FLOAT, c AS _FLOAT, d AS _FLOAT)
        m.m00 = a
        m.m01 = b
        m.m10 = c
        m.m11 = d
    END SUB

    SUB matrixAbs (m AS tMATRIX2d, o AS tMATRIX2d)
        o.m00 = ABS(m.m00)
        o.m01 = ABS(m.m01)
        o.m10 = ABS(m.m10)
        o.m11 = ABS(m.m11)
    END SUB

    SUB matrixGetAxisX (m AS tMATRIX2d, o AS tVECTOR2d)
        o.x = m.m00
        o.y = m.m10
    END SUB

    SUB matrixGetAxisY (m AS tMATRIX2d, o AS tVECTOR2d)
        o.x = m.m01
        o.y = m.m11
    END SUB

    SUB matrixTransposeI (m AS tMATRIX2d)
        SWAP m.m01, m.m10
    END SUB

    SUB matrixTranspose (m AS tMATRIX2d, o AS tMATRIX2d)
        DIM tm AS tMATRIX2d
        tm.m00 = m.m00
        tm.m01 = m.m10
        tm.m10 = m.m01
        tm.m11 = m.m11
        o = tm
    END SUB

    SUB matrixInvert (m AS tMATRIX2d, o AS tMATRIX2d)
        DIM a, b, c, d, det AS _FLOAT
        DIM tm AS tMATRIX2d

        a = m.m00: b = m.m01: c = m.m10: d = m.m11
        det = a * d - b * c
        IF det = 0 THEN EXIT SUB

        det = 1 / det
        tm.m00 = det * d: tm.m01 = -det * b
        tm.m10 = -det * c: tm.m11 = det * a
        o = tm
    END SUB

    SUB matrixMultiplyVector (m AS tMATRIX2d, v AS tVECTOR2d, o AS tVECTOR2d)
        DIM t AS tVECTOR2d
        t.x = m.m00 * v.x + m.m01 * v.y
        t.y = m.m10 * v.x + m.m11 * v.y
        o = t
    END SUB

    SUB matrixAddMatrix (m AS tMATRIX2d, x AS tMATRIX2d, o AS tMATRIX2d)
        o.m00 = m.m00 + x.m00
        o.m01 = m.m01 + x.m01
        o.m10 = m.m10 + x.m10
        o.m11 = m.m11 + x.m11
    END SUB

    SUB matrixMultiplyMatrix (m AS tMATRIX2d, x AS tMATRIX2d, o AS tMATRIX2d)
        o.m00 = m.m00 * x.m00 + m.m01 * x.m10
        o.m01 = m.m00 * x.m01 + m.m01 * x.m11
        o.m10 = m.m10 * x.m00 + m.m11 * x.m10
        o.m11 = m.m10 * x.m01 + m.m11 * x.m11
    END SUB
$END IF
