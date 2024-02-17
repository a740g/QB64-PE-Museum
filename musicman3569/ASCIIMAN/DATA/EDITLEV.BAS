DEFINT A-Z

TYPE Level
    fileName AS STRING '--- Name of the level's data file
    title AS STRING '--- Display title of level
END TYPE

TYPE Button
    label AS STRING '--- Label to show above toolbar when a toolbar button is selected
    char AS STRING '--- Character to add to level when the toolboar button is selected
END TYPE

TYPE Mouse
    row AS INTEGER '--- Text row the mouse is currently over
    col AS INTEGER '--- Text col the mouse is currently over
    btnLeft AS INTEGER '--- Left mouse button pressed = -1, unpressed = 0
    btnRight AS INTEGER '--- Right mouse button pressed = -1, unpressed = 0
    btnMiddle AS INTEGER '--- Middle mouse button pressed = -1, unpressed = 0
    clickCol AS INTEGER '--- Text col the mouse last clicked on
    clickRow AS INTEGER '--- Text row the mouse last clicked on
END TYPE

'--- Global mouse singleton to store mouse position and events
DIM SHARED MOUSE AS Mouse

'--- Toolbar buttons to show at the bottom of the level editor for adding sprites/tiles
DIM SHARED BUTTONS AS INTEGER: BUTTONS = 15 '--- MUST be set equal to the number of BUTTON() array elements
DIM SHARED BUTTON(1 TO BUTTONS) AS Button
BUTTON(1).label = "Player"
BUTTON(1).char = ""
BUTTON(2).label = "Enemy1"
BUTTON(2).char = "O"
BUTTON(3).label = "Fire"
BUTTON(3).char = "F"
BUTTON(4).label = "1-Up"
BUTTON(4).char = ""
BUTTON(5).label = "Spike"
BUTTON(5).char = "³"
BUTTON(6).label = "SlideR"
BUTTON(6).char = "\"
BUTTON(7).label = "SlideL"
BUTTON(7).char = "/"
BUTTON(8).label = "LvlEnd"
BUTTON(8).char = "°"
BUTTON(9).label = "Solid"
BUTTON(9).char = "S"
BUTTON(10).label = "Torch"
BUTTON(10).char = "T"
BUTTON(11).label = "Pole"
BUTTON(11).char = "P"
BUTTON(12).label = "Block"
BUTTON(12).char = "ß"
BUTTON(13).label = "Stone"
BUTTON(13).char = "Û"
BUTTON(14).label = "Solid (Cyan)"
BUTTON(14).char = "±"
BUTTON(15).label = "Solid (Lt Blue)"
BUTTON(15).char = "²"

'--- Stores which toolbar button is currently selected
DIM SHARED BUTTON_ACTIVE: BUTTON_ACTIVE = 12


TYPE LevelMenu
    min AS INTEGER '--- Lowest visible menu item index to show on the top menu row
    max AS INTEGER '--- Highest visible menu item index to show on the bottom menu row
    value AS INTEGER '--- Value of the currently selected menu item index
    pageSize AS INTEGER '--- Number of menu item rows to show at one time on screen
    offset AS INTEGER '--- Number of rows to offset the menu from the top of the screen
END TYPE

DIM SHARED COLS: COLS = 80
DIM SHARED ROWS: ROWS = 28

'--- List of level data filenames in the DATA directory
DIM SHARED FILE_LIST$(1 TO 200)
DIM SHARED FILE_LISTS: FILE_LISTS = 0

'--- Level file data found in the DATA directory
DIM SHARED LEVEL(1 TO 200) AS Level
DIM SHARED LEVELS: LEVELS = 0

SCREEN 12: CLS 0
_FULLSCREEN _SQUAREPIXELS

LevelMenu
SYSTEM

'--------------------------------------------------------------------------
' Displays the main menu with the level data files found in the DATA directory.
' Allows using the arrow keys to select a level, and Enter to edit the
' selected level.
'--------------------------------------------------------------------------
SUB LevelMenu
    DIM menu AS LevelMenu
    CLS 0

    PrintAt 1, 2, 15, "SELECT A LEVEL TO EDIT: (Arrow keys to move, Enter to select)"
    PrintAt 2, 2, 15, "-----------------------"

    GetLevels
    menu.offset = 3
    menu.pageSize = 20
    menu.value = 1
    menu.min = 1
    menu.max = GetMin(LEVELS, menu.pageSize)

    DO
        LevelMenuPrint menu
        SLEEP
        keyPress$ = INKEY$
        WHILE INKEY$ <> "": WEND

        SELECT CASE keyPress$
            CASE CHR$(0) + "H" 'Up
                LevelMenuSelect menu, menu.value - 1
            CASE CHR$(0) + "P" 'Down
                LevelMenuSelect menu, menu.value + 1
            CASE CHR$(27)
                SYSTEM
        END SELECT
    LOOP WHILE keyPress$ <> CHR$(13)

    LoadLevelFile LEVEL(menu.value)
    LevelEditor LEVEL(menu.value)
END SUB

'--------------------------------------------------------------------------
' Main editing loop for the level editor. Displays the level data and
' allows editing by clicking toolbar buttons on the bottom and clicking
' the mouse to add them to the screen, or right-click to erase.
'
' @param level Level to edit.
'--------------------------------------------------------------------------
SUB LevelEditor (level AS Level)
    DO
        GetMouseInput
        keyInput$ = INKEY$
        PrintAt 29, 40, 10, "Row:" + STR$(MOUSE.row) + " "
        PrintAt 29, 48, 10, "Col:" + STR$(MOUSE.col) + " "
        PrintAt 29, 60, 10, "F1=Save  Esc=Exit"
        ButtonsPrint

        IF MOUSE.btnLeft THEN
            IF MOUSE.row = 30 THEN
                '--- Toolbar button was clicked, make it the active button
                IF MOUSE.col <= (BUTTONS * 2) THEN
                    BUTTON_ACTIVE = _CEIL(MOUSE.col / 2)
                END IF
            ELSEIF MOUSE.row < 29 THEN
                '--- Game area was clicked, add the currently selected toolbar character
                PrintAt MOUSE.row, MOUSE.col, 7, BUTTON(BUTTON_ACTIVE).char
            END IF
        END IF

        '--- Game area was right-clicked, erase character
        IF MOUSE.btnRight AND MOUSE.row < 29 THEN
            PrintAt MOUSE.row, MOUSE.col, 7, " "
        END IF

        '--- F1 key was pressed, save file
        SELECT CASE keyInput$
            CASE CHR$(0) + CHR$(59) '[F1]
                PrintAt 29, 2, 10, "Saving " + level.fileName + "          "
                LevelFileSave level
                PrintAt 29, 2, 10, "Saved " + level.fileName + "          "
                SLEEP 1
            CASE CHR$(27)
                '--- Do nothing, exit below
            CASE ELSE
                '--- Any other character, just print on-screen
                IF MOUSE.row < 29 THEN
                    PrintAt MOUSE.row, MOUSE.col, 7, keyInput$
                END IF
        END SELECT

        _LIMIT 60
    LOOP UNTIL keyInput$ = CHR$(27) '--- Loop until Esc is pressed
END SUB

'--------------------------------------------------------------------------
' Print the toolbar buttons at the bottom of the screen.
'--------------------------------------------------------------------------
SUB ButtonsPrint
    DIM btnColor
    LOCATE 30, 1

    FOR b = 1 TO BUTTONS
        IF b = BUTTON_ACTIVE THEN
            btnColor = 10
            PrintAt 29, 2, btnColor, BUTTON(b).label + "               "
        ELSE
            btnColor = 7
        END IF

        PrintAt 30, b * 2, btnColor, BUTTON(b).char
    NEXT b
END SUB

'--------------------------------------------------------------------------
' Print the specified menu's items on-screen.  Call this any time a change
' in selection to the menu is made.  Handles paging/scrolling automatically.
'
' @param menu LevelMenu to render on-screen.
'--------------------------------------------------------------------------
SUB LevelMenuPrint (menu AS LevelMenu)
    row = menu.min
    menuColor = 7

    WHILE row <= menu.max
        IF row = menu.value THEN
            menuColor = 14
        ELSE
            menuColor = 7
        END IF

        PrintAt menu.offset - menu.min + row, 2, menuColor, "Level" + STR$(row) + " - " + LEVEL(row).title + "                                       "
        row = row + 1
    WEND
END SUB

'--------------------------------------------------------------------------
' Set the selected value of a LevelMenu, after checking that it is a valid
' value. If the value is not valid, no change is made.
'
' @param menu The LevelMenu being changed.
' @param newLevelMenuVal New proposed value to set for the menu. Only used if the value is legal.
'--------------------------------------------------------------------------
SUB LevelMenuSelect (menu AS LevelMenu, newLevelMenuVal)
    IF newLevelMenuVal > menu.max THEN
        IF LEVELS > menu.max THEN
            menu.min = menu.min + 1
            menu.max = menu.max + 1
            menu.value = newLevelMenuVal
        END IF
    ELSEIF newLevelMenuVal < menu.min THEN
        IF menu.min > 1 THEN
            menu.min = menu.min - 1
            menu.max = menu.max - 1
            menu.value = newLevelMenuVal
        END IF
    ELSE
        menu.value = newLevelMenuVal
    END IF
END SUB

'--------------------------------------------------------------------------
' Lists the data files in the current directory.  Has to cache the file
' names to a text file to overcome QBasic limitations in listing
' filenames in a parseable way.
'--------------------------------------------------------------------------
SUB GetFileList
    DIM textFileForList$: textFileForList$ = "FILE_LIST.TXT"
    FILE_LISTS = 0

    '--- Use the DOS "dir" command options to write the filtered filenames to a text file.
    SHELL _HIDE "dir /B .\*.DAT > " + textFileForList$

    '--- Read the filenames from the text file into an array of filenames.
    OPEN textFileForList$ FOR INPUT AS #1
    WHILE NOT EOF(1)
        FILE_LISTS = FILE_LISTS + 1
        INPUT #1, FILE_LIST$(FILE_LISTS)
    WEND
    CLOSE #1
END SUB

'--------------------------------------------------------------------------
' Populate the LEVEL() data array by getting the level data file list
' and reading the titles from each file.
'--------------------------------------------------------------------------
SUB GetLevels
    GetFileList
    LEVELS = FILE_LISTS

    FOR fileList = 1 TO FILE_LISTS
        fileName$ = FILE_LIST$(fileList)
        LEVEL = VAL(Replace$(Replace$(FILE_LIST$(fileList), "LEV_", ""), ".DAT", ""))
        LEVEL(LEVEL).fileName = fileName$

        OPEN LEVEL(LEVEL).fileName FOR INPUT AS #1
        INPUT #1, LEVEL(LEVEL).title
        CLOSE #1
    NEXT fileList
END SUB

'--------------------------------------------------------------------------
' Reads the data in from a specified level and prints it on-screen.
'
' @param level Level data to read.
'--------------------------------------------------------------------------
SUB LoadLevelFile (level AS Level)
    DIM row$

    OPEN level.fileName FOR INPUT AS #1
    INPUT #1, level.title

    COLOR 7, 0

    FOR ROW = 1 TO ROWS
        INPUT #1, row$
        LOCATE ROW, 1: PRINT row$
    NEXT ROW
    CLOSE #1
END SUB

'--------------------------------------------------------------------------
' Saves the currently loaded level data to the specified level.
'
' @param level Level to save the on-screen changes to.
'--------------------------------------------------------------------------
SUB LevelFileSave (level AS Level)
    DIM ln$(30)
    FOR r = 1 TO 28
        FOR c = 1 TO 80
            ln$(r) = ln$(r) + CHR$(SCREEN(r, c))
        NEXT c
    NEXT r

    OPEN level.fileName FOR OUTPUT AS #1
    PRINT #1, CHR$(34) + level.title + CHR$(34)
    FOR r = 1 TO 28
        PRINT #1, CHR$(34) + ln$(r) + CHR$(34)
    NEXT r
    PRINT #1, CHR$(34) + CHR$(34)
    PRINT #1, CHR$(34) + CHR$(34)
    CLOSE #1
END SUB

'--------------------------------------------------------------------------
' Print text using a specified position and color.
'
' @param row% Screen row to start printing the text
' @param col% Screen col to start printing the text
' @param text$ Text to render
'--------------------------------------------------------------------------
SUB PrintAt (row, col, textColor, text$)
    IF row > 0 AND row <= 30 AND col > 0 AND col <= 80 THEN
        COLOR textColor
        LOCATE row, col
        PRINT text$;
    END IF
END SUB

'--------------------------------------------------------------------------
' Replaces all instances of the [Find] sub-string with the [Add] sub-string
' within the [Text] string.
'
' @param Text The input string; the text that's being manipulated.
' @param Find The specified sub-string; the string sought within the [Text] string.
' @param Add The sub-string that's being added to the [Text] string.
'--------------------------------------------------------------------------
FUNCTION Replace$ (Text AS STRING, Find AS STRING, Add AS STRING)
    DIM lngLocation AS LONG 'The address of the [Find] substring within the [Text] string.
    DIM strBefore AS STRING 'The characters before the string to be replaced.
    DIM strAfter AS STRING 'The characters after the string to be replaced.

    '--- INITIALIZE:
    lngLocation = INSTR(1, Text, Find)

    '--- PROCESSING:
    '--- While [Find] appears in [Text]...
    WHILE lngLocation
        'Extract all text before the [Find] substring:
        strBefore = LEFT$(Text, lngLocation - 1)
        'Extract all text after the [Find] substring:
        strAfter = RIGHT$(Text, ((LEN(Text) - (lngLocation + LEN(Find) - 1))))
        'Return the substring:
        Text = strBefore + Add + strAfter
        'Locate the next instance of [Find]:
        lngLocation = INSTR(1, Text, Find)
        'Next instance of [Find]...
    WEND

    '--- OUTPUT:
    Replace$ = Text
END FUNCTION

'--------------------------------------------------------------------------
' Reads a character from the screen at the specified position.
'
' @param row% Screen row to read.
' @param col% Screen col to read.
'--------------------------------------------------------------------------
FUNCTION CharAt$ (row, col)
    CharAt$ = CHR$(SCREEN(row, col))
END FUNCTION

'--------------------------------------------------------------------------
' Get the maximum of 2 integer values.
'
' @param valueA First value to compare.
' @param valueB Second value to compare.
' @return Maximum value between valueA and valueB
'--------------------------------------------------------------------------
FUNCTION GetMax (valueA, valueB)
    IF (valueA > valueB) THEN GetMax = valueA ELSE GetMax = valueB
END FUNCTION

'--------------------------------------------------------------------------
' Get the minimum of 2 integer values.
'
' @param valueA First value to compare.
' @param valueB Second value to compare.
' @return Minimum value between valueA and valueB
'--------------------------------------------------------------------------
FUNCTION GetMin (valueA, valueB)
    IF (valueA < valueB) THEN GetMin = valueA ELSE GetMin = valueB
END FUNCTION

'--------------------------------------------------------------------------
' Capture mouse input for this frame.  To be called during the level editor
' main loop.
'--------------------------------------------------------------------------
SUB GetMouseInput
    DO WHILE _MOUSEINPUT
        MOUSE.col = _CEIL(_MOUSEX / (640 / 80))
        MOUSE.row = _CEIL(_MOUSEY / (480 / 30))
        MOUSE.btnLeft = _MOUSEBUTTON(1)
        MOUSE.btnRight = _MOUSEBUTTON(2)
        MOUSE.btnMiddle = _MOUSEBUTTON(3)

        IF MOUSE.btnLeft THEN
            MOUSE.clickCol = MOUSE.col
            MOUSE.clickRow = MOUSE.row
        END IF
    LOOP
END SUB


