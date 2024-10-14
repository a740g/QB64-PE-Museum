DEFLNG A-Z
OPTION _EXPLICIT

$RESIZE:SMOOTH
SCREEN 2
_ALLOWFULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM AS LONG Style, Cycles
DIM AS SINGLE X, Y

' Viewport sized to proper scale for graph:
VIEW (20, 2)-(620, 172), , 1

' Make window large enough to graph sine wave from
' 0 radians to pi radians:
WINDOW (0, -1.1)-(2 * _PI, 1.1)
Style = &HFF00 ' Use to make dashed line.
VIEW PRINT 23 TO 24 ' Scroll printed output in rows 23, 24.
DO
    PRINT TAB(20);
    INPUT "Number of cycles (0 to end): ", Cycles
    CLS
    LINE (2 * _PI, 0)-(0, 0), , , Style ' Draw the x axis.
    IF Cycles > 0 THEN

        '  Start at (0,0) and plot the graph:
        FOR X = 0 TO 2 * _PI STEP .01
            Y = SIN(Cycles * X) ' Calculate the y coordinate.
            LINE -(X, Y) ' Draw a line to new point.
        NEXT X
    END IF
LOOP WHILE Cycles > 0

SYSTEM
