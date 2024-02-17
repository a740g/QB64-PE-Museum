
'$include:'/../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'$include:'/../Pool/poolTypesConstArrays.bas'
'$include:'/../fzxNGN/physics/collisionQuery.bas'
'$include:'/../fzxNGN/body/bodyTools.bas'
'**********************************************************************************************
'   Pool related Methods
'**********************************************************************************************

$IF POOLMETHODSINCLUDE = UNDEFINED THEN
    $LET POOLMETHODSINCLUDE = TRUE


    SUB handlePocketSensors (body() AS tBODY, hits() AS tHIT, mute AS INTEGER)
        DIM AS LONG index, ballId, index2
        FOR index = 0 TO 5 ' check if ball has been pocketed
            ballId = isBodyTouching(hits(), poolSensors(index).objId)
            IF ballId > 0 THEN
                body(ballId).position = pool(17).rackposition ' Move to ball return
                FOR index2 = 1 TO 16
                    IF pool(index2).objId = ballId THEN
                        IF mute = 0 THEN pool(index2).status = 1
                        EXIT FOR
                    END IF
                NEXT
                CALL bodyStop(body(ballId))
            END IF
        NEXT
    END SUB

    SUB checkForScratch (body() AS tBODY, cueBallId AS INTEGER, mute AS INTEGER)
        IF pool(cueBallId).status = 1 THEN
            IF allBallsAtRest(body()) THEN
                body(pool(cueBallId).objId).position = pool(16).rackposition ' Move to break position
                CALL bodyStop(body(cueBallId))
                IF mute = 0 THEN pool(cueBallId).status = 0
            END IF
        END IF
    END SUB

    SUB reRackBalls (body() AS tBODY)
        DIM AS INTEGER index
        FOR index = 1 TO 16
            body(pool(index).objId).position = pool(index).rackposition
            CALL bodyStop(body(pool(index).objId))
            pool(index).status = 0
        NEXT
    END SUB


    FUNCTION allBallsAtRest (body() AS tBODY)
        DIM AS INTEGER index
        allBallsAtRest = 1
        FOR index = 1 TO 16
            IF pool(index).status = 0 THEN ' dont worry pocketed balls
                IF bodyAtRest(body(pool(index).objId)) = 0 THEN allBallsAtRest = 0: EXIT FUNCTION
            END IF
        NEXT
    END FUNCTION
$END IF

