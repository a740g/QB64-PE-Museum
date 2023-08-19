'============================================================================
'
'     GENERAL.BAS - General Routines for the User Interface Toolbox in
'           Microsoft BASIC 7.1, Professional Development System
'              Copyright (C) 1987-1990, Microsoft Corporation
'                   Copyright (C) 2023 Samuel Gomes
'
'  NOTE:    This sample source code toolbox is intended to demonstrate some
'           of the extended capabilities of Microsoft BASIC 7.1 Professional
'           Development system that can help to leverage the professional
'           developer's time more effectively.  While you are free to use,
'           modify, or distribute the routines in this module in any way you
'           find useful, it should be noted that these are examples only and
'           should not be relied upon as a fully-tested "add-on" library.
'
'  PURPOSE: These are the general purpose routines needed by the other
'           modules in the user interface toolbox.
'
'  To create a library and QuickLib containing the routines found
'  in this file, follow these steps:
'       BC /X/FS general.bas
'       LIB general.lib + general + uiasm + qbx.lib;
'       LINK /Q general.lib, general.qlb,,qbxqlb.lib;
'  Creating a library and QuickLib for any of the other UI toolbox files
'  (WINDOW.BAS, MENU.BAS and MOUSE.BAS) is done this way also.
'
'  To create a library and QuickLib containing all routines from
'  the User Interface toolbox follow these steps:
'       BC /X/FS general.bas
'       BC /X/FS window.bas
'       BC /X/FS mouse.bas
'       BC /X/FS menu.bas
'       LIB uitb.lib + general + window + mouse + menu + uiasm + qbx.lib;
'       LINK /Q uitb.lib, uitb.qlb,,qbxqlb.lib;
'  If you are going to use this QuickLib in conjunction with the font source
'  code (FONTB.BAS) or the charting source code (CHRTB.BAS), you need to
'  include the assembly code routines referenced in these files.  For the font
'  routines, perform the following LIB command after creating the library but
'  before creating the QuickLib as described above:
'       LIB uitb.lib + fontasm;
'  For the charting routines, perform the following LIB command after creating
'  the library but before creating the QuickLib as described above:
'       LIB uitb.lib + chrtasm;
'
'============================================================================

';-----------------------------------------------------------------------------
';-----------------------------------------------------------------------------
';
';  UIASM.ASM
';
';  Copyright (C) 1989-1990 Microsoft Corporation, All Rights Reserved
';
';  GetCopyBox : Gets screen box info and places into string variable
';  PutCopyBox : Puts screen box info from string variable onto screen
';  AttrBox    : Changes the color attributes of all characters within a box
';
';-----------------------------------------------------------------------------
';-----------------------------------------------------------------------------

';NOTE: For optimum speed, these routines write directly to screen memory
';      without waiting for re-trace.  If "snow" is a problem, these routines
';      will need modification.

'.model medium

'        extrn   STRINGADDRESS:far       ;BASIC RTL entry point for string info

'.data

'attr    db      ?                       ;destination attribute (AttrBox)
'x0      db      ?                       ;x coord of upper-left
'y0      db      ?                       ;y coord of upper-left
'x1      db      ?                       ;x coord of lower-right
'y1      db      ?                       ;y coord of lower-right
'bwidth  db      ?                       ;box width
'height  db      ?                       ;box height
'strdoff dw      ?                       ;string pointer offset
'strdseg dw      ?                       ;string pointer segment
'scrseg  dw      ?                       ;screen segment
'movword dw      ?                       ;word count to move/change

'.code

';---------------------------------------place segment of screen memory
';---------------------------------------in SCRSEG
'get_scrseg      proc

'        push    ax                      ;save value of AX
'        mov     ah,0Fh
'        int     10h                     ;INT 10H fn. 0Fh - Get Video Mode
'        mov     dgroup:scrseg,0B800h    ;assume COLOR screen for now
'        cmp     al,07h                  ;is it MONOCHROME mode?
'        jne     arnd1
'        mov     dgroup:scrseg,0B000h    ;yes, set for mono screen seg
'arnd1:  pop     ax                      ;restore AX
'        ret                             ;and exit

'get_scrseg      endp


';----------------------------------------Given X and Y in AH and AL, find
';----------------------------------------the offset into screen memory and
';----------------------------------------return in AX
'get_memxy       proc

'        push    dx                      ;save DX
'        push    ax                      ;save coords
'        mov     dl,160
'        mul     dl                      ;multiply Y by 160
'        pop     dx                      ;put coords in DX
'        mov     dl,dh
'        mov     dh,0
'        add     dl,dl                   ;double X
'        add     ax,dx                   ;and add to mult. result for final!
'        pop     dx                      ;restore DX
'        ret

'get_memxy       endp


';-----------------------------------------------------------------------------
';----------------------------------------This is the routine that copies
';----------------------------------------screen info to the string variable
';-----------------------------------------------------------------------------
'        public  GETCOPYBOX
'getcopybox      proc    far

'        push    bp
'        mov     bp,sp
'        push    ds
'        push    es
'        push    si
'        push    di                      ;preserve registers

'get_start:
'        mov     bx,[bp + 14]            ;get y0
'        mov     ax,[bx]
'        mov     y0,al
'        mov     bx,[bp + 12]            ;...x0
'        mov     ax,[bx]
'        mov     x0,al
'        mov     bx,[bp + 10]            ;...y1
'        mov     ax,[bx]
'        mov     y1,al
'        mov     bx,[bp + 8]             ;...x1
'        mov     ax,[bx]
'        mov     x1,al
'        mov     bx,[bp + 6]             ;...and the destination str desc.

'        push    bx
'        call    STRINGADDRESS           ;for both near and far string support
'        mov     strdoff, ax
'        mov     strdseg, dx

'        dec     x0                      ;subtract 1 from
'        dec     y0                      ;all coordinates
'        dec     x1                      ;to reflect BASIC's
'        dec     y1                      ;screen base of 1 (not 0)

'get_chkscr:
'        call    get_scrseg              ;set up screen segment

'get_setstr:
'        mov     al,x1
'        sub     al,x0                   ;find width of box
'        mov     bwidth,al               ;and save
'        add     al,1                    ;add one to width
'        mov     ah,0                    ;to find # words to move
'        mov     movword,ax              ;MovWord = (width+1)
'        mov     al,y1
'        sub     al,y0                   ;find height of box
'        mov     height,al               ;and save
'        mov     es,strdseg
'        mov     di,strdoff              ;string is the destination
'        mov     si,offset bwidth        ;point to width
'        movsb                           ;put width in string
'        mov     si,offset height
'        movsb                           ;and the height, too

'get_movstr:
'        mov     al,y0
'        mov     ah,x0                   ;put coords in AH and AL
'        call    get_memxy               ;and find offset into screen mem
'        mov     si,ax                   ;this will be the source

'get_domove:
'        mov     cx,movword
'        push    ds
'        mov     ds,scrseg
'        rep     movsw                   ;move a row into the string
'        pop     ds
'        add     si,160
'        sub     si,movword              ;Add 160-(movword*2) to si
'        sub     si,movword              ;to point to next row
'        cmp     height,0                ;was that the last row?
'        je      get_done                ;yes, we're done
'        dec     height                  ;decrement height
'        jmp     get_domove              ;and do another row

'get_done:
'        pop     di
'        pop     si
'        pop     es
'        pop     ds                      ;restore registers
'        pop     bp
'        ret     10                      ;there were 5 parameters

'getcopybox      endp


';-----------------------------------------------------------------------------
';----------------------------------------This is the routine that copies the
';----------------------------------------information stored in the string to
';----------------------------------------the screen in the specified location
';-----------------------------------------------------------------------------
'        public  PUTCOPYBOX
'putcopybox      proc    far

'        push    bp
'        mov     bp,sp
'        push    ds
'        push    es
'        push    si
'        push    di                      ;preserve registers


'put_start:
'        mov     bx,[bp + 10]            ;get y0
'        mov     ax,[bx]
'        mov     y0,al
'        mov     bx,[bp + 8]             ;...x0
'        mov     ax,[bx]
'        mov     x0,al
'        mov     bx,[bp + 6]             ;...and the destination string

'        push    bx
'        call    STRINGADDRESS           ;for both near and far string support
'        mov     strdoff, ax
'        mov     strdseg, dx

'        dec     x0                      ;subtract 1 from
'        dec     y0                      ;all coordinates

'put_chkscr:
'        call    get_scrseg              ;set up scrseg

'put_setstr:
'        push    ds
'        pop     es                      ;equate ES to DS

'        mov     si,strdoff              ;point DS:SI to string mem
'        push    ds
'        mov     ds,strdseg
'        mov     di,offset bwidth
'        movsb                           ;get width
'        mov     di,offset height
'        movsb                           ;and height out of string
'        pop     ds

'        mov     al,bwidth
'        add     al,1
'        mov     ah,0
'        mov     movword,ax              ;set movword to (bwidth+1)

'        mov     ah,x0
'        mov     al,y0                   ;get coords
'        call    get_memxy               ;and find offset into screen mem
'        mov     di,ax
'        mov     es,scrseg               ;ES:DI -> screen mem (UL corner)

'put_domove:
'        mov     cx,movword
'        push    ds
'        mov     ds,strdseg
'        rep     movsw                   ;move a row onto the screen
'        pop     ds
'        add     di,160
'        sub     di,movword              ;add 160-(movword*2) to DI
'        sub     di,movword              ;to point to next row on screen
'        cmp     height,0                ;was that the last row?
'        je      put_done                ;yes, we're finished
'        dec     height
'        jmp     put_domove              ;no, decrement and do again

'put_done:
'        pop     di
'        pop     si
'        pop     es
'        pop     ds                      ;restore registers
'        pop     bp
'        ret     6                       ;pop off 3 parameters

'putcopybox      endp

';-----------------------------------------------------------------------------
';----------------------------------------This is the routine that changes
';----------------------------------------the colors of the box's characters
';-----------------------------------------------------------------------------
'        public  ATTRBOX
'attrbox         proc    far

'        push    bp
'        mov     bp, sp
'        push    ds
'        push    es
'        push    si
'        push    di                      ;preserve registers

'atr_start:
'        mov     bx, [bp+14]             ;get y0
'        mov     ax, [bx]
'        mov     y0, al
'        mov     bx, [bp+12]             ;...x0
'        mov     ax, [bx]
'        mov     x0, al
'        mov     bx, [bp+10]             ;...y1
'        mov     ax, [bx]
'        mov     y1, al
'        mov     bx, [bp+8]              ;...x1
'        mov     ax, [bx]
'        mov     x1, al
'        mov     bx, [bp+6]              ;...and finally the new color value
'        mov     ax, [bx]
'        mov     attr, al

'        dec     y0                      ;subtract 1 from
'        dec     x0                      ;all coordinates
'        dec     y1                      ;to reflect BASIC's
'        dec     x1                      ;screen base of 1 (not 0)

'atr_chkscr:
'        call    get_scrseg              ;set up screen segment

'atr_setup:
'        mov     al, x1
'        sub     al, x0                  ;find width of box
'        inc     al
'        xor     ah, ah
'        mov     movword, ax             ;(width + 1 = movword)
'        mov     al, y1
'        sub     al, y0                  ;find height of box
'        mov     height, al              ;and save

'atr_chgclr:
'        mov     al, y0
'        mov     ah, x0                  ;put coords in AH and AL
'        call    get_memxy               ;find offset into screen memory
'        mov     di, ax                  ;(which is our destination)
'        mov     es, scrseg
'        mov     al, attr                ;get the color value to store

'atr_doit:
'        mov     cx, movword
'atr_loop:
'        inc     di                      ;skip the character value
'        stosb                           ;write new color value
'        loop    atr_loop                ;cx times
'        add     di, 160                 ;add 160-(movword*2) to di
'        sub     di, movword
'        sub     di, movword
'        cmp     height, 0               ;was that the last row?
'        je      atr_done                ;yes, we be finished
'        dec     height                  ;no, decrement height
'        jmp     atr_doit

'atr_done:
'        pop     di
'        pop     si
'        pop     es
'        pop     ds
'        pop     bp                      ;restore registers
'        ret     10                      ;pull off 5 paramters and return

'attrbox         endp

'        END

$IF GENERAL_BAS = UNDEFINED THEN
    $LET GENERAL_BAS = TRUE

    '$INCLUDE:'General.bi'

    ' Same as DECLARE SUB GetCopyBox (row1%, col1%, row2%, col2%, buffer$)
    ';-----------------------------------------------------------------------------
    ';----------------------------------------This is the routine that copies
    ';----------------------------------------screen info to the string variable
    ';-----------------------------------------------------------------------------
    SUB GetBackground (row1 AS LONG, col1 AS LONG, row2 AS LONG, col2 AS LONG, buffer AS STRING)
        ' =======================================================================
        ' Create enough space in buffer$ to hold the screen info behind the box
        ' =======================================================================
        DIM w AS LONG: w = col2 - col1 + 1
        DIM h AS LONG: h = row2 - row1 + 1

        buffer = STRING$(LEN(w) + LEN(h) + (2 * w * h), 0) ' sizeof_long + sizeof_long + (sizeof_each_textmode_cell * w * h)

        ' Save the size
        DIM i AS LONG: i = 1
        MID$(buffer, i, LEN(w)) = MKL$(w)
        i = i + LEN(w)
        MID$(buffer, i, LEN(h)) = MKL$(h)
        i = i + LEN(h)

        ' Now copy the contents of the screen to the buffer
        DIM AS LONG x, y
        FOR y = row1 TO row2
            FOR x = col1 TO col2
                IF x > 0 AND x <= _WIDTH AND y > 0 AND y <= _HEIGHT THEN
                    ASC(buffer, i) = SCREEN(y, x, 1) ' copy the color attribute
                    i = i + 1
                    ASC(buffer, i) = SCREEN(y, x) ' copy the text
                    i = i + 1
                ELSE
                    i = i + 2
                END IF
            NEXT
        NEXT
    END SUB


    ' Same as DECLARE SUB PutCopyBox (row%, col%, buffer$)
    ';-----------------------------------------------------------------------------
    ';----------------------------------------This is the routine that copies the
    ';----------------------------------------information stored in the string to
    ';----------------------------------------the screen in the specified location
    ';-----------------------------------------------------------------------------
    SUB PutBackground (row AS LONG, col AS LONG, buffer AS STRING)
        ' Save some stuff
        DIM fc AS LONG: fc = _DEFAULTCOLOR
        DIM bc AS LONG: bc = _BACKGROUNDCOLOR

        ' Get the width and height
        DIM i AS LONG: i = 1
        DIM w AS LONG: w = CVL(LEFT$(buffer, LEN(w)))
        i = i + LEN(w)
        DIM h AS LONG: h = CVL(MID$(buffer, i, LEN(h)))
        i = i + LEN(h)

        DIM row2 AS LONG: row2 = row + h - 1
        DIM col2 AS LONG: col2 = col + w - 1

        ' Now copy the contents of the buffer to the screen
        DIM AS LONG x, y
        DIM AS LONG c
        FOR y = row TO row2
            FOR x = col TO col2
                IF x > 0 AND x <= _WIDTH AND y > 0 AND y <= _HEIGHT THEN
                    c = ASC(buffer, i) ' get the color
                    COLOR c AND 15, c \ 16 ' this correctly sets high intensity colors
                    i = i + 1
                    _PRINTSTRING (x, y), MID$(buffer, i, 1) ' get and print the character at x, y
                    i = i + 1
                ELSE
                    i = i + 2
                END IF
            NEXT
        NEXT

        ' Restore saved stuff
        COLOR fc, bc
    END SUB


    '-----------------------------------------------------------------------------
    '----------------------------------------This is the routine that changes
    '----------------------------------------the colors of the box's characters
    '-----------------------------------------------------------------------------
    SUB AttrBox (row1 AS LONG, col1 AS LONG, row2 AS LONG, col2 AS LONG, attr AS LONG)
        ' Save some stuff
        DIM fc AS LONG: fc = _DEFAULTCOLOR
        DIM bc AS LONG: bc = _BACKGROUNDCOLOR

        DIM AS LONG x, y
        FOR y = row1 TO row2
            FOR x = col1 TO col2
                IF x > 0 AND x <= _WIDTH AND y > 0 AND y <= _HEIGHT THEN
                    COLOR attr AND 15, attr \ 16 ' Set the color attribute
                    _PRINTSTRING (x, y), CHR$(SCREEN(y, x))
                END IF
            NEXT
        NEXT

        ' Restore saved stuff
        COLOR fc, bc
    END SUB


    ' =======================================================================
    ' Draws a box on the screen using characters specified in border
    ' =======================================================================
    SUB Box (row1 AS LONG, col1 AS LONG, row2 AS LONG, col2 AS LONG, fore AS LONG, back AS LONG, border AS STRING, fillFlag AS LONG)
        STATIC defaultBoxChars AS STRING
        IF LEN(defaultBoxChars) = 0 THEN
            defaultBoxChars = CHR$(218) + CHR$(196) + CHR$(191) + CHR$(179) + CHR$(32) + CHR$(179) + CHR$(192) + CHR$(196) + CHR$(217)
        END IF

        '=======================================================================
        '  Use default border if an illegal border$ is passed
        '=======================================================================
        DIM t AS STRING
        IF LEN(border) < 9 THEN
            t = defaultBoxChars
        ELSE
            t = border
        END IF

        ' =======================================================================
        ' Check coordinates for validity, then draw box
        ' =======================================================================
        IF col1 <= (col2 - 2) AND row1 <= (row2 - 2) AND col1 >= MINCOL AND row1 >= MINROW AND col2 <= _WIDTH AND row2 <= _HEIGHT THEN
            DIM boxWidth AS LONG: boxWidth = col2 - col1 + 1
            DIM boxHeight AS LONG: boxHeight = row2 - row1 + 1

            COLOR fore, back

            _PRINTSTRING (col1, row1), LEFT$(t, 1) + STRING$(boxWidth - 2, ASC(t, 2)) + MID$(t, 3, 1)
            _PRINTSTRING (col1, row2), MID$(t, 7, 1) + STRING$(boxWidth - 2, ASC(t, 8)) + MID$(t, 9, 1)

            DIM i AS LONG: FOR i = row1 + 1 TO row1 + boxHeight - 2
                IF fillFlag THEN
                    _PRINTSTRING (col1, i), MID$(t, 4, 1) + STRING$(boxWidth - 2, ASC(t, 5)) + MID$(t, 6, 1)
                ELSE
                    _PRINTSTRING (col1, i), MID$(t, 4, 1)
                    _PRINTSTRING (col1 + boxWidth - 1, i), MID$(t, 6, 1)
                END IF
            NEXT

            LOCATE row1 + 1, col1 + 1 ' set cursor inside the box
        END IF
    END SUB


    ' =======================================================================
    ' Clears a given portion of the screen without disturbing the cursor location and colors
    ' =======================================================================
    SUB ClearBox (row1 AS LONG, col1 AS LONG, row2 AS LONG, col2 AS LONG, bc AS LONG)
        ' Save some stuff
        DIM obc AS LONG: obc = _BACKGROUNDCOLOR

        COLOR , bc

        DIM AS LONG x, y
        FOR y = row1 TO row2
            FOR x = col1 TO col2
                IF x > 0 AND x <= _WIDTH AND y > 0 AND y <= _HEIGHT THEN _PRINTSTRING (x, y), " " ' fill with SPACE
            NEXT
        NEXT

        ' Restore saved stuff
        COLOR , obc
    END SUB


    ' =======================================================================
    ' Scrolls a section of the screen up (lines > 0), down (lines < 0)
    ' or clears the screen (lines = 0)
    ' =======================================================================
    SUB Scroll (row1 AS LONG, col1 AS LONG, row2 AS LONG, col2 AS LONG, lines AS LONG, bc AS LONG)
        ' If coordinates are valid, scroll the screen
        IF row1 >= MINROW AND row2 <= _HEIGHT AND col1 >= MINCOL AND col2 <= _WIDTH THEN
            DIM buffer AS STRING

            IF lines < 0 THEN ' scoll down
                GetBackground row1, col1, row2 + lines, col2, buffer ' only get the portion we want to scroll
                PutBackground row2 + lines, col1, buffer ' put the portion in the correct location
                ClearBox row1, col1, row1 - lines - 1, col2, bc
            ELSEIF lines > 0 THEN ' scroll up
                GetBackground row2 - lines, col1, row2, col2, buffer ' only get the portion we want to scroll
                PutBackground row1, col1, buffer ' put the portion in the correct location
                ClearBox row2 - lines + 1, col1, row2, col2, bc
            ELSE ' clear area
                ClearBox row1, col1, row2, col2, bc
            END IF
        END IF
    END SUB


    ' =======================================================================
    ' Converts Alt+A to A,Alt+B to B, etc.  You send it a string.  The right
    ' most character is compared to the string below, and is converted to
    ' the proper character.
    ' =======================================================================
    FUNCTION AltToASCII$ (kbd AS STRING)
        STATIC altStr AS STRING
        IF LEN(altStr) = 0 THEN
            altStr = CHR$(120) + CHR$(121) + CHR$(122) + CHR$(123) + CHR$(124) + CHR$(125) + CHR$(126) + CHR$(127) _
                + CHR$(128) + CHR$(129) + CHR$(16) + CHR$(17) + CHR$(18) + CHR$(19) + CHR$(20) + CHR$(21) + CHR$(22) _
                + CHR$(23) + CHR$(24) + CHR$(25) + CHR$(30) + CHR$(31) + CHR$(32) + CHR$(33) + CHR$(34) + CHR$(35) _
                + CHR$(36) + CHR$(37) + CHR$(38) + CHR$(44) + CHR$(45) + CHR$(46) + CHR$(47) + CHR$(48) + CHR$(49) _
                + CHR$(50) + CHR$(130) + CHR$(131)
        END IF

        DIM AS LONG index: index = INSTR(altStr, RIGHT$(kbd, 1))

        IF index = 0 THEN
            AltToASCII = ""
        ELSE
            AltToASCII = MID$("1234567890QWERTYUIOPASDFGHJKLZXCVBNM-=", index, 1)
        END IF
    END FUNCTION


    ' =======================================================================
    ' Returns the keyboard shift state after calling interrupt 22
    '    bit 0 : right shift
    '        1 : left shift
    '        2 : ctrl key
    '        3 : alt key
    '        4 : scroll lock
    '        5 : num lock
    '        6 : caps lock
    '        7 : insert state
    ' =======================================================================
    FUNCTION GetShiftState& (b AS LONG)
        STATIC isInsert AS LONG, lastTime AS SINGLE

        DIM curTime AS SINGLE: curTime = TIMER

        IF _KEYDOWN(20992) AND ABS(curTime - lastTime) > 1 THEN
            lastTime = curTime
            isInsert = NOT isInsert
        END IF

        IF _READBIT(b, 0) THEN
            GetShiftState = _KEYDOWN(100303)
        ELSEIF _READBIT(b, 1) THEN
            GetShiftState = _KEYDOWN(100304)
        ELSEIF _READBIT(b, 2) THEN
            GetShiftState = _KEYDOWN(100306) OR _KEYDOWN(100305)
        ELSEIF _READBIT(b, 3) THEN
            GetShiftState = _KEYDOWN(100308) OR _KEYDOWN(100306)
        ELSEIF _READBIT(b, 4) THEN
            GetShiftState = _SCROLLLOCK
        ELSEIF _READBIT(b, 5) THEN
            GetShiftState = _NUMLOCK
        ELSEIF _READBIT(b, 6) THEN
            GetShiftState = _CAPSLOCK
        ELSEIF _READBIT(b, 7) THEN
            GetShiftState = isInsert
        END IF
    END FUNCTION

$END IF
