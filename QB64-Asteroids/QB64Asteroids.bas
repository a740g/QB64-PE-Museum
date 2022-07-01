'+----------------------------------------------------------------------------+
'|                   QB64 Asteroids! by Terry Ritchie                         |
'|                       terry.ritchie@gmail.com                              |
'|                                                                            |
'|                         Programmed in QB64                                 |
'|                            www.qb64.net                                    |
'|                           July 29th 2011                                   |
'|                                                                            |
'| This program was created as a test bed for Ritchie's Sprite Library. It    |
'| has been released as freeware. Please pass a copy along to anyone who      |
'| might like it. If you use any of the code inside, or modify the game,      |
'| please give credit where credit is due. Thank you and have fun!            |
'|                                                                            |
'| A special thanks to Rob (Galleon) the creator of QB64, for allowing old-   |
'| school programmers to continue their craft.                                |
'+----------------------------------------------------------------------------+

'$INCLUDE:'spritetop.bi'

Const FALSE = 0, TRUE = Not FALSE ' boolean constants
Const PI = 3.1415926 '              I like with ice cream

Type SPARK '                holds explosion spark information
    count As Integer '      used to time how long spark will last
    x As Single '           x location on screen of spark
    y As Single '           y location on screen of spark
    xdir As Single '        the horizontal vector of the spark
    ydir As Single '        the vertical vector of the spark
    speed As Single '       the speed the spark is traveling
    fade As Integer '       the current amount the spark is fading
End Type

Type TOPTEN '               holds top ten high score information
    initials As String * 3 'the player's initials
    score As Double '       the player's high score
End Type

ReDim sparks(0) As SPARK '  GFX: array to hold collision and explosion pixels
ReDim rocks%(0) '           GFX: the asteroids flying around on the screen
Dim rock%(3, 3) '           GFX: the nine asteroid sprites to choose from (rock%(size, rock)  size = 1 to 3, rock = 1 to 3)
Dim lfont%(35) '            GFX: the large number and letter fonts
Dim sfont%(9) '             GFX: the small number fonts
Dim round%(5) '             GFX: the player's five bullet rounds
Dim sround%(3) '            GFX: the saucer's three bullet rounds
Dim rocksheet128% '         GFX: the sprite sheet containing the large asteroid images
Dim rocksheet64% '          GFX: the sprite sheet containing the medium asteroid images
Dim rocksheet32% '          GFX: the sprite sheet containing the small asteroid images
Dim lfontsheet% '           GFX: the sprite sheet containing the large number and letter fonts
Dim sfontsheet% '           GFX: the sprite sheet containing the small number fonts
Dim shipsheet% '            GFX: the sprite sheet containing the player ship images
Dim roundsheet% '           GFX: the sprite sheet containing the bullet rounds
Dim bsaucersheet% '         GFX: the sprite sheet containing the big saucer image
Dim lsaucersheet% '         GFX: the sprite sheet containing the little saucer image
Dim ship% '                 GFX: the player's ship
Dim extraship% '            GFX: inmages of the player ships remaining
Dim bsaucer% '              GFX: the big flying saucer
Dim lsaucer% '              GFX: the little flying saucer
Dim saucer% '               GFX: the flying saucer currently on screen
Dim icon& '                 GFX: the game window icon
Dim explode&(3) '           SND: the three explosion sounds in game
Dim beat&(1) '              SND: the jaws beats in the background
Dim thrust& '               SND: ship thrusting forward sound
Dim pfire& '                SND: player ship firing sound
Dim extralife& '            SND: extra ship awarded sound
Dim bigsaucer& '            SND: the big saucer flying sound
Dim littlesaucer& '         SND: the little saucer flying sound (run! hide!)
Dim hiscore(10) As TOPTEN ' the top ten high scores
Dim level% '                the current game level
Dim score& '                the surrent game score
Dim hiscore& '              the overall high score
Dim shipsremaining% '       player ships remaining in game
Dim rocksleft% '            the number of small rocks remaining in the level
Dim newlevelwait% '         time to pause between levels
Dim beattimer! '            time to pause between background beat sounds
Dim intro% '                true when game in intro screen mode
Dim saucerflying% '         true when a saucer is on screen
Dim playerdead% '           true when player has died
Dim deathfinished% '        true when last death sequence finished
Dim enter% '                true when player presses ENTER to start game
Dim coin% '                 true when player inserts coin
Dim gameover% '             true when a game has ended

Screen _NewImage(1024, 768, 32) '                                              set up 1024x768 screen with 32bit color
Cls '                                                                          clear the screen to remove alpha blending
_ScreenMove _Middle '                                                          move the game screen to center of player screen
icon& = _LoadImage("aicon.bmp", 32) '                                          load the game window icon
_Icon icon& '                                                                  set the icon image
_FreeImage icon& '                                                             icon image no longer needed
_Title "QB64 Asteroids!" '                                                     give the window a title
Randomize Timer '                                                              seed the random number generator
LoadSounds '                                                                   load the game sounds
LoadGraphics '                                                                 load the game graphics
LoadHiScores '                                                                 load the high scores
Do '                                                                           start the main loop
    IntroScreen '                                                              show the intro screen
    level% = 1 '                                                               start the game at level 1
    score& = 0 '                                                               reset the player score
    shipsremaining% = 3 '                                                      set the amount of ships player has
    beattimer! = 32 '                                                          set the beat sound timer
    newlevelwait% = 96 '                                                       set the amount of wait time between levels
    playerdead% = FALSE '                                                      tell the program the player is alive and well
    NewLevel '                                                                 create a new level
    Do '                                                                       start game loop
        Do '                                                                   start of level loop
            _Limit 32 '                                                        limit game play to 32 frames per second
            Cls '                                                              clear the game screen
            deathfinished% = FALSE '                                           make sure death sequence is seen at end
            UpdateSparks '                                                     move any sparks that may be on screen
            UpdateRocks '                                                      update the asteroid positions on screen
            UpdatePlayer '                                                     check and update the player's movements
            If playerdead% Then UpdatePlayerDeath '                            update player death routines
            UpdateUfo '                                                        update ufo movement on screen
            UpdateBullets '                                                    move any bullets that may be on screen
            UpdateCollisions '                                                 handle any collisions that may have occured
            UpdateScore '                                                      update the player's score, high score and ships
            _Display '                                                         display the results of previous subs on screen
        Loop Until (rocksleft% = 0) Or (shipsremaining% = 0) '                 end the level loop
        If newlevelwait% > 0 Then newlevelwait% = newlevelwait% - 1 '          countdown until next level can be shown
        If newlevelwait% = 0 Then '                                            has the countdown completed?
            level% = level% + 1 '                                              yes, increment the game level
            If level% > 9 Then level% = 9 '                                    generate no more than 12 large rocks
            NewLevel '                                                         create a new level
            newlevelwait% = 96 '                                               reset the countdown timer
            beattimer! = 32 '                                                  reset the beat sound timer
        End If
    Loop Until (shipsremaining% = 0) And deathfinished% '                      end the game loop
    gameover% = TRUE '                                                         inform the intro screen that a game has ended
Loop '                                                                         end the main loop
End

'##################################################################################################################################

Sub UpdateHiScores ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Gets the initials of the player that achieved a high score and saves them and the score to the high score file.                |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared hiscore() As TOPTEN, score&

    Dim toolong% '                                                                 2 minute countdown timer that leaves when reached
    Dim letter%(3) '                                                               the three player initials
    Dim currentletter% '                                                           the current initial being selected
    Dim keytimer% '                                                                timer used to keep letters from going by too fast
    Dim finished% '                                                                true when player finished entering initials

    toolong% = 3840 '                                                              leaves loop when 2 minutes elapsed (3840 frames)
    letter%(1) = 65 '                                                              set first letter in initials to "A"
    letter%(2) = 32 '                                                              set second letter in initials to " "
    letter%(3) = 32 '                                                              set third letter in initials to " "
    currentletter% = 1 '                                                           current intital being changed
    finished% = FALSE '                                                            not finished yet
    Do '                                                                           start the initial selection loop here
        _Limit 32 '                                                                limit updates to 32fps
        Cls '                                                                      clear the screen
        toolong% = toolong% - 1 '                                                  decrement the 2 minute countdown timer
        If toolong% = 0 Then Exit Do '                                             if 2 minutes have elapased then exit loop
        UpdateScore '                                                              show the score and high score on screen
        DrawText 10, 250, "YOUR SCORE IS ONE OF THE 10 BEST" '                     inform the player that they are an asteroids god
        DrawText 10, 300, "PLEASE ENTER YOUR INITIALS" '                           and instruct them on how to enter their initials
        DrawText 10, 350, "PUSH ROTATE TO SELECT LETTER"
        DrawText 10, 400, "PUSH HYPERSPACE WHEN LETTER CORRECT"
        DrawText 442, 500, Chr$(letter%(1)) + " " + Chr$(letter%(2)) + " " + Chr$(letter%(3)) 'draw the initials on the screen
        Line (454, 520)-(482, 520), _RGB(128, 128, 128) '                          first letter underline
        Line (511, 520)-(539, 520), _RGB(128, 128, 128) '                          second letter underline
        Line (568, 520)-(596, 520), _RGB(128, 128, 128) '                          third letter underline
        If _KeyDown(19712) And keytimer% = 0 Then '                                is the player pressing the right arrow key?
            letter%(currentletter%) = letter%(currentletter%) + 1 '                yes, increment the ASCII value of the letter
            If letter%(currentletter%) = 91 Then letter%(currentletter%) = 65 '    has the ASCII value gone beyond Z? set to A if so
            keytimer% = 8 '                                                        next keypress won't be seen for 8 frames
        End If
        If _KeyDown(19200) And keytimer% = 0 Then '                                is the player pressing the left arrow key?
            letter%(currentletter%) = letter%(currentletter%) - 1 '                yes, decrement the ASCII value of the letter
            If letter%(currentletter%) = 64 Then letter%(currentletter%) = 90 '    has the ASCII value gone below A? set to Z if so
            keytimer% = 8 '                                                        next keypress won't be seen for 8 frames
        End If
        If _KeyDown(20480) And keytimer% = 0 Then '                                is the player pressing the down arrow key?
            currentletter% = currentletter% + 1 '                                  yes, move to the next letter
            If currentletter% = 4 Then '                                           is the next letter too far?
                finished% = TRUE '                                                 yes, set the finished flag
            Else '                                                                 no, still within the 3 initials
                letter%(currentletter%) = 65 '                                     set this letter to "A"
            End If
            keytimer% = 8 '                                                        next keypress won't be seen for 8 frames
        End If
        If keytimer% > 0 Then keytimer% = keytimer% - 1 '                          decrement the keypress timer if needed
        _Display '                                                                 display the results of the previous commands on screen
    Loop Until finished% '                                                         continue looping until player finished
    If toolong% = 0 Then '                                                         did 2 minutes elapse?
        If letter%(2) = 32 Then letter%(2) = 65 '                                  yes, set the second letter to "A" if it's a space
        If letter%(3) = 32 Then letter%(3) = 65 '                                  set the third letter to "A" if it's a space
    End If
    hiscore(10).score = score& '                                                   set the last high score array container to score
    hiscore(10).initials = Chr$(letter%(1)) + Chr$(letter%(2)) + Chr$(letter%(3)) 'set the last high score array container to initials
    SortHiScores '                                                                 sort the new high score into proper order
    SaveHiScores '                                                                 save the new high score to the high score file

End Sub

'##################################################################################################################################

Sub SortHiScores ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Bubble sorts the high scores into descending order.                                                                            |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared hiscore() As TOPTEN

    Dim count1% '                                                                  generic counter
    Dim count2% '                                                                  generic counter

    For count1% = 1 To 10 '                                                        cycle through the high score array 10 times
        For count2% = 1 To 10 '                                                    cycle through the high score array 10 more times
            If hiscore(count1%).score > hiscore(count2%).score Then '              is the lower score greater than the score above?
                Swap hiscore(count1%), hiscore(count2%) '                          yes, swap the array values with each other
            End If
        Next count2%
    Next count1%

End Sub

'##################################################################################################################################

Sub SaveHiScores ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Saves the 10 high scores to the high score file.                                                                               |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared hiscore() As TOPTEN

    Dim filenum% '                                                                 the next available file handle
    Dim count% '                                                                   generic counter

    filenum% = FreeFile '                                                          get the next available file handle
    Open "asteroids.hi" For Output As #filenum% '                                  open the high score file for output
    For count% = 1 To 10 '                                                         cycle through all 10 high score array containers
        Print #filenum%, hiscore(count%).initials '                                print the player's initials to the file
        Print #filenum%, hiscore(count%).score '                                   print the player's high score to the file
    Next count%
    Close #filenum% '                                                              close the high score file

End Sub

'##################################################################################################################################

Sub LoadHiScores ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Load the high scores from the high score file or creates the file if it does not exist.                                        |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared hiscore() As TOPTEN, hiscore&

    Dim filenum% '                                                                 the next available file handle
    Dim count% '                                                                   generic counter

    filenum% = FreeFile '                                                          get the next available file handle
    Open "asteroids.hi" For Append As #filenum% '                                  open the high score file for appending
    If LOF(filenum%) Then '                                                        is the length of the file greater than 0?
        Close #filenum% '                                                          yes, the file exists, close the file
        filenum% = FreeFile '                                                      get the next available file handle
        Open "asteroids.hi" For Input As #filenum% '                               open the high score file for input
        For count% = 1 To 10 '                                                     cycle through all 10 high score array containers
            Input #filenum%, hiscore(count%).initials '                            get the player's initials
            Input #filenum%, hiscore(count%).score '                               get the player's high score
        Next count%
        Close #filenum% '                                                          close the high score file
        hiscore& = hiscore(1).score '                                              set the game's highest high score
    Else '                                                                         the high score file does not exist
        Close #filenum% '                                                          close the open appended file
        Kill "asteroids.hi" '                                                      kill temporary file that was created for appending
        hiscore(1).initials = "TWR" '                                              create a list of 10 high scores and player initials
        hiscore(1).score = 100
        hiscore(2).initials = "GAL" '                                              Galleon!
        hiscore(2).score = 90
        hiscore(3).initials = "UNS" '                                              Unseen Machine!
        hiscore(3).score = 80
        hiscore(4).initials = "CLY" '                                              Clippy!
        hiscore(4).score = 70
        hiscore(5).initials = "DWH" '                                              DarthWho!
        hiscore(5).score = 60
        hiscore(6).initials = "CYP" '                                              Cyperium!
        hiscore(6).score = 50
        hiscore(7).initials = "PET" '                                              Pete!
        hiscore(7).score = 40
        hiscore(8).initials = "ZMB" '                                              Zom-B!
        hiscore(8).score = 30
        hiscore(9).initials = "MRW" '                                              MrWhy!
        hiscore(9).score = 20
        hiscore(10).initials = "DAV" '                                             Dave!
        hiscore(10).score = 10
        SaveHiScores '                                                             save the high scores to the high score file
    End If

End Sub

'##################################################################################################################################

Sub UpdateCollisions ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Handles all collisions between objects currently located on screen.                                                            |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared round%(), sround%(), ship%, saucer%, saucerflying%, score&, explode&()
    Shared ssound&, intro%, shipsremaining%, playerdead%, rocksleft%

    Dim count% '                                                                   generic counter
    Dim bcount% '                                                                  generic counter
    Dim hit% '                                                                     contains sprite number of objects that collide

    For count% = 1 To 5 '                                                          cycle through all 5 player bullets
        If SPRITESCORE(round%(count%)) > 0 Then '                                  is this bullet active?
            If SPRITECOLLIDE(round%(count%), ALLSPRITES) Then '                    yes, has the bullet collided with something?
                hit% = SPRITECOLLIDEWITH(round%(count%)) '                         yes, get the sprite that it collided with
                For bcount% = 1 To 5 '                                             cycle through all 5 possible player bullets
                    If hit% = round%(bcount%) Then hit% = 0 '                      if bullet hit bullet then ignore
                    If bcount% < 4 Then '                                          is the bullet counter less than 4?
                        If hit% = sround%(bcount%) Then hit% = 0 '                 yes, if bullet hit saucer bullet then ignore
                    End If
                Next bcount%
                If hit% = ship% Then hit% = 0 '                                    if the bullet hit ship then ignore
                If hit% <> 0 Then '                                                ignore hits with a value of 0
                    If Not intro% Then score& = score& + SPRITESCORE(hit%) '       add the sprite's score to the player's score
                    If Not intro% Then _SndPlay explode&(Int(Rnd(1) * 3) + 1) '    play a random explosion sound
                    Select Case SPRITESCORE(hit%) '                                what was it that the bullet hit?
                        Case 20 '                                                  it was a large rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '     generate two medium size rocks where large rock is
                        Case 50 '                                                  it was a medium sized rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '     generate two small rocks where medium rock is
                        Case 100 '                                                 it was a small rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            rocksleft% = rocksleft% - 1 '                          keep track of how many small rocks left in level
                        Case 200 '                                                 it was a large flying saucer (I want to believe)
                            SPRITEMOTION hit%, DONTMOVE '                          turn automotion off for the saucer
                            saucerflying% = FALSE '                                tell the program a saucer is no longer flying
                            If _SndPlaying(ssound&) Then _SndStop ssound& '        if the saucer sound is playing turn it off
                        Case 1000 '                                                it was a small flying saucer
                            SPRITEMOTION hit%, DONTMOVE '                          turn automotion off for the saucer
                            saucerflying% = FALSE '                                tell the program a saucer is no longer flying
                            If _SndPlaying(ssound&) Then _SndStop ssound& '        if the saucer sound is playing turn it off
                    End Select
                    SPRITEPUT -500, -500, hit% '                                   move the object that was hit off screen
                    MakeSparks SPRITEX(round%(count%)), SPRITEY(round%(count%)) '  make explosion sparks where bullet hit object
                    SPRITESCORESET round%(count%), 1 '                             set to 1 so the next countdown turns bullet off
                End If
            End If
            SPRITESCORESET round%(count%), SPRITESCORE(round%(count%)) - 1 '       decrement the bullet countdown timer
            If SPRITESCORE(round%(count%)) = 0 Then '                              has the bullet traveled its full course?
                SPRITEMOTION round%(count%), DONTMOVE '                            yes, turn automotion off for bullet
                SPRITEPUT -500, -500, round%(count%) '                             move the bullet off screen for later use
            End If
        End If
    Next count%
    For count% = 1 To 3 '                                                          cycle through all 3 saucer bullets
        If SPRITESCORE(sround%(count%)) > 0 Then '                                 is this saucer bullet active?
            If SPRITECOLLIDE(sround%(count%), ALLSPRITES) Then '                   yes, has the saucer bullet collided with something?
                hit% = SPRITECOLLIDEWITH(sround%(count%)) '                        yes, get the sprite that it collided with
                For bcount% = 1 To 5 '                                             cycle through all 5 possible player bullets
                    If hit% = round%(bcount%) Then hit% = 0 '                      if saucer bullet hit bullet then treat as though it hit nothing
                    If bcount% < 4 Then '                                          is the bullet counter less than 4?
                        If hit% = sround%(bcount%) Then hit% = 0 '                 if saucer bullet hit saucer bullet then ignore
                    End If
                Next bcount%
                If hit% = saucer% Then hit% = 0 '                                  ignore saucer bullets hitting self
                If hit% <> 0 Then '                                                did the saucer bullet hit something?
                    If Not intro% Then _SndPlay explode&(Int(Rnd(1) * 3) + 1) '    yes, play a random explosion sound
                    Select Case SPRITESCORE(hit%) '                                what was it that the saucer bullet hit?
                        Case 20 '                                                  it was a large rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '     generate two medium size rocks where large rock is
                        Case 50 '                                                  it was a medium sized rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '     generate two small rocks where medium rock is
                        Case 100 '                                                 it was a small rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            rocksleft% = rocksleft% - 1 '                          keep track of how many small rocks left in level
                        Case 5 '                                                   it hit the player's ship
                            If Not playerdead% Then '                              is the player already dead? (keep from multiple saucer hits)
                                shipsremaining% = shipsremaining% - 1 '            no, decrement the amount of ships player has left
                                playerdead% = TRUE '                               tell the program the player is dead
                            End If
                    End Select
                    If SPRITESCORE(hit%) <> 5 Then SPRITEPUT -500, -500, hit% '    move all hit objects except for player's ship off screen
                    MakeSparks SPRITEX(sround%(count%)), SPRITEY(sround%(count%)) 'make explosion sparks where saucer bullet hit object
                    SPRITESCORESET sround%(count%), 1 '                            set to 1 so the next countdown turns saucer bullet off
                End If
            End If
            SPRITESCORESET sround%(count%), SPRITESCORE(sround%(count%)) - 1 '     decrement the saucer bullet countdown timer
            If SPRITESCORE(sround%(count%)) = 0 Then '                             has the saucer bullet run its course?
                SPRITEMOTION sround%(count%), DONTMOVE '                           yes, turn automotion off for saucer bullet
                SPRITEPUT -500, -500, sround%(count%) '                            move the saucer bullet off screen for later use
            End If
        End If
    Next count%
    If saucerflying% Then '                                                        is a saucer currently on screen?
        If SPRITECOLLIDE(saucer%, ALLSPRITES) Then '                               has the saucer collided with something?
            hit% = SPRITECOLLIDEWITH(saucer%) '                                    yes, get the sprite that the saucer collided with
            For count% = 1 To 3 '                                                  cycle through all three saucer bullets
                If SPRITESCORE(sround%(count%)) > 0 Then '                         is this saucer bullet on screen?
                    If hit% = sround%(count%) Then hit% = 0 '                      yes, ignore saucer bullet hits with saucer
                End If
            Next count%
            If hit% <> 0 Then '                                                    did the saucer collide with something?
                If Not intro% Then score& = score& + SPRITESCORE(saucer%) '        yes, add the saucer's score to the player's score
                If Not intro% Then _SndPlay explode&(Int(Rnd(1) * 3) + 1) '        play a random explosion sound
                Select Case SPRITESCORE(hit%) '                                    what did the saucer hit?
                    Case 20 '                                                      it was a large rock
                        SPRITEMOTION hit%, DONTMOVE '                              turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                                   set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '         generate two medium size rocks where large rock is
                    Case 50 '                                                      it was a medium sized rock
                        SPRITEMOTION hit%, DONTMOVE '                              turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                                   set the rock's score value to 0
                        GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '         generate two small rocks where medium rock is
                    Case 100 '                                                     it was a small rock
                        SPRITEMOTION hit%, DONTMOVE '                              turn the rock's automotion off
                        SPRITESCORESET hit%, 0 '                                   set the rock's score value to 0
                        rocksleft% = rocksleft% - 1 '                              keep track of how many small rocks left in level
                    Case 5 '                                                       it was the player's ship
                        If Not playerdead% Then '                                  is the player already dead? (keep saucer from hitting player explosion sequence)
                            shipsremaining% = shipsremaining% - 1 '                no, decrement the amount of ships player has left
                            playerdead% = TRUE '                                   tell the program the player is dead
                        End If
                End Select
                If SPRITESCORE(hit%) <> 5 Then SPRITEPUT -500, -500, hit% '        move all hit objects except for player's ship off screen
                SPRITEMOTION saucer%, DONTMOVE '                                   turn the saucer's automotion off
                saucerflying% = FALSE '                                            tell the program a saucer in no longer on screen
                If _SndPlaying(ssound&) Then _SndStop ssound& '                    turn off the saucer sound
                MakeSparks SPRITEX(saucer%), SPRITEY(saucer%) '                    make explosion sparks where saucer hit object
                SPRITEPUT -500, -500, saucer% '                                    move the saucer off screen for later use
            End If
        End If
    End If
    If Not intro% Then
        If Not playerdead% Then '                                                  is the player still alive and kicking?
            If SPRITECOLLIDE(ship%, ALLSPRITES) Then '                             yes, has the ship collided with anything?
                hit% = SPRITECOLLIDEWITH(ship%) '                                  yes, get the sprite that the ship collided with
                For bcount% = 1 To 5 '                                             cycle through all 5 possible player bullets
                    If hit% = round%(bcount%) Then hit% = 0 '                      ignore collisions between player bullet and ship
                Next bcount%
                If hit% <> 0 Then '                                                did the ship collide with something?
                    score& = score& + SPRITESCORE(hit%) '                          yes, add the object's score to the player's score
                    If Not intro% Then _SndPlay explode&(Int(Rnd(1) * 3) + 1) '    play a random explosion sound
                    Select Case SPRITESCORE(hit%) '                                what did the ship hit?
                        Case 20 '                                                  it was a large rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 2 '     generate two medium size rocks where large rock is
                        Case 50 '                                                  it was a medium sized rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            GenerateRocks SPRITEX(hit%), SPRITEY(hit%), 2, 3 '     generate two small rocks where medium rock is
                        Case 100 '                                                 it was a small rock
                            SPRITEMOTION hit%, DONTMOVE '                          turn the rock's automotion off
                            SPRITESCORESET hit%, 0 '                               set the rock's score value to 0
                            rocksleft% = rocksleft% - 1 '                          keep track of how many small rocks left in level
                    End Select
                    SPRITEPUT -500, -500, hit% '                                   move object that was hit off screen
                    MakeSparks SPRITEX(ship%), SPRITEY(ship%) '                    make explosion sparks where ship hit object
                    playerdead% = TRUE '                                           tell the program the player is dead
                    shipsremaining% = shipsremaining% - 1 '                        decrement the amount of ships player has left
                End If
            End If
        End If
    End If

End Sub

'##################################################################################################################################

Sub UpdatePlayerDeath ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| handles the intermediate time between a player death and respawn.                                                              |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared shipsremaining%, rocks%(), playerdead%, ship%, ssound&, deathfinished%

    Static deathcount% '                                                           countdown timer used to control when player can respawn
    Static setcount% '                                                             counter used to control when to tighten spawn box
    Static distance% '                                                             the minimum distance a rock must be from spawn box
    Static animcount% '                                                            animation counter used to control ship explosion animation

    Dim count% '                                                                   generic counter
    Dim setplayer% '                                                               true when it's ok to respawn player

    If distance% = 0 Then distance% = 150 '                                        set minimum distance from rocks to respawn
    If deathcount% = 0 Then deathcount% = 64 '                                     wait at least 2 seconds to respawn
    animcount% = animcount% + 1 '                                                  exploding ship animation counter
    If (animcount% \ 5 = animcount% / 5) And (animcount% < 30) Then '              have 5 framses passed?
        SPRITESET ship%, (animcount% \ 5) * 2 + 1 '                                yes, set the next explosion animation cell
    End If
    If animcount% < 30 Then '                                                      still within explosion animation frames?
        SPRITEPUT SPRITEX(ship%), SPRITEY(ship%), ship% '                          yes, show the next animation cell
    Else
        SPRITESET ship%, 1 '                                                       no, set ship back to normal sprite
        SPRITEPUT -500, -500, ship% '                                              put it off screen until later
        deathfinished% = TRUE
    End If
    If _SndPlaying(ssound&) Then Exit Sub '                                        wait until the saucer has left the screen
    deathcount% = deathcount% - 1 '                                                decrement the 2 second wait counter
    If deathcount% = 0 Then '                                                      have 2 seconds elapsed?
        deathcount% = 1 '                                                          yes, set to 1 in case we need to come back here
        setplayer% = TRUE '                                                        assume player's ship will be set this time around
        For count% = 1 To UBound(rocks%) '                                         cycle through all the rocks
            If SPRITESCORE(rocks%(count%)) > 0 Then '                              is this rock on screen and far enough away?
                If (Abs(SPRITEX(rocks%(count%)) - 512) < distance%) And (Abs(SPRITEY(rocks%(count%)) - 384) < distance%) Then setplayer% = FALSE
            End If
        Next count%
        If setplayer% = TRUE Then '                                                are all rocks far enough away?
            playerdead% = FALSE '                                                  yes, the player is alive again
            SPRITEPUT 512, 384, ship% '                                            respawn ship
            deathcount% = 0 '                                                      reset the spawn delay timer
            distance% = 0 '                                                        reset the distance to 0 so it's set at max again
            animcount% = 0 '                                                       reset the explosion animation counter
        Else
            setcount% = setcount% + 1 '                                            rocks are too close! increment 1/2 second counter
            If setcount% = 16 Then '                                               have we tried at this distance for at least 1/2 sec?
                distance% = distance% - 1 '                                        yes, tighten the minimum distance required
                If distance% < 70 Then distance% = 70 '                            but not too close
                setcount% = 0 '                                                    reset the 1/2 second counter
            End If
        End If
    End If

End Sub

'##################################################################################################################################

Sub UpdateUfo ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Updates the position of any flying saucer that is currently on screen.                                                         |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared lsaucer%, bsaucer%, level%, bigsaucer&, littlesaucer&, intro%
    Shared saucerflying%, sround%(), ship%, saucer%, ssound&, pfire&, playerdead%
    Shared score&, explode&(), rocksleft%, shipsremaining%

    Static saucerwait% '                                                           the amount of time to wait between saucer encounters
    Static nextshot% '                                                             the amount of time to wait between saucer shots
    Static changedir% '                                                            countdown timer used to control when saucer can change direction

    Dim side% '                                                                    the side of the screen the saucer will appear at
    Dim height% '                                                                  how high on the screen the saucer will appear
    Dim angle! '                                                                   the angle at which the bullet will leave the saucer
    Dim sdirection% '                                                              the saucer's current direction

    If shipsremaining% = 0 Then '                                                  does the player have any ships left?
        If _SndPlaying(ssound&) Then _SndStop ssound& '                            no, if a saucer is flying stop its flying sound
    End If
    If (saucerwait% = 0) And (Not saucerflying%) Then '                            has enough time elapsed and no saucer currently onscreen?
        If (Int(Rnd(1) * 250) = 125) And (Not playerdead%) Then '                  yes, should a saucer appear if the player isn't dead?
            saucerflying% = TRUE '                                                 yes, let the program know a saucer is flying
            saucerwait% = 320 '                                                    time to wait after this saucer done (320 = 10 secs)
            saucer% = Int(Rnd(1) * level%) '                                       calculate how often each type of saucer should appear
            If saucer% <= level% \ 3 Then '                                        should a large saucer be produced?
                saucer% = bsaucer% '                                               yes, set to equal a big saucer
                ssound& = bigsaucer& '                                             set the sound to big saucer sound
                nextshot% = 32 '                                                   set time between shots to 1 sec (32fps)
                changedir% = 120 '                                                 amount of frames to travel before changing direction again
                SPRITESPEEDSET saucer%, 3 '                                        set the speed of the large saucer
            Else '                                                                 no, a small saucer should be produced
                saucer% = lsaucer% '                                               set to equal a small saucer
                ssound& = littlesaucer& '                                          set the sound to small saucer sound
                nextshot% = 24 '                                                   set time between shots to 3/4 sec (24fps)
                changedir% = 90 '                                                  amount of frames to travel before changing direction again
                SPRITESPEEDSET saucer%, 4 '                                        set the speed of the small saucer
            End If
            side% = Int(Rnd(1) * 2) '                                              calculate a random side to appear from
            height% = Int(Rnd(1) * 6) '                                            calculate a random height to appear at
            Select Case side% '                                                    which side should saucer appear from?
                Case 0 '                                                           the left side
                    SPRITEPUT -32, (height% * 128) + 26, saucer% '                 place saucer just off left of screen
                    SPRITEDIRECTIONSET saucer%, 90 '                               set the saucer to travel at 90 degrees (right)
                Case 1 '                                                           the right side
                    SPRITEPUT 1056, (height% * 128) + 26, saucer% '                place saucer just off right of screen
                    SPRITEDIRECTIONSET saucer%, 270 '                              set the saucer to travel at 270 degrees (left)
            End Select
            SPRITEMOTION saucer%, MOVE '                                           turn automotion on for the saucer
            If Not intro% Then _SndLoop ssound& '                                  play the saucer sound if not in intro mode
        End If
    End If
    If saucerflying% Then '                                                        is the saucer currently flying?
        SPRITEPUT MOVE, MOVE, saucer% '                                            yes, automove the saucer
        changedir% = changedir% - 1 '                                              decrement the direction change counter
        If changedir% = 0 Then '                                                   is it time to see if a direction change is coming?
            If saucer% = bsaucer% Then '                                           yes, is this a big saucer?
                changedir% = 120 '                                                 yes, reset the direction change counter
            Else '                                                                 no, this is a little saucer
                changedir% = 90 '                                                  reset the direction change counter
            End If
            If Int(Rnd(1) * 2) = 1 Then '                                          will the saucer randomly change direction now?
                sdirection% = SPRITEDIRECTION(saucer%) '                           yes, get the saucer's direction
                If sdirection% = 270 Then '                                        is the saucer heading left?
                    If Int(Rnd(1) * 2) = 0 Then '                                  yes, should it randomly be changed by 45 degrees?
                        SPRITEDIRECTIONSET saucer%, 315 '                          yes, add 45 degrees to the saucer direction
                    Else
                        SPRITEDIRECTIONSET saucer%, 225 '                          yes, subtract 45 degrees from the saucer direction
                    End If
                ElseIf (sdirection% = 315) Or (sdirection% = 225) Then '           is the saucer already heading left at a +/- 45 degrees?
                    SPRITEDIRECTIONSET saucer%, 270 '                              yes, set the suacer direction back to 270
                ElseIf sdirection% = 90 Then '                                     is the saucer heading right?
                    If Int(Rnd(1) * 2) = 0 Then '                                  yes, should it randmoly be changed by 45 degrees?
                        SPRITEDIRECTIONSET saucer%, 45 '                           yes, subtract 45 degrees from the saucer direction
                    Else
                        SPRITEDIRECTIONSET saucer%, 135 '                          yes, add 45 degrees to the saucer direction
                    End If
                ElseIf (sdirection% = 45) Or (sdirection% = 135) Then '            is the saucer already heading right at a +/- 45 degrees?
                    SPRITEDIRECTIONSET saucer%, 90 '                               yes, set the saucer direction back to 90 degrees
                End If
            End If
        End If
        If SPRITEY(saucer%) < 0 Then '                                             has the saucer left the top of the screen?
            SPRITEMOTION saucer%, DONTMOVE '                                       yes, stop the saucer's automotion
            SPRITEPUT SPRITEX(saucer%), 767, saucer% '                             place the saucer at the bottom of screen
            SPRITEMOTION saucer%, MOVE '                                           turn the saucer's automotion back on
        End If
        If SPRITEY(saucer%) > 767 Then '                                           has the saucer left the bottom of the screen?
            SPRITEMOTION saucer%, DONTMOVE '                                       yes, turn the saucer's automotion off
            SPRITEPUT SPRITEX(saucer%), 0, saucer% '                               place the saucer at the top of the screen
            SPRITEMOTION saucer%, MOVE '                                           turn the saucer's automotion back on
        End If
        If SPRITEX(saucer%) <= -32 Or SPRITEX(saucer%) >= 1056 Then '              has the saucer left the right or left side of screen?
            saucerflying% = FALSE '                                                yes, tell the program that a saucer is no longer flying
            SPRITEMOTION saucer%, DONTMOVE '                                       turn automotion off for saucer
            SPRITEPUT -300, -300, saucer% '                                        place the saucer off screen for later use
            If _SndPlaying(ssound&) Then _SndStop ssound& '                        if the saucer sound is playing stop it
        End If
        If Not playerdead% Then '                                                  is the player still alive?
            If nextshot% = 0 Then '                                                yes, is it time to shoot another bullet yet?
                For count% = 1 To 3 '                                              yes, cycle through all 3 possible bullets
                    If SPRITESCORE(sround%(count%)) = 0 Then '                     is  this bullet available for use?
                        If Not intro% Then _SndPlay pfire& '                       yes, play the ship firing bullet sound if not in intro mode
                        SPRITESCORESET sround%(count%), 64 '                       set the countdown timer of the bullet to 2 seconds (64 frames)
                        SPRITEPUT SPRITEX(saucer%), SPRITEY(saucer%), sround%(count%) 'put the bullet onto the screen
                        SPRITESPEEDSET sround%(count%), 10 '                       set the speed of the bullet

                        If Not intro% Then
                            If saucer% = bsaucer% Then '                           is the saucer flying a big saucer?
                                If Int(Rnd(1) * (27 \ level%)) = 1 Then '          yes, how accurate will the big saucer be on this shot?
                                    angle! = SPRITEANGLE(saucer%, ship%) '         very accurate, aim right for player ship
                                Else '                                             not accurate at all
                                    angle! = Int(Rnd(1) * 360) '                   fire bullet in a random direction
                                End If
                                nextshot% = 32 '                                   wait 32 frames until next bullet
                            Else '                                                 no, this is a small saucer flying
                                angle! = SPRITEANGLE(saucer%, ship%) '             assume that the small saucer will be dead on accurate
                                If Int(Rnd(1) * level% * 3) = 1 Then '             should a little error be introduced in the shot?
                                    angle! = angle! + Rnd(1) * 10 - Rnd(1) * 10 '  yes, introduce a +/- 10 degree error
                                    If angle! < 0 Then angle! = angle! + 360 '     make sure angle stays in between 0 and 359.99.. degrees
                                    If angle! >= 360 Then angle! = angle! - 360 '  make sure angle stays in between 0 and 359.99.. degrees
                                End If
                                nextshot% = 24 '                                   wait 24 frames until next bullet
                            End If
                        Else
                            angle! = Int(Rnd(1) * 360) '                           in intro mode just make shots have random angles
                            nextshot% = 32 '                                       both saucers will wait 32 frames before next bullet
                        End If

                        SPRITEDIRECTIONSET sround%(count%), angle! '               set the angle of the bullet
                        SPRITEMOTION sround%(count%), MOVE '                       turn on automotion for the bullet
                        Exit For '                                                 no need to cycle through the rest of the bullets
                    End If
                Next count%
            End If
        End If
        If nextshot% > 0 Then nextshot% = nextshot% - 1 '                          decrement the shot timer
    End If
    If (saucerwait% > 0) And (Not saucerflying%) Then saucerwait% = saucerwait% - 1 'decrement the saucer wait timer

End Sub

'##################################################################################################################################

Sub IntroScreen ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Displays the intro screen goodies while waiting for the player to enter a coin and start game.                                 |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared intro%, shipsremaining%, level%, score&, beattimer!, playerdead%
    Shared rocksleft%, enter%, coin%, saucerflying%, saucer%, sround%()

    Static firsttime% '                                                            keeps track of first time this sub is called

    Dim count% '                                                                   generic counter

    intro% = TRUE '                                                                let the program know its in intro mode
    Do: Loop Until InKey$ = "" '                                                   clear the keyboard buffer
    playerdead% = FALSE '                                                          make the player alive to allow ufos to shoot
    If Not firsttime% Then '                                                       is this the first time this sub called?
        firsttime% = TRUE '                                                        yes, set flag so this part of code not entered again
        level% = 1 '                                                               set the game level to 1
        score& = 0 '                                                               set the player score to 0
        shipsremaining% = 3 '                                                      set the remaining ships to 3
        NewLevel '                                                                 set up a new asteroid field
    End If
    Do '                                                                           start the intro loop here
        _Limit 32 '                                                                limit the intro to 32fps
        Cls '                                                                      clear the screen
        If rocksleft% = 0 Then NewLevel '                                          if ufos clear asteroids set up new asteroid field
        UpdateSparks '                                                             update any explosions currently on screen
        UpdateUfo '                                                                update the position of ufos
        UpdateRocks '                                                              update the positions of asteroids
        UpdateBullets '                                                            update any ufo bullets that are on screen
        UpdateCollisions '                                                         update any collisions that are happening
        UpdateScore '                                                              show the high score
        UpdateText '                                                               update the info text on screen
        _Display '                                                                 display the results of previous subs on screen
    Loop Until enter% '                                                            keep looping until the player presses ENTER
    If saucerflying% Then '                                                        is there a ufo currently on screen?
        SPRITEMOTION saucer%, DONTMOVE '                                           yes, stop it from moving
        SPRITEPUT -500, -500, saucer% '                                            put it off screen for later use
        saucerflying% = FALSE '                                                    tell the program no more ufos are on screen
    End If
    For count% = 1 To 3 '                                                          cycle through all 3 possible ufo bullets
        If SPRITESCORE(sround%(count%)) > 0 Then '                                 is this bullet on screen?
            SPRITEMOTION sround%(count%), DONTMOVE '                               yes, stop it from moving
            SPRITESCORESET sround%(count%), 0 '                                    set its value to 0 signifying it's dead
            SPRITEPUT -500, -500, sround%(count%) '                                put it off screen for later use
        End If
    Next count%
    intro% = FALSE '                                                               let the program know its no longer in intro mode
    enter% = FALSE '                                                               reset the enter key flag for next time
    coin% = FALSE '                                                                reset the coin indicator for next time
    Cls '                                                                          clear the screen
    UpdateScore '                                                                  show the score and player ships
    DrawText 367, 100, "PLAYER ONE" '                                              let player one know it's time
    _Display '                                                                     display the results on screen of previous commands
    _Delay 2 '                                                                     pause for 2 seconds

End Sub

'##################################################################################################################################

Sub UpdateText ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Displays any relevant text on the screen while in intro mode.                                                                  |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared enter%, coin%, hiscore() As TOPTEN, gameover%, score&, explode&()

    Static flip% '                                                                 counter used to turn high scores on and off
    Static flash% '                                                                used to flash "press enter"
    Static overcount% '                                                            counter used to show "game over" for 3 seconds
    Static esc% '                                                                  player escape key timer

    Dim keypress$ '                                                                holds any key value the player may press
    Dim count% '                                                                   generic counter

    keypress$ = InKey$ '                                                           get any key that the player may press
    If keypress$ = "1" Then coin% = TRUE '                                         if the player pressed 1 then signify a coin drop
    If keypress$ = Chr$(13) And coin% Then '                                       did the player press ENTER after a coin dropped?
        enter% = TRUE '                                                            yes, let the program know the player pressed ENTER
        flip% = 0 '                                                                reset the high score flip counter
        flash% = 0 '                                                               reset the "press enter" flash counter
        Exit Sub '                                                                 exit the subroutine to play the game
    End If
    If keypress$ = Chr$(27) Then '                                                 did the player press the escape key?
        esc% = 1 '                                                                 yes, increment the escape counter
        flip% = 0 '                                                                reset high score flip
        coin% = FALSE '                                                            take the coin back
    End If
    If esc% > 0 And esc% < 160 Then '                                              has the escape counter been activated?
        esc% = esc% + 1 '                                                          yes, increment the escape counter
        _SndPlay explode&(Int(Rnd(1) * 3) + 1) '                                   play a random explosion sound for each frame
        MakeSparks Int(Rnd(1) * 1024), Int(Rnd(1) * 768) '                         make sparks at a random spot on screen
        DrawText 260, 350, "PROGRAMMED IN QB64" '                                  display credits for 5 seconds
        DrawText 260, 400, " BY TERRY RITCHIE" '                                   ""
        DrawText 260, 450, "   WWW QB64 NET" '                                     ""
        PSet (455, 465), _RGB(192, 192, 192) '                                     put the first dot in www.qb64.net
        PSet (595, 465), _RGB(192, 192, 192) '                                     put the second dot in www.qb64.net
    End If
    If esc% > 159 Then '                                                           have 5 seconds gone by?
        esc% = esc% + 1 '                                                          yes, increment escape counter
        If esc% = 224 Then System '                                                exit the game after 7 seconds
    End If
    If gameover% Then '                                                            is the previous game over?
        DrawText 381, 400, "GAME OVER" '                                           yes, print "game over" on screen
        overcount% = overcount% + 1 '                                              increment the game over counter
        If overcount% = 96 Then '                                                  have 96 frames elapsed? (3 seconds)
            overcount% = 0 '                                                       yes, reset the counter for next game
            gameover% = FALSE '                                                    reset the game over flag for next game
            If score& > hiscore(10).score Then UpdateHiScores '                    player has achieved a high score, get info
        End If
    End If
    DrawText 325, 680, "1 COIN 1 PLAY" '                                           print instructions on the screen
    DrawText 72, 740, "1 TO INSERT COIN OR ESC TO QUIT" '                          print more instructions on screen
    If flip% < 320 Or coin% Then '                                                 should screen show no high scores or coin information?
        If coin% Then '                                                            yes, has a coin been dropped?
            DrawText 25, 250, "RIGHT AND LEFT ARROW KEYS TO TURN" '                yes, print game play instructions on screen
            DrawText 25, 300, "  UP ARROW KEY TO THRUST FORWARD" '                 ""
            DrawText 25, 350, "DOWN ARROW KEY TO ENTER HYPERSPACE" '               ""
            DrawText 25, 400, "     SPACEBAR TO FIRE BULLETS" '                    ""
            DrawText 25, 500, "   ALT ENTER TO GO FULL SCREEN" '                   ""
            If flash% < 32 Then '                                                  is it time to show "press enter"? (every other second)
                DrawText 367, 100, "PUSH ENTER" '                                  yes, print the message on screen
            End If
            flash% = flash% + 1 '                                                  increment the "press enter" flash counter
            If flash% = 64 Then flash% = 0 '                                       if 64 frames have elapsed reset flash counter (2 seconds)
        End If
    Else '                                                                         the screen should show high scores now
        DrawText 367, 100, "HIGH SCORES" '                                         print the message to the screen
        For count% = 1 To 10 '                                                     cycle through all high scores and print them to screen
            DrawText 325, 100 + (count% * 50), Right$(" " + LTrim$(Str$(count%)), 2) + "  " + Right$("    " + LTrim$(Str$(hiscore(count%).score)), 5) + " " + hiscore(count%).initials
            PSet (404, 113 + count% * 50), _RGB(128, 128, 128) '                   put the periods after the line numbers
        Next count%
    End If
    flip% = flip% + 1 '                                                            increment the high score screen flip counter
    If flip% = 640 Then flip% = 0 '                                                if 640 frames have passed reset counter (20 seconds)

End Sub

'##################################################################################################################################

Sub DrawText (x%, y%, text$)

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Draws the asteroids font text on the screen at the given location.                                                             |
    '| x%, y% = the position on screen to draw the text.                                                                              |
    '| text$  = the text message to display on the screen                                                                             |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared lfont%()

    Dim count% '                                                                   generic counter
    Dim nextx% '                                                                   the next text character location
    Dim subtract% '                                                                calculate where on the sprite sheet to get character

    nextx% = x% '                                                                  set variable to starting x location of text
    For count% = 1 To Len(text$) '                                                 cycle through the text one character at a time
        If Mid$(text$, count%, 1) = " " Then '                                     is this character a space?
            nextx% = nextx% + 28 '                                                 yes, move the x position to the right
        Else '                                                                     this character is not a space
            nextx% = nextx% + 28 '                                                 move to the next character position
            If Asc(Mid$(text$, count%, 1)) < 65 Then subtract% = 48 Else subtract% = 55 'calculate where on sprite sheet character resides
            SPRITESTAMP nextx%, y%, lfont%(Asc(Mid$(text$, count%, 1)) - subtract%) 'stamp the character onto the screen
        End If
    Next count%

End Sub

'##################################################################################################################################

Sub UpdateBullets ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Updates the positions of the player's and saucer's bullets on screen                                                           |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared round%(), ship%, score&, explode&(), rocksleft%, sround%(), intro%
    Shared saucer%, saucerflying%, ssound&, playerdead%, shipsremaining%

    Dim count% '                                                                   generic counter
    Dim bcount% '                                                                  generic counter used to detect bullet/bullet collision

    For count% = 1 To 5 '                                                          cycle through all 5 possible bullets on screen
        If SPRITESCORE(round%(count%)) > 0 Then '                                  if the bullet score is greater than 0 it's on screen
            SPRITEPUT MOVE, MOVE, round%(count%) '                                 automove the bullet to its next position
            If SPRITEX(round%(count%)) < 0 Then '                                  has the bullet left the left side of the screen?
                SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
                SPRITEPUT 1023, SPRITEY(round%(count%)), round%(count%) '          move bullet to right side of screen
                SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
            End If
            If SPRITEX(round%(count%)) > 1023 Then '                               has the bullet left the right side of the screen?
                SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
                SPRITEPUT 0, SPRITEY(round%(count%)), round%(count%) '             move bullet to left side of screen
                SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
            End If
            If SPRITEY(round%(count%)) > 767 Then '                                has the bullet left the bottom of the screen?
                SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
                SPRITEPUT SPRITEX(round%(count%)), 0, round%(count%) '             move bullet to top of screen
                SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
            End If
            If SPRITEY(round%(count%)) < 0 Then '                                  has the bullet left the top of the screen?
                SPRITEMOTION round%(count%), DONTMOVE '                            yes, stop automotion
                SPRITEPUT SPRITEX(round%(count%)), 767, round%(count%) '           move bullet to bottom of screen
                SPRITEMOTION round%(count%), MOVE '                                turn bullet automotion back on
            End If
        End If
        If count% < 4 Then '                                                       is count less than 4
            If SPRITESCORE(sround%(count%)) > 0 Then '                             yes, if the saucer bullet on screen?
                SPRITEPUT MOVE, MOVE, sround%(count%) '                            yes, automove the saucer bullet to its next position
                If SPRITEX(sround%(count%)) < 0 Then '                             has the saucer bullet left the left side of the screen?
                    SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                    SPRITEPUT 1023, SPRITEY(sround%(count%)), sround%(count%) '    move saucer bullet to right side of screen
                    SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
                End If
                If SPRITEX(sround%(count%)) > 1023 Then '                          has the saucer bullet left the right side of the screen?
                    SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                    SPRITEPUT 0, SPRITEY(sround%(count%)), sround%(count%) '       move saucer bullet to left side of screen
                    SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
                End If
                If SPRITEY(sround%(count%)) > 767 Then '                           has the saucer bullet left the bottom of the screen?
                    SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                    SPRITEPUT SPRITEX(sround%(count%)), 0, sround%(count%) '       move saucer bullet to the top of screen
                    SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
                End If
                If SPRITEY(sround%(count%)) < 0 Then '                             has the saucer bullet left the top of the screen?
                    SPRITEMOTION sround%(count%), DONTMOVE '                       yes, stop automotion
                    SPRITEPUT SPRITEX(sround%(count%)), 767, sround%(count%) '     move suacer bullet to the bottom of screen
                    SPRITEMOTION sround%(count%), MOVE '                           turn saucer bullet automotion back on
                End If
            End If
        End If
    Next count%

End Sub

'##################################################################################################################################

Sub UpdateScore ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Displays player's score, the high score and remaining ships on screen.                                                         |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared score&, hiscore&, lfont%(), sfont%(), shipsremaining%, intro%
    Shared extraship%, extralife&

    Dim s$ '                                                                       the player's score in string format
    Dim hs$ '                                                                      the high score in string format
    Dim count% '                                                                   generic counter
    Dim padding$ '                                                                 the type of padding needed before score and hiscore

    Static shipawarded% '                                                          true when a player has been awarded ship
    Static nextship& '                                                             score value to award next extra ship

    If nextship& = 0 Then nextship& = 10000 '                                      set extra life value for first time
    If score& > hiscore& Then hiscore& = score& '                                  if the score is greater than high score set high score
    If score& = 0 Then padding$ = "   0" Else padding$ = "    " '                  original game shows two zeros if no high score file
    s$ = Right$(padding$ + LTrim$(Str$(score&)), 5) '                              format the score string padding it with spaces
    If hiscore& = 0 Then padding$ = "   0" Else padding$ = "    " '                original game shows to zeros if no high score file
    hs$ = Right$(padding$ + LTrim$(Str$(hiscore&)), 5) '                           format the high score string padding it with spaces
    For count% = 1 To 5 '                                                          cycle through all 5 digits of score and high score
        If Mid$(s$, count%, 1) <> Chr$(32) Then '                                  is this place in score string a space?
            SPRITESTAMP 25 + count% * 25, 25, lfont%(Asc(Mid$(s$, count%, 1)) - 48) 'no, stamp an image of the number onto the screen
        End If
        If Mid$(hs$, count%, 1) <> Chr$(32) Then '                                 is this place in high score string a space?
            SPRITESTAMP 471 + count% * 11, 15, sfont%(Asc(Mid$(hs$, count%, 1)) - 48) 'no, stamp an image of the number onto the screen
        End If
    Next count%
    If score& >= nextship& Then '                                                  has the score for an extra ship been achieved?
        _SndPlay extralife& '                                                      yes, play the extra life sound
        shipsremaining% = shipsremaining% + 1 '                                    add a ship tot he player's remaining ships
        nextship& = nextship& + 10000 '                                            set the next extra ship value
    End If
    If Not intro% Then '                                                           is game in intro mode?
        For count% = 1 To shipsremaining% '                                        no, cycle through the number of remaining player ships
            SPRITESTAMP 30 + count% * 30, 65, extraship% '                         stamp an image of the ship onto the screen
        Next count%
    End If

End Sub

'##################################################################################################################################

Sub UpdateSparks ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Moves the individual explosion sparks that are currently on screen.                                                            |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sparks() As SPARK

    Dim count% '                                                                   generic counter
    Dim fade1% '                                                                   fade level of vertical and horizontal from center
    Dim fade2% '                                                                   fade level of 45 degree from center

    For count% = 1 To UBound(sparks) '                                                                                      cycle through the entire array
        If sparks(count%).count > 0 Then '                                                                                  is the countdown timer still active?
            fade1% = sparks(count%).fade / 2 '                                                                              yes, compute first fade level
            fade2% = sparks(count%).fade / 4 '                                                                              compute second fade level
            PSet (sparks(count%).x, sparks(count%).y), _RGB(sparks(count%).fade, sparks(count%).fade, sparks(count%).fade) 'set center pixel with full intensity
            PSet (sparks(count%).x + 1, sparks(count%).y), _RGB(fade1%, fade1%, fade1%) '                                   set right horizontal pixel 1/2 intensity
            PSet (sparks(count%).x - 1, sparks(count%).y), _RGB(fade1%, fade1%, fade1%) '                                   set left horizontal pixel 1/2 intensity
            PSet (sparks(count%).x, sparks(count%).y + 1), _RGB(fade1%, fade1%, fade1%) '                                   set lower vertical pixel 1/2 intensity
            PSet (sparks(count%).x, sparks(count%).y - 1), _RGB(fade1%, fade1%, fade1%) '                                   set upper vertical pixel 1/2 intensity
            PSet (sparks(count%).x + 1, sparks(count%).y + 1), _RGB(fade2%, fade2%, fade2%) '                               set lower right pixel 1/4 intensity
            PSet (sparks(count%).x - 1, sparks(count%).y - 1), _RGB(fade2%, fade2%, fade2%) '                               set upper left pixel 1/4 intensity
            PSet (sparks(count%).x - 1, sparks(count%).y + 1), _RGB(fade2%, fade2%, fade2%) '                               set lower left pixel 1/4 intensity
            PSet (sparks(count%).x + 1, sparks(count%).y - 1), _RGB(fade2%, fade2%, fade2%) '                               set upper right pixel 1/4 intensity
            sparks(count%).fade = sparks(count%).fade - 8 '                                                                 decrease intensity amount
            sparks(count%).x = sparks(count%).x + sparks(count%).xdir * sparks(count%).speed '                              compute new x location based on direction and speed
            sparks(count%).y = sparks(count%).y + sparks(count%).ydir * sparks(count%).speed '                              compute new y location based on direction and speed
            sparks(count%).speed = sparks(count%).speed / 1.1 '                                                             derease the speed of the spark
            sparks(count%).count = sparks(count%).count - 1 '                                                               decrement the countdown timer
        End If
    Next count%

End Sub

'##################################################################################################################################

Sub MakeSparks (x%, y%)

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Creates the explosion sparks when objects collide with one another in game.                                                    |
    '| x%, y% = the location to originate the sparks from.                                                                            |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sparks() As SPARK

    Dim cleanup% '                                                                 if true then array is redimmed to 0
    Dim count% '                                                                   generic counter
    Dim topspark% '                                                                the upper boundary of the spark array

    cleanup% = TRUE '                                                              assume redimming of the array will occur
    For count% = 1 To UBound(sparks) '                                             cycle through the contents of the entire array
        If sparks(count%).count <> 0 Then '                                        is the countdown timer for this spark at 0?
            cleanup% = FALSE '                                                     no, redimming of the array will not occur
            Exit For '                                                             no reason to check the rest of the array
        End If
    Next count%
    If cleanup% Then ReDim sparks(0) As SPARK '                                    if cleanup is still true then redim the array
    topspark% = UBound(sparks) '                                                   get the upper boundary of the array
    ReDim _Preserve sparks(topspark% + 11) As SPARK '                              add 10 more spark elements to the array
    For count% = 1 To 10 '                                                         cycle through 10 new spark elements
        sparks(topspark% + count%).count = 32 '                                    set the countdown timer to equal 1 second (32fps)
        sparks(topspark% + count%).x = x% '                                        set the start x point for the spark
        sparks(topspark% + count%).y = y% '                                        set the start y point for the spark
        sparks(topspark% + count%).fade = 255 '                                    set the initial intensity of the spark
        sparks(topspark% + count%).speed = Int(Rnd(1) * 6) + 6 '                   give the spark a random speed to travel at
        sparks(topspark% + count%).xdir = Rnd(1) - Rnd(1) '                        give the spark a random x vector to travel at
        sparks(topspark% + count%).ydir = Rnd(1) - Rnd(1) '                        give the spark a random y vector to travel at
    Next count%

End Sub

'##################################################################################################################################

Sub UpdatePlayer

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Updates the player's ship position on screen.                                                                                  |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared ship%, thrust&, round%(), pfire&, playerdead%

    Shared sprite() As SPRITE '                                                    allows the sprite library to be accesses directly

    Static vx! '                                                                   x vector velocity of player ship
    Static vy! '                                                                   y vector velocity of player ship
    Static pulse% '                                                                controls the pulse rate of ship's rocket engine
    Static nextshot% '                                                             controls the rate of fire
    Static hyperwait% '                                                            control how often a player can hyperspace

    Dim newrotation! '                                                             the new rotational heading ship will be heading in
    Dim acceleration! '                                                            the acceleration rate of ship
    Dim ax! '                                                                      current x acceleration velocity to add to ship
    Dim ay! '                                                                      current y acceleration velocity to add to ship
    Dim speed!

    If playerdead% Then '                                                          is the player dead?
        vx! = 0 '                                                                  yes, set horizontal velocity to 0
        vy! = 0 '                                                                  set vertical velocity to 0
        If _SndPlaying(thrust&) Then _SndStop (thrust&) '                          if the ship thrusting sound is playing turn it off
        Exit Sub '                                                                 player is dead, nothing more to do
    End If
    If _KeyDown(32) Then '                                                         is the player pressing the space bar?
        If nextshot% = 0 Then '                                                    yes, is it time to shoot another bullet yet?
            For count% = 1 To 5 '                                                  yes, cycle through all 5 possible bullets
                If SPRITESCORE(round%(count%)) = 0 Then '                          is this bullet available for use?
                    _SndPlay pfire& '                                              yes, play the ship firing bullet sound
                    SPRITESCORESET round%(count%), 48 '                            set the countdown timer of the bullet to 1.5 seconds (48 frames)
                    SPRITEPUT SPRITEX(ship%), SPRITEY(ship%), round%(count%) '     put the bullet onto the screen
                    SPRITESPEEDSET round%(count%), 10 '                            set the speed of the bullet
                    SPRITEDIRECTIONSET round%(count%), SPRITEROTATION(ship%) '     match the direction of the bullet to the ship's rotation
                    sprite(round%(count%)).xdir = sprite(round%(count%)).xdir + vx! 'had to access the sprite library directly to add the velocity of
                    sprite(round%(count%)).ydir = sprite(round%(count%)).ydir + vy! 'the ship to the velocity of the bullets. need to make commands to handle this.
                    SPRITEMOTION round%(count%), MOVE '                            turn on automotion for the bullet
                    nextshot% = 4 '                                                must wait at least 4 frames before another bullet can be fired
                    Exit For '                                                     no need to cycle through the rest of the bullets
                End If
            Next count%
        End If
    End If
    If nextshot% > 0 Then nextshot% = nextshot% - 1
    If _KeyDown(19712) Then '                                                      is the player pressing the right arrow key?
        newrotation! = SPRITEROTATION(ship%) + 11.25 '                             yes, add clockwise rotation to the ship
        If newrotation! >= 360 Then newrotation! = newrotation! - 360 '            keep rotation angle between 0 and 359.99.. degrees
        SPRITEROTATE ship%, newrotation! '                                         apply new rotational angle to ship
    End If
    If _KeyDown(19200) Then '                                                      is the player pressing the left arrow key?
        newrotation! = SPRITEROTATION(ship%) - 11.25 '                             yes, add counter-clockwise rotation to the ship
        If newrotation! < 0 Then newrotation! = newrotation! + 360 '               keep rotation andgle between 0 and 359.99.. degrees
        SPRITEROTATE ship%, newrotation! '                                         apply new rotational angle to ship
    End If
    If _KeyDown(20480) Then '                                                      is the player pressing the down arrow key?
        If hyperwait% = 0 Then '                                                   yes, has 10 seconds elapsed since the last hyperspace?
            SPRITEPUT Int(Rnd(1) * _Width(_Dest)), Int(Rnd(1) * _Height(_Dest)), ship% 'yes, hyperspace ship to random spot on screen
            vy! = 0 '                                                              set vertical velocity to 0
            vx! = 0 '                                                              set horizontal velocity to 0
            hyperwait% = 320 '                                                     wait 320 frames until the next hyperspace (10 secs)
        End If
    End If
    If hyperwait% > 0 Then hyperwait% = hyperwait% - 1 '                           decrement the hyperspace wait timer
    If _KeyDown(18432) Then ' Up arrow '                                           is the player pressing the up arrow key?
        If Not _SndPlaying(thrust&) Then _SndLoop thrust& '                        play the thruster sound if not already playing
        acceleration! = .2 '                                                       this much acceleration will be applied to ship
        pulse% = pulse% + 1 '                                                      increase the thruster pulse counter
        If pulse% = 2 Then '                                                       does the pulse counter = 2?
            SPRITESET ship%, 2 '                                                   yes, change the sprite to the ship with rocket flame
        ElseIf pulse% = 4 Then '                                                   no, does the pulse counter = 4?
            SPRITESET ship%, 1 '                                                   yes, change the sprite to the ship without flame
            pulse% = 0 '                                                           reset the pulse counter
        End If
    Else
        _SndStop thrust& '                                                         no, the player is not pressing the up arrow key
        acceleration! = 0 '                                                        no acceleration will be added to ship
        SPRITESET ship%, 1 '                                                       set the sprite to the ship without flame
        pulse% = 1 '                                                               set pulse count to 1 so flame shows on key press
    End If
    If acceleration! <> 0 Then '                                                   is ship currently accelerating?
        ax! = acceleration! * Sin(SPRITEROTATION(ship%) * PI / 180) '              yes, compute velocity to add to x vector
        ay! = acceleration! * -Cos(SPRITEROTATION(ship%) * PI / 180) '             compute velocity to add to y vector
        vx! = vx! + ax! '                                                          add x velocity to velocity already present
        vy! = vy! + ay! '                                                          add y velocity to velocity already present
        speed! = Sqr(vx! * vx! + vy! * vy!) '                                      get the current speed of the ship (Yikes! this takes lots of horsepower! is there a better way?)
        If speed! > 10 Then '                                                      has it exceeded the maximum speed allowed?
            vx! = vx! * 10 / speed! '                                              yes, limit the x velocity vector to max speed
            vy! = vy! * 10 / speed! '                                              limit the y velocity vector to max speed
        End If
    Else
        vx! = vx! * .99 '                                                          add a little "space friction"
        vy! = vy! * .99 '                                                          we'll call it dark matter for those saying WTF?
    End If
    SPRITEPUT SPRITEAX(ship%) + vx!, SPRITEAY(ship%) + vy!, ship% '                add velocity to actual x,y for small increments
    If SPRITEX(ship%) < 0 Then '                                                   has ship crossed left boundary?
        SPRITEPUT _Width(_Dest), SPRITEY(ship%), ship% '                           yes, move ship to the right of the screen
    End If
    If SPRITEX(ship%) > _Width(_Dest) Then '                                       has ship crossed right boundary?
        SPRITEPUT 0, SPRITEY(ship%), ship% '                                       yes, move ship to left of screen
    End If
    If SPRITEY(ship%) < 0 Then '                                                   has ship crossed upper boundary?
        SPRITEPUT SPRITEX(ship%), _Height(_Dest), ship% '                          yes, move ship to bottom of screen
    End If
    If SPRITEY(ship%) > _Height(_Dest) Then '                                      has ship crossed lower boundary?
        SPRITEPUT SPRITEX(ship%), 0, ship% '                                       yes, move ship to top of screen
    End If

End Sub

'##################################################################################################################################

Sub NewLevel ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Generates a new game screen based on the current game level.                                                                   |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared level%, ship%, rocksleft%, intro%

    If SPRITEAX(ship%) <= 0 And SPRITEAY(ship%) <= 0 Then '                        is the ship off screen?
        If Not intro% Then '                                                       yes, is game in intro mode?
            SPRITEPUT 512, 384, ship% '                                            no, place ship for first time
        Else '                                                                     yes, game is in intro mode
            SPRITEPUT -300, -300, ship% '                                          hide ship during intro screen
        End If
    End If
    GenerateRocks 0, 0, level% + 3, 1 '                                            generate large rocks at beginning of level
    rocksleft% = (level% + 3) * 4 '                                                total small rocks that will be generated in level

End Sub

'##################################################################################################################################

Sub UpdateRocks ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Updates the position of the asteroids on screen.                                                                               |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared rocks%(), beat&(), beattimer!, intro%

    Static beatcount% '                                                            controls when to play jaws beat sound
    Static beat% '                                                                 controls which jaws beat sound to play

    For rockcount% = 1 To UBound(rocks%) '                                         cycle through all the rocks that have been generated
        If SPRITESCORE(rocks%(rockcount%)) <> 0 Then '                             is this rock active and on screen?
            SPRITEPUT MOVE, MOVE, rocks%(rockcount%) '                             yes, automove the rock to its new location
            If SPRITEX(rocks%(rockcount%)) < 0 Then '                              has rock left the left side of screen?
                SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
                SPRITEPUT 1023, SPRITEY(rocks%(rockcount%)), rocks%(rockcount%) '  move the rock to the right side of screen
                SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
            End If
            If SPRITEX(rocks%(rockcount%)) > 1023 Then '                           has rock left the right side of screen?
                SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
                SPRITEPUT 0, SPRITEY(rocks%(rockcount%)), rocks%(rockcount%) '     move the rock to the left side of screen
                SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
            End If
            If SPRITEY(rocks%(rockcount%)) < 0 Then '                              has the rock left the upper portion of screen?
                SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
                SPRITEPUT SPRITEX(rocks%(rockcount%)), 767, rocks%(rockcount%) '   move the rock to the lower portion of screen
                SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
            End If
            If SPRITEY(rocks%(rockcount%)) > 767 Then '                            has the rock left the lower portion of screen?
                SPRITEMOTION rocks%(rockcount%), DONTMOVE '                        yes, stop automotion
                SPRITEPUT SPRITEX(rocks%(rockcount%)), 0, rocks%(rockcount%) '     move the rock to the upper portion of screen
                SPRITEMOTION rocks%(rockcount%), MOVE '                            turn automotion back on
            End If
        End If
    Next rockcount%
    If Not intro% Then '                                                           is this sub being called by the intro screen?
        If beatcount% = 0 Then '                                                   no, time to change beat sound?
            beatcount% = beattimer! '                                              yes, set beat count to equal beat timer
            beat% = 1 - beat% '                                                    flip/flop the current beat sound
            _SndPlay beat&(beat%) '                                                play the current beat sound
            beattimer! = beattimer! - .2 '                                         decrease the beat timer a little at a time
            If beattimer! < 8 Then beattimer! = 8 '                                never go less than 8 frames per beat
        Else
            beatcount% = beatcount% - 1 '                                          not time yet, decrement beat count
        End If
    End If

End Sub

'##################################################################################################################################

Sub GenerateRocks (x%, y%, rocknum%, size%)

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Generates rocks at a given position on screen with a predetermined size.                                                       |
    '| x%, y%   = the location on screen to generate the new rocks                                                                    |
    '| rocknum% = the number of new rocks to generate                                                                                 |
    '| size%    = the size of the new rocks (1 = 100%, 2 = 50%, 3 = 25%)                                                              |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared rocks%(), rock%(), ship%, level%

    Static nextrock% '                                                             holds the next rock type to be chosen

    Dim rockstart% '                                                               the top of the rock array
    Dim rockcount% '                                                               generic counter
    Dim rockspeed! '                                                               the calculated speed a new rock will travel at

    If (UBound(rocks%) > 0) And (size% = 1) Then '                                 is level 2 or greater starting?
        For rockcount% = UBound(rocks%) To 1 Step -1 '                             yes, cycle through entire rock array
            SPRITEFREE rocks%(rockcount%) '                                        free the sprite from memory
        Next rockcount%
        ReDim rocks%(0) '                                                          clear array for new level
    End If
    rockstart% = UBound(rocks%) '                                                  the last element in the rock array
    ReDim _Preserve rocks%(UBound(rocks%) + rocknum%) '                            add the desired number of new rocks to the array
    For rockcount% = 1 To rocknum% '                                               cycle through all the new rocks that need created
        nextrock% = nextrock% + 1 '                                                cycle through all three available types of rocks
        If nextrock% = 4 Then nextrock% = 1 '                                      rest rock type cycle timer if gone too high
        rocks%(rockstart% + rockcount%) = SPRITECOPY(rock%(size%, nextrock%)) '    copy the chosen rock sprite
        If size% = 1 Then ' random spots on new level '                            are the new rocks being created large?
            Do '                                                                   yes, this is the start of a new level
                x% = Int(Rnd(1) * 824) + 100 '                                     choose a random x location for rock
                y% = Int(Rnd(1) * 568) + 100 '                                     choose a random y location for rock
            Loop Until (Abs(SPRITEX(ship%) - x%) > 200) Or (Abs(SPRITEY(ship%) - y%) > 200) 'make sure it's not too close to ship
        End If
        SPRITEPUT x%, y%, rocks%(rockstart% + rockcount%) '                        place the rock on the screen
        If size% = 1 Then rockspeed! = Rnd(1) * (level% / 3) + 1 '                 calculate the speed of big rocks based on level
        If size% = 2 Then rockspeed! = Rnd(1) * (level% / 2) + 1 '                 calculate the speed of medium rocks based on level
        If size% = 3 Then rockspeed! = Rnd(1) * level% + 1 '                       calculate the speed of small rocks based on level
        SPRITESPEEDSET rocks%(rockstart% + rockcount%), rockspeed! '               set the speed of the rock
        SPRITEDIRECTIONSET rocks%(rockstart% + rockcount%), Int(Rnd(1) * 360) '    create a random direction for the rock to move in
        'SPRITESPINSET rocks%(rockstart% + rockcount%), RND(1) * 2 - RND(1) * 2 '  put some spin on the rock
        SPRITEMOTION rocks%(rockstart% + rockcount%), MOVE '                       enable automotion for the rock sprite
        If Int(Rnd(1) * 2) = 1 Then SPRITEFLIP rocks%(rockstart% + rockcount%), Int(Rnd(1) * 3) + 1 'randomly flip rocks around
    Next rockcount%

End Sub

'##################################################################################################################################

Sub LoadGraphics ()

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Loads the game's graphics into memory.                                                                                         |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared rocksheet128%, rocksheet64%, rocksheet32%, rock%(), lfont%(), sfont%()
    Shared lfontsheet%, sfontsheet%, roundsheet%, round%(), shipsheet%, ship%
    Shared extraship%, bsaucersheet%, lsaucersheet%
    Shared bsaucer%, lsaucer%, sround%()

    Dim rock1%
    Dim rock2%
    Dim rock3%
    Dim count%

    rocksheet128% = SPRITESHEETLOAD("hrocks128.png", 128, 128, _RGB(0, 0, 0))
    rocksheet64% = SPRITESHEETLOAD("hrocks64.png", 64, 64, _RGB(0, 0, 0))
    rocksheet32% = SPRITESHEETLOAD("hrocks32.png", 32, 32, _RGB(0, 0, 0))
    rock%(1, 1) = SPRITENEW(rocksheet128%, 1, DONTSAVE)
    SPRITECOLLIDETYPE rock%(1, 1), PIXELDETECT
    SPRITESCORESET rock%(1, 1), 20
    rock%(1, 2) = SPRITENEW(rocksheet128%, 2, DONTSAVE)
    SPRITECOLLIDETYPE rock%(1, 2), PIXELDETECT
    SPRITESCORESET rock%(1, 2), 20
    rock%(1, 3) = SPRITENEW(rocksheet128%, 3, DONTSAVE)
    SPRITECOLLIDETYPE rock%(1, 3), PIXELDETECT
    SPRITESCORESET rock%(1, 3), 20
    rock%(2, 1) = SPRITENEW(rocksheet64%, 1, DONTSAVE)
    SPRITECOLLIDETYPE rock%(2, 1), PIXELDETECT
    SPRITESCORESET rock%(2, 1), 50
    rock%(2, 2) = SPRITENEW(rocksheet64%, 2, DONTSAVE)
    SPRITECOLLIDETYPE rock%(2, 2), PIXELDETECT
    SPRITESCORESET rock%(2, 2), 50
    rock%(2, 3) = SPRITENEW(rocksheet64%, 3, DONTSAVE)
    SPRITECOLLIDETYPE rock%(2, 3), PIXELDETECT
    SPRITESCORESET rock%(2, 3), 50
    rock%(3, 1) = SPRITENEW(rocksheet32%, 1, DONTSAVE)
    SPRITECOLLIDETYPE rock%(3, 1), PIXELDETECT
    SPRITESCORESET rock%(3, 1), 100
    rock%(3, 2) = SPRITENEW(rocksheet32%, 2, DONTSAVE)
    SPRITECOLLIDETYPE rock%(3, 2), PIXELDETECT
    SPRITESCORESET rock%(3, 2), 100
    rock%(3, 3) = SPRITENEW(rocksheet32%, 3, DONTSAVE)
    SPRITECOLLIDETYPE rock%(3, 3), PIXELDETECT
    SPRITESCORESET rock%(3, 3), 100
    lfontsheet% = SPRITESHEETLOAD("lfont19x29.png", 19, 29, _RGB(0, 0, 0))
    sfontsheet% = SPRITESHEETLOAD("ssfont9x15.png", 9, 15, _RGB(0, 0, 0))
    For count% = 0 To 35
        lfont%(count%) = SPRITENEW(lfontsheet%, count% + 1, DONTSAVE)
    Next count%
    For count% = 0 To 9
        sfont%(count%) = SPRITENEW(sfontsheet%, count% + 1, DONTSAVE)
    Next count%
    roundsheet% = SPRITESHEETLOAD("rounds11.png", 11, 11, NOTRANSPARENCY)
    For count% = 1 To 5
        round%(count%) = SPRITENEW(roundsheet%, 1, DONTSAVE)
        SPRITECOLLIDETYPE round%(count%), PIXELDETECT
        SPRITEANIMATESET round%(count%), 1, 3
        SPRITEANIMATION round%(count%), ANIMATE, FORWARDLOOP
    Next count%
    For count% = 1 To 3
        sround%(count%) = SPRITENEW(roundsheet%, 1, DONTSAVE)
        SPRITECOLLIDETYPE sround%(count%), PIXELDETECT
        SPRITEANIMATESET sround%(count%), 1, 3
        SPRITEANIMATION sround%(count%), ANIMATE, FORWARDLOOP
    Next count%
    shipsheet% = SPRITESHEETLOAD("ships41.png", 41, 41, _RGB(0, 0, 0))
    ship% = SPRITENEW(shipsheet%, 1, DONTSAVE)
    SPRITESCORESET ship%, 5
    SPRITECOLLIDETYPE ship%, PIXELDETECT
    extraship% = SPRITENEW(shipsheet%, 8, DONTSAVE)
    bsaucersheet% = SPRITESHEETLOAD("lsaucer51x33.png", 51, 33, _RGB(0, 0, 0))
    bsaucer% = SPRITENEW(bsaucersheet%, 1, DONTSAVE)
    SPRITECOLLIDETYPE bsaucer%, PIXELDETECT
    SPRITESCORESET bsaucer%, 200
    lsaucersheet% = SPRITESHEETLOAD("ssaucer25x16.png", 25, 16, _RGB(0, 0, 0))
    lsaucer% = SPRITENEW(lsaucersheet%, 1, DONTSAVE)
    SPRITECOLLIDETYPE lsaucer%, PIXELDETECT
    SPRITESCORESET lsaucer%, 1000

End Sub

'##################################################################################################################################

Sub LoadSounds

    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Loads the game's sounds into memory.                                                                                           |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared thrust&, beat&(), pfire&, explode&(), extralife&, bigsaucer&
    Shared littlesaucer&

    bigsaucer& = _SndOpen("lsaucer.ogg", "VOL, SYNC")
    littlesaucer& = _SndOpen("ssaucer.ogg", "VOL, SYNC")
    extralife& = _SndOpen("extraship.ogg", "VOL, SYNC")
    explode&(1) = _SndOpen("aexplode1.ogg", "VOL, SYNC")
    explode&(2) = _SndOpen("aexplode2.ogg", "VOL, SYNC")
    explode&(3) = _SndOpen("aexplode3.ogg", "VOL, SYNC")
    pfire& = _SndOpen("fire.ogg", "VOL, SYNC")
    thrust& = _SndOpen("thrust.ogg", "VOL, SYNC")
    beat&(0) = _SndOpen("thumplo.ogg", "VOL, SYNC")
    beat&(1) = _SndOpen("thumphi.ogg", "VOL,SYNC")
    _SndVol beat&(0), .25
    _SndVol beat&(1), .25

End Sub

'##################################################################################################################################

'$INCLUDE:'sprite.bi'
