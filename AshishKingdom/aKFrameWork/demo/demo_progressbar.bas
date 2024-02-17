'$include:'../include/aKFrameWork_Global.bas'

Screen _NewImage(800, 700, 32)
'setting background
_PutImage , _LoadImage("bg.jpg")
'setting title
_Title "ProgressBar Demo"

'creating a dialog handle
progressDialog = aKNewdialog("Progress Bar Demo", 380, 150)
'creating a label
label1 = aKAddlabel(progressDialog, "Click the button below to see a", 10, 10)
label2 = aKAddlabel(progressDialog, "beautiful progressbar running.", 10, 30)
'creating a run button which we'll use to run progress bar
'No matter if you are using it directly or not.
runBtn = aKAddButton(progressDialog, "Run Progress", 10, 90)
progress = aKAddProgressBar(progressDialog, 10, 50, 340, 1, -1)
'#####################################
'How shall I create progress bar   ?
'Answer:
'Read aKFramework.pdf in doc folder or see it below
'progress% = aKAddProgressBar(handle%,xpos%,ypos%,width%,value%,active%)
'handle% : the handle of your dialog.
'xpos% : the x-position of the progress bar inside the dialog.
'ypos% : the y-position of the progress bar inside the dialog.
'width% : the width of the progress bar in pixel. Should not be greater than the
'width of the dialog. If greater than the progress bar will be placed outside.
' Minimum width is 340, if provided less than it, then strips will made properly.
'value% : value can between 0 to 100. It represents how much portion of the
'progress bar will have green strip.
'active% :  It defines whether the progress bar is active or not. if given -1 then
'it is active
'###################################
'How shall I update the value of the progress bar ?
'Answer:
'Use aKUpdateProgress sub to update the value of the progress bar.
'Here's its syntax -
'aKUpdateProgress progressHandle%,newValue%
'progressHandle% : the handle of the progress bar.
'newValue% : the new value to be updated. Whether it is more than old value
'or less, the green stripp covering portion of progress bar will be
'updated.
Do
    'always use these two subs at the top of a loop with your dialog handle.
    aKCheck progressDialog
    aKUpdate progressDialog
    'checking if the user click run button
    If aKClick(progressDialog, aKButton, runBtn) Then
        'to prevent user next click we'll erase this object
        aKEraseObject progressDialog, aKButton, runBtn
        'and add progress bar
        start = -1
    End If
    'updating our progress bar
    If start And p < 100 Then
        p = p + 10
        akUpdateProgress progress, p
        'some delay. not neccessary
        _Delay .2
    End If
    _Display
    'checking if our dialog is closed by the user.
    If aKDialogClose(progressDialog) Then Exit Do
Loop

'$include:'../include/aKFrameWork_Method.bas'

