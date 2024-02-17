'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/math/vector.bas'
'$include:'/../../fzxNGN/math/matrix2d.bas'
'**********************************************************************************************
'   Camera Math Ahead
'**********************************************************************************************
$IF CAMERAINCLUDE = UNDEFINED THEN
    $LET CAMERAINCLUDE = TRUE


    SUB worldToCamera (body() AS tBODY, camera AS tCAMERA, index AS INTEGER, vert AS tVECTOR2d)
        DIM tv AS tVECTOR2d
        CALL vectorSet(tv, _WIDTH / 2 * (1 / camera.zoom), _HEIGHT / 2 * (1 / camera.zoom)) ' Camera Center
        CALL matrixMultiplyVector(body(index).shape.u, vert, vert) ' Rotate body
        CALL vectorAddVector(vert, body(index).position) ' Add Position
        CALL vectorSubVector(vert, camera.position) 'Sub Camera Position
        CALL vectorAddVector(vert, tv) ' Add to camera Center
        CALL vectorMultiplyScalar(vert, camera.zoom) 'Zoom everything
    END SUB

    SUB worldToCameraNR (body() AS tBODY, camera AS tCAMERA, index AS INTEGER, vert AS tVECTOR2d)
        DIM tv AS tVECTOR2d
        CALL vectorSet(tv, _WIDTH / 2 * (1 / camera.zoom), _HEIGHT / 2 * (1 / camera.zoom)) ' Camera Center
        CALL vectorSetVector(vert, body(index).position) ' Add Position
        CALL vectorSubVector(vert, camera.position) 'Sub Camera Position
        CALL vectorAddVector(vert, tv) ' Add to camera Center
        CALL vectorMultiplyScalar(vert, camera.zoom) 'Zoom everything
    END SUB
$END IF

