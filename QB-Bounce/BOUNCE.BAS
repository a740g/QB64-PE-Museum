'This is my favorite of all the games I have made.
'Since I have a slow computer, you may experience speed problems.
'  If so, change the "slower" variable below to a larger number.
'     Ex.  slower = 100   slower = 1000
'Right mouse button pauses.

'This program was made on a 433 Mhz, Pentium Celeron, 32 MB RAM computer.

'Required Files:
'BOUNCE.BAS, BTITLE.PAL, BTITLE1.BSV, BTITLE2.BSV, BTITLE3.BSV, BTITLE4.BSV
'FSINTRO.BSV, SOUNDS.SFX, TEXT.BSV

$Resize:Smooth

_FullScreen _SquarePixels , _Smooth

Start:
Common Shared score, level%, fade%, fadespeed%
Common Shared TEXT%(), pltt%()
Common Shared mx%, my%, mse%, speed%

slower = 0

Dim Shared c$(8)
DefInt E-R, T-Z
Cls
Color 15
Print "QB-Bounce  Version 1.0"
Print "Future Software"
Color 7
Locate 10, 1
Print "Special Thanks to:"
Print
Print "  Tim Truman for mouse capabilities."
Print "    (SWFXV1's TARGETS.BAS)"
Print
Print "  Brian Hogan's PROBE where I learned the OUT commands "
Print "    for changing the palette colors."
Print
Print "  QBASIC.COM which is where I got some good programs that"
Print "    I learned a lot of cool programming techniques from."

Randomize Timer
Close

Color 23: Locate 5, 1: Print "Initializing Mouse."
Dim Shared Mcode%(0 To 56)
Def Seg = VarSeg(Mcode%(0))
offset% = VarPtr(Mcode%(0))
Restore Mouser
For i% = 0 To 56
    Read byte%
    Poke offset% + i%, byte%
Next
Mouse 0
mx% = 320: my% = 200
Mouse 4
Color 7: Locate 5, 1: Print "Initializing Mouse."

Color 23: Locate 6, 1: Print "Setting Arrays."
Dim TEXT%(2620)
Dim frequency%(25)
Dim octave%(25)
Dim connection%(25)
Dim channel%(25)
Dim feedback%(25)
Dim multiply1%(25)
Dim wave1%(25)
Dim vibrato1%(25)
Dim attack1%(25)
Dim decay1%(25)
Dim sustain1%(25)
Dim release1%(25)
Dim tremolo1%(25)
Dim atten1%(25)
Dim multiply2%(25)
Dim wave2%(25)
Dim vibrato2%(25)
Dim attack2%(25)
Dim decay2%(25)
Dim sustain2%(25)
Dim release2%(25)
Dim tremolo2%(25)
Dim atten2%(25)
Dim fcls%(10)
Dim pltt%(50)
Dim hits%(9)
Dim px%(9), py%(9)
Color 7: Locate 6, 1: Print "Setting Arrays."

Color 23: Locate 7, 1: Print "Loading Sound Effects."
c$(0) = "&hB0&h20&h23&h40&h43&h60&h63&h80&h83&hA0&HBD&HC0&HE0&HE3&hB0"
c$(1) = "&hB1&h21&h24&h41&h44&h61&h64&h81&h84&hA1&HBD&HC1&HE1&HE4&hB1"
c$(2) = "&hB2&h22&h25&h42&h45&h62&h65&h82&h85&hA2&HBD&HC2&HE2&HE5&hB2"
c$(3) = "&hB3&h28&h2B&h48&h4B&h68&h6B&h88&h8B&hA3&HBD&HC3&HE8&HEB&hB3"
c$(4) = "&hB4&h29&h2C&h49&h4C&h69&h6C&h89&h8C&hA4&HBD&HC4&HE9&HEC&hB4"
c$(5) = "&hB5&h2A&h2D&h4A&h4D&h6A&h6D&h8A&h8D&hA5&HBD&HC5&HEA&HED&hB5"
c$(6) = "&hB6&h30&h33&h50&h53&h70&h73&h90&h93&hA6&HBD&HC6&HF0&HF3&hB6"
c$(7) = "&hB7&h31&h34&h51&h54&h71&h74&h91&h94&hA7&HBD&HC7&HF1&HF4&hB7"
c$(8) = "&hB8&h32&h35&h52&h55&h72&h75&h92&h95&hA8&HBD&HC8&HF2&HF5&hB8"
Close
file$ = "sounds.sfx"
Open file$ For Input As #1
effect% = 0
Do
    Input #1, frequency%(effect%)
    Input #1, octave%(effect%)
    Input #1, connection%(effect%)
    Input #1, channel%(effect%)
    Input #1, feedback%(effect%)
    Input #1, multiply1%(effect%)
    Input #1, wave1%(effect%)
    Input #1, vibrato1%(effect%)
    Input #1, attack1%(effect%)
    Input #1, decay1%(effect%)
    Input #1, sustain1%(effect%)
    Input #1, release1%(effect%)
    Input #1, tremolo1%(effect%)
    Input #1, atten1%(effect%)
    Input #1, multiply2%(effect%)
    Input #1, wave2%(effect%)
    Input #1, vibrato2%(effect%)
    Input #1, attack2%(effect%)
    Input #1, decay2%(effect%)
    Input #1, sustain2%(effect%)
    Input #1, release2%(effect%)
    Input #1, tremolo2%(effect%)
    Input #1, atten2%(effect%)
    effect% = effect% + 1
Loop While effect% < 25
Close
Color 7: Locate 7, 1: Print "Loading Sound Effects."

Color 23: Locate 8, 1: Print "Loading Text."
Def Seg = VarSeg(TEXT%(0))
BLoad "text.bsv", 0
Def Seg
Color 7: Locate 8, 1: Print "Loading Text."

Close
Open "bounce.dat" For Append As #1
Write #1, Date$, Time$
Close

Intro

Restart:
Cls: Screen 13
LoadScreen4 "btitle", 2
Randomize Timer
Do
    ink$ = InKey$
Loop While ink$ = ""
FadeOut2 5
Cls
Colors 15, 63, 63, 63
If ink$ = Chr$(27) Then End
'Menu

rot% = 0
addblocks% = 0
bc% = 0: comp% = 0
Paint (320, 240), bc%
score = 0: level% = 1: lives% = 4
stx% = 5: sty% = 53: blsz% = 35
mxx% = 639: mxy% = 220
sz1% = 28: sz2% = 7
div = 4
c1% = 14: c2% = 13
speed = 6: If comp% = 1 Then speed = 12
bonblk% = 0: bnx% = 0: bny% = 0
rotate% = 0

Do '*New*
    Randomize Timer
    Screen 13
    Cls: Screen 12
    'WINDOW (0, 0)-(639, 479)
    Colors 0, 0, 0, 0
    Colors 12, 42, 42, 42
    Colors 13, 63, 63, 63
    Colors 15, 63, 63, 63
    Colors 7, 50, 50, 0

    rndcolor% = 1
    dr% = Rnd
    If dr% = 0 Then
        If rndcolor% = 1 Then
            cool% = Rnd
            bright% = Rnd
            cool% = 1: bright% = 0
            n% = 1
            Do
                If cool% = 0 And bright% = 0 Then Colors n%, Rnd * 25 + 10, Rnd * 5 + 10, Rnd * 5 + 10
                If cool% = 1 And bright% = 0 Then Colors n%, 0, Rnd * 25 + 10, Rnd * 25 + 10
                If cool% = 0 And bright% = 1 Then Colors n%, Rnd * 33 + 30, Rnd * 15 + 10, Rnd * 15 + 10
                If cool% = 1 And bright% = 1 Then Colors n%, 0, Rnd * 43 + 20, Rnd * 43 + 20
                n% = n% + 1
            Loop While n% < 11
        End If
    End If

    c% = 0: n% = 0
    Do
        Out &H3C6, &HFF
        Out &H3C7, c%
        r% = Inp(&H3C9)
        g% = Inp(&H3C9)
        B% = Inp(&H3C9)
        pltt%(n%) = r%
        n% = n% + 1
        pltt%(n%) = g%
        n% = n% + 1
        pltt%(n%) = B%
        n% = n% + 1
        c% = c% + 1
    Loop While c% < 16

    Display

    'DO '*Old*
    x% = stx%: y% = sty%: s% = blsz% - 1
    x2% = x%: n% = 0: numb% = 0
    Do
        Line (x%, y%)-(x% + s%, y% + s%), 12, B
        Line (x% + 1, y% + 1)-(x% + s%, y% + s%), 0, B
        PSet (x% + s%, y%), 0: PSet (x%, y% + s%), 0
        BadColor:
        c% = Rnd * 9 + 1
        mdx% = x% + blsz% / 2: mdy% = y% + blsz% / 2
        If Point(mdx% - blsz%, mdy% - blsz%) = c% Then GoTo BadColor
        If Point(mdx% + blsz%, mdy% - blsz%) = c% Then GoTo BadColor
        If Point(mdx% - blsz%, mdy% + blsz%) = c% Then GoTo BadColor
        If Point(mdx% + blsz%, mdy% + blsz%) = c% Then GoTo BadColor
        If Point(mdx% - blsz%, mdy%) = c% Then GoTo BadColor
        If Point(mdx% + blsz%, mdy%) = c% Then GoTo BadColor
        If Point(mdx%, mdy% - blsz%) = c% Then GoTo BadColor
        If Point(mdx%, mdy% + blsz%) = c% Then GoTo BadColor
        Line (x% + 1, y% + 1)-(x% + s% - 1, y% + s% - 1), c%, BF
        numb% = numb% + 1
        x% = x% + s% + 1
        If x% > mxx% - s% Then x% = x2%: y% = y% + s% + 1
    Loop While y% < mxy%

    mx2% = 320: my2% = 440
    bx2 = 320: by2 = 440
    bx = 320: by = 440
    dx% = Rnd: If dx% = 0 Then dx% = -1
    dx = Rnd * 2 * dx%
    dy = speed * -1
    atim = numb% * 2
    '1,47,638,478
    minx% = 1: miny% = 47: maxx% = 638: maxy% = 478

    DoText 10, 10, "SCORE"
    DoText 10, 25, Str$(score)
    DoText 110, 10, "LEVEL"
    DoText 110, 25, Str$(level%)
    DoText 210, 10, "LIVES"
    DoText 210, 25, Str$(lives%)
    DoText 310, 10, "TIMER"
    DoText 310, 25, Str$(atim)
    DoText 410, 10, "BLOCKS LEFT"
    DoText 410, 25, Str$(numb%)

    DoText2 250, "LEVEL" + Str$(level%)
    If level% > 1 Then DoText2 280, "YOUR SCORE IS" + Str$(score)
    DoText2 300, "YOU HAVE" + Str$(lives%) + " LIVES"
    DoText2 320, "YOU HAVE" + Str$(atim) + " SECONDS TO COMPLETE THIS LEVEL"
    DoText2 350, "PRESS LEFT MOUSE BUTTON TO START"
 
    Do
        Mouse 3
    Loop While Not mse% = 1
    Line (50, 250)-(590, 375), 0, BF

    stime = Timer
    Do
        If rot% = 1 Then
            If yd% = 0 Then yn% = yn% - 1: If yn% < 0 Then yn% = 0: yd% = 1
            If yd% = 1 Then yn% = yn% + 1: If yn% > 63 Then yn% = 63: yd% = 0
            Colors 14, yn%, yn%, 0
        End If
        If comp% = 0 Then Mouse 3
        If mse% = 2 Then
            sptme = Timer
            Do
                Mouse 3
            Loop While mse% = 2
            Do
                Mouse 3
            Loop While Not mse% = 2
            Do
                Mouse 3
            Loop While mse% = 2
            stime = stime + (Timer - sptme)
        End If
        If comp% = 1 Then
            If dy > 0 And search% = 0 Then
                srchx% = Rnd * mxx%
                srchy% = Rnd * mxy%
                x% = stx%: n% = 0
                Do
                    If srchx% > x% And srchx% < x% + blsz% Then n% = 1
                    If n% = 0 Then x% = x% + blsz%
                Loop While n% = 0 And x% < 640
                y% = sty%: n% = 0
                Do
                    If srchy% > y% And srchy% < y% + blsz% Then n% = 1
                    If n% = 0 Then y% = y% + blsz%
                Loop While n% = 0 And y% < 480
                srchx% = x% + blsz% / 2: srchy% = y% + blsz% / 2
                srchc% = Point(srchx%, srchy%)
                If srchc% > 0 And srchc% < 15 Then search% = 1
            End If
 
            If dx = dx2 Then
            Else
                loops% = ((459 - by) / dy)
                ahx = bx + (dx * loops%)
                amv% = Rnd: If amv% = 0 Then amv% = -1
                ahx = ahx + Rnd * (sz1% / 2) * amv%
                ahy = 459
                move% = 1
            End If
            If dy > 0 And dy2 < 0 Then
                loops% = ((459 - by) / dy)
                ahx = bx + (dx * loops%)
                amv% = Rnd: If amv% = 0 Then amv% = -1
                'dx = (bx - mx%) / div
                ahx = ahx + Rnd * (sz1% / 2) * amv%
                'IF search% = 1 THEN
                ' ndx = (srchx% - bx) / (srchy% - by)
                ' PRINT ndx
                ' ahx = ahx + ndx * div
                'END IF
                search% = 0
                ahy = 459
                move% = 1
            End If
            dx2 = dx
            dy2 = dy
            If dy < 0 Then move% = 0
            If move% = 1 Then
                mx% = mx% + (ahx - mx%) / 5 'loops%
            End If
        End If
        If mx% < sz1% + 1 Then mx% = sz1% + 1
        If mx% > 638 - sz1% Then mx% = 638 - sz1%
        If my% < 47 + sz1% Then my% = 47 + sz1%
        If my% > 478 - sz1% Then my% = 478 - sz1%
        Line (mx2% - sz1%, 457)-(mx2% + sz1%, 461), bc%, BF '''
        Line (mx% - sz1%, 457)-(mx% + sz1%, 461), c1%, BF '''
        If my% < 47 + sz1% Then my% = 47 + sz1%
        If my% > 478 - sz1% Then my% = 478 - sz1%
        mx2% = mx%: my2% = my%

        bx2 = bx: by2 = by

        bx = bx + dx: by = by + dy
        If bx < sz2% + minx% Then bx = sz2% + minx%: dx = dx * -1: effect% = 2: GoSub Player
        If bx > maxx% - sz2% Then bx = maxx% - sz2%: dx = dx * -1: effect% = 2: GoSub Player
        If by < miny% + sz2% Then by = miny% + sz2%: dy = dy * -1: effect% = 2: GoSub Player
        If by > maxy% - sz2% Then
            by = maxy% - sz2%: dy = dy * -1: effect% = 2: GoSub Player
            lives% = lives% - 1
            az2 = sz2%
            Do
                Circle (bx2, by2), az2, bc%
                Paint (bx2, by2), bc%
                az2 = az2 - .5
                Circle (bx2, by2), az2, c2%
                Paint (bx2, by2), c2%
                Wait 986, 8
            Loop While az2 > 0
            PSet (bx2, by2), bc%
            bx = 320: by = 420: dx = 0: dy = -1 * speed
            If lives% > -1 Then
                az2 = 0
                Do
                    Circle (bx, by), az2, bc%
                    Paint (bx, by), bc%
                    az2 = az2 + .5
                    Circle (bx, by), az2, c2%
                    Paint (bx, by), c2%
                    Wait 986, 8
                Loop While az2 < sz2%
            End If
            If lives% < 0 Then FadeOut 1: Cls: GameOver: GoTo Restart
        End If
        If Abs(bx - mx%) < (sz1% + sz2%) And by > 450 And by < 470 Then dy = dy * -1: dx = (bx - mx%) / div: effect% = 2: GoSub Player

        p1% = Point(bx, by - sz2% - 4)
        p2% = Point(bx - sz2% - 4, by)
        p3% = Point(bx + sz2% + 4, by)
        p4% = Point(bx, by + sz2% + 4)
        p5% = Point(bx - sz2% - 2, by - sz2% - 2)
        p6% = Point(bx + sz2% + 2, by - sz2% - 2)
        p7% = Point(bx - sz2% - 2, by + sz2% + 2)
        p8% = Point(bx + sz2% + 2, by + sz2% + 2)
        p9% = Point(bx, by)
        hits%(0) = p1%: hits%(1) = p2%: hits%(2) = p3%: hits%(3) = p4%: hits%(4) = p5%
        hits%(5) = p6%: hits%(6) = p7%: hits%(7) = p8%: hits%(8) = p9%

        nn% = 1
        Do
            n% = 0
            Do
                If hits%(nn%) = hits%(n%) Then hits%(nn%) = 0
                n% = n% + 1
            Loop While n% < nn%
            nn% = nn% + 1
        Loop While nn% < 9

        hit% = 0: dxc% = 0: dyc% = 0
        If hits%(0) > 0 And hits%(0) < 12 Then dyc% = 1: hit% = 1: px%(0) = bx: py%(0) = by - sz2% - 4
        If hits%(1) > 0 And hits%(1) < 12 Then dxc% = 1: hit% = 1: px%(1) = bx - sz2% - 4: py%(1) = by
        If hits%(2) > 0 And hits%(2) < 12 Then dxc% = 1: hit% = 1: px%(2) = bx + sz2% + 4: py%(2) = by
        If hits%(3) > 0 And hits%(3) < 12 Then dyc% = 1: hit% = 1: px%(3) = bx: py%(3) = by + sz2% + 4
        If hits%(4) > 0 And hits%(4) < 12 Then dxc% = 1: dyc% = 1: hit% = 1: px%(4) = bx - sz2% - 2: py%(4) = by - sz2% - 2
        If hits%(5) > 0 And hits%(5) < 12 Then dxc% = 1: dyc% = 1: hit% = 1: px%(5) = bx + sz2% + 2: py%(5) = by - sz2% - 2
        If hits%(6) > 0 And hits%(6) < 12 Then dxc% = 1: dyc% = 1: hit% = 1: px%(6) = bx - sz2% - 2: py%(6) = by + sz2% + 2
        If hits%(7) > 0 And hits%(7) < 12 Then dxc% = 1: dyc% = 1: hit% = 1: px%(7) = bx + sz2% + 2: py%(7) = by + sz2% + 2
        If hits%(8) > 0 And hits%(8) < 12 Then dxc% = 1: dyc% = 1: hit% = 1: px%(8) = bx: py%(8) = by

        If hit% > 0 Then
            Circle (bx2, by2), sz2%, bc%
            Paint (bx2, by2), bc%
            Circle (bx, by), sz2%, c2%
            Paint (bx, by), c2%
            If dxc% = 1 Then dx = dx * -1
            If dyc% = 1 Then dy = dy * -1
            effect% = 8: GoSub Player
            sn% = 0
            Do
                If hits%(sn%) > 0 And hits%(sn%) < 12 Then
                    x% = stx%: n% = 0
                    Do
                        If px%(sn%) > x% And px%(sn%) < x% + blsz% Then n% = 1
                        If n% = 0 Then x% = x% + blsz%
                    Loop While n% = 0 And x% < 640
                    y% = sty%: n% = 0
                    Do
                        If py%(sn%) > y% And py%(sn%) < y% + blsz% Then n% = 1
                        If n% = 0 Then y% = y% + blsz%
                    Loop While n% = 0 And y% < 480
   
                    blc% = Point(px%(sn%), py%(sn%))
                    If blc% > 0 And blc% < 12 Then
                        Line (x%, y%)-(x% + blsz% - 1, y% + blsz% - 1), 0, BF
                        numb% = numb% - 1
                        If blc% = 11 Then blc% = 100: bnx% = 0: bny% = 0: bonblk% = 0
                        score = score + (blc% * 10)
                    End If
                End If
                sn% = sn% + 1
            Loop While sn% < 9
 
            bx2 = bx: by2 = by
            bx = bx + dx: by = by + dy
            If bx < sz2% + minx% Then bx = sz2% + minx%: dx = dx * -1: effect% = 2: GoSub Player
            If bx > maxx% - sz2% Then bx = maxx% - sz2%: dx = dx * -1: effect% = 2: GoSub Player
            If by < miny% + sz2% Then by = miny% + sz2%: dy = dy * -1: effect% = 2: GoSub Player
            If by > maxy% - sz2% Then by = maxy% - sz2%: dy = dy * -1: effect% = 2: GoSub Player: lives% = lives% - 1
            If Abs(bx - mx%) < (sz1% + sz2%) And by > 450 And by < 470 Then dy = dy * -1: dx = (bx - mx%) / div: effect% = 2: GoSub Player

        End If
 
        fx% = 0: fy% = 30: fcl% = 0
        Do
            'LINE (fx%, fy%)-(fx% + 9, fy% + 5), fcl%, BF
            fx% = fx% + 10
            fcl% = fcl% + 1
        Loop While fcl% < 16

        If rotate% = 1 Then
            fct% = fct% + 1
            If fct% = 3 Then fct% = 1
            If dr% = 0 And fct% = 1 Then
                If cool% = 1 And bright% = 0 Then
                    fcl% = 1
                    Do
                        Out &H3C6, &HFF
                        Out &H3C7, fcl%
                        fr% = Inp(&H3C9)
                        fg% = Inp(&H3C9)
                        fb% = Inp(&H3C9)
                        If fcls%(fcl%) = 0 Then
                            fg% = fg% + 1: fb% = fb% + 1: If fg% > 40 Or fb% > 40 Then fcls%(fcl%) = 1
                            Colors fcl%, fr%, fg%, fb%
                        End If
                        If fcls%(fcl%) = 1 Then
                            fg% = fg% - 1: fb% = fb% - 1: If fg% < 10 Or fb% < 10 Then fcls%(fcl%) = 0
                            Colors fcl%, fr%, fg%, fb%
                        End If
                        fcl% = fcl% + 1
                    Loop While fcl% < 11

                End If
            End If
        End If

        If bnx% = 0 And bny% = 0 And numb% > 0 Then
            Randomize Timer
            bnx% = Rnd * mxx%: bny% = Rnd * mxy%
            dur% = Rnd * 10 + 5: btime = Timer
            x% = stx%: n% = 0
            Do
                If bnx% > x% And bnx% < x% + blsz% Then n% = 1
                If n% = 0 Then x% = x% + blsz%
            Loop While n% = 0 And x% < 640
            y% = sty%: n% = 0
            Do
                If bny% > y% And bny% < y% + blsz% Then n% = 1
                If n% = 0 Then y% = y% + blsz%
            Loop While n% = 0 And y% < 480
            bnx% = x%: bny% = y%
            prc% = Point(bnx% + 3, bny% + 3)
            If prc% > 0 And prc% < 12 Then Else bnx% = 0: bny% = 0: GoTo BadBonus
            Line (bnx%, bny%)-(bnx% + blsz% - 1, bny% + blsz% - 1), 12, B
            Line (bnx% + 1, bny% + 1)-(bnx% + blsz% - 1, bny% + blsz% - 1), 0, B
            PSet (bnx% + blsz% - 1, bny%), 0: PSet (bnx% - 1, bny% + blsz% - 1), 0
            Line (bnx% + 1, bny% + 1)-(bnx% + blsz% - 2, bny% + blsz% - 2), 11, BF
            ct% = Rnd * 5
            bonblk% = 1
        End If
        BadBonus:
        If bonblk% = 1 Then
            If bn% = 1 Then bnn% = bnn% + 1 Else bnn% = bnn% - 1
            If bnn% > 63 Then bnn% = 63: bn% = 0
            If bnn% < 20 Then bnn% = 20: bn% = 1: ct% = Rnd * 5
            If ct% = 0 Then Colors 11, bnn%, 0, 0
            If ct% = 1 Then Colors 11, 0, bnn%, 0
            If ct% = 2 Then Colors 11, 0, 0, bnn%
            If ct% = 3 Then Colors 11, 0, bnn%, bnn%
            If ct% = 4 Then Colors 11, bnn%, 0, bnn%
            If ct% = 5 Then Colors 11, bnn%, bnn%, 0
            If Timer - btime > dur% Then
                Line (bnx%, bny%)-(bnx% + blsz% - 1, bny% + blsz% - 1), 12, B
                Line (bnx% + 1, bny% + 1)-(bnx% + blsz% - 1, bny% + blsz% - 1), 0, B
                PSet (bnx% + blsz% - 1, bny%), 0: PSet (bnx% - 1, bny% + blsz% - 1), 0
                Line (bnx% + 1, bny% + 1)-(bnx% + blsz% - 2, bny% + blsz% - 2), prc%, BF
                bnx% = 0: bny% = 0
                bonblk% = 0
            End If
        End If
        For slo = 1 To slower: Next slo
        Wait 986, 8
        Circle (bx2, by2), sz2%, bc%
        Paint (bx2, by2), bc%
        Circle (bx, by), sz2%, c2%
        Paint (bx, by), c2%
        bx2 = bx: by2 = by

        If addblocks% = 1 Then
            addb% = Rnd * 120
            If addb% = 120 Then GoSub AddBlock
        End If

        If score = score2 Then
        Else
            'LINE (6, 20)-(99, 35), 0, BF
            DoText 10, 25, Str$(score)
        End If
        If level% = level2% Then
        Else
            'LINE (106, 20)-(199, 35), 0, BF
            DoText 110, 25, Str$(level%)
        End If
        If lives% = lives2% Then
        Else
            'LINE (206, 20)-(299, 35), 0, BF
            DoText 210, 25, Str$(lives%)
        End If
        If atim = tim2% Then
        Else
            'LINE (306, 20)-(399, 35), 0, BF
            DoText 310, 25, Str$(atim)
        End If
        If numb% = numb2% Then
        Else
            'LINE (406, 20)-(499, 35), 0, BF
            DoText 410, 25, Str$(numb%)
        End If

        score2 = score
        level2% = level%
        lives2% = lives%
        tim2% = atim
        numb2% = numb%
        If Timer - stime > 1 Then stime = stime + 1: atim = atim - 1

        ink$ = InKey$
        If ink$ = Chr$(27) Then FadeOut 1: Cls: Colors 15, 63, 63, 63: End
        If ink$ = "~" Then bnx% = 0: bny% = 0: bonblk% = 0: atim = 0: numb% = 0: Line (minx%, miny%)-(maxx%, maxy%), 0, BF

        _Limit 30
    Loop While numb% > 0
    Circle (bx2, by2), sz2%, bc%
    Line (mx2% - sz1%, 457)-(mx2% + sz1%, 461), bc%, B
    level% = level% + 1
    blsz% = blsz% - 5
    If blsz% < 20 Then blsz% = 30: speed = speed + 2: div = div / 2: If div < .5 Then div = .5

    bonus = 0
    If atim > 0 Then bonus = atim * 100
    score = score + bonus
    DoText2 240, "BONUS" + Str$(bonus) + " POINTS"
    Delay 2.5

    If rndcolor% = 1 Then
        n% = 1
        Do
            Colors n%, Rnd * 63, Rnd * 63, Rnd * 63
            n% = n% + 1
        Loop While n% < 11
        c% = 0: n% = 0
        Do
            Out &H3C6, &HFF
            Out &H3C7, c%
            r% = Inp(&H3C9)
            g% = Inp(&H3C9)
            B% = Inp(&H3C9)
            pltt%(n%) = r%
            n% = n% + 1
            pltt%(n%) = g%
            n% = n% + 1
            pltt%(n%) = B%
            n% = n% + 1
            c% = c% + 1
        Loop While c% < 16
    End If

    FadeOut 1
Loop

Player:
GoSub Getter
If w1% = 0 Then w1$ = "0"
If w1% = 1 Then w1$ = "1"
If w1% = 2 Then w1$ = "2"
If w1% = 3 Then w1$ = "3"
If w2% = 0 Then w2$ = "0"
If w2% = 1 Then w2$ = "1"
If w2% = 2 Then w2$ = "2"
If w2% = 3 Then w2$ = "3"
c$ = Str$(ch%)
If c% = 0 And o% = 0 Then aaa$ = "21"
If c% = 0 And o% = 1 Then aaa$ = " 24"
If c% = 0 And o% = 2 Then aaa$ = "2A"
If c% = 0 And o% = 3 Then aaa$ = "2F"
If c% = 0 And o% = 4 Then aaa$ = "30"
If c% = 0 And o% = 5 Then aaa$ = "37"
If c% = 0 And o% = 6 Then aaa$ = "3B"
If c% = 0 And o% = 7 Then aaa$ = "3F"
If c% = 1 And o% = 0 Then aaa$ = "33"
If c% = 1 And o% = 1 Then aaa$ = "24"
If c% = 1 And o% = 2 Then aaa$ = "33"
If c% = 1 And o% = 3 Then aaa$ = "2E"
If c% = 1 And o% = 4 Then aaa$ = "33"
If c% = 1 And o% = 5 Then aaa$ = "33"
If c% = 1 And o% = 6 Then aaa$ = "39"
If c% = 1 And o% = 7 Then aaa$ = "33"
sfx$ = "&H00&H" + Hex$(v1%) + Hex$(m1%) + "&H" + Hex$(v2%) + Hex$(m2%)
sfx$ = sfx$ + "&H0" + Hex$(at1%) + "&H0" + Hex$(at2%) + "&H" + Hex$(a1%)
sfx$ = sfx$ + Hex$(d1%) + "&H" + Hex$(a2%) + Hex$(d2%) + "&H" + Hex$(s1%)
sfx$ = sfx$ + Hex$(r1%) + "&H" + Hex$(s2%) + Hex$(r2%) + "&H" + Hex$(f%)
sfx$ = sfx$ + "&HC0&H00&H0" + (w1$) + "&H0" + (w2$) + "&H" + aaa$ + "&H" + (c$)
chan% = effect%
'FOR in = 1 TO 60 STEP 4
in = 1
'DO
CS:
reg$ = Mid$(c$(chan%), in, 4): reg% = Val(reg$)
dat$ = Mid$(sfx$, in, 4): dat% = Val(dat$)
Out &H388, reg%: For d% = 1 To 6: B% = Inp(&H388): Next
Out &H389, dat%: For d% = 1 To 35: B% = Inp(&H388): Next
in = in + 4
If in < 61 Then GoTo CS
'LOOP WHILE in < 61
'NEXT
Return
Getter:
f% = frequency%(effect%)
o% = octave%(effect%)
c% = connection%(effect%)
ch% = channel%(effect%)
fe% = feedback%(effect%)
m1% = multiply1%(effect%)
w1% = wave1%(effect%)
v1% = vibrato1%(effect%)
a1% = attack1%(effect%)
d1% = decay1%(effect%)
s1% = sustain1%(effect%)
r1% = release1%(effect%)
t1% = tremolo1%(effect%)
at1% = atten1%(effect%)
m2% = multiply2%(effect%)
w2% = wave2%(effect%)
v2% = vibrato2%(effect%)
a2% = attack2%(effect%)
d2% = decay2%(effect%)
s2% = sustain2%(effect%)
r2% = release2%(effect%)
t2% = tremolo2%(effect%)
at2% = atten2%(effect%)
Return


Mouser:
Data &H55,&H89,&HE5,&H8B,&H5E,&H0C,&H8B,&H07,&H50,&H8B
Data &H5E,&H0A,&H8B,&H07,&H50,&H8B,&H5E,&H08,&H8B,&H0F
Data &H8B,&H5E,&H06,&H8B,&H17,&H5B,&H58,&H1E,&H07,&HCD
Data &H33,&H53,&H8B,&H5E,&H0C,&H89,&H07,&H58,&H8B,&H5E
Data &H0A,&H89,&H07,&H8B,&H5E,&H08,&H89,&H0F,&H8B,&H5E
Data &H06,&H89,&H17,&H5D,&HCA,&H08,&H00

AddBlock:
x% = stx%: y% = sty%
found% = 0
Do
    spacecolor% = Point(x% + blsz% / 2, y% + blsz% / 2)
    If spacecolor% = 0 Then
        found% = 1
    End If
    If found% = 0 Then
        x% = x% + blsz%
        If x% > mxx% Then x% = stx%: y% = y% + blsz%
    End If
Loop While y% < mxy% And found% = 0
If found% = 1 Then
    s% = blsz% - 1
    Line (x%, y%)-(x% + s%, y% + s%), 12, B
    Line (x% + 1, y% + 1)-(x% + s%, y% + s%), 0, B
    PSet (x% + s%, y%), 0: PSet (x%, y% + s%), 0
    BadColor3:
    c% = Rnd * 9 + 1
    mdx% = x% + blsz% / 2: mdy% = y% + blsz% / 2
    If Point(mdx% - blsz%, mdy% - blsz%) = c% Then GoTo BadColor3
    If Point(mdx% + blsz%, mdy% - blsz%) = c% Then GoTo BadColor3
    If Point(mdx% - blsz%, mdy% + blsz%) = c% Then GoTo BadColor3
    If Point(mdx% + blsz%, mdy% + blsz%) = c% Then GoTo BadColor3
    If Point(mdx% - blsz%, mdy%) = c% Then GoTo BadColor3
    If Point(mdx% + blsz%, mdy%) = c% Then GoTo BadColor3
    If Point(mdx%, mdy% - blsz%) = c% Then GoTo BadColor3
    If Point(mdx%, mdy% + blsz%) = c% Then GoTo BadColor3
    Line (x% + 1, y% + 1)-(x% + s% - 1, y% + s% - 1), c%, BF
    numb% = numb% + 1
End If
Return


Sub Background
    Cls: Screen 12
    Colors 0, 0, 0, 0
    Colors 12, 42, 42, 42
    Colors 13, 63, 63, 63
    Colors 15, 63, 63, 63
    Colors 7, 50, 50, 0
    blsz% = 35
    x% = -7: y% = -4
    mxx% = 645 + blsz%: mxy% = 485 + blsz%
    s% = blsz% - 1
    x2% = x%: n% = 0: numb% = 0
    Do
        Line (x%, y%)-(x% + s%, y% + s%), 12, B
        Line (x% + 1, y% + 1)-(x% + s%, y% + s%), 0, B
        PSet (x% + s%, y%), 0: PSet (x%, y% + s%), 0
        BadColor2:
        c% = Rnd * 9 + 1
        mdx% = x% + blsz% / 2: mdy% = y% + blsz% / 2
        If Point(mdx% - blsz%, mdy% - blsz%) = c% Then GoTo BadColor2
        If Point(mdx% + blsz%, mdy% - blsz%) = c% Then GoTo BadColor2
        If Point(mdx% - blsz%, mdy% + blsz%) = c% Then GoTo BadColor2
        If Point(mdx% + blsz%, mdy% + blsz%) = c% Then GoTo BadColor2
        If Point(mdx% - blsz%, mdy%) = c% Then GoTo BadColor2
        If Point(mdx% + blsz%, mdy%) = c% Then GoTo BadColor2
        If Point(mdx%, mdy% - blsz%) = c% Then GoTo BadColor2
        If Point(mdx%, mdy% + blsz%) = c% Then GoTo BadColor2
        Line (x% + 1, y% + 1)-(x% + s% - 1, y% + s% - 1), c%, BF
        numb% = numb% + 1
        x% = x% + s% + 1
        If x% > mxx% - s% Then x% = x2%: y% = y% + s% + 1
    Loop While y% < mxy%

End Sub

DefInt A-D, S
Sub Colors (c%, r%, g%, B%)
    Out &H3C8, c%
    Out &H3C9, r%
    Out &H3C9, g%
    Out &H3C9, B%
End Sub

DefSng O, S
Sub Delay (sat)
    satt = Timer
    Do
    Loop While Timer - satt < sat
End Sub

DefInt O, S
Sub Display
    FadeOut 3
    Cls: Screen 12
    Line (1, 1)-(638, 40), 13, B
    Line (0, 46)-(639, 479), 13, B

    Line (5, 5)-(100, 36), 12, B
    Line (105, 5)-(200, 36), 12, B
    Line (205, 5)-(300, 36), 12, B
    Line (305, 5)-(400, 36), 12, B
    Line (405, 5)-(500, 36), 12, B
    Line (505, 5)-(633, 36), 12, B
 
    DoText 510, 10, "    QB-BOUNCE"
    DoText 510, 25, " FUTURE SOFTWARE"

 
    Line (3, 3)-(102, 38), 12, B
    Line (103, 3)-(202, 38), 12, B
    Line (203, 3)-(302, 38), 12, B
    Line (303, 3)-(402, 38), 12, B
    Line (403, 3)-(502, 38), 12, B
    Line (503, 3)-(635, 38), 12, B

    'LINE (1, 1)-(638, 40), 8, B
    'LINE (4, 4)-(101, 37), 8, B
    'LINE (104, 4)-(201, 37), 8, B
    'LINE (204, 4)-(301, 37), 8, B
    'LINE (304, 4)-(401, 37), 8, B
    'LINE (404, 4)-(501, 37), 8, B
    FadeIn 1
End Sub

Sub DoText (StartX%, StartY%, TEXT$)
    If Len(TEXT$) = 0 Then Exit Sub
    Text2$ = TEXT$
    x% = StartX%
    y% = StartY%
    Do
        SendText$ = Left$(TEXT$, 1)
        TEXT$ = Right$(TEXT$, Len(TEXT$) - 1)
        PutText x%, y%, SendText$
        x% = x% + 7
    Loop While Len(TEXT$) > 0
    TEXT$ = Text2$
End Sub

Sub DoText2 (StartY%, TEXT$)
    Gap% = 7
    If Len(TEXT$) = 0 Then Exit Sub
    Text2$ = TEXT$
    x% = 320 - ((Len(TEXT$) * 7) / 2)
    y% = StartY%
    Do
        SendText$ = Left$(TEXT$, 1)
        TEXT$ = Right$(TEXT$, Len(TEXT$) - 1)
        PutText x%, y%, SendText$
        x% = x% + Gap%
    Loop While Len(TEXT$) > 0
    TEXT$ = Text2$
End Sub

Sub FadeIn (speed%)
    x% = -63
    Do
        done% = 1
        c% = 0: n% = 0
        Do
            mr% = pltt%(n%)
            n% = n% + 1
            mg% = pltt%(n%)
            n% = n% + 1
            mb% = pltt%(n%)
            n% = n% + 1
            rr% = mr% + x%
            gg% = mg% + x%
            bb% = mb% + x%
            If rr% < 0 Then rr% = 0
            If gg% < 0 Then gg% = 0
            If bb% < 0 Then bb% = 0
            If rr% > mr% Then rr% = mr%
            If gg% > mg% Then gg% = mg%
            If bb% > mb% Then bb% = mb%
            Colors c%, rr%, gg%, bb%
            If rr% = mr% And gg% = mg% And bb% = mb% Then Else done% = 0
            c% = c% + 1
        Loop While c% < 16
        x% = x% + speed%
        Wait 986, 8
    Loop While done% = 0
End Sub

Sub FadeIn2 (array%(), speed%)
    x% = -63
    Do
        done% = 1
        c% = 0: n% = 0
        Do
            mr% = array%(n%)
            n% = n% + 1
            mg% = array%(n%)
            n% = n% + 1
            mb% = array%(n%)
            n% = n% + 1
            rr% = mr% + x%
            gg% = mg% + x%
            bb% = mb% + x%
            If rr% < 0 Then rr% = 0
            If gg% < 0 Then gg% = 0
            If bb% < 0 Then bb% = 0
            If rr% > mr% Then rr% = mr%
            If gg% > mg% Then gg% = mg%
            If bb% > mb% Then bb% = mb%
            Colors c%, rr%, gg%, bb%
            If rr% = mr% And gg% = mg% And bb% = mb% Then Else done% = 0
            c% = c% + 1
        Loop While c% < 256
        x% = x% + speed%
        Wait 986, 8
    Loop While done% = 0
End Sub

Sub FadeOut (speed%)
    Do
        done% = 1
        c% = 0
        Do
            Out &H3C6, &HFF
            Out &H3C7, c%
            rr% = Inp(&H3C9)
            gg% = Inp(&H3C9)
            bb% = Inp(&H3C9)
            rr% = rr% - speed%
            gg% = gg% - speed%
            bb% = bb% - speed%
            If rr% < 0 Then rr% = 0
            If gg% < 0 Then gg% = 0
            If bb% < 0 Then bb% = 0
            Colors c%, rr%, gg%, bb%
            If rr% = 0 And gg% = 0 And bb% = 0 Then Else done% = 0
            c% = c% + 1
        Loop While c% < 16
        Wait 986, 8
    Loop While done% = 0
End Sub

Sub FadeOut2 (speed%)
    Do
        done% = 1
        c% = 0
        Do
            Out &H3C6, &HFF
            Out &H3C7, c%
            rr% = Inp(&H3C9)
            gg% = Inp(&H3C9)
            bb% = Inp(&H3C9)
            rr% = rr% - speed%
            gg% = gg% - speed%
            bb% = bb% - speed%
            If rr% < 0 Then rr% = 0
            If gg% < 0 Then gg% = 0
            If bb% < 0 Then bb% = 0
            Colors c%, rr%, gg%, bb%
            If rr% = 0 And gg% = 0 And bb% = 0 Then Else done% = 0
            c% = c% + 1
        Loop While c% < 256
        Wait 986, 8
    Loop While done% = 0
End Sub

DefSng S
Sub FlyText (sx%, sy%, mx%, my%, TEXT$)
    Dim x(100)
    Dim y(100)
    Dim tt$(100)

    maxn% = Len(TEXT$)

    n% = 0
    Do
        If m% = -1 Then m% = 1 Else m% = -1
        x(n%) = sx% * m%
        y(n%) = sy% * m%
        n% = n% + 1
    Loop While n% < maxn% + 1

    n% = 0
    nn% = maxn% + 1
    Do
        tt$(n%) = Mid$(TEXT$, nn%, 1)
        n% = n% + 1
        nn% = nn% - 1
    Loop While nn% > 0
    speed = 2
    Do
        'x2% = ABS(x(0))
        'y2% = ABS(y(0))

        x = mx%: y = my%
        x(0) = (x(0) - x) / speed
        x(0) = x(0) - 12
        y(0) = (y(0) - y) / speed
        n = 1
        moving% = 0
        Do
            Line (x(n) - 1, y(n) - 1)-(x(n) + 5, y(n) + 8), 0, BF
            xp% = x(n): yp% = y(n)
            x(n) = (x(n) - x(n - 1)) / speed
            x(n) = x(n) - 4 * n
            y(n) = (y(n) - y(n - 1)) / speed
            xn% = x(n): yn% = y(n)
            If xp% = xn% And yp% = yn% Then Else moving% = 1
            If x(n) > 12 And x(n) < 630 And y(n) > 0 And y(n) < 468 Then DoText x(n), y(n), tt$(n)
            'x2% = x(n): y2% = y(n)
            n = n + 1
        Loop While n < maxn%

        Wait 986, 8
    Loop While moving% = 1
End Sub

DefSng M-R
Sub FlyText2 (sx%, sy%, sx2%, sy2%, mx%, my%, TEXT$, mtime)
    Dim x(100)
    Dim y(100)
    Dim tt$(100)

    maxn% = Len(TEXT$)

    n% = 0
    Do
        If m% = -1 Then m% = 1 Else m% = -1
        x(n%) = sx% * m%
        y(n%) = sy% * m%
        n% = n% + 1
    Loop While n% < maxn% + 1

    n% = 0
    nn% = maxn% + 1
    Do
        tt$(n%) = Mid$(TEXT$, nn%, 1)
        n% = n% + 1
        nn% = nn% - 1
    Loop While nn% > 0
    stime = Timer
    speed = 2
    Do

        x = sx2%: y = sy2%
        x(0) = (x(0) - x) / speed
        x(0) = x(0) - 12
        y(0) = (y(0) - y) / speed
        n = 1
        moving% = 0
        Do
            Line (x(n) - 1, y(n) - 1)-(x(n) + 5, y(n) + 8), 0, BF
            xp% = x(n): yp% = y(n)
            x(n) = (x(n) - x(n - 1)) / speed
            x(n) = x(n) - 6 * n
            y(n) = (y(n) - y(n - 1)) / speed
            xn% = x(n): yn% = y(n)
            If xp% = xn% And yp% = yn% Then Else moving% = 1
            If x(n) > 12 And x(n) < 630 And y(n) > 0 And y(n) < 468 Then DoText x(n), y(n), tt$(n)
            n = n + 1
        Loop While n < maxn%
 
        Wait 986, 8
    Loop While Timer - stime < mtime

    Do

        x = mx%: y = my%
        x(0) = (x(0) - x) / speed
        x(0) = x(0) - 12
        y(0) = (y(0) - y) / speed
        n = 1
        moving% = 0
        Do
            Line (x(n) - 1, y(n) - 1)-(x(n) + 5, y(n) + 8), 0, BF
            xp% = x(n): yp% = y(n)
            x(n) = (x(n) - x(n - 1)) / speed
            x(n) = x(n) - 6 * n
            y(n) = (y(n) - y(n - 1)) / speed
            xn% = x(n): yn% = y(n)
            If xp% = xn% And yp% = yn% Then Else moving% = 1
            If x(n) > 12 And x(n) < 630 And y(n) > 0 And y(n) < 468 Then DoText x(n), y(n), tt$(n)
            n = n + 1
        Loop While n < maxn%
 
        Wait 986, 8
    Loop While moving% = 1


End Sub

DefInt M-R
DefSng A-D
Sub GameOver
    GoTo SkipThis
    Line (0, 0)-(639, 479), 1, B
    x% = 639: y% = 0: s% = 20
    Do
        Line (x%, 0)-(0, y%), 1
        x% = x% - s%
        y% = y% + s%
    Loop While x% > 0
    x% = 0: y% = 0
    Do
        Line (x%, 0)-(639, y%), 1
        x% = x% + s%
        y% = y% + s%
    Loop While x% < 639
    x% = 0: y% = 479
    Do
        Line (639, y%)-(x%, 479), 1
        x% = x% + s%
        y% = y% - s%
    Loop While x% < 639
    x% = 639: y% = 479
    Do
        Line (x%, 479)-(0, y%), 1
        x% = x% - s%
        y% = y% - s%
    Loop While x% > 0
    x% = 0: y% = 0
    Do
        Line (x%, 0)-(0, y%), 1
        x% = x% + s%
        y% = y% + s%
    Loop While x% < 639 * 2
    x% = 639: y% = 0
    Do
        Line (x%, 0)-(639, y%), 1
        x% = x% - s%
        y% = y% + s%
    Loop While x% > -639

    SkipThis:
    s% = 20: s2% = s% + 1
    c% = Rnd * 9 + 1
    x% = 185: y% = 100
    x2% = x%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    c% = Rnd * 9 + 1
    x% = x% + s2% * 4
    y% = y% + s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    x% = x% + s2%
    y% = y% - s2% * 2
    GoSub Block
    c% = Rnd * 9 + 1
    y% = y% - s2% * 2
    x% = x% + s2% * 3
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% - s2% * 3
    x% = x% + s2%
    GoSub Block
    y% = y% + s2%
    x% = x% + s2%
    GoSub Block
    y% = y% - s2%
    x% = x% + s2%
    GoSub Block
    y% = y% - s2%
    x% = x% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    c% = Rnd * 9 + 1
    x% = x% + s2% * 4
    y% = y% - s2% * 4
    GoSub Block
    x% = x% - s2%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    x% = x% - s2%
    y% = y% - s2% * 2
    GoSub Block
    x% = x2% + s2%
    y% = y% + s2% * 5
    GoSub Block
    x% = x% - s2%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    x% = x% + s2% * 2
    c% = Rnd * 9 + 1
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    x% = x% + s2%
    GoSub Block
    y% = y% - s2%
    x% = x% + s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    y% = y% - s2%
    GoSub Block
    x% = x% + s2% * 4
    c% = Rnd * 9 + 1
    GoSub Block
    x% = x% - s2%
    GoSub Block
    x% = x% - s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    x% = x% + s2%
    GoSub Block
    y% = y% - s2% * 2
    x% = x% - s2%
    GoSub Block
    y% = y% - s2% * 2
    x% = x% + s2% * 3
    c% = Rnd * 9 + 1
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    y% = y% - s2% * 4
    x% = x% + s2%
    GoSub Block
    x% = x% + s2%
    y% = y% + s2%
    GoSub Block
    x% = x% - s2%
    y% = y% + s2%
    GoSub Block
    y% = y% + s2%
    x% = x% + s2%
    GoSub Block
    y% = y% + s2%
    GoSub Block
    FadeIn 1
    Delay 4
    FadeOut 1
    Cls
    FadeIn 4
    'Info
    Exit Sub
    Block:
    Line (x%, y%)-(x% + s%, y% + s%), 12, B
    Line (x% + 1, y% + 1)-(x% + s%, y% + s%), 0, B
    PSet (x% + s%, y%), 0: PSet (x%, y% + s%), 0
    Line (x% + 1, y% + 1)-(x% + s% - 1, y% + s% - 1), c%, BF
    Return
End Sub

Sub Info
    Cls: Screen 12
    l% = 16: x% = 320 + ((l% - 4) * 7) / 2
    FlyText 800, 400, x%, 30, " G A M E   I N F O R M A T I O N"
    l% = 4: x% = 320 + ((l% - 4) * 7) / 2
    FlyText -160, 400, x%, 70, " S C O R E"
    l% = 4: x% = 320 + ((l% - 4) * 7) / 2
    FlyText 800, 400, x%, 110, " L E V E L"
    Line (320, 0)-(320, 480), 15
    Do
    Loop While InKey$ = ""
End Sub

DefInt A-D, S
Sub Intro
    RestartIntro:
    Cls: Screen 13
    n% = 1
    Do
        Colors n%, 0, 0, 0
        n% = n% + 1
    Loop While n% < 220
    Dim a%(2635)
    Def Seg = VarSeg(a%(0))
    BLoad "fsintro.bsv", 0
    Def Seg
    Put (20, 85), a%(), PSet
    Erase a%
    x% = 50
    Do
        x% = x% + 2
        c% = 1
        Do
            a% = Abs(c% - x%) / .45
            a% = 63 - a%
            If a% > 63 Then a% = 0
            If a% < 0 Then a% = 0
            Colors c%, a%, a%, a%
            c% = c% + 1
            If c% = 10 Or c% = 100 Or c% = 190 Then Wait 986, 8
        Loop While c% < 210
        Wait 986, 8
        ink$ = InKey$
    Loop While x% < 250
    Cls
    Colors 15, 63, 63, 63
    Exit Sub

    Dim a%(2635)
    Def Seg = VarSeg(a%(0))
    BLoad "fsintro2.bsv", 0
    Def Seg
    Put (20, 85), a%(), PSet
    Erase a%
    n% = 0
    Do
        Colors n% + 1, n% * 2, n% * 2, n% * 2
        n% = n% + 1
    Loop While n% < 31
    Randomize Timer
    Do
        x% = Rnd * 320
        y% = Rnd * 20 + 85
        c% = Point(x%, y%)
        If c% > 63 Then c% = 1
        If c% > 0 Then PSet (x%, y%), c% + 1
    Loop While Not InKey$ = " "
 
End Sub

Sub LoadPal (array%(), file$, now%)
    Def Seg = VarSeg(array%(0))
    BLoad file$, 0
    Def Seg
    If now% = 1 Then
        n% = 0
        c% = 0
        Do
            r% = array%(n%)
            n% = n% + 1
            g% = array%(n%)
            n% = n% + 1
            B% = array%(n%)
            n% = n% + 1
            Colors c%, r%, g%, B%
            c% = c% + 1
        Loop While c% < 256
    End If
End Sub

DefSng A-D, S
Sub LoadScreen4 (name$, reveal%)
    pfile$ = name$ + ".pal"
    file1$ = name$ + "1.bsv"
    file2$ = name$ + "2.bsv"
    file3$ = name$ + "3.bsv"
    file4$ = name$ + "4.bsv"
    n% = 0
    Do
        Colors n%, 0, 0, 0
        n% = n% + 1
    Loop While n% < 256
    Dim pal%(770)
    Dim a%(8800)
    Def Seg = VarSeg(a%(0))
    BLoad file1$, 0
    Def Seg
    Put (0, 0), a%(), PSet
    Def Seg = VarSeg(a%(0))
    BLoad file2$, 0
    Def Seg
    Put (160, 0), a%(), PSet
    Def Seg = VarSeg(a%(0))
    BLoad file3$, 0
    Def Seg
    Put (0, 100), a%(), PSet
    Def Seg = VarSeg(a%(0))
    BLoad file4$, 0
    Def Seg
    Put (160, 100), a%(), PSet
    If reveal% = 0 Then LoadPal pal%(), pfile$, 0
    If reveal% = 1 Then LoadPal pal%(), pfile$, 1
    If reveal% = 2 Then LoadPal pal%(), pfile$, 0: FadeIn2 pal%(), 5
    If reveal% = 3 Then LoadPal pal%(), pfile$, 0: FadeIn2 pal%(), fadespeed%
    Erase a%, pal%
End Sub

Sub Menu
    Background
    Line (50, 50)-(589, 429), 0, BF
    Line (50, 50)-(589, 429), 15, B
    Line (52, 52)-(587, 427), 15, B
    DoText2 75, "QB-BOUNCE"
    DoText2 90, "VERSION 1.0"
    Line (250, 105)-(390, 105), 15


    Mouse 1
    Do
        Mouse 3
    Loop While Not mse% = 1
End Sub

DefInt A-D
DefSng O
Sub Mouse (func%)
    Def Seg = VarSeg(Mcode%(0)) 'set array segment
    offset% = VarPtr(Mcode%(0)) 'get array address
    Select Case func%
        Case 0 'reset mouse driver
            ax% = 0: bx% = 0: cx% = 0: dx% = 0
            Call Absolute(ax%, bx%, cx%, dx%, offset%)
            If ax% = 0 Then
                ' PRINT "No mouse detected!"
                ' PRINT "Sorry, this program requires a mouse."
                ' END
            Else
                'PRINT "Mouse found"
            End If
        Case 1 'mouse cursor on
            ax% = 1: bx% = 0: cx% = 0: dx% = 0
            Call Absolute(ax%, bx%, cx%, dx%, offset%)
        Case 2 'mouse cursor off
            ax% = 2: bx% = 0: cx% = 0: dx% = 0
            Call Absolute(ax%, bx%, cx%, dx%, offset%)
        Case 3 'get mouse statsus
            ax% = 3: bx% = 0: cx% = 0: dx% = 0
            Call Absolute(ax%, bx%, cx%, dx%, offset%)
            mse% = bx%
            mx% = cx%
            my% = dx%
    End Select
    Def Seg
End Sub

DefInt O, S
Sub PutText (textx%, texty%, TEXT$)
    TEXT$ = UCase$(TEXT$)
    n% = Asc(TEXT$)
    If n% > 48 And n% < 58 Then n% = n% - 48 + 26: GoTo NextText
    If n% = 39 Then n% = 63: GoTo NextText
    If n% = 37 Then n% = 41: GoTo NextText
    If n% = 94 Then n% = 42: GoTo NextText
    If n% = 48 Then n% = 36: GoTo NextText
    If n% = 33 Then n% = 37: GoTo NextText
    If n% = 64 Then n% = 38: GoTo NextText
    If n% = 35 Then n% = 39: GoTo NextText
    If n% = 38 Then n% = 43: GoTo NextText
    If n% = 42 Then n% = 44: GoTo NextText
    If n% = 40 Then n% = 45: GoTo NextText
    If n% = 41 Then n% = 46: GoTo NextText
    If n% = 36 Then n% = 40: GoTo NextText
    If n% > 64 And n% < 91 Then n% = n% - 64: GoTo NextText
    If n% > 32 And n% < 42 Then n% = n%: GoTo NextText
    If n% = 45 Then n% = 47: GoTo NextText
    If n% = 43 Then n% = 48: GoTo NextText
    If n% = 61 Then n% = 49: GoTo NextText
    If n% = 91 Then n% = 50: GoTo NextText
    If n% = 93 Then n% = 51: GoTo NextText
    If n% = 123 Then n% = 52: GoTo NextText
    If n% = 125 Then n% = 53: GoTo NextText
    If n% = 92 Then n% = 54: GoTo NextText
    If n% = 126 Then n% = 55: GoTo NextText
    If n% = 96 Then n% = 56: GoTo NextText
    If n% = 44 Then n% = 57: GoTo NextText
    If n% = 46 Then n% = 58: GoTo NextText
    If n% = 60 Then n% = 59: GoTo NextText
    If n% = 62 Then n% = 60: GoTo NextText
    If n% = 63 Then n% = 61: GoTo NextText
    If n% = 47 Then n% = 62: GoTo NextText
    If n% = 59 Then n% = 64: GoTo NextText
    If n% = 58 Then n% = 65: GoTo NextText
    Exit Sub
    NextText:
    Line (textx%, texty%)-(textx% + 13, texty% + 8), 0, BF
    Put (textx%, texty%), TEXT%(n% * 20 - 20), PSet
End Sub

DefSng S
Sub Saver
    Cls: Screen 12
    Randomize Timer
    Do
        ss% = Rnd
        If ss% = 0 Then
            sx% = Rnd
            If sx% = 0 Then sx% = -60 Else sx% = 700
            sy% = Rnd * 480
        Else
            sy% = Rnd
            If sy% = 0 Then sy% = -60 Else sy% = 540
            sx% = Rnd * 640
        End If
        TEXT% = Rnd
        If TEXT% = 0 Then TEXT$ = " F U T U R E   S O F T W A R E"
        If TEXT% = 1 Then TEXT$ = " B O U N C E !"
        'FlyText sx%, sy%, RND * 240 + 200, RND * 450 + 10, text$
        FlyText2 sx%, sy%, Rnd * 240 + 200, Rnd * 450 + 10, Rnd * 240 + 200, Rnd * 450 + 10, TEXT$, Rnd * .6
        Delay .5
        Cls
        ink$ = InKey$
    Loop While ink$ = ""
End Sub

