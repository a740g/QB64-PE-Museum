Option _Explicit ' updated 2022-12-06 fixes with major change to LstBox control
'$include:'GUIb.BI'

'   Set Globals from BI
Xmax = 1200: Ymax = 700: GuiTitle$ = "Gradebook Editor GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' << arial works well for pixel sizes 6 to 128 .FontH

' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long btnGetFile, lbClass, lbGrade, lbRName, lbSelName, tbTestCol, tbScore, btnChange, lblGrade, lstGrades
btnGetFile = NewControl(1, 10, 10, 340, 40, "Get a Class.txt File", "")
lbClass = NewControl(6, 10, 60, 1180, 20, "", "")
con(lbClass).FontH = 16
con(lbClass).FC = C3(52)
drwLbl lbClass

lbGrade = NewControl(6, 10, 90, 1180, 20, "", "")
con(lbGrade).FontH = 16
con(lbGrade).FC = C3(52)
drwLbl lbClass

lbRName = NewControl(6, 10, 138, 450, 20, "Row = Name", "")
con(lbRName).FontH = 20
con(lbRName).Align = 2
con(lbRName).FC = White
drwLbl lbRName

lbSelName = NewControl(6, 10, 165, 455, 20, "", "")
con(lbSelName).FontH = 20
con(lbSelName).Align = 2
con(lbSelName).FC = C3(2)
drwLbl lbSelName

tbTestCol = NewControl(2, 490, 160, 200, 30, "", "Test Col")
tbScore = NewControl(2, 740, 160, 200, 30, "", "Score")
btnChange = NewControl(1, 990, 140, 200, 50, "Change", "")

lblGrade = NewControl(6, 10, 210, 1180, 20, "Name  \  Test Col____ 1____ 2____3____ 4____ 5____6____ 7____ 8____ 9___ 10_ Sum__Ave", "")
con(lblGrade).FontH = 16
con(lblGrade).Align = 1
con(lblGrade).FC = C3(0)
drwLbl lblGrade

lstGrades = NewControl(3, 10, 230, 1180, 460, "", "")
' End GUI Controls

Dim Shared grades(0 To 12, 1 To 50) As String ' this has 13 columns 0 for name, 1 to 10 for test scores, 11 totals, 12 averages
Dim Shared saveFile(1 To 50) As String
Dim Shared gradeFile$, maxStudents
Dim Shared As Long selRow

MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    Dim fl$, baseName$, aName$
    Dim As Long c, j
    Select Case i
        Case btnGetFile ' look for x - Class.txt files
            fl$ = _OpenFileDialog$("Select an: *Class.txt, file for Student List", ExePath$ + OSslash$ + "*Class.txt", "*Class.txt", "")
            If Right$(fl$, 9) = "Class.txt" Then
                Erase grades
                Erase saveFile
                con(lbSelName).Text = ""
                drwLbl lbSelName
                con(tbTestCol).Text = ""
                drwTB tbTestCol
                con(tbScore).Text = ""
                drwTB tbScore
                con(lbClass).Text = fl$
                drwLbl lbClass
                baseName$ = Mid$(fl$, 1, InStr(fl$, "Class.txt") - 1)
                gradeFile$ = baseName$ + "Gradebook.dat"
                con(lbGrade).Text = gradeFile$
                drwLbl lbGrade
                If _FileExists(gradeFile$) Then 'load it
                    Open gradeFile$ For Input As #1
                    While Not EOF(1)
                        j = j + 1
                        Line Input #1, fl$
                        If _Trim$(Mid$(fl$, 1, 15)) <> "" Then ' not blank line
                            grades(0, j) = Mid$(fl$, 1, 15)
                            For c = 1 To 12
                                grades(c, j) = Mid$(fl$, (c - 1) * 6 + 16, 6)
                            Next
                        End If
                        If j = 50 Then Exit While
                    Wend
                    Close #1
                Else 'get started with names in column 0
                    Open fl$ For Input As #1
                    While Not EOF(1)
                        j = j + 1
                        Input #1, aName$
                        grades(0, j) = Right$(Space$(15) + aName$, 15)
                        If j = 50 Then Exit While ' limit 50 per class
                    Wend
                    Close #1
                End If
                maxStudents = j
                con(lstGrades).CurPage = 1 ' start new lists on page 1, item 1
                con(lstGrades).CurRow = 1
                displayGrades
                SetActiveControl tbTestCol ' this is the box we want to have focus after load a new file
            Else
                _MessageBox "File Error:", "You need to makeup and select a ____ + Class.txt file in your favorite WP."
            End If
        Case btnChange
            Dim As Long tcol, tscore
            If _Trim$(con(lbSelName).Text) <> "" Then ' have name
                tcol = Val(con(tbTestCol).Text)
                If tcol > 0 And tcol < 11 Then ' inside right col
                    tscore = Val(con(tbScore).Text)
                    If tscore > 0 And tscore < 101 Then ' inside score limits
                        grades(tcol, selRow) = Right$(Space$(6) + _Trim$(Str$(tscore)), 6)
                        ' move down one in list box
                        If selRow < maxStudents Then
                            If con(lstGrades).CurRow + 1 > con(lstGrades).RowsPPg Then
                                con(lstGrades).CurPage = con(lstGrades).CurPage + 1
                                con(lstGrades).CurRow = 1
                            Else
                                con(lstGrades).CurRow = con(lstGrades).CurRow + 1
                            End If
                        End If
                        ActiveControl = tbScore ' make active control this testbox
                        displayGrades
                        LstSelectEvent lstGrades ' this will show new name highlighted in list box
                        con(tbScore).Text = "" ' clear last score
                        con(tbScore).CurSec = 1 ' reset text box numbers
                        con(tbScore).CurCol = 1
                        con(tbScore).MaxChars = 1
                        SetActiveControl tbScore
                    End If
                End If
            End If
    End Select
End Sub

Sub LstSelectEvent (control As Long)
    Select Case control
        Case lstGrades
            selRow = LstHighliteNum&(lstGrades)
            con(lbSelName).Text = grades(0, selRow)
            drwLbl lbSelName
    End Select
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

Sub lblclickevent (i As Long)
    i = i
End Sub

Sub displayGrades ' converts the values in Grades array to line to display
    Dim As Long r, t, n, c, a
    Dim Build$
    For r = 1 To 50
        If _Trim$(grades(0, r)) <> "" Then
            grades(0, r) = Right$(Space$(15) + grades(0, r), 15)
            Build$ = grades(0, r)
            t = 0: n = 0
            For c = 1 To 10
                a = Int(Val(_Trim$(grades(c, r))))
                If a <> 0 Then n = n + 1: t = t + a
                If a <> 0 Then
                    Build$ = Build$ + Right$(Space$(6) + grades(c, r), 6)
                Else
                    Build$ = Build$ + Space$(6)
                End If
            Next
            If n > 0 Then
                grades(11, r) = Right$(Space$(6) + _Trim$(Str$(t)), 6)
                Build$ = Build$ + grades(11, r)
            Else
                Build$ = Build$ + Space$(6)
            End If
            If n > 0 Then
                grades(12, r) = Right$(Space$(6) + _Trim$(Str$(Int(t / n + .5))), 6)
                Build$ = Build$ + grades(12, r)
            Else
                Build$ = Build$ + Space$(6)
            End If
            saveFile(r) = Build$
        End If
    Next
    con(lstGrades).Text = Join$(saveFile(), "~")
    Open gradeFile$ For Output As #1 ' filing   ' keep file up to date in case bug out before proper close
    For r = 1 To 50
        Print #1, saveFile(r)
    Next
    Close #1
    drwLst lstGrades
End Sub

'$include:'GUIb.BM'
