' BACH.BAS Copyright (c) 1987 by Unique Software
' Ported from TANDY 1000 Advanced BASIC to QB64-PE by a740g

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

_TITLE "Trio Sonata No. 1 in E-Flat Allegro"

RESTORE data_bach_bmp
$RESIZE:SMOOTH
SCREEN _LOADIMAGE(Base64_LoadResourceData, 256, "memory, adaptive")

DIM m(0 TO 2) AS STRING

RESTORE data_bach_mml
DO
    READ m(0), m(1), m(2)
    PLAY m(0), m(1), m(2)
LOOP WHILE LEN(m(0)) _ANDALSO LEN(m(1)) _ANDALSO LEN(m(2))

DIM c AS _UNSIGNED LONG

WHILE PLAY(0) > 0 _ORELSE PLAY(1) > 0 _ORELSE PLAY(2) > 0
    c = _PALETTECOLOR(1)
    _PALETTECOLOR 1, _PALETTECOLOR(2)
    _PALETTECOLOR 2, _PALETTECOLOR(3)
    _PALETTECOLOR 3, c

    _LIMIT 10
WEND

SLEEP 1

SYSTEM

data_bach_mml:
DATA "mb","mb","mb"
DATA "v12 t120 o3 e-8 >e-8","v12 t120 o2 p4","v12 t120 o2 e-4"
DATA "o4 <f8 >e-8","o2 p4","o2 e-4"
DATA "o4 <g8 >e-8","o2 p4","o2 p4"
DATA "o4 <a-8 >e-8","o2 p4","o2 c4"
DATA "o4 <b-8 >e-8","o2 p4","o2 c4"
DATA "o4 c8 e-8","o2 p4","o2 p4"
DATA "o4 <b-16 >e-16 d16 c16","o2 p4","o1 g4"
DATA "o4 <b-16 >g16 f16 e-16","o2 p4","o1 a-4"
DATA "o4 d16 c16 <b-16 a-16","o2 p4","o1 b-4"
DATA "o3 g16 a-16 b-16 g16","o2 p4","o1 e-4"
DATA "o3 e-16 g16 b-16 >e-16","o2 p4","o1 g4"
DATA "o4 <f16 a16 >c16 e-16","o2 p4","o1 a4"
DATA "o4 d16 c16 d16 f16","o2 b-8 >b-8","o1 b-4"
DATA "o4 e-16 d16 e-16 g16","o3 c8 b-8","o1 b-4"
DATA "o4 f16 e-16 f16 a-16","o3 d8 b-8","o1 p4"
DATA "o4 g16 f16 g16 b-16","o3 e-8 b-8","o1 b-4"
DATA "o4 d16 c16 d16 b-16","o3 f8 b-8","o1 b-4"
DATA "o4 e-16 d16 e-16 b-16","o3 g8 b-8","o1 p4"
DATA "o4 d8 f8","o3 f16 b-16 a16 g16","o1 b-4"
DATA "o4 b-8 d8","o3 f16 >d16 c16 <b-16","o1 >d4"
DATA "o4 c8 a8","o3 a16 g16 f16 e-16","o2 f4"
DATA "o4 b-8 d8","o3 d16 e-16 f16 d16","o2 b-4"
DATA "o4 f8 d8","o3 <b-16 >d16 f16 b-16","o2 b-4"
DATA "o4 <b-8 >d8","o3 d16 f16 a-16 b-16","o2 p4"
DATA "o4 e-8 p8","o3 g16 f16 g16 b-16","o1 e-8 >e-8"
DATA "o4 e-8 p8","o3 a-16 g16 a-16 >c16","o2 <f8 >e-8"
DATA "o4 e-8 p8","o3 <b-16 a-16 b-16 >d-16","o2 <g8 >e-8"
DATA "o4 e-8 p8","o4 c16 <b-16 >c16 e-16","o2 <a-8 >e-8"
DATA "o4 e-8 p8","o4 <g16 f16 g16 >e-16","o2 <b-8 >e-8"
DATA "o4 e-8 p8","o4 <a-16 g16 a-16 >e-16","o2 c8 e-8"
DATA "o4 p16 e-16 f16 g16","o4 <g8 b-8","o2 <b-8 p8"
DATA "o4 a-16 b-16 >c16 <b-16","o3 >e-8 <g8","o1 >c8 p8"
DATA "o4 a-16 g16 f16 a-16","o3 f8 b-8","o2 d8 p8"
DATA "o4 g8 <b-8","o3 p16 e-16 f16 g16","o2 e-4"
DATA "o3 >c8 <a-8","o3 a-16 b-16 >c16 <b-16","o2 e-4"
DATA "o3 >f4","o3 a-16 g16 f16 a-16","o2 d4"
DATA "o4 p16 a-16 g16 f16","o3 g8 <b-8","o2 e-4"
DATA "o4 e-16 d16 c16 <b-16","o2 >c8 <a-8","o2 a-4"
DATA "o3 a-16 g16 a-16 >f16","o2 >f4","o2 p4"
DATA "o4 <g16 >f16 e-16 d16","o3 p16 a-16 g16 f16","o2 <b4"
DATA "o4 c16 <b-16 a-16 g16","o3 e-16 d16 c16 <b-16","o1 >c4"
DATA "o3 f4","o2 a-16 g16 a-16 >f16","o2 d4"
DATA "o3 p16 a-16 g16 f16","o3 <g16 >f16 e-16 d16","o2 <e-4"
DATA "o3 e-4","o3 c16 <b-16 a-16 g16","o1 a-4"
DATA "o3 p16 d16 e-16 f16","o2 f4","o1 a-4"
DATA "o3 <b8 >d8","o2 p16 a-16 g16 f16","o1 g4"
DATA "o3 g8 b8","o2 e-8 g8","o1 p16 >g16 f16 g16"
DATA "o3 >c8 d8","o2 a8 b8","o2 e-16 f16 d16 e-16"
DATA "o4 e-16 c16 <b16 >c16","o3 c8 p8","o2 c8 e-8"
DATA "o4 <g16 >c16 <b16 >c16","o3 p4","o2 c8 e-8"
DATA "o4 e-16 c16 <b-16 >c16","o3 p4","o2 c8 e-8"
DATA "o4 <a-8 p8","o3 p16 f16 e-16 f16","o2 <f8 >a-8"
DATA "o3 >e-8 p8","o3 c16 f16 e-16 f16","o2 <f8 >a-8"
DATA "o4 e-8 p8","o3 a-16 f16 e-16 f16","o2 <f8 >a-8"
DATA "o4 p16 <b-16 a-16 b-16","o3 d8 p8","o2 <b-8 >d8"
DATA "o3 f16 b-16 a-16 b-16","o3 a-8 p8","o2 <b-8 >d8"
DATA "o3 >d16 <b-16 a-16 b-16","o3 a-8 p8","o2 <b-8 >d8"
DATA "o3 g8 p8","o3 p16 e-16 d-16 e-16","o2 <e-8 >g8"
DATA "o3 >d-8 p8","o3 <b-16 >e-16 d-16 e-16","o2 <e-8 >g8"
DATA "o4 d-8 p8","o3 g16 e-16 d-16 e-16","o2 <e-8 g8"
DATA "o3 p16 a-16 g16 a-16","o3 c16 f16 e16 f16","o1 a-8 >c8"
DATA "o3 f16 a-16 g16 a-16","o3 c16 f16 e16 f16","o2 <a-8 >c8"
DATA "o3 >c16 <a-16 g16 a-16","o3 a-16 f16 e-16 f16","o2 <a-8 >c8"
DATA "o3 f16 b-16 a-16 b-16","o3 d8 f8","o2 <a-8 >d8"
DATA "o3 >d16 <b-16 a-16 b-16","o3 b-4","o2 <a-8 >d8"
DATA "o3 >f16 d16 c16 d16","o3 b-4","o2 <a-8 >d8"
DATA "o4 b-8 g8","o3 p16 <b-16 a-16 b-16","o2 <g8 >e-8"
DATA "o4 e-4","o2 >e-16 <b-16 a-16 b-16","o2 <g8 >e-8"
DATA "o4 e-4","o2 >g16 e-16 d16 e-16","o2 <g8 >e-8"
DATA "o4 p16 d16 c16 <b-16","o3 a16 b-16 a16 g16","o2 <f4"
DATA "o3 a16 b-16 a16 g16","o3 f16 >d16 c16 <b-16","o1 p4"
DATA "o3 f16 >e-16 d16 c16","o3 a16 g16 f16 e-16","o1 p4"
DATA "o3 b-4","o3 d16 c16 d16 f16","o1 b-8 >b-8"
DATA "o3 b-4","o3 e-16 d16 e-16 g16","o2 c8 b-8"
DATA "o3 b-4","o3 f16 e-16 f16 a-16","o2 d8 b-8"
DATA "o3 p16 a16 b-16 >e-16","o3 g16 f16 g16 b-16","o2 e-8 b-8"
DATA "o4 <b-16 a16 b-16 >d16","o3 d16 c16 d16 b-16","o2 f8 b-8"
DATA "o4 c4","o3 e-16 d16 e-16 b-16","o2 g8 b-8"
DATA "o4 p16 g16 f16 e-16","o3 d4","o2 f8 b-8"
DATA "o4 d16 b-16 a16 g16","o3 p16 >d16 c16 <b-16","o2 e-8 b-8"
DATA "o4 f16 e-16 d16 c16","o3 a16 g16 f16 e-16","o2 f8 a8"
DATA "o3 b-8 >f8","o3 d16 b-16 a16 b-16","o1 b-4"
DATA "o4 g8 f8","o3 e-16 b-16 d16 b-16","o1 p4"
DATA "o4 g8 f8","o3 e-16 b-16 c16 b-16","o1 p4"
DATA "o4 f16 b-16 a16 b-16","o3 d8 f8","o1 b-4"
DATA "o4 e-16 b-16 d16 b-16","o3 g8 f8","o1 p4"
DATA "o4 e-16 b-16 c16 b-16","o3 g8 e-8","o1 p4"
DATA "o4 d4","o3 f16 <b-16 >c16 d16","o1 p8 >f8"
DATA "o4 p16 <b-16 >c16 d16","o3 e-4","o2 g8 f8"
DATA "o4 e-16 f16 g16 a16","o3 p16 d16 e-16 c16","o2 g8 e-8"
DATA "o4 b-8 <b-8","o3 f8 d8","o2 d8 g8"
DATA "o3 >c8 p8","o3 e-8 p8","o2 e-8 p8"
DATA "o4 <a4","o3 c4","o2 f4"
DATA "o3 mlb-4","o3 mld4","o1 mlb-4"
DATA "o3 b-4","o3 d4","o1 b-4"
DATA "o3 b-4","o3 d4","o1 b-4"
DATA "","",""

data_bach_bmp:
DATA 65078,2296,-1
DATA "eNrslrV1BEEUwGR29OtwBZcacofX5FXiloy38N+8P2ZmaVnLiubkdHEDAIttOACONuAM2GCfmQuKDTpWrJdrVuP0UpbrNetxEREREfl1bCRsJWwm"
DATA "T3l9aXvYz372e5O3n/3kXdzr3I5bb/19X9p+9rOf/d7m7Wc/eR9bSds+M47U3z60n/3e5O1nP/vZ733Io+PFh7FT2yTf2i8i+GDsZ7+oNjHSrStc"
DATA "2+9VHrXro3wz/RNyqcfXXUldX0/+D/3sFwRAAAEEAUAAAQDU3w/t3QFq7DgQhOG+wX//2y7LUDyaAmOrJ5adVMHOSC0pD394skZKSKvYa1vXvD8k"
DATA "Nr+tqj76M34Hid/C+ZHDzv3+j/v1irm2uf07gFZ3P1v1mf8tv/4crW78nuTX3UoS/QpUNj/Vu093Kv8Kvd1XVfz+qJ8g9JShV9XK/JqiXv1pyJ9f"
DATA "RK5VbX6vx+9pft+MqVRrW81WnZvr9uXjO86PDja24nd2/3Tst3Z1+iR6vTz6PB5Yvdwvfsnj/eIXvz+RnB8B5PxjokcRv1EgfvH7bvjkHxBQ/VUN"
DATA "QG1Vyf0HAGp6Wr3Ki2z22x/0jl702kcOivPsPz+a+kHt99u3fzoIn7gfED+LRS7uJ6X4HYYjP9zPUOMH5X7Ax1YpvMkf95OG+YlWA3orenGr3/5I"
DATA "0P1eke37fwJb8cv+qd1+6DV+VwQr99/NiV/84pfk94+yf/+txC9+AKCOSr1gO38KLdWH+1j1qNzb0PdueMP9B+VPw/gVHBUAH/eqr2xtkKFqvMCv"
DATA "uh+oqhe/aNfvUordxz5ou6v9jRecH9FwwC5vk99bzo8EBlSxz6/M7x37p/8u/ft+ZueDfTm81u/T+ik/lAaE/2Pv9IPqftTcT1jm54Mv//wiP8Fx"
DATA "1Y/yVWAlH3S/eqOfWv0p+NgPAK3QqvH3PzWAV5wfUQVqWczvRIyIOh4EH+Yt50cUqHUYlvyOn1/mftv3T+GkXxG/Q76Fz6+v8dnA8SDv9QPo37yP"
DATA "c9LvxP5LT1lu9Uvil/OjnB9l/z6JX/ziFz9L/JJbzo+SH90/jV/84he/+KG0XllP3bLgO4d9LmhYrT6lz6zy0eeeHxmLOtbzq7HDE5vrLn7gq1Uq"
DATA "gY8++/wIsO1k72EVX47NtYaVsDF8dP/+6dTPkRTozUN0DMZFqeI3+3HBj0v3X5Xy2/xwE8Wumit+8as1vwJwPx/9O35c8VPX/Xz00edH5se1739+"
DATA "ref9/P7z0cefH5lfe3O/siA9nzv//vf0/VPzK8zPKFq63iGbIVvFRl/kpw4q2k0F+Horgj8ZI9mODGZmo+/xA0Ak6vVBjxf7XAB8eS+g+Ohz/Wh+"
DATA "jPmLGmTA9W6/epPfcfb6MfR72/mRPaosXRPs99uzfwq018Vroj35LOfkaoCn+PWs+pWWv9nvb0R88Rv4VfzWAzecH8VvcH4Uv/z8ffzi98wAL/OL"
DATA "Hwo+AMfrDidbyaIJ3rES4EpWAbj3/IgeH+LkSp9rNcv5L0CnBHyiWneeH9kPVG32w4dxyT4Vd75r/9TE1DXQBUCvWPDgg6hJX2HT1LnTzz29N/j8"
DATA "lcfmeHzopF/d7VfHfnXh+m2Busdxn+ZX5VzqWOV+P8AAl3N5MXiv+bmKJii9ssOPT+uyH8AQEDj2q3v9LsT8WPFj7McGv6+dHw39/PKBBT+BKXO/"
DATA "u/ZPAWrZr00HtP6Sn9TNrzT2PD8PwBU/8xfFoh/++ZXnr/XD8imO/AyDergfrPlhufQVBEd/c6rn+7Hih0fXenb9Gb+6028pKF/z48L65lcdgIHf"
DATA "fedHYz/jG/iZhYbND5xXxVv3nwd+/tTMyK9JgdIBfbJaKC/xsyYw9+sTHNCrWO70q1U/rfXUFUD5qbvmVxv8xs/PsOannPGrwkdctHze4/1GfOan"
DATA "Pn20t5Q20+bdd3408ePLfibQhErxUlu+6fePvudXF2J+xQIBwKafvx/4+V6JMvBT6XV+BRcddNVTwLEf2/w8AEtTpwcnxI8v+HEdg61+MHiCZnAR"
DATA "7clOq9nrt5D1DVDfKWb5H1Zv6Lfh94/oWfy/p7Ls1/o197tv/3QGOFhtCxf96iF+up9GBquL1ySUe/2S+MXviX7J3/j9IyB//8NQqoq+kYPaZ/+Y"
DATA "UvzQq/3XjeNnfsA5P3L/eboN4H4qx8/j9xa+J6uRp/rtDUXvesjfPzoI1mOvX/7+R/ziF78bEr/4JT9zfmT3Y+rX9k/jF7/4xe+oHr/4fTU5P9K7"
DATA "3Zeqp97KK36pxy9+8Ytf/IZJVp4rU1d5yS/1+MUvfvGL3yzJf4Ljix4="

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

' Loads a binary file encoded with Bin2Data
' Usage:
'   1. Encode the binary file with Bin2Data
'   2. Include the file or it's contents
'   3. Load the file like so:
'       Restore label_generated_by_bin2data
'       Dim buffer As String
'       buffer = LoadResource   ' buffer will now hold the contents of the file
FUNCTION Base64_LoadResourceData$
    DIM ogSize AS _UNSIGNED LONG, resize AS _UNSIGNED LONG, isComp AS _BYTE
    READ ogSize, resize, isComp ' read the header

    DIM buffer AS STRING: buffer = SPACE$(resize) ' preallocate complete buffer

    ' Read the whole resource data
    DIM i AS _UNSIGNED LONG: DO WHILE i < resize
        DIM chunk AS STRING: READ chunk
        MID$(buffer, i + 1) = chunk
        i = i + LEN(chunk)
    LOOP

    ' Decode the data
    buffer = Base64_Decode(buffer)

    ' Expand the data if needed
    IF isComp THEN buffer = _INFLATE$(buffer, ogSize)

    Base64_LoadResourceData = buffer
END FUNCTION
