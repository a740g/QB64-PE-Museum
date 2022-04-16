CONST true = -1, false = NOT true

CONST objHero = 1
CONST objEnemy = 2
CONST objFloor = 3
CONST objBonus = 4
CONST objBackground = 5
CONST objBlock = 6

DIM SHARED kinds(1 TO 6) AS STRING
kinds(1) = "Hero"
kinds(2) = "Enemy"
kinds(3) = "Floor"
kinds(4) = "Bonus"
kinds(5) = "Background"
kinds(6) = "Block"

CONST objShapeRect = 0
CONST objShapeRound = 1
CONST g = 1

TYPE Objects
    kind AS INTEGER
    shape AS INTEGER
    x AS INTEGER
    xv AS SINGLE
    y AS INTEGER
    yv AS SINGLE
    w AS INTEGER
    h AS INTEGER
    color AS _UNSIGNED LONG
    landedOn AS LONG
    taken AS _BYTE
END TYPE

REDIM SHARED Object(1 TO 100) AS Objects
DIM SHARED TotalObjects AS LONG
DIM SHARED Hero AS LONG, NewObj AS LONG
DIM SHARED Dead AS _BYTE, CameraX AS LONG, CameraY AS LONG
DIM SHARED Points AS LONG

SCREEN _NEWIMAGE(800, 600, 32)
_PRINTMODE _KEEPBACKGROUND

DO
    Level = Level + 1
    SetLevel Level

    DO
        ProcessInput
        DoPhysics
        UpdateScreen
        _LIMIT 35
    LOOP
LOOP

SYSTEM

FUNCTION AddObject (Kind AS INTEGER, x AS SINGLE, y AS SINGLE, w AS SINGLE, h AS SINGLE, c AS _UNSIGNED LONG)
    TotalObjects = TotalObjects + 1
    IF TotalObjects > UBOUND(Object) THEN
        REDIM _PRESERVE Object(1 TO UBOUND(Object) + 99) AS Objects
    END IF

    Object(TotalObjects).kind = Kind

    Object(TotalObjects).x = x
    Object(TotalObjects).y = y
    Object(TotalObjects).w = w
    Object(TotalObjects).h = h
    Object(TotalObjects).color = c

    AddObject = TotalObjects
END FUNCTION

SUB ProcessInput
    STATIC JumpButton AS _BYTE
    IF _KEYDOWN(19712) AND NOT Dead THEN
        IF _KEYDOWN(100306) THEN
            Object(Hero).x = Object(Hero).x + 1
            DO WHILE _KEYDOWN(19712): LOOP
        ELSE
            IF Object(Hero).xv < 0 THEN
                Object(Hero).xv = Object(Hero).xv + 2
            ELSE
                Object(Hero).xv = 4
            END IF
        END IF
    END IF
    IF _KEYDOWN(19200) AND NOT Dead THEN
        IF _KEYDOWN(100306) THEN
            Object(Hero).x = Object(Hero).x - 1
            DO WHILE _KEYDOWN(19200): LOOP
        ELSE
            IF Object(Hero).xv > 0 THEN
                Object(Hero).xv = Object(Hero).xv - 2
            ELSE
                Object(Hero).xv = -4
            END IF
        END IF
    END IF
    IF _KEYDOWN(18432) AND NOT Dead THEN
        IF NOT JumpButton THEN
            JumpButton = true
            IF Object(Hero).landedOn > 0 THEN Object(Hero).yv = -20: Object(Hero).landedOn = 0
        END IF
    ELSEIF NOT _KEYDOWN(18432) THEN
        IF JumpButton THEN JumpButton = false
    END IF
    IF _KEYDOWN(13) AND Dead THEN
        Dead = 0
        Object(Hero).x = 25
        Object(Hero).y = _HEIGHT - _HEIGHT / 5 - 22
        Object(Hero).yv = 0
        Object(Hero).xv = 0
        Object(Hero).landedOn = 0
    END IF
    IF _KEYDOWN(27) THEN SYSTEM
END SUB

SUB DoPhysics
    FOR i = 1 TO TotalObjects
        IF Object(i).kind = objHero OR Object(i).kind = objEnemy THEN

            IF Object(i).kind = objEnemy THEN
                IF Object(Hero).x < Object(i).x THEN Object(i).xv = -1.5 ELSE Object(i).xv = 1.5
            END IF

            Object(i).x = Object(i).x + Object(i).xv
            Object(i).y = Object(i).y + Object(i).yv

            IF Object(i).landedOn = 0 THEN
                Object(i).yv = Object(i).yv + g
            END IF

            FOR j = 1 TO TotalObjects

                IF Object(i).yv < 0 THEN
                    IF Object(j).kind = objBlock THEN
                        IF Object(i).x + Object(i).w > Object(j).x AND Object(i).x < Object(j).x + Object(j).w THEN
                            IF Object(i).y > Object(j).y AND Object(i).y < Object(j).y + Object(j).h + 1 THEN
                                Object(i).yv = 2
                                Object(i).y = Object(i).y + 2
                                IF Object(j).taken = false THEN
                                    Object(j).taken = true
                                    Object(j).color = _RGB32(122, 100, 78)
                                END IF
                                EXIT FOR
                            END IF
                        END IF
                    END IF
                END IF

                IF Object(i).kind = objHero AND Object(j).kind = objBonus AND Object(j).taken = false THEN
                    IF Object(i).y + Object(i).h >= Object(j).y AND Object(i).y <= Object(j).y + Object(j).h THEN
                        IF Object(i).x + Object(i).w > Object(j).x AND Object(i).x < Object(j).x + Object(j).w THEN
                            Object(j).taken = true
                            Points = Points + 10
                            EXIT FOR
                        END IF
                    END IF
                END IF

                IF Object(i).xv > 0 THEN
                    IF Object(j).kind = objBlock OR Object(j).kind = objEnemy THEN
                        IF Object(i).y + Object(i).h >= Object(j).y AND Object(i).y <= Object(j).y + Object(j).h THEN
                            IF Object(i).x + Object(i).w > Object(j).x AND Object(i).x < Object(j).x + Object(j).w THEN
                                Object(i).x = Object(j).x - Object(i).w - 1
                                Object(i).xv = 0
                                IF Object(i).kind = objHero AND Object(j).kind = objEnemy AND Object(j).taken = false THEN Dead = true: Object(j).taken = true
                                EXIT FOR
                            END IF
                        END IF
                    END IF
                ELSEIF Object(i).xv < 0 THEN
                    IF Object(j).kind = objBlock THEN
                        IF Object(i).y + Object(i).h >= Object(j).y AND Object(i).y <= Object(j).y + Object(j).h THEN
                            IF Object(i).x + Object(i).w > Object(j).x AND Object(i).x < Object(j).x + Object(j).w THEN
                                Object(i).x = Object(j).x + Object(j).w + 1
                                Object(i).xv = 0
                                IF Object(i).kind = objHero AND Object(j).kind = objEnemy AND Object(j).taken = false THEN Dead = true: Object(j).taken = true
                                EXIT FOR
                            END IF
                        END IF
                    END IF
                END IF

                IF Object(i).yv >= 0 THEN
                    IF Object(j).kind = objFloor OR Object(j).kind = objBlock THEN
                        IF Object(i).x + Object(i).w >= Object(j).x AND Object(i).x <= Object(j).x + Object(j).w THEN
                            IF Object(i).y + Object(i).h > Object(j).y AND Object(i).y < Object(j).y + Object(j).h THEN
                                Object(i).y = Object(j).y - Object(i).h - 1
                                Object(i).yv = 0
                                Object(i).landedOn = j
                                EXIT FOR
                            END IF
                        ELSE
                            IF Object(i).landedOn = j THEN
                                Object(i).landedOn = 0
                                EXIT FOR
                            END IF
                        END IF
                    END IF
                END IF
            NEXT

            IF Object(Hero).y > _HEIGHT THEN Dead = true

            IF Object(i).xv > 0 THEN Object(i).xv = Object(i).xv - 1
            IF Object(i).xv < 0 THEN Object(i).xv = Object(i).xv + 1
            IF Object(i).yv <> 0 THEN Object(i).yv = Object(i).yv + g
        END IF
    NEXT

    IF Object(Hero).x + CameraX > _WIDTH / 2 THEN
        CameraX = _WIDTH / 2 - Object(Hero).x
    ELSEIF Object(Hero).x + CameraX < _WIDTH / 5 THEN
        CameraX = _WIDTH / 5 - Object(Hero).x
    END IF

    IF Object(Hero).y + CameraY < _HEIGHT / 3 THEN
        CameraY = -Object(Hero).y + _HEIGHT / 3
    ELSEIF Object(Hero).y + CameraY > _HEIGHT / 2 THEN
        CameraY = _HEIGHT / 2 - Object(Hero).y
    END IF

    IF CameraX > 0 THEN CameraX = 0
    IF CameraY < 0 THEN CameraY = 0
END SUB

SUB UpdateScreen
    CLS

    DIM this AS Objects

    FOR i = 1 TO TotalObjects
        this = Object(i)
        IF this.kind > 0 THEN
            IF this.kind = objBackground THEN
                thisCameraX = CameraX / 2
                thisCameraY = CameraY / 2
            ELSE
                thisCameraX = CameraX
                thisCameraY = CameraY
            END IF
            IF (this.kind = objEnemy OR this.kind = objBonus) AND this.taken THEN GOTO Continue
            IF this.x + this.w + thisCameraX < 0 AND this.shape <> objShapeRound THEN
                GOTO Continue
            ELSEIF thisCameraX + this.x + this.w + this.w / 2 < 0 AND this.shape = objShapeRound THEN
                GOTO Continue
            END IF
            IF this.x + thisCameraX > _WIDTH THEN GOTO Continue
            IF this.shape = objShapeRect THEN
                LINE (this.x + thisCameraX, this.y + thisCameraY)-STEP(this.w, this.h), this.color, BF
                LINE (this.x + thisCameraX, this.y + thisCameraY)-STEP(this.w, this.h), _RGB32(0, 0, 0), B
                '_PRINTSTRING (this.x + CameraX, this.y), LTRIM$(STR$(this.x)) + STR$(this.x + this.w)
            ELSEIF this.shape = objShapeRound THEN
                FOR k = 1 TO this.w
                    CIRCLE (thisCameraX + this.x + this.w / 2, thisCameraY + this.y + this.h / 2), k, this.color, , , this.w / this.h
                NEXT
                CIRCLE (thisCameraX + this.x + this.w / 2, thisCameraY + this.y + this.h / 2), this.w, _RGB32(0, 0, 0), , , this.w / this.h
            END IF
            'IF this.kind = objHero AND this.landedOn > 0 THEN _PRINTSTRING (this.x + CameraX, this.y - _FONTHEIGHT), "Landed on" + STR$(this.landedOn)
            PRINT i; kinds(this.kind)
        END IF
        Continue:
    NEXT

    PRINT "CameraX"; CameraX
    PRINT "CameraY"; CameraY

    IF Dead THEN
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("You're dead!") / 2, _HEIGHT / 2 - _FONTHEIGHT), "You're dead!"
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("(hit ENTER)") / 2, _HEIGHT / 2 + _FONTHEIGHT), "(hit ENTER)"
    END IF

    IF Points > 0 THEN _PRINTSTRING (0, 0), STR$(Points)

    _DISPLAY
END SUB

SUB SetLevel (__Level AS INTEGER)
    DIM Level AS INTEGER, MaxLevels AS INTEGER

    MaxLevels = 1

    IF __Level > MaxLevels THEN
        Level = _CEIL(RND * MaxLevels)
    ELSE
        Level = __Level
    END IF

    SELECT CASE Level
        CASE 1
            NewObj = AddObject(objBackground, 0, 0, _WIDTH * 2, _HEIGHT, _RGB32(61, 161, 222))

            FOR i = 1 TO 10
                NewObj = AddObject(objBackground, RND * _WIDTH * 2, RND * -_HEIGHT, 50, 100, _RGB32(255, 255, 255))
                Object(NewObj).shape = objShapeRound
            NEXT

            NewObj = AddObject(objFloor, 20, _HEIGHT - _HEIGHT / 5, _WIDTH * 1.5, 150, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 1300, _HEIGHT - _HEIGHT / 5, _WIDTH * 1.5, 150, _RGB32(111, 89, 50))

            NewObj = AddObject(objFloor, 110, 400, 110, 10, _RGB32(111, 89, 50))

            NewObj = AddObject(objFloor, 400, 400, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 575, 330, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 700, 260, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 875, 200, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 1000, 140, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 1175, 70, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 1000, 10, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 875, -50, 110, 10, _RGB32(111, 89, 50))
            NewObj = AddObject(objFloor, 700, -110, 110, 10, _RGB32(111, 89, 50))

            NewObj = AddObject(objBlock, 20, 400, 25, 25, _RGB32(216, 166, 50))

            NewObj = AddObject(objBlock, 200, _HEIGHT - _HEIGHT / 5 - 16, 15, 15, _RGB32(216, 166, 50))
            NewObj = AddObject(objBlock, 216, _HEIGHT - _HEIGHT / 5 - 16, 15, 15, _RGB32(216, 166, 50))
            NewObj = AddObject(objBlock, 232, _HEIGHT - _HEIGHT / 5 - 16, 15, 15, _RGB32(216, 166, 50))
            NewObj = AddObject(objBlock, 216, _HEIGHT - _HEIGHT / 5 - 32, 15, 15, _RGB32(216, 166, 50))
            NewObj = AddObject(objBlock, 232, _HEIGHT - _HEIGHT / 5 - 32, 15, 15, _RGB32(216, 166, 50))
            NewObj = AddObject(objBlock, 232, _HEIGHT - _HEIGHT / 5 - 48, 15, 15, _RGB32(216, 166, 50))

            NewObj = AddObject(objBonus, 800, 270, 15, 10, _RGB32(249, 244, 55))
            Object(NewObj).shape = objShapeRound

            NewObj = AddObject(objBonus, 820, 320, 15, 10, _RGB32(249, 244, 55))
            Object(NewObj).shape = objShapeRound

            NewObj = AddObject(objBonus, 1200, _HEIGHT - _HEIGHT / 5 - 22, 15, 10, _RGB32(249, 244, 55))
            Object(NewObj).shape = objShapeRound

            NewObj = AddObject(objEnemy, 1200, _HEIGHT - _HEIGHT / 5 - 22, 15, 10, _RGB32(150, 89, 238))

            Hero = AddObject(objHero, 25, _HEIGHT - _HEIGHT / 5 - 22, 10, 20, _RGB32(127, 244, 127))
    END SELECT
END SUB

