'============
'XE.BAS v1.12
'============
'A simple File editor/viewer.
'Coded by Dav, NOV/2021 with QB64-GL v2
'
' * FIXED: Fixed FileSelect box to work correctly under Linux.
' * ADDED: Uses a resizable Code Page FONT to allow a larger SCREEN 0.
'          (FONT is extracted/created temporarily then deleted after use)
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

Screen Pete: Width 80, 25 'Use Screen mode 0, aka the Pete...

'Font size based on desktop resolution - it expands SCREEN 0 nicely.
'You may have to adjust it a bit to look the best on your screen res
FONT (Int(_DesktopHeight / 25) * .88)

_Delay .25 'Be sure window exists before calling _TITLE
_ControlChr Off 'Printing all 255 characters on screen, so this is needed.

_Title "XE v1.12" 'Everything has a name


'==========================================================================
'LOAD FILE
'=========

Cls , 1: Color 1, 15
Locate 1, 1: Print String$(80, 32);
Locate 1, 1: Print " Load file...";

If Command$ = "" Then
    File$ = FileSelect$(5, 10, 15, 55, "*.*")
    If File$ = "" Then
        Print "No file selected."
        End
    End If
Else
    File$ = Command$
End If

If _FileExists(File$) = 0 Then
    Color 7, 0: Cls
    Print "XE v1.12 - Binary file editor."
    Print
    Print File$; " not found!"
    End
End If

File$ = LTrim$(RTrim$(File$)) 'trim off any spaces is any...
FullFileName$ = File$ 'make a copy For TITLE/OPEN to use...

'If filename+path too long for display, strip off path
If Len(File$) > 70 Then
    ts$ = ""
    For q = Len(File$) To 1 Step -1
        t$ = Mid$(File$, q, 1)
        If t$ = "/" Or t$ = "\" Then Exit For
        ts$ = t$ + ts$
    Next
    File$ = ts$
    'If filename too long, shorten it for display
    If Len(File$) > 70 Then
        File$ = Mid$(File$, 1, 67) + "..."
    End If
End If

'==========================================================================
'OPEN FILE
'=========

Open FullFileName$ For Binary As 7

_Title "XE v1.12 - " + FullFileName$

DisplayView% = 1 'Default to 2-PANE view

ByteLocation& = 1
If DisplayView% = 1 Then
    BufferSize% = (16 * 23)
Else
    BufferSize% = (79 * 23)
End If
If BufferSize% > LOF(7) Then BufferSize% = LOF(7)


'==========================================================================
'DISPLAY FILE
'============

Color 15, 1: Cls: Locate 1, 1, 0

Do
    Seek #7, ByteLocation&

    PageOfData$ = Input$(BufferSize%, 7)

    'If dual pane mode....
    If DisplayView% = 1 Then
        If Len(PageOfData$) < (16 * 23) Then
            PageFlag% = 1: PageLimit% = Len(PageOfData$)
            PageOfData$ = PageOfData$ + String$(16 * 23 - Len(PageOfData$), Chr$(0))
        End If
        'show right side
        y% = 3: x% = 63
        For c% = 1 To Len(PageOfData$)
            CurrentByte% = Asc(Mid$(PageOfData$, c%, 1))
            'show a . instead of a null (looks better to me)
            If CurrentByte% = 0 Then CurrentByte% = 46
            If Filter% = 1 Then
                Select Case CurrentByte%
                    Case 0 To 31, 123 To 255: CurrentByte% = 32
                End Select
            End If
            Locate y%, x%: Print Chr$(CurrentByte%);
            x% = x% + 1: If x% = 79 Then x% = 63: y% = y% + 1
        Next
        'show left side
        y% = 3: x% = 15
        For c% = 1 To Len(PageOfData$)
            CurrentByte% = Asc(Mid$(PageOfData$, c%, 1))
            CurrentByte$ = Hex$(CurrentByte%): If Len(CurrentByte$) = 1 Then CurrentByte$ = "0" + CurrentByte$
            Locate y%, x%: Print CurrentByte$; " ";
            x% = x% + 3: If x% >= 62 Then x% = 15: y% = y% + 1
        Next
    Else
        'One page display, Full view
        'Adjust data size used
        If Len(PageOfData$) < (79 * 23) Then 'Enough to fill screen?
            PageFlag% = 1: PageLimit% = Len(PageOfData$) 'No? Mark this and pad
            PageOfData$ = PageOfData$ + Space$(79 * 23 - Len(PageOfData$)) 'data with spaces.
        End If
        y% = 3: x% = 1 'Screen location where data begins displaying
        For c% = 1 To Len(PageOfData$) 'Show all the bytes.
            CurrentByte% = Asc(Mid$(PageOfData$, c%, 1)) 'Check the ASCII value.
            If Filter% = 1 Then 'If Filter is turned on,
                Select Case CurrentByte% 'changes these values to spaces
                    Case 0 To 32, 123 To 255: CurrentByte% = 32
                End Select
            End If
            Locate y%, x%: Print Chr$(CurrentByte%);
            'This line calculates when to go to next row.
            x% = x% + 1: If x% = 80 Then x% = 1: y% = y% + 1
        Next
    End If

    GoSub DrawTopBar 'update viewing info at top

    'Get user input
    Do

        Do Until L$ <> "": L$ = InKey$: Loop
        K$ = L$: L$ = ""

        GoSub DrawTopBar
        Select Case UCase$(K$)
            Case Chr$(27): Exit Do
            Case "M": GoSub Menu:
            Case "N"
                If s$ <> "" Then
                    GoSub Search
                    GoSub DrawTopBar
                End If
            Case "E"
                If DisplayView% = 1 Then
                    GoSub EditRightSide
                Else
                    GoSub EditFullView
                End If
                GoSub DrawTopBar
            Case "F"
                If Filter% = 0 Then Filter% = 1 Else Filter% = 0
            Case "G"
                Locate 1, 1: Print String$(80 * 3, 32);
                Locate 1, 3: Print "TOTAL BYTES>"; LOF(7)
                Input "  GOTO BYTE# > ", GotoByte$
                If GotoByte$ <> "" Then
                    TMP$ = ""
                    For m% = 1 To Len(GotoByte$)
                        G$ = Mid$(GotoByte$, m%, 1) 'to numerical vales
                        Select Case Asc(G$)
                            Case 48 To 57: TMP$ = TMP$ + G$
                        End Select
                    Next: GotoByte$ = TMP$
                    If Val(GotoByte$) < 1 Then GotoByte$ = "1"
                    If Val(GotoByte$) > LOF(7) Then GotoByte$ = Str$(LOF(7))
                    If GotoByte$ <> "" Then ByteLocation& = 0 + Val(GotoByte$)
                End If
            Case "L"
                Locate 1, 1: Print String$(80 * 3, 32);
                Locate 1, 3: 'PRINT "TOTAL BYTES>"; LOF(7)
                Input "  GOTO HEX LOCATION-> ", GotoByte$
                If GotoByte$ <> "" Then
                    GotoByte$ = "&H" + GotoByte$
                    If Val(GotoByte$) < 1 Then GotoByte$ = "1"
                    If Val(GotoByte$) > LOF(7) Then GotoByte$ = Str$(LOF(7))
                    If GotoByte$ <> "" Then ByteLocation& = 0 + Val(GotoByte$)
                End If
            Case "S": s$ = ""
                Locate 1, 1: Print String$(80 * 3, 32);
                Locate 1, 3: Input "Search for> ", s$
                If s$ <> "" Then
                    Print "  CASE sensitive (Y/N)? ";
                    I$ = Input$(1): I$ = UCase$(I$)
                    If I$ = "Y" Then CaseOn% = 1 Else CaseOn% = 0
                    GoSub Search
                End If
                GoSub DrawTopBar
            Case Chr$(13)
                If DisplayView% = 1 Then
                    DisplayView% = 0
                    BufferSize% = (79 * 23)
                Else
                    DisplayView% = 1
                    BufferSize% = (16 * 23)
                End If
                GoSub DrawTopBar
            Case Chr$(0) + Chr$(72)
                If DisplayView% = 1 Then
                    If ByteLocation& > 15 Then ByteLocation& = ByteLocation& - 16
                Else
                    If ByteLocation& > 78 Then ByteLocation& = ByteLocation& - 79
                End If
            Case Chr$(0) + Chr$(80)
                If DisplayView% = 1 Then
                    If ByteLocation& < LOF(7) - 15 Then ByteLocation& = ByteLocation& + 16
                Else
                    If ByteLocation& < LOF(7) - 78 Then ByteLocation& = ByteLocation& + 79
                End If
            Case Chr$(0) + Chr$(73): ByteLocation& = ByteLocation& - BufferSize%: If ByteLocation& < 1 Then ByteLocation& = 1
            Case Chr$(0) + Chr$(81): If ByteLocation& < LOF(7) - BufferSize% Then ByteLocation& = ByteLocation& + BufferSize%
            Case Chr$(0) + Chr$(71): ByteLocation& = 1
            Case Chr$(0) + Chr$(79): If Not EOF(7) Then ByteLocation& = LOF(7) - BufferSize%
        End Select
    Loop Until K$ <> ""
Loop Until K$ = Chr$(27)

Close 7

System

'==========================================================================
'                              GOSUB ROUTINES
'==========================================================================


'==========================================================================
Search:
'======

If Not EOF(7) Then
    Do
        B$ = Input$(BufferSize%, 7): ByteLocation& = ByteLocation& + BufferSize%
        If CaseOn% = 0 Then B$ = UCase$(B$): s$ = UCase$(s$)
        d$ = InKey$: If d$ <> "" Then Exit Do
        If InStr(1, B$, s$) Then Sound 4000, .5: Exit Do
    Loop Until InStr(1, B$, s$) Or EOF(7)
    If EOF(7) Then Sound 2000, 1: Sound 1000, 1
    ByteLocation& = ByteLocation& - Len(s$)
End If
Return


'==========================================================================
EditRightSide: 'Editing Right side info in dual pane mode
'============

Pane% = 1

x% = 63: If rightx% Then y% = CsrLin Else y% = 3
leftx% = 15

test% = Pos(0)

If test% = 15 Or test% = 16 Then x% = 63: leftx% = 15
If test% = 18 Or test% = 19 Then x% = 64: leftx% = 18
If test% = 21 Or test% = 22 Then x% = 65: leftx% = 21
If test% = 24 Or test% = 25 Then x% = 66: leftx% = 24
If test% = 27 Or test% = 28 Then x% = 67: leftx% = 27
If test% = 30 Or test% = 31 Then x% = 68: leftx% = 30
If test% = 33 Or test% = 34 Then x% = 69: leftx% = 33
If test% = 36 Or test% = 37 Then x% = 70: leftx% = 36
If test% = 39 Or test% = 40 Then x% = 71: leftx% = 39
If test% = 42 Or test% = 43 Then x% = 72: leftx% = 42
If test% = 45 Or test% = 46 Then x% = 73: leftx% = 45
If test% = 48 Or test% = 49 Then x% = 74: leftx% = 48
If test% = 51 Or test% = 52 Then x% = 75: leftx% = 51
If test% = 54 Or test% = 55 Then x% = 76: leftx% = 54
If test% = 57 Or test% = 58 Then x% = 77: leftx% = 57
If test% = 60 Or test% = 61 Then x% = 78: leftx% = 60

GoSub DrawEditBar:

Locate y%, x%, 1, 1, 30

Do
    Do
        E$ = InKey$
        If E$ <> "" Then
            Select Case E$
                Case Chr$(9)
                    If Pane% = 1 Then
                        Pane% = 2: GoTo EditLeftSide
                    Else
                        Pane% = 1: GoTo EditRightSide
                    End If
                Case Chr$(27): Exit Do
                Case Chr$(0) + Chr$(72): If y% > 3 Then y% = y% - 1
                Case Chr$(0) + Chr$(80): If y% < 25 Then y% = y% + 1
                Case Chr$(0) + Chr$(75): If x% > 63 Then x% = x% - 1: leftx% = leftx% - 3
                Case Chr$(0) + Chr$(77): If x% < 78 Then x% = x% + 1: leftx% = leftx% + 3
                Case Chr$(0) + Chr$(73), Chr$(0) + Chr$(71): y% = 3
                Case Chr$(0) + Chr$(81), Chr$(0) + Chr$(79): y% = 25
                Case Else
                    If (ByteLocation& + ((y% - 3) * 16 + x% - 1) - 62) <= LOF(7) And E$ <> Chr$(8) Then
                        changes% = 1
                        'new color for changed bytes...
                        Color 1, 15: Locate y%, x%: Print " ";
                        Locate y%, leftx%
                        CurrentByte$ = Hex$(Asc(E$)): If Len(CurrentByte$) = 1 Then CurrentByte$ = "0" + CurrentByte$
                        Print CurrentByte$;
                        Locate y%, x%: Print E$;
                        Mid$(PageOfData$, ((y% - 3) * 16 + x% * 1) - 62) = E$
                        If x% < 78 Then x% = x% + 1: leftx% = leftx% + 3 'skip space
                    End If
            End Select
        End If
    Loop Until E$ <> ""
    Locate y%, x%
Loop Until E$ = Chr$(27)

'==========================================================================
SaveChanges:
'===========

If changes% = 1 Then
    Sound 4500, .2: Color 15, 4: Locate , , 0
    Locate 10, 29: Print Chr$(201); String$(21, 205); Chr$(187);
    Locate 11, 29: Print Chr$(186); " Save Changes (Y/N)? "; Chr$(186);
    Locate 12, 29: Print Chr$(200); String$(21, 205); Chr$(188);
    N$ = Input$(1): Color 15, 1
    If UCase$(N$) = "Y" Then
        If PageFlag% = 1 Then PageOfData$ = Left$(PageOfData$, PageLimit%)
        Put #7, ByteLocation&, PageOfData$:
    End If
End If
Color 15, 1: Cls: Locate 1, 1, 0
Return


'==========================================================================
EditLeftSide: 'Editing Left side info in dual pane mode
'===========

Color 1, 7
x% = 15: 'y% = 3
rightx% = 63

test% = Pos(0)
If test% = 63 Then x% = 15: rightx% = 63
If test% = 64 Then x% = 18: rightx% = 64
If test% = 65 Then x% = 21: rightx% = 65
If test% = 66 Then x% = 24: rightx% = 66
If test% = 67 Then x% = 27: rightx% = 67
If test% = 68 Then x% = 30: rightx% = 68
If test% = 69 Then x% = 33: rightx% = 69
If test% = 70 Then x% = 36: rightx% = 70
If test% = 71 Then x% = 39: rightx% = 71
If test% = 72 Then x% = 42: rightx% = 72
If test% = 73 Then x% = 45: rightx% = 73
If test% = 74 Then x% = 48: rightx% = 74
If test% = 75 Then x% = 51: rightx% = 75
If test% = 76 Then x% = 54: rightx% = 76
If test% = 77 Then x% = 57: rightx% = 77
If test% = 78 Then x% = 60: rightx% = 78

GoSub DrawEditBar:

Locate y%, x%, 1, 1, 30

Do
    Do
        E$ = InKey$
        If E$ <> "" Then
            Select Case E$
                Case Chr$(9)
                    If Pane% = 1 Then
                        Pane% = 2: GoTo EditLeftSide
                    Else
                        Pane% = 1: GoTo EditRightSide
                    End If
                Case Chr$(27): Exit Do
                Case Chr$(0) + Chr$(72): If y% > 3 Then y% = y% - 1
                Case Chr$(0) + Chr$(80): If y% < 25 Then y% = y% + 1
                Case Chr$(0) + Chr$(75) 'right arrow....
                    If x% > 15 Then
                        Select Case x%
                            Case 17, 18, 20, 21, 23, 24, 26, 27, 29, 30, 32, 33, 35, 36, 38, 39, 41, 42, 44, 45, 47, 48, 50, 51, 53, 54, 56, 57, 59, 60, 62, 63
                                x% = x% - 2
                                rightx% = rightx% - 1
                            Case Else: x% = x% - 1
                        End Select
                    End If

                Case Chr$(0) + Chr$(77)
                    If x% < 61 Then
                        Select Case x%
                            Case 16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 46, 47, 49, 50, 52, 53, 55, 56, 58, 59, 61, 62
                                x% = x% + 2
                                rightx% = rightx% + 1
                            Case Else: x% = x% + 1
                        End Select
                    End If

                Case Chr$(0) + Chr$(73), Chr$(0) + Chr$(71): y% = 3
                Case Chr$(0) + Chr$(81), Chr$(0) + Chr$(79): y% = 25
                Case Else
                    If (ByteLocation& + ((y% - 3) * 16 + rightx% - 1) - 62) <= LOF(7) And E$ <> Chr$(8) Then
                        Select Case UCase$(E$)
                            Case "A", "B", "C", "D", "E", "F", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
                                E$ = UCase$(E$)
                                changes% = 1
                                Color 1, 15: Locate y%, x%: Print " ";
                                Locate y%, x%: Print E$;
                                If x% < 62 Then

                                    Select Case x%
                                        Case 16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 46, 47, 49, 50, 52, 53, 55, 56, 58, 59, 61, 62
                                            e2$ = Chr$(Val("&H" + Chr$(Screen(y%, x% - 1)) + Chr$(Screen(y%, x%))))
                                            'reflect changes on right panel
                                            Color 1, 15: Locate y%, rightx%: Print " ";
                                            Locate y%, rightx%: Print e2$;
                                            Mid$(PageOfData$, ((y% - 3) * 16 + rightx% * 1) - 62) = e2$
                                            'dont advance cursor if at last place
                                            If x% < 61 Then
                                                rightx% = rightx% + 1
                                                x% = x% + 2
                                            End If
                                        Case Else: x% = x% + 1
                                    End Select
                                End If
                        End Select

                    End If
            End Select
        End If
    Loop Until E$ <> ""
    Locate y%, x%
Loop Until E$ = Chr$(27)

GoTo SaveChanges:


'==========================================================================
EditFullView: 'Editing file in full display mode (one pane)
'===========

Color 1, 7
x% = 1: y% = 3
changes% = 0

GoSub DrawEditBar

Locate 3, 1, 1, 1, 30

Do
    Do
        E$ = InKey$
        If E$ <> "" Then
            Select Case E$
                Case Chr$(27): Exit Do
                Case Chr$(0) + Chr$(72): If y% > 3 Then y% = y% - 1
                Case Chr$(0) + Chr$(80): If y% < 25 Then y% = y% + 1
                Case Chr$(0) + Chr$(75): If x% > 1 Then x% = x% - 1
                Case Chr$(0) + Chr$(77): If x% < 79 Then x% = x% + 1
                Case Chr$(0) + Chr$(73), Chr$(0) + Chr$(71): y% = 3
                Case Chr$(0) + Chr$(81), Chr$(0) + Chr$(79): y% = 25
                Case Else
                    If (ByteLocation& + (y% - 3) * 79 + x% - 1) <= LOF(7) And E$ <> Chr$(8) Then
                        changes% = 1
                        'new color for changed bytes
                        Color 1, 15: Locate y%, x%: Print " ";
                        Locate y%, x%: Print E$;
                        Mid$(PageOfData$, (y% - 3) * 79 + x% * 1) = E$
                        If x% < 79 Then x% = x% + 1
                    End If
            End Select
        End If
    Loop Until E$ <> ""
    GoSub DrawEditBar
    Locate y%, x%
Loop Until E$ = Chr$(27)

GoTo SaveChanges:

'==========================================================================
DrawEditBar:
'===========

If DisplayView% = 1 Then
    Locate 1, 1:
    Color 31, 4: Print "  EDIT MODE: ";
    Color 15, 4
    Print " Press TAB to switch editing sides "; Chr$(179); " Arrows move cursor "; Chr$(179); " ESC=Exit ";
Else
    Locate 1, 1
    Color 31, 4: Print " EDIT MODE ";
    Color 15, 4
    Print Chr$(179); " Arrows move cursor "; Chr$(179); " ESC=Exit "; Chr$(179);
    Locate 1, 45: Print String$(35, " ");

    Locate 1, 46
    CurrentByte& = ByteLocation& + (y% - 3) * 79 + x% - 1
    CurrentValue% = Asc(Mid$(PageOfData$, (y% - 3) * 79 + x% * 1, 1))
    If CurrentByte& > LOF(7) Then
        Print Space$(9); "PAST END OF FILE";
    Else
        Print "Byte:"; LTrim$(Str$(CurrentByte&));
        Print ", ASC:"; LTrim$(Str$(CurrentValue%));
        Print ", HEX:"; RTrim$(Hex$(CurrentValue%));
    End If
End If
Return

'==========================================================================
DrawTopBar:
'============

Color 1, 15
Locate 1, 1: Print String$(80, 32);
Locate 2, 1: Print String$(80, 32);

Locate 1, 1
If Filter% = 1 Then
    Color 30, 4: Print "F";: Color 1, 15
Else
    Print " ";
End If

Print "FILE: "; File$;

Locate 2, 2:
Print "Total Bytes:"; LOF(7);
EC& = ByteLocation& + BufferSize%: If EC& > LOF(7) Then EC& = LOF(7)
Print Chr$(179); " Viewing Bytes:"; RTrim$(Str$(ByteLocation&)); "-"; LTrim$(Str$(EC&));
Locate 1, 71: Print " M = Menu";
Color 15, 1
'Draw bar on right side of screen
For d% = 3 To 25
    Locate d%, 80: Print Chr$(176);
Next

If DisplayView% = 1 Then
    'Draw lines down screen
    For d% = 3 To 25
        Locate d%, 79: Print Chr$(179);
        Locate d%, 62: Print Chr$(179);
        'add space around numbers...
        '(full screen messes it...)
        Locate d%, 13: Print " " + Chr$(179);
        Locate d%, 1: Print Chr$(179) + " ";
    Next

    'Draw location
    For d% = 3 To 25
        Locate d%, 3
        nm$ = Hex$(ByteLocation& - 32 + (d% * 16))
        If Len(nm$) = 9 Then nm$ = "0" + nm$
        If Len(nm$) = 8 Then nm$ = "00" + nm$
        If Len(nm$) = 7 Then nm$ = "000" + nm$
        If Len(nm$) = 6 Then nm$ = "0000" + nm$
        If Len(nm$) = 5 Then nm$ = "00000" + nm$
        If Len(nm$) = 4 Then nm$ = "000000" + nm$
        If Len(nm$) = 3 Then nm$ = "0000000" + nm$
        If Len(nm$) = 2 Then nm$ = "00000000" + nm$
        If Len(nm$) = 1 Then nm$ = "000000000" + nm$
        Print nm$;
    Next
End If

Marker% = CInt(ByteLocation& / LOF(7) * 22)
Locate Marker% + 3, 80: Print Chr$(178);
Return

'==========================================================================
Menu:
'========

Sound 4500, .2: Color 15, 0: Locate , , 0
Locate 5, 24: Print Chr$(201); String$(34, 205); Chr$(187);
For m = 6 To 20
    Locate m, 24: Print Chr$(186); Space$(34); Chr$(186);
Next
Locate 21, 24: Print Chr$(200); String$(34, 205); Chr$(188);

Locate 6, 26: Print "Use the arrow keys, page up/down";
Locate 7, 26: Print "and Home/End keys to navigate.";
Locate 9, 26: Print "E = Enter into file editing mode";
Locate 10, 26: Print "F = Toggles the filter ON or OFF";
Locate 11, 26: Print "G = Goto a certain byte position";
Locate 12, 26: Print "L = Goto a certain HEX location";
Locate 13, 26: Print "S = Searches for string in file";
Locate 14, 26: Print "N = Find next match after search";
Locate 16, 26: Print "ENTER = Toggle HEX/ASCII modes";
Locate 17, 26: Print "TAB   = switch window (HEX mode)";
Locate 18, 26: Print "ESC   = EXITS this program";
Locate 20, 26: Print "ALT+ENTER for full screen window";
Pause$ = Input$(1)
Color 15, 1: Cls: Locate 1, 1, 0
Return


'==========================================================================
'                           FUNCTIONS/SUBS
'==========================================================================

Function FileSelect$ (y, x, y2, x2, Filespec$)


    '=== save original place of cursor
    origy = CsrLin
    origx = Pos(1)

    '=== save colors
    fg& = _DefaultColor
    bg& = _BackgroundColor

    '=== Save whole screen
    Dim scr1 As _MEM, scr2 As _MEM
    scr1 = _MemImage(0): scr2 = _MemNew(scr1.SIZE)
    _MemCopy scr1, scr1.OFFSET, scr1.SIZE To scr2, scr2.OFFSET

    '=== Generate a unique temp filename to use based on date + timer
    tmp$ = "_qb64_" + Date$ + "_" + LTrim$(Str$(Int(Timer))) + ".tmp"
    If InStr(_OS$, "LINUX") Then tmp$ = "/tmp/" + tmp$

    loadagain:

    top = 0
    selection = 0

    '=== list directories
    If InStr(_OS$, "LINUX") Then
        Shell _Hide "find . -maxdepth 1 -type d > " + tmp$
    Else
        Shell _Hide "dir /b /A:D > " + tmp$
    End If

    '=== make room for names
    ReDim FileNames$(10000) 'space for 10000 filenames

    '=== only show the ".." when not at root dir
    If Len(_CWD$) <> 3 Then
        FileNames$(0) = ".."
        LineCount = 1
    Else
        LineCount = 0
    End If

    '=== Open temp file
    FF = FreeFile
    Open tmp$ For Input As #FF

    While ((LineCount < UBound(FileNames$)) And (Not EOF(FF)))
        Line Input #FF, rl$

        '=== load, ignoring the . entry added under Linux
        If rl$ <> "." Then

            'also remove the ./ added at the beginning when under linux
            If InStr(_OS$, "LINUX") Then
                If Left$(rl$, 2) = "./" Then
                    rl$ = Right$(rl$, Len(rl$) - 2)
                End If
            End If

            FileNames$(LineCount) = "[" + rl$ + "]"
            LineCount = LineCount + 1

        End If
    Wend

    Close #FF

    '=== now grab list of files...
    If InStr(_OS$, "LINUX") Then
        Shell _Hide "rm " + tmp$
        If Filespec$ = "*.*" Then Filespec$ = ""
        Shell _Hide "find -maxdepth 1 -type f -name '" + Filespec$ + "*' > " + tmp$
    Else
        Shell _Hide "del " + tmp$
        Shell _Hide "dir /b /A:-D " + Filespec$ + " > " + tmp$
    End If

    '=== open temp file
    FF = FreeFile
    Open tmp$ For Input As #FF

    While ((LineCount < UBound(FileNames$)) And (Not EOF(FF)))

        Line Input #FF, rl$

        '=== load, ignoring the generated temp file...
        If rl$ <> tmp$ Then

            'also remove the ./ added at the beginning when under linux
            If InStr(_OS$, "LINUX") Then
                If Left$(rl$, 2) = "./" Then
                    rl$ = Right$(rl$, Len(rl$) - 2)
                End If
            End If

            FileNames$(LineCount) = rl$
            LineCount = LineCount + 1
        End If

    Wend
    Close #FF

    '=== Remove the temp file created
    If InStr(_OS$, "LINUX") Then
        Shell _Hide "rm " + tmp$
    Else
        Shell _Hide "del " + tmp$
    End If


    '=== draw a box
    Color _RGB(100, 100, 255)
    For l = 0 To y2 + 1
        Locate y + l, x: Print String$(x2 + 4, Chr$(219));
    Next

    '=== show current working dir at top
    Color _RGB(255, 255, 255), _RGB(100, 100, 255)
    CurDir$ = _CWD$
    '=== Shorten it is too long, for display purposes
    If Len(CurDir$) > x2 - x Then
        CurDir$ = Mid$(CurDir$, 1, x2 - x - 3) + "..."
    End If
    Locate y, x + 2: Print CurDir$;

    '=== scroll through list...
    Do

        For l = 0 To (y2 - 1)

            Locate (y + 1) + l, (x + 2)
            If l + top = selection Then
                Color _RGB(0, 0, 64), _RGB(255, 255, 255) 'selected line
            Else
                Color _RGB(255, 255, 255), _RGB(0, 0, 64) 'regular
                '=== directories get a different color...
                If Mid$(FileNames$(top + l), 1, 1) = "[" Then
                    Color _RGB(255, 255, 0), _RGB(0, 0, 64)
                End If
            End If

            Print Left$(FileNames$(top + l) + String$(x2, " "), x2);

        Next

        '=== Get user input

        k$ = InKey$
        Select Case k$

            Case Is = Chr$(0) + Chr$(72) 'Up arrow
                If selection > 0 Then selection = selection - 1
                If selection < top Then top = selection

            Case Is = Chr$(0) + Chr$(80) 'Down Arrow
                If selection < (LineCount - 1) Then selection = selection + 1
                If selection > (top + (y2 - 2)) Then top = selection - y2 + 1

            Case Is = Chr$(0) + Chr$(73) 'Page up
                top = top - y2
                selection = selection - y2
                If top < 0 Then top = 0
                If selection < 0 Then selection = 0

            Case Is = Chr$(0) + Chr$(81) 'Page Down
                top = top + y2
                selection = selection + y2
                If top >= LineCount - y2 Then top = LineCount - y2
                If top < 0 Then top = 0
                If selection >= LineCount Then selection = LineCount - 1

            Case Is = Chr$(0) + Chr$(71) 'Home
                top = 0: selection = 0

            Case Is = Chr$(0) + Chr$(79) 'End
                selection = LineCount - 1
                top = selection - y2 + 1
                If top < 0 Then top = 0

            Case Is = Chr$(27) ' ESC cancels
                FileSelect$ = ""
                Exit Do

            Case Is = Chr$(13) 'Enter
                '=== if .. then go up one dir
                If RTrim$(FileNames$(selection)) = ".." Then
                    cd$ = _CWD$
                    If InStr(_OS$, "LINUX") Then
                        cd$ = Left$(cd$, _InStrRev(cd$, "/"))
                    Else
                        cd$ = Left$(cd$, _InStrRev(cd$, "\"))
                    End If
                    ChDir cd$
                    Erase FileNames$
                    GoTo loadagain
                End If

                'see if directory
                test$ = RTrim$(FileNames$(selection))
                If Left$(test$, 1) = "[" Then
                    test$ = Mid$(test$, 2, Len(test$) - 2)
                    ChDir test$
                    Erase FileNames$
                    GoTo loadagain
                Else
                    If InStr(_OS$, "LINUX") Then
                        If Right$(_CWD$, 1) = "/" Then
                            C$ = _CWD$
                        Else
                            C$ = _CWD$ + "/"
                        End If
                    Else
                        If Right$(_CWD$, 1) = "\" Then
                            C$ = _CWD$
                        Else
                            C$ = _CWD$ + "\"
                        End If
                    End If

                    FileSelect$ = C$ + RTrim$(FileNames$(selection))
                    Exit Do

                End If

        End Select

    Loop

    _KeyClear

    '=== Restore the whole screen
    _MemCopy scr2, scr2.OFFSET, scr2.SIZE To scr1, scr1.OFFSET
    _MemFree scr1: _MemFree scr2

    '=== restore original y,x and color
    Locate origy, origx

    Color fg&, bg&


End Function

Sub FONT (size)
    'load/set built-in CP437 font
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
    For i& = 1 To Len(A$) Step 4: B$ = Mid$(A$, i&, 4)
        If InStr(1, B$, "%") Then
            For C% = 1 To Len(B$): F$ = Mid$(B$, C%, 1)
                If F$ <> "%" Then C$ = C$ + F$
            Next: B$ = C$: End If: For j = 1 To Len(B$)
            If Mid$(B$, j, 1) = "#" Then
        Mid$(B$, j) = "@": End If: Next
        For t% = Len(B$) To 1 Step -1
            B& = B& * 64 + Asc(Mid$(B$, t%)) - 48
            Next: X$ = "": For t% = 1 To Len(B$) - 1
            X$ = X$ + Chr$(B& And 255): B& = B& \ 256
    Next: btemp$ = btemp$ + X$: Next
    BASFILE$ = _Inflate$(btemp$): btemp$ = ""

    '=== Generate a unique font name to use based on date + timer
    fontname$ = "_cp437_" + Date$ + "_" + LTrim$(Str$(Int(Timer))) + ".ttf"
    If InStr(_OS$, "LINUX") Then tmp$ = "/tmp/" + tmp$
    '=== Make font file
    FFF = FreeFile: Open fontname$ For Output As #FFF
    Print #FFF, BASFILE$;: Close #FFF
    '=== Load then kill it after loading it into memory
    fnt& = _LoadFont(fontname$, size, "monospace"): _Font fnt&
    Kill fontname$

End Sub


