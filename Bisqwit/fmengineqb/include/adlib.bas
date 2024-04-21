'-----------------------------------------------------------------------------------------------------------------------
' OPL3 emulation for QB64-PE using Nuked OPL3
' Copyright (c) 2023 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$IF ADLIB_BAS = UNDEFINED THEN
    $LET ADLIB_BAS = TRUE

    '$INCLUDE:'adlib.bi'

    '-------------------------------------------------------------------------------------------------------------------
    'OPTION _EXPLICIT

    'IF Adlib_Initialize THEN
    '    Adlib_WriteRegister 1, 0
    '    Adlib_WriteRegister &H23, &H21
    '    Adlib_WriteRegister &H43, 0
    '    Adlib_WriteRegister &H63, &HFF
    '    Adlib_WriteRegister &H83, &H05
    '    Adlib_WriteRegister &H20, &H20
    '    Adlib_WriteRegister &H40, &H3F
    '    Adlib_WriteRegister &H60, &H44
    '    Adlib_WriteRegister &H80, &H5
    '    Adlib_WriteRegister &HA0, &H41
    '    Adlib_WriteRegister &HB0, &H32

    '    DO
    '        _LIMIT 60
    '        LOCATE , 1: PRINT USING "Buffer time = ######.###"; Adlib_GetSoundBufferTime;
    '    LOOP UNTIL _KEYHIT = 27

    '    PRINT: PRINT "key off"
    '    Adlib_WriteRegister &HB0, &H12
    'ELSE
    '    PRINT "Failed to initialize Adlib emulator."
    'END IF

    'Adlib_Finalize

    'END
    '-------------------------------------------------------------------------------------------------------------------

    FUNCTION Adlib_Initialize%%
        SHARED __AdlibState AS __AdlibStateType

        IF __AdlibState.updateTimer > 0 THEN
            Adlib_Initialize = TRUE
            EXIT FUNCTION
        END IF

        __AdlibState.updateTimer = _FREETIMER
        IF __AdlibState.updateTimer < 1 THEN EXIT FUNCTION

        __AdlibState.soundHandle = _SNDOPENRAW
        IF __AdlibState.soundHandle < 1 THEN
            TIMER(__AdlibState.updateTimer) FREE
            __AdlibState.updateTimer = 0
            EXIT FUNCTION
        END IF

        __AdlibState.soundBuffer = _MEMNEW(ADLIB_SOUND_BUFFER_BYTES)

        IF __AdlibState.soundBuffer.SIZE = 0 THEN
            _SNDCLOSE __AdlibState.soundHandle
            __AdlibState.soundHandle = 0
            TIMER(__AdlibState.updateTimer) FREE
            __AdlibState.updateTimer = 0
            EXIT FUNCTION
        END IF

        __Adlib_Initialize _SNDRATE

        ON TIMER(__AdlibState.updateTimer, ADLIB_SOUND_BUFFER_FRAMES / _SNDRATE - 0.001!) __Adlib_TimerHandler
        TIMER(__AdlibState.updateTimer) ON

        Adlib_Initialize = TRUE
    END FUNCTION

    SUB Adlib_Finalize
        SHARED __AdlibState AS __AdlibStateType

        IF __AdlibState.updateTimer > 0 THEN
            TIMER(__AdlibState.updateTimer) OFF
            __Adlib_Initialize _SNDRATE

            _SNDRAWDONE __AdlibState.soundHandle
            _SNDCLOSE __AdlibState.soundHandle
            __AdlibState.soundHandle = 0

            _MEMFREE __AdlibState.soundBuffer

            TIMER(__AdlibState.updateTimer) FREE
            __AdlibState.updateTimer = 0
        END IF
    END SUB

    SUB Adlib_Pause
        SHARED __AdlibState AS __AdlibStateType

        IF __AdlibState.updateTimer > 0 THEN TIMER(__AdlibState.updateTimer) OFF
    END SUB

    SUB Adlib_Resume
        SHARED __AdlibState AS __AdlibStateType

        IF __AdlibState.updateTimer > 0 THEN TIMER(__AdlibState.updateTimer) ON
    END SUB

    FUNCTION Adlib_GetSoundBufferTime#
        SHARED __AdlibState AS __AdlibStateType

        Adlib_GetSoundBufferTime = _SNDRAWLEN(__AdlibState.soundHandle)
    END FUNCTION

    SUB __Adlib_TimerHandler
        SHARED __AdlibState AS __AdlibStateType

        IF _SNDRAWLEN(__AdlibState.soundHandle) > ADLIB_SOUND_BUFFER_TIME_DEFAULT THEN EXIT SUB

        _MEMFILL __AdlibState.soundBuffer, __AdlibState.soundBuffer.OFFSET, __AdlibState.soundBuffer.SIZE, 0 AS _BYTE

        __Adlib_GenerateSamples __AdlibState.soundBuffer.OFFSET, ADLIB_SOUND_BUFFER_FRAMES

        DIM i AS _UNSIGNED LONG
        DO WHILE i < ADLIB_SOUND_BUFFER_BYTES
            _SNDRAW _MEMGET(__AdlibState.soundBuffer, __AdlibState.soundBuffer.OFFSET + i, INTEGER) / 32768!, _MEMGET(__AdlibState.soundBuffer, __AdlibState.soundBuffer.OFFSET + i + ADLIB_SOUND_BUFFER_SAMPLE_SIZE, INTEGER) / 32768!, __AdlibState.soundHandle
            i = i + ADLIB_SOUND_BUFFER_CHANNELS * ADLIB_SOUND_BUFFER_SAMPLE_SIZE
        LOOP
    END SUB
$END IF
