' mklev v1.0 for arctic mine/qdigger

$Resize:Smooth
$ExeIcon:'.\ARCTICPAK.ico'

Const FALSE = 0, TRUE = Not FALSE

Const COLORFUL = TRUE
Const GOLDMIN = 4, GOLDMAX = 15
Const JEWMIN = 25, JEWMAX = 100
DefInt A-Z

Type XY
    x As Integer
    y As Integer
End Type
Type RECT
    x1 As Integer
    y1 As Integer
    x2 As Integer
    y2 As Integer
End Type

Const SOIL = 0, EMPTY = 1, GOLD = 2, ENEM = 3, DIGGER = 4, JEWEL = 5
Const MZW = 15, MZH = 10
Dim Shared mz(0 To MZW + 1, 0 To MZH + 1) As Integer
Dim Shared rct(50) As RECT
Dim Shared BGR, nosel
Dim nmines As Long, i As Long
Dim Shared d(3) As XY: d(0).x = -1: d(1).y = -1: d(2).x = 1: d(3).y = 1

'DEBUG = TRUE
If DEBUG Then
    Randomize Timer
    Cls
    MAKELEV
    DRAWMAZE 1, 1
    End
End If

Randomize Timer
Print "mklev, 2008"
Print "--"
Input "filename [mklev]"; file$
If file$ = "" Then file$ = "mklev"
If InStr(file$, ".") < Len(file$) - 3 Then file$ = file$ + ".mn"
Input "number of levels [8]"; nmines
If nmines = 0 Then nmines = 8
Input "background color [no]"; a$: BGR = (LCase$(Left$(a$, 1)) = "y")
Input "select only good levels [yes]"; a$: nosel = (LCase$(Left$(a$, 1)) = "n")
Print "--"
For i = 1 To MZH + 1: Print: Next: y = CsrLin - MZH - 1
f = FreeFile
Open file$ For Output As #f
t# = Timer
For i = 1 To nmines
    MAKELEV
    DRAWMAZE 1, y: Color 7: Print "maze"; i
    STORELEV f, LTrim$(RTrim$(Str$(i)))
Next
t# = Timer - t#
Print #f, "_end"
Close #f
Print "done: "; t#; "sec.": Print

Input "run game [yes,d=digger]"; a$
If a$ = "" Then a$ = "y"
a$ = LCase$(Left$(a$, 1))
cmd$ = "arctic"
If a$ = "d" Then a$ = "y": cmd$ = "digger"
If a$ = "y" Then
    Shell cmd$ + " " + file$
    Print
    Print "mklev: saved as "; file$
    Print
    While InKey$ = "": Wend
End If
End

Sub CLEARMAZE
    For x = 1 To MZW
        For y = 1 To MZH
            mz(x, y) = SOIL
        Next
    Next
End Sub

Sub DEADSHAFT (x, y, n)
    If n > 10 Then Exit Sub
    n = n + 1
    'CLS : DRAWMAZE 1, 1: SLEEP
    mz(x, y) = EMPTY
    c = 0
    done = FALSE
    Do
        dir = RAND(0, 3)
        x1 = x + d(dir).x
        y1 = y + d(dir).y
        If x1 > 0 And y1 > 0 And x1 <= MZW And y1 <= MZH Then
            b = 0
            For i = -1 To 1
                For j = -1 To 1
                    If Abs(i) + Abs(j) <> 0 Then
                        x2 = x1 + i
                        y2 = y1 + j
                        If mz(x2, y2) = EMPTY And x2 <> x And y2 <> y Then b = b + 1
                    End If
                Next
            Next
            If b = 0 Then
                If x1 = x And y1 = y Then Stop
                x2 = x1: y2 = y1
                DEADSHAFT x1, y1, n
                If x1 <> x2 Or y1 <> y2 Then Stop
                If n < 5 Then mz(x, y) = SOIL: mz(x1, y1) = SOIL
                Exit Sub
            End If
            c = c + 1
        End If
    Loop Until done Or (Rnd < .1 And c > 4) Or c > 30
End Sub

Sub DIGMAZE
    minw = 2
    maxw = 14
    minh = 2
    maxh = 9
    NRECTS = RAND(2, 5)
    CLEARMAZE
    For i = 1 To NRECTS
        n = 0
        Do
            w = RAND(minw, maxw)
            h = RAND(minh, maxh)
            x = RAND(1, MZW - w)
            y = RAND(1, MZH - h)
            rct(i).x1 = x
            rct(i).y1 = y
            rct(i).x2 = rct(i).x1 + w
            rct(i).y2 = rct(i).y1 + h
            retry = FALSE
            For j = 1 To i - 1
                If Not RECTSVALID(i, j) Then
                    retry = TRUE
                    Exit For
                End If
            Next
            n = n + 1
        Loop While retry Or n > 10000
    Next
    Dim r(1 To NRECTS, 1 To NRECTS)
    For i = 1 To RAND(0, 7)
        r1 = RAND(1, NRECTS)
        r2 = RAND(1, NRECTS)
        r(r1, r2) = TRUE
        r(r2, r1) = TRUE
    Next
    For i = 1 To NRECTS
        For x = rct(i).x1 To rct(i).x2
            For y = rct(i).y1 To rct(i).y2
                If x = rct(i).x1 Or x = rct(i).x2 Or y = rct(i).y1 Or y = rct(i).y2 Then
                    drw = TRUE
                    For j = 1 To NRECTS
                        If r(j, i) = TRUE Then
                            If PTINRECT(j, x, y) Then
                                drw = FALSE
                            End If
                        End If
                    Next
                    If drw Then mz(x, y) = i + 100
                End If
            Next
        Next
    Next
    For x = 1 To MZW
        For y = 1 To MZH
            If mz(x, y) > 100 Then mz(x, y) = EMPTY
        Next
    Next
    Exit Sub
    DRAWMAZE 1, 1
    For sh = 1 To 30
        For j = 1 To 100
            x = RAND(1, MZW)
            y = RAND(1, MZH)
            If PATH(x, y) Then
                x0 = x: y0 = y
                z = 0: DEADSHAFT x0, y0, z
                mz(x, y) = EMPTY
                If z < 2 Then DRAWMAZE 1, 1
                sh = sh + 5
                Exit For
            End If
        Next
    Next
    'DIM arr(100) AS XY, arrc
    'FOR sh = 1 TO 4
    '  done = FALSE
    '  z = 0
    '  DO
    '    x = RAND(1, MZW)
    '    y = RAND(1, MZH)
    '    z = z + 1
    '  LOOP UNTIL PATH(x, y) OR z > 100
    '  IF z <= 100 THEN done = TRUE
    '
    '  IF done THEN
    '    arrc = 0
    '    FOR i = 0 TO 3
    '      a = RND * 4
    '      FOR j = 1 TO a
    '        x1 = x + j * d(i).x
    '        y1 = y + j * d(i).y
    '        IF x1 > 0 AND y1 > 0 AND x1 <= MZW AND y1 <= MZH THEN
    '          IF PATH(x1, y1) THEN
    '            arrc = arrc + 1
    '            arr(arrc).x = x1
    '            arr(arrc).y = y1
    '          ELSE
    '            j = a + 1
    '          END IF
    '        END IF
    '      NEXT
    '    NEXT
    '    FOR i = 1 TO arrc: mz(arr(i).x, arr(i).y) = SOIL: NEXT
    '    mz(x, y) = SOIL
    '  END IF
    '  q = q + 1
    '  IF q > 100 THEN EXIT FOR
    'NEXT
End Sub

Function DIST! (a As XY, b As XY)
    DIST! = Sqr((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
End Function

Sub DRAWMAZE (x0, y0)
    Locate 1, 1
    For y = 1 To MZH
        Locate y0 + y - 1, x0
        For x = 1 To MZW
            Select Case mz(x, y)
                Case EMPTY: c = 8: ch$ = "#"
                Case SOIL: c = 6: ch$ = ":"
                Case GOLD: c = 14: ch$ = "$"
                Case DIGGER: c = 5: ch$ = "d"
                Case ENEM: c = 1: ch$ = "e"
                Case JEWEL: c = 2: ch$ = "7"
                    'CASE IS > 200: c = 10: ch$ = CHR$(mz(x, y) - 200 + ASC("0"))
                    'CASE IS > 100: c = 9: ch$ = CHR$(mz(x, y) - 100 + ASC("0"))
            End Select
            'ch$ = "Z"
            If COLORFUL Then Color c
            Print ch$;
        Next
        Print
    Next
    Color 7, 0
    '  DELAY .2
End Sub

Sub MAKELEV
    Do
        DIGMAZE
        n = 0
        For x = 1 To MZW
            For y = 1 To MZH
                If mz(x, y) = EMPTY Then n = n + 1
            Next
        Next
    Loop Until (n > 50 And (n < 60 Or Rnd < .01)) Or nosel
    PLACEGOLD
    PLACEJEWELS
    PLACECHARS
End Sub

Function PATH (x, y)
    If mz(x, y) = EMPTY Then
        xe = (mz(x + 1, y) = EMPTY And mz(x - 1, y) = EMPTY)
        xs = (mz(x + 1, y) = SOIL And mz(x - 1, y) = SOIL)
        ye = (mz(x, y + 1) = EMPTY And mz(x, y - 1) = EMPTY)
        ys = (mz(x, y + 1) = SOIL And mz(x, y - 1) = SOIL)
        If (xe Or ye) Then PATH = TRUE Else PATH = FALSE
    Else
        PATH = FALSE
    End If
End Function

'place digger and monsters
Sub PLACECHARS
    Dim lst(1 To MZW * MZH) As XY
    lstc = 0
    For x = 1 To MZW
        For y = 1 To MZH
            If mz(x, y) = EMPTY And Not PATH(x, y) Then
                lstc = lstc + 1
                lst(lstc).x = x: lst(lstc).y = y
            End If
        Next
    Next

    z = RAND(1, lstc): mz(lst(z).x, lst(z).y) = DIGGER
    Do
        z1 = RAND(1, lstc)
    Loop Until (z1 <> z) And (DIST(lst(z), lst(z1)) > 5 Or Rnd < .04)
    mz(lst(z1).x, lst(z1).y) = ENEM
End Sub

Sub PLACEGOLD
    Dim lst(1 To MZW * MZH) As XY, lstc, c
    For x = 1 To MZW
        For y = 1 To MZH - 2
            If mz(x, y) = SOIL And mz(x, y + 1) = SOIL Then
                lstc = lstc + 1
                lst(lstc).x = x
                lst(lstc).y = y
            End If
        Next
    Next
    goldc = RAND(GOLDMIN, GOLDMAX)
    If goldc > lstc Then c = lstc Else c = goldc
    For i = 1 To c
        z = RAND(1, lstc)
        mz(lst(z).x, lst(z).y) = GOLD
        lst(z).x = lst(lstc).x: lst(z).y = lst(lstc).y
        lstc = lstc - 1
    Next
End Sub

Sub PLACEJEWELS
    Dim lst(1 To MZW * MZH) As XY
    lstc = 0
    For x = 1 To MZW
        For y = 1 To MZH
            If mz(x, y) = SOIL Then
                lstc = lstc + 1
                lst(lstc).x = x: lst(lstc).y = y
            End If
        Next
    Next
    jewc = RAND(JEWMIN, JEWMAX)
    If jewc > lstc Then jewc = lstc - RAND(0, lstc / 3)
    For i = 1 To jewc
        z = RAND(1, lstc)
        mz(lst(z).x, lst(z).y) = JEWEL
        lst(z).x = lst(lstc).x: lst(z).y = lst(lstc).y
        lstc = lstc - 1
    Next
End Sub

Function PTINRECT (r, x, y)
    If (x > rct(r).x1 And x < rct(r).x2) And (y > rct(r).y1 And y < rct(r).y2) Then PTINRECT = TRUE Else PTINRECT = FALSE
    'IF (x >= rct(r).x1 AND x <= rct(r).x2) AND (y >= rct(r).y1 AND y <= rct(r).y2) THEN PTINBORDER = TRUE ELSE PTINBORDER = FALSE
End Function

Function RAND (min, max)
    RAND = Int(Rnd * (max - min + 1)) + min
End Function

Function RECTSVALID (r1o, r2o)
    Dim r1, r2

    r1 = r1o
    r2 = r2o

    res = TRUE
    If rct(r1).y1 > rct(r2).y1 Then ymin = rct(r1).y1 Else ymin = rct(r2).y1
    If rct(r1).y2 < rct(r2).y2 Then ymax = rct(r1).y2 Else ymax = rct(r2).y2
    If ymin < ymax Then
        If rct(r1).x1 > rct(r2).x1 Then Swap r1, r2
        If rct(r1).x1 = rct(r2).x1 - 1 Then res = FALSE
        If rct(r1).x2 = rct(r2).x1 - 1 Then res = FALSE
        If rct(r1).x2 < rct(r2).x1 Then Swap r1, r2
        If rct(r1).x2 = rct(r2).x1 + 1 Then res = FALSE
        If rct(r1).x2 > rct(r2).x2 Then Swap r1, r2
        If rct(r2).x2 = rct(r1).x2 + 1 Then res = FALSE
    End If
    If rct(r1).x1 > rct(r2).x1 Then xmin = rct(r1).x1 Else xmin = rct(r2).x1
    If rct(r1).x2 < rct(r2).x2 Then xmax = rct(r1).x2 Else xmax = rct(r2).x2
    If xmin < xmax Then
        If rct(r1).y1 > rct(r2).y1 Then Swap r1, r2
        If rct(r1).y1 = rct(r2).y1 - 1 Then res = FALSE
        If rct(r1).y2 = rct(r2).y1 - 1 Then res = FALSE
        If rct(r1).y2 < rct(r2).y1 Then Swap r1, r2
        If rct(r1).y2 = rct(r2).y1 + 1 Then res = FALSE
        If rct(r1).y2 > rct(r2).y2 Then Swap r1, r2
        If rct(r2).y2 = rct(r1).y2 + 1 Then res = FALSE
    End If
    RECTSVALID = res
End Function

Sub STORELEV (f, idx$)
    Print #f, "_mine #" + idx$
    If BGR Then c = RAND(0, 3) * 16 + RAND(0, 7) Else c = 17
    Print #f, "_levcol " + LTrim$(RTrim$(Str$(c)))
    For y = 1 To MZH
        For x = 1 To MZW
            Select Case mz(x, y)
                Case EMPTY: Print #f, "#";
                Case SOIL: Print #f, ":";
                Case GOLD: Print #f, "$";
                Case DIGGER: Print #f, "d";
                Case ENEM: Print #f, "e";
                Case JEWEL: Print #f, "7";
                Case Is > 100: Print #f, "#";
            End Select
        Next
        Print #f, ""
    Next
    Print #f, ""
End Sub

