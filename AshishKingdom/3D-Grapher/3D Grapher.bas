'##############################################################################
'3D Grapher in QB64 using OpenGL
'
'Contributors:
'  Ashish Kushwaha (primary)
'  FellipeHeitor
'  STxAxTIC
'
'See README.bm.

Option _Explicit

Rem $INCLUDE: 'sxript.bi'
Rem $Include: 'sxmath.bi'

Do Until _ScreenExists: Loop
_Title "3D Grapher"

Screen _NewImage(600, 600, 32)

Declare Library
    Sub gluLookAt (ByVal eyeX#, Byval eyeY#, Byval eyeZ#, Byval centerX#, Byval centerY#, Byval centerZ#, Byval upX#, Byval upY#, Byval upZ#)
End Declare

' Types.
Type rgb
    r As Single
    g As Single
    b As Single
End Type

' Master switch for SUB _GL().
Dim Shared glAllow As Integer

' Plot structure.
Dim Shared mainEquation As String
Dim Shared shadeMap(100, 100) As rgb
Dim Shared vert(100, 100)

' Plot settings.
Dim Shared stepFactor As Double
Dim Shared zStretch As Double

' Camera settings.
Dim Shared xRot As Double
Dim Shared yRot As Double
Dim Shared zoomFactor

' Render settings.
Dim Shared graph_render_mode

' Initialize.
Call setShades
stepFactor = .1
zStretch = 5
zoomFactor = 1.0
mainEquation = "sin((x^2)-(y^2))"

If (Command$ <> "") Then
    Open Command$ For Input As #1
    Input #1, mainEquation
    Close #1
Else
    Call getEquation
End If

' Prime main loop.
Call initSequence

' Main loop.
Do
    Call mouseProcess
    If (glAllow = 0) Then
        Call getEquation
        Call initSequence
    End If
    Call keyProcess
    _Limit 60
Loop

End

Sub _GL Static
    If (glAllow = 0) Then Exit Sub

    Dim x As Integer
    Dim z As Integer

    ' Environment.
    _glClear _GL_COLOR_BUFFER_BIT Or _GL_DEPTH_BUFFER_BIT
    _glEnable _GL_DEPTH_TEST
    _glEnable _GL_BLEND
    _glMatrixMode _GL_PROJECTION

    _gluPerspective 50, 1, 0.1, 40
    _glMatrixMode _GL_MODELVIEW

    _glLoadIdentity

    gluLookAt 0, 7, 15, 0, 0, 0, 0, 1, 0

    ' Set camera angle.
    _glRotatef xRot, 1, 0, 0
    _glRotatef yRot, 0, 1, 0

    ' Set camera zoom.
    _glScalef zoomFactor, zoomFactor, zoomFactor

    ' Draw axes.
    _glBegin _GL_LINES
    _glLineWidth 2.0
    ' x-axis
    _glColor3f 1, 0, 0
    _glVertex3f -5, 0, 0
    _glVertex3f 5, 0, 0
    ' z-axis
    _glColor3f 0, 1, 0
    _glVertex3f 0, -5, 0
    _glVertex3f 0, 5, 0
    ' y-axis
    _glColor3f 0, 0, 1
    _glVertex3f 0, 0, -5
    _glVertex3f 0, 0, 5
    _glEnd

    ' Draw the surface.
    For z = -50 To 49
        For x = -50 To 49

            ' Each square patch is really two triangles.

            If (graph_render_mode = 1) Then _glBegin _GL_TRIANGLE_STRIP Else _glBegin _GL_LINE_STRIP
            _glColor4f shadeMap(x + 50, z + 50).r, shadeMap(x + 50, z + 50).g, shadeMap(x + 50, z + 50).b, 0.7
            _glLineWidth 1.0
            _glVertex3f x, vert(x + 50, z + 50), z
            _glVertex3f x + 1, vert(x + 51, z + 50), z
            _glVertex3f x, vert(x + 50, z + 51), z + 1
            _glEnd

            If (graph_render_mode = 1) Then _glBegin _GL_TRIANGLE_STRIP Else _glBegin _GL_LINE_STRIP
            _glColor4f shadeMap(x + 50, z + 50).r, shadeMap(x + 50, z + 50).g, shadeMap(x + 50, z + 50).b, 0.7
            _glLineWidth 1.0
            _glVertex3f x + 1, vert(x + 51, z + 51), z + 1
            _glVertex3f x + 1, vert(x + 51, z + 50), z
            _glVertex3f x, vert(x + 50, z + 51), z + 1
            _glEnd

        Next
    Next

End Sub

'By Fellipe Heitor
Function INPUTBOX (tTitle$, tMessage$, InitialValue As String, NewValue As String, Selected)
    'INPUTBOX ---------------------------------------------------------------------
    'Show a dialog and allow user input. Returns 1 = OK or 2 = Cancel.            '
    '                                                                             '
    '- tTitle$ is the desired dialog title. If not provided, it'll be "Input"     '
    '                                                                             '
    '- tMessage$ is the prompt that'll be shown to the user. You can show         '
    '   a multiline message by adding line breaks with CHR$(10).                  '
    '                                                                             '
    ' - InitialValue can be passed both as a string literal or as a variable.     '
    '                                                                             '
    '- Actual user input is returned by altering NewValue, so it must be          '
    '   passed as a variable.                                                     '
    '                                                                             '
    '- Selected indicates wheter the initial value will be preselected when the   '
    '   dialog is first shown. -1 preselects the whole text; positive values      '
    '   select only part of the initial value (from the character position passed '
    '   to the end of the initial value).                                         '
    '                                                                             '
    'Intended for use with 32-bit screen modes.                                   '
    '------------------------------------------------------------------------------

    'Variable declaration:
    Dim Message$, Title$, CharW As Integer, MaxLen As Integer
    Dim lineBreak As Integer, totalLines As Integer, prevlinebreak As Integer
    Dim Cursor As Integer, Selection.Start As Integer, InputViewStart As Integer
    Dim FieldArea As Integer, DialogH As Integer, DialogW As Integer
    Dim DialogX As Integer, DialogY As Integer, InputField.X As Integer
    Dim TotalButtons As Integer, B As Integer, ButtonLine$
    Dim cb As Integer, DIALOGRESULT As Integer, i As Integer
    Dim message.X As Integer, SetCursor#, cursorBlink%
    Dim DefaultButton As Integer, k As Long
    Dim shiftDown As _Byte, ctrlDown As _Byte, Clip$
    Dim FindLF%, s1 As Integer, s2 As Integer
    Dim Selection.Value$
    Dim prevCursor As Integer, ss1 As Integer, ss2 As Integer, mb As _Byte
    Dim mx As Integer, my As Integer, nmx As Integer, nmy As Integer
    Dim FGColor As Long, BGColor As Long

    'Data type used for the dialog buttons:
    Type BUTTONSTYPE
        ID As Long
        CAPTION As String * 120
        X As Integer
        Y As Integer
        W As Integer
    End Type

    'Color constants. You can customize colors by changing these:
    Const TitleBarColor = _RGB32(0, 178, 179)
    Const DialogBGColor = _RGB32(255, 255, 255)
    Const TitleBarTextColor = _RGB32(0, 0, 0)
    Const DialogTextColor = _RGB32(0, 0, 0)
    Const InputFieldColor = _RGB32(200, 200, 200)
    Const InputFieldTextColor = _RGB32(0, 0, 0)
    Const SelectionColor = _RGBA32(127, 127, 127, 100)

    'Initial variable setup:
    Message$ = tMessage$
    Title$ = RTrim$(LTrim$(tTitle$))
    If Title$ = "" Then Title$ = "Input"
    NewValue = RTrim$(LTrim$(InitialValue))
    DefaultButton = 1

    'Save the current drawing page so it can be restored later:
    FGColor = _DefaultColor
    BGColor = _BackgroundColor
    PCopy 0, 1

    'Figure out the print width of a single character (in case user has a custom font applied)
    CharW = _PrintWidth("_")

    'Place a color overlay over the old screen image so the focus is on the dialog:
    Line (0, 0)-Step(_Width - 1, _Height - 1), _RGBA32(170, 170, 170, 170), BF

    'Message breakdown, in case CHR$(10) was used as line break:
    ReDim MessageLines(1) As String
    MaxLen = 1
    Do
        lineBreak = InStr(lineBreak + 1, Message$, Chr$(10))
        If lineBreak = 0 And totalLines = 0 Then
            totalLines = 1
            MessageLines(1) = Message$
            MaxLen = Len(Message$)
            Exit Do
        ElseIf lineBreak = 0 And totalLines > 0 Then
            totalLines = totalLines + 1
            ReDim _Preserve MessageLines(1 To totalLines) As String
            MessageLines(totalLines) = Right$(Message$, Len(Message$) - prevlinebreak + 1)
            If Len(MessageLines(totalLines)) > MaxLen Then MaxLen = Len(MessageLines(totalLines))
            Exit Do
        End If
        If totalLines = 0 Then prevlinebreak = 1
        totalLines = totalLines + 1
        ReDim _Preserve MessageLines(1 To totalLines) As String
        MessageLines(totalLines) = Mid$(Message$, prevlinebreak, lineBreak - prevlinebreak)
        If Len(MessageLines(totalLines)) > MaxLen Then MaxLen = Len(MessageLines(totalLines))
        prevlinebreak = lineBreak + 1
    Loop

    Cursor = Len(NewValue)
    Selection.Start = 0
    InputViewStart = 1
    FieldArea = _Width \ CharW - 4
    If FieldArea > 62 Then FieldArea = 62
    If Selected > 0 Then Selection.Start = Selected: Selected = -1

    'Calculate dialog dimensions and print coordinates:
    DialogH = _FontHeight * (6 + totalLines) + 10
    DialogW = (CharW * FieldArea) + 10
    If DialogW < MaxLen * CharW + 10 Then DialogW = MaxLen * CharW + 10

    DialogX = _Width / 2 - DialogW / 2
    DialogY = _Height / 2 - DialogH / 2
    InputField.X = (DialogX + (DialogW / 2)) - (((FieldArea * CharW) - 10) / 2) - 4

    'Calculate button's print coordinates:
    TotalButtons = 2
    Dim Buttons(1 To TotalButtons) As BUTTONSTYPE
    B = 1
    Buttons(B).ID = 1: Buttons(B).CAPTION = "< OK >": B = B + 1
    Buttons(B).ID = 2: Buttons(B).CAPTION = "< Cancel >": B = B + 1
    ButtonLine$ = " "
    For cb = 1 To TotalButtons
        ButtonLine$ = ButtonLine$ + RTrim$(LTrim$(Buttons(cb).CAPTION)) + " "
        Buttons(cb).Y = DialogY + 5 + _FontHeight * (5 + totalLines)
        Buttons(cb).W = _PrintWidth(RTrim$(LTrim$(Buttons(cb).CAPTION)))
    Next cb
    Buttons(1).X = _Width / 2 - _PrintWidth(ButtonLine$) / 2
    For cb = 2 To TotalButtons
        Buttons(cb).X = Buttons(1).X + _PrintWidth(Space$(InStr(ButtonLine$, RTrim$(LTrim$(Buttons(cb).CAPTION)))))
    Next cb

    'Main loop:
    DIALOGRESULT = 0
    _KeyClear
    Do: _Limit 500
        'Draw the dialog.
        Line (DialogX, DialogY)-Step(DialogW - 1, DialogH - 1), DialogBGColor, BF
        Line (DialogX, DialogY)-Step(DialogW - 1, _FontHeight + 1), TitleBarColor, BF
        Color TitleBarTextColor
        _PrintString (_Width / 2 - _PrintWidth(Title$) / 2, DialogY + 1), Title$

        Color DialogTextColor, _RGBA32(0, 0, 0, 0)
        For i = 1 To totalLines
            message.X = _Width / 2 - _PrintWidth(MessageLines(i)) / 2
            _PrintString (message.X, DialogY + 5 + _FontHeight * (i + 1)), MessageLines(i)
        Next i

        'Draw the input field
        Line (InputField.X - 2, DialogY + 3 + _FontHeight * (3 + totalLines))-Step(FieldArea * CharW, _FontHeight + 4), InputFieldColor, BF
        Color InputFieldTextColor
        _PrintString (InputField.X, DialogY + 5 + _FontHeight * (3 + totalLines)), Mid$(NewValue, InputViewStart, FieldArea)

        'Selection highlight:
        GoSub SelectionHighlight

        'Cursor blink:
        If Timer - SetCursor# > .4 Then
            SetCursor# = Timer
            If cursorBlink% = 1 Then cursorBlink% = 0 Else cursorBlink% = 1
        End If
        If cursorBlink% = 1 Then
            Line (InputField.X + (Cursor - (InputViewStart - 1)) * CharW, DialogY + 5 + _FontHeight * (3 + totalLines))-Step(0, _FontHeight), _RGB32(0, 0, 0)
        End If

        'Check if buttons have been clicked or are being hovered:
        GoSub CheckButtons

        'Draw buttons:
        For cb = 1 To TotalButtons
            _PrintString (Buttons(cb).X, Buttons(cb).Y), RTrim$(LTrim$(Buttons(cb).CAPTION))
            If cb = DefaultButton Then
                Color _RGB32(255, 255, 0)
                _PrintString (Buttons(cb).X, Buttons(cb).Y), "<" + Space$(Len(RTrim$(LTrim$(Buttons(cb).CAPTION))) - 2) + ">"
                Color _RGB32(0, 178, 179)
                _PrintString (Buttons(cb).X - 1, Buttons(cb).Y - 1), "<" + Space$(Len(RTrim$(LTrim$(Buttons(cb).CAPTION))) - 2) + ">"
                Color _RGB32(0, 0, 0)
            End If
        Next cb

        _Display

        'Process input:
        k = _KeyHit
        If k = 100303 Or k = 100304 Then shiftDown = -1
        If k = -100303 Or k = -100304 Then shiftDown = 0
        If k = 100305 Or k = 100306 Then ctrlDown = -1
        If k = -100305 Or k = -100306 Then ctrlDown = 0

        Select Case k
            Case 13: DIALOGRESULT = 1
            Case 27: DIALOGRESULT = 2
            Case 32 To 126 'Printable ASCII characters
                If k = Asc("v") Or k = Asc("V") Then 'Paste from clipboard (Ctrl+V)
                    If ctrlDown Then
                        Clip$ = _Clipboard$
                        FindLF% = InStr(Clip$, Chr$(13))
                        If FindLF% > 0 Then Clip$ = Left$(Clip$, FindLF% - 1)
                        FindLF% = InStr(Clip$, Chr$(10))
                        If FindLF% > 0 Then Clip$ = Left$(Clip$, FindLF% - 1)
                        If Len(RTrim$(LTrim$(Clip$))) > 0 Then
                            If Not Selected Then
                                If Cursor = Len(NewValue) Then
                                    NewValue = NewValue + Clip$
                                    Cursor = Len(NewValue)
                                Else
                                    NewValue = Left$(NewValue, Cursor) + Clip$ + Mid$(NewValue, Cursor + 1)
                                    Cursor = Cursor + Len(Clip$)
                                End If
                            Else
                                s1 = Selection.Start
                                s2 = Cursor
                                If s1 > s2 Then Swap s1, s2
                                NewValue = Left$(NewValue, s1) + Clip$ + Mid$(NewValue, s2 + 1)
                                Cursor = s1 + Len(Clip$)
                                Selected = 0
                            End If
                        End If
                        k = 0
                    End If
                ElseIf k = Asc("c") Or k = Asc("C") Then 'Copy selection to clipboard (Ctrl+C)
                    If ctrlDown Then
                        _Clipboard$ = Selection.Value$
                        k = 0
                    End If
                ElseIf k = Asc("x") Or k = Asc("X") Then 'Cut selection to clipboard (Ctrl+X)
                    If ctrlDown Then
                        _Clipboard$ = Selection.Value$
                        GoSub DeleteSelection
                        k = 0
                    End If
                ElseIf k = Asc("a") Or k = Asc("A") Then 'Select all text (Ctrl+A)
                    If ctrlDown Then
                        Cursor = Len(NewValue)
                        Selection.Start = 0
                        Selected = -1
                        k = 0
                    End If
                End If

                If k > 0 Then
                    If Not Selected Then
                        If Cursor = Len(NewValue) Then
                            NewValue = NewValue + Chr$(k)
                            Cursor = Cursor + 1
                        Else
                            NewValue = Left$(NewValue, Cursor) + Chr$(k) + Mid$(NewValue, Cursor + 1)
                            Cursor = Cursor + 1
                        End If
                        If Cursor > FieldArea Then InputViewStart = (Cursor - FieldArea) + 2
                    Else
                        s1 = Selection.Start
                        s2 = Cursor
                        If s1 > s2 Then Swap s1, s2
                        NewValue = Left$(NewValue, s1) + Chr$(k) + Mid$(NewValue, s2 + 1)
                        Selected = 0
                        Cursor = s1 + 1
                    End If
                End If
            Case 8 'Backspace
                If Len(NewValue) > 0 Then
                    If Not Selected Then
                        If Cursor = Len(NewValue) Then
                            NewValue = Left$(NewValue, Len(NewValue) - 1)
                            Cursor = Cursor - 1
                        ElseIf Cursor > 1 Then
                            NewValue = Left$(NewValue, Cursor - 1) + Mid$(NewValue, Cursor + 1)
                            Cursor = Cursor - 1
                        ElseIf Cursor = 1 Then
                            NewValue = Right$(NewValue, Len(NewValue) - 1)
                            Cursor = Cursor - 1
                        End If
                    Else
                        GoSub DeleteSelection
                    End If
                End If
            Case 21248 'Delete
                If Not Selected Then
                    If Len(NewValue) > 0 Then
                        If Cursor = 0 Then
                            NewValue = Right$(NewValue, Len(NewValue) - 1)
                        ElseIf Cursor > 0 And Cursor <= Len(NewValue) - 1 Then
                            NewValue = Left$(NewValue, Cursor) + Mid$(NewValue, Cursor + 2)
                        End If
                    End If
                Else
                    GoSub DeleteSelection
                End If
            Case 19200 'Left arrow key
                GoSub CheckSelection
                If Cursor > 0 Then Cursor = Cursor - 1
            Case 19712 'Right arrow key
                GoSub CheckSelection
                If Cursor < Len(NewValue) Then Cursor = Cursor + 1
            Case 18176 'Home
                GoSub CheckSelection
                Cursor = 0
            Case 20224 'End
                GoSub CheckSelection
                Cursor = Len(NewValue)
        End Select

        'Cursor adjustments:
        GoSub CursorAdjustments
    Loop Until DIALOGRESULT > 0

    _KeyClear
    INPUTBOX = DIALOGRESULT

    'Restore previous display:
    PCopy 1, 0
    Color FGColor, BGColor
    Exit Function

    CursorAdjustments:
    If Cursor > prevCursor Then
        If Cursor - InputViewStart + 2 > FieldArea Then InputViewStart = (Cursor - FieldArea) + 2
    ElseIf Cursor < prevCursor Then
        If Cursor < InputViewStart - 1 Then InputViewStart = Cursor
    End If
    prevCursor = Cursor
    If InputViewStart < 1 Then InputViewStart = 1
    Return

    CheckSelection:
    If shiftDown = -1 Then
        If Selected = 0 Then
            Selected = -1
            Selection.Start = Cursor
        End If
    ElseIf shiftDown = 0 Then
        Selected = 0
    End If
    Return

    DeleteSelection:
    NewValue = Left$(NewValue, s1) + Mid$(NewValue, s2 + 1)
    Selected = 0
    Cursor = s1
    Return

    SelectionHighlight:
    If Selected Then
        s1 = Selection.Start
        s2 = Cursor
        If s1 > s2 Then
            Swap s1, s2
            If InputViewStart > 1 Then
                ss1 = s1 - InputViewStart + 1
            Else
                ss1 = s1
            End If
            ss2 = s2 - s1
            If ss1 + ss2 > FieldArea Then ss2 = FieldArea - ss1
        Else
            ss1 = s1
            ss2 = s2 - s1
            If ss1 < InputViewStart Then ss1 = 0: ss2 = s2 - InputViewStart + 1
            If ss1 > InputViewStart Then ss1 = ss1 - InputViewStart + 1: ss2 = s2 - s1
        End If
        Selection.Value$ = Mid$(NewValue, s1 + 1, s2 - s1)

        Line (InputField.X + ss1 * CharW, DialogY + 5 + _FontHeight * (3 + totalLines))-Step(ss2 * CharW, _FontHeight), _RGBA32(255, 255, 255, 150), BF
    End If
    Return

    CheckButtons:
    'Hover highlight:
    While _MouseInput: Wend
    mb = _MouseButton(1): mx = _MouseX: my = _MouseY
    For cb = 1 To TotalButtons
        If (mx >= Buttons(cb).X) And (mx <= Buttons(cb).X + Buttons(cb).W) Then
            If (my >= Buttons(cb).Y) And (my < Buttons(cb).Y + _FontHeight) Then
                Line (Buttons(cb).X, Buttons(cb).Y)-Step(Buttons(cb).W, _FontHeight - 1), _RGBA32(230, 230, 230, 235), BF
            End If
        End If
    Next cb

    If mb Then
        If mx >= InputField.X And my >= DialogY + 3 + _FontHeight * (3 + totalLines) And mx <= InputField.X + (FieldArea * CharW - 10) And my <= DialogY + 3 + _FontHeight * (3 + totalLines) + _FontHeight + 4 Then
            'Clicking inside the text field positions the cursor
            While _MouseButton(1)
                _Limit 500
                mb = _MouseInput
            Wend
            Cursor = ((mx - InputField.X) / CharW) + (InputViewStart - 1)
            If Cursor > Len(NewValue) Then Cursor = Len(NewValue)
            Selected = 0
            Return
        End If

        For cb = 1 To TotalButtons
            If (mx >= Buttons(cb).X) And (mx <= Buttons(cb).X + Buttons(cb).W) Then
                If (my >= Buttons(cb).Y) And (my < Buttons(cb).Y + _FontHeight) Then
                    DefaultButton = cb
                    While _MouseButton(1): _Limit 500: mb = _MouseInput: Wend
                    mb = 0: nmx = _MouseX: nmy = _MouseY
                    If nmx = mx And nmy = my Then DIALOGRESULT = cb
                    Return
                End If
            End If
        Next cb
    End If
    Return
End Function

Function hsb~& (__H As _Float, __S As _Float, __B As _Float, A As _Float)
    'method adapted form http://stackoverflow.com/questions/4106363/converting-rgb-to-hsb-colors
    Dim H As _Float, S As _Float, B As _Float

    H = map(__H, 0, 255, 0, 360)
    S = map(__S, 0, 255, 0, 1)
    B = map(__B, 0, 255, 0, 1)

    If S = 0 Then
        hsb~& = _RGBA32(B * 255, B * 255, B * 255, A)
        Exit Function
    End If

    Dim fmx As _Float, fmn As _Float
    Dim fmd As _Float, iSextant As Integer
    Dim imx As Integer, imd As Integer, imn As Integer

    If B > .5 Then
        fmx = B - (B * S) + S
        fmn = B + (B * S) - S
    Else
        fmx = B + (B * S)
        fmn = B - (B * S)
    End If

    iSextant = Int(H / 60)

    If H >= 300 Then
        H = H - 360
    End If

    H = H / 60
    H = H - (2 * Int(((iSextant + 1) Mod 6) / 2))

    If iSextant Mod 2 = 0 Then
        fmd = (H * (fmx - fmn)) + fmn
    Else
        fmd = fmn - (H * (fmx - fmn))
    End If

    imx = _Round(fmx * 255)
    imd = _Round(fmd * 255)
    imn = _Round(fmn * 255)

    Select Case Int(iSextant)
        Case 1
            hsb~& = _RGBA32(imd, imx, imn, A)
        Case 2
            hsb~& = _RGBA32(imn, imx, imd, A)
        Case 3
            hsb~& = _RGBA32(imn, imd, imx, A)
        Case 4
            hsb~& = _RGBA32(imd, imn, imx, A)
        Case 5
            hsb~& = _RGBA32(imx, imn, imd, A)
        Case Else
            hsb~& = _RGBA32(imx, imd, imn, A)
    End Select
End Function

Sub getEquation
    Dim inputStatus As Integer
    Cls
    inputStatus = INPUTBOX("Equation Editor", "Enter the expression for z = (ex. x*y)", mainEquation, mainEquation, -1)
    If (inputStatus = 2) Then End
End Sub

Sub initSequence
    Cls
    Print "Generating..."
    _Display
    Call generatePlot(mainEquation)
    Cls , 1
    Color , 1
    Print "z = " + mainEquation
    _Display
    _GLRender _Behind
    graph_render_mode = 1 ' 1=solid surface, -1=lines
    glAllow = 1
End Sub

Sub mouseProcess
    Dim x As Double
    Dim y As Double
    While _MouseInput
        If (zoomFactor > 0.1) Then
            zoomFactor = zoomFactor + _MouseWheel * 0.05
        Else
            zoomFactor = 0.11
        End If
    Wend
    If (_MouseButton(1)) Then
        x = _MouseX
        y = _MouseY
        While _MouseButton(1)
            While _MouseInput: Wend
            yRot = yRot + (_MouseX - x)
            xRot = xRot + (_MouseY - y)
            x = _MouseX
            y = _MouseY
        Wend
    End If
    If (_MouseButton(2)) Then
        glAllow = 0
    End If
End Sub

Sub keyProcess
    Dim k As Integer
    k = _KeyHit
    If (k = Asc(" ")) Then graph_render_mode = graph_render_mode * -1
    _KeyClear
End Sub

Sub generatePlot (TheExpression As String)
    Dim x As Integer
    Dim z As Integer
    Dim i As Integer
    Dim ca As String
    Dim ex As String
    For x = -50 To 50
        For z = -50 To 50
            ex = ""
            For i = 1 To Len(TheExpression)
                ca = Mid$(TheExpression, i, 1)
                If (LCase$(ca) = "x") Then ca = _Trim$("(" + Str$(x * stepFactor) + ")")
                If (LCase$(ca) = "y") Then ca = _Trim$("(" + Str$(z * stepFactor) + ")")
                ex = ex + ca
            Next
            vert(x + 50, z + 50) = zStretch * Val(SxriptEval(ex))
        Next
    Next
End Sub

Sub setShades
    Dim x As Integer
    Dim z As Integer
    Dim c As _Unsigned Long
    For x = -50 To 50
        For z = -50 To 50
            c = hsb(map(z, -50, 50, 0, 255), 255, 128, 255)
            shadeMap(x + 50, z + 50).r = _Red(c) / 255
            shadeMap(x + 50, z + 50).g = _Green(c) / 255
            shadeMap(x + 50, z + 50).b = _Blue(c) / 255
        Next
    Next
End Sub

Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function

Rem $INCLUDE: 'sxript.bm'
Rem $Include: 'sxmath.bm'
