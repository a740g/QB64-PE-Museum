' ===========================================================================
'
' MENU.BI
'
'  Copyright (C) 1989 Microsoft Corporation, All Rights Reserved
'  Copyright (C) 2023 Samuel Gomes
'
' ===========================================================================

$IF MENU_BI = UNDEFINED THEN
    $LET MENU_BI = TRUE

    '$INCLUDE:'General.bi'
    '$INCLUDE:'Mouse.bi'

    ' ===========================================================================
    ' MenuTitleType stores information about each menu's title, and the left and
    ' right margins of the actual pull down menus.
    ' ===========================================================================
    TYPE MenuTitleType
        text AS STRING * 15 'Menu title's text
        state AS LONG 'Menu's state  -1 empty, 0 disabled, 1 enabled
        lowestRow AS LONG 'lowest row of the menu
        rColItem AS LONG 'Right hand side of the menu
        lColItem AS LONG
        rColTitle AS LONG
        lColTitle AS LONG
        itemLength AS LONG
        accessKey AS LONG
    END TYPE

    ' ===========================================================================
    ' MenuItemType stores information about menu items
    ' ===========================================================================
    TYPE MenuItemType '(GloItem)
        text AS STRING * 30
        state AS LONG
        index AS LONG
        row AS LONG
        accessKey AS LONG
    END TYPE

    ' ===========================================================================
    ' MenuMiscType stores information about menu color attributes, current menu,
    ' previous menu, and an assortment of other miscellaneous information
    ' ===========================================================================
    TYPE MenuMiscType '(GloStorage)
        lastMenu AS LONG
        lastItem AS LONG
        currMenu AS LONG
        currItem AS LONG

        MenuOn AS LONG
        altKeyReset AS LONG
        menuIndex AS STRING * 160
        shortcutKeyIndex AS STRING * 100

        fore AS LONG
        back AS LONG
        highlight AS LONG
        disabled AS LONG
        cursorFore AS LONG
        cursorBack AS LONG
        cursorHi AS LONG
    END TYPE

    ' ===========================================================================
    ' GLOBAL VARIABLES
    ' ===========================================================================

    DIM SHARED GloMenu AS MenuMiscType
    REDIM SHARED GloTitle(0 TO 0) AS MenuTitleType
    REDIM SHARED GloItem(0 TO 0, 0 TO 0) AS MenuItemType

$END IF
