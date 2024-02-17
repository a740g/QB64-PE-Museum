Option _Explicit

On Error GoTo BadExit

$Console
_Console Off

Do Until _ScreenExists: Loop
_Title "qXed"

$ExeIcon:'./qXedlogo.ico'
$Resize:On

Const KeyboardBksp = 8
Const KeyboardTab = 9
Const KeyboardEnter = 13
Const KeyboardEsc = 27
Const KeyboardF1 = 15104
Const KeyboardF2 = 15360
Const KeyboardF3 = 15616
Const KeyboardF4 = 15872
Const KeyboardF5 = 16128
Const KeyboardF6 = 16384
Const KeyboardF7 = 16640
Const KeyboardF8 = 16896
Const KeyboardF9 = 17152
Const KeyboardF10 = 17408
Const KeyboardF11 = 34048
Const KeyboardF12 = 34304
Const KeyboardHome = 18176
Const KeyboardUpArrow = 18432
Const KeyboardPgUp = 18688
Const KeyboardLeftArrow = 19200
Const KeyboardRightArrow = 19712
Const KeyboardEnd = 20224
Const KeyboardDnArrow = 20480
Const KeyboardPgDn = 20736
Const KeyboardIns = 20992
Const KeyboardDel = 21248
Const KeyboardRightShift = 100304
Const KeyboardLeftShift = 100304
Const KeyboardRightCtrl = 100305
Const KeyboardLeftCtrl = 100306
Const KeyboardRightAlt = 100307
Const KeyboardLeftAlt = 100308

Dim Shared LF As String
Dim Shared CR As String
Dim Shared Spacebar As String
LF = Chr$(10)
CR = Chr$(13)
Spacebar = Chr$(32)

Dim Shared BackgroundColor
Dim Shared Cursor1Back
Dim Shared Cursor2Back
Dim Shared CursorBlinkFace
Dim Shared CursorMixedBack
Dim Shared CursorStdFace
Dim Shared ScrollbarBack
Dim Shared ScrollbarBase
Dim Shared ScrollbarFace
Dim Shared StatusBarColor
Dim Shared TextBackColor
Dim Shared TextFaceColor
Dim Shared TextHighBack
Dim Shared TextHighFace
Dim Shared TitleColor
Dim Shared WireColor

Dim Shared ColorTheme
ColorTheme = 1

Dim Shared TheERROR As String
Dim Shared Debug$

_AcceptFileDrop

_Delay .25
Dim Shared scrHand As Long
Dim Shared oldHand As Long
scrHand = _NewImage(1 * 80, 1 * 24, 0) ' 8, 16, 0
Screen scrHand
Call SetPalette

' Define fundamental structures.
Type Vector
    X As Integer
    Y As Integer
End Type

Type Cell
    Identity As Long
    Pointer As Long
    Lagger As Long
    Content As String * 1
End Type

Dim Shared ChainLimit As Long
Dim Shared BOC As Long ' Beginning of chain.
Dim Shared EOC As Long ' End of chain.
ChainLimit = 1 * 10 ^ 6
BOC = 0
EOC = ChainLimit

' Define text window properties.
Dim Shared WindowHeight As Integer
Dim Shared WindowWidth As Integer
Dim Shared VisibleLines As Integer
Dim Shared TopIndent As Integer
Dim Shared LeftIndent As Integer
Dim Shared TextHeight As Integer
Dim Shared TextWidth As Integer
Dim Shared HScroll As Integer
Dim Shared TextWrapping As Integer
Dim Shared TextFormatting As Integer
Dim Shared InsertKey As Integer

' Set window properties.
Call InitTextWindow

' Set display state.
HScroll = 1
TextWrapping = 1
TextFormatting = -1
InsertKey = -1

' Initiate text inside window.
Dim Shared StartIndex
Dim Shared LineAsMapped(TextHeight + 1) As String
Dim Shared Cursor1 As Vector
Dim Shared Cursor2 As Vector
Dim Shared ID1
Dim Shared ID2

' Auxiliary 2D text grid.
Dim Shared GOLSwitch
Dim Shared AuxGrid(TextWidth, TextHeight, 2) As String
GOLSwitch = -1

' Create memory space for string.
Dim Shared TheChain(ChainLimit) As Cell

' File I/O.
Dim Shared WorkingFileName As String

Dim Shared Highlight As String
Highlight = "qXed"

' Load text file into memory if applicable, use example string if not.
Call InitTextChain(Command$)

' Prime main loop.
Call MapText
Call CalibrateCursor(ID1)
Call CalibrateCursor(ID2)
Call PrintEverything

' Main loop.
Do

    If (StateChange% = 1) Then
        Call PrintEverything
    End If

    If (GOLSwitch = 1) Then
        Call ConvertToGrid
        Call GOL
        Call ConvertFromGrid
        Call MapText
        Call PrintEverything
    End If

    Do While (_Resize)
        If ((_ResizeWidth / 8 > 20) And (_ResizeHeight / 16 > 6)) Then
            oldHand = scrHand
            scrHand = _NewImage((_ResizeWidth / 8), (_ResizeHeight / 16), 0)
            Screen scrHand
            _FreeImage oldHand
            Call SetPalette
            Call InitTextWindow
            ReDim LineAsMapped(TextHeight)
            ReDim AuxGrid(TextWidth, TextHeight, 2)
            Call MapText
            Call CalibrateCursor(ID1)
            Call CalibrateCursor(ID2)
            Call PrintEverything
        End If
    Loop

    If (_TotalDroppedFiles > 0) Then
        If (_FileExists(_DroppedFile$(1))) Then
            Call InitTextChain(_DroppedFile$(1))
            Call MapText
            Call CalibrateCursor(ID1)
            Call CalibrateCursor(ID2)
            Call PrintEverything
        End If
        _FinishDrop
    End If

    _Display
    _Limit 240
Loop

System

BadExit:
_Console On
_Echo (TheERROR)
Sleep
System

Sub StringPrint (RequestCode As String, x As Integer, y As Integer, txt As String)
    TheERROR = RequestCode + Str$(x) + Str$(y) + " " + txt
    '_PrintString (x * 8, y * 16), txt
    Locate y, x: Print txt;
End Sub

Sub InitTextWindow
    WindowWidth = _Width / 1 - 0 * 1 '8, 1
    WindowHeight = _Height / 1 - 0 * 1 '16, 1
    TopIndent = 1 '0
    LeftIndent = 1 '0
    TextHeight = WindowHeight - (1 + TopIndent)
    TextWidth = WindowWidth - (1 + LeftIndent)
End Sub

Sub SetPalette
    BackgroundColor = 0
    Cursor1Back = 3
    Cursor2Back = 7
    CursorBlinkFace = 16 + 6
    CursorMixedBack = 7
    CursorStdFace = 0
    ScrollbarBack = 7
    ScrollbarBase = 8
    ScrollbarFace = 1
    StatusBarColor = 3
    TextBackColor = 1
    TextFaceColor = 11
    TextHighBack = 2
    TextHighFace = 1
    TitleColor = 3
    WireColor = 8
    If (ColorTheme = 1) Then
        _PaletteColor 0, _RGB32(0, 0, 39)
        _PaletteColor 1, _RGB32(0, 49, 78)
        _PaletteColor 3, _RGB32(69, 118, 147)
        _PaletteColor 4, _RGB32(216, 98, 78)
        _PaletteColor 6, _RGB32(255, 167, 0) '''
        _PaletteColor 7, _RGB32(98, 98, 98)
        _PaletteColor 8, _RGB32(48, 48, 48) '''
        _PaletteColor 9, _RGB32(0, 88, 108)
        _PaletteColor 10, _RGB32(85, 206, 85)
        _PaletteColor 11, _RGB32(0, 170, 170) '''
        _PaletteColor 14, _RGB32(255, 167, 0)
        _PaletteColor 15, _RGB32(216, 216, 216)
    Else
        oldHand = scrHand
        scrHand = _NewImage(_Width, _Height, 0)
        Screen scrHand
        _FreeImage oldHand
    End If
End Sub

Sub InitTextChain (c As String)
    Dim i As Integer
    Dim j As Integer
    Dim k As Long
    Dim q As String
    Dim r As String
    If (c <> "") Then
        q = ""
        Open c For Input As #1
        Do While Not EOF(1)
            Line Input #1, r
            q = q + r + CR
        Loop
        Close #1
        i = InStr(c, ".")
        If (i <> 0) Then
            j = i - 1
        Else
            j = Len(c)
        End If
        WorkingFileName = Left$(c, j) + "-" + LTrim$(RTrim$(Str$(Int(Timer)))) + ".txt"
    Else
        WorkingFileName = "qXed_file" + "-" + Date$ + "-" + LTrim$(RTrim$(Str$(Int(Timer)))) + ".txt"
        q = ""
        'q = q + "Working file is:" + CR + Chr$(9) + WorkingFileName + CR + CR + "Press F6 to save." + CR
        q = q + "Welcome to qXed" + CR
        q = q + "... a hackable text editor" + CR
        q = q + "... now boosted with Pipecom!" + CR
        q = q + CR
        q = q + "Use Pipecom by starting a line with a bracket '>'." + CR
        q = q + "Press Ctrl+Enter to evaluate that line." + CR
        q = q + CR
        q = q + "For example, place the cursor after 'dir', and press Ctrl+Enter:" + CR
        q = q + "(Or, replace 'dir' with 'ls' for Linux.)" + CR
        q = q + CR
        q = q + ">dir"
        q = q + CR
        q = q + CR
        q = q + "This program has a steeper learning curve than Notepad, so beware." + CR
        q = q + CR
        q = q + "Press F3 to change search term." + CR
        q = q + "Press F10 to toggle high contrast mode." + CR
        q = q + "Press F11 to see break returns and whitespace." + CR
        q = q + "Press F12 to cycle text wrapping modes." + CR
    End If

    ' Create character list.
    For k = 1 To ChainLimit
        TheChain(k).Identity = 0
    Next
    ID2 = Assimilate&(q, BOC, EOC)
    'StartIndex = 1
    ID1 = StartIndex

    GOLSwitch = -1
End Sub

Function Assimilate& (a As String, st As Long, en As Long)
    ' Maps a raw string of text between a set of identities.
    Dim b As String
    Dim c As String
    Dim j As Long
    Dim previousID As Long
    Dim nextID As Long
    Dim n0 As Long

    If ((st = BOC) And (en = EOC)) Then
        previousID = st
        nextID = NextOpenIdentity&(1)
    Else
        previousID = TheChain(st).Lagger
        nextID = NextOpenIdentity&(st)
    End If
    n0 = nextID

    b = a
    Do
        c = Left$(b, 1)
        b = Right$(b, Len(b) - 1)
        Select Case c
            Case Chr$(9)
                c = " "
                b = "   " + b
            Case CR
                If (Left$(b, 1) = LF) Then
                    b = Right$(b, Len(b) - 1)
                End If
            Case LF
                c = CR
        End Select
        j = nextID
        TheChain(j).Identity = j
        TheChain(j).Content = c
        TheChain(j).Lagger = previousID
        If (previousID <> BOC) Then TheChain(previousID).Pointer = j
        If (Len(b) > 0) Then
            previousID = j
            nextID = NextOpenIdentity&(j)
        Else
            If ((st = BOC) And (en = EOC)) Then
                TheChain(j).Pointer = en
                TheChain(en).Lagger = j
            Else
                TheChain(j).Pointer = st
                TheChain(st).Lagger = j
            End If
            Exit Do
        End If
    Loop

    If ((st = BOC) And (en = EOC)) Then
        StartIndex = n0
    End If

    If (st <> EOC) Then
        If (st = StartIndex) Then
            StartIndex = BackBreak&(StartIndex)
        End If
    End If

    Assimilate& = n0
End Function

Function InsertString& (a As String, st As Long)
    InsertString& = Assimilate&(a, st, TheChain(st).Pointer)
End Function

Function NthP& (a As Long, b As Long)
    ' Returns the address that is b jumps ahead of address a.
    Dim i As Long
    Dim j As Long
    Dim k As Long
    i = a
    j = 0
    If (i <> EOC) Then
        k = 0
        Do While (k < b)
            k = k + 1
            j = i
            i = TheChain(j).Pointer
            If (i = EOC) Then Exit Do
        Loop
    End If
    '''
    If (j = 0) Then
        j = StartIndex
        Sound 1000, 1
    End If
    '''
    NthP& = j
End Function

Function NthL& (a As Long, b As Long)
    ' Returns the address that is b jumps behind address a.
    Dim i As Long
    Dim j As Long
    Dim k As Long
    i = a
    k = 0
    Do While (k < b)
        k = k + 1
        j = i
        i = TheChain(j).Lagger
        If (i = BOC) Then Exit Do
    Loop
    NthL& = j
End Function

Function NextOpenIdentity& (a As Long)
    Dim j As Long
    For j = a To ChainLimit
        If (TheChain(j).Identity = 0) Then Exit For
    Next
    If (j > ChainLimit) Then
        Print "Chain limit exceeded."
        Sleep
        System
    End If
    NextOpenIdentity& = j
End Function

Function BackBreak& (a As Long)
    ' Function for scrolling up.
    Dim c As String
    Dim d As String
    Dim j As Long
    Dim k As Long
    Dim lastBreak As Long
    j = a
    lastBreak = 0
    c = ""
    Do
        If (j = BOC) Then Exit Do
        k = TheChain(j).Lagger
        If (k = BOC) Then
            lastBreak = j
            Exit Do
        End If
        j = k
        d = TheChain(j).Content
        c = d + c
        If (TextWrapping = 1) Then
            If ((d = " ") Or (d = CR)) Then
                lastBreak = j
            End If
        End If
        If (TextWrapping <> 2) And (Len(c) = TextWidth) Then Exit Do
        If (d = CR) Then
            Exit Do
        End If
    Loop
    If (lastBreak <> 0) Then j = lastBreak
    BackBreak& = j
End Function

Function BackBreak2& (a As Long)
    Dim c As String
    Dim d As String
    Dim j As Long
    Dim k As Long
    Dim lastBreak As Long
    j = a
    lastBreak = 0
    c = ""
    Do
        If (j = BOC) Then Exit Do
        k = TheChain(j).Lagger
        If (k = BOC) Then
            lastBreak = j
            Exit Do
        End If
        j = k
        d = TheChain(j).Content
        c = d + c
        If (TextWrapping = 1) Then
            If (d = CR) Then
                If (Mid$(c, 2, 1) = ">") Or (Mid$(c, 2, 1) = "]") Then
                    'If ((d = " ") Or (d = CR)) Then
                    lastBreak = TheChain(j).Pointer
                    'lastBreak = j
                End If
            End If
        End If
        If (TextWrapping <> 2) And (Len(c) = TextWidth) Then Exit Do
        If (d = CR) Then
            If (Mid$(c, 2, 1) = ">") Or (Mid$(c, 2, 1) = "]") Then
                'If (d = CR) Then
                Exit Do
            End If
        End If
    Loop
    If (lastBreak <> 0) Then j = lastBreak
    BackBreak2& = j
End Function


Sub InsertBefore (a As Long, b As String)
    ' Inserts a single cell before address a in the chain.
    Dim lg As Long
    Dim j As Long
    j = NextOpenIdentity&(a)
    lg = TheChain(a).Lagger
    TheChain(j).Identity = j
    TheChain(j).Pointer = a
    TheChain(j).Lagger = lg
    TheChain(j).Content = b
    TheChain(a).Lagger = j
    If (lg = BOC) Then
        StartIndex = j
    Else
        TheChain(lg).Pointer = j
    End If
End Sub

Sub InsertCharacter (k As Integer)
    If (InsertKey = -1) Then
        Call InsertBefore(ID1, LTrim$(RTrim$(Chr$(k))))
    Else
        TheChain(ID1).Content = LTrim$(RTrim$(Chr$(k)))
        ID1 = NthP&(ID1, 2)
    End If
    If (TextWrapping = 2) Then
        If (Cursor1.X - LeftIndent = TextWidth) Then
            HScroll = HScroll + 1
        End If
    End If
End Sub

Function InsertAfter& (a As Long, b As String)
    ' Inserts a single cell after address a in the chain.
    Dim j As Long
    Dim p As Long
    j = NextOpenIdentity&(a)
    p = TheChain(a).Pointer
    TheChain(j).Identity = j
    TheChain(j).Pointer = p
    TheChain(j).Lagger = a
    TheChain(j).Content = b
    TheChain(a).Pointer = j
    If (p <> EOC) Then
        TheChain(p).Lagger = j
    End If
    InsertAfter& = j
End Function

Function LinearCount& (a As Long, b As Long)
    LinearCount& = LinearCountProto&(a, b, ChainLimit + 1)
End Function

Function LinearCountProto& (a As Long, b As Long, c As Long)
    ' Returns number of links between two addresses, with exit condition.
    Dim i As Long
    Dim j As Long
    Dim k As Long
    i = a
    k = 0
    Do While (i <> b)
        k = k + 1
        j = i
        i = TheChain(j).Pointer
        If (i = EOC) Then Exit Do
        If (k = c) Then Exit Do
    Loop
    LinearCountProto& = k
End Function

Function Projection$ (a As Long, b As Long)
    ' Returns the linear content for all address between a and b, inclusive.
    Dim TheReturn As String
    Dim j As Long
    Dim k As Long
    Dim c As String
    TheReturn = ""
    If (a = b) Then
        TheReturn = TheChain(a).Content
    Else
        j = a
        Do
            c = TheChain(j).Content
            TheReturn = TheReturn + c
            k = TheChain(j).Pointer
            If (j = b) Then Exit Do
            If (k = EOC) Then Exit Do
            j = k
        Loop
    End If
    Projection$ = TheReturn
End Function

Sub MapText
    Dim c1 As Long
    Dim c2 As Long
    Dim i As Integer
    Dim r As Integer
    Dim m As Integer
    Dim j As Long
    Dim k As Long
    Dim k1 As Long
    Dim k2 As Long
    Dim n As Long
    Dim q As String
    Dim d As String
    Dim c As String
    Dim brsymbol As String
    If (TextFormatting = 1) Then
        brsymbol = "~"
    Else
        brsymbol = " "
    End If
    j = StartIndex
    i = 1
    q = ""
    d = ""
    Do ' Begin with any left-over text from previous iteration.
        q = d
        d = ""
        r = TextWidth - Len(q)

        '''
        If (TextWrapping = 0) Then
            k1 = NthP&(j, r)
            If (TheChain(k1).Pointer = EOC) Then k1 = EOC
        End If
        If (TextWrapping = 1) Then
            k1 = NthP&(j, r)
            If (TheChain(k1).Pointer = EOC) Then k1 = EOC
        End If
        If (TextWrapping = 2) Then
            k1 = EOC
        End If
        '''

        k2 = j
        Do
            If (TheChain(k2).Content = CR) Then Exit Do
            If (TheChain(k2).Pointer = EOC) Then Exit Do
            k2 = TheChain(k2).Pointer
        Loop

        If (TextWrapping <> 2) Then
            c1 = LinearCount&(j, k1)
        Else
            c1 = LinearCountProto&(j, k1, TextWidth * TextHeight)
        End If

        c2 = LinearCount&(j, k2)

        If (c2 = 0) Then ' Line has one character (except in Fluid mode).
            k = k2
            If (TheChain(j).Content = CR) Then
                q = q + brsymbol
            Else
                q = q + TheChain(j).Content
            End If
            j = NthP&(k, 2)

        Else

            If (c1 = c2) Then ' End of line. (Possible end of chain?)
                '''
                If (TextWrapping = 0) Then
                    k = k1
                    If (TheChain(k).Content = CR) Then
                        q = q + Projection$(j, TheChain(k).Lagger) + brsymbol
                    Else
                        q = q + Projection$(j, k)
                    End If
                    j = NthP&(k, 2)
                End If
                If (TextWrapping = 1) Then
                    k = TheChain(k1).Lagger
                    If (TheChain(k).Content = CR) Then
                        q = q + Projection$(j, TheChain(k).Lagger) + brsymbol
                    Else
                        q = q + Projection$(j, k)
                    End If
                    j = NthP&(k, 2)
                End If
                If (TextWrapping = 2) Then
                    k = k1 ' == EOC
                    q = q + Projection$(j, k)
                    j = NthP&(k, 2)
                End If
                '''
            End If
            If (c1 < c2) Then ' Width limit case (not always maximum).
                k = k1
                q = q + Projection$(j, k)
                j = NthP&(k, 2)
            End If
            If (c1 > c2) Then ' Break return somewhere in line (not first).
                k = k2
                n = TheChain(k).Pointer
                ''' Clean this up if compelled.
                If (n <> EOC) Then
                    q = q + Projection$(j, TheChain(k).Lagger) + brsymbol
                    j = n
                Else ' End of chain.
                    If (TheChain(k).Content = CR) Then
                        q = q + Projection$(j, TheChain(k).Lagger) + brsymbol
                    Else
                        q = q + Projection$(j, k)
                    End If
                End If
                '''
            End If
        End If

        If (TextWrapping = 1) Then ' Wrap text at first breaking character from right, send remainder to next line.
            If (Len(q) >= TextWidth) Then
                For m = Len(q) To 1 Step -1
                    c = Mid$(q, m, 1)
                    If ((c = " ") Or (c = "-") Or (c = ".") Or (c = "_") Or (c = brsymbol)) Then
                        q = Left$(q, m)
                        Exit For
                    End If
                    d = c + d
                Next
                If (m = 0) Then ' Text is too long for line and contains no wrapping characters.
                    q = Left$(q, TextWidth)
                    d = ""
                End If
            End If
        End If

        LineAsMapped(i) = q
        i = i + 1

        If (n = EOC) Then
            If (d <> "") Then
                LineAsMapped(i) = d
                i = i + 1
            End If
            Exit Do
        End If
        If (i = TextHeight) Then
            'IF (d <> "") THEN BEEP
            Exit Do
        End If
        If (j = k) Then
            'IF (d <> "") THEN BEEP
            Exit Do
        End If
    Loop
    VisibleLines = i - 1
End Sub

Sub PasteClipboard (a As Long, b As String)
    Dim z As Long
    z = InsertString&(b, a)
End Sub

Sub CalibrateCursor (a As Long)
    ' Place Cursor under ID on rendered line.
    Dim s As Long
    Dim c As Long
    Dim i As Integer
    Dim j As Integer
    Dim k As Integer
    Dim n As Integer
    s = StartIndex
    If ((TextWrapping = 2) And (HScroll > 1)) Then s = NthP&(s, HScroll)
    c = LinearCount&(s, a)
    k = 0
    i = -1
    For j = 1 To VisibleLines
        n = Len(LineAsMapped(j))
        If (k + n < c) Then
            k = k + n
        Else
            i = c - k + 1
            Exit For
        End If
    Next
    If (j < VisibleLines) Then
        If (i >= 1 + Len(LineAsMapped(j))) Then ''' Clean this line up a little.
            i = 1
            j = j + 1
        End If
    End If
    If (a = ID1) Then
        Cursor1.X = LeftIndent + i
        Cursor1.Y = TopIndent + j
    End If
    If (a = ID2) Then
        Cursor2.X = LeftIndent + i
        Cursor2.Y = TopIndent + j
    End If
End Sub

Function FindID% (a As Integer, b As Long)
    ' Find identity under a mapped location.
    Dim relx As Integer
    Dim rely As Integer
    Dim k As Integer
    Dim t As Integer
    relx = a - LeftIndent
    rely = b - TopIndent
    For k = 1 To rely - 1
        t = t + Len(LineAsMapped(k))
    Next
    t = t + relx
    FindID% = t
End Function

Sub ReassignID1
    ID1 = NthP&(StartIndex, FindID%(Cursor1.X, Cursor1.Y) + (HScroll - 1))
End Sub

Sub ReassignID2
    ID2 = NthP&(StartIndex, FindID%(Cursor2.X, Cursor2.Y) + (HScroll - 1))
End Sub

Sub PrintEverything
    Color BackgroundColor, BackgroundColor
    Cls
    Call PrintWires
    Call HorizontalScrollbar
    Call PrintStatusBars(VerticalScrollbar#)
    Call PrintCursorInfo
    Call PrintMainText
    Call PrintCursor2
    Call PrintCursor1
End Sub

Sub PrintWires
    Dim i As Integer
    Color WireColor, BackgroundColor
    Call StringPrint("PrintWires", WindowWidth, WindowHeight - 1, Chr$(217))
    Call StringPrint("PrintWires", LeftIndent, WindowHeight - 1, Chr$(192))
    For i = 1 + TopIndent To WindowHeight - 2
        Call StringPrint("PrintWires", LeftIndent, i, Chr$(179))
    Next
    Call StringPrint("PrintWires", LeftIndent, TopIndent, Chr$(218))
    Call StringPrint("PrintWires", WindowWidth, TopIndent, Chr$(191))
    For i = 1 + LeftIndent To WindowWidth - 1
        Call StringPrint("PrintWires", i, TopIndent, Chr$(196))
    Next
End Sub

Sub HorizontalScrollbar
    Dim i As Integer
    Dim p As Long
    Dim q As Long
    Dim r As Double
    Dim s As Double
    Color ScrollbarBase, BackgroundColor
    For i = (1 + LeftIndent) To (WindowWidth - 1)
        Call StringPrint("HorizontalScrollbar1", i, WindowHeight - 1, Chr$(177))
    Next
    p = LinearCount&(NthP&(StartIndex, FindID%(LeftIndent + 1, Cursor1.Y)), ID1)
    q = Len(LineAsMapped(Cursor1.Y - TopIndent))
    If (q <> 1) Then
        r = p / (q - 1)
        If (r > 1) Then r = 1
        If q = 0 Then r = 0
    Else
        r = 0
    End If
    s = r * (WindowWidth - LeftIndent - 2)
    i = (1 + LeftIndent) + Int(s)
    Color ScrollbarFace, ScrollbarBack
    Call StringPrint("HorizontalScrollbar2", i, WindowHeight - 1, "^")
End Sub

Function VerticalScrollbar#
    Dim i As Integer
    Dim p As Long
    Dim q As Long
    Dim r As Double
    Dim s As Double
    Color ScrollbarBase, BackgroundColor
    For i = (1 + TopIndent) To (WindowHeight - 2)
        Call StringPrint("VerticalScrollbar#", WindowWidth, i, Chr$(177))
    Next
    p = LinearCount&(ID1, NthP&(ID1, ChainLimit + 1))
    q = LinearCount&(NthL&(ID1, ChainLimit + 1), NthP&(ID1, ChainLimit + 1))
    If (q = 0) Then
        r = 1
    Else
        r = Abs(1 - p / q)
    End If
    s = r * (WindowHeight - TopIndent - 3)
    i = (1 + TopIndent) + Int(s)
    Color ScrollbarFace, ScrollbarBack
    Call StringPrint("VerticalScrollbar#", WindowWidth, i, "<")
    VerticalScrollbar# = r
End Function

Sub PrintStatusBars (r As Double)
    Dim c As String
    c = ""
    If (TextFormatting = 1) Then c = "[Fmt] " + c
    Select Case TextWrapping
        Case 0: c = c + "[Square]" + " "
        Case 1: c = c + "[Fluid]" + " "
        Case 2: c = c + "[None]" + " "
    End Select
    c = c + "[" + LTrim$(RTrim$(Str$(Int(100 * r)))) + "%]"
    If (Len(c) >= TextWidth) Then c = Left$(c, TextWidth)
    Color StatusBarColor, BackgroundColor
    Call StringPrint("PrintStatusBars", WindowWidth - Len(c), TopIndent, c)
    c = ""
    If (InsertKey = 1) Then c = "[Ins]" + c
    If (Len(c) >= TextWidth) Then c = Left$(c, TextWidth)
    Color StatusBarColor, BackgroundColor
    Call StringPrint("PrintStatusBars", WindowWidth - Len(c), WindowHeight, c)
End Sub

Sub PrintCursorInfo
    Dim c As String
    Dim d As String
    Dim c0 As String
    Dim d0 As String
    c = TheChain(ID1).Content
    d = TheChain(ID2).Content
    c0 = c
    d0 = d
    If (c = LF) Then c = "@" ' Should never happen.
    If (d = LF) Then d = "@" ' Should never happen.
    If (c = CR) Then c = "~"
    If (d = CR) Then d = "~"
    If (c = Spacebar) Then c = "_"
    If (d = Spacebar) Then d = "_"
    c = "(" + LTrim$(RTrim$(Str$(Cursor1.X - LeftIndent))) + " " + LTrim$(RTrim$(Str$(Cursor1.Y - TopIndent))) + " " + c + Str$(ID1) + ")"
    Color CursorStdFace, Cursor1Back
    Call StringPrint("PrintCursorInfo", 1 + LeftIndent, WindowHeight, c)
    'IF (LinearCount&(StartIndex, ID2) > LinearCount&(StartIndex, ID1)) THEN
    d = "(" + LTrim$(RTrim$(Str$(Cursor2.X - LeftIndent))) + " " + LTrim$(RTrim$(Str$(Cursor2.Y - TopIndent))) + " " + d + Str$(ID2) + ")"
    Color CursorStdFace, Cursor2Back
    Call StringPrint("PrintCursorInfo", 2 + LeftIndent + Len(c), WindowHeight, d)
    'END IF
    Color TitleColor, BackgroundColor
    Call StringPrint("PrintCursorInfo", 1 + LeftIndent, TopIndent, "[qXed]" + Debug$)
End Sub

Sub PrintMainText
    Dim i As Integer
    Dim j As Integer
    Dim k As Integer
    Dim k0 As Integer
    Dim k00 As Integer
    Dim c As String
    Dim d As String
    For i = 1 To VisibleLines
        c = LineAsMapped(i)
        If (TextFormatting = 1) Then
            For j = 1 To TextWidth - Len(c)
                c = c + "_"
            Next
        End If
        d = Mid$(c, HScroll, TextWidth)

        If (Highlight <> "") Then
            k = InStr(d, Highlight)
        End If
        If (k > 0) Then
            k0 = 0
            Do While (k > 0)
                k00 = k0 + k - 1
                Color TextFaceColor, TextBackColor
                Call StringPrint("PrintMainText", k0 + LeftIndent + 1, TopIndent + i, Left$(d, k - 1))
                Color TextHighFace, TextHighBack
                Call StringPrint("PrintMainText", k0 + k - 1 + LeftIndent + 1, TopIndent + i, Mid$(d, k, Len(Highlight)))
                d = Right$(d, Len(d) - k - Len(Highlight) + 1)
                k0 = k0 + k - 1 + Len(Highlight)
                k = InStr(d, Highlight)
            Loop
            Color TextFaceColor, TextBackColor
            Call StringPrint("PrintMainText", k00 + Len(Highlight) + LeftIndent + 1, TopIndent + i, d)
        Else
            Color TextFaceColor, TextBackColor
            Call StringPrint("PrintMainText", LeftIndent + 1, TopIndent + i, d)
        End If
    Next
End Sub

Sub PrintCursor1
    Dim c As String
    If ((Cursor1.X > 0 And Cursor1.X < WindowWidth) And ((Cursor1.Y > 0) And (Cursor1.Y < WindowHeight))) Then
        c = TheChain(ID1).Content
        If (c = " ") Then c = "_"
        If (c = CR) Then c = "~"
        If ((Cursor1.X = Cursor2.X) And (Cursor1.Y = Cursor2.Y)) Then
            Color CursorBlinkFace, CursorMixedBack
            Call StringPrint("PrintCursor1", Cursor1.X, Cursor1.Y, c)
        Else
            Color CursorBlinkFace, Cursor1Back
            Call StringPrint("PrintCursor1", Cursor1.X, Cursor1.Y, c)
        End If
    End If
End Sub

Sub PrintCursor2
    Dim c As String
    Dim p1 As Long
    Dim p2 As Long
    Dim pe As Long
    If ((Cursor2.X > 0 And Cursor2.X < WindowWidth) And ((Cursor2.Y > 0) And (Cursor2.Y < WindowHeight))) Then
        p1 = LinearCount&(StartIndex, ID1)
        p2 = LinearCount&(StartIndex, ID2)
        pe = LinearCount&(StartIndex, EOC)
        If p2 < pe Then 'IF ((p2 > p1) AND (p2 < pe)) THEN
            c = TheChain(ID2).Content
            If (c = " ") Then c = "_"
            If (c = CR) Then c = "~"
            Color CursorStdFace, Cursor2Back
            Call StringPrint("PrintCursor2", Cursor2.X, Cursor2.Y, c)
        End If
    End If
End Sub

Function StateChange%
    Dim TheReturn As Integer
    Dim MH As Integer
    Dim MW As Integer
    Dim MT As Integer
    Dim MH1 As Integer
    Dim MH2 As Integer
    Dim MH3 As Integer
    Dim KH As Long
    MH = 0
    MW = 0
    MT = 0

    KH = _KeyHit

    Do While _MouseInput
        MH1 = _MouseButton(1)
        MH2 = _MouseButton(2)
        MH3 = _MouseButton(3)
        MW = _MouseWheel
        If (MW <> 0) Then MT = MW
    Loop
    MW = MT

    If (MH1 = -1) Then MH = MouseButton1%
    If (MH2 = -1) Then MH = MouseButton2%
    If (MH3 = -1) Then MH = MouseButton3%
    If (MW = -1) Then MH = MouseWheelUp%
    If (MW = 1) Then MH = MouseWheelDown%

    If (KH = KeyboardBksp) Then Call KeyBksp
    If (KH = KeyboardTab) Then Call KeyTab
    If (KH = KeyboardEsc) Then Call KeyEsc
    If (KH = KeyboardEnter) Or ((KH >= 32) And (KH <= 126)) Then Call KeyEnterAlphaNumer(KH)
    If (KH = KeyboardF1) Then Call KeyF1
    If (KH = KeyboardF2) Then Call KeyF2
    If (KH = KeyboardF3) Then Call KeyF3
    If (KH = KeyboardF4) Then Call KeyF4
    If (KH = KeyboardF5) Then Call KeyF5
    If (KH = KeyboardF6) Then Call KeyF6
    'If (KH = KeyboardF7) Then Call KeyF7
    If (KH = KeyboardF10) Then Call KeyF10
    If (KH = KeyboardF11) Then Call KeyF11
    If (KH = KeyboardF12) Then Call KeyF12
    If (KH = KeyboardHome) Then Call KeyHome
    If (KH = KeyboardUpArrow) Then Call KeyUpArrow
    If (KH = KeyboardPgUp) Then Call KeyPgUp
    If (KH = KeyboardLeftArrow) Then Call KeyLeftArrow
    If (KH = KeyboardRightArrow) Then Call KeyRightArrow
    If (KH = KeyboardEnd) Then Call KeyEnd
    If (KH = KeyboardDnArrow) Then Call KeyDwnArrow
    If (KH = KeyboardPgDn) Then Call KeyPgDn
    If (KH = KeyboardIns) Then Call KeyIns
    If (KH = KeyboardDel) Then Call KeyDel

    ' Exit sequence
    TheReturn = 0
    If ((MH <> 0) Or (KH > 0)) Then
        TheReturn = 1
        Call MapText
        Call CalibrateCursor(ID1)
        Call CalibrateCursor(ID2)

        ' Cursor sync and autoscrolling.
        Do While (Cursor1.Y > TopIndent + TextHeight - 1)
            StartIndex = NthP&(StartIndex, Len(LineAsMapped(1)) + 1)
            Call MapText
            Call CalibrateCursor(ID1)
            Call CalibrateCursor(ID2)
        Loop
        If (TextWrapping = 2) Then '''
            Do While (Cursor1.X > LeftIndent + TextWidth - 0)
                HScroll = HScroll + 1
                Cursor1.X = Cursor1.X - 1
            Loop
        End If

    End If
    MH = 0
    KH = 0
    _KeyClear
    StateChange% = TheReturn
End Function

Function MouseButton1%
    Dim As Double mx, my
    mx = _MouseX ' Int(_MouseX / 8)
    my = _MouseY ' Int(_MouseY / 16)
    If ((mx > LeftIndent) And (mx < TextWidth + LeftIndent + 1) And (my > TopIndent) And (my < TopIndent + TextHeight)) Then
        Call MouseButton1Cursor
    End If
    If (mx = WindowWidth) Then
        Call MouseButton1VScroll
    End If
    If (my = WindowHeight - 1) Then
        Call MouseButton1Hscroll
    End If
    MouseButton1% = 1
End Function

Sub MouseButton1VScroll
    ' This sub does things wrong.
    Dim i As Long
    Dim j As Long
    Dim k As Long
    Dim t As Long
    Dim r As Double
    Dim f As Double
    Dim As Double mx, my
    mx = _MouseX ' Int(_MouseX / 8)
    my = _MouseY ' Int(_MouseY / 16)
    If ((my > TopIndent) And (my < (TopIndent + TextHeight))) Then
        i = NthL&(ID1, ChainLimit + 1)
        j = NthP&(ID1, ChainLimit + 1)
        If (my = 1 + TopIndent) Then
            i = i ' clicked at top
        ElseIf (my = (TopIndent + TextHeight - 1)) Then
            i = j ' clicked at bottom
        Else
            t = LinearCount&(i, j)
            f = (my - TopIndent + 1) / (WindowHeight - TopIndent)
            For k = 1 To t
                r = k / t
                If (r >= f) Then Exit For
                i = TheChain(i).Pointer
            Next
            If (TextWrapping <> 2) Then
                'i = BackBreak&(i)
            End If
        End If
        StartIndex = i
        ID1 = i
    End If
End Sub

Sub MouseButton1Hscroll
    Dim i As Long
    Dim j As Long
    Dim k As Integer
    Dim t As Integer
    Dim r As Double
    Dim f As Double
    Dim As Double mx, my
    mx = _MouseX ' Int(_MouseX / 8)
    my = _MouseY ' Int(_MouseY / 16)
    If ((mx > LeftIndent) And (mx < (LeftIndent + 1 + TextWidth))) Then
        j = ID1
        i = NthP&(StartIndex, FindID%(LeftIndent + 1, Cursor1.Y))
        t = Len(LineAsMapped(Cursor1.Y - TopIndent))
        f = (mx - LeftIndent) / (WindowWidth - LeftIndent)
        For k = 1 To t
            r = k / t
            If (r >= f) Then Exit For
            i = TheChain(i).Pointer
        Next
        ID1 = i
        k = LinearCount&(StartIndex, i) - LinearCount&(StartIndex, j)
        If (TextWrapping = 2) Then HScroll = HScroll + k
        If (HScroll < 1) Then HScroll = 1
    End If
End Sub

Sub MouseButton1Cursor
    Dim k As Integer
    Dim As Double mx, my
    mx = _MouseX ' Int(_MouseX / 8)
    my = _MouseY ' Int(_MouseY / 16)
    Cursor1.X = mx
    k = LeftIndent + Len(LineAsMapped(my - TopIndent)) - (HScroll - 1)
    If (Cursor1.X > k) Then
        If (k < 0) Then
            If (Len(LineAsMapped(my - TopIndent)) > TextWidth) Then
                HScroll = 1 + Len(LineAsMapped(my - TopIndent)) - (Cursor1.X - LeftIndent)
            Else
                HScroll = 1
                Cursor1.X = LeftIndent + Len(LineAsMapped(my - TopIndent))
            End If
        Else
            Cursor1.X = k
        End If
    End If
    Cursor1.Y = my
    Call ReassignID1
End Sub

Function MouseButton2%
    ' Move Cursor2.
    Dim k As Integer
    Dim As Double mx, my
    mx = _MouseX ' Int(_MouseX / 8)
    my = _MouseY ' Int(_MouseY / 16)
    If (mx > LeftIndent) And (mx < TextWidth + LeftIndent + 1) And (my > TopIndent) And (my < TopIndent + TextHeight + 1) Then
        Cursor2.X = mx
        k = LeftIndent + Len(LineAsMapped(my - TopIndent)) - (HScroll - 1)
        If (Cursor2.X > k) Then
            If (k < 0) Then
            Else
                Cursor2.X = k
            End If
        End If
        Cursor2.Y = my
        Call ReassignID2
    End If
    MouseButton2% = 1
End Function

Function MouseButton3%
    Call PasteClipboard(ID1, _Clipboard$)
    MouseButton3% = 1
End Function

Function MouseWheelUp%
    Call KeyUpArrow
    MouseWheelUp% = 1
End Function

Function MouseWheelDown%
    Call KeyDwnArrow
    MouseWheelDown% = 1
End Function

Sub KeyBksp
    Dim qq As Long
    Dim q As Long
    Dim p As Long
    q = TheChain(ID1).Lagger
    p = TheChain(ID1).Pointer
    If (q = BOC) Then
        ' Do nothing.
    End If
    If (q <> BOC) Then
        If ((TextWrapping = 2) And (Cursor1.X - LeftIndent = 1)) Then
            If (HScroll > 1) Then
                HScroll = HScroll - 1
                Call CalibrateCursor(ID1)
            End If
        End If
        qq = TheChain(q).Lagger
        TheChain(ID1).Lagger = qq
        TheChain(q).Identity = 0
        If (qq <> BOC) Then
            If (StartIndex = q) Then StartIndex = BackBreak&(StartIndex)
            TheChain(qq).Pointer = ID1
        End If
        If (qq = BOC) Then
            StartIndex = ID1
        End If
    End If
    ID2 = StartIndex
End Sub

Sub KeyDel
    Dim i As _Integer64
    Dim q As Long
    Dim p As Long
    Dim q2 As Long
    Dim p2 As Long

    If (LinearCount(StartIndex, ID2) = LinearCount&(StartIndex, EOC)) Then
        i = -1
    Else
        i = LinearCount&(StartIndex, ID2) - LinearCount&(StartIndex, ID1)
    End If

    If (i <= 0) Then
        q = TheChain(ID1).Lagger
        p = TheChain(ID1).Pointer
        If (q = BOC) And (p = EOC) Then
            ' Never delete the only character.
            TheChain(ID1).Content = " "
        End If
        If (q <> BOC) And (p <> EOC) Then
            If (StartIndex = ID1) Then StartIndex = p
            TheChain(p).Lagger = q
            TheChain(ID1).Identity = 0
            TheChain(q).Pointer = p
            ID1 = p
        End If
        If ((q = BOC) And (p <> EOC)) Then
            StartIndex = p
            TheChain(p).Lagger = q
            TheChain(ID1).Identity = 0
            ID1 = p
        End If
        If ((q <> BOC) And (p = EOC)) Then
            If (StartIndex = ID1) Then StartIndex = q
            TheChain(ID1).Identity = 0
            TheChain(q).Pointer = p
            ID1 = q
        End If
    End If

    If (i > 0) Then
        q = TheChain(ID1).Lagger
        p = TheChain(ID1).Pointer
        q2 = TheChain(ID2).Lagger
        p2 = TheChain(ID2).Pointer

        If ((q <> BOC) And (p2 <> EOC)) Then
            If (StartIndex = ID1) Then StartIndex = p2
            Call UnlinkRange(ID1, ID2)
            ID1 = TheChain(q).Pointer
        End If
        If ((q = BOC) And (p2 <> EOC)) Then
            StartIndex = p2
            Call UnlinkRange(p, ID2)
            TheChain(p2).Lagger = q
            ID1 = p2
        End If
        If ((q <> BOC) And (p2 = EOC)) Then
            If (StartIndex = ID1) Then StartIndex = q
            Call UnlinkRange(ID1, q2)
            TheChain(ID2).Identity = 0
            TheChain(q).Pointer = p2
            ID1 = q
        End If
        If ((q = BOC) And (p2 = EOC)) Then
            StartIndex = ID1 '''
            Call UnlinkRange(p, q2)
            TheChain(ID2).Identity = 0
            TheChain(ID1).Content = " "
            TheChain(ID1).Lagger = BOC
            TheChain(ID1).Pointer = EOC
        End If
    End If

    ID2 = StartIndex
End Sub

Sub UnlinkRange (a As Long, b As Long)
    Dim q As Long
    Dim u As Long
    Dim p As Long
    q = TheChain(a).Lagger
    u = a
    Do
        TheChain(u).Identity = 0
        p = TheChain(u).Pointer
        If (u = b) Then Exit Do
        If (p <> EOC) Then u = p
    Loop
    TheChain(p).Lagger = q
    If (q <> BOC) Then TheChain(q).Pointer = p
End Sub

Sub KeyEsc
    If (ID2 <> ID1) Then
        ID2 = ID1
    Else
        ID2 = StartIndex
    End If
End Sub

Sub KeyEnterAlphaNumer (k As Integer)
    Dim z As Long
    Dim a As String
    Dim b As String
    Dim c As String
    Dim n As Integer
    If (_KeyDown(KeyboardLeftCtrl) Or _KeyDown(KeyboardRightCtrl)) Then

        If (k = KeyboardEnter) Then
            z = BackBreak2&(ID1)
            a = Projection$(z, TheChain(ID1).Lagger)

            If (Left$(a, 1) = ">") Then
                a = Right$(a, Len(a) - 1)
                a = _Trim$(a)
                a = pipecom_lite$(a)
                Do While ((Right$(a, 1) = CR) Or (Right$(a, 1) = LF))
                    a = Left$(a, Len(a) - 1)
                Loop
                z = InsertString&(CR + "(" + a + ")" + CR + ">", ID1)
            End If

            If (Left$(a, 6) = "]save ") Then
                a = Right$(a, Len(a) - 6)
                n = InStr(a, " ")
                b = Left$(a, n - 1)
                c = Right$(a, Len(a) - n)
                If (b <> "") Then
                    Open b For Output As #1
                    Print #1, c
                    Close #1
                    z = InsertString&(CR + "(" + b + ")" + CR + "]", ID1)
                Else
                    z = InsertString&(CR + "(" + "Error" + ")" + CR + "]", ID1)
                End If
            End If

            ID2 = StartIndex
        End If


        If (k = Asc("c")) Or (k = Asc("C")) Then
            _Clipboard$ = Projection$(ID1, ID2)
            ID2 = StartIndex
        End If

        If (k = Asc("v")) Or (k = Asc("V")) Then
            Call PasteClipboard(ID1, _Clipboard$)
            ID2 = StartIndex
        End If

        '''
    Else

        Call InsertCharacter(k)

        If ((k = KeyboardEnter) And (TextWrapping = 2)) Then HScroll = 1
        If ((k = KeyboardEnter) And (Cursor1.Y = TextHeight)) Then
            Call KeyDwnArrow
            Call KeyHome
        End If

    End If

End Sub

Sub KeyF1
    Dim h0 As Integer
    h0 = HScroll
    Call KeyLeftArrow
    If (h0 = HScroll) Then
        If (TextWrapping = 2) Then
            HScroll = HScroll - 1
            If (HScroll < 1) Then HScroll = 1
        End If
    End If
End Sub

Sub KeyF2
    Dim h0 As Integer
    h0 = HScroll
    Call KeyRightArrow
    If ((HScroll = h0) And (HScroll <> 1)) Then
        If (TextWrapping = 2) Then
            HScroll = HScroll + 1
        End If
    End If
End Sub

Sub KeyF3
    Dim j As Integer
    Dim k As Integer
    For k = 2 To _Width - 1
        For j = Int(_Height / 3) - 2 To Int(_Height / 3) + 2
            Color BackgroundColor, BackgroundColor
            Call StringPrint("", k, j, " ")
        Next
        Color Cursor1Back, Cursor1Back
        Call StringPrint("", k, Int(_Height / 3) - 2, " ")
        Color Cursor1Back, Cursor1Back
        Call StringPrint("", k, Int(_Height / 3) + 2, " ")
    Next
    Color TextFaceColor, BackgroundColor
    Cls
    Locate 1, 1: Line Input "Text to highlight: ", Highlight
End Sub

Sub KeyF4
    Cursor1.X = LeftIndent + 1
    Call ReassignID1
    Cursor2.X = LeftIndent + Len(LineAsMapped(Cursor1.Y - TopIndent))
    Cursor2.Y = Cursor1.Y
    Call ReassignID2
End Sub

Sub KeyF5
    Dim a As Long
    Dim b As Long
    Dim c As String
    Dim k As Long
    a = NthL&(ID1, ChainLimit + 1)
    b = NthP&(ID1, ChainLimit + 1)
    c = Projection$(a, b) + CR
    For k = 1 To ChainLimit
        TheChain(k).Identity = 0
    Next
    a = Assimilate&(c, BOC, EOC)
End Sub

Sub KeyF6
    Dim c As String
    Open WorkingFileName For Output As #1
    c = Projection$(NthL&(ID1, ChainLimit + 1), NthP&(ID1, ChainLimit + 1))
    Print #1, c
    Close #1
End Sub

Sub KeyF7
    GOLSwitch = -GOLSwitch
End Sub

Sub KeyF10
    ColorTheme = -ColorTheme
    Call SetPalette
End Sub

Sub KeyF11
    TextFormatting = -TextFormatting
End Sub

Sub KeyF12
    TextWrapping = TextWrapping + 1
    If (TextWrapping > 2) Then
        TextWrapping = 0
    End If
    If (TextWrapping <> 2) Then
        HScroll = 1
    End If
End Sub

Sub KeyHome
    If (TextWrapping = 2) Then HScroll = 1
    Cursor1.X = LeftIndent + 1
    Call ReassignID1
End Sub

Sub KeyUpArrow
    Dim k As Integer
    If (Cursor1.Y > TopIndent + 1) Then
        Cursor1.Y = Cursor1.Y - 1
    Else
        StartIndex = BackBreak&(StartIndex)
    End If
    k = LeftIndent + Len(LineAsMapped(Cursor1.Y - TopIndent)) - (HScroll - 1)
    If (Cursor1.X > k) Then
        If (k < 0) Then
            If (Len(LineAsMapped(Cursor1.Y - TopIndent)) > TextWidth) Then
                HScroll = 1 + Len(LineAsMapped(Cursor1.Y - TopIndent)) - (Cursor1.X - LeftIndent)
            Else
                HScroll = 1
                Cursor1.X = LeftIndent + Len(LineAsMapped(Cursor1.Y - TopIndent))
            End If
        Else
            Cursor1.X = k
        End If
    End If
    Call ReassignID1
End Sub

Sub KeyPgUp
    Dim k As Integer
    For k = 1 To Int(TextHeight / 2)
        StartIndex = BackBreak&(StartIndex)
    Next
    Call ReassignID1
End Sub

Sub KeyLeftArrow
    Dim j As Integer
    Dim k As Integer
    ID1 = NthL&(ID1, 2)
    If (TextWrapping = 2) Then
        If (Cursor1.X = LeftIndent + 1) Then
            If (HScroll > 1) Then
                HScroll = HScroll - 1
            Else
                j = Cursor1.Y - TopIndent - 1
                If (j >= 1) Then
                    k = Len(LineAsMapped(j)) - TextWidth + 1
                    If (k >= 1) Then
                        HScroll = k
                    End If
                End If
            End If
        End If
    Else
        If ((Cursor1.X - LeftIndent = 1) And Cursor1.Y - TopIndent = 1) Then
            StartIndex = BackBreak&(StartIndex)
        End If
    End If
End Sub

Sub KeyRightArrow
    Dim i As Integer
    Dim j As Integer
    Dim k As Integer
    ID1 = NthP&(ID1, 2)
    i = Cursor1.X - LeftIndent
    j = Len(LineAsMapped(Cursor1.Y - TopIndent)) - HScroll + 1
    If (TextWrapping = 2) Then
        If (i >= TextWidth) Then
            HScroll = HScroll + 1
            Call ReassignID1
        End If
        If (i >= j) Then
            k = Cursor1.Y - TopIndent + 1
            If ((k <= TextHeight) And (VisibleLines > 1)) Then HScroll = 1
        End If
    Else
        If ((i >= j) And (Cursor1.Y - TopIndent = VisibleLines)) Then
            If (VisibleLines > 1) Then StartIndex = NthP&(StartIndex, Len(LineAsMapped(1)) + 1)
        End If
    End If
End Sub

Sub KeyEnd
    Dim k As Integer
    If (TextWrapping <> 2) Then
        Cursor1.X = LeftIndent + Len(LineAsMapped(Cursor1.Y - TopIndent))
        Call ReassignID1
    End If
    If (TextWrapping = 2) Then
        Do
            If (TheChain(ID1).Content = CR) Then Exit Do
            If (TheChain(ID1).Pointer = EOC) Then Exit Do
            ID1 = TheChain(ID1).Pointer
        Loop
        k = Len(LineAsMapped(Cursor1.Y - TopIndent)) - TextWidth + 1
        If (k >= 1) Then
            HScroll = k
            Call CalibrateCursor(ID1)
        End If
    End If
End Sub

Sub KeyTab
    Dim z As Long
    z = InsertString&(Chr$(KeyboardTab), ID1)
End Sub

Sub KeyDwnArrow
    Dim k As Integer
    If (Cursor1.Y = TopIndent + VisibleLines) Then
        If (VisibleLines > 1) Then
            StartIndex = NthP&(StartIndex, Len(LineAsMapped(1)) + 1)
            Call MapText
        End If
    Else
        Cursor1.Y = Cursor1.Y + 1
    End If
    k = LeftIndent + Len(LineAsMapped(Cursor1.Y - TopIndent)) - (HScroll - 1)
    If (Cursor1.X > k) Then
        If (k < 0) Then
            If (Len(LineAsMapped(Cursor1.Y - TopIndent)) > TextWidth) Then
                HScroll = 1 + Len(LineAsMapped(Cursor1.Y - TopIndent)) - (Cursor1.X - LeftIndent)
            Else
                HScroll = 1
                Cursor1.X = LeftIndent + Len(LineAsMapped(Cursor1.Y - TopIndent))
            End If
        Else
            Cursor1.X = k
        End If
    End If
    Call ReassignID1
End Sub

Sub KeyPgDn
    Dim k As Integer
    For k = 1 To Int(TextHeight / 2)
        If (VisibleLines > 1) Then
            StartIndex = NthP&(StartIndex, Len(LineAsMapped(1)) + 1)
            Call MapText
        End If
    Next
    Call ReassignID1
End Sub

Sub KeyIns
    InsertKey = -InsertKey
End Sub

Sub ConvertToGrid
    Dim i As Integer
    Dim j As Integer
    Dim c As String
    For j = 1 To VisibleLines
        c = LineAsMapped(j)
        For i = 1 To Len(c) - 1 ' BR offset to exclude CR at line end.
            AuxGrid(i, j, 1) = Mid$(c, i, 1)
        Next
    Next
End Sub

Sub ConvertFromGrid
    Dim i As Integer
    Dim j As Integer
    Dim k As Long
    Dim c As String
    c = ""
    For j = 1 To VisibleLines
        For i = 1 To Len(LineAsMapped(j)) - 1
            c = c + AuxGrid(i, j, 1)
        Next
        c = c + CR ' Undoes BR offset.
    Next
    For k = 1 To ChainLimit
        TheChain(k).Identity = 0
    Next
    k = Assimilate&(c, BOC, EOC)
End Sub

Sub GOL
    Dim i As Integer
    Dim j As Integer
    Dim c As String
    Dim a1 As Integer
    Dim a2 As Integer
    Dim a3 As Integer
    Dim a4 As Integer
    Dim a6 As Integer
    Dim a7 As Integer
    Dim a8 As Integer
    Dim a9 As Integer
    Dim t As Integer
    For j = 1 To VisibleLines
        For i = 1 To Len(LineAsMapped(j)) - 1
            c = AuxGrid(i, j, 1)
            If (c = " ") Then c = "0" Else c = "1"
            AuxGrid(i, j, 1) = c
            AuxGrid(i, j, 2) = c
        Next
    Next
    For j = 2 To VisibleLines - 2 ' BR offset.
        For i = 2 To Len(LineAsMapped(j)) - 2 ' BR offset.
            c = AuxGrid(i, j, 1)
            a1 = Val(AuxGrid(i - 1, j + 1, 1))
            a2 = Val(AuxGrid(i, j + 1, 1))
            a3 = Val(AuxGrid(i + 1, j + 1, 1))
            a4 = Val(AuxGrid(i - 1, j, 1))
            a6 = Val(AuxGrid(i + 1, j, 1))
            a7 = Val(AuxGrid(i - 1, j - 1, 1))
            a8 = Val(AuxGrid(i, j - 1, 1))
            a9 = Val(AuxGrid(i + 1, j - 1, 1))
            t = a1 + a2 + a3 + a4 + a6 + a7 + a8 + a9
            If (c = "1") Then
                Select Case t
                    Case Is < 2
                        AuxGrid(i, j, 2) = "0"
                    Case 2
                        AuxGrid(i, j, 2) = "1"
                    Case 3
                        AuxGrid(i, j, 2) = "1"
                    Case Is > 3
                        AuxGrid(i, j, 2) = "0"
                End Select
            Else
                If (t = 3) Then AuxGrid(i, j, 2) = "1"
            End If
        Next
    Next
    For j = 1 To VisibleLines
        For i = 1 To Len(LineAsMapped(j)) - 1
            c = AuxGrid(i, j, 2)
            If (c = "0") Then c = " " Else c = Chr$(219)
            AuxGrid(i, j, 1) = c
            AuxGrid(i, j, 2) = c
        Next
    Next
End Sub

'''

$If PIPECOM = UNDEFINED Then
    $Let PIPECOM = TRUE
    Function pipecom& (cmd As String, stdout As String, stderr As String)
        stdout = "": stderr = ""
        $If WIN Then
            Type SECURITY_ATTRIBUTES
                As _Unsigned Long nLength
                $If 64BIT Then
                    As String * 4 padding
                $End If
                As _Offset lpSecurityDescriptor
                As Long bInheritHandle
                $If 64BIT Then
                    As String * 4 padding2
                $End If
            End Type

            Type STARTUPINFO
                As Long cb
                $If 64BIT Then
                    As String * 4 padding
                $End If
                As _Offset lpReserved, lpDesktop, lpTitle
                As _Unsigned Long dwX, dwY, dwXSize, dwYSize, dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags
                As _Unsigned Integer wShowWindow, cbReserved2
                $If 64BIT Then
                    As String * 4 padding2
                $End If
                As _Offset lpReserved2, hStdInput, hStdOutput, hStdError
            End Type

            Type PROCESS_INFORMATION
                As _Offset hProcess, hThread
                As _Unsigned Long dwProcessId
                $If 64BIT Then
                    As String * 4 padding
                $End If
            End Type

            Const STARTF_USESTDHANDLES = &H00000100
            Const CREATE_NO_WINDOW = &H8000000

            Const INFINITE = 4294967295
            Const WAIT_FAILED = &HFFFFFFFF

            Declare CustomType Library
                Function CreatePipe& (ByVal hReadPipe As _Offset, Byval hWritePipe As _Offset, Byval lpPipeAttributes As _Offset, Byval nSize As _Unsigned Long)
                Function CreateProcess& (ByVal lpApplicationName As _Offset, Byval lpCommandLine As _Offset, Byval lpProcessAttributes As _Offset, Byval lpThreadAttributes As _Offset, Byval bInheritHandles As Long, Byval dwCreationFlags As _Unsigned Long, Byval lpEnvironment As _Offset, Byval lpCurrentDirectory As _Offset, Byval lpStartupInfo As _Offset, Byval lpProcessInformation As _Offset)
                Function GetExitCodeProcess& (ByVal hProcess As _Offset, Byval lpExitCode As _Offset)
                Sub HandleClose Alias "CloseHandle" (ByVal hObject As _Offset)
                Function ReadFile& (ByVal hFile As _Offset, Byval lpBuffer As _Offset, Byval nNumberOfBytesToRead As _Unsigned Long, Byval lpNumberOfBytesRead As _Offset, Byval lpOverlapped As _Offset)
                Function WaitForSingleObject~& (ByVal hHandle As _Offset, Byval dwMilliseconds As _Unsigned Long)
            End Declare

            Dim As Long ok: ok = 1
            Dim As _Offset hStdOutPipeRead, hStdOutPipeWrite, hStdReadPipeError, hStdOutPipeError
            Dim As SECURITY_ATTRIBUTES sa: sa.nLength = Len(sa): sa.lpSecurityDescriptor = 0: sa.bInheritHandle = 1

            If CreatePipe(_Offset(hStdOutPipeRead), _Offset(hStdOutPipeWrite), _Offset(sa), 0) = 0 Then
                pipecom = -1
                Exit Function
            End If

            If CreatePipe(_Offset(hStdReadPipeError), _Offset(hStdOutPipeError), _Offset(sa), 0) = 0 Then
                pipecom = -1
                Exit Function
            End If

            Dim As STARTUPINFO si
            si.cb = Len(si)
            si.dwFlags = STARTF_USESTDHANDLES
            si.hStdError = hStdOutPipeError
            si.hStdOutput = hStdOutPipeWrite
            si.hStdInput = 0
            Dim As PROCESS_INFORMATION procinfo
            Dim As _Offset lpApplicationName
            Dim As String lpCommandLine: lpCommandLine = "cmd /c " + cmd + Chr$(0)
            Dim As _Offset lpProcessAttributes, lpThreadAttributes
            Dim As Long bInheritHandles: bInheritHandles = 1
            Dim As _Unsigned Long dwCreationFlags: dwCreationFlags = CREATE_NO_WINDOW
            Dim As _Offset lpEnvironment, lpCurrentDirectory
            ok = CreateProcess(lpApplicationName, _Offset(lpCommandLine), lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, _Offset(si), _Offset(procinfo))

            If ok = 0 Then
                pipecom = -1
                Exit Function
            End If

            HandleClose hStdOutPipeWrite
            HandleClose hStdOutPipeError

            Dim As String buf: buf = Space$(4096 + 1)
            Dim As _Unsigned Long dwRead
            While ReadFile(hStdOutPipeRead, _Offset(buf), 4096, _Offset(dwRead), 0) <> 0 And dwRead > 0
                buf = Mid$(buf, 1, dwRead)
                GoSub RemoveChr13
                stdout = stdout + buf
                buf = Space$(4096 + 1)
            Wend

            While ReadFile(hStdReadPipeError, _Offset(buf), 4096, _Offset(dwRead), 0) <> 0 And dwRead > 0
                buf = Mid$(buf, 1, dwRead)
                GoSub RemoveChr13
                stderr = stderr + buf
                buf = Space$(4096 + 1)
            Wend

            Dim As Long exit_code, ex_stat
            If WaitForSingleObject(procinfo.hProcess, INFINITE) <> WAIT_FAILED Then
                If GetExitCodeProcess(procinfo.hProcess, _Offset(exit_code)) Then
                    ex_stat = 1
                End If
            End If

            HandleClose hStdOutPipeRead
            HandleClose hStdReadPipeError
            If ex_stat = 1 Then
                pipecom = exit_code
            Else
                pipecom = -1
            End If

            Exit Function

            RemoveChr13:
            Dim As Long j
            j = InStr(buf, Chr$(13))
            Do While j
                buf = Left$(buf, j - 1) + Mid$(buf, j + 1)
                j = InStr(buf, Chr$(13))
            Loop
            Return
        $Else
                Declare CustomType Library
                Function popen%& (cmd As String, readtype As String)
                Function feof& (ByVal stream As _Offset)
                Function fgets$ (str As String, Byval n As Long, Byval stream As _Offset)
                Function pclose& (ByVal stream As _Offset)
                End Declare

                Declare Library
                Function WEXITSTATUS& (ByVal stat_val As Long)
                End Declare

                Dim As _Offset stream

                Dim buffer As String * 4096
                If _FileExists("pipestderr") Then
                Kill "pipestderr"
                End If
                stream = popen(cmd + " 2>pipestderr", "r")
                If stream Then
                While feof(stream) = 0
                If fgets(buffer, 4096, stream) <> "" And feof(stream) = 0 Then
                stdout = stdout + Mid$(buffer, 1, InStr(buffer, Chr$(0)) - 1)
                End If
                Wend
                Dim As Long status, exit_code
                status = pclose(stream)
                exit_code = WEXITSTATUS(status)
                If _FileExists("pipestderr") Then
                Dim As Integer errfile
                errfile = FreeFile
                Open "pipestderr" For Binary As #errfile
                If LOF(errfile) > 0 Then
                stderr = Space$(LOF(errfile))
                Get #errfile, , stderr
                End If
                Close #errfile
                Kill "pipestderr"
                End If
                pipecom = exit_code
                Else
                pipecom = -1
                End If
        $End If
    End Function

    Function pipecom_lite$ (cmd As String)
        Dim As Long a
        Dim As String stdout, stderr
        a = pipecom(cmd, stdout, stderr)
        If stderr <> "" Then
            pipecom_lite = stderr
        Else
            pipecom_lite = stdout
        End If
    End Function
$End If

