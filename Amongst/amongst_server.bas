OPTION _EXPLICIT

DIM SHARED gameVersion AS INTEGER
'this is to be increased everytime the client
'becomes incompatible with previous versions
gameVersion = 3

$LET DEBUGGING = FALSE
$IF DEBUGGING = TRUE THEN
    $CONSOLE
$END IF

$CONSOLE:ONLY
_DEST _CONSOLE

CONST True = -1, False = 0

CONST id_SERVERFULL = 1
CONST id_PING = 2
CONST id_ID = 3
CONST id_NEWCOLOR = 4
CONST id_NEWNAME = 5
CONST id_COLOR = 6
CONST id_POS = 7
CONST id_NAME = 8
CONST id_CHAT = 9
CONST id_PLAYERONLINE = 10
CONST id_PLAYEROFFLINE = 11
CONST id_PONG = 12
CONST id_PLAYERQUIT = 13
CONST id_GAMEVERSION = 14
CONST id_SHOOT = 15
CONST id_SIZE = 16
CONST id_UPDATESERVER = 17
CONST id_KICK = 18

TYPE object
    name AS STRING
    handle AS LONG
    x AS SINGLE
    xv AS SINGLE
    y AS SINGLE
    yv AS SINGLE
    state AS INTEGER
    color AS INTEGER
    basicInfoSent AS _BYTE
    broadcastOffline AS _BYTE
    ping AS SINGLE
    hasNewName AS _BYTE
    hasNewColor AS _BYTE
    hasNewPosition AS STRING
    hasNewMessage AS _BYTE
    hasNewSize AS _BYTE
    size AS INTEGER
END TYPE

CONST maxUsers = 10

DIM SHARED totalClients AS INTEGER
DIM SHARED playerStream(1 TO maxUsers) AS STRING
DIM SHARED player(1 TO maxUsers) AS object
DIM SHARED colors(1 TO 12) AS _UNSIGNED LONG
DIM i AS LONG, j AS LONG
DIM newClient AS LONG, checkUpdate AS _BYTE, checkUpdateRequester AS INTEGER
DIM id AS INTEGER, value$
DIM packet$

DIM SHARED endSignal AS STRING
endSignal = CHR$(253) + CHR$(254) + CHR$(255)

CONST timeout = 20

DIM SHARED host AS LONG
PRINT TIME$ + " Starting server (ver. "; _TRIM$(STR$(gameVersion)); ")... ";
host = _OPENHOST("TCP/IP:51512")
IF host = 0 THEN
    PRINT "Cannot listen on port 51512"
    SYSTEM
END IF
PRINT "Listening on port 51512"

DO
    newClient = 0
    newClient = _OPENCONNECTION(host)
    IF newClient THEN
        IF totalClients < maxUsers THEN
            totalClients = totalClients + 1
            FOR i = 1 TO maxUsers
                IF player(i).state = False THEN
                    playerStream(i) = ""
                    player(i).color = 0
                    player(i).handle = newClient
                    player(i).state = True
                    player(i).broadcastOffline = False
                    player(i).size = 15
                    sendData player(i), id_GAMEVERSION, MKI$(gameVersion)
                    sendData player(i), id_ID, MKI$(i)

                    'send existing players' data:
                    FOR j = 1 TO maxUsers
                        IF j = i THEN _CONTINUE
                        IF player(j).state = True THEN
                            sendData player(j), id_PLAYERONLINE, MKI$(i)

                            sendData player(i), id_PLAYERONLINE, MKI$(j)
                            sendData player(i), id_NAME, MKI$(j) + player(j).name
                            sendData player(i), id_COLOR, MKI$(j) + MKI$(player(j).color)
                            sendData player(i), id_POS, MKI$(j) + MKS$(player(j).x) + MKS$(player(j).y) + MKS$(player(j).xv) + MKS$(player(j).yv)
                            sendData player(i), id_SIZE, MKI$(j) + MKI$(player(j).size)
                        END IF
                    NEXT

                    player(i).ping = TIMER
                    EXIT FOR
                END IF
            NEXT
            PRINT TIME$ + " User at " + _CONNECTIONADDRESS$(newClient) + " connected as client #" + LTRIM$(STR$(i))
        ELSE
            packet$ = MKI$(id_SERVERFULL) + endSignal
            PUT #newClient, , packet$
            PRINT TIME$ + " Connection from " + _CONNECTIONADDRESS$(newClient) + " refused (server full)"
            CLOSE newClient
        END IF
    END IF

    FOR i = 1 TO maxUsers
        IF player(i).state = False THEN
            IF player(i).broadcastOffline = False THEN
                player(i).broadcastOffline = True
                FOR j = 1 TO maxUsers
                    IF j = i OR player(j).state = False THEN _CONTINUE
                    sendData player(j), id_PLAYEROFFLINE, MKI$(i)
                NEXT
            END IF
            _CONTINUE
        END IF

        player(i).hasNewName = False
        player(i).hasNewColor = False
        player(i).hasNewPosition = ""
        player(i).hasNewMessage = False
        player(i).hasNewSize = False

        IF timeElapsedSince(player(i).ping) > timeout THEN
            'player inactive
            player(i).state = False
            CLOSE player(i).handle
            PRINT TIME$ + " Client #" + LTRIM$(STR$(i)) + " (" + player(i).name + ") lost connection."
            totalClients = totalClients - 1
            _CONTINUE
        END IF

        getData player(i), playerStream(i)

        DO WHILE parse(playerStream(i), id, value$)
            player(i).ping = TIMER
            SELECT CASE id
                CASE id_NAME
                    player(i).hasNewName = True
                    player(i).name = value$
                    DIM attempt AS INTEGER, checkAgain AS _BYTE, m$
                    m$ = ""
                    attempt = 0
                    DO
                        checkAgain = False
                        FOR j = 1 TO maxUsers
                            IF j = i THEN _CONTINUE
                            IF attempt THEN m$ = STR$(attempt)
                            IF player(j).name = player(i).name + m$ THEN
                                attempt = attempt + 1
                                checkAgain = True
                                EXIT FOR
                            END IF
                        NEXT
                    LOOP WHILE checkAgain
                    IF attempt THEN
                        player(i).name = player(i).name + m$
                        sendData player(i), id_NEWNAME, player(i).name
                    END IF
                    PRINT TIME$ + " Client #" + LTRIM$(STR$(i)) + " has name " + player(i).name
                CASE id_COLOR 'received once per player
                    player(i).hasNewColor = True
                    DIM newcolor AS INTEGER, changed AS _BYTE
                    newcolor = CVI(value$)
                    changed = False
                    'check if this color is already in use, so another one can be assigned
                    FOR j = 1 TO maxUsers
                        IF player(j).state = True AND player(j).color = newcolor THEN
                            newcolor = newcolor + 1
                            IF newcolor > UBOUND(colors) THEN newcolor = 1
                            changed = True
                            j = 0 'check again
                        END IF
                    NEXT
                    player(i).color = newcolor
                    IF changed THEN
                        sendData player(i), id_NEWCOLOR, MKI$(newcolor)
                    END IF
                CASE id_SHOOT
                    IF player(CVI(value$)).size > 5 THEN
                        player(CVI(value$)).size = player(CVI(value$)).size - 2
                    END IF
                    FOR j = 1 TO maxUsers
                        IF player(j).state = False THEN _CONTINUE
                        sendData player(j), id_SHOOT, MKI$(i) + value$
                        sendData player(j), id_SIZE, value$ + MKI$(player(CVI(value$)).size)
                    NEXT
                CASE id_POS
                    player(i).hasNewPosition = value$
                    player(i).x = getCVS(value$)
                    player(i).y = getCVS(value$)
                    player(i).xv = getCVS(value$)
                    player(i).yv = getCVS(value$)
                CASE id_SIZE
                    player(i).hasNewSize = True
                    player(i).size = CVI(value$)
                CASE id_GAMEVERSION
                    'player is signaling it will disconnect due to wrong version
                    player(i).x = -1
                    player(i).y = -1
                CASE id_PLAYERQUIT
                    player(i).state = False
                    CLOSE player(i).handle
                    totalClients = totalClients - 1
                    PRINT TIME$ + " Client #" + LTRIM$(STR$(i)) + " (" + player(i).name + ") quit";
                    IF player(i).x = -1 AND player(i).y = -1 THEN
                        PRINT " - wrong version."
                    ELSE
                        PRINT "."
                    END IF
                    EXIT DO
                CASE id_UPDATESERVER
                    'temporary solution for triggering auto-update checks
                    checkUpdate = True
                    checkUpdateRequester = i
                    PRINT TIME$ + " Update check requested;"
                CASE id_CHAT
                    DIM chatMessage$
                    player(i).hasNewMessage = True
                    chatMessage$ = value$
                CASE id_PING
                    sendData player(i), id_PONG, ""
            END SELECT
        LOOP

        IF player(i).state = False THEN
            _CONTINUE
        ELSE
            'send this player's data to everybody else
            FOR j = 1 TO maxUsers
                IF j = i THEN _CONTINUE
                IF player(j).state = True THEN
                    IF player(i).hasNewName THEN sendData player(j), id_NAME, MKI$(i) + player(i).name
                    IF player(i).hasNewColor THEN sendData player(j), id_COLOR, MKI$(i) + MKI$(player(i).color)
                    IF LEN(player(i).hasNewPosition) THEN sendData player(j), id_POS, MKI$(i) + player(i).hasNewPosition
                    IF player(i).hasNewMessage THEN sendData player(j), id_CHAT, MKI$(i) + chatMessage$
                    IF player(i).hasNewSize THEN sendData player(j), id_SIZE, MKI$(i) + MKI$(player(i).size)
                END IF
            NEXT
        END IF
    NEXT

    IF checkUpdate THEN
        DIM remoteFile$, result AS INTEGER, file$, newVersion AS INTEGER
        DIM fileHandle AS INTEGER, updater$

        remoteFile$ = "www.qb64.org/amongst/amongst_version.txt"
        result = Download(remoteFile$, 30, file$)
        SELECT CASE result
            CASE 0 'success
                checkUpdate = False
                newVersion = VAL(MID$(file$, INSTR(file$, "=") + 1))

                IF newVersion > gameVersion THEN
                    PRINT TIME$ + " Downloading new version ("; LTRIM$(STR$(newVersion)); ")... ";

                    IF INSTR(_OS$, "WIN") THEN
                        remoteFile$ = "server_win.exe"
                        updater$ = "amongst_updater.exe"
                    ELSEIF INSTR(_OS$, "MAC") THEN
                        remoteFile$ = "server_mac"
                        updater$ = "./amongst_updater"
                    ELSE
                        remoteFile$ = "server_lnx"
                        updater$ = "./amongst_updater"
                    END IF

                    DO
                        result = Download("www.qb64.org/amongst/" + remoteFile$, 30, file$)

                        SELECT CASE result
                            CASE 0 'success
                                PRINT "done."
                                fileHandle = FREEFILE
                                OPEN remoteFile$ FOR BINARY AS #fileHandle
                                PUT #fileHandle, , file$
                                CLOSE #fileHandle
                                IF _FILEEXISTS(updater$) THEN
                                    FOR j = 1 TO maxUsers
                                        IF player(j).state = False THEN _CONTINUE
                                        sendData player(j), id_KICK, "Server auto-updating; try again in a few moments."
                                    NEXT

                                    CLOSE host
                                    SHELL _DONTWAIT CHR$(34) + updater$ + CHR$(34) + " " + CHR$(34) + COMMAND$(0) + CHR$(34)
                                    SYSTEM
                                ELSE
                                    packet$ = "Unable to update - missing '" + updater$ + "'."
                                    PRINT packet$
                                    sendData player(checkUpdateRequester), id_CHAT, MKI$(0) + packet$
                                    checkUpdate = False
                                    EXIT DO
                                END IF
                            CASE 2, 3 'can't connect or timed out
                                packet$ = "Unable to download update; try again in a few moments."
                                PRINT packet$
                                sendData player(checkUpdateRequester), id_CHAT, MKI$(0) + packet$
                                checkUpdate = False
                                EXIT DO
                        END SELECT
                        _LIMIT 10
                    LOOP
                ELSE
                    packet$ = "No new version available."
                    PRINT packet$
                    sendData player(checkUpdateRequester), id_CHAT, MKI$(0) + packet$
                    checkUpdate = False
                END IF
            CASE 2, 3 'can't connect or timed out
                packet$ = "Unable to check new versions."
                PRINT packet$
                sendData player(checkUpdateRequester), id_CHAT, MKI$(0) + packet$
                checkUpdate = False
        END SELECT
    END IF

    _LIMIT 60
LOOP

SUB sendData (client AS object, id AS INTEGER, value$)
    DIM key$
    key$ = MKI$(id) + value$ + endSignal
    PUT #client.handle, , key$
END SUB

SUB getData (client AS object, buffer AS STRING)
    DIM incoming$
    GET #client.handle, , incoming$
    buffer = buffer + incoming$
END SUB

FUNCTION parse%% (buffer AS STRING, id AS INTEGER, value$)
    DIM endMarker AS LONG
    endMarker = INSTR(buffer, endSignal)
    IF endMarker THEN
        id = CVI(LEFT$(buffer, 2))
        value$ = MID$(buffer, 3, endMarker - 3)
        buffer = MID$(buffer, endMarker + LEN(endSignal))
        parse%% = True
    END IF
END FUNCTION

FUNCTION Download% (url$, timelimit, contents$)
    'adapted from http://www.qb64.org/wiki/Downloading_Files
    '
    'Usage:
    '    Call Download%() in a loop until one of the return codes
    '    bellow is returned. Contents downloaded are returned in
    '    the contents$ variable.
    '
    'Return codes:
    '    0 = success
    '    1 = still working
    '    2 = can't connect
    '    3 = timed out

    STATIC client AS LONG, l AS LONG
    STATIC prevUrl$, prevUrl2$, a$, a2$, url2$, url3$
    STATIC x AS LONG, i AS LONG, i2 AS LONG, i3 AS LONG
    STATIC e$, x$, t!, d$, fh AS INTEGER

    IF url$ = "" THEN
        IF client THEN CLOSE client: client = 0
        prevUrl$ = ""
        EXIT SUB
    END IF

    IF url$ <> prevUrl$ THEN
        prevUrl$ = url$
        a$ = ""
        url2$ = url$
        x = INSTR(url2$, "/")
        IF x THEN url2$ = LEFT$(url$, x - 1)
        IF url2$ <> prevUrl2$ THEN
            prevUrl2$ = url2$
            IF client THEN CLOSE client: client = 0
            client = _OPENCLIENT("TCP/IP:80:" + url2$)
            IF client = 0 THEN Download = 2: prevUrl$ = "": EXIT FUNCTION
        END IF
        e$ = CHR$(13) + CHR$(10) ' end of line characters
        url3$ = RIGHT$(url$, LEN(url$) - x + 1)
        x$ = "GET " + url3$ + " HTTP/1.1" + e$
        x$ = x$ + "Host: " + url2$ + e$ + e$
        PUT #client, , x$
        t! = TIMER ' start time
    END IF

    GET #client, , a2$
    a$ = a$ + a2$
    i = INSTR(a$, "Content-Length:")
    IF i THEN
        i2 = INSTR(i, a$, e$)
        IF i2 THEN
            l = VAL(MID$(a$, i + 15, i2 - i - 14))
            i3 = INSTR(i2, a$, e$ + e$)
            IF i3 THEN
                i3 = i3 + 4 'move i3 to start of data
                IF (LEN(a$) - i3 + 1) = l THEN
                    d$ = MID$(a$, i3, l)
                    fh = FREEFILE
                    Download = 0
                    contents$ = d$
                    prevUrl$ = ""
                    prevUrl2$ = ""
                    a$ = ""
                    CLOSE client
                    client = 0
                    EXIT FUNCTION
                END IF ' availabledata = l
            END IF ' i3
        END IF ' i2
    END IF ' i
    IF TIMER > t! + timelimit THEN CLOSE client: client = 0: Download = 3: prevUrl$ = "": EXIT FUNCTION
    Download = 1 'still working
END FUNCTION

FUNCTION getCVS! (buffer$)
    getCVS! = CVS(LEFT$(buffer$, 4))
    buffer$ = MID$(buffer$, 5)
END FUNCTION

FUNCTION getCVI% (buffer$)
    getCVI% = CVI(LEFT$(buffer$, 2))
    buffer$ = MID$(buffer$, 3)
END FUNCTION


FUNCTION timeElapsedSince! (startTime!)
    IF startTime! > TIMER THEN startTime! = startTime! - 86400
    timeElapsedSince! = TIMER - startTime!
END FUNCTION

