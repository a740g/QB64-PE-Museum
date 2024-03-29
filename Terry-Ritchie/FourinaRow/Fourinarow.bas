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

$UNSTABLE:MIDI
$MIDISOUNDFONT:DEFAULT
OPTION _EXPLICIT

'******************************************************************************
'* The game utilizes my sprite library                                        *
'*                                                                            *
'$INCLUDE:'spritetop.bi'
'*                                                                            *
'******************************************************************************

CONST FALSE = 0, TRUE = NOT FALSE
CONST BLACK = 0, RED = 1, EMPTY = 2 '                                          player and checkers on board flags
CONST HUMAN = -1 '                                                             tells checker drop routine human is dropping checker
CONST FULL = -32767 '                                                          used to indicate a full column of checkers
CONST MAX = 1000000 '                                                          maximum score for min/max recursive routine

TYPE CELL '                                                                    used to keep track of graphics characteristics of board
    x AS INTEGER '                                                             x location of graphics cell
    y AS INTEGER '                                                             y location of graphics cell
    c AS INTEGER '                                                             color of checker in cell (0 = black, 1 = red, 2 = none)
    f AS INTEGER '                                                             which side of checker is facing (0 = front, 1 = back)
END TYPE

REDIM BoardStack%(0, 6, 5) '                                                   game board stack holding past board states
DIM CheckerSheet% '                                                            sprite sheet containing checker images
DIM MenuSheet% '                                                               sprite sheet containing menu options
DIM Menu%(4, 1) '                                                              handles holding menu option graphics
DIM MenuY%(4) '                                                                menu graphic vertical locations
DIM Cell(6, 5) AS CELL '                                                       graphics setup of game board
DIM WinCells%(3, 1) '                                                          location of four checkers in a row on board
DIM LastRow% '                                                                 remembers last row checker dropped into
DIM LastColumn% '                                                              remembers last column checker dropped into
DIM CheckersDropped% '                                                         number of checkers dropped in game
DIM ColumnVal&(6) '                                                            column scores
DIM Winner%(3) '                                                               sprites containing banner messages
DIM WinSpin%(1, 3) '                                                           sprites containing winning spinning checkers
DIM SoundOption% '                                                             determines if sound turned on/off
DIM MusicOption% '                                                             determines if music turned on/off
DIM MenuMusic& '                                                               handle containing menu music
DIM Win&(1) '                                                                  handles containing winning applause sounds
DIM Lose& '                                                                    handle containing losing sound
DIM Board%(6, 5) '                                                             the current board state
DIM Options%(4, 5) '                                                           sprites containing the options menu
DIM Depth% '                                                                   the depth of look ahead recursive min/max on
DIM Checker%(2, 1) '                                                           handles holding static checker images
DIM SpinChecker%(1) '                                                          handles holding black and red spinning checker images
DIM MarqueeChecker%(1) '                                                       handles holding small checkers for marquee
DIM board& '                                                                   handle holding image of game board
DIM CellImage% '                                                               handle holding sprite image of single cell on board
DIM CellBlank% '                                                               handle holding sprite image of blue background box
DIM Click& '                                                                   handle holding click sound of checker hitting chekcer
DIM Drop& '                                                                    handle holding drop sound of first checker being dropped
DIM Slide& '                                                                   handle holding sliding sound of checker dropping
DIM TitleMusic& '                                                              handle holding title music used in intro sequence
DIM GameMusic& '                                                               handle holding game music
DIM TitleMode% '                                                               flag telling other routines when title sequence running
DIM MenuImage& '                                                               handle holding image of menu screen
DIM MenuOption% '                                                              the menu option selected
DIM GameOver% '                                                                flag to set when game is over
DIM GameLevel% '                                                               level of game play chosen by player

'******************************************************************************
'*                                                                            *
'* Main program loop                                                          *
'*                                                                            *
'******************************************************************************

CreateAssets '                                                                 Create the games graphics and sounds
InitializeVariables '                                                          set variables to initial state
TitleSequence '                                                                display the title sequence
DO
    IF MusicOption% AND NOT _SNDPLAYING(MenuMusic&) THEN _SNDLOOP MenuMusic&
    MenuOption% = MainMenu% '                                                  get the menu option player selects
    IF MenuOption% = 4 THEN SYSTEM '                                           player has chosen to quit
    IF MenuOption% = 3 THEN SetOptions '                                       player has chosen to change/display options
    IF MenuOption% < 3 THEN '                                                  player has chosen to play a game
        IF MusicOption% THEN _SNDSTOP MenuMusic&
        NewGame '                                                              set game variables to initial state
        DrawBoard '                                                            draw the game board
        IF MusicOption% THEN _SNDLOOP GameMusic&
        IF MenuOption% = 2 THEN '                                              player chose 2 player game
            DO
                MoveChecker BLACK, HUMAN '                                     allow player 1 to make move
                CheckersDropped% = CheckersDropped% + 1 '                      increment dropped checker counter
                StackInit '                                                    save the state of board in stack
                IF CheckFour% = BLACK THEN GameOver% = TRUE '                  if player got 4 in row then game over
                IF NOT GameOver% THEN '                                        is the game over?
                    MoveChecker RED, HUMAN '                                   no, allow player 2 to make move
                    CheckersDropped% = CheckersDropped% + 1 '                  increment dropped checker counter
                    StackInit '                                                save the state of board in stack
                    IF CheckFour% = RED THEN GameOver% = TRUE '                if player got 4 in row then game over
                END IF
            LOOP UNTIL GameOver% OR CheckersDropped% = 42 '                    keep playing until win/lose/draw
        ELSE '                                                                 player chose 1 player game
            DO
                MoveChecker BLACK, HUMAN '                                     allow player 1 to make move
                CheckersDropped% = CheckersDropped% + 1 '                      increment dropped checker counter
                StackInit '                                                    save the state of board in stack
                IF CheckFour% = BLACK THEN GameOver% = TRUE '                  if player got 4 in row then game over
                IF NOT GameOver% THEN MoveChecker RED, BestMove% '             if game not over allow computer to make move
                CheckersDropped% = CheckersDropped% + 1 '                      increment dropped checker counter
            LOOP UNTIL GameOver% OR CheckersDropped% = 42 '                    keep playing until win/lose/draw
        END IF
        IF MusicOption% THEN _SNDSTOP GameMusic& '                             stop game music if necessary
    END IF
    IF GameOver% OR CheckersDropped% = 42 THEN '                               game over?
        ShowWinner '                                                           show the winner or draw
        GameOver% = FALSE '                                                    yes, reset game over flag
    END IF
LOOP

'******************************************************************************

SUB PushState ()
    '******************************************************************************
    '*                                                                            *
    '* Pushes the state of the playing board onto the LIFO stack                  *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     row counter
    DIM Column% '                                                                  column counter

    SHARED Board%()
    SHARED BoardStack%()
    SHARED Depth%

    Depth% = UBOUND(BoardStack%) + 1 '                                             get new upper stack limit
    REDIM _PRESERVE BoardStack%(Depth%, 6, 5) '                                    increase stack array
    FOR Column% = 0 TO 6 '                                                         cycle through all columns
        FOR Row% = 0 TO 5 '                                                        cycle through all rows
            BoardStack%(Depth%, Column%, Row%) = Board%(Column%, Row%) '           copy current board state to stack array
        NEXT Row%
    NEXT Column%

    '******************************************************************************
END SUB

SUB PopState ()
    '******************************************************************************
    '*                                                                            *
    '* Pops the previous state of the playing board from the LIFO stack           *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     row counter
    DIM Column% '                                                                  column counter

    SHARED Board%()
    SHARED BoardStack%()
    SHARED Depth%

    FOR Column% = 0 TO 6 '                                                         cycle through all columns
        FOR Row% = 0 TO 5 '                                                        cycle through all rows
            Board%(Column%, Row%) = BoardStack%(Depth%, Column%, Row%) '           get previous board state from stack array
        NEXT Row%
    NEXT Column%
    Depth% = UBOUND(BoardStack%) - 1 '                                             get new upper stack limit
    REDIM _PRESERVE BoardStack%(Depth%, 6, 5) '                                    decrease stack array

    '******************************************************************************
END SUB

SUB StackInit ()
    '******************************************************************************
    '*                                                                            *
    '* Initializes the stack with current playing board information               *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     row counter
    DIM Column% '                                                                  column counter

    SHARED Board%()
    SHARED Cell() AS CELL
    SHARED Depth%
    SHARED BoardStack%()

    REDIM BoardStack%(0, 6, 5) '                                                   clear stack

    Depth% = 0 '                                                                   keep track of how deep stack is
    FOR Column% = 0 TO 6 '                                                         cycle through all columns
        FOR Row% = 0 TO 5 '                                                        cycle through all rows
            Board%(Column%, Row%) = Cell(Column%, Row%).c '                        get current playing board state
        NEXT Row%
    NEXT Column%

    '******************************************************************************
END SUB

FUNCTION BoardDrop% (Player%, DropColumn%)
    '******************************************************************************
    '*                                                                            *
    '* Drops a checker into current board and returns the row number checker was  *
    '* dropped into or -1 if the column is full.                                  *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     row counter

    SHARED Board%()

    Row% = 0 '                                                                     start at bottom row
    IF Board%(DropColumn%, 5) <> EMPTY THEN '                                      is the top row empty?
        BoardDrop% = -1 '                                                          no, set function to return column is full
        EXIT FUNCTION '                                                            leave function
    ELSE '                                                                         yes, the top row is empty
        DO WHILE Board%(DropColumn%, Row%) <> EMPTY '                              is this board position empty?
            Row% = Row% + 1 '                                                      no, go to next row
        LOOP
        Board%(DropColumn%, Row%) = Player% '                                      put the player's checker here
    END IF
    BoardDrop% = Row% '                                                            set function to return the row checker dropped into

    '******************************************************************************
END FUNCTION

SUB NewGame ()
    '******************************************************************************
    '*                                                                            *
    '* Set conditions for a new game                                              *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     current cell row
    DIM Column% '                                                                  current cell column

    SHARED Cell() AS CELL
    SHARED GameOver%
    SHARED CheckersDropped%

    GameOver% = FALSE '                                                            reset game over flag
    CheckersDropped% = 0 '                                                         no checkers dropped yet
    FOR Column% = 0 TO 6 '                                                         cycle through all cell columns
        FOR Row% = 0 TO 5 '                                                        cycle through all cell rows
            Cell(Column%, Row%).c = EMPTY '                                        set spot on board to empty
        NEXT Row%
    NEXT Column%

    '******************************************************************************
END SUB

SUB SetOptions ()
    '******************************************************************************
    '*                                                                            *
    '* Set the game options                                                       *
    '*                                                                            *
    '******************************************************************************

    DIM Selection% '                                                               current menu selection
    DIM Mcount% '                                                                  marquee counter
    DIM ClearBuffer$ '                                                             clear keyboard input
    DIM KeyPress$ '                                                                key user pressed
    DIM SelectionMade% '                                                           true when finished with options

    SHARED Options%()
    SHARED GameLevel%
    SHARED MenuY%()
    SHARED SoundOption%
    SHARED MusicOption%
    SHARED SpinChecker%()
    SHARED MenuMusic&

    Selection% = 1 '                                                               start with first menu entry
    SelectionMade% = FALSE '                                                       stay in loop until options set
    SPRITESTAMP 349, MenuY%(1), Options%(1, 0) '                                   show 'Difficulty'
    SPRITESTAMP 349, MenuY%(2), Options%(2, GameLevel%) '                          show '1 2 3 4 5'
    SPRITESTAMP 349, MenuY%(3), Options%(3, ABS(SoundOption%)) '                   show 'Sound On Off'
    SPRITESTAMP 349, MenuY%(4), Options%(4, ABS(MusicOption%)) '                   show 'Music On Off'
    DO
        _LIMIT 36 '                                                                limit loop to 36 frames per second
        IF Selection% = 1 THEN '                                                   currently on difficulty?
            SPRITESTAMP 349, MenuY%(1), Options%(1, 1) '                           yes, show highlighted
        ELSE '                                                                     no
            SPRITESTAMP 349, MenuY%(1), Options%(1, 0) '                           show unhighlighted
        END IF
        SPRITESTAMP 349, MenuY%(2), Options%(2, GameLevel%) '                      show which level currently chosen
        IF Selection% = 2 THEN '                                                   currently on sound?
            SPRITESTAMP 349, MenuY%(3), Options%(3, ABS(SoundOption%) + 2) '       yes, show correct highlighted version
        ELSE '                                                                     no
            SPRITESTAMP 349, MenuY%(3), Options%(3, ABS(SoundOption%)) '           show correct unhighlighted version
        END IF
        IF Selection% = 3 THEN '                                                   currently on music?
            SPRITESTAMP 349, MenuY%(4), Options%(4, ABS(MusicOption%) + 2) '       yes, show correct highlighted version
        ELSE '                                                                     no
            SPRITESTAMP 349, MenuY%(4), Options%(4, ABS(MusicOption%)) '           show correct unhighlighted version
        END IF
        SPRITEPUT 62, MenuY%(1), SpinChecker%(1) '                                 place red spinning checker on screen
        SPRITEPUT 636, MenuY%(1), SpinChecker%(0) '                                place black spinning checker on screen
        Mcount% = Mcount% + 1 '                                                    increment the marquee counter
        IF Mcount% = 9 THEN '                                                      time to update the marquee (4 times per second)
            Mcount% = 1 '                                                          yes, reset the marquee counter
            Marquee '                                                              update the marquee
        END IF
        _DISPLAY '                                                                 show all graphic updates on screen
        DO
            ClearBuffer$ = INKEY$ '                                                get key in buffer
            IF ClearBuffer$ <> "" THEN KeyPress$ = UCASE$(ClearBuffer$) '          save the last key pressed
        LOOP UNTIL ClearBuffer$ = "" '                                             keep looping until the buffer cleared
        IF LEN(KeyPress$) > 1 THEN KeyPress$ = RIGHT$(KeyPress$, 1) '              strip control character from player input
        SELECT CASE KeyPress$ '                                                    which key was pressed?
            CASE CHR$(72) '                                                        up arrow key has been pressed
                Selection% = Selection% - 1 '                                      decrement the menu selection
                IF Selection% < 1 THEN Selection% = 1 '                            if too low set to minimum
            CASE CHR$(80) '                                                        down arrow key has been pressed
                Selection% = Selection% + 1 '                                      increment the menu selection
                IF Selection% > 3 THEN Selection% = 3 '                            if too high set to maximum
            CASE CHR$(77) '                                                        right arrow key has been pressed
                IF Selection% = 1 THEN '                                           currently on difficulty?
                    GameLevel% = GameLevel% + 1 '                                  yes, increment game play level
                    IF GameLevel% = 6 THEN GameLevel% = 5 '                        if too high set to max
                ELSEIF Selection% = 2 THEN '                                       currently on sound?
                    SoundOption% = NOT SoundOption% '                              yes, invert sound option
                ELSEIF Selection% = 3 THEN '                                       currently on music?
                    MusicOption% = NOT MusicOption% '                              yes, invert music option
                END IF
            CASE CHR$(75) '                                                        left arrow key has been pressed
                IF Selection% = 1 THEN '                                           currently on difficulty?
                    GameLevel% = GameLevel% - 1 '                                  yes, decrement game play level
                    IF GameLevel% = 0 THEN GameLevel% = 1 '                        if too low set to minimum
                ELSEIF Selection% = 2 THEN '                                       currently on sound?
                    SoundOption% = NOT SoundOption% '                              yes, invert sound option
                ELSEIF Selection% = 3 THEN '                                       currently on music?
                    MusicOption% = NOT MusicOption% '                              yes, invert music option
                END IF
            CASE CHR$(13), CHR$(27) '                                              enter or ESC key has been pressed
                SelectionMade% = TRUE '                                            set selection made flag to true
        END SELECT
        KeyPress$ = "" '                                                           reset keyboard input string
    LOOP UNTIL SelectionMade% '                                                    keep looping until options set
    IF _SNDPLAYING(MenuMusic&) AND NOT MusicOption% THEN _SNDSTOP MenuMusic&
    IF NOT _SNDPLAYING(MenuMusic&) AND MusicOption% THEN _SNDLOOP MenuMusic&
    OPEN "options.4ir" FOR OUTPUT AS #1 '                                          open options file
    PRINT #1, GameLevel% '                                                         save game level
    PRINT #1, SoundOption% '                                                       save sound option
    PRINT #1, MusicOption% '                                                       save music option
    CLOSE #1 '                                                                     close options file

    '******************************************************************************
END SUB

FUNCTION BestMove% ()
    '******************************************************************************
    '*                                                                            *
    '* Computer will pick best move                                               *
    '*                                                                            *
    '******************************************************************************

    DIM Column% '                                                                  column counter
    DIM Row% '                                                                     row checker dropped in
    DIM BestColumn% '                                                              column with best score
    DIM BestWorst& '                                                               comparison from one check to next
    DIM Goodness& '                                                                the score a checker drop ultimately receives
    DIM CurrentRow$ '                                                              string to hold string representation of a row
    DIM RowBelow$ '                                                                string to hold string representation of the row below
    DIM Look%

    SHARED Cell() AS CELL
    SHARED Board%()
    SHARED GameOver%
    SHARED CheckersDropped%
    SHARED ColumnVal&()
    SHARED GameLevel%

    BestColumn% = -1 '                                                             initialize column with best score
    BestWorst& = -MAX '                                                            start out with lowest possible score

    '** --------------------------------------------------------------
    '** Place a computer checker in each column and see if it's a win.
    '** If not evaluate the drop and return a score.
    '** --------------------------------------------------------------

    StackInit '                                                                    initialize the stack to equal what board looks like
    IF Board%(3, 0) = EMPTY THEN '                                                 is center bottom position free?
        BestMove% = 3 '                                                            yes, take it
        EXIT FUNCTION '                                                            leave function
    END IF
    FOR Column% = 0 TO 6 '                                                         cycle through all 7 columns
        StackInit '                                                                initialize the stack to equal what board looks like
        Row% = BoardDrop%(RED, Column%) '                                          simulate a dropped checker
        IF Row% > -1 THEN '                                                        was the column full?
            IF CheckFour% = RED THEN '                                             no, did computer get four in a row?
                BestMove% = Column% '                                              yes, return the winning column
                GameOver% = TRUE '                                                 game will be over after the move
                EXIT FUNCTION '                                                    leave function with winning move
            END IF
        END IF
    NEXT Column%
    FOR Column% = 0 TO 6
        StackInit '                                                                initialize the stack to equal what board looks like
        Row% = BoardDrop%(BLACK, Column%) '                                        simulate a dropped checker
        IF Row% > -1 THEN '                                                        was the column full?
            IF CheckFour% = BLACK THEN '                                           no, did human get four in a row?
                BestMove% = Column% '                                              yes, return the column to block
                EXIT FUNCTION '                                                    leave function with blocking move
            END IF
        END IF
    NEXT Column%

    '*** ------------------------------------------------------------------------------------------
    '*** check to see if human is setting up for 3 checkers in a row and blank space on either side
    '*** ------------------------------------------------------------------------------------------

    StackInit '                                                                    initialize the stack to equal what board looks like
    FOR Row% = 0 TO 5 '                                                            cycle through all rows
        CurrentRow$ = "" '                                                         clear current row string
        IF Row% > 0 THEN '                                                         currently on row 0?
            RowBelow$ = "" '                                                       no, reset row below string
        ELSE '                                                                     yes, currently on row 0
            RowBelow$ = "0000000" '                                                create a dummy row below for now
        END IF
        FOR Column% = 0 TO 6 '                                                     cycle through all columns
            CurrentRow$ = CurrentRow$ + LTRIM$(STR$(Board%(Column%, Row%))) '      create string representation of current row
            IF Row% > 0 THEN RowBelow$ = RowBelow$ + LTRIM$(STR$(Board%(Column%, Row% - 1))) ' create string representation of row below
        NEXT Column%
        Look% = INSTR(CurrentRow$, "22002") '                                      look for 2 black checkers set up for win
        IF Look% > 0 THEN '                                                        does the row contain 2 black checkers set up for win?
            IF MID$(RowBelow$, Look%, 1) <> "2" AND MID$(RowBelow$, Look% + 1, 1) <> "2" AND MID$(RowBelow$, Look% + 4, 1) <> "2" THEN
                RANDOMIZE TIMER '                                                  seed generator if previous statement said to block
                SELECT CASE INT(RND(1) * 3) + 1 '                                  pick a random column to drop into
                    CASE 1
                        BestMove% = Look% - 1
                        EXIT FUNCTION
                    CASE 2
                        BestMove% = Look%
                        EXIT FUNCTION
                    CASE 3
                        BestMove% = Look% + 3
                        EXIT FUNCTION
                END SELECT
            END IF
        END IF
        Look% = INSTR(CurrentRow$, "20022") '                                      look for 2 black checkers set up for win
        IF Look% > 0 THEN '                                                        does the row contain 2 black checkers set up for win?
            IF MID$(RowBelow$, Look%, 1) <> "2" AND MID$(RowBelow$, Look% + 3, 1) <> "2" AND MID$(RowBelow$, Look% + 4, 1) <> "2" THEN
                RANDOMIZE TIMER '                                                  seed generator if previous statement said to block
                SELECT CASE INT(RND(1) * 3) + 1 '                                  pick a random column to drop into
                    CASE 1
                        BestMove% = Look% - 1
                        EXIT FUNCTION
                    CASE 2
                        BestMove% = Look% + 2
                        EXIT FUNCTION
                    CASE 3
                        BestMove% = Look% + 3
                        EXIT FUNCTION
                END SELECT
            END IF
        END IF
    NEXT Row%
    _TITLE "Thinking ..." '                                                        let player know computer is thinking
    FOR Column% = 0 TO 6 '                                                         cycle through all columns
        StackInit '                                                                initialize the state of the stack
        ColumnVal&(Column%) = 0 '                                                  set the column score to 0
        Row% = BoardDrop%(RED, Column%) '                                          drop a red checker into current column
        CheckersDropped% = CheckersDropped% + 1 '                                  keep track of how many checkers dropped
        IF Row% > -1 THEN '                                                        was the drop successful?
            PushState '                                                            yes, save state of board
            Row% = BoardDrop%(BLACK, Column%) '                                    drop a black checker in same column
            IF Row% > -1 THEN '                                                    was the column full?
                IF CheckFour% = BLACK THEN '                                       no, did the human get four in a row?
                    Goodness& = -MAX '                                             yes, avoid this column!
                ELSE '                                                             the column was full
                    PopState '                                                     restore the state of the board
                    Evaluate RED, GameLevel% * 2 '                                 simulate game being played
                    Goodness& = ColumnVal&(Column%) '                              get this column's score
                END IF
            END IF
            IF Goodness& > BestWorst& THEN '                                       is score the best seen?
                BestWorst& = Goodness& '                                           yes, remember this score
                BestColumn% = Column% '                                            this column is best so far
            ELSEIF Goodness& = BestWorst& THEN '                                   does this column equal another for best?
                RANDOMIZE TIMER '                                                  seed random number generator
                IF (INT(RND(1) * 10) + 1) > 5 THEN BestColumn% = Column% '         select between the two randomly
            END IF
        END IF
        CheckersDropped% = CheckersDropped% - 1 '                                  decrement the dropped checkers counter
    NEXT Column%
    _TITLE "Game in progress!"
    BestMove% = BestColumn% '                                                      return the best column to drop checker in

    '******************************************************************************
END FUNCTION

SUB Evaluate (Player%, Level%)
    '******************************************************************************
    '*                                                                            *
    '* Recursively evaluate various checker drops                                 *
    '* Warning!: hair pulling zone ahead!                                         *
    '*                                                                            *
    '******************************************************************************

    DIM Column% '                                                                  column counter
    DIM Row% '                                                                     row checker dropped in (not used for any evaluation)

    SHARED Depth%
    SHARED Board%()
    SHARED CheckersDropped%
    SHARED ColumnVal&()

    IF Level% = Depth% - 1 THEN '                                                  have we reached the depth of forward looking checks?
        EXIT SUB '                                                                 leave function
    ELSEIF CheckersDropped% = 42 THEN
        EXIT SUB
    ELSE '                                                                         move onto next simulated checker drop
        FOR Column% = 0 TO 6 '                                                     cycle through all 7 columns
            IF Board%(Column%, 5) = EMPTY THEN '                                   is this column full?
                PushState '                                                        no, save the state of the current board
                Row% = BoardDrop%(1 - Player%, Column%) '                          drop other player's checker into this column
                CheckersDropped% = CheckersDropped% + 1 '                          increment checker drop counter
                IF Player% = RED THEN
                    ColumnVal&(Column%) = ColumnVal&(Column%) - GoodnessOf&(1 - Player%, Column%, Row%)
                ELSE
                    ColumnVal&(Column%) = ColumnVal&(Column%) + GoodnessOf&(1 - Player%, Column%, Row%)
                END IF
                Evaluate 1 - Player%, Level% '                                     evaluate other player's checker drop
                CheckersDropped% = CheckersDropped% - 1 '                          decrememnt checker drop counter
                PopState '                                                         restore the previous state of the board
            END IF
        NEXT Column%
    END IF

    '******************************************************************************
END SUB

FUNCTION GoodnessOf& (Player%, Pcolumn%, Prow%)
    '******************************************************************************
    '*                                                                            *
    '* Examines the current state of the board for a given player and returns a   *
    '* score based on that examination.                                           *
    '*                                                                            *
    '* This is needs work.                                                        *
    '*                                                                            *
    '******************************************************************************

    DIM Score& '                                                                   the score this checker receives
    DIM Count% '                                                                   generic counter
    DIM Count2% '                                                                  another generic counter
    DIM Inarow% '                                                                  how many in a row is made by this checker
    DIM Importance% '                                                              the imprtance of this move based on look-ahead depth
    DIM StartColumn% '                                                             starting column for diagonal checks
    DIM StartRow% '                                                                starting row for diagnoal checks
    DIM NextRow% '                                                                 row counter used in diagonal checks
    DIM Greatest% '                                                                used to save greatest n in a row seen
    DIM Least% '                                                                   used to determine where to start diagnoal checks

    SHARED Board%()
    SHARED GameLevel%
    SHARED Depth%

    Importance% = GameLevel% * 2 - Depth% '                                        calculate the importance of this checker
    Score& = 0 '                                                                   reset score value

    IF Prow% > 0 THEN '                                                            is this checker sitting on another?

        '*** --------------------------------------
        '*** check player connecting vertical score
        '*** --------------------------------------

        Inarow% = 1 '                                                              yes, current checker counts for 1
        FOR Count% = Prow% - 1 TO 0 STEP -1 '                                      cycle from the row below to bottom of board
            IF Board%(Pcolumn%, Count%) = Player% THEN '                           does this checker match the player's checker?
                Inarow% = Inarow% + 1 '                                            yes, increment the in a row counter
            ELSE '                                                                 no, this is the other player's checker
                EXIT FOR '                                                         no need to check further
            END IF
        NEXT Count%
        Score& = Score& + Inarow% * Importance% '                                  add to score based on how many in a row seen

        '*** ------------------------------------
        '*** check player blocking vertical score
        '*** ------------------------------------

        Inarow% = 1 '                                                              current checker counts for 1 (assume other player)
        FOR Count% = Prow% - 1 TO 0 STEP -1 '                                      cycle from the row below to bottom of board
            IF Board%(Pcolumn%, Count%) = 1 - Player% THEN '                       does this checker match the ohter player's checker?
                Inarow% = Inarow% + 1 '                                            yes, increment the in a row counter
            ELSE '                                                                 no, this is the player's checker
                EXIT FOR '                                                         no need to check further
            END IF
        NEXT Count%
        Score& = Score& + Inarow% * Importance% '                                  add to score based on how many in a row seen
    END IF

    StartColumn% = Pcolumn% - 3 '                                                  leftmost column possible for this checker
    IF StartColumn% < 0 THEN StartColumn% = 0 '                                    make sure to stay at left side of board if breached

    '*** ----------------------------------------
    '*** check player connecting horizontal score
    '*** ----------------------------------------

    Greatest% = 0 '                                                                greatest n in a row seen so far
    FOR Count% = StartColumn% TO Pcolumn% '                                        cycle from leftmost column to current column
        Inarow% = 0 '                                                              reset the in a row counter
        FOR Count2% = Count% TO Count% + 3 '                                       cycle through next 4 columns
            IF Count2% > 6 THEN EXIT FOR '                                         no need to check further if right side of board reached
            IF Board%(Count2%, Prow%) = Player% THEN '                             does this checker match the player's checker?
                Inarow% = Inarow% + 1 '                                            yes, increment the in a row counter
            ELSE '                                                                 no, this is the other player's checker or a blank spot
                Inarow% = 0 '                                                      reset the four in a row counter
            END IF
        NEXT Count2%
        IF Inarow% > Greatest% THEN Greatest% = Inarow% '                          save the largest in a row seen so far
    NEXT Count%
    Score& = Score& + Greatest% * Importance% '                                    add to score based on how many in a row seen

    '*** --------------------------------------
    '*** check player blocking horizontal score
    '*** --------------------------------------

    Greatest% = 0 '                                                                greatest n in a row seen so far
    FOR Count% = StartColumn% TO Pcolumn% '                                        cycle from leftmost column to current column
        Inarow% = 0 '                                                              reset the in a row counter
        FOR Count2% = Count% TO Count% + 3 '                                       cycle through next 4 columns
            IF Count2% > 6 THEN EXIT FOR '                                         no need to check further if right side of board reached
            IF Count2% <> Pcolumn% THEN '                                          is this the checker that was dropped?
                IF Board%(Count2%, Prow%) = 1 - Player% THEN '                     no, does this checker match the other player's checker
                    Inarow% = Inarow% + 1 '                                        yes, increment the in a row counter
                ELSE '                                                             no, this is the player's checker or a blank spot
                    Inarow% = 0 '                                                  reset the in a row counter
                END IF
            ELSE '                                                                 yes, this is the checker that was dropped
                Inarow% = Inarow% + 1 '                                            treat it as the other player's checker for now
            END IF
        NEXT Count2%
        IF Inarow% > Greatest% THEN Greatest% = Inarow% '                          save the largest in a row seen so far
    NEXT Count%
    Score& = Score& + Greatest% * Importance% '                                    add to score based on how many in a row seen

    IF Pcolumn% <= Prow% THEN '                                                    is the column number = or < the row number?
        Least% = Pcolumn% '                                                        yes, save this as the smallest number
    ELSE '                                                                         no, row number is < the column number
        Least% = Prow% '                                                           save this as the smallest number
    END IF
    IF Least% > 3 THEN Least% = 3 '                                                only need to diagonally check back three places
    StartColumn% = Pcolumn% - Least% '                                             compute the starting column
    StartRow% = Prow% - Least% '                                                   compute the starting row

    IF StartRow% < 3 AND StartColumn% < 4 THEN '                                   is four in a row / diagonally possible here?

        '*** ----------------------------------------
        '*** check player connecting / diagonal score
        '*** ----------------------------------------

        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        FOR Count% = StartColumn% TO Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            FOR Count2% = Count% TO Count% + 3 '                                   cycle through next 4 columns
                IF (Count2% > 6) OR (NextRow% > 5) THEN EXIT FOR '                 no need to check further if top or right side of board hit
                IF Board%(Count2%, NextRow%) = Player% THEN '                      does this checker match the player's checker?
                    Inarow% = Inarow% + 1 '                                        yes, increment the in a row counter
                ELSE '                                                             no, this is the other player's checker or a blank spot
                    Inarow% = 0 '                                                  reset the in a row counter
                END IF
                NextRow% = NextRow% + 1 '                                          increment the row counter
            NEXT Count2%
            StartRow% = StartRow% + 1 '                                            increment the starting row counter
            IF Inarow% > Greatest% THEN Greatest% = Inarow% '                      save the largest in a row seen so far
        NEXT Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen

        '*** --------------------------------------
        '*** check player blocking / diagonal score
        '*** --------------------------------------

        StartRow% = Prow% - Least% '                                               reset the starting row
        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        FOR Count% = StartColumn% TO Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            FOR Count2% = Count% TO Count% + 3 '                                   cycle through next 4 columns
                IF (Count2% > 6) OR (NextRow% > 5) THEN EXIT FOR '                 no need to check further if top or right side of board hit
                IF Count2% <> Pcolumn% AND NextRow% <> Prow% THEN '                is this the checker that was dropped?
                    IF Board%(Count2%, NextRow%) = 1 - Player% THEN '              no, does this checker match the other player's checker?
                        Inarow% = Inarow% + 1 '                                    yes, increment the in a row counter
                    ELSE '                                                         no, this is the player's checker or a blank spot
                        Inarow% = 0 '                                              reset the in a row counter
                    END IF
                ELSE '                                                             yes, this is the checker that was dropped
                    Inarow% = Inarow% + 1 '                                        treat it as the other player's checker for now
                END IF
                NextRow% = NextRow% + 1 '                                          increment the row counter
            NEXT Count2%
            StartRow% = StartRow% + 1 '                                            increment the starting row counter
            IF Inarow% > Greatest% THEN Greatest% = Inarow% '                      save the largest in a row seen so far
        NEXT Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen
    END IF

    IF Pcolumn% <= 5 - Prow% THEN '                                                is the column number = or < the row number from the top?
        Least% = Pcolumn% '                                                        yes, save this as the smallest number
    ELSE '                                                                         no, row number from top is < the column number
        Least% = 5 - Prow% '                                                       save this as the smallest number
    END IF
    IF Least% > 3 THEN Least% = 3 '                                                only need to diagonally check back three places
    StartColumn% = Pcolumn% - Least% '                                             compute the starting column
    StartRow% = Prow% + Least% '                                                   compute the starting row

    IF StartRow% > 2 AND StartColumn% < 4 THEN '                                   is four in a row \ diagonally possible here?

        '*** ----------------------------------------
        '*** check player connecting \ diagonal score
        '*** ----------------------------------------

        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        FOR Count% = StartColumn% TO Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            FOR Count2% = Count% TO Count% + 3 '                                   cycle through next 4 columns
                IF (Count2% > 6) OR (NextRow% < 0) THEN EXIT FOR '                 no need to check further if bottom or right side of board hit
                IF Board%(Count2%, NextRow%) = Player% THEN '                      does this checker match the player's checker?
                    Inarow% = Inarow% + 1 '                                        yes, increment the in a row counter
                ELSE '                                                             no, this is the other player's checker or a blank spot
                    Inarow% = 0 '                                                  reset the in a row counter
                END IF
                NextRow% = NextRow% - 1 '                                          decrement the row counter
            NEXT Count2%
            StartRow% = StartRow% - 1 '                                            decrement the starting row counter
            IF Inarow% > Greatest% THEN Greatest% = Inarow% '                      save the largest in a row seen so far
        NEXT Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen

        '*** --------------------------------------
        '*** check player blocking \ diagonal score
        '*** --------------------------------------

        StartRow% = Prow% + Least% '                                               reset the starting row
        Greatest% = 0 '                                                            yes, greatest n in a row seen so far
        FOR Count% = StartColumn% TO Pcolumn% '                                    cycle from leftmost column to current column
            Inarow% = 0 '                                                          reset the in a row counter
            NextRow% = StartRow% '                                                 set the row start on
            FOR Count2% = Count% TO Count% + 3 '                                   cycle through next 4 columns
                IF (Count2% > 6) OR (NextRow% < 0) THEN EXIT FOR '                 no need to check further if bottom or right side of board hit
                IF Count2% <> Pcolumn% AND NextRow% <> Prow% THEN '                is this the checker that was dropped?
                    IF Board%(Count2%, NextRow%) = 1 - Player% THEN '              no, does this checker match the other player's checker?
                        Inarow% = Inarow% + 1 '                                    yes, increment the in a row counter
                    ELSE '                                                         no, this is the player's checker or a blank spot
                        Inarow% = 0 '                                              reset the in a row counter
                    END IF
                ELSE '                                                             yes, this is the checker that was dropped
                    Inarow% = Inarow% + 1 '                                        treat it as the other player's checker for now
                END IF
                NextRow% = NextRow% - 1 '                                          decrement the row counter
            NEXT Count2%
            StartRow% = StartRow% - 1 '                                            decrement the starting row counter
            IF Inarow% > Greatest% THEN Greatest% = Inarow% '                      save the largest in a row seen so far
        NEXT Count%
        Score& = Score& + Greatest% * Importance% '                                add to score based on how many in a row seen
    END IF
    GoodnessOf& = Score& '                                                         return overall score

    '******************************************************************************
END FUNCTION

FUNCTION CheckFour% ()
    '******************************************************************************
    '*                                                                            *
    '* Checks for four checkers in a row on entire board and returns the player   *
    '* that achieved it or empty if no player has four in a row.                  *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     row counter
    DIM Column% '                                                                  column counter
    DIM FourCount% '                                                               four in a row counter
    DIM Count% '                                                                   counter used to test possible four in row spots
    DIM Player% '                                                                  the current player's checker being tested

    SHARED WinCells%()
    SHARED Board%()

    '** ------------------------------------------------------
    '** Check for 4 vertical checkers in a row on entire board
    '** ------------------------------------------------------
    FOR Column% = 0 TO 6 '                                                         cycle through all 7 columns
        FOR Row% = 0 TO 2 '                                                        cycle through first 3 rows
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            IF Player% = EMPTY THEN EXIT FOR '                                     move to next column, four in row impossible
            WinCells%(0, 0) = Column% '                                            save spot as potential first four in a row checker
            WinCells%(0, 1) = Row% '                                               save spot as potential first four in a row checker
            FourCount% = 1 '                                                       reset four in a row counter
            FOR Count% = 1 TO 3 '                                                  count through next three board positions
                IF Board%(Column%, Row% + Count%) = Player% THEN '                 does this position have a player checker in it?
                    WinCells%(Count%, 0) = Column% '                               yes, save spot as another potential four in a row checker
                    WinCells%(Count%, 1) = Row% + Count% '                         save spot as another potential four in a row checker
                    FourCount% = FourCount% + 1 '                                  increment four in a row counter
                END IF
            NEXT Count%
            IF FourCount% = 4 THEN '                                               were 4 board positions saved?
                CheckFour% = Player% '                                             yes, player has four in a row
                EXIT FUNCTION '                                                    leave function with result
            END IF
        NEXT Row%
    NEXT Column%
    '** --------------------------------------------------------
    '** Check for 4 horizontal checkers in a row on entire board
    '** --------------------------------------------------------
    FOR Row% = 0 TO 5 '                                                            cycle through all 6 rows
        FOR Column% = 0 TO 3 '                                                     cycle through first 4 columns
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            IF Player% <> EMPTY THEN '                                             skip, move to next column%
                WinCells%(0, 0) = Column% '                                        save spot as potential first four in a row checker
                WinCells%(0, 1) = Row% '                                           save spot as potential first four in a row checker
                FourCount% = 1 '                                                   reset four in a row counter
                FOR Count% = 1 TO 3 '                                              count through next three board positions
                    IF Board%(Column% + Count%, Row%) = Player% THEN '             does this position have a player checker in it?
                        WinCells%(Count%, 0) = Column% + Count% '                  yes, save spot as another potential four in a row checker
                        WinCells%(Count%, 1) = Row% '                              save spot as another potential four in a row checker
                        FourCount% = FourCount% + 1 '                              increment four in a row counter
                    END IF
                NEXT Count%
                IF FourCount% = 4 THEN '                                           were 4 board positions saved?
                    CheckFour% = Player% '                                         yes, player has four in a row
                    EXIT FUNCTION '                                                leave function with result
                END IF
            END IF
        NEXT Column%
    NEXT Row%
    '** --------------------------------------------------------
    '** Check for 4 diagonal / checkers in a row on entire board
    '** --------------------------------------------------------
    FOR Row% = 0 TO 2 '                                                            cycle through first 3 rows
        FOR Column% = 0 TO 3 '                                                     cycle through first 4 columns
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            IF Player% <> EMPTY THEN '                                             skip, move to next column%
                WinCells%(0, 0) = Column% '                                        save spot as potential first four in a row checker
                WinCells%(0, 1) = Row% '                                           save spot as potential first four in a row checker
                FourCount% = 1 '                                                   reset four in a row counter
                FOR Count% = 1 TO 3 '                                              count through next three board positions
                    IF Board%(Column% + Count%, Row% + Count%) = Player% THEN '    does this position have a player checker in it?
                        WinCells%(Count%, 0) = Column% + Count% '                  yes, save spot as another potential four in a row checker
                        WinCells%(Count%, 1) = Row% + Count% '                     save spot as another potential four in a row checker
                        FourCount% = FourCount% + 1 '                              increment four in a row counter
                    END IF
                NEXT Count%
                IF FourCount% = 4 THEN '                                           were 4 board positions saved?
                    CheckFour% = Player% '                                         yes, player has four in a row
                    EXIT FUNCTION '                                                leave function with result
                END IF
            END IF
        NEXT Column%
    NEXT Row%
    '** --------------------------------------------------------
    '** Check for 4 diagonal \ checkers in a row on entire board
    '** --------------------------------------------------------
    FOR Row% = 5 TO 3 STEP -1 '                                                    cycle through top 3 rows
        FOR Column% = 0 TO 3 '                                                     cycle through first 4 columns
            Player% = Board%(Column%, Row%) '                                      get checker at current position
            IF Player% <> EMPTY THEN '                                             skip, move to next column
                WinCells%(0, 0) = Column% '                                        save spot as potential first four in a row checker
                WinCells%(0, 1) = Row% '                                           save spot as potential first four in a row checker
                FourCount% = 1 '                                                   reset four in a row counter
                FOR Count% = 1 TO 3 '                                              count through next three board positions
                    IF Board%(Column% + Count%, Row% - Count%) = Player% THEN '    does this position have a player checker in it?
                        WinCells%(Count%, 0) = Column% + Count% '                  yes, save spot as another potential four in a row checker
                        WinCells%(Count%, 1) = Row% - Count% '                     save spot as another potential four in a row checker
                        FourCount% = FourCount% + 1 '                              increment four in a row counter
                    END IF
                NEXT Count%
                IF FourCount% = 4 THEN '                                           were 4 board positions saved?
                    CheckFour% = Player% '                                         yes, player has four in a row
                    EXIT FUNCTION '                                                leave function with result
                END IF
            END IF
        NEXT Column%
    NEXT Row%
    CheckFour% = EMPTY '                                                           return that no player has four in a row

    '******************************************************************************
END FUNCTION

SUB ShowWinner ()
    '******************************************************************************
    '*                                                                            *
    '* Show the winner of the previous game                                       *
    '*                                                                            *
    '******************************************************************************

    DIM Count% '                                                                   generic counter
    DIM Banner% '                                                                  the banner to show at top
    DIM Win% '                                                                     the winner of the game
    DIM x%, y%

    SHARED WinCells%()
    SHARED Cell() AS CELL
    SHARED Win&()
    SHARED Lose&
    SHARED Winner%()
    SHARED CheckersDropped%
    SHARED MenuOption%
    SHARED SoundOption%
    SHARED CellBlank%
    SHARED CellImage%
    SHARED WinSpin%()
    SHARED GameOver%

    _TITLE "Game Over!" '                                                          change window title
    Win% = Cell(WinCells%(0, 0), WinCells%(0, 1)).c '                              get the winner of the game
    IF CheckersDropped% = 42 AND NOT GameOver% THEN '                                  was maximum amount of checkers dropped?
        Banner% = 3 '                                                              yes, set banner to display a draw
        IF SoundOption% THEN _SNDPLAYCOPY Lose& '                                  play the audience not happy
        DO: LOOP UNTIL INKEY$ = "" '                                               clear keyboard buffer
        DO: LOOP UNTIL INKEY$ <> "" '                                              wait for a key to be pressed
        EXIT SUB '                                                                 leave subroutine
    ELSEIF Win% = 0 THEN '                                                         is the winner player 1?
        Banner% = 0 '                                                              yes, set banner to display player 1 win
        IF SoundOption% THEN _SNDPLAYCOPY Win&(0) '                                play audience clapping
    ELSEIF MenuOption% = 1 AND Win% = 1 THEN '                                     is the winner player 2 against the computer?
        Banner% = 2 '                                                              yes, set banner to display computer win
        IF SoundOption% THEN _SNDPLAYCOPY Lose& '                                  play the audience not happy
    ELSE '                                                                         player 2 wins against player 1
        Banner% = 1 '                                                              set banner to display player 2 win
        IF SoundOption% THEN _SNDPLAYCOPY Win&(1) '                                play audience clapping
    END IF
    FOR Count% = 1 TO 100 '                                                        cycle from 1 to 100
        SPRITEZOOM Winner%(Banner%), Count% '                                      set the zoom level of the banner
        SPRITESTAMP 349, 49, Winner%(Banner%) '                                    display the banner on screen at current zoom
        _DISPLAY '                                                                 show the changes on screen
    NEXT Count%
    FOR Count% = 0 TO 3 '                                                          cycle from 0 to 3
        x% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).x '                  get the x location of winning checker
        y% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).y '                  get the y location of winning checker
        SPRITESTAMP x%, y%, CellBlank% '                                           blank the current board spot
        SPRITESTAMP x%, y%, CellImage% '                                           place a clean cell there
        SPRITEZOOM WinSpin%(Win%, Count%), 90 '                                    zoom the winning spin checker to 90%
    NEXT Count%
    DO: LOOP UNTIL INKEY$ = "" '                                                   clear the keyboard buffer
    DO
        _LIMIT 36 '                                                                limit loop to 36 FPS
        FOR Count% = 0 TO 3 '                                                      cycle from 0 to 3
            x% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).x '              get the x location of winning checker
            y% = Cell(WinCells%(Count%, 0), WinCells%(Count%, 1)).y '              get the y location of winning checker
            SPRITEPUT x%, y%, WinSpin%(Win%, Count%) '                             place the winning spinning checker
        NEXT Count%
        _DISPLAY '                                                                 show the changes on screen
    LOOP UNTIL INKEY$ <> "" '                                                      keep looping until a key is pressed
    FOR Count% = 0 TO 3 '                                                          cycle from 0 to 3
        SPRITEPUT -100, -100, WinSpin%(Win%, Count%) '                             place winning spin checkers off screen for later use
    NEXT Count%

    '******************************************************************************
END SUB

FUNCTION MainMenu% ()
    '******************************************************************************
    '*                                                                            *
    '* The main menu                                                              *
    '*                                                                            *
    '******************************************************************************

    DIM Selection% '                                                               keep track of player menu selection
    DIM SelectionMade% '                                                           true when player has made a selection
    DIM KeyPress$ '                                                                which key is user pressing
    DIM Mcount% '                                                                  keep track of when to update marquee
    DIM ClearBuffer$

    SHARED MenuImage&
    SHARED MenuY%()
    SHARED Menu%()
    SHARED SpinChecker%()
    SHARED MenuMusic&
    SHARED MusicOption%

    _TITLE "Welcome to Four in a Row!" '                                           set the window title
    SPRITEPUT -100, -100, SpinChecker%(0) '                                        place black spinning checker sprite off screen for later use
    SPRITEPUT -100, -100, SpinChecker%(1) '                                        place red spinning chcker sprite off screen for later use.
    _PUTIMAGE (0, 0), MenuImage& '                                                 place saved image of menu screen on screen
    Selection% = 1 '                                                               reset player selection to first option
    SelectionMade% = FALSE '                                                       player has not made a selection yet
    Mcount% = 0 '                                                                  reset marquee update counter
    DO
        _LIMIT 36 '                                                                limit loop to 36 frames per second
        Mcount% = Mcount% + 1 '                                                    increment the marquee counter
        IF Mcount% = 9 THEN '                                                      time to update the marquee (4 times per second)
            Mcount% = 1 '                                                          yes, reset the marquee counter
            Marquee '                                                              update the marquee
        END IF
        DO
            ClearBuffer$ = INKEY$ '                                                get key in buffer
            IF ClearBuffer$ <> "" THEN KeyPress$ = UCASE$(ClearBuffer$) '          save the last key pressed
        LOOP UNTIL ClearBuffer$ = "" '                                             keep looping until the buffer cleared
        IF LEN(KeyPress$) > 1 THEN KeyPress$ = RIGHT$(KeyPress$, 1) '              strip control character from player input
        SELECT CASE KeyPress$ '                                                    which key was pressed?
            CASE CHR$(72) '                                                        up arrow key has been pressed
                Selection% = Selection% - 1 '                                      decrement the menu selection
                IF Selection% < 1 THEN '                                           has menu selection gone below 1?
                    Selection% = 1 '                                               yes, reset menu selection back to 1
                ELSE '                                                             meneu selection is within range
                    SPRITESTAMP 349, MenuY%(Selection%), Menu%(Selection%, 1) '    highlight new menu selection
                    SPRITESTAMP 349, MenuY%(Selection% + 1), Menu%(Selection% + 1, 0) ' remove highlight from former menu selection
                END IF
            CASE CHR$(80) '                                                        down arrow key has been pressed
                Selection% = Selection% + 1 '                                      increment the menu selection
                IF Selection% > 4 THEN '                                           has menu selection gone above 4?
                    Selection% = 4 '                                               yes, reset menu selection back to 4
                ELSE '                                                             menu selection is within range
                    SPRITESTAMP 349, MenuY%(Selection%), Menu%(Selection%, 1) '    highlight new menu selection
                    SPRITESTAMP 349, MenuY%(Selection% - 1), Menu%(Selection% - 1, 0) ' remove highlight from former menu selection
                END IF
            CASE CHR$(13) '                                                        enter key has been pressed
                SelectionMade% = TRUE '                                            set selection made flag to true
        END SELECT
        KeyPress$ = "" '                                                           reset keyboard input string
        SPRITEPUT 62, MenuY%(Selection%), SpinChecker%(1) '                        place red spinning checker on screen
        SPRITEPUT 636, MenuY%(Selection%), SpinChecker%(0) '                       place black spinning checker on screen
        _DISPLAY '                                                                 show all graphic updates on screen
    LOOP UNTIL SelectionMade% '                                                    keep looping until a selection has been made
    SPRITEPUT -100, -100, SpinChecker%(0) '                                        place black spinning checker sprite off screen for later use
    SPRITEPUT -100, -100, SpinChecker%(1) '                                        place red spinning chcker sprite off screen for later use.
    MainMenu% = Selection% '                                                       return the value of selection

    '******************************************************************************
END FUNCTION

SUB Marquee () STATIC
    '******************************************************************************
    '*                                                                            *
    '* Marquee                                                                    *
    '*                                                                            *
    '******************************************************************************

    DIM MainFlipFlop% '                                                            which checker color to start on
    DIM FlipFlop% '                                                                keep track of color as checkers drawn
    DIM count%

    SHARED CheckerSheet%
    SHARED MarqueeChecker%()

    MainFlipFlop% = 1 - MainFlipFlop% '                                            flip the start color value
    FlipFlop% = MainFlipFlop% '                                                    set the color tracker
    FOR count% = 10 TO 690 STEP 20 '                                               x location of checkers
        SPRITESTAMP count%, 10, MarqueeChecker%(FlipFlop%) '                       draw top row checker
        SPRITESTAMP count%, 210, MarqueeChecker%(FlipFlop%) '                      draw bottom row checker
        IF count% < 210 THEN '                                                     use x location as y location for vertical checkers
            SPRITESTAMP 10, count%, MarqueeChecker%(FlipFlop%) '                   draw left side checker
            SPRITESTAMP 690, count%, MarqueeChecker%(FlipFlop%) '                  draw right side checker
        END IF
        FlipFlop% = 1 - FlipFlop% '                                                flip the next checker color
    NEXT count%

    '******************************************************************************
END SUB

SUB MoveChecker (CheckerColor%, CPUColumn%)
    '******************************************************************************
    '*                                                                            *
    '* Moves the checker from column to column.                                   *
    '*                                                                            *
    '******************************************************************************

    DIM SpinCount% '                                                               keep track of which checker frame is showing
    DIM Column% '                                                                  the column spinning checker is at
    DIM ClearBuffer$ '                                                             clears the keyboard buffer
    DIM KeyPress$ '                                                                the key the player pressed
    DIM ColumnChosen% '                                                            true when player has chosen column
    DIM OldColumn% '                                                               the previous column spinning checker was at
    DIM CheckerDrop% '                                                             flag used to indicate when checker dropped
    DIM Face% '                                                                    indicates which side of checker to show
    DIM WaitTime% '                                                                time in between computer movements
    DIM NewWait% '                                                                 flag to indicate ok for computer to move
    DIM ComputerTurn% '                                                            flag indicating it's the computer's turn to move

    SHARED CellBlank%
    SHARED Cell() AS CELL
    SHARED SpinChecker%()
    SHARED TitleMode%

    RANDOMIZE TIMER '                                                              seed the random number generator
    SPRITESET SpinChecker%(0), 1 '                                                 reset black checker animation to beginning
    SPRITESET SpinChecker%(1), 37 '                                                reset red checker animation to beginning
    ComputerTurn% = FALSE '                                                        assume it is not computer's turn to move
    NewWait% = FALSE '                                                             assume it is not computer's turn to move
    ColumnChosen% = FALSE '                                                        no column chosen yet
    CheckerDrop% = FALSE '                                                         the checker has not been dropped yet
    SpinCount% = 1 '                                                               set to frame 1 of spinning animation
    Column% = ABS(TitleMode% * 3) + 3 '                                            where should spinning checker start
    OldColumn% = Column% '                                                         set previous column to the same
    IF CPUColumn% >= 0 THEN '                                                      is it the computer's turn to move?
        ComputerTurn% = TRUE '                                                     yes, set flag indicating this
        NewWait% = TRUE '                                                          set flag telling CPU ok to move
    END IF
    DO
        IF NOT ComputerTurn% THEN '                                                is it the computer's turn to move?
            DO '                                                                   no
                ClearBuffer$ = INKEY$ '                                            get key in buffer
                IF ClearBuffer$ <> "" THEN KeyPress$ = UCASE$(ClearBuffer$) '      save the last key pressed
            LOOP UNTIL ClearBuffer$ = "" '                                         keep looping until the buffer cleared
            IF LEN(KeyPress$) > 1 THEN KeyPress$ = RIGHT$(KeyPress$, 1) '          strip control character from player input
        ELSE '                                                                     computer's move
            IF NewWait% THEN '                                                     generate a random wait time?
                WaitTime% = INT(RND(1) * 20) + 9 '                                 yes, between 9 and 28 frames
                IF TitleMode% THEN WaitTime% = 18 '                                set a fixed wait time if in title sequence mode
                NewWait% = FALSE '                                                 turn off random wait time generate until move made
            END IF
            IF SpinCount% > 0 AND (SpinCount% / WaitTime% = SpinCount% \ WaitTime%) THEN ' is it time for computer move?
                NewWait% = TRUE '                                                  yes, a new wait time will be needed then
                IF CPUColumn% > Column% THEN '                                     does computer need to move right?
                    KeyPress$ = CHR$(77) '                                         yes, simulate the right key being pressed
                ELSEIF CPUColumn% < Column% THEN '                                 does computer need to move left?
                    KeyPress$ = CHR$(75) '                                         yes, simulate the left key being pressed
                ELSE '                                                             computer is now at correct column
                    KeyPress$ = CHR$(80) '                                         simulate the down key being pressed
                END IF
            END IF
        END IF
        SELECT CASE KeyPress$ '                                                    which key was pressed?
            CASE CHR$(75) '                                                        left arrow key
                Column% = Column% - 1 '                                            decrement column value
            CASE CHR$(77) '                                                        right arrow key
                Column% = Column% + 1 '                                            increment column value
            CASE CHR$(80), CHR$(13) '                                              down arrow or enter key
                CheckerDrop% = TRUE '                                              set flag to drop checker
        END SELECT
        KeyPress$ = "" '                                                           reset keyboard input string
        IF Column% < 0 THEN Column% = 0 '                                          stay on left side of board
        IF Column% > 6 THEN Column% = 6 '                                          stay on right side of board
        IF Column% <> OldColumn% THEN OldColumn% = Column% '                       remember new column chosen
        DO
            _LIMIT 36 '                                                            limit this loop to 36 times per second
            SPRITEPUT Cell(Column%, 1).x, 50, SpinChecker%(CheckerColor%) ' place the auto-animating checker sprite
            SpinCount% = SpinCount% + 1 '                                          keep track of which checker frame is showing
            IF SpinCount% = 36 THEN SpinCount% = 0 '                               reset frame tracker when checker completes a spin
            _DISPLAY '                                                             update the screen with changes
            IF (CheckerDrop% AND (SpinCount% = 1)) OR (CheckerDrop% AND (SpinCount% = 19)) THEN ' is checker ready to drop?
                IF SpinCount% = 1 THEN Face% = 0 ELSE Face% = 1 '                  yes, determine which checker face to show
                ColumnChosen% = DropChecker(Column%, CheckerColor%, Face%) '       drop the checker
                CheckerDrop% = FALSE '                                             reset checker drop flag
                IF TitleMode% THEN '                                               in title sequence mode?
                    ColumnChosen% = TRUE '                                         yes, trick routine into thinking column chosen
                    CheckerDrop% = FALSE '                                         trick routine into thinking checker dropped
                END IF
            END IF
        LOOP UNTIL NOT CheckerDrop% '                                              stay in this loop until attempted checker drop
    LOOP UNTIL ColumnChosen% '                                                     stay in this loop until checker has actually dropped
    DO: LOOP UNTIL INKEY$ = "" '                                                   clear keyboard buffer of any stray inputs

    '******************************************************************************
END SUB

FUNCTION DropChecker% (Column%, CheckerColor%, Face%)
    '******************************************************************************
    '*                                                                            *
    '* Drops a checker into a given column of specified color and facing side.    *
    '*                                                                            *
    '******************************************************************************

    DIM RowCheck% '                                                                row to check for a checker
    DIM RowFound% '                                                                goes true when a valid row is found
    DIM SlideVolume! '                                                             current volume of checker sliding sound
    DIM Fallen% '                                                                  true when checker has fallen total distance
    DIM FallCount% '                                                               current y position of falling checker
    DIM OldFallCount% '                                                            last y position of falling checker
    DIM FallTime! '                                                                increasing speed of falling checker
    DIM CellCount% '                                                               cell positions involved in drop animation
    DIM SlideVloume!

    SHARED CellImage%
    SHARED CellBlank%
    SHARED Cell() AS CELL
    SHARED Click&
    SHARED Drop&
    SHARED Slide&
    SHARED Checker%()
    SHARED LastRow%
    SHARED LastColumn%
    SHARED SoundOption%

    DropChecker% = FALSE '                                                         assume column can't have checker dropped
    RowCheck% = 6 '                                                                reset row count
    RowFound% = FALSE '                                                            assume a row can't be found
    Fallen% = FALSE '                                                              assume checker has not fallen yet
    SlideVloume! = .00001 '                                                        set intital volume of slide sound low
    FallCount% = 50 '                                                              start animation y location from here
    OldFallCount% = 50 '                                                           start animation y location from here
    FallTime! = 1 '                                                                set initial falling speed of 1 pixel
    DO
        IF Cell(Column%, RowCheck% - 1).c <> 2 THEN '                              is there a checker here?
            RowFound% = TRUE '                                                     yes, previous row seems valid
        ELSE '                                                                     there is no checker here
            RowCheck% = RowCheck% - 1 '                                            move onto the next row
            IF RowCheck% = 0 THEN RowFound% = TRUE '                               leave if run out of rows to check
        END IF
    LOOP UNTIL RowFound% '                                                         leave if a possible row is found
    IF RowCheck% <> 6 THEN '                                                       was a vaild row found?
        DropChecker% = TRUE '                                                      return that a checker was dropped
        IF SoundOption% THEN '                                                     is sound allowed?
            _SNDPLAY Slide& '                                                      yes, start the sliding noise
            _SNDVOL Slide&, SlideVolume! '                                         set the initial low volume
        END IF
        DO
            _LIMIT 150 '                                                           limit to 150 frames per second
            SPRITESTAMP Cell(Column%, RowCheck%).x, OldFallCount%, CellBlank% '    clear the last checker position
            FallCount% = FallCount% + INT(FallTime!) '                             update falling checker y position
            OldFallCount% = FallCount% '                                           remember this position to clear later
            IF FallCount% >= Cell(Column%, RowCheck%).y THEN '                     has checker reached bottom?
                Fallen% = TRUE '                                                   yes, mark as such
                SPRITESTAMP Cell(Column%, RowCheck%).x, Cell(Column%, RowCheck%).y, Checker%(CheckerColor%, Face%) ' draw checker in final spot
                IF SoundOption% THEN _SNDSTOP Slide& '                             stop the sliding noise if allowed
                IF RowCheck% = 0 THEN '                                            was there no other checker in this column?
                    IF SoundOption% THEN _SNDPLAYCOPY Drop&, 1 '                   play sound of checker hitting game rack if allowed
                ELSE '                                                             the falling checker hit another checker
                    IF SoundOption% THEN _SNDPLAYCOPY Click&, .1666 * (6 - RowCheck%) ' play sound of checker hitting another checker if allowed
                END IF
            ELSE '                                                                 checker is still falling
                SPRITESTAMP Cell(Column%, RowCheck%).x, FallCount%, Checker%(CheckerColor%, Face%) ' draw checker's current position
            END IF
            FOR CellCount% = 5 TO RowCheck% STEP -1 '                              loop through cells affected by animation
                SPRITESTAMP Cell(Column%, CellCount%).x, Cell(Column%, CellCount%).y, CellImage% ' draw cell image in these locations
            NEXT CellCount%
            FallTime! = FallTime! * 1.05 '                                         increase the falling speed
            SlideVolume! = SlideVolume! + .0005 '                                  increase the sliding noise volume
            IF SoundOption% THEN _SNDVOL Slide&, SlideVolume! '                    set the new sliding noise volume if sound allowed
            _DISPLAY '                                                             show all changes made to screen
        LOOP UNTIL Fallen% '                                                       keep looping until checker comes to a halt
        Cell(Column%, RowCheck%).c = CheckerColor% '                               update array with current checker in position
        Cell(Column%, RowCheck%).f = Face% '                                       update array with current checker face showing
        LastRow% = RowCheck% '                                                     remember last row checker dropped in
        LastColumn% = Column% '                                                    remember last column checker dropped in
    END IF

    '******************************************************************************
END FUNCTION

SUB DrawBoard ()
    '******************************************************************************
    '*                                                                            *
    '* Draws the initial game board.                                              *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     current row of cell being drawn
    DIM Column% '                                                                  current column of cell being drawn

    SHARED CellImage%
    SHARED Cell() AS CELL

    _TITLE "Game in Progress!" '                                                   change window title to show game in progress
    LINE (0, 0)-(699, 699), _RGB32(0, 0, 254), BF '                                clear the entire screen
    FOR Column% = 0 TO 6 '                                                         cycle through all cell columns
        FOR Row% = 0 TO 5 '                                                        cycle through all cell rows
            SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, CellImage% ' draw the cell image
        NEXT Row%
    NEXT Column%

    '******************************************************************************
END SUB

SUB InitializeVariables ()
    '******************************************************************************
    '*                                                                            *
    '* Initializes game variables to default conditions.                          *
    '*                                                                            *
    '******************************************************************************

    DIM Row% '                                                                     current cell row
    DIM Column% '                                                                  current cell column

    SHARED Cell() AS CELL '                                                        game board checker positions

    FOR Column% = 0 TO 6 '                                                         cycle through all cell columns
        FOR Row% = 0 TO 5 '                                                        cycle through all cell rows
            Cell(Column%, Row%).x = Column% * 100 + 50 '                           compute this cell's x location
            Cell(Column%, Row%).y = 650 - Row% * 100 '                             compute this cell's y location
            Cell(Column%, Row%).c = EMPTY '                                        no checker
            Cell(Column%, Row%).f = 0 '                                            front facing checkers
        NEXT Row%
    NEXT Column%

    '******************************************************************************
END SUB

SUB TitleSequence ()
    '******************************************************************************
    '*                                                                            *
    '* Plays the starting title sequence of the game.                             *
    '*                                                                            *
    '******************************************************************************

    DIM Bcolumn$(6, 4) '                                                           array holding checkers spelling "4 in a row"
    DIM DropCount% '                                                               keeps track of number of checkers dropped
    DIM CellCount% '                                                               keeps track of number of cells visited in column
    DIM Dummy% '                                                                   dummy value returned by DropChecker()
    DIM Dropped% '                                                                 true when a checker has been dropped
    DIM Column% '                                                                  the random column to drop a checker down
    DIM Row% '                                                                     row counter
    DIM ShrinkingChecker%(2) '                                                     shrinking checker sprites
    DIM Zoom% '                                                                    zoom level of shrinking checkers
    DIM FourImage& '                                                               image of red 4
    DIM TempImage& '                                                               temporary image holder
    DIM Count% '                                                                   generic counter
    DIM Mcount% '                                                                  marquee counter

    SHARED TitleMode%
    SHARED TitleMusic&
    SHARED Cell() AS CELL
    SHARED Checker%()
    SHARED CheckerSheet%
    SHARED CellBlank%
    SHARED Drop&
    SHARED Menu%()
    SHARED MenuImage&
    SHARED MenuY%()
    SHARED SpinChecker%()
    SHARED MusicOption%
    SHARED SoundOption%

    Bcolumn$(0, 0) = "000000": Bcolumn$(0, 1) = "00000 ": Bcolumn$(0, 2) = " 0    ": Bcolumn$(0, 3) = "    0 ": Bcolumn$(0, 4) = "0     "
    Bcolumn$(1, 0) = "000111": Bcolumn$(1, 1) = "      ": Bcolumn$(1, 2) = "0 0 0 ": Bcolumn$(1, 3) = "   0  ": Bcolumn$(1, 4) = " 00   "
    Bcolumn$(2, 0) = "000100": Bcolumn$(2, 1) = "00000 ": Bcolumn$(2, 2) = "0 0 0 ": Bcolumn$(2, 3) = " 000  ": Bcolumn$(2, 4) = "0     "
    Bcolumn$(3, 0) = "000100": Bcolumn$(3, 1) = "   0  ": Bcolumn$(3, 2) = " 000  ": Bcolumn$(3, 3) = "0   0 ": Bcolumn$(3, 4) = " 0000 "
    Bcolumn$(4, 0) = "111111": Bcolumn$(4, 1) = "    0 ": Bcolumn$(4, 2) = "0     ": Bcolumn$(4, 3) = "0   0 ": Bcolumn$(4, 4) = "      "
    Bcolumn$(5, 0) = "000100": Bcolumn$(5, 1) = "0000  ": Bcolumn$(5, 2) = "00000 ": Bcolumn$(5, 3) = " 000  ": Bcolumn$(5, 4) = "      "
    Bcolumn$(6, 0) = "000000": Bcolumn$(6, 1) = "      ": Bcolumn$(6, 2) = "   0  ": Bcolumn$(6, 3) = " 0000 ": Bcolumn$(6, 4) = "      "

    SCREEN _NEWIMAGE(700, 700, 32) '                                               700x700x32bit screen
    _SCREENMOVE _MIDDLE '                                                          move the screen to the middle of desktop
    DrawBoard '                                                                    draw the game board
    _TITLE "Welcome to Four in a Row!" '                                           title the window
    DropCount% = 0 '                                                               reset checker drop counter
    ShrinkingChecker%(0) = SPRITENEW(CheckerSheet%, 1, SAVE) '                     create the black shrinking checker sprite side 1
    ShrinkingChecker%(1) = SPRITENEW(CheckerSheet%, 19, SAVE) '                    create the black shrinking checker sprite side 2
    ShrinkingChecker%(2) = SPRITENEW(CheckerSheet%, 37, SAVE)
    RANDOMIZE TIMER '                                                              seed the random number generator
    IF MusicOption% THEN '                                                         is music allowed?
        _SNDPLAY TitleMusic& '                                                     yes, start the funky title music
        _SNDVOL TitleMusic&, 1 '                                                   set the volume to highest value
    END IF
    DO
        Column% = INT(RND(1) * 7) '                                                choose a random column
        CellCount% = 1 '                                                           start counting at bottom cell of column
        Dropped% = FALSE '                                                         reset the checker dropped flag
        IF Bcolumn$(Column%, 0) <> "      " THEN '                                 is this column full of checkers?
            DO '                                                                   no
                IF MID$(Bcolumn$(Column%, 0), CellCount%, 1) <> " " THEN '         is there a checker in this position?
                    Dummy% = DropChecker%(Column%, VAL(MID$(Bcolumn$(Column%, 0), CellCount%, 1)), INT(RND(1) * 2)) ' no, drop a checker
                    MID$(Bcolumn$(Column%, 0), CellCount%, 1) = " " '              mark this cell as used by a checker
                    DropCount% = DropCount% + 1 '                                  increment the checker drop counter
                    Dropped% = TRUE '                                              set the dropped checker flag
                ELSE '                                                             there is a checker in this position
                    CellCount% = CellCount% + 1 '                                  increment cell counter to try next cell
                END IF
            LOOP UNTIL Dropped% '                                                  keep looping until a checker is dropped
        END IF
    LOOP UNTIL DropCount% = 42 '                                                   keep looping until all checkers have been dropped
    TitleMode% = TRUE '                                                            set the title mode flag
    MoveChecker RED, 1 '                                                           move a spinning red checker into the scene
    TitleMode% = FALSE '                                                           remove the title mode flag
    LINE (0, 100)-(699, 699), _RGB32(0, 0, 254), BF '                              remove the board and chckers, leave top red checker
    FOR Column% = 0 TO 6 '                                                         cycle through all the columns
        FOR Row% = 0 TO 5 '                                                        cycle through all the rows
            SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, Checker%(Cell(Column%, Row%).c, Cell(Column%, Row%).f) ' draw only checkers
        NEXT Row%
    NEXT Column%
    _DISPLAY '                                                                     update the screen with changes
    FOR Zoom% = 100 TO 1 STEP -1 '                                                 zoom black checkers from 100% to 1%
        _LIMIT 100 '                                                               take one second to zoom black checkers out
        SPRITEZOOM ShrinkingChecker%(0), Zoom% '                                   set the zoom level of black checker face 1
        SPRITEZOOM ShrinkingChecker%(1), Zoom% '                                   set the zoom level of black checker face 2
        FOR Column% = 0 TO 6 '                                                     cycle through all the columns
            FOR Row% = 0 TO 5 '                                                    cycle through all the rows
                IF Cell(Column%, Row%).c = 0 THEN '                                does this cell contain a black checker?
                    SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, CellBlank% ' yes, clear the cell
                    SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, ShrinkingChecker%(Cell(Column%, Row%).f) ' place the zoomed checker
                END IF
            NEXT Row%
        NEXT Column%
        _DISPLAY '                                                                 update the screen with changes
    NEXT Zoom%
    FourImage& = _COPYIMAGE(0) '                                                   save the red 4 that is left on the screen
    SPRITEPUT -100, -100, SpinChecker%(1)
    FOR Zoom% = 699 TO 139 STEP -10 '                                              shrink the red 4 image by 80%
        LINE (0, 0)-(Zoom% + 30, Zoom% + 50), _RGB32(0, 0, 254), BF '              clear the last red 4 image drawn
        _PUTIMAGE (20, 40)-(Zoom% + 20, Zoom% + 40), FourImage& '                  place the newly sized red 4 on the screen
        _DISPLAY '                                                                 update the screen with changes
    NEXT Zoom%
    IF SoundOption% THEN _SNDPLAYCOPY Drop& '                                      play checker drop noise when 4 finished shrinking
    TempImage& = _NEWIMAGE(700, 700, 32) '                                         create a new temporary image
    FOR Count% = 1 TO 4 '                                                          cycle through the remaining four array elements
        _DEST TempImage& '                                                         drawing will be done on the temporary image
        LINE (0, 0)-(699, 699), _RGB32(0, 0, 254), BF '                            fill the temp image with blue
        FOR Column% = 0 TO 6 '                                                     cycle through all the columns
            FOR Row% = 0 TO 5 '                                                    cycle through all the rows
                IF MID$(Bcolumn$(Column%, Count%), Row% + 1, 1) = "0" THEN '           does this string position in array contain 0?
                    IF Count% = 2 AND Column% < 5 THEN '                           yes, are we currently drawing the "a"?
                        Cell(Column%, Row%).c = 1 '                                yes, set this position to be a red checker
                    ELSE '                                                         we are not currently drawing the "a"
                        Cell(Column%, Row%).c = 0 '                                set this position to be a black checker
                    END IF
                    Cell(Column%, Row%).f = INT(RND(1) * 2) '                      create a random face for the checker
                ELSE '                                                             this position does not contain a 0
                    Cell(Column%, Row%).c = 2 '                                    set this position to contain no checker
                END IF
                SPRITESTAMP Cell(Column%, Row%).x, Cell(Column%, Row%).y, Checker%(Cell(Column%, Row%).c, Cell(Column%, Row%).f) ' draw the positon
            NEXT Row%
        NEXT Column%
        _DEST 0 '                                                                  drawing will be done on the screen
        FOR DropCount% = -150 TO 20 '                                              drop the remaining words in from the top of screen
            LINE (20 + Count% * 140, 0)-(149 + Count% * 140, 149), _RGB32(0, 0, 254), BF ' clear the position where words will drop in from
            _PUTIMAGE (20 + Count% * 140, DropCount%)-(159 + Count% * 140, DropCount% + 139), TempImage& ' place temporary image shrunk on screen
            _DISPLAY '                                                             update the screen with changes
        NEXT DropCount%
        IF SoundOption% THEN _SNDPLAYCOPY Drop& '                                  play checker drop noise when words in place
    NEXT Count%
    Row% = 1 '                                                                     start with menu row 1
    Mcount% = 0 '                                                                  reset marquee counter
    FOR Count% = 300 TO 645 STEP 115 '                                             step through menu entry Y positions
        MenuY%(Row%) = Count% '                                                    save this Y position
        FOR Zoom% = 1 TO 100 '                                                     cycle from 1 to 100
            _LIMIT 128 '                                                           limit FOR statement to 128 FPS
            SPRITEZOOM Menu%(Row%, 0), Zoom% '                                     set zoom level of menu entry
            SPRITESTAMP 349, Count%, Menu%(Row%, 0) '                              place menu entry on screen
            Mcount% = Mcount% + 1 '                                                increment marquee counter
            IF Mcount% = 32 THEN '                                                 1/4 second gone by?
                Mcount% = 1 '                                                      yes, reset marquee counter
                Marquee '                                                          update the marquee
            END IF
            _DISPLAY '                                                             display changes to the screen
        NEXT Zoom%
        IF SoundOption% THEN _SNDPLAYCOPY Drop& '                                  play sound when menu entry zoomed in
        Row% = Row% + 1 '                                                          increment menu row counter
    NEXT Count%
    SPRITESTAMP 349, MenuY%(1), Menu%(1, 1) '                                      highlight first menu entry
    MenuImage& = _COPYIMAGE(0) '                                                   save a copy of the screen
    FOR Zoom% = 1 TO 100 '                                                         cycle from 1 to 100
        _LIMIT 128 '                                                               limit FOR statement to 128 FPS
        SPRITEZOOM ShrinkingChecker%(0), Zoom% '                                   set zoom level of black checker
        SPRITEZOOM ShrinkingChecker%(2), Zoom% '                                   set zoom level of red checker
        SPRITEPUT 62, MenuY%(1), ShrinkingChecker%(2) '                            place red checker on screen
        SPRITEPUT 636, MenuY%(1), ShrinkingChecker%(0) '                           place black checker on screen
        Mcount% = Mcount% + 1 '                                                    incrememnt marquee counter
        IF Mcount% = 32 THEN '                                                     1/4 second gone by?
            Mcount% = 1 '                                                          yes, reset marquee counter
            Marquee '                                                              update the marquee
        END IF
        _DISPLAY '                                                                 display changes to the screen
    NEXT Zoom%
    DO
        _LIMIT 4 '                                                                 limit loop to 4 FPS
        Marquee '                                                                  update the marquee
        _DISPLAY '                                                                 display changes to the screen
    LOOP UNTIL NOT _SNDPLAYING(TitleMusic&) '                                      keep looping until music done
    IF MusicOption% THEN '                                                         is music allowed?
        _SNDVOL TitleMusic&, 0 '                                                   yes, set music volume to 0  \
        _SNDPLAY TitleMusic& '                                                     play music again             \  this is a workaround for a QB64
        _DELAY .1 '                                                                delay for 10th of second      - MMIDI bug that crashes program
        _SNDSTOP TitleMusic& '                                                     stop music                   /
        _SNDCLOSE TitleMusic& '                                                    close music                 /
    END IF

    '******************************************************************************
END SUB

FUNCTION AllExist% ()
    '******************************************************************************
    '*                                                                            *
    '* Returns TRUE if all support files exist, FALSE otherwise.                  *
    '*                                                                            *
    '******************************************************************************

    AllExist% = FALSE '                                                            assume a file(s) is missing
    IF NOT _FILEEXISTS("checkers.png") THEN EXIT FUNCTION '                        if any file is missing return FALSE
    IF NOT _FILEEXISTS("4iaricon.bmp") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("click.wav") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("firstdrop.wav") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("slide.wav") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("title.mid") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("music.ogg") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("menu.png") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("menu.ogg") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("win1.ogg") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("win2.ogg") THEN EXIT FUNCTION
    IF NOT _FILEEXISTS("lose.ogg") THEN EXIT FUNCTION
    AllExist% = TRUE '                                                             made it this far then all exist

    '******************************************************************************
END FUNCTION

SUB CreateAssets ()
    '******************************************************************************
    '*                                                                            *
    '* Prepares graphics and sounds for game play.                                *
    '*                                                                            *
    '* - Load the checkers sprite sheet and game board images into memory.        *
    '* - Create the black and red checker sprites.                                *
    '* - Set up animation characteristics of both checker sprites.                *
    '*                                                                            *
    '******************************************************************************

    DIM icon& '                                                                    handle that holds window icon image

    SHARED CheckerSheet% '
    SHARED MenuSheet%
    SHARED SpinChecker%() '
    SHARED Checker%() '
    SHARED Menu%()
    SHARED board& '
    SHARED CellImage% '
    SHARED CellBlank% '
    SHARED Click& '
    SHARED Drop& '
    SHARED Slide& '
    SHARED TitleMusic&
    SHARED MarqueeChecker%()
    SHARED Options%()
    SHARED GameLevel%
    SHARED SoundOption%
    SHARED MusicOption%
    SHARED GameMusic&
    SHARED MenuMusic&
    SHARED Win&()
    SHARED Lose&
    SHARED Winner%()
    SHARED WinSpin%()

    IF NOT AllExist% THEN '                                                        do all support files exist?
        PRINT '                                                                    no, inform user
        PRINT "     Four in a Row"
        PRINT "          by"
        PRINT "     Terry Ritchie"
        PRINT "terry.ritchie@gmail.com"
        PRINT
        PRINT "ERROR: One or more support files are missing."
        PRINT "       Please reinstall the game."
        PRINT
        PRINT "Press any key to return to Windows."
        BEEP '                                                                     get user's attention
        DO: LOOP UNTIL INKEY$ = "" '                                               clear keyboard buffer
        DO: LOOP UNTIL INKEY$ <> "" '                                              wait for a key press
        SYSTEM '                                                                   return to Windows
    END IF
    icon& = _LOADIMAGE("4iaricon.bmp", 32) '                                       load the window icon image
    _ICON icon& '                                                                  set the window icon image
    _FREEIMAGE icon& '                                                             remove the icon image from memory
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
    Click& = _SNDOPEN("click.wav", "VOL,SYNC") '                                   sound of checker hitting another checker
    Drop& = _SNDOPEN("firstdrop.wav", "VOL,SYNC") '                                sound of checker hitting game board rack
    Slide& = _SNDOPEN("slide.wav", "VOL,SYNC") '                                   sound of checker sliding down game board rack
    TitleMusic& = _SNDOPEN("title.mid", "VOL") '                                   music that plays during title sequence
    GameMusic& = _SNDOPEN("music.ogg", "VOL,SYNC") '                               music that plays during game
    MenuMusic& = _SNDOPEN("menu.ogg", "VOL,SYNC") '                                music that plays during menu
    Win&(0) = _SNDOPEN("win1.ogg", "VOL,SYNC") '                                   audience applause sound 1
    Win&(1) = _SNDOPEN("win2.ogg", "VOL,SYNC") '                                   audience applause sound 2
    Lose& = _SNDOPEN("lose.ogg", "VOL,SYNC") '                                     audience not happy sound
    _SNDVOL GameMusic&, .5 '                                                       set game music volume to 50%
    SPRITEZOOM MarqueeChecker%(0), 20 '                                            zoom black checker out 80%
    SPRITEZOOM MarqueeChecker%(1), 20 '                                            zoom red checker out 80%
    IF _FILEEXISTS("options.4ir") THEN '                                           does the options file exist?
        OPEN "options.4ir" FOR INPUT AS #1 '                                       yes, open it
        INPUT #1, GameLevel% '                                                     get save game level
        INPUT #1, SoundOption% '                                                   get saved sound option
        INPUT #1, MusicOption% '                                                   get saved music option
        CLOSE #1 '                                                                 close the options file
    ELSE '                                                                         no
        OPEN "options.4ir" FOR OUTPUT AS #1 '                                      create the options file
        PRINT #1, 2 '                                                              set level of game play to 2
        PRINT #1, TRUE '                                                           set sounds to on
        PRINT #1, TRUE '                                                           set music to on
        CLOSE #1
    END IF

    '******************************************************************************
END SUB

'******************************************************************************
'* The game utilizes my sprite library                                        *
'*                                                                            *
'$INCLUDE:'sprite.bi'
'*                                                                            *
'******************************************************************************
