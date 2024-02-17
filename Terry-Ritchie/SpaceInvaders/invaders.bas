'----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'
'                 лллл     ллллллл     ллл       лллл    ллллллл               This software has been written for educational purposes only. Under no circumstances is this source
'                ллллллл   лллллллл    ллл      лллллл   ллллллл               code or compiled EXE to be sold or otherwise used for a profitable purpose.
'                лллллллл  ллллллллл  ллллл     ллллллл  ллллллл
'                лллллллл  ллллллллл  ллллл    лллллллл  ллллллл               Space Invaders was designed by Tomohiro Nishikado and is Copyright Taito Corporation with a license
'                лллллллл  ллл   ллл ллллллл   ллл  ллл ллл                    to the Midway division of Bally Corporation for production. This software was written to pay homage
'                лл   ллл  ллл   ллл ллллллл   ллл  ллл ллл                    to Mr. Nishikado's outstanding game.
'                ллл  ллл  ллл   ллл ллллллл   ллл  ллл ллл
'                 ллл      ллл   ллл лл л лл   ллл      ллл                    This source code has been released as open source which means you are free to use this source code
'                 лллл     ллллллллл лл л лл   ллл      ллллл                  to learn from and modify without prior consent from the original author. It is requested, however,
'                 ллллл    лллллллл  ллллллл  ллл      лллллл                  that if you do make modifications to this source code that the author, version, and any
'                  лллллл   лллллл    ллллл   ллл      лллллл                  modifications be noted in the area provided below if you plan to redistribute the source code with
'                    ллллл  лллллл    ллллл   ллл      лл                      your modifications.
'                      ллл  ллл       лл лл   ллл      лл
'                   лл  лл  ллл      ллл ллл  ллл ллл  лл                           Author      Version   Date     Modifications
'                   лл  лл  ллл      лл   лл  ллл ллл ллл                      ---------------- ------- -------- ------------------------------------------------------------------
'                   лллллл  ллл     лллл лллл ллллллл лллллл                   Terry Ritchie    1.0     06/24/13 Original version written in QB64 v0.954 SDL never released (buggy)
'                   лллллл  ллл      ллл ллл   ллллл  лллллл                   ---------------- ------- -------- ------------------------------------------------------------------
'                    ллллл  ллл       лл лл     ллл   лллллл                   Terry Ritchie    2.0     10/31/22 Complete rewrite of code to support QB64PE v.3.3.0
'                     ллл   ллл       лл лл     ллл   лллллл                                                     This source code should compile with versions of QB64 2.1 and up
'                                                                                                                The QB64PE logo was created by Pwillard at the QB64PE forum
'                 лл лл  лл лл  лл  ллл  лллл  ллллл  ллл   ллл                ---------------- ------- -------- ------------------------------------------------------------------
'                 лл лл  лл лл  лл ллллл ллллл лл    ллллл лл лл
'                 лл лл  лл лл  лл ллллл лл лл лл    ллллл лл
'                 лл ллл лл лл  лл лл лл лл лл лл    лл лл лл
'                 лл лллллл лл  лл лл лл лл лл лл    лл лл лл
'                 лл лллллл  лллл  ллллл лл лл ллллл лллл   ллл
'                 лл лл ллл  лллл  ллллл лл лл лл    ллллл    лл
'                 лл лл  лл  лллл  лл лл лл лл лл    лл лл лл лл
'                 лл лл  лл   лл   лл лл лллл  лл    лл лл  ллл
'                 лл лл  лл   лл   лл лл лллл  ллллл лл лл  ллл
'
'                               QB64 adaptation
'                                      by
'                                Terry Ritchie
'                           (quickbasic64@gmail.com)
'                                   06/24/13
'                               Updated 10/31/22
'
'
' I tried to clone the original space invaders game as closely as possible. The deviations from the original are noted below:
' ---------------------------------------------------------------------------------------------------------------------------
' - Centered the high score.
' - UFO intervals are 23 to 27 seconds. Sources I found state every 25 seconds give or take a few seconds but nothing firm.
' - player keyboard instructions on screen for inserting coins, setting options, and exiting the game.
' - An options screen simulating DIP switch settings on the motherboard of arcade machine.
' - Ability to turn the background image on and off (set in options).
' - Ability to display cabinet bezel around the screen (set in options).
' - Ability to change the screen resolution from native 224x248 to 2x, 3x, and full screen (set in options).
' - QB64 and author credit screen added to demo loop.
' - Invader beat sounds are slightly longer in length than the original.
' - Scores are five digits instead of the four found in the original game.
' - Extra ship sound is not exact to the original.
' - The high score is saved between program executions with the ability to reset the high score if desired (reset in options).
' - There is no demo play yet between the different intro screens at startup. Coming in next version.
'
' What I found about the original that was emulated in the game.
' --------------------------------------------------------------
' - The invaders update in a wave pattern like the original due to the slow microprocessor.
' - As the invaders are destroyed the wave pattern increases in speed.
' - The UFO scoring is not random. After 23 shots the UFO will always be 300 points and every 15 shots after that.
' - DIP switch options for setting the number of shields (3 to 6), coin or free play, and extra ship score (1000 or 1500).
' - The player's laser will always be destroyed when hit by a bomb. The bomb will randomly survive the encounter.
' - The demo screen will alternate between spelling PLAY correctly and with an upside down Y. The upside down Y will be carried off and corrected by an invader.
' - The demo screen will alternative between spelling COIN correctly or adding an extra C. The extra C will be destroyed by an invader.
'
' Bug or easter egg?
' ------------------
' There was a "bug" in the original Space Invaders that some considered to be an "Easter Egg". Mr. Nishikado never confirmed this either way. When the invaders are in the row
' directly above the player the player is immune to bombs. I consider this to be a "bug" because the bottom of the bomb was used to detect a collision with the player's ship.
' Since the bomb moves down one pixel before the collision check is done the player's ship becomes immune. Since this was a bug in my view this behavior has not been emulated
' in this version of the game. However, this behavior would be very easy to emulate if desired.
'
' Coding today is easier!
' -----------------------
' Of all the games I've emulated this was surprisingly one of the most difficult to write. It makes me appreciate the complexity of writing software for the late 70's to early
' 80's microprocessors used in arcade games of the time. Those were true programmers crafting excellent games in Assembler on very limited processors with 2K to 4K of RAM and ROM!
'
' Known issues with this version of the game.
' -------------------------------------------
' - When selecting a different screen size or adding/removing the bezel image in options upon exit from the options screen the game window will not recenter on the desktop.
'   I've tried every method I can think of to get this to work. Upon game exit and restart the centering will work fine.
'
' Files included with the game:
' -----------------------------
' File created by the game - si.sav         - saved options and high score
' Support files            - sibeat1.ogg    - heart beat 1 sound
'                          - sibeat2.ogg    - heart beat 2 sound
'                          - sibeat3.ogg    - heart beat 3 sound
'                          - sibeat4.ogg    - heart beat 4 soound
'                          - sicoin.ogg     - coin inserted sound
'                          - siextra.ogg    - extra ship sound
'                          - siidead.ogg    - invader explosion sound
'                          - silaser.ogg    - laser sound
'                          - sipdead.ogg    - ship explosion sound
'                          - siudead.ogg    - UFO explosion sound
'                          - siufofly.ogg   - UFO flying sound
'                          - siicon.bmp     - window icon image
'                          - sisprites.png  - game graphics
'                          - invaders.bas   - QB64 source code
'                                                                                                                                                                  +--------------+
'                                                                                                                                                                  | METACOMMANDS |
'------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
'
Option _Explicit '                                         force declaration of all variables
$VersionInfo:CompanyName=RitchCraft Creations
$VersionInfo:FileDescription=QB64 Space Invaders
$VersionInfo:InternalName=invaders.exe
$VersionInfo:ProductName=QB64 Space Invaders
$VersionInfo:OriginalFilename=invaders.exe
$VersionInfo:LegalCopyright=(c)2022 RitchCraft Creations
$VersionInfo:FILEVERSION#=2,0,0,0
$VersionInfo:PRODUCTVERSION#=2,0,0,0
'                                                                                                                                                                     +-----------+
'                                                                                                                                                                     | CONSTANTS |
'---------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------+
'
Const FALSE = 0, TRUE = Not FALSE '   boolean truth detecors
Const PLAYER1 = 1 '                   player 1 value
Const PLAYER2 = 2 '                   player 2 value
Const BOTHPLAYERS = 3 '               both players value
Const BLACK = _RGB32(0, 0, 0) '       color constants
Const WHITE = _RGB32(255, 255, 255)
Const INGAME = 5 '                    mode settings
Const INOPTIONS = 1
Const INCOIN = 2
Const INSELECT = 3
Const NEWGAME = -1
Const NEWLEVEL = 0
Const CLEARVARIABLES = -1
Const GODMODE = FALSE '               developer option
'                                                                                                                                                             +-------------------+
'                                                                                                                                                             | TYPE DECLARATIONS |
'-------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------+
Type RECT '                   rectangle definition                                                                                                                         | RECT |
    x1 As Integer '           rectagular coordinates for objects and collision detection                                                                                   +------+
    y1 As Integer
    x2 As Integer '           x1,y1 = upper left    x2,y2 = lower right
    y2 As Integer
End Type
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------+
Type PAUSE '                  pause conditions                                                                                                                            | PAUSE |
    Level As Integer '        between levels pause                                                                                                                        +-------+
    Die As Integer '          after player death pause
End Type
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Type LASERHIT '               laser hitting objects properties                                                                                                         | LASERHIT |
    Count As Integer '        number of invaders player has hit
    Invader As Integer '      countdown timer after invader hit by laser                                                                                               +----------+
    InvaderX As Integer '     invader hit coordinates for explosion
    InvaderY As Integer
    UFO As Integer '          countdown timer after UFO hit by laser
    UFOX As Integer '         UFO hit coordinate for score text
    Shield As Integer '       countdown timer after shield hit by laser
    ShieldX As Integer '      shield hit coordinates for explosion (mask)
    ShieldY As Integer
    Bomb As Integer '         countdown timer after bomb hit by laser
    BombX As Integer '        bomb hit coordinates for explosion
    BombY As Integer
End Type
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------+
Type BOMBHIT '                bomb hitting objects properties                                                                                                           | BOMBHIT |
    Shield As Integer '       countdown timer after shield hit by bomb
    ShieldX As Integer '      shield hit coordinates for explosion (mask)
    ShieldY As Integer
End Type
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------+
Type LASER '                  laser properties                                                                                                                            | LASER |
    rect As RECT '            laser coordinates                                                                                                                           +-------+
    Active As Integer '       laser active (t/f)
    Hit As LASERHIT '         laser hit something
    Miss As Integer '         laser hit top of screen
    ShotsFired As Integer '   number of laser shots fired (for UFO scoring)
End Type
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+
Type SHIP '                   player ship properties                                                                                                                       | SHIP |
    rect As RECT '            player ship coordinates                                                                                                                      +------+
    Remain As Integer '       player ships remain
    Dead As Integer '         player ship is dead
    DeadX As Integer '        player ship death location
    DeadImage As Integer '    player ship exploding images indicator (-1 or 1)
    Extra As Integer '        extra ship awarded to player (t/f)
End Type
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+
Type SOUNDS '                 sounds                                                                                                                                     | SOUNDS |
    InvaderHit As Long '      invader hit sound                                   snd.invaderhit                                                                         +--------+
    PlayerHit As Long '       player hit sound                                    snd.playerhit
    UFOHit As Long '          UFO hit sound                                       snd.ufohit
    UFOFlying As Long '       UFO slying sound                                    snd.ufoflying
    Laser As Long '           laser firing sound                                  snd.laser
    Coin As Long '            coin dropping sound                                 snd.coin
    Beat1 As Long '           heartbeat sounds                                    snd.beat1
    Beat2 As Long '                                                               snd.beat2
    Beat3 As Long '                                                               snd.beat3
    Beat4 As Long '                                                               snd.beat4
    Extra As Long '           extra ship sound                                    snd.extra
End Type
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+
Type IMAGES '                 images                                                                                                                                     | IMAGES |
    UFO As Long '             UFO image                                           img.ufo                                                                                +--------+
    InvaderHit As Long '      invader explosion                                   img.invaderhit
    BombHit As Long '         bomb explosion (bottom of screen and shields)       img.bombhit
    BombHitMask As Long '     destroy shields image                               img.bombhitmask
    LaserHit As Long '        laser hit explosion (top of screen and shields)     img.laserhit
    LaserHitMask As Long '    destroy shields image                               img.laserhitmask
    Shield As Long '          shield                                              img.shield
    QB64PE As Long '          QB64 Phoenix Edition logo                           img.qb64pe
    DipSwitch As Long '       single DIP switch image                             img.dipswitch
End Type
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------+
Type OPTIONS '                game options                                                                                                                              | OPTIONS |
    ScreenSize As Integer '   screen size (1 to 4)                                options.screensize                                                                    +---------+
    Shields As Integer '      number of shields (3 to 6)                          options.shields
    ExtraShip As Integer '    extra ship score (1000 or 1500)                     options.extraship
    FreePlay As Integer '     free play (t/f)                                     options.freeplay
    Background As Integer '   show background (t/f)                               options.background
    Bezel As Integer '        show bezel (t/f)                                    options.bezel
    Switches As Integer '     DIP switch settings                                 options.switches
    FullScreen As Integer '   full screen (t/f)                                   options.fullscreen
End Type
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------+
Type DISPLAY '                screens                                                                                                                                   | DISPLAY |
    WorkScreen As Long '      224x248 game work screen                            display.workscreen                                                                    +---------+
    Screen As Long '          screen to stretch work screen onto                  display.screen
    OptionScreen As Long '    options (dip switch) screen                         display.optionscreen
    ColorMask As Long '       color mask to lay over                              display.colormask
    WorkMask As Long '        work mask screen                                    display.workmask
    Bezel As Long '           bezel image                                         display.bezel
    Background As Long '      background image                                    display.background
    Bez As RECT '             display screen coordinates within bezel             display.bez
    WithY As Long '           Images for intro animations                         display.withy
    WithoutY As Long '                                                            display.withouty
    CorrectY As Long '                                                            display.correcty
    AddedC As Long '                                                              display.addedc
    NormalC As Long '                                                             display.normalc
End Type
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+
Type GAME '                   game in progress settings                                                                                                                    | GAME |
    Player As Integer '       current player playing game                         game.player                                                                              +------+
    Players As Integer '      number of players playing game                      game.players
    Credits As Integer '      credits inserted into machine                       game.credits
    Pause As PAUSE '          pause needed between levels                         game.pause.level             (count down timer 120 frames or 2 seconds - PlayGame)
    '                         pause needed between player deaths                  game.pause.die               (count down timer 180 frames or 3 seconds - PlayGame)
    Frame As Integer '        master frame counter                                game.frame
    HighScore As Long '       game high score                                     game.highscore
    Landed As Integer '       invaders landed (t/f)                               game.landed
End Type
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+
Type BOMB '                   bomb properties                                                                                                                              | BOMB |
    rect As RECT '            bomb coordinates                                    bomb().rect                                                                              +------+
    Hit As BOMBHIT '          indicates bomb hit a shield                         bomb().hit.shield            (count down timer 5 frames - DrawShields)
    '                         where the bomb hit the shield                       bomb().hit.shieldx
    '                                                                             bomb().hit.shieldy
    Image As Integer '        bomb image (1 to 3)                                 bomb().image
    Cell As Integer '         bomb image animation cell (1 to 4)                  bomb().cell
    Active As Integer '       bomb currently dropping (t/f)                       bomb().active
    Miss As Integer '         bomb hit bottom of screen                           bomb().miss                  (count down timer 5 frames - DrawBombs)
End Type
'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----+
Type UFO '                    UFO properties                                                                                                                                | UFO |
    rect As RECT '            UFO coordinates                                     ufo.rect                                                                                  +-----+
    Dir As Integer '          UFO direction                                       ufo.dir
    Active As Integer '       UFO active                                          ufo.active
    Score As Integer '        UFO score                                           ufo.score
    Pause As Integer '        Time to wait for next UFO                           ufo.pause                    (count down timer 1500 frames +/- 120 - DrawUFO)
End Type
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+
Type PLAYER '                 player properties                                                                                                                          | PLAYER |
    Ship As SHIP '            player ship coordinates                             player().ship.rect                                                                     +--------+
    '                         player ships remaining                              player().ship.remain
    '                         indicates the player's ship was hit                 player().ship.dead
    '                         where on screen the ship was hit                    player().ship.deadx
    '                         player ship exploding images indicator (-1 or 1)    player().ship.deadimage
    '                         indicates if player was awarded extra ship (t/f)    player().ship.extra
    Level As Integer '        player level                                        player().level
    Score As Long '           player score                                        player().score
    GameOver As Integer '     player game over (t/f)                              player().gameover
    Laser As LASER '          player laser coordinates                            player().laser.rect
    '                         indicates if laser if currently flying (t/f)        player().laser.active
    '                         indicates laser hit top of screen                   player().laser.miss          (count down timer 10 frames - DrawLaser)
    '                         indictaes laser hit an invader                      player().laser.hit.invader   (count down timer 5 frames - DrawInvaders)
    '                         location on screen where invader was hit            player().laser.hit.invaderx
    '                                                                             player().laser.hit.invadery
    '                         number of invaders killed (1 to 55)                 player().laser.hit.count
    '                         indicates if laser hit a UFO                        player().laser.hit.ufo       (count down timer 60 frames or 1 second - DrawUFO)
    '                         location on screen where UFO was hit                player().laser.hit.ufox
    '                         indicates that laser hit a shield                   player().laser.hit.shield    (count down timer 5 frames - DrawShields)
    '                         location on shield where laser hit                  player().laser.hit.shieldx
    '                                                                             player().laser.hit.shieldy
    '                         indicates that laser hit a bomb                     player().laser.hit.bomb      (count down timer 5 frames - DrawLaser)
    '                         location on screen where laser hit bomb             player().laser.hit.bombx
    '                                                                             player().laser.hit.bomby
    '                         number of lasers fired by player (for UFO score)    player().laser.shotsfired
    idir As Integer '         invader direction (-2 or 2)                         player().idir
    MaxBombs As Integer '     maximum number of invader bombs allowed (1 to 3)    player().maxbombs
    UFO As UFO '              UFO saved state in multiplayer game                 player().ufo.rect
    '                         direction of UFO (-1 or 1)                          player().ufo.dir
    '                         indicates if UFO currently flying (t/f)             player().ufo.active
    '                         score of UFO if hit                                 player().ufo.score
    '                         time to wait in between UFO showings (23 to 27 sec) player().ufo.pause
    Keydown As Integer '      player is holding a key down (t/f)                  player().keydown
End Type
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------+
Type SHIELDS '                shield properties                                                                                                                         | SHIELDS |
    rect As RECT '            shield coordinates                                  shield(player,x).rect                                                                 +---------+
    Image As Long '           damaged shield image                                shield(player,x).image
End Type
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Type INVADERS '               invader properties                                                                                                                       | INVADERS |
    rect As RECT '            invader coordinates                                 invader(player,column,row).rect                                                      +----------+
    Active As Integer '       invader active (t/f)                                invader(player,column,row).active
    cell As Integer '         invader image animation cell                        invader(player,column,row).cell
    Image As Integer '        invader image '                                     invader(player,column,row).image
    Width As Integer '        invader width                                       invader(player,column,row).width
    Score As Integer '        invader score                                       invader(player,column,row).score
End Type
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
Type DROPCOLUMN '             bomb column properties                                                                                                                 | DROPCOLUMN |
    Pause As Integer '        time to wait before dropping bomb in column         dropcolumn().pause           (count down timer)                                    +------------+
    Row As Integer '          row that contains bottom invader (0 for none)       dropcolumn().row
End Type
'------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------+
Dim Player(2) As PLAYER '           player settings                                                                                                          | Declared Variables |
Dim Invader(2, 11, 5) As INVADERS ' 55 invaders (player,column,row)                                                                                          +--------------------+
Dim DropColumn(11) As DROPCOLUMN '  11 columns for bomb drops
Dim Bomb(3) As BOMB '               invader bombs dropping
Dim UFO(2) As UFO '                 UFO settings
Dim IMG As IMAGES '                 images
Dim SND As SOUNDS '                 sounds
Dim Display As DISPLAY '            display screens
Dim Options As OPTIONS '            player selectable options
Dim Game As GAME '                  current game settings
Dim Font(255) As Long '             game font characters
Dim IMG_Invader(3, 1) As Long '     invader images and animation cells (image, cell)
Dim IMG_Bomb(3, 3) As Long '        bomb images and animation cells (image, cell)
Dim IMG_Ship(-1 To 1) As Long '     images of player ship (-1,1 explosion, 0 intact)
Dim Shield(2, 6) As SHIELDS '       player shield images (player, shield)
'                                                                                                                                                             +-------------------+
'                                                                                                                                                             | MAIN CODE SECTION |
'-------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------+
LoadAssets '                                     load the games graphic and sound files                                                                       |   MAIN GAME LOOP  |
LoadOptions '                                    load the saved game options                                                                                  +-------------------+
Initialize '                                     initialize all game variables
Do '                                             begin game play loop
    If Options.FreePlay Then Game.Credits = 99 ' fill the game with coins if set to free play
    InsertCoin '                                 allow the player to insert coins (skipped if free play)
    SelectPlayers '                              select the number of players and play a game
Loop '                                           loop back forever
'                                                                                                                                                     +---------------------------+
'                                                                                                                                                     |    END MAIN GAME LOOP     |
'-----------------------------------------------------------------------------------------------------------------------------------------------------+---------------------------+
'                                                                                                                                                     | SUBROUTINES AND FUNCTIONS |
'                                                                                                                                                     +---------------------------+
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Sub PlayGame (Players As Integer) '                                                                                                                                    | PlayGame |
    '+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
    '| Plays a 1 or 2 player game of Space Invaders                                                                                                                               |
    '| Players - number of players (1 or 2)                                                                                                                                       |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER ' need access to shared variables
    Shared Game As GAME
    Shared UFO() As UFO
    Shared SND As SOUNDS
    Dim KeyPress As Integer '   keypress in slow text
    Dim p As Integer '          current player

    StartNewGame '                                                                                         reset variables to start a new game
    Game.Players = Players '                                                                               record the number of players passed in
    p = Game.Player '                                                                                      get the current player
    If Players = 1 Then Player(2).GameOver = TRUE '                                                        kill off player 2 if a one player game
    GetReady '                                                                                             inform player 1 to get ready
    Do '                                                                                                   begin main game loop
        Do '                                                                                               begin game level loop
            _Limit 60 '                                                                                    game runs at 60 frames per second
            ClearDisplay INGAME '                                                                          clear the display
            If Game.Pause.Level Then '                                                                     is game paused for a level change?
                Game.Pause.Level = Game.Pause.Level - 1 '                                                  yes, decrement pause count down timer
                If Game.Pause.Level = 0 Then '                                                             has the count down finished?
                    ResetBombs '                                                                           yes, reset the bombs
                    DrawShields NEWLEVEL '                                                                 restore player shields for next level
                End If
            End If
            If Players = 2 Then '                                                                          is this a 2 player game?
                DrawScore BOTHPLAYERS, INGAME '                                                            yes, display both scores on screen
            Else '                                                                                         no, this is a 1 player game
                DrawScore PLAYER1, INGAME '                                                                display just player 1's score
            End If
            MoveInvaders p, INGAME '                                                                       move the invaders
            DrawInvaders '                                                                                 draw the invaders to the screen
            DrawShields INGAME '                                                                           draw the player's shields
            DrawUFO '                                                                                      draw the UFO when active
            DrawShip '                                                                                     draw the player's ship
            DrawLaser '                                                                                    draw the player's laser when active
            DrawBombs '                                                                                    draw the invader bombs when active
            DrawShipsRemaining '                                                                           draw the number of ships the player has remaining
            UpdateDisplay INGAME '                                                                         update the display with all the changes
            If _KeyDown(27) Or _Exit Then ExitGame '                                                       exit the game if the player presses ESC
        Loop Until Player(p).Laser.Hit.Count = 55 Or Player(p).Ship.Dead Or Game.Landed '                  leave when level finished or player dead
        If Game.Landed Then '                                                                              did the invaders land?
            Player(p).Ship.Dead = TRUE '                                                                   yes, the player is dead
            Player(p).Ship.DeadX = Player(p).Ship.rect.x1 '                                                the player died at this location
            _SndPlay SND.PlayerHit '                                                                       play the player death sound
            Player(p).Ship.Remain = 1 '                                                                    take all ships away from player
            Game.Landed = FALSE '                                                                          reset for 2nd player if needed
        End If
        If Player(p).Laser.Hit.Count = 55 Then '                                                           did the player shoot all of the invaders?
            Game.Pause.Level = 120 '                                                                       yes, pause for 2 seconds between levels
            StartNewLevel '                                                                                reset variables for a new level
        ElseIf Player(p).Ship.Dead Then '                                                                  no, is the player dead?
            ResetBombs '                                                                                   yes, reset the bombs
            If Game.Pause.Level Then '                                                                     did the player die between level changes?
                Game.Pause.Level = 0 '                                                                     yes, stop the level pause count down
                DrawShields NEWLEVEL '                                                                     restore the player's shields for the new level
            End If
            Player(p).Ship.Remain = Player(p).Ship.Remain - 1 '                                            take a ship away from player
            Game.Pause.Die = 180 '                                                                         3 second pause after player dies
            Player(p).Laser.Active = FALSE '                                                               deactivate the player's laser
            Player(p).UFO = UFO(p) '                                                                       save the player's UFO state
            If UFO(p).Active And Players = 2 Then '                                                        is the UFO still active in a 2 player game?
                UFO(p).Active = FALSE '                                                                    yes, deactivate the UFO
                _SndStop SND.UFOFlying '                                                                   stop the UFO sound
            End If
            Do '                                                                                           begin player death pause loop
                _Limit 60 '                                                                                sequence will run at 60 frames per second
                ClearDisplay INGAME '                                                                      clear the display
                If Players = 1 Then '                                                                      is this a 1 player game?
                    DrawScore PLAYER1, INGAME '                                                            yes, just draw player 1's score
                    If Player(1).Ship.Remain > 0 Then '                                                    does the player have any ships remaining?
                        DrawUFO '                                                                          yes, keep the UFO flying during pause
                    Else '                                                                                 no, player 1's game is about to end
                        _SndStop SND.UFOFlying '                                                           stop the UFO sound if it happens to be playing
                    End If
                Else '                                                                                     no, this is a 2 player game
                    DrawScore BOTHPLAYERS, INGAME '                                                        draw both player's scores to the screen
                End If
                DrawInvaders '                                                                             draw the invaders without moving
                DrawShields INGAME '                                                                       draw the player's current shields
                DrawShipsRemaining '                                                                       draw the number of ships the player has remaining
                If Game.Pause.Die = 1 Then '                                                               is this the last frame of the death pause?
                    If Player(p).Ship.Remain = 0 Then '                                                    yes, is the player out of ships?
                        If Players = 1 Then '                                                              yes, is this a 1 player game?
                            DrawScore PLAYER1, INGAME '                                                    yes, draw player 1's score
                            SlowText 6, 9, "GAME OVER", INGAME, KeyPress '                                 slowly tell player 1 that the game is over
                        Else '                                                                             no, this is a 2 player game
                            DrawScore BOTHPLAYERS, INGAME '                                                draw both player scores to the screen
                            SlowText 6, 5, "GAME OVER PLAYER<" + _Trim$(Str$(p)) + ">", INGAME, KeyPress ' slowly tell the current player that the game is over
                        End If
                        Player(p).GameOver = TRUE '                                                        the player's game is over
                        Sleep 2 '                                                                          pause for 2 seconds to let it sink in
                    Else '                                                                                 no, the player has at least 1 ship remaining
                        Player(p).Ship.Dead = FALSE '                                                      bring the player back to life
                    End If
                End If
                DrawShip '                                                                                 draw the player's ship blowing up
                UpdateDisplay INGAME '                                                                     update the display with all the changes made
                Game.Pause.Die = Game.Pause.Die - 1 '                                                      decrement the death pause count down timer
                If _KeyDown(27) Or _Exit Then ExitGame '                                                   leave the game if the player presses ESC
            Loop Until Game.Pause.Die = 0 '                                                                leave the death loop when the count down has completed
            If Players = 2 And (Player(1).GameOver = FALSE Or Player(2).GameOver = FALSE) Then '           is this a 2 player game with at least 1 player still active?
                Do '                                                                                       yes, begin next player search loop
                    p = p + 1 '                                                                            increment the player number
                    If p > 2 Then p = 1 '                                                                  return back to player 1 if needed
                Loop Until Player(p).Ship.Dead = FALSE '                                                   leave the loop when a live player is found
                Game.Player = p '                                                                          record the new current player
                GetReady '                                                                                 tell the player to get ready
                UFO(p) = Player(p).UFO '                                                                   restore the UFO settings
                If UFO(p).Active Then _SndLoop SND.UFOFlying '                                             restart the UFO sound if the UFO happens to be flying
            End If
        End If
    Loop Until Player(1).GameOver And Player(2).GameOver '                                                 leave when both players have exhaused their ships
    _KeyClear '                                                                                            clear all keyboard buffers
    KeyPress = GetKey(NEWGAME) '                                                                           clear getkey buffer
    SaveOptions '                                                                                          save the options in case a new high score was achieved

End Sub
'--------------------------------------------------------------------------------------------------------------------------------+---------------------------------+--+-----------+
Sub DrawBombs () '                                                                                                               | COLLISION: Bomb and Player Ship |  | DrawBombs |
    '+---------------------------------------------------------------------------------------------------------------------------+---------------------------------+--+-----------+
    '| Manages invader bombs and collisions between bombs and the player's ship                                                                                                   |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Invader() As INVADERS '          need access to shared variables
    Shared Bomb() As BOMB
    Shared IMG_Bomb() As Long
    Shared DropColumn() As DROPCOLUMN
    Shared IMG As IMAGES
    Shared Game As GAME
    Shared Player() As PLAYER
    Shared Shield() As SHIELDS
    Shared SND As SOUNDS
    Dim b As Integer '                      bomb counter
    Dim c As Integer '                      column counter
    Dim p As Integer '                      current player

    p = Game.Player '                                                                                   get current player
    Do '                                                                                                begin active bomb loop
        b = b + 1 '                                                                                     increment bomb counter
        If Bomb(b).Active Then '                                                                        is this bomb falling?
            If Bomb(b).Hit.Shield Then '                                                                yes, has the bomb hit a shield?
                Bomb(b).Hit.Shield = Bomb(b).Hit.Shield - 1 '                                           yes, decrement count down timer
                _PutImage (Bomb(b).Hit.ShieldX, Bomb(b).Hit.ShieldY), IMG.BombHit '                     show bomb explosion
                If Bomb(b).Hit.Shield = 0 Then Bomb(b).Active = FALSE
            ElseIf Bomb(b).Miss Then '                                                                  did bomb miss and hit top of screen?
                Bomb(b).Miss = Bomb(b).Miss - 1 '                                                       yes, decrement count down timer
                _PutImage (Bomb(b).rect.x1 - 1, Bomb(b).rect.y1), IMG.BombHit '                         show bomb explosion image
                If Bomb(b).Miss = 0 Then Bomb(b).Active = FALSE '                                       deactivate bomb when count down complete
            Else '                                                                                      no, bomb is stil falling
                Bomb(b).rect.y1 = Bomb(b).rect.y1 + 1 + Game.Frame Mod 2 '                              drop bomb at 90 FPS
                Bomb(b).rect.y2 = Bomb(b).rect.y2 + 1 + Game.Frame Mod 2
                Bomb(b).Cell = Bomb(b).Cell + 1 '                                                       increment animation cell
                If Bomb(b).Cell = 4 Then Bomb(b).Cell = 1 '                                             reset animation cell when needed
                _PutImage (Bomb(b).rect.x1, Bomb(b).rect.y1), IMG_Bomb(Bomb(b).Image, Bomb(b).Cell) '   show bomb on screen
                If Bomb(b).rect.y1 >= 228 Then '                                                        has bomb hit bottom of screen?
                    Bomb(b).Miss = 5 '                                                                  yes, set count down timer
                Else '                                                                                  no, bomb is still on the sceen
                    '******************************************************
                    '** Check for collision between bomb and player ship **
                    '******************************************************
                    If Not GODMODE Then '                                                               is developer in god mode?
                        If Player(p).Ship.Dead = FALSE Then '                                           no, is the player ship active?
                            If RectCollide(Player(p).Ship.rect, Bomb(b).rect) Then '                    yes, has the bomb hit the player's ship?
                                Player(p).Ship.Dead = TRUE '                                            yes, player is dead
                                Player(p).Ship.DeadX = Player(p).Ship.rect.x1 '                         record where on screen ship was hit
                                _SndPlay SND.PlayerHit '                                                play ship explosion sound
                            End If
                        End If
                    End If
                End If
            End If
        End If
    Loop Until b = Player(p).MaxBombs '                                                                 leave when all bombs checked
    If Game.Pause.Level Then Exit Sub '                                                                 leave subroutine if game is paused between levels
    Do '                                                                                                begin bomb drop column loop
        c = c + 1 '                                                                                     increment column counter
        If DropColumn(c).Pause Then '                                                                   is this column ready to have a bomb dropped?
            DropColumn(c).Pause = DropColumn(c).Pause - 1 '                                             no, decrement pause timer
        Else '                                                                                          yes, the pause period has ended
            If DropColumn(c).Row Then '                                                                 is there an invader in this column?
                If Int(Rnd * 11) = 1 Then '                                                             yes, should a bomb be randomly dropped?
                    b = 0 '                                                                             yes, reset bomb counter
                    Do '                                                                                begin inactive bomb search
                        b = b + 1 '                                                                     increment bomb counter
                    Loop Until Bomb(b).Active = FALSE Or b = Player(p).MaxBombs '                       leave when inactive bomb found or no inactive bombs
                    If Bomb(b).Active = FALSE Then '                                                    is this bomb inactive?
                        Bomb(b).Active = TRUE '                                                         yes, activate the bomb
                        Bomb(b).Image = Int(Rnd * 3) + 1 '                                              set a random bomb image
                        Bomb(b).Cell = 1 '                                                              reset the animation cell
                        Bomb(b).rect.x1 = Invader(p, c, DropColumn(c).Row).rect.x1 + Invader(p, c, DropColumn(c).Row).Width / 2 - 1 ' calculate bomb location on screen
                        Bomb(b).rect.y1 = Invader(p, c, DropColumn(c).Row).rect.y2 - 2
                        Bomb(b).rect.x2 = Bomb(b).rect.x1 + 2
                        Bomb(b).rect.y2 = Bomb(b).rect.y1 + 7
                        DropColumn(c).Pause = Int(Rnd * 15) + 55 - Player(p).Laser.Hit.Count '          reset the pause timer for this column
                    End If
                End If
            End If
        End If
    Loop Until c = 11 '                                                                                 leave when all columns checked

End Sub
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
Sub ResetBombs () '                                                                                                                                                  | ResetBombs |
    '+---------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
    '| Resets the bombs and columns status                                                                                                                                        |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared DropColumn() As DROPCOLUMN ' need access to shared variables
    Shared Bomb() As BOMB
    Dim c As Integer '                  column counter

    Do '                                            begin column loop
        c = c + 1 '                                 increment column counter
        DropColumn(c).Pause = 60 + Int(Rnd * 240) ' reset column pause timer
        If c < 4 Then Bomb(c) = Bomb(0) '           reset status of bomb
    Loop Until c = 11 '                             leave when all columns processed

End Sub
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
Function RectCollide (Rect1 As RECT, Rect2 As RECT) '                                                                                                               | RectCollide |
    '+--------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
    '| Detects a collision between two rectangular objects                                                                                                                        |
    '| Rect1 - the first set of rectangular coordinates                                                                                                                           |
    '| Rect2 - the second set of rectangular coordinates                                                                                                                          |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    RectCollide = FALSE '                        assume no collision
    If Rect1.x2 >= Rect2.x1 Then
        If Rect1.x1 <= Rect2.x2 Then
            If Rect1.y2 >= Rect2.y1 Then
                If Rect1.y1 <= Rect2.y2 Then
                    RectCollide = TRUE '         a collision has occurred
                End If
            End If
        End If
    End If

End Function
'--------------------------------------------------------------------------------------------------------------------------------------+---------------------------+--+-----------+
Sub DrawLaser () '                                                                                                                     | COLLISION: Laser and Bomb |  | DrawLaser |
    '+---------------------------------------------------------------------------------------------------------------------------------+---------------------------+--+-----------+
    '| Manages the player's laser and collisions between the laser and bombs                                                                                                      |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER ' need access to shared variables
    Shared SND As SOUNDS
    Shared IMG As IMAGES
    Shared Bomb() As BOMB
    Shared Game As GAME
    Dim b As Integer '          bomb counter
    Dim p As Integer '          current player

    p = Game.Player '                                                                                   get current player
    If Not _KeyDown(32) Then Player(p).Keydown = FALSE '                                                remember when player releases space bar
    If Player(p).Laser.Active = FALSE Then '                                                            is the player's laser flying?
        If _KeyDown(32) And Player(p).Keydown = FALSE Then '                                            no, did the player press the space bar after releasing it?
            Player(p).Laser.Active = TRUE '                                                             yes, activate the laser
            Player(p).Laser.ShotsFired = Player(p).Laser.ShotsFired + 1 '                               increment the shots fired counter
            Player(p).Keydown = TRUE '                                                                  remember that player is holding the space bar down
            Player(p).Laser.rect.x1 = Player(p).Ship.rect.x1 + 6 '                                      calculate the position of the laser
            Player(p).Laser.rect.x2 = Player(p).Laser.rect.x1
            Player(p).Laser.rect.y1 = 216
            Player(p).Laser.rect.y2 = 219
            _SndPlay SND.Laser '                                                                        play the laser fired sound
        End If
    Else '                                                                                              yes, the player's laser is active
        If Player(p).Laser.Miss Then '                                                                  did the player's laser hit the top of screen?
            Player(p).Laser.Miss = Player(p).Laser.Miss - 1 '                                           yes, decrement count down timer
            _PutImage (Player(p).Laser.rect.x1 - 4, 24), IMG.LaserHit '                                 show the laser explosion
            If Player(p).Laser.Miss = 0 Then Player(p).Laser.Active = FALSE '                           deactivate the laser when count down complete
        ElseIf Player(p).Laser.Hit.Invader Then '                                                       no, did the laser hit an invader?
            Player(p).Laser.Hit.Invader = Player(p).Laser.Hit.Invader - 1 '                             yes, decrement the count down timer
            _PutImage (Player(p).Laser.Hit.InvaderX, Player(p).Laser.Hit.InvaderY), IMG.InvaderHit '    show invader explosion
            If Player(p).Laser.Hit.Invader = 0 Then Player(p).Laser.Active = FALSE '                    deactivate the laser whn count down complete
        ElseIf Player(p).Laser.Hit.Bomb Then '                                                          no, did the laser hit a bomb?
            Player(p).Laser.Hit.Bomb = Player(p).Laser.Hit.Bomb - 1 '                                   yes, decrement the count down timer
            _PutImage (Player(p).Laser.Hit.BombX, Player(p).Laser.Hit.BombY), IMG.BombHit '             show bomb explosion
            If Player(p).Laser.Hit.Bomb = 0 Then '                                                      has the count down timer ended?
                Player(p).Laser.Active = FALSE '                                                        yes, deactivate the player's laser
            End If
        ElseIf Player(p).Laser.Hit.Shield Then '                                                        no, did the laser hit a shield?
            Player(p).Laser.Hit.Shield = Player(p).Laser.Hit.Shield - 1 '                               yes, decrement the count down timer
            _PutImage (Player(p).Laser.Hit.ShieldX, Player(p).Laser.Hit.ShieldY), IMG.LaserHit '        show laser explosion
            If Player(p).Laser.Hit.Shield = 0 Then Player(p).Laser.Active = FALSE '                     deactivate the laser when count down complete
        Else '                                                                                          no, laser is still flying
            Player(p).Laser.rect.y1 = Player(p).Laser.rect.y1 - 4 '                                     move the laser upward
            Player(p).Laser.rect.y2 = Player(p).Laser.rect.y2 - 4
            Line (Player(p).Laser.rect.x1, Player(p).Laser.rect.y1)-(Player(p).Laser.rect.x2, Player(p).Laser.rect.y2 + 3), WHITE ' draw the laser
            If Player(p).Laser.rect.y1 = 24 Then '                                                      did the laser hit the top of screen?
                Player(p).Laser.Miss = 10 '                                                             yes, set the count down timer
            Else '                                                                                      no, laser still on sreen
                '************************************************
                '** Check for collision between laser and bomb **
                '************************************************
                Do '                                                                                    begin bomb check loop
                    b = b + 1 '                                                                         increment bomb counter
                    If Bomb(b).Active And Player(p).Laser.Active Then '                                 is this bomb falling and player laser active?
                        If RectCollide(Player(p).Laser.rect, Bomb(b).rect) Then '                       yes, did the bomb hit the laser?
                            Player(p).Laser.Hit.Bomb = 5 '                                              yes, set the count down timer
                            Player(p).Laser.Hit.BombX = Bomb(b).rect.x1 - 2 '                           record the location of the collision
                            Player(p).Laser.Hit.BombY = Bomb(b).rect.y1 + 5
                            If Int(Rnd * 2) = 1 Then Bomb(b).Active = FALSE '                           randomly deactivate the bomb
                        End If
                    End If
                Loop Until b = Player(p).MaxBombs Or Player(p).Laser.Hit.Bomb '                         leave when all bombs checked
            End If
        End If
    End If

End Sub
'-----------------------------------------------------------------------------------------------------------------------+---------------------------------------+--+--------------+
Sub DrawInvaders () '                                                                                                   | COLLISION:Invader and Laser or Shield |  | DrawInvaders |
    '+------------------------------------------------------------------------------------------------------------------+---------------------------------------+--+--------------+
    '| Draws the active invaders to the screen and handles collisions between invaders and the player's laser and invaders and shields                                            |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Invader() As INVADERS '     need access to shared variables
    Shared DropColumn() As DROPCOLUMN
    Shared IMG_Invader() As Long
    Shared Shield() As SHIELDS
    Shared Display As DISPLAY
    Shared Options As OPTIONS
    Shared Player() As PLAYER
    Shared SND As SOUNDS
    Shared Game As GAME
    Dim x As Integer '                 invader column counter
    Dim y As Integer '                 invader row counter
    Dim s As Integer '                 shield counter
    Dim shx As Integer '               location of invader and shield collision
    Dim shy As Integer
    Dim p As Integer '                 current player

    If Game.Pause.Level Then Exit Sub '                                                                leave subroutine if game paused between levels
    p = Game.Player '                                                                                  get current player
    Do '                                                                                               begin invader column loop
        x = x + 1 '                                                                                    increment column counter
        y = 0 '                                                                                        reset row counter
        DropColumn(x).Row = 0 '                                                                        assume no invaders in this column
        Do '                                                                                           begin invader row loop
            y = y + 1 '                                                                                increment row counter
            If Invader(p, x, y).Active Then '                                                          is this invader active?
                _PutImage (Invader(p, x, y).rect.x1, Invader(p, x, y).rect.y1), IMG_Invader(Invader(p, x, y).Image, Invader(p, x, y).cell) ' yes, draw the invader
                If y > DropColumn(x).Row Then DropColumn(x).Row = y '                                  record the lowest invader in the column
                '********************************************
                '** Check for invader and shield collision **
                '********************************************
                If Invader(p, x, y).rect.y1 > 191 And Invader(p, x, y).rect.y1 < 209 Then '            is the invader in the shield area?
                    s = 0 '                                                                            yes, reset shield counter
                    Do '                                                                               begin shield loop
                        s = s + 1 '                                                                    increment shield counter
                        If RectCollide(Invader(p, x, y).rect, Shield(p, s).rect) Then '                is the invader colliding with a shield?
                            shx = Invader(p, x, y).rect.x1 - Shield(p, s).rect.x1 '                    yes, record the location of the collision
                            shy = Invader(p, x, y).rect.y1 - 192
                            _Dest Shield(p, s).Image '                                                 draw on the shield image
                            Line (shx, shy)-(shx + Invader(p, x, y).Width - 1, shy + 7), BLACK, BF '   remove portion of shield where collision occurring
                            _Dest Display.WorkScreen '                                                 return to drawing on work display
                        End If
                    Loop Until s = Options.Shields '                                                   leave when all shields have been checked
                ElseIf Invader(p, x, y).rect.y1 = 216 Then '                                           has the invader landed at ship location?
                    '**************************************
                    '** Invader reached bottom of screen **
                    '**************************************
                    Game.Landed = TRUE '                                                               yes, remember that invader has landed
                End If
                '*******************************************
                '** Check for invader and laser collision **
                '*******************************************
                If Player(p).Laser.Active Then '                                                       is the player's laser flying?
                    If RectCollide(Player(p).Laser.rect, Invader(p, x, y).rect) Then '                 yes, has the laser collided with an invader?
                        Player(p).Score = Player(p).Score + Invader(p, x, y).Score '                   yes, add the invader's score to the player's score
                        Player(p).Laser.Hit.Count = Player(p).Laser.Hit.Count + 1 '                    increment the player's invader hit counter
                        If Player(p).Laser.Hit.Count = 27 Then '                                       have half the invaders been destroyed?
                            If Player(p).MaxBombs < 3 Then '                                           yes, are the maximum number of bombs dropping?
                                Player(p).MaxBombs = Player(p).MaxBombs + 1 '                          no, increase the amount of bombs invaders allowed to drop
                            End If
                        End If
                        Player(p).Laser.Hit.Invader = 5 '                                              set count down timer
                        Player(p).Laser.Hit.InvaderX = Invader(p, x, y).rect.x1 - ((14 - Invader(p, x, y).Width) \ 2) ' record where the collision occurred
                        Player(p).Laser.Hit.InvaderY = Invader(p, x, y).rect.y1
                        Invader(p, x, y).Active = FALSE '                                              deactivate this invader
                        _SndPlay SND.InvaderHit '                                                      play the invader explosion sound
                    End If
                End If
            End If
        Loop Until y = 5 '                                                                             leave when all rows checked
    Loop Until x = 11 '                                                                                leave whan all columns checked

End Sub
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Sub DrawShip () '                                                                                                                                                      | DrawShip |
    '+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
    '| Manages the player's ship                                                                                                                                                  |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared IMG_Ship() As Long ' need access to shared variables
    Shared Player() As PLAYER
    Shared Game As GAME
    Dim p As Integer '          current player

    p = Game.Player '                                                                                  get current player
    If Game.Pause.Die Then '                                                                           is a death pause happening?
        If Game.Frame Mod 5 = 0 Then Player(p).Ship.DeadImage = -Player(p).Ship.DeadImage '            yes, toggle the death image every 5 frames
        _PutImage (Player(p).Ship.DeadX, Player(p).Ship.rect.y1), IMG_Ship(Player(p).Ship.DeadImage) ' draw the ship death image
        If Game.Pause.Die = 1 Then '                                                                   is this the last frame of the death pause?
            Player(p).Ship.rect.x1 = 15 '                                                              yes, reset player's ship location
            Player(p).Ship.rect.x2 = 27
        End If
    Else '                                                                                             no, player is still alive
        If _KeyDown(19712) Then '                                                                      is player pressing the right arrow key?
            Player(p).Ship.rect.x1 = Player(p).Ship.rect.x1 + 1 '                                      yes, move ship to the right
            Player(p).Ship.rect.x2 = Player(p).Ship.rect.x2 + 1
        End If
        If _KeyDown(19200) Then '                                                                      is player pressing the left arrow key?
            Player(p).Ship.rect.x1 = Player(p).Ship.rect.x1 - 1 '                                      yes, move ship to the left
            Player(p).Ship.rect.x2 = Player(p).Ship.rect.x2 - 1
        End If
        If Player(p).Ship.rect.x1 < 15 Then '                                                          is the ship moving too far left?
            Player(p).Ship.rect.x1 = 15 '                                                              yes, hold ship at left side of screen
            Player(p).Ship.rect.x2 = 27
        End If
        If Player(p).Ship.rect.x2 > 207 Then '                                                         is the ship moving too far right?
            Player(p).Ship.rect.x1 = 194 '                                                             yes, hold ship at right side of screen
            Player(p).Ship.rect.x2 = 207
        End If
        _PutImage (Player(p).Ship.rect.x1, Player(p).Ship.rect.y1), IMG_Ship(0) '                      draw player ship
    End If

End Sub
'-----------------------------------------------------------------------------------------------------------------------------------------+--------------------------+--+---------+
Sub DrawUFO () '                                                                                                                          | COLLISION: Laser and UFO |  | DrawUFO |
    '+------------------------------------------------------------------------------------------------------------------------------------+--------------------------+--+---------+
    '| Manages the UFO and collisions between the UFO and player's laser                                                                                                          |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER ' need access to shared variables
    Shared UFO() As UFO
    Shared Game As GAME
    Shared IMG As IMAGES
    Shared SND As SOUNDS
    Dim p As Integer '          current player

    p = Game.Player '                                                             get current player
    If Player(p).Laser.Hit.UFO Then '                                             did the player's laser hit the UFO?
        Player(p).Laser.Hit.UFO = Player(p).Laser.Hit.UFO - 1 '                   yes, decrement count down timer
        Text Player(p).Laser.Hit.UFOX, 32, _Trim$(Str$(UFO(p).Score)) '           display the UFO score where UFO was hit
    End If
    If UFO(p).Active Then '                                                       is the UFO flying across the screen?
        If Game.Frame Mod 4 Then '                                                yes, skip every 4th frame
            UFO(p).rect.x1 = UFO(p).rect.x1 + UFO(p).Dir '                        move UFO at 45 FPS
            UFO(p).rect.x2 = UFO(p).rect.x1 + 15
        End If
        If UFO(p).rect.x1 > 199 Or UFO(p).rect.x1 < 8 Then '                      has the UFO reached the edge of screen?
            _SndStop SND.UFOFlying '                                              yes, stop the UFO sound
            UFO(p).Active = FALSE '                                               deactivate the UFO
        Else '                                                                    no, UFO is still flying
            _PutImage (UFO(p).rect.x1, UFO(p).rect.y1), IMG.UFO '                 draw the UFO
            '***********************************************
            '** Check for collision between laser and UFO **
            '***********************************************
            If Player(p).Laser.Active Then '                                      is the player's laser active?
                If RectCollide(Player(p).Laser.rect, UFO(p).rect) Then '          has the player's laser hit the UFO?
                    Select Case Int(Rnd * 3) + 1 '                                yes, set a random score value
                        Case 1
                            UFO(p).Score = 50 '                                   50 points
                        Case 2
                            UFO(p).Score = 100 '                                  100 points
                        Case 3
                            UFO(p).Score = 200 '                                  200 points
                    End Select
                    If Player(p).Laser.ShotsFired = 23 Then UFO(p).Score = 300 '  300 points if the player has fired 23 lasers
                    If Player(p).Laser.ShotsFired > 23 Then '                     has the player fired more than 23 lasers?
                        If (Player(p).Laser.ShotsFired - 23) Mod 15 = 0 Then '    every 15 laser firings afterwards?
                            UFO(p).Score = 300 '                                  yes, UFO score is again 300 points
                        End If
                    End If
                    Player(p).Score = Player(p).Score + UFO(p).Score '            add the UFO score to the player's score
                    Player(p).Laser.Hit.UFO = 60 '                                set the count down timer
                    Player(p).Laser.Hit.UFOX = UFO(p).rect.x1 + 32 '              record where the UFO was hit
                    UFO(p).Active = FALSE '                                       deactivate the UFO
                    Player(p).Laser.Active = FALSE '                              deactivate the player's laser
                    _SndStop SND.UFOFlying '                                      stop the UFO sound
                    _SndPlay SND.UFOHit '                                         play the UFO explosion sound
                End If
            End If
        End If
    Else '                                                                        no, UFO is currently inactive
        UFO(p).Pause = UFO(p).Pause - 1 '                                         decrement the UFO pause timer
        If UFO(p).Pause = 0 Then '                                                has the timer ended?
            _SndLoop SND.UFOFlying '                                              yes, play the UFO flying sound
            UFO(p).Active = TRUE '                                                activate the UFO
            UFO(p).Pause = 1500 + Int(Rnd * 120) - Int(Rnd * 120) '               reset the UFO pause for 23 to 27 seconds
            If Int(Rnd * 2) = 1 Then '                                            which direction should UFO come from?
                UFO(p).Dir = 1 '                                                  UFO will travel left to right
                UFO(p).rect.x1 = 8 '                                              position UFO at left of screen
            Else
                UFO(p).Dir = -1 '                                                 UFO will travel right to left
                UFO(p).rect.x1 = 199 '                                            position UFO at right of screen
            End If
        End If
    End If

End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
Sub MoveInvaders (p As Integer, Mode As Integer) Static '                                                                                                          | MoveInvaders |
    '+-------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
    '| Manages the wave motion of invaders across the screen                                                                                                                      |
    '| p    - current player                                                                                                                                                      |
    '| Mode - signal to clear variables for a movement reset (CLEARVARIABLES or -1)                                                                                               |
    '| NOTE: This subroutine retains values between calls (STATIC)                                                                                                                |
    '|                                                                                                                                                                            |
    '| Moves the invaders across the screen by simulating the "strobing" effect of an Intel 8080 barely able to keep up with the graphics. Only one invader is updated per frame  |
    '| of the game to achieve the slow CPU effect. As fewer invaders are alive this subroutine will simulate the speeding up effect of the invaders as if an 8080 CPU has less    |
    '| work to do.                                                                                                                                                                |
    '|                                                                                                                                                                            |
    '| From: https://en.wikipedia.org/wiki/Space_Invaders                                                                                                                         |
    '|                                                                                                                                                                            |
    '| "While programming the game, Nishikado discovered that the processor was able to render the alien graphics faster the fewer were on screen. Rather than design the game to |
    '|  compensate for the speed increase, he decided to keep it as a challenging gameplay mechanic."                                                                             |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Invader() As INVADERS ' need access to shared variables
    Shared Player() As PLAYER
    Shared SND As SOUNDS
    Shared Game As GAME
    Dim c(2) As Integer '          column counter
    Dim r(2) As Integer '          row counter
    Dim Down(2) As Integer '       invader to move down flag
    Dim Edge(2) As Integer '       invader hit edge of screen flag
    Dim Beat(2) As Integer '       current heart throb sound to play

    If Mode = CLEARVARIABLES Or Game.Pause.Level Then '                                                       time to reset the movement variables?
        c(p) = 0 '                                                                                            yes, reset all movement variables
        r(p) = 0
        Down(p) = FALSE
        Edge(p) = FALSE
        Beat(p) = 0
        Exit Sub '                                                                                            leave the subroutine
    End If
    Do '                                                                                                      begin active invader search loop
        c(p) = c(p) + 1 '                                                                                     increment column counter
        If c(p) = 12 Then '                                                                                   has the last column been reached?
            c(p) = 1 '                                                                                        yes, reset the column counter
            r(p) = r(p) - 1 '                                                                                 decrement the row counter
        End If
        If r(p) = 0 Then '                                                                                    has the top row been reached?
            r(p) = 5 '                                                                                        yes, reset the row counter
            If Edge(p) Then '                                                                                 has the invader reached the edge of the screen?
                Down(p) = TRUE '                                                                              yes, flag the invader for a downward movement
                Edge(p) = FALSE '                                                                             reset the edge detection flag
            ElseIf Down(p) Then '                                                                             no, has the invader been flagged for a downward movement?
                Down(p) = FALSE '                                                                             yes, reset the downward movement flag
                Player(p).idir = -Player(p).idir '                                                            reverse the direction of the invaders
            End If
            Beat(p) = Beat(p) + 1 '                                                                           increment the heart throb sound counter
            If Beat(p) = 5 Then Beat(p) = 1 '                                                                 reset the counter when needed
            Select Case Beat(p) '                                                                             which sound to play?
                Case 1
                    _SndPlay SND.Beat1
                Case 2
                    _SndPlay SND.Beat2
                Case 3
                    _SndPlay SND.Beat3
                Case 4
                    _SndPlay SND.Beat4
            End Select
        End If
    Loop Until Invader(p, c(p), r(p)).Active '                                                                leave when an active invader found
    Invader(p, c(p), r(p)).cell = 1 - Invader(p, c(p), r(p)).cell '                                           toggle the invader animation cell
    If Down(p) Then '                                                                                         is this invader flagged for downward movement?
        Invader(p, c(p), r(p)).rect.y1 = Invader(p, c(p), r(p)).rect.y1 + 8 '                                 yes, move the invader down one row
        Invader(p, c(p), r(p)).rect.y2 = Invader(p, c(p), r(p)).rect.y2 + 8
    Else '                                                                                                    no, move the invader right or left
        Invader(p, c(p), r(p)).rect.x1 = Invader(p, c(p), r(p)).rect.x1 + Player(p).idir '                    move the invader horizontally across screen
        Invader(p, c(p), r(p)).rect.x2 = Invader(p, c(p), r(p)).rect.x2 + Player(p).idir
        If Invader(p, c(p), r(p)).rect.x1 <= 8 Or Invader(p, c(p), r(p)).rect.x2 >= 215 Then Edge(p) = TRUE ' set the edge flag when an invader reaches side of screen
    End If

End Sub
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
Sub ResetInvaders (p As Integer) '                                                                                                                                | ResetInvaders |
    '+------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
    '| Resets the invader start positions for the current level of the player                                                                                                     |
    '| p - player to reset invaders for                                                                                                                                           |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Invader() As INVADERS ' need access to shared variables
    Shared Player() As PLAYER
    Dim r As Integer '             row counter
    Dim c As Integer '             column counter
    Dim Level As Integer '         current player level

    Level = Player(p).Level '                                                                   get current player level
    If Level > 5 Then Level = 5 '                                                               keep the level at 5
    Do '                                                                                        begin invader row loop
        r = r + 1 '                                                                             increment row counter
        c = 0 '                                                                                 reset column counter
        Do '                                                                                    begin invader column loop
            c = c + 1 '                                                                         increment column counter
            Invader(p, c, r).Active = TRUE '                                                    activate this invader
            Invader(p, c, r).rect.x1 = (16 * c) + 8 - Invader(p, c, r).Width \ 2 '              calculate position of invader on screen
            Invader(p, c, r).rect.x2 = Invader(p, c, r).rect.x1 + Invader(p, c, r).Width - 1
            Invader(p, c, r).rect.y1 = (32 + (r * 16)) + Level * 16
            Invader(p, c, r).rect.y2 = Invader(p, c, r).rect.y1 + 7
            Invader(p, c, r).cell = 0 '                                                         reset invader animation cell
        Loop Until c = 11 '                                                                     leave when all columns checked
    Loop Until r = 5 '                                                                          leave when all rows checked

End Sub
'--------------------------------------------------------------------------------------------------------------------------+-------------------------------------+--+-------------+
Sub DrawShields (Mode As Integer) '                                                                                        | COLLISION: Shield and Laser or Bomb |  | DrawShields |
    '+---------------------------------------------------------------------------------------------------------------------+-------------------------------------+--+-------------+
    '| Draws the player's shields to the screen and handles collisions between the shields and lasers or bombs                                                                    |
    '| Mode - How to handle drawing of the shields                                                                                                                                |
    '|        -1 (NEWGAME)  - reset the shields for both players                                                                                                                  |
    '|         0 (NEWLEVEL) - reset the shields for the current player                                                                                                            |
    '|         5 (INGAME)   - manage the shields during game play                                                                                                                 |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    Shared Options As OPTIONS '  need access to shared variables
    Shared IMG As IMAGES
    Shared Shield() As SHIELDS
    Shared Player() As PLAYER
    Shared Display As DISPLAY
    Shared Bomb() As BOMB
    Shared Game As GAME
    Dim x As Integer '            shield counter
    Dim p As Integer '            current player
    Dim lx As Integer '           location of laser hitting shield
    Dim ly As Integer
    Dim scan As Integer '         pixel perfect scanner
    Dim rndx As Integer '         random variance added to hit locations
    Dim rndy As Integer
    Dim b As Integer '            bomb counter
    Dim shx As Integer '          location of hit on shield
    Dim shy As Integer

    p = Game.Player '                                                                                     get current player
    x = 1 '                                                                                               set shield counter
    Do '                                                                                                  begin shield loop
        Select Case Mode '                                                                                which mode was requested?
            Case NEWGAME '                                                                                a new game is beginning
                _PutImage , IMG.Shield, Shield(PLAYER1, x).Image '                                        reset the shield images with undamaged images
                _PutImage , IMG.Shield, Shield(PLAYER2, x).Image
            Case NEWLEVEL '                                                                               a new level is beginning for the current player
                _PutImage , IMG.Shield, Shield(p, x).Image '                                              reset the shield images with undamaged images
            Case INGAME '                                                                                 a game level is currently being played
                _SetAlpha 0, BLACK, Shield(p, x).Image '                                                  set the transparency color of shields
                _PutImage (Shield(p, x).rect.x1, 192), Shield(p, x).Image '                               draw the player's shield to the screen
                '******************************************
                '** Check for laser and shield collision **
                '******************************************
                If Player(p).Laser.Active And Player(p).Laser.Hit.Shield = 0 Then '                       if the player's laser flying and didn't hit a shield?
                    If RectCollide(Player(p).Laser.rect, Shield(p, x).rect) Then '                        yes, did the laser hit the shield?
                        lx = Player(p).Laser.rect.x1 - Shield(p, x).rect.x1 '                             yes, remember location of collision
                        ly = Player(p).Laser.rect.y1 - 192
                        scan = 0 '                                                                        reset pixel perfect scanner
                        _Source Shield(p, x).Image '                                                      work with shield image
                        _Dest Shield(p, x).Image
                        Do '                                                                              begin pixel perfect collision loop
                            If Point(lx, ly + scan) = WHITE Then '                                        did this part of laser hit the shiled?
                                rndx = Int(Rnd * 2) - Int(Rnd * 2) '                                      yes, set some random variance in collision location
                                rndy = Int(Rnd * 2)
                                Player(p).Laser.Hit.ShieldX = Player(p).Laser.rect.x1 - 4 + rndx '        record location of collision on screen
                                Player(p).Laser.Hit.ShieldY = Player(p).Laser.rect.y1 - 3 + scan + rndy '
                                _PutImage (lx - 4 + rndx, ly - 3 + scan + rndy), IMG.LaserHitMask '       damage the shields
                                Player(p).Laser.Hit.Shield = 5 '                                          set count down timer
                            End If
                            scan = scan + 1 '                                                             move to next pixel location on laser
                        Loop Until scan = 4 Or Player(p).Laser.Hit.Shield '                               leave when laser length scanned or a hit on shield occurred
                        _Source Display.WorkScreen '                                                      return back to the work display
                        _Dest Display.WorkScreen
                    End If
                End If
                '*****************************************
                '** Check for bomb and shield collision **
                '*****************************************
                b = 0 '                                                                                   reset bomb counter
                Do '                                                                                      begin bomb loop
                    b = b + 1 '                                                                           increment bomb counter
                    If Bomb(b).Active And Bomb(b).Hit.Shield = 0 Then '                                   is this bomb dropping and not hit a shield?
                        If RectCollide(Bomb(b).rect, Shield(p, x).rect) Then '                            yes, has the bomb hit a shield?
                            shx = Bomb(b).rect.x1 - Shield(p, x).rect.x1 '                                yes, record location of collision
                            shy = Bomb(b).rect.y1 - 192
                            _Source Shield(p, x).Image '                                                  work with shield image
                            _Dest Shield(p, x).Image
                            scan = -1 '                                                                   reset pixel perfect scanner
                            Do '                                                                          begin pixel perfect collision loop
                                If Point(shx + scan, shy) = WHITE Then '                                  did this part of bomb hit the shield?
                                    rndy = Int(Rnd * 3) '                                                 yes, set som random variance in collision location
                                    Bomb(b).Hit.ShieldX = Bomb(b).rect.x1 - 2 '                           record screen location of collision
                                    Bomb(b).Hit.ShieldY = Bomb(b).rect.y1 - 4 + scan + rndy
                                    _PutImage (shx - 2, shy - 4 + scan + rndy), IMG.BombHitMask '         damage the shields
                                    Bomb(b).Hit.Shield = 5 '                                              set countdown timer
                                End If
                                scan = scan + 1 '                                                         move to next pixel location on bomb
                            Loop Until scan = 2 Or Bomb(b).Hit.Shield '                                   leave when bomb scanned or a hit on shield occurred
                            _Source Display.WorkScreen '                                                  return back to work display
                            _Dest Display.WorkScreen
                        End If
                    End If
                Loop Until b = Player(p).MaxBombs '                                                       leave when all bombs checked
        End Select
        x = x + 1 '                                                                                       increment shield counter
    Loop Until x > Options.Shields '                                                                      leave when all shields checked

End Sub
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
Sub StartNewLevel () '                                                                                                                                            | StartNewLevel |
    '+------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
    '| Resets the variables in preparation for a new player level                                                                                                                 |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER '         need access to shared variables
    Shared DropColumn() As DROPCOLUMN
    Shared Game As GAME
    Dim p As Integer '                  current player

    p = Game.Player '                                        get current player
    Player(p).Level = Player(p).Level + 1 '                  increment player level
    If Player(p).Level = 11 Then Player(p).Level = 1 '       reset player level when level 11 reached
    Player(p).idir = 2 '                                     reset invader movement
    Player(p).Laser.Hit.Count = 0 '                          reset invader hit count
    Player(p).MaxBombs = Player(p).Level '                   calculate maximum number of invader bombs allowed
    If Player(p).MaxBombs > 3 Then Player(p).MaxBombs = 3 '  no more than 3 bombs allowed
    MoveInvaders p, CLEARVARIABLES '                         clear the invader movement variables
    ResetInvaders p '                                        reset invader locations

End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
Sub StartNewGame () '                                                                                                                                              | StartNewGame |
    '+-------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
    '| Resets the variables in preparation for a new game                                                                                                                         |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared DropColumn() As DROPCOLUMN ' need access to shared variables
    Shared Player() As PLAYER
    Shared UFO() As UFO
    Shared Game As GAME

    Randomize Timer '                      seed the RND generator
    Game.Player = 1 '                      set the current player to player 1
    Game.Landed = FALSE '                  reset the invader landed flag
    Player(1) = Player(0) '                reset player variables
    Player(2) = Player(0)
    UFO(1) = UFO(0) '                      reset UFO variables
    UFO(2) = UFO(0)
    DrawShields NEWGAME '                  restore the shield images
    ResetInvaders PLAYER1 '                reset invader locations
    ResetInvaders PLAYER2
    MoveInvaders PLAYER1, CLEARVARIABLES ' clear the invader movement variables
    MoveInvaders PLAYER2, CLEARVARIABLES
    ResetBombs
    '                                      reset the bombs and drop columns
End Sub
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
Sub Initialize () '                                                                                                                                                  | Initialize |
    '+---------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
    '+ Initializes all variables upon power up                                                                                                                                    |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER '    need access to shared variables
    Shared Invader() As INVADERS
    Shared Shield() As SHIELDS
    Shared UFO() As UFO
    Shared Bomb() As BOMB
    Shared Options As OPTIONS
    Shared Game As GAME
    Dim p As Integer '             player counter
    Dim c As Integer '             column counter
    Dim r As Integer '             row counter

    Game.Credits = 0 '                                  set in game settings
    Game.Player = 1
    Game.Players = 1
    Game.Pause.Level = 0
    Game.Pause.Die = 0
    Game.Landed = FALSE
    Bomb(0).rect.x1 = 0 '                               set default bomb settings
    Bomb(0).rect.y1 = 0
    Bomb(0).rect.x2 = 0
    Bomb(0).rect.y2 = 0
    Bomb(0).Hit.Shield = 0
    Bomb(0).Hit.ShieldX = 0
    Bomb(0).Hit.ShieldY = 0
    Bomb(0).Image = 1
    Bomb(0).Cell = 1
    Bomb(0).Active = FALSE
    Bomb(0).Miss = 0
    Bomb(1) = Bomb(0) '                                 set bomb settings to default
    Bomb(2) = Bomb(0)
    Bomb(3) = Bomb(0)
    UFO(0).Score = 0 '                                  set default UFO settings
    UFO(0).Pause = 1500
    UFO(0).Active = FALSE
    UFO(0).Dir = 1
    UFO(0).rect.x1 = 8
    UFO(0).rect.y1 = 32
    UFO(0).rect.y2 = 39
    UFO(1) = UFO(0) '                                   set UFO settings to default
    UFO(2) = UFO(0)
    Player(0).Ship.rect.y1 = 216 '                      set default player settings
    Player(0).Ship.rect.y2 = 223
    Player(0).Ship.Dead = FALSE
    Player(0).Ship.DeadX = 0
    Player(0).Ship.DeadImage = 1
    Player(0).Ship.Extra = FALSE
    Player(0).Score = 0
    Player(0).Ship.Remain = 3
    Player(0).idir = 2
    Player(0).Level = 1
    Player(0).GameOver = FALSE
    Player(0).MaxBombs = 1
    Player(0).Laser.Active = FALSE
    Player(0).Laser.ShotsFired = 0
    Player(0).Laser.Hit.Count = 0
    Player(0).Laser.Miss = 0
    Player(0).Laser.Hit.Invader = 0
    Player(0).Laser.Hit.InvaderX = 0
    Player(0).Laser.Hit.InvaderY = 0
    Player(0).Laser.Hit.Shield = 0
    Player(0).Laser.Hit.ShieldX = 0
    Player(0).Laser.Hit.ShieldY = 0
    Player(0).Laser.Hit.Bomb = 0
    Player(0).Laser.Hit.BombX = 0
    Player(0).Laser.Hit.BombY = 0
    Player(0).UFO = UFO(0)
    Player(1) = Player(0) '                             set player settings to default
    Player(2) = Player(0)
    Randomize Timer '                                   seed the RND generator
    Do '                                                begin player loop
        p = p + 1 '                                     increment player counter
        r = 0 '                                         reset row counter
        Do '                                            begin invader row loop
            r = r + 1 '                                 increment row counter
            c = 0 '                                     reset column counter
            Do '                                        begin invader column loop
                c = c + 1 '                             increment column counter
                Select Case r '                         which row?
                    Case 1 '                            row 1 (top row)
                        Invader(p, c, r).Image = 1 '    set invader image
                        Invader(p, c, r).Width = 8 '    set invader width
                        Invader(p, c, r).Score = 30 '   set invader score
                    Case 2 To 3 '                       rows 2 and 3
                        Invader(p, c, r).Image = 2
                        Invader(p, c, r).Width = 11
                        Invader(p, c, r).Score = 20
                    Case 4 To 5 '                       rows 4 and 5 (bottom row)
                        Invader(p, c, r).Image = 3
                        Invader(p, c, r).Width = 12
                        Invader(p, c, r).Score = 10
                End Select
            Loop Until c = 11 '                         leave when all columns processed
        Loop Until r = 5 '                              leave when all rows processed
        Shield(p, 1).rect.x1 = 32 '                     set first shield screen location
        Shield(p, 1).rect.x2 = 57
        Select Case Options.Shields '                   how many shields set in options?
            Case 3 '                                    3 shields
                Shield(p, 2).rect.x1 = 99 '             2nd shield location
                Shield(p, 2).rect.x2 = 124
                Shield(p, 3).rect.x1 = 166 '            3rd shield location
                Shield(p, 3).rect.x2 = 191
            Case 4 '                                    4 shields (default)
                Shield(p, 2).rect.x1 = 77 '             2nd shield location
                Shield(p, 2).rect.x2 = 102
                Shield(p, 3).rect.x1 = 121 '            3rd shield location
                Shield(p, 3).rect.x2 = 146
                Shield(p, 4).rect.x1 = 166 '            4th shield location
                Shield(p, 4).rect.x2 = 191
            Case 5 '                                    5 shields
                Shield(p, 2).rect.x1 = 66 '             2nd shield location
                Shield(p, 2).rect.x2 = 91
                Shield(p, 3).rect.x1 = 99 '             3rd shield location
                Shield(p, 3).rect.x2 = 124
                Shield(p, 4).rect.x1 = 132 '            4th shield location
                Shield(p, 4).rect.x2 = 157
                Shield(p, 5).rect.x1 = 166 '            5th shield location
                Shield(p, 5).rect.x2 = 191
            Case 6 '                                    6 shields
                Shield(p, 2).rect.x1 = 59 '             2nd shield location
                Shield(p, 2).rect.x2 = 84
                Shield(p, 3).rect.x1 = 86 '             3rd shield location
                Shield(p, 3).rect.x2 = 111
                Shield(p, 4).rect.x1 = 113 '            4th shield location
                Shield(p, 4).rect.x2 = 138
                Shield(p, 5).rect.x1 = 140 '            5th shield location
                Shield(p, 5).rect.x2 = 165
                Shield(p, 6).rect.x1 = 167 '            6th shield location
                Shield(p, 6).rect.x2 = 192
        End Select
        Shield(p, 1).rect.y1 = 192 '                    set all shield Y locations
        Shield(p, 1).rect.y2 = 207
        Shield(p, 2).rect.y1 = 192
        Shield(p, 2).rect.y2 = 207
        Shield(p, 3).rect.y1 = 192
        Shield(p, 3).rect.y2 = 207
        Shield(p, 4).rect.y1 = 192
        Shield(p, 4).rect.y2 = 207
        Shield(p, 5).rect.y1 = 192
        Shield(p, 5).rect.y2 = 207
        Shield(p, 6).rect.y1 = 192
        Shield(p, 6).rect.y2 = 207
    Loop Until p = 2 '                                  leave when both players processed

End Sub
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Sub GetReady () '                                                                                                                                                      | GetReady |
    '+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
    '| Informs the player to get ready to play a game or take turns in a 2 player game                                                                                            |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Game As GAME '  need access to shared variables
    Dim Blink As Integer ' blink toggle
    Dim Pause As Integer ' pause counter

    Pause = 180 '                                                                              set 3 second pause
    Do '                                                                                       begin pause loop
        _Limit 60 '                                                                            60 frames per second
        ClearDisplay INCOIN '                                                                  clear the display
        If Game.Frame Mod 5 = 0 Then Blink = Not Blink '                                       toggle blink flag every 5 frames
        Text 13, 7, "PLAY PLAYER<" + _Trim$(Str$(Game.Player)) + ">" '                         print player notice
        If Blink Then DrawScore Game.Player, INCOIN '                                          draw the score when flag set
        If Game.Players = 2 Then '                                                             is this a 2 player game?
            If Game.Player = 1 Then DrawScore PLAYER2, INCOIN Else DrawScore PLAYER1, INCOIN ' yes, draw the other player's score non-blinking
        End If
        UpdateDisplay INCOIN '                                                                 update the display with changes
        Pause = Pause - 1 '                                                                    decrement count down timer
    Loop Until Pause = 0 '                                                                     leave when timer ended

End Sub
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
Sub SelectPlayers () '                                                                                                                                            | SelectPlayers |
    '+------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
    '| Allows the player to choose the number of players when a coin has been inserted into the game                                                                              |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Game As GAME '     need access to shared variables
    Dim KeyPress As Integer ' any key pressed

    Do '                                               begin select loop
        _Limit 30 '                                    30 frames per second
        ClearDisplay INSELECT '                        clear the display
        DrawScore BOTHPLAYERS, INSELECT '              draw the score of both players
        DrawCredits '                                  draw number of credits in machine
        DrawShipsRemaining '                           draw the number of ships remaining for player 1
        Text 12, 12, "PUSH" '                          display text
        If Game.Credits = 1 Then '                     only 1 coin inserted?
            Text 14, 4, "ONLY <1>PLAYER BUTTON" '      yes, display appropriate text
        Else '                                         no, more than 1 coin
            Text 14, 2, "<1> OR <2>PLAYERS BUTTON" '   display appropriate text
        End If
        UpdateDisplay INSELECT '                       update the display with changes
        KeyPress = GetKey(INSELECT) '                  get any key that may have been pressed
        If KeyPress = 49 Then '                        did player press the 1 key?
            Game.Players = 1 '                         yes, set the number of players
            Game.Credits = Game.Credits - 1 '          subtract a credit from the game
            PlayGame PLAYER1 '                         player a 1 player game
        ElseIf KeyPress = 50 Then '                    no, did player press the 2 key?
            If Game.Credits > 1 Then '                 yes, is there more than 1 credit in game?
                Game.Players = 2 '                     yes, set number of players
                Game.Credits = Game.Credits - 2 '      subtract 2 credits from game
                PlayGame PLAYER2 '                     play a two player game
            End If
        ElseIf KeyPress = 79 Then '                    did player press the O key?
            SetOptions '                               yes, go to set options screen
        End If
    Loop Until Game.Credits = 0 '                      leave when all credits have been used

End Sub
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Sub SlowText (Row As Integer, Column As Integer, Txt As String, Mode As Integer, KeyPress As Integer) '                                                                | SlowText |
    '+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
    '| Displays text on screen slowly at 1/10th second per letter                                                                                                                 |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Font() As Long ' need access to shared variables
    Shared Game As GAME
    Dim c As Integer '      column counter
    Dim r As Integer '      row counter
    Dim p As Integer '      text character position counter

    r = Row * 8 '                                          yes, calculate text row
    c = Column * 8 '                                       calculate text column
    p = 0 '                                                reset character position counter
    Do '                                                   begin text loop
        _Limit 60 '                                        60 frames per second
        KeyPress = GetKey(Mode) '                          get any key pressed
        If Game.Frame Mod 6 = 0 Then '                     have 6 frames gone by? (1/10th second)
            p = p + 1 '                                    yes, increment character position counter
            _PutImage (c, r), Font(Asc(Mid$(Txt, p, 1))) ' draw font character onto screen
            c = c + 8 '                                    move to next text column
        End If
        UpdateDisplay Mode '                               update the display with changes
    Loop Until p = Len(Txt) Or KeyPress '                  leave when text finished or a valid key pressed

End Sub
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
Sub InsertCoin () '                                                                                                                                                  | InsertCoin |
    '+---------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
    '| Plays the various intro screens while waiting for a coin to be inserted                                                                                                    |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Font() As Long '        need access to shared variables
    Shared IMG As IMAGES
    Shared IMG_Invader() As Long
    Shared IMG_Bomb() As Long
    Shared Display As DISPLAY
    Shared Game As GAME
    Dim FlippedY As Integer '      toggle used to flip between normal Y and flipped Y screens
    Dim AddedC As Integer '        toggle used to flip between normal C and added C screens
    Dim KeyPress As Integer '      contains any key pressed by player
    Dim Bcycle As Integer '        bomb animation cycler
    Dim ShowQB64 As Integer '      toogle used to flip showing QB64 screen or not
    Dim x As Integer '             generic counter
    Dim Flip As Integer '          invader animation cycler

    Do '                                                                                       begin key check loop
        FlippedY = TRUE '                                                                      set initial state of toggles
        AddedC = TRUE
        ShowQB64 = FALSE
        Do '                                                                                   begin insert coin animation loop
            FlippedY = Not FlippedY '                                                          toggle flipped Y screen
            ClearDisplay INCOIN '                                                              clear the display
            DrawScore BOTHPLAYERS, INCOIN '                                                    draw the score of both players
            DrawCredits '                                                                      draw number of credits in machine
            DrawShipsRemaining '                                                               draw the number of ships remaining
            If Not FlippedY Then '                                                             show the flipped Y screen?
                SlowText 8, 12, "PLAY", INCOIN, KeyPress: If KeyPress Then Exit Do '           no, display text and exit if key pressed
                _PutImage , Display.WorkScreen, Display.CorrectY, (0, 64)-(223, 71) '          get an image of non-flipped Y
            Else '                                                                             yes, show the slipped Y screen
                SlowText 8, 12, "PLA ", INCOIN, KeyPress: If KeyPress Then Exit Do '           display text and exit if key pressed
                _PutImage , Display.WorkScreen, Display.WithoutY, (0, 64)-(223, 71) '          get an image of the Y missing
                _PutImage (127, 70)-(120, 63), Font(89) '                                      draw an upside down Y
                _PutImage , Display.WorkScreen, Display.WithY, (0, 64)-(223, 71) '             get an image of the upside down Y
            End If
            SlowText 11, 7, "SPACE  INVADERS", INCOIN, KeyPress: If KeyPress Then Exit Do '    display text and exit if key pressed
            Sleep 1 '                                                                          pause for 1 second
            Text 15, 4, "*SCORE ADVANCE TABLE*" '                                              display text
            _PutImage (64, 136), IMG.UFO: Text 17, 10, "=" '                                   display UFO=
            _PutImage (68, 152), IMG_Invader(1, 1): Text 19, 10, "=" '                         display invaders and =
            _PutImage (67, 168), IMG_Invader(2, 0): Text 21, 10, "="
            _PutImage (66, 184), IMG_Invader(3, 1): Text 23, 10, "="
            SlowText 17, 11, "? MYSTERY", INCOIN, KeyPress: If KeyPress Then Exit Do '         display point values and exit if key pressed
            SlowText 19, 11, "30 POINTS", INCOIN, KeyPress: If KeyPress Then Exit Do
            SlowText 21, 11, "20 POINTS", INCOIN, KeyPress: If KeyPress Then Exit Do
            SlowText 23, 11, "10 POINTS", INCOIN, KeyPress: If KeyPress Then Exit Do
            If FlippedY Then '                                                                 has the Y been flipped?
                For x = 240 To 124 Step -2 '                                                   yes, cycle from right of screen to left
                    _Limit 30 '                                                                loop will run at 30 frames per second
                    _PutImage (0, 64), Display.WithY '                                         show image with flipped Y
                    _PutImage (x + 4, 64), IMG_Invader(1, Flip) '                              show invader on screen at x coordinate
                    Flip = 1 - Flip '                                                          flip between invader images (0 to 1)
                    DrawScore BOTHPLAYERS, INCOIN '                                            draw the score of both players
                    DrawCredits '                                                              draw number of credits in machine
                    DrawShipsRemaining '                                                       draw the number of ships remaining
                    UpdateDisplay INCOIN '                                                     show results on display screen
                    KeyPress = GetKey(INCOIN): If KeyPress Then Exit Do '                      leave if a key has been pressed
                Next x
                For x = 124 To 240 Step 2 '                                                    cycle back to the right of screen
                    _Limit 30 '                                                                loop will run at 30 frames per second
                    _PutImage (0, 64), Display.WithoutY '                                      show image without a Y
                    _PutImage (x + 4, 64), IMG_Invader(1, Flip) '                              place invader at x location
                    _PutImage (x + 3, 70)-(x - 4, 63), Font(89) '                              place flipped Y behind invader
                    Flip = 1 - Flip '                                                          flip between invader images (0 to 1)
                    DrawScore BOTHPLAYERS, INCOIN '                                            draw the score of both players
                    DrawCredits '                                                              draw number of credits in machine
                    DrawShipsRemaining '                                                       draw the number of ships remaining
                    UpdateDisplay INCOIN '                                                     show results on display screen
                    KeyPress = GetKey(INCOIN): If KeyPress Then Exit Do '                      leave if a key has been pressed
                Next x
                For x = 240 To 124 Step -2 '                                                   cycle from right of screen to left
                    _Limit 30 '                                                                loop will run at 30 frames per second
                    _PutImage (0, 64), Display.WithoutY '                                      show image without a Y
                    _PutImage (x + 4, 64), IMG_Invader(1, Flip) '                              place invader at x location
                    _PutImage (x - 4, 64), Font(89) '                                          place regular Y in front of invader
                    Flip = 1 - Flip '                                                          flip between invader images (0 to 1)
                    DrawScore BOTHPLAYERS, INCOIN '                                            draw the score of both players
                    DrawCredits '                                                              draw number of credits in machine
                    DrawShipsRemaining '                                                       draw the number of ships remaining
                    UpdateDisplay INCOIN '                                                     show results on display screen
                    KeyPress = GetKey(INCOIN): If KeyPress Then Exit Do '                      leave if a key has been pressed
                Next x
                _PutImage (0, 64), Display.CorrectY '                                          show image with correct Y
                Sleep 1 '                                                                      pause for 1 second
                UpdateDisplay INCOIN '                                                         show result on display screen
            End If
            Sleep 2 '                                                                          pause for 2 seconds

            '** PLAY DEMO **

            AddedC = Not AddedC '                                                              toggle added C screen
            ClearDisplay INCOIN '                                                              clear the display
            DrawScore BOTHPLAYERS, INCOIN '                                                    draw the score of both players
            DrawCredits '                                                                      draw number of credits in machine
            DrawShipsRemaining '                                                               draw the number of ships remaining
            Text 14, 8, "INSERT  COIN" '                                                       display text
            _PutImage , Display.WorkScreen, Display.NormalC, (0, 32)-(223, 119) '              get an image without an extra C
            If AddedC Then '                                                                   time to add an extra C?
                Text 14, 15, "C" '                                                             yes, display another C
                _PutImage , Display.WorkScreen, Display.AddedC, (0, 32)-(223, 119) '           get an image with the extra C
            End If
            SlowText 18, 6, "<1 OR 2 PLAYERS>", INCOIN, KeyPress: If KeyPress Then Exit Do '   display text and exit if key pressed
            SlowText 21, 6, "*1 PLAYER  1 COIN", INCOIN, KeyPress: If KeyPress Then Exit Do
            SlowText 24, 6, "*2 PLAYERS 2 COINS", INCOIN, KeyPress: If KeyPress Then Exit Do
            If AddedC Then '                                                                   has an extra C been added?
                Flip = 1 '                                                                     yes, reset invader image flip
                For x = -16 To 120 Step 2 '                                                    start from left side of screen to right
                    _Limit 30 '                                                                limit loop to 30 frames per second
                    _PutImage (0, 32), Display.AddedC '                                        show image with the extra C
                    _PutImage (x, 32), IMG_Invader(1, Flip) '                                  place moving invader on screen
                    Flip = 1 - Flip '                                                          flip between invader images (0 to 1)
                    UpdateDisplay INCOIN '                                                     show results on display screen
                    KeyPress = GetKey(INCOIN): If KeyPress Then Exit Do '                      leave if a key has been pressed
                Next x
                _Delay .125 '                                                                  pause for 1/8th second
                Bcycle = 1 '                                                                   reset bomb image cycler
                For x = 40 To 108 Step 2 '                                                     cycle from under invader to letter C
                    _Limit 30 '                                                                limit loop to 30 frames per second
                    _PutImage (0, 32), Display.AddedC '                                        show image with the extra C
                    _PutImage (120, 32), IMG_Invader(1, Flip) '                                place stationary invader on screen
                    _PutImage (123, x), IMG_Bomb(1, Bcycle) '                                  place moving bomb on screen
                    Bcycle = Bcycle + 1 '                                                      cycle to next bomb image
                    If Bcycle = 4 Then Bcycle = 0 '                                            cycle back to 1 if needed
                    UpdateDisplay INCOIN '                                                     show results on display screen
                    KeyPress = GetKey(INCOIN): If KeyPress Then Exit Do '                      leave if a key has been pressed
                Next x
                _PutImage (0, 32), Display.NormalC '                                           show image without the extra C
                _PutImage (122, 112), IMG.BombHit '                                            place bomb hit explosion over C
                _PutImage (120, 32), IMG_Invader(1, Flip) '                                    place stationary invader on screen
                UpdateDisplay INCOIN '                                                         show results on display screen
                _Delay .0625 '                                                                 pause for 1/16th second
                _PutImage (0, 32), Display.NormalC '                                           show image without the extra C
                _PutImage (120, 32), IMG_Invader(1, Flip) '                                    place stationary invader on screen
                UpdateDisplay INCOIN '                                                         show results on display screen
            End If
            Sleep 2 '                                                                          pause for 2 seconds
            ShowQB64 = Not ShowQB64 '                                                          toggle QB64 screen
            If ShowQB64 Then '                                                                 time to show QB64 screen?
                ClearDisplay INCOIN '                                                          yes, clear the display
                DrawScore BOTHPLAYERS, INCOIN '                                                draw the score of both players
                DrawCredits '                                                                  draw number of credits in machine
                DrawShipsRemaining '                                                           draw the number of ships remaining
                _PutImage (75, 71), IMG.QB64PE '                                               show QB64PE image
                SlowText 5, 8, "Created With", INCOIN, KeyPress: If KeyPress Then Exit Do '    draw credits and leave if a key pressed
                SlowText 7, 11, "QB64PE", INCOIN, KeyPress: If KeyPress Then Exit Do
                SlowText 19, 4, "www.qb64phoenix.com", INCOIN, KeyPress: If KeyPress Then Exit Do
                SlowText 21, 7, "QB64 remake by", INCOIN, KeyPress: If KeyPress Then Exit Do
                SlowText 23, 7, "TERRY  RITCHIE", INCOIN, KeyPress: If KeyPress Then Exit Do
                SlowText 25, 3, "quickbasic64@gmail.com", INCOIN, KeyPress: If KeyPress Then Exit Do
                Sleep 4 '                                                                      pause for 4 seconds
                KeyPress = GetKey(INCOIN): If KeyPress Then Exit Do '                          leave if a key has been pressed
            End If
        Loop
        If KeyPress = 79 Then SetOptions '                                                     go to options screen if O key pressed
    Loop Until KeyPress = 67 '                                                                 leave when C key pressed

End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
Sub SetupDisplay () '                                                                                                                                              | SetupDisplay |
    '+-------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
    '+ Sets up the display screen according to options selected                                                                                                                   |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Options As OPTIONS ' need access to shared variables
    Shared Display As DISPLAY
    Shared IMG As IMAGES
    Dim TmpScreen As Long '     temporary screen image if needed
    Dim IMG_Icon As Long '      window icon image
    Dim Xclicked As Integer '   window X close trap

    If _FullScreen Then _FullScreen _Off '                                                   leave full screen if currently enabled
    If Display.Screen Then '                                                                 has a window already been created?
        TmpScreen = _NewImage(1, 1, 32) '                                                    yes, create a temporary new window
        Screen TmpScreen '                                                                   change to the new window
        _FreeImage Display.Screen '                                                          remove old window image from RAM
    End If
    If Options.Bezel Then '                                                                  is the bezel selected to display?
        Display.Screen = _NewImage(640 * Options.ScreenSize, 360 * Options.ScreenSize, 32) ' yes, make the display screen the size of the bezel
        _PutImage , Display.Bezel, Display.Screen '                                          place the bezel image onto the display screen
        Display.Bez.x1 = 208 * Options.ScreenSize '                                          calculate the location of the work screen coordinates within the bezel image
        Display.Bez.y1 = 74 * Options.ScreenSize
        Display.Bez.x2 = Display.Bez.x1 + 224 * Options.ScreenSize
        Display.Bez.y2 = Display.Bez.y1 + 248 * Options.ScreenSize
    Else '                                                                                   no, no bezel image to be used
        Display.Screen = _NewImage(224 * Options.ScreenSize, 248 * Options.ScreenSize, 32) ' create player display screen based on size of game screen
    End If
    Screen Display.Screen '                                                                  create game window
    _Delay .5
    _ScreenMove _Middle '                                                                    move game screen to center of desktop
    IMG_Icon = _LoadImage("siicon.bmp", 32) '                                                load window icon
    _Icon IMG_Icon '                                                                         set window icon
    _FreeImage IMG_Icon '                                                                    icon image no longer needed
    _Title "QB64 Space Invaders" '                                                           set window title
    If TmpScreen Then _FreeImage TmpScreen '                                                 remove temporary image if created
    If Options.FullScreen Then _FullScreen _SquarePixels , _Smooth '                         go full screen if option set
    _Dest Display.WorkScreen '                                                               game updates take place on this screen
    _Source Display.WorkScreen '                                                             game updates take place on this screen
    Cls , BLACK '                                                                            clear the screen with black background
    Xclicked = _Exit '                                                                       trap the window X close button

End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
Sub ClearDisplay (Mode As Integer) '                                                                                                                               | ClearDisplay |
    '+-------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------+
    '| Clears the display according to mode requested                                                                                                                             |
    '| Mode - 5 (INGAME), 2 (INCOIN), 3 (INSELECT) - clear with background or colored foil                                                                                        |
    '|        1 (INOPTIONS) - clear completely to black                                                                                                                           |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Options As OPTIONS ' need access to shared variables
    Shared Display As DISPLAY

    Select Case Mode '                                                 which type of screen clear needs to be done?
        Case INGAME, INCOIN, INSELECT '                                game screen is currently showing
            If Options.Background Then '                               is the option to show a background image set?
                _PutImage , Display.Background '                       yes, clear the working screen with the background image
            Else '                                                     no, no background image is to be used
                Cls , BLACK '                                          clear the working screen with solid black
                Line (0, 24)-(223, 55), _RGB32(255, 0, 0, 20), BF '    simulate the foil strips that were placed over
                Line (0, 184)-(223, 239), _RGB32(0, 255, 0, 15), BF '  the screen in arcades to give the illusion that
                Line (16, 240)-(135, 247), _RGB32(0, 255, 0, 15), BF ' the game was in color
            End If
        Case INOPTIONS '                                               options screen is currently showing
            Cls , BLACK '                                              clear the screen in black
            _PutImage , Display.OptionScreen, Display.WorkScreen '     place the option screen onto the work screen
    End Select

End Sub
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
Sub UpdateDisplay (Mode As Integer) '                                                                                                                             | UpdateDisplay |
    '+------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------+
    '| Updates the display with changes according to mode requested                                                                                                               |
    '| Mode - 5 (INGAME), 2 (INCOIN), 3 (INSELECT) - display high score, line under player, and apply color strips                                                                |
    '|        1 (INOPTIONS) - just copy work screen to work mask, no changes                                                                                                      |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Game As GAME '       need access to shared variables
    Shared Display As DISPLAY
    Shared Options As OPTIONS

    Game.Frame = Game.Frame + 1 '                                                                                       increment master game frame counter
    If Game.Frame = 32761 Then Game.Frame = 1 '                                                                         reset master game frame counter when needed
    Select Case Mode '                                                                                                  which type of screen update needs to be done?
        Case INGAME, INCOIN, INSELECT '                                                                                 game screen is currently showing
            Text 0, 1, "SCORE<1> HI-SCORE SCORE<2>" '                                                                   draw high score text
            Text 2, 11, Right$("00000" + _Trim$(Str$(Game.HighScore)), 5)
            Line (0, 237)-(223, 237), WHITE '                                                                           draw line under player
            _PutImage , Display.ColorMask, Display.WorkMask '                                                           place color strips onto a temporary image
            _SetAlpha 0, WHITE, Display.WorkScreen '                                                                    make white the transparent color of the working screen
            _PutImage , Display.WorkScreen, Display.WorkMask '                                                          place the working screen onto the color strips
        Case INOPTIONS '                                                                                                options screen is currently showing
            _PutImage , Display.WorkScreen, Display.WorkMask '                                                          place the working screen onto a temporary image
    End Select
    If Options.Bezel Then '                                                                                             is the bezel selected to be displayed?
        _PutImage (Display.Bez.x1, Display.Bez.y1)-(Display.Bez.x2, Display.Bez.y2), Display.WorkMask, Display.Screen ' yes, place screen inside bezel image
    Else '                                                                                                              no, no bezel image is to be shown
        _PutImage , Display.WorkMask, Display.Screen '                                                                  place the temporary image onto the player's view screen
    End If
    _Display '                                                                                                          update the player's display screen with changes

End Sub
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
Sub LoadAssets () '                                                                                                                                                  | LoadAssets |
    '+---------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
    '| Load the game's graphics and sound files                                                                                                                                   |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared IMG As IMAGES '         need access to shared variables
    Shared SND As SOUNDS
    Shared Font() As Long
    Shared IMG_Invader() As Long
    Shared IMG_Bomb() As Long
    Shared IMG_Ship() As Long
    Shared Shield() As SHIELDS
    Shared Display As DISPLAY
    Dim IMG_SpriteSheet As Long '  image sprite sheet
    Dim x As Integer '             generic counter
    Dim y As Integer '             generic counter

    SND.Beat1 = _SndOpen("sibeat1.ogg") '                                      beat 1 sound
    SND.Beat2 = _SndOpen("sibeat2.ogg") '                                      beat 2 sound
    SND.Beat3 = _SndOpen("sibeat3.ogg") '                                      beat 3 sound
    SND.Beat4 = _SndOpen("sibeat4.ogg") '                                      beat 4 sound
    SND.InvaderHit = _SndOpen("siidead.ogg") '                                 invader explosion sound
    SND.PlayerHit = _SndOpen("sipdead.ogg") '                                  player explosion sound
    SND.UFOHit = _SndOpen("siudead.ogg") '                                     ufo explosion sound
    SND.UFOFlying = _SndOpen("siufofly.ogg") '                                 ufo flying sound
    SND.Laser = _SndOpen("silaser.ogg") '                                      player shooting sound
    SND.Coin = _SndOpen("sicoin.ogg") '                                        coin dropping sound
    SND.Extra = _SndOpen("siextra.ogg") '                                      extra ship sound
    IMG.QB64PE = _NewImage(73, 73, 32) '                                       create image containers
    IMG.DipSwitch = _NewImage(16, 36, 32)
    IMG.UFO = _NewImage(16, 8, 32)
    IMG.InvaderHit = _NewImage(14, 8, 32)
    IMG.BombHit = _NewImage(6, 8, 32)
    IMG.BombHitMask = _NewImage(6, 8, 32)
    IMG.LaserHit = _NewImage(8, 8, 32)
    IMG.LaserHitMask = _NewImage(8, 8, 32)
    IMG.Shield = _NewImage(26, 16, 32)
    IMG_Ship(-1) = _NewImage(16, 8, 32)
    IMG_Ship(0) = _NewImage(13, 8, 32)
    IMG_Ship(1) = _NewImage(16, 8, 32)
    IMG_Invader(1, 0) = _NewImage(8, 8, 32)
    IMG_Invader(1, 1) = _NewImage(8, 8, 32)
    IMG_Invader(2, 0) = _NewImage(11, 8, 32)
    IMG_Invader(2, 1) = _NewImage(11, 8, 32)
    IMG_Invader(3, 0) = _NewImage(12, 8, 32)
    IMG_Invader(3, 1) = _NewImage(12, 8, 32)
    Display.Bezel = _NewImage(1920, 1080, 32)
    Display.Screen = _NewImage(224, 248, 32)
    Display.WorkScreen = _NewImage(224, 248, 32)
    Display.WorkMask = _NewImage(224, 248, 32)
    Display.ColorMask = _NewImage(224, 248, 32)
    Display.Background = _NewImage(896, 992, 32)
    Display.OptionScreen = _NewImage(224, 248, 32)
    Display.WithY = _NewImage(224, 8, 32)
    Display.WithoutY = _NewImage(224, 8, 32)
    Display.CorrectY = _NewImage(224, 8, 32)
    Display.AddedC = _NewImage(224, 88, 32)
    Display.NormalC = _NewImage(224, 88, 32)
    For x = PLAYER1 To PLAYER2
        For y = 1 To 6
            Shield(x, y).Image = _NewImage(26, 16, 32) '                       6 shield image containers
        Next y
    Next x
    IMG_Bomb(1, 0) = _NewImage(3, 8, 32)
    IMG_Bomb(1, 1) = _NewImage(3, 8, 32)
    IMG_Bomb(1, 2) = _NewImage(3, 8, 32)
    IMG_Bomb(1, 3) = _NewImage(3, 8, 32)
    IMG_Bomb(2, 0) = _NewImage(3, 8, 32)
    IMG_Bomb(2, 1) = _NewImage(3, 8, 32)
    IMG_Bomb(2, 2) = _NewImage(3, 8, 32)
    IMG_Bomb(2, 3) = _NewImage(3, 8, 32)
    IMG_Bomb(3, 0) = _NewImage(3, 8, 32)
    IMG_SpriteSheet = _LoadImage("sisprites.png", 32) '                        load the sprite sheet
    _SetAlpha 0, BLACK, IMG_SpriteSheet '                                      make black transparent
    _PutImage , IMG_SpriteSheet, IMG.QB64PE, (848, 200)-(920, 272) '           get qb64pe logo
    _PutImage , IMG_SpriteSheet, Display.ColorMask, (400, 200)-(623, 447) '    get color mask
    _PutImage , IMG_SpriteSheet, Display.OptionScreen, (624, 200)-(847, 447) ' get dip switch screen
    _Dest IMG_SpriteSheet '                                                    draw on sprite sheet
    Line (400, 200)-(920, 447), BLACK, BF '                                    remove images from inside of bezel
    _PutImage , IMG_SpriteSheet, Display.Bezel, (0, 8)-(1919, 1087) '          get bezel image
    _PutImage , IMG_SpriteSheet, Display.Background, (1920, 8)-(2815, 999) '   get background image
    _PutImage , Display.OptionScreen, IMG.DipSwitch, (16, 32)-(31, 67) '       get single dip switch
    _PutImage , IMG_SpriteSheet, IMG_Invader(1, 0), (0, 0)-(7, 7) '            get invader 1 image cell 1
    _PutImage , IMG_SpriteSheet, IMG_Invader(1, 1), (8, 0)-(15, 7) '           get invader 1 image cell 2
    _PutImage , IMG_SpriteSheet, IMG_Invader(2, 0), (16, 0)-(26, 7) '          get invader 2 image cell 1
    _PutImage , IMG_SpriteSheet, IMG_Invader(2, 1), (27, 0)-(37, 7) '          get invader 2 image cell 2
    _PutImage , IMG_SpriteSheet, IMG_Invader(3, 0), (38, 0)-(49, 7) '          get invader 3 image cell 1
    _PutImage , IMG_SpriteSheet, IMG_Invader(3, 1), (50, 0)-(61, 7) '          get invader 3 image cell 2
    _PutImage , IMG_SpriteSheet, IMG.UFO, (62, 0)-(77, 7) '                    get UFO image
    _PutImage , IMG_SpriteSheet, IMG_Ship(-1), (91, 0)-(106, 7) '              get exploding player ship image cell 1
    _PutImage , IMG_SpriteSheet, IMG_Ship(0), (78, 0)-(90, 7) '                get player ship image
    _PutImage , IMG_SpriteSheet, IMG_Ship(1), (107, 0)-(122, 7) '              get exploding player ship image cell 2
    _PutImage , IMG_SpriteSheet, IMG.InvaderHit, (123, 0)-(136, 7) '           get exploding invader image
    _PutImage , IMG_SpriteSheet, IMG.BombHit, (137, 0)-(142, 7) '              get laser/bomb exploding hit image
    _Source IMG.BombHit '                                                      image used on display screen
    _Dest IMG.BombHitMask '                                                    image used to destroy shields
    Cls , BLACK '                                                              clear image in black
    For x = 0 To 5 '                                                           cycle through columns
        For y = 0 To 7 '                                                       cycle through rows
            If Point(x, y) <> WHITE Then '                                     is pixel at x,y white?
                PSet (x, y), WHITE '                                           no, draw white pixel on mask
            End If '                                                           (this creates a "negative" or mask
        Next y '                                                                of the IMG.bombhit image)
    Next x
    _SetAlpha 0, WHITE, IMG.BombHitMask '                                      make white transparent
    _PutImage , IMG_SpriteSheet, IMG.LaserHit, (143, 0)-(150, 7) '             get laser exploding miss image
    _Source IMG.LaserHit '                                                     image used on display screen
    _Dest IMG.LaserHitMask '                                                   image used to destroy shields
    Cls , BLACK '                                                              clear image in black
    For x = 0 To 7 '                                                           cycle through columns
        For y = 0 To 7 '                                                       cycle through rows
            If Point(x, y) <> WHITE Then '                                     is pixel at x,y white?
                PSet (x, y), WHITE '                                           no, draw white pixel on mask
            End If '                                                           (this creates a "negative" or mask
        Next y '                                                                of the IMG.laserhit image)
    Next x
    _SetAlpha 0, WHITE, IMG.LaserHitMask '                                     set white as transparent
    _PutImage (0, 0), IMG_SpriteSheet, IMG.Shield, (154, 0)-(166, 7) '         get upper left shield image
    _PutImage (13, 0), IMG_SpriteSheet, IMG.Shield, (167, 0)-(179, 7) '        get upper right shield image
    _PutImage (0, 8), IMG_SpriteSheet, IMG.Shield, (186, 0)-(198, 7) '         get lower left shield image
    _PutImage (13, 8), IMG_SpriteSheet, IMG.Shield, (199, 0)-(211, 7) '        get lower right shield image
    _SetAlpha 0, BLACK, IMG.Shield '                                           add transparency to shield image
    _PutImage , IMG_SpriteSheet, IMG_Bomb(1, 0), (215, 0)-(217, 7) '           get bomb 1 image cell 1
    _PutImage , IMG_SpriteSheet, IMG_Bomb(1, 1), (218, 0)-(220, 7) '           get bomb 1 image cell 2
    _PutImage , IMG_SpriteSheet, IMG_Bomb(1, 2), (221, 0)-(223, 7) '           get bomb 1 image cell 3
    _PutImage , IMG_SpriteSheet, IMG_Bomb(1, 3), (224, 0)-(226, 7) '           get bomb 1 image cell 4
    _PutImage , IMG_SpriteSheet, IMG_Bomb(2, 0), (227, 0)-(229, 7) '           get bomb 2 image cell 1
    _PutImage , IMG_SpriteSheet, IMG_Bomb(2, 1), (230, 0)-(232, 7) '           get bomb 2 image cell 2
    _PutImage , IMG_SpriteSheet, IMG_Bomb(2, 2), (233, 0)-(235, 7) '           get bomb 2 image cell 3
    _PutImage , IMG_SpriteSheet, IMG_Bomb(2, 3), (236, 0)-(238, 7) '           get bomb 2 image cell 4
    _PutImage , IMG_SpriteSheet, IMG_Bomb(3, 0), (239, 0)-(241, 7) '           get bomb 3 image cell 1
    IMG_Bomb(3, 1) = _CopyImage(IMG_Bomb(1, 0)) '                              copy bomb 3 image cell 2
    IMG_Bomb(3, 2) = _CopyImage(IMG_Bomb(3, 0)) '                              copy bomb 3 image cell 3
    IMG_Bomb(3, 3) = _CopyImage(IMG_Bomb(1, 2)) '                              copy bomb 3 image cell 4
    For x = 1 To 255 '                                                         cycle through 255 font images
        Font(x) = _NewImage(8, 8, 32) '                                        create font image container
        _PutImage (0, 0), IMG_SpriteSheet, Font(x), ((x - 1) * 8 + 242, 0)-(((x - 1) * 8 + 242) + 7, 7)
    Next x '                                                                   get font character fron sprite sheet
    _FreeImage IMG_SpriteSheet '                                               remove spritesheet from RAM

End Sub
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
Sub LoadOptions () '                                                                                                                                                | LoadOptions |
    '+--------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
    '| Load the game options from the options file. If the file does not exist create one with default settings.                                                                  |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Options As OPTIONS ' need access to shared variables
    Shared Game As GAME

    If _FileExists("si.sav") Then '                                                            does the options file exist?
        Open "si.sav" For Input As #1 '                                                        yes, open the file for reading
        Input #1, Options.Switches '                                                           get the saved DIP switch settings
        Input #1, Game.HighScore '                                                             get the save high score
        Close #1 '                                                                             close the options file
    Else '                                                                                     no, the options file does not exist
        Options.Switches = 215 '                                                               set DIP switches to default settings
        SaveOptions '                                                                          save the options
    End If
    If Options.Switches And 128 Then Options.FreePlay = FALSE Else Options.FreePlay = TRUE '   set free play according to DIP switch setting
    If Options.Switches And 64 Then Options.ExtraShip = 1500 Else Options.ExtraShip = 1000 '   set extra ship value according to DIP switch setting
    If (Options.Switches And 48) = 48 Then '                                                   are DIP switches 3 and 4 on?
        Options.Shields = 6 '                                                                  yes, 6 shields will be used
    ElseIf Options.Switches And 32 Then '                                                      no, is DIP switch 3 on?
        Options.Shields = 5 '                                                                  yes, 5 shields will be used
    ElseIf Options.Switches And 16 Then '                                                      no, is DIP switch 4 on?
        Options.Shields = 4 '                                                                  yes, 4 shields will be used
    Else '                                                                                     no, neither DIP switch 3 or 4 is on
        Options.Shields = 3 '                                                                  3 shields will be used
    End If
    Options.FullScreen = FALSE '                                                               assume full screen mode is disabled
    If (Options.Switches And 12) = 12 Then '                                                   are DIP switches 5 and 6 on?
        Options.FullScreen = TRUE '                                                            yes, full screen mode activated
        Options.ScreenSize = 3 '                                                               game screen will be 3X size full screen
    ElseIf Options.Switches And 8 Then '                                                       no, is DIP switch 5 on?
        Options.ScreenSize = 3 '                                                               yes, game screen will be 3X size windowed
    ElseIf Options.Switches And 4 Then '                                                       no, is DIP switch 6 on?
        Options.ScreenSize = 2 '                                                               yes, game screen will be 2X size windowed
    Else '                                                                                     no, neither DIP switch 5 or 6 is on
        Options.ScreenSize = 1 '                                                               game screen will be 1X size windowed
    End If
    If Options.Switches And 2 Then Options.Background = TRUE Else Options.Background = FALSE ' set background image according to DIP switch setting
    If Options.Switches And 1 Then Options.Bezel = TRUE Else Options.Bezel = FALSE '           set bezel image according to DIP switch setting
    If (Options.Bezel = FALSE) And Options.FullScreen Then Options.ScreenSize = 4 '            use a 4x screen size for full screen without the bezel
    SetupDisplay '                                                                             set the dsiplay according to chosen options

End Sub
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
Sub SaveOptions () '                                                                                                                                                | SaveOptions |
    '+--------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
    '| Save the game's options and high score to the options file                                                                                                                 |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Options As OPTIONS ' need access to shared variables
    Shared Game As GAME

    Open "si.sav" For Output As #1 ' create a file to write to
    Print #1, Options.Switches '     write the current options to the file
    Print #1, Game.HighScore '       write the high score to the file
    Close #1 '                       close the file

End Sub
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
Sub SetOptions () '                                                                                                                                                  | SetOptions |
    '+---------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
    '| Displays the options screen allowing the player to select options                                                                                                          |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Options As OPTIONS ' need access to shared variables
    Shared IMG As IMAGES
    Shared Game As GAME
    Shared SND As SOUNDS
    Dim KeyPress As Integer '   a key that was pressed

    Do '                                                                              begin display loop
        _Limit 30 '                                                                   limit to 30 frames per second
        ClearDisplay INOPTIONS '                                                      clear the screen
        If Options.Switches And 128 Then '                                            is switch 1 on?
            Text 14, 1, "1: COIN REQUIRED TO PLAY" '                                  yes, display text
            _PutImage (31, 67)-(16, 32), IMG.DipSwitch '                              flip switch 1 to on position
        Else '                                                                        no, switch 1 is off
            Text 14, 1, "1: GAME SET TO FREE PLAY" '                                  display text
        End If
        If Options.Switches And 64 Then '                                             is switch 2 on?
            Text 16, 1, "2: EXTRA SHIP AT 1500" '                                     yes, display text
            _PutImage (57, 67)-(42, 32), IMG.DipSwitch '                              flip switch 2 to on position
        Else '                                                                        no, switch 2 is off
            Text 16, 1, "2: EXTRA SHIP AT 1000" '                                     display text
        End If
        If (Options.Switches And 48) = 48 Then '                                      are switches 3 and 4 on?
            Text 18, 1, "3: SIX BASES DURING PLAY" '                                  yes, display text
            Text 19, 1, "4: HELP MOMMY - 6 BASES"
        ElseIf Options.Switches And 32 Then '                                         no, is switch 3 on?
            Text 18, 1, "3: FIVE BASES DURING PLAY" '                                 yes, display text
            Text 19, 1, "4: EASY - 5 BASES"
        ElseIf Options.Switches And 16 Then '                                         no, is switch 4 on?
            Text 18, 1, "3: FOUR BASES DURING PLAY" '                                 yes, display text
            Text 19, 1, "4: DEFAULT - 4 BASES"
        Else '                                                                        no, both switches 3 and 4 are off
            Text 18, 1, "3: THREE BASES DURING PLAY" '                                display text
            Text 19, 1, "4: HARD - 3 BASES"
        End If
        If Options.Switches And 32 Then _PutImage (83, 67)-(68, 32), IMG.DipSwitch '  if switch 3 is on flip it to the on position
        If Options.Switches And 16 Then _PutImage (109, 67)-(94, 32), IMG.DipSwitch ' if switch 4 is on flip it to the on position
        If (Options.Switches And 12) = 12 Then '                                      are switches 5 and 6 on?
            Text 21, 1, "5: FULL SCREEN" '                                            yes, display text
            Text 22, 1, "6: (3X ORIGINAL SIZE)"
        ElseIf Options.Switches And 8 Then '                                          no, is switch 5 on?
            Text 21, 1, "5: LARGE 672x744 WINDOW" '                                   yes, display text
            Text 22, 1, "6: (3X ORIGINAL SIZE)"
        ElseIf Options.Switches And 4 Then '                                          no, is switch 6 on?
            Text 21, 1, "5: MEDIUM 448x496 WINDOW" '                                  yes, display text
            Text 22, 1, "6: (2X ORIGINAL SIZE)"
        Else '                                                                        no, both switches 5 and 6 are off
            Text 21, 1, "5: SMALL 224x248 WINDOW" '                                   display text
            Text 22, 1, "6: (ORIGINAL SIZE)"
        End If
        If Options.Switches And 8 Then _PutImage (135, 67)-(120, 32), IMG.DipSwitch ' if switch 5 is on flip it to the on position
        If Options.Switches And 4 Then _PutImage (161, 67)-(146, 32), IMG.DipSwitch ' if switch 6 is on flip it to the on position
        If Options.Switches And 2 Then '                                              is switch 7 on?
            Text 24, 1, "7: SHOW BACKGROUND IMAGE" '                                  yes, display text
            _PutImage (187, 67)-(172, 32), IMG.DipSwitch '                            flip switch 7 to on position
        Else '                                                                        no, switch 7 is off
            Text 24, 1, "7: NO BACKGROUND IMAGE" '                                    display text
        End If
        If Options.Switches And 1 Then '                                              is switch 8 on?
            Text 26, 1, "8: SHOW BEZEL IMAGE" '                                       yes, display text
            _PutImage (213, 67)-(198, 32), IMG.DipSwitch '                            flip switch 8 to the on position
        Else '                                                                        no, switch 8 is off
            Text 26, 1, "8: NO BEZEL IMAGE" '                                         display text
        End If
        Text 28, 2, "  <R> RESET HIGH SCORE" '                                        display input options
        Text 29, 2, "  <S> SAVE SETTINGS"
        Text 30, 2, "<1-8> TOGGLE DIP SWITCH"
        UpdateDisplay INOPTIONS '                                                     update display with changes
        Do '                                                                          begin keyboard input loop
            _Limit 30 '                                                               limit to 30 frames per second
            KeyPress = GetKey(INOPTIONS) '                                            get a valid keyboard input
        Loop Until KeyPress '                                                         leave when valid keyboard input received
        If KeyPress = 82 Then '                                                       was the R key pressed?
            Game.HighScore = 0 '                                                      yes, reset the high score
            _SndPlay SND.Extra '                                                      play sound to acknowledge
        End If
        If KeyPress <> 83 Then '                                                      was the S key pressed?
            KeyPress = Abs(KeyPress - 56) '                                           no, convert keypress vale to 7 through 0
            Options.Switches = Options.Switches Xor 2 ^ KeyPress '                    flip appropriate switch setting
        End If
    Loop Until KeyPress = 83 '                                                        leave when S keyboard input received
    SaveOptions '                                                                     save game options
    LoadOptions '                                                                     load game options to make any changes take effect

End Sub
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+
Sub Text (Row As Integer, Column As Integer, Txt As String) '                                                                                                              | Text |
    '+---------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+
    '| Displays text instantly at the requested location                                                                                                                          |
    '| Row    - row where text is to printed (if row > 31 then actual screen coordinates are used. This is for the UFO text)                                                      |
    '| Column - column where text is to be printed                                                                                                                                |
    '| Txt    - text string to be printed                                                                                                                                         |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Font() As Long ' need access to shared variables
    Dim c As Integer '      column counter
    Dim r As Integer '      row counter
    Dim p As Integer '      text character position counter

    If Row < 31 Then '                                 text on an 8x8 grid?
        r = Row * 8 '                                  yes, calculate text row
        c = Column * 8 '                               calculate text column
    Else '                                             no, use actual coordinates on screen for UFO text
        r = Column '                                   convert row to X screen coordinate
        c = Row - 32 '                                 convert column to Y screen coordinate
    End If
    Do '                                               begin text print loop
        p = p + 1 '                                    increment character position counter
        _PutImage (c, r), Font(Asc(Mid$(Txt, p, 1))) ' draw font character onto screen
        c = c + 8 '                                    move to next text column
    Loop Until p = Len(Txt) '                          leave when all characters printed

End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+
Function GetKey (Mode As Integer) '                                                                                                                                      | GetKey |
    '+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+
    '| Get key presses from the player                                                                                                                                            |
    '| Mode - 1 (INOPTIONS) S, 1-8, and R keys only are returned                                                                                                                  |
    '|        2 (INCOIN)    O key (letter O) is the only one returned                                                                                                             |
    '|        3 (INSELECT)  1, 2, and O (letter O) keys are only returned                                                                                                         |
    '|       -1 (NEWGMAE)   clears the buffer and exits                                                                                                                           |
    '| The C key is always monitored and returned. Additionaly when C is pressed a credit is added to the game.                                                                   |
    '| The ESC key is always monitored and the game exited if pressed.                                                                                                            |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Game As GAME '      need access to shared variables
    Shared SND As SOUNDS
    Static Buffer As Integer ' buffer to hold last key pressed (retains value between calls)
    Dim KeyPress As Integer '  last key that was pressed

    If _Exit Then ExitGame '                          leave game if player closes window with X button
    If Mode = NEWGAME Then Buffer = 0: Exit Function 'clear the buffer and exit
    KeyPress = _KeyHit '                              get a key if pressed
    If KeyPress = 0 Then Exit Function '              leave function if no key pressed
    If KeyPress < 0 Then Buffer = 0: Exit Function '  if a key was released then clear the buffer and leave function
    If Buffer Then GetKey = 0: Exit Function '        if a key is being held down return nothing and leave function
    If KeyPress = 27 Then ExitGame '                  exit the game if the ESC key pressed
    Buffer = KeyPress '                               put the key into the buffer
    If KeyPress = 67 Or KeyPress = 99 Then '          was the C key pressed?
        Game.Credits = Game.Credits + 1 '             yes, insert a coin
        If Game.Credits > 99 Then Game.Credits = 99 ' limit amount of coins in game
        _SndPlay SND.Coin '                           play the coin dropping sound
        GetKey = 67 '                                 return the key to the insert coin screen
        Exit Function '                               leave the function
    End If
    Select Case Mode '                                which mode is the game in?
        Case INOPTIONS '                              the options screen is showing
            If KeyPress = 83 Or KeyPress = 115 Then ' was the S key pressed?
                GetKey = 83 '                         yes, return the key to the options screen
            End If
            If KeyPress > 48 And KeyPress < 57 Then ' was the 1 through 8 key pressed?
                GetKey = KeyPress '                   yes, return the key to the options screen
            End If
            If KeyPress = 82 Or KeyPress = 114 Then ' was the R key pressed?
                GetKey = 82 '                         yes, return the key to the options screen
            End If
        Case INCOIN '                                 the insert coin screen is showing
            If KeyPress = 79 Or KeyPress = 111 Then ' was the O key pressed?
                GetKey = 79 '                         yes, return the key to the insert coin screen
            End If
        Case INSELECT '                               the select players screen is showing
            If KeyPress = 49 Or KeyPress = 50 Then '  was the 1 or 2 key pressed?
                GetKey = KeyPress '                   yes, return the key to the select players screen
            End If
            If KeyPress = 79 Or KeyPress = 111 Then ' was the O key pressed?
                GetKey = 79 '                         yes, return the key to the insert coin screen
            End If
    End Select

End Function
'---------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------+
Sub DrawScore (p As Integer, Mode As Integer) '                                                                                                                       | DrawScore |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------+
    '| Draws the given player's score in the mode requested                                                                                                                       |
    '| p    - player 1 or 2 - 3 (BOTHPLAYERS) to have both players high scores drawn at same time                                                                                 |
    '| Mode - 5 (INGAME) - update the high score if it has been surpassed                                                                                                         |
    '|        any other value is ignored                                                                                                                                          |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER ' need access to shared variables
    Shared Game As GAME
    Shared Options As OPTIONS
    Shared SND As SOUNDS

    If p = PLAYER1 Or p = BOTHPLAYERS Then '                                                            player 1 selected?
        Text 2, 2, Right$("00000" + _Trim$(Str$(Player(1).Score)), 5) '                                 yes, print palyer 1's score
    End If
    If p = PLAYER2 Or p = BOTHPLAYERS Then '                                                            player 2 selected?
        Text 2, 20, Right$("00000" + _Trim$(Str$(Player(2).Score)), 5) '                                yes, print player 2's score
    End If
    If Player(Game.Player).Ship.Extra = FALSE Then '                                                    has the current player been awarded an extra ship?
        If Player(Game.Player).Score >= Options.ExtraShip Then '                                        no, is the current player's score high enough for an extra ship?
            Player(Game.Player).Ship.Remain = Player(Game.Player).Ship.Remain + 1 '                     yes, award the player another ship
            Player(Game.Player).Ship.Extra = TRUE '                                                     remember that an extra ship was awarded
            _SndPlay SND.Extra
        End If
    End If
    If Mode = INGAME Then '                                                                             is a game currently in progress?
        If Player(Game.Player).Score > Game.HighScore Then Game.HighScore = Player(Game.Player).Score ' yes, update the high score is a player exceeds it
    End If

End Sub
'------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------+
Sub DrawShipsRemaining () '                                                                                                                                  | DrawShipsRemaining |
    '+-------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------+
    '| Draws the player's remaining ships                                                                                                                                         |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Player() As PLAYER ' need access to shared variables
    Shared IMG_Ship() As Long
    Shared Game As GAME
    Dim s As Integer '          ship counter
    Dim p As Integer '          curent player

    p = Game.Player '                                 get current player
    Text 30, 1, _Trim$(Str$(Player(p).Ship.Remain)) ' print number of total ships
    s = 1 '                                           reset ship counter
    While s <= Player(p).Ship.Remain - 1 '            display a ship?
        _PutImage (8 + (s * 16), 239), IMG_Ship(0) '  yes, draw ship
        s = s + 1 '                                   increment ship counter
    Wend '                                            leave when no more ships to draw

End Sub
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
Sub DrawCredits () '                                                                                                                                                | DrawCredits |
    '+--------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------+
    '| Draw the number of credits in the game                                                                                                                                     |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared Game As GAME ' ned access to shared variables

    Text 28, 1, "<C>OIN <O>PTIONS <ESC>EXIT" '                              print the options text
    Text 30, 17, "CREDIT-" + Right$("00" + _Trim$(Str$(Game.Credits)), 2) ' print the number of credits inserted

End Sub
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
Sub ExitGame () '                                                                                                                                                      | ExitGame |
    '+-----------------------------------------------------------------------------------------------------------------------------------------------------------------+----------+
    '| Frees all game assets from RAM and exits the game                                                                                                                          |
    '+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    Shared SND As SOUNDS '                   need access to shared variables
    Shared IMG As IMAGES
    Shared IMG_Ship() As Long
    Shared IMG_Invader() As Long
    Shared IMG_Bomb() As Long
    Shared Display As DISPLAY
    Shared Shield() As SHIELDS
    Shared Font() As Long
    Dim x As Integer '                       generic counter
    Dim y As Integer '                       generic counter

    If _FullScreen Then _FullScreen _Off '   leave full screen if enabled
    Screen 0, 0, 0, 0 '                      switch to a pure text screen
    _SndClose SND.Beat1 '                    remove sounds from RAM
    _SndClose SND.Beat2
    _SndClose SND.Beat3
    _SndClose SND.Beat4
    _SndClose SND.InvaderHit
    _SndClose SND.PlayerHit
    _SndClose SND.UFOHit
    _SndClose SND.UFOFlying
    _SndClose SND.Laser
    _SndClose SND.Coin
    _SndClose SND.Extra
    _FreeImage IMG.QB64PE '                  remove images from RAM
    _FreeImage IMG.DipSwitch
    _FreeImage IMG.UFO
    _FreeImage IMG.InvaderHit
    _FreeImage IMG.BombHit
    _FreeImage IMG.BombHitMask
    _FreeImage IMG.LaserHit
    _FreeImage IMG.LaserHitMask
    _FreeImage IMG.Shield
    _FreeImage IMG_Ship(-1)
    _FreeImage IMG_Ship(0)
    _FreeImage IMG_Ship(1)
    _FreeImage IMG_Invader(1, 0)
    _FreeImage IMG_Invader(1, 1)
    _FreeImage IMG_Invader(2, 0)
    _FreeImage IMG_Invader(2, 1)
    _FreeImage IMG_Invader(3, 0)
    _FreeImage IMG_Invader(3, 1)
    _FreeImage Display.Bezel
    _FreeImage Display.Screen
    _FreeImage Display.WorkScreen
    _FreeImage Display.WorkMask
    _FreeImage Display.ColorMask
    _FreeImage Display.Background
    _FreeImage Display.OptionScreen
    _FreeImage Display.WithY
    _FreeImage Display.WithoutY
    _FreeImage Display.CorrectY
    _FreeImage Display.AddedC
    _FreeImage Display.NormalC
    _FreeImage IMG_Bomb(1, 0)
    _FreeImage IMG_Bomb(1, 1)
    _FreeImage IMG_Bomb(1, 2)
    _FreeImage IMG_Bomb(1, 3)
    _FreeImage IMG_Bomb(2, 0)
    _FreeImage IMG_Bomb(2, 1)
    _FreeImage IMG_Bomb(2, 2)
    _FreeImage IMG_Bomb(2, 3)
    _FreeImage IMG_Bomb(3, 0)
    _FreeImage IMG_Bomb(3, 1)
    _FreeImage IMG_Bomb(3, 2)
    _FreeImage IMG_Bomb(3, 3)
    For x = 1 To 2
        For y = 1 To 6
            _FreeImage Shield(x, y).Image
        Next y
    Next x
    For x = 1 To 255
        _FreeImage Font(x)
    Next x
    System '                                return to the operating system

End Sub
'----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

