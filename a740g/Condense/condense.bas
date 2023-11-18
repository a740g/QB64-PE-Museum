'-----------------------------------------------------------------------------------------------------
'
' Text file condenser
'
' Copyright (c) Samuel Gomes (a740g), 1998-2023.
' All rights reserved.
'
'-----------------------------------------------------------------------------------------------------

'-----------------------------------------------------------------------------------------------------
' These are some metacommands and compiler options for QB64 to write modern type-strict code
'-----------------------------------------------------------------------------------------------------
$NOPREFIX
DEFLNG A-Z
OPTION EXPLICIT
OPTION EXPLICITARRAY
OPTION BASE 1
'$STATIC
$CONSOLE:ONLY
$VERSIONINFO:CompanyName='Samuel Gomes'
$VERSIONINFO:FileDescription='Condense executable'
$VERSIONINFO:InternalName='condense'
$VERSIONINFO:LegalCopyright='Copyright (c) 1998-2022, Samuel Gomes'
$VERSIONINFO:OriginalFilename='condense.exe'
$VERSIONINFO:ProductName='Text File Condenser'
$VERSIONINFO:Web='https://github.com/a740g'
$VERSIONINFO:Comments='https://github.com/a740g'
$VERSIONINFO:FILEVERSION#=5,0,0,2
$VERSIONINFO:PRODUCTVERSION#=5,0,0,2
'-----------------------------------------------------------------------------------------------------

CONSOLETITLE "Text File Condenser"

CONST FALSE = 0, TRUE = NOT FALSE

' PROGRAM ENTRY POINT

' Check the command line and then collect relevant data
IF COMMANDCOUNT < 1 OR IsArgVPresent("?") THEN
    PRINT
    PRINT "Text file condenser."
    PRINT
    PRINT "Copyright (c) Samuel Gomes, 1998-2023."
    PRINT "All rights reserved."
    PRINT
    PRINT "https://github.com/a740g"
    PRINT
    PRINT "Usage: CONDENSE [InFile] [/B] [/C] [/X] [/S[4 | 8] [/T[4 | 8] [/K] [/?]"
    PRINT "    InFile          is the input file"
    PRINT "    /B              backups input text file"
    PRINT "    /C              strips invalid characters"
    PRINT "    /X              avoids extra text file checks"
    PRINT "    /S              no tab to space expansion"
    PRINT "    /S4             expands 1 tab to 4 spaces (default)"
    PRINT "    /S8             expands 1 tab to 8 spaces"
    PRINT "    /T              no space to tab compression"
    PRINT "    /T4             compresses 4 spaces to 1 tab (default)"
    PRINT "    /T8             compresses 8 spaces to 1 tab"
    PRINT "    /K              performs a text file check only"
    PRINT "    /O              overwrite backup if it exists"
    PRINT "    /?              shows this help message"
    SYSTEM
END IF

DIM sTextFile AS STRING
DIM lTextFileSizeOld AS INTEGER64, lTextFileSizeNew AS INTEGER64

' Change to the directory specified by the environment
CHDIR STARTDIR$

' Resolve the input file name
sTextFile = COMMAND$(1)

' Check if input file is present
IF NOT FILEEXISTS(sTextFile) THEN
    PRINT sTextFile; " does not exist! Specify a valid name."
    SYSTEM 1
END IF

' Perform solitary text file check if specified
IF IsArgVPresent("K") THEN
    IF IsTextFile(sTextFile) THEN
        PRINT sTextFile; " is a text file."
    END IF

    SYSTEM
END IF

' Note original file size
lTextFileSizeOld = GetFileSize(sTextFile)

' Backup input file if specified
IF IsArgVPresent("B") THEN
    IF NOT CopyFile(sTextFile, sTextFile + ".bak", IsArgVPresent("O")) THEN
        PRINT "Backup failed to "; sTextFile + ".bak"
        SYSTEM 1
    END IF
END IF

' Check text file
IF NOT IsArgVPresent("C") AND NOT IsArgVPresent("X") THEN
    IF NOT IsTextFile(sTextFile) THEN SYSTEM 1
END IF

' Strip invalid characters
IF IsArgVPresent("C") THEN
    CleanText sTextFile
END IF

' Expand tabs to spaces
IF NOT IsArgVPresent("S") THEN
    IF IsArgVPresent("S8") THEN
        ExpandTextTab sTextFile, 8
    ELSEIF IsArgVPresent("S4") THEN
        ExpandTextTab sTextFile, 4
    END IF
END IF

' Condense it
CondenseText sTextFile

' Compress spaces to tabs
IF NOT IsArgVPresent("T") THEN
    IF IsArgVPresent("T8") THEN
        CompressTextSpace sTextFile, 8
    ELSEIF IsArgVPresent("T4") THEN
        CompressTextSpace sTextFile, 4
    END IF
END IF

' Get new file size
lTextFileSizeNew = GetFileSize(sTextFile)

' Print some statistics
PRINT
PRINT "Original size:"; lTextFileSizeOld; "bytes"
PRINT "Current size:"; lTextFileSizeNew; "bytes"
PRINT "Condensation: "; TRIM$(STR$(100 - INT(100 * (lTextFileSizeNew / lTextFileSizeOld)))); "%"

SYSTEM


' Performs extra text check
FUNCTION IsTextFile% (sFileName AS STRING)
    PRINT "Scanning "; sFileName; " ..."

    DIM sBuffer AS STRING: sBuffer = LoadFile(sFileName)

    DIM i AS UNSIGNED LONG: FOR i = 1 TO LEN(sBuffer)
        IF i MOD 4096 = 0 THEN
            LOCATE , 1
            PRINT USING "###% completed."; 100&& * i \ LEN(sBuffer);
        END IF

        DIM sChar AS UNSIGNED BYTE: sChar = ASC(sBuffer, i)
        IF sChar < 32 AND sChar <> 9 AND sChar <> 10 AND sChar <> 13 THEN
            LOCATE , 1
            PRINT sFileName; " is not a text file!"
            EXIT FUNCTION
        END IF
    NEXT i

    LOCATE , 1
    PRINT "Finished scanning."

    IsTextFile = TRUE
END FUNCTION


' Cleans text file
SUB CleanText (sFileName AS STRING)
    PRINT "Removing invalid characters from "; sFileName; " ..."

    DIM sBuffer AS STRING: sBuffer = LoadFile(sFileName)

    DIM i AS UNSIGNED LONG: FOR i = 1 TO LEN(sBuffer)
        IF i MOD 4096 = 0 THEN
            LOCATE , 1
            PRINT USING "###% completed."; 100&& * i \ LEN(sBuffer);
        END IF

        DIM c AS _UNSIGNED _BYTE: c = ASC(sBuffer, i)

        IF c >= 32 OR c = 9 OR c = 10 OR c = 13 THEN
            DIM j AS LONG: j = j + 1
            ASC(sBuffer, j) = c
        END IF
    NEXT i

    sBuffer = LEFT$(sBuffer, j)

    LOCATE , 1

    IF SaveFile(sBuffer, sFileName, TRUE) THEN
        PRINT "Finished removing invalid characters."
    ELSE
        PRINT "Failed!"
    END IF
END SUB


' Condenses the source code to use minimum disk space
SUB CondenseText (sFileName AS STRING)
    DIM sText AS STRING, iOHandle AS INTEGER
    DIM lTotalLines AS INTEGER64, lActualLines AS INTEGER64
    DIM sTempFile AS STRING, iIHandle AS INTEGER

    iIHandle = FREEFILE

    ' Open file for counting the effective lines
    OPEN sFileName FOR INPUT AS iIHandle

    PRINT "Scanning "; sFileName; " ..."
    DO WHILE NOT EOF(iIHandle)
        LINE INPUT #iIHandle, sText
        lTotalLines = lTotalLines + 1
        IF TRIM$(sText) <> "" THEN lActualLines = lTotalLines
        LOCATE , 1
        PRINT USING "###% completed."; 128&& * 100&& * LOC(iIHandle) \ LOF(iIHandle);
    LOOP
    LOCATE , 1
    PRINT "Finished scanning."

    CLOSE iIHandle

    ' Open file for the actual condensation
    OPEN sFileName FOR INPUT AS iIHandle

    iOHandle = FREEFILE
    sTempFile = GetTempFileName
    OPEN sTempFile FOR OUTPUT AS iOHandle

    PRINT "Condensing "; sFileName; " ..."
    FOR lTotalLines = 1 TO lActualLines
        LINE INPUT #iIHandle, sText
        PRINT #iOHandle, RTRIM$(sText)
        LOCATE , 1
        PRINT USING "###% completed."; 100&& * lTotalLines \ lActualLines;
    NEXT
    LOCATE , 1
    PRINT "Finished condensing."

    CLOSE iIHandle, iOHandle

    IF NOT CopyFile(sTempFile, sFileName, TRUE) THEN
        NAME sTempFile AS sFileName
    ELSE
        KILL sTempFile
    END IF
END SUB


' Tabifies a text file
SUB CompressTextSpace (sFileName AS STRING, iLen AS INTEGER)
    DIM sIText AS STRING, iOHandle AS INTEGER
    DIM sTempFile AS STRING, iIHandle AS INTEGER
    DIM sOText AS STRING, i AS INTEGER, j AS INTEGER, sStr AS STRING

    ' Open file for compressing spaces
    iIHandle = FREEFILE
    OPEN sFileName FOR INPUT AS iIHandle

    iOHandle = FREEFILE
    sTempFile = GetTempFileName
    OPEN sTempFile FOR OUTPUT AS iOHandle

    PRINT "Compressing spaces to tabs ("; TRIM$(STR$(iLen)); ":1) in "; sFileName; " ..."
    DO WHILE NOT EOF(iIHandle)
        LINE INPUT #iIHandle, sIText

        sOText = ""
        j = LEN(sIText)
        FOR i = 1 TO (j - iLen + 1) STEP iLen
            sStr = MID$(sIText, i, iLen)
            IF sStr = SPACE$(iLen) THEN
                sOText = sOText + CHR$(9)
            ELSE
                sOText = sOText + sStr
            END IF
        NEXT

        ' Copy the remaining characters
        sOText = sOText + RIGHT$(sIText, j MOD iLen)

        PRINT #iOHandle, sOText

        LOCATE , 1
        PRINT USING "###% completed."; 128&& * 100&& * LOC(iIHandle) \ LOF(iIHandle);
    LOOP
    LOCATE , 1
    PRINT "Finished compressing spaces to tabs."

    CLOSE iIHandle, iOHandle

    IF NOT CopyFile(sTempFile, sFileName, TRUE) THEN
        NAME sTempFile AS sFileName
    ELSE
        KILL sTempFile
    END IF
END SUB


' Expands tabs to spaces
SUB ExpandTextTab (sFileName AS STRING, iLen AS INTEGER)
    DIM sBuffer1 AS STRING, sBuffer2 AS STRING
    DIM lLastPos AS INTEGER64, iHandleD AS INTEGER
    DIM sTempFile AS STRING, iHandleS AS INTEGER
    DIM iBytesRead AS INTEGER, i AS INTEGER
    DIM sChar AS STRING * 1

    sTempFile = GetTempFileName

    ' Check if source file is present
    ' If not then this causes a user trapable error
    iHandleS = FREEFILE
    OPEN sFileName FOR INPUT AS iHandleS
    CLOSE iHandleS

    ' Reopen it for the real job
    OPEN sFileName FOR BINARY AS iHandleS

    ' Overwrite distination file
    iHandleD = FREEFILE
    OPEN sTempFile FOR OUTPUT AS iHandleD
    CLOSE iHandleD

    ' Reopen it for the real job
    OPEN sTempFile FOR BINARY AS iHandleD

    ' Allocate buffer memory
    sBuffer1 = SPACE$(16384)

    ' Start copying the file
    PRINT "Expanding tabs to spaces (1:"; TRIM$(STR$(iLen)); ") in "; sFileName; " ..."
    WHILE NOT EOF(iHandleS)
        ' Read from source, noting the number of bytes read
        lLastPos = LOC(iHandleS)
        GET #iHandleS, , sBuffer1
        iBytesRead = LOC(iHandleS) - lLastPos

        LOCATE , 1
        PRINT USING "###% completed."; 100&& * LOC(iHandleS) \ LOF(iHandleS);

        ' Resize buffer to the number of bytes read from source
        sBuffer1 = LEFT$(sBuffer1, iBytesRead)

        ' Expand
        sBuffer2 = ""
        FOR i = 1 TO iBytesRead
            sChar = MID$(sBuffer1, i, 1)
            IF sChar = CHR$(9) THEN
                sBuffer2 = sBuffer2 + SPACE$(iLen)
            ELSE
                sBuffer2 = sBuffer2 + sChar
            END IF
        NEXT

        ' Write the buffer content to the destination file
        PUT #iHandleD, , sBuffer2
    WEND
    LOCATE , 1
    PRINT "Finished expanding tabs to spaces."

    CLOSE iHandleS, iHandleD

    IF NOT CopyFile(sTempFile, sFileName, TRUE) THEN
        NAME sTempFile AS sFileName
    ELSE
        KILL sTempFile
    END IF
END SUB


' Generates a temporary filename. Returns a unique name
FUNCTION GetTempFileName$
    DO
        DIM sName AS STRING: sName = DIR$("temp") + STR$(FIX(TIMER)) + ".tmp"
    LOOP WHILE FILEEXISTS(sName)

    GetTempFileName = sName
END FUNCTION


' Returns the length of a file in bytes
FUNCTION GetFileSize&& (fileName AS STRING)
    GetFileSize = -1

    IF FILEEXISTS(fileName) THEN
        DIM AS LONG ff: ff = FREEFILE
        OPEN fileName FOR BINARY AS ff
        GetFileSize = LOF(ff)
        CLOSE ff
    END IF
END FUNCTION


' Loads a whole file from disk into a string buffer
FUNCTION LoadFile$ (path AS STRING)
    IF _FILEEXISTS(path) THEN
        DIM AS LONG fh: fh = FREEFILE
        OPEN path FOR BINARY ACCESS READ AS fh
        LoadFile = INPUT$(LOF(fh), fh)
        CLOSE fh
    END IF
END FUNCTION


' Saves a string buffer to a file
FUNCTION SaveFile%% (buffer AS STRING, fileName AS STRING, overwrite AS _BYTE)
    IF _FILEEXISTS(fileName) AND NOT overwrite THEN EXIT FUNCTION

    DIM fh AS LONG: fh = FREEFILE
    OPEN fileName FOR OUTPUT AS fh ' open file in text mode to wipe out the file if it exists
    PRINT #fh, buffer; ' write the buffer to the file (works regardless of the file being opened in text mode)
    CLOSE fh

    SaveFile = TRUE
END FUNCTION


' Copies file src to dst. Src file must exist and dst file must not
FUNCTION CopyFile%% (fileSrc AS STRING, fileDst AS STRING, overwrite AS _BYTE)
    CopyFile = SaveFile(LoadFile(fileSrc), fileDst, overwrite)
END FUNCTION


' Returns true if a comamnd line argument is present
FUNCTION IsArgVPresent%% (argv AS STRING)
    DIM argc AS LONG: argc = 1
    DIM b AS STRING: b = UCASE$(argv)

    DO
        DIM a AS STRING: a = UCASE$(COMMAND$(argc))
        IF LEN(a) = 0 THEN EXIT DO

        IF a = "/" + b OR a = "-" + b THEN
            IsArgVPresent = TRUE
            EXIT FUNCTION
        END IF

        argc = argc + 1
    LOOP
END FUNCTION
