' ===========================================================================
'
' WINDOW.BI
'
'  Copyright (C) 1989 Microsoft Corporation, All Rights Reserved
'  Copyright (C) 2023 Samuel Gomes
'
' ===========================================================================

$IF WINDOW_BI = UNDEFINED THEN
    $LET WINDOW_BI = TRUE

    '$INCLUDE:'General.bi'
    '$INCLUDE:'Mouse.bi'
    '$INCLUDE:'Menu.bi'

    ' ===========================================================================
    ' windoType stores information about each window
    ' ===========================================================================

    TYPE windowType
        handle AS LONG
        row1 AS LONG
        col1 AS LONG
        row2 AS LONG
        col2 AS LONG
        cursorRow AS LONG
        cursorCol AS LONG
        highlight AS LONG
        textFore AS LONG
        textBack AS LONG
        fore AS LONG
        back AS LONG
        windowType AS LONG
        title AS STRING * 15
    END TYPE

    ' ===========================================================================
    ' buttonType stores info about buttons
    ' ===========================================================================

    TYPE buttonType
        handle AS LONG
        windowHandle AS LONG
        text AS STRING * 30
        state AS LONG
        buttonOn AS LONG
        row1 AS LONG
        col1 AS LONG
        row2 AS LONG
        col2 AS LONG
        buttonType AS LONG
    END TYPE

    ' ===========================================================================
    ' EditField Type stores info about edit fields
    ' ===========================================================================

    TYPE EditFieldType
        handle AS LONG
        windowHandle AS LONG
        text AS STRING * 255
        fore AS LONG
        back AS LONG
        row AS LONG
        col AS LONG
        visLength AS LONG
        maxLength AS LONG
    END TYPE

    TYPE hotSpotType
        row1 AS LONG
        row2 AS LONG
        col1 AS LONG
        col2 AS LONG
        action AS LONG
        misc AS LONG
        misc2 AS LONG
    END TYPE

    TYPE WindowStorageType
        currWindow AS LONG
        numWindowsOpen AS LONG
        numButtonsOpen AS LONG
        numEditFieldsOpen AS LONG
        DialogEdit AS LONG
        DialogClose AS LONG
        DialogButton AS LONG
        DialogWindow AS LONG
        DialogEvent AS LONG
        DialogScroll AS LONG
        DialogRow AS LONG
        DialogCol AS LONG
        oldDialogEdit AS LONG
        oldDialogClose AS LONG
        oldDialogButton AS LONG
        oldDialogWindow AS LONG
        oldDialogEvent AS LONG
        oldDialogScroll AS LONG
        oldDialogRow AS LONG
        oldDialogCol AS LONG
    END TYPE

    ' ===========================================================================
    ' GLOBAL VARIABLES
    ' ===========================================================================

    REDIM SHARED GloWindow(0 TO 0) AS windowType
    REDIM SHARED GloButton(0 TO 0) AS buttonType
    REDIM SHARED GloEdit(0 TO 0) AS EditFieldType
    DIM SHARED GloStorage AS WindowStorageType
    REDIM SHARED GloWindowStack(0 TO 0) AS LONG
    REDIM SHARED GloBuffer(0 TO 0, 0 TO 0) AS STRING

$END IF
