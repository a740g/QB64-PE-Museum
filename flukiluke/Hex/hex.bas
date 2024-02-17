'Made available under the MIT license, see LICENSE for details

'Set this to -1 to enable compile in console functionality, 0 to exclude it (only available on Linux)
$Let CONSOLE = -1

DefLng A-Z
Dim Shared CursorX, CursorY, Blinkrate, CursorActive, CursorShape, CONSOLE

ChDir _StartDir$

$If CONSOLE AND LINUX Then
        $CONSOLE
        $SCREENHIDE
    $If 32BIT Then
            DECLARE LIBRARY "i386-linux-gnu/ncurses"
            END DECLARE
    $Else
            DECLARE LIBRARY "x86_64-linux-gnu/ncurses"
            END DECLARE
    $End If
        DECLARE LIBRARY "./stdiox"
        SUB initx
        SUB printx (s$)
        SUB printstringx (BYVAL x&, BYVAL y&, s$)
        FUNCTION acs& (BYVAL cp437byte&)
        SUB displayx
        SUB locatex (BYVAL row&, BYVAL col&)
        SUB colorx (BYVAL fg&, BYVAL bg&)
        FUNCTION maxcol&
        FUNCTION maxrow&
        FUNCTION screenx& (BYVAL row&, BYVAL col&)
        FUNCTION csrlinx&
        FUNCTION posx&
        FUNCTION inkeyx (extended&)
        SUB showcursor
        SUB hidecursor
        SUB clsx ()
        SUB finishx
        END DECLARE
        _DEST _CONSOLE
$End If

'Parse command line
If _CommandCount > 0 Then
    $If CONSOLE AND LINUX Then
            IF _COMMANDCOUNT > 2 THEN PRINT COMMAND$(0); ": [--console] [<file>]": SYSTEM
    $Else
        If _CommandCount > 1 Then Print Command$(0); ": [<file>]": System
    $End If

    For i = 1 To _CommandCount
        If Command$(i) = "--console" Or Command$(i) = "-c" Then
            CONSOLE = -1
        Else
            If inputfile$ <> "" Then Print "Bad command line": System
            inputfile$ = Command$(i)
        End If
    Next i

End If

If CONSOLE Then
    $If CONSOLE AND LINUX Then
            initx
    $End If
Else
    _ScreenShow
    _Dest 0
End If

lines = 22
Dim contents As _MEM
Dim newmem As _MEM 'Used for temporary allocations (for resizing)
CursorShape = 1
Blinkrate = 500
CursorActive = -1

GoSub redraw
GoTo initial_load

Do
    Do
        k$ = inkeyy$
        _Limit 30
    Loop While k$ = ""
    Select Case k$
        Case "0" To "9", "A" To "F", "a" To "f"
            changed = -1
            If editmode = -1 Then
                GoSub textinsert
            Else
                If cursornybble = 0 Then
                    _MemPut contents, contents.OFFSET + cursoroff, Val("&H" + k$) * &H10 + (_MemGet(contents, contents.OFFSET + cursoroff, _Unsigned _Byte) And &HF) As _UNSIGNED _BYTE
                    cursornybble = 1
                Else
                    _MemPut contents, contents.OFFSET + cursoroff, Val("&H" + k$) + (_MemGet(contents, contents.OFFSET + cursoroff, _Unsigned _Byte) And &HF0) As _UNSIGNED _BYTE
                    cursornybble = 0
                    If cursoroff < contents.SIZE - 1 Then
                        cursoroff = cursoroff + 1
                        If cursoroff Mod 16 = 0 Then
                            If scrline = lines Then foffset = foffset + 16 Else scrline = scrline + 1
                        End If
                    End If
                End If
                GoSub redraw
            End If
        Case Chr$(32) To Chr$(126)
            If editmode = -1 Then GoSub textinsert: changed = -1
        Case Chr$(0) + Chr$(73) 'PgUp
            cursornybble = 0
            If foffset < 16 * lines Then
                foffset = 0
                cursoroff = 0
                scrline = 1
            Else
                foffset = foffset - 16 * lines
                cursoroff = cursoroff - 16 * lines
            End If
            GoSub redraw
        Case Chr$(0) + Chr$(81) 'PgDn
            If foffset + 16 * lines < contents.SIZE - 1 And foffset + 16 * lines * 2 > contents.SIZE - 1 Then
                foffset = foffset + 16 * lines
                If cursoroff + 16 * lines > contents.SIZE - 1 Then cursoroff = o2l~&&(contents.SIZE) - 1: scrline = (cursoroff - foffset) \ 16 + 1 Else cursoroff = cursoroff + 16 * lines
                cursornybble = 0
            ElseIf foffset + 16 * lines * 2 < contents.SIZE - 1 Then
                foffset = foffset + 16 * lines
                cursoroff = cursoroff + 16 * lines
                cursornybble = 0
            End If
            GoSub redraw
        Case Chr$(0) + Chr$(77) 'right
            If cursoroff < contents.SIZE - 1 Then
                cursornybble = 0
                cursoroff = cursoroff + 1
                If cursoroff Mod 16 = 0 Then
                    If scrline = lines Then foffset = foffset + 16 Else scrline = scrline + 1
                End If
                GoSub redraw
            End If
        Case Chr$(0) + Chr$(72) 'up
            If cursoroff >= 16 Then
                cursornybble = 0
                cursoroff = cursoroff - 16
                If scrline = 1 Then foffset = foffset - 16 Else scrline = scrline - 1
                GoSub redraw
            End If
        Case Chr$(0) + Chr$(75) 'left
            If cursoroff >= 1 Then
                cursornybble = 0
                If cursoroff Mod 16 = 0 Then
                    If scrline = 1 Then foffset = foffset - 16 Else scrline = scrline - 1
                End If
                cursoroff = cursoroff - 1
                GoSub redraw
            End If
        Case Chr$(0) + Chr$(80) 'down
            If cursoroff + 16 < contents.SIZE Then
                cursornybble = 0
                cursoroff = cursoroff + 16
                If scrline = lines Then foffset = foffset + 16 Else scrline = scrline + 1
                GoSub redraw
            End If
        Case Chr$(0) + Chr$(83) 'delete
            If cursoroff <= contents.SIZE - 1 Then
                count = 1
                GoSub deletebytes
                changed = -1
                If cursoroff >= contents.SIZE And cursoroff <> 0 Then cursoroff = o2l~&&(contents.SIZE) - 1
                GoSub redraw
            End If
        Case Chr$(0) + Chr$(59) 'F1 Calculator
        Case Chr$(0) + Chr$(60) 'F2 Search
            'IF editmode = 0 THEN
            '    hexneedle$ = prompt_input$("FIND HEX [" + recenthexsearch$ + "]: ")
            '    IF needle$ = CHR$(27) THEN needle$ = recenthexsearch$ ELSE recenthexsearch$ = needle$
            '    for
        Case Chr$(0) + Chr$(61) 'F3 Search&Replace
        Case Chr$(0) + Chr$(62) 'F4 Insert
            count = Val(prompt_input$("INSERT Num bytes (&H/&O/&B for non-decimal): "))
            newmem = _MemNew(contents.SIZE + count)
            If newmem.SIZE <> contents.SIZE + count Then
                clear_bottom
                locatey 25, 1
                printy "Allocation failed, data unchanged. Press any key."
                displayy
                Do
                    _Limit 20
                    k$ = inkeyy$
                Loop While k$ = ""
            Else
                _MemCopy contents, contents.OFFSET, cursoroff To newmem, newmem.OFFSET
                _MemFill newmem, newmem.OFFSET + cursoroff, count, 0 As _BYTE
                _MemCopy contents, contents.OFFSET + cursoroff, contents.SIZE - cursoroff To newmem, newmem.OFFSET + cursoroff + count
                _MemFree contents
                contents = newmem
                changed = -1
            End If
            GoSub redraw
        Case Chr$(0) + Chr$(63) 'F5 Append
            count = Val(prompt_input$("APPEND Num bytes (&H/&O/&B for non-decimal): "))
            newmem = _MemNew(contents.SIZE + count)
            If newmem.SIZE <> contents.SIZE + count Then
                clear_bottom
                locatey 25, 1
                printy "Allocation failed, data unchanged. Press any key."
                displayy
                Do
                    _Limit 20
                    k$ = inkeyy$
                Loop While k$ = ""
            Else
                _MemCopy contents, contents.OFFSET, contents.SIZE To newmem, newmem.OFFSET
                _MemFill newmem, newmem.OFFSET + contents.SIZE, count, 0 As _BYTE
                _MemFree contents
                contents = newmem
                changed = -1
            End If
            GoSub redraw
        Case Chr$(0) + Chr$(64) 'F6 Delete
            count = Val(prompt_input$("DELETE Num bytes (&H/&O/&B for non-decimal): "))
            If count > contents.SIZE Then
                clear_bottom
                locatey 25, 1
                printy "Count bigger than file, data unchanged. Press any key."
                displayy
                Do
                    _Limit 20
                    k$ = inkeyy$
                Loop While k$ = ""
            Else
                GoSub deletebytes
                changed = -1
            End If
            If cursoroff >= contents.SIZE And cursoroff <> 0 Then cursoroff = o2l~&&(contents.SIZE) - 1
            GoSub redraw
        Case Chr$(0) + Chr$(65) 'F7 Goto
            p = Val(prompt_input$("GOTO Offset (&H/&O/&B for non-decimal): "))
            If p > contents.SIZE - 1 Then p = o2l~&&(contents.SIZE) - 1
            cursoroff = p
            foffset = (cursoroff \ 16) * 16
            scrline = 1
            GoSub redraw
        Case Chr$(0) + Chr$(66) 'F8 Write
            If changed Then
                write_file inputfile$, contents
                changed = 0
                GoSub redraw
            End If
        Case Chr$(0) + Chr$(67) 'F9 Open
            initial_load:
            If changed Then GoSub promptsave
            changed = 0
            If inputfile$ = "" Then inputfile$ = prompt_input$("File name: ")
            If _MemExists(contents) Then _MemFree contents
            read_file inputfile$, contents
            changed = 0 'becomes 0 when saved and -1 when changed
            foffset = 0
            cursoroff = 0
            cursornybble = 0 'becomes 1 when on the second nybble
            editmode = 0 '0 = hex, -1 = text
            scrline = 1
            GoSub redraw
        Case Chr$(0) + Chr$(68) 'F10
        Case Chr$(0) + Chr$(133) 'F11
        Case Chr$(0) + Chr$(134) 'F12


        Case Chr$(27) 'escape
            If changed Then GoSub promptsave
            $If CONSOLE AND LINUX Then
                    IF CONSOLE THEN finishx
            $End If
            System
        Case Chr$(9) 'tab
            cursornybble = 0
            editmode = Not editmode
            GoSub redraw
    End Select
Loop

deletebytes:
newmem = _MemNew(contents.SIZE - count)
_MemCopy contents, contents.OFFSET, cursoroff To newmem, newmem.OFFSET
_MemCopy contents, contents.OFFSET + cursoroff + count, contents.SIZE - cursoroff - count To newmem, newmem.OFFSET + cursoroff
_MemFree contents
contents = newmem
Return

promptsave:
clear_bottom
locatey 25, 1
printy "Current file changed. Save (y/n)? "
displayy
Do
    k$ = UCase$(InKey$)
Loop While k$ <> "Y" And k$ <> "N"
If k$ = "Y" Then write_file inputfile$, contents
GoSub redraw
Return

textinsert:
_MemPut contents, contents.OFFSET + cursoroff, Asc(k$) As _UNSIGNED _BYTE
If cursoroff < contents.SIZE - 1 Then
    cursoroff = cursoroff + 1
    If cursoroff Mod 16 = 0 Then
        If scrline = lines Then foffset = foffset + 16 Else scrline = scrline + 1
    End If
    GoSub redraw
End If
GoSub redraw
Return

redraw:
clsy
printy "[" + hexpad$(cursoroff, 8) + "/" + hexpad$(o2l~&&(contents.SIZE), 8) + "]"
If changed Then printy "!"
printy " " + inputfile$
locatey csrliny + 1, 1
For lstart = foffset To foffset + 16 * lines - 1 Step 16
    If lstart + 16 > contents.SIZE Then count = o2l~&&(contents.SIZE) - lstart Else count = 16
    If count > 0 Then
        bytes$ = Space$(count)
        _MemGet contents, contents.OFFSET + lstart, bytes$
        printy hexpad$(lstart, 8) + "|"
        For byte = 1 To count
            If byte = 9 Then printy "  "
            locatey csrliny, posy + 1
            If lstart + byte - 1 = cursoroff And editmode = 0 Then
                CursorY = csrliny
                CursorX = posy + cursornybble
            End If
            printy hexpadb$(Asc(bytes$, byte), 2)
        Next byte
        locatey csrliny, 60
        printy " | "
        For byte = 1 To count
            b = Asc(bytes$, byte)
            If lstart + byte - 1 = cursoroff And editmode = -1 Then CursorY = csrliny: CursorX = posy
            If b >= 32 And b <= 126 Then printy Chr$(b) Else printy "." 'CHR$(249)
        Next byte
        locatey csrliny + 1, 1
    Else
        printy hexpad$(lstart, 8) + "|"
        locatey csrliny + 1, 1
    End If
Next lstart
locatey 25, 1
printy "F4=INSERT  F5=APPEND  F6=DELETE  F7=GOTO  F8=SAVE  F9=OPEN"
$If CONSOLE AND LINUX Then
        IF CONSOLE THEN locatex CursorY, CursorX
$End If
displayy
Return

Sub clear_bottom
    locatey 25, 1
    printy Space$(79)
    displayy
End Sub

Function hexpad$ (n, p)
    n$ = Hex$(n)
    hexpad$ = Space$(p - Len(n$)) + n$
End Function

Function hexpadb$ (n, p)
    n$ = Hex$(n)
    If Len(n$) Mod 2 Then n$ = "0" + n$
    hexpadb$ = Space$(p - Len(n$)) + n$
End Function

Sub read_file (f$, m As _MEM)
    Open f$ For Binary As #1
    l = LOF(1)
    temp$ = Space$(l)
    Get #1, 1, temp$
    Close #1
    m = _MemNew(l)
    _MemPut m, m.OFFSET, temp$
End Sub

Sub write_file (f$, m As _MEM)
    If _FileExists(f$) Then Kill f$
    Open f$ For Binary As #1
    temp$ = Space$(o2l~&&(m.SIZE))
    _MemGet m, m.OFFSET, temp$
    Put #1, , temp$
End Sub

$If CONSOLE AND LINUX Then
        SUB printy (s$)
        IF CONSOLE THEN printx s$ + CHR$(0) ELSE PRINT s$;
        END SUB

        SUB locatey (r, c)
        IF CONSOLE THEN locatex r, c ELSE LOCATE r, c
        END SUB

        FUNCTION csrliny
        IF CONSOLE THEN csrliny = csrlinx ELSE csrliny = CSRLIN
        END FUNCTION

        FUNCTION posy
        IF CONSOLE THEN posy = posx ELSE posy = POS(0)
        END FUNCTION

        SUB colory (f, b)
        IF CONSOLE THEN colorx f, b ELSE COLOR f, b
        END SUB


        SUB clsy
        IF CONSOLE THEN clsx ELSE CLS
        END SUB

        SUB displayy
        IF CONSOLE THEN displayx ELSE _DISPLAY
        END SUB

        FUNCTION inkeyy$
        IF CONSOLE THEN
        b1 = inkeyx(extended)
        s$ = CHR$(b1)
        IF extended <> 0 THEN s$ = s$ + CHR$(extended)
        ELSE
        s$ = INKEY$
        END IF
        inkeyy$ = s$
        END FUNCTION
$Else
    Sub printy (s$)
        Print s$;
    End Sub

    Sub locatey (r, c)
        Locate r, c
    End Sub

    Function csrliny
        csrliny = CsrLin
    End Function

    Function posy
        posy = Pos(0)
    End Function

    Sub colory (f, b)
        Color f, b
    End Sub


    Sub clsy
        Cls
    End Sub

    Sub displayy
        _Display
    End Sub

    Function inkeyy$
        inkeyy$ = InKey$
    End Function
$End If


Sub _GL
    Static blinker!, showing
    If Timer - blinker! >= Blinkrate / 1000 Then showing = Not showing: blinker! = Timer
    If showing And CursorActive Then
        cy = CursorY
        cx = CursorX
        fh = _FontHeight
        fw = _FontWidth

        'For SCREEN 0:
        h = _Height
        w = _Width

        'For all other screen modes:
        'h = _HEIGHT / fh
        'w = _WIDTH / fw

        _glMatrixMode _GL_PROJECTION
        _glLoadIdentity
        _glOrtho 0, w * fw, 0, h * fh, 0, -1
        x = (cx - 1) * fw
        Select Case CursorShape
            Case 0
                'Left vertical bar
                _glBegin _GL_LINES
                _glVertex2i x + 1, (h - cy) * fh
                _glVertex2i x + 1, (h - cy + 1) * fh
            Case 1
                'Underline
                _glBegin _GL_LINES
                _glVertex2i x, (h - cy) * fh
                _glVertex2i x + fw, (h - cy) * fh
            Case 2
                'Box
                _glBegin _GL_QUADS
                _glVertex2i x, (h - cy) * fh
                _glVertex2i x, (h - cy + 1) * fh
                _glVertex2i x + fw, (h - cy + 1) * fh
                _glVertex2i x + fw, (h - cy) * fh
        End Select
        _glEnd
    End If
End Sub

'Only works on little-endian machines (and big-endian ones where len(x~&&) = len(x%&))
Function o2l~&& (o~%&)
    Static m As _MEM
    If _MemExists(m) = 0 Then m = _MemNew(Len(dummy~&&))
    _MemPut m, m.OFFSET, o~%&
    o2l~&& = _MemGet(m, m.OFFSET, _Unsigned _Integer64)
End Function

'This routine based on one thanks to Steve!
Function prompt_input$ (prompt$)
    clear_bottom
    x = Len(prompt$) + 1
    Do
        _Limit 30
        l = 79 - x
        p = 1 - l + Len(temp$)
        If p < 1 - l Then p = 1 - l
        locatey 25, 1
        printy prompt$ + t$ + " "
        displayy
        k$ = inkeyy$
        Select Case k$
            Case Chr$(8): temp$ = Left$(temp$, Len(temp$) - 1)
            Case Chr$(13): prompt_input$ = temp$: Exit Function
            Case Chr$(32) To Chr$(126): temp$ = temp$ + k$
        End Select
        t$ = Mid$(temp$, p, l)
    Loop
End Function

