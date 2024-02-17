'$include:'../include/aKFrameWork_Global.bas'

Screen _NewImage(800, 700, 32)

'setting our background
_PutImage , _LoadImage("bg.jpg")
'setting window title
_Title "ColorPicker Demo"
'creating a dialog handle of colorpicker
colorpicker = aKNewdialog("Color Picker Dialog Demo", 400, 300)
'creating gradient based image from which the user
'will choose color.
gradient& = _NewImage(200, 200, 32)
_Dest gradient&
Line (0, 0)-(200, 100), _RGB(255, 255, 255), BF
Line (0, 101)-(200, 200), _RGB(0, 0, 0), BF
s = 101: a = 255
Do Until s >= 200
    Line (0, s)-(200, s), _RGBA(255, 255, 255, a)
    s = s + 1: a = a - 3
Loop
'change it's value so that another gradient will be created
col& = _RGB(255, 0, 0)
s = 0: a = 0
Do Until s > 100
    Line (0, s)-(200, s), _RGBA(_Red(col&), _Green(col&), _Blue(col&), a)
    s = s + 1: a = a + 3
Loop
s = 101: a = 255
Do Until s >= 200
    Line (0, s)-(200, s), _RGBA(_Red(col&), _Green(col&), _Blue(col&), a)
    s = s + 1: a = a - 3
Loop
'creating a picture box with our gradient image handle
GrdImage = aKAddPicture(colorpicker, 10, 10, 200, 200, gradient&)
'adding a colorbar image which has raiblow color
bar = aKAddPicture(colorpicker, 10, 230, 175, 30, _LoadImage("colorpicker.png"))
'adding a panel in which RGB values will be display.
rgbPanel = aKAddPanel(colorpicker, 220, 15, 170, 110, "RGB Values")
'now we will add three lables and numeric up-down in it which will
'show the rgb value of current color.
label1 = aKAddlabel(colorpicker, "Red", 225, 34)
label2 = aKAddlabel(colorpicker, "Green", 225, 64)
label3 = aKAddlabel(colorpicker, "Blue", 225, 94)
redValue = aKAddNumericUpDown(colorpicker, _Red(col&), 300, 30, 25)
greenValue = aKAddNumericUpDown(colorpicker, _Green(col&), 300, 60, 25)
blueValue = aKAddNumericUpDown(colorpicker, _Blue(col&), 300, 90, 25)
'adding current color picture box
current& = _NewImage(150, 40, 32)
_Dest current&
Paint (0, 0), col&
curPanel = aKAddPanel(colorpicker, 220, 137, 170, 60, "Current Color")
curImage = aKAddPicture(colorpicker, 230, 150, 150, 40, current&)
'and finally adding choose and cancel buttons
chooseBtn = aKAddButton(colorpicker, "Choose", 220, 235)
cancelBtn = aKAddButton(colorpicker, "Cancel", 300, 235)
'hurray!! we have created all the objects of our dialog
'they are as follows :-
' 3 Lables
' 3 Picture Boxes
' 3 Numeric Up-Down
' 2 Panels
' and 2 Buttons

'setting our drawing page to 0
_Dest 0
Do
    'always use these two subs at the top the loop with your dialog handle.
    aKCheck colorpicker
    aKUpdate colorpicker
    _Display
    'checking if the user click cancel button
    If aKClick(colorpicker, aKButton, cancelBtn) Then
        'we have to close the dialog
        aKHideDialog colorpicker
        End
    End If
    'checking if the user click choose button
    If aKClick(colorpicker, aKButton, chooseBtn) Then
        'now, we'll show the color that the user has selected
        r = Val(aKGetValue(aKNumericUpDown, redValue))
        g = Val(aKGetValue(aKNumericUpDown, greenValue))
        b = Val(aKGetValue(aKNumericUpDown, blueValue))
        aKHideDialog colorpicker
        Color _RGB(r, g, b)
        Print "You have choosen RGB("; r; ", "; g; " ,"; b; ")"
        End
    End If
    'checking if the rgb values in the panel should not be more
    'than 255
    If Val(aKGetValue(aKNumericUpDown, redValue)) > 255 Then
        'we'll set it's value to 255 by using aKSetValue method.
        aKSetValue aKNumericUpDown, redValue, "255"
        'also we have to update the content of the dialog
        aKDrawObject colorpicker, aKNumericUpDown, redValue
    End If
    If Val(aKGetValue(aKNumericUpDown, greenValue)) > 255 Then
        aKSetValue aKNumericUpDown, greenValue, "255"
        aKDrawObject colorpicker, aKNumericUpDown, greenValue
    End If
    If Val(aKGetValue(aKNumericUpDown, blueValue)) > 255 Then
        aKSetValue aKNumericUpDown, blueValue, "255"
        aKDrawObject colorpicker, aKNumericUpDown, blueValue
    End If
    'and also not less than 0 by the user
    If Val(aKGetValue(aKNumericUpDown, redValue)) < 0 Then
        aKSetValue aKNumericUpDown, redValue, "0"
        aKDrawObject colorpicker, aKNumericUpDown, redValue
    End If
    If Val(aKGetValue(aKNumericUpDown, greenValue)) < 0 Then
        aKSetValue aKNumericUpDown, greenValue, "0"
        aKDrawObject colorpicker, aKNumericUpDown, greenValue
    End If
    If Val(aKGetValue(aKNumericUpDown, blueValue)) < 0 Then
        aKSetValue aKNumericUpDown, blueValue, "0"
        aKDrawObject colorpicker, aKNumericUpDown, blueValue
    End If
    'checking if the any Numeric Up-down of the dialog are
    'clicked means there value has been changed
    If aKAnyClick(colorpicker, aKNumericUpDown) Then
        'now we have to update our current color picture box
        r = Val(aKGetValue(aKNumericUpDown, redValue))
        g = Val(aKGetValue(aKNumericUpDown, greenValue))
        b = Val(aKGetValue(aKNumericUpDown, blueValue))
        current& = _NewImage(150, 40, 32)
        _Dest current&
        Paint (0, 0), _RGB(r, g, b)
        _Dest 0
        aKSetPicture curImage, current&
        _FreeImage current&
        aKDrawObject colorpicker, aKPicture, curImage
    End If
    'checking if the gradient picture box is clicked by the user
    'then update current color as well as rgb values
    If aKClick(colorpicker, aKPicture, GrdImage) Then
        'note that Mouse.x, Mouse.y, Mouse.Lclick, Mouse.Rclick are the variables
        'defined in the akframework_global.bi
        col& = Point(Mouse.x, Mouse.y)
        aKSetValue aKNumericUpDown, redValue, Str$(_Red(col&))
        aKSetValue aKNumericUpDown, greenValue, Str$(_Green(col&))
        aKSetValue aKNumericUpDown, blueValue, Str$(_Blue(col&))
        current& = _NewImage(150, 40, 32)
        _Dest current&
        Paint (0, 0), _RGB(_Red(col&), _Green(col&), _Blue(col&))
        _Dest 0
        aKSetPicture curImage, current&
        _FreeImage current&
        aKDrawObject colorpicker, aKPicture, curImage
        aKDrawObject colorpicker, aKNumericUpDown, redValue
        aKDrawObject colorpicker, aKNumericUpDown, greenValue
        aKDrawObject colorpicker, aKNumericUpDown, blueValue
    End If
    'and last checking that the bar has been clicked by the user
    'so we have to update our color gradient
    If aKClick(colorpicker, aKPicture, bar) Then
        'recreating our gradient
        col& = Point(Mouse.x, Mouse.y)
        gradient& = _NewImage(200, 200, 32)
        _Dest gradient&
        Line (0, 0)-(200, 100), _RGB(255, 255, 255), BF
        Line (0, 101)-(200, 200), _RGB(0, 0, 0), BF
        s = 101: a = 255
        Do Until s >= 200
            Line (0, s)-(200, s), _RGBA(255, 255, 255, a)
            s = s + 1: a = a - 3
        Loop
        s = 0: a = 0
        Do Until s > 100
            Line (0, s)-(200, s), _RGBA(_Red(col&), _Green(col&), _Blue(col&), a)
            s = s + 1: a = a + 3
        Loop
        s = 101: a = 255
        Do Until s >= 200
            Line (0, s)-(200, s), _RGBA(_Red(col&), _Green(col&), _Blue(col&), a)
            s = s + 1: a = a - 3
        Loop
        _Dest 0
        aKSetPicture GrdImage, gradient&
        _FreeImage gradient&
        aKDrawObject colorpicker, aKPicture, GrdImage
    End If
    'checking if the dialog is closed by the user
    If aKDialogClose(colorpicker) Then Exit Do
Loop

'$include:'../include/aKFrameWork_Method.bas'

