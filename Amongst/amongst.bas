OPTION _EXPLICIT

DIM SHARED gameVersion AS INTEGER
'this is to be increased everytime the client
'becomes incompatible with previous versions
gameVersion = 3

$LET DEBUGGING = FALSE
$IF DEBUGGING = TRUE THEN
    $CONSOLE
$END IF

CONST True = -1, False = 0
CONST mode_freeplay = 0
CONST mode_onlineclient = 1

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

CONST timeout = 20
CONST dataSendThreshold = .5

CONST windowWidth = 800
CONST windowHeight = 600

TYPE object
    name AS STRING
    handle AS LONG
    x AS SINGLE
    prevX AS SINGLE
    nextX AS SINGLE
    y AS SINGLE
    prevY AS SINGLE
    nextY AS SINGLE
    xv AS SINGLE
    yv AS SINGLE
    xa AS SINGLE
    ya AS SINGLE
    w AS INTEGER
    h AS INTEGER
    state AS INTEGER
    start AS SINGLE
    duration AS SINGLE
    color AS _UNSIGNED LONG
    fgColor AS _UNSIGNED LONG
    basicInfoSent AS _BYTE
    stateSent AS SINGLE
    broadcastOffline AS _BYTE
    ping AS SINGLE
    id AS INTEGER
    text AS STRING
    size AS INTEGER
    r AS INTEGER
    g AS INTEGER
    b AS INTEGER
    gravity AS SINGLE
    delay AS SINGLE
END TYPE

TYPE colorType
    name AS STRING
    value AS _UNSIGNED LONG
END TYPE

REDIM SHARED ui(1 TO 1) AS object, mouseDownOn AS INTEGER, uiClicked AS _BYTE
DIM SHARED mouseIsDown AS _BYTE, mouseDownX AS INTEGER, mouseDownY AS INTEGER
DIM SHARED mb1 AS _BYTE, mb2 AS _BYTE, mx AS INTEGER, my AS INTEGER
REDIM SHARED serverList(0) AS object, mouseWheel AS INTEGER
DIM SHARED focus AS INTEGER
DIM SHARED endSignal AS STRING
DIM SHARED mainWindow AS LONG, mapImage AS LONG, worldMapImage AS LONG
DIM SHARED settingsScreenImage AS LONG, dialogImage AS LONG, chatLogImage AS LONG
DIM SHARED scanLinesImage AS LONG
DIM SHARED messageIcon AS LONG
DIM SHARED particle(1000) AS object
DIM SHARED mode AS INTEGER
DIM SHARED totalClients AS INTEGER
DIM SHARED serverStream AS STRING
DIM SHARED player(1 TO 10) AS object, me AS INTEGER
DIM SHARED colors(1 TO 12) AS colorType, r AS INTEGER, g AS INTEGER, b AS INTEGER
DIM SHARED warning(1 TO 30) AS object
REDIM SHARED chat(1 TO 100) AS object, hasUnreadMessages AS _BYTE, chatOpen AS _BYTE
DIM SHARED chatScroll AS INTEGER
DIM SHARED chosenServer$
DIM SHARED server AS object
DIM SHARED userName$, userColor%
DIM SHARED exitSign AS INTEGER
DIM SHARED serverPing AS SINGLE
DIM SHARED errorDialog AS object
DIM radians AS SINGLE
DIM idSet AS _BYTE, shipMovement AS _BYTE
DIM currentPing AS SINGLE, waitingForPong AS _BYTE
DIM id AS INTEGER, value$
DIM myMessage$, char$, tooFast AS _BYTE

DIM target AS INTEGER
DIM score AS LONG
DIM i AS LONG
DIM x AS SINGLE, y AS SINGLE

endSignal = CHR$(253) + CHR$(254) + CHR$(255)

mainWindow = _NEWIMAGE(windowWidth, windowHeight, 32)
SCREEN mainWindow
DO UNTIL _SCREENEXISTS: _LIMIT 10: LOOP
_TITLE "Amongst"
_PRINTMODE _KEEPBACKGROUND
_CONTROLCHR OFF

readServerList
restoreColors
generateImages

intro
DO
    _FONT 16
    settingsScreen

    'reset chat history, if any
    FOR i = 1 TO UBOUND(chat)
        chat(i).state = False
    NEXT
    _FONT 16
    IF chatLogImage = 0 THEN
        chatLogImage = _NEWIMAGE(windowWidth - 100, windowHeight - 100 - _FONTHEIGHT * 3, 32)
    END IF
    chatScroll = -(_FONTHEIGHT * 2 * UBOUND(chat)) + _HEIGHT(chatLogImage)

    _FONT 8
    _PRINTMODE _KEEPBACKGROUND

    DIM SHARED playerSpeed AS SINGLE
    DIM SHARED camera AS object

    RANDOMIZE TIMER

    CONST keyUP = 18432
    CONST keyDOWN = 20480
    CONST keyLEFT = 19200
    CONST keyRIGHT = 19712
    CONST keySPACE = 32

    CONST cameraWindow = 100

    CONST minSpeed = 3
    CONST maxSpeed = 5

    playerSpeed = maxSpeed
    shipMovement = True

    uiReset
    i = addUiItem("messageicon", windowWidth - 50, 10, _WIDTH(messageIcon), _HEIGHT(messageIcon))
    ui(i).handle = messageIcon
    ui(i).state = True
    ui(i).color = _RGB32(255)

    chatOpen = False
    myMessage$ = ""
    IF mode > 0 OR server.handle <> 0 THEN
        idSet = False
        IF me THEN player(me).basicInfoSent = False
    ELSE
        idSet = True
        me = 1
        player(me).name = userName$
        player(me).x = _WIDTH / 2 + COS(RND * _PI) * (RND * 100)
        player(me).y = _HEIGHT / 2 + SIN(RND * _PI) * (RND * 100)
        player(me).state = True
        player(me).color = userColor%
        player(me).size = 15
    END IF

    DIM rx, ry, rr

    DO
        CLS

        DIM shipFlotation AS SINGLE, shipFloatAmplitude AS SINGLE
        IF shipMovement THEN
            shipFlotation = shipFlotation + .05
            IF shipFlotation > _PI(2) THEN shipFlotation = shipFlotation - _PI(2)
            shipFloatAmplitude = 1.5
        END IF

        _DONTBLEND
        _PUTIMAGE (camera.x + COS(shipFlotation) * shipFloatAmplitude, camera.y + SIN(shipFlotation) * shipFloatAmplitude), mapImage
        _BLEND

        IF mode = mode_onlineclient OR server.handle <> 0 THEN
            IF idSet THEN
                IF player(me).basicInfoSent = False THEN
                    player(me).basicInfoSent = True
                    sendData server, id_COLOR, MKI$(player(me).color)
                    sendData server, id_NAME, player(me).name
                    sendData server, id_SIZE, MKI$(player(me).size)
                END IF

                IF timeElapsedSince(player(me).stateSent) > dataSendThreshold OR player(me).xv <> player(me).prevX OR player(me).yv <> player(me).prevY THEN
                    player(me).prevX = player(me).xv
                    player(me).prevY = player(me).yv
                    player(me).stateSent = TIMER

                    ' This number 50 is just made up, but it should be calculated form average ping.
                    sendData server, id_POS, MKS$(player(me).x + 50 * player(me).xv) + MKS$(player(me).y + 50 * player(me).yv) + MKS$(player(me).xv) + MKS$(player(me).yv)
                END IF
            END IF


            IF waitingForPong = False THEN
                serverPing = TIMER
                sendData server, id_PING, ""
                waitingForPong = True
            END IF

            getData server, serverStream
            WHILE parse(serverStream, id, value$)
                SELECT EVERYCASE id
                    CASE id_ID 'first piece of data sent by server if not full
                        idSet = True
                        me = CVI(value$)
                        player(me).name = userName$
                        player(me).x = _WIDTH / 2 + COS(RND * _PI) * (RND * 100)
                        player(me).y = _HEIGHT / 2 + SIN(RND * _PI) * (RND * 100)
                        player(me).nextX = player(me).x
                        player(me).nextY = player(me).y
                        player(me).state = True
                        player(me).color = userColor%
                        player(me).size = 15
                    CASE id_NEWCOLOR 'server color changes must always be applied
                        player(me).color = CVI(value$)
                    CASE id_NEWNAME 'server name changes must always be applied
                        player(me).name = value$
                    CASE id_COLOR
                        player(CVI(LEFT$(value$, 2))).color = CVI(RIGHT$(value$, 2))
                    CASE id_SIZE
                        player(CVI(LEFT$(value$, 2))).size = CVI(RIGHT$(value$, 2))
                    CASE id_POS
                        'playerStream(CVI(LEFT$(value$, 2))) = playerStream(CVI(LEFT$(value$, 2))) + MID$(value$, 3)
                        id = getCVI(value$)
                        player(id).nextX = getCVS(value$)
                        player(id).nextY = getCVS(value$)
                        player(id).xv = getCVS(value$)
                        player(id).yv = getCVS(value$)
                    CASE id_NAME
                        player(CVI(LEFT$(value$, 2))).name = MID$(value$, 3)
                    CASE id_CHAT
                        hasUnreadMessages = True
                        addMessageToChat CVI(LEFT$(value$, 2)), MID$(value$, 3)
                    CASE id_SHOOT
                        id = getCVI(value$)
                        IF id = me THEN _CONTINUE
                        target = getCVI(value$)
                        IF target = me THEN score = score - 100
                        addParticles "explosion", player(target).x, player(target).y, 0, 0, 0, 5, 0, _RGB32(255), .3
                        addParticles "explosion", player(target).x, player(target).y, 0, 0, 0, 100, 0, colors(player(target).color).value, .3

                        radians = _ATAN2(player(target).y - player(id).y, player(target).x - player(id).x)
                        FOR i = 1 TO 20
                            addParticles "projectile", player(id).x + COS(radians) * i, player(id).y + SIN(radians) * i, COS(radians) * 5, SIN(radians) * 5, 2, 1, .5, colors(player(id).color).value, 0
                        NEXT
                    CASE id_PLAYERONLINE
                        player(CVI(value$)).state = True
                    CASE id_PLAYEROFFLINE
                        IF player(CVI(value$)).state = True THEN
                            player(CVI(value$)).state = False
                            addWarning player(CVI(value$)).name + " left the game."
                        END IF
                    CASE id_PONG
                        waitingForPong = False
                    CASE id_KICK
                        setError "Kicked from server. Reason:" + CHR$(10) + value$, 3
                        CLOSE server.handle
                        server.handle = 0
                        EXIT DO
                END SELECT
            WEND

            totalClients = 0
            FOR i = 1 TO UBOUND(player)
                IF player(i).state = True THEN totalClients = totalClients + 1
            NEXT
        END IF

        IF playerSpeed < minSpeed THEN playerSpeed = minSpeed
        IF playerSpeed > maxSpeed THEN playerSpeed = maxSpeed

        IF idSet THEN
            IF chatOpen = False THEN
                player(me).xv = 0
                player(me).yv = 0
                IF _KEYDOWN(keyUP) THEN
                    player(me).nextY = player(me).y - playerSpeed
                    player(me).yv = -playerSpeed
                END IF
                IF _KEYDOWN(keyDOWN) THEN
                    player(me).nextY = player(me).y + playerSpeed
                    player(me).yv = playerSpeed
                END IF
                IF _KEYDOWN(keyLEFT) THEN
                    player(me).nextX = player(me).x - playerSpeed
                    player(me).xv = -playerSpeed
                END IF
                IF _KEYDOWN(keyRIGHT) THEN
                    player(me).nextX = player(me).x + playerSpeed
                    player(me).xv = playerSpeed
                END IF

                IF player(me).x < 0 THEN player(me).x = 0
                IF player(me).y < 0 THEN player(me).y = 0
                IF player(me).x > _WIDTH(mapImage) THEN player(me).x = _WIDTH(mapImage)
                IF player(me).y > _HEIGHT(mapImage) THEN player(me).y = _HEIGHT(mapImage)
            END IF
            adjustCamera
        END IF

        exitSign = _EXIT
        IF exitSign THEN
            IF mode = mode_onlineclient OR server.handle <> 0 THEN sendData server, id_PLAYERQUIT, ""
            EXIT DO
        END IF

        IF mode = mode_onlineclient OR server.handle <> 0 THEN
            DIM k AS LONG
            k = _KEYHIT

            IF k = 27 THEN
                IF chatOpen THEN
                    myMessage$ = ""
                    chatOpen = False
                END IF
            END IF

            COLOR _RGB32(255)

            DIM m$
            currentPing = timeElapsedSince(serverPing)
            IF currentPing > timeout THEN
                setError "Connection lost (timed out)", 4
                CLOSE server.handle
                server.handle = 0
                EXIT DO
            END IF
            m$ = LTRIM$(STR$(currentPing))
            m$ = MID$(m$, INSTR(m$, ".") + 1)
            m$ = LEFT$(STRING$(3 - LEN(m$), "0") + m$, 3) + "ms"
            _PRINTSTRING (_WIDTH - 150 - _PRINTWIDTH(m$), 0), m$

            _FONT 16
            m$ = LTRIM$(STR$(totalClients)) + "/" + LTRIM$(STR$(UBOUND(player)))
            _PRINTSTRING ((_WIDTH - _PRINTWIDTH(m$)) / 2, _HEIGHT - _FONTHEIGHT), m$
            _FONT 8
        END IF

        target = 0
        DIM testDist AS SINGLE, closest AS SINGLE
        closest = _WIDTH
        FOR i = 1 TO UBOUND(player)
            'proximity
            IF i <> me AND player(i).state = True THEN
                testDist = dist(player(me).x, player(me).y, player(i).x, player(i).y)
                IF testDist < 150 AND testDist < closest THEN
                    closest = testDist
                    target = i
                END IF
            END IF
        NEXT

        IF target THEN
            DIM targetAnimation AS SINGLE
            targetAnimation = targetAnimation - .1
            IF targetAnimation < 0 THEN targetAnimation = 5

            x = player(target).x + camera.x + COS(shipFlotation) * shipFloatAmplitude
            y = player(target).y + camera.y + SIN(shipFlotation) * shipFloatAmplitude
            CircleFill x, y, player(target).size + 10 + targetAnimation, _RGB32(255, 0, 0, 100)
        END IF

        FOR i = 1 TO UBOUND(player)
            IF player(i).state = False OR player(i).color = 0 THEN _CONTINUE

            rx = player(i).nextX - player(i).x
            ry = player(i).nextY - player(i).y
            rr = SQR(rx ^ 2 + ry ^ 2)
            IF rr > 5 THEN
                rx = rx / rr
                ry = ry / rr
                player(i).x = player(i).x + rx * playerSpeed
                player(i).y = player(i).y + ry * playerSpeed
            ELSE
                rx = 0
                ry = 0
                player(i).x = player(i).nextX
                player(i).y = player(i).nextY
            END IF

            x = player(i).x + camera.x + COS(shipFlotation) * shipFloatAmplitude
            y = player(i).y + camera.y + SIN(shipFlotation) * shipFloatAmplitude
            CircleFill x, y + 6, player(i).size + 5, _RGB32(0, 50)
            CircleFill x, y, player(i).size + 5, _RGB32(0)
            CircleFill x, y, player(i).size, colors(player(i).color).value
            COLOR _RGB32(0)
            _PRINTSTRING (1 + x - _PRINTWIDTH(player(i).name) / 2, 1 + y - 25), player(i).name
            COLOR _RGB32(255)
            _PRINTSTRING (x - _PRINTWIDTH(player(i).name) / 2, y - 25), player(i).name
        NEXT

        IF _KEYDOWN(keySPACE) AND chatOpen = False THEN
            DIM lastShot AS SINGLE
            IF target > 0 THEN
                IF timeElapsedSince(lastShot) > .5 THEN
                    lastShot = TIMER
                    score = score + 100
                    sendData server, id_SHOOT, MKI$(target)
                    addParticles "explosion", player(target).x, player(target).y, 0, 0, 0, 5, 0, _RGB32(255), .3
                    addParticles "explosion", player(target).x, player(target).y, 0, 0, 0, 100, 0, colors(player(target).color).value, .3

                    radians = _ATAN2(player(target).y - player(me).y, player(target).x - player(me).x)
                    FOR i = 1 TO 20
                        addParticles "projectile", player(me).x + COS(radians) * i, player(me).y + SIN(radians) * i, COS(radians) * 5, SIN(radians) * 5, 2, 1, .5, colors(player(me).color).value, 0
                    NEXT
                END IF
            END IF
        END IF

        updateParticles

        'LINE (_WIDTH / 2 - cameraWindow, _HEIGHT / 2 - cameraWindow)-STEP(cameraWindow * 2, cameraWindow * 2), , B

        'display warnings
        FOR i = 1 TO UBOUND(warning)
            IF warning(i).state = True THEN
                COLOR _RGB32(0)
                _PRINTSTRING (11, 1 + _HEIGHT / 2 + _FONTHEIGHT * i), warning(i).name
                COLOR _RGB32(238, 50, 22)
                _PRINTSTRING (10, _HEIGHT / 2 + _FONTHEIGHT * i), warning(i).name
                IF timeElapsedSince(warning(i).ping) > 2.5 THEN warning(i).state = False
            END IF
        NEXT

        'display UI
        IF mode = mode_onlineclient OR server.handle <> 0 THEN
            uiDisplay
            IF hasUnreadMessages THEN
                CircleFill _WIDTH - 50, 10, 8, _RGB32(0)
                CircleFill _WIDTH - 50, 10, 5, _RGB32(205, 6, 0)
            END IF

            IF chatOpen THEN
                hasUnreadMessages = False
                LINE (50, 50)-(_WIDTH - 50, _HEIGHT - 50), _RGB32(0, 150), BF
                LINE (50, 50)-(_WIDTH - 50, _HEIGHT - 50), _RGB32(0), B

                _DEST chatLogImage
                _PRINTMODE _KEEPBACKGROUND
                chatScroll = chatScroll - mouseWheel * 15
                IF chatScroll < -(_FONTHEIGHT * 2 * UBOUND(chat)) + _HEIGHT(chatLogImage) THEN
                    chatScroll = -(_FONTHEIGHT * 2 * UBOUND(chat)) + _HEIGHT(chatLogImage)
                END IF
                IF chatScroll > 0 THEN chatScroll = 0
                CLS
                _CLEARCOLOR _RGB32(0)
                _FONT 16
                COLOR _RGB32(0)
                FOR i = 1 TO UBOUND(chat)
                    y = chatScroll + 15 + _FONTHEIGHT * ((i - 1) * 2)
                    IF chat(i).state THEN
                        IF y > _HEIGHT(chatLogImage) THEN EXIT FOR
                        LINE (5, y - 10)-(_WIDTH - 5, y + 18), _RGB32(255, 100), BF
                        _FONT 8
                        x = 10
                        IF chat(i).id = me THEN x = _WIDTH - 10 - _PRINTWIDTH(chat(i).name)
                        printOutline x, y - 8, chat(i).name, colors(chat(i).color).value, _RGB32(0)
                        _FONT 16
                        x = 10
                        IF chat(i).id = me THEN x = _WIDTH - 10 - _PRINTWIDTH(chat(i).text)
                        printOutline x, y, LEFT$(chat(i).text, (_WIDTH - 100) \ _FONTWIDTH), _RGB32(255), _RGB32(0)
                    ELSE
                        IF y > 0 AND y < _HEIGHT(chatLogImage) THEN
                            chatScroll = chatScroll - y
                            IF chatScroll < -(_FONTHEIGHT * 2 * UBOUND(chat)) + _HEIGHT(chatLogImage) THEN
                                chatScroll = -(_FONTHEIGHT * 2 * UBOUND(chat)) + _HEIGHT(chatLogImage)
                            END IF
                        END IF
                    END IF
                NEXT
                _DEST 0
                _FONT 16
                _PUTIMAGE (50, 50), chatLogImage

                'DIM SHARED mouseIsDown AS _BYTE, mouseDownX AS INTEGER, mouseDownY AS INTEGER
                'DIM SHARED mb1 AS _BYTE, mb2 AS _BYTE, mx AS INTEGER, my AS INTEGER
                IF mouseIsDown THEN
                    IF mouseDownX > 50 AND mouseDownX < 50 + _WIDTH(chatLogImage) AND mouseDownY > 50 AND mouseDownY < 50 + _HEIGHT(chatLogImage) THEN
                        'dragging the chat log
                        chatScroll = chatScroll - (mouseDownY - my)
                        mouseDownY = my
                    END IF
                END IF

                CONST messageSpeed = 1.5
                char$ = INKEY$
                SELECT CASE char$
                    CASE CHR$(22) 'ctrl+v
                        myMessage$ = myMessage$ + _CLIPBOARD$
                    CASE " " TO "z"
                        myMessage$ = myMessage$ + char$
                    CASE CHR$(8)
                        IF LEN(myMessage$) THEN
                            myMessage$ = LEFT$(myMessage$, LEN(myMessage$) - 1)
                        END IF
                    CASE CHR$(13)
                        DIM lastSentChat AS SINGLE
                        IF myMessage$ = ">reset" THEN
                            player(me).size = 15
                            sendData server, id_SIZE, MKI$(player(me).size)
                            myMessage$ = ""
                            chatOpen = False
                        ELSEIF myMessage$ = ">big" THEN
                            player(me).size = 25
                            sendData server, id_SIZE, MKI$(player(me).size)
                            myMessage$ = ""
                            chatOpen = False
                        ELSEIF myMessage$ = ">quit" THEN
                            IF mode = mode_onlineclient OR server.handle <> 0 THEN sendData server, id_PLAYERQUIT, ""
                            CLOSE server.handle
                            server.handle = 0
                            EXIT DO
                        ELSEIF myMessage$ = ">updateserver" THEN
                            'temporary solution for triggering auto-update checks
                            sendData server, id_UPDATESERVER, ""
                            myMessage$ = ""
                            chatOpen = False
                        ELSE
                            IF LEN(myMessage$) > 0 THEN 'AND timeElapsedSince(lastSentChat) > messageSpeed THEN
                                lastSentChat = TIMER
                                addMessageToChat me, myMessage$
                                sendData server, id_CHAT, myMessage$
                                myMessage$ = ""
                                'ELSEIF LEN(myMessage$) > 0 AND timeElapsedSince(lastSentChat) < messageSpeed THEN
                                '    tooFast = True
                            END IF
                        END IF
                END SELECT

                COLOR _RGB32(0)
                _PRINTSTRING (61, _HEIGHT - 61 - _FONTHEIGHT * 1.5), "> " + myMessage$ + cursorBlink
                COLOR _RGB32(255)
                _PRINTSTRING (60, _HEIGHT - 60 - _FONTHEIGHT * 1.5), "> " + myMessage$ + cursorBlink
                _FONT 8

                IF tooFast THEN
                    DIM s AS INTEGER
                    s = _CEIL(messageSpeed - (timeElapsedSince(lastSentChat)))
                    m$ = "(too fast - wait" + STR$(s) + " second" + LEFT$("s", ABS(s > 1)) + ")"
                    y = _HEIGHT - 50 - _FONTHEIGHT
                    COLOR _RGB32(0)
                    _PRINTSTRING (61, 1 + y), m$
                    COLOR _RGB32(200, 177, 44)
                    _PRINTSTRING (60, y), m$
                    IF timeElapsedSince(lastSentChat) > messageSpeed THEN tooFast = False
                END IF
            ELSE
                char$ = INKEY$
                SELECT CASE char$
                    CASE CHR$(13)
                        chatOpen = True
                END SELECT
            END IF
        END IF

        IF errorDialog.state THEN
            _FONT 16
            showError
            _FONT 8
        END IF

        uiCheck
        IF uiClicked THEN
            SELECT CASE ui(mouseDownOn).name
                CASE "messageicon"
                    IF mode = mode_onlineclient OR server.handle <> 0 THEN chatOpen = NOT chatOpen
            END SELECT
            uiClicked = False
        END IF

        IF mode = mode_onlineclient OR server.handle <> 0 THEN
            _FONT 16
            printOutline 0, 0, "Score:" + STR$(score), _RGB32(255), _RGB32(0)
            _FONT 8
        END IF

        _DISPLAY
        _LIMIT 60
    LOOP
    CLOSE
LOOP

SUB addMessageToChat (id AS INTEGER, text$)
    DIM i AS INTEGER
    IF id > 0 THEN
        FOR i = 2 TO UBOUND(chat)
            SWAP chat(i), chat(i - 1)
        NEXT
        chat(UBOUND(chat)).id = id
        chat(UBOUND(chat)).state = True
        chat(UBOUND(chat)).name = player(id).name
        chat(UBOUND(chat)).color = player(id).color
        chat(UBOUND(chat)).text = text$
    ELSE
        setError text$, 4
        'chat(UBOUND(chat)).name = "SYSTEM:"
        'chat(UBOUND(chat)).color = 7
        'chatOpen = True
    END IF
END SUB

SUB addWarning (text$)
    DIM i AS INTEGER
    FOR i = 1 TO UBOUND(warning)
        IF warning(i).state = False THEN
            warning(i).state = True
            warning(i).name = text$
            warning(i).ping = TIMER
            EXIT FOR
        END IF
    NEXT
END SUB

SUB sendData (client AS object, id AS INTEGER, value$)
    DIM packet$
    packet$ = MKI$(id) + value$ + endSignal
    IF client.handle THEN PUT #client.handle, , packet$
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

SUB adjustCamera
    IF player(me).x + camera.x > _WIDTH / 2 + cameraWindow THEN
        camera.x = _WIDTH / 2 - player(me).x + cameraWindow
    ELSEIF player(me).x + camera.x < _WIDTH / 2 - cameraWindow THEN
        camera.x = _WIDTH / 2 - player(me).x - cameraWindow
    END IF
    IF camera.x > 0 THEN camera.x = 0
    IF camera.x < -(_WIDTH(mapImage) - _WIDTH) THEN camera.x = -(_WIDTH(mapImage) - _WIDTH)

    IF player(me).y + camera.y > _HEIGHT / 2 + cameraWindow THEN
        camera.y = _HEIGHT / 2 - player(me).y + cameraWindow
    ELSEIF player(me).y + camera.y < _HEIGHT / 2 - cameraWindow THEN
        camera.y = _HEIGHT / 2 - player(me).y - cameraWindow
    END IF
    IF camera.y > 0 THEN camera.y = 0
    IF camera.y < -(_HEIGHT(mapImage) - _HEIGHT) THEN camera.y = -(_HEIGHT(mapImage) - _HEIGHT)
END SUB


SUB CircleFill (CX AS INTEGER, CY AS INTEGER, R AS INTEGER, C AS _UNSIGNED LONG)
    ' CX = center x coordinate
    ' CY = center y coordinate
    '  R = radius
    '  C = fill color
    DIM Radius AS INTEGER, RadiusError AS INTEGER
    DIM X AS INTEGER, Y AS INTEGER
    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0
    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB
    LINE (CX - X, CY)-(CX + X, CY), C, BF
    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    WEND
END SUB

SUB db (text$)
    $IF DEBUGGING = TRUE THEN
        _ECHO text$
    $ELSE
        DIM dummy$
        dummy$ = text$
    $END IF
END SUB

FUNCTION dist! (x1!, y1!, x2!, y2!)
    dist! = _HYPOT((x2! - x1!), (y2! - y1!))
END FUNCTION

SUB thickLine (x1 AS SINGLE, y1 AS SINGLE, x2 AS SINGLE, y2 AS SINGLE, lineWeight%, c~&)
    DIM a AS SINGLE, x0 AS SINGLE, y0 AS SINGLE
    DIM prevDest AS LONG
    DIM colorSample AS LONG

    colorSample = _NEWIMAGE(1, 1, 32)

    prevDest = _DEST
    _DEST colorSample
    PSET (0, 0), c~&
    _DEST prevDest

    a = _ATAN2(y2 - y1, x2 - x1)
    a = a + _PI / 2
    x0 = 0.5 * lineWeight% * COS(a)
    y0 = 0.5 * lineWeight% * SIN(a)

    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, 0)-(0, 0), colorSample TO(x1 - x0, y1 - y0)-(x1 + x0, y1 + y0)-(x2 + x0, y2 + y0), , _SMOOTH
    _MAPTRIANGLE _SEAMLESS(0, 0)-(0, 0)-(0, 0), colorSample TO(x1 - x0, y1 - y0)-(x2 + x0, y2 + y0)-(x2 - x0, y2 - y0), , _SMOOTH

    _FREEIMAGE colorSample
END SUB

SUB addParticles (kind$, x AS SINGLE, y AS SINGLE, xv AS SINGLE, yv AS SINGLE, size AS INTEGER, total AS INTEGER, duration AS SINGLE, c AS _UNSIGNED LONG, delay AS SINGLE)
    DIM addedP AS INTEGER, p AS INTEGER
    DIM a AS SINGLE

    addedP = 0: p = 0
    DO
        p = p + 1
        IF p > UBOUND(particle) THEN EXIT DO
        IF particle(p).state = True THEN _CONTINUE
        addedP = addedP + 1
        particle(p).state = True
        particle(p).x = x
        particle(p).y = y
        particle(p).r = _RED32(c)
        particle(p).g = _GREEN32(c)
        particle(p).b = _BLUE32(c)
        particle(p).start = TIMER
        IF duration THEN
            particle(p).duration = duration
        ELSE
            particle(p).duration = RND
        END IF
        particle(p).delay = delay

        SELECT CASE kind$
            CASE "explosion"
                a = RND * _PI(2)
                particle(p).xv = COS(a) * (RND * 10)
                particle(p).yv = SIN(a) * (RND * 10)
                particle(p).size = _CEIL(RND * 3)
                particle(p).gravity = .1
            CASE "projectile"
                particle(p).xv = xv
                particle(p).yv = yv
                particle(p).size = size
                particle(p).gravity = 0
        END SELECT
    LOOP UNTIL addedP >= total
END SUB

SUB updateParticles
    DIM i AS INTEGER

    FOR i = 1 TO UBOUND(particle)
        IF particle(i).state AND (timeElapsedSince(particle(i).start) >= particle(i).delay) THEN
            particle(i).xv = particle(i).xv + particle(i).xa
            particle(i).x = particle(i).x + particle(i).xv
            particle(i).yv = particle(i).yv + particle(i).ya + particle(i).gravity
            particle(i).y = particle(i).y + particle(i).yv

            IF particle(i).x > _WIDTH(mapImage) OR particle(i).x < 0 OR particle(i).y > _HEIGHT(mapImage) OR particle(i).y < 0 THEN
                particle(i).state = False
            ELSE
                CircleFill particle(i).x + camera.x, particle(i).y + camera.y, particle(i).size, _RGB32(particle(i).r, particle(i).g, particle(i).b, map(timeElapsedSince(particle(i).start), 0, particle(i).duration, 255, 0))
            END IF
        END IF
    NEXT
END SUB

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION


SUB generateImages
    DIM i AS LONG, j AS LONG
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, c AS _UNSIGNED LONG
    DIM red AS INTEGER, green AS INTEGER, blue AS INTEGER, alpha AS INTEGER

    mapImage = _NEWIMAGE(windowWidth * 4, windowHeight * 3, 32)
    _DEST mapImage
    RANDOMIZE 6
    FOR i = 1 TO 15
        x = RND * _WIDTH
        y = RND * _HEIGHT
        r = RND * 1000
        red = RND * 255
        green = RND * 255
        blue = RND * 255
        alpha = RND * 150
        c = _RGB32(red, green, blue, alpha)
        CircleFill x, y, r, c
    NEXT
    _DEST 0

    settingsScreenImage = _NEWIMAGE(windowWidth, windowHeight, 32)
    _DEST settingsScreenImage
    FOR i = 1 TO 10
        x = RND * _WIDTH
        y = RND * _HEIGHT
        r = RND * _WIDTH
        alpha = RND * 150
        c = _RGB32(50, alpha)
        CircleFill x, y, r, c
    NEXT
    _DEST 0

    worldMapImage = _NEWIMAGE(800, 351, 32)
    _DEST worldMapImage
    RESTORE worldMapData
    READ j
    FOR i = 1 TO j
        READ x, y
        CircleFill x, y, 1, _RGB32(0, 177, 0)
    NEXT
    FOR i = 0 TO _HEIGHT STEP 3
        LINE (3, i)-(_WIDTH - 4, i), _RGB32(0, 139, 0, 100)
    NEXT
    _DEST 0

    scanLinesImage = _NEWIMAGE(500, 60, 32)
    _DEST scanLinesImage
    FOR i = 0 TO _HEIGHT / 2
        LINE (3, i)-(_WIDTH - 4, i), _RGB32(0, 139, 0, map(i, 0, _HEIGHT / 2, 0, 127))
    NEXT
    FOR i = _HEIGHT / 2 + 1 TO _HEIGHT
        LINE (3, i)-(_WIDTH - 4, i), _RGB32(0, 139, 0, map(i, _HEIGHT / 2 + 1, _HEIGHT, 127, 0))
    NEXT
    _DEST 0

    dialogImage = _NEWIMAGE(500, 100, 32)
    _DEST dialogImage
    LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(0, 180), BF
    LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), _RGB32(0, 139, 0), B
    LINE (2, 2)-(_WIDTH - 3, _HEIGHT - 3), _RGB32(0, 139, 0), B
    FOR i = 4 TO _HEIGHT - 5 STEP 3
        LINE (3, i)-(_WIDTH - 4, i), _RGB32(0, 139, 0, 60)
    NEXT
    _DEST 0

    messageIcon = _NEWIMAGE(32, 32, 32)
    _DEST messageIcon
    LINE (0, 0)-(31, 31), _RGB32(0), BF
    LINE (4, 4)-(27, 27), _RGB32(200), BF
    FOR i = 8 TO 23 STEP 5
        LINE (5, i)-(25, i), _RGB32(0)
    NEXT
    _DEST 0

    worldMapData:
    DATA 1075
    DATA 251,6,276,6,279,6,287,6,302,6,336,6,212,12,213,12,215,12,216,12,220,12,221,12
    DATA 223,12,224,12,227,12,239,12,240,12,263,12,271,12,339,12,397,12,398,12,430,12,438,12
    DATA 441,12,457,12,458,12,461,12,479,12,481,12,500,12,507,12,181,18,191,18,205,18,207,18
    DATA 208,18,215,18,220,18,221,18,222,18,226,18,232,18,236,18,239,18,244,18,259,18,335,18
    DATA 386,18,395,18,398,18,404,18,511,18,512,18,519,18,529,18,531,18,538,18,165,24,179,24
    DATA 192,24,194,24,203,24,208,24,211,24,218,24,222,24,227,24,230,24,235,24,236,24,239,24
    DATA 275,24,328,24,454,24,461,24,495,24,538,24,541,24,547,24,553,24,555,24,592,24,595,24
    DATA 96,30,97,30,99,30,112,30,113,30,114,30,168,30,192,30,203,30,210,30,217,30,246,30
    DATA 274,30,277,30,278,30,322,30,324,30,328,30,403,30,408,30,409,30,414,30,453,30,460,30
    DATA 475,30,486,30,487,30,623,30,626,30,630,30,662,30,668,30,79,36,166,36,171,36,175,36
    DATA 179,36,188,36,191,36,195,36,196,36,197,36,199,36,212,36,215,36,223,36,232,36,236,36
    DATA 238,36,250,36,272,36,307,36,390,36,433,36,439,36,444,36,448,36,489,36,492,36,679,36
    DATA 67,42,207,42,208,42,210,42,211,42,215,42,224,42,245,42,250,42,251,42,272,42,291,42
    DATA 323,42,339,42,385,42,402,42,407,42,425,42,426,42,428,42,429,42,431,42,435,42,683,42
    DATA 687,42,688,42,689,42,697,42,61,48,149,48,151,48,195,48,209,48,214,48,222,48,223,48
    DATA 224,48,225,48,236,48,242,48,272,48,286,48,351,48,354,48,375,48,395,48,401,48,689,48
    DATA 59,54,76,54,77,54,81,54,99,54,185,54,217,54,233,54,240,54,242,54,373,54,401,54
    DATA 413,54,414,54,415,54,651,54,664,54,671,54,57,60,62,60,66,60,71,60,102,60,186,60
    DATA 215,60,243,60,349,60,357,60,380,60,382,60,385,60,393,60,395,60,397,60,403,60,407,60
    DATA 408,60,629,60,662,60,674,60,30,66,35,66,36,66,37,66,106,66,201,66,207,66,248,66
    DATA 345,66,353,66,354,66,359,66,378,66,382,66,387,66,388,66,396,66,397,66,401,66,627,66
    DATA 665,66,678,66,682,66,684,66,685,66,687,66,105,72,163,72,164,72,198,72,204,72,250,72
    DATA 341,72,349,72,352,72,365,72,370,72,642,72,644,72,646,72,672,72,677,72,712,72,714,72
    DATA 102,78,107,78,108,78,224,78,230,78,233,78,244,78,248,78,356,78,358,78,363,78,647,78
    DATA 649,78,654,78,674,78,676,78,103,84,172,84,176,84,179,84,185,84,226,84,227,84,228,84
    DATA 233,84,235,84,243,84,245,84,246,84,252,84,354,84,647,84,652,84,656,84,675,84,676,84
    DATA 100,90,176,90,180,90,186,90,189,90,190,90,192,90,219,90,221,90,231,90,246,90,247,90
    DATA 357,90,385,90,388,90,422,90,430,90,435,90,438,90,459,90,467,90,484,90,487,90,647,90
    DATA 656,90,659,90,670,90,674,90,95,96,173,96,174,96,175,96,176,96,187,96,190,96,209,96
    DATA 340,96,366,96,378,96,380,96,383,96,390,96,399,96,420,96,448,96,462,96,470,96,639,96
    DATA 657,96,665,96,90,102,91,102,92,102,201,102,289,102,290,102,292,102,295,102,340,102
    DATA 360,102,367,102,369,102,377,102,381,102,392,102,400,102,401,102,408,102,409,102,411,102
    DATA 414,102,415,102,416,102,467,102,473,102,619,102,622,102,638,102,660,102,665,102,93,108
    DATA 195,108,340,108,358,108,387,108,393,108,404,108,409,108,410,108,415,108,417,108,466,108
    DATA 477,108,617,108,631,108,641,108,662,108,666,108,93,114,191,114,317,114,318,114,346,114
    DATA 349,114,357,114,384,114,390,114,391,114,410,114,412,114,431,114,435,114,437,114,622,114
    DATA 637,114,644,114,652,114,667,114,98,120,182,120,214,120,216,120,339,120,387,120,437,120
    DATA 626,120,640,120,641,120,646,120,658,120,98,126,101,126,105,126,176,126,336,126,399,126
    DATA 403,126,631,126,672,126,673,126,101,132,104,132,107,132,141,132,172,132,177,132,312,132
    DATA 314,132,316,132,318,132,320,132,321,132,323,132,325,132,332,132,433,132,434,132,468,132
    DATA 474,132,632,132,673,132,674,132,103,138,106,138,110,138,137,138,173,138,176,138,181,138
    DATA 182,138,326,138,437,138,441,138,471,138,472,138,474,138,482,138,484,138,485,138,487,138
    DATA 488,138,630,138,5,144,6,144,105,144,108,144,114,144,135,144,186,144,187,144,322,144
    DATA 440,144,445,144,491,144,513,144,627,144,632,144,636,144,11,150,14,150,116,150,136,150
    DATA 152,150,159,150,167,150,169,150,176,150,184,150,193,150,197,150,319,150,443,150,448,150
    DATA 494,150,517,150,558,150,562,150,564,150,567,150,568,150,569,150,604,150,608,150,613,150
    DATA 91,156,92,156,118,156,138,156,147,156,156,156,160,156,161,156,177,156,178,156,182,156
    DATA 183,156,186,156,188,156,190,156,200,156,208,156,209,156,321,156,445,156,449,156,450,156
    DATA 452,156,490,156,525,156,554,156,572,156,602,156,608,156,612,156,614,156,615,156,99,162
    DATA 100,162,128,162,154,162,155,162,157,162,162,162,163,162,167,162,168,162,216,162,218,162
    DATA 219,162,220,162,306,162,307,162,320,162,448,162,453,162,454,162,457,162,481,162,527,162
    DATA 548,162,577,162,607,162,635,162,641,162,145,168,164,168,193,168,194,168,217,168,218,168
    DATA 319,168,454,168,457,168,472,168,481,168,482,168,530,168,544,168,584,168,611,168,637,168
    DATA 641,168,690,168,693,168,156,174,159,174,160,174,164,174,188,174,192,174,194,174,196,174
    DATA 198,174,199,174,213,174,214,174,215,174,216,174,270,174,271,174,320,174,458,174,461,174
    DATA 462,174,475,174,477,174,481,174,482,174,532,174,543,174,575,174,577,174,584,174,585,174
    DATA 587,174,590,174,593,174,594,174,596,174,612,174,636,174,637,174,642,174,643,174,644,174
    DATA 646,174,647,174,650,174,161,180,166,180,168,180,169,180,173,180,174,180,181,180,190,180
    DATA 192,180,214,180,220,180,221,180,222,180,223,180,326,180,476,180,535,180,542,180,544,180
    DATA 546,180,584,180,585,180,586,180,589,180,602,180,606,180,633,180,635,180,643,180,651,180
    DATA 707,180,708,180,109,186,110,186,176,186,221,186,329,186,473,186,475,186,476,186,523,186
    DATA 524,186,541,186,542,186,544,186,549,186,579,186,581,186,590,186,593,186,629,186,630,186
    DATA 642,186,644,186,646,186,653,186,670,186,672,186,724,186,727,186,758,186,760,186,177,192
    DATA 236,192,337,192,344,192,370,192,470,192,523,192,525,192,580,192,586,192,592,192,599,192
    DATA 624,192,636,192,174,198,239,198,380,198,466,198,522,198,525,198,581,198,583,198,586,198
    DATA 593,198,594,198,601,198,613,198,614,198,618,198,633,198,656,198,659,198,9,204,10,204
    DATA 15,204,16,204,147,204,148,204,170,204,243,204,247,204,248,204,376,204,377,204,379,204
    DATA 433,204,437,204,459,204,461,204,462,204,522,204,524,204,589,204,599,204,612,204,633,204
    DATA 637,204,640,204,645,204,648,204,655,204,658,204,663,204,665,204,62,210,63,210,169,210
    DATA 254,210,255,210,256,210,301,210,302,210,380,210,454,210,591,210,592,210,594,210,603,210
    DATA 604,210,606,210,615,210,630,210,631,210,632,210,636,210,643,210,652,210,653,210,666,210
    DATA 672,210,675,210,685,210,699,210,701,210,168,216,270,216,274,216,275,216,276,216,277,216
    DATA 385,216,425,216,426,216,450,216,598,216,606,216,612,216,613,216,621,216,622,216,636,216
    DATA 639,216,641,216,645,216,675,216,698,216,712,216,715,216,172,222,277,222,279,222,280,222
    DATA 387,222,427,222,428,222,449,222,603,222,613,222,614,222,621,222,633,222,634,222,681,222
    DATA 703,222,708,222,709,222,717,222,720,222,721,222,723,222,174,228,275,228,388,228,450,228
    DATA 482,228,483,228,624,228,625,228,637,228,638,228,646,228,651,228,653,228,654,228,688,228
    DATA 691,228,699,228,705,228,729,228,731,228,734,228,735,228,774,228,775,228,177,234,271,234
    DATA 389,234,437,234,438,234,452,234,661,234,668,234,688,234,690,234,713,234,716,234,728,234
    DATA 729,234,181,240,268,240,386,240,453,240,461,240,463,240,469,240,474,240,642,240,643,240
    DATA 650,240,653,240,655,240,656,240,658,240,672,240,684,240,685,240,686,240,693,240,791,240
    DATA 795,240,189,246,268,246,344,246,346,246,385,246,450,246,460,246,473,246,474,246,475,246
    DATA 501,246,502,246,641,246,642,246,644,246,676,246,677,246,678,246,684,246,695,246,744,246
    DATA 747,246,788,246,789,246,196,252,267,252,386,252,442,252,459,252,471,252,635,252,636,252
    DATA 638,252,695,252,733,252,734,252,746,252,747,252,193,258,194,258,197,258,265,258,390,258
    DATA 438,258,458,258,469,258,485,258,487,258,625,258,700,258,735,258,738,258,739,258,740,258
    DATA 741,258,743,258,197,264,256,264,391,264,440,264,457,264,468,264,617,264,703,264,198,270
    DATA 248,270,392,270,433,270,467,270,468,270,617,270,706,270,197,276,248,276,249,276,250,276
    DATA 394,276,433,276,458,276,459,276,462,276,463,276,616,276,705,276,198,282,247,282,397,282
    DATA 427,282,617,282,702,282,199,288,242,288,399,288,421,288,616,288,638,288,656,288,698,288
    DATA 737,288,738,288,199,294,233,294,658,294,659,294,660,294,692,294,740,294,743,294,746,294
    DATA 747,294,199,300,235,300,665,300,687,300,738,300,739,300,740,300,744,300,200,306,226,306
    DATA 480,306,481,306,669,306,670,306,735,306,742,306,205,312,223,312,669,312,676,312,724,312
    DATA 731,312,96,318,97,318,206,318,221,318,389,318,390,318,711,318,721,318,207,324,223,324
    DATA 536,324,538,324,707,324,709,324,209,330,223,330,215,336,223,336,238,336,242,336,222,342
END SUB

SUB restoreColors
    DIM i AS INTEGER

    playerColorPalette:
    DATA 195,17,16,Red
    DATA 14,51,196,Blue
    DATA 18,125,46,Green
    DATA 236,84,187,Pink
    DATA 239,125,17,Orange
    DATA 248,245,91,Yellow
    DATA 62,71,77,Black
    DATA 216,225,241,White
    DATA 107,48,187,Purple
    DATA 112,73,28,Brown
    DATA 93,250,220,Cyan
    DATA 79,240,58,Lime

    RESTORE playerColorPalette
    FOR i = 1 TO UBOUND(colors)
        READ r%, g%, b%, colors(i).name
        colors(i).value = _RGB32(r%, g%, b%)
    NEXT
END SUB

SUB readServerList
    RESTORE serverList
    DIM i AS INTEGER
    READ i
    REDIM serverList(1 TO i) AS object
    FOR i = 1 TO i
        READ serverList(i).text, serverList(i).name, serverList(i).x, serverList(i).y
    NEXT

    serverList:
    DATA 3
    DATA spriggsyspriggs.ddns.net,North America,145,105
    DATA alephc.xyz,Australia,662,270
    DATA 187.94.219.178,Brazil,240,233
END SUB

SUB intro

END SUB

SUB settingsScreen
    DIM i AS LONG
    DIM x AS INTEGER, y AS INTEGER
    DIM item AS LONG, itemX AS INTEGER, itemY AS INTEGER
    DIM text AS STRING
    DIM dummyPlayer AS object
    DIM attemptingToConnect AS _BYTE, handshaking AS _BYTE
    DIM id AS INTEGER, value$
    DIM attempt AS INTEGER

    GOSUB setUi
    CONST maxAttempts = 5
    CONST mapX = 0, mapY = 240

    DO
        IF attemptingToConnect = False AND handshaking = False AND errorDialog.state = False THEN
            uiCheck
        END IF

        DIM shipFlotation AS SINGLE, shipFloatAmplitude AS SINGLE
        shipFlotation = shipFlotation + .05
        IF shipFlotation > _PI(2) THEN shipFlotation = shipFlotation - _PI(2)
        shipFloatAmplitude = 1.5

        _DONTBLEND
        _PUTIMAGE (COS(shipFlotation) * shipFloatAmplitude, SIN(shipFlotation) * shipFloatAmplitude), settingsScreenImage
        _BLEND

        x = dummyPlayer.x + COS(shipFlotation) * shipFloatAmplitude
        y = dummyPlayer.y + SIN(shipFlotation) * shipFloatAmplitude
        CircleFill x, y + 6, dummyPlayer.size + 5, _RGB32(0, 50)
        CircleFill x, y, dummyPlayer.size + 5, _RGB32(0)
        CircleFill x, y, dummyPlayer.size, colors(dummyPlayer.color).value
        text = dummyPlayer.name

        _FONT 8
        COLOR _RGB32(0)
        _PRINTSTRING (1 + x - _PRINTWIDTH(text) / 2, 1 + y - 25), text + cursorBlink
        COLOR _RGB32(255)
        _PRINTSTRING (x - _PRINTWIDTH(text) / 2, y - 25), text + cursorBlink
        _FONT 16

        FOR i = 1 TO UBOUND(colors)
            IF dummyPlayer.color = i THEN
                ui(i + 1).text = "*"
            ELSE
                ui(i + 1).text = ""
            END IF
        NEXT

        DIM targetAnimation AS SINGLE
        targetAnimation = targetAnimation + .25
        IF targetAnimation > 25 THEN targetAnimation = 0

        FOR i = 1 TO UBOUND(serverlist)
            x = serverList(i).x + mapX
            y = serverList(i).y + mapY
            CircleFill x, y, 5 + targetAnimation, _RGB32(255, 0, 0, map(targetAnimation, 0, 25, 255, 0))
        NEXT

        uiDisplay

        _PUTIMAGE (mapX, mapY), worldMapImage

        COLOR _RGB32(255)

        IF uiClicked THEN
            SELECT CASE LEFT$(ui(mouseDownOn).name, INSTR(ui(mouseDownOn).name, ".") - 1)
                CASE "color"
                    dummyPlayer.color = CVI(RIGHT$(ui(mouseDownOn).name, 2))
                CASE "freeplay"
                    mode = mode_freeplay
                    userName$ = dummyPlayer.name
                    IF userName$ = "" THEN userName$ = "Player"
                    userColor% = dummyPlayer.color
                    chosenServer$ = "localhost"
                    attempt = 0
                    attemptingToConnect = True
                CASE "server"
                    mode = mode_onlineclient
                    userName$ = dummyPlayer.name
                    IF userName$ = "" THEN userName$ = "Player"
                    userColor% = dummyPlayer.color
                    chosenServer$ = serverList(CVI(RIGHT$(ui(mouseDownOn).name, 2))).text
                    attempt = 0
                    attemptingToConnect = True
            END SELECT
            uiClicked = False
        END IF

        IF attemptingToConnect THEN
            attempt = attempt + 1
            dialog "Attempting to connect to server..."
            IF attempt = 1 THEN _DISPLAY

            server.handle = 0
            server.handle = _OPENCLIENT("TCP/IP:51512:" + chosenServer$)

            IF server.handle THEN
                serverStream = ""
                attemptingToConnect = False
                handshaking = True
                serverPing = TIMER
            ELSE
                IF attempt >= maxAttempts THEN
                    attemptingToConnect = False
                    IF mode = mode_freeplay THEN
                        setError "Failed to connect to server. You're in free play mode.", 3
                        EXIT SUB
                    ELSE
                        setError "Failed to connect to server. Try again later (or chose another).", 2
                        mode = 0
                    END IF
                END IF
            END IF
        ELSEIF handshaking THEN
            progressDialog "Connected! Handshaking...", timeElapsedSince(serverPing), 10
            getData server, serverStream
            WHILE parse(serverStream, id, value$)
                SELECT CASE id
                    CASE id_SERVERFULL
                        setError "Server full.", 2
                        handshaking = False
                        CLOSE server.handle
                        server.handle = 0
                    CASE id_GAMEVERSION
                        IF CVI(value$) <> gameVersion THEN
                            setError "Server version incompatible.", 2
                            sendData server, id_GAMEVERSION, ""
                            sendData server, id_PLAYERQUIT, ""
                            CLOSE server.handle
                            server.handle = 0
                            handshaking = False
                        ELSE
                            EXIT SUB
                        END IF
                END SELECT
            WEND
            IF timeElapsedSince(serverPing) > 10 THEN
                IF mode = mode_freeplay THEN
                    setError "No response from server. You're in free play mode.", 3
                    EXIT SUB
                ELSE
                    setError "No response from server.", 2
                    mode = 0
                END IF
                handshaking = False
            END IF
        ELSEIF errorDialog.state THEN
            showError
        ELSE
            'only get input if no dialog is being presented
            DIM char$
            char$ = INKEY$
            SELECT CASE char$
                CASE " " TO "z"
                    IF LEN(dummyPlayer.name) < 20 THEN dummyPlayer.name = dummyPlayer.name + char$
                CASE CHR$(8)
                    IF LEN(dummyPlayer.name) THEN
                        dummyPlayer.name = LEFT$(dummyPlayer.name, LEN(dummyPlayer.name) - 1)
                    END IF
                CASE CHR$(27)
                    dummyPlayer.name = ""
            END SELECT
        END IF

        exitSign = _EXIT
        IF exitSign THEN
            SYSTEM
        END IF

        _DISPLAY
        _LIMIT 60
    LOOP

    EXIT SUB

    setUi:
    uiReset

    'color picker
    CONST colorPickerSquareSize = 35
    itemX = 200
    itemY = 50

    item = addUiItem("colorpickerframe", itemX - 4, itemY - 4, colorPickerSquareSize * 3 + 8, colorPickerSquareSize * 4 + 8)
    ui(item).color = _RGB32(50)

    y = 1
    x = 0
    FOR i = 1 TO UBOUND(colors)
        x = x + 1
        IF x = 4 THEN y = y + 1: x = 1
        item = addUiItem("color." + LCASE$(colors(i).name) + "." + MKI$(i), itemX + (colorPickerSquareSize * (x - 1)), itemY + (colorPickerSquareSize * (y - 1)), colorPickerSquareSize - 2, colorPickerSquareSize - 2)
        ui(item).color = colors(i).value
        ui(item).fgColor = _RGB32(255)
        ui(item).state = True
    NEXT

    'server locations
    CONST mapLocationsPickerSize = 16
    FOR i = 1 TO UBOUND(serverlist)
        itemX = mapX + serverList(i).x - mapLocationsPickerSize / 2
        itemY = mapY + serverList(i).y - mapLocationsPickerSize / 2
        item = addUiItem("server." + LCASE$(serverList(i).name) + "." + MKI$(i), itemX, itemY, mapLocationsPickerSize, mapLocationsPickerSize)
        ui(item).color = _RGB32(105, 200, 50)
        ui(item).state = True
    NEXT

    'interface
    itemY = _FONTHEIGHT
    item = addUiItem("titleseparator", 0, itemY, _WIDTH, 2)
    ui(item).color = _RGB32(200)
    ui(item).fgColor = _RGB32(0)

    item = addUiItem("titlelabel", 0, 0, 0, 0)
    ui(item).text = "AMONGST... WHO IS THE IMPOSTOR?"
    ui(item).w = _PRINTWIDTH(ui(item).text) + 30
    ui(item).h = _FONTHEIGHT * 2
    ui(item).x = (_WIDTH - ui(item).w) / 2
    ui(item).y = itemY - _FONTHEIGHT
    ui(item).color = _RGB32(200)
    ui(item).fgColor = _RGB32(0)

    itemX = 500
    itemY = 100
    text$ = "Free Play - local host"
    item = addUiItem("freeplay.", itemX, itemY, _PRINTWIDTH(text$) + 30, _FONTHEIGHT * 2)
    ui(item).text = text$
    ui(item).color = _RGB32(200)
    ui(item).fgColor = _RGB32(0)
    ui(item).state = True

    itemY = 220 - _FONTHEIGHT
    item = addUiItem("mapseparator", 0, itemY + _FONTHEIGHT, _WIDTH, 2)
    ui(item).color = _RGB32(200)
    ui(item).fgColor = _RGB32(0)

    item = addUiItem("serverlabel", 0, 0, 0, 0)
    ui(item).text = "Play online - Choose a server"
    ui(item).w = _PRINTWIDTH(ui(item).text) + 30
    ui(item).h = _FONTHEIGHT * 2
    ui(item).x = (_WIDTH - ui(item).w) / 2
    ui(item).y = itemY
    ui(item).color = _RGB32(200)
    ui(item).fgColor = _RGB32(0)

    dummyPlayer.x = 100
    dummyPlayer.y = 120
    dummyPlayer.size = 15
    IF userColor% > 0 THEN dummyPlayer.color = userColor% ELSE dummyPlayer.color = 1
    IF LEN(COMMAND$) = 0 THEN dummyPlayer.name = "Player 1" ELSE dummyPlayer.name = COMMAND$
    IF LEN(userName$) > 0 THEN dummyPlayer.name = userName$
    RETURN
END SUB

SUB uiCheck
    DIM i AS INTEGER

    mouseWheel = 0
    IF _MOUSEINPUT THEN
        mouseWheel = mouseWheel + _MOUSEWHEEL
        IF _MOUSEBUTTON(1) = mb1 AND _MOUSEBUTTON(2) = mb2 THEN
            DO WHILE _MOUSEINPUT
                mouseWheel = mouseWheel + _MOUSEWHEEL
                IF NOT (_MOUSEBUTTON(1) = mb1 AND _MOUSEBUTTON(2) = mb2) THEN EXIT DO
            LOOP
        END IF
        mb1 = _MOUSEBUTTON(1)
        mb2 = _MOUSEBUTTON(2)
        mx = _MOUSEX
        my = _MOUSEY
    END IF

    focus = 0
    FOR i = UBOUND(ui) TO 1 STEP -1
        IF ui(i).state AND mx > ui(i).x AND mx < ui(i).x + ui(i).w AND my > ui(i).y AND my < ui(i).y + ui(i).h THEN
            focus = i
            EXIT FOR
        END IF
    NEXT

    IF mb1 THEN
        uiClicked = False
        IF NOT mouseIsDown THEN
            mouseDownOn = focus
            mouseIsDown = True
            mouseDownX = mx
            mouseDownY = my
        END IF
    ELSE
        IF mouseIsDown THEN
            IF mouseDownOn THEN
                uiClicked = True
            END IF
        END IF
        mouseIsDown = False
    END IF

END SUB

SUB uiDisplay
    DIM i AS INTEGER, x AS INTEGER, y AS INTEGER
    DIM tempColor AS _UNSIGNED LONG

    CONST hoverIntensity = 30

    FOR i = 1 TO UBOUND(ui)
        IF i = focus THEN _CONTINUE 'draw focused clickable control last
        GOSUB drawIt
    NEXT

    IF focus THEN
        IF ui(focus).state THEN
            i = focus
            GOSUB drawIt
        END IF
    END IF
    EXIT SUB

    drawIt:
    'shadow
    IF ui(i).state THEN
        x = ui(i).x + 4
        y = ui(i).y + 4
        LINE (x, y)-STEP(ui(i).w - 1 + (ABS(i = focus) * 4), ui(i).h - 1 + (ABS(i = focus) * 4)), _RGB32(0, 50), BF
    END IF

    'surface
    IF i = focus AND ui(i).state THEN
        tempColor = _RGB32(_RED32(ui(i).color) + hoverIntensity, _GREEN32(ui(i).color) + hoverIntensity, _BLUE32(ui(i).color) + hoverIntensity)
        LINE (ui(i).x - 2, ui(i).y - 2)-STEP(ui(i).w - 1 + 4, ui(i).h - 1 + 4), tempColor, BF
    ELSE
        LINE (ui(i).x, ui(i).y)-STEP(ui(i).w - 1, ui(i).h - 1), ui(i).color, BF
    END IF

    'custom image
    IF ui(i).handle < -1 THEN
        _PUTIMAGE (ui(i).x, ui(i).y), ui(i).handle
    END IF

    'caption
    IF LEN(ui(i).text) THEN
        x = ui(i).x + ((ui(i).w - _PRINTWIDTH(ui(i).text)) / 2)
        y = ui(i).y + ((ui(i).h - _FONTHEIGHT) / 2)
        IF i = focus AND ui(i).state THEN
            COLOR _RGB32(0, 50)
            _PRINTSTRING (x + 2, y + 2), ui(i).text
        END IF
        COLOR ui(i).fgColor
        _PRINTSTRING (x, y), ui(i).text
    END IF
    RETURN
END SUB

SUB uiReset
    REDIM ui(0) AS object
    uiClicked = False
    mouseDownOn = 0
    focus = 0
END SUB

FUNCTION addUiItem& (name$, x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
    DIM i AS LONG
    i = UBOUND(ui) + 1
    REDIM _PRESERVE ui(1 TO i) AS object
    ui(i).name = name$
    ui(i).handle = 0
    ui(i).x = x
    ui(i).y = y
    ui(i).w = w
    ui(i).h = h
    ui(i).state = False
    addUiItem = i
END FUNCTION

SUB progressDialog (text$, value AS LONG, max AS LONG)
    STATIC prevText$

    IF text$ <> prevText$ THEN
        prevText$ = text$
    END IF

    DIM x AS INTEGER, y AS INTEGER
    DIM percentage$

    drawDialogBox

    x = (_WIDTH - _PRINTWIDTH(text$)) / 2
    y = (_HEIGHT - _FONTHEIGHT) / 2 - _FONTHEIGHT / 2
    _PRINTSTRING (x, y), text$

    percentage$ = "[" + STRING$(map(value, 0, max, 0, 20), 254) + STRING$(map(value, 0, max, 20, 0), 250) + "] "
    x = (_WIDTH - _PRINTWIDTH(percentage$)) / 2
    y = (_HEIGHT - _FONTHEIGHT) / 2 + _FONTHEIGHT / 2
    _PRINTSTRING (x, y), percentage$
END SUB

SUB drawDialogBox
    STATIC scanY AS SINGLE

    CONST scanLinesSpeed = .5

    _PUTIMAGE ((_WIDTH - _WIDTH(dialogImage)) / 2, (_HEIGHT - _HEIGHT(dialogImage)) / 2), dialogImage

    scanY = scanY + scanLinesSpeed
    IF scanY > _HEIGHT(dialogImage) THEN scanY = -_HEIGHT(scanLinesImage)
    IF scanY < 0 THEN
        _PUTIMAGE ((_WIDTH - _WIDTH(dialogImage)) / 2, (_HEIGHT - _HEIGHT(dialogImage)) / 2), scanLinesImage, , (0, ABS(scanY))-STEP(_WIDTH(scanLinesImage) - 1, _HEIGHT(scanLinesImage) - 1)
    ELSEIF scanY > _HEIGHT(dialogImage) - _HEIGHT(scanLinesImage) THEN
        _PUTIMAGE ((_WIDTH - _WIDTH(dialogImage)) / 2, scanY + (_HEIGHT - _HEIGHT(dialogImage)) / 2), scanLinesImage, , (0, 0)-STEP(_WIDTH(scanLinesImage) - 1, _HEIGHT(dialogImage) - scanY)
    ELSE
        _PUTIMAGE ((_WIDTH - _WIDTH(dialogImage)) / 2, scanY + (_HEIGHT - _HEIGHT(dialogImage)) / 2), scanLinesImage
    END IF
END SUB

SUB dialog (__text$)
    CONST maxLines = 4

    STATIC prevText$
    STATIC lines$(1 TO maxLines), totalLines AS INTEGER
    DIM text$, i AS INTEGER
    DIM x AS INTEGER, y AS INTEGER

    text$ = StrReplace$(__text$, "\n", CHR$(10))
    IF text$ <> prevText$ THEN
        prevText$ = text$
        totalLines = 0
        x = INSTR(text$, CHR$(10))
        IF x THEN
            WHILE x
                totalLines = totalLines + 1
                IF totalLines > maxLines THEN totalLines = maxLines: EXIT WHILE
                lines$(totalLines) = LEFT$(text$, x - 1)
                text$ = MID$(text$, x + 1)
                x = INSTR(text$, CHR$(10))
            WEND
            IF x = 0 AND LEN(text$) > 0 AND totalLines < maxLines THEN
                totalLines = totalLines + 1
                lines$(totalLines) = text$
            END IF
        ELSE
            totalLines = 1
            lines$(1) = text$
        END IF
    END IF

    drawDialogBox

    FOR i = 1 TO totalLines
        x = (_WIDTH - _PRINTWIDTH(lines$(i))) / 2
        y = (_HEIGHT / 2) - ((_FONTHEIGHT * totalLines) / 2) + ((i - 1) * _FONTHEIGHT)
        _PRINTSTRING (x, y), lines$(i)
    NEXT
END SUB


SUB setError (text$, duration AS SINGLE)
    errorDialog.text = text$
    errorDialog.state = True
    errorDialog.start = TIMER
    errorDialog.duration = duration
END SUB

SUB showError
    IF errorDialog.state THEN
        dialog errorDialog.text
        IF timeElapsedSince(errorDialog.start) > errorDialog.duration THEN
            errorDialog.state = False
        END IF
    END IF
END SUB

FUNCTION cursorBlink$
    STATIC lastBlink
    IF timeElapsedSince(lastBlink) < .5 THEN
        cursorBlink$ = "_"
    ELSE
        cursorBlink$ = " "
    END IF

    IF timeElapsedSince(lastBlink) > 1 THEN
        lastBlink = TIMER
    END IF
END FUNCTION

FUNCTION StrReplace$ (myString$, find$, replaceWith$) 'noncase sensitive
    DIM a$, b$, basei AS LONG, i AS LONG
    IF LEN(myString$) = 0 THEN EXIT FUNCTION
    a$ = myString$
    b$ = LCASE$(find$)
    basei = 1
    i = INSTR(basei, LCASE$(a$), b$)
    DO WHILE i
        a$ = LEFT$(a$, i - 1) + replaceWith$ + RIGHT$(a$, LEN(a$) - i - LEN(b$) + 1)
        basei = i + LEN(replaceWith$)
        i = INSTR(basei, LCASE$(a$), b$)
    LOOP
    StrReplace$ = a$
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

FUNCTION lerp! (start!, stp!, amt!)
    lerp! = amt! * (stp! - start!) + start!
END FUNCTION

SUB printOutline (x AS INTEGER, y AS INTEGER, text$, fg AS _UNSIGNED LONG, bg AS _UNSIGNED LONG)
    DIM hlX AS INTEGER, hlY AS INTEGER
    COLOR bg
    FOR hlX = -1 TO 1 STEP 2
        FOR hlY = -1 TO 1 STEP 2
            _PRINTSTRING (x + hlX, y + hlY), text$
        NEXT
    NEXT

    COLOR fg
    _PRINTSTRING (x, y), text$
END SUB

