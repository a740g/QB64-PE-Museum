' Mikmod UniMod 5 ripper
' Programmed by a740g in Winter 2K
' Slow but does the job!

$NoPrefix
DefLng A-Z
Option Explicit
Option ExplicitArray
Option Base 1
'$Static
$Console:Only
$ScreenHide
Dest Console

Type uniModType
    numChn As String * 1
    numPos As Integer
    repPos As Integer
    numPat As Integer
    numTrk As Integer
    numIns As Integer
    initSpeed As String * 1
    initTempo As String * 1
    positions As String * 256
    panning As String * 32
    flags As String * 1
End Type

Dim myId As String * 4
Dim myFile As String
Dim bc As Long
Dim modLen As Long
Dim fcount As Long

On Error GoTo errorHandler

myFile$ = Command$
While (myFile$ = "")
    Line Input "File to rip: ", myFile$
Wend

Open myFile$ For Input As 1
Close 1
Open myFile$ For Binary As 1

For bc& = 1 To LOF(1)
    Get 1, bc&, myId

    If (myId = "UN05") Then
        Print "Please wait, MikMod UniMod found, processing..."
        modLen& = findUniModLen(1)

        ' Finally do the real stuff!
        copyUniModToFile 1, bc&, modLen&, "MIKMOD" + LTrim$(Str$(fcount)) + ".UNI"
        fcount = fcount + 1
    End If
Next

Close 1
End

errorHandler:
Print "Error: "; ErrorMessage$; "!"
End

Sub copyUniModToFile (fromFile, fromWhere&, howMuch&, toFile$)
    Dim myChar As String * 1
    Dim id As String * 4
    Dim afile As Long, i As Long

    Seek fromFile, fromWhere&
    Get fromFile, , id
    If (id$ <> "UN05") Then
        Print "Invalid Id: "; id
        Exit Sub
    End If
    Seek fromFile, fromWhere&

    Print
    Print "Copying UniMod to "; toFile$; "...";

    afile = FreeFile
    Open toFile$ For Binary As afile

    For i& = 1 To howMuch&
        Get fromFile, , myChar
        Put afile, , myChar
    Next

    Close afile

    Print "done!"
End Sub

Function findUniModLen& (whichFile)
    Dim modHeader As uniModType
    Dim myChar As String * 1, junk As String
    Dim myModPos As Long, v As Long, w As Long, samLen As Long, totSamLen As Long
    Dim flags As Integer, trkLen As Integer

    myModPos& = Loc(whichFile) - 4 ' we are 4 bytes away from the id

    Get whichFile, , modHeader

    Print
    Print "This UniMod sports:"
    Print Asc(modHeader.numChn); "channels"
    Print modHeader.numPat; "patterns"
    Print modHeader.numTrk; "tracks"
    Print modHeader.numIns; "instruments"

    Print
    Print "UniMod info:"
    Print "Name: "; getUniModString(whichFile)
    Print "Mod Type: "; getUniModString(whichFile)
    Print "Comment: "; getUniModString(whichFile)

    ' Go through the instruments
    Print
    Print "Instruments:"
    For v = 1 To modHeader.numIns
        Get whichFile, , myChar

        junk$ = Space$(208)
        Get whichFile, , junk$

        Print "Instrument"; v; "="; getUniModString(whichFile)

        For w = 1 To Asc(myChar) ' numsmp
            junk$ = Space$(5)
            Get whichFile, , junk$

            Get whichFile, , samLen&

            junk$ = Space$(8)
            Get whichFile, , junk$

            Get whichFile, , flags

            If (flags And 1) Then samLen& = samLen& * 2
            totSamLen& = totSamLen& + samLen&

            Print " Sample"; w; "="; getUniModString(whichFile)
        Next
    Next

    ' Go thru the patterns
    junk$ = Space$(modHeader.numPat * 2)
    Get whichFile, , junk$
    junk$ = Space$(modHeader.numPat * Asc(modHeader.numChn) * 2)
    Get whichFile, , junk$

    ' Go thru the tracks
    For v = 1 To modHeader.numTrk
        Get whichFile, , trkLen
        junk$ = Space$(trkLen)
        Get whichFile, , junk$
    Next

    ' Finally go thru the samples
    For v& = 1 To totSamLen&
        Get whichFile, , myChar
    Next

    ' Now calculate module length
    myModPos& = Loc(whichFile) - myModPos&
    Print
    Print "UniMod length ="; myModPos&

    findUniModLen& = myModPos&
End Function

Function getUniModString$ (whichFile)
    Dim myLen As Integer
    Dim mystr As String

    Get whichFile, , myLen
    mystr$ = Space$(myLen)
    Get whichFile, , mystr$
    getUniModString$ = mystr$
End Function

