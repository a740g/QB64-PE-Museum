'QB64 Sprite Library by Terry Ritchie (terry.ritchie@gmail.com)
'
'SPRITETOP.BI - place this file at the very top of your code with an INCLUDE$ metacommand
'
'SPRITE.BI - place at the very bottom of your code with an INCLUDE$ metacommand.
'
'Version A0.1  07/18/2011
'Version A0.11 08/01/2011 (Current version)
'
'COMMANDS FINISHED
'
'SUB      SPRITEPUT          (x!, y!, handle%)                                      Places a sprite on screen at coordinates INT(x!), INT(y!).
'SUB      SPRITESHOW         (handle%)                                              Unhides a sprite from view.
'SUB      SPRITEHIDE         (handle%)                                              Hides a sprite from view.
'SUB      SPRITEZOOM         (handle%, zoom%)                                       Change the size (zoom level) of a sprite.
'SUB      SPRITEROTATE       (handle%, degrees!)                                    Rotates a sprite from 0 to 360 degrees.
'SUB      SPRITEFLIP         (handle%, behavior%)                                   Flips a sprite horizontaly, verticaly, both or resets to no flipping.
'SUB      SPRITESET          (handle%, cell%)                                       Sets a sprite's image to a new image number on sprite sheet.
'SUB      SPRITEANIMATESET   (handle%, startcell%, endcell%)                        Sets a sprite's animation sequence start and end sprite sheet cells.
'SUB      SPRITEANIMATION    (handle%, onoff%, behavior%)                           Turns on or off automatic sprite animation with specified behavior.
'SUB      SPRITENEXT         (handle%)                                              Go to next cell of sprite's animation sequence.
'SUB      SPRITEPREVIOUS     (handle%)                                              Go to previous cell of sprite's animation sequence.
'SUB      SPRITESTAMP        (x%, y%, handle%)                                      Places a sprite on the background as if using a sprite stamp pad.
'SUB      SPRITEFREE         (handle%)                                              Removes a sprite from memory, freeing its resources.
'SUB      SPRITECOLLIDETYPE  (handle%, behavior%)                                   Sets the type of collision detection used for a sprite.
'SUB      SPRITESCORESET     (handle%, value!)                                      Sets the score value of a sprite.
'SUB      SPRITETRAVEL       (handle%, direction!, speed!)                          Moves a sprite in the direction and speed indicated.
'SUB      SPRITEDIRECTIONSET (handle%, direction!)                                  Sets a sprite's automotion direction angle.
'SUB      SPRITESPEEDSET     (handle%, speed!)                                      Sets a sprite's automotion speed in pixels.
'SUB      SPRITEMOTION       (handle%, behavior%)                                   Enables or disables a sprite's automotion feature.
'SUB      SPRITESPINSET      (handle%, spin!)                                       Sets a sprite's automotion spin direction.
'SUB      SPRITEREVERSEY     (handle%)                                              Reverses the y vector automotion value of a sprite.
'SUB      SPRITEREVERSEX     (handle%)                                              Reverses the x vector automotion value of a sprite.
'SUB      SPRITETRAVEL       (handle%, direction!, speed!)                          Moves a sprite in the direction and speed indicated.
'FUNCTION SPRITEROTATION     (handle%)                                              Gets the current rotation angle of a sprite in degrees.
'FUNCTION SPRITENEW          (sheet%, cell%, behavior%)                             Creates a new sprite given the sheet and images that make up the sprite.
'FUNCTION SPRITESHEETLOAD    (filename$, spritewidth%, spriteheight%, transparent&) Loads a sprite sheet into the sprite sheet array and assigns an integer handle value pointing to the sheet.
'FUNCTION SPRITEFILEEXISTS   (filename$)                                            Checks for the existance of the file specified.
'FUNCTION SPRITEX            (handle%)                                              Returns the screen x location of a sprite. (integer) centered
'FUNCTION SPRITEY            (handle%)                                              Returns the screen y location of a sprite. (integer) centered
'FUNCTION SPRITEAX           (handle%)                                              Returns the actual x location of a sprite. (single) centered
'FUNCTION SPRITEAY           (handle%)                                              Returns the actual y location of a sprite. (single) centered
'FUNCTION SPRITEX1           (handle%)                                              Returns the upper left x screen position of the sprite.
'FUNCTION SPRITEY1           (handle%)                                              Returns the upper left y screen position of the sprite.
'FUNCTION SPRITEX2           (handle%)                                              Returns the lower right x screen position of the sprite.
'FUNCTION SPRITEY2           (handle%)                                              Returns the lower right y screen position of the sprite.
'FUNCTION SPRITECOPY         (handle%)                                              Makes a copy of a sprite and returns the newly created sprite's handle.
'FUNCTION SPRITEMOUSE        (handle%)                                              Returns the status of the current sprite and mouse pointer interaction.
'FUNCTION SPRITEMOUSEX       (handle%)                                              Returns the x location of the mouse on the sprite itself.
'FUNCTION SPRITEMOUSEY       (handle%)                                              Returns the y location of the mouse on the sprite itself.
'FUNCTION SPRITEMOUSEAX      (handle%)                                              Returns the x location of the mouse on the screen.
'FUNCTION SPRITEMOUSEAY      (handle%)                                              Returns the y location of the mouse on the screen.
'FUNCTION SPRITECOLLIDE      (handle%, handle2%)                                    Returns the status of collisions with other sprites.
'FUNCTION SPRITEANGLE        (handle%, handle2%)                                    Retrieves the angle in degrees between two sprites.
'FUNCTION SPRITECOLLIDEWITH  (handle%)                                              Returns the sprite number that collided with the specified sprite.
'FUNCTION SPRITESCORE        (handle%)                                              Retrieves the score value from a sprite.
'FUNCTION SPRITESHOWING      (handle%)                                              Returns the status of a sprite being hidden or not.
'FUNCTION SPRITEDIRECTION    (handle%)                                              Returns the direction angle a sprite's automotion has been set to.
'FUNCTION SPRITEZOOMLEVEL    (handle%)                                              Returns a sprite's current zoom level.
'FUNCTION SPRITECURRENTHEIGHT(handle%)                                              Returns the current height of a sprite.
'FUNCTION SPRITECURRENTWIDTH (handle%)                                              Returns the current width of a sprite.

'-------------------------------------------------------------------------
'Future features:
'
'SET DEPTH OF SPRITE
'ZOOM only x or y (scale) http://www.qb64.net/forum/index.php?topic=3956.0
'-------------------------------------------------------------------------

$If SPRITETOP_BI = UNDEFINED Then
    $Let SPRITETOP_BI = TRUE

    '*
    '* GLOBAL constants
    '*
    Const NOVALUE = -32767 '      variables with no value assigned
    '*
    '* SPRITEFLIP constants
    '*
    Const NONE = 0 '              no sprite flipping
    Const HORIZONTAL = 1 '        flip sprite horizontal
    Const VERTICAL = 2 '          flip sprite vertical
    Const BOTH = 3 '              flip both horiz/vertical
    '*
    '* SPRITENEW constants
    '*
    Const SAVE = -1 '             save background image
    Const DONTSAVE = 0 '          don't save background image
    '*
    '* SPRITESHEETLOAD constants
    '*
    Const NOTRANSPARENCY = -1 '  sheet has no transparency
    Const AUTOTRANSPARENCY = -2 'automatically discover transparency
    '*
    '* SPRITEANIMATION constants
    '*
    Const ANIMATE = -1
    Const NOANIMATE = 0
    Const FORWARDLOOP = 0
    Const BACKWARDLOOP = 1
    Const BACKFORTHLOOP = 2
    '*
    '* SPRITEMOUSE constants
    '*
    Const NOMOUSE = 0 '          no current mouse interaction
    Const MOUSELEFT = 1 '        left button clicked on sprite
    Const MOUSERIGHT = 2 '       right button clicked on sprite
    Const MOUSEHOVER = 3 '       mouse hovering over sprite
    '*
    '* SPRITECOLLIDETYPE constants
    '*
    Const NODETECT = 0 '         do not detect collisions
    Const BOXDETECT = 1 '        use rectangular detection
    Const PIXELDETECT = 2 '      use pixel accurate detection
    '*
    '* SPRITECOLLIDE constants
    '*
    Const ALLSPRITES = -1 '      check all sprites for collision
    '*
    '* SPRITEMOTION constants
    '*
    Const MOVE = -1 '            enable automotion
    Const DONTMOVE = 0 '         disable automotion

    Type SPRITE
        inuse As Integer '        sprite is in use             (true / false)
        sheet As Integer '        what sheet is sprite on
        onscreen As Integer '     sprite showing on screen     (true / false)
        visible As Integer '      sprite hidden/showing        (true / false)
        currentwidth As Integer ' current width of sprite      (width after zoom/rotate)
        currentheight As Integer 'current height of sprite     (height after zoom/rotate)
        restore As Integer '      sprite restores background   (true / false)
        image As Double '         current image on screen      (use for pixel accurate detection)
        background As Double '    sprite background image
        currentcell As Integer '  current animation cell       (1 to cells)
        flip As Integer '         flip vertical/horizonatal    (0 = none, 1 = horizontal, 2 = vertical, 3 = both)
        animation As Integer '    automatic sprite animation   (true / false)
        animtype As Integer '     automatic animation type     (0 = acsending loop, 1 = descending loop, 2 = forward/backward loop
        animdir As Integer '      forward/backward loop dir    (1 = forward, -1 = backward)
        animstart As Integer '    animation sequence start     (=> 1 to <= animend)
        animend As Integer '      animation sequence end       (=> animstart to <= cells)
        transparent As Double '   transparent color            (-1 = none, 0 and higher = color)
        zoom As Integer '         zoom level in percentage     (1 to x%)
        rotation As Single '      rotation in degrees          (0 to 359.9999 degrees)
        motion As Integer '       sprite auto motion           (true / false)
        speed As Single '         sprite auto motion speed     (any numeric value)
        direction As Single '     sprite auto motion angle     (0 to 359.9999 degrees)
        xdir As Single '          x vector for automotion
        ydir As Single '          y vector for automotion
        spindir As Single '       spin direction for automotion
        actualx As Single '       actual x location
        actualy As Single '       actual y location
        currentx As Integer '     current x location on screen (INT(actualx))
        currenty As Integer '     current y location on screen (INT(actualy))
        backx As Integer '        x location of background image
        backy As Integer '        y location of background image
        screenx1 As Integer '     upper left x of sprite
        screeny1 As Integer '     upper left y of sprite
        screenx2 As Integer '     lower right x of sprite
        screeny2 As Integer '     lower right y of sprite
        layer As Integer '        layer the sprite resides on (1 to x, lower sprite layers drawn first)
        detect As Integer '       collision detection          (true / false)
        detecttype As Integer '   the type of detection use    (0 = do not detect collisions, 1 = box, 2 = pixel accurate)
        collx1 As Integer '       upper left x collision area  (pixel accurate = x location of hit, box = upper left x)
        colly1 As Integer '       upper left y collision area  (pixel accurate = y location of hit, box = upper left x)
        collx2 As Integer '       lower right x collision area
        colly2 As Integer '       lower right y collision area
        collsprite As Integer '   sprite number colliding with (0 = none, 1 to x = sprite colliding with)
        pointer As Integer '      mouse pointer interaction    (0 none, 1 left button, 2 right button, 3 hovering)
        mouseax As Integer '      actual x location of pointer (x = 0 to screen width)
        mouseay As Integer '      actual y location of pointer (y = 0 to screen height)
        mousecx As Integer '      x location pointer on sprite (x = 0 to sprite width)
        mousecy As Integer '      y location pointer on sprite (y = 0 to sprite height)
        score As Single '         sprite score value for games
    End Type

    Type SHEET
        inuse As Integer '        sheet is in use              (true / false)
        sheetimage As Double '    image handle of sheet
        sheetwidth As Integer '   width of sheet
        sheetheight As Integer '  height of sheet
        spritewidth As Integer '  width of each sprite
        spriteheight As Integer ' height of each sprite
        transparent As Double '   transparent color on sheet   (negative = none, 0 and greater = color)
        columns As Integer '      number of sprite columns
    End Type

    ReDim sprite(1) As SPRITE
    ReDim sheet(1) As SHEET

$End If

