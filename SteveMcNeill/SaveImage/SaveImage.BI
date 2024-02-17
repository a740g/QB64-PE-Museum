' Constants
CONST Z_OK = 0
CONST Z_NO_COMPRESSION = 0
CONST Z_BEST_SPEED = 1
CONST Z_BEST_COMPRESSION = 9
CONST Z_DEFAULT_COMPRESSION = -1

'These are used for PNG import and export, and are needed for the PNGCRC check
'If you only want ZLib for something else, these variables could be removed if necessary.
DIM SHARED PNGCRC_table(0 TO 255) AS _UNSIGNED LONG
DIM SHARED PNGCRC_table_computed AS LONG: PNGCRC_table_computed = 0
DIM SHARED PNGCRC AS _UNSIGNED LONG
DIM SHARED PNGOptions AS PNG_Options_Type

'I put the types and their info here at the end of the library, so that I wouldn't have to scroll past
'the stupid things a million times, just to get to my code!


TYPE ChunkType
    Ancillary AS _UNSIGNED _BYTE
    Private AS _UNSIGNED _BYTE
    Reserved AS _UNSIGNED _BYTE
    SafeToCopy AS _UNSIGNED _BYTE
END TYPE


TYPE PNGChunkLayout
    Length AS _UNSIGNED LONG 'Need to convert this number with the ConvertUL~& function
    Type AS ChunkType
END TYPE


TYPE PNGImageHeaderType
    'Can't just read width and height as _unsigned longs.
    'Must convert them to QB64 format with the ConvertUL~& function.

    Width AS _UNSIGNED LONG 'Need to convert this number with the ConvertUL~& function
    Height AS _UNSIGNED LONG 'Need to convert this number with the ConvertUL~& function
    Depth AS _UNSIGNED _BYTE
    ColorType AS _UNSIGNED _BYTE
    Compression AS _UNSIGNED _BYTE
    Filter AS _UNSIGNED _BYTE
    Interlace AS _UNSIGNED _BYTE
END TYPE

TYPE PNG_Options_Type
    Alpha AS _UNSIGNED _BYTE
    Screen AS LONG
    Color AS INTEGER
    GrabMode AS _UNSIGNED _BYTE
    x1 AS _UNSIGNED INTEGER
    y1 AS _UNSIGNED INTEGER
    x2 AS _UNSIGNED INTEGER
    y2 AS _UNSIGNED INTEGER
    AutoReset AS _UNSIGNED _BYTE
END TYPE


'****************************************************
'  End of ZLib and SMcNeill PNG Export/Import Library
'****************************************************

'****************************************************
'  Start of JPG Export Library
'****************************************************

TYPE JPEGState
    FileNo AS INTEGER
    YCount AS INTEGER
    CbCount AS INTEGER
    CrCount AS INTEGER
    YDC AS INTEGER
    CbDC AS INTEGER
    CrDC AS INTEGER
    Position AS INTEGER
    Leftover AS INTEGER
    LeftoverBits AS INTEGER
END TYPE

Huff0:
DATA 0
DATA 1,0
DATA 5,1,2,3,4,5
DATA 1,6
DATA 1,7
DATA 1,8
DATA 1,9
DATA 1,10
DATA 1,11
DATA 0,0,0,0,0,0,0

Huff1:
DATA 0
DATA 3,0,1,2
DATA 1,3
DATA 1,4
DATA 1,5
DATA 1,6
DATA 1,7
DATA 1,8
DATA 1,9
DATA 1,10
DATA 1,11
DATA 0,0,0,0,0

Huff2:
DATA 0
DATA 2,1,2
DATA 1,3
DATA 3,0,4,&H11
DATA 3,5,&H12,&H21
DATA 2,&H31,&H41
DATA 4,6,&H13,&H51,&H61
DATA 3,7,&H22,&H71
DATA 5,&H14,&H32,&H81,&H91,&HA1
DATA 5,&H08,&H23,&H42,&HB1,&HC1
DATA 4,&H15,&H52,&HD1,&HF0
DATA 4,&H24,&H33,&H62,&H72
DATA 0
DATA 0
DATA 1,&H82
DATA 125,&H09,&H0A,&H16,&H17,&H18,&H19,&H1A,&H25,&H26,&H27,&H28,&H29,&H2A,&H34,&H35,&H36
DATA &H37,&H38,&H39,&H3A,&H43,&H44,&H45,&H46,&H47,&H48,&H49,&H4A,&H53,&H54,&H55,&H56
DATA &H57,&H58,&H59,&H5A,&H63,&H64,&H65,&H66,&H67,&H68,&H69,&H6A,&H73,&H74,&H75,&H76
DATA &H77,&H78,&H79,&H7A,&H83,&H84,&H85,&H86,&H87,&H88,&H89,&H8A,&H92,&H93,&H94,&H95
DATA &H96,&H97,&H98,&H99,&H9A,&HA2,&HA3,&HA4,&HA5,&HA6,&HA7,&HA8,&HA9,&HAA,&HB2,&HB3
DATA &HB4,&HB5,&HB6,&HB7,&HB8,&HB9,&HBA,&HC2,&HC3,&HC4,&HC5,&HC6,&HC7,&HC8,&HC9,&HCA
DATA &HD2,&HD3,&HD4,&HD5,&HD6,&HD7,&HD8,&HD9,&HDA,&HE1,&HE2,&HE3,&HE4,&HE5,&HE6,&HE7
DATA &HE8,&HE9,&HEA,&HF1,&HF2,&HF3,&HF4,&HF5,&HF6,&HF7,&HF8,&HF9,&HFA

Huff3:
DATA 0
DATA 2,0,1
DATA 1,2
DATA 2,3,&H11
DATA 4,4,5,&H21,&H31
DATA 4,6,&H12,&H41,&H51
DATA 3,7,&H61,&H71
DATA 4,&H13,&H22,&H32,&H81
DATA 7,8,&H14,&H42,&H91,&HA1,&HB1,&HC1
DATA 5,9,&H23,&H33,&H52,&HF0
DATA 4,&H15,&H62,&H72,&HD1
DATA 4,&HA,&H16,&H24,&H34
DATA 0
DATA 1,&HE1
DATA 2,&H25,&HF1
DATA 119,&H17,&H18,&H19,&H1A,&H26,&H27,&H28,&H29,&H2A,&H35,&H36,&H37,&H38,&H39,&H3A,&H43
DATA &H44,&H45,&H46,&H47,&H48,&H49,&H4A,&H53,&H54,&H55,&H56,&H57,&H58,&H59,&H5A,&H63
DATA &H64,&H65,&H66,&H67,&H68,&H69,&H6A,&H73,&H74,&H75,&H76,&H77,&H78,&H79,&H7A,&H82
DATA &H83,&H84,&H85,&H86,&H87,&H88,&H89,&H8A,&H92,&H93,&H94,&H95,&H96,&H97,&H98,&H99
DATA &H9A,&HA2,&HA3,&HA4,&HA5,&HA6,&HA7,&HA8,&HA9,&HAA,&HB2,&HB3,&HB4,&HB5,&HB6,&HB7
DATA &HB8,&HB9,&HBA,&HC2,&HC3,&HC4,&HC5,&HC6,&HC7,&HC8,&HC9,&HCA,&HD2,&HD3,&HD4,&HD5
DATA &HD6,&HD7,&HD8,&HD9,&HDA,&HE2,&HE3,&HE4,&HE5,&HE6,&HE7,&HE8,&HE9,&HEA,&HF2,&HF3
DATA &HF4,&HF5,&HF6,&HF7,&HF8,&HF9,&HFA

StandardQT:
DATA 16,11,10,16,24,40,51,61
DATA 12,12,14,19,26,58,60,55
DATA 14,13,16,24,40,57,69,56
DATA 14,17,22,29,51,87,80,62
DATA 18,22,37,56,68,109,103,77
DATA 24,35,55,64,81,104,113,92
DATA 49,64,78,87,103,121,120,101
DATA 72,92,95,98,112,100,103,99

DATA 17,18,24,47,99,99,99,99
DATA 18,24,26,66,99,99,99,99
DATA 24,26,56,99,99,99,99,99
DATA 47,66,99,99,99,99,99,99
DATA 99,99,99,99,99,99,99,99
DATA 99,99,99,99,99,99,99,99
DATA 99,99,99,99,99,99,99,99
DATA 99,99,99,99,99,99,99,99

DIM SHARED JPG_Library_Pow2(0 TO 15) AS LONG
DIM SHARED JPG_Library_Cosine(0 TO 7, 0 TO 7) AS SINGLE
DIM SHARED JPG_Library_ZigZagX(0 TO 63) AS INTEGER, JPG_Library_ZigZagY(0 TO 63) AS INTEGER

'JPRG Precalculations
DIM JPG_Library_X AS INTEGER, JPG_Library_Y AS INTEGER, JPG_Library_T AS INTEGER, JPG_Library_Dir AS INTEGER, JPG_Library_L AS LONG

JPG_Library_L = 1
FOR JPG_Library_X = 0 TO 15: JPG_Library_Pow2(JPG_Library_X) = JPG_Library_L: JPG_Library_L = JPG_Library_L + JPG_Library_L: NEXT
FOR JPG_Library_Y = 0 TO 7: FOR JPG_Library_X = 0 TO 7: JPG_Library_Cosine(JPG_Library_X, JPG_Library_Y) = COS((2 * JPG_Library_X + 1) * JPG_Library_Y * .1963495): NEXT JPG_Library_X, JPG_Library_Y

JPG_Library_X = 0: JPG_Library_Y = 0
JPG_Library_T = 0
JPG_Library_Dir = 0
DO
    JPG_Library_ZigZagX(JPG_Library_T) = JPG_Library_X
    JPG_Library_ZigZagY(JPG_Library_T) = JPG_Library_Y
    JPG_Library_T = JPG_Library_T + 1
    IF JPG_Library_T = 64 THEN EXIT DO
    IF JPG_Library_Dir THEN
        IF JPG_Library_Y = 7 THEN
            JPG_Library_X = JPG_Library_X + 1: JPG_Library_Dir = 0
        ELSEIF JPG_Library_X = 0 THEN
            JPG_Library_Y = JPG_Library_Y + 1: JPG_Library_Dir = 0
        ELSE
            JPG_Library_X = JPG_Library_X - 1: JPG_Library_Y = JPG_Library_Y + 1
        END IF
    ELSE
        IF JPG_Library_Y = 0 THEN
            JPG_Library_X = JPG_Library_X + 1: JPG_Library_Dir = 1
        ELSEIF JPG_Library_X = 7 THEN
            JPG_Library_Y = JPG_Library_Y + 1: JPG_Library_Dir = 1
        ELSE
            JPG_Library_X = JPG_Library_X + 1: JPG_Library_Y = JPG_Library_Y - 1
        END IF
    END IF
LOOP
'End of Precalculations

DIM SHARED JPG_Library_Huff(0 TO 255, 0 TO 1, 0 TO 1, 0 TO 1) AS INTEGER
DIM SHARED JPG_Library_QT(0 TO 7, 0 TO 7, 0 TO 1) AS INTEGER
DIM SHARED JPG_Library_State AS JPEGState

DIM SHARED JPG_Library_Sampling(0 TO 2, 0 TO 1) AS INTEGER
JPG_Library_Sampling(0, 0) = 2 'JPG_Library_Sampling factor (JPG_Library_X then JPG_Library_Y) for luminance
JPG_Library_Sampling(0, 1) = 2
JPG_Library_Sampling(1, 0) = 1 'JPG_Library_Sampling factor for "blue" chrominance
JPG_Library_Sampling(1, 1) = 1
JPG_Library_Sampling(2, 0) = 1 'JPG_Library_Sampling factor for "red" chrominance
JPG_Library_Sampling(2, 1) = 1

'*************************************
' End of SaveImage Header Library
'*************************************

