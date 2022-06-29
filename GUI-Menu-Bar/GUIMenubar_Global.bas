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



TYPE menuBarThemeSettings
    defaultFG AS _UNSIGNED LONG
    defaultBG AS _UNSIGNED LONG
    hoverFG AS _UNSIGNED LONG
    hoverBG AS _UNSIGNED LONG
    divider AS _UNSIGNED LONG
    shortcutKey AS _UNSIGNED LONG
    disableFG AS _UNSIGNED LONG
    disableBG AS _UNSIGNED LONG
    hoverDisableFG AS _UNSIGNED LONG
    hoverDisableBG AS _UNSIGNED LONG
END TYPE

TYPE __MenuItemsType
    exp AS STRING * 512
    name AS STRING * 32
    x AS INTEGER
    shortKey AS STRING * 1
    shortKeyPos AS INTEGER
END TYPE

DIM SHARED GUIMenubarTheme AS menuBarThemeSettings

REDIM SHARED GUIMenuItems(1) AS __MenuItemsType

'Default theme settings
GUIMenubarTheme.defaultFG = _RGB32(0, 0, 0)
GUIMenubarTheme.defaultBG = _RGB32(240, 240, 240)
GUIMenubarTheme.hoverFG = _RGB32(0, 0, 0)
GUIMenubarTheme.hoverBG = _RGB32(100, 200, 200)
GUIMenubarTheme.divider = _RGB32(150, 150, 150)
GUIMenubarTheme.shortcutKey = _RGB32(255, 0, 255)

DIM SHARED GUIMouseX, GUIMouseY, GUIMouseClick, GUISelected$, GUIKeyHit$

