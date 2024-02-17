'*****************************************************************************
'
'                            M I N I - G O L F
'
'               Freeware - Copyright (C) 2004 by Bob Seguin
'
'                       Email: BOBSEG@sympatico.ca
'
'*****************************************************************************

$Resize:Smooth

DefInt A-Z

Const Degree! = 3.14159 / 180
Option Base 1

Dim Shared MouseDATA$
Dim Shared LB, RB
Dim Shared MapX!, MapY!, IncX!, IncY!
Dim Shared BallX, BallY, ShiftX, ShiftY
Dim Shared Drop, CupX, CupY, Count&
Dim Shared Strokes, Level, Direction, GamePLAYED
Dim Shared CharBOX(22)
Dim Shared CheckCHAR As String

Level = 1
CheckCHAR = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890.,?'!&()-_" + Chr$(34)

ReDim Shared PuttBOX(32000)
ReDim Shared MapBOX(1, 1)
ReDim Shared FlagBOX(1)
ReDim Shared SBox(850)
ReDim Shared Box(1)
ReDim Shared FontBOX(0 To 1)
ReDim Shared LilBOX(1)
ReDim Shared LilBOX2(1)
ReDim Shared TraxBOX(36)

Dim Shared ScoreBOX(9, 2)
Dim Shared SliderBOX(1325)
Dim Shared DigitBOX(400)
Dim Shared BallBOX(850)
Dim Shared PutterBOX(300)

Type ScoreTYPE
    PlayerNAME As String * 20
    PlayDATE As String * 10
    PlayerSCORE As Integer
    PlayerPAR As Integer
    PlayerSTATUS As Integer
End Type
Dim Shared ScoreDATA(6) As ScoreTYPE

Open "mg.top" For Append As #1: Close #1

Open "mg.top" For Input As #1
Do While Not EOF(1)
    Element = Element + 1
    Input #1, ScoreDATA(Element).PlayerNAME
    Input #1, ScoreDATA(Element).PlayDATE
    Input #1, ScoreDATA(Element).PlayerSCORE
    Input #1, ScoreDATA(Element).PlayerPAR
    Input #1, ScoreDATA(Element).PlayerSTATUS
Loop
Close #1

'Create and load MouseDATA$ for CALL ABSOLUTE routines
MouseDATA:
Data 55,89,E5,8B,5E,0C,8B,07,50,8B,5E,0A,8B,07,50,8B,5E,08,8B
Data 0F,8B,5E,06,8B,17,5B,58,1E,07,CD,33,53,8B,5E,0C,89,07,58
Data 8B,5E,0A,89,07,8B,5E,08,89,0F,8B,5E,06,89,17,5D,CA,08,00
MouseDATA$ = Space$(57)
Restore MouseDATA
For i = 1 To 57
    Read h$
    Hexxer$ = Chr$(Val("&H" + h$))
    Mid$(MouseDATA$, i, 1) = Hexxer$
Next i

Moused = InitMOUSE
If Not Moused Then
    Print "Sorry, cat must have got the mouse."
    Interval 2
    System
End If

ParDATA:
Data 2,3,4,4,4,2,3,3,3

Screen 12
_FullScreen _SquarePixels , _Smooth

SetSCREEN

Do
    PlayGAME
Loop

System

PaletteDATA:
Data 0,0,12,0,10,30,4,11,1,21,21,63
Data 63,0,0,42,0,42,32,15,0,63,16,0
Data 0,63,21,50,27,18,5,13,1,28,28,32
Data 36,36,40,44,44,48,52,52,56,63,63,63

Sub Bridge
    Static Index, StartTIME#
    Shared BridgeNUM, StartBRIDGE

    If StartBRIDGE = 0 Then
        Index = 261
        Put (244, 231), SBox(Index), PSet
        Play "MBT255L64O6g"
        StartBRIDGE = 1
        BridgeNUM = 1
        StartTIME# = Timer
    End If

    If Timer > StartTIME# + 1.2 Then
        Index = Index + 140
        If Index = 821 Then Index = 261
        Play "MBT255L64O6g"
        Put (244, 231), SBox(Index), PSet
        BridgeNUM = BridgeNUM + 1
        If BridgeNUM = 5 Then BridgeNUM = 1
        StartTIME# = Timer
    End If

End Sub

Sub ClearMOUSE

    While LB Or RB
        MouseSTATUS LB, RB, MouseX, MouseY
    Wend

End Sub

Sub ControlBOX
    Static SliderY1, SliderY2, Rotation, Force
    Shared SlowTRAIN, Putted, MapXD, MapYD, LowerLEVEL
    SlowTRAIN = 0: Putted = 0

    ''FieldMOUSE 0, 0, 639, 479

    Get (BallX - 13, BallY - 13)-(BallX + 13, BallY + 13), PutterBOX()
    Put (BallX - 5, BallY - 5), BallBOX(201), And
    Put (BallX - 5, BallY - 5), BallBOX(), Xor

    ShowMOUSE
    If Force = 0 Then Force = 15
    Rotate = 1

    Do
        a$ = InKey$
        If a$ = Chr$(27) Then System
        MouseSTATUS LB, RB, MouseX, MouseY
        Select Case MouseY
            Case 166 To 201 'Putt button
                If MouseX > 527 And MouseX < 603 Then
                    If LB = -1 Then
                        Put (BallX - 13, BallY - 13), PutterBOX(), PSet
                        If Level <> 6 Then
                            HideMOUSE
                            Line (531, 169)-(600, 199), 0, B
                            Line (531, 199)-(600, 199), 15
                            Line (600, 168)-(600, 199), 15
                            ShowMOUSE
                            Interval .1
                            HideMOUSE
                            Line (530, 168)-(600, 199), 13, B
                            Line (531, 169)-(598, 169), 3
                            Line (531, 169)-(531, 197), 3
                            ShowMOUSE
                            ClearMOUSE
                        End If
                        Opp! = Cos(Rotation * Degree!)
                        Adj! = Sin(Rotation * Degree!)
                        IncX! = (Opp! * Force) / 100 * -1
                        IncY! = (Adj! * Force) / 100
                        Putted = 1
                        ''FieldMOUSE 478, 0, 639, 479
                        Exit Sub
                    End If
                End If
            Case 249 To 323 'Sliders
                Select Case MouseX
                    Case 535 To 557
                        If LB = -1 Then
                            ''FieldMOUSE 535, 250, 557, 323
                            If Level = 6 Then SlowTRAIN = 0
                            While LB = -1
                                If Level <> 6 Then Wait &H3DA, 8
                                GoSub PutSLIDER1
                                If Level = 7 Then Bridge
                            Wend
                            SlowTRAIN = 1
                            ''FieldMOUSE 0, 0, 639, 479
                            Rotate = 0
                        End If
                    Case 573 To 595
                        If LB = -1 Then
                            ''FieldMOUSE 573, 250, 595, 323
                            SlowTRAIN = 0
                            Rotate = 0
                            While LB = -1
                                If Level = 6 Then Train
                                If Level = 7 Then Bridge
                                If Level <> 6 Then Wait &H3DA, 8
                                GoSub PutSLIDER2
                                If Level = 6 Then Train
                            Wend
                            SlowTRAIN = 1
                            ''FieldMOUSE 0, 0, 639, 479
                        End If
                End Select
            Case 368 To 380 'Instructions
                If MouseX > 531 And MouseX < 599 Then
                    If MenuNUM <> 2 Then
                        GoSub CloseMENU
                        MenuY = 368
                        MI = 721
                        GoSub OpenMENU
                        MenuNUM = 2
                    End If
                    If LB = -1 Then
                        Erase MapBOX
                        ReDim PuttBOX(32000)
                        Instructions
                        Erase PuttBOX
                        If Level = 5 And LowerLEVEL = 1 Then
                            ReDim MapBOX(1 To 188, 1 To 140)
                            Def Seg = VarSeg(MapBOX(1, 1))
                            BLoad "mglev5b.map", VarPtr(MapBOX(1, 1))
                            Def Seg
                        Else
                            ReDim MapBOX(MapXD, MapYD)
                            FileNAME$ = "mglevel" + LTrim$(Str$(Level)) + ".map"
                            Def Seg = VarSeg(MapBOX(1, 1))
                            BLoad FileNAME$, VarPtr(MapBOX(1, 1))
                            Def Seg
                        End If
                    End If
                End If
            Case 398 To 414 'EXIT
                If MouseX > 541 And MouseX < 588 Then
                    If LB Then
                        HideMOUSE
                        Line (542, 398)-(587, 414), 11, B
                        Line (542, 414)-(587, 414), 15
                        Line (587, 398)-(587, 414), 15
                        ShowMOUSE
                        Interval .1
                        HideMOUSE
                        Line (542, 398)-(587, 414), 15, B
                        Line (542, 414)-(587, 414), 11
                        Line (587, 398)-(587, 414), 11
                        ShowMOUSE
                        Interval .1
                        ExitGAME
                    End If
                End If
            Case Else
                GoSub CloseMENU
        End Select

        If Rotate = 1 Then
            Put (BallX - 13, BallY - 13), PutterBOX(), PSet
            If Level = 4 Then
                Traps
                If MapBOX(MapX!, MapY!) < 0 Then
                    Get (BallX - 13, BallY - 13)-(BallX + 13, BallY + 13), PutterBOX()
                End If
            End If
            Angler = Angler + 5
            If Angler = 360 Then Angler = 0
            PutPUTTER BallX, BallY, Angler
            Wait &H3DA, 8
            Wait &H3DA, 8, 8
        End If

        If Level = 4 And Rotate = 0 Then Traps
        If Level = 6 Then Train
        If Level = 7 Then Bridge

        If LB = -1 And MenuNUM Then
            ClearMOUSE
        End If
        If Level = 7 Then Bridge
    Loop

    Exit Sub

    OpenMENU:
    HideMOUSE
    Get (532, MenuY)-(598, MenuY + 13), SliderBOX(981)
    Put (532, MenuY), SliderBOX(MI), PSet
    ShowMOUSE
    Return

    CloseMENU:
    If MenuNUM Then
        HideMOUSE
        Put (532, MenuY), SliderBOX(981), PSet
        ShowMOUSE
        MenuNUM = 0
    End If
    Return

    PutSLIDER1:
    If SliderBOX(131) Then
        HideMOUSE
        Put (535, SliderY1), SliderBOX(131), PSet
        ShowMOUSE
    Else
        HideMOUSE
        Put (535, 316), SliderBOX(65), PSet
        ShowMOUSE
    End If
    SliderY1 = MouseY - 5
    HideMOUSE
    Get (535, SliderY1)-(557, SliderY1 + 9), SliderBOX(131)
    Put (535, SliderY1), SliderBOX(), PSet
    ShowMOUSE
    Force = 317 - SliderY1
    If Force < 0 Then Force = 0
    If Force > 72 Then Force = 72
    Force = Force + 15
    Return

    PutSLIDER2:
    If SliderBOX(1251) Then
        HideMOUSE
        Put (573, SliderY2), SliderBOX(1251), PSet
        ShowMOUSE
    Else
        HideMOUSE
        Put (573, 316), SliderBOX(65), PSet
        ShowMOUSE
    End If
    SliderY2 = MouseY - 5
    HideMOUSE
    Get (573, SliderY2)-(595, SliderY2 + 9), SliderBOX(1251)
    Put (573, SliderY2), SliderBOX(), PSet
    ShowMOUSE

    Angle = 317 - SliderY2
    If Angle < 0 Then Angle = 0
    If Angle > 72 Then Angle = 72
    Rotation = Angle * 5 - 90
    HideMOUSE
    Put (BallX - 13, BallY - 13), PutterBOX(), PSet
    Get (BallX - 13, BallY - 13)-(BallX + 13, BallY + 13), PutterBOX()
    PutPUTTER BallX, BallY, Rotation
    ShowMOUSE
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Return

End Sub

Sub Digital

    x = 558: y = 139
    Num$ = LTrim$(Str$(Strokes))
    If Len(Num$) = 1 Then Num$ = "0" + Num$
    For Digit = 1 To Len(Num$)
        Digit$ = Mid$(Num$, Digit, 1)
        DigitINDEX = Val(Digit$) * 40 + 1
        Put (x, y), DigitBOX(DigitINDEX), PSet
        x = x + DigitBOX(DigitINDEX)
    Next Digit

End Sub

Sub EndGAME

    HideMOUSE
    Beep
    Open "mgover.dat" For Input As #1
    For x = 0 To 257
        For y = 0 To 60
            Input #1, Colr
            If Colr Then PSet (x + 140, y + 230), Colr
        Next y
    Next x
    Close #1
    Do: Loop Until InKey$ = ""
    Interval 1.4

    ReDim PuttBOX(16000)
    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mgfinal1.bsv", VarPtr(PuttBOX(1))
    Def Seg
    Put (110, 159), PuttBOX(), PSet
    ScoreCARD
    a$ = Input$(1)
    If a$ = Chr$(27) Then System
    ReDim FontBOX(0 To 5171)
    Def Seg = VarSeg(FontBOX(0))
    BLoad "mg.fbs", VarPtr(FontBOX(0))
    Def Seg

    If 1000 - Strokes > ScoreDATA(5).PlayerSTATUS Then
        If 1000 - Strokes > ScoreDATA(1).PlayerSTATUS Then
            Def Seg = VarSeg(PuttBOX(1))
            BLoad "mgfinal5.bsv", VarPtr(PuttBOX(1))
            Def Seg
        Else
            Def Seg = VarSeg(PuttBOX(1))
            BLoad "mgfinal2.bsv", VarPtr(PuttBOX(1))
            Def Seg
        End If
        Put (110, 159), PuttBOX(), PSet
        GoSub GetNAME
        If Len(ScoreDATA(6).PlayerNAME) Then
            For a = 1 To 6
                For B = a To 6
                    If ScoreDATA(B).PlayerSTATUS > ScoreDATA(a).PlayerSTATUS Then Swap ScoreDATA(B), ScoreDATA(a)
                Next B
            Next a
            Open "mg.top" For Output As #1
            For n = 1 To 5
                Write #1, ScoreDATA(n).PlayerNAME, ScoreDATA(n).PlayDATE, ScoreDATA(n).PlayerSCORE, ScoreDATA(n).PlayerPAR, ScoreDATA(n).PlayerSTATUS
            Next n
            Close #1
        End If
    End If
    Do: Loop Until InKey$ = ""
    TopFIVE
    Erase FontBOX
    a$ = Input$(1)
    If a$ = Chr$(27) Then System
    x1 = 268: x2 = 268
    y1 = 100: y2 = 100

    'Erase previous level graphic
    For n = 0 To 248
        If x2 + n > 470 Then y2 = 110
        Line (x1 - n, y1)-(x1 - n, 460), 0
        Line (x2 + n, y2)-(x2 + n, 460), 0
    Next n
    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mgfinal4.bsv", VarPtr(PuttBOX(1))
    Def Seg
    Put (80, 190), PuttBOX(), PSet

    GamePLAYED = 1

    a$ = Input$(1)
    If a$ = Chr$(13) Then
        Level = 1
        Count& = 0
        Exit Sub
    ElseIf a$ = Chr$(27) Then
        System
    Else
        ExitGAME
    End If

    Exit Sub

    GetNAME:
    x = 170
    Line (x, 298)-(x + 5, 298), 12, B
    Do
        Do
            k$ = InKey$
        Loop Until k$ <> ""
        Select Case k$
            Case Chr$(8) 'Backspace
                If CharX Then
                    Line (x, 298)-(x + 5, 298), 14, BF
                    Line (CharBOX(CharX), 286)-(x, 298), 14, BF
                    Name$ = Left$(Name$, Len(Name$) - 1)
                    x = CharBOX(CharX)
                    Line (x, 298)-(x + 5, 298), 12, B
                    CharX = CharX - 1
                End If
            Case Chr$(13) 'Enter
                Name$ = LTrim$(Name$)
                If Len(Name$) Then
                    Line (x, 298)-(x + 5, 298), 14, BF
                    ScoreDATA(6).PlayerNAME = Name$
                    ScoreDATA(6).PlayDATE = Date$
                    ScoreDATA(6).PlayerSCORE = Strokes
                    ScoreDATA(6).PlayerPAR = Strokes - 28
                    ScoreDATA(6).PlayerSTATUS = 1000 - Strokes
                Else
                    ScoreDATA(6).PlayerSTATUS = 0
                End If
                Name$ = ""
                CharX = 0
                Erase CharBOX
                Exit Do
            Case Chr$(27)
                System
            Case Else
                If InStr(CheckCHAR, k$) Then
                    If Len(Name$) < 20 Then
                        Name$ = Name$ + k$
                        Line (x, 298)-(x + 5, 298), 14, BF
                        CharX = CharX + 1
                        CharBOX(CharX) = x
                        PrintSTRING x, 286, k$
                        Line (x, 298)-(x + 5, 298), 12, B
                    End If
                End If
        End Select
    Loop
    Return

End Sub

Sub ExitGAME

    SetPALETTE 0
    HideMOUSE
    Cls
    Erase MapBOX
    ReDim PuttBOX(16000)
    Def Seg = VarSeg(PuttBOX(1))
    If ScoreBOX(1, 2) = 0 And GamePLAYED = 0 Then
        BLoad "mgsplsh1.bsv", VarPtr(PuttBOX(1))
        Put (154, 140), PuttBOX(1), PSet
        Def Seg
        SetPALETTE 1
    Else
        BLoad "mgsplsh2.bsv", VarPtr(PuttBOX(1))
        Def Seg
        Put (154, 140), PuttBOX(1), PSet
        SetPALETTE 1
        Open "mgthanks.dat" For Input As #1
        For x = 0 To 210
            For y = 0 To 38
                Input #1, Colr
                If Colr Then PSet (x + 208, y + 248), 8
            Next y
            If x Mod 5 = 0 Then Wait &H3DA, 8
        Next x
        Close #1
    End If
    Sleep 1
    System

End Sub

Sub FieldMOUSE (x1, y1, x2, y2)

    MouseDRIVER 7, 0, x1, x2
    MouseDRIVER 8, 0, y1, y2

End Sub

Sub HideMOUSE

    LB = 2
    MouseDRIVER LB, 0, 0, 0

End Sub

Function InitMOUSE

    LB = 0
    MouseDRIVER LB, 0, 0, 0
    InitMOUSE = LB

End Function

Sub Instructions

    ClearMOUSE
    HideMOUSE
    Get (110, 159)-(439, 347), PuttBOX()
    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mghelp1.bsv", VarPtr(PuttBOX(16100))
    Def Seg
    Put (110, 159), PuttBOX(16100), PSet
    ShowMOUSE

    Do
        a$ = InKey$
        If a$ = Chr$(27) Then System
        MouseSTATUS LB, RB, MouseX, MouseY
        If MouseX > 379 And MouseX < 421 Then
            If MouseY > 177 And MouseY < 199 Then
                If CloseMENU = 0 Then GoSub OpenCLOSE
            Else
                GoSub CloseCLOSE
            End If
        Else
            GoSub CloseCLOSE
        End If
        If CloseMENU And LB = -1 Then
            If HelpCOUNT = 0 Then
                ClearMOUSE
                HelpCOUNT = 1
                Def Seg = VarSeg(PuttBOX(1))
                BLoad "mghelp2.bsv", VarPtr(PuttBOX(16100))
                Def Seg
                HideMOUSE
                Put (110, 159), PuttBOX(16100), PSet
                ShowMOUSE
                CloseMENU = 0
            Else
                Exit Do
            End If
        End If
    Loop

    HideMOUSE
    Put (110, 159), PuttBOX(), PSet
    ShowMOUSE
    ClearMOUSE

    Exit Sub

    OpenCLOSE:
    HideMOUSE
    For x = 380 To 416
        For y = 182 To 194
            If Point(x, y) = 1 Then PSet (x, y), 8
        Next y
    Next x
    ShowMOUSE
    CloseMENU = 1
    Return

    CloseCLOSE:
    If CloseMENU = 1 Then
        HideMOUSE
        For x = 380 To 416
            For y = 182 To 194
                If Point(x, y) = 8 Then PSet (x, y), 1
            Next y
        Next x
        ShowMOUSE
        CloseMENU = 0
    End If
    Return

End Sub

DefSng A-Z
Sub Interval (Length!)

    OldTimer# = Timer
    Do
        a$ = InKey$
        If a$ = Chr$(27) Then System
    Loop Until Timer > OldTimer# + Length!
    Wait &H3DA, 8

End Sub

DefInt A-Z
Sub LocateMOUSE (x, y)

    LB = 4
    MX = x
    MY = y
    MouseDRIVER LB, 0, MX, MY

End Sub

Sub MouseDRIVER (LB, RB, MX, MY)

    Def Seg = VarSeg(MouseDATA$)
    Mouse = SAdd(MouseDATA$)
    Call ABSOLUTE_MOUSE_EMU(LB, RB, MX, MY)

End Sub

Sub MouseSTATUS (LB, RB, MouseX, MouseY)

    LB = 3
    MouseDRIVER LB, RB, MX, MY
    LB = ((RB And 1) <> 0)
    RB = ((RB And 2) <> 0)
    MouseX = MX
    MouseY = MY

End Sub

Sub PauseMOUSE (OldLB, OldRB, OldMX, OldMY)
    Shared Key$

    Do
        Key$ = UCase$(InKey$)
        MouseSTATUS LB, RB, MouseX, MouseY
    Loop Until LB <> OldLB Or RB <> OldRB Or MouseX <> OldMX Or MouseY <> OldMY Or Key$ <> ""

End Sub

Sub PlayGAME
    Shared BoxCAR, BallIN, StopTRAIN, BridgeNUM, StartBRIDGE, LowerLEVEL

    Select Case Level
        Case 1
            Strokes = 0
            Digital
            Restore ParDATA
            For n = 1 To 9
                Read ScoreBOX(n, 1)
                ScoreBOX(n, 2) = 0
            Next n
            SetLEVEL 81, 101
            If GamePLAYED Then Shell "MGTheme"
        Case 2
            SetLEVEL 70, 121
        Case 3
            SetLEVEL 53, 117
        Case 4
            SetLEVEL 40, 140
        Case 5
            LowerLEVEL = 0
            SetLEVEL 40, 112
        Case 6
            BoxCAR = 0: BallIN = 0: StopTRAIN = 0: Direction = 0
            SetLEVEL 60, 116
        Case 7
            BridgeNUM = 0: StartBRIDGE = 0
            SetLEVEL 60, 116
        Case 8
            SetLEVEL 70, 110
        Case 9
            SetLEVEL 109, 105
    End Select

    BallX = MapX! * 2 + ShiftX
    BallY = MapY! * 2 + ShiftY
    Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
    Put (BallX - 5, BallY - 5), BallBOX(201), And
    Put (BallX - 5, BallY - 5), BallBOX(), Xor

    Do
        ControlBOX
        Strokes = Strokes + 1
        ScoreBOX(Level, 2) = ScoreBOX(Level, 2) + 1
        Digital
        Put (BallX - 5, BallY - 5), BallBOX(450), PSet
        Play "MBT220L64O3C"

        Do
            Select Case MapBOX(MapX!, MapY!)
                Case 0
                    Bounce = 0
                    Cup = 0
                    MapX! = LocX!: MapY! = LocY!
                Case -1, 1, 1000
                    Select Case Level
                        Case 2
                            If MapBOX(MapX!, MapY!) = 1 Then
                                For Index = 261 To 456 Step 65
                                    Put (246, 231), SBox(Index), PSet
                                    Wait &H3DA, 8
                                    Wait &H3DA, 8, 8
                                    Wait &H3DA, 8
                                    Wait &H3DA, 8, 8
                                Next Index
                            End If
                            Play "MFT255O2L64cp16<bp16ap16g"
                            GoSub ResetBALL
                        Case 4
                            If Drop = 1 Then
                                Sy = 158: Sy2 = 175
                                SI = 461
                                GoSub DropBALL
                                MapX! = 117
                                MapY! = 19
                                IncX! = Abs(IncX!)
                                IncY! = 0
                            End If
                        Case 5
                            Get (168, 267)-(182, 281), SBox(456)
                            Put (168, 267), SBox(391), And
                            Put (168, 267), SBox(261), Xor
                            Interval 0
                            Put (168, 267), SBox(456), PSet
                            Put (168, 267), SBox(391), And
                            Put (168, 267), SBox(326), Xor
                            Interval 0
                            Put (168, 267), SBox(456), PSet
                            GoSub ResetBALL
                            Exit Do
                        Case 6
                            If BoxCAR Then
                                BallIN = 1
                                SlowTRAIN = 1
                                Play "MBMST255O4L64b"
                                Do
                                    Train
                                    Wait &H3DA, 8
                                    Wait &H3DA, 8, 8
                                Loop While BallIN
                                x = 195
                                Play "MBMST255L64O6b"
                                Do
                                    Get (x - 5, 280)-(x + 5, 290), BallBOX(450)
                                    Put (x - 5, 280), BallBOX(201), And
                                    Put (x - 5, 280), BallBOX(), Xor
                                    Wait &H3DA, 8
                                    Put (x - 5, 280), BallBOX(450), PSet
                                    StopTRAIN = 1
                                    Train
                                    x = x - 1
                                Loop Until x = 90
                                Count2 = 2
                                Cup = 1
                            Else
                                Play "MBMST255L64O2C"
                                IncX! = IncX! * -1
                            End If
                        Case 9 'map value 1
                            If MapY! > 84 Then 'bottom half
                                If MapX! < 61 Then
                                    'left side
                                    StartDEGREES = 331
                                    Advance = 37
                                Else
                                    'right side
                                    StartDEGREES = 31
                                    Advance = 34
                                End If
                            Else 'top half
                                If MapX! < 61 Then
                                    'left side
                                    StartDEGREES = 171
                                    Advance = 45
                                Else
                                    'right side
                                    StartDEGREES = 111
                                    Advance = 48
                                End If
                            End If
                            Roulette StartDEGREES, Advance, 4
                    End Select
                Case -2, 2, 20
                    Bounce = 0
                    CupSOUND = 0
                    Cup = 0
                    LocX! = MapX!: LocY! = MapY!
                Case -3, 3 'left well
                    Select Case Level
                        Case 4
                            If Drop = 2 Then
                                Sy = 188: Sy2 = 205
                                SI = 571
                                GoSub DropBALL
                                MapX! = 117
                                MapY! = 34
                                IncX! = Abs(IncX!)
                                IncY! = 0
                            End If
                        Case 5
                            Play "MBMST255L64O3gP32eP32cO2CP32CP32>"
                            Get (138, 297)-(152, 311), SBox(456)
                            Put (138, 297), SBox(391), And
                            Put (138, 297), SBox(261), Xor
                            Interval 0
                            Put (138, 297), SBox(391), And
                            Put (138, 297), SBox(326), Xor
                            Interval 0
                            Put (138, 297), SBox(456), PSet
                            Interval .5
                            Play "MFCP32CP32CP32CP32<CP32CP32CP32>CP32CP32C"
                            GoSub NewMAP
                            MapX! = 105: MapY! = 20
                            BumpUP! = Abs(IncX!) + Abs(IncY!)
                            If BumpUP! < .2 Then BumpUP! = .2
                            IncX! = .36 * BumpUP!: IncY! = .18 * BumpUP!
                        Case 9
                            If MapY! > 84 Then 'bottom half
                                StartDEGREES = 311
                                Advance = 45
                            Else
                                StartDEGREES = 191
                                Advance = 52
                            End If
                            Roulette StartDEGREES, Advance, 2
                            GoSub ResetBALL
                    End Select
                Case 4, 40
                    If Bounce <> 4 Then
                        SwapX! = IncX!
                        IncX! = IncY! * -1
                        IncY! = SwapX! * -1
                        Play "MBMST255L64O2C"
                        Bounce = 4
                    End If
                Case -5, 5 'right well
                    Select Case Level
                        Case 4
                            If Drop = 3 Then
                                Sy = 218
                                Sy2 = 235
                                SI = 681
                                GoSub DropBALL
                                MapX! = 117
                                MapY! = 49
                                IncX! = Abs(IncX!)
                                IncY! = 0
                            End If
                        Case 5
                            Get (198, 237)-(212, 251), SBox(456)
                            Put (198, 237), SBox(391), And
                            Put (198, 237), SBox(261), Xor
                            Interval 0
                            Put (198, 237), SBox(391), And
                            Put (198, 237), SBox(326), Xor
                            Interval 0
                            Put (198, 237), SBox(456), PSet
                            Play "MBMST255L32O4Cp32bp32<ap32gp32fp32<ep32c"
                            GoSub NewMAP
                            MapX! = MapX! - 2: MapY! = MapY! + 2
                            IncX! = -.16: IncY! = .16
                        Case 9 'map value 5
                            If MapY! > 84 Then 'bottom half
                                If MapX! > 59 Then
                                    'right side
                                    StartDEGREES = 351
                                    Advance = 44
                                Else
                                    'left side
                                    StartDEGREES = 291
                                    Advance = 47
                                End If
                            Else
                                If MapX! > 59 Then
                                    'right side
                                    StartDEGREES = 151
                                    Advance = 54
                                Else 'top half
                                    'left side
                                    StartDEGREES = 211
                                    Advance = 51
                                End If
                            End If
                            Roulette StartDEGREES, Advance, 3
                    End Select
                Case 6, 60
                    If Bounce <> 6 Then
                        SwapX! = IncX!
                        IncX! = IncY! * -1
                        IncY! = SwapX! * -1
                        Play "MBMST255L64O2C"
                        Bounce = 6
                    End If
                Case 7, 70
                    If Bounce <> 7 Then
                        IncY! = Abs(IncY!)
                        Play "MBMST255L64O2C"
                        Bounce = 7
                    End If
                Case 8, 80
                    If Bounce <> 8 Then
                        SwapX! = IncX!
                        Swap IncX!, IncY!
                        Swap IncY!, SwapX!
                        Play "MBMST255L64O2C"
                        Bounce = 8
                    End If
                Case 9, 90
                    If Bounce <> 9 Then
                        IncY! = -Abs(IncY!)
                        Play "MBMST255L64O2C"
                        Bounce = 9
                    End If
                Case 10, 100
                    If Bounce <> 10 Then
                        IncX! = -Abs(IncX!)
                        Play "MBMST255L64O2C"
                        Bounce = 10
                    End If
                Case 11, 110
                    If Bounce <> 11 Then
                        IncX! = Abs(IncX!)
                        Play "MBMST255L64O2C"
                        Bounce = 11
                    End If
                Case 12
                    If (Abs(IncX!) + Abs(IncY!)) < .2 Then
                        Cup = 1
                    Else
                        If CupSOUND = 0 Then
                            Play "MBMST255L64O5C"
                            CupSOUND = 1
                        End If
                    End If
                Case 13, 130
                    If Bounce <> 13 Then
                        Swap IncX!, IncY!
                        Play "MBMST255L64O2C"
                        Bounce = 13
                    End If
                Case 14
                    If MapY! > 84 Then 'bottom half
                        StartDEGREES = 11
                        Advance = 43
                    Else
                        StartDEGREES = 131
                        Advance = 36
                    End If
                    Roulette StartDEGREES, Advance, 1
                    Cup = 1
                Case 15 'hole 9 only
                    Put (170, 141), SBox(261), PSet
                    Play "MfT255O2L64a"
                    Wait &H3DA, 8
                    Wait &H3DA, 8, 8
                    Put (170, 141), SBox(326), PSet
                    Wait &H3DA, 8
                    Wait &H3DA, 8, 8
                    Put (170, 141), SBox(391), PSet
                    Play "MfT255O3L64c"
                    Wait &H3DA, 8
                    Wait &H3DA, 8, 8
                    Put (170, 141), SBox(456), PSet
                    GoSub ResetBALL
                Case 30
                    Select Case IncX!
                        Case Is < 0
                            Select Case BridgeNUM
                                Case 1: IncY! = 0
                                Case 2: GoSub SinkBALL
                                Case 3: Play "MBMST255L64O2b": IncX! = IncX! * -1
                                Case 4: GoSub Splunk
                            End Select
                        Case Is > 0
                            Select Case BridgeNUM
                                Case 1: IncY! = 0
                                Case 2: GoSub Splunk
                                Case 3: Play "MBMST255L64O2b": IncX! = IncX! * -1
                                Case 4: GoSub SinkBALL
                            End Select
                    End Select
            End Select
            BallX = MapX! * 2 + ShiftX
            BallY = MapY! * 2 + ShiftY
            Count2 = Count2 + 1
            If Count2 = 32000 Then Count2 = 0
            If Cup = 1 Then Count2 = Count2 - Count2 Mod 3
            If Count2 Mod 3 = 0 Then
                If Cup = 1 Then
                    Put (CupX, CupY), BallBOX(201), And
                    Put (CupX, CupY), BallBOX(), Xor
                    Play "MBMST255O5L64ap32bp32>c"
                    Cup = 0
                    Level = Level + 1
                    If Level = 7 Then StopTRAIN = 0
                    Interval 2
                    If Level = 10 Then
                        Erase MapBOX
                        EndGAME
                    End If
                    Exit Sub
                End If
                Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
                If Level = 4 Then Traps
                If MapBOX(MapX!, MapY!) < 20 Then
                    Put (BallX - 5, BallY - 5), BallBOX(201), And
                    Put (BallX - 5, BallY - 5), BallBOX(), Xor
                    If Level = 6 Then Train
                    If Level = 7 Then Bridge
                End If
                Wait &H3DA, 8
                If Level <> 6 Then Wait &H3DA, 8, 8
                Put (BallX - 5, BallY - 5), BallBOX(450), PSet
                Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
                IncX! = IncX! * .994
                IncY! = IncY! * .994
            End If
            MapX! = MapX! + IncX!
            MapY! = MapY! + IncY!
        Loop While (Abs(IncX!) + Abs(IncY!)) > .05

        Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
        If MapBOX(MapX!, MapY!) < 20 Then
            Put (BallX - 5, BallY - 5), BallBOX(201), And
            Put (BallX - 5, BallY - 5), BallBOX(), Xor
        Else
            GoSub ResetBALL
            If Level = 5 Then
                Erase MapBOX
                ReDim MapBOX(67, 115)
                Def Seg = VarSeg(MapBOX(1, 1))
                BLoad "mglevel5.map", VarPtr(MapBOX(1, 1))
                Def Seg
            End If
            Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
            Put (BallX - 5, BallY - 5), BallBOX(201), And
            Put (BallX - 5, BallY - 5), BallBOX(), Xor
        End If
    Loop

    If MapBOX(MapX!, MapY!) < 20 Then
        Put (BallX - 5, BallY - 5), BallBOX(201), And
        Put (BallX - 5, BallY - 5), BallBOX()
    End If

    Exit Sub

    DropBALL:
    Put (235, Sy), SBox(), And
    Put (235, Sy), SBox(221), Xor
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (235, Sy), SBox(), And
    Put (235, Sy), SBox(331), Xor
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (235, Sy), SBox(SI), PSet
    Play "MFT220L64O2AP32FP32DP1"
    Get (270, Sy2)-(274, Sy2 + 11), SBox(800)
    Put (270, Sy2), SBox(441), PSet
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (270, Sy2), SBox(800), PSet
    Return

    NewMAP:
    Erase MapBOX
    ReDim MapBOX(1 To 188, 1 To 140)
    Def Seg = VarSeg(MapBOX(1, 1))
    BLoad "mglev5b.map", VarPtr(MapBOX(1, 1))
    Def Seg
    ShiftX = 45: ShiftY = 116
    MapX! = MapX! + 31: MapY! = MapY! + 26
    LowerLEVEL = 1
    Return

    ResetBALL:
    Select Case Level
        Case 2
            ResetX = 119: ResetY = 379
            MapX! = 28: MapY! = 133
            ShiftX = 70: ShiftY = 121
        Case 5:
            ResetX = 168: ResetY = 381
            MapX! = 34: MapY! = 109.5
            ShiftX = 107: ShiftY = 169
            LowerLEVEL = 0
        Case 7:
            ResetX = 104: ResetY = 378
            MapX! = 25: MapY! = 83.5
        Case 8:
            ResetX = 193: ResetY = 371
            MapX! = 27.5: MapY! = 132.5
        Case 9:
            ResetX = 252: ResetY = 382
            MapX! = 58.5: MapY! = 141.5
    End Select
    IncX! = 0: IncY! = 0
    Put (ResetX, ResetY), SBox(), PSet
    Play "MBT255L64O6b"
    Play "MFMST255L64O3gP32eP32cO1CP32CP32"
    Play "CP32CP32CP32CP32CP32CP32CP32CP32CP32CP32CP32CP32CP32CP32C"
    Play "CP32CP32CP32CP32CP32CP32CP32CP32CP32"
    Play "CP32CP32CP32CP32CP32CP32CP32CP32CP32CP32O5BP32>BP32<B"
    Interval 0
    Put (ResetX, ResetY), SBox(66), PSet
    Interval 0
    Put (ResetX, ResetY), SBox(131), PSet
    Interval 0
    Play "MBT255L64O6b"
    Put (ResetX, ResetY), SBox(196), PSet
    BallX = MapX! * 2 + ShiftX
    BallY = MapY! * 2 + ShiftY
    Return

    'The following 2 subroutines apply to hole 7 only
    SinkBALL: 'Ball to cup
    Get (249, 310)-(259, 320), BallBOX(450)
    Play "MBMST255L64O2b"
    StartTIME# = Timer: Do: Loop While Timer < StartTIME# + .2
    Play "MFT255L64O5CP32<CP32<CP32<CP32<C"
    For y = 297 To 408
        Get (249, y)-(259, y + 10), BallBOX(450)
        Put (249, y), BallBOX(201), And
        Put (249, y), BallBOX(), Xor
        Wait &H3DA, 8
        Wait &H3DA, 8, 8
        Put (249, y), BallBOX(450), PSet
    Next y
    Cup = 1
    Return

    Splunk: 'Water hazard
    Play "MBMST255L64O2b"
    Interval .3
    Play "MBMST255L64O5cP16eP16c<P16gP16>>c"
    For Index = 851 To 2251 Step 200
        Wait &H3DA, 8
        Put (242, 195), SBox(Index), PSet
        Interval .02
    Next Index
    GoSub ResetBALL
    Return

End Sub

Sub PrintSTRING (x, y, Prnt$)

    For i = 1 To Len(Prnt$)
        Char$ = Mid$(Prnt$, i, 1)
        If Char$ = " " Then
            x = x + FontBOX(1)
        Else
            Index = (Asc(Char$) - 33) * FontBOX(0) + 2
            Put (x, y), FontBOX(Index)
            x = x + FontBOX(Index)
        End If
    Next i

End Sub

Sub PutPUTTER (x, y, Angle)

    Angle2 = Angle - 60
    Angle3 = Angle + 60
    Adj = Cos(Angle * Degree!) * 3
    Opp = Sin(Angle * Degree!) * 3
    Adj1 = Cos(Angle * Degree!) * 4
    Opp1 = Sin(Angle * Degree!) * 4
    Adj4 = Cos(Angle * Degree!) * 5
    Opp4 = Sin(Angle * Degree!) * 5
    Adj2 = Cos(Angle2 * Degree!) * 9
    Opp2 = Sin(Angle2 * Degree!) * 9
    Adj3 = Cos(Angle3 * Degree!) * 9
    Opp3 = Sin(Angle3 * Degree!) * 9
    PointX = x + Adj
    PointY = y - Opp
    LeftX = PointX + Adj2
    LeftY = PointY - Opp2
    RightX = PointX + Adj3
    RightY = PointY - Opp3
    PointX2 = x + Adj1
    PointY2 = y - Opp1
    LeftX2 = PointX2 + Adj2
    LeftY2 = PointY2 - Opp2
    RightX2 = PointX2 + Adj3
    RightY2 = PointY2 - Opp3
    PointX3 = x + Adj4
    PointY3 = y - Opp4
    LeftX3 = PointX3 + Adj2
    LeftY3 = PointY3 - Opp2
    RightX3 = PointX3 + Adj3
    RightY3 = PointY3 - Opp3

    Select Case Angle
        Case 90, -90, 270
            Line (LeftX, RightY)-(RightX, RightY), 12
            Line (LeftX2, RightY2)-(RightX2, RightY2), 13
            Line (LeftX3, RightY3)-(RightX3, RightY3), 15
            Line (LeftX, LeftY)-(LeftX, LeftY3), 15
            Line (RightX, RightY)-(RightX, RightY3), 15
        Case 180
            Line (LeftX, LeftY)-(LeftX, RightY), 12
            Line (LeftX2, LeftY2)-(LeftX2, RightY2), 13
            Line (LeftX3, LeftY3)-(LeftX3, RightY3), 15
            Line (LeftX, LeftY)-(LeftX, LeftY3), 15
            Line (RightX, RightY)-(LeftX3, RightY3), 15
        Case Else
            Line (LeftX, LeftY)-(RightX, RightY), 12
            Line (LeftX2, LeftY2)-(RightX2, RightY2), 13
            Line (LeftX3, LeftY3)-(RightX3, RightY3), 15
            Line (LeftX, LeftY)-(LeftX3, LeftY3), 15
            Line (RightX, RightY)-(RightX3, RightY3), 15
    End Select

End Sub

Sub Roulette (BallSLOT, Advance, OutCOME)

    nn = BallSLOT
    For Spins = 1 To Advance
        a$ = InKey$
        If a$ = Chr$(27) Then System
        nn = nn + 20
        If nn = 360 + BallSLOT Then nn = BallSLOT
        Adj! = 260 + 54 * Sin(Degree! * nn)
        Opp! = 280 + 54 * Cos(Degree! * nn)
        Put (198, 217), SBox(525), PSet

        SpinCOUNT = SpinCOUNT + 1
        If SpinCOUNT Mod 2 Then
            Put (198, 217), SBox(525), PSet
        Else
            Put (198, 217), SBox(4530), PSet
        End If

        Get (Adj! - 5, Opp! - 5)-(Adj! + 5, Opp! + 5), BallBOX(450)
        Put (Adj! - 5, Opp! - 5), BallBOX(201), And
        Put (Adj! - 5, Opp! - 5), BallBOX()

        If Spins > Advance * .6 Then Clicks = 3 Else Clicks = 1
        For Reps = 1 To Clicks
            Wait &H3DA, 8
            Wait &H3DA, 8, 8
        Next Reps

        Play "MFT255O6L64a"
        Put (Adj! - 5, Opp! - 5), BallBOX(450), PSet
    Next Spins

    Select Case OutCOME
        Case 1
            GoSub Cuppa
        Case 2
            GoSub Sewer
        Case 3
            MapX! = 74
            MapY! = 55
            IncX! = -.15
            IncY! = -(Rnd * .5) - .01
        Case 4:
            MapX! = 55
            MapY! = 122
            IncX! = .05
            IncY! = (Rnd * .2) + .01
    End Select

    Exit Sub

    Sewer:
    x! = 267: y! = 210

    Do
        Get (x!, y!)-(x! + 10, y! + 10), BallBOX(450)
        Put (x!, y!), BallBOX(201), And
        Put (x!, y!), BallBOX()
        Wait &H3DA, 8
        Wait &H3DA, 8, 8
        Put (x!, y!), BallBOX(450), PSet
        x! = x! - 1: y! = y! - 1.5
    Loop While y! > 109
    Play "MBMST255L64O2C"

    Do
        Get (x!, y!)-(x! + 10, y! + 10), BallBOX(450)
        Put (x!, y!), BallBOX(201), And
        Put (x!, y!), BallBOX()
        Wait &H3DA, 8
        Wait &H3DA, 8, 8
        Put (x!, y!), BallBOX(450), PSet
        x! = x! - 1: y! = y! + 1.4
    Loop While y! < 142

    Put (170, 141), SBox(261), PSet
    Play "MfT255O2L64a"
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (170, 141), SBox(326), PSet
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (170, 141), SBox(391), PSet
    Play "MfT255O3L64c"
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (170, 141), SBox(456), PSet

    Return

    Cuppa:
    x! = 282: y! = 216

    Do
        Get (x!, y!)-(x! + 10, y! + 10), BallBOX(450)
        Put (x!, y!), BallBOX(201), And
        Put (x!, y!), BallBOX()
        Wait &H3DA, 8
        Wait &H3DA, 8, 8
        Put (x!, y!), BallBOX(450), PSet
        x! = x! - .52: y! = y! - 1.3
    Loop While y! > 109
    Play "MBMST255L64O2C"

    Do
        Get (x!, y!)-(x! + 10, y! + 10), BallBOX(450)
        Put (x!, y!), BallBOX(201), And
        Put (x!, y!), BallBOX()
        Wait &H3DA, 8
        Wait &H3DA, 8, 8
        Put (x!, y!), BallBOX(450), PSet
        x! = x! - .52: y! = y! + 1.3
    Loop While y! < 197
    Play "MBMST255L64O2C"

    SlowY! = .52
    SlowX! = 1.3
    Do
        Get (x!, y!)-(x! + 10, y! + 10), BallBOX(450)
        Put (x!, y!), BallBOX(201), And
        Put (x!, y!), BallBOX()
        Wait &H3DA, 8
        Wait &H3DA, 8, 8
        Put (x!, y!), BallBOX(450), PSet
        SlowX! = SlowX! * .993
        SlowY! = SlowY! * .993
        x! = x! + SlowX!: y! = y! - SlowY!
    Loop While x! < 334

    Return

End Sub

Sub ScoreCARD

    ReDim NumBOX(1900)
    Def Seg = VarSeg(NumBOX(1))
    BLoad "mgnums.fbs", VarPtr(NumBOX(1))
    Def Seg

    For y = 204 To 268 Step 32
        For x = 190 To 370 Step 90
            ParCOUNT = ParCOUNT + 1
            NumVAL = ScoreBOX(ParCOUNT, 2) - ScoreBOX(ParCOUNT, 1)
            Select Case NumVAL
                Case Is < 0
                    Put (x, y), NumBOX(1321)
                    x = x + NumBOX(1321)
                    GoSub PrintNUMS
                    x = x - NumBOX(1321)
                Case 0
                    Put (x, y), NumBOX(1441)
                Case Is > 0
                    Put (x, y), NumBOX(1201)
                    x = x + NumBOX(1201)
                    GoSub PrintNUMS
                    x = x - NumBOX(1201)
            End Select
        Next x
    Next y

    x = 290: y = 300
    NumVAL = Strokes
    GoSub PrintNUMS
    FinalSCORE = Strokes - 28

    Put (331, 297), NumBOX(1641)
    If FinalSCORE < 0 Then Put (338, 305), NumBOX(1321)
    If FinalSCORE > 0 Then Put (338, 305), NumBOX(1201)
    If FinalSCORE = 0 Then
        Put (338, 302), NumBOX(1441)
        Put (366, 300), NumBOX(1741)
        Erase NumBOX
        Exit Sub
    End If

    x = 348: y = 300
    NumVAL = FinalSCORE
    GoSub PrintNUMS
    Put (xx, 297), NumBOX(1741)

    Erase NumBOX
    Exit Sub

    PrintNUMS:
    Num$ = LTrim$(Str$(Abs(NumVAL)))
    xx = x
    For n = 1 To Len(Num$)
        Char$ = Mid$(Num$, n, 1)
        Index = Val(Char$) * 120 + 1
        Put (xx, y), NumBOX(Index)
        xx = xx + NumBOX(Index)
    Next n
    Return

End Sub

Sub SetLEVEL (x, y)
    Static NewGAME
    Shared MapXD, MapYD

    x1 = 268: x2 = 268
    y1 = 100: y2 = 100

    'Erase previous level graphic
    HideMOUSE
    For n = 0 To 248
        If x2 + n > 470 Then y2 = 110
        Line (x1 - n, y1)-(x1 - n, 460), 0
        Line (x2 + n, y2)-(x2 + n, 460), 0
    Next n

    Erase MapBOX

    ReDim PuttBOX(32000)
    FileNAME$ = "mglevel" + LTrim$(Str$(Level)) + ".bsv"
    Def Seg = VarSeg(PuttBOX(1))
    BLoad FileNAME$, VarPtr(PuttBOX(1))
    Def Seg
    Put (x, y), PuttBOX(), PSet
    ShowMOUSE
    Erase PuttBOX

    'PUT level number on flag
    ReDim FlagBOX(1 To 5000)
    Def Seg = VarSeg(FlagBOX(1))
    BLoad "mgfnums.bsv", VarPtr(FlagBOX(1))
    Def Seg
    HideMOUSE
    Put (538, 44), FlagBOX(555 * (Level - 1) + 1), PSet
    ShowMOUSE
    Erase FlagBOX

    If NewGAME = 0 Then
        SetPALETTE 1
        NewGAME = 1
    End If

    Select Case Level
        Case 1
            MapX! = 134: MapY! = 133
            ShiftX = 91: ShiftY = 111
            CupX = 134: CupY = 154
            ReDim MapBOX(157, 157)
            MapXD = 157: MapYD = 157
        Case 2
            MapX! = 27.5: MapY! = 132.5
            ShiftX = 70: ShiftY = 121
            CupX = 379: CupY = 141
            Def Seg = VarSeg(SBox(1))
            BLoad "mgspec2.bsv", VarPtr(SBox(1))
            Def Seg
            ReDim MapBOX(182, 146)
            MapXD = 182: MapYD = 146
        Case 3
            MapX! = 148: MapY! = 118
            ShiftX = 60: ShiftY = 137
            CupX = 142: CupY = 150
            ReDim MapBOX(192, 127)
            MapXD = 192: MapYD = 127
        Case 4
            MapX! = 50: MapY! = 105
            ShiftX = 42: ShiftY = 141
            CupX = 371: CupY = 360
            ReDim SBox(1330)
            Def Seg = VarSeg(SBox(1))
            BLoad "mgspec4.bsv", VarPtr(SBox(1))
            Def Seg
            ReDim MapBOX(217, 136)
            MapXD = 217: MapYD = 136
        Case 5
            MapX! = 34: MapY! = 109.5
            ShiftX = 107: ShiftY = 169
            CupX = 399: CupY = 154
            Def Seg = VarSeg(SBox(1))
            BLoad "mgspec5.bsv", VarPtr(SBox(1))
            Def Seg
            ReDim MapBOX(67, 115)
            MapXD = 67: MapYD = 115
        Case 6
            'MapX! = 59.5: MapY! = 24
            MapX! = 59.5: MapY! = 23.5
            ShiftX = 286: ShiftY = 238
            CupX = 84: CupY = 280
            Def Seg = VarSeg(TraxBOX(1))
            BLoad "mgtrack.lin", VarPtr(TraxBOX(1))
            Def Seg
            ReDim LilBOX(410)
            ReDim LilBOX2(410)
            ReDim MapBOX(69, 47)
            MapXD = 69: MapYD = 47
        Case 7
            MapX! = 25: MapY! = 83.5
            ShiftX = 61: ShiftY = 218
            CupX = 249: CupY = 409
            ReDim SBox(1 To 2650)
            Def Seg = VarSeg(SBox(1))
            BLoad "mgspec7.bsv", VarPtr(SBox(1))
            Def Seg
            ReDim MapBOX(192, 90)
            MapXD = 192: MapYD = 90
        Case 8
            MapX! = 27.5: MapY! = 132.5
            ShiftX = 145: ShiftY = 113
            CupX = 345: CupY = 162
            Def Seg = VarSeg(SBox(1))
            BLoad "mgspec5.bsv", VarPtr(SBox(1))
            Def Seg
            ReDim MapBOX(118, 144)
            MapXD = 118: MapYD = 144
        Case 9
            MapX! = 58.5: MapY! = 141.5
            ShiftX = 142: ShiftY = 106
            CupX = 338: CupY = 143
            ReDim SBox(1 To 8600)
            Def Seg = VarSeg(SBox(1))
            BLoad "mgspec9.bsv", VarPtr(SBox(1))
            Def Seg
            ReDim MapBOX(117, 151)
            MapXD = 117: MapYD = 151
    End Select

    FileNAME$ = "mglevel" + LTrim$(Str$(Level)) + ".map"
    Def Seg = VarSeg(MapBOX(1, 1))
    BLoad FileNAME$, VarPtr(MapBOX(1, 1))
    Def Seg

End Sub

Sub SetPALETTE (OnOFF)

    Select Case OnOFF
        Case 0
            Out &H3C8, 0
            For n = 1 To 48
                Out &H3C9, 0
            Next n
        Case 1
            Restore PaletteDATA
            Out &H3C8, 0
            For n = 1 To 48
                Read Intensity
                Intensity = Intensity + 10
                If Intensity > 63 Then Intensity = 63
                Out &H3C9, Intensity
            Next n
            Out &H3C8, 0
            Out &H3C9, 0
            Out &H3C9, 0
            Out &H3C9, 18
            'RESTORE PaletteDATA
            'OUT &H3C8, 0
            'FOR n = 1 TO 48
            'READ Intensity: OUT &H3C9, Intensity
            'NEXT n
    End Select

End Sub

Sub SetSCREEN

    SetPALETTE 0
    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mgsplsh1.bsv", VarPtr(PuttBOX(16100))
    Def Seg
    Put (154, 140), PuttBOX(16100), PSet
    SetPALETTE 1
    Shell "MGTheme.EXE"
    Interval .75

    SetPALETTE 0
    Cls

    'Screen borders
    Line (5, 5)-(634, 474), 2, B
    Line (10, 10)-(629, 469), 2, B

    'Load title
    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mgtitle.bsv", VarPtr(PuttBOX(1))
    Def Seg
    Put (20, 20), PuttBOX(), PSet

    'Load golfball image and mask
    Def Seg = VarSeg(BallBOX(1))
    BLoad "mgball.bsv", VarPtr(BallBOX(1))
    Def Seg

    'Load control panel
    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mgctrl2.bsv", VarPtr(PuttBOX(1))
    Def Seg
    Put (438, 27), PuttBOX(), PSet

    'Load digital numbers
    Def Seg = VarSeg(DigitBOX(1))
    BLoad "mgdigits.bsv", VarPtr(DigitBOX(1))
    Def Seg

    Digital

    'Load control slider images
    Def Seg = VarSeg(SliderBOX(1))
    BLoad "mgctrl.bsv", VarPtr(SliderBOX(1))
    Def Seg
    Put (535, 316), SliderBOX(), PSet
    Put (573, 316), SliderBOX(), PSet

    'LocateMOUSE 563, 350

    Erase PuttBOX

End Sub

Sub ShowMOUSE
    LB = 1
    MouseDRIVER LB, 0, 0, 0
End Sub

Sub TopFIVE

    Def Seg = VarSeg(PuttBOX(1))
    BLoad "mgfinal3.bsv", VarPtr(PuttBOX(1))
    Def Seg
    Put (110, 159), PuttBOX(), PSet

    TopY = 223
    For n = 1 To 5
        If ScoreDATA(n).PlayerSCORE <> 0 Then
            PrintSTRING 136, TopY, RTrim$(ScoreDATA(n).PlayerNAME)
            PrintSTRING 276, TopY, ScoreDATA(n).PlayDATE
            PrintSTRING 354, TopY, LTrim$(Str$(ScoreDATA(n).PlayerSCORE))
            If ScoreDATA(n).PlayerPAR = 0 Then
                PrintSTRING 392, TopY, "Par"
            Else
                PrintSTRING 393, TopY, LTrim$(Str$(ScoreDATA(n).PlayerPAR))
            End If
        End If
        TopY = TopY + 19
    Next n

End Sub

Sub Train
    Static y, yy, Route, TrackINDEX, Count
    Static StartINDEX, StopINDEX, TrainX, TrackY, UpDOWN
    Shared SlowTRAIN, Putted, BoxCAR, BallIN, StopTRAIN

    Select Case Direction
        Case 0
            'Load Train"
            Def Seg = VarSeg(LilBOX(1))
            BLoad "mgtrupe.lin", VarPtr(LilBOX(1))
            Def Seg
            Def Seg = VarSeg(LilBOX2(1))
            BLoad "mgtrupf.lin", VarPtr(LilBOX2(1))
            Def Seg
            StartINDEX = 1: StopINDEX = 1
            TrackINDEX = 13: TrackY = 433
            TrainX = 265: UpDOWN = 1
            y = 365: Route = -1
            Direction = 1
        Case 1
            If StopTRAIN = 0 Then
                If y > 184 Then yy = y Else yy = 184
                If Count And StartINDEX < 403 Then StartINDEX = StartINDEX + 6
                If yy = 184 Then Count = 1
                If SlowTRAIN And Putted = 0 Then Wait &H3DA, 8
                GoSub PutTRAIN
                If y > 298 And StopINDEX < 403 Then StopINDEX = StopINDEX + 6
                If y Mod 12 = 0 Then Sound 12000, .05
                TrackINDEX = TrackINDEX - 6
                If TrackINDEX = -5 Then TrackINDEX = 31
                If y < 298 Then Put (TrainX, TrackY), TraxBOX(TrackINDEX), PSet
                If y < 126 Then Line (TrainX, TrackY)-(TrainX + 14, TrackY), 0
                TrackY = TrackY - 1
                y = y - 1
                If y > 227 And y < 246 Then
                    BoxCAR = 1
                Else
                    BoxCAR = 0
                End If
                If y = 115 Then
                    Line (265, 184)-(279, 185), 0, B
                    Count = 0
                    Direction = 2
                End If
            End If
        Case 2
            'Load Train"
            Def Seg = VarSeg(LilBOX(1))
            BLoad "mgtrdne.lin", VarPtr(LilBOX(1))
            Def Seg
            Def Seg = VarSeg(LilBOX2(1))
            BLoad "mgtrdnf.lin", VarPtr(LilBOX2(1))
            Def Seg
            StartINDEX = 1: StopINDEX = 1
            TrackINDEX = 13: TrackY = 116
            TrainX = 198: UpDOWN = -1
            y = 184
            Route = 1
            Direction = 3
        Case 3
            If y < 365 Then yy = y Else yy = 365
            If Count And StartINDEX < 403 Then StartINDEX = StartINDEX + 6
            If yy = 365 Then Count = 1
            If SlowTRAIN And Putted = 0 Then Wait &H3DA, 8
            GoSub PutTRAIN
            If y > 183 And StopINDEX < 403 Then StopINDEX = StopINDEX + 6
            If y Mod 12 = 0 Then Sound 12000, .05
            If y <= 261 And y > 250 Then Line (TrainX, TrackY)-(TrainX + 14, TrackY), 0, B
            If y > 261 Then Put (TrainX, TrackY), TraxBOX(TrackINDEX), PSet
            TrackINDEX = TrackINDEX + 6
            If TrackINDEX = 37 Then TrackINDEX = 1
            TrackY = TrackY + 1
            y = y + 1
            If y = 433 Then
                Put (TrainX, TrackY), TraxBOX(TrackINDEX), PSet
                Count = 0
                Direction = 0
            End If
            If BallIN And y > 335 Then BallIN = 0
    End Select

    Exit Sub

    PutTRAIN:
    Index = StartINDEX
    For Reps = 1 To 68
        Select Case UpDOWN
            Case 1
                Select Case BallIN
                    Case 0: Put (TrainX, yy), LilBOX(Index), PSet
                    Case 1: Put (TrainX, yy), LilBOX2(Index), PSet
                End Select
            Case -1
                Select Case BallIN
                    Case 0: Put (TrainX, yy), LilBOX(Index), PSet
                    Case 1: Put (TrainX, yy), LilBOX2(Index), PSet
                End Select
        End Select
        If Index < StopINDEX Then
            Index = Index + 6
            yy = yy + UpDOWN
        End If
    Next Reps
    Return

End Sub

Sub Traps
    Static StartTIME#, Trap
    Shared StartTRAPS

    If StartTRAPS = 0 Then
        Put (235, 218), SBox(681), PSet
        Play "MBT220L64O0CO6B"
        Trap = 1
        StartTIME# = Timer
        StartTRAPS = 1
    End If

    If Timer - StartTIME# > 1 Then GoSub Trap

    Exit Sub

    DropBALL2:
    Select Case Drop
        Case 1
            Sy = 158: Sy2 = 175
            SI = 461
            MapX! = 117
            MapY! = 19
            Get (235, 158)-(252, 175), SBox(851)
        Case 2
            Sy = 188: Sy2 = 205
            SI = 571
            MapX! = 117
            MapY! = 34
            Get (235, 188)-(252, 205), SBox(851)
        Case 3
            Sy = 218
            Sy2 = 235
            SI = 681
            MapX! = 117
            MapY! = 49
            Get (235, 218)-(252, 235), SBox(851)
    End Select
    Put (235, Sy), SBox(), And
    Put (235, Sy), SBox(221), Xor
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (235, Sy), SBox(), And
    Put (235, Sy), SBox(331), Xor
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (235, Sy), SBox(SI), PSet
    Play "MBT220L64O2AP32FP32D"
    Interval 1
    Get (270, Sy2)-(274, Sy2 + 11), SBox(800)
    Put (270, Sy2), SBox(441), PSet
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Wait &H3DA, 8
    Wait &H3DA, 8, 8
    Put (270, Sy2), SBox(800), PSet
    IncX! = .25
    IncY! = 0
    BallX = MapX! * 2 + 42
    BallY = MapY! * 2 + 141
    Get (313, BallY - 13)-(339, BallY + 13), PutterBOX()
    Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
    Do
        If Timer > StartTIME# + 1 Then GoSub Trap
        Put (BallX - 5, BallY - 5), BallBOX(450), PSet
        MapX! = MapX! + IncX!
        BallX = MapX! * 2 + 42
        BallY = MapY! * 2 + 141
        Get (BallX - 5, BallY - 5)-(BallX + 5, BallY + 5), BallBOX(450)
        Put (BallX - 5, BallY - 5), BallBOX(201), And
        Put (BallX - 5, BallY - 5), BallBOX()
        Wait &H3DA, 8
        IncX! = IncX! * .994
    Loop While IncX! > .1
    Put (BallX - 13, BallY - 13), PutterBOX(), PSet
    Put (BallX - 5, BallY - 5), BallBOX(201), And
    Put (BallX - 5, BallY - 5), BallBOX()
    Get (BallX - 13, BallY - 13)-(BallX + 13, BallY + 13), PutterBOX()
    IncX! = 0
    Return

    Trap:
    Count& = Count& + 1
    Select Case Count& Mod 3
        Case 0
            Put (235, 188), SBox(1111), PSet
            Put (235, 218), SBox(461), PSet
            Drop = 3
            If MapBOX(MapX!, MapY!) = -5 Then GoSub DropBALL2
        Case 1
            Put (235, 218), SBox(1221), PSet
            Put (235, 158), SBox(571), PSet
            Drop = 1
            If MapBOX(MapX!, MapY!) = -1 Then GoSub DropBALL2
        Case 2
            Put (235, 158), SBox(1001), PSet
            Put (235, 188), SBox(681), PSet
            Drop = 2
            If MapBOX(MapX!, MapY!) = -3 Then GoSub DropBALL2
    End Select
    Play "MBT220L64O0CO6B"
    StartTIME# = Timer
    Put (BallX - 5, BallY - 5), BallBOX(201), And
    Put (BallX - 5, BallY - 5), BallBOX()
    Return

End Sub

 
Sub ABSOLUTE_MOUSE_EMU (AX%, BX%, CX%, DX%)
    Select Case AX%
        Case 0
            AX% = -1
        Case 1
            _MouseShow
        Case 2
            _MouseHide
        Case 3
            While _MouseInput
            Wend
            BX% = -_MouseButton(1) - _MouseButton(2) * 2 - _MouseButton(3) * 4
            CX% = _MouseX
            DX% = _MouseY
        Case 4
            _MouseMove CX%, DX% 'Not currently supported in QB64 GL
    End Select
End Sub
