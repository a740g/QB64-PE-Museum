'****************************************************************************
'*                                                                          *
'*                  K   K  AAA  BBBB   OOO   OOO  M   M  !!!                *
'*                  K  K  A   A B   B O   O O   O MM MM  !!!                *
'*                  K K   A   A B   B O   O O   O M M M  !!!                *
'*                  KK    AAAAA BBBB  O   O O   O M M M  !!!                *
'*                  K K   A   A B   B O   O O   O M   M  !!!                *
'*                  K  K  A   A B   B O   O O   O M   M  !!!                *
'*                  K   K A   A BBBB   OOO   OOO  M   M   !                 *
'*                                                                          *
'* Kaboom! - A remake of the 1983 game by Activision for the Atari 2600     *
'* V1.0      (well, sort of)                                                *
'*                                                                          *
'* Terry Ritchie - terry.ritchie@gmail.com                                  *
'* September 26th, 2010                                                     *
'*                                                                          *
'* A convict is trying to escape from prison and somehow he got his hands   *
'* on an unlimited supply of bombs! It's up to you to catch the bombs in    *
'* the buckets of water you posess to extinguish them.                      *
'*                                                                          *
'* Use your mouse to move your buckets from right/left and catch the bombs. *
'*                                                                          *
'* This game is being released as freeware.                                 *
'*                                                                          *
'* This game was simply made to show novice programmers how a simple game   *
'* can be designed with QB64. All of the animation used in the game was     *
'* written using QB64's unique graphics handeling commands.                 *
'*                                                                          *
'* Future update plans:                                                     *
'*                                                                          *
'* - Use QB64's font commands to display score, menu options and high score *
'*   indication at end of game.                                             *
'* - Clean PNG graphics files to remove artifacts from around images.       *
'*                                                                          *
'****************************************************************************

'**
'** Declare functions and subroutines ***************************************
'**

DECLARE SUB UpdatePlayer() '                       update player movements
DECLARE SUB UpdatePrisoner() '                     update prisoner movements
DECLARE SUB UpdateBombs() '                        update bomb movements
DECLARE SUB TitleScreen() '                        main title screen
DECLARE SUB LevelUp(lvl AS INTEGER) '              increase level difficulty
DECLARE SUB Initialize() '                         initialize new game
DECLARE SUB CheckHighScore() '                     check/update high score
DECLARE FUNCTION FileExists (filename AS STRING) ' test for existance of file

'**
'** Declare CONSTants *******************************************************
'**

Const False = 0, True = Not False ' boolean truth testers
Const Maxbombs = 40 '               maximum nuber of bombs on screen

'**
'** Declare TYPEs ***********************************************************
'**

Type bombs '               values for dropping bombs
    x As Integer '         horizontal location of bomb (x)
    y As Integer '         vertical location of bomb (y)
    speed As Integer '     speed bomb is dropping
    image As Integer '     which bomb image to show (fizzing fuse)
End Type

Type player '              values for player
    x As Integer '         horizontal location of player (x)
    buckets As Integer '   number of buckets player has
End Type

Type prisoner '            values for prisoner dropping bombs
    x As Integer '         horizontal location of prisoner (x)
    xdir As Integer '      direction of prisoner (right or left zig-zag)
    image As Integer '     which prisoner image to show
End Type

'**
'** Declare variables *******************************************************
'**

Dim Shared bomb(Maxbombs) As bombs ' bombs that prisoner drops
Dim Shared player As player '        player properties
Dim Shared prisoner As prisoner '    prisoner properties
Dim Shared dropFrequency% '          bomb drop frequency
Dim Shared count% '                  general purpose counter
Dim Shared hiScore% '                high score
Dim Shared bombDrop% '               when to release a new bomb
Dim Shared nextBomb% '               which bomb to release next
Dim Shared level% '                  current game level
Dim Shared shiftiness% '             how shifty is the prisoner
Dim Shared kaboom% '                 true when bomb hits bottom
Dim Shared levelClear% '             true when level cleared
Dim Shared bombsToDrop% '            number of bombs to drop in level
Dim Shared bombsDropped% '           number of bombs that have been dropped
Dim Shared bombsCaught% '            number of bombs that have been caught
Dim Shared score% '                  game score counter
Dim Shared previousLevel% '          indicate when extra bucket awarded
Dim Shared gameOver% '               true when game is over
Dim Shared imgWall& '                game background image handler
Dim Shared imgBucket& '              bucket image handler
Dim Shared imgBomb&(1) '             bomb images handlers
Dim Shared imgPrisoner&(1) '         prisoner images handlers
Dim Shared imgTitle& '               game title screen image handler
Dim Shared imgNewgame&(1) '          "start new game" images handlers
Dim Shared imgQuit&(1) '             "quit" images handlers
Dim Shared imgExplode& '             explosion image handler
Dim Shared imgHiScore& '             message that displays high score
Dim Shared sndExplode&(3) '          exploding bomb sounds
Dim Shared sndHighScore& '           sound when high score is achieved
Dim Shared sndLevelCleared& '        sound when level is cleared
Dim Shared sndFuse& '                fuse burning sound
Dim Shared sndSplash& '              splash sound when bomb hits water
Dim Shared sndFizzle& '              sound of fuse burning out in water
Dim Shared sndBackground& '          background music

'**
'** Initialize variables ****************************************************
'**

sndExplode&(1) = _SndOpen("explode1.wav", "VOL, SYNC") '   explosion1 sound
sndExplode&(2) = _SndOpen("explode2.wav", "VOL, SYNC") '   explosion2 sound
sndExplode&(3) = _SndOpen("explode3.wav", "VOL, SYNC") '   explosion3 sound
sndHighScore& = _SndOpen("highscore.wav", "VOL, SYNC") '   high score sound
sndLevelCleared& = _SndOpen("levelcleared.wav", "VOL, SYNC") ' level end snd
sndFuse& = _SndOpen("fuse.wav", "VOL, SYNC") '             fuse burn sound
sndSplash& = _SndOpen("splash.wav", "VOL, SYNC") '         splash sound
sndFizzle& = _SndOpen("fizzle.wav", "VOL, SYNC") '         fizzle out sound
imgWall& = _LoadImage("wall.png", 32) '                    game background
imgBucket& = _LoadImage("bucket.png", 32) '                bucket image
imgBomb&(0) = _LoadImage("bomb1.png", 32) '                bomb 1 image
imgBomb&(1) = _LoadImage("bomb2.png", 32) '                bomb 2 image
imgExplode& = _LoadImage("explosion.png", 32) '            bomb explosion
imgPrisoner&(0) = _LoadImage("prisoner.png", 32) '         prisoner1 (Bill)
imgPrisoner&(1) = _LoadImage("prisoner2.png", 32) '        prisoner2 (Steve)
imgTitle& = _LoadImage("title.png", 32) '                  title screen
imgNewgame&(0) = _LoadImage("newgame.png", 32) '           new game image 1
imgNewgame&(1) = _LoadImage("newgame2.png", 32) '          new game image 2
imgQuit&(0) = _LoadImage("quit.png", 32) '                 quit image 1
imgQuit&(1) = _LoadImage("quit2.png", 32) '                quit image 2
imgHiScore& = _LoadImage("hiscore.png", 32) '              high score image

'****************************************************************************
'**
'** Main program code starts here
'**

Screen _NewImage(800, 600, 32) '             800 x 600 32bit color
_Title "Kaboom!" '                           set window title
Randomize Timer '                            seed random number generator
Do '                                         begin main code loop
    Initialize '                             initialize game variables
    TitleScreen '                            display the title screen
    '**
    '** Select a random background song from 9 available
    '**
    sndBackground& = _SndOpen("kab" + LTrim$(RTrim$(Str$(Int(Rnd(1) * 9) + 1))) + ".mid", "VOL")
    '**
    _SndVol sndBackground&, .25 '            25% volume background music
    _SndLoop sndBackground& '                loop the background music
    Do '                                     begin game loop here
        LevelUp (level%) '                   set up the new level
        kaboom% = False '                    reset bomb hit indicator
        levelClear% = False '                reset level clear indicator
        bombsDropped% = 0 '                  reset number of bombs dropped
        bombsCaught% = 0 '                   reset number of bombs caught
        Do '                                 begin current level loop here
            _PutImage , imgWall& '           overwrite screen with background
            Locate 2, 50 '                   position text cursor
            '**
            '** print the current score to screen
            '**
            Print Right$("0000" + LTrim$(RTrim$(Str$(score%))), 5);
            '**
            UpdatePlayer '                   update player bucket movements
            UpdatePrisoner '                 update the prisoner movements
            UpdateBombs '                    update the dropping bombs
            _Limit 64 '                      limit game 64 frames per second
            _Display '                       display changes made to screen
        Loop Until kaboom% Or levelClear% '  keep playing until boom or clear
        If kaboom% Then '                    did bomb hit ground?
            level% = level% - 1 '            send player back a level
            If level% = 0 Then level% = 1 '  too far?
            player.buckets = player.buckets - 1 ' take a player bucket away
            If player.buckets < 1 Then gameOver% = True ' all buckets gone?
        Else
            level% = level% + 1 '            level cleared, advance to next
            _SndPlay sndLevelCleared& '      play congrats chorus
        End If
    Loop Until gameOver% '                   leave loop when game is over
    _SndStop sndBackground& '                stop the background music
    _SndClose sndBackground& '               unload the background music
    CheckHighScore '                         New high score?
Loop '                                       end of main code loop

'**
'** Main program code ends here
'**
'****************************************************************************

'**
'** Subroutines and Functions
'**

Sub CheckHighScore ()

    '****************************************************************************
    '*                                                                          *
    '* Check current score against high score and update if needed              *
    '*                                                                          *
    '****************************************************************************

    If score% > hiScore% Then '                                new high score?
        _AutoDisplay '                                         auto update screen
        _PutImage (0, 0), imgHiScore& '                        display message
        _Delay 2 '                                             let it soak in
        _SndPlay sndHighScore& '                               play yahoo music
        _Delay 5 '                                             time to celebrate
        Open "hiscore.kab" For Output As #1 '                  open score file
        Print #1, score% '                                     write new score
        Close #1 '                                             close score file
    Else
        _Delay 3 '                                             time to view score
    End If

End Sub

Sub Initialize ()

    '****************************************************************************
    '*                                                                          *
    '* Initialize the variables for a new game                                  *
    '*                                                                          *
    '****************************************************************************

    player.x = 400 '       start location of player bucket(s)
    player.buckets = 3 '   number of buckets player starts with
    prisoner.x = 400 '     start location of prisoner
    prisoner.image = 0 '   start image of prisoner
    prisoner.xdir = 0 '    start direction of prisoner
    hiScore% = 0 '         set high score to 0
    bombDrop% = 0 '        bomb drop timer
    dropFrequency% = 64 '  how often to drop bombs (wait x fps, 64 = 1 sec)
    nextBomb% = 0 '        bomb drop counter
    level% = 1 '           start at level 1
    shiftiness% = 1 '      how often prisoner changes direction randomly
    kaboom% = False '      true when bomb hits ground
    levelClear% = False '  true after each level cleared
    score% = 0 '           reset game score
    gameOver% = False '    reset game over indicator

    For count% = 1 To Maxbombs '  initialize all bombs
        bomb(count%).y = 0 '      start y position of each bomb
        bomb(count%).speed = 0 '  start drop speed of each bomb
        bomb(count%).image = 0 '  start image of each bomb (burning fuse anim)
    Next count%

    If FileExists("hiscore.kab") Then '       high score file exist?
        Open "hiscore.kab" For Input As #1 '  yes, open it
        Input #1, hiScore% '                  get the high score
        Close #1 '                            close high score file
    End If

End Sub

Sub LevelUp (lvl As Integer)

    '****************************************************************************
    '*                                                                          *
    '* Increases (or decreases) the level of difficulty                         *
    '*                                                                          *
    '****************************************************************************

    Dim bombSpeed% ' speed at which bombs can drop

    bombDrop% = 0 '                                            reset drop counter
    Select Case lvl '                                          which level?
        Case 1 '                                               level 1
            previousLevel% = 1 '                               let next level know
            bombsToDrop% = 20 '                                drop 20 bombs
            bombSpeed% = 1 '                                   fall slowly
            dropFrequency% = 64 '                              1 bomb per sec
            prisoner.xdir = 1 '                                prisoner slow
            shiftiness% = 200 '                                zig-zag low
        Case 2 '                                               level 2
            previousLevel% = 2 '                               let next level know
            bombsToDrop% = 30 '                                drop 30 bombs
            bombSpeed% = 2 '                                   fall a bit faster
            dropFrequency% = 60 '                              1.1 bombs per sec
            prisoner.xdir = 2 '                                prisoner bit faster
            shiftiness% = 180 '                                zig-zag faster
        Case 3 '                                               level 3
            If previousLevel% = 2 Then previousLevel% = 3 '    let next level know
            bombsToDrop% = 35 '                                drop 35 bombs
            bombSpeed% = 2 '                                   fall same speed
            dropFrequency% = 44 '                              1.4 bombs per sec
            prisoner.xdir = 3 '                                prisoner faster
            shiftiness% = 160 '                                zig-zag faster
        Case 4 '                                               level 4
            '**
            '** only award extra bucket if coming from previous level,
            '** not coming back from higher level (kaboom happened)
            '**
            If previousLevel% = 3 Then player.buckets = player.buckets + 1
            '**
            previousLevel% = 4 '                               let next level know
            bombsToDrop% = 40 '                                drop 40 bombs
            bombSpeed% = 3 '                                   fall even faster
            dropFrequency% = 40 '                              1.8 bombs per sec
            prisoner.xdir = 4 '                                prisoner very fast
            shiftiness% = 140 '                                zig-zag crazier
        Case 5 '                                               level 5
            If previousLevel% = 4 Then previousLevel% = 5 '    let next level know
            bombsToDrop% = 45 '                                drop 45 bombs
            bombSpeed% = 3 '                                   fall same speed
            dropFrequency% = 32 '                              2 bombs per sec
            prisoner.xdir = 5 '                                prisoner faster!
            shiftiness% = 120 '                                zig-zag wild now
        Case 6 '                                               level 6
            '**
            '** only award extra bucket if coming from previous level,
            '** not coming back from higher level (kaboom happened)
            '**
            If previousLevel% = 5 Then player.buckets = player.buckets + 1
            '**
            previousLevel% = 6 '                               let next level know
            bombsToDrop% = 55 '                                drop 55 bombs
            bombSpeed% = 4 '                                   fall even faster!
            dropFrequency% = 24 '                              2.4 bombs per sec
            prisoner.xdir = 6 '                                prisoner real fast
            shiftiness% = 100 '                                zig-zag irratic
        Case Else '                                            awesome player!
            bombsToDrop% = 60 '                                drop 60 bombs
            bombSpeed% = 5 '                                   fall extreme fast
            dropFrequency% = 16 '                              3 bombs per sec
            prisoner.xdir = 7 '                                prisoner sprinting
            shiftiness% = 80 '                                 zig-zag crazy!
    End Select
    If player.buckets > 3 Then player.buckets = 3 '            only 3 buckets
    Randomize Timer '                                          seed rnd generator
    For count% = 1 To Maxbombs '                               set up bomb speeds
        bomb(count%).speed = Int(Rnd(1) * bombSpeed%) + 1 '    random speeds
    Next count%

End Sub

Sub UpdateBombs ()

    '****************************************************************************
    '*                                                                          *
    '* Updates the bombs falling on the screen                                  *
    '*                                                                          *
    '****************************************************************************

    If Not _SndPlaying(sndFuse&) Then '                        start fuse sound
        _SndVol sndFuse&, .25 '                                set volume low
        _SndLoop sndFuse& '                                    loop fuse sound
    End If
    bombDrop% = bombDrop% + 1 '                                bomb timer
    If bombsDropped% <> bombsToDrop% Then '                    more bombs to drop?
        If bombDrop% = dropFrequency% Then '                   do it now?
            bombsDropped% = bombsDropped% + 1 '                count dropped bombs
            bombDrop% = 0 '                                    reset bomb timer
            nextBomb% = nextBomb% + 1 '                        where in array?
            If nextBomb% > Maxbombs Then nextBomb% = 1 '       back to start array
            bomb(nextBomb%).x = prisoner.x - 25 '              position x location
            bomb(nextBomb%).y = 25 '                           position y location
            bomb(nextBomb%).image = 0 '                        fuse burn image
        End If
    End If
    For count% = 1 To Maxbombs '                               cycle thru array
        If bomb(count%).y <> 0 Then '                          is bomb out there?
            bomb(count%).y = bomb(count%).y + bomb(count%).speed ' move bomb down
            bomb(count%).image = 1 - bomb(count%).image '      cycle fuse image
            '**
            '** draw the image of the bomb to the screen
            '**
            _PutImage (bomb(count%).x, bomb(count%).y), imgBomb&(bomb(count%).image)
            '**
            If bomb(count%).y >= 550 Then '                    bomb at bottom?
                kaboom% = True '                               yes, kaboom happens
                _SndStop sndFuse& '                            stop fuse sound
            Else '                                             bomb still dropping
                splash% = False '                              no splash yet
                '**
                '** is bomb currently located where the bottom bucket resides?
                '** if so then add 1 to score and make splash true
                '**
                If bomb(count%).x >= player.x - 50 And bomb(count%).x <= player.x + 25 And bomb(count%).y > 500 And bomb(count%).y < 560 Then
                    splash% = True
                    score% = score% + 1
                End If
                '**
                '** is bomb currently located where the middle bucket resides?
                '** if so does the middle bucket exist?
                '** if so then add 2 to score and make splash true
                '**
                If player.buckets > 1 And bomb(count%).x >= player.x - 50 And bomb(count%).x <= player.x + 25 And bomb(count%).y > 400 And bomb(count%).y < 460 Then
                    splash% = True
                    score% = score% + 2
                End If
                '**
                '** is bomb currently located where the top bucket resides?
                '** if so does the top bucket exist?
                '** if so then add 3 to score and make splash true
                '**
                If player.buckets > 2 And bomb(count%).x >= player.x - 50 And bomb(count%).x <= player.x + 25 And bomb(count%).y > 300 And bomb(count%).y < 360 Then
                    splash% = True
                    score% = score% + 3
                End If
                If splash% Then '                              bomb hit bucket?
                    bombsCaught% = bombsCaught% + 1 '          count caught bombs
                    If bombsCaught% = bombsToDrop% Then '      all caught?
                        levelClear% = True '                   level is clear
                        _SndStop sndFuse& '                    stop fuse sound
                    End If
                    bomb(count%).y = 0 '                       remove bomb
                    _SndPlay sndSplash& '                      make splash sound
                    _SndPlay sndFizzle& '                      fuse fizzles out
                End If
            End If
        End If
    Next count%
    If kaboom% Then '                                          bomb hit ground?
        _PutImage (prisoner.x - 25, 0), imgPrisoner&(1) '      Ballmer's head!
        For count% = 1 To Maxbombs '                           cycle through array
            If bomb(count%).y <> 0 Then '                      bomb in play?
                '**
                '** place an explosion image over bomb on screen
                '**
                _PutImage (bomb(count%).x - 10, bomb(count%).y + 10), imgExplode&
                '**
                bomb(count%).y = 0 '                           remove bomb
                _SndPlay sndExplode&(Int(Rnd(1) * 3) + 1) '    which boom sound?
                _Delay .2 '                                    pause between booms
                _Display '                                     update screen
            End If
        Next count%
    End If

End Sub

Sub UpdatePlayer ()

    '****************************************************************************
    '*                                                                          *
    '* Updates the position of the player's bucket(s)                           *
    '*                                                                          *
    '****************************************************************************

    Do While _MouseInput '                                     get mouse changes
    Loop '                                                     since last visit
    player.x = Int(_MouseX / 1.14286) + 50 '                   calc bucket posit
    For count% = 0 To player.buckets - 1 '                     draw each bucket
        buckety% = 520 - (count% * 100) '                      y bucket location
        _PutImage (player.x - 50, buckety%), imgBucket& '      display bucket
    Next count%

End Sub

Sub UpdatePrisoner ()
    '****************************************************************************
    '*                                                                          *
    '* Updates the position of the prisoner                                     *
    '*                                                                          *
    '****************************************************************************

    prisoner.x = prisoner.x + prisoner.xdir '                  move prisoner
    If prisoner.x > 775 Then '                                 hit right edge
        prisoner.x = 775 '                                     stop prisoner
        prisoner.xdir = -prisoner.xdir '                       reverse direction
    End If
    If prisoner.x < 25 Then '                                  hit left edge
        prisoner.x = 25 '                                      stop prisoner
        prisoner.xdir = -prisoner.xdir '                       reverse direction
    End If
    '**
    '** based on shiftiness should we randonly shift prisoner?
    '**
    If Int(Rnd(1) * shiftiness%) = Int(shiftiness% / 2) Then prisoner.xdir = -prisoner.xdir
    '**
    _PutImage (prisoner.x - 25, 0), imgPrisoner&(0) '          display prisoner

End Sub

Sub TitleScreen ()
    '****************************************************************************
    '*                                                                          *
    '* Main title screen                                                        *
    '*                                                                          *
    '****************************************************************************

    Dim sndIntroMusic& ' intro music handler
    Dim ng% '            controls which "start new game" image to display
    Dim qt% '            controls which "quit" image to display
    Dim optionChosen% '  holds the option player chooses
    Dim mx% '            x location of mouse pointer
    Dim my% '            y location of mouse pointer
    Dim mb% '            holds status of left mouse button
    Dim sndMarvin& '     marvin martian "where's the kaboom" sound handler
    Dim highScore$ '     high score scrolling message to display on screen

    ng% = 0 '            show unhighlighted new game option first
    qt% = 0 '            show unhighlighted quit option first
    optionChosen% = 0 '  use has not yet chosen an option

    _FullScreen '                                              go full screen
    _MouseShow '                                               show mouse pointer
    _AutoDisplay '                                             auto update screen
    sndIntroMusic& = _SndOpen("title.ogg", "VOL") '            load title music
    _SndVol sndIntroMusic&, .5 '                               set title volume
    _SndLoop sndIntroMusic& '                                  loop title music
    _PutImage , imgTitle& '                                    display title image
    '**
    '** form the scrolling high score message
    '**
    highScore$ = String$(40, 32) + "The score to beat is "
    highScore$ = highScore$ + Right$("0000" + LTrim$(RTrim$(Str$(hiScore%))), 5)
    highScore$ = highScore$ + String$(40, 32) + "Can you keep Billy boy in jail? "
    '**
    Color _RGB(0, 0, 0), _RGB(85, 183, 255) '                  set text color
    count% = 0 '                                               text scroll count
    Do '                                                       start input loop
        _Limit 8 '                                             don't hog cpu
        count% = count% + 1 '                                  inc scroll count
        If count% > Len(highScore$) Then count% = 1 '          reset count?
        Locate 2, 40 '                                         locate text
        Print Mid$(highScore$, count%, 20); '                  print banner
        Do While _MouseInput '                                 get mouse changes
        Loop '                                                 since last visit
        mx% = _MouseX '                                        x location of mouse
        my% = _MouseY '                                        y location of mouse
        mb% = _MouseButton(1) '                                left button status
        '**
        '** if the mouse pointer falls within either square containing a menu
        '** option then set the appropriate variable controlling which image
        '** to show to 1, otherwise set each one to 0 (the default image)
        '**
        If mx% > 49 And mx% < 360 And my% > 274 And my% < 301 Then ng% = 1 Else ng% = 0
        If mx% > 149 And mx% < 241 And my% > 339 And my% < 373 Then qt% = 1 Else qt% = 0
        '**
        _PutImage (50, 275), imgNewgame&(ng%) '                display menu entry
        _PutImage (150, 340), imgQuit&(qt%) '                  display menu entry
        If ng% = 1 And mb% <> 0 Then optionChosen% = 1 '       option 1 chosen
        If qt% = 1 And mb% <> 0 Then optionChosen% = 2 '       option 2 chosen
    Loop Until optionChosen% <> 0 '                            end of input loop
    _SndStop sndIntroMusic& '                                  stop title music
    _SndClose sndIntroMusic& '                                 close title music
    _MouseHide '                                               hide mouse pointer
    If optionChosen% = 2 Then '                                did user quit?
        Locate 2, 40 '                                         locate text
        Print "Bill said "; Chr$(34); "Chicken!"; Chr$(34); '  taunt player!
        sndMarvin& = _SndOpen("marvin.wav", "VOL") '           load marvin sound
        _SndPlay sndMarvin& '                                  play marvin sound
        _Delay 5 '                                             wait 5 seconds
        _SndClose sndMarvin& '                                 close marvin sound
        Color _RGB(255, 255, 255), _RGB(0, 0, 0) '             reset text color
        System '                                               return to OS
    End If

End Sub

Function FileExists (filename As String)

    '****************************************************************************
    '*                                                                          *
    '* Tests for the existance of a file. Returns true if file found, false     *
    '* otherwise.                                                               *
    '*                                                                          *
    '****************************************************************************

    Open filename For Append As #1 '                           open file
    If LOF(1) Then '                                           data present?
        FileExists = True '                                    file does exist
    Else
        FileExists = False '                                   file not exist
    End If
    Close #1 '                                                 close file

End Function

