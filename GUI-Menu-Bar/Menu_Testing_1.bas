'$include:'GUIMenubar_Global.bas'

_Title "Menu_Testing_1"
Screen _NewImage(600, 400, 32)
'Custom theme settings
GUIMenubarTheme.defaultFG = _RGB(255, 255, 255)
GUIMenubarTheme.defaultBG = _RGB(40, 40, 40)
GUIMenubarTheme.hoverBG = _RGB(255, 150, 0)
GUIMenubarTheme.hoverFG = _RGB(255, 255, 255)
GUIMenubarTheme.divider = _RGB(255, 255, 255)
GUIMenubarTheme.shortcutKey = _RGB(255, 255, 0)

addMenu "#File[{#New File}{#Open File}{***}{#Save}{Save #As}{***}{E#xit}]"
addMenu "#Insert[{#Line}{***}{#Circle}{#Rectangle}{#Triangle}{***}{#Polygon}{Pol#yline}]"
addMenu "#View[{HTML #Code}{#Browser Output}]"
addMenu "#Options[{#Language}{#Theme}{***}{#Help}{About A#uthor}{***}{#Version}]"
_PrintString (150, 200), "Try to select any menuitem"
Do
    While _MouseInput: Wend
    GUIMouseX = _MouseX
    GUIMouseY = _MouseY
    GUIMouseClick = _MouseButton(1)
    GUIKeyHit$ = InKey$
    If GUIMouseY < _FontHeight Or GUIKeyHit$ <> "" Then GUIMenubarShow
    If GUISelected$ = "File#Exit" Then End
    If GUISelected$ <> "" Then
        Color _RGB(255, 255, 255), _RGB(0, 0, 0)
        _PrintString (150, 200), Space$(50)
        _PrintString (150, 230), Space$(50)
        a = InStr(GUISelected$, "#")
        _PrintString (150, 200), "You have selected " + Left$(GUISelected$, a - 1) + "-->" + Mid$(GUISelected$, a + 1, Len(GUISelected$) - a)
        Color _RGB(0, 200, 255)
        _PrintString (150, 230), "GuiSelected$ = " + Chr$(34) + GUISelected$ + Chr$(34)
        GUISelected$ = ""
    End If
    _Display
    _Limit 30
Loop

'$include:'GUIMenubar_Method.bas'
