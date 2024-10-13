'$INCLUDE: './global.bh'
'$CHECKING:OFF

'ON ERROR GOTO er
DIM temp AS winType
DIM win_Log AS INTEGER
DIM win_Img AS INTEGER, win_Img_Image AS LONG
DIM win_Cat AS INTEGER, win_Cat_Text AS STRING
DIM win_Launcher
DIM win_Other AS INTEGER

win_Img_Image = _LOADIMAGE("images/image.jpg", 32)
'SetAlpha 250, , win_Img_Image

temp = __template_Win
temp.IH = _NEWIMAGE(temp.W, temp.H, 32)
temp.T = ""
win_Launcher = newWin(temp)


logP "INFO> main routine: Ready"
DIM win AS INTEGER
DO
    DO WHILE _MOUSEINPUT: updateMouse: LOOP

    FOR win = LBOUND(w) TO UBOUND(w)
        IF w(win).IH = 0 THEN _CONTINUE
        SELECT CASE win


            CASE win_Log 'Log window
                IF w(win).NeedsRefresh THEN resizeWin win_Log: logP ""


            CASE win_Img
                IF w(win).NeedsRefresh THEN
                    resizeWin win_Img
                    _PUTIMAGE , win_Img_Image, w(win).IH
                END IF



            CASE win_Cat 'Text editor window
                $CHECKING:OFF
                IF w(win_Cat).Z = 0 THEN

                    IF __inKey <> "" THEN w(win_Cat).NeedsRefresh = -1
                    DO UNTIL __inKey = ""
                        SELECT CASE __inKey '__inKey is updated when upd is called.
                            CASE CHR$(8): win_Cat_Text = LEFT$(win_Cat_Text, LEN(win_Cat_Text) - 1) 'backspace
                            CASE CHR$(13): win_Cat_Text = win_Cat_Text + " " + CHR$(13) + " "
                            CASE ELSE: win_Cat_Text = win_Cat_Text + __inKey 'Append keypress to window
                        END SELECT
                        __inKey = INKEY$
                    LOOP


                    IF w(win).NeedsRefresh THEN
                        resizeWin win
                        printWithWrap win_Cat_Text, win_Cat
                    END IF
                END IF
                $CHECKING:ON




            CASE win_Launcher
                w(win).W = 100
                w(win).H = 76
                IF (w(win).NeedsRefresh <> 0) OR (w(win_Launcher).Z = 0) THEN
                    resizeWin win
                    _DEST w(win).IH
                    LINE (0, 0)-STEP(100, 16), &H404040C8, BF
                    LINE (0, 20)-STEP(100, 16), &H404040C8, BF
                    LINE (0, 40)-STEP(100, 16), &H404040C8, BF
                    LINE (0, 60)-STEP(100, 16), &H404040C8, BF
                    IF win_Log THEN _PRINTSTRING (2, 2), "Close log" ELSE _PRINTSTRING (2, 2), "Open log"
                    IF win_Cat THEN _PRINTSTRING (2, 22), "Close text editor" ELSE _PRINTSTRING (2, 22), "Open text editor"
                    IF win_Img THEN _PRINTSTRING (2, 42), "Close image" ELSE _PRINTSTRING (2, 42), "Open image"
                    IF win_Other THEN _PRINTSTRING (2, 62), "Close debug" ELSE _PRINTSTRING (2, 62), "Open debug"
                END IF

                IF w(win_Launcher).Z = 0 THEN
                    IF ((w(win).MX < 100) AND (w(win).MX > 0)) THEN
                        w(win).NeedsRefresh = True
                        SELECT CASE w(win).MY
                            CASE 0 TO 16
                                IF _MOUSEBUTTON(1) THEN
                                    IF win_Log THEN
                                        freeWin win_Log
                                        win_Log = 0
                                    ELSE
                                        temp = __template_Win
                                        temp.X = 50
                                        temp.IH = _NEWIMAGE(320, 240, 32)
                                        temp.T = "Log"
                                        temp.FH = __font_Mono
                                        win_Log = newWin(temp)
                                    END IF
                                ELSE
                                    LINE (0, 0)-(100, 16), &H66666666, BF
                                END IF

                            CASE 20 TO 36
                                IF _MOUSEBUTTON(1) THEN
                                    IF win_Cat THEN
                                        freeWin win_Cat
                                        win_Cat = 0
                                    ELSE
                                        temp = __template_Win
                                        temp.X = 200
                                        temp.IH = _NEWIMAGE(320, 240, 32)
                                        temp.T = "Text editor"
                                        temp.FH = __font_Sans
                                        win_Cat = newWin(temp)
                                    END IF
                                ELSE
                                    LINE (0, 20)-(100, 36), &H66666666, BF
                                END IF

                            CASE 40 TO 56
                                IF _MOUSEBUTTON(1) THEN
                                    IF win_Img THEN
                                        freeWin win_Img
                                        win_Img = 0
                                    ELSE
                                        temp = __template_Win
                                        temp.IH = _NEWIMAGE(temp.W, temp.H, 32)
                                        temp.T = "Image"
                                        win_Img = newWin(temp)
                                    END IF
                                ELSE
                                    LINE (0, 40)-(100, 56), &H66666666, BF
                                END IF

                            CASE 60 TO 76
                                IF _MOUSEBUTTON(1) THEN
                                    IF win_Other THEN
                                        freeWin win_Other
                                        win_Other = 0
                                    ELSE
                                        temp = __template_Win
                                        temp.IH = _NEWIMAGE(temp.W, temp.H, 32)
                                        temp.FH = __font_Mono
                                        win_Other = newWin(temp)
                                    END IF
                                ELSE
                                    LINE (0, 60)-(100, 76), &H66666666, BF
                                END IF
                        END SELECT
                    END IF
                END IF


            CASE win_Other 'Other window
                IF w(win).NeedsRefresh THEN resizeWin win_Other
                'Window contents
                _DEST w(win).IH
                CLS , 0
                PRINT USING "X: ####  Y: ####  Z: +####"; w(win).X, w(win).Y, w(win).Z
                PRINT USING "W: ####  H: ####"; w(win).W, w(win).H
                PRINT USING "MX: ####  MY: ####  MS: +#  MAS: ####"; w(win).MX, w(win).MY, w(win).MS, w(win).MAS
                PRINT USING "IH: ########  FH: ########  win: ###"; w(win).IH, w(win).FH, win

                'Window title
                w(win).T = "Window " + LTRIM$(STR$(win)) + " (" + LTRIM$(STR$(w(win).X)) + "," + LTRIM$(STR$(w(win).Y)) + ")-(" + LTRIM$(STR$(w(win).W + w(win).X)) + "," + LTRIM$(STR$(w(win).H + w(win).Y)) + ")"

        END SELECT
    NEXT
    upd
    _DISPLAY
    _LIMIT 60
LOOP






$CHECKING:OFF
SUB splitIntoWords (words() AS STRING, text AS STRING)
    DIM sp AS _UNSIGNED LONG, oldSp AS _UNSIGNED LONG
    DIM nextWord AS _UNSIGNED LONG
    REDIM words(1000) AS STRING
    DO
        oldSp = sp + 1
        sp = INSTR(oldSp, text, " ")
        IF sp = 0 THEN EXIT DO

        IF nextWord > UBOUND(words) THEN EXIT DO
        words(nextWord) = MID$(text, oldSp, sp - oldSp) + " "
        nextWord = nextWord + 1
    LOOP
    words(nextWord) = MID$(text, oldSp)
    REDIM _PRESERVE words(nextWord + 1) AS STRING
END SUB

SUB printWithWrap (text AS STRING, win AS INTEGER)
    SHARED w() AS winType

    IF w(win).MAS > 0 THEN w(win).MAS = 0
    REM $DYNAMIC
    DIM words(1) AS STRING
    CALL splitIntoWords(words(), text)

    _DEST w(win).IH
    CLS , 0

    DIM wordCount AS _UNSIGNED LONG
    DIM current_X AS _UNSIGNED LONG, current_Y AS _UNSIGNED LONG
    current_X = 0
    current_Y = w(win).MAS

    FOR wordCount = 0 TO UBOUND(words) ' for word wrapping
        DIM wordSize AS _UNSIGNED INTEGER

        IF words(wordCount) = "" THEN _CONTINUE 'prevent Illegal function calls

        IF ASC(words(wordCount)) = 13 THEN 'if its a newline character
            current_Y = current_Y + _FONTHEIGHT(w(win).FH)
            current_X = 0
            _CONTINUE
        END IF

        wordSize = _PRINTWIDTH(words(wordCount), w(win).IH)

        IF wordSize + current_X > w(win).W THEN
            current_Y = current_Y + _FONTHEIGHT(w(win).FH)

            IF current_Y > w(win).H THEN EXIT FOR

            current_X = 0
        END IF

        _PRINTSTRING (current_X, current_Y), words(wordCount), w(win).IH
        current_X = current_X + wordSize
    NEXT
    LINE (current_X, current_Y)-STEP(0, _FONTHEIGHT(w(win).FH))
END SUB

$CHECKING:ON


$CHECKING:OFF
$IF LIGHT = TRUE THEN
        Sub putWin (w As winType)
        Shared __param_TBHeight As _Unsigned _byte

        If w.IH = 0 Then Exit Sub 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!
        _DontBlend

        If w.Z = 0 Then
        Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF000000, BF
        Else Line (w.X, w.Y)-Step(w.W + 2, w.H + __param_TBHeight + 1), &HFF999999, BF
        End If

        _PrintString ((w.W - _PrintWidth(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

        _PutImage (w.X + 1, w.Y + __param_TBHeight), w.IH, , (0, 0)-Step(w.W, w.H) ' Put the contents of the window down
        End Sub
$ELSE
    SUB putWin (w AS winType)
        SHARED __param_TBHeight AS _UNSIGNED _BYTE

        'For speed
        REM RGBA32(0, 0, 0, 10)  = &H0A000000
        REM RGBA32(0, 0, 0, 200) = &HC8000000
        REM RGBA32(0, 0, 0, 64)  = &H40000000

        'LINE (w.X - 2, w.Y - 2)-STEP(w.W + 6, w.H + __param_TBHeight + 6), &H2A000000, BF 'Shadow

        IF w.IH = 0 THEN EXIT SUB 'Make sure the handle isn't invalid to prevent Illegal Function Call errors!

        IF w.Z = 0 THEN
            LINE (w.X, w.Y)-STEP(w.W + 2, w.H + __param_TBHeight + 1), &HC8000000, BF 'Window backing
        END IF

        _PRINTSTRING ((w.W - _PRINTWIDTH(w.T, 0)) / 2 + w.X, w.Y + 1), w.T ' Title

        _PUTIMAGE (w.X + 1, w.Y + __param_TBHeight), w.IH, , (0, 0)-STEP(w.W, w.H) ' No stretch one
        'PutImage (w.X + 1, w.Y + __param_TBHeight)-Step(w.W, w.H), w.IH ' Put the contents of the window down

        LINE (w.X, w.Y)-STEP(w.W + 2, w.H + __param_TBHeight + 1), &HFF000000, B ' Outline

        IF w.Z THEN LINE (w.X, w.Y)-STEP(w.W + 2, w.H + __param_TBHeight + 1), &H40000000, BF 'Dark overlay if not focused
    END SUB

    SUB putOverlay (w AS winType)
        SHARED __param_TBHeight AS _UNSIGNED _BYTE
        LINE (w.X, w.Y)-STEP(w.W, w.H), &HFF000000, B
        _PUTIMAGE (w.X + 1, w.Y + 1), w.IH
    END SUB
$END IF
$CHECKING:ON


$CHECKING:OFF
SUB upd
    SHARED w() AS winType
    SHARED winZOrder() AS _BYTE
    SHARED __image_Background AS LONG
    SHARED __image_Screen AS LONG
    SHARED __image_ScreenBuffer AS LONG
    SHARED __image_Cursor AS LONG
    SHARED __param_ScreenFont AS LONG
    'Shared __inKey$

    __inKey$ = INKEY$

    $IF HW = TRUE THEN
            IF _RESIZE THEN
            DIM tempImage AS LONG

            tempImage = _NEWIMAGE(_RESIZEWIDTH, _RESIZEHEIGHT, 32)
            SCREEN tempImage

            _FREEIMAGE __image_Screen
            __image_Screen = _NEWIMAGE(_RESIZEWIDTH, _RESIZEHEIGHT, 32)

            _FREEIMAGE __image_ScreenBuffer
            __image_ScreenBuffer = _COPYIMAGE(tempImage, 33)

            _FONT __param_ScreenFont, __image_ScreenBuffer
            _printmode _keepbackground,__image_screenbuffer
            SCREEN __image_Screen

            _FREEIMAGE tempImage
            END IF

            _DEST __image_ScreenBuffer
    $ELSE
        IF (_RESIZE) THEN 'If the program window is resizing
            SCREEN 0
            _FREEIMAGE __image_Screen
            __image_Screen = _NEWIMAGE(_RESIZEWIDTH, _RESIZEHEIGHT, 32)
            SCREEN __image_Screen
            _FONT __param_ScreenFont, __image_Screen
            _PRINTMODE _KEEPBACKGROUND , __image_Screen
        END IF

        _DEST _DISPLAY
    $END IF

    _PUTIMAGE , __image_Background 'Put the background image down on top of the previous frame's contents so we don't paint the screen. (although that would be noice...)
    _PRINTSTRING (0, 0), "FPS:" + STR$(fps) 'the fps function is fps the amount of times it's called in a second.

    fixFocusArray

    DIM i AS INTEGER
    FOR i = UBOUND(winZOrder) TO LBOUND(winZOrder) STEP -1
        IF winZOrder(i) <> 0 THEN
            IF w(winZOrder(i)).T = "" THEN putOverlay w(winZOrder(i)) ELSE putWin w(winZOrder(i))
        END IF
    NEXT

    _PUTIMAGE (_MOUSEX, _MOUSEY), __image_Cursor

    $IF HW = TRUE THEN
            _PUTIMAGE , __image_ScreenBuffer, __image_Screen
    $END IF
END SUB
$CHECKING:ON





'$Checking:Off
FUNCTION newWin% (template AS winType)
    SHARED w() AS winType

    _FONT template.FH, template.IH
    template.X = _MOUSEX
    template.Y = _MOUSEY
    DIM i AS INTEGER
    FOR i = LBOUND(w) TO UBOUND(w)

        IF (w(i).IH = 0) THEN
            logP "INFO> newWin: Empty slot " + STR$(i) + " now holds window with image handle of " + STR$(w(i).IH)
            GOTO e
        END IF

    NEXT
    REDIM _PRESERVE w(LBOUND(w) TO UBOUND(w) + 1) AS winType
    i = UBOUND(w)
    logP "INFO> newWin: Extending w() to " + STR$(i) + " for window with image handle of " + STR$(w(i).IH)

    e:
    IF template.T <> "" THEN template.T = template.T + " (" + LTRIM$(STR$(i)) + ")"
    w(i) = template
    IF w(i).Z = 0 THEN grabFocus i
    newWin% = i
END FUNCTION
'$Checking:On




'$Checking:Off
SUB logP (s AS STRING)
    SHARED w() AS winType
    SHARED win_Log AS INTEGER

    STATIC l AS STRING

    DIM i AS LONG
    i = _DEST

    IF s <> "" THEN l = l + s + " " + CHR$(13) + " "

    IF win_Log THEN
        IF w(win_Log).IH THEN
            printWithWrap l, win_Log
            _DEST i 'Restore the DEST IMAGE
        END IF
    END IF
END SUB
'$Checking:On




FUNCTION fps%
    STATIC t AS DOUBLE
    DIM t2 AS DOUBLE

    t2 = TIMER(0.0001)
    fps = 1 / (t2 - t)
    t = t2
END FUNCTION





SUB freeWin (hdl AS INTEGER)
    SHARED w() AS winType

    IF w(hdl).IH = 0 THEN logP "ERROR> freeWin: Window " + LTRIM$(STR$(hdl)) + " doesn't exist": EXIT SUB
    _FREEIMAGE w(hdl).IH
    w(hdl).IH = 0
END SUB




$CHECKING:OFF
SUB updateMouse
    SHARED w() AS winType
    SHARED winZOrder() AS _BYTE
    SHARED __param_TBHeight AS _UNSIGNED _BYTE


    STATIC optMenu AS INTEGER, optWin AS INTEGER
    STATIC mLockX AS SINGLE, mLockY AS SINGLE 'Or as I like to call it, mmmlocks and mmmlockie
    STATIC mouseLatch AS _BIT

    DIM win AS INTEGER, i AS INTEGER
    FOR win = LBOUND(winZOrder) TO UBOUND(winZOrder)
        i = winZOrder(win)

        IF i = 0 THEN _CONTINUE

        IF w(i).T = "" THEN
            w(i).MX = _MOUSEX - (w(i).X + 1)
            w(i).MY = _MOUSEY - (w(i).Y + 1)
        ELSE
            w(i).MX = _MOUSEX - (w(i).X + 1)
            w(i).MY = _MOUSEY - (w(i).Y + __param_TBHeight + 1)
        END IF

        IF mouseIsOver(i) THEN

            IF _MOUSEBUTTON(1) AND (__inKey$ = " ") THEN 'Open options (Middle click)
                IF optMenu = 0 THEN
                    __template_WinOptions.IH = _COPYIMAGE(__template_WinOptions.IH, 32) 'So that when we inevitably freeWin the option menu, we dont erase the template's image
                    __template_WinOptions.X = w(i).X
                    __template_WinOptions.Y = w(i).Y

                    optMenu = newWin(__template_WinOptions)
                    grabFocus optMenu

                    optWin = i
                    mouseLatch = True
                END IF

            ELSEIF (_MOUSEBUTTON(1) OR _MOUSEBUTTON(2)) AND (mouseLatch = False) THEN
                grabFocus i
                mouseLatch = True

            ELSEIF (__focusedWindow = i) AND (NOT _MOUSEBUTTON(1)) AND (NOT _MOUSEBUTTON(2)) THEN mouseLatch = False
            END IF

            REM ElseIf (mouseIsOver(i) = false) And (MouseButton(1)) Then __focusedWindow = 0
            REM ElseIf (mouseIsOver(i)) And (MouseButton(1)) Then grabFocus i
        END IF


    NEXT

    IF (optMenu <> 0) AND (__inKey$ <> " ") THEN
        IF _MOUSEBUTTON(1) THEN
            IF mouseIsOver(optMenu) THEN
                freeWin optWin
                freeWin optMenu
                optMenu = 0
            ELSE
                freeWin optMenu
                optMenu = 0
            END IF
        END IF
    END IF

    IF __focusedWindow THEN
        w(__focusedWindow).MS = _MOUSEWHEEL
        IF w(__focusedWindow).MS <> 0 THEN w(__focusedWindow).NeedsRefresh = True: w(__focusedWindow).MAS = w(__focusedWindow).MAS + w(__focusedWindow).MS

        IF _MOUSEBUTTON(1) THEN 'Move (Left click)
            w(__focusedWindow).X = w(__focusedWindow).X + (_MOUSEX - mLockX)
            w(__focusedWindow).Y = w(__focusedWindow).Y + (_MOUSEY - mLockY)

        ELSEIF _MOUSEBUTTON(2) THEN 'Resize (Right click)
            w(__focusedWindow).W = w(__focusedWindow).W + (_MOUSEX - mLockX)
            w(__focusedWindow).H = w(__focusedWindow).H + (_MOUSEY - mLockY)
            $IF LIGHT = FALSE THEN
                w(__focusedWindow).NeedsRefresh = True
            $END IF

            $IF LIGHT = TRUE THEN
                    ElseIf (w(__focusedWindow).W <> _Width(w(__focusedWindow).IH)) Or (w(__focusedWindow).H <> _Height(w(__focusedWindow).IH)) Then
                    w(__focusedWindow).NeedsRefresh = True
            $END IF
            'Else
            'w(__focusedWindow).NeedsRefresh = False

    END IF: END IF

    mLockX = _MOUSEX
    mLockY = _MOUSEY
END SUB
$CHECKING:ON





SUB fixFocusArray
    SHARED winZOrder() AS _BYTE
    SHARED w() AS winType

    ERASE winZOrder

    DIM i AS INTEGER
    'For i = LBound(w) To UBound(w)
    '    If w(i).T = "" Then winZOrder(UBound(winZOrder)) = i
    'Next

    FOR i = UBOUND(w) TO LBOUND(w) STEP -1 'Prioritize newer windows by going backwards
        IF w(i).IH = 0 THEN _CONTINUE
        IF i = __focusedWindow THEN
            w(i).Z = 0
            winZOrder(0) = i
            _CONTINUE
        END IF

        DO UNTIL winZOrder(w(i).Z) = 0
            w(i).Z = w(i).Z + 1
        LOOP
        winZOrder(w(i).Z) = i
    NEXT
END SUB



SUB resizeWin (win AS INTEGER)
    SHARED w() AS winType
    _FREEIMAGE w(win).IH
    w(win).IH = _NEWIMAGE(w(win).W, w(win).H, 32)
    setPM w(win).PM, w(win).IH
    _FONT w(win).FH, w(win).IH
    w(win).NeedsRefresh = False
END SUB



SUB setPM (PM AS _UNSIGNED _BYTE, IH AS LONG)
    SELECT CASE PM
        CASE __PM_KeepBackground: _PRINTMODE _KEEPBACKGROUND , IH
        CASE __PM_OnlyBackground: _PRINTMODE _ONLYBACKGROUND , IH
        CASE __PM_FillBackground: _PRINTMODE _FILLBACKGROUND , IH
        CASE ELSE: logP "ERROR> setPM: Invalid mode '" + STR$(PM) + "'"
    END SELECT
END SUB




FUNCTION mouseIsOver` (win AS INTEGER)
    SHARED w() AS winType
    mouseIsOver` = ((_MOUSEX >= w(win).X) AND (_MOUSEX <= (w(win).X + w(win).W)) AND (_MOUSEY >= w(win).Y) AND (_MOUSEY <= (w(win).Y + w(win).H)))
END FUNCTION






SUB grabFocus (win AS INTEGER)
    SHARED w() AS winType
    DIM i AS INTEGER
    FOR i = LBOUND(w) TO UBOUND(w)
        IF i = win THEN w(i).Z = 0 ELSE w(i).Z = w(i).Z + 1
    NEXT
    __focusedWindow = win
END SUB




SUB sendWin (w AS winType, c AS LONG)
    DIM i AS _UNSIGNED _BYTE
    i = 0
    PUT #c, , i
    PUT #c, , w.X
    PUT #c, , w.Y
    PUT #c, , w.Z
    PUT #c, , w.W
    PUT #c, , w.H
    PUT #c, , w.NeedsRefresh
    _SOURCE w.IH

    DIM x AS INTEGER, y AS INTEGER, clr AS LONG

    x = _WIDTH(w.IH)
    PUT #c, , x

    y = _HEIGHT(w.IH)
    PUT #c, , y

    FOR x = 0 TO _WIDTH(w.IH)
        FOR y = 0 TO _HEIGHT(w.IH)
            clr = POINT(x, y)
            PUT #c, , clr
    NEXT y, x
END SUB



SUB getWin (c AS LONG)
    SHARED temp AS winType
    DIM i AS _UNSIGNED _BYTE
    DO
        i = 1
        IF LOF(c) THEN GET #c, , i
    LOOP UNTIL i = 0
    DO: LOOP UNTIL LOF(c)
    GET #c, , temp.X
    DO: LOOP UNTIL LOF(c)
    GET #c, , temp.Y
    DO: LOOP UNTIL LOF(c)
    GET #c, , temp.Z
    DO: LOOP UNTIL LOF(c)
    GET #c, , temp.W
    DO: LOOP UNTIL LOF(c)
    GET #c, , temp.H
    DO: LOOP UNTIL LOF(c)
    GET #c, , temp.NeedsRefresh

    DIM x AS INTEGER, y AS INTEGER
    DO: LOOP UNTIL LOF(c)
    GET #c, , x

    DO: LOOP UNTIL LOF(c)
    GET #c, , y

    IF temp.IH = 0 OR temp.IH = -1 THEN _FREEIMAGE temp.IH
    temp.IH = _NEWIMAGE(x, y, 32)
    _DEST temp.IH

    DIM clr AS LONG
    FOR x = 0 TO _WIDTH(temp.IH)
        FOR y = 0 TO _HEIGHT(temp.IH)
            DO: LOOP UNTIL LOF(c)
            GET #c, , clr
            PSET (x, y), clr
    NEXT y, x
END SUB
