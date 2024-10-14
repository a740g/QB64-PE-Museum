$RESIZE:SMOOTH
SCREEN 7
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

TYPE Player
    score AS INTEGER
    Nomen AS STRING * 10
    Colr AS INTEGER
END TYPE

DIM SHARED SortArray(10) AS Player

LOCATE 2, 5
COLOR 1, 0
PRINT "Copyright (c) 2013 Tim Baxendale"
COLOR 15, 0
RECT -1, 67, 321, 50, 2
LOCATE 12, 16
PRINT "SNAKE 3.3!"
LOCATE 24, 8
COLOR 4, 0
PRINT "Press any key to start..."
DO
LOOP WHILE INKEY$ = ""

DIM wrap%, startSize%, lenIncrease%, foodTime%, dt%, pv%
GOTO SETTINGS

START:

COLOR 15, 0
CLS

xmove% = 10
ymove% = 0
DIM bodyX%(511)
DIM bodyY%(511)
DIM score AS INTEGER
score = 0
size% = startSize%
FOR i% = size% TO 0 STEP -1
    bodyX%(i%) = 140
    bodyY%(i%) = 80
NEXT

foodOut% = 0
DIM foodPos%(1)
t# = TIMER
IsChanged = 0

WHILE 1
    'Get the pressed key
    key$ = INKEY$
    DO
    LOOP WHILE INKEY$ <> ""
    SELECT CASE key$
        CASE CHR$(27)
            END
        CASE CHR$(0) + "H"
            IF ymove% <> 10 THEN
                ymove% = -10
                xmove% = 0
            END IF
        CASE CHR$(0) + "P"
            IF ymove% <> -10 THEN
                ymove% = 10
                xmove% = 0
            END IF
        CASE CHR$(0) + "K"
            IF xmove% <> 10 THEN
                ymove% = 0
                xmove% = -10
            END IF
        CASE CHR$(0) + "M"
            IF xmove% <> -10 THEN
                ymove% = 0
                xmove% = 10
            END IF
        CASE " "
            LOCATE 1, 1
            PRINT "Game Paused"
            DO
            LOOP WHILE INKEY$ <> " "
    END SELECT

    'Time for food?
    IF TIMER - t# > foodTime% AND foodOut% = 0 THEN
        t# = TIMER
        foodOut% = 1
        foodPos%(0) = Rand(0, 20) * 10
        foodPos%(1) = Rand(1, 18) * 10
    END IF

    'Is the food out?
    IF foodOut% = 1 THEN
        RECT foodPos%(0) + 1, foodPos%(1) + 1, 8, 8, 4
        PAINT (foodPos%(0) + 2, foodPos%(1) + 2), 4, 4
    END IF
  
    'Did ya get it?
    IF foodOut% = 1 AND (intersects(bodyX%(0), bodyY%(0), 8, 8, foodPos%(0), foodPos%(1)) OR intersects(bodyX%(0), bodyY%(0), 8, 8, foodPos%(0) + 4, foodPos%(1) + 4)) THEN
        PAINT (foodPos%(0) + 2, foodPos%(1) + 2), 1, 0
        size% = size% + lenIncrease%
        foodOut% = 0
        score = score + pv%
        IF snd% = 1 THEN SOUND 300, 1
        IsChanged = 1
    END IF

    'Erase the tail
    IF IsChanged = 0 THEN
        PAINT (bodyX%(size%) + 2, bodyY%(size%) + 2), 0, 0
    ELSE
        IsChanged = 0
    END IF

    'Move the body
    X = bodyX%(0) + xmove%
    y = bodyY%(0) + ymove%
   
    'Sort the body arrays
    FOR i% = size% TO 0 STEP -1
        bodyX%(i% + 1) = bodyX%(i%)
        bodyY%(i% + 1) = bodyY%(i%)
        IF X = bodyX%(i%) AND y = bodyY%(i%) THEN
            GOTO DEAD
        END IF
        IF X < 0 OR X >= 320 THEN
            IF wrap% = 0 THEN
                GOTO DEAD
            ELSE
                IF X < 0 THEN
                    X = 310
                ELSE
                    X = 0
                END IF
            END IF
        END IF
        IF y < 10 OR y >= 200 THEN
            IF wrap% = 0 THEN
                GOTO DEAD
            ELSE
                IF y < 10 THEN
                    y = 190
                ELSE
                    y = 10
                END IF
            END IF
        END IF
    NEXT

    bodyX%(0) = X
    bodyY%(0) = y

    'Draw the damn thing
    RECT bodyX%(0) + 1, bodyY%(0) + 1, 8, 8, 1
    PAINT (bodyX%(0) + 2, bodyY%(0) + 2), 1, 1
 
    _DELAY dt% / 10

    'Show me da score!
    LOCATE 1, 1
    PRINT "Score: ", score
    LINE (0, 9)-(320, 9), 2
    'RECT 0, 9, 319, 190, 15
WEND

DEAD:
PALETTE 0, 4
COLOR 15, 4
LOCATE 12, 16
PRINT "You Died!"
IF snd% = 1 THEN SOUND 37, 18
LOCATE 23, 7
PRINT "Press space to continue..."
DO
LOOP WHILE INKEY$ <> " "
COLOR 15, 0
HIGHSCORE score
GOTO START

SETTINGS:
OPEN "CONFIG.DAT" FOR RANDOM AS #1
IF LOF(1) <= 0 THEN
    wrap% = 0
    PUT #1, 1, wrap%
    startSize% = 4
    PUT #1, 2, startSize%
    lenIncrease% = 3
    PUT #1, 3, lenIncrease%
    foodTime% = 5
    PUT #1, 4, foodTime%
    dt% = 1
    PUT #1, 5, dt%
    pv% = 5
    PUT #1, 6, pv%
    snd% = 1
    PUT #1, 7, snd%
END IF
GET #1, 1, wrap%
GET #1, 2, startSize%
GET #1, 3, lenIncrease%
GET #1, 4, foodTime%
GET #1, 5, dt%
GET #1, 6, pv%
GET #1, 7, snd%
CLOSE #1
GOTO START

SUB FOOD
    X% = Rand(0, 200)
    y% = Rand(0, 180)
    RECT X%, y%, 20, 20, 3
END SUB

SUB HIGHSCORE (score%)
    DIM p AS Player
    OPEN "SCORE.DAT" FOR RANDOM AS #1
    IF LOF(1) <= 0 THEN
        FOR i = 1 TO 10
            p.Nomen = RandomName$
            p.score = Rand(1, 20) * 5
            p.Colr = 1
            PUT #1, i, p
        NEXT
    END IF

    CLS

    ISHIGHSCORE = 0

    FOR i = 1 TO 10
        GET #1, i, p
        SortArray(i) = p
        IF p.score < score% THEN
            ISHIGHSCORE = 1
        END IF
    NEXT

    IF ISHIGHSCORE = 1 THEN
        DIM newPlayer AS Player
        PRINT "You got a high score!"
        DO
            INPUT "Please enter your name: ", Nomen$
        LOOP WHILE LEN(Nomen$) = 0 OR LEN(Nomen$) > 10
        newPlayer.Nomen = Nomen$
        newPlayer.score = score%
        newPlayer.Colr = 15
        SortArray(0) = newPlayer
    END IF

    QuickSort 0, 10

    place = 1
    cnt = 1
    CLS
    PRINT "", "High Scores"
    PRINT ""

    FOR i = 10 TO 1 STEP -1
        IF SortArray(i).score = last% THEN
            place = place - 1
        END IF
        COLOR (SortArray(i).Colr), 0
        LOCATE (cnt * 2) + 1, 9
        PRINT place; ">"
        LOCATE (cnt * 2) + 1, 15
        PRINT SortArray(i).Nomen
        LOCATE (cnt * 2) + 1, 27
        PRINT SortArray(i).score,
        PRINT ""
        PUT #1, i, SortArray(i)
        last% = SortArray(i).score
        place = place + 1
        cnt = cnt + 1
    NEXT
    CLOSE #1
    COLOR 3

    COLOR 4, 0
    LOCATE 23, 4
    PRINT "Press ESC to exit or R to restart"
    WHILE 1
        k$ = INKEY$

        IF k$ = CHR$(27) THEN END
        IF k$ = "r" THEN GOTO Restart

    WEND
    Restart:
END SUB

FUNCTION intersects (x1%, y1%, w1%, h1%, x2%, y2%)
    IF x2% < x1% + w1% AND x2% > x1% AND y2% < y1% + h1% AND y2% > y1% THEN
        intersects = INT(1)
    ELSE
        intersects = INT(0)
    END IF
END FUNCTION

DEFINT A-Z
' ============================== QuickSort ===================================
'   QuickSort works by picking a random "pivot" element in SortArray, then
'   moving every element that is bigger to one side of the pivot, and every
'   element that is smaller to the other side.  QuickSort is then called
'   recursively with the two subdivisions created by the pivot.  Once the
'   number of elements in a subdivision reaches two, the recursive calls end
'   and the array is sorted.
' ============================================================================
'
SUB QuickSort (LOW, HIGH)
    IF LOW < HIGH THEN

        ' Only two elements in this subdivision; swap them if they are out of
        ' order, then end recursive calls:
        IF HIGH - LOW = 1 THEN
            IF SortArray(LOW).score > SortArray(HIGH).score THEN
                SWAP SortArray(LOW), SortArray(HIGH)
                'SwapBars Low, High
            END IF
        ELSE

            ' Pick a pivot element at random, then move it to the end:
            RandIndex = RandInt%(LOW, HIGH)
            SWAP SortArray(HIGH), SortArray(RandIndex)
            'SwapBars High, RandIndex
            Partition = SortArray(HIGH).score
            DO

                ' Move in from both sides towards the pivot element:
                i = LOW: J = HIGH
                DO WHILE (i < J) AND (SortArray(i).score <= Partition)
                    i = i + 1
                LOOP
                DO WHILE (J > i) AND (SortArray(J).score >= Partition)
                    J = J - 1
                LOOP

                ' If we haven't reached the pivot element, it means that two
                ' elements on either side are out of order, so swap them:
                IF i < J THEN
                    SWAP SortArray(i), SortArray(J)
                    'SwapBars i, J
                END IF
            LOOP WHILE i < J

            ' Move the pivot element back to its proper place in the array:
            SWAP SortArray(i), SortArray(HIGH)
            'SwapBars i, High

            ' Recursively call the QuickSort procedure (pass the smaller
            ' subdivision first to use less stack space):
            IF (i - LOW) < (HIGH - i) THEN
                QuickSort LOW, i - 1
                QuickSort i + 1, HIGH
            ELSE
                QuickSort i + 1, HIGH
                QuickSort LOW, i - 1
            END IF
        END IF
    END IF
END SUB

DEFSNG A-Z
FUNCTION Rand (Bottom, Top)
    RANDOMIZE TIMER
    RANDOMIZE RND
    Rand = INT((Top - Bottom + 1) * RND + Bottom)
END FUNCTION

DEFINT A-Z
' =============================== RandInt% ===================================
'   Returns a random integer greater than or equal to the Lower parameter
'   and less than or equal to the Upper parameter.
' ============================================================================
'
FUNCTION RandInt% (lower, Upper) STATIC
    RandInt% = INT(RND * (Upper - lower + 1)) + lower
END FUNCTION

DEFSNG A-Z
FUNCTION RandomName$ ()
    SELECT CASE Rand(0, 22)
        CASE 0
            RandomName$ = "Dan"
        CASE 1
            RandomName$ = "Matt"
        CASE 2
            RandomName$ = "Annie"
        CASE 3
            RandomName$ = "Mary C"
        CASE 4
            RandomName$ = "Jake"
        CASE 5
            RandomName$ = "Michael G"
        CASE 6
            RandomName$ = "Timothy P"
        CASE 7
            RandomName$ = "Stephen F"
        CASE 8
            RandomName$ = "Joseph P"
        CASE 9
            RandomName$ = "Kate"
        CASE 10
            RandomName$ = "Peter A"
        CASE 11
            RandomName$ = "John C"
        CASE 12
            RandomName$ = "Gracie"
        CASE 13
            RandomName$ = "Claire"
        CASE 14
            RandomName$ = "Frank"
        CASE 15
            RandomName$ = "Meaghan"
        CASE 16
            RandomName$ = "Maddie"
        CASE 17
            RandomName$ = "Andrew"
        CASE 18
            RandomName$ = "Jason"
        CASE 19
            RandomName$ = "Paul"
        CASE 20
            RandomName$ = "David"
        CASE 21
            RandomName$ = "Jon Jon"
        CASE 22
            RandomName$ = "Emilie"
    END SELECT
END FUNCTION

SUB RECT (X%, y%, W%, H%, C%)
    LINE (X%, y%)-(X% + W%, y%), C%
    LINE (X%, y%)-(X%, y% + H%), C%
    LINE (X% + W%, y%)-(X% + W%, y% + H%), C%
    LINE (X%, y% + H%)-(X% + W%, y% + H%), C%
END SUB
