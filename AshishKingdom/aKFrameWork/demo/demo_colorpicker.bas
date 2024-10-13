'$INCLUDE:'../include/aKFrameWork_Global.bas'

SCREEN _NEWIMAGE(800, 700, 32)

'setting our background
_PUTIMAGE , _LOADIMAGE("bg.jpg")
'setting window title
_TITLE "ColorPicker Demo"
'creating a dialog handle of colorpicker
colorpicker = aKNewdialog("Color Picker Dialog Demo", 400, 300)
'creating gradient based image from which the user
'will choose color.
gradient& = _NEWIMAGE(200, 200, 32)
_DEST gradient&
LINE (0, 0)-(200, 100), _RGB(255, 255, 255), BF
LINE (0, 101)-(200, 200), _RGB(0, 0, 0), BF
s = 101: a = 255
DO UNTIL s >= 200
    LINE (0, s)-(200, s), _RGBA(255, 255, 255, a)
    s = s + 1: a = a - 3
LOOP
'change it's value so that another gradient will be created
col& = _RGB(255, 0, 0)
s = 0: a = 0
DO UNTIL s > 100
    LINE (0, s)-(200, s), _RGBA(_RED(col&), _GREEN(col&), _BLUE(col&), a)
    s = s + 1: a = a + 3
LOOP
s = 101: a = 255
DO UNTIL s >= 200
    LINE (0, s)-(200, s), _RGBA(_RED(col&), _GREEN(col&), _BLUE(col&), a)
    s = s + 1: a = a - 3
LOOP
'creating a picture box with our gradient image handle
GrdImage = aKAddPicture(colorpicker, 10, 10, 200, 200, gradient&)
'adding a colorbar image which has raiblow color
bar = aKAddPicture(colorpicker, 10, 230, 175, 30, _LOADIMAGE("colorpicker.png"))
'adding a panel in which RGB values will be display.
rgbPanel = aKAddPanel(colorpicker, 220, 15, 170, 110, "RGB Values")
'now we will add three lables and numeric up-down in it which will
'show the rgb value of current color.
label1 = aKAddlabel(colorpicker, "Red", 225, 34)
label2 = aKAddlabel(colorpicker, "Green", 225, 64)
label3 = aKAddlabel(colorpicker, "Blue", 225, 94)
redValue = aKAddNumericUpDown(colorpicker, _RED(col&), 300, 30, 25)
greenValue = aKAddNumericUpDown(colorpicker, _GREEN(col&), 300, 60, 25)
blueValue = aKAddNumericUpDown(colorpicker, _BLUE(col&), 300, 90, 25)
'adding current color picture box
current& = _NEWIMAGE(150, 40, 32)
_DEST current&
PAINT (0, 0), col&
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
_DEST 0
DO
    'always use these two subs at the top the loop with your dialog handle.
    aKCheck colorpicker
    aKUpdate colorpicker
    _DISPLAY
    'checking if the user click cancel button
    IF aKClick(colorpicker, aKButton, cancelBtn) THEN
        'we have to close the dialog
        aKHideDialog colorpicker
        END
    END IF
    'checking if the user click choose button
    IF aKClick(colorpicker, aKButton, chooseBtn) THEN
        'now, we'll show the color that the user has selected
        r = VAL(aKGetValue(aKNumericUpDown, redValue))
        g = VAL(aKGetValue(aKNumericUpDown, greenValue))
        b = VAL(aKGetValue(aKNumericUpDown, blueValue))
        aKHideDialog colorpicker
        COLOR _RGB(r, g, b)
        PRINT "You have choosen RGB("; r; ", "; g; " ,"; b; ")"
        END
    END IF
    'checking if the rgb values in the panel should not be more
    'than 255
    IF VAL(aKGetValue(aKNumericUpDown, redValue)) > 255 THEN
        'we'll set it's value to 255 by using aKSetValue method.
        aKSetValue aKNumericUpDown, redValue, "255"
        'also we have to update the content of the dialog
        aKDrawObject colorpicker, aKNumericUpDown, redValue
    END IF
    IF VAL(aKGetValue(aKNumericUpDown, greenValue)) > 255 THEN
        aKSetValue aKNumericUpDown, greenValue, "255"
        aKDrawObject colorpicker, aKNumericUpDown, greenValue
    END IF
    IF VAL(aKGetValue(aKNumericUpDown, blueValue)) > 255 THEN
        aKSetValue aKNumericUpDown, blueValue, "255"
        aKDrawObject colorpicker, aKNumericUpDown, blueValue
    END IF
    'and also not less than 0 by the user
    IF VAL(aKGetValue(aKNumericUpDown, redValue)) < 0 THEN
        aKSetValue aKNumericUpDown, redValue, "0"
        aKDrawObject colorpicker, aKNumericUpDown, redValue
    END IF
    IF VAL(aKGetValue(aKNumericUpDown, greenValue)) < 0 THEN
        aKSetValue aKNumericUpDown, greenValue, "0"
        aKDrawObject colorpicker, aKNumericUpDown, greenValue
    END IF
    IF VAL(aKGetValue(aKNumericUpDown, blueValue)) < 0 THEN
        aKSetValue aKNumericUpDown, blueValue, "0"
        aKDrawObject colorpicker, aKNumericUpDown, blueValue
    END IF
    'checking if the any Numeric Up-down of the dialog are
    'clicked means there value has been changed
    IF aKAnyClick(colorpicker, aKNumericUpDown) THEN
        'now we have to update our current color picture box
        r = VAL(aKGetValue(aKNumericUpDown, redValue))
        g = VAL(aKGetValue(aKNumericUpDown, greenValue))
        b = VAL(aKGetValue(aKNumericUpDown, blueValue))
        current& = _NEWIMAGE(150, 40, 32)
        _DEST current&
        PAINT (0, 0), _RGB(r, g, b)
        _DEST 0
        aKSetPicture curImage, current&
        _FREEIMAGE current&
        aKDrawObject colorpicker, aKPicture, curImage
    END IF
    'checking if the gradient picture box is clicked by the user
    'then update current color as well as rgb values
    IF aKClick(colorpicker, aKPicture, GrdImage) THEN
        'note that Mouse.x, Mouse.y, Mouse.Lclick, Mouse.Rclick are the variables
        'defined in the akframework_global.bi
        col& = POINT(Mouse.x, Mouse.y)
        aKSetValue aKNumericUpDown, redValue, STR$(_RED(col&))
        aKSetValue aKNumericUpDown, greenValue, STR$(_GREEN(col&))
        aKSetValue aKNumericUpDown, blueValue, STR$(_BLUE(col&))
        current& = _NEWIMAGE(150, 40, 32)
        _DEST current&
        PAINT (0, 0), _RGB(_RED(col&), _GREEN(col&), _BLUE(col&))
        _DEST 0
        aKSetPicture curImage, current&
        _FREEIMAGE current&
        aKDrawObject colorpicker, aKPicture, curImage
        aKDrawObject colorpicker, aKNumericUpDown, redValue
        aKDrawObject colorpicker, aKNumericUpDown, greenValue
        aKDrawObject colorpicker, aKNumericUpDown, blueValue
    END IF
    'and last checking that the bar has been clicked by the user
    'so we have to update our color gradient
    IF aKClick(colorpicker, aKPicture, bar) THEN
        'recreating our gradient
        col& = POINT(Mouse.x, Mouse.y)
        gradient& = _NEWIMAGE(200, 200, 32)
        _DEST gradient&
        LINE (0, 0)-(200, 100), _RGB(255, 255, 255), BF
        LINE (0, 101)-(200, 200), _RGB(0, 0, 0), BF
        s = 101: a = 255
        DO UNTIL s >= 200
            LINE (0, s)-(200, s), _RGBA(255, 255, 255, a)
            s = s + 1: a = a - 3
        LOOP
        s = 0: a = 0
        DO UNTIL s > 100
            LINE (0, s)-(200, s), _RGBA(_RED(col&), _GREEN(col&), _BLUE(col&), a)
            s = s + 1: a = a + 3
        LOOP
        s = 101: a = 255
        DO UNTIL s >= 200
            LINE (0, s)-(200, s), _RGBA(_RED(col&), _GREEN(col&), _BLUE(col&), a)
            s = s + 1: a = a - 3
        LOOP
        _DEST 0
        aKSetPicture GrdImage, gradient&
        _FREEIMAGE gradient&
        aKDrawObject colorpicker, aKPicture, GrdImage
    END IF
    'checking if the dialog is closed by the user
    IF aKDialogClose(colorpicker) THEN EXIT DO
LOOP

'$INCLUDE:'../include/aKFrameWork_Method.bas'

