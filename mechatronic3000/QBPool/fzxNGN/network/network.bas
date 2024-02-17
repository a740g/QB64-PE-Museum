'$include:'/../../fzxNGN/typesAndConstants/fzxNGNTypes.bas'
'**********************************************************************************************
'   Network Stuff Ahead
'**********************************************************************************************
$IF NETWORKINCLUDE = UNDEFINED THEN
    $LET NETWORKINCLUDE = TRUE

    SUB handleNetwork (body() AS tBODY, net AS tNETWORK)
        IF net.SorC = cNET_SERVER THEN
            IF net.HCHandle = 0 THEN
                CALL networkStartHost(net)
            END IF
            CALL networkTransmit(body(), net)
        END IF

        IF net.SorC = cNET_CLIENT THEN
            CALL networkReceiveFromHost(body(), net)
        END IF
    END SUB


    SUB networkStartHost (net AS tNETWORK)
        DIM connection AS STRING
        connection = RTRIM$(net.protocol) + ":" + LTRIM$(STR$(net.port))
        net.HCHandle = _OPENHOST(connection)
    END SUB

    SUB networkReceiveFromHost (body() AS tBODY, net AS tNETWORK)
        DIM connection AS STRING
        DIM AS LONG timeout
        connection = RTRIM$(net.protocol) + ":" + LTRIM$(STR$(net.port)) + ":" + RTRIM$(net.address)
        net.HCHandle = _OPENCLIENT(connection)
        timeout = TIMER
        IF net.HCHandle THEN
            DO
                GET #net.HCHandle, , body()
                IF TIMER - timeout > 5 THEN EXIT DO ' 5 sec time out
            LOOP UNTIL EOF(net.HCHandle) = 0
            CALL networkClose(net)
        END IF
    END SUB

    SUB networkTransmit (body() AS tBODY, net AS tNETWORK)
        IF net.HCHandle <> 0 THEN
            net.connectionHandle = _OPENCONNECTION(net.HCHandle)
            IF net.connectionHandle <> 0 THEN
                PUT #net.connectionHandle, , body()
                CLOSE net.connectionHandle
            END IF
        END IF
    END SUB

    SUB networkClose (net AS tNETWORK)
        IF net.HCHandle <> 0 THEN
            CLOSE net.HCHandle
            net.HCHandle = 0
        END IF
    END SUB
$END IF

