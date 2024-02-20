Option _Explicit

'$include:'GUIb.BI'

'   Set Globals from BI
Xmax = 1280: Ymax = 700: GuiTitle$ = "Interface with Tabulator GUIb" ' <<<<<  Window size shared throughout program
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' need to do this before drawing anything from NewControls
' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long tbFx, tbVV, btAdd, lsVV, btEdit, btDelete, btPlot, tbStart, tbEnd, pPlot

tbFx = NewControl(2, 10, 40, 560, 30, "", "Formula F(x)")
tbVV = NewControl(2, 10, 110, 490, 30, "", "Variable = Value")
btAdd = NewControl(1, 510, 110, 60, 30, "Add", "")
lsVV = NewControl(3, 10, 180, 560, 380, "", "Variable and Value List:")
btEdit = NewControl(1, 10, 570, 180, 40, "Edit", "")
btDelete = NewControl(1, 200, 570, 180, 40, "Delete", "")
btPlot = NewControl(1, 390, 570, 180, 40, "Plot", "")
tbStart = NewControl(2, 10, 650, 180, 40, "", "X:Start")
tbEnd = NewControl(2, 200, 650, 180, 40, "", "X:End")
pPlot = NewControl(5, 580, 0, 700, 700, "", "")
' End GUI Controls

MainRouter ' after all controls setup
System

'  EDIT these to your programs needs
Sub BtnClickEvent (i As Long) ' attach you button click code in here
    Dim item$, lastx, lasty
    Select Case i
        Case btAdd
            If _Trim$(con(tbVV).Text) <> "" Then
                If _Trim$(con(lsVV).Text) <> "" Then
                    con(lsVV).Text = con(lsVV).Text + "~" + _Trim$(con(tbVV).Text)
                Else
                    con(lsVV).Text = con(tbVV).Text
                End If
                con(tbVV).Text = ""
                drwTB tbVV
                drwLst lsVV
            End If
        Case btEdit
            ReDim lst(1 To 1) As String
            Split con(lsVV).Text, "~", lst()
            item$ = LstHighliteItem$(lsVV)
            con(tbVV).Text = item$
            drwTB tbVV
            Remove item$, lst()
            con(lsVV).Text = Join$(lst(), "~")
            drwLst lsVV
        Case btDelete ' what is the highlited
            ReDim lst(1 To 1) As String
            Split con(lsVV).Text, "~", lst()
            item$ = LstHighliteItem$(lsVV)
            Remove item$, lst()
            con(lsVV).Text = Join$(lst(), "~")
            drwLst lsVV
        Case btPlot
            ' make call to Tabulator (in Shell)
            ReDim As Long j
            Dim xStart, xEnd, yMin, yMax, dx, y(700), dy, x, y
            Dim fx$
            ReDim lst(0)
            xStart = Val(_Trim$(con(tbStart).Text)): xEnd = Val(_Trim$(con(tbEnd).Text))
            dx = (xEnd - xStart) / 700: fx$ = _Trim$(LCase$(con(tbFx).Text))
            Split con(lsVV).Text, "~", lst()
            item$ = Join$(lst(), Chr$(10)) ' reusing something already DIM's this is our variable list delimited by chr$(10)
            item$ = LCase$(item$) ' didn't do well with var in all caps
            ReDim arr$(0)
            If dx = 0 Then Cls: Print "dx = 0": End
            forXEqual xStart, xEnd, dx, fx$, 0, item$, arr$() ' 0 = using radians for trig
            ' hopefully arr$ has the data we need to make our plot

            'debug
            'item$ = Join$(arr$(), Chr$(10)) ' debug
            'mBox "Our Data Array", item$ ' debug   with 700 items in table probably don't want to check in mbox

            ' need to find min, max y and convert values to number
            For j = 0 To 700
                y(j) = Val(_Trim$(RightOf$(arr$(j), " ")))
                If j = 0 Then
                    yMax = y(j): yMin = y(j)
                Else
                    If y(j) < yMin Then
                        yMin = y(j)
                    ElseIf y(j) > yMax Then
                        yMax = y(j)
                    End If
                End If
            Next j
            yMin = yMin - 10
            yMax = yMax + 10
            dy = yMax - yMin
            If dy <> 0 Then ' dont divide by 0
                _Dest con(pPlot).ImgHnd
                Line (0, 0)-Step(con(pPlot).W - 1, con(pPlot).H - 1), &HFFEEEEFF, BF

                If 0 >= xStart And 0 <= xEnd Then
                    Line (700 * (0 - xStart) / (xEnd - xStart), 0)-Step(0, 700), Black ' y axis
                    For y = -10 To 10
                        Line (700 * (-xStart) / (xEnd - xStart) - 3, 700 - 700 * (y - yMin) / (yMax - yMin))-Step(6, 0), Black
                    Next
                End If

                If 0 >= yMin And 0 <= yMax Then
                    Line (0, 700 - 700 * (0 - yMin) / (yMax - yMin))-Step(700, 0), Black ' y axis
                    For x = -10 To 10
                        Line (700 * (x - xStart) / (xEnd - xStart), 700 - 700 * (0 - yMin) / (yMax - yMin) - 3)-Step(0, 6), Black ' y axis
                    Next
                End If
                For j = 0 To 700
                    Circle (j, con(pPlot).H - 1 - 700 * (y(j) - yMin) / dy), 1, &HFF0000FF
                    PSet (j, con(pPlot).H - 1 - 700 * (y(j) - yMin) / dy), &HFF0000FF
                    If j > 0 Then Line (lastx, lasty)-(j, con(pPlot).H - 1 - 700 * (y(j) - yMin) / dy), &HFF0000FF
                    lastx = j: lasty = con(pPlot).H - 1 - 700 * (y(j) - yMin) / dy
                Next
                _Dest 0
                _PutImage (con(pPlot).X, con(pPlot).Y)-Step(con(pPlot).W, con(pPlot).H), con(pPlot).ImgHnd, 0
            End If

    End Select
End Sub

Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long) ' attach your Picture click code in here
    i = i: Pmx = Pmx: Pmy = Pmy
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
End Sub

Sub lblclickevent (i As Long)
    i = i
End Sub

Sub forXEqual (start, toFinish, incStep, formula$, dFlag As Long, variablesCHR10$, outputArr$())
    Dim fLine$, tabPath$
    tabPath$ = ExePath + OSslash + "Tabulator" + OSslash
    If _FileExists(tabPath$ + "TableOut.txt") Then Kill tabPath$ + "TableOut.txt"
    Open tabPath$ + "TableIn.txt" For Output As #1
    Print #1, _Trim$(Str$(start))
    Print #1, _Trim$(Str$(toFinish))
    Print #1, _Trim$(Str$(incStep))
    Print #1, formula$
    Print #1, TS$(dFlag)
    Print #1, variablesCHR10$
    Close #1
    ReDim outputArr$(0)
    Shell _Hide tabPath$ + "Tabulator.exe"
    _Delay .5 ' sometimes it compiles in time sometimes not, 3 reduces the nots
    If _FileExists(tabPath$ + "TableOut.txt") Then
        Open tabPath$ + "TableOut.txt" For Input As #1
        While Not EOF(1)
            Line Input #1, fLine$
            sAppend outputArr$(), fLine$
        Wend
        Close #1
    End If
End Sub

''append to the string array the string item
Sub sAppend (arr() As String, addItem$)
    ReDim _Preserve arr(LBound(arr) To UBound(arr) + 1) As String
    arr(UBound(arr)) = addItem$
End Sub

'$include:'GUIb.BM'

