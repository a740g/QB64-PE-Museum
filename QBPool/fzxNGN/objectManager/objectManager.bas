'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'**********************************************************************************************
'   ObjectManager Stuff ahead
'**********************************************************************************************
$IF OBJECTMANAGERINCLUDE = UNDEFINED THEN
    $LET OBJECTMANAGERINCLUDE = TRUE

    FUNCTION objectManagerAdd (body() AS tBODY)
        objectManagerAdd = objectManager.objectCount
        objectManager.objectCount = objectManager.objectCount + 1
        IF objectManager.objectCount > sNUMBEROFBODIES THEN
            sNUMBEROFBODIES = sNUMBEROFBODIES * 1.5
            REDIM _PRESERVE body(sNUMBEROFBODIES) AS tBODY
        END IF
    END FUNCTION

    FUNCTION objectManagerID (body() AS tBODY, objName AS STRING)
        DIM i AS INTEGER
        DIM uID AS _INTEGER64
        uID = computeHash(RTRIM$(LTRIM$(objName)))
        objectManagerID = -1

        FOR i = 0 TO objectManager.objectCount
            IF body(i).objectHash = uID THEN
                objectManagerID = i
                EXIT FUNCTION
            END IF
        NEXT
    END FUNCTION

    FUNCTION objectContainsString (body() AS tBODY, start AS INTEGER, s AS STRING)
        objectContainsString = -1
        DIM AS INTEGER j
        FOR j = start TO objectManager.objectCount
            IF INSTR(body(j).objectName, s) THEN
                objectContainsString = j
                EXIT FUNCTION
            END IF
        NEXT
    END FUNCTION

    '**********************************************************************************************
    '   String Hash
    '**********************************************************************************************

    FUNCTION computeHash&& (s AS STRING)
        DIM p, i AS INTEGER: p = 31
        DIM m AS _INTEGER64: m = 1E9 + 9
        DIM AS _INTEGER64 hash_value, p_pow
        p_pow = 1
        FOR i = 1 TO LEN(s)
            hash_value = (hash_value + (ASC(MID$(s, i)) - 97 + 1) * p_pow)
            p_pow = (p_pow * p) MOD m
        NEXT
        computeHash = hash_value
    END FUNCTION

$END IF

