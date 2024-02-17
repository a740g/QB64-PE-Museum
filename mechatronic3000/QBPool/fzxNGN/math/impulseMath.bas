'**********************************************************************************************
'   Impulse Specific Math Ahead
'**********************************************************************************************
$IF IMPULSEMHELPERINCLUDE = UNDEFINED THEN
    $LET IMPULSEMHELPERINCLUDE = TRUE


    FUNCTION impulseEqual (a AS _FLOAT, b AS _FLOAT)
        impulseEqual = ABS(a - b) <= cEPSILON
    END FUNCTION

    FUNCTION impulseClamp (min AS _FLOAT, max AS _FLOAT, a AS _FLOAT)
        IF a < min THEN
            impulseClamp = min
        ELSE IF a > max THEN
                impulseClamp = max
            ELSE
                impulseClamp = a
            END IF
        END IF
    END FUNCTION

    FUNCTION impulseRound (a AS _FLOAT)
        impulseRound = INT(a + 0.5)
    END FUNCTION

    FUNCTION impulseRandom_float (min AS _FLOAT, max AS _FLOAT)
        impulseRandom_float = ((max - min) * RND + min)
    END FUNCTION

    FUNCTION impulseRandomInteger (min AS INTEGER, max AS INTEGER)
        impulseRandomInteger = INT((max - min) * RND + min)
    END FUNCTION

    FUNCTION impulseGT (a AS _FLOAT, b AS _FLOAT)
        impulseGT = (a >= b * cBIAS_RELATIVE + a * cBIAS_ABSOLUTE)
    END FUNCTION
$END IF
