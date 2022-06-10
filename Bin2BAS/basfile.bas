'==================
' BASFILE.BAS v0.10
'==================
'Coded by Dav for QB64 (c) 2009

'BASFILE helps you include binary files INSIDE your QB64 compiled programs.
'It does this by converting file to BAS code that you add to your program
'that will recreate the file when you wish to use it.

'BASFILE will ask you for a file to convert, and will output the BAS code.

'=========================================================================

DefInt A-Z
DECLARE FUNCTION E$ (B$)

Print
Print "============="
Print "BASFILE v0.10"
Print "============="
Print

Input "INPUT File --> ", IN$: If IN$ = "" Then End
Input "OUTPUT File -> ", OUT$: If OUT$ = "" Then End
Open IN$ For Binary As 1
If LOF(1) = 0 Then
    Close: Kill IN$
    Print UCase$(IN$); " not found!": End
End If

Open OUT$ For Output As 2
Print: Print "Encoding file...";

Q$ = Chr$(34) 'quotation mark
Print #2, "A$ = "; Q$; Q$
Print #2, "A$ = A$ + "; Q$;

Do
    a$ = Input$(3, 1)
    BC& = BC& + 3: LL& = LL& + 4
    If LL& = 60 Then
        LL& = 0
        Print #2, E$(a$);: Print #2, Q$
        Print #2, "A$ = A$ + "; Q$;
    Else
        Print #2, E$(a$);
    End If
    If LOF(1) - BC& < 3 Then
        a$ = Input$(LOF(1) - BC&, 1): B$ = E$(a$)
        Select Case Len(B$)
            Case 0: a$ = Q$
            Case 1: a$ = "%%%" + B$ + Q$
            Case 2: a$ = "%%" + B$ + Q$
            Case 3: a$ = "%" + B$ + Q$
        End Select: Print #2, a$;: Exit Do
    End If
Loop: Print #2, ""

Print #2, "btemp$="; Q$; Q$
Print #2, "FOR i&=1TO LEN(A$) STEP 4:B$=MID$(A$,i&,4)"
Print #2, "IF INSTR(1,B$,"; Q$; "%"; Q$; ") THEN"
Print #2, "FOR C%=1 TO LEN(B$):F$=MID$(B$,C%,1)"
Print #2, "IF F$<>"; Q$; "%"; Q$; "THEN C$=C$+F$"
Print #2, "NEXT:B$=C$"
Print #2, "END IF:FOR t%=LEN(B$) TO 1 STEP-1"
Print #2, "B&=B&*64+ASC(MID$(B$,t%))-48"
Print #2, "NEXT:X$="; Q$; Q$; ":FOR t%=1 TO LEN(B$)-1"
Print #2, "X$=X$+CHR$(B& AND 255):B&=B&\256"
Print #2, "NEXT:btemp$=btemp$+X$:NEXT"
Print #2, "BASFILE$=btemp$:btemp$="; Q$; Q$
Print #2, "'==================================="
Print #2, "'EXAMPLE: SAVE BASFILE$ TO DISK"
Print #2, "'==================================="
Print #2, "'OPEN "; Q$; IN$; Q$; " FOR OUTPUT AS #1"
Print #2, "'PRINT #1, BASFILE$;"
Print #2, "'CLOSE #1"

Print "Done!"
Print UCase$(OUT$); " saved."
End

Function E$ (B$)

    For T% = Len(B$) To 1 Step -1
        B& = B& * 256 + Asc(Mid$(B$, T%))
    Next

    a$ = ""
    For T% = 1 To Len(B$) + 1
        g$ = Chr$(48 + (B& And 63)): B& = B& \ 64
        'If < and > are here, replace them with # and *
        'Just so there's no HTML tag problems with forums.
        'They'll be restored during the decoding process..
        'IF g$ = "<" THEN g$ = "#"
        'IF g$ = ">" THEN g$ = "*"
        a$ = a$ + g$
    Next: E$ = a$

End Function

