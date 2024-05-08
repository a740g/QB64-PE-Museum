'============
'XE.BAS v1.14
'============
'A simple File editor/viewer.
'Coded by Dav, SEP/2023 with QB64-PE v3.8.0
'
' * ADDED: Now loads internal FONT resource from string memory.
'          No longer need to Extract/KILL a seperate font file on the OS.
' * FIXED: Changed _OPENFILEDIALOG to work in MacOS (thanks, grymmjack).
'
'==========================================================================
'* * * *          USE THIS PROGRAM AT YOUR OWN RISK ONLY!!          * * * *
'==========================================================================
'
'
' ABOUT:
' ~~~~~
'
' XE is a simple Binary File Editor (also called a HEX editor) that lets
' you view and edit raw data bytes of a file.  With XE you can peek inside
' EXE/DLL files and see what information they may contain.  XE also has the
' capacity to change bytes by either typing in ASCII characters or entering
' the HEX value for each byte.  XE was first coded in Qbasic - now in QB64.
'
' Since the very nature of XE is to alter file data you should always use
' EXTREME caution when editing any file - AND ALWAYS MAKE A BACKUP FIRST!
'
'==========================================================================
'
' HOW TO USE:
' ~~~~~~~~~~
'
' XE accepts command line arguments.  You can drag/drop a file onto XE.
' If you don't specify a filename on startup, XE will ask you for one.
'
' There are TWO ways to View & Edit files - in HEX (default) or ASCII mode.
'
' Files are first opened in HEX mode displaying 2 windows of data.  The
' right window shows the charaters while the larger left window shows HEX
' values for them. HEX mode is best for patching and is the only way to
' edit the HEX values of bytes.
'
'
' Pressing ENTER switches to ASCII (non-HEX) mode, showing a larger page
' of raw data bytes - the ASCII chracter data only.  This mode is best for
' skimming through files faster.  ENTER toggles view modes back and forth.
'
' While viewing a file you can browse through the file using the ARROWS,
' PAGEUP/DOWN, HOME and the END keys.
'
' The currently opened filename is shown with full path in the title bar.
' and just filename is displayed in the FILE: area just below title bar.
'
' While viewing a file, press E to enter into EDIT mode and begin editing
' bytes at the current position. If you're in HEX mode (2 windows), you can
' edit bytes either by typing characters on the right side or entering HEX
' values on the left window.  Press TAB to switch windows to edit in.
' Press ESC to save or disgard changes and to exit editing mode.
'
' Press M for a complete MENU listing all of the Key COMMANDS.
'
'==========================================================================
'
' COMMAND:
' ~~~~~~~~
'
'         E  =  Enters EDIT MODE. Only the displayed bytes can be edited.
'
'       TAB  =  Switchs panes (the cursor) while editing in HEX mode.
'
'         S  =  Searches file for a string starting at the current byte.
'               A Match-Case option is available.  A high beep alerts you
'               when match is found. A Low beep sounds when EOF reached.
'
'         N  =  Finds NEXT Match after a do a string search.
'
'         F  =  Toggles FILTERING of all non-standard-text characters.
'               A flashing "F" is at the top-left corner when FILTER ON.
'
'         G  =  GOTO a certain byte position (number) in the file.
'
'         L  =  GOTO a specified location (Hex value) of the file.
'
'     ENTER  =  Toggles HEX and ASCII view modes.  The ASCII mode lets
'               you browse more data per page.  You can EDIT in both
'               modes but can only enter in HEX vaules in HEX mode.
'
'       ESC  =  EXITS out of editing mode, and also EXITS the program.
'
' ALT+ENTER  =  Toggle FULLSCREEN/WINDOWED mode of the XE program.
'
'==========================================================================
'==========================================================================


'==========================================================================
'SETUP SCREEN MODE
'=================

SCREEN Pete: WIDTH 80, 25 'Use Screen mode 0, aka the Pete (Come back Pete!)

'Font size based on desktop resolution - it expands SCREEN 0 nicely.
'You may have to adjust it a bit to look the best on your screen res
BIGFONT (INT(_DESKTOPHEIGHT / 25) * .85)

_DELAY .25 'Be sure window exists before calling _TITLE
_CONTROLCHR OFF 'Printing all 255 characters on screen, so this is needed.

_TITLE "XE v1.14" 'Everything has a name


'==========================================================================
'LOAD FILE
'=========


PRINT "XE v1.14 - Binary file editor."
PRINT

IF COMMAND$ = "" THEN
    PRINT "Selecting file..."
    File$ = _OPENFILEDIALOG$("Select File for XE to Open...", , , "Files", 0)
    IF File$ = "" THEN
        PRINT "ERROR: No file selected."
        SYSTEM
    END IF
ELSE
    File$ = COMMAND$
    IF _FILEEXISTS(File$) = 0 THEN
        PRINT File$; " not found!"
        END
    END IF
END IF

File$ = LTRIM$(RTRIM$(File$)) 'trim off any spaces, if any...
FullFileName$ = File$ 'make a copy For TITLE/OPEN to use...

'If filename+path too long for display, strip off path
IF LEN(File$) > 70 THEN
    ts$ = ""
    FOR q = LEN(File$) TO 1 STEP -1
        t$ = MID$(File$, q, 1)
        IF t$ = "/" OR t$ = "\" THEN EXIT FOR
        ts$ = t$ + ts$
    NEXT
    File$ = ts$
    'If filename too long, shorten it for display
    IF LEN(File$) > 70 THEN
        File$ = MID$(File$, 1, 67) + "..."
    END IF
END IF

'==========================================================================
'OPEN FILE
'=========

OPEN FullFileName$ FOR BINARY AS 7

_TITLE "XE: " + FullFileName$

DisplayView% = 1 'Default to 2-PANE view

ByteLocation& = 1
IF DisplayView% = 1 THEN
    BufferSize% = (16 * 23)
ELSE
    BufferSize% = (79 * 23)
END IF
IF BufferSize% > LOF(7) THEN BufferSize% = LOF(7)


'==========================================================================
'DISPLAY FILE
'============

COLOR 15, 1: CLS: LOCATE 1, 1, 0

DO
    SEEK #7, ByteLocation&

    PageOfData$ = INPUT$(BufferSize%, 7)

    'If dual pane mode....
    IF DisplayView% = 1 THEN
        IF LEN(PageOfData$) < (16 * 23) THEN
            PageFlag% = 1: PageLimit% = LEN(PageOfData$)
            PageOfData$ = PageOfData$ + STRING$(16 * 23 - LEN(PageOfData$), CHR$(0))
        END IF
        'show right side
        y% = 3: x% = 63
        FOR c% = 1 TO LEN(PageOfData$)
            CurrentByte% = ASC(MID$(PageOfData$, c%, 1))
            'show a . instead of a null (looks better to me)
            IF CurrentByte% = 0 THEN CurrentByte% = 46
            IF Filter% = 1 THEN
                SELECT CASE CurrentByte%
                    CASE 0 TO 31, 123 TO 255: CurrentByte% = 32
                END SELECT
            END IF
            LOCATE y%, x%: PRINT CHR$(CurrentByte%);
            x% = x% + 1: IF x% = 79 THEN x% = 63: y% = y% + 1
        NEXT
        'show left side
        y% = 3: x% = 15
        FOR c% = 1 TO LEN(PageOfData$)
            CurrentByte% = ASC(MID$(PageOfData$, c%, 1))
            CurrentByte$ = HEX$(CurrentByte%): IF LEN(CurrentByte$) = 1 THEN CurrentByte$ = "0" + CurrentByte$
            LOCATE y%, x%: PRINT CurrentByte$; " ";
            x% = x% + 3: IF x% >= 62 THEN x% = 15: y% = y% + 1
        NEXT
    ELSE
        'One page display, Full view
        'Adjust data size used
        IF LEN(PageOfData$) < (79 * 23) THEN 'Enough to fill screen?
            PageFlag% = 1: PageLimit% = LEN(PageOfData$) 'No? Mark this and pad
            PageOfData$ = PageOfData$ + SPACE$(79 * 23 - LEN(PageOfData$)) 'data with spaces.
        END IF
        y% = 3: x% = 1 'Screen location where data begins displaying
        FOR c% = 1 TO LEN(PageOfData$) 'Show all the bytes.
            CurrentByte% = ASC(MID$(PageOfData$, c%, 1)) 'Check the ASCII value.
            IF Filter% = 1 THEN 'If Filter is turned on,
                SELECT CASE CurrentByte% 'changes these values to spaces
                    CASE 0 TO 32, 123 TO 255: CurrentByte% = 32
                END SELECT
            END IF
            LOCATE y%, x%: PRINT CHR$(CurrentByte%);
            'This line calculates when to go to next row.
            x% = x% + 1: IF x% = 80 THEN x% = 1: y% = y% + 1
        NEXT
    END IF

    GOSUB DrawTopBar 'update viewing info at top

    'Get user input
    DO

        DO UNTIL L$ <> "": L$ = INKEY$: LOOP
        K$ = L$: L$ = ""

        GOSUB DrawTopBar
        SELECT CASE UCASE$(K$)
            CASE CHR$(27): EXIT DO
            CASE "M": GOSUB Menu:
            CASE "N"
                IF s$ <> "" THEN
                    GOSUB Search
                    GOSUB DrawTopBar
                END IF
            CASE "E"
                IF DisplayView% = 1 THEN
                    GOSUB EditRightSide
                ELSE
                    GOSUB EditFullView
                END IF
                GOSUB DrawTopBar
            CASE "F"
                IF Filter% = 0 THEN Filter% = 1 ELSE Filter% = 0
            CASE "G"
                LOCATE 1, 1: PRINT STRING$(80 * 3, 32);
                LOCATE 1, 3: PRINT "TOTAL BYTES>"; LOF(7)
                INPUT "  GOTO BYTE# > ", GotoByte$
                IF GotoByte$ <> "" THEN
                    TMP$ = ""
                    FOR m% = 1 TO LEN(GotoByte$)
                        G$ = MID$(GotoByte$, m%, 1) 'to numerical vales
                        SELECT CASE ASC(G$)
                            CASE 48 TO 57: TMP$ = TMP$ + G$
                        END SELECT
                    NEXT: GotoByte$ = TMP$
                    IF VAL(GotoByte$) < 1 THEN GotoByte$ = "1"
                    IF VAL(GotoByte$) > LOF(7) THEN GotoByte$ = STR$(LOF(7))
                    IF GotoByte$ <> "" THEN ByteLocation& = 0 + VAL(GotoByte$)
                END IF
            CASE "L"
                LOCATE 1, 1: PRINT STRING$(80 * 3, 32);
                LOCATE 1, 3: 'PRINT "TOTAL BYTES>"; LOF(7)
                INPUT "  GOTO HEX LOCATION-> ", GotoByte$
                IF GotoByte$ <> "" THEN
                    GotoByte$ = "&H" + GotoByte$
                    IF VAL(GotoByte$) < 1 THEN GotoByte$ = "1"
                    IF VAL(GotoByte$) > LOF(7) THEN GotoByte$ = STR$(LOF(7))
                    IF GotoByte$ <> "" THEN ByteLocation& = 0 + VAL(GotoByte$)
                END IF
            CASE "S": s$ = ""
                LOCATE 1, 1: PRINT STRING$(80 * 3, 32);
                LOCATE 1, 3: INPUT "Search for> ", s$
                IF s$ <> "" THEN
                    PRINT "  CASE sensitive (Y/N)? ";
                    I$ = INPUT$(1): I$ = UCASE$(I$)
                    IF I$ = "Y" THEN CaseOn% = 1 ELSE CaseOn% = 0
                    GOSUB Search
                END IF
                GOSUB DrawTopBar
            CASE CHR$(13)
                IF DisplayView% = 1 THEN
                    DisplayView% = 0
                    BufferSize% = (79 * 23)
                ELSE
                    DisplayView% = 1
                    BufferSize% = (16 * 23)
                END IF
                GOSUB DrawTopBar
            CASE CHR$(0) + CHR$(72)
                IF DisplayView% = 1 THEN
                    IF ByteLocation& > 15 THEN ByteLocation& = ByteLocation& - 16
                ELSE
                    IF ByteLocation& > 78 THEN ByteLocation& = ByteLocation& - 79
                END IF
            CASE CHR$(0) + CHR$(80)
                IF DisplayView% = 1 THEN
                    IF ByteLocation& < LOF(7) - 15 THEN ByteLocation& = ByteLocation& + 16
                ELSE
                    IF ByteLocation& < LOF(7) - 78 THEN ByteLocation& = ByteLocation& + 79
                END IF
            CASE CHR$(0) + CHR$(73): ByteLocation& = ByteLocation& - BufferSize%: IF ByteLocation& < 1 THEN ByteLocation& = 1
            CASE CHR$(0) + CHR$(81): IF ByteLocation& < LOF(7) - BufferSize% THEN ByteLocation& = ByteLocation& + BufferSize%
            CASE CHR$(0) + CHR$(71): ByteLocation& = 1
            CASE CHR$(0) + CHR$(79): IF NOT EOF(7) THEN ByteLocation& = LOF(7) - BufferSize%
        END SELECT
    LOOP UNTIL K$ <> ""
LOOP UNTIL K$ = CHR$(27)

CLOSE 7

SYSTEM

'==========================================================================
'                              GOSUB ROUTINES
'==========================================================================


'==========================================================================
Search:
'======

IF NOT EOF(7) THEN
    DO
        B$ = INPUT$(BufferSize%, 7): ByteLocation& = ByteLocation& + BufferSize%
        IF CaseOn% = 0 THEN B$ = UCASE$(B$): s$ = UCASE$(s$)
        d$ = INKEY$: IF d$ <> "" THEN EXIT DO
        IF INSTR(1, B$, s$) THEN SOUND 4000, .5: EXIT DO
    LOOP UNTIL INSTR(1, B$, s$) OR EOF(7)
    IF EOF(7) THEN SOUND 2000, 1: SOUND 1000, 1
    ByteLocation& = ByteLocation& - LEN(s$)
END IF
RETURN


'==========================================================================
EditRightSide: 'Editing Right side info in dual pane mode
'============

Pane% = 1

x% = 63: IF rightx% THEN y% = CSRLIN ELSE y% = 3
leftx% = 15

test% = POS(0)

IF test% = 15 OR test% = 16 THEN x% = 63: leftx% = 15
IF test% = 18 OR test% = 19 THEN x% = 64: leftx% = 18
IF test% = 21 OR test% = 22 THEN x% = 65: leftx% = 21
IF test% = 24 OR test% = 25 THEN x% = 66: leftx% = 24
IF test% = 27 OR test% = 28 THEN x% = 67: leftx% = 27
IF test% = 30 OR test% = 31 THEN x% = 68: leftx% = 30
IF test% = 33 OR test% = 34 THEN x% = 69: leftx% = 33
IF test% = 36 OR test% = 37 THEN x% = 70: leftx% = 36
IF test% = 39 OR test% = 40 THEN x% = 71: leftx% = 39
IF test% = 42 OR test% = 43 THEN x% = 72: leftx% = 42
IF test% = 45 OR test% = 46 THEN x% = 73: leftx% = 45
IF test% = 48 OR test% = 49 THEN x% = 74: leftx% = 48
IF test% = 51 OR test% = 52 THEN x% = 75: leftx% = 51
IF test% = 54 OR test% = 55 THEN x% = 76: leftx% = 54
IF test% = 57 OR test% = 58 THEN x% = 77: leftx% = 57
IF test% = 60 OR test% = 61 THEN x% = 78: leftx% = 60

GOSUB DrawEditBar:

LOCATE y%, x%, 1, 1, 30

DO
    DO
        E$ = INKEY$
        IF E$ <> "" THEN
            SELECT CASE E$
                CASE CHR$(9)
                    IF Pane% = 1 THEN
                        Pane% = 2: GOTO EditLeftSide
                    ELSE
                        Pane% = 1: GOTO EditRightSide
                    END IF
                CASE CHR$(27): EXIT DO
                CASE CHR$(0) + CHR$(72): IF y% > 3 THEN y% = y% - 1
                CASE CHR$(0) + CHR$(80): IF y% < 25 THEN y% = y% + 1
                CASE CHR$(0) + CHR$(75): IF x% > 63 THEN x% = x% - 1: leftx% = leftx% - 3
                CASE CHR$(0) + CHR$(77): IF x% < 78 THEN x% = x% + 1: leftx% = leftx% + 3
                CASE CHR$(0) + CHR$(73), CHR$(0) + CHR$(71): y% = 3
                CASE CHR$(0) + CHR$(81), CHR$(0) + CHR$(79): y% = 25
                CASE ELSE
                    IF (ByteLocation& + ((y% - 3) * 16 + x% - 1) - 62) <= LOF(7) AND E$ <> CHR$(8) THEN
                        changes% = 1
                        'new color for changed bytes...
                        COLOR 1, 15: LOCATE y%, x%: PRINT " ";
                        LOCATE y%, leftx%
                        CurrentByte$ = HEX$(ASC(E$)): IF LEN(CurrentByte$) = 1 THEN CurrentByte$ = "0" + CurrentByte$
                        PRINT CurrentByte$;
                        LOCATE y%, x%: PRINT E$;
                        MID$(PageOfData$, ((y% - 3) * 16 + x% * 1) - 62) = E$
                        IF x% < 78 THEN x% = x% + 1: leftx% = leftx% + 3 'skip space
                    END IF
            END SELECT
        END IF
    LOOP UNTIL E$ <> ""
    LOCATE y%, x%
LOOP UNTIL E$ = CHR$(27)

'==========================================================================
SaveChanges:
'===========

IF changes% = 1 THEN
    SOUND 4500, .2: COLOR 15, 4: LOCATE , , 0
    LOCATE 10, 29: PRINT CHR$(201); STRING$(21, 205); CHR$(187);
    LOCATE 11, 29: PRINT CHR$(186); " Save Changes (Y/N)? "; CHR$(186);
    LOCATE 12, 29: PRINT CHR$(200); STRING$(21, 205); CHR$(188);
    N$ = INPUT$(1): COLOR 15, 1
    IF UCASE$(N$) = "Y" THEN
        IF PageFlag% = 1 THEN PageOfData$ = LEFT$(PageOfData$, PageLimit%)
        PUT #7, ByteLocation&, PageOfData$:
    END IF
END IF
COLOR 15, 1: CLS: LOCATE 1, 1, 0
RETURN


'==========================================================================
EditLeftSide: 'Editing Left side info in dual pane mode
'===========

COLOR 1, 7
x% = 15: 'y% = 3
rightx% = 63

test% = POS(0)
IF test% = 63 THEN x% = 15: rightx% = 63
IF test% = 64 THEN x% = 18: rightx% = 64
IF test% = 65 THEN x% = 21: rightx% = 65
IF test% = 66 THEN x% = 24: rightx% = 66
IF test% = 67 THEN x% = 27: rightx% = 67
IF test% = 68 THEN x% = 30: rightx% = 68
IF test% = 69 THEN x% = 33: rightx% = 69
IF test% = 70 THEN x% = 36: rightx% = 70
IF test% = 71 THEN x% = 39: rightx% = 71
IF test% = 72 THEN x% = 42: rightx% = 72
IF test% = 73 THEN x% = 45: rightx% = 73
IF test% = 74 THEN x% = 48: rightx% = 74
IF test% = 75 THEN x% = 51: rightx% = 75
IF test% = 76 THEN x% = 54: rightx% = 76
IF test% = 77 THEN x% = 57: rightx% = 77
IF test% = 78 THEN x% = 60: rightx% = 78

GOSUB DrawEditBar:

LOCATE y%, x%, 1, 1, 30

DO
    DO
        E$ = INKEY$
        IF E$ <> "" THEN
            SELECT CASE E$
                CASE CHR$(9)
                    IF Pane% = 1 THEN
                        Pane% = 2: GOTO EditLeftSide
                    ELSE
                        Pane% = 1: GOTO EditRightSide
                    END IF
                CASE CHR$(27): EXIT DO
                CASE CHR$(0) + CHR$(72): IF y% > 3 THEN y% = y% - 1
                CASE CHR$(0) + CHR$(80): IF y% < 25 THEN y% = y% + 1
                CASE CHR$(0) + CHR$(75) 'right arrow....
                    IF x% > 15 THEN
                        SELECT CASE x%
                            CASE 17, 18, 20, 21, 23, 24, 26, 27, 29, 30, 32, 33, 35, 36, 38, 39, 41, 42, 44, 45, 47, 48, 50, 51, 53, 54, 56, 57, 59, 60, 62, 63
                                x% = x% - 2
                                rightx% = rightx% - 1
                            CASE ELSE: x% = x% - 1
                        END SELECT
                    END IF

                CASE CHR$(0) + CHR$(77)
                    IF x% < 61 THEN
                        SELECT CASE x%
                            CASE 16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 46, 47, 49, 50, 52, 53, 55, 56, 58, 59, 61, 62
                                x% = x% + 2
                                rightx% = rightx% + 1
                            CASE ELSE: x% = x% + 1
                        END SELECT
                    END IF

                CASE CHR$(0) + CHR$(73), CHR$(0) + CHR$(71): y% = 3
                CASE CHR$(0) + CHR$(81), CHR$(0) + CHR$(79): y% = 25
                CASE ELSE
                    IF (ByteLocation& + ((y% - 3) * 16 + rightx% - 1) - 62) <= LOF(7) AND E$ <> CHR$(8) THEN
                        SELECT CASE UCASE$(E$)
                            CASE "A", "B", "C", "D", "E", "F", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
                                E$ = UCASE$(E$)
                                changes% = 1
                                COLOR 1, 15: LOCATE y%, x%: PRINT " ";
                                LOCATE y%, x%: PRINT E$;
                                IF x% < 62 THEN

                                    SELECT CASE x%
                                        CASE 16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 46, 47, 49, 50, 52, 53, 55, 56, 58, 59, 61, 62
                                            e2$ = CHR$(VAL("&H" + CHR$(SCREEN(y%, x% - 1)) + CHR$(SCREEN(y%, x%))))
                                            'reflect changes on right panel
                                            COLOR 1, 15: LOCATE y%, rightx%: PRINT " ";
                                            LOCATE y%, rightx%: PRINT e2$;
                                            MID$(PageOfData$, ((y% - 3) * 16 + rightx% * 1) - 62) = e2$
                                            'dont advance cursor if at last place
                                            IF x% < 61 THEN
                                                rightx% = rightx% + 1
                                                x% = x% + 2
                                            END IF
                                        CASE ELSE: x% = x% + 1
                                    END SELECT
                                END IF
                        END SELECT

                    END IF
            END SELECT
        END IF
    LOOP UNTIL E$ <> ""
    LOCATE y%, x%
LOOP UNTIL E$ = CHR$(27)

GOTO SaveChanges:


'==========================================================================
EditFullView: 'Editing file in full display mode (one pane)
'===========

COLOR 1, 7
x% = 1: y% = 3
changes% = 0

GOSUB DrawEditBar

LOCATE 3, 1, 1, 1, 30

DO
    DO
        E$ = INKEY$
        IF E$ <> "" THEN
            SELECT CASE E$
                CASE CHR$(27): EXIT DO
                CASE CHR$(0) + CHR$(72): IF y% > 3 THEN y% = y% - 1
                CASE CHR$(0) + CHR$(80): IF y% < 25 THEN y% = y% + 1
                CASE CHR$(0) + CHR$(75): IF x% > 1 THEN x% = x% - 1
                CASE CHR$(0) + CHR$(77): IF x% < 79 THEN x% = x% + 1
                CASE CHR$(0) + CHR$(73), CHR$(0) + CHR$(71): y% = 3
                CASE CHR$(0) + CHR$(81), CHR$(0) + CHR$(79): y% = 25
                CASE ELSE
                    IF (ByteLocation& + (y% - 3) * 79 + x% - 1) <= LOF(7) AND E$ <> CHR$(8) THEN
                        changes% = 1
                        'new color for changed bytes
                        COLOR 1, 15: LOCATE y%, x%: PRINT " ";
                        LOCATE y%, x%: PRINT E$;
                        MID$(PageOfData$, (y% - 3) * 79 + x% * 1) = E$
                        IF x% < 79 THEN x% = x% + 1
                    END IF
            END SELECT
        END IF
    LOOP UNTIL E$ <> ""
    GOSUB DrawEditBar
    LOCATE y%, x%
LOOP UNTIL E$ = CHR$(27)

GOTO SaveChanges:

'==========================================================================
DrawEditBar:
'===========

IF DisplayView% = 1 THEN
    LOCATE 1, 1:
    COLOR 31, 4: PRINT "  EDIT MODE: ";
    COLOR 15, 4
    PRINT " Press TAB to switch editing sides "; CHR$(179); " Arrows move cursor "; CHR$(179); " ESC=Exit ";
ELSE
    LOCATE 1, 1
    COLOR 31, 4: PRINT " EDIT MODE ";
    COLOR 15, 4
    PRINT CHR$(179); " Arrows move cursor "; CHR$(179); " ESC=Exit "; CHR$(179);
    LOCATE 1, 45: PRINT STRING$(35, " ");

    LOCATE 1, 46
    CurrentByte& = ByteLocation& + (y% - 3) * 79 + x% - 1
    CurrentValue% = ASC(MID$(PageOfData$, (y% - 3) * 79 + x% * 1, 1))
    IF CurrentByte& > LOF(7) THEN
        PRINT SPACE$(9); "PAST END OF FILE";
    ELSE
        PRINT "Byte:"; LTRIM$(STR$(CurrentByte&));
        PRINT ", ASC:"; LTRIM$(STR$(CurrentValue%));
        PRINT ", HEX:"; RTRIM$(HEX$(CurrentValue%));
    END IF
END IF
RETURN

'==========================================================================
DrawTopBar:
'============

COLOR 1, 15
LOCATE 1, 1: PRINT STRING$(80, 32);
LOCATE 2, 1: PRINT STRING$(80, 32);

LOCATE 1, 1
IF Filter% = 1 THEN
    COLOR 30, 4: PRINT "F";: COLOR 1, 15
ELSE
    PRINT " ";
END IF

PRINT "FILE: "; File$;

LOCATE 2, 2:
PRINT "Total Bytes:"; LOF(7);
EC& = ByteLocation& + BufferSize%: IF EC& > LOF(7) THEN EC& = LOF(7)
PRINT CHR$(179); " Viewing Bytes:"; RTRIM$(STR$(ByteLocation&)); "-"; LTRIM$(STR$(EC&));
LOCATE 1, 71: PRINT " M = Menu";
COLOR 15, 1
'Draw bar on right side of screen
FOR d% = 3 TO 25
    LOCATE d%, 80: PRINT CHR$(176);
NEXT

IF DisplayView% = 1 THEN
    'Draw lines down screen
    FOR d% = 3 TO 25
        LOCATE d%, 79: PRINT CHR$(179);
        LOCATE d%, 62: PRINT CHR$(179);
        'add space around numbers...
        '(full screen messes it...)
        LOCATE d%, 13: PRINT " " + CHR$(179);
        LOCATE d%, 1: PRINT CHR$(179) + " ";
    NEXT

    'Draw location
    FOR d% = 3 TO 25
        LOCATE d%, 3
        nm$ = HEX$(ByteLocation& - 32 + (d% * 16))
        IF LEN(nm$) = 9 THEN nm$ = "0" + nm$
        IF LEN(nm$) = 8 THEN nm$ = "00" + nm$
        IF LEN(nm$) = 7 THEN nm$ = "000" + nm$
        IF LEN(nm$) = 6 THEN nm$ = "0000" + nm$
        IF LEN(nm$) = 5 THEN nm$ = "00000" + nm$
        IF LEN(nm$) = 4 THEN nm$ = "000000" + nm$
        IF LEN(nm$) = 3 THEN nm$ = "0000000" + nm$
        IF LEN(nm$) = 2 THEN nm$ = "00000000" + nm$
        IF LEN(nm$) = 1 THEN nm$ = "000000000" + nm$
        PRINT nm$;
    NEXT
END IF

Marker% = CINT(ByteLocation& / LOF(7) * 22)
LOCATE Marker% + 3, 80: PRINT CHR$(178);
RETURN

'==========================================================================
Menu:
'========

SOUND 4500, .2: COLOR 15, 0: LOCATE , , 0
LOCATE 5, 24: PRINT CHR$(201); STRING$(34, 205); CHR$(187);
FOR m = 6 TO 20
    LOCATE m, 24: PRINT CHR$(186); SPACE$(34); CHR$(186);
NEXT
LOCATE 21, 24: PRINT CHR$(200); STRING$(34, 205); CHR$(188);

LOCATE 6, 26: PRINT "Use the arrow keys, page up/down";
LOCATE 7, 26: PRINT "and Home/End keys to navigate.";
LOCATE 9, 26: PRINT "E = Enter into file editing mode";
LOCATE 10, 26: PRINT "F = Toggles the filter ON or OFF";
LOCATE 11, 26: PRINT "G = Goto a certain byte position";
LOCATE 12, 26: PRINT "L = Goto a certain HEX location";
LOCATE 13, 26: PRINT "S = Searches for string in file";
LOCATE 14, 26: PRINT "N = Find next match after search";
LOCATE 16, 26: PRINT "ENTER = Toggle HEX/ASCII modes";
LOCATE 17, 26: PRINT "TAB   = switch window (HEX mode)";
LOCATE 18, 26: PRINT "ESC   = EXITS this program";
LOCATE 20, 26: PRINT "ALT+ENTER for full screen window";
Pause$ = INPUT$(1)
COLOR 15, 1: CLS: LOCATE 1, 1, 0
RETURN


'==========================================================================
'                           FUNCTIONS/SUBS
'==========================================================================


SUB BIGFONT (size)
    'loads a custom size CP437 font (like QB64's built-in one)'
    'You can make/use any size now.
    A$ = ""
    A$ = A$ + "haIgm]0MLEMMXkS^ST\\T]lHiaboe<Nl8c71HYa3f0VPiWa9H07n5a_0bn:K"
    A$ = A$ + ";#FB8;c773hBD8T42E_#C:=QBC39PSQB=DB2UhdhVBB^9=_D2EQ#Ala?JFmi"
    A$ = A$ + "ejeGKNiYTV4\UNkOWcmL791Y0Iefg<NdmNWiLfWmIoO_?WkeP10H6`NP0HS["
    A$ = A$ + "KMGj5l9Nf7lH0HC;3of5MAGb9ef>>V6V60Vfa[_^=_m>j[Y]NOC7PDY`?kKc"
    A$ = A$ + "gd0IQB1o20VfnaO?eFkH7m=nh8TP=]8ljY]e^_e]DhRj<;0CoG1`5>lfj\S`"
    A$ = A$ + "IOn5Z6o]G6oLbK3oRZONcW6QoL`[Gfffn0gBQ5]P_=NmC3#5__^kMcMlg=[o"
    A$ = A$ + "a=RPjY`[?W]ga]dWICVEPonZafW]W>fNWObWOGk3P[h7POg7[_Nga07oM<8f"
    A$ = A$ + "f[2agZnF0=g`?kjkmmOT[]nel;PVZJ]hg0?OKcLadaGiKoLOB06[_P\Y8lOJ"
    A$ = A$ + "#5Pl2kCZm?FO04TU^4o[1Bn:5m=VLhOH8jj9mj4UF4Te<4D9R7[U6eP\fS#H"
    A$ = A$ + "5]c]X6G?2l1mUORGl9Rl3CcgPP3Yf?27leNXQi017VViP9PXlI5<D`Bg[8lC"
    A$ = A$ + "8OFXkk2MW7jMNL?lKIT21l_VF:3>F2D;LOV8TRaP9n:<aIA^f=aF7iJaK2<#"
    A$ = A$ + "L8<Ak3Q9<_mJcKe[TDPTc\936fA:ngRlXaf?Q:5<^GQ:NaoU>Jo437Vj6iV1"
    A$ = A$ + "CjiCm;DJYL^oDO^mEPnIARTN`G4_b`GW:h^aS?8:nE5\4h>P72nB`S0?6lT`"
    A$ = A$ + "G3n6`g4n^`g3nA`;PJd_>l_2S2oK`APa=OZPk;hn3NXP7>h;7l41OUP36l\1"
    A$ = A$ + "OW\;=kJbN7IOTLOjLkMY;HY=]dSMY[OYM\d>cGAnIU?G1X#55Z[`\:<W2c[`"
    A$ = A$ + "R:\\2]DHU5FCQ^;\W23Fh^;L?5^_2On2?FQW\`cDh05Nf2o]5n7JN==_fV?["
    A$ = A$ + "V_^VgLcKYiK0]l#_nl<n]?Ho`G1N64oNF7nmJ`?5no0oBhG?1lkY#lk_a3o6"
    A$ = A$ + "2a_i_dUXhG8SOIW2lKS>lKXb`_G\iCeQOMfleChgho?6o#SoJSo:SoBSoRSo"
    A$ = A$ + "2SoS7o7=nc=ngKl_mh7LloZao6SOPaojSo<SodSglAKnX;mXckXcmXciXchX"
    A$ = A$ + "eNDcA6o8SMX7j#Ol3]n3Uke>UGKi_jGkEOZGmAOe?i[^cGM7_b?iEnn_bGOT"
    A$ = A$ + "GITGNTonAN^An_?bgOT_k87LTobANbANdA^oAn8SLWSL7S\kA^eAfn8KJT[I"
    A$ = A$ + "T;OT;KT;LTe?bJNYGnUn7NYGlUnj_dOi;md_dG1if?hKUTeoQnbPBTY#kYE1"
    A$ = A$ + "ESFZ[1V>D;D7jiJVX]gjQI1YQI3=0c1b0c5J4V7<OH1`2Aig5SB]=QF<c1;5"
    A$ = A$ + "b3;3:0=3;7>6hHQS3>NX5h4#keW4\2XEX=X8\BX4Lb`ZPE3W2LZ`Y1[1>Mhm"
    A$ = A$ + "0W1JUo<Qc2>KhLPc5F7LN`jQg;lnPc7f0L1`52G4\Ahm3G<L9`U2G6Li`70J"
    A$ = A$ + "7^2h:Q[2^JhJP?8L]`e1M0K2f<Zke9\5H[`fP^P[7^1XKHk#?#_#O`=2m3k0"
    A$ = A$ + "60f9LC`=3g2L[`^P?4\KhfPK7ejf3B0Z2o4TZbZZNJe<mJ[K6c\RjWEjIg`L"
    A$ = A$ + "b<g6WglG`2GdRGBCIc]dl;[#c;oH>fSkhKi4>aCJ5]fFaEFjTGeZ?UCmdFcY"
    A$ = A$ + "oN>SeNVWeIO>Wkj>_eoNOOWo6^P;lRfhkoR_T;mb^l?#kGaENEGmel1_f[[S"
    A$ = A$ + "=]i`>gbFgFGGo=dmfkYgn^anga0klV^iKiFge7Jggf]O7kiCoI^ooX?kWk1n"
    A$ = A$ + "CN`?oO:l5nR?lGjAfknnb?jSmWmWohko9PWj_h[lEQ?n7N`kjKO_oa2;k?4N"
    A$ = A$ + "n?a?i5o8X?Fh_6nX3m=N8h?h>oHoXWn73gmo=hgcSeBVBdGon_Ub1Ll68O[5"
    A$ = A$ + "Tn_7d>d?4niViJ>Ec5J^NcmJN6coD5c\REDAgEL?ElHEllElc2VE`E7\]P?E"
    A$ = A$ + "`S5lM2NmD#ZIUJUYf#Z#lmNBMoYNfDoZ:?V:_^:k_bQZlaZliZlWFi_\Z:ZJ"
    A$ = A$ + "VEeFEQE][ZfKE?GEoZZWGe[Yj[^jk^j7_j3Fm;<]:VfLWfI=]]<]kJJ?nd6N"
    A$ = A$ + "JSECfJFG=K[Vk_VmGcgYV3=mY=mU>me>m?hdgedo\Co_Jj_N]cZfFZm\Z=\f"
    A$ = A$ + "k\f7_fOH]7Y^IFg:[KMe]Ujj_^1[K_emm[k`cX^I\RILYcHgch1VaGM63?SO"
    A$ = A$ + "c<Wi<?^I^^I^YINGcLOc<JVobjWKm]Eo6Zoj[ocDoG]nG]naVe\Ve9>[e?[^"
    A$ = A$ + "aggm\NlIm2YQdK8MgYO`d?NjXd_n\[JfIWmJWm5>knVmGHf_D3;ZQef`0=lH"
    A$ = A$ + "=llcYZidfLfdL^WilhcIh<EUIeIj9c3TIhi2cmHVkE>g?nL?hLoI=>k6GISG"
    A$ = A$ + "ISkZamfhcghAVga=_;MNM?_?cl>hlnGVoLWoI=o]=oM=om=oGL1YF`:F#k;h"
    A$ = A$ + ">G`3_P3\PGL1S^`U^`CNQGj2kKQ?h2?`2OQ5ncGDM;J5;jbGdNFdm^Xm]XO`"
    A$ = A$ + "RNi5mcGlBFlZGLhR_g5oT;nK]hGLao;;ng\TY]Ti]TSI9WjBf`B^^U<`B^[U"
    A$ = A$ + "lIGbC]TXUlB;iWeDE=U]YEfdjKjjJjVJjNJjQKj0=ml=m?W=Ef5UmmTmbcfG"
    A$ = A$ + "fk=k3Wm0IOi\obLc<g9VKSij;g3TKOiNjLOWL3WkeGj3^\Y]\WJIO[Um3Gfo"
    A$ = A$ + "DQZ:\T2_W2KZ`]GHO5>DceeljK^_VOPV?HcodUGeb?^U_nUOmXESBXnd[Vjh"
    A$ = A$ + "#k:E3WhCHPCJ=?IeYPog]m4EEi;_VW<X2lDh92X_^Bj[ObZ[bLTelT6jk;V>"
    A$ = A$ + "Gj2iBW[Ti;?fmH>San[CML_a;D:hPP69H#F<>]JAkB#YRUX6W;Mn<i<I:F:4"
    A$ = A$ + "SnK\n27KHc#AAQELPa6nXk=<H`#fYLe^n6`m^1dBf2A[G#Yd5Cg#YLIbW9OY"
    A$ = A$ + "PB5cT;OYR=T?MAC^<iBSOOHXIX`8l_]4B7>jiDAk7M_EdNH#fSL8jkTO1oNj"
    A$ = A$ + ";TQ;U7N:S3=:8\:BXJY6bD4afRU:D\Dn:;U?3RfHog;1N4mYQ31NH82=nLNH"
    A$ = A$ + "i917o06WJF4V`l=8<b`O#Xb_;A_aFc]WA<Yo4DE#``8TQ1REY9BH966lk4`a"
    A$ = A$ + "oU0WhGalR1AJY5K4h#<Td1jE4b4=f`AdTPR9S>1I#]<f`S=L8bUdHR8h<5h3"
    A$ = A$ + "bA`_QaW8QHPCW8T5;H2?KIhPa_EAkHloe2#1J28P9_ID^1J39lFc:9PTQV_9"
    A$ = A$ + "GJS`>`nT9O#FTA49SBE[mGO`:>0gIJn6Bd]:>02OLn^ZHniYkgOQDAH8?Rj5"
    A$ = A$ + ":CTWZ96o5ZH0=7CWWT2CgPRg4KP`678laZf]SS:EZl3>76[D]B;AXVVA]<5E"
    A$ = A$ + "i_CcT>O2^:Q^Af[6[_8ETQc=RVg2LIiHBc#Whi]H9=8[2oV85RAd;jPIdHT?"
    A$ = A$ + ":D08RWSo0\^1Y32\6<2UdjARBPTIJVRb7\43ZG]KFDnXWCH`QYiJE>IV0E;>"
    A$ = A$ + "?6g1#<RUc65`g2bQBRi;QOG63nQd^[4IE4f55ZoQ\E4=FMAR#29HBcND2U^d"
    A$ = A$ + "Z>jYkPdRDKPT0J=]E:eCc1O;<KFj<e6BXbT\o>IM6S5M>jMDLG<S:7OSWBPP"
    A$ = A$ + "AT1IN<\:R`W>_Wn2B4EmGNfa2<j7a#5=a\cUD>n:ISV]W^:\kXNLj6eS2STN"
    A$ = A$ + "IJYR3PDOmXWMhIPa62iHb<=58I3\SXL[P1H[AcJ13NTMSC5478iE#U1Hj#A<"
    A$ = A$ + "n?XEbZ[Kn[ZBUHa\<iiojK=P>R>7\:LT=6QII9IATTSNiHeIWiFM`9LQdi8?"
    A$ = A$ + "n3:V6#lgLYYc7[?V^;dZVNcXkRUZTdnS^g9BnEI1;<A:O39PFndZfN4ImQNQ"
    A$ = A$ + ">M>#imIEZL^eRMXXd5BNn#NU_<K4KgZ1BVSXcNB\hX:NgHkcN6i;_O2nQDn<"
    A$ = A$ + "2GQ\7CmP]dUXSNSIkD=J8o[i#NdXXZ6>oCRCaflcD<1NYc9oGZ]5WnU__\jI"
    A$ = A$ + "]o4n>L\IA782:[mY5On>oMFJM5]K=OQbYH_ZXMKl6=TFmfVVD?bTGlXPLYf9"
    A$ = A$ + "n;iA3=OdG4KcTVMXlMUTgX6HeK3KcT=b#n^B]1TdaVKR]M?XHknd=ZlUBCDi"
    A$ = A$ + ";VVD`:MXl<AfWn3Qd\?EbD>2GIn>nZAlHoF[SX4:6HEndNBK\o1[1MQVCc2;"
    A$ = A$ + "UV2VBXgReMNTHCS3[^=0]6KJ<5T]H`gdF9OSST9IbJLa<iC`KYiADTcU^SA`"
    A$ = A$ + "TC?OK5`L;EOK>;4TVG9U:EB=3aF84KaR^WXB:aN8RBjg8fhKQ?#SX8O6BJn8"
    A$ = A$ + "o3SJd`Z9HlPTNB45H6K3chT=J#R6#WXY]DE;la>A^[U8l\j7Nm=fnOa<fHiR"
    A$ = A$ + "B#6\MFdK2b6[gTGUA4Ga5EI4a6ThQ;:JBRMS\S4YabDN\Bj;=f\XaO0d9N;4"
    A$ = A$ + "M8W#6BCB_ZWBEGf<4B]6UT28M:RbAh:Gk]AaI:nm5`n:`f;6f5nV;WDVlAR3"
    A$ = A$ + "NbL4=DTiHN#>7=T\dMJDJ15U`OJ0AO[dPe>\85hcN4j]8fiI_M6<ObJe7iaF"
    A$ = A$ + "?[LOahCLc[3ChB[YSWF<Mc9Y:_Ao4Rm9:bH[GND3`9[6;kh5gQhgWdS9]HB["
    A$ = A$ + "EQ<>OU8kR8^2ma2eaZ;dZf6JeI3mdWbT8ZKNV9J?5C_lRUD^P6?HTed53FR4"
    A$ = A$ + "bfNBPO=h`_dDjCil`[j`4bZSS7D`941W8n#I;ihT<UBQ#A4H<9:D11KjD\IK"
    A$ = A$ + "CK:9N8aCb^CUY62#^mA2M?h`D_`8B6RW8#IbD^\fR3h=6C:aHC<=fBf]TJMR"
    A$ = A$ + "aGU`nE3fLUbiTB9J]>oHhaad[n64?;RgLl<2HE#eMg<:Zo#a]AJ_\HYXMaVA"
    A$ = A$ + "1a_5gVZI=l<R2>g^Q4S2BhiAabh3Bb]=<1EAG\G9R?e575ORE0>QAV:Xjccf"
    A$ = A$ + "HHlTb`f#IC;I?c6QKaJ;b=n[bUcR6;h4S_f5OLBLXlQ_LJNjHM#EP8GV68_#"
    A$ = A$ + "<b;ncXh]TT\h`oY\2RU]7TcF9>[?j<B6_431DNRlDRR2T869A<D4afBR7;dc"
    A$ = A$ + "b#6eJOjLH2PfL7UiShS:<>h?:<;>=f4bXB=<XXWi<7]BX5Hi1:3?a^6RJ43W"
    A$ = A$ + "LLEVHYWnBCnf?c;XCJ9]fRZ]DK0Haf3Hh7I=M69fU[`3ola>ENOiZmH[DS`l"
    A$ = A$ + "8TC=0S0=Ym>52B6BYe^[Zd2AbI_413IFRVVb<5MA53[6WBHUa3>C4:ncYi3i"
    A$ = A$ + "V2:5CSZ<_0N?J5IDHD^#0UA_TX>Z;9OXFF21=MaB6YiXR6KHbDUIXS<?cXff"
    A$ = A$ + "77G:DXHLa38KZ^DF9RZ?\[GR5gFW1f^LT]L5Te6KAWVLj_TG][>2<UcEE\Hj"
    A$ = A$ + "_6D[Z4A;bJIhPER8V7ZIPH7NGL5afbeL]U8UBcaYVF\QAmk`dhOTi9EAKZjK"
    A$ = A$ + "66kE>ObnJJ19]3YM^2?NAm9[KWc6]emS5SY59fG^_QTJU8];CPCSTT]BX?BF"
    A$ = A$ + "3ULRGM\NClhFTmALJ6>e3[?RQU8HLh#TVhg4\kEVe1JnCYfK]>4iQ;A\_#d?"
    A$ = A$ + "=S?9RWAlY7WQNIIVKmac\A_<`AjDT4CCTV76?k;;ggdiLa\C#B#<>Ll3`DIb"
    A$ = A$ + ">:ZNF^NB9[NR<fAdXAEJPnT#6Flh:FcBW\FYNnbdBL4WlLHIbAR^SlfV=VdO"
    A$ = A$ + "jM`PXIJbSm1`AgEGC;m;^X6IR=ZV?faJ6_8]LJCf8am>9A<Y=`ITJa7;m[TU"
    A$ = A$ + "#cic`N>XTdEc2`KJLZIbK3Jb6U:[OZ\=eOTee]Omb47XNfUZF\;AaLQN29L8"
    A$ = A$ + "REflmWbend_6JnE1[\LoU86\HR`MPb6?f:5Vgg#Al<65Z?blHn0Ua4V3LSCB"
    A$ = A$ + "mUER_ec[eETGL4L>d1I7o18?_I#Z4EK;nkS26d<:2G:7A1DfL4?LHRhfAeB["
    A$ = A$ + "6=m>CAKVZ<?C2NTC8=RmF8QZGWUhV`Vd<dZhTfYgUF[^#;R27ak36DLPe7Y?"
    A$ = A$ + "L8V[kS;aaaTAXHR7NEaEeTlBO`GFNnaEFVm98c3Ej;D[4AXjfSWCTbXjFb>?"
    A$ = A$ + "#L8=ViQ3;RaQ6#b3gjj\XA;RoC6PQZ8\R?];hSHQ[HJ??bJF<FYEE1O8[c:["
    A$ = A$ + "KM2>T6[T?M6>GjLJlnD1YUZ:8n9UdMdBOd774Th9Pn;kd\<O7=hiiTZZ_Fi8"
    A$ = A$ + "5SHC6\gBbN;ijQfhBaeKZVh<>Yn;EKR3HHh8NTYEfj`B]A2YiP]F\D6_B<8D"
    A$ = A$ + "09LMFhj1a>VYBMCZ58;9enSPYd?OiVWV<ole9G`5M:Y^H=naTHS8Y5YKnbQY"
    A$ = A$ + "iJ\JG1;m=;o#S1K]iXk53iQ<PEWW\CeBekTNYN9C79NJR\4C;9e[O_enceca"
    A$ = A$ + "Snb6X^;CCe#8\MW4L5:P;S?^j#R81ijcZg53WBU9K9E<V]1H5]2MhQEb:Z<m"
    A$ = A$ + "g<>In<>INENgYoIS^VC=f[_FOiUVBOiIVJOiClE2ObILfG5m?KV3YSdj7B9\"
    A$ = A$ + "g^LDP6AW;S_bNIY8NTJKcJNT]P8>aa#m_an1anE?Go]d>Okne2WRHVnT`O^c"
    A$ = A$ + "6hKRol:JW\1QSmXJIkB#3K=I=kV#]o\nDBh?ggHD\G\HiS6lSYA[<#9=fV#^"
    A$ = A$ + "d9L`RTL=9FTTnSmOaNeC;?cBCF`YLR4Qc=>VPJDH<bilIi7OQJG=?7m8;gTV"
    A$ = A$ + "5bRc\9Ai>0Yn4D]7TeERFK8^4:Bm9Xf?DIS1;_`e]Em<Ba065:EffEdIWAKe"
    A$ = A$ + "O^4kXVE_EB;S8n[A577W09SI[kOSN[=Z6eA1M1B]l6M=SlFMDYD5U_N0NBMU"
    A$ = A$ + "Bk]N0l2M;QX7<XG<KYfP^^M9[oNJGmF\aSJ3kSeoL:OAnaDP`RigC^[?QPh;"
    A$ = A$ + "bQPiXk=:Y?`j2C4;NC4o>^Rb^J:cI=8eK?:d?PDFF:bFfN]Z5Jl:oWbeg;PZ"
    A$ = A$ + "L6SG1RgB^ZD5IG\82RiHUG<``i1aag>Z4mb`\f197IGC\Uk_ZHan:;<A_WUL"
    A$ = A$ + "f0\cSX9^Q:LB[jJD9[M65YGndELP89V8MmhYO5W3bJBI;[U5o]:;BlflDg]N"
    A$ = A$ + "]IUml#[L]hdBnShH#FdBP`751^89f0cXHl]K`_2ai;[Ff5ejH7ib8P;CU7?P"
    A$ = A$ + "SOn1\[iFVBaFL9cCQjRFAa6X6ZSlfK9_MGOI3Y0BKn0:VMS\f3lRBhT1JWU1"
    A$ = A$ + "ZG\a9b09XR<Z4C9EaP#=7\bT3TEN<^NU4UYQ9\>[5;i4:M[NW_0[_P<SWbJg"
    A$ = A$ + "]1N=e>N_egLBF\TPd5W_aE3obbMBCV\\U#QH^SEWhL3]<DfhEl]LlX8J;U?N"
    A$ = A$ + "5hh8I:KLUUWTLEDGi[PSo`kVcCjj08NFMI8`[LHT\D0Lm5dUTT3<F]gVbIST"
    A$ = A$ + "PCC9bd=^^[dND:CJ]f[N[89]MU4lVR:C:R:7::ER\3cD;FJ8NLf?kGQg3:]j"
    A$ = A$ + "_:DNef=M\RC^Ea[<9K8fJdDUeRL[fWTDH2359Y?c?N\\ikT;]DKW<^Z[Z4U\"
    A$ = A$ + "QFoW4AWcUf^f`8\>Fk^gJb[mKA=F4[]<oZ0[aU`NldjXKmEIAj:Ld8JMjR[n"
    A$ = A$ + "G9N_4`^Z<abGdNhk0AlbHAeOG67>XAIa]UJmiA;HhVOb[bG#IA7hZjGDLL23"
    A$ = A$ + "bdNdn1Ao[c2NkNhSUQ\kF`4i>8b>YcI\[Q0Q\bb0akm#IEK8`OTMCeabOmUL"
    A$ = A$ + "`<A=\88FPRR`:Ic#RfDQl6;D#eb[=[GE2Uh#dXBY<=E97aD3eK]ZfJ5L>b^M"
    A$ = A$ + "d`=`B_CI5:J`I:S\<V\J5ZT#i5]##F?Mjgba`G6HB7S9<4I;g^1?6;o]J<:J"
    A$ = A$ + "cHJRSCXHJNZ6YbFoUhm?jT>J1JTDU?:B0RCf8h9OXFCVjIRcMEYL8cObZQT]"
    A$ = A$ + "DBC1[9In#iWPG<iXFoIRNE<ShGAc\B8HF_:AARi;ISiPaDZnlG\=NgL9Re=f"
    A$ = A$ + "VRHQ;bFcBIg\hfdZ2`mX;DMSb=EE>:M2idb[RT:XVXFBNk]_O;73e[8;Y>aa"
    A$ = A$ + "`Vd\g#X62;3n5Vbi`4TAW`HX2Y9W8^P7PHoOX<:=FcWcDH2SVjm;WQUAm65["
    A$ = A$ + "I<oQP;\QGN#T1H96d<D<Xa1kfP[VEan8`NYk4bS<?]fE^LY#HD313_JMi5_A"
    A$ = A$ + "TK[iX4FZ\GnjmflZZQl7F6<lXR>hHC#CPdPN4]0_m3YVK0_SAE8BD;19JA]V"
    A$ = A$ + "BK:E7Hl];D=7cQ[2E;_<_#EZ[3S^;J4o#\>P]ZEN15bUbZ<o6;LREaZL9o9A"
    A$ = A$ + "XGZ[E\0oK=<CHA^LHj1bF:gfX2cVV:HVDjNb4\C2I6fabd_inSEYi988CPDF"
    A$ = A$ + "[<1`J^0JM12dM:1B7;P`Lij>ZH\nhM3X61]gl[JIel]E[bg3I3NE^BMM55Go"
    A$ = A$ + ":EVk87bF8[Y6VNdOc4PYO=a\J4>Pj3c6]gS3Z?Y4LPThZ[d3^R]M0WLhiHag"
    A$ = A$ + "DNbiejh3>?NF8BWkLgU4E]XY\nd1Bm_B\WKV#=`hk;SBLU0RRgQ<lE9;8Vj8"
    A$ = A$ + "5L[KSToJ6AGd_D9YMefgV3AX=GDDUci2b]_k\cINO1Cf4`hDiEVOh8<BZHmo"
    A$ = A$ + "1I^hKjnA[T6>MVlU]Odd\1RlGl5e7[gjV5_o:U#bciE4UbZf77=]]FSnEl;f"
    A$ = A$ + "4CD\MDkn?eFQ:Y4RFlWi0lFCUe6DcDl6Lf5ACLQ=em8YU^ISl?AfATg8MciU"
    A$ = A$ + "FFWaTk>?c#f[i<Gd=IKMne<foN[YDRJ`J_?7R[iRj\LDOlTZ0Mllo`R_bEIW"
    A$ = A$ + "nB>Ki\Y<RI^9cNf?`#jB`kO_CHIKlNA;D[EHSfm7ZM7]Uc]OA2e]d6KFUn8Y"
    A$ = A$ + "oIaE_jmQfX#kCid2Q#ilaaFPJXd2F;iK<i[eAnhki3RW5C5\[dQoHT>I=EiA"
    A$ = A$ + ";S[4Jai2;[7OPFWV1In#>Y^hLdNfL7ejl#5h]AnZ#G#A^K;4k^NTa<nFgRf4"
    A$ = A$ + "KofNoll>lnH#[5DReDJEj2BYkRF^>JfEeQ9HafGYeY[9MM\8Nkl95liKR_k0"
    A$ = A$ + "TMU\^5a\ZLHd#Ad=<fQSRT<?E>^UGlfOOgofiN:h]km7`kTk5QgYkkogm^?H"
    A$ = A$ + "nMbmfQFoaAm[ohXNe_Wm;E_^BndVT#:3E9J?N>T\Fc3Q0<H#:RIIMI8I>I_O"
    A$ = A$ + "[e>8NGT:Jgl^jaNW4Zih[i1Zk?eO[^_<4o0ejEK1dOWFfMak=E>2oJPF_N?;"
    A$ = A$ + "T8:gb[mR;Bg8_c\<HohlXiIRHb>MS\cA=lN;WTJ5kM^=Rb4lOe#nb:JYGn91"
    A$ = A$ + "8D\5OeNXRf;K7\bKFQ9c_X_KgTk<e:]`e1IJgkVXFhl_l^fJAUHM2:akfJJ3"
    A$ = A$ + "F;ke2A6T^?3Um:UA;M0aBhJWC#13=hgl?GiL\aF`kUUJSGGD=f8Y>2S=LZ=#"
    A$ = A$ + "g5Jjnm?8KlnmWNF\8kgOJCZbgGSPQF9oASB]oOm1[J]>L1kCUTn0OoQV5]7R"
    A$ = A$ + "h::>=8_6Xmaj;^el#ZHoAf=olGQdW6R_W9YnccE:LPaZ;enYk9`\Z\;]WbM]"
    A$ = A$ + "Y4e6RlUJoH`Q\Y>;NXkI76>i58=L43ZSL82M]hS]MiEXaE[UVCXNPefY>_ZF"
    A$ = A$ + "X5ac\Q4=57mbK<;9H?Mg3c3J2H9l0;^IK[\mRKAaAk`cn_6R]94HaP2<7QJS"
    A$ = A$ + "N?^8]SbTi0<_Qg]BY?n:TUT5=TY<9UfP`Z6;?RliXl9JQ`aAVBSWae8MNGSB"
    A$ = A$ + "OH?<XY;ZD]VQ8VZ>mUaVQKURT81f:SK?_Y3aV`E8PU6LdO1GB;E0SgK84J`d"
    A$ = A$ + "f`ghYTWL#dlB`3A^9_\NIQFY76;Z#JW57TF^L1V3akjK]eA4L?\WlF=:_8SC"
    A$ = A$ + "VKHA^S3>Gh_AN]]X6D;ALi5:#U#aP=4JQC>^FK[[V38TJ?G70\CN#gG^^6E^"
    A$ = A$ + "^D\\]8D`9oXkI5jNaaQ;i4gb8\Y5h;De4\hR]]FL11K1i>lQJ?=0T`Q2LN_a"
    A$ = A$ + "6[oD[?M9O<UIH;bcJB:_WUm]cglFI?9aHOe>Djdfn:U8i<\LB1VTBi0SBnbJ"
    A$ = A$ + "3PhVJl#fZ6_aCAgFd#2MgJMj^UldOmdQIRV:K`j62>Vg8kCddL50#R#TCWW>"
    A$ = A$ + "0jm`]SfEO\45e?Johakd:i^;FU[8:H5]SXXNoWckgUJS]J8j]\N^XjB2^JNO"
    A$ = A$ + "Z^VfJk>URX5Q>3=\LNP3f9`[22ETlQ:JXSE7?64V9jLQ^m9QcFE]NF[XNZF\"
    A$ = A$ + "8dCHaVA]kEL]?>9JWD7]aTEE0WLGP[m1XDJmF[FDG4n<=GRhHBR4CHbF`Qhb"
    A$ = A$ + "#2kT=4KKXX_\XDd7W09K^#g3#Z=YbPQKO0iX]AjCE0ZcfH>R9cD=#lTCC;k\"
    A$ = A$ + "DO:Ml\aAaSWBnTm9<gXkJ7a7:mL1Phk:Q;F>8P_gVba?o96U[mPakI:Pf?ii"
    A$ = A$ + "4PCOHXhOSbM`nKdifnQLKlgLoJF8dmKEWh9V1]b47?LB#AHE`Y1W1Lf`i1W?"
    A$ = A$ + "LA`U0O0hZP[5f<\Eh6PNQM0g<lQPk#^oSJDo#aV]HSL\4NmZ`?E:EJ=CedWR"
    A$ = A$ + "bM8JejgAgknfn`mgoSnm5ljS]O1Nm?iFjES_[l0cN;KPl?nACP;QHj57QNHX"
    A$ = A$ + "Dk9M1KShUoCkAkj=9`QSkW\]n:oGI_e[eSGn>S^oQQ?:l9POOhnPo#hc1o9`"
    A$ = A$ + "31?2lX`O>lG0O=h[3OCh_1n^`O;lg1om`?161N=hO4nO2o_PoEho;l_1_1<^"
    A$ = A$ + "\C1W<JZUGIn]Q_RlVFYfhM<]geFNISJZFffH:[?]ZS1E9_Zc[Ka#mjPbPK1M"
    A$ = A$ + "LcHg0CNbEdgKd[]YginXO?Un>G7iT_R[6jD9UDf[4K=Y9ie4gBUC\7bjBk9o"
    A$ = A$ + "i;=YBJkm=AhLg>8Ie2hB_b[c]]DHNXQ01FjU;BQVhQ;cO5N2\dkLBkm;1fGY"
    A$ = A$ + "KB[aaQXHTM]ijTY?1XEX4L:`Y3W9L^`k5^0hm3G6L5`e0M0M2M1K7^AHW`]2"
    A$ = A$ + "g6m#\RbYd^cclnTAc\TbIV[RVl;[ba_adX`OYAmH3hAZZ<E[O2`V_HSL\4N]"
    A$ = A$ + "A_Vo=lcbmJC<Q9b]94]g_3_9l]hK_h9me_nP9^L24c9b<A>N<kgm]JM#JGll"
    A$ = A$ + "_:=?mHo5`To\\hOo?c4\[9mKgWi9okiI^`kdWA:_KmLji]kc9XOGmlmioOhi"
    A$ = A$ + "GeoAmLkig1?3SLk1Wg=OF;m^ec2[gEOfLmObNNSmfiIofk6?cY0HV`S3fWEa"
    A$ = A$ + "E2eYWK`cGRNN5XFj:ec3`_MGjidcFc_TNNUHF?OCmlZ`[nadC3fDdc[hYcmR"
    A$ = A$ + ">gPW?Kml:`aMIji1`J`gbiY`fl7YWG9fj7E?_:lkoNH\QK4a4:BAh\gh:;B7"
    A$ = A$ + "V`gLaX7g]RNKk6mmf?NIWKMWMg1Nbj`H8k16P?f?fR>aL1>ElC<4T[K3mTCn"
    A$ = A$ + "cK5oKK`:`?]RM^gN6HMmfoFk<kYVU77lHKU>QFKm4JK5]ejTQ6G>>0dSWc^h"
    A$ = A$ + "Q=;n6^l>kO7MeK?Ic>I]70kC4jaG=h^38lOIbQOZ`4HBIZdDUYJcd<eHV^YF"
    A$ = A$ + "CMVIHVYYNc\<Y=cfdPI>V<ViJJd<?cl=;`\#cR<;f\4CCV\84VZW8ZoGRW7Z"
    A$ = A$ + "VUJbSak?8lAP?3LG`O<lUQ_8V?`mIF6V;`MSAnoP`nPO1<:l5hWLZ3im\CmS"
    A$ = A$ + "1G?b:XWNZm0ONTULS#O<kIWX4QldCMGHlIdC?eW6cahfQmPAZm<`3K:HJf\L"
    A$ = A$ + "caH>FcaI>NC;`WcL2VCdLB`7e\2C[Vf<5=[dDbLbVEIF]iD<W:Z?lY<WVI=`"
    A$ = A$ + "SH>Mh?0ndVgSi<<[eLVVcbLfVcaL^VeI>?cj=_GckcLnV=H^0c5J^8c6=_Oc"
    A$ = A$ + "5K^4cUJ^<cUKn0Vf=GQi:=GUiZ=GSi3J^FceIj`\9cV=QV>=Ka\Ecf<MI^Nc"
    A$ = A$ + "=Hjf\MC?VN=mI^ACoVMH6`\Cc=I^Ic]H^Ec^<O8c^=gVif=gQI?VO?cMJn`V"
    A$ = A$ + "1=OTZgI?M]2lUNlLdS]Z7KC?FD?^BmH9mh9[7GUNLejaCA?NVjacB?NfjacE"
    A$ = A$ + "?^>iH[jhgZ>^]ZSK[jhfZ>^]ZSK[jhfZ>^]ZSK[jhfZ>^]ZSK[jhfZ>oJE7o"
    A$ = A$ + "FeaOEjacDaScZ]:?_>fnfkXb;MKM>#7EN9M]e]gA`6gFGl_Fl<?U:kXknfF7"
    A$ = A$ + "E6fIg3dAeMfg>jZkNkYbM`]JP>fI#OK[[JjlFfLgM\m`=e=eWf`AXZnjL78`"
    A$ = A$ + "ZYSnk_gK^k>gb0EcW]cnV>O\o^fjf6#na`N_iNTcfD_3\]JdV5fCM^cfd>jT"
    A$ = A$ + "1KK]N:C_gn7HKm^eNkYS^[[[N60]XdiV70=ZDKWgh>kjVjXk>kIcMFifjMWk"
    A$ = A$ + "XcIdOWgDgm^e^fL7MgC_3<MZaK]o>jNPnLW^Y1VfU\^F9aQE#WdZNb:LWDdN"
    A$ = A$ + "BKfCFYmTEK?iD\WLbfCFUmTBj9[d2Wf\M_TM8:IQLA;LJcn=]IKCKFhDbRZ["
    A$ = A$ + "dfhRFdX=g9fA_=;nDdMRmWFYM8Je=XF8gV5EGY[aF8_B;n\Bglb2iEJkN9g4"
    A$ = A$ + "d1WE:ZKm]Y^kMcg#e8_T>FYLEgKA>fo0je3\S]eAHWEbo]j`KP?FcFjZk^k<"
    A$ = A$ + "LCmN;CG>[OTSGm0mgE7KMWm97kG_>\7iHgKYZ=gEoK^k>[Y[N^Y=]C\C3#WY"
    A$ = A$ + "Og>fNGXlH7K^CD0jVLG4\SMfCEKYc]SR#YXoDi>j37lDK^kM^Y:gFWMP3AHG"
    A$ = A$ + "M\mNk9\f]_cMX2EM>C_cAIOa=ehScNbHoGSl3nVg6Mdooo4noEAM%%h1"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$: END IF: FOR j = 1 TO LEN(B$)
            IF MID$(B$, j, 1) = "#" THEN
        MID$(B$, j) = "@": END IF: NEXT
        FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    BASFILE$ = _INFLATE$(btemp$, 25152): btemp$ = ""
    _FONT _LOADFONT(BASFILE$, size, "memory, monospace")
END SUB
