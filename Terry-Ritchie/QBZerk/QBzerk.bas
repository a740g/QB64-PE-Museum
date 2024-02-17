'
'          ____________________________________________________________________________________________
'                    _______  _______  _______  _______  ______    ___   _  ___      _   ___
'                   |       ||  _    ||       ||       ||    _ |  |   | | ||   |    | | |   |
'                   |   _   || |_|   ||____   ||    ___||   | ||  |   |_| ||   |___ | |_|   |
'                   |  | |  ||       | ____|  ||   |___ |   |_||_ |      _||    _  ||       |
'                   |  |_|  ||  _   | |  _____||    ___||    __  ||     |_ |   | | ||___    |
'                   |      | | |_|   || |_____ |   |___ |   |  | ||    _  ||   |_| |    |   |
'                   |____||_||_______||_______||_______||___|  |_||___| |_||_______|    |___|
'                                                    _______
'                                                  _|  ___  |_
'                                                _|   |___|   |_
'                                               |  _         _  |
'                                               | | |       | | |
'                                               | | |       | | |
'                                               |_| |       | |_|
'                                                   |  ___  |
'                                                   | |   | |
'                                                  _| |   | |_
'                                                 |___|   |___|
'          ____________________________________________________________________________________________
'
'                                                       by
'
'                                                 Terry Ritchie
'
'                                                 Sept 5th, 2015
'
' QBzerk64 is based off the 1980 arcade game called Berzerk by Stern Electronics. This is not a 100% clone of the
' original arcade game nor was it meant to be. The following are notable differences about this version:
'
'   - The maze generation algorithm is performed exactly like the original.
'     - There is a total grid of 256 x 256 rooms creating a possible combination of 65,536 maze rooms.
'     - Going back to a previously visited maze room will reveal the same maze that was there before.
'   - The scrolling maze sequence has been modified:
'     - When scrolling from one maze to another the new maze scrolls in as the old maze scrolls out.
'     - The player's character continues to run to the start point in the new maze.
'     - As the new maze scrolls in doors slide across the entered path to block passage back to the previous maze.
'     - Robots are seen in their position as the new maze scrolls in.
'     - There is no pause once the new maze has scrolled in since the player has had time to analyze the new maze.
'   - The maximum number of robots on the screen at any time in the original arcade version was 11.
'     - In QBzerk64 after level 13 a total of 14 robots can be on the screen at any time.
'   - The maximum number of robot lasers on the screen at one time in the original aracde version is 5.
'     - In this version after level 13 that number increases to 8.
'   - The robot AI does not perform exactly as the original game.
'     - Attempting to reproduce the "dumbness" of the robots as seen in the original is quite challenging!
'     - The robots have four psuedo-random modes when chasing the player:
'       - Track the player vertically
'       - Track the player horizontally
'       - Track the player diagonally
'       - Stand in place and wait for player
'     - The robots will also track the player relentlessly when the player has come within the robots realm.
'     - The robots have the ability shoot vertically from both their right and left sides after level 6.
'       - In the original the robots could only shoot vertically from their right side.
'     - A robot will stand in place while it has a bullet(s) in flight.
'   - The robot's eyes scan side to side, much like KITT from Knight Rider, instead of one direction.
'   - The first 13 levels of the arcade version has fixed colors for the robots, Evil Otto and the doors.
'     - This version follows those same colors but after level 13 the colors are random.
'   - The robot voice sequences were created by combining the original individual robot voice words.
'     - The original arcade sound hardware was capable of stringing these words together at different pitches.
'     - This was simulated by creating each voice sequence with a low, normal, and high pitch sound file.
'   - A total of 10 high scores are saved while the game is "powered on".
'     - Only the top 5 high scores are maintained between sessions just like the original arcade version.
'     - A file named "QBzerk.sav" will be created in the game directory to store the high score table.
'   - Game options can be selected by the player and saved.
'     - Screen size, full screen and extra player values can be selected by the player.
'     - A file name "QBzerk.ini" will be created in the game directory to store the player selected game options.
'   - Text on information screens has been centered which could not be achieved on the original arcade hardware.
'   - An example of game play is not shown to the player while awaiting for a game to be played.
'     - Instead, a main screen with a big robot and the high score screen alternates back and forth.
'   - This game is just begging to be ported to Android!
'
'   - You may freely distribute this source code and associated files as long as the following conditions are met.
'
'   - Any modifcations to the original source code or asset files must be documented in the revision history below.
'   - The original text above to include the revision history below must remain intact.
'
' Revision History.
' -----------------------------------------------------------------------------------------------------------------
' | V1.0B | Terry Ritchie | July 4th, 2015  | Original release of source code and asset files.                    |
' --------|---------------|-----------------|---------------------------------------------------------------------|
' | V1.1B | Terry Ritchie | July 7th, 2015  | - Added joystick support to game with code examples by SMcNeill     |
' --------|---------------|-----------------|---------------------------------------------------------------------|
' | V1.2B | Terry RItchie | Sept 5th, 2015  | - Added auto-detection of player's desktop size                     |
' |       |               |                 | - Fixed _SCREENMOVE _MIDDLE to work correctly per SMcNeill          |
' |       |               |                 | - Fixed a few sound timing issues when exiting program              |
' |       |               |                 | - Remove joystick code introduced in V1.1B (did not work correctly) |
' -----------------------------------------------------------------------------------------------------------------
'
' The original release post can be found at: http://www.qb64.net/forum/index.php?topic=12850.0
'
'----------------------------------------------------------------------------------------------------------------------
'                                                                                 CONSTANT AND TYPE DECLARATION SECTION
Const FALSE = 0 '             BOOL : false test/set
Const TRUE = Not FALSE '      BOOL : true test/set
Const BEGIN = -1 '                   Starting maze indicator
Const AFTERLIFE = -2 '               New maze after player death
Const NORTH = 0 '                    value for north maze
Const SOUTH = 1 '                    value for south maze
Const EAST = 2 '                     value for east maze
Const WEST = 3 '                     value for west maze
Const LOAD = 0 '                     load high scores
Const SAVE = 1 '                     save high scores
Const NORMAL = 0 '                   draw player during normal play
Const TRANSITIONING = 1 '            draw player during a transitioning phase
Const ZAPPED = 2 '                   draw player during a death sequence
Const FIRING = 3 '                   draw player during a firing sequence

Type OTTO
    x As Integer '                   x location (base)
    y As Integer '                   y location (base)
    xdir As Integer '                x direction (base moving)
    ydir As Integer '                y direction (base moving)
    yoffset As Integer '             y bounce offset from base
    yvel As Integer '                speed of y offset direction
    fcount As Integer '              frame counter
    acount As Integer '              appearance counter
    alive As Integer '        BOOL : true if Otto active
    cell As Integer '                animation cell
    bounce As Integer '       BOOL : true if bouncing
End Type

Type LEVEL '                         level properties
    points As Integer '              points needed to increase to next level
    rcolor As _Unsigned Long '       robot color at each level
    bullets As Integer '             total number of robot bullets allowed flying at once
    rbullets As Integer '            number of bullets each robot allowed to shoot at a time
    bspeed As Integer '              speed of robot bullets in level
End Type

Type SETTINGS '                      game options
    size As Integer '                screen size (1 - 4)
    full As Integer '                full screen (1 = no, 2 = yes)
    extra As Integer '               extra player (1 = 5000, 2 = 10000, 3 = for both 5000 and 10000)
    iddqd As Integer '        BOOL : true if in god mode (game test mode)
    god As Integer '          BOOL : true if god mode ever activated
    eye As Integer '                 god mode eye intensity
    eyedir As Integer '              god mode eye color direction
End Type

Type LAWS '                          human laws variables
    text1 As String * 32 '           text of each law
    text2 As String * 32
    text3 As String * 32
    text4 As String * 32
    y As Integer '                   y location of first line of text
    r As Integer '                   red component
    g As Integer '                   green component
    b As Integer '                   blue component
    m As Integer '                   color multiplier
    s As Long '                      sound when law fading in
End Type

Type PIECES '                        flying screen pieces
    image As Long '                  image of piece of screen
    x As Single '                    x location of piece
    y As Single '                    y location of piece
    xdir As Single '                 x direction of piece
    ydir As Single '                 y direction of piece
End Type

Type BULLETS '                       location and direction of bullets
    x As Integer '                   x location of bullet
    y As Integer '                   y location of bullet
    oldx As Integer
    oldy As Integer
    xdir As Integer '                x direction of bullet
    ydir As Integer '                y direction of bullet
    alive As Integer '        BOOL : true is bullet active
    who As Integer '                 who shot this bullet (0=player, 1-15=robots)
End Type

Type PILLARS '                       locations of maze pillars
    x As Integer '                   x location of each pillar
    y As Integer '                   y location of each pillar
End Type

Type PLAYER '                        player characteristics
    x As Integer '                   x location of player
    y As Integer '                   y location of player
    xdir As Single '                 x direction of player
    ydir As Single '                 y direction of player
    cell As Integer '                current image cell
    dir As Integer '                 direction player is facing
    alive As Integer '        BOOL : true if player alive
    zcolor As Integer '              zap flash color
    zcount As Integer '              zap counter
    chicken As Integer '      BOOL : true if player is a chicken
    ccount As Integer '              chicken counter: if less than 2 player is chicken
    score As Long '                  player's score
    lives As Integer '               player lives remaining
    tcount As Integer '              taunt frame counter
    taunt As Integer '               frames to wait before taunting player
    bullets As Integer '             number of bullets player has flying
    bcount As Integer '              bullet frame counter
    mode As Integer '                mode of player: FIRING, NORMAL
    awarded As Integer '             player awarded extra life(s)
    fix As Integer '                 must pause animation for two frames after firing down (player shoots foot)
End Type

Type ROBOTS '                        robot characteristics
    x As Integer '                   x location of robot
    y As Integer '                   y location of robot
    zx As Integer '                  robot starting zone x location
    zy As Integer '                  robot starting zone y location
    xdir As Integer '                x direction of robot
    ydir As Integer '                y direction of robot
    cell As Integer '                current image cell
    dir As Integer '                 direction robot is facing
    alive As Integer '        BOOL : true if robot active on screen
    hit As Integer '          BOOL : true when robot hits something
    eye As Integer '                 rotating eye
    eyedir As Integer '              eye direction
    ecount As Integer '              eye frame counter
    fcount As Integer '              robot movement frame counter
    bullets As Integer '             number of bullets robot has flying
    bcount As Integer '              bullet frame counter
    xmode As Integer '        BOOL : true if robot allowed to move in x (AI)
    ymode As Integer '        BOOL : true if robot allowed to move in y (AI)
    xmcount As Integer '             x mode frame counter (AI)
    ymcount As Integer '             y mode frame counter (AI)
    distance As Integer '            distance from player to start tracking (AI)
End Type

Type HIGH '                          high score table
    n As String * 3 '                player's intiials
    s As Long '                      player's score
End Type

Type ROOM '                          room information
    x As Integer '                   x grid coordinate of current room
    y As Integer '                   y grid coordinate of current room
    level As Integer '               level of play
    reallevel As Integer '           actual level counter
    bonus As Integer '               bonus amount after clearing room
    robots As Integer '              number of robots in room
    killed As Integer '              number of robots killed in room
    bullets As Integer '             number of active bullets in room
    delay As Integer '               delay before beginning of new maze
    blink As Integer '        BOOL : true if player should blink
End Type
'                                                                             END CONSTANT AND TYPE DECLARATION SECTION
'----------------------------------------------------------------------------------------------------------------------
'                                                                                          VARIABLE DECLARATION SECTION
Dim Robot(15) As ROBOTS '     ARRAY: robot variables
Dim P(8) As PILLARS '         ARRAY: maze pillar locations
Dim Player As PLAYER '        ARRAY: player variables
Dim High(10) As HIGH '        ARRAY: top ten high scores
Dim Room As ROOM '            ARRAY: room variables
Dim Bullet(10) As BULLETS '   ARRAY: bullet variables
Dim Piece(15, 13) As PIECES ' ARRAY: flying screen pieces
Dim Law(4) As LAWS '          ARRAY: human being laws
Dim Setting As SETTINGS '     ARRAY: game option settings
Dim Level(14) As LEVEL '      ARRAY: level properties
Dim Otto As OTTO '            ARRAY: evil otto properties
Dim MainScreen& '             IMAGE: main view screen
Dim Pimage&(9, -1 To 1) '     IMAGE: player images
Dim Pmask&(9, -1 To 1) '      IMAGE: player mask for edge detection
Dim PmaskTest& '              IMAGE: mask area to test for player edge detection
Dim Rimage&(7, -1 To 1) '     IMAGE: robot images
Dim Rmask& '                  IMAGE: robot mask area
Dim BigRobot&(4) '            IMAGE: large robot
Dim Boom&(3) '                IMAGE: robot blowing up
Dim BoomMask& '               IMAGE: mask area for exploding robots
Dim Flash&(4) '               IMAGE: player flashing when hit
Dim FlashMask& '              IMAGE: player flashing mask
Dim BlankRoom& '              IMAGE: room with blank maze (outer maze walls only)
Dim WorkRoom& '               IMAGE: main game screen where action takes place
Dim Maze& '                   IMAGE: level maze
Dim Maze3D& '                 IMAGE: 3D maze image
Dim Life& '                   IMAGE: extra life indicator (little stick guy)
Dim Font&(62) '               IMAGE: game font
Dim Otto&(5) '                IMAGE: Evil Otto!
Dim QBZerk64l& '              IMAGE: colorful QBzerk64 logo (large)
Dim QBzerk64s& '              IMAGE: colorful QBzerk64 logo (small)
Dim Icon& '                   IMAGE: window icon
Dim IconOtto& '               IMAGE: otto window icon image
Dim OttoMask& '               IMAGE: evil otto mask
Dim Taunt&(7, 5, 3) '         SOUND: robot taunts during gameplay (verb, noun, pitch)
Dim Ctaunt& '                 SOUND: current taunt playing
Dim MustNotEscape&(3, 3) '    SOUND: the %noun% must not escape sequences
Dim CoinDetected&(3) '        SOUND: coin detected in pocket sequences
Dim FightLikeRobot&(3) '      SOUND: fight like a robot sequences
Dim Rshoot& '                 SOUND: robot shooting
Dim Pshoot& '                 SOUND: player shooting
Dim Killed& '                 SOUND: robot and player killed
Dim GotTheHumanoid& '         SOUND: got the humanoid, got the intruder
Dim IntruderAlert& '          SOUND: intruder alert, intruder alert
Dim FootStep& '               SOUND: robotic foot step
Dim IntroMusic& '             SOUND: introduction screen background music
Dim Coin& '                   SOUND: coin entering machine
Dim Extra& '                  SOUND: extra life sound
Dim Credits% '                       number of coins currently fed into machine
Dim Cheat$ '                         what is this for?
'                                                                                      END VARIABLE DECLARATION SECTION
'----------------------------------------------------------------------------------------------------------------------
'                                                                                                   MAIN PROGRAM BEGINS
LOADASSETS '                          load game's graphics, sound and set initial settings
SETSCREENMODE '                       set game's screen size based on settings
ASIMOV '                              the three human being laws introduction sequence
Do '                                  cyce through program
    INTRO '                           wait for input while showing game's intro and high score screens
    RESETGAME '                       initialize setting for a new game
    Do '                              cycle through game
        Do '                          cycle through level
            _Limit 30 '               game will run at 30 FPS
            _Dest WorkRoom& '         switch to main work screen
            _PutImage (0, 0), Maze& ' clear room with current maze image
            UPDATEPLAYER '            check for player movements
            UPDATEROBOTS '            update robot movements
            UPDATEBULLETS '           maintain game's bullets flying around
            DRAWROBOTS '              draw robots in updated positions
            DRAWPLAYER Player.mode '  display the player in updated position
            CHECKFORTRANSITION '      check for transition from one maze to another
            RANDOMTAUNT '             taunt the player as he/she playing
            UPDATESCORE '             update score
            _Dest MainScreen& '       draw to main view screen
            _PutImage , WorkRoom& '   stretch work room onto main screen
            _Display '                update display results to player
        Loop Until Not Player.alive ' leave when player gets killed
        RESETLEVEL '                  reset for next game level
    Loop Until Player.lives = 0 '     leave when player loses all lives
    HIGHSCORES SAVE '                 save high score if necessary
Loop '                                always loop back
'                                                                                                     MAIN PROGRAM ENDS
'----------------------------------------------------------------------------------------------------------------------
'                                   ********** SUBROUTINES AND FUNCTIONS *********
'----------------------------------------------------------------------------------------------------------------------
'                                                                                                             RESETGAME
Sub RESETGAME ()

    '**
    '** Resets variables for a new game.
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared Room As ROOM '        ARRAY: room variables
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared Otto As OTTO '        ARRAY: evil otto properties

    Dim c% '                            generic counter

    Player.lives = 3 '             reset player settings
    Player.alive = TRUE
    Player.bullets = 0
    Player.score = 0
    Player.x = 12
    Player.y = 100
    Player.dir = 1
    Player.cell = 1
    Player.mode = NORMAL
    Player.xdir = 0
    Player.ydir = 0
    Player.awarded = 0
    Otto.alive = FALSE '           reset otto settings
    Room.level = 1 '               reset room settings
    Room.reallevel = 1
    Room.killed = 0
    Room.bullets = 0
    Room.delay = 60
    Setting.iddqd = FALSE '        reset master settings
    Setting.god = FALSE
    For c% = 1 To 10 '             cycle through bullet array
        Bullet(c%).alive = FALSE ' kill off any flying bullets
    Next c%
    MAKEMAZE BEGIN '               make initial maze
    GENERATEROBOTS EAST '          generate initial robots

End Sub
'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            RESETLEVEL
Sub RESETLEVEL ()

    '**
    '** Resets variables for a new level after player killed.
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared Room As ROOM '        ARRAY: room variables
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Otto As OTTO '        ARRAY: evil otto properties

    Dim c% '                            generic counter

    Player.alive = TRUE '          reset player settings
    Player.bullets = 0
    Player.x = 12
    Player.y = 100
    Player.dir = 1
    Player.cell = 1
    Player.xdir = 0
    Player.ydir = 0
    Otto.alive = FALSE '           reset otto settings
    Room.killed = 0 '              reset room settings
    Room.bullets = 0
    Room.delay = 60
    For c% = 1 To 10 '             cycle through bullet array
        Bullet(c%).alive = FALSE ' kill off any flying bullets
    Next c%
    MAKEMAZE AFTERLIFE '           make random maze
    GENERATEROBOTS EAST '          generate new robots

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                                 ANGLE
Function ANGLE! (r%)

    '**
    '** Returns the angle in degrees from a robot to the player.
    '**
    '** r% - robot to get angle from
    '**
    '** Note: This function is based off of work done by Galleon at the following QB64 forum topic:
    '**       http://www.qb64.net/forum/index.php?topic=3934.0
    '**

    Shared Robot() As ROBOTS ' ARRAY: robot variables
    Shared Player As PLAYER '  ARRAY: player variables

    Dim Px%, Py% '                    player x,y coordinates
    Dim Rx%, Ry% '                    robot x,y coordinats

    Px% = Player.x + 3 '                                                     get player x location
    Py% = Player.y + 7 '                                                     get player y location
    Rx% = Robot(r%).x + 3 '                                                  get robot x location
    Ry% = Robot(r%).y + 5 '                                                  get robot y location

    If Py% = Ry% Then '                                                      are both at same y location?
        If Px% = Rx% Then Exit Function '                                    if same x then on top of each other, leave
        If Px% > Rx% Then ANGLE! = 90 Else ANGLE! = 270 '                    player is directly EAST or WEST
        Exit Function '                                                      leave
    End If
    If Px% = Rx% Then '                                                      are both at same x location?
        If Py% > Ry% Then ANGLE! = 180 '                                     player is directly NORTH or SOUTH
        Exit Function '                                                      leave
    End If
    If Py% < Ry% Then '                                                      is player y less than robot y?
        If Px% > Rx% Then '                                                  yes, is player x greater than robot x?
            ANGLE! = Atn((Px% - Rx%) / (Py% - Ry%)) * -57.2957795131 '       yes, compute angle
        Else '                                                               no
            ANGLE! = Atn((Px% - Rx%) / (Py% - Ry%)) * -57.2957795131 + 360 ' compute angle
        End If
    Else '                                                                   no
        ANGLE! = Atn((Px% - Rx%) / (Py% - Ry%)) * -57.2957795131 + 180 '     compute angle
    End If

End Function

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                         SETSCREENMODE
Sub SETSCREENMODE ()

    '**
    '** Sets the screen properties based on game settings.
    '**
    '** Note: _SCREENMOVE _MIDDLE does not work correctly in QB64GL
    '**       _WIDTH(_SCREENIMAGE) appears to be returning faulty values as well.
    '**

    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared MainScreen& '         IMAGE: main view screen
    Shared WorkRoom& '           IMAGE: main game screen where action takes place
    Shared Icon& '               IMAGE: window icon

    Dim TempScreen& '            IMAGE: temporary screen window
    If MainScreen& Then '                                                 does a screen already exist?
        TempScreen& = _NewImage(1, 1, 32) '                               yes, create a temporary screen
        Screen TempScreen& '                                              switch to temporary screen
        _FreeImage MainScreen& '                                          free previous screen from RAM
    End If
    MainScreen& = _NewImage(256 * Setting.size, 224 * Setting.size, 32) ' create main screen image
    Screen MainScreen& '                                                  switch to this screen
    Cls '                                                                 clear the screen
    _Icon Icon& '                                                         set window icon
    _Title "QBZERK64" '                                                   set window title
    If Setting.full = 2 Then _FullScreen _SquarePixels '                  go full screen if necessary
    If Setting.full = 1 And _FullScreen Then _FullScreen _Off '           leave full screen if necessary
    _Delay 1 '                                                            pause for one second
    _ScreenMove _Middle '                                                 center window on desktop
    If TempScreen& Then _FreeImage TempScreen& '                          remove temp image if it exists
    _Dest WorkRoom& '                                                     go back to working in work room

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                               OPTIONS
Sub OPTIONS ()

    '**
    '** Allows player to change game options
    '**

    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared WorkRoom& '           IMAGE: main game screen where action takes place

    Dim Menu$(3, 4) '                   menu entries
    Dim Opt%(3) '                       game settings
    Dim Current% '                      current menu selected
    Dim c% '                            menu display counter
    Dim fc% '                           full screen test frame counter
    Dim Clr~& '                         menu setting color
    Dim KeyPress$ '                     any key the player presses
    Dim OldSize% '                      origial screen size setting
    Dim OldFS% '                        original full screen setting
    Dim Leave% '                 BOOL : true if ok to leave options screen

    Menu$(1, 0) = " SCREEN SIZE  " '                                               set menu entires
    Menu$(1, 1) = "256 x 224"
    Menu$(1, 2) = "512 x 448"
    Menu$(1, 3) = "768 x 672"
    Menu$(1, 4) = "1024 x 896"
    Menu$(2, 0) = " FULL SCREEN  "
    Menu$(2, 1) = "NO"
    Menu$(2, 2) = "YES"
    Menu$(3, 0) = "EXTRA PLAYER  "
    Menu$(3, 1) = "5000 points"
    Menu$(3, 2) = "10000 points"
    Menu$(3, 3) = "5000 and 10000"
    Opt%(1) = Setting.size '                                                       get current game settings
    Opt%(2) = Setting.full
    Opt%(3) = Setting.extra
    OldFS% = Setting.full '                                                        remember original full screen mode
    OldSize% = Setting.size '                                                      remember original screen size
    Current% = 1 '                                                                 menu starts at first entry
    Do
        Do
            Cls '                                                                  clear work room
            DRAWTEXT 76, 3, "Game Settings", _RGB32(0, 255, 0) '                   draw text
            Line (1, 18)-(254, 19), _RGB32(255, 255, 255), B '                     display box under text
            UPDATESCORE '                                                                       display last player's score
            DRAWTEXT 115, 212, Right$(" " + LTrim$(Str$(Credits%)), 2), _RGB32(255, 255, 255) ' display credits
            Line (1, 204)-(254, 205), _RGB32(255, 255, 255), B '                                draw box above credits
            DRAWTEXT 32, 152, "Use arrow keys to change", _RGB32(255, 255, 0) '    display instructions to player
            DRAWTEXT 24, 176, "Press ESC to save and exit", _RGB32(255, 255, 0) '  display exit instructions to player
            For c% = 1 To 3 '                                                      cycle through menu entries
                If c% = Current% Then '                                            is this the currently selected entry?
                    Clr~& = _RGB32(0, 255, 0) '                                    yes, color it green
                Else '                                                             no
                    Clr~& = _RGB32(255, 0, 0) '                                    color it red
                End If
                DRAWTEXT 20, 24 + c% * 32, Menu$(c%, 0) + Menu$(c%, Opt%(c%)), Clr~& ' draw menu entry
            Next c%
            _PutImage , WorkRoom&, 0 '                                             stretch work room to main screen
            _Display '                                                             update screen with changes
            Do '                                                                   begin keyboard loop
                _Limit 30 '                                                        don't hog the CPU
                KeyPress$ = InKey$ '                                               get any key player presses
                Select Case KeyPress$ '                                            which key did player press?
                    Case Chr$(0) + "H" '                                           UP arrow key
                        Current% = Current% - 1 '                                  go to previous menu entry
                        If Current% = 0 Then Current% = 1 '                        stay at first entry if necessary
                    Case Chr$(0) + "P" '                                           DOWN arrow key
                        Current% = Current% + 1 '                                  go to next menu entry
                        If Current% = 4 Then Current% = 3 '                        stay at last entry if necessary
                    Case Chr$(0) + "M" '                                           RIGHT arrow key
                        Opt%(Current%) = Opt%(Current%) + 1 '                      go to next option selection
                        Select Case Current% '                                     which option was changed?
                            Case 1 '                                               screen size
                                If Opt%(1) = 5 Then Opt%(1) = 1 '                  cycle back to first option if necessary
                            Case 2 '                                               full screen mode
                                If Opt%(2) = 3 Then Opt%(2) = 1 '                  cycle back to first option if necessary
                            Case 3 '                                               extra player values
                                If Opt%(3) = 4 Then Opt%(3) = 1 '                  cycle back to first option if necessary
                        End Select
                    Case Chr$(0) + "K" '                                           LEFT arrow key
                        Opt%(Current%) = Opt%(Current%) - 1 '                      go to previouos option selection
                        Select Case Current% '                                     which option was changed?
                            Case 1 '                                               screen size
                                If Opt%(1) = 0 Then Opt%(1) = 4 '                  cycle back to last option if necessary
                            Case 2 '                                               full screen mode
                                If Opt%(2) = 0 Then Opt%(2) = 2 '                  cycle back to last option if necessary
                            Case 3 '                                               extra player values
                                If Opt%(3) = 0 Then Opt%(3) = 3 '                  cycle back to last option if necessary
                        End Select
                End Select
                If Opt%(2) = 2 Then Opt%(1) = 1 '                                  full screen always uses smallest size
            Loop Until KeyPress$ <> "" '                                           leave when a key has been pressed
        Loop Until KeyPress$ = Chr$(27) '                                          leave when player presses the ESC key
        Setting.size = Opt%(1) '                                                   write options back to settings
        Setting.full = Opt%(2)
        Setting.extra = Opt%(3)
        Leave% = TRUE '                                                            assume it's ok to leave
        If Setting.full = 2 And OldFS% = 1 Then '                                  did player change to full screen?
            Cls '                                                                  clear work room
            DRAWTEXT 76, 3, "Game Settings", _RGB32(0, 255, 0) '                   draw text
            Line (1, 18)-(254, 19), _RGB32(255, 255, 255), B '                     display box under text
            UPDATESCORE '                                                                       display last player's score
            DRAWTEXT 115, 212, Right$(" " + LTrim$(Str$(Credits%)), 2), _RGB32(255, 255, 255) ' display credits
            Line (1, 204)-(254, 205), _RGB32(255, 255, 255), B '                                draw box above credits
            DRAWTEXT 8, 48, "Now entering full screen test", _RGB32(255, 255, 255) ' display dull screen test message
            DRAWTEXT 8, 64, "Follow instructions on screen", _RGB32(255, 255, 255)
            DRAWTEXT 8, 80, "If no instructions wait 10 sec", _RGB32(255, 255, 255)
            DRAWTEXT 8, 96, "Screen will return unchanged", _RGB32(255, 255, 255)
            DRAWTEXT 28, 128, "Press ENTER to start test", _RGB32(255, 255, 0)
            _PutImage , WorkRoom&, 0 '                                             stretch work room to main screen
            _Display '                                                             update screen with changes
            Do '                                                                   wait for player to press ENTER
                _Limit 30 '                                                        don't hog cpu
            Loop Until InKey$ = Chr$(13) '                                         leave when ENTER pressed
            fc% = 0 '                                                              reset frame counter
            SETSCREENMODE '                                                        set new screen settings
            DRAWTEXT 16, 160, "Press X if you can read this", _RGB32(0, 255, 0) '  as player to verify
            _PutImage , WorkRoom&, 0 '                                             stretch work room to main screen
            _Display '                                                             update screen with changes
            Do '                                                                   begin key input test
                _Limit 30 '                                                        don't hog CPU
                fc% = fc% + 1 '                                                    increment frame counter
            Loop Until UCase$(InKey$) = "X" Or fc% = 300 '                         leave when time out or X key pressed
            If fc% = 300 Then '                                                    did the screen time out?
                Setting.size = OldSize% '                                          yes, reset screen size
                Setting.full = OldFS% '                                            reset full screen option
                Opt%(1) = OldSize% '                                               reset screen size menu entry
                Opt%(2) = OldFS% '                                                 reset full screen menu entry
                SETSCREENMODE '                                                    restore old screen settings
                Leave% = FALSE '                                                   it's not ok to leave yet
            End If
        ElseIf Setting.size <> OldSize% Or Setting.full <> OldFS% Then '           did player change something else?
            SETSCREENMODE '                                                        yes, update screen with player's changes
        End If
    Loop Until Leave% '                                                            leave when it's ok
    Open "QBzerk.ini" For Output As #1 '                                           open settings file for output
    Print #1, Setting.size '                                                       save screen size option
    Print #1, Setting.full '                                                       save full screen option
    Print #1, Setting.extra '                                                      save extra player amount
    Close #1 '                                                                     close settings file

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                                 INTRO
Sub INTRO ()

    '**
    '** Displays the intro screen that cycles between the big robot and high score screens.
    '**

    Shared High() As HIGH '      ARRAY: top ten high scores
    Shared Maze3D& '             IMAGE: 3D maze image
    Shared BigRobot&() '         IMAGE: large robot
    Shared QBZerk64l& '          IMAGE: colorful QBzerk64 logo (large)
    Shared WorkRoom& '           IMAGE: main game screen where action takes place
    Shared IntroMusic& '         SOUND: introduction screen background music
    Shared Taunt&() '            SOUND: robot taunts during gameplay (verb, noun, pitch)
    Shared IntruderAlert& '      SOUND: intruder alert, intruder alert
    Shared CoinDetected&() '     SOUND: coin detected in pocket sequences
    Shared Coin& '               SOUND: coin entering machine
    Shared Credits% '                   number of coins currently fed into machine

    Dim Eye% '                          big robot eye x location
    Dim Eyedir% '                       direction of big robot eye
    Dim Ecount% '                       big robot eye counter
    Dim Message$(4) '                   scrolling messages
    Dim m% '                            message pointer
    Dim p% '                            message character position counter
    Dim c% '                            generic counter
    Dim Hscount% '                      high score screen frame counter
    Dim s% '                            high score array counter
    Dim mode% '                         toggles between intro and high score screens
    Dim KeyPress$ '                     any key the user presses
    Dim Blink% '                        text blink counter

    Eye% = 111 '                                                               reset robot eye location
    Eyedir% = 16 '                                                             reset robot eye directon
    m% = 1 '                                                                   reset message pointer
    Message$(1) = Space$(30) + "INTRUDER ALERT  INTRUDER ALERT " '             set scrolling messages
    Message$(2) = Space$(30) + "Humanoid detected in sector 049 083 "
    Message$(3) = Space$(30) + "DESTROY THE HUMANOID "
    Message$(4) = Space$(30) + "Evil Otto has been deployed "
    _Dest WorkRoom& '                                                          draw on work room
    _SndLoop IntroMusic& '                                                     start background music
    Do '                                                                       start intro loop
        _Limit 30 '                                                            30 loops per second
        Select Case mode% '                                                    which mode is active?
            Case 0 '                                                           big robot mode
                _PutImage (0, 0), Maze3D& '                                    display 3D maze screen
                _PutImage (63, 23), BigRobot&(2) '                             display big robot
                Ecount% = Ecount% + 1 '                                        increment eye counter
                If Ecount% = 10 Then '                                         eye frame counter max?
                    Ecount% = 0 '                                              yes, reset frame counter
                    Eye% = Eye% + Eyedir% '                                    move robot eye
                    If Eye% = 95 Or Eye% = 127 Then '                          time to change direction?
                        Eyedir% = -Eyedir% '                                   yes, reverse eye direction
                    End If
                End If
                Line (Eye%, 38)-(Eye% + 31, 53), _RGB32(0, 0, 0), BF '         draw robot eye
                c% = c% + 1 '                                                  increment message delay counter
                If c% = 5 Then '                                               time to scroll message?
                    c% = 0 '                                                   yes, reset message delay counter
                    p% = p% + 1 '                                              increment character position counter
                    If p% = Len(Message$(m%)) Then '                           reached end of message?
                        mode% = 1 '                                            yes, change to high score table mode
                        p% = 0 '                                               reset character position counter
                        m% = m% + 1 '                                          increment message pointer
                        If m% = 5 Then m% = 1 '                                cycle back to first message
                    End If
                    If m% = 1 And p% = 30 Then _SndPlay IntruderAlert& '       play sound at appropriate time
                    If m% = 3 And p% = 25 Then _SndPlay Taunt&(3, 3, 1) '      play sound at appropriate time
                End If
                If Credits% Then '                                             has a coin been inserted?
                    If Ecount% = 0 Then '                                      yes, has eye counter reset?
                        Blink% = 1 - Blink% '                                  yes, flip blinking bit
                    End If
                    DRAWTEXT 48, 188, "Press       to start", _RGB32(255, 0, 0) ' yes, display instructions
                    DRAWTEXT 88, 4, "to fire         move", _RGB32(255, 0, 0) '   display remaining instructions
                    If Blink% Then '                                                  show instructions?
                        DRAWTEXT 96, 188, "ENTER", _RGB32(0, 255, 0) '         yes, show keys to player
                        DRAWTEXT 8, 4, "LEFT CTRL", _RGB32(0, 255, 0) '
                        DRAWTEXT 160, 4, "ARROWS", _RGB32(0, 255, 0)
                    End If
                Else '                                                          no coin inserted yet
                    DRAWTEXT 8, 188, "  to insert coin       options", _RGB32(255, 0, 0) ' ask player for a coin
                    DRAWTEXT 8, 188, "C", _RGB32(0, 255, 0)
                    DRAWTEXT 176, 188, "O", _RGB32(0, 255, 0)
                    DRAWTEXT 8, 7, Mid$(Message$(m%), p%, 30), _RGB32(0, 255, 0) ' display scrolling message portion
                End If
                _PutImage (13, 73), QBZerk64l& '                               display large logo
            Case 1 '                                                           high score table mode
                Cls '                                                          clear work room
                DRAWTEXT 84, 3, "High Scores", _RGB32(0, 255, 0) '             draw text
                Line (1, 18)-(254, 19), _RGB32(255, 255, 255), B '             display box under text
                For s% = 1 To 10 '                                             cycle through high score array
                    If High(s%).s <> 0 Then '                                  show this score?
                        DRAWTEXT 75, 24 + (16 * (s% - 1)), Right$(" " + LTrim$(Str$(s%)), 2), _RGB32(255, 0, 0)
                        DRAWTEXT 99, 24 + (16 * (s% - 1)), Right$("     " + LTrim$(Str$(High(s%).s)), 6), _RGB32(255, 255, 0)
                        DRAWTEXT 155, 24 + (16 * (s% - 1)), High(s%).n, _RGB32(255, 0, 255)
                    End If
                    Line (1, 180)-(254, 181), _RGB32(255, 255, 255), B '       draw box under high scores
                    DRAWTEXT 12, 188, "Q", _RGB32(0, 188, 252) '               show author
                    DRAWTEXT 20, 188, "B", _RGB32(0, 124, 252)
                    DRAWTEXT 28, 188, "ZERK", _RGB32(255, 0, 0)
                    DRAWTEXT 60, 188, "6", _RGB32(252, 188, 0)
                    DRAWTEXT 68, 188, "4", _RGB32(252, 124, 0)
                    DRAWTEXT 92, 188, "2015  Terry Ritchie", _RGB32(255, 255, 255)
                Next s%
                Hscount% = Hscount% + 1 '                                      increment high score frame counter
                If Hscount% = 60 Then '                                        60 frames gone by? (2 seconds)
                    If Credits% = 0 Then '                                                    yes, any credits?
                        If Int(Rnd(1) * 2) Then _SndPlay CoinDetected&(Int(Rnd(1) * 3) + 1) ' no, randomly play sound
                    End If
                End If
                If Hscount% = 300 Then '                                       300 frames gone by? (10 seconds)
                    Hscount% = 0 '                                             yes, reset high score frame counter
                    mode% = 0 '                                                return to big robot mode
                End If
        End Select
        UPDATESCORE '                                                                       display last player's score
        DRAWTEXT 115, 212, Right$(" " + LTrim$(Str$(Credits%)), 2), _RGB32(255, 255, 255) ' display credits
        Line (1, 204)-(254, 205), _RGB32(255, 255, 255), B '                                draw box above credits
        _PutImage , WorkRoom&, 0 '                                             stretch work room to main screen
        _Display '                                                             update screen with changes
        KeyPress$ = UCase$(InKey$) '                                           get every key the player presses
        Select Case KeyPress$ '                                                wich key was presses?
            Case Chr$(27) '                                                    ESC key pressed
                CLEANUP '                                                      leave game
            Case "C" '                                                         player inserted a coin
                Credits% = Credits% + 1 '                                      increment credits
                _SndPlay Coin& '                                               play coin sound
                If Credits% > 99 Then Credits% = 99 '                          let's not go overboard
            Case "O" '                                                         player selected options
                OPTIONS '                                                      display options screen
        End Select
        If _Exit Then CLEANUP '                                                leave if player uses X to close window
    Loop Until KeyPress$ = Chr$(13) And Credits% > 0 '                         leave when player wants to play
    Credits% = Credits% - 1 '                                                  remove a credit from player
    _SndStop IntroMusic& '                                                     stop the background music
    If _SndPlaying(IntruderAlert&) Then _SndStop IntruderAlert& '              stop intruder alert if playing
    If _SndPlaying(Taunt&(3, 3, 1)) Then _SndStop Taunt&(3, 3, 1) '            stop taunt if playing

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                                ASIMOV
Sub ASIMOV ()

    '**
    '** Opening sequence displaying the three human being laws, robot blasting screen, robot approaching and logo.
    '**

    Shared Robot() As ROBOTS ' ARRAY: robot variables
    Shared Piece() As PIECES ' ARRAY: flying screen pieces
    Shared Law() As LAWS '     ARRAY: human being laws
    Shared WorkRoom& '         IMAGE: main game screen where action takes place
    Shared BigRobot&() '       IMAGE: large robot
    Shared Maze3D& '           IMAGE: 3D maze image
    Shared QBZerk64l& '        IMAGE: colorful QBzerk64 logo (large)
    Shared FootStep& '         SOUND: robotic foot step
    Shared Taunt&() '          SOUND: robot taunts during gameplay (verb, noun, pitch)
    Shared Rshoot& '           SOUND: robot shooting
    Shared Pshoot& '           SOUND: player shooting
    Shared Killed& '           SOUND: robot and player killed
    Shared IntruderAlert& '    SOUND: intruder alert, intruder alert

    Dim ShakeRoom& '           IMAGE: shake sequence temp image
    Dim Isaac& '               SOUND: background music
    Dim c% '                          generic counter
    Dim x%, y% '                      piece array counters
    Dim s% '                          generic timer
    Dim r%, g%, b% '                  RGB fade values for law text
    Dim Bx%, By! '                    large logo x,y location
    Dim l% '                          law counter
    Dim L1$, L2$, L3$, L4$ '          law text lines
    Dim Mode% '                       current intro mode

    _Dest WorkRoom& '                                                                draw on work screen
    Cls , _RGB32(0, 0, 63) '                                                         clear screen with dark blue
    ShakeRoom& = _NewImage(256, 224, 32) '                                           create temp image for shake sequence
    Isaac& = _SndOpen("QBzerkL0.ogg", "VOL,SYNC") '                                  load background music
    _SndPlay Isaac& '                                                                play background music
    l% = 1 '                                                                         set law counter
    Robot(0).x = 63 '                                                                set big robot x position
    Robot(0).y = 3 '                                                                 set big robot y position
    Robot(0).cell = 2 '                                                              set initial robot animation cell
    Robot(0).eye = 95 '                                                              set robot eye position
    Robot(0).eyedir = 16 '                                                           set robot eye direction
    Robot(0).fcount = 120 '                                                          set robot frame counter
    Do '                                                                             begin main loop
        _Limit 60 '                                                                  60 frames per second
        If Mode% > 1 Then '                                                          is big robot showing?
            _PutImage (0, 0), Maze3D& '                                              yes, display the maze
            _PutImage (Robot(0).x, Robot(0).y), BigRobot&(Robot(0).cell) '           display the big robot
            Robot(0).ecount = Robot(0).ecount + 1 '                                  increment eye frame counter
            If Robot(0).ecount = 20 Then '                                           eye frame counter max?
                Robot(0).ecount = 0 '                                                yes, reset eye frame counter
                Robot(0).eye = Robot(0).eye + Robot(0).eyedir '                      move robot eye position
                If Robot(0).eye = 95 Or Robot(0).eye = 127 Then '                    time to change direction?
                    Robot(0).eyedir = -Robot(0).eyedir '                             yes, reverse eye direction
                End If
            End If
            Line (Robot(0).eye, Robot(0).y + 15)-(Robot(0).eye + 31, Robot(0).y + 30), _RGB32(0, 0, 0), BF ' draw robot eye
        End If
        Select Case Mode% '                                                          what is the current mode?
            Case 0 '                                                                 display the three laws
                If s% Then '                                                         value in wait timer?
                    s% = s% - 1 '                                                    yes, decrement wait timer
                Else '                                                               no, time's up
                    L1$ = RTrim$(Law(l%).text1) '                                    extra human law text lines
                    L2$ = RTrim$(Law(l%).text2)
                    L3$ = RTrim$(Law(l%).text3)
                    L4$ = RTrim$(Law(l%).text4)
                    If Law(l%).r = 255 Then '                                        is red set to 255?
                        r% = c% '                                                    yes, the red follows color counter
                    ElseIf Law(l%).r = 0 Then '                                      no, is red set to 0?
                        r% = 0 '                                                     yes, then there is no red component
                    Else '                                                           no, it needs to be calculated
                        If Law(l%).m = 25 Then '                                     multiply by .25 and subtract?
                            r% = 63 - c% * (Law(l%).m / 100) '                       yes, calculate red component
                        Else '                                                       no, multiply vy .75 and add
                            r% = 63 + c% * (Law(l%).m / 100) '                       calculate red component
                        End If
                    End If
                    If Law(l%).g = 255 Then '                                        green and blue calculated same way
                        g% = c%
                    ElseIf Law(l%).g = 0 Then
                        g% = 0
                    Else
                        If Law(l%).m = 25 Then
                            g% = 63 - c% * (Law(l%).m / 100)
                        Else
                            g% = 63 + c% * (Law(l%).m / 100)
                        End If
                    End If
                    If Law(l%).b = 255 Then
                        b% = c%
                    ElseIf Law(l%).b = 0 Then
                        b% = 0
                    Else
                        If Law(l%).m = 25 Then
                            b% = 63 - c% * (Law(l%).m / 100)
                        Else
                            b% = 63 + c% * (Law(l%).m / 100)
                        End If
                    End If
                    DRAWTEXT (256 - Len(L1$) * 8) \ 2, Law(l%).y, L1$, _RGB32(r%, g%, b%) '          draw line 1 of law
                    If L2$ <> "-" Then '                                                             line 2 exist?
                        DRAWTEXT (256 - Len(L2$) * 8) \ 2, Law(l%).y + 16, L2$, _RGB32(r%, g%, b%) ' yes, draw it
                    End If
                    If L3$ <> "-" Then '                                                             line 3 exist?
                        DRAWTEXT (256 - Len(L3$) * 8) \ 2, Law(l%).y + 32, L3$, _RGB32(r%, g%, b%) ' yes, draw it
                    End If
                    If L4$ <> "-" Then '                                                             line 4 exist?
                        DRAWTEXT (256 - Len(L4$) * 8) \ 2, Law(l%).y + 48, L4$, _RGB32(r%, g%, b%) ' yes, draw it
                    End If
                    If c% = 32 Then _SndPlay Law(l%).s '                             play law sound at apprpriate time
                    c% = c% + 1 '                                                    increment color counter
                    If c% = 256 Then '                                               color counter reached max?
                        c% = 0 '                                                     yes, reset color counter
                        l% = l% + 1 '                                                increment law counter
                        If l% = 5 Then '                                             all laws been displayed?
                            Mode% = 1 '                                              yes, move onto shake screen mode
                            If _SndPlaying(Isaac&) Then _SndStop Isaac& '            stop background music if playing
                            _PutImage (0, 0), WorkRoom&, ShakeRoom& '                store a copy of work room
                            s% = 15 '                                                set mode 1 wait timer (.25 second)
                            r% = 1 '                                                 set mode 1 robot footstep counter
                        Else '                                                       no, more laws to display
                            s% = 300 '                                               reset wait timer (5 seconds)
                        End If
                    End If
                End If
            Case 1 '                                                                 shake the screen
                If s% Then '                                                         value in wait timer?
                    s% = s% - 1 '                                                    yes, decrement wait timer
                    If s% = 0 Then _SndPlay FootStep& '                              play sound, the robot is coming!
                Else '                                                               no, time's up
                    Cls '                                                            clear the screen
                    x% = Int(Rnd(1) * 3) - Int(Rnd(1) * 3) '                         create random x movement
                    y% = Int(Rnd(1) * 3) - Int(Rnd(1) * 3) '                         create random y movement
                    _PutImage (x%, y%), ShakeRoom&, WorkRoom& '                      show screen in slightly diff position
                    c% = c% + 1 '                                                    increment shake counter
                    If c% = 9 Then '                                                 shake counter maxed?
                        c% = 0 '                                                     yes, reset shake counter
                        s% = 60 '                                                    reset wait timer (1 second)
                        r% = r% + 1 '                                                increment foot step counter
                        If r% = 3 Then _SndPlay Taunt&(3, 3, 1) '                    play sound if third step
                        If r% = 6 Then '                                             foot step counter maxed?
                            Mode% = 2 '                                              yes, move onto screen destroy mode
                            s% = 7 '                                                 set mode 2 piece size increaser
                            c% = 1 '                                                 set mode 2 piece movement counter
                            For x% = 0 To 15 '                                       cycle horizontally across screen
                                For y% = 0 To 13 '                                   cycle vertically across screen
                                    _PutImage (0, 0), WorkRoom&, Piece(x%, y%).image, (x% * 16, y% * 16)-(x% * 16 + 15, y% * 16 + 15) ' get piece
                                    Piece(x%, y%).x = x% * 16 + 7 '                  calculate piece x location
                                    Piece(x%, y%).y = y% * 16 + 7 '                  calculate piece y location
                                    Piece(x%, y%).xdir = ((x% * 16 + 7) - 127) / 8 ' calculate x vector of piece
                                    Piece(x%, y%).ydir = ((y% * 16 + 7) - 111) / 7 ' calculate y vector of piece
                                Next y%
                            Next x%
                            Sleep 1 '                                                wait 1 second (unless key pressed)
                            _SndPlay Rshoot& '                                       play robot shooting sound
                            Sleep 1 '                                                wait 1 second (unless key pressed)
                            _SndPlay Killed& '                                       play sound of screen blowing up
                        End If
                    End If
                End If
            Case 2 '                                                                 screen destroy
                If c% Mod 8 = 0 Then s% = s% + 1 '                                   increase piece size if necessary
                For x% = 0 To 15 '                                                   cycle horizontally through pieces
                    For y% = 0 To 13 '                                               cycle vertically through pieces
                        If Piece(x%, y%).x > -8 And Piece(x%, y%).y > -8 Then '      is piece on screen?
                            _PutImage (Piece(x%, y%).x - s%, Piece(x%, y%).y - s%)-(Piece(x%, y%).x + s% + 1, Piece(x%, y%).y + s% + 1), Piece(x%, y%).image ' yes, display piece
                        End If
                        If c% Mod 8 = 0 Then '                                       time to increase speed of pieces?
                            Piece(x%, y%).xdir = Piece(x%, y%).xdir * 1.25 '         increase speed x by 25%
                            Piece(x%, y%).ydir = Piece(x%, y%).ydir * 1.25 '         increase y speed by 25%
                        End If
                        Piece(x%, y%).x = Piece(x%, y%).x + Piece(x%, y%).xdir '     update piece x location
                        Piece(x%, y%).y = Piece(x%, y%).y + Piece(x%, y%).ydir '     update piece y location
                    Next y%
                Next x%
                c% = c% + 1 '                                                        increment piece movement counter
                If c% = 65 Then '                                                    all pieces moved max distance?
                    Mode% = 3 '                                                      yes, move onto robot walking mode
                    _SndPlay IntruderAlert& '                                        the robot now sees you!
                End If
            Case 3 '                                                                 robot walking toward player
                Robot(0).fcount = Robot(0).fcount - 1 '                              decrement robot frame counter
                If Robot(0).fcount = 0 Then '                                        countdown complete?
                    Robot(0).fcount = 40 '                                           yes, reset frame counter (.66 second)
                    Robot(0).cell = Robot(0).cell + 1 '                              increment to next animation cell
                    If Robot(0).cell = 5 Then Robot(0).cell = 1 '                    cycle back to first cell if needed
                    _SndPlay FootStep& '                                                         play foot step sound
                    If Robot(0).cell = 1 Or Robot(0).cell = 3 Then Robot(0).y = Robot(0).y + 5 ' move robot down if needed
                End If
                If Robot(0).y = 23 And Robot(0).cell = 2 Then '                      robot finished moving?
                    Mode% = 4 '                                                      yes, move onto show logo mode
                    Bx% = 127 '                                                      set logo x position
                    By! = 111 '                                                      set logo y position
                    _SndPlay Pshoot& '                                               player shooting sound
                End If
            Case 4 '                                                                 show logo
                Bx% = Bx% - 2 '                                                      decrement logo x position
                By! = By! - .6666666 '                                                    decrement logo y position
                _PutImage (Bx%, By!)-(127 + (127 - Bx%), 111 + (111 - By!)), QBZerk64l& ' display shrunk logo
                If Bx% = 13 Then Mode% = 5 '                                              leave when logo full size
        End Select
        _PutImage , WorkRoom&, 0 '                                                   stretch work room to main screen
        _Display '                                                                   update main screen
        If _Exit Then CLEANUP '                                                      leave if player uses X to close window
    Loop Until Mode% = 5 Or InKey$ <> "" '                                           leave when finished or player hits key
    If _SndPlaying(Isaac&) Then _SndStop Isaac& '                                    stop background music if playing
    For x% = 0 To 15 '                                                               cycle horizontally through piece images
        For y% = 0 To 13 '                                                           cycle vertically through piece images
            _FreeImage Piece(x%, y%).image '                                         image no longer needed
        Next y%
    Next x%
    _FreeImage ShakeRoom& '                                                          image no longer needed
    _SndClose FootStep& '                                                            sounds no longer needed
    _SndClose Isaac&
    _SndClose Law(1).s
    _SndClose Law(2).s
    _SndClose Law(3).s
    _SndClose Law(4).s

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                         UPDATEBULLETS
Sub UPDATEBULLETS ()

    '**
    '** Maintains the bullets flying around on the screen
    '**

    Shared Robot() As ROBOTS '   ARRAY: robot variables
    Shared Player As PLAYER '    ARRAY: player variables
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Room As ROOM '        ARRAY: room variables
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Maze& '               IMAGE: level maze
    Shared Rimage&() '           IMAGE: robot images
    Shared Rmask& '              IMAGE: robot mask area
    Shared Killed& '             SOUND: robot and player killed

    Dim c% '                            generic counter
    Dim Oldx% '                         beginning x coordinate of bullet
    Dim Oldy% '                         beginning y coordinate of bullet
    Dim Newx% '                         ending x coordinate of bullet
    Dim Newy% '                         ending y coordinate of bullet
    Dim s% '                            bullet pixel position counter
    Dim Bhit% '                  BOOL : true when bullet hits robot
    Dim Cdest& '                        calling routine destination

    If Room.delay Then Exit Sub '                                                       leave if in room delay state
    Cdest& = _Dest '                                                                    remember calling routine destination
    c% = 0 '                                                                            reset robot counter
    Do '                                                                                cycle through all robots
        c% = c% + 1 '                                                                   increment robot counter
        If Robot(c%).bcount Then Robot(c%).bcount = Robot(c%).bcount - 1 '              decrement robot bullet frame count
    Loop Until c% = 15 '                                                                leave when all robots checked
    If Player.bcount Then Player.bcount = Player.bcount - 1 '                           decrement player bullet frame count
    c% = 0 '                                                                            reset bullet counter
    Do '                                                                                cycle through bullet array
        _Source Maze& '                                                                 use maze image to compare bullet wall hits
        c% = c% + 1 '                                                                   increment bullet counter
        If Bullet(c%).alive Then '                                                      is this bullet active?
            Bullet(c%).oldx = Bullet(c%).x + Sgn(Bullet(c%).xdir) '                     get last x position in new bullet trace
            Bullet(c%).oldy = Bullet(c%).y + Sgn(Bullet(c%).ydir) '                     get last y position in new bullet trace
            s% = 0 '                                                                    reset bullet pixel counter
            Do '                                                                        cycle through length of bullet
                s% = s% + 1 '                                                           increment pixel counter
                Newx% = Bullet(c%).x + (s% * Sgn(Bullet(c%).xdir)) '                    get next x location to check
                Newy% = Bullet(c%).y + (s% * Sgn(Bullet(c%).ydir)) '                    get next y location to check
                If Point(Newx%, Newy%) = _RGB32(0, 0, 255) Then '                       will bullet hit a wall?
                    If s% = 1 Then '                                                    yes, it is already at wall?
                        Bullet(c%).alive = FALSE '                                      yes, make bullet inactive
                    Else '                                                              no, bullet still has some travel
                        Newx% = Oldx% '                                                 make previous pixel the new x location
                        Newy% = Oldy% '                                                 make previous pixel the new y location
                    End If
                    Exit Do '                                                           leave loop, no need to continue
                End If
                _Source Cdest&
                If Point(Newx%, Newy%) = Level(Room.level).rcolor Then Bhit% = TRUE '   remember if bullets collide
                If Newx% = 3 Or Newx% = 252 Or Newy% = -1 Or Newy% = 208 Then '         did bullet go through door?
                    If s% = 1 Then '                                                    yes, is bullet already at door?
                        Bullet(c%).alive = FALSE '                                      yes, make bullet inactive
                    Else '                                                              no, bullet still has some travel
                        Newx% = Oldx% '                                                 make previous pixel the new x location
                        Newy% = Oldy% '                                                 make previous pixel the new y location
                    End If
                    Exit Do '                                                           leave loop, no need to continue
                End If
                Oldx% = Bullet(c%).x + (s% * Sgn(Bullet(c%).xdir)) '                    remember last x location checked
                Oldy% = Bullet(c%).y + (s% * Sgn(Bullet(c%).ydir)) '                    remember last y location checked
            Loop Until s% = Abs(Bullet(c%).xdir) Or s% = Abs(Bullet(c%).ydir) '         leave when entire bullet scanned
            Bullet(c%).x = Newx% '                                                      record new x location
            Bullet(c%).y = Newy% '                                                      record new y location
            If Bullet(c%).alive Then '                                                  is bullet still active?
                _Dest Cdest& '                                                                     return to calling destination
                Line (Bullet(c%).oldx, Bullet(c%).oldy)-(Newx%, Newy%), Level(Room.level).rcolor ' draw bullet to work screen
                If Bhit% Then '                                                                    did bullets collide?
                    Bhit% = FALSE '                                                     yes, reset hit flag
                    Bullet(c%).alive = FALSE '                                          this bullet now inactive
                End If
            End If
            If Not Bullet(c%).alive Then '                                              is bullet still active?
                If Bullet(c%).who = 0 Then '                                            no, did bullet belong to player?
                    Player.bullets = Player.bullets - 1 '                               yes, remove bullet from player
                Else '                                                                  no, bullet belongs to a robot
                    Robot(Bullet(c%).who).bullets = Robot(Bullet(c%).who).bullets - 1 ' remove bullet from robot
                    Room.bullets = Room.bullets - 1 '                                   decrement room shot counter
                End If
            End If
        End If
    Loop Until c% = 10 '                                                                leave when all bullets checked

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                           RANDOMTAUNT
Sub RANDOMTAUNT ()

    '**
    '** Plays random taunt messages to player.
    '**

    Shared Player As PLAYER ' ARRAY: player variables
    Shared Room As ROOM '     ARRAY: room variables
    Shared Taunt&() '         SOUND: robot taunts during gameplay (verb, noun, pitch)
    Shared Ctaunt& '          SOUND: current taunt playing
    Shared IntruderAlert& '   SOUND: intruder alert, intruder alert
    Shared GotTheHumanoid& '  SOUND: got the humanoid, got the intruder

    Dim Verb% '                      robot voice verb (attack, charge, destroy, fight, get, kill, shoot)
    Dim Noun% '                      robot voice noun (it, humanoid, intruder, chicken)
    Dim Pitch% '                     robot voice pitch (low, normal, high)

    If Room.killed = Room.robots Then Exit Sub '              no taunts if all robots killed
    If _SndPlaying(IntruderAlert&) Then Exit Sub '            no taunt if intruder alert playing
    If _SndPlaying(GotTheHumanoid&) Then Exit Sub '           no taunt if robots gloating
    Player.tcount = Player.tcount + 1 '                       increment taunt frame counter
    If Player.tcount > Player.taunt Then '                    time for a taunt?
        Player.tcount = 0 '                                   yes, reset taunt frame counter
        Player.taunt = Int(Rnd(1) * 300) + 150 '              set up random time for next taunt (5 to 15 seconds)
        Verb% = Int(Rnd(1) * 7) + 1 '                         random verb
        Noun% = Int(Rnd(1) * (4 + Abs(Player.chicken))) + 1 ' random noun
        Pitch% = Int(Rnd(1) * 3) + 1 '                        random pitch
        Ctaunt& = Taunt&(Verb%, Noun%, Pitch%) '              get the taunt from arrary
        _SndPlay Ctaunt& '                                    play the taunt
    End If

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                          UPDATEROBOTS
Sub UPDATEROBOTS ()

    '**
    '** Robot AI. Tried to simulate "dumbness" of robots by having they collide with each other and run into walls. But
    '** their overall intelligence when pursuing the player has been increased from the original game. Also, the closer
    '** the player gets to a robot the wider field of view the robot has, increasing its chance of shooting the player.
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared Robot() As ROBOTS '   ARRAY: robot variables
    Shared Room As ROOM '        ARRAY: room variables
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Maze& '               IMAGE: level maze
    Shared Rshoot& '             SOUND: robot shooting

    Dim c% '                            robot counter
    Dim dx%, dy% '                      x,y distance from robot to player
    Dim x%, y% '                        wall detection vectors
    Dim Xdir% '                         x direction of robot to player
    Dim Ydir% '                         y direction of robot to player
    Dim a% '                            angle of robot to player
    Dim Fire% '                  BOOL : true if robot is going to fire
    Dim Dpm% '                          deflection angle plus/minus

    If Room.killed = Room.robots Then Exit Sub '                              no robots to update? then leave
    If Room.delay Then Exit Sub '                                             leave if in room delay state
    c% = 0 '                                                                  reset robot counter
    _Source Maze& '                                                           source for robot wall detection
    Do '                                                                      cycle through all robots
        c% = c% + 1 '                                                         increment robot counter
        If Robot(c%).alive Then '                                             is this robot active?
            dx% = Abs(Robot(c%).x + 3 - Player.x + 3) '                       calculate x distance between robot and player
            dy% = Abs(Robot(c%).y + 5 - Player.y + 7) '                       calculate y distance between robot and player
            If Robot(c%).bullets = 0 Then '                                   yes, does robot have any bullets flying?
                Robot(c%).fcount = Robot(c%).fcount + 1 '                     no, increment frame movement counter
                If Robot(c%).xmcount Then '                                   value in x movement frame counter?
                    Robot(c%).xmcount = Robot(c%).xmcount - 1 '               yes, decrement x movement frame counter
                    If Robot(c%).xmcount = 0 Then '                           complete count down of x movement frame counter?
                        Robot(c%).xmcount = Int(Rnd(1) * 150) + 150 '         yes, reset x movement frame counter
                        Robot(c%).xmode = Int(Rnd(1) * 2) '                   set x movement mode of robot (0 = no, 1 = yes)
                    End If
                End If
                If Robot(c%).ymcount Then '                                   value in y movement frame counter?
                    Robot(c%).ymcount = Robot(c%).ymcount - 1 '               yes, decrement y movement frame counter
                    If Robot(c%).ymcount = 0 Then '                           complete count down of y movement frame counter?
                        Robot(c%).ymcount = Int(Rnd(1) * 150) + 150 '         yes, reset y movement frame counter
                        Robot(c%).ymode = Int(Rnd(1) * 2) '                   set y movement mode of robot (0 = no, 1 = yes)
                    End If
                End If
                If Robot(c%).fcount >= Room.robots - Room.killed Then '       frame movement counter reached max?
                    Robot(c%).fcount = 0 '                                    yes, reset frame movement counter
                    Robot(c%).xdir = Sgn(Player.x - Robot(c%).x) '            get x vector direction of player to robot
                    Robot(c%).ydir = Sgn(Player.y - Robot(c%).y) '            get y vector direction of player to robot
                    y% = Robot(c%).y + 2 '                                    set y wall scan position
                    Do '                                                      cycle through y wall coordinates (EAST/WEST)
                        y% = y% + 1 '                                                                   increment y position
                        If Point(Robot(c%).x + 3 + (Robot(c%).xdir * 6), y%) = _RGB32(0, 0, 255) Then ' wall here?
                            Robot(c%).xdir = 0 '                                                        yes, stop robot
                            Exit Do '                                         no need to look further
                        End If
                    Loop Until y% = Robot(c%).y + 8 '                         leave when all y positions checked
                    x% = Robot(c%).x + 2 '                                    set x wall scan position
                    Do '                                                      cycle through x wall coordinates (NORTH/SOUTH)
                        x% = x% + 1 '                                                                   increment x position
                        If Point(x%, Robot(c%).y + 5 + (Robot(c%).ydir * 7)) = _RGB32(0, 0, 255) Then ' wall here?
                            Robot(c%).ydir = 0 '                                                        yes, stop robot
                            Exit Do '                                         no need to look further
                        End If
                    Loop Until x% = Robot(c%).x + 4 '                         leave when all x positions checked
                    If Sqr(dx% * dx% + dy% * dy%) > Robot(c%).distance Then ' is overall distance too far?
                        If Robot(c%).xmode = 0 Then Robot(c%).xdir = 0 '      yes, over-ride robot x movement
                        If Robot(c%).ymode = 0 Then Robot(c%).ydir = 0 '      over-ride robot y movement
                    End If
                    Robot(c%).x = Robot(c%).x + Robot(c%).xdir '              update robot x position
                    Robot(c%).y = Robot(c%).y + Robot(c%).ydir '              update robot y position
                End If
            End If
            If Room.level > 1 Then '                                                     no, above level 1?
                If Room.bullets < Level(Room.level).bullets Then '                       yes, maximum bullets already flying?
                    If Robot(c%).bullets < Level(Room.level).rbullets Then '             no, can robot shoot another bullet?
                        If Robot(c%).bcount = 0 Then '                                   yes, ok for robot to fire?
                            If Int(Rnd(1) * (Room.robots - Room.killed)) = 0 Then '      yes, does the robot want to fire?
                                b% = 0 '                                                 yes, reset bullet counter
                                Do '                                                     find an available bullet
                                    b% = b% + 1 '                                        increment bullet counter
                                Loop Until Not Bullet(b%).alive '                        leave when inactive bullet found
                                Bullet(b%).y = Robot(c%).y + 5 '                         set bullet's y location
                                a% = Int(ANGLE!(c%)) '                                   get angle from robot to player
                                Fire% = TRUE '                                           assume robot will actually fire
                                Select Case Int(Sqr(dx% * dx% + dy% * dy%)) '            what is the distance to player?
                                    Case Is > 200 '                                      greater than 200 pixels
                                        Dpm% = 2 '                                       set very narrow band of view
                                    Case 151 To 200 '                                    151 to 200 pixels
                                        Dpm% = 3 '                                       set narrow band of view
                                    Case 101 To 150 '                                    101 to 150 pixels
                                        Dpm% = 4 '                                       set normal band of view
                                    Case 51 To 100 '                                     51 to 100 pixels
                                        Dpm% = 5 '                                       set wide band of view
                                    Case Is < 51 '                                       50 pixels or less
                                        Dpm% = 10 '                                      set very wide band of view
                                End Select
                                Select Case a% '                                         which angle was found?
                                    Case 359 - Dpm% + 1 To 359 '                         NORTH slightly WEST
                                        Xdir% = 0 '                                      EAST/WEST to none
                                        Ydir% = -1 '                                     NORTH
                                        If Room.level > 6 Then '                         level 7 or higher?
                                            Bullet(b%).x = Robot(c%).x - 1 '             robot allowed to shoot from left
                                        Else '                                           no, level 6 or below
                                            Bullet(b%).x = Robot(c%).x + 8 '             robot shoots from right side
                                        End If
                                    Case 0 '                                             NORTH
                                        Xdir% = 0 '                                      EAST/WEST to none
                                        Ydir% = -1 '                                     NORTH
                                        If Room.level > 6 Then '                         level 7 or higher?
                                            If Int(Rnd(1) * 2) = 0 Then '                yes, shoot from which side?
                                                Bullet(b%).x = Robot(c%).x - 1 '         left side
                                            Else
                                                Bullet(b%).x = Robot(c%).x + 8 '         right side
                                            End If
                                        Else '                                           no, level 6 or below
                                            Bullet(b%).x = Robot(c%).x + 8 '             right side only
                                        End If
                                    Case 1 To Dpm% '                                     NORTH slightly EAST
                                        Xdir% = 0 '                                      EAST/WEST to none
                                        Ydir% = -1 '                                     NORTH
                                        Bullet(b%).x = Robot(c%).x + 8 '                 set bullet's x location
                                    Case 45 - Dpm% To 45 + Dpm% '                        NORTHEAST
                                        Xdir% = 1 '                                      EAST
                                        Ydir% = -1 '                                     NORTH
                                        Bullet(b%).x = Robot(c%).x + 8 '                 set bullet's x location
                                    Case 90 - Dpm% To 90 + Dpm% '                        EAST
                                        Xdir% = 1 '                                      EAST
                                        Ydir% = 0 '                                      NORTH/SOUTH to none
                                        Bullet(b%).x = Robot(c%).x + 8 '                 set bullet's x location
                                    Case 135 - Dpm% To 135 + Dpm% '                      SOUTHEAST
                                        Xdir% = 1 '                                      EAST
                                        Ydir% = 1 '                                      SOUTH
                                        Bullet(b%).x = Robot(c%).x + 8 '                 set bullet's x location
                                    Case 180 - Dpm% To 179 '                             SOUTH slightly EAST
                                        Xdir% = 0 '                                      EAST/WEST to none
                                        Ydir% = 1 '                                      SOUTH
                                        Bullet(b%).x = Robot(c%).x + 8 '                 set bullet's x location
                                    Case 180 '                                           SOUTH
                                        Xdir% = 0 '                                      EAST/WEST to none
                                        Ydir% = 1 '                                      SOUTH
                                        If Room.level > 6 Then '                         level 7 or higher?
                                            If Int(Rnd(1) * 2) = 0 Then '                yes, shoot from which side?
                                                Bullet(b%).x = Robot(c%).x + 8 '         right side
                                            Else
                                                Bullet(b%).x = Robot(c%).x - 1 '         left side
                                            End If
                                        Else '                                           no, level 6 or below
                                            Bullet(b%).x = Robot(c%).x + 8 '             right side only
                                        End If
                                    Case 181 To 180 + Dpm% '                             SOUTH slightly WEST
                                        Xdir% = 0 '                                      EAST/WEST to none
                                        Ydir% = 1 '                                      SOUTH
                                        If Room.level > 6 Then '                         level 7 or higher?
                                            Bullet(b%).x = Robot(c%).x - 1 '             yes, robot shoots from left
                                        Else '                                           no, level 6 or below
                                            Bullet(b%).x = Robot(c%).x + 8 '             right side only
                                        End If
                                    Case 225 - Dpm% To 225 + Dpm% '                      SOUTHWEST
                                        Xdir% = -1 '                                     WEST
                                        Ydir% = 1 '                                      SOUTH
                                        Bullet(b%).x = Robot(c%).x - 1 '                 set bullet's x location
                                    Case 270 - Dpm% To 270 + Dpm% '                      WEST
                                        Xdir% = -1 '                                     WEST
                                        Ydir% = 0 '                                      NORTH/SOUTH to none
                                        Bullet(b%).x = Robot(c%).x - 1 '                 set bulet's x location
                                    Case 315 - Dpm% To 315 + Dpm% '                      NORTHWEST
                                        Xdir% = -1 '                                     NORTH
                                        Ydir% = -1 '                                     WEST
                                        Bullet(b%).x = Robot(c%).x - 1 '                 set bullet's x location
                                    Case Else '                                          player out of range
                                        Fire% = FALSE '                                  robot will not fire
                                End Select
                                If Fire% Then '                                          ok for robot to fire?
                                    Bullet(b%).xdir = Xdir% * Level(Room.level).bspeed ' yes, set bullet's x direction
                                    Bullet(b%).ydir = Ydir% * Level(Room.level).bspeed ' set bullet's y direction
                                    Bullet(b%).who = c% '                                remember which robot shot bullet
                                    Bullet(b%).alive = TRUE '                            bullet is now active
                                    Room.bullets = Room.bullets + 1 '                    increment room bullet counter
                                    Robot(c%).bullets = Robot(c%).bullets + 1 '          increment robot bullet counter
                                    Robot(c%).bcount = 15 '                              reset bullet frame counter
                                    Robot(c%).xdir = 0 '                                 robot needs to remain still
                                    Robot(c%).ydir = 0 '                                 during firing sequence
                                    _SndPlay Rshoot& '                                   play robot shooting sound
                                End If
                            End If
                        End If
                    End If
                End If
            End If
        End If
    Loop Until c% = 15 '                                                                 leave when all robots updated

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            DRAWROBOTS
Sub DRAWROBOTS ()

    '**
    '** Displays the robots on screen. Also handles Evil Otto's appearance and bouncing around on screen.
    '**

    Shared Robot() As ROBOTS '   ARRAY: robot variables
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Room As ROOM '        ARRAY: room variables
    Shared Player As PLAYER '    ARRAY: player variables
    Shared Otto As OTTO '        ARRAY: evil otto properties
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Rimage&() '           IMAGE: robot images
    Shared Rmask& '              IMAGE: robot mask area
    Shared Boom&() '             IMAGE: robot blowing up
    Shared BoomMask& '           IMAGE: mask area for exploding robots
    Shared Otto&() '             IMAGE: Evil Otto!
    Shared OttoMask& '           IMAGE: evil otto mask
    Shared Killed& '             SOUND: robot and player killed
    Shared IntruderAlert& '      SOUND: intruder alert, intruder alert
    Shared Ctaunt& '             SOUND: current taunt playing

    Dim Cdest& '                        calling destination
    Dim c% '                            robot zone counter
    Dim x%, y% '                        coordinate counters for collision test
    Dim bx%, by% '                      upper left x,y coordinate of bullet
    Dim b% '                            bullet counter

    Cdest& = _Dest '                                                                  remember calling destination
    If Player.mode <> ZAPPED Then '                                                   is player flashing?
        If Otto.acount Then '                                                         no, value in appearance counter?
            Otto.acount = Otto.acount - 1 '                                           yes, decrement  counter
            If Otto.acount = 0 Then '                                                 has counter run out?
                Otto.alive = TRUE '                                                   yes, evil otto awakens
                Otto.fcount = 0 '                                                     reset frame counter
                Otto.cell = 0 '                                                       reset otto animation cell
                Otto.bounce = FALSE '                                                 otto is not yet bouncing
                If _SndPlaying(Ctaunt&) Then _SndStop Ctaunt& '                       stop taunt if it is playing
                _SndPlay IntruderAlert& '                                             INTRUDER ALERT! INTRDUER ALERT!
            End If
        End If
    End If
    If Otto.alive Then '                                                              has otto been activated?
        If Otto.bounce Then '                                                         yes, perform otto bouncing?
            Otto.fcount = Otto.fcount + 1 '                                           yes, increment frame counter
            If Otto.fcount > Room.robots - Room.killed Then '                         frame counter reached max?
                Otto.fcount = 0 '                                                     yes, reset frame counter
                Otto.yoffset = Otto.yoffset + Otto.yvel '                             calculate bounce height
                Otto.yvel = Otto.yvel - 2 '                                           caclulate new bounce y velocity
                If Otto.yoffset = 0 Then '                                            has a complete bounce occurred?
                    Otto.yvel = 7 '                                                   yes, reset bounce y velocity
                    Otto.cell = 3 '                                                   set animation cell to slightly squashed
                Else '                                                                no, still mid bounce
                    Otto.cell = 5 '                                                   show evil ott's evil smiley face
                End If
                Otto.xdir = Sgn(Player.x - Otto.x) '                                  get x direction to player
                Otto.ydir = Sgn(Player.y + 7 - Otto.y) '                              get y direction to player
                Otto.x = Otto.x + Otto.xdir '                                         move otto in x direction to player
                Otto.y = Otto.y + Otto.ydir '                                         move otto in y direction to player
            End If
        Else '                                                                        no, perform otto appearance sequence
            If Otto.fcount Then Otto.fcount = Otto.fcount - 1 '                       decrement count down timer if value
            If Otto.fcount = 0 Then '                                                 has count down timer run out?
                Otto.cell = Otto.cell + 1 '                                           increment otto animation cell
                If Otto.cell = 4 Then '                                               has otto completely appeared?
                    Otto.bounce = TRUE '                                              yes, otto will now bounce
                    Otto.fcount = 0 '                                                 reset frame counter
                Else '                                                                no, otto still appearing
                    Otto.fcount = 5 '                                                 reset count down timer
                End If
            End If
        End If
        _Dest OttoMask& '                                                             draw on otto mask
        Cls , Level(Room.level).rcolor '                                              clear mask to robot color
        _PutImage (0, 0), Otto&(Otto.cell), OttoMask& '                               place otto animation cell on mask
        _ClearColor _RGB32(0, 0, 0), OttoMask& '                                      make black transparent
        _Dest Cdest& '                                                                return to calling destination
        _PutImage (Otto.x, Otto.y - Otto.yoffset), OttoMask& '                        place otto onto work room
    End If
    If Room.killed = Room.robots Then Exit Sub '                                      no robots? no need to update then
    c% = 0 '                                                                          reset robot counter
    Do '                                                                              cycle through exploding robots
        c% = c% + 1 '                                                                 increment robot counter
        If Robot(c%).hit Then '                                                       is robot exploding?
            _Dest BoomMask& '                                                         yes, draw on boom mask
            Cls , Level(Room.level).rcolor '                                          clear mask with robot color
            _PutImage (0, 0), Boom&(Robot(c%).cell) '                                 place explode image over mask
            _ClearColor _RGB32(0, 0, 0), BoomMask& '                                  make black transparent
            _PutImage (Robot(c%).x - 4, Robot(c%).y - 3), BoomMask&, Cdest& '         place mask image onto work room
            Robot(c%).fcount = Robot(c%).fcount - 1 '                                 decrement frame counter
            If Robot(c%).fcount% = 0 Then '                                           has counter run out?
                Robot(c%).fcount = 5 '                                                yes, reset counter
                Robot(c%).cell = Robot(c%).cell + 1 '                                 increment robot animation cell
                If Robot(c%).cell = 4 Then '                                          reached the last cell?
                    Robot(c%).hit = FALSE '                                           yes, robot done exploding
                    Room.killed = Room.killed + 1 '                                   increment room kill counter
                End If
            End If
        End If
    Loop Until c% = 15 '                                                              leave when all robotos checked
    c% = 0 '                                                                          reset robot counter
    Do '                                                                              cycle through all robots
        c% = c% + 1 '                                                                 increment robot counter
        If Robot(c%).alive Then '                                                     is this robot active?
            _Source Rmask& '                                                          yes, set image source
            _Dest Rmask& '                                                                                     set image destination
            _PutImage (0, 0), Cdest&, Rmask&, (Robot(c%).x, Robot(c%).y)-(Robot(c%).x + 7, Robot(c%).y + 11) ' get robot area from screen
            _PutImage (0, 0), Rimage&(Robot(c%).cell, Robot(c%).dir) '                                         place mask over top of image
            x% = -1 '                                                                 reset x mask location
            Do '                                                                      cycle horiz through mask
                x% = x% + 1 '                                                         increment x mask location
                y% = -1 '                                                             reset y mask location
                Do '                                                                  cycle vert through mask
                    y% = y% + 1 '                                                     increment y mask location
                    If Point(x%, y%) <> _RGB32(0, 0, 0) Then '                        colored pixel here?
                        Robot(c%).hit = TRUE '                                        yes, robot hit
                        Robot(c%).alive = FALSE '                                     robot is now inactive
                        Robot(c%).cell = 1 '                                          set robot animation cell
                        Robot(c%).fcount = 5 '                                        reset robot frame counter
                        b% = 0 '                                                      reset bullet counter
                        Do '                                                          cycle through bullets
                            b% = b% + 1 '                                             increment bullet counter
                            If Bullet(b%).alive Then '                                                                  bullet active?
                                If Bullet(b%).x <= Bullet(b%).oldx Then bx% = Bullet(b%).x Else bx% = Bullet(b%).oldx ' yes, upper left x
                                If Bullet(b%).y <= Bullet(b%).oldy Then by% = Bullet(b%).y Else by% = Bullet(b%).oldy ' upper left y
                                If bx% <= Robot(c%).x + 7 Then '                                                        box collision check
                                    If bx% + Abs(Bullet(b%).x - Bullet(b%).oldx) >= Robot(c%).x Then
                                        If by% <= Robot(c%).y + 11 Then
                                            If by% + Abs(Bullet(b%).y - Bullet(b%).oldy) >= Robot(c%).y Then '          box collision?
                                                Bullet(b%).alive = FALSE '                                              yes, bullet now inactive
                                                If Bullet(b%).who = 0 Then '                                            bullet belong to player?
                                                    Player.bullets = Player.bullets - 1 '                               yes, remove from player
                                                Else '                                                                  no, belongs to a robot
                                                    Robot(Bullet(b%).who).bullets = Robot(Bullet(b%).who).bullets - 1 ' remove bullet from robot
                                                    Room.bullets = Room.bullets - 1 '                                   decrement room shot counter
                                                End If
                                            End If
                                        End If
                                    End If
                                End If
                            End If
                        Loop Until b% = 10 '                                          leave when all bullets checked
                    End If
                Loop Until y% = 11 Or Robot(c%).hit '                                 leave at bottom of mask or robot hit
            Loop Until x% = 7 Or Robot(c%).hit '                                      leave at right side of mask or robot hit
            If Robot(c%).hit Then '                                                   was the robot hit?
                Player.score = Player.score + 50 '                                    yes, add robot score to player
                _SndPlay Killed& '                                                    play robot exploding sound
            Else '                                                                    no, robot still active
                If Robot(c%).xdir Then '                                              is robot moving right or left?
                    Robot(c%).dir = Sgn(Robot(c%).xdir) '                             yes, get robot direction
                    If Robot(c%).fcount = 0 Then '                                    has frame counter run out?
                        Robot(c%).cell = Robot(c%).cell - 1 '                         yes, move to next animation cell
                        If Robot(c%).cell < 6 Then Robot(c%).cell = 7 '               keep animation cell within limits
                    End If
                ElseIf Robot(c%).ydir Then '                                          no, is robot moving up or down?
                    If Robot(c%).fcount = 0 Then '                                    yes, has frame counter run out?
                        Robot(c%).cell = Robot(c%).cell + 1 '                         yes, move to next animation cell
                        If Robot(c%).cell > 5 Then Robot(c%).cell = 2 '               keep animation cell within limits
                    End If
                Else '                                                                no, robot is standing still
                    Robot(c%).cell = 1 '                                              set animation cell to still image
                End If
            End If
            Cls , Level(Room.level).rcolor '                                          clear rmask to robot color
            _PutImage (0, 0), Rimage&(Robot(c%).cell, Robot(c%).dir) '                place robot image on rmask
            If Robot(c%).cell = 1 Or Robot(c%).ydir = 1 Then '                        robot standing still or moving down?
                If Robot(c%).xdir = 0 Then '                                          yes, is robot moving diagonally?
                    Robot(c%).ecount = Robot(c%).ecount + 1 '                         no, increment eye frame counter
                    If Robot(c%).ecount = 5 Then '                                    eye frame counter max?
                        Robot(c%).ecount = 0 '                                        yes, reset eye frame counter
                        Robot(c%).eye = Robot(c%).eye + Robot(c%).eyedir '            move robot eye to next position
                        If Robot(c%).eye = 1 Or Robot(c%).eye = 5 Then '              time to change direction?
                            Robot(c%).eyedir = -Robot(c%).eyedir '                    yes, reverse eye direction
                        End If
                    End If
                    Line (Robot(c%).eye, 1)-(Robot(c%).eye + 1, 1), _RGB32(0, 0, 0) ' draw robot eye
                End If
            End If
            _ClearColor _RGB32(0, 0, 0), Rmask& '                                     black will be transparent
            _PutImage (Robot(c%).x, Robot(c%).y), Rmask&, Cdest& '                    place robot onto work room
        End If
    Loop Until c% = 15 '                                                              leave when all robots checked
    _Dest Cdest& '                                                                    return to calling destination

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                        GENERATEROBOTS
Sub GENERATEROBOTS (Heading%)

    '**
    '** Generates robots for a new maze.
    '**

    Shared Robot() As ROBOTS ' ARRAY: robot variables
    Shared Room As ROOM '      ARRAY: room variables
    Shared Player As PLAYER '  ARRAY: player variables
    Shared Level() As LEVEL '  ARRAY: level properties
    Shared Otto As OTTO '      ARRAY: evil otto properties
    Shared Icon& '             IMAGE: window icon
    Shared IconOtto& '         IMAGE: otto window icon image

    Dim Max% '                        max number of robots per level
    Dim c% '                          generic counter
    Dim Rz% '                         robot zone indicator
    Dim Pz% '                         player zone indicator
    Dim RGB%(3) '                     random color components
    Dim RGBadd% '                     color components added together
    Dim Cdest& '                      calling destination

    Cdest& = _Dest '                                                remember calling destination
    If Player.score >= Level(Room.level).points Then '              have level up points been reached?
        Room.level = Room.level + 1 '                               yes, increment game level
        Room.reallevel = Room.reallevel + 1 '                       increment game level counter
    End If
    Max% = 9 '                                                      maximum robot count (-2)
    If Room.level > 13 Then '                                       level 14 and beyond?
        Room.level = 14 '                                           yes, keep within limits
        Do '                                                        make random robot color
            c% = 0 '                                                reset color component counter
            RGBadd% = 0 '                                           reset color component adder
            Do
                c% = c% + 1 '                                       increment counter
                RGB%(c%) = Int(Rnd(1) * 3) '                        random between 0 and 2
                If RGB%(c%) = 1 Then RGB%(c%) = 191 '               dark color
                If RGB%(c%) = 2 Then RGB%(c%) = 255 '               bright color
                RGBadd% = RGBadd% + RGB%(c%) '                      add the colors up
            Loop Until c% = 3 '                                     cycle three times
        Loop Until RGBadd% '                                        make sure final result is not zero (black)
        Level(14).rcolor = _RGB32(RGB%(1), RGB%(2), RGB%(3)) '      random robot color
        Max% = 12 '                                                 three more robots! (muahahaha)
    End If
    _Dest Icon& '                                                   draw on icon image holder
    Cls , Level(Room.level).rcolor '                                clear with robot color
    _PutImage (0, 0), IconOtto& '                                   place large Evil Otto on icon image
    _Icon Icon& '                                                                  change window icon
    _Title "QBZERK64 - Level: " + Right$("00" + LTrim$(Str$(Room.reallevel)), 3) ' update window title
    Select Case Heading% '                                          which direction is player heading?
        Case NORTH '
            Pz% = 15 '                                              player will be in southern zone
            Otto.x = 122 '                                          evil otto x coordinate
            Otto.y = 189 '                                          evil otto y coordinate
        Case SOUTH
            Pz% = 12 '                                              player will be in northern zone
            Otto.x = 122
            Otto.y = 19
        Case EAST
            Pz% = 13 '                                              player will be in western zone
            Otto.x = 23
            Otto.y = 111
        Case WEST
            Pz% = 14 '                                              player will be in eastern zone
            Otto.x = 232
            Otto.y = 111
    End Select
    Otto.yoffset = 0 '                                              set evil otto attributes
    Otto.yvel = 7
    Otto.fcount = 0
    Otto.alive = FALSE
    Otto.cell = 1
    For c% = 1 To 15 '                                              cycle through all robots
        Robot(c%).alive = FALSE '                                   kill off all from previous maze
        Robot(c%).hit = FALSE '                                     remove exploding robots
    Next c%
    Room.robots = Int(Rnd(1) * Max%) + 3 '                          set room with random number of robots (3 to max)
    Otto.acount = Room.robots * 90 '                                3 seconds wait time for each robot
    For c% = 1 To Room.robots '                                     cycle through number of robots
        Do
            Do
                Rz% = Int(Rnd(1) * 15) + 1 '                        choose a random robot zone
            Loop Until Rz% <> Pz% '                                 make sure player is not already there
        Loop Until Not Robot(Rz%).alive '                           make sure a robot is not already there
        Robot(Rz%).alive = TRUE '                                   robot is now active
        Robot(Rz%).x = Robot(Rz%).zx + Int(Rnd(1) * 28) '           random x coordinate within cell
        Robot(Rz%).y = Robot(Rz%).zy + Int(Rnd(1) * 44) '           random y coordinate within cell
        Robot(Rz%).cell = 1 '                                       animation cell to standing still
        Robot(Rz%).dir = 1 '                                        facing right
        Robot(Rz%).xdir = 0 '                                       no horizontal movement
        Robot(Rz%).ydir = 0 '                                       no vertical movement
        Robot(Rz%).hit = FALSE '                                    robot has not hit anything
        Robot(Rz%).eye = 3 '                                        start with eye in middle
        Do
            Robot(Rz%).eyedir = Int(Rnd(1) * 2) - Int(Rnd(1) * 2) ' start eye moving in random direction
        Loop Until Robot(Rz%).eyedir <> 0 '                         make sure eye movement is not zero
        Robot(Rz%).ecount = 0 '                                     reset eye frame counter
        Robot(Rz%).fcount = Int(Rnd(1) * Room.robots) '             reset robot movement frame counter
        Robot(Rz%).bullets = 0 '                                    reset robot bullet counter
        Robot(Rz%).bcount = 0 '                                     reset robot bullet frame counter
        Robot(Rz%).xmode = Int(Rnd(1) * 2) '                        reset x travel mode
        Robot(Rz%).ymode = Int(Rnd(1) * 2) '                        reset y travel mode
        Robot(Rz%).xmcount = Int(Rnd(1) * 150) + 150 '              reset x travel mode counter
        Robot(Rz%).ymcount = Int(Rnd(1) * 150) + 150 '              reset y travel mode counter
        Robot(Rz%).distance = Int(Rnd(1) * 75) + 25 '               reset distance to track player
    Next c%
    _Dest Cdest& '                                                  return to calling destination

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            DRAWPLAYER
Sub DRAWPLAYER (Mode%)

    '**
    '** Draws and animates player on screen
    '**
    '** Mode%: NORMAL(0)        - draw player running around
    '**        TRANSITIONING(1) - draw player transitioning from one maze room to another
    '**        ZAPPED(2)        - draw player in flashing death sequence
    '**        FIRING(3)        - draw player in firing sequence
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared Room As ROOM '        ARRAY: room variables
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared Pimage&() '           IMAGE: player images
    Shared Pmask&() '            IMAGE: mask for edge detection
    Shared PmaskTest& '          IMAGE: mask area to test for player edge detection
    Shared Flash&() '            IMAGE: player flashing when hit
    Shared FlashMask& '          IMAGE: player flashing mask
    Shared GotTheHumanoid& '     SOUND: got the humanoid, got the intruder
    Shared Ctaunt& '             SOUND: current taunt playing
    Shared IntruderAlert& '      SOUND: intruder alert, intruder alert

    Dim Bounce% '                BOOL : true if bounce added to player's step
    Dim Cdest& '                        calling destination
    Dim x%, y% '                        counters to cycle through mask image

    Cdest& = _Dest '                                                                           remember calling destination
    If Mode% = ZAPPED Then '                                                                   player currently flashing?
        If Player.zcount Then '                                                                yes, value in zap counter?
            Player.zcount = Player.zcount - 1 '                                                yes, decrement zap counter
            Player.cell = Player.cell + 1 '                                                    increment flash animation cell
            If Player.cell = 5 Then Player.cell = 1 '                                          keep cell within limits
            Player.zcolor = Player.zcolor + 1 '                                                increment hit color
            If Player.zcolor = 14 Then Player.zcolor = 1 '                                     keep color within limits
            _Dest FlashMask& '                                                                 draw on flash mask
            Cls , Level(Player.zcolor).rcolor '                                                clear mask with robot color
            _PutImage (0, 0), Flash&(Player.cell) '                                            place flash image on mask
            _ClearColor _RGB32(0, 0, 0), FlashMask& '                                          black will be transparent
            _PutImage (Player.x, Player.y - 1), FlashMask&, Cdest& '                           place mask on work room
        Else '                                                                                 no, player finished flashing
            Player.alive = FALSE '                                                             player is now dead
            Player.lives = Player.lives - 1 '                                                  player loses a life
            Player.mode = NORMAL '                                                             set player mode back to normal
        End If
    Else
        If Mode% <> FIRING Then '                                                              is player firing?
            If Player.fix Then Player.fix = Player.fix - 1 '                                   decrement no foot shoot
            If Player.ydir = 0 And Player.xdir = 0 Then '                                      no, is player standing still?
                Player.cell = 1 '                                                              yes, standing animation cell
            Else '                                                                             nope, player is moving
                If Mode% = NORMAL Then '                                                       normal playing mode?
                    If Player.xdir Then Player.dir = Player.xdir '                             yes, set cell direction
                    Player.x = Player.x + Player.xdir '                                        move player horizontally
                    Player.y = Player.y + Player.ydir '                                        move player vertically
                End If
                If Player.fix = 0 Then '                                                       will player shoot foot?
                    Player.cell = Player.cell + 1 '                                            no, move to next animation cell
                    If Player.cell > 4 Then Player.cell = 2 '                                  repeat animation cells
                    If Player.cell = 3 Then Bounce% = TRUE '                                   add a bounce to player's step
                End If
            End If
        End If
        If Not Setting.iddqd Then '                                                            in god mode?
            _Source PmaskTest& '                                                               no, set image source
            _Dest PmaskTest& '                                                                         set image destination
            _PutImage (0, 0), Cdest&, PmaskTest&, (Player.x, Player.y)-(Player.x + 7, Player.y + 15) ' get player area from screen
            _PutImage (0, 0), Pmask&(Player.cell, Player.dir) '                                        place mask over top of image
            x% = -1 '                                                                          reset x mask location
            Do '                                                                               cycle horiz through mask
                x% = x% + 1 '                                                                  increment x mask location
                y% = -1 '                                                                      reset y mask location
                Do '                                                                           cycle vert through mask
                    y% = y% + 1 '                                                              increment y mask location
                    If Point(x%, y%) <> _RGB32(0, 0, 0) Then '                                 did player hit something?
                        Player.zcolor = 1 '                                                    start hit color at 1
                        Player.cell = 1 '                                                      start flash cell at 1
                        Player.mode = ZAPPED '                                                 set player's mode to zapping
                        Player.zcount = 75 '                                                   set zap countdown timer
                        If _SndPlaying(Ctaunt&) Then _SndStop Ctaunt& '                        stop any taunt playing
                        If _SndPlaying(IntruderAlert&) Then _SndStop IntruderAlert& '          stop intruder alert
                        _SndPlay GotTheHumanoid& '                                             let the robots gloat
                    End If
                Loop Until y% = 15 Or Player.mode = ZAPPED '                                   leave at bottom of mask
            Loop Until x% = 7 Or Player.mode = ZAPPED '                                        leave at right side of mask
        End If
        _Source Cdest& '                                                                       set source back to calling
        _Dest Cdest& '                                                                         set destination back to calling
        If Not Room.blink Then '                                                               room in blink delay?
            _PutImage (Player.x, Player.y + Bounce%), Pimage&(Player.cell, Player.dir) '       no, put player image on screen
        End If
        x% = Player.x - 5 '                                                                    reset green border x location
        Do '                                                                                   cycle horiz through green border
            x% = x% + 1 '                                                                      increment x border location
            y% = Player.y - 5 '                                                                reset green border y location
            Do '                                                                               cycle vert through green border
                y% = y% + 1 '                                                                  increment y border location
                If Point(x%, y%) <> _RGB32(0, 0, 0) Then PSet (x%, y%), _RGB32(0, 255, 0) '    if pixel here paint it green
            Loop Until y% = Player.y + 19 '                                                    leave at bottom of border
        Loop Until x% = Player.x + 11 '                                                        leave at right side of border
    End If
    _Dest Cdest&

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            MOVEPLAYER
Sub MOVEPLAYER (Dir%)

    '**
    '** Sets direction of player movement
    '**
    '** Dir%: Go NORTH(0), SOUTH(1), EAST(2) or WEST(3)
    '**

    Shared Player As PLAYER ' ARRAY: player variables
    Shared Cheat$ '                  what is this for?

    Select Case Dir% '                               which direction has player selected?
        Case NORTH '                                 north (0)
            Player.ydir = -1 '                       set vertical direction up
        Case SOUTH '                                 south (1)
            Player.ydir = 1 '                        set vertical direction down
        Case EAST '                                  east (2)
            Player.xdir = 1 '                        set horizontal direction right
        Case WEST '                                  west (3)
            Player.xdir = -1 '                       set horizontal direction left
    End Select
    If Player.xdir Or Player.ydir Then Cheat$ = "" ' if player moves then empty this string

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                          UPDATEPLAYER
Sub UPDATEPLAYER ()

    '**
    '** Reacts to player input.
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Room As ROOM '        ARRAY: room variables
    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared Pshoot& '             SOUND: player shooting
    Shared Cheat$ '                     what is this for?

    Dim c% '                            bullet array index counter
    Dim k$ '                            any key player presses

    If _KeyDown(27) Then CLEANUP '                                 if ESC pressed then leave game
    If _Exit Then CLEANUP '                                        leave if player uses X to close window
    If Room.delay Then '                                           delay and blink player?
        Room.delay = Room.delay - 1 '                              yes, decrement room delay counter
        If Room.delay Mod 5 = 0 Then Room.blink = Not Room.blink ' flip state of blinking player
        Exit Sub '                                                 leave
    End If
    If Player.mode = ZAPPED Then Exit Sub '                        if player flashing the leave
    k$ = InKey$ '                                                  get any non-control key pressed
    If k$ <> "" Then Cheat$ = Cheat$ + UCase$(k$) '                add to game test string
    If Cheat$ = "IDDQD" Then '                                     full cheat code entered?
        Cheat$ = "" '                                              yes, clear cheat code
        Setting.iddqd = Not Setting.iddqd '                        flip cheat mode
        Setting.god = TRUE '                                       remember that player cheated
        Setting.eye = 0 '                                          reset glowing eye color
        Setting.eyedir = 10 '                                      reset glowing eye color direction
    End If
    Player.xdir = 0 '                                              set no horizontal direction
    Player.ydir = 0 '                                              set no vertical direction
    Player.mode = NORMAL '                                         set player to normal
    If _KeyDown(18432) Then MOVEPLAYER NORTH '                     if UP ARROW key pressed set direction
    If _KeyDown(20480) Then MOVEPLAYER SOUTH '                     if DOWN ARROW key pressed set direction
    If _KeyDown(19712) Then MOVEPLAYER EAST '                      if RIGHT ARROW key pressed set direction
    If _KeyDown(19200) Then MOVEPLAYER WEST '                      if LEFT ARROW key pressed set direction
    If _KeyDown(100306) Then '                                     player pressing LEFT CTRL key?
        Cheat$ = "" '                                              empty this string
        Player.mode = FIRING '                                     player now in firing mode
        If Player.xdir Or Player.ydir Then '                       yes, are arrow keys also pressed?
            If Player.bullets < 2 Then '                           yes, are max number of player bullets flying?
                If Player.bcount = 0 Then '                        no, is it time for another player bullet?
                    c% = 8 '                                       yes, reset bullet array counter (always top 2)
                    Do '                                           cycle through bullets
                        c% = c% + 1 '                              increment array counter
                    Loop Until Not Bullet(c%).alive '              leave when inactive bullet found
                    If Player.xdir Then '                          is player facing right/left?
                        Player.dir = Player.xdir '                 yes, set player direction
                        If Player.xdir = -1 Then '                 player facing WEST?
                            Bullet(c%).x = Player.x '              yes, set bullet x coordinate
                        Else '                                     no, player facing EAST
                            Bullet(c%).x = Player.x + 7 '          set bullet x coordinate
                        End If
                        Select Case Player.ydir '                  which vertical direction is player shooting?
                            Case -1 '                              shooting UP
                                Player.cell = 6 '                  pointing up and right/left animation
                                Bullet(c%).y = Player.y + 1 '      set y coordinate of bullet
                            Case 0 '                               shooting RIGHT/LEFT
                                Player.cell = 7 '                  pointing right/left animation
                                Bullet(c%).y = Player.y + 3 '      set y coordinate of bullet
                            Case 1 '                               shooting DOWN
                                Player.cell = 8 '                  pointing down and right/left animation
                                Bullet(c%).y = Player.y + 6 '      set y coordinate of bullet
                        End Select
                    Else '                                         no, player is facing up/down
                        Player.dir = 1 '                           face player EAST
                        If Player.ydir = -1 Then '                 is player facing NORTH?
                            Player.cell = 5 '                      yes, pointing up animation
                            Bullet(c%).x = Player.x + 7 '          set bullet x coordinate
                            Bullet(c%).y = Player.y + 3 '          set bullet y coordinate
                        Else '                                     no, player is facing SOUTH
                            Player.cell = 9 '                      pointing down animation
                            Bullet(c%).x = Player.x + 6 '          set bullet x coordinate
                            Bullet(c%).y = Player.y + 7 '          set bullet y coordinate
                            Player.fix = 3 '                       don't allow player to shoot foot!
                        End If
                    End If
                    Bullet(c%).xdir = Player.xdir * 6 '           set x direction of bullet
                    Bullet(c%).ydir = Player.ydir * 6 '           set y direction of bullet
                    Bullet(c%).who = 0 '                          set as player shot this bullet
                    Bullet(c%).alive = TRUE '                     make this bullet active
                    Player.bullets = Player.bullets + 1 '         increment player shot count
                    Player.bcount = 15 '                          wait 1/2 second until next shot allowed
                    _SndPlay Pshoot& '                            player shooting sound
                End If
            End If
        End If
        Player.xdir = 0 '                                         stop player x movement
        Player.ydir = 0 '                                         stop player y movement
    End If

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                           GETINITIALS
Function GETINITIALS$ ()

    '**
    '** Get's player's intials when a high score has been achieved. The function will time out and leave after 10 seconds
    '** of inactivity.
    '**

    Shared WorkRoom& ' IMAGE: main game screen where action takes place

    Dim x% '                  x location of each letter
    Dim i$ '                  initials entered by player
    Dim l% '                  letter position in font array
    Dim t% '                  timeout timer
    Dim k$ '                  any key the player presses (via INKEY$)
    Dim Ctrl% '        BOOL : true when player has released Left CTRL key (latch)
    Dim Khit& '               value of key being pressed (via _KEYHIT)

    _Dest WorkRoom& '                                                       draw on work room
    Cls '                                                                   clear screen
    DRAWTEXT 40, 16, "Congratulations Player", _RGB32(255, 255, 0) '        show text to player
    DRAWTEXT 12, 48, "You have joined the immortals", _RGB32(0, 255, 255)
    DRAWTEXT 16, 64, "in the QBZERK64 hall of fame", _RGB32(0, 255, 255)
    DRAWTEXT 52, 96, "Enter your initials", _RGB32(0, 255, 255)
    DRAWTEXT 8, 144, "LEFT or RIGHT to change letter", _RGB32(0, 255, 0)
    DRAWTEXT 20, 160, "then press FIRE to store it", _RGB32(0, 255, 0)
    Line (116, 123)-(122, 123), _RGB32(255, 255, 255) '                     draw the 3 underlines
    Line (124, 123)-(130, 123), _RGB32(255, 255, 255)
    Line (132, 123)-(138, 123), _RGB32(255, 255, 255)
    x% = 116 '                                                              set x location of first letter
    l% = 11 '                                                               start with letter A in font array
    Ctrl% = TRUE '                                                          LEFT CTRL key is released
    Do '                                                                    clear keyhit buffer
        Khit& = _KeyHit '                                                   get key from buffer
    Loop Until Khit& = 0 '                                                  leave when keyboard buffer empty
    Do '                                                                    clear inkey buffer
    Loop Until InKey$ = "" '                                                leave when inkey buffer empty
    Do '                                                                    get intitals loop
        Do '                                                                time-out loop
            _Limit 30 '                                                     limit to 30 loops per second (for timing)
            _Dest WorkRoom& '                                               set destination to game screen
            Line (x%, 112)-(x% + 7, 121), _RGB32(0, 0, 0), BF '             remove previous letter
            DRAWTEXT x%, 112, Chr$(l% + 54), _RGB32(255, 255, 255) '        draw letter
            t% = t% + 1 '                                                   increment timer
            If t% = 300 Then Exit Do '                                      leave if 10 seconds reached
            k$ = InKey$ '                                                   get any key player presses
            Select Case k$ '                                                which key was pressed?
                Case Chr$(0) + "K" '                                        LEFT ARROW key
                    l% = l% - 1 '                                           decrement letter position
                    If l% < 11 Then l% = 36 '                               keep within limits
                    t% = 0 '                                                reset timer
                Case Chr$(0) + "M" '                                        RIGHT ARROW key
                    l% = l% + 1 '                                           increment letter position
                    If l% > 36 Then l% = 11 '                               keep within limits
                    t% = 0 '                                                reset timer
            End Select
            Khit& = _KeyHit '                                               get keys INKEY$ can't see
            If (Khit& = 100306) And Ctrl% Then '                            LEFT CTRL key and previously released?
                Ctrl% = FALSE '                                             yes, remember that key is pressed
                x% = x% + 8 '                                               move to next letter position
                t% = 0 '                                                    reset timer
                i$ = i$ + Chr$(l% + 54) '                                   add letter to intital string
                Exit Do '                                                   leave loop
            End If
            If Khit& = -100306 Then Ctrl% = TRUE '                          remember that LEFT CTRL key was released
            _Dest 0 '                                                       set destination to main screen
            _PutImage , WorkRoom& '                                         stretch game screen onto main screen
            _Display '                                                      update screen with changes
        Loop '                                                              never stop looping
    Loop Until Len(i$) = 3 Or t% = 300 '                                    leave when timer reached or letters entered
    GETINITIALS$ = i$ '                                                     pass initials back

End Function

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            HIGHSCORES
Sub HIGHSCORES (Mode%)

    '**
    '** Maintains the high score table. Only the 5 highest scores are maintained between game executions. This allows for
    '** everyone to get into the high score table every time they play and feel like an immortal. :)
    '**
    '** Mode%: LOAD(0) - Loads the high score table from file.
    '**        SAVE(1) - Saves the high score table to file. If player's score is greater than any in the high score table
    '**                  the new player's information is inserted into the high score table.
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared High() As HIGH '      ARRAY: top ten high scores
    Shared Setting As SETTINGS ' ARRAY: game option settings

    Dim c% '                            score line counter

    Select Case Mode% '                                       which mode was selected?
        Case LOAD '                                           load high score table
            If _FileExists("QBzerk.sav") Then '               does high score file exist?
                Open "QBzerk.sav" For Input As #1 '           yes, open high score file for reading
                For c% = 1 To 5 '                             cycle through first 5 high scores
                    Line Input #1, High(c%).n '               get player name
                    Input #1, High(c%).s '                    get player score
                Next c%
            Else '                                            no, it needs created
                Open "QBzerk.sav" For Output As #1 '          open high score file for writing
                High(1).n = "TWR" '                           default high score player's initials (author)
                High(1).s = 1000 '                            default high score
                High(2).n = "GAL" '                           default high score player's initials (Galleon)
                High(2).s = 900 '                             default high score
                High(3).n = "SMC" '                           default high score player's initials (SMcNeill)
                High(3).s = 800 '                             default high score
                High(4).n = "CLP" '                           default high score player's initials (Clippy)
                High(4).s = 700 '                             default high score
                High(5).n = "OLD" '                           default high score player's initials (OldDos)
                High(5).s = 900 '                             default high score
                Print #1, High(1).n '                         save author's name
                Print #1, High(1).s '                         save author's score
                Print #1, High(2).n '                         save creator's name
                Print #1, High(2).s '                         save creator's score
                Print #1, High(3).n '                         save player's name
                Print #1, High(3).s '                         save player's score
                Print #1, High(4).n '                         save player's name
                Print #1, High(4).s '                         save player's score
                Print #1, High(5).n '                         save player's name
                Print #1, High(5).s '                         save player's score
            End If
            Close #1 '                                        close high score file
        Case SAVE '                                           save high score table (if necessary)
            If Not Setting.god Then '                         did player use god mode?
                If Player.score > High(10).s Then '           no, is player score greater than lowest high score?
                    High(10).s = Player.score '               yes, replace lowest score with player score
                    High(10).n = GETINITIALS$ '               replace lowest name with player name
                    For c% = 9 To 1 Step -1 '                 cycle through remaining score lines (bubble sort)
                        If High(c% + 1).s > High(c%).s Then ' is lower score greater than this one?
                            Swap High(c%).s, High(c% + 1).s ' yes, swap score values (bubble up)
                            Swap High(c%).n, High(c% + 1).n ' swap player name values (bubble up)
                        End If
                    Next c%
                    Open "QBzerk.sav" For Output As #1 '      open high score file for writing
                    For c% = 1 To 5 '                         cycle through first 5 high scores
                        Print #1, High(c%).n '                save this line's name
                        Print #1, High(c%).s '                save this line's score
                    Next c%
                    Close #1 '                                close high score file
                End If
            End If
    End Select

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                           UPDATESCORE
Sub UPDATESCORE ()

    '**
    '** Updates the player's score and lives left on the game screen.
    '**

    Shared Player As PLAYER '    ARRAY: player variables
    Shared Room As ROOM '        ARRAY: room variables
    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Life& '               IMAGE: extra life indicator (little stick guy)
    Shared Otto&() '             IMAGE: Evil Otto!
    Shared OttoMask& '           IMAGE: evil otto mask
    Shared Extra& '              SOUND: extra life sound

    Dim c% '                            generic counter
    Dim b$ '                            bonus amount in string
    Dim s$ '                            score amount in string
    Dim Cdest& '                        calling routine destination

    Cdest& = _Dest '                                                 remeber calling destination
    If Player.score >= 5000 And Player.awarded = 0 Then '            time to award extra life at 5000?
        If Setting.extra = 1 Or Setting.extra = 3 Then '             yes, do settings allow this?
            Player.awarded = 1 '                                     yes, remember that 5000 life awarded
            Player.lives = Player.lives + 1 '                        give player an extra life
            _SndPlay Extra& '                                        notify player that extra life awarded
        End If
    ElseIf Player.score >= 10000 And Player.awarded < 2 Then '       time to award extra life at 10000?
        If Setting.extra > 1 Then '                                  yes, do settings allow this?
            Player.awarded = 2 '                                     yes, remember that 10000 life awarded
            Player.lives = Player.lives + 1 '                        give player an extra life
            _SndPlay Extra& '                                        notify player that extra life awarded
        End If
    End If
    s$ = LTrim$(Str$(Player.score)) '                                convert score to string
    DRAWTEXT 49 - Len(s$) * 8, 212, s$, _RGB32(0, 255, 0) '          display score on screen
    For c% = 1 To Player.lives - 1 '                                 cycle through lives left
        _PutImage (58 + (c% - 1) * 8, 212), Life& '                  display life indicator for each
    Next c%
    If Room.bonus Then '                                             bonus value?
        b$ = LTrim$(Str$(Room.bonus)) '                              yes, convert bonus to string
        DRAWTEXT 97, 212, "BONUS", _RGB32(255, 255, 255) '           display BONUS on screen
        DRAWTEXT 169 - Len(b$) * 8, 212, b$, _RGB32(255, 255, 255) ' display bonus amount on screen
    End If
    If Setting.iddqd Then '                                          god mode?
        _Dest OttoMask& '                                            yes, draw on otto mask
        Cls , Level(Room.level).rcolor '                             clear mask to robot color
        _PutImage (0, 0), Otto&(5), OttoMask& '                      place otto animation cell on mask
        _ClearColor _RGB32(0, 0, 0), OttoMask& '                     make black transparent
        _Dest Cdest& '                                               return to calling destination
        _PutImage (179, 213), OttoMask& '                            place otto onto work room
        Setting.eye = Setting.eye + Setting.eyedir '                 increase eye color
        If Setting.eye > 255 Then '                                  eye color too much?
            Setting.eyedir = -Setting.eyedir '                       yes, reverse eye color direction
            Setting.eye = 255 '                                      keep color within limit
        End If
        If Setting.eye < 0 Then '                                    eye color too little?
            Setting.eyedir = -Setting.eyedir '                       yes, reverse eye color direction
            Setting.eye = 0 '                                        keep color within limit
        End If
        PSet (181, 215), _RGB32(Setting.eye, 0, 0) '                 make glowing eyes
        PSet (184, 215), _RGB32(Setting.eye, 0, 0)
    End If

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                              DRAWTEXT
Sub DRAWTEXT (x%, y%, t$, c~&)

    '**
    '** Draws text on the screen at a given location and color.
    '**
    '** x%, y% - upper left hand corner of text
    '** t$     - the text to display
    '** c~&    - the color of the text
    '**
    '** Note: only works for characters 0 - 9, A - Z, a - z and space
    '**

    Shared Font&() ' IMAGE: game font

    Dim temp& '      IMAGE: temporary image used to draw text
    Dim l% '                count through letters in text
    Dim a% '                ASCII valueof each letter in text
    Dim Cdest& '            calling routine destination

    Cdest& = _Dest '                                                                 remember original destination
    temp& = _NewImage(Len(t$) * 8, 12, 32) '                                         create temporary image holder
    _Dest temp& '                                                                    draw on temporary image
    Cls , c~& '                                                                      clear image with text color
    For l% = 1 To Len(t$) '                                                          cycle through text string
        a% = Asc(Mid$(t$, l%, 1)) '                                                  get ASCII value of letter
        Select Case a% '                                                             what is ASCII value?
            Case 32 '                                                                space
                a% = 0 '                                                             remember that a space was here
                Line ((l% - 1) * 8, 0)-((l% - 1) * 8 + 7, 11), _RGB32(0, 0, 0), BF ' draw blank box for space
            Case 48 To 57 '                                                          0 through 9
                a% = a% - 47 '                                                       set to location in font images
            Case 65 To 90 '                                                          A through Z
                a% = a% - 54 '                                                       set to location in font images
            Case 97 To 122 '                                                         a through z
                a% = a% - 60 '                                                       set to location in font images
        End Select
        If a% <> 0 Then _PutImage ((l% - 1) * 8, 0), Font&(a%) '                     draw letter if not a space
    Next l%
    _ClearColor _RGB32(0, 0, 0) '                                                    set black as transparency color
    _Dest Cdest& '                                                                   go back to original destination
    _PutImage (x%, y%), temp& '                                                      place text image on destination
    _FreeImage temp& '                                                               temporary image no longer needed

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                    CHECKFORTRANSITION
Sub CHECKFORTRANSITION ()

    '**
    '** Checks player position for transition into a new maze.
    '**

    Shared Player As PLAYER ' ARRAY: player variables

    If Player.x = 4 Then TRANSITION WEST '    go west if player leaves
    If Player.x = 244 Then TRANSITION EAST '  go east if player leaves
    If Player.y = 0 Then TRANSITION NORTH '   go north if player leaves
    If Player.y = 192 Then TRANSITION SOUTH ' go south if player leaves

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            TRANSITION
Sub TRANSITION (Heading%)

    '**
    '** Scrolls from one maze room to the next based on the direction passed in.
    '**
    '** Heading% - the direction to scroll to: NORTH(0), SOUTH(1), EAST(2), WEST(3)
    '**
    '** Note: This scrolling sequence differs from the original Berzerk game.
    '**       - The original scrolled the current maze away and then displayed the new maze at once.
    '**         - This version shows the new maze scrolling in while the old scrolls out.
    '**         - The doorway the player passed through closes off as the mazes scroll by.
    '**         - The player continues to run to the new start position as the mazes scroll by.
    '**       - The original would pause after the new maze is displayed, giving the player time to view the new maze and
    '**         position of robot enemies.
    '**         - This version has no pause since the new maze and robot enemies appear already in place.
    '**
    '** I played Berzerk heavily as a kid in the arcades. The above transitioning changes are things I always wished the
    '** original did. Now that I'm a programmer: wish granted!
    '**

    Shared Room As ROOM '        ARRAY: room variables
    Shared Player As PLAYER '    ARRAY: player variables
    Shared Bullet() As BULLETS ' ARRAY: bullet variables
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Otto As OTTO '        ARRAY: evil otto properties
    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared Maze& '               IMAGE: level maze
    Shared WorkRoom& '           IMAGE: main game screen where action takes place
    Shared MustNotEscape&() '    SOUND: the %noun% must not escape sequences
    Shared FightLikeRobot&() '   SOUND: fight like a robot sequences
    Shared Ctaunt& '             SOUND: current taunt playing
    Shared IntruderAlert& '      SOUND: intruder alert, intruder alert

    Dim ThisRoom& '              IMAGE: temporary current game screen
    Dim ScrollRoom& '            IMAGE: temporary scrolling maze image
    Dim m% '                            movement counter
    Dim Move% '                         number of pixels to scroll
    Dim Cdest& '                        calling routine destination
    Dim t% '                            player transitioning counter

    Cdest& = _Dest '                                                        get calling destination
    ThisRoom& = _CopyImage(WorkRoom&) '                                     get current game screen condition
    If _SndPlaying(Ctaunt&) Then _SndStop Ctaunt& '                         stop taunt if it is playing
    If _SndPlaying(IntruderAlert&) Then _SndStop IntruderAlert& '           stop alert if it is playing
    If Setting.iddqd Then Player.chicken = TRUE '                           player always chicken in god mode
    If Room.killed <> Room.robots Then '                                    have all robots been killed?
        _SndPlay FightLikeRobot&(Int(Rnd(1) * 3) + 1) '                     no, call user a chicken
        Player.chicken = TRUE '                                             player now officially a chicken
        Player.ccount = 0 '                                                 reset chicken counter
        Room.bonus = 0 '                                                    no room bonus for player
    Else '                                                                                          yes, all robots killed
        _SndPlay MustNotEscape&(Int(Rnd(1) * (2 + Abs(Player.chicken))) + 1, Int(Rnd(1) * 3) + 1) ' warn robots
        Room.bonus = Room.robots * 10 '                                                             calculate room bonus
        If Not Otto.alive Then Room.bonus = Room.bonus + 50 '               add no otto score to bonus
        Player.score = Player.score + Room.bonus '                          add bonus to player score
        Player.ccount = Player.ccount + 1 '                                 increment chicken counter
        If Player.ccount > 1 Then Player.chicken = FALSE '                  player no longer a chicken
    End If
    Room.killed = 0 '                                                       reset room kill count
    Room.bullets = 0 '                                                      remove bullets from room
    For t% = 1 To 10 '                                                      cycle through bullet array
        Bullet(t%).alive = FALSE '                                          kill off any flying bullets
    Next t%
    Player.bullets = 0 '                                                    reset player bullet counter
    If Heading% < EAST Then '                                               heading NORTH or SOUTH?
        t% = 20 '                                                           set number of player transition steps
        Move% = 203 '                                                       yes, set vertical pixel movement
        ScrollRoom& = _NewImage(248, 412, 32) '                             create scrolling image
    Else '                                                                  no, heading EAST or WEST
        t% = 16 '                                                           set number of player transition steps
        Move% = 243 '                                                       set horizontal pixel movement
        ScrollRoom& = _NewImage(492, 208, 32) '                             create scrolling image
    End If
    _Dest Maze& '                                                           draw on maze image
    DRAWROBOTS '                                                            draw last position of remaining robots
    _Dest Cdest& '                                                          return to calling destination
    GENERATEROBOTS Heading% '                                               generate a new set of robots
    Select Case Heading% '                                                  which direction is player heading?
        Case NORTH '                                                        NORTH
            _PutImage (0, 204), Maze&, ScrollRoom&, (4, 0)-(251, 207) '     put current maze on scrolling maze
            MAKEMAZE NORTH '                                                create next game screen to the NORTH
            DRAWROBOTS '                                                    draw robots onto work screen
            _PutImage (0, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '   put new maze on scrolling maze
        Case SOUTH '                                                        SOUTH
            _PutImage (0, 0), Maze&, ScrollRoom&, (4, 0)-(251, 207) '       put current maze on scrolling maze
            MAKEMAZE SOUTH '                                                create next game screen to the SOUTH
            DRAWROBOTS '                                                    draw robots onto work screen
            _PutImage (0, 204), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) ' put new maze on scrolling maze
        Case EAST '                                                         EAST
            _PutImage (0, 0), Maze&, ScrollRoom&, (4, 0)-(251, 207) '       put current maze on scrolling maze
            MAKEMAZE EAST '                                                 create next game screen to the EAST
            DRAWROBOTS '                                                    draw robots onto work screen
            _PutImage (244, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) ' put new maze on scrolling maze
        Case WEST '                                                         WEST
            _PutImage (244, 0), Maze&, ScrollRoom&, (4, 0)-(251, 207) '     put current maze on scrolling maze
            MAKEMAZE WEST '                                                 create next game screen to the WEST
            DRAWROBOTS '                                                    draw robots onto work screen
            _PutImage (0, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '   put new maze on scroling maze
    End Select
    m% = -1 '                                                               reset movement counter
    Do '                                                                    cycle through transition
        _Limit 60 '                                                         limit to 60 frames per second
        m% = m% + 1 '                                                       increment movement counter
        _Dest ThisRoom& '                                                   work on temporary game screen
        Select Case Heading% '                                              Which direction is player heading?
            Case NORTH '                                                                        NORTH
                _PutImage (4, 0), ScrollRoom&, ThisRoom&, (0, 204 - m%)-(247, 204 - m% + 207) ' scroll maze down
            Case SOUTH '                                                                        SOUTH
                _PutImage (4, 0), ScrollRoom&, ThisRoom&, (0, m%)-(247, m% + 207) '             scroll maze up
            Case EAST '                                                                         EAST
                _PutImage (4, 0), ScrollRoom&, ThisRoom&, (m%, 0)-(m% + 247, 207) '             scroll maze left
            Case WEST '                                                                         WEST
                _PutImage (4, 0), ScrollRoom&, ThisRoom&, (244 - m%, 0)-(244 - m% + 247, 207) ' scroll maze right
        End Select
        Select Case m% '                                                                      value of movement counter
            Case Is < t% '                                                                    player still transitioning?
                DRAWPLAYER TRANSITIONING '                                                    yes, animate transitioning player
            Case t% '                                                                         player done transitioning?
                Player.xdir = 0 '                                                             yes, stop player's y direction
                Player.ydir = 0 '                                                             stop player's x direction
                Select Case Heading% '                                                        which direction did player transition?
                    Case NORTH '                                                              player went north
                        Player.y = 182 '                                                      player now at bottom of new maze
                        _Dest WorkRoom& '                                                     draw on work screen
                        DRAWPLAYER NORMAL '                                                   draw the player one last time
                        _PutImage (0, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '         update scrolling maze image
                    Case SOUTH '                                                              player went south
                        Player.y = 10 '                                                       player now at top of new maze
                        _Dest WorkRoom& '                                                     draw on work screen
                        DRAWPLAYER NORMAL '                                                   draw player one last time
                        _PutImage (0, 204), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '       update scrolling maze image
                    Case EAST '                                                               player went east
                        Player.x = 12 '                                                       player now on left of new maze
                        _Dest WorkRoom& '                                                     draw on work screen
                        DRAWPLAYER NORMAL '                                                   draw player one last time
                        _PutImage (244, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '       update scrolling maze image
                    Case WEST '                                                               player went west
                        Player.x = 236 '                                                      player now on right of new maze
                        _Dest WorkRoom& '                                                     draw on work screen
                        DRAWPLAYER NORMAL '                                                   draw player one last time
                        _PutImage (0, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '         update scrolling maze image
                End Select
            Case 32 To 64 '                                                                   shut doors?
                _Dest WorkRoom& '                                                             yes, work on game screen
                Select Case Heading% '                                                        direction of player?
                    Case NORTH '                                                              NORTH
                        Line (104, 205)-(104 + m% - 32, 206), Level(Room.level).rcolor, B '   draw left sliding door
                        Line (151, 206)-(151 - (m% - 32), 205), Level(Room.level).rcolor, B ' draw right sliding door
                        _PutImage (0, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '         update scrolling maze image
                    Case SOUTH '                                                              SOUTH
                        Line (104, 1)-(104 + m% - 32, 2), Level(Room.level).rcolor, B '       draw left sliding door
                        Line (151, 2)-(151 - (m% - 32), 1), Level(Room.level).rcolor, B '     draw right sliding door
                        _PutImage (0, 204), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '       update scrolling maze image
                    Case EAST '                                                               EAST
                        Line (5, 72)-(6, 72 + m% - 32), Level(Room.level).rcolor, B '         draw top sliding door
                        Line (6, 135)-(5, 135 - (m% - 32)), Level(Room.level).rcolor, B '     draw bottom sliding door
                        _PutImage (244, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '       update scrolling maze image
                    Case WEST '                                                               WEST
                        Line (249, 72)-(250, 72 + m% - 32), Level(Room.level).rcolor, B '     draw top sliding door
                        Line (250, 135)-(249, 135 - (m% - 32)), Level(Room.level).rcolor, B ' draw bottom sliding door
                        _PutImage (0, 0), WorkRoom&, ScrollRoom&, (4, 0)-(251, 207) '         update scrolling maze image
                End Select
        End Select
        _Dest ThisRoom& '                                             work on this room
        UPDATESCORE '                                                 put score on screen
        _Dest 0 '                                                     work on view screen
        _PutImage , ThisRoom& '                                       stretch temporary image to view screen
        _Display '                                                    update view screen with changes
    Loop Until m% >= Move% '                                          leave when transition complete
    Room.bonus = 0 '                                                  remove bonus value
    _Dest Maze& '                                                     draw on maze screen
    Select Case Heading% '                                            which direction did player transition?
        Case NORTH '                                                  player went north
            Line (104, 205)-(151, 206), Level(Room.level).rcolor, B ' draw closed door
        Case SOUTH '                                                  player went south
            Line (104, 1)-(151, 2), Level(Room.level).rcolor, B '     draw closed door
        Case EAST '                                                   player went east
            Line (5, 72)-(6, 135), Level(Room.level).rcolor, B '      draw closed door
        Case WEST '                                                   player went west
            Line (249, 72)-(250, 135), Level(Room.level).rcolor, B '  draw closed door
    End Select
    _FreeImage ThisRoom& '                                            temporary image no longer needed
    _FreeImage ScrollRoom& '                                          scrolling maze image no longer needed
    _Dest Cdest& '                                                    return to calling destination

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                              MAKEMAZE
Sub MAKEMAZE (Heading%)

    '**
    '** Creates a new maze room based on the current room's X,Y location in a 256x256 play field. This subroutine creates
    '** rooms in the exact same way as the original arcade Berzerk does. For more information go to the URL below.
    '**
    '** http://www.robotron2084guidebook.com/home/games/berzerk/mazegenerator/code/
    '**
    '** Note: There are a total of 65,536 mazes that can be created (256 x 256).
    '**

    Shared Room As ROOM '   ARRAY: room variables
    Shared P() As PILLARS ' ARRAY: maze pillar locations
    Shared WorkRoom& '      IMAGE: main game screen where action takes place
    Shared BlankRoom& '     IMAGE: room with blank maze (outer maze walls only)
    Shared QBzerk64s& '     IMAGE: colorful QBzerk64 logo
    Shared Maze& '          IMAGE: level maze

    Dim Direction~% '              direction (NSEW) of each maze pillar
    Dim p% '                       pillar counter
    Dim Add% '                     pillars 2/3 and 6/7 are spaced 48 apart instead of 44
    Dim Cdest& '                   calling destination

    Cdest& = _Dest '                                          remember calling destination
    Select Case Heading% '                                    which direction is player heading?
        Case AFTERLIFE '                                      facing EAST, player lost a life
            Room.x = Int(Rnd(1) * 256) '                      random room x coordinate
            Room.y = Int(Rnd(1) * 256) '                      random room y coordinate
        Case BEGIN '                                          facing EAST, start of game
            Room.x = 49 '                                     starting room x location
            Room.y = 83 '                                     starting room y location
        Case NORTH '                                          NORTH
            Room.y = Room.y - 1 '                             go to room above this one
            If Room.y = -1 Then Room.y = 255 '                 scroll to bottom room if necessary
        Case SOUTH '                                          SOUTH
            Room.y = Room.y + 1 '                             go to room below this one
            If Room.y = 256 Then Room.y = 0 '                 scroll to top room if necessary
        Case EAST '                                           EAST
            Room.x = Room.x + 1 '                             go to room to right of this one
            If Room.x = 256 Then Room.x = 0 '                 scroll to leftmost room if necessary
        Case WEST '                                           WEST
            Room.x = Room.x - 1 '                             go to room to left of this one
            If Room.x = -1 Then Room.x = 255 '                scroll to rightmost room if necessary
    End Select
    _Dest Maze& '                                             draw on maze
    _PutImage (0, 0), BlankRoom& '                            reset maze screen to blank room
    _PutImage (189, 212), QBzerk64s& '                        display small logo
    Direction~% = (Room.x * 256 + Room.y) * 7 + 12627 '       seed random direction generator
    For p% = 1 To 8 '                                         cycle through all 8 pillars
        Direction~% = (Direction~% * 7 + 12627) * 7 + 12627 ' get next pillar direction
        Add% = 0 '                                            reset center pillar adder
        Select Case (Direction~% \ 256) And 3 '               get low bits value of high order byte
            Case NORTH '                                                                                NORTH (00)
                Line (P(p%).x, P(p%).y + 3)-(P(p%).x + 3, P(p%).y - 68), _RGB32(0, 0, 255), BF '        maze segment UP
            Case SOUTH '                                                                                SOUTH (01)
                Line (P(p%).x, P(p%).y)-(P(p%).x + 3, P(p%).y + 71), _RGB32(0, 0, 255), BF '            maze segment DOWN
            Case EAST '                                                                                 EAST (10)
                If p% = 2 Or p% = 6 Then Add% = 4 '                                                     center pillar?
                Line (P(p%).x, P(p%).y)-(P(p%).x + 51 + Add%, P(p%).y + 3), _RGB32(0, 0, 255), BF '     maze segment RIGHT
            Case WEST '                                                                                 WEST (11)
                If p% = 3 Or p% = 7 Then Add% = 4 '                                                     center pillar?
                Line (P(p%).x + 3, P(p%).y)-(P(p%).x - 48 - Add%, P(p%).y + 3), _RGB32(0, 0, 255), BF ' maze segment LEFT
        End Select
    Next p%
    _PutImage (0, 0), Maze&, WorkRoom& '                      place maze image on work screen
    _Dest Cdest& '                                            return to calling destination

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                            LOADASSETS
Sub LOADASSETS ()

    '**
    '** Sets up game variables and loads graphics and sounds.
    '**

    Shared Robot() As ROBOTS '   ARRAY: robot variables
    Shared P() As PILLARS '      ARRAY: maze pillar locations
    Shared Piece() As PIECES '   ARRAY: flying screen pieces
    Shared Law() As LAWS '       ARRAY: human being laws
    Shared Setting As SETTINGS ' ARRAY: game option settings
    Shared Level() As LEVEL '    ARRAY: level properties
    Shared Pimage&() '           IMAGE: player images
    Shared Pmask&() '            IMAGE: player mask for edge detection
    Shared PmaskTest& '          IMAGE: mask area to test for player edge detection
    Shared Rimage&() '           IMAGE: robot images
    Shared Rmask& '              IMAGE: robot mask area
    Shared BigRobot&() '         IMAGE: large robot
    Shared Boom&() '             IMAGE: robot blowing up
    Shared BoomMask& '           IMAGE: mask area for exploding robots
    Shared Flash&() '            IMAGE: player flashing when hit
    Shared FlashMask& '          IMAGE: player flashing mask
    Shared BlankRoom& '          IMAGE: room with blank maze (outer maze walls only)
    Shared WorkRoom& '           IMAGE: main game screen where action takes place
    Shared Maze& '               IMAGE: level maze
    Shared Maze3D& '             IMAGE: 3D maze image
    Shared Life& '               IMAGE: extra life indicator (little stick guy)
    Shared Font&() '             IMAGE: game font
    Shared Otto&() '             IMAGE: Evil Otto!
    Shared QBZerk64l& '          IMAGE: colorful QBzerk64 logo (large)
    Shared QBzerk64s& '          IMAGE: colorful QBzerk64 logo (small)
    Shared Icon& '               IMAGE: window icon
    Shared IconOtto& '           IMAGE: otto window icon image
    Shared OttoMask& '           IMAGE: evil otto mask
    Shared Taunt&() '            SOUND: robot taunts during gameplay (verb, noun, pitch)
    Shared MustNotEscape&() '    SOUND: the %noun% must not escape sequences
    Shared CoinDetected&() '     SOUND: coin detected in pocket sequences
    Shared FightLikeRobot&() '   SOUND: fight like a robot sequences
    Shared Rshoot& '             SOUND: robot shooting
    Shared Pshoot& '             SOUND: player shooting
    Shared Killed& '             SOUND: robot and player killed
    Shared GotTheHumanoid& '     SOUND: got the humanoid, got the intruder
    Shared IntruderAlert& '      SOUND: intruder alert, intruder alert
    Shared FootStep& '           SOUND: robotic foot step
    Shared IntroMusic& '         SOUND: introduction screen background music
    Shared Coin& '               SOUND: coin entering machine
    Shared Extra& '              SOUND: extra life sound

    Dim Sheet& '                 IMAGE: main sprite sheet
    Dim Verb%, Noun%, Pitch% '          counters to load in robot taunt sounds
    Dim c% '                            generic counter
    Dim v$, n$, p$ '                    used to build sound file names
    Dim x%, y% '                        used to cycle through arrays
    Dim q% '                            used to stop player from using X to close window manually
    Dim Dwidth% '                       width of player's desktop
    Dim Dheight% '                      height of player's desktop

    q% = _Exit '                                                                  player can't close window
    Dwidth% = _Width(_ScreenImage) '                                              get player's desktop width
    Dheight% = _Height(_ScreenImage) '                                            get player's desktop height
    Randomize Timer '                                                             seed random number generator
    HIGHSCORES LOAD '                                                             load high score table
    If _FileExists("QBzerk.ini") Then '                                           does options file exist?
        Open "QBzerk.ini" For Input As #1 '                                       yes, open file for input
        Input #1, Setting.size '                                                  get screen size option
        Input #1, Setting.full '                                                  get full screen option
        Input #1, Setting.extra '                                                 get extra player amount
    Else '                                                                        no, file does not exist
        Setting.size = 5 '                                                        set default screen size too large
        Do '                                                                      scan through screen sizes
            Setting.size = Setting.size - 1 '                                           decrement screen size
        Loop Until (Dwidth% > 256 * Setting.size) And (Dheight% > 224 * Setting.size) ' leave when window fits desktop
        Setting.full = 1 '                                                        set default full screen option
        Setting.extra = 3 '                                                       set default extra player amount
        Open "QBzerk.ini" For Output As #1 '                                      open file for output
        Print #1, Setting.size '                                                  save screen size option
        Print #1, Setting.full '                                                  save full screen option
        Print #1, Setting.extra '                                                 save extra player amount
    End If
    Close #1 '                                                                    close options file
    Law(1).text1 = "A human being may not injure a" '                             set human laws variables
    Law(1).text2 = "robot or through inaction allow"
    Law(1).text3 = "a robot to come to harm"
    Law(1).text4 = "-"
    Law(1).y = 4
    Law(1).r = 255 '                                                              255 means fade
    Law(1).g = 255
    Law(1).b = -1 '                                                               -1 means calculate
    Law(1).m = 25
    Law(1).s = _SndOpen("QBzerkL1.ogg", "VOL,SYNC")
    Law(2).text1 = "A human being must obey the"
    Law(2).text2 = "orders given it by robots"
    Law(2).text3 = "except where such orders would"
    Law(2).text4 = "conflict with the first law"
    Law(2).y = 60
    Law(2).r = 0 '                                                                0 means leave at 0
    Law(2).g = 255
    Law(2).b = -1
    Law(2).m = 75
    Law(2).s = _SndOpen("QBzerkL2.ogg", "VOL,SYNC")
    Law(3).text1 = "A human being must protect its"
    Law(3).text2 = "own existance as long as such"
    Law(3).text3 = "protection does not conflict"
    Law(3).text4 = "with the first or second laws"
    Law(3).y = 132
    Law(3).r = 255
    Law(3).g = 255
    Law(3).b = -1
    Law(3).m = 75
    Law(3).s = _SndOpen("QBzerkL3.ogg", "VOL,SYNC")
    Law(4).text1 = "YOU BROKE ALL THREE LAWS"
    Law(4).text2 = "-"
    Law(4).text3 = "-"
    Law(4).text4 = "-"
    Law(4).y = 204
    Law(4).r = 255
    Law(4).g = 0
    Law(4).b = -1
    Law(4).m = 25
    Law(4).s = _SndOpen("QBzerkL4.ogg", "VOL,SYNC")
    Level(1).points = 250 '                                                       set level point advance
    Level(2).points = 500
    Level(3).points = 1500
    Level(4).points = 3000
    Level(5).points = 4500
    Level(6).points = 6000
    Level(7).points = 7500
    Level(8).points = 10000
    Level(9).points = 12000
    Level(10).points = 14000
    Level(11).points = 16000
    Level(12).points = 18000
    Level(13).points = 20000
    Level(14).points = 20000
    Level(1).rcolor = _RGB32(191, 191, 0) '                                       dark yellow  (set robot colors)
    Level(2).rcolor = _RGB32(255, 0, 0) '                                         red
    Level(3).rcolor = _RGB32(0, 191, 191) '                                       dark cyan
    Level(4).rcolor = _RGB32(0, 255, 0) '                                         green
    Level(5).rcolor = _RGB32(191, 0, 191) '                                       dark purple
    Level(6).rcolor = _RGB32(255, 255, 0) '                                       light yellow
    Level(7).rcolor = _RGB32(255, 255, 255) '                                     white
    Level(8).rcolor = _RGB32(0, 191, 191) '                                       dark cyan
    Level(9).rcolor = _RGB32(255, 0, 255) '                                       light purple
    Level(10).rcolor = _RGB32(191, 191, 191) '                                    grey
    Level(11).rcolor = _RGB32(191, 191, 0) '                                      dark yellow
    Level(12).rcolor = _RGB32(255, 0, 0) '                                        red
    Level(13).rcolor = _RGB32(0, 255, 255) '                                      light cyan
    Level(14).rcolor = _RGB32(0, 255, 255) '                                      light cyan
    Level(1).bullets = 0 '                                                        total number of robot bullets allowed on screen at once
    Level(2).bullets = 1
    Level(3).bullets = 2
    Level(4).bullets = 3
    Level(5).bullets = 4
    Level(6).bullets = 5
    Level(7).bullets = 1
    Level(8).bullets = 2
    Level(9).bullets = 3
    Level(10).bullets = 4
    Level(11).bullets = 5
    Level(12).bullets = 5
    Level(13).bullets = 8
    Level(14).bullets = 8
    Level(1).rbullets = 0 '                                                       number of bullets a robot can fire at a time
    Level(2).rbullets = 1
    Level(3).rbullets = 2
    Level(4).rbullets = 3
    Level(5).rbullets = 4
    Level(6).rbullets = 5
    Level(7).rbullets = 1
    Level(8).rbullets = 2
    Level(9).rbullets = 3
    Level(10).rbullets = 4
    Level(11).rbullets = 5
    Level(12).rbullets = 5
    Level(13).rbullets = 8
    Level(14).rbullets = 8
    Level(1).bspeed = 0 '                                                         robot bullet speed
    Level(2).bspeed = 2
    Level(3).bspeed = 2
    Level(4).bspeed = 3
    Level(5).bspeed = 3
    Level(6).bspeed = 3
    Level(7).bspeed = 5
    Level(8).bspeed = 5
    Level(9).bspeed = 5
    Level(10).bspeed = 5
    Level(11).bspeed = 6
    Level(12).bspeed = 6
    Level(13).bspeed = 6
    Level(14).bspeed = 6
    Robot(1).zx = 12: Robot(1).zy = 12 '                                          set robot zone coordinates
    Robot(2).zx = 60: Robot(2).zy = 12
    Robot(3).zx = 160: Robot(3).zy = 12
    Robot(4).zx = 208: Robot(4).zy = 12
    Robot(5).zx = 60: Robot(5).zy = 80
    Robot(6).zx = 110: Robot(6).zy = 80
    Robot(7).zx = 160: Robot(7).zy = 80
    Robot(8).zx = 12: Robot(8).zy = 148
    Robot(9).zx = 60: Robot(9).zy = 148
    Robot(10).zx = 160: Robot(10).zy = 148
    Robot(11).zx = 208: Robot(11).zy = 148
    Robot(12).zx = 110: Robot(12).zy = 12
    Robot(13).zx = 12: Robot(13).zy = 80
    Robot(14).zx = 208: Robot(14).zy = 80
    Robot(15).zx = 110: Robot(15).zy = 148
    P(1).x = 52: P(1).y = 68 '                                                    set maze pillar locations
    P(2).x = 100: P(2).y = 68
    P(3).x = 152: P(3).y = 68
    P(4).x = 200: P(4).y = 68
    P(5).x = 52: P(5).y = 136
    P(6).x = 100: P(6).y = 136
    P(7).x = 152: P(7).y = 136
    P(8).x = 200: P(8).y = 136
    PmaskTest& = _NewImage(8, 16, 32) '                                           create player mask test area
    Rmask& = _NewImage(8, 12, 32) '                                               create robot mask test area
    OttoMask& = _NewImage(8, 8, 32) '                                             create evil otto mask area
    BoomMask& = _NewImage(16, 18, 32) '                                           create exploding robot mask area
    FlashMask& = _NewImage(8, 17, 32) '                                           create flashing player mask
    Maze& = _NewImage(256, 224, 32) '                                             each level's maze image
    WorkRoom& = _NewImage(256, 224, 32) '                                         room where action happens
    BlankRoom& = _NewImage(256, 224, 32) '                                        blank room with no maze
    Sheet& = _LoadImage("QBzerkSH.png", 32) '                                     load sprite sheet
    QBZerk64l& = _LoadImage("QBzerk64.png", 32) '                                 get large QBzerk64 logo
    Maze3D& = _LoadImage("QBzerk3D.png", 32) '                                    load 3D maze screen
    _Dest BlankRoom& '                                                            draw on blank room
    Cls '                                                                         remove transparency from room
    Line (4, 0)-(251, 207), _RGB32(0, 0, 255), BF '                               draw outer maze walls
    Line (8, 4)-(247, 203), _RGB32(0, 0, 0), BF
    Line (0, 72)-(255, 135), _RGB32(0, 0, 0), BF
    Line (104, 0)-(151, 223), _RGB32(0, 0, 0), BF
    IconOtto& = _NewImage(16, 16, 32)
    _PutImage (0, 0), Sheet&, IconOtto&, (192, 36)-(207, 51) '                    place large Evil Otto on icon image
    Icon& = _NewImage(16, 16, 32) '                                               create window icon image holder
    _Dest Icon& '                                                                 draw on icon image holder
    Cls , _RGB32(255, 255, 0) '                                                   clear with light yellow background
    _PutImage (0, 0), IconOtto& '                                                 place large Evil Otto on icon image
    Life& = _NewImage(5, 8, 32) '                                                 life indicator holder
    _PutImage (0, 0), Sheet&, Life&, (80, 0)-(84, 77) '                           get life indicator
    QBzerk64s& = _NewImage(64, 11, 32) '                                          QBzerk64 small logo holder
    _PutImage (0, 0), Sheet&, QBzerk64s&, (127, 0)-(190, 10) '                    get small logo
    For x% = 0 To 15 '                                                            cycle horizontally through piece array
        For y% = 0 To 13 '                                                        cycle vertically through piece array
            Piece(x%, y%).image = _NewImage(16, 16, 32) '                         create piece image holder
        Next y%
    Next x%
    For c% = 0 To 25 '                                                            cycle through all sheet sprites
        Font&(c% + 11) = _NewImage(8, 12, 32) '                                   create upper-case holder
        Font&(c% + 37) = _NewImage(8, 12, 32) '                                   create lower-case holder
        _PutImage (0, 0), Sheet&, Font&(c% + 11), (c% * 8, 12)-(c% * 8 + 7, 23) ' get upper case character
        _PutImage (0, 0), Sheet&, Font&(c% + 37), (c% * 8, 24)-(c% * 8 + 7, 35) ' get lower case character
        If c% < 3 Then '                                                                          ok to get boom images?
            Boom&(c% + 1) = _NewImage(16, 18, 32) '                                               yes, blowing up holder
            _PutImage (0, 0), Sheet&, Boom&(c% + 1), (144 + c% * 16, 36)-(159 + c% * 18, 53) '    get blowing up image
        End If
        If c% < 4 Then '                                                                          ok to get flash images?
            Flash&(c% + 1) = _NewImage(8, 17, 32) '                                               yes, flash holder
            _PutImage (0, 0), Sheet&, Flash&(c% + 1), (72 + c% * 8, 36)-(79 + c% * 8, 52) '       get flashing images
        End If
        If c% < 5 Then '                                                                          ok get otto/robot images?
            Otto&(c% + 1) = _NewImage(8, 8, 32) '                                                 yes, evil otto holder
            _PutImage (0, 0), Sheet&, Otto&(c% + 1), (85 + c% * 8, 0)-(92 + c% * 8, 7) '          get evil otto images
            Rimage&(c% + 1, -1) = _NewImage(8, 12, 32) '                                          robot facing left holder
            Rimage&(c% + 1, 1) = _NewImage(8, 12, 32) '                                           robot facing right holder
            _PutImage (0, 0), Sheet&, Rimage&(c% + 1, 1), (104 + c% * 8, 36)-(111 + c% * 8, 47) ' get robot facing right
            _PutImage (0, 0), Rimage&(c% + 1, 1), Rimage&(c% + 1, -1), (7, 0)-(0, 11) '           make robot facing left
        End If
        If c% < 9 Then '                                                                          ok to get player images?
            Pimage&(c% + 1, -1) = _NewImage(8, 16, 32) '                                          yes, player left holder
            Pimage&(c% + 1, 1) = _NewImage(8, 16, 32) '                                           player right holder
            Pmask&(c% + 1, -1) = _NewImage(8, 16, 32) '                                           player left mask
            Pmask&(c% + 1, 1) = _NewImage(8, 16, 32) '                                            player right mask
            _PutImage (0, 0), Sheet&, Pimage&(c% + 1, 1), (c% * 8, 36)-(c% * 8 + 7, 51) '         get player facing right
            _PutImage (0, 0), Pimage&(c% + 1, 1), Pimage&(c% + 1, -1), (7, 0)-(0, 15) '           make player facing left
            Pmask&(c% + 1, -1) = _CopyImage(Pimage&(c% + 1, -1)) '                                copy mask image right
            Pmask&(c% + 1, 1) = _CopyImage(Pimage&(c% + 1, 1)) '                                  copy mask image left
            _ClearColor _RGB32(0, 0, 0), Pimage&(c% + 1, -1) '                                    player black transparent
            _ClearColor _RGB32(0, 0, 0), Pimage&(c% + 1, 1) '                                     player black transparent
            _ClearColor _RGB32(0, 255, 0), Pmask&(c% + 1, -1) '                                   mask green transparent
            _ClearColor _RGB32(0, 255, 0), Pmask&(c% + 1, 1) '                                    mask green transparent
        End If
        If c% < 10 Then '                                                                         ok to get numbers?
            Font&(c% + 1) = _NewImage(8, 12, 32) '                                                yes, create number holder
            _PutImage (0, 0), Sheet&, Font&(c% + 1), (c% * 8, 0)-(c% * 8 + 7, 11) '               get number from sheet
        End If
    Next c%
    Rimage&(7, -1) = _CopyImage(Rimage&(5, -1)) '                                 arrange robot walking sequences
    Rimage&(6, -1) = _CopyImage(Rimage&(4, -1))
    Rimage&(5, -1) = _CopyImage(Rimage&(1, -1))
    Rimage&(4, -1) = _CopyImage(Rimage&(3, -1))
    Rimage&(3, -1) = _CopyImage(Rimage&(1, -1))
    Rimage&(7, 1) = _CopyImage(Rimage&(5, 1))
    Rimage&(6, 1) = _CopyImage(Rimage&(4, 1))
    Rimage&(5, 1) = _CopyImage(Rimage&(1, 1))
    Rimage&(4, 1) = _CopyImage(Rimage&(3, 1))
    Rimage&(3, 1) = _CopyImage(Rimage&(1, 1))
    For c% = 1 To 4 '                                                             cycle through big robot images
        BigRobot&(c%) = _NewImage(128, 176, 32) '                                 create image holder
        _Dest BigRobot&(c%) '                                                     make image destination
        Cls , _RGB32(196, 0, 0) '                                                 clear with red
        _PutImage , Rimage&(c% + 1, 1), BigRobot&(c%) '                           place robot image over top
        _ClearColor _RGB32(0, 0, 0) '                                             make black transparent
    Next c%
    For Verb% = 1 To 7 '                                                          cycle through robot verbs
        v$ = LTrim$(Str$(Verb%)) '                                                extract verb number
        For Noun% = 1 To 5 '                                                      cycle through robot nouns
            n$ = v$ + LTrim$(Str$(Noun%)) '                                       extract noun number
            For Pitch% = 1 To 3 '                                                 cycle through robot pitches
                p$ = "QBzerk" + n$ + LTrim$(Str$(Pitch%)) + ".ogg" '              piece together sound file name
                Taunt&(Verb%, Noun%, Pitch%) = _SndOpen(p$, "VOL,SYNC") '         load taunt sound
            Next Pitch%
            If Verb% < 4 And Noun% < 4 Then '                                     ok to load escape sequences?
                p$ = "QBzerkE" + n$ + ".ogg" '                                    yes, piece together sound file name
                MustNotEscape&(Verb%, Noun%) = _SndOpen(p$, "VOL,SYNC") '         load escape sounds
            End If
        Next Noun%
        If Verb% < 4 Then '                                                       load coin & chicken sequences?
            n$ = "QBzerkC" + v$ + ".ogg" '                                        yes, piece together sound file name
            CoinDetected&(Verb%) = _SndOpen(n$, "VOL,SYNC") '                     load coin detected sounds
            n$ = "QBzerkF" + v$ + ".ogg" '                                        piece together sound file name
            FightLikeRobot&(Verb%) = _SndOpen(n$, "VOL,SYNC") '                   load fight sounds
        End If
    Next Verb%
    Rshoot& = _SndOpen("QBzerkRS.ogg", "VOL,SYNC") '                              load remaining sounds
    Pshoot& = _SndOpen("QBzerkPS.ogg", "VOL,SYNC")
    Killed& = _SndOpen("QBzerkRD.ogg", "VOL,SYNC")
    GotTheHumanoid& = _SndOpen("QBzerkGI.ogg", "VOL,SYNC")
    IntruderAlert& = _SndOpen("QBzerkIA.ogg", "VOL,SYNC")
    FootStep& = _SndOpen("QBzerkWR.ogg", "VOL,SYNC")
    IntroMusic& = _SndOpen("QBzerkBG.ogg", "VOL,SYNC")
    Coin& = _SndOpen("QBzerk1C.ogg", "VOL,SYNC")
    Extra& = _SndOpen("QBzerkEX.ogg", "VOL,SYNC")
    _FreeImage Sheet& '                                                           sprite sheet no longer needed

End Sub

'----------------------------------------------------------------------------------------------------------------------
'                                                                                                               CLEANUP
Sub CLEANUP ()

    '**
    '** Removes all sound and graphic assets from computer's RAM. This subroutine will be called if the player attempts
    '** to close the game using the X button in the upper right hand corner of the game window, ensuring all assets are
    '** properly removed from RAM.
    '**

    Shared MainScreen& '         IMAGE: main view screen
    Shared Pimage&() '           IMAGE: player images
    Shared Pmask&() '            IMAGE: mask for edge detection
    Shared PmaskTest& '          IMAGE: mask area to test for player edge detection
    Shared Rimage&() '           IMAGE: robot images
    Shared Rmask& '              IMAGE: robot mask area
    Shared BigRobot&() '         IMAGE: large robot
    Shared Boom&() '             IMAGE: robot blowing up
    Shared BoomMask& '           IMAGE: mask area for exploding robots
    Shared Flash&() '            IMAGE: player flashing when hit
    Shared FlashMask& '          IMAGE: player flashing mask
    Shared Maze& '               IMAGE: level maze
    Shared Maze3D& '             IMAGE: 3D maze image
    Shared BlankRoom& '          IMAGE: room with blank maze (outer maze walls only)
    Shared WorkRoom& '           IMAGE: main game screen where action takes place
    Shared Life& '               IMAGE: extra life indicator (little stick guy)
    Shared Font&() '             IMAGE: game font
    Shared Otto&() '             IMAGE: Evil Otto!
    Shared QBzerk64s& '          IMAGE: colorful QBzerk64 logo
    Shared QBZerk64l& '          IMAGE: colorful QBzerk64 logo (large)
    Shared Icon& '               IMAGE: window icon
    Shared IconOtto& '           IMAGE: otto window icon image
    Shared OttoMask& '           IMAGE: evil otto mask
    Shared Taunt&() '            SOUND: robot taunts during gameplay (verb, noun, pitch)
    Shared MustNotEscape&() '    SOUND: the %noun% must not escape sequences
    Shared CoinDetected&() '     SOUND: coin detected in pocket sequences
    Shared FightLikeRobot&() '   SOUND: fight like a robot sequences
    Shared Rshoot& '             SOUND: robot shooting
    Shared Pshoot& '             SOUND: player shooting
    Shared Killed& '             SOUND: robot and player killed
    Shared GotTheHumanoid& '     SOUND: got the humanoid, got the intruder
    Shared IntruderAlert& '      SOUND: intruder alert, intruder alert
    Shared IntroMusic& '         SOUND: introduction screen background music
    Shared Coin& '               SOUND: coin entering machine
    Shared Extra& '              SOUND: extra life sound

    Dim c% '                            generic counter to close sprite images
    Dim Verb%, Noun%, Pitch% '          counters to close robot taunt sounds
    Dim Chicken& '               SOUND: one last taunt

    If _SndPlaying(IntroMusic&) Then _SndStop IntroMusic& '         stop background music if playing
    If _SndPlaying(IntruderAlert&) Then _SndStop IntruderAlert& '   stop intruder alert if playing
    If _SndPlaying(Taunt&(3, 3, 1)) Then _SndStop Taunt&(3, 3, 1) ' stop taunt if playing
    _Delay .5 '                                                     1/2 second pause
    Chicken& = _SndOpen("QBzerkCH.ogg", "VOL,SYNC") '    load chicken sound
    _SndPlay Chicken& '                                  play chicken
    Do: Loop Until Not _SndPlaying(Chicken&) '           stay here until finished
    _SndClose Chicken& '                                 free chicken sound file
    _Delay .5 '                                          1/2 second pause
    _Source 0 '                                          return to main screen as source
    _Dest 0 '                                            return to main screen as destination
    For c% = 0 To 25 '                                   free all images
        _FreeImage Font&(c% + 11)
        _FreeImage Font&(c% + 37)
        If c% < 3 Then
            _FreeImage Boom&(c% + 1)
        End If
        If c% < 4 Then
            _FreeImage Flash&(c% + 1)
            _FreeImage BigRobot&(c% + 1)
        End If
        If c% < 5 Then
            _FreeImage Otto&(c% + 1)
        End If
        If c% < 7 Then
            _FreeImage Rimage&(c% + 1, -1)
            _FreeImage Rimage&(c% + 1, 1)
        End If
        If c% < 9 Then
            _FreeImage Pimage&(c% + 1, -1)
            _FreeImage Pimage&(c% + 1, 1)
            _FreeImage Pmask&(c% + 1, -1)
            _FreeImage Pmask&(c% + 1, 1)
        End If
        If c% < 10 Then '
            _FreeImage Font&(c% + 1)
        End If
    Next c%
    _FreeImage Rmask&
    _FreeImage PmaskTest&
    _FreeImage Maze&
    _FreeImage WorkRoom&
    _FreeImage BlankRoom&
    _FreeImage Icon&
    _FreeImage IconOtto&
    _FreeImage Life&
    _FreeImage QBzerk64s&
    _FreeImage QBZerk64l&
    _FreeImage Maze3D&
    _FreeImage BoomMask&
    _FreeImage OttoMask&
    _FreeImage FlashMask&
    For Verb% = 1 To 7 '                                 free all sound files
        For Noun% = 1 To 5 '
            For Pitch% = 1 To 3 '
                _SndClose Taunt&(Verb%, Noun%, Pitch%)
            Next Pitch%
            If Verb% < 4 And Noun% < 4 Then '
                _SndClose MustNotEscape&(Verb%, Noun%)
            End If
        Next Noun%
        If Verb% < 4 Then '
            _SndClose CoinDetected&(Verb%)
            _SndClose FightLikeRobot&(Verb%)
        End If
    Next Verb%
    _SndClose Rshoot&
    _SndClose Pshoot&
    _SndClose Killed&
    _SndClose GotTheHumanoid&
    _SndClose IntruderAlert&
    _SndClose IntroMusic&
    _SndClose Coin&
    _SndClose Extra&
    Close '                                              close all open files
    Screen 0 '                                           go to text screen
    _FreeImage MainScreen& '                             remove main playing screen
    System '                                             return to operating system

End Sub
'----------------------------------------------------------------------------------------------------------------------
'
' Acknowledgments:
'------------------
'
' Berzerk is Copyright(c)1980 Stern Electronics, Inc.
'
' QBzerk64 was written in QB64 Version 1.0. A free copy of the QB64 programming language can be obtained at:
'
'                                                 http://www.qb64.net
'
' A special thanks to Rob (aka Galleon) for creating the QB64 programming language thereby giving all of us old-school
' QuickBasic programmers something to do with our over-active minds! :)
'
' A special thanks to Ted (aka Clippy) for maintaining the QB64 Wiki, an invaluable resource for QB64 programmers!
'
' A special thanks to Steve McNeill (aka smcneill) for helping me through the process of hardware image use in QB64.
'
' And finally a special thanks to the entire QB64 forum community for helping to keep QB64 alive and well.
'
'----------------------------------------------------------------------------------------------------------------------
'          ____________________________________________________________________________________________
'                                                   _________
'                                                 _|         |_
'                                               _|   _     _   |_
'                                              |    |_|   |_|    |
'                                              |                 |
'                                              |   _         _   |
'                                              |  |_|_______|_|  |
'                                              |_   |_______|   _|
'                                                |_           _|
'                                                  |_________|
'
'                                                HAVE A NICE DAY
'          ____________________________________________________________________________________________
'
