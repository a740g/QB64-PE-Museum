'**********************************************************************************************
'   Load Bitmap
'**********************************************************************************************
$IF LOADTEXTUREINCLUDE = UNDEFINED THEN
    $LET LOADTEXTUREINCLUDE = TRUE

    SUB loadBitmap (textureMap() AS LONG)
        DIM AS INTEGER index
        DIM AS STRING fl
        FOR index = 1 TO 16
            fl = _CWD$ + "\Assets\ball_" + LTRIM$(STR$(index)) + ".png"
            textureMap(index) = _LOADIMAGE(fl)
            loadBitmapError textureMap(), index, fl
        NEXT
        textureMap(index + 1) = _LOADIMAGE(_CWD$ + "\Assets\cue.png")
        loadBitmapError textureMap(), index + 1, fl
        textureMap(index + 2) = _LOADIMAGE(_CWD$ + "\Assets\table.png")
        loadBitmapError textureMap(), index + 2, fl
        textureMap(index + 3) = _LOADIMAGE(_CWD$ + "\Assets\triangle.png")
        loadBitmapError textureMap(), index + 3, fl
        textureMap(index + 4) = _LOADIMAGE(_CWD$ + "\Assets\ballreturn.png")
        loadBitmapError textureMap(), index + 4, fl
    END SUB

    SUB loadBitmapError (textureMap() AS LONG, index AS INTEGER, fl AS STRING)
        IF textureMap(index) > -2 THEN
            PRINT "Unable to load image "; fl; " with return of "; textureMap(index)
            END
        END IF
    END SUB
$END IF

