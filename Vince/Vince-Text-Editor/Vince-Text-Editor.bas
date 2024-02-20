DEFINT A-Z

CONST sw = 800
CONST sh = 600

CONST winBarH = 25
CONST winMinW = 50
CONST winMinH = 50

CONST fontSize = 16

TYPE nodeType
    str AS _MEM
    strLen AS INTEGER

    n AS _MEM
    p AS _MEM
END TYPE

TYPE listType
    head AS _MEM
    tail AS _MEM

    cur AS _MEM

    cx AS INTEGER
    cy AS INTEGER
    scroll AS INTEGER
    scrollmax AS INTEGER
END TYPE

TYPE winType
    x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER

    img AS LONG

    cap AS STRING * 128

    pid AS INTEGER
    text AS listType
END TYPE

DIM SHARED mx, my, mbr, mbl, mw

DIM tmem AS _MEM
DIM SHARED win(50) AS winType, wn

win(0).x = 10
win(0).y = 10
win(0).w = 320
win(0).h = 240
win(0).img = _NEWIMAGE(win(0).w + 1, win(0).h + 1, 32)
win(0).cap = "command prompt 0"
win(0).pid = 2
newList win(0).text
addNodeNext win(0).text.cur, ">", win(0).text.head, win(0).text
win(0).text.cx = 1
nextNode win(0).text.cur, win(0).text.head

win(1).x = 400
win(1).y = 10
win(1).w = 320
win(1).h = 240
win(1).cap = "textbox 1"
win(1).img = _NEWIMAGE(win(1).w + 1, win(1).h + 1, 32)
win(1).pid = 1
newList win(1).text
addNodeNext win(1).text.cur, "", win(1).text.head, win(1).text
nextNode win(0).text.cur, win(0).text.head

win(2).x = 200
win(2).y = 300
win(2).w = 520
win(2).h = 240
win(2).cap = "textbox 2"
win(2).img = _NEWIMAGE(win(2).w + 1, win(2).h + 1, 32)
win(2).pid = 1
newList win(2).text
addNodeNext win(2).text.cur, "I", win(2).text.head, win(2).text
addNodeNext win(2).text.cur, "am", win(2).text.cur, win(2).text
addNodeNext win(2).text.cur, "a", win(2).text.cur, win(2).text
addNodeNext win(2).text.cur, "textbox", win(2).text.cur, win(2).text
nextNode win(2).text.cur, win(2).text.head

win(3).x = 15
win(3).y = 305
win(3).w = 160
win(3).h = 120
win(3).cap = "about"
win(3).img = _NEWIMAGE(win(3).w + 1, win(3).h + 1, 32)
win(3).pid = 0
'newList win(3).text
'addNodeNext win(3).text.cur, "", win(3).text.head, win(3).text

wn = 3

DIM SHARED bg AS _INTEGER64, p1 AS _INTEGER64
p1 = _NEWIMAGE(sw, sh, 32)
bg = _NEWIMAGE(sw, sh, 32)
_DEST bg
LINE (0, 0)-(sw, sh), _RGB(0, 0, 0), BF
FOR y = 0 TO sh STEP 4
    LINE (0, y)-(sw, y), _RGB(42, 42, 42), , &H8888
    LINE (1, y + 1)-(sw, y + 1), _RGB(42, 42, 42), , &H8888
    LINE (3, y + 2)-(sw, y + 2), _RGB(42, 42, 42), , &H8888
    LINE (2, y + 3)-(sw, y + 3), _RGB(42, 42, 42), , &H8888
NEXT
'circle (sw\2, sh\2),100,_rgb(0,50,105)
'for a# = 0 to 2*3.141593 step 2*3.141593/6
'   x# = 100*cos(a#) + sw\2
'   y# = 100*sin(a#) + sh\2
'   circle(x#, y#),100,_rgb(0,50,105)
'   for b# = 0 to 2*3.141593 step 2*3.141593/6
'       xx# = x# + 100*cos(b#)
'       yy# = y# + 100*sin(b#)
'       circle(xx#, yy#),100,_rgb(0,50,105)
'       for c# = 0 to 2*3.141593 step 2*3.141593/6
'           circle(xx# + 100*cos(b#), yy# + 100*sin(b#)),100,_rgb(0,50,105)
'       next
'   next
'next
_DEST 0

SCREEN _NEWIMAGE(sw, sh, 32)

FOR i = 0 TO wn
    drawWin (i)
NEXT

redraw

DIM temp AS winType
DIM k AS LONG

DO
    mw = 0
    getMouse
    k = _KEYHIT

    IF wn >= 0 THEN

        '''process current window left mouse button events
        IF mbl THEN
            'mouse over current window
            tabw = tabWidth(0)
            IF mbox(win(0).x, win(0).y, win(0).w, win(0).h) THEN
                IF mbox(win(0).x, win(0).y, win(0).w, winBarH) AND NOT mbox(win(0).x + tabw, win(0).y, win(0).w - tabw, winBarH) THEN
                    IF mbox(win(0).x + tabw - winBarH + 3, win(0).y + 3, winBarH - 6, winBarH - 6) THEN
                        '''resize
                        _DEST p1
                        redraw
                        _DEST 0

                        boxx = win(0).x
                        boxy = win(0).y
                        boxw = win(0).w
                        boxh = win(0).h
                        drawBox boxx, boxy, boxw, boxh
                        _DISPLAY

                        stuck = 0
                        omx = mx
                        omy = my
                        DO WHILE mbl
                            getMouse

                            IF omx <> mx OR omy <> my THEN
                                IF NOT mbox(boxx, boxy, boxw, boxh) THEN
                                    IF mx <= boxx THEN
                                        stuck = stuck OR 1
                                    ELSEIF mx >= boxx + boxw THEN
                                        stuck = stuck OR 2
                                    END IF
                                    IF my <= boxy THEN
                                        stuck = stuck OR 4
                                    ELSEIF my >= boxy + boxh THEN
                                        stuck = stuck OR 8
                                    END IF
                                END IF

                                IF stuck AND 1 THEN
                                    boxx = mx
                                    boxw = win(0).w + win(0).x - mx

                                    IF boxw <= 50 THEN stuck = stuck XOR 1
                                ELSEIF stuck AND 2 THEN
                                    boxx = win(0).x
                                    boxw = mx - win(0).x

                                    IF boxw <= 50 THEN stuck = stuck XOR 2
                                END IF
                                IF stuck AND 4 THEN
                                    boxy = my
                                    boxh = win(0).h + win(0).y - my

                                    IF boxh <= 50 THEN stuck = stuck XOR 4
                                ELSEIF stuck AND 8 THEN
                                    boxy = win(0).y
                                    boxh = my - win(0).y

                                    IF boxh <= 50 THEN stuck = stuck XOR 8
                                END IF

                                _PUTIMAGE , p1
                                drawBox boxx, boxy, boxw, boxh
                                _DISPLAY

                                omx = mx
                                omy = my
                            END IF
                        LOOP

                        win(0).x = boxx
                        win(0).y = boxy
                        win(0).w = boxw
                        win(0).h = boxh
                        _FREEIMAGE win(0).img
                        win(0).img = _NEWIMAGE(win(0).w + 1, win(0).h + 1, 32)

                        SELECT CASE win(0).pid
                            CASE 1
                                win(0).text.cx = 0
                                FOR i = 1 TO win(0).text.cy
                                    prevNode win(0).text.cur, win(0).text.cur
                                NEXT
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen
                                win(0).text.cy = 0
                            CASE 2
                                win(0).text.cx = 1
                                FOR i = 1 TO win(0).text.cy
                                    prevNode win(0).text.cur, win(0).text.cur
                                NEXT
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen
                                win(0).text.cy = 0

                        END SELECT

                        drawWin (0)

                        redraw
                        _DISPLAY
                    ELSEIF mbox(win(0).x + 3, win(0).y + 3, winBarH - 6, winBarH - 6) THEN
                        '''close
                        DO WHILE mbr
                            getMouse
                        LOOP

                        closeWin (0)

                    ELSE
                        '''drag
                        'partial redraw
                        _DEST p1
                        _PUTIMAGE , bg

                        FOR i = wn TO 1 STEP -1
                            _PUTIMAGE (win(i).x, win(i).y), win(i).img
                        NEXT
                        _DEST 0

                        omx = mx
                        omy = my
                        owx = mx - win(0).x
                        owy = my - win(0).y
                        DO WHILE mbl
                            getMouse

                            IF mx <> omx OR my <> omy THEN
                                _PUTIMAGE (win(0).x, win(0).y), p1, , (win(0).x, win(0).y)-(win(0).x + win(0).w, win(0).y + win(0).h)
                                win(0).x = mx - owx
                                win(0).y = my - owy

                                '''''
                                '''''''''''fixxx thisss!!!
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img

                                _DISPLAY

                                omx = mx
                                omy = my
                            END IF
                        LOOP
                    END IF
                END IF

            ELSE
                'mouse over other windows
                FOR i = 1 TO wn
                    tabw = tabWidth(i)
                    IF mbox(win(i).x, win(i).y, win(i).w, win(i).h) AND NOT mbox(win(i).x + tabw, win(i).y, win(i).w - tabw, winBarH) THEN
                        temp = win(i)
                        FOR j = i TO 1 STEP -1
                            win(j) = win(j - 1)
                        NEXT
                        win(0) = temp

                        drawWin (0)
                        drawWin (1)
                        redraw
                        _DISPLAY

                        EXIT FOR
                    END IF
                NEXT

            END IF
        END IF
        '''

        '''process current window right mouse button events
        IF mbr THEN
            '''close [old]
            'if mbox(win(0).x, win(0).y, win(0).w, winBarH) then
            '   do while mbr
            '       getMouse
            '   loop

            '   closeWin(0)

            'end if
        END IF
        '''

        '''process current window mouse wheel events
        IF mw <> 0 THEN
            SELECT CASE win(0).pid
                CASE 1
                    '''scroll

                    IF mw < 0 THEN
                        'scrolling up
                        IF win(0).text.scroll > 0 THEN
                            win(0).text.scroll = win(0).text.scroll - 1

                            IF win(0).text.cy < (win(0).h - winBarH - 6) \ fontSize - 1 THEN
                                win(0).text.cy = win(0).text.cy + 1
                            ELSEIF -1 THEN
                                prevNode win(0).text.cur, win(0).text.cur
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen
                            END IF
                        END IF
                        'scrolling down
                    ELSEIF mw > 0 THEN
                        IF win(0).text.scroll + mw < win(0).text.scrollmax THEN
                            win(0).text.scroll = win(0).text.scroll + 1

                            IF win(0).text.cy > 0 THEN
                                win(0).text.cy = win(0).text.cy - 1
                            ELSEIF -1 THEN
                                nextNode win(0).text.cur, win(0).text.cur
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen
                            END IF
                        END IF
                    END IF

                    drawWin (0)
                    _PUTIMAGE (win(0).x, win(0).y), win(0).img
                    _DISPLAY
            END SELECT
        END IF
        '''

        '''process current window keyboard controls
        IF k <> 0 THEN
            SELECT CASE win(0).pid
                'about window
                CASE 0

                    'textbox
                CASE 1
                    SELECT CASE k

                        'right
                        CASE 19712
                            IF win(0).text.cx < LEN(readNode$(win(0).text.cur)) AND win(0).text.cx < (win(id).w - 8) \ 8 THEN
                                win(0).text.cx = win(0).text.cx + 1
                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF

                            'left
                        CASE 19200
                            IF win(0).text.cx > 0 THEN win(0).text.cx = win(0).text.cx - 1
                            drawWin (0)
                            _PUTIMAGE (win(0).x, win(0).y), win(0).img
                            _DISPLAY

                            'down
                        CASE 20480
                            IF win(0).text.cy < (win(0).h - winBarH - 6) \ fontSize - 1 THEN
                                IF win(0).text.cy + win(0).text.scroll + 1 < win(0).text.scrollmax THEN
                                    win(0).text.cy = win(0).text.cy + 1

                                    nextNode win(0).text.cur, win(0).text.cur
                                    curlen = lenNode(win(0).text.cur)
                                    IF win(0).text.cx > curlen THEN win(0).text.cx = curlen

                                    drawWin (0)
                                    _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                    _DISPLAY
                                END IF
                            ELSEIF win(0).text.scroll + win(0).text.cy + 1 < win(0).text.scrollmax THEN
                                win(0).text.scroll = win(0).text.scroll + 1

                                nextNode win(0).text.cur, win(0).text.cur
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen

                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF

                            'up
                        CASE 18432
                            IF win(0).text.cy > 0 THEN
                                win(0).text.cy = win(0).text.cy - 1

                                prevNode win(0).text.cur, win(0).text.cur
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen

                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            ELSEIF win(0).text.scroll > 0 THEN
                                win(0).text.scroll = win(id).text.scroll - 1

                                prevNode win(0).text.cur, win(0).text.cur
                                curlen = lenNode(win(0).text.cur)
                                IF win(0).text.cx > curlen THEN win(0).text.cx = curlen

                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF

                            'enter
                        CASE 13
                            IF win(0).text.cx = 0 THEN
                                addNodePrev win(0).text.cur, "", win(0).text.cur, win(0).text
                                nextNode win(0).text.cur, win(0).text.cur

                            ELSEIF win(0).text.cx >= lenNode(win(0).text.cur) THEN
                                addNodeNext win(0).text.cur, "", win(0).text.cur, win(0).text
                            ELSEIF -1 THEN
                                rn$ = readNode$(win(0).text.cur)
                                curlen = lenNode(win(0).text.cur)
                                lt$ = LEFT$(rn$, win(0).text.cx)
                                rt$ = MID$(rn$, win(0).text.cx + 1, curlen - cx - 1)

                                writeNode win(0).text.cur, lt$

                                addNodeNext win(0).text.cur, rt$, win(0).text.cur, win(0).text
                            END IF

                            win(0).text.cx = 0

                            IF win(0).text.cy < (win(0).h - winBarH - 6) \ fontSize - 1 THEN
                                IF win(0).text.cy + win(0).text.scroll + 1 < win(0).text.scrollmax THEN
                                    win(0).text.cy = win(0).text.cy + 1

                                    drawWin (0)
                                    _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                    _DISPLAY
                                END IF
                            ELSEIF win(0).text.scroll + win(0).text.cy + 1 < win(0).text.scrollmax THEN
                                win(0).text.scroll = win(0).text.scroll + 1

                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF

                            'backspace
                        CASE 8
                            IF win(0).text.cx > 0 THEN
                                rn$ = readNode$(win(0).text.cur)

                                lt$ = LEFT$(rn$, win(0).text.cx - 1)
                                rt$ = MID$(rn$, win(0).text.cx + 1, curlen - cx - 1)

                                writeNode win(0).text.cur, lt$ + rt$

                                win(0).text.cx = win(0).text.cx - 1

                            ELSEIF win(0).text.cx = 0 THEN
                                IF win(0).text.cy > 0 OR win(0).text.scroll > 0 THEN
                                    s$ = readNode$(win(0).text.cur)
                                    tmem = win(0).text.cur
                                    prevNode win(0).text.cur, win(0).text.cur
                                    win(0).text.cx = lenNode(win(0).text.cur)
                                    s$ = readNode$(win(0).text.cur) + s$
                                    writeNode win(0).text.cur, s$
                                    rmNode tmem, win(0).text

                                    IF win(0).text.cy > 0 THEN
                                        win(0).text.cy = win(0).text.cy - 1
                                    ELSEIF win(0).text.cy = 0 THEN
                                        IF win(0).text.scroll > 0 THEN
                                            win(0).text.scroll = win(0).text.scroll - 1
                                        END IF
                                    END IF
                                END IF
                            END IF

                            drawWin (0)
                            _PUTIMAGE (win(0).x, win(0).y), win(0).img
                            _DISPLAY

                        CASE 32 TO 126
                            IF win(0).text.cx < (win(id).w - 8) \ 8 THEN


                                rn$ = readNode$(win(0).text.cur)
                                IF win(0).text.cx = 0 THEN
                                    rn$ = "$" + rn$
                                    writeNode win(0).text.cur, CHR$(k) + readNode$(win(0).text.cur)
                                ELSEIF win(0).text.cx >= lenNode(win(0).text.cur) THEN
                                    writeNode win(0).text.cur, readNode$(win(0).text.cur) + CHR$(k)
                                ELSEIF -1 THEN
                                    curlen = lenNode(win(0).text.cur)
                                    writeNode win(0).text.cur, LEFT$(rn$, win(0).text.cx) + CHR$(k) + MID$(rn$, win(0).text.cx + 1, curlen - cx - 1)
                                END IF

                                win(0).text.cx = win(0).text.cx + 1

                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF
                    END SELECT

                    'command prompt
                CASE 2
                    SELECT CASE k

                        'right
                        CASE 19712
                            IF win(0).text.cx < LEN(readNode$(win(0).text.cur)) AND win(0).text.cx < (win(id).w - 8) \ 8 THEN
                                win(0).text.cx = win(0).text.cx + 1
                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF

                            'left
                        CASE 19200
                            IF win(0).text.cx > 0 THEN win(0).text.cx = win(0).text.cx - 1
                            drawWin (0)
                            _PUTIMAGE (win(0).x, win(0).y), win(0).img
                            _DISPLAY


                            'enter
                        CASE 13
                            result$ = ""
                            rn$ = readNode$(win(0).text.cur)

                            IF cmd(result$, RIGHT$(rn$, LEN(rn$) - 1), 0) THEN
                                addNodePrev win(0).text.cur, rn$, win(0).text.cur, win(0).text
                                addNodeNext win(0).text.cur, result$, win(0).text.cur, win(0).text
                                nextNode win(0).text.cur, win(0).text.cur
                                writeNode win(0).text.cur, ">"

                                win(0).text.cx = 1


                                IF win(0).text.cy < (win(0).h - winBarH - 6) \ fontSize - 1 THEN
                                    IF win(0).text.cy + win(0).text.scroll + 1 < win(0).text.scrollmax THEN
                                        win(0).text.cy = win(0).text.cy + 2

                                        drawWin (0)
                                        _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                        _DISPLAY
                                    END IF
                                ELSEIF win(0).text.scroll + win(0).text.cy + 1 < win(0).text.scrollmax THEN
                                    win(0).text.scroll = win(0).text.scroll + 1

                                    drawWin (0)
                                    _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                    _DISPLAY
                                END IF
                            ELSE
                                closeWin (0)
                            END IF

                            'backspace
                        CASE 8
                            IF win(0).text.cx > 1 THEN
                                rn$ = readNode$(win(0).text.cur)

                                lt$ = LEFT$(rn$, win(0).text.cx - 1)
                                rt$ = MID$(rn$, win(0).text.cx + 1, curlen - cx - 1)

                                writeNode win(0).text.cur, lt$ + rt$

                                win(0).text.cx = win(0).text.cx - 1
                            END IF

                            drawWin (0)
                            _PUTIMAGE (win(0).x, win(0).y), win(0).img
                            _DISPLAY

                        CASE 32 TO 126
                            IF win(0).text.cx < (win(id).w - 8) \ 8 THEN


                                rn$ = readNode$(win(0).text.cur)
                                IF win(0).text.cx = 0 THEN
                                    rn$ = "$" + rn$
                                    writeNode win(0).text.cur, CHR$(k) + readNode$(win(0).text.cur)
                                ELSEIF win(0).text.cx >= lenNode(win(0).text.cur) THEN
                                    writeNode win(0).text.cur, readNode$(win(0).text.cur) + CHR$(k)
                                ELSEIF -1 THEN
                                    curlen = lenNode(win(0).text.cur)
                                    writeNode win(0).text.cur, LEFT$(rn$, win(0).text.cx) + CHR$(k) + MID$(rn$, win(0).text.cx + 1, curlen - cx - 1)
                                END IF

                                win(0).text.cx = win(0).text.cx + 1

                                drawWin (0)
                                _PUTIMAGE (win(0).x, win(0).y), win(0).img
                                _DISPLAY
                            END IF
                    END SELECT
            END SELECT
        END IF
        '''

    END IF
LOOP UNTIL k = 27
SYSTEM

FUNCTION cmd (result AS STRING, in AS STRING, id)
    SELECT CASE in
        CASE "version"
            result = "vwm version 2"
            cmd = -1
        CASE "time"
            result = STR$(TIMER)
            cmd = -1
        CASE "exit"
            cmd = 0
        CASE ELSE
            result = "error"
            cmd = -1
    END SELECT
END FUNCTION

SUB getMouse ()
    DO
        mx = _MOUSEX
        my = _MOUSEY
        mbl = _MOUSEBUTTON(1)
        mbr = _MOUSEBUTTON(2)
        mw = mw + _MOUSEWHEEL
    LOOP WHILE _MOUSEINPUT
END SUB

SUB redraw ()
    _PUTIMAGE , bg

    FOR i = wn TO 0 STEP -1
        _PUTIMAGE (win(i).x, win(i).y), win(i).img
    NEXT
END SUB

SUB closeWin (id)
    _FREEIMAGE win(id).img

    SELECT CASE win(id).pid
        CASE 1 TO 2
            rmList win(id).text
    END SELECT

    wn = wn - 1
    FOR i = id TO wn
        win(i) = win(i + 1)
    NEXT

    redraw
    _DISPLAY
END SUB

SUB resizeWin (id)
END SUB

FUNCTION tabWidth (id)
    s$ = RTRIM$(win(id).cap)
    IF (LEN(s$) * 8 + winBarH * 4) > win(id).w THEN
        tabWidth = win(id).w
    ELSE
        tabWidth = winBarH * 4 + LEN(s$) * 8
    END IF
END FUNCTION

SUB drawWin (id)
    _DEST win(id).img

    'LINE (0, winBarH)-STEP(win(id).w, win(id).h - winBarH), _RGB(0, 0, 0), BF
    'LINE (0, winBarH)-STEP(win(id).w, win(id).h - winBarH), _RGB(255, 255, 255), B

    s$ = RTRIM$(win(id).cap)
    IF (LEN(s$) * 8 + winBarH * 4) > win(id).w THEN
        ss$ = LEFT$(s$, (win(id).w - winBarH * 4) \ 8)
        tabw = win(id).w
    ELSE
        ss$ = s$
        tabw = winBarH * 4 + LEN(s$) * 8
    END IF

    'line (0, 0)-step(tabw, winBarH),_rgb(0,0,0),bf
    'line (0, 0)-step(tabw, winBarH),_rgb(255,255,255),b
    'line (4, 4)-step(winBarH-8, winBarH-8),_rgb(255,255,255),b
    'line (tabw-winBarH+4, 4)-step(winBarH-8, winBarH-8),_rgb(255,255,255),b


    '''BeOS
    DIM g1 AS LONG, g2 AS LONG, g3 AS LONG
    IF id = 0 THEN
        'g1 = _RGB(255, 255, 82)
        'g2 = _RGB(255, 206, 0)
        'g3 = _RGB(173, 123, 0)
        c0 = _RGBA32(255, 255, 57, 255)
        c1 = _RGBA32(255, 239, 33, 255)
        c2 = _RGBA32(255, 206, 0, 255)
        c3 = _RGBA32(239, 181, 0, 255)
        c4 = _RGBA32(214, 156, 0, 255)
    ELSE
        'g1 = _RGB(255, 255, 255)
        'g2 = _RGB(239, 239, 239)
        'g3 = _RGB(156, 156, 156)
        c0 = _RGBA32(255, 255, 255, 255)
        c1 = c0
        c2 = _RGBA32(239, 239, 239, 255)
        c3 = _RGBA32(222, 214, 222, 255)
        c4 = _RGBA32(198, 189, 198, 255)
    END IF

    '255.255.255 - c0/c1
    '239.239.239 - c2
    '222.214.222 - c3
    '198.189.198 - c4

    LINE (0, 0)-(tabw, 0), _RGB(156, 156, 156)
    LINE (tabw + 1, winBarH)-(win(id).w - 1, winBarH), _RGB(156, 156, 156)
    LINE (0, 0)-(0, win(id).h - 1), _RGB(156, 156, 156)
    LINE (tabw, 1)-(tabw, winBarH), _RGB(99, 99, 99)
    LINE (0, win(id).h)-(win(id).w, win(id).h), _RGB(99, 99, 99)
    LINE (win(id).w, winBarH - 1)-(win(id).w, win(id).h), _RGB(99, 99, 99)
    LINE (1, win(id).h - 1)-(win(id).w - 1, win(id).h - 1), _RGB(140, 140, 140)
    LINE (win(id).w - 1, win(id).h - 1)-(win(id).w - 1, winBarH + 1), _RGB(140, 140, 140)
    LINE (1, winBarH + 1)-(1, win(id).h - 2), _RGB(255, 255, 255)
    LINE (tabw - 1, winBarH + 1)-(win(id).w - 2, winBarH + 1), _RGB(255, 255, 255)
    LINE (2, winBarH + 1)-(tabw - 2, winBarH + 1), _RGB(222, 222, 222)
    LINE (2, winBarH + 2)-(win(id).w - 2, win(id).h - 2), _RGB(222, 222, 222), B
    LINE (3, winBarH + 3)-(3, win(id).h - 3), _RGB(156, 156, 156)
    LINE (3, winBarH + 3)-(win(id).w - 4, winBarH + 3), _RGB(156, 156, 156)

    LINE (4, win(id).h - 3)-(win(id).w - 4, win(id).h - 3), _RGB(255, 255, 255)
    LINE (win(id).w - 3, win(id).h - 3)-(win(id).w - 3, winBarH + 3), _RGB(255, 255, 255)

    LINE (1, 1)-(tabw - 1, 1), c1
    LINE (1, 1)-(1, winBarH), c1
    LINE (2, 2)-(tabw - 2, winBarH), c2, BF
    LINE (tabw - 1, 2)-(tabw - 1, winBarH), c3


    LeftButtonStartX = 6
    LeftButtonStartY = 6
    LINE (LeftButtonStartX + 0, LeftButtonStartY + 0)-(LeftButtonStartX + 13, LeftButtonStartY + 0), c4
    LINE (LeftButtonStartX + 0, LeftButtonStartY + 0)-(LeftButtonStartX + 0, LeftButtonStartY + 13), c4
    LINE (LeftButtonStartX + 1, LeftButtonStartY + 1)-(LeftButtonStartX + 13, LeftButtonStartY + 1), c0
    LINE (LeftButtonStartX + 1, LeftButtonStartY + 1)-(LeftButtonStartX + 1, LeftButtonStartY + 13), c0
    LINE (LeftButtonStartX + 1, LeftButtonStartY + 13)-(LeftButtonStartX + 13, LeftButtonStartY + 13), c0
    LINE (LeftButtonStartX + 13, LeftButtonStartY + 13)-(LeftButtonStartX + 13, LeftButtonStartY + 1), c0
    LINE (LeftButtonStartX + 2, LeftButtonStartY + 12)-(LeftButtonStartX + 12, LeftButtonStartY + 12), c4
    LINE (LeftButtonStartX + 12, LeftButtonStartY + 12)-(LeftButtonStartX + 12, LeftButtonStartY + 2), c4
    LINE (LeftButtonStartX + 6, LeftButtonStartY + 11)-(LeftButtonStartX + 11, LeftButtonStartY + 11), c3
    LINE (LeftButtonStartX + 7, LeftButtonStartY + 10)-(LeftButtonStartX + 11, LeftButtonStartY + 10), c3
    LINE (LeftButtonStartX + 9, LeftButtonStartY + 9)-(LeftButtonStartX + 11, LeftButtonStartY + 9), c3
    LINE (LeftButtonStartX + 10, LeftButtonStartY + 8)-(LeftButtonStartX + 11, LeftButtonStartY + 8), c3
    LINE (LeftButtonStartX + 9, LeftButtonStartY + 7)-(LeftButtonStartX + 11, LeftButtonStartY + 7), c3
    PSET (LeftButtonStartX + 11, LeftButtonStartY + 6), c3
    LINE (LeftButtonStartX + 9, LeftButtonStartY + 8)-(LeftButtonStartX + 8, LeftButtonStartY + 9), c2
    LINE (LeftButtonStartX + 8, LeftButtonStartY + 8)-(LeftButtonStartX + 7, LeftButtonStartY + 9), c3
    LINE (LeftButtonStartX + 11, LeftButtonStartY + 3)-(LeftButtonStartX + 10, LeftButtonStartY + 4), c1
    LINE (LeftButtonStartX + 6, LeftButtonStartY + 10)-(LeftButtonStartX + 5, LeftButtonStartY + 11), c2
    LINE (LeftButtonStartX + 11, LeftButtonStartY + 5)-(LeftButtonStartX + 10, LeftButtonStartY + 6), c2
    LINE (LeftButtonStartX + 11, LeftButtonStartY + 4)-(LeftButtonStartX + 4, LeftButtonStartY + 11), c2
    LINE (LeftButtonStartX + 9, LeftButtonStartY + 5)-(LeftButtonStartX + 5, LeftButtonStartY + 9), c2
    LINE (LeftButtonStartX + 4, LeftButtonStartY + 10)-(LeftButtonStartX + 3, LeftButtonStartY + 11), c1
    LINE (LeftButtonStartX + 11, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 11), c2
    LINE (LeftButtonStartX + 10, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 10), c1
    LINE (LeftButtonStartX + 8, LeftButtonStartY + 3)-(LeftButtonStartX + 3, LeftButtonStartY + 8), c2
    LINE (LeftButtonStartX + 8, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 8), c1
    LINE (LeftButtonStartX + 7, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 7), c1
    LINE (LeftButtonStartX + 6, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 6), c1
    LINE (LeftButtonStartX + 5, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 5), c1
    LINE (LeftButtonStartX + 4, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 4), c0
    LINE (LeftButtonStartX + 3, LeftButtonStartY + 2)-(LeftButtonStartX + 2, LeftButtonStartY + 3), c1
    PSET (LeftButtonStartX + 2, LeftButtonStartY + 2), c0
    PSET (LeftButtonStartX + 9, LeftButtonStartY + 2), c1
    PSET (LeftButtonStartX + 2, LeftButtonStartY + 9), c1

    RightButtonStartX = (tabw - 14) - 6
    RightButtonStartY = 6
    LINE (RightButtonStartX + 0, RightButtonStartY + 0)-(RightButtonStartX + 7, RightButtonStartY + 0), c4
    LINE (RightButtonStartX + 0, RightButtonStartY + 0)-(RightButtonStartX + 0, RightButtonStartY + 7), c4
    LINE (RightButtonStartX + 1, RightButtonStartY + 1)-(RightButtonStartX + 8, RightButtonStartY + 1), c0
    LINE (RightButtonStartX + 1, RightButtonStartY + 1)-(RightButtonStartX + 1, RightButtonStartY + 8), c0
    LINE (RightButtonStartX + 8, RightButtonStartY + 1)-(RightButtonStartX + 8, RightButtonStartY + 8), c0
    LINE (RightButtonStartX + 1, RightButtonStartY + 8)-(RightButtonStartX + 8, RightButtonStartY + 8), c0
    LINE (RightButtonStartX + 2, RightButtonStartY + 7)-(RightButtonStartX + 7, RightButtonStartY + 7), c4
    LINE (RightButtonStartX + 7, RightButtonStartY + 2)-(RightButtonStartX + 7, RightButtonStartY + 7), c4
    LINE (RightButtonStartX + 9, RightButtonStartY + 3)-(RightButtonStartX + 13, RightButtonStartY + 3), c4
    LINE (RightButtonStartX + 9, RightButtonStartY + 4)-(RightButtonStartX + 13, RightButtonStartY + 4), c0
    LINE (RightButtonStartX + 13, RightButtonStartY + 4)-(RightButtonStartX + 13, RightButtonStartY + 13), c0
    LINE (RightButtonStartX + 13, RightButtonStartY + 13)-(RightButtonStartX + 4, RightButtonStartY + 13), c0
    LINE (RightButtonStartX + 4, RightButtonStartY + 13)-(RightButtonStartX + 4, RightButtonStartY + 9), c0
    LINE (RightButtonStartX + 3, RightButtonStartY + 13)-(RightButtonStartX + 3, RightButtonStartY + 9), c4
    LINE (RightButtonStartX + 12, RightButtonStartY + 5)-(RightButtonStartX + 12, RightButtonStartY + 12), c4
    LINE (RightButtonStartX + 12, RightButtonStartY + 12)-(RightButtonStartX + 5, RightButtonStartY + 12), c4
    LINE (RightButtonStartX + 11, RightButtonStartY + 6)-(RightButtonStartX + 11, RightButtonStartY + 11), c3
    LINE (RightButtonStartX + 6, RightButtonStartY + 11)-(RightButtonStartX + 11, RightButtonStartY + 11), c3
    LINE (RightButtonStartX + 5, RightButtonStartY + 9)-(RightButtonStartX + 5, RightButtonStartY + 11), c1
    LINE (RightButtonStartX + 6, RightButtonStartY + 9)-(RightButtonStartX + 6, RightButtonStartY + 10), c1
    PSET (RightButtonStartX + 7, RightButtonStartY + 9), c1
    LINE (RightButtonStartX + 9, RightButtonStartY + 5)-(RightButtonStartX + 11, RightButtonStartY + 5), c1
    LINE (RightButtonStartX + 9, RightButtonStartY + 6)-(RightButtonStartX + 10, RightButtonStartY + 6), c1
    PSET (RightButtonStartX + 9, RightButtonStartY + 7), c1
    LINE (RightButtonStartX + 10, RightButtonStartY + 9)-(RightButtonStartX + 10, RightButtonStartY + 10), c2
    PSET (RightButtonStartX + 9, RightButtonStartY + 10), c2
    LINE (RightButtonStartX + 10, RightButtonStartY + 8)-(RightButtonStartX + 8, RightButtonStartY + 10), c1
    LINE (RightButtonStartX + 10, RightButtonStartY + 7)-(RightButtonStartX + 7, RightButtonStartY + 10), c2
    LINE (RightButtonStartX + 2, RightButtonStartY + 2)-(RightButtonStartX + 4, RightButtonStartY + 2), c1
    LINE (RightButtonStartX + 2, RightButtonStartY + 3)-(RightButtonStartX + 3, RightButtonStartY + 3), c1
    PSET (RightButtonStartX + 2, RightButtonStartY + 4), c1
    LINE (RightButtonStartX + 6, RightButtonStartY + 2)-(RightButtonStartX + 6, RightButtonStartY + 4), c2
    LINE (RightButtonStartX + 2, RightButtonStartY + 6)-(RightButtonStartX + 3, RightButtonStartY + 6), c2
    LINE (RightButtonStartX + 5, RightButtonStartY + 2)-(RightButtonStartX + 2, RightButtonStartY + 5), c2
    LINE (RightButtonStartX + 5, RightButtonStartY + 3)-(RightButtonStartX + 3, RightButtonStartY + 5), c1
    LINE (RightButtonStartX + 4, RightButtonStartY + 6)-(RightButtonStartX + 6, RightButtonStartY + 6), c3
    PSET (RightButtonStartX + 6, RightButtonStartY + 5), c3
    LINE (RightButtonStartX + 4, RightButtonStartY + 5)-(RightButtonStartX + 5, RightButtonStartY + 5), c2
    PSET (RightButtonStartX + 5, RightButtonStartY + 4), c2

    'line (tabw-(3*winBarH\4)+7, (winBarH-8)\2+3)-step

    COLOR _RGB(0, 0, 0), c2
    _PRINTSTRING (winBarH * 2, 6), ss$

    '''

    'line (winBarH*2, 0)-step(len(s$)*8,winBarH),_rgb(255,255,0),b

    '_printstring (winBarH*2, 5), ss$

    's$ = left$(win(id).cap, win(id).w\8 - 3)
    '_printstring (4, 3), s$
    'line (0, winBarH) - step(win(id).w, 0), _rgb(255,255,255)
    'line (win(id).w - winBarH+3, 3)-step(winBarH-6,winBarH-6), _rgb(255,255,255), b

    SELECT CASE win(id).pid
        CASE 1
            LINE (4, winBarH + 4)-(win(id).w - 4, win(id).h - 4), _RGB(255, 255, 255), BF
            COLOR _RGB(0, 0, 0), _RGB(255, 255, 255)
        CASE 2
            LINE (4, winBarH + 4)-(win(id).w - 4, win(id).h - 4), _RGB(0, 0, 0), BF
            COLOR _RGB(0, 255, 0), _RGB(0, 0, 0)
    END SELECT

    SELECT CASE win(id).pid
        CASE 0
            LINE (4, winBarH + 4)-(win(id).w - 4, win(id).h - 4), _RGB(156, 156, 156), BF
            COLOR _RGB(0, 0, 0), _RGB(156, 156, 156)
            _PRINTSTRING ((win(id).w - 3 * 8) \ 2, (win(id).h - 2 * fontSize) \ 2), "vwm"
            _PRINTSTRING ((win(id).w - 9 * 8) \ 2, (win(id).h - 2 * fontSize) \ 2 + 16), "version 2"
        CASE 1 TO 2

            DIM temp AS _MEM
            temp = win(id).text.cur

            maxy = (win(id).h - winBarH + 8) \ fontSize - 1
            FOR i = win(id).text.cy TO maxy
                IF temp.OFFSET = win(id).text.tail.OFFSET THEN EXIT FOR
                _PRINTSTRING (4, winBarH + 4 + i * fontSize), readNode$(temp)
                nextNode temp, temp
            NEXT
            temp = win(id).text.cur
            IF win(id).text.cy > 0 THEN
                FOR i = win(id).text.cy - 1 TO 0 STEP -1
                    prevNode temp, temp
                    IF temp.OFFSET = win(id).text.head.OFFSET THEN EXIT FOR
                    _PRINTSTRING (4, winBarH + 4 + i * fontSize), readNode$(temp)
                NEXT
            END IF

            LINE (4 + 8 * win(id).text.cx, winBarH + 4 + fontSize * win(id).text.cy)-STEP(8, fontSize), , B
    END SELECT

    _DEST 0
END SUB

SUB drawBox (boxx, boxy, boxw, boxh)
    w3 = boxw \ 3
    h3 = (boxh - winBarH) \ 3
    DIM c AS LONG
    c = _RGB(255, 0, 255)
    LINE (boxx, boxy)-STEP(boxw, boxh), c, B
    LINE (boxx, boxy + winBarH)-STEP(boxw, 0), c

    LINE (boxx + w3, boxy + winBarH)-STEP(0, boxh - winBarH), c, B
    LINE (boxx + 2 * w3, boxy + winBarH)-STEP(0, boxh - winBarH), c, B
    LINE (boxx, boxy + h3 + winBarH)-STEP(boxw, 0), c, B
    LINE (boxx, boxy + 2 * h3 + winBarH)-STEP(boxw, 0), c, B
END SUB

FUNCTION mbox (x, y, w, h)
    IF mx >= x THEN
        IF my >= y THEN
            IF mx <= x + w THEN
                IF my <= y + h THEN
                    mbox = -1
                    EXIT FUNCTION
                END IF
            END IF
        END IF
    END IF

    mbox = 0
END FUNCTION

SUB addNodeNext (new AS _MEM, s$, cur AS _MEM, list1 AS listType)
    DIM node AS nodeType
    DIM temp AS _MEM
    DIM n AS _MEM

    list1.scrollmax = list1.scrollmax + 1

    temp = _MEMNEW(LEN(node))

    nextNode n, cur

    node.strLen = LEN(s$)
    IF node.strLen > 0 THEN
        node.str = _MEMNEW(LEN(s$))
        _MEMPUT node.str, node.str.OFFSET, s$
    END IF
    node.n = n
    node.p = cur
    _MEMPUT temp, temp.OFFSET, node

    node = _MEMGET(cur, cur.OFFSET, nodeType)
    node.n = temp
    _MEMPUT cur, cur.OFFSET, node

    node = _MEMGET(n, n.OFFSET, nodeType)
    node.p = temp
    _MEMPUT n, n.OFFSET, node

    new = temp
END SUB

SUB addNodePrev (new AS _MEM, s$, cur AS _MEM, list1 AS listType)
    DIM node AS nodeType
    DIM temp AS _MEM
    DIM p AS _MEM

    list1.scrollmax = list1.scrollmax + 1
    temp = _MEMNEW(LEN(node))

    prevNode p, cur

    node.strLen = LEN(s$)
    IF node.strLen > 0 THEN
        node.str = _MEMNEW(LEN(s$))
        _MEMPUT node.str, node.str.OFFSET, s$
    END IF

    node.n = cur
    node.p = p
    _MEMPUT temp, temp.OFFSET, node

    node = _MEMGET(cur, cur.OFFSET, nodeType)
    node.p = temp
    _MEMPUT cur, cur.OFFSET, node

    node = _MEMGET(p, p.OFFSET, nodeType)
    node.n = temp
    _MEMPUT p, p.OFFSET, node

    new = temp
END SUB

SUB rmNode (cur AS _MEM, list1 AS listType)
    DIM node AS nodeType
    DIM n AS _MEM
    DIM p AS _MEM

    list1.scrollmax = list1.scrollmax - 1
    'remove the string first
    node = _MEMGET(cur, cur.OFFSET, nodeType)
    IF node.strLen > 0 THEN
        _MEMFREE node.str
    END IF

    nextNode n, cur
    prevNode p, cur

    node = _MEMGET(p, p.OFFSET, nodeType)
    node.n = n
    _MEMPUT p, p.OFFSET, node

    node = _MEMGET(n, n.OFFSET, nodeType)
    node.p = p
    _MEMPUT n, n.OFFSET, node

    _MEMFREE cur
END SUB

SUB nextNode (new AS _MEM, old AS _MEM)
    DIM node AS nodeType

    node = _MEMGET(old, old.OFFSET, nodeType)
    new = node.n
END SUB

SUB prevNode (new AS _MEM, old AS _MEM)
    DIM node AS nodeType

    node = _MEMGET(old, old.OFFSET, nodeType)
    new = node.p
END SUB

FUNCTION lenNode (cur AS _MEM)
    DIM node AS nodeType

    node = _MEMGET(cur, cur.OFFSET, nodeType)
    lenNode = node.strLen
END FUNCTION

FUNCTION readNode$ (cur AS _MEM)
    DIM node AS nodeType

    node = _MEMGET(cur, cur.OFFSET, nodeType)
    IF node.strLen = 0 THEN
        readNode$ = ""
        EXIT FUNCTION
    END IF
    s$ = STRING$(node.strLen, 0)
    _MEMGET node.str, node.str.OFFSET, s$

    readNode$ = s$
END FUNCTION

SUB writeNode (cur AS _MEM, s$)
    DIM node AS nodeType

    'remove old string, free memory
    node = _MEMGET(cur, cur.OFFSET, nodeType)
    IF node.strLen > 0 THEN _MEMFREE node.str

    'add new string
    node.strLen = LEN(s$)
    IF node.strLen > 0 THEN
        node.str = _MEMNEW(LEN(s$))
        _MEMPUT node.str, node.str.OFFSET, s$
    END IF
    _MEMPUT cur, cur.OFFSET, node
END SUB

SUB newList (new AS listType)
    DIM node AS nodeType

    new.head = _MEMNEW(LEN(node))
    new.tail = _MEMNEW(LEN(node))
    new.cx = 0
    new.cy = 0
    new.scroll = 0
    new.scrollmax = 0

    s$ = "head"
    node.strLen = LEN(s$)
    node.str = _MEMNEW(LEN(s$))
    node.n = new.tail
    node.p = new.tail
    _MEMPUT node.str, node.str.OFFSET, s$
    _MEMPUT new.head, new.head.OFFSET, node

    s$ = "tail"
    node.strLen = LEN(s$)
    node.str = _MEMNEW(LEN(s$))
    node.n = new.head
    node.p = new.head
    _MEMPUT node.str, node.str.OFFSET, s$
    _MEMPUT new.tail, new.tail.OFFSET, node

END SUB

SUB printList (cur AS listType)
    DIM temp AS _MEM

    nextNode temp, cur.head
    DO
        IF temp.OFFSET = cur.tail.OFFSET THEN EXIT DO

        PRINT readNode$(temp)
        nextNode temp, temp
    LOOP
END SUB

SUB rmList (cur AS listType)
    DIM temp AS _MEM
    DIM temp2 AS _MEM

    nextNode temp, cur.head
    DO
        IF temp.OFFSET = cur.tail.OFFSET THEN EXIT DO

        temp2 = temp
        nextNode temp, temp2
        rmNode temp2, cur
    LOOP

    rmNode cur.head, cur
    rmNode cur.tail, cur
END SUB
