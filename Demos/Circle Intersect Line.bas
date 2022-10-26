_Title "Circle Intersect Line" ' b+ 2020-01-31 develop
' Find point on line perpendicular to line at another point" 'B+ 2019-12-15
' further for a Line and Circle Intersect, making full use of the information from the link below.

Const xmax = 800, ymax = 600
Screen _NewImage(xmax, ymax, 32)
_ScreenMove 300, 40

Do
    Cls
    If testTangent = 0 Then 'test plug in set of border conditions not easy to click
        Print "First set here is a plug in test set for vertical lines."
        mx(1) = 200: my(1) = 100: mx(2) = 200: my(2) = 400 'line  x = 200
        mx(3) = 400: my(3) = 300: mx(4) = 150: my(4) = 300 ' circle origin (center 400, 300) then radius test 200 tangent, 150 more than tangent, 250 short
        For i = 1 To 4
            Circle (mx(i), my(i)), 2
        Next
        If mx(1) <> mx(2) Then
            slopeYintersect mx(1), my(1), mx(2), my(2), m, Y0 ' Y0 otherwise know as y Intersect
            Line (0, Y0)-(xmax, m * xmax + Y0), &HFF0000FF
            Line (mx(1), my(1))-(mx(2), my(2))
        Else
            Line (mx(1), 0)-(mx(1), ymax), &HFF0000FF
            Line (mx(1), my(1))-(mx(2), my(2))
        End If
        testTangent = 1
    Else
        Print "First 2 clicks will form a line, 3rd the circle origin and 4th the circle radius:"
        While pi < 4 'get 4 mouse clicks
            _PrintString (20, 20), Space$(20)
            _PrintString (20, 20), "Need 4 clicks, have" + Str$(pi)
            While _MouseInput: Wend
            If _MouseButton(1) And oldMouse = 0 Then 'new mouse down
                pi = pi + 1
                mx(pi) = _MouseX: my(pi) = _MouseY
                Circle (mx(pi), my(pi)), 2
                If pi = 2 Then 'draw first line segment then line
                    If mx(1) <> mx(2) Then
                        slopeYintersect mx(1), my(1), mx(2), my(2), m, Y0 ' Y0 otherwise know as y Intersect
                        Line (0, Y0)-(xmax, m * xmax + Y0), &HFF0000FF
                        Line (mx(1), my(1))-(mx(2), my(2))
                    Else
                        Line (mx(1), 0)-(mx(1), ymax), &HFF0000FF
                        Line (mx(1), my(1))-(mx(2), my(2))
                    End If
                End If
            End If
            oldMouse = _MouseButton(1)
            _Display
            _Limit 60
        Wend
    End If
    p = mx(3): q = my(3)
    r = Sqr((mx(3) - mx(4)) ^ 2 + (my(3) - my(4)) ^ 2)
    Circle (p, q), r, &HFFFF0000
    If mx(1) = mx(2) Then 'line is vertical so if r =
        If r = Abs(mx(1) - mx(3)) Then ' one point tangent intersect
            Print "Tangent point is "; TS$(mx(1)); ", "; TS$(my(3))
            Circle (mx(1), my(3)), 2, &HFFFFFF00
            Circle (mx(1), my(3)), 4, &HFFFFFF00
        ElseIf r < Abs(mx(1) - mx(3)) Then 'no intersect
            Print "No intersect, radius too small."
        Else '2 point intersect
            ydist = Sqr(r ^ 2 - (mx(1) - mx(3)) ^ 2)
            y1 = my(3) + ydist
            y2 = my(3) - ydist
            Print "2 Point intersect (x1, y1) = "; TS$(mx(1)); ", "; TS$(y1); "  (x2, y2) = "; TS$(mx(1)); ", "; TS$(y2)
            Circle (mx(1), y1), 2, &HFFFFFF00 'marking intersect points yellow
            Circle (mx(1), y2), 2, &HFFFFFF00
            Circle (mx(1), y1), 4, &HFFFFFF00 'marking intersect points yellow
            Circle (mx(1), y2), 4, &HFFFFFF00

        End If
    Else
        'OK the calculations!
        'from inserting eq ofline into eq of circle where line intersects circle see reference
        ' https://math.stackexchange.com/questions/228841/how-do-i-calculate-the-intersections-of-a-straight-line-and-a-circle
        A = m ^ 2 + 1
        B = 2 * (m * Y0 - m * q - p)
        C = q ^ 2 - r ^ 2 + p ^ 2 - 2 * Y0 * q + Y0 ^ 2
        D = B ^ 2 - 4 * A * C 'telling part of Quadratic formula = 0 then circle is tangent  or > 0 then 2 intersect points
        If D < 0 Then ' no intersection
            Print "m, y0 "; TS$(m); ", "; TS$(Y0)
            Print "(p, q) "; TS$(p); ", "; TS$(q)
            Print "A: "; TS$(A)
            Print "B: "; TS$(B)
            Print "C: "; TS$(C)
            Print "D: "; TS$(D); " negative so no intersect."
        ElseIf D = 0 Then ' one point tangent
            x1 = (-B + Sqr(D)) / (2 * A)
            y1 = m * x1 + Y0
            Print "Tangent Point Intersect (x1, y1) = "; TS$(x1); ", "; TS$(y1)
            Circle (x1, y1), 2, &HFFFFFF00 'yellow circle should be on line perprendicular to 3rd click point
            Circle (x1, y1), 4, &HFFFFFF00 'yellow circle should be on line perprendicular to 3rd click point
        Else
            '2 points
            x1 = (-B + Sqr(D)) / (2 * A): y1 = m * x1 + Y0
            x2 = (-B - Sqr(D)) / (2 * A): y2 = m * x2 + Y0
            Print "2 Point intersect (x1, y1) = "; TS$(x1); ", "; TS$(y1); "  (x2, y2) = "; TS$(x2); ", "; TS$(y2)
            Circle (x1, y1), 2, &HFFFFFF00 'marking intersect points yellow
            Circle (x2, y2), 2, &HFFFFFF00
            Circle (x1, y1), 4, &HFFFFFF00 'marking intersect points yellow
            Circle (x2, y2), 4, &HFFFFFF00
        End If
    End If
    _Display
    Input "press enter to continue, any + enter to quit "; q$
    If Len(q$) Then System
    pi = 0 'point index
Loop Until _KeyDown(27)

Sub slopeYintersect (X1, Y1, X2, Y2, slope, Yintercept) ' fix for when x1 = x2
    slope = (Y2 - Y1) / (X2 - X1)
    Yintercept = slope * (0 - X1) + Y1
End Sub

Function TS$ (n)
    TS$ = _Trim$(Str$(n))
End Function



