Option _Explicit
' _Title "GUI Tic Tac Toe with AI"  ' b+ 2022-07-12 try GUI version with fixed AI and a Btn Array!
'      Needs fixing   https://www.youtube.com/watch?v=5n2aQ3UQu9Y
' you start at corner
' they AI play middle to at least tie
' you play opposite corner
' they or AI plays corner will loose!!! I am saying in AI always play corner is not always right!!!
' they have to play side to just tie
'
' 2022-07-12 finally got around to fixing this program
' 2022-07-12 Now try it out with vsGUI, can I use an array of control handles? Yes.

'$include:'vs GUI.BI'

'   Set Globals from BI              your Title here VVV
Xmax = 502: Ymax = 502: GuiTitle$ = "GUI Tic-Tac-Toe with AI"
OpenWindow Xmax, Ymax, GuiTitle$, "ARLRDBD.TTF"

Dim Shared As Long Btn(0 To 8) ' our 9 buttons for the game
Dim As Long x, y, i
For y = 0 To 2 '        yes in, vs GUI, we Can have arrays of controls!!!
    For x = 0 To 2
        Btn(i) = NewControl(1, x * 175 + 1, y * 175 + 1, 150, 150, 120, 600, 668, "")
        i = i + 1
    Next
Next ' that's all for the GUI

' one time sets
Dim Shared Player$, AI$, Turn$, Winner$
Dim Shared As Long PlayerStarts, Count, Done
Dim Shared board$(2, 2) 'store X and O here 3x3
Player$ = "X": AI$ = "O": PlayerStarts = 0

ResetGame
MainRouter

Sub ResetGame
    Dim As Long i, rc, bx, by
    Winner$ = "": Count = 0: Done = 0: Erase board$ 'reset
    For i = 0 To 8
        con(Btn(i)).Text = ""
        drwBtn i + 1, 0
    Next
    PlayerStarts = 1 - PlayerStarts
    If PlayerStarts Then Turn$ = Player$ Else Turn$ = AI$
    If Turn$ = AI$ Then
        rc = AIchoice
        con(rc + 1).Text = AI$
        bx = rc Mod 3: by = Int(rc / 3)
        board$(bx, by) = AI$
        _Delay 3 'let player think AI is thinking
        drwBtn rc + 1, 0
        Count = Count + 1
        'If checkwin Then Winner$ = AI$
        Turn$ = Player$
        mBox "The AI has started the next game.", "It's your turn."
        'now wait for MainRouter to detect a Button click
    End If
End Sub

Function checkwin
    Dim As Long i
    For i = 0 To 2
        If (board$(0, i) = board$(1, i) And board$(1, i) = board$(2, i)) And (board$(2, i) <> "") Then checkwin = 1: Exit Function
    Next
    For i = 0 To 2
        If (board$(i, 0) = board$(i, 1) And board$(i, 1) = board$(i, 2)) And board$(i, 2) <> "" Then checkwin = 1: Exit Function
    Next
    If (board$(0, 0) = board$(1, 1) And board$(1, 1) = board$(2, 2)) And board$(2, 2) <> "" Then checkwin = 1: Exit Function
    If (board$(0, 2) = board$(1, 1) And board$(1, 1) = board$(2, 0)) And board$(2, 0) <> "" Then checkwin = 1
End Function

Function AIchoice
    Dim As Long r, c
    'test all moves to win
    For r = 0 To 2
        For c = 0 To 2
            If board$(c, r) = "" Then
                board$(c, r) = AI$
                If checkwin Then
                    board$(c, r) = ""
                    AIchoice = 3 * r + c
                    Exit Function
                Else
                    board$(c, r) = ""
                End If
            End If
        Next
    Next

    'still here? then no winning moves for AI, how about for player$
    For r = 0 To 2
        For c = 0 To 2
            If board$(c, r) = "" Then
                board$(c, r) = Player$
                If checkwin Then
                    board$(c, r) = ""
                    AIchoice = 3 * r + c 'spoiler move!
                    Exit Function
                Else
                    board$(c, r) = ""
                End If
            End If
        Next
    Next

    'still here? no winning moves, no spoilers then is middle sq available
    If board$(1, 1) = "" Then AIchoice = 4: Exit Function

    ' one time you dont want a corner when 3 moves made human has opposite corners, then defense is any side!
    If (board$(0, 0) = Player$ And board$(2, 2) = Player$) Or (board$(2, 0) = Player$ And board$(0, 2) = Player$) Then
        ' try a side order?
        If board$(1, 0) = "" Then AIchoice = 1: Exit Function
        If board$(0, 1) = "" Then AIchoice = 3: Exit Function
        If board$(2, 1) = "" Then AIchoice = 5: Exit Function
        If board$(1, 2) = "" Then AIchoice = 7: Exit Function

        'still here still? how about a corner office?
        If board$(0, 0) = "" Then AIchoice = 0: Exit Function
        If board$(2, 0) = "" Then AIchoice = 2: Exit Function
        If board$(0, 2) = "" Then AIchoice = 6: Exit Function
        If board$(2, 2) = "" Then AIchoice = 8: Exit Function
    Else
        'still here still? how about a corner office?
        If board$(0, 0) = "" Then AIchoice = 0: Exit Function
        If board$(2, 0) = "" Then AIchoice = 2: Exit Function
        If board$(0, 2) = "" Then AIchoice = 6: Exit Function
        If board$(2, 2) = "" Then AIchoice = 8: Exit Function

        'still here??? a side order then!
        If board$(1, 0) = "" Then AIchoice = 1: Exit Function
        If board$(0, 1) = "" Then AIchoice = 3: Exit Function
        If board$(2, 1) = "" Then AIchoice = 5: Exit Function
        If board$(1, 2) = "" Then AIchoice = 7: Exit Function
    End If
End Function

Sub BtnClickEvent (i As Long) ' Basically the game is played here with player's button clicks
    Dim As Long rc, bx, by
    ' note Btn(0) = 1, Btn(1) = 2...
    rc = i - 1 ' from control number to button number
    bx = rc Mod 3: by = Int(rc / 3) ' from button number to board$ x, y location
    If board$(bx, by) = "" Then ' update board, check win, call AI for it's turn, update board, check win
        con(i).Text = Player$
        drwBtn i, 0
        board$(bx, by) = Player$
        If checkwin Then
            mBox "And the Winner is", "You! Congratulations AI was supposed to be unbeatable."
            ResetGame
        Else
            Count = Count + 1
            If Count >= 9 Then
                mBox "Out of Spaces:", "The Game is a draw."
                ResetGame
            Else ' run the ai
                rc = AIchoice
                con(rc + 1).Text = AI$
                bx = rc Mod 3: by = Int(rc / 3)
                board$(bx, by) = AI$
                _Delay 1 'let player think AI is thinking
                drwBtn rc + 1, 0
                If checkwin Then
                    mBox "And the Winner is", "AI, the AI is supposed to be unbeatable."
                    ResetGame
                Else
                    Count = Count + 1
                    If Count >= 9 Then
                        mBox "Out of Spaces:", "The Game is a draw."
                        ResetGame
                    Else
                        Turn$ = Player$
                    End If
                End If
            End If
        End If
    Else
        Beep: mBox "Player Error:", "That button has already been played."
    End If
End Sub

' this is to keep MainRouter in, vs GUI.BM, happy =========================================
Sub LstSelectEvent (control As Long)
    Select Case control
    End Select
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    Select Case i
    End Select
End Sub

Sub PicFrameUpdate (i As Long)
    Select Case i
    End Select
End Sub

'$include:'vs GUI.BM'
