'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'**********************************************************************************************
'   Shape Creation Ahead
'**********************************************************************************************
$IF SHAPECREATEINCLUDE = UNDEFINED THEN
    $LET SHAPECREATEINCLUDE = TRUE

    SUB shapeCreate (sh AS tSHAPE, ty AS INTEGER, radius AS _FLOAT)
        DIM u AS tMATRIX2d
        CALL matrixSetScalar(u, 1, 0, 0, 1)
        sh.ty = ty
        sh.radius = radius
        sh.u = u
        sh.scaleTextureX = 1.0
        sh.scaleTextureY = 1.0
    END SUB
$END IF

