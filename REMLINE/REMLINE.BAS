'-----------------------------------------------------------------------------------------------------
'   Microsoft RemLine - Line Number Removal Utility
'   Copyright (C) Microsoft Corporation 1985-1990
'
'   REMLINE.BAS is a program to remove line numbers from Microsoft Basic
'   Programs. It removes only those line numbers that are not the object
'   of one of the following statements: GOSUB, RETURN, GOTO, THEN, ELSE,
'   RESUME, RESTORE, or RUN.
'
'   When REMLINE is run, it will ask for the name of the file to be
'   processed and the name of the file or device to receive the
'   reformatted output. If no extension is given, .BAS is assumed (except
'   for output devices). If filenames are not given, REMLINE prompts for
'   file names. If both filenames are the same, REMLINE saves the original
'   file with the extension .BAK.
'
'   REMLINE makes several assumptions about the program:
'
'     1. It must be correct syntactically, and must run in BASICA or
'        GW-BASIC interpreter.
'     2. There is a 400 line limit. To process larger files, change
'        MaxLines constant.
'     3. The first number encountered on a line is considered a line
'        number; thus some continuation lines (in a compiler-specific
'        construction) may not be handled correctly.
'     4. REMLINE can handle simple statements that test the ERL function
'        using  relational operators such as =, <, and >. For example,
'        the following statement is handled correctly:
'
'             IF ERL = 100 THEN END
'
'        Line 100 is not removed from the source code. However, more
'        complex expressions that contain the +, -, AND, OR, XOR, EQV,
'        MOD, or IMP operators may not be handled correctly. For example,
'        in the following statement REMLINE does not recognize line 105
'        as a referenced line number and removes it from the source code:
'
'             IF ERL + 5 = 105 THEN END
'
'   If you do not like the way REMLINE formats its output, you can modify
'   the output lines in SUB GenOutFile. An example is shown in comments.
'-----------------------------------------------------------------------------------------------------

'-----------------------------------------------------------------------------------------------------
' These are some metacommands and compiler options for QB64 to write modern & type-strict code
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
' For text mode programs, uncomment the lines below.
$Console
$ScreenHide
Dest Console
ConsoleTitle "RemLine"
'-----------------------------------------------------------------------------------------------------

' Global and constant data
Const FALSE = 0, TRUE = Not FALSE
Const MaxLines = 65536

Dim Shared LineTable(MaxLines) As Long
Dim Shared LineCount As Long
Dim Shared As String Seps, InputFile, OutputFile

' Keyword search data
Const KeyWordCount = 9
Dim Shared KeyWordTable(KeyWordCount) As String

KeyData:
Data THEN,ELSE,GOSUB,GOTO,RESUME,RETURN,RESTORE,RUN,ERL,""

' Check the command line and then collect relevant data
If CommandCount < 1 Then
    Print
    Print "Microsoft RemLine: Line Number Removal Utility"
    Print "Copyright (C) Microsoft Corporation 1985-1990"
    Print
    Print "Usage: REMLINE [InFile] [OutFile]"
    Print "    InFile          is the input file"
    Print "    OutFile         is the output file"
    Print
    Print "Note:"
    Print "    - .BAS is assumed if extension is not present"
    Print "    - OutFile defaults to InFile.TMP if not present"
    System 0
End If

' Start of module-level program code
Seps = " ,:=<>()" + Chr$(9)
InitKeyTable
GetFileNames
Print "Working";
Open InputFile For Input As 1
BuildTable
Print " . . . ";
Close #1
Open InputFile For Input As 1
Open OutputFile For Output As 2
GenOutFile
Print "done!"
Close #1, #2

System 0

'
' BuildTable:
'   Examines the entire text file looking for line numbers that are
'   the object of GOTO, GOSUB, etc. As each is found, it is entered
'   into a table of line numbers. The table is used during a second
'   pass (see GenOutFile), when all line numbers not in the list
'   are removed.
' Input:
'   Uses globals KeyWordTable$, KeyWordCount, and Seps$
' Output:
'   Modifies LineTable! and LineCount
'
Sub BuildTable Static
    Dim As String InLin, ToKen
    Dim As Long KeyIndex

    Do While Not EOF(1)
        ' Get line and first token
        Line Input #1, InLin
        ToKen = GetToken$(InLin, Seps)
        Do While (ToKen <> "")
            For KeyIndex = 1 To KeyWordCount
                ' See if token is keyword
                If (KeyWordTable(KeyIndex) = UCase$(ToKen)) Then
                    ' Get possible line number after keyword
                    ToKen = GetToken$("", Seps)
                    ' Check each token to see if it is a line number
                    ' (the LOOP is necessary for the multiple numbers
                    ' of ON GOSUB or ON GOTO). A non-numeric token will
                    ' terminate search.
                    Do While (IsDigit(Left$(ToKen, 1)))
                        LineCount = LineCount + 1
                        LineTable(LineCount) = Val(ToKen)
                        ToKen = GetToken$("", Seps)
                        If ToKen <> "" Then KeyIndex = 0
                    Loop
                End If
            Next KeyIndex
            ' Get next token
            ToKen = GetToken$("", Seps)
        Loop
    Loop
End Sub

'
' GenOutFile:
'  Generates an output file with unreferenced line numbers removed.
' Input:
'  Uses globals LineTable!, LineCount, and Seps$
' Output:
'  Processed file
'
Sub GenOutFile Static
    Dim As String Sep, InLin, Token
    Dim As Long LineNumber, FoundNumber, Index

    ' Speed up by eliminating comma and colon (can't separate first token)
    Sep = " " + Chr$(9)
    Do While Not EOF(1)
        Line Input #1, InLin
        If (InLin <> "") Then
            ' Get first token and process if it is a line number
            Token = GetToken$(InLin, Sep)
            If IsDigit(Left$(Token, 1)) Then
                LineNumber = Val(Token)
                FoundNumber = FALSE
                ' See if line number is in table of referenced line numbers
                For Index = 1 To LineCount
                    If (LineNumber = LineTable(Index)) Then
                        FoundNumber = TRUE
                    End If
                Next Index
                ' Modify line strings
                If (Not FoundNumber) Then
                    Token = Space$(Len(Token))
                    Mid$(InLin, StrSpn(InLin, Sep), Len(Token)) = Token
                End If

                ' You can replace the previous lines with your own
                ' code to reformat output. For example, try these lines:

                'TmpPos1 = StrSpn(InLin, Sep) + LEN(Token)
                'TmpPos2 = TmpPos1 + StrSpn(MID$(InLin, TmpPos1), Sep)
                '
                'IF FoundNumber THEN
                '   InLin = LEFT$(InLin, TmpPos1 - 1) + CHR$(9) + MID$(InLin, TmpPos2)
                'ELSE
                '   InLin = CHR$(9) + MID$(InLin, TmpPos2)
                'END IF

            End If
        End If
        ' Print line to file or console (PRINT is faster than console device)
        If OutputFile = "CON" Then
            Print InLin
        Else
            Print #2, InLin
        End If
    Loop
End Sub

'
' GetFileNames:
'  Gets a file name from COMMAND$.
' Input:
'  Used Command$
' Output:
'  Defines InputFiles$ and OutputFiles$
'
Sub GetFileNames
    ' Change to the directory specified by the environment
    ChDir StartDir$

    InputFile = Command$(1)

    ' Add .bas extension if required
    If InStr(InputFile, ".") = 0 Then
        InputFile = InputFile + ".BAS"
    End If

    ' Check if input file is present
    If Not FileExists(InputFile) Then
        Print InputFile; " does not exist! Specify a valid name."
        System 1
    End If

    OutputFile = Command$(2)

    If (OutputFile = "") Then
        OutputFile = InputFile + ".TMP"
    End If

    ' Add .bas extension if required
    If InStr(OutputFile, ".") = 0 Then
        OutputFile = OutputFile + ".BAS"
    End If

    If FileExists(OutputFile) Then
        Print InputFile; " already exist! Specify a valid name."
        System 1
    End If
End Sub

'
' GetToken$:
'  Extracts tokens from a string. A token is a word that is surrounded
'  by separators, such as spaces or commas. Tokens are extracted and
'  analyzed when parsing sentences or commands. To use the GetToken$
'  function, pass the string to be parsed on the first call, then pass
'  a null string on subsequent calls until the function returns a null
'  to indicate that the entire string has been parsed.
' Input:
'  Search$ = string to search
'  Delim$  = String of separators
' Output:
'  GetToken$ = next token
'
Function GetToken$ (Search As String, Delim As String) Static
    Dim As Long BegPos, NewPos
    Dim As String SaveStr

    ' Note that SaveStr$ and BegPos must be static from call to call
    ' (other variables are only static for efficiency).
    ' If first call, make a copy of the string
    If (Search <> "") Then
        BegPos = 1
        SaveStr = Search
    End If

    ' Find the start of the next token
    NewPos = StrSpn(Mid$(SaveStr, BegPos, Len(SaveStr)), Delim)
    If NewPos Then
        ' Set position to start of token
        BegPos = NewPos + BegPos - 1
    Else
        ' If no new token, quit and return null
        GetToken = ""
        Exit Function
    End If

    ' Find end of token
    NewPos = StrBrk(Mid$(SaveStr, BegPos, Len(SaveStr)), Delim)
    If NewPos Then
        ' Set position to end of token
        NewPos = BegPos + NewPos - 1
    Else
        ' If no end of token, return set to end a value
        NewPos = Len(SaveStr) + 1
    End If
    ' Cut token out of search string
    GetToken$ = Mid$(SaveStr, BegPos, NewPos - BegPos)
    ' Set new starting position
    BegPos = NewPos
End Function

'
' InitKeyTable:
'  Initializes a keyword table. Keywords must be recognized so that
'  line numbers can be distinguished from numeric constants.
' Input:
'  Uses KeyData
' Output:
'  Modifies global array KeyWordTable$
'
Sub InitKeyTable
    Dim As Long Count
    Dim As String KeyWord

    Restore KeyData
    For Count = 1 To KeyWordCount
        Read KeyWord
        KeyWordTable(Count) = KeyWord
    Next
End Sub

'
' IsDigit:
'  Returns true if character passed is a decimal digit. Since any
'  Basic token starting with a digit is a number, the function only
'  needs to check the first digit. Doesn't check for negative numbers,
'  but that's not needed here.
' Input:
'  Char$ - initial character of string to check
' Output:
'  IsDigit - true if within 0 - 9
'
Function IsDigit (Char As String)
    Dim As Long CharAsc

    If (Char = "") Then
        IsDigit = FALSE
    Else
        CharAsc = Asc(Char)
        IsDigit = (CharAsc >= Asc("0")) And (CharAsc <= Asc("9"))
    End If
End Function

'
' StrBrk:
'  Searches InString$ to find the first character from among those in
'  Separator$. Returns the index of that character. This function can
'  be used to find the end of a token.
' Input:
'  InString$ = string to search
'  Separator$ = characters to search for
' Output:
'  StrBrk = index to first match in InString$ or 0 if none match
'
Function StrBrk (InString As String, Separator As String) Static
    Dim As Long Ln, BegPos

    Ln = Len(InString)
    BegPos = 1
    ' Look for end of token (first character that is a delimiter).
    Do While InStr(Separator, Mid$(InString, BegPos, 1)) = 0
        If BegPos > Ln Then
            StrBrk = 0
            Exit Function
        Else
            BegPos = BegPos + 1
        End If
    Loop
    StrBrk = BegPos
End Function

'
' StrSpn:
'  Searches InString$ to find the first character that is not one of
'  those in Separator$. Returns the index of that character. This
'  function can be used to find the start of a token.
' Input:
'  InString$ = string to search
'  Separator$ = characters to search for
' Output:
'  StrSpn = index to first nonmatch in InString$ or 0 if all match
'
Function StrSpn% (InString As String, Separator As String) Static
    Dim As Long Ln, BegPos

    Ln = Len(InString)
    BegPos = 1
    ' Look for start of a token (character that isn't a delimiter).
    Do While InStr(Separator, Mid$(InString, BegPos, 1))
        If BegPos > Ln Then
            StrSpn = 0
            Exit Function
        Else
            BegPos = BegPos + 1
        End If
    Loop
    StrSpn = BegPos
End Function

