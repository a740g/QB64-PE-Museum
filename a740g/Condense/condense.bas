'-----------------------------------------------------------------------------------------------------
'
' Text file condenser
'
' Copyright (c) Samuel Gomes (a740g), 1998-2022.
' All rights reserved.
'
'-----------------------------------------------------------------------------------------------------

'-----------------------------------------------------------------------------------------------------
' These are some metacommands and compiler options for QB64 to write modern type-strict code
'-----------------------------------------------------------------------------------------------------
' This will disable prefixing all modern QB64 calls using a underscore prefix.
$NoPrefix
' Whatever indentifiers are not defined, should default to signed longs (ex. constants and functions).
DefLng A-Z
' All variables must be defined.
Option Explicit
' All arrays must be defined.
Option ExplicitArray
' Array lower bounds should always start from 1 unless explicitly specified.
' This allows a(4) as integer to have 4 members with index 1-4.
Option Base 1
' All arrays should be static by default. Allocate dynamic array using ReDim
'$Static
' For text mode programs, uncomment the three lines below.
$Console:Only
$ScreenHide
Dest Console
ConsoleTitle "Text File Condenser"
' Icon and version info stuff.
$VersionInfo:CompanyName=Samuel Gomes
$VersionInfo:FileDescription=Condense executable
$VersionInfo:InternalName=condense
$VersionInfo:LegalCopyright=Copyright (c) 1998-2022, Samuel Gomes
$VersionInfo:OriginalFilename=condense.exe
$VersionInfo:ProductName=Text File Condenser
$VersionInfo:Web=https://github.com/a740g
$VersionInfo:Comments=https://github.com/a740g
$VersionInfo:FILEVERSION#=5,0,0,1
$VersionInfo:ProductVersion=5,0,0,1
'-----------------------------------------------------------------------------------------------------

Const FALSE%% = 0
Const TRUE%% = Not FALSE

' PROGRAM ENTRY POINT

' Check the command line and then collect relevant data
If CommandCount < 1 Or ArgVPresent("?") Then
    Print
    Print "Text file condenser. Version 5.0"
    Print
    Print "Copyright (c) Samuel Gomes, 1998-2022."
    Print "All rights reserved."
    Print
    Print "https://github.com/a740g"
    Print
    Print "Usage: CONDENSE [InFile] [/B] [/C] [/X] [/S[4 | 8] [/T[4 | 8] [/K] [/?]"
    Print "    InFile          is the input file"
    Print "    /B              backups input text file"
    Print "    /C              strips invalid characters"
    Print "    /X              avoids extra text file checks"
    Print "    /S              no tab to space expansion"
    Print "    /S4             expands 1 tab to 4 spaces (default)"
    Print "    /S8             expands 1 tab to 8 spaces"
    Print "    /T              no space to tab compression"
    Print "    /T4             compresses 4 spaces to 1 tab (default)"
    Print "    /T8             compresses 8 spaces to 1 tab"
    Print "    /K              performs a text file check only"
    Print "    /?              shows this help message"
    System 0
End If

Dim sTextFile As String
Dim lTextFileSizeOld As Integer64, lTextFileSizeNew As Integer64

' Change to the directory specified by the environment
ChDir StartDir$

' Resolve the input file name
sTextFile = Command$(1)

' Check if input file is present
If Not FileExists(sTextFile) Then
    Print sTextFile; " does not exist! Specify a valid name."
    System 1
End If

' Perform solitary text file check if specified
If ArgVPresent("K") Then
    If IsTextFile(sTextFile) Then
        Print sTextFile; " is a text file."
    End If

    System 0
End If

' Note original file size
lTextFileSizeOld = FileLen(sTextFile)

' Backup input file if specified
If ArgVPresent("B") Then
    If Not FileCopy(sTextFile, sTextFile + ".bak") Then
        Print "Backup failed to "; sTextFile + ".bak"
        System 1
    End If
End If

' Check text file
If Not ArgVPresent("C") And Not ArgVPresent("X") Then
    If Not IsTextFile(sTextFile) Then
        Print sTextFile; " is not a text file!"
        System 1
    End If
End If

' Strip invalid characters
If ArgVPresent("C") Then
    TextClean sTextFile
End If

' Expand tabs to spaces
If ArgVPresent("S8") Then
    TextTabExpand sTextFile, 8
ElseIf ArgVPresent("S") Then
    ' no expansion
Else
    TextTabExpand sTextFile, 4
End If

' Condense it
TextCondense sTextFile

' Compress spaces to tabs
If ArgVPresent("T8") Then
    TextSpaceCompress sTextFile, 8
ElseIf ArgVPresent("T") Then
    ' no compression
Else
    TextSpaceCompress sTextFile, 4
End If

' Get new file size
lTextFileSizeNew = FileLen(sTextFile)

' Print some statistics
Print
Print "Original size:"; lTextFileSizeOld; "bytes"
Print "Current size:"; lTextFileSizeNew; "bytes"
Print "Condensation: "; Trim$(Str$(100 - Int(100 * (lTextFileSizeNew / lTextFileSizeOld)))); "%"

System 0

' Generates a temporary filename. Returns a unique name
Function TempFile$ ()
    Do
        TempFile = Dir$("temp") + Str$(Fix(Timer)) + ".tmp"
    Loop While FileExists(TempFile)
End Function

' Returns the length of a file in bytes
Function FileLen&& (fileName As String)
    Dim As Long ff

    FileLen = -1

    If FileExists(fileName) Then
        ff = FreeFile
        Open fileName For Binary As ff

        FileLen = LOF(ff)

        Close ff
    End If
End Function

' Copies file src to dst. Src file must exist and dst file must not
Function FileCopy%% (fileSrc As String, fileDst As String)
    Dim As Long ffs, ffd
    Dim ffbc As String

    ' By default we assume failure
    FileCopy = FALSE

    ' Check if source file exists
    If FileExists(fileSrc) Then
        ' Check if dest file exists
        If FileExists(fileDst) Then
            Exit Function
        End If

        ffs = FreeFile
        Open fileSrc For Binary Access Read As ffs
        ffd = FreeFile
        Open fileDst For Binary Access Write As ffd

        ' Load the whole file into memory
        ffbc = Input$(LOF(ffs), ffs)
        ' Write the buffer to the new file
        Put ffd, , ffbc

        Close ffs
        Close ffd

        ' Success
        FileCopy = TRUE
    End If
End Function

' Check if an atgument is present in the command line
Function ArgVPresent%% (argv As String)
    Dim argc As Integer
    Dim As String a, b

    argc = 1
    b = UCase$(argv)
    Do
        a = UCase$(Command$(argc))
        If Len(a) = 0 Then Exit Do

        If a = "/" + b Or a = "-" + b Then
            ArgVPresent = TRUE
            Exit Function
        End If

        argc = argc + 1
    Loop

    ArgVPresent = FALSE
End Function

' Performs extra text check
Function IsTextFile% (sFileName As String)
    Dim sBuffer As String, sChar As Integer
    Dim lLastPos As Integer64, i As Integer
    Dim iTHandle As Long, iBytesRead As Integer

    iTHandle = FreeFile

    If Not FileExists(sFileName) Then
        IsTextFile = FALSE
        Exit Function
    End If

    Open sFileName For Binary Access Read As iTHandle

    sBuffer = Space$(16384)

    Print "Scanning "; sFileName; " ..."
    While Not EOF(iTHandle)
        ' Read from source, noting the number of bytes read
        lLastPos = Loc(iTHandle)
        Get #iTHandle, , sBuffer
        iBytesRead = Loc(iTHandle) - lLastPos

        Locate , 1
        Print Using "###% completed."; 100&& * Loc(iTHandle) \ LOF(iTHandle);

        ' Resize buffer to the number of bytes read from source
        sBuffer = Left$(sBuffer, iBytesRead)

        ' Test the content
        For i = 1 To iBytesRead
            sChar = Asc(Mid$(sBuffer, i, 1))
            If sChar < 32 And sChar <> 9 And sChar <> 10 And sChar <> 13 Then
                Locate , 1
                Print sFileName; " is not a text file!"
                IsTextFile = FALSE
                Close iTHandle
                Exit Function
            End If
        Next
    Wend
    Locate , 1
    Print "Finished scanning."

    IsTextFile = TRUE
    Close iTHandle
End Function

' Cleans text file
Sub TextClean (sFileName As String)
    Dim sBuffer1 As String, sBuffer2 As String
    Dim lLastPos As Integer64, iHandleD As Integer
    Dim sTempFile As String, iHandleS As Integer
    Dim iBytesRead As Integer, i As Integer
    Dim sChar As Integer

    sTempFile = TempFile

    ' Check if source file is present
    ' If not then this causes a user trapable error
    iHandleS = FreeFile
    Open sFileName For Input As iHandleS
    Close iHandleS

    ' Reopen it for the real job
    Open sFileName For Binary As iHandleS

    ' Overwrite distination file
    iHandleD = FreeFile
    Open sTempFile For Output As iHandleD
    Close iHandleD

    ' Reopen it for the real job
    Open sTempFile For Binary As iHandleD

    ' Allocate buffer memory
    sBuffer1 = Space$(16384)

    ' Start copying the file
    Print "Removing invalid characters from "; sFileName; " ..."
    While Not EOF(iHandleS)
        ' Read from source, noting the number of bytes read
        lLastPos = Loc(iHandleS)
        Get #iHandleS, , sBuffer1
        iBytesRead = Loc(iHandleS) - lLastPos

        Locate , 1
        Print Using "###% completed."; 100&& * Loc(iHandleS) \ LOF(iHandleS);

        ' Resize buffer to the number of bytes read from source
        sBuffer1 = Left$(sBuffer1, iBytesRead)

        ' Remove crap
        sBuffer2 = ""
        For i = 1 To iBytesRead
            sChar = Asc(Mid$(sBuffer1, i, 1))
            Select Case sChar
                Case Is = 9, Is = 10, Is = 13
                    sBuffer2 = sBuffer2 + Chr$(sChar)
                Case Is < 32
                    ' do nothing
                Case Else
                    sBuffer2 = sBuffer2 + Chr$(sChar)
            End Select
        Next

        ' Write the buffer content to the destination file
        Put #iHandleD, , sBuffer2
    Wend
    Locate , 1
    Print "Finished removing invalid characters."

    Close iHandleS, iHandleD

    Kill sFileName
    If Not FileCopy(sTempFile, sFileName) Then
        Name sTempFile As sFileName
    Else
        Kill sTempFile
    End If
End Sub

' Condenses the source code to use minimum disk space
Sub TextCondense (sFileName As String)
    Dim sText As String, iOHandle As Integer
    Dim lTotalLines As Integer64, lActualLines As Integer64
    Dim sTempFile As String, iIHandle As Integer

    iIHandle = FreeFile

    ' Open file for counting the effective lines
    Open sFileName For Input As iIHandle

    Print "Scanning "; sFileName; " ..."
    Do While Not EOF(iIHandle)
        Line Input #iIHandle, sText
        lTotalLines = lTotalLines + 1
        If Trim$(sText) <> "" Then lActualLines = lTotalLines
        Locate , 1
        Print Using "###% completed."; 128&& * 100&& * Loc(iIHandle) \ LOF(iIHandle);
    Loop
    Locate , 1
    Print "Finished scanning."

    Close iIHandle

    ' Open file for the actual condensation
    Open sFileName For Input As iIHandle

    iOHandle = FreeFile
    sTempFile = TempFile
    Open sTempFile For Output As iOHandle

    Print "Condensing "; sFileName; " ..."
    For lTotalLines = 1 To lActualLines
        Line Input #iIHandle, sText
        Print #iOHandle, RTrim$(sText)
        Locate , 1
        Print Using "###% completed."; 100&& * lTotalLines \ lActualLines;
    Next
    Locate , 1
    Print "Finished condensing."

    Close iIHandle, iOHandle

    Kill sFileName
    If Not FileCopy(sTempFile, sFileName) Then
        Name sTempFile As sFileName
    Else
        Kill sTempFile
    End If
End Sub

' Tabifies a text file
Sub TextSpaceCompress (sFileName As String, iLen As Integer)
    Dim sIText As String, iOHandle As Integer
    Dim sTempFile As String, iIHandle As Integer
    Dim sOText As String, i As Integer, j As Integer, sStr As String

    ' Open file for compressing spaces
    iIHandle = FreeFile
    Open sFileName For Input As iIHandle

    iOHandle = FreeFile
    sTempFile = TempFile
    Open sTempFile For Output As iOHandle

    Print "Compressing spaces to tabs ("; Trim$(Str$(iLen)); ":1) in "; sFileName; " ..."
    Do While Not EOF(iIHandle)
        Line Input #iIHandle, sIText

        sOText = ""
        j = Len(sIText)
        For i = 1 To (j - iLen + 1) Step iLen
            sStr = Mid$(sIText, i, iLen)
            If sStr = Space$(iLen) Then
                sOText = sOText + Chr$(9)
            Else
                sOText = sOText + sStr
            End If
        Next

        ' Copy the remaining characters
        sOText = sOText + Right$(sIText, j Mod iLen)

        Print #iOHandle, sOText

        Locate , 1
        Print Using "###% completed."; 128&& * 100&& * Loc(iIHandle) \ LOF(iIHandle);
    Loop
    Locate , 1
    Print "Finished compressing spaces to tabs."

    Close iIHandle, iOHandle

    Kill sFileName
    If Not FileCopy(sTempFile, sFileName) Then
        Name sTempFile As sFileName
    Else
        Kill sTempFile
    End If
End Sub

' Expands tabs to spaces
Sub TextTabExpand (sFileName As String, iLen As Integer)
    Dim sBuffer1 As String, sBuffer2 As String
    Dim lLastPos As Integer64, iHandleD As Integer
    Dim sTempFile As String, iHandleS As Integer
    Dim iBytesRead As Integer, i As Integer
    Dim sChar As String * 1

    sTempFile = TempFile

    ' Check if source file is present
    ' If not then this causes a user trapable error
    iHandleS = FreeFile
    Open sFileName For Input As iHandleS
    Close iHandleS

    ' Reopen it for the real job
    Open sFileName For Binary As iHandleS

    ' Overwrite distination file
    iHandleD = FreeFile
    Open sTempFile For Output As iHandleD
    Close iHandleD

    ' Reopen it for the real job
    Open sTempFile For Binary As iHandleD

    ' Allocate buffer memory
    sBuffer1 = Space$(16384)

    ' Start copying the file
    Print "Expanding tabs to spaces (1:"; Trim$(Str$(iLen)); ") in "; sFileName; " ..."
    While Not EOF(iHandleS)
        ' Read from source, noting the number of bytes read
        lLastPos = Loc(iHandleS)
        Get #iHandleS, , sBuffer1
        iBytesRead = Loc(iHandleS) - lLastPos

        Locate , 1
        Print Using "###% completed."; 100&& * Loc(iHandleS) \ LOF(iHandleS);

        ' Resize buffer to the number of bytes read from source
        sBuffer1 = Left$(sBuffer1, iBytesRead)

        ' Expand
        sBuffer2 = ""
        For i = 1 To iBytesRead
            sChar = Mid$(sBuffer1, i, 1)
            If sChar = Chr$(9) Then
                sBuffer2 = sBuffer2 + Space$(iLen)
            Else
                sBuffer2 = sBuffer2 + sChar
            End If
        Next

        ' Write the buffer content to the destination file
        Put #iHandleD, , sBuffer2
    Wend
    Locate , 1
    Print "Finished expanding tabs to spaces."

    Close iHandleS, iHandleD

    Kill sFileName
    If Not FileCopy(sTempFile, sFileName) Then
        Name sTempFile As sFileName
    Else
        Kill sTempFile
    End If
End Sub

