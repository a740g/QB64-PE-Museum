Option _Explicit '
_Title "Account Tracker GUIb" 'remove opening screen use a File Menu button

' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'                   Do NOT use decimals in Amt these will be inserted
'          Do NOT use commas in Notes, they are used to delimited Fields in Files
'               so you may view and edit these files in a regular .Txt Editor
'
'       Account File names now end in " Acct.txt" for identifying txt files intended.
'
'         This app will automatically create an Accounts folder a subdirectory below
'     the one the exe file it is found in. Tha same level as GUIb Fonts and Image folders.
'
'
' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'$include:'GUIb.BI'

Type Record
    As String * 10 date
    As String * 57 note ' for 80 chars across 10 + 57 + 11 + 11 = 89 wide record in file
    As String * 11 amt, bal
End Type
Dim Shared WorkFile$ '                 the acct file we are working
Dim Shared lstRecs$ '                  this is the long ~ delimited string for lstAcct control
ReDim Shared Acct(1 To 1) As Record '  new array to track and edit no save/load file each edit
Dim Shared As Long Nrecs '             track last record index
Dim Shared As _Integer64 Amt, Bal '    integer arithmetic for money so convert back and forth
Dim Shared Saved

'   Set Globals from BI
Xmax = 1130: Ymax = 700: GuiTitle$ = "Account Tracker GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControl()

' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long tbAmt, tbNote, tbDate, BtnA, BNew, BOpen, BSav, BReplace, BInsert, BCopy, BDelete, BExit, lstAcct
tbDate = NewControl(2, 20, 40, 150, 24, "", "Date")
tbNote = NewControl(2, 190, 40, 750, 24, "", "Notes")
tbAmt = NewControl(2, 960, 40, 150, 24, "", "Amount")
BtnA = NewControl(1, 20, 100, 260, 40, "Append", "")
lstAcct = NewControl(3, 310, 100, 800, 580, lstRecs$, "Transactions List")
BNew = NewControl(1, 20, 200, 260, 24, "New", "File:")
BOpen = NewControl(1, 20, 225, 260, 24, "Open", "")
BSav = NewControl(1, 20, 250, 260, 24, "Save", "")
BReplace = NewControl(1, 20, 340, 260, 24, "Replace Highlighted", "Edit Line:")
BInsert = NewControl(1, 20, 365, 260, 24, "Insert at Highlight", "")
BCopy = NewControl(1, 20, 430, 260, 24, "Copy to Edit", "File Item:")
BDelete = NewControl(1, 20, 455, 260, 24, "Delete", "")
BExit = NewControl(1, 20, 500, 260, 24, "Exit", "")
' End GUI Controls
If _DirExists(ExePath$ + OSslash$ + "Accounts") = 0 Then MkDir ExePath$ + OSslash$ + "Accounts"
Saved = -1
WorkFile$ = ""
_Title "Acct File: " + "New"
MainRouter ' _exit will exit mainRouter but now you must handle ending the program
checkSaved
System

Sub BtnClickEvent (i As Long)
    Dim t$, s$, fl$, pe1$, pe2$, rec As Record, replaceRec As Record
    Dim As _Integer64 replaceAmt
    Dim As Long j, listN
    pe1$ = "Punctuation Error:": pe2$ = "No commas in Notes, nor decimals in Amount."

    Select Case i
        Case BtnA
            If InStr(con(tbAmt).Text, ".") = 0 And InStr(con(tbNote).Text, ",") = 0 Then
                Amt = Val(con(tbAmt).Text)
                Bal = Bal + Amt
                rec.date = _Trim$(con(tbDate).Text)
                rec.note = _Trim$(con(tbNote).Text)
                rec.amt = Dot2_11$(Amt)
                rec.bal = Dot2_11$(Bal)
                Nrecs = Nrecs + 1
                ReDim _Preserve Acct(1 To Nrecs) As Record
                Acct(Nrecs) = rec
                updateLstAcc
                LstKeyEvent lstAcct, 20224 ' highlight last record   redrw again
                con(tbNote).Text = ""
                con(tbNote).CurSec = 1
                con(tbNote).CurCol = 1
                drwTB tbNote
                con(tbAmt).Text = ""
                con(tbAmt).CurSec = 1
                con(tbAmt).CurCol = 1
                drwTB tbAmt
                Saved = 0
            Else
                _MessageBox pe1$, pe2$, "error"
            End If

        Case BNew
            checkSaved
            ReDim Acct(1 To 1) As Record
            WorkFile$ = "": Saved = -1: Nrecs = 0
            _Title "Acct File: " + "New"
            con(lstAcct).CurPage = 1
            con(lstAcct).CurRow = 1
            updateLstAcc
            Saved = -1

        Case BOpen
            s$ = "Load an Acct.txt File:"
            t$ = _OpenFileDialog$(s$, ExePath$ + OSslash$ + "Accounts" + OSslash$ + "*Acct.txt", "*Acct.txt", "*Acct.txt")
            If t$ <> "" Then
                checkSaved ' before we change work file name
                WorkFile$ = t$
                _Title "Acct File: " + WorkFile$
                ReDim Acct(1 To 1) As Record
                ReDim fields$(1 To 1)
                Nrecs = 0
                Open WorkFile$ For Input As #1
                While Not EOF(1)
                    Line Input #1, fl$
                    If _Trim$(fl$) <> "" Then
                        Split fl$, ",", fields$()
                        rec.date = _Trim$(fields$(1))
                        rec.note = _Trim$(fields$(2))
                        Amt = Val(_Trim$(fields$(3))) * 100
                        Bal = Bal + Amt ' independent adding up
                        rec.amt = Dot2_11$(Amt)
                        rec.bal = Dot2_11$(Bal)
                        Nrecs = Nrecs + 1 'prepare to add to array
                        ReDim _Preserve Acct(1 To Nrecs) As Record
                        Acct(Nrecs) = rec
                    End If
                Wend
                Close #1
                Saved = -1
                _Title "Acct File:" + WorkFile$
                con(lstAcct).CurPage = 1
                con(lstAcct).CurRow = 1
                updateLstAcc
            End If

        Case BSav
            saveWork

        Case BReplace
            ReDim lst(1 To 1) As String 'need to find highlighted item
            ReDim fields$(1 To 1)
            If InStr(con(tbAmt).Text, ".") = 0 And InStr(con(tbNote).Text, ",") = 0 Then
                replaceAmt = Val(con(tbAmt).Text) '           code from btnPlus  get new line ready
                replaceRec.date = _Trim$(con(tbDate).Text)
                replaceRec.note = _Trim$(con(tbNote).Text)
                replaceRec.amt = Dot2_11$(replaceAmt)
                replaceRec.bal = "" ' this gets updated later
            Else
                _MessageBox pe1$, pe2$, "error"
                Exit Sub ' fix the problem
            End If
            ' we need to get the array index number of highlight item  check that function in BM
            listN = LstHighliteNum&(lstAcct) ' try new function
            Acct(listN) = replaceRec
            updateLstAcc ' it does the rest
            con(tbNote).Text = "" ' clear the tb's  like with add/append
            con(tbNote).CurSec = 1
            con(tbNote).CurCol = 1
            drwTB tbNote
            con(tbAmt).Text = ""
            con(tbAmt).CurSec = 1
            con(tbAmt).CurCol = 1
            drwTB tbAmt
            Saved = 0

        Case BInsert
            ReDim lst(1 To 1) As String 'need to find highlighted item
            ReDim fields$(1 To 1)
            If InStr(con(tbAmt).Text, ".") = 0 And InStr(con(tbNote).Text, ",") = 0 Then
                replaceAmt = Val(con(tbAmt).Text) ' <<<<<<<<<< fix 8-12 missing this line
                rec.date = _Trim$(con(tbDate).Text) 'code from btnPlus  get new line ready
                rec.note = _Trim$(con(tbNote).Text)
                rec.amt = Dot2_11$(replaceAmt)
                rec.bal = "" ' this gets updated later
            Else
                _MessageBox pe1$, pe2$, "error"
                Exit Sub ' fix the problem
            End If
            listN = LstHighliteNum&(lstAcct) ' try new function
            Nrecs = Nrecs + 1 ' now make room for new addition
            ReDim _Preserve Acct(1 To Nrecs) As Record
            For j = Nrecs To (listN + 1) Step -1 ' slide all the values up one dont worry about bal
                Acct(j) = Acct(j - 1)
            Next
            Acct(listN) = rec 'exchange old for new   inserted
            updateLstAcc ' just call this it does the rest highlight is right where we want it
            con(tbNote).Text = "" '                clear the tb's  like with add/append
            con(tbNote).CurSec = 1
            con(tbNote).CurCol = 1
            drwTB tbNote
            con(tbAmt).Text = ""
            con(tbAmt).CurSec = 1
            con(tbAmt).CurCol = 1
            drwTB tbAmt
            Saved = 0

        Case BCopy
            t$ = LstHighliteItem$(lstAcct)
            ReDim lst(1 To 1) As String
            Split t$, ",", lst()
            con(tbDate).Text = lst(1)
            con(tbDate).CurSec = 1
            con(tbDate).CurCol = 1
            drwTB tbDate
            con(tbNote).Text = lst(2)
            con(tbNote).CurSec = 1
            con(tbNote).CurCol = 1
            drwTB tbNote
            con(tbAmt).Text = _Trim$(Str$(100 * Val(lst(3))))
            con(tbAmt).CurSec = 1
            con(tbAmt).CurCol = 1
            drwTB tbAmt

        Case BDelete
            listN = LstHighliteNum&(lstAcct) ' try new function
            For j = listN To Nrecs - 1 'copy all the values down one dont worry about bal
                Acct(j) = Acct(j + 1)
            Next
            Nrecs = Nrecs - 1
            ReDim _Preserve Acct(1 To Nrecs) As Record
            updateLstAcc ' ' Now just call this it does the rest
            Saved = 0

        Case BExit
            checkSaved
            System

    End Select
End Sub

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
End Sub

Sub LblClickEvent (i As Long)
    i = i
End Sub

' this formats a _integer64 type number into a right aligned 11 places and places dot 2 places in
' so fits up to 99,999,999.99 dollars or some other unit, fixed right alignment number 2022-8-7
Function Dot2_11$ (cents As _Integer64) ' modified for right aligned in 11 spaces
    Dim s$, rtn$, sign$
    s$ = _Trim$(Str$(cents)) ' TS$ is for long
    If Left$(s$, 1) = "-" Then sign$ = "-": s$ = Mid$(s$, 2) Else sign$ = ""
    If Len(s$) = 1 Then
        s$ = sign$ + "0.0" + s$
    ElseIf Len(s$) = 2 Then
        s$ = sign$ + "0." + s$
    Else
        s$ = sign$ + Mid$(s$, 1, Len(s$) - 2) + "." + Mid$(s$, Len(s$) - 1)
    End If
    rtn$ = Space$(11)
    s$ = _Trim$(s$)
    Mid$(rtn$, 11 - Len(s$) + 1) = s$ ' fixes that nasty extra space
    Dot2_11$ = rtn$
End Function

Sub updateLstAcc ' after the acct() updated
    Dim As Long j
    lstRecs$ = "" ' rejoin the string
    Bal = 0 ' recalc bal
    For j = 1 To Nrecs
        Bal = Bal + 100 * Val(Acct(j).amt) ' new bal calc
        Acct(j).bal = Dot2_11$(Bal)
        If lstRecs$ <> "" Then
            lstRecs$ = lstRecs$ + "~" + Acct(j).date + "," + Acct(j).note + "," + Acct(j).amt +_
             "," + Acct(j).bal
        Else
            lstRecs$ = Acct(j).date + "," + Acct(j).note + "," + Acct(j).amt + "," + Acct(j).bal
        End If
    Next
    con(lstAcct).Text = lstRecs$
    drwLst lstAcct
End Sub

Sub checkSaved
    Dim As Long a
    If Saved = 0 Then
        a = _MessageBox("Save work?", "Do you want to save changes to " + WorkFile$, "yesno", "question")
        If a = 1 Then saveWork
    End If
End Sub

Sub saveWork ' assumes workfile <> "" and correct
    Dim t$, try As Long
    If WorkFile$ = "" Then 'get a name!
        tryAgain:

        t$ = _SaveFileDialog$("Save File As:", ExePath$ + OSslash$ + "Accounts" + OSslash$ +_
        "*Acct.txt", "*Acct.txt", "*Acct.txt file")

        If Right$(t$, 8) = "Acct.txt" Then
            WorkFile$ = t$
        Else
            try = try + 1
            _MessageBox "Error:", "Name must end with Acct.txt"
            If try > 5 Then Exit Sub
            GoTo tryAgain
        End If
    End If

    ' workfile should be at least Acct.txt by now, either opened or newly named here
    Dim fl$
    Dim As Long j
    ReDim lst(1 To 1) As String
    Split con(lstAcct).Text, "~", lst$()
    fl$ = Join$(lst$(), Chr$(13) + Chr$(10))
    Open WorkFile$ For Output As #1
    For j = LBound(lst) To UBound(lst)
        Print #1, lst$(j)
    Next
    Close #1
    Saved = -1
    _MessageBox "Saved", WorkFile$
End Sub

'$include:'GUIb.BM'
