OPTION _EXPLICIT '        declare those variables!

CONST SWIDTH = 1024 '     screen width
CONST SHEIGHT = 768 '     screen height
CONST DEEP = 1 '          Filter methods
CONST RUSHHOUR = 2
CONST TEXTURE = 3
CONST WOODEN = 4
CONST AVERAGE3 = 5
CONST AVERAGE5 = 6
CONST AVERAGE7 = 7
CONST GAUSS4 = 8
CONST GAUSS8 = 9
CONST NEEDGLASSES = 10
CONST UNSHARPCAM = 11
CONST LOWSHARPEN = 12
CONST MEDIUMSHARPEN = 13
CONST HIGHSHARPEN = 14
CONST MEXICANHAT = 15
CONST KIRSCHN = 16
CONST KIRSCHNW = 17
CONST KIRSCHW = 18
CONST KIRSCHSW = 19
CONST KIRSCHS = 20
CONST KIRSCHSE = 21
CONST KIRSCHE = 22
CONST KIRSCHNE = 23
CONST LAPLACE4 = 24
CONST LAPLACE8 = 25
CONST ROBERTS1 = 26
CONST ROBERTS2 = 27
CONST PREWITT1 = 28
CONST PREWITT2 = 29
CONST SOBEL1 = 30
CONST SOBEL2 = 31
CONST HORIZONTAL = 1 '    horizontal flip
CONST VERTICAL = 2 '      vertical flip
CONST BOTH = 3 '          horizontal and vertical flip

'--------------------------------------------------------------------------------------

'**
'** begin example code
'**

DIM Image AS LONG
DIM AlteredImage AS LONG
DIM c AS INTEGER
DIM d AS INTEGER
DIM s AS STRING
DIM clr AS _UNSIGNED LONG

Image = _LOADIMAGE("sample.png", 32)
SCREEN _NEWIMAGE(SWIDTH, SHEIGHT, 32)
CLS

Display_Image Image, "ORIGINAL IMAGE", 1
c = 0
DO
    _LIMIT 60
    AlteredImage = _COPYIMAGE(Image)
    __Rotate AlteredImage, c
    Display_Image AlteredImage, "ROTATED" + STR$(c) + " DEGREES", 0
    _FREEIMAGE AlteredImage
    c = c + 1
LOOP UNTIL c = 361
Display_Image Image, "ROTATED 0 DEGREES", 1
AlteredImage = _COPYIMAGE(Image)
__Flip AlteredImage, HORIZONTAL
Display_Image AlteredImage, "FLIPPED HORIZONTAL", 1
_FREEIMAGE AlteredImage
AlteredImage = _COPYIMAGE(Image)
__Flip AlteredImage, VERTICAL
Display_Image AlteredImage, "FLIPPED VERTICAL", 1
_FREEIMAGE AlteredImage
AlteredImage = _COPYIMAGE(Image)
__Flip AlteredImage, BOTH
Display_Image AlteredImage, "FLIPPED BOTH HORIZONTAL & VERTICAL", 1
c = 75
d = 1
DO
    _LIMIT 15
    _FREEIMAGE AlteredImage
    AlteredImage = _COPYIMAGE(Image)
    __Zoom AlteredImage, c / 100
    Display_Image AlteredImage, "RESIZED" + STR$(c) + "%", 0
    c = c + d
    IF c = 125 THEN d = -d
LOOP UNTIL c = 100 AND d = -1
Display_Image AlteredImage, "RESIZED 100%", 1
_FREEIMAGE AlteredImage
AlteredImage = _COPYIMAGE(Image)
__Negative AlteredImage
Display_Image AlteredImage, "NEGATIVE IMAGE", 1
_FREEIMAGE AlteredImage
AlteredImage = _COPYIMAGE(Image)
__GrayScale AlteredImage
Display_Image AlteredImage, "GRAYSCALE IMAGE", 1

c = -100
d = 1
DO
    _LIMIT 30
    _FREEIMAGE AlteredImage
    AlteredImage = _COPYIMAGE(Image)
    __Brightness AlteredImage, c / 100
    Display_Image AlteredImage, "BRIGHTNESS LEVEL " + STR$(c) + "%", 0
    c = c + d
    IF c = 100 THEN d = -d
LOOP UNTIL c = 0 AND d = -1
Display_Image AlteredImage, "BRIGHTNESS LEVEL 0%", 1
c = -100
d = 1
DO
    _LIMIT 30
    _FREEIMAGE AlteredImage
    AlteredImage = _COPYIMAGE(Image)
    __Contrast AlteredImage, c / 100
    Display_Image AlteredImage, "CONTRAST LEVEL " + STR$(c) + "%", 0
    c = c + d
    IF c = 100 THEN d = -d
LOOP UNTIL c = 0 AND d = -1
Display_Image AlteredImage, "CONTRAST LEVEL 0%", 1
c = 1
d = 1
DO
    _LIMIT 30
    _FREEIMAGE AlteredImage
    AlteredImage = _COPYIMAGE(Image)
    __Gamma AlteredImage, c / 100
    Display_Image AlteredImage, "GAMMA CORRECTION " + STR$(c - 100) + "%", 0
    c = c + d
    IF c = 200 THEN d = -d
LOOP UNTIL c = 100 AND d = -1
Display_Image AlteredImage, "GAMMA CORRECTION 0%", 1

c = 1
d = 1
DO
    _LIMIT 5
    _FREEIMAGE AlteredImage
    AlteredImage = _COPYIMAGE(Image)
    __Gaussian AlteredImage, c
    Display_Image AlteredImage, "GAUSSIAN BLUR RADIUS" + STR$(c), 0
    c = c + d
    IF c = 10 THEN d = -d
LOOP UNTIL c = 1 AND d = -1
Display_Image AlteredImage, "GAUSSIAN BLUR RADIUS 1", 1
_FREEIMAGE AlteredImage
c = 1
DO
    SELECT CASE c
        CASE 1: s = "DEEP (artistic)"
        CASE 2: s = "RUSHHOUR (artistic)"
        CASE 3: s = "TEXTURE (artistic)"
        CASE 4: s = "WOODEN (artistic)"
        CASE 5: s = "AVERAGE3 (bluring)"
        CASE 6: s = "AVERAGE5 (bluring)"
        CASE 7: s = "AVERAGE7 (bluring)"
        CASE 8: s = "GAUSS4 (bluring)"
        CASE 9: s = "GAUSS8 (bluring)"
        CASE 10: s = "NEEDGLASSES (bluring)"
        CASE 11: s = "UNSHARPCAM (bluring)"
        CASE 12: s = "LOWSHARPEN (sharpen)"
        CASE 13: s = "MEDIUMSHARPEN (sharpen)"
        CASE 14: s = "HIGHSHARPEN (sharpen)"
        CASE 15: s = "MEXICANHAT (sharpen)"
        CASE 16: s = "KIRSCHN (edge detect)"
        CASE 17: s = "KIRSCHNW (edge detect)"
        CASE 18: s = "KIRSCHW (edge detect)"
        CASE 19: s = "KIRSCHSW (edge detect)"
        CASE 20: s = "KIRSCHS (edge detect)"
        CASE 21: s = "KIRSCHSE (edge detect)"
        CASE 22: s = "KIRSCHE (edge detect)"
        CASE 23: s = "KIRSCHNE (edge detect)"
        CASE 24: s = "LAPLACE4 (edge detect)"
        CASE 25: s = "LAPLACE8 (edge detect)"
        CASE 26: s = "ROBERTS1 (edge detect)"
        CASE 27: s = "ROBERTS2 (edge detect)"
        CASE 28: s = "PREWITT1 (line detect)"
        CASE 29: s = "PREWITT2 (line detect)"
        CASE 30: s = "SOBEL1 (line detect)"
        CASE 31: s = "SOBEL2 (line detect)"
    END SELECT
    AlteredImage = _COPYIMAGE(Image)
    __Filter AlteredImage, c
    Display_Image AlteredImage, s + " FILTER APPLIED", 1
    _FREEIMAGE AlteredImage
    c = c + 1
LOOP UNTIL c = 32
_FREEIMAGE Image
Image = _LOADIMAGE("colors.png", 32)
c = 0
DO
    _LIMIT 5
    c = c + 1
    IF c = 8 THEN c = 1
    SELECT CASE c
        CASE 1: clr = _RGB32(255, 0, 0)
        CASE 2: clr = _RGB32(0, 255, 0)
        CASE 3: clr = _RGB32(255, 255, 0)
        CASE 4: clr = _RGB32(0, 0, 255)
        CASE 5: clr = _RGB32(255, 0, 255)
        CASE 6: clr = _RGB32(0, 255, 255)
        CASE 7: clr = _RGB32(255, 255, 255)
    END SELECT
    AlteredImage = _COPYIMAGE(Image)
    __Replace AlteredImage, clr, _RGB32(0, 0, 0)
    Display_Image AlteredImage, "REPLACING COLORS", 0
    LOCATE (SHEIGHT \ 16) - 1, ((SWIDTH \ 8) - 21) \ 2
    PRINT "PRESS ESC KEY TO EXIT";
    _DISPLAY
    _FREEIMAGE AlteredImage
LOOP UNTIL _KEYDOWN(27)
_FREEIMAGE Image
SYSTEM
'----------------------------
SUB Display_Image (i AS LONG, s AS STRING, p AS INTEGER)

    CLS
    _PUTIMAGE ((SWIDTH - _WIDTH(i)) \ 2, (SHEIGHT - _HEIGHT(i)) \ 2), i
    LOCATE 2, ((SWIDTH \ 8) - LEN(s)) \ 2
    PRINT s;
    _DISPLAY
    IF p THEN
        LOCATE (SHEIGHT \ 16) - 1, ((SWIDTH \ 8) - 11) \ 2
        PRINT "PRESS A KEY";
        _DISPLAY
        SLEEP
    END IF

END SUB
'----------------------------

'**
'** end example code
'**

'+-----------------------------------------------------------------------------------------------------------+
'| Image manipulation routines by Terry Ritchie 02/20/24                                                     |
'|                                                                                                           |
'| An exercise in using QB64PE's _MEM related statements.                                                    |
'|                                                                                                           |
'| Each subroutine includes links to credit other programmer's work for inspiration.                         |
'+-----------------------------------------------------------------------------------------------------------+

' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Gaussian (i AS LONG, r AS INTEGER) '                                                    __Gaussian |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Performs a Guassian blur on an image without affecting original alpha values.                         |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| r - the radius size of the kernel to build (1 to x) (the larger the radius the slower the process).   |
    '|                                                                                                       |
    '| Uses the formula: G(x,y) = (1 / (2 * PI * sigma^2)) * eulers_constant ^ -((x^2 + y^2) / 2 * sigma^2)) |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '|                                                                                                       |
    '| This subroutine also draws insight from Aryaman Sharda's gaussian blur Swift code found here:         |
    '| https://aryamansharda.medium.com/image-filters-gaussian-blur-eb36db6781b1                             |
    '\_______________________________________________________________________________________________________/

    CONST EULERSCONSTANT = .5772156649015328 ' gamma ( https://en.wikipedia.org/wiki/Euler's_constant )
    DIM m AS _MEM '             source image data memory block
    DIM tm AS _MEM '            target image data memory block
    DIM o AS _OFFSET '          pixel location within image memory block
    DIM ko AS _OFFSET '         kernel matrix offset
    DIM rb AS _UNSIGNED _BYTE ' red component byte at pixel offset
    DIM gb AS _UNSIGNED _BYTE ' green component byte at pixel offset
    DIM bb AS _UNSIGNED _BYTE ' blue component byte at pixel offset
    DIM ti AS LONG '            target image
    DIM h AS INTEGER '          height of source image
    DIM w AS INTEGER '          width of source image
    DIM s AS DOUBLE '           sigma
    DIM kw AS INTEGER '         kernel matrix width and height
    DIM sum AS DOUBLE '         sum of kernel matrix values
    DIM x AS INTEGER '          pixel horizontal counter
    DIM y AS INTEGER '          pixel vertical counter
    DIM kx AS INTEGER '         kernel matrix horizontal location
    DIM ky AS INTEGER '         kernel matrix vertical location
    DIM en AS DOUBLE '          exponent numerator
    DIM ed AS DOUBLE '          exponent denominator
    DIM ee AS DOUBLE '          exponent expression
    DIM dp AS DOUBLE '          exponent denominator multiped by PI
    DIM kv AS DOUBLE '          kernel value
    DIM rv AS DOUBLE '          new convolved red value
    DIM gv AS DOUBLE '          new convolved green value
    DIM bv AS DOUBLE '          new convolved blue value

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Create the kernel matrix                                                                      |
            '| ========================                                                                      |
            '+------------------------------------------+                                                    |
            s = r / 2 '                                 | calculate sigma (min standard deviation baseline)  |
            IF s < 1 THEN s = 1 '                       | sigma must not be lower than 1                     |
            kw = (2 * r) + 1 '                          | ensure odd kernel matrix width                     |
            DIM Kernel(kw, kw) AS DOUBLE '              | create kernel matrix                               |
            sum = 0 '                                   | reset kernel sum                                   |
            ed = 2 * s * s '                            | calculate exponent denominator                     |
            dp = _PI * ed '                             | exponent denominator times PI                      |
            x = -r '                                    | start at left side of kernel matrix                |
            DO '                                        | begin horizontal matrix counter                    |
                y = -r '                                | start at top of kernel matrix                      |
                DO '                                    | begin vertical matrix counter                      |
                    en = x * x + y * y '                | calculate exponent numerator                       |
                    ee = EULERSCONSTANT ^ (en / ed) '   | calculate exponent expression                      |
                    kv = ee / dp '                      | calculate kernel value                             |
                    Kernel(x + r, y + r) = kv '         | store value in matrix                              |
                    sum = sum + kv '                    | add value to overall kernel sum                    |
                    y = y + 1 '                         | increment vertical counter                         |
                LOOP UNTIL y > r '                      | leave when at bottom of matrix                     |
                x = x + 1 '                             | increment horizontal counter                       |
            LOOP UNTIL x > r '                          | leave when at ride side of matrix                  |
            x = 0 '                                     | reset horizontal counter                           |
            DO '                                        | begin horizontal matrix counter                    |
                y = 0 '                                 | reset vertical counter                             |
                DO '                                    | begin vertical matrix counter                      |
                    Kernel(x, y) = Kernel(x, y) / sum ' | normalize kernel values                            |
                    y = y + 1 '                         | increment vertical counter                         |
                LOOP UNTIL y > kw '                     | leave when at bottom of matrix                     |
                x = x + 1 '                             | increment horizontal counter                       |
            LOOP UNTIL x > kw '                         | leave when at right side of matrix                 |
            '                                           +----------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Create a target image                                                                         |
            '| =====================                                                                         |
            '+-------------------+                                                                           |
            ti = _COPYIMAGE(i) ' | create target image                                                       |
            w = _WIDTH(ti) '     | get target image width                                                    |
            h = _HEIGHT(ti) '    | get target image height                                                   |
            '                    +---------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-------------------+                                                                           |
            m = _MEMIMAGE(i) '   | source image memory block                                                 |
            tm = _MEMIMAGE(ti) ' | target image memory block                                                 |
            '                    +---------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Apply Guassian blur to image                                                                  |
            '| ============================                                                                  |
            '+--------------------------------------------+                                                  |
            y = 0 '                                       | reset vertical counter                           |
            DO '                                          | begin vertical image pixel counter               |
                o = y * w * 4 '                           | calculate offset location of pixel               |
                x = 0 '                                   | reset horizontal counter                         |
                DO '                                      | begin horizontal image pixel counter             |
                    rv = 0: gv = 0: bv = 0 '              | reset new convoluted RGB values                  |
                    '+------------------------------------+                                                  |
                    '| Get RGB value of pixel within image                                                   |
                    '| ===================================                                                   |
                    '+----------------------------------------------------------+                            |
                    ky = y - r '                                                | set matrix row counter     |
                    DO '                                                        | begin matrix row counter   |
                        ko = ky * w * 4 + ((x - r) * 4) '                       | matrix offset location     |
                        kx = x - r '                                            | set matrix column counter  |
                        DO '                                                    | begin matrix column counter|
                            IF ky >= 0 AND ky < h AND kx >= 0 AND kx < w THEN ' | matrix within image?       |
                                _MEMGET m, m.OFFSET + ko + 2, rb '              | yes, get this pixel red    |
                                _MEMGET m, m.OFFSET + ko + 1, gb '              | get this pixel green       |
                                _MEMGET m, m.OFFSET + ko, bb '                  | get this pixel blue        |
                            ELSE '                                              | no, outside of image       |
                                _MEMGET m, m.OFFSET + o + 2, rb '               | get edge pixel red         |
                                _MEMGET m, m.OFFSET + o + 1, gb '               | get edge pixel green       |
                                _MEMGET m, m.OFFSET + o, bb '                   | get edge pixel blue        |
                            END IF '                                            |                            |
                            '+--------------------------------------------------+                            |
                            '| Calculate pixel value for output image                                        |
                            '| ======================================                                        |
                            '+------------------------------------+                                          |
                            kv = Kernel(kx - x + r, ky - y + r) ' | get kernal value                         |
                            rv = rv + rb * kv '                   | convolute red value                      |
                            gv = gv + gb * kv '                   | convolute green value                    |
                            bv = bv + bb * kv '                   | convolute blue value                     |
                            ko = ko + 4 '                         | next pixel offset                        |
                            kx = kx + 1 '                         | next matrix column                       |
                        LOOP UNTIL kx > x + r '                   | leave at right side of matrix            |
                        ky = ky + 1 '                             | next matrix row                          |
                    LOOP UNTIL ky > y + r '                       | leave at bottom of matrix                |
                    '+--------------------------------------------+                                          |
                    '| Write new pixel to target image                                                       |
                    '| ===============================                                                       |
                    '+-----------------------------------------------------+                                 |
                    _MEMPUT tm, tm.OFFSET + o + 2, rv AS _UNSIGNED _BYTE ' | write red to target image       |
                    _MEMPUT tm, tm.OFFSET + o + 1, gv AS _UNSIGNED _BYTE ' | write green to target image     |
                    _MEMPUT tm, tm.OFFSET + o, bv AS _UNSIGNED _BYTE '     | write blue to target image      |
                    '+-----------------------------------------------------+                                 |
                    '| Move to next pixel in source image                                                    |
                    '| ==================================                                                    |
                    '+-------------+                                                                         |
                    o = o + 4 '    | next pixel offset                                                       |
                    x = x + 1 '    | next image column                                                       |
                LOOP UNTIL x = w ' | leave when at right side of image                                       |
                y = y + 1 '        | next image row                                                          |
            LOOP UNTIL y = h '     | leave when at bottom of image                                           |
            '                      +-------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Replace source image with blurred target image                                                |
            '| ==============================================                                                |
            '+-----------------------------------------------+                                               |
            _MEMCOPY tm, tm.OFFSET, tm.SIZE TO m, m.OFFSET ' | overwrite source image with target image      |
            _MEMFREE m '                                     | free source image memory block                |
            _MEMFREE tm '                                    | free target image memory block                |
            _FREEIMAGE ti '                                  | remove target image from memory               |
            '                                                +-----------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Filter (i AS LONG, me AS INTEGER) '                                                       __Filter |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Applies a pre-defined filter matrix to an image without affecting the origial alpha values.           |
    '|                                                                                                       |
    '| i  - the image to work with                                                                           |
    '| me - the filter method to apply (1 to 31)                                                             |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '|                                                                                                       |
    '| This subroutine is simply a redesign of RhoSigma's excellent ApplyFilter function found in            |
    '| imageprocess.bm                                                                                       |
    '\_______________________________________________________________________________________________________/

    DIM w AS INTEGER '            image width
    DIM h AS INTEGER '            image height
    DIM ti AS LONG '              temporary target image
    DIM m AS _MEM '               memory block holding image data
    DIM tm AS _MEM '              memory block holding target image data
    DIM o AS _OFFSET '            pixel location within memory block
    DIM fo AS _OFFSET '           filter offset
    DIM x AS INTEGER '            horizontal location of pixel
    DIM y AS INTEGER '            vertical location of pixel
    DIM fx AS INTEGER '           horizontal filter offset of pixel
    DIM fy AS INTEGER '           vertical filter offset of pixel
    DIM alph AS _UNSIGNED _BYTE ' alpha value of each pixel
    DIM r AS _UNSIGNED _BYTE '    red value of each pixel
    DIM g AS _UNSIGNED _BYTE '    green value of each pixel
    DIM b AS _UNSIGNED _BYTE '    blue value of each pixel
    DIM sr AS LONG '              sum of new red value
    DIM sg AS LONG '              sum of new green value
    DIM sb AS LONG '              sum of new blue value
    DIM f(6, 6) AS INTEGER '      filter matrix
    DIM wt AS INTEGER '           weight of individual filter matrix cell
    DIM sz AS INTEGER '           kernel size within matrix
    DIM s AS INTEGER '            half the kernel size within matrix (radius)
    DIM a AS INTEGER '            add
    DIM d AS INTEGER '            divide

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Populate the kernel matrix with desired filter method                                         |
            '| =====================================================                                         |
            '+---------------+                                                                               |
            SELECT CASE me ' | which method?                                                                 |
                '            +-------------------------------------------------------------------------------+
                CASE 1 'DEEP (artistic)
                    '0  0  0  0  0  0  0
                    '0  0  0  1  0  0  0
                    '0  0  0  3  0  0  0
                    '0  1  3  1 -3 -1  0   Representation of kernel filter matrix being applied
                    '0  0  0 -3  0  0  0
                    '0  0  0 -1  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 5: a = 0: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 1: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 3: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 1: f(3, 2) = 3: f(3, 3) = 1: f(3, 4) = -3: f(3, 5) = -1: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = -3: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = -1: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 2 'RUSHHOUR (artistic)
                    '0  0  0  0  0  0  0
                    '0  1  0  0  0  2  0
                    '0  0  2  0  1  0  0
                    '0  0  0  2  0  0  0
                    '0  0 -1  0 -2  0  0
                    '0 -2  0  0  0 -1  0
                    '0  0  0  0  0  0  0
                    sz = 5: a = -150: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 1: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 2: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 2: f(2, 3) = 0: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 2: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -1: f(4, 3) = 0: f(4, 4) = -2: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = -2: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = -1: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 3 'TEXTURE (artistic)
                    '0  0  0  0  0  0  0
                    '0  0  0  1  0  0  0
                    '0  0 -1  0 -1  0  0
                    '0  1  0  1  0  1  0
                    '0  0 -1  0 -1  0  0
                    '0  0  0  1  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 5: a = 0: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 1: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -1: f(2, 3) = 0: f(2, 4) = -1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 1: f(3, 2) = 0: f(3, 3) = 1: f(3, 4) = 0: f(3, 5) = 1: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -1: f(4, 3) = 0: f(4, 4) = -1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 1: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 4 'WOODEN (artistic)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -2  0  0  0  0
                    '0  0  0  5  0  0  0
                    '0  0  0  0 -2  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -2: f(2, 3) = 0: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 5: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = 0: f(4, 4) = -2: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 5 'AVERAGE3 (bluring)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  1  1  1  0  0
                    '0  0  1  1  1  0  0
                    '0  0  1  1  1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 9
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 1: f(2, 3) = 1: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 1: f(3, 3) = 1: f(3, 4) = 1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 1: f(4, 3) = 1: f(4, 4) = 1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 6 'AVERAGE5 (bluring)
                    '0  0  0  0  0  0  0
                    '0  1  1  1  1  1  0
                    '0  1  1  1  1  1  0
                    '0  1  1  1  1  1  0
                    '0  1  1  1  1  1  0
                    '0  1  1  1  1  1  0
                    '0  0  0  0  0  0  0
                    sz = 5: a = 0: d = 25
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 1: f(1, 2) = 1: f(1, 3) = 1: f(1, 4) = 1: f(1, 5) = 1: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 1: f(2, 2) = 1: f(2, 3) = 1: f(2, 4) = 1: f(2, 5) = 1: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 1: f(3, 2) = 1: f(3, 3) = 1: f(3, 4) = 1: f(3, 5) = 1: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 1: f(4, 2) = 1: f(4, 3) = 1: f(4, 4) = 1: f(4, 5) = 1: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 1: f(5, 2) = 1: f(5, 3) = 1: f(5, 4) = 1: f(5, 5) = 1: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 7 'AVERAGE7 (bluring)
                    '1  1  1  1  1  1  1
                    '1  1  1  1  1  1  1
                    '1  1  1  1  1  1  1
                    '1  1  1  1  1  1  1
                    '1  1  1  1  1  1  1
                    '1  1  1  1  1  1  1
                    '1  1  1  1  1  1  1
                    sz = 7: a = 0: d = 49
                    f(0, 0) = 1: f(0, 1) = 1: f(0, 2) = 1: f(0, 3) = 1: f(0, 4) = 1: f(0, 5) = 1: f(0, 6) = 1
                    f(1, 0) = 1: f(1, 1) = 1: f(1, 2) = 1: f(1, 3) = 1: f(1, 4) = 1: f(1, 5) = 1: f(1, 6) = 1
                    f(2, 0) = 1: f(2, 1) = 1: f(2, 2) = 1: f(2, 3) = 1: f(2, 4) = 1: f(2, 5) = 1: f(2, 6) = 1
                    f(3, 0) = 1: f(3, 1) = 1: f(3, 2) = 1: f(3, 3) = 1: f(3, 4) = 1: f(3, 5) = 1: f(3, 6) = 1
                    f(4, 0) = 1: f(4, 1) = 1: f(4, 2) = 1: f(4, 3) = 1: f(4, 4) = 1: f(4, 5) = 1: f(4, 6) = 1
                    f(5, 0) = 1: f(5, 1) = 1: f(5, 2) = 1: f(5, 3) = 1: f(5, 4) = 1: f(5, 5) = 1: f(5, 6) = 1
                    f(6, 0) = 1: f(6, 1) = 1: f(6, 2) = 1: f(6, 3) = 1: f(6, 4) = 1: f(6, 5) = 1: f(6, 6) = 1
                CASE 8 'GAUSS4 (bluring)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  1  0  0  0
                    '0  0  1  2  1  0  0
                    '0  0  0  1  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 6
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 1: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 1: f(3, 3) = 2: f(3, 4) = 1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = 1: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 9 'GAUSS8 (bluring)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  1  2  1  0  0
                    '0  0  2  4  2  0  0
                    '0  0  1  2  1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 16
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 1: f(2, 3) = 2: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 2: f(3, 3) = 4: f(3, 4) = 2: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 1: f(4, 3) = 2: f(4, 4) = 1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 10 'NEEDGLASSES (bluring)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  30 0  0  0  30 0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 5: a = 0: d = 60
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 0: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 30: f(3, 2) = 0: f(3, 3) = 0: f(3, 4) = 0: f(3, 5) = 30: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = 0: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 11 'UNSHARPCAM (bluring)
                    '30 0  0  10 0  0  10
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  20 0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '30 0  0  30 0  0  10
                    sz = 7: a = 0: d = 140
                    f(0, 0) = 30: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 10: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 10
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 0: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 20: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = 0: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 30: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 30: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 10
                CASE 12 'LOWSHARPEN (sharpen)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0 -1  0  0  0
                    '0  0 -1  12-1  0  0
                    '0  0  0 -1  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 8
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = -1: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -1: f(3, 3) = 12: f(3, 4) = -1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = -1: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 13 'MEDIUMSHARPEN (sharpen)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0 -1  0  0  0
                    '0  0 -1  10-1  0  0
                    '0  0  0 -1  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 6
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = -1: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -1: f(3, 3) = 10: f(3, 4) = -1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = -1: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 14 'HIGHSHARPEN (sharpen)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -2  1 -2  0  0
                    '0  0  1  12 1  0  0
                    '0  0 -2  1 -2  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 0: d = 8
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -2: f(2, 3) = 1: f(2, 4) = -2: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 1: f(3, 3) = 12: f(3, 4) = 1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -2: f(4, 3) = 1: f(4, 4) = -2: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 15 'MEXICANHAT (sharpen)
                    '0  0  0  0  0  0  0
                    '0  0  0 -1  0  0  0
                    '0  0  1 -2  1  0  0
                    '0 -1 -2  16-2 -1  0
                    '0  0  1 -2  1  0  0
                    '0  0  0 -1  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 5: a = 0: d = 8
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = -1: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 1: f(2, 3) = -2: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = -1: f(3, 2) = -2: f(3, 3) = 16: f(3, 4) = -2: f(3, 5) = -1: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 1: f(4, 3) = -2: f(4, 4) = 1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = -1: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 16 'KIRSCHN (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  5  5  5  0  0
                    '0  0 -3  0 -3  0  0
                    '0  0 -3 -3 -3  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 5: f(2, 3) = 5: f(2, 4) = 5: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -3: f(3, 3) = 0: f(3, 4) = -3: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -3: f(4, 3) = -3: f(4, 4) = -3: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 17 'KIRSCHNW (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  5  5 -3  0  0
                    '0  0  5  0 -3  0  0
                    '0  0 -3 -3 -3  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 5: f(2, 3) = 5: f(2, 4) = -3: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 5: f(3, 3) = 0: f(3, 4) = -3: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -3: f(4, 3) = -3: f(4, 4) = -3: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 18 'KIRSCHW (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  5 -3 -3  0  0
                    '0  0  5  0 -3  0  0
                    '0  0  5 -3 -3  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 5: f(2, 3) = -3: f(2, 4) = -3: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 5: f(3, 3) = 0: f(3, 4) = -3: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 5: f(4, 3) = -3: f(4, 4) = -3: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 19 'KIRSCHSW (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -3 -3 -3  0  0
                    '0  0  5  0 -3  0  0
                    '0  0  5  5 -3  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -3: f(2, 3) = -3: f(2, 4) = -3: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 5: f(3, 3) = 0: f(3, 4) = -3: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 5: f(4, 3) = 5: f(4, 4) = -3: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 20 'KIRSCHS (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -3 -3 -3  0  0
                    '0  0 -3  0 -3  0  0
                    '0  0  5  5  5  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -3: f(2, 3) = -3: f(2, 4) = -3: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -3: f(3, 3) = 0: f(3, 4) = -3: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 5: f(4, 3) = 5: f(4, 4) = 5: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 21 'KIRSCHSE (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -3 -3 -3  0  0
                    '0  0 -3  0  5  0  0
                    '0  0 -3  5  5  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -3: f(2, 3) = -3: f(2, 4) = -3: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -3: f(3, 3) = 0: f(3, 4) = 5: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -3: f(4, 3) = 5: f(4, 4) = 5: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 22 'KIRSCHE (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -3 -3  5  0  0
                    '0  0 -3  0  5  0  0
                    '0  0 -3 -3  5  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -3: f(2, 3) = -3: f(2, 4) = 5: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -3: f(3, 3) = 0: f(3, 4) = 5: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -3: f(4, 3) = -3: f(4, 4) = 5: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 23 'KIRSCHNE (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -3  5  5  0  0
                    '0  0 -3  0  5  0  0
                    '0  0 -3 -3 -3  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -3: f(2, 3) = 5: f(2, 4) = 5: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -3: f(3, 3) = 0: f(3, 4) = 5: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -3: f(4, 3) = -3: f(4, 4) = -3: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 24 'LAPLACE4 (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  1  0  0  0
                    '0  0  1 -4  1  0  0
                    '0  0  0  1  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 1: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 1: f(3, 3) = -4: f(3, 4) = 1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = 1: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 25 'LAPLACE8 (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  1  1  1  0  0
                    '0  0  1 -8  1  0  0
                    '0  0  1  1  1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 1: f(2, 3) = 1: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 1: f(3, 3) = -8: f(3, 4) = 1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 1: f(4, 3) = 1: f(4, 4) = 1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 26 'ROBERTS1 (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  1  0  0  0
                    '0  0  0  0 -1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 0: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 1: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 0: f(4, 3) = 0: f(4, 4) = -1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 27 'ROBERTS2 (edge detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  1  0  0  0
                    '0  0 -1  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 0: f(2, 3) = 0: f(2, 4) = 0: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 1: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -1: f(4, 3) = 0: f(4, 4) = 0: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 28 'PREWITT1 (line detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -1  0  1  0  0
                    '0  0 -1  0  1  0  0
                    '0  0 -1  0  1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -1: f(2, 3) = 0: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = -1: f(3, 3) = 0: f(3, 4) = 1: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -1: f(4, 3) = 0: f(4, 4) = 1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 29 'PREWITT2 (line detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -1 -1 -1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  1  1  1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = -1: f(2, 3) = -1: f(2, 4) = -1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 0: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 1: f(4, 3) = 1: f(4, 4) = 1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 30 'SOBEL1 (line detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  1  0 -1  0  0
                    '0  0  2  0 -2  0  0
                    '0  0  1  0 -1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 1: f(2, 3) = 0: f(2, 4) = -1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 2: f(3, 3) = 0: f(3, 4) = -2: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = 1: f(4, 3) = 0: f(4, 4) = -1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
                CASE 31 'SOBEL2 (line detect)
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    '0  0  1  2  1  0  0
                    '0  0  0  0  0  0  0
                    '0  0 -1 -2 -1  0  0
                    '0  0  0  0  0  0  0
                    '0  0  0  0  0  0  0
                    sz = 3: a = 128: d = 1
                    f(0, 0) = 0: f(0, 1) = 0: f(0, 2) = 0: f(0, 3) = 0: f(0, 4) = 0: f(0, 5) = 0: f(0, 6) = 0
                    f(1, 0) = 0: f(1, 1) = 0: f(1, 2) = 0: f(1, 3) = 0: f(1, 4) = 0: f(1, 5) = 0: f(1, 6) = 0
                    f(2, 0) = 0: f(2, 1) = 0: f(2, 2) = 1: f(2, 3) = 2: f(2, 4) = 1: f(2, 5) = 0: f(2, 6) = 0
                    f(3, 0) = 0: f(3, 1) = 0: f(3, 2) = 0: f(3, 3) = 0: f(3, 4) = 0: f(3, 5) = 0: f(3, 6) = 0
                    f(4, 0) = 0: f(4, 1) = 0: f(4, 2) = -1: f(4, 3) = -2: f(4, 4) = -1: f(4, 5) = 0: f(4, 6) = 0
                    f(5, 0) = 0: f(5, 1) = 0: f(5, 2) = 0: f(5, 3) = 0: f(5, 4) = 0: f(5, 5) = 0: f(5, 6) = 0
                    f(6, 0) = 0: f(6, 1) = 0: f(6, 2) = 0: f(6, 3) = 0: f(6, 4) = 0: f(6, 5) = 0: f(6, 6) = 0
            END SELECT
            '+-----------------------------------------------------------------------------------------------+
            '| Create a target image                                                                         |
            '| =====================                                                                         |
            '+-------------------+                                                                           |
            ti = _COPYIMAGE(i) ' | create target image                                                       |
            w = _WIDTH(ti) '     | get target image width                                                    |
            h = _HEIGHT(ti) '    | get target image height                                                   |
            '                    +---------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-------------------+                                                                           |
            m = _MEMIMAGE(i) '   | source image memory block                                                 |
            tm = _MEMIMAGE(ti) ' | target image memory block                                                 |
            '                    +---------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Apply filter to image                                                                         |
            '| =====================                                                                         |
            '+------------------------------------------+                                                    |
            s = sz \ 2 '                                | radius of kernel within matrix                     |
            y = 0 '                                     | reset vertical counter                             |
            DO '                                        | begin vertical image pixel counter                 |
                o = (y * w * 4) '                       | calculate offset location of pixel                 |
                x = 0 '                                 | reset horizontal counter                           |
                DO '                                    | begin horizontal image pixel counter               |
                    _MEMGET m, m.OFFSET + o + 3, alph ' | get current alpha value                            |
                    sr = 0: sg = 0: sb = 0 '            | reset new pixel RGB color sums                     |
                    '+----------------------------------+                                                    |
                    '| Get RGB value of pixel within image                                                   |
                    '| ===================================                                                   |
                    '+----------------------------------------------------------+                            |
                    fy = y - s '                                                | set matrix row counter     |
                    DO '                                                        | begin matrix row counter   |
                        fo = (fy * w * 4) + ((x - s) * 4) '                     | matrix offset location     |
                        fx = x - s '                                            | set matrix column counter  |
                        DO '                                                    | begin matrix column counter|
                            IF fy >= 0 AND fy < h AND fx >= 0 AND fx < w THEN ' | matrix within image??      |
                                _MEMGET m, m.OFFSET + fo + 2, r '               | yes, get this pixel red    |
                                _MEMGET m, m.OFFSET + fo + 1, g '               | get this pixel green       |
                                _MEMGET m, m.OFFSET + fo, b '                   | get this pixel blue        |
                            ELSE '                                              | no, outside of image       |
                                _MEMGET m, m.OFFSET + o + 2, r '                | get edge pixel red         |
                                _MEMGET m, m.OFFSET + o + 1, g '                | get edge pixel green       |
                                _MEMGET m, m.OFFSET + o, b '                    | get edge pixel blue        |
                            END IF '                                            |                            |
                            '+--------------------------------------------------+                            |
                            '| Calculate pixel value for output image                                        |
                            '| ======================================                                        |
                            '+-------------------------------+                                               |
                            wt = f(fy - y + 3, fx - x + 3) ' | get weight of location from kernel matrix     |
                            sr = sr + (r * wt) '             | sum up red component weight                   |
                            sg = sg + (g * wt) '             | sum up green component weight                 |
                            sb = sb + (b * wt) '             | sum up blue component weight                  |
                            fo = fo + 4 '                    | move to next pixel offset in memory block     |
                            fx = fx + 1 '                    | move to next horizontal kernel location       |
                        LOOP UNTIL fx > x + s '              | leave at right side of kernel                 |
                        fy = fy + 1 '                        | move to next vertical kernel location         |
                    LOOP UNTIL fy > y + s '                  | leave at bottom of kernel                     |
                    '+---------------------------------------+                                               |
                    '| Write new pixel to target image                                                       |
                    '| ===============================                                                       |
                    '+-----------------------------------------------------------------------------+         |
                    _MEMPUT tm, tm.OFFSET + o, _RGBA32(CINT(sr / d) + a,_
                                                       CINT(sg / d) + a,_
                                                       CINT(sb / d) + a, alph) AS _UNSIGNED LONG ' | write   |
                    '+-----------------------------------------------------------------------------| pixel   |
                    '| Move to next pixel in source image                                                    |
                    '| ==================================                                                    |
                    '+-------------+                                                                         |
                    o = o + 4 '    | next pixel offset                                                       |
                    x = x + 1 '    | next image column                                                       |
                LOOP UNTIL x = w ' | leave when at right side of image                                       |
                y = y + 1 '        | next image row                                                          |
            LOOP UNTIL y = h '     | leave when at bottom of image                                           |
            '                      +-------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Replace source image with blurred target image                                                |
            '| ==============================================                                                |
            '+-----------------------------------------------+                                               |
            _MEMCOPY tm, tm.OFFSET, tm.SIZE TO m, m.OFFSET ' | overwrite source image with target image      |
            _MEMFREE tm '                                    | free target image memory block                |
            _MEMFREE m '                                     | free source image memory block                |
            _FREEIMAGE ti '                                  | remove target image image from memory         |
            '                                                +-----------------------------------------------|
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Gamma (i AS LONG, l AS SINGLE) '                                                           __Gamma |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Adjusts the gamma correction of an image without affecting original alpha values.                     |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| l - the level of gamma correction (> 0 to <= 10, 1 = no change in gamma level)                        |
    '|                                                                                                       |
    '| Uses the formula: v = 255 x (input value / 255) ^ 1 / gamma                                           |
    '|                                                                                                       |
    '| A level value less than 1 will darken the image. Values above 1 will brighten the image.              |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '|                                                                                                       |
    '| More information can be found here:                                                                   |
    '| https://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/                        |
    '|         image-processing-algorithms-part-6-gamma-correction/                                          |
    '\_______________________________________________________________________________________________________/

    DIM m AS _MEM '                 memory block holding image data
    DIM e AS _OFFSET '              end of memory block
    DIM o AS _OFFSET '              pixel location within memory block
    DIM gc AS SINGLE '              new gamma correction value
    DIM v AS INTEGER '              new calculated component gamma corrected brightness value
    DIM c AS INTEGER '              generic counter
    DIM h(255) AS _UNSIGNED _BYTE ' translation table to hold new gamma corrected brightness values

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Create a brightness translation table.                                                        |
            '| ======================================                                                        |
            '| The following table contains the new component values based on the calculated gamma           |
            '| correction provided by the formula listed above.                                              |
            '+-------------------------------------------------------+                                       |
            gc = l '                                                 | get gamma level change desired        |
            IF gc <= 0 THEN gc = .001 ELSE IF gc > 10 THEN gc = 10 ' | truncate level if necessary           |
            gc = 1 / gc '                                            | calculate gamma correction exponent   |
            c = 0 '                                                  | reset table counter                   |
            DO '                                                     | begin translation table creation      |
                v = FIX((c / 255) ^ gc * 255 + .5) '                 | calculate new gamma value             |
                IF v < 0 THEN v = 0 ELSE IF v > 255 THEN v = 255 '   | truncate new gamma value if necessary |
                h(c) = v '                                           | store new gamma value                 |
                c = c + 1 '                                          | increment table counter               |
            LOOP UNTIL c = 256 '                                     | leave when table created              |
            '                                                        +---------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-----------------+                                                                             |
            m = _MEMIMAGE(i) ' | create memory block containing image                                        |
            o = m.OFFSET '     | start position of memory block                                              |
            e = o + m.SIZE '   | end position of memory block                                                |
            '                  +-----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Translate each pixel's component values to the new values contained in the table.             |
            '| =================================================================================             |
            '| Use each component's current value as the table index value to get the new calculated         |
            '| brightness value.                                                                             |
            '+------------------------------------------------------------+                                  |
            DO '                                                          | begin brightness translation     |
                _MEMPUT m, o + 2, h(_MEMGET(m, o + 2, _UNSIGNED _BYTE)) ' | get then set new red value       |
                _MEMPUT m, o + 1, h(_MEMGET(m, o + 1, _UNSIGNED _BYTE)) ' | get then set new green value     |
                _MEMPUT m, o, h(_MEMGET(m, o, _UNSIGNED _BYTE)) '         | get then set new blue value      |
                o = o + 4 '                                               | next pixel location in block     |
            LOOP UNTIL o = e '                                            | leave when end of block reached  |
            _MEMFREE m '                                                  | free memory block                |
            '                                                             +----------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Contrast (i AS LONG, l AS SINGLE) '                                                     __Contrast |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Adjusts the contrast of an image without affecting original alpha values.                             |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| l - the level of contrast (-1 to 1 or -100% to +100%, 0% = no change)                                 |
    '|                                                                                                       |
    '| Uses formula: v = 259 * ( l * 128 + 255) / 255 * (259 - l * 128) * (component_level - 128) + 128      |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '|                                                                                                       |
    '| This subroutine also draws insight from Francis G. Loch's contrast adjustment page found here:        |
    '| https://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/                        |
    '|         image-processing-algorithms-part-5-contrast-adjustment/                                       |
    '\_______________________________________________________________________________________________________/

    DIM m AS _MEM '                 memory block holding image data
    DIM e AS _OFFSET '              end of memory block holding image data
    DIM o AS _OFFSET '              each pixel location within memory block
    DIM c AS INTEGER '              generic counter
    DIM v AS INTEGER '              new calculated component contrast value
    DIM ch AS SINGLE '              change in contrast
    DIM f AS DOUBLE '               contrast correction factor
    DIM h(255) AS _UNSIGNED _BYTE ' translation table to hold new component contrast values

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Create a contrast translation table.                                                          |
            '| ====================================                                                          |
            '+-----------------------------------------------------+                                         |
            ch = l * 128 '                                         | change scale to -128 to +128            |
            f = (259 * (ch + 255)) / (255 * (259 - ch)) '          | calculate contrast correction factor    |
            c = 0 '                                                | reset table counter                     |
            DO '                                                   | begin translation table creation        |
                v = FIX(f * (c - 128) + 128) '                     | calculate contrast level value          |
                IF v < 0 THEN v = 0 ELSE IF v > 255 THEN v = 255 ' | truncate value if necessary             |
                h(c) = v '                                         | store value                             |
                c = c + 1 '                                        | increment table counter                 |
            LOOP UNTIL c = 256 '                                   | leave when table created                |
            '                                                      +-----------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-----------------+                                                                             |
            m = _MEMIMAGE(i) ' | create memory block containing image                                        |
            o = m.OFFSET '     | start position of memory block                                              |
            e = o + m.SIZE '   | end position of memory block                                                |
            '                  +-----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Translate each pixel's component values to the new values contained in the table.             |
            '| =================================================================================             |
            '| Use each component's current value as the table index value to get the new calculated         |
            '| contrast value.                                                                               |
            '+------------------------------------------------------------+                                  |
            DO '                                                          | begin contrast translation       |
                _MEMPUT m, o + 2, h(_MEMGET(m, o + 2, _UNSIGNED _BYTE)) ' | get then set new red value       |
                _MEMPUT m, o + 1, h(_MEMGET(m, o + 1, _UNSIGNED _BYTE)) ' | get then set new green value     |
                _MEMPUT m, o, h(_MEMGET(m, o, _UNSIGNED _BYTE)) '         | get then set new blue value      |
                o = o + 4 '                                               | next pixel location in block     |
            LOOP UNTIL o = e '                                            | leave when end of block reached  |
            _MEMFREE m '                                                  | free memory block                |
            '                                                             +----------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Brightness (i AS LONG, l AS SINGLE) '                                                 __Brightness |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Adjusts the brightness of an image without affecting original alpha values.                           |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| l - the level of brightness (-1 to 1 or -100% all black to +100% all white, 0% = no change)           |
    '|                                                                                                       |
    '| Uses the formula: component_color = component_color + brightness                                      |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '|                                                                                                       |
    '| More information can be found here:                                                                   |
    '| https://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/                        |
    '|         image-processing-algorithms-part-4-brightness-adjustment/                                     |
    '\_______________________________________________________________________________________________________/

    DIM m AS _MEM '                 memory block holding image data
    DIM e AS _OFFSET '              end of memory block holding image data
    DIM o AS _OFFSET '              each pixel location within memory block
    DIM c AS INTEGER '              generic counter
    DIM v AS INTEGER '              new calculated component brightness value
    DIM h(255) AS _UNSIGNED _BYTE ' translation table to hold new component brightness values

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Create a brightness translation table.                                                        |
            '| ======================================                                                        |
            '| The following table contains the new component values based on the brightness level (l). For  |
            '| example, if the level of change is -.5 (l = -.5) and the color component of any given pixel   |
            '| is 128 then the table at index 128 will have the value:                                       |
            '| h(128) = 128 * (l + 1)                                                                        |
            '| h(128) = 128 * .5                                                                             |
            '| h(128) = 64 (half the brightness)                                                             |
            '| All index values in this case will be half the brightness based on the level of change being  |
            '| -.5 (or -50%). The table in this case will translate the values 0 to 255 to 0 to 128.         |
            '+-----------------------------------------------------+                                         |
            c = 0 '                                                | reset table index counter               |
            DO '                                                   | begin translation table creation        |
                v = FIX(c * (l + 1)) '                             | calculate new brightness value          |
                IF v < 0 THEN v = 0 ELSE IF v > 255 THEN v = 255 ' | truncate to 0 to 255 if necessary       |
                h(c) = v '                                         | store new brightness level              |
                c = c + 1 '                                        | increment table index counter           |
            LOOP UNTIL c = 256 '                                   | leave when table created                |
            '                                                      +-----------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-----------------+                                                                             |
            m = _MEMIMAGE(i) ' | create memory block containing image                                        |
            o = m.OFFSET '     | start position of memory block                                              |
            e = o + m.SIZE '   | end position of memory block                                                |
            '                  +-----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Translate each pixel's component values to the new values contained in the table.             |
            '| =================================================================================             |
            '| Use each component's current value as the table index value to get the new calculated         |
            '| brightness value.                                                                             |
            '+------------------------------------------------------------+                                  |
            DO '                                                          | begin brightness translation     |
                _MEMPUT m, o + 2, h(_MEMGET(m, o + 2, _UNSIGNED _BYTE)) ' | get then set new red value       |
                _MEMPUT m, o + 1, h(_MEMGET(m, o + 1, _UNSIGNED _BYTE)) ' | get then set new green value     |
                _MEMPUT m, o, h(_MEMGET(m, o, _UNSIGNED _BYTE)) '         | get then set new blue value      |
                o = o + 4 '                                               | next pixel location in block     |
            LOOP UNTIL o = e '                                            | leave when end of block reached  |
            _MEMFREE m '                                                  | free memory block                |
            '                                                             +----------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __GrayScale (i AS LONG) '                                                                __GrayScale |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Converts an image to gray scale without affecting original alpha values.                              |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '|                                                                                                       |
    '| Uses ITU-R 601-2 Luma Transformation (L = R * 299/1000 + G * 587/1000 + B * 114/1000)                 |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '|                                                                                                       |
    '| More information can be found here:                                                                   |
    '| https://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/                        |
    '|         image-processing-algorithms-part-3-greyscale-conversion/                                      |
    '\_______________________________________________________________________________________________________/

    DIM m AS _MEM '            memory block holding image data
    DIM e AS _OFFSET '         end of memory block
    DIM o AS _OFFSET '         4 byte pixel location within memory block
    DIM r AS _UNSIGNED _BYTE ' red value of each pixel
    DIM g AS _UNSIGNED _BYTE ' green value of each pixel / new gray value of each pixel
    DIM b AS _UNSIGNED _BYTE ' blue value of each pixel

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-----------------+                                                                             |
            m = _MEMIMAGE(i) ' | create memory block containing image                                        |
            o = m.OFFSET '     | start position of memory block                                              |
            e = o + m.SIZE '   | end position of memory block                                                |
            '                  +-----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Convert each pixel in the image to its grayscale equivalent.                                  |
            '| ============================================================                                  |
            '| Get each pixel's red, green, and blue components and calculate the gray level using Luma      |
            '| Transformation. Use the same calculated value to write the pixel's red, green, and blue       |
            '| components to create a level of gray.                                                         |
            '+---------------------------------------+                                                       |
            DO '                                     | begin luma transformation                             |
                _MEMGET m, o + 2, r '                | get red   (0 to 255)                                  |
                _MEMGET m, o + 1, g '                | get green (0 to 255)                                  |
                _MEMGET m, o, b '                    | get blue  (0 to 255)                                  |
                g = r * .299 + g * .587 + b * .114 ' | calculate gray level                                  |
                _MEMPUT m, o + 2, g '                | set red pixel value (RGB all same to make gray level) |
                _MEMPUT m, o + 1, g '                | set green pixel value                                 |
                _MEMPUT m, o, g '                    | set blue pixel value                                  |
                o = o + 4 '                          | next pixel location in block                          |
            LOOP UNTIL o = e '                       | leave when end of block reached                       |
            _MEMFREE m '                             | free memory block                                     |
            '                                        +-------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Replace (i AS LONG, c AS _UNSIGNED LONG, n AS _UNSIGNED LONG) '                          __Replace |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Replaces a color in an image with another color without affecting original alpha values.              |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| c - the color to replace      (from)                                                                  |
    '| n - the new replacement color (to)                                                                    |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '\_______________________________________________________________________________________________________/

    CONST GETRGB = 16777215 '     00000000111111111111111111111111 extract RGB
    CONST GETALPHA = 4278190080 ' 11111111000000000000000000000000 extract alpha
    DIM m AS _MEM '               memory block holding image data
    DIM e AS _OFFSET '            end of memory block
    DIM o AS _OFFSET '            pixel location within memory block
    DIM cr AS LONG '              RGB of color to replace
    DIM rc AS LONG '              RGB of replacement color
    DIM p AS _UNSIGNED LONG '     pixel color

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Extract RBG component colors                                                                  |
            '| ============================                                                                  |
            '+------------------+                                                                            |
            cr = c AND GETRGB ' | get RGB from color to replace                                              |
            rc = n AND GETRGB ' | get RGB from replacement color                                             |
            '                   +----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-----------------+                                                                             |
            m = _MEMIMAGE(i) ' | create memory block containing image                                        |
            o = m.OFFSET '     | start position of memory block                                              |
            e = o + m.SIZE '   | end position of memory block                                                |
            '                  +-----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Replace color in image                                                                        |
            '| ======================                                                                        |
            '+--------------------------------------------------------------+                                |
            DO '                                                            | begin color replacement        |
                _MEMGET m, o, p '                                           | get pixel from block           |
                IF (p AND GETRGB) = cr THEN '                               | is this the color to replace?  |
                    _MEMPUT m, o, (p AND GETALPHA) + rc AS _UNSIGNED LONG ' | yes, replace pixel color       |
                END IF '                                                    |                                |
                o = o + 4 '                                                 | next pixel location in block   |
            LOOP UNTIL o = e '                                              | leave when end of block reached|
            _MEMFREE m '                                                    | free memory block              |
            '                                                               +--------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Negative (i AS LONG) '                                                                  __Negative |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Creates a negative image without affecting original alpha values.                                     |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '|                                                                                                       |
    '| This subroutine draws insight from RhoSigma's imageprocess.bm Image Processing Libray found here:     |
    '| https://qb64phoenix.com/forum/showthread.php?tid=1033                                                 |
    '\_______________________________________________________________________________________________________/

    CONST RGB = 16777215 ' 000000001111111111111111 extract RGB
    DIM m AS _MEM '        memory block holding image data
    DIM e AS _OFFSET '     end of memory block
    DIM o AS _OFFSET '     pixel location within memory block

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Use direct image memory manipulation for speed.                                               |
            '| ==============================================                                                |
            '+-----------------+                                                                             |
            m = _MEMIMAGE(i) ' | create memory block containing image                                        |
            o = m.OFFSET '     | start position of memory block                                              |
            e = o + m.SIZE '   | end position of memory block                                                |
            '                  +-----------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Negate all image pixels                                                                       |
            '| =======================                                                                       |
            '+--------------------------------------------------------------------------+                    |
            DO '                                                                        | begin negation     |
                _MEMPUT m, o, _MEMGET(m, o, _UNSIGNED LONG) XOR RGB AS _UNSIGNED LONG ' | negate & save pixel|
                o = o + 4 '                                                             | next pixel location|
            LOOP UNTIL o = e '                                                          | leave end of block |
            _MEMFREE m '                                                                | free memory block  |
            '                                                                           +--------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Zoom (i AS LONG, p AS SINGLE) '                                                             __Zoom |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Resizes an image                                                                                      |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| p - the zoom percentage ( .25 = 25%, 1 = 100%, 2 = 200%, etc. )                                       |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '\_______________________________________________________________________________________________________/

    DIM c AS LONG '    temporary copy of image
    DIM b AS INTEGER ' image blend setting

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Resize the image                                                                              |
            '| ================                                                                              |
            '+-------------------------------------------------------+                                       |
            b = _BLEND(i) '                                          | get current blend setting of image    |
            c = _COPYIMAGE(i) '                                      | copy the image                        |
            _DONTBLEND c '                                           | turn off blending for speed           |
            _FREEIMAGE i '                                           | remove the original image surface     |
            i = _NEWIMAGE(_WIDTH(c) * p, _HEIGHT(c) * p, 32) '       | create the new image surface          |
            _DONTBLEND i '                                           | turn off blending for speed           |
            _PUTIMAGE (0, 0)-(_WIDTH(i) - 1, _HEIGHT(i) - 1), c, i ' | stretch/shrink copy onto image surface|
            _FREEIMAGE c '                                           | remove copy of image                  |
            IF b THEN _BLEND i '                                     | restore blending to image             |
            '                                                        +---------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Flip (i AS LONG, d AS INTEGER) '                                                            __Flip |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Flips an image                                                                                        |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| d - the flip direction (0 = none, 1 = horizontal, 2 = vertical, 3 = both)                             |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '\_______________________________________________________________________________________________________/

    DIM c AS LONG '    temporary copy of image
    DIM b AS INTEGER ' image blend setting

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Flip the image                                                                                |
            '| ==============                                                                                |
            '+---------------------------------------------------------------+                               |
            b = _BLEND(i) '                                                  | get blend setting of image    |
            _DONTBLEND i '                                                   | turn off blending for speed   |
            c = _COPYIMAGE(i) '                                              | copy the original image       |
            _DONTBLEND c '                                                   | turn off blending for speed   |
            SELECT CASE d '                                                  | flip in which direction?      |
                CASE 1 '                                                     | horizontally                  |
                    _PUTIMAGE (_WIDTH(i) - 1, 0)-(0, _HEIGHT(i) - 1), c, i ' | map copy of image onto image  |
                CASE 2 '                                                     | vertically                    |
                    _PUTIMAGE (0, _HEIGHT(i) - 1)-(_WIDTH(i) - 1, 0), c, i ' | map copy of image onto image  |
                CASE 3 '                                                     | horizontally and vertically   |
                    _PUTIMAGE (_WIDTH(i) - 1, _HEIGHT(i) - 1)-(0, 0), c, i ' | map copy of image onto image  |
            END SELECT '                                                     |                               |
            _FREEIMAGE c '                                                   | remove copy of image          |
            IF b THEN _BLEND i '                                             | restore blending to image     |
            '                                                                +-------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
' _______________________________________________________________________________________________________
'/                                                                                                       \
SUB __Rotate (i AS LONG, d AS SINGLE) '                                                         __Rotate |
    ' ___________________________________________________________________________________________________|___
    '/                                                                                                       \
    '| Rotates an image to an the degree angle provided.                                                     |
    '|                                                                                                       |
    '| i - the image to work with                                                                            |
    '| d - the angle of rotation (0 to 360 clockwise from north/up )                                         |
    '|                                                                                                       |
    '| NOTE: Only works with 32 bit images                                                                   |
    '\_______________________________________________________________________________________________________/

    DIM c AS LONG '        temporary copy of image
    DIM a AS SINGLE '      angle of rotation
    DIM px(3) AS INTEGER ' x vector values of four corners of image
    DIM py(3) AS INTEGER ' y vector values of four corners of image
    DIM l AS INTEGER '     left-most value seen when calculating rotated image size
    DIM r AS INTEGER '     right-most value seen when calculating rotated image size
    DIM t AS INTEGER '     top-most value seen when calculating rotated image size
    DIM b AS INTEGER '     bottom-most value seen when calculating rotated image size
    DIM bl AS INTEGER '    image blend setting
    DIM w AS INTEGER '     width of image to rotate
    DIM h AS INTEGER '     height of image to rotate
    DIM rw AS INTEGER '    width of rotated image
    DIM rh AS INTEGER '    height of rotated image
    DIM xo AS INTEGER '    x offset used to move (0,0) back to upper left corner of image
    DIM yo AS INTEGER '    y offset used to move (0,0) back to upper left corner of image
    DIM cr AS SINGLE '     cosine of radian calculation for matrix rotation
    DIM sr AS SINGLE '     sine of radian calculation for matrix rotation
    DIM x AS SINGLE '      new x vector of rotated point
    DIM y AS SINGLE '      new y vector of rotated point
    DIM v AS INTEGER '     vector counter

    '+-------------------------------------------------------------------------------------------------------+
    '| Check for a valid image before proceeding.                                                            |
    '| ==========================================                                                            |
    '+------------------------------+                                                                        |
    IF i < -1 THEN '                | is this a valid image handle?                                          |
        IF _PIXELSIZE(i) = 4 THEN ' | is this a 32 bit color image?                                          |
            '                       +------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned off for an increase in processing speed.                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:OFF
            '+-----------------------------------------------------------------------------------------------+
            '| Copy original image and correct rotation angle if needed                                      |
            '|=========================================================                                      |
            '+------------------------------+                                                                |
            bl = _BLEND(i) '                | yes, get blend setting of image                                |
            c = _COPYIMAGE(i) '             | create a copy of image                                         |
            _DONTBLEND c '                  | turn off blending for speed                                    |
            _FREEIMAGE i '                  | remove image                                                   |
            a = d '                         | get angle                                                      |
            IF a < 0 OR a >= 360 THEN '     | angle out of range? (keep angle between 0 and 360)             |
                a = a MOD 360 '             | yes, get remainder of modulus angle and 360                    |
                IF a < 0 THEN a = a + 360 ' | add 360 if less than 0                                         |
            END IF '                        +----------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Create the four vector points for the rotation matrix                                         |
            '| =====================================================                                         |
            '| Move coordinate 0,0 to the center of the image.                                               |
            '+-------------------+                                                                           |
            w = _WIDTH(c) '      | width of image to rotate                                                  |
            h = _HEIGHT(c) '     | height of image to rotate          -x,-y +-----------------+ x,-y         |
            px(0) = -w * .5 '    |                              px(0),py(0) |                 | px(3),py(3)  |
            py(0) = -h * .5 '    | Create points around (0,0)               |                 |              |
            px(1) = px(0) '      | that match the size of the               |        .        |              |
            py(1) = h * .5 - 1 ' | original image. This                     |       0,0       |              |
            px(2) = w * .5 - 1 ' | creates four vector                      |                 |              |
            py(2) = py(1) '      | quantities to work with.     px(1),py(1) |                 | px(2),py(2)  |
            px(3) = px(2) '      |                                     -x,y +-----------------+ x,y          |
            py(3) = py(0) '      |                                                                           |
            '                    +---------------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Perform rotation matrix ( https://en.wikipedia.org/wiki/Rotation_matrix )                     |
            '| =======================                                                                       |
            '+--------------------------------+                                                              |
            sr = SIN(_D2R(-a)) '              | sine and cosine calculations for rotation matrix             |
            cr = COS(_D2R(-a)) '              | degrees converted to radian, -Degree = clockwise rotation    |
            DO '                              | cycle through vectors                                        |
                x = px(v) * cr + sr * py(v) ' | perform 2D rotation matrix on vector                         |
                y = py(v) * cr - px(v) * sr ' | (see wikipedia link above for more information)              |
                px(v) = x '                   | save new x vector                                            |
                py(v) = y '                   | save new y vector                                            |
                IF px(v) < l THEN l = px(v) ' | record left most coordinate seen                             |
                IF px(v) > r THEN r = px(v) ' | record right most coordinate seen                            |
                IF py(v) < t THEN t = py(v) ' | record top most coordinate seen                              |
                IF py(v) > b THEN b = py(v) ' | record bottom most coordinate seen                           |
                v = v + 1 '                   | increment vector counter                                     |
            LOOP UNTIL v = 4 '                | leave when all vectors processed                             |
            '                                 +--------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Make coordinate 0,0 the upper left corner                                                     |
            '| =========================================                                                     |
            '| Move coordinate 0,0 back the upper left corner of the image.                                  |
            '+--------------------------+                                                                    |
            rw = r - l + 1 '            | calculate width of rotated image                                   |
            rh = b - t + 1 '            | calculate height of rotated image                                  |
            xo = rw * .5 '              | calculate upper left x coordinate                                  |
            yo = rh * .5 '              | calculate upper left y coordinate                                  |
            v = 0 '                     | reset corner counter                                               |
            DO '                        | cycle through rotated image coordinates                            |
                px(v) = px(v) + xo '    | adjust each vector's x coordinate                                  |
                py(v) = py(v) + yo '    | adjust each vector's y coordinate                                  |
                v = v + 1 '             | increment corner counter                                           |
            LOOP UNTIL v = 4 '          | leave when all four corners of image adjusted                      |
            '                           +--------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Create new image canvas and map image to new coordinates                                      |
            '| ========================================================                                      |
            '+--------------------------+                                                                    |
            i = _NEWIMAGE(rw, rh, 32) ' | create rotated image canvas                                        |
            _DONTBLEND i '              | turn off blending for speed                                        |
            _MAPTRIANGLE (0, 0)-(0, h - 1)-(w - 1, h - 1), c TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2)), i
            _MAPTRIANGLE (0, 0)-(w - 1, 0)-(w - 1, h - 1), c TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2)), i
            _FREEIMAGE c '              | remove temporary image                                             |
            IF bl THEN _BLEND i '       | restore blending to image                                          |
            '                           +--------------------------------------------------------------------+
            '+-----------------------------------------------------------------------------------------------+
            '| Error checking is turned back on.                                                             |
            '+-----------------------------------------------------------------------------------------------+
            $CHECKING:ON
        END IF
    END IF

END SUB
