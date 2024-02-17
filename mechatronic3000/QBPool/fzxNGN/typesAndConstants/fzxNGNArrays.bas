'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../../fzxNGN/typesAndConstants/fzxNGNConst.bas'
'$include:'/../../fzxNGN/typesAndConstants/fzxNGNShared.bas'


$IF ARRAYSINCLUDE = UNDEFINED THEN
    $LET ARRAYSINCLUDE = TRUE
    DIM poly(cMAXNUMBEROFPOLYGONS) AS tPOLY
    DIM body(sNUMBEROFBODIES) AS tBODY
    DIM joints(cMAXNUMBEROFJOINTS) AS tJOINT
    DIM hits(cMAXNUMBEROFHITS) AS tHIT
    DIM veh(sNUMBEROFVEHICLES) AS tVEHICLE
    DIM camera AS tCAMERA
    DIM inputDevice AS tINPUTDEVICE
    DIM network AS tNETWORK
    DIM texture(100) AS LONG
$END IF

