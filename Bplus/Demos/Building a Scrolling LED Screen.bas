
_TITLE "Building a Scrolling LED Screen" ' b+ 2021-05-08

SCREEN _NEWIMAGE(1200, 160, 32)
_DELAY .25 'give screen time to load
_SCREENMOVE _MIDDLE 'and center screen

'scroll some text
Text$ = "Try scrolling me for awhile until you got it, then press a key...  "
lenText = LEN(Text$)
startTextPos = 1
'put text in sign 15 chars wide in middle of screen print the message moving down 1 character evey frame
_TITLE "Building a Scrolling LED Screen:  Step 1 get some code to scroll your message in middle of screen."
DO
    k$ = INKEY$
    CLS
    ' two pieces of text?  when get to end of text will have less than 15 chars to fill sign so get remainder from front
    len1 = lenText - startTextPos
    IF len1 < 15 THEN len2 = 15 - len1 ELSE len1 = 15: len2 = 0
    ' locate at middle of screen for 15 char long sign
    _PRINTSTRING ((1200 - 15 * 8) / 2, (160 / 2) - 8), MID$(Text$, startTextPos, len1) + MID$(Text$, 1, len2)
    startTextPos = startTextPos + 1
    IF startTextPos > lenText THEN startTextPos = 1
    _DISPLAY ' no blinking when clear screen so often
    _LIMIT 5 ' slow down to see scroll
LOOP UNTIL LEN(k$)

' OK  now for the enLARGE M E N T  using _PutImage
' our little sign is 16 pixels high and 8 * 15 chars pixels wide = 120
DIM sign AS LONG
sign = _NEWIMAGE(120, 16, 32) ' we will store the print image here

'  _PUTIMAGE [STEP] [(dx1, dy1)-[STEP][(dx2, dy2)]][, sourceHandle&][, destHandle&][, ][STEP][(sx1, sy1)[-STEP][(sx2, sy2)]][_SMOOTH]
'  use same pixel location to _printString as for _PutImage Source rectangle ie (sx1, sy1), -step( sign width and height)

' test screen capture with _putimage and then blowup with _putimage
'_PutImage , 0, sign, ((1200 - 15 * 8) / 2, (160 / 2) - 8)-Step(119, 15)
'Cls
'_PutImage , sign, 0 ' stretch to whole screen
'_Display

'now that that works  do it on the move

' about here I resized the screen to 1200 x 160 to make the text scalable X's 10 ie 120 x 10 wide and 16 x 10 high
_TITLE "Building a Scrolling LED Screen:  Step 2 Blow it up by using _PutImage twice once to capture, then to expand"
k$ = ""
DO
    k$ = INKEY$
    CLS
    ' two pieces of text?  when get to end of text will have less than 15 chars to fill sign so get remainder from front
    len1 = lenText - startTextPos
    IF len1 < 15 THEN len2 = 15 - len1 ELSE len1 = 15: len2 = 0
    ' locate at middle of screen for 15 char long sign
    _PRINTSTRING ((1200 - 15 * 8) / 2, (160 / 2) - 8), MID$(Text$, startTextPos, len1) + MID$(Text$, 1, len2)
    _PUTIMAGE , 0, sign, ((1200 - 15 * 8) / 2, (160 / 2) - 8)-STEP(119, 15)

    CLS
    _PUTIMAGE , sign, 0 ' stretch to whole screen
    _DISPLAY ' no blinking when clear screen so often
    _LIMIT 5 ' slow down to see scroll
    startTextPos = startTextPos + 1
    IF startTextPos > lenText THEN startTextPos = 1
LOOP UNTIL LEN(k$)



' now for a mask just draw a grid  test grid draw here
'For x = 0 To _Width Step 10 ' verticals
'    Line (x, 0)-(x + 3, _Height), &HFF000000, BF
'Next
'For y = 0 To _Height Step 10
'    Line (0, y)-(_Width, y + 3), &HFF000000, BF
'Next

_TITLE "Building a Scrolling LED Screen:  Step 3 Mask or Cover the thing with a grid or grate."
' here is the whole code with all setup variables
k$ = ""
DO
    k$ = INKEY$
    CLS
    ' two pieces of text?  when get to end of text will have less than 15 chars to fill sign so get remainder from front
    len1 = lenText - startTextPos
    IF len1 < 15 THEN len2 = 15 - len1 ELSE len1 = 15: len2 = 0
    ' locate at middle of screen for 15 char long sign
    _PRINTSTRING ((1200 - 15 * 8) / 2, (160 / 2) - 8), MID$(Text$, startTextPos, len1) + MID$(Text$, 1, len2)
    _PUTIMAGE , 0, sign, ((1200 - 15 * 8) / 2, (160 / 2) - 8)-STEP(119, 15)

    CLS
    _PUTIMAGE , sign, 0 ' stretch to whole screen

    ' now for a mask just draw a grid  best to draw this and copy and layover screen as another layer
    ' here QB64 is fast evough to redarw each time
    FOR x = 0 TO _WIDTH STEP 10 ' verticals
        LINE (x, 0)-(x + 3, _HEIGHT), &HFF000000, BF
    NEXT
    FOR y = 0 TO _HEIGHT STEP 10
        LINE (0, y)-(_WIDTH, y + 3), &HFF000000, BF
    NEXT

    _DISPLAY ' no blinking when clear screen so often
    _LIMIT 5 ' slow down to see scroll
    startTextPos = startTextPos + 1
    IF startTextPos > lenText THEN startTextPos = 1
LOOP UNTIL LEN(k$)

