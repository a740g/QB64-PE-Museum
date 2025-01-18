DIM SHARED sw, sh, LHead$, LBody$, LTail$, RHead$, RBody$, RTail$
sw = 1024: sh = 700
LHead$ = "<*": LBody$ = ")": LTail$ = ">{"
RHead$ = "*>": RBody$ = "(": RTail$ = "}<"
TYPE fish
    LFish AS INTEGER
    X AS INTEGER
    Y AS INTEGER
    DX AS INTEGER
    fish AS STRING
    Colr AS _UNSIGNED LONG
END TYPE

SCREEN _NEWIMAGE(sw, sh, 32)

COLOR _RGB32(220), _RGB32(0, 0, 60)
CLS
'_PRINTMODE _KEEPBACKGROUND
DIM AS INTEGER i, nFish
'DIM k$
nFish = 40

'restart:
REDIM SHARED school(1 TO nFish) AS fish
REDIM SHARED kelp(sw, sh) AS _UNSIGNED LONG
growKelp
FOR i = 1 TO nFish
    NewFish i, -1
NEXT

DO
    CLS

    'k$ = INKEY$
    'If k$ = "m" Then ' more fish
    '    nFish = nFish * 2
    '    If nFish > 300 Then Beep: nFish = 300
    '    'GoTo restart
    'End If
    'If k$ = "l" Then ' less fish
    '    nFish = nFish / 2
    '    If nFish < 4 Then Beep: nFish = 4
    '    'GoTo restart
    'End If

    FOR i = 1 TO nFish ' draw fish behind kelp
        IF _RED32(school(i).Colr) < 160 THEN
            COLOR school(i).Colr
            _PRINTSTRING (school(i).X, school(i).Y), school(i).fish 'draw fish
            school(i).X = school(i).X + school(i).DX
            IF school(i).LFish THEN
                IF school(i).X + LEN(school(i).fish) * 8 < 0 THEN NewFish i, 0
            ELSE
                IF school(i).X - LEN(school(i).fish) * 8 > _WIDTH THEN NewFish i, 0
            END IF
        END IF
    NEXT
    showKelp
    FOR i = 1 TO nFish ' draw fish in from of kelp
        IF _RED32(school(i).Colr) >= 160 THEN
            COLOR school(i).Colr
            _PRINTSTRING (school(i).X, school(i).Y), school(i).fish 'draw fish
            school(i).X = school(i).X + school(i).DX
            IF school(i).LFish THEN
                IF school(i).X + LEN(school(i).fish) * 8 < 0 THEN NewFish i, 0
            ELSE
                IF school(i).X - LEN(school(i).fish) * 8 > _WIDTH THEN NewFish i, 0
            END IF
        END IF
    NEXT

    _DISPLAY
    _LIMIT 10
LOOP UNTIL _KEYDOWN(_KEY_ESC)

SYSTEM


SUB NewFish (i, initTF)
    DIM gray
    gray = RND * 200 + 55
    school(i).Colr = _RGB32(gray) ' color
    IF RND > .5 THEN
        school(i).LFish = -1
        school(i).fish = LHead$ + STRING$(INT(RND * 5) + -2 * (gray > 160) + 1, LBody$) + LTail$
    ELSE
        school(i).LFish = 0
        school(i).fish = RTail$ + STRING$(INT(RND * 5) + -2 * (gray > 160) + 1, RBody$) + RHead$
    END IF
    IF initTF THEN
        school(i).X = _WIDTH * RND
    ELSE
        IF school(i).LFish THEN school(i).X = _WIDTH + RND * 35 ELSE school(i).X = -35 * RND - LEN(school(i).fish) * 8
    END IF
    IF gray > 160 THEN
        IF school(i).LFish THEN school(i).DX = -18 * RND - 3 ELSE school(i).DX = 18 * RND + 3
    ELSE
        IF school(i).LFish THEN school(i).DX = -6 * RND - 1 ELSE school(i).DX = 6 * RND + 1
    END IF
    school(i).Y = _HEIGHT * RND
END SUB

SUB growKelp
    DIM kelps, x, y, r
    REDIM kelp(sw, sh) AS _UNSIGNED LONG
    kelps = INT(RND * 20) + 20
    FOR x = 1 TO kelps
        kelp(FIX(INT(RND * sw / 8)), FIX((sh - 16) / 16)) = _RGB32(0, RND * 128, 0)
    NEXT
    FOR y = FIX(sh / 16) TO 0 STEP -1
        FOR x = 0 TO FIX(sw / 8)
            IF kelp(x, y + 1) THEN
                r = FIX(INT(RND * 23) + 1)
                SELECT CASE r
                    CASE 1, 2, 3, 18 '1 branch node
                        IF x - 1 >= 0 THEN kelp(x - 1, y) = kelp(x, y + 1)
                    CASE 4, 5, 6, 7, 8, 9, 21 '1 branch node
                        kelp(x, y) = kelp(x, y + 1)
                    CASE 10, 11, 12, 20 '1 branch node
                        IF x + 1 <= sw THEN kelp(x + 1, y) = kelp(x, y + 1)
                    CASE 13, 14, 15, 16, 17, 19 '2 branch node
                        IF x - 1 >= 0 THEN kelp(x - 1, y) = kelp(x, y + 1)
                        IF x + 1 <= sw THEN kelp(x + 1, y) = kelp(x, y + 1)
                END SELECT
            END IF
        NEXT
    NEXT
END SUB

SUB showKelp
    DIM y, x
    FOR y = 0 TO FIX(sh / 16)
        FOR x = 0 TO FIX(sw / 8)
            IF kelp(x, y) THEN
                COLOR kelp(x, y)
                'Color 2
                _PRINTSTRING (x * 8, y * 16), MID$("kelp", INT(RND * 4) + 1, 1)
            END IF
        NEXT
    NEXT
END SUB
