'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'

'********************************************************
'   Handle Mouse Events
'********************************************************
$IF INPUTDEVICEINCLUDE = UNDEFINED THEN
    $LET INPUTDEVICEINCLUDE = TRUE


    SUB handleInputDevice (iDevice AS tINPUTDEVICE)
        ' iDevice.keyHit = _KEYHIT ' --- THIS IS TOO SLOW
        CALL cleanUpInputDevice(iDevice)
        DO WHILE _MOUSEINPUT
            iDevice.x = _MOUSEX
            iDevice.y = _MOUSEY
            iDevice.b1 = _MOUSEBUTTON(1)
            iDevice.b2 = _MOUSEBUTTON(2)
            iDevice.b3 = _MOUSEBUTTON(3)
            iDevice.w = _MOUSEWHEEL
            iDevice.wCount = iDevice.wCount + iDevice.w
        LOOP
        IF iDevice.lb1 > iDevice.b1 THEN ' 0 --> -1
            iDevice.b1PosEdge = 1
        ELSE
            iDevice.b1PosEdge = 0
        END IF

        IF iDevice.lb1 < iDevice.b1 THEN ' -1 --> 0
            iDevice.b1NegEdge = 1
        ELSE
            iDevice.b1NegEdge = 0
        END IF

        IF iDevice.lb2 > iDevice.b2 THEN ' 0 --> -1
            iDevice.b2PosEdge = 1
        ELSE
            iDevice.b2PosEdge = 0
        END IF

        IF iDevice.lb2 < iDevice.b2 THEN ' -1 --> 0
            iDevice.b2NegEdge = 1
        ELSE
            iDevice.b2NegEdge = 0
        END IF

        IF iDevice.lb3 > iDevice.b3 THEN ' 0 --> -1
            iDevice.b3PosEdge = 1
        ELSE
            iDevice.b3PosEdge = 0
        END IF

        IF iDevice.lb3 < iDevice.b3 THEN ' -1 --> 0
            iDevice.b3NegEdge = 1
        ELSE
            iDevice.b3NegEdge = 0
        END IF


    END SUB

    SUB cleanUpInputDevice (iDevice AS tINPUTDEVICE)
        iDevice.lb1 = iDevice.b1
        iDevice.lb2 = iDevice.b2
        iDevice.lb3 = iDevice.b3
        iDevice.lastKeyHit = iDevice.keyHit
        iDevice.wCount = 0
    END SUB
$END IF

