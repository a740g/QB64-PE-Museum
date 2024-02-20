Option _Explicit ' 2022-08-05 Remake to match the Wordle Game On-Line
'$include:'GUIb.BI'
Randomize Timer
Dim Shared As String Dict(1 To 3146), TheWord
Dim Shared As Long TopWord, BtnKey(1 To 26), LB(1 To 30), BtnEnter, BtnBkSp, Turn, CP

_Title "Wordle GUIb"
Intro

'   Set Globals from BI
Xmax = 780: Ymax = 700: GuiTitle$ = "GUI Wordle GUIb"
OpenWindow Xmax, Ymax, GuiTitle$, "arial.ttf" ' need to do this before drawing anything from NewControls"
Init
MainRouter ' after all controls setup
System

Sub BtnClickEvent (i As Long)
    Dim blank$, guess$, keyOrder$
    Dim As Long colorCode(1 To 5), letter, start, hits, p, ControlKeyN

    keyOrder$ = "ZXCVBNMASDFGHJKLQWERTYUIOP" ' mid$(keyorder$, i, 1)  or ControlPos = instr(KeyOrder$, con(btnkey(i)).text)
    Select Case i
        Case 1 To 26 ' Letter Keys  lbl pos = Turn * 5 + cp
            If CP >= 1 And CP <= 5 Then
                con(LB(Turn * 5 + CP)).Text = con(BtnKey(i)).Text
                p = Turn * 5 + CP
                drwLbl LB(Turn * 5 + CP)
                ' drwLabel (x, y, w, h, fontH, fc As _Unsigned Long, bc As _Unsigned Long, align, text As String)
                If CP < 5 Then CP = CP + 1
            End If
        Case BtnBkSp
            If CP > 1 And CP < 5 Then
                con(LB(Turn * 5 + CP - 1)).Text = ""
                drwLbl LB(Turn * 5 + CP - 1)
                CP = CP - 1
            ElseIf CP = 5 Then ' is it blank or not
                If con(LB(Turn * 5 + CP)).Text = "" Then
                    con(LB(Turn * 5 + CP - 1)).Text = ""
                    drwLbl LB(Turn * 5 + CP - 1)
                    CP = CP - 1
                Else
                    con(LB(Turn * 5 + 5)).Text = "" ' just remove letter
                    drwLbl LB(Turn * 5 + 5)
                End If
            End If
        Case BtnEnter
            ''before updating turn check the guess$ length and if in dictionary
            guess$ = ""
            For i = 1 To 5 ' build guess from labels
                If con(LB(Turn * 5 + i)).Text <> "" Then
                    guess$ = guess$ + con(LB(Turn * 5 + i)).Text
                Else ' dont have 5 letters so reject
                    _MessageBox "Guessing Error:", "Missing letter in guess row."
                    Exit Sub
                End If
            Next
            If find&(guess$) = 0 Then ' not in our dictionary so wont be fair guess
                _MessageBox "Guessing Error:", "Sorry, could not find your guess in our little Dictionery. Retype your guess."
                Exit Sub
            End If
            Turn = Turn + 1 ' OK a turn has been taken it's a word
            CP = 1 ' for next row of guess letters
            start = (Turn - 1) * 5 'guess row helper
            blank$ = TheWord ' we use blank to remove letters as we assign colors
            For letter = 1 To 5
                If Mid$(TheWord, letter, 1) = Mid$(guess$, letter, 1) Then
                    hits = hits + 1
                    Mid$(blank$, letter, 1) = " " ' remove green letters taken by direct hits
                    colorCode(letter) = 3
                End If
            Next
            For letter = 1 To 5
                If colorCode(letter) <> 3 Then
                    p = InStr(blank$, Mid$(guess$, letter, 1))
                    If p > 0 Then
                        colorCode(letter) = 2
                        Mid$(blank$, p, 1) = " " ' remove so can't color again
                    End If
                End If
            Next
            For letter = 1 To 5 '                           now to display our colorful feedback
                con(LB(start + letter)).Text = Mid$(guess$, letter, 1)
                ControlKeyN = InStr(keyOrder$, Mid$(guess$, letter, 1))
                If colorCode(letter) = 3 Then '             fantastic
                    con(LB(start + letter)).BC = C3(60)
                    con(BtnKey(ControlKeyN)).BC = C3(60)
                ElseIf colorCode(letter) = 2 Then '         in the ball park
                    con(LB(start + letter)).BC = C3(990)
                    con(BtnKey(ControlKeyN)).BC = C3(990)
                Else '                                      acknowledge we checked the letter on keyboard too
                    con(LB(start + letter)).BC = C3(333)
                    con(BtnKey(ControlKeyN)).BC = C3(333)
                End If
                con(LB(start + letter)).FC = C3(888) '      all checked letters are aglow
                con(BtnKey(ControlKeyN)).FC = C3(888)

                drwLbl LB(start + letter)
                drwBtn BtnKey(ControlKeyN) '             very helpful to show what letters have been tried!!!
            Next
            If hits = 5 Then
                _MessageBox "Congratulations", "You got it!"
                ResetGame
                Exit Sub
            End If
            If Turn = 6 Then
                _MessageBox "So sorry, out of turns", "The word was " + TheWord + "."
                ResetGame
            End If
    End Select
End Sub

' this is to keep MainRouter happy
Sub LstSelectEvent (control As Long)
    control = control
End Sub

Sub SldClickEvent (i As Long)
    i = i
End Sub

Sub PicClickEvent (i As Long, Pmx As Long, Pmy As Long)
    i = i: Pmx = Pmx: Pmy = Pmy
End Sub

Sub PicFrameUpdate (i As Long, MXfracW, MYfracH)
    i = i: MXfracW = MXfracW: MYfracH = MYfracH
End Sub

Sub lblClickevent (i As Long)
    i = i
End Sub

Sub Intro
    Dim fl$
    Screen _NewImage(600, 400, 32) ' leave room for Editor window next to this QB64 app
    _ScreenMove 200, 200
    Color _RGB32(200, 200, 200), _RGB32(0, 0, 0) ' not too bright white on black for normal print
    '      123456789012345678901234567890123456789012345678901234567890123456789012345
    Locate 8, 1
    Print "                          The Skinny on Wordle:"
    Print
    Print "         You get 6 tries to guess a 5 letter word with real words!"
    Print "          A letter color coded yellow is right letter wrong place."
    Print "          A letter color coded green is right letter right place."
    Print
    Print "    Hint: try early on, words that cover most letters specially vowels."
    Print
    Print "                ... zzz   Press a key to continue  ...zzz"
    Sleep
    Open ExePath + OSslash + "Word Lists" + OSslash + "5l_words.txt" For Input As #1
    ' W3 version allows repeated letters, allot of 5 letter 1st names in here
    While Not EOF(1)
        TopWord = TopWord + 1
        Input #1, fl$
        Dict(TopWord) = UCase$(fl$) ' OK upper case letters to match On-Line Wordle
    Wend
    Close #1
End Sub

Sub Init ' controls and variables to start first game
    Dim As Long i, y, x
    Dim t$
    ' last row first, it's anchor for all the others
    i = 1: y = 630: t$ = "ZXCVBNM" ' same as Keyboard
    For x = 0 To 6
        BtnKey(i) = NewControl(1, x * 70 + 150, y, 60, 60, Mid$(t$, x + 1, 1), "")
        con(BtnKey(i)).FontH = 30
        con(BtnKey(i)).FC = C3(0)
        con(BtnKey(i)).BC = C3(888)
        drwBtn BtnKey(i)
        i = i + 1
    Next
    ' next row up aligns letters with bottom row
    y = 560: t$ = "ASDFGHJKL"
    For x = 0 To 8
        BtnKey(i) = NewControl(1, x * 70 + 80, y, 60, 60, Mid$(t$, x + 1, 1), "")
        con(BtnKey(i)).FontH = 30
        con(BtnKey(i)).FC = C3(0)
        con(BtnKey(i)).BC = C3(888)
        drwBtn BtnKey(i)
        i = i + 1
    Next
    ' next row is misaligned by half key
    y = 490: t$ = "QWERTYUIOP"
    For x = 0 To 9
        BtnKey(i) = NewControl(1, x * 70 + 45, y, 60, 60, Mid$(t$, x + 1, 1), "")
        con(BtnKey(i)).FontH = 30
        con(BtnKey(i)).FC = C3(0)
        con(BtnKey(i)).BC = C3(888)
        drwBtn BtnKey(i)
        i = i + 1
    Next
    BtnEnter = NewControl(1, 10, 630, 130, 60, "enter", "")
    con(BtnEnter).FontH = 30
    con(BtnEnter).FC = C3(0)
    con(BtnEnter).BC = C3(888)
    drwBtn BtnEnter
    BtnBkSp = NewControl(1, 640, 630, 130, 60, Chr$(27), "")
    con(BtnBkSp).FontH = 30
    con(BtnBkSp).FC = C3(0)
    con(BtnBkSp).BC = C3(888)
    drwBtn BtnBkSp
    i = 1 ' guess labels above the above
    For y = 0 To 5
        For x = 0 To 4
            'drwLabel (x, y, w, h, fontH, fc As _Unsigned Long, bc As _Unsigned Long, align, text As String)
            LB(i) = NewControl(6, x * 70 + 220, y * 78 + 18, 60, 60, "", "")
            con(LB(i)).FontH = 30
            con(LB(i)).FC = C3(0)
            con(LB(i)).BC = C3(888)
            drwLbl LB(i)
            i = i + 1
        Next
    Next
    CP = 1 ' first position in guess = 0
    TheWord = Dict(Int(Rnd * TopWord) + 1)
    ActiveControl = 0
    _Title TheWord 'debug
End Sub

Sub ResetGame ' reset Controls and Variables for new game
    Dim As Long i
    CP = 1: Turn = 0
    TheWord = Dict(Int(Rnd * TopWord) + 1)
    For i = 1 To 30 ' clear labels and colors
        con(LB(i)).Text = ""
        con(LB(i)).FC = C3(0)
        con(LB(i)).BC = C3(888)
        drwLbl LB(i)
    Next
    For i = 1 To 26 ' clear keyboard colors
        con(BtnKey(i)).FC = C3(0)
        con(BtnKey(i)).BC = C3(888)
        drwBtn BtnKey(i)
    Next
End Sub

Function find& (word$)
    Dim As Long hi, lo, md
    hi = TopWord: lo = 1
    Do
        md = Int((hi + lo) / 2)
        If md <= lo Or md >= hi Then Exit Function
        If Dict(md) = word$ Then find& = -1: Exit Function
        If Dict(md) < word$ Then lo = md Else hi = md
    Loop
End Function

'$include:'GUIb.BM'
