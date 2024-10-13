' Mikmod UniMod 5 ripper
' Programmed by a740g in Winter 2K
' Slow but does the job!

$CONSOLE:ONLY
_DEFINE A-Z AS LONG
OPTION _EXPLICIT

TYPE uniModType
    numChn AS STRING * 1
    numPos AS INTEGER
    repPos AS INTEGER
    numPat AS INTEGER
    numTrk AS INTEGER
    numIns AS INTEGER
    initSpeed AS STRING * 1
    initTempo AS STRING * 1
    positions AS STRING * 256
    panning AS STRING * 32
    flags AS STRING * 1
END TYPE

DIM myId AS STRING * 4
DIM myFile AS STRING
DIM bc AS LONG
DIM modLen AS LONG
DIM fcount AS LONG

ON ERROR GOTO errorHandler

myFile$ = COMMAND$
WHILE (myFile$ = "")
    LINE INPUT "File to rip: ", myFile$
WEND

OPEN myFile$ FOR INPUT AS 1
CLOSE 1
OPEN myFile$ FOR BINARY AS 1

FOR bc& = 1 TO LOF(1)
    GET 1, bc&, myId

    IF (myId = "UN05") THEN
        PRINT "Please wait, MikMod UniMod found, processing..."
        modLen& = findUniModLen(1)

        ' Finally do the real stuff!
        copyUniModToFile 1, bc&, modLen&, "MIKMOD" + LTRIM$(STR$(fcount)) + ".UNI"
        fcount = fcount + 1
    END IF
NEXT

CLOSE 1
END

errorHandler:
PRINT "Error: "; _ERRORMESSAGE$; "!"
END

SUB copyUniModToFile (fromFile, fromWhere&, howMuch&, toFile$)
    DIM myChar AS STRING * 1
    DIM id AS STRING * 4
    DIM afile AS LONG, i AS LONG

    SEEK fromFile, fromWhere&
    GET fromFile, , id
    IF (id$ <> "UN05") THEN
        PRINT "Invalid Id: "; id
        EXIT SUB
    END IF
    SEEK fromFile, fromWhere&

    PRINT
    PRINT "Copying UniMod to "; toFile$; "...";

    afile = FREEFILE
    OPEN toFile$ FOR BINARY AS afile

    FOR i& = 1 TO howMuch&
        GET fromFile, , myChar
        PUT afile, , myChar
    NEXT

    CLOSE afile

    PRINT "done!"
END SUB

FUNCTION findUniModLen& (whichFile)
    DIM modHeader AS uniModType
    DIM myChar AS STRING * 1, junk AS STRING
    DIM myModPos AS LONG, v AS LONG, w AS LONG, samLen AS LONG, totSamLen AS LONG
    DIM flags AS INTEGER, trkLen AS INTEGER

    myModPos& = LOC(whichFile) - 4 ' we are 4 bytes away from the id

    GET whichFile, , modHeader

    PRINT
    PRINT "This UniMod sports:"
    PRINT ASC(modHeader.numChn); "channels"
    PRINT modHeader.numPat; "patterns"
    PRINT modHeader.numTrk; "tracks"
    PRINT modHeader.numIns; "instruments"

    PRINT
    PRINT "UniMod info:"
    PRINT "Name: "; getUniModString(whichFile)
    PRINT "Mod Type: "; getUniModString(whichFile)
    PRINT "Comment: "; getUniModString(whichFile)

    ' Go through the instruments
    PRINT
    PRINT "Instruments:"
    FOR v = 1 TO modHeader.numIns
        GET whichFile, , myChar

        junk$ = SPACE$(208)
        GET whichFile, , junk$

        PRINT "Instrument"; v; "="; getUniModString(whichFile)

        FOR w = 1 TO ASC(myChar) ' numsmp
            junk$ = SPACE$(5)
            GET whichFile, , junk$

            GET whichFile, , samLen&

            junk$ = SPACE$(8)
            GET whichFile, , junk$

            GET whichFile, , flags

            IF (flags AND 1) THEN samLen& = samLen& * 2
            totSamLen& = totSamLen& + samLen&

            PRINT " Sample"; w; "="; getUniModString(whichFile)
        NEXT
    NEXT

    ' Go thru the patterns
    junk$ = SPACE$(modHeader.numPat * 2)
    GET whichFile, , junk$
    junk$ = SPACE$(modHeader.numPat * ASC(modHeader.numChn) * 2)
    GET whichFile, , junk$

    ' Go thru the tracks
    FOR v = 1 TO modHeader.numTrk
        GET whichFile, , trkLen
        junk$ = SPACE$(trkLen)
        GET whichFile, , junk$
    NEXT

    ' Finally go thru the samples
    FOR v& = 1 TO totSamLen&
        GET whichFile, , myChar
    NEXT

    ' Now calculate module length
    myModPos& = LOC(whichFile) - myModPos&
    PRINT
    PRINT "UniMod length ="; myModPos&

    findUniModLen& = myModPos&
END FUNCTION

FUNCTION getUniModString$ (whichFile)
    DIM myLen AS INTEGER
    DIM mystr AS STRING

    GET whichFile, , myLen
    mystr$ = SPACE$(myLen)
    GET whichFile, , mystr$
    getUniModString$ = mystr$
END FUNCTION
