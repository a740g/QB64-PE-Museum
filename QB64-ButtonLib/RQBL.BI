'******************************************************************************
'* Ritchie's QB64 Button Library                                              *
'* V1.0 - 06/21/2011                                                          *
'*                                                                            *
'* This library has been distributed as freeware. If you make any changes to  *
'* the code and wish to have it considered in an update, please email your    *
'* changes to the author at:                                                  *
'*                                                                            *
'* terry.ritchie@gmail.com                                                    *
'*                                                                            *
'* Proper credit will be given for your submission.                           *
'*                                                                            *
'* If you use this library in your project please credit the author.          *
'*                                                                            *
'* Credits:                                                                   *
'*                                                                            *
'* - Galleon, the creator of QB64, allowing old school programmers to keep    *
'*   their QuickBasic programming craft alive.                                *
'*                                                                            *
'* - All forum members of QB64.NET, for their never ending help to the QB64   *
'*   community.                                                               *
'*                                                                            *
'* Documentation:                                                             *
'*                                                                            *
'* - See RQBLV10.PDF for command syntax and use.                              *
'*                                                                            *
'* History:                                                                   *
'*                                                                            *
'* - 06/21/2011: Version 1.0 released                                         *
'*                                                                            *
'* Reporting errors and bugs: terry.ritchie@gmail.com                         *
'******************************************************************************
'
'RQBL.BI - functions and subroutines TO BE INCLUDED AT THE BOTTOM OF YOUR CODE
'
'##############################################################################

SUB BUTTONSHOW (bh%) '                                           Error Checking

'******************************************************************************
'* Shows a button on screen that is currently hidden.                         *
'*                                                                            *
'* bh% - Handle number of button to show.                                     *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONSHOW", bh% '                           any handle errors?
IF NOT bi(bh%).show THEN '                                not currently shown?
    bi(bh%).show = 1 '                                    now showing on screen
    BUTTONPUT bi(bh%).x, bi(bh%).y, bh% '                 show button on screen
END IF

END SUB

'##############################################################################

SUB BUTTONHIDE (bh%) '                                           Error Checking

'******************************************************************************
'* Hides a button currently shown on screen.                                  *
'*                                                                            *
'* bh% - Handle number of button to hide.                                     *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONHIDE", bh% '                           any handle errors?
IF bi(bh%).show THEN '                                    currently on screen?
    _PUTIMAGE (bi(bh%).x, bi(bh%).y), bi(bh%).bg '        restore background
    bi(bh%).show = 0 '                                    not showing on screen
END IF

END SUB

'##############################################################################

SUB BUTTONOFF (bh%) '                                            Error Checking

'******************************************************************************
'* Toggles the button to a depressed state.                                   *
'*                                                                            *
'* bh% - Handle number of button to press.                                    *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONOFF", bh% '                            any handle errors?
bi(bh%).state = 0 '                                       depress button
BUTTONPUT bi(bh%).x, bi(bh%).y, bh% '                     update button image

END SUB

'##############################################################################

SUB BUTTONON (bh%) '                                             Error Checking

'******************************************************************************
'* Toggles the button to a pressed state.                                     *
'*                                                                            *
'* bh% - Handle number of button to press.                                    *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONON", bh% '                             any handle errors?
bi(bh%).state = -1 '                                      press button
BUTTONPUT bi(bh%).x, bi(bh%).y, bh% '                     update button image

END SUB

'##############################################################################

SUB BUTTONTOGGLE (bh%) '                                         Error Checking

'******************************************************************************
'* Toggles the button specified between pressed/depressed.                    *
'*                                                                            *
'* bh% - Handle number of button to toggle.                                   *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONTOGGLE", bh% '                         any handle errors?
bi(bh%).state = NOT bi(bh%).state '                       toggle button's state
BUTTONPUT bi(bh%).x, bi(bh%).y, bh% '                     update button image

END SUB

'##############################################################################

FUNCTION BUTTONEVENT (bh%) '                                     Error Checking

'******************************************************************************
'* Returns the status of a button's mouse/button interaction.                 *
'*                                                                            *
'* bh% = The button handle number to retrieve the status from.                *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONEVENT", bh% '                          any handle errors?
BUTTONEVENT = bi(bh%).mouse '                             return mouse status

END FUNCTION

'##############################################################################

SUB BUTTONCHECKING (bc%) STATIC '

'******************************************************************************
'* Turns automatic button checking on or off. (local variables static)        *
'*                                                                            *
'* bc% - true (-1) = turn checking on.                                        *
'*       false (0) = turn checking off.                                       *
'*                                                                            *
'* Note: The first time this routine is called with true (-1) an event timer  *
'*       is created and turned on. Subsequent calls with true (-1) will       *
'*       simply turn the event timer on if it is currently off.               *
'******************************************************************************

DIM created% '                                            first time creation
DIM ct% '                                                 event checking timer

SHARED bchecking% '                                       button check status

IF bc% THEN '                                             true? checking on
    IF NOT created% THEN '                                is timer created?
        ct% = _FREETIMER '                                no, get timer handle
        ON TIMER(ct%, .05) BUTTONUPDATE '                 set timer event
        created% = -1 '                                   timer now created
    END IF
    IF NOT bchecking% THEN TIMER(ct%) ON '                timer on already?
    bchecking% = -1 '                                     other routines know
ELSE
    IF created% AND bchecking% THEN '                     timer made and on?
        TIMER(ct%) OFF '                                  yes, timer event off
        bchecking% = 0 '                                  other routines know
    END IF
END IF

END SUB

'##############################################################################

SUB BUTTONUPDATE ()

'******************************************************************************
'* Checks the status of the buttons in relation to the mouse pointer.         *
'*                                                                            *
'* Sets each buttons .mouse element to the following conditions:              *
'*   0 - no mouse event.                                                      *
'*   1 - left mouse button clicked on button.                                 *
'*   2 - right mouse button clicked on button.                                *
'*   3 - mouse hovering over button.                                          *
'*                                                                            *
'* Note: This subroutine is called automatically if button checking is turned *
'*       on. If button checking is turned off the user can still call this    *
'*       subroutine manually to get updates on mouse/button interaction.      *
'******************************************************************************

DIM bh% '                                                 button handle counter
DIM ev% '                                                 current mouse event

SHARED bi() AS bi '                                       button defining array

DO: LOOP WHILE _MOUSEINPUT '                              get last mouse event
ev% = 3 '                                                 assume hovering
IF _MOUSEBUTTON(1) THEN ev% = 1 '                         left button clicked
IF _MOUSEBUTTON(2) THEN ev% = 2 '                         right button cicked
FOR bh% = 1 TO UBOUND(bi) '                               test pointer boundary
    IF bi(bh%).inuse AND bi(bh%).show THEN '              used and on screen?
        IF (_MOUSEX >= bi(bh%).x) AND (_MOUSEX <= bi(bh%).x + bi(bh%).xs - 1) AND (_MOUSEY >= bi(bh%).y) AND (_MOUSEY <= bi(bh%).y + bi(bh%).ys - 1) THEN
            bi(bh%).mouse = ev% '                         is in boundary, set
        ELSE '                                            not button boundary
            bi(bh%).mouse = 0 '                           no event to set
        END IF
    END IF
NEXT bh%

END SUB

'##############################################################################

FUNCTION BUTTONHEIGHT (bh%) '                                    Error Checking

'******************************************************************************
'* Returns the height of a button handle.                                     *
'*                                                                            *
'* bh% - Handle number of button to get height from.                          *
'*                                                                            *
'* returns: Integer value indicating the height of the button.                *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONHEIGHT", bh% '                         any handle errors?
BUTTONHEIGHT = bi(bh%).ys '                               return button height

END FUNCTION

'##############################################################################

FUNCTION BUTTONWIDTH (bh%) '                                     Error Checking

'******************************************************************************
'* Returns the width of a button handle.                                      *
'*                                                                            *
'* bh% - Handle number of button to get width from.                           *
'*                                                                            *
'* returns: Integer value indicating the width of the button.                 *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONWIDTH", bh% '                          any handle errors?
BUTTONWIDTH = bi(bh%).xs '                                return button width

END FUNCTION

'##############################################################################

FUNCTION BUTTONCOPY (bh%) '                                      Error Checking

'******************************************************************************
'* Duplicates a button handle from a designated handle.                       *
'*                                                                            *
'* bh% - Handle number of button to duplicate.                                *
'*                                                                            *
'* returns: Integer value greater than 0 indicating the new button's handle.  *
'******************************************************************************

DIM nh% '                                                 new button handle num

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONCOPY", bh% '                           any handle errors?
nh% = BUTTONNEW("~", 0, 0, 0) '                           get new handle number
bi(nh%) = bi(bh%) '                                       new button properties  ///// this may be a problem - copying background?? not freeing properly?
bi(bh%).shown = 0 '                                       never been on screen
bi(bh%).show = 0 '                                        not showing on screen
BUTTONCOPY = nh% '                                        return hew handle num

END FUNCTION

'##############################################################################

SUB BUTTONFREE (bh%) '                                           Error Checking

'******************************************************************************
'* Removes a button from the screen, restores the background image and frees  *
'* any resources the button was using.                                        *
'*                                                                            *
'* bh% - Handle number of button to free.                                     *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONFREE", bh% '                           any handle errors?
IF bi(bh%).show THEN '                                    is button on screen?
    _PUTIMAGE (bi(bh%).x, bi(bh%).y), bi(bh%).bg '        restore background
    _FREEIMAGE bi(bh%).bg '                               free image memory
END IF
IF bh% = UBOUND(bi) AND bh% <> 1 THEN '                   button last element?
    REDIM _PRESERVE bi(bh% - 1) AS bi '                   decrease array size
ELSE '                                                    not last element
    bi(bh%).inuse = 0 '                                   not in use any more
    bi(bh%).show = 0 '                                    not showing on screen
    bi(bh%).shown = 0 '                                   never been on screen
    bi(bh%).state = 0 '                                   reset button state
    bi(bh%).text = "" '                                   remove any text
END IF

END SUB

'##############################################################################

SUB BUTTONPUT (x%, y%, bh%) '                                    Error Checking

'******************************************************************************
'* Places, moves or refreshes a button on the screen.                         *
'*                                                                            *
'* x%  - x location of button.                                                *
'* y%  - y location of button.                                                *
'* bh% - Handle number of button to place.                                    *
'*                                                                            *
'* Note: The first time a handle is called the button will be placed on the   *
'*       screen. Subsequent calls to the same handle will move the button to  *
'*       a new location, restoring the background at the old position. If a   *
'*       handle is called at the same coordinates as a previous call, the     *
'*       button is simply refreshed on the screen.                            *
'******************************************************************************

SHARED bi() AS bi '                                       button defining array

BUTTONERROR "BUTTONPUT", bh% '                            any handle errors?
IF bi(bh%).show THEN '                                    is button on screen?
    _PUTIMAGE (bi(bh%).x, bi(bh%).y), bi(bh%).bg '        restore background
END IF
IF NOT ((bi(bh%).x = x%) AND (bi(bh%).y = y%)) THEN '     button x,y change?
    IF NOT bi(bh%).shown THEN '                           shown for 1st time?
        bi(bh%).shown = -1 '                              set 1st time showing
        bi(bh%).show = -1 '                               now showing on screen
        bi(bh%).bg = _NEWIMAGE(bi(bh%).xs, bi(bh%).ys, 32) 'background holder
    END IF
    bi(bh%).x = x% '                                      save new x location
    bi(bh%).y = y% '                                      save new y location
    '                                                     get background image
    _PUTIMAGE , _DEST, bi(bh%).bg, (x%, y%)-(x% + bi(bh%).xs - 1, y% + bi(bh%).ys - 1)
END IF
IF bi(bh%).show THEN '                                    is button on screen?
    IF bi(bh%).state THEN '                               is button pressed?
        _PUTIMAGE (x%, y%), bi(bh%).in '                  draw button pressed
    ELSE '                                                button is not pressed
        _PUTIMAGE (x%, y%), bi(bh%).out '                 draw button depressed
    END IF
END IF

END SUB

'##############################################################################

FUNCTION BUTTONNEW (bname$, xs%, ys%, bcolor&)

'******************************************************************************
'* Creates a new button either internally or from a file set                  *
'*                                                                            *
'* bname$  - File name of button set to load. If set to null the button will  *
'*           be created from an internal generic button creator. If not null  *
'*           the button images will be loaded from a graphic file set that    *
'*           contains the button images. Example: "mybutton" would load       *
'*           mybutton0.png as the depressed image and mybutton1.png as the    *
'*           pressed image.                                                   *
'* xs%     - The width of the button. This value is ignored if a valid        *
'*           filename is provided through bname$.                             *
'* ys%     - The height of the button. This value is ignored if a valid       *
'*           filename is provided through bname$.                             *
'* bcolor& - The color of the button. This value is ignored if a valid        *
'*           filename is provided through bname$.                             *
'*                                                                            *
'* returns:  Integer value greater than 0 indicating the button's handle.     *
'*                                                                            *
'* Note:     If the button specified in bname$ does not exist then a generic  *
'*           button will be created from xsize%, ysize% and bcolor& to take   *
'*           the place of the missing button file. This can either be viewed  *
'*           as a failsafe feature or allow the coder to concentrate on the   *
'*           code and the button graphics later.                              *
'*                                                                            *
'* NEED TO FIX: Custom button creation routine is half baked. The buttons     *
'*              look "ok", but the routine could really use the touch of a    *
'*              good graphics programmer.                                     *
'******************************************************************************

DIM bh% '                             handle number of button to be passed back
DIM scr& '                            holds the handle of the current screen
DIM cred&, newred& '                  red color value used in button creation
DIM cgreen&, newgreen& '              green color value used in button creation
DIM cblue&, newblue& '                blue color value used in button creation

SHARED bi() AS bi '                                       button defining array

bh% = 0 '                                                 init button handle
DO '                                                      find available handle
    bh% = bh% + 1 '                                       inc handle number
LOOP UNTIL (NOT bi(bh%).inuse) OR bh% = UBOUND(bi) '      test handle value
IF bi(bh%).inuse THEN '                                   last one in use?
    bh% = bh% + 1 '                                       use next handle
    REDIM _PRESERVE bi(bh%) AS bi '                       increase array size
END IF
bi(bh%).inuse = -1 '                                      mark as in use
bi(bh%).state = 0 '                                       mark as out
bi(bh%).x = -32767 '                                      set low for first use
bi(bh%).y = -32767 '                                      set low for first use
IF bname$ <> "~" THEN '                                   called by routine?
    IF bname$ = "" OR (NOT BUTTONEXISTS(bname$)) THEN '   make generic button?
        bi(bh%).out = _NEWIMAGE(xs%, ys%, 32) '           generic gfx
        bi(bh%).in = _NEWIMAGE(xs%, ys%, 32) '            generic gfx
        bi(bh%).xs = xs% '                                width of button
        bi(bh%).ys = ys% '                                height of button
        scr& = _DEST '                                    current screen handle
        _DEST bi(bh%).out '                               new image destination
        '\\\
        'Generic button creation routine - needs work! \\\\\\\\\\\\\\\\\\\\\\\\
        '///
        cred& = _RED(bcolor&)
        cgreen& = _GREEN(bcolor&)
        cblue& = _BLUE(bcolor&)
        CLS , bcolor&
        newred& = cred& + 64: IF newred& > 255 THEN newred& = 255
        newgreen& = cgreen& + 64: IF newgreen& > 255 THEN newgreen& = 255
        newblue& = cblue& + 64: IF newblue& > 255 THEN newblue& = 255
        LINE (0, ys% - 2)-(0, 0), _RGB(newred&, newgreen&, newblue&)
        LINE -(xs% - 2, 0), _RGB(newred&, newgreen&, newblue&)
        newred& = cred& + 32: IF newred& > 255 THEN newred& = 255
        newgreen& = cgreen& + 32: IF newgreen& > 255 THEN newgreen& = 255
        newblue& = cblue& + 32: IF newblue& > 255 THEN newblue& = 255
        LINE (1, ys% - 3)-(1, 1), _RGB(newred&, newgreen&, newblue&)
        LINE -(xs% - 3, 1), _RGB(newred&, newgreen&, newblue&)
        newred& = cred& - 64: IF newred& < 0 THEN newred& = 0
        newgreen& = cgreen& - 64: IF newgreen& < 0 THEN newgreen& = 0
        newblue& = cblue& - 64: IF newblue& < 0 THEN newblue& = 0
        LINE (0, ys% - 1)-(xs% - 1, ys% - 1), _RGB(newred&, newgreen&, newblue&)
        LINE -(xs% - 1, 0), _RGB(newred&, newgreen&, newblue&)
        newred& = cred& - 32: IF newred& < 0 THEN newred& = 0
        newgreen& = cgreen& - 32: IF newgreen& < 0 THEN newgreen& = 0
        newblue& = cblue& - 32: IF newblue& < 0 THEN newblue& = 0
        LINE (1, ys% - 2)-(xs% - 2, ys% - 2), _RGB(newred&, newgreen&, newblue&)
        LINE -(xs% - 2, 1), _RGB(newred&, newgreen&, newblue&)
        _DEST bi(bh%).in
        _PUTIMAGE (bi(bh%).xs - 1, bi(bh%).ys - 1)-(0, 0), bi(bh%).out
        _DEST scr&
        '\\\
        'End generic button creation routine \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
        '///
    ELSE
        bi(bh%).out = _LOADIMAGE(bname$ + "0.png", 32) '  button depressed
        bi(bh%).in = _LOADIMAGE(bname$ + "1.png", 32) '   button pressed
        bi(bh%).xs = _WIDTH(bi(bh%).out) '                button width
        bi(bh%).ys = _HEIGHT(bi(bh%).out) '               button height
    END IF
END IF
BUTTONNEW = bh% '                                         return handle number

END FUNCTION

'############################################################################

FUNCTION BUTTONEXISTS (bname$)

'******************************************************************************
'* Tests for the existance of both button .PNG graphic images.                *
'*                                                                            *
'* bname$ - The name of the file to test for. Do not include an extension to  *
'*          the file name. "0.png" and "1.png" will be appended to the file   *
'*          name.                                                             *
'*                                                                            *
'* Returns: -1 (true)  = Both button graphic images exist.                    *
'*           0 (false) = One or both of the graphic images do not exist.      *
'******************************************************************************

DIM freefan1% '                               next available file access number
DIM freefan2% '                               next available file access number

BUTTONEXISTS = -1 '                                       assume files exist
freefan1% = FREEFILE '                                    get free file number
OPEN bname$ + "0.png" FOR APPEND AS #freefan1% '          open depressed image
freefan2% = FREEFILE '                                    get free file number
OPEN bname$ + "1.png" FOR APPEND AS #freefan2% '          open pressed image
IF LOF(freefan1%) THEN '                                  first file present?
    CLOSE #freefan1% '                                    yes, close file
ELSE '                                                    does not exist
    CLOSE #freefan1% '                                    close first file
    BUTTONEXISTS = 0 '                                    report back not exist
    KILL bname$ + "0.png" '                               clean up temp file
END IF
IF LOF(freefan2%) THEN '                                  second file present?
    CLOSE #freefan2% '                                    yes, close file
ELSE '                                                    does not exist
    CLOSE #freefan2% '                                    close file
    BUTTONEXISTS = 0 '                                    report back not exist
    KILL bname$ + "1.png" '                               clean up temp file
END IF

END FUNCTION

'##############################################################################

SUB BUTTONERROR (routine$, bh%)

'******************************************************************************
'* Reports handle errors found in button routines.                            *
'*                                                                            *
'* routine$ - The name of the routine currently testing for handle errors.    *
'* bh%      - The handle number being tested.                                 *
'******************************************************************************

DIM terminate% '                                          termination flag
DIM errorname$ '                                          hold name of error

SHARED bi() AS bi '                                       button defining array

IF bh% > UBOUND(bi) THEN '                                handle too large?
    terminate% = -1 '                                     yes, flag as error
    errorname$ = "handle number passed is too large." '   set error type
ELSEIF bh% < 1 THEN '                                     handle too small?
    terminate% = -1 '                                     yes, flag as error
    errorname$ = "handle number passed is less than 1." ' set error type
ELSEIF NOT bi(bh%).inuse THEN '                           handle not in use?
    terminate% = -1 '                                     yes, flag as error
    errorname$ = "handle number passed is not in use." '  set error type
END IF
IF terminate% THEN '                                      is an error flagged?
    SCREEN 0 '                                            yes, basic screen
    _FONT 16 '                                            set basic font
    PRINT '                                               report the error
    PRINT "************************"
    PRINT "* Button Library Error *"
    PRINT "************************"
    PRINT
    PRINT routine$; ": "; errorname$
    SLEEP '                                               wait for keystroke
    SYSTEM '                                              terminate now
END IF

END SUB
