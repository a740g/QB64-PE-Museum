Option _Explicit '
_Title "Edit QB64 Recent Files GUIb" '  b+ started 2023-03-31

'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

' Windows only, mainly because GetBas$ adds a C: to the beginning of what _OpenFileDialog returns
' This matches the C: needed in the other IDE recent list to avoid duplicate listing.

' Edit the following path for recent.bin your QB64pe setup
Const RecentF$ = "C:\Users\Mark\Desktop\3_6 qb64pe_win-x64-3.6.0\qb64pe\internal\temp\recent.bin"

'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'$include:'GUIb.BI'
ReDim Shared fList$(1 To 1024)
Dim Shared nLines
Dim Shared lstRecent$ '                  this is the long ~ delimited string for lstRecent control
Dim Shared Saved

'   Set Globals from BI
Xmax = 1220: Ymax = 680: GuiTitle$ = "Edit QB64 Recent Files GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' before drawing anything from NewControl()

' GUI Controls
'                     Dim and set Globals for GUI app
Dim Shared As Long lstRecent, BInsert, BReplace, BAdd, BDelete, BSav, BExit
lstRecent = NewControl(3, 20, 40, 1180, 580, "", "Recent Files List")
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
lstRecent$ = Join$(fList$(), "~") '        join to long string
con(lstRecent).Text = lstRecent$ '         for lstRecent control
drwLst lstRecent '                         update the control with new list

' ready to edit
MainRouter ' _exit will exit mainRouter but now you must handle ending the program
checkSaved
System

Sub BtnClickEvent (i As Long)
    Dim As Long hiNum, j
    Dim f$, b$

    Select Case i
        Case BInsert
            f$ = GetBas$
            If f$ <> "" Then
                hiNum = LstHighliteNum&(lstRecent)
                If hiNum = 0 Then
                    lstRecent$ = f$ + "~" + lstRecent$
                Else
                    ReDim temp$(1 To 1)
                    Split lstRecent$, "~", temp$()
                    For j = LBound(temp$) To UBound(temp$)
                        If j = hiNum Then
                            If Len(b$) Then b$ = b$ + "~" + f$ Else b$ = f$
                        End If
                        If temp$(j) <> f$ Then ' don't add duplicates
                            If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                        End If
                    Next
                    lstRecent$ = b$
                End If
                con(lstRecent).Text = lstRecent$ '         for lstRecent control
                drwLst lstRecent '                         update the control with new list
                Saved = 0
            End If

        Case BReplace
            f$ = GetBas$
            If f$ <> "" Then
                hiNum = LstHighliteNum&(lstRecent)
                If hiNum = 0 Then ' just add it to top of list
                    lstRecent$ = f$ + "~" + lstRecent$
                Else
                    ReDim temp$(1 To 1)
                    Split lstRecent$, "~", temp$()
                    For j = LBound(temp$) To UBound(temp$)
                        If j = hiNum Then
                            If Len(b$) Then b$ = b$ + "~" + f$ Else b$ = f$
                        Else
                            If temp$(j) <> f$ Then
                                If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                            End If
                        End If
                    Next
                    lstRecent$ = b$
                End If
                con(lstRecent).Text = lstRecent$ '         for lstRecent control
                drwLst lstRecent '                         update the control with new list
                Saved = 0
            End If

        Case BAdd
            f$ = GetBas$
            If f$ <> "" Then
                ReDim temp$(1 To 1)
                Split lstRecent$, "~", temp$()
                For j = LBound(temp$) To UBound(temp$)
                    If temp$(j) <> f$ Then
                        If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                    End If
                Next
                lstRecent$ = b$
                lstRecent$ = lstRecent$ + "~" + f$
                con(lstRecent).Text = lstRecent$ '         for lstRecent control
                drwLst lstRecent '                         update the control with new list
                Saved = 0
            End If

        Case BDelete
            hiNum = LstHighliteNum&(lstRecent)
            If hiNum <> 0 Then
                ReDim temp$(1 To 1)
                Split lstRecent$, "~", temp$()
                For j = LBound(temp$) To UBound(temp$)
                    If j <> hiNum Then
                        If Len(b$) Then b$ = b$ + "~" + temp$(j) Else b$ = temp$(j)
                    End If
                Next
                lstRecent$ = b$
                con(lstRecent).Text = lstRecent$ '         for lstRecent control
                drwLst lstRecent '                         update the control with new list
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
        ans = _MessageBox("Save Work?", "Do you want to save your changes to the Recent.Bin file?", "yesno", "question")
        If ans = 1 Then saveWork
    End If
End Sub

Sub saveWork ' assumes workfile <> "" and correct
    Dim As Long i
    ReDim lst(1 To 1) As String
    Split con(lstRecent).Text, "~", lst$()
    Open RecentF$ For Output As #1
    For i = 1 To UBound(lst$)
        Print #1, ""
        Print #1, _Trim$(lst$(i))
    Next
    Close #1
    Saved = -1
    _MessageBox "Saved:", RecentF$
End Sub

Function GetBas$
    Dim bas$
    bas$ = _OpenFileDialog$("Select a .bas file", "*.bas", "*.bas", "Basic file")
    If bas$ <> "" Then
        If Left$(bas$, 2) <> "C:" Then GetBas$ = "C:" + bas$ Else GetBas$ = bas$
    End If
End Function

'$include:'GUIb.BM'
