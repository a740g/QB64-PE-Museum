'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'**********************************************************************************************
'   Collision Helper Tools
'**********************************************************************************************
$IF COLLISIONQUERYINCLUDE = UNDEFINED THEN
    $LET COLLISIONQUERYINCLUDE = TRUE

    FUNCTION isBodyTouchingBody (hits() AS tHIT, A AS INTEGER, B AS INTEGER)
        DIM hitcount AS INTEGER: hitcount = 1
        isBodyTouchingBody = 0
        DO WHILE hits(hitcount).A <> hits(hitcount).B
            IF hits(hitcount).A = A AND hits(hitcount).B = B THEN
                isBodyTouchingBody = hitcount
                EXIT FUNCTION
            END IF
            hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
        LOOP
    END FUNCTION

    FUNCTION isBodyTouchingStatic (body() AS tBODY, hits() AS tHIT, A AS INTEGER)
        DIM hitcount AS INTEGER: hitcount = 1
        isBodyTouchingStatic = 0
        DO WHILE hits(hitcount).A <> hits(hitcount).B
            IF hits(hitcount).A = A THEN
                IF body(hits(hitcount).B).mass = 0 THEN
                    isBodyTouchingStatic = hitcount
                    EXIT FUNCTION
                END IF
            ELSE
                IF hits(hitcount).B = A THEN
                    IF body(hits(hitcount).A).mass = 0 THEN
                        isBodyTouchingStatic = hitcount
                        EXIT FUNCTION
                    END IF
                END IF
            END IF
            hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
        LOOP
    END FUNCTION

    FUNCTION isBodyTouching (hits() AS tHIT, A AS INTEGER)
        DIM hitcount AS INTEGER: hitcount = 1
        isBodyTouching = 0
        DO WHILE hits(hitcount).A <> hits(hitcount).B
            IF hits(hitcount).A = A THEN
                isBodyTouching = hits(hitcount).B
                EXIT FUNCTION
            END IF
            IF hits(hitcount).B = A THEN
                isBodyTouching = hits(hitcount).A
                EXIT FUNCTION
            END IF

            hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
        LOOP
    END FUNCTION

    FUNCTION highestCollisionVelocity (hits() AS tHIT, A AS INTEGER) ' this function is a bit dubious and may not do as you think
        DIM hitcount AS INTEGER: hitcount = 1
        DIM hiCv AS _FLOAT: hiCv = 0
        highestCollisionVelocity = 0
        DO WHILE hits(hitcount).A <> hits(hitcount).B
            IF hits(hitcount).A = A AND ABS(hits(hitcount).cv) > hiCv AND hits(hitcount).cv < 0 THEN
                hiCv = ABS(hits(hitcount).cv)
            END IF
            hitcount = hitcount + 1: IF hitcount > UBOUND(hits) THEN REDIM _PRESERVE hits(hitcount * 1.5) AS tHIT
        LOOP
        highestCollisionVelocity = hiCv
    END FUNCTION
$END IF
