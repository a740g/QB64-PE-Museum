'QB64 Sprite Library by Terry Ritchie (terry.ritchie@gmail.com)
'
'SPRITETOP.BI - place this file at the very top of your code with an $INCLUDE metacommand
'
'SPRITE.BI - place at the very bottom of your code with an $INCLUDE metacommand.
'
'Version A0.1  07/18/2011
'Version A0.11 08/01/2011
'  - minor bug fixes
'Version 0.2   10/27/2012 (Current version)
'  - updated error handling routines
'      - all errors will now be forced to a true text screen (screen 0)
'  - added SPRITEERROR function to handle errors reported by subs/functions
'  - removed SPRITEFILEEXISTS function and replaced with QB64 _FILEEXISTS command
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

'*
'* GLOBAL constants
'*
CONST NOVALUE = -32767 '      variables with no value assigned
'*
'* SPRITEFLIP constants
'*
CONST NONE = 0 '              no sprite flipping
CONST HORIZONTAL = 1 '        flip sprite horizontal
CONST VERTICAL = 2 '          flip sprite vertical
CONST BOTH = 3 '              flip both horiz/vertical
'*
'* SPRITENEW constants
'*
CONST SAVE = -1 '             save background image
CONST DONTSAVE = 0 '          don't save background image
'*
'* SPRITESHEETLOAD constants
'*
CONST NOTRANSPARENCY = -1 '  sheet has no transparency
CONST AUTOTRANSPARENCY = -2 'automatically discover transparency
'*
'* SPRITEANIMATION constants
'*
CONST ANIMATE = -1
CONST NOANIMATE = 0
CONST FORWARDLOOP = 0
CONST BACKWARDLOOP = 1
CONST BACKFORTHLOOP = 2
'*
'* SPRITEMOUSE constants
'*
CONST NOMOUSE = 0 '          no current mouse interaction
CONST MOUSELEFT = 1 '        left button clicked on sprite
CONST MOUSERIGHT = 2 '       right button clicked on sprite
CONST MOUSEHOVER = 3 '       mouse hovering over sprite
'*
'* SPRITECOLLIDETYPE constants
'*
CONST NODETECT = 0 '         do not detect collisions
CONST BOXDETECT = 1 '        use rectangular detection
CONST PIXELDETECT = 2 '      use pixel accurate detection
'*
'* SPRITECOLLIDE constants
'*
CONST ALLSPRITES = -1 '      check all sprites for collision
'*
'* SPRITEMOTION constants
'*
CONST MOVE = -1 '            enable automotion 
CONST DONTMOVE = 0 '         disable automotion 

TYPE SPRITE
    inuse AS INTEGER '        sprite is in use             (true / false)
    sheet AS INTEGER '        what sheet is sprite on
    onscreen AS INTEGER '     sprite showing on screen     (true / false)
    visible AS INTEGER '      sprite hidden/showing        (true / false)
    currentwidth AS INTEGER ' current width of sprite      (width after zoom/rotate)
    currentheight AS INTEGER 'current height of sprite     (height after zoom/rotate)
    restore AS INTEGER '      sprite restores background   (true / false)
    image AS DOUBLE '         current image on screen      (use for pixel accurate detection)
    background AS DOUBLE '    sprite background image
    currentcell AS INTEGER '  current animation cell       (1 to cells)
    flip AS INTEGER '         flip vertical/horizonatal    (0 = none, 1 = horizontal, 2 = vertical, 3 = both)
    animation AS INTEGER '    automatic sprite animation   (true / false)
    animtype AS INTEGER '     automatic animation type     (0 = acsending loop, 1 = descending loop, 2 = forward/backward loop
    animdir AS INTEGER '      forward/backward loop dir    (1 = forward, -1 = backward)
    animstart AS INTEGER '    animation sequence start     (=> 1 to <= animend)
    animend AS INTEGER '      animation sequence end       (=> animstart to <= cells)
    transparent AS DOUBLE '   transparent color            (-1 = none, 0 and higher = color)
    zoom AS INTEGER '         zoom level in percentage     (1 to x%)
    rotation AS SINGLE '      rotation in degrees          (0 to 359.9999 degrees)
    motion AS INTEGER '       sprite auto motion           (true / false)
    speed AS SINGLE '         sprite auto motion speed     (any numeric value)
    direction AS SINGLE '     sprite auto motion angle     (0 to 359.9999 degrees)
    xdir as single '          x vector for automotion 
    ydir as single '          y vector for automotion
    spindir as single '       spin direction for automotion
    actualx AS SINGLE '       actual x location
    actualy AS SINGLE '       actual y location
    currentx AS INTEGER '     current x location on screen (INT(actualx))
    currenty AS INTEGER '     current y location on screen (INT(actualy))
    backx AS INTEGER '        x location of background image
    backy AS INTEGER '        y location of background image
    screenx1 AS INTEGER '     upper left x of sprite
    screeny1 AS INTEGER '     upper left y of sprite
    screenx2 AS INTEGER '     lower right x of sprite
    screeny2 AS INTEGER '     lower right y of sprite
    layer AS INTEGER '        layer the sprite resides on (1 to x, lower sprite layers drawn first)
    detect AS INTEGER '       collision detection          (true / false)
    detecttype AS INTEGER '   the type of detection use    (0 = do not detect collisions, 1 = box, 2 = pixel accurate)
    collx1 AS INTEGER '       upper left x collision area  (pixel accurate = x location of hit, box = upper left x)
    colly1 AS INTEGER '       upper left y collision area  (pixel accurate = y location of hit, box = upper left x)
    collx2 AS INTEGER '       lower right x collision area
    colly2 AS INTEGER '       lower right y collision area
    collsprite AS INTEGER '   sprite number colliding with (0 = none, 1 to x = sprite colliding with)
    pointer AS INTEGER '      mouse pointer interaction    (0 none, 1 left button, 2 right button, 3 hovering)
    mouseax AS INTEGER '      actual x location of pointer (x = 0 to screen width)
    mouseay AS INTEGER '      actual y location of pointer (y = 0 to screen height)
    mousecx AS INTEGER '      x location pointer on sprite (x = 0 to sprite width)
    mousecy AS INTEGER '      y location pointer on sprite (y = 0 to sprite height)
    score as single '         sprite score value for games 
END TYPE

TYPE SHEET
    inuse AS INTEGER '        sheet is in use              (true / false)
    sheetimage AS DOUBLE '    image handle of sheet
    sheetwidth AS INTEGER '   width of sheet
    sheetheight AS INTEGER '  height of sheet
    spritewidth AS INTEGER '  width of each sprite
    spriteheight AS INTEGER ' height of each sprite
    transparent AS DOUBLE '   transparent color on sheet   (negative = none, 0 and greater = color)
    columns AS INTEGER '      number of sprite columns
END TYPE

REDIM sprite(1) AS SPRITE
REDIM sheet(1) AS SHEET
