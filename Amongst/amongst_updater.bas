OPTION _EXPLICIT

$CONSOLE:ONLY
_DEST _CONSOLE

CONST true = -1, false = 0

DIM remoteFile$, localFile$
DIM newContents$

localFile$ = COMMAND$
IF LEFT$(localFile$, 2) = "./" THEN localFile$ = MID$(localFile$, 3)
IF _FILEEXISTS(localFile$) = false THEN
    PRINT "Incorrect usage."
    SYSTEM
ELSE
    PRINT "*"; localFile$; "* found;"
END IF

IF INSTR(_OS$, "WIN") THEN
    remoteFile$ = "server_win.exe"
ELSEIF INSTR(_OS$, "MAC") THEN
    remoteFile$ = "server_mac"
ELSE
    remoteFile$ = "server_lnx"
END IF

IF _FILEEXISTS(remoteFile$) THEN
    OPEN remoteFile$ FOR BINARY AS #1
    newContents$ = SPACE$(LOF(1))
    GET #1, , newContents$
    CLOSE #1

    KILL localFile$
    OPEN localFile$ FOR BINARY AS #1
    PUT #1, , newContents$
    CLOSE #1

    KILL remoteFile$
    IF INSTR(_OS$, "LINUX") THEN SHELL _HIDE "chmod +x " + CHR$(34) + COMMAND$ + CHR$(34)
    SHELL _DONTWAIT CHR$(34) + COMMAND$ + CHR$(34)
    PRINT "Update successful."
    SYSTEM
ELSE
    PRINT "Incorrect usage."
    SYSTEM
END IF

