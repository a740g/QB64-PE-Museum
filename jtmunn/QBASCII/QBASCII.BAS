'*****************************************************************************
' Name:         QBASCII.BAS
' Author:       Jeremy Munn
' Date:         07/28/2012
' Description:  ASCII drawing program with save & load features.
'*****************************************************************************

DEFINT A-Z

'*****************************************************************************
' CONSTANTS
'*****************************************************************************
' Common constants
CONST FALSE = 0, TRUE = NOT FALSE

' Keys constants
CONST KEYS.TAB = 9
CONST KEYS.RETURN = 13
CONST KEYS.ESCAPE = 27
CONST KEYS.SPACE = 32
CONST KEYS.UP = 72
CONST KEYS.LEFT = 75
CONST KEYS.RIGHT = 77
CONST KEYS.DOWN = 80
CONST KEYS.PAGEUP = 73
CONST KEYS.PAGEDOWN = 81
CONST KEYS.BACKSPACE = 8
CONST KEYS.INSERT = 82
CONST KEYS.DELETE = 83
CONST KEYS.HOME = 71
CONST KEYS.END = 79

CONST KEYS.CTRL.N = 14
CONST KEYS.CTRL.O = 15
CONST KEYS.CTRL.S = 19
CONST KEYS.CTRL.Q = 17

CONST KEYS.CTRL.LEFT = 115
CONST KEYS.CTRL.RIGHT = 116
CONST KEYS.CTRL.PAGEUP = 132
CONST KEYS.CTRL.PAGEDOWN = 118
CONST KEYS.CTRL.HOME = 119
CONST KEYS.CTRL.END = 117

CONST KEYS.F1 = 59

' Style constants
CONST STYLE.FILL.NONE = 1
CONST STYLE.FILL.SOLID = 2
CONST STYLE.BORDER.SINGLE = 4
CONST STYLE.BORDER.DOUBLE = 8
CONST STYLE.BORDER.SOLID = 16
CONST STYLE.BORDER.MIXED = 32
CONST STYLE.BORDER.MIXEDINV = 64

' Program-specific constants
CONST SCREEN.WIDTH = 80
CONST SCREEN.HEIGHT = 25

'*****************************************************************************
' USER-DEFINED TYPES
'*****************************************************************************
TYPE AsciiType
    code AS INTEGER
    row AS INTEGER
    col AS INTEGER
    fg AS INTEGER
    bg AS INTEGER
END TYPE

'*****************************************************************************
' SUB / FUNCTION DECLARATIONS
'*****************************************************************************
DECLARE SUB Mouse (funk)

DECLARE SUB AddAsciiToBuffer (pAscii AS AsciiType)
DECLARE SUB Center (pRow, pText$)
DECLARE SUB ClearAsciiBuffer (pBufferId, pLength)
DECLARE SUB DrawAscii (pAscii AS AsciiType)
DECLARE SUB DrawWindow (pR1, pC1, pR2, pC2, pStyle, pTitle$)
DECLARE SUB GetAsciiFromBuffer (pAscii AS AsciiType)
DECLARE SUB ShowAsciiSelection (pAscii AS AsciiType)
DECLARE SUB Init ()
DECLARE SUB LoadFile ()
DECLARE SUB SaveFile ()
DECLARE SUB ShiftAsciiColumn (pRow, pCol, pLength)
DECLARE SUB DrawRow (pRow)
DECLARE SUB DrawStatusBar (pAscii AS AsciiType, showStatus)
DECLARE SUB ShowUsage ()


DECLARE FUNCTION GetRowFromBuffer (pBufferId)
DECLARE FUNCTION GetColFromBuffer (pBufferId)
DECLARE FUNCTION GetRowColBuffer (pRow, pCol)
DECLARE FUNCTION ConfirmQuit ()
DECLARE FUNCTION ConfirmNewFile ()
DECLARE FUNCTION QBInput$ (pLength, pDefault$)
DECLARE FUNCTION Trim$ (pString$)

'*****************************************************************************
' GLOBAL VARIABLES
'*****************************************************************************
DIM SHARED gBlankAscii AS AsciiType
DIM SHARED gAsciiBuffer(SCREEN.WIDTH * SCREEN.HEIGHT) AS AsciiType
DIM SHARED gFileName$
DIM SHARED mouseV, mouseH, mouseB

'*****************************************************************************
' INITIALIZE
'*****************************************************************************
SCREEN 0: COLOR 7, 0: CLS
Mouse 0

DIM ascii AS AsciiType, oldAscii AS AsciiType

gFileName$ = "UNTITLED.QBA"
gBlankAscii.code = 0
gBlankAscii.fg = 7
gBlankAscii.bg = 0

ascii.code = 1
ascii.row = 12
ascii.col = 40
ascii.fg = 7
ascii.bg = 0

oldAscii = ascii
oldMouseV = mouseV
oldMouseH = mouseH
oldMouseB = mouseB
ClearAsciiBuffer -1, -1
isInsertMode = FALSE
isDeleteMode = FALSE
isQuit = FALSE

'*****************************************************************************
' MAIN
'*****************************************************************************
DrawAscii oldAscii
DrawAscii ascii

oldAscii = ascii
GetAsciiFromBuffer oldAscii

needsRender = TRUE

DO
    keyPress$ = INKEY$
    Mouse 3
 
    IF oldMouseV <> mouseV OR oldMouseH <> mouseH OR oldMouseB <> mouseB THEN
        needsRender = TRUE
     
        IF mouseV <> ascii.row THEN
            IF mouseV > 0 AND mouseV <= SCREEN.HEIGHT THEN
                ascii.row = mouseV
            END IF
        END IF

        IF mouseH <> ascii.col THEN
            IF mouseH > 0 AND mouseH <= SCREEN.WIDTH THEN
                ascii.col = mouseH
            END IF
        END IF

        IF mouseB = 1 AND NOT isInsertMode THEN
            AddAsciiToBuffer ascii
        END IF

        IF mouseB = 2 AND NOT isInsertMode THEN
            isDeleteMode = TRUE
            bufferId = GetRowColBuffer(ascii.row, ascii.col)
            ClearAsciiBuffer bufferId, 1
        ELSE
            isDeleteMode = FALSE
        END IF
    END IF

    IF keyPress$ > "" THEN
        needsRender = TRUE

        SELECT CASE ASC(keyPress$)
         
            CASE KEYS.TAB
                IF NOT isInsertMode THEN
                    ShowAsciiSelection ascii
                END IF
         
            CASE KEYS.ESCAPE
                pShowStatus = NOT pShowStatus

                IF NOT pShowStatus THEN
                    DrawStatusBar ascii, FALSE
                END IF
         
            CASE KEYS.SPACE
                IF NOT isInsertMode THEN
                    AddAsciiToBuffer ascii
                ELSE
                    IF ascii.col < SCREEN.WIDTH THEN
                        bufferId = GetRowColBuffer(ascii.row, SCREEN.WIDTH)
                     
                        'Only shift if the last column is blank
                        IF gAsciiBuffer(bufferId).code = gBlankAscii.code THEN
                            ShiftAsciiColumn ascii.row, ascii.col, 1
                            ascii.col = ascii.col + 1
                        END IF
                    END IF
                END IF
         
            CASE KEYS.BACKSPACE
                IF isInsertMode THEN
                    IF ascii.col > 1 THEN
                        ShiftAsciiColumn ascii.row, ascii.col, -1
                        ascii.col = ascii.col - 1
                    END IF
                END IF
         
            CASE IS > 32
                IF NOT isInsertMode THEN
                    ascii.code = ASC(keyPress$)
                END IF
         
            CASE ELSE
                SELECT CASE ASC(RIGHT$(keyPress$, 1))
                 
                    CASE KEYS.UP
                        ascii.row = ascii.row - 1
                        IF ascii.row < 1 THEN ascii.row = SCREEN.HEIGHT
                 
                    CASE KEYS.DOWN
                        ascii.row = ascii.row + 1
                        IF ascii.row > SCREEN.HEIGHT THEN ascii.row = 1
                 
                    CASE KEYS.RIGHT
                        ascii.col = ascii.col + 1
                        IF ascii.col > SCREEN.WIDTH THEN ascii.col = 1
                 
                    CASE KEYS.LEFT
                        ascii.col = ascii.col - 1
                        IF ascii.col < 1 THEN ascii.col = SCREEN.WIDTH

                    CASE KEYS.CTRL.LEFT
                        'starting at current position -1, find the previous non-space char
                        'if already at first non-space char, set row, col to first
                        bufferId = GetRowColBuffer(ascii.row, ascii.col)
                        FOR i = bufferId - 1 TO 1 STEP -1
                            IF gAsciiBuffer(i).code > gBlankAscii.code THEN
                                EXIT FOR
                            END IF
                        NEXT i

                        IF i < 1 THEN i = 1

                        ascii.row = GetRowFromBuffer(i)
                        ascii.col = GetColFromBuffer(i)

                    CASE KEYS.CTRL.RIGHT
                        'starting at current position +1, find the next non-space char
                        'if already at last non-space char, set row, col to last
                        bufferId = GetRowColBuffer(ascii.row, ascii.col)
                        FOR i = bufferId + 1 TO UBOUND(gAsciiBuffer)
                            IF gAsciiBuffer(i).code > gBlankAscii.code THEN
                                EXIT FOR
                            END IF
                        NEXT i

                        IF i > UBOUND(gAsciiBuffer) THEN i = UBOUND(gAsciiBuffer)

                        ascii.row = GetRowFromBuffer(i)
                        ascii.col = GetColFromBuffer(i)
                 
                    CASE KEYS.HOME
                        'left-to-right, find first blank char
                        'if ascii.col already at first blank char, set col to 1
                        'if blank char not found, set col to 1
                        FOR c = 1 TO SCREEN.WIDTH
                            bufferId = GetRowColBuffer(ascii.row, c)
                            IF gAsciiBuffer(bufferId).code <> gBlankAscii.code THEN
                                IF ascii.col = c THEN c = 1
                                EXIT FOR
                            END IF
                        NEXT c

                        IF c > SCREEN.WIDTH THEN c = 1

                        ascii.col = c

                    CASE KEYS.END
                        'right-to-left, find first blank char
                        'if ascii.col already at last blank char, set col to last col
                        'if blank char not found, set col to last col
                        FOR c = SCREEN.WIDTH TO 1 STEP -1
                            bufferId = GetRowColBuffer(ascii.row, c)
                            IF gAsciiBuffer(bufferId).code <> gBlankAscii.code THEN
                                IF ascii.col = c THEN c = SCREEN.WIDTH
                                EXIT FOR
                            END IF
                        NEXT c

                        IF c < 1 THEN c = SCREEN.WIDTH

                        ascii.col = c

                    CASE KEYS.CTRL.HOME
                        'start from buffer(1) loop until non-space char
                        'if already at first non-space char, set row, col to 1
                        FOR i = 1 TO UBOUND(gAsciiBuffer)
                            IF gAsciiBuffer(i).code <> 32 THEN
                                bufferRow = GetRowFromBuffer(i)
                                bufferCol = GetColFromBuffer(i)
                                                         
                                IF ascii.row = bufferRow AND ascii.col = bufferCol THEN
                                    i = 1
                                END IF

                                EXIT FOR
                            END IF
                        NEXT i

                        IF i > UBOUND(gAsciiBuffer) THEN i = 1
                     
                        ascii.row = GetRowFromBuffer(i)
                        ascii.col = GetColFromBuffer(i)

                    CASE KEYS.CTRL.END
                        'start from UBOUND(buffer) loop down until non-space char
                        'if already at last non-space char, set row, col to last
                        FOR i = UBOUND(gAsciiBuffer) TO 1 STEP -1
                            IF gAsciiBuffer(i).code <> 32 THEN
                                bufferRow = GetRowFromBuffer(i)
                                bufferCol = GetColFromBuffer(i)

                                IF ascii.row = bufferRow AND ascii.col = bufferCol THEN
                                    i = UBOUND(gAsciiBuffer)
                                END IF

                                EXIT FOR
                            END IF
                        NEXT i

                        IF i < 1 THEN i = UBOUND(gAsciiBuffer)

                        ascii.row = GetRowFromBuffer(i)
                        ascii.col = GetColFromBuffer(i)

                    CASE KEYS.PAGEUP
                        ascii.fg = ascii.fg + 1
                        IF ascii.fg > 15 THEN ascii.fg = 0
                 
                    CASE KEYS.PAGEDOWN
                        ascii.fg = ascii.fg - 1
                        IF ascii.fg < 0 THEN ascii.fg = 15
                 
                    CASE KEYS.CTRL.PAGEUP
                        ascii.bg = ascii.bg + 1
                        IF ascii.bg > 7 THEN ascii.bg = 0
                 
                    CASE KEYS.CTRL.PAGEDOWN
                        ascii.bg = ascii.bg - 1
                        IF ascii.bg < 0 THEN ascii.bg = 7
                 
                    CASE KEYS.CTRL.N
                        IF ConfirmNewFile THEN RUN

                    CASE KEYS.CTRL.O
                        LoadFile
                 
                    CASE KEYS.CTRL.S
                        SaveFile

                    CASE KEYS.CTRL.Q
                        isQuit = ConfirmQuit
                 
                    CASE KEYS.INSERT
                        isInsertMode = NOT isInsertMode
                        DrawAscii oldAscii

                    CASE KEYS.DELETE
                        IF NOT isInsertMode THEN
                            bufferId = GetRowColBuffer(ascii.row, ascii.col)
                            ClearAsciiBuffer bufferId, 1
                        ELSE
                            ShiftAsciiColumn ascii.row, ascii.col + 1, -1
                        END IF

                        'Only shift if the last column is blank
                        'IF gAsciiBuffer(bufferId).code = gBlankAscii.code THEN
                        '  ShiftAsciiColumn ascii.row, ascii.col, 1
                        '  ascii.col = ascii.col + 1
                        'END IF

                    CASE KEYS.F1
                        ShowUsage

                END SELECT
        END SELECT
    END IF 'IF keyPress$ > ""

    IF needsRender THEN
        IF NOT isInsertMode THEN
            DrawAscii oldAscii
            DrawAscii ascii
        END IF

        IF pShowStatus THEN
            DrawStatusBar ascii, TRUE
         
            'need this extra DrawAscii call because ascii would get overwritten
            ' after DrawStatusBar
            'DrawAscii ascii
        END IF

        needsRender = FALSE
    END IF

    IF isInsertMode THEN
        LOCATE ascii.row, ascii.col, 1, 29, 31
    ELSEIF isDeleteMode THEN
        LOCATE ascii.row, ascii.col, 1, 1, 4
    ELSE
        LOCATE , , 0 ' Turn the cursor off
    END IF

    oldAscii = ascii
    GetAsciiFromBuffer oldAscii

    oldMouseV = mouseV
    oldMouseH = mouseH
    oldMouseB = mouseB
LOOP UNTIL isQuit

'*****************************************************************************
' CLEANUP
'*****************************************************************************
COLOR 7, 0
LOCATE , , 0 ' Turn the cursor off
SYSTEM 0

SUB AddAsciiToBuffer (pAscii AS AsciiType)
    bufferId = GetRowColBuffer(pAscii.row, pAscii.col)

    gAsciiBuffer(bufferId).code = pAscii.code
    gAsciiBuffer(bufferId).row = pAscii.row
    gAsciiBuffer(bufferId).col = pAscii.col
    gAsciiBuffer(bufferId).fg = pAscii.fg
    gAsciiBuffer(bufferId).bg = pAscii.bg
END SUB

SUB Center (pRow, pText$)
    iLength = LEN(pText$)

    IF iLength < 1 OR iLength > 80 THEN iLength = 80
    IF pRow < 1 OR pRow > 25 THEN pRow = CSRLIN

    iRelPos = (SCREEN.WIDTH / 2) - (iLength / 2)

    LOCATE pRow, iRelPos
    PRINT pText$;
END SUB

SUB ClearAsciiBuffer (pBufferId, pLength)
    bufferStart = 1
    IF pBufferId > 0 THEN bufferStart = pBufferId
 
    bufferLength = UBOUND(gAsciiBuffer)
    IF pLength > 0 THEN bufferLength = pLength

    FOR i = bufferStart TO (bufferStart + bufferLength) - 1
        gBlankAscii.row = GetRowFromBuffer(i)
        gBlankAscii.col = GetColFromBuffer(i)
    
        gAsciiBuffer(i) = gBlankAscii
        DrawAscii gAsciiBuffer(i)
    NEXT i
END SUB

FUNCTION ConfirmNewFile
    newFile = FALSE
    PCOPY 0, 1
    COLOR 15, 4
    LOCATE , , 0 ' Turn the cursor off
    DrawWindow 10, 14, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, "Start New File"
    Center 12, "Are you sure you want to start a new file? (Y/N)"
    ans$ = INPUT$(1)
    IF UCASE$(ans$) = "Y" THEN newFile = TRUE
    PCOPY 1, 0
    ConfirmNewFile = newFile
END FUNCTION

FUNCTION ConfirmQuit
    isQuit = FALSE
    PCOPY 0, 1
    COLOR 15, 4
    LOCATE , , 0 ' Turn the cursor off
    DrawWindow 10, 20, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, "Quit QBASCII"
    Center 12, "Are you sure you want to quit? (Y/N)"
    ans$ = INPUT$(1)
    IF UCASE$(ans$) = "Y" THEN isQuit = TRUE
    PCOPY 1, 0
    ConfirmQuit = isQuit
END FUNCTION

SUB DrawAscii (pAscii AS AsciiType)
    COLOR pAscii.fg, pAscii.bg
    LOCATE pAscii.row, pAscii.col, 0 'Make sure the cursor is off
    PRINT CHR$(pAscii.code);
END SUB

SUB DrawRow (pRow)
    bufferId = GetRowColBuffer(pRow, 1)
    DIM rowAscii AS AsciiType
    FOR i = 1 TO SCREEN.WIDTH
        rowAscii.row = pRow
        rowAscii.col = i

        GetAsciiFromBuffer rowAscii
        DrawAscii rowAscii
    NEXT i
END SUB

SUB DrawStatusBar (pAscii AS AsciiType, pShowStatus)
    STATIC row
    STATIC oldRow

    IF NOT pShowStatus THEN
        DrawRow row
        EXIT SUB
    END IF

    IF row = 0 THEN
        oldRow = 25
        row = 25
    END IF
 
    IF pAscii.row = 25 THEN
        oldRow = row
        row = 1

        IF row <> oldRow THEN
            DrawRow oldRow
        END IF

    ELSEIF pAscii.row = 1 THEN
        oldRow = row
        row = 25

        IF row <> oldRow THEN
            DrawRow oldRow
        END IF
    END IF
 
    COLOR 0, 7
    LOCATE row, 1
    PRINT "Char: "; CHR$(pAscii.code); " ";
    PRINT "Code: ";
    PRINT USING "###"; pAscii.code;
    PRINT " row: ";: PRINT USING "##"; pAscii.row;
    PRINT " col: ";: PRINT USING "##"; pAscii.col;
    PRINT " FG: ";: COLOR pAscii.fg, 0: PRINT CHR$(219);
    COLOR 0, 7
    PRINT " BG: ";: COLOR pAscii.bg, 0: PRINT CHR$(219);
    COLOR 0, 7:
    PRINT "                ";
    PRINT USING "File: \           \"; gFileName$;
END SUB

SUB DrawWindow (pR1, pC1, pR2, pC2, pStyle, pTitle$)
    DIM styles$

    SELECT CASE pStyle
        CASE IS > STYLE.BORDER.MIXEDINV
            styles$ = CHR$(205) + CHR$(179) + CHR$(213) + CHR$(184) + CHR$(212) + CHR$(190)
            pStyle = pStyle - STYLE.BORDER.MIXEDINV
        CASE IS > STYLE.BORDER.MIXED
            styles$ = CHR$(196) + CHR$(186) + CHR$(214) + CHR$(183) + CHR$(211) + CHR$(189)
            pStyle = pStyle - STYLE.BORDER.MIXED
        CASE IS > STYLE.BORDER.DOUBLE
            styles$ = CHR$(205) + CHR$(186) + CHR$(201) + CHR$(187) + CHR$(200) + CHR$(188)
            pStyle = pStyle - STYLE.BORDER.DOUBLE
        CASE IS > STYLE.BORDER.SINGLE
            styles$ = CHR$(196) + CHR$(179) + CHR$(218) + CHR$(191) + CHR$(192) + CHR$(217)
            pStyle = pStyle - STYLE.BORDER.SINGLE
        CASE IS > STYLE.BORDER.SOLID
            styles$ = CHR$(219) + CHR$(219) + CHR$(219) + CHR$(219) + CHR$(219) + CHR$(219)
            pStyle = pStyle - STYLE.BORDER.SOLID
    END SELECT

    IF pR2 = -1 THEN
        pR2 = SCREEN.HEIGHT - pR1
    END IF

    IF pC2 = -1 THEN
        pC2 = SCREEN.WIDTH - pC1
    END IF

    LOCATE pR1, pC1: PRINT MID$(styles$, 3, 1);
    FOR col = pC1 + 1 TO pC2 - 1
        LOCATE pR1, col: PRINT MID$(styles$, 1, 1);
    NEXT col

    IF pTitle$ <> "" THEN
        pTitle$ = "[ " + pTitle$ + " ]"
        iCenter = pC1 + ((pC2 - pC1) \ 2)
        LOCATE pR1, iCenter - (LEN(pTitle$) \ 2)
        PRINT pTitle$;
    END IF

    LOCATE pR1, pC2: PRINT MID$(styles$, 4, 1);
    FOR row = pR1 + 1 TO pR2 - 1
        LOCATE row, pC1: PRINT MID$(styles$, 2, 1);
        IF pStyle = STYLE.FILL.SOLID THEN
            PRINT STRING$(pC2 - pC1 - 1, " ");
        END IF
        LOCATE row, pC2: PRINT MID$(styles$, 2, 1);
    NEXT row
    LOCATE pR2, pC1: PRINT MID$(styles$, 5, 1);
    FOR col = pC1 + 1 TO pC2 - 1
        LOCATE pR2, col: PRINT MID$(styles$, 1, 1);
    NEXT col
    LOCATE pR2, pC2: PRINT MID$(styles$, 6, 1);
END SUB

SUB GetAsciiFromBuffer (pAscii AS AsciiType)
    bufferId = GetRowColBuffer(pAscii.row, pAscii.col)
 
    pAscii.code = gAsciiBuffer(bufferId).code
    pAscii.row = gAsciiBuffer(bufferId).row
    pAscii.col = gAsciiBuffer(bufferId).col
    pAscii.fg = gAsciiBuffer(bufferId).fg
    pAscii.bg = gAsciiBuffer(bufferId).bg
END SUB

FUNCTION GetColFromBuffer (pBufferId)
    row = GetRowFromBuffer(pBufferId)
    GetColFromBuffer = SCREEN.WIDTH - ((row * SCREEN.WIDTH) - pBufferId)
END FUNCTION

FUNCTION GetRowColBuffer (pRow, pCol)
    GetRowColBuffer = (SCREEN.WIDTH * pRow) - SCREEN.WIDTH + pCol
END FUNCTION

FUNCTION GetRowFromBuffer (pBufferId)
    GetRowFromBuffer = INT((pBufferId - 1) / SCREEN.WIDTH) + 1
END FUNCTION

SUB LoadFile
    PCOPY 0, 1
    COLOR 15, 1
    LOCATE , , 0 ' Turn the cursor off
    DrawWindow 10, 23, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, "Load QBASCII File"
    Center 12, "Filename: " + SPACE$(12)
    LOCATE , POS(0) - 12
    COLOR 15, 0
    PRINT SPACE$(12);
    LOCATE , POS(0) - 12 'Locate to beginning of input
    COLOR 15, 0
    fileInput$ = QBInput$(12, gFileName$)
    PCOPY 1, 0
    IF fileInput$ <> "" THEN
        isValidFile = TRUE
        isFileFound = FALSE

        IF NOT UCASE$(RIGHT$(_TRIM$(fileInput$), 4)) = ".QBA" THEN
            IF LEN(fileInput$) <= 8 THEN
                fileInput$ = fileInput$ + ".QBA"
            ELSE
                isValidFile = FALSE
            END IF
        END IF

        IF isValidFile THEN
            gFileName$ = UCASE$(fileInput$)
            OPEN gFileName$ FOR BINARY AS #1
            IF LOF(1) > 0 THEN isFileFound = TRUE
            CLOSE #1
     
            IF isFileFound THEN
                OPEN gFileName$ FOR RANDOM AS #1 LEN = LEN(gBlankAscii)
                FOR i = 1 TO SCREEN.WIDTH * SCREEN.HEIGHT
                    GET #1, i, gAsciiBuffer(i)
                NEXT i
                CLOSE #1

                FOR i = 1 TO SCREEN.WIDTH * SCREEN.HEIGHT
                    DrawAscii gAsciiBuffer(i)
                NEXT i

                PCOPY 0, 1
                COLOR 15, 1
                DrawWindow 11, 25, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, ""
                Center 12, gFileName$ + " Loaded"
                SLEEP 2
                PCOPY 1, 0
            ELSE
                KILL gFileName$
                PCOPY 0, 1
                COLOR 15, 4
                DrawWindow 11, 25, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, ""
                Center 12, "File not found: " + gFileName$
                SLEEP 2
                PCOPY 1, 0
            END IF 'isFileFound
        ELSE
            PCOPY 0, 1
            COLOR 15, 4
            DrawWindow 11, 25, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, ""
            Center 12, "Invalid File Name"
            SLEEP 2
            PCOPY 1, 0
        END IF 'isValidFile
    END IF 'fileInput$ <> ""
END SUB

SUB Mouse (funk)
    '"QBMouse.bas" Written 1999 by: Daryl R. Dubbs

    'SHARED mouseH, mouseV, mouseB
    STATIC crsr 'track whether Cursor is shown
    IF funk% = 1 THEN crsr = 1 'show Cursor
    IF funk% = 2 AND crsr = 0 THEN EXIT SUB 'don't hide cursor more than onced
    IF funk% = 2 AND crsr = 1 THEN crsr = 0 'Hide cursor

    POKE 100, 184: POKE 101, funk: POKE 102, 0 'Poke machine code necessary for
    POKE 103, 205: POKE 104, 51: POKE 105, 137 'using the mouse into memeory
    POKE 106, 30: POKE 107, 170: POKE 108, 10 'starting at offset 100 in the
    POKE 109, 137: POKE 110, 14: POKE 111, 187 'current segment. This code
    POKE 112, 11: POKE 113, 137: POKE 114, 22 'then executed as a unit, via the
    POKE 115, 204: POKE 116, 12: POKE 117, 203 'statement "Call Absolute"
    CALL ABSOLUTE(100) 'Call machine code
    
    mouseB = PEEK(&HAAA) 'Get values for buttons
    mouseH = CINT((PEEK(&HBBB) + PEEK(&HBBC) * 256) / 8) 'Horizontal position (2 bytes)
    mouseV = CINT((PEEK(&HCCC) + PEEK(&HCCD) * 256) / 8) 'Vertical position (2 bytes)
END SUB

FUNCTION QBInput$ (pLength, pDefault$)
    inputLength = pLength
    defaultLength = LEN(pDefault$)

    IF defaultLength > inputLength THEN inputLength = defaultLength

    inputText$ = SPACE$(inputLength)

    IF defaultLength > 0 THEN MID$(inputText$, 1) = pDefault$

    iCsrPos = 0
    rowOffset = CSRLIN
    colOffset = POS(0)

    LOCATE , , 1, 0, 1
    PRINT inputText$;
    DO
        keyPress$ = INKEY$

        IF keyPress$ > "" THEN
            SELECT CASE ASC(keyPress$)
            
                CASE KEYS.ESCAPE
                    inputText$ = ""
                    isCancel = TRUE
            
                CASE KEYS.RETURN
                    isReturn = TRUE

                CASE KEYS.BACKSPACE
                    IF iCsrPos > 0 THEN
                        iCsrPos = iCsrPos - 1
                        FOR i = iCsrPos TO inputLength - 1
                            MID$(inputText$, i + 1) = MID$(inputText$, i + 2, 1)
                        NEXT i
                        MID$(inputText$, inputLength) = " "
                    ELSE
                    END IF

                    ' 0-9 A-Z, a-z
                CASE 48 TO 57, 65 TO 90, 97 TO 122
                    IF isInsert THEN
                        IF iCsrPos < inputLength THEN iCsrPos = iCsrPos + 1
                        MID$(inputText$, iCsrPos) = keyPress$
                    ELSE
                        IF RIGHT$(inputText$, 1) = " " THEN
                            IF iCsrPos < inputLength THEN
                                iCsrPos = iCsrPos + 1
                                IF iCsrPos <> inputLength THEN
                                    s$ = MID$(inputText$, iCsrPos, inputLength - 1)
                                    MID$(inputText$, iCsrPos + 1) = s$
                                END IF
                                MID$(inputText$, iCsrPos) = keyPress$
                            END IF
                        END IF
                    END IF
                    
                    IF iCsrPos = inputLength THEN iCsrPos = iCsrPos - 1
            
                CASE ELSE
                
                    SELECT CASE ASC(RIGHT$(keyPress$, 1))
                    
                        CASE KEYS.INSERT
                            isInsert = NOT isInsert
                         
                        CASE KEYS.DELETE
                            FOR i = iCsrPos TO inputLength - 1
                                IF i = inputLength - 1 THEN
                                    MID$(inputText$, inputLength) = " "
                                ELSE
                                    MID$(inputText$, i + 1) = MID$(inputText$, i + 2, 1)
                                END IF
                            NEXT i

                        CASE KEYS.HOME
                            iCsrPos = 0

                        CASE KEYS.END
                            iCsrPos = inputLength - 1
                    
                        CASE KEYS.LEFT
                            IF iCsrPos > 0 THEN iCsrPos = iCsrPos - 1

                        CASE KEYS.RIGHT
                            IF iCsrPos < inputLength - 1 THEN iCsrPos = iCsrPos + 1

                    END SELECT

            END SELECT

            LOCATE , colOffset: PRINT inputText$;

        END IF

        IF isInsert THEN
            LOCATE , , 1, 0, 31
        ELSE
            LOCATE , , 1, 29, 31
        END IF
        LOCATE rowOffset, colOffset + iCsrPos
     
    LOOP UNTIL isCancel OR isReturn

    'Turn cursor off
    LOCATE , , 0

    QBInput = LTRIM$(RTRIM$(inputText$))
END FUNCTION

SUB SaveFile
    PCOPY 0, 1
    COLOR 15, 1
    LOCATE , , 0 ' Turn the cursor off
    DrawWindow 10, 23, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, "Save QBASCII File"
    Center 12, "Filename: " + SPACE$(12)
    LOCATE , POS(0) - 12
    COLOR 15, 0
    PRINT SPACE$(12);
    LOCATE , POS(0) - 12
    fileInput$ = QBInput$(12, gFileName$)
    PCOPY 1, 0
    IF fileInput$ <> "" THEN
        isValidFile = TRUE
        isFileFound = FALSE

        IF NOT UCASE$(RIGHT$(_TRIM$(fileInput$), 4)) = ".QBA" THEN
            IF LEN(fileInput$) <= 8 THEN
                fileInput$ = fileInput$ + ".QBA"
            ELSE
                isValidFile = FALSE
            END IF
        END IF
        
        IF isValidFile THEN
            gFileName$ = UCASE$(fileInput$)
            OPEN gFileName$ FOR RANDOM AS #1 LEN = LEN(gBlankAscii)
            FOR i = 1 TO UBOUND(gAsciiBuffer)
                PUT #1, i, gAsciiBuffer(i)
            NEXT i
            CLOSE #1

            PCOPY 0, 1
            COLOR 15, 1
            DrawWindow 11, 25, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, ""
            Center 12, gFileName$ + " Saved"
            SLEEP 2
            PCOPY 1, 0
        ELSE
            PCOPY 0, 1
            COLOR 15, 4
            DrawWindow 11, 25, -1, -1, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, ""
            Center 12, "Invalid File Name"
            SLEEP 2
            PCOPY 1, 0
        END IF 'isValidFile
    END IF 'fileInput$ <> ""
END SUB

SUB ShiftAsciiColumn (pRow, pCol, pShiftDir)
    bufferId = GetRowColBuffer(pRow, pCol)
    pLength = SCREEN.WIDTH - pCol

    IF pShiftDir > 0 THEN
        FOR i = bufferId + pLength TO bufferId STEP -1
            gAsciiBuffer(i).code = gAsciiBuffer(i - 1).code
            gAsciiBuffer(i).fg = gAsciiBuffer(i - 1).fg
            gAsciiBuffer(i).bg = gAsciiBuffer(i - 1).bg
            DrawAscii gAsciiBuffer(i)
        NEXT i

        ClearAsciiBuffer bufferId, 1
    ELSE
        FOR i = bufferId - 1 TO bufferId + pLength
            gAsciiBuffer(i).code = gAsciiBuffer(i + 1).code
            gAsciiBuffer(i).fg = gAsciiBuffer(i + 1).fg
            gAsciiBuffer(i).bg = gAsciiBuffer(i + 1).bg

            IF gAsciiBuffer(i).col = SCREEN.WIDTH THEN
                ClearAsciiBuffer i, 1
            ELSE
                DrawAscii gAsciiBuffer(i)
            END IF
        NEXT i
    END IF
END SUB

SUB ShowAsciiSelection (pAscii AS AsciiType)
    rowOffset = 4
    colOffset = 22
    colSpacing = 2
    rowMax = 15
    colMax = 17

    PCOPY 0, 1
    COLOR 15, 1
    DrawWindow rowOffset, colOffset, rowOffset + 18, colOffset + 36, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, "Select an ASCII char"

    COLOR 7, 1
    FOR r = 1 TO rowMax
        FOR c = 1 TO colMax
            asciiCode = asciiCode + 1
            LOCATE r + rowOffset, c * colSpacing + colOffset
         
            SELECT CASE asciiCode
                CASE 1 TO 6, 8, 14 TO 27, IS > 33
                    PRINT CHR$(asciiCode);
                CASE ELSE
                    PRINT CHR$(32);
            END SELECT
            
        NEXT c
    NEXT r

    isSelected = FALSE
    isDone = FALSE
    selCode = pAscii.code
    selRow = (selCode + colMax - 1) \ colMax
    selCol = selCode - (selRow * colMax - colMax)
    needsRender = TRUE

    DO
        keyPress$ = INKEY$
        Mouse 3

        IF oldMouseV <> mouseV OR oldMouseH <> mouseH OR oldMouseB <> mouseB THEN
            needsRender = TRUE
        
            IF mouseV <> selRow THEN
                IF mouseV > 0 AND mouseV <= rowMax THEN
                    selRow = mouseV
                END IF
            END IF

            IF mouseH <> selCol THEN
                IF mouseH > 0 AND mouseH <= colMax THEN
                    selCol = mouseH
                END IF
            END IF

            IF mouseB = 1 THEN
                isSelected = TRUE
            END IF
        END IF

        IF keyPress$ > "" THEN
            needsRender = TRUE
            SELECT CASE ASC(keyPress$)
                CASE KEYS.ESCAPE, KEYS.TAB
                    isDone = TRUE
                CASE KEYS.RETURN
                    isSelected = TRUE
                CASE ELSE
                    SELECT CASE ASC(RIGHT$(keyPress$, 1))
                        CASE KEYS.UP
                            selRow = selRow - 1
                            IF selRow < 1 THEN selRow = rowMax
                        CASE KEYS.DOWN
                            selRow = selRow + 1
                            IF selRow > rowMax THEN selRow = 1
                        CASE KEYS.LEFT
                            selCol = selCol - 1
                            IF selCol < 1 THEN selCol = colMax
                        CASE KEYS.RIGHT
                            selCol = selCol + 1
                            IF selCol > colMax THEN selCol = 1
                    END SELECT
            END SELECT
        END IF

        IF needsRender THEN
            selCode = selRow * colMax - colMax + selCol

            SELECT CASE selCode
                CASE 1 TO 6, 8, 14 TO 27, IS > 33
                CASE ELSE
                    selCode = 32
            END SELECT

            COLOR 15, 1: LOCATE rowOffset + 17, colOffset + 9
            PRINT "ASCII: "; CHR$(selCode); " Code:"; selCode;

            LOCATE rowOffset + selRow, colOffset + selCol * colSpacing, 1, 0, 4
         
            needsRender = FALSE
        END IF
     
        IF isSelected THEN
            pAscii.code = selCode
        END IF

        oldMouseV = mouseV
        oldMouseH = mouseH
        oldMouseB = mouseB
    LOOP UNTIL isSelected OR isDone
 
    LOCATE , , 0 ' Turn the cursor off
    PCOPY 1, 0
END SUB

SUB ShowUsage
    PCOPY 0, 1
    COLOR 15, 1
    LOCATE , , 0 ' Turn the cursor off
    DrawWindow 2, 6, 24, 75, STYLE.BORDER.MIXEDINV + STYLE.FILL.SOLID, "Using QBASCII"
    LOCATE 3, 8
    PRINT "                        <F1>   Show usage (this screen)";
    LOCATE 4, 8
    PRINT "                    <Escape>   Show / Hide status bar";
    LOCATE 6, 8
    PRINT "                    <Ctrl+Q>   Quit";
    LOCATE 7, 8
    PRINT "                    <Ctrl+N>   New file";
    LOCATE 8, 8
    PRINT "                    <Ctrl+O>   Open file";
    LOCATE 9, 8
    PRINT "                    <Ctrl+S>   Save file";
    LOCATE 11, 8
    PRINT "  <Up>,<Down>,<Left>,<Right>   Move in specified direction";
    LOCATE 12, 8
    PRINT "                     <Space>   Plot ASCII char at position";
    LOCATE 13, 8
    PRINT "                       <Tab>   ASCII char selection window";
    LOCATE 14, 8
    PRINT "         <PageUp>,<PageDown>   Change char foreground color";
    LOCATE 15, 8
    PRINT "<Ctrl+PageUp><Ctrl+PageDown>   Change char background color";
    LOCATE 16, 8
    PRINT "    <Ctrl+Left>,<Ctrl+Right>   Move to previous / next char";
    LOCATE 17, 8
    PRINT "                <Home>,<End>   Move to first / last char on row";
    LOCATE 18, 8
    PRINT "      <Ctrl+Home>,<Ctrl+End>   Move to first / last char on screen";
    LOCATE 20, 8
    PRINT "                    <Insert>   Toggle insert mode";
    LOCATE 21, 8
    PRINT "       <Space> (insert mode)   Insert a space at position";
    LOCATE 22, 8
    PRINT "   <Backspace> (insert mode)   Remove char to left of position";
    LOCATE 23, 8
    PRINT "         <Del> (insert mode)   Remove char at position";

    ans$ = INPUT$(1)
    PCOPY 1, 0
END SUB
