Option _Explicit ' Controls Editor GUIb  2022-12-14
' b+ build from GUI Forms Designer 2022-06-22 post + GUI Get Filename 20220-06-16
' 2022-12-10 Are we ready for the next Gui version? Another makeover!
' Goal one line tbFields, All buttons to lstMenu OK
' Now more edit abilities. Can we draw NewLabels too?

'    DO NOT Put more than one item in a List Box for text val, because the control LstCon needs to be split by same delimiter

'    DO NOT use () in text or label boxes try [] or {} Sliders look good with [] for upper and lower limits text

'$include:'GUIb.BI'

'   Set Globals from BI   You spec here your Font File Screen Width = Xmax, Screen Height = Ymax and Gui app Title
Xmax = 1270: Ymax = 740: GuiTitle$ = "Controls Editor" ' <<<<<  Window size shared throughout program
OpenWindow Xmax, Ymax, GuiTitle$, "arial.TTF" ' need to do this before drawing anything from NewControls

'   Dim and set Globals for GUI app  Controls for sMode 1 this app
Dim Shared As Long TbName, TbType, TbX, TbY, TbW, TbH, TbText, TbLabel
Dim Shared As Long LstCon
Dim Shared As Long Badd, Breplace, Binsert
Dim Shared As Long Bcopy, Bdelete, Blayout, Bexit
Dim Shared As Long Bnew, Bopen, Bsav, BsaveAs 'buttons that were ina LstMenu control

' install a Sample set of Controls for testing the Editor
ReDim Shared ControlList$(1 To 5) ' base 1 dynamic
Dim Shared Clist$ ' just for here just for testing some controls without having to start from scratch
Dim Shared As Long NList '          NList tracks ubound
NList = 5
ControlList$(1) = "Pic1 = NewControl(5, 10, 200, 200, 200, " + Chr$(34) + Chr$(34) + ", " + Chr$(34) + "Picture 1" + Chr$(34) + ")"
ControlList$(2) = "Lst1 = NewControl(3, 350, 30, 350, 200, " + Chr$(34) + Chr$(34) + ", " + Chr$(34) + "List Box 1" + Chr$(34) + ")"
ControlList$(3) = "Tb1 = NewControl(2, 200, 30, 100, 30, " + Chr$(34) + Chr$(34) + ", " + Chr$(34) + "Text Box 1" + Chr$(34) + ")"
ControlList$(4) = "Btn1 = NewControl(1, 20, 20, 100, 30, " + Chr$(34) + "Btn 1 Here" + Chr$(34) + ", " + Chr$(34) + Chr$(34) + ")"
ControlList$(5) = "Sld1 = NewControl(4, 20, 600, 500, 30, " + Chr$(34) + "[0 - 100] Slider = " + Chr$(34) + ", " + Chr$(34) + Chr$(34) + ")"
Clist$ = Join$(ControlList$(), "~")

Dim menu$(1 To 18)
Dim Shared lstMenu$ ' save for return from Layout page
menu$(1) = "GUIb.bas File:"
menu$(2) = "     New"
menu$(3) = "     Open"
menu$(4) = "     Save"
menu$(5) = "     Save As"
menu$(6) = " "
menu$(7) = "Fields to Controls List:"
menu$(8) = "     Append to List"
menu$(9) = "     Replace Highlighted"
menu$(10) = "     Insert at Highlighted"
menu$(11) = " "
menu$(12) = "Controls List:"
menu$(13) = "     Copy to Fields (Edit)"
menu$(14) = "     Delete"
menu$(15) = " "
menu$(16) = "LayOut Preview"
menu$(17) = " "
menu$(18) = "Exit"
lstMenu$ = Join$(menu$(), "~")
ReloadMe ' this sets up Controls for Main Editor Window sMode=1

' For moving and resizing Sample controls in what looks like 2nd screen
ReDim Shared C2(1 To 1) As Control 'this is needed for this specific app
ReDim Shared Head$(1 To 1)
Dim Shared NControls2 As Long ' will need to track number of controls in 2nd array

' Globals from GetFile, get a files controls section if there is one for editing
Dim Shared WorkFile$
ReDim Shared FileLines$(1 To 1)
Dim Shared As Long FileControlsStart, FileControlsEnd, Saved
Saved = -1
WorkFile$ = ""
_Title "Controls Editor GUIb - WorkFile: new"

MainRouter ' Coder MUST END PORGRAM WITH SYSTEM or END _EXIT is only way out of MainRouter
checkSaved
System

Sub drwPreviewControl (i As Long) ' much simpler control for placement, size and a little sample of color
    Dim As _Unsigned Long FC, BC
    Select Case C2(i).ConType
        Case 1: FC = C3(800): BC = C3(888) ' red on white
        Case 2: FC = C3(778): BC = C3(225) ' light blue on dark
        Case 3: FC = C3(889): BC = C3(336) 'lighter blue on lighter dark blue
        Case 4: FC = Black: BC = C3(666) ' black on gray
        Case 5: FC = White: BC = Black
        Case 6: FC = C3(50): BC = C3(669)
    End Select
    If C2(i).Label <> "" And C2(i).ConType <> 4 Then
        Line (C2(i).X, C2(i).Y - 22)-Step(C2(i).W, 21), screenBC, BF
        _Font FontHandle&(20)
        Color Black
        _PrintString (C2(i).X + (C2(i).W - _PrintWidth(C2(i).Label)) / 2 + 1, C2(i).Y - 21), C2(i).Label
        Color White
        _PrintString (C2(i).X + (C2(i).W - _PrintWidth(C2(i).Label)) / 2, C2(i).Y - 22), C2(i).Label
    ElseIf C2(i).ConType = 4 Then
        Line (C2(i).X, C2(i).Y - 22)-Step(C2(i).W, 21), screenBC, BF
        _Font FontHandle&(20)
        Color Black
        _PrintString (C2(i).X + (C2(i).W - _PrintWidth(C2(i).Text)) / 2 + 1, C2(i).Y - 21), C2(i).Text
        Color White
        _PrintString (C2(i).X + (C2(i).W - _PrintWidth(C2(i).Text)) / 2, C2(i).Y - 22), C2(i).Text
    End If
    Line (C2(i).X, C2(i).Y)-Step(C2(i).W, C2(i).H), BC, BF
    _Font 16
    Color FC
    _PrintString (C2(i).X, C2(i).Y), LeftOf$(Head$(i), " = ")
End Sub

Sub BtnClickEvent (cntrl As Long)
    Dim As Long i, Pre, screen1, mx, my, mb, j
    Dim test$
    Select Case cntrl
        Case Bnew ' new clear all old
            ReDim ControlList$(1 To 1)
            Clist$ = ""
            NList = 0
            con(LstCon).Text = Clist$
            drwLst LstCon
            ClearTBs
            WorkFile$ = ""
            _Title "Controls Editor GUIb - WorkFile: new"
            Saved = -1

        Case Bopen ' BtnGetFile ' with option to extract and edit files controls here in this app!
                            test$ = _OpenFileDialog$("Select GUI File to Start/Edit Controls",_
                             ExePath$ + OSslash$ + "*GUIb.bas", "*GUIb.bas", "GUIb.bas files")
            If test$ <> "" Then ' load it
                WorkFile$ = test$
                _Title "Controls Editor GUIb - WorkFile: " + WorkFile$
                'load it's controls if any found   this is going to be good!
                ReDim FileLines$(1 To 1) ' zero out
                FileControlsStart = 0
                FileControlsEnd = 0
                ReDim ControlList$(1 To 1)
                NList = 0
                i = 0
                Open WorkFile$ For Input As #1
                While Not EOF(1)
                    i = i + 1
                    ReDim _Preserve FileLines$(1 To i)
                    Line Input #1, FileLines$(i)
                    If _Trim$(FileLines$(i)) = "' GUI Controls" Then
                        FileControlsStart = i
                    ElseIf _Trim$(FileLines$(i)) = "' End GUI Controls" Then
                        FileControlsEnd = i
                    ElseIf (FileControlsStart > 0) And (FileControlsEnd = 0) Then ' inside controls list
                        If InStr(FileLines$(i), " = NewControl(") > 0 Then ' add control to list
                            NList = NList + 1
                            ReDim _Preserve ControlList$(1 To NList)
                            ControlList$(NList) = FileLines$(i)
                        End If
                    End If
                Wend
                Close #1
                con(LstCon).Text = Join$(ControlList$(), "~")
                drwLst LstCon
                Saved = -1
                'Else use last workfile
            End If

        Case Bsav ' BtnFile
            saveWork

        Case BsaveAs ' save as
            WorkFile$ = "" ' like a new file
            _Title "Controls Editor GUIb -  WorkFile: new" ' in case user cancels
            saveWork

        Case Badd 'BtnAdd
            If OKTBs Then
                NList = NList + 1
                ReDim _Preserve ControlList$(LBound(ControlList$) To NList)
                ControlList$(NList) = NewControlStr$
                con(LstCon).MaxLines = NList
                con(LstCon).Text = Join$(ControlList$(), "~")
                drwLst LstCon
                Saved = 0
            End If

        Case Breplace ' replace highlighted
            If OKTBs Then
                j = LstHighliteNum(LstCon)
                ControlList$(j) = NewControlStr$
                Clist$ = Join$(ControlList$(), "~")
                con(LstCon).Text = Clist$
                drwLst LstCon
                Saved = 0
            End If

        Case Binsert ' insert over highlighted
            If OKTBs Then
                j = LstHighliteNum(LstCon)
                NList = NList + 1
                ReDim _Preserve ControlList$(LBound(ControlList$) To NList)
                For i = NList To j + 1 Step -1
                    ControlList$(i) = ControlList$(i - 1)
                Next
                ControlList$(j) = NewControlStr$
                Clist$ = Join$(ControlList$(), "~")
                con(LstCon).Text = Clist$
                drwLst LstCon
                Saved = 0
            End If

        Case Bcopy ' BtnEdit ? Copy to Fields
            If LstHighliteItem$(LstCon) <> "" Then
                con(TbName).Text = _Trim$(LeftOf$(LstHighliteItem$(LstCon), " ="))
                drwTB TbName
                ReDim T$(1 To 1)
                Split RightOf$(LstHighliteItem$(LstCon), "NewControl("), ", ", T$()
                con(TbType).Text = _Trim$(T$(1))
                drwTB TbType
                con(TbX).Text = _Trim$(T$(2))
                drwTB TbX
                con(TbY).Text = _Trim$(T$(3))
                drwTB TbY
                con(TbW).Text = _Trim$(T$(4))
                drwTB TbW
                con(TbH).Text = _Trim$(T$(5))
                drwTB TbH
                con(TbText).Text = LeftOf$(RightOf$(T$(6), Chr$(34)), Chr$(34)) 'no trim
                drwTB TbText
                con(TbLabel).Text = LeftOf$(RightOf$(T$(7), Chr$(34)), Chr$(34)) 'no trim
                drwTB TbLabel
            End If

        Case Bdelete '  BtnDelete
            j = LstHighliteNum&(LstCon)
            For i = j To NList - 1
                ControlList$(i) = ControlList$(i + 1)
            Next
            NList = NList - 1
            ReDim _Preserve ControlList$(1 To NList)
            con(LstCon).Text = Join$(ControlList$(), "~")
            drwLst LstCon
            Saved = 0

        Case Blayout 'BtnPreview
            'make a new image from ControlList$ in View by loading a control array with controls from list

            ' get the ControlList$ into a control type array
            ReDim C2(1 To 1) As Control
            ReDim Head$(1 To 1) 'save headers of accepted controls to rebuild list later
            NControls2 = 0 ' start 1 less than above count actual controls long enough to be legit
            For i = 1 To UBound(ControlList$) 'load c2() control array
                If Len(ControlList$(i)) > 20 Then 'hardly the best test for legit control line
                    NControls2 = NControls2 + 1
                    ReDim _Preserve C2(1 To NControls2) As Control '< very important fix! (1 to ...)
                    ReDim _Preserve Head$(1 To NControls2)
                    'Btn1 = NewControl(1, 20, 20, 100, 30, " + Chr$(34) + "Btn 1 Here" + Chr$(34) + ", "+ chr$(34) + "label"+chr$(34)+ ")"  'new sample line
                    Head$(NControls2) = LeftOf$(ControlList$(i), "(") + "("
                    ReDim s$(1 To 1)
                    Split LeftOf$(RightOf$(ControlList$(i), "("), ")"), ", ", s$()
                    C2(NControls2).ConType = Val(s$(1))
                    C2(NControls2).X = Val(s$(2))
                    C2(NControls2).Y = Val(s$(3))
                    C2(NControls2).W = Val(s$(4))
                    C2(NControls2).H = Val(s$(5))
                    C2(NControls2).Text = LeftOf$(RightOf$(s$(6), Chr$(34)), Chr$(34))
                    C2(NControls2).Label = LeftOf$(RightOf$(s$(7), Chr$(34)), Chr$(34))
                End If
            Next

            ' snapshot of current screen
            screen1 = _NewImage(_Width, _Height, 32)
            _PutImage , 0, screen1 ' save first screen image so don't have to redraw
            ' background for moving and resizing controls
            Pre = _NewImage(_Width, _Height, 32) 'setup back image for controls
            Color White, screenBC
            Cls
            _Font 16
            Print "<" ' this is magic return to main screen 'button'
            Color &H88000000
            drawGridRect 0, 0, _Width - 1, _Height - 1, 10, 20
            _Display
            _PutImage , 0, Pre ' background grid ready

            Do ' move controls around and resize them
                _PutImage , Pre, 0 ' clear
                For j = 1 To NControls2
                    drwPreviewControl j
                Next
                _Display
                While _MouseInput: Wend ' poll mouse for mb events
                mx = 10 * Int((_MouseX + 5) / 10): my = 10 * Int((_MouseY + 5) / 10): mb = _MouseButton(1)

                If mb Then ' check where top, left for moving,  bottom right for resizing
                    If mx <= 10 And my <= 20 Then Exit Do
                    For i = NControls2 To 1 Step -1 ' last drawn is first checked in case overlap another control

                        'see if first click is inside box top, left corner = move corner
                        If (mx >= C2(i).X) And (mx <= C2(i).X + 20) Then
                            If (my >= C2(i).Y) And (my <= C2(i).Y + 20) Then ' yes we are on a moving corning

                                While mb ' so while mb show controls and ghost of control to be moved
                                    _PutImage , Pre, 0 ' clear  draw controls update control layout ghost
                                    For j = 1 To NControls2 'while showing controls
                                        drwPreviewControl j
                                        If j = i Then ' highlite the control we are going to move
                                            Line (C2(i).X, C2(i).Y)-Step(C2(i).W, C2(i).H), White, B
                                        End If
                                    Next
                                    While _MouseInput: Wend 'continue ghost until mb is released....
                                    mx = 10 * Int((_MouseX + 5) / 10): my = 10 * Int((_MouseY + 5) / 10): mb = _MouseButton(1)
                                    Line (mx, my)-Step(C2(i).W, C2(i).H), White, B ' show position in layout
                                    _Display
                                    _Limit 200
                                Wend
                                ' mb released set new loacation
                                C2(i).X = mx: C2(i).Y = my ' reset control new place and draw it
                                drwPreviewControl i
                                _Display
                                Exit For ' loop around  shouldn't do another control
                            End If ' move x corner
                        End If ' move y corner

                        'still here  try resize corners
                        'see if first click is inside box in bottom left corner
                        If (mx >= (C2(i).X + C2(i).W - 20)) And ((mx <= C2(i).X + C2(i).W)) Then
                            If (my >= (C2(i).Y + C2(i).H - 20)) And (my <= C2(i).Y + C2(i).H) Then 'yes, resize corner
                                While mb ' constantly update screen with ghost of new size
                                    _PutImage , Pre, 0 ' clear old
                                    For j = 1 To NControls2 'while showing controls
                                        drwPreviewControl j
                                        If j = i Then ' highlite the control we are going to move
                                            Line (C2(i).X, C2(i).Y)-Step(C2(i).W, C2(i).H), White, B
                                        End If
                                    Next
                                    While _MouseInput: Wend ' poll mouse until mb is released
                                    mx = 10 * Int((_MouseX + 5) / 10): my = 10 * Int((_MouseY + 5) / 10): mb = _MouseButton(1)
                                    If (mx > C2(i).X) And (my > C2(i).Y) Then ' check resize legit cant go past left and up of x, y corner
                                        Line (C2(i).X, C2(i).Y)-(mx, my), White, B ' ghost it
                                    End If
                                    _Display
                                    _Limit 200
                                Wend
                                If mx > C2(i).X And my > C2(i).Y Then ' resize legit?
                                    C2(i).W = mx - C2(i).X: C2(i).H = my - C2(i).Y
                                    drwPreviewControl i
                                    _Display
                                    Exit For ' dont check any more controls on this loop
                                End If
                            End If ' have resize corner y
                        End If ' have resize corner x
                    Next ' control check corner
                End If ' have mb
                _Limit 400 ' is case just sitting there
            Loop Until _KeyDown(60) ' press < to get back out of this screen add to instructions

            ReDim ControlList$(1 To NControls2) ' for update LstCon of main screen
            For i = 1 To NControls2
                'Pic1 = NewControl(5, 10, 200, 200, 200, " + Chr$(34) + "Picture 1" + Chr$(34) + ")"

        ControlList$(i) = head$(i) + TS$(c2(i).ConType) + ", " + TS$(c2(i).X) + ", " + TS$(c2(i).Y) +_
        ", " + TS$(c2(i).W) + ", " + TS$(c2(i).H) + ", "  + Chr$(34) + c2(i).Text + Chr$(34) + ", "  +_
        Chr$(34) + c2(i).label + Chr$(34)+ ")"

            Next
            con(LstCon).Text = Join$(ControlList$(), "~") ' update LstCon's .text from which the list is created
            _PutImage , screen1, 0 ' put first screen image back
            drwLst LstCon 'redraw the controls list
            _Display ' before return dump temp images
            _FreeImage Pre
            _FreeImage screen1
            Saved = 0 ' just assume something was changed in layout

        Case Bexit
            checkSaved
            System

    End Select
End Sub

Sub ClearTBs
    con(TbName).Text = ""
    drwTB TbName
    con(TbType).Text = ""
    drwTB TbType
    con(TbX).Text = "0"
    drwTB TbX
    con(TbY).Text = "0"
    drwTB TbY
    con(TbW).Text = "0"
    drwTB TbW
    con(TbH).Text = "0"
    drwTB TbH
    con(TbText).Text = ""
    drwTB TbText
    con(TbLabel).Text = ""
    drwTB TbLabel
End Sub

Function NewControlStr$
    ' check that strings aren't empty
    If OKTBs Then

NewControlStr$ = con(TbName).Text + " = NewControl(" + con(TbType).Text + ", " +_
con(TbX).Text + ", " + con(TbY).Text +", " + con(TbW).Text + ", " + con(TbH).Text + ", " +_
Chr$(34) + con(TbText).Text + Chr$(34) + ", " + Chr$(34) + con(TbLabel).Text + Chr$(34) + ")"

    End If
End Function

Function OKTBs&
    Dim As Long testT, testW, testH
    ' check that strings aren't empty
    If _Trim$(con(TbName).Text) <> "" Then
        If _Trim$(con(TbType).Text) <> "" Then
            testT = Val(_Trim$(con(TbType).Text))
            If testT > 0 And testT < 7 Then
                If _Trim$(con(TbX).Text) <> "" Then
                    If _Trim$(con(TbY).Text) <> "" Then
                        If _Trim$(con(TbW).Text) <> "" Then
                            testW = Val(_Trim$(con(TbW).Text))
                            If testW > 30 Then
                                If _Trim$(con(TbH).Text) <> "" Then
                                    testH = Val(_Trim$(con(TbH).Text))
                                    If testH >= 20 Then
                                        OKTBs& = -1
                                        Exit Function
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If
            End If
        End If
    End If
    _MessageBox "Error:", "Bad Values or missing strings in Text Box(es).", "error"
End Function

Sub ReloadMe ' first 10 controls are for this Controls Editor
    NControls = 0
    TbName = NewControl(2, 10, 30, 260, 30, "", "Name = Handle")
    TbType = NewControl(2, 280, 30, 80, 30, "", "Type")
    TbX = NewControl(2, 370, 30, 80, 30, "0", "X")
    TbY = NewControl(2, 460, 30, 80, 30, "0", "Y")
    TbW = NewControl(2, 550, 30, 80, 30, "0", "W")
    TbH = NewControl(2, 640, 30, 80, 30, "0", "H")
    TbText = NewControl(2, 730, 30, 260, 30, "", "Text")
    TbLabel = NewControl(2, 1000, 30, 260, 30, "", "Label")

    Badd = NewControl(1, 10, 110, 350, 25, "Append", "Fields to Controls List:")
    Breplace = NewControl(1, 10, 140, 350, 25, "Replace Highlighted", "")
    Binsert = NewControl(1, 10, 170, 350, 25, "Insert at Highlighted", "")

    Bcopy = NewControl(1, 10, 245, 350, 25, "Copy to Edit", "Highlighted in Contols:")
    Bdelete = NewControl(1, 10, 275, 350, 25, "Delete", "")

    Blayout = NewControl(1, 10, 350, 350, 25, "Layout Worksheet", "")

    Bnew = NewControl(1, 10, 425, 350, 25, "New", "File:")
    Bopen = NewControl(1, 10, 455, 350, 25, "Open", "")
    Bsav = NewControl(1, 10, 485, 350, 25, "Save", "")
    BsaveAs = NewControl(1, 10, 515, 350, 25, "Save As", "")

    Bexit = NewControl(1, 10, 605, 350, 25, "Exit", "")

    LstCon = NewControl(3, 370, 110, 890, 520, Clist$, "Controls List:")
End Sub

Sub checkSaved
    Dim As Long a
    If Saved = 0 Then
        a = _MessageBox("Save work?", "Do you want to save changes to " + WorkFile$,_
         "yesno", "question")

        If a = 1 Then saveWork
    End If
End Sub

Sub saveWork
    Dim answer$
    Dim As Long yn, i
    ' now fix this up for working with .bas file and does it have controls already
    ' if the WorkFile$ is "untitled.bas"  then no controls to work around
    If WorkFile$ = "" Then ' the whole works! assume we are starting a new file
        answer$ = _SaveFileDialog$("Save File As:", ExePath$ + OSslash$ + "*GUIb.bas",_
         "*GUIb.bas", "*GUIb.bas file")

        If answer$ <> "" Then
            If _FileExists(answer$) Then
                yn = _MessageBox("Write Over Existing File?", answer$ +_
                 ", File already exists. Do you wish to Start Over?", "yesno", "warning")
                If yn <> 1 Then Exit Sub
            End If
            WorkFile$ = answer$
            ' damn it dialog lets a non GUIb.bas file pass!
            ' ehhh let it pass crap I hate file shit. getting tired and lazy
            _Title "Controls Editor GUIb - WorkFile: " + WorkFile$
            Open WorkFile$ For Output As #1
            SaveFileStart
            SaveFileMiddle
            SaveFileTail
            Print #1, "'$include:'GUIb.BM'"
            Close
            Saved = -1
            _MessageBox "Saved", WorkFile$
        Else
            Exit Sub ' nothing changed if have a working file going
        End If

    Else ' working with file  in FileLines$() , may or may not have insert section signal
        ' did the workfile$ have a controls section

        Close ' < should not need this?

        Open WorkFile$ For Output As #1
        If FileControlsStart Then ' just insert edited controls section
            For i = 1 To FileControlsStart 'copy back this part of file including the line label
                Print #1, FileLines$(i)
            Next
            SaveFileMiddle ' insert the new / edited controls
            For i = FileControlsEnd To UBound(FileLines$) 'the rest of the file
                Print #1, FileLines$(i)
            Next
        Else '  add GUI at start, insert bas file then final BM include
            SaveFileStart
            SaveFileMiddle
            SaveFileTail
            For i = 1 To UBound(FileLines$) '  now the bas file
                Print #1, FileLines$(i)
            Next
            Print #1, "'$include:'GUIb.BM'" ' finally at the end
        End If
        Close #1
        Saved = -1
        _MessageBox "Saved", WorkFile$

    End If
End Sub

' saving to file ===================================================================================
Sub SaveFileStart
    Print #1, "'$include:'GUIb.BI'"
    Print #1, "'   Set Globals from BI              your Title here VVV"
    Print #1, "Xmax = 1280: Ymax = 720: GuiTitle$ = " + Chr$(34) + "untitled_GUIb.bas" +_
     Chr$(34)

    Print #1, "OpenWindow Xmax, Ymax, GuiTitle$, " + Chr$(34) + "arial.ttf" + Chr$(34) +_
     " ' before drawing anything from NewControls"
    Print #1, "' GUI Controls"
End Sub

Sub SaveFileMiddle
    Dim As Long i
    Dim t$, b$
    Print #1, "'                     Dim and set Globals for GUI app"
    ' make a string listing all the control names
    Print #1, "Dim Shared As Long ";
    For i = 1 To UBound(ControlList$)
        t$ = LeftOf$(ControlList$(i), " = NewControl(")
        If _Trim$(t$) <> "" Then
            If Len(b$) Then b$ = b$ + ", " + t$ Else b$ = t$
        End If
    Next
    Print #1, b$ ' all on one line! can cut/edit line later
    ' now copy the whole lines for NewControls section
    For i = 1 To UBound(ControlList$)
        If Len(_Trim$(ControlList$(i))) > 20 Then Print #1, ControlList$(i)
    Next
End Sub

Sub SaveFileTail
    Print #1, "' End GUI Controls"
    Print #1, ""
    Print #1, "MainRouter ' after all controls setup, YOU MUST HANDLE USERS ATTEMPT TO EXIT!"
    Print #1, "System"
    Print #1, ""
    Print #1, "Sub BtnClickEvent (i As Long)"
    Print #1, "   i = i"
    Print #1, "'   Select Case i"
    Print #1, "'   End Select"
    Print #1, "End Sub"
    Print #1, ""
    Print #1, "Sub LstSelectEvent (control As Long)"
    Print #1, "   control = control"
    Print #1, "'   Select Case control"
    Print #1, "'   End Select"
    Print #1, "End Sub"
    Print #1, ""
    Print #1, "Sub SldClickEvent (i As Long)"
    Print #1, "   i = i"
    Print #1, "'   Select Case i"
    Print #1, "'   End Select"
    Print #1, "End Sub"
    Print #1, ""
    Print #1, "Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)"
    Print #1, "   i = i : Pmx = Pmx : Pmy = Pmy"
    Print #1, "'   Select Case i"
    Print #1, "'   End Select"
    Print #1, "End Sub"
    Print #1, ""
    Print #1, "Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)"
    Print #1, "   i = i : MXfracW = MXfracW : MYfracH = MYfracH"
    Print #1, "'   Select Case i"
    Print #1, "'   End Select"
    Print #1, "End Sub"
    Print #1, ""
    Print #1, "Sub LblClickEvent (i As Long)"
    Print #1, "   i = i"
    Print #1, "End Sub"
End Sub

' Keep MainRouter Happy ==========================================================================

Sub lstselectEvent (cntrl As Long) ' attach you button click code in here
    cntrl = cntrl
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

Sub LblClickEvent (i As Long)
    i = i
End Sub

'$include:'GUIb.BM'
