'**************************************************************************************************
'**SORTING VISUALIZER by AKITA SOFT (C) 2021**
'**FEEL FREE TO USE HOW YOU WANT WITHOUT LICENSE!**
'**************************************************************************************************
_Title "Bubble Sort Visualizer"
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
Dim rndNums(numOfValues) As Integer 'Make sure this one is an integer just in case, do it up top to avoid problems

'**************************************************************************************************
'*COLORS
'**************************************************************************************************

Const red = _RGB32(255, 0, 0)
Const green = _RGB32(0, 255, 0)
Const blue = _RGB32(0, 0, 255)
Const yellow = _RGB32(255, 255, 0)
Const black = _RGB32(0, 0, 0)

'**************************************************************************************************
'*INIT SCREEN
'**************************************************************************************************

screenWidth = 640
screenHeight = 480
Screen _NewImage(screenWidth, screenHeight, 32) 'Initialize the screen
_Limit 30 'Limit Framerate

'**************************************************************************************************
' MAIN FUNCTION
'**************************************************************************************************

main:
Cls

'SLEEP
GoSub rngArrayFill
GoSub printArray
GoSub bubbleSort

End

'**************************************************************************************************
' SUBROUNTINES
'**************************************************************************************************

printArray:
Cls
_Delay delayTime
For i = 0 To numOfValues

    'Print text output displaying"RNG" ;abel and numbers generated
    Locate 1, 1
    Print "       "
    Locate 1, 1
    Print "RNG"

    Locate 2, 1
    Print "   "
    Locate 2, 1
    Print rndNums(i)

    'Starting at 0, loop drawing lines to create thickness based off var lineThickness
    'Remember QB64 is 0 based, not 1 based
    For z = 0 To (lineThickness - 1)
        Line ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), yellow

    Next z

    _Delay delayTime 'Delay so we can see it

Next i

Return


'**************************************************************************************************
bubbleSort:
'**************************************************************************************************

'Initialize vars here just in case
swaps = 0
sorted = 1

'Print text output displaying "SWAPS" for our swap counter
Locate 1, 1
Print "   "
Locate 1, 1
Print "SWAPS"

'Print text output displaying "WORST" and number of swaps completed
Locate 3, 1
Print "WORST"
Locate 4, 1
Print numOfValues ^ 2 'Bubble sort worst case n^2

'The DO loop that actually DOes the real stuff
Do
    swapped = 0 'Init as swapped 0 before iterating through array again

    For i = 0 To numOfValues - sorted 'Iterate through array until we hit a number we know is sorted already


        'Update our swap counter in the beginning of the loop
        Locate 2, 1
        Print "     "
        Locate 2, 1
        Print swaps

        'Use the same line drawing looper based on thickness to draw our neighbor selections in color
        For z = 0 To (lineThickness - 1)
            Line ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), red
            Line ((lineThickness * i + lineThickness) + z + leftOffset, lowerOffset)-((lineThickness * i + lineThickness) + z + leftOffset, maxNum - rndNums(i + 1)), green
        Next z

        _Delay delayTime

        'If the first value is bigger than the second value, swap them in the array. This gradually moves the larger value to the end
        If rndNums(i) > rndNums(i + 1) Then swapped = 1: Swap rndNums(i), rndNums(i + 1)

        'If swap is detected then clear the lines we need to swap graphically
        If swapped = 1 Then
            For z = 0 To (lineThickness - 1)
                Line ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i + 1)), black
                Line ((lineThickness * i + lineThickness) + z + leftOffset, lowerOffset)-((lineThickness * i + lineThickness) + z + leftOffset, maxNum - rndNums(i + 1)), black
            Next z

            'Add to the swaps counter
            swaps = swaps + 1
        End If

        'Draw new second to last value as yellow again
        For z = 0 To (lineThickness - 1)
            Line ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), yellow
        Next z

        'Draw last value (the sorted one) as blue, marking as complete
        For z = 0 To (lineThickness - 1)
            Line ((lineThickness * i + lineThickness) + z + leftOffset, lowerOffset)-((lineThickness * i + lineThickness) + z + leftOffset, maxNum - rndNums(i + 1)), blue
        Next z


        'Iterate array again
    Next i

    'Keep track of the last sorted array element
    sorted = sorted + 1

    'Beep if sound enabled
    If soundOn = 1 Then
        Sound (rndNums(i) * 5), 1
    End If

Loop While swapped = 1

'Make the rest of the array BLUE when we are done to make a fully sorted liste visually
For i = numOfValues - sorted + 1 To 0 Step -1
    For z = 0 To (lineThickness - 1)
        Line ((lineThickness * i) + z + leftOffset, lowerOffset)-((lineThickness * i) + z + leftOffset, maxNum - rndNums(i)), blue
    Next z
    _Delay delayTime

Next i

Return


'**************************************************************************************************
rngArrayFill:
'**************************************************************************************************

'For 0 to total amount of values, fill array with random numbers
For x = 0 To numOfValues

    Randomize Timer 'Randomize timer to make sure it's random every run
    rndNums(x) = Int(Rnd * (maxNum - 1 + 1)) + 1

Next x
Return

