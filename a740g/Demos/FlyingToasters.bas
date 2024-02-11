' Flying toasters - a740g
' I am not sure where the toaster sprites came from. Sorry.
' C version - 2003
' QB64-PE port - 2024

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST FALSE = 0, TRUE = NOT FALSE
CONST NUMCIRCLES = 400
CONST NUMTOASTERS = 6
CONST NUMTOASTERFRAMES = 3

TYPE ToasterType
    x AS LONG
    y AS LONG
    speed AS LONG
    frame AS LONG
END TYPE

DIM bmpToaster(1 TO NUMTOASTERFRAMES) AS LONG
DIM AS LONG bmpCircle, bmpBackground
DIM toaster(1 TO NUMTOASTERS) AS ToasterType

RANDOMIZE TIMER

' Switch to graphics mode
SCREEN _NEWIMAGE(640, 400, 256)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND

LoadAssets

_COPYPALETTE bmpToaster(1), _DEST

' Set pallette colors 50-100 to blue values between 13 and 63
DIM i AS LONG: FOR i = 50 TO 100
    _PALETTECOLOR i, _RGB32(0, 0, (i - 37) * 4)
NEXT i

_DISPLAY
_COPYPALETTE _DEST, bmpCircle ' save the master palette

Graphics_ResetPalette _DEST, _RGB32(0) ' reset the display palette

DIM mX AS LONG: mX = _WIDTH - 1
DIM mY AS LONG: mY = _HEIGHT - 1

' Draw funny lines
FOR i = 0 TO mX
    DrawFunnyLine 0, mY, i, 0
NEXT i

FOR i = 0 TO mY
    DrawFunnyLine 0, mY, mX, i
NEXT i

' Draw circles
FOR i = 1 TO NUMCIRCLES
    _PUTIMAGE (RND * (mX - _WIDTH(bmpCircle)), RND * (mY - _HEIGHT(bmpCircle))), bmpCircle
NEXT i

' Make a copy of the background
bmpBackground = _COPYIMAGE(_DEST)

FOR i = 1 TO NUMTOASTERS
    Toaster_Init toaster(i)
NEXT i

_KEYCLEAR

DIM isPalMorphed AS _BYTE

DO
    _PUTIMAGE (0, 0), bmpBackground

    ' Blit and make all the toasters go
    FOR i = 1 TO NUMTOASTERS
        Toaster_Go toaster(i)

        ' Select the actual bitmap frame
        DIM frame AS LONG
        SELECT CASE toaster(i).frame
            CASE 2
                frame = 2

            CASE 3
                frame = 3

            CASE 4
                frame = 2

            CASE ELSE
                frame = 1
        END SELECT

        _PUTIMAGE (toaster(i).x, toaster(i).y), bmpToaster(frame)
    NEXT i

    IF isPalMorphed THEN
        Graphics_RotatePalette _DEST, -1, 50, 100
    ELSE
        isPalMorphed = Graphics_MorphPalette(_DEST, bmpCircle, 0, 255)
    END IF

    _PRINTSTRING (0, 0), STR$(Time_GetHertz) + " FPS"

    _DISPLAY

    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

_KEYCLEAR

END


SUB Toaster_Init (t AS ToasterType)
    ' Non realistic values
    t.x = -_WIDTH
    t.y = _HEIGHT
    t.speed = 0
    t.frame = 0
END SUB


SUB Toaster_Go (t AS ToasterType)
    SHARED bmpToaster() AS LONG

    ' Move the toaster
    t.x = t.x - t.speed
    t.y = t.y + t.speed

    ' Increment the frame
    t.frame = t.frame + 1
    IF t.frame > 4 THEN t.frame = 1

    ' When toaster reaches the edge of the screen, render it inactive and bring a new one into existence
    IF (t.x < -_WIDTH(bmpToaster(1))) OR (t.y >= _HEIGHT) THEN
        t.x = RND * (_WIDTH + _HEIGHT)
        t.y = -_HEIGHT(bmpToaster(1))
        t.frame = 1
        t.speed = RND * 3 + 1
    END IF
END SUB


' Draws "funny lines"
SUB DrawFunnyLine (a AS LONG, b AS LONG, c AS LONG, d AS LONG)
    DIM AS LONG al, bl, i, s, d1x, d1y, d2x, d2y, u, v, m, n, count

    al = a
    bl = b
    count = 50
    u = c - al ' u = x2 - x1  (change in x)
    v = d - bl ' v = y2 - y1  (change in y)

    d1x = SGN(u) ' d1x = sign of the change in x
    d1y = SGN(v) ' d1y = sign of the change in y

    d2x = SGN(u) ' d2x = sign of the change in x

    m = ABS(u) ' m = positive change in x
    n = ABS(v) ' n = positive change in y

    IF m <= n THEN
        d2x = 0 ' d2x = 0
        d2y = SGN(v) ' d2y = sign of the change in y
        m = ABS(v) ' m = positive change in y
        n = ABS(u) ' n = positive change in x
    END IF
    s = m \ 2 ' s = half of the change in x/y

    FOR i = 0 TO m
        PSET (al, bl), count ' plot the original x1 and y1
        count = count + 1 ' increment the color
        IF count > 100 THEN count = 50 ' if color is out of bounds, reset
        s = s + n
        IF s >= m THEN
            s = s - m
            al = al + d1x
            bl = bl + d1y
        ELSE
            al = al + d2x
            bl = bl + d2y
        END IF
    NEXT i
END SUB


SUB LoadAssets
    SHARED bmpToaster() AS LONG
    SHARED bmpCircle

    CONST SIZE_TOASTER1_BMP_2518~& = 2518~&
    CONST COMP_TOASTER1_BMP_2518%% = -1%%
    CONST DATA_TOASTER1_BMP_2518 = _
    "eNo0gxcUw0AAQH/23l4OlkqhchfGOf7ifC6dzufayXXv9O75R7u7dfjQ0iEHmkADULABmBmQed9R+ENZlkgp2e/3VI8H/nWEP9rgVz7FqEAIQQ0s" + _
    "8pzzYMCjrgnDkCiKiOOYJElI05Qsy54EwQUBACAAwLCHwN2tf0A2hBBIKVFKobXGGIO1Fucc3ntCCMQYSSmRc6aUQq2V1hq9d8YYzDlZa7H35pzD" + _
    "vZf33icILggAAAEAhr0P7m79S7EhhEBKiVIKrTXGGKy1OOfw3hNCIMZISomcM6UUaq201ui9M8Zgzslai7035xzuvbz3PkFwQQAgEABA7LLh8O7e" + _
    "vwYb27ax7zvHcXCeJ9d1cd83z/Pwvi/f9yGEQEqJUgqtNcYYrLU45/DeE0IgxkhKiZwzpRRqrbTW6L0zxmDOyVrrJwgeDAAGAgCI3aR929q/Cd/3" + _
    "IYRASolSCq01xhistTjn8N4TQiDGSEqJnDOlFGqttNbovTPGYM7JWou9N+cc7r28936C4MEAYCAAgNhN3betnZvwfR9CCKSUKKXQWmOMwVqLcw7v" + _
    "PSEEYoyklMg5U0qh1kprjd47YwzmnKy12HtzzuHey3vvJwiuCQAGAgCInf+hz8zkswnf9yGEQEqJUgqtNcYYrLU45/DeE0IgxkhKiZwzpRRqrbTW" + _
    "6L0zxmDOyVqLvTfnHO69vPd+guCCAEAgAIDY9Q/Cu7t1Y+P7PoQQSClRSqG1xhiDtRbnHN57QgjEGEkpkXOmlEKtldYavXfGGMw5WWux9+acw72X" + _
    "9x4/QXBBACAQAEDs+ofi3d36sH3fhxACKSVKKbTWGGOw1uKcw3tPCIEYIyklcs6UUqi10lqj984Ygzknay323pxzuPfy3vsJggsCAEAgAGLXPyDu" + _
    "8BKDjRACMUZSSuScKaVQa6W1Ru+dMQZzTtZa7L0553Dv5b2HiKCqmBnu/gmCBwIAgAAAYte/6dvmhhACKSVKKbTWGGOw1uKcw3tPCIEYIyklcs6U" + _
    "Uqi10lqj984Ygzknay323pxzuPfy3uO3S1YJDEIBDMPb3f/Ak+B0vn2+4JDgb1Co95wO/M9v22d+Bk1TJ1VSd90ARAcePDCL4r/na+Zd32BJr3zo" + _
    "hctcz33+H3zZsq2X/yeB7KnRS5/AaxBJv6ECfMkgvdLXgFHbwqkTSBn0ttOfAzDTnPSQOgGFbEY5C7QsaICdaW4LmN0L8N2fQQ=="

    bmpToaster(1) = Graphics_LoadImage(Base64_LoadResourceString(DATA_TOASTER1_BMP_2518, SIZE_TOASTER1_BMP_2518, COMP_TOASTER1_BMP_2518), -1, 0, "memory", 0)

    CONST SIZE_TOASTER2_BMP_2518~& = 2518~&
    CONST COMP_TOASTER2_BMP_2518%% = -1%%
    CONST DATA_TOASTER2_BMP_2518 = _
    "eNo0gxcUw0AAQH/23l4OlkqhchfGOf7ifC6dzufayXXv9O75R7u7dfjQ0iEHmkADULABmBmQed9R+ENZlkgp2e/3VI8H/nWEP9rgVz7FqEAIQQ0s" + _
    "8pzzYMCjrgnDkCiKiOOYJElI05Qsy54EwQUBACAAwLCHwN2tf0A2hBBIKVFKobXGGIO1Fucc3ntCCMQYSSmRc6aUQq2V1hq9d8YYzDlZa7H35pzD" + _
    "vZf33icILggAAAEAhr0P7m79S7EhhEBKiVIKrTXGGKy1OOfw3hNCIMZISomcM6UUaq201ui9M8Zgzslai7035xzuvbz3PkFwQQAwDAAwrNrOY+b5" + _
    "1/GE4zg4z5Prurjvm+d5eN+X7/sQQiClRCmF1hpjDNZanHN47wkhEGMkpUTOmVIKtVZaa/TeGWMw52Stxd77JwguaACAAQCGzeiZmfwnbxFCIKVE" + _
    "KYXWGmMM1lqcc3jvCSEQYySlRM6ZUgq1Vlpr9N4ZYzDnZK3F3ptzDvde3nufIHgwABgIACB2Q79tdekmCCGQUqKUQmuNMQZrLc45vPeEEIgxklIi" + _
    "50wphVorrTV674wxmHOy1mLvzTmHey/vPb7v55AerBgGAAAK/v37Ytu2k+mqm+Fe/wuCICCKIpIkIcsyiqKgqiqapqHrOoZhYJomlmVh2zaO4+C6" + _
    "Lp7n4fs+QRAQhiFRFBHHMUmSkKYpWZaR5zlFUVCWJVVVUdc1TdPQti1d19H3PcMwMI4j0zQxzzPLsrCuK9u2/R8fx8F5nlzXxX3fPM/DhyC4IAAA" + _
    "BAAY9v6RcHeLxCaEQEqJUgqtNcYYrLU45/DeE0IgxkhKiZwzpRRqrbTW6L0zxmDOyVqLvTfnHO69vPc+QXBBACAQAEDs+rfj3d1isPF9H0IIpJQo" + _
    "pdBaY4zBWotzDu89IQRijKSUyDlTSqHWSmuN3jtjDOacrLXYe3PO4d7Le4+fILgwAgCEASD2+2+Ku0OPRCmF1hpjDNZanHN47wkhEGMkpUTOmVIK" + _
    "tVZaa/TeGWMw52Stxd6bcw73Xt57iAi/XTrQoBCM4Si+U+3+9f4P3LWF1fIlBOinBGcjtm2bfR7gbG3e6+f5vu8D08SVXbEsv5RDzeCH8/N6L8V7" + _
    "17ubuccTFLjtS/aIvj+Res9oP9pB5ZkINOhROOYmBvvdAQlUeRBI1Rd3R1LLc4Bzv+78yIo0uk8vD++515+X/QEUV5we"

    bmpToaster(2) = Graphics_LoadImage(Base64_LoadResourceString(DATA_TOASTER2_BMP_2518, SIZE_TOASTER2_BMP_2518, COMP_TOASTER2_BMP_2518), -1, 0, "memory", 0)

    CONST SIZE_TOASTER3_BMP_2518~& = 2518~&
    CONST COMP_TOASTER3_BMP_2518%% = -1%%
    CONST DATA_TOASTER3_BMP_2518 = _
    "eNo0gxcQwwAAAD9770TLwVIpVO7COMcvznHpdI5rJ9e907vnj3Z3a/ChJUMKNIEGIKADMFMgsr4j8Ic8z6nrmv1+T/F4YF9H2KMNdmGTjTKqqqIE" + _
    "FmnKeTDgUZa4rovnefi+TxAEhGFIFEXEcUySJE+C4IIAABAAYNhT4O7WPx8bQgiklCil0FpjjMFai3MO7z0hBGKMpJTIOVNKodZKa43eO2MM5pys" + _
    "tdh7c87h3st77xMEFwQAAgEAxK4Q8O4u/Sux8TwP7/vyfR9CCKSUKKXQWmOMwVqLcw7vPSEEYoyklMg5U0qh1kprjd47YwzmnKy12HtzzuHe+xME" + _
    "FwQAAgEAxC7du7vRvwYbQgiklCil0FpjjMFai3MO7z0hBGKMpJTIOVNKodZKa43eO2MM5pystdh7c87h3st7j+/7CYILIoBhAABib3RlZvJ/Sz6E" + _
    "EEgpUUqhtcYYg7UW5xzee0IIxBhJKZFzppRCrZXWGr13xhjMOVlrsffmnMO9l/d+guDBAGAgAIDYDd23raWbfAghkFKilEJrjTEGay3OObz3hBCI" + _
    "MZJSIudMKYVaK601eu+MMZhzstZi7805h3sv7/0c0oMVwwAAQMG/f19s23YyXXUz3Ot/QRAERFFEkiRkWUZRFFRVRdM0dF3HMAxM08SyLGzbxnEc" + _
    "XNfF8zx83ycIAsIwJIoi4jgmSRLSNCXLMvI8pygKyrKkqirquqZpGtq2pes6+r5nGAbGcWSaJuZ5ZlkW1nVl27b/4+M4OM+T67q475vneT4EwQUB" + _
    "ACAAwLD3j4S7WyQ2hBBIKVFKobXGGIO1Fucc3ntCCMQYSSmRc6aUQq2V1hq9d8YYzDlZa7H35pzDvZf33icILggABAIAiF3/dry7Www2vu9DCIGU" + _
    "EqUUWmuMMVhrcc7hvSeEQIyRlBI5Z0op1FpprdF7Z4zBnJO1Fntvzjnce3nv/QTBAwEAQAAAsevf9G1zQwiBlBKlFFprjDFYa3HO4b0nhECMkZQS" + _
    "OWdKKdRaaa3Re2eMwZyTtRZ7b8453Ht57/3252iFYRCAoWhjeyf9/x8eFDJxxFWhj7vPR43bOGBbCTd5Hy2SlgCyJ/Baq0R+gcRVzd3Iq+/8lD1r" + _
    "HuT2fc2Xoi7ynKrjeF1dh1q/5vvf9x4Gnt677AN32QftgseVKd/4lG96zrsbHwu89+dX2bvn/b/negMelJyn"

    bmpToaster(3) = Graphics_LoadImage(Base64_LoadResourceString(DATA_TOASTER3_BMP_2518, SIZE_TOASTER3_BMP_2518, COMP_TOASTER3_BMP_2518), -1, 0, "memory", 0)

    bmpCircle = _NEWIMAGE(5, 5, 256)
    _COPYPALETTE bmpToaster(1), bmpCircle
    DIM oldDest AS LONG: oldDest = _DEST
    _DEST bmpCircle
    CIRCLE (2, 2), 2, 10
    PAINT (2, 2), 11, 10
    _CLEARCOLOR 0
    _DEST oldDest
END SUB


' Calculates and returns the hertz value when repeatedly called inside a loop
FUNCTION Time_GetHertz~&
    DECLARE LIBRARY
        FUNCTION GetTicks~&&
    END DECLARE

    STATIC AS _UNSIGNED LONG counter, finalFPS
    STATIC lastTime AS _UNSIGNED _INTEGER64

    DIM currentTime AS _UNSIGNED _INTEGER64: currentTime = GetTicks

    IF currentTime >= lastTime + 1000 THEN
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    END IF

    counter = counter + 1

    Time_GetHertz = finalFPS
END FUNCTION


' Loads an image and returns and image handle
' fileName - filename or memory buffer of the image
' is8bpp - image will be loaded as an 8-bit image if this is true (not supported by hardware images)
' isHardware - image will be loaded as a hardware image (is8bpp must not be true for this to work)
' otherOptions - other image loading options like "memory", "adaptive" and the various image scalers
' transparentColor - if this is >= 0 then the color specified by this becomes the transparency color key
FUNCTION Graphics_LoadImage& (fileName AS STRING, is8bpp AS _BYTE, isHardware AS _BYTE, otherOptions AS STRING, transparentColor AS _INTEGER64)
    DIM handle AS LONG

    IF is8bpp THEN
        handle = _LOADIMAGE(fileName, 256, otherOptions)
    ELSE
        handle = _LOADIMAGE(fileName, 32, otherOptions)
    END IF

    IF handle < -1 THEN
        IF transparentColor >= 0 THEN _CLEARCOLOR transparentColor, handle

        IF isHardware THEN
            DIM handleHW AS LONG: handleHW = _COPYIMAGE(handle, 33)
            _FREEIMAGE handle
            handle = handleHW
        END IF
    END IF

    Graphics_LoadImage = handle
END FUNCTION


' Rotates an image palette left or right
SUB Graphics_RotatePalette (dstImage AS LONG, isForward AS _BYTE, startIndex AS _UNSIGNED _BYTE, stopIndex AS _UNSIGNED _BYTE)
    IF stopIndex > startIndex THEN
        DIM tempColor AS _UNSIGNED LONG, i AS LONG

        IF isForward THEN
            ' Save the last color
            tempColor = _PALETTECOLOR(stopIndex, dstImage)

            ' Shift places for the remaining colors
            FOR i = stopIndex TO startIndex + 1 STEP -1
                _PALETTECOLOR i, _PALETTECOLOR(i - 1, dstImage), dstImage
            NEXT i

            ' Set first to last
            _PALETTECOLOR startIndex, tempColor, dstImage
        ELSE
            ' Save the first color
            tempColor = _PALETTECOLOR(startIndex, dstImage)

            ' Shift places for the remaining colors
            FOR i = startIndex TO stopIndex - 1
                _PALETTECOLOR i, _PALETTECOLOR(i + 1, dstImage), dstImage
            NEXT i

            ' Set last to first
            _PALETTECOLOR stopIndex, tempColor, dstImage
        END IF
    END IF
END SUB


' This will progressively change the palette of dstImg to that of srcImg
' Keep calling this repeatedly until it returns true
FUNCTION Graphics_MorphPalette%% (dstImage AS LONG, srcImage AS LONG, startIndex AS _UNSIGNED _BYTE, stopIndex AS _UNSIGNED _BYTE)
    Graphics_MorphPalette = TRUE ' Assume completed

    DIM i AS LONG: FOR i = startIndex TO stopIndex
        ' Get both src and dst colors of the current index
        DIM srcColor AS _UNSIGNED LONG: srcColor = _PALETTECOLOR(i, srcImage)
        DIM dstColor AS _UNSIGNED LONG: dstColor = _PALETTECOLOR(i, dstImage)

        ' Break down the colors into individual components
        DIM srcR AS _UNSIGNED _BYTE: srcR = _RED32(srcColor)
        DIM srcG AS _UNSIGNED _BYTE: srcG = _GREEN32(srcColor)
        DIM srcB AS _UNSIGNED _BYTE: srcB = _BLUE32(srcColor)
        DIM dstR AS _UNSIGNED _BYTE: dstR = _RED32(dstColor)
        DIM dstG AS _UNSIGNED _BYTE: dstG = _GREEN32(dstColor)
        DIM dstB AS _UNSIGNED _BYTE: dstB = _BLUE32(dstColor)

        ' Change red
        IF dstR < srcR THEN
            Graphics_MorphPalette = FALSE
            dstR = dstR + 1
        ELSEIF dstR > srcR THEN
            Graphics_MorphPalette = FALSE
            dstR = dstR - 1
        END IF

        ' Change green
        IF dstG < srcG THEN
            Graphics_MorphPalette = FALSE
            dstG = dstG + 1
        ELSEIF dstG > srcG THEN
            Graphics_MorphPalette = FALSE
            dstG = dstG - 1
        END IF

        ' Change blue
        IF dstB < srcB THEN
            Graphics_MorphPalette = FALSE
            dstB = dstB + 1
        ELSEIF dstB > srcB THEN
            Graphics_MorphPalette = FALSE
            dstB = dstB - 1
        END IF

        ' Set the palette index color
        _PALETTECOLOR i, _RGB32(dstR, dstG, dstB), dstImage
    NEXT i
END FUNCTION


' Sets the complete palette to a single color
SUB Graphics_ResetPalette (dstImage AS LONG, resetColor AS _UNSIGNED LONG)
    DIM i AS LONG: FOR i = 0 TO 255
        _PALETTECOLOR i, resetColor, dstImage
    NEXT i
END SUB


' Converts a base64 string to a normal string or binary data
FUNCTION Base64_Decode$ (s AS STRING)
    DIM srcSize AS _UNSIGNED LONG: srcSize = LEN(s)
    DIM buffer AS STRING: buffer = SPACE$((srcSize \ 4) * 3) ' preallocate complete buffer
    DIM j AS _UNSIGNED LONG: j = 1
    DIM AS _UNSIGNED _BYTE index, char1, char2, char3, char4

    DIM i AS _UNSIGNED LONG: FOR i = 1 TO srcSize STEP 4
        index = ASC(s, i): GOSUB find_index: char1 = index
        index = ASC(s, i + 1): GOSUB find_index: char2 = index
        index = ASC(s, i + 2): GOSUB find_index: char3 = index
        index = ASC(s, i + 3): GOSUB find_index: char4 = index

        ASC(buffer, j) = _SHL(char1, 2) OR _SHR(char2, 4)
        j = j + 1
        ASC(buffer, j) = _SHL(char2 AND 15, 4) OR _SHR(char3, 2)
        j = j + 1
        ASC(buffer, j) = _SHL(char3 AND 3, 6) OR char4
        j = j + 1
    NEXT i

    ' Remove padding
    IF RIGHT$(s, 2) = "==" THEN
        buffer = LEFT$(buffer, LEN(buffer) - 2)
    ELSEIF RIGHT$(s, 1) = "=" THEN
        buffer = LEFT$(buffer, LEN(buffer) - 1)
    END IF

    Base64_Decode = buffer
    EXIT FUNCTION

    find_index:
    IF index >= 65 AND index <= 90 THEN
        index = index - 65
    ELSEIF index >= 97 AND index <= 122 THEN
        index = index - 97 + 26
    ELSEIF index >= 48 AND index <= 57 THEN
        index = index - 48 + 52
    ELSEIF index = 43 THEN
        index = 62
    ELSEIF index = 47 THEN
        index = 63
    END IF
    RETURN
END FUNCTION


' This function loads a resource directly from a string variable or constant (like the ones made by Bin2Data)
FUNCTION Base64_LoadResourceString$ (src AS STRING, ogSize AS _UNSIGNED LONG, isComp AS _BYTE)
    ' Decode the data
    DIM buffer AS STRING: buffer = Base64_Decode(src)

    ' Expand the data if needed
    IF isComp THEN buffer = _INFLATE$(buffer, ogSize)

    Base64_LoadResourceString = buffer
END FUNCTION
