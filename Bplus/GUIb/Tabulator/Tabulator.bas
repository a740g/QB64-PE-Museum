_TITLE "Tabulator" ' B+ 2020-10-23  from Formula Saver
' More Evaluate.txt bplus started 2020-05-10 inspired by honkytonk app
' 2020-10-23 translate from JB but install latest Evaluate
' copy of Evaluate subs used in this Forumla Saver Project Folder
' Should be able to do all this without Word$ tools
' OK everything seems to be working now start Tabulator
' OK Had to rearrnge th eorder the formula string gets prepped, ie
' put spaces around all the "words", replace variable for their values
' or replace constants like pi and e. THEN running x in a FOR loop update
' only the X variable with it's value.

' The Tabulator.exe opens the file: TableIn.txt
' reads lines formated as:
' first line holds the start value of a FOR Loop
' 2nd the end value of same FOR loop
' 3rd the increament to STEP
' 4th the formula eg, X ^ 2 + b * X + pi
' 5th the dFlag use 0 for Radian units any other for Degrees units
' 6+ the variables separated by CHR$(10) eg
' a = 1
' b = 6
' c = 5
' inches = 42

' Tabulator runs the formula in a for loop and generates a table in the
' file  TableOut.txt.

' So you can edit TableIn.txt in your favorite Text Editor and Run Tabulator
' and it will rewrite the TableOut.txt with the list of x and f(x).

' Or you can use Calling the Tabulator sub to write the TableIn.txt file,
' Shell and Run Tabulator then read the file into an array top use:
' SUB forXEqual (start, toFinish, incStep, formula$, dFlag%, variablesCHR10$, outputArr$())
' Calling the Tabulator.bas is a demo for the SUB mainly.

' BTW Tabulator does everything in background you will have no idea the TableOut.txt file
' has been rewritten or not!


'evaluate$ and evalW setup
DIM SHARED evalErr$, pi, rad, deg, Dflag, vTopI AS INTEGER, debug
debug = 0 ' this is for checking the Evaluate stuff

pi = _PI: rad = pi / 180: deg = 180 / pi '<<<<<<<<<<< true constants
vTopI = 0 'track variables and functions we have changeable global variables change as needed

Dflag = 0 ' degrees flag
evalErr$ = ""
rad = _PI / 180.0
deg = 180 / _PI
REDIM SHARED fList(1 TO 1) AS STRING
Split "int, sin, cos, tan, asin, acos, atan, log, exp, sqr, rad, deg,", ", ", fList()
REDIM SHARED oList(1 TO 1) AS STRING
Split "^, %, /, *, -, +, =, <, >, <=, >=, <>, or, and, not", ", ", oList()

DIM SHARED varNames$(1 TO 100), varValues(1 TO 100)

IF _FILEEXISTS("TableIn.txt") THEN ' 5 lines max to read
    OPEN "TableIn.txt" FOR INPUT AS #1
    FOR i = 1 TO 5
        LINE INPUT #1, fline$
        SELECT CASE i '                     format first 5 lines set variables, more than 5 sets variable names and values
            CASE 1: start = VAL(fline$)
            CASE 2: finish = VAL(fline$)
            CASE 3: inc = VAL(fline$)
            CASE 4: frml$ = fline$
            CASE 5: Dflag = VAL(fline$)
        END SELECT
    NEXT
    WHILE NOT EOF(1) ' read in additional varaibles and values
        LINE INPUT #1, fline$
        IF INSTR(fline$, "=") THEN '                        collect variable names and values
            vTopI = vTopI + 1
            varNames$(vTopI) = _TRIM$(leftOf$(fline$, "=")): varValues(vTopI) = VAL(_TRIM$(rightOf$(fline$, "=")))
        END IF
    WEND
    CLOSE #1
ELSE
    PRINT " Sorry, TableIn.txt file is missing, goodbye!"
    END
END IF
OPEN "TableOut.txt" FOR OUTPUT AS #1
e$ = prepEval$(frml$)
IF evalErr$ = "" THEN 'debug
    'PRINT "prep formula: "; e$
    'INPUT " OK "; w$
ELSE
    PRINT #1, "Error: " + evalErr$
    CLOSE #1
    SYSTEM
END IF
preEvalSubst e$ 'OK inject variable values into formula
' debug
'PRINT "Replace variables with values, except x: "; e$
'INPUT "After preEvalSubst OK "; w$

FOR x = start TO finish STEP inc
    REDIM ev$(1 TO 1)
    copy$ = e$
    Split copy$, " ", ev$()
    FOR i = LBOUND(ev$) TO UBOUND(ev$) 'look for x
        IF LCASE$(ev$(i)) = "x" THEN ev$(i) = _TRIM$(STR$(x))
    NEXT
    'rebuild eString$
    FOR i = LBOUND(ev$) TO UBOUND(ev$) ' rejoin as b$
        IF i = LBOUND(ev$) THEN b$ = ev$(1) ELSE b$ = b$ + " " + ev$(i)
    NEXT
    copy$ = b$
    result$ = _TRIM$(Evaluate$(copy$))
    IF evalErr$ = "" THEN
        PRINT #1, ts$(x); " "; result$
    ELSE
        PRINT #1, ts$(x); " Error: " + evalErr$
    END IF
NEXT
CLOSE #1
SYSTEM

FUNCTION value (vName$) ' find vName$ index to get value of variable
    FOR i = 1 TO vTopI
        IF _TRIM$(varNames$(i)) = _TRIM$(vName$) THEN
            value = varValues(i)
            EXIT FUNCTION
        END IF
    NEXT
    value = -99.11 ' no value found can't be -1 or 0 too common
END FUNCTION

SUB preEvalSubst (eString$) ' this is meant to modify eString$ inserting values for variables
    REDIM ev$(1 TO 1)
    Split eString$, " ", ev$()
    FOR i = LBOUND(ev$) TO UBOUND(ev$) 'replace variables for values
        IF LCASE$(ev$(i)) = "pi" THEN
            ev$(i) = ts$(_PI)
        ELSEIF LCASE$(ev$(i)) = "e" THEN
            ev$(i) = ts$(EXP(1))
        ELSEIF LCASE$(ev$(i)) <> "x" THEN
            v = value(ev$(i))
            IF v <> -99.11 THEN ev$(i) = ts$(v)
        END IF
    NEXT
    'rebuild eString$
    FOR i = LBOUND(ev$) TO UBOUND(ev$) ' rejoin as b$
        IF i = LBOUND(ev$) THEN b$ = ev$(1) ELSE b$ = b$ + " " + ev$(i)
    NEXT
    eString$ = b$
END SUB

FUNCTION leftOf$ (source$, of$)
    IF INSTR(source$, of$) > 0 THEN leftOf$ = MID$(source$, 1, INSTR(source$, of$) - 1)
END FUNCTION

FUNCTION rightOf$ (source$, of$)
    IF INSTR(source$, of$) > 0 THEN rightOf$ = MID$(source$, INSTR(source$, of$) + LEN(of$))
END FUNCTION

FUNCTION prepEval$ (e$)
    DIM b$, c$
    DIM i AS INTEGER, po AS INTEGER ', isolateNeg AS _BIT
    ' isolateNeg = 0
    b$ = "" 'rebuild string with padded spaces
    'this makes sure ( ) + * / % ^ are wrapped with spaces,  ??????????? on your own with - sign fixed?
    FOR i = 1 TO LEN(e$) 'filter chars and count ()
        c$ = LCASE$(MID$(e$, i, 1))
        IF c$ = ")" THEN
            po = po - 1: b$ = b$ + " ) "
        ELSEIF c$ = "(" THEN
            po = po + 1: b$ = b$ + " ( "
        ELSEIF INSTR("+*/%^", c$) > 0 THEN
            b$ = b$ + " " + c$ + " "
        ELSEIF c$ = "-" THEN
            IF LEN(b$) > 0 THEN
                IF INSTR(".0123456789abcdefghijklmnopqrstuvwxyz)", RIGHT$(RTRIM$(b$), 1)) > 0 THEN
                    b$ = b$ + " " + c$ + " "
                ELSE
                    b$ = b$ + " " + c$
                END IF
            ELSE
                b$ = b$ + " " + c$
            END IF
        ELSEIF INSTR(" .0123456789abcdefghijklmnopqrstuvwxyz<>=", c$) > 0 THEN
            b$ = b$ + c$
        END IF
        IF po < 0 THEN evalErr$ = "Too many )": EXIT FUNCTION
    NEXT
    IF po <> 0 THEN evalErr$ = "Unbalanced ()": EXIT FUNCTION
    prepEval$ = b$
END FUNCTION

' ================================================================================ from Evaluate
'this preps e$ string for actual evaluation function and makes call to it,
'checks results for error returns that or string form of result calculation
'the new goal is to do string functions along side math
FUNCTION Evaluate$ (e$)
    REDIM ev(1 TO 1) AS STRING
    Split e$, " ", ev()
    c$ = evalW$(ev())
    IF evalErr$ <> "" THEN Evaluate$ = evalErr$ ELSE Evaluate$ = c$
END FUNCTION

' the recursive part of EVAL
FUNCTION evalW$ (a() AS STRING)
    IF evalErr$ <> "" THEN EXIT FUNCTION

    DIM fun$, test$, innerV$, m$, op$
    DIM pop AS INTEGER, lPlace AS INTEGER, i AS INTEGER, rPlace AS INTEGER
    DIM po AS INTEGER, p AS INTEGER, o AS INTEGER, index AS INTEGER
    DIM recurs AS INTEGER
    DIM innerVal AS _FLOAT, a AS _FLOAT, b AS _FLOAT
    IF debug THEN
        PRINT "evalW rec'd a() as:"
        FOR i = LBOUND(a) TO UBOUND(a)
            PRINT a(i); ", ";
        NEXT
        PRINT: INPUT "OK enter"; test$: PRINT
    END IF
    pop = find%(a(), "(") 'parenthesis open place
    WHILE pop > 0
        IF pop = 1 THEN
            fun$ = "": lPlace = 1
        ELSE
            test$ = a(pop - 1)
            IF find%(fList(), test$) > 0 THEN
                fun$ = test$: lPlace = pop - 1
            ELSE
                fun$ = "": lPlace = pop
            END IF
        END IF
        po = 1
        FOR i = pop + 1 TO UBOUND(a)
            IF a(i) = "(" THEN po = po + 1
            IF a(i) = ")" THEN po = po - 1
            IF po = 0 THEN rPlace = i: EXIT FOR
        NEXT
        REDIM inner(1 TO 1) AS STRING: index = 0: recurs = 0
        FOR i = (pop + 1) TO (rPlace - 1)
            index = index + 1
            REDIM _PRESERVE inner(1 TO index) AS STRING
            inner(index) = a(i)
            IF find%(oList(), a(i)) > 0 THEN recurs = -1
        NEXT
        IF recurs THEN innerV$ = evalW$(inner()) ELSE innerV$ = a(pop + 1)
        innerVal = VAL(innerV$)

        SELECT CASE fun$
            CASE "": m$ = innerV$
            CASE "int": m$ = ts$(INT(innerVal))
            CASE "sin": IF Dflag THEN m$ = ts$(SIN(rad * innerVal)) ELSE m$ = ts$(SIN(innerVal))
            CASE "cos": IF Dflag THEN m$ = ts$(COS(rad * innerVal)) ELSE m$ = ts$(COS(innerVal))
            CASE "tan": IF Dflag THEN m$ = ts$(TAN(rad * innerVal)) ELSE m$ = ts$(TAN(innerVal))
            CASE "asin": IF Dflag THEN m$ = ts$(_ASIN(rad * innerVal)) ELSE m$ = ts$(_ASIN(innerVal))
            CASE "acos": IF Dflag THEN m$ = ts$(_ACOS(rad * innerVal)) ELSE m$ = ts$(_ACOS(innerVal))
            CASE "atan": IF Dflag THEN m$ = ts$(ATN(rad * innerVal)) ELSE m$ = ts$(ATN(innerVal))
            CASE "log"
                IF innerVal > 0 THEN
                    m$ = ts$(LOG(innerVal))
                ELSE
                    evalErr$ = "LOG only works on numbers > 0.": EXIT FUNCTION
                END IF
            CASE "exp" 'the error limit is inconsistent in JB
                IF -745 <= innerVal AND innerVal <= 709 THEN 'your system may have different results
                    m$ = ts$(EXP(innerVal))
                ELSE
                    'what the heck???? 708 works fine all alone as limit ?????
                    evalErr$ = "EXP(n) only works for n = -745 to 709.": EXIT FUNCTION
                END IF
            CASE "sqr"
                IF innerVal >= 0 THEN
                    m$ = ts$(SQR(innerVal))
                ELSE
                    evalErr$ = "SQR only works for numbers >= 0.": EXIT FUNCTION
                END IF
            CASE "rad": m$ = ts$(innerVal * rad)
            CASE "deg": m$ = ts$(innerVal * deg)
            CASE ELSE: evalErr$ = "Unidentified function " + fun$: EXIT FUNCTION
        END SELECT
        IF debug THEN
            PRINT "lPlace, rPlace"; lPlace, rPlace
        END IF
        arrSubst a(), lPlace, rPlace, m$
        IF debug THEN
            PRINT "After arrSubst a() is:"
            FOR i = LBOUND(a) TO UBOUND(a)
                PRINT a(i); " ";
            NEXT
            PRINT: PRINT
        END IF
        pop = find%(a(), "(")
    WEND

    'all parenthesis cleared
    'ops$ = "% ^ / * + - = < > <= >= <> and or not" 'all () cleared, now for binary ops (not not binary but is last!)
    FOR o = 1 TO 15
        op$ = oList(o)
        p = find%(a(), op$)
        WHILE p > 0
            a = VAL(a(p - 1))
            b = VAL(a(p + 1))
            IF debug THEN
                PRINT STR$(a) + op$ + STR$(b)
            END IF
            SELECT CASE op$
                CASE "%"
                    IF b >= 2 THEN
                        m$ = ts$(INT(a) MOD INT(b))
                    ELSE
                        evalErr$ = "For a Mod b, b value < 2."
                        EXIT FUNCTION
                    END IF
                CASE "^"
                    IF INT(b) = b OR a >= 0 THEN
                        m$ = ts$(a ^ b)
                    ELSE
                        evalErr$ = "For a ^ b, a needs to be >= 0 when b not integer."
                        EXIT FUNCTION
                    END IF
                CASE "/"
                    IF b <> 0 THEN
                        m$ = ts$(a / b)
                    ELSE
                        evalErr$ = "Div by 0"
                        EXIT FUNCTION
                    END IF
                CASE "*": m$ = ts$(a * b)
                CASE "-": m$ = ts$(a - b)
                CASE "+": m$ = ts$(a + b)
                CASE "=": IF a = b THEN m$ = "-1" ELSE m$ = "0"
                CASE "<": IF a < b THEN m$ = "-1" ELSE m$ = "0"
                CASE ">": IF a > b THEN m$ = "-1" ELSE m$ = "0"
                CASE "<=": IF a <= b THEN m$ = "-1" ELSE m$ = "0"
                CASE ">=": IF a >= b THEN m$ = "-1" ELSE m$ = "0"
                CASE "<>": IF a <> b THEN m$ = "-1" ELSE m$ = "0"
                CASE "and": IF a <> 0 AND b <> 0 THEN m$ = "-1" ELSE m$ = "0"
                CASE "or": IF a <> 0 OR b <> 0 THEN m$ = "-1" ELSE m$ = "0"
                CASE "not": IF b = 0 THEN m$ = "-1" ELSE m$ = "0" 'use b as nothing should be left of not
            END SELECT
            arrSubst a(), p - 1, p + 1, m$

            IF debug THEN
                PRINT "a() reloaded after " + op$ + " as:"
                FOR i = LBOUND(a) TO UBOUND(a)
                    PRINT a(i); ", ";
                NEXT
                PRINT: PRINT
            END IF

            p = find%(a(), op$)
        WEND
    NEXT
    fun$ = ""
    FOR i = LBOUND(a) TO UBOUND(a)
        fun$ = fun$ + " " + a(i)
    NEXT
    evalW$ = LTRIM$(fun$)
END FUNCTION

SUB arrSubst (a() AS STRING, substLow AS LONG, substHigh AS LONG, subst AS STRING)
    DIM i AS LONG, index AS LONG
    a(substLow) = subst: index = substLow + 1
    FOR i = substHigh + 1 TO UBOUND(a)
        a(index) = a(i): index = index + 1
    NEXT
    REDIM _PRESERVE a(LBOUND(a) TO UBOUND(a) + substLow - substHigh)
END SUB

'notes: REDIM the array(0) to be loaded before calling Split '<<<<<<<<<<<<<<<<<<<<<<< IMPORTANT!!!!
SUB Split (mystr AS STRING, delim AS STRING, arr() AS STRING)
    ' bplus modifications of Galleon fix of Bulrush Split reply #13
    ' http://www.qb64.net/forum/index.php?topic=1612.0
    ' this sub further developed and tested here: \test\Strings\Split test.bas
    ' 2018-09-16 modified for base 1 arrays
    DIM copy AS STRING, p AS LONG, curpos AS LONG, arrpos AS LONG, lc AS LONG, dpos AS LONG
    copy = mystr 'make copy since we are messing with mystr
    'special case if delim is space, probably want to remove all excess space
    IF delim = " " THEN
        copy = RTRIM$(LTRIM$(copy))
        p = INSTR(copy, "  ")
        WHILE p > 0
            copy = MID$(copy, 1, p - 1) + MID$(copy, p + 1)
            p = INSTR(copy, "  ")
        WEND
    END IF
    REDIM arr(1 TO 1) 'clear it
    curpos = 1
    arrpos = 1
    lc = LEN(copy)
    dpos = INSTR(curpos, copy, delim)
    DO UNTIL dpos = 0
        arr(arrpos) = MID$(copy, curpos, dpos - curpos)
        arrpos = arrpos + 1
        REDIM _PRESERVE arr(1 TO arrpos + 1) AS STRING
        curpos = dpos + LEN(delim)
        dpos = INSTR(curpos, copy, delim)
    LOOP
    arr(arrpos) = MID$(copy, curpos)
    REDIM _PRESERVE arr(1 TO arrpos) AS STRING
END SUB

'assume a() is base 1 array so if find comes back as 0 then found nothing
FUNCTION find% (a() AS STRING, s$)
    DIM i%
    FOR i% = LBOUND(a) TO UBOUND(a)
        IF a(i%) = s$ THEN find% = i%: EXIT FUNCTION
    NEXT
END FUNCTION

'ltrim a number float
FUNCTION ts$ (n)
    ts$ = _TRIM$(STR$(n))
END FUNCTION

