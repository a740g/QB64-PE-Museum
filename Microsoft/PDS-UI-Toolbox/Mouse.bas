'============================================================================
'
'    MOUSE.BAS - Mouse Support Routines for the User Interface Toolbox in
'           Microsoft BASIC 7.1, Professional Development System
'              Copyright (C) 1987-1990, Microsoft Corporation
'                   Copyright (C) 2023 Samuel Gomes
'
' NOTE:     This sample source code toolbox is intended to demonstrate some
'           of the extended capabilities of Microsoft BASIC 7.1 Professional
'           Development system that can help to leverage the professional
'           developer's time more effectively.  While you are free to use,
'           modify, or distribute the routines in this module in any way you
'           find useful, it should be noted that these are examples only and
'           should not be relied upon as a fully-tested "add-on" library.
'
'  PURPOSE: These routines are required for mouse support in the user
'           interface toolbox, but they may be used independently as well.
'
'  For information on creating a library and QuickLib from the routines
'  contained in this file, read the comment header of GENERAL.BAS.
'
'============================================================================

$INCLUDEONCE

'$INCLUDE:'Mouse.bi'

' =======================================================================
' Mouse driver's initialization routine
' =======================================================================
SUB MouseInit
    SHARED MousePrivate AS MousePrivateType

    MousePrivate.bL = 1
    MousePrivate.bT = 1
    MousePrivate.bR = _WIDTH
    MousePrivate.bB = _HEIGHT
END SUB


' =======================================================================
' Sets max and min bounds on mouse movement both vertically, and
' horizontally
' =======================================================================
SUB MouseBorder (row1 AS LONG, col1 AS LONG, row2 AS LONG, col2 AS LONG)
    SHARED MousePrivate AS MousePrivateType

    MousePrivate.bL = col1
    MousePrivate.bT = row1
    MousePrivate.bR = col2
    MousePrivate.bB = row2
END SUB


' =======================================================================
' Polls mouse driver, then sets parms correctly
' =======================================================================
SUB MousePoll (row AS LONG, col AS LONG, lButton AS LONG, rButton AS LONG)
    SHARED MousePrivate AS MousePrivateType

    WHILE _MOUSEINPUT
    WEND

    lButton = _MOUSEBUTTON(1)
    rButton = _MOUSEBUTTON(2)

    row = _MOUSEY
    col = _MOUSEX

    IF row < MousePrivate.bT THEN row = MousePrivate.bT
    IF row > MousePrivate.bB THEN row = MousePrivate.bB
    IF col < MousePrivate.bL THEN col = MousePrivate.bL
    IF col > MousePrivate.bR THEN col = MousePrivate.bR

END SUB

'$INCLUDE:'General.bas'
