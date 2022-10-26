' ################################################################################################################################################################
' #TOP

' QB64 Sound Examples
' Version 2.00 by madscijr

' CHANGE LOG:
' Date         Who                What
' 04/11/2021   madscijr           collected together sound code from various QB and QB64 programs
' 04/21/2021   madscijr           v1.0 sound demo program (added menu + playback and save comments)
' 01/26/2022   madscijr           v2.0 added a friendlier menu system

' DESCRIPTION:
' Just a bunch of sound code taken from various programs collected
' in one place that you can listen to using a simple menu,
' and study the code to see how each sound was done.

' ****************************************************************************************************************************************************************
' CREDITS / ATTRIBUTION:
'
' The following lists the source programs the sound routines came from,
' the original programmers (where known), and the URL each was found at.
' (Each sound routine has the original program's name in the sub name.)

' Source Program                               Author/Info/Source URLs
' ------------------------------------------   ----------------------------------
' 18WHEELR.BAS                                 Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' ALRMBOBS.BAS                                 Released to PUBLIC DOMAIN by Kurt Kuzba. (3/10/96)
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' ANSISHOW.BAS                                 Unknown
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' ANSISUB.BAS                                  Released to PUBLIC DOMAIN by Kurt Kuzba. (1/22/96)
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' ARG!!.BAS (qb_src.zip)                       From: Andrew Jones, Date: 04-14-96 14:33, Released to PUBLIC DOMAIN by Kurt Kuzba. (4/28/96)
'                                              https://forum.thegamecreators.com/thread/222397
' arqanoid.bas                                 Galleondragon
'                                              https://github.com/Galleondragon/qb64/blob/master/programs/samples/qb45com/action/arqanoid/arqanoid.bas
' BEEP!.BAS                                    Unknown
'                                              http://www.thedubber.altervista.org/qbsrc.htm
'                                              http://nasm.rm-f.net/~jon/BASIC/QBASIC/
' bomb.bas                                     By Dave Duvenaud
'                                              https://www.ocf.berkeley.edu/~horie/bomb.bas
' bplus_asteroids_makeover.bas                 Asteroids Makeover by bplus
'                                              https://www.qb64.org/forum/index.php?topic=3173.0
'                                              https://forum.qb64.org/index.php?topic=3173.msg124947#msg124947
' CLOCK.BAS                                    UnderWARE Labs
'                                              http://files.allbasic.info/UnderWare/CLOCK.txt
' CONSANSI.BAS                                 Unknown
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' CR.BAS                                       CAVE RAIDER Version 1.4, Copyright (c) 2004 by Paul Redling
'                                              https://dosgamer.com/games/play/cave-raider-4612.html
'                                              https://archive.org/details/CaveRaider
' DEMO_BTN.txt (Qb_junk.zip)                   Text screen Mouse and Button Demo - and included SUBs.
'                                              http://files.allbasic.info/UnderWare/uwl_files.html
' DEMO3.BAS                                    Microsoft Programmer's Library 1.3 CD-ROM
'                                              https://www.pcjs.org/documents/books/mspl13/basic/qblearn/
'                                              https://www.pcjs.org/documents/books/mspl13/
' ELYSIAN.BAS                                  Elysian Fields by Pantera55@aol.com, released May 2nd, 1998 as freeware.
'                                              http://petesqbsite.com/reviews/rpgs/elysian.html
'                                              http://members.aol.com/Pantera55/
' FADE-IO.BAS                                  Released to PUBLIC DOMAIN by Kurt Kuzba. (1/21/96)
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' frog.bas                                     RETRO.BAS by Matt Bross, 1997, oh_bother@GeoCities.Com
'                                              https://github.com/Galleondragon/qb64/blob/master/programs/samples/misc/samples.txt
'                                              http://www.GeoCities.Com/SoHo/7067/
' Frostbite Tribute (Beta 6).bas               FellippeHeitor, July 17, 2018, 12:01:48 AM
'                                              https://www.qb64.org/forum/index.php?topic=342.0
' GOLF.BAS                                     Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' HANGMAN.BAS                                  Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' KISSED.BAS                                   Unknown
'                                              http://mangoun.c-scene.org/~jon/BASIC/QBASIC/SOURCE/PD/KISSED.BAS
'                                              http://mangoun.c-scene.org/~jon/BASIC/QBASIC/
' KWIKVIEW.BAS                                 Unknown
'                                              http://mangoun.c-scene.org/~jon/BASIC/QBASIC/SOURCE/PD/KWIKVIEW.BAS
'                                              http://mangoun.c-scene.org/~jon/BASIC/QBASIC/
' leapfrog.bas                                 L E A P F R O G. B A S 2.1 (C) 2002 - 2007 by Bob Seguin (Freeware)
'                                              http://bcs.solano.edu/workarea/jurrutia/Coursework/CIS%2001%20-%20Intro%20to%20Computers/Qbasic/QBasic64/qb64/samples/thebob/leapfrog/
' LLED.BAS                                     Unknown
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' macattak.bas                                 Mac & Splat! STEELCHARM@AOL.COM
'                                              http://files.allbasic.info/UnderWare/
' MONOP.BAS                                    MONOPOLY CREATED BY KENNETH SILVERMAN
'                                              http://advsys.net/ken/qb/qb.htm
'                                              http://advsys.net/ken/qb/qb.htm
' MOON.BAS, qb_src.zip                         From: Earl Montgomery, Date: 11-01-95 15:42
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' mooncr.bas                                   by Daniel Kupfer, dk1000000@aol.com
'                                              https://www.qb64.org/forum/index.php?topic=1528.0
' MOSH.BAS                                     Mosh At A & P, a game by Softintheheadware, 1997
'                                              https://softintheheadware.com
'                                              https://sourceforge.net/u/sithw/profile/
' mosh_at_a&p.bas                              Mosh At A & P, a game by Softintheheadware, 1997
'                                              https://softintheheadware.com
'                                              https://sourceforge.net/u/sithw/profile/
' NDXCRLF.BAS                                  Unknownh, ttp://www.thedubber.altervista.org/qbsrc.htm
' PAC-MAN.txt                                  P A C M A N  -  R E V I S I T E D ! From UnderWARE Labs(1997)
'                                              http://files.allbasic.info/UnderWare/PAC-MAN.txt
' POLFILL.BAS, kensqb.zip                      Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' QBLANDER.BAS                                 Unknown
'                                              http://www.thedubber.altervista.org/qbsrc.htm
'                                              http://nasm.rm-f.net/~jon/BASIC/QBASIC/
' Qbw_1-1.txt, qbw.zip                         Nice text editor by UnderWare Labs
'                                              https://qb45.org/files.php?cat=10&p=8
'                                              https://qb45.org/download.php?id=1244
'                                              https://qb45.org/files.php?action=search2&keywords=qbw.zip&funcbtn=Search%21
' RMORTIS2.BAS                                 Rigor Mortis 2
'                                              https://archive.org/details/RigorMortis2
'                                              http://www.o-bizz.de/qbdown/qbcom/action.htm
'                                              http://community.fortunecity.ws/underworld/digitalstreet/112/qbasic/qbdload.htm
' SCROLL12.BAS                                 Released to PUBLIC DOMAIN by Kurt Kuzba. (8/14/98)
'                                              http://c.rm-f.net/~jon/BASIC/QBASIC/SOURCE/PD/SCROLL12.BAS
'                                              http://nasm.rm-f.net/~jon/BASIC/QBASIC/
' SEARCH.BAS                                   PROGRAMMED BY KENNETH SILVERMAN
'                                              http://advsys.net/ken/qb/qb.htm
' SLIME.BAS                                    Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' SLOTS.txt                                    BASIC - Slots version 1.O - for MS QBasic by UWL
'                                              http://files.allbasic.info/UnderWare/SLOTS.txt
' SNATCH.BAS                                   Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' SOFTINTHEHEADWARE_SOUND2.BAS                 Softintheheadware
'                                              https://softintheheadware.com
'                                              https://sourceforge.net/u/sithw/profile/
' SOFTINTHEHEADWARE_SOUND3.BAS                 Softintheheadware
'                                              https://softintheheadware.com
'                                              https://sourceforge.net/u/sithw/profile/
' StarBlast_2018-6-19.bas                      SirCrow
'                                              https://www.qb64.org/forum/index.php?topic=285.0
'                                              https://forum.qb64.org/index.php?action=profile;u=91
' STEEL.BAS, qb_src.zip                        ILLUSION.BAS by tony cave, Date: 06-07-96 03:01
'                                              http://www.thedubber.altervista.org/qbsrc.htm
' Tank Walls 2.bas (Tank Walls 2.zip)          Tank Walls 2 by SierraKen
'                                              https://forum.qb64.org/index.php?topic=1482.0
'                                              https://forum.qb64.org/index.php?action=profile;u=389
' Tech Invaders.bas                            Tech Invaders 2 by SierraKen
'                                              https://forum.qb64.org/index.php?topic=1537.0
'                                              https://forum.qb64.org/index.php?action=profile;u=389
' temple.bas                                   Temple VERSION 4.2 by John Belew (Nurruc the Chaotic)
'                                              of the Apple Eliminators, July 25, 1984
'                                              https://github.com/Galleondragon/qb64/blob/master/programs/samples/misc/temple.bas
' THEWOODS.BAS                                 PUBLIC DOMAIN by Kurt Kuzba. (6/19/1997)
'                                              http://c.rm-f.net/~jon/BASIC/QBASIC/SOURCE/PD/THEWOODS.BAS
'                                              http://nasm.rm-f.net/~jon/BASIC/QBASIC/
' SierraKen_My 1996 Tiny Dungeon Game v2.bas   My 1996 Tiny Dungeon Game by SierraKen
'                                              https://www.qb64.org/forum/index.php?topic=3482.0
'                                              https://forum.qb64.org/index.php?action=profile;u=389
' TRIANGU2.BAS                                 Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' TANKGAME.txt, SOUND-FX.txt                   UnderWARE Labs
'                                              http://files.allbasic.info/UnderWare/TANKGAME.txt
'                                              http://files.allbasic.info/UnderWare/SOUND-FX.txt
' uwl-subs.bas.txt                             UnderWARE Labs (UWLabs)
'                                              http://files.allbasic.info/UnderWare/uwl_files.html
' WASTER.BAS                                   Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' XGAME.BAS                                    Ken Silverman's QuickBasic Page
'                                              http://advsys.net/ken/qb/qb.htm
' XWING.BAS                                    2060-A.BAS, XWING, BROUGHT TO YOU BY DATATECH, MICHAEL KNOX WAUSAU WI 54403,
'                                              MODIFIED BY GALLEON TO BE QBASIC COMPATIBLE, QB64 DEMO #5: X-WING FIGHTER
'                                              https://github.com/Galleondragon/qb64/blob/master/programs/samples/misc/samples.txt
' ****************************************************************************************************************************************************************

' ################################################################################################################################################################
' #CONSTANTS = GLOBAL CONSTANTS

' boolean constants:
Const FALSE = 0
Const TRUE = Not FALSE

' ################################################################################################################################################################
' #VARS = GLOBAL VARIABLES

' ENABLE / DISABLE DEBUG CONSOLE
Dim Shared m_bTesting As Integer: m_bTesting = TRUE

' BASIC PROGRAM METADATA
Dim Shared m_ProgramPath$: m_ProgramPath$ = Left$(Command$(0), _InStrRev(Command$(0), "\"))
Dim Shared m_ProgramName$: m_ProgramName$ = Mid$(Command$(0), _InStrRev(Command$(0), "\") + 1)
Dim Shared m_VersionInfo$: m_VersionInfo$ = "2.00"

' FOR MENU
ReDim Shared m_arrMenu(-1) As String
ReDim Shared m_arrCredits(-1) As String

' =============================================================================
' LOCAL VARIABLES
Dim in$

' ****************************************************************************************************************************************************************
' ACTIVATE DEBUGGING WINDOW
If m_bTesting = TRUE Then
    $Console
    _Delay 4
    _Console On
    _Echo "Started " + m_ProgramName$
    _Echo "Debugging on..."
End If
' ****************************************************************************************************************************************************************

' =============================================================================
' START THE MAIN ROUTINE
main

' =============================================================================
' FINISH
Screen 0
Print m_ProgramName$ + " finished."
Input "Press <ENTER> to continue", in$

' ****************************************************************************************************************************************************************
' DEACTIVATE DEBUGGING WINDOW
If m_bTesting = TRUE Then
    _Console Off
End If
' ****************************************************************************************************************************************************************

System ' return control to the operating system
End

' /////////////////////////////////////////////////////////////////////////////

Sub main
    Dim RoutineName As String: RoutineName = "main"
    Dim in$
    Dim result$: result$ = ""

    ' INTIALIZE
    Cls
    Print "Initializing..."
    InitializeGlobal

    ' SET UP SCREEN
    Screen _NewImage(1024, 768, 32): _ScreenMove 0, 0

    ' MAIN MENU
    Do
        If Len(result$) = 0 Then
            Cls
        Else
            Print
        End If

        Print m_ProgramName$
        Print
        Print "-------------------------------------------------------------------------------"
        Print "QB64 Sound Examples " + m_VersionInfo$
        Print "-------------------------------------------------------------------------------"
        Print
        Print "Sounds from various free Quick Basic, QBasic, and QB64 programs, "
        Print "collected from the Web by Softintheheadware (Jan, 2022)."
        Print
        Print "OPTIONS:"
        Print "1. Sample sounds"
        Print "2. List of programs / programmers who created the sounds"
        Print

        Print "What to do? ('q' to exit)"

        Input in$: in$ = _Trim$(in$) ' in$ = LCase$(Left$(in$, 1))

        If in$ = "1" Then
            result$ = ReviewSounds$
            _KeyClear
        ElseIf in$ = "2" Then
            result$ = DisplayCredits$
            _KeyClear
        End If

        If Len(result$) > 0 Then
            Print result$
        End If

    Loop Until in$ = "q"

    ' RETURN TO TEXT SCREEN
    Screen 0

End Sub ' main

' /////////////////////////////////////////////////////////////////////////////

Function ReviewSounds$
    ' DECLARATIONS
    Dim sResult As String
    Dim sFileName As String
    Dim vbCrLf As String: vbCrLf = Chr$(10) + Chr$(13)
    Dim vbCr As String: vbCr = Chr$(13)
    Dim vbLf As String: vbLf = Chr$(10)
    Dim vbTab As String: vbTab = Chr$(9)
    Dim quot As String: quot = Chr$(34)
    Dim sTempHR As String: sTempHR = "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    Dim sOut As String
    Dim sComment As String
    Dim sError As String
    Dim bFinished As Integer
    Dim bAppend As Integer
    Dim iMenuSize As Integer ' how many items to display on screen
    Dim iMenuPos As Integer ' where in the list we are
    Dim iMenuStart As Integer ' first item to display on the list
    Dim iMenuEnd As Integer ' last item to display on the list
    Dim iMenuLoop As Integer
    Dim iStartRow As Integer
    Dim iPromptRow As Integer
    Dim iRow As Integer
    Dim iCol As Integer
    Dim iColCount As Integer
    Dim iLastKey As Integer
    Dim iPageSize As Integer
    Dim iNudgeSize As Integer ' when cursor reaches bottom or top, how many lines to scroll
    Dim bMoved As Integer
    Dim bInitPage As Integer
    Dim in$

    ' INITIALIZE
    iMenuSize = 20
    iNudgeSize = iMenuSize \ 2
    iPageSize = iMenuSize - iNudgeSize
    iMenuPos = LBound(m_arrMenu)
    iMenuStart = iMenuPos
    iColCount = _Width(0) \ _FontWidth
    sFileName = m_ProgramPath$ + Left$(m_ProgramName$, Len(m_ProgramName$) - 4) + ".txt"
    iStartRow = 7
    iPromptRow = iMenuSize + 10
    bInitPage = TRUE

    ' SETUP SCREEN
    Screen _NewImage(1024, 768, 32): _ScreenMove 0, 0

    ' PLAY SOUNDS
    iLastKey = 0
    bMoved = TRUE
    bFinished = FALSE
    Do
        ' SHOW INSTRUCTIONS
        If bInitPage = TRUE Then
            Cls , cBlack ' makes the background opaque black
            Color cDodgerBlue, cBlack
            PrintString 0, 0, "Listen to QB64 Sound Samples"

            Color cCyan, cBlack
            PrintString 2, 0, "KEY(S)                                ACTION"
            PrintString 3, 0, "-----------------------------------   --------------------------------"
            PrintString 4, 0, "Crsr Up/Down, PgUp/PgDown, Home/End   Navigate/select sound"
            PrintString 5, 0, "Crsr Left                             Play selected sound"
            PrintString 6, 0, "Crsr Right                            Save comments for selected sound"
            ClearKeyboard 1
            bInitPage = FALSE
        End If

        ' (RE)DISPLAY CURRENT SLICE OF THE MENU
        If bMoved = TRUE Then
            iRow = iStartRow
            iCol = 0
            If iMenuStart < LBound(m_arrMenu) Then
                iMenuStart = LBound(m_arrMenu)
            End If
            iMenuEnd = (iMenuStart + iMenuSize) - 1
            If iMenuEnd > UBound(m_arrMenu) Then
                If iMenuSize >= UBound(m_arrMenu) Then
                    iMenuStart = UBound(m_arrMenu) - (iMenuSize - 1)
                Else
                    iMenuStart = LBound(m_arrMenu)
                    iMenuEnd = UBound(m_arrMenu)
                End If
            End If
            For iMenuLoop = iMenuStart To iMenuEnd
                iRow = iRow + 1
                If iMenuLoop = iMenuPos Then
                    Color cBlack, cWhite
                Else
                    Color cWhite, cBlack
                End If
                PrintString iRow, iCol, right$("   " + cstr$(iMenuLoop), 3) + ". " + _
                    left$(m_arrMenu(iMenuLoop) + string$(iColCount, " "), iColCount)
            Next iMenuLoop
            bMoved = FALSE
        End If

        ' GET USER INPUT
        While _DeviceInput(1): Wend ' Clear and update the keyboard buffer

        ' DON'T ACCEPT ANY MORE INPUT UNTIL THE LAST PRESSED KEY IS RELEASED
        If iLastKey <> 0 Then
            If _Button(iLastKey) = FALSE Then
                iLastKey = 0
            End If
        End If

        ' READY TO ACCEPT MORE INPUT?
        If iLastKey = 0 Then
            ' DID PLAYER PRESS ANY KEYS WE KNOW?
            If _Button(KeyCode_Home%) Then
                in$ = "home"
                iLastKey = KeyCode_Home%
            ElseIf _Button(KeyCode_End%) Then
                in$ = "end"
                iLastKey = KeyCode_End%
            ElseIf _Button(KeyCode_PgUp%) Then
                in$ = "pgup"
                iLastKey = KeyCode_PgUp%
            ElseIf _Button(KeyCode_PgDn%) Then
                in$ = "pgdn"
                iLastKey = KeyCode_PgDn%
            ElseIf _Button(KeyCode_Up%) Then
                in$ = "up"
                iLastKey = KeyCode_Up%
            ElseIf _Button(KeyCode_Down%) Then
                in$ = "down"
                iLastKey = KeyCode_Down%
            ElseIf _Button(KeyCode_Left%) Then
                in$ = "play"
                iLastKey = KeyCode_Left%
            ElseIf _Button(KeyCode_Right%) Then
                in$ = "comment"
                iLastKey = KeyCode_Right%
            ElseIf _Button(KeyCode_Escape%) Then
                in$ = "esc"
                iLastKey = KeyCode_Escape%
            Else
                in$ = ""
            End If

            ' IF USER DID PRESS A KEY WE KNOW, PROCESS INPUT
            If iLastKey <> 0 Then
                ClearKeyboard 0

                If in$ = "" Then
                    ' (DO NOTHING)
                ElseIf in$ = "home" Then
                    iMenuPos = LBound(m_arrMenu)
                    bMoved = TRUE
                ElseIf in$ = "end" Then
                    iMenuPos = UBound(m_arrMenu)
                    bMoved = TRUE
                ElseIf in$ = "pgup" Then
                    iMenuPos = iMenuPos - iPageSize
                    bMoved = TRUE
                ElseIf in$ = "pgdn" Then
                    iMenuPos = iMenuPos + iPageSize
                    bMoved = TRUE
                ElseIf in$ = "up" Then
                    iMenuPos = iMenuPos - 1
                    bMoved = TRUE
                ElseIf in$ = "down" Then
                    iMenuPos = iMenuPos + 1
                    bMoved = TRUE
                ElseIf in$ = "play" Then
                    ' HIGHLIGHT NAME
                    iRow = iStartRow
                    For iMenuLoop = iMenuStart To iMenuEnd
                        iRow = iRow + 1
                        If iMenuLoop = iMenuPos Then
                            Color cBlack, cYellow
                            PrintString iRow, iCol, right$("   " + cstr$(iMenuLoop), 3) + ". " + _
                                left$(m_arrMenu(iMenuLoop) + string$(iColCount, " "), iColCount)
                            Exit For
                        End If
                    Next iMenuLoop

                    ' PLAY SOUND
                    PlaySoundEffect m_arrMenu(iMenuPos)
                    bMoved = TRUE

                ElseIf in$ = "comment" Then
                    ' PROMPT FOR COMMENTS + SAVE
                    If Len(m_arrMenu(iMenuPos)) > 0 Then
                        ' PROMPT FOR A DESCRIPTION AND APPEND IT TO THE OUTPUT FILE
                        Locate iPromptRow, 1
                        Color cRed, cBlack
                        Print "Current sound is " + quot;
                        Color cBlue, cBlack
                        Print m_arrMenu(iMenuPos);
                        Color cRed, cBlack
                        Print quot + ". "

                        ClearKeyboard 2
                        Color cLime, cBlack
                        Input "Describe the sound (blank to skip) "; sComment
                        ClearKeyboard 0

                        sComment = LTrim$(RTrim$(sComment))
                        If Len(sComment) > 0 Then
                            'sOut = cstr$(iMenuPos) + vbTab + m_arrMenu(iMenuPos) + vbTab + sComment '+ vbCrLf
                            sOut = m_arrMenu(iMenuPos) + " ' " + sComment

                            bAppend = _FileExists(sFileName)
                            sError = PrintFile$(sFileName, sOut, bAppend)
                            If Len(sError) = 0 Then
                                DebugPrint "Wrote output to file " + Chr$(34) + sFileName + Chr$(34) + "."
                            Else
                                DebugPrint "Could not write to file " + Chr$(34) + sFileName + Chr$(34) + "."
                                DebugPrint sError

                                Print "Could not write to file " + Chr$(34) + sFileName + Chr$(34) + "."
                                Print sError

                                ClearKeyboard 3
                                Input "Press <ENTER> to continue"; in$

                            End If
                        End If
                        ClearKeyboard 0

                        iCol = 0
                        For iRow = iPromptRow - 1 To (iPromptRow + 10)
                            Color cBlack, cBlack
                            PrintString iRow, iCol, String$(iColCount, " ")
                        Next iRow

                        'bInitPage = TRUE
                        bMoved = TRUE
                    End If ' If Len(m_arrMenu(iMenuPos)) > 0 Then

                ElseIf in$ = "esc" Then
                    bFinished = TRUE
                    Exit Do
                End If

                ' HANDLE MOVE
                If bMoved = TRUE Then
                    ' MAKE SURE NOT OUT OF BOUNDS
                    If iMenuPos < LBound(m_arrMenu) Then
                        iMenuPos = LBound(m_arrMenu)
                    ElseIf iMenuPos > UBound(m_arrMenu) Then
                        iMenuPos = UBound(m_arrMenu)
                    End If

                    ' DETERMINE WHAT RANGE TO DISPLAY
                    If iMenuPos < iMenuStart Then
                        iMenuStart = iMenuPos - iNudgeSize
                        If iMenuStart < LBound(m_arrMenu) Then
                            iMenuStart = LBound(m_arrMenu)
                        End If
                        iMenuEnd = iMenuStart + (iMenuSize - 1)
                        If iMenuEnd > UBound(m_arrMenu) Then
                            iMenuEnd = UBound(m_arrMenu)
                        End If
                    ElseIf iMenuPos > iMenuEnd Then
                        iMenuEnd = iMenuPos + iNudgeSize
                        If iMenuEnd > UBound(m_arrMenu) Then
                            iMenuEnd = UBound(m_arrMenu)
                        End If
                        iMenuStart = iMenuEnd - (iMenuSize - 1)
                        If iMenuStart < LBound(m_arrMenu) Then
                            iMenuStart = LBound(m_arrMenu)
                        End If
                    End If

                End If
            End If ' iLastKey <> 0
        End If ' IF iLastKey = 0
    Loop Until bFinished = TRUE

    While _DeviceInput(1): Wend ' Clear and update the keyboard buffer
    ClearKeyboard 3

    ReviewSounds$ = sResult
End Function ' ReviewSounds$

' /////////////////////////////////////////////////////////////////////////////

Function DisplayCredits$
    Dim iRowCount As Integer
    Dim iCount As Integer
    Dim iLoop As Integer
    Dim in$
    Dim bFinished As Integer

    iRowCount = _Height(0) \ _FontHeight
    iCount = 0
    Cls
    For iLoop = LBound(m_arrCredits) To UBound(m_arrCredits)
        If InStr(LCase$(m_arrCredits(iLoop)), "http:") = 0 Then
            If InStr(LCase$(m_arrCredits(iLoop)), "https:") = 0 Then
                Print m_arrCredits(iLoop)
                iCount = iCount + 1
                If iCount > (iRowCount - 8) Then
                    Print ""
                    bFinished = FALSE
                    Do
                        Input "PRESS <ENTER> TO CONTINUE OR TYPE Q TO EXIT"; in$
                        If LCase$(_Trim$(in$)) = "q" Then
                            Exit For
                            'elseif lcase$(_Trim$(in$)) = "c" then
                        Else
                            iCount = 0
                            bFinished = TRUE
                        End If
                    Loop Until bFinished = TRUE
                End If
            End If
        End If
    Next iLoop
    If LCase$(_Trim$(in$)) <> "q" Then
        Input "PRESS <ENTER> TO CONTINUE OR TYPE Q TO EXIT"; in$
    End If
    DisplayCredits$ = ""
End Function ' DisplayCredits$
' /////////////////////////////////////////////////////////////////////////////

Sub ClearKeyboard (iDelay%)
    Dim k As Integer
    _KeyClear
    If iDelay% = 1 Then
        _Delay iDelay%
    End If
    If iDelay% > 1 Then
        While _DeviceInput(1): Wend ' Clear and update the keyboard buffer
    End If
    If iDelay% > 2 Then
        k = _KeyHit
    End If
End Sub ' ClearKeyboard

' /////////////////////////////////////////////////////////////////////////////

Sub AddNextMenuItem (sName As String)
    ReDim _Preserve m_arrMenu(1 To UBound(m_arrMenu) + 1) As String
    m_arrMenu(UBound(m_arrMenu)) = sName
End Sub ' AddNextMenuItem

' /////////////////////////////////////////////////////////////////////////////

Sub AddNextAttribItem (sInfo As String)
    ReDim _Preserve m_arrCredits(1 To UBound(m_arrCredits) + 1) As String
    m_arrCredits(UBound(m_arrCredits)) = sInfo
End Sub ' AddNextAttribItem

' /////////////////////////////////////////////////////////////////////////////

Sub InitializeGlobal
    AddNextMenuItem "ALRMBOBS_BAS_sound_1"
    AddNextMenuItem "ANSISHOW_BAS_sound_1_LONG"
    AddNextMenuItem "ANSISUB_BAS_sound_1_LONG"
    AddNextMenuItem "ANSISUB_BAS_sound_2"
    AddNextMenuItem "ARG_BAS_sound_1"
    AddNextMenuItem "arqanoid_BAS_sound_1"
    AddNextMenuItem "arqanoid_BAS_sound_2"
    AddNextMenuItem "arqanoid_BAS_sound_3"
    AddNextMenuItem "arqanoid_BAS_sound_4"
    AddNextMenuItem "arqanoid_BAS_sound_5"
    AddNextMenuItem "arqanoid_BAS_sound_6"
    AddNextMenuItem "arqanoid_BAS_sound_7"
    AddNextMenuItem "arqanoid_BAS_sound_8"
    AddNextMenuItem "arqanoid_BAS_sound_9"
    AddNextMenuItem "arqanoid_BAS_DosoundP"
    AddNextMenuItem "arqanoid_BAS_Dosound2P"
    AddNextMenuItem "BEEP_BAS_SOUND_cricket"
    AddNextMenuItem "BEEP_BAS_SOUND_frog"
    AddNextMenuItem "BEEP_BAS_SOUND_phone"
    AddNextMenuItem "BEEP_BAS_SOUND_wolfwhistle"
    AddNextMenuItem "BombBas_Sound_1"
    AddNextMenuItem "bplus_asteroids_makeover_sound_1a"
    AddNextMenuItem "bplus_asteroids_makeover_sound_1b"
    AddNextMenuItem "bplus_asteroids_makeover_sound_2"
    AddNextMenuItem "bplus_asteroids_makeover_sound_3"
    AddNextMenuItem "bplus_asteroids_makeover_sound_4"
    AddNextMenuItem "CLOCK_BAS_tick"
    AddNextMenuItem "CLOCK_BAS_Alarm"
    AddNextMenuItem "CONSANSI_BAS_SOUND_1"
    AddNextMenuItem "cr_bas_sound_1"
    AddNextMenuItem "cr_bas_sound_2"
    AddNextMenuItem "cr_bas_sound_3"
    AddNextMenuItem "cr_bas_sound_4"
    AddNextMenuItem "cr_bas_sound_5"
    AddNextMenuItem "cr_bas_sound_6"
    AddNextMenuItem "cr_bas_sound_7"
    AddNextMenuItem "cr_bas_sound_8"
    AddNextMenuItem "cr_bas_sound_9"
    AddNextMenuItem "cr_bas_sound_10"
    AddNextMenuItem "cr_bas_sound_11"
    AddNextMenuItem "cr_bas_sound_12_TUNE"
    AddNextMenuItem "cr_bas_sound_13"
    AddNextMenuItem "cr_bas_sound_14_tune_LONG"
    AddNextMenuItem "DEMO_BTN_Click"
    AddNextMenuItem "demo3_Bounce"
    AddNextMenuItem "demo3_fall"
    AddNextMenuItem "demo3_siren"
    AddNextMenuItem "demo3_klaxon"
    AddNextMenuItem "ELYSIAN_fp1"
    AddNextMenuItem "ELYSIAN_fp2"
    AddNextMenuItem "ELYSIAN_fp3_LONG"
    AddNextMenuItem "ELYSIAN_csound"
    AddNextMenuItem "FADE_IO_BAS_SOUND_1"
    AddNextMenuItem "frog_bas_sound_1"
    AddNextMenuItem "frog_bas_sound_2"
    AddNextMenuItem "frog_bas_sound_3"
    AddNextMenuItem "Frostbite_Tribute_beta_6_sound_1"
    AddNextMenuItem "Frostbite_Tribute_beta_6_sound_2"
    AddNextMenuItem "golf_bas_sound_1"
    AddNextMenuItem "KISSED_BAS_sound_1_alarm"
    AddNextMenuItem "KISSED_BAS_sound_2_noise"
    AddNextMenuItem "KWIKVIEW_BAS_SOUND_1"
    AddNextMenuItem "hangman_bas_sound_1"
    AddNextMenuItem "hangman_bas_sound_2"
    AddNextMenuItem "leapfrog_bas_sound_1"
    AddNextMenuItem "leapfrog_bas_sound_2"
    AddNextMenuItem "leapfrog_bas_sound_3"
    AddNextMenuItem "leapfrog_bas_sound_4"
    AddNextMenuItem "leapfrog_bas_sound_5"
    AddNextMenuItem "leapfrog_bas_sound_6"
    AddNextMenuItem "LLED_BAS_SOUND_1"
    AddNextMenuItem "LLED_BAS_SOUND_2"
    AddNextMenuItem "LLED_BAS_SOUND_3"
    AddNextMenuItem "macattak_sound_1"
    AddNextMenuItem "macattak_sound_2"
    AddNextMenuItem "macattak_sound_3"
    AddNextMenuItem "macattak_sound_4"
    AddNextMenuItem "MONOP_BAS_SOUND_1"
    AddNextMenuItem "MONOP_BAS_SOUND_2"
    AddNextMenuItem "MONOP_BAS_SOUND_3"
    AddNextMenuItem "MONOP_BAS_SOUND_4"
    AddNextMenuItem "MONOP_BAS_SOUND_5"
    AddNextMenuItem "MONOP_BAS_SOUND_6"
    AddNextMenuItem "MONOP_BAS_SOUND_7"
    AddNextMenuItem "MOON_BAS_SOUND_1"
    AddNextMenuItem "mooncr_sounds_1"
    AddNextMenuItem "mooncr_sounds_2"
    AddNextMenuItem "mooncr_sounds_3"
    AddNextMenuItem "mooncr_sounds_4"
    AddNextMenuItem "mooncr_sounds_5"
    AddNextMenuItem "mooncr_sounds_6"
    AddNextMenuItem "mooncr_sounds_7"
    AddNextMenuItem "mooncr_sounds_8"
    AddNextMenuItem "mooncr_sounds_9"
    AddNextMenuItem "mooncr_sounds_10"
    AddNextMenuItem "mooncr_sounds_11"
    AddNextMenuItem "mooncr_sounds_12"
    AddNextMenuItem "mooncr_sounds_13"
    AddNextMenuItem "mooncr_sounds_14"
    AddNextMenuItem "mooncr_sounds_15"
    AddNextMenuItem "mooncr_sounds_16"
    AddNextMenuItem "mooncr_sounds_17"
    AddNextMenuItem "mooncr_sounds_18"
    AddNextMenuItem "mooncr_sounds_19"
    AddNextMenuItem "mooncr_sounds_20"
    AddNextMenuItem "mooncr_sounds_21"
    AddNextMenuItem "mooncr_sounds_22"
    AddNextMenuItem "mooncr_sounds_23_LONG"
    AddNextMenuItem "mooncr_sounds_24"
    AddNextMenuItem "mooncr_sounds_25"
    AddNextMenuItem "mooncr_sounds_26"
    AddNextMenuItem "mooncr_sounds_27"
    AddNextMenuItem "mooncr_sounds_28"
    AddNextMenuItem "mooncr_sounds_29"
    AddNextMenuItem "mooncr_sounds_30"
    AddNextMenuItem "mooncr_sounds_31"
    AddNextMenuItem "mooncr_sounds_32"
    AddNextMenuItem "mooncr_sounds_33"
    AddNextMenuItem "mooncr_sounds_34"
    AddNextMenuItem "mooncr_sounds_35"
    AddNextMenuItem "mooncr_sounds_36"
    AddNextMenuItem "mooncr_sounds_37"
    AddNextMenuItem "mooncr_sounds_38_BSG_LONG"
    AddNextMenuItem "mooncr_sounds_39_BSG_LONG"
    AddNextMenuItem "mooncr_sounds_40_BSG_LONG"
    AddNextMenuItem "mooncr_sounds_41"
    AddNextMenuItem "mooncr_sounds_42_BSG_LONG"
    AddNextMenuItem "mooncr_sounds_43_BSG_LONG"
    AddNextMenuItem "mooncr_sounds_44_LONG"
    AddNextMenuItem "mosh_at_a_and_p_sound_1"
    AddNextMenuItem "mosh_at_a_and_p_theme"
    AddNextMenuItem "NDXCRLF_BAS_SOUND_1"
    AddNextMenuItem "PAC_MAN_Chirp1"
    AddNextMenuItem "PAC_MAN_Chirp2"
    AddNextMenuItem "PAC_MAN_Chirp3"
    AddNextMenuItem "PAC_MAN_Chirp4"
    AddNextMenuItem "PAC_MAN_Chirp5"
    AddNextMenuItem "POLFILL_BAS_sound"
    AddNextMenuItem "QBLANDER_BAS_SOUND_1"
    AddNextMenuItem "QBW_BAS_sound_1"
    AddNextMenuItem "QBW_BAS_sound_2"
    AddNextMenuItem "RMORTIS2_sound_1"
    AddNextMenuItem "RMORTIS2_sound_2"
    AddNextMenuItem "SCROLL12_BAS_SOUND_1"
    AddNextMenuItem "SEARCH_BAS_SOUND_1"
    AddNextMenuItem "SLIME_BAS_SOUND_1"
    AddNextMenuItem "SLIME_BAS_SOUND_2_LONG"
    AddNextMenuItem "SLIME_BAS_SOUND_3"
    AddNextMenuItem "SLIME_BAS_SOUND_4"
    AddNextMenuItem "SLIME_BAS_SOUND_5"
    AddNextMenuItem "SLIME_BAS_SOUND_6"
    AddNextMenuItem "SLIME_BAS_SOUND_7"
    AddNextMenuItem "SLIME_BAS_SOUND_8"
    AddNextMenuItem "SLIME_BAS_SOUND_9"
    AddNextMenuItem "SLIME_BAS_SOUND_10"
    AddNextMenuItem "SLIME_BAS_SOUND_11"
    AddNextMenuItem "SLIME_BAS_SOUND_12"
    AddNextMenuItem "SLIME_BAS_SOUND_13"
    AddNextMenuItem "SLIME_BAS_SOUND_14"
    AddNextMenuItem "SLOTS_sound_1"
    AddNextMenuItem "SLOTS_sound_2"
    AddNextMenuItem "snatch_bas_sound_1_squirrel"
    AddNextMenuItem "snatch_bas_sound_2_rabbit"
    AddNextMenuItem "snatch_bas_sound_3_chipmunk"
    AddNextMenuItem "snatch_bas_sound_4_groundhog"
    AddNextMenuItem "snatch_bas_sound_5"
    AddNextMenuItem "snatch_bas_sound_6"
    AddNextMenuItem "softintheheadware_sound3_bas"
    AddNextMenuItem "softintheheadware_sound2_bas"
    AddNextMenuItem "SOUND_18WHEELR_BAS_1"
    AddNextMenuItem "SOUND_18WHEELR_BAS_2"
    AddNextMenuItem "StarBlast_BAS_sound_1"
    AddNextMenuItem "StarBlast_BAS_sound_2"
    AddNextMenuItem "StarBlast_BAS_sound_3"
    AddNextMenuItem "StarBlast_BAS_sound_4"
    AddNextMenuItem "StarBlast_BAS_sound_5"
    AddNextMenuItem "StarBlast_BAS_sound_6"
    AddNextMenuItem "StarBlast_BAS_sound_7"
    AddNextMenuItem "StarBlast_BAS_sound_8"
    AddNextMenuItem "StarBlast_BAS_sound_9"
    AddNextMenuItem "StarBlast_BAS_sound_10"
    AddNextMenuItem "StarBlast_BAS_sound_11"
    AddNextMenuItem "StarBlast_BAS_sound_12"
    AddNextMenuItem "STEEL_BAS_sound_1"
    AddNextMenuItem "STEEL_BAS_sound_2"
    AddNextMenuItem "Tank_Walls_2_BAS_sound_1"
    AddNextMenuItem "tech_invaders_2_sound_1"
    AddNextMenuItem "tech_invaders_2_OPENINGSOUND"
    AddNextMenuItem "temple_bas_sound_1"
    AddNextMenuItem "temple_bas_sound_2"
    AddNextMenuItem "temple_bas_sound_3"
    AddNextMenuItem "temple_bas_sound_4"
    AddNextMenuItem "temple_bas_sound_5"
    AddNextMenuItem "temple_bas_sound_6"
    AddNextMenuItem "temple_bas_sound_7"
    AddNextMenuItem "temple_bas_sound_8"
    AddNextMenuItem "temple_bas_sound_9"
    AddNextMenuItem "THEWOODS_BAS_sound_1"
    AddNextMenuItem "THEWOODS_BAS_sound_2"
    AddNextMenuItem "Tiny_Dungeon_sound_1_drumming"
    AddNextMenuItem "Tiny_Dungeon_sound_2_drumming_v2"
    AddNextMenuItem "TRIANGU2_BAS_sound_1"
    AddNextMenuItem "UnderWare_sound_1_Rocket"
    AddNextMenuItem "UnderWare_sound_2_MachineGun"
    AddNextMenuItem "UnderWare_sound_3_LowPitchedWarble"
    AddNextMenuItem "UnderWare_sound_4_HighPitchedWarble"
    AddNextMenuItem "UnderWare_sound_5_FlyingSaucerSlow"
    AddNextMenuItem "UnderWare_sound_6_FlyingSaucerFast"
    AddNextMenuItem "UnderWare_sound_7_TumblingSound"
    AddNextMenuItem "UnderWare_uwl_subs_bas_sound_1"
    AddNextMenuItem "waster_bas_sound_1"
    AddNextMenuItem "waster_bas_sound_2"
    AddNextMenuItem "waster_bas_sound_3"
    AddNextMenuItem "waster_bas_sound_4"
    AddNextMenuItem "waster_bas_sound_5"
    AddNextMenuItem "waster_bas_sound_6"
    AddNextMenuItem "waster_bas_sound_7"
    AddNextMenuItem "waster_bas_sound_8"
    AddNextMenuItem "waster_bas_sound_9"
    AddNextMenuItem "waster_bas_sound_10"
    AddNextMenuItem "waster_bas_sound_11"
    AddNextMenuItem "waster_bas_sound_12"
    AddNextMenuItem "waster_bas_sound_13"
    AddNextMenuItem "waster_bas_sound_14"
    AddNextMenuItem "waster_bas_sound_15"
    AddNextMenuItem "waster_bas_sound_16"
    AddNextMenuItem "waster_bas_sound_17"
    AddNextMenuItem "xgame_bas_sound_1"
    AddNextMenuItem "xgame_bas_sound_2"
    AddNextMenuItem "xgame_bas_sound_3"
    AddNextMenuItem "xgame_bas_sound_4"
    AddNextMenuItem "xgame_bas_sound_5"
    AddNextMenuItem "xgame_bas_sound_6"
    AddNextMenuItem "xgame_bas_sound_7_LONG"
    AddNextMenuItem "xgame_bas_sound_8_LONG"
    AddNextMenuItem "xwing_bas_sound_1_theme"
    AddNextMenuItem "xwing_bas_sound_2"
    AddNextMenuItem "xwing_bas_sound_3"

    AddNextAttribItem "CREDITS / ATTRIBUTION:"
    AddNextAttribItem ""
    AddNextAttribItem "The following lists the source programs the sound routines came from, "
    AddNextAttribItem "the original programmers (where known). "
    AddNextAttribItem "(Each sound routine has the original program's name in the sub name.)"
    AddNextAttribItem ""
    AddNextAttribItem "Source Program                               Author/Info/Source URLs"
    AddNextAttribItem "------------------------------------------   ----------------------------------"
    AddNextAttribItem "18WHEELR.BAS                                 Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "ALRMBOBS.BAS                                 Released to PUBLIC DOMAIN by Kurt Kuzba. (3/10/96)"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "ANSISHOW.BAS                                 Unknown"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "ANSISUB.BAS                                  Released to PUBLIC DOMAIN by Kurt Kuzba. (1/22/96)"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "ARG!!.BAS (qb_src.zip)                       From: Andrew Jones, Date: 04-14-96 14:33, "
    AddNextAttribItem "                                             Released to PUBLIC DOMAIN by Kurt Kuzba. (4/28/96)"
    AddNextAttribItem "                                             https://forum.thegamecreators.com/thread/222397"
    AddNextAttribItem "arqanoid.bas                                 Galleondragon"
    AddNextAttribItem "                                             https://github.com/Galleondragon/qb64/blob/master/programs/samples/qb45com/action/arqanoid/arqanoid.bas"
    AddNextAttribItem "BEEP!.BAS                                    Unknown"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "                                             http://nasm.rm-f.net/~jon/BASIC/QBASIC/"
    AddNextAttribItem "bomb.bas                                     By Dave Duvenaud"
    AddNextAttribItem "                                             https://www.ocf.berkeley.edu/~horie/bomb.bas"
    AddNextAttribItem "bplus_asteroids_makeover.bas                 Asteroids Makeover by bplus"
    AddNextAttribItem "                                             https://www.qb64.org/forum/index.php?topic=3173.0"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?topic=3173.msg124947#msg124947"
    AddNextAttribItem "CLOCK.BAS                                    UnderWARE Labs"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/CLOCK.txt"
    AddNextAttribItem "CONSANSI.BAS                                 Unknown"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "CR.BAS                                       CAVE RAIDER Version 1.4, Copyright (c) 2004 by Paul Redling"
    AddNextAttribItem "                                             https://dosgamer.com/games/play/cave-raider-4612.html"
    AddNextAttribItem "                                             https://archive.org/details/CaveRaider"
    AddNextAttribItem "DEMO_BTN.txt (Qb_junk.zip)                   Text screen Mouse and Button Demo - and included SUBs."
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/uwl_files.html"
    AddNextAttribItem "DEMO3.BAS                                    Microsoft Programmer's Library 1.3 CD-ROM"
    AddNextAttribItem "                                             https://www.pcjs.org/documents/books/mspl13/basic/qblearn/"
    AddNextAttribItem "                                             https://www.pcjs.org/documents/books/mspl13/"
    AddNextAttribItem "ELYSIAN.BAS                                  Elysian Fields by Pantera55@aol.com, released May 2nd, 1998 as freeware."
    AddNextAttribItem "                                             http://petesqbsite.com/reviews/rpgs/elysian.html"
    AddNextAttribItem "                                             http://members.aol.com/Pantera55/"
    AddNextAttribItem "FADE-IO.BAS                                  Released to PUBLIC DOMAIN by Kurt Kuzba. (1/21/96)"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "frog.bas                                     RETRO.BAS by Matt Bross, 1997, oh_bother@GeoCities.Com"
    AddNextAttribItem "                                             https://github.com/Galleondragon/qb64/blob/master/programs/samples/misc/samples.txt"
    AddNextAttribItem "                                             http://www.GeoCities.Com/SoHo/7067/"
    AddNextAttribItem "Frostbite Tribute (Beta 6).bas               FellippeHeitor, July 17, 2018, 12:01:48 AM"
    AddNextAttribItem "                                             https://www.qb64.org/forum/index.php?topic=342.0"
    AddNextAttribItem "GOLF.BAS                                     Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "HANGMAN.BAS                                  Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "KISSED.BAS                                   Unknown"
    AddNextAttribItem "                                             http://mangoun.c-scene.org/~jon/BASIC/QBASIC/SOURCE/PD/KISSED.BAS"
    AddNextAttribItem "                                             http://mangoun.c-scene.org/~jon/BASIC/QBASIC/"
    AddNextAttribItem "KWIKVIEW.BAS                                 Unknown"
    AddNextAttribItem "                                             http://mangoun.c-scene.org/~jon/BASIC/QBASIC/SOURCE/PD/KWIKVIEW.BAS"
    AddNextAttribItem "                                             http://mangoun.c-scene.org/~jon/BASIC/QBASIC/"
    AddNextAttribItem "leapfrog.bas                                 L E A P F R O G. B A S 2.1 (C) 2002 - 2007 by Bob Seguin (Freeware)"
    AddNextAttribItem "                                             http://bcs.solano.edu/workarea/jurrutia/Coursework/CIS%2001%20-%20Intro%20to%20Computers/Qbasic/QBasic64/qb64/samples/thebob/leapfrog/"
    AddNextAttribItem "LLED.BAS                                     Unknown"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "macattak.bas                                 Mac & Splat! STEELCHARM@AOL.COM"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/"
    AddNextAttribItem "MONOP.BAS                                    MONOPOLY CREATED BY KENNETH SILVERMAN"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "MOON.BAS, qb_src.zip                         From: Earl Montgomery, Date: 11-01-95 15:42"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "mooncr.bas                                   by Daniel Kupfer, dk1000000@aol.com"
    AddNextAttribItem "                                             https://www.qb64.org/forum/index.php?topic=1528.0"
    AddNextAttribItem "MOSH.BAS                                     Mosh At A & P, a game by Softintheheadware, 1997"
    AddNextAttribItem "                                             https://softintheheadware.com"
    AddNextAttribItem "                                             https://sourceforge.net/u/sithw/profile/"
    AddNextAttribItem "mosh_at_a&p.bas                              Mosh At A & P, a game by Softintheheadware, 1997"
    AddNextAttribItem "                                             https://softintheheadware.com"
    AddNextAttribItem "                                             https://sourceforge.net/u/sithw/profile/"
    AddNextAttribItem "NDXCRLF.BAS                                  Unknownh, ttp://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "PAC-MAN.txt                                  P A C M A N  -  R E V I S I T E D ! From UnderWARE Labs(1997)"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/PAC-MAN.txt"
    AddNextAttribItem "POLFILL.BAS, kensqb.zip                      Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "QBLANDER.BAS                                 Unknown"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "                                             http://nasm.rm-f.net/~jon/BASIC/QBASIC/"
    AddNextAttribItem "Qbw_1-1.txt, qbw.zip                         Nice text editor by UnderWare Labs"
    AddNextAttribItem "                                             https://qb45.org/files.php?cat=10&p=8"
    AddNextAttribItem "                                             https://qb45.org/download.php?id=1244"
    AddNextAttribItem "                                             https://qb45.org/files.php?action=search2&keywords=qbw.zip&funcbtn=Search%21"
    AddNextAttribItem "RMORTIS2.BAS                                 Rigor Mortis 2"
    AddNextAttribItem "                                             https://archive.org/details/RigorMortis2"
    AddNextAttribItem "                                             http://www.o-bizz.de/qbdown/qbcom/action.htm"
    AddNextAttribItem "                                             http://community.fortunecity.ws/underworld/digitalstreet/112/qbasic/qbdload.htm"
    AddNextAttribItem "SCROLL12.BAS                                 Released to PUBLIC DOMAIN by Kurt Kuzba. (8/14/98)"
    AddNextAttribItem "                                             http://c.rm-f.net/~jon/BASIC/QBASIC/SOURCE/PD/SCROLL12.BAS"
    AddNextAttribItem "                                             http://nasm.rm-f.net/~jon/BASIC/QBASIC/"
    AddNextAttribItem "SEARCH.BAS                                   PROGRAMMED BY KENNETH SILVERMAN"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "SLIME.BAS                                    Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "SLOTS.txt                                    BASIC - Slots version 1.O - for MS QBasic by UWL"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/SLOTS.txt"
    AddNextAttribItem "SNATCH.BAS                                   Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "SOFTINTHEHEADWARE_SOUND2.BAS                 Softintheheadware"
    AddNextAttribItem "                                             https://softintheheadware.com"
    AddNextAttribItem "                                             https://sourceforge.net/u/sithw/profile/"
    AddNextAttribItem "SOFTINTHEHEADWARE_SOUND3.BAS                 Softintheheadware"
    AddNextAttribItem "                                             https://softintheheadware.com"
    AddNextAttribItem "                                             https://sourceforge.net/u/sithw/profile/"
    AddNextAttribItem "StarBlast_2018-6-19.bas                      SirCrow"
    AddNextAttribItem "                                             https://www.qb64.org/forum/index.php?topic=285.0"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?action=profile;u=91"
    AddNextAttribItem "STEEL.BAS, qb_src.zip                        ILLUSION.BAS by tony cave, Date: 06-07-96 03:01"
    AddNextAttribItem "                                             http://www.thedubber.altervista.org/qbsrc.htm"
    AddNextAttribItem "Tank Walls 2.bas (Tank Walls 2.zip)          Tank Walls 2 by SierraKen"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?topic=1482.0"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?action=profile;u=389"
    AddNextAttribItem "Tech Invaders.bas                            Tech Invaders 2 by SierraKen"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?topic=1537.0"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?action=profile;u=389"
    AddNextAttribItem "temple.bas                                   Temple VERSION 4.2 by John Belew (Nurruc the Chaotic)"
    AddNextAttribItem "                                             of the Apple Eliminators, July 25, 1984"
    AddNextAttribItem "                                             https://github.com/Galleondragon/qb64/blob/master/programs/samples/misc/temple.bas"
    AddNextAttribItem "THEWOODS.BAS                                 PUBLIC DOMAIN by Kurt Kuzba. (6/19/1997)"
    AddNextAttribItem "                                             http://c.rm-f.net/~jon/BASIC/QBASIC/SOURCE/PD/THEWOODS.BAS"
    AddNextAttribItem "                                             http://nasm.rm-f.net/~jon/BASIC/QBASIC/"
    AddNextAttribItem "SierraKen_My 1996 Tiny Dungeon Game v2.bas   My 1996 Tiny Dungeon Game by SierraKen"
    AddNextAttribItem "                                             https://www.qb64.org/forum/index.php?topic=3482.0"
    AddNextAttribItem "                                             https://forum.qb64.org/index.php?action=profile;u=389"
    AddNextAttribItem "TRIANGU2.BAS                                 Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "TANKGAME.txt, SOUND-FX.txt                   UnderWARE Labs"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/TANKGAME.txt"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/SOUND-FX.txt"
    AddNextAttribItem "uwl-subs.bas.txt                             UnderWARE Labs (UWLabs)"
    AddNextAttribItem "                                             http://files.allbasic.info/UnderWare/uwl_files.html"
    AddNextAttribItem "WASTER.BAS                                   Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "XGAME.BAS                                    Ken Silverman's QuickBasic Page"
    AddNextAttribItem "                                             http://advsys.net/ken/qb/qb.htm"
    AddNextAttribItem "XWING.BAS                                    2060-A.BAS, XWING, BROUGHT TO YOU BY DATATECH, MICHAEL KNOX WAUSAU WI 54403,"
    AddNextAttribItem "                                             MODIFIED BY GALLEON TO BE QBASIC COMPATIBLE, QB64 DEMO #5: X-WING FIGHTER"
    AddNextAttribItem "                                             https://github.com/Galleondragon/qb64/blob/master/programs/samples/misc/samples.txt"

End Sub ' InitializeGlobal

' /////////////////////////////////////////////////////////////////////////////

Sub PlaySoundEffect (in$)
    If in$ = "" Then ' (DO NOTHING)
    ElseIf in$ = "tech_invaders_2_sound_1" Then tech_invaders_2_sound_1
    ElseIf in$ = "tech_invaders_2_OPENINGSOUND" Then tech_invaders_2_OPENINGSOUND
    ElseIf in$ = "BombBas_Sound_1" Then BombBas_Sound_1
    ElseIf in$ = "bplus_asteroids_makeover_sound_1a" Then bplus_asteroids_makeover_sound_1a
    ElseIf in$ = "bplus_asteroids_makeover_sound_1b" Then bplus_asteroids_makeover_sound_1b
    ElseIf in$ = "bplus_asteroids_makeover_sound_2" Then bplus_asteroids_makeover_sound_2
    ElseIf in$ = "bplus_asteroids_makeover_sound_3" Then bplus_asteroids_makeover_sound_3
    ElseIf in$ = "bplus_asteroids_makeover_sound_4" Then bplus_asteroids_makeover_sound_4
    ElseIf in$ = "mosh_at_a_and_p_sound_1" Then mosh_at_a_and_p_sound_1
    ElseIf in$ = "UnderWare_sound_1_Rocket" Then UnderWare_sound_1_Rocket
    ElseIf in$ = "UnderWare_sound_2_MachineGun" Then UnderWare_sound_2_MachineGun
    ElseIf in$ = "UnderWare_sound_3_LowPitchedWarble" Then UnderWare_sound_3_LowPitchedWarble
    ElseIf in$ = "UnderWare_sound_4_HighPitchedWarble" Then UnderWare_sound_4_HighPitchedWarble
    ElseIf in$ = "UnderWare_sound_5_FlyingSaucerSlow" Then UnderWare_sound_5_FlyingSaucerSlow
    ElseIf in$ = "UnderWare_sound_6_FlyingSaucerFast" Then UnderWare_sound_6_FlyingSaucerFast
    ElseIf in$ = "UnderWare_sound_7_TumblingSound" Then UnderWare_sound_7_TumblingSound
    ElseIf in$ = "SLOTS_sound_1" Then SLOTS_sound_1
    ElseIf in$ = "SLOTS_sound_2" Then SLOTS_sound_2
    ElseIf in$ = "QBW_BAS_sound_1" Then QBW_BAS_sound_1
    ElseIf in$ = "QBW_BAS_sound_2" Then QBW_BAS_sound_2
    ElseIf in$ = "PAC_MAN_Chirp1" Then PAC_MAN_Chirp1
    ElseIf in$ = "PAC_MAN_Chirp2" Then PAC_MAN_Chirp2
    ElseIf in$ = "PAC_MAN_Chirp3" Then PAC_MAN_Chirp3
    ElseIf in$ = "PAC_MAN_Chirp4" Then PAC_MAN_Chirp4
    ElseIf in$ = "PAC_MAN_Chirp5" Then PAC_MAN_Chirp5
    ElseIf in$ = "UnderWare_uwl_subs_bas_sound_1" Then UnderWare_uwl_subs_bas_sound_1
    ElseIf in$ = "DEMO_BTN_Click" Then DEMO_BTN_Click
    ElseIf in$ = "CLOCK_BAS_tick" Then CLOCK_BAS_tick
    ElseIf in$ = "CLOCK_BAS_Alarm" Then CLOCK_BAS_Alarm
    ElseIf in$ = "macattak_sound_1" Then macattak_sound_1
    ElseIf in$ = "macattak_sound_2" Then macattak_sound_2
    ElseIf in$ = "macattak_sound_3" Then macattak_sound_3
    ElseIf in$ = "macattak_sound_4" Then macattak_sound_4
    ElseIf in$ = "Frostbite_Tribute_beta_6_sound_1" Then Frostbite_Tribute_beta_6_sound_1
    ElseIf in$ = "Frostbite_Tribute_beta_6_sound_2" Then Frostbite_Tribute_beta_6_sound_2
    ElseIf in$ = "xwing_bas_sound_1_theme" Then xwing_bas_sound_1_theme
    ElseIf in$ = "xwing_bas_sound_2" Then xwing_bas_sound_2
    ElseIf in$ = "xwing_bas_sound_3" Then xwing_bas_sound_3
    ElseIf in$ = "temple_bas_sound_1" Then temple_bas_sound_1
    ElseIf in$ = "temple_bas_sound_2" Then temple_bas_sound_2
    ElseIf in$ = "temple_bas_sound_3" Then temple_bas_sound_3
    ElseIf in$ = "temple_bas_sound_4" Then temple_bas_sound_4
    ElseIf in$ = "temple_bas_sound_5" Then temple_bas_sound_5
    ElseIf in$ = "temple_bas_sound_6" Then temple_bas_sound_6
    ElseIf in$ = "temple_bas_sound_7" Then temple_bas_sound_7
    ElseIf in$ = "temple_bas_sound_8" Then temple_bas_sound_8
    ElseIf in$ = "temple_bas_sound_9" Then temple_bas_sound_9
    ElseIf in$ = "mooncr_sounds_1" Then mooncr_sounds_1
    ElseIf in$ = "mooncr_sounds_2" Then mooncr_sounds_2
    ElseIf in$ = "mooncr_sounds_3" Then mooncr_sounds_3
    ElseIf in$ = "mooncr_sounds_4" Then mooncr_sounds_4
    ElseIf in$ = "mooncr_sounds_5" Then mooncr_sounds_5
    ElseIf in$ = "mooncr_sounds_6" Then mooncr_sounds_6
    ElseIf in$ = "mooncr_sounds_7" Then mooncr_sounds_7
    ElseIf in$ = "mooncr_sounds_8" Then mooncr_sounds_8
    ElseIf in$ = "mooncr_sounds_9" Then mooncr_sounds_9
    ElseIf in$ = "mooncr_sounds_10" Then mooncr_sounds_10
    ElseIf in$ = "mooncr_sounds_11" Then mooncr_sounds_11
    ElseIf in$ = "mooncr_sounds_12" Then mooncr_sounds_12
    ElseIf in$ = "mooncr_sounds_13" Then mooncr_sounds_13
    ElseIf in$ = "mooncr_sounds_14" Then mooncr_sounds_14
    ElseIf in$ = "mooncr_sounds_15" Then mooncr_sounds_15
    ElseIf in$ = "mooncr_sounds_16" Then mooncr_sounds_16
    ElseIf in$ = "mooncr_sounds_17" Then mooncr_sounds_17
    ElseIf in$ = "mooncr_sounds_18" Then mooncr_sounds_18
    ElseIf in$ = "mooncr_sounds_19" Then mooncr_sounds_19
    ElseIf in$ = "mooncr_sounds_20" Then mooncr_sounds_20
    ElseIf in$ = "mooncr_sounds_21" Then mooncr_sounds_21
    ElseIf in$ = "mooncr_sounds_22" Then mooncr_sounds_22
    ElseIf in$ = "mooncr_sounds_23_LONG" Then mooncr_sounds_23_LONG
    ElseIf in$ = "mooncr_sounds_24" Then mooncr_sounds_24
    ElseIf in$ = "mooncr_sounds_25" Then mooncr_sounds_25
    ElseIf in$ = "mooncr_sounds_26" Then mooncr_sounds_26
    ElseIf in$ = "mooncr_sounds_27" Then mooncr_sounds_27
    ElseIf in$ = "mooncr_sounds_28" Then mooncr_sounds_28
    ElseIf in$ = "mooncr_sounds_29" Then mooncr_sounds_29
    ElseIf in$ = "mooncr_sounds_30" Then mooncr_sounds_30
    ElseIf in$ = "mooncr_sounds_31" Then mooncr_sounds_31
    ElseIf in$ = "mooncr_sounds_32" Then mooncr_sounds_32
    ElseIf in$ = "mooncr_sounds_33" Then mooncr_sounds_33
    ElseIf in$ = "mooncr_sounds_34" Then mooncr_sounds_34
    ElseIf in$ = "mooncr_sounds_35" Then mooncr_sounds_35
    ElseIf in$ = "mooncr_sounds_36" Then mooncr_sounds_36
    ElseIf in$ = "mooncr_sounds_37" Then mooncr_sounds_37
    ElseIf in$ = "mooncr_sounds_38_BSG_LONG" Then mooncr_sounds_38_BSG_LONG
    ElseIf in$ = "mooncr_sounds_39_BSG_LONG" Then mooncr_sounds_39_BSG_LONG
    ElseIf in$ = "mooncr_sounds_40_BSG_LONG" Then mooncr_sounds_40_BSG_LONG
    ElseIf in$ = "mooncr_sounds_41" Then mooncr_sounds_41
    ElseIf in$ = "mooncr_sounds_42_BSG_LONG" Then mooncr_sounds_42_BSG_LONG
    ElseIf in$ = "mooncr_sounds_43_BSG_LONG" Then mooncr_sounds_43_BSG_LONG
    ElseIf in$ = "mooncr_sounds_44_LONG" Then mooncr_sounds_44_LONG
    ElseIf in$ = "leapfrog_bas_sound_1" Then leapfrog_bas_sound_1
    ElseIf in$ = "leapfrog_bas_sound_2" Then leapfrog_bas_sound_2
    ElseIf in$ = "leapfrog_bas_sound_3" Then leapfrog_bas_sound_3
    ElseIf in$ = "leapfrog_bas_sound_4" Then leapfrog_bas_sound_4
    ElseIf in$ = "leapfrog_bas_sound_5" Then leapfrog_bas_sound_5
    ElseIf in$ = "leapfrog_bas_sound_6" Then leapfrog_bas_sound_6
    ElseIf in$ = "frog_bas_sound_1" Then frog_bas_sound_1
    ElseIf in$ = "frog_bas_sound_2" Then frog_bas_sound_2
    ElseIf in$ = "frog_bas_sound_3" Then frog_bas_sound_3
    ElseIf in$ = "cr_bas_sound_1" Then cr_bas_sound_1
    ElseIf in$ = "cr_bas_sound_2" Then cr_bas_sound_2
    ElseIf in$ = "cr_bas_sound_3" Then cr_bas_sound_3
    ElseIf in$ = "cr_bas_sound_4" Then cr_bas_sound_4
    ElseIf in$ = "cr_bas_sound_5" Then cr_bas_sound_5
    ElseIf in$ = "cr_bas_sound_6" Then cr_bas_sound_6
    ElseIf in$ = "cr_bas_sound_7" Then cr_bas_sound_7
    ElseIf in$ = "cr_bas_sound_8" Then cr_bas_sound_8
    ElseIf in$ = "cr_bas_sound_9" Then cr_bas_sound_9
    ElseIf in$ = "cr_bas_sound_10" Then cr_bas_sound_10
    ElseIf in$ = "cr_bas_sound_11" Then cr_bas_sound_11
    ElseIf in$ = "cr_bas_sound_12_TUNE" Then cr_bas_sound_12_TUNE
    ElseIf in$ = "cr_bas_sound_13" Then cr_bas_sound_13
    ElseIf in$ = "cr_bas_sound_14_tune_LONG" Then cr_bas_sound_14_tune_LONG
    ElseIf in$ = "demo3_Bounce" Then demo3_Bounce
    ElseIf in$ = "demo3_fall" Then demo3_fall
    ElseIf in$ = "demo3_siren" Then demo3_siren
    ElseIf in$ = "demo3_klaxon" Then demo3_klaxon
    ElseIf in$ = "hangman_bas_sound_1" Then hangman_bas_sound_1
    ElseIf in$ = "hangman_bas_sound_2" Then hangman_bas_sound_2
    ElseIf in$ = "RMORTIS2_sound_1" Then RMORTIS2_sound_1
    ElseIf in$ = "RMORTIS2_sound_2" Then RMORTIS2_sound_2
    ElseIf in$ = "softintheheadware_sound3_bas" Then softintheheadware_sound3_bas
    ElseIf in$ = "softintheheadware_sound2_bas" Then softintheheadware_sound2_bas
    ElseIf in$ = "mosh_at_a_and_p_theme" Then mosh_at_a_and_p_theme
    ElseIf in$ = "ELYSIAN_fp1" Then ELYSIAN_fp1
    ElseIf in$ = "ELYSIAN_fp2" Then ELYSIAN_fp2
    ElseIf in$ = "ELYSIAN_fp3_LONG" Then ELYSIAN_fp3_LONG
    ElseIf in$ = "ELYSIAN_csound" Then ELYSIAN_csound
    ElseIf in$ = "POLFILL_BAS_sound" Then POLFILL_BAS_sound
    ElseIf in$ = "SOUND_18WHEELR_BAS_1" Then SOUND_18WHEELR_BAS_1
    ElseIf in$ = "SOUND_18WHEELR_BAS_2" Then SOUND_18WHEELR_BAS_2
    ElseIf in$ = "MONOP_BAS_SOUND_1" Then MONOP_BAS_SOUND_1
    ElseIf in$ = "MONOP_BAS_SOUND_2" Then MONOP_BAS_SOUND_2
    ElseIf in$ = "MONOP_BAS_SOUND_3" Then MONOP_BAS_SOUND_3
    ElseIf in$ = "MONOP_BAS_SOUND_4" Then MONOP_BAS_SOUND_4
    ElseIf in$ = "MONOP_BAS_SOUND_5" Then MONOP_BAS_SOUND_5
    ElseIf in$ = "MONOP_BAS_SOUND_6" Then MONOP_BAS_SOUND_6
    ElseIf in$ = "MONOP_BAS_SOUND_7" Then MONOP_BAS_SOUND_7
    ElseIf in$ = "SEARCH_BAS_SOUND_1" Then SEARCH_BAS_SOUND_1
    ElseIf in$ = "SLIME_BAS_SOUND_1" Then SLIME_BAS_SOUND_1
    ElseIf in$ = "SLIME_BAS_SOUND_2_LONG" Then SLIME_BAS_SOUND_2_LONG
    ElseIf in$ = "SLIME_BAS_SOUND_3" Then SLIME_BAS_SOUND_3
    ElseIf in$ = "SLIME_BAS_SOUND_4" Then SLIME_BAS_SOUND_4
    ElseIf in$ = "SLIME_BAS_SOUND_5" Then SLIME_BAS_SOUND_5
    ElseIf in$ = "SLIME_BAS_SOUND_6" Then SLIME_BAS_SOUND_6
    ElseIf in$ = "SLIME_BAS_SOUND_7" Then SLIME_BAS_SOUND_7
    ElseIf in$ = "SLIME_BAS_SOUND_8" Then SLIME_BAS_SOUND_8
    ElseIf in$ = "SLIME_BAS_SOUND_9" Then SLIME_BAS_SOUND_9
    ElseIf in$ = "SLIME_BAS_SOUND_10" Then SLIME_BAS_SOUND_10
    ElseIf in$ = "SLIME_BAS_SOUND_11" Then SLIME_BAS_SOUND_11
    ElseIf in$ = "SLIME_BAS_SOUND_12" Then SLIME_BAS_SOUND_12
    ElseIf in$ = "SLIME_BAS_SOUND_13" Then SLIME_BAS_SOUND_13
    ElseIf in$ = "SLIME_BAS_SOUND_14" Then SLIME_BAS_SOUND_14
    ElseIf in$ = "snatch_bas_sound_1_squirrel" Then snatch_bas_sound_1_squirrel
    ElseIf in$ = "snatch_bas_sound_2_rabbit" Then snatch_bas_sound_2_rabbit
    ElseIf in$ = "snatch_bas_sound_3_chipmunk" Then snatch_bas_sound_3_chipmunk
    ElseIf in$ = "snatch_bas_sound_4_groundhog" Then snatch_bas_sound_4_groundhog
    ElseIf in$ = "snatch_bas_sound_5" Then snatch_bas_sound_5
    ElseIf in$ = "snatch_bas_sound_6" Then snatch_bas_sound_6
    ElseIf in$ = "waster_bas_sound_1" Then waster_bas_sound_1
    ElseIf in$ = "waster_bas_sound_2" Then waster_bas_sound_2
    ElseIf in$ = "waster_bas_sound_3" Then waster_bas_sound_3
    ElseIf in$ = "waster_bas_sound_4" Then waster_bas_sound_4
    ElseIf in$ = "waster_bas_sound_5" Then waster_bas_sound_5
    ElseIf in$ = "waster_bas_sound_6" Then waster_bas_sound_6
    ElseIf in$ = "waster_bas_sound_7" Then waster_bas_sound_7
    ElseIf in$ = "waster_bas_sound_8" Then waster_bas_sound_8
    ElseIf in$ = "waster_bas_sound_9" Then waster_bas_sound_9
    ElseIf in$ = "waster_bas_sound_10" Then waster_bas_sound_10
    ElseIf in$ = "waster_bas_sound_11" Then waster_bas_sound_11
    ElseIf in$ = "waster_bas_sound_12" Then waster_bas_sound_12
    ElseIf in$ = "waster_bas_sound_13" Then waster_bas_sound_13
    ElseIf in$ = "waster_bas_sound_14" Then waster_bas_sound_14
    ElseIf in$ = "waster_bas_sound_15" Then waster_bas_sound_15
    ElseIf in$ = "waster_bas_sound_16" Then waster_bas_sound_16
    ElseIf in$ = "waster_bas_sound_17" Then waster_bas_sound_17
    ElseIf in$ = "xgame_bas_sound_1" Then xgame_bas_sound_1
    ElseIf in$ = "xgame_bas_sound_2" Then xgame_bas_sound_2
    ElseIf in$ = "xgame_bas_sound_3" Then xgame_bas_sound_3
    ElseIf in$ = "xgame_bas_sound_4" Then xgame_bas_sound_4
    ElseIf in$ = "xgame_bas_sound_5" Then xgame_bas_sound_5
    ElseIf in$ = "xgame_bas_sound_6" Then xgame_bas_sound_6
    ElseIf in$ = "xgame_bas_sound_7_LONG" Then xgame_bas_sound_7_LONG
    ElseIf in$ = "xgame_bas_sound_8_LONG" Then xgame_bas_sound_8_LONG
    ElseIf in$ = "golf_bas_sound_1" Then golf_bas_sound_1
    ElseIf in$ = "TRIANGU2_BAS_sound_1" Then TRIANGU2_BAS_sound_1
    ElseIf in$ = "ALRMBOBS_BAS_sound_1" Then ALRMBOBS_BAS_sound_1
    ElseIf in$ = "ANSISHOW_BAS_sound_1_LONG" Then ANSISHOW_BAS_sound_1_LONG
    ElseIf in$ = "ANSISUB_BAS_sound_1_LONG" Then ANSISUB_BAS_sound_1_LONG
    ElseIf in$ = "ANSISUB_BAS_sound_2" Then ANSISUB_BAS_sound_2
    ElseIf in$ = "ARG_BAS_sound_1" Then ARG_BAS_sound_1
    ElseIf in$ = "BEEP_BAS_SOUND_cricket" Then BEEP_BAS_SOUND_cricket
    ElseIf in$ = "BEEP_BAS_SOUND_frog" Then BEEP_BAS_SOUND_frog
    ElseIf in$ = "BEEP_BAS_SOUND_phone" Then BEEP_BAS_SOUND_phone
    ElseIf in$ = "BEEP_BAS_SOUND_wolfwhistle" Then BEEP_BAS_SOUND_wolfwhistle
    ElseIf in$ = "KWIKVIEW_BAS_SOUND_1" Then KWIKVIEW_BAS_SOUND_1
    ElseIf in$ = "LLED_BAS_SOUND_1" Then LLED_BAS_SOUND_1
    ElseIf in$ = "LLED_BAS_SOUND_2" Then LLED_BAS_SOUND_2
    ElseIf in$ = "LLED_BAS_SOUND_3" Then LLED_BAS_SOUND_3
    ElseIf in$ = "MOON_BAS_SOUND_1" Then MOON_BAS_SOUND_1
    ElseIf in$ = "NDXCRLF_BAS_SOUND_1" Then NDXCRLF_BAS_SOUND_1
    ElseIf in$ = "QBLANDER_BAS_SOUND_1" Then QBLANDER_BAS_SOUND_1
    ElseIf in$ = "CONSANSI_BAS_SOUND_1" Then CONSANSI_BAS_SOUND_1
    ElseIf in$ = "FADE_IO_BAS_SOUND_1" Then FADE_IO_BAS_SOUND_1
    ElseIf in$ = "KISSED_BAS_sound_1_alarm" Then KISSED_BAS_sound_1_alarm
    ElseIf in$ = "KISSED_BAS_sound_2_noise" Then KISSED_BAS_sound_2_noise
    ElseIf in$ = "SCROLL12_BAS_SOUND_1" Then SCROLL12_BAS_SOUND_1
    ElseIf in$ = "STEEL_BAS_sound_1" Then STEEL_BAS_sound_1
    ElseIf in$ = "STEEL_BAS_sound_2" Then STEEL_BAS_sound_2
    ElseIf in$ = "THEWOODS_BAS_sound_1" Then THEWOODS_BAS_sound_1
    ElseIf in$ = "THEWOODS_BAS_sound_2" Then THEWOODS_BAS_sound_2
    ElseIf in$ = "StarBlast_BAS_sound_1" Then StarBlast_BAS_sound_1
    ElseIf in$ = "StarBlast_BAS_sound_2" Then StarBlast_BAS_sound_2
    ElseIf in$ = "StarBlast_BAS_sound_3" Then StarBlast_BAS_sound_3
    ElseIf in$ = "StarBlast_BAS_sound_4" Then StarBlast_BAS_sound_4
    ElseIf in$ = "StarBlast_BAS_sound_5" Then StarBlast_BAS_sound_5
    ElseIf in$ = "StarBlast_BAS_sound_6" Then StarBlast_BAS_sound_6
    ElseIf in$ = "StarBlast_BAS_sound_7" Then StarBlast_BAS_sound_7
    ElseIf in$ = "StarBlast_BAS_sound_8" Then StarBlast_BAS_sound_8
    ElseIf in$ = "StarBlast_BAS_sound_9" Then StarBlast_BAS_sound_9
    ElseIf in$ = "StarBlast_BAS_sound_10" Then StarBlast_BAS_sound_10
    ElseIf in$ = "StarBlast_BAS_sound_11" Then StarBlast_BAS_sound_11
    ElseIf in$ = "StarBlast_BAS_sound_12" Then StarBlast_BAS_sound_12
    ElseIf in$ = "Tank_Walls_2_BAS_sound_1" Then Tank_Walls_2_BAS_sound_1
    ElseIf in$ = "arqanoid_BAS_sound_1" Then arqanoid_BAS_sound_1
    ElseIf in$ = "arqanoid_BAS_sound_2" Then arqanoid_BAS_sound_2
    ElseIf in$ = "arqanoid_BAS_sound_3" Then arqanoid_BAS_sound_3
    ElseIf in$ = "arqanoid_BAS_sound_4" Then arqanoid_BAS_sound_4
    ElseIf in$ = "arqanoid_BAS_sound_5" Then arqanoid_BAS_sound_5
    ElseIf in$ = "arqanoid_BAS_sound_6" Then arqanoid_BAS_sound_6
    ElseIf in$ = "arqanoid_BAS_sound_7" Then arqanoid_BAS_sound_7
    ElseIf in$ = "arqanoid_BAS_sound_8" Then arqanoid_BAS_sound_8
    ElseIf in$ = "arqanoid_BAS_sound_9" Then arqanoid_BAS_sound_9
    ElseIf in$ = "arqanoid_BAS_DosoundP" Then arqanoid_BAS_DosoundP
    ElseIf in$ = "arqanoid_BAS_Dosound2P" Then arqanoid_BAS_Dosound2P
    ElseIf in$ = "Tiny_Dungeon_sound_1_drumming" Then Tiny_Dungeon_sound_1_drumming
    ElseIf in$ = "Tiny_Dungeon_sound_2_drumming_v2" Then Tiny_Dungeon_sound_2_drumming_v2
    Else ' (DO NOTHING)
    End If
End Sub ' PlaySoundEffect

' ################################################################################################################################################################
' BEGIN SOUND ROUTINES
' ################################################################################################################################################################

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' down then up (moon buggy jump or pick up object)

Sub mooncr_sounds_10
    SETYPE6$ = "MBT255l40n39n31n25n19n13n7n2n7n10n7n13n15n19n15n22n25n27n25n31n34n39n34n43n46"
    Play SETYPE6$
End Sub ' mooncr_sounds_10

' /////////////////////////////////////////////////////////////////////////////
' medium-quick low to high stepping sound (pick up a power-up or bonus object or got recharged)

Sub mooncr_sounds_11
    SETYPE8$ = "MBT255l32n2n7n10n13n15n19n22n25n27n31n34n39n43n46n58"
    Play SETYPE8$
End Sub ' mooncr_sounds_11

' /////////////////////////////////////////////////////////////////////////////
' quick high to low tones (killed enemy or dropped an object)

Sub mooncr_sounds_12
    SETYPE9$ = "MBT255l40n58n46n43n39n34n31n27n25n22n19n15n13"
    Play SETYPE9$
End Sub ' mooncr_sounds_12

' /////////////////////////////////////////////////////////////////////////////
' high to low then high again (jump or touched an object)

Sub mooncr_sounds_13
    SETYPE10$ = "MBT255l32n56n55n53n50n45n43n41n40n41n43n45n50n53n55n56"
    Play SETYPE10$
End Sub ' mooncr_sounds_13

' /////////////////////////////////////////////////////////////////////////////
' quick ascending warbly sounds low to high (some neutral action like beaming someone down or picking up an object)

Sub mooncr_sounds_20
    SDOCK2$ = "MBT255l32n15n17n15n17n20n25n29n32n37"
    Play SDOCK2$
End Sub ' mooncr_sounds_20

' /////////////////////////////////////////////////////////////////////////////
' fast ascending step sound (shields up or quick warp or repeat for alarm)

Sub mooncr_sounds_30
    SSTAGE2$ = "MBT255l32n19n22n25n27n31n34n39n43n46"
    Play SSTAGE2$
End Sub ' mooncr_sounds_30

' /////////////////////////////////////////////////////////////////////////////
' quick sequence of notes up then down (jumping or handing off an object)

Sub leapfrog_bas_sound_5
    'NewGAME:
    Play "MBT220MSO5L64cP16dP16eP16fP16gP16fP16eP16dP16c"
End Sub ' leapfrog_bas_sound_5

' /////////////////////////////////////////////////////////////////////////////
' quick sequence of notes up then down (happier - maybe accomplished something)

Sub leapfrog_bas_sound_6
    Play "MBT220MSL64O5cP16gP16>cP16gP16cP16<gP16c"
End Sub ' leapfrog_bas_sound_6

' /////////////////////////////////////////////////////////////////////////////
' simple 2 note beep (picked up or dropped object)

Sub cr_bas_sound_2
    'Treasure
    Play "mlt80o4l64ce"
End Sub ' cr_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' 2-note beep sound (dropped object or simple phaser or action)

Sub cr_bas_sound_7
    'Magic wall
    Play "mnt180o4l64ed<dc<c<l32f"
End Sub ' cr_bas_sound_7

' /////////////////////////////////////////////////////////////////////////////
' lower pitched pulsing (quick) for some action

Sub cr_bas_sound_9
    'Explosion
    Play "mlt255o0l32gbagbagbagbagbabg"
End Sub ' cr_bas_sound_9

' /////////////////////////////////////////////////////////////////////////////
' fast descending lower pitched sweep (bumped by an enemy)

Sub cr_bas_sound_11
    'Rock
    Play "mlt255o0l32bagfedc"
End Sub ' cr_bas_sound_11

' /////////////////////////////////////////////////////////////////////////////
' hangman.bas
' lower pitched warble beep (the spelunker sound but short)

Sub hangman_bas_sound_1
    For z = 1 To 10
        Sound Int(200 * Rnd) + 40, .5
    Next z
End Sub ' hangman_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' short lower pitched descending sweep (something falling)

Sub hangman_bas_sound_2
    For z = 166 To 299 Step 6
        Sound 340 - z, 1
    Next z
End Sub ' hangman_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' ELYSIAN.BAS
' fast low to high sweep (picked up an object or some neutral action)

Sub ELYSIAN_fp1
    x = 0
    Do
        x = x + 6
        Sound 40 + x, .3
    Loop Until x > 120
End Sub ' ELYSIAN_fp1

' /////////////////////////////////////////////////////////////////////////////
' fast med to high sweep (some action)

Sub ELYSIAN_fp2
    x = 0
    Do
        x = x + 7
        Sound 80 + x, .3
    Loop Until x > 115
End Sub ' ELYSIAN_fp2

' /////////////////////////////////////////////////////////////////////////////
' POLFILL.BAS
' quick chirpy beep (ascending) - accomplished some action

Sub POLFILL_BAS_sound
    For z% = 0 To 31
        Sound (z% * 160) + 40, .03
        'Sound z% * 16 + 40, .03
    Next z%
End Sub ' POLFILL_BAS_sound

' /////////////////////////////////////////////////////////////////////////////
' quick smooth ascending beep (low to mid) like for refueling or picking up a powerup or repairing

Sub SLIME_BAS_SOUND_3
    For z% = 70 To 300
        Sound z%, .1
    Next z%
End Sub ' SLIME_BAS_SOUND_3

' /////////////////////////////////////////////////////////////////////////////
' quick 3-note ascending beep (picked up an object)

Sub SLIME_BAS_SOUND_4
    For z% = 50 To 350 Step 50
        Sound z%, .5
    Next z%
End Sub ' SLIME_BAS_SOUND_4

' /////////////////////////////////////////////////////////////////////////////
' quick med-to-high smooth ascending sweep (repeat for alarm or picked up some powerup or refueling)

Sub SLIME_BAS_SOUND_8
    For z% = 110 To 660 Step 5
        Sound z%, .1
    Next z%
End Sub ' SLIME_BAS_SOUND_8

' /////////////////////////////////////////////////////////////////////////////
' quick high-to-low smooth ascending sweep (powering down or dropping some object)

Sub SLIME_BAS_SOUND_9
    For z% = 660 To 65 Step -8
        Sound z%, .1
    Next z%
End Sub ' SLIME_BAS_SOUND_9

' /////////////////////////////////////////////////////////////////////////////
' fast low-high-low sweep (maybe like a dog barking)

Sub THEWOODS_BAS_sound_2
    'You have defeated all enemies! You WIN!!
    For t% = 100 To 999 Step 10: Sound t%, .03: Next
    For t% = 1000 To 500 Step -10: Sound t%, .03: Next
End Sub ' THEWOODS_BAS_sound_2

' /////////////////////////////////////////////////////////////////////////////
' StarBlast_2018-07-10.bas
' quick low to high warbly sweep (powerup or phaser-laser)

Sub StarBlast_BAS_sound_1
    'Ship touched Object
    For S = 100 To 600 Step 50: Sound S, .2: Sound S * 3, .2: Next
End Sub ' StarBlast_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' med-high bip or fwip (dropped object or enemy attack)

Sub StarBlast_BAS_sound_3
    For F = 600 To 500 Step -50: Sound F, .3: Next 'Ver. 2
End Sub ' StarBlast_BAS_sound_3

' /////////////////////////////////////////////////////////////////////////////
' high to low sweep (jumping or falling or dropping object)

Sub StarBlast_BAS_sound_8
    'the Energy-Drain Object
    For F = 1700 To 1100 Step -100: Sound F, .75: Next
End Sub ' StarBlast_BAS_sound_8

' /////////////////////////////////////////////////////////////////////////////
' short low to high and higher beep (some action)

Sub arqanoid_BAS_sound_6
    SD = 110
    For I = 1 To 5 'UBOUND(BallExpIndex)
        SD = SD * (2 + (Int(Rnd * 3)))
        'Print SD
        Sound SD, .5
    Next I
End Sub ' arqanoid_BAS_sound_6

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ALERT SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' quick high chirpy alarm sound (enemy action)

Sub mooncr_sounds_17
    SNEW1$ = "MBT255l24n58n57n58n53n57n58"
    Play SNEW1$
End Sub ' mooncr_sounds_17

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ALERT SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' fast high to low descending sound (dropping cargo in space)

Sub mooncr_sounds_7
    SETYPE2$ = "MBT255l40n60n59n58n57n19n13n10n7n2n7n5n1n3n1n2n1"
    Play SETYPE2$
End Sub ' mooncr_sounds_7

' /////////////////////////////////////////////////////////////////////////////
' fast high to low tone with a little bit of an aftertaste (maybe a laser)

Sub mooncr_sounds_14
    SETYPE11$ = "MBT255l64n70n69n68n67n66n65n64n63n62n61n60"
    Play SETYPE11$
End Sub ' mooncr_sounds_14

' /////////////////////////////////////////////////////////////////////////////
' quick lower descending sound (dropped object or negative response or enemy phaser)

Sub mooncr_sounds_15
    SCRASH8$ = "MBT255l64n58n25n19n13n10n7n2n7n5n1n3n1n2n1"
    Play SCRASH8$
End Sub ' mooncr_sounds_15

' /////////////////////////////////////////////////////////////////////////////
' fast high descending sound (phasers or deploy a different weapon)

Sub mooncr_sounds_27
    SHITBOS1$ = "MBT255l64n63n62n61n60n50n40n30n20n13n10n8n7n5n4n3n2n1n1n1"
    Play SHITBOS1$
End Sub ' mooncr_sounds_27

' /////////////////////////////////////////////////////////////////////////////
' fast lower descending sound (closing airlock doors or disable a weapon or device)

Sub mooncr_sounds_28
    SBOSPTS$ = "MBT255l64n46n45n44n43n42n41n40n39n38n37n36n35n34"
    Play SBOSPTS$
End Sub ' mooncr_sounds_28

' /////////////////////////////////////////////////////////////////////////////
' quick descending sweep (jumping or some action)

Sub RMORTIS2_sound_2
    For sv = 0 To 50
        'Sound 65 - sv / 2, .1
        Sound 650 - ((sv * 10) / 2), .1
    Next sv
End Sub ' RMORTIS2_sound_2

' /////////////////////////////////////////////////////////////////////////////
' sound3.bas
' quick ascending sweep (jumping or some action)

Sub softintheheadware_sound3_bas
    Hi = 750
    Lo = 150
    For Count = 200 To 100 Step -5
        Sound Hi - Count, .2
    Next Count
End Sub ' softintheheadware_sound3_bas

' /////////////////////////////////////////////////////////////////////////////
' sound2.bas
' faster ascending sweep (jumping)

Sub softintheheadware_sound2_bas
    Hi = 750
    Lo = 150
    For Count = 200 To 100 Step -4
        Sound Hi - Count, .1
    Next Count
End Sub ' softintheheadware_sound2_bas

' /////////////////////////////////////////////////////////////////////////////
' faster shorter descending laser sound

Sub snatch_bas_sound_3_chipmunk
    'RR(3) = 8
    '530 If I$ = "C" Or I$ = "c" Then Z = Int((RR(3) * Rnd + 2) / 5)

    RR = 8
    Z = Int((RR * Rnd + 2) / 5)
    For ZZ = 1 To Z
        For ZZZ = 600 To 100 Step -20
            Sound ZZZ, .1
        Next ZZZ
    Next ZZ
    '640 GoTo 490
End Sub ' snatch_bas_sound_3_chipmunk

' /////////////////////////////////////////////////////////////////////////////
' quick low-high fweep - droping object or ejected something

Sub ANSISUB_BAS_sound_2
    For t% = 800 To 1111 Step 20: Sound t%, .1: Next
End Sub ' ANSISUB_BAS_sound_2

' /////////////////////////////////////////////////////////////////////////////
' THEWOODS.BAS
' fast med-low sweep (drop object or fire low power laser)

Sub THEWOODS_BAS_sound_1
    'Sorry... You have perished in battle.
    For t% = 200 To 150 Step -1: Sound t%, .1: Next
End Sub ' THEWOODS_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' quick higher descending sweep sound (falling or dropping object)

Sub StarBlast_BAS_sound_12
    'the Energy-Drain Object
    For F = 1700 To 1100 Step -100: Sound F, .75: Next
End Sub ' StarBlast_BAS_sound_12

' /////////////////////////////////////////////////////////////////////////////
' short low descending bwooop (drop object etc)

Sub arqanoid_BAS_sound_4
    'Check4Bomb:
    For J = 0 To 3
        'Wait &H3DA, 8
        'Wait &H3DA, 8, 8
        Sound 400 - (J * 50), .3
    Next J
End Sub ' arqanoid_BAS_sound_4

' /////////////////////////////////////////////////////////////////////////////
' short quick high-low descending chirp (turning device off or dropping object or phaser)

Sub arqanoid_BAS_sound_9
    'SndExplode
    For SI = 3000 To 400 Step -250
        Sound SI, .1
    Next SI
End Sub ' arqanoid_BAS_sound_9

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN BIP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' simple bip (picked up an object or stopped by wall)

Sub leapfrog_bas_sound_2
    Play "MBT220L64O2b"
End Sub ' leapfrog_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' RMORTIS2.BAS
' boop (knocking on door)

Sub RMORTIS2_sound_1
    Sound 400 + Rnd * 100, .1
    Sound 40, .1
    Sound 47, 1: Sound 47, 0
End Sub ' RMORTIS2_sound_1

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END BIP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN BUP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' quick lower (medium) bip (handed player an object or ready an object)

Sub PAC_MAN_Chirp5
    Sound 440, .05
    Sound 900, .1
End Sub ' PAC_MAN_Chirp5

' /////////////////////////////////////////////////////////////////////////////
' DEMO_BTN.txt
' lower couple of ascending tones (footsteps?)

Sub DEMO_BTN_Click
    Sound 400, .1
    Sound 1400, .1
End Sub ' DEMO_BTN_Click

' /////////////////////////////////////////////////////////////////////////////
' low boop sound (footsteps or some action)

Sub mooncr_sounds_5
    SSHOOT3$ = "MBT255l48n7n10n7"
    Play SSHOOT3$
End Sub ' mooncr_sounds_5

' /////////////////////////////////////////////////////////////////////////////
' leapfrog.bas
' ascending low pitched sounds (footsteps or some basic action)

Sub leapfrog_bas_sound_1
    Play "MBMST220L64O1cP16eP16g"
End Sub ' leapfrog_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' lower fwip sound (some action)

Sub waster_bas_sound_9
    For z = 1 To 10
        'Sound 121, .05
        Sound 121 * z, .05
        'Sound 40, .05
        Sound 40 * z, .05
    Next z
End Sub ' waster_bas_sound_9

' /////////////////////////////////////////////////////////////////////////////
' short low putt sound (repeat for a kind of engine noise)

Sub KISSED_BAS_sound_2_noise
    Sound 1000, .1
End Sub ' KISSED_BAS_sound_2_noise

' /////////////////////////////////////////////////////////////////////////////
' fast med-low sound (some action)

Sub StarBlast_BAS_sound_6
    For F = 150 To 50 Step -25: Sound F, .3: Next 'Ver. 5
End Sub ' StarBlast_BAS_sound_6

' /////////////////////////////////////////////////////////////////////////////
' SierraKen_My 1996 Tiny Dungeon Game v2.bas
' woop! sound (bubble sound)

Sub Tiny_Dungeon_sound_1_drumming
    'drumming:
    For dr = 1 To 20 Step 2
        Sound 100 + dr * 10, .1
        For tm = 1 To 3000: Next tm
    Next dr
End Sub ' Tiny_Dungeon_sound_1_drumming

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END BUP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN CHEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' tiny quick high-pitched chirp

Sub StarBlast_BAS_sound_2
    'Fire_Laser
    For F = 6000 To 5500 Step -100: Sound F, .25: Next 'Ver. 1  (HIGH pitch)                 ( ((  )) )
End Sub ' StarBlast_BAS_sound_2

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END CHEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ACTION / ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' lower squiggly sound (phaser or dropping object)

Sub macattak_sound_4
    For q = 1 To 2
        For f = 2500 To 100 Step -80
            Sound f, .025
        Next f
    Next q
End Sub ' macattak_sound_4

' /////////////////////////////////////////////////////////////////////////////
' lower quick warble (moon buggy jumping or rumble type sound)

Sub mooncr_sounds_8
    SETYPE3$ = "MBT255l32n36n24n1n17n2n19n0n11n1n15n3n17n2n9n1n6n2n4n1n3n1"
    Play SETYPE3$
End Sub ' mooncr_sounds_8

' /////////////////////////////////////////////////////////////////////////////
' XGAME.BAS
' low to high ascending stepped notes (picked up object or some action)

Sub xgame_bas_sound_1
    For Z = 100 To 1000 Step 75: Sound Z, .5: Next Z
End Sub ' xgame_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' fast low to high

Sub xgame_bas_sound_6
    For Z = 500 To 1500 Step 100: Sound Z, .5: Next Z
End Sub ' xgame_bas_sound_6

' /////////////////////////////////////////////////////////////////////////////
' fast high-low pew sound (laser or drop object or some action)

Sub StarBlast_BAS_sound_4
    For F = 600 To 100 Step -100: Sound F, .3: Next 'Ver. 3
End Sub ' StarBlast_BAS_sound_4

' /////////////////////////////////////////////////////////////////////////////
' medium high-low pew sound (some action)

Sub StarBlast_BAS_sound_5
    For F = 300 To 100 Step -45: Sound F, .3: Next 'Ver. 4
End Sub ' StarBlast_BAS_sound_5

' /////////////////////////////////////////////////////////////////////////////
' quick high to low descending stepped notes like firing phasers or some action

Sub StarBlast_BAS_sound_11
    'A Power Orb was hit
    For F = 700 To 100 Step -100: Sound F, .75: Next
End Sub ' StarBlast_BAS_sound_11

' /////////////////////////////////////////////////////////////////////////////
' arqanoid.bas
' short medium pitched zweeeeep (use shields or something)

Sub arqanoid_BAS_sound_1
    Sound 1000, .2
    Sound 500, .4

    For I = 106 To 121
        'WriteRGB I, 0, 63, INT(RND * 63)
    Next I

    Sound 1000, .3
    Sound 700, .2
    'WAIT &H3DA, 8

    For I = 106 To 121
        'R = SavRGB(I).R
        'g = SavRGB(I).g
        'B = SavRGB(I).B
        'WriteRGB I, R, g, B
    Next I

    Sound 1000, .2
End Sub ' arqanoid_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' short descending beep (dropping object or turning something off)

Sub arqanoid_BAS_sound_2
    'XFlies:
    For J = 0 To 3
        'WAIT &H3DA, 8
        'WAIT &H3DA, 8, 8
        Sound 1500 - (J * 150), .3
    Next J
End Sub ' arqanoid_BAS_sound_2

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ACTION / ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN FWEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' uwl-subs.bas.txt
' quick couple of ascending tones (drop or pickup object)

Sub UnderWare_uwl_subs_bas_sound_1
    Sound 200, .1

    Sound 2000, .1

    Sound 400, .05

    Sound 1000, .25

    Sound 1500, .25

    Sound 2000, .25

    Sound 2500, .25
End Sub ' UnderWare_uwl_subs_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' quick fwip sound (fire phaser or picked up or dropped some object or some action)

Sub waster_bas_sound_5
    For z = 40 To 2000 Step 162
        Sound z, .03
    Next z
End Sub ' waster_bas_sound_5

' /////////////////////////////////////////////////////////////////////////////
' quick fwip sound (some action)

Sub waster_bas_sound_7
    For z = 40 To 2000 Step 162
        Sound z, .03
    Next z
End Sub ' waster_bas_sound_7

' /////////////////////////////////////////////////////////////////////////////
' high quick fwip sound

Sub waster_bas_sound_14
    'ko:
    For z = 2000 To 5000 Step 161
        Sound z, .03
    Next z
End Sub ' waster_bas_sound_14

' /////////////////////////////////////////////////////////////////////////////
' TRIANGU2.BAS
' medium-high fwip sound (pilfered or discarded object)

Sub TRIANGU2_BAS_sound_1
    For z% = 0 To 31
        'Sound z% * 16 + 40, .03
        Sound z% * 91 + 40, .03
    Next z%
End Sub ' TRIANGU2_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' NDXCRLF.BAS
' fast very low to very high fweep (meteor or comet zooming across sky)

Sub NDXCRLF_BAS_SOUND_1
    For S% = 5 To 35: Sound S% * 200, .1: Next
End Sub ' NDXCRLF_BAS_SOUND_1

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END FWEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN MAGIC SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' warbly relatively quick ascending sweep (beaming signal or some action)

Sub SLIME_BAS_SOUND_7
    '3570 For Z = 1 To 10 Step .05
    For Z = 1 To 10 Step .05
        Sound Z * (Int(50 * Rnd) + 50), .1
        '3590 Sound Int(50 * Rnd) + 50, .1
    Next Z
End Sub ' SLIME_BAS_SOUND_7

' /////////////////////////////////////////////////////////////////////////////
' MOON.BAS
' high-low sweeping to high sound (some funky action)

Sub MOON_BAS_SOUND_1
    'explosion:
    For x = 37 To 150: Sound x, .1: Sound 2 * x, .1: Sound 3 * x, .1: Next
End Sub ' MOON_BAS_SOUND_1

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END MAGIC SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN MICROTUNES SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' descending tones (some negative action or dropping an object)

Sub SLOTS_sound_2
    Sound 850, 3: Sound 600, 2: Sound 200, 3
End Sub ' SLOTS_sound_2

' /////////////////////////////////////////////////////////////////////////////
' 2-note tune (successfully completed refueling or some action)

Sub mooncr_sounds_18
    SNEWPL1$ = "MBT255l3n25n32"
    Play SNEWPL1$
End Sub ' mooncr_sounds_18

' /////////////////////////////////////////////////////////////////////////////
' fast 2-note tune (successfully completed or picked up object)

Sub mooncr_sounds_19
    SNEWPL2$ = "MBT255l8n25n32"
    Play SNEWPL2$
End Sub ' mooncr_sounds_19

' /////////////////////////////////////////////////////////////////////////////
' lower pitched alert type sound (enemies detected)

Sub mooncr_sounds_41
    SFINAL$ = "MBMNT64l16n8n8n8n0n8n0n8n0n8n8n8n0n8n0"
    Play SFINAL$
End Sub ' mooncr_sounds_41

' /////////////////////////////////////////////////////////////////////////////
' quick ascending notes (entered a portal or finished a round or accomplished something minor)

Sub leapfrog_bas_sound_3
    Play "MFMST120O1L16ceg>ceg>ceg>L32cg"
End Sub ' leapfrog_bas_sound_3

' /////////////////////////////////////////////////////////////////////////////
' quick little affirmative sequence of notes (got an object or refueled or something)

Sub cr_bas_sound_10
    'Magic
    Play "mst255o3l16cdcdg"
End Sub ' cr_bas_sound_10

' /////////////////////////////////////////////////////////////////////////////
' success tune (finished level or got an object you need)

Sub waster_bas_sound_12
    'ESCAPE THE POLICEMAN
    Sound 262, 2: Sound 330, 2: Sound 392, 2: Sound 523, 3
    Sound 392, 1: Sound 523, 4
End Sub ' waster_bas_sound_12

' /////////////////////////////////////////////////////////////////////////////
' quick little neutral tune (jumping or some action)

Sub waster_bas_sound_13
    'mus:
    Sound 364, 1: Sound 364, 1: Sound 364, 1: Sound 445, 1: Sound 526, 1
    Sound 445, 1: Sound 526, 1: Sound 445, 1: Sound 364, 1
End Sub ' waster_bas_sound_13

' /////////////////////////////////////////////////////////////////////////////
' quick high-to-low stepped sequence of notes - tumbling down or falling or jumping down sound

Sub StarBlast_BAS_sound_10
    'S u p e r  O b j e c t   D  E  S  T  R  O  Y  E  D
    For F = 700 To 100 Step -100: Sound F, 1.75: Next '          ( (( )) )
End Sub ' StarBlast_BAS_sound_10

' /////////////////////////////////////////////////////////////////////////////
' Tank Walls 2.bas
' medium slow descending notes sequence like a ball bouncing down steps

Sub Tank_Walls_2_BAS_sound_1
    For welcome = 10 To 100 Step 10
        _Delay .25
        Sound 350 - (welcome * 2.5), 1
    Next welcome
End Sub ' Tank_Walls_2_BAS_sound_1

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN PILFER SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' medium-short ascending beep (picking up object or quick power up)

Sub arqanoid_BAS_sound_3
    'CheckPowerCaps
    'FindType:
    Sound 700, .5
    Sound 900, .5
    Sound 1100, .5
    Sound 1300, .5
    Sound 1500, .5
    Sound 1700, .5
    Sound 1900, .5
    Sound 2100, .5
End Sub ' arqanoid_BAS_sound_3

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END PILFER SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN RUMBLE SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' low warbling rumbly sound (earthquake or boulderdash screen generation)

Sub SLIME_BAS_SOUND_10
    For z% = 318 To 221 Step -1
        Sound Int(100 * Rnd) + 50, .3
        For zz% = 1 To 1000: Next zz%
    Next z%
End Sub ' SLIME_BAS_SOUND_10

' /////////////////////////////////////////////////////////////////////////////
' low warbling rumbly sound (very short version)

Sub SLIME_BAS_SOUND_11
    For z% = 220 To 200 Step -1
        Sound Int(100 * Rnd) + 50, .3
        For zz% = 1 To 1000: Next zz%
    Next z%
End Sub ' SLIME_BAS_SOUND_11

' /////////////////////////////////////////////////////////////////////////////
' short low rumble (rocket engine type noise)

Sub SLIME_BAS_SOUND_12
    For z% = 199 To 175 Step -1
        Sound Int(100 * Rnd) + 50, .3
        For zz% = 1 To 1000: Next zz%
    Next z%
End Sub ' SLIME_BAS_SOUND_12

' /////////////////////////////////////////////////////////////////////////////
' medium rumbling type sound

Sub snatch_bas_sound_6
    For Z = 40 To 1 Step -1
        Sound Int(60 * Rnd) + 60 + Z, .2
    Next Z
End Sub ' snatch_bas_sound_6

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END RUMBLE SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN TINY BIP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' Qbw_1-1.txt
' quick chirp sound (phaser or some action)

Sub QBW_BAS_sound_1
    For t = 1800 To 1000 Step -600: Sound t, .5: Next t
End Sub ' QBW_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' even higher bip

Sub PAC_MAN_Chirp2
    Sound 3200, .4
    Sound 6400, .2
    Sound 12800, .4
End Sub ' PAC_MAN_Chirp2

' /////////////////////////////////////////////////////////////////////////////
' high 2-note high to low (dropping object or enemy attack turn)

Sub mooncr_sounds_3
    SSHOOT1$ = "MBT255l64n63n61n58n55n58"
    Play SSHOOT1$
End Sub ' mooncr_sounds_3

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END TINY BIP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN TREASURE SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' high-low-high-higher-higher tinkling beep sound (picked up a diamond or some treasure)

Sub arqanoid_BAS_sound_5
    Sound 500, 1
    Sound 1300, 2

    Sound 2500, .5
    Sound 3000, .2

    Sound 1500, 1
    Sound 3500, 1
End Sub ' arqanoid_BAS_sound_5

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END TREASURE SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ZEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' a little lower high squiggly sound (maybe a small dog bark!)

Sub macattak_sound_3
    For q = 1 To 3
        For f = 100 To 2500 Step 800
            Sound f, .1
        Next f
    Next q
End Sub ' macattak_sound_3

' /////////////////////////////////////////////////////////////////////////////
' fast ascending sweep (zzzzzooop) some action

Sub waster_bas_sound_6
    For z = 1 To 40
        'Sound 50, .03
        Sound 50 * z, .03
        'Sound 280, .03
        Sound 280 * z, .03
    Next z
End Sub ' waster_bas_sound_6

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ZEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ARCADE-ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' quick 4-note sequence (picked up object)

Sub xgame_bas_sound_2
    1170 Sound 262, 1: Sound 330, 1: Sound 392, 1: Sound 523, 1
End Sub ' xgame_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' medium low to high to higher sweep (picked up a powerup)

Sub arqanoid_BAS_Dosound2P
    Dim Dsi As Single
    Dsi = .9
    For SI = 300 To 3000 Step 50
        If Dsi > .1 Then Dsi = Dsi - .1
        Sound SI, Dsi
    Next SI
End Sub ' arqanoid_BAS_Dosound2P

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ARCADE-ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ARCADE-ACTION-OR-ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' short med-low to high ascending sweep (pick up powerup or refueling or some action)

Sub arqanoid_BAS_sound_7
    'SfxOpenDialog
    For II = 400 To 900 Step 10
        Sound II, .1
    Next II
End Sub ' arqanoid_BAS_sound_7

' /////////////////////////////////////////////////////////////////////////////
' medium short low-to-high ascending bwap! (docked with space station or some action)

Sub arqanoid_BAS_sound_8
    'SfxPowerUp
    For SI = 500 To 1400 Step 100
        Dsi = Rnd
        Sound SI, Dsi
    Next SI
End Sub ' arqanoid_BAS_sound_8

' /////////////////////////////////////////////////////////////////////////////
' short quick low-high-low sweep sound (swinging a bat or touching some object)

Sub arqanoid_BAS_DosoundP
    For SI = 500 To 2000 Step 100
        Sound SI, .1
    Next SI
    For SI = 1000 To 500 Step -100
        Sound SI, .1
    Next SI
End Sub ' arqanoid_BAS_DosoundP


' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ARCADE-ACTION-OR-ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ARCADE-ALERT SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' fast ringing sound (touched an object or short alert)

Sub leapfrog_bas_sound_4
    Play "MBMST120O4L32cgcgcgcg"
End Sub ' leapfrog_bas_sound_4

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ARCADE-ALERT SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN ARCADE-MICROTUNES SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' quick 7 or 8 note ascending notes (finished round or starting one)

Sub xgame_bas_sound_3
    Sound 300, 3
    Sound 350, 3
    Sound 400, 3
    Sound 450, 3
    Sound 500, 3
    Sound 600, 3
    Sound 800, 3
End Sub ' xgame_bas_sound_3

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END ARCADE-MICROTUNES SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN PONG TYPE BEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' bomb.bas.(realtime 2d tank game).txt
' short high beep (pong!)

Sub BombBas_Sound_1
    For l = 1 To 1
        i = 1500 - (l * 10)
        Sound (i), 1
    Next l
    Sound 100, .1
End Sub ' BombBas_Sound_1

' /////////////////////////////////////////////////////////////////////////////
' beep (pong!)

Sub bplus_asteroids_makeover_sound_4
    Sound 500, 3
End Sub ' bplus_asteroids_makeover_sound_4

' /////////////////////////////////////////////////////////////////////////////
' medium-short beep (system online or activated)

Sub waster_bas_sound_8
    For z = 2000 To 40 Step -162
        Sound z, .03
    Next z
    Sound 1000, 3
End Sub ' waster_bas_sound_8

' /////////////////////////////////////////////////////////////////////////////
' short mid beep (pong!)

Sub temple_bas_sound_2
    '3220 Print "a scream!"
    For I = 2075 To 1800 Step -1
        Sound I, .001
    Next
    Sound 32729, 1
End Sub ' temple_bas_sound_2

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END PONG TYPE BEEP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' medium squiggly sound (quick alert or enemy attacking)

Sub mooncr_sounds_2
    SLASER2$ = "MBT255l48n58n56n54n52n58n56n54n52"
    Play SLASER2$
End Sub ' mooncr_sounds_2

' /////////////////////////////////////////////////////////////////////////////
' 3-note affirmative sequence (accomplished fueling or repair or something similar)

Sub MONOP_BAS_SOUND_7
    Sound 262, 2
    Sound 392, 1
    Sound 523, 2
End Sub ' MONOP_BAS_SOUND_7

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE ALERT SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' short alert sound (attention!)

Sub MONOP_BAS_SOUND_3
    Sound 784, 1: Sound 30000, .5: Sound 784, 1: Sound 30000, .5: Sound 784, 1
End Sub ' MONOP_BAS_SOUND_3

' /////////////////////////////////////////////////////////////////////////////
' WASTER.BAS
' quick pulsing alert sound (receiving transmission or picked up object or some action or beaming transmission)

Sub waster_bas_sound_1
    For z = 1 To 3
        Sound 330, 1
        Sound 784, 1
    Next z
End Sub ' waster_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' fast low-high-low-high note sequence for picking up or touching an object

Sub xgame_bas_sound_5
    Sound 131, 1: Sound 262, 1: Sound 523, 1: Sound 262, 1: Sound 131, 1: Sound 262, 1: Sound 523, 1: Sound 262, 1: Sound 131, 1
End Sub ' xgame_bas_sound_5

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE ALERT SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE ALERT-OR-ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' quick med-low pitch 2-note pulsing (alarm or touching a force field or some action)

Sub xgame_bas_sound_4
    Sound 131, 1: Sound 262, 1: Sound 131, 1: Sound 262, 1: Sound 131, 1
End Sub ' xgame_bas_sound_4

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE ALERT-OR-ACTION SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' SNATCH.BAS
' pulsing laser phaser sound or cool spaceship alarm

Sub snatch_bas_sound_1_squirrel
    '40 Dim RR(4)
    '60 RR(1) = 9: RR(2) = 6: RR(3) = 8: RR(4) = 3
    '480 Print "SHOOT (S)QUIRREL,(R)ABBIT,(C)HIPMUNK OR (G)ROUNDHOG? (Q to quit)"
    '490 I$ = InKey$: If I$ = "" Then 490
    '510 If I$ = "S" Or I$ = "s" Then Z = Int((RR(1) * Rnd + 2) / 2)

    RR = 9
    Z = Int((RR * Rnd + 2) / 2)
    For ZZ = 1 To Z
        For ZZZ = 600 To 100 Step -20
            Sound ZZZ, .1
        Next ZZZ
    Next ZZ
    '640 GoTo 490
End Sub ' snatch_bas_sound_1_squirrel

' /////////////////////////////////////////////////////////////////////////////
' lower fwip sound (fast descending) like dropped object or fired phaser

Sub waster_bas_sound_17
    '" LOST 2 SHIELDS"
    For z = 1 To 40
        'Sound 50, .03
        Sound (50 / z * 100), .03

        'Sound 280, .03
        Sound (280 / z) * 100, .03
    Next z
End Sub ' waster_bas_sound_17

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE ACTION-OR-ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' KWIKVIEW.BAS
' quick higher-pitcked ascending sweep (launched or ejected something)

Sub KWIKVIEW_BAS_SOUND_1
    For S% = 5 To 35: Sound S% * 200, .1: Next
End Sub ' KWIKVIEW_BAS_SOUND_1

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE ACTION-OR-ATTACK SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE MICROTUNES SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' SLOTS.txt
' 3 tone ship computer coming online (like beginning of Atari Star Raiders)

Sub SLOTS_sound_1
    Sound 450, 2: Sound 600, 3: Sound 800, 4: Sound 800, 1: Sound 800, 2
End Sub ' SLOTS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' starting a round (reveille type tune)

Sub cr_bas_sound_13
    'Exit cave 6
    Play "mst255o3l4dl8ddl4dl8ddl2mlg"
End Sub ' cr_bas_sound_13

' /////////////////////////////////////////////////////////////////////////////
' ARG!!.BAS
' 4-note alert type sequence (entering quadrant - space warp compete)

Sub ARG_BAS_sound_1
    Sound 500, 2
    Sound 700, 5
    Sound 600, 2
    Sound 800, 7
End Sub ' ARG_BAS_sound_1

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE MICROTUNES SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN SPACE BONUS-OR-POWERUP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' fast little note sequence low to high (jumping or picked up some object)

Sub waster_bas_sound_11
    Sound 688, 1: Sound 850, 1: Sound 1012, 1: Sound 850, 1
    Sound 1012, 1: Sound 1336, 1: Sound 1660, 1
    Sound 1984, 1: Sound 2632, 1
End Sub ' waster_bas_sound_11

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END SPACE BONUS-OR-POWERUP SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' BEGIN OTHER SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' /////////////////////////////////////////////////////////////////////////////
' tech invaders 2.bas.vbs
' ship's computer alert sound

Sub tech_invaders_2_sound_1
    Sound 400, .5

    Sound 100, 1

    Sound 300, .5

    Sound 400, .5
    Sound 300, .5
    Sound 200, .5
    Sound 100, .5

    Sound 800, .25

    Sound 900, .25

    Sound 400, 2
    Sound 400, 2
    Sound 400, 2

    Sound 1000, 3

    Sound 400, 4
    Sound 300, 4

    Sound 49, 1

    Sound 50, .3

    Sound 37, .07
End Sub ' tech_invaders_2_sound_1

' /////////////////////////////////////////////////////////////////////////////
' smooth ascending sweep (refueling)

Sub tech_invaders_2_OPENINGSOUND
    snd = 300
    snd2 = 800
    For t = 1 To 50
        If snd > 800 Then snd = 300
        If snd2 < 300 Then snd2 = 800
        snd = snd + 10
        Sound snd, .25
    Next t
End Sub ' tech_invaders_2_OPENINGSOUND

' /////////////////////////////////////////////////////////////////////////////
' b+_asteroids_makeover_20201106.bas
' long pulsing sound (if shortened could be a phaser or alarm)

Sub bplus_asteroids_makeover_sound_1a
    For i = 1 To 50
        'Sound 25600, .2
        'Sound 12800, .15
        'Sound 6400, .1
        Sound 3200, .15
        Sound 1600, .2
        Sound 800, .25
        Sound 400, .2
        Sound 200, .15
        Sound 100, .1
        '_Limit 30 ' keep loop at 30 frames per second
    Next i
End Sub ' bplus_asteroids_makeover_sound_1a

' /////////////////////////////////////////////////////////////////////////////
' long pulsing sound (broken up using _LIMIT in loop)

Sub bplus_asteroids_makeover_sound_1b
    For i = 1 To 50
        'Sound 25600, .2
        'Sound 12800, .15
        'Sound 6400, .1
        Sound 3200, .15
        Sound 1600, .2
        Sound 800, .25
        Sound 400, .2
        Sound 200, .15
        Sound 100, .1
        _Limit 10 ' keep loop at 10 frames per second
    Next i
End Sub ' bplus_asteroids_makeover_sound_1b

' /////////////////////////////////////////////////////////////////////////////
' high fast ascending sweep (pilfered in ultima or phaser sound)

Sub bplus_asteroids_makeover_sound_2
    alienN = 30 ' 3
    For i = 1 To alienN
        Sound 6000 + i * 200, .07
    Next
End Sub ' bplus_asteroids_makeover_sound_2

' /////////////////////////////////////////////////////////////////////////////
' motor in low gear

Sub bplus_asteroids_makeover_sound_3
    Sound 37, 15
End Sub ' bplus_asteroids_makeover_sound_3

' /////////////////////////////////////////////////////////////////////////////
' short ascending sweep (fast refuel or laser sound)

Sub mosh_at_a_and_p_sound_1
    For BlastSound% = 200 To 100 Step -5
        Sound 750 - BlastSound%, .2
    Next BlastSound%
End Sub ' mosh_at_a_and_p_sound_1

' /////////////////////////////////////////////////////////////////////////////
' UnderWare other
' Some PC speaker sound effects that I collected over time.
' quick descending sweep (laser or death or negative response)

Sub UnderWare_sound_1_Rocket
    For x = 1000 To 50 Step -25
        Sound x, .1
        Sound 50 + Rnd * 200, .1
    Next x
End Sub ' UnderWare_sound_1_Rocket

' /////////////////////////////////////////////////////////////////////////////
' phone ringing type sound

Sub UnderWare_sound_2_MachineGun
    For p = 1 To 100 Step 7
        For i = 200 To 50 Step -60
            Sound i, .2
            Sound 13676 - p * 10, .05
            Sound 100, .1
        Next i
        Sound 32676, .6
        Sound 100, .1: Sound 50, .3
    Next p
End Sub ' UnderWare_sound_2_MachineGun

' /////////////////////////////////////////////////////////////////////////////
' low warble (like c64 spelunker)

Sub UnderWare_sound_3_LowPitchedWarble
    For x = 1 To 50
        a = Rnd * 50 + 150
        Sound a, 1
    Next x
End Sub ' UnderWare_sound_3_LowPitchedWarble

' /////////////////////////////////////////////////////////////////////////////
' random sequence of high pitched sounds (like c64 boulderdash generating screen sound)

Sub UnderWare_sound_4_HighPitchedWarble
    For x = 1 To 50
        a = Rnd * 500 + 1500
        Sound a, 1
    Next x
End Sub ' UnderWare_sound_4_HighPitchedWarble

' /////////////////////////////////////////////////////////////////////////////
' theramin type sound

Sub UnderWare_sound_5_FlyingSaucerSlow
    For t% = 1 To 10
        For i% = 950 To 1000 Step 5
            Sound i%, i% / 6000
        Next i%
        For i% = 1000 To 950 Step -5
            Sound i%, i% / 6000
        Next i%
    Next t%
End Sub ' UnderWare_sound_5_FlyingSaucerSlow

' /////////////////////////////////////////////////////////////////////////////
' higher pitched theramin type sound

Sub UnderWare_sound_6_FlyingSaucerFast
    For t% = 1 To 10
        For i% = 1950 To 2050 Step 18
            Sound i%, i% / 6000
        Next i%
        For i% = 2050 To 1950 Step -18
            Sound i%, i% / 6000
        Next i%
    Next t%
End Sub ' UnderWare_sound_6_FlyingSaucerFast

' /////////////////////////////////////////////////////////////////////////////
' 5x descending notes (could be alarm or shorten to 1x for alert)

Sub UnderWare_sound_7_TumblingSound
    For t% = 1 To 5
        For x% = 4000 To 100 Step -500
            D = D - .1 * Q
            If D < 1 Then D = 1: Q = Q * -1
            If D > 5 Then D = 5: Q = Q * -1
            For i% = 100 To 950 Step -5
                Sound i%, i% / 6000
            Next i%
            Sound x%, D
        Next x%
    Next t%
End Sub ' UnderWare_sound_7_TumblingSound

' /////////////////////////////////////////////////////////////////////////////
' quick bip (selecting an object or can't go past wall)

Sub QBW_BAS_sound_2
    For t = 1800 To 1000 Step -600: Sound t, .3: Next t
End Sub ' QBW_BAS_sound_2

' /////////////////////////////////////////////////////////////////////////////
' higher bip (drop or select object or affirmative action)

Sub PAC_MAN_Chirp1
    Sound 1200, .2
    Sound 6400, .2
    Sound 12800, .2
End Sub ' PAC_MAN_Chirp1

' /////////////////////////////////////////////////////////////////////////////
' smooth ascending tone (refueling or repeat for spaceship alarm or brain salad surgery sound)

Sub PAC_MAN_Chirp3
    For i% = 400 To 4000 Step 30
        Sound i%, .1
    Next
End Sub ' PAC_MAN_Chirp3

' /////////////////////////////////////////////////////////////////////////////
' multi cascading smoothly descending tones (space warp)

Sub PAC_MAN_Chirp4
    For i% = 4000 To 1500 Step -500
        For j% = i% To i% - 1200 Step -15
            Sound j%, .1
        Next j%
    Next i%
    For i% = 1 To 40
        Sound 100, .05
        Sound 200, .05
    Next i%
End Sub ' PAC_MAN_Chirp4

' /////////////////////////////////////////////////////////////////////////////
' CLOCK.txt
' single tick sound

Sub CLOCK_BAS_tick
    TickSound% = 1 'Ticking sound   ( 1=ON, 0=OFF )
    If TickSound% = 1 Then Sound 4400, .05
End Sub ' CLOCK_BAS_tick

' /////////////////////////////////////////////////////////////////////////////
' couple of high tones (repeat for alarm)

Sub CLOCK_BAS_Alarm
    Sound 32767, .1
    Sound 4000, 1
    Sound 32767, .1
    Sound 3000, 1
End Sub ' CLOCK_BAS_Alarm

' /////////////////////////////////////////////////////////////////////////////
' macattak.bas
' long smoothly descending sweep (like 1st half of tuning a space radio)

Sub macattak_sound_1
    For q = 5000 To 400 Step -10
        Sound q, .1
    Next q
End Sub ' macattak_sound_1

' /////////////////////////////////////////////////////////////////////////////
' quick high squggly sound (turn on shields phaser etc.)

Sub macattak_sound_2
    For q = 1 To 3
        For f = 2500 To 100 Step -800
            Sound f, .1
        Next f
    Next q
End Sub ' macattak_sound_2

' /////////////////////////////////////////////////////////////////////////////
' Frostbite Tribute (Beta 6)
' smoothly descending sweeping sound (falling jumping or emptying something)

Sub Frostbite_Tribute_beta_6_sound_1
    For x = 550 To 37 Step -5
        Sound x + 5, .2
    Next x
End Sub ' Tribute_beta_6_sound_1

' /////////////////////////////////////////////////////////////////////////////
' smoothly ascending sweeping sound (refueling or launching an item)

Sub Frostbite_Tribute_beta_6_sound_2
    For x = 37 To 550 Step 5
        Sound x + 5, .2
    Next x
End Sub ' Tribute_beta_6_sound_2

' /////////////////////////////////////////////////////////////////////////////
' xwing.bas
' star wars theme song

Sub xwing_bas_sound_1_theme
    Sound 525.25, 18.2: Sound 783.99, 18.2 / 2: Sound 698.46, 18.2 / 6: Sound 659.26, 18.2 / 6: Sound 587.33, 18.2 / 6: Sound 1046.6, 18.2: Sound 783.99, 18.2 / 2: Sound 698.46, 18.2 / 6: Sound 659.26, 18.2 / 6: Sound 587.33, 18.2 / 6
    Sound 1046.5, 18.2: Sound 783.99, 18.2 / 2: Sound 698.46, 18.2 / 6: Sound 659.26, 18.2 / 6: Sound 698.46, 18.2 / 6: Sound 587.33, 18.2
End Sub ' xwing_bas_sound_1_theme

' /////////////////////////////////////////////////////////////////////////////
' high pitched quick pilfer or phaser type sound

Sub xwing_bas_sound_2
    For J2 = 10000 To 100 Step -500
        Sound J2, .001 * 18.2
    Next J2
End Sub ' xwing_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' smoothly descending sweep (if slower could be dropping bomb)(or emptying something)

Sub xwing_bas_sound_3
    For J2 = 1000 To 37 Step -10
        Sound J2, .01 * 18.2
    Next J2
End Sub ' xwing_bas_sound_3

' /////////////////////////////////////////////////////////////////////////////
' temple.bas
' slower smoothly descending sweep like aliens diving in galaxian

Sub temple_bas_sound_1
    For QWER = 220 To 196 Step -1
        Sound QWER, 1
    Next
End Sub ' temple_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' annoying alert sound (on off x 4)

Sub temple_bas_sound_3
    '3280 Print "footsteps!"
    '3290 'FOR I=1 TO 5
    For J = 40 To 37 Step -1
        Sound J, 1
        Sound 32729, 10
        '3330 'NEXT
    Next
End Sub ' temple_bas_sound_3

' /////////////////////////////////////////////////////////////////////////////
' simple 2-note x4 (alert or beginning of battle sequence)

Sub temple_bas_sound_4
    '3360 Print "a Wumpus!"
    Play "O0MST255L4AGP5AGP5AGP5AG"
    'SLEEP 2
End Sub ' temple_bas_sound_4

' /////////////////////////////////////////////////////////////////////////////
' med-fast smoth descending sweep (jumping down? laser? dropping bomb?)

Sub temple_bas_sound_5
    '3390 Print "groans!"
    For I = 300 To 37 Step -1
        Sound I, .1
    Next
End Sub ' temple_bas_sound_5

' /////////////////////////////////////////////////////////////////////////////
' med-high beep (pong)

Sub temple_bas_sound_6
    '3530 Print "hear faint rustling noises!"
    For Q = 1 To 200
        A = Int(Rnd * 50 + 37)
        Sound A, .001
        'SOUND 32729,1
    Next
    Sound 32729, 1
End Sub ' temple_bas_sound_6

' /////////////////////////////////////////////////////////////////////////////
' long annoying beep (computer alert)

Sub temple_bas_sound_7
    '11400 Print "You hear footsteps...";
    Sound 32767, 28
End Sub ' temple_bas_sound_7

' /////////////////////////////////////////////////////////////////////////////
' long annoying beep (same as 45)

Sub temple_bas_sound_8
    '11420 Print "The footsteps get louder!"
    Sound 32767, 28
End Sub ' temple_bas_sound_8

' /////////////////////////////////////////////////////////////////////////////
' long annoying beep (same as 45)

Sub temple_bas_sound_9
    '11440 Print "You hear people talking in a strange language."
    Sound 32767, 28
End Sub ' temple_bas_sound_9

' /////////////////////////////////////////////////////////////////////////////
' mooncr.bas
' quick 2-note high to low (dropping object or enemy attack turn)

Sub mooncr_sounds_1
    'GoSub LOAD.SOUNDS
    'LOAD.SOUNDS:
    Rem 2,7,10,13,15,19,22,25,27,31,34,39,43,46,58
    SLASER1$ = "MBT255l64n58n57n56n55n54"
    Play SLASER1$
End Sub ' mooncr_sounds_1

' /////////////////////////////////////////////////////////////////////////////
' higher 2-note high to low (enemy moving)

Sub mooncr_sounds_4
    SSHOOT2$ = "MBT255l64n61n58n55"
    Play SSHOOT2$
End Sub ' mooncr_sounds_4

' /////////////////////////////////////////////////////////////////////////////
' quick descending step sound (fire lasers or repeat for funky disco alert)

Sub mooncr_sounds_6
    SETYPE1$ = "MBT255l32n39n34n31n27n25n22n19n15n13n10n7n2"
    Play SETYPE1$
End Sub ' mooncr_sounds_6

' /////////////////////////////////////////////////////////////////////////////
' quick 2x phaser sound

Sub mooncr_sounds_9
    SETYPE4$ = "MBT255l64n50n48n45n41n36n50n47n43n37n33n26n19n12n1n9n1n7n1n5n1n3n1"
    Play SETYPE4$
End Sub ' mooncr_sounds_9

' /////////////////////////////////////////////////////////////////////////////
' high to low stepping warbly sound (maybe an enemy attack sound)

Sub mooncr_sounds_16
    SCRASH9$ = "MBT255l32n30n1n23n2n19n3n14n2n15n1n11n1n7n1n4n1n5n1n3n1n2n1n0n1n3n1n2n1"
    Play SCRASH9$
End Sub ' mooncr_sounds_16

' /////////////////////////////////////////////////////////////////////////////
' happy little tune (relatively quick)

Sub mooncr_sounds_21
    SRGTON$ = "MBT80l24n27n0l24n27n29n34n31n34n31l12n29l24n29n32l6n36l24n38n34n31n38n34n31n38n34l12n39l24n38l8n39"
    Play SRGTON$
End Sub ' mooncr_sounds_21

' /////////////////////////////////////////////////////////////////////////////
' a little longer tune to play at the start of a round

Sub mooncr_sounds_22
    SLAUNCH$ = "MBT96l64n27l8n22l16n22l4n27n34l16n0n22MLl4n27n34MSl24n39n0n0l32n39n0l48n39n0l64n39n0n39n0l32n39n0n39n0l48n39n0n39n0l24n51MN"
    Play SLAUNCH$
End Sub ' mooncr_sounds_22

' /////////////////////////////////////////////////////////////////////////////
' slightly long tune (can shorten by reducing 2x to 1x) to play at the end of a round or end of game

Sub mooncr_sounds_23_LONG
    SFAROUT1$ = "MBT80l8n22l12n22l8n26l12n26l8n29l12n29l8n34l12n34l8n22l12n22l8n26l12n26l8n29l12n29l8n34l12n34"
    Play SFAROUT1$
End Sub ' mooncr_sounds_23_LONG

' /////////////////////////////////////////////////////////////////////////////
' end of round tune (like 70 but 1x and each note steps up quickly)

Sub mooncr_sounds_24
    SFAROUT2$ = "MBT80l64n17l8n22l12n22l64n17l8n26l12n26l64n17l8n29l12n29l64n17l8n34l12n34"
    Play SFAROUT2$
End Sub ' mooncr_sounds_24

' /////////////////////////////////////////////////////////////////////////////
' beginning of round tune (determined triumphant mood like galaxian/galaga)

Sub mooncr_sounds_25
    SEND$ = "MBT96l6n22l16n27l2n25l16n27l8n25n27n29l16n25n27l48n25n27l12n29l32n27n29n27n29l4n34"
    Play SEND$
End Sub ' mooncr_sounds_25

' /////////////////////////////////////////////////////////////////////////////
' warble into beep (got a powerup or some successful action)

Sub mooncr_sounds_26
    SBONPLAY$ = "MBT64l64n15n22n19n22n19n22n27l32n34"
    Play SBONPLAY$
End Sub ' mooncr_sounds_26

' /////////////////////////////////////////////////////////////////////////////
' morse code type beeps (reciving a message)

Sub mooncr_sounds_29
    SSTAGE1$ = "MBMST64l32n40n0n40n40n0n40n40n40n40n0n40n40n0n40n0n40n0n40n40n40n0n40n0MN"
    Play SSTAGE1$
End Sub ' mooncr_sounds_29

' /////////////////////////////////////////////////////////////////////////////
' little tune to play at the start of a round or entering a new quadrant of space

Sub mooncr_sounds_31
    SFINAL$ = "MBMNT64l4n25l24n18n18l4n25l24n18n18l24n25n0n30n0l4n25"
    Play SFINAL$
End Sub ' mooncr_sounds_31

' /////////////////////////////////////////////////////////////////////////////
' quick little tune (5 notes) to play entering new space quadrant

Sub mooncr_sounds_32
    SFINAL$ = "MBMNT64l24n18n18l24n25n0n30n0l3n32"
    Play SFINAL$
End Sub ' mooncr_sounds_32

' /////////////////////////////////////////////////////////////////////////////
' end of round tune (7 notes)

Sub mooncr_sounds_33
    SFINAL$ = "MBMNT64l24n23n23l24n28n0n30n0l8n32l24n34l4n35"
    Play SFINAL$
End Sub ' mooncr_sounds_33

' /////////////////////////////////////////////////////////////////////////////
' entering new quadrant tune (6 notes)

Sub mooncr_sounds_34
    SFINAL$ = "MBMNT64l6n37l6n34l8n30n28n32n35"
    Play SFINAL$
End Sub ' mooncr_sounds_34

' /////////////////////////////////////////////////////////////////////////////
' another tune (9 notes)

Sub mooncr_sounds_35
    SFINAL$ = "MBMLT64l8n39l6n37l6n34l8n30n28n32n35n39l6n42"
    Play SFINAL$
End Sub ' mooncr_sounds_35

' /////////////////////////////////////////////////////////////////////////////
' alien attack alert type sound (not too annoying)

Sub mooncr_sounds_36
    SFINAL$ = "MBMLT64l64n37n42n49n37n42n49n37n42n49n37n42n49n37n42n49n37n42n49l16n42"
    Play SFINAL$
End Sub ' mooncr_sounds_36

' /////////////////////////////////////////////////////////////////////////////
' (SILENT)

Sub mooncr_sounds_37
    SFINAL$ = "MBMLT64"
    Play SFINAL$
End Sub ' mooncr_sounds_37

' /////////////////////////////////////////////////////////////////////////////
' battlestar galactica 70s theme

Sub mooncr_sounds_38_BSG_LONG
    SFINAL$ = "MBMNT64l6n13n15n18n20n25l24n23n22l12n20l6n23l24n22n20l12n18n22n18l6n20"
    Play SFINAL$
End Sub ' mooncr_sounds_38_BSG_LONG

' /////////////////////////////////////////////////////////////////////////////
' battlestar galactica type music (start of a new round)

Sub mooncr_sounds_39_BSG_LONG
    SFINAL$ = "MBMLT64l64n25n30n37MNl16n0l24n13n13n18n0n18n18n20n0n20n20n25n0n25n25n23n22n20n0"
    Play SFINAL$
End Sub ' mooncr_sounds_39_BSG_LONG

' /////////////////////////////////////////////////////////////////////////////
' battlestar galactica theme music (2nd half)

Sub mooncr_sounds_40_BSG_LONG
    SFINAL$ = "MBMNT64l24n23n0n23n23n22n20n18n0l12n22l24n23n0n18n0n22n0l4n20"
    Play SFINAL$
End Sub ' mooncr_sounds_40_BSG_LONG

' /////////////////////////////////////////////////////////////////////////////
' battlestar galactica 70s theme (short version at start of a round)

Sub mooncr_sounds_42_BSG_LONG
    SFINAL$ = "MBMNT48l64n20l4n32MLl12n32n30n29n27n25l4n30l24n32n34l4n32"
    Play SFINAL$
End Sub ' mooncr_sounds_42_BSG_LONG

' /////////////////////////////////////////////////////////////////////////////
' battlestar galactica 70s theme (2nd part) (short version at the start of a round)

Sub mooncr_sounds_43_BSG_LONG
    SFINAL$ = "MBMNT48l12n8l4n32MLl12n32n30n29n27T64n25l4n35l24n37n39"
    Play SFINAL$
End Sub ' mooncr_sounds_43_BSG_LONG

' /////////////////////////////////////////////////////////////////////////////
' alarm or alert sound with longer beep at end

Sub mooncr_sounds_44_LONG
    SFINAL$ = "MBMLT64l64n25n37n25n37n25n37n25n37n25n37n25n37n25n37n25n37l8n37"
    'SND = 1
    Play SFINAL$
End Sub ' mooncr_sounds_44_LONG

' /////////////////////////////////////////////////////////////////////////////
' frog.bas
' 3 notes descending (turned shields off or similar type action)

Sub frog_bas_sound_1
    'DIE:
    Sound 500, 5: Sound 200, 3: Sound 100, 2
End Sub ' frog_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' higher pitched notes ascending sweep then two lower tones at end (some action?)

Sub frog_bas_sound_2
    'LOSE:
    For X = 0 To 500 Step 40: Sound 2000 + X, 1: Next
    Sound 200, 4: Sound 100, 2
End Sub ' frog_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' simple high chimy beep

Sub frog_bas_sound_3
    'LIFEUP:
    Sound 3000, .9: Sound 3000, .2: Sound 4000, .1
End Sub ' frog_bas_sound_3

' /////////////////////////////////////////////////////////////////////////////
' cr.bas
' (SILENT)

' * CAVE RAIDER             Version 1.4 *
' * ===========                         *
' * Copyright (c) 2004 by Paul  Redling *

Sub cr_bas_sound_1
    Play "mb"
End Sub ' cr_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' lower 2-note beep-beep (enemies detected or some action)

Sub cr_bas_sound_3
    'Chest of grenades
    Play "mst120o1l16cl8mlc"
End Sub ' cr_bas_sound_3

' /////////////////////////////////////////////////////////////////////////////
' higher warbly pulsing (some action)

Sub cr_bas_sound_4
    'Gem/scroll
    Play "mlt250o4l64agagag>egg>g"
End Sub ' cr_bas_sound_4

' /////////////////////////////////////////////////////////////////////////////
' med-slow descending sweep sound (if higher could be skidding)

Sub cr_bas_sound_5
    'Male CR
    For n! = 10.8 To 8 Step -.1: Sound (Tan(n!) + 50) * 25, .5: Next n!
End Sub ' cr_bas_sound_5

' /////////////////////////////////////////////////////////////////////////////
' hig-med descending sweep sound

Sub cr_bas_sound_6
    'Female CR
    For n! = 10.8 To 8 Step -.1: Sound (Tan(n!) + 50) * 28, .5: Next n!
End Sub ' cr_bas_sound_6

' /////////////////////////////////////////////////////////////////////////////
' quick lower pitched murp sound

Sub cr_bas_sound_8
    'Grenade launcher
    Play "mnt255o1l32ccc"
End Sub ' cr_bas_sound_8

' /////////////////////////////////////////////////////////////////////////////
' finished round happy tune

Sub cr_bas_sound_12_TUNE
    'Exit cave 1-5
    Play "mst100o3l16cdel8gp64l16el4mlg"
End Sub ' cr_bas_sound_12_TUNE

' /////////////////////////////////////////////////////////////////////////////
' simple theme song (relatively long)

Sub cr_bas_sound_14_tune_LONG
    ' Hall of Fame
    'Dim tune As Integer
    'Dim iTimes As Integer
    'iTimes = 1
    'For tune = 1 To iTimes
    Play "mnt190o2l2al4fgafgal2a#l4gaa#gaa#"
    CR_Delay -5: 'If dkey$ <> "" Then Exit For
    Play "l2>cl4d.l8<al4aa#fgl2al4gfl1>cl2<a"
    CR_Delay -5: 'If dkey$ <> "" Then Exit For
    Play "l4fgafgal2a#l4gaa#gaa#l2>cl4d.l8<a"
    CR_Delay -6: 'If dkey$ <> "" Then Exit For
    Play "l4aa#fga>c<a.l8gl1mlf"
    CR_Delay -5
    'Next tune
End Sub ' cr_bas_sound_14_tune_LONG

' /////////////////////////////////////////////////////////////////////////////
' * CAVE RAIDER             Version 1.4 *
' (used by cr_bas_sound_14_tune_LONG)

'Sub CR_Delay (seconds!)
Sub CR_Delay (iSeconds As Integer)
    Dim iCount As Integer
    Dim iTime As Integer
    iTime = Abs(iSeconds)
    iCount = 0
    Do
        iCount = iCount + 1
        If iCount > iTime Then Exit Do
        _Limit 1 ' keep loop at 10 frames per second
    Loop

    ''Delays the program or sleeps
    '' If seconds! > 0, then it delays the program
    '' If seconds! <= 0, then it sleeps
    '' Delay 0 = Sleep, Delay -1 = Sleep 1, Delay -1.5 = Sleep 1.5
    '' Unlike the SLEEP statement, the keyboard buffer is cleared after a key is
    '' pressed.
    '
    'secs! = Abs(seconds!)
    'If secs! = 0 Then secs! = 86400
    't! = Timer
    'Do
    '    If seconds! > 0 Then 'Delay
    '        While InKey$ <> "": Wend 'Clear the keyboard buffer (no beeps!)
    '    Else 'Sleep
    '        dkey$ = InKey$ 'To read a keystroke, make "dkey$" DIM
    '        If dkey$ <> "" Then Exit Do 'SHARED in the main module.
    '    End If
    'Loop Until Abs(Timer - t!) >= secs! 'No endless loop at midnight!

End Sub ' CR_Delay

' /////////////////////////////////////////////////////////////////////////////
' demo3.bas
' alert or space warp sound - gets faster as it goes (make a little longer so it gets really fast then good for warp)

'DECLARE SUB Bounce (Hi%, Low%)
'DECLARE SUB Fall (Hi%, Low%, Del%)
'DECLARE SUB Siren (Hi%, Range%)
'DECLARE SUB Klaxon (Hi%, Low%)
'DefInt A-Z

' QB 4.5 Version of Sound Effects Demo Program

Sub demo3_Bounce
    'Case Is = "B"
    '    Print "Bouncing . . . "
    Bounce 32767, 246
End Sub ' demo3_Bounce

' /////////////////////////////////////////////////////////////////////////////
' Loop two sounds down at decreasing time intervals
' (used by demo3_Bounce)

Sub Bounce (Hi%, Low%)
    For Count = 60 To 1 Step -2
        Sound Low% - Count / 2, Count / 20
        Sound Hi%, Count / 15
    Next Count
End Sub ' Bounce

' /////////////////////////////////////////////////////////////////////////////
' longer descending bomb dropping sound

Sub demo3_fall
    'Case Is = "F"
    '    Print "Falling . . . "
    Fall 2000, 550, 500
End Sub ' demo3_fall

' /////////////////////////////////////////////////////////////////////////////
' Loop down from a high sound to a low sound
' (used by demo3_fall)

Sub Fall (Hi%, Low%, Del%)
    For Count = Hi% To Low% Step -10
        Sound Count, Del% / Count
    Next Count
End Sub ' Fall

' /////////////////////////////////////////////////////////////////////////////
' slow siren
' (goes on forever how do you stop?) <- DISABLED InKey LOOP

Sub demo3_siren
    'Case Is = "S"
    '    Print "Wailing . . ."
    '    Print " . . . press any key to end."
    Siren 780, 650
End Sub ' demo3_siren

' /////////////////////////////////////////////////////////////////////////////
' Loop a sound from low to high to low
' (used by demo3_siren)

Sub Siren (Hi%, Range%)
    'Dim iLoop As Integer
    Dim iCount As Integer
    'Do While InKey$ = ""
    'For iLoop = 1 To 2
    For iCount = Range% To -Range% Step -4
        Sound Hi% - Abs(Count), .3
        iCount = iCount - 2 / Range%
    Next iCount
    'Next iLoop
    'Loop
End Sub ' Siren

' /////////////////////////////////////////////////////////////////////////////
' alarm sound (need to limit the length and remove the wait for keypress) for space ship

Sub demo3_klaxon
    'Case Is = "K"
    '    Print "Oscillating . . ."
    '    Print " . . . press any key to end."
    Klaxon 987, 329
End Sub ' demo3_klaxon

' /////////////////////////////////////////////////////////////////////////////
' (used by demo3_klaxon)

' Plays sounds 3 times

' Originally:
' Alternate two sounds until a key is pressed

Sub Klaxon (Hi%, Low%) Static
    Dim iLoop As Integer
    'Do While InKey$ = ""
    For iLoop = 1 To 3
        Sound Hi%, 5
        Sound Low%, 5
    Next iLoop
    'Loop
End Sub ' Klaxon

' /////////////////////////////////////////////////////////////////////////////
' mosh.bas
' descending then ascending chirping cascading type notes (beginning of a round)

Sub mosh_at_a_and_p_theme
    ' lazer song
    For i = 1 To 20
        Hi = i * 100
        Lo = (20 - i) * 100
        Sound Hi, 1
        Sound Lo, 1
    Next i
End Sub ' mosh_at_a_and_p_theme

' /////////////////////////////////////////////////////////////////////////////
' med-fast high to low sweep (dropped bomb or something falling)

Sub ELYSIAN_fp3_LONG
    'For y = 200 To 0 Step -1
    For y = 200 To 10 Step -1
        'Sound 100, .1
        Sound y * 10, .1
    Next y
End Sub ' ELYSIAN_fp3_LONG

' /////////////////////////////////////////////////////////////////////////////
' quick chirpy beep (pilfered or lost object)

Sub ELYSIAN_csound
    For d = 2500 To 5000 Step 100
        Sound d, .04
    Next d
End Sub ' ELYSIAN_csound

' /////////////////////////////////////////////////////////////////////////////
' 18WHEELR.BAS
' slower low to high smooth sweep (warp or powering up)

Sub SOUND_18WHEELR_BAS_1
    vel = 32
    For iLoop = 1 To 100
        vel = vel + .25: If vel > 65 Then vel = 65: Exit For
        Sound 2 ^ (Abs(vel) / 24) * 55, .5
    Next iLoop
End Sub ' SOUND_18WHEELR_BAS_1

' /////////////////////////////////////////////////////////////////////////////
' slower high to low smooth sweep (powering down)

Sub SOUND_18WHEELR_BAS_2
    vel = 32
    For iLoop = 1 To 100
        vel = vel - .5: If vel < 0 Then vel = 0: Exit For
        Sound 2 ^ (Abs(vel) / 24) * 55, .5
    Next iLoop
End Sub ' SOUND_18WHEELR_BAS_2

' /////////////////////////////////////////////////////////////////////////////
' MONOP.BAS
' quick high pitched alert sound

Sub MONOP_BAS_SOUND_1
    Sound 523, 3: Sound 30000, 1: Sound 523, 3: Sound 1047, 3: Sound 30000, 1: Sound 1047, 3
End Sub ' MONOP_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' low pitched alert sound (with high pitched sounds mixed in)

Sub MONOP_BAS_SOUND_2
    Sound 174, 2: Sound 30000, 1: Sound 174, 2: Sound 30000, 1: Sound 174, 2
End Sub ' MONOP_BAS_SOUND_2

' /////////////////////////////////////////////////////////////////////////////
' short low/high sound

Sub MONOP_BAS_SOUND_4
    Sound 60, 1: Sound 30000, 1: Sound 60, 1
End Sub ' MONOP_BAS_SOUND_4

' /////////////////////////////////////////////////////////////////////////////
' 2-beep alert/action (with high pitch mixed in)

Sub MONOP_BAS_SOUND_5
    Sound 440, 1: Sound 30000, 1: Sound 440, 2
End Sub ' MONOP_BAS_SOUND_5

' /////////////////////////////////////////////////////////////////////////////
' jittering descending sweeping sound - a space warp maybe? traving through a vortex?

Sub MONOP_BAS_SOUND_6
    For Y = 1042 To 262 Step -10
        Sound Y, .2: Sound 30000, .1
    Next Y
End Sub ' MONOP_BAS_SOUND_6

' /////////////////////////////////////////////////////////////////////////////
' SEARCH.BAS
' short sharp little beep (some action)

Sub SEARCH_BAS_SOUND_1
    For Z = 1 To 50: Sound 37, .03: Sound 30000, .03: Next Z
End Sub ' SEARCH_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' SLIME.BAS
' fast pulsing high pitch sound (like spelunker ghost killer sound?)

Sub SLIME_BAS_SOUND_1
    For z% = 1 To 1500
        zz% = Int(200 * Rnd) + 200: zzz% = Int(50 * Rnd) + 150
        ZX = ZX + 1: If ZX = 10 And ZXX < 60 Then ZX = 0: ZXX = ZXX + 1: Sound 1000 * Rnd + 2200, .2
    Next z%
End Sub ' SLIME_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' 3x fast low to high space radio sweeping sound (REMOVE PRINT STATEMENTS)

Sub SLIME_BAS_SOUND_2_LONG
    cdc = 0
    For C = 1 To 1000 ' 8000
        CD = Int(20 * Rnd) + 1
        If CD = 5 Or cdc > 0 Then
            cdc = cdc + 1
        Else
            cdc = cdc - 1
        End If
        If Abs(cdc) > 300 Then
            cdc = 0
        End If

        '168 If cdc > 0 Then Sound Int(100 * Rnd) + 100, .05
        freq = (Abs(Int(10 * Rnd) + cdc)) * 100

        If freq < 100 Then
            freq = 100
        ElseIf freq > 32767 Then
            freq = 32767
        End If

        'dura = Int(1000 * Rnd) * .001
        'Sound freq, dura

        Sound freq, .05
        'Print "cdc=" + Str$(cdc) ' DEBUG

    Next C
End Sub ' SLIME_BAS_SOUND_2_LONG

' /////////////////////////////////////////////////////////////////////////////
' quick high-pitch random chirping (spelunker ghost killer) kind of annoying

Sub SLIME_BAS_SOUND_5
    For z% = 1 To 50
        Sound 1000 * Rnd + 2000, z% / 100
    Next z%
End Sub ' SLIME_BAS_SOUND_5

' /////////////////////////////////////////////////////////////////////////////
' long beep then fast ascending sweep (med-low to high) - space warp?

Sub SLIME_BAS_SOUND_6
    Sound 262, 10: For z% = 1 To 3000: Next z%
    For z% = 70 To 350
        Sound z%, .1
    Next z%
End Sub ' SLIME_BAS_SOUND_6

' /////////////////////////////////////////////////////////////////////////////
' trippy tuning into space transmission type sound (cool!)

Sub SLIME_BAS_SOUND_13
    '12350 For ZX = 115 To 200
    For ZX = 1 To 2000
        '12360 Sound 250 - ZX, .1
        Sound 25000 - (ZX * 10), .1
    Next ZX
End Sub ' SLIME_BAS_SOUND_13

' /////////////////////////////////////////////////////////////////////////////
' smooth descending dropping sound (med-slow) repeat for alarm or else blasting off into warp

Sub SLIME_BAS_SOUND_14
    For z% = -20 To 193
        Sound 425 - z% * 2, .2
    Next z%
End Sub ' SLIME_BAS_SOUND_14

' /////////////////////////////////////////////////////////////////////////////
' quick descending laser sound

Sub snatch_bas_sound_2_rabbit
    'RR(2) = 6
    '520 If I$ = "R" Or I$ = "r" Then Z = Int((RR(2) * Rnd + 2) / 2)'

    RR = 6
    Z = Int((RR * Rnd + 2) / 2)

    For ZZ = 1 To Z
        For ZZZ = 600 To 100 Step -20
            Sound ZZZ, .1
        Next ZZZ
    Next ZZ
    '640 GoTo 490
End Sub ' snatch_bas_sound_2_rabbit

' /////////////////////////////////////////////////////////////////////////////
' faster shorter descending sound
' (same as sound 157: snatch_bas_sound_3_chipmunk)

Sub snatch_bas_sound_4_groundhog
    'RR(4) = 3
    '540 If I$ = "G" Or I$ = "g" Then Z = Int((RR(4) * Rnd + 2) / 4)
    '550 If I$ = "Q" Or I$ = "q" Then GoTo finish

    RR = 3
    Z = Int((RR * Rnd + 2) / 4)

    For ZZ = 1 To Z
        For ZZZ = 600 To 100 Step -20
            Sound ZZZ, .1
        Next ZZZ
    Next ZZ
    '640 GoTo 490
End Sub ' snatch_bas_sound_4_groundhog

' /////////////////////////////////////////////////////////////////////////////
' medium speed descending sound (dropping bomb or launching something)

Sub snatch_bas_sound_5
    For Z = 1000 To 100 Step -10
        Sound Z, .1
    Next Z
End Sub ' snatch_bas_sound_5

' /////////////////////////////////////////////////////////////////////////////
' quick high to low descending sweep (phaser or dropped object)

Sub waster_bas_sound_2
    For z = 5000 To 1 Step -81
        Sound z, .03
    Next z
End Sub ' waster_bas_sound_2

' /////////////////////////////////////////////////////////////////////////////
' quick sharp beep (some action or non-action)

Sub waster_bas_sound_3
    For z = 1 To 30
        Sound 50, .03
        Sound 5000, .03
    Next z
End Sub ' waster_bas_sound_3

' /////////////////////////////////////////////////////////////////////////////
' short medium-low buzzer sound

Sub waster_bas_sound_4
    For z = 1 To 30
        Sound 121, .1: Sound 283, .1: Sound 1255, .1
    Next z
End Sub ' waster_bas_sound_4

' /////////////////////////////////////////////////////////////////////////////
' high quick chirp

Sub waster_bas_sound_10
    For z = 5000 To 2000 Step -162
        Sound z, .03
    Next z
End Sub ' waster_bas_sound_10

' /////////////////////////////////////////////////////////////////////////////
' a little lower quick fwip sound

Sub waster_bas_sound_15
    'sw:
    For z = 1 To 20
        eq = Int(2000 * Rnd) + 2000
        Sound eq, .03
    Next z
End Sub ' waster_bas_sound_15

' /////////////////////////////////////////////////////////////////////////////
' med-high quick fwip sound

Sub waster_bas_sound_16
    For z = 5000 To 2000 Step -162
        Sound z, .03
    Next z
End Sub ' waster_bas_sound_16

' /////////////////////////////////////////////////////////////////////////////
' longer low to high smoothly ascending sweep like a slow alarm (leaving a space quadrant or launching something)

Sub xgame_bas_sound_7_LONG
    For Z = 1 To 460
        Sound (Z + 20) * 5, .1
    Next Z
End Sub ' xgame_bas_sound_7_LONG

' /////////////////////////////////////////////////////////////////////////////
' medium warbling sound like a river rushing by

Sub xgame_bas_sound_8_LONG
    For Z = 1 To 1000
        Sound Int(1000 * Rnd) + 200, .1
    Next Z
End Sub ' xgame_bas_sound_8_LONG

' /////////////////////////////////////////////////////////////////////////////
' GOLF.BAS
' quick pulsing alarm type sound (medium pitched)

Sub golf_bas_sound_1
    Sound 1047, 1: Sound 784, 1: Sound 1047, 1: Sound 784, 1: Sound 1047, 1: DFG = 0
End Sub ' golf_bas_sound_1

' /////////////////////////////////////////////////////////////////////////////
' ALRMBOBS.BAS
' warbly high-low-high-medium sound - not quite a siren but could be an alarm if longer

Sub ALRMBOBS_BAS_sound_1
    For t% = 0 To 447
        Sound 1000 + t%, .03
        Sound 1400 - t%, .03
    Next
End Sub ' ALRMBOBS_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' ANSISHOW.BAS
' longer low-high fwip sound (launching something)

Sub ANSISHOW_BAS_sound_1_LONG
    For S% = 5 To 35: Sound S% * 200, .1: Next
End Sub ' ANSISHOW_BAS_sound_1_LONG

' /////////////////////////////////////////////////////////////////////////////
' ANSISUB.BAS
' longer low-high fwip sound (like sound 189: ANSISHOW_BAS_sound_1_LONG)

Sub ANSISUB_BAS_sound_1_LONG
    For S% = 5 To 35: Sound S% * 200, .1: Next
End Sub ' ANSISUB_BAS_sound_1_LONG

' /////////////////////////////////////////////////////////////////////////////
' BEEP!.BAS
' pulsing med-high sound (firing some kind of beam or transmitting)

Sub BEEP_BAS_SOUND_cricket
    For t% = 0 To 40 Step 4
        Sound t% + 2000, .11
        Sound t% + 5000, .11
        Sound t% + 6000, .11
        Sound t% + 3000, .11
        Sound t% + 2000, .2
    Next
End Sub ' BEEP_BAS_SOUND_cricket

' /////////////////////////////////////////////////////////////////////////////
' med-low quick boop sound (bounced into something)

Sub BEEP_BAS_SOUND_frog
    For t% = 100 To 200 Step 5
        Sound 300 - t%, .11
        Sound t%, .11
        Sound t% - 50, .11
    Next
End Sub ' BEEP_BAS_SOUND_frog

' /////////////////////////////////////////////////////////////////////////////
' med-high pulsing type sound (more like a primitive skid sound than a phone)

Sub BEEP_BAS_SOUND_phone
    For t! = .1 To .3 Step .01
        Sound 3136, t!
        Sound 1568, t!
        Sound 784, t!
    Next
End Sub ' BEEP_BAS_SOUND_phone

' /////////////////////////////////////////////////////////////////////////////
' quick ascending sweep + descending sweep (too fast for a wolf whistle - would need speed fixed for that)

Sub BEEP_BAS_SOUND_wolfwhistle
    For t% = 1000 To 4000 Step 70
        Sound t%, .03
        Sound t% + 10, .03
        Sound t% + 30, .03
    Next
    For t% = 1 To 50: Wait &H3DA, 8: Wait &H3DA, 255, 8: Next
    For t% = 700 To 2500 Step 80
        Sound t%, .03
        Sound t% + 10, .03
        Sound t% + 30, .03
    Next
    For t% = 2500 To 400 Step -80
        Sound t%, .03
        Sound t% + 10, .03
        Sound t% + 30, .03
    Next
End Sub ' BEEP_BAS_SOUND_wolfwhistle

' /////////////////////////////////////////////////////////////////////////////
' LLED.BAS
' quick 2-tone beep (finished something or activated some device)

Sub LLED_BAS_SOUND_1
    For t% = 10 To 50: Sound 100 - t, .04: Sound 999, .07: Next
End Sub ' LLED_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' quick med-low ziiip type sound (using some object)

Sub LLED_BAS_SOUND_2
    For t% = 1 To 20: Sound 2000, .05: Sound 7000, .07: Next
End Sub ' LLED_BAS_SOUND_2

' /////////////////////////////////////////////////////////////////////////////
' fast low-hi zeeep semi-sharp sound (zippering something closed?)

Sub LLED_BAS_SOUND_3
    For t% = 100 To 300 Step 20
        Sound 2000 + t% * 5, .07: Sound 5000 + t% * 2, .03
    Next
End Sub ' LLED_BAS_SOUND_3

' /////////////////////////////////////////////////////////////////////////////
' QBLANDER.BAS
' low warbling rumbly type sound

Sub QBLANDER_BAS_SOUND_1
    For x = 1 To 50
        For Y = 1 To 50
            'C = RND * 200 + 10
            'a! = RND: a! = a! * 7!
            'r = RND * 20 + 5
            'CIRCLE (Ship.X + 14, Ship.Y + 14), r, C, , , a!
        Next
        Sound 73 + Rnd * 20, .7
    Next
End Sub ' QBLANDER_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' CONSANSI.BAS
' fast low to high fweep (zipping by or 1st half of tuning into station)

Sub CONSANSI_BAS_SOUND_1
    For S% = 5 To 35: Sound S% * 200, .1: Next
End Sub ' CONSANSI_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' FADE-IO.BAS
' 4-note sequence at beginning of round or battle

Sub FADE_IO_BAS_SOUND_1
    Sound 416, 4: Sound 524, 7: Sound 468, 4: Sound 627, 9
End Sub ' FADE_IO_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' KISSED.BAS
' quick short ascending sweep (hit object that makes you skid or some kind of bird call)

Sub KISSED_BAS_sound_1_alarm
    For t% = 0 To 25: Sound 2200 + 2 * t%, .1: Sound 2225 + t%, .05: Next
End Sub ' KISSED_BAS_sound_1_alarm

' /////////////////////////////////////////////////////////////////////////////
' SCROLL12.BAS
' loooong sequence of notes based on a text string?

Sub SCROLL12_BAS_SOUND_1
    text$ = " ... ... ...   This is a simple scrolling message. It"
    text$ = text$ + " doesn't mean anything and really doesn't say"
    text$ = text$ + " anything. It just scrolls across the screen "
    text$ = text$ + "until somebody gets sick of it and hits a key"
    text$ = text$ + ". I hope you like the way it works... ... ..."

    'While InKey$ = ""
    freq% = 800 - ((Asc(text$) And 28) \ 3) * 48
    dur! = (Asc(text$) And 7) * .3 + 1
    Sound freq%, dur!
    text$ = Mid$(text$ + Left$(text$, 1), 2)
    If Mid$(text$, 77, 3) = "..." Then Beep
    'Wend

    'Screen 0: End
End Sub ' SCROLL12_BAS_SOUND_1

' /////////////////////////////////////////////////////////////////////////////
' STEEL.BAS
' super high short zeep sound

Sub STEEL_BAS_sound_1
    Sound 6000, .03: Sound 20000, 1
End Sub ' STEEL_BAS_sound_1

' /////////////////////////////////////////////////////////////////////////////
' high short zeep sound

Sub STEEL_BAS_sound_2
    Sound 3000, .03: Sound 20000, 1
End Sub ' STEEL_BAS_sound_2

' /////////////////////////////////////////////////////////////////////////////
' medium speed high to low sweep (drop object or some action)

Sub StarBlast_BAS_sound_7
    'O B J E C T   E L I M I N A T E D
    Input "press enter to continue"; in$
    'Object was hit
    For F = 700 To 100 Step -100: Sound F, .75: Next
End Sub ' StarBlast_BAS_sound_7

' /////////////////////////////////////////////////////////////////////////////
' 3 note alert (same low note 3x) to use as some non-obtrusive alert

Sub StarBlast_BAS_sound_9
    For S = 1 To 3: Sound 180, 4: Sound 0, 2: Next
End Sub ' StarBlast_BAS_sound_9

' /////////////////////////////////////////////////////////////////////////////
' based on drum sound from
' SierraKen_My 1996 Tiny Dungeon Game v2.bas
'
' madscijr improved for tribal drum sequence (repeats 4x)

Sub Tiny_Dungeon_sound_2_drumming_v2
    'The sound scared all the bats away!
    'drumming:
    For drum = 1 To 4 ' 100
        For dr = 1 To 20 Step 2
            f1 = 100 + dr * 10
            'print "f1=" + Str$(f1)
            Sound f1, .1

            'For tm = 1 To 3000: Next tm
            f2 = ((10 * dr) / 2) + 60
            'print "f2=" + Str$(f2)
            Sound f2, .75

            _Limit 10 ' keep loop at 10 frames per second
        Next dr


        _Limit 5 ' keep loop at 5 frames per second
    Next drum
End Sub ' Tiny_Dungeon_sound_2_drumming_v2

' /////////////////////////////////////////////////////////////////////////////

' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
' END OTHER SOUNDS
' @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

' ################################################################################################################################################################
' END SOUND ROUTINES
' ################################################################################################################################################################




























' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' BEGIN DEBUGGING ROUTINES #DEBUGGING
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Sub DebugPrint (s$)
    If m_bTesting = TRUE Then
        _Echo s$
        'ReDim arrLines$(0)
        'dim delim$ : delim$ = Chr$(13)
        'split MyString, delim$, arrLines$()
    End If
End Sub ' DebugPrint

'' /////////////////////////////////////////////////////////////////////////////
'
'Sub DebugPause (sPrompt As String, iRow As Integer, iColumn As Integer, fgColor As _Unsigned Long, bgColor As _Unsigned Long)
'    Color fgColor, bgColor
'
'    PrintString iRow, iColumn, String$(128, " ")
'
'    PrintString iRow, iColumn, sPrompt
'    Sleep
'    '_KEYCLEAR: _DELAY 1
'    'DO
'    'LOOP UNTIL _KEYDOWN(13) ' leave loop when ENTER key pressed
'    '_KEYCLEAR: _DELAY 1
'End Sub ' DebugPause
'
'' /////////////////////////////////////////////////////////////////////////////
'
'Sub DebugOut (sPrompt As String, iRow As Integer, iColumn As Integer, fgColor As _Unsigned Long, bgColor As _Unsigned Long)
'    Color fgColor, bgColor
'    PrintString iRow, iColumn, String$(128, " ")
'    PrintString iRow, iColumn, sPrompt
'End Sub ' DebugOut

' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' END DEBUGGING ROUTINES @DEBUGGING
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' BEGIN GENERAL PURPOSE ROUTINES #GEN
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /////////////////////////////////////////////////////////////////////////////
' Convert a value to string and trim it (because normal Str$ adds spaces)

Function cstr$ (myValue)
    'cstr$ = LTRIM$(RTRIM$(STR$(myValue)))
    cstr$ = _Trim$(Str$(myValue))
End Function ' cstr$

' /////////////////////////////////////////////////////////////////////////////
' Convert a Long value to string and trim it (because normal Str$ adds spaces)

Function cstrl$ (myValue As Long)
    cstrl$ = _Trim$(Str$(myValue))
End Function ' cstrl$

' /////////////////////////////////////////////////////////////////////////////
' Convert a Single value to string and trim it (because normal Str$ adds spaces)

Function cstrs$ (myValue As Single)
    ''cstr$ = LTRIM$(RTRIM$(STR$(myValue)))
    cstrs$ = _Trim$(Str$(myValue))
End Function ' cstrs$

' /////////////////////////////////////////////////////////////////////////////
' Convert an unsigned Long value to string and trim it (because normal Str$ adds spaces)

Function cstrul$ (myValue As _Unsigned Long)
    cstrul$ = _Trim$(Str$(myValue))
End Function ' cstrul$

' /////////////////////////////////////////////////////////////////////////////
' Scientific notation - QB64 Wiki
' https://www.qb64.org/wiki/Scientific_notation

' Example: A string function that displays extremely small or large exponential decimal values.

Function DblToStr$ (n#)
    value$ = UCase$(LTrim$(Str$(n#)))
    Xpos% = InStr(value$, "D") + InStr(value$, "E") 'only D or E can be present
    If Xpos% Then
        expo% = Val(Mid$(value$, Xpos% + 1))
        If Val(value$) < 0 Then
            sign$ = "-": valu$ = Mid$(value$, 2, Xpos% - 2)
        Else valu$ = Mid$(value$, 1, Xpos% - 1)
        End If
        dot% = InStr(valu$, "."): L% = Len(valu$)
        If expo% > 0 Then add$ = String$(expo% - (L% - dot%), "0")
        If expo% < 0 Then min$ = String$(Abs(expo%) - (dot% - 1), "0"): DP$ = "."
        For n = 1 To L%
            If Mid$(valu$, n, 1) <> "." Then num$ = num$ + Mid$(valu$, n, 1)
        Next
    Else DblToStr$ = value$: Exit Function
    End If
    DblToStr$ = _Trim$(sign$ + DP$ + min$ + num$ + add$)
End Function ' DblToStr$

' /////////////////////////////////////////////////////////////////////////////

Function FormatNumber$ (myValue, iDigits As Integer)
    Dim strValue As String
    strValue = DblToStr$(myValue) + String$(iDigits, " ")
    If myValue < 1 Then
        If myValue < 0 Then
            strValue = Replace$(strValue, "-.", "-0.")
        ElseIf myValue > 0 Then
            strValue = "0" + strValue
        End If
    End If
    FormatNumber$ = Left$(strValue, iDigits)
End Function ' FormatNumber$

' /////////////////////////////////////////////////////////////////////////////
' From: Bitwise Manipulations By Steven Roman
' http://www.romanpress.com/Articles/Bitwise_R/Bitwise.htm

' Returns the 8-bit binary representation
' of an integer iInput where 0 <= iInput <= 255

Function GetBinary$ (iInput1 As Integer)
    Dim sResult As String
    Dim iLoop As Integer
    Dim iInput As Integer: iInput = iInput1

    sResult = ""

    If iInput >= 0 And iInput <= 255 Then
        For iLoop = 1 To 8
            sResult = LTrim$(RTrim$(Str$(iInput Mod 2))) + sResult
            iInput = iInput \ 2
            'If iLoop = 4 Then sResult = " " + sResult
        Next iLoop
    End If

    GetBinary$ = sResult
End Function ' GetBinary$

' /////////////////////////////////////////////////////////////////////////////
' wonderfully inefficient way to read if a bit is set
' ival = GetBit256%(int we are comparing, int containing the bits we want to read)

' See also: GetBit256%, SetBit256%

Function GetBit256% (iNum1 As Integer, iBit1 As Integer)
    Dim iResult As Integer
    Dim sNum As String
    Dim sBit As String
    Dim iLoop As Integer
    Dim bContinue As Integer
    'DIM iTemp AS INTEGER
    Dim iNum As Integer: iNum = iNum1
    Dim iBit As Integer: iBit = iBit1

    iResult = FALSE
    bContinue = TRUE

    If iNum < 256 And iBit <= 128 Then
        sNum = GetBinary$(iNum)
        sBit = GetBinary$(iBit)
        For iLoop = 1 To 8
            If Mid$(sBit, iLoop, 1) = "1" Then
                'if any of the bits in iBit are false, return false
                If Mid$(sNum, iLoop, 1) = "0" Then
                    iResult = FALSE
                    bContinue = FALSE
                    Exit For
                End If
            End If
        Next iLoop
        If bContinue = TRUE Then
            iResult = TRUE
        End If
    End If

    GetBit256% = iResult
End Function ' GetBit256%

' /////////////////////////////////////////////////////////////////////////////
' From: Bitwise Manipulations By Steven Roman
' http://www.romanpress.com/Articles/Bitwise_R/Bitwise.htm

' Returns the integer that corresponds to a binary string of length 8

Function GetIntegerFromBinary% (sBinary1 As String)
    Dim iResult As Integer
    Dim iLoop As Integer
    Dim strBinary As String
    Dim sBinary As String: sBinary = sBinary1

    iResult = 0
    strBinary = Replace$(sBinary, " ", "") ' Remove any spaces
    For iLoop = 0 To Len(strBinary) - 1
        iResult = iResult + 2 ^ iLoop * Val(Mid$(strBinary, Len(strBinary) - iLoop, 1))
    Next iLoop

    GetIntegerFromBinary% = iResult
End Function ' GetIntegerFromBinary%

' /////////////////////////////////////////////////////////////////////////////

Function IIF (Condition, IfTrue, IfFalse)
    If Condition Then IIF = IfTrue Else IIF = IfFalse
End Function

' /////////////////////////////////////////////////////////////////////////////

Function IIFSTR$ (Condition, IfTrue$, IfFalse$)
    If Condition Then IIFSTR$ = IfTrue$ Else IIFSTR$ = IfFalse$
End Function

' /////////////////////////////////////////////////////////////////////////////
' https://slaystudy.com/qbasic-program-to-check-if-number-is-even-or-odd/

Function IsEven% (n)
    If n Mod 2 = 0 Then
        IsEven% = TRUE
    Else
        IsEven% = FALSE
    End If
End Function ' IsEven%

' /////////////////////////////////////////////////////////////////////////////
' https://slaystudy.com/qbasic-program-to-check-if-number-is-even-or-odd/

Function IsOdd% (n)
    If n Mod 2 = 1 Then
        IsOdd% = TRUE
    Else
        IsOdd% = FALSE
    End If
End Function ' IsOdd%

' /////////////////////////////////////////////////////////////////////////////
' By sMcNeill from https://www.qb64.org/forum/index.php?topic=896.0

Function IsNum% (text$)
    Dim a$
    Dim b$
    a$ = _Trim$(text$)
    b$ = _Trim$(Str$(Val(text$)))
    If a$ = b$ Then
        IsNum% = TRUE
    Else
        IsNum% = FALSE
    End If
End Function ' IsNum%

' /////////////////////////////////////////////////////////////////////////////
' Re: Does a Is Number function exist in QB64?
' https://www.qb64.org/forum/index.php?topic=896.15

' MWheatley
' « Reply #18 on: January 01, 2019, 11:24:30 AM »

' returns 1 if string is an integer, 0 if not
Function IsNumber (text$)
    Dim i As Integer

    IsNumber = 1
    For i = 1 To Len(text$)
        If Asc(Mid$(text$, i, 1)) < 45 Or Asc(Mid$(text$, i, 1)) >= 58 Then
            IsNumber = 0
            Exit For
        ElseIf Asc(Mid$(text$, i, 1)) = 47 Then
            IsNumber = 0
            Exit For
        End If
    Next i
End Function ' IsNumber

' /////////////////////////////////////////////////////////////////////////////
' Split and join strings
' https://www.qb64.org/forum/index.php?topic=1073.0

'Combine all elements of in$() into a single string with delimiter$ separating the elements.

Function join$ (in$(), delimiter$)
    Dim result$
    Dim i As Long
    result$ = in$(LBound(in$))
    For i = LBound(in$) + 1 To UBound(in$)
        result$ = result$ + delimiter$ + in$(i)
    Next i
    join$ = result$
End Function ' join$

' /////////////////////////////////////////////////////////////////////////////
' ABS was returning strange values with type LONG
' so I created this which does not.

Function LongABS& (lngValue As Long)
    If Sgn(lngValue) = -1 Then
        LongABS& = 0 - lngValue
    Else
        LongABS& = lngValue
    End If
End Function ' LongABS&

' /////////////////////////////////////////////////////////////////////////////
' Writes sText to a debug file in the EXE folder.
' Debug file is named the same thing as the program EXE name with ".txt" at the end.
' For example the program "C:\QB64\MyProgram.BAS" running as
' "C:\QB64\MyProgram.EXE" would have an output file "C:\QB64\MyProgram.EXE.txt".
' If the file doesn't exist, it is created, otherwise it is appended to.

Sub DebugPrintFile (sText As String)
    Dim sFileName As String
    Dim sError As String
    Dim sOut As String

    sFileName = m_ProgramPath$ + m_ProgramName$ + ".txt"
    sError = ""
    If _FileExists(sFileName) = FALSE Then
        sOut = ""
        sOut = sOut + "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" + Chr$(13) + Chr$(10)
        sOut = sOut + "PROGRAM : " + m_ProgramName$ + Chr$(13) + Chr$(10)
        sOut = sOut + "RUN DATE: " + CurrentDateTime$ + Chr$(13) + Chr$(10)
        sOut = sOut + "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" + Chr$(13) + Chr$(10)
        sError = PrintFile$(sFileName, sOut, FALSE)
    End If
    If Len(sError) = 0 Then
        sError = PrintFile$(sFileName, sText, TRUE)
    End If
    If Len(sError) <> 0 Then
        Print CurrentDateTime$ + " DebugPrintFile FAILED: " + sError
    End If
End Sub ' DebugPrintFile

' /////////////////////////////////////////////////////////////////////////////

Function IntPadRight$ (iValue As Integer, iWidth As Integer)
    IntPadRight$ = Left$(_Trim$(Str$(iValue)) + String$(iWidth, " "), iWidth)
End Function ' IntPadRight$

' /////////////////////////////////////////////////////////////////////////////
' Returns blank if successful else returns error message.

Function PrintFile$ (sFileName As String, sText As String, bAppend As Integer)
    'x = 1: y = 2: z$ = "Three"

    Dim sError As String: sError = ""

    If Len(sError) = 0 Then
        If (bAppend = TRUE) Then
            If _FileExists(sFileName) Then
                Open sFileName For Append As #1 ' opens an existing file for appending
            Else
                sError = "Error in PrintFile$ : File not found. Cannot append."
            End If
        Else
            Open sFileName For Output As #1 ' opens and clears an existing file or creates new empty file
        End If
    End If
    If Len(sError) = 0 Then
        ' WRITE places text in quotes in the file
        'WRITE #1, x, y, z$
        'WRITE #1, sText

        ' PRINT does not put text inside quotes
        Print #1, sText

        Close #1

        'PRINT "File created with data. Press a key!"
        'K$ = INPUT$(1) 'press a key

        'OPEN sFileName FOR INPUT AS #2 ' opens a file to read it
        'INPUT #2, a, b, c$
        'CLOSE #2

        'PRINT a, b, c$
        'WRITE a, b, c$
    End If

    PrintFile$ = sError
End Function ' PrintFile$

' /////////////////////////////////////////////////////////////////////////////
' Does a _PrintString at the specified row+column.

' iRow and iCol are 0-based.

Sub PrintString (iRow As Integer, iCol As Integer, MyString As String)
    Dim iX As Integer
    Dim iY As Integer
    iX = _FontWidth * iCol
    iY = _FontHeight * iRow ' (iRow + 1)
    _PrintString (iX, iY), MyString
End Sub ' PrintString

' /////////////////////////////////////////////////////////////////////////////
' Does a _PrintString at the specified row+column.

' iRow and iCol are 1-based.

Sub PrintString1 (iRow As Integer, iCol As Integer, MyString As String)
    Dim iX As Integer
    Dim iY As Integer
    iX = _FontWidth * (iCol - 1)
    iY = _FontHeight * (iRow - 1)
    _PrintString (iX, iY), MyString
End Sub ' PrintString1

' /////////////////////////////////////////////////////////////////////////////
' Generate random value between Min and Max.
Function RandomNumber% (Min%, Max%)
    Dim NumSpread%

    ' SET RANDOM SEED
    'Randomize ' Initialize random-number generator.
    Randomize Timer

    ' GET RANDOM # Min%-Max%
    'RandomNumber = Int((Max * Rnd) + Min) ' generate number

    NumSpread% = (Max% - Min%) + 1

    RandomNumber% = Int(Rnd * NumSpread%) + Min% ' GET RANDOM # BETWEEN Max% AND Min%

End Function ' RandomNumber%

' /////////////////////////////////////////////////////////////////////////////

Sub RandomNumberTest
    Dim iCols As Integer: iCols = 10
    Dim iRows As Integer: iRows = 20
    Dim iLoop As Integer
    Dim sError As String
    Dim sFileName As String
    Dim sText As String
    Dim bAppend As Integer
    Dim iMin As Integer
    Dim iMax As Integer
    Dim iNum As Integer
    Dim iErrorCount As Integer
    Dim sInput$

    sFileName = "c:\temp\maze_test_1.txt"
    sText = "Count" + Chr$(9) + "Min" + Chr$(9) + "Max" + Chr$(9) + "Random"
    bAppend = FALSE
    sError = PrintFile$(sFileName, sText, bAppend)
    If Len(sError) = 0 Then
        bAppend = TRUE
        iErrorCount = 0

        iMin = 0
        iMax = iCols - 1
        For iLoop = 1 To 100
            iNum = RandomNumber%(iMin, iMax)
            sText = Str$(iLoop) + Chr$(9) + Str$(iMin) + Chr$(9) + Str$(iMax) + Chr$(9) + Str$(iNum)
            sError = PrintFile$(sFileName, sText, bAppend)
            If Len(sError) > 0 Then
                iErrorCount = iErrorCount + 1
                Print Str$(iLoop) + ". ERROR"
                Print "    " + "iMin=" + Str$(iMin)
                Print "    " + "iMax=" + Str$(iMax)
                Print "    " + "iNum=" + Str$(iNum)
                Print "    " + "Could not write to file " + Chr$(34) + sFileName + Chr$(34) + "."
                Print "    " + sError
            End If
        Next iLoop

        iMin = 0
        iMax = iRows - 1
        For iLoop = 1 To 100
            iNum = RandomNumber%(iMin, iMax)
            sText = Str$(iLoop) + Chr$(9) + Str$(iMin) + Chr$(9) + Str$(iMax) + Chr$(9) + Str$(iNum)
            sError = PrintFile$(sFileName, sText, bAppend)
            If Len(sError) > 0 Then
                iErrorCount = iErrorCount + 1
                Print Str$(iLoop) + ". ERROR"
                Print "    " + "iMin=" + Str$(iMin)
                Print "    " + "iMax=" + Str$(iMax)
                Print "    " + "iNum=" + Str$(iNum)
                Print "    " + "Could not write to file " + Chr$(34) + sFileName + Chr$(34) + "."
                Print "    " + sError
            End If
        Next iLoop

        Print "Finished generating numbers. Errors: " + Str$(iErrorCount)
    Else
        Print "Error creating file " + Chr$(34) + sFileName + Chr$(34) + "."
        Print sError
    End If

    Input "Press <ENTER> to continue", sInput$
End Sub ' RandomNumberTest

' /////////////////////////////////////////////////////////////////////////////
' FROM: String Manipulation
' found at abandoned, outdated and now likely malicious qb64 dot net website
' http://www.qb64.[net]/forum/index_topic_5964-0/
'
'SUMMARY:
'   Purpose:  A library of custom functions that transform strings.
'   Author:   Dustinian Camburides (dustinian@gmail.com)
'   Platform: QB64 (www.qb64.org)
'   Revision: 1.6
'   Updated:  5/28/2012

'SUMMARY:
'[Replace$] replaces all instances of the [Find] sub-string with the [Add] sub-string within the [Text] string.
'INPUT:
'Text: The input string; the text that's being manipulated.
'Find: The specified sub-string; the string sought within the [Text] string.
'Add: The sub-string that's being added to the [Text] string.

Function Replace$ (Text1 As String, Find1 As String, Add1 As String)
    ' VARIABLES:
    Dim Text2 As String
    Dim Find2 As String
    Dim Add2 As String
    Dim lngLocation As Long ' The address of the [Find] substring within the [Text] string.
    Dim strBefore As String ' The characters before the string to be replaced.
    Dim strAfter As String ' The characters after the string to be replaced.

    ' INITIALIZE:
    ' MAKE COPIESSO THE ORIGINAL IS NOT MODIFIED (LIKE ByVal IN VBA)
    Text2 = Text1
    Find2 = Find1
    Add2 = Add1

    lngLocation = InStr(1, Text2, Find2)

    ' PROCESSING:
    ' While [Find2] appears in [Text2]...
    While lngLocation
        ' Extract all Text2 before the [Find2] substring:
        strBefore = Left$(Text2, lngLocation - 1)

        ' Extract all text after the [Find2] substring:
        strAfter = Right$(Text2, ((Len(Text2) - (lngLocation + Len(Find2) - 1))))

        ' Return the substring:
        Text2 = strBefore + Add2 + strAfter

        ' Locate the next instance of [Find2]:
        lngLocation = InStr(1, Text2, Find2)

        ' Next instance of [Find2]...
    Wend

    ' OUTPUT:
    Replace$ = Text2
End Function ' Replace$

' /////////////////////////////////////////////////////////////////////////////

Sub ReplaceTest
    Dim in$

    Print "-------------------------------------------------------------------------------"
    Print "ReplaceTest"
    Print

    Print "Original value"
    in$ = "Thiz iz a teZt."
    Print "in$ = " + Chr$(34) + in$ + Chr$(34)
    Print

    Print "Replacing lowercase " + Chr$(34) + "z" + Chr$(34) + " with " + Chr$(34) + "s" + Chr$(34) + "..."
    in$ = Replace$(in$, "z", "s")
    Print "in$ = " + Chr$(34) + in$ + Chr$(34)
    Print

    Print "Replacing uppercase " + Chr$(34) + "Z" + Chr$(34) + " with " + Chr$(34) + "s" + Chr$(34) + "..."
    in$ = Replace$(in$, "Z", "s")
    Print "in$ = " + Chr$(34) + in$ + Chr$(34)
    Print

    Print "ReplaceTest finished."
End Sub ' ReplaceTest

' /////////////////////////////////////////////////////////////////////////////
' https://www.qb64.org/forum/index.php?topic=3605.0
' Quote from: SMcNeill on Today at 03:53:48 PM
'
' Sometimes, you guys make things entirely too  complicated.
' There ya go!  Three functions to either round naturally,
' always round down, or always round up, to whatever number of digits you desire.
' EDIT:  Modified to add another option to round scientific,
' since you had it's description included in your example.

Function Round## (num##, digits%)
    Round## = Int(num## * 10 ^ digits% + .5) / 10 ^ digits%
End Function

Function RoundUp## (num##, digits%)
    RoundUp## = _Ceil(num## * 10 ^ digits%) / 10 ^ digits%
End Function

Function RoundDown## (num##, digits%)
    RoundDown## = Int(num## * 10 ^ digits%) / 10 ^ digits%
End Function

Function Round_Scientific## (num##, digits%)
    Round_Scientific## = _Round(num## * 10 ^ digits%) / 10 ^ digits%
End Function

Function RoundUpDouble# (num#, digits%)
    RoundUpDouble# = _Ceil(num# * 10 ^ digits%) / 10 ^ digits%
End Function

Function RoundUpSingle! (num!, digits%)
    RoundUpSingle! = _Ceil(num! * 10 ^ digits%) / 10 ^ digits%
End Function

' /////////////////////////////////////////////////////////////////////////////
' fantastically inefficient way to set a bit

' example use: arrMaze(iX, iY) = SetBit256%(arrMaze(iX, iY), cS, FALSE)

' See also: GetBit256%, SetBit256%

' newint=SetBit256%(oldint, int containing the bits we want to set, value to set them to)
Function SetBit256% (iNum1 As Integer, iBit1 As Integer, bVal1 As Integer)
    Dim sNum As String
    Dim sBit As String
    Dim sVal As String
    Dim iLoop As Integer
    Dim strResult As String
    Dim iResult As Integer
    Dim iNum As Integer: iNum = iNum1
    Dim iBit As Integer: iBit = iBit1
    Dim bVal As Integer: bVal = bVal1

    If iNum < 256 And iBit <= 128 Then
        sNum = GetBinary$(iNum)
        sBit = GetBinary$(iBit)
        If bVal = TRUE Then
            sVal = "1"
        Else
            sVal = "0"
        End If
        strResult = ""
        For iLoop = 1 To 8
            If Mid$(sBit, iLoop, 1) = "1" Then
                strResult = strResult + sVal
            Else
                strResult = strResult + Mid$(sNum, iLoop, 1)
            End If
        Next iLoop
        iResult = GetIntegerFromBinary%(strResult)
    Else
        iResult = iNum
    End If

    SetBit256% = iResult
End Function ' SetBit256%

' /////////////////////////////////////////////////////////////////////////////
' Scientific notation - QB64 Wiki
' https://www.qb64.org/wiki/Scientific_notation

' Example: A string function that displays extremely small or large exponential decimal values.

Function SngToStr$ (n!)
    value$ = UCase$(LTrim$(Str$(n!)))
    Xpos% = InStr(value$, "D") + InStr(value$, "E") 'only D or E can be present
    If Xpos% Then
        expo% = Val(Mid$(value$, Xpos% + 1))
        If Val(value$) < 0 Then
            sign$ = "-": valu$ = Mid$(value$, 2, Xpos% - 2)
        Else valu$ = Mid$(value$, 1, Xpos% - 1)
        End If
        dot% = InStr(valu$, "."): L% = Len(valu$)
        If expo% > 0 Then add$ = String$(expo% - (L% - dot%), "0")
        If expo% < 0 Then min$ = String$(Abs(expo%) - (dot% - 1), "0"): DP$ = "."
        For n = 1 To L%
            If Mid$(valu$, n, 1) <> "." Then num$ = num$ + Mid$(valu$, n, 1)
        Next
    Else SngToStr$ = value$: Exit Function
    End If
    SngToStr$ = _Trim$(sign$ + DP$ + min$ + num$ + add$)
End Function ' SngToStr$

' /////////////////////////////////////////////////////////////////////////////
' Split and join strings
' https://www.qb64.org/forum/index.php?topic=1073.0
'
' FROM luke, QB64 Developer
' Date: February 15, 2019, 04:11:07 AM »
'
' Given a string of words separated by spaces (or any other character),
' splits it into an array of the words. I've no doubt many people have
' written a version of this over the years and no doubt there's a million
' ways to do it, but I thought I'd put mine here so we have at least one
' version. There's also a join function that does the opposite
' array -> single string.
'
' Code is hopefully reasonably self explanatory with comments and a little demo.
' Note, this is akin to Python/JavaScript split/join, PHP explode/implode.

'Split in$ into pieces, chopping at every occurrence of delimiter$. Multiple consecutive occurrences
'of delimiter$ are treated as a single instance. The chopped pieces are stored in result$().
'
'delimiter$ must be one character long.
'result$() must have been REDIMmed previously.

' Modified to handle multi-character delimiters

Sub split (in$, delimiter$, result$())
    Dim start As Integer
    Dim finish As Integer
    Dim iDelimLen As Integer
    ReDim result$(-1)

    iDelimLen = Len(delimiter$)

    start = 1
    Do
        'While Mid$(in$, start, 1) = delimiter$
        While Mid$(in$, start, iDelimLen) = delimiter$
            'start = start + 1
            start = start + iDelimLen
            If start > Len(in$) Then
                Exit Sub
            End If
        Wend
        finish = InStr(start, in$, delimiter$)
        If finish = 0 Then
            finish = Len(in$) + 1
        End If

        ReDim _Preserve result$(0 To UBound(result$) + 1)

        result$(UBound(result$)) = Mid$(in$, start, finish - start)
        start = finish + 1
    Loop While start <= Len(in$)
End Sub ' split

' /////////////////////////////////////////////////////////////////////////////

Sub SplitTest
    Dim in$
    Dim delim$
    ReDim arrTest$(0)
    Dim iLoop%

    delim$ = Chr$(10)
    in$ = "this" + delim$ + "is" + delim$ + "a" + delim$ + "test"
    Print "in$ = " + Chr$(34) + in$ + Chr$(34)
    Print "delim$ = " + Chr$(34) + delim$ + Chr$(34)
    split in$, delim$, arrTest$()

    For iLoop% = LBound(arrTest$) To UBound(arrTest$)
        Print "arrTest$(" + LTrim$(RTrim$(Str$(iLoop%))) + ") = " + Chr$(34) + arrTest$(iLoop%) + Chr$(34)
    Next iLoop%
    Print
    Print "Split test finished."
End Sub ' SplitTest

' /////////////////////////////////////////////////////////////////////////////

Sub SplitAndReplaceTest
    Dim in$
    Dim out$
    Dim iLoop%
    ReDim arrTest$(0)

    Print "-------------------------------------------------------------------------------"
    Print "SplitAndReplaceTest"
    Print

    Print "Original value"
    in$ = "This line 1 " + Chr$(13) + Chr$(10) + "and line 2" + Chr$(10) + "and line 3 " + Chr$(13) + "finally THE END."
    out$ = in$
    out$ = Replace$(out$, Chr$(13), "\r")
    out$ = Replace$(out$, Chr$(10), "\n")
    out$ = Replace$(out$, Chr$(9), "\t")
    Print "in$ = " + Chr$(34) + out$ + Chr$(34)
    Print

    Print "Fixing linebreaks..."
    in$ = Replace$(in$, Chr$(13) + Chr$(10), Chr$(13))
    in$ = Replace$(in$, Chr$(10), Chr$(13))
    out$ = in$
    out$ = Replace$(out$, Chr$(13), "\r")
    out$ = Replace$(out$, Chr$(10), "\n")
    out$ = Replace$(out$, Chr$(9), "\t")
    Print "in$ = " + Chr$(34) + out$ + Chr$(34)
    Print

    Print "Splitting up..."
    split in$, Chr$(13), arrTest$()

    For iLoop% = LBound(arrTest$) To UBound(arrTest$)
        out$ = arrTest$(iLoop%)
        out$ = Replace$(out$, Chr$(13), "\r")
        out$ = Replace$(out$, Chr$(10), "\n")
        out$ = Replace$(out$, Chr$(9), "\t")
        Print "arrTest$(" + cstr$(iLoop%) + ") = " + Chr$(34) + out$ + Chr$(34)
    Next iLoop%
    Print

    Print "SplitAndReplaceTest finished."
End Sub ' SplitAndReplaceTest

' /////////////////////////////////////////////////////////////////////////////

Function StrPadLeft$ (sValue As String, iWidth As Integer)
    StrPadLeft$ = Right$(String$(iWidth, " ") + sValue, iWidth)
End Function ' StrPadLeft$

' /////////////////////////////////////////////////////////////////////////////

Function StrJustifyRight$ (sValue As String, iWidth As Integer)
    StrJustifyRight$ = Right$(String$(iWidth, " ") + sValue, iWidth)
End Function ' StrJustifyRight$

' /////////////////////////////////////////////////////////////////////////////

Function StrPadRight$ (sValue As String, iWidth As Integer)
    StrPadRight$ = Left$(sValue + String$(iWidth, " "), iWidth)
End Function ' StrPadRight$

' /////////////////////////////////////////////////////////////////////////////

Function StrJustifyLeft$ (sValue As String, iWidth As Integer)
    StrJustifyLeft$ = Left$(sValue + String$(iWidth, " "), iWidth)
End Function ' StrJustifyLeft$

' /////////////////////////////////////////////////////////////////////////////
' div: int1% = num1% \ den1%
' mod: rem1% = num1% MOD den1%

Function StrJustifyCenter$ (sValue As String, iWidth As Integer)
    Dim iLen0 As Integer
    Dim iLen1 As Integer
    Dim iLen2 As Integer
    Dim iExtra As Integer

    iLen0 = Len(sValue)
    If iWidth = iLen0 Then
        ' no extra space: return unchanged
        StrJustifyCenter$ = sValue
    ElseIf iWidth > iLen0 Then
        If IsOdd%(iWidth) Then
            iWidth = iWidth - 1
        End If

        ' center
        iExtra = iWidth - iLen0
        iLen1 = iExtra \ 2
        iLen2 = iLen1 + (iExtra Mod 2)
        StrJustifyCenter$ = String$(iLen1, " ") + sValue + String$(iLen2, " ")
    Else
        ' string is too long: truncate
        StrJustifyCenter$ = Left$(sValue, iWidth)
    End If
End Function ' StrJustifyCenter$

' /////////////////////////////////////////////////////////////////////////////

Function TrueFalse$ (myValue)
    If myValue = TRUE Then
        TrueFalse$ = "TRUE"
    Else
        TrueFalse$ = "FALSE"
    End If
End Function ' TrueFalse$

' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' END GENERAL PURPOSE ROUTINES
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' BEGIN KEYBOARD CODE FUNCTIONS
' NOTE: ALL CODES ARE FOR _BUTTON, EXCEPT:
' cF10 (_KEYDOWN)
' cAltLeft (_KEYHIT)
' cAltRight (_KEYHIT)
' cPrintScreen (_KEYHIT) <- may slow down pc?
' cPauseBreak (_KEYHIT) <- may not work?
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Function KeyCode_Escape% ()
    KeyCode_Escape% = 2
End Function

Function KeyCode_F1% ()
    KeyCode_F1% = 60
End Function

Function KeyCode_F2% ()
    KeyCode_F2% = 61
End Function

Function KeyCode_F3% ()
    KeyCode_F3% = 62
End Function

Function KeyCode_F4% ()
    KeyCode_F4% = 63
End Function

Function KeyCode_F5% ()
    KeyCode_F5% = 64
End Function

Function KeyCode_F6% ()
    KeyCode_F6% = 65
End Function

Function KeyCode_F7% ()
    KeyCode_F7% = 66
End Function

Function KeyCode_F8% ()
    KeyCode_F8% = 67
End Function

Function KeyCode_F9% ()
    KeyCode_F9% = 68
End Function

'_KEYDOWN CODE, NOT _BUTTON CODE
Function KeyCode_F10% ()
    KeyCode_F10% = 17408
End Function

Function KeyCode_F11% ()
    KeyCode_F11% = 88
End Function

Function KeyCode_F12% ()
    KeyCode_F12% = 89
End Function

'_KEYHIT CODE, NOT _BUTTON CODE
Function KeyCode_PrintScreen% ()
    KeyCode_PrintScreen% = -44
End Function

Function KeyCode_ScrollLock% ()
    KeyCode_ScrollLock% = 71
End Function

'_KEYHIT CODE, NOT _BUTTON CODE
Function KeyCode_PauseBreak% ()
    KeyCode_PauseBreak% = 31053
End Function

Function KeyCode_Tilde% ()
    KeyCode_Tilde% = 42
End Function

Function KeyCode_1% ()
    KeyCode_1% = 3
End Function

Function KeyCode_2% ()
    KeyCode_2% = 4
End Function

Function KeyCode_3% ()
    KeyCode_3% = 5
End Function

Function KeyCode_4% ()
    KeyCode_4% = 6
End Function

Function KeyCode_5% ()
    KeyCode_5% = 7
End Function

Function KeyCode_6% ()
    KeyCode_6% = 8
End Function

Function KeyCode_7% ()
    KeyCode_7% = 9
End Function

Function KeyCode_8% ()
    KeyCode_8% = 10
End Function

Function KeyCode_9% ()
    KeyCode_9% = 11
End Function

Function KeyCode_0% ()
    KeyCode_0% = 12
End Function

Function KeyCode_Minus% ()
    KeyCode_Minus% = 13
End Function

Function KeyCode_Equal% ()
    KeyCode_Equal% = 14
End Function

Function KeyCode_BkSp% ()
    KeyCode_BkSp% = 15
End Function

Function KeyCode_Ins% ()
    KeyCode_Ins% = 339
End Function

Function KeyCode_Home% ()
    KeyCode_Home% = 328
End Function

Function KeyCode_PgUp% ()
    KeyCode_PgUp% = 330
End Function

Function KeyCode_Del% ()
    KeyCode_Del% = 340
End Function

Function KeyCode_End% ()
    KeyCode_End% = 336
End Function

Function KeyCode_PgDn% ()
    KeyCode_PgDn% = 338
End Function

Function KeyCode_NumLock% ()
    KeyCode_NumLock% = 326
End Function

Function KeyCode_KeypadSlash% ()
    KeyCode_KeypadSlash% = 310
End Function

Function KeyCode_KeypadMultiply% ()
    KeyCode_KeypadMultiply% = 56
End Function

Function KeyCode_KeypadMinus% ()
    KeyCode_KeypadMinus% = 75
End Function

Function KeyCode_Keypad7Home% ()
    KeyCode_Keypad7Home% = 72
End Function

Function KeyCode_Keypad8Up% ()
    KeyCode_Keypad8Up% = 73
End Function

Function KeyCode_Keypad9PgUp% ()
    KeyCode_Keypad9PgUp% = 74
End Function

Function KeyCode_KeypadPlus% ()
    KeyCode_KeypadPlus% = 79
End Function

Function KeyCode_Keypad4Left% ()
    KeyCode_Keypad4Left% = 76
End Function

Function KeyCode_Keypad5% ()
    KeyCode_Keypad5% = 77
End Function

Function KeyCode_Keypad6Right% ()
    KeyCode_Keypad6Right% = 78
End Function

Function KeyCode_Keypad1End% ()
    KeyCode_Keypad1End% = 80
End Function

Function KeyCode_Keypad2Down% ()
    KeyCode_Keypad2Down% = 81
End Function

Function KeyCode_Keypad3PgDn% ()
    KeyCode_Keypad3PgDn% = 82
End Function

Function KeyCode_KeypadEnter% ()
    KeyCode_KeypadEnter% = 285
End Function

Function KeyCode_Keypad0Ins% ()
    KeyCode_Keypad0Ins% = 83
End Function

Function KeyCode_KeypadPeriodDel% ()
    KeyCode_KeypadPeriodDel% = 84
End Function

Function KeyCode_Tab% ()
    KeyCode_Tab% = 16
End Function

Function KeyCode_Q% ()
    KeyCode_Q% = 17
End Function

Function KeyCode_W% ()
    KeyCode_W% = 18
End Function

Function KeyCode_E% ()
    KeyCode_E% = 19
End Function

Function KeyCode_R% ()
    KeyCode_R% = 20
End Function

Function KeyCode_T% ()
    KeyCode_T% = 21
End Function

Function KeyCode_Y% ()
    KeyCode_Y% = 22
End Function

Function KeyCode_U% ()
    KeyCode_U% = 23
End Function

Function KeyCode_I% ()
    KeyCode_I% = 24
End Function

Function KeyCode_O% ()
    KeyCode_O% = 25
End Function

Function KeyCode_P% ()
    KeyCode_P% = 26
End Function

Function KeyCode_BracketLeft% ()
    KeyCode_BracketLeft% = 27
End Function

Function KeyCode_BracketRight% ()
    KeyCode_BracketRight% = 28
End Function

Function KeyCode_Backslash% ()
    KeyCode_Backslash% = 44
End Function

Function KeyCode_CapsLock% ()
    KeyCode_CapsLock% = 59
End Function

Function KeyCode_A% ()
    KeyCode_A% = 31
End Function

Function KeyCode_S% ()
    KeyCode_S% = 32
End Function

Function KeyCode_D% ()
    KeyCode_D% = 33
End Function

Function KeyCode_F% ()
    KeyCode_F% = 34
End Function

Function KeyCode_G% ()
    KeyCode_G% = 35
End Function

Function KeyCode_H% ()
    KeyCode_H% = 36
End Function

Function KeyCode_J% ()
    KeyCode_J% = 37
End Function

Function KeyCode_K% ()
    KeyCode_K% = 38
End Function

Function KeyCode_L% ()
    KeyCode_L% = 39
End Function

Function KeyCode_Semicolon% ()
    KeyCode_Semicolon% = 40
End Function

Function KeyCode_Apostrophe% ()
    KeyCode_Apostrophe% = 41
End Function

Function KeyCode_Enter% ()
    KeyCode_Enter% = 29
End Function

Function KeyCode_ShiftLeft% ()
    KeyCode_ShiftLeft% = 43
End Function

Function KeyCode_Z% ()
    KeyCode_Z% = 45
End Function

Function KeyCode_X% ()
    KeyCode_X% = 46
End Function

Function KeyCode_C% ()
    KeyCode_C% = 47
End Function

Function KeyCode_V% ()
    KeyCode_V% = 48
End Function

Function KeyCode_B% ()
    KeyCode_B% = 49
End Function

Function KeyCode_N% ()
    KeyCode_N% = 50
End Function

Function KeyCode_M% ()
    KeyCode_M% = 51
End Function

Function KeyCode_Comma% ()
    KeyCode_Comma% = 52
End Function

Function KeyCode_Period% ()
    KeyCode_Period% = 53
End Function

Function KeyCode_Slash% ()
    KeyCode_Slash% = 54
End Function

Function KeyCode_ShiftRight% ()
    KeyCode_ShiftRight% = 55
End Function

Function KeyCode_Up% ()
    KeyCode_Up% = 329
End Function

Function KeyCode_Left% ()
    KeyCode_Left% = 332
End Function

Function KeyCode_Down% ()
    KeyCode_Down% = 337
End Function

Function KeyCode_Right% ()
    KeyCode_Right% = 334
End Function

Function KeyCode_CtrlLeft% ()
    KeyCode_CtrlLeft% = 30
End Function

Function KeyCode_WinLeft% ()
    KeyCode_WinLeft% = 348
End Function

' _KEYHIT CODE NOT _BUTTON CODE
Function KeyCode_AltLeft% ()
    KeyCode_AltLeft% = -30764
End Function

Function KeyCode_Spacebar% ()
    KeyCode_Spacebar% = 58
End Function

' _KEYHIT CODE NOT _BUTTON CODE
Function KeyCode_AltRight% ()
    KeyCode_AltRight% = -30765
End Function

Function KeyCode_WinRight% ()
    KeyCode_WinRight% = 349
End Function

Function KeyCode_Menu% ()
    KeyCode_Menu% = 350
End Function

Function KeyCode_CtrlRight% ()
    KeyCode_CtrlRight% = 286
End Function

' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' END KEYBOARD CODE FUNCTIONS
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++







' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' BEGIN COLOR FUNCTIONS
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' NOTE: these are mostly negative numbers
'       and have to be forced to positive
'       when stored in the dictionary
'       (only cEmpty should be negative)

Function cRed~& ()
    cRed = _RGB32(255, 0, 0)
End Function

Function cOrangeRed~& ()
    cOrangeRed = _RGB32(255, 69, 0)
End Function ' cOrangeRed~&

Function cDarkOrange~& ()
    cDarkOrange = _RGB32(255, 140, 0)
End Function ' cDarkOrange~&

Function cOrange~& ()
    cOrange = _RGB32(255, 165, 0)
End Function ' cOrange~&

Function cGold~& ()
    cGold = _RGB32(255, 215, 0)
End Function ' cGold~&

Function cYellow~& ()
    cYellow = _RGB32(255, 255, 0)
End Function ' cYellow~&

' LONG-HAIRED FRIENDS OF JESUS OR NOT,
' THIS IS NOT YELLOW ENOUGH (TOO CLOSE TO LIME)
' TO USE FOR OUR COMPLEX RAINBOW SEQUENCE:
Function cChartreuse~& ()
    cChartreuse = _RGB32(127, 255, 0)
End Function ' cChartreuse~&

' WE SUBSTITUTE THIS CSS3 COLOR FOR INBETWEEN LIME AND YELLOW:
Function cOliveDrab1~& ()
    cOliveDrab1 = _RGB32(192, 255, 62)
End Function ' cOliveDrab1~&

Function cLime~& ()
    cLime = _RGB32(0, 255, 0)
End Function ' cLime~&

Function cMediumSpringGreen~& ()
    cMediumSpringGreen = _RGB32(0, 250, 154)
End Function ' cMediumSpringGreen~&

Function cCyan~& ()
    cCyan = _RGB32(0, 255, 255)
End Function ' cCyan~&

Function cDeepSkyBlue~& ()
    cDeepSkyBlue = _RGB32(0, 191, 255)
End Function ' cDeepSkyBlue~&

Function cDodgerBlue~& ()
    cDodgerBlue = _RGB32(30, 144, 255)
End Function ' cDodgerBlue~&

Function cSeaBlue~& ()
    cSeaBlue = _RGB32(0, 64, 255)
End Function ' cSeaBlue~&

Function cBlue~& ()
    cBlue = _RGB32(0, 0, 255)
End Function ' cBlue~&

Function cBluePurple~& ()
    cBluePurple = _RGB32(64, 0, 255)
End Function ' cBluePurple~&

Function cDeepPurple~& ()
    cDeepPurple = _RGB32(96, 0, 255)
End Function ' cDeepPurple~&

Function cPurple~& ()
    cPurple = _RGB32(128, 0, 255)
End Function ' cPurple~&

Function cPurpleRed~& ()
    cPurpleRed = _RGB32(128, 0, 192)
End Function ' cPurpleRed~&

Function cDarkRed~& ()
    cDarkRed = _RGB32(160, 0, 64)
End Function ' cDarkRed~&

Function cBrickRed~& ()
    cBrickRed = _RGB32(192, 0, 32)
End Function ' cBrickRed~&

Function cDarkGreen~& ()
    cDarkGreen = _RGB32(0, 100, 0)
End Function ' cDarkGreen~&

Function cGreen~& ()
    cGreen = _RGB32(0, 128, 0)
End Function ' cGreen~&

Function cOliveDrab~& ()
    cOliveDrab = _RGB32(107, 142, 35)
End Function ' cOliveDrab~&

Function cLightPink~& ()
    cLightPink = _RGB32(255, 182, 193)
End Function ' cLightPink~&

Function cHotPink~& ()
    cHotPink = _RGB32(255, 105, 180)
End Function ' cHotPink~&

Function cDeepPink~& ()
    cDeepPink = _RGB32(255, 20, 147)
End Function ' cDeepPink~&

Function cMagenta~& ()
    cMagenta = _RGB32(255, 0, 255)
End Function ' cMagenta~&

Function cBlack~& ()
    cBlack = _RGB32(0, 0, 0)
End Function ' cBlack~&

Function cDimGray~& ()
    cDimGray = _RGB32(105, 105, 105)
End Function ' cDimGray~&

Function cGray~& ()
    cGray = _RGB32(128, 128, 128)
End Function ' cGray~&

Function cDarkGray~& ()
    cDarkGray = _RGB32(169, 169, 169)
End Function ' cDarkGray~&

Function cSilver~& ()
    cSilver = _RGB32(192, 192, 192)
End Function ' cSilver~&

Function cLightGray~& ()
    cLightGray = _RGB32(211, 211, 211)
End Function ' cLightGray~&

Function cGainsboro~& ()
    cGainsboro = _RGB32(220, 220, 220)
End Function ' cGainsboro~&

Function cWhiteSmoke~& ()
    cWhiteSmoke = _RGB32(245, 245, 245)
End Function ' cWhiteSmoke~&

Function cWhite~& ()
    cWhite = _RGB32(255, 255, 255)
    'cWhite = _RGB32(254, 254, 254)
End Function ' cWhite~&

Function cDarkBrown~& ()
    cDarkBrown = _RGB32(128, 64, 0)
End Function ' cDarkBrown~&

Function cLightBrown~& ()
    cLightBrown = _RGB32(196, 96, 0)
End Function ' cLightBrown~&

Function cKhaki~& ()
    cKhaki = _RGB32(240, 230, 140)
End Function ' cKhaki~&

Function cEmpty~& ()
    'cEmpty~& = -1
    cEmpty = _RGB32(0, 0, 0, 0)
End Function ' cEmpty~&

' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' END COLOR FUNCTIONS
' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' #END
' ################################################################################################################################################################


