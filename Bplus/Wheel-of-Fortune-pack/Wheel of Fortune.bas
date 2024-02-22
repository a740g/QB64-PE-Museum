OPTION _EXPLICIT
_TITLE "Wheel of Fortune Cookies" ' b+ started 2020-12-26
' 2020-12-29 Puzzle limited to 3 words or less 11 letters or less each word
' category added to puzzle and readjusted screen to fit in the label.
' 12-31 5 secs to explain lose turn

RANDOMIZE TIMER
CONST Xmax = 1240, Ymax = 640, ORad = 299, IRad = 100, CA = _PI(2 / 24), Cad2 = CA / 2
CONST Vowels = "AEIOU", Letters = "BCDFGHJKLMNPQRSTVWXYZ"
TYPE player
    Index AS LONG
    Name AS STRING
    Spin AS STRING
    Current AS LONG
    Game AS LONG
    FreePlay AS LONG
END TYPE

REDIM SHARED FV72&, F20, F40, Wheel&, WheelSpin$(0), P(0 TO 2) AS player, Category$, Puzzle$, Hidden$, LettersAvail$, VowelsAvail$, Turn AS LONG

SCREEN _NEWIMAGE(Xmax, Ymax, 32)
_DELAY .25
_SCREENMOVE _MIDDLE

'local main module variables  lower case 1st letter
REDIM s$, i AS LONG, highSpin AS LONG, savePlayer, tie ' who plays first?
REDIM mx AS LONG, my AS LONG, mb AS LONG, ok AS LONG, ln AS LONG, guess$
REDIM mx1 AS LONG, my1 AS LONG, mb1 AS LONG, letter AS LONG, amt AS LONG ' just for picking letters
REDIM time!


'                                                      getting started
FV72& = _LOADFONT("verdanab.ttf", 72) ' used for letters and digits in makeWheel
F20 = _LOADFONT("OpenSans-ExtraBold.ttf", 20) ' Host says and small letter and vowel picks in puzzle
F40 = _LOADFONT("OpenSans-ExtraBold.ttf", 40) ' large letters in puzzle

'    debug
'GetPuzzle
'PRINT Category$, Puzzle$
'PRINT Hidden$
'END

'ShowLetters
'ShowVowels
'ShowPuzzleBoard

' oh we have to initialize UDT's
FOR i = 0 TO 2
    P(i).Index = 0
    P(i).Name = ""
    P(i).Spin = ""
    P(i).Current = 0
    P(i).Game = 0
    P(i).FreePlay = 0
NEXT
MakeWheel
RotoZoom2 0, Xmax - 19 - 299, 19 + 299, Wheel&, 1, 1, -22 * CA
LINE (Xmax - 19 - 299 - 3, 19 + 299 - 315)-STEP(6, 20), &HFFFFFFFF, BF
LINE (Xmax - 19 - 299 - 3, 19 + 299 - 315)-STEP(6, 20), &HFF000000, B
COLOR &HFFFFFFFF

highSpin = 0: tie = -1
FOR i = 0 TO 2
    P(i).Index = i
    HostSays "Hello player " + _TRIM$(STR$(i + 1)) + ", please enter your name:"
    COLOR &HFFFFFFFF
    LOCATE 6, 5: INPUT ""; P(i).Name
    P(i).Spin = SpinWheel$(P(i).Name)
    WHILE P(i).Spin = "FREE PLAY":
        P(i).Spin = SpinWheel$(P(i).Name)
        UpdatePlayer i, -1
    WEND
    UpdatePlayer i, 0
    IF VAL(P(i).Spin) > highSpin THEN
        savePlayer = i: highSpin = VAL(P(i).Spin): tie = 0
    ELSEIF VAL(P(i).Spin) = highSpin THEN
        tie = -1
    END IF
NEXT
'tie = -1 'debug test
LINE (0, 0)-STEP(600, 110), &HFF000000, BF
WHILE tie
    tie = -1: highSpin = 0: savePlayer = -1
    FOR i = 0 TO 2
        UpdatePlayer i, -1
        P(i).Spin = SpinWheel$(P(i).Name)
        WHILE P(i).Spin = "FREE PLAY"
            P(i).Spin = SpinWheel$(P(i).Name)
            UpdatePlayer i, -1
        WEND
        UpdatePlayer i, 0
        IF VAL(P(i).Spin) > highSpin THEN
            savePlayer = i: highSpin = VAL(P(i).Spin): tie = 0
        ELSEIF VAL(P(i).Spin) = highSpin THEN
            tie = -1
        END IF
    NEXT
WEND
Turn = savePlayer 'from the spinoff above, from here on the players play in sequence

NewPuzzle
DO ' play a round
    playAgain: ' may restart same player
    s$ = P(Turn).Name + ", click: The Wheel or Solve"
    IF VowelsAvail$ <> "     " AND P(Turn).Current >= 250 THEN s$ = s$ + " or Vowel (to buy)"
    HostSays s$
    UpdatePlayer Turn, -1
    ShowLetters
    ShowVowels
    ShowPuzzleBoard
    _PRINTSTRING (50, 80), "Solve"

    ok = 0
    DO ' wait for click a spot input from player
        WHILE _MOUSEINPUT: WEND
        mb = _MOUSEBUTTON(1)
        IF mb THEN 'where did the click occur
            mx = _MOUSEX: my = _MOUSEY
            _DELAY .25 'wait
            IF mx > 50 AND mx < 90 AND my > 80 AND my < 96 THEN 'wants to solve
                s$ = P(Turn).Name + ", type in your guess and press enter."
                HostSays s$
                LOCATE 6, 5: INPUT ""; guess$
                IF UCASE$(guess$) = Puzzle$ THEN 'we have a winner!
                    'move the winner's current into game
                    IF P(Turn).Current < 1000 THEN 'player must win at least 1000
                        P(Turn).Game = P(Turn).Game + 1000
                    ELSE
                        P(Turn).Game = P(Turn).Game + P(Turn).Current
                    END IF
                    Hidden$ = Puzzle$ 'reveal
                    ShowPuzzleBoard
                    s$ = P(Turn).Name + ", Congratulations you solved the puzzle!"
                    HostSays s$
                    _DELAY 3

                    NewPuzzle
                    ok = -1 'and we are onto checking if next player has lost turn


                ELSE
                    BEEP: ok = -1 ' move to next player
                    s$ = P(Turn).Name + ", sorry, that's not it."
                    HostSays s$
                    _DELAY 3
                END IF

            ELSEIF mx > Xmax - 640 THEN ' wants to spin
                P(Turn).Spin = SpinWheel$(P(Turn).Name)
                UpdatePlayer Turn, -1
                IF P(Turn).Spin = "FREE PLAY" OR LEN(P(Turn).Spin) < 5 THEN ' money or token
                    IF P(Turn).Spin = "FREE PLAY" THEN P(Turn).FreePlay = P(Turn).FreePlay + 1
                    'now pick a letter
                    s$ = P(Turn).Name + ", and now click a letter not guessed yet."
                    HostSays s$ ' too slow
                    _FONT F20
                    _PRINTSTRING (300 - _PRINTWIDTH(s$) / 2, 40), s$
                    _FONT 16
                    letter = 0
                    DO
                        WHILE _MOUSEINPUT: WEND
                        mb1 = _MOUSEBUTTON(1)
                        IF mb1 THEN 'where did the click occur
                            mx1 = _MOUSEX: my1 = _MOUSEY
                            _DELAY .25 'make sure click is done
                            IF mx1 > 25 AND mx1 < 550 AND my1 > Ymax - 50 AND my1 < Ymax THEN 'we're in the letters
                                ln = INT((mx1 - 25) / 25) + 1
                                IF INSTR(LettersAvail$, MID$(Letters, ln, 1)) > 0 THEN
                                    MID$(LettersAvail$, ln, 1) = " " 'remove from avail
                                    amt = Find&(MID$(Letters, ln, 1))
                                    IF amt THEN ' player may go again but has 10 secs to solve
                                        P(Turn).Current = P(Turn).Current + amt * VAL(P(Turn).Spin)
                                        GOTO playAgain
                                    ELSE
                                        BEEP: letter = -1: ok = -1 'escape from loop
                                    END IF ' find letter or not
                                ELSE
                                    BEEP: letter = -1: ok = -1 'you lose turn for clicking a letter already used
                                END IF ' letter is avail
                            END IF ' in letter area
                        END IF 'mb to click a letter
                    LOOP UNTIL letter = -1

                ELSEIF P(Turn).Spin = "BANKRUPT" THEN
                    P(Turn).Current = 0: ok = -1: _DELAY 2
                ELSEIF P(Turn).Spin = "LOSE TURN" THEN
                    s$ = P(Turn).Name + ", sorry you lose next turn unless have FREE PLAY."
                    HostSays s$
                    _DELAY 5
                    ok = -1
                END IF

            ELSEIF mx > 25 AND mx < 150 AND my > Ymax - 100 AND my < Ymax - 60 THEN 'buying a vowel
                'which vowel clicked is it available?
                ln = INT((mx - 25) / 25) + 1
                IF INSTR(VowelsAvail$, MID$(Vowels, ln, 1)) > 0 THEN 'vowel not already taken
                    IF P(Turn).Current >= 250 THEN ' player has the cash
                        P(Turn).Current = P(Turn).Current - 250

                        'take vowel off
                        MID$(VowelsAvail$, ln, 1) = " "

                        'OK now see if vowel in clue
                        IF Find&(MID$(Vowels, ln, 1)) THEN ' player may go again but has 10 secs to solve
                            GOTO playAgain
                        ELSE
                            BEEP: ok = -1 'escape from loop
                        END IF
                    ELSE
                        BEEP: ok = -1 'don't have money to buy loose your turn
                    END IF
                ELSE
                    BEEP: ok = -1 ' vowel taken  lose turn  when click a vowel already played
                END IF

            END IF 'mx, my are in active zones

        END IF ' a click has occurred
        _LIMIT 60
    LOOP UNTIL ok ' no escape but click and follow instructions

    'ok the player's turn is up and before we move onto next player
    'let's offer a Play Free Play button if the player has one before moving to next player
    ' this is best under a Timer
    IF P(Turn).FreePlay THEN

        s$ = P(Turn).Name + ", Click me in 5 secs to play a Free Play."
        HostSays s$
        time! = TIMER(.01)
        DO
            WHILE _MOUSEINPUT: WEND
            mb1 = _MOUSEBUTTON(1)
            IF mb1 THEN 'where did the click occur
                mx1 = _MOUSEX: my1 = _MOUSEY
                _DELAY .25
                IF mx1 > 0 AND mx1 < 600 THEN
                    IF my1 > 0 AND my1 < 110 THEN
                        P(Turn).FreePlay = P(Turn).FreePlay - 1
                        s$ = P(Turn).Name + ", using a FREE PLAY."
                        HostSays s$
                        GOTO playAgain
                    END IF
                END IF
            END IF
        LOOP UNTIL TIMER(.01) - time! > 5
    END IF

    UpdatePlayer Turn, 0
    updateTurn:
    Turn = (Turn + 1) MOD 3
    IF P(Turn).Spin = "LOSE TURN" THEN 'check next player up for LOSE TURN status
        P(Turn).Spin = "PAID TURN" ' because we are skipping now
        UpdatePlayer Turn, 0
        IF P(Turn).FreePlay > 0 THEN
            P(Turn).FreePlay = P(Turn).FreePlay - 1
            s$ = P(Turn).Name + ", using a FREE PLAY."
            HostSays s$
            _DELAY 2
        ELSE
            GOTO updateTurn ' skip this player it actually happened that 2 players in row Lose Turn!!!
        END IF
    END IF ' checking for LOSE TURN of next player
LOOP

SUB NewPuzzle
    DIM i
    CLS
    RotoZoom2 0, Xmax - 19 - 299, 19 + 299, Wheel&, 1, 1, -22 * CA
    'clear players round
    FOR i = 0 TO 2
        'P(i).Spin = ""  LOSE TURN carries over to next game
        P(i).Current = 0
        'P(i).FreePlay = 0  carries over to next game
        UpdatePlayer i, (Turn = i)
    NEXT 'reset some player data
    GetPuzzle 'reset Puzzle$, Hidden$ , letters and vowels Avail$
    ShowPuzzleBoard
    ShowVowels
    ShowLetters
END SUB

SUB HostSays (s$)
    LINE (0, 0)-STEP(600, 110), &HFF000000, BF
    _FONT F20
    COLOR &HFFDDDDFF
    _PRINTSTRING (300 - _PRINTWIDTH(s$) / 2, 40), s$
    _FONT 16
END SUB

FUNCTION Find& (L$) ' not used letter in puzzle and change hidden$ and report how many found
    REDIM i AS LONG, b$, rtn&
    b$ = ""
    FOR i = 1 TO LEN(Puzzle$)
        IF MID$(Puzzle$, i, 1) = L$ THEN b$ = b$ + L$: rtn& = rtn& + 1 ELSE b$ = b$ + MID$(Hidden$, i, 1)
    NEXT
    Hidden$ = b$
    Find& = rtn&
END FUNCTION

SUB ShowPuzzleBoard
    REDIM words$(1 TO 1), i AS LONG, j AS LONG
    Split Hidden$, " ", words$()


    '            DEBUG
    'PRINT LBOUND(words$), UBOUND(words$)
    'FOR i = LBOUND(words$) TO UBOUND(words$)
    '    PRINT words$(i)
    'NEXT
    'SLEEP

    LINE (0, Ymax - 430)-STEP(600, 180), &HFF000000, BF
    COLOR &HFFEEEEEE
    _PRINTSTRING (50, 210), "Category: " + Category$
    FOR i = 1 TO UBOUND(words$)
        FOR j = 1 TO LEN(words$(i))
            ShowLetterBox j * 50, 140 + i * 100, MID$(words$(i), j, 1), -1
        NEXT
    NEXT
END SUB

SUB ShowVowels
    REDIM i
    LINE (0, Ymax - 100)-STEP(600, 50), &HFF000000, BF
    FOR i = 1 TO LEN(VowelsAvail$)
        ShowLetterBox i * 25, Ymax - 100, MID$(VowelsAvail$, i, 1), 0
    NEXT
    _PRINTSTRING (160, Ymax - 100 + 12), "Vowels for sale @ $250"
END SUB

SUB ShowLetters
    REDIM i
    LINE (0, Ymax - 50)-STEP(600, 50), &HFF000000, BF
    FOR i = 1 TO LEN(LettersAvail$)
        ShowLetterBox i * 25, Ymax - 50, MID$(LettersAvail$, i, 1), 0
    NEXT
END SUB

SUB ShowLetterBox (x, y, L$, dbl)
    REDIM w AS LONG, h AS LONG
    COLOR &HFF000000, &HFFFFFFFF
    IF dbl THEN w = 41: h = 80: _FONT F40 ELSE w = 20: h = 40: _FONT F20
    IF L$ = "*" THEN
        LINE (x, y)-STEP(w, h), &HFF00AA33, BF
    ELSEIF L$ <> " " AND L$ <> "*" THEN
        LINE (x, y)-STEP(w, h), &HFFFFFFFF, BF
        IF dbl THEN
            _PRINTSTRING (x + 21 - _PRINTWIDTH(L$) / 2, y + 40 - _FONTHEIGHT(F40) / 2), L$
        ELSE
            _PRINTSTRING (x + 11 - _PRINTWIDTH(L$) / 2, y + 20 - _FONTHEIGHT(F20) / 2), L$
        END IF
    END IF
    _FONT 16
    COLOR &HFFFFFFFF, &HFF000000
END SUB

SUB GetPuzzle 'set the shared variable Puzzle$ and hide the letters
    REDIM last AS LONG, i AS LONG, fline$, save1$
    Puzzle$ = ""
    IF _FILEEXISTS("Fortune Puzzles with Categories.txt") THEN
        IF _FILEEXISTS("Last Fortune Puzzle.txt") THEN
            OPEN "Last Fortune Puzzle.txt" FOR INPUT AS #1
            INPUT #1, last
            CLOSE #1
            OPEN "Last Fortune Puzzle.txt" FOR OUTPUT AS #1
            PRINT #1, last + 1
            CLOSE #1
        ELSE
            last = 1
            OPEN "Last Fortune Puzzle.txt" FOR OUTPUT AS #1
            PRINT #1, last
            CLOSE #1
        END IF
        OPEN "Fortune Puzzles with Categories.txt" FOR INPUT AS #1
        WHILE NOT EOF(1)
            LINE INPUT #1, fline$
            i = i + 1
            IF i = last THEN
                Category$ = UCASE$(LeftOf$(fline$, "=")): Puzzle$ = UCASE$(RightOf$(fline$, "="))
                CLOSE #1: EXIT WHILE
                IF i = 1 THEN save1$ = fline$
            END IF
        WEND
        IF Puzzle$ = "" THEN ' use the first entry we saved
            Category$ = UCASE$(LeftOf$(save1$, "=")): Puzzle$ = UCASE$(RightOf$(save1$, "="))
            CLOSE #1
            OPEN "Last Fortune Puzzle.txt" FOR OUTPUT AS #1
            PRINT #1, "2"
            CLOSE #1
        END IF
    ELSE 'something! temporary

        PRINT " Warning: Fortune Puzzles with Categories.txt file not found, better fix problem."
        Puzzle$ = "LOAD FORTUNE COOKIES.TXT"
    END IF
    Hidden$ = ""
    FOR i = 1 TO LEN(Puzzle$)
        IF INSTR(Letters, MID$(Puzzle$, i, 1)) > 0 OR INSTR(Vowels, MID$(Puzzle$, i, 1)) > 0 THEN
            Hidden$ = Hidden$ + "*"
        ELSE
            Hidden$ = Hidden$ + MID$(Puzzle$, i, 1)
        END IF
    NEXT
    LettersAvail$ = Letters: VowelsAvail$ = Vowels

    'debug
    '_TITLE Puzzle$
    'Hidden$ = Puzzle$
END SUB

SUB UpdatePlayer (p02, focus)
    LINE (200 * p02, 110)-STEP(199, 100), &HFF000000, BF
    IF focus THEN
        COLOR &HFFFFFFFF
    ELSE
        SELECT CASE p02
            CASE 0: COLOR &HFFFF0000
            CASE 1: COLOR &HFFEEEE00
            CASE 2: COLOR &HFF0000FF
        END SELECT
    END IF
    _PRINTSTRING (200 * p02 + 50, 110), P(p02).Name
    _PRINTSTRING (200 * p02 + 50, 110 + 16), P(p02).Spin
    _PRINTSTRING (200 * p02 + 50, 110 + 32), "  Current: " + TS$(P(p02).Current)
    _PRINTSTRING (200 * p02 + 50, 110 + 48), " Winnings: " + TS$(P(p02).Game)
    _PRINTSTRING (200 * p02 + 50, 110 + 64), "Free Play: " + TS$(P(p02).FreePlay)
END SUB

FUNCTION SpinWheel$ (player$)
    REDIM yc, xc, a, stopAt AS LONG, l AS SINGLE
    COLOR &HFFFFFFFF: yc = 19 + 299: xc = Xmax - 19 - 299 ' practice spinning wheel
    stopAt = INT(RND * 24): l = (24 + stopAt) * 5
    FOR a = 0 TO (24 + stopAt) * CA STEP _PI(2 / 120) ' give it a right quick start
        Fcirc xc, yc, IRad - 1, &HFF000000
        RotoZoom2 0, xc, yc, Wheel&, 1, 1, -a
        LINE (xc - 3, yc - 315)-STEP(6, 20), &HFFFFFFFF, BF
        LINE (xc - 3, yc - 315)-STEP(6, 20), &HFF000000, B
        _PRINTSTRING (xc - _PRINTWIDTH(player$) / 2, yc - 16), player$
        _DISPLAY
        IF l > 2 THEN l = l - 1
        IF l > 30 THEN _LIMIT 30 ELSE _LIMIT l
    NEXT
    _PRINTSTRING (xc - _PRINTWIDTH(player$) / 2, yc - 16), player$
    _PRINTSTRING (xc - _PRINTWIDTH(WheelSpin$(stopAt)) / 2, yc), WheelSpin$(stopAt)
    _DISPLAY
    _DELAY 1
    SpinWheel$ = WheelSpin$(stopAt)
    _AUTODISPLAY
END FUNCTION

SUB MakeWheel
    REDIM WheelSpin$(0 TO 23), wC(23) AS _UNSIGNED LONG, x0, y0, midR, i AS LONG, s$, sc AS _UNSIGNED LONG
    REDIM ls, rr, rrd2, f, j AS LONG
    GOSUB initWheel
    Wheel& = _NEWIMAGE(599, 599, 32)
    _DEST Wheel&
    _SOURCE Wheel&
    x0 = 299: y0 = 299: midR = (ORad + IRad) / 2
    COLOR &HFF000000, &H00000000
    CIRCLE (x0, y0), ORad
    CIRCLE (x0, y0), IRad
    FOR i = 0 TO 23 ' wedge border
        LINE (x0 + IRad * COS(i * CA - Cad2), y0 + IRad * SIN(i * CA - Cad2))-(x0 + ORad * COS(i * CA - Cad2), y0 + ORad * SIN(i * CA - Cad2))
    NEXT
    FOR i = 0 TO 23
        PAINT (x0 + midR * COS(i * CA), y0 + midR * SIN(i * CA)), wC((i + 6) MOD 24), &HFF000000
        s$ = WheelSpin$((i + 6) MOD 24)
        IF s$ = "LOSE TURN" THEN
            sc = &HFF000000
        ELSEIF s$ = "BANKRUPT" THEN
            sc = &HFFFFFFFF
        ELSEIF s$ = "FREE PLAY" THEN
            sc = &HFFFFFF00
        ELSEIF LEN(s$) = 4 THEN
            sc = &HFF000000: s$ = "$" + s$
        ELSE 's$ = 3 char $ amt
            sc = &HFF000000: s$ = "$" + s$
        END IF
        ls = LEN(s$): rr = (ORad - IRad - 10) / ls: rrd2 = rr / 2 - 5: f = (rr / 90)
        FOR j = 1 TO ls
            f = rr / (58 + 8 * j)
            ' drwstring(S$, c AS _UNSIGNED LONG, midX, midY, xScale, yScale, Rotation)
            DrwString Wheel&, MID$(s$, j, 1), sc, x0 + (ORad - j * rr + rrd2) * COS(i * CA), y0 + (ORad - j * rr + rrd2) * SIN(i * CA), f, f, i * CA + _PI(1 / 2)
        NEXT
    NEXT
    _DEST 0
    _SOURCE 0
    EXIT SUB

    initWheel:
    WheelSpin$(0) = "LOSE TURN": wC(0) = &HFFFFFFFF
    WheelSpin$(1) = "2500": wC(1) = &HFFFF3310
    WheelSpin$(2) = "350": wC(2) = &HFFCC0099
    WheelSpin$(3) = "3500": wC(3) = &HFFFF6666
    WheelSpin$(4) = "700": wC(4) = &HFF00AA33
    WheelSpin$(5) = "1500": wC(5) = &HFFFF8800
    WheelSpin$(6) = "BANKRUPT": wC(6) = &HFF000000
    WheelSpin$(7) = "400": wC(7) = &HFFAA0066
    WheelSpin$(8) = "550": wC(8) = &HFF00AA00
    WheelSpin$(9) = "600": wC(9) = &HFFFFFF00
    WheelSpin$(10) = "450": wC(10) = &HFFCC1100
    WheelSpin$(11) = "950": wC(11) = &HFF0077AA
    WheelSpin$(12) = "650": wC(12) = &HFFEE6600
    WheelSpin$(13) = "900": wC(13) = &HFFAA0077
    WheelSpin$(14) = "750": wC(14) = &HFFFFFF00
    WheelSpin$(15) = "300": wC(15) = &HFFFF7777
    WheelSpin$(16) = "850": wC(16) = &HFFFF1100
    WheelSpin$(17) = "2000": wC(17) = &HFF0000FF
    WheelSpin$(18) = "500": wC(18) = &HFF009900
    WheelSpin$(19) = "3000": wC(19) = &HFFFF8888
    WheelSpin$(20) = "BANKRUPT": wC(20) = &HFF000000
    WheelSpin$(21) = "800": wC(21) = &HFF990088
    WheelSpin$(22) = "FREE PLAY": wC(22) = &HFF006600
    WheelSpin$(23) = "1000": wC(23) = &HFF0000FF
    RETURN
END SUB

'drwString needs sub RotoZoom2, intended for graphics screens using the default font.
'S$ is the string to display
'c is the color (will have a transparent background)
'midX and midY is the center of where you want to display the string
'xScale would multiply 8 pixel width of default font
'yScale would multiply the 16 pixel height of the default font
'Rotation is in Radian units, use _D2R to convert Degree units to Radian units
SUB DrwString (DH&, S$, C AS _UNSIGNED LONG, MidX, MidY, xScale, yScale, Rotation)
    REDIM storeFont&, storeDest&, tempI&
    storeFont& = _FONT
    storeDest& = _DEST
    _FONT FV72& ' loadfont at start and share handle
    tempI& = _NEWIMAGE(_PRINTWIDTH(S$), _FONTHEIGHT(FV72&), 32)
    _DEST tempI&
    _FONT FV72&
    COLOR C, _RGBA32(0, 0, 0, 0)
    _PRINTSTRING (0, 0), S$
    _DEST storeDest&
    RotoZoom2 DH&, MidX, MidY, tempI&, xScale, yScale, Rotation
    _FREEIMAGE tempI&
    _FONT storeFont&
END SUB

SUB RotoZoom2 (Dh&, X AS LONG, Y AS LONG, Image AS LONG, xScale AS SINGLE, yScale AS SINGLE, Rotation AS SINGLE)
    REDIM px(3) AS SINGLE, py(3) AS SINGLE, w&, h&, sinr!, cosr!, i&, x2&, y2&
    w& = _WIDTH(Image&): h& = _HEIGHT(Image&)
    px(0) = -w& / 2: py(0) = -h& / 2: px(1) = -w& / 2: py(1) = h& / 2
    px(2) = w& / 2: py(2) = h& / 2: px(3) = w& / 2: py(3) = -h& / 2
    sinr! = SIN(-Rotation): cosr! = COS(-Rotation)
    FOR i& = 0 TO 3
        x2& = (px(i&) * cosr! + sinr! * py(i&)) * xScale + X: y2& = (py(i&) * cosr! - px(i&) * sinr!) * yScale + Y
        px(i&) = x2&: py(i&) = y2&
    NEXT
    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, h& - 1)-(w& - 1, h& - 1), Image& TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2)), Dh&, _SMOOTH
    _MAPTRIANGLE _SEAMLESS(0, 0)-(w& - 1, 0)-(w& - 1, h& - 1), Image& TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2)), Dh&, _SMOOTH
END SUB

FUNCTION TS$ (n AS LONG)
    TS$ = _TRIM$(STR$(n))
END FUNCTION

'from Steve Gold standard
SUB Fcirc (CX AS INTEGER, CY AS INTEGER, R AS INTEGER, C AS _UNSIGNED LONG)
    DIM Radius AS INTEGER, RadiusError AS INTEGER
    DIM X AS INTEGER, Y AS INTEGER
    Radius = ABS(R): RadiusError = -Radius: X = Radius: Y = 0
    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB
    LINE (CX - X, CY)-(CX + X, CY), C, BF
    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    WEND
END SUB

'notes: REDIM the array(0) to be loaded before calling Split '<<<< IMPORTANT dynamic array and empty, can use any lbound though
'This SUB will take a given N delimited string, and delimiter$ and create an array of N+1 strings using the LBOUND of the given dynamic array to load.
'notes: the loadMeArray() needs to be dynamic string array and will not change the LBOUND of the array it is given.  rev 2019-08-27
SUB Split (SplitMeString AS STRING, delim AS STRING, loadMeArray() AS STRING)
    DIM curpos AS LONG, arrpos AS LONG, LD AS LONG, dpos AS LONG 'fix use the Lbound the array already has
    curpos = 1: arrpos = LBOUND(loadMeArray): LD = LEN(delim)
    dpos = INSTR(curpos, SplitMeString, delim)
    DO UNTIL dpos = 0
        loadMeArray(arrpos) = MID$(SplitMeString, curpos, dpos - curpos)
        arrpos = arrpos + 1
        IF arrpos > UBOUND(loadMeArray) THEN REDIM _PRESERVE loadMeArray(LBOUND(loadMeArray) TO UBOUND(loadMeArray) + 1000) AS STRING
        curpos = dpos + LD
        dpos = INSTR(curpos, SplitMeString, delim)
    LOOP
    loadMeArray(arrpos) = MID$(SplitMeString, curpos)
    REDIM _PRESERVE loadMeArray(LBOUND(loadMeArray) TO arrpos) AS STRING 'get the ubound correct
END SUB

FUNCTION LeftOf$ (source$, of$)
    IF INSTR(source$, of$) > 0 THEN LeftOf$ = _TRIM$(MID$(source$, 1, INSTR(source$, of$) - 1))
END FUNCTION

FUNCTION RightOf$ (source$, of$)
    IF INSTR(source$, of$) > 0 THEN RightOf$ = _TRIM$(MID$(source$, INSTR(source$, of$) + LEN(of$)))
END FUNCTION

