'$include:'../include/aKFrameWork_Global.bas'

Screen _NewImage(700, 600, 32)
Cls

'creating our dialog handle.
dialog = aKNewdialog("Tooltip Demo", 400, 250)
'for our demo, we'll create 5 objects
'- 2 picture boxes
'- 1 button
'- 1 label
'- 1 link label
'You can use tooltip only on some objects
'listed above, i.e. picture boxes, button,
'label and link label.

'adding picture boxes
pic1 = aKAddPicture(dialog, 10, 10, 200, 200, _LoadImage("bg.jpg"))
pic2 = aKAddPicture(dialog, 220, 10, 170, 30, _LoadImage("colorpicker.png"))
'a label
label = aKAddlabel(dialog, "This is a label", 220, 60)
'link and button
link = aKAddLinklabel(dialog, "Link Label1", 220, 100)
button = aKAddButton(dialog, "Hover on Me!!", 220, 140)
'now, we'll add tooltips to above objects by
'using a function aKAddTooltip. To use this, here its
'syntax -
'myTooltip% = aKAddTooltip(handle%,typ%,object%,text$)
'in which
'handle% : the handle of your dialog.
'typ% : the type of the object given. Example -
'aKLabel, aKLinkLabel, aKButton and aKPicture
'object% : the handle of the object in which you
'want to add tooltip
'text$ : the text which will be shown when the object
'will be hovered by the mouse.
tooltip1 = aKAddTooltip(dialog, aKPicture, pic1, "This tooltip is on image!!.")
tooltip2 = aKAddTooltip(dialog, aKPicture, pic2, "This tooltip on another image!!.")
'NOTE : To break lines in tooltip use '\n' with text$
'You can see a example below -
tooltip3 = aKAddTooltip(dialog, aKLabel, label, "This is line 1\nThis is line 2")
tooltip4 = aKAddTooltip(dialog, aKLinkLabel, link, "Tooltip on links!!")
tooltip5 = aKAddTooltip(dialog, aKButton, button, "Tooltips!! even on buttons")
'if my framework is like by you then please
'comment what you feels at http://www.qb64.net/forum

Do
    aKCheck dialog
    aKUpdate dialog
    _Display
    If aKDialogClose(dialog) Then System
Loop


getError:
If Err = 258 Then
    Screen 0
    Print "Images file not found"
End If

'$include:'../include/aKFrameWork_Method.bas'

