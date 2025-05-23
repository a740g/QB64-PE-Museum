'-----------------------------------------------------------------------------------------------------
'                                 SORTDEMO
' This program graphically demonstrates six common sorting algorithms.  It
' prints 25 or 43 horizontal bars, all of different lengths and all in random
' order, then sorts the bars from smallest to longest.
'
' The program also uses SOUND statements to generate different pitches,
' depending on the location of the bar being printed. Note that the SOUND
' statements delay the speed of each sorting algorithm so you can follow
' the progress of the sort.  Therefore, the times shown are for comparison
' only. They are not an accurate measure of sort speed.
'
' If you use these sorting routines in your own programs, you may notice
' a difference in their relative speeds (for example, the exchange
' sort may be faster than the shell sort) depending on the number of
' elements to be sorted and how "scrambled" they are to begin with.
'-----------------------------------------------------------------------------------------------------

DEFINT A-Z
OPTION _EXPLICIT
OPTION BASE 1
'$STATIC
$RESIZE:SMOOTH
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_TITLE "Sort Demo"

' Define the data type used to hold the information for each colored bar:
TYPE SortType
    Length AS INTEGER ' Bar length (the element compared in the different sorts)
    ColorVal AS INTEGER ' Bar color
    BarString AS STRING * 43 ' The bar (a string of 43 characters)
END TYPE

' Declare global constants:
CONST FALSE = 0, TRUE = NOT FALSE
CONST LEFTCOLUMN = 49, NUMOPTIONS = 11, NUMSORTS = 6

' Declare global variables, and allocate storage space for them.  SortArray
' and SortBackup are both arrays of the data type SortType defined above:
DIM SHARED SortArray(1 TO 43) AS SortType, SortBackup(1 TO 43) AS SortType
DIM SHARED OptionTitle(1 TO NUMOPTIONS) AS STRING * 12
DIM SHARED StartTime AS SINGLE
DIM SHARED Foreground, Background, NoSound, Pause
DIM SHARED Selection, MaxRow, InitRow, MaxColors

' Data statements for the different options printed in the sort menu:
DATA Insertion,Bubble,Heap,Exchange,Shell,Quick,
DATA Toggle Sound,,<   (Slower),>   (Faster)

' Begin logic of module-level code:

Initialize ' Initialize data values.
SortMenu ' Print sort menu.
WIDTH 80, InitRow ' Restore original number of rows.
COLOR 7, 0 ' Restore default color
SYSTEM

' GetRow, MonoTrap, and RowTrap are error-handling routines invoked by
' the CheckScreen SUB procedure.  GetRow determines whether the program
' started with 25, 43, or 50 lines.  MonoTrap determines the current
' video adapter is monochrome.  RowTrap sets the maximum possible
' number of rows (43 or 25).

GetRow:
IF InitRow = 50 THEN
    InitRow = 43
    RESUME
ELSE
    InitRow = 25
    RESUME NEXT
END IF

MonoTrap:
MaxColors = 2
RESUME NEXT

RowTrap:
MaxRow = 25
RESUME

' =============================== BoxInit ====================================
'    Calls the DrawFrame procedure to draw the frame around the sort menu,
'    then prints the different options stored in the OptionTitle array.
' ============================================================================
'
SUB BoxInit STATIC
    DrawFrame 1, 22, LEFTCOLUMN - 3, 78
    DIM AS INTEGER i

    LOCATE 3, LEFTCOLUMN + 2: PRINT "QUICKBASIC SORTING DEMO";
    LOCATE 5
    FOR i = 1 TO NUMOPTIONS - 1
        LOCATE , LEFTCOLUMN: PRINT OptionTitle(i)
    NEXT i

    ' Don't print the last option (> Faster) if the length of the Pause
    ' is down to 1 clock tick:
    IF Pause > 1 THEN LOCATE , LEFTCOLUMN: PRINT OptionTitle(NUMOPTIONS);

    ' Toggle sound on or off, then print the current value for NoSound:
    NoSound = NOT NoSound
    ToggleSound 12, LEFTCOLUMN + 12

    LOCATE NUMOPTIONS + 6, LEFTCOLUMN
    PRINT "Type first character of"
    LOCATE , LEFTCOLUMN
    PRINT "choice ( I B H E S Q T < > )"
    LOCATE , LEFTCOLUMN
    PRINT "or ESC key to end program: ";
END SUB

' ============================== BubbleSort ==================================
'    The BubbleSort algorithm cycles through SortArray, comparing adjacent
'    elements and swapping pairs that are out of order.  It continues to
'    do this until no pairs are swapped.
' ============================================================================
'
SUB BubbleSort STATIC
    DIM AS INTEGER RowLimit, Switch, Row

    RowLimit = MaxRow
    DO
        Switch = FALSE
        FOR Row = 1 TO (RowLimit - 1)

            ' Two adjacent elements are out of order, so swap their values
            ' and redraw those two bars:
            IF SortArray(Row).Length > SortArray(Row + 1).Length THEN
                SWAP SortArray(Row), SortArray(Row + 1)
                SwapBars Row, Row + 1
                Switch = Row
            END IF
        NEXT Row

        ' Sort on next pass only to where the last switch was made:
        RowLimit = Switch
    LOOP WHILE Switch
END SUB

' ============================== CheckScreen =================================
'     Checks for type of monitor (VGA, EGA, CGA, or monochrome) and
'     starting number of screen lines (50, 43, or 25).
' ============================================================================
'
SUB CheckScreen STATIC
    ' Try locating to the 50th row; if that fails, try the 43rd. Finally,
    ' if that fails, the user was using 25-line mode:
    InitRow = 50
    ON ERROR GOTO GetRow
    LOCATE InitRow, 1

    ' Try a SCREEN 1 statement to see if the current adapter has color
    ' graphics; if that causes an error, reset MaxColors to 2:
    MaxColors = 15
    ON ERROR GOTO MonoTrap
    SCREEN 1
    SCREEN 0

    ' See if 43-line mode is accepted; if not, run this program in 25-line
    ' mode:
    MaxRow = 43
    ON ERROR GOTO RowTrap
    WIDTH 80, MaxRow
    ON ERROR GOTO 0 ' Turn off error trapping.
END SUB

' ============================== DrawFrame ===================================
'   Draws a rectangular frame using the high-order ASCII characters � (201) ,
'   � (187) , � (200) , � (188) , � (186) , and � (205). The parameters
'   TopSide, BottomSide, LeftSide, and RightSide are the row and column
'   arguments for the upper-left and lower-right corners of the frame.
' ============================================================================
'
SUB DrawFrame (TopSide, BottomSide, LeftSide, RightSide) STATIC
    DIM AS INTEGER FrameWidth, Row

    CONST ULEFT = 201, URIGHT = 187, LLEFT = 200, LRIGHT = 188
    CONST VERTICAL = 186, HORIZONTAL = 205

    FrameWidth = RightSide - LeftSide - 1
    LOCATE TopSide, LeftSide
    PRINT CHR$(ULEFT); STRING$(FrameWidth, HORIZONTAL); CHR$(URIGHT);
    FOR Row = TopSide + 1 TO BottomSide - 1
        LOCATE Row, LeftSide
        PRINT CHR$(VERTICAL); SPC(FrameWidth); CHR$(VERTICAL);
    NEXT Row
    LOCATE BottomSide, LeftSide
    PRINT CHR$(LLEFT); STRING$(FrameWidth, HORIZONTAL); CHR$(LRIGHT);
END SUB

' ============================= ElapsedTime ==================================
'    Prints seconds elapsed since the given sorting routine started.
'    Note that this time includes both the time it takes to redraw the
'    bars plus the pause while the SOUND statement plays a note, and
'    thus is not an accurate indication of sorting speed.
' ============================================================================
'
SUB ElapsedTime (CurrentRow) STATIC
    CONST FORMAT = "  &###.### seconds  "

    ' Print current selection and number of seconds elapsed in
    ' reverse video:
    COLOR Foreground, Background
    LOCATE Selection + 4, LEFTCOLUMN - 2
    PRINT USING FORMAT; OptionTitle(Selection); TIMER - StartTime;

    IF NoSound THEN
        _DELAY Pause / 15
    ELSE
        SOUND 60 * CurrentRow, Pause ' Sound on, so play a note while
        _DELAY Pause / 15
    END IF ' pausing.

    COLOR MaxColors, 0 ' Restore regular foreground and
    ' background colors.
END SUB

' ============================= ExchangeSort =================================
'   The ExchangeSort compares each element in SortArray - starting with
'   the first element - with every following element.  If any of the
'   following elements is smaller than the current element, it is exchanged
'   with the current element and the process is repeated for the next
'   element in SortArray.
' ============================================================================
'
SUB ExchangeSort STATIC
    DIM AS INTEGER Row, SmallestRow, j

    FOR Row = 1 TO MaxRow
        SmallestRow = Row
        FOR j = Row + 1 TO MaxRow
            IF SortArray(j).Length < SortArray(SmallestRow).Length THEN
                SmallestRow = j
                ElapsedTime j
            END IF
        NEXT j

        ' Found a row shorter than the current row, so swap those
        ' two array elements:
        IF SmallestRow > Row THEN
            SWAP SortArray(Row), SortArray(SmallestRow)
            SwapBars Row, SmallestRow
        END IF
    NEXT Row
END SUB

' =============================== HeapSort ===================================
'  The HeapSort procedure works by calling two other procedures - PercolateUp
'  and PercolateDown.  PercolateUp turns SortArray into a "heap," which has
'  the properties outlined in the diagram below:
'
'                               SortArray(1)
'                               /          \
'                    SortArray(2)           SortArray(3)
'                   /          \            /          \
'         SortArray(4)   SortArray(5)   SortArray(6)  SortArray(7)
'          /      \       /       \       /      \      /      \
'        ...      ...   ...       ...   ...      ...  ...      ...
'
'
'  where each "parent node" is greater than each of its "child nodes"; for
'  example, SortArray(1) is greater than SortArray(2) or SortArray(3),
'  SortArray(3) is greater than SortArray(6) or SortArray(7), and so forth.
'
'  Therefore, once the first FOR...NEXT loop in HeapSort is finished, the
'  largest element is in SortArray(1).
'
'  The second FOR...NEXT loop in HeapSort swaps the element in SortArray(1)
'  with the element in MaxRow, rebuilds the heap (with PercolateDown) for
'  MaxRow - 1, then swaps the element in SortArray(1) with the element in
'  MaxRow - 1, rebuilds the heap for MaxRow - 2, and continues in this way
'  until the array is sorted.
' ============================================================================
'
SUB HeapSort STATIC
    DIM AS INTEGER i

    FOR i = 2 TO MaxRow
        PercolateUp i
    NEXT i

    FOR i = MaxRow TO 2 STEP -1
        SWAP SortArray(1), SortArray(i)
        SwapBars 1, i
        PercolateDown i - 1
    NEXT i
END SUB

' ============================== Initialize ==================================
'    Initializes the SortBackup and OptionTitle arrays.  It also calls the
'    CheckScreen, BoxInit, and RandInt% procedures.
' ============================================================================
'
SUB Initialize STATIC
    DIM TempArray(1 TO 43)
    DIM AS INTEGER i, MaxIndex, Index, BarLength

    CheckScreen ' Check for monochrome or EGA and set
    ' maximum number of text lines.
    FOR i = 1 TO MaxRow
        TempArray(i) = i
    NEXT i

    MaxIndex = MaxRow

    RANDOMIZE TIMER ' Seed the random-number generator.
    FOR i = 1 TO MaxRow

        ' Call RandInt% to find a random element in TempArray between 1
        ' and MaxIndex, then assign the value in that element to BarLength:
        Index = RandInt%(1, MaxIndex)
        BarLength = TempArray(Index)

        ' Overwrite the value in TempArray(Index) with the value in
        ' TempArray(MaxIndex) so the value in TempArray(Index) is
        ' chosen only once:
        TempArray(Index) = TempArray(MaxIndex)

        ' Decrease the value of MaxIndex so that TempArray(MaxIndex) can't
        ' be chosen on the next pass through the loop:
        MaxIndex = MaxIndex - 1

        ' Assign the BarLength value to the .Length element, then store
        ' a string of BarLength block characters (ASCII 223: �) in the
        ' .BarString element:
        SortBackup(i).Length = BarLength
        SortBackup(i).BarString = STRING$(BarLength, 223)

        ' Store the appropriate color value in the .ColorVal element:
        IF MaxColors > 2 THEN
            SortBackup(i).ColorVal = (BarLength MOD MaxColors) + 1
        ELSE
            SortBackup(i).ColorVal = MaxColors
        END IF
    NEXT i

    FOR i = 1 TO NUMOPTIONS ' Read SORT DEMO menu options and store
        READ OptionTitle(i) ' them in the OptionTitle array.
    NEXT i

    CLS
    Reinitialize ' Assign values in SortBackup to SortArray and draw
    ' unsorted bars on the screen.
    NoSound = FALSE
    Pause = 2 ' Initialize Pause to 2 clock ticks (@ 1/9 second).
    BoxInit ' Draw frame for the sort menu and print options.
END SUB

' ============================= InsertionSort ================================
'   The InsertionSort procedure compares the length of each successive
'   element in SortArray with the lengths of all the preceding elements.
'   When the procedure finds the appropriate place for the new element, it
'   inserts the element in its new place, and moves all the other elements
'   down one place.
' ============================================================================
'
SUB InsertionSort STATIC
    DIM TempVal AS SortType
    DIM AS INTEGER Row, TempLength, j

    FOR Row = 2 TO MaxRow
        TempVal = SortArray(Row)
        TempLength = TempVal.Length
        FOR j = Row TO 2 STEP -1

            ' As long as the length of the J-1st element is greater than the
            ' length of the original element in SortArray(Row), keep shifting
            ' the array elements down:
            IF SortArray(j - 1).Length > TempLength THEN
                SortArray(j) = SortArray(j - 1)
                PrintOneBar j ' Print the new bar.
                ElapsedTime j ' Print the elapsed time.

                ' Otherwise, exit the FOR...NEXT loop:
            ELSE
                EXIT FOR
            END IF
        NEXT j

        ' Insert the original value of SortArray(Row) in SortArray(J):
        SortArray(j) = TempVal
        PrintOneBar j
        ElapsedTime j
    NEXT Row
END SUB

' ============================ PercolateDown =================================
'   The PercolateDown procedure restores the elements of SortArray from 1 to
'   MaxLevel to a "heap" (see the diagram with the HeapSort procedure).
' ============================================================================
'
SUB PercolateDown (MaxLevel) STATIC
    DIM AS INTEGER i, Child

    i = 1

    ' Move the value in SortArray(1) down the heap until it has
    ' reached its proper node (that is, until it is less than its parent
    ' node or until it has reached MaxLevel, the bottom of the current heap):
    DO
        Child = 2 * i ' Get the subscript for the child node.

        ' Reached the bottom of the heap, so exit this procedure:
        IF Child > MaxLevel THEN EXIT DO

        ' If there are two child nodes, find out which one is bigger:
        IF Child + 1 <= MaxLevel THEN
            IF SortArray(Child + 1).Length > SortArray(Child).Length THEN
                Child = Child + 1
            END IF
        END IF

        ' Move the value down if it is still not bigger than either one of
        ' its children:
        IF SortArray(i).Length < SortArray(Child).Length THEN
            SWAP SortArray(i), SortArray(Child)
            SwapBars i, Child
            i = Child

            ' Otherwise, SortArray has been restored to a heap from 1 to MaxLevel,
            ' so exit:
        ELSE
            EXIT DO
        END IF
    LOOP
END SUB

' ============================== PercolateUp =================================
'   The PercolateUp procedure converts the elements from 1 to MaxLevel in
'   SortArray into a "heap" (see the diagram with the HeapSort procedure).
' ============================================================================
'
SUB PercolateUp (MaxLevel) STATIC
    DIM AS INTEGER i, Parent

    i = MaxLevel

    ' Move the value in SortArray(MaxLevel) up the heap until it has
    ' reached its proper node (that is, until it is greater than either
    ' of its child nodes, or until it has reached 1, the top of the heap):
    DO UNTIL i = 1
        Parent = i \ 2 ' Get the subscript for the parent node.

        ' The value at the current node is still bigger than the value at
        ' its parent node, so swap these two array elements:
        IF SortArray(i).Length > SortArray(Parent).Length THEN
            SWAP SortArray(Parent), SortArray(i)
            SwapBars Parent, i
            i = Parent

            ' Otherwise, the element has reached its proper place in the heap,
            ' so exit this procedure:
        ELSE
            EXIT DO
        END IF
    LOOP
END SUB

' ============================== PrintOneBar =================================
'  Prints SortArray(Row).BarString at the row indicated by the Row
'  parameter, using the color in SortArray(Row).ColorVal.
' ============================================================================
'
SUB PrintOneBar (Row) STATIC
    LOCATE Row, 1
    COLOR SortArray(Row).ColorVal
    PRINT SortArray(Row).BarString;
END SUB

' ============================== QuickSort ===================================
'   QuickSort works by picking a random "pivot" element in SortArray, then
'   moving every element that is bigger to one side of the pivot, and every
'   element that is smaller to the other side.  QuickSort is then called
'   recursively with the two subdivisions created by the pivot.  Once the
'   number of elements in a subdivision reaches two, the recursive calls end
'   and the array is sorted.
' ============================================================================
'
SUB QuickSort (Low, High)
    DIM AS INTEGER RandIndex, Partition, i, j

    IF Low < High THEN

        ' Only two elements in this subdivision; swap them if they are out of
        ' order, then end recursive calls:
        IF High - Low = 1 THEN
            IF SortArray(Low).Length > SortArray(High).Length THEN
                SWAP SortArray(Low), SortArray(High)
                SwapBars Low, High
            END IF
        ELSE

            ' Pick a pivot element at random, then move it to the end:
            RandIndex = RandInt%(Low, High)
            SWAP SortArray(High), SortArray(RandIndex)
            SwapBars High, RandIndex
            Partition = SortArray(High).Length
            DO

                ' Move in from both sides towards the pivot element:
                i = Low: j = High
                DO WHILE (i < j) AND (SortArray(i).Length <= Partition)
                    i = i + 1
                LOOP
                DO WHILE (j > i) AND (SortArray(j).Length >= Partition)
                    j = j - 1
                LOOP

                ' If we haven't reached the pivot element, it means that two
                ' elements on either side are out of order, so swap them:
                IF i < j THEN
                    SWAP SortArray(i), SortArray(j)
                    SwapBars i, j
                END IF
            LOOP WHILE i < j

            ' Move the pivot element back to its proper place in the array:
            SWAP SortArray(i), SortArray(High)
            SwapBars i, High

            ' Recursively call the QuickSort procedure (pass the smaller
            ' subdivision first to use less stack space):
            IF (i - Low) < (High - i) THEN
                QuickSort Low, i - 1
                QuickSort i + 1, High
            ELSE
                QuickSort i + 1, High
                QuickSort Low, i - 1
            END IF
        END IF
    END IF
END SUB

' =============================== RandInt% ===================================
'   Returns a random integer greater than or equal to the Lower parameter
'   and less than or equal to the Upper parameter.
' ============================================================================
'
FUNCTION RandInt% (lower, Upper) STATIC
    RandInt% = INT(RND * (Upper - lower + 1)) + lower
END FUNCTION

' ============================== Reinitialize ================================
'   Restores the array SortArray to its original unsorted state, then
'   prints the unsorted color bars.
' ============================================================================
'
SUB Reinitialize STATIC
    DIM AS INTEGER i

    FOR i = 1 TO MaxRow
        SortArray(i) = SortBackup(i)
    NEXT i

    FOR i = 1 TO MaxRow
        LOCATE i, 1
        COLOR SortArray(i).ColorVal
        PRINT SortArray(i).BarString;
    NEXT i

    COLOR MaxColors, 0
END SUB

' =============================== ShellSort ==================================
'  The ShellSort procedure is similar to the BubbleSort procedure.  However,
'  ShellSort begins by comparing elements that are far apart (separated by
'  the value of the Offset variable, which is initially half the distance
'  between the first and last element), then comparing elements that are
'  closer together (when Offset is one, the last iteration of this procedure
'  is merely a bubble sort).
' ============================================================================
'
SUB ShellSort STATIC
    DIM AS INTEGER RowOffset, RowLimit, Switch, Row

    ' Set comparison offset to half the number of records in SortArray:
    RowOffset = MaxRow \ 2

    DO WHILE RowOffset > 0 ' Loop until offset gets to zero.
        RowLimit = MaxRow - RowOffset
        DO
            Switch = FALSE ' Assume no switches at this offset.

            ' Compare elements and switch ones out of order:
            FOR Row = 1 TO RowLimit
                IF SortArray(Row).Length > SortArray(Row + RowOffset).Length THEN
                    SWAP SortArray(Row), SortArray(Row + RowOffset)
                    SwapBars Row, Row + RowOffset
                    Switch = Row
                END IF
            NEXT Row

            ' Sort on next pass only to where last switch was made:
            RowLimit = Switch - RowOffset
        LOOP WHILE Switch

        ' No switches at last offset, try one half as big:
        RowOffset = RowOffset \ 2
    LOOP
END SUB

' =============================== SortMenu ===================================
'   The SortMenu procedure first calls the Reinitialize procedure to make
'   sure the SortArray is in its unsorted form, then prompts the user to
'   make one of the following choices:
'
'               * One of the sorting algorithms
'               * Toggle sound on or off
'               * Increase or decrease speed
'               * End the program
' ============================================================================
'
SUB SortMenu STATIC
    DIM AS STRING sEscape, sOption, sChoice

    sEscape = CHR$(27)

    ' Create a string consisting of all legal choices:
    sOption = "IBHESQ><T" + sEscape

    DO

        ' Make the cursor visible:
        LOCATE NUMOPTIONS + 8, LEFTCOLUMN + 27, 1

        sChoice = UCASE$(INPUT$(1)) ' Get the user's choice and see
        Selection = INSTR(sOption, sChoice) ' if it's one of the menu options.

        ' User chose one of the sorting procedures:
        IF (Selection >= 1) AND (Selection <= NUMSORTS) THEN
            Reinitialize ' Rescramble the bars.
            LOCATE , , 0 ' Make the cursor invisible.
            Foreground = 0 ' Set reverse-video values.
            Background = 7
            StartTime = TIMER ' Record the starting time.
        END IF

        ' Branch to the appropriate procedure depending on the key typed:
        SELECT CASE sChoice
            CASE "I"
                InsertionSort
            CASE "B"
                BubbleSort
            CASE "H"
                HeapSort
            CASE "E"
                ExchangeSort
            CASE "S"
                ShellSort
            CASE "Q"
                QuickSort 1, MaxRow
            CASE ">"

                ' Decrease pause length to speed up sorting time, then redraw
                ' the menu to clear any timing results (since they won't compare
                ' with future results):
                Pause = (2 * Pause) / 3
                BoxInit

            CASE "<"

                ' Increase pause length to slow down sorting time, then redraw
                ' the menu to clear any timing results (since they won't compare
                ' with future results):
                Pause = (3 * Pause) / 2
                BoxInit

            CASE "T"
                ToggleSound 12, LEFTCOLUMN + 12

            CASE sEscape

                ' User pressed ESC, so exit this procedure and return to
                ' module level:
                EXIT DO

            CASE ELSE

                ' Invalid key
        END SELECT

        IF (Selection >= 1) AND (Selection <= NUMSORTS) THEN
            Foreground = MaxColors ' Turn off reverse video.
            Background = 0
            ElapsedTime 0 ' Print final time.
        END IF

    LOOP
END SUB

' =============================== SwapBars ===================================
'   Calls PrintOneBar twice to switch the two bars in Row1 and Row2,
'   then calls the ElapsedTime procedure.
' ============================================================================
'
SUB SwapBars (Row1, Row2) STATIC
    PrintOneBar Row1
    PrintOneBar Row2
    ElapsedTime Row1
END SUB

' ============================== ToggleSound =================================
'   Reverses the current value for NoSound, then prints that value next
'   to the "Toggle Sound" option on the sort menu.
' ============================================================================
'
SUB ToggleSound (Row, Column) STATIC
    NoSound = NOT NoSound
    LOCATE Row, Column
    IF NoSound THEN
        PRINT ": OFF";
    ELSE
        PRINT ": ON ";
    END IF
END SUB

