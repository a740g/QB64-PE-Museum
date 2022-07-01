'+----------------------------------------------------------------------------+
'|                           QB64 Space Invaders!                             |
'|                                                                            |
'|                              Programmed by:                                |
'|                                                                            |
'|                              Terry Ritchie                                 |
'|                                                                            |
'|                         terry.ritchie@gmail.com                            |
'|                                                                            |
'| This game was written to be used as a test bed for my QB64 Sprite Library. |
'| QB64 Space Invaders! has been released as freeware to be used as a         |
'| QB64 Sprite Libary example. If you use any of the code from this game for  |
'| your own project(s) please give credit where credit is due (and email me a |
'| copy of the cool games you create!).                                       |
'|                                                                            |
'| A special thanks goes to Rob (Galleon), the creator of the QB64 language.  |
'|                                                                            |
'| You can download the QB64 language at: http://www.qb64.net                 |
'|                                                                            |
'| And a big thank you to the QB64 forum community for all their help during  |
'| the creation of the Sprite Library and this program. Thank guys!           |
'+----------------------------------------------------------------------------+

'$INCLUDE:'spritetop.bi'

Const FALSE = 0, TRUE = Not FALSE

Type letters '           font container
    h As Integer '       sprite H font image
    i As Integer '       sprite I font image
    s As Integer '       sprite S font image
    c As Integer '       sprite C font image
    o As Integer '       sprite O font image
    r As Integer '       sprite R font image
    e As Integer '       sprite E font image
    d As Integer '       sprite D font image
    t As Integer '       sprite T font image
    dash As Integer '    sprite - font image
    lthan As Integer '   sprite < font image
    gthan As Integer '   sprite > font image
    one As Integer '     sprite 1 font image
End Type

Dim letter As letters '  GFX: container holding the font sprites
Dim invader%(5, 11) '    GFX: the space invaders (5 rows by 11 columns)
Dim remaining%(3) '      GFX: sprites of ships remaining
Dim scoredigit%(4) '     GFX: player score four digits
Dim hiscoredigit%(4) '   GFX: player hi-score four digits
Dim imissile%(10) '      GFX: 10 invader missiles
Dim remainingdigit% '    GFX: ships remaining digit
Dim background& '        GFX: the background image
Dim mainsheet% '         GFX: the sprite sheet that holds the enemies
Dim fontsheet% '         GFX: the sprite sheet that holds the font
Dim missilesheet% '      GFX: the sprite sheet that holds the missiles
Dim pmissile% '          GFX: the player's missile sprite
Dim player% '            GFX: the player's ship
Dim ufo% '               GFX: the ufo
Dim base1% '             GFX: top left quarter of base
Dim base2% '             GFX: bottom left quarter of base
Dim icon& '              GFX: windows icon image
Dim baseshields& '       GFX: copy of base shields
Dim beat&(4) '           SND: walking beat sounds
Dim playerhit& '         SND: player getting hit explosion sound
Dim invaderhit& '        SND: invader getting hit explosion sound
Dim fire& '              SND: player laser cannon firing sound
Dim ufomoving& '         SND: ufo moving scross the screen sound
Dim ufohit& '            SND: ufo getting hit funky sound
Dim level% '             current game level
Dim showufoscore% '      showscore after ufo hit?
Dim fps% '               frames per second game runs at (default = 128)
Dim score% '             player's score
Dim hiscore% '           game high score
Dim shipsremaining% '    number of ships player has remaining
Dim shieldsremain% '     does any part of the base shields remain
Dim invadersremaining% ' the number of invaders left in game

Screen _NewImage(800, 700, 32) '                                               800 by 700 screen in 32bit color
Cls '                                                                          get rid of alpha transparency
_ScreenMove _Middle '                                                          move the image to the center of player's screen
icon& = _LoadImage("siicon.bmp", 32) '                                         load the window icon image
_Icon icon& '                                                                  set the icon to the loaded image
_FreeImage icon& '                                                             no longer need the icon image
_Title "QB64 Space Invaders!" '                                                set window title
Randomize Timer '                                                              seed random number generator
fps% = 128 '                                                                   set to 128 frames per second (default)
level% = 0 '                                                                   reset the level counter
shipsremaining% = 3 '                                                          player starts with 3 ships
shieldsremain% = TRUE '                                                        set the shield flag
LoadGraphics '                                                                 load the game graphics
LoadSounds '                                                                   load the game sounds
DrawScreen '                                                                   draw the initial game screen
Do '                                                                           start the game loop here
    level% = level% + 1 '                                                      increment game level
    If level% = 8 Then level% = 7
    invadersremaining% = 55
    NewLevel '                                                                 draw the next level screen
    Do '                                                                       start the individual level loop here
        _Limit fps% '                                                          limit game to this many frames per second
        _PutImage (0, 36), background&
        If shieldsremain% Then _PutImage (80, 500), baseshields&
        UpdateInvaders '                                                       update the position of the invaders
        UpdateUfo '                                                            update the ufo status
        UpdatePlayerMissile '                                                  update the player missile status
        UpdatePlayer '                                                         update the player status
        UpdateInvaderMissiles '                                                update the invader missiles
        UpdateScore '                                                          update the score
        _Display '                                                             show all changes made to the screen
    Loop Until (invadersremaining% = 0) Or (shipsremaining% = 0) '             time to end level?
Loop Until shipsremaining% = 0 '                                               time to end the game?
System '                                                                       yes, back the the OS

'##################################################################################################################################

Sub PlayerLostShip (ships%)

    Shared player%, imissile%(), ufomoving&, playerhit&, shipsremaining%

    Dim count% '                                                                   generic counter
    Dim remember% '                                                                remember if ufo moving sound was playing

    For count% = 1 To 10 '                                                         cycle through all 10 possible invader missiles
        SPRITESCORESET imissile%(count%), 0 '                                      turn any lingering ones off
        SPRITEPUT -40, 0, imissile%(count%) '                                      place them off the screen and out of the way for now
    Next count%
    SPRITESET player%, 10 '                                                        set the player's ship to the explosion image
    SPRITEANIMATESET player%, 10, 11 '                                             set the explosion animation sequence
    SPRITEANIMATION player%, ANIMATE, FORWARDLOOP '                                turn animation on for the player ship
    If _SndPlaying(ufomoving&) Then '                                              is the ufo sound playing? (ufo in flight)
        remember% = TRUE '                                                         yes, remember that it was
        _SndStop ufomoving& '                                                      stop the ufo moving sound
    End If
    _SndPlay playerhit& '                                                          play the player ship explosion sound
    For count% = 1 To 60 '                                                         show the animation for 60 frames
        _Limit 20 '                                                                at 20 frames per second for total of 3 seconds
        SPRITEPUT SPRITEX(player%), SPRITEY(player%), player% '                    put player ship on screen for autoanimation
        _Display '                                                                 show the screen changes
    Next count%
    SPRITESET player%, 9 '                                                         set the player's ship back the standard image
    SPRITEANIMATION player%, NOANIMATE, FORWARDLOOP '                              turn off animation for player's ship
    shipsremaining% = shipsremaining% - ships% '                                   take player's ship(s) away
    UpdatePlayerShips '                                                            show the result of taking away a ship on screen
    If remember% Then _SndLoop (ufomoving&) '                                      if the ufo sound was playing turn it back on

End Sub

'##################################################################################################################################

Sub UpdateInvaderMissiles ()

    Shared imissile%(), player%, invader%(), level%, invadersremaining%, shieldsremain%

    Static mcount%(11) '                                                           don't allow missiles to get too close in each column

    Dim count% '                                                                   generic counter
    Dim shieldhit% '                                                               true if missiles hit base shield
    Dim count2% '                                                                  generic counter
    Dim row% '                                                                     cycle through invader rows
    Dim column% '                                                                  cycle through invader columns

    For count% = 1 To 10 '                                                         cycle through all 10 possible invader missiles
        If SPRITESCORE(imissile%(count%)) = 1 Then '                               is this missile flying, if so update its position
            SPRITEPUT SPRITEX(imissile%(count%)), SPRITEY(imissile%(count%)) + (level% \ 4) + 1, imissile%(count%) ' 1-3 slow, 4-7 fast
            If SPRITECOLLIDE(imissile%(count%), player%) Then '                    has this missile collided with the player?
                PlayerLostShip 1 '                                                  player has been hit and loses a ship
            End If
            If SPRITEY(imissile%(count%)) > 486 Then '                             are we in base shield territory?
                If shieldsremain% Then '                                           yes, are there any base shields to worry about?
                    shieldhit% = FALSE '                                           yes, assume this missile did not hit base shield
                    For count2% = -1 To 1 '                                        scan ahead of missile looking for the shield
                        If Point(SPRITEX(imissile%(count%)) + count2%, SPRITEY(imissile%(count%)) + 15) = _RGB(0, 255, 0) Then
                            shieldhit% = TRUE '                                    shield was hit, remember this
                        End If
                    Next count2%
                    If shieldhit% Then '                                           was the shield hit?
                        SPRITESCORESET imissile%(count%), 0 '                      yes, hide the invader missile
                        DamageShields SPRITEX(imissile%(count%)) - 8, SPRITEY(imissile%(count%)) + 32 'damage the shields in location where missile hit
                        SPRITEPUT -40, 0, imissile%(count%) '                      move missile off screen out of the way for now
                    End If
                End If
            End If
            If SPRITEY(imissile%(count%)) > 620 Then '                             did the missile hit the bottom of the screen?
                SPRITESCORESET imissile%(count%), 0 '                              yes, remove it from view
                SPRITEPUT -40, 0, imissile%(count%) '                              move missile off screen out of the way for now
            End If
        Else
            If Int(Rnd(1) * (invadersremaining% * (24 - level% * 2))) + 1 = 10 Then 'should an invader randomly drop a missile now?
                column% = Int(Rnd(1) * 11) + 1 '                                   yes, pick a random column
                If mcount%(column%) = 0 Then '                                     is there another missile in this column that just left?
                    For row% = 5 To 1 Step -1 '                                    no, start checking each row for an invader at bottom
                        If SPRITESCORE(invader%(row%, column%)) <> 0 Then '        is this invader still active?
                            If level% > 3 Then mcount%(column%) = 16 Else mcount%(column%) = 32 'yes, adjust missile closeness based on level
                            SPRITEPUT SPRITEX(invader%(row%, column%)), SPRITEY(invader%(row%, column%)), imissile%(count%) 'put missile on screen
                            SPRITESCORESET imissile%(count%), 1 '                  set that it's active and flying
                            Exit For
                        End If
                    Next row%
                End If
            End If
        End If
        If mcount%(count%) > 0 Then mcount%(count%) = mcount%(count%) - 1 '        decrement the column missile closeness counter
    Next count%

End Sub

'##################################################################################################################################

Sub DamageShields (x%, y%)

    Shared baseshields&, background&

    Dim dx% '                                                                      x damage location
    Dim dy% '                                                                      y damage location

    For dx% = 0 To 4 '                                                             create a damage cell 20 pixels wide
        For dy% = 0 To 8 '                                                         by 36 pixels high
            If Int(Rnd(1) * 2) - 1 Then '                                          randomly do damage to this 4x4 pixel square?
                _PutImage (x% - 80 + (dx% * 4), (y% - 536) + (dy% * 4))-(x% - 80 + (dx% * 4) + 3, (y% - 536) + (dy% * 4) + 3), background&, baseshields&, (x% + (dx% * 4), (y% - 72) + (dy% * 4))-(x% + (dx% * 4) + 3, (y% - 72) + (dy% * 4) + 3)
            End If
        Next dy%
    Next dx%

End Sub

'##################################################################################################################################

Sub UpdatePlayerShips ()

    Shared remainingdigit%, shipsremaining%, remaining%()

    Dim count% '                                                                   generic counter

    SPRITESET remainingdigit%, shipsremaining% + 1 '                               set the ship number digit to sprite digit
    SPRITEPUT 16, 667, remainingdigit% '                                           place remaining ships number at bottom of screen
    For count% = 1 To 3 '                                                          cycle through all ship image placeholders
        If shipsremaining% - 1 >= count% Then '                                    should this ship be shown at bottom of screen?
            SPRITESHOW remaining%(count%) '                                        yes, show the ship
            SPRITEPUT count% * 64, 667, remaining%(count%) '                       place the ship on the screen
        Else
            SPRITEHIDE remaining%(count%) '                                        no, hide the ship
        End If
    Next count%

End Sub

'##################################################################################################################################

Sub UpdateScore ()

    Shared score%, hiscore%, scoredigit%(), hiscoredigit%(), ufohit&, shipsremaining%

    Static shipawarded% '                                                          true if an extra ship has been awarded

    Dim s$ '                                                                       string holding the player's score padded with zeros
    Dim hs$ '                                                                      string holding the high score padded with zeros
    Dim count% '                                                                   generic counter

    s$ = Right$("000" + LTrim$(Str$(score%)), 4) '                                 pad the beginning of the score with zeros
    If score% > hiscore% Then hiscore% = score% '                                  should the high score be updated?
    For count% = 1 To 4 '                                                          cycle through all four score and high score digits
        SPRITESET scoredigit%(count%), Val(Mid$(s$, count%, 1)) + 1 '              set the corresponding digit to the score digit
        SPRITEPUT 254 + count% * 24, 17, scoredigit%(count%) '                     place the digit on the screen
        If hiscore% = score% Then '                                                does the high score need to be updated as well?
            SPRITESET hiscoredigit%(count%), Val(Mid$(s$, count%, 1)) + 1 '        yes, set the corresponding digit to high score digit
            SPRITEPUT 638 + count% * 24, 17, hiscoredigit%(count%) '               place the high score digit on the screen
        End If
    Next count%
    If (score% >= 1500) And (Not shipawarded%) Then '                              should the player be awarded with an extra ship?
        _SndPlay ufohit& '                                                         yes, play the extra ship sound
        shipawarded% = TRUE '                                                      set the flag indicating an extra ship was given
        shipsremaining% = shipsremaining% + 1 '                                    add to the pool of player ships remaining
        UpdatePlayerShips '                                                        update the player remaining ships on screen
    End If

End Sub

'##################################################################################################################################

Sub UpdatePlayerMissile ()

    Shared pmissile%, invaderhit&, showufoscore%, ufomoving&, ufohit&, ufo%, score%
    Shared player%, shieldsremain%, imissile%()

    Static hit% '                                                                  remebers which invader was last hit
    Static hittimer% '                                                             counts down time left to show invader explosion

    Dim deadguy% '                                                                 the invader, missile or ufo that was hit
    Dim shieldhit% '                                                               true if player missile hits base shield
    Dim count% '                                                                   generic counter
    Dim im% '                                                                      true if an invader missile was hit

    If hit% > 0 Then '                                                             was an invader recently hit?
        hittimer% = hittimer% - 1 '                                                yes, decrement the explosion show counter
        If hittimer% = 0 Then '                                                    done showing the explosion?
            SPRITESCORESET hit%, 0 '                                               yes, set the invader not to be seen
            SPRITEPUT -40, 0, hit% '                                               put it off the screen out of the way
            hit% = 0 '                                                             reset recently hit invader for next one
        End If
    End If
    If SPRITESCORE(pmissile%) = 1 Then '                                           is the player's missile currently traveling?
        If SPRITEY(pmissile%) = 50 Then '                                          yes, has the missile reached the top of the screen?
            SPRITESCORESET pmissile%, 0 '                                          yes, hide the player's missile
        Else '                                                                     no, missile has not reached top of screen
            SPRITEPUT SPRITEX(pmissile%), SPRITEY(pmissile%) - 2, pmissile% '      move the misile and place it on the screen
            If SPRITECOLLIDE(pmissile%, ALLSPRITES) Then '                         has the player's missile collided with anything?
                deadguy% = SPRITECOLLIDEWITH(pmissile%) '                          yes, find out what it collided with
                If deadguy% <> player% Then '                                      make sure missile doesn't collide with player ship
                    For count% = 1 To 10 '                                         cycle through all 10 possible invader missiles
                        If deadguy% = imissile%(count%) Then '                     did the missile hit an invader missile?
                            im% = TRUE '                                           yes, remember this
                        End If
                    Next count%
                    If Not im% Then '                                              was an invader missile hit?
                        If SPRITEY(deadguy%) = 52 Then '                           no, was the object hit a ufo?
                            _SndStop ufomoving& '                                  yes, stop the ufo moving sound
                            _SndPlay ufohit& '                                     play the ufo hit explosion sound
                            showufoscore% = TRUE '                                 set a flag to show the ufo's score for a brief time
                            Select Case Abs(SPRITEX(ufo%) - SPRITEX(pmissile%)) \ 10 'how accurate was player's missile?
                                Case 0 '                                           very close to center or dead center
                                    SPRITESET ufo%, 16 '                           set the ufo image to 300
                                    score% = score% + 300 '                        add 300 to the player's score
                                Case 1 '                                           close to center
                                    SPRITESET ufo%, 15 '                           set the ufo image to 200
                                    score% = score% + 200 '                        add 200 to player's score
                                Case Is > 1 '                                      on the outer edge
                                    SPRITESET ufo%, 14 '                           set the ufo image to 100
                                    score% = score% + 100 '                        add 100 to the player's score
                            End Select
                            SPRITEPUT SPRITEX(ufo%), SPRITEY(ufo%), ufo% '         display the point value image on the screen
                            SPRITESCORESET pmissile%, 0 '                          turn off the player's missile
                        Else '                                                     an invader was hit
                            _SndPlay invaderhit& '                                 play the invader hit explosion sound
                            SPRITESCORESET pmissile%, 0 '                          hide the player's missile
                            SPRITEANIMATION deadguy%, NOANIMATE, FORWARDLOOP '     turn off animation for the invader that was hit
                            SPRITESET deadguy%, 7 '                                set the invader to the explosion sprite
                            hit% = deadguy% '                                      remember that this invader was hit
                            hittimer% = 4 '                                        show explosion for four frames
                            score% = score% + SPRITESCORE(deadguy%) '              add the invader's score value to the player's score
                        End If
                    Else '                                                         an invader missile was hit
                        SPRITESCORESET pmissile%, 0 '                              invader's missile wins, turn off player's missile
                    End If
                End If
            End If
        End If
        If shieldsremain% Then '                                                   are there any base shields left?
            If SPRITEY(pmissile%) > 516 Then '                                     yes, is missle in area of base shields?
                shieldhit% = FALSE '                                               assume shields have not been hit
                For count% = -1 To 1 '                                             look ahead for shield pixels
                    If Point(SPRITEX(pmissile%) + count%, SPRITEY(pmissile%) - 15) = _RGB(0, 255, 0) Then shieldhit% = TRUE
                Next count%
                If shieldhit% Then '                                               did the player's missile hit the shields?
                    SPRITESCORESET pmissile%, 0 '                                  yes, hide the player's missile
                    DamageShields SPRITEX(pmissile%) - 8, SPRITEY(pmissile%) + 8 ' damage the shields in location where missile hit
                End If
            End If
        End If
    End If

End Sub

'##################################################################################################################################

Sub UpdatePlayer ()

    Shared player%, pmissile%, fire&

    Static speed% '                                                                used to control speed of player's ship

    If speed% = 0 Then '                                                           is it ok to move player?
        speed% = 4 '                                                               yes, reset speed controller
        If _KeyDown(19712) Then '                                                  is player pressing the right arrow key?
            If SPRITEX(player%) + 4 <= 740 Then '                                  yes, is player at the right edge of the screen?
                SPRITEPUT SPRITEX(player%) + 4, SPRITEY(player%), player% '        no, move the player's ship to the right
            End If
        End If
        If _KeyDown(19200) Then '                                                  is player pressing the left arrow key?
            If SPRITEX(player%) - 4 >= 56 Then '                                   yes, is player at the left edge of the screen?
                SPRITEPUT SPRITEX(player%) - 4, SPRITEY(player%), player% '        no, move the player's ship to the left
            End If
        End If
    Else
        speed% = speed% - 1 '                                                      no, decrement speed controller
    End If
    If _KeyDown(32) Then '                                                         is the player pressing the space bar?
        If SPRITESCORE(pmissile%) = 0 Then '                                       yes, is the player's missile already traveling?
            _SndPlay fire& '                                                       no, play the laser firing sound
            SPRITEPUT SPRITEX(player%) - 1, SPRITEY(player%), pmissile% '          put the player's missile on the screen
            SPRITESCORESET pmissile%, 1 '                                          turn the missile on
        End If
    End If
    SPRITEPUT SPRITEX(player%), SPRITEY(player%), player% '                        put the player's ship on the screen

End Sub

'##################################################################################################################################

Sub UpdateInvaders ()

    Shared invader%(), beat&(), baseshields&, background&, fps%, pmissile%
    Shared shieldsremain%, invadersremaining%, imissile%(), shipsremaining%

    Static beatsound% '                                                            keeps track of which beat sound to play next
    Static direction% '                                                            keeps track of invader direction
    Static walktimer% '                                                            keeps track of when it is ok for invaders to move
    Static walktime! '                                                             holds amount of time to wait between invader moves

    Dim highy% '                                                                   contains the y value of the lowest invader
    Dim row% '                                                                     used to keep track of invader rows
    Dim column% '                                                                  used to keep trak of invader columns
    Dim addx% '                                                                    value invaders will move horizontally
    Dim addy% '                                                                    value invaders will move vertically
    Dim im%(10) '                                                                  generic counter
    Dim count%

    If direction% = 0 Then direction% = -4 '                                       set direction for first time
    walktimer% = walktimer% + 1 '                                                  increment the walk timer
    If walktimer% >= walktime! Then '                                              is it time for the invaders to move?
        invadersremaining% = 0 '                                                   reset the invader counter
        walktimer% = 0 '                                                           yes, reset the walk timer
        beatsound% = beatsound% + 1 '                                              go to the next marching beat sound
        If beatsound% = 5 Then beatsound% = 1 '                                    cycle back to first marching beat sound
        _SndPlay beat&(beatsound%) '                                               play the marching beat sound
        addx% = direction% '                                                       the amount of horizontal invader movement
        addy% = 0 '                                                                the amount of vertical invader movement
        For row% = 5 To 1 Step -1 '                                                cycle through each row of invaders
            For column% = 1 To 11 '                                                cycle through each column of invaders in each row
                If SPRITESCORE(invader%(row%, column%)) <> 0 Then '                   is the invader still on the screen?
                    invadersremaining% = invadersremaining% + 1 '                  count the number of invaders remaining for later use
                    If SPRITEY(invader%(row%, column%)) > highy% Then '            yes, is it the lowest one seen so far?
                        highy% = SPRITEY(invader%(row%, column%)) '                yes, save its y location for later use
                    End If
                    If SPRITEX(invader%(row%, column%)) + direction% = 24 Or SPRITEX(invader%(row%, column%)) + direction% = 776 Then ' will invader leave the screen?
                        addx% = 0 '                                                yes, stop invaders horizontal movement
                        addy% = 32 '                                               invaders must move down instead
                    End If
                End If
            Next column%
        Next row%
        If addy% = 32 Then '                                                       are invaders going to drop down?
            direction% = -direction% '                                             tyes, after invaders move down they go in new direction
            If highy% + addy% = 516 Then '                                         will invader cover the top half of base shields?
                _PutImage (0, 0), background&, baseshields&, (80, 464)-(719, 495) 'yes, top half of base shields will get erased
            ElseIf highy% + addy% = 548 Then '                                     will invader cover all of the base shields?
                _PutImage (0, 0), background&, baseshields&, (80, 464)-(719, 528) 'yes, all of base shields will get erased
                shieldsremain% = FALSE '                                           shields completely gone
            End If
        End If
        walktime! = (invadersremaining% * (fps% / 55)) - (fps% / 55) '             calculate amount of time until next invader walk
        For row% = 1 To 5 '                                                        cycle through each row of invaders
            For column% = 1 To 11 '                                                cycle through each column of invaders in each row
                If SPRITESCORE(invader%(row%, column%)) <> 0 Then '                if the sprite is showing put it on the screen
                    SPRITENEXT invader%(row%, column%) '                           go to the next animation cell
                    SPRITEPUT SPRITEX(invader%(row%, column%)) + addx%, SPRITEY(invader%(row%, column%)) + addy%, invader%(row%, column%)
                End If
            Next column%
        Next row%
    Else
        For row% = 1 To 5 '                                                        cycle through each row of invaders
            For column% = 1 To 11 '                                                cycle through each column of invaders in each row
                If SPRITESCORE(invader%(row%, column%)) <> 0 Then '                if the sprite is showing put it on the screen
                    SPRITEPUT SPRITEX(invader%(row%, column%)), SPRITEY(invader%(row%, column%)), invader%(row%, column%)
                End If '                                                           used for non-animation frames
            Next column%
        Next row%
    End If
    If invadersremaining% = 0 Then '                                               is the screen clear of invaders?
        walktimer% = 0 '                                                           yes, reset walk timer
        beatsound% = 0 '                                                           start the marching beat sound back from the beginning
        direction% = 0 '                                                           rest the invader direction
    End If
    If highy% = 612 Then PlayerLostShip shipsremaining% '                          the invasion has begun! Lock up your wives and daughters!


End Sub

'##################################################################################################################################

Sub UpdateUfo ()

    Shared ufo%, ufomoving&, ufohit&, showufoscore%, fps%, pmissile%

    Static scoretimer% '                                                           count down timer indicating how long score shows
    Static speed% '                                                                speed controller for the ufo
    Static ufotimer% '                                                             make sure that ufo shows up only once every 30 sec
    Static ufoflying% '                                                            true if ufo flying across screen

    If ufotimer% = 0 Then '                                                        has it been at leat 30 seconds or first time?
        If (Not showufoscore%) And (Not ufoflying%) Then '                         yes, ufo not on screen and not showing score?
            If Int(Rnd(1) * 1250) = 750 Then '                                     should a ufo be created now?
                SPRITEPUT 832, 52, ufo% '                                          yes, place ufo just off the screen to the right
                _SndLoop ufomoving& '                                              start playing the ufo moving sound
                ufoflying% = TRUE '                                                the ufo is now flying across the screen
                scoretimer% = fps% '                                               set score timer to 1 sec in case the ufo gets hit
            End If
        ElseIf showufoscore% Then '                                                is the ufo score currently being displayed?
            If _SndPlaying(ufomoving&) Then '                                      yes, is the ufo moving sound still playing?
                _SndStop ufomoving& '                                              yes, stop the ufo moving sound
                _SndPlay ufohit& '                                                 play the ufo being hit sound
            End If
            scoretimer% = scoretimer% - 1 '                                        decrement the show score timer
            If scoretimer% = 0 Then '                                              has the show score timer reached 0?
                showufoscore% = FALSE '                                            don't show the ufo's score any longer
                SPRITESET ufo%, 13 '                                               set the sprite back to the ufo image
                SPRITEPUT -40, 0, ufo% '                                           put ufo off screen out of the way
                ufotimer% = 30 * fps% '                                            wait at least 30 seconds until next ufo encounter
                ufoflying% = FALSE
            Else
                SPRITEPUT SPRITEX(ufo%), SPRITEY(ufo%), ufo% '                     display the ufo screen
            End If
        Else '                                                                     ufo is currently on the screen moving
            speed% = 1 - speed% '                                                  flip/flop used to slow ufo to half player's speed
            If speed% = 0 Then '                                                   time to move?
                SPRITEPUT SPRITEX(ufo%) - 1, SPRITEY(ufo%), ufo% '                 yes, update ufo position on screen
                If SPRITEX(ufo%) = -32 Then '                                      has the ufo flown off the left side of screen?
                    _SndStop ufomoving& '                                          yes, stop the ufo moving sound
                    ufoflying% = FALSE '                                           ufo is no longer flying across the screen
                    ufotimer% = 30 * fps% '                                        wait at least 30 seconds until next ufo encounter
                End If
            Else
                SPRITEPUT SPRITEX(ufo%), SPRITEY(ufo%), ufo% '                     show ufo on non animation frames
            End If
        End If
    Else
        If ufotimer% > 0 Then ufotimer% = ufotimer% - 1 '                          decrement the count down timer
    End If

End Sub

'##################################################################################################################################

Sub NewLevel ()

    Shared background&, ufomoving&, baseshields&, level%, invader%(), beat&()
    Shared player%, ufo%, shieldsremain%, pmissile%, imissile%(), fps%

    Static firsttime% '                                                            no 2 second delay at the start of the first level

    Dim row% '                                                                     the current row of invaders being drawn
    Dim column% '                                                                  the current invader being drawn in column
    Dim x% '                                                                       the x location of each invader
    Dim y% '                                                                       the y location of each invader

    _PutImage (0, 36), background& '                                               place background image on screen
    _PutImage (80, 500), baseshields& '                                            place base shields image on screen
    For count% = 1 To 10 '                                                         cycle through all 10 possible invader missiles
        SPRITESCORESET imissile%(count%), 0 '                                      turn any lingering ones off
        SPRITEPUT -40, 0, imissile%(count%) '                                      place them off the screen and out of the way for now
    Next count%
    If ((level% - 1) * 32) + 356 = 516 Then '                                      will invaders be generated over top of base shields?
        _PutImage (0, 0), background&, baseshields&, (80, 464)-(719, 495) '        yes, top half of base shields will get erased
    ElseIf ((level% - 1) * 32) + 356 = 548 Then '                                  will invaders be genrated over all of base shields?
        _PutImage (0, 0), background&, baseshields&, (80, 464)-(719, 528) '        yes, all of base shields will get erased
        shieldsremain% = FALSE '                                                   shields completely gone
    End If
    SPRITEPUT SPRITEX(player%), SPRITEY(player%), player% '                        put the player's ship on the screen
    count% = fps% * 2 '                                                            calculate 2 seconds worth of frames
    If Not firsttime% Then '                                                       is this the first level being played?
        firsttime% = TRUE '                                                        yes, set flag
    Else '                                                                         no, flag is already set, first level already played
        Do '                                                                       create a two second pause between levels
            _Limit fps% '                                                          limit loop to this many frames per second
            UpdateUfo '                                                            allow ufo to keep moving if on screen
            UpdatePlayer '                                                         allow player to keep moving ship
            UpdatePlayerMissile '                                                  allow player to fire a missile while waiting!
            count% = count% - 1 '                                                  decrement count down timer
            _Display '                                                             show each frame change to the screen
        Loop Until count% = 0 '                                                    begin playing next level after 2 seconds
    End If
    For row% = 1 To 5 '                                                            cycle through all 5 rows of invaders
        y% = ((level% - 1) * 32) + 100 + ((row% - 1) * 64) '                       calculate the y location of this row
        For column% = 1 To 11 '                                                    cycle through all 11 columns of invaders
            _Limit fps%
            UpdateUfo '                                                            keep ufo moving between levels
            UpdatePlayer '                                                         allow player to move between levels
            x% = 80 + (column% - 1) * 64 '                                         calculate the x value of this invader
            Select Case row% '                                                     which row is currently being generated?
                Case 1 '                                                           top row
                    SPRITESET invader%(row%, column%), 1 '                         set the invader image to top row image
                    SPRITEANIMATESET invader%(row%, column%), 1, 2 '               set the animation cells associated with this invader
                    SPRITESCORESET invader%(row%, column%), 30 '                   set the score value of this invader
                Case 2 To 3 '                                                      2nd & 3rd rows
                    SPRITESET invader%(row%, column%), 3 '                         set the invader image to 2nd & 3rd row image
                    SPRITEANIMATESET invader%(row%, column%), 3, 4 '               set the animation cells associated with this invader
                    SPRITESCORESET invader%(row%, column%), 20 '                   set the score value of this invader
                Case 4 To 5 '                                                      4th & 5th rows
                    SPRITESET invader%(row%, column%), 5 '                         set the invader image to 4th & 5th row image
                    SPRITEANIMATESET invader%(row%, column%), 5, 6 '               set the animation cells associated with this invader
                    SPRITESCORESET invader%(row%, column%), 10 '                   set the score value of this invader
            End Select
            _SndPlay beat&(4) '                                                    play a pulsating beat sound as invaders being drawn
            SPRITEPUT x%, y%, invader%(row%, column%) '                            draw the current invader to the screen
            _Display '                                                             show each invader being drawn
        Next column%
    Next row%

End Sub

'##################################################################################################################################

Sub DrawScreen ()

    Shared remaining%(), scoredigit%(), hiscoredigit%(), background&
    Shared fontsheet%, remainingdigit%, player%, base1%, base2%, baseshields&
    Shared letter As letters

    Dim count% '                                                                   generic counter used in subroutine

    _PutImage (0, 36), background& '                                               place background image on screen
    Line (0, 636)-(799, 639), _RGB(0, 254, 0), BF '                                draw green line toward bottom of screen
    SPRITESTAMP 62, 17, letter.s '                                                 place letter S in word SCORE<1>
    SPRITESTAMP 86, 17, letter.c '                                                 place letter C in word SCORE<1>
    SPRITESTAMP 110, 17, letter.o '                                                place letter O in word SCORE<1>
    SPRITESTAMP 134, 17, letter.r '         Top row letters centered on 17         place letter R in word SCORE<1>
    SPRITESTAMP 158, 17, letter.e '                                                place letter E in word SCORE<1>
    SPRITESTAMP 182, 17, letter.lthan '                                            place letter < in word SCORE<1>
    SPRITESTAMP 206, 17, letter.one '                                              place letter 1 in word SCORE<1>
    SPRITESTAMP 230, 17, letter.gthan '                                            place letter > in word SCORE<1>
    SPRITESTAMP 446, 17, letter.h '                                                place letter H in word HI-SCORE
    SPRITESTAMP 470, 17, letter.i '                                                place letter I in word HI-SCORE
    SPRITESTAMP 494, 17, letter.dash '                                             place letter - in word HI-SCORE
    SPRITESTAMP 518, 17, letter.s '                                                place letter S in word HI-SCORE
    SPRITESTAMP 542, 17, letter.c '                                                place letter C in word HI-SCORE
    SPRITESTAMP 566, 17, letter.o '                                                place letter O in word HI-SCORE
    SPRITESTAMP 590, 17, letter.r '                                                place letter R in word HI-SCORE
    SPRITESTAMP 614, 17, letter.e '                                                place letter E in word HI-SCORE
    SPRITESTAMP 593, 667, letter.c '                                               place letter C in word CREDIT<1>
    SPRITESTAMP 617, 667, letter.r '                                               place letter R in word CREDIT<1>
    SPRITESTAMP 641, 667, letter.e '       bottom row letters centered on 667      place letter E in word CREDIT<1>
    SPRITESTAMP 665, 667, letter.d '                                               place letter D in word CREDIT<1>
    SPRITESTAMP 689, 667, letter.i '                                               place letter I in word CREDIT<1>
    SPRITESTAMP 713, 667, letter.t '                                               place letter T in word CREDIT<1>
    SPRITESTAMP 737, 667, letter.lthan '                                           place letter < in word CREDIT<1>
    SPRITESTAMP 761, 667, letter.one '                                             place number 1 in word CREDIT<1>
    SPRITESTAMP 785, 667, letter.gthan '                                           place letter > in word CREDIT<1>
    SPRITEPUT 399, 620, player% '                                                  place player base ship on the screen
    For count% = 1 To 3
        SPRITEPUT count% * 64, 667, remaining%(count%) '                           place the remaining ships at bottom of the screen
    Next count%
    SPRITEHIDE remaining%(3) '                                                     hide the 3rd ship (extra ship) for now
    SPRITEPUT 16, 667, remainingdigit% '                                           place remaining ships number at bottom of screen
    For count% = 1 To 4
        SPRITEPUT 254 + count% * 24, 17, scoredigit%(count%) '                     place the score digits at the top of screen
        SPRITEPUT 638 + count% * 24, 17, hiscoredigit%(count%) '                   place the high score digits at the top of screen
    Next count%
    SPRITESTAMP 100, 516, base1% '                                                 first base shield top left quarter
    SPRITESTAMP 100, 548, base2% '                                                 first base shield bottom left quarter
    SPRITESTAMP 280, 516, base1% '                                                 second base shield top left quarter
    SPRITESTAMP 280, 548, base2% '                                                 second base shield bottom left quarter
    SPRITESTAMP 456, 516, base1% '                                                 third base shield top left quarter
    SPRITESTAMP 456, 548, base2% '                                                 third base shield bottom left quarter
    SPRITESTAMP 636, 516, base1% '                                                 fourth base shield top left quarter
    SPRITESTAMP 636, 548, base2% '                                                 fourth base shield bottom left quarter
    SPRITEFLIP base1%, HORIZONTAL '                                                flip top half horizontally
    SPRITEFLIP base2%, HORIZONTAL '                                                flip bottom half horizontally
    SPRITESTAMP 164, 516, base1% '                                                 first base shield top right quarter
    SPRITESTAMP 164, 548, base2% '                                                 first base shield bottom right quarter
    SPRITESTAMP 344, 516, base1% '                                                 second base shield top right quarter
    SPRITESTAMP 344, 548, base2% '                                                 second base shield bottom right quarter
    SPRITESTAMP 520, 516, base1% '                                                 third base shield top right quarter
    SPRITESTAMP 520, 548, base2% '                                                 third base shield bottom right quarter
    SPRITESTAMP 700, 516, base1% '                                                 fourth base shield to right quarter
    SPRITESTAMP 700, 548, base2% '                                                 fourth base shield bottom right quarter
    _PutImage (0, 0), _Dest, baseshields&, (80, 500)-(719, 563) '                  place copy of shields in shield image holder

End Sub

'##################################################################################################################################

Sub LoadGraphics ()

    Shared letter As letters, scoredigit%(), hiscoredigit%(), imissile%()
    Shared invader%(), remaining%(), background&, mainsheet%
    Shared missilesheet%, pmissile%, ufo%, player%, base1%, base2%, fontsheet%
    Shared remainingdigit%, baseshields&

    Dim counter% '                                                                 generic counter used in subroutine
    Dim invader1%, invader2%, invader3% '                                          temporary invader sprites used for copying
    Dim row%, column% '                                                            used when creating the 55 invader sprites
    Dim imissile1%, imissile2%, imissile3% '                                       temporary invader missile sprites used for copying

    '*
    '*                                                                             DEFINE STATIC IMAGES
    '*
    background& = _LoadImage("invadersbackground.png", 32) '                       background image of planet and stars
    baseshields& = _NewImage(640, 64, 32) '                                        image to hold copy of base shields
    '*
    '*                                                                             DEFINE ENEMY AND PLAYER SPRITES
    '*
    mainsheet% = SPRITESHEETLOAD("invaders64x32.png", 64, 32, _RGB(1, 1, 1)) '     main sprite sheet containing player and invaders
    invader1% = SPRITENEW(mainsheet%, 1, DONTSAVE) '                               top row invader sprite
    SPRITECOLLIDETYPE invader1%, PIXELDETECT '                                     this sprite uses pixel accurate collision detection
    invader2% = SPRITENEW(mainsheet%, 3, DONTSAVE) '                               2nd & 3rd row invader sprite
    SPRITECOLLIDETYPE invader2%, PIXELDETECT '                                     this sprite uses pixel accurate collision detection
    invader3% = SPRITENEW(mainsheet%, 5, DONTSAVE) '                               4th & 5th row invader sprite
    SPRITECOLLIDETYPE invader3%, PIXELDETECT '                                     this sprite uses pixel accurate collision detection
    player% = SPRITENEW(mainsheet%, 9, SAVE) '                                     player base ship sprite
    SPRITECOLLIDETYPE player%, PIXELDETECT '                                       this sprite uses pixel accurate collision detection
    ufo% = SPRITENEW(mainsheet%, 13, SAVE) '                                       ufo sprite
    SPRITECOLLIDETYPE ufo%, PIXELDETECT '                                          this sprite uses pixel accurate collision detection
    SPRITESCORESET ufo%, 100 '                                                     this sprite is worth a minimum 100 points when hit
    base1% = SPRITENEW(mainsheet%, 8, DONTSAVE) '                                  top left quarter of base shield
    base2% = SPRITENEW(mainsheet%, 12, DONTSAVE) '                                 bottom left quarter of base shield
    For count% = 0 To 3 '                                                          create 3 player ships to show at bottom of screen
        remaining%(count%) = SPRITENEW(mainsheet%, 9, SAVE) ' allow hide/show '    remaining player base ships on bottom of screen
    Next count%
    For row% = 1 To 5 '                                                            create a sprite array of 55 invader sprites
        For column% = 1 To 11 '                                                    with each invader sprite in its correct row
            Select Case row% '                                                     which row is being created?
                Case 1 '                                                           top row
                    invader%(row%, column%) = SPRITECOPY(invader1%) '              sprites 1 through 11
                Case 2 To 3 '                                                      2nd & 3rd rows
                    invader%(row%, column%) = SPRITECOPY(invader2%) '              sprites 12 through 33
                Case 4 To 5 '                                                      4th & 5th rows
                    invader%(row%, column%) = SPRITECOPY(invader3%) '              sprites 34 through 55
            End Select
        Next column%
    Next row%
    '*
    '*                                                                             DEFINE FONT SPRITES
    '*
    fontsheet% = SPRITESHEETLOAD("invadersfont.png", 20, 28, _RGB(1, 1, 1)) '      sprite sheet containing fonts needed in game
    letter.h = SPRITENEW(fontsheet%, 12, DONTSAVE) '                               font letter H
    letter.i = SPRITENEW(fontsheet%, 13, DONTSAVE) '                               font letter I
    letter.s = SPRITENEW(fontsheet%, 15, DONTSAVE) '                               font letter S
    letter.c = SPRITENEW(fontsheet%, 16, DONTSAVE) '                               font letter C
    letter.o = SPRITENEW(fontsheet%, 17, DONTSAVE) '                               font letter O
    letter.r = SPRITENEW(fontsheet%, 18, DONTSAVE) '                               font letter R
    letter.e = SPRITENEW(fontsheet%, 19, DONTSAVE) '                               font letter E
    letter.d = SPRITENEW(fontsheet%, 20, DONTSAVE) '                               font letter D
    letter.t = SPRITENEW(fontsheet%, 21, DONTSAVE) '                               font letter T
    letter.dash = SPRITENEW(fontsheet%, 14, DONTSAVE) '                            font letter -
    letter.lthan = SPRITENEW(fontsheet%, 11, DONTSAVE) '                           font letter <
    letter.gthan = SPRITENEW(fontsheet%, 22, DONTSAVE) '                           font letter >
    letter.one = SPRITENEW(fontsheet%, 2, DONTSAVE) '                              font letter 1
    For count% = 1 To 4 '                                                          create 4 digits for score and high score
        scoredigit%(count%) = SPRITENEW(fontsheet%, 1, SAVE) '                     score digits at the top of screen
        hiscoredigit%(count%) = SPRITENEW(fontsheet%, 1, SAVE) '                   high score digits at the top of screen
    Next count%
    remainingdigit% = SPRITENEW(fontsheet%, 4, SAVE) '                             digit showing ships remaining at bottom of screen
    '*
    '*                                                                             DEFINE MISSILE SPRITES
    '*
    missilesheet% = SPRITESHEETLOAD("invadersmissiles.png", 12, 28, _RGB(1, 1, 1)) 'sprite sheet containing various missiles
    pmissile% = SPRITENEW(missilesheet%, 1, SAVE) '                            the player missile sprite (normal missile)
    SPRITECOLLIDETYPE pmissile%, PIXELDETECT '                                     this missile uses pixel accurate collision detection
    imissile1% = SPRITENEW(missilesheet%, 1, DONTSAVE) '                           invader missile 1 sprite (normal missile)
    SPRITECOLLIDETYPE imissile1%, PIXELDETECT '                                    this missile uses pixel accurate collision detection
    imissile2% = SPRITENEW(missilesheet%, 2, DONTSAVE) '                           invader missile 2 sprite (throbbing missile)
    SPRITEANIMATESET imissile2%, 2, 5 '                                            this sprite uses these sheet cells for animation
    SPRITEANIMATION imissile2%, ANIMATE, FORWARDLOOP '                             activate auto animation for this sprite
    SPRITECOLLIDETYPE imissile2%, PIXELDETECT '                                    this missile uses pixel accurate collision detection
    imissile3% = SPRITENEW(missilesheet%, 6, DONTSAVE) '                           invader missile 3 sprite (screwball missile)
    SPRITEANIMATESET imissile3%, 6, 9 '                                            this sprite uses these sheet cells for animation
    SPRITEANIMATION imissile3%, ANIMATE, FORWARDLOOP '                             activate auto animation for this sprite
    SPRITECOLLIDETYPE imissile3%, PIXELDETECT '                                    this missile uses pixel accurate collision detection
    For count% = 1 To 10 '                                                         create sprite array of 10 invader missiles
        Select Case count% '                                                       which missiles should be created?
            Case 1 To 4 '                                                          normal missiles
                imissile%(count%) = SPRITECOPY(imissile1%) '                       create 4 normal missiles
            Case 5 To 7 '                                                          throbbing missiles
                imissile%(count%) = SPRITECOPY(imissile2%) '                       create 3 throbbing missiles
            Case 8 To 10 '                                                         screwball missiles
                imissile%(count%) = SPRITECOPY(imissile3%) '                       create 3 screwball missiles
        End Select
    Next count%

End Sub

'##################################################################################################################################

Sub LoadSounds ()

    Shared beat&(), playerhit&, invaderhit&, fire&, ufomoving&, ufohit&

    beat&(1) = _SndOpen("beat1.ogg", "VOL, SYNC") '                                first beat of four beat marching sound
    beat&(2) = _SndOpen("beat2.ogg", "VOL, SYNC") '                                second beat of four beat marching sound
    beat&(3) = _SndOpen("beat3.ogg", "VOL, SYNC") '                                third beat of four beat marching sound
    beat&(4) = _SndOpen("beat4.ogg", "VOL, SYNC") '                                fourth beat of four beat marching sound
    playerhit& = _SndOpen("explosion.ogg", "VOL, SYNC") '                          player base ship getting hit explosion sound
    invaderhit& = _SndOpen("kill.ogg", "VOL, SYNC") '                              invader getting hit explosion sound
    fire& = _SndOpen("laser.ogg", "VOL, SYNC") '                                   player base ship laser cannon firing sound
    ufomoving& = _SndOpen("ufo.ogg", "VOL, SYNC") '                                ufo moving across the screen sound
    ufohit& = _SndOpen("ufokill.ogg", "VOL, SYNC") '                               ufo getting hit funky explosion sound

End Sub

'##################################################################################################################################

'$INCLUDE:'sprite.bi'

