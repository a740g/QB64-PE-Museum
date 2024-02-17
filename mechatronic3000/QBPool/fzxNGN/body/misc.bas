

$IF BODYMISCINCLUDE = UNDEFINED THEN
    $LET BODYMISCINCLUDE = TRUE

    FUNCTION arrayNextIndex (i AS INTEGER, count AS INTEGER)
        arrayNextIndex = ((i + 1) MOD (count + 1))
    END FUNCTION
$END IF
