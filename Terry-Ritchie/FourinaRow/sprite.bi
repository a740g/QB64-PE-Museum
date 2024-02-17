'QB64 Sprite Library by Terry Ritchie (terry.ritchie@gmail.com)
'
'SPRITE.BI - place this file at the very bottom of your code with an INCLUDE$ metacommand.
'
'SPRITETOP.BI - place file at the very top of your code with an INCLUDE$ metacommand
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

'$INCLUDE:'spritetop.bi'

'##################################################################################################################################

Sub SPRITESPINSET (handle%, spin!)

    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets a sprite's automotion spin direction.                                 |                     - NOTES -                     |
    '|                                                                            | - Specifyng a sprite that does not exist will     |
    '| Usage : SPRITESPINSET mysprite%, 11.25                                     |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to set automotion spin on.                    |                                                   |
    '|         spin!   - the amount of spin to add, positive or negative value.   |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESPINSET: The sprite specified does not exist." '              no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).spindir = spin! '                                              set the sprite's automotion spin direction

End Sub

'##################################################################################################################################

Function SPRITEZOOMLEVEL (handle%)

    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns a sprite's current zoom level.                                     |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : zoom% = SPRITEZOOMLEVEL(mysprite%)                                 |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the zoom level from.              |                                                   |
    '|                                                                            |                                                   |
    '| Output: an integer value representing the sprite's zoom level.             |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEZOOMLEVEL: The sprite specified does not exist." '            no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEZOOMLEVEL = sprite(handle%).zoom '                                       return the sprite's current zoom value

End Function

'##################################################################################################################################

Sub SPRITEREVERSEY (handle%)

    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Reverses the y vector automotion value of a sprite.                        |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEREVERSEY mysprite%                                           |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to reverse the y vector direction of.         |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEREVERSEY: The sprite specified does not exist." '             no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).ydir = -sprite(handle%).ydir '                                 reverse sprite's y vector automotion value

End Sub

'##################################################################################################################################

Sub SPRITEREVERSEX (handle%)

    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Reverses the x vector automotion value of a sprite.                        |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEREVERSEX mysprite%                                           |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to reverse the x vector direction of.         |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEREVERSEX: The sprite specified does not exist." '             no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).xdir = -sprite(handle%).xdir '                                 reverse sprite's x vector automotion value

End Sub

'##################################################################################################################################

Function SPRITECURRENTHEIGHT (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the current height of a sprite.                                    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : sheight% = SPRITECURRENTHEIGHT(mysprite%)                          |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the current height information.   | - This is an especially useful command for        |
    '|                                                                            |   getting the height of sprites that have been    |
    '| Output: an integer value representing the height of the sprite.            |   rotated.                                        |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITECURRENTHEIGHT: The sprite specified does not exist." '        no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITECURRENTHEIGHT = sprite(handle%).currentheight '                          return the current height of the sprite

End Function

'##################################################################################################################################

Function SPRITECURRENTWIDTH (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the current width of a sprite.                                     |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that doe not exist will     |
    '| Usage : swidth% = SPRITECURRENTWIDTH(mysprite%)                            |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the current width information.    | - This is an especially useful command for        |
    '|                                                                            |   getting the width of sprites that have been     |
    '| Output: an integer value representing the width of the sprite.             |   rotated.                                        |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITECURRENTWIDTH: The sprite specified does not exist." '         no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITECURRENTWIDTH = sprite(handle%).currentwidth '                            return the current width of the sprite

End Function

'##################################################################################################################################

Sub SPRITETRAVEL (handle%, direction!, speed!)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Moves a sprite in the direction and speed indicated.                       |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exists will   |
    '| Usage : SPRITETRAVEL mysprite%, 90, 10                                     |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%    - the sprite to move.                                   | - The direction and speed given will not set the  |
    '|         direction! - the direction to move in (0 - 359.99..)               |   the sprite's automotion speed and direction     |
    '|         speed!     - the speed to move at.                                 |   angle or vectors.                               |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITETRAVEL: The sprite specified does not exist." '               no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).actualx = sprite(handle%).actualx + Sin(direction! * 3.1415926 / 180) * speed! ' calculate x vector and update position
    sprite(handle%).actualy = sprite(handle%).actualy + -Cos(direction! * 3.1415926 / 180) * speed! 'calculate y vector and update position

End Sub

'##################################################################################################################################

Function SPRITEDIRECTION (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the direction angle a sprite's automotion has been set to.         |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : angle! = SPRITEDIRECTION(mysprite%)                                |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the direction angle from.         | - The sprite direction angle is independant of    |
    '|                                                                            |   the sprite's rotation angle.                    |
    '| Output: a single numeric value representing direction angle (0 - 359.99..) |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEDIRECTION: The sprite specified does not exist." '            no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEDIRECTION = sprite(handle%).direction '                                  return the automotion direction angle

End Function

'##################################################################################################################################

Sub SPRITEDIRECTIONSET (handle%, direction!)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets a sprite's automotion direction angle.                                |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEDIRECTIONSET mysprite%, 270                                  |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%    - the sprite to set the direction.                      | - The direction value is used by the automotion   |
    '|         direction! - the angle of direction to set (0 - 359.99..)          |   portion of the sprite library. This value will  |
    '|                                                                            |   not be used unless automotion has been enabled  |
    '| Output: none                                                               |   for the sprite (SPRITEMOTION).                  |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEDIRECTIONSET: The sprite specified does not exist." '         no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).direction = direction! '                                       set the automotion direction angle
    sprite(handle%).xdir = Sin(direction! * 3.1415926 / 180) * sprite(handle%).speed ' calculate the x direction vector
    sprite(handle%).ydir = -Cos(direction! * 3.1415926 / 180) * sprite(handle%).speed 'calculate the y direction vector

End Sub

'##################################################################################################################################

Sub SPRITESPEEDSET (handle%, speed!)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets a sprite's automotion speed in pixels.                                |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITESPEEDSET mysprite%, 5                                        |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to set the speed.                             | - The speed value is used by the automotion       |
    '|         speed!  - the number of pixels or partial pixels to move.          |   portion of the sprite library. This value will  |
    '|                                                                            |   not be used unless automotion has been enabled  |
    '| Output: none                                                               |   for the sprite (SPRITEMOTION).                  |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESPEEDSET: The sprite specified does not exist." '             no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).speed = speed! '                                               set the sprite's speed value

End Sub

'##################################################################################################################################

Sub SPRITEMOTION (handle%, behavior%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Enables or disables a sprite's automotion feature.                         |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEMOTION mysprite%, -1                                         |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%   - the sprite to turn on or off automotion.               | - This subroutine will enable the automotion      |
    '|         behavior% - enable or disable the sprite's automotion.             |   portion of the sprite library which uses the    |
    '|                 0 = disable automotion (constant DONTMOVE)                 |   sprite's direction (SPRITEDIRECTIONSET) and     |
    '|                -1 = enable automotion  (constant MOVE)                     |   speed (SPRITESPEEDSET) values.                  |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEMOTION: The sprite specified does not exist." '               no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).motion = behavior% '                                           set the automotion behavior

End Sub

'##################################################################################################################################

Function SPRITESCORE (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Retrieves the score value from a sprite.                                   |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : score% = SPRITESCORE(mysprite%)                                    |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite the score is to be retrieved from.            |                                                   |
    '|                                                                            |                                                   |
    '| Output: An single value representing the score value saved.                |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESCORE: The sprite specified does not exist." '                no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITESCORE = sprite(handle%).score '                                          return the score value of sprite

End Function

'##################################################################################################################################

Sub SPRITESCORESET (handle%, value!)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets the score value of a sprite.                                          |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITESCORESET mysprite%, 100                                      |   result in the subroutine reporting an error     |
    '|                                                                            |   and halting program execution.                  |
    '| Input : handle% - the sprite number of the score to set.                   | - This subroutine can also be used as a storage   |
    '|         value!  - the single numeric value to store as the score.          |   container for any numeric data that needs to be |
    '|                                                                            |   associated with the sprite or even as a flag    |
    '| Output: none                                                               |   indicator.                                      |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESCORESET: The sprite specified does not exist." '             no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).score = value! '                                                set the sprite's score value

End Sub

'##################################################################################################################################

Function SPRITESHOWING (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the status of a sprite being hidden or not.                        |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : visible% = SPRITESHOWING(mysprite%)                                |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite number of the visible status to retrieve.     |                                                   |
    '|                                                                            |                                                   |
    '| Output: an integer value of -1 (true) if showing or 0 (false) if not.      |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESHOWING: The sprite specified does not exist." '              no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITESHOWING = sprite(handle%).visible '                                      return hidden status of sprite

End Function

'##################################################################################################################################

Function SPRITEANGLE (handle%, handle2%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Retrieves the angle in degrees between two sprites.                        |                     - NOTES -                     |
    '|                                                                            | - Specifying sprites that do not exist will       |
    '| Usage : missiledir! = SPRITEANGLE(mysprite%, anothersprite%)               |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%  - the sprite where the angle is originating from.         |                                                   |
    '|         handle2% - the sprite the first sprite is pointing to.             |                                                   |
    '|                                                                            |                                                   |
    '| Output: a single value with the range of 0 to 359.99....                   |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Credits: Most of this code was realized by using Galleon's getangle# function as found in the following forum topic:           |
    '|          http://www.qb64.net/forum/index.php?topic=3934.0                                                                      |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEANGLE: The first sprite specified does not exist." '          no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEANGLE: The second sprite specified does not exist." '         no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If sprite(handle2%).currenty = sprite(handle%).currenty Then '                 are both sprites at same y location?
        If sprite(handle%).currentx = sprite(handle2%).currentx Then Exit Function 'yes, if both at same x the leave, at same location
        If sprite(handle2%).currentx > sprite(handle%).currentx Then SPRITEANGLE = 90 Else SPRITEANGLE = 270 'sprite is either right or left
        Exit Function
    End If
    If sprite(handle2%).currentx = sprite(handle%).currentx Then '                 are both sprites at same x location?
        If sprite(handle2%).currenty > sprite(handle%).currenty Then SPRITEANGLE = 180 'yes, if its greater, 180, less, 0
        Exit Function
    End If
    If sprite(handle2%).currenty < sprite(handle%).currenty Then '                 is sprite2 y value less than sprite1?
        If sprite(handle2%).currentx > sprite(handle%).currentx Then '             yes, is sprite2 x value greater than sprite1?
            SPRITEANGLE = Atn((sprite(handle2%).currentx - sprite(handle%).currentx) / (sprite(handle2%).currenty - sprite(handle%).currenty)) * -57.2957795131
        Else
            SPRITEANGLE = Atn((sprite(handle2%).currentx - sprite(handle%).currentx) / (sprite(handle2%).currenty - sprite(handle%).currenty)) * -57.2957795131 + 360
        End If
    Else
        SPRITEANGLE = Atn((sprite(handle2%).currentx - sprite(handle%).currentx) / (sprite(handle2%).currenty - sprite(handle%).currenty)) * -57.2957795131 + 180
    End If

End Function

'##################################################################################################################################

Function SPRITECOLLIDEWITH (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the sprite number that collided with the specified sprite.         |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : hit% = SPRITECOLLIDEWITH(mysprite%)                                |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the collision information from.   | - This function should be used after the function |
    '|                                                                            |   SPRITECOLLIDE() was called and ALLSPRITES       |
    '| Output: handle number of the sprite that collided with specified sprite.   |   specified to determine which sprite collided.   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITECOLLIDEWITH: The sprite specified does not exist." '          no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITECOLLIDEWITH = sprite(handle%).collsprite '                               return the handle number of the colliding sprite

End Function

'##################################################################################################################################

Function SPRITECOLLIDE (handle%, handle2%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the status of collisions with other sprites.                       |                     - NOTES -                     |
    '|                                                                            | - Specifying sprites that do not exist will       |
    '| Usage : hit% = SPRITECOLLIDE(mysprite%, anothersprite%)                    |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%  - the sprite to test for collisions.                      | - The constant ALLSPRITES was created to be used  |
    '|         handle2% - the sprite(s) to test for a collision with.             |   with this function.                             |
    '|               -1 = test all sprites for collision (constant ALLSPRITES).   | - THERE IS A KNOWN PROBLEM currently with this    |
    '|              > 0 = the specific sprite to check for a collision with.      |   function. See "Known Issues" below.             |
    '|                                                                            |                                                   |
    '| Output: 0 if no collision, the sprite handle number colliding with.        |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Known Issues: If two identical sized sprites come at each other on the same horizontal or vertical position a collision will   |
    '|               not be detected. The work-around for now is to make sure that exact size sprites be one pixel off from each      |
    '|               other. This problem will be resolved soon.                                                                       |
    '+--------------------------------------------------------------------------------------------------------------------------------+
    '| Credits: Portions of this code were realized by examining UnseenMachine's (John Onyon) GDK code. His Game Development Kit(GDK) |
    '|          can be downloaded from here: http://dl.dropbox.com/u/8822351/UnseenGDK.bm and a tutorial for the GDK can be           |
    '|          downloaded from here: http://dl.dropbox.com/u/8822351/UnseenGDK_Tutorial.doc                                          |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    Dim count% '                                                                   counter used to cycle through sprite array
    Dim countfrom% '                                                               where to start count cycle
    Dim countto% '                                                                 where to end count cycle
    Dim x% '                                                                       pixel accurate collision box pixel x location
    Dim y% '                                                                       pixel accurate collision box pixel y location
    Dim w% '                                                                       pixel accurate collision box width
    Dim h% '                                                                       pixel accurate collision box height
    Dim p1~& '                                                                     pixel accurate image 1 pixel color
    Dim p2~& '                                                                     pixel accurate image 2 pixel color
    Dim a1&, a2&

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITECOLLIDE: The first sprite specified does not exist." '        no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITECOLLIDE = 0 '                                                            assume no collision and send this assumption back
    If sprite(handle%).detecttype = 0 Then Exit Function '                         the sprite does not have collision detection on
    sprite(handle%).detect = 0 '                                                   assume no collision
    If handle2% = -1 Then '                                                        should all sprites be checked for collisions?
        countfrom% = 1 '                                                           yes, start at beginning of sprite array
        countto% = UBound(sprite) '                                                end at the last element in sprite array
    Else '                                                                         checking for a specific sprite collision
        If Not sprite(handle2%).inuse Then '                                       is this sprite handle in use?
            Print "SPRITECOLLIDE: The second sprite specified does not exist." '   no, report error to the programmer
            _Display '                                                             make sure programmer sees error
            Sleep '                                                                wait for a key press
            System '                                                               abort program execution
        End If
        countfrom% = handle2% '                                                    start at element of specific sprite in array
        countto% = handle2% '                                                      end at element of specific sprite in array
    End If
    For count% = countfrom% To countto% '                                          cycle through all known sprites or single sprite
        If count% <> handle% Then '                                                can't detect a collision with ourself!
            If sprite(count%).visible Then '                                       don't check hidden sprites
                If sprite(count%).detecttype <> 0 Then '                           ignore sprites with no detection enabled
                    If sprite(count%).layer = sprite(handle%).layer Then '         sprites must be on same layer to collide
                        If sprite(handle%).screenx1 <= sprite(count%).screenx1 + sprite(count%).currentwidth Then '               is upper left x of sprite within current sprite?
                            If sprite(handle%).screenx1 + sprite(handle%).currentwidth >= sprite(count%).screenx1 Then '          is upper left x of current sprite within sprite?
                                If sprite(handle%).screeny1 <= sprite(count%).screeny1 + sprite(count%).currentheight Then '      is upper left y of sprite within current sprite?
                                    If sprite(handle%).screeny1 + sprite(handle%).currentheight >= sprite(count%).screeny1 Then ' is upper left y of current sprite within sprite?
                                        sprite(handle%).detect = -1 '              all true, sprite has collision
                                        sprite(count%).detect = -1 '               current sprite also has collision
                                        sprite(handle%).collsprite = count% '      sprite colliding with current sprite
                                        sprite(count%).collsprite = handle% '      current sprite colliding with sprite
                                        Exit For '                                 no need to check the rest of sprites
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If
            End If
        End If
    Next count%
    If sprite(handle%).detect Then '                                               a box collision was detected
        SPRITECOLLIDE = sprite(handle%).collsprite '                               return the sprite number the collision happened with
        If sprite(handle%).detecttype = 2 And sprite(sprite(handle%).collsprite).detecttype = 2 Then ' we need to go to pixel accurate detection
            If sprite(handle%).screenx1 < sprite(sprite(handle%).collsprite).screenx1 Then ' get collision area and place coordinates in each sprite
                sprite(sprite(handle%).collsprite).collx1 = 0
                sprite(handle%).collx1 = sprite(sprite(handle%).collsprite).screenx1 - sprite(handle%).screenx1 - 1
                If sprite(sprite(handle%).collsprite).currentwidth + sprite(handle%).collx1 < sprite(handle%).currentwidth Then
                    sprite(sprite(handle%).collsprite).collx2 = sprite(sprite(handle%).collsprite).currentwidth - 1
                    sprite(handle%).collx2 = sprite(handle%).collx1 + sprite(sprite(handle%).collsprite).currentwidth - 1
                Else
                    sprite(handle%).collx2 = sprite(handle%).currentwidth - 1
                    sprite(sprite(handle%).collsprite).collx2 = (sprite(handle%).screenx1 + sprite(handle%).currentwidth) - sprite(sprite(handle%).collsprite).screenx1 - 1
                End If
            ElseIf sprite(handle%).screenx1 > sprite(sprite(handle%).collsprite).screenx1 Then
                sprite(handle%).collx1 = 0
                sprite(sprite(handle%).collsprite).collx1 = sprite(handle%).screenx1 - sprite(sprite(handle%).collsprite).screenx1 - 1
                If sprite(sprite(handle%).collsprite).currentwidth - sprite(sprite(handle%).collsprite).collx1 < sprite(handle%).currentwidth Then
                    sprite(handle%).collx2 = (sprite(handle%).collx1 + sprite(sprite(handle%).collsprite).currentwidth) - sprite(sprite(handle%).collsprite).collx1 - 1
                    sprite(sprite(handle%).collsprite).collx2 = sprite(sprite(handle%).collsprite).currentwidth - 1
                Else
                    sprite(handle%).collx2 = sprite(handle%).currentwidth - 1
                    sprite(sprite(handle%).collsprite).collx2 = sprite(sprite(handle%).collsprite).collx1 + sprite(handle%).currentwidth - 1
                End If
            End If
            If sprite(handle%).screeny1 < sprite(sprite(handle%).collsprite).screeny1 Then
                sprite(sprite(handle%).collsprite).colly1 = 0
                sprite(handle%).colly1 = sprite(sprite(handle%).collsprite).screeny1 - sprite(handle%).screeny1 - 1
                If sprite(sprite(handle%).collsprite).currentheight + sprite(handle%).colly1 < sprite(handle%).currentheight Then
                    sprite(sprite(handle%).collsprite).colly2 = sprite(sprite(handle%).collsprite).currentheight - 1
                    sprite(handle%).colly2 = sprite(handle%).colly1 + sprite(sprite(handle%).collsprite).currentheight - 1
                Else
                    sprite(handle%).colly2 = sprite(handle%).currentheight - 1
                    sprite(sprite(handle%).collsprite).colly2 = (sprite(handle%).screeny1 + sprite(handle%).currentheight) - sprite(sprite(handle%).collsprite).screeny1 - 1
                End If
            ElseIf sprite(handle%).screeny1 > sprite(sprite(handle%).collsprite).screeny1 Then
                sprite(handle%).colly1 = 0
                sprite(sprite(handle%).collsprite).colly1 = sprite(handle%).screeny1 - sprite(sprite(handle%).collsprite).screeny1 - 1
                If sprite(sprite(handle%).collsprite).currentheight - sprite(sprite(handle%).collsprite).colly1 < sprite(handle%).currentheight Then
                    sprite(handle%).colly2 = (sprite(handle%).colly1 + sprite(sprite(handle%).collsprite).currentheight) - sprite(sprite(handle%).collsprite).colly1 - 1
                    sprite(sprite(handle%).collsprite).colly2 = sprite(sprite(handle%).collsprite).currentheight - 1
                Else
                    sprite(handle%).colly2 = sprite(handle%).currentheight - 1
                    sprite(sprite(handle%).collsprite).colly2 = sprite(sprite(handle%).collsprite).colly1 + sprite(handle%).currentheight - 1
                End If
            End If '                                                               collision coordinates now in both sprites
            x% = 0 '                                                               start at upper left x of each collision box
            y% = 0 '                                                               start at upper left y of each collision box
            w% = sprite(handle%).collx2 - sprite(handle%).collx1 '- 1 '            get the width of the collision boxes
            h% = sprite(handle%).colly2 - sprite(handle%).colly1 '- 1 '            get the height of the collision boxes
            Do '                                                                   start looping through collision box pixels
                _Source sprite(handle%).image '                                    set the first sprite as the image source
                p1~& = Point(sprite(handle%).collx1 + x%, sprite(handle%).colly1 + y%) ' get the current pixel's color
                a1& = _Alpha32(p1~&)
                _Source sprite(sprite(handle%).collsprite).image '                 set the second sprite as the image source
                p2~& = Point(sprite(sprite(handle%).collsprite).collx1 + x%, sprite(sprite(handle%).collsprite).colly1 + y%) ' get the current pixel's color
                a2& = _Alpha32(p2~&)
                If (a1& <> 0) And (a2& <> 0) Then Exit Do '                        if both are not transparent then we have a collision
                x% = x% + 1 '                                                      move right one pixel
                If x% > w% Then '                                                  have we reached the edge of the collision box?
                    x% = 0 '                                                       yes, move back to the left of the collision box
                    y% = y% + 1 '                                                  move down one pixel
                End If
            Loop Until y% > h% '                                                   stop when gone past the bottom of collision box
            If y% > h% Then SPRITECOLLIDE = 0 '                                    no collision if we checked entire collision box
        End If
        _Source 0
    End If

End Function

'##################################################################################################################################

Sub SPRITECOLLIDETYPE (handle%, behavior%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets the type of collision detection used for a sprite.                    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITECOLLIDETYPE mysprite%, 2                                     |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%   - the number of the sprite to set the collision type.    | - The constants NODETECT, BOXDETECT and           |
    '|         behavior% - the type of collision detection desired for sprite:    |   PIXELDETECT have been created to be used with   |
    '|                 0 - no collision detection        (constant NODETECT)      |   this subroutine.                                |
    '|                 1 - rectangular box detection     (constant BOXDETECT)     |                                                   |
    '|                 2 - pixel accurate detection      (constant PIXELDETECT)   |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().detecttype to desired detection method.                   |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITECOLLIDESET: The sprite specified does not exist." '           no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If behavior% = 2 Then sprite(handle%).image = _NewImage(1, 1, 32) '            temp image for first time deletion in SPRITEPUT()
    sprite(handle%).detecttype = behavior% '                                       set the collision detection method for this sprite

End Sub

'##################################################################################################################################

Sub SPRITEPUT (x!, y!, handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Places a sprite on screen at coordinates INT(x!), INT(y!).                 |                     - NOTES -                     |
    '|                                                                            | - The x! and y! values can be sent in as integers |
    '| Usage : SPRITEPUT 10, 10, mysprite%                                        |   or single precision to allow the programmer to  |
    '|                                                                            |   use fine or pixel by pixel movements.           |
    '| Input : x!      - row to display sprite at.                                |                                                   |
    '|         y!      - column to display sprite at.                             |                                                   |
    '|         handle% - the sprite to display on the screen.                     |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().onscreen to -1 if not previously on screen.               |                                                   |
    '|         sprite().actualx to equal x! variable passed in.                   |                                                   |
    '|         sprite().actualy to equal y! variable passed in.                   |                                                   |
    '|         sprite().currentx to equal INT(x!) variable passed in.             |                                                   |
    '|         sprite().currenty to equal INT(y!) variable passed in.             |                                                   |
    '|         sprite().currentwidth to equal the screen width of sprite.         |                                                   |
    '|         sprite().currentheight to equal the screen height of sprite.       |                                                   |
    '|         sprite().background to hold the image of the background if needed. |                                                   |
    '|         sprite().screenx1 to upper left x of sprite on screen. *           |                                                   |
    '|         sprite().screeny1 to upper left y of sprite on screen. *           |                                                   |
    '|         sprite().screenx2 to lower right x of sprite on screen.            |                                                   |
    '|         sprite().screeny2 to lower right y of sprite on screen.            |                                                   |
    '|         sprite().backx to upper left x of sprite on screen. *              |                                                   |
    '|         sprite().backy to upper left y of sprite on screen. *              |                                                   |
    '|         * = redundant?                                                     |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Credits: Portions of this subroutine have code based off of Galleon's RotoZoom subroutine found in the QB64 documentation at   |
    '|          http://qb64.net/wiki/index.php?title=MAPTRIANGLE                                                                      |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sheet() As SHEET '                                                      array defining sprite sheets
    Shared sprite() As SPRITE '                                                    array defining sprites

    Dim tempsprite& '                                                              temporary holding image for sprite from sheet
    Dim cellx% '                                                                   the upper left x location of sprite on sheet
    Dim celly% '                                                                   the upper right y location of sprite on sheet
    Dim px!(3) '                                                                   polar x coordinates of maptriangle
    Dim py!(3) '                                                                   polar y coordinates of maptriangle
    Dim sinr! '                                                                    the sine function used on rotation
    Dim cosr! '                                                                    the cosine function used on rotation
    Dim count% '                                                                   a generic counter used in subroutine
    Dim x2& '                                                                      temp variable used when computing polar coordinates
    Dim y2& '                                                                      temp variable used when computing polar coordinates
    Dim swidth% '                                                                  the width of the sprite on the sprite sheet
    Dim sheight% '                                                                 the height of the sprite on the sprite sheet
    Dim bx1% '                                                                     upper left x location of background image
    Dim by1% '                                                                     upper left y location of background image
    Dim bx2% '                                                                     lower right x location of background image
    Dim by2% '                                                                     lower right y location of background image
    Dim cx% '                                                                      used to center pixel accurate collision image
    Dim cy% '                                                                      used to center pixel accurate collision image

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEPUT: The sprite specified does not exist." '                  no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If sprite(handle%).onscreen And sprite(handle%).restore Then '                 is sprite on screen and should it restore background
        _PutImage (sprite(handle%).backx, sprite(handle%).backy), sprite(handle%).background
        _FreeImage sprite(handle%).background '                                    background image no longer needed
    ElseIf (Not sprite(handle%).onscreen) And sprite(handle%).visible Then '       has sprite been made visible again or first time?
        sprite(handle%).onscreen = -1 '                                            sprite will be placed on the screen
    End If

    If sprite(handle%).motion Then '                                               is sprite automotion enabled?
        sprite(handle%).actualx = sprite(handle%).actualx + sprite(handle%).xdir ' yes, update sprite x position
        sprite(handle%).actualy = sprite(handle%).actualy + sprite(handle%).ydir ' update sprite y position
        sprite(handle%).currentx = Int(sprite(handle%).actualx) '                  this is where the sprite will show on screen
        sprite(handle%).currenty = Int(sprite(handle%).actualy) '                  this is where the sprite will show on screen

    Else
        sprite(handle%).actualx = x! '                                             allows user to use small increments if desired
        sprite(handle%).actualy = y! '                                             allows user to use small increments if desired
        sprite(handle%).currentx = Int(x!) '                                       this is where the sprite will show on screen
        sprite(handle%).currenty = Int(y!) '                                       this is where the sprite will show on screen
    End If

    If Not sprite(handle%).visible Then Exit Sub '                                 if sprite hidden no need to do rest of subroutine
    If sprite(handle%).animation Then SPRITENEXT handle% '                         perform autoanimation if enabled
    swidth% = sheet(sprite(handle%).sheet).spritewidth '                           width of sprite
    sheight% = sheet(sprite(handle%).sheet).spriteheight '                         height of sprite
    If sprite(handle%).currentcell Mod sheet(sprite(handle%).sheet).columns = 0 Then ' is sprite in rightmost column?
        cellx% = swidth% * (sheet(sprite(handle%).sheet).columns - 1) '            yes, upper left x position of sprite on sprite sheet
        celly% = ((sprite(handle%).currentcell \ sheet(sprite(handle%).sheet).columns) - 1) * sheight% ' upper left y position on sheet
    Else '                                                                         sprite is not in rightmost column
        cellx% = (sprite(handle%).currentcell Mod sheet(sprite(handle%).sheet).columns - 1) * swidth% ' upper left x position of sprite on sheet
        celly% = (sprite(handle%).currentcell \ sheet(sprite(handle%).sheet).columns) * sheight% '      upper left y position of sprite on sheet
    End If
    If sprite(handle%).zoom <> 100 Then '                                          does the sprite need to be zoomed in or out?
        swidth% = swidth% * (sprite(handle%).zoom / 100) '                         yes, calculate new sprite width
        sheight% = sheight% * (sprite(handle%).zoom / 100) '                       calculate new sprite height
    End If
    tempsprite& = _NewImage(swidth%, sheight%, 32) '                               create temporary image holder for sprite
    Select Case sprite(handle%).flip '                                             should the image be flipped while copied?
        Case 0 '                                                                   no flip, copy original sprite orientation
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx%, celly%)-(cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)
        Case 1 '                                                                   flip sprite horizontally while copying it
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly%)-(cellx%, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)
        Case 2 '                                                                   flip sprite vertically while copying it
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx%, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)-(cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly%)
        Case 3 '                                                                   flip sprite both horizontally and vertically
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)-(cellx%, celly%)
    End Select
    px!(0) = -swidth% / 2 '                                                        upper left  x polar coordinate of sprite
    py!(0) = -sheight% / 2 '                                                       upper left  y polar coordinate of sprite
    px!(1) = px!(0) '                                                              lower left  x polar coordinate of sprite
    py!(1) = sheight% / 2 '                                                        lower left  y polar coordinate of sprite
    px!(2) = swidth% / 2 '                                                         lower right x polar coordinate of sprite
    py!(2) = py!(1) '                                                              lower right y polar coordinate of sprite
    px!(3) = px!(2) '                                                              upper right x polar coordinate of sprite
    py!(3) = py!(0) '                                                              upper right y polar coordinate of sprite


    If sprite(handle%).motion And sprite(handle%).spindir <> 0 Then
        sprite(handle%).rotation = sprite(handle%).rotation + sprite(handle%).spindir
        If sprite(handle%).rotation < 0 Then sprite(handle%).rotation = sprite(handle%).rotation + 360
        If sprite(handle%).rotation >= 360 Then sprite(handle%).rotation = sprite(handle%).rotation - 360
    End If


    If sprite(handle%).rotation <> 0 Then '                                        does the sprite need to be rotated?
        sinr! = Sin(-sprite(handle%).rotation / 57.2957795131) '                   yes, some magic math for rotation
        cosr! = Cos(-sprite(handle%).rotation / 57.2957795131) '                   some more magic math for rotation
        bx1% = 0 '                                                                 upper left  x coordinate of background
        by1% = 0 '                                                                 upper left  y coordinate of background
        bx2% = 0 '                                                                 lower right x coordinate of background
        by2% = 0 '                                                                 lower right y coordinate of background
        For count% = 0 To 3 '                                                      cycle through all four polar coordinates
            x2& = (px!(count%) * cosr! + sinr! * py!(count%)) '                    compute new polar coordinate location
            y2& = (py!(count%) * cosr! - px!(count%) * sinr!) '                    compute new polar coordinate location
            px!(count%) = x2& '                                                    save the new polar coordinate
            py!(count%) = y2& '                                                    save the new polar coordinate
            If px!(count%) < bx1% Then bx1% = px!(count%) '                        save lowest  x value seen \
            If px!(count%) > bx2% Then bx2% = px!(count%) '                        save highest x value seen  \ background image
            If py!(count%) < by1% Then by1% = py!(count%) '                        save lowest  y value seen  / rectangle coordinates
            If py!(count%) > by2% Then by2% = py!(count%) '                        save highest y value seen /
        Next count%
        If sprite(handle%).onscreen And sprite(handle%).restore Then '             should the sprite save the background?
            sprite(handle%).background = _NewImage((bx2% - bx1%) + 1, (by2% - by1%) + 1, 32) ' yes, compute the background image
            _PutImage , _Dest, sprite(handle%).background, (sprite(handle%).currentx + bx1%, sprite(handle%).currenty + by1%)-(sprite(handle%).currentx + bx2%, sprite(handle%).currenty + by2%)
            sprite(handle%).backx = sprite(handle%).currentx + bx1% ' save the background's x location
            sprite(handle%).backy = sprite(handle%).currenty + by1% ' save the background's y location
        End If
        sprite(handle%).currentwidth = bx2% - bx1% + 1 '                           save width of sprite after zoom and rotation
        sprite(handle%).currentheight = by2% - by1% + 1 '                          save height of sprite after zoom and rotation
        sprite(handle%).screenx1 = sprite(handle%).currentx + bx1% '               save upper left x position of sprite on screen
        sprite(handle%).screeny1 = sprite(handle%).currenty + by1% '               save upper left y potition of sprite on screen
        sprite(handle%).screenx2 = sprite(handle%).currentx + bx2% '               save lower right x position of sprite on screen
        sprite(handle%).screeny2 = sprite(handle%).currenty + by2% '               save lower right y potition of sprite on screen
        _MapTriangle (0, 0)-(0, sheight% - 1)-(swidth% - 1, sheight% - 1), tempsprite& To(sprite(handle%).currentx + px!(0), sprite(handle%).currenty + py!(0))-(sprite(handle%).currentx + px!(1), sprite(handle%).currenty + py!(1))-(sprite(handle%).currentx + px!(2), sprite(handle%).currenty + py!(2))
        _MapTriangle (0, 0)-(swidth% - 1, 0)-(swidth% - 1, sheight% - 1), tempsprite& To(sprite(handle%).currentx + px!(0), sprite(handle%).currenty + py!(0))-(sprite(handle%).currentx + px!(3), sprite(handle%).currenty + py!(3))-(sprite(handle%).currentx + px!(2), sprite(handle%).currenty + py!(2))
        If sprite(handle%).detecttype = 2 Then '                                   does sprite use pixel accuracy collision detection?
            _FreeImage sprite(handle%).image '                                     yes, get rid of the last image save
            sprite(handle%).image = _NewImage(sprite(handle%).currentwidth, sprite(handle%).currentheight, 32) ' create a new image holder and map triangles in
            cx% = sprite(handle%).currentwidth / 2
            cy% = sprite(handle%).currentheight / 2
            _MapTriangle (0, 0)-(0, sheight% - 1)-(swidth% - 1, sheight% - 1), tempsprite& To(cx% + px!(0), cy% + py!(0))-(cx% + px!(1), cy% + py!(1))-(cx% + px!(2), cy% + py!(2)), sprite(handle%).image
            _MapTriangle (0, 0)-(swidth% - 1, 0)-(swidth% - 1, sheight% - 1), tempsprite& To(cx% + px!(0), cy% + py!(0))-(cx% + px!(3), cy% + py!(3))-(cx% + px!(2), cy% + py!(2)), sprite(handle%).image
        End If
    Else '                                                                         no rotation was needed, just place image on screen
        If sprite(handle%).onscreen And sprite(handle%).restore Then '             should the sprite save the background?
            sprite(handle%).background = _NewImage(Int(px!(2)) - Int(px!(0)), Int(py!(2)) - Int(py!(0)), 32) ' yes, compute the background image
            _PutImage , _Dest, sprite(handle%).background, (sprite(handle%).currentx + Int(px!(0)), sprite(handle%).currenty + Int(py!(0)))-(sprite(handle%).currentx + Int(px!(2)) - 1, sprite(handle%).currenty + Int(py!(2)) - 1)
            sprite(handle%).backx = sprite(handle%).currentx + Int(px!(0)) '       save the background's x location
            sprite(handle%).backy = sprite(handle%).currenty + Int(py!(0)) '       save the background's y location
        End If
        sprite(handle%).currentwidth = Int(px!(2)) - Int(px!(0)) '                 save width of sprite after zoom
        sprite(handle%).currentheight = Int(py!(2)) - Int(py!(0)) '                save height of sprite after zoom
        sprite(handle%).screenx1 = sprite(handle%).currentx + Int(px!(0)) '        save upper left x of sprite on screen
        sprite(handle%).screeny1 = sprite(handle%).currenty + Int(py!(0)) '        save upper left y of sprite on screen
        sprite(handle%).screenx2 = sprite(handle%).currentx + Int(px!(2)) - 1 '    save lower right x of sprite onscreen
        sprite(handle%).screeny2 = sprite(handle%).currenty + Int(py!(2)) - 1 '    save lower right y of sprite onscreen
        _PutImage (sprite(handle%).screenx1, sprite(handle%).screeny1), tempsprite& ' copy temporary sprite image to the screen
        If sprite(handle%).detecttype = 2 Then '                                   does sprite use pixel accuracy collision detection?
            _FreeImage sprite(handle%).image '                                     yes, get rid of the last image saved
            sprite(handle%).image = _CopyImage(tempsprite&) '                      save a copy of the current sprite image
        End If
    End If
    _FreeImage tempsprite& '                                                       temporary image holder no longer needed

End Sub

'##################################################################################################################################

Function SPRITEY2 (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the lower right y screen position of the sprite.                   |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : y2% = SPRITEY2(mysprite%)                                          |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to get the lower right y screen coordinate.   | - The y value passed back is the lower right y    |
    '|                                                                            |   screen position of the bounding box of the      |
    '| Output: an integer value containing the lower right y screen coordinate.   |   sprite.                                         |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEY2: The sprite specified does not exist." '                   no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEY2 = sprite(handle%).screeny2 '                                          return the lower right y coordinate of sprite

End Function

'##################################################################################################################################

Function SPRITEX2 (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the lower right x screen position of the sprite.                   |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : x2% = SPRITEX2(mysprite%)                                          |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to get the lower right x screen coordinate.   | - The x value passed back is the lower right x    |
    '|                                                                            |   screen position of the bounding box of the      |
    '| Output: an integer value containing the lower right x screen coordinate.   |   sprite.                                         |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEX2: The sprite specified does not exist." '                   no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEX2 = sprite(handle%).screenx2 '                                          return the lower right x coordinate of sprite

End Function

'##################################################################################################################################

Function SPRITEY1 (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the upper left y screen position of the sprite.                    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : y1% = SPRITEY1(mysprite%)                                          |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to get the upper left y screen coordinate.    | - The y value passed back is the upper left y     |
    '|                                                                            |   screen position of the bounding box of the      |
    '| Output: an integer value containing the upper left y screen coordinate.    |   sprite.                                         |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEY1: The sprite specified does not exist." '                   no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEY1 = sprite(handle%).screeny1 '                                          return the upper left y coordinate of sprite

End Function

'##################################################################################################################################

Function SPRITEX1 (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the upper left x screen position of the sprite.                    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : x1% = SPRITEX1(mysprite%)                                          |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to get the upper left x screen coordinate.    | - The x value passed back is the upper left x     |
    '|                                                                            |   screen position of the bounding box of the      |
    '| Output: an integer value containing the upper left x screen coordinate.    |   sprite.                                         |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEX1: The sprite specified does not exist." '                   no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEX1 = sprite(handle%).screenx1 '                                          return the upper left x coordinate of sprite

End Function

'##################################################################################################################################

Function SPRITEMOUSEAY (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the y location of the mouse on the screen.                         |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : yonscreen% = SPRITEMOUSEAY(mysprite%)                              |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution                       |
    '| Input : handle% - the sprite to get the mouse's y screen position from.    | - The y location returned is the coordinate on    |
    '|                                                                            |   on the screen itself.                           |
    '| Output: an integer value containing the mouse's y screen position.         |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEMOUSEAY: The sprite specified does not exist." '              no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEMOUSEAY = sprite(handle%).mouseay '                                      report the y location of pointer on screen

End Function

'##################################################################################################################################

Function SPRITEMOUSEAX (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the x location of the mouse on the screen.                         |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : xonscreen% = SPRITEMOUSEAX(mysprite%)                              |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution                       |
    '| Input : handle% - the sprite to get the mouse's x screen position from.    | - The x location returned is the coordinate on    |
    '|                                                                            |   on the screen itself.                           |
    '| Output: an integer value containing the mouse's x screen position.         |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEMOUSEAX: The sprite specified does not exist." '              no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEMOUSEAX = sprite(handle%).mouseax '                                      report the x location of pointer on screen

End Function

'##################################################################################################################################

Function SPRITEMOUSEY (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the y location of the mouse on the sprite itself.                  |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : yonsprite% = SPRITEMOUSEY(mysprite%)                               |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution                       |
    '| Input : handle% - the sprite to get the mouse's y position from.           | - The y location returned is the coordinate on    |
    '|                                                                            |   on the sprite itself. A 50x50 sprite would      |
    '| Output: an integer value containing the mouse's y poisition on the sprite. |   return a y value of 0 through 49.               |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEMOUSEY: The sprite specified does not exist." '               no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEMOUSEY = sprite(handle%).mousecy '                                       report the y location of pointer on sprite

End Function

'##################################################################################################################################

Function SPRITEMOUSEX (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the x location of the mouse on the sprite itself.                  |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : xonsprite% = SPRITEMOUSEX(mysprite%)                               |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution                       |
    '| Input : handle% - the sprite to get the mouse's x position from.           | - The x location returned is the coordinate on    |
    '|                                                                            |   on the sprite itself. A 50x50 sprite would      |
    '| Output: an integer value containing the mouse's x position on the sprite.  |   return an x value of 0 through 49.              |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEMOUSEX: The sprite specified does not exist." '               no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEMOUSEX = sprite(handle%).mousecx '                                       report the x location of pointer on sprite

End Function

'##################################################################################################################################

Function SPRITEMOUSE (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the status of the current sprite and mouse pointer interaction.    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : interaction% = SPRITEMOUSE(mysprite%)                              |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to check for mouse interaction with.          | - If a mouse event is detected the event is also  |
    '|                                                                            |   recorded in sprite().pointer and the            |
    '| Output: integer value between 0 and 3 indicating the type of interaction.  |   actual mouse x,y screen location, as well as    |
    '|         0 = no mouse interaction.       (constant NOMOUSE)                 |   the mouse x,y sprite location, is recorded.     |
    '|         1 = left mouse button clicked.  (constant MOUSELEFT)               | - The constants NOMOUSE, MOUSELEFT, MOUSERIGHT    |
    '|         2 = right mouse button clicked. (constant MOUSERIGHT)              |   and MOUSEHOVER have been created to be used     |
    '|         3 = mouse pointer is hovering.  (constant MOUSEHOVER)              |   with this function.                             |
    '|                                                                            | - The global constant NOVALUE can be used to      |
    '| Sets  : sprite().pointer  = event number (0-3).                            |   check for valid mouse x,y actual screen         |
    '|         sprite().mouseax  = actual x location of mouse on screen.          |   locations and valid mouse x,y sprite locations. |
    '|                          -32767 = no interaction (constant NOVALUE)        |                                                   |
    '|         sprite().mouseay  = actual y location of mouse on screen.          |                                                   |
    '|                          -32767 = no interaction (constant NOVALUE)        |                                                   |
    '|         sprite().mousecx = x location of mouse on sprite.                  |                                                   |
    '|                          -32767 = no interaction (constant NOVALUE)        |                                                   |
    '|         sprite().mousecy = y location of mouse on sprite.                  |                                                   |
    '|                          =32767 = no interaction (constant NOVALUE)        |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    Dim event% '                                                                   event currently interacting between mouse and sprite

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEMOUSE: The sprite specified does not exist." '                no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    Do: Loop While _MouseInput '                                                   get the most up to date mouse event
    SPRITEMOUSE = 0 '                                                              report no sprite and mouse interaction by default
    event% = 3 '                                                                   assume mouse in currenly hovering over sprite
    If _MouseButton(1) Then event% = 1 '                                           if left button pressed then set the event
    If _MouseButton(2) Then event% = 2 '                                           if the right button pressed then set the event
    If sprite(handle%).onscreen Then '                                             is the sprite currently on the screen?
        If (_MouseX >= sprite(handle%).screenx1) And (_MouseX <= sprite(handle%).screenx2) And (_MouseY >= sprite(handle%).screeny1) And (_MouseY <= sprite(handle%).screeny2) Then
            sprite(handle%).pointer = event% '                                     mouse pointer is over sprite, set the event
            SPRITEMOUSE = event% '                                                 report the event number
        Else '                                                                     mouse pointer is not currently over sprite
            sprite(handle%).pointer = 0 '                                          set event as no mouse interaction
            SPRITEMOUSE = 0 '                                                      report the event number
            event% = 0 '                                                           set the event as no interaction
        End If
        If event% <> 0 Then '                                                      was there mouse interaction with this sprite?
            sprite(handle%).mouseax = _MouseX '                                    yes, save the actual screen x location of pointer
            sprite(handle%).mouseay = _MouseY '                                    save the actual screen y location of pointer
            sprite(handle%).mousecx = _MouseX - sprite(handle%).screenx1 '         save the pointer x location on sprite itself
            sprite(handle%).mousecy = _MouseY - sprite(handle%).screeny1 '         save the pointer y location on sprite itself
        Else '                                                                     there is no mouse interaction with sprite
            sprite(handle%).mouseax = -32767 '                                     set the mouse x value as having no interaction
            sprite(handle%).mouseay = -32767 '                                     set the mouse y value as having no interaction
            sprite(handle%).mousecx = -32767 '                                     set the mouse x location on sprite as no interaction
            sprite(handle%).mousecy = -32767 '                                     set the mouse y location on sprite as no interaction
        End If
    End If

End Function

'##################################################################################################################################

Sub SPRITEFREE (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Removes a sprite from memory, freeing its resources.                       |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEFREE mysprite%                                               |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite number to be freed from memory.               | - If the sprite is on the screen when freed the   |
    '|                                                                            |   background image will be restored before the    |
    '| Output: none                                                               |   sprite is freed from memory.                    |
    '|                                                                            |                                                   |
    '| Sets  : sprite().inuse to equal 0 if the element is not last in array.     |                                                   |
    '|         sprite().background image freed if element contained one.          |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEFREE: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If sprite(handle%).restore Then '                                              has this sprite been saving the background?
        If sprite(handle%).onscreen Then '                                         yes, is the sprite onscreen?
            _PutImage (sprite(handle%).backx, sprite(handle%).backy), sprite(handle%).background ' restore background
        End If
        _FreeImage sprite(handle%).background '                                    free the sprite's background image
    End If
    If handle% = UBound(sprite) And handle% <> 1 Then '                            is this the last element in the array?
        ReDim _Preserve sprite(handle% - 1) As SPRITE '                            yes, resize the array, removing the element
    Else '                                                                         this is not the last element in the array
        sprite(handle%).inuse = 0 '                                                mark the array entry as not in use
    End If

End Sub

'##################################################################################################################################

Sub SPRITESTAMP (x%, y%, handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Places a sprite on the background as if using a sprite stamp pad.          |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITESTAMP 100, 100, mysprite%                                    |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : x%      - the x location to place stamp.                           | - The sprite will be stamped onto the background  |
    '|         y%      - the y location to place stamp.                           |   with all current aspects (orientation and zoom) |
    '|         handle% - the sprite image to use as a stamp.                      |   that have been set for the sprite being stamped.|
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Credits: Portions of this subroutine have code based off of Galleon's RotoZoom subroutine found in the QB64 documentation at   |
    '|          http://qb64.net/wiki/index.php?title=MAPTRIANGLE                                                                      |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites
    Shared sheet() As SHEET '                                                      array defining sprite sheets

    Dim tempsprite& '                                                              temporary holding image for sprite from sheet
    Dim cellx% '                                                                   the upper left x location of sprite on sheet
    Dim celly% '                                                                   the upper right y location of sprite on sheet
    Dim px!(3) '                                                                   polar x coordinates of maptriangle
    Dim py!(3) '                                                                   polar y coordinates of maptriangle
    Dim sinr! '                                                                    the sine function used on rotation
    Dim cosr! '                                                                    the cosine function used on rotation
    Dim count% '                                                                   a generic counter used in subroutine
    Dim x2& '                                                                      temp variable used when computing polar coordinates
    Dim y2& '                                                                      temp variable used when computing polar coordinates
    Dim swidth% '                                                                  the width of the stamp on the sprite sheet
    Dim sheight% '                                                                 the height of the stamp on the sprite sheet

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESTAMP: The sprite specified does not exist." '                no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    swidth% = sheet(sprite(handle%).sheet).spritewidth '                           width of stamp
    sheight% = sheet(sprite(handle%).sheet).spriteheight '                         height of stamp
    If sprite(handle%).currentcell Mod sheet(sprite(handle%).sheet).columns = 0 Then ' is stamp in rightmost column?
        cellx% = swidth% * (sheet(sprite(handle%).sheet).columns - 1) '            yes, upper left x position of stamp on sprite sheet
        celly% = ((sprite(handle%).currentcell \ sheet(sprite(handle%).sheet).columns) - 1) * sheight% ' upper left y position on sheet
    Else '                                                                         stamp is not in rightmost column
        cellx% = (sprite(handle%).currentcell Mod sheet(sprite(handle%).sheet).columns - 1) * swidth% ' upper left x position of stamp on sheet
        celly% = (sprite(handle%).currentcell \ sheet(sprite(handle%).sheet).columns) * sheight% '      upper left y position of stamp on sheet
    End If
    If sprite(handle%).zoom <> 100 Then '                                          does the stamp need to be zoomed in or out?
        swidth% = swidth% * (sprite(handle%).zoom / 100) '                         yes, calculate new stamp width
        sheight% = sheight% * (sprite(handle%).zoom / 100) '                       calculate new stamp height
    End If
    tempsprite& = _NewImage(swidth%, sheight%, 32) '                               create temporary image holder for the stamp
    Select Case sprite(handle%).flip '                                             should the image be flipped while copied?
        Case 0 '                                                                   no flip, copy original stamp orientation
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx%, celly%)-(cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)
        Case 1 '                                                                   flip stamp horizontally while copying it
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly%)-(cellx%, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)
        Case 2 '                                                                   flip stamp vertically while copying it
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx%, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)-(cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly%)
        Case 3 '                                                                   flip stamp both horizontally and vertically
            _PutImage , sheet(sprite(handle%).sheet).sheetimage, tempsprite&, (cellx% + sheet(sprite(handle%).sheet).spritewidth - 1, celly% + sheet(sprite(handle%).sheet).spriteheight - 1)-(cellx%, celly%)
    End Select
    px!(0) = -swidth% / 2 '                                                        upper left  x polar coordinate of stamp
    py!(0) = -sheight% / 2 '                                                       upper left  y polar coordinate of stamp
    px!(1) = px!(0) '                                                              lower left  x polar coordinate of stamp
    py!(1) = sheight% / 2 '                                                        lower left  y polar coordinate of stamp
    px!(2) = swidth% / 2 '                                                         lower right x polar coordinate of stamp
    py!(2) = py!(1) '                                                              lower right y polar coordinate of stamp
    px!(3) = px!(2) '                                                              upper right x polar coordinate of stamp
    py!(3) = py!(0) '                                                              upper right y polar coordinate of stamp
    If sprite(handle%).rotation <> 0 Then '                                        does the stamp need to be rotated?
        sinr! = Sin(-sprite(handle%).rotation / 57.2957795131) '                   yes, some magic math for rotation
        cosr! = Cos(-sprite(handle%).rotation / 57.2957795131) '                   some more magic math for rotation
        For count% = 0 To 3 '                                                      cycle through all four polar coordinates
            x2& = (px!(count%) * cosr! + sinr! * py!(count%)) '                    compute new polar coordinate location
            y2& = (py!(count%) * cosr! - px!(count%) * sinr!) '                    compute new polar coordinate location
            px!(count%) = x2& '                                                    save the new polar coordinate
            py!(count%) = y2& '                                                    save the new polar coordinate
        Next count%
        _MapTriangle (0, 0)-(0, sheight% - 1)-(swidth% - 1, sheight% - 1), tempsprite& To(x% + px!(0), y% + py!(0))-(x% + px!(1), y% + py!(1))-(x% + px!(2), y% + py!(2))
        _MapTriangle (0, 0)-(swidth% - 1, 0)-(swidth% - 1, sheight% - 1), tempsprite& To(x% + px!(0), y% + py!(0))-(x% + px!(3), y% + py!(3))-(x% + px!(2), y% + py!(2))
    Else '                                                                         no rotation was needed, just place stamp on screen
        _PutImage (x% + Int(px!(0)), y% + Int(py!(0))), tempsprite& '              stamp temporary sprite image to the screen
    End If
    _FreeImage tempsprite& '                                                       temporary image holder no longer needed

End Sub

'##################################################################################################################################

Function SPRITECOPY (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Makes a copy of a sprite and returns the newly created sprite's handle.    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : newsprite% = SPRITECOPY(mysprite%)                                 |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite being copied.                                 | - All aspects of the sprite being copied (auto-   |
    '|                                                                            |   motion, autoanimation, location, orientation,   |
    '| Output: an integer greater than 0 indicating the new sprite's handle.      |   etc.. will be retained by the new sprite.       |
    '|                                                                            |                                                   |
    '| Sets  : sprite().* all variables of new sprite by virtue of copying values |                                                   |
    '|         from original sprite().*                                           |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    Dim newhandle% '                                                               the handle number fo the newly created sprite

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITECOPY: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    newhandle% = 0 '                                                               initialize handle value
    Do '                                                                           look for the next available handle
        newhandle% = newhandle% + 1 '                                              increment the handle value
    Loop Until (Not sprite(newhandle%).inuse) Or newhandle% = UBound(sprite) '     stop looking when valid handle value found
    If sprite(newhandle%).inuse Then '                                             is the last array element in use?
        newhandle% = newhandle% + 1 '                                              yes, increment the handle value
        ReDim _Preserve sprite(newhandle%) As SPRITE '                             increase the size of sprite array
    End If
    sprite(newhandle%) = sprite(handle%) '                                         copy the sprite
    SPRITECOPY = newhandle% '                                                      report back with the new sprite handle

End Function

'##################################################################################################################################

Sub SPRITEPREVIOUS (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Go to previous cell of sprite's animation sequence.                        |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEPREVIOUS mysprite%                                           |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the number of the sprite to advance animation cell.      |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().currentcell to the previous animation cell based on the   |                                                   |
    '|         saved sprite().animtype.                                           |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITENEXT: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    Select Case sprite(handle%).animtype '                                         which type of animation behavior should be used?
        Case 0 '                                                                   forward looping animation
            sprite(handle%).currentcell = sprite(handle%).currentcell - 1 '        select previous sprite sheet cell
            If sprite(handle%).currentcell < sprite(handle%).animstart Then '      does cell go beyond the minimum cell allowed?
                sprite(handle%).currentcell = sprite(handle%).animend '            yes, reset the cell back to end of animation
            End If
        Case 1 '                                                                   backward looping animation
            sprite(handle%).currentcell = sprite(handle%).currentcell + 1 '        select next sprite sheet cell
            If sprite(handle%).currentcell > sprite(handle%).animend Then '        does the cell go beyond the maximum cell allowed?
                sprite(handle%).currentcell = sprite(handle%).animstart '          yes, reset the cell back to beginning of animation
            End If
        Case 2 '                                                                   forward/backward looping animation
            sprite(handle%).animdir = -sprite(handle%).animdir '                   temporarily set opposite looping direction
            If (sprite(handle%).currentcell + sprite(handle%).animdir < sprite(handle%).animstart) Or (sprite(handle%).currentcell + sprite(handle%).animdir > sprite(handle%).animend) Then
                sprite(handle%).animdir = -sprite(handle%).animdir '               minimum/maximum cell was reached, change direction
            End If
            sprite(handle%).currentcell = sprite(handle%).currentcell + sprite(handle%).animdir ' select next/previous sheet cell
            sprite(handle%).animdir = -sprite(handle%).animdir '                   set looping direction back to what it was
    End Select

End Sub

'##################################################################################################################################

Sub SPRITENEXT (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Go to next cell of sprite's animation sequence.                            |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITENEXT mysprite%                                               |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the number of the sprite to advance animation cell.      |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().currentcell to the next animation cell based on the saved |                                                   |
    '|         sprite().animtype.                                                 |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITENEXT: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    Select Case sprite(handle%).animtype '                                         which type of animation behavior should be used?
        Case 0 '                                                                   forward looping animation
            sprite(handle%).currentcell = sprite(handle%).currentcell + 1 '        select next sprite sheet cell
            If sprite(handle%).currentcell > sprite(handle%).animend Then '        does cell go beyond the maximum cell allowed?
                sprite(handle%).currentcell = sprite(handle%).animstart '          yes, reset the cell back to beginning of animation
            End If
        Case 1 '                                                                   backward looping animation
            sprite(handle%).currentcell = sprite(handle%).currentcell - 1 '        select previous sprite sheet cell
            If sprite(handle%).currentcell < sprite(handle%).animstart Then '      does the cell go beyond the minimum cell allowed?
                sprite(handle%).currentcell = sprite(handle%).animend '            yes, reset the cell back to end of animation
            End If
        Case 2 '                                                                   forward/backward looping animation
            If (sprite(handle%).currentcell + sprite(handle%).animdir < sprite(handle%).animstart) Or (sprite(handle%).currentcell + sprite(handle%).animdir > sprite(handle%).animend) Then
                sprite(handle%).animdir = -sprite(handle%).animdir '               minimum/maximum cell was reached, change direction
            End If
            sprite(handle%).currentcell = sprite(handle%).currentcell + sprite(handle%).animdir ' select next/previous sheet cell
    End Select

End Sub

'##################################################################################################################################

Sub SPRITEANIMATION (handle%, onoff%, behavior%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Turns on or off automatic sprite animation with specified behavior.        |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEANIMATION mysprite%, -1, 0                                   |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%   - the number of the sprite to turn animation on or off.  | - The constants ANIMATE, NOANIMATE, FORWARDLOOP,  |
    '|         onoff%    - enable or disable automatic sprite animation:          |   BACKWARDLOOP and BACKFORTHLOOP have been        |
    '|                     0 = disable automatic animation (constant NOANIMATE)   |   created to be used with this subroutine.        |
    '|                    -1 = enable automatic animation  (cosntant ANIMATE)     |                                                   |
    '|         behavior% - the type of animation sequence desired:                |                                                   |
    '|                     0 = forward loop               (constant FORWARDLOOP)  |                                                   |
    '|                     1 = backward loop              (constant BACKWARDLOOP) |                                                   |
    '|                     2 = forward then backward loop (constant BACKFORTHLOOP)|                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().animation to 0 or -1 based on variable onoff% passed in.  |                                                   |
    '|         sprite().animtype to 0, 1 or 2 bassed on behavior% passed in.      |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEANIMATION: The sprite specified does not exist." '            no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).animation = onoff% '                                           enable or disable automatic sprite animation
    sprite(handle%).animtype = behavior% '                                         set animation looping type behavior

End Sub

'##################################################################################################################################

Sub SPRITEANIMATESET (handle%, startcell%, endcell%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets a sprite's animation sequence start and end sprite sheet cells.       |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEANIMATESET mysprite%, 10, 14                                 |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%    - the sprite number to set the animation sequence for.  |                                                   |
    '|         startcell% - the sprite sheet cell number to start at.             |                                                   |
    '|         endcell%   - the sprite sheet cell number to end at.               |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().animstart to equal the startcell number passed in.        |                                                   |
    '|         sprite().animend to equal the endcell number passed in.            |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEANIMATESET: The sprite specified does not exist." '           no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).animstart = startcell% '                                       set sprite's starting animation cell
    sprite(handle%).animend = endcell% '                                           set sprite's ending animation cell

End Sub

'##################################################################################################################################

Sub SPRITESET (handle%, cell%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Sets a sprite's image to a new image number on sprite sheet.               |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITESET mysprite%, 20                                            |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite number to change the image of.                |                                                   |
    '|         cell%   - the cell number on the animation sheet to use.           |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().currentcell to equal the cell number passed in.           |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESET: The sprite specified does not exist." '                  no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).currentcell = cell% '                                          set sprite's image to new sheet image number

End Sub

'##################################################################################################################################

Function SPRITEAY (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the actual y location of a sprite.                                 |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : y! = SPRITEAY(mysprite%)                                           |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the actual y location from.       |                                                   |
    '|                                                                            |                                                   |
    '| Output: a single value indicating the actual y position of the sprite.     |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEAY: The sprite specified does not exist." '                   no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEAY = sprite(handle%).actualy '                                           report back with sprite's actual y location

End Function

'##################################################################################################################################

Function SPRITEAX (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the actual x location of a sprite.                                 |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : x! = SPRITEAX(mysprite%)                                           |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the actual x location from.       |                                                   |
    '|                                                                            |                                                   |
    '| Output: a single value indicating the actual x position of the sprite.     |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEAX: The sprite specified does not exist." '                   no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEAX = sprite(handle%).actualx '                                           report back with sprite's screen x location

End Function

'##################################################################################################################################

Function SPRITEY (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the screen y location of a sprite.                                 |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : y% = SPRITEY(mysprite%)                                            |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the screen y location from.       |                                                   |
    '|                                                                            |                                                   |
    '| Output: an integer value indicating the y screen position of the sprite.   |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEY: The sprite specified does not exist." '                    no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEY = sprite(handle%).currenty '                                           report back with sprite's screen y location

End Function

'##################################################################################################################################

Function SPRITEX (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Returns the screen x location of a sprite.                                 |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : x% = SPRITEX(mysprite%)                                            |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to retrieve the screen x location from.       |                                                   |
    '|                                                                            |                                                   |
    '| Output: an integer value indicating the x screen position of the sprite.   |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEX: The sprite specified does not exist." '                    no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEX = sprite(handle%).currentx '                                           report back with sprite's screen x location

End Function

'##################################################################################################################################

Function SPRITEROTATION (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Gets the current rotation angle of a sprite in degrees.                    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : degrees! = SPRITEROTATION(mysprite%)                               |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution                       |
    '| Input : handle% - the sprite to retrieve the rotation angle from.          |                                                   |
    '|                                                                            |                                                   |
    '| Output: a single value between 0 and 359.99..                              |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEROTATION: The sprite specified does not exist." '             no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    SPRITEROTATION = sprite(handle%).rotation '                                    report back with sprite's rotation angle

End Function

'##################################################################################################################################

Sub SPRITESHOW (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Unhides a sprite from view.                                                |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITESHOW mysprite%                                               |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to make visible.                              |                                                   |
    '|                                                                            |                                                   |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().visible to equal -1.                                      |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITESHOW: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If Not sprite(handle%).visible Then '                                          is sprite currently hidden?
        sprite(handle%).visible = -1 '                                             yes, set sprite as being visible
        SPRITEPUT sprite(handle%).currentx, sprite(handle%).currenty, handle% '    put sprite back on screen
    End If

End Sub

'##################################################################################################################################

Sub SPRITEHIDE (handle%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Hides a sprite from view.                                                  |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEHIDE mysprite%                                               |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to make invisible.                            | - Only a sprite that saves its background can be  |
    '|                                                                            |   hidden. Specifying a sprite that is not saving  |
    '| Output: none                                                               |   the background will result in the subroutine    |
    '|                                                                            |   reporting an error and halting program          |
    '| Sets  : sprite().visible to equal 0. *                                     |   execution.                                      |
    '|         sprite().onscreen equal to 0 if it was showing on screen. *        |                                                   |
    '|          * redundant?                                                      |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEHIDE: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If Not sprite(handle%).restore Then '                                          is this sprite saving the background?
        Print "SPRITEHIDE: Only sprites that save the background can be hidden." ' no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If sprite(handle%).onscreen Then '                                             yes, is the sprite onscreen?
        _PutImage (sprite(handle%).backx, sprite(handle%).backy), sprite(handle%).background ' restore background
        _FreeImage sprite(handle%).background '                                    free the sprite's background image
        sprite(handle%).onscreen = 0 '                                             sprite is no longer on the screen
    End If
    sprite(handle%).visible = 0 '                                                  set sprite as being hidden

End Sub

'##################################################################################################################################

Sub SPRITEZOOM (handle%, zoom%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Change the size (zoom level) of a sprite.                                  |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEZOOM mysprite%, 150                                          |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle% - the sprite to change the size of.                        | - Specifying a zoom level of 0 or less will       |
    '|         zoom%   - 1 to x (100 = 100%)                                      |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Output: none                                                               |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : sprite().zoom to equal the zoom value passed in.                   |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEZOOM: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If Not zoom% > 0 Then '                                                        is zoom value greater than 0?
        Print "SPRITEZOOM: zoom value must be greater than 0" '                    no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).zoom = zoom% '                                                 set the sprite's zoom level

End Sub

'##################################################################################################################################

Sub SPRITEROTATE (handle%, degrees!)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Rotates a sprite from 0 to 360 degrees.                                    |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEROTATE mysprite%, 22.5                                       |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%  - the sprite to rotate.                                   | - Specifying a rotation angle of less than 0 or   |
    '|         degrees! - the angle to rotate the sprite to.                      |   or not less than 360 will result in the sub-    |
    '|                                                                            |   routine reporting an error and halting program  |
    '| Output: none                                                               |   execution.                                      |
    '|                                                                            |                                                   |
    '| Sets  : sprite().rotation to equal the rotation degrees passed in.         |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEROTATE: The sprite specified does not exist." '               no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If (degrees! < 0) Or (Not degrees! < 360) Then '                               is the degree angle within limits?
        Print "SPRITEROTATE: Degree angle outside allowed range." '                no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).rotation = degrees! '                                          set sprite degree angle

End Sub

'##################################################################################################################################

Sub SPRITEFLIP (handle%, behavior%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Flips a sprite horizontaly, verticaly, both or resets to no flipping.      |                     - NOTES -                     |
    '|                                                                            | - Specifying a sprite that does not exist will    |
    '| Usage : SPRITEFLIP mysprite%, 2                                            |   result in the subroutine reporting an error and |
    '|                                                                            |   halting program execution.                      |
    '| Input : handle%   - the sprite to flip.                                    | - Specifying an invalid behavior type will result |
    '|         behavior% - the type of flipping desired:                          |   in the subroutine reporting an error and        |
    '|                     0 = no flipping     (constant NONE)                    |   halting program execution.                      |
    '|                     1 = flip horizontal (constant HORIZONTAL)              | - The constants NONE, HORIZONTAL, VERTICAL and    |
    '|                     2 = flip vertical   (constant VERTICAL)                |   BOTH have been created to be used with this     |
    '|                     3 = flip both       (constant BOTH)                    |   subroutine.                                     |
    '|                                                                            | - Once a flip behavior has been set it will       |
    '| Output: none                                                               |   remain in effect until the behavior is changed. |
    '|                                                                            |                                                   |
    '| Sets  : sprite().flip to equal the bevaior number passed in.               |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sprite() As SPRITE '                                                    array defining sprites

    If Not sprite(handle%).inuse Then '                                            is this sprite handle in use?
        Print "SPRITEFLIP: The sprite specified does not exist." '                 no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    If behavior% < 0 Or behavior% > 3 Then '                                       was a valid flipping behavior passed in?
        Print "SPRITEFLIP: Invalid flip behavior specified." '                     no, report error to the programmer
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program execution
    End If
    sprite(handle%).flip = behavior% '                                             save the new flipping behavior to the sprite

End Sub

'##################################################################################################################################

Function SPRITENEW (sheet%, cell%, behavior%)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Creates a new sprite given the sheet and images that make up the sprite.   |                     - NOTES -                     |
    '|                                                                            | - Specifying a sheet that does not exist will     |
    '| Usage : mysprite% = SPRITENEW(mysheet%, 1, 4, -1)                          |   result in the function reporting an error and   |
    '|                                                                            |   halting program execution.                      |
    '| Input : sheet%     - the sprite sheet the images reside on.                | - The constants SAVE and DONTSAVE have been       |
    '|         cell%      - the first image in the animation set.                 |   created to be used with this function.          |
    '|                                                                            |                                                   |
    '|         behavior%  - the desired background behavior of sprite:            |                                                   |
    '|                      0 = don't restore background (constant DONTSAVE)      |                                                   |
    '|                     -1 = restore background       (constant SAVE)          |                                                   |
    '|                                                                            |                                                   |
    '| Output: integer value greater than 0 pointing to the newly created sprite. |                                                   |
    '|                                                                            |                                                   |
    '| Sets  : all variables associated with sprite().*                           |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+

    Shared sheet() As SHEET '                                                      array defining sprite sheets
    Shared sprite() As SPRITE '                                                    array defining sprites

    Dim handle% '                                                                  handle number of new sprite

    If Not sheet(sheet%).inuse Then '                                              is the specified sprite sheet in use?
        Print "SPRITENEW: The sprite sheet specified does not exist." '            no, inform user of the error
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort the program
    End If
    handle% = 0 '                                                                  initialize handle value
    Do '                                                                           look for the next available handle
        handle% = handle% + 1 '                                                    increment the handle value
    Loop Until (Not sprite(handle%).inuse) Or handle% = UBound(sprite) '           stop looking when valid handle value found
    If sprite(handle%).inuse Then '                                                is the last array element in use?
        handle% = handle% + 1 '                                                    yes, increment the handle value
        ReDim _Preserve sprite(handle%) As SPRITE '                                increase the size of sprite array
    End If
    sprite(handle%).inuse = -1 '                                                   mark this element as being used
    sprite(handle%).sheet = sheet% '                                               sprite sheet graphics can be found on
    sprite(handle%).currentcell = cell% '                                          reset first image as default
    sprite(handle%).animation = 0 '                                                reset automatic animation to off
    sprite(handle%).animtype = 0 '                                                 default to forward animation looping
    sprite(handle%).animdir = 1 '                                                  forward/backward animation looping starts forward
    sprite(handle%).animstart = 1 '                                                reset animation sequence start cell
    sprite(handle%).animend = 1 '                                                  reset amimation sequence end cell
    sprite(handle%).flip = 0 '                                                     sprite is not flipped horizontaly or verticaly
    sprite(handle%).onscreen = 0 '                                                 sprite is not on screen yet
    sprite(handle%).visible = -1 '                                                 sprite has not been hidden
    sprite(handle%).actualx = 0 '                                                  reset sprite's actual x location
    sprite(handle%).actualy = 0 '                                                  reset sprite's actual y location
    sprite(handle%).currentx = 0 '                                                 reset sprite's current screen x location
    sprite(handle%).currenty = 0 '                                                 reset sprite's current screen y location
    sprite(handle%).backx = 0 '                                                    reset background x location
    sprite(handle%).backy = 0 '                                                    reset background y location
    sprite(handle%).currentwidth = 0 '                                             reset sprite screen width
    sprite(handle%).currentheight = 0 '                                            reset sprite screen height
    sprite(handle%).screenx1 = 0 '                                                 reset upper left x position
    sprite(handle%).screeny1 = 0 '                                                 reset upper left y position
    sprite(handle%).screenx2 = 0 '                                                 reset lower right x position
    sprite(handle%).screeny2 = 0 '                                                 reset lower right y position
    sprite(handle%).layer = 1 '                                                    reset sprite's layer
    sprite(handle%).restore = behavior% '                                          set sprite's background restoration behavior
    sprite(handle%).transparent = sheet(sheet%).transparent '                      get transparent color of sprite
    sprite(handle%).zoom = 100 '                                                   reset sprite's zoom level
    sprite(handle%).rotation = 0 '                                                 reset sprite's degree of rotation
    sprite(handle%).detect = 0 '                                                   reset sprite's collision autodetection
    sprite(handle%).detecttype = 0 '                                               reset to no collision detection desired
    sprite(handle%).collx1 = 0 '                                                   reset collision rectangular area
    sprite(handle%).colly1 = 0 '                                                   reset collision rectangular area
    sprite(handle%).collx2 = 0 '                                                   reset collision rectangular area
    sprite(handle%).colly2 = 0 '                                                   reset collision rectangular area
    sprite(handle%).collsprite = 0 '                                               sprite is not currently colliding with sprite
    sprite(handle%).motion = 0 '                                                   reset sprite's automotion
    sprite(handle%).speed = 0 '                                                    reset sprite's automotion speed
    sprite(handle%).direction = 0 '                                                reset sprite's automotion direction
    sprite(handle%).pointer = 0 '                                                  mouse not currently interacting
    sprite(handle%).mouseax = -32767 '                                             set as no interaction with mouse
    sprite(handle%).mouseay = -32767 '                                             set as no interaction with mouse
    sprite(handle%).mousecx = -32767 '                                             set as no interaction with mouse
    sprite(handle%).mousecy = -32767 '                                             set as no interaction with mouse
    sprite(handle%).score = 0 '                                                    reset sprite's score value
    sprite(handle%).motion = 0
    sprite(handle%).speed = 0
    sprite(handle%).direction = 0
    sprite(handle%).xdir = 0
    sprite(handle%).ydir = 0
    sprite(handle%).spindir = 0
    SPRITENEW = handle% '                                                          return the handle number pointing to this sprite

End Function

'##################################################################################################################################

Function SPRITESHEETLOAD (filename$, spritewidth%, spriteheight%, transparent&)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Loads a sprite sheet into the sprite sheet array and assigns an integer    |                     - NOTES -                     |
    '| handle value pointing to the sheet.                                        | - Specifying a transparent color less than 0 will |
    '|                                                                            |   indicate to the function that no transparency   |
    '| Usage : mysheet% = SPRITESHEETLOAD("sprites.png", 64, 96, _RGB(0, 1, 0))   |   exists in the sprite sheet.                     |
    '|                                                                            | - Specifying a file name of a file that does not  |
    '| Input : filename$     - the name of the sprite sheet image.                |   exist will result in the function reporting an  |
    '|         spritewidth%  - the width of each sprite on the sheet.             |   error and halting program execution.            |
    '|         spriteheight% - the height of each sprite on the sheet.            | - When the width and height of sprites are added  |
    '|         transparent&  - the transparent color layer in sheet (if any).     |   they should match the sheet width and height.   |
    '|                          -1 = no transparency (constant NOTRANSPARENCY).   |   For example, 10 sprites of 20x20 pixels         |
    '|                          -2 = auto discover   (constant AUTOTRANSPARENCY)  |   arranged in two rows should make a 100x40 sheet.|
    '|                         >-1 = transparency color.                          |                                                   |
    '|                                                                            | - The constants NOTRANSPARENCY and                |
    '| Output: integer value greater than 0 pointing to the newly loaded sheet.   |   AUTOTRANSPARENCY have been created to be used   |
    '|                                                                            |   with this function.                             |
    '|                                                                            | - THERE IS A KNOWN ISSUE with this function. See  |
    '| Sets  :                                                                    |   "Known Issues" below.                           |
    '|                                                                            |                                                   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Known Issues: Currently, specifying a transparency value (transparent&) has no effect on any of the other subroutines and      |
    '|               functions in this library. For now, simply supply a value of 0 (or an actual color if you prefer). This feature  |
    '|               is going to be added in a later revision of the library. Use transparent PNG files for now for transparency.     |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Shared sheet() As SHEET '                                                      array defining sprite sheets

    Dim handle% '                                                                  handle number of new sprite sheet
    Dim x%
    Dim y%
    Dim pixel&, alpha&

    If Not SPRITEFILEEXISTS(filename$) Then '                                      does the sprite sheet exist?
        Print "SPRITESHEETLOAD: The sheet named "; filename$; " does not exist." ' no, inform the user of error
        _Display '                                                                 make sure programmer sees error
        Sleep '                                                                    wait for a key press
        System '                                                                   abort program
    End If
    handle% = 0 '                                                                  initialize handle value
    Do '                                                                           look for the next available handle
        handle% = handle% + 1 '                                                    increment the handle value
    Loop Until (Not sheet(handle%).inuse) Or handle% = UBound(sheet) '             stop looking when valid handle value found
    If sheet(handle%).inuse Then '                                                 is the last array element in use?
        handle% = handle% + 1 '                                                    yes, increment the handle value
        ReDim _Preserve sheet(handle%) As SHEET '                                  increase the size of sprite sheet array
    End If
    sheet(handle%).sheetimage = _LoadImage(filename$, 32) '                        assign the image to the array
    sheet(handle%).inuse = -1 '                                                    mark this element as being used
    sheet(handle%).sheetwidth = _Width(sheet(handle%).sheetimage) '                save the width of the sprite sheet
    sheet(handle%).sheetheight = _Height(sheet(handle%).sheetimage) '              save the height of the sprite sheet
    sheet(handle%).spritewidth = spritewidth% '                                    save the width of each sprite
    sheet(handle%).spriteheight = spriteheight% '                                  save the height of each sprite
    sheet(handle%).columns = sheet(handle%).sheetwidth / spritewidth% '            number of sprite columns on sheet
    Select Case transparent& '                                                     which type of transparency selected?
        Case -2 '                                     (constant AUTOTRANSPARENCY)  auto discover the transparency color
            x% = 0 '                                                               start at upper left x of sheet
            y% = 0 '                                                               start at upper left y of sheet
            _Source sheet(handle%).sheetimage '                                    set the sprite sheet image as the source image
            Do '                                                                   start looping through the sheet's pixels
                pixel& = Point(x%, y%) '                                           get the pixel's color attributes
                alpha& = _Alpha32(pixel&) '                                        get the alpha level (0 - 255)
                If alpha& = 0 Then Exit Do '                                       if it is transparent then leave the loop
                x% = x% + 1 '                                                      move right one pixel
                If x% > sheet(handle%).sheetwidth Then '                           have we gone off the sheet?
                    x% = 0 '                                                       yes, reset back to the left beginning
                    y% = y% + 1 '                                                  move down one pixel
                End If
            Loop Until y% > sheet(handle%).sheetheight '                           don't stop until the entire sheet has been checked
            If alpha& = 0 Then '                                                   did we find a transparent pixel?
                sheet(handle%).transparent = pixel& '                              yes, set the sheet's transparency to this color
            Else '                                                                 there was no transparent pixel found
                sheet(handle%).transparent = -1 '                                  set as having no transparency layer
            End If
            _Source 0 '                                                            set the source back to the screen
        Case -1 '                                     (constant NOTRANSPARENCY)    sheet has no transparency layer
            sheet(handle%).transparent = -1 '                                      set as having no transparency layer
        Case Else '                                                                transparency layer specified by programmer
            sheet(handle%).transparent = transparent& '                            set transparency layer color
    End Select
    SPRITESHEETLOAD = handle% '                                                    return the handle number pointing to this sheet

End Function

'##################################################################################################################################

Function SPRITEFILEEXISTS (filename$)
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Checks for the existance of the file specified.                            |                     - NOTES -                     |
    '|                                                                            | - If the file does not exist the temporary file   |
    '| Usage : exists% = SPRITEFILEEXISTS("sprites.png")                          |   created by the function will be erased.         |
    '|                                                                            | - It is ok to add the drive letter and path       |
    '| Input : filename$ - the name of the file to check for existance.           |   before the actual file name.                    |
    '|                                                                            | - This function may soon be replaced by the newly |
    '| Output: Boolean value of 0 (false) if not exist and -1 (true) if exists.   |   announced _FILEEXISTS command to be released.   |
    '+----------------------------------------------------------------------------+---------------------------------------------------+
    '| Credits: This code was adapted from a posting on QB64's forum on June 21st of 2010. Clippy made the suggestion of writing this |
    '|          function a better way, which was incorporated: http://www.qb64.net/forum/index.php?topic=997.0                        |
    '+--------------------------------------------------------------------------------------------------------------------------------+

    Dim filenum% '                                                                 the file access number of file to open

    filenum% = FreeFile '                                                          get the next available free file access number

    SPRITEFILEEXISTS = -1 '                                                        assume the file exists
    Open filename$ For Append As #filenum% '                                       open the file for append access
    If LOF(filenum%) Then '                                                        does the file contain any data?
        Close #filenum% '                                                          yes, it exists, close the file
    Else '                                                                         no, the file contains no data
        Close #filenum% '                                                          close the file
        SPRITEFILEEXISTS = 0 '                                                     report that the file does not exist
        Kill filename$ '                                                           clean the drive of temporary file created
    End If

End Function

'##################################################################################################################################
'+----------------------------------------------------------------------------+---------------------------------------------------+
'| <blank>                                                                    |                     - NOTES -                     |
'|                                                                            | -                                                 |
'| Usage :                                                                    |                                                   |
'|                                                                            |                                                   |
'| Input :                                                                    |                                                   |
'|                                                                            |                                                   |
'| Output:                                                                    |                                                   |
'+----------------------------------------------------------------------------+---------------------------------------------------+
'| Credits:                                                                                                                       |
'|                                                                                                                                |
'+--------------------------------------------------------------------------------------------------------------------------------+
