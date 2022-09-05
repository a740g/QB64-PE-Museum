'CHESSUBS.BAS
DefInt A-Z

Dim Shared MouseDATA$
Dim Shared LB, RB

'Create and load MouseDATA$ for CALL ABSOLUTE routines
Data 55,89,E5,8B,5E,0C,8B,07,50,8B,5E,0A,8B,07,50,8B,5E,08,8B
Data 0F,8B,5E,06,8B,17,5B,58,1E,07,CD,33,53,8B,5E,0C,89,07,58
Data 8B,5E,0A,89,07,8B,5E,08,89,0F,8B,5E,06,89,17,5D,CA,08,00
MouseDATA$ = Space$(57)
For i = 1 To 57
    Read h$
    Hexxer$ = Chr$(Val("&H" + h$))
    Mid$(MouseDATA$, i, 1) = Hexxer$
Next i

Moused = InitMOUSE
If Not Moused Then
    Print "Sorry, cat must have got the mouse."
    Sleep 2
    System
End If

BoardDATA:
Data 2,3,4,5,6,4,3,2
Data 1,1,1,1,1,1,1,1
Data 0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0
Data 11,11,11,11,11,11,11,11
Data 12,13,14,15,16,14,13,12

Dim Shared Box(1 To 26000)
Dim Shared LilBOX(1 To 800)
Dim Shared Board(1 To 8, 1 To 8)

Const King = 1
Const Queen = 751
Const Bishop = 1501
Const Knight = 2251
Const Rook = 3001
Const Pawn = 3751
Const White = 0 'piece color
Const Black = 4500 'piece color
Const Light = 0 'square color
Const Dark = 9000 'square color
Const ELight = 18751 'erase light square
Const EDark = 18001 'erase dark square

Screen 12

SetPALETTE
LoadSCREEN
Color 7: Locate 29, 22: Print "PRESS ESC TO QUIT";
LocateMOUSE 254, 194
ShowMOUSE
Do
    k$ = InKey$
    MouseSTATUS LB, RB, MouseX, MouseY
    Select Case MouseX
        Case 31 To 80: Col = 1
        Case 81 To 130: Col = 2
        Case 131 To 180: Col = 3
        Case 181 To 230: Col = 4
        Case 231 To 280: Col = 5
        Case 281 To 330: Col = 6
        Case 331 To 380: Col = 7
        Case 381 To 430: Col = 8
    End Select
    Select Case MouseY
        Case 31 To 80: Row = 1
        Case 81 To 130: Row = 2
        Case 131 To 180: Row = 3
        Case 181 To 230: Row = 4
        Case 231 To 280: Row = 5
        Case 281 To 330: Row = 6
        Case 331 To 380: Row = 7
        Case 381 To 430: Row = 8
    End Select

    If LB = -1 Then
        Select Case Clicked
            Case 0
                ExROW = Row: ExCOL = Col
                HighLIGHT Row, Col, 1
                Clicked = 1
            Case 1
                If ExROW = Row And ExCOL = Col Then
                    HighLIGHT Row, Col, 0
                Else
                    PutPIECE ExROW, ExCOL, Row, Col
                End If
                Clicked = 0
        End Select
    End If

    ClearMOUSE
Loop Until k$ = Chr$(27)

System

PaletteDATA:
Data 12,0,10,17,19,17,20,22,20,23,25,23
Data 63,0,0,63,60,50,58,55,45,53,50,40
Data 0,0,0,42,42,48,50,50,55,40,40,63
Data 15,15,34,58,37,15,60,52,37,63,63,63

Sub ClearMOUSE

    While LB Or RB
        MouseSTATUS LB, RB, MouseX, MouseY
    Wend

End Sub

Sub ClearSQUARE (Row, Col)

    If (Col + Row Mod 2) Mod 2 Then Square = EDark Else Square = ELight
    x = Col * 50 - 19
    y = Row * 50 - 19
    Put (x, y), Box(Square), PSet

End Sub

Sub FieldMOUSE (x1, y1, x2, y2)

    MouseDRIVER 7, 0, x1, x2
    MouseDRIVER 8, 0, y1, y2

End Sub

Sub HideMOUSE

    LB = 2
    MouseDRIVER LB, 0, 0, 0

End Sub

Sub HighLIGHT (Row, Col, OnOFF)
    Static SquareON, Oldx, Oldy

    If SquareON And OnOFF = 0 Then
        HideMOUSE
        Put (Oldx, Oldy), LilBOX(), PSet
        ShowMOUSE
        SquareON = 0
        Exit Sub
    End If

    x = Col * 50 - 19
    y = Row * 50 - 19
    HideMOUSE
    Get (x, y)-(x + 46, y + 46), LilBOX()
    Line (x, y)-(x + 46, y + 46), 4, B
    Line (x + 1, y + 1)-(x + 45, y + 45), 4, B
    ShowMOUSE
    SquareON = 1: Oldx = x: Oldy = y

End Sub

Function InitMOUSE

    LB = 0
    MouseDRIVER LB, 0, 0, 0
    InitMOUSE = LB

End Function

Sub LoadSCREEN

    'Loads screen and then loads chess pieces into Box array
    FileNUM = 0
    Def Seg = VarSeg(Box(1))
    For y = 0 To 320 Step 160
        FileNUM = FileNUM + 1
        FileNAME$ = "ChessBD" + LTrim$(Str$(FileNUM)) + ".BSV"
        BLoad FileNAME$, VarPtr(Box(1))
        Put (0, y), Box(), PSet
    Next y
    BLoad "chesspcs.bsv", VarPtr(Box(1))
    Def Seg

    'read starting values into map array
    Restore BoardDATA
    For Col = 1 To 8
        For Row = 1 To 8
            Read Board(Col, Row)
        Next Row
    Next Col

End Sub

Sub LocateMOUSE (x, y)

    LB = 4
    MX = x
    MY = y
    MouseDRIVER LB, 0, MX, MY

End Sub

Sub MouseDRIVER (LB, RB, MX, MY)

    Def Seg = VarSeg(MouseDATA$)
    mouse = SAdd(MouseDATA$)
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

Sub PutPIECE (Row1, Col1, Row2, Col2)

    If Board(Row1, Col1) <> 0 Then
        Select Case Board(Row1, Col1) Mod 10
            Case 1: Piece = Pawn
            Case 2: Piece = Rook
            Case 3: Piece = Knight
            Case 4: Piece = Bishop
            Case 5: Piece = Queen
            Case 6: Piece = King
        End Select

        If (Col1 + Row1 Mod 2) Mod 2 Then Cancel = EDark Else Cancel = ELight
        If (Col2 + Row2 Mod 2) Mod 2 Then Square = Dark Else Square = Light
        If Board(Row1, Col1) \ 10 = 0 Then Colr = Black Else Colr = White

        x = Col1 * 50 - 19
        y = Row1 * 50 - 19
        HideMOUSE
        Put (x, y), Box(Cancel), PSet
        ShowMOUSE

        Board(Row2, Col2) = Board(Row1, Col1)
        Board(Row1, Col1) = 0

        x = Col2 * 50 - 19
        y = Row2 * 50 - 19
        HideMOUSE
        Put (x, y), Box(Colr + Piece + Square), PSet
        ShowMOUSE
    Else
        HighLIGHT Row1, Col1, 0
    End If

End Sub

Sub SetPALETTE

    Restore PaletteDATA
    Out &H3C8, 0
    For n = 1 To 48
        Read Intensity
        Out &H3C9, Intensity
    Next n

End Sub

Sub ShowMOUSE
    LB = 1
    MouseDRIVER LB, 0, 0, 0
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

