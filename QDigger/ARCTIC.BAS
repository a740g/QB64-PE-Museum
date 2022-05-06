$Resize:Smooth
$ExeIcon:'.\ARCTIC.ico'

DefInt A-Z

Const PROGNAME$ = "Arctic Mine"
Const PROGVER$ = "v1.4 beta"
Const PROGEXE$ = "ARCTIC"
Const GRAPHSIZE = 19800 - 1 ' max = 32767-1
Const hiscorefile$ = "ARCTIC.SCO"

Const lifecost = 5000
Const inifile$ = "arctic.ini"
Const hiscorec = 7
Const namelen = 14

Const FALSE = 0, TRUE = Not FALSE, OLD = -2
Const scrmode = 9, nopal = FALSE

_Title PROGNAME$

Type SCORETYPE
    uname As String * Namelen
    score As Long
End Type
Type PICPAR
    sequence As Integer
    frame As Integer
End Type
Type TIMEINT
    starttime As Single
    interval As Single
End Type
Type DIGGERTYPE
    x As Integer
    y As Integer
    startx As Integer
    starty As Integer
    dx As Integer
    dy As Integer
    pic As PICPAR
    mode As Integer
    eye As Integer
    lives As Integer
    score As Long
    teye As TIMEINT
End Type
Type ENEMYTYPE
    x As Integer
    y As Integer
    stpx As Integer
    stpy As Integer
    trgx As Integer
    trgy As Integer
    dir As Integer
    pic As PICPAR
    chaseflee As Integer
    mode As Integer
    thob As TIMEINT
    tdead As TIMEINT
End Type
Type NESTTYPE
    x As Integer
    y As Integer
    count As Integer
End Type
Type PICKUPTYPE
    x As Integer
    y As Integer
    mode As Integer
    pic As PICPAR
    use As Integer
    misc As Integer
    fally As Integer
    dx As Integer
    dy As Integer
    dir As Integer
    t As TIMEINT
End Type
Type PARTYTYPE
    x As Integer
    y As Integer
    use As Integer
    iwait As Single
    ilen As Single
    t As TIMEINT
End Type

Const enm.creating = 1
Const enm.nobbin = 2
Const enm.hobbin = 3
Const enm.falling = 4
Const enm.dead = 5

Const mz.filled = -1
Const mz.empty = 0
Const mz.half = 1
Const mz.init = -100

Const gr.winner = 1
Const gr.gameover = 2
Const gr.abort = 0

Const newdecor = 1
Const newbag = 2
Const newnobbin = 4
Const newgift = 5

Const snd.decor = 1
Const snd.gift = 2
Const snd.party = 3
Const snd.dead = 5
Const snd.killenemy = 7
Const snd.bagswing = 6
Const snd.bagshift = 4
Const snd.bagfall = 8
Const snd.baglanding = 9
Const snd.hit = 10
Const snd.shoot = 11
Const snd.dig = 12

Const pal.normal = 0
Const pal.party = 1

Const diggerspeedy = 3
Const diggerspeedx = 4
Const dgr.left = 1
Const dgr.right = 2
Const dgr.up = 3
Const dgr.down = 4
Const dgr.dead = 5
Const dgr.falling = 6

Const viewx = 12, viewy = 8
Const cellw = 15 + 5
Const cellh = 14 + 4
Const mazex = 15
Const mazey = 10

Const f.x = 10
Const f.y = 16
Const f.w = cellw * mazex + 20
Const f.h = cellh * mazey + 12

Const tim.s.eye = 5
Const tim.s.hobbin = 3
Const tim.s.nobbin = 15
Const tim.d.nobbin = -1
Const tim.d.hobbin = 1
Const tim.min.nobbin = 7
Const tim.max.hobbin = 7

Const ani.stat = 0
Const ani.bgrs = 1
Const ani.dgrleft = 2
Const ani.dgrright = 3
Const ani.dgrup = 4
Const ani.dgrdown = 5
Const anid.withouteye = 4
Const ani.dgrxleft = 6
Const ani.dgrxright = 7
Const ani.dgrxup = 8
Const ani.dgrxdown = 9
Const ani.dgrdie = 10
Const ani.nobbin = 11
Const ani.nobbindie = 12
Const ani.hobbinleft = 13
Const ani.hobbinright = 14
Const ani.hobbindieleft = 15
Const ani.hobbindieright = 16
Const ani.decor = 17
Const ani.bag = 19
Const ani.bagleft = 18
Const ani.bagright = 20
Const ani.bagfall = 21
Const ani.party = 22
Const ani.coins = 23
Const ani.expl = 24
Const ani.fire = 25
Const ani.dig = 26
Const iblob.down = 79 + 6
Const iblob.left = iblob.down - 3
Const iblob.right = iblob.down - 2
Const iblob.up = iblob.down - 1

Const img1 = 0
Const framec = 1
Const mask = 1
Const pic = 0

Const opened = 0
Const leftwall = 1
Const rightwall = 2
Const upperwall = 4
Const lowerwall = 8
Const filled = 16

Const bagm.normal = 0
Const bagm.swinging = 1
Const bagm.left = 2
Const bagm.right = 3
Const bagm.falling = 4

Const maxcol = 15

Const ornw = 16, ornh = 13
Const giftw = 17, gifth = 15
Const imgw = 16, imgh = 16

Const gs.play = 0
Const gs.pause = 1
Const gs.killed = 2
Const gs.restart = 3
Const gs.newgame = 10
Const gs.quit = 100

Const eyem.normal = 0
Const eyem.expl = 1
Const eyew = 8, eyeh = 8

Const ps.brightbgr = 0
Const ps.whitebgr = 1
Const ps.snowing = 2

If Command$ = "/?" Then
    Print "Runs "; Chr$(34); PROGNAME$; Chr$(34); " computer game."
    Print
    Print PROGEXE$ + " [{ file | /? | /I }]"
    Print
    Print "    file    use levelpack from file 'file', not built-in levels."
    Print "    /I      create ini-file."
    Print
    Print "System requirements: 386/486, 250k of free base RAM, EGA 256k video."
    Print
    End
ElseIf UCase$(Command$) = "/I" Then
    Input "Do you want sound (y/n)"; s$: s$ = LCase$(s$)
    Input "Do you want RETRACE (y/n)"; v$: v$ = LCase$(v$)
    Input "Which party mode do you like (B for Bright, W for White, S for Snow)"; pm$: pm$ = Left$(LCase$(pm$), 1)
    Input "How many snow flakes do you want in decades (<=255)"; fl$: fl = Val(fl$)
    Print
    Open "ARCTIC.INI" For Output As #1
    If s$ = "y" Then Print #1, "s+ "; Else Print #1, "s- ";
    If v$ = "y" Then Print #1, "r+ "; Else Print #1, "r- ";
    Print #1, "b" + pm$ + " ";: Print #1, "f" + Hex$(fl);
    Close #1
    Print "ARCTIC.INI was created. Press any key to continue."
    While InKey$ = "": Wend
    While InKey$ <> "": Wend
End If

'$DYNAMIC
Dim Shared font(255, 15) As String * 1
Dim Shared mapon As Integer
Dim Shared eye As PICKUPTYPE
Dim Shared party As PARTYTYPE
Dim Shared tim.hobbin As Single, tim.nobbin As Single, tim.eye As Single
Dim Shared maze(-1 To mazex * 2 + 1, -1 To mazey * 2 + 1) As Integer
Dim Shared graph(GRAPHSIZE) As Integer, graphindex
Dim Shared img(90, 1) As Integer, imgc
Dim Shared anim(70, 1) As Integer
Dim Shared digger As DIGGERTYPE
Dim Shared enemy(1 To 5) As ENEMYTYPE, enemyc
Dim Shared bag(1 To 20) As PICKUPTYPE, bagc
Dim Shared gift(1 To 20) As PICKUPTYPE, giftc
Dim Shared decor(1 To 100) As PICKUPTYPE, decorc
Dim Shared hiscore(hiscorec - 1) As SCORETYPE
Dim Shared nest As NESTTYPE
Dim Shared levidx(1 To 256)
Dim Shared bgrc, curbgr, consorn, snowc, snowready
Dim Shared curlevel, partymode, bonusscore
Dim Shared levelpack$, nosound, partystyle
Dim Shared noretrace, gamestate
Dim Shared tcons As TIMEINT
Dim Shared shotc As Integer
Dim Shared gameresult
Dim Shared levelpal
Dim Shared scrbuf(32000 - 1) As Integer
Dim Shared snowbuf(1, 3) As Single

Print PROGNAME$ + " " + PROGVER$
'PRINT LTRIM$(RTRIM$(STR$(FRE(-1)))); "K of free base memory available"
INIT
Do
    curlevel = 0
    SETPAL pal.normal
    RESTOREFIELD
    NEWGAME
    If gameresult <> gr.abort Then COLLAPSE
    ADDSCORE -1
    CHECKHISCORE digger.score, gameresult
Loop Until gamestate = gs.quit
QUIT


DataLevidx:
Data 01,02,03,04,05,06,07,08
Data 06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,08
Data 05,06,07,-1

DataLevels:

Data "_mine #1"
Data "_levcol 1"
Data " :::$:::::    e"
Data " ::77::7:: :$::"
Data " $:77::7:: ::::"
Data " ::77$:7$: :777"
Data " ::77::7:: :777"
Data "  :77::7:: :777"
Data ": ::::$:$: ::::"
Data ":    ::::: ::::"
Data "7::: ::::: :::7"
Data "77::   d   ::77"

Data "_mine #2"
Data "_levcol 3"
Data "      ::$:$:: e"
Data ":77:: ::::::: :"
Data ":77:: :77777: :"
Data "$77$: :77777: :"
Data "7777: ::::::: :"
Data "7777: :$::    :"
Data ":77:: :77: ::::"
Data ":$$:: 7777 :77:"
Data "7:::: :77: :77:"
Data "77:::  d   ::::"

Data "_mine #3"
Data "_levcol 11"
Data "     $:$:$    e"
Data "77:: :7:7: :$$:"
Data "7::: :7:7: :77:"
Data ":$$: :7:7: 7777"
Data "7777 :7:7: 7777"
Data "7777       :77:"
Data ":77::7: :7::77:"
Data ":77::7: :7:::::"
Data "7::::7: :7::::7"
Data "77:::7:d:7:::77"

Data "_mine #4"
Data "_levcol 24"
Data "  $7777$7777$  "
Data "7 ::7777777:: 7"
Data "7   :77777:   7"
Data "7:: ::777:: ::7"
Data ":::   :7:   :::"
Data "::$:: :$: ::$::"
Data "::7:: 777 ::7::"
Data ":777:     :777:"
Data "77777:7 7:77777"
Data "77777:7d7:77777"

Data "_mine #5"
Data "_levcol 39"
Data "              e"
Data " $7777$ 777777 "
Data " 777777 :77$7: "
Data " :7777: 77$777 "
Data " 777777 :7777: "
Data " :7777: $77777 "
Data " 77$777 :7777: "
Data " :77$7: 777777 "
Data " 777777 777777 "
Data "       d       "

Data "_mine #6"
Data "_levcol 8"
Data "              e"
Data " 7$77 : : 77$7 "
Data " 777: $ $ :777 "
Data " 777  : :  777 "
Data " 77: :7 7: :77 "
Data " 77  :7 7:  77 "
Data " 7: :77 77: :7 "
Data " 7  $77 77$  7 "
Data " 7 7777 7777 7 "
Data "       d       "

Data "_mine #7"
Data "_levcol 7"
Data "  77777 77777 e"
Data ": 7$7$7 7$7$7 :"
Data "$ 77777 77777 $"
Data "7  7777 7777  7"
Data "77 :777 777: 77"
Data "77   77 77   77"
Data "7777 :7 7: 7777"
Data "7777  : :  7777"
Data "77777 : : 77777"
Data "77777  d  77777"

Data "_mine #8"
Data "_levcol 15"
Data "              e"
Data " :77$77777$77: "
Data "   7777$7777   "
Data " $ :7777777: $ "
Data " 7   77777   7 "
Data " 77$ :777: $77 "
Data " 777   7   777 "
Data " 7777: : :7777 "
Data " 77777 : 77777 "
Data "       d       "

Data "_end"

DataGfx:
'stats = 0
Data 11
Data 12,12
Data "877777777888"
Data "777777777788"
Data "778888887788"
Data "778888887788"
Data "778888887788"
Data "778888777788"
Data "778888777788"
Data "778888777788"
Data "778888777788"
Data "778888777788"
Data "777777777788"
Data "877777777888"
Data 12,12
Data "888887788888"
Data "888887788888"
Data "888887788888"
Data "888887788888"
Data "888887788888"
Data "888877788888"
Data "888877788888"
Data "888877788888"
Data "888877788888"
Data "888877788888"
Data "888877788888"
Data "888877788888"
Data 12,12
Data "877777777888"
Data "777777777788"
Data "778888887788"
Data "888888887788"
Data "888888887788"
Data "888888887788"
Data "877777777788"
Data "777777777888"
Data "777788888888"
Data "777788888888"
Data "777777777788"
Data "877777777788"
Data 12,12
Data "877777788888"
Data "777777778888"
Data "778888778888"
Data "778888778888"
Data "888888778888"
Data "887777777888"
Data "887777777788"
Data "888888877788"
Data "778888877788"
Data "778888877788"
Data "777777777788"
Data "877777777888"
Data 12,12
Data "778888888888"
Data "778888888888"
Data "778888778888"
Data "778888778888"
Data "778888778888"
Data "778888778888"
Data "778888778888"
Data "777777777788"
Data "877777777788"
Data "888887778888"
Data "888887778888"
Data "888887778888"
Data 12,12
Data "877777778888"
Data "777777778888"
Data "778888888888"
Data "778888888888"
Data "778888888888"
Data "777777777888"
Data "877777777788"
Data "888888777788"
Data "778888777788"
Data "778888777788"
Data "777777777788"
Data "877777777888"
Data 12,12
Data "877777777888"
Data "777777777788"
Data "778888887788"
Data "778888887788"
Data "778888888888"
Data "777777777888"
Data "777777777788"
Data "778888777788"
Data "778888777788"
Data "778888777788"
Data "777777777788"
Data "877777777888"
Data 12,12
Data "877777777888"
Data "877777777788"
Data "888888887788"
Data "888888887788"
Data "888888887788"
Data "888888887788"
Data "888888877788"
Data "888888877788"
Data "888888877788"
Data "888888877788"
Data "888888877788"
Data "888888877788"
Data 12,12
Data "888777778888"
Data "887777777888"
Data "887788877888"
Data "887788877888"
Data "887788877888"
Data "887777777888"
Data "877777777788"
Data "778888877788"
Data "778888877788"
Data "778888877788"
Data "777777777788"
Data "877777777888"
Data 12,12
Data "877777777888"
Data "777777777788"
Data "778888887788"
Data "778888887788"
Data "778888887788"
Data "777777777788"
Data "877777777788"
Data "888888777788"
Data "888888777788"
Data "888888777788"
Data "888888777788"
Data "888888777788"
Data 16,14
Data "8888888888888888"
Data "88888888FF888888"
Data "8888888FFFF88888"
Data "8888888F88F88888"
Data "AAAAA8BBBBBBB888"
Data "AAAAAABBBBBBBB88"
Data "8888AABBBBBBBBB8"
Data "AAAAAABBBBBBBBBB"
Data "AAAAA8B88BBBB88B"
Data "8888888FF8BB8FF8"
Data "888888F88F88F88F"
Data "888888F88F88F88F"
Data "8888888FF8888FF8"
Data "8888888888888888"

gfx.bgrs:
Data 8
Data 20,4
Data "77FFFFFF7777FFFFFF77"
Data "F77FFFF77FF77FFFF77F"
Data "FF77FF77FFFF77FF77FF"
Data "FFF7777FFFFFF7777FFF"
Data 20,4
Data "AA77AA77AA77AA77AA77"
Data "7AA77AA77AA77AA77AA7"
Data "77AA77AA77AA77AA77AA"
Data "7AA77AA77AA77AA77AA7"
Data 20,4
Data "77FF77FF77FF77FF77FF"
Data "F77FF77FF77FF77FF77F"
Data "FF77FF77FF77FF77FF77"
Data "7FF77FF77FF77FF77FF7"
Data 20,4
Data "AAFFFFFFAAAAFFFFFFAA"
Data "FAAFFFFAAFFAAFFFFAAF"
Data "FFAAFFAAFFFFAAFFAAFF"
Data "FFFAAAAFFFFFFAAAAFFF"
Data 20,4
Data "77FFFFFF7777FFFFFF77"
Data "FAAFFFFAAFFAAFFFFAAF"
Data "FF77FF77FFFF77FF77FF"
Data "FFFAAAAFFFFFFAAAAFFF"
Data 20,4
Data "AA77AA77AA77AA77AA77"
Data "7AA77AA77AA77AA77AA7"
Data "AA77AA77AA77AA77AA77"
Data "7AA77AA77AA77AA77AA7"
Data 20,4
Data "77FF77FF77FF77FF77FF"
Data "FAAFFAAFFAAFFAAFFAAF"
Data "FFAAFFAAFFAAFFAAFFAA"
Data "7FF77FF77FF77FF77FF7"
Data 20,4
Data "FF77FF77FF77FF77FF77"
Data "7FF77FF77FF77FF77FF7"
Data "77FF77FF77FF77FF77FF"
Data "7FF77FF77FF77FF77FF7"

'digger: left = 2
Data 3
Data 17,15
Data "///////8888//////"
Data "//////8FFFF8/////"
Data "//////8F88F8/////"
Data "//////8F88F8/////"
Data "/8888/8F88F88////"
Data "8AAAA8BBBBBBB8///"
Data "8AAAAABBBBBBBB8//"
Data "/888AABBBBBBBBB8/"
Data "8AAAAABBBBBBB88B8"
Data "8AAAA8B88BBB8FF8/"
Data "/8888/8FF8B8F88F8"
Data "/////8F88F88F88F8"
Data "/////8F88F8/8FF8/"
Data "//////8FF8///88//"
Data "///////88////////"
Data 17,15
Data "////////88///////"
Data "///////8FF8//////"
Data "//////8FFFF8/////"
Data "/8888/8F88F8/////"
Data "8AAAA88F88F88////"
Data "8AAAAABBBBBBB8///"
Data "/88AAABBBBBBBB8//"
Data "///8AABBBBBBBBB8/"
Data "/88AAAB88BBBBBBB8"
Data "8AAAAA8FF88BB88B8"
Data "8AAAA8F88F888FF8/"
Data "/88888F88F88F88F8"
Data "//////8FF8/8F88F8"
Data "///////88///8FF8/"
Data "/////////////88//"
Data 17,15
Data "/////////////////"
Data "////////88///////"
Data "//88///8FF8//////"
Data "/8AA8/8FFFF8/////"
Data "/8AAA88F88F88////"
Data "//8AAABBBBBBB8///"
Data "///8AABBBBBBBB8//"
Data "///8AABBBBBBBBB8/"
Data "///8AABBBBBBB88B8"
Data "//8AAAB88BBB8FF8/"
Data "/8AAA88FF8B8F88F8"
Data "/8AA88F88F88F88F8"
Data "//88/8F88F8/8FF8/"
Data "//////8FF8///88//"
Data "///////88////////"

'digg6r: right = 6
Data 3
Data 17,15
Data "//////8888///////"
Data "/////8FFFF8//////"
Data "/////8F88F8//////"
Data "/////8F88F8//////"
Data "////88F88F8/8888/"
Data "///8BBBBBBB8AAAA8"
Data "//8BBBBBBBBAAAAA8"
Data "/8BBBBBBBBBAA888/"
Data "8B88BBBBBBBAAAAA8"
Data "/8FF8BBB88B8AAAA8"
Data "8F88F8B8FF8/8888/"
Data "8F88F88F88F8/////"
Data "/8FF8/8F88F8/////"
Data "//88///8FF8//////"
Data "////////88///////"
Data 17,15
Data "///////88////////"
Data "//////8FF8///////"
Data "/////8FFFF8//////"
Data "/////8F88F8//888/"
Data "////88F88F888AAA8"
Data "///8BBBBBBBAAAAA8"
Data "//8BBBBBBBBAAA88/"
Data "/8BBBBBBBBBAA8///"
Data "8BBBBBBB88BAAA88/"
Data "8B88BBB8FF8AAAAA8"
Data "/8FF8B8F88F88AAA8"
Data "8F88F88F88F8/888/"
Data "8F88F8/8FF8//////"
Data "/8FF8///88///////"
Data "//88/////////////"
Data 17,15
Data "/////////////////"
Data "///////88////////"
Data "//////8FF8///88//"
Data "/////8FFFF8/8AA8/"
Data "////88F88F88AAA8/"
Data "///8BBBBBBBAAA8//"
Data "//8BBBBBBBBAA8///"
Data "/8BBBBBBBBBAA8///"
Data "8B88BBBBBBBAA8///"
Data "/8FF8BBB88BAAA8//"
Data "8F88F8B8FF88AAA8/"
Data "8F88F88F88F88AA8/"
Data "/8FF8/8F88F8/88//"
Data "//88///8FF8//////"
Data "////////88///////"

'digg6r: up = /
Data 3
Data 15,16
Data "/////88/88//////"
Data "////8AA8AA8/////"
Data "////8AA8AA8/////"
Data "////8AA8AA8/////"
Data "//88/8AAA8//////"
Data "/8FF8BBBBB8888//"
Data "8F88F8BBBBFFFF8/"
Data "8F88F8BBBB888FF8"
Data "/8FF8BBBBB888FF8"
Data "//888BBBBBFFFF8/"
Data "///88BBBBB8888//"
Data "//8FF8BBBB8/////"
Data "/8F88F8BB8//////"
Data "/8F88F8B8///////"
Data "//8FF8B8////////"
Data "///88/8/////////"
Data 15,16
Data "////88///88////"
Data "///8AA8/8AA8///"
Data "///8AAA8AAA8///"
Data "///8AAAAAAA8///"
Data "///88AAAAA8////"
Data "//8FF8BBBB888//"
Data "/8F88F8BBBFFF8/"
Data "/8F88F8BBB88FF8"
Data "//8FF8BBBB88FF8"
Data "///888BBBBFFF8/"
Data "//888BBBBB888//"
Data "/8FF8BBBBB8////"
Data "8F88F8BBB8/////"
Data "8F88F8BB8//////"
Data "/8FF8BB8///////"
Data "//88/88////////"
Data 15,16
Data "///88/////88///"
Data "//8AA8///8AA8//"
Data "//8AAA888AAA8//"
Data "///8AAAAAAA8///"
Data "//888AAAAA8////"
Data "/8FF8BBBBB88///"
Data "8F88F8BBBBFF8//"
Data "8F88F8BBBB8FF8/"
Data "/8FF8BBBBB8FF8/"
Data "//888BBBBBFF8//"
Data "///88BBBBB88///"
Data "//8FF8BBBB8////"
Data "/8F88F8BB8/////"
Data "/8F88F8B8//////"
Data "//8FF8B8///////"
Data "///88/8////////"

'digger: down = 5
Data 3
Data 15,16
Data "////////8/88///"
Data "///////8B8FF8//"
Data "//////8B8F88F8/"
Data "/////8BB8F88F8/"
Data "////8BBBB8FF8//"
Data "/8888BBBBB88///"
Data "8FFFFBBBBB888//"
Data "8F888BBBBB8FF8/"
Data "8F888BBBB8F88F8"
Data "8FFFFBBBB8F88F8"
Data "/8888BBBBB8FF8/"
Data "/////8AAA8/88//"
Data "////8AAAAA8////"
Data "////8AA8AA8////"
Data "////8AA8AA8////"
Data "/////88/88/////"
Data 15,16
Data "////////88/88//"
Data "///////8BB8FF8/"
Data "//////8BB8F88F8"
Data "/////8BBB8F88F8"
Data "////8BBBBB8FF8/"
Data "//888BBBBB888//"
Data "/8FFFBBBB888///"
Data "8FF88BBBB8FF8//"
Data "8FF88BBB8F88F8/"
Data "/8FFFBBB8F88F8/"
Data "//888BBBB8FF8//"
Data "////8AAAA888///"
Data "///8AAA8AAA8///"
Data "///8AA8/8AA8///"
Data "///8AA8/8AA8///"
Data "////88///88////"
Data 15,16
Data "////////8/88///"
Data "///////8B8FF8//"
Data "//////8B8F88F8/"
Data "/////8BB8F88F8/"
Data "////8BBBB8FF8//"
Data "///88BBBBB88///"
Data "//8FFBBBBB888//"
Data "/8FF8BBBBB8FF8/"
Data "/8FF8BBBB8F88F8"
Data "//8FFBBBB8F88F8"
Data "///88BBBBB8FF8/"
Data "////8AAAAA888//"
Data "///8AAAAAAA8///"
Data "//8AAA888AAA8//"
Data "//8AA8///8AA8//"
Data "///88/////88///"

' digger: leftx
Data 3
Data 17,15
Data "/////////////////"
Data "/////////////////"
Data "////////88///////"
Data "///////8FF8//////"
Data "/8888/8FFFF88////"
Data "8AAAA8BBBBBBB8///"
Data "8AAAAABBBBBBBB8//"
Data "/888AABBBBBBBBB8/"
Data "8AAAAABBBBBBB88B8"
Data "8AAAA8B88BBB8FF8/"
Data "/8888/8FF8B8F88F8"
Data "/////8F88F88F88F8"
Data "/////8F88F8/8FF8/"
Data "//////8FF8///88//"
Data "///////88////////"
Data 17,15
Data "/////////////////"
Data "/////////////////"
Data "////////88///////"
Data "/8888//8FF8//////"
Data "8AAAA88FFFF88////"
Data "8AAAAABBBBBBB8///"
Data "/88AAABBBBBBBB8//"
Data "///8AABBBBBBBBB8/"
Data "/88AAAB88BBBBBBB8"
Data "8AAAAA8FF88BB88B8"
Data "8AAAA8F88F888FF8/"
Data "/88888F88F88F88F8"
Data "//////8FF8/8F88F8"
Data "///////88///8FF8/"
Data "/////////////88//"
Data 17,15
Data "/////////////////"
Data "/////////////////"
Data "//88////88///////"
Data "/8AA8//8FF8//////"
Data "/8AAA88FFFF88////"
Data "//8AAABBBBBBB8///"
Data "///8AABBBBBBBB8//"
Data "///8AABBBBBBBBB8/"
Data "///8AABBBBBBB88B8"
Data "//8AAAB88BBB8FF8/"
Data "/8AAA88FF8B8F88F8"
Data "/8AA88F88F88F88F8"
Data "//88/8F88F8/8FF8/"
Data "//////8FF8///88//"
Data "///////88////////"

'digger: rightx
Data 3
Data 17,15
Data "/////////////////"
Data "/////////////////"
Data "///////88////////"
Data "//////8FF8///////"
Data "////88FFFF8/8888/"
Data "///8BBBBBBB8AAAA8"
Data "//8BBBBBBBBAAAAA8"
Data "/8BBBBBBBBBAA888/"
Data "8B88BBBBBBBAAAAA8"
Data "/8FF8BBB88B8AAAA8"
Data "8F88F8B8FF8/8888/"
Data "8F88F88F88F8/////"
Data "/8FF8/8F88F8/////"
Data "//88///8FF8//////"
Data "////////88///////"
Data 17,15
Data "/////////////////"
Data "/////////////////"
Data "///////88////////"
Data "//////8FF8///888/"
Data "////88FFFF888AAA8"
Data "///8BBBBBBBAAAAA8"
Data "//8BBBBBBBBAAA88/"
Data "/8BBBBBBBBBAA8///"
Data "8BBBBBBB88BAAA88/"
Data "8B88BBB8FF8AAAAA8"
Data "/8FF8B8F88F88AAA8"
Data "8F88F88F88F8/888/"
Data "8F88F8/8FF8//////"
Data "/8FF8///88///////"
Data "//88/////////////"
Data 17,15
Data "/////////////////"
Data "/////////////////"
Data "///////88////88//"
Data "//////8FF8//8AA8/"
Data "////88FFFF88AAA8/"
Data "///8BBBBBBBAAA8//"
Data "//8BBBBBBBBAA8///"
Data "/8BBBBBBBBBAA8///"
Data "8B88BBBBBBBAA8///"
Data "/8FF8BBB88BAAA8//"
Data "8F88F8B8FF88AAA8/"
Data "8F88F88F88F88AA8/"
Data "/8FF8/8F88F8/88//"
Data "//88///8FF8//////"
Data "////////88///////"

'digger: upx
Data 3
Data 15,16
Data "/////88/88/////"
Data "////8AA8AA8////"
Data "////8AA8AA8////"
Data "////8AA8AA8////"
Data "//88/8AAA8/////"
Data "/8FF8BBBBB8////"
Data "8F88F8BBBBF8///"
Data "8F88F8BBBBFF8//"
Data "/8FF8BBBBBFF8//"
Data "//888BBBBBF8///"
Data "///88BBBBB8////"
Data "//8FF8BBBB8////"
Data "/8F88F8BB8/////"
Data "/8F88F8B8//////"
Data "//8FF888///////"
Data "///88//////////"
Data 15,16
Data "////88///88////"
Data "///8AA8/8AA8///"
Data "///8AAA8AAA8///"
Data "///8AAAAAAA8///"
Data "///88AAAAA8////"
Data "//8FF8BBBB8////"
Data "/8F88F8BBBF8///"
Data "/8F88F8BBBFF8//"
Data "//8FF8BBBBFF8//"
Data "///888BBBBF8///"
Data "//888BBBBB8////"
Data "/8FF8BBBBB8////"
Data "8F88F8BBB8/////"
Data "8F88F8BB8//////"
Data "/8FF8BB8///////"
Data "//88/88////////"
Data 15,16
Data "///88/////88///"
Data "//8AA8///8AA8//"
Data "//8AAA888AAA8//"
Data "///8AAAAAAA8///"
Data "//888AAAAA8////"
Data "/8FF8BBBBB8////"
Data "8F88F8BBBBF8///"
Data "8F88F8BBBBFF8//"
Data "/8FF8BBBBBFF8//"
Data "//888BBBBBF8///"
Data "///88BBBBB8////"
Data "//8FF8BBBB8////"
Data "/8F88F8BB8/////"
Data "/8F88F8B8//////"
Data "//8FF8B8///////"
Data "///88/8////////"

'digger: downx
Data 3
Data 15,16
Data "////////8/88///"
Data "///////8B8FF8//"
Data "//////8B8F88F8/"
Data "/////8BB8F88F8/"
Data "////8BBBB8FF8//"
Data "////8BBBBB88///"
Data "///8FBBBBB888//"
Data "//8FFBBBBB8FF8/"
Data "//8FFBBBB8F88F8"
Data "///8FBBBB8F88F8"
Data "////8BBBBB8FF8/"
Data "/////8AAA8/88//"
Data "////8AAAAA8////"
Data "////8AA8AA8////"
Data "////8AA8AA8////"
Data "/////88/88/////"
Data 15,16
Data "////////88/88//"
Data "///////8BB8FF8/"
Data "//////8BB8F88F8"
Data "/////8BBB8F88F8"
Data "////8BBBBB8FF8/"
Data "////8BBBBB888//"
Data "///8FBBBB888///"
Data "//8FFBBBB8FF8//"
Data "//8FFBBB8F88F8/"
Data "///8FBBB8F88F8/"
Data "////8BBBB8FF8//"
Data "////8AAAA888///"
Data "///8AAA8AAA8///"
Data "///8AA8/8AA8///"
Data "///8AA8/8AA8///"
Data "////88///88////"
Data 15,16
Data "////////8/88///"
Data "///////8B8FF8//"
Data "//////8B8F88F8/"
Data "/////8BB8F88F8/"
Data "////8BBBB8FF8//"
Data "////8BBBBB88///"
Data "///8FBBBBB888//"
Data "//8FFBBBBB8FF8/"
Data "//8FFBBBB8F88F8"
Data "///8FBBBB8F88F8"
Data "////8BBBBB8FF8/"
Data "////8AAAAA888//"
Data "///8AAAAAAA8///"
Data "//8AAA888AAA8//"
Data "//8AA8///8AA8//"
Data "///88/////88///"

'digger: die
Data 6
Data 17,15
Data "///////88////88//"
Data "//////8FF8//8FF8/"
Data "/////8FF8F88FFFF8"
Data "//8888FFFF88FF8F8"
Data "/8AAA88FF8BB8FF8/"
Data "8AAAAAB88BBBB88B8"
Data "8A88AABBBBBBBBB8/"
Data "/8AAAABBBBBBBB8//"
Data "8AAAA8BBBBBBB8///"
Data "8A888/8F88FF8////"
Data "/8////88F8F88////"
Data "//////8F88FF8////"
Data "///////8FFFF8////"
Data "////////8FF8/////"
Data "/////////88//////"
Data 16,15
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "//////888///////"
Data "////8877788/////"
Data "//8877FFF7788///"
Data "/877FFFFFFF778//"
Data "/87FFFFFFFFF78//"
Data "888888888888888/"
Data 16,15
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "//////888///////"
Data "////8877788/////"
Data "//8877FFF7788///"
Data "/877FFFFFFF778//"
Data "/87FFFFFFFFF78//"
Data "878888FFFFFFF78/"
Data "878FF8F8FFFFF78/"
Data "888888888888888/"
Data 16,15
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "//////888///////"
Data "////8877788/////"
Data "//8877FFF7788///"
Data "/877FFFFFFF778//"
Data "/87FFFFFFFFF78//"
Data "878888FFFFFFF78/"
Data "878FF8F8FFFFF78/"
Data "878888F8F888878/"
Data "8788FFF8F8FF878/"
Data "888888888888888/"
Data 16,15
Data "////////////////"
Data "////////////////"
Data "//////888///////"
Data "////8877788/////"
Data "//8877FFF7788///"
Data "/877FFFFFFF778//"
Data "/87FFFFFFFFF78//"
Data "878888FFFFFFF78/"
Data "878FF8F8FFFFF78/"
Data "878888F8F888878/"
Data "8788FFF8F8FF878/"
Data "878F8FF8F888878/"
Data "878FF8F8F8FFF78/"
Data "87FFFFF8F8FFF78/"
Data "888888888888888/"
Data 16,15
Data "//////888///////"
Data "////8877788/////"
Data "//8877FFF7788///"
Data "/877FFFFFFF778//"
Data "/87FFFFFFFFF78//"
Data "878888FFFFFFF78/"
Data "878FF8F8FFFFF78/"
Data "878888F8F888878/"
Data "8788FFF8F8FF878/"
Data "878F8FF8F888878/"
Data "878FF8F8F8FFF78/"
Data "87FFFFF8F8FFF78/"
Data "87FFFFFFF8FFF78/"
Data "87FFFFFFFFFFF78/"
Data "888888888888888/"

'nobbin: walk
Data 3
Data 16,15
Data "///888////888///"
Data "//8FFF8888FFF8//"
Data "/8FFFFF99FFFFF8/"
Data "/8F88FF99F88FF8/"
Data "/8F88FF99F88FF8/"
Data "//8FFF9999FFF8//"
Data "///8999999998///"
Data "///8899999988///"
Data "//8EE898898EE8//"
Data "/8EE88999988EE8/"
Data "/8EE8/8998/8EE8/"
Data "/8EE8//88/8EEEE8"
Data "/8EE8////8EEEEE8"
Data "8EEEE8////888888"
Data "8888888/////////"
Data 16,15
Data "///888////888///"
Data "//8FFF8888FFF8//"
Data "/8FFFFF99FFFFF8/"
Data "/8FF88F99FF88F8/"
Data "/8FF88F99FF88F8/"
Data "//8FFF9999FFF8//"
Data "///8999999998///"
Data "///8899889988///"
Data "//8EE898898EE8//"
Data "/8EE88999988EE8/"
Data "/8EE8/8998/8EE8/"
Data "/8EE8//88//8EE8/"
Data "8EEEE/////8EEEE8"
Data "8EEEEE///8EEEEE8"
Data "888888////888888"
Data 16,15
Data "///888////888///"
Data "//8FFF8888FFF8//"
Data "/8FF88F99FF88F8/"
Data "/8FF88F99FF88F8/"
Data "/8FFFFF99FFFFF8/"
Data "//8FFF9999FFF8//"
Data "///8999889998///"
Data "///8899889988///"
Data "//8EE898898EE8//"
Data "/8EE88988988EE8/"
Data "/8EE8/8998/8EE8/"
Data "8EEEE8/88//8EE8/"
Data "8EEEEE8////8EE8/"
Data "888888////8EEEE8"
Data "/////////8888888"

'nobbin: die
Data 1
Data 16,15
Data "////////////////"
Data "////////////////"
Data "///888////888///"
Data "//8FFF8888FFF8//"
Data "/8F88FF99FF88F8/"
Data "/8F88FF99FF88F8/"
Data "/8FFFFF99FFFFF8/"
Data "//8FFF9999FFF8//"
Data "///8999889998///"
Data "///8899889988///"
Data "//8EE898898EE8//"
Data "/8EE88988988EE8/"
Data "8EEEE889988EEEE8"
Data "8EEEEE8888EEEEE8"
Data "888888////888888"

'hobbin: left
Data 3
Data 16,16
Data "/////8888888////"
Data "////898FFF898///"
Data "///898FFFFF898//"
Data "///898FF88F8998/"
Data "//8998FF88F89998"
Data "/899998FFF899998"
Data "8999999888999998"
Data "/8EEEEE99999998/"
Data "//88888E999998//"
Data "/8EEEEE999998///"
Data "//8999999998////"
Data "///8888EE88/////"
Data "//////8EE8//////"
Data "//////8EE8//////"
Data "/////8EEEE8/////"
Data "////88888888////"
Data 16,16
Data "/////8888888////"
Data "////898FFF898///"
Data "///898FFFFF898//"
Data "//8998F88FF8998/"
Data "/89998F88FF89998"
Data "8999998FFF899998"
Data "8EEE999888999998"
Data "/888EEE99999998/"
Data "////888E999998//"
Data "//888EE999998///"
Data "/8EEE9999998////"
Data "//99988EE88/////"
Data "///88/8EE8//////"
Data "/////8EEEE8/////"
Data "////8EEEEEE8////"
Data "/////888888/////"
Data 16,16
Data "/////8888888////"
Data "////898FFF898///"
Data "///898F88FF898//"
Data "//8998F88FF8998/"
Data "/89998FFFFF89998"
Data "8EE9998FFF899998"
Data "/88EE99888999998"
Data "///88EE99999998/"
Data "////888E999998//"
Data "//888EE999998///"
Data "//8EE9999998////"
Data "//E9988EE88/////"
Data "///888EEEE8/////"
Data "////8EEEEEE8////"
Data "/////888888/////"
Data "////////////////"

'hobbin: right
Data 3
Data 16,16
Data "////8888888/////"
Data "///898FFF898////"
Data "//898FFFFF898///"
Data "/8998F88FF898///"
Data "89998F88FF8998//"
Data "899998FFF899998/"
Data "8999998889999998"
Data "/89999999EEEEE8/"
Data "//899999E88888//"
Data "///899999EEEEE8/"
Data "////8999999998//"
Data "/////88EE8888///"
Data "//////8EE8//////"
Data "//////8EE8//////"
Data "/////8EEEE8/////"
Data "////88888888////"
Data 16,16
Data "////8888888/////"
Data "///898FFF898////"
Data "//898FFFFF898///"
Data "/8998FF88F8998//"
Data "89998FF88F89998/"
Data "899998FFF8999998"
Data "899999888999EEE8"
Data "/89999999EEE888/"
Data "//899999E888////"
Data "///899999EE888//"
Data "////8999999EEE8/"
Data "/////88EE889998/"
Data "//////8EE8/888//"
Data "/////8EEEE8/////"
Data "////8EEEEEE8////"
Data "/////888888/////"
Data 16,16
Data "////8888888/////"
Data "///898FFF898////"
Data "//898FF88F898///"
Data "/8998FF88F8998//"
Data "89998FFFFF89998/"
Data "899998FFF8999EE8"
Data "89999988899EE88/"
Data "/89999999EE88///"
Data "//899999E88/////"
Data "///899999EE88///"
Data "////8999999EE88/"
Data "/////88EE8899E8/"
Data "/////8EEEE8888//"
Data "////8EEEEEE8////"
Data "/////888888/////"
Data "////////////////"

'hobbin: dieleft
Data 1
Data 16,14
Data "/////8888888////"
Data "////898FFF898///"
Data "///898F88FF898//"
Data "//8998F88FF8998/"
Data "/89998FFFFF89998"
Data "8EE9998FFF899998"
Data "/88EE99888999998"
Data "///88EE99999998/"
Data "///88EEE999998//"
Data "/88EEE9999998///"
Data "8EEE99999998////"
Data "/88888EEEE8/////"
Data "////8EEEEEE8////"
Data "/////888888/////"

'hobbin: dieright
Data 1
Data 16,15
Data "////////////////"
Data "////8888888/////"
Data "///898FFF898////"
Data "//898FF88F898///"
Data "/8998FF88F8998//"
Data "89998FFFFF89998/"
Data "899998FFF8999EE8"
Data "89999988899EE88/"
Data "/89999999EE88///"
Data "//899999EEE88///"
Data "///8999999EEE88/"
Data "////89999999EEE8"
Data "/////8EEEE88888/"
Data "////8EEEEEE8////"
Data "/////888888/////"

' decorent
gfx.decorent:
Data 7
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "89FFFFFFFFFFF8"
Data "89FF99FFF9FFF8"
Data "8999999F999F98"
Data "89919999999998"
Data "/899119999998/"
Data "//8899999988//"
Data "////888888////"
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "8AFFFFFFFFFFF8"
Data "8AFFAAFFFAFFF8"
Data "8AAAAAAFAAAFA8"
Data "8AA2AAAAAAAAA8"
Data "/8AA22AAAAAA8/"
Data "//88AAAAAA88//"
Data "////888888////"
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "8BFFFFFFFFFFF8"
Data "8BFFBBFFFBFFF8"
Data "8BBBBBBFBBBFB8"
Data "8BB3BBBBBBBBB8"
Data "/8BB33BBBBBB8/"
Data "//88BBBBBB88//"
Data "////888888////"
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "8CFFFFFFFFFFF8"
Data "8CFFCCFFFCFFF8"
Data "8CCCCCCFCCCFC8"
Data "8CC4CCCCCCCCC8"
Data "/8CC44CCCCCC8/"
Data "//88CCCCCC88//"
Data "////888888////"
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "8DFFFFFFFFFFF8"
Data "8DFFDDFFFDFFF8"
Data "8DDDDDDFDDDFD8"
Data "8DD5DDDDDDDDD8"
Data "/8DD55DDDDDD8/"
Data "//88DDDDDD88//"
Data "////888888////"
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "8EFFFFFFFFFFF8"
Data "8EFFEEFFFEFFF8"
Data "8EEEEEEFEEEFE8"
Data "8EE6EEEEEEEEE8"
Data "/8EE66EEEEEE8/"
Data "//88EEEEEE88//"
Data "////888888////"
Data 14,13
Data "//////88//////"
Data "/////8EE8/////"
Data "/////8FF8/////"
Data "////8FFFF8////"
Data "//88FFFFFF88//"
Data "/8FFFFFFFFFF8/"
Data "87FFFFFFFFFFF8"
Data "87FF77FFF7FFF8"
Data "8777777F777F78"
Data "87717777777778"
Data "/877117777778/"
Data "//8877777788//"
Data "////888888////"

' giftbag: moveleft
Data 1
Data 16,15
Data "/////8888///////"
Data "////866668//////"
Data "/////8668///////"
Data "////8666688/////"
Data "///866666668////"
Data "//86FF66FF668///"
Data "/866FF66FF6668//"
Data "866F66FF66F6668/"
Data "86FFFFFFFFFF668/"
Data "866F66FF66F6668/"
Data "8666FF66FF66668/"
Data "8666FF66FF6668//"
Data "/866666666668///"
Data "//8866666688////"
Data "////888888//////"

' giftbag: normal
Data 1
Data 16,15
Data "/////888888/////"
Data "/////866668/////"
Data "//////8668//////"
Data "////88666688////"
Data "///8666666668///"
Data "//866FF66FF668//"
Data "/8666FF66FF6668/"
Data "8666F66FF66F6668"
Data "866FFFFFFFFFF668"
Data "8666F66FF66F6668"
Data "86666FF66FF66668"
Data "86666FF66FF66668"
Data "/86666666666668/"
Data "//886666666688//"
Data "////88888888////"

'giftbag: moveright
Data 1
Data 16,15
Data "///////8888/////"
Data "//////866668////"
Data "//////88668/////"
Data "/////8666668////"
Data "////866666668///"
Data "///866FF66FF68//"
Data "//8666FF66FF668/"
Data "/8666F66FF66F668"
Data "/866FFFFFFFFFF68"
Data "/8666F66FF66F668"
Data "/86666FF66FF6668"
Data "//8666FF66FF668/"
Data "///86666666668//"
Data "////886666688///"
Data "//////88888/////"


'giftbag: fall
Data 1
Data 16,15
Data "/////868868/////"
Data "//////8668//////"
Data "//////8668//////"
Data "/////866668/////"
Data "////86666668////"
Data "///86FF66FF68///"
Data "//866FF66FF668//"
Data "/866F66FF66F668/"
Data "/86FFFFFFFFFF68/"
Data "/866F66FF66F668/"
Data "/8666FF66FF6668/"
Data "//866FF66FF668//"
Data "///8666666668///"
Data "////88666688////"
Data "//////8888//////"

' fir-tree
Data 1
Data 16,15
Data "///////8////////"
Data "//////8F8///////"
Data "/////8E2F8//////"
Data "////8F22928/////"
Data "/////8AF28//////"
Data "////8D2E2F8/////"
Data "///82F92FD28////"
Data "//82CF2A22CF8///"
Data "///88222FA88////"
Data "///8A2E22228////"
Data "//8F2F2FC2F28///"
Data "/8D22C222D29F8//"
Data "8F29F22AF2E22A8/"
Data "/8888844488888//"
Data "//////888///////"

' gifts from bag
Data 3
Data 16,15
Data "//////8/////////"
Data "/////8F8C///////"
Data "////8FFFCC//////"
Data "///8FCFCF8///8//"
Data "//8FFFCFFF8/8F8/"
Data "/8/8FCFCF8/8BFF8"
Data "8D8/8FFF8/8B9B8/"
Data "DFF888F888B9B88/"
Data "8FDD8E8E8FFB8FF8"
Data "/8DF8EEE88F82FF8"
Data "//8F8FFF88822228"
Data "/8FDD88F88FF2FF8"
Data "/8888778/8FF2FF8"
Data "8FF77778//88888/"
Data "/888888/////////"
Data 16,15
Data "////////////////"
Data "////////88//////"
Data "//////88CC8/////"
Data "/////8FFCF8/////"
Data "/////8FFCFF8////"
Data "////8CCFCFF8////"
Data "////8FFCCCC8////"
Data "////8FFCFF88888/"
Data "//8/888CFF8228F8"
Data "/8D88EE888F88FF8"
Data "8DFF8EEE888B9B88"
Data "/8FDDFFF8FF9B828"
Data "/888888F88F88FF8"
Data "8FF77778/88F2FF8"
Data "/888888///88888/"
Data 16,15
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "////////////////"
Data "///////888//////"
Data "/////88CCC88////"
Data "/////8FFCFF8////"
Data "/////8FFCFF88///"
Data "//8//8CCCCC82888"
Data "/8D888FFCFF82FF8"
Data "8DFF88FFCFF82FF8"
Data "/8FDD88888888888"
Data "/8888EEE8B9B9BF8"
Data "8FF78FFF8B9B9BF8"
Data "/888888888888888"

' explosion
Data 3
Data 8,7
Data "D6////FE"
Data "6FE6FE6D"
Data "/D6EE6D/"
Data "//6E6E//"
Data "/D6FE6D/"
Data "D6E6FE6D"
Data "ED////FE"
Data 8,7
Data "6D////D6"
Data "FE6//6FE"
Data "/6E//E6/"
Data "//D//D//"
Data "/DE//ED/"
Data "FE6//6EF"
Data "6D////D6"
Data 8,7
Data "ED////6E"
Data "6F6//6EF"
Data "/E////D/"
Data "////////"
Data "/F////6/"
Data "D6E//EFD"
Data "ED////DE"

' fire
Data 3
Data 8,7
Data "//D66D//"
Data "/E6DE66/"
Data "D6E66D6D"
Data "66D666E6"
Data "D66D666D"
Data "/6D66D6/"
Data "//D6E6//"
Data 8,7
Data "//E6E///"
Data "/66DEE6/"
Data "DDEE6DE/"
Data "66D6E6EE"
Data "EE6DED6E"
Data "/ED6EED/"
Data "//E6ED//"
Data 8,7
Data "//EEDE//"
Data "/ED6EED/"
Data "EDEEEDEE"
Data "E6D6EEED"
Data "DEEEE6EE"
Data "/6D6EED/"
Data "//EEED//"

' digleft
Data 1
Data 8,18
Data "//////00"
Data "////0000"
Data "///00000"
Data "//000000"
Data "//000000"
Data "/0000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "/0000000"
Data "//000000"
Data "//000000"
Data "///00000"
Data "/////00/"
Data "////00//"

' digright
Data 1
Data 8,18
Data "//00////"
Data "0000////"
Data "00000///"
Data "000000//"
Data "000000//"
Data "0000000/"
Data "00000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "00000000"
Data "0000000/"
Data "000000//"
Data "00000///"
Data "00000///"
Data "/00/////"
Data "00//////"

' digup
Data 1
Data 24,6
Data "/////////000000/////////"
Data "///////0000000000///////"
Data "//////0000000000000/////"
Data "///000000000000000000///"
Data "//000000000000000000////"
Data "////000000000000000000//"

' digdown
Data 1
Data 24,6
Data "///000000000000000000///"
Data "//000000000000000000////"
Data "////000000000000000000//"
Data "/////00000000000000/////"
Data "///////0000000000///////"
Data "/////////000000/////////"

GfxFont8x16:
Data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,126,129,165,129,129,189,153,129,126,0,0,0,0,0
Data 0,0,126,255,219,255,255,195,231,255,126,0,0,0,0,0
Data 0,0,0,54,127,127,127,127,62,28,8,0,0,0,0,0
Data 0,0,0,8,28,62,127,62,28,8,0,0,0,0,0,0
Data 0,0,24,60,60,231,231,231,24,24,60,0,0,0,0,0
Data 0,0,24,60,126,255,255,126,24,24,60,0,0,0,0,0
Data 0,0,0,0,0,24,60,60,24,0,0,0,0,0,0,0
Data 255,255,255,255,255,231,195,195,231,255,255,255,255,255,0,0
Data 0,0,0,0,60,102,66,66,102,60,0,0,0,0,0,0
Data 255,255,255,255,195,153,189,189,153,195,255,255,255,255,0,0
Data 0,0,15,7,13,25,60,102,102,102,60,0,0,0,0,0
Data 0,0,60,102,102,102,60,24,126,24,24,0,0,0,0,0
Data 0,0,63,51,63,48,48,48,112,240,224,0,0,0,0,0
Data 0,0,127,99,127,99,99,99,103,231,230,192,0,0,0,0
Data 0,0,24,24,219,60,231,60,219,24,24,0,0,0,0,0
Data 0,128,192,224,240,248,254,248,240,224,192,128,0,0,0,0
Data 0,2,6,14,30,62,254,62,30,14,6,2,0,0,0,0
Data 0,0,24,60,126,24,24,24,126,60,24,0,0,0,0,0
Data 0,0,102,102,102,102,102,102,102,0,102,102,0,0,0,0
Data 0,0,127,219,219,219,123,27,27,27,27,27,0,0,0,0
Data 0,124,198,96,56,108,198,198,108,56,12,198,124,0,0,0
Data 0,0,0,0,0,0,0,0,254,254,254,254,0,0,0,0
Data 0,0,24,60,126,24,24,24,126,60,24,126,0,0,0,0
Data 0,0,24,60,126,24,24,24,24,24,24,24,0,0,0,0
Data 0,0,24,24,24,24,24,24,24,126,60,24,0,0,0,0
Data 0,0,0,0,0,24,12,254,12,24,0,0,0,0,0,0
Data 0,0,0,0,0,48,96,254,96,48,0,0,0,0,0,0
Data 0,0,0,0,0,0,192,192,192,254,0,0,0,0,0,0
Data 0,0,0,0,0,36,102,255,102,36,0,0,0,0,0,0
Data 0,0,0,0,16,56,56,124,124,254,254,0,0,0,0,0
Data 0,0,0,0,254,254,124,124,56,56,16,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,24,60,60,60,24,24,0,24,24,0,0,0,0,0
Data 0,99,99,99,34,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,54,54,127,54,54,54,127,54,54,0,0,0,0,0
Data 12,12,62,99,97,96,62,3,67,99,62,12,12,0,0,0
Data 0,0,0,0,97,99,6,12,24,51,99,0,0,0,0,0
Data 0,0,28,54,54,28,59,110,102,102,59,0,0,0,0,0
Data 0,48,48,48,96,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,12,24,48,48,48,48,48,24,12,0,0,0,0,0
Data 0,0,24,12,6,6,6,6,6,12,24,0,0,0,0,0
Data 0,0,0,0,102,60,255,60,102,0,0,0,0,0,0,0
Data 0,0,0,24,24,24,255,24,24,24,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,24,24,24,48,0,0,0,0
Data 0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,24,24,0,0,0,0,0
Data 0,0,1,3,6,12,24,48,96,192,128,0,0,0,0,0
Data 0,0,126,231,231,239,247,231,231,231,126,0,0,0,0,0
Data 0,0,28,60,60,28,28,28,28,28,62,0,0,0,0,0
Data 0,0,126,239,239,239,15,126,224,255,255,0,0,0,0,0
Data 0,0,126,247,247,7,127,7,247,247,126,0,0,0,0,0
Data 0,0,15,15,47,111,255,15,15,15,15,0,0,0,0,0
Data 0,0,255,239,231,248,15,239,239,239,126,0,0,0,0,0
Data 0,0,126,239,239,224,254,239,239,239,126,0,0,0,0,0
Data 0,0,255,239,239,15,15,31,62,124,248,0,0,0,0,0
Data 0,0,126,231,231,231,126,231,231,231,126,0,0,0,0,0
Data 0,0,126,239,239,239,127,15,239,239,126,0,0,0,0,0
Data 0,0,0,24,24,0,0,0,24,24,0,0,0,0,0,0
Data 0,0,0,24,24,0,0,0,24,24,48,0,0,0,0,0
Data 0,0,6,12,24,48,96,48,24,12,6,0,0,0,0,0
Data 0,0,0,0,0,126,0,0,126,0,0,0,0,0,0,0
Data 0,0,96,48,24,12,6,12,24,48,96,0,0,0,0,0
Data 0,0,62,99,99,6,12,12,0,12,12,0,0,0,0,0
Data 0,0,62,99,99,111,111,111,110,96,62,0,0,0,0,0
Data 0,0,126,247,247,7,127,247,247,247,127,0,0,0,0,0
Data 0,0,254,239,239,238,252,238,239,239,254,0,0,0,0,0
Data 0,0,126,239,239,239,224,239,239,239,126,0,0,0,0,0
Data 0,0,254,239,239,239,239,239,239,239,254,0,0,0,0,0
Data 0,0,126,247,247,255,240,247,247,247,126,0,0,0,0,0
Data 0,0,126,247,247,247,240,255,240,240,240,0,0,0,0,0
Data 0,0,126,247,247,247,240,247,247,247,127,0,0,0,0,0
Data 0,0,231,231,231,231,255,231,231,231,231,0,0,0,0,0
Data 0,0,60,60,60,60,60,60,60,60,60,0,0,0,0,0
Data 0,0,15,15,15,15,15,239,239,239,126,0,0,0,0,0
Data 0,0,247,247,247,247,254,247,247,247,247,0,0,0,0,0
Data 0,0,240,240,240,240,240,240,247,247,247,0,0,0,0,0
Data 0,0,254,219,219,219,219,219,219,219,219,0,0,0,0,0
Data 0,0,254,239,239,239,239,239,239,239,239,0,0,0,0,0
Data 0,0,126,231,231,231,231,231,231,231,126,0,0,0,0,0
Data 0,0,254,251,251,251,254,240,240,240,240,0,0,0,0,0
Data 0,0,126,231,231,231,231,231,231,231,127,0,0,0,0,0
Data 0,0,254,239,239,239,254,239,239,239,239,0,0,0,0,0
Data 0,0,126,247,247,240,255,7,247,247,126,0,0,0,0,0
Data 0,0,240,255,240,240,240,247,247,247,126,0,0,0,0,0
Data 0,0,247,247,247,247,247,247,247,247,126,0,0,0,0,0
Data 0,0,247,247,247,247,247,247,247,118,60,0,0,0,0,0
Data 0,0,219,219,219,219,219,219,219,219,126,0,0,0,0,0
Data 0,0,247,247,119,55,126,236,238,239,239,0,0,0,0,0
Data 0,0,239,239,239,127,15,239,239,239,126,0,0,0,0,0
Data 0,0,255,247,239,222,189,123,247,239,255,0,0,0,0,0
Data 0,0,60,48,48,48,48,48,48,48,60,0,0,0,0,0
Data 0,0,64,96,112,56,28,14,7,3,1,0,0,0,0,0
Data 0,0,60,12,12,12,12,12,12,12,60,0,0,0,0,0
Data 8,28,54,99,0,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0,0,0,255,0,0,0
Data 24,24,12,0,0,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,62,111,15,63,111,63,0,0,0,0,0
Data 0,0,112,112,112,126,123,123,123,123,126,0,0,0,0,0
Data 0,0,0,0,0,62,123,120,123,123,62,0,0,0,0,0
Data 0,0,7,7,7,63,111,111,111,111,63,0,0,0,0,0
Data 0,0,0,0,0,62,123,127,120,123,62,0,0,0,0,0
Data 0,0,62,123,123,120,127,120,120,120,120,0,0,0,0,0
Data 0,0,0,0,0,62,119,119,119,63,7,119,119,62,0,0
Data 0,0,112,112,112,126,119,119,119,119,119,0,0,0,0,0
Data 0,0,28,28,0,28,28,28,28,28,28,0,0,0,0,0
Data 0,0,7,7,0,7,7,7,7,7,119,119,119,62,0,0
Data 0,0,112,112,112,119,119,126,119,119,119,0,0,0,0,0
Data 0,0,56,56,56,56,56,56,56,56,56,0,0,0,0,0
Data 0,0,0,0,0,254,219,219,219,219,219,0,0,0,0,0
Data 0,0,0,0,0,126,119,119,119,119,119,0,0,0,0,0
Data 0,0,0,0,0,62,119,119,119,119,62,0,0,0,0,0
Data 0,0,0,0,0,126,123,123,123,123,126,112,112,112,0,0
Data 0,0,0,0,0,63,111,111,111,111,63,7,7,7,0,0
Data 0,0,0,0,0,126,119,119,112,112,112,0,0,0,0,0
Data 0,0,0,0,0,62,96,127,3,123,62,0,0,0,0,0
Data 0,0,56,56,56,127,56,59,59,63,30,0,0,0,0,0
Data 0,0,0,0,0,119,119,119,119,119,63,0,0,0,0,0
Data 0,0,0,0,0,119,119,119,119,54,28,0,0,0,0,0
Data 0,0,0,0,0,219,219,219,219,219,126,0,0,0,0,0
Data 0,0,0,0,0,251,251,31,248,239,239,0,0,0,0,0
Data 0,0,0,0,0,119,119,119,63,7,119,119,119,62,0,0
Data 0,0,0,0,0,127,111,94,61,123,127,0,0,0,0,0
Data 0,0,14,24,24,24,112,24,24,24,14,0,0,0,0,0
Data 0,0,24,24,24,24,0,24,24,24,24,0,0,0,0,0
Data 0,0,112,24,24,24,28,24,24,24,112,0,0,0,0,0
Data 0,0,59,110,0,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,8,28,54,99,99,127,0,0,0,0,0,0
Data 0,0,30,51,97,96,96,97,51,30,6,3,62,0,0,0
Data 0,0,102,102,0,102,102,102,102,102,59,0,0,0,0,0
Data 0,6,12,24,0,62,99,127,96,99,62,0,0,0,0,0
Data 0,8,28,54,0,60,6,62,102,102,59,0,0,0,0,0
Data 0,0,102,102,0,60,6,62,102,102,59,0,0,0,0,0
Data 0,48,24,12,0,60,6,62,102,102,59,0,0,0,0,0
Data 0,28,54,28,0,60,6,62,102,102,59,0,0,0,0,0
Data 0,0,0,0,60,102,96,102,60,12,6,60,0,0,0,0
Data 0,8,28,54,0,62,99,127,96,99,62,0,0,0,0,0
Data 0,0,102,102,0,62,99,127,96,99,62,0,0,0,0,0
Data 0,48,24,12,0,62,99,127,96,99,62,0,0,0,0,0
Data 0,0,102,102,0,56,24,24,24,24,60,0,0,0,0,0
Data 0,24,60,102,0,56,24,24,24,24,60,0,0,0,0,0
Data 0,96,48,24,0,56,24,24,24,24,60,0,0,0,0,0
Data 0,99,99,8,28,54,99,99,127,99,99,0,0,0,0,0
Data 28,54,28,0,28,54,99,99,127,99,99,0,0,0,0,0
Data 12,24,48,0,127,51,48,62,48,51,127,0,0,0,0,0
Data 0,0,0,0,110,59,27,126,216,220,119,0,0,0,0,0
Data 0,0,31,54,102,102,127,102,102,102,103,0,0,0,0,0
Data 0,8,28,54,0,62,99,99,99,99,62,0,0,0,0,0
Data 0,0,99,99,0,62,99,99,99,99,62,0,0,0,0,0
Data 0,48,24,12,0,62,99,99,99,99,62,0,0,0,0,0
Data 0,24,60,102,0,102,102,102,102,102,59,0,0,0,0,0
Data 0,48,24,12,0,102,102,102,102,102,59,0,0,0,0,0
Data 0,0,99,99,0,99,99,99,99,63,3,6,60,0,0,0
Data 0,99,99,28,54,99,99,99,99,54,28,0,0,0,0,0
Data 0,99,99,0,99,99,99,99,99,99,62,0,0,0,0,0
Data 0,24,24,126,195,192,192,195,126,24,24,0,0,0,0,0
Data 0,28,54,50,48,120,48,48,48,115,126,0,0,0,0,0
Data 0,0,195,102,60,24,255,24,255,24,24,0,0,0,0,0
Data 0,252,102,102,124,98,102,111,102,102,243,0,0,0,0,0
Data 0,14,27,24,24,24,126,24,24,24,24,216,112,0,0,0
Data 0,12,24,48,0,60,6,62,102,102,59,0,0,0,0,0
Data 0,12,24,48,0,56,24,24,24,24,60,0,0,0,0,0
Data 0,12,24,48,0,62,99,99,99,99,62,0,0,0,0,0
Data 0,12,24,48,0,102,102,102,102,102,59,0,0,0,0,0
Data 0,0,59,110,0,110,51,51,51,51,51,0,0,0,0,0
Data 59,110,0,99,115,123,127,111,103,99,99,0,0,0,0,0
Data 0,60,108,108,62,0,126,0,0,0,0,0,0,0,0,0
Data 0,56,108,108,56,0,124,0,0,0,0,0,0,0,0,0
Data 0,0,24,24,0,24,24,48,99,99,62,0,0,0,0,0
Data 0,0,0,0,0,0,127,96,96,96,0,0,0,0,0,0
Data 0,0,0,0,0,0,127,3,3,3,0,0,0,0,0,0
Data 0,96,224,99,102,108,24,48,110,195,6,12,31,0,0,0
Data 0,96,224,99,102,108,24,51,103,207,31,3,3,0,0,0
Data 0,0,24,24,0,24,24,60,60,60,24,0,0,0,0,0
Data 0,0,0,0,27,54,108,54,27,0,0,0,0,0,0,0
Data 0,0,0,0,108,54,27,54,108,0,0,0,0,0,0,0
Data 130,16,130,16,130,16,130,16,130,16,130,16,130,16,130,16
Data 195,24,195,24,195,24,195,24,195,24,195,24,195,24,195,24
Data 216,131,218,19,216,131,218,19,216,131,218,19,216,131,218,19
Data 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
Data 24,24,24,24,24,24,24,248,24,24,24,24,24,24,24,24
Data 24,24,24,24,24,248,24,248,24,24,24,24,24,24,24,24
Data 54,54,54,54,54,54,54,246,54,54,54,54,54,54,54,54
Data 0,0,0,0,0,0,0,254,54,54,54,54,54,54,54,54
Data 0,0,0,0,0,248,24,248,24,24,24,24,24,24,24,24
Data 54,54,54,54,54,246,6,246,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,54,54,54,54,54,54,54,54,54,54,54
Data 0,0,0,0,0,254,6,246,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,246,6,254,0,0,0,0,0,0,0,0
Data 54,54,54,54,54,54,54,254,0,0,0,0,0,0,0,0
Data 24,24,24,24,24,248,24,248,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,248,24,24,24,24,24,24,24,24
Data 24,24,24,24,24,24,24,31,0,0,0,0,0,0,0,0
Data 24,24,24,24,24,24,24,255,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,255,24,24,24,24,24,24,24,24
Data 24,24,24,24,24,24,24,31,24,24,24,24,24,24,24,24
Data 0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0
Data 24,24,24,24,24,24,24,255,24,24,24,24,24,24,24,24
Data 24,24,24,24,24,31,24,31,24,24,24,24,24,24,24,24
Data 54,54,54,54,54,54,54,55,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,55,48,63,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,63,48,55,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,247,0,255,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,255,0,247,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,55,48,55,54,54,54,54,54,54,54,54
Data 0,0,0,0,0,255,0,255,0,0,0,0,0,0,0,0
Data 54,54,54,54,54,247,0,247,54,54,54,54,54,54,54,54
Data 24,24,24,24,24,255,0,255,0,0,0,0,0,0,0,0
Data 54,54,54,54,54,54,54,255,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,255,0,255,24,24,24,24,24,24,24,24
Data 0,0,0,0,0,0,0,255,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,54,54,63,0,0,0,0,0,0,0,0
Data 24,24,24,24,24,31,24,31,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,31,24,31,24,24,24,24,24,24,24,24
Data 0,0,0,0,0,0,0,63,54,54,54,54,54,54,54,54
Data 54,54,54,54,54,54,54,255,54,54,54,54,54,54,54,54
Data 24,24,24,24,24,255,24,255,24,24,24,24,24,24,24,24
Data 24,24,24,24,24,24,24,248,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,31,24,24,24,24,24,24,24,24
Data 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
Data 0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255
Data 240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
Data 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
Data 255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,59,110,108,108,110,59,0,0,0,0,0
Data 0,0,0,0,62,99,126,99,99,126,96,96,32,0,0,0
Data 0,0,127,99,99,96,96,96,96,96,96,0,0,0,0,0
Data 0,0,0,0,127,54,54,54,54,54,54,0,0,0,0,0
Data 0,0,127,99,48,24,12,24,48,99,127,0,0,0,0,0
Data 0,0,0,0,0,63,108,108,108,108,56,0,0,0,0,0
Data 0,0,0,0,51,51,51,51,62,48,48,96,0,0,0,0
Data 0,0,0,0,59,110,12,12,12,12,12,0,0,0,0,0
Data 0,0,126,24,60,102,102,102,60,24,126,0,0,0,0,0
Data 0,0,28,54,99,99,127,99,99,54,28,0,0,0,0,0
Data 0,0,28,54,99,99,99,54,54,54,119,0,0,0,0,0
Data 0,0,30,48,24,12,62,102,102,102,60,0,0,0,0,0
Data 0,0,0,0,0,126,219,219,126,0,0,0,0,0,0,0
Data 0,0,3,6,126,219,219,243,126,96,192,0,0,0,0,0
Data 0,0,28,48,96,96,124,96,96,48,28,0,0,0,0,0
Data 0,0,0,62,99,99,99,99,99,99,99,0,0,0,0,0
Data 0,0,0,127,0,0,127,0,0,127,0,0,0,0,0,0
Data 0,0,24,24,24,255,24,24,24,0,255,0,0,0,0,0
Data 0,0,48,24,12,6,12,24,48,0,126,0,0,0,0,0
Data 0,0,12,24,48,96,48,24,12,0,126,0,0,0,0,0
Data 0,0,14,27,27,24,24,24,24,24,24,24,24,24,0,0
Data 24,24,24,24,24,24,24,24,216,216,112,0,0,0,0,0
Data 0,0,24,24,0,0,255,0,0,24,24,0,0,0,0,0
Data 0,0,0,0,59,110,0,59,110,0,0,0,0,0,0,0
Data 0,56,108,108,56,0,0,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,24,24,0,0,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,24,0,0,0,0,0,0,0,0
Data 0,15,12,12,12,12,12,236,108,60,28,0,0,0,0,0
Data 0,216,108,108,108,108,108,0,0,0,0,0,0,0,0,0
Data 0,112,216,48,96,200,248,0,0,0,0,0,0,0,0,0
Data 0,0,0,0,62,62,62,62,62,62,0,0,0,0,0,0
Data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Rem $STATIC
Sub ADD (obj, cx, cy)
    GETCELLCOORDS cx, cy, x, y
    Select Case obj
        Case newnobbin
            enemyc = enemyc + 1
            enemy(enemyc).x = x
            enemy(enemyc).y = y
            enemy(enemyc).stpx = x
            enemy(enemyc).stpy = y
            enemy(enemyc).trgx = cx
            enemy(enemyc).trgy = cy
            enemy(enemyc).mode = enm.nobbin
            enemy(enemyc).thob.starttime = Timer
            enemy(enemyc).thob.interval = tim.nobbin
            enemy(enemyc).pic.sequence = ani.nobbin
            enemy(enemyc).pic.frame = 0
        Case newdecor
            decorc = decorc + 1
            decor(decorc).x = x
            decor(decorc).y = y + 1
            decor(decorc).use = TRUE
            decor(decorc).mode = 0
            decor(decorc).pic.sequence = ani.decor
            decor(decorc).pic.frame = Int(Rnd * anim(ani.decor, framec))
            DRAWPIC decor(decorc).x, decor(decorc).y, decor(decorc).pic, FALSE
        Case newbag
            bagc = bagc + 1
            bag(bagc).x = x
            bag(bagc).y = y
            bag(bagc).mode = gld.normal
            bag(bagc).use = TRUE
            bag(bagc).misc = 0
            bag(bagc).fally = 0
            bag(bagc).pic.sequence = ani.bag
            DRAWPIC x, y, bag(bagc).pic, FALSE
        Case newgift
            giftc = giftc + 1
            gift(giftc).x = x
            gift(giftc).y = y
            gift(giftc).pic.sequence = ani.coins
            gift(giftc).pic.frame = -1
            gift(giftc).t.interval = 10
            gift(giftc).t.starttime = Timer
    End Select
End Sub

Sub ADDSCORE (amount)
    Static addition As Long
    Static t As TIMEINT
    Static newlife As Long
    Static palflag
    t.interval = .01
    If amount < 0 Then
        digger.score = digger.score + addition
        SHOWSCORE digger.score, digger.lives
        addition = 0
        Exit Sub
    End If
    addition = addition + amount
    If TEVENT(t) Then
        If digger.score = 0 Then newlife = lifecost
        If palflag >= 1 Then
            palflag = palflag - 1
            If palflag = 0 Then
                If partymode Then SETPAL pal.party Else SETPAL pal.normal
            End If
        End If
        If digger.score + addition >= newlife Then
            Palette 0, 63 ' snow-white
            palflag = 3
            newlife = newlife + lifecost
            If digger.lives < 9 Then digger.lives = digger.lives + 1
        End If
        For i = 1 To addition \ 5 + 1
            If addition <= 0 Then Exit For
            addition = addition - 1
            digger.score = digger.score + 1
        Next
    End If
End Sub

Sub ANIMATE (p As PICPAR)
    p.frame = (p.frame + 1) Mod anim(p.sequence, framec)
End Sub

Function BOXCOLL (x, y, w, h, ax, ay, aw, ah)
    x2 = x + w - 1
    y2 = y + h - 1
    ax2 = ax + aw - 1
    ay2 = ay + ah - 1
    If x > ax Then xr1 = x Else xr1 = ax
    If y > ay Then yr1 = y Else yr1 = ay
    If x2 < ax2 Then xr2 = x2 Else xr2 = ax2
    If y2 < ay2 Then yr2 = y2 Else yr2 = ay2
    If xr2 - xr1 < 0 Or yr2 - yr1 < 0 Then BOXCOLL = FALSE Else BOXCOLL = TRUE
End Function

Sub CELEBRATE Static
    Static initflag, n, wind
    Static ts As TIMEINT
    Const x = 1, y = 2, v = 3
    ts.interval = .045
    Select Case partystyle
        Case ps.whitebgr, ps.brightbgr
            If partymode = TRUE Then
                s! = (party.t.interval - (Timer - party.t.starttime)) * 2
                If s! < 9 And Abs(Int(s!) - s!) < .2 Then SETPAL s! Mod 2
            End If
        Case ps.snowing
            If snowready = FALSE Then
                If partymode = FALSE Then Exit Sub
                ReDim snowbuf(0 To snowc, 1 To 3) As Single
                snowready = TRUE
                h = 1
                For i = 0 To snowc
                    GoSub newflake
                Next
            Else
                If Not TEVENT(ts) Then Exit Sub
                If Int(Rnd * 200) = 10 Then wind = Rnd * 1 - .5
                h = 10
                For i = 0 To snowc
                    If snowbuf(i, v) = TRUE Then
                        If Point(snowbuf(i, x), snowbuf(i, y)) = 15 Then
                            PSet (snowbuf(i, x), snowbuf(i, y)), 0
                        End If
                    End If
                    snowbuf(i, x) = snowbuf(i, x) + Rnd * 4 - 2 + wind
                    snowbuf(i, y) = snowbuf(i, y) + Rnd * 2 + .5
                    If snowbuf(i, x) > f.w Or snowbuf(i, x) < 0 Or snowbuf(i, y) > f.h Then
                        If (party.t.interval + party.t.starttime - Timer) > 7 Then GoSub newflake
                    End If
                    If partymode = TRUE And Point(snowbuf(i, x), snowbuf(i, y)) = 0 Then
                        PSet (snowbuf(i, x), snowbuf(i, y)), 15
                        snowbuf(i, v) = TRUE
                    Else
                        snowbuf(i, v) = FALSE
                    End If
                Next
                snowready = partymode
                If snowready = FALSE Then Erase snowbuf
            End If
    End Select
    Exit Sub
    newflake:
    snowbuf(i, x) = Rnd * f.w
    snowbuf(i, y) = Rnd * f.h / h
    snowbuf(i, v) = FALSE
    Return
End Sub

Function CHECKBAGSHIFT (x, y, dir)
    For i = 1 To bagc
        If BOXCOLL(x + dir, y, imgw, imgh, bag(i).x, bag(i).y, cellw - 1, cellh) Then
            If bag(i).mode = bagm.normal And dir <> 0 Then r = SHIFTBAG(i, dir * diggerspeedx)
            CHECKBAGSHIFT = TRUE
            Exit Function
        End If
    Next
    CHECKBAGSHIFT = FALSE
End Function

Sub CHECKDECORS (plx, ply, scoreflag)
    For i = decorc To 1 Step -1
        If decor(i).use And BOXCOLL(plx, ply, imgw, imgh, decor(i).x, decor(i).y, ornw, ornh) Then
            If scoreflag Then
                ADDSCORE 25
                consorn = consorn + 1
                tcons.starttime = Timer
                If consorn = 8 Then ADDSCORE 250: consorn = 0
                PLAYSOUND snd.decor
            End If
            ERASEPIC decor(i).x, decor(i).y, decor(i).pic
            REDRAW decor(i).x, decor(i).y, bag(), bagc
            REDRAW decor(i).x, decor(i).y, gift(), giftc
            Swap decor(decorc), decor(i)
            decorc = decorc - 1
        End If
    Next
End Sub

Sub CHECKGIFT (plx, ply, scoreflag)
    For i = giftc To 1 Step -1
        If BOXCOLL(plx, ply, imgw + 2, imgh + 2, gift(i).x, gift(i).y + imgh * .4, imgw + 3, imgh * (1 - .4)) Then
            If scoreflag Then ADDSCORE 500
            PLAYSOUND snd.gift
            ERASEPIC gift(i).x, gift(i).y, gift(i).pic
            REDRAW gift(i).x, gift(i).y, bag(), bagc
            REDRAW gift(i).x, gift(i).y, decor(), decorc
            Swap gift(giftc), gift(i)
            giftc = giftc - 1
        End If
    Next
End Sub

Sub CHECKHISCORE (score As Long, gameresult)
    If score > hiscore(hiscorec - 1).score Then
        For i = 0 To hiscorec - 1
            If hiscore(i).score < score Then
                For j = hiscorec - 1 To i + 1 Step -1
                    hiscore(j) = hiscore(j - 1)
                Next
                hiscore(i).score = score
                View
                cw = 8: ch = 14
                Line (cw * 10 + 2, ch * 4)-Step(cw * 22 + 1, ch * 6 + 1), 8, BF
                If gameresult = gr.gameover Then
                    Color 1
                    TEXTOUT 6, 12, "   GAME OVER!   ", -2
                ElseIf gameresult = gr.winner Then
                    Color 13
                    TEXTOUT 6, 12, "CONGRATULATIONS!", -2
                Else
                    Color 7
                    TEXTOUT 6, 12, "  HIGH SCORE!!  ", -2
                End If
                Color 7
                Line (cw * 10 + 2 + 2, ch * 4 + 2)-Step(cw * 22 - 3, ch * 6 - 3), , B
                TEXTOUT 8, 12, "Enter your name:", -2
                TEXTOUT 9, 13, String$(namelen, "."), -2
                Do
                    Do: K$ = InKey$: Loop While Len(K$) = 0
                    Select Case Asc(K$)
                        Case Is >= 32: If Len(name$) < namelen Then name$ = name$ + K$
                        Case 8: If Len(name$) > 0 Then name$ = Left$(name$, Len(name$) - 1)
                    End Select
                    TEXTOUT 9, 13, name$ + String$(namelen - Len(name$), "."), -2
                Loop Until K$ = Chr$(13)
                hiscore(i).uname = name$ + Space$(namelen - Len(name$))
                UPDATESCORES
                Exit For
            End If
        Next
    End If
End Sub

Sub CHECKKILL
    Const d = 2
    For i = enemyc To 1 Step -1
        If (enemy(i).mode = enm.hobbin Or enemy(i).mode = enm.nobbin) And BOXCOLL(enemy(i).x + d, enemy(i).y + d, imgw - d * 2, imgh - d * 2, digger.x, digger.y, imgw, imgh) Then
            If Not partymode Then
                gamestate = gs.killed
                For j = 1 To enemyc
                    ERASEPIC enemy(j).x - 1, enemy(j).y, enemy(j).pic
                Next
                ERASEPIC digger.x, digger.y, digger.pic
                digger.pic.sequence = ani.dgrdie
                digger.pic.frame = -1
                digger.mode = dgr.dead
                PLAYSOUND snd.dead
                Exit For
            Else
                ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                Swap enemy(i), enemy(enemyc)
                enemyc = enemyc - 1
                bonusscore = bonusscore + 250
                ADDSCORE bonusscore
            End If
        End If
    Next
End Sub

Sub CHECKPARTY (x, y, scoreflag)
    If party.use Then
        bx = party.x
        by = party.y
        If BOXCOLL(x, y, imgw, imgh, bx, by, imgw, imgh) Then
            ERASEIMG bx, by, anim(ani.party, img1)
            REDRAW bx, by, bag(), bagc
            REDRAW bx, by, decor(), decorc
            REDRAW bx, by, gift(), giftc
            partymode = TRUE
            snowready = FALSE
            party.use = FALSE
            party.t.starttime = Timer
            If scoreflag Then ADDSCORE 1000
            SETPAL pal.party
        Else
            DRAWIMG bx, by, anim(ani.party, img1), TRUE
        End If
    End If
End Sub

Sub CLOSELEVEL
    If levelpack$ <> "" Then Close #1
End Sub

Sub COLLAPSE
    Const y = 1, c = 2, x = 3
    Const count = 5, skip = 3
    Dim p(319, 1 To count, 1 To 3)
    Dim c(319)
    Dim h(319)
    Dim t(319)

    For i = 0 To 319
        h(i) = 190
        t(i) = 191
        c(i) = 0
    Next

    Do
        done = TRUE
        For i = 0 To 319
            If h(i) >= 0 Then
                If c(i) < count And Rnd * 10 < 8 Then
                    For j = 1 To skip - 1
                        PSet (i, h(i)), 0
                        h(i) = h(i) - 1
                    Next
                    Do While Point(i, h(i)) = 0: h(i) = h(i) - 1: Loop
                    If h(i) >= 0 Then
                        c(i) = c(i) + 1
                        p(i, c(i), y) = h(i)
                        p(i, c(i), c) = Point(i, h(i))
                        p(i, c(i), x) = i
                    End If
                End If
                done = FALSE
            End If
            If c(i) <> 0 Then done = FALSE
            For j = c(i) To 1 Step -1
                a = Len(InKey$)
                newy = p(i, j, y) + Rnd * 4 + 1
                x1 = p(i, j, x)
             
                If newy >= t(x1) Then
                    If p(i, j, y) < t(x1) Then PSet (x1, p(i, j, y)), 0
                    If x1 > 0 And x1 < 319 Then
                        newv = (t(x1 - 1) + t(x1 + 1)) / 2
                        If newv > t(x1) Then t(x1) = newv
                        t(x1) = t(x1) - 1
                    End If
                    PSet (x1, t(x1)), p(i, j, c)
                    Swap p(i, c(i), y), p(i, j, y)
                    Swap p(i, c(i), c), p(i, j, c)
                    Swap p(i, c(i), x), p(i, j, x)
                    c(i) = c(i) - 1
                Else
                    PSet (x1, p(i, j, y)), 0
                    p(i, j, x) = x1 + Rnd * 4 - 2
                    If p(i, j, x) < 0 Then p(i, j, x) = 0
                    If p(i, j, x) > 319 Then p(i, j, x) = 319
                    p(i, j, y) = newy
                    PSet (p(i, j, x), p(i, j, y)), p(i, j, c)
                End If
            Next
        Next
    Loop Until done
End Sub

Sub DELAY (sec!)
    ct! = Timer
    Do Until ct! + sec! <= Timer Or Abs(ct! - Timer) > 1000: a = Len(InKey$): Loop
End Sub

Sub DRAWHOLE (x, y)
    SCANMAZECELL x, y, 0, l, r, u, d
    SCANMAZECELL x + 1, y, rc, 0, 0, 0, 0
    SCANMAZECELL x - 1, y, lc, 0, 0, 0, 0
    SCANMAZECELL x, y + 1, dc, 0, 0, 0, 0
    SCANMAZECELL x, y - 1, uc, 0, 0, 0, 0
    GETCELLCOORDS x, y, cx, cy
    If l = FALSE Or (x = 0 And (y = 0 Or y = mazey - 1 Or r = FALSE)) Then
        For i = cx - 5 To cx + 10 Step diggerspeedx
            DRAWIMG i, cy - 1, iblob.left, FALSE
        Next
    End If
    If r = FALSE Or (x = mazex - 1 And (y = 0 Or y = mazey - 1 Or l = FALSE)) Then
        If lc = mz.empty Then delta = 1 Else delta = 0
        For i = cx + 10 + 1 - diggerspeedx * (3 + delta) To cx + 10 + 1 Step diggerspeedx
            DRAWIMG i, cy - 1, iblob.right, FALSE
        Next
    End If
    If u = FALSE Or (y = 0 And (x = mazex - 1 Or x = 0)) Then
        If uc = FALSE Then delta = 1 Else delta = 0
        For i = cy - 3 - diggerspeedy * delta To cy - 3 + diggerspeedy * 4 Step diggerspeedy
            DRAWIMG cx - 5, i, iblob.up, FALSE
        Next
    End If
    If d = FALSE Or (y = 0 And (x = mazex - 1 Or x = 0)) Then
        If dc = mz.empty And u = FALSE Then delta = 1 Else delta = 0
        For i = cy + 12 - diggerspeedy * (4) To cy + 12 + diggerspeedy * delta Step diggerspeedy
            DRAWIMG cx - 5, i, iblob.down, FALSE
        Next
    End If
End Sub

Sub DRAWIMG (x, y, imgn, disablemask)
    If Not disablemask Then Put (x, y), graph(img(imgn, mask)), And
    Put (x, y), graph(img(imgn, pic)), Or
End Sub

Sub DRAWMAP
    Const cw = 3, ch = 3
    Const mvx = 639 - mazex * cw, mvy = 349 - mazey * ch
    View (mvx, mvy)-(mvx + mazex * cw, mvy + mazey * ch)
    For i = 0 To mazex - 1
        For j = 0 To mazey - 1
            SCANMAZECELL i, j, inner, lw, rw, uw, dw
            Select Case inner
                Case mz.filled: col = 1
                Case mz.half: col = 13
                Case mz.empty: col = 8
            End Select
            Line (i * cw + 1, j * ch + 1)-Step(cw - 2, ch - 2), col, B
            If uw Then col = 9 Else col = 8
            Line (i * cw, j * ch)-Step(cw, 0), col
            If dw Then col = 9 Else col = 8
            Line (i * cw, j * ch + ch)-Step(cw, 0), col
            If lw Then col = 9 Else col = 8
            Line (i * cw, j * ch)-Step(0, ch), col
            If rw Then col = 9 Else col = 8
            Line (i * cw + cw, j * ch)-Step(0, ch), col
        Next
    Next
    RESTOREFIELD
End Sub

Sub DRAWPIC (x, y, p As PICPAR, disablemask)
    If p.frame >= 0 Then DRAWIMG x, y, anim(p.sequence, img1) + p.frame, disablemask
End Sub

Sub ERASEIMG (x, y, im)
    Put (x, y), graph(img(im, mask)), And
End Sub

Sub ERASEPIC (x, y, p As PICPAR)
    ERASEIMG x, y, anim(p.sequence, img1) + p.frame
End Sub

Sub FADELEVEL
    Dim s As Single
    Static speed As Single
    Const w = 16
    If speed = 0 Then
        btime# = Timer
        Do
            speed = speed + 1
            For s = 1 To 100: Next
            n = (n + 1) Mod 100
            If n = 0 Then If Timer - btime# >= .1 Then Exit Do
        Loop
        Exit Sub
    End If
    Select Case Int(Rnd * 20)
        Case Is < 5
            siz = IMGSIZE(f.w, f.h)
            Dim bb(siz)
            Dim bb2(siz)
            For i = f.w / w - 1 To 0 Step -1
                Screen , , 1, 0
                Get (0, 0)-Step(f.w - i * w - 1, f.h - 1), bb()
                Screen , , 0, 0
                Get (w - 1, 0)-Step(i * w, f.h - 1), bb2()
                RETRACE
                Put (0, 0), bb2(), PSet
                Put (i * w, 0), bb(), PSet
                For s = 1 To speed / (f.w / w): For z! = 1 To 10: Next: Next
            Next
        Case Else
            siz = IMGSIZE(w, f.h)
            Dim bb(siz)
            For i = f.w / w - 1 To 0 Step -1
                Screen , , 1, 0
                Get (i * w, 0)-Step(w - 1, f.h - 1), bb()
                Screen , , 0, 0
                RETRACE
                Put (i * w, 0), bb(), PSet
                Line (i * w - 1, 0)-Step(0, f.h), 8
                For s = 1 To speed / (f.w / w): For z! = 1 To 10: Next: Next
            Next
    End Select
    Screen , , 1, 0
    Cls
    Screen 9, 1, 0, 0
    Screen 9
End Sub

Sub FILLBGR (num)
    n = anim(ani.bgrs, img1) + num
    GETIMAGE n, w, h, idx
    For y = 0 To f.h - 1 Step h
        For x = 0 To f.w - 1 Step w
            Put (x, y), graph(idx), PSet
        Next
    Next
End Sub

Sub FILLMAZECELL (x, y, i, l, r, u, d)
    If x < 0 Or y < 0 Or x > mazex - 1 Or y > mazey - 1 Then Exit Sub
    x2 = x * 2
    y2 = y * 2
    If i <> OLD Then
        Select Case i
            Case mz.init: maze(x2, y2) = mz.filled
            Case mz.filled: If maze(x2, y2) <> mz.empty And maze(x2, y2) <> mz.half Then maze(x2, y2) = i
            Case mz.half: If maze(x2, y2) <> mz.empty Then maze(x2, y2) = i
            Case mz.empty: maze(x2, y2) = i
        End Select
    End If
    If l <> OLD Then
        If x2 <> 0 Then maze(x2 - 1, y2) = l Else maze(x2 - 1, y2) = TRUE
    End If
    If r <> OLD Then
        If x2 <> (mazex - 1) * 2 Then maze(x2 + 1, y2) = r Else maze(x2 + 1, y2) = TRUE
    End If
    If u <> OLD Then
        If y2 <> 0 Then maze(x2, y2 - 1) = u Else maze(x2, y2 - 1) = TRUE
    End If
    If d <> OLD Then
        If y2 <> (mazey - 1) * 2 Then maze(x2, y2 + 1) = d Else maze(x2, y2 + 1) = TRUE
    End If
    If mapon Then DRAWMAP
End Sub

Sub GETCELLCOORDS (x, y, rx, ry)
    rx = x * cellw + viewx
    ry = y * cellh + viewy
End Sub

Sub GETIMAGE (i, x, y, idx)
    idx = img(i, pic)
    Def Seg = VarSeg(graph(idx))
    x = Peek(VarPtr(graph(idx)))
    y = Peek(VarPtr(graph(idx)) + 2)
    Def Seg
End Sub

Sub GETINPUTS
    Static cheat$, i$
    Static tch As TIMEINT
    Static tctl As TIMEINT
    Dim intenemy(6) As Double
    Dim intgift(6) As Double
    Dim intparty As Double
    tctl.interval = .045
    tch.interval = 1
    z$ = InKey$: If z$ <> "" Then i$ = z$
    If gamestate <> gs.play Then i$ = ""
    If z$ = Chr$(0) + Chr$(59) Then
        If gamestate = gs.play Then
            gamestate = gs.pause
            While InKey$ <> "": Wend
            intparty = Timer - party.t.starttime
            For i = 1 To enemyc
                intenemy(i) = Timer - enemy(i).thob.starttime
            Next
            For i = 1 To giftc
                intgift(i) = Timer - gift(i).t.starttime
            Next
            Do
                ink$ = InKey$
                If ink$ = Chr$(0) + Chr$(62) Then SCREENSHOT
            Loop Until ink$ = Chr$(0) + Chr$(59)
            party.t.starttime = Timer - intparty
            For i = 1 To enemyc
                enemy(i).thob.starttime = Timer - intenemy(i)
            Next
            For i = 1 To giftc
                gift(i).t.starttime = Timer - intgift(i)
            Next
            gamestate = gs.play
        End If
    Else
        Select Case z$
            Case Chr$(0) + Chr$(68), Chr$(27): gamestate = gs.quit: gameresult = gr.abort
            Case Chr$(0) + Chr$(63): gamestate = gs.newgame
            Case Chr$(0) + Chr$(66): nosound = Not nosound
            Case Chr$(0) + Chr$(62): SCREENSHOT
            Case Chr$(0) + Chr$(65): noretrace = Not noretrace
            Case Chr$(0) + Chr$(83): If shotc > 0 Then Kill "ams*.bsv": shotc = 0
            Case Chr$(32), Chr$(0) + Chr$(82), "0"
                If gamestate = gs.play Then
                    GETMAZECELL digger.x, digger.y, dx, dy
                    SCANMAZECELL dx, dy, l, 0, 0, 0, 0
                    u = l
                    SCANMAZECELL dx + 1, dy, r, 0, 0, 0, 0
                    SCANMAZECELL dx, dy + 1, d, 0, 0, 0, 0
                    l = (l = mz.empty)
                    d = (d = mz.empty)
                    u = (u = mz.empty)
                    r = (r = mz.empty)
                    IF (digger.mode = dgr.left AND digger.x > imgw AND l) OR (digger.mode = dgr.up AND digger.y > imgh AND u) OR (digger.mode = dgr.right AND digger.x < f.w - imgw * 2 AND r) OR (digger.mode = dgr.down AND digger.y < f.h - imgh * 2 AND d) THEN _

                        If digger.eye Then
                            digger.eye = FALSE
                            digger.teye.starttime = Timer
                            Select Case digger.mode
                                Case dgr.left: SHOOT -1, 0
                                Case dgr.right: SHOOT 1, 0
                                Case dgr.up: SHOOT 0, -1
                                Case dgr.down: SHOOT 0, 1
                            End Select
                            ERASEPIC digger.x, digger.y, digger.pic
                            digger.pic.sequence = digger.pic.sequence + anid.withouteye
                            DRAWPIC digger.x, digger.y, digger.pic, TRUE
                        End If
                    End If
                End If
        End Select
    End If
    
    If gamestate = gs.play And (z$ >= "a" And z$ <= "z") Or (z$ >= "0" And z$ <= "9") Then
        tch.starttime = Timer
        cheat$ = cheat$ + z$
        Select Case cheat$
            Case "mazedebug": mapon = Not mapon: cheat$ = ""
            Case "afterlong":
                Color 8
                Locate 21, 70
                Input li
                curlevel = li
                LOADLEVEL li
                cheat$ = ""
                Exit Sub
            Case "thecure": digger.lives = 9: cheat$ = ""
            Case "bfg9000": digger.teye.interval = 0: digger.eye = TRUE: cheat$ = ""
            Case "trace": DRAWMAP: cheat$ = ""
        End Select
    Else
        If z$ <> "" Then
            cheat$ = ""
        ElseIf TEVENT(tch) Then
            cheat$ = ""
        End If
        If TEVENT(tctl) And gamestate = gs.play Then
            Select Case i$
                Case Chr$(0) + Chr$(72): MOVEDIGGER 0, -1
                Case Chr$(0) + Chr$(75): MOVEDIGGER -1, 0
                Case Chr$(0) + Chr$(80): MOVEDIGGER 0, 1
                Case Chr$(0) + Chr$(77): MOVEDIGGER 1, 0
            End Select
            i$ = ""
            If Not digger.eye Then
                If TEVENT(digger.teye) Then
                    digger.eye = TRUE
                    ERASEPIC digger.x, digger.y, digger.pic
                    digger.pic.sequence = digger.pic.sequence - anid.withouteye
                    DRAWPIC digger.x, digger.y, digger.pic, TRUE
                End If
            End If
        End If
    End If
End Sub

Function GETLEVIDX$ (num)
    If levelpack$ = "" Then
        GETLEVIDX$ = NUMTOSTR$(levidx(num) + 0)
    Else
        GETLEVIDX$ = NUMTOSTR$(num + 0)
    End If
End Function

Sub GETMAZECELL (x, y, rx, ry)
    If x - viewx < 0 Then
        rx = -1
    Else
        rx = (x - viewx) \ cellw
    End If
    If y - viewy < 0 Then
        ry = -1
    Else
        ry = (y - viewy) \ cellh
    End If
End Sub

Function GETPATH (sx, sy, tx, ty, pl) Static
    Const x = 0, y = 1, size = mazex * mazey
    Dim d(3, 1), wl(3)
    Dim mzf(mazex, mazey)
    Dim pp(size, 1, 0 To 1)
    Dim bx(20), by(20)

    For i = 0 To mazex - 1
        For j = 0 To mazey - 1
            mzf(i, j) = 0
        Next
    Next

    dc = 4
    d(0, x) = -1: d(0, y) = 0
    d(1, x) = 1: d(1, y) = 0
    d(2, x) = 0: d(2, y) = -1
    d(3, x) = 0: d(3, y) = 1

    pf = 1
    pp(0, x, 0) = tx
    pp(0, y, 0) = ty
    pc1 = 1
    w = 0
    mzf(tx, ty) = w + 1
    For j = 1 To bagc: GETMAZECELL bag(j).x, bag(j).y, bx(j), by(j): Next
    Do
        w = w + 1
        If pf = 0 Then
            pf = 1
            pf2 = 0
        Else
            pf = 0
            pf2 = 1
        End If
        pc = pc1
        pc1 = 0
        fw = FALSE
        For i = 0 To pc - 1
            SCANMAZECELL pp(i, x, pf), pp(i, y, pf), 0, wl(0), wl(1), wl(2), wl(3)
            For j = 1 To bagc
                If bx(j) = pp(i, x, pf) And by(j) = pp(i, y, pf) Then
                    ' it's not only means that enemies won't try to break
                    ' through bag when it can't be moved, it also
                    ' means that enemies will avoid falling bags (cause
                    ' they never (or very-very seldom) enter deadlocks).
                    wl(2) = TRUE
                    wl(3) = TRUE
                    Exit For
                End If
            Next
            For dr = 0 To dc - 1
                x1 = pp(i, x, pf) + d(dr, x)
                y1 = pp(i, y, pf) + d(dr, y)
                If x1 >= 0 And y1 >= 0 And x1 <= mazex - 1 And y1 <= mazey - 1 Then
                    If mzf(x1, y1) = 0 Then
                        SCANMAZECELL x1, y1, v, 0, 0, 0, 0
                        If wl(dr) = FALSE And v = mz.empty Then
                            If x1 = sx And y1 = sy Then
                                Select Case dr
                                    Case 0: dirc = 1
                                    Case 1: dirc = 0
                                    Case 2: dirc = 3
                                    Case 3: dirc = 2
                                End Select
                                pl = w
                                GETPATH = dirc
                                GoTo exitfunc
                            End If
                            pp(pc1, x, pf2) = x1
                            pp(pc1, y, pf2) = y1
                            mzf(x1, y1) = w + 1
                            pc1 = pc1 + 1
                        End If
                    End If
                End If
            Next
        Next
    Loop Until pc1 = 0
    pl = -1
    GETPATH = -1
    GoTo exitfunc
    exitfunc:
    Exit Function
    DRW:
    Const cw = 5, ch = 5
    Const mvx = 639 - mazex * cw, mvy = 349 - mazey * ch
    View (mvx, mvy)-(mvx + mazex * cw, mvy + mazey * ch)
    For q = 0 To mazex - 1
        For j = 0 To mazey - 1
            Select Case mzf(q, j)
                Case Is = 0: col = 1
                Case Is <> 0: col = 7
            End Select
            Line (q * cw, j * ch)-Step(cw, ch), col, BF
        Next
    Next
    RESTOREFIELD
    Return
End Function

Sub GETRANDOMCELL (dx, dy)
    Do
        dx = Int(Rnd * mazex)
        dy = Int(Rnd * mazey)
        SCANMAZECELL dx, dy, v, 0, 0, 0, 0
    Loop Until v = mz.empty
End Sub

Function IMGSIZE (w, h) Static
    size = (4 + Int((w + 7) / 8) * 4 * h - 1) \ 2 + 1
    IMGSIZE = size
End Function

Sub INIT
    Out &H60, &HF3
    s! = Timer: Do: Loop While s! + .2 > Timer
    Out &H60, 0
    s! = Timer: Do: Loop While s! + .2 > Timer
    For i = 1 To 10: temp = Inp(&H60): Next
    Randomize Timer
    Screen scrmode
    _AllowFullScreen _SquarePixels , _Smooth

    levelpal = 7
    If UCase$(Command$) <> "/I" Then levelpack$ = Command$
    nosound = TRUE
    noretrace = TRUE
    partystyle = ps.snowing
    snowc = 200
    READINI

    SETPAL pal.normal
    LOADFONT
    Color 7
    FADELEVEL ' to initialize speed constant, nothing else will be done
    LOADLEVIDX
    LOADGRAPHICS
    SHOWHINTS
    LOADSCORES hiscorefile, hiscore()
End Sub

Sub INITDIGGER
    digger.dx = -1
    digger.pic.sequence = ani.dgrleft: digger.mode = dgr.left
    digger.eye = TRUE
    digger.x = digger.startx
    digger.y = digger.starty
End Sub

Sub LOADFONT
    Restore GfxFont8x16
    For i = 0 To 255
        For j = 0 To 15
            Read ch
            font(i, j) = Chr$(ch)
        Next
    Next
End Sub

Sub LOADGRAPHICS
    Screen , , 1, 0
    graphindex = 0
    animc = 0
    Restore DataGfx
    For i = 1 To 30
        Read framecount
        anim(animc, framec) = framecount
        anim(animc, img1) = imgc
        animc = animc + 1
        For f = 1 To framecount
            LOADIMAGE w, h
            img(imgc, pic) = graphindex
            Get (0, 0)-(w - 1, h - 1), graph(graphindex)
            graphindex = graphindex + IMGSIZE(w, h) * 2
            img(imgc, mask) = graphindex
            Get (0 + w, 0)-(w - 1 + w, h - 1), graph(graphindex)
            graphindex = graphindex + IMGSIZE(w, h) * 2
            imgc = imgc + 1
        Next
    Next
    bgrc = anim(ani.bgrs, framec)
    curbgr = -1
    Screen , , 0, 0
    Cls
End Sub

Sub LOADIMAGE (w, h)
    Read w, h
    For y = 0 To h - 1
        Read B$
        For x = 0 To w - 1
            ch$ = Mid$(B$, x + 1, 1)
            c1 = 0
            Select Case ch$
                Case "0" To "9", "A" To "F": c = Val("&H" + ch$): c1 = 0
                Case "/": c = 0: c1 = 15
            End Select
            PSet (x, y), c
            PSet (x + w, y), c1
        Next
    Next
End Sub

Sub LOADLEVEL (levidx As Integer)
    If Not OPENLEVEL(GETLEVIDX$(levidx)) Then
        For i = 1 To digger.lives
            ADDSCORE 1000
        Next
        gameresult = gr.winner
        gamestate = gs.newgame
    Else
        eye.use = FALSE
        Screen , , 1, 0
        x1 = 0
        y1 = 0
        x2 = f.w - 1
        y2 = f.h - 1
        tim.nobbin = tim.s.nobbin - levidx / 2 * tim.d.nobbin: If tim.nobbin < tim.min.nobbin Then tim.nobbin = tim.min.nobbin
        tim.hobbin = tim.s.hobbin + levidx * tim.d.hobbin: If tim.hobbin > tim.max.hobbin Then tim.hobbin = tim.max.hobbin
        gamestate = gs.play
        party.use = FALSE
        decorc = 0
        bagc = 0
        giftc = 0
        enemyc = 0
        For i = 0 To mazex - 1
            For j = 0 To mazey - 1
                FILLMAZECELL i, j, mz.init, TRUE, TRUE, TRUE, TRUE
            Next
        Next
        curbgr = (levidx - 1) Mod bgrc
        party.t.starttime = Timer
        y = -1
        levelpal = 7
        bgrflag = FALSE
        Do
            s$ = READLEVELSTR$
            If Left$(s$, 1) = "_" Then
                If Mid$(s$, 2, 6) = "levcol" Then
                    levelpal = Val(Right$(s$, Len(s$) - 8))
                ElseIf Mid$(s$, 2, 6) = "levbgr" Then
                    curbgr = Val(Right$(s$, Len(s$) - 8))
                End If
            Else
                If Not bgrflag Then FILLBGR curbgr: bgrflag = TRUE
                y = y + 1
                For x = 0 To 14
                    ch$ = Mid$(s$, x + 1, 1)
                    Select Case ch$
                        Case "#", " ": FILLMAZECELL x, y, mz.empty, TRUE, TRUE, TRUE, TRUE
                        Case "e":
                            nest.x = x
                            nest.y = y
                            GETCELLCOORDS x, y, party.x, party.y
                            party.use = FALSE
                            party.iwait = levidx * 5 + 10: If party.iwait > 35 Then party.iwait = 35
                            party.t.interval = party.iwait
                            party.ilen = 20
                            nest.count = levidx \ 3 + 2: If nest.count > 5 Then nest.count = 5
                            FILLMAZECELL x, y, mz.empty, TRUE, TRUE, TRUE, TRUE
                        Case "d": GETCELLCOORDS x, y, digger.startx, digger.starty: FILLMAZECELL x, y, mz.empty, FALSE, FALSE, TRUE, TRUE
                        Case "7": ADD newdecor, x, y
                        Case "$": ADD newbag, x, y
                    End Select
                Next
            End If
        Loop Until y = 9
        partymode = FALSE: snowready = FALSE
        bonusscore = 0
        CLOSELEVEL
        For i = 0 To mazey - 1
            For j = 0 To mazex - 1
                SCANMAZECELL j, i, v, 0, 0, 0, 0
                SCANMAZECELL j - 1, i, l, 0, 0, 0, 0
                SCANMAZECELL j + 1, i, r, 0, 0, 0, 0
                SCANMAZECELL j, i - 1, u, 0, 0, 0, 0
                SCANMAZECELL j, i + 1, d, 0, 0, 0, 0
                If v = mz.empty Then
                    n = l + r + u + d
                    FILLMAZECELL j, i, mz.empty, (l = mz.filled), (r = mz.filled), (u = mz.filled), (d = mz.filled)
                    If r = mz.empty Or l = mz.empty Then FILLMAZECELL j, i, mz.empty, FALSE, FALSE, OLD, OLD
                    If n < -2 Then FILLMAZECELL j, i, mz.empty, FALSE, FALSE, FALSE, FALSE
                End If
            Next
        Next
        GETMAZECELL digger.startx, digger.starty, cx, cy
        FILLMAZECELL cx, cy, mz.empty, FALSE, FALSE, OLD, OLD
        GETMAZECELL party.x, party.y, cx, cy
        FILLMAZECELL cx, cy, mz.empty, FALSE, FALSE, OLD, OLD

        For i = 0 To mazey - 1
            For j = 0 To mazex - 1
                SCANMAZECELL j, i, v, 0, 0, 0, 0
                If v = mz.empty Then DRAWHOLE j, i
                a$ = InKey$
            Next
        Next
        INITDIGGER
        SETPAL pal.normal
        FADELEVEL
    End If
End Sub

Sub LOADLEVIDX
    Restore DataLevidx
    i = 0
    Do
        i = i + 1
        Read levidx(i)
    Loop Until levidx(i) = -1
End Sub

Sub LOADSCORES (file$, scorebuf() As SCORETYPE)
    Open hiscorefile$ For Binary As #1
    For i = 0 To hiscorec - 1
        Get #1, , hiscore(i)
    Next
    Close #1
    SHOWHISCORES
End Sub

Sub MOVEBAGS
    f = FALSE
    For i = 1 To bagc
        If bag(i).mode = bagm.swinging Or bag(i).mode = bagm.falling Then f = TRUE: Exit For
    Next
    For i = bagc To 1 Step -1
        Select Case bag(i).mode
            Case bagm.normal
                GETMAZECELL bag(i).x, bag(i).y, mx, my
                SCANMAZECELL mx, my + 1, f, 0, 0, 0, 0
                GETCELLCOORDS mx, my, bx, by
                If f <> mz.filled And bag(i).x = bx And bag(i).y = by Then
                    bag(i).mode = bagm.swinging
                    bag(i).misc = 0
                    FILLMAZECELL mx, my, mz.empty, OLD, OLD, OLD, FALSE
                End If
            Case bagm.swinging
                'RETRACE
                ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                Select Case bag(i).misc Mod 3
                    Case 0: bag(i).pic.sequence = ani.bagleft
                    Case 1: bag(i).pic.sequence = ani.bag
                    Case 2: bag(i).pic.sequence = ani.bagright
                End Select
                bag(i).misc = bag(i).misc + 1
                If bag(i).misc > 6 Then
                    bag(i).mode = bagm.falling
                    bag(i).pic.sequence = ani.bagfall
                    GETMAZECELL bag(i).x, bag(i).y, 0, bag(i).fally
                    For B = 0 To 4: DRAWIMG bag(i).x - 5, bag(i).y + 12 - B * diggerspeedy, iblob.up, FALSE: Next
                End If
                DRAWPIC bag(i).x, bag(i).y, bag(i).pic, TRUE
                REDRAW bag(i).x, bag(i).y, decor(), decorc
                REDRAW bag(i).x, bag(i).y, gift(), giftc
                PLAYSOUND snd.bagswing
            Case bagm.falling
                ' erase bag and dig through soil under it.
                'RETRACE
                ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                For B = 0 To 2
                    DRAWIMG bag(i).x - 5, bag(i).y + 12 - B * diggerspeedy, iblob.up, FALSE
                Next

                ' move bag and check for digger
                bag(i).y = bag(i).y + diggerspeedy * 2
                If BOXCOLL(digger.x, digger.y, imgw, imgh, bag(i).x, bag(i).y, imgw, imgh) Then
                    digger.mode = dgr.falling
                    ERASEPIC digger.x, digger.y, digger.pic
                    digger.pic.sequence = ani.dgrdie
                    digger.pic.frame = 0
                    digger.x = bag(i).x
                    digger.y = bag(i).y
                    gamestate = gs.killed
                    DRAWPIC digger.x, digger.y, digger.pic, TRUE
                    ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                End If

                ' check for landing
                GETMAZECELL bag(i).x, bag(i).y, bx, by
                SCANMAZECELL bx, by + 1, v, 0, 0, 0, 0
                FILLMAZECELL bx, by, mz.empty, OLD, OLD, 2 * (by = bag(i).fally), 2 * (v = mz.filled)
                exists = TRUE
                If v = mz.filled Then
                    PLAYSOUND snd.baglanding
                    ' if digger falling with this bag, he's now dead
                    If digger.x = bag(i).x And digger.y = bag(i).y Then
                        PLAYSOUND snd.dead
                        digger.mode = dgr.dead
                    End If
                    ' if height>1, gifts and sweets appear
                    If by - bag(i).fally > 1 Then
                        GETMAZECELL bag(i).x, bag(i).y, x, y
                        ADD newgift, x, y
                        exists = FALSE
                    Else
                        bag(i).mode = bagm.normal
                        bag(i).pic.sequence = ani.bag
                    End If
                End If

                ' check for enemy killing and landing
                For j = 1 To enemyc
                    If BOXCOLL(bag(i).x, bag(i).y, imgw, imgh, enemy(j).x, enemy(j).y, imgw, imgh) And enemy(j).mode <> enm.dead Then
                        ' if bag is falling, enemy is falling with it, else ...
                        If exists And bag(i).mode <> bagm.normal Then
                            enemy(j).mode = enm.falling
                            ERASEPIC enemy(j).x - 1, enemy(j).y, enemy(j).pic
                            enemy(j).y = bag(i).y
                            enemy(j).x = bag(i).x ' <== if not, enemy can corrupt ground
                            If enemy(j).mode = enm.nobbin Then
                                enemy(j).pic.sequence = ani.nobbindie
                            ElseIf enemy(j).mode = enm.hobbin Then
                                enemy(j).pic.sequence = enm.nobbin
                            End If
                            enemy(j).pic.frame = 0
                            DRAWPIC enemy(j).x - 1, enemy(j).y, enemy(j).pic, TRUE
                            ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                        Else
                            ' ... else enemy is dead
                            enemy(j).mode = enm.dead
                            enemy(j).tdead.starttime = Timer: enemy(j).tdead.interval = .5
                            ERASEPIC enemy(j).x - 1, enemy(j).y, enemy(j).pic
                            enemy(j).y = bag(i).y
                        End If
                    End If
                Next

                If exists Then
                    DRAWPIC bag(i).x, bag(i).y, bag(i).pic, FALSE
                    REDRAW bag(i).x, bag(i).y - diggerspeedy * 2, decor(), decorc
                    REDRAW bag(i).x, bag(i).y - diggerspeedy * 2, gift(), giftc
                Else ' destroy it
                    Swap bag(i), bag(bagc)
                    bagc = bagc - 1
                    MOVEGIFT
                End If
            Case bagm.left, bagm.right
                moveit = TRUE
                If bag(i).mode = bagm.left Then
                    dx = -diggerspeedx
                Else
                    dx = diggerspeedx
                End If

                If BOXCOLL(bag(i).x + dx, bag(i).y, cellw, cellh, digger.x, digger.y, imgw, imgh) And digger.x * Sgn(dx) > (bag(i).x + dx) * Sgn(dx) Then moveit = FALSE
                For j = 1 To enemyc
                    If BOXCOLL(bag(i).x + dx, bag(i).y, cellw, cellh, enemy(j).x, enemy(j).y, imgw, imgh) And enemy(j).mode <> bagm.dead Then moveit = FALSE
                Next

                If moveit = TRUE Then
                    bx = bag(i).x + dx
                    ' shift complete?
                    GETMAZECELL bx, bag(i).y, bgx, bgy
                    GETCELLCOORDS bgx, bgy, bgx0, bgy0
                    If bx = bgx0 Then
                        ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                        bag(i).mode = bagm.normal
                        bag(i).pic.sequence = ani.bag
                        SCANMAZECELL bgx, bgy + 1, v, 0, 0, 0, 0
                        FILLMAZECELL bgx, bgy, FALSE, (Not (dx > 0)) * 2, (Not (dx < 0)) * 2, OLD, OLD
                        If v <> mz.filled Then
                            bag(i).mode = bagm.falling
                            bag(i).pic.sequence = ani.bagfall
                            bag(i).fally = bgy
                        End If
                    End If
                    ' dig through soil and redraw bag.
                    RETRACE
                    If dx > 0 Then
                        For q = 0 To 1
                            j = q * diggerspeedx
                            DRAWIMG bag(i).x - j + 3, bag(i).y - 1, iblob.left, FALSE
                        Next
                    Else
                        For q = 0 To 1
                            j = q * diggerspeedx
                            DRAWIMG bag(i).x + imgw - 8 - j + 3, bag(i).y - 1, iblob.right, FALSE
                        Next
                    End If
                    ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                    bag(i).x = bx
                    
                    ' automatically draw current bag (it collides with itself).
                    REDRAW bag(i).x - dx, bag(i).y - dy, bag(), bagc

                    REDRAW bag(i).x - dx, bag(i).y, decor(), decorc
                    PLAYSOUND snd.bagshift
                Else
                    ERASEPIC bag(i).x, bag(i).y, bag(i).pic
                    If bag(i).mode = bagm.left Then
                        bag(i).mode = bagm.right
                        bag(i).pic.sequence = ani.bagright
                    Else
                        bag(i).mode = bagm.left
                        bag(i).pic.sequence = ani.bagleft
                    End If
                    DRAWPIC bag(i).x, bag(i).y, bag(i).pic, FALSE
                    REDRAW bag(i).x, bag(i).y, decor(), decorc
                End If
        End Select
    Next
End Sub

Sub MOVEDIGGER (dx, dy)
    newx = digger.x + diggerspeedx * dx
    newy = digger.y + diggerspeedy * dy
    GETMAZECELL newx, newy, nx, ny
    GETCELLCOORDS nx, ny, n1x, n1y
    If nx < 0 Or ny < 0 Or ((nx >= mazex - 1 And newx <> n1x And dx > 0) Or (ny >= mazey - 1 And newy <> n1y And dy > 0)) Then Exit Sub

    ' *** adjust for maze cells *** '
    If ((n1y <> newy And dx <> 0) Or (n1x <> newx And dy <> 0)) And (dx <> digger.dx Or dy <> digger.dy) Then
        ' *** if not in cell, move it in currently used direction
        dx = digger.dx
        dy = digger.dy
        amode = digger.pic.sequence
    Else
        ' *** if in cell, change direction *** '
        If dx < 0 Then digger.mode = dgr.left: amode = ani.dgrleft
        If dx > 0 Then digger.mode = dgr.right: amode = ani.dgrright
        If dy < 0 Then digger.mode = dgr.up: amode = ani.dgrup
        If dy > 0 Then digger.mode = dgr.down: amode = ani.dgrdown
        If Not digger.eye Then amode = amode + anid.withouteye
    End If
 
    newx = digger.x + diggerspeedx * dx
    newy = digger.y + diggerspeedy * dy
    If CHECKBAGSHIFT(newx, newy, dx) Then Exit Sub

    digger.dx = dx
    digger.dy = dy
 
    ' *** adjust maze *** '
    GETMAZECELL newx - 1, newy, clx, cy
    GETMAZECELL newx, newy - 1, cx, cuy
    GETMAZECELL digger.x - 1, digger.y, olx, oy
    GETMAZECELL digger.x, digger.y - 1, ox, ouy
    If dx < 0 Then
        If clx <> olx Then FILLMAZECELL clx + 1, cy, mz.empty, FALSE, OLD, OLD, OLD
        SCANMAZECELL clx, cy, v, 0, 0, 0, 0
        FILLMAZECELL clx, cy, (2 * (olx <> clx) + 1) * mz.half * Abs(v), OLD, FALSE, OLD, OLD
    End If
    If dx > 0 Then
        If ox <> cx Then FILLMAZECELL cx, cy, mz.empty, OLD, FALSE, OLD, OLD
        SCANMAZECELL cx + 1, cy, v, 0, 0, 0, 0
        FILLMAZECELL cx + 1, cy, (2 * (ox <> cx) + 1) * mz.half * Abs(v), FALSE, OLD, OLD, OLD
    End If
    If dy < 0 Then
        If cuy <> ouy Then FILLMAZECELL cx, cuy + 1, mz.empty, OLD, OLD, FALSE, OLD
        SCANMAZECELL cx, cuy, v, 0, 0, 0, 0
        FILLMAZECELL cx, cuy, (2 * (ouy <> cuy) + 1) * mz.half * Abs(v), OLD, OLD, OLD, FALSE
    End If
    If dy > 0 Then
        If cy <> oy Then FILLMAZECELL cx, cy, mz.empty, OLD, OLD, OLD, FALSE
        SCANMAZECELL cx, cy + 1, v, 0, 0, 0, 0
        FILLMAZECELL cx, cy + 1, (2 * (oy <> cy) + 1) * mz.half * Abs(v), OLD, OLD, FALSE, OLD
    End If

    ' *** dig through the ground *** '
    Select Case digger.mode
        Case dgr.left: DRAWIMG newx - 5, newy - 1, iblob.left, FALSE
        Case dgr.right: DRAWIMG newx + 10 + 1, newy - 1, iblob.right, FALSE
        Case dgr.up: DRAWIMG newx - 5, newy - 3, iblob.up, FALSE
        Case dgr.down: DRAWIMG newx - 5, newy + 12, iblob.down, FALSE
    End Select

    ' redraw sprite
    RETRACE
    ERASEPIC digger.x, digger.y, digger.pic
    digger.x = newx
    digger.y = newy
    digger.pic.sequence = amode
    n = 3
    DRAWPIC digger.x, digger.y, digger.pic, TRUE
    CHECKDECORS digger.x, digger.y, TRUE
    CHECKGIFT digger.x, digger.y, TRUE
    REDRAW digger.x + dx * n, digger.y + dy * n, decor(), decorc
    REDRAW digger.x + dx * n, digger.y + dy * n, gift(), giftc
End Sub

Sub MOVEENEMIES
    Dim delta(3, 1)
    Dim w(3), cl(3), dl(3), ds(3)
    Dim aw(1 To 4), bw(1 To 4)
    Const xd = 0, yd = 1
    Static nn
    nn = (nn + 1) Mod 2
    delta(0, xd) = -1
    delta(1, xd) = 1
    delta(2, yd) = -1
    delta(3, yd) = 1
    For i = enemyc To 1 Step -1
        If (enemy(i).stpx = enemy(i).x And enemy(i).stpy = enemy(i).y) And gamestate = gs.play And enemy(i).mode <> enm.falling Then
            GETMAZECELL enemy(i).x, enemy(i).y, cx, cy
            If enemy(i).mode = enm.nobbin Then
                If Int(Rnd * 1000) < 70 Or (cx = enemy(i).trgx And cy = enemy(i).trgy) Or enemy(i).chaseflee = TRUE Then
                    If Int(Rnd * 100) < (20 + 15 * (enemy(i).chaseflee = TRUE)) And Not partymode Then
                        enemy(i).chaseflee = FALSE
                        GETRANDOMCELL dx, dy
                        enemy(i).trgx = dx
                        enemy(i).trgy = dy
                    Else
                        enemy(i).chaseflee = TRUE
                        GETMAZECELL digger.x, digger.y, dx, dy
                        If partymode Then
                            temp = GETPATH(cx, cy, dx, dy, pl0)
                            If pl0 <> -1 Then
                                SCANMAZECELL cx, cy, 0, w(0), w(1), w(2), w(3): For j = 0 To 3: SCANMAZECELL cx + delta(j, xd), cy + delta(j, yd), cl(j), 0, 0, 0, 0: Next
                                bwc = 0: awc = 0
                                For j = 0 To 3
                                    If w(j) = FALSE And cl(j) = mz.empty Then
                                        temp = GETPATH(dx, dy, cx + delta(j, xd), cy + delta(j, yd), pl)
                                        awc = awc + 1: aw(awc) = j
                                        If pl > pl0 Then bwc = bwc + 1: bw(bwc) = j
                                    End If
                                Next
                                If bwc > 0 Then
                                    j = Int(Rnd * bwc) + 1
                                    dx = cx + delta(bw(j), xd)
                                    dy = cy + delta(bw(j), yd)
                                ElseIf awc > 0 Then
                                    j = Int(Rnd * awc) + 1
                                    dx = cx + delta(aw(j), xd)
                                    dy = cy + delta(aw(j), yd)
                                Else
                                    enemy(i).trgx = cx
                                    enemy(i).trgy = cy
                                End If
                            Else
                                GETRANDOMCELL dx, dy
                                enemy(i).trgx = dx
                                enemy(i).trgy = dy
                                enemy(i).chaseflee = FALSE
                            End If
                        Else
                            enemy(i).chaseflee = TRUE
                        End If
                    End If
                End If
                FILLMAZECELL cx, cy, mz.empty, OLD, OLD, OLD, OLD
                SCANMAZECELL dx, dy, v, 0, 0, 0, 0
                Do
                    If enemy(i).chaseflee = TRUE Then
                        If v <> mz.empty Then
                            If digger.dx <> 0 Then
                                dx = dx + 1
                            ElseIf digger.dy <> 0 Then
                                dy = dy + 1
                            End If
                        End If
                        r = GETPATH(cx, cy, dx, dy, 0)
                        enemy(i).trgx = dx
                        enemy(i).trgy = dy
                    Else
                        r = GETPATH(cx, cy, enemy(i).trgx, enemy(i).trgy, 0)
                    End If
                    If r = -1 Then
                        GETRANDOMCELL dx, dy
                        enemy(i).chaseflee = FALSE
                        enemy(i).trgx = dx
                        enemy(i).trgy = dy
                    Else
                        Exit Do
                    End If
                Loop
                Select Case r
                    Case 0: cx = cx - 1
                    Case 1: cx = cx + 1
                    Case 2: cy = cy - 1
                    Case 3: cy = cy + 1
                End Select
            ElseIf enemy(i).mode = enm.hobbin Then
                ' hobbin can become nobbin only when it doesn't dig the tunnel,
                ' otherwise nobbin will dig through soil.
                If Not partymode Then
                    If TEVENT(enemy(i).thob) Then
                        enemy(i).thob.starttime = Timer
                        ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                        enemy(i).pic.sequence = ani.nobbin
                        enemy(i).pic.frame = 0
                        enemy(i).mode = enm.nobbin
                        enemy(i).thob.interval = tim.nobbin
                        Exit For
                    End If
                End If
                d = enemy(i).dir
                FILLMAZECELL cx, cy, FALSE, (d <> 1) * 2, (d <> 2) * 2, (d <> 3) * 2, (d <> 4) * 2
                Do
                    enemy(i).chaseflee = Int(Rnd * 200) < 20 - 160 * enemy(i).chaseflee
                    If enemy(i).chaseflee = TRUE Then
                        dist0x = Abs(enemy(i).x - digger.x)
                        dist0y = Abs(enemy(i).y - digger.y)
                        btime! = Timer
                        l = 0 ' longer way directions
                        s = 0 ' shorter way directions
                        For j = 1 To 4
                            '    for hobbin, dirs are 01234 <0lrud (0=no dir)>;
                            '    in delta, they are 0123 <lrud>;
                            '    so we will convert hobbin's dir to delta dir with (j - 1).
                            distJx = Abs(enemy(i).x - digger.x + diggerspeedx * delta(j - 1, xd))
                            distJy = Abs(enemy(i).y - digger.y + diggerspeedy * delta(j - 1, yd))
                            If distJx < dist0x Or distJy < dist0y Then
                                s = s + 1
                                ds(s - 1) = j
                            Else
                                l = l + 1
                                dl(l - 1) = j
                            End If
                        Next
                        If partymode Then
                            enemy(i).dir = dl(Int(Rnd * l))
                        Else
                            enemy(i).dir = ds(Int(Rnd * s))
                        End If
                    Else
                        If enemy(i).dir = 0 Or Int(Rnd * 5) = 2 Then enemy(i).dir = Int(Rnd * 4) + 1
                    End If
                    Select Case enemy(i).dir
                        Case 1: If cx = 0 Then enemy(i).dir = 0 Else cx = cx - 1
                        Case 2: If cx = mazex - 1 Then enemy(i).dir = 0 Else cx = cx + 1
                        Case 3: If cy = 0 Then enemy(i).dir = 0 Else cy = cy - 1
                        Case 4: If cy = mazey - 1 Then enemy(i).dir = 0 Else cy = cy + 1
                    End Select
                    d = enemy(i).dir
                    FILLMAZECELL cx, cy, OLD, (d <> 2) * 2, (d <> 1) * 2, (d <> 4) * 2, (d <> 3) * 2
                Loop Until enemy(i).dir <> 0
            End If
            GETCELLCOORDS cx, cy, enemy(i).stpx, enemy(i).stpy
        End If
        If enemy(i).mode = enm.dead Then
            If TEVENT(enemy(i).tdead) Then
                ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                REDRAW enemy(i).x - 1, enemy(i).y, gift(), giftc
                REDRAW enemy(i).x - 1, enemy(i).y, bag(), bagc
                Swap enemy(i), enemy(enemyc)
                enemyc = enemyc - 1
                ADDSCORE 250
            Else
                DRAWPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic, FALSE
                REDRAW enemy(i).x, enemy(i).y, gift(), giftc
            End If
        Else
            ' nobbin can become hobbin anytime, because if it shifts a bag,
            ' and other nobbin (or digger!) shift this bag too from the other side,
            ' our nobbin will never become hobbin. and look at hobbin->nobbin part.
            If enemy(i).mode = enm.nobbin And Not partymode Then
                If TEVENT(enemy(i).thob) And gamestate = gs.play Then
                    enemy(i).thob.starttime = Timer
                    ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                    enemy(i).pic.sequence = ani.hobbinleft
                    enemy(i).pic.frame = 0
                    enemy(i).mode = enm.hobbin
                    enemy(i).chaseflee = TRUE
                    enemy(i).thob.interval = tim.hobbin
                End If
            End If
        End If
    Next

    For i = 1 To enemyc
        If enm.mode <> enm.falling And enemy(i).mode <> enm.dead Then
            CHECKGIFT enemy(i).x, enemy(i).y, FALSE
            CHECKDECORS enemy(i).x, enemy(i).y, FALSE
        End If
    Next

    ' move them on the screen
    RETRACE
    For i = 1 To enemyc
        If enemy(i).mode <> enm.falling And enemy(i).mode <> enm.dead Then
            nx = enemy(i).x + diggerspeedx * Sgn(enemy(i).stpx - enemy(i).x)
            ny = enemy(i).y + diggerspeedy * Sgn(enemy(i).stpy - enemy(i).y)
            oldx = enemy(i).x
            oldy = enemy(i).y
            If enemy(i).mode = enm.hobbin Or Not CHECKBAGSHIFT(nx, ny, Sgn(enemy(i).stpx - enemy(i).x)) Then
                If enemy(i).mode = enm.hobbin Then
                    For j = bagc To 1 Step -1
                        If bag(j).mode <> bagm.falling And BOXCOLL(nx, ny, imgw, imgh, bag(j).x + 1, bag(j).y + 1, imgw - 2, imgh - 2) And bag(j).mode <> bagm.falling Then
                            ERASEPIC bag(j).x, bag(j).y, bag(j).pic
                            Swap bag(bagc), bag(j)
                            bagc = bagc - 1
                        End If
                    Next
                    Select Case enemy(i).dir
                        Case 1: DRAWIMG nx - 5, ny - 1, iblob.left, FALSE
                        Case 2: DRAWIMG nx + 10 + 1, ny - 1, iblob.right, FALSE
                        Case 3: DRAWIMG nx - 5, ny - 3, iblob.up, FALSE
                        Case 4: DRAWIMG nx - 5, ny + 12, iblob.down, FALSE
                    End Select
                    If nx < enemy(i).x And enemy(i).pic.sequence <> ani.hobbinleft Then
                        ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                        enemy(i).pic.sequence = ani.hobbinleft
                    End If
                    If nx > enemy(i).x And enemy(i).pic.sequence <> ani.hobbinright Then
                        ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                        enemy(i).pic.sequence = ani.hobbinright
                    End If
                End If
                ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                enemy(i).x = nx
                enemy(i).y = ny
                If nn Then ANIMATE enemy(i).pic
            End If
            DRAWPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic, TRUE
            If party.use Then
                If BOXCOLL(oldx, oldy, cellw, cellh, party.x, party.y, cellw, cellh) Then
                    RETRACE
                    DRAWIMG party.x, party.y, anim(ani.party, img1), FALSE
                End If
            End If
        End If
    Next
End Sub

Sub MOVEEYE
    ERASEPIC eye.x, eye.y, eye.pic
    REDRAW eye.x, eye.y, bag(), bagc
    REDRAW eye.x, eye.y, decor(), decorc
    REDRAW eye.x, eye.y, gift(), giftc
    ANIMATE eye.pic
    If eye.mode = eyem.normal Then
        eye.x = eye.x + eye.dx * diggerspeedx * 2
        eye.y = eye.y + eye.dy * diggerspeedy * 2
        For i = enemyc To 1 Step -1
            If BOXCOLL(enemy(i).x, enemy(i).y, imgw, imgh, eye.x, eye.y, eyew, eyeh) Then
                ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
                eye.pic.sequence = ani.expl
                eye.pic.frame = 0
                eye.mode = eyem.expl
                ADDSCORE 250
                Swap enemy(i), enemy(enemyc)
                enemyc = enemyc - 1
                PLAYSOUND snd.hit
                PLAYSOUND snd.killenemy
                Exit For
            End If
        Next
        GETMAZECELL eye.x - (eye.dx > 0) * (diggerspeedx + eyew), eye.y - (eye.dy > 0) * (diggerspeedy + eyeh), x, y
        SCANMAZECELL x, y, i, 0, 0, 0, 0
        If i = mz.filled Then
            PLAYSOUND snd.hit
            eye.pic.sequence = ani.expl
            eye.pic.frame = 0
            eye.mode = eyem.expl
        End If
    Else
        If eye.pic.frame = anim(ani.expl, framec) - 1 Then eye.use = FALSE
    End If
    If eye.use Then DRAWPIC eye.x, eye.y, eye.pic, FALSE
End Sub

Sub MOVEGIFT
    For i = giftc To 1 Step -1
        If gift(i).pic.frame <> 2 Then
            RETRACE
            ERASEPIC gift(i).x, gift(i).y, gift(i).pic
            REDRAW gift(i).x, gift(i).y, bag(), bagc
            REDRAW gift(i).x, gift(i).y, decor(), decorc
            ANIMATE gift(i).pic
            DRAWPIC gift(i).x, gift(i).y, gift(i).pic, FALSE
        End If
        GETMAZECELL gift(i).x, gift(i).y, x, y
        SCANMAZECELL x, y + 1, v, 0, 0, 0, 0
        If v <> mz.filled Then gift(i).t.interval = 5
        If TEVENT(gift(i).t) Then
            ERASEPIC gift(i).x, gift(i).y, gift(i).pic
            REDRAW gift(i).x, gift(i).y, decor(), decorc
            REDRAW gift(i).x, gift(i).y, bag(), bagc
            Swap gift(i), gift(giftc)
            giftc = giftc - 1
        End If
    Next
End Sub

Sub NEWGAME
    Dim tbags As TIMEINT
    Dim tstat As TIMEINT
    Dim tdgra As TIMEINT
    Dim tgift As TIMEINT
    Dim tbon As TIMEINT
    Dim tenem As TIMEINT
    Dim tenew As TIMEINT
    RESTOREFIELD
    gameresult = 0
    tbon.interval = .1
    tbags.interval = .1
    tstat.interval = .1
    tdgra.interval = .08
    tgift.interval = .1
    tcons.interval = 1
    tenem.interval = .045
    tenew.interval = 3
    tim.eye = 1
    digger.lives = 4
    digger.score = 0
    digger.teye.interval = tim.eye
    NEXTLEVEL
    Do
        ADDSCORE 0

        GETINPUTS
        If gamestate = gs.newgame Or gamestate = gs.quit Then Exit Sub

        If gamestate <> gs.killed Then
            ' next level if all decors collected
            If decorc = 0 Then
                DRAWPIC digger.x, digger.y, digger.pic, FALSE
                NEXTLEVEL
                If gamestate = gs.quit Then Exit Sub
            End If
            CELEBRATE 'if partymode = TRUE, but if it not so, snow will be erased.
            If partymode = FALSE And enemyc < nest.count Then
                If TEVENT(tenew) Then ADD newnobbin, nest.x, nest.y
            End If
            If TEVENT(tenem) Then
                MOVEENEMIES
                If eye.use Then MOVEEYE
                CHECKKILL
            End If
            If TEVENT(party.t) Then
                If partymode Then
                    partymode = FALSE
                    SETPAL pal.normal
                    party.t.starttime = Timer
                    party.iwait = party.iwait + 5
                    party.t.interval = party.iwait
                Else
                    party.t.interval = party.ilen
                    party.t.starttime = Timer
                    party.use = TRUE
                End If
            End If
            If TEVENT(tbon) Then CHECKPARTY digger.x, digger.y, TRUE
            If TEVENT(tcons) Then consorn = 0 ' remove decor octave
        Else
            tdgra.interval = .14
            If digger.pic.frame = anim(ani.dgrdie, framec) - 1 Then
                If Not RESTART Then Exit Sub
                tdgra.interval = .08
            End If
        End If
        If TEVENT(tgift) Then MOVEGIFT: If gamestate <> gs.play Then DRAWPIC digger.x, digger.y, digger.pic, FALSE
        If TEVENT(tbags) Then MOVEBAGS
        If TEVENT(tstat) Then SHOWSCORE digger.score, digger.lives
        If TEVENT(tdgra) And digger.mode <> dgr.falling Then
            RETRACE
            ERASEPIC digger.x, digger.y, digger.pic
            If digger.mode = dgr.dead Then
                REDRAW digger.x, digger.y, bag(), bagc
                REDRAW digger.x, digger.y, decor(), decorc
                REDRAW digger.x, digger.y, gift(), giftc
            End If
            ANIMATE digger.pic
            DRAWPIC digger.x, digger.y, digger.pic, FALSE
        End If
    Loop
End Sub

Sub NEXTLEVEL
    curlevel = curlevel + 1
    LOADLEVEL curlevel
End Sub

Function NUMTOSTR$ (n As Long)
    NUMTOSTR = LTrim$(RTrim$(Str$(n)))
End Function

Function OPENLEVEL (idx$)
    If levelpack$ = "" Then
        Restore DataLevels
        Do
            Read s$: s$ = LTrim$(RTrim$(s$))
            If s$ = "_end" Then
                OPENLEVEL = FALSE
                Exit Function
            End If
        Loop Until s$ = "_mine #" + idx$
        OPENLEVEL = TRUE
    Else
        Open levelpack$ For Input As #1
        Do
            Line Input #1, s$: s$ = LTrim$(RTrim$(s$))
            If s$ = "_end" Then
                OPENLEVEL = FALSE
                Close #1
                Exit Function
            End If
        Loop Until s$ = "_mine #" + idx$
        OPENLEVEL = TRUE
    End If
End Function

Sub PLAYSOUND (sndcode)
    If nosound Then Exit Sub
    Select Case sndcode
        Case snd.killenemy: For i = 85 To 100: Sound ((i - 84) ^ 3) / 40 + 37 + (i Mod 3) * 40, i / 400: Next
        Case snd.shoot: Sound 1000 + Rnd * 1000 + 37, .3
        Case snd.hit: Sound Rnd * 1000 + 237, Rnd * .04 + .04
        Case snd.dead: For j = 0 To 14: Sound Abs(Sin(j / 5)) * 2700 + 37, .21: Next
        Case snd.bagshift: Sound Rnd * 100 + 37, Rnd * .04 + .04
        Case snd.baglanding: For j = 1 To 10: Sound Rnd * 200 + 40, Rnd * .17: Next
        Case snd.decor: a = Rnd * 1400: For i = 1 To 70: Sound i + 37 + (i Mod 3) * 100 + 8000 + a, i / 2800: Next
        Case snd.gift: a = 30: For i = 1 To 10: a = a * 1.5: Sound a + Rnd * 200 + 400, .1: Next
    End Select
End Sub

Sub QUIT
    Screen 0
    Width 80, 25
    Erase img
    Erase gift
    Erase bag
    Erase decor
    Erase graph
    Erase anim
    Print PROGNAME$ + " " + PROGVER$ + ", 2002-2008"
    Print "Better luck next time!"
    End
End Sub

Sub READINI
    Open inifile$ For Binary Access Read As #1
    Seek #1, 1
    For i = 1 To 10
        a$ = Space$(3): Get #1, , a$
        Select Case LCase$(Left$(a$, 2))
            Case "s+": nosound = FALSE
            Case "s-": nosound = TRUE
            Case "r-": noretrace = TRUE
            Case "r+": noretrace = FALSE
            Case "bw": partystyle = ps.whitebgr
            Case "bb": partystyle = ps.brightbgr
            Case "bs": partystyle = ps.snowing
        End Select
        If LCase$(Left$(a$, 1)) = "f" Then
            snowc = Val("&h" + Right$(a$, 2)) * 10
            If snowc = 0 Then snowc = 7
        End If
    Next
    Close #1
End Sub

Function READLEVELSTR$
    If levelpack$ = "" Then
        Read s$
        READLEVELSTR$ = s$
    Else
        Line Input #1, s$
        READLEVELSTR$ = s$
    End If
End Function

Sub REDRAW (x, y, obj() As PICKUPTYPE, objc)
    For j = 1 To objc
        If Abs(y - obj(j).y) < cellh Then
            If Abs(x - obj(j).x) < cellw Then
                If BOXCOLL(x, y, cellw, cellh, obj(j).x - 2, obj(j).y - 2, cellw - 3, cellh - 3) Then
                    DRAWPIC obj(j).x, obj(j).y, obj(j).pic, FALSE
                    Exit Sub
                End If
            End If
        End If
    Next
End Sub

Sub REDRAWOBJS (arr() As PICKUPTYPE, n, maskfl)
    For i = 1 To n: DRAWPIC arr(i).x, arr(i).y, arr(i).pic, FALSE: Next
End Sub

Function RESTART
    DELAY 1
    While InKey$ <> "": Wend
    digger.lives = digger.lives - 1
    If digger.lives < 0 Then
        digger.lives = 0
        RESTART = FALSE
        gameresult = gr.gameover
        Exit Function
    End If
    If party.use = FALSE Then party.t.starttime = Timer
    For i = 1 To enemyc
        ERASEPIC enemy(i).x - 1, enemy(i).y, enemy(i).pic
    Next
    For i = bagc To 1 Step -1
        If bag(i).mode = bagm.falling Then
            ERASEPIC bag(i).x, bag(i).y, bag(i).pic
            Swap bag(i), bag(bagc)
            bagc = bagc - 1
        End If
    Next
    enemyc = 0
    If eye.use Then
        ERASEPIC eye.x, eye.y, eye.pic
        eye.use = FALSE
    End If
    ERASEPIC digger.x, digger.y, digger.pic
    INITDIGGER
    gamestate = gs.play
    For i = 1 To bagc
        DRAWPIC bag(i).x, bag(i).y, bag(i).pic, FALSE
        temp = Len(InKey$)
    Next
    For i = 1 To decorc
        DRAWPIC decor(i).x, decor(i).y, decor(i).pic, FALSE
        temp = Len(InKey$)
    Next
    For i = 1 To giftc
        DRAWPIC gift(i).x, gift(i).y, gift(i).pic, FALSE
        temp = Len(InKey$)
    Next
    RESTART = TRUE
End Function

Sub RESTOREFIELD
    View (f.x, f.y)-(f.x + f.w - 1, f.y + f.h - 1)
End Sub

Sub RETRACE
    Static n
    n = (n + 1) Mod 3
    If Not noretrace And n = 0 Then Wait &H3DA, 8
End Sub

Sub SCANMAZECELL (cx, cy, inner, lw, rw, uw, dw)
    cx2 = cx * 2
    cy2 = cy * 2
    If cx < 0 Or cy < 0 Or cx > mazex - 1 Or cy > mazey - 1 Then
        inner = mz.filled
        lw = TRUE
        rw = TRUE
        uw = TRUE
        dw = TRUE
    Else
        inner = maze(cx2, cy2)
        lw = maze(cx2 - 1, cy2)
        rw = maze(cx2 + 1, cy2)
        uw = maze(cx2, cy2 - 1)
        dw = maze(cx2, cy2 + 1)
    End If
End Sub

Sub SCREENSHOT
    a$ = NUMTOSTR$(shotc + 0)
    a$ = String$(5 - Len(a$), "0") + a$
    shotc = shotc + 1

    siz = IMGSIZE(f.w, f.h) + 1
    Dim buf(siz) As Integer

    buf(0) = Abs(partymode) + &H100 * partystyle

    Get (0, 0)-(f.w - 1, f.h - 1), buf(1)
    Line (0, 0)-Step(f.w, f.h), 1, BF
    Def Seg = VarSeg(buf(1))
    BSave "ams" + a$ + ".bsv", VarPtr(buf(0)), siz * 2
    Def Seg

    While Len(InKey$) <> 0: Wend
    Put (0, 0), buf(1), PSet
    Erase buf
End Sub

Sub SETPAL (palmode As Integer)
    If nopal Or scrmode = 12 Then Exit Sub
    Wait &H3DA, 8: Wait &H3DA, 8, 8
    Select Case palmode
        Case pal.normal
            Palette 0, levelpal
            Palette 1, 57
            Palette 2, 10
            Palette 3, 35
            Palette 4, 12
            Palette 5, 13 + 32
            Palette 6, 36
            Palette 7, 15
            Palette 8, 0
            Palette 9, 11
            Palette 10, 19
            Palette 11, 27
            Palette 12, 53
            Palette 13, 15 + 32
            Palette 14, 38
            Palette 15, 15 + 48
        Case pal.party
            Select Case partystyle
                Case ps.brightbgr: Palette 0, (levelpal + 8) Mod 64
                Case ps.whitebgr: Palette 0, 63
                Case ps.snowing: Palette 0, levelpal
            End Select
    End Select
End Sub

Function SHIFTBAG (num, dir)
    If dir = 0 Then SHIFTBAG = FALSE: Exit Function
    GETMAZECELL bag(num).x, bag(num).y, bx, by: If bx = 0 Or bx = mazex - 1 Then SHIFTBAG = FALSE: Exit Function
    If BOXCOLL(bag(num).x + dir, bag(num).y, cellw, cellh, digger.x, digger.y, imgw, imgh) Then SHIFTBAG = FALSE: Exit Function
    For i = 1 To bagc
        If i <> num Then
            If BOXCOLL(bag(num).x + dir, bag(num).y, cellw, cellh, bag(i).x, bag(i).y, cellw - 1, imgh) And bag(i).mode = bagm.normal And bag(num).x * Sgn(dir) < bag(i).x * Sgn(dir) Then
                If SHIFTBAG(i, dir) = FALSE Then SHIFTBAG = FALSE: Exit Function
            End If
        End If
    Next

    SHIFTBAG = TRUE
    GETMAZECELL bag(num).x, bag(num).y, cx, cy
    FILLMAZECELL cx, cy, FALSE, OLD, OLD, OLD, OLD
    If dir < 0 Then
        bag(num).mode = bagm.left
        bag(num).pic.sequence = ani.bagleft
        GETCELLCOORDS bx, by, x, y
        If x = bag(num).x And y = bag(num).y Then d = 1 Else d = 0
        GETCELLCOORDS bx - d, by, bag(num).dx, 0
    Else
        bag(num).mode = bagm.right
        bag(num).pic.sequence = ani.bagright
        GETCELLCOORDS bx + 1, by, bag(num).dx, 0
    End If
End Function

Sub SHOOT (dx, dy)
    If eye.use Then Exit Sub
    eye.x = digger.x - 5 * (dx = 0 And dy < 0) - imgw * (dx > 0) + eyew * (dx < 0)
    eye.y = digger.y - 2 * (dy = 0) - imgh * (dy > 0) + eyeh * (dy < 0)
    eye.dx = dx
    eye.dy = dy
    eye.use = TRUE
    eye.mode = eyem.normal
    eye.pic.sequence = ani.fire
    eye.pic.frame = 0
    PLAYSOUND snd.shoot
End Sub

Sub SHOWHINT (col, row, a$)
    Const charw = 9, charh = 14
    Const cl0 = 9, cl1 = 14, cl2 = 13, cl3 = 7
    cl = cl0
    x = col
    For i = 1 To Len(a$)
        Color cl
        Select Case Mid$(a$, i, 1)
            Case "*": TEXTOUT row, x, Chr$(4), 1: x = x + 1
            Case "\": If cl = cl0 Then cl = cl1 Else cl = cl0
            Case "~": If cl = cl0 Then cl = cl2 Else cl = cl0
            Case "^": If cl = cl0 Then cl = cl3 Else cl = cl0
            Case "&":
                Select Case Mid$(a$, i + 1, 1)
                    Case "e": im = 65: dx = 6: dy = 0: f = 1
                    Case "g": im = 73: dy = -1: dx = 6
                    Case "c": im = 72: dx = 6: dy = -1
                    Case "n": im = 49: dx = 5: dy = -1
                    Case "h": im = 57: dy = -2
                    Case "s": im = 73: f = 1: dx = 9: dy = 3
                End Select
                If f = 0 Then
                    x = x + 1
                Else
                    x = x + 1
                    f = 0
                End If
                DRAWIMG charw * (x - 3) + dx, (row - 1) * charh + dy, im, TRUE
                i = i + 1
            Case Else: TEXTOUT row, x, Mid$(a$, i, 1), 1: x = x + 1
        End Select
    Next
End Sub

Sub SHOWHINTS
    View
    Line (0, 0)-(640, 350), 8, BF
    col = 2: ctl = 40
    SHOWHINT 2, 17, "Welcome to ~" + PROGNAME$ + "~! The scoring system works as follows:"
    SHOWHINT col, 19, " Decoration (&e) costs \25\ points;  pick  up  eight  of  them, and  you"
    SHOWHINT col, 20, "will  get extra \250\ points.  Gifts  and  sweets (&g)  cost \500\ points."
    SHOWHINT col, 21, "Neutralization of dangerous Hobbins and Nobbins ( &h and &n) gives  you"
    SHOWHINT col, 22, "\250\ points.  If you go to  the New Year Party (&c), your wishes become"
    SHOWHINT col, 23, "true,   and  you  receive  \1000\  extra  points.  Extra  life  appears"
    SHOWHINT col, 24, "every \5,000\ points."
    SHOWHINT 60, 25, "~2002-2008~"
    SHOWHINT ctl, 1, "use  ^arrow keys^  to move, ^space^"
    SHOWHINT ctl, 2, "to  shoot,  ^F1^ to pause,  ^F5^ to"
    SHOWHINT ctl, 3, "restart, ^F4^ to save screenshot,"
    SHOWHINT ctl, 4, "^F8^ to toggle sound. ^F10^ quits."
    View (f.x, f.y)-(f.x + f.w - 1, f.y + f.h - 1), 0, 14
    RESTOREFIELD
End Sub

Sub SHOWHISCORES
    Const scores.y = 8
    Const scores.x = 42
    Const linestyle = &HFFFF
    View
    Color 15: TEXTOUT scores.y - 2, scores.x + 2, "H I G H  S C O R E S", 1
    Line ((scores.x - 1) * 9 - 3, (scores.y - 1) * 14 - 8)-Step((namelen + 1 + 9) * 9 + 4, 0), 9, , linestyle
    Line ((scores.x + 1) * 9 + 1, (scores.y - 1) * 14 - 8)-Step(0, (scores.y) * 14), 9, , linestyle
    Line ((scores.x - 1) * 9 - 3, (scores.y + hiscorec) * 14 - 8)-Step((namelen + 1 + 9) * 9 + 4, 0), 9, , linestyle
    For i = 0 To hiscorec - 1
        Color 13 + (i <> 0)
        TEXTOUT scores.y + i, scores.x, NUMTOSTR$(i + 1) + ".", -2
        
        fl = 0
        For j = 1 To namelen
            If InStr(Chr$(0), Mid$(hiscore(i).uname, j, 1)) <> 0 Then Mid$(hiscore(i).uname, j, 1) = " " Else fl = 1
        Next
        If fl = 0 Then hiscore(i).uname = "... free place"

        Color 7: TEXTOUT scores.y + i, scores.x + 3, hiscore(i).uname, -2

        a$ = NUMTOSTR$(hiscore(i).score)
        a$ = String$(6 - Len(a$), " ") + a$
        Color 11: TEXTOUT scores.y + i, scores.x + namelen + 4, a$, -2
    Next
    RESTOREFIELD
End Sub

Sub SHOWSCORE (score As Long, lives As Integer)
    Dim ind(1 To 8) As Integer
    Dim im(0 To 10, 0 To 2) As Integer
 
    a$ = LTrim$(RTrim$(Str$(score)))
    a$ = String$(7 - Len(a$), "0") + a$
    For i = 1 To Len(a$)
        ind(i) = Asc(Mid$(a$, i, 1)) - Asc("0") + img0
    Next
    indc = Len(a$)

    For i = 0 To 10
        GETIMAGE anim(ani.stat, img1) + i, im(i, 1), im(i, 2), im(i, 0)
    Next

    View (0, 0)-(f.w + f.x, 14)
    x = f.x
    For i = 1 To indc
        Put (x, 0), graph(im(ind(i), 0)), PSet
        x = x + im(ind(i), 1) + 3
    Next
    View (7 * 15 + f.x + 2, 0)-(7 * 15 + f.x + 2 + f.w, 14)
    GETIMAGE anim(ani.stat, img1) + 10, w, 0, idx
    For i = 0 To lives - 1
        Put (i * (w + 5), 1), graph(idx), PSet
    Next
    Line (lives * (w + 5), 1)-Step(w * 2, 14), 8, BF
    RESTOREFIELD
End Sub

Function TEVENT (t As TIMEINT)
    Dim tmr As Single
    tmr = Timer
    If tmr >= t.starttime + t.interval Or Abs(tmr - t.starttime) > 10000 Then
        t.starttime = Timer
        TEVENT = TRUE
    Else
        TEVENT = FALSE
    End If
End Function

Sub TEXTOUT (row, col, text$, sp)
    'sp = -2
    y = (row - 1) * 14
    If sp < 0 Then Bg = 1: sp = -sp - 1 Else Bg = 0
    x = (col - 1) * (8 + sp)
    For i = 1 To Len(text$)
        idx = Asc(Mid$(text$, i, 1))
        For j = 0 To 15
            ch = Asc(font(idx, j))
            For K = 0 To 7
                c = ch And (2 ^ K)
                If c <> 0 Then
                    PSet (x + 7 - K + (i - 1) * (8 + sp), y + j)
                Else
                    If Bg Then PSet (x + 7 - K + (i - 1) * (8 + sp), y + j), 8
                End If
            Next
        Next
    Next
End Sub

Sub UPDATESCORES
    Open hiscorefile$ For Binary Access Write As #1
    Seek #1, 1
    For i = 0 To hiscorec - 1
        Put #1, , hiscore(i)
    Next
    Close #1
    LOADSCORES hiscorefile, hiscore()
End Sub

