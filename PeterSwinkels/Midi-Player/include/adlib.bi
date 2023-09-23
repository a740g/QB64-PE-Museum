'-----------------------------------------------------------------------------------------------------------------------
' OPL3 emulation for QB64-PE using Nuked OPL3
' Copyright (c) 2023 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$IF ADLIB_BI = UNDEFINED THEN
    $LET ADLIB_BI = TRUE

    CONST FALSE = 0, TRUE = NOT FALSE

    CONST ADLIB_SOUND_BUFFER_FRAMES = 1024
    CONST ADLIB_SOUND_BUFFER_CHANNELS = 2
    CONST ADLIB_SOUND_BUFFER_SAMPLE_SIZE = 2
    CONST ADLIB_SOUND_BUFFER_SAMPLES = ADLIB_SOUND_BUFFER_FRAMES * ADLIB_SOUND_BUFFER_CHANNELS
    CONST ADLIB_SOUND_BUFFER_BYTES = ADLIB_SOUND_BUFFER_SAMPLES * ADLIB_SOUND_BUFFER_SAMPLE_SIZE
    CONST ADLIB_SOUND_BUFFER_TIME_DEFAULT = 0.1!

    TYPE __AdlibStateType
        updateTimer AS LONG
        soundHandle AS LONG
        soundBuffer AS _MEM
    END TYPE

    DECLARE LIBRARY "adlib"
        SUB __Adlib_Initialize (BYVAL sampleRate AS _UNSIGNED LONG)
        SUB Adlib_WriteRegister (BYVAL register AS _UNSIGNED INTEGER, BYVAL value AS _UNSIGNED _BYTE)
        SUB __Adlib_GenerateSamples (BYVAL buffer AS _UNSIGNED _OFFSET, BYVAL frames AS _UNSIGNED LONG)
    END DECLARE

    DIM __AdlibState AS __AdlibStateType
$END IF
