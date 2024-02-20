OPTION _EXPLICIT
_TITLE "b+ mods vince fine Curves code" ' b+ 2022-02-01
DEFLNG A-Z
CONST sw = 1024, sh = 600 ' const shared everywhere
SCREEN _NEWIMAGE(sw, sh, 32)
_SCREENMOVE 150, 60 'center stage

'put 'em all here
DIM AS LONG n, r, mx, my, mb, omx, omy, i, j, vs
DIM AS DOUBLE bx, by, t, bin
DIM k$
REDIM x(n) AS LONG, y(n) AS LONG

vs = _NEWIMAGE(sw, sh, 32) ' vs for virtual screen
r = 5 'gap checker?
DO
    CLS
    k$ = INKEY$
    IF k$ = "c" THEN
        _DEST vs
        LINE (0, 0)-(sw, sh), &HFF000000, BF
        _DEST 0
        CLS
    END IF
    _PUTIMAGE , vs, 0
    WHILE _MOUSEINPUT: WEND ' poll mouse update mouse variables
    mx = _MOUSEX: my = _MOUSEY: mb = _MOUSEBUTTON(1)


    IF mb THEN
        n = 1
        REDIM _PRESERVE x(n)
        REDIM _PRESERVE y(n)

        x(0) = mx - sw / 2
        y(0) = sh / 2 - my

        PSET (mx, my)
        DO WHILE mb
            WHILE _MOUSEINPUT: WEND ' poll mouse update mouse variables
            mx = _MOUSEX: my = _MOUSEY: mb = _MOUSEBUTTON(1)
            LINE -(mx, my), _RGB(30, 30, 30)

            IF (mx - omx) ^ 2 + (my - omy) ^ 2 > r ^ 2 THEN
                circlef mx, my, 3, _RGB(30, 30, 30)
                omx = mx
                omy = my

                x(n) = mx - sw / 2
                y(n) = sh / 2 - my
                n = n + 1
                REDIM _PRESERVE x(n)
                REDIM _PRESERVE y(n)
            END IF

            _DISPLAY
            '_Limit 30
        LOOP

        'close the contour
        'x(n) = x(0)
        'y(n) = y(0)
        'n = n + 1
        'redim _preserve x(n)
        'redim _preserve y(n)


        'redraw spline
        'pset (sw/2 + x(0), sh/2 - y(0))
        'for i=0 to n
        'line -(sw/2 + x(i), sh/2 - y(i)), _rgb(255,0,0)
        'circlef sw/2 + x(i), sh/2 - y(i), 3, _rgb(255,0,0)
        'next
        _DEST vs
        PSET (sw / 2 + x(0), sh / 2 - y(0))
        FOR t = 0 TO 1 STEP 0.001
            bx = 0
            by = 0

            FOR i = 0 TO n
                bin = 1
                FOR j = 1 TO i
                    bin = bin * (n - j) / j
                NEXT

                bx = bx + bin * ((1 - t) ^ (n - 1 - i)) * (t ^ i) * x(i)
                by = by + bin * ((1 - t) ^ (n - 1 - i)) * (t ^ i) * y(i)
            NEXT

            LINE -(sw / 2 + bx, sh / 2 - by), _RGB(255, 0, 0)
        NEXT
        _DEST 0
    END IF

    _DISPLAY
    _LIMIT 30
LOOP UNTIL _KEYHIT = 27
SYSTEM

SUB circlef (x AS LONG, y AS LONG, r AS LONG, c AS LONG)
    DIM AS LONG x0, y0, e
    x0 = r
    y0 = 0
    e = -r

    DO WHILE y0 < x0
        IF e <= 0 THEN
            y0 = y0 + 1
            LINE (x - x0, y + y0)-(x + x0, y + y0), c, BF
            LINE (x - x0, y - y0)-(x + x0, y - y0), c, BF
            e = e + 2 * y0
        ELSE
            LINE (x - y0, y - x0)-(x + y0, y - x0), c, BF
            LINE (x - y0, y + x0)-(x + y0, y + x0), c, BF
            x0 = x0 - 1
            e = e - 2 * x0
        END IF
    LOOP
    LINE (x - r, y)-(x + r, y), c, BF
END SUB
