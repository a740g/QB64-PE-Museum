'+---------------+---------------------------------------------------+
'| ###### ###### |     .--. .         .-.                            |
'| ##  ## ##   # |     |   )|        (   ) o                         |
'| ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
'| ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
'| ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
'| ##     ##   # |                            ._.'                   |
'| ##     ###### |  Sources & Documents placed in the Public Domain. |
'+---------------+---------------------------------------------------+
'|                                                                   |
'| === MakeDATA.bas ===                                              |
'|                                                                   |
'| == Create a DATA block out of the given file, so you can embed it |
'| == in your program and write it back when needed.                 |
'|                                                                   |
'| == The DATAs are written into a .bm file together with a ready to |
'| == use write back FUNCTION. You just $INCLUDE this .bm file into  |
'| == your program and call the write back FUNCTION somewhere.       |
'|                                                                   |
'| == This program needs the 'lzwpacker.bm' file available from the  |
'| == Libraries Collection here:                                     |
'| ==      http://qb64phoenix.com/forum/forumdisplay.php?fid=23      |
'| == as it will try to pack the given file to keep the DATA block   |
'| == as small as possible. If compression is successful, then your  |
'| == program also must $INCLUDE 'lzwpacker.bm' to be able to unpack |
'| == the file data again for write back. MakeDATA.bas is printing   |
'| == a reminder message in such a case.                             |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'--- if you wish, set any default paths, end with a backslash ---
srcPath$ = "" 'source path
tarPath$ = "" 'target path
'-----
If srcPath$ <> "" Then
    Color 15: Print "Default source path: ": Color 7: Print srcPath$: Print
End If
If tarPath$ <> "" Then
    Color 15: Print "Default target path: ": Color 7: Print tarPath$: Print
End If

'--- collect inputs (relative paths allowed, based on default paths) ---
source:
Line Input "Source Filename: "; src$ 'any file you want to put into DATAs
If src$ = "" GoTo source
target:
Line Input "Target Basename: "; tar$ 'write stuff into this file (.bm is added)
If tar$ = "" GoTo target
'-----
On Error GoTo abort
Open "I", #1, srcPath$ + src$: Close #1 'file exist check
Open "O", #2, tarPath$ + tar$ + ".bm": Close #2 'path exist check
On Error GoTo 0

'--- separate source filename part ---
For po% = Len(src$) To 1 Step -1
    If Mid$(src$, po%, 1) = "\" Or Mid$(src$, po%, 1) = "/" Then
        srcName$ = Mid$(src$, po% + 1)
        Exit For
    ElseIf po% = 1 Then
        srcName$ = src$
    End If
Next po%
'--- separate target filename part ---
For po% = Len(tar$) To 1 Step -1
    If Mid$(tar$, po%, 1) = "\" Or Mid$(tar$, po%, 1) = "/" Then
        tarName$ = Mid$(tar$, po% + 1)
        Exit For
    ElseIf po% = 1 Then
        tarName$ = tar$
    End If
Next po%
Mid$(tarName$, 1, 1) = UCase$(Mid$(tarName$, 1, 1)) 'capitalize 1st letter

'--- init ---
Open "B", #1, srcPath$ + src$
filedata$ = Space$(LOF(1))
Get #1, , filedata$
Close #1
rawdata$ = _Deflate$(filedata$)
If rawdata$ <> "" Then
    Open "O", #1, tarPath$ + tar$ + ".lzw"
    Close #1
    Open "B", #1, tarPath$ + tar$ + ".lzw"
    Put #1, , rawdata$
    Close #1
    packed% = -1
    Open "B", #1, tarPath$ + tar$ + ".lzw"
Else
    packed% = 0
    Open "B", #1, srcPath$ + src$
End If
fl& = LOF(1)
cntL& = Int(fl& / 32)
cntB& = (fl& - (cntL& * 32))

'--- .bm include file ---
Open "O", #2, tarPath$ + tar$ + ".bm"
Print #2, "'============================================================"
Print #2, "'=== This file was created with MakeDATA.bas by RhoSigma, ==="
Print #2, "'=== you must $INCLUDE this at the end of your program.   ==="
If packed% Then
    Print #2, "'=== ---------------------------------------------------- ==="
    Print #2, "'=== If your program is NOT a GuiTools based application, ==="
    Print #2, "'=== then it must also $INCLUDE: 'lzwpacker.bm' available ==="
    Print #2, "'=== from the Libraries Collection here:                  ==="
    Print #2, "'=== http://qb64phoenix.com/forum/forumdisplay.php?fid=23 ==="
End If
Print #2, "'============================================================"
Print #2, ""
'--- writeback function ---
Print #2, "'"; String$(Len(tarName$) + 18, "-")
Print #2, "'--- Write"; tarName$; "Data$ ---"
Print #2, "'"; String$(Len(tarName$) + 18, "-")
Print #2, "' This function will write the DATAs you've created with MakeDATA.bas"
Print #2, "' back to disk and so it rebuilds the original file."
Print #2, "'"
Print #2, "' After the writeback call, only use the returned realFile$ to access the"
Print #2, "' written file. It's your given path, but with an maybe altered filename"
Print #2, "' (number added) in order to avoid the overwriting of an already existing"
Print #2, "' file with the same name in the given location."
Print #2, "'----------"
Print #2, "' SYNTAX:"
Print #2, "'   realFile$ = Write"; tarName$; "Data$ (wantFile$)"
Print #2, "'----------"
Print #2, "' INPUTS:"
Print #2, "'   --- wantFile$ ---"
Print #2, "'    The filename you would like to write the DATAs to, can contain"
Print #2, "'    a full or relative path."
Print #2, "'----------"
Print #2, "' RESULT:"
Print #2, "'   --- realFile$ ---"
Print #2, "'    - On success this is the path and filename finally used after all"
Print #2, "'      applied checks, use only this returned filename to access the"
Print #2, "'      written file."
Print #2, "'    - On failure this function will panic with the appropriate runtime"
Print #2, "'      error code which you may trap and handle as needed with your own"
Print #2, "'      ON ERROR GOTO... handler."
Print #2, "'---------------------------------------------------------------------"
Print #2, "FUNCTION Write"; tarName$; "Data$ (file$)"
Print #2, "'--- option _explicit requirements ---"
Print #2, "DIM po%, body$, ext$, num%, numL&, numB&, rawdata$, stroffs&, i&, dat&, ff%";
If packed% Then Print #2, ", filedata$": Else Print #2, ""
Print #2, "'--- separate filename body & extension ---"
Print #2, "FOR po% = LEN(file$) TO 1 STEP -1"
Print #2, "    IF MID$(file$, po%, 1) = "; Chr$(34); "."; Chr$(34); " THEN"
Print #2, "        body$ = LEFT$(file$, po% - 1)"
Print #2, "        ext$ = MID$(file$, po%)"
Print #2, "        EXIT FOR"
Print #2, "    ELSEIF MID$(file$, po%, 1) = "; Chr$(34); "\"; Chr$(34); " OR MID$(file$, po%, 1) = "; Chr$(34); "/"; Chr$(34); " OR po% = 1 THEN"
Print #2, "        body$ = file$"
Print #2, "        ext$ = "; Chr$(34); Chr$(34)
Print #2, "        EXIT FOR"
Print #2, "    END IF"
Print #2, "NEXT po%"
Print #2, "'--- avoid overwriting of existing files ---"
Print #2, "num% = 1"
Print #2, "WHILE _FILEEXISTS(file$)"
Print #2, "    file$ = body$ + "; Chr$(34); "("; Chr$(34); " + LTRIM$(STR$(num%)) + "; Chr$(34); ")"; Chr$(34); " + ext$"
Print #2, "    num% = num% + 1"
Print #2, "WEND"
Print #2, "'--- write DATAs ---"
Print #2, "RESTORE "; tarName$
Print #2, "READ numL&, numB&"
Print #2, "rawdata$ = SPACE$((numL& * 4) + numB&)"
Print #2, "stroffs& = 1"
Print #2, "FOR i& = 1 TO numL&"
Print #2, "    READ dat&"
Print #2, "    MID$(rawdata$, stroffs&, 4) = MKL$(dat&)"
Print #2, "    stroffs& = stroffs& + 4"
Print #2, "NEXT i&"
Print #2, "IF numB& > 0 THEN"
Print #2, "    FOR i& = 1 TO numB&"
Print #2, "        READ dat&"
Print #2, "        MID$(rawdata$, stroffs&, 1) = CHR$(dat&)"
Print #2, "        stroffs& = stroffs& + 1"
Print #2, "    NEXT i&"
Print #2, "END IF"
Print #2, "ff% = FREEFILE"
Print #2, "OPEN file$ FOR OUTPUT AS ff%"
If packed% Then
    Print #2, "CLOSE ff%"
    Print #2, "filedata$ = _INFLATE$(rawdata$)"
    Print #2, "OPEN file$ FOR BINARY AS ff%"
    Print #2, "PUT #ff%, , filedata$"
Else
    Print #2, "PRINT #ff%, rawdata$;"
End If
Print #2, "CLOSE ff%"
Print #2, "'--- set result ---"
Print #2, "Write"; tarName$; "Data$ = file$"
Print #2, "EXIT FUNCTION"
Print #2, ""
Print #2, "'--- DATAs representing the contents of file "; srcName$
Print #2, "'---------------------------------------------------------------------"
Print #2, tarName$; ":"
'--- read LONGs ---
Print #2, "DATA "; LTrim$(Str$(cntL& * 8)); ","; LTrim$(Str$(cntB&))
tmpI$ = Space$(32)
For z& = 1 To cntL&
    Get #1, , tmpI$: offI% = 1
    tmpO$ = "DATA " + String$(87, ","): offO% = 6
    Do
        tmpL& = CVL(Mid$(tmpI$, offI%, 4)): offI% = offI% + 4
        Mid$(tmpO$, offO%, 10) = "&H" + Right$("00000000" + Hex$(tmpL&), 8)
        offO% = offO% + 11
    Loop Until offO% > 92
    Print #2, tmpO$
Next z&
'--- read remaining BYTEs ---
If cntB& > 0 Then
    Print #2, "DATA ";
    For x% = 1 To cntB&
        Get #1, , tmpB%%
        Print #2, "&H" + Right$("00" + Hex$(tmpB%%), 2);
        If x% <> 16 Then
            If x% <> cntB& Then Print #2, ",";
        Else
            If x% <> cntB& Then
                Print #2, ""
                Print #2, "DATA ";
            End If
        End If
    Next x%
    Print #2, ""
End If
Print #2, "END FUNCTION"
Print #2, ""
'--- ending ---
Close #2
Close #1

'--- finish message ---
Color 10: Print: Print "file successfully processed..."
Color 9: Print: Print "You must $INCLUDE the created file (target name + .bm extension) at"
Print "the end of your program and call the function 'Write"; tarName$; "Data$(...)'"
Print "in an appropriate place to write the file back to disk."
If packed% Then
    Color 12: Print: Print "Your program must also $INCLUDE 'lzwpacker.bm' available from"
    Print "the Libraries Collection here:"
    Print "     http://qb64phoenix.com/forum/forumdisplay.php?fid=23"
    Print "to be able to write back the just processed file."
    Kill tarPath$ + tar$ + ".lzw"
End If
done:
Color 7
End
'--- error handler ---
abort:
Color 12: Print: Print "something is wrong with path/file access, check your inputs and try again..."
Resume done

