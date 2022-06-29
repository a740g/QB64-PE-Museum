'    '@@:
'   @@@@@@              #@                   @@@@@@@
'  #@@  @@'             #@'               :@@@@@@@@@
'  @@`  +@#             '@#               ,@@@@  #@@
' #@#   +@@             ,@@     ,           .@@ +@@
' @@    '@#             `@@   +@@@      @@: .@@@@@@@           @# .@,      #@
' @@        .@@@+    @@# @@  .@@@@`  '@'@@@ `@@@@@@@@  #@@@   .@+ @@: :@@@@@@
':@#        @@@@@:  @@@@@@@  @@,@@   #@@@    @@@   @@@ @@@@@  #@. @@  @@@@@@.
'+@#        @@ `@@ #@# @@@@ @@@@@+   +@@:    @@     @@'@@ #@@ @@ `@@     @@+
''@@       .@@  '@:@@   @@@.@@@@+ `@,'@@     @@    `@@#@:  @@ @@ @@#    @@@
' @@,    @@.@#  .@'@@.  `@@ #@    @@.'@@     @@   '@@@#@`  #@ @@@@@@   @@@
' #@@@@@@@@.@@ #@@ #@@@@@@@ :@@@@@@@ +@+    +@@@@@@@@ #@# @@@ @@@@@@  @@@@+  @
'  @@@@@@#  @@@@@   @@@@@    @@@@@#  #@,    @@@@@@@@  .@@@@@   @  @@ '@@@@@@@@
'                                            @                    @@:`@  ,@@@`
'                                                            @,   ,@@
'                                                            @#    @@
'                                                            @@,  `@@
'                                                             @@@@@@#
'                                                             `@@@@@
'GUI Menu Bar v0.98
'Copyright <c> 2017-18
'By Ashish
'Last Update 4/30/2017


Sub addMenu (exp$)
    If exp$ = "" Then Exit Sub

    Shared GUIMenuItems() As __MenuItemsType

    n = UBound(GUIMenuItems)
    GUIMenuItems(n).exp = exp$
    initMenuItems n
    ReDim _Preserve GUIMenuItems(n + 1) As __MenuItemsType

End Sub

Sub initMenuItems (i)
    Shared GUIMenuItems() As __MenuItemsType
    If i < 1 Or i > UBound(GUIMenuItems) Then Exit Sub
    For j = 1 To Len(RTrim$(GUIMenuItems(i).exp))
        ca$ = Mid$(GUIMenuItems(i).exp, j, 1)
        If ca$ = "[" Then Exit For
        tmp$ = tmp$ + ca$
    Next
    GUIMenuItems(i).shortKey = "!"
    For j = 1 To Len(tmp$)
        ca$ = Mid$(tmp$, j, 1)
        If ca$ = "#" Then
            GUIMenuItems(i).shortKey = Mid$(tmp$, j + 1, 1)
            GUIMenuItems(i).shortKeyPos = j - 1
            tmp2$ = Left$(tmp$, j - 1) + Mid$(tmp$, j + 1, Len(tmp$) - j)
            Exit For
        End If
    Next
    If tmp2$ = "" Then tmp2$ = tmp$
    GUIMenuItems(i).name = tmp2$
    If i = 1 Then GUIMenuItems(i).x = 10 Else GUIMenuItems(i).x = (GUIMenuItems(i - 1).x - 10) + Len(RTrim$(GUIMenuItems(i - 1).name)) * _FontWidth + 30

End Sub

Sub GUIMenubarShow ()
    '  IF NOT allowMenuBar THEN EXIT SUB

    Line (0, 0)-(_Width, _FontHeight), GUIMenubarTheme.defaultBG, BF

    For i = 1 To UBound(GUIMenuItems) - 1
        If GUIMouseY > 0 And GUIMouseY < _FontHeight And GUIMouseX > GUIMenuItems(i).x - 10 And GUIMouseX < GUIMenuItems(i).x + Len(RTrim$(GUIMenuItems(i).name)) * _FontWidth + 10 Or UCase$(GUIKeyHit$) = UCase$(GUIMenuItems(i).shortKey) Then
            If GUIMouseClick Or UCase$(GUIKeyHit$) = UCase$(GUIMenuItems(i).shortKey) Then
                'now, we have to draw  submenus
                GUIKeyHit$ = ""
                For j = 1 To UBound(GUIMenuItems) - 1
                    Color GUIMenubarTheme.defaultFG, GUIMenubarTheme.defaultBG
                    _PrintString (GUIMenuItems(j).x, 0), RTrim$(GUIMenuItems(j).name)
                    If GUIMenuItems(j).shortKey <> "!" Then
                        Color GUIMenubarTheme.shortcutKey
                        _PrintString (GUIMenuItems(j).x + (GUIMenuItems(j).shortKeyPos * _FontWidth), 0), GUIMenuItems(j).shortKey
                    End If

                Next
                backup& = _CopyImage(0)
                For j = Len(RTrim$(GUIMenuItems(i).name)) + 1 To Len(RTrim$(GUIMenuItems(i).exp))

                    ca$ = Mid$(GUIMenuItems(i).exp, j, 1)
                    If ca$ = "{" Then cb = -1
                    If ca$ = "}" And cb Then d = d + 1: cb = 0

                Next

                Dim Menus(d) As __MenuItemsType
                n = 1
                For j = Len(RTrim$(GUIMenuItems(i).name)) + 1 To Len(RTrim$(GUIMenuItems(i).exp))
                    ca$ = Mid$(GUIMenuItems(i).exp, j, 1)
                    If ca$ = "{" Then cb = -1: ca$ = ""
                    If ca$ = "}" And cb Then cb = 0: ca$ = "": Menus(n).name = tmps$: n = n + 1: tmps$ = ""
                    If cb Then tmps$ = tmps$ + ca$
                Next

                For j = 1 To d
                    If RTrim$(Menus(j).name) = "***" Then Else h = h + 1
                Next
                totalHeight = h * (_FontHeight + 8) + 10
                For j = 1 To d
                    G = Len(RTrim$(Menus(j).name))
                    If G > pg Then fg = G
                    pg = G
                Next
                totalWidth = (fg * _FontWidth) + 70
                Menus(0).x = _FontHeight / 2
                Line (GUIMenuItems(i).x - 10, _FontHeight)-(totalWidth + GUIMenuItems(i).x, totalHeight + _FontHeight), GUIMenubarTheme.defaultBG, BF
                For j = 1 To d
                    If j = 1 Then
                        Menus(j).x = _FontHeight + 8
                    Else
                        If RTrim$(Menus(j).name) = "***" Then Menus(j).x = Menus(j - 1).x + 8 Else Menus(j).x = Menus(j - 1).x + _FontHeight + 8
                    End If
                Next
                For j = 1 To d
                    tmp$ = RTrim$(Menus(j).name)
                    For k = 1 To Len(tmp$)
                        ca$ = Mid$(tmp$, k, 1)
                        If ca$ = "#" Then
                            Menus(j).shortKey = Mid$(tmp$, k + 1, 1)
                            Menus(j).shortKeyPos = k - 1
                            Menus(j).name = Left$(tmp$, k - 1) + Mid$(tmp$, k + 1, Len(tmp$) - k)
                            Exit For
                        End If
                    Next
                Next
                GUIMouseClick = 0
                GUIMouseX = 0
                GUIMouseY = 0
                Do
                    While _MouseInput: Wend
                    GUIMouseX = _MouseX
                    GUIMouseY = _MouseY
                    GUIMouseClick = _MouseButton(1)
                    k$ = InKey$
                    If GUIMouseX > GUIMenuItems(i).x + totalWidth And GUIMouseClick Or GUIMouseY > _FontHeight + totalHeight And GUIMouseClick Or GUIMouseX < GUIMenuItems(i).x - 10 And GUIMouseClick Or GUIMouseY <= _FontHeight And GUIMouseX > GUIMenuItems(i).x + Len(RTrim$(GUIMenuItems(i).name)) * _FontWidth + 10 And GUIMouseClick Or GUIMouseY <= _FontHeight And GUIMouseX < GUIMenuItems(i).x - 10 And GUIMouseClick Then

                        GUISelected$ = ""
                        Exit Do

                    End If
                    For j = 1 To d
                        If RTrim$(Menus(j).name) = "***" Then
                            Line (GUIMenuItems(i).x - 10, (Menus(j).x + _FontHeight) - 4)-Step(totalWidth + 10, 0), GUIMenubarTheme.divider
                        Else
                            If GUIMouseX > GUIMenuItems(i).x - 10 And GUIMouseX < GUIMenuItems(i).x + totalWidth And GUIMouseY > Menus(j).x - 8 And GUIMouseY < Menus(j).x + _FontHeight Then
                                GUISelected$ = RTrim$(GUIMenuItems(i).name) + "^" + RTrim$(Menus(j).name)
                                If GUIMouseClick Then
                                    GUISelected$ = RTrim$(GUIMenuItems(i).name) + "#" + RTrim$(Menus(j).name)
                                    Exit Do
                                End If
                                Line (GUIMenuItems(i).x - 10, Menus(j).x - 8)-(GUIMenuItems(i).x + totalWidth, Menus(j).x + _FontHeight), GUIMenubarTheme.hoverBG, BF
                                Color GUIMenubarTheme.hoverFG, GUIMenubarTheme.hoverBG
                            Else
                                Line (GUIMenuItems(i).x - 10, Menus(j).x - 8)-(GUIMenuItems(i).x + totalWidth, Menus(j).x + _FontHeight), GUIMenubarTheme.defaultBG, BF
                                Color GUIMenubarTheme.defaultFG, GUIMenubarTheme.defaultBG
                            End If
                            _PrintString (GUIMenuItems(i).x, Menus(j).x - 4), RTrim$(Menus(j).name)
                            If GUIMenuItems(i).shortKey <> "!" Then
                                Color GUIMenubarTheme.shortcutKey
                                _PrintString (GUIMenuItems(i).x + (Menus(j).shortKeyPos * _FontWidth), Menus(j).x - 4), Menus(j).shortKey
                            End If
                            If UCase$(k$) = UCase$(Menus(j).shortKey) Then GUISelected$ = RTrim$(GUIMenuItems(i).name) + "#" + RTrim$(Menus(j).name): Exit Do
                        End If
                    Next
                    _Display
                    _Limit 30
                Loop
                Cls , _RGB(0, 0, 0)
                _PutImage , backup&
                _FreeImage backup&
                Erase Menus
                Exit Sub
            End If
            Color GUIMenubarTheme.hoverFG, GUIMenubarTheme.hoverBG
            Line (GUIMenuItems(i).x - 10, 0)-(GUIMenuItems(i).x + Len(RTrim$(GUIMenuItems(i).name)) * _FontWidth + 10, _FontHeight), GUIMenubarTheme.hoverBG, BF
        Else
            Color GUIMenubarTheme.defaultFG, GUIMenubarTheme.defaultBG
        End If
        _PrintString (GUIMenuItems(i).x, 0), RTrim$(GUIMenuItems(i).name)
        If GUIMenuItems(i).shortKey <> "!" Then
            Color GUIMenubarTheme.shortcutKey
            _PrintString (GUIMenuItems(i).x + (GUIMenuItems(i).shortKeyPos * _FontWidth), 0), GUIMenuItems(i).shortKey
        End If
    Next
End Sub

