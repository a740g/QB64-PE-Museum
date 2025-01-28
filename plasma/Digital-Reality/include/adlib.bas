'-----------------------------------------------------------------------------------------------------------------------
' OPL3 emulation for QB64-PE using Opal
' Copyright (c) 2025 Samuel Gomes
'-----------------------------------------------------------------------------------------------------------------------

$INCLUDEONCE

SUB Adlib_Handler
    DECLARE LIBRARY "adlib"
        SUB Adlib_Initialize (BYVAL sampleRate AS _UNSIGNED LONG)
        SUB Adlib_WriteRegister (BYVAL register AS _UNSIGNED INTEGER, BYVAL value AS _UNSIGNED _BYTE)
        SUB Adlib_GenerateSamples (buffer AS INTEGER, BYVAL frames AS _UNSIGNED LONG)
    END DECLARE

    CONST ADLIB_BUFFER_FRAMES = 2048
    CONST ADLIB_BUFFER_CHANNELS = 2
    CONST ADLIB_BUFFER_SAMPLES = ADLIB_BUFFER_FRAMES * ADLIB_BUFFER_CHANNELS

    STATIC buffer(0 TO 0) AS INTEGER
    STATIC bufferMEM AS _MEM
    STATIC AS LONG adlibTimer, sndRawHandle

    ' This setup part should only run once (if successful)
    IF bufferMEM.OFFSET = 0 THEN
        adlibTimer = _FREETIMER ' allocate a timer
        IF adlibTimer < 1 THEN EXIT SUB ' this should not happen. But we'll check anyway

        sndRawHandle = _SNDOPENRAW ' allocate a raw sound pipe
        IF sndRawHandle < 1 THEN
            TIMER(adlibTimer) FREE
            adlibTimer = 0
            EXIT SUB ' failed to open sound pipe
        END IF

        REDIM buffer(0 TO ADLIB_BUFFER_SAMPLES - 1) AS INTEGER ' stereo 16-bit
        bufferMEM = _MEM(buffer()) ' we need the _MEM for rapid array wipes

        IF bufferMEM.OFFSET = 0 THEN
            _SNDCLOSE sndRawHandle
            sndRawHandle = 0
            TIMER(adlibTimer) FREE
            adlibTimer = 0
        END IF

        Adlib_Initialize _SNDRATE ' initialize the emulator using the native device sample rate

        ON TIMER(adlibTimer, ADLIB_BUFFER_FRAMES / _SNDRATE) Adlib_Handler ' setup timer handler to tigger at correct intervals
        TIMER(adlibTimer) ON
    END IF

    ' Clear the render buffer
    _MEMFILL bufferMEM, bufferMEM.OFFSET, bufferMEM.SIZE, 0 AS _BYTE

    ' Generate samples to playbacks
    Adlib_GenerateSamples buffer(0), ADLIB_BUFFER_FRAMES

    DIM i AS LONG
    DO WHILE i < ADLIB_BUFFER_SAMPLES
        _SNDRAW buffer(i) / 32768!, buffer(i + 1) / 32768!, sndRawHandle
        i = i + ADLIB_BUFFER_CHANNELS
    LOOP
END SUB
