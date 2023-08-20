$CONSOLE
DEFLNG A-Z
OPTION _EXPLICIT

'$INCLUDE:'adlib.bi'

Adlib_Handler

Adlib_WriteRegister 1, 0
Adlib_WriteRegister &H23, &H21
Adlib_WriteRegister &H43, 0
Adlib_WriteRegister &H63, &HFF
Adlib_WriteRegister &H83, &H05
Adlib_WriteRegister &H20, &H20
Adlib_WriteRegister &H40, &H3F
Adlib_WriteRegister &H60, &H44
Adlib_WriteRegister &H80, &H5
Adlib_WriteRegister &HA0, &H41
Adlib_WriteRegister &HB0, &H32

DO
    SLEEP
LOOP UNTIL _KEYHIT = 27

PRINT "key off"
Adlib_WriteRegister &HB0, &H12

END

SUB Adlib_Handler
    CONST ADLIB_BUFFER_FRAMES = 1024
    CONST ADLIB_BUFFER_CHANNELS = 2
    CONST ADLIB_BUFFER_SAMPLES = ADLIB_BUFFER_FRAMES * ADLIB_BUFFER_CHANNELS

    STATIC buffer(0 TO 0) AS INTEGER
    STATIC bufferMEM AS _MEM
    STATIC AS LONG adlibTimer, sndRawHandle

    ' This setup part should only run once (if successful)
    IF bufferMEM.OFFSET = 0 THEN
        adlibTimer = _FREETIMER ' allocate a timer
        IF adlibTimer < 1 THEN EXIT SUB

        sndRawHandle = _SNDOPENRAW
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

        ON TIMER(adlibTimer, ADLIB_BUFFER_FRAMES / _SNDRATE) Adlib_Handler ' setup timer handler to tigger every n seconds
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

