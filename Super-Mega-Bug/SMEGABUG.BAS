'****************************************************************************
'*                                                                          *
'*  SSS                       M   M EEEEE  GGG   AAA      BBBB  U   U  GGG  *
'* S   S                      MM MM E     G   G A   A     B   B U   U G   G *
'* S                          M M M E     G     A   A     B   B U   U G     *
'*  SSS  U  U PPP   EE  R RR  M M M EEEE  G GG  AAAAA === BBBB  U   U G GG  *
'*     S U  U P  P EEEE RR    M   M E     G G G A   A     B   B U   U G G G *
'* S   S U  U P  P E    R     M   M E     G   G A   A     B   B U   U G   G *
'*  SSS   UU  PPP   EE  R     M   M EEEEE  GGG  A   A     BBBB   UUU   GGG  *
'*            P                                                             *
'*            P                                                             *
'*                                                                          *
'*              ***********************************************             *
'*              * When viewing this code in the QB64 IDE you  *             *
'*              * need to set the auto-indent option to 2 if  *             *
'* ** READ **   * you utilize auto-indent. This will preserve *  ** READ ** *
'*              * the correct alignment of the code and its   *             *
'*              * comments.                                   *             *
'*              ***********************************************             *
'*                                                                          *
'* Program Name: Super MEGA-BUG                                             *
'* Program Date: June 27th, 2010                                            *
'* Program Ver : 1.0                                                        *
'* Created by  : Terry Ritchie                                              *
'*             : terry.ritchie@gmail.com (home)                             *
'*             : ritch-t@vscc.k12.oh.us  (school)                           *
'*             : CCNT1 Instructor                                           *
'*             : The Technology Center                                      *
'*             : 1220 Cedar Street, Suite C                                 *
'*             : Fremont, OH 43420                                          *
'*                                                                          *
'* This program and it's source are being distributed as freeware. If you   *
'* make any modifications/improvements to the program please email me a     *
'* a copy of your finished project. I welcome all comments and suggestions. *
'* Please feel free to email me any time.                                   *
'*                                                                          *
'* Super Mega-Bug was originally written in pure QB4.5 code. It was soon    *
'* apparent that even with today's super fast multi Ghz processors that     *
'* the game was going to be too much for QuickBasic 4.5 to handle. While    *
'* searching the Internet for a graphics library to help speed the game up  *
'* QB64 was discovered. QB64 enabled Super Mega-Bug to have excellent       *
'* speed, graphics and sound along with the ability to work in today's      *
'* versions of Windows (and Linux!) all the way up to Windows 7. I would    *
'* like to thank Rob (Galleon), the creator of QB64 and the administrator   *
'* of http://www.qb64.net, for his outstanding QB64 compiler.               *
'*                                                                          *
'* Super Mega-Bug is a recreation of Mega-Bug programmed by Steve Bjork in  *
'* 1982 for the Radio Shack TRS-80 Color Computer. I was fourteen at the    *
'* time and was simply amazed that a computer that ran at less than 1Mhz    *
'* with 4KB of RAM could do so much. The Color Computer, or COCO as it was  *
'* known back then, was an 8 bit computer with a Motorola 6809E processor   *
'* at its core. It was often put down by the Commodore 64 and Apple II fan  *
'* base as being a mediocre computer at best. But programmers like Mr.      *
'* Bjork and hobbyists around the world made the COCO a huge success. Super *
'* Mega-Bug was written for two reasons; to pay homage to the man that made *
'* programming a passion for me and as a training aid to instruct future    *
'* programmers.                                                             *
'*                                                                          *
'* There are many obvious differences from the original Mega-Bug to Super   *
'* Mega-Bug, the most notable the maze size, number of bugs and colors. Oh, *
'* and hyperspace was not available on the original either. :)              *
'*                                                                          *
'* Why QuickBasic? Because it's difficult! (and FUN!)                       *
'*                                                                          *
'* Programmers today have become sloppy and lazy. They rely on "visual"     *
'* languages that remove the programmer from much of the code. By learning  *
'* to program in a language that requires the programmer to code every step *
'* of the way I feel a more well-rounded programmer is created. By learning *
'* to program in QuickBasic a programmer understands what is going on       *
'* behind the scenes in a visual language. This makes, in my opinion, a     *
'* much better programmer. Forcing programmers to code every step creates a *
'* programmer that thinks, not a robot that merely drags and drops elements *
'* onto a screen and relies on M$'s built-in libraries of procedures to do  *
'* the work for them. Again, this is my opinion, flame away! :)             *
'*                                                                          *
'* I've also seen first-hand that programmers that take the visual route    *
'* have a very hard time transitioning to lower level languages such as C   *
'* and Assembler.                                                           *
'*                                                                          *
'* Microsoft did the world a huge injustice by not including a BASIC        *
'* language in their OS beginning with Windows 95. Yes, you could find it   *
'* on the CD in a folder called OLDMSDOS, but Microsoft made no mention of  *
'* this and didn't even give the user an option to install it. Most         *
'* computers in the late 70's and early 80's booted to a flavor of BASIC,   *
'* forcing computer users at the time to learn the language, in effect, to  *
'* become programmers. Today's users point and click in a GUI and if they   *
'* can memorize where everything is located they think they are computer    *
'* wizards. Insane.                                                         *
'*                                                                          *
'*                 Programmers ... DOCUMENT YOUR CODE!!                     *
'*                                                                          *
'*               Always give credit where credit is due!!                   *
'*                                                                          *
'* Again, Galleon and the QB64 compiler: http://www.qb64.net   !!THANKS!!   *
'*                                                                          *
'* I would like to thank Mr. Steve Bjork for creating so many great games   *
'* for the Tandy/Radio Shack Color Computers I/II/III. It was his programs  *
'* that prompted me to take programming seriously and enabled me the        *
'* opportunity to be in the Information Technology fields to this day.      *
'*                                                                          *
'* I would like to thank mazeworks.com for their contribution to this       *
'* program as well. See the "CreateRandomMaze" subroutine for information   *
'* on their contribution and web site.                                      *
'*                                                                          *
'* It's also important to note that MEGA-BUG was a clone of the game called *
'* Dung Beetles created by Bob Bishop for the Apple II and released in 1982 *
'* by Datasoft, founded by Pat Ketchum in 1980. This information was        *
'* obtained from http://en.wikipedia.org/wiki/Dung_Beetles_(computer_game)  *
'*                                                                          *
'* If you would like to try the original game in a JAVA emulator on the web *
'* go to http://www.scottunes.com/main/megabug.htm                          *
'*                                                                          *
'* On this page will be instructions on how to load MEGA-BUG into the COCO  *
'* emulator. Before loading the game, however, go to the settings page of   *
'* the emulator and select high quality audio. Once you've done this then   *
'* select the MEGA-BUG cassette, as per instructions, type CLOADM to load   *
'* the machine language program from cassette (takes about 30 seconds) then *
'* type EXEC to execute the machine language program.                       *
'*                                                                          *
'****************************************************************************

DefInt A-Z '** define all variables as integer

'**
'** define constants ********************************************************
'**

Const False = 0 '          boolean: test for false truth
Const True = Not False '   boolean: test for true truth
Const North = 0 '          test direction and walls (2^north)
Const East = 1 '           (2^east)
Const South = 2 '          (2^south)
Const West = 3 '           (2^west)
Const Maxbugs = 40 '       maximum number of bugs on screen
Const Maxspeed = 32 '      maximum of 32 frames per second (fast!)
Const Uparrow = "UP" '     up arrow key    - move player up
Const Dnarrow = "DN" '     down arrow key  - move player down
Const Rtarrow = "RT" '     right arrow key - move player right
Const Ltarrow = "LT" '     left arrow key  - move player left
Const Spacebar = "SP" '    spacebar key    - wormhole
Const Escape = "ES" '      escape(ESC) key - leave game
Const Pause = "PA" '       P key           - pause game
Const Resetscore = -100 '  resets the score back 0 when used with UpdateScore
Const Highscore = -99 '    saves the high score when used with UpdateScore
Const ShowScore = -98 '    shows high scores when used with UpdateScore
Const Stopmusic = -100 '   stops background music when used with BackMusic

'**
'** define variable types ***************************************************
'**

Type cell '          each maze cell's properties
    walls As Integer '   which cell walls are on/off
    x As Integer '       x location of cell (upper left)
    y As Integer '       y location of cell (upper left)
    npell As Integer '   north red pellet on/off (true/false)
    wpell As Integer '   west red pellet on/off (true/false)
    cpell As Integer '   center red/white pellet on/off (0/1/2)
End Type

Type stack '         LIFO stack to hold visited cells when creating maze
    x As Integer '       x location of previously visited cell
    y As Integer '       y location of previously visited cell
End Type

Type player '        player properties
    x As Integer '       x location of player within current cell (0-3)
    y As Integer '       y location of player within current cell (0-3)
    cx As Integer '      current x location of cell player is in (0-39)
    cy As Integer '      current y location of cell player is in (0-31)
    dir As Integer '     current direction (0=north, 1=east, 2=south, 3=west)
    image As Integer '   current image to show in magnified view (0/1)
End Type

Type bug '           each bug's properties
    x As Integer '       x location of bug within current cell (0-3)
    y As Integer '       y location of bug within current cell (0-3)
    cx As Integer '      current x location of cell bug is in (0-39)
    cy As Integer '      current y location of cell bug is in (0-31)
    dir As Integer '     current direction (0=north, 1=east, 2=south, 3=west)
    image As Integer '   current image to show in magnified view (0/1)
End Type

'**
'** set up functions and procedures *****************************************
'**

DECLARE FUNCTION Fifty50 ()
DECLARE SUB BackMusic (lvl AS INTEGER)
DECLARE SUB DisplayText (xpos AS INTEGER, ypos AS INTEGER, txt AS STRING, fore AS INTEGER, back AS INTEGER, xsize AS INTEGER, ysize AS INTEGER)
DECLARE SUB CreateRandomMaze ()
DECLARE SUB CreateRandomBugs ()
DECLARE SUB DrawCast ()
DECLARE SUB DrawMaze ()
DECLARE SUB DrawCell (cellx AS INTEGER, celly AS INTEGER)
DECLARE SUB RemoveWall (cellx AS INTEGER, celly AS INTEGER, dir AS INTEGER)
DECLARE SUB MoveBugs ()
DECLARE SUB MovePlayer ()
DECLARE SUB Magnifier ()
DECLARE SUB Initialize ()
DECLARE SUB Gotcha ()
DECLARE SUB TitleScreen ()
DECLARE SUB UpdateTime ()
DECLARE SUB UpdateScore (addtoscore AS INTEGER)
DECLARE FUNCTION FileExists (filename AS STRING)
DECLARE SUB ViewInstructions ()
DECLARE SUB PauseGame ()
DECLARE FUNCTION PlayerExits ()
DECLARE SUB LevelUp ()
DECLARE SUB Warp ()
DECLARE SUB DrawWormholes (worms AS INTEGER)
DECLARE SUB SetOptions ()
DECLARE SUB WriteOptions ()
DECLARE SUB ReadOptions ()
DECLARE SUB ChangeFullscreen()

'**
'** define variables ********************************************************
'**

Dim Shared cell(0 To 39, 0 To 31) As cell '  hold cell matrix of 40x32
Dim Shared player As player '                player properties
Dim Shared px As Integer '                   actual x coordinate of player
Dim Shared py As Integer '                   actual y coordinate of player
Dim Shared bug(Maxbugs) As bug '             bug matrix (REDIM PRESERVE?)
Dim Shared bigbug(449) As Integer '          big side bugs
Dim Shared premag(1461) As Integer '         area covered by magnified image
Dim Shared worm(57) As Integer '             wormhole indicator
Dim Shared larmsd(47) As Integer '           big bug left arms down
Dim Shared larmsu(47) As Integer '           big bug left arms up
Dim Shared rarmsd(47) As Integer '           big bug right arms down
Dim Shared rarmsu(47) As Integer '           big bug right arms up
Dim Shared eyesrd(5) As Integer '            big bug eyes right down
Dim Shared eyesru(5) As Integer '            big bug eyes right up
Dim Shared eyesld(5) As Integer '            big bug eyes left down
Dim Shared eyeslu(5) As Integer '            big bug eyes left up
Dim Shared pn0(13) As Integer '              player north image 0
Dim Shared pn1(13) As Integer '              player north image 1
Dim Shared pe0(13) As Integer '              player east  image 0
Dim Shared pe1(13) As Integer '              player east  image 1
Dim Shared ps0(13) As Integer '              player south image 0
Dim Shared ps1(13) As Integer '              player south image 1
Dim Shared pw0(13) As Integer '              player west  image 0
Dim Shared pw1(13) As Integer '              player west  image 1
Dim Shared bn0(13) As Integer '              bug north image 0
Dim Shared bn1(13) As Integer '              bug north image 1
Dim Shared be0(13) As Integer '              bug east  image 0
Dim Shared be1(13) As Integer '              bug east  image 1
Dim Shared bs0(13) As Integer '              bug south image 0
Dim Shared bs1(13) As Integer '              bug south image 1
Dim Shared bw0(13) As Integer '              bug west  image 0
Dim Shared bw1(13) As Integer '              bug west  image 1
Dim Shared bugstep As Integer '              controls bug movement
Dim Shared nextkey As String '               keyboard buffer
Dim Shared olddir As Integer '               direction before forced stop
Dim Shared foodcount As Integer '            number of dots eaten
Dim Shared theygotcha As Integer '           goes true when bug gets you!
Dim Shared text(127, 7) As Integer '         large font letters/numbers
Dim Shared originaltimer As Single '         timer at start of game
Dim Shared bugnum As Integer '               number of current bugs
Dim Shared gamespeed As Integer '            speed of the game
Dim Shared intromusic As Long '              sound handle for intro music
Dim Shared level As Integer '                current level player on
Dim Shared bgmusic As Long '                 snd handle for background music
Dim Shared hellfreezesover '                 that will be a bad day!
Dim Shared playerexited As Integer '         true when player exits game(ESC)
Dim Shared bugspeed As Integer '             speed of bugs in maze
Dim Shared wormhole As Integer '             number of wormholes available
Dim Shared bgvolume As Single '              volume of background music
Dim Shared fscreen As Integer '              fullscreen option 0-no 1-yes
Dim Shared chompsound As Long '              sound handle for chomp sound
Dim Shared difficulty As Integer '           difficulty level of game
Dim smbicon As Long '                        handle to load icon

'**
'** main program begins here ************************************************
'**

_Title "Super Mega-Bug" '             window title
Screen _NewImage(640, 400, 7) '       work in a 640x400 screen
smbicon = _LoadImage("smbicon.bmp") ' load icon
_Icon smbicon '                       set icon
_FreeImage smbicon '                  discard image
DrawCast '                            draw the cast members
Do
    Initialize
    TitleScreen '                       display title screen
    Do '                                new levels start here
        player.cx = 19 '                  player cell to start in (x)
        player.cy = 15 '                  player cell to start in (y)
        player.x = 2 '                    player position within cell (x)
        player.y = 2 '                    player position within cell (y)
        player.dir = -1 '                 set player to no motion
        olddir = 0 '                      image to show when still
        bugstep = 0 '                     initialize bug movement
        foodcount = 0 '                   no food eaten yet
        originaltimer = Timer '           base point for time elapsed in level
        CreateRandomMaze '                create the random looping maze
        CreateRandomBugs '                create the bugs
        DrawMaze '                        draw the maze
        BackMusic level '                 play background music
        Do '                              current level continues playing here
            bugstep = bugstep + 1 '         bug movement counter
            If bugstep > bugspeed Then '    counter greater than bugspeed?
                bugstep = 0 '                 reset counter
            ElseIf bugstep = bugspeed Then 'move bugs now?
                MoveBugs '                    yes, move them now
            End If
            MovePlayer '                    update player movement
            UpdateTime '                    update time elapsed
            Magnifier '                     draw the magnifier
            _Limit gamespeed '              limit loop to 'gamespeed' per second
        Loop Until foodcount = 1280 Or theygotcha Or playerexited
        If playerexited Then theygotcha = True ' player left game
        If theygotcha Then '              They win!
            BackMusic Stopmusic '           stop background music
            Gotcha '                        inform player of bad news
        Else '                            player cleared level. Player wins!
            BackMusic Stopmusic '           stop background music
            LevelUp '                       proceed to next level
        End If
    Loop Until theygotcha '             stop playing when player dead
    UpdateScore Resetscore '            reset score back to 0
Loop Until hellfreezesover '          this will never happen! will it?

'**
'** main program ends here **************************************************
'**

'**
'** define DATA *************************************************************
'**
'
'** player image 0
'
Data 15,15,00,00,15,15
Data 15,00,00,00,00,15
Data 15,15,00,00,15,15
Data 15,00,00,00,00,15
Data 15,15,15,15,15,15
Data 00,00,15,15,00,00
'
'** player image 1
'
Data 00,15,15,15,15,00
Data 00,15,00,00,15,00
Data 00,15,15,15,15,00
Data 00,15,00,00,15,00
Data 00,15,15,15,15,00
Data 00,00,15,15,00,00
'
'** bug image 0
'
Data 04,00,14,14,00,00
Data 00,12,06,06,12,00
Data 00,00,06,06,00,04
Data 04,00,06,06,00,00
Data 00,12,06,06,12,00
Data 00,00,06,06,00,04
'
'** bug image 1
'
Data 00,00,14,14,00,04
Data 00,12,06,06,12,00
Data 04,00,06,06,00,00
Data 00,00,06,06,00,04
Data 00,12,06,06,12,00
Data 04,00,06,06,00,00
'
'** worm in hole
'** (Looks like loch-ness monster! Someone with graphics skills needs to make
'**  this look more like a worm coming out of a hole.)
'
Data 00,00,00,00,00,02,02,02,00,00
Data 00,00,00,00,02,10,10,10,02,00
Data 00,00,00,03,10,10,00,10,10,02
Data 00,00,00,02,10,10,10,10,10,02
Data 00,00,00,02,10,10,10,02,02,00
Data 00,00,00,02,10,10,02,00,00,00
Data 00,00,00,02,10,10,02,00,00,00
Data 00,00,00,02,10,10,02,00,00,00
Data 00,00,00,02,10,10,02,00,00,00
Data 00,08,08,02,10,10,02,08,08,00
Data 08,00,00,02,10,10,02,00,00,08
Data 08,00,00,00,02,02,00,00,00,08
Data 00,08,08,00,00,00,00,08,08,00
Data 00,00,00,08,08,08,08,00,00,00
'
'** big bug eyes looking right and down
'
Data 15,15,06,06,15,15
Data 15,00,06,06,15,00
'
'** big bug eye looking right and up
'
Data 15,00,06,06,15,00
Data 15,15,06,06,15,15
'
'** big bug eyes looking left and down
'
Data 15,15,06,06,15,15
Data 00,15,06,06,00,15
'
'** big bug eyes looking left and up
'
Data 00,15,06,06,00,15
Data 15,15,06,06,15,15
'
'** big standing bug
'
Data -8,0,14,-8,0,14,-1
Data -7,0,14,-10,0,14,-1
Data -7,0,14,-10,0,14,-1
Data -6,0,14,-12,0,14,-1
Data -6,0,14,-12,0,14,-1
Data -7,0,14,-10,0,14,-1
Data -7,0,14,-10,0,14,-1
Data -8,0,14,-8,0,14,-1
Data -9,0,14,-6,0,14,-1
Data -10,0,14,-4,0,14,-1
Data -10,0,6,6,0,0,6,6,-1
Data -9,0,-8,6,-1
Data -8,0,-10,6,-1
Data -8,0,6,6,7,7,6,6,7,7,6,6,-1
Data -7,0,6,6,6,7,0,6,6,7,0,6,6,6,-1
Data -7,0,-12,6,-1
Data -8,0,-10,6,-1
Data -8,0,6,6,6,-4,0,6,6,6,-1
Data -9,0,6,6,6,0,0,6,6,6,-1
Data -10,0,-6,6,-1
Data -11,0,6,4,4,6,-1
Data -7,0,12,12,12,-6,6,12,12,12,-1
Data -4,0,-5,12,-8,6,-5,12,-1
Data 0,0,0,-5,12,-10,6,-5,12,-1
Data 0,0,0,12,12,12,0,0,-4,6,4,4,-4,6,0,0,12,12,12,-1
Data 0,0,0,12,12,0,0,-12,6,0,0,12,12,-1
Data 0,0,0,12,12,0,0,-12,6,0,0,12,12,-1
Data 0,0,0,12,12,0,0,-12,6,0,0,12,12,-1
Data 0,0,12,12,12,0,0,-12,6,0,0,12,12,12,-1
Data 0,0,12,12,12,0,0,-5,6,4,4,-5,6,0,0,12,12,12,-1
Data 0,4,4,4,-4,0,-10,6,-4,0,4,4,4,-1
Data -4,4,-4,0,-10,6,-4,0,-4,4,-1
Data -7,0,12,12,-8,6,12,12,-1
Data -4,0,-7,12,6,4,4,6,-7,12,-1
Data 0,0,0,-6,12,-8,6,-6,12,-1
Data 0,0,0,12,12,12,0,0,-10,6,0,0,12,12,12,-1
Data 0,0,0,12,12,0,0,0,-10,6,0,0,0,12,12,-1
Data 0,0,0,12,12,0,0,-5,6,4,4,-5,6,0,0,12,12,-1
Data 0,0,0,12,12,0,0,-12,6,0,0,12,12,-1
Data 0,0,0,12,12,0,0,-12,6,0,0,12,12,-1
Data 0,0,12,12,12,0,0,-5,6,4,4,-5,6,0,0,12,12,12,-1
Data 0,0,12,12,12,0,0,-12,6,0,0,12,12,12,-1
Data 0,4,4,4,0,0,0,-12,6,0,0,0,4,4,4,-1
Data -4,4,-4,0,-4,6,4,4,-4,6,-4,0,-4,4,-1
Data -6,0,12,12,-10,6,12,12,-1
Data -4,0,-5,12,-8,6,-5,12,-1
Data 0,0,0,-6,12,0,0,-4,6,0,0,-6,12,-1
Data 0,0,0,12,12,12,-14,0,12,12,12,-1
Data 0,0,0,12,12,-16,0,12,12,-1
Data 0,0,0,12,12,-16,0,12,12,-1
Data 0,0,0,12,12,-16,0,12,12,-1
Data 0,0,0,12,12,-16,0,12,12,-1
Data 0,0,12,12,12,-16,0,12,12,12,-1
Data 0,0,12,12,12,-16,0,12,12,12,-1
Data 0,4,4,4,-18,0,4,4,4,-1
Data -4,4,-18,0,-4,4,-1
'
'** large text data (ASCII 32 to 127)
'
Data 0,0,0,0,0,0,0,0
Data 0,0,56,3580,3580,56,0,0
Data 0,14,30,0,0,30,14,0
Data 544,4088,4088,544,4088,4088,544,0
Data 1592,3196,2116,14407,14407,4044,1944,0
Data 3120,1584,768,384,192,3168,3120,0
Data 1920,4056,2172,2276,1980,4056,2112,0
Data 0,16,30,14,0,0,0,0
Data 0,0,1008,2040,3084,2052,0,0
Data 0,0,2052,3084,2040,1008,0,0
Data 128,672,992,448,448,992,672,128
Data 0,128,128,992,992,128,128,0
Data 0,0,4096,7680,3584,0,0,0
Data 128,128,128,128,128,128,128,0
Data 0,0,0,3072,3072,0,0,0
Data 3072,1536,768,384,192,96,48,0
Data 1008,2040,3084,2244,3084,2040,1008,0
Data 0,2064,2072,4092,4092,2048,2048,0
Data 3592,3852,2436,2244,2148,3132,3096,0
Data 1032,3084,2116,2116,2116,4092,1976,0
Data 192,224,176,2200,4092,4092,2176,0
Data 1148,3196,2116,2116,2116,4036,1924,0
Data 2032,4088,2124,2116,2116,4032,1920,0
Data 12,12,3844,3972,196,124,60,0
Data 1976,4092,2116,2116,2116,4092,1976,0
Data 56,2172,2116,2116,3140,2044,1016,0
Data 0,0,0,1584,1584,0,0,0
Data 0,0,2048,3632,1584,0,0,0
Data 0,128,448,864,1584,3096,2056,0
Data 0,288,288,288,288,288,288,0
Data 0,2056,3096,1584,864,448,128,0
Data 24,28,4,3524,3556,60,24,0
Data 2032,4088,2056,3016,3016,3064,496,0
Data 4064,4080,152,140,152,4080,4064,0
Data 2052,4092,4092,2116,2116,4092,1976,0
Data 1008,2040,3084,2052,2052,3084,1560,0
Data 2052,4092,4092,2052,3084,2040,1008,0
Data 2052,4092,4092,2116,2276,3084,3612,0
Data 2052,4092,4092,2116,228,12,28,0
Data 1008,2040,3084,2180,2180,1932,3992,0
Data 4092,4092,64,64,64,4092,4092,0
Data 0,0,2052,4092,4092,2052,0,0
Data 1792,3840,2048,2052,4092,2044,4,0
Data 2052,4092,4092,192,480,3900,3612,0
Data 2052,4092,4092,2052,2048,3072,3584,0
Data 4092,4092,56,112,56,4092,4092,0
Data 4092,4092,56,112,224,4092,4092,0
Data 2040,4092,2052,2052,2052,4092,2040,0
Data 2052,4092,4092,2116,68,124,56,0
Data 2040,4092,2052,3588,15364,16380,10232,0
Data 2052,4092,4092,68,196,4092,3896,0
Data 1560,3644,2148,2116,2244,3996,1816,0
Data 0,28,2060,4092,4092,2060,28,0
Data 2044,4092,2048,2048,2048,4092,2044,0
Data 508,1020,1536,3072,1536,1020,508,0
Data 2044,4092,3584,960,3584,4092,2044,0
Data 3084,3900,1008,480,1008,3900,3084,0
Data 0,60,2172,4032,4032,2172,60,0
Data 3612,3852,2436,2244,2148,3132,3612,0
Data 0,0,4092,4092,2052,2052,0,0
Data 56,112,224,448,896,1792,3584,0
Data 0,0,2052,2052,4092,4092,0,0
Data 8,12,6,3,6,12,8,0
Data 8192,8192,8192,8192,8192,8192,8192,8192
Data 0,0,3,7,4,0,0,0
Data 1792,4000,2208,2208,2016,4032,2048,0
Data 4,4092,4092,2080,2144,4032,1920,0
Data 1984,4064,2080,2080,2080,3168,1088,0
Data 1920,4032,2144,2084,2044,4092,2048,0
Data 1984,4064,2208,2208,2208,3296,1216,0
Data 2112,4088,4092,2116,12,24,0,0
Data 2496,7136,4640,4640,8128,4064,32,0
Data 2052,4092,4092,64,32,4064,4032,0
Data 0,0,2080,4076,4076,2048,0,0
Data 0,3072,7168,4096,4128,8172,4076,0
Data 2052,4092,4092,384,960,3680,3104,0
Data 0,0,2052,4092,4092,2048,0,0
Data 4064,4064,96,1984,96,4064,4032,0
Data 32,4064,4032,32,32,4064,4032,0
Data 1984,4064,2080,2080,2080,4064,1984,0
Data 4128,8160,8128,4640,544,992,448,0
Data 448,992,544,4640,8128,8160,4128,0
Data 2080,4064,4032,2144,32,224,192,0
Data 1088,3296,2464,2336,2848,3680,1088,0
Data 32,32,2040,4092,2080,3104,1024,0
Data 2016,4064,2048,2048,2016,4064,2048,0
Data 0,992,2016,3072,3072,2016,992,0
Data 2016,4064,3072,1920,3072,4064,2016,0
Data 2080,3168,1984,896,1984,3168,2080,0
Data 4576,5088,4608,4608,6656,4064,2016,0
Data 3168,3680,2848,2464,2272,3168,3104,0
Data 0,64,64,2040,4028,2052,2052,0
Data 0,0,0,4028,4028,0,0,0
Data 0,2052,2052,4028,2040,64,64,0
Data 8,12,4,12,8,12,4,0
Data 1920,1984,1120,1072,1120,1984,1920,0

DefInt A-Z
Sub BackMusic (lvl As Integer) Static '                    save variables

    '****************************************************************************
    '*                                                                          *
    '* Plays background music while game is in play. Music chosen is based on   *
    '* level passed into the subroutine. Passing the constant Stopmusic (-100)  *
    '* will turn any background music off that is currently playing.            *
    '*                                                                          *
    '* There are 15 background MIDI files to choose from. Back01-Back05 are     *
    '* slow tempo for level 1. Back06-Back10 are medium tempo for level 2.      *
    '* Back11-Back15 are fast tempo for levels 3 and above.                     *
    '*                                                                          *
    '* NOTE: Possible bug in QB64 found? If you change the variable 'randmusic' *
    '*       to 'rndmusic' the compiler will error. I have no explanation for   *
    '*       this. I've tried recreating the bug in a small program but         *
    '*       'rndmusic' is ok? Curious? It probably has something to do with my *
    '*       code but Galleon will be alerted all the same just in case.        *
    '*                                                                          *
    '****************************************************************************

    Dim mfile As String '                    music file to open
    Dim randmusic As Integer '               random music file to play
    Dim oldmusic As Integer '                music that was played previous level

    If lvl = Stopmusic Then
        _SndStop bgmusic '                                       stop the music
        _SndClose bgmusic '                                      close the music
    Else '                                                     new music
        Select Case lvl '                                        which level?
            Case 1 '                                               level 1
                randmusic = Int(Rnd(1) * 5) + 1 '                    slow tempo music
            Case 2 '                                               level 2
                randmusic = Int(Rnd(1) * 5) + 6 '                    medium tempo music
            Case Else '                                            level 3 and above
                Do
                    randmusic = Int(Rnd(1) * 5) + 11 '                 fast tempo music
                Loop Until randmusic <> oldmusic '                   never twice in row
        End Select
        oldmusic = randmusic '                                   retain for next
        mfile = "BACK" + Right$("0" + LTrim$(RTrim$(Str$(randmusic))), 2) + ".MID"
        bgmusic = _SndOpen(mfile, "VOL") '                       open sound file
        _SndVol bgmusic, bgvolume '                              volume
        _SndLoop bgmusic '                                       loop sound file
    End If

End Sub

DefInt A-Z
Sub CreateRandomBugs

    '****************************************************************************
    '*                                                                          *
    '* Creates random starting points for the bugs.                             *
    '*                                                                          *
    '****************************************************************************

    Dim bc As Integer '                                loop counter
    Dim rx As Integer '                                random x starting location
    Dim ry As Integer '                                random y starting location
    Dim rd As Integer '                                random direction of travel

    For bc = 1 To bugnum '                                     cycle through bugs
        Randomize Timer '                                        seed generator
        Do '                                                     loop until
            rx = Int(Rnd(1) * 40) '                                random x start
        Loop Until rx < 10 Or rx > 29 '                          away from player
        Do '                                                     loop until
            ry = Int(Rnd(1) * 32) '                                random y start
        Loop Until ry < 10 Or ry > 22 '                          away from player
        bug(bc).cx = rx '                                        bug x cell
        bug(bc).cy = ry '                                        bug y cell
        bug(bc).x = 2 '                                          center of cell
        bug(bc).y = 2 '                                          center of cell
        If Fifty50 Then '                                        50/50 chance
            bug(bc).image = 0 '                                    image 0 start
        Else
            bug(bc).image = 1 '                                    image 1 start
        End If
        Do '                                                     loop until
            rd = Int(Rnd(1) * 4) '                                 random direction
        Loop Until Not (cell(rx, ry).walls And 2 ^ rd) '         direction valid?
        bug(bc).dir = rd '                                       set bug direction
    Next bc '                                                  cycle through bugs

End Sub

DefInt A-Z
Sub CreateRandomMaze

    '****************************************************************************
    '*                                                                          *
    '* Creates a random sized braided (looping) maze by first creating a        *
    '* perfect maze (a maze with no loops) then visiting each dead end and      *
    '* randomly opening them to create loops.                                   *
    '*                                                                          *
    '* vcells stores valid next maze cell moves in binary (bit) format          *
    '* if all adjacent cell walls are turned on then that cell is saved in      *
    '* vcells as follows:                                                       *
    '*             bit 1 (2^0) = north cell has all walls on                    *
    '*             bit 2 (2^1) = east  cell has all walls on                    *
    '*             bit 3 (2^2) = south cell has all walls on                    *
    '*             bit 4 (2^3) = west  cell has all walls on                    *
    '*                                                                          *
    '* This subroutine was generated from psuedo-code found at mazeworks.com    *
    '*                                                                          *
    '*         http://www.mazeworks.com/mazegen/mazetut/index.htm               *
    '*                                                                          *
    '* I would like to thank mazeworks.com for taking the time to write their   *
    '* very informative tutorial on braided mazes.                              *
    '*                                                                          *
    '****************************************************************************

    Dim stack(1280) As stack '                      maze generation LIFO stack
    Dim cellx, celly '                              general counters
    Dim ccell As stack '                            current cell being created
    Dim pointer As Integer '                        pointer for use in LIFO stack
    Dim vcells As Integer '                         which cells are valid moves
    Dim randomwall As Integer '                     random valid direction mover
    Dim forward As Integer '                        movement indicator
 
    Randomize Timer '                                          seed generator
    For cellx = 0 To 39 '                                      initialize grid
        For celly = 0 To 31
            cell(cellx, celly).walls = 15 '                        turn all walls on
            cell(cellx, celly).x = 80 + cellx * 4 '                upper left x
            cell(cellx, celly).y = 36 + celly * 4 '                upper left y
            cell(cellx, celly).npell = False '                     north pellet off
            cell(cellx, celly).wpell = False '                     west pellet off
            cell(cellx, celly).cpell = 2 '                         center pellet food
        Next celly
    Next cellx
    ccell.x = Int(Rnd(1) * 39) '                               random x start
    ccell.y = Int(Rnd(1) * 31) '                               random y start
    visitedcells = 1 '                                         initialize counter
    pointer = 0 '                                              LIFO stack pointer
    forward = False '                                          movement indicator
    While visitedcells < 1280 '                                until all cells
        vcells = 0 '                                             valid move check
        '**
        '** The following 12 lines of code look at all four adjoining maze cells
        '** (north, east, south and west) and determine if all the walls in each
        '** cell are turned on. If so each corresponding bit in vcells is turned on
        '** (2^0 = north, 2^1 = east, 2^2 = south, 2^3 = west). If a bit is on (1)
        '** then that direction is a valid move. If a bit is off (0) then that
        '** direction has already been visited (invalid move).
        '**
        If ccell.y <> 0 Then
            If cell(ccell.x, ccell.y - 1).walls = 15 Then vcells = vcells + 1
        End If
        If ccell.x <> 39 Then
            If cell(ccell.x + 1, ccell.y).walls = 15 Then vcells = vcells + 2
        End If
        If ccell.y <> 31 Then
            If cell(ccell.x, ccell.y + 1).walls = 15 Then vcells = vcells + 4
        End If
        If ccell.x <> 0 Then
            If cell(ccell.x - 1, ccell.y).walls = 15 Then vcells = vcells + 8
        End If
        '**
        If vcells <> 0 Then '                                    a cell has walls
            Do '                                                   find random dir
                randomwall = Int(Rnd(1) * 4) '                       select random wall
            Loop Until vcells And 2 ^ randomwall '                 is it valid?
            stack(pointer) = ccell '                               save cell in stack
            pointer = pointer + 1 '                                increment pointer
            visitedcells = visitedcells + 1 '                      increment counter
            forward = True '                                       forward movement
            RemoveWall ccell.x, ccell.y, randomwall '              remove random wall
            Select Case randomwall '                               which direction?
                Case North '                                         north wall
                    ccell.y = ccell.y - 1 '                            move north
                Case East '                                          east wall
                    ccell.x = ccell.x + 1 '                            move east
                Case South '                                         south wall
                    ccell.y = ccell.y + 1 '                            move south
                Case West '                                          west wall
                    ccell.x = ccell.x - 1 '                            move west
            End Select
        Else '                                                   no walls!
            If forward Then '                                      we hit a dead end!
                forward = False '                                    stop movement here
                If Fifty50 Then '                                    make looping maze?
                    Select Case randomwall '                           which random wall?
                        Case North '                                     remove north wall
                            If ccell.y <> 0 Then '                         unless a border
                                RemoveWall ccell.x, ccell.y, randomwall '    remove now
                            End If
                        Case East '                                      remove east wall
                            If ccell.x <> 39 Then '                        unless a border
                                RemoveWall ccell.x, ccell.y, randomwall '    remove now
                            End If
                        Case South '                                     remove south wall
                            If ccell.y <> 31 Then '                        unless a border
                                RemoveWall ccell.x, ccell.y, randomwall '    remove now
                            End If
                        Case West '                                      remove west wall
                            If ccell.x <> 0 Then '                         unless a border
                                RemoveWall ccell.x, ccell.y, randomwall '    remove now
                            End If
                    End Select
                End If
            End If
            pointer = pointer - 1 '                                decrement pointer
            ccell = stack(pointer) '                               go previous cell
        End If
    Wend '                                                     all cells visited

End Sub

DefInt A-Z
Sub DisplayText (xpos As Integer, ypos As Integer, txt As String, fore As Integer, back As Integer, xsize As Integer, ysize As Integer)

    '****************************************************************************
    '*                                                                          *
    '* Prints characters to the screen in custom color and font sizes.          *
    '*                                                                          *
    '* DisplayText X, Y, Text$, Foreground, Background, Xsize, Ysize            *
    '*                                                                          *
    '* X          = X coordinate starting position (upper left)                 *
    '* Y          = Y coordinate starting position (upper right)                *
    '* Text$      = Text to be displayed to the screen                          *
    '* Foreground = color of letters                                            *
    '* Background = color behind letters (-1 for transparent)                   *
    '* Xsize      = width of letters  (use width and height combinations for    *
    '* Ysize      = height of letters  custom aspect ratios)                    *
    '*                                                                          *
    '* I created this subroutine back in the early 90's as a way to easily      *
    '* create big text anywhere on a graphics screen. The DATA for this routine *
    '* was created by printing each ASCII character from 32 to 255 onto a       *
    '* graphics screen at position 1,1. I then read the character's points in   *
    '* saving each vertical column of the character points into a 16bit integer *
    '* value (top point being 2^0, bottom point being 2^13). Each character is  *
    '* 8 pixels wide by 14 pixels high. The routine below simply blows these    *
    '* pixels up based on xsize/ysize passed to it. This game doesn't require   *
    '* the extended ASCII set (128 to 255) so I omitted them from the DATA      *
    '* statements. If you would like the entire ASCII set of 16bit values       *
    '* simply email me and I will send you the entire subroutine intact.        *
    '*                                                                          *
    '* As a side note, this is how I got the idea for the magnifier routine.    *
    '*                                                                          *
    '****************************************************************************

    Dim x As Integer '          keeps track of current x value
    Dim y As Integer '          keeps track of current y value
    Dim tx As Integer '         ASCII value of each individual text character
    Dim character As Integer '  counter used to grab each character from text
    Dim i As Integer '          counter used to keep track of column
    Dim j As Integer '          counter used to read each bit contained in column

    x = xpos '                                                 x start location
    y = ypos '                                                 y start location
    '**
    '** If a background color was specified then draw a box of that color where
    '** text will be drawn.
    '**
    If back > -1 Then
        Line (x, y)-(x + (Len(txt) * 8 * xsize) - 1, y + (14 * ysize) - 1), back, BF
    End If
    '**
    For character = 1 To Len(txt) '                            go through chars
        tx = Asc(Mid$(txt, character, 1)) '                      get ASCII value
        For i = 0 To 7 '                                         current column
            For j = 0 To 13 '                                      cycle through bits
                '**
                '** If a bit is on (1) then draw a line from the current x,y position
                '** to a position of x + xsize, y + ysize in filled box format. This
                '** will give the appearance of the pixels being drawn larger.
                '**
                If text(tx, i) And 2 ^ j Then
                    Line (x, y)-(x + xsize - 1, y + ysize - 1), fore, BF
                End If
                '**
                y = y + ysize '                                      move y position
            Next j '                                               next bit
            x = x + xsize '                                        move x position
            y = ypos '                                             reset y position
        Next i '                                                 next column
    Next character '                                           next character

End Sub

DefInt A-Z
Sub DrawCast

    '****************************************************************************
    '*                                                                          *
    '* Draws and/or retrieves the cast members (bug, player and text images)    *
    '*                                                                          *
    '****************************************************************************

    Dim image As Integer '           which image currently being drawn
    Dim x, y As Integer '            x,y pixel plot positions
    Dim pixel, pcolor As Integer '   pixel and color read in from DATA statements
    Dim character As Integer '       text character currently being read in
    Dim vline, hline As Integer

    Screen , 0, 1, 0 '                       active page 1, view page 0
    For image = 1 To 4 '                     four sets of images to be drawn
        For y = 0 To 5 '                       6x6 matrix for images to be drawn
            For x = 0 To 5 '                     read in 6 pixels
                Read pixel '                       get pixel color
                PSet (x, y), pixel '               draw north facing image (  0')
                PSet (5 - y + 6, x), pixel '       draw east  facing image ( 90')
                PSet (5 - x + 12, 5 - y), pixel '  draw south facing image (180')
                PSet (y + 18, 5 - x), pixel '      draw west  facing image (270')
            Next x
        Next y
        Select Case image '                    which set of images were drawn?
            Case 1 '                             player animated images set 0
                Get (0, 0)-(5, 5), pn0() '         get player north image 0
                Get (6, 0)-(11, 5), pe0() '        get player east  image 0
                Get (12, 0)-(17, 5), ps0() '       get player south image 0
                Get (18, 0)-(23, 5), pw0() '       get player west  image 0
            Case 2 '                             player animated images set 1
                Get (0, 0)-(5, 5), pn1() '         get player north image 1
                Get (6, 0)-(11, 5), pe1() '        get player east  image 1
                Get (12, 0)-(17, 5), ps1() '       get player south image 1
                Get (18, 0)-(23, 5), pw1() '       get player west  image 1
            Case 3 '                             bug animated images set 0
                Get (0, 0)-(5, 5), bn0() '         get bug north image 0
                Get (6, 0)-(11, 5), be0() '        get bug east  image 0
                Get (12, 0)-(17, 5), bs0() '       get bug south image 0
                Get (18, 0)-(23, 5), bw0() '       get bug west  image 0
            Case 4 '                             bug animated images set 1
                Get (0, 0)-(5, 5), bn1() '         get bug north image 1
                Get (6, 0)-(11, 5), be1() '        get bug east  image 1
                Get (12, 0)-(17, 5), bs1() '       get bug south image 1
                Get (18, 0)-(23, 5), bw1() '       get bug west  image 1
        End Select
    Next image
    Cls '                                    clear screen page 1
    For y = 0 To 13 '                        10x14 matrix to be drawn
        For x = 0 To 9 '                       read in 10 pixels
            Read pixel '                         get pixel color
            PSet (x, y), pixel '                 draw worm in hole
        Next x
    Next y
    Get (0, 0)-(9, 13), worm() '             get wormhole image
    Cls '                                    clear screen page 1
    For image = 1 To 4 '                     four sets of images to be drawn
        For y = 0 To 1 '                       6x2 matrix for images to be drawn
            For x = 0 To 5 '                     read in 6 pixels
                Read pixel '                       get pixel color
                PSet (x, y), pixel '               draw eyes
            Next x
        Next y
        Select Case image '                    which image was drawn?
            Case 1 '                             big bug eyes looking right and down
                Get (0, 0)-(5, 1), eyesrd() '      get the image
            Case 2 '                             big bug eyes looking right and up
                Get (0, 0)-(5, 1), eyesru() '      get the image
            Case 3 '                             big bug eyes looking left and down
                Get (0, 0)-(5, 1), eyesld() '      get the image
            Case 4 '                             big bug eyes looking left and up
                Get (0, 0)-(5, 1), eyeslu() '      get the image
        End Select
    Next image
    For y = 0 To 55 '                        draw the big bug (56 pixels high)
        x = 0 '                                start at beginning of line
        Do '                                   keep looping ...
            Read pixel '                         read in first value
            If pixel <> -1 Then '                if equals -1 then end of line
                If pixel < 0 Then '                if less than zero then many
                    Read pcolor '                    read the next value (color)
                    For hline = 1 To Abs(pixel) '    draw many pixels of pcolor
                        PSet (x, y), pcolor '          draw the dot
                        x = x + 1 '                    move dot position to right
                    Next hline
                Else '                             only one pixel to be drawn
                    PSet (x, y), pixel '             draw the dot
                    x = x + 1 '                      move dot position to right
                End If
            End If
        Loop Until pixel = -1 '                ... until end of line (-1)
    Next y
    Get (0, 0)-(25, 55), bigbug() '          get the big bug
    Get (0, 22)-(6, 43), larmsd() '          get big bug's left arms down
    Get (19, 22)-(25, 43), rarmsd() '        get big bug's right arms down
    Cls
    Put (0, 0), larmsd(), PSet '             put left arms down in upper left
    For y = 0 To 21 '                        22x7 matrix for images to be drawn
        For x = 0 To 6 '                       scan 7 pixels
            pixel = Point(x, y) '                get pixel color
            PSet (x + 7, 21 - y), pixel '        draw inverted image
        Next x
    Next y
    Get (7, 0)-(13, 21), larmsu() '          get left arms up
    Put (0, 0), rarmsd(), PSet '             put right arms down in upper left
    For y = 0 To 21 '                        22x7 matrix for images to be drawn
        For x = 0 To 6 '                       scan 7 pixels
            pixel = Point(x, y) '                get pixel color
            PSet (x + 7, 21 - y), pixel '        draw inverted image
        Next x
    Next y
    Get (7, 0)-(13, 21), rarmsu() '          get right arms up
    For character = 32 To 127 '              ASCII chr 32 to 127 for DisplayText
        For vline = 0 To 7 '                   8 vertical lines per character
            Read text(character, vline) '        read in the 16bit integer DATA
        Next vline
    Next character
    Screen , , 0, 0 '                        work on page 0
    Cls '                                    clear page 0

End Sub

DefInt A-Z
Sub DrawCell (cellx As Integer, celly As Integer)

    '****************************************************************************
    '*                                                                          *
    '* Draws the cell specified by cellx,celly to the screen.                   *
    '*                                                                          *
    '****************************************************************************

    '**
    '** The following two lines draw a black cross in the center of the cell.
    '** This resets the bug and player path and wipes out red/white dots.
    '**
    Line (cell(cellx, celly).x + 2, cell(cellx, celly).y)-(cell(cellx, celly).x + 2, cell(cellx, celly).y + 3), 0
    Line (cell(cellx, celly).x, cell(cellx, celly).y + 2)-(cell(cellx, celly).x + 3, cell(cellx, celly).y + 2), 0
    '**
    If cell(cellx, celly).walls And 1 Then '                   north wall present
        '**
        '** The following line draws the north wall in the cell.
        '**
        Line (cell(cellx, celly).x, cell(cellx, celly).y)-(cell(cellx, celly).x + 4, cell(cellx, celly).y), 1
        '**
    Else '                                                     no north wall
        If cell(cellx, celly).npell Then '                       red dot on?
            PSet (cell(cellx, celly).x + 2, cell(cellx, celly).y), 4 'turn it on
        End If
    End If
    '**
    '** The next two lines test for the existance of a wall and draw it. Since red
    '** dots can only be contained in north and west walls there is no need to
    '** test for their existance. The first line draws east walls and the second
    '** line draws south walls.
    '**
    If cell(cellx, celly).walls And 2 Then Line (cell(cellx, celly).x + 4, cell(cellx, celly).y)-(cell(cellx, celly).x + 4, cell(cellx, celly).y + 4), 1
    If cell(cellx, celly).walls And 4 Then Line (cell(cellx, celly).x, cell(cellx, celly).y + 4)-(cell(cellx, celly).x + 4, cell(cellx, celly).y + 4), 1
    '**
    If cell(cellx, celly).walls And 8 Then '                   west wall present
        '**
        '** The following line draws the west wall in the cell.
        '**
        Line (cell(cellx, celly).x, cell(cellx, celly).y)-(cell(cellx, celly).x, cell(cellx, celly).y + 4), 1
        '**
    Else '                                                     no west wall
        If cell(cellx, celly).wpell Then '                       red dot on?
            PSet (cell(cellx, celly).x, cell(cellx, celly).y + 2), 4 'turn it on
        End If
    End If
    '**
    '** The next line colors the center dot according to it's value multiplied by
    '** four, 0=nothing(0), 1=red dot(4), 2=player food(8).
    '**
    PSet (cell(cellx, celly).x + 2, cell(cellx, celly).y + 2), cell(cellx, celly).cpell * 4

End Sub

DefInt A-Z
Sub DrawMaze

    '****************************************************************************
    '*                                                                          *
    '* Draws the entire maze to the graphics screen.                            *
    '*                                                                          *
    '****************************************************************************

    Dim x As Integer '                loop counter: holds x location of maze cell
    Dim y As Integer '                loop counter: holds y location of maze cell
    Dim yline As Integer '            counter used for screen wipe

    Screen , , 1, 0 '                                          work on page 1
    Cls '                                                      clear page 1
    For x = 0 To 39 '                                          cycle cells
        For y = 0 To 31 '                                        in y,x fashion
            DrawCell x, y '                                        draw cell at x,y
        Next y
    Next x
    Line (79, 35)-(241, 165), 1, B '                           maze border
    Put (27, 72), bigbug(), PSet '                             big bug left
    Put (266, 72), bigbug(), PSet '                            big bug right
    DrawWormholes wormhole '                                   wormholes left
    DisplayText 48, 5, "Time: 00:00:00", 4, 0, 2, 2 '          draw time text
    DisplayText 64, 168, "Score: 00000", 4, 0, 2, 2 '          draw score text
    UpdateTime '                                               for level 2+
    UpdateScore 0 '                                            for level 2+
    _PutImage (0, 0)-(_Width - 1, _Height - 1), 1, 4, (0, 0)-(319, 199)
    Screen , , 3, 2 '                                          work on page 3
    For yline = 0 To 200 '                                     screen wipe
        PCopy 4, 3 '                                             copy page 4 to 3
        Line (0, 0)-(639, 200 - yline), 0, BF '                  blank top area
        Line (0, 399)-(639, 200 + yline), 0, BF '                blank bottom area
        Line (0, 200 - yline)-(639, 200 - yline), 15 '           top wipe line
        Line (0, 200 + yline)-(639, 200 + yline), 15 '           bottom wipe line
        PCopy 3, 2 '                                             copy page 3 to 2
        _Limit 150 '                                             150 frames per sec
    Next yline
    Screen , , 1, 0 '                                          work on page 1
    _PutImage (0, 0)-(_Width - 1, _Height - 1), 1, 0, (0, 0)-(319, 199)
    _SndPlayFile "getready.wav", 1, 1 '                        la Cucaracha
    _Delay 11 '                                                wait 11 seconds

End Sub

DefInt A-Z
Function Fifty50

    '****************************************************************************
    '*                                                                          *
    '* There is a 50/50 chance of this function returning a true or false.      *
    '*                                                                          *
    '****************************************************************************

    Randomize Timer '                                          seed generator
    If Int(Rnd(1) * 2) + 1 = 1 Then '                          random 1?
        Fifty50 = True '                                         return true
    Else '                                                     random 0
        Fifty50 = False '                                        return false
    End If

End Function

DefInt A-Z
Sub Gotcha

    '****************************************************************************
    '*                                                                          *
    '* We gotcha! Player has quit or been eaten by a bug.                       *
    '*                                                                          *
    '****************************************************************************

    Dim dance As Integer '              controls which animation sequence to show
    Dim dancecount As Integer '         counts the number of dances done
    Dim yline As Integer '              counter used for screen wipes

    If playerexited Then
        _SndPlayFile "gameover.wav" '                            that's it man!
    Else
        _SndPlayFile "wegotcha.wav" '                            play We Gotcha!
    End If
    dance = 0 '                                                init sequence
    PCopy 1, 3 '                                               copy page 1 to 3
    Screen , , 2, 0 '                                          work on page 2
    Cls '                                                      clear screen 2
    Screen , , 3, 2 '                                          work on page 3
    For dancecount = 1 To 20 '                                 dance there you!
        dance = 1 - dance '                                      cycle sequence
        Line (27, 85)-(33, 115), 0, BF '                         clear left arm
        Line (46, 85)-(53, 115), 0, BF '                         clear right arm
        Line (266, 85)-(272, 115), 0, BF '                       clear left arm
        Line (285, 85)-(292, 115), 0, BF '                       clear right arm
        If dance = 0 Then '                                      sequence 1
            Put (27, 94), larmsd(), PSet '                         left down
            Put (46, 85), rarmsu(), PSet '                         right up
            Put (266, 85), larmsu(), PSet '                        left up
            Put (285, 94), rarmsd(), PSet '                        right down
            Put (37, 85), eyesrd(), PSet '                         eyes right down
            Put (276, 85), eyeslu(), PSet '                        eyes left up
        Else '                                                   sequence 2
            Put (27, 85), larmsu(), PSet '                         left up
            Put (46, 94), rarmsd(), PSet '                         right down
            Put (266, 94), larmsd(), PSet '                        left down
            Put (285, 85), rarmsu(), PSet '                        right up
            Put (37, 85), eyesru(), PSet '                         eyes right up
            Put (276, 85), eyesld(), PSet '                        eyes left down
        End If
        _PutImage (0, 0)-(_Width - 1, _Height - 1), 3, 2, (0, 0)-(319, 199)
        _Limit 4 '                                               4 dances per sec
    Next dancecount
    Screen , , 1, 0 '                                          work on page 1
    For yline = 200 To 0 Step -1
        PCopy 2, 1
        Line (0, 0)-(639, 200 - yline), 0, BF '                  blank top area
        Line (0, 399)-(639, 200 + yline), 0, BF '                blank bottom area
        Line (0, 200 - yline)-(639, 200 - yline), 15 '           top wipe line
        Line (0, 200 + yline)-(639, 200 + yline), 15 '           bottom wipe line
        PCopy 1, 0
        _Limit 150
    Next yline
    UpdateScore Highscore '                                    save hi score

End Sub

DefInt A-Z
Sub Initialize
    '****************************************************************************
    '*                                                                          *
    '* initialize variables                                                     *
    '*                                                                          *
    '****************************************************************************

    Dim full As Integer '                        used to check full screen status

    Randomize Timer '                            seed random number generator
    chompsound = _SndOpen("chomp.wav", "VOL,SYNC") ' handle for chomp.wav
    theygotcha = False '                         they haven't got you yet
    playerexited = False '                       true when player leaves game
    hellfreezesover = False '                    not today
    level = 1 '                                  game starts on level 1
    difficulty = 2 '                             default difficulty level
    fscreen = 0 '                                default fullscreen option
    bgvolume = .33 '                             default background volume
    bugnum = 16 '                                default starting number of bugs
    gamespeed = 16 '                             default starting game speed
    bugspeed = 4 '                               default bug speed
    wormhole = 1 '                               default number of wormholes
    ReadOptions '                                read options from OPTIONS.SMB
    If fscreen = 1 Then '                        fullscreen option is turned on
        full = _FullScreen '                       check full screen status
        If full = 0 Then '                         not at full screen yet?
            _FullScreen '                            go full screen
            _Delay 2 '                               wait for video card to sync
        End If
    End If

End Sub

DefInt A-Z
Sub Magnifier

    '****************************************************************************
    '*                                                                          *
    '* Creates the magnified area.                                              *
    '*                                                                          *
    '* An area of 35x35 pixels (17 right/left/up/down from player) is grabbed   *
    '* into array magarea. The maze area that will be overwritten by the        *
    '* magnifier is then saved in array premag to be used later to restore the  *
    '* original maze. The area to be magnified, array magarea, is placed onto   *
    '* page 2 in the upper left hand corner. This image is scanned from left to *
    '* right in a vertical fashion and the image is redrawn double the size in  *
    '* the center of the screen on page 2. Bug positions are then looked at to  *
    '* see if they fall within the magnified area. If so they are drawn on the  *
    '* magnified area in their correct position and orientation. The player's   *
    '* image is then placed on the magnified image in its correct position and  *
    '* orientation. If a bug and player collide then the boolean variable       *
    '* theygotcha is set to true. The magnified image is now grabbed and placed *
    '* into an array called magnified. This magnified image is now placed in    *
    '* the correct position over top of the maze located on page 1. Page 1 is   *
    '* now copied to page 0, giving the illusion of animation. The original     *
    '* image of the affected maze area, held in the array premag, is now placed *
    '* back over the magnified area to restore the maze to its original         *
    '* condition.                                                               *
    '*                                                                          *
    '* This routine was written when Super Mega-Bug was still pure QB4.5 code.  *
    '* QB64 contains the _PUTIMAGE command that can stretch an image as it is   *
    '* drawn to the screen. This may be a superior method of creating the       *
    '* magnified area and will be investigated in version 2.                    *
    '*                                                                          *
    '****************************************************************************

    Dim magarea(362) As Integer '       area of screen that gets magnified
    Dim magnified(1448) As Integer '    magnified image
    Dim x As Integer '                  counter used to draw magnified area
    Dim bx As Integer '                 actual x coordinate of bugs on screen
    Dim y As Integer '                  counter used to draw magnified image
    Dim by As Integer '                 actual y coordinate of bugs on screen
    Dim pcolor As Integer '             color of each pixel to be magnified
    Dim bc As Integer '                 counter used to cycle through all bugs
    Dim cellx1 As Integer '             upper left x cell in magnified area
    Dim cellx2 As Integer '             lower right x cell in magnified area
    Dim celly1 As Integer '             upper left y cell in magnified area
    Dim celly2 As Integer '             lower right y cell in magnified area

    px = cell(player.cx, player.cy).x + player.x '             player x location
    py = cell(player.cx, player.cy).y + player.y '             player y location
    cellx1 = player.cx - 5 '                                   upper left area x
    If cellx1 < 0 Then cellx1 = 0 '                            fix if border
    cellx2 = player.cx + 5 '                                   lower right area x
    If cellx2 > 39 Then cellx2 = 39 '                          fix if border
    celly1 = player.cy - 5 '                                   upper left area y
    If celly1 < 0 Then celly1 = 0 '                            fix if border
    celly2 = player.cy + 5 '                                   lower right area y
    If celly2 > 31 Then celly2 = 31 '                          fix if border
    Get (px - 36, py - 36)-(px + 36, py + 36), premag() '      save maze area
    Get (px - 17, py - 17)-(px + 17, py + 17), magarea() '     area to be mag'ed
    Screen , , 2, 0 '                                          work on page 2
    Put (0, 0), magarea(), PSet '                              draw area
    For y = 0 To 34 '                                          scan area from
        For x = 0 To 34 '                                        left to right
            pcolor = Point(x, y) '                                 get pixel's color
            If pcolor = 8 Then pcolor = 7 '                        brighten food dots
            Line (126 + x * 2, 66 + y * 2)-(126 + x * 2 + 1, 66 + y * 2 + 1), pcolor, BF
        Next x
    Next y
    For bc = 1 To bugnum '                                     cycle through bugs
        '**
        '** The following line tests to see if bug falls within magnified area.
        '**
        If bug(bc).cx >= cellx1 And bug(bc).cx <= cellx2 And bug(bc).cy >= celly1 And bug(bc).cy <= celly2 Then
            bx = cell(bug(bc).cx, bug(bc).cy).x + bug(bc).x '      bug x location
            by = cell(bug(bc).cx, bug(bc).cy).y + bug(bc).y '      bug y location
            bx = bx + (bx - px) + (158 - px) '                     correct for shift
            by = by + (by - py) + (98 - py) '                      in mag area
            Select Case bug(bc).dir '                              which bug dir?
                Case North '                                         heading north
                    If bug(bc).image = 0 Then '                        which image?
                        Put (bx, by), bn0(), PSet '                      north image 0
                    Else
                        Put (bx, by), bn1(), PSet '                      north image 1
                    End If
                Case East '                                          heading east
                    If bug(bc).image = 0 Then '                        which image?
                        Put (bx, by), be0(), PSet '                      east image 0
                    Else
                        Put (bx, by), be1(), PSet '                      east image 1
                    End If
                Case South '                                         heading south
                    If bug(bc).image = 0 Then '                        which image?
                        Put (bx, by), bs0(), PSet '                      south image 0
                    Else
                        Put (bx, by), bs1(), PSet '                      south image 1
                    End If
                Case West '                                          heading west
                    If bug(bc).image = 0 Then '                        which image?
                        Put (bx, by), bw0(), PSet '                      west image 0
                    Else
                        Put (bx, by), bw1(), PSet '                      west image 1
                    End If
            End Select
            If Abs(158 - bx) < 6 And Abs(98 - by) < 6 Then '       bug get player?
                theygotcha = True '                                  ouch!! yes!
            End If
        End If
    Next bc '                                                  test each bug
    player.image = 1 - player.image '                          rotate image
    Select Case player.dir '                                   player direction?
        Case North '                                             heading north
            If player.image = 0 Then '                             which image?
                Put (158, 98), pn0(), PSet '                         north image 0
            Else
                Put (158, 98), pn1(), PSet '                         north image 1
            End If
        Case East '                                              heading east
            If player.image = 0 Then '                             which image?
                Put (158, 98), pe0(), PSet '                         east image 0
            Else
                Put (158, 98), pe1(), PSet '                         east image 1
            End If
        Case South '                                             heading south
            If player.image = 0 Then '                             which image?
                Put (158, 98), ps0(), PSet '                         south image 0
            Else
                Put (158, 98), ps1(), PSet '                         south image 1
            End If
        Case West '                                              heading west
            If player.image = 0 Then '                             which image?
                Put (158, 98), pw0(), PSet '                         west image 0
            Else
                Put (158, 98), pw1(), PSet '                         west image 1
            End If
        Case Else '                                              standing still?
            Select Case olddir '                                   what was dir?
                Case North '                                         was heading north
                    If player.image = 0 Then '                         which image?
                        Put (158, 98), pn0(), PSet '                     north image 0
                    Else
                        Put (158, 98), pn1(), PSet '                     north image 1
                    End If
                Case East '                                          was heading east
                    If player.image = 0 Then '                         which image?
                        Put (158, 98), pe0(), PSet '                     east image 0
                    Else
                        Put (158, 98), pe1(), PSet '                     east image 1
                    End If
                Case South '                                         was heading south
                    If player.image = 0 Then '                         which image?
                        Put (158, 98), ps0(), PSet '                     south image 0
                    Else
                        Put (158, 98), ps1(), PSet '                     south image 1
                    End If
                Case West '                                          was heading west
                    If player.image = 0 Then '                         which image?
                        Put (158, 98), pw0(), PSet '                     west image 0
                    Else
                        Put (158, 98), pw1(), PSet '                     west image 1
                    End If
            End Select
    End Select
    Get (126, 66)-(194, 134), magnified() '                    get new mag area
    Screen , , 1, 0 '                                          work on page 1
    Put (px - 34, py - 34), magnified(), PSet '                draw mag area
    Line (px - 36, py - 36)-(px + 36, py + 36), 15, B '        draw double width
    Line (px - 35, py - 35)-(px + 35, py + 35), 15, B '        border around mag
    '**
    '** The following line grabs the image from page 1 and copies to page 0,
    '** stretching the 320x200 image over a 640x400 screen. This line was
    '** suggested by Galleon, the administrator of QB64.net. It allowed my
    '** original QB4.5 code to stay intact which originally used screen 7 for
    '** graphics. Nice trick!
    '**
    _PutImage (0, 0)-(_Width - 1, _Height - 1), 1, 0, (0, 0)-(319, 199)
    '**
    Put (px - 36, py - 36), premag(), PSet '                   restore maze

End Sub

DefInt A-Z
Sub MoveBugs

    '****************************************************************************
    '*                                                                          *
    '* Updates bug movement on the screen.                                      *
    '*                                                                          *
    '****************************************************************************

    Dim bc As Integer '                    loop counter (bugcount)
    Dim lookright As Integer '             the direction to the right
    Dim lookleft As Integer '              the direction to the left
    Dim reverse As Integer '               opposite direction
    Dim deadend As Integer '               will be > 0 if dead end encountered
    Dim rightwall As Integer '             will be > 0 if wall to right present
    Dim leftwall As Integer '              will be > 0 if wall to left present
    Dim redahead As Integer '              boolean: is red pellet straight ahead?
    Dim redright As Integer '              boolean: is red pellet to the right?
    Dim redleft As Integer '               boolean: is red pellet to the left?

    For bc = 1 To bugnum '                                     loop through bugs
        If bug(bc).x = 2 And bug(bc).y = 2 Then '                center of cell
            If cell(bug(bc).cx, bug(bc).cy).cpell = 1 Then '       center dot red?
                cell(bug(bc).cx, bug(bc).cy).cpell = 0 '             turn it off
            End If
            lookright = bug(bc).dir + 1 '                          right dir
            If lookright = 4 Then lookright = 0 '                  correct the dir
            lookleft = bug(bc).dir - 1 '                           left dir
            If lookleft = -1 Then lookleft = 3 '                   correct the dir
            '**
            '** The next three lines look at the wall ahead (deadend), to the
            '** right (rightwall) and to the left (leftwall). If a wall is present
            '** in any of these directions then the corresponding variable will be
            '** greater than 0.
            '**
            deadend = cell(bug(bc).cx, bug(bc).cy).walls And 2 ^ bug(bc).dir
            rightwall = cell(bug(bc).cx, bug(bc).cy).walls And 2 ^ lookright
            leftwall = cell(bug(bc).cx, bug(bc).cy).walls And 2 ^ lookleft
            '**
            redahead = False '                                     initialize flags
            redright = False '                                     that look for red
            redleft = False '                                      dots in bug path
            '**
            '** The following CASE statement looks for red dots in the path of each
            '** each bug. if a red dot is ahead (redahead), to the right (redright)
            '** of to the left (redleft) then the corresponding boolean flag is set
            '** true indicating a red dot near.
            '**
            Select Case bug(bc).dir '                              which bug dir?
                Case North '                                         heading north
                    redahead = cell(bug(bc).cx, bug(bc).cy).npell '    north red dot?
                    If bug(bc).cx < 39 Then '                          on a border cell?
                        redright = cell(bug(bc).cx + 1, bug(bc).cy).wpell 'red dot right?
                    End If
                    redleft = cell(bug(bc).cx, bug(bc).cy).wpell '     red dot left?
                Case East '                                          heading east
                    If bug(bc).cx < 39 Then '                          on a border cell?
                        redahead = cell(bug(bc).cx + 1, bug(bc).cy).wpell 'red dot ahead?
                    End If
                    If bug(bc).cy < 31 Then '                          on a border cell?
                        redright = cell(bug(bc).cx, bug(bc).cy + 1).npell 'red dot right?
                    End If
                    redleft = cell(bug(bc).cx, bug(bc).cy).npell '     red dot left
                Case South '                                         heading south
                    If bug(bc).cy < 31 Then '                          on a border cell?
                        redahead = cell(bug(bc).cx, bug(bc).cy + 1).npell 'red dot ahead?
                    End If
                    redright = cell(bug(bc).cx, bug(bc).cy).wpell '    red dot right?
                    If bug(bc).cx < 39 Then '                          on a border cell?
                        redleft = cell(bug(bc).cx + 1, bug(bc).cy).wpell 'red dot left?
                    End If
                Case West '                                          heading west
                    redahead = cell(bug(bc).cx, bug(bc).cy).wpell '    red dot ahead?
                    redright = cell(bug(bc).cx, bug(bc).cy).npell '    red dot right?
                    If bug(bc).cy < 31 Then '                          on a border cell?
                        redleft = cell(bug(bc).cx, bug(bc).cy + 1).npell 'red dot left?
                    End If
            End Select
            '**
            If deadend > 0 Then '                                  hit wall?
                If rightwall > 0 And leftwall > 0 Then '             surrounded?
                    reverse = bug(bc).dir + 2 '                        get reverse
                    If reverse > 3 Then reverse = reverse - 4 '        correct the dir
                    bug(bc).dir = reverse '                            reverse bug dir
                ElseIf rightwall > 0 Then '                          wall to right?
                    bug(bc).dir = lookleft '                           go left
                ElseIf leftwall > 0 Then '                           wall to left?
                    bug(bc).dir = lookright '                          go right
                Else '                                               both dirs open
                    If (Not redright) And (Not redleft) Then '         no red right/left?
                        If Fifty50 Then '                                which dir?
                            bug(bc).dir = lookleft '                       go left
                        Else
                            bug(bc).dir = lookright '                      go right
                        End If
                    ElseIf redright And (Not redleft) Then '           red dot right?
                        bug(bc).dir = lookright '                        go right
                    ElseIf redleft And (Not redright) Then '           red dot left?
                        bug(bc).dir = lookleft '                         go left
                    ElseIf redright And redleft Then '                 red right/left?
                        If Fifty50 Then '                                which dir?
                            bug(bc).dir = lookleft '                       go left
                        Else
                            bug(bc).dir = lookright '                      go right
                        End If
                    End If
                End If
            Else '                                                 not a dead end
                '**
                '** The following line looks in all three directions (forward,
                '** right and left) for red dots. It's important to remember to
                '** perform the NOT operations first when working with boolean
                '** operators such as AND or unpredictable results may occur.
                '**
                If (Not redahead) And (Not redright) And (Not redleft) Then
                    If (Not rightwall > 0) And Fifty50 Then '          no wall right, go?
                        bug(bc).dir = lookright '                        make bug go right
                    ElseIf (Not leftwall > 0) And Fifty50 Then '       no wall left, go?
                        bug(bc).dir = lookleft '                         make bug go left
                    End If
                    '**
                    '** The following line tests for the existance of a red dot to the
                    '** right only.
                    '**
                ElseIf redright And (Not redahead) And (Not redleft) Then
                    bug(bc).dir = lookright '                          bug must go right
                    '**
                    '** The following line tests for the existance of a red dot to the
                    '** left only.
                    '**
                ElseIf redleft And (Not redahead) And (Not redright) Then
                    bug(bc).dir = lookleft '                           bug must go left
                    '**
                    '** The following line tests for the existance of red dots to the
                    '** right and left but not forward.
                    '**
                ElseIf redright And redleft And (Not redahead) Then
                    If Fifty50 Then '                                  which dir?
                        bug(bc).dir = lookright '                        make bug go right
                    Else
                        bug(bc).dir = lookleft '                         make bug go left
                    End If
                    '**
                    '** The following line tests for the existance of red dots to the
                    '** right and forward.
                    '**
                ElseIf redright And redahead And (Not redleft) Then
                    If Fifty50 Then bug(bc).dir = lookright '          go right?
                    '**
                    '** The following line tests for the existance of red dots to the
                    '** left and forward.
                    '**
                ElseIf redleft And redahead And (Not redright) Then
                    If Fifty50 Then bug(bc).dir = lookleft '           go left?
                End If '                                             no dir taken? then
            End If '                                               keep going forward
        End If
        DrawCell bug(bc).cx, bug(bc).cy '                        clear old cell
        Select Case bug(bc).dir '                                which dir?
            Case North '                                           bug heading north
                bug(bc).y = bug(bc).y - 1 '                          move up in cell
                If bug(bc).y = -1 Then '                             too far?
                    bug(bc).y = 3 '                                    move to bottom
                    bug(bc).cy = bug(bc).cy - 1 '                      of next cell
                End If
                If bug(bc).y = 0 Then '                              top of cell?
                    If cell(bug(bc).cx, bug(bc).cy).npell Then '       red dot on?
                        cell(bug(bc).cx, bug(bc).cy).npell = False '     turn red dot off
                    End If
                End If
            Case East '                                            bug heading east
                If bug(bc).x = 0 Then '                              leftmost in cell?
                    If cell(bug(bc).cx, bug(bc).cy).wpell Then '       red dot on?
                        cell(bug(bc).cx, bug(bc).cy).wpell = False '     turn red dot off
                    End If
                End If
                bug(bc).x = bug(bc).x + 1 '                          move bug right
                If bug(bc).x = 4 Then '                              too far?
                    bug(bc).x = 0 '                                    move to left
                    bug(bc).cx = bug(bc).cx + 1 '                      of next cell
                End If
            Case South '                                           bug heading south
                If bug(bc).y = 0 Then '                              top of cell?
                    If cell(bug(bc).cx, bug(bc).cy).npell Then '       red dot on?
                        cell(bug(bc).cx, bug(bc).cy).npell = False '     turn red dot off
                    End If
                End If
                bug(bc).y = bug(bc).y + 1 '                          move bug down
                If bug(bc).y = 4 Then '                              too far?
                    bug(bc).y = 0 '                                    move to top
                    bug(bc).cy = bug(bc).cy + 1 '                      of next cell
                End If
            Case West '                                            bug heading west
                bug(bc).x = bug(bc).x - 1 '                          move bug left
                If bug(bc).x = -1 Then '                             too far?
                    bug(bc).x = 3 '                                    move to right
                    bug(bc).cx = bug(bc).cx - 1 '                      of next cell
                End If
                If bug(bc).x = 0 Then '                              leftmost in cell?
                    If cell(bug(bc).cx, bug(bc).cy).wpell Then '       red dot on?
                        cell(bug(bc).cx, bug(bc).cy).wpell = False '     turn red dot off
                    End If
                End If
        End Select
        bug(bc).image = 1 - bug(bc).image '                      rotate bug image
        '**
        '** The following line draws the bug onto the maze.
        '**
        PSet (cell(bug(bc).cx, bug(bc).cy).x + bug(bc).x, cell(bug(bc).cx, bug(bc).cy).y + bug(bc).y), 6
    Next bc '                                                  cycle through bugs

End Sub

DefInt A-Z
Sub MovePlayer

    '****************************************************************************
    '*                                                                          *
    '* Moves player in the direction desired by the user.                       *
    '*                                                                          *
    '* NOTE: Possible bug discovered in QB64. If a test for the space bar is    *
    '*       done using a space .. " " .. the IF statement will pick it up      *
    '*       every time? Even if I assign the space to a CONSTant and then use  *
    '*       the constant to test with IF the same result happens? This is why  *
    '*       I decided to use CONSTants with the first two letters of the key   *
    '*       being pressed .. i.e. Uparrow = "UP", Spacebar = "SP" and so on.   *
    '*       This is probably due to my code but Galleon will be alerted just   *
    '*       in case.                                                           *
    '*                                                                          *
    '****************************************************************************

    Dim keypress As String '    test for key user may press
    Dim northwall As Integer '  test for existance of wall to the north
    Dim eastwall As Integer '   test for existance of wall to the east
    Dim southwall As Integer '  test for existance of wall to the south
    Dim westwall As Integer '   test for existance of wall to the west
    Dim reverse As Integer '    contains the opposite direction player traveling
    Dim controlkey As Integer ' test to see if a control key was pressed
    Dim clearbuffer As String ' used to clear the keyboard buffer

    Do
        clearbuffer = InKey$ '                                   get key in buffer
        If clearbuffer <> "" Then '                              buffer clear?
            keypress = clearbuffer '                               no, save key
        End If
    Loop Until clearbuffer = "" '                              buffer now clear
    If Len(keypress) > 1 Then controlkey = True '              control key?
    keypress = UCase$(Right$(keypress, 1)) '                   format key input
    If keypress = Chr$(72) Then nextkey = Uparrow '            up arrow pressed
    If keypress = Chr$(75) Then nextkey = Ltarrow '            left arrow pressed
    If keypress = Chr$(77) Then nextkey = Rtarrow '            right arrow press
    If keypress = Chr$(80) Then nextkey = Dnarrow '            down arrow pressed
    If keypress = Chr$(32) Then nextkey = Spacebar '           space bar pressed
    If keypress = Chr$(27) Then nextkey = Escape '             escape pressed
    If Not controlkey Then '                                   not control key?
        If keypress = Chr$(80) Then '                            P only pressed?
            nextkey = Pause '                                      yes, only P key
        End If
    End If

    If player.x = 2 And player.y = 2 Then '                    center of cell?
        '**
        '** The following line checks for existance of a wall ahead of player.
        '**
        If cell(player.cx, player.cy).walls And 2 ^ player.dir Then
            olddir = player.dir '                                  save current dir
            player.dir = -1 '                                      stop player
        End If
        If cell(player.cx, player.cy).cpell = 2 Then '           white dot?
            UpdateScore 10 '                                       add 10 to score
            foodcount = foodcount + 1 '                            add 1 to foodcount
            _SndPlayCopy chompsound '                              chomp, chomp ..
        End If
        cell(player.cx, player.cy).cpell = 1 '                   create red dot
        If nextkey <> "" Then '                                  key in buffer?
            '**
            '** The following four lines test for the existance of a wall to the
            '** north (northwall), east (eastwall), south (southwall) and west
            '** (westwall) then saves the result into the corresponding variable.
            '** If a wall exists then the variable will be greater than zero.
            '**
            northwall = cell(player.cx, player.cy).walls And 2 ^ North
            eastwall = cell(player.cx, player.cy).walls And 2 ^ East
            southwall = cell(player.cx, player.cy).walls And 2 ^ South
            westwall = cell(player.cx, player.cy).walls And 2 ^ West
            '**
            Select Case nextkey '                                  which key pressed?
                Case Uparrow '                                       up arrow key
                    If northwall = 0 Then '                            wall to north?
                        player.dir = North '                             set dir north
                        nextkey = "" '                                   clear buffer
                    End If
                Case Rtarrow '                                       right arrow key
                    If eastwall = 0 Then '                             wall to east?
                        player.dir = East '                              set dir east
                        nextkey = "" '                                   clear buffer
                    End If
                Case Dnarrow '                                       down arrow key
                    If southwall = 0 Then '                            wall to south?
                        player.dir = South '                             set dir south
                        nextkey = "" '                                   clear buffer
                    End If
                Case Ltarrow '                                       left arrow key
                    If westwall = 0 Then '                             wall to west?
                        player.dir = West '                              set dir west
                        nextkey = "" '                                   clear buffer
                    End If
                Case Spacebar '                                      space bar key
                    If wormhole > 0 Then '                             wormholes left?
                        Warp '                                           yes, warp player
                        nextkey = "" '                                   clear buffer
                    End If
                Case Escape '                                        escape key
                    If PlayerExits Then playerexited = True '          player left game
                    nextkey = ""
                Case Pause '                                         P key
                    PauseGame '                                        pause the game
                    nextkey = "" '                                     clear buffer
            End Select
        End If
    Else
        If player.x = 0 Then '                                   top of cell?
            cell(player.cx, player.cy).wpell = True '              create red dot
        End If
        If player.y = 0 Then '                                   leftmost in cell?
            cell(player.cx, player.cy).npell = True '              create red dot
        End If
        If nextkey <> "" Then '                                  key in buffer?
            reverse = player.dir + 2 '                             get reverse dir
            If reverse > 3 Then reverse = reverse - 4 '            correct the dir
            '**
            '** The following CASE statement allows the player to reverse direction at
            '** any time during game play.
            '**
            Select Case player.dir '                               which player dir?
                Case North '                                         moving north
                    If nextkey = Dnarrow Then '                        down arrow key?
                        player.dir = reverse '                           reverse player dir
                        nextkey = "" '                                   clear buffer
                    End If
                Case East '                                          moving east
                    If nextkey = Ltarrow Then '                        left arrow key?
                        player.dir = reverse '                           reverse player dir
                        nextkey = "" '                                   clear buffer
                    End If
                Case South '                                         moving south
                    If nextkey = Uparrow Then '                        up arrow key?
                        player.dir = reverse '                           reverse player dir
                        nextkey = "" '                                   clear buffer
                    End If
                Case West '                                          moving west
                    If nextkey = Rtarrow Then '                        right arrow key?
                        player.dir = reverse '                           reverse player dir
                        nextkey = "" '                                   clear buffer
                    End If
            End Select
        End If
    End If
    DrawCell player.cx, player.cy '                            clear old cell
    Select Case player.dir '                                   which player dir?
        Case North '                                             moving north
            player.y = player.y - 1 '                              move player
            If player.y = -1 Then '                                too far?
                player.y = 3 '                                       move to bottom of
                player.cy = player.cy - 1 '                          next cell
            End If
        Case East '                                              moving east
            player.x = player.x + 1 '                              move player
            If player.x = 4 Then '                                 too far?
                player.x = 0 '                                       move to left of
                player.cx = player.cx + 1 '                          next cell
            End If
        Case South '                                             moving south
            player.y = player.y + 1 '                              move player
            If player.y = 4 Then '                                 too far?
                player.y = 0 '                                       move to top of
                player.cy = player.cy + 1 '                          next cell
            End If
        Case West '                                              moving west
            player.x = player.x - 1 '                              move player
            If player.x = -1 Then '                                too far?
                player.x = 3 '                                       move to right of
                player.cx = player.cx - 1 '                          next cell
            End If
    End Select
    DrawCell player.cx, player.cy '                            draw new cell
    If player.cy = 12 Then '                                   update bug eyes
        Put (37, 85), eyesru(), PSet '                           eyes right up
        Put (276, 85), eyeslu(), PSet '                          eyes left up
    ElseIf player.cy = 13 Then
        Put (37, 85), eyesrd(), PSet '                           eyes right down
        Put (276, 85), eyesld(), PSet '                          eyes left down
    End If

End Sub

DefInt A-Z
Sub RemoveWall (cellx As Integer, celly As Integer, dir As Integer)

    '****************************************************************************
    '*                                                                          *
    '* Removes the walls between two adjoining cells based on the direction of  *
    '* movement. This routine is only used during maze generation.              *
    '*                                                                          *
    '****************************************************************************

    Select Case dir '                                          which direction?
        Case North '                                             remove north/south
            cell(cellx, celly).walls = cell(cellx, celly).walls - 1 '             2^0
            cell(cellx, celly - 1).walls = cell(cellx, celly - 1).walls - 4 '     2^2
        Case East '                                              remove east/west
            cell(cellx, celly).walls = cell(cellx, celly).walls - 2 '             2^1
            cell(cellx + 1, celly).walls = cell(cellx + 1, celly).walls - 8 '     2^3
        Case South '                                             remove south/north
            cell(cellx, celly).walls = cell(cellx, celly).walls - 4 '             2^2
            cell(cellx, celly + 1).walls = cell(cellx, celly + 1).walls - 1 '     2^0
        Case West '                                              remove west/east
            cell(cellx, celly).walls = cell(cellx, celly).walls - 8 '             2^3
            cell(cellx - 1, celly).walls = cell(cellx - 1, celly).walls - 2 '     2^1
    End Select

End Sub

DefInt A-Z
Sub TitleScreen

    '****************************************************************************
    '*                                                                          *
    '* Draws the title screen.                                                  *
    '*                                                                          *
    '****************************************************************************

    Dim col1 As Integer '                      red/white/blue rotating colors
    Dim col2 As Integer '                      red/white/blue rotating colors
    Dim col3 As Integer '                      red/white/blue rotating colors
    Dim colrotate As Integer '                 keeps track of rotating colors
    Dim yline As Integer '                     used to keep track of screen wiper
    Dim volume As Single '                     volume of intro music
    Dim keypress As String * 1 '               player response
    Dim gamestart As Integer '                 true when player starts game
    Dim counter As Integer '                   used to count 1/5th of a second

    Screen , , 2, 0 '                                          work on page 2
    Cls '                                                      clear page 2
    colrotate = 1 '                                            init color rotater
    volume = 1 '                                               full volume
    gamestart = False '                                        no game yet
    intromusic = _SndOpen("intromusic.wav", "VOL") '           open intro music
    _SndVol intromusic, volume '                               set music volume
    _SndLoop intromusic '                                      loop intro music
    DisplayText 152, 0, "Super Mega-Bug", 15, 0, 3, 3
    DisplayText 296, 39, "By", 1, 0, 3, 3 '                    display intro
    DisplayText 164, 78, "Terry Ritchie", 1, 0, 3, 3 '         screen text to
    DisplayText 164, 156, "Copyleft 2010", 4, 0, 3, 3 '        player
    DisplayText 80, 195, "RitchCraft Creations", 4, 0, 3, 3
    DisplayText 188, 273, "Licensed to", 1, 0, 3, 3
    DisplayText 104, 312, "Handy Corporations", 1, 0, 3, 3
    DisplayText 8, 370, "( )tart ( )nstructions ( )ptions ( )uit", 8, 0, 2, 2
    DisplayText 24, 370, "S", 15, 0, 2, 2 '                    highlight "S"
    DisplayText 152, 370, "I", 15, 0, 2, 2 '                   highlight "I"
    DisplayText 392, 370, "O", 15, 0, 2, 2 '                   highlight "O"
    DisplayText 552, 370, "Q", 15, 0, 2, 2 '                   highlight "Q"
    Screen , , 1, 0 '                                          work on page 1
    For yline = 0 To 200 '                                     draw 200 lines
        PCopy 2, 1 '                                             copy page 2 to 1
        Line (0, 0)-(639, 200 - yline), 0, BF '                  blank top area
        Line (0, 399)-(639, 200 + yline), 0, BF '                blank bottom area
        Line (0, 200 - yline)-(639, 200 - yline), 15 '           top wipe line
        Line (0, 200 + yline)-(639, 200 + yline), 15 '           bottom wipe line
        PCopy 1, 0 '                                             copy page 1 to 0
        _Limit 150 '                                             150 times per sec
    Next yline
    PCopy 2, 0 '                                               copy page 2 to 0
    Screen , , 0, 0 '                                          work on page 0
    counter = 0 '                                              reset counter
    Do
        Select Case colrotate '                                  which color combo?
            Case 1 '                                               red/white/blue
                col1 = 4: col2 = 15: col3 = 1 '                      set colors
            Case 2 '                                               blue/red/white
                col1 = 1: col2 = 4: col3 = 15 '                      set colors
            Case 3 '                                               white/blue/red
                col1 = 15: col2 = 1: col3 = 4 '                      set colors
        End Select
        DisplayText 152, 0, "S", col1, 0, 3, 3 '                 draw the color
        DisplayText 176, 0, "u", col2, 0, 3, 3 '                 rotating
        DisplayText 200, 0, "p", col3, 0, 3, 3 '                 "Super Mega-Bug"
        DisplayText 224, 0, "e", col1, 0, 3, 3
        DisplayText 248, 0, "r", col2, 0, 3, 3
        DisplayText 296, 0, "M", col3, 0, 3, 3
        DisplayText 320, 0, "e", col1, 0, 3, 3
        DisplayText 344, 0, "g", col2, 0, 3, 3
        DisplayText 368, 0, "a", col3, 0, 3, 3
        DisplayText 392, 0, "-", col1, 0, 3, 3
        DisplayText 416, 0, "B", col2, 0, 3, 3
        DisplayText 440, 0, "u", col3, 0, 3, 3
        DisplayText 464, 0, "g", col1, 0, 3, 3
        colrotate = colrotate + 1 '                              rotate the colors
        If colrotate = 4 Then colrotate = 1 '                    too far then reset
        _Limit 5 '                                               5 rotates per sec
        keypress = UCase$(InKey$) '                              get player input
        If keypress <> "" Then '                                 was key pressed?
            Select Case keypress '                                 which key was it?
                Case "S" '                                           "S" key pressed
                    gamestart = True '                                 set gamestart flag
                    counter = 0 '                                      reset counter
                Case "I" '                                           "I" key pressed
                    ViewInstructions '                                 view instructions
                    counter = 0 '                                      reset counter
                Case "O" '                                           "O" key pressed
                    SetOptions '                                       set the options
                    counter = 0 '                                      reset counter
                Case "Q" '                                           "Q" key pressed
                    _SndStop intromusic '                              stop intro music
                    _SndClose intromusic '                             close intro music
                    _SndPlayFile "quit.wav" '                          bugs laugh at you!
                    _Delay 2 '                                         wait 2 seconds
                    Screen 0, 0, 0, 0 '                                go to text screen
                    Cls '                                              clear text screen
                    System '                                           back to the OS
            End Select
        End If
        counter = counter + 1 '                                  1/5th second
        If counter = 50 Then '                                   10 seconds?
            counter = 0 '                                          reset counter
            UpdateScore ShowScore '                                show high scores
        End If
    Loop Until gamestart '                                     start game?
    Screen , , 1, 0 '                                          work on page 1
    For yline = 200 To 0 Step -1 '                             draw 200 lines
        volume = volume - .005 '                                 music volume down
        If volume < 0 Then volume = 0 '                          not to far
        _SndVol intromusic, volume '                             change volume now
        PCopy 2, 1 '                                             copy page 2 to 1
        Line (0, 0)-(639, 200 - yline), 0, BF '                  blank top area
        Line (0, 399)-(639, 200 + yline), 0, BF '                blank bottom area
        Line (0, 200 - yline)-(639, 200 - yline), 15 '           top wipe line
        Line (0, 200 + yline)-(639, 200 + yline), 15 '           bottom wipe line
        PCopy 1, 0 '                                             copy page 1 to 0
        _Limit 150 '                                             150 times per sec
    Next yline
    _SndStop intromusic '                                      stop intro music
    _SndClose intromusic '                                     close intro music
    Screen , , 0, 0 '                                          work on page 0
    Cls '                                                      clear page 0

End Sub

DefInt A-Z
Sub UpdateScore (addtoscore As Integer) Static '           save variables

    '****************************************************************************
    '*                                                                          *
    '* Updates the score. Passing the constant "Highscore" (-99) will cause the *
    '* high score to be saved to a file called "HISCORE.SMB". Passing the       *
    '* constant "Resetscore" (-100) will cause the score to be reset to 0.      *
    '* Passing the CONSTant "Showscore" (-98) will display high scores.         *
    '*                                                                          *
    '****************************************************************************

    Dim score As Long '                             game score
    Dim easyhigh As String '                        easy difficulty high score
    Dim normalhigh As String '                      normal difficulty high score
    Dim hardhigh As String '                        hard difficulty high score
    Dim counter As Integer '                        used to count 1/5th of second
    Dim keypress As String '                        check for player input

    Select Case addtoscore '                                   what was passed?
        Case Resetscore '                                        reset score to 0
            score = 0 '                                            score now = 0
        Case Highscore '                                         save high score
            easyhigh = "00000" '                                   clear easy score
            normalhigh = "00000" '                                 clear normal score
            hardhigh = "00000" '                                   clear hard score
            If _FileExists("HISCORE.SMB") Then '                    score file exist?
                Open "HISCORE.SMB" For Input As #1 '                 yes, open it
                Line Input #1, easyhigh '                            get easy score
                Line Input #1, normalhigh '                          get normal score
                Line Input #1, hardhigh '                            get hard score
                Close #1 '                                           close score file
                Kill "HISCORE.SMB" '                                 delete score file
            End If
            Select Case difficulty '                               difficulty level?
                Case 1 '                                             1 - easy
                    If Val(easyhigh) < score Then '                    new high score?
                        easyhigh = LTrim$(RTrim$(Str$(score))) '         hold new score
                    End If
                Case 2 '                                             2 - normal
                    If Val(normalhigh) < score Then '                  new high score?
                        normalhigh = LTrim$(RTrim$(Str$(score))) '       hold new score
                    End If
                Case 3 '                                             3 - hard
                    If Val(hardhigh) < score Then '                    new high score?
                        hardhigh = LTrim$(RTrim$(Str$(score))) '         hold new score
                    End If
            End Select
            Open "HISCORE.SMB" For Output As #1 '                  new score file
            Print #1, Right$("0000" + easyhigh, 5) '               save easy score
            Print #1, Right$("0000" + normalhigh, 5) '             save normal score
            Print #1, Right$("0000" + hardhigh, 5) '               save hard score
            Close #1 '                                             close score file
        Case ShowScore '                                         display scores
            easyhigh = "00000" '                                   clear easy score
            normalhigh = "00000" '                                 clear normal score
            hardhigh = "00000" '                                   clear hard score
            If _FileExists("HISCORE.SMB") Then '                    score file exist?
                Open "HISCORE.SMB" For Input As #1 '                 yes, open it
                Line Input #1, easyhigh '                            get easy score
                Line Input #1, normalhigh '                          get normal score
                Line Input #1, hardhigh '                            get hard score
                Close #1 '                                           close score file
            End If
            Screen , , 1, 1 '                                      work on page 1
            Cls '                                                  clear page 1
            counter = 0 '                                          reset counter
            DisplayText 0, 0, " Super Mega-Bug Hi Scores", 15, 0, 3, 3
            DisplayText 0, 108, "             Easy   : " + easyhigh, 1, 0, 2, 2
            DisplayText 0, 168, "             Normal : " + normalhigh, 1, 0, 2, 2
            DisplayText 0, 228, "             Hard   : " + hardhigh, 1, 0, 2, 2
            DisplayText 0, 288, " Do you think you have what it takes to ", 4, 0, 2, 2
            DisplayText 0, 318, " beat the bugs and achieve a high score?", 4, 0, 2, 2
            DisplayText 0, 348, "  Play Super Mega-Bug now to find out!  ", 15, 0, 2, 2
            Do
                counter = counter + 1 '                              1/5th second
                keypress = InKey$ '                                  was key pressed?
                _Limit 5 '                                           5 loops per second
            Loop Until counter = 50 Or keypress <> "" '            10 secs or key
            Screen , , 0, 0 '                                      work on page 0
        Case Else '                                              update score
            score = score + addtoscore '                           add to score
            If score < 0 Then score = 0 '                          too low?
            '**
            '** The following line draws large text to the screen in red double the
            '** normal size (4, 0, 2, 2).
            '**
            DisplayText 176, 168, Right$("0000" + LTrim$(RTrim$(Str$(score))), 5), 4, 0, 2, 2
            '**
    End Select

End Sub

DefInt A-Z
Sub UpdateTime Static '                                    save variables

    '****************************************************************************
    '*                                                                          *
    '* Updates the time.                                                        *
    '*                                                                          *
    '****************************************************************************

    Dim current As Single '             elapsed TIMER value since start of game
    Dim hours As Integer '              hours computed from elapsed time
    Dim minutes As Integer '            minutes computed from elapsed time
    Dim seconds As Integer '            seconds computed from elapsed time
    Dim oldhours As Integer '           hour value last time subroutine visited
    Dim oldminutes As Integer '         minute value last time subroutine visited
    Dim oldseconds As Integer '         second value last time subroutine visited

    If Timer < originaltimer Then '                            pass midnight?
        current = Timer - originaltimer + 86400 '                fix elapsed time
    Else '                                                     still on same day
        current = Timer - originaltimer '                        get elapsed time
    End If
    hours = Int(current / 3600) '                              compute hours
    minutes = Int((current - hours * 3600) / 60) '             compute minutes
    seconds = current Mod 60 '                                 compute seconds
    If seconds <> oldseconds Then '                            seconds changed?
        DisplayText 240, 5, Right$("0" + LTrim$(RTrim$(Str$(seconds))), 2), 4, 0, 2, 2
        UpdateScore -1 '                                         subtract score
        oldseconds = seconds '                                   save seconds
    End If
    If minutes <> oldminutes Then '                            minutes changed?
        DisplayText 192, 5, Right$("0" + LTrim$(RTrim$(Str$(minutes))), 2), 4, 0, 2, 2
        oldminutes = minutes '                                   save minutes
    End If
    If hours <> oldhours Then '                                hours changed?
        DisplayText 144, 5, Right$("0" + LTrim$(RTrim$(Str$(hours))), 2), 4, 0, 2, 2
        oldhours = hours '                                       save hours
    End If

End Sub

DefInt A-Z
Sub ViewInstructions

    '****************************************************************************
    '*                                                                          *
    '* Displays the instructions screen for the user.                           *
    '*                                                                          *
    '****************************************************************************

    Screen , , 1, 1 '                                          work on page 1
    Cls '                                                      clear page 1
    DisplayText 8, 0, "How to play Super Mega-Bug", 15, 0, 3, 3
    DisplayText 0, 66, "     Arrow Keys - Move Your Chomper", 1, 0, 2, 2
    DisplayText 0, 108, "     Spacebar   - Wormhole", 1, 0, 2, 2
    DisplayText 0, 150, "     P key      - Pause Game", 1, 0, 2, 2
    DisplayText 0, 192, "     ESC key    - Leave Game", 1, 0, 2, 2
    DisplayText 0, 234, " Your chomper is trapped in a maze and", 4, 0, 2, 2
    DisplayText 0, 262, " the only way out is to eat all the", 4, 0, 2, 2
    DisplayText 0, 290, " white pellets the bugs are protecting.", 4, 0, 2, 2
    DisplayText 0, 318, " As you navigate the maze you leave a", 4, 0, 2, 2
    DisplayText 0, 346, " red trail that the bugs will follow!", 4, 0, 2, 2
    Do: Loop Until InKey$ <> "" '                              wait for key press
    Screen , , 0, 0 '                                          work on page 0

End Sub

DefInt A-Z
Sub PauseGame

    '****************************************************************************
    '*                                                                          *
    '* Pauses game play until a key is pressed                                  *
    '*                                                                          *
    '****************************************************************************

    Dim blink As Integer '                                    make the text blink

    blink = 0 '                                                initialize blinker
    Screen , , 2, 2 '                                          work on page 2
    Cls '                                                      clear the page
    Do
        blink = 1 - blink '                                      rotate blinker
        DisplayText 80, 150, "Super Mega-Bug Has Been Paused", 14 * blink, 0, 2, 2
        _Limit 2 '                                               2 loops per sec
    Loop Until InKey$ <> "" '                                  wait for key
    Screen , , 1, 0 '                                          work on page 1

End Sub

DefInt A-Z
Function PlayerExits

    '****************************************************************************
    '*                                                                          *
    '* Asks the player if he/she wishes to exit the game. Returns True if the   *
    '* player chooses to exit, returns False if the user chooses to keep        *
    '* playing.                                                                 *
    '*                                                                          *
    '****************************************************************************

    Dim response As String '                    player's response to Y/N question

    Screen , , 2, 2 '                                          work on page 2
    Cls '                                                      clear page 2
    DisplayText 192, 158, "Exit Game? (Y/N)", 14, 0, 2, 2 '    ask user
    Do
        response = UCase$(InKey$) '                              get player choice
    Loop Until response <> ""
    If response = "Y" Then '                                   player choose yes?
        PlayerExits = True '                                     yes, return True
    Else '                                                     yes not chosen
        PlayerExits = False '                                    return False
    End If
    Screen , , 1, 0 '                                          work on page 1

End Function

DefInt A-Z
Sub LevelUp

    '****************************************************************************
    '*                                                                          *
    '* Increases level difficulty                                               *
    '*                                                                          *
    '****************************************************************************

    Dim counter As Integer '           counter used to count 1/2 second intervals
    Dim clr As Integer '               current color of text
    Dim rotateclr As Integer '         color rotater

    level = level + 1 '                          proceed to next level
    Select Case level '                          which level is player on?
        Case 2 '                                   level 2 (** pretty good **)
            bugnum = bugnum + 8 '                    add 8 bugs to maze
            bugspeed = bugspeed - 1 '                speed the bugs up
            gamespeed = gamespeed + 0 '              speed the game up
            wormhole = wormhole + 1 '                players earns a wormhole
        Case 3 '                                   level 3 (** excellent! **)
            bugnum = bugnum + 8 '                    add 8 bugs to maze
            bugspeed = bugspeed - 1 '                speed the bugs up
            gamespeed = gamespeed + 2 '              speed the game up
            wormhole = wormhole + 1 '                player earns a wormhole
        Case 4 '                                   level 4 (** super human! **)
            bugnum = bugnum + 8 '                    add 8 bugs to maze
            bugspeed = bugspeed - 1 '                speed the bugs up
            gamespeed = gamespeed + 4 '              speed the game up
            wormhole = wormhole + 1 '                player earns a wormhole
        Case 5 '                                   level 5 (** android playing! **)
            bugnum = bugnum + 8 '                    add 8 bugs to the maze
            bugspeed = bugspeed - 1 '                speed the bugs up
            gamespeed = gamespeed + 4 '              speed the game up
            wormhole = wormhole + 1 '                player earns a wormhole
        Case Else '                                level 6 and up (** NO WAY! **)
            bugnum = bugnum + 8 '                    add 8 bugs to the maze
            bugspeed = bugspeed - 1 '                speed the bugs up
            gamespeed = gamespeed + 4 '              speed the game up
            wormhole = wormhole + 1 '                player earns a wormhole
    End Select
    If bugnum > Maxbugs Then bugnum = Maxbugs '  don't exceed max bugs allowed
    If bugspeed < 1 Then bugspeed = 1 '          don't exceed max bug speed
    If gamespeed > 32 Then gamespeed = 32 '      don't exceed max game speed
    If wormhole > 5 Then wormhole = 5 '          don't exceed max wormholes
    Screen , , 0, 0 '                            work on page 0
    clr = 8 '                                    text color to 8 (dark grey)
    rotateclr = 1 '                              color rotater
    counter = 0 '                                counts 1/2 second
    Do
        DisplayText 40, 150, "LEVEL CLEARED!", clr, -1, 5, 5 ' inform user
        rotateclr = 1 - rotateclr '                rotate text color
        If rotateclr = 1 Then '                    which color?
            clr = 8 '                                dark grey
        Else
            clr = 15 '                               bright white
        End If
        counter = counter + 1 '                    count 1/2 second
        If counter = 4 Then _SndPlayFile "woohoo.wav", 1, 1 ' woohoo!
        _Limit 2 '                                 2 loops per second
    Loop Until counter = 10 '                    5 seconds passed?
    Screen , , 1, 0 '                            work on page 1

End Sub

DefInt A-Z
Sub Warp

    '****************************************************************************
    '*                                                                          *
    '* Wormhole routine. Warps player to another part of the maze.              *
    '*                                                                          *
    '****************************************************************************

    Dim warpcount As Integer '          counter to draw ever smaller/larger boxes

    PCopy 1, 3 '                                               copy page 1 to 3
    Screen , , 3, 2 '                                          work on page 3
    _PutImage (0, 0)-(_Width - 1, _Height - 1), 3, 2, (0, 0)-(319, 199)
    _SndPlayFile "WORMHOLE.WAV", 1, 1
    For warpcount = 36 To 1 Step -1 '                          big to small box
        Put (px - 36, py - 36), premag(), PSet '                 repair area
        Line (px - warpcount, py - warpcount)-(px + warpcount, py + warpcount), 0, BF
        Line (px - warpcount, py - warpcount)-(px + warpcount, py + warpcount), 15, B
        _PutImage (0, 0)-(_Width - 1, _Height - 1), 3, 2, (0, 0)-(319, 199)
        _Limit 72 '                                              72 FPS
    Next warpcount
    player.cx = Int(Rnd(1) * 39) '                             new player cell x
    player.cy = Int(Rnd(1) * 31) '                             new player cell y
    player.x = 2 '                                             center in cell x
    player.y = 2 '                                             center in cell y
    player.dir = -1 '                                          stop player dir
    px = cell(player.cx, player.cy).x + player.x '             player x location
    py = cell(player.cx, player.cy).y + player.y '             player y location
    Get (px - 36, py - 36)-(px + 36, py + 36), premag() '      hold warp-in area
    For warpcount = 1 To 36 '                                  small to big box
        Put (px - 36, py - 36), premag(), PSet '                 repair area
        Line (px - warpcount, py - warpcount)-(px + warpcount, py + warpcount), 0, BF
        Line (px - warpcount, py - warpcount)-(px + warpcount, py + warpcount), 15, B
        _PutImage (0, 0)-(_Width - 1, _Height - 1), 3, 2, (0, 0)-(319, 199)
        _Limit 72 '                                              72 FPS
    Next warpcount
    Screen , , 1, 0 '                                          work on page 1
    wormhole = wormhole - 1 '                                  take wormhole away
    DrawWormholes wormhole '                                   wormholes left

End Sub

DefInt A-Z
Sub DrawWormholes (worms As Integer)

    '****************************************************************************
    '*                                                                          *
    '* Draws the number of wormholes that the player has remaining.             *
    '*                                                                          *
    '****************************************************************************

    Dim wormcount As Integer '            counter used to cycle through wormholes

    Line (5, 176)-(55, 189), 0, BF '                           clear wormholes
    For wormcount = 0 To worms - 1 '                           cycle worms
        Put (wormcount * 10 + 5, 176), worm() '                  draw worm
    Next wormcount

End Sub

DefInt A-Z
Sub SetOptions

    '****************************************************************************
    '*                                                                          *
    '* Allows the player to change options.                                     *
    '*                                                                          *
    '****************************************************************************

    Dim done As Integer '                    true when player done making changes
    Dim keypress As String '                 player's input
    Dim oldfscreen As Integer '              holds current fullscreen status

    Screen , , 1, 1 '                                          work on page 1
    Cls '                                                      clear page 1
    DisplayText 0, 0, "  Super Mega-Bug Options", 15, 0, 3, 3
    DisplayText 0, 108, "     Difficulty Level: ( ) ( ) ( )", 1, 0, 2, 2
    DisplayText 0, 168, "     Background Music:", 1, 0, 2, 2
    DisplayText 0, 228, "     Full Screen     : ( )es ( )o", 1, 0, 2, 2
    DisplayText 0, 288, "   Press key of option you would like ", 4, 0, 2, 2
    DisplayText 0, 318, "   change. Press the UP and DOWN arrow", 4, 0, 2, 2
    DisplayText 0, 348, "  keys to change volume. ENTER to exit.", 4, 0, 2, 2
    done = False '                                             set done flag
    oldfscreen = fscreen '                                     hold current value
    Do
        Select Case difficulty '                                 difficulty level?
            Case 1 '                                               1 - easy
                DisplayText 384, 108, "1", 15, 0, 2, 2 '             highlight "1"
                DisplayText 384, 138, "Easy        ", 15, 0, 2, 2 '  display "Easy"
                DisplayText 448, 108, "2", 8, 0, 2, 2 '              unhighlight "2"
                DisplayText 512, 108, "3", 8, 0, 2, 2 '              unhighlight "3"
            Case 2 '                                               2 - normal
                DisplayText 448, 108, "2", 15, 0, 2, 2 '             highlight "2"
                DisplayText 384, 138, "    Normal  ", 15, 0, 2, 2 '  display "Normal"
                DisplayText 384, 108, "1", 8, 0, 2, 2 '              unhighlight "1"
                DisplayText 512, 108, "3", 8, 0, 2, 2 '              unhighlight "3"
            Case 3 '                                               3 - hard
                DisplayText 512, 108, "3", 15, 0, 2, 2 '             highlight "3"
                DisplayText 384, 138, "        Hard", 15, 0, 2, 2 '  display "Hard"
                DisplayText 384, 108, "1", 8, 0, 2, 2 '              unhighlight "1"
                DisplayText 448, 108, "2", 8, 0, 2, 2 '              unhighlight "2"
        End Select
        DisplayText 368, 168, Right$("  " + LTrim$(RTrim$(Str$(Int(bgvolume * 100))) + "%"), 4), 15, 0, 2, 2
        If fscreen = 1 Then '                                    fullscreen on
            DisplayText 384, 228, "Y", 15, 0, 2, 2 '               highlight "Y"
            DisplayText 480, 228, "N", 8, 0, 2, 2 '                unhighlight "N"
        Else '                                                   windowed mode
            DisplayText 480, 228, "N", 15, 0, 2, 2 '               highlight "N"
            DisplayText 384, 228, "Y", 8, 0, 2, 2 '                unhighlight "Y"
        End If
        Do '                                                     wait for key
            keypress = InKey$ '                                    get user input
        Loop Until keypress <> "" '                              was key pressed?
        keypress = UCase$(Right$(keypress, 1)) '                 format key input
        Select Case keypress '                                   which key pressed?
            Case "H" '                                             UP arrow key
                bgvolume = bgvolume + .01 '                          increase volume
                If bgvolume > 1 Then bgvolume = 1 '                  don't exceed limit
            Case "P" '                                             DOWN arrow key
                bgvolume = bgvolume - .01 '                          decrease volume
                If bgvolume < 0 Then bgvolume = 0 '                  don't go below 0
            Case "1" '                                             "1" key
                difficulty = 1 '                                     set to easy
            Case "2" '                                             "2" key
                difficulty = 2 '                                     set to normal
            Case "3" '                                             "3" key
                difficulty = 3 '                                     set to hard
            Case "Y" '                                             "Y" key
                fscreen = 1 '                                        fullscreen on
            Case "N" '                                             "N" key
                fscreen = 0 '                                        fullscreen off
            Case Chr$(13) '                                        ENTER key
                done = True '                                        done with changes
        End Select
    Loop Until done '                                          player finished?
    WriteOptions '                                             write options file
    ReadOptions '                                              read options file
    If oldfscreen <> fscreen Then ChangeFullscreen '           status change?
    Screen , , 0, 0 '                                          work on page 0

End Sub

DefInt A-Z
Sub WriteOptions

    '****************************************************************************
    '*                                                                          *
    '* Creates the options file OPTIONS.SMB.                                    *
    '*                                                                          *
    '****************************************************************************

    Open "OPTIONS.SMB" For Output As #1 '                      write option file
    Print #1, ";-------------------------------------------" ' print file's
    Print #1, ";This is the options file for Super Mega-Bug" ' contents
    Print #1, ";-------------------------------------------"
    Print #1, "[DIFFICULTY]"
    Print #1, LTrim$(RTrim$(Str$(difficulty))) '               difficulty level
    Print #1, ";"
    Print #1, "; Difficulty Values"
    Print #1, ";"
    Print #1, ";   1 - Easy"
    Print #1, ";   2 - Normal"
    Print #1, ";   3 - Hard"
    Print #1, ";-------------------------------------------"
    Print #1, "[BGMUSIC]"
    Print #1, LTrim$(RTrim$(Str$(Int(bgvolume * 100)))) '      background volume
    Print #1, ";"
    Print #1, "; Background Music Values"
    Print #1, ";"
    Print #1, ";   0             - Off"
    Print #1, ";   1 through 100 - Volume Percentage"
    Print #1, ";-------------------------------------------"
    Print #1, "[FULLSCREEN]"
    Print #1, LTrim$(RTrim$(Str$(fscreen))) '                  screen state
    Print #1, ";"
    Print #1, "; Fullscreen Values"
    Print #1, ";"
    Print #1, ";   1 - Yes"
    Print #1, ";   0 - No"
    Close #1 '                                                 close option file

End Sub

DefInt A-Z
Sub ReadOptions

    '****************************************************************************
    '*                                                                          *
    '* Reads in the options from the OPTIONS.SMB file if it exists. If the file *
    '* does not exist it will create one.                                       *
    '*                                                                          *
    '****************************************************************************

    Dim optionname As String '                             header in options file
    Dim opt As String '                                    option under header

    If _FileExists("OPTIONS.SMB") Then '                        option file exist?
        Open "OPTIONS.SMB" For Input As #1 '                     yes, open it
        While Not EOF(1) '                                       while data exists
            Line Input #1, optionname '                            get line from file
            Select Case optionname '                               is it a header?
                Case "[FULLSCREEN]" '                                yes, fullscreen
                    Line Input #1, opt '                               get option value
                    fscreen = Val(opt) '                               store option value
                Case "[BGMUSIC]" '                                   yes, bgmusic
                    Line Input #1, opt '                               get option value
                    bgvolume = Val(opt) / 100 '                        store option value
                Case "[DIFFICULTY]" '                                yes, difficulty
                    Line Input #1, opt '                               get option value
                    difficulty = Val(opt) '                            store option value
                    Select Case difficulty '                           which level?
                        Case 1 '                                         1 - easy
                            bugnum = 8 '                                   number of bugs
                            gamespeed = 16 '                               speed of game
                            bugspeed = 5 '                                 speed of bugs
                            wormhole = 2 '                                 number of wormhole
                        Case 2 '                                         2 - normal
                            bugnum = 16 '                                  number of bugs
                            gamespeed = 16 '                               speed of game
                            bugspeed = 4 '                                 speed of bugs
                            wormhole = 1 '                                 number of wormhole
                        Case 3 '                                         3 - hard
                            bugnum = 24 '                                  number of bugs
                            gamespeed = 20 '                               speed of game
                            bugspeed = 3 '                                 speed of bugs
                            wormhole = 0 '                                 number of wormhole
                    End Select
            End Select '                                           ignore other lines
        Wend
        Close #1 '                                               close option file
    Else '                                                     file not exist
        WriteOptions '                                           create default
    End If

End Sub

DefInt A-Z
Sub ChangeFullscreen
    '****************************************************************************
    '*                                                                          *
    '* Changes between windowed and full screen views.                          *
    '*                                                                          *
    '****************************************************************************

    Dim full As Integer '                    state of fullscreen mode
    Dim passed As Integer '                  true if fullscreen passes test
    Dim counter As Integer '                 used to count by the seconds in test
    Dim keypress As String '                 player response to test question

    full = _FullScreen '                                       fullscreen state
    passed = False '                                           test not passed
    If full = 0 And fscreen = 1 Then '                         change screen?
        Cls '                                                    yes, clear first
        DisplayText 0, 30, " Your screen will be tested to see if it", 15, 0, 2, 2
        DisplayText 0, 60, " can play the game in full screen mode.", 15, 0, 2, 2
        DisplayText 0, 120, " A message will be displayed asking if", 15, 0, 2, 2
        DisplayText 0, 150, " you can read the screen. If you can't", 15, 0, 2, 2
        DisplayText 0, 180, " read the screen simply wait 10 seconds", 15, 0, 2, 2
        DisplayText 0, 210, " and your screen will return to normal.", 15, 0, 2, 2
        DisplayText 0, 270, "Press any key when ready to test screen.", 15, 0, 2, 2
        Do: Loop Until InKey$ = "" '                             clear kbd buffer
        Do: Loop Until InKey$ <> "" '                            wait for key
        Cls '                                                    clear screen
        _FullScreen '                                            go fullscreen
        _Delay 2 '                                               wait for sync
        DisplayText 0, 186, "  Press your X key if you can read this.", 15, 0, 2, 2
        Do: Loop Until InKey$ = "" '                             clear kbd buffer
        counter = 0 '                                            start timer
        Do
            counter = counter + 1 '                                increment timer
            keypress = UCase$(InKey$) '                            get user input
            If keypress = "X" Then passed = True '                 correct key press?
            _Limit 1 '                                             count by seconds
        Loop Until (counter = 9) Or passed '                     too long? passed?
        If Not passed Then '                                     test failed
            Cls '                                                  clear screen
            _FullScreen _Off '                                     go windowed
            _Delay 2 '                                             wait for sync
            DisplayText 0, 186, "You can't play this game in full screen!!", 15, 0, 2, 2
            fscreen = 0 '                                          fullscreen off
            WriteOptions '                                         save in options
            _Delay 5 '                                             wait 5 seconds
        End If
    End If
    If full <> 0 And fscreen = 0 Then '                        back to windowed?
        _FullScreen _Off '                                       fullscreen off
        _Delay 2 '                                               wait for sync
    End If

End Sub

