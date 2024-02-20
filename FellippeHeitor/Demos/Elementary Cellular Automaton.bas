OPTION _EXPLICIT
_CONTROLCHR OFF

CONST true = -1, false = 0

DIM ruleValue AS _UNSIGNED _BYTE
DIM SHARED ruleSet$
DIM nav$, newValue$
DIM AS LONG w, total, i, x, y, k
DIM AS _BYTE l, r, state, newState, firstTime, done
DIM AS _UNSIGNED LONG c
DIM AS _MEM m1, m2

firstTime = true
ruleValue = 99
w = 2

'setup
SCREEN _NEWIMAGE(1000, 800, 32)
_DISPLAY
COLOR _RGB32(0), _RGB32(255)
total = _WIDTH / w

'main loop
DO
    ruleSet$ = RIGHT$(STRING$(8, "0") + _BIN$(ruleValue), 8)
    REDIM AS _BYTE cells(total - 1), nextCells(total - 1)
    cells(INT(total / 2)) = 1
    y = _FONTHEIGHT
    CLS

    'draw loop
    DO
        FOR i = 0 TO total - 1
            x = i * w
            IF cells(i) THEN
                IF x < _WIDTH / 2 THEN
                    c = _RGB32(map(x, 0, _WIDTH / 2, 200, 0))
                ELSE
                    c = _RGB32(map(x, _WIDTH / 2, _WIDTH, 0, 200))
                END IF
            ELSE
                _CONTINUE
            END IF
            LINE (x, y)-STEP(w, w), c, BF
        NEXT

        y = y + w
        IF y > _HEIGHT THEN EXIT DO

        'calculate next generation
        FOR i = 0 TO total - 1
            l = cells((i - 1 + total) MOD total)
            r = cells((i + 1) MOD total)
            state = cells(i)
            newState = calculateState(l, state, r)
            nextCells(i) = newState
        NEXT

        m1 = _MEM(cells())
        m2 = _MEM(nextCells())
        _MEMCOPY m2, m2.OFFSET, m2.SIZE TO m1, m1.OFFSET
    LOOP

    IF ruleValue > 0 THEN nav$ = CHR$(27) + " " ELSE nav$ = SPACE$(2)
    nav$ = nav$ + "Rule " + RIGHT$(STRING$(3, "0") + _TRIM$(STR$(ruleValue)), 3)
    IF ruleValue < 255 THEN nav$ = nav$ + " " + CHR$(26)
    nav$ = nav$ + "; w =" + STR$(w)
    _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(nav$) / 2, 0), nav$
    IF firstTime THEN
        LOCATE 3, 1
        PRINT "use left/right arrows to change rule set or"
        PRINT "enter a rule number directly (0-255);"
        PRINT "up/down arrows to change box width."
        firstTime = false
    END IF

    _DISPLAY
    _KEYCLEAR
    done = false
    DO
        k = _KEYHIT
        SELECT CASE k
            CASE 27: SYSTEM
            CASE 19200: IF ruleValue > 0 THEN ruleValue = ruleValue - 1: EXIT DO
            CASE 19712: IF ruleValue < 255 THEN ruleValue = ruleValue + 1: EXIT DO
            CASE 18432: w = w + 2: total = _WIDTH / w: EXIT DO
            CASE 20480: IF w > 2 THEN w = w - 2: total = _WIDTH / w: EXIT DO
            CASE 13, 48 TO 57
                'insert mode
                IF k > 13 THEN newValue$ = CHR$(k) ELSE newValue$ = ""
                _KEYCLEAR
                DO
                    LOCATE 2, 1
                    PRINT "Enter new rule (0-255): "; newValue$; "_ ";
                    _DISPLAY
                    k = _KEYHIT
                    SELECT CASE k
                        CASE 48 TO 57
                            newValue$ = newValue$ + CHR$(k)
                        CASE 8
                            IF LEN(newValue$) THEN newValue$ = LEFT$(newValue$, LEN(newValue$) - 1)
                        CASE 13
                            IF VAL(newValue$) >= 0 AND VAL(newValue$) <= 255 THEN
                                ruleValue = VAL(newValue$)
                                done = true
                                EXIT DO
                            ELSE
                                BEEP
                            END IF
                        CASE 27
                            done = true
                            EXIT DO
                    END SELECT
                    _LIMIT 30
                LOOP
        END SELECT
        _LIMIT 30
    LOOP UNTIL done
LOOP

FUNCTION calculateState%% (a AS _BYTE, b AS _BYTE, c AS _BYTE)
    DIM neighborhood$
    DIM value AS _BYTE

    neighborhood$ = _TRIM$(STR$(a)) + _TRIM$(STR$(b)) + _TRIM$(STR$(c))
    value = 8 - VAL("&B" + neighborhood$)
    calculateState%% = VAL(MID$(ruleSet$, value, 1))
END FUNCTION

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION
