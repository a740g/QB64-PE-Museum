 Option _Explicit
_Title "GUI Designer w GetFile" 'b+ build from GUI Forms Designer 2022-06-22 post + GUI Get Filename 20220-06-16
' 2022-06-18 still organizing this file with: b+ Very Simple GUI.txt file
' 2022-06-19 compiled first working test form
' 2022-06-21 Today we try and move controls around the Form Designer, the stuff in Preview needs to be moved into Write and Run button.
' 2022-06-22 Debug problems I had moving and resizing controls on the 2nd screen. Finish by reloading the Controls List back into
' the main form's control editor. Post GUI Forms Designer 2022-06-22
' 2022-06-23 assimulate the GetFile form controls into Designer with another screen
' 2022-06-24 I've killed 2 bugs concerning control handles wth the same number by adding another global, sMode, to track what screen =
' set of controls I am on and using. This technique might be the way to do multiple windows, but not all accessable at same time.
' 2022-06-25&26 coding and testing extracting, editing and reinserting Controls in Form Designer. Tested code in real situation, a make
' over of my mod of Ken's Artillery. I loaded, added, edited, moved and resized, deleted Controls about a half dozen times.
' 2022-07-09 GUI Controls Editor Rework with 3 Digit Color, reworked Text Boxes (TB), fontH ? tempted to just say 20 for TB and Lst
' 2022-07-10 Nice updated screen for controls.
' 2022-07-11 Finally TB up and running again better than ever! Now with abreviated Preview Screen which should be called Layout.



'    DO NOT Put more than one item in a List Box for text val, because the control LstCon needs to be split by same delimiter

'$include:'vs GUI.BI'

'==================================================================================================================  vs GUI.BI start

'' direntry.h needs to be in QB64 folder '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< see b+ Very Simple GUI.txt file end
'Declare CustomType Library ".\direntry"
'    Function load_dir& (s As String)
'    Function has_next_entry& ()
'    Sub close_dir ()
'    Sub get_next_entry (s As String, flags As Long, file_size As Long)
'End Declare

''reset your colors here   FC = ForeColor  BC = Back Color  All the RGB32() are right here in constants section!
'Dim Shared As _Unsigned Long Black, White, ScreenBC
'Black = _RGB32(0, 0, 0)
'White = _RGB32(255, 255, 255)
'ScreenBC = _RGB32(168, 168, 224) ' c3(668)

'Type Control ' all are boxes with colors, 1 is active
'    As Long ConType, X, Y, W, H, FontH, N1, N2, N3, N4, N5, N6 ' N1, N2 sometimes controls need extra numbers for special functions
'    As String Text, Text2 ' dims are pixels  Text2 is for future selected text from list box
'    As _Unsigned Long FC, BC
'End Type
'Dim Shared GuiTitle$ ' set in OpenWindow
'Dim Shared curPath$ ' _CWD$ for file stuff
'Dim Shared As Long Xmax, Ymax, NControls, ActiveControl ' This Controls Editor uses same Controls!
'ReDim Shared con(0) As Control
'Dim Shared fontHandle&(6 To 128) ' also Set in OpenWindow the fontHandle& = FontH !!!

'================================================================================================================== vs GUI.BI end

'   Set Globals from BI   You spec here your Font File Screen Width = Xmax, Screen Height = Ymax and Gui app Title
Xmax = 1280: Ymax = 700: GuiTitle$ = "vs GUI Controls Editor" ' <<<<<  Window size shared throughout program
OpenWindow Xmax, Ymax, GuiTitle$, "ARLRDBD.TTF" ' need to do this before drawing anything from NewControls

Dim Shared As Long sMode ' using multiple screen setups for multiple controls sets!!!
sMode = 1 ' main controls add screen , only used in User defined app and controls? not anything concerning BI/BM?
'                right! sMode is not used in vs GUI.BI/BM

' sMode = 2 ' getFile screen before doing a control set

'   Dim and set Globals for GUI app  Controls for sMode 1 this app
Dim Shared As Long BtnGetFile
Dim Shared As Long LblName, TbName, LblType, TBType
Dim Shared As Long LblX, TbX, LblY, TbY, LblW, TbW, LblH, TbH
Dim Shared As Long LblFontH, TbFontH, LblText, TbText
Dim Shared As Long LbFC, TbFCon, LblBC, TbBCon
Dim Shared As Long BtnAdd
Dim Shared As Long LblCon, LstCon
Dim Shared As Long BtnPreview, BtnDelete, BtnEdit, BtnFile


' install a Sample set of Controls for testing the Editor
ReDim Shared ControlList$(1 To 5) ' base 1 dynamic
Dim Shared Clist$ ' just for here just for testing some controls without having to start from scratch
Dim Shared As Long NList '          NList tracks ubound
NList = 5
ControlList$(1) = "Btn1 = NewControl(1, 20, 20, 100, 30, 20, 0, 0, " + Chr$(34) + "Btn 1 Here" + Chr$(34) + ")"
ControlList$(2) = "Tb1 = NewControl(2, 200, 10, 100, 30, 20, 0, 0, " + Chr$(34) + "Text Box 1" + Chr$(34) + ")"
ControlList$(3) = "Lst1 = NewControl(3, 350, 10, 350, 200, 20, 0, 0, " + Chr$(34) + "List Box 1" + Chr$(34) + ")"
ControlList$(4) = "Lbl1 = NewControl(4, 10, 100, 200, 30, 30, 0, 0, " + Chr$(34) + "Label 1" + Chr$(34) + ")"
ControlList$(5) = "Pic1 = NewControl(5, 10, 200, 200, 200, 20, 0, 0, " + Chr$(34) + "Picture 1" + Chr$(34) + ")"
Clist$ = Join$(ControlList$(), "~")

reloadMe ' this sets up Controls for Main Editor Window sMode=1

' For moving and resizing Sample controls in what looks like 2nd screen
ReDim Shared c2(1 To 1) As Control 'this is needed for this specific app
ReDim Shared head$(1 To 1)
Dim Shared NControls2 As Long ' will need to track number of controls in 2nd array

' Globals from GetFile, get a files controls section if there is one for editing
Dim Shared As Long LblPath, LblCurPath, LblDirs, LblFils, LstD, LstF, BtnOK, BtnKill, BtnCancel
Dim Shared WorkFile$
ReDim Shared FileLines$(1 To 1)
Dim Shared As Long FileControlsStart, FileControlsEnd
WorkFile$ = "untitled.bas"

MainRouter ' we're off to the races! after all controls setup

'  EDIT these to your programs needs

Sub drwPreviewControl (i As Long) ' much simpler control for placement, size and a little sample of color
    Dim As _Unsigned Long FC, BC
    Select Case c2(i).ConType
        Case 1
            If c2(i).FC = 0 And c2(i).BC = 0 Then ' use default colors
                FC = C3(800): BC = C3(888)
            Else ' convert to RGB
                FC = C3(c2(i).FC): BC = C3(c2(i).BC)
            End If
        Case 2
            If c2(i).FC = 0 And c2(i).BC = 0 Then ' use default colors
                FC = C3(778): BC = C3(225)
            Else ' convert to RGB
                FC = C3(c2(i).FC): BC = C3(c2(i).BC)
            End If
        Case 3
            If c2(i).FC = 0 And c2(i).BC = 0 Then ' use default colors
                FC = C3(889): BC = C3(336)
            Else ' convert to RGB
                FC = C3(c2(i).FC): BC = C3(c2(i).BC)
            End If
        Case 4
            If c2(i).FC = 0 And c2(i).BC = 0 Then ' use default colors
                FC = C3(889): BC = screenBC
            Else ' convert to RGB
                FC = C3(c2(i).FC): BC = C3(c2(i).BC)
            End If
        Case 5
            If c2(i).FC = 0 And c2(i).BC = 0 Then ' use default colors
                FC = C3(590): BC = C3(40)
            Else ' convert to RGB
                FC = C3(FC): BC = C3(BC)
            End If
    End Select
    Line (c2(i).X, c2(i).Y)-Step(c2(i).W, c2(i).H), BC, BF
    _Font 16
    Color FC
    _PrintString (c2(i).X, c2(i).Y), LeftOf$(head$(i), " = ")
End Sub

Sub BtnClickEvent (cntrl As Long) ' attach you button click code in here
    Dim As Long i, Pre, screen1, mx, my, mb, j
    Dim b$, t$, answer$
    Select Case cntrl
        Case BtnGetFile And sMode = 1 ' with option to extract and edit files controls here in this app!
            ReDim con(0) As Control
            NControls = 0
            sMode = 2 ' only here to enter
            Dim fils$, dirs$
            GetListStrings dirs$, fils$
            Color White, screenBC
            Cls
            ' reload con with get file controls
            LblPath = NewControl(4, 0, 10, _Width, 20, 20, 0, 0, "Current Folder:")
            LblCurPath = NewControl(4, 0, 35, _Width, 20, 16, 151, 668, curPath$)
            LblDirs = NewControl(4, 150, 60, 300, 20, 20, 0, 0, "Sub Directorys:")
            LblFils = NewControl(4, 530, 60, 600, 20, 20, 0, 0, "Files:")
            LstD = NewControl(3, 150, 85, 300, 480, 20, 0, 0, dirs$)
            LstF = NewControl(3, 530, 85, 600, 480, 20, 0, 0, fils$)
            BtnOK = NewControl(1, 150, _Height - 70, 313, 50, 20, 0, 0, "OK that File!")
            BtnCancel = NewControl(1, 483, _Height - 70, 313, 50, 20, 0, 0, "Cancel, no file")
            BtnKill = NewControl(1, 816, _Height - 70, 313, 50, 20, 0, 0, "Kill it!")
            ' let call main router take over now

        Case BtnOK And sMode = 2 ' get file main event use file to extract controls and or insert edited controls
            ' get file name and check it has .bas extension  check if there is anything
            If UCase$(Right$(LstHighliteItem$(LstF), 4)) = ".BAS" Then ' load it
                WorkFile$ = LstHighliteItem$(LstF)
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
            Else
                answer$ = inputBox$("Enter y for yes, if you want to work a .BAS file.", "File selected is not a .BAS file.", 54)
                If answer$ = "y" Then GoTo skipExit
            End If
            ' back to main screen  reverse process that got us here
            Color White, screenBC
            Cls
            ReDim con(0) As Control
            reloadMe ' now updates sMode to 1
            'update lstCon with new ControlList$()
            con(LstCon).Text = Join$(ControlList$(), "~")
            drwLst LstCon, 0
            ActiveControl = 1

            ' and that's it, control back to mainRouter note ControlList$ array untouched
            skipExit:

            'get file event totally inside
        Case BtnKill And sMode = 2 ' don't kill WorkFile$
            If LstHighliteItem$(LstF) <> WorkFile$ Then
                answer$ = inputBox$(LstHighliteItem$(LstF), "Confirm Kill, enter y or n", _Width \ 8 - 7)
                If answer$ = "y" Then
                    Kill LstHighliteItem$(LstF)
                    GetListStrings dirs$, fils$
                    con(LstD).Text = dirs$
                    con(LstF).Text = fils$
                    'con(LblSelFile).Text = ""
                    'drwLbl LblSelFile
                    drwLst LstD, 0
                    drwLst LstF, 0
                End If
            Else
                mBox "File not Killed", "It is the work file loaded into Forms Designer."
            End If

        Case BtnCancel And sMode = 2 ' getfile event
            ' leave WorkFile$ and such alone, just get back to main screen  reverse process that got us here
            Color White, screenBC
            Cls
            ReDim con(0) As Control
            reloadMe 'resets sMode
            ActiveControl = 1
            ' and that's it, control back to mainRouter note ControlList$ array untouched

        Case BtnAdd And sMode = 1
            NList = NList + 1
            ReDim _Preserve ControlList$(LBound(ControlList$) To NList)
            ControlList$(NList) = NewControlStr$(1)
            con(LstCon).N5 = NList
            con(LstCon).Text = Join$(ControlList$(), "~")
            drwLst LstCon, cntrl = ActiveControl

        Case BtnPreview And sMode = 1
            'make a new image from ControlList$ in View by loading a control array with controls from list

            ' get the ControlList$ into a control type array
            ReDim c2(1 To 1) As Control
            ReDim head$(1 To 1) 'save headers of accepted controls to rebuild list later
            NControls2 = 0 ' start 1 less than above count actual controls long enough to be legit
            For i = 1 To UBound(ControlList$) 'load c2() control array
                If Len(ControlList$(i)) > 20 Then 'hardly the best test for legit control line
                    NControls2 = NControls2 + 1
                    ReDim _Preserve c2(1 To NControls2) As Control '< very important fix! (1 to ...)
                    ReDim _Preserve head$(1 To NControls2)
                    'Btn1 = NewControl(1, 20, 20, 100, 30, 20, 0, 0, " + Chr$(34) + "Btn 1 Here" + Chr$(34) + ")"  'new sample line
                    head$(NControls2) = LeftOf$(ControlList$(i), "(") + "("
                    ReDim s$(1 To 1)
                    Split LeftOf$(RightOf$(ControlList$(i), "("), ")"), ", ", s$()
                    c2(NControls2).ConType = Val(s$(1))
                    c2(NControls2).X = Val(s$(2))
                    c2(NControls2).Y = Val(s$(3))
                    c2(NControls2).W = Val(s$(4))
                    c2(NControls2).H = Val(s$(5))
                    c2(NControls2).FontH = Val(s$(6))
                    c2(NControls2).FC = Val(s$(7))
                    c2(NControls2).BC = Val(s$(8))
                    c2(NControls2).Text = LeftOf$(RightOf$(s$(9), Chr$(34)), Chr$(34))
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
                        If (mx >= c2(i).X) And (mx <= c2(i).X + 10) Then
                            If (my >= c2(i).Y) And (my <= c2(i).Y + 10) Then ' yes we are on a moving corning

                                While mb ' so while mb show controls and ghost of control to be moved
                                    _PutImage , Pre, 0 ' clear  draw controls update control layout ghost
                                    For j = 1 To NControls2 'while showing controls
                                        drwPreviewControl j
                                        If j = i Then ' highlite the control we are going to move
                                            Line (c2(i).X, c2(i).Y)-Step(c2(i).W, c2(i).H), White, B
                                        End If
                                    Next
                                    While _MouseInput: Wend 'continue ghost until mb is released....
                                    mx = 10 * Int((_MouseX + 5) / 10): my = 10 * Int((_MouseY + 5) / 10): mb = _MouseButton(1)
                                    Line (mx, my)-Step(c2(i).W, c2(i).H), White, B ' show position in layout
                                    _Display
                                    _Limit 200
                                Wend
                                ' mb released set new loacation
                                c2(i).X = mx: c2(i).Y = my ' reset control new place and draw it
                                drwPreviewControl i
                                _Display
                                Exit For ' loop around  shouldn't do another control
                            End If ' move x corner
                        End If ' move y corner

                        'still here  try resize corners
                        'see if first click is inside box in bottom left corner
                        If (mx >= (c2(i).X + c2(i).W - 10)) And ((mx <= c2(i).X + c2(i).W)) Then
                            If (my >= (c2(i).Y + c2(i).H - 10)) And (my <= c2(i).Y + c2(i).H) Then 'yes, resize corner
                                While mb ' constantly update screen with ghost of new size
                                    _PutImage , Pre, 0 ' clear old
                                    For j = 1 To NControls2 'while showing controls
                                        drwPreviewControl j
                                        If j = i Then ' highlite the control we are going to move
                                            Line (c2(i).X, c2(i).Y)-Step(c2(i).W, c2(i).H), White, B
                                        End If
                                    Next
                                    While _MouseInput: Wend ' poll mouse until mb is released
                                    mx = 10 * Int((_MouseX + 5) / 10): my = 10 * Int((_MouseY + 5) / 10): mb = _MouseButton(1)
                                    If (mx > c2(i).X) And (my > c2(i).Y) Then ' check resize legit cant go past left and up of x, y corner
                                        Line (c2(i).X, c2(i).Y)-(mx, my), White, B ' ghost it
                                    End If
                                    _Display
                                    _Limit 200
                                Wend
                                If mx > c2(i).X And my > c2(i).Y Then ' resize legit?
                                    c2(i).W = mx - c2(i).X: c2(i).H = my - c2(i).Y
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
                ControlList$(i) = head$(i) + TS$(c2(i).ConType) + ", " + TS$(c2(i).X) + ", " + TS$(c2(i).Y) + ", " +_
                 TS$(c2(i).W) + ", " + TS$(c2(i).H) + ", " + TS$(c2(i).FontH) + ", " + TS$(c2(i).FC) + ", " + TS$(c2(i).BC) +_
                  ", " + Chr$(34) + c2(i).Text + Chr$(34) + ")"
            Next
            con(LstCon).Text = Join$(ControlList$(), "~") ' update LstCon's .text from which the list is created
            _PutImage , screen1, 0 ' put first screen image back
            drwLst LstCon, (LstCon = ActiveControl) 'redraw the controls list
            _Display ' before return dump temp images
            _FreeImage Pre
            _FreeImage screen1

        Case BtnDelete And sMode = 1
            If LstHighliteItem$(LstCon) <> "" Then
                Remove LstHighliteItem$(LstCon), ControlList$()
                con(LstCon).N5 = UBound(ControlList$)
                NList = UBound(ControlList$)
                con(LstCon).Text = Join$(ControlList$(), "~")
                con(LstCon).N2 = 1 ' better than leaving it on a likely blank
                drwLst LstCon, 0
            End If
        Case BtnEdit And sMode = 1
            If LstHighliteItem$(LstCon) <> "" Then
                con(TbName).Text = _Trim$(LeftOf$(LstHighliteItem$(LstCon), " ="))
                drwTB TbName, 0
                ReDim T$(1 To 1)
                Split RightOf$(LstHighliteItem$(LstCon), "NewControl("), ", ", T$()
                con(TBType).Text = _Trim$(T$(1))
                drwTB TBType, 0
                con(TbX).Text = _Trim$(T$(2))
                drwTB TbX, 0
                con(TbY).Text = _Trim$(T$(3))
                drwTB TbY, 0
                con(TbW).Text = _Trim$(T$(4))
                drwTB TbW, 0
                con(TbH).Text = _Trim$(T$(5))
                drwTB TbH, 0
                con(TbFontH).Text = _Trim$(T$(6))
                drwTB TbFontH, 0
                con(TbFCon).Text = _Trim$(T$(7))
                drwTB TbFCon, 0
                con(TbBCon).Text = _Trim$(T$(8))
                drwTB TbBCon, 0
                con(TbText).Text = LeftOf$(RightOf$(_Trim$(T$(6)), Chr$(34)), Chr$(34))
                drwTB TbText, 0
                BtnClickEvent BtnDelete 'clear the item from LstCon
            End If

        Case BtnFile And sMode = 1
            ' now fix this up for working with .bas file and does it have controls already
            ' if the WorkFile$ is "untitled.bas"  or ControlsExtracted = 0 then no controls to work around

            If WorkFile$ = "untitled.bas" Then ' the whole works! assume we are starting a new file
                answer$ = inputBox$("Enter a name for your .bas file, nothing will be: untitled.bas", "untitled.bas file", 65)
                If answer$ <> "" Then
                    If UCase$(Right$(_Trim$(answer$), 4)) = ".BAS" Then ' ok
                        WorkFile$ = answer$
                    Else
                        WorkFile$ = answer$ + ".bas"
                    End If
                End If
                Open WorkFile$ For Output As #1
                Print #1, "'$include:'vs GUI.BI'"
                Print #1, "'   Set Globals from BI              your Title here VVV"
                Print #1, "Xmax = 1280: Ymax = 720: GuiTitle$ = " + Chr$(34) + "GUI Form Designer" + Chr$(34) '<<  Window size shared throughout
                Print #1, "OpenWindow Xmax, Ymax, GuiTitle$ ' need to do this before drawing anything from NewControls"
                ' insert / extract section  ==============================================================================
                Print #1, "' GUI Controls"
                Print #1, "'                     Dim and set Globals for GUI app"
                Print #1, "Dim Shared As Long ";
                For i = 1 To UBound(ControlList$)
                    t$ = LeftOf$(ControlList$(i), " = NewControl(")
                    If _Trim$(t$) <> "" Then
                        If Len(b$) Then b$ = b$ + ", " + t$ Else b$ = t$
                    End If
                Next
                Print #1, b$
                For i = 1 To UBound(ControlList$)
                    If Len(_Trim$(ControlList$(i))) > 20 Then Print #1, ControlList$(i)
                Next
                Print #1, "' End GUI Controls"
                ' end insert / extract section ===========================================================================
                Print #1, ""
                Print #1, "MainRouter ' after all controls setup"
                Print #1, ""
                Print #1, "Sub BtnClickEvent (i As Long)"
                Print #1, "   Select Case i"
                Print #1, "   End Select"
                Print #1, "End Sub"
                Print #1, ""
                Print #1, "Sub LstSelectEvent (control As Long)"
                Print #1, "   Select Case control"
                Print #1, "   End Select"
                Print #1, "End Sub"
                Print #1, ""
                Print #1, "Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)"
                Print #1, "   Select Case i"
                Print #1, "   End Select"
                Print #1, "End Sub"
                Print #1, ""
                Print #1, "Sub PicFrameUpdate (i As Long)"
                Print #1, "   Select Case i"
                Print #1, "   End Select"
                Print #1, "End Sub"
                Print #1, ""
                Print #1, "'$include:'vs GUI.BM'"

            Else ' not untitled
                ' did the workfile$ have a controls section
                Open WorkFile$ For Output As #1
                If FileControlsStart Then ' just insert edited controls section
                    For i = 1 To FileControlsStart 'copy back this part of file including the line label
                        Print #1, FileLines$(i)
                    Next
                    ' insert the new / edited controls
                    Print #1, "'                     Dim and set Globals for GUI app"
                    Print #1, "Dim Shared As Long ";
                    For i = 1 To UBound(ControlList$)
                        If Len(_Trim$(ControlList$(i))) > 20 Then ' make sure there is something significant here
                            t$ = LeftOf$(ControlList$(i), " = NewControl(")
                            If _Trim$(t$) <> "" Then
                                If Len(b$) Then b$ = b$ + ", " + t$ Else b$ = t$
                            End If
                        End If
                    Next
                    Print #1, b$
                    For i = 1 To UBound(ControlList$)
                        If Len(_Trim$(ControlList$(i))) > 20 Then Print #1, ControlList$(i)
                    Next
                    'the rest of the file including the label line
                    For i = FileControlsEnd To UBound(FileLines$)
                        Print #1, FileLines$(i)
                    Next
                Else ' new to GUI put at start of the file, add GUI at start, insert bas file then final BM include
                    Print #1, "'$include:'vs GUI.BI'"
                    Print #1, "'   Set Globals from BI              your Title here VVV"
                    Print #1, "Xmax = 1280: Ymax = 720: GuiTitle$ = " + Chr$(34) + "GUI Form Designer" + Chr$(34) '<<  Window size shared throughout
                    Print #1, "OpenWindow Xmax, Ymax, GuiTitle$ ' need to do this before drawing anything from NewControls"
                    ' insert / extract section  ==============================================================================
                    Print #1, "' GUI Controls"
                    Print #1, "'                     Dim and set Globals for GUI app"
                    Print #1, "Dim Shared As Long ";
                    For i = 1 To UBound(ControlList$)
                        t$ = LeftOf$(ControlList$(i), " = NewControl(")
                        If _Trim$(t$) <> "" Then
                            If Len(b$) Then b$ = b$ + ", " + t$ Else b$ = t$
                        End If
                    Next
                    Print #1, b$
                    For i = 1 To UBound(ControlList$)
                        If Len(_Trim$(ControlList$(i))) > 20 Then Print #1, ControlList$(i)
                    Next
                    Print #1, "' End GUI Controls"
                    ' end insert / extract section ===========================================================================
                    Print #1, ""
                    Print #1, "MainRouter ' after all controls setup"
                    Print #1, ""
                    Print #1, "Sub BtnClickEvent (i As Long)"
                    Print #1, "   Select Case i"
                    Print #1, "   End Select"
                    Print #1, "End Sub"
                    Print #1, ""
                    Print #1, "Sub LstSelectEvent (control As Long)"
                    Print #1, "   Select Case control"
                    Print #1, "   End Select"
                    Print #1, "End Sub"
                    Print #1, ""
                    Print #1, "Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)"
                    Print #1, "   Select Case i"
                    Print #1, "   End Select"
                    Print #1, "End Sub"
                    Print #1, ""
                    Print #1, "Sub PicFrameUpdate (i As Long)"
                    Print #1, "   Select Case i"
                    Print #1, "   End Select"
                    Print #1, "End Sub"
                    Print #1, ""
                    '  now the bas file
                    For i = 1 To UBound(FileLines$)
                        Print #1, FileLines$(i)
                    Next
                    ' finally at the end
                    Print #1, "'$include:'vs GUI.BM'"
                End If
                Close #1
            End If
    End Select
End Sub

Sub LstSelectEvent (control As Long)
    Dim dirs$, fils$
    Select Case control
        Case LstD And sMode = 2 'get file event
            ChDir LstHighliteItem$(LstD)
            curPath$ = _CWD$
            con(LblCurPath).Text = curPath$
            drwLbl LblCurPath
            GetListStrings dirs$, fils$
            con(LstD).Text = dirs$
            con(LstD).N1 = 1
            con(LstD).N2 = 1
            con(LstF).Text = fils$
            con(LstF).N1 = 1
            con(LstF).N2 = 1
            'con(LblSelFile).Text = ""
            'drwLbl LblSelFile
            drwLst LstD, 0
            drwLst LstF, -1 'should be active
            'Case LstF And sMode = 2 'get file event
            'con(LblSelFile).Text = curPath$ + "/" + LstHighliteItem$(LstF)
            'drwLbl LblSelFile
    End Select
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long) ' attach your Picture click code in here
    Select Case i
    End Select
End Sub

Sub PicFrameUpdate (i As Long) ' attach your Picture click code in here
    Select Case i
    End Select
End Sub

Function NewControlStr$ (dummy)
    dummy = 0
    NewControlStr$ = con(TbName).Text + " = NewControl(" + con(TBType).Text + ", " + con(TbX).Text + ", " + con(TbY).Text +_
     ", " + con(TbW).Text + ", " + con(TbH).Text + ", " + con(TbFontH).Text + ", " + con(TbFCon).Text + ", " + con(TbBCon).Text +_
      ", " + Chr$(34) + con(TbText).Text + Chr$(34) + ")"
End Function

Sub reloadMe
    sMode = 1 ' for this set of controls
    Dim CList$
    NControls = 0

    BtnGetFile = NewControl(1, 20, 20, 460, 60, 30, 0, 0, "Select File to Edit Controls")

    LblName = NewControl(4, 20, 120, 360, 40, 30, 0, 0, "Name = Handle")
    TbName = NewControl(2, 20, 160, 360, 40, 30, 0, 0, "12345gjyqWdNC")
    LblType = NewControl(4, 400, 120, 80, 40, 30, 0, 0, "Type")
    TBType = NewControl(2, 400, 160, 80, 40, 30, 0, 0, "") '

    LblX = NewControl(4, 20, 220, 220, 40, 30, 0, 0, "X")
    TbX = NewControl(2, 20, 260, 220, 40, 30, 0, 0, "0")
    LblY = NewControl(4, 260, 220, 220, 40, 30, 0, 0, "Y")
    TbY = NewControl(2, 260, 260, 220, 40, 30, 0, 0, "0")

    LblW = NewControl(4, 20, 320, 220, 40, 30, 0, 0, "W")
    TbW = NewControl(2, 20, 360, 220, 40, 30, 0, 0, "0")
    LblH = NewControl(4, 260, 320, 220, 40, 30, 0, 0, "H")
    TbH = NewControl(2, 260, 360, 220, 40, 30, 0, 0, "0")

    LblFontH = NewControl(4, 20, 420, 80, 40, 30, 0, 0, "FontH")
    TbFontH = NewControl(2, 20, 460, 80, 40, 30, 0, 0, "0")
    LblText = NewControl(4, 120, 420, 360, 40, 30, 0, 0, "Text")
    TbText = NewControl(2, 120, 460, 360, 40, 30, 0, 0, "")

    LbFC = NewControl(4, 20, 520, 220, 40, 30, 0, 0, "Fore Color")
    TbFCon = NewControl(2, 20, 560, 220, 40, 30, 0, 0, "0")
    LblBC = NewControl(4, 260, 520, 220, 40, 30, 0, 0, "Back Color")
    TbBCon = NewControl(2, 260, 560, 220, 40, 30, 0, 0, "0")

    BtnAdd = NewControl(1, 20, 620, 460, 60, 30, 0, 0, "Add to List")

    LblCon = NewControl(4, 500, 20, 760, 40, 30, 0, 0, "Controls List:")
    CList$ = Join$(ControlList$(), "~")
    LstCon = NewControl(3, 500, 60, 760, 540, 20, 0, 0, CList$)

    BtnPreview = NewControl(1, 500, 620, 175, 60, 30, 0, 0, "Layout")
    BtnDelete = NewControl(1, 695, 620, 175, 60, 30, 0, 0, "Delete")
    BtnEdit = NewControl(1, 890, 620, 175, 60, 30, 0, 0, "Edit")
    BtnFile = NewControl(1, 1085, 620, 175, 60, 30, 0, 0, "File")

End Sub

'$include:'vs GUI.BM'

'=========================================================================== vs GUI.BM start to end

'' GUI.BM 2022-07-20 add Function LstHighliteItem$
'' Change MainRouter clicking outside a control was changing the active control, no more!
'' If Mouse Over a Control, that controls becomes active, don't try and Tab off a control that a
'' mouse is over, mouse wins!
'' 2022-07-25
'' Do display after all drwX's
'' Font Heights for Text Boxes, Btns, Pic Box (but that is stupid no room for pic) now only have to
'' be 2 pixels less than Control Height.
'' Removed N6, Text2, Fhdl, FontFile, ImgFile from the Control Type for vs GUI.
'' Aha! to do an image file instead of Text use ">Filename.ext" for the text.
'' 2022-07-26
'' Another fix in MainRouter, Exit For when found the control mouse is inside. Needed this when a
'' Click switched screens and threw errors because it was a whole different set of controls!

'Function LstHighliteItem$ (controlI As Long) ' 2022-07-20 adding this to BM
'    ReDim lst(1 To 1) As String 'need to find highlighted item
'    Split con(controlI).Text, "~", lst()
'    LstHighliteItem$ = lst((con(controlI).N1 - 1) * con(controlI).N4 + con(controlI).N2)
'End Function

'Function NewControl& (ConType As Long, X As Long, Y As Long, W As Long, H As Long,_
' FontH As Long, FC As Long, BC As Long, s$) ' dims are pixels
'    Dim As Long a
'    NControls = NControls + 1
'    ReDim _Preserve con(0 To NControls) As Control
'    con(NControls).ConType = ConType
'    con(NControls).X = X
'    con(NControls).Y = Y
'    con(NControls).W = W
'    con(NControls).H = H
'    con(NControls).Text = s$
'    ActiveControl = 1
'    If NControls = 1 Then a = 1 Else a = 0
'    Select Case ConType
'        Case 1
'            con(NControls).N1 = 0
'            If Left$(s$, 1) = "<" Then
'                If _FileExists(Mid$(s$, 2)) Then con(NControls).N1 = _LoadImage(Mid$(s$, 2))
'            End If
'            If FontH < H - 1 Then con(NControls).FontH = FontH Else con(NControls).FontH = H - 2
'            If FC = 0 And BC = 0 Then ' use default colors
'                con(NControls).FC = C3(800): con(NControls).BC = C3(888)
'            Else ' convert to RGB
'                con(NControls).FC = C3(FC): con(NControls).BC = C3(BC)
'            End If
'            drwBtn NControls, a
'        Case 2
'            If FontH < H - 1 Then con(NControls).FontH = FontH Else con(NControls).FontH = H - 2
'            If FC = 0 And BC = 0 Then ' use default colors
'                con(NControls).FC = C3(778): con(NControls).BC = C3(225)
'            Else ' convert to RGB
'                con(NControls).FC = C3(FC): con(NControls).BC = C3(BC)
'            End If
'            con(NControls).N1 = 1 ' page/section
'            con(NControls).N2 = 1 ' highlite
'            con(NControls).N3 = Int(con(NControls).FontH * .65) ' width of character
'            con(NControls).N4 = Int((con(NControls).W - 4) / con(NControls).N3) ' width of section
'            con(NControls).N5 = Len(con(NControls).Text) + 1
'            drwTB NControls, a
'        Case 3
'            If FC = 0 And BC = 0 Then ' use default colors
'                con(NControls).FC = C3(889): con(NControls).BC = C3(336)
'            Else ' convert to RGB
'                con(NControls).FC = C3(FC): con(NControls).BC = C3(BC)
'            End If
'            If 3 * FontH > H Then con(NControls).FontH = Int(H / 3) Else con(NControls).FontH = FontH
'            con(NControls).N4 = Int((H - 2 * con(NControls).FontH) / con(NControls).FontH)
'            '                page height 2 empty lines for home, end, page up, page down clicking
'            con(NControls).N1 = 1 ' page number
'            con(NControls).N2 = 1 ' select highlite bar
'            drwLst NControls, a
'        Case 4
'            con(NControls).N1 = 0
'            If Left$(s$, 1) = "<" Then
'                If _FileExists(Mid$(s$, 2)) Then con(NControls).N1 = _LoadImage(Mid$(s$, 2))
'            End If
'            If FontH <= H Then con(NControls).FontH = FontH Else con(NControls).FontH = H
'            If FC = 0 And BC = 0 Then ' use default colors
'                con(NControls).FC = C3(889): con(NControls).BC = screenBC
'            Else ' convert to RGB
'                con(NControls).FC = C3(FC): con(NControls).BC = C3(BC)
'            End If
'            drwLbl NControls
'        Case 5
'            If FontH < H - 1 Then con(NControls).FontH = FontH Else con(NControls).FontH = H - 2
'            If s$ <> "" Then ' label color is
'                If FC = 0 And BC = 0 Then ' use default colors
'                    con(NControls).FC = C3(590): con(NControls).BC = C3(40)
'                Else ' convert to RGB
'                    con(NControls).FC = C3(FC): con(NControls).BC = C3(BC)
'                End If
'            End If
'            con(NControls).N1 = _NewImage(con(NControls).W, con(NControls).H, 32)
'            _Dest con(NControls).N1
'            Line (0, 0)-Step(con(NControls).W - 1, con(NControls).H - 1), Black, BF
'            _Dest 0
'            drwPic NControls, a
'    End Select
'    NewControl& = NControls ' same as ID
'End Function

'Sub MainRouter
'    Dim As Long kh, mx, my, mb1, mb2, i, shift, temp

'    Do
'        ' mouse clicks and tabs will decide the active control,
'        ' when mouse is over control you wont Tab out of it as of 7-20+ updates.
'        While _MouseInput
'            If con(ActiveControl).ConType = 3 Then
'                If _MouseWheel > 0 Then
'                    LstKeyEvent ActiveControl, 20480
'                ElseIf _MouseWheel < 0 Then
'                    LstKeyEvent ActiveControl, 18432
'                End If
'            End If
'        Wend
'        'altKh = 0 ' this is a hack!
'        mx = _MouseX: my = _MouseY: mb1 = _MouseButton(1): mb2 = _MouseButton(2)
'        For i = 1 To NControls
'            If mx >= con(i).X And mx <= con(i).X + con(i).W Then
'                If my >= con(i).Y And my <= con(i).Y + con(i).H Then ' we are  inside a control
'                    If i <> ActiveControl And con(i).ConType <> 4 Then ' active control is changed
'                        activateControl ActiveControl, 0
'                        ActiveControl = i
'                        activateControl ActiveControl, -1
'                    End If

'                    If mb1 Then ' click, find which type control we are in and exit for
'                        If con(i).ConType = 1 Then
'                            BtnClickEvent i
'                        ElseIf con(i).ConType = 2 Then ' move cursor to click point
'                            If mx > con(i).X + 4 And mx < con(i).X + con(i).W Then
'                                If my >= con(i).Y And my <= con(i).Y + con(i).H Then
'                                    con(i).N2 = Int((mx - (con(i).X + 4)) / con(i).N3) + 1
'                                    If (con(i).N1 - 1) * con(i).N4 + con(i).N2 > con(i).N5 Then
'                                        If con(i).N5 Mod con(i).N4 = 0 Then
'                                            'last page exactly at end of it
'                                            con(i).N1 = Int(con(i).N5 / con(i).N4)
'                                            con(i).N2 = con(i).N4
'                                        Else
'                                            ' last page with only some lines
'                                            con(i).N1 = Int(con(i).N5 / con(i).N4) + 1
'                                            con(i).N2 = con(i).N5 Mod con(i).N4
'                                        End If
'                                    End If
'                                    drwTB i, -1
'                                End If
'                            End If
'                        ElseIf con(i).ConType = 3 Then
'                            If my >= con(i).Y And my <= con(i).Y + con(i).FontH Then ' top empty
'                                If mx < con(i).X + .5 * con(i).W Then 'home else pgUp
'                                    LstKeyEvent i, 18176 ' home
'                                ElseIf mx > con(i).X + .5 * con(i).W Then
'                                    LstKeyEvent i, 18688 ' pgup
'                                End If
'                            ElseIf my >= con(i).Y + con(i).H - con(i).FontH Then
'                                If my <= con(i).Y + con(i).H Then
'                                    If mx < con(i).X + .5 * con(i).W Then 'end else pgDn
'                                        LstKeyEvent i, 20224 ' end
'                                    ElseIf mx > con(i).X + .5 * con(i).W Then
'                                        LstKeyEvent i, 20736 ' pgdn
'                                    End If
'                                End If
'                            ElseIf my >= con(i).Y + con(i).FontH Then
'                                If my < con(i).Y + con(i).H - con(i).FontH Then
'                                    temp = Int((my - con(i).Y - con(i).FontH) / con(i).FontH)
'                                    con(i).N2 = temp + 1
'                                    If (con(i).N1 - 1) * con(i).N4 + con(i).N2 > con(i).N5 Then
'                                        LstKeyEvent i, 20224 ' end
'                                    End If
'                                    drwLst i, -1
'                                End If
'                            End If
'                        ElseIf con(i).ConType = 5 Then
'                            PicClickEvent i, mx - con(i).X, my - con(i).Y 'picture box click event
'                        End If ' what kind of control

'                        _Delay .2 ' user release key wait
'                    End If ' left click a control check

'                    If mb2 Then ' check right clicking to select
'                        If con(i).ConType = 3 Then ' only selecting in lst box
'                            LstSelectEvent i ' check event called for 5
'                        End If ' control type 3
'                        _Delay .2 ' user release button  so action not taken twice
'                    End If ' mb2
'                    Exit For ' should only be inside one control
'                End If ' y is inside control
'            End If 'x inside control
'        Next

'        kh = _KeyHit ' now for key presses
'        shift = _KeyDown(100304) Or _KeyDown(100303)
'        If kh = 9 Then 'tab
'            If shift Then shiftActiveControl -1 Else shiftActiveControl 1
'        ElseIf kh = 13 And con(ActiveControl).ConType = 1 Then ' enter on a btn
'            BtnClickEvent ActiveControl
'            shiftActiveControl 1
'        ElseIf kh = 13 And con(ActiveControl).ConType = 2 Then
'            shiftActiveControl 1
'        ElseIf kh = 13 And con(ActiveControl).ConType = 3 Then
'            LstSelectEvent ActiveControl
'            shiftActiveControl 1
'        End If
'        If con(ActiveControl).ConType = 2 Then
'            TBKeyEvent ActiveControl, kh, shift ' this handles keypress in active textbox
'        ElseIf con(ActiveControl).ConType = 3 Then
'            LstKeyEvent ActiveControl, kh
'        End If
'        For i = 1 To NControls ' update active picture boxes
'            If con(i).ConType = 5 Then PicFrameUpdate i
'        Next
'        _Display
'        _Limit 60
'    Loop
'    System
'End Sub

'Sub shiftActiveControl (change As Long) ' change = 1 or -1
'    activateControl ActiveControl, 0 ' turn off last
'    Do
'        ActiveControl = ActiveControl + change
'        If ActiveControl > NControls Then ActiveControl = 1
'        If ActiveControl < 1 Then ActiveControl = NControls
'    Loop Until con(ActiveControl).ConType <> 4
'    activateControl ActiveControl, -1 ' turn on next
'End Sub

'Sub activateControl (i, activate)
'    Select Case con(i).ConType
'        Case 1: drwBtn i, activate
'        Case 2: drwTB i, activate
'        Case 3: drwLst i, activate
'        Case 5: drwPic i, activate
'    End Select
'End Sub

'Sub OpenWindow (WinWidth As Long, WinHeight As Long, title$, fontFile$)
'    Screen _NewImage(WinWidth, WinHeight, 32)
'    _ScreenMove 80, 0
'    _PrintMode _KeepBackground
'    _Title title$
'    curPath$ = _CWD$ ' might need this for file stuff
'    Color White, screenBC
'    Cls
'    Dim As Long j
'    For j = 6 To 128
'        fontHandle&(j) = _LoadFont(fontFile$, j)
'        If fontHandle&(j) <= 0 Then
'            Cls
'            Print "Font did not load (OpenWindow sub) at height" + Str$(j) + ", goodbye!"
'            Sleep: End
'        End If
'    Next
'End Sub

'Sub drwBtn (i As Long, active As Long) ' gray back, black text
'    Dim As Long tempX, tempY
'    If con(i).N1 > -2 Then ' no image
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).BC, BF
'        _Font fontHandle&(con(i).FontH)
'        tempX = con(i).X + (con(i).W - _PrintWidth(con(i).Text)) / 2
'        tempY = con(i).Y + (con(i).H - con(i).FontH) / 2
'        If con(i).FontH >= 20 Then
'            Color Black
'            _PrintString (tempX - 1, tempY - 1), con(i).Text
'        End If
'        Color con(i).FC
'        _PrintString (tempX, tempY), con(i).Text
'    Else
'        _PutImage (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).N1, 0
'    End If
'    If active Then
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), White, B
'    Else
'        Line (con(i).X, con(i).Y)-Step(con(i).W, 0), White
'        Line (con(i).X, con(i).Y)-Step(0, con(i).H), White
'        Line (con(i).X + con(i).W, con(i).Y)-Step(0, con(i).H), Black
'        Line (con(i).X, con(i).Y + con(i).H)-Step(con(i).W, 0), Black
'    End If
'    _Display
'End Sub

'Sub drwTB (i As Long, active As Long) ' blue back, white text
'    ' just like LstBox
'    ' N1 = section / page number we are on
'    ' N2 = current location of the highlight bar on the page 1 to page/section width
'    ' N3 = char width allowed for char fontH * .65
'    ' N4 = page height or section width
'    ' N5 = len(text) + 1 upperbound of letters

'    Dim As Long j, xoff, tempX
'    Dim t$
'    Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).BC, BF
'    If active Then
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), White, B
'    Else
'        Line (con(i).X, con(i).Y)-Step(con(i).W, 0), Black
'        Line (con(i).X, con(i).Y)-Step(0, con(i).H), Black
'        Line (con(i).X + con(i).W, con(i).Y)-Step(0, con(i).H), White
'        Line (con(i).X, con(i).Y + con(i).H)-Step(con(i).W, 0), White
'    End If
'    con(i).N5 = Len(con(i).Text) + 1 ' allow for 1 more char insertion or insertion on end
'    _Font fontHandle&(con(i).FontH)
'    For j = 1 To con(i).N4
'        If (con(i).N1 - 1) * con(i).N4 + j <= con(i).N5 Then
'            t$ = Mid$(con(i).Text, (con(i).N1 - 1) * con(i).N4 + j, 1)
'            xoff = (con(i).N3 - _PrintWidth(t$)) / 2
'            tempX = con(i).X + 4 + (j - 1) * con(i).N3
'            If j <> con(i).N2 Or active = 0 Then
'                Color con(i).FC
'            Else ' cursor
'                Line (tempX + 1, con(i).Y)-Step(con(i).N3, con(i).H - 2), con(i).FC, BF
'                Color con(i).BC
'            End If
'            _PrintString (tempX + xoff, con(i).Y + (con(i).H - con(i).FontH) / 2), t$
'        End If
'    Next
'    _Display
'End Sub

'Sub drwLst (i As Long, active As Long)
'    ' new control will get numbers for constructing a screen
'    ' N1 = page number we are on
'    ' N2 = current location of the highlight bar on the page
'    ' N3 = page width in chars
'    ' N4 = page height + 2 lines are left blank at top and bottom
'    ' N5 = Ubound of the list() base 1 ie last item number

'    Dim As Long j, k, tempY
'    Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).BC, BF
'    If active Then
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), White, B
'    Else
'        Line (con(i).X, con(i).Y)-Step(con(i).W, 0), Black
'        Line (con(i).X, con(i).Y)-Step(0, con(i).H), Black
'        Line (con(i).X + con(i).W, con(i).Y)-Step(0, con(i).H), White
'        Line (con(i).X, con(i).Y + con(i).H)-Step(con(i).W, 0), White
'    End If
'    ReDim lst(1 To 1) As String
'    Split con(i).Text, "~", lst()
'    con(i).N5 = UBound(lst)
'    _Font fontHandle&(con(i).FontH)
'    For j = 1 To con(i).N4 ' - 1
'        If (con(i).N1 - 1) * con(i).N4 + j <= con(i).N5 Then
'            k = Len(lst((con(i).N1 - 1) * con(i).N4 + j)) ' (page-1) * lines per page + cur line j
'            While _PrintWidth(Mid$(lst((con(i).N1 - 1) * con(i).N4 + j), 1, k)) > con(i).W - 4
'                k = k - 1
'            Wend
'            tempY = con(i).Y + con(i).FontH + (j - 1) * con(i).FontH
'            If j <> con(i).N2 Then
'                Color con(i).FC
'            Else
'                Line (con(i).X + 1, tempY)-Step(con(i).W - 2, con(i).FontH), con(i).FC, BF
'                Color con(i).BC
'            End If
'            _PrintString (con(i).X + 4, tempY), Mid$(lst((con(i).N1 - 1) * con(i).N4 + j), 1, k)
'        End If
'    Next
'    _Display
'End Sub

'Sub drwLbl (i As Long)
'    Dim As Long tempX
'    If con(i).N1 > -2 Then ' no image
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).BC, BF
'        _Font fontHandle&(con(i).FontH)
'        tempX = con(i).X + (con(i).W - _PrintWidth(con(i).Text)) / 2
'        If con(i).FontH >= 20 Then
'            Color Black
'            _PrintString (tempX + 1, con(i).Y + (con(i).H - con(i).FontH) / 2 + 1), con(i).Text
'        End If
'        Color con(i).FC
'        _PrintString (tempX, con(i).Y + (con(i).H - con(i).FontH) / 2), con(i).Text
'    Else
'        _PutImage (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).N1, 0
'    End If
'    _Display
'End Sub

'Sub drwPic (i As Long, active As Long)
'    Dim As Long tempY
'    If con(i).Text <> "" Then ' title to display
'        Dim sd&
'        sd& = _Dest
'        _Dest con(i).N1
'        Line (0, con(i).H - con(i).FontH - 2)-Step(con(i).W - 1, con(i).FontH + 2), con(i).BC, BF
'        _Font fontHandle&(con(i).FontH)
'        Color con(i).FC, con(i).BC
'        tempY = con(i).H - con(i).FontH - 1
'        _PrintString ((con(i).W - _PrintWidth(con(i).Text)) / 2, tempY), con(i).Text
'        _Dest 0
'        _PutImage (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), con(i).N1, 0
'        _Dest sd&
'    End If
'    If active Then
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), White, B
'    Else
'        Line (con(i).X, con(i).Y)-Step(con(i).W, con(i).H), Black, B
'    End If
'    _Display
'End Sub

'' this is standard for all Text Boxes
'Sub TBKeyEvent (i As Long, ky As Long, shift As Long) ' for all text boxes
'    Dim As Long L
'    ' just like LstBox
'    ' N1 = section / page number we are on
'    ' N2 = current location of the highlight bar on the page 1 to page/section width
'    ' N3 = char width allowed for char fontH * .65
'    ' N4 = page height or section width
'    ' N5 = len(text) + 1 upperbound of letters
'    L = (con(i).N1 - 1) * con(i).N4 + con(i).N2 ' help shorten really long lines
'    If ky = 19200 Then 'left arrow
'        If con(i).N2 > 1 Then
'            con(i).N2 = con(i).N2 - 1: drwTB i, -1
'        Else
'            If con(i).N1 > 1 Then con(i).N1 = con(i).N1 - 1: con(i).N2 = con(i).N4: drwTB i, -1
'        End If
'    ElseIf ky = 19712 Then ' right arrow
'        If con(i).N2 < con(i).N4 And (con(i).N1 - 1) * con(i).N4 + con(i).N2 < con(i).N5 Then
'            con(i).N2 = con(i).N2 + 1: drwTB i, -1
'        Else
'            If con(i).N2 = con(i).N4 Then ' can we move to another page
'                If con(i).N1 < con(i).N5 / con(i).N4 Then
'                    con(i).N1 = con(i).N1 + 1: con(i).N2 = 1: drwTB i, -1
'                End If
'            End If
'        End If
'    ElseIf ky = 18176 Then ' home
'        con(i).N1 = 1: con(i).N2 = 1: drwTB i, -1
'    ElseIf ky = 20224 Then ' end
'        If con(i).N5 Mod con(i).N4 = 0 Then
'            con(i).N1 = Int(con(i).N5 / con(i).N4)
'            con(i).N2 = con(i).N4
'        Else
'            con(i).N1 = Int(con(i).N5 / con(i).N4) + 1
'            con(i).N2 = con(i).N5 Mod con(i).N4
'        End If
'        drwTB i, -1
'    ElseIf ky = 18688 Then ' PgUp
'        If con(i).N1 > 1 Then con(i).N1 = con(i).N1 - 1: drwTB i, -1
'    ElseIf ky = 20736 Then ' PgDn
'        If con(i).N1 < con(i).N5 / con(i).N4 Then
'            con(i).N1 = con(i).N1 + 1: con(i).N2 = 1: drwTB i, -1
'        End If
'    ElseIf ky >= 32 And ky <= 128 Then ' normal letter or digit or symbol
'        con(i).Text = Mid$(con(i).Text, 1, L - 1) + Chr$(ky) + Mid$(con(i).Text, L)
'        con(i).N5 = Len(con(i).Text) + 1
'        ' now do right arrow code
'        If con(i).N2 < con(i).N4 And (con(i).N1 - 1) * con(i).N4 + con(i).N2 < con(i).N5 Then
'            con(i).N2 = con(i).N2 + 1: drwTB i, -1
'        Else
'            If con(i).N2 = con(i).N4 Then ' can we move to another page
'                If con(i).N1 < con(i).N5 / con(i).N4 Then
'                    con(i).N1 = con(i).N1 + 1: con(i).N2 = 1: drwTB i, -1
'                End If
'            End If
'        End If
'    ElseIf ky = 8 Then 'backspace
'        If shift Then
'            con(i).Text = "": con(i).N2 = 1: con(i).N1 = 1: con(i).N5 = 1: drwTB i, -1
'        Else
'            If con(i).N2 > 1 Then
'                con(i).Text = Mid$(con(i).Text, 1, L - 2) + Mid$(con(i).Text, L)
'                con(i).N5 = Len(con(i).Text) + 1
'                con(i).N2 = con(i).N2 - 1: drwTB i, -1
'            ElseIf con(i).N1 <> 1 Then
'                con(i).Text = Mid$(con(i).Text, 1, L - 2) + Mid$(con(i).Text, L)
'                con(i).N5 = Len(con(i).Text) + 1
'                con(i).N1 = con(i).N1 - 1: con(i).N2 = con(i).N4: drwTB i, -1
'            End If
'        End If
'    ElseIf ky = 21248 Then 'delete  shift is super delete
'        If shift Then
'            con(i).Text = "": con(i).N2 = 1: con(i).N1 = 1: con(i).N5 = 1: drwTB i, -1
'        Else
'            con(i).Text = Mid$(con(i).Text, 1, L - 1) + Mid$(con(i).Text, L + 1)
'            con(i).N5 = Len(con(i).Text) + 1: drwTB i, -1
'        End If
'    End If
'End Sub

'' this is standard for all List Boxes
'Sub LstKeyEvent (i As Long, ky As Long) ' for all text boxes
'    If ky = 18432 Then 'up arrow
'        If con(i).N2 > 1 Then
'            con(i).N2 = con(i).N2 - 1: drwLst i, -1
'        Else
'            If con(i).N1 > 1 Then con(i).N1 = con(i).N1 - 1: con(i).N2 = con(i).N4: drwLst i, -1
'        End If
'    ElseIf ky = 20480 Then ' down arrow
'        If con(i).N2 < con(i).N4 And (con(i).N1 - 1) * con(i).N4 + con(i).N2 < con(i).N5 Then
'            con(i).N2 = con(i).N2 + 1: drwLst i, -1
'        Else
'            If con(i).N2 = con(i).N4 Then ' can we start another page
'                If con(i).N1 < con(i).N5 / con(i).N4 Then
'                    con(i).N1 = con(i).N1 + 1: con(i).N2 = 1: drwLst i, -1
'                End If
'            End If
'        End If
'    ElseIf ky = 18176 Then 'home
'        con(i).N1 = 1: con(i).N2 = 1: drwLst i, -1
'    ElseIf ky = 20224 Then ' end
'        If con(i).N5 Mod con(i).N4 = 0 Then
'            con(i).N1 = Int(con(i).N5 / con(i).N4)
'            con(i).N2 = con(i).N4
'        Else
'            con(i).N1 = Int(con(i).N5 / con(i).N4) + 1
'            con(i).N2 = con(i).N5 Mod con(i).N4
'        End If
'        drwLst i, -1
'    ElseIf ky = 18688 Then 'pgUp
'        If con(i).N1 > 1 Then con(i).N1 = con(i).N1 - 1: drwLst i, -1
'    ElseIf ky = 20736 Then 'pgDn
'        If con(i).N1 * con(i).N4 < con(i).N5 Then
'            con(i).N1 = con(i).N1 + 1
'            If con(i).N1 > Int(con(i).N5 / con(i).N4) Then ' > last whole page check high bar
'                If con(i).N2 > con(i).N5 Mod con(i).N4 Then con(i).N2 = con(i).N5 Mod con(i).N4
'            End If
'            drwLst i, -1
'        End If
'    End If
'End Sub

'' This is used and available for maniupating strings to arrays ie change delimiters to commas
'Sub Split (SplitMeString As String, delim As String, loadArray() As String)
'    Dim curpos As Long, arrpos As Long, LD As Long, dpos As Long 'fix use the Lbound the array already has
'    curpos = 1: arrpos = LBound(loadArray): LD = Len(delim)
'    dpos = InStr(curpos, SplitMeString, delim)
'    Do Until dpos = 0
'        loadArray(arrpos) = Mid$(SplitMeString, curpos, dpos - curpos)
'        arrpos = arrpos + 1
'        If arrpos > UBound(loadArray) Then
'            ReDim _Preserve loadArray(LBound(loadArray) To UBound(loadArray) + 1000) As String
'        End If
'        curpos = dpos + LD
'        dpos = InStr(curpos, SplitMeString, delim)
'    Loop
'    loadArray(arrpos) = Mid$(SplitMeString, curpos)
'    ReDim _Preserve loadArray(LBound(loadArray) To arrpos) As String 'get the ubound correct
'End Sub

'' Available if need to create a string from an array
'Function Join$ (arr() As String, delimiter$) ' modified to avoid blank lines
'    Dim i As Long, b$
'    For i = LBound(arr) To UBound(arr)
'        If arr(i) <> "" Then
'            If b$ = "" Then b$ = arr(i) Else b$ = b$ + delimiter$ + arr(i)
'        End If
'    Next
'    Join$ = b$
'End Function

'Function LeftOf$ (source$, of$)
'    If InStr(source$, of$) > 0 Then
'        LeftOf$ = Mid$(source$, 1, InStr(source$, of$) - 1)
'    Else
'        LeftOf$ = source$
'    End If
'End Function

'' update these 2 in case of$ is not found! 2021-02-13
'Function RightOf$ (source$, of$)
'    If InStr(source$, of$) > 0 Then
'        RightOf$ = Mid$(source$, InStr(source$, of$) + Len(of$))
'    Else
'        RightOf$ = ""
'    End If
'End Function

'Function TS$ (n As Long)
'    TS$ = _Trim$(Str$(n))
'End Function

'Sub Remove (item$, a$())
'    Dim As Long i, c, lba
'    lba = LBound(a$)
'    Dim t$(lba To UBound(a$))
'    c = lba - 1
'    For i = lba To UBound(a$)
'        If a$(i) <> "" And a$(i) <> item$ Then c = c + 1: t$(c) = a$(i)
'    Next
'    ReDim a$(lba To c)
'    For i = lba To c
'        a$(i) = t$(i)
'    Next
'End Sub

'Function C3~& (i As Long) ' from 0 to 999 3 digit pos integers
'    Dim s$
'    s$ = Right$("   " + Str$(i), 3)
'    C3~& = _RGB32(Val(Mid$(s$, 1, 1)) * 28, Val(Mid$(s$, 2, 1)) * 28, Val(Mid$(s$, 3, 1)) * 28)
'End Function

'Sub drawGridRect (x, y, w, h, xstep, ystep)
'    Dim i
'    For i = 0 To w Step xstep
'        Line (x + i, y + 0)-(x + i, y + y + h)
'    Next
'    For i = 0 To h Step ystep
'        Line (x + 0, y + i)-(x + w, y + i)
'    Next
'End Sub

'Sub fellipse (CX As Long, CY As Long, xr As Long, yr As Long, C As _Unsigned Long)
'    If xr = 0 Or yr = 0 Then Exit Sub
'    Dim h2 As _Integer64, w2 As _Integer64, h2w2 As _Integer64
'    Dim x As Long, y As Long
'    w2 = xr * xr: h2 = yr * yr: h2w2 = h2 * w2
'    Line (CX - xr, CY)-(CX + xr, CY), C, BF
'    Do While y < yr
'        y = y + 1
'        x = Sqr((h2w2 - y * y * w2) \ h2)
'        Line (CX - x, CY + y)-(CX + x, CY + y), C, BF
'        Line (CX - x, CY - y)-(CX + x, CY - y), C, BF
'    Loop
'End Sub

'Sub fcirc (x As Long, y As Long, R As Long, C As _Unsigned Long) 'vince version
'    Dim x0 As Long, y0 As Long, e As Long
'    x0 = R: y0 = 0: e = 0
'    Do While y0 < x0
'        If e <= 0 Then
'            y0 = y0 + 1
'            Line (x - x0, y + y0)-(x + x0, y + y0), C, BF
'            Line (x - x0, y - y0)-(x + x0, y - y0), C, BF
'            e = e + 2 * y0
'        Else
'            Line (x - y0, y - x0)-(x + y0, y - x0), C, BF
'            Line (x - y0, y + x0)-(x + y0, y + x0), C, BF
'            x0 = x0 - 1: e = e - 2 * x0
'        End If
'    Loop
'    Line (x - R, y)-(x + R, y), C, BF
'End Sub

'Sub ftri (x1, y1, x2, y2, x3, y3, K As _Unsigned Long)
'    Dim D As Long
'    Static a&
'    D = _Dest ' so important
'    If a& = 0 Then a& = _NewImage(1, 1, 32)
'    _Dest a&
'    _DontBlend a& '  '<<<< new 2019-12-16 fix
'    PSet (0, 0), K
'    _Blend a& '<<<< new 2019-12-16 fix
'    _Dest D
'    _MapTriangle _Seamless(0, 0)-(0, 0)-(0, 0), a& To(x1, y1)-(x2, y2)-(x3, y3)
'End Sub

'Sub ScnState (restoreTF As Long) 'Thanks Steve McNeill
'    Static defaultColor~&, backGroundColor~&
'    Static font&, dest&, source&, row&, col&, autodisplay&, mb&
'    If restoreTF Then
'        _Font font&
'        Color defaultColor~&, backGroundColor~&
'        _Dest dest&
'        _Source source&
'        Locate row&, col&
'        If autodisplay& Then _AutoDisplay Else _Display
'        _KeyClear
'        While _MouseInput: Wend 'clear mouse clicks
'        mb& = _MouseButton(1)
'        If mb& Then
'            Do
'                While _MouseInput: Wend
'                mb& = _MouseButton(1)
'                _Limit 100
'            Loop Until mb& = 0
'        End If
'    Else
'        font& = _Font: defaultColor~& = _DefaultColor: backGroundColor~& = _BackgroundColor
'        dest& = _Dest: source& = _Source
'        row& = CsrLin: col& = Pos(0): autodisplay& = _AutoDisplay
'        _KeyClear
'    End If
'End Sub

''title$ limit is 57 chars, all lines are 58 chars max, version 2019-08-06
''THIS SUB NOW NEEDS SUB scnState(restoreTF) for saving and restoring screen settings
'Sub mBox (title As String, m As String)

'    Dim bg As _Unsigned Long, fg As _Unsigned Long
'    bg = &HFF006030
'    fg = &HFF33AAFF

'    'first screen dimensions and items to restore at exit
'    Dim sw As Long, sh As Long
'    Dim curScrn As Long, backScrn As Long, mbx As Long 'some handles
'    Dim ti As Long, limit As Long 'ti = text index for t$(), limit is number of chars per line
'    Dim i As Long, j As Long, ff As _Bit, addb As _Byte 'index, flag and
'    Dim bxH As Long, bxW As Long 'first as cells then as pixels
'    Dim mb As Long, mx As Long, my As Long, mi As Long, grabx As Long, graby As Long
'    Dim tlx As Long, tly As Long 'top left corner of message box
'    Dim lastx As Long, lasty As Long, t As String, b As String, c As String, tail As String
'    Dim d As String, r As Single, kh As Long

'    'screen and current settings to restore at end ofsub
'    ScnState 0
'    sw = _Width: sh = _Height

'    _KeyClear '<<<<<<<<<<<<<<<<<<<< do i still need this?   YES! 2019-08-06 update!

'    'screen snapshot
'    curScrn = _Dest
'    backScrn = _NewImage(sw, sh, 32)
'    _PutImage , curScrn, backScrn

'    'setup t() to store strings with ti as index, linit 58 chars per line max, b is for build
'    ReDim t(0) As String: ti = 0: limit = 58: b = ""
'    For i = 1 To Len(m)
'        c = Mid$(m, i, 1)
'        'are there any new line signals, CR, LF or both? take CRLF or LFCR as one break
'        'but dbl LF or CR means blank line
'        Select Case c
'            Case Chr$(13) 'load line
'                If Mid$(m, i + 1, 1) = Chr$(10) Then i = i + 1
'                t(ti) = b: b = "": ti = ti + 1: ReDim _Preserve t(ti) As String
'            Case Chr$(10)
'                If Mid$(m, i + 1, 1) = Chr$(13) Then i = i + 1
'                t(ti) = b: b = "": ti = ti + 1: ReDim _Preserve t(ti)
'            Case Else
'                If c = Chr$(9) Then c = Space$(4): addb = 4 Else addb = 1
'                If Len(b) + addb > limit Then
'                    tail = "": ff = 0
'                    For j = Len(b) To 1 Step -1 'backup,
'                        d = Mid$(b, j, 1)
'                        If d = " " Then ' until find a space
'                            t(ti) = Mid$(b, 1, j - 1): b = tail + c 'save the tail
'                            ti = ti + 1: ReDim _Preserve t(ti)
'                            ff = 1 'found space flag
'                            Exit For
'                        Else
'                            tail = d + tail 'the tail grows!
'                        End If
'                    Next
'                    If ff = 0 Then 'no break? OK
'                        t(ti) = b: b = c: ti = ti + 1: ReDim _Preserve t(ti)
'                    End If
'                Else
'                    b = b + c 'just keep building the line
'                End If
'        End Select
'    Next
'    t(ti) = b
'    bxH = ti + 3: bxW = limit + 2

'    'draw message box
'    mbx = _NewImage(60 * 8, (bxH + 1) * 16, 32)
'    _Dest mbx
'    Color _RGB32(128, 0, 0), _RGB32(225, 225, 255)
'    Locate 1, 1: Print Left$(Space$((bxW - Len(title) - 3) / 2) + title + Space$(bxW), bxW)
'    Color _RGB32(225, 225, 255), _RGB32(200, 0, 0)
'    Locate 1, bxW - 2: Print " X "
'    Color fg, bg
'    Locate 2, 1: Print Space$(bxW);
'    For r = 0 To ti
'        Locate 1 + r + 2, 1: Print Left$(" " + t(r) + Space$(bxW), bxW);
'    Next
'    Locate 1 + bxH, 1: Print Space$(limit + 2);

'    'now for the action
'    _Dest curScrn

'    'convert to pixels the top left corner of box at moment
'    bxW = bxW * 8: bxH = bxH * 16
'    tlx = (sw - bxW) / 2: tly = (sh - bxH) / 2
'    lastx = tlx: lasty = tly
'    'now allow user to move it around or just read it
'    While 1
'        Cls
'        _PutImage , backScrn
'        _PutImage (tlx, tly), mbx, curScrn
'        _Display
'        While _MouseInput: Wend
'        mx = _MouseX: my = _MouseY: mb = _MouseButton(1)
'        If mb Then 'is mouse down on title bar to grab and move ?
'            If mx >= tlx And mx <= tlx + bxW And my >= tly And my <= tly + 16 Then
'                If mx >= tlx + bxW - 24 Then Exit While
'                grabx = mx - tlx: graby = my - tly
'                Do While mb 'wait for release
'                    mi = _MouseInput: mb = _MouseButton(1)
'                    mx = _MouseX: my = _MouseY
'                    If mx - grabx >= 0 And mx - grabx <= sw - bxW Then
'                        If my - graby >= 0 And my - graby <= sh - bxH Then
'                            'attempt to speed up with less updates
'                            i = (lastx - (mx - grabx)) ^ 2 + (lasty - (my - graby)) ^ 2
'                            If i ^ .5 > 10 Then
'                                tlx = mx - grabx: tly = my - graby
'                                Cls
'                                _PutImage , backScrn
'                                _PutImage (tlx, tly), mbx, curScrn
'                                lastx = tlx: lasty = tly
'                                _Display
'                            End If
'                        End If
'                    End If
'                    _Limit 400
'                Loop
'            End If
'        End If
'        kh = _KeyHit
'        If kh = 27 Or kh = 13 Or kh = 32 Then Exit While
'        _Limit 400
'    Wend

'    'put things back
'    Color _RGB32(255, 255, 255), _RGB32(0, 0, 0): Cls '
'    _PutImage , backScrn
'    _Display
'    _FreeImage backScrn
'    _FreeImage mbx
'    ScnState 1 'Thanks Steve McNeill
'End Sub

'' You can grab this box by title and drag it around screen for full viewing while answering prompt.
'' Only one line allowed for prompt$
'' boxWidth is 4 more than the allowed length of input, needs to be longer than title$ and prompt$
'' Utilities > Input Box > Input Box 1 tester v 2019-07-31
'Function inputBox$ (prompt$, title$, boxWidth As Long) ' boxWidthin default 8x16 chars!!!
'    Dim ForeColor As _Unsigned Long, BackColor As _Unsigned Long
'    Dim sw As Long, sh As Long, curScrn As Long, backScrn As Long, ibx As Long 'some handles

'    'colors
'    ForeColor = &HFF000055 '<  change as desired  prompt text color, back color or type in area
'    BackColor = &HFF6080CC '<  change as desired  used fore color in type in area

'    'items to restore at exit
'    ScnState 0

'    'screen snapshot
'    sw = _Width: sh = _Height: curScrn = _Dest
'    backScrn = _NewImage(sw, sh, 32)
'    _PutImage , curScrn, backScrn

'    'moving box around on screen
'    Dim As Long bxW, bxH, mb, mx, my, mi, grabx, graby, tlx, tly, lastx, lasty, dist
'    Dim inp$, kh&

'    'draw message box
'    bxW = boxWidth * 8: bxH = 7 * 16
'    ibx = _NewImage(bxW, bxH, 32)
'    _Dest ibx
'    Color &HFF880000, White
'    Locate 1, 1
'    Print Left$(Space$(Int((boxWidth - Len(title$) - 3)) / 2) + title$ + Space$(boxWidth), boxWidth)
'    Color White, &HFFBB0000
'    Locate 1, boxWidth - 2: Print " X "
'    Color ForeColor, BackColor
'    Locate 2, 1: Print Space$(boxWidth);
'    Locate 3, 1
'    Print Left$(Space$((boxWidth - Len(prompt$)) / 2) + prompt$ + Space$(boxWidth), boxWidth);
'    Locate 4, 1: Print Space$(boxWidth);
'    Locate 5, 1: Print Space$(boxWidth);
'    Locate 6, 1: Print Space$(boxWidth);
'    inp$ = ""
'    GoSub finishBox

'    'convert to pixels the top left corner of box at moment
'    bxW = boxWidth * 8: bxH = 5 * 16
'    tlx = (sw - bxW) / 2: tly = (sh - bxH) / 2
'    lastx = tlx: lasty = tly
'    _KeyClear
'    'now allow user to move it around or just read it
'    While 1
'        Cls
'        _PutImage , backScrn
'        _PutImage (tlx, tly), ibx, curScrn
'        _Display
'        While _MouseInput: Wend
'        mx = _MouseX: my = _MouseY: mb = _MouseButton(1)
'        If mb Then 'is mouse down on title bar for a grab and move?
'            If mx >= tlx And mx <= tlx + bxW And my >= tly And my <= tly + 16 Then
'                If mx >= tlx + bxW - 24 Then Exit While
'                grabx = mx - tlx: graby = my - tly
'                Do While mb 'wait for release
'                    mi = _MouseInput: mb = _MouseButton(1)
'                    mx = _MouseX: my = _MouseY
'                    If mx - grabx >= 0 And mx - grabx <= sw - bxW Then
'                        If my - graby >= 0 And my - graby <= sh - bxH Then
'                            'attempt to speed up with less updates
'                            dist = (lastx - (mx - grabx)) ^ 2 + (lasty - (my - graby)) ^ 2
'                            If dist ^ .5 > 10 Then
'                                tlx = mx - grabx: tly = my - graby
'                                Cls
'                                _PutImage , backScrn
'                                _PutImage (tlx, tly), ibx, curScrn
'                                lastx = tlx: lasty = tly
'                                _Display
'                            End If
'                        End If
'                    End If
'                    _Limit 400
'                Loop
'            End If
'        End If
'        kh& = _KeyHit
'        Select Case kh& 'whew not much for the main event!
'            Case 13: Exit While
'            Case 27: inp$ = "": Exit While
'            Case 32 To 128: If Len(inp$) < boxWidth - 4 Then
'                    inp$ = inp$ + Chr$(kh&): GoSub finishBox
'                Else
'                    Beep
'                End If
'            Case 8: If Len(inp$) Then inp$ = Left$(inp$, Len(inp$) - 1): GoSub finishBox Else Beep
'        End Select
'        _Limit 60
'    Wend

'    'put things back
'    ScnState 1 'need fg and bg colors set to cls
'    Cls '? is this needed YES!!
'    _PutImage , backScrn
'    _Display
'    _FreeImage backScrn
'    _FreeImage ibx
'    ScnState 1 'because we have to call _display, we have to call this again
'    inputBox$ = inp$
'    Exit Function

'    finishBox:
'    _Dest ibx
'    Color BackColor, ForeColor
'    Locate 5, 2: Print Left$(" " + inp$ + Space$(boxWidth - 2), boxWidth - 2)
'    _Dest curScrn
'    Return
'End Function

'' for saving and restoring screen settins

'Sub GetLists (SearchDirectory As String, DirList() As String, FileList() As String)
'    ' Thanks SNcNeill ! for a cross platform method to get file and directory lists
'    'put this block in main code section of your program close to top
'    '' direntry.h needs to be in QB64 folder '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
'    'DECLARE CUSTOMTYPE LIBRARY ".\direntry"
'    '    FUNCTION load_dir& (s AS STRING)
'    '    FUNCTION has_next_entry& ()
'    '    SUB close_dir ()
'    '    SUB get_next_entry (s AS STRING, flags AS LONG, file_size AS LONG)
'    'END DECLARE

'    Const IS_DIR = 1
'    Const IS_FILE = 2
'    Dim As Long flags, file_size, length
'    Dim As Integer DirCount, FileCount
'    Dim nam$
'    ReDim _Preserve DirList(100), FileList(100)
'    DirCount = 0: FileCount = 0

'    If load_dir(SearchDirectory + Chr$(0)) Then
'        Do
'            length = has_next_entry
'            If length > -1 Then
'                nam$ = Space$(length)
'                get_next_entry nam$, flags, file_size
'                If (flags And IS_DIR) Then
'                    DirCount = DirCount + 1
'                    If DirCount > UBound(DirList) Then
'                        ReDim _Preserve DirList(UBound(DirList) + 100)
'                    End If
'                    DirList(DirCount) = nam$
'                ElseIf (flags And IS_FILE) Then
'                    FileCount = FileCount + 1
'                    If FileCount > UBound(FileList) Then
'                        ReDim _Preserve FileList(UBound(FileList) + 100)
'                    End If
'                    FileList(FileCount) = nam$
'                End If
'            End If
'        Loop Until length = -1
'        'close_dir 'move to after end if  might correct the multi calls problem
'    Else
'    End If
'    close_dir 'this  might correct the multi calls problem

'    ReDim _Preserve DirList(DirCount)
'    ReDim _Preserve FileList(FileCount)
'End Sub

'Sub GetListStrings (dirOut$, fileOut$)
'    ReDim Folders$(1 To 1), Files$(1 To 1) ' setup to call GetLists
'    If curPath$ = "" Then curPath$ = _CWD$
'    GetLists curPath$, Folders$(), Files$()
'    dirOut$ = Join$(Folders$(), "~")
'    fileOut$ = Join$(Files$(), "~")
'End Sub ' 937

