'$include:'../include/aKFrameWork_Global.bas'

Screen _NewImage(800, 700, 32)
'setting background
_PutImage , _LoadImage("bg.jpg")
_Title "Registration Form Demo"
'creating registration form dialog
regForm = aKNewdialog("Please fill the form", 350, 250)
'adding textboxes which will take first-name, last-name,password no.
'and email address
firstName = aKAddTextBox(regForm, "", "First Name", 10, 10, 160, 0)
lastName = aKAddTextBox(regForm, "", "Last Name", 180, 10, 160, 0)
email = aKAddTextBox(regForm, "", "Email Address", 10, 40, 330, 0)
password = aKAddTextBox(regForm, "", "Your Password", 10, 70, 330, aKPassword)
'adding  radio button for the person
label1 = aKAddlabel(regForm, "Choose Gender", 10, 110)
male = aKAddRadioButton(regForm, "Male", 140, 110, 1)
female = aKAddRadioButton(regForm, "Female", 200, 110, 1)
aKSetRadioValue regForm, male, 1
'adding a combo box to choose a city
city = aKAddComboBox(regForm, "Select City", "London,New York,Delhi,Sydney,Germany", 220, 135)
'adding numeric up-down for age.
label2 = aKAddlabel(regForm, "Age", 10, 138)
age = aKAddNumericUpDown(regForm, 22, 70, 132, 24)
'and finally adding submit,reset and cancel button
subBtn = aKAddButton(regForm, "Submit", 5, 180)
resetBtn = aKAddButton(regForm, "Reset", 75, 180)
cancelBtn = aKAddButton(regForm, "Cancel", 140, 180)
Do
    'always use this two subs at the top of the loop with the dialog handle
    aKCheck regForm
    aKUpdate regForm
    'checking if user click cancel button
    If aKClick(regForm, aKButton, cancelBtn) Then
        aKHideDialog regForm
        End
    End If
    'checking if user click reset button
    If aKClick(regForm, aKButton, resetBtn) Then
        'we'll reset values of all objects
        aKSetValue aKTextBox, firstName, ""
        aKSetValue aKTextBox, lastName, ""
        aKSetValue aKTextBox, email, ""
        aKSetValue aKTextBox, password, ""
        aKSetRadioValue regForm, male, 1
        aKSetValue aKComboBox, city, "Select City"
        aKSetValue aKNumericUpDown, age, "22"
        'update everything.
        aKDrawObject regForm, aKTextBox, firstName
        aKDrawObject regForm, aKTextBox, lastName
        aKDrawObject regForm, aKTextBox, email
        aKDrawObject regForm, aKTextBox, password
        aKDrawObject regForm, aKComboBox, city
        aKDrawObject regForm, aKNumericUpDown, age
        aKDrawObject regForm, aKRadioButton, male
        aKDrawObject regForm, aKRadioButton, female
    End If
    'checking if user hit submit btn
    If aKClick(regForm, aKButton, subBtn) Then enter = -1: Exit Do
    _Display
    'checking if the user close the dialog
    If aKDialogClose(regForm) Then System
Loop

If Not enter Then End
Screen 0
Print "Fist name : "; aKGetValue(aKTextBox, firstName)
Print "Last name : "; aKGetValue(aKTextBox, lastName)
Print "Email     : "; aKGetValue(aKTextBox, email)
Print "Password  : "; aKGetValue(aKTextBox, password)
Print "City      : "; aKGetValue(aKComboBox, city)
Print "Gender    : "; aKGetRadioValue(regForm, 1)
Print "Age       : "; aKGetValue(aKNumericUpDown, age)

 
'$include:'../include/aKFrameWork_Method.bas'

