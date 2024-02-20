Option _Explicit '
_Title "MyFilesList GUIb" '  b+ 2023-04-10 from Edit Recent Files

'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

' Windows only, mainly because GetFile$ adds a C: to the beginning of what _OpenFileDialog returns
' This matches the C: needed in the other IDE recent list to avoid duplicate listing.

Const RecentF$ = "MyFilesList.txt" ' whatever directory your exe is in (usu same as source)

'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'$include:'GUIb.BI'
ReDim Shared fList$(1 To 1024)
Dim Shared nLines
Dim Shared lstFiles$ '                  this is the long ~ delimited string for lstFile control
Dim Shared Saved

'   Set Globals from BI
Xmax = 1220: Ymax = 680: GuiTitle$ = "Edit MyFilesList.txt GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControl()

' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long lstFile, BInsert, BReplace, BAdd, BDelete, BSav, BExit
lstFile = NewControl(3, 20, 40, 1180, 580, "", "My Files List")
BInsert = NewControl(1, 20, 640, 180, 24, "Insert at Highlight", "")
BReplace = NewControl(1, 220, 640, 180, 24, "Replace at Highlight", "")
BAdd = NewControl(1, 420, 640, 180, 24, "Add (to end)", "")
BDelete = NewControl(1, 620, 640, 180, 24, "Delete Highlighted", "")
BSav = NewControl(1, 820, 640, 180, 24, "Save", "")
BExit = NewControl(1, 1020, 640, 180, 24, "Exit", "")
' End GUI Controls

Saved = -1

Dim fl$
'          join array to long string delimited by ~ for lst control
If _FileExists(RecentF$) Then
    Open RecentF$ For Input As #1 '            load the file into buf$
    While Not EOF(1)
        Line Input #1, fl$
        fl$ = _Trim$(fl$)
        If fl$ <> "" Then
            nLines = nLines + 1
            fList$(nLines) = fl$
        End If
    Wend
    Close #1
End If
lstFiles$ = Join$(fList$(), "~") '        join to long string
con(lstFile).Text = lstFiles$ '         for lstFile control
drwLst lstFile '                         update the control with new list

' ready to edit
MainRouter ' _exit will exit mainRouter but now you must handle ending the program
checkSaved
System

Sub BtnClickEvent (i As Long)
    Dim As Long hiNum, j
    Dim f$, b$

    Select Case i
        Case BInsert
            f$ = GetFile$
            If f$ <> "" Then
                hiNum = LstHighliteNum&(lstFile)
                If hiNum = 0 Then
                    lstFiles$ = f$ + "~" + lstFiles$
                Else
                    ReDim temp$(1 To 1)
                    Split lstFiles$, "~", temp$()
                    For j = LBound(temp$) To UBound(temp$)
                        If j = hiNum Then
                            If Len(b$) Then b$ = b$ + "~" + f$ Else b$ = f$
                        End If
                        If temp$(j) <> f$ Then ' don't add duplicates
                            If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                        End If
                    Next
                    lstFiles$ = b$
                End If
                con(lstFile).Text = lstFiles$ '         for lstFile control
                drwLst lstFile '                         update the control with new list
                Saved = 0
            End If

        Case BReplace
            f$ = GetFile$
            If f$ <> "" Then
                hiNum = LstHighliteNum&(lstFile)
                If hiNum = 0 Then ' just add it to top of list
                    lstFiles$ = f$ + "~" + lstFiles$
                Else
                    ReDim temp$(1 To 1)
                    Split lstFiles$, "~", temp$()
                    For j = LBound(temp$) To UBound(temp$)
                        If j = hiNum Then
                            If Len(b$) Then b$ = b$ + "~" + f$ Else b$ = f$
                        Else
                            If temp$(j) <> f$ Then
                                If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                            End If
                        End If
                    Next
                    lstFiles$ = b$
                End If
                con(lstFile).Text = lstFiles$ '         for lstFile control
                drwLst lstFile '                         update the control with new list
                Saved = 0
            End If

        Case BAdd
            f$ = GetFile$
            If f$ <> "" Then
                ReDim temp$(1 To 1)
                Split lstFiles$, "~", temp$()
                For j = LBound(temp$) To UBound(temp$)
                    If temp$(j) <> f$ Then
                        If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                    End If
                Next
                lstFiles$ = b$
                lstFiles$ = lstFiles$ + "~" + f$
                con(lstFile).Text = lstFiles$ '         for lstFile control
                drwLst lstFile '                         update the control with new list
                Saved = 0
            End If

        Case BDelete
            hiNum = LstHighliteNum&(lstFile)
            If hiNum <> 0 Then
                ReDim temp$(1 To 1)
                Split lstFiles$, "~", temp$()
                For j = LBound(temp$) To UBound(temp$)
                    If j <> hiNum Then
                        If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                    End If
                Next
                lstFiles$ = b$
                con(lstFile).Text = lstFiles$ '         for lstFile control
                drwLst lstFile '                         update the control with new list
                Saved = 0
            End If

        Case BSav
            saveWork

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

Sub checkSaved
    Dim As Long ans
    If Saved = 0 Then
        ans = _MessageBox("Save Work?", "Do you want to save your changes to MyFilesList.txt file?", "yesno", "question")
        If ans = 1 Then saveWork
    End If
End Sub

Sub saveWork ' assumes workfile <> "" and correct
    Dim As Long i
    ReDim lst(1 To 1) As String
    Split con(lstFile).Text, "~", lst$()
    Open RecentF$ For Output As #1
    For i = 1 To UBound(lst$)
        Print #1, _Trim$(lst$(i))
    Next
    Close #1
    Saved = -1
    _MessageBox "Saved:", RecentF$
End Sub

Function GetFile$
    Dim bas$
    bas$ = _OpenFileDialog$("Select a file", "*.*", "*.*", "Any file")
    If bas$ <> "" Then
        If Left$(bas$, 2) <> "C:" Then GetFile$ = "C:" + bas$ Else GetFile$ = bas$
    End If
End Function

'$include:'GUIb.BM'
