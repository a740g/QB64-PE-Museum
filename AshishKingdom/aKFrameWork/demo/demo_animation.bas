'$INCLUDE:'../include/aKFrameWork_Global.bas'

SCREEN _NEWIMAGE(800, 700, 32)

_PUTIMAGE (0, 0), _LOADIMAGE("bg.jpg") 'sets the background of our screen
'set programs title
_TITLE "aKFrameWork Demo"

'create new dialog handle with desire hight and width
dialog = aKNewdialog("Animation Effect Demo", 600, 100)
'adding some labels to our handle at 10,10 position under it.
labels = aKAddlabel(dialog, "Select any animation from the combobox below", 10, 10)
'adding combobox which have all animation options.
'commas are used to separate options.
combobox = aKAddComboBox(dialog, "No Effect", "No Effect,FadeBlack,FadeWhite,CrosFade,Focus,ShapeOut,Slide,Blinds", 10, 40)
'adding button for running animation
runBtn = aKAddButton(dialog, "Show Dialog", 120, 40)
'adding tooltips to our button handle and defined it's type as
'aKButton. Use '\n' for line breaks in tooltips
t = aKAddTooltip(dialog, aKButton, runBtn, "click the view dialog with\ndesire animation effect.")
'creating one more dialogs in which we will
'apply animation using aKAddTransiton
miniDialog = aKNewdialog("Mini-Dialog", 400, 200)
DO
    'use these two subs at the top of the loop with
    'your dialog handle
    aKCheck dialog
    aKUpdate dialog
    'checking if our button has been clicked by the user
    'using aKClick function. Usage :
    'result% = aKClick(handle%, type%, objectHandle%)
    'handle% : the handle of our dialog
    'type% : the type of the object given like aKLable, aKButton, aKPicture or aKLinkLabel etc
    'objectHandle% : the handle of our object
    'return -1 if the following object has been clicked, 0 if not.
    IF aKClick(dialog, aKButton, runBtn) THEN
        'first we will get the value of our combo box using akGetValue Function
        'usage :
        'result$ = aKGetValue(type%, objectHandle%)
        'type% : the type of the object given like akKTextBox, aKComboBox, aKNumericUpDown, aKCheckBox
        'objectHandle% : the handle of our object
        'return the value of the desire object
        'we are using aKAddTransition to add effect to our dialog
        'usage:
        'aKAddTransition handle%,effect$
        'handle% : the handle of our dialog
        'effect$ : can be name of the effect like fadewhite,fadeblack,focus,crosfade,slide,blinds and shapeout
        aKAddTransition miniDialog, aKGetValue(aKComboBox, combobox)
        DO
            aKCheck miniDialog
            aKUpdate miniDialog
            'checking if the dialog has been closed by the user.
            IF aKDialogClose(miniDialog) THEN EXIT DO
            _DISPLAY
        LOOP
        aKFreeDialog miniDialog
        'use it always whenever a dialog as been closed by the user
        'so that it can be reuse.
    END IF
    IF aKDialogClose(dialog) THEN SYSTEM
    _DISPLAY
LOOP
'for more info read aKFramework_uses.pdf in doc folder

'$INCLUDE:'../include/aKFrameWork_Method.bas'

