'******************************************************************************
'*                                                                            *
'*                    FOUR IN A ROW by Terry Ritchie                          *
'*                                                                            *
'* Created from base code developed by Philip Perry                           *
'*                                                                            *
'* Created for February 2012 gaming contest on QB64.NET                       *
'*                                                                            *
'* This program code can be used freely as you wish. If you have a question   *
'* or comment you can email me directly at terry.ritchie@gmail.com            *
'*                                                                            *
'* The contest stated that a currently written game for Qbasic is to be       *
'* updated using QB64. I chose the game Four in a row by Philip Perry that    *
'* was found at http://www.petesqbsite.com/reviews/misc/four.html             *
'* I tracked down Mr. Perry on the Internet and obtained permission to use    *
'* his code as a basis for this contest entry. The email address contained in *
'* his original code is no longer valid. If you wish to contact Mr. Perry his *
'* current email address is wireless_phil@yahoo.de                            *
'*                                                                            *
'* Written using QB64 version 0.952 found at http://www.qb64.net              *
'*                                                                            *
'* Updated and fixed by a740g to work with QB64-PE found at:                  *
'* https://github.com/QB64-Phoenix-Edition/QB64pe/releases                    *
'*                                                                            *
'******************************************************************************

$Unstable:Midi
$MidiSoundFont:Default
Option _Explicit

'******************************************************************************
'* The game utilizes my sprite library                                        *
'*                                                                            *
'$INCLUDE:'spritetop.bi'
'*                                                                            *
'******************************************************************************

Const FALSE = 0, TRUE = Not FALSE
Const BLACK = 0, RED = 1, EMPTY = 2 '                                          player and checkers on board flags
Const HUMAN = -1 '                                                             tells checker drop routine human is dropping checker
Const FULL = -32767 '                                                          used to indicate a full column of checkers
Const MAX = 1000000 '                                                          maximum score for min/max recursive routine

Type CELL '                                                                    used to keep track of graphics characteristics of board
    x As Integer '                                                             x location of graphics cell
    y As Integer '                                                             y location of graphics cell
    c As Integer '                                                             color of checker in cell (0 = black, 1 = red, 2 = none)
    f As Integer '                                                             which side of checker is facing (0 = front, 1 = back)
End Type

ReDim BoardStack%(0, 6, 5) '                                                   game board stack holding past board states
Dim CheckerSheet% '                                                            sprite sheet containing checker images
Dim MenuSheet% '                                                               sprite sheet containing menu options
Dim Menu%(4, 1) '                                                              handles holding menu option graphics
Dim MenuY%(4) '                                                                menu graphic vertical locations
Dim Cell(6, 5) As CELL '                                                       graphics setup of game board
Dim WinCells%(3, 1) '                                                          location of four checkers in a row on board
Dim LastRow% '                                                                 remembers last row checker dropped into
Dim LastColumn% '                                                              remembers last column checker dropped into
Dim CheckersDropped% '                                                         number of checkers dropped in game
Dim ColumnVal&(6) '                                                            column scores
Dim Winner%(3) '                                                               sprites containing banner messages
Dim WinSpin%(1, 3) '                                                           sprites containing winning spinning checkers
Dim SoundOption% '                                                             determines if sound turned on/off
Dim MusicOption% '                                                             determines if music turned on/off
Dim MenuMusic& '                                                               handle containing menu music
Dim Win&(1) '                                                                  handles containing winning applause sounds
Dim Lose& '                                                                    handle containing losing sound
Dim Board%(6, 5) '                                                             the current board state
Dim Options%(4, 5) '                                                           sprites containing the options menu
Dim Depth% '                                                                   the depth of look ahead recursive min/max on
Dim Checker%(2, 1) '                                                           handles holding static checker images
Dim SpinChecker%(1) '                                                          handles holding black and red spinning checker images
Dim MarqueeChecker%(1) '                                                       handles holding small checkers for marquee
Dim board& '                                                                   handle holding image of game board
Dim CellImage% '                                                               handle holding sprite image of single cell on board
Dim CellBlank% '                                                               handle holding sprite image of blue background box
Dim Click& '                                                                   handle holding click sound of checker hitting chekcer
Dim Drop& '                                                                    handle holding drop sound of first checker being dropped
Dim Slide& '                                                                   handle holding sliding sound of checker dropping
Dim TitleMusic& '                                                              handle holding title music used in intro sequence
Dim GameMusic& '                                                               handle holding game music
Dim TitleMode% '                                                               flag telling other routines when title sequence running
Dim MenuImage& '                                                               handle holding image of menu screen
Dim MenuOption% '                                                              the menu option selected
Dim GameOver% '                                                                flag to set when game is over
Dim GameLevel% '                                                               level of game play chosen by player

'******************************************************************************
'*                                                                            *
'* Main program loop                                                          *
'*                                                                            *
'******************************************************************************

CreateAssets '                                                                 Create the games graphics and sounds
InitializeVariables '                                                          set variables to initial state
TitleSequence '                                                                display the title sequence
Do
    If MusicOption% And Not _SndPlaying(MenuMusic&) Then _SndLoop MenuMusic&
    MenuOption% = MainMenu% '                                                  get the menu option player selects
    If MenuOption% = 4 Then System '                                           player has chosen to quit
    If MenuOption% = 3 Then SetOptions '                                       player has chosen to change/display options
    If MenuOption% < 3 Then '                                                  player has chosen to play a game
        If MusicOption% Then _SndStop MenuMusic&
        NewGame '                                                              set game variables to initial state
        DrawBoard '                                                            draw the game board
        If MusicOption% Then _SndLoop GameMusic&
        If MenuOption% = 2 Then '                                              player chose 2 player game
            Do
                MoveChecker BLACK, HUMAN '                                     allow player 1 to make move
                CheckersDropped% = CheckersDropped% + 1 '                      increment dropped checker counter
                StackInit '                                                    save the state of board in stack
                If CheckFour% = BLACK Then GameOver% = TRUE '                  if player got 4 in row then game over
                If Not GameOver% Then '                                        is the game over?
                    MoveChecker RED, HUMAN '                                   no, allow player 2 to make move
                    CheckersDropped% = CheckersDropped% + 1 '                  increment dropped checker counter
                    StackInit '                                                save the state of board in stack
                    If CheckFour% = RED Then GameOver% = TRUE '                if player got 4 in row then game over
                End If
            Loop Until GameOver% Or CheckersDropped% = 42 '                    keep playing until win/lose/draw
        Else '                                                                 player chose 1 player game
            Do
                MoveChecker BLACK, HUMAN '                                     allow player 1 to make move
                CheckersDropped% = CheckersDropped% + 1 '                      increment dropped checker counter
                StackInit '                                                    save the state of board in stack
                If CheckFour% = BLACK Then GameOver% = TRUE '                  if player got 4 in row then game over
                If Not GameOver% Then MoveChecker RED, BestMove% '             if game not over allow computer to make move
                CheckersDropped% = CheckersDropped% + 1 '                      increment dropped checker counter
            Loop Until GameOver% Or CheckersDropped% = 42 '                    keep playing until win/lose/draw
        End If
        If MusicOption% Then _SndStop GameMusic& '                             stop game music if necessary
    End If
    If GameOver% Or CheckersDropped% = 42 Then '                               game over?
        ShowWinner '                                                           show the winner or draw
        GameOver% = FALSE '                                                    yes, reset game over flag
    End If
Loop

'******************************************************************************

Sub PushState ()
    '******************************************************************************
    '*                                                                            *
    '* Pushes the state of the playing board onto the LIFO stack                  *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     row counter
    Dim Column% '                                                                  column counter

    Shared Board%()
    Shared BoardStack%()
    Shared Depth%

    Depth% = UBound(BoardStack%) + 1 '                                             get new upper stack limit
    ReDim _Preserve BoardStack%(Depth%, 6, 5) '                                    increase stack array
    For Column% = 0 To 6 '                                                         cycle through all columns
        For Row% = 0 To 5 '                                                        cycle through all rows
            BoardStack%(Depth%, Column%, Row%) = Board%(Column%, Row%) '           copy current board state to stack array
        Next Row%
    Next Column%

    '******************************************************************************
End Sub

Sub PopState ()
    '******************************************************************************
    '*                                                                            *
    '* Pops the previous state of the playing board from the LIFO stack           *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     row counter
    Dim Column% '                                                                  column counter

    Shared Board%()
    Shared BoardStack%()
    Shared Depth%

    For Column% = 0 To 6 '                                                         cycle through all columns
        For Row% = 0 To 5 '                                                        cycle through all rows
            Board%(Column%, Row%) = BoardStack%(Depth%, Column%, Row%) '           get previous board state from stack array
        Next Row%
    Next Column%
    Depth% = UBound(BoardStack%) - 1 '                                             get new upper stack limit
    ReDim _Preserve BoardStack%(Depth%, 6, 5) '                                    decrease stack array

    '******************************************************************************
End Sub

Sub StackInit ()
    '******************************************************************************
    '*                                                                            *
    '* Initializes the stack with current playing board information               *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     row counter
    Dim Column% '                                                                  column counter

    Shared Board%()
    Shared Cell() As CELL
    Shared Depth%
    Shared BoardStack%()

    ReDim BoardStack%(0, 6, 5) '                                                   clear stack

    Depth% = 0 '                                                                   keep track of how deep stack is
    For Column% = 0 To 6 '                                                         cycle through all columns
        For Row% = 0 To 5 '                                                        cycle through all rows
            Board%(Column%, Row%) = Cell(Column%, Row%).c '                        get current playing board state
        Next Row%
    Next Column%

    '******************************************************************************
End Sub

Function BoardDrop% (Player%, DropColumn%)
    '******************************************************************************
    '*                                                                            *
    '* Drops a checker into current board and returns the row number checker was  *
    '* dropped into or -1 if the column is full.                                  *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     row counter

    Shared Board%()

    Row% = 0 '                                                                     start at bottom row
    If Board%(DropColumn%, 5) <> EMPTY Then '                                      is the top row empty?
        BoardDrop% = -1 '                                                          no, set function to return column is full
        Exit Function '                                                            leave function
    Else '                                                                         yes, the top row is empty
        Do While Board%(DropColumn%, Row%) <> EMPTY '                              is this board position empty?
            Row% = Row% + 1 '                                                      no, go to next row
        Loop
        Board%(DropColumn%, Row%) = Player% '                                      put the player's checker here
    End If
    BoardDrop% = Row% '                                                            set function to return the row checker dropped into

    '******************************************************************************
End Function

Sub NewGame ()
    '******************************************************************************
    '*                                                                            *
    '* Set conditions for a new game                                              *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     current cell row
    Dim Column% '                                                                  current cell column

    Shared Cell() As CELL
    Shared GameOver%
    Shared CheckersDropped%

    GameOver% = FALSE '                                                            reset game over flag
    CheckersDropped% = 0 '                                                         no checkers dropped yet
    For Column% = 0 To 6 '                                                         cycle through all cell columns
        For Row% = 0 To 5 '                                                        cycle through all cell rows
            Cell(Column%, Row%).c = EMPTY '                                        set spot on board to empty
        Next Row%
    Next Column%

    '******************************************************************************
End Sub

Sub SetOptions ()
    '******************************************************************************
    '*                                                                            *
    '* Set the game options                                                       *
    '*                                                                            *
    '******************************************************************************

    Dim Selection% '                                                               current menu selection
    Dim Mcount% '                                                                  marquee counter
    Dim ClearBuffer$ '                                                             clear keyboard input
    Dim KeyPress$ '                                                                key user pressed
    Dim SelectionMade% '                                                           true when finished with options

    Shared Options%()
    Shared GameLevel%
    Shared MenuY%()
    Shared SoundOption%
    Shared MusicOption%
    Shared SpinChecker%()
    Shared MenuMusic&

    Selection% = 1 '                                                               start with first menu entry
    SelectionMade% = FALSE '                                                       stay in loop until options set
    SPRITESTAMP 349, MenuY%(1), Options%(1, 0) '                                   show 'Difficulty'
    SPRITESTAMP 349, MenuY%(2), Options%(2, GameLevel%) '                          show '1 2 3 4 5'
    SPRITESTAMP 349, MenuY%(3), Options%(3, Abs(SoundOption%)) '                   show 'Sound On Off'
    SPRITESTAMP 349, MenuY%(4), Options%(4, Abs(MusicOption%)) '                   show 'Music On Off'
    Do
        _Limit 36 '                                                                limit loop to 36 frames per second
        If Selection% = 1 Then '                                                   currently on difficulty?
            SPRITESTAMP 349, MenuY%(1), Options%(1, 1) '                           yes, show highlighted
        Else '                                                                     no
            SPRITESTAMP 349, MenuY%(1), Options%(1, 0) '                           show unhighlighted
        End If
        SPRITESTAMP 349, MenuY%(2), Options%(2, GameLevel%) '                      show which level currently chosen
        If Selection% = 2 Then '                                                   currently on sound?
            SPRITESTAMP 349, MenuY%(3), Options%(3, Abs(SoundOption%) + 2) '       yes, show correct highlighted version
        Else '                                                                     no
            SPRITESTAMP 349, MenuY%(3), Options%(3, Abs(SoundOption%)) '           show correct unhighlighted version
        End If
        If Selection% = 3 Then '                                                   currently on music?
            SPRITESTAMP 349, MenuY%(4), Options%(4, Abs(MusicOption%) + 2) '       yes, show correct highlighted version
        Else '                                                                     no
            SPRITESTAMP 349, MenuY%(4), Options%(4, Abs(MusicOption%)) '           show correct unhighlighted version
        End If
        SPRITEPUT 62, MenuY%(1), SpinChecker%(1) '                                 place red spinning checker on screen
        SPRITEPUT 636, MenuY%(1), SpinChecker%(0) '                                place black spinning checker on screen
        Mcount% = Mcount% + 1 '                                                    increment the marquee counter
        If Mcount% = 9 Then '                                                      time to update the marquee (4 times per second)
            Mcount% = 1 '                                                          yes, reset the marquee counter
            Marquee '                                                              update the marquee
        End If
        _Display '                                                                 show all graphic updates on screen
        Do
            ClearBuffer$ = InKey$ '                                                get key in buffer
            If ClearBuffer$ <> "" Then KeyPress$ = UCase$(ClearBuffer$) '          save the last key pressed
        Loop Until ClearBuffer$ = "" '                                             keep looping until the buffer cleared
        If Len(KeyPress$) > 1 Then KeyPress$ = Right$(KeyPress$, 1) '              strip control character from player input
        Select Case KeyPress$ '                                                    which key was pressed?
            Case Chr$(72) '                                                        up arrow key has been pressed
                Selection% = Selection% - 1 '                                      decrement the menu selection
                If Selection% < 1 Then Selection% = 1 '                            if too low set to minimum
            Case Chr$(80) '                                                        down arrow key has been pressed
                Selection% = Selection% + 1 '                                      increment the menu selection
                If Selection% > 3 Then Selection% = 3 '                            if too high set to maximum
            Case Chr$(77) '                                                        right arrow key has been pressed
                If Selection% = 1 Then '                                           currently on difficulty?
                    GameLevel% = GameLevel% + 1 '                                  yes, increment game play level
                    If GameLevel% = 6 Then GameLevel% = 5 '                        if too high set to max
                ElseIf Selection% = 2 Then '                                       currently on sound?
                    SoundOption% = Not SoundOption% '                              yes, invert sound option
                ElseIf Selection% = 3 Then '                                       currently on music?
                    MusicOption% = Not MusicOption% '                              yes, invert music option
                End If
            Case Chr$(75) '                                                        left arrow key has been pressed
                If Selection% = 1 Then '                                           currently on difficulty?
                    GameLevel% = GameLevel% - 1 '                                  yes, decrement game play level
                    If GameLevel% = 0 Then GameLevel% = 1 '                        if too low set to minimum
                ElseIf Selection% = 2 Then '                                       currently on sound?
                    SoundOption% = Not SoundOption% '                              yes, invert sound option
                ElseIf Selection% = 3 Then '                                       currently on music?
                    MusicOption% = Not MusicOption% '                              yes, invert music option
                End If
            Case Chr$(13), Chr$(27) '                                              enter or ESC key has been pressed
                SelectionMade% = TRUE '                                            set selection made flag to true
        End Select
        KeyPress$ = "" '                                                           reset keyboard input string
    Loop Until SelectionMade% '                                                    keep looping until options set
    If _SndPlaying(MenuMusic&) And Not MusicOption% Then _SndStop MenuMusic&
    If Not _SndPlaying(MenuMusic&) And MusicOption% Then _SndLoop MenuMusic&
    Open "options.4ir" For Output As #1 '                                          open options file
    Print #1, GameLevel% '                                                         save game level
    Print #1, SoundOption% '                                                       save sound option
    Print #1, MusicOption% '                                                       save music option
    Close #1 '                                                                     close options file

    '******************************************************************************
End Sub

Function BestMove% ()
    '******************************************************************************
    '*                                                                            *
    '* Computer will pick best move                                               *
    '*                                                                            *
    '******************************************************************************

    Dim Column% '                                                                  column counter
    Dim Row% '                                                                     row checker dropped in
    Dim BestColumn% '                                                              column with best score
    Dim BestWorst& '                                                               comparison from one check to next
    Dim Goodness& '                                                                the score a checker drop ultimately receives
    Dim CurrentRow$ '                                                              string to hold string representation of a row
    Dim RowBelow$ '                                                                string to hold string representation of the row below
    Dim Look%

    Shared Cell() As CELL
    Shared Board%()
    Shared GameOver%
    Shared CheckersDropped%
    Shared ColumnVal&()
    Shared GameLevel%

    BestColumn% = -1 '                                                             initialize column with best score
    BestWorst& = -MAX '                                                            start out with lowest possible score

    '** --------------------------------------------------------------
    '** Place a computer checker in each column and see if it's a win.
    '** If not evaluate the drop and return a score.
    '** --------------------------------------------------------------

    StackInit '                                                                    initialize the stack to equal what board looks like
    If Board%(3, 0) = EMPTY Then '                                                 is center bottom position free?
        BestMove% = 3 '                                                            yes, take it
        Exit Function '                                                            leave function
    End If
    For Column% = 0 To 6 '                                                         cycle through all 7 columns
        StackInit '                                                                initialize the stack to equal what board looks like
        Row% = BoardDrop%(RED, Column%) '                                          simulate a dropped checker
        If Row% > -1 Then '                                                        was the column full?
            If CheckFour% = RED Then '                                             no, did computer get four in a row?
                BestMove% = Column% '                                              yes, return the winning column
                GameOver% = TRUE '                                                 game will be over after the move
                Exit Function '                                                    leave function with winning move
            End If
        End If
    Next Column%
    For Column% = 0 To 6
        StackInit '                                                                initialize the stack to equal what board looks like
        Row% = BoardDrop%(BLACK, Column%) '                                        simulate a dropped checker
        If Row% > -1 Then '                                                        was the column full?
            If CheckFour% = BLACK Then '                                           no, did human get four in a row?
                BestMove% = Column% '                                              yes, return the column to block
                Exit Function '                                                    leave function with blocking move
            End If
        End If
    Next Column%

    '*** ------------------------------------------------------------------------------------------
    '*** check to see if human is setting up for 3 checkers in a row and blank space on either side
    '*** ------------------------------------------------------------------------------------------

    StackInit '                                                                    initialize the stack to equal what board looks like
    For Row% = 0 To 5 '                                                            cycle through all rows
        CurrentRow$ = "" '                                                         clear current row string
        If Row% > 0 Then '                                                         currently on row 0?
            RowBelow$ = "" '                                                       no, reset row below string
        Else '                                                                     yes, currently on row 0
            RowBelow$ = "0000000" '                                                create a dummy row below for now
        End If
        For Column% = 0 To 6 '                                                     cycle through all columns
            CurrentRow$ = CurrentRow$ + LTrim$(Str$(Board%(Column%, Row%))) '      create string representation of current row
            If Row% > 0 Then RowBelow$ = RowBelow$ + LTrim$(Str$(Board%(Column%, Row% - 1))) ' create string representation of row below
        Next Column%
        Look% = InStr(CurrentRow$, "22002") '                                      look for 2 black checkers set up for win
        If Look% > 0 Then '                                                        does the row contain 2 black checkers set up for win?
            If Mid$(RowBelow$, Look%, 1) <> "2" And Mid$(RowBelow$, Look% + 1, 1) <> "2" And Mid$(RowBelow$, Look% + 4, 1) <> "2" Then
                Randomize Timer '                                                  seed generator if previous statement said to block
                Select Case Int(Rnd(1) * 3) + 1 '                                  pick a random column to drop into
                    Case 1
                        BestMove% = Look% - 1
                        Exit Function
                    Case 2
                        BestMove% = Look%
                        Exit Function
                    Case 3
                        BestMove% = Look% + 3
                        Exit Function
                End Select
            End If
        End If
        Look% = InStr(CurrentRow$, "20022") '                                      look for 2 black checkers set up for win
        If Look% > 0 Then '                                                        does the row contain 2 black checkers set up for win?
            If Mid$(RowBelow$, Look%, 1) <> "2" And Mid$(RowBelow$, Look% + 3, 1) <> "2" And Mid$(RowBelow$, Look% + 4, 1) <> "2" Then
                Randomize Timer '                                                  seed generator if previous statement said to block
                Select Case Int(Rnd(1) * 3) + 1 '                                  pick a random column to drop into
                    Case 1
                        BestMove% = Look% - 1
                        Exit Function
                    Case 2
                        BestMove% = Look% + 2
                        Exit Function
                    Case 3
                        BestMove% = Look% + 3
                        Exit Function
                End Select
            End If
        End If
    Next Row%
    _Title "Thinking ..." '                                                        let player know computer is thinking
    For Column% = 0 To 6 '                                                         cycle through all columns
        StackInit '                                                                initialize the state of the stack
        ColumnVal&(Column%) = 0 '                                                  set the column score to 0
        Row% = BoardDrop%(RED, Column%) '                                          drop a red checker into current column
        CheckersDropped% = CheckersDropped% + 1 '                                  keep track of how many checkers dropped
        If Row% > -1 Then '                                                        was the drop successful?
            PushState '                                                            yes, save state of board
            Row% = BoardDrop%(BLACK, Column%) '                                    drop a black checker in same column
            If Row% > -1 Then '                                                    was the column full?
                If CheckFour% = BLACK Then '                                       no, did the human get four in a row?
                    Goodness& = -MAX '                                             yes, avoid this column!
                Else '                                                             the column was full
                    PopState '                                                     restore the state of the board
                    Evaluate RED, GameLevel% * 2 '                                 simulate game being played
                    Goodness& = ColumnVal&(Column%) '                              get this column's score
                End If
            End If
            If Goodness& > BestWorst& Then '                                       is score the best seen?
                BestWorst& = Goodness& '                                           yes, remember this score
                BestColumn% = Column% '                                            this column is best so far
            ElseIf Goodness& = BestWorst& Then '                                   does this column equal another for best?
                Randomize Timer '                                                  seed random number generator
                If (Int(Rnd(1) * 10) + 1) > 5 Then BestColumn% = Column% '         select between the two randomly
            End If
        End If
        CheckersDropped% = CheckersDropped% - 1 '                                  decrement the dropped checkers counter
    Next Column%
    _Title "Game in progress!"
    BestMove% = BestColumn% '                                                      return the best column to drop checker in

    '******************************************************************************
End Function

Sub Evaluate (Player%, Level%)
    '******************************************************************************
    '*                                                                            *
    '* Recursively evaluate various checker drops                                 *
    '* Warning!: hair pulling zone ahead!                                         *
    '*                                                                            *
    '******************************************************************************

    Dim Column% '                                                                  column counter
    Dim Row% '                                                                     row checker dropped in (not used for any evaluation)

    Shared Depth%
    Shared Board%()
    Shared CheckersDropped%
    Shared ColumnVal&()

    If Level% = Depth% - 1 Then '                                                  have we reached the depth of forward looking checks?
        Exit Sub '                                                                 leave function
    ElseIf CheckersDropped% = 42 Then
        Exit Sub
    Else '                                                                         move onto next simulated checker drop
        For Column% = 0 To 6 '                                                     cycle through all 7 columns
            If Board%(Column%, 5) = EMPTY Then '                                   is this column full?
                PushState '                                                        no, save the state of the current board
                Row% = BoardDrop%(1 - Player%, Column%) '                          drop other player's checker into this column
                CheckersDropped% = CheckersDropped% + 1 '                          increment checker drop counter
                If Player% = RED Then
                    ColumnVal&(Column%) = ColumnVal&(Column%) - GoodnessOf&(1 - Player%, Column%, Row%)
                Else
                    ColumnVal&(Column%) = ColumnVal&(Column%) + GoodnessOf&(1 - Player%, Column%, Row%)
                End If
                Evaluate 1 - Player%, Level% '                                     evaluate other player's checker drop
                CheckersDropped% = CheckersDropped% - 1 '                          decrememnt checker drop counter
                PopState '                                                         restore the previous state of the board
            End If
        Next Column%
    End If

    '******************************************************************************
End Sub

Function GoodnessOf& (Player%, Pcolumn%, Prow%)
    '******************************************************************************
    '*                                                                            *
    '* Examines the current state of the board for a given player and returns a   *
    '* score based on that examination.                                           *
    '*                                                                            *
    '* This is needs work.                                                        *
    '*                                                                            *
    '******************************************************************************

    Dim Score& '                                                                   the score this checker receives
    Dim Count% '                                                                   generic counter
    Dim Count2% '                                                                  another generic counter
    Dim Inarow% '                                                                  how many in a row is made by this checker
    Dim Importance% '                                                              the imprtance of this move based on look-ahead depth
    Dim StartColumn% '                                                             starting column for diagonal checks
    Dim StartRow% '                                                                starting row for diagnoal checks
    Dim NextRow% '                                                                 row counter used in diagonal checks
    Dim Greatest% '                                                                used to save greatest n in a row seen
    Dim Least% '                                                                   used to determine where to start diagnoal checks

    Shared Board%()
    Shared GameLevel%
    Shared Depth%

    Importance% = GameLevel% * 2 - Depth% '                                        calculate the importance of this checker
    Score& = 0 '                                                                   reset score value

    If Prow% > 0 Then '                                                            is this checker sitting on another?

        '*** --------------------------------------
        '*** check player connecting vertical score
        '*** --------------------------------------

        Inarow% = 1 '                                                              yes, current checker counts for 1
        For Count% = Prow% - 1 To 0 Step -1 '                                      cycle from the row below to bottom of board
            If Board%(Pcolumn%, Count%) = Player% Then '                           does this checker match the player's checker?
                Inarow% = Inarow% + 1 '                                            yes, increment the in a row counter
            Else '                                                                 no, this is the other player's checker
                Exit For '                                                         no need to check further
            End If
        Next Count%
        Score& = Score& + Inarow% * Importance% '                                  add to score based on how many in a row seen

        '*** ------------------------------------
        '*** check player blocking vertical score
        '*** ------------------------------------

        Inarow% = 1 '                                                              current checker counts for 1 (assume other player)
        For Count% = Prow% - 1 To 0 Step -1 '                                      cycle from the row below to bottom of board
            If Board%(Pcolumn%, Count%) = 1 - Player% Then '                       does this checker match the ohter player's checker?
                Inarow% = Inarow% + 1 '                                            yes, increment the in a row counter
            Else '                                                                 no, this is the player's checker
                Exit For '                                                         no need to check further
            End If
        Next Count%
        Score& = Score& + Inarow% * Importance% '                                  add to score based on how many in a row seen
    End If

    StartColumn% = Pcolumn% - 3 '                                                  leftmost column possible for this checker
    If StartColumn% < 0 Then StartColumn% = 0 '                                    make sure to stay at left side of board if breached

    '*** ----------------------------------------
    '*** check player connecting horizontal score
    '*** ----------------------------------------

    Greatest% = 0 '                                                                greatest n in a row seen so far
    For Count% = StartColumn% To Pcolumn% '                                        cycle from leftmost column to current column
        Inarow% = 0 '                                                              reset the in a row counter
        For Count2% = Count% To Count% + 3 '                                       cycle through next 4 columns
            If Count2% > 6 Then Exit For '                                         no need to check further if right side of board reached
            If Board%(Count2%, Prow%) = Player% Then '                             does this checker match the player's checker?
                Inarow% = Inarow% + 1 '                                            yes, increment the in a row counter
            Else '                                                                 no, this is the other player's checker or a blank spot
                Inarow% = 0 '                                                      reset the four in a row counter
            End If
        Next Count2%
        If Inarow% > Greatest% Then Greatest% = Inarow% '                          save the largest in a row seen so far
    Next Count%
    Score& = Score& + Greatest% * Importance% '                                    add to score based on how many in a row seen

    '*** --------------------------------------
    '*** check player blocking horizontal score
    '*** --------------------------------------

    Greatest% = 0 '                                                                greatest n in a row seen so far
    For Count% = StartColumn% To Pcolumn% '                                        cycle from leftmost column to current column
        Inarow% = 0 '                                                              reset the in a row counter
        For Count2% = Count% To Count% + 3 '                                       cycle through next 4 columns
            If Count2% > 6 Then Exit For '                                         no need to check further if right side of board reached
            If Count2% <> Pcolumn% Then '                                          is this the checker that was dropped?
                If Board%(Count2%, Prow%) = 1 - Player% Then '                     no, does this checker match the other player's checker
                    Inarow% = Inarow% + 1 '                                        yes, increment the in a row counter
                Else '                                                             no, this is the player's checker or a blank spot
                    Inarow% = 0 '                                                  reset the in a row counter
                End If
            Else '                                                                 yes, this is the checker that was dropped
                Inarow% = Inarow% + 1 '                                            treat it as the other player's checker for now
            End If
        Next Count2%
        If Inarow% > Greatest% Then Greatest% = Inarow% '                          save the largest in a row seen so far
    Next Count%
    Score& = Score& + Greatest% * Importance% '                                    add to score based on how many in a row seen

    If Pcolumn% <= Prow% Then '                                                    is the column number = or < the row number?
        Least% = Pcolumn% '                                                        yes, save this as the smallest number
    Else '                                                                         no, row number is < the column number
        Least% = Prow% '                                                           save this as the smallest number
    End If
    If Least% > 3 Then Least% = 3 '                                                only need to diagonally check back three places
    StartColumn% = Pcolumn% - Least% '                                             compute the starting column
    StartRow% = Prow% - Least% '                                                   compute the starting row

    If StartRow% < 3 And StartColumn% < 4 Then '                                   is four in a row / diagonally possible here?

        '*** ----------------------------------------
        '*** check player connecting / diagonal score
        '*** ----------------------------------------

        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        For Count% = StartColumn% To Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            For Count2% = Count% To Count% + 3 '                                   cycle through next 4 columns
                If (Count2% > 6) Or (NextRow% > 5) Then Exit For '                 no need to check further if top or right side of board hit
                If Board%(Count2%, NextRow%) = Player% Then '                      does this checker match the player's checker?
                    Inarow% = Inarow% + 1 '                                        yes, increment the in a row counter
                Else '                                                             no, this is the other player's checker or a blank spot
                    Inarow% = 0 '                                                  reset the in a row counter
                End If
                NextRow% = NextRow% + 1 '                                          increment the row counter
            Next Count2%
            StartRow% = StartRow% + 1 '                                            increment the starting row counter
            If Inarow% > Greatest% Then Greatest% = Inarow% '                      save the largest in a row seen so far
        Next Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen

        '*** --------------------------------------
        '*** check player blocking / diagonal score
        '*** --------------------------------------

        StartRow% = Prow% - Least% '                                               reset the starting row
        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        For Count% = StartColumn% To Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            For Count2% = Count% To Count% + 3 '                                   cycle through next 4 columns
                If (Count2% > 6) Or (NextRow% > 5) Then Exit For '                 no need to check further if top or right side of board hit
                If Count2% <> Pcolumn% And NextRow% <> Prow% Then '                is this the checker that was dropped?
                    If Board%(Count2%, NextRow%) = 1 - Player% Then '              no, does this checker match the other player's checker?
                        Inarow% = Inarow% + 1 '                                    yes, increment the in a row counter
                    Else '                                                         no, this is the player's checker or a blank spot
                        Inarow% = 0 '                                              reset the in a row counter
                    End If
                Else '                                                             yes, this is the checker that was dropped
                    Inarow% = Inarow% + 1 '                                        treat it as the other player's checker for now
                End If
                NextRow% = NextRow% + 1 '                                          increment the row counter
            Next Count2%
            StartRow% = StartRow% + 1 '                                            increment the starting row counter
            If Inarow% > Greatest% Then Greatest% = Inarow% '                      save the largest in a row seen so far
        Next Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen
    End If

    If Pcolumn% <= 5 - Prow% Then '                                                is the column number = or < the row number from the top?
        Least% = Pcolumn% '                                                        yes, save this as the smallest number
    Else '                                                                         no, row number from top is < the column number
        Least% = 5 - Prow% '                                                       save this as the smallest number
    End If
    If Least% > 3 Then Least% = 3 '                                                only need to diagonally check back three places
    StartColumn% = Pcolumn% - Least% '                                             compute the starting column
    StartRow% = Prow% + Least% '                                                   compute the starting row

    If StartRow% > 2 And StartColumn% < 4 Then '                                   is four in a row \ diagonally possible here?

        '*** ----------------------------------------
        '*** check player connecting \ diagonal score
        '*** ----------------------------------------

        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        For Count% = StartColumn% To Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            For Count2% = Count% To Count% + 3 '                                   cycle through next 4 columns
                If (Count2% > 6) Or (NextRow% < 0) Then Exit For '                 no need to check further if bottom or right side of board hit
                If Board%(Count2%, NextRow%) = Player% Then '                      does this checker match the player's checker?
                    Inarow% = Inarow% + 1 '                                        yes, increment the in a row counter
                Else '                                                             no, this is the other player's checker or a blank spot
                    Inarow% = 0 '                                                  reset the in a row counter
                End If
                NextRow% = NextRow% - 1 '                                          decrement the row counter
            Next Count2%
            StartRow% = StartRow% - 1 '                                            decrement the starting row counter
            If Inarow% > Greatest% Then Greatest% = Inarow% '                      save the largest in a row seen so far
        Next Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen

        '*** --------------------------------------
        '*** check player blocking \ diagonal score
        '*** --------------------------------------

        StartRow% = Prow% + Least% '                                               reset the starting row
        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        For Count% = StartColumn% To Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            For Count2% = Count% To Count% + 3 '                                   cycle through next 4 columns
                If (Count2% > 6) Or (NextRow% < 0) Then Exit For '                 no need to check further if bottom or right side of board hit
                If Count2% <> Pcolumn% And NextRow% <> Prow% Then '                is this the checker that was dropped?
                    If Board%(Count2%, NextRow%) = 1 - Player% Then '              no, does this checker match the other player's checker?
                        Inarow% = Inarow% + 1 '                                    yes, increment the in a row counter
                    Else '                                                         no, this is the player's checker or a blank spot
                        Inarow% = 0 '                                              reset the in a row counter
                    End If
                Else '                                                             yes, this is the checker that was dropped
                    Inarow% = Inarow% + 1 '                                        treat it as the other player's checker for now
                End If
                NextRow% = NextRow% - 1 '                                          decrement the row counter
            Next Count2%
            StartRow% = StartRow% - 1 '                                            decrement the starting row counter
            If Inarow% > Greatest% Then Greatest% = Inarow% '                      save the largest in a row seen so far
        Next Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen
    End If
    GoodnessOf& = Score& '                                                         return overall score

    '******************************************************************************
End Function

Function CheckFour% ()
    '******************************************************************************
    '*                                                                            *
    '* Checks for four checkers in a row on entire board and returns the player   *
    '* that achieved it or empty if no player has four in a row.                  *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     row counter
    Dim Column% '                                                                  column counter
    Dim FourCount% '                                                               four in a row counter
    Dim Count% '                                                                   counter used to test possible four in row spots
    Dim Player% '                                                                  the current player's checker being tested

    Shared WinCells%()
    Shared Board%()

    '** ------------------------------------------------------
    '** Check for 4 vertical checkers in a row on entire board
    '** ------------------------------------------------------
    For Column% = 0 To 6 '                                                         cycle through all 7 columns
        For Row% = 0 To 2 '                                                        cycle through first 3 rows
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            If Player% = EMPTY Then Exit For '                                     move to next column, four in row impossible
            WinCells%(0, 0) = Column% '                                            save spot as potential first four in a row checker
            WinCells%(0, 1) = Row% '                                               save spot as potential first four in a row checker
            FourCount% = 1 '                                                       reset four in a row counter
            For Count% = 1 To 3 '                                                  count through next three board positions
                If Board%(Column%, Row% + Count%) = Player% Then '                 does this position have a player checker in it?
                    WinCells%(Count%, 0) = Column% '                               yes, save spot as another potential four in a row checker
                    WinCells%(Count%, 1) = Row% + Count% '                         save spot as another potential four in a row checker
                    FourCount% = FourCount% + 1 '                                  increment four in a row counter
                End If
            Next Count%
            If FourCount% = 4 Then '                                               were 4 board positions saved?
                CheckFour% = Player% '                                             yes, player has four in a row
                Exit Function '                                                    leave function with result
            End If
        Next Row%
    Next Column%
    '** --------------------------------------------------------
    '** Check for 4 horizontal checkers in a row on entire board
    '** --------------------------------------------------------
    For Row% = 0 To 5 '                                                            cycle through all 6 rows
        For Column% = 0 To 3 '                                                     cycle through first 4 columns
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            If Player% <> EMPTY Then '                                             skip, move to next column%
                WinCells%(0, 0) = Column% '                                        save spot as potential first four in a row checker
                WinCells%(0, 1) = Row% '                                           save spot as potential first four in a row checker
                FourCount% = 1 '                                                   reset four in a row counter
                For Count% = 1 To 3 '                                              count through next three board positions
                    If Board%(Column% + Count%, Row%) = Player% Then '             does this position have a player checker in it?
                        WinCells%(Count%, 0) = Column% + Count% '                  yes, save spot as another potential four in a row checker
                        WinCells%(Count%, 1) = Row% '                              save spot as another potential four in a row checker
                        FourCount% = FourCount% + 1 '                              increment four in a row counter
                    End If
                Next Count%
                If FourCount% = 4 Then '                                           were 4 board positions saved?
                    CheckFour% = Player% '                                         yes, player has four in a row
                    Exit Function '                                                leave function with result
                End If
            End If
        Next Column%
    Next Row%
    '** --------------------------------------------------------
    '** Check for 4 diagonal / checkers in a row on entire board
    '** --------------------------------------------------------
    For Row% = 0 To 2 '                                                            cycle through first 3 rows
        For Column% = 0 To 3 '                                                     cycle through first 4 columns
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            If Player% <> EMPTY Then '                                             skip, move to next column%
                WinCells%(0, 0) = Column% '                                        save spot as potential first four in a row checker
                WinCells%(0, 1) = Row% '                                           save spot as potential first four in a row checker
                FourCount% = 1 '                                                   reset four in a row counter
                For Count% = 1 To 3 '                                              count through next three board positions
                    If Board%(Column% + Count%, Row% + Count%) = Player% Then '    does this position have a player checker in it?
                        WinCells%(Count%, 0) = Column% + Count% '                  yes, save spot as another potential four in a row checker
                        WinCells%(Count%, 1) = Row% + Count% '                     save spot as another potential four in a row checker
                        FourCount% = FourCount% + 1 '                              increment four in a row counter
                    End If
                Next Count%
                If FourCount% = 4 Then '                                           were 4 board positions saved?
                    CheckFour% = Player% '                                         yes, player has four in a row
                    Exit Function '                                                leave function with result
                End If
            End If
        Next Column%
    Next Row%
    '** --------------------------------------------------------
    '** Check for 4 diagonal \ checkers in a row on entire board
    '** --------------------------------------------------------
    For Row% = 5 To 3 Step -1 '                                                    cycle through top 3 rows
        For Column% = 0 To 3 '                                                     cycle through first 4 columns
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            If Player% <> EMPTY Then '                                             skip, move to next column
                WinCells%(0, 0) = Column% '                                        save spot as potential first four in a row checker
                WinCells%(0, 1) = Row% '                                           save spot as potential first four in a row checker
                FourCount% = 1 '                                                   reset four in a row counter
                For Count% = 1 To 3 '                                              count through next three board positions
                    If Board%(Column% + Count%, Row% - Count%) = Player% Then '    does this position have a player checker in it?
                        WinCells%(Count%, 0) = Column% + Count% '                  yes, save spot as another potential four in a row checker
                        WinCells%(Count%, 1) = Row% - Count% '                     save spot as another potential four in a row checker
                        FourCount% = FourCount% + 1 '                              increment four in a row counter
                    End If
                Next Count%
                If FourCount% = 4 Then '                                           were 4 board positions saved?
                    CheckFour% = Player% '                                         yes, player has four in a row
                    Exit Function '                                                leave function with result
                End If
            End If
        Next Column%
    Next Row%
    CheckFour% = EMPTY '                                                           return that no player has four in a row

    '******************************************************************************
End Function

Sub ShowWinner ()
    '******************************************************************************
    '*                                                                            *
    '* Show the winner of the previous game                                       *
    '*                                                                            *
    '******************************************************************************

    Dim Count% '                                                                   generic counter
    Dim Banner% '                                                                  the banner to show at top
    Dim Win% '                                                                     the winner of the game
    Dim x%, y%

    Shared WinCells%()
    Shared Cell() As CELL
    Shared Win&()
    Shared Lose&
    Shared Winner%()
    Shared CheckersDropped%
    Shared MenuOption%
    Shared SoundOption%
    Shared CellBlank%
    Shared CellImage%
    Shared WinSpin%()
    Shared GameOver%

    _Title "Game Over!" '                                                          change window title
    Win% = Cell(WinCells%(0, 0), WinCells%(0, 1)).c '                              get the winner of the game
    If CheckersDropped% = 42 And Not GameOver% Then '                                  was maximum amount of checkers dropped?
        Banner% = 3 '                                                              yes, set banner to display a draw
        If SoundOption% Then _SndPlayCopy Lose& '                                  play the audience not happy
        Do: Loop Until InKey$ = "" '                                               clear keyboard buffer
        Do: Loop Until InKey$ <> "" '                                              wait for a key to be pressed
        Exit Sub '                                                                 leave subroutine
    ElseIf Win% = 0 Then '                                                         is the winner player 1?
        Banner% = 0 '                                                              yes, set banner to display player 1 win
        If SoundOption% Then _SndPlayCopy Win&(0) '                                play audience clapping
    ElseIf MenuOption% = 1 And Win% = 1 Then '                                     is the winner player 2 against the computer?
        Banner% = 2 '                                                              yes, set banner to display computer win
        If SoundOption% Then _SndPlayCopy Lose& '                                  play the audience not happy
    Else '                                                                         player 2 wins against player 1
        Banner% = 1 '                                                              set banner to display player 2 win
        If SoundOption% Then _SndPlayCopy Win&(1) '                                play audience clapping
    End If
    For Count% = 1 To 100 '                                                        cycle from 1 to 100
        SPRITEZOOM Winner%(Banner%), Count% '                                      set the zoom level of the banner
        SPRITESTAMP 349, 49, Winner%(Banner%) '                                    display the banner on screen at current zoom
        _Display '                                                                 show the changes on screen
    Next Count%
    For Count% = 0 To 3 '                                                          cycle from 0 to 3
        x% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).x '                  get the x location of winning checker
        y% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).y '                  get the y location of winning checker
        SPRITESTAMP x%, y%, CellBlank% '                                           blank the current board spot
        SPRITESTAMP x%, y%, CellImage% '                                           place a clean cell there
        SPRITEZOOM WinSpin%(Win%, Count%), 90 '                                    zoom the winning spin checker to 90%
    Next Count%
    Do: Loop Until InKey$ = "" '                                                   clear the keyboard buffer
    Do
        _Limit 36 '                                                                limit loop to 36 FPS
        For Count% = 0 To 3 '                                                      cycle from 0 to 3
            x% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).x '              get the x location of winning checker
            y% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).y '              get the y location of winning checker
            SPRITEPUT x%, y%, WinSpin%(Win%, Count%) '                             place the winning spinning checker
        Next Count%
        _Display '                                                                 show the changes on screen
    Loop Until InKey$ <> "" '                                                      keep looping until a key is pressed
    For Count% = 0 To 3 '                                                          cycle from 0 to 3
        SPRITEPUT -100, -100, WinSpin%(Win%, Count%) '                             place winning spin checkers off screen for later use
    Next Count%

    '******************************************************************************
End Sub

Function MainMenu% ()
    '******************************************************************************
    '*                                                                            *
    '* The main menu                                                              *
    '*                                                                            *
    '******************************************************************************

    Dim Selection% '                                                               keep track of player menu selection
    Dim SelectionMade% '                                                           true when player has made a selection
    Dim KeyPress$ '                                                                which key is user pressing
    Dim Mcount% '                                                                  keep track of when to update marquee
    Dim ClearBuffer$

    Shared MenuImage&
    Shared MenuY%()
    Shared Menu%()
    Shared SpinChecker%()
    Shared MenuMusic&
    Shared MusicOption%

    _Title "Welcome to Four in a Row!" '                                           set the window title
    SPRITEPUT -100, -100, SpinChecker%(0) '                                        place black spinning checker sprite off screen for later use
    SPRITEPUT -100, -100, SpinChecker%(1) '                                        place red spinning chcker sprite off screen for later use.
    _PutImage (0, 0), MenuImage& '                                                 place saved image of menu screen on screen
    Selection% = 1 '                                                               reset player selection to first option
    SelectionMade% = FALSE '                                                       player has not made a selection yet
    Mcount% = 0 '                                                                  reset marquee update counter
    Do
        _Limit 36 '                                                                limit loop to 36 frames per second
        Mcount% = Mcount% + 1 '                                                    increment the marquee counter
        If Mcount% = 9 Then '                                                      time to update the marquee (4 times per second)
            Mcount% = 1 '                                                          yes, reset the marquee counter
            Marquee '                                                              update the marquee
        End If
        Do
            ClearBuffer$ = InKey$ '                                                get key in buffer
            If ClearBuffer$ <> "" Then KeyPress$ = UCase$(ClearBuffer$) '          save the last key pressed
        Loop Until ClearBuffer$ = "" '                                             keep looping until the buffer cleared
        If Len(KeyPress$) > 1 Then KeyPress$ = Right$(KeyPress$, 1) '              strip control character from player input
        Select Case KeyPress$ '                                                    which key was pressed?
            Case Chr$(72) '                                                        up arrow key has been pressed
                Selection% = Selection% - 1 '                                      decrement the menu selection
                If Selection% < 1 Then '                                           has menu selection gone below 1?
                    Selection% = 1 '                                               yes, reset menu selection back to 1
                Else '                                                             meneu selection is within range
                    SPRITESTAMP 349, MenuY%(Selection%), Menu%(Selection%, 1) '    highlight new menu selection
                    SPRITESTAMP 349, MenuY%(Selection% + 1), Menu%(Selection% + 1, 0) ' remove highlight from former menu selection
                End If
            Case Chr$(80) '                                                        down arrow key has been pressed
                Selection% = Selection% + 1 '                                      increment the menu selection
                If Selection% > 4 Then '                                           has menu selection gone above 4?
                    Selection% = 4 '                                               yes, reset menu selection back to 4
                Else '                                                             menu selection is within range
                    SPRITESTAMP 349, MenuY%(Selection%), Menu%(Selection%, 1) '    highlight new menu selection
                    SPRITESTAMP 349, MenuY%(Selection% - 1), Menu%(Selection% - 1, 0) ' remove highlight from former menu selection
                End If
            Case Chr$(13) '                                                        enter key has been pressed
                SelectionMade% = TRUE '                                            set selection made flag to true
        End Select
        KeyPress$ = "" '                                                           reset keyboard input string
        SPRITEPUT 62, MenuY%(Selection%), SpinChecker%(1) '                        place red spinning checker on screen
        SPRITEPUT 636, MenuY%(Selection%), SpinChecker%(0) '                       place black spinning checker on screen
        _Display '                                                                 show all graphic updates on screen
    Loop Until SelectionMade% '                                                    keep looping until a selection has been made
    SPRITEPUT -100, -100, SpinChecker%(0) '                                        place black spinning checker sprite off screen for later use
    SPRITEPUT -100, -100, SpinChecker%(1) '                                        place red spinning chcker sprite off screen for later use.
    MainMenu% = Selection% '                                                       return the value of selection

    '******************************************************************************
End Function

Sub Marquee () Static
    '******************************************************************************
    '*                                                                            *
    '* Marquee                                                                    *
    '*                                                                            *
    '******************************************************************************

    Dim MainFlipFlop% '                                                            which checker color to start on
    Dim FlipFlop% '                                                                keep track of color as checkers drawn
    Dim count%

    Shared CheckerSheet%
    Shared MarqueeChecker%()

    MainFlipFlop% = 1 - MainFlipFlop% '                                            flip the start color value
    FlipFlop% = MainFlipFlop% '                                                    set the color tracker
    For count% = 10 To 690 Step 20 '                                               x location of checkers
        SPRITESTAMP count%, 10, MarqueeChecker%(FlipFlop%) '                       draw top row checker
        SPRITESTAMP count%, 210, MarqueeChecker%(FlipFlop%) '                      draw bottom row checker
        If count% < 210 Then '                                                     use x location as y location for vertical checkers
            SPRITESTAMP 10, count%, MarqueeChecker%(FlipFlop%) '                   draw left side checker
            SPRITESTAMP 690, count%, MarqueeChecker%(FlipFlop%) '                  draw right side checker
        End If
        FlipFlop% = 1 - FlipFlop% '                                                flip the next checker color
    Next count%

    '******************************************************************************
End Sub

Sub MoveChecker (CheckerColor%, CPUColumn%)
    '******************************************************************************
    '*                                                                            *
    '* Moves the checker from column to column.                                   *
    '*                                                                            *
    '******************************************************************************

    Dim SpinCount% '                                                               keep track of which checker frame is showing
    Dim Column% '                                                                  the column spinning checker is at
    Dim ClearBuffer$ '                                                             clears the keyboard buffer
    Dim KeyPress$ '                                                                the key the player pressed
    Dim ColumnChosen% '                                                            true when player has chosen column
    Dim OldColumn% '                                                               the previous column spinning checker was at
    Dim CheckerDrop% '                                                             flag used to indicate when checker dropped
    Dim Face% '                                                                    indicates which side of checker to show
    Dim WaitTime% '                                                                time in between computer movements
    Dim NewWait% '                                                                 flag to indicate ok for computer to move
    Dim ComputerTurn% '                                                            flag indicating it's the computer's turn to move

    Shared CellBlank%
    Shared Cell() As CELL
    Shared SpinChecker%()
    Shared TitleMode%

    Randomize Timer '                                                              seed the random number generator
    SPRITESET SpinChecker%(0), 1 '                                                 reset black checker animation to beginning
    SPRITESET SpinChecker%(1), 37 '                                                reset red checker animation to beginning
    ComputerTurn% = FALSE '                                                        assume it is not computer's turn to move
    NewWait% = FALSE '                                                             assume it is not computer's turn to move
    ColumnChosen% = FALSE '                                                        no column chosen yet
    CheckerDrop% = FALSE '                                                         the checker has not been dropped yet
    SpinCount% = 1 '                                                               set to frame 1 of spinning animation
    Column% = Abs(TitleMode% * 3) + 3 '                                            where should spinning checker start
    OldColumn% = Column% '                                                         set previous column to the same
    If CPUColumn% >= 0 Then '                                                      is it the computer's turn to move?
        ComputerTurn% = TRUE '                                                     yes, set flag indicating this
        NewWait% = TRUE '                                                          set flag telling CPU ok to move
    End If
    Do
        If Not ComputerTurn% Then '                                                is it the computer's turn to move?
            Do '                                                                   no
                ClearBuffer$ = InKey$ '                                            get key in buffer
                If ClearBuffer$ <> "" Then KeyPress$ = UCase$(ClearBuffer$) '      save the last key pressed
            Loop Until ClearBuffer$ = "" '                                         keep looping until the buffer cleared
            If Len(KeyPress$) > 1 Then KeyPress$ = Right$(KeyPress$, 1) '          strip control character from player input
        Else '                                                                     computer's move
            If NewWait% Then '                                                     generate a random wait time?
                WaitTime% = Int(Rnd(1) * 20) + 9 '                                 yes, between 9 and 28 frames
                If TitleMode% Then WaitTime% = 18 '                                set a fixed wait time if in title sequence mode
                NewWait% = FALSE '                                                 turn off random wait time generate until move made
            End If
            If SpinCount% > 0 And (SpinCount% / WaitTime% = SpinCount% \ WaitTime%) Then ' is it time for computer move?
                NewWait% = TRUE '                                                  yes, a new wait time will be needed then
                If CPUColumn% > Column% Then '                                     does computer need to move right?
                    KeyPress$ = Chr$(77) '                                         yes, simulate the right key being pressed
                ElseIf CPUColumn% < Column% Then '                                 does computer need to move left?
                    KeyPress$ = Chr$(75) '                                         yes, simulate the left key being pressed
                Else '                                                             computer is now at correct column
                    KeyPress$ = Chr$(80) '                                         simulate the down key being pressed
                End If
            End If
        End If
        Select Case KeyPress$ '                                                    which key was pressed?
            Case Chr$(75) '                                                        left arrow key
                Column% = Column% - 1 '                                            decrement column value
            Case Chr$(77) '                                                        right arrow key
                Column% = Column% + 1 '                                            increment column value
            Case Chr$(80), Chr$(13) '                                              down arrow or enter key
                CheckerDrop% = TRUE '                                              set flag to drop checker
        End Select
        KeyPress$ = "" '                                                           reset keyboard input string
        If Column% < 0 Then Column% = 0 '                                          stay on left side of board
        If Column% > 6 Then Column% = 6 '                                          stay on right side of board
        If Column% <> OldColumn% Then OldColumn% = Column% '                       remember new column chosen
        Do
            _Limit 36 '                                                            limit this loop to 36 times per second
            SPRITEPUT Cell(Column%, 1).x, 50, SpinChecker%(CheckerColor%) ' place the auto-animating checker sprite
            SpinCount% = SpinCount% + 1 '                                          keep track of which checker frame is showing
            If SpinCount% = 36 Then SpinCount% = 0 '                               reset frame tracker when checker completes a spin
            _Display '                                                             update the screen with changes
            If (CheckerDrop% And (SpinCount% = 1)) Or (CheckerDrop% And (SpinCount% = 19)) Then ' is checker ready to drop?
                If SpinCount% = 1 Then Face% = 0 Else Face% = 1 '                  yes, determine which checker face to show
                ColumnChosen% = DropChecker(Column%, CheckerColor%, Face%) '       drop the checker
                CheckerDrop% = FALSE '                                             reset checker drop flag
                If TitleMode% Then '                                               in title sequence mode?
                    ColumnChosen% = TRUE '                                         yes, trick routine into thinking column chosen
                    CheckerDrop% = FALSE '                                         trick routine into thinking checker dropped
                End If
            End If
        Loop Until Not CheckerDrop% '                                              stay in this loop until attempted checker drop
    Loop Until ColumnChosen% '                                                     stay in this loop until checker has actually dropped
    Do: Loop Until InKey$ = "" '                                                   clear keyboard buffer of any stray inputs

    '******************************************************************************
End Sub

Function DropChecker% (Column%, CheckerColor%, Face%)
    '******************************************************************************
    '*                                                                            *
    '* Drops a checker into a given column of specified color and facing side.    *
    '*                                                                            *
    '******************************************************************************

    Dim RowCheck% '                                                                row to check for a checker
    Dim RowFound% '                                                                goes true when a valid row is found
    Dim SlideVolume! '                                                             current volume of checker sliding sound
    Dim Fallen% '                                                                  true when checker has fallen total distance
    Dim FallCount% '                                                               current y position of falling checker
    Dim OldFallCount% '                                                            last y position of falling checker
    Dim FallTime! '                                                                increasing speed of falling checker
    Dim CellCount% '                                                               cell positions involved in drop animation
    Dim SlideVloume!

    Shared CellImage%
    Shared CellBlank%
    Shared Cell() As CELL
    Shared Click&
    Shared Drop&
    Shared Slide&
    Shared Checker%()
    Shared LastRow%
    Shared LastColumn%
    Shared SoundOption%

    DropChecker% = FALSE '                                                         assume column can't have checker dropped
    RowCheck% = 6 '                                                                reset row count
    RowFound% = FALSE '                                                            assume a row can't be found
    Fallen% = FALSE '                                                              assume checker has not fallen yet
    SlideVloume! = .00001 '                                                        set intital volume of slide sound low
    FallCount% = 50 '                                                              start animation y location from here
    OldFallCount% = 50 '                                                           start animation y location from here
    FallTime! = 1 '                                                                set initial falling speed of 1 pixel
    Do
        If Cell(Column%, RowCheck% - 1).c <> 2 Then '                              is there a checker here?
            RowFound% = TRUE '                                                     yes, previous row seems valid
        Else '                                                                     there is no checker here
            RowCheck% = RowCheck% - 1 '                                            move onto the next row
            If RowCheck% = 0 Then RowFound% = TRUE '                               leave if run out of rows to check
        End If
    Loop Until RowFound% '                                                         leave if a possible row is found
    If RowCheck% <> 6 Then '                                                       was a vaild row found?
        DropChecker% = TRUE '                                                      return that a checker was dropped
        If SoundOption% Then '                                                     is sound allowed?
            _SndPlay Slide& '                                                      yes, start the sliding noise
            _SndVol Slide&, SlideVolume! '                                         set the initial low volume
        End If
        Do
            _Limit 150 '                                                           limit to 150 frames per second
            SPRITESTAMP Cell(Column%, RowCheck%).x, OldFallCount%, CellBlank% '    clear the last checker position
            FallCount% = FallCount% + Int(FallTime!) '                             update falling checker y position
            OldFallCount% = FallCount% '                                           remember this position to clear later
            If FallCount% >= Cell(Column%, RowCheck%).y Then '                     has checker reached bottom?
                Fallen% = TRUE '                                                   yes, mark as such
                SPRITESTAMP Cell(Column%, RowCheck%).x, Cell(Column%, RowCheck%).y, Checker%(CheckerColor%, Face%) ' draw checker in final spot
                If SoundOption% Then _SndStop Slide& '                             stop the sliding noise if allowed
                If RowCheck% = 0 Then '                                            was there no other checker in this column?
                    If SoundOption% Then _SndPlayCopy Drop&, 1 '                   play sound of checker hitting game rack if allowed
                Else '                                                             the falling checker hit another checker
                    If SoundOption% Then _SndPlayCopy Click&, .1666 * (6 - RowCheck%) ' play sound of checker hitting another checker if allowed
                End If
            Else '                                                                 checker is still falling
                SPRITESTAMP Cell(Column%, RowCheck%).x, FallCount%, Checker%(CheckerColor%, Face%) ' draw checker's current position
            End If
            For CellCount% = 5 To RowCheck% Step -1 '                              loop through cells affected by animation
                SPRITESTAMP Cell(Column%, CellCount%).x, Cell(Column%, CellCount%).y, CellImage% ' draw cell image in these locations
            Next CellCount%
            FallTime! = FallTime! * 1.05 '                                         increase the falling speed
            SlideVolume! = SlideVolume! + .0005 '                                  increase the sliding noise volume
            If SoundOption% Then _SndVol Slide&, SlideVolume! '                    set the new sliding noise volume if sound allowed
            _Display '                                                             show all changes made to screen
        Loop Until Fallen% '                                                       keep looping until checker comes to a halt
        Cell(Column%, RowCheck%).c = CheckerColor% '                               update array with current checker in position
        Cell(Column%, RowCheck%).f = Face% '                                       update array with current checker face showing
        LastRow% = RowCheck% '                                                     remember last row checker dropped in
        LastColumn% = Column% '                                                    remember last column checker dropped in
    End If

    '******************************************************************************
End Function

Sub DrawBoard ()
    '******************************************************************************
    '*                                                                            *
    '* Draws the initial game board.                                              *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     current row of cell being drawn
    Dim Column% '                                                                  current column of cell being drawn

    Shared CellImage%
    Shared Cell() As CELL

    _Title "Game in Progress!" '                                                   change window title to show game in progress
    Line (0, 0)-(699, 699), _RGB32(0, 0, 254), BF '                                clear the entire screen
    For Column% = 0 To 6 '                                                         cycle through all cell columns
        For Row% = 0 To 5 '                                                        cycle through all cell rows
            SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, CellImage% ' draw the cell image
        Next Row%
    Next Column%

    '******************************************************************************
End Sub

Sub InitializeVariables ()
    '******************************************************************************
    '*                                                                            *
    '* Initializes game variables to default conditions.                          *
    '*                                                                            *
    '******************************************************************************

    Dim Row% '                                                                     current cell row
    Dim Column% '                                                                  current cell column

    Shared Cell() As CELL '                                                        game board checker positions

    For Column% = 0 To 6 '                                                         cycle through all cell columns
        For Row% = 0 To 5 '                                                        cycle through all cell rows
            Cell(Column%, Row%).x = Column% * 100 + 50 '                           compute this cell's x location
            Cell(Column%, Row%).y = 650 - Row% * 100 '                             compute this cell's y location
            Cell(Column%, Row%).c = EMPTY '                                        no checker
            Cell(Column%, Row%).f = 0 '                                            front facing checkers
        Next Row%
    Next Column%

    '******************************************************************************
End Sub

Sub TitleSequence ()
    '******************************************************************************
    '*                                                                            *
    '* Plays the starting title sequence of the game.                             *
    '*                                                                            *
    '******************************************************************************

    Dim Bcolumn$(6, 4) '                                                           array holding checkers spelling "4 in a row"
    Dim DropCount% '                                                               keeps track of number of checkers dropped
    Dim CellCount% '                                                               keeps track of number of cells visited in column
    Dim Dummy% '                                                                   dummy value returned by DropChecker()
    Dim Dropped% '                                                                 true when a checker has been dropped
    Dim Column% '                                                                  the random column to drop a checker down
    Dim Row% '                                                                     row counter
    Dim ShrinkingChecker%(2) '                                                     shrinking checker sprites
    Dim Zoom% '                                                                    zoom level of shrinking checkers
    Dim FourImage& '                                                               image of red 4
    Dim TempImage& '                                                               temporary image holder
    Dim Count% '                                                                   generic counter
    Dim Mcount% '                                                                  marquee counter

    Shared TitleMode%
    Shared TitleMusic&
    Shared Cell() As CELL
    Shared Checker%()
    Shared CheckerSheet%
    Shared CellBlank%
    Shared Drop&
    Shared Menu%()
    Shared MenuImage&
    Shared MenuY%()
    Shared SpinChecker%()
    Shared MusicOption%
    Shared SoundOption%

    Bcolumn$(0, 0) = "000000": Bcolumn$(0, 1) = "00000 ": Bcolumn$(0, 2) = " 0    ": Bcolumn$(0, 3) = "    0 ": Bcolumn$(0, 4) = "0     "
    Bcolumn$(1, 0) = "000111": Bcolumn$(1, 1) = "      ": Bcolumn$(1, 2) = "0 0 0 ": Bcolumn$(1, 3) = "   0  ": Bcolumn$(1, 4) = " 00   "
    Bcolumn$(2, 0) = "000100": Bcolumn$(2, 1) = "00000 ": Bcolumn$(2, 2) = "0 0 0 ": Bcolumn$(2, 3) = " 000  ": Bcolumn$(2, 4) = "0     "
    Bcolumn$(3, 0) = "000100": Bcolumn$(3, 1) = "   0  ": Bcolumn$(3, 2) = " 000  ": Bcolumn$(3, 3) = "0   0 ": Bcolumn$(3, 4) = " 0000 "
    Bcolumn$(4, 0) = "111111": Bcolumn$(4, 1) = "    0 ": Bcolumn$(4, 2) = "0     ": Bcolumn$(4, 3) = "0   0 ": Bcolumn$(4, 4) = "      "
    Bcolumn$(5, 0) = "000100": Bcolumn$(5, 1) = "0000  ": Bcolumn$(5, 2) = "00000 ": Bcolumn$(5, 3) = " 000  ": Bcolumn$(5, 4) = "      "
    Bcolumn$(6, 0) = "000000": Bcolumn$(6, 1) = "      ": Bcolumn$(6, 2) = "   0  ": Bcolumn$(6, 3) = " 0000 ": Bcolumn$(6, 4) = "      "

    Screen _NewImage(700, 700, 32) '                                               700x700x32bit screen
    _ScreenMove _Middle '                                                          move the screen to the middle of desktop
    DrawBoard '                                                                    draw the game board
    _Title "Welcome to Four in a Row!" '                                           title the window
    DropCount% = 0 '                                                               reset checker drop counter
    ShrinkingChecker%(0) = SPRITENEW(CheckerSheet%, 1, SAVE) '                     create the black shrinking checker sprite side 1
    ShrinkingChecker%(1) = SPRITENEW(CheckerSheet%, 19, SAVE) '                    create the black shrinking checker sprite side 2
    ShrinkingChecker%(2) = SPRITENEW(CheckerSheet%, 37, SAVE)
    Randomize Timer '                                                              seed the random number generator
    If MusicOption% Then '                                                         is music allowed?
        _SndPlay TitleMusic& '                                                     yes, start the funky title music
        _SndVol TitleMusic&, 1 '                                                   set the volume to highest value
    End If
    Do
        Column% = Int(Rnd(1) * 7) '                                                choose a random column
        CellCount% = 1 '                                                           start counting at bottom cell of column
        Dropped% = FALSE '                                                         reset the checker dropped flag
        If Bcolumn$(Column%, 0) <> "      " Then '                                 is this column full of checkers?
            Do '                                                                   no
                If Mid$(Bcolumn$(Column%, 0), CellCount%, 1) <> " " Then '         is there a checker in this position?
                    Dummy% = DropChecker%(Column%, Val(Mid$(Bcolumn$(Column%, 0), CellCount%, 1)), Int(Rnd(1) * 2)) ' no, drop a checker
                    Mid$(Bcolumn$(Column%, 0), CellCount%, 1) = " " '              mark this cell as used by a checker
                    DropCount% = DropCount% + 1 '                                  increment the checker drop counter
                    Dropped% = TRUE '                                              set the dropped checker flag
                Else '                                                             there is a checker in this position
                    CellCount% = CellCount% + 1 '                                  increment cell counter to try next cell
                End If
            Loop Until Dropped% '                                                  keep looping until a checker is dropped
        End If
    Loop Until DropCount% = 42 '                                                   keep looping until all checkers have been dropped
    TitleMode% = TRUE '                                                            set the title mode flag
    MoveChecker RED, 1 '                                                           move a spinning red checker into the scene
    TitleMode% = FALSE '                                                           remove the title mode flag
    Line (0, 100)-(699, 699), _RGB32(0, 0, 254), BF '                              remove the board and chckers, leave top red checker
    For Column% = 0 To 6 '                                                         cycle through all the columns
        For Row% = 0 To 5 '                                                        cycle through all the rows
            SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, Checker%(Cell(Column%, Row%).c, Cell(Column%, Row%).f) ' draw only checkers
        Next Row%
    Next Column%
    _Display '                                                                     update the screen with changes
    For Zoom% = 100 To 1 Step -1 '                                                 zoom black checkers from 100% to 1%
        _Limit 100 '                                                               take one second to zoom black checkers out
        SPRITEZOOM ShrinkingChecker%(0), Zoom% '                                   set the zoom level of black checker face 1
        SPRITEZOOM ShrinkingChecker%(1), Zoom% '                                   set the zoom level of black checker face 2
        For Column% = 0 To 6 '                                                     cycle through all the columns
            For Row% = 0 To 5 '                                                    cycle through all the rows
                If Cell(Column%, Row%).c = 0 Then '                                does this cell contain a black checker?
                    SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, CellBlank% ' yes, clear the cell
                    SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, ShrinkingChecker%(Cell(Column%, Row%).f) ' place the zoomed checker
                End If
            Next Row%
        Next Column%
        _Display '                                                                 update the screen with changes
    Next Zoom%
    FourImage& = _CopyImage(0) '                                                   save the red 4 that is left on the screen
    SPRITEPUT -100, -100, SpinChecker%(1)
    For Zoom% = 699 To 139 Step -10 '                                              shrink the red 4 image by 80%
        Line (0, 0)-(Zoom% + 30, Zoom% + 50), _RGB32(0, 0, 254), BF '              clear the last red 4 image drawn
        _PutImage (20, 40)-(Zoom% + 20, Zoom% + 40), FourImage& '                  place the newly sized red 4 on the screen
        _Display '                                                                 update the screen with changes
    Next Zoom%
    If SoundOption% Then _SndPlayCopy Drop& '                                      play checker drop noise when 4 finished shrinking
    TempImage& = _NewImage(700, 700, 32) '                                         create a new temporary image
    For Count% = 1 To 4 '                                                          cycle through the remaining four array elements
        _Dest TempImage& '                                                         drawing will be done on the temporary image
        Line (0, 0)-(699, 699), _RGB32(0, 0, 254), BF '                            fill the temp image with blue
        For Column% = 0 To 6 '                                                     cycle through all the columns
            For Row% = 0 To 5 '                                                    cycle through all the rows
                If Mid$(Bcolumn$(Column%, Count%), Row% + 1, 1) = "0" Then '           does this string position in array contain 0?
                    If Count% = 2 And Column% < 5 Then '                           yes, are we currently drawing the "a"?
                        Cell(Column%, Row%).c = 1 '                                yes, set this position to be a red checker
                    Else '                                                         we are not currently drawing the "a"
                        Cell(Column%, Row%).c = 0 '                                set this position to be a black checker
                    End If
                    Cell(Column%, Row%).f = Int(Rnd(1) * 2) '                      create a random face for the checker
                Else '                                                             this position does not contain a 0
                    Cell(Column%, Row%).c = 2 '                                    set this position to contain no checker
                End If
                SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, Checker%(Cell(Column%, Row%).c, Cell(Column%, Row%).f) ' draw the positon
            Next Row%
        Next Column%
        _Dest 0 '                                                                  drawing will be done on the screen
        For DropCount% = -150 To 20 '                                              drop the remaining words in from the top of screen
            Line (20 + Count% * 140, 0)-(149 + Count% * 140, 149), _RGB32(0, 0, 254), BF ' clear the position where words will drop in from
            _PutImage (20 + Count% * 140, DropCount%)-(159 + Count% * 140, DropCount% + 139), TempImage& ' place temporary image shrunk on screen
            _Display '                                                             update the screen with changes
        Next DropCount%
        If SoundOption% Then _SndPlayCopy Drop& '                                  play checker drop noise when words in place
    Next Count%
    Row% = 1 '                                                                     start with menu row 1
    Mcount% = 0 '                                                                  reset marquee counter
    For Count% = 300 To 645 Step 115 '                                             step through menu entry Y positions
        MenuY%(Row%) = Count% '                                                    save this Y position
        For Zoom% = 1 To 100 '                                                     cycle from 1 to 100
            _Limit 128 '                                                           limit FOR statement to 128 FPS
            SPRITEZOOM Menu%(Row%, 0), Zoom% '                                     set zoom level of menu entry
            SPRITESTAMP 349, Count%, Menu%(Row%, 0) '                              place menu entry on screen
            Mcount% = Mcount% + 1 '                                                increment marquee counter
            If Mcount% = 32 Then '                                                 1/4 second gone by?
                Mcount% = 1 '                                                      yes, reset marquee counter
                Marquee '                                                          update the marquee
            End If
            _Display '                                                             display changes to the screen
        Next Zoom%
        If SoundOption% Then _SndPlayCopy Drop& '                                  play sound when menu entry zoomed in
        Row% = Row% + 1 '                                                          increment menu row counter
    Next Count%
    SPRITESTAMP 349, MenuY%(1), Menu%(1, 1) '                                      highlight first menu entry
    MenuImage& = _CopyImage(0) '                                                   save a copy of the screen
    For Zoom% = 1 To 100 '                                                         cycle from 1 to 100
        _Limit 128 '                                                               limit FOR statement to 128 FPS
        SPRITEZOOM ShrinkingChecker%(0), Zoom% '                                   set zoom level of black checker
        SPRITEZOOM ShrinkingChecker%(2), Zoom% '                                   set zoom level of red checker
        SPRITEPUT 62, MenuY%(1), ShrinkingChecker%(2) '                            place red checker on screen
        SPRITEPUT 636, MenuY%(1), ShrinkingChecker%(0) '                           place black checker on screen
        Mcount% = Mcount% + 1 '                                                    incrememnt marquee counter
        If Mcount% = 32 Then '                                                     1/4 second gone by?
            Mcount% = 1 '                                                          yes, reset marquee counter
            Marquee '                                                              update the marquee
        End If
        _Display '                                                                 display changes to the screen
    Next Zoom%
    Do
        _Limit 4 '                                                                 limit loop to 4 FPS
        Marquee '                                                                  update the marquee
        _Display '                                                                 display changes to the screen
    Loop Until Not _SndPlaying(TitleMusic&) '                                      keep looping until music done
    If MusicOption% Then '                                                         is music allowed?
        _SndVol TitleMusic&, 0 '                                                   yes, set music volume to 0  \
        _SndPlay TitleMusic& '                                                     play music again             \  this is a workaround for a QB64
        _Delay .1 '                                                                delay for 10th of second      - MMIDI bug that crashes program
        _SndStop TitleMusic& '                                                     stop music                   /
        _SndClose TitleMusic& '                                                    close music                 /
    End If

    '******************************************************************************
End Sub

Function AllExist% ()
    '******************************************************************************
    '*                                                                            *
    '* Returns TRUE if all support files exist, FALSE otherwise.                  *
    '*                                                                            *
    '******************************************************************************

    AllExist% = FALSE '                                                            assume a file(s) is missing
    If Not _FileExists("checkers.png") Then Exit Function '                        if any file is missing return FALSE
    If Not _FileExists("4iaricon.bmp") Then Exit Function
    If Not _FileExists("click.wav") Then Exit Function
    If Not _FileExists("firstdrop.wav") Then Exit Function
    If Not _FileExists("slide.wav") Then Exit Function
    If Not _FileExists("title.mid") Then Exit Function
    If Not _FileExists("music.ogg") Then Exit Function
    If Not _FileExists("menu.png") Then Exit Function
    If Not _FileExists("menu.ogg") Then Exit Function
    If Not _FileExists("win1.ogg") Then Exit Function
    If Not _FileExists("win2.ogg") Then Exit Function
    If Not _FileExists("lose.ogg") Then Exit Function
    AllExist% = TRUE '                                                             made it this far then all exist

    '******************************************************************************
End Function

Sub CreateAssets ()
    '******************************************************************************
    '*                                                                            *
    '* Prepares graphics and sounds for game play.                                *
    '*                                                                            *
    '* - Load the checkers sprite sheet and game board images into memory.        *
    '* - Create the black and red checker sprites.                                *
    '* - Set up animation characteristics of both checker sprites.                *
    '*                                                                            *
    '******************************************************************************

    Dim icon& '                                                                    handle that holds window icon image

    Shared CheckerSheet% '
    Shared MenuSheet%
    Shared SpinChecker%() '
    Shared Checker%() '
    Shared Menu%()
    Shared board& '
    Shared CellImage% '
    Shared CellBlank% '
    Shared Click& '
    Shared Drop& '
    Shared Slide& '
    Shared TitleMusic&
    Shared MarqueeChecker%()
    Shared Options%()
    Shared GameLevel%
    Shared SoundOption%
    Shared MusicOption%
    Shared GameMusic&
    Shared MenuMusic&
    Shared Win&()
    Shared Lose&
    Shared Winner%()
    Shared WinSpin%()

    If Not AllExist% Then '                                                        do all support files exist?
        Print '                                                                    no, inform user
        Print "     Four in a Row"
        Print "          by"
        Print "     Terry Ritchie"
        Print "terry.ritchie@gmail.com"
        Print
        Print "ERROR: One or more support files are missing."
        Print "       Please reinstall the game."
        Print
        Print "Press any key to return to Windows."
        Beep '                                                                     get user's attention
        Do: Loop Until InKey$ = "" '                                               clear keyboard buffer
        Do: Loop Until InKey$ <> "" '                                              wait for a key press
        System '                                                                   return to Windows
    End If
    icon& = _LoadImage("4iaricon.bmp", 32) '                                       load the window icon image
    _Icon icon& '                                                                  set the window icon image
    _FreeImage icon& '                                                             remove the icon image from memory
    CheckerSheet% = SPRITESHEETLOAD("checkers.png", 100, 100, _RGB32(0, 0, 255)) ' load the checkers sprite sheet into memory
    MenuSheet% = SPRITESHEETLOAD("menu.png", 700, 100, NOTRANSPARENCY) '           sprite sheet containing menu and options entries
    Checker%(0, 0) = SPRITENEW(CheckerSheet%, 1, SAVE) '                           create the black checker sprite side 1
    Checker%(0, 1) = SPRITENEW(CheckerSheet%, 19, SAVE) '                          create the black checker sprite side 2
    Checker%(1, 0) = SPRITENEW(CheckerSheet%, 37, SAVE) '                          create the red checker sprite side 1
    Checker%(1, 1) = SPRITENEW(CheckerSheet%, 55, SAVE) '                          create the red checker sprite side 2
    Checker%(2, 0) = SPRITENEW(CheckerSheet%, 74, DONTSAVE) '                      create sprite containing blank background
    Checker%(2, 1) = Checker%(2, 0) '                                              for both sides
    SpinChecker%(0) = SPRITENEW(CheckerSheet%, 1, SAVE) '                          create the black spinning checker sprite
    SpinChecker%(1) = SPRITENEW(CheckerSheet%, 37, SAVE) '                         create the red spinning checker sprite
    WinSpin%(0, 0) = SPRITENEW(CheckerSheet%, 1, SAVE) '                           create the winning black spinning checkers
    WinSpin%(0, 1) = SPRITENEW(CheckerSheet%, 1, SAVE)
    WinSpin%(0, 2) = SPRITENEW(CheckerSheet%, 1, SAVE)
    WinSpin%(0, 3) = SPRITENEW(CheckerSheet%, 1, SAVE)
    WinSpin%(1, 0) = SPRITENEW(CheckerSheet%, 37, SAVE) '                          create the winning red spinning checkers
    WinSpin%(1, 1) = SPRITENEW(CheckerSheet%, 37, SAVE)
    WinSpin%(1, 2) = SPRITENEW(CheckerSheet%, 37, SAVE)
    WinSpin%(1, 3) = SPRITENEW(CheckerSheet%, 37, SAVE)
    Menu%(1, 0) = SPRITENEW(MenuSheet%, 1, DONTSAVE) '                              1 Player
    Menu%(1, 1) = SPRITENEW(MenuSheet%, 2, DONTSAVE) '                             (1 Player)
    Menu%(2, 0) = SPRITENEW(MenuSheet%, 3, DONTSAVE) '                              2 Player
    Menu%(2, 1) = SPRITENEW(MenuSheet%, 4, DONTSAVE) '                             (2 Player)
    Menu%(3, 0) = SPRITENEW(MenuSheet%, 5, DONTSAVE) '                              Options
    Menu%(3, 1) = SPRITENEW(MenuSheet%, 6, DONTSAVE) '                             (Options)
    Menu%(4, 0) = SPRITENEW(MenuSheet%, 7, DONTSAVE) '                              Quit
    Menu%(4, 1) = SPRITENEW(MenuSheet%, 8, DONTSAVE) '                             (Quit)
    Options%(1, 0) = SPRITENEW(MenuSheet%, 9, DONTSAVE) '                           Difficulty
    Options%(1, 1) = SPRITENEW(MenuSheet%, 10, DONTSAVE) '                         (Difficulty)
    Options%(2, 1) = SPRITENEW(MenuSheet%, 11, DONTSAVE) '                         (1) 2  3  4  5
    Options%(2, 2) = SPRITENEW(MenuSheet%, 12, DONTSAVE) '                          1 (2) 3  4  5
    Options%(2, 3) = SPRITENEW(MenuSheet%, 13, DONTSAVE) '                          1  2 (3) 4  5
    Options%(2, 4) = SPRITENEW(MenuSheet%, 14, DONTSAVE) '                          1  2  3 (4) 5
    Options%(2, 5) = SPRITENEW(MenuSheet%, 15, DONTSAVE) '                          1  2  3  4 (5)
    Options%(3, 0) = SPRITENEW(MenuSheet%, 16, DONTSAVE) '                          Sound  On (Off)
    Options%(3, 1) = SPRITENEW(MenuSheet%, 17, DONTSAVE) '                          Sound (On) Off
    Options%(3, 2) = SPRITENEW(MenuSheet%, 18, DONTSAVE) '                         (Sound) On (Off)
    Options%(3, 3) = SPRITENEW(MenuSheet%, 19, DONTSAVE) '                         (Sound)(On) Off
    Options%(4, 0) = SPRITENEW(MenuSheet%, 20, DONTSAVE) '                          Music  On (Off)
    Options%(4, 1) = SPRITENEW(MenuSheet%, 21, DONTSAVE) '                          Music (On) Off
    Options%(4, 2) = SPRITENEW(MenuSheet%, 22, DONTSAVE) '                         (Music) On (Off)
    Options%(4, 3) = SPRITENEW(MenuSheet%, 23, DONTSAVE) '                         (Music)(On) Off
    Winner%(0) = SPRITENEW(MenuSheet%, 24, DONTSAVE) '                             Player 1 Wins!
    Winner%(1) = SPRITENEW(MenuSheet%, 25, DONTSAVE) '                             Player 2 Wins!
    Winner%(2) = SPRITENEW(MenuSheet%, 26, DONTSAVE) '                             I Win!
    Winner%(3) = SPRITENEW(MenuSheet%, 27, DONTSAVE) '                             It's a Draw!
    SPRITEANIMATESET WinSpin%(0, 0), 1, 36 '                                       set the animation cells of black winning spinning checkers
    SPRITEANIMATESET WinSpin%(0, 1), 1, 36
    SPRITEANIMATESET WinSpin%(0, 2), 1, 36
    SPRITEANIMATESET WinSpin%(0, 3), 1, 36
    SPRITEANIMATESET WinSpin%(1, 0), 37, 72 '                                      set the animation cells of red winning spinning checkers
    SPRITEANIMATESET WinSpin%(1, 1), 37, 72
    SPRITEANIMATESET WinSpin%(1, 2), 37, 72
    SPRITEANIMATESET WinSpin%(1, 3), 37, 72
    SPRITEANIMATION WinSpin%(0, 0), ANIMATE, FORWARDLOOP '                         enable autoanimation for black winning spinning checkers
    SPRITEANIMATION WinSpin%(0, 1), ANIMATE, FORWARDLOOP
    SPRITEANIMATION WinSpin%(0, 2), ANIMATE, FORWARDLOOP
    SPRITEANIMATION WinSpin%(0, 3), ANIMATE, FORWARDLOOP
    SPRITEANIMATION WinSpin%(1, 0), ANIMATE, FORWARDLOOP '                         enable autoanimation for red winning spinning checkers
    SPRITEANIMATION WinSpin%(1, 1), ANIMATE, FORWARDLOOP
    SPRITEANIMATION WinSpin%(1, 2), ANIMATE, FORWARDLOOP
    SPRITEANIMATION WinSpin%(1, 3), ANIMATE, FORWARDLOOP
    SPRITEANIMATESET SpinChecker%(0), 1, 36 '                                      define the animation cells of the black spinning checker
    SPRITEANIMATESET SpinChecker%(1), 37, 72 '                                     define the animation cells of the red spinning checker
    SPRITEANIMATION SpinChecker%(0), ANIMATE, FORWARDLOOP '                        turn on auto-animation for black spinning checker
    SPRITEANIMATION SpinChecker%(1), ANIMATE, FORWARDLOOP '                        turn on auto-animation for red spinning checker
    CellImage% = SPRITENEW(CheckerSheet%, 73, SAVE) '                              create the game board cell sprite
    CellBlank% = SPRITENEW(CheckerSheet%, 74, DONTSAVE) '                          create sprite containing blank background
    MarqueeChecker%(0) = SPRITENEW(CheckerSheet%, 1, DONTSAVE) '                   black checker for use in marquee
    MarqueeChecker%(1) = SPRITENEW(CheckerSheet%, 37, DONTSAVE) '                  red checker for use in marquee
    Click& = _SndOpen("click.wav", "VOL,SYNC") '                                   sound of checker hitting another checker
    Drop& = _SndOpen("firstdrop.wav", "VOL,SYNC") '                                sound of checker hitting game board rack
    Slide& = _SndOpen("slide.wav", "VOL,SYNC") '                                   sound of checker sliding down game board rack
    TitleMusic& = _SndOpen("title.mid", "VOL") '                                   music that plays during title sequence
    GameMusic& = _SndOpen("music.ogg", "VOL,SYNC") '                               music that plays during game
    MenuMusic& = _SndOpen("menu.ogg", "VOL,SYNC") '                                music that plays during menu
    Win&(0) = _SndOpen("win1.ogg", "VOL,SYNC") '                                   audience applause sound 1
    Win&(1) = _SndOpen("win2.ogg", "VOL,SYNC") '                                   audience applause sound 2
    Lose& = _SndOpen("lose.ogg", "VOL,SYNC") '                                     audience not happy sound
    _SndVol GameMusic&, .5 '                                                       set game music volume to 50%
    SPRITEZOOM MarqueeChecker%(0), 20 '                                            zoom black checker out 80%
    SPRITEZOOM MarqueeChecker%(1), 20 '                                            zoom red checker out 80%
    If _FileExists("options.4ir") Then '                                           does the options file exist?
        Open "options.4ir" For Input As #1 '                                       yes, open it
        Input #1, GameLevel% '                                                     get save game level
        Input #1, SoundOption% '                                                   get saved sound option
        Input #1, MusicOption% '                                                   get saved music option
        Close #1 '                                                                 close the options file
    Else '                                                                         no
        Open "options.4ir" For Output As #1 '                                      create the options file
        Print #1, 2 '                                                              set level of game play to 2
        Print #1, TRUE '                                                           set sounds to on
        Print #1, TRUE '                                                           set music to on
        Close #1
    End If

    '******************************************************************************
End Sub

'******************************************************************************
'* The game utilizes my sprite library                                        *
'*                                                                            *
'$INCLUDE:'sprite.bi'
'*                                                                            *
'******************************************************************************

