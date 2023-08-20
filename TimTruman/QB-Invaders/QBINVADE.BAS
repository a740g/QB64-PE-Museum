'Program : QB Invaders
'Version : Ver 1.1 for Qbasic
'Type    : Shareware
'Revised : 4/29/97
'Author  : Tim Truman
'Address : NET -TimTruman@aol.com, AOL-TimTruman
'
'Copyright(c) 1997 Nocturnal Creations
'
'Feel free to use any routines or code found this program in your own
'as long as you credit Tim Truman as the contributer. Graphics and sounds
'are property of Tim Truman and may not be used.
'
'I just ask that you do not distribute this source code program or
'modify and recompile the program for reasons other than personal use.
'
'You are not obligated... however if you like QB Invaders, or plan to use
'code from it, please register by sending a small amount of money to :
'Tim Truman
'110 Homestead Ave.
'Springfield, MA 01151
'USA
'
'-------------------
'Info & Requirements
'-------------------
'Graphics for this program were made using SPRITE 2.0.
'Adlib sound effects were made using FX.
'Requires a VGA.
'Recommend 386 or higher processor, and a sound card.
'
'-------------------
'Running QBInvaders       * Important read this ! *
'-------------------
'Playing under DOS:
' Type qbasic /run qbinvade.
'
'Playing under WIN 3.1 and WIN 95 :
' Use the File Manager and double click on the MSDOS shortcut.
' Why?
' Some key combinations are reserved to windows like ALT-SPACE
' combo used by this program. Using the MSDOS shortcut realeases
' this key combo for Qbasic, preventing program errors.
'
'-------------------
' Program options
'-------------------
'  (1) Change the 'UseFX' variable to false for PC speaker sounds.
'  (2) Change the 'Hard' variable to true for harder gameplay.
'  (3) Two graphics set are available.


DEFINT A-Z
OPTION _EXPLICIT
$RESIZE:SMOOTH

'$INCLUDE:'adlib.bi'

TYPE Hues ' define the type for hues
    red AS INTEGER ' red component
    grn AS INTEGER ' green component
    blu AS INTEGER ' blue component
END TYPE

TYPE Sprite
    x AS INTEGER 'current alien location
    y AS INTEGER '
    lx AS INTEGER 'last alien location
    ly AS INTEGER '
    w AS INTEGER 'width of image
    h AS INTEGER 'height of image
    dir AS INTEGER 'referenced for movement
    health AS INTEGER 'aliens well being
    sseg AS INTEGER 'segment of alien char
    tile AS INTEGER 'offset to frame
    ltile AS INTEGER 'for erase
    hit AS INTEGER 'check for a hit before moving
END TYPE

TYPE Highscores 'type for highscores
    rank AS STRING * 3 'rank
    dat AS STRING * 8 'date
    nam AS STRING * 25 'name
    lines AS STRING * 4 'lines
    score AS STRING * 6 'score
END TYPE

'MAPPED KEY VALUES
CONST UP = -72
CONST DOWN = -80
CONST LEFT = -75
CONST RIGHT = -77
CONST EIGHT = 56
CONST TWO = 50
CONST ENTER = 13
CONST BACKSPACE = 8
CONST ESC = 27
CONST SPACE = 32
CONST LETTERC = 99
'MOUSE
CONST LEFTCLICK = 1
CONST RIGHTCLICK = 2
'OTHER
CONST FALSE = 0, TRUE = NOT FALSE
CONST MAXX = 319
CONST MAXY = 199

DIM SHARED AS INTEGER event
DIM SHARED AS INTEGER elmPerSpr, NewAlienFrame, spriteheight, spritewidth
REDIM SHARED alien(0 TO 0) AS Sprite
DIM SHARED AS INTEGER numberofaliens, AliensInPLay, movealiens
DIM SHARED AliensPerCol AS INTEGER, AliensPerRow AS INTEGER, alienvelx AS INTEGER, AlienVely AS INTEGER, TimeToStep AS SINGLE
DIM SHARED AS INTEGER AlienStartX, AlienStartY, AlienStepX, AlienStepY
REDIM SHARED abomb(0 TO 0) AS Sprite
DIM SHARED Numberofbombs AS INTEGER, AbombInterval AS SINGLE, Abombvel AS INTEGER
DIM SHARED gunner AS Sprite, gunnerlives AS INTEGER
DIM SHARED AS INTEGER gunnerMaxx, GunnerMinx, gunnervel
DIM SHARED gunshot AS Sprite, GunShotVel AS INTEGER
DIM SHARED cship AS Sprite, headisup AS INTEGER
REDIM SHARED shield(0 TO 0) AS Sprite
DIM SHARED NumberofShields AS INTEGER
REDIM SHARED Barrier(0 TO 0) AS Sprite
DIM SHARED level AS INTEGER, gamescore AS LONG, UseFX AS INTEGER, Hard AS INTEGER
DIM SHARED c$(8) 'FM register information for 9 channels
DIM SHARED sfx$(25) 'dim array to hold 26 sounds

_TITLE "QB Invaders"
SCREEN 13 'set video mode
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_MOUSEHIDE

PLAY "MB@1Q0" ' a740g: play SOUND and MML in the background, use square wave, no volume ramping

c$(0) = "&hB0&h20&h23&h40&h43&h60&h63&h80&h83&hA0&HBD&HC0&HE0&HE3&hB0"
c$(1) = "&hB1&h21&h24&h41&h44&h61&h64&h81&h84&hA1&HBD&HC1&HE1&HE4&hB1"
c$(2) = "&hB2&h22&h25&h42&h45&h62&h65&h82&h85&hA2&HBD&HC2&HE2&HE5&hB2"
c$(3) = "&hB3&h28&h2B&h48&h4B&h68&h6B&h88&h8B&hA3&HBD&HC3&HE8&HEB&hB3"
c$(4) = "&hB4&h29&h2C&h49&h4C&h69&h6C&h89&h8C&hA4&HBD&HC4&HE9&HEC&hB4"
c$(5) = "&hB5&h2A&h2D&h4A&h4D&h6A&h6D&h8A&h8D&hA5&HBD&HC5&HEA&HED&hB5"
c$(6) = "&hB6&h30&h33&h50&h53&h70&h73&h90&h93&hA6&HBD&HC6&HF0&HF3&hB6"
c$(7) = "&hB7&h31&h34&h51&h54&h71&h74&h91&h94&hA7&HBD&HC7&HF1&HF4&hB7"
c$(8) = "&hB8&h32&h35&h52&h55&h72&h75&h92&h95&hA8&HBD&HC8&HF2&HF5&hB8"

OPEN "qbinvade.sfx" FOR INPUT AS #1 'open the .SFX file
DIM sfxnum AS INTEGER: FOR sfxnum = 0 TO 25 'first to last
    INPUT #1, sfx$(sfxnum) 'load sound into string
NEXT 'next sound
CLOSE #1 'close the file

OUT &H60, &HF3 'inform keyboard port

OUT &H60, 0 'fast typematic rate with min delay

DIM bucket AS INTEGER: bucket = TimeIsUp(7, -1) 'set up timers

REDIM SHARED pal(255) AS Hues 'array for palette
DEF SEG = VARSEG(pal(0)) 'point to it
BLOAD "default.pal", 0 'load it
OUT &H3C8, 0 'inform VGA
DIM c AS INTEGER: FOR c = 0 TO 255 'entire palette
    OUT &H3C9, pal(c).red 'send red component
    OUT &H3C9, pal(c).grn 'send green component
    OUT &H3C9, pal(c).blu 'send blue component
NEXT 'next attribute

DIM SHARED font(127, 4, 6) AS INTEGER 'DIM array for fonts
DEF SEG = VARSEG(font(0, 0, 0)) 'Point to it
BLOAD "qbinvade.fnt", 0 'Load 'em in

' Unremark image file to load. **********   Choose graphics. *************
DIM filename$
filename$ = "atari.spr"
'filename$ = "qbinvade.spr"

CLS
DIM Filesize&: Filesize& = 12877 'File size
DIM bytes AS LONG: bytes = (Filesize& - 7) \ 2 - 1 'BSAVE & BLOAD use 7 bytes
REDIM SHARED sprites(bytes) AS INTEGER 'dim the sprite array
DEF SEG = VARSEG(sprites(0)) 'point to it
BLOAD filename$, 0 'load the sprite file
spritewidth = sprites(0) \ 8 'get image width
spriteheight = sprites(1) 'get image height
elmPerSpr = ((spritewidth * spriteheight) \ 2) + 3 ' elements in one image

RANDOMIZE TIMER 'seed randomizer
UseFX = TRUE 'set to false for PC speaker
Hard = FALSE 'set to true for harder gameplay
IF UseFX THEN Adlib_Handler ' calling this the first time will kickstart everything
TitleScreen 'start intro
InitGameStart 'init game varaibles/screen

DO 'level loop
    level = level + 1 'increment level
    Initlevel 'display graphics
    GetReady 'tell user game is ready

    DO 'game loop
        event = returnevent 'get events
        IF event = ESC THEN EndToDos 'user wants out
        DoAlienBombs
        DoAliens
        IF TimeIsUp(3, 15) THEN cship.health = TRUE 'time appearance of command ship
        DoCommandShip
        DoCollisions
        DoGunner
        DoGunShot

        _LIMIT 60
    LOOP UNTIL AliensInPLay = 0
LOOP

SYSTEM

'data to reconstruct qbinvader.scr in the event it is erased
DATA 1,4/11/97,Timothy Truman,2000
DATA 2,4/11/97,John Denesha,2000
DATA 3,4/11/97,David Pastore,2000
DATA 4,4/11/97,John Matias,2000
DATA 5,4/11/97,Mike Eberts,1500
DATA 6,4/11/97,Bonnie Soffan,1500
DATA 7,4/11/97,Patty Effilo,1500
DATA 8,4/11/97,Kelsi Donahue,1450
DATA 9,4/11/97,Sabrina McIntosh,1450
DATA 10,4/11/97,Colleen Wise,1450
DATA 11,4/11/97,Michelle Poules,1300
DATA 12,4/11/97,Dominic Amato,1300
DATA 13,4/11/97,Bobby Barkett,1300
DATA 14,4/11/97,Tracy Truman,1200
DATA 15,4/11/97,Chris Hitas,1200


' Visit this FTP for my latest programs and utilities :
'   members.aol.com/TimTruman

SUB DoAlienBombs
    DIM ab AS INTEGER: FOR ab = 1 TO Numberofbombs 'do alien bombs
        IF NOT abomb(ab).health THEN 'new one set up
            IF TimeIsUp(2, AbombInterval) THEN 'time has passed
                DIM a AS INTEGER: FOR a = 1 TO numberofaliens
                    IF alien(a).health THEN 'wide scan for gunner
                        IF alien(a).x < gunner.x OR alien(a).x > gunner.x - gunner.w THEN
                            DIM AlienUnder AS INTEGER: AlienUnder = FALSE 'assume alien under
                            DIM m AS INTEGER: FOR m = 1 TO AliensPerCol 'next row down
                                DIM lookunder AS INTEGER: lookunder = (a + (AliensPerRow * m)) 'calc down one
                                IF lookunder <= numberofaliens THEN 'Alien there ?
                                    IF alien(lookunder).health THEN AlienUnder = TRUE 'This one can't fire
                                END IF
                            NEXT
                            IF NOT AlienUnder THEN
                                DIM maybe AS INTEGER: maybe = RND * 12 'this one is possible
                                IF maybe > 1 AND maybe < 6 THEN 'use 'em
                                    abomb(ab).health = alien(a).health 'set up Bomp
                                    abomb(ab).x = alien(a).x + alien(a).w / 2 'ditto
                                    abomb(ab).y = alien(a).y + alien(a).h 'ditto
                                    abomb(ab).lx = abomb(ab).x 'ditto
                                    abomb(ab).ly = abomb(ab).y 'ditto
                                    EXIT FOR 'Outa here
                                END IF
                                'narrow scan
                                IF alien(a).x >= gunner.x AND alien(a).x < gunner.x + gunner.w THEN
                                    IF maybe <> 0 THEN 'use 'em
                                        abomb(ab).health = alien(a).health 'set up Bomp
                                        abomb(ab).x = alien(a).x + alien(a).w / 2 'ditto
                                        abomb(ab).y = alien(a).y + alien(a).h 'ditto
                                        abomb(ab).lx = abomb(ab).x 'ditto
                                        abomb(ab).ly = abomb(ab).y 'ditto
                                        EXIT FOR 'outa here
                                    END IF
                                END IF
                            END IF
                        END IF
                    END IF
                NEXT 'check next alien
            END IF

        ELSEIF abomb(ab).health THEN 'animate it
            LINE (abomb(ab).lx, abomb(ab).ly)-(abomb(ab).lx, abomb(ab).ly + abomb(ab).h), 0
            abomb(ab).y = abomb(ab).y + Abombvel + -Hard 'adjust bomb y
            IF abomb(ab).y > MAXY THEN 'it's off screen
                abomb(ab).health = FALSE 'Kill it
            ELSE 'still visible
                LINE (abomb(ab).x, abomb(ab).y)-(abomb(ab).x, abomb(ab).y + abomb(ab).h), 138
                abomb(ab).lx = abomb(ab).x: abomb(ab).ly = abomb(ab).y 'for erase
            END IF
        END IF

    NEXT
END SUB


SUB DoAliens
    STATIC AS INTEGER dir, ctr1

    IF TimeIsUp(1, TimeToStep) THEN 'Move aliens ?

        DIM a AS INTEGER: FOR a = 1 TO numberofaliens 'look for live aliens
            IF alien(a).health THEN 'got one
                DIM CountEm AS INTEGER: CountEm = CountEm + 1 'count em in
                IF dir = 1 THEN 'going left
                    alien(a).x = alien(a).x - alienvelx 'adjust x position
                    DIM dflag AS INTEGER
                    IF alien(a).x <= alienvelx THEN dflag = TRUE 'drop em ?
                    IF dflag AND CountEm = AliensInPLay THEN 'wait for every x adjust
                        DIM b AS INTEGER: FOR b = 1 TO numberofaliens 'drop em all at once
                            IF alien(b).health THEN alien(b).y = alien(b).y + AlienVely
                        NEXT 'next one
                        dflag = FALSE: dir = 0 'did drop; change direction
                    END IF
                ELSEIF dir = 0 THEN 'going right
                    alien(a).x = alien(a).x + alienvelx 'adjust x position
                    IF alien(a).x > MAXX - alien(a).w - alienvelx THEN dflag = TRUE ' drop ?
                    IF dflag AND CountEm = AliensInPLay THEN 'wait for every x adjust
                        FOR b = 1 TO numberofaliens 'drop em all at once
                            IF alien(b).health THEN alien(b).y = alien(b).y + AlienVely
                        NEXT 'next
                        dflag = FALSE: dir = 1 'did drop; change direction
                    END IF
                END IF
            END IF
        NEXT
        CountEm = 0 'reset
        movealiens = TRUE 'update screen
    END IF

    DO: LOOP UNTIL (INP(&H3DA) AND 8) 'wait for VGA retrace

    IF movealiens THEN
        FOR a = numberofaliens TO 1 STEP -1 'start at bot
            IF alien(a).health AND NOT alien(a).hit THEN 'got a live one
                PUT (alien(a).lx, alien(a).ly), sprites(elmPerSpr * 20), PSET 'erase last
                alien(a).tile = (alien(a).tile + elmPerSpr) MOD NewAlienFrame 'calc ani frame
                alien(a).tile = alien(a).tile + alien(a).sseg 'calc alien
                PUT (alien(a).x, alien(a).y), sprites(alien(a).tile), PSET 'Put it
                alien(a).lx = alien(a).x: alien(a).ly = alien(a).y 'for erase
                alien(a).ltile = alien(a).tile 'ditto
            END IF
        NEXT

        IF UseFX THEN
            ctr1 = (ctr1 + 1) MOD 2
            IF ctr1 THEN playsfx (sfx$(2)) ELSE playsfx (sfx$(3))
        ELSE
            soundfx (1)
        END IF
        movealiens = FALSE 'done

    END IF
END SUB


SUB DoCollisions
    '--* do collisions
    '--* check for collisions between aliens and gunshots using a bounding box

    DIM b AS INTEGER: FOR b = 1 TO numberofaliens
        IF alien(b).health AND gunshot.health THEN
            IF gunshot.y >= alien(b).y AND gunshot.y <= alien(b).y + alien(b).h THEN
                IF gunshot.x >= alien(b).x AND gunshot.x <= alien(b).x + alien(b).w THEN
                    PUT (alien(b).lx, alien(b).ly), sprites(alien(b).ltile) 'erase old
                    LINE (gunshot.lx, gunshot.ly)-(gunshot.lx, gunshot.ly + gunshot.h), 0
                    'soundfx (4)
                    IF UseFX THEN
                        playsfx (sfx$(1))
                    ELSE
                        soundfx (4)
                    END IF

                    alien(b).health = FALSE
                    gunshot.health = FALSE
                    AliensInPLay = AliensInPLay - 1 'one less alien
                    DIM row AS INTEGER: row = ((b - 1) \ (AliensPerRow)) + 1
                    DIM points AS INTEGER: points = 5 * ABS(row - (AliensPerRow + 1))
                    DoScore (points)
                    EXIT FOR
                END IF
            END IF
        END IF
    NEXT

    '--* check for collisions between alien bombs and barriers

    DIM ab AS INTEGER: FOR ab = 1 TO Numberofbombs
        FOR b = 1 TO 2
            IF abomb(ab).health THEN
                IF abomb(ab).y > Barrier(b).y AND abomb(ab).y < Barrier(b).y + spriteheight THEN
                    IF abomb(ab).x >= Barrier(b).x AND abomb(ab).x <= Barrier(b).x + spritewidth THEN
                        abomb(ab).health = FALSE
                        LINE (abomb(ab).lx, abomb(ab).ly)-(abomb(ab).lx, abomb(ab).ly + abomb(ab).h), 0
                    END IF
                END IF
            END IF
        NEXT
    NEXT

    '--* check for collisions between alien bombs and gunner

    FOR ab = 1 TO Numberofbombs
        IF abomb(ab).health THEN
            IF abomb(ab).x > (gunner.x + 4) AND abomb(ab).x < (gunner.x + gunner.w - 4) THEN
                IF abomb(ab).y >= gunner.y AND abomb(ab).y <= gunner.y THEN
                    abomb(ab).health = FALSE
                    gunner.health = FALSE
                    LINE (abomb(ab).lx, abomb(ab).ly)-(abomb(ab).lx, abomb(ab).ly + abomb(ab).h), 0
                END IF
            END IF
        END IF
    NEXT


    '--* bombs against gunshots

    FOR ab = 1 TO Numberofbombs
        IF abomb(ab).health AND gunshot.health THEN
            IF abomb(ab).x = gunshot.x THEN
                IF abomb(ab).y >= gunshot.y AND abomb(ab).y <= gunshot.y + gunshot.h THEN
                    abomb(ab).health = FALSE
                    gunshot.health = FALSE
                    LINE (abomb(ab).lx, abomb(ab).ly)-(abomb(ab).lx, abomb(ab).ly + abomb(ab).h), 0
                    LINE (gunshot.x, gunshot.y)-(gunshot.x, gunshot.y + gunshot.h), 0, BF 'ditto
                    IF UseFX THEN
                        playsfx (sfx$(4))
                    ELSE
                        soundfx (3)
                    END IF
                END IF
            END IF
        END IF
    NEXT

    '--* alienbombs against shields

    DIM s AS INTEGER: FOR s = 1 TO NumberofShields
        FOR ab = 1 TO Numberofbombs
            IF abomb(ab).x > shield(s).x AND abomb(ab).x < shield(s).x + shield(s).w THEN
                IF abomb(ab).y >= shield(s).y AND abomb(ab).y <= shield(s).y + shield(s).h THEN
                    IF POINT(abomb(ab).x, abomb(ab).y + abomb(ab).h + 1) > 0 THEN
                        LINE (abomb(ab).x, abomb(ab).y)-(abomb(ab).x, abomb(ab).y + abomb(ab).h + 1), 0
                        PSET (abomb(ab).x + (RND * -2), abomb(ab).y + abomb(ab).h + 1), 0
                        PSET (abomb(ab).x + (RND * 2), abomb(ab).y + abomb(ab).h + 1), 0
                        abomb(ab).health = FALSE
                    END IF
                END IF
            END IF
        NEXT
    NEXT

    '--* gunshots against shields

    FOR s = 1 TO NumberofShields
        IF gunshot.x > shield(s).x AND gunshot.x < shield(s).x + shield(s).w THEN
            IF gunshot.y >= shield(s).y AND gunshot.y <= shield(s).y + shield(s).h THEN
                IF POINT(gunshot.x, gunshot.y - 1) > 0 THEN
                    LINE (gunshot.x, gunshot.y - 1)-(gunshot.x, gunshot.y + gunshot.h), 0
                    gunshot.health = FALSE
                END IF
            END IF
        END IF
    NEXT

    '--* gunshots against command ship

    IF cship.health AND gunshot.health THEN
        IF gunshot.y < cship.y + spriteheight THEN
            IF gunshot.x > cship.x AND gunshot.x < cship.x + spritewidth THEN

                IF headisup THEN
                    gunnerlives = gunnerlives + 1
                    IF UseFX THEN
                        playsfx sfx$(7)
                    ELSE
                        soundfx 7
                    END IF
                ELSE
                    IF UseFX THEN
                        playsfx sfx$(6)
                    ELSE
                        soundfx 6
                    END IF
                END IF

                cship.health = FALSE
                gunshot.health = FALSE
                LINE (gunshot.x, gunshot.y)-(gunshot.x, gunshot.y + gunshot.h), 0, BF 'ditto
                DoScore 50
            END IF
        END IF
    END IF

    DIM a AS INTEGER: FOR a = 1 TO numberofaliens
        IF alien(a).y + alien(a).h >= gunner.y THEN
            IF UseFX THEN
                playsfx sfx$(9)
            ELSE
                soundfx 5
            END IF
            _KEYCLEAR
            DO: LOOP UNTIL returnevent
            DoGameEnd
        END IF
    NEXT
END SUB


SUB DoCommandShip
    STATIC AS INTEGER initialize, startframe, frame, framedir, counter

    IF cship.health THEN

        IF NOT initialize THEN
            startframe = (24 * elmPerSpr) 'calc start frame
            cship.x = 300 'set start coridinates
            cship.y = 1 'ditto
            DIM xerase AS INTEGER: FOR xerase = 1 TO 300 STEP 20 'clear top of screen
                PUT (xerase, 1), sprites(20 * elmPerSpr), PSET
            NEXT
            ' soundfx (8)                        'make command ship noise
            IF UseFX THEN
                playsfx sfx$(5)
            ELSE
                soundfx 8
            END IF

            initialize = NOT initialize 'don't do this again
        END IF

        IF TimeIsUp(5, 3) THEN 'soundfx (8)                   'time sound effect
            IF UseFX THEN
                playsfx sfx$(5)
            ELSE
                soundfx 8
            END IF
        END IF
        PUT (cship.lx, cship.y), sprites(20 * elmPerSpr), PSET 'clear spot
        PUT (cship.x, cship.y), sprites(startframe + (frame * elmPerSpr)), PSET

        IF framedir = 0 THEN 'add to last frame
            IF TimeIsUp(4, 1.1) THEN frame = (frame + 1) MOD 6 'time frames
            IF frame = 5 THEN 'extra life hitting this frame
                headisup = TRUE 'raise flag
                framedir = 1 'reverse frame direction
            END IF
        ELSE 'subtract from last frame
            IF TimeIsUp(4, 1.1) THEN
                frame = (frame - 1) 'time frames
                headisup = FALSE 'drop flag
            END IF
            IF frame = 0 THEN framedir = 0 'reverse frame direction
        END IF

        cship.lx = cship.x 'save for erase

        counter = (counter + 1) MOD 3 'slow down ship movement
        IF counter = 2 THEN cship.x = cship.x - 1 'move ship

        IF cship.x <= 1 THEN cship.health = FALSE 'ship reached left limit

    ELSEIF cship.health = FALSE THEN 'ship has gone off screen

        IF initialize THEN
            PUT (cship.x, 1), sprites(20 * elmPerSpr), PSET 'remove ship
            DIM bitbucket AS INTEGER
            bitbucket = TimeIsUp(3, 0) 'reset timers
            bitbucket = TimeIsUp(4, 0) 'ditto
            bitbucket = TimeIsUp(5, 0) 'ditto
            initialize = NOT initialize 'to re-initialize ship
            framedir = 0 'reset frame direction
            DoScore (0) 'redraw score and lives
        END IF
    END IF
END SUB


FUNCTION DoExplode (x AS INTEGER, y AS INTEGER)
    STATIC AS INTEGER frame

    DIM ExplodeFrame AS INTEGER: ExplodeFrame = elmPerSpr * 17 'point to Explosion frames

    DoExplode = FALSE

    PUT (x, y), sprites(ExplodeFrame + (frame * elmPerSpr)), PSET ' dislplay it

    IF TimeIsUp(3, .4) THEN 'time each frame
        PUT (x, y), sprites(ExplodeFrame + ((frame + 1) * elmPerSpr)), PSET ' dislplay it
        frame = (frame + 1) MOD 3 'calc next frame
        IF frame = 0 THEN DoExplode = TRUE 'Did all frames
    END IF
END FUNCTION


SUB DoGameEnd
    Pfont "Game Over", 125, 90, 190
    playsfx (sfx$(10))
    DO: LOOP UNTIL returnevent

    DoHighScores

    SYSTEM
END SUB


SUB DoGunner
    IF gunner.health THEN

        IF _KEYDOWN(19712) OR _KEYDOWN(100305) THEN 'left ctrl key
            gunner.x = gunner.x + gunnervel 'move gunner                                'check Ctrl key
        END IF

        IF _KEYDOWN(19200) OR _KEYDOWN(100308) THEN 'alt key
            gunner.x = gunner.x - gunnervel 'move gunner
        END IF

        IF gunner.x > gunnerMaxx THEN gunner.x = gunnerMaxx 'keep gunner in bounds
        IF gunner.x < GunnerMinx THEN gunner.x = GunnerMinx 'ditto

        IF gunner.x <> gunner.lx THEN 'gunner moved ?
            PUT (gunner.lx, gunner.ly), sprites(gunner.ltile) 'erase old
            gunner.tile = ((gunner.tile + elmPerSpr) MOD NewAlienFrame) + gunner.sseg
            PUT (gunner.x, gunner.y), sprites(gunner.tile), PSET 'draw new
            gunner.lx = gunner.x: gunner.ly = gunner.y 'for erase
            gunner.ltile = gunner.tile 'ditto
        END IF

    ELSE 'gunner got hit

        IF UseFX THEN 'make hit noise
            playsfx (sfx$(8))
        ELSE
            soundfx (2)
        END IF

        DO
            _KEYCLEAR 'clear key buffer
            IF DoExplode(gunner.x, gunner.y) THEN 'show all frames ?
                DO: _KEYCLEAR: LOOP UNTIL TimeIsUp(3, .7) 'wait a bit so user can get ready
                gunnerlives = gunnerlives - 1 'less one gun
                DoScore (0) 'redraw gun count
                IF gunnerlives = 0 THEN DoGameEnd 'any more guns ?
                DIM ab AS INTEGER: FOR ab = 1 TO Numberofbombs 'yes, then reset alien bombs
                    abomb(ab).health = FALSE 'kill bomb and remove it from screen
                    LINE (abomb(ab).x, abomb(ab).y)-(abomb(ab).x, abomb(ab).y + abomb(ab).h), 0
                NEXT 'next alien bomb
                gunner.health = TRUE 'reset gunner health
                PUT (gunner.x, gunner.y), sprites(gunner.tile), PSET 'put on screen
            END IF
        LOOP UNTIL gunner.health ' all done

    END IF
END SUB


SUB DoGunShot
    STATIC AS INTEGER colour

    IF NOT gunshot.health THEN 'Do gun shot
        IF event = SPACE THEN 'fire shot ?
            gunshot.x = gunner.x + (gunner.w / 2) 'calc pos
            gunshot.y = gunner.y - 1
            gunshot.health = TRUE 'give it life
            gunshot.lx = gunner.x 'for erase
            gunshot.ly = gunner.y 'ditto
            'IF usefx THEN playsfx (sfx$(0))
        END IF
    ELSEIF gunshot.health THEN 'animate it
        PSET (gunshot.lx, gunshot.ly), 0 'erase last
        LINE -(gunshot.lx, gunshot.ly + gunshot.h), 0, BF 'ditto
        gunshot.y = gunshot.y - GunShotVel 'move shot

        IF cship.health THEN
            IF gunshot.y < 1 THEN gunshot.health = FALSE 'it's off screen
        ELSE
            IF gunshot.y < spriteheight + 1 THEN gunshot.health = 0
        END IF
        IF gunshot.health THEN
            colour = ((colour + 1) MOD 16) + 48
            PSET (gunshot.x, gunshot.y), 0 'draw new
            LINE -(gunshot.x, gunshot.y + gunshot.h), colour 'ditto
            gunshot.lx = gunshot.x: gunshot.ly = gunshot.y 'for erase
        END IF
    END IF
END SUB


SUB DoHighScores
    DIM fc AS INTEGER: fc = 199

    DIM score(1 TO 16) AS Highscores

    DIM filespec$: filespec$ = "qbvaders.scr"

    OPEN filespec$ FOR RANDOM AS #1 LEN = 46 'open high score file
    DIM n AS INTEGER: FOR n = 1 TO 15 'first to last
        GET #1, n, score(n) 'load it in
    NEXT n 'next entry
    CLOSE #1 'close the file

    IF VAL(score(1).score) = 0 THEN 'did file exist
        OPEN filespec$ FOR RANDOM AS #1 LEN = 46 'create file
        FOR n = 1 TO 15 'first to last
            DIM a$, b$, c$, d$
            READ a$, b$, c$, d$ 'read in data
            score(n).rank = a$ 'store it
            score(n).dat = b$ 'ditto
            score(n).nam = c$ 'ditto
            score(n).score = d$ 'ditto
            PUT #1, n, score(n) 'write it
        NEXT n 'next entry
        CLOSE #1 'close file
    END IF


    DIM Temp$: Temp$ = LTRIM$(STR$(gamescore&)) 'convert to clean string
    DIM addpad AS INTEGER: addpad = 6 - LEN(Temp$) 'calc padding
    DIM gamescor$: gamescor$ = Temp$ + STRING$(addpad, 32) 'add it

    DIM rank AS INTEGER: FOR rank = 1 TO 15 'find players rank

        IF gamescore& > VAL(score(rank).score) THEN 'make the list ?
            DIM madelist AS INTEGER: madelist = TRUE 'setflag

            DIM bump AS INTEGER: FOR bump = 14 TO rank STEP -1 'sort it
                score(bump + 1).dat = score(bump).dat 'bump ahead
                score(bump + 1).nam = score(bump).nam 'ditto
                score(bump + 1).score = score(bump).score 'ditto
            NEXT 'bump next
            DIM month$: month$ = MID$(DATE$, 1, 2) 'get month
            DIM day$: day$ = MID$(DATE$, 4, 2) 'get day
            DIM year$: year$ = MID$(DATE$, 9, 2) 'get year
            DIM format$: format$ = month$ + "/" + day$ + "/" + year$ 'format the date
            score(rank).dat = format$ 'store it
            score(rank).nam = SPACE$(14) 'blank name
            score(rank).score = gamescor$ 'store gamescore
            ShowHighScores score(), 1 'print the list
            DIM y AS INTEGER: y = (rank * 10) + 26 'calc y
            score(rank).nam = InputText$(93 + 8, y, 199) 'enter name
            OPEN filespec$ FOR RANDOM AS #1 LEN = 46 'open file to save
            FOR n = 1 TO 15 'first to last
                PUT #1, n, score(n) 'write entry
            NEXT 'next entry
            CLOSE #1 'close file
            EXIT FOR 'all done
        END IF
    NEXT

    IF madelist = FALSE THEN ShowHighScores score(), 0
END SUB


SUB Dolevel
    SELECT CASE level

        CASE 1 TO 5
            AlienStartY = (level * 7) + 20
            alienvelx = 1
            TimeToStep = .5

        CASE 6 TO 11
            AlienStartY = 18
            alienvelx = (level - 6) + 1
            TimeToStep = .5

        CASE 12
            AlienStartY = 21
            alienvelx = alienvelx - 2

        CASE 13 TO 17
            AlienStartY = ((level - 14) * 7) + 20
            alienvelx = ((level - 14) + 1)
            TimeToStep = .5

        CASE 18 TO 24
            AlienStartY = ((level - 18) * 7) + 20
            alienvelx = ((level - 18) + 2)
            TimeToStep = .5

        CASE 25
            AlienStartY = ((level - 25) * 7) + 20
            alienvelx = 7

        CASE 26
            AlienStartY = ((level - 26) * 7) + 20
            alienvelx = 1
            TimeToStep = .5
            level = 1

    END SELECT
END SUB


SUB DoScore (points AS INTEGER)
    STATIC gunnerlives AS INTEGER, lTimeToStep AS SINGLE

    SELECT CASE AliensInPLay
        CASE 1: TimeToStep = .01: IF level = 25 THEN TimeToStep = 0!
        CASE 4: TimeToStep = .09
        CASE 5 TO 8: TimeToStep = .15
        CASE 9 TO 22: TimeToStep = .25
        CASE 23 TO 42: TimeToStep = .5
    END SELECT

    IF lTimeToStep <> TimeToStep THEN
        SELECT CASE AliensInPLay
            CASE 1: alienvelx = alienvelx + 4
            CASE 4: alienvelx = alienvelx + 1
            CASE 9 TO 22: alienvelx = alienvelx + 1
        END SELECT
    END IF
    lTimeToStep = TimeToStep

    DIM startframe AS INTEGER: startframe = (30 * elmPerSpr) 'point to start of score frames
    DIM xscore AS INTEGER: xscore = 1
    DIM yscore AS INTEGER: yscore = 1
    DIM xstep AS INTEGER: xstep = 20
    gamescore& = gamescore& + points


    IF NOT cship.health THEN

        DIM onedigit AS INTEGER: onedigit = (gamescore& \ 1) MOD 10
        DIM tendigit AS INTEGER: tendigit = (gamescore& \ 10) MOD 10
        DIM hdigit AS INTEGER: hdigit = (gamescore& \ 100) MOD 10
        DIM tdigit AS INTEGER: tdigit = (gamescore& \ 1000) MOD 10
        DIM ttdigit AS INTEGER: ttdigit = (gamescore& \ 10000) MOD 10

        PUT (xscore, yscore), sprites(startframe + (ttdigit * elmPerSpr)), PSET
        PUT (xscore + xstep, yscore), sprites(startframe + (tdigit * elmPerSpr)), PSET
        PUT (xscore + (xstep * 2), yscore), sprites(startframe + (hdigit * elmPerSpr)), PSET
        PUT (xscore + (xstep * 3), yscore), sprites(startframe + (tendigit * elmPerSpr)), PSET
        PUT (xscore + (xstep * 4), yscore), sprites(startframe + (onedigit * elmPerSpr)), PSET


        'gunnerlives = 10
        DIM lives AS INTEGER: FOR lives = 1 TO 10
            IF lives >= gunnerlives THEN
                DIM gx AS INTEGER
                PUT (280 - gx, yscore), sprites(elmPerSpr * 20), PSET
            ELSE
                PUT (280 - gx, yscore), sprites(gunner.tile), PSET
            END IF
            gx = gx + xstep
        NEXT

    END IF
END SUB


SUB EndToDos
    DIM buffer(1000)

    DIM x1 AS INTEGER: x1 = 130
    DIM x2 AS INTEGER: x2 = 190
    DIM y1 AS INTEGER: y1 = 90
    DIM y2 AS INTEGER: y2 = 102

    GET (x1, y1)-(x2, y2), buffer()

    LINE (x1, y1)-(x2, y2), 120, BF
    LINE (x1, y1)-(x2, y2), 123, B
    p5x7font x1 + 3, y1 + 3, "Quit? (y/n)", 1
    DO
        event = returnevent

        SELECT CASE event
            CASE 89, 121
                EXIT DO
            CASE 78, 110
                PUT (x1, y1), buffer(), PSET
                EXIT SUB
        END SELECT
    LOOP
    'zero out adlib regs incase of hanging sounds
    DIM sfx AS INTEGER: FOR sfx = 11 TO 19 'sounds effects 11 through 19 zero out all channels
        IF UseFX THEN playsfx (sfx$(sfx))
    NEXT

    SYSTEM
END SUB


SUB FadePal (fc AS INTEGER, lc AS INTEGER, level AS INTEGER, mode AS INTEGER)
    STATIC savepal(0 TO 255) AS Hues
    DIM value AS LONG

    IF mode THEN 'fade in
        FOR value = 0 TO level 'bring 'em all up
            OUT &H3C8, fc 'tell video card to get ready
            DIM attrib AS INTEGER: FOR attrib = fc TO lc 'first color to last color

                IF pal(attrib).red < savepal(attrib).red THEN pal(attrib).red = pal(attrib).red + 1
                IF pal(attrib).grn < savepal(attrib).grn THEN pal(attrib).grn = pal(attrib).grn + 1
                IF pal(attrib).blu < savepal(attrib).blu THEN pal(attrib).blu = pal(attrib).blu + 1

                OUT &H3C9, pal(attrib).red 'send red component
                OUT &H3C9, pal(attrib).grn 'send green component
                OUT &H3C9, pal(attrib).blu 'send blue component
            NEXT attrib

            _DELAY 0.002!
            _KEYCLEAR
        NEXT value

    ELSE 'fade out
        FOR attrib = 0 TO 255
            savepal(attrib).red = pal(attrib).red 'save pal to restore
            savepal(attrib).grn = pal(attrib).grn 'ditto
            savepal(attrib).blu = pal(attrib).blu 'ditto
        NEXT

        FOR value = 0 TO level
            OUT &H3C8, fc 'tell video card to get ready
            FOR attrib = fc TO lc 'first color to last color

                IF pal(attrib).red > 0 THEN pal(attrib).red = pal(attrib).red - 1
                IF pal(attrib).grn > 0 THEN pal(attrib).grn = pal(attrib).grn - 1
                IF pal(attrib).blu > 0 THEN pal(attrib).blu = pal(attrib).blu - 1

                OUT &H3C9, pal(attrib).red 'send red component
                OUT &H3C9, pal(attrib).grn 'send green component
                OUT &H3C9, pal(attrib).blu 'send blue component
            NEXT attrib

            _DELAY 0.002!
            _KEYCLEAR
        NEXT value
    END IF
END SUB


SUB GetReady
    DO
        _KEYCLEAR
    LOOP UNTIL TimeIsUp(7, 1) 'wait a bit so user can get ready
    _KEYCLEAR

    DIM x1 AS INTEGER: x1 = 130
    DIM y1 AS INTEGER: y1 = 80

    DO

        DIM toggle AS INTEGER: IF TimeIsUp(5, .4) THEN toggle = NOT toggle
        IF toggle THEN
            p5x7font x1, y1, "Get Ready", 0
            p5x7font x1, y1 + 8, "Wave " + STR$(level), 0


        ELSE
            p5x7font x1, y1, "Get Ready", 190
            p5x7font x1, y1 + 8, "Wave " + STR$(level), 190
        END IF

        IF TimeIsUp(6, 4) THEN EXIT DO

    LOOP UNTIL returnevent = SPACE

    p5x7font x1, y1, "Get Ready", 0
    p5x7font x1, y1 + 8, "Wave " + STR$(level), 0
END SUB


SUB InitGameStart
    '--* set up aliens

    AliensPerRow = 6 'eight max
    IF Hard THEN AliensPerRow = 8
    AliensPerCol = 6 'six max
    numberofaliens = (AliensPerRow * AliensPerCol)
    AliensInPLay = numberofaliens
    REDIM alien(AliensInPLay) AS Sprite 'need storage
    AlienStepX = 35 'spaceing
    AlienStepY = 20 'ditto
    AlienStartX = 35 'position
    AlienStartY = 20
    alienvelx = 2 'velocity
    AlienVely = AlienStepY / 2 'ditto
    DIM Cornerx AS INTEGER: Cornerx = AlienStartX 'for adding steps
    DIM Cornery AS INTEGER: Cornery = AlienStartY 'ditto
    DIM AlienEndX AS INTEGER: AlienEndX = (AlienStepX * AliensPerRow) + AlienStartX 'calc end column
    NewAlienFrame = (elmPerSpr * 2) 'to skip animation frames


    '--*set up gunner 1
    gunnerlives = 3
    gunnerMaxx = MAXX - (20 * 4) 'set limits of movement
    GunnerMinx = (20 * 3) 'ditto
    DIM GunnerY AS INTEGER: GunnerY = MAXY - 14 'placement
    gunnervel = 1 'velocity
    gunner.x = gunnerMaxx - 18 'start position
    gunner.y = MAXY - 14 'ditto
    gunner.lx = gunner.x - 1 'force update
    gunner.ly = gunner.y 'ditto
    gunner.w = spritewidth 'gunner width
    gunner.h = spriteheight 'gunner height
    gunner.health = TRUE 'set health
    gunner.sseg = elmPerSpr * 14 'pointer to image
    gunner.tile = elmPerSpr * 14 'offset to frame
    gunner.ltile = elmPerSpr * 14 'for erase

    '--* set up gunshots
    gunshot.w = 1
    gunshot.h = 4
    gunshot.health = FALSE
    GunShotVel = 2

    '--* set up alien bombs
    Numberofbombs = 3
    REDIM abomb(Numberofbombs) AS Sprite
    DIM ab AS INTEGER: FOR ab = 1 TO Numberofbombs
        abomb(ab).w = 1
        abomb(ab).h = 4
        abomb(ab).health = FALSE
    NEXT
    Abombvel = 1
    AbombInterval = .2

    '--* set up shields

    NumberofShields = 3
    REDIM shield(NumberofShields) AS Sprite
    shield(1).x = 80
    shield(1).y = 170
    shield(2).x = 150
    shield(2).y = 170
    shield(3).x = 220
    shield(3).y = 170
    DIM s AS INTEGER: FOR s = 1 TO NumberofShields
        shield(s).w = 20
        shield(s).h = 14
    NEXT

    '--* set up barriers

    REDIM Barrier(2) AS Sprite
    Barrier(1).x = GunnerMinx - spritewidth
    Barrier(1).y = GunnerY
    Barrier(1).tile = elmPerSpr * 12
    Barrier(2).x = gunnerMaxx + spritewidth
    Barrier(2).y = GunnerY
    Barrier(2).tile = elmPerSpr * 13


    PUT (Barrier(1).x, Barrier(1).y), sprites(Barrier(1).tile), PSET
    PUT (Barrier(2).x, Barrier(2).y), sprites(Barrier(2).tile), PSET

    DoScore (0) 'display score
END SUB


SUB Initlevel
    Dolevel
    '--* reset alien bombs
    DIM ab AS INTEGER: FOR ab = 1 TO Numberofbombs 'Do alien bombs
        abomb(ab).health = FALSE 'reset em
        LINE (abomb(ab).lx, abomb(ab).ly)-(abomb(ab).lx, abomb(ab).ly + abomb(ab).h), 0
        LINE (abomb(ab).x, abomb(ab).y)-(abomb(ab).x, abomb(ab).y + abomb(ab).h), 0
    NEXT
    '--* reset barriers
    PUT (shield(1).x, shield(1).y), sprites(elmPerSpr * 21), PSET
    PUT (shield(2).x, shield(2).y), sprites(elmPerSpr * 22), PSET
    PUT (shield(3).x, shield(3).y), sprites(elmPerSpr * 23), PSET
    '--* reset gunner1
    PUT (gunner.x, gunner.y), sprites(20 * elmPerSpr), PSET
    gunner.x = gunnerMaxx - 18
    gunner.lx = gunner.x
    PUT (gunner.x, gunner.y), sprites(gunner.tile), PSET
    '--* reset aliens
    AliensInPLay = numberofaliens
    movealiens = TRUE 'so aliens appear
    DIM Cornerx AS INTEGER: Cornerx = AlienStartX 'for adding steps
    DIM Cornery AS INTEGER: Cornery = AlienStartY 'ditto
    DIM AlienEndX AS INTEGER: AlienEndX = (AlienStepX * AliensPerRow) + AlienStartX 'calc end column
    NewAlienFrame = (elmPerSpr * 2) 'to skip animation frames
    DIM NextChar AS INTEGER: NextChar = 0
    DIM NextFrame AS INTEGER: NextFrame = 0
    DIM a AS INTEGER: FOR a = 1 TO numberofaliens 'initilaize aliens
        alien(a).x = Cornerx 'position
        alien(a).y = Cornery 'ditto
        alien(a).lx = Cornerx 'ditto
        alien(a).ly = Cornery 'ditto
        alien(a).w = spritewidth 'size
        alien(a).h = spriteheight 'ditto
        alien(a).dir = 1 'walk towards left
        alien(a).health = TRUE 'make alive
        alien(a).sseg = NextChar 'pointer to images
        alien(a).tile = NextChar 'offset to frame
        alien(a).ltile = NextChar 'for erase
        NextFrame = (NextFrame + elmPerSpr) MOD NewAlienFrame 'calc next frame
        Cornerx = Cornerx + AlienStepX 'next column
        IF Cornerx = AlienEndX THEN 'last in row
            Cornerx = AlienStartX 'reset column
            Cornery = Cornery + AlienStepY 'next row
            NextChar = NextChar + (NewAlienFrame) 'next char
        END IF
    NEXT
END SUB


FUNCTION InputText$ (xcur AS INTEGER, ycur AS INTEGER, length AS INTEGER)
    DIM AS INTEGER red, grn, blu

    PalRegInfo 255, red, 0, 0, 1 'define cursor color
    DIM Edit$(length) 'DIM array to edit
    DIM ele AS INTEGER: ele = 1 'set first element
    DIM background(35, length + 2) 'DIM array to save background
    GET (xcur, ycur)-(xcur + 6, ycur + 8), background(35, 1) 'GET background
    p5x7font xcur, ycur, "_", 255 'init curser


    _KEYCLEAR 'clear the keybuffer

    DO
        DO 'event loop
            event = returnevent 'anything happen ?
            DIM dir AS INTEGER
            IF dir = 0 THEN 'strobe cursor
                red = red + 1: IF red > 62 THEN dir = 1 'ditto
            ELSE 'ditto
                red = red - 1: IF red < 10 THEN dir = 0 'ditto
            END IF 'ditto
            PALETTE 255, (65536 * blu) + (256 * grn) + red 'ditto
        LOOP UNTIL event 'back for event

        SELECT CASE event

            CASE ESC: EXIT DO 'do Esc
            CASE ENTER: EXIT DO 'do enter

            CASE 1 TO 7, 9 TO 126 'do regular keys
                DIM event$: event$ = CHR$(event) 'convert for printing
                IF ele < length THEN 'stay in bounds
                    PUT (xcur, ycur), background(35, ele), PSET
                    p5x7font xcur, ycur, CHR$(event), 191 'print font
                    Edit$(ele) = event$ 'in case of backspace
                    SELECT CASE event$ 'adjust kern
                        CASE "i": xcur = xcur + 2 'ditto
                        CASE "j": xcur = xcur + 5 'ditto
                        CASE "l": xcur = xcur + 2 'ditto
                        CASE "r": xcur = xcur + 5 'ditto
                        CASE ".": xcur = xcur + 3 'ditto
                        CASE "(": xcur = xcur + 3 'ditto
                        CASE ")": xcur = xcur + 3 'ditto
                        CASE "'": xcur = xcur + 2 'ditto
                        CASE "!": xcur = xcur + 2 'ditto
                        CASE ELSE: xcur = xcur + 6 'ditto
                    END SELECT
                    ele = ele + 1 'advance to next element
                    GET (xcur, ycur)-(xcur + 6, ycur + 8), background(35, ele)
                    p5x7font xcur, ycur, "_", 255 'print cursor
                END IF

            CASE BACKSPACE, LEFT 'do backspace

                IF ele > 1 THEN
                    PUT (xcur, ycur), background(35, ele), PSET 'restore background
                    ele = ele - 1 'move to previous element
                    SELECT CASE (Edit$(ele)) 'adjust kern
                        CASE "i": xcur = xcur - 2 'ditto
                        CASE "j": xcur = xcur - 5 'ditto
                        CASE "l": xcur = xcur - 2 'ditto
                        CASE "r": xcur = xcur - 5 'ditto
                        CASE ".": xcur = xcur - 3 'ditto
                        CASE "(": xcur = xcur - 3 'ditto
                        CASE ")": xcur = xcur - 3 'ditto
                        CASE "'": xcur = xcur - 2 'ditto
                        CASE "!": xcur = xcur - 2 'ditto
                        CASE ELSE: xcur = xcur - 6 'ditto
                    END SELECT
                    PUT (xcur, ycur), background(35, ele), PSET
                    p5x7font xcur, ycur, "_", 255 'print cursor
                    Edit$(ele) = CHR$(SPACE) 'clear element
                END IF
        END SELECT

        _LIMIT 60
    LOOP

    DIM n AS INTEGER: FOR n = 1 TO length - 1 'put elements into a string
        IF Edit$(n) = "" THEN Edit$(n) = CHR$(SPACE) 'replace nulls
        DIM Temp$: Temp$ = Temp$ + Edit$(n) 'create string
    NEXT n

    InputText$ = Temp$ 'return the string
END FUNCTION


SUB p5x7font (x AS INTEGER, y AS INTEGER, text AS STRING, colour AS INTEGER)
    DIM length AS INTEGER: length = LEN(text$) 'get characters to print
    IF length = 0 THEN EXIT SUB 'check length

    DIM char AS INTEGER: FOR char = 0 TO length - 1 'print loop

        DIM piece$: piece$ = MID$(text$, char + 1, 1) 'look at each piece of string
        DIM aski AS INTEGER: aski = ASC(piece$) 'assign it's ASCII value

        DIM kerny AS INTEGER
        SELECT CASE (piece$) 'adjust lower case
            CASE "g": kerny = kerny + 2 'ditto
            CASE "j": kerny = kerny + 2 'ditto
            CASE "p": kerny = kerny + 2 'ditto
            CASE "q": kerny = kerny + 2 'ditto
            CASE "y": kerny = kerny + 2 'ditto
        END SELECT

        DIM kernx AS INTEGER
        DIM ybit AS INTEGER: FOR ybit = 0 TO 6 'top to Bottom
            DIM xbit AS INTEGER: FOR xbit = 0 TO 4 'left to right
                IF font(aski, xbit, ybit) = 1 THEN 'set bits only
                    PSET (x + xbit + kernx, y + ybit + kerny), colour 'PSET data
                END IF
            NEXT
        NEXT

        SELECT CASE (piece$) 'kern adjusment
            CASE "i": kernx = kernx + 2 'ditto
            CASE "j": kernx = kernx + 5 'ditto
            CASE "l": kernx = kernx + 2 'ditto
            CASE "r": kernx = kernx + 5 'ditto
            CASE ".": kernx = kernx + 3 'ditto
            CASE "(": kernx = kernx + 3 'ditto
            CASE ")": kernx = kernx + 3 'ditto
            CASE "'": kernx = kernx + 2 'ditto
            CASE "!": kernx = kernx + 2 'ditto
            CASE ELSE: kernx = kernx + 6 'ditto
        END SELECT

        kerny = 0 'reset
    NEXT
END SUB


SUB PalRegInfo (reg AS INTEGER, red AS INTEGER, grn AS INTEGER, blu AS INTEGER, mode AS INTEGER)
    IF mode THEN 'get individual palette register
        OUT &H3C8, reg 'tell video card which register to change
        OUT &H3C9, red 'send red component
        OUT &H3C9, grn 'send green component
        OUT &H3C9, blu 'send blue component
    ELSE 'set individual palette register
        OUT &H3C7, reg 'tell video card which register
        red = INP(&H3C9) 'get red component
        grn = INP(&H3C9) 'get green component
        blu = INP(&H3C9) 'get blue component
    END IF
END SUB


SUB Pfont (text$, x, y, colour)
    DIM kernx AS INTEGER
    DEF SEG = &HFFA6
    DIM piece AS INTEGER: FOR piece = 1 TO LEN(text$)
        DIM address AS INTEGER: address = (8 * ASC(MID$(text$, piece))) + 14
        DIM hl AS INTEGER: FOR hl = 0 TO 7
            DIM mask AS INTEGER: mask = PEEK(address + hl) * 128
            LINE (x + kernx, y + hl)-(x + 8 + kernx, y + hl), colour, , mask
        NEXT
        kernx = kernx + 8
    NEXT
    'x = 0
    DEF SEG
END SUB


' Plays an sfx$ that is sent to it.
' Sub expects the c$() array (channel info) to be global
SUB playsfx (sfx AS STRING)
    DIM chan AS INTEGER: chan = VAL(MID$(sfx$, 61, 4))
    DIM in AS INTEGER: FOR in = 1 TO 60 STEP 4
        DIM reg$, reg AS INTEGER: reg$ = MID$(c$(chan), in, 4): reg = VAL(reg$)
        DIM dat$, dat AS INTEGER: dat$ = MID$(sfx$, in, 4): dat = VAL(dat$)
        Adlib_WriteRegister reg, dat
    NEXT
END SUB


FUNCTION returnevent
    DIM kee$: kee$ = INKEY$
    IF kee$ <> "" THEN
        IF LEN(kee$) = 1 THEN
            DIM keycode AS INTEGER: keycode = ASC(kee$)
        ELSE
            keycode = -ASC(RIGHT$(kee$, 1))
        END IF
    END IF

    returnevent = keycode
END FUNCTION


SUB ShowHighScores (score() AS Highscores, mode AS INTEGER)
    DIM fc AS INTEGER: fc = 199
    CLS

    FadePal 16, 255, 23, 0


    DIM alien AS INTEGER: alien = INT(RND * 12)

    DIM x AS INTEGER: FOR x = 1 TO 300 STEP 20
        DIM y AS INTEGER: FOR y = 1 TO 186 STEP 14
            PUT (x, y), sprites(elmPerSpr * alien), PSET
        NEXT
    NEXT

    p5x7font 96, 17, "Invader Hall of Fame", 19
    p5x7font 96, 16, "Invader Hall of Fame", 7

    DIM placey AS INTEGER: placey = 35
    DIM shadow AS INTEGER: shadow = 1

    DIM a AS INTEGER: FOR a = 1 TO 15
        p5x7font 20 + 8 - shadow, placey + shadow, score(a).rank, 19
        p5x7font 38 + 8 - shadow, placey + shadow, score(a).dat, 19
        p5x7font 93 + 8 - shadow, placey + shadow, score(a).nam, 19
        p5x7font 240 + 8 - shadow, placey + shadow, score(a).score, 19
        p5x7font 20 + 8, placey, score(a).rank, 191
        p5x7font 38 + 8, placey, score(a).dat, 29
        p5x7font 93 + 8, placey, score(a).nam, 191
        p5x7font 240 + 8, placey, score(a).score, 29
        placey = placey + 10 ' drop y to a new line
    NEXT a

    IF mode THEN EXIT SUB

    DO
        IF TimeIsUp(6, 120) THEN EXIT DO
        event = returnevent
    LOOP UNTIL event
END SUB


SUB soundfx (fx AS INTEGER)
    DIM AS SINGLE f, d

    SELECT CASE fx
        CASE 1 ' step sound
            SOUND 60, .1

        CASE 2 ' gunner hit
            FOR f = 160 TO 60 STEP -10
                d = f / 100!
                SOUND f, d
            NEXT

        CASE 3 ' alien bomb hiting gunshot
            SOUND 1160, .1

        CASE 4 ' gunshot hit alien
            PLAY "O0L64ABCBCA"

        CASE 5
            FOR f = 200 TO 60 STEP -8
                SOUND 32767, 0.18! ' a740g: 10 ms silence without blocking the caller :)
                SOUND f, 0.1!
            NEXT

        CASE 6 ' hit command ship
            PLAY "O1L20GGG"

        CASE 7 ' hit command ship with head up
            PLAY "O2L30CDEF"

        CASE 8
            PLAY "O0L40CDEFGFED"

        CASE ELSE
            BEEP
    END SELECT
END SUB


' Poll this function to check for passage of time. When the amount of
' time in tsecs has passed timeisup() returns TRUE, otherwise the function
' returns false.
' Initialize this routine with tsecs = -1 and n = to the number
' of timers to set up.
FUNCTION TimeIsUp% (n AS LONG, tSecs AS DOUBLE)
    STATIC getClock(0 TO 0) AS INTEGER, oldTSecs(0 TO 0) AS DOUBLE, time1(0 TO 0) AS DOUBLE

    IF tSecs < 0 THEN ' initialize timers
        REDIM getClock(n) AS INTEGER
        REDIM oldTSecs(n) AS DOUBLE
        REDIM time1(n) AS DOUBLE
        EXIT FUNCTION
    END IF

    IF tSecs <> oldTSecs(n) THEN getClock(n) = FALSE

    IF NOT getClock(n) THEN
        time1(n) = TIMER(0.001)
        getClock(n) = TRUE
        oldTSecs(n) = tSecs
    ELSEIF ABS(TIMER(0.001) - time1(n)) >= tSecs THEN
        TimeIsUp = TRUE
        getClock(n) = FALSE
    END IF
END FUNCTION


SUB TitleScreen
    DIM text$: text$ = "QB Invaders"

    DIM alien AS INTEGER: FOR alien = 0 TO 7 STEP 2 'select alien to pull title
        IF INT(RND * 11) = 5 THEN EXIT FOR
    NEXT

    DIM x AS INTEGER: FOR x = 300 TO 95 STEP -1
        DO: LOOP UNTIL INP(&H3DA) AND 8 'wait for VGA retrace
        DIM counter AS INTEGER: counter = (counter + 1) MOD 6
        DIM frame AS INTEGER
        IF counter = 2 THEN frame = (frame + 1) MOD 2
        DIM lx AS INTEGER
        PUT (lx, 90), sprites(elmPerSpr * 20), PSET 'erase last
        p5x7font lx + 20, 90, text$, 0
        event = returnevent
        IF event THEN EXIT FOR
        PUT (x, 90), sprites((alien + frame) * elmPerSpr), PSET
        p5x7font x + 20, 90, text$, 155
        lx = x
        _LIMIT 60
    NEXT

    PUT (95, 90), sprites((alien + frame) * elmPerSpr), PSET

    IF event = 0 THEN FadePal 140, 187, 60, 0
    p5x7font 95 + 20, 90, text$ + " Ver 1.0", 155
    p5x7font 78, 120, "Atari graphics by John Denesha", 155
    p5x7font 69, 130, "Other graphics by Timothy Truman", 187
    p5x7font 79, 140, "Program Author Timothy Truman", 187
    p5x7font 59, 160, "Copyright (c) 1997 Nocturnal Creations", 170
    IF event = 0 THEN FadePal 140, 187, 60, 1

    IF event = 0 THEN FadePal 154, 154, 60, 0
    p5x7font 65, 40, "Use right Ctrl and Alt keys to move", 154
    p5x7font 100, 50, "Use Space bar to fire", 154
    p5x7font 130, 60, "Esc to Quit", 154

    IF event = 0 THEN FadePal 154, 154, 60, 1

    DO
        DO: LOOP UNTIL INP(&H3DA) AND 8 'wait for VGA retrace
        IF TimeIsUp(3, 1) THEN cship.health = TRUE
        DoCommandShip
        event = returnevent
        IF event = ESC THEN
            EndToDos
            event = 0
        END IF
        _LIMIT 60
    LOOP UNTIL event

    cship.health = FALSE
    CLS
END SUB


SUB Adlib_Handler
    CONST ADLIB_BUFFER_FRAMES = 2048
    CONST ADLIB_BUFFER_CHANNELS = 2
    CONST ADLIB_BUFFER_SAMPLES = ADLIB_BUFFER_FRAMES * ADLIB_BUFFER_CHANNELS

    STATIC buffer(0 TO 0) AS INTEGER
    STATIC bufferMEM AS _MEM
    STATIC AS LONG adlibTimer, sndRawHandle

    ' This setup part should only run once (if successful)
    IF bufferMEM.OFFSET = 0 THEN
        adlibTimer = _FREETIMER ' allocate a timer
        IF adlibTimer < 1 THEN EXIT SUB ' this should not happen. But we'll check anyway

        sndRawHandle = _SNDOPENRAW ' allocate a raw sound pipe
        IF sndRawHandle < 1 THEN
            TIMER(adlibTimer) FREE
            adlibTimer = 0
            EXIT SUB ' failed to open sound pipe
        END IF

        REDIM buffer(0 TO ADLIB_BUFFER_SAMPLES - 1) AS INTEGER ' stereo 16-bit
        bufferMEM = _MEM(buffer()) ' we need the _MEM for rapid array wipes

        IF bufferMEM.OFFSET = 0 THEN
            _SNDCLOSE sndRawHandle
            sndRawHandle = 0
            TIMER(adlibTimer) FREE
            adlibTimer = 0
        END IF

        Adlib_Initialize _SNDRATE ' initialize the emulator using the native device sample rate

        ON TIMER(adlibTimer, ADLIB_BUFFER_FRAMES / _SNDRATE) Adlib_Handler ' setup timer handler to tigger at correct intervals
        TIMER(adlibTimer) ON
    END IF

    ' Clear the render buffer
    _MEMFILL bufferMEM, bufferMEM.OFFSET, bufferMEM.SIZE, 0 AS _BYTE

    ' Generate samples to playbacks
    Adlib_GenerateSamples buffer(0), ADLIB_BUFFER_FRAMES

    DIM i AS LONG
    DO WHILE i < ADLIB_BUFFER_SAMPLES
        _SNDRAW buffer(i) / 32768!, buffer(i + 1) / 32768!, sndRawHandle
        i = i + ADLIB_BUFFER_CHANNELS
    LOOP
END SUB
