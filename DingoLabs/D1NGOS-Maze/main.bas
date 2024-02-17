$Resize:Smooth
_Title "D1NGOS MAZE GAME"
Screen _NewImage(500, 520, 32)

img& = _LoadImage("currentTiles.png")
_PrintString (100, 0), "WELCOME TO D1NGOS MAZE GAME!!!"
Print
Print "*************************************************************"
Print " type 's' during the game to start over"
Print " "


start:
Input "do you want a random seed or to pick? (random / pick) ", answer$
If answer$ = "random" Then
    time = Timer / 4
    time = _Round(time)
    Randomize time
    Print "your seed number is ", time
    Sleep

ElseIf answer$ = "pick" Then
    Input "enter a seed number (0 - 32767) ", seed
    Randomize seed
    Print "generating maze based off seed number: ", seed
    Sleep
Else
    Print answer$; "not vaild choice"
    GoTo start
End If
Cls
'Print "seed number: "; seed; "random number: "; time
'Print "steps: "; steps


Dim array(200) As Integer
Dim coin(200) As Integer
Dim A As Integer
Dim C As Integer
A = 1
C = 1
For i = 0 To 520 Step 50
    For j = 20 To 520 Step 50
        x = Int(Rnd * 7)
        If x = 0 Then
            _PutImage (i, j), img&, , (0, 0)-(49, 49) 'up and down
            array(A) = 0
        End If
        If x = 1 Then
            _PutImage (i, j), img&, , (50, 50)-(99, 99) 'blank
            array(A) = 1
        End If
        If x = 2 Then
            _PutImage (i, j), img&, , (0, 50)-(49, 99) 'right to left
            array(A) = 2
        End If
        If x = 3 Then
            _PutImage (i, j), img&, , (50, 0)-(99, 49) ' cross
            array(A) = 3
        End If
        If x >= 4 Then
            _PutImage (i, j), img&, , (0, 100)-(49, 149) 'full
            array(A) = 4
        End If

        y = Int(Rnd * 3)

        If y = 0 And array(A) <> 1 Then
            _PutImage (i + 19, j + 18), img&, , (82, 120)-(93, 131) 'coin
            coin(C) = 0
        End If

        If y >= 1 Then
            coin(C) = 1
        End If
        A = A + 1
        C = C + 1
    Next
Next
_PutImage (0, 19), img&, , (0, 99)-(49, 149)
'_PutImage (450, 470), img&, , (0, 100)-(49, 149)



PlayerX = 19
PlayerY = 38
_PutImage (PlayerX, PlayerY), img&, , (70, 120)-(81, 131)

array(1) = 4
CPos = 1
NPos = 1
coinPos = 1
steps% = 0
Dim gold As Integer
gold = 0

Do
    top:
    keypress$ = UCase$(InKey$)
    If keypress$ = Chr$(0) + Chr$(77) Then 'move right
        PlayerX = PlayerX + 50
        If PlayerX > 500 Then
            PlayerX = PlayerX - 50
            GoTo top
        End If
        PlayerX = PlayerX - 50
        NPos = CPos + 11 'check position
        If array(CPos) = 0 Then GoTo top:
        If array(NPos) = 2 Or array(NPos) = 3 Or array(NPos) = 4 Then
            _PutImage (PlayerX, PlayerY), img&, , (20, 120)-(31, 131)
            PlayerX = PlayerX + 50
            _PutImage (PlayerX, PlayerY), img&, , (70, 120)-(81, 131)
            steps = steps + 1
            CPos = NPos
        End If
    ElseIf keypress$ = Chr$(0) + Chr$(80) Then 'move down
        PlayerY = PlayerY + 50
        If PlayerY > 520 Then
            PlayerY = PlayerY - 50
            GoTo top
        End If
        PlayerY = PlayerY - 50
        NPos = CPos + 1 'check position
        If array(CPos) = 2 Then GoTo top:
        If array(NPos) = 0 Or array(NPos) = 3 Or array(NPos) = 4 Then
            _PutImage (PlayerX, PlayerY), img&, , (20, 120)-(31, 131)
            PlayerY = PlayerY + 50
            If PlayerY > 520 Then GoTo top
            _PutImage (PlayerX, PlayerY), img&, , (70, 120)-(81, 131)
            steps = steps + 1
            CPos = NPos
        End If
    ElseIf keypress$ = Chr$(0) + Chr$(72) Then 'move up
        PlayerY = PlayerY - 50
        If PlayerY < 0 Then
            PlayerY = PlayerY + 50
            GoTo top
        End If
        PlayerY = PlayerY + 50
        NPos = CPos - 1 'check positions
        If array(CPos) = 2 Then GoTo top:
        If array(NPos) = 0 Or array(NPos) = 3 Or array(NPos) = 4 Then
            _PutImage (PlayerX, PlayerY), img&, , (20, 120)-(31, 131)
            PlayerY = PlayerY - 50
            _PutImage (PlayerX, PlayerY), img&, , (70, 120)-(81, 131)
            steps = steps + 1
            CPos = NPos
        End If
    ElseIf keypress$ = Chr$(0) + Chr$(75) Then 'move left
        PlayerX = PlayerX - 50
        If PlayerX < 0 Then
            PlayerX = PlayerX + 50
            GoTo top
        End If
        PlayerX = PlayerX + 50
        NPos = CPos - 11 'check position
        If array(CPos) = 0 Then GoTo top:
        If array(NPos) = 2 Or array(NPos) = 3 Or array(NPos) = 4 Then
            _PutImage (PlayerX, PlayerY), img&, , (20, 120)-(31, 131)
            PlayerX = PlayerX - 50
            _PutImage (PlayerX, PlayerY), img&, , (70, 120)-(81, 131)
            steps = steps + 1
            CPos = NPos
        End If
    End If
    coinPos = CPos
    If coin(coinPos) = 0 Then
        gold = gold + 1
        coin(coinPos) = 1
    End If
    If keypress$ = "S" Then
        Cls
        GoTo start
    End If
    If keypress$ = "Q" Then
        System
    End If

    _PrintString (0, 0), "steps: "
    _PrintString (60, 0), Str$(CPos)
    _PrintString (100, 0), "gold: "
    _PrintString (160, 0), Str$(gold)
Loop

