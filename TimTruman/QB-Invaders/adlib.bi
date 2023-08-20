'-----------------------------------------------------------------------------------------------------------------------
' OPL3 emulation for QB64-PE using Nuked OPL3
' Copyright (c) 2023 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$IF ADLIB_BI = UNDEFINED THEN
    $LET ADLIB_BI = TRUE

    DECLARE LIBRARY "adlib"
        SUB Adlib_Initialize (BYVAL sampleRate AS _UNSIGNED LONG)
        SUB Adlib_WriteRegister (BYVAL register AS _UNSIGNED INTEGER, BYVAL value AS _UNSIGNED _BYTE)
        SUB Adlib_GenerateSamples (buffer AS INTEGER, BYVAL frames AS _UNSIGNED LONG)
    END DECLARE

$END IF
