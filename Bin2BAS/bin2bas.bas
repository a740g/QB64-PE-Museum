'=======================
' BIN2BAS.BAS Version 2
'=======================
'BIN2BAS converts binary files to BAS code (text mode).
'Program coded by Dav

'*** NEW IN THIS VERSION:
'*** Added multi-sub saving to allow bigger files (150k).

'*** PLANNED FOR NEXT VERSION:
'*** Give option of splitting output into 16k sgement files.
'*** (useful for posting to the forum which has 16k size limit)

'BIN2BAS was coded to help people put small binary files (ZIP, etc)
'on message boards or in emails by converting them the text BAS code.
'It will convert a binary file to a Qbasic BAS script that, when run
'under Qbasic 1.1 or QB 4.5, will recreate the original binary file.

'
'=====================================================================

DefInt A-Z
DECLARE FUNCTION E$ (B$)

Print
Print "==================="
Print "BIN2BAS v2.0 by Dav"
Print "==================="
Print "Converts small binary files to BAS code."
Print "This program was coded for THECODEPOST.COM"
Print

'=== Get file from user

Input "INPUT File --> ", IN$: If IN$ = "" Then End
Input "OUTPUT File -> ", OUT$: If OUT$ = "" Then End

'=== Open and check for existance

Open IN$ For Binary As 1
If LOF(1) = 0 Then
    Close: Kill IN$
    Print UCase$(IN$); " not found!": End
End If

'=== See if it's too big for making a valid BAS file.

If LOF(1) > 150000 Then
    Print
    Print "=========================================================="
    Print "ERROR: Sorry, this file's too big to make into a BAS file."
    Print "=========================================================="
    Close: End
End If

'=== Make sure it's not too big to post

If LOF(1) > 11000 Then
    Print
    Print "=========================================================="
    Print "WARNING: The converted file will be too big to post as is."
    Print "THE QB CODE POST currently only allows 16k size messages. "
    Print "You CAN continue, but you will have to break the BAS into "
    Print "parts before posting them to the forum. < PRESS ANY KEY > "
    Print "=========================================================="
    OK$ = Input$(1)
End If

'=== Open the file to make

Open OUT$ For Output As 2

'========================
' THE ENCODING SECTION...
'========================

Print: Print "Encoding file...";

Q$ = Chr$(34) 'quotation mark
SUBS = 1 'current number of sub's made

'=== Give file info.

Print #2, "'Made with BIN2BAS v2.0 by Dav"
Print #2, "'THE QB CODE POST: http://home.carolina.rr.com/davs/codepost/"
Print #2, "'============================================================="
Print #2, "'RUN THIS UNDER QBASIC TO CREATE FILE IN THE CURRENT DIRECTORY"
Print #2, "'FILENAME: "; UCase$(IN$); ", FILESIZE:"; LOF(1); "bytes."
Print #2, "'============================================================="
Print #2, "DEFINT A-Z:DIM SHARED C&:C&="; LOF(1)
Print #2, "OPEN"; Q$; IN$; Q$; "FOR OUTPUT AS 1:";
Print #2, "?"; Q$; "Decoding..."; Q$; ";"
Print #2, "SUB S" + LTrim$(RTrim$(Str$(SUBS)))
Print #2, "D"; Q$;

'=======================================================================
'NOTE: There are three special characters used in the encoding/decoding.
' The % is a null character and added because the decoder's set to read
' in chunks of 4 bytes. So, If less than 3 bytes of the file are left
' when encoding, nulls are added to pad it up to 4 and will be removed
' in the decoding process. To make the BAS script HTML-safe to post,
' we must replace the "<" and ">" (html tag) with some other ones which
' aren't being used. So, "#" and "*" will do nicely as replacements.
'=======================================================================

LC& = 1 'Number of lines saved

Do
    a$ = Input$(3, 1)
    BC& = BC& + 3: LL& = LL& + 4
    If LL& = 60 Then 'If line length=60,
        LC& = LC& + 1: LL& = 0
        Print #2, E$(a$) 'Save with a CR.
        If LC& = 225 Then
            Print #2, "END SUB"
            LC& = 0: SUBS = SUBS + 1
            Print #2, "SUB S" + LTrim$(RTrim$(Str$(SUBS)))
        End If
        Print #2, "D"; Q$;
    Else
        Print #2, E$(a$);
    End If
    If LOF(1) - BC& < 3 Then
        a$ = Input$(LOF(1) - BC&, 1): B$ = E$(a$)
        Select Case Len(B$)
            Case 0: a$ = ""
            Case 1: a$ = "%%%" + B$
            Case 2: a$ = "%%" + B$
            Case 3: a$ = "%" + B$
        End Select: Print #2, a$;: Exit Do
    End If
Loop

Print #2, Chr$(10); Chr$(13);
Print #2, "IF C&=LOF(1)THEN?"; Q$; "OK!"; Q$; "ELSE?"; Q$; "BAD!"; Q$
Print #2, "END SUB"

For T = 1 To SUBS
    Print #2, "S" + LTrim$(RTrim$(Str$(T)))
Next

'=== Add the Decoder SUB

Print #2, "SUB D(A$)"
Print #2, "g$="; Q$; Q$; ":FOR t%=1TO LEN(A$)"
Print #2, "t$=MID$(A$,t%,1)"
Print #2, "IF t$="; Q$; "#"; Q$; "THEN t$="; Q$; "<"; Q$
Print #2, "IF t$="; Q$; "*"; Q$; "THEN t$="; Q$; ">"; Q$
Print #2, "g$=g$+t$:NEXT:A$=g$"
Print #2, "FOR i&=1TO LEN(A$) STEP 4:B$=MID$(A$,i&,4)"
Print #2, "IF INSTR(1,B$,"; Q$; "%"; Q$; ") THEN"
Print #2, "FOR C%=1 TO LEN(B$):F$=MID$(B$,C%,1)"
Print #2, "IF F$<>"; Q$; "%"; Q$; "THEN C$=C$+F$"
Print #2, "NEXT:B$=C$"
Print #2, "END IF:FOR t%=LEN(B$) TO 1 STEP-1"
Print #2, "B&=B&*64+ASC(MID$(B$,t%))-48"
Print #2, "NEXT:X$="; Q$; Q$; ":FOR t%=1 TO LEN(B$)-1"
Print #2, "X$=X$+CHR$(B& AND 255):B&=B&\256"
Print #2, "NEXT:?#1,X$;:NEXT:END SUB"

Print "Done!"
Print UCase$(OUT$); " saved."
End

Function E$ (B$)

    '=== Encode bytes

    For T% = Len(B$) To 1 Step -1
        B& = B& * 256 + Asc(Mid$(B$, T%))
    Next

    a$ = ""
    For T% = 1 To Len(B$) + 1
        g$ = Chr$(48 + (B& And 63)): B& = B& \ 64
        'If < and > are here, replace them with # and *
        If g$ = "<" Then g$ = "#"
        If g$ = ">" Then g$ = "*"
        a$ = a$ + g$
    Next: E$ = a$

End Function

