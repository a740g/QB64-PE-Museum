'#######################
' aKFrameWork v1.012
'  A Qb64 Framework
'      library
'#######################
'Copyright © 2016-17 by Ashish Kushwaha
'Last Update on 12:24 PM 7/22/2016
'Any suggestion or bug about this library are always welcome
'find me at http://www.qb64.net/forum

' Changes by a740g to work with QBPE

'$INCLUDE:'akFrameWork_Global.bas'

'roundBox v1.000
' By Ashish
' 2016-17 Copyright Ashish
Sub roundBox (x1, y1, nWidth, nHeight, r!, c&)
    Dim As Single p, p2, p3

    p = r! / 2 - 1
    p2 = r! / 2 + 1
    p3 = r! / 3
    Color c&
    Line (x1 + p2 - 1, y1)-(x1 + nWidth - p3, y1)
    Line (x1 + p2 - 1, y1 + nHeight)-(x1 + nWidth - p3, y1 + nHeight)
    Line (x1 - p2, y1 + r!)-(x1 - p2, y1 + nHeight - r!)
    Line (x1 + nWidth + p2 + 1, y1 + r!)-(x1 + nWidth + p2 + 1, y1 + nHeight - r!)
    Circle (x1 + p, y1 + r!), r!, , 1.5, 3.3
    Circle (x1 + p, y1 + nHeight - r!), r!, , 2.9, 4.8
    Circle (x1 + nWidth - p, y1 + r!), r!, , 0, 1.8
    Circle (x1 + nWidth - p, y1 + nHeight - r!), r!, , 4.7, 6.2
End Sub

Function aKStrLength& (s As String)
    aKStrLength = Len(RTrim$(s))
End Function

Function aKNumLength& (n As Long)
    aKNumLength = Len(LTrim$(RTrim$(Str$(n))))
End Function

Function aKNewdialog (sTitle As String, nWidth, nHeight)
    Dim As Single i

    i = aKDialogLength
    aKDialog(i).caption = sTitle
    aKDialog(i).h = nHeight
    aKDialog(i).w = nWidth
    aKDialog(i).shown = 0
    aKDialogLength = aKDialogLength + 1
    aKNewdialog = i
    ReDim _Preserve aKDialog(i + 1) As aKdialogType
End Function

Sub akDialogShow (id) Static
    Dim As Single x, y, x1, y1, i, a, wx, wy, px, n
    Dim As Long tmp, ps

    aKDialog(id).background = _CopyImage(0)
    x = _Width / 2
    y = _Height / 2
    x1 = aKDialog(id).w / 2
    y1 = aKDialog(id).h / 2
    If Not aKDialog(id).save And aKDialog(id).hasAnimation Then
        aKDialog(id).save = -1: aKDialog(id).noShadow = -1: tmp& = _NewImage(_Width, _Height, 32)
        aKDialog(id).content = _NewImage(aKDialog(id).w + 1, aKDialog(id).h + 1, 32)
        _Dest tmp&
        akDialogShow id
        _Dest aKDialog(id).content
        _PutImage (0, 0), tmp&, , (aKDialog(id).Wx, aKDialog(id).Wy - 25)-(aKDialog(id).Wx + aKDialog(id).w, aKDialog(id).h + aKDialog(id).Wy - 25)
        _Dest 0
        _FreeImage tmp&
        aKRunAnimation id
        aKDialog(id).noShadow = 0
    End If
    'box shadow
    If aKDialog(id).noShadow Then GoTo noshadow
    i = 21: a = i
    Do While i > 0
        Line (x - x1 - 21 + i, y - y1 - 21 + i)-(x - x1 - 21 + i, y + y1 + 21 - i), _RGBA(0, 0, 0, a * 6)
        Line (x + x1 + 21 - i, y - y1 - 21 + i)-(x + x1 + 21 - i, y + y1 + 21 - i), _RGBA(0, 0, 0, a * 6)
        Line (x - x1 - 20 + i, y - y1 - 21 + i)-(x + x1 + 20 + -i, y - y1 - 21 + i), _RGBA(0, 0, 0, a * 6)
        Line (x - x1 - 20 + i, y + y1 + 21 - i)-(x + x1 + 20 + -i, y + y1 + 21 - i), _RGBA(0, 0, 0, a * 6)
        i = i - 1: a = a - 3
    Loop
    noshadow:

    'Dialog Box
    Line (x - x1, y - y1)-(x + x1, y + y1), _RGB(230, 230, 230), BF
    Line (x - x1, y - y1)-(x + x1, y + y1), _RGB(0, 0, 255), B
    'Title Bar
    Line ((x - x1) + 1, (y - y1) + 1)-((x + x1) - 1, (y - y1) + 25), _RGB(255, 255, 255), BF
    Color _RGB(0, 0, 0), _RGB(255, 255, 255)
    _PrintString ((x - x1) + 10, (y - y1) + 6), RTrim$(aKDialog(id).caption)
    'close button
    Line ((x + x1) - 1, (y - y1) + 1)-((x + x1) - 30, (y - y1) + 25), _RGB(220, 0, 0), BF
    Color _RGB(255, 255, 255), _RGB(220, 0, 0)
    _PrintString ((x + x1) - 18, (y - y1) + 5), "x"
    aKDialog(id).Cx2 = (x + x1) - 1: aKDialog(id).Cy = (y - y) + 1
    aKDialog(id).Cx = (x + x1) - 30: aKDialog(id).Cy2 = (y - y1) + 25
    'labels
    wx = (x - x1): wy = (y - y1) + 25
    aKDialog(id).Wx = wx: aKDialog(id).Wy = wy
    For i = 1 To aKlabelLength
        If aKLabel(i).id = id Then
            aKDrawObject id, aKLabel, i
        End If
    Next
    'buttons
    For i = 1 To aKButtonLength
        If aKButton(i).id = id Then
            aKDrawObject id, aKButton, i
        End If
    Next
    'check boxes
    For i = 1 To aKCheckBoxLength
        If aKCheckBox(i).id = id Then
            aKDrawObject id, aKCheckBox, i
        End If
    Next
    'radio buttons
    For i = 1 To aKRadioLength
        If aKRadioButton(i).id = id Then
            aKDrawObject id, aKRadioButton, i
        End If
    Next
    'Link labels
    For i = 1 To aKLinklabelLength
        If aKLinkLabel(i).id = id Then
            aKDrawObject id, aKLinkLabel, i
        End If
    Next
    'Combo Boxes
    For i = 1 To aKComboBoxLength
        If aKComboBox(i).id = id Then
            aKDrawObject id, aKComboBox, i
        End If
    Next
    'textbox
    For i = 1 To aKTextBoxLength
        If aKTextBox(i).id = id Then
            aKDrawObject id, aKTextBox, i
        End If
    Next
    'Numeric Up and Down
    For i = 1 To aKNumericUDLength
        If aKNumericUpDown(i).id = id Then
            aKDrawObject id, aKNumericUpDown, i
        End If
    Next
    'pictures
    For i = 1 To aKPictureLength
        If aKPicture(i).id = id Then
            aKDrawObject id, aKPicture, i
        End If
    Next
    'dividers
    For i = 1 To aKDividerLength
        If aKDivider(i).id = id Then
            aKDrawObject id, aKDivider, i
        End If
    Next
    'panels
    For i = 1 To aKPanelLength
        If aKPanel(i).id = id Then
            aKDrawObject id, aKPanel, i
        End If
    Next
    'progress bars
    For i = 1 To aKProgressBarLength
        If aKProgressBar(i).id = id Then
            Line (wx + aKProgressBar(i).x, wy + aKProgressBar(i).y)-(wx + aKProgressBar(i).x + aKProgressBar(i).w, wy + aKProgressBar(i).y + 20), _RGB(210, 210, 210), BF
            Line (wx + aKProgressBar(i).x, wy + aKProgressBar(i).y)-(wx + aKProgressBar(i).x + aKProgressBar(i).w, wy + aKProgressBar(i).y + 20), _RGB(0, 0, 0), B
            px = aKProgressBar(i).w - 2
            ps& = _NewImage(px, 19, 32)
            _Dest ps&
            Line (0, 0)-(px, 19), _RGB(0, 155, 0), BF
            For n = -px To px Step 10
                Line (n, 0)-(n + px, 400), _RGB(0, 255, 0)
            Next

            For n = -px To px Step 20
                Paint (n + 2, 1), _RGB(0, 255, 0), _RGB(0, 255, 0)
                Paint (n + 5, 18), _RGB(0, 255, 0), _RGB(0, 255, 0)
            Next
            aKProgressBar(i).bar = ps&
            _Dest 0
        End If
    Next
    'tooltips
    For i = 1 To aKTooltipLength
        If aKTooltip(i).id = id Then
            aKDrawObject id, aKTooltip, i
        End If
    Next
    'finishing touch.....
    _Dest 0: _Source 0: _Display
    aKDialog(id).Wx = wx: aKDialog(id).Wy = wy
End Sub


Sub aKError (routine$, ErrorCode)
    Screen 0
    Cls , 4
    Color 15, 4
    Print "aKFrameWork gets the following error : "
    Print: Print
    Print "An error occured while calling " + routine$ + " because"
    Select Case ErrorCode
        Case 256
            Print "the handle of the dialog is not in use. " + routine$: Print "works only when it is in use."
        Case 255
            Print "file not found."
        Case 254
            Print "Undefined type has given."
        Case 253
            Print "Invalid handle is given."
    End Select
    Do: _Limit 1: Loop Until InKey$ <> "": System
End Sub

Function aKAddlabel (id, text As String, x, y)
    Dim As Single i

    i = aKlabelLength
    aKLabel(i).text = text
    aKLabel(i).x = x
    aKLabel(i).y = y
    aKLabel(i).id = id
    aKlabelLength = aKlabelLength + 1
    aKAddlabel = i
    ReDim _Preserve aKLabel(i + 1) As aKlabelType
End Function

Function aKAddButton (id, v$, x, y)
    Dim As Single i

    i = aKButtonLength
    aKButton(i).value = v$
    aKButton(i).x = x
    aKButton(i).y = y
    aKButton(i).id = id
    aKAddButton = i
    aKButtonLength = aKButtonLength + 1
    ReDim _Preserve aKButton(i + 1) As aKButtonType
End Function

Function aKAddCheckBox (id, t$, x, y)
    Dim As Single i

    i = aKCheckBoxLength
    aKCheckBox(i).text = t$
    aKCheckBox(i).x = x
    aKCheckBox(i).y = y
    aKCheckBox(i).id = id
    aKAddCheckBox = aKCheckBoxLength
    aKCheckBoxLength = aKCheckBoxLength + 1
    ReDim _Preserve aKCheckBox(i + 1) As akCheckBoxType
End Function

Function aKAddRadioButton (id, t$, x, y, gid)
    Dim As Single i

    i = aKRadioLength
    aKRadioButton(i).text = t$
    aKRadioButton(i).x = x
    aKRadioButton(i).y = y
    aKRadioButton(i).groupId = gid
    aKRadioButton(i).id = id
    aKAddRadioButton = i
    aKRadioLength = aKRadioLength + 1
    ReDim _Preserve aKRadioButton(i + 1) As akRadioButtonType
End Function

Function aKAddLinklabel (id, t$, x, y)
    Dim As Single i

    i = aKLinklabelLength
    aKLinkLabel(i).text = t$
    aKLinkLabel(i).x = x
    aKLinkLabel(i).y = y
    aKLinkLabel(i).id = id
    aKAddLinklabel = i
    aKLinklabelLength = aKLinklabelLength + 1
    ReDim _Preserve aKLinkLabel(i + 1) As aKLinklabelType
End Function

Function aKAddComboBox (id, v$, o$, x, y)
    Dim As Single i

    i = aKComboBoxLength
    aKComboBox(i).value = v$
    aKComboBox(i).options = o$
    aKComboBox(i).x = x
    aKComboBox(i).y = y
    aKComboBox(i).id = id
    aKAddComboBox = i
    aKComboBoxLength = aKComboBoxLength + 1
    ReDim _Preserve aKComboBox(i + 1) As aKComboBoxType
End Function

Function aKAddTextBox (id, v$, p$, x, y, nWidth, typ)
    Dim As Single i

    i = aKTextBoxLength
    aKTextBox(i).value = v$
    aKTextBox(i).placeholder = p$
    aKTextBox(i).x = x
    aKTextBox(i).y = y
    aKTextBox(i).w = nWidth
    aKTextBox(i).typ = typ
    aKTextBox(i).id = id
    aKAddTextBox = i
    aKTextBoxLength = aKTextBoxLength + 1
    ReDim _Preserve aKTextBox(i + 1) As aKTextboxType
End Function

Function aKAddNumericUpDown (id, v, x, y, nwidth)
    Dim As Single i

    i = aKNumericUDLength
    aKNumericUpDown(i).value = v
    aKNumericUpDown(i).x = x
    aKNumericUpDown(i).y = y
    aKNumericUpDown(i).w = nwidth
    aKNumericUpDown(i).id = id
    aKAddNumericUpDown = i
    aKNumericUDLength = aKNumericUDLength + 1
    ReDim _Preserve aKNumericUpDown(i + 1) As aKNumericUpDownType
End Function

Function aKAddProgressBar (id, x, y, nWidth, value, active)
    Dim As Single i

    i = aKProgressBarLength
    aKProgressBar(i).x = x
    aKProgressBar(i).y = y
    aKProgressBar(i).w = nWidth
    aKProgressBar(i).value = value
    aKProgressBar(i).active = active
    aKProgressBar(i).id = id
    aKProgressBarLength = aKProgressBarLength + 1
    aKAddProgressBar = i
    ReDim _Preserve aKProgressBar(i + 1) As aKProgressBarType
End Function

Function aKAddTooltip (id, typ, object, t$)
    Dim As Single i

    i = aKTooltipLength
    Select Case typ
        Case aKLabel
            aKLabel(object).tooltip = -1
            aKLabel(object).tId = i
            aKTooltip(i).text = t$
            aKTooltip(i).id = id
        Case aKButton
            aKButton(object).tooltip = -1
            aKButton(object).tId = i
            aKTooltip(i).text = t$
            aKTooltip(i).id = id
        Case aKLinkLabel
            aKLinkLabel(object).tooltip = -1
            aKLinkLabel(object).tId = i
            aKTooltip(i).text = t$
            aKTooltip(i).id = id
        Case aKPicture
            aKPicture(object).tooltip = -1
            aKPicture(object).tid = i
            aKTooltip(i).text = t$
            aKTooltip(i).id = id
        Case Else
            aKError "aKAddToolip", 254
    End Select
    aKTooltipLength = aKTooltipLength + 1
    ReDim _Preserve aKTooltip(i + 1) As aKTooltipType
End Function

Function aKAddPanel (id, x, y, nWidth, nHeight, title$)
    Dim As Single i

    i = aKPanelLength
    aKPanel(i).id = id
    aKPanel(i).x = x
    aKPanel(i).y = y
    aKPanel(i).w = nWidth
    aKPanel(i).h = nHeight
    aKPanel(i).title = title$

    aKPanelLength = aKPanelLength + 1

    aKAddPanel = i

    ReDim _Preserve aKPanel(i + 1) As aKPanelType
End Function

Function aKAddDivider (id, x, y, typ, size)
    Dim As Single i

    i = aKDividerLength
    aKDivider(i).id = id
    aKDivider(i).x = x
    aKDivider(i).y = y
    If Not typ = aKVertical And Not typ = aKHorizontal Then aKError "aKAddDivider", 254
    aKDivider(i).typ = typ
    aKDivider(i).size = size

    aKDividerLength = aKDividerLength + 1

    aKAddDivider = i

    ReDim _Preserve aKDivider(i + 1) As aKDividerType
End Function

Function aKAddPicture (id, x, y, nWidth, nHeight, img&)
    Dim As Single i

    i = aKPictureLength
    aKPicture(i).id = id
    aKPicture(i).x = x
    aKPicture(i).y = y
    aKPicture(i).h = nHeight
    aKPicture(i).w = nWidth
    aKPicture(i).img = img&

    aKPictureLength = aKPictureLength + 1

    aKAddPicture = i

    ReDim _Preserve aKPicture(i + 1) As aKPictureType
End Function

Sub aKCheck (id) Static
    Dim As Single i, s, q, e, n

    If Not aKDialog(id).shown And Not aKDialog(id).closed Then akDialogShow id: aKDialog(id).shown = -1
    Do
        aKMouse.movement = _MouseInput

        For i = 1 To aKProgressBarLength
            If aKProgressBar(i).active And aKProgressBar(i).id = id Then
                If aKProgressBar(i).oldValue <> aKProgressBar(i).value / 100 * aKProgressBar(i).w Then
                    If aKProgressBar(i).oldValue <= aKProgressBar(i).value Then s = 1 Else s = -1
                    q = aKProgressBar(i).value / 100 * aKProgressBar(i).w
                    e = aKProgressBar(i).oldValue / 100 * aKProgressBar(i).w
                    For n = e To q Step s
                        _PutImage (aKDialog(id).Wx + aKProgressBar(i).x + 1, aKDialog(id).Wy + aKProgressBar(i).y + 1), aKProgressBar(i).bar
                        Line (aKDialog(id).Wx + aKProgressBar(i).x + 1 + n, aKDialog(id).Wy + aKProgressBar(i).y + 1)-(aKDialog(id).Wx + aKProgressBar(i).x + aKProgressBar(i).w - 1, aKDialog(id).Wy + aKProgressBar(i).y + 19), _RGB(210, 210, 210), BF
                        _Limit 100
                        _Display
                    Next
                    aKProgressBar(i).oldValue = aKProgressBar(i).value
                End If
                aKProgressBar(i).active = 0
                Exit Do
            End If
        Next
        If aKMouse.movement Then
            aKMouse.x = _MouseX: aKMouse.y = _MouseY
            If _MouseButton(1) Then aKMouse.Lclick = -1 Else aKMouse.Lclick = 0
            If _MouseButton(2) Then aKMouse.Rclick = -1 Else aKMouse.Rclick = 0
            Exit Do
        End If
    Loop
End Sub

Sub aKUpdate (id)
    Dim As Long tmp, tmp2, tmp4, cursor
    Dim As Single ox, oy, dx, dy, i, n, cursorX, cursorY, limit, strpos, strlen, s1, s2, start, l, c, g, o, p, a
    Dim As String tmpstr, tmpstr2, k, ca, sO

    If Not aKDialog(id).shown And Not aKDialog(id).closed Then akDialogShow id: aKDialog(id).shown = -1
    'close of dialog
    If Not aKDialog(id).closed Then
        If aKMouse.x > aKDialog(id).Cx And aKMouse.x < aKDialog(id).Cx2 And aKMouse.y > aKDialog(id).Cy And aKMouse.y < aKDialog(id).Cy2 And aKMouse.Lclick Then aKHideDialog id: Exit Sub
        'draging feature (suggested by Fellippe )
        If aKMouse.x > aKDialog(id).Wx And aKMouse.x < aKDialog(id).Cx - 30 And aKMouse.y > aKDialog(id).Wy - 25 And aKMouse.y < aKDialog(id).Wy Then
            If Not RTrim$(aKMouse.icon) = "move" Then aKMouse.icon = "move": glutSetCursor 5
            If aKMouse.Lclick Then
                tmp& = _NewImage(aKDialog(id).w + 1, aKDialog(id).h + 1, 32)
                tmp2& = _CopyImage(0)
                _Dest tmp&
                _PutImage (0, 0), 0, tmp&, (aKDialog(id).Wx, aKDialog(id).Wy - 25)-(aKDialog(id).Wx + aKDialog(id).w + 8, aKDialog(id).Wy + aKDialog(id).h - 25)
                _Dest 0
                ox = (aKDialog(id).Wx - _MouseX)
                oy = (aKDialog(id).Wy - _MouseY) - 25

                _SetAlpha 122, , tmp&
                Do
                    While _MouseInput: Wend
                    If _MouseButton(1) Then
                        _PutImage , tmp2&
                        _PutImage (_MouseX + ox, _MouseY + oy), tmp&
                        _Display
                        dx = _MouseX + ox: dy = _MouseY + oy
                    Else
                        If dx < 1 Then dx = 1
                        If dy < 26 Then dy = 26
                        If dx + aKDialog(id).w > _Width Then dx = _Width - aKDialog(id).w - 2
                        If dy + aKDialog(id).h > _Height Then dy = _Height - aKDialog(id).h
                        aKDialog(id).Wx = dx: aKDialog(id).Wy = dy
                        aKDialog(id).Cx = aKDialog(id).Wx + aKDialog(id).w - 30
                        aKDialog(id).Cx2 = aKDialog(id).Wx + aKDialog(id).w - 1
                        aKDialog(id).Cy = aKDialog(id).Wy - 24: aKDialog(id).Cy2 = aKDialog(id).Wy
                        _SetAlpha 255, , tmp&
                        If aKDialog(id).hasAnimation Then
                            If UCase$(RTrim$(aKDialog(id).transition)) = "FADEWHITE" Then
                                tmp4& = _NewImage(_Width, _Height, 32)
                                _Dest tmp4&: Line (0, 0)-(_Width, _Height), _RGB(255, 255, 255), BF: _Dest 0
                                _SetAlpha 125, , tmp4&: _PutImage , aKDialog(id).background: _PutImage , tmp4&
                                _FreeImage tmp4&
                            ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "FADEBLACK" Then
                                tmp4& = _NewImage(_Width, _Height, 32)
                                _Dest tmp4&: Line (0, 0)-(_Width, _Height), _RGB(0, 0, 0), BF: _Dest 0
                                _SetAlpha 125, , tmp4&: _PutImage , aKDialog(id).background: _PutImage , tmp4&
                                _FreeImage tmp4&
                            ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "FOCUS" Then
                                _PutImage , aKDialog(id).background
                                Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, 120), BF
                            Else
                                _PutImage , aKDialog(id).background
                            End If
                        Else
                            _PutImage , aKDialog(id).background
                        End If
                        aKCreateShadow id
                        _PutImage (aKDialog(id).Wx, aKDialog(id).Wy - 25), tmp&
                        _FreeImage tmp&
                        _FreeImage tmp2&
                        _Display
                        Exit Sub
                    End If
                Loop
            End If
        Else
            If RTrim$(aKMouse.icon) = "move" Then _MouseShow "default": aKMouse.icon = "default"
        End If
        'checking tooltips of labels
        If aKlabelLength > 0 Then
            For i = 1 To aKlabelLength
                If aKHover(id, aKLabel, i) And aKLabel(i).id = id And Not aKLabel(i).hidden Then
                    If aKLabel(i).tooltip And aKTooltip(aKLabel(i).tId).id = id Then
                        If aKMouse.Lclick Then aKTooltip(aKLabel(i).tId).shown = 0: _PutImage , tooltipBg: Exit Sub
                        If Not aKTooltip(aKLabel(i).tId).shown Then tooltipBg = _CopyImage(0)
                        _PutImage , tooltipBg
                        _PutImage (aKMouse.x + 10, aKMouse.y - 3 - _Height(aKTooltip(aKLabel(i).tId).content)), aKTooltip(aKLabel(i).tId).content
                        aKTooltip(aKLabel(i).tId).shown = -1
                    End If
                Else
                    If aKTooltip(aKLabel(i).tId).shown And aKLabel(i).id = id Then aKTooltip(aKLabel(i).tId).shown = 0: _PutImage , tooltipBg&
                End If
            Next
        End If
        'buttons reactions with user

        For i = 1 To aKButtonLength
            If aKHover(id, aKButton, i) And aKButton(i).id = id And Not aKButton(i).hidden Then
                If Not aKButton(i).react Then
                    Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 7.5 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(229, 241, 255), BF
                    Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 7.5 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(0, 0, 255), B
                    Color _RGB(0, 0, 0), _RGB(229, 241, 255)
                    _PrintString (aKDialog(id).Wx + aKButton(i).x + 10, aKDialog(id).Wy + aKButton(i).y + 5), RTrim$(aKButton(i).value)
                    aKButton(i).react = -1
                End If
                'tooltips
                If aKButton(i).tooltip Then
                    If aKMouse.Lclick Then aKTooltip(aKButton(i).tId).shown = 0: _PutImage , tooltipBg: Exit Sub
                    If Not aKTooltip(aKButton(i).tId).shown Then tooltipBg = _CopyImage(0)
                    _PutImage , tooltipBg
                    _PutImage (aKMouse.x + 20, aKMouse.y - 5), aKTooltip(aKButton(i).tId).content
                    aKTooltip(aKButton(i).tId).shown = -1
                End If
            Else
                If aKButton(i).react < 1 And aKButton(i).id = id Then
                    Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 7.5 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(180, 180, 180), BF
                    Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 7.5 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(0, 0, 0), B
                    Color _RGB(0, 0, 0), _RGB(180, 180, 180)
                    _PrintString (aKDialog(id).Wx + aKButton(i).x + 10, aKDialog(id).Wy + aKButton(i).y + 5), RTrim$(aKButton(i).value)
                    aKButton(i).react = aKButton(i).react + 1
                End If
                If aKTooltip(aKButton(i).tId).shown And aKButton(i).id = id Then aKTooltip(aKButton(i).tId).shown = 0: _PutImage , tooltipBg&
            End If
        Next


        For i = 1 To aKLinklabelLength
            If aKHover(id, aKLinkLabel, i) And aKLinkLabel(i).id = id And Not aKLinkLabel(i).hidden Then
                If Not RTrim$(aKMouse.icon) = "link" Then aKMouse.icon = "link": _MouseShow "link"
                If aKClick(id, aKLinkLabel, i) Then
                    Color _RGB(255, 0, 0), _RGB(230, 230, 230)
                    _PrintString (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y), RTrim$(aKLinkLabel(i).text)
                    Line (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y + 14)-(aKDialog(id).Wx + aKLinkLabel(i).x + aKStrLength(aKLinkLabel(i).text) * 8, aKDialog(id).Wy + aKLinkLabel(i).y + 14), _RGB(255, 0, 0)
                    _Display
                    _Delay .1
                    Color _RGB(0, 0, 255)
                    _PrintString (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y), RTrim$(aKLinkLabel(i).text)
                    Line (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y + 14)-(aKDialog(id).Wx + aKLinkLabel(i).x + aKStrLength(aKLinkLabel(i).text) * 8, aKDialog(id).Wy + aKLinkLabel(i).y + 14), _RGB(0, 0, 255)
                End If
                If aKLinkLabel(i).tooltip Then
                    If aKMouse.Lclick Then aKTooltip(aKLinkLabel(i).tId).shown = 0: _PutImage , tooltipBg: Exit Sub
                    If Not aKTooltip(aKLinkLabel(i).tId).shown Then tooltipBg = _CopyImage(0)
                    _PutImage , tooltipBg
                    _PutImage (aKMouse.x + 20, aKMouse.y - 5), aKTooltip(aKLinkLabel(i).tId).content
                    aKTooltip(aKLinkLabel(i).tId).shown = -1
                End If
            Else
                If RTrim$(aKMouse.icon) = "link" And Not aKAnyHover(id, aKLinkLabel) Then aKMouse.icon = "default": _MouseShow "default"
                If aKTooltip(aKLinkLabel(i).tId).shown And aKLinkLabel(i).id = id Then aKTooltip(aKLinkLabel(i).tId).shown = 0: _PutImage , tooltipBg
            End If
        Next

        For i = 1 To aKPictureLength
            If aKHover(id, aKPicture, i) And aKPicture(i).id = id And Not aKPicture(i).hidden Then
                If aKPicture(i).tooltip Then
                    If aKMouse.Lclick Then aKTooltip(aKPicture(i).tid).shown = 0: _PutImage , tooltipBg: Exit Sub
                    If Not aKTooltip(aKPicture(i).tid).shown Then tooltipBg = _CopyImage(0)
                    _PutImage , tooltipBg
                    _PutImage (aKMouse.x + 20, aKMouse.y - 5), aKTooltip(aKPicture(i).tid).content
                    aKTooltip(aKPicture(i).tid).shown = -1
                End If
            Else
                If aKTooltip(aKPicture(i).tid).shown And aKPicture(i).id = id Then aKTooltip(aKPicture(i).tid).shown = 0: _PutImage , tooltipBg
            End If
        Next

        For i = 1 To aKCheckBoxLength
            If aKHover(id, aKCheckBox, i) And aKCheckBox(i).id = id And Not aKCheckBox(i).hidden Then
                If aKMouse.Lclick Then
                    If aKCheckBox(i).checked Then aKCheckBox(i).checked = 0: Line (aKCheckBox(i).x + aKDialog(id).Wx + 3, aKCheckBox(i).y + aKDialog(id).Wy + 3)-(aKCheckBox(i).x + aKDialog(id).Wx + 9, aKCheckBox(i).y + aKDialog(id).Wy + 9), _RGB(255, 255, 255), BF Else aKCheckBox(i).checked = -1: Line (aKCheckBox(i).x + aKDialog(id).Wx + 3, aKCheckBox(i).y + aKDialog(id).Wy + 3)-(aKCheckBox(i).x + aKDialog(id).Wx + 9, aKCheckBox(i).y + aKDialog(id).Wy + 9), _RGB(0, 0, 0), BF
                End If
                If Not aKCheckBox(i).react Then Line (aKDialog(id).Wx + aKCheckBox(i).x, aKDialog(id).Wy + aKCheckBox(i).y)-(aKDialog(id).Wx + aKCheckBox(i).x + 12, aKDialog(id).Wy + aKCheckBox(i).y + 12), _RGB(0, 0, 255), B: aKCheckBox(i).react = -1
            Else
                If aKCheckBox(i).react Then Line (aKDialog(id).Wx + aKCheckBox(i).x, aKDialog(id).Wy + aKCheckBox(i).y)-(aKDialog(id).Wx + aKCheckBox(i).x + 12, aKDialog(id).Wy + aKCheckBox(i).y + 12), _RGB(0, 0, 0), B: aKCheckBox(i).react = 0
            End If
        Next


        For i = 1 To aKRadioLength
            If aKHover(id, aKRadioButton, i) And aKRadioButton(i).id = id And Not aKRadioButton(i).hidden Then
                If aKMouse.Lclick And Not aKRadioButton(i).checked Then
                    For n = 1 To aKRadioLength
                        If aKRadioButton(i).groupId = aKRadioButton(n).groupId And aKRadioButton(n).checked And aKRadioButton(n).id = id Then
                            If Not aKRadioButton(n).hidden Then
                                Paint (aKDialog(id).Wx + aKRadioButton(n).x + 5, aKDialog(id).Wy + aKRadioButton(n).y + 7), _RGB(255, 255, 255), _RGB(0, 0, 0)
                                Circle (aKDialog(id).Wx + aKRadioButton(n).x + 5, aKDialog(id).Wy + aKRadioButton(n).y + 7), 5, _RGB(0, 0, 0)
                                Paint (aKDialog(id).Wx + aKRadioButton(n).x + 5, aKDialog(id).Wy + aKRadioButton(n).y + 7), _RGB(255, 255, 255), _RGB(0, 0, 0)
                            End If
                            aKRadioButton(n).checked = 0
                        End If
                    Next
                    Circle (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), 3, _RGB(8, 8, 8)
                    Paint (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), _RGB(8, 8, 8), _RGB(8, 8, 8)
                    aKRadioButton(i).checked = -1
                End If
                If Not aKRadioButton(i).react Then Circle (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), 5, _RGB(0, 0, 255): aKRadioButton(i).react = -1
            Else
                If aKRadioButton(i).react Then Circle (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), 5, _RGB(0, 0, 0): aKRadioButton(i).react = 0
            End If
        Next


        For i = 1 To aKNumericUDLength
            If aKHover(id, aKNumericUpDown, i) And aKNumericUpDown(i).id = id And Not aKNumericUpDown(i).hidden Then
                If Not aKNumericUpDown(i).react Then
                    Line (aKDialog(id).Wx + aKNumericUpDown(i).x, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(0, 0, 255), B
                    Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 10, aKNumericUpDown(i).y + aKDialog(id).Wy)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 30, aKNumericUpDown(i).y + aKDialog(id).Wy + 13), _RGB(0, 0, 255), B
                    Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 10, aKNumericUpDown(i).y + aKDialog(id).Wy + 13)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 30, aKNumericUpDown(i).y + aKDialog(id).Wy + 25), _RGB(0, 0, 255), B
                    aKNumericUpDown(i).react = -1
                End If
                If aKMouse.x > aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 10 And aKMouse.y > aKNumericUpDown(i).y + aKDialog(id).Wy And aKMouse.x < aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 30 And aKMouse.y < aKNumericUpDown(i).y + aKDialog(id).Wy + 13 Then
                    If aKMouse.Lclick Then
                        aKNumericUpDown(i).value = aKNumericUpDown(i).value + 1
                        Color _RGB(0, 0, 0), _RGBA(255, 255, 255, 255)
                        n = Int(aKNumericUpDown(i).w / 8)
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + 5, aKDialog(id).Wy + aKNumericUpDown(i).y + 6), String$(n, " ")
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + 5, aKDialog(id).Wy + aKNumericUpDown(i).y + 6), LTrim$(RTrim$(Str$(aKNumericUpDown(i).value)))
                    End If
                    If Not aKNumericUpDown(i).react1 Then
                        Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 11, aKNumericUpDown(i).y + aKDialog(id).Wy + 1)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 29, aKNumericUpDown(i).y + aKDialog(id).Wy + 12), _RGB(229, 241, 255), BF
                        Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y - 1), Chr$(30)
                        aKNumericUpDown(i).react1 = -1
                    End If
                Else
                    If aKNumericUpDown(i).react1 Then
                        Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 11, aKNumericUpDown(i).y + aKDialog(id).Wy + 1)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 29, aKNumericUpDown(i).y + aKDialog(id).Wy + 12), _RGB(180, 180, 180), BF
                        Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y - 1), Chr$(30)
                        aKNumericUpDown(i).react1 = 0
                    End If
                End If
                If aKMouse.x > aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 10 And aKMouse.y > aKNumericUpDown(i).y + aKDialog(id).Wy + 13 And aKMouse.x < aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 30 And aKMouse.y < aKNumericUpDown(i).y + aKDialog(id).Wy + 25 Then
                    If aKMouse.Lclick Then
                        aKNumericUpDown(i).value = aKNumericUpDown(i).value - 1
                        Color _RGB(0, 0, 0), _RGBA(255, 255, 255, 255)
                        n = Int(aKNumericUpDown(i).w / 8)
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + 5, aKDialog(id).Wy + aKNumericUpDown(i).y + 6), String$(n, " ")
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + 5, aKDialog(id).Wy + aKNumericUpDown(i).y + 6), LTrim$(RTrim$(Str$(aKNumericUpDown(i).value)))
                    End If
                    If Not aKNumericUpDown(i).react2 Then
                        Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 11, aKNumericUpDown(i).y + aKDialog(id).Wy + 14)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 29, aKNumericUpDown(i).y + aKDialog(id).Wy + 24), _RGB(229, 241, 255), BF
                        Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y + 13), Chr$(31)
                        aKNumericUpDown(i).react2 = -1
                    End If
                Else
                    If aKNumericUpDown(i).react2 Then
                        Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 11, aKNumericUpDown(i).y + aKDialog(id).Wy + 14)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 29, aKNumericUpDown(i).y + aKDialog(id).Wy + 24), _RGB(180, 180, 180), BF
                        Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                        _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y + 13), Chr$(31)
                        aKNumericUpDown(i).react2 = 0
                    End If
                End If
            Else
                If aKNumericUpDown(i).react Then
                    Line (aKDialog(id).Wx + aKNumericUpDown(i).x, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(0, 0, 0), B
                    Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 10, aKNumericUpDown(i).y + aKDialog(id).Wy)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 30, aKNumericUpDown(i).y + aKDialog(id).Wy + 13), _RGB(0, 0, 0), B
                    Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 10, aKNumericUpDown(i).y + aKDialog(id).Wy + 13)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 30, aKNumericUpDown(i).y + aKDialog(id).Wy + 25), _RGB(0, 0, 0), B
                    aKNumericUpDown(i).react = 0
                End If
                If aKNumericUpDown(i).react1 Then
                    Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 11, aKNumericUpDown(i).y + aKDialog(id).Wy + 1)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 29, aKNumericUpDown(i).y + aKDialog(id).Wy + 12), _RGB(180, 180, 180), BF
                    Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                    _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y - 1), Chr$(30)
                    aKNumericUpDown(i).react1 = 0
                End If
                If aKNumericUpDown(i).react2 Then
                    Line (aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 11, aKNumericUpDown(i).y + aKDialog(id).Wy + 14)-(aKNumericUpDown(i).x + aKDialog(id).Wx + aKNumericUpDown(i).w + 29, aKNumericUpDown(i).y + aKDialog(id).Wy + 24), _RGB(180, 180, 180), BF
                    Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                    _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y + 13), Chr$(31)
                    aKNumericUpDown(i).react2 = 0
                End If
            End If
        Next
        'multi-tasking input textbox
        'by Ashish v1.002
        For i = 1 To aKTextBoxLength
            If aKHover(id, aKTextBox, i) And aKTextBox(i).id = id And Not aKTextBox(i).hidden Then
                If Not RTrim$(aKMouse.icon) = "text" Then aKMouse.icon = "text": _MouseShow "text"
                If aKMouse.Lclick Then
                    aKTextBox(i).active = -1
                    aKMouse.icon = "default": _MouseShow "default"
                    cursorX = 4: cursorY = aKDialog(id).Wy + aKTextBox(i).y + 3
                    limit = Int(aKTextBox(i).w - 20) / 8
                    If aKStrLength(aKTextBox(i).value) > limit Then
                        cursorX = limit * 8
                        strpos = aKStrLength(aKTextBox(i).value)
                        strlen = strpos
                        tmpstr$ = Right$(RTrim$(aKTextBox(i).value), limit)
                        aKDrawObject id, aKTextBox, i
                        Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                        _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, cursorY + 3), tmpstr$
                    End If
                    If aKStrLength(aKTextBox(i).value) > 0 And Not aKStrLength(aKTextBox(i).value) > limit Then
                        cursorX = cursorX + aKStrLength(aKTextBox(i).value) * 8: strpos = (cursorX - 4) / 8
                    End If
                    If RTrim$(aKTextBox(i).value) <> "" Then
                        tmpstr2$ = RTrim$(aKTextBox(i).value)
                    End If
                    strlen = aKStrLength(aKTextBox(i).value)
                    s1 = limit: s2 = 0
                    Do
                        k$ = InKey$
                        aKMouse.movement = _MouseInput
                        If aKMouse.movement Then
                            aKMouse.x = _MouseX: aKMouse.y = _MouseY: aKMouse.Lclick = _MouseButton(1): aKMouse.Rclick = _MouseButton(2)
                            If Not aKHover(id, aKTextBox, i) And aKMouse.Lclick Then
                                aKTextBox(i).active = 0
                                aKDrawObject id, aKTextBox, i
                                If Not RTrim$(aKTextBox(i).value) = "" Then
                                    Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                                    If Not aKTextBox(i).typ = aKPassword Then _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, cursorY + 3), Left$(aKTextBox(i).value, limit) Else _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, cursorY + 3), Left$(tmpstr$, limit)
                                End If
                                Exit Sub
                            End If
                        End If
                        If k$ <> "" Then
                            Select Case k$
                                Case Chr$(0) + Chr$(75)
                                    If strpos > 0 Then
                                        If Not strlen > limit Then
                                            aKDrawObject id, aKTextBox, i
                                            strpos = strpos - 1
                                            cursorX = cursorX - 8
                                        End If
                                    End If
                                Case Chr$(0) + Chr$(77)
                                    If strpos < strlen Then
                                        If Not strpos > limit Then
                                            aKDrawObject id, aKTextBox, i
                                            strpos = strpos + 1
                                            cursorX = cursorX + 8
                                        End If
                                    End If
                                Case Chr$(13)
                                    aKTextBox(i).active = 0
                                    aKDrawObject id, aKTextBox, i
                                    _Display
                                    Exit For
                                Case Chr$(8)
                                    If strpos = strlen And strpos > 0 Then
                                        tmpstr$ = Left$(tmpstr2$, Len(tmpstr2$) - 1)
                                        tmpstr2$ = tmpstr$
                                        aKTextBox(i).value = tmpstr2$
                                        aKDrawObject id, aKTextBox, i
                                        cursorX = cursorX - 8
                                        strpos = strpos - 1
                                        strlen = strlen - 1
                                        If strlen > limit - 1 Then tmpstr$ = Right$(tmpstr2$, limit): cursorX = cursorX + 8
                                    ElseIf strpos > 0 And strpos < strlen Then
                                        tmpstr$ = Left$(tmpstr2$, strpos - 1) + Mid$(tmpstr2$, strpos + 1, strlen - strpos)
                                        tmpstr2$ = tmpstr$
                                        aKTextBox(i).value = tmpstr2$
                                        aKDrawObject id, aKTextBox, i
                                        cursorX = cursorX - 8
                                        strpos = strpos - 1
                                        strlen = strlen - 1
                                    End If
                                Case Else
                                    If strpos = strlen Then
                                        tmpstr$ = tmpstr2$ + k$
                                        tmpstr2$ = tmpstr$
                                        aKTextBox(i).value = tmpstr2$
                                        aKDrawObject id, aKTextBox, i
                                        cursorX = cursorX + 8
                                        strpos = strpos + 1
                                        strlen = strlen + 1
                                        If strlen > limit Then tmpstr$ = Right$(tmpstr$, limit): cursorX = cursorX - 8: s1 = s1 + 1
                                    ElseIf strpos = 0 Then
                                        tmpstr$ = k$ + tmpstr2$
                                        tmpstr2$ = tmpstr$
                                        aKTextBox(i).value = tmpstr2$
                                        aKDrawObject id, aKTextBox, i
                                        cursorX = cursorX + 8
                                        strpos = strpos + 1
                                        strlen = strlen + 1
                                    Else
                                        tmpstr$ = Left$(tmpstr2$, strpos) + k$ + Mid$(tmpstr2$, strpos + 1, strlen - strpos)
                                        tmpstr2$ = tmpstr$
                                        aKTextBox(i).value = tmpstr2$
                                        aKDrawObject id, aKTextBox, i
                                        cursorX = cursorX + 8
                                        strpos = strpos + 1
                                        strlen = strlen + 1
                                        If strlen > limit Then tmpstr$ = Mid$(tmpstr2$, Len(tmpstr2$) - limit, s2)
                                    End If
                            End Select
                            Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                            If aKTextBox(i).typ = aKPassword Then tmpstr$ = String$(Len(tmpstr$), "*")
                            _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, cursorY + 3), tmpstr$
                        End If

                        Line (aKDialog(id).Wx + aKTextBox(i).x + cursorX, cursorY)-(aKDialog(id).Wx + aKTextBox(i).x + cursorX, cursorY + 18), cursor&

                        If Timer > start! + .3 Then
                            start! = Timer
                            If cursor& = _RGB(255, 255, 255) Then cursor& = _RGB(0, 0, 0) Else cursor& = _RGB(255, 255, 255)
                        End If
                        _Display
                    Loop
                End If
                If Not aKTextBox(i).react Then Line (aKDialog(id).Wx + aKTextBox(i).x, aKDialog(id).Wy + aKTextBox(i).y)-(aKDialog(id).Wx + aKTextBox(i).x + aKTextBox(i).w, aKDialog(id).Wy + aKTextBox(i).y + 25), _RGB(0, 0, 255), B: aKTextBox(i).react = -1
            Else
                If RTrim$(aKMouse.icon) = "text" And Not aKAnyHover(id, aKTextBox) And aKTextBox(i).id = id Then aKMouse.icon = "default": _MouseShow "default"
                If aKTextBox(i).react Then Line (aKDialog(id).Wx + aKTextBox(i).x, aKDialog(id).Wy + aKTextBox(i).y)-(aKDialog(id).Wx + aKTextBox(i).x + aKTextBox(i).w, aKDialog(id).Wy + aKTextBox(i).y + 25), _RGB(0, 0, 0), B: aKTextBox(i).react = 0
            End If
        Next

        'displaying options when user click combo box
        For i = 1 To aKComboBoxLength
            If aKHover(id, aKComboBox, i) And aKComboBox(i).id = id And Not aKComboBox(i).hidden Then
                If aKClick(id, aKComboBox, i) Then
                    If aKComboBox(i).active Then aKComboBox(i).active = 0: Exit For
                    aKComboBox(i).active = -1
                    sO = RTrim$(aKComboBox(i).options)
                    l = 1 ' this loop will calculate dropdown menu height and width in l and g variable
                    'use commas to separate your options
                    optionsBg = _CopyImage(0)
                    For n = 1 To Len(sO)
                        ca$ = Mid$(sO, n, 1)
                        c = c + 1
                        If ca$ = "," Then l = l + 1: c = 0
                        If g < c Then g = c
                    Next
                    dx = (g * 8 + 10) / 2 'dropdown width
                    dy = l * 15 + 10 'dropdown height
                    'holding options into array
                    c = 0: o = 1: p = 1: a = 0
                    Dim options(l) As String, optionsY(l)
                    For n = 1 To Len(sO)
                        ca$ = Mid$(sO, n, 1)
                        If ca$ = "," Then o = o + 1: ca$ = ""
                        options(o) = options(o) + ca$
                    Next
                    For n = 1 To l
                        optionsY(n) = aKDialog(id).Wy + aKComboBox(i).y + a + 28
                        a = a + 15
                    Next
                    For n = 1 To dy
                        Line (aKComboBox(i).x + aKDialog(id).Wx, aKComboBox(i).y + aKDialog(id).Wy + 23)-(aKComboBox(i).x + aKDialog(id).Wx + dx + aKStrLength(aKComboBox(i).value) * 8 + 30, aKComboBox(i).y + aKDialog(id).Wy + n + 23), _RGB(255, 255, 255), BF
                        Line (aKComboBox(i).x + aKDialog(id).Wx, aKComboBox(i).y + aKDialog(id).Wy + 23)-(aKComboBox(i).x + aKDialog(id).Wx + dx + aKStrLength(aKComboBox(i).value) * 8 + 30, aKComboBox(i).y + aKDialog(id).Wy + n + 23), _RGB(0, 0, 0), B
                        _Display
                    Next
                    For n = 1 To l
                        Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                        _PrintString (aKComboBox(i).x + aKDialog(id).Wx + 5, optionsY(n)), options(n)
                    Next
                    Do
                        aKCheck id
                        aKUpdate id
                        If aKDialog(id).closed Then Exit Do
                        If Not aKComboBox(i).active Then _PutImage , optionsBg: Exit Do
                        If aKMouse.x < aKComboBox(i).x + aKDialog(id).Wx And aKMouse.Lclick Or aKMouse.x > aKComboBox(i).x + aKDialog(id).Wx + aKStrLength(aKComboBox(i).value) * 8 + 30 And aKMouse.Lclick And aKMouse.y < aKComboBox(i).y + aKDialog(id).Wy + 23 Or aKMouse.y < aKComboBox(i).y + aKDialog(id).Wy And aKMouse.Lclick Or aKMouse.y > aKComboBox(i).y + aKDialog(id).Wy + dy + 23 And aKMouse.Lclick Or aKMouse.x > aKComboBox(i).x + aKDialog(id).Wx + dx + aKStrLength(aKComboBox(i).value) * 8 + 30 And aKMouse.y > aKComboBox(i).y + aKDialog(id).Wy + 23 And aKMouse.Lclick Then _PutImage , optionsBg: aKComboBox(i).active = 0: Exit Do
                        For n = 1 To l
                            If aKMouse.x > aKComboBox(i).x + aKDialog(id).Wx And aKMouse.y > optionsY(n) And aKMouse.x < aKComboBox(i).x + aKDialog(id).Wx + dx + aKStrLength(aKComboBox(i).value) * 8 + 30 And aKMouse.y < optionsY(n) + 15 Then
                                If aKMouse.Lclick Then
                                    _PutImage , optionsBg: aKComboBox(i).active = 0
                                    Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                                    Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(230, 230, 230), BF
                                    aKComboBox(i).value = options(n)
                                    Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(255, 255, 255), BF
                                    Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 0), B
                                    Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(180, 180, 180), BF
                                    Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 0), B
                                    _PrintString (aKDialog(id).Wx + aKComboBox(i).x + 5, aKDialog(id).Wy + aKComboBox(i).y + 5), RTrim$(aKComboBox(i).value)
                                    Color , _RGBA(0, 0, 0, 0)
                                    _PrintString (aKDialog(id).Wx + aKComboBox(i).x + 19 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 6), Chr$(31)
                                    optionsBg = _CopyImage(0)
                                    _PutImage , optionsBg
                                    Exit Do
                                End If
                                Line (aKComboBox(i).x + aKDialog(id).Wx + 1, optionsY(n))-(aKComboBox(i).x + aKDialog(id).Wx + dx + aKStrLength(aKComboBox(i).value) * 8 + 30 - 1, optionsY(n) + 15), _RGB(0, 0, 255), BF
                                Color _RGB(255, 255, 255), _RGB(0, 0, 255)
                                _PrintString (aKComboBox(i).x + aKDialog(id).Wx + 5, optionsY(n)), options(n)
                            Else
                                Line (aKComboBox(i).x + aKDialog(id).Wx + 1, optionsY(n))-(aKComboBox(i).x + aKDialog(id).Wx + dx + aKStrLength(aKComboBox(i).value) * 8 + 30 - 1, optionsY(n) + 15), _RGB(255, 255, 255), BF
                                Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                                _PrintString (aKComboBox(i).x + aKDialog(id).Wx + 5, optionsY(n)), options(n)
                            End If
                        Next
                        _Display
                    Loop
                End If
                If Not aKComboBox(i).react Then
                    Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 255), B
                    Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(229, 241, 255), BF
                    Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 255), B
                    Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                    _PrintString (aKDialog(id).Wx + aKComboBox(i).x + 19 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 6), Chr$(31)
                    aKComboBox(i).react = -1
                End If
            Else
                If aKComboBox(i).react Then
                    Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 0), B
                    Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(180, 180, 180), BF
                    Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 0), B
                    Color _RGB(0, 0, 0), _RGBA(0, 0, 0, 0)
                    _PrintString (aKDialog(id).Wx + aKComboBox(i).x + 19 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 6), Chr$(31)
                    aKComboBox(i).react = 0
                End If
            End If
        Next
    End If


End Sub

Sub aKHideDialog (id)

    _PutImage , aKDialog(id).background
    aKDialog(id).shown = 0: aKDialog(id).closed = -1
End Sub

Function aKClick (id, typ, object)

    Select Case typ
        Case aKLabel
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKButton
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKCheckBox
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKRadioButton
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKLinkLabel
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKComboBox
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKNumericUpDown
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKTextBox
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case aKPicture
            If aKHover(id, typ, object) And aKMouse.Lclick Then aKClick = -1
        Case Else
            aKError "aKClick", 254
    End Select
End Function

Function aKHover (id, typ, object)

    Select Case typ
        Case aKLabel
            If aKMouse.x > aKLabel(object).x + aKDialog(id).Wx And aKMouse.y > aKLabel(object).y + aKDialog(id).Wy And aKMouse.x < aKLabel(object).x + aKDialog(id).Wx + aKStrLength(aKLabel(object).text) * 8 And aKMouse.y < aKLabel(object).y + aKDialog(id).Wy + 15 Then aKHover = -1
        Case aKButton
            If aKMouse.x > aKButton(object).x + aKDialog(id).Wx And aKMouse.y > aKButton(object).y + aKDialog(id).Wy And aKMouse.x < aKButton(object).x + aKDialog(id).Wx + aKStrLength(aKButton(object).value) * 7.5 + 20 And aKMouse.y < aKButton(object).y + aKDialog(id).Wy + 23 Then aKHover = -1
        Case aKCheckBox
            If aKMouse.x > aKCheckBox(object).x + aKDialog(id).Wx And aKMouse.y > aKCheckBox(object).y + aKDialog(id).Wy And aKMouse.x < aKCheckBox(object).x + aKDialog(id).Wx + aKStrLength(aKCheckBox(object).text) * 8 + 20 And aKMouse.y < aKCheckBox(object).y + aKDialog(id).Wy + 15 Then aKHover = -1
        Case aKRadioButton
            If aKMouse.x > aKRadioButton(object).x + aKDialog(id).Wx And aKMouse.y > aKRadioButton(object).y + aKDialog(id).Wy And aKMouse.x < aKRadioButton(object).x + aKDialog(id).Wx + aKStrLength(aKRadioButton(object).text) * 8 + 20 And aKMouse.y < aKRadioButton(object).y + aKDialog(id).Wy + 15 Then aKHover = -1
        Case aKLinkLabel
            If aKMouse.x > aKLinkLabel(object).x + aKDialog(id).Wx And aKMouse.y > aKLinkLabel(object).y + aKDialog(id).Wy And aKMouse.x < aKLinkLabel(object).x + aKDialog(id).Wx + aKStrLength(aKLinkLabel(object).text) * 8 And aKMouse.y < aKLinkLabel(object).y + aKDialog(id).Wy + 18 Then aKHover = -1
        Case aKComboBox
            If aKMouse.x > aKComboBox(object).x + aKDialog(id).Wx And aKMouse.y > aKComboBox(object).y + aKDialog(id).Wy And aKMouse.x < aKComboBox(object).x + aKDialog(id).Wx + aKStrLength(aKComboBox(object).value) * 8 + 30 And aKMouse.y < aKComboBox(object).y + aKDialog(id).Wy + 23 Then aKHover = -1
        Case aKTextBox
            If aKMouse.x > aKTextBox(object).x + aKDialog(id).Wx And aKMouse.y > aKTextBox(object).y + aKDialog(id).Wy And aKMouse.x < aKTextBox(object).x + aKDialog(id).Wx + aKTextBox(object).w And aKMouse.y < aKTextBox(object).y + aKDialog(id).Wy + 25 Then aKHover = -1
        Case aKNumericUpDown
            If aKMouse.x > aKNumericUpDown(object).x + aKDialog(id).Wx And aKMouse.y > aKNumericUpDown(object).y + aKDialog(id).Wy And aKMouse.x < aKNumericUpDown(object).x + aKDialog(id).Wx + aKNumericUpDown(object).w + 30 And aKMouse.y < aKNumericUpDown(object).y + aKDialog(id).Wy + 25 Then aKHover = -1
        Case aKPicture
            If aKMouse.x > aKPicture(object).x + aKDialog(id).Wx And aKMouse.x < aKPicture(object).x + aKPicture(object).w + aKDialog(id).Wx And aKMouse.y > aKPicture(object).y + aKDialog(id).Wy And aKMouse.y < aKPicture(object).y + aKPicture(object).h + aKDialog(id).Wy Then aKHover = -1
        Case Else
            aKError "aKHover", 254
    End Select
End Function


Sub akUpdateProgress (object, value)
    aKProgressBar(object).value = value
    aKProgressBar(object).active = True
End Sub



Function aKAnyHover (id, typ)
    Dim As Single i

    Select Case typ
        Case aKLabel
            For i = 1 To aKlabelLength
                If aKHover(id, typ, i) And aKLabel(i).id = id Then aKAnyHover = -1
            Next
        Case aKLinkLabel
            For i = 1 To aKLinklabelLength
                If aKHover(id, typ, i) And aKLinkLabel(i).id = id Then aKAnyHover = -1
            Next
        Case aKTextBox
            For i = 1 To aKTextBoxLength
                If aKHover(id, typ, i) And aKTextBox(i).id = id Then aKAnyHover = -1
            Next
        Case aKPicture
            For i = 1 To aKPictureLength
                If aKHover(id, typ, i) And aKPicture(i).id = id Then aKAnyHover = -1
            Next
        Case aKComboBox
            For i = 1 To aKComboBoxLength
                If aKHover(id, typ, i) And aKComboBox(i).id = id Then aKAnyHover = -1
            Next
        Case aKRadioButton
            For i = 1 To aKRadioLength
                If aKHover(id, typ, i) And aKRadioButton(i).id = id Then aKAnyHover = -1
            Next
        Case aKCheckBox
            For i = 1 To aKCheckBoxLength
                If aKHover(id, typ, i) And aKCheckBox(i).id = id Then aKAnyHover = -1
            Next
        Case aKNumericUpDown
            For i = 1 To aKNumericUDLength
                If aKHover(id, typ, i) And aKNumericUpDown(i).id = id Then aKAnyHover = -1
            Next
        Case aKPicture
            For i = 1 To aKPictureLength
                If aKHover(id, typ, i) And aKPicture(i).id = id Then aKAnyHover = -1
            Next
        Case Else
            aKError "aKAnyHover", 254
    End Select
End Function

Function aKDialogClose (id)
    If aKDialog(id).closed Or Not aKDialog(id).shown Then aKDialogClose = -1 Else aKDialogClose = 0
End Function

Function aKGetValue$ (typ, object)
    Dim As Single i

    i = object
    Select Case typ
        Case aKTextBox
            aKGetValue = RTrim$(aKTextBox(i).value)
        Case aKCheckBox
            If aKCheckBox(i).checked Then aKGetValue$ = RTrim$(aKCheckBox(i).text) Else aKGetValue = ""
        Case aKComboBox
            aKGetValue = RTrim$(aKComboBox(i).value)
        Case aKNumericUpDown
            aKGetValue = LTrim$(RTrim$(Str$(aKNumericUpDown(i).value)))
        Case aKButton
            aKGetValue = LTrim$(RTrim$(aKButton(i).value))
        Case aKLabel
            aKGetValue = LTrim$(RTrim$(aKLabel(i).text))
        Case aKLinkLabel
            aKGetValue = LTrim$(RTrim$(aKLinkLabel(i).text))
        Case Else
            aKError "aKGetValue$", 254
    End Select
End Function

Function aKGetRadioValue$ (id, GroupId)
    Dim As Single g, i

    g = GroupId
    For i = 1 To aKRadioLength
        If aKRadioButton(i).id = id And aKRadioButton(i).groupId = g And aKRadioButton(i).checked Then aKGetRadioValue = RTrim$(aKRadioButton(i).text)
    Next
End Function

Sub aKEraseObject (id, typ, object)
    Dim As Single i

    i = object
    If aKDialogClose(id) Then aKError "aKEraseObject()", 256
    If tooltipBg Then _PutImage , tooltipBg
    Select Case typ
        Case aKLabel
            Line (aKDialog(id).Wx + aKLabel(i).x, aKDialog(id).Wy + aKLabel(i).y)-(aKDialog(id).Wx + aKLabel(i).x + aKStrLength(aKLabel(i).text) * 8, aKDialog(id).Wy + aKLabel(i).y + 20), _RGB(230, 230, 230), BF
            aKLabel(i).hidden = -1
        Case aKButton
            Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 8 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(230, 230, 230), BF
            aKButton(i).hidden = -1
        Case aKCheckBox
            Line (aKDialog(id).Wx + aKCheckBox(i).x, aKDialog(id).Wy + aKCheckBox(i).y)-(aKDialog(id).Wx + aKCheckBox(i).x + aKStrLength(aKCheckBox(i).text) * 8 + 20, aKDialog(id).Wy + aKCheckBox(i).y + 20), _RGB(230, 230, 230), BF
            aKCheckBox(i).hidden = -1
        Case aKRadioButton
            Line (aKDialog(id).Wx + aKRadioButton(i).x, aKDialog(id).Wy + aKRadioButton(i).y)-(aKDialog(id).Wx + aKRadioButton(i).x + aKStrLength(aKRadioButton(i).text) * 8 + 20, aKDialog(id).Wy + aKRadioButton(i).y + 20), _RGB(230, 230, 230), BF
            aKRadioButton(i).hidden = -1
        Case aKLinkLabel
            Line (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y)-(aKDialog(id).Wx + aKLinkLabel(i).x + aKStrLength(aKLinkLabel(i).text) * 8, aKDialog(id).Wy + aKLinkLabel(i).y + 20), _RGB(230, 230, 230), BF
            aKLinkLabel(i).hidden = -1
        Case aKComboBox
            Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + aKStrLength(aKComboBox(i).value) * 8 + 30, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(230, 230, 230), BF
            aKComboBox(i).hidden = -1
        Case aKTextBox
            Line (aKDialog(id).Wx + aKTextBox(i).x, aKDialog(id).Wy + aKTextBox(i).y)-(aKDialog(id).Wx + aKTextBox(i).x + aKTextBox(i).w, aKDialog(id).Wy + aKTextBox(i).y + 25), _RGB(230, 230, 230), BF
            aKTextBox(i).hidden = -1
        Case aKNumericUpDown
            Line (aKDialog(id).Wx + aKNumericUpDown(i).x, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(230, 230, 230), BF
            aKNumericUpDown(i).hidden = -1
        Case aKProgressBar
            Line (aKDialog(id).Wx + aKProgressBar(i).x, aKDialog(id).Wy + aKProgressBar(i).y)-(aKDialog(id).Wx + aKProgressBar(i).x + aKProgressBar(i).w, aKDialog(id).Wy + aKProgressBar(i).y + 20), _RGB(230, 230, 230), BF
            aKProgressBar(i).hidden = -1
        Case aKPicture
            Line (aKDialog(id).Wx + aKPicture(i).x - 1, aKDialog(id).Wy + aKPicture(i).y - 1)-(aKDialog(id).Wx + aKPicture(i).x + aKPicture(i).w + 1, aKDialog(id).Wy + aKPicture(i).y + aKPicture(i).h + 1), _RGB(230, 230, 230), BF
            aKPicture(i).hidden = -1
        Case aKDivider
            If aKDivider(i).typ = aKVertical Then
                Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).x + aKDivider(i).size, aKDialog(id).Wy + aKDivider(i).y + 1), _RGB(230, 230, 230), BF
            ElseIf aKDivider(i).typ = aKHorizontal Then
                Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).x + 1, aKDialog(id).Wy + aKDivider(i).y + aKDivider(i).size), _RGB(230, 230, 230), BF
            End If
            aKDivider(i).hidden = -1
        Case aKPanel
            Line (aKDialog(id).Wx + aKPanel(i).x, aKDialog(id).Wy + aKPanel(i).y - 6)-(aKDialog(id).Wx + aKPanel(i).x + aKPanel(i).w + 1, aKDialog(id).Wy + aKPanel(i).y + aKPanel(i).h + 1), _RGB(230, 230, 230), BF
            aKPanel(i).hidden = -1
        Case Else
            aKError "aKEraseObject", 254
    End Select
    If tooltipBg Then tooltipBg = _CopyImage(0)
End Sub

Sub aKDrawObject (id, typ, object)
    Dim As Single i, px, n, g, c, l, ty, tx, yy, xx
    Dim As Long ps, ts, col
    Dim As String ca

    i = object
    If aKDialog(id).closed Then aKError "aKDrawObject()", 256

    Select Case typ
        Case aKLabel
            Color _RGB(0, 0, 0), _RGB(230, 230, 230)
            _PrintString (aKDialog(id).Wx + aKLabel(i).x, aKDialog(id).Wy + aKLabel(i).y), RTrim$(aKLabel(i).text)
            If aKLabel(i).hidden Then aKLabel(i).hidden = 0
        Case aKButton
            Color _RGB(0, 0, 0), _RGB(180, 180, 180)
            Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 7.5 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(180, 180, 180), BF
            Line (aKDialog(id).Wx + aKButton(i).x, aKDialog(id).Wy + aKButton(i).y)-(aKDialog(id).Wx + aKButton(i).x + aKStrLength(aKButton(i).value) * 7.5 + 20, aKDialog(id).Wy + aKButton(i).y + 23), _RGB(0, 0, 0), B
            _PrintString (aKDialog(id).Wx + aKButton(i).x + 10, aKDialog(id).Wy + aKButton(i).y + 5), RTrim$(aKButton(i).value)
            If aKButton(i).hidden Then aKButton(i).hidden = 0
        Case aKCheckBox
            Color _RGB(0, 0, 0), _RGB(230, 230, 230)
            Line (aKDialog(id).Wx + aKCheckBox(i).x, aKDialog(id).Wy + aKCheckBox(i).y)-(aKDialog(id).Wx + aKCheckBox(i).x + 12, aKDialog(id).Wy + aKCheckBox(i).y + 12), _RGB(255, 255, 255), BF
            Line (aKDialog(id).Wx + aKCheckBox(i).x, aKDialog(id).Wy + aKCheckBox(i).y)-(aKDialog(id).Wx + aKCheckBox(i).x + 12, aKDialog(id).Wy + aKCheckBox(i).y + 12), _RGB(0, 0, 0), B
            _PrintString (aKDialog(id).Wx + aKCheckBox(i).x + 20, aKDialog(id).Wy + aKCheckBox(i).y), RTrim$(aKCheckBox(i).text)
            If aKCheckBox(i).checked Then Line (aKCheckBox(i).x + aKDialog(id).Wx + 3, aKCheckBox(i).y + aKDialog(id).Wy + 3)-(aKCheckBox(i).x + aKDialog(id).Wx + 9, aKCheckBox(i).y + aKDialog(id).Wy + 9), _RGB(0, 0, 0), BF
            If aKCheckBox(i).hidden Then aKCheckBox(i).hidden = 0
        Case aKRadioButton
            Color _RGB(0, 0, 0), _RGB(230, 230, 230)
            Circle (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), 5, _RGB(0, 0, 0)
            Paint (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), _RGB(255, 255, 255), _RGB(0, 0, 0)
            _PrintString (aKDialog(id).Wx + aKRadioButton(i).x + 18, aKDialog(id).Wy + aKRadioButton(i).y), RTrim$(aKRadioButton(i).text)
            If aKRadioButton(i).checked Then Circle (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), 3, _RGB(8, 8, 8): Paint (aKDialog(id).Wx + aKRadioButton(i).x + 5, aKDialog(id).Wy + aKRadioButton(i).y + 7), _RGB(8, 8, 8), _RGB(8, 8, 8)
            If aKRadioButton(i).hidden Then aKRadioButton(i).hidden = 0
        Case aKLinkLabel
            Color _RGB(0, 0, 255), _RGB(230, 230, 230)
            _PrintString (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y), RTrim$(aKLinkLabel(i).text)
            Line (aKDialog(id).Wx + aKLinkLabel(i).x, aKDialog(id).Wy + aKLinkLabel(i).y + 14)-(aKDialog(id).Wx + aKLinkLabel(i).x + aKStrLength(aKLinkLabel(i).text) * 8, aKDialog(id).Wy + aKLinkLabel(i).y + 14), _RGB(0, 0, 255)
            If aKLinkLabel(i).hidden Then aKLinkLabel(i).hidden = 0
        Case aKNumericUpDown
            Color _RGB(0, 0, 0), _RGB(255, 255, 255)
            Line (aKDialog(id).Wx + aKNumericUpDown(i).x, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(255, 255, 255), BF
            Line (aKDialog(id).Wx + aKNumericUpDown(i).x, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(0, 0, 0), B
            _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + 5, aKDialog(id).Wy + aKNumericUpDown(i).y + 6), LTrim$(RTrim$(Str$(aKNumericUpDown(i).value)))
            Line (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 10, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(180, 180, 180), BF
            Line (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 10, aKDialog(id).Wy + aKNumericUpDown(i).y)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 25), _RGB(0, 0, 0), B
            Line (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 10, aKDialog(id).Wy + aKNumericUpDown(i).y + 13)-(aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 30, aKDialog(id).Wy + aKNumericUpDown(i).y + 13)
            Color , _RGBA(0, 0, 0, 0)
            _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y - 1), Chr$(30)
            _PrintString (aKDialog(id).Wx + aKNumericUpDown(i).x + aKNumericUpDown(i).w + 17, aKDialog(id).Wy + aKNumericUpDown(i).y + 13), Chr$(31)
            If aKNumericUpDown(i).hidden Then aKNumericUpDown(i).hidden = 0
        Case aKComboBox
            Color _RGB(0, 0, 0), _RGB(255, 255, 255)
            Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(255, 255, 255), BF
            Line (aKDialog(id).Wx + aKComboBox(i).x, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 0), B
            Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(180, 180, 180), BF
            Line (aKDialog(id).Wx + aKComboBox(i).x + 15 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y)-(aKDialog(id).Wx + aKComboBox(i).x + 30 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 23), _RGB(0, 0, 0), B
            _PrintString (aKDialog(id).Wx + aKComboBox(i).x + 5, aKDialog(id).Wy + aKComboBox(i).y + 5), RTrim$(aKComboBox(i).value)
            Color , _RGBA(0, 0, 0, 0)
            _PrintString (aKDialog(id).Wx + aKComboBox(i).x + 19 + aKStrLength(aKComboBox(i).value) * 8, aKDialog(id).Wy + aKComboBox(i).y + 6), Chr$(31)
            If aKComboBox(i).hidden Then aKComboBox(i).hidden = 0
        Case aKPicture
            _PutImage (aKDialog(id).Wx + aKPicture(i).x, aKDialog(id).Wy + aKPicture(i).y)-(aKDialog(id).Wx + aKPicture(i).x + aKPicture(i).w, aKDialog(id).Wy + aKPicture(i).y + aKPicture(i).h), aKPicture(i).img
            Line (aKDialog(id).Wx + aKPicture(i).x - 1, aKDialog(id).Wy + aKPicture(i).y - 1)-(aKDialog(id).Wx + aKPicture(i).x + aKPicture(i).w + 1, aKDialog(id).Wy + aKPicture(i).y + aKPicture(i).h + 1), _RGB(0, 0, 0), B
            If aKPicture(i).hidden Then aKPicture(i).hidden = 0
        Case aKPanel
            Color _RGB(0, 0, 0), _RGB(230, 230, 230)
            Line (aKDialog(id).Wx + aKPanel(i).x + 1, aKDialog(id).Wy + aKPanel(i).y + 1)-(aKDialog(id).Wx + aKPanel(i).x + aKPanel(i).w + 1, aKDialog(id).Wy + aKPanel(i).y + aKPanel(i).h + 1), _RGB(255, 255, 255), B
            Line (aKDialog(id).Wx + aKPanel(i).x, aKDialog(id).Wy + aKPanel(i).y)-(aKDialog(id).Wx + aKPanel(i).x + aKPanel(i).w, aKDialog(id).Wy + aKPanel(i).y + aKPanel(i).h), _RGB(150, 150, 150), B
            _PrintString (aKDialog(id).Wx + aKPanel(i).x + 10, aKDialog(id).Wy + aKPanel(i).y - 6), RTrim$(aKPanel(i).title)
            If aKPanel(i).hidden Then aKPanel(i).hidden = 0
        Case aKProgressBar
            Line (aKDialog(id).Wx + aKProgressBar(i).x, aKDialog(id).Wy + aKProgressBar(i).y)-(aKDialog(id).Wx + aKProgressBar(i).x + aKProgressBar(i).w, aKDialog(id).Wy + aKProgressBar(i).y + 20), _RGB(210, 210, 210), BF
            Line (aKDialog(id).Wx + aKProgressBar(i).x, aKDialog(id).Wy + aKProgressBar(i).y)-(aKDialog(id).Wx + aKProgressBar(i).x + aKProgressBar(i).w, aKDialog(id).Wy + aKProgressBar(i).y + 20), _RGB(0, 0, 0), B
            px = aKProgressBar(i).w - 2
            ps& = _NewImage(px, 19, 32)
            _Dest ps&
            Line (0, 0)-(px, 19), _RGB(0, 155, 0), BF
            For n = -px To px Step 10
                Line (n, 0)-(n + px, 400), _RGB(0, 255, 0)
            Next

            For n = -px To px Step 20
                Paint (n + 2, 1), _RGB(0, 255, 0), _RGB(0, 255, 0)
                Paint (n + 5, 18), _RGB(0, 255, 0), _RGB(0, 255, 0)
            Next
            aKProgressBar(i).bar = ps&
            If aKProgressBar(i).hidden Then aKProgressBar(i).hidden = 0
        Case aKDivider
            If aKDivider(i).typ = aKVertical Then
                If aKDialog(id).Wx + aKDivider(i).x + aKDivider(i).size >= aKDialog(id).Wx + aKDialog(i).w Then
                    Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDialog(id).w - 1, aKDialog(id).Wy + aKDivider(i).y), _RGB(150, 150, 150)
                    Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y + 1)-(aKDialog(id).Wx + aKDialog(id).w - 1, aKDialog(id).Wy + aKDivider(i).y + 1), _RGB(255, 255, 255)
                Else
                    Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).size, aKDialog(id).Wy + aKDivider(i).y), _RGB(150, 150, 150)
                    Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y + 1)-(aKDialog(id).Wx + aKDivider(i).size, aKDialog(id).Wy + aKDivider(i).y + 1), _RGB(255, 255, 155)
                End If
            ElseIf aKDivider(i).typ = aKHorizontal Then
                If aKDialog(id).Wy + aKDivider(i).y + aKDivider(i).size >= aKDialog(id).Wy + aKDialog(i).h - 20 Then
                    Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDialog(i).h - 26), _RGB(170, 170, 170)
                    Line (aKDialog(id).Wx + aKDivider(i).x + 1, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).x + 1, aKDialog(id).Wy + aKDialog(i).h - 26), _RGB(255, 255, 255)
                Else
                    Line (aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).x, aKDialog(id).Wy + aKDivider(i).size), _RGB(150, 150, 150)
                    Line (aKDialog(id).Wx + aKDivider(i).x + 1, aKDialog(id).Wy + aKDivider(i).y)-(aKDialog(id).Wx + aKDivider(i).x + 1, aKDialog(id).Wy + aKDivider(i).size), _RGB(255, 255, 255)
                End If
            End If
            If aKDivider(i).hidden Then aKDivider(i).hidden = 0
        Case aKTooltip
            g = 0: c = 0: ca$ = "": l = 1
            For n = 1 To aKStrLength(aKTooltip(i).text)
                c = c + 1
                ca$ = Mid$(aKTooltip(i).text, n, 1)
                If ca$ = "\" And UCase$(Mid$(aKTooltip(i).text, n + 1, 1)) = "N" Then l = l + 1: c = 0
                If g < c Then g = c
            Next
            ty = l * 15 + 18
            tx = g * 8 + 16
            ts& = _NewImage(tx, ty, 32) 'saving tooltip as image
            _Dest ts&
            Line (0, 0)-(tx, ty), _RGB(200, 0, 0), BF
            roundBox 6, 3, tx - 12, ty - 6, 3, _RGB(255, 255, 255)
            Paint (8, 5), _RGB(0, 0, 0), _RGB(255, 255, 255)
            Color _RGB(255, 255, 255), _RGB(0, 0, 0)
            yy = 10: xx = 10
            For n = 1 To aKStrLength(aKTooltip(i).text)
                ca$ = Mid$(aKTooltip(i).text, n, 1)
                If c > 50 Then yy = yy + 10
                If ca$ = "\" And UCase$(Mid$(aKTooltip(i).text, n + 1, 1)) = "N" Then yy = yy + 15: xx = 10: ca$ = "": xx = xx - 8
                If UCase$(ca$) = "N" And Mid$(aKTooltip(i).text, n - 1, 1) = "\" Then ca$ = "": xx = xx - 8
                _PrintString (xx, yy), ca$
                xx = xx + 8
            Next
            _ClearColor _RGB(200, 0, 0), ts&
            aKTooltip(i).content = _CopyImage(ts&)
            _FreeImage ts&
        Case aKTextBox
            Color _RGB(0, 0, 0), _RGB(255, 255, 255)
            If aKTextBox(i).active Then col& = _RGB(0, 0, 255) Else col& = _RGB(0, 0, 0)
            Line (aKDialog(id).Wx + aKTextBox(i).x, aKDialog(id).Wy + aKTextBox(i).y)-(aKDialog(id).Wx + aKTextBox(i).x + aKTextBox(i).w, aKDialog(id).Wy + aKTextBox(i).y + 25), _RGB(255, 255, 255), BF
            Line (aKDialog(id).Wx + aKTextBox(i).x, aKDialog(id).Wy + aKTextBox(i).y)-(aKDialog(id).Wx + aKTextBox(i).x + aKTextBox(i).w, aKDialog(id).Wy + aKTextBox(i).y + 25), col&, B
            If RTrim$(aKTextBox(i).value) = "" Then Color _RGB(150, 150, 150): _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, aKDialog(id).Wy + aKTextBox(i).y + 6), RTrim$(aKTextBox(i).placeholder)
            If aKTextBox(i).active = 0 And RTrim$(aKTextBox(i).value) <> "" Then
                Color _RGB(0, 0, 0), _RGB(255, 255, 255)
                _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, aKDialog(id).Wy + aKTextBox(i).y + 6), Space$(Len(RTrim$(aKTextBox(i).placeholder)))
                If aKTextBox(i).typ = aKPassword Then
                    _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, aKDialog(id).Wy + aKTextBox(i).y + 6), String$(Len(RTrim$(aKTextBox(i).value)), "*")
                Else
                    _PrintString (aKDialog(id).Wx + aKTextBox(i).x + 5, aKDialog(id).Wy + aKTextBox(i).y + 6), RTrim$(aKTextBox(i).value)
                End If
            End If
            If aKTextBox(i).hidden Then aKTextBox(i).hidden = 0
        Case Else
            aKError "aKDrawObject", 254
    End Select
    _Dest 0: _Source 0
    If tooltipBg Then tooltipBg = _CopyImage(0)
End Sub

Sub aKEraseAll ()
    Erase aKDialog, aKLabel, aKButton, aKCheckBox, aKRadioButton, aKLinkLabel, aKComboBox
    Erase aKTextBox, aKNumericUpDown, aKTooltip, aKProgressBar, aKDivider, aKPanel, aKPicture

    ReDim aKDialog(1) As aKdialogType, aKDialogLength
    ReDim aKLabel(1) As aKlabelType, aKlabelLength As Integer
    ReDim aKButton(1) As aKButtonType, aKButtonLength As Integer
    ReDim aKCheckBox(1) As akCheckBoxType, aKCheckBoxLength As Integer
    ReDim aKRadioButton(1) As akRadioButtonType, aKRadioLength As Integer
    ReDim aKLinkLabel(1) As aKLinklabelType, aKLinklabelLength As Integer
    ReDim aKComboBox(1) As aKComboBoxType, aKComboBoxLength As Integer
    ReDim aKTextBox(1) As aKTextboxType, aKTextBoxLength As Integer
    ReDim aKNumericUpDown(1) As aKNumericUpDownType, aKNumericUDLength As Integer
    ReDim aKProgressBar(1) As aKProgressBarType, aKProgressBarLength As Integer
    ReDim aKTooltip(1) As aKTooltipType, aKTooltipLength As Integer
    ReDim aKDivider(1) As aKDividerType, aKDividerLength As Integer
    ReDim aKPicture(1) As aKPictureType, aKPictureLength As Integer
    ReDim aKPanel(1) As aKPanelType, aKPanelLength As Integer
    ReDim aKMouse As mousetype, tooltipBg As Long, optionsBg As Long

    aKDialogLength = 1: aKlabelLength = 1: aKButtonLength = 1
    aKCheckBoxLength = 1: aKRadioLength = 1: aKLinklabelLength = 1
    aKComboBoxLength = 1: aKTextBoxLength = 1: aKNumericUDLength = 1
    aKProgressBarLength = 1: aKTooltipLength = 1: aKDividerLength = 1
    aKPictureLength = 1: aKPanelLength = 1

End Sub

Sub aKSetValue (typ, object, v$)
    Dim As Single i

    i = object
    Select Case typ
        Case aKLabel
            aKLabel(i).text = v$
        Case aKButton
            aKButton(i).value = v$
        Case aKCheckBox
            If UCase$(v$) = "Y" Then
                aKCheckBox(i).checked = -1
            ElseIf UCase$(v$) = "N" Then
                aKCheckBox(i).checked = 0
            End If
        Case aKPanel
            aKPanel(i).title = v$
        Case aKNumericUpDown
            aKNumericUpDown(i).value = Val(v$)
        Case aKTextBox
            aKTextBox(i).value = v$
        Case aKComboBox
            aKComboBox(i).value = v$
        Case aKLinkLabel
            aKLinkLabel(i).text = v$
        Case Else
            aKError "aKSetValue", 254
    End Select
End Sub

Sub aKSetRadioValue (id, GroupId, object)
    Dim As Single i

    For i = 1 To aKRadioLength
        If aKRadioButton(i).id = id And aKRadioButton(i).groupId = GroupId And aKRadioButton(i).checked Then aKRadioButton(i).checked = 0
    Next
    For i = 1 To aKRadioLength
        If aKRadioButton(i).id = id And aKRadioButton(i).groupId = GroupId And i = object Then aKRadioButton(i).checked = -1
    Next
End Sub

Function aKAnyClick (id, typ)
    Select Case typ
        Case aKLabel
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKLinkLabel
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKTextBox
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKPicture
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKComboBox
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKRadioButton
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKCheckBox
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKNumericUpDown
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case aKPicture
            If aKAnyHover(id, typ) And aKMouse.Lclick Then aKAnyClick = -1
        Case Else
            aKError "aKAnyClick", 254
    End Select
End Function



Sub aKAddTransition (id, typ$)
    If id > aKDialogLength Then aKError "aKAddTransition", 253
    aKDialog(id).transition = typ$
    aKDialog(id).hasAnimation = -1
End Sub

Sub aKRunAnimation (id)
    Dim As Long tmpImg, s, f
    Dim As Single i, h, cx, cy, r

    If UCase$(RTrim$(aKDialog(id).transition)) = "FADEBLACK" Then
        'uses an image in fading screen by changing its opacity
        tmpImg& = _NewImage(_Width, _Height, 32)
        _Dest tmpImg&: Line (0, 0)-(_Width, _Height), _RGB(0, 0, 0), BF: _Dest 0
        _SetAlpha 0, , tmpImg&
        For i = 0 To 125
            _PutImage , aKDialog(id).background
            _PutImage , tmpImg&
            _SetAlpha i, , tmpImg&
            _Display
        Next
        _FreeImage tmpImg&
    ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "FADEWHITE" Then
        'uses an image in fading screen by changing its opacity
        tmpImg& = _NewImage(_Width, _Height, 32)
        _Dest tmpImg&: Line (0, 0)-(_Width, _Height), _RGB(255, 255, 255), BF: _Dest 0
        _SetAlpha 0, , tmpImg&
        For i = 0 To 125
            _PutImage , aKDialog(id).background
            _PutImage , tmpImg&
            _SetAlpha i, , tmpImg&
            _Display
        Next
        _FreeImage tmpImg&
    ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "FOCUS" Then
        Line (0, 0)-(_Width(0), _Height(0)), _RGBA(0, 0, 0, 120), BF
    ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "SLIDE" Then
        'new method.
        h = aKDialog(id).h
        tmpImg& = _CopyImage(aKDialog(id).content)
        _Source tmpImg&
        Do
            _Dest tmpImg&
            _PutImage , aKDialog(id).content
            Line (0, i)-(_Width, _Height), _RGB(255, 0, 0), BF
            _ClearColor _RGB(255, 0, 0), tmpImg&
            _Dest 0
            _PutImage (aKDialog(id).Wx, aKDialog(id).Wy - 25), tmpImg&
            _Display
            i = i + 1
        Loop Until i >= h
        _Dest 0: _Source 0
    ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "CROSFADE" Then
        For i = 0 To 255 Step 4
            _SetAlpha i, , aKDialog(id).content
            _PutImage , aKDialog(id).background
            _PutImage (aKDialog(id).Wx, aKDialog(id).Wy - 25), aKDialog(id).content
            _Display
        Next
    ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "SHAPEOUT" Then
        tmpImg& = _CopyImage(aKDialog(id).content)
        cx = aKDialog(id).w / 2: cy = aKDialog(id).h / 2
        r = aKDialog(id).w / 2 + 30
        Do
            _Dest tmpImg&
            _PutImage , aKDialog(id).content
            Circle (cx, cy), r, _RGB(255, 0, 0)
            Paint (cx, cy), _RGB(255, 0, 0), _RGB(255, 0, 0)
            _ClearColor _RGB(255, 0, 0), tmpImg&
            _Dest 0
            _PutImage (aKDialog(id).Wx, aKDialog(id).Wy - 25), tmpImg&
            _Display
            r = r - 1
        Loop Until r <= 0
        _Source 0: _Dest 0
    ElseIf UCase$(RTrim$(aKDialog(id).transition)) = "BLINDS" Then
        tmpImg& = _CopyImage(aKDialog(id).content)
        _Source tmpImg&
        s = _Width / 50: h = _Height: f = 50
        Do
            _Dest tmpImg&
            _PutImage , aKDialog(id).content
            For i = 0 To s
                Line (i * 50, 0)-(i * 50 + f, h), _RGB(255, 0, 0), BF
            Next
            _ClearColor _RGB(255, 0, 0), tmpImg&
            _Dest 0
            _PutImage (aKDialog(id).Wx, aKDialog(id).Wy - 25), tmpImg&
            _Display
            f = f - 1
        Loop Until f <= 0
        _Dest 0: _Source 0
    End If
End Sub

Sub aKSetPicture (object, newImage&)
    Dim As Single i

    i = object
    _FreeImage aKPicture(i).img
    aKPicture(i).img = _CopyImage(newImage&)
End Sub

Sub aKFreeDialog (id)
    aKDialog(id).closed = 0
    aKDialog(id).shown = 0
    aKDialog(id).save = 0
End Sub

Sub aKCreateShadow (id)
    Dim As Single i, a

    'shadow
    If aKDialog(id).noShadow Then GoTo skipshadow
    i = 21: a = i
    Do While i > 0
        Line (aKDialog(id).Wx - 21 + i, aKDialog(id).Wy - 25 - 21 + i)-(aKDialog(id).Wx - 21 + i, aKDialog(id).Wy + aKDialog(id).h - 25 + 21 - i), _RGBA(0, 0, 0, a * 6)
        Line (aKDialog(id).Wx + aKDialog(id).w + 21 - i, aKDialog(id).Wy - 25 - 21 + i)-(aKDialog(id).Wx + aKDialog(id).w + 21 - i, aKDialog(id).Wy + aKDialog(id).h - 25 + 21 - i), _RGBA(0, 0, 0, a * 6)
        Line (aKDialog(id).Wx - 20 + i, aKDialog(id).Wy - 25 - 21 + i)-(aKDialog(id).Wx + aKDialog(id).w + 20 + -i, aKDialog(id).Wy - 25 - 21 + i), _RGBA(0, 0, 0, a * 6)
        Line (aKDialog(id).Wx - 20 + i, aKDialog(id).Wy + aKDialog(id).h - 25 + 21 - i)-(aKDialog(id).Wx + aKDialog(id).w + 20 + -i, aKDialog(id).Wy + aKDialog(id).h - 25 + 21 - i), _RGBA(0, 0, 0, a * 6)
        i = i - 1: a = a - 3
    Loop
    skipshadow:

End Sub


