'$INCLUDE:'SaveImage.BI'

CONST SaveTextAs256Color = 0 'Flag to Save as 256 color file or 32-bit color file, when converting SCREEN 0 to an image
'                             Set to TRUE (any non-zero value) to save text screens in 256 color mode.
'                             Set to FALSE (zero) to save text screens in 32-bit color mode.


'CONST ConvertToStandard256Palette = 0
'                             Set the value to 0 (FALSE) to preseve the color information perfectly, using its default palette.
'                             If the CONST is set (TRUE), then we convert our colors to as close of a match as possible, while
'                             preserving the standard QB64 256-color palette.
'                             Commented here, simply to help folks know that it exists for use when converting a 32 bit image
'                             down to 256 colors, such as what the GIF routine has to do for us (GIFs are limited to 256 color images)

SCREEN _NEWIMAGE(1280, 720, 32)
DIM exportimage(4) AS STRING
InitialImage$ = "Volcano Logo.jpg"
exportimage(1) = "testimage.png": exportimage(2) = "testimage.bmp"
exportimage(3) = "testimage.jpg": exportimage(4) = "testimage.gif"

'If you want to test the demo with a screen 0 image, then...
l& = _LOADIMAGE(InitialImage$) 'Remark out this line
'_PUTIMAGE , l& 'And remark the _PUTIMAGE line down below as well

'And unremark the following
'SCREEN 0
'FOR i = 0 TO 15
'    COLOR i
'    PRINT "COLOR i"
'NEXT
'Then you can watch as we prove that we can save images while in Screen 0 TEXT mode.
FOR i = 1 TO 4
    _PUTIMAGE , l& 'Remark out this line, if you want to see the SCREEN 0 demo
    LOCATE 1, 1
    Result = SaveImage(exportimage(i), 0, 0, 0, _WIDTH - 1, _HEIGHT - 1)
    IF Result = 1 THEN 'file already found on drive
        KILL exportimage(i) 'delete the old file
        Result = SaveImage(exportimage(i), 0, 0, 0, _WIDTH - 1, _HEIGHT - 1) 'save the new one again
    END IF
    PRINT Result
    IF Result < 0 THEN PRINT "Successful " + exportimage(i) + " export" ELSE PRINT ext$ + " Export failed with Error Code:"; Result: ' END
    SLEEP
NEXT

FOR i = 1 TO 4
    zz& = _LOADIMAGE(exportimage(i), 32)
    IF zz& <> -1 THEN
        SCREEN zz&
        PRINT "Image Handle: "; zz&, exportimage(i)
        PRINT "Successful Import using _LOADIMAGE"
    ELSE
        PRINT "ERROR - Not Loading the new image (" + exportimage(i) + ") with _LOADIMAGE."
    END IF
    SLEEP
NEXT

CLS
SYSTEM

'$INCLUDE:'SaveImage.BM'

