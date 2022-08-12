'============
'TANKDRUM.BAS v1.0d
'============
'A Playable/Recordable Tankdrum Virtual Instrument
'Coded by Dav for QB64 Phoenix Edition, MAY/2022

'New in v1.0d:
'               - Sounding notes are now highlighted.
'               - Added Menu/Help screen.  Press M for it.
'               - Added file saving box.
'               - Added loading a file box.
'               - changed song extensions to .TNK
'               - Included several sample .TNK files to load.
'               - made some small bug fixes.

'-----
'ABOUT
'-----

'QB64 TankDrum is a virtual instrument that you can play
'and record little tunes with.  Use the mouse to click on
'and play notes. The program starts in freeplay mode, but
'you can record in real time as you play by pressing R.
'Record over your song several times to add more notes and
'make more complex patterns (called overdubbing).

'--------
'CONTROLS
'--------

'Press R to record song and to overdub (add) notes to a song.
'Press U to Undo last recording (in case you nmake a mistake!
'Press P to play back the recorded song currently in memory.
'Press C to clear (erase) the recorded song currently in memory.

'Press ESC to stop recording and to stop playing back of the song.
'NOTE: You can also play notes during a song play back.

'Press S to Save your recording in the current dir.
'Press L to Load a .TNK recording file (if any exists).
'Press D to Delete a currently loaded .TNK file.


$ExeIcon:'./img/tankdrum.ico'
_Icon

Dim Shared aflag, atimer, bflag, btimer, cflag, ctimer, dflag, dtimer
Dim Shared eflag, etimer, fflag, ftimer, gflag, gtimer, hflag, htimer
Dim Shared iflag, itimer, jflag, jtimer, kflag, ktimer, lflag, ltimer
Dim Shared mflag, mtimer, nflag, ntimer, oflag, otimer

Dim Shared a&, b&, c&, d&, e&, f&, g&, h&, i&, j&, k&, l&, m&, n&, o&

Screen _LoadImage("img\tankdrum.png", 32)

Do: Loop Until _ScreenExists 'Make sure window exists before TITLE used.
_Title "QB64 TankDrum v1.0d"

'Load sound samples
a& = _SndOpen("ogg\a.ogg")
b& = _SndOpen("ogg\b.ogg")
c& = _SndOpen("ogg\c.ogg")
d& = _SndOpen("ogg\d.ogg")
e& = _SndOpen("ogg\e.ogg")
f& = _SndOpen("ogg\f.ogg")
g& = _SndOpen("ogg\g.ogg")
h& = _SndOpen("ogg\h.ogg")
i& = _SndOpen("ogg\i.ogg")
j& = _SndOpen("ogg\j.ogg")
k& = _SndOpen("ogg\k.ogg")
l& = _SndOpen("ogg\l.ogg")
m& = _SndOpen("ogg\m.ogg")
n& = _SndOpen("ogg\n.ogg")
o& = _SndOpen("ogg\o.ogg")

MaxSongLength = 500000 'max of 500k bytes song data

'play a welcome scale (all notes)
For d = 97 To 111
    PlayNote Chr$(d)
    GoSub NoteDisplay
    _Delay .05
Next

'========
MainLoop:
'========

GoSub DrawTopBar

Do

    GoSub PlayDrum

    k$ = UCase$(InKey$)
    If k$ = "R" Then GoSub record: GoTo MainLoop
    If k$ = "P" Then GoSub playback: GoTo MainLoop
    If k$ = "C" Then
        NoteData$ = ""
        loadedfile$ = ""
        ok$ = IBOX$("SONG MEMORY CLEARED!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
        GoTo MainLoop
    End If
    If k$ = "U" Then
        If NoteData$ <> "" Then
            NoteData$ = UndoData$
            ok$ = IBOX$("LAST RECORDING UNDONE!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
        Else
            ok$ = IBOX$("NO RECORDING TO UNDO!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
        End If
        GoTo MainLoop
    End If
    If k$ = "S" Then
        If NoteData$ <> "" Then
            fname$ = IBOX$("SAVE FILE AS: ", 20, _RGB(255, 255, 255), _RGB(70, 95, 114), 0)
            If fname$ <> "" Then
                If InStr(1, UCase$(fname$), ".TNK") = 0 Then fname$ = fname$ + ".tnk"
                Open fname$ For Output As #1
                Print #1, NoteData$;: Close 1
                ok$ = IBOX$(UCase$(fname$) + " HAS BEEN SAVED!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
                loadedfile$ = fname$
            End If
        Else
            ok$ = IBOX$("THERE IS NO SONG TO SAVE!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
        End If
        GoTo MainLoop
    End If ' _RGB(70, 95, 114)
    If k$ = "L" Then
        lf$ = FileSelect$(5, 15, 20, 45, "*.tnk", _RGB(32, 32, 64), _RGB(60, 85, 104), _RGB(255, 255, 255), _RGB(255, 255, 255), _RGB(232, 232, 0))
        If lf$ <> "" Then
            loadedfile$ = Mid$(lf$, _InStrRev(lf$, "\") + 1)
            Open loadedfile$ For Binary As #1
            NoteData$ = Input$(LOF(1), 1): Close 1
            plf$ = UCase$(loadedfile$) + " LOADED!"
            ok$ = IBOX$(plf$, 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
        Else
            ok$ = IBOX$("NO SONG FILE SELECTED!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
        End If

        GoTo MainLoop

    End If

    If k$ = "D" Then
        If _FileExists(loadedfile$) Then
            ''=== ask make sure here
            ok$ = IBOX$("DELETE " + UCase$(loadedfile$) + " (Y/N)? ", 1, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
            huh$ = UCase$(ok$)
            If huh$ = "Y" Then
                Kill loadedfile$
                ok$ = IBOX$(UCase$(loadedfile$) + " DELETED!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
                loadedfile$ = ""
            End If
        Else
            If loadedfile$ = "" Then
                ok$ = IBOX$(" NO SONG FILE IS LOADED!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
            Else
                ok$ = IBOX$(UCase$(loadedfile$) + " NOT FOUND!", 0, _RGB(255, 255, 255), _RGB(70, 95, 114), 2)
            End If
        End If

        GoTo MainLoop

    End If

    If k$ = "M" Then
        backup& = _CopyImage(_Display)
        temp& = _LoadImage("img\menu.png", 32)
        _PutImage (120, 120), temp&
        hmm$ = Input$(1)
        _PutImage (0, 0), backup&
        _FreeImage temp&
        _FreeImage backup&
    End If

Loop

End

'=========
DrawTopBar:
'=========
Line (0, 0)-(_Width, 16), _RGB(32, 32, 64), BF
Color _RGB(255, 255, 255), _RGB(32, 32, 64): Locate 1, 1
If loadedfile$ = "" And NoteData$ = "" Then Print " Song: (none)";
If loadedfile$ = "" And NoteData$ <> "" Then Print " Song: (unsaved)";
If loadedfile$ <> "" Then Print " Song: "; loadedfile$
Locate 1, 63: Print "M = MENU";
Return

'=======
record:
'=======

'Make copy of NoteData$ for undo purposes
UndoData$ = NoteData$

If NoteData$ = "" Then NoteData$ = "1" 'song recording marker
note = 1

Color _RGB(255, 255, 255), _RGB(255, 0, 0)
Locate 1, 1: Print " Now Recording | ESC to Stop           ";

Do

    note$ = ""

    'playback previously recorded notes
    Select Case Mid$(NoteData$, note, 1)
        Case "a": PlayNote "a"
        Case "b": PlayNote "b"
        Case "c": PlayNote "c"
        Case "d": PlayNote "d"
        Case "e": PlayNote "e"
        Case "f": PlayNote "f"
        Case "g": PlayNote "g"
        Case "h": PlayNote "h"
        Case "i": PlayNote "i"
        Case "j": PlayNote "j"
        Case "k": PlayNote "k"
        Case "l": PlayNote "l"
        Case "m": PlayNote "m"
        Case "n": PlayNote "n"
        Case "o": PlayNote "o"
    End Select

    'Add these notes to recording...
    mi = _MouseInput
    If _MouseButton(1) = 0 Then done = 0
    If _MouseButton(1) And done = 0 Then
        mx = _MouseX: my = _MouseY
        If mx > 217 And mx < 269 And my > 226 And my < 355 Then PlayNote "a": note$ = "a"
        If mx > 276 And mx < 329 And my > 226 And my < 304 Then PlayNote "b": note$ = "b"
        If mx > 335 And mx < 382 And my > 226 And my < 355 Then PlayNote "c": note$ = "c"
        If mx > 271 And mx < 328 And my > 402 And my < 545 Then PlayNote "d": note$ = "d"
        If mx > 351 And mx < 432 And my > 407 And my < 510 Then PlayNote "e": note$ = "e"
        If mx > 414 And mx < 507 And my > 346 And my < 424 Then PlayNote "f": note$ = "f"
        If mx > 412 And mx < 523 And my > 265 And my < 321 Then PlayNote "g": note$ = "g"
        If mx > 416 And mx < 493 And my > 175 And my < 242 Then PlayNote "h": note$ = "h"
        If mx > 354 And mx < 420 And my > 111 And my < 182 Then PlayNote "i": note$ = "i"
        If mx > 266 And mx < 334 And my > 70 And my < 184 Then PlayNote "j": note$ = "j"
        If mx > 179 And mx < 244 And my > 113 And my < 182 Then PlayNote "k": note$ = "k"
        If mx > 109 And mx < 182 And my > 174 And my < 240 Then PlayNote "l": note$ = "l"
        If mx > 83 And mx < 184 And my > 265 And my < 320 Then PlayNote "m": note$ = "m"
        If mx > 98 And mx < 185 And my > 345 And my < 414 Then PlayNote "n": note$ = "n"
        If mx > 173 And mx < 245 And my > 405 And my < 508 Then PlayNote "o": note$ = "o"
        done = 1 'did a mouse click
    End If

    GoSub NoteDisplay

    If note$ <> "" Then
        If note <= Len(NoteData$) Then
            Mid$(NoteData$, note, 1) = note$ 'add the note
        Else
            NoteData$ = NoteData$ + note$
        End If
    Else
        If note >= Len(NoteData$) Then
            NoteData$ = NoteData$ + " " 'else add empty space
        End If
    End If

    note = note + 1
    If note >= MaxSongLength Then Exit Do

    _Limit 1500

Loop Until InKey$ = Chr$(27)

Do: Loop Until InKey$ = ""

Return


'========
playback:
'========

'If nothing recorded yet, don't try play
If NoteData$ = "" Then
    Color _RGB(0, 0, 0), _RGB(255, 255, 0)
    Locate 1, 1: Print " No recorded song in memory! ";
    _Delay 2
    Do: Loop Until InKey$ = ""
    Return
End If

Color _RGB(0, 0, 0), _RGB(0, 255, 0)
Locate 1, 1: Print " Playing song | ESC to stop            ";

note = 1

Do
    Select Case Mid$(NoteData$, note, 1)
        Case "a": PlayNote "a"
        Case "b": PlayNote "b"
        Case "c": PlayNote "c"
        Case "d": PlayNote "d"
        Case "e": PlayNote "e"
        Case "f": PlayNote "f"
        Case "g": PlayNote "g"
        Case "h": PlayNote "h"
        Case "i": PlayNote "i"
        Case "j": PlayNote "j"
        Case "k": PlayNote "k"
        Case "l": PlayNote "l"
        Case "m": PlayNote "m"
        Case "n": PlayNote "n"
        Case "o": PlayNote "o"
    End Select

    note = note + 1

    If note >= Len(NoteData$) Then Exit Do

    _Limit 1500

    GoSub PlayDrum 'you can play notes too while song is playing

Loop Until InKey$ = Chr$(27)

Do: Loop Until InKey$ = ""

Return


'========
PlayDrum: 'Gets mouse input and plays drum notes
'========

mi = _MouseInput
If _MouseButton(1) = 0 Then done = 0

If _MouseButton(1) And done = 0 Then
    mx = _MouseX: my = _MouseY
    If mx > 217 And mx < 269 And my > 226 And my < 355 Then PlayNote "a"
    If mx > 276 And mx < 329 And my > 226 And my < 304 Then PlayNote "b"
    If mx > 335 And mx < 382 And my > 226 And my < 355 Then PlayNote "c"
    If mx > 271 And mx < 328 And my > 402 And my < 545 Then PlayNote "d"
    If mx > 351 And mx < 432 And my > 407 And my < 510 Then PlayNote "e"
    If mx > 414 And mx < 507 And my > 346 And my < 424 Then PlayNote "f"
    If mx > 412 And mx < 523 And my > 265 And my < 321 Then PlayNote "g"
    If mx > 416 And mx < 493 And my > 175 And my < 242 Then PlayNote "h"
    If mx > 354 And mx < 420 And my > 111 And my < 182 Then PlayNote "i"
    If mx > 266 And mx < 334 And my > 70 And my < 184 Then PlayNote "j"
    If mx > 179 And mx < 244 And my > 113 And my < 182 Then PlayNote "k"
    If mx > 109 And mx < 182 And my > 174 And my < 240 Then PlayNote "l"
    If mx > 83 And mx < 184 And my > 265 And my < 320 Then PlayNote "m"
    If mx > 98 And mx < 185 And my > 345 And my < 414 Then PlayNote "n"
    If mx > 173 And mx < 245 And my > 405 And my < 508 Then PlayNote "o"
    done = 1
End If

GoSub NoteDisplay

Return

'===========
NoteDisplay:
'===========

If aflag = 1 Then
    If Timer - atimer > .5 Then
        aflag = 0: NotePut "img\a0.png", 215, 225
    End If
End If
If bflag = 1 Then
    If Timer - btimer > .5 Then
        bflag = 0: NotePut "img\b0.png", 275, 225
    End If
End If
If cflag = 1 Then
    If Timer - ctimer > .5 Then
        cflag = 0: NotePut "img\c0.png", 335, 225
    End If
End If
If dflag = 1 Then
    If Timer - dtimer > .5 Then
        dflag = 0: NotePut "img\d0.png", 271, 402
    End If
End If
If eflag = 1 Then
    If Timer - etimer > .5 Then
        eflag = 0: NotePut "img\e0.png", 351, 402
    End If
End If
If fflag = 1 Then
    If Timer - ftimer > .5 Then
        fflag = 0: NotePut "img\f0.png", 415, 338
    End If
End If
If gflag = 1 Then
    If Timer - gtimer > .5 Then
        gflag = 0: NotePut "img\g0.png", 414, 265
    End If
End If
If hflag = 1 Then
    If Timer - htimer > .5 Then
        hflag = 0: NotePut "img\h0.png", 416, 172
    End If
End If
If iflag = 1 Then
    If Timer - itimer > .5 Then
        iflag = 0: NotePut "img\i0.png", 354, 118
    End If
End If
If jflag = 1 Then
    If Timer - jtimer > .5 Then
        jflag = 0: NotePut "img\j0.png", 267, 94
    End If
End If
If kflag = 1 Then
    If Timer - ktimer > .5 Then
        kflag = 0: NotePut "img\k0.png", 184, 115
    End If
End If
If lflag = 1 Then
    If Timer - ltimer > .5 Then
        lflag = 0: NotePut "img\l0.png", 119, 170
    End If
End If
If mflag = 1 Then
    If Timer - mtimer > .5 Then
        mflag = 0: NotePut "img\m0.png", 109, 266
    End If
End If
If nflag = 1 Then
    If Timer - ntimer > .5 Then
        nflag = 0: NotePut "img\n0.png", 111, 333
    End If
End If
If oflag = 1 Then
    If Timer - otimer > .5 Then
        oflag = 0: NotePut "img\o0.png", 173, 404
    End If
End If

Return

Sub NotePut (file$, x&, y&)
    temp& = _LoadImage(file$, 32)
    _PutImage (x&, y&), temp&
    _FreeImage temp&
End Sub

Sub PlayNote (note$)
    'Plays note$, draws note$, sets flags and timers on
    If note$ = "a" Then
        _SndPlayCopy a&: aflag = 1: atimer = Timer
        NotePut "img\a1.png", 215, 225
    End If
    If note$ = "b" Then
        _SndPlayCopy b&: bflag = 1: btimer = Timer
        NotePut "img\b1.png", 275, 225
    End If
    If note$ = "c" Then
        _SndPlayCopy c&: cflag = 1: ctimer = Timer
        NotePut "img\c1.png", 335, 225
    End If
    If note$ = "d" Then
        _SndPlayCopy d&: dflag = 1: dtimer = Timer
        NotePut "img\d1.png", 271, 402
    End If
    If note$ = "e" Then
        _SndPlayCopy e&: eflag = 1: etimer = Timer
        NotePut "img\e1.png", 351, 402
    End If
    If note$ = "f" Then
        _SndPlayCopy f&: fflag = 1: ftimer = Timer
        NotePut "img\f1.png", 415, 338
    End If
    If note$ = "g" Then
        _SndPlayCopy g&: gflag = 1: gtimer = Timer
        NotePut "img\g1.png", 414, 265
    End If
    If note$ = "h" Then
        _SndPlayCopy h&: hflag = 1: htimer = Timer
        NotePut "img\h1.png", 416, 172
    End If
    If note$ = "i" Then
        _SndPlayCopy i&: iflag = 1: itimer = Timer
        NotePut "img\i1.png", 354, 118
    End If
    If note$ = "j" Then
        _SndPlayCopy j&: jflag = 1: jtimer = Timer
        NotePut "img\j1.png", 267, 94
    End If
    If note$ = "k" Then
        _SndPlayCopy k&: kflag = 1: ktimer = Timer
        NotePut "img\k1.png", 184, 115
    End If
    If note$ = "l" Then
        _SndPlayCopy l&: lflag = 1: ltimer = Timer
        NotePut "img\l1.png", 119, 170
    End If
    If note$ = "m" Then
        _SndPlayCopy m&: mflag = 1: mtimer = Timer
        NotePut "img\m1.png", 109, 266
    End If
    If note$ = "n" Then
        _SndPlayCopy n&: nflag = 1: ntimer = Timer
        NotePut "img\n1.png", 111, 333
    End If
    If note$ = "o" Then
        _SndPlayCopy o&: oflag = 1: otimer = Timer
        NotePut "img\o1.png", 173, 404
    End If
End Sub


Function FileSelect$ (y, x, y2, x2, Filespec$, fsborder&, fsback&, fsfile&, fsdir&, fshigh&)

    'EDITED VERSION OF FILESELECT$ ADAPTED FOR THIS PROGRAM

    '=== save original place of cursor
    origy = CsrLin
    origx = Pos(1)

    '=== save colors
    fg& = _DefaultColor
    bg& = _BackgroundColor

    '=== Save whole screen
    Dim scr1 As _MEM, scr2 As _MEM
    scr1 = _MemImage(0): scr2 = _MemNew(scr1.SIZE)
    _MemCopy scr1, scr1.OFFSET, scr1.SIZE To scr2, scr2.OFFSET

    '=== Generate a unique temp filename to use based on date + timer
    tmp$ = "_qb64_" + Date$ + "_" + LTrim$(Str$(Int(Timer))) + ".tmp"
    If InStr(_OS$, "LINUX") Then tmp$ = "/tmp/" + tmp$

    loadagain:

    top = 0
    selection = 0

    '=== make room for names
    ReDim FileNames$(10000) 'space for 10000 filenames

    '=== now grab list of files...
    If InStr(_OS$, "LINUX") Then
        If Filespec$ = "*.*" Then Filespec$ = ""
        Shell _Hide "find -maxdepth 1 -type f -name '" + Filespec$ + "*' > " + tmp$
    Else
        Shell _Hide "dir /b /A:-D " + Filespec$ + " > " + tmp$
    End If

    '=== open temp file
    FF = FreeFile
    Open tmp$ For Input As #FF

    While ((LineCount < UBound(FileNames$)) And (Not EOF(FF)))

        Line Input #FF, rl$

        '=== load, ignoring the generated temp file...
        If rl$ <> tmp$ Then

            'also remove the ./ added at the beginning when under linux
            If InStr(_OS$, "LINUX") Then
                If Left$(rl$, 2) = "./" Then
                    rl$ = Right$(rl$, Len(rl$) - 2)
                End If
            End If

            FileNames$(LineCount) = rl$
            LineCount = LineCount + 1
        End If

    Wend
    Close #FF

    '=== Remove the temp file created
    If InStr(_OS$, "LINUX") Then
        Shell _Hide "rm " + tmp$
    Else
        Shell _Hide "del " + tmp$
    End If


    '=== draw a box
    Color fsborder&
    For l = 0 To y2 + 1
        Locate y + l, x: Print String$(x2 + 4, Chr$(219));
    Next

    '=== show notice at top
    Color _RGB(255, 255, 128), fsborder&
    CurDir$ = _CWD$
    CurDir$ = Mid$(CurDir$, 1, x2 - x - 3) + "..."

    Locate y, x + 16: Print "SELECT A SONG";

    '=== scroll through list...
    Do

        For l = 0 To (y2 - 1)

            Locate (y + 1) + l, (x + 2)
            If l + top = selection Then
                Color fsback&, fshigh& 'selected line
            Else
                Color fsfile&, fsback& 'regular
                '=== directories get a different color...
                If Mid$(FileNames$(top + l), 1, 1) = "[" Then
                    Color fsdir&, fsback&
                End If
            End If

            Print Left$(FileNames$(top + l) + String$(x2, " "), x2);

        Next

        '=== Get user input

        k$ = InKey$
        Select Case k$

            Case Is = Chr$(0) + Chr$(72) 'Up arrow
                If selection > 0 Then selection = selection - 1
                If selection < top Then top = selection

            Case Is = Chr$(0) + Chr$(80) 'Down Arrow
                If selection < (LineCount - 1) Then selection = selection + 1
                If selection > (top + (y2 - 2)) Then top = selection - y2 + 1

            Case Is = Chr$(0) + Chr$(73) 'Page up
                top = top - y2
                selection = selection - y2
                If top < 0 Then top = 0
                If selection < 0 Then selection = 0

            Case Is = Chr$(0) + Chr$(81) 'Page Down
                top = top + y2
                selection = selection + y2
                If top >= LineCount - y2 Then top = LineCount - y2
                If top < 0 Then top = 0
                If selection >= LineCount Then selection = LineCount - 1

            Case Is = Chr$(0) + Chr$(71) 'Home
                top = 0: selection = 0

            Case Is = Chr$(0) + Chr$(79) 'End
                selection = LineCount - 1
                top = selection - y2 + 1
                If top < 0 Then top = 0

            Case Is = Chr$(27) ' ESC cancels
                FileSelect$ = ""
                Exit Do

            Case Is = Chr$(13) 'Enter

                If RTrim$(FileNames$(selection)) = "" Then
                    FileSelect$ = "": Exit Do
                End If

                If InStr(_OS$, "LINUX") Then
                    If Right$(_CWD$, 1) = "/" Then
                        C$ = _CWD$
                    Else
                        C$ = _CWD$ + "/"
                    End If
                Else
                    If Right$(_CWD$, 1) = "\" Then
                        C$ = _CWD$
                    Else
                        C$ = _CWD$ + "\"
                    End If
                End If

                FileSelect$ = C$ + RTrim$(FileNames$(selection))
                Exit Do

        End Select

    Loop

    _KeyClear

    '=== Restore the whole screen
    _MemCopy scr2, scr2.OFFSET, scr2.SIZE To scr1, scr1.OFFSET
    _MemFree scr1: _MemFree scr2

    '=== restore original y,x and color
    Locate origy, origx

    Color fg&, bg&

End Function


Sub DrawBox 'Draws the litte info box.  Used often
    Line (150, 200)-(450, 270), _RGB(70, 95, 114), BF
    Line (152, 202)-(448, 268), _RGB(255, 255, 255), B
    Color _RGB(255, 255, 255), _RGB(70, 95, 114)
End Sub

Function KINPUT$ (y, x, text$, limitnum)

    Locate y, x: Print text$;

    entry$ = ""
    y = CsrLin: x = Pos(1)

    Do
        a$ = Input$(1)

        If a$ = Chr$(13) Then 'enter returns entry
            KINPUT$ = entry$: Exit Function
        End If

        If a$ = Chr$(27) Then 'ESC bails out
            KINPUT$ = "": Exit Function
        End If

        If a$ = Chr$(8) Then 'Backspace goes back a space
            If Len(entry$) > 0 Then
                entry$ = Mid$(entry$, 1, Len(entry$) - 1)
            End If
        Else
            'add letter entered, if not over limitnum
            If Len(entry$) < limitnum Then
                entry$ = entry$ + a$
            End If
        End If

        Locate y, x: Print Space$(limitnum);
        Locate y, x: Print entry$;

    Loop

End Function


Function IBOX$ (text$, limitnum, fg&, bg&, delay)
    'This function either gets user input or shows info.
    'If limitnum is 0, it just shows info.

    'text$: Your text to show
    'limitnum: how many letters of input to get
    'fg&: The Text color
    'bg&: Background color of box
    'delay: optional delay period for message box only
    '       If set at -1 then wait for a keypress

    '=== save original place of cursor
    origy = CsrLin: origx = Pos(1)

    '=== Save whole screen
    Dim scr1 As _MEM, scr2 As _MEM
    scr1 = _MemImage(0): scr2 = _MemNew(scr1.SIZE)
    _MemCopy scr1, scr1.OFFSET, scr1.SIZE To scr2, scr2.OFFSET

    '=== find center x/y of screen
    y = Int(_Height / _FontHeight / 2)
    x = Int(_Width / _FontWidth / 2)

    tl = Len(text$) + limitnum 'total length of letter spacing used
    x = x - Int(tl / 2) 'recompute x based on text length

    Line (x * 8 - 24, y * 16 - 32)-((x * 8) + (tl * 8) + 8, y * 16 + 16), bg&, BF
    Line (x * 8 - 24, y * 16 - 32)-((x * 8) + (tl * 8) + 8, y * 16 + 16), fg&, B
    Color fg&, bg&

    Locate y, x: Print text$;
    y = CsrLin: x = Pos(1)

    If limitnum = 0 Then
        If delay = -1 Then
            a$ = Input$(1)
        Else
            _Delay delay
        End If
        IBOX$ = ""
    Else

        entry$ = ""

        Do
            a$ = Input$(1)

            '=== Return exits with data
            If a$ = Chr$(13) Then IBOX$ = entry$: Exit Do
            '=== Handle the backspace
            If a$ = Chr$(27) Then IBOX$ = "": Exit Do
            '=== ESC cancels
            If a$ = Chr$(8) Then 'Backspace goes back a space
                If Len(entry$) > 0 Then
                    entry$ = Mid$(entry$, 1, Len(entry$) - 1)
                End If
            Else
                'add letter entered, if not over limitnum
                If Len(entry$) < limitnum Then
                    entry$ = entry$ + a$
                End If
            End If

            Locate y, x: Print Space$(limitnum);
            Locate y, x: Print entry$;

        Loop

    End If

    '=== Restore the whole screen
    _MemCopy scr2, scr2.OFFSET, scr2.SIZE To scr1, scr1.OFFSET
    _MemFree scr1: _MemFree scr2

    '=== restore original y,x
    Locate origy, origx

End Function


