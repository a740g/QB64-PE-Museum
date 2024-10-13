'**************************************************************************************************
'**SORTING VISUALIZER by AKITA SOFT (C) 2021**
'**FEEL FREE TO USE HOW YOU WANT WITHOUT LICENSE!**
'**************************************************************************************************
_TITLE "Bubble Sort Visualizer"
'**************************************************************************************************
'*VARIABLES
'**************************************************************************************************
soundOn = 1
numOfValues = 35 'Random number amount
maxNum = 470 'Maximum value of random numbers
lineThickness = 16 'Thickness of graphical lines
leftOffset = 50 'Start how far from left of screen
lowerOffset = 470 'Start how low down the screen
swapCount = -1 'Initialize Swap Count
delayTime = .04 'Global delay value
DIM rndNums(numOfValues) AS INTEGER 'Make sure this one is an integer just in case, do it up top to avoid problems

'**************************************************************************************************
'*COLORS
'**************************************************************************************************

CONST red = _RGB32(255, 0, 0)
CONST green = _RGB32(0, 255, 0)
CONST blue = _RGB32(0, 0, 255)
CONST yellow = _RGB32(255, 255, 0)
CONST black = _RGB32(0, 0, 0)

'**************************************************************************************************
'*INIT SCREEN
'**************************************************************************************************

screenWidth = 640
screenHeight = 480
SCREEN _NEWIMAGE(screenWidth, screenHeight, 32) 'Initialize the screen
_LIMIT 30 'Limit Framerate

'**************************************************************************************************
' MAIN FUNCTION
'**************************************************************************************************

main:
CLS

'SLEEP
GOSUB rngArrayFill
GOSUB printArray
GOSUB bubbleSort

END

'**************************************************************************************************
' SUBROUNTINES
'**************************************************************************************************

printArray:
CLS
_DELAY delayTime
FOR i = 0 TO numOfValues

    'Print text output displaying"RNG" ;abel and numbers generated
    LOCATE 1, 1
    PRINT "       "
    LOCATE 1, 1
    PRINT "RNG"

    LOCATE 2, 1
    PRINT "   "
    LOCATE 2, 1
    PRINT rndNums(i)

    'Starting at 0, loop drawing lines to create thickness based off var lineThickness
    'Remember QB64 is 0 based, not 1 based
    FOR z = 0 TO (lineThickness - 1)
        LINE ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), yellow

    NEXT z

    _DELAY delayTime 'Delay so we can see it

NEXT i

RETURN


'**************************************************************************************************
bubbleSort:
'**************************************************************************************************

'Initialize vars here just in case
swaps = 0
sorted = 1

'Print text output displaying "SWAPS" for our swap counter
LOCATE 1, 1
PRINT "   "
LOCATE 1, 1
PRINT "SWAPS"

'Print text output displaying "WORST" and number of swaps completed
LOCATE 3, 1
PRINT "WORST"
LOCATE 4, 1
PRINT numOfValues ^ 2 'Bubble sort worst case n^2

'The DO loop that actually DOes the real stuff
DO
    swapped = 0 'Init as swapped 0 before iterating through array again

    FOR i = 0 TO numOfValues - sorted 'Iterate through array until we hit a number we know is sorted already


        'Update our swap counter in the beginning of the loop
        LOCATE 2, 1
        PRINT "     "
        LOCATE 2, 1
        PRINT swaps

        'Use the same line drawing looper based on thickness to draw our neighbor selections in color
        FOR z = 0 TO (lineThickness - 1)
            LINE ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), red
            LINE ((lineThickness * i + lineThickness) + z + leftOffset, lowerOffset)-((lineThickness * i + lineThickness) + z + leftOffset, maxNum - rndNums(i + 1)), green
        NEXT z

        _DELAY delayTime

        'If the first value is bigger than the second value, swap them in the array. This gradually moves the larger value to the end
        IF rndNums(i) > rndNums(i + 1) THEN swapped = 1: SWAP rndNums(i), rndNums(i + 1)

        'If swap is detected then clear the lines we need to swap graphically
        IF swapped = 1 THEN
            FOR z = 0 TO (lineThickness - 1)
                LINE ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i + 1)), black
                LINE ((lineThickness * i + lineThickness) + z + leftOffset, lowerOffset)-((lineThickness * i + lineThickness) + z + leftOffset, maxNum - rndNums(i + 1)), black
            NEXT z

            'Add to the swaps counter
            swaps = swaps + 1
        END IF

        'Draw new second to last value as yellow again
        FOR z = 0 TO (lineThickness - 1)
            LINE ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), yellow
        NEXT z

        'Draw last value (the sorted one) as blue, marking as complete
        FOR z = 0 TO (lineThickness - 1)
            LINE ((lineThickness * i + lineThickness) + z + leftOffset, lowerOffset)-((lineThickness * i + lineThickness) + z + leftOffset, maxNum - rndNums(i + 1)), blue
        NEXT z


        'Iterate array again
    NEXT i

    'Keep track of the last sorted array element
    sorted = sorted + 1

    'Beep if sound enabled
    IF soundOn = 1 THEN
        SOUND (rndNums(i) * 5), 1
    END IF

LOOP WHILE swapped = 1

'Make the rest of the array BLUE when we are done to make a fully sorted liste visually
FOR i = numOfValues - sorted + 1 TO 0 STEP -1
    FOR z = 0 TO (lineThickness - 1)
        LINE ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), blue
    NEXT z
    _DELAY delayTime

NEXT i

RETURN


'**************************************************************************************************
rngArrayFill:
'**************************************************************************************************

'For 0 to total amount of values, fill array with random numbers
FOR x = 0 TO numOfValues

    RANDOMIZE TIMER 'Randomize timer to make sure it's random every run
    rndNums(x) = INT(RND * (maxNum - 1 + 1)) + 1

NEXT x
RETURN

