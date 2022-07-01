'******************************************************************************
'*                                                                            *
'* GLINPUT Libary v2.10 06/13/12 by Terry Ritchie                             *
'*                                                                            *
'* Documentation Demo Program #2 - GLICURRENT and GLIFORCE example            *
'*                                                                            *
'* Sets up an input array                                                     *
'*                                                                            *
'******************************************************************************

'$INCLUDE:'glinputtop.bi'

CONST FALSE = 0, TRUE = NOT FALSE ' set up boolean constants

TYPE INFORMATION
    response AS STRING * 255 '      contains the text typed in
    info AS STRING * 80 '           general info to user using program
    allow AS INTEGER '              allowed input for each field
    required AS INTEGER '           field is/is not required (boolean)
END TYPE

REDIM question(0) AS INFORMATION '  set up array
DIM wallpaper& '                    animated background image
DIM x%, y% '                        location of circles when creating background
DIM count% '                        generic counter
DIM required% '                     true when a field is required
DIM requiredinput% '                which input field is currently required
DIM handle% '                       handle of newly created input field

wallpaper& = _NEWIMAGE(640, 528, 32) '                                         create background image container
_DEST wallpaper& '                                                             set destination to this image
LINE (0, 0)-(639, 527), _RGB32(0, 0, 127), BF '                                fill the image with dark blue
FOR y% = 1 TO 11 '                                                             cycle through y circle locations
    FOR x% = 1 TO 13 '                                                         cycle through x circle locations
        CIRCLE (x% * 48 - 17, y% * 48 - 24), 24, _RGB32(0, 0, 0) '             draw evenly spaced circles on image
        PAINT (x% * 48 - 17, y% * 48 - 24), _RGB32(0, 0, 96), _RGB32(0, 0, 0) 'paint the circles slightly darker blue
    NEXT x%
NEXT y%
SCREEN _NEWIMAGE(640, 480, 32) '                                               create a new 32bit screen
_SCREENMOVE _MIDDLE '                                                          move to middle of user's desktop
_TITLE "Customer Database" '                                                   give the window a title
_PUTIMAGE (0, 0), wallpaper& '                                                 place the background image on screen
FOR count% = 1 TO 13 '                                                         cycle through DATA statements
    READ text$, info$, allow%, required% '                                     get data from one line of DATA
    IF required% THEN '                                                        is this question required?
        COLOR _RGB32(255, 255, 255) '                                          yes, question color will be white
    ELSE '                                                                     no, this question is not required
        COLOR _RGB(255, 255, 0) '                                              question color will be yellow
    END IF
    handle% = GLIINPUT(180, (count% + 3) * 16, allow%, text$, TRUE) '          create graphics input
    IF handle% > UBOUND(question) THEN '                                       is this handle larger than array?
        REDIM _PRESERVE question(handle%) AS INFORMATION '                     yes, increase size of array to handle
    END IF
    question(handle%).info = info$ '                                           populate array with required data
    question(handle%).allow = allow%
    question(handle%).required = required%
    question(handle%).response = ""
NEXT count%
y% = 0 '                                                                       reset background image y location
required% = FALSE '                                                            reset required field flag
DO '                                                                           start of main program loop
    DO
        GLICLEAR '                                                             remove all graphic inputs from screen
        _LIMIT 32 '                                                            limit loop to 32 times per second
        y% = y% - 1 '                                                          decrement background image location
        IF y% = -48 THEN y% = 0 '                                              gone too far? If so reset image location
        _PUTIMAGE (0, y%), wallpaper& '                                        place background image on screen
        _PRINTMODE _KEEPBACKGROUND '                                           all text printed should save background
        COLOR _RGB32(0, 255, 255) '                                            set color to bright cyan
        _PRINTSTRING (190, 20), "ENTER CUSTOMER INFORMATION BELOW" '           display header on screen
        _PRINTSTRING (319 - (_PRINTWIDTH(RTRIM$(question(GLICURRENT).info))_
            \ 2), 280), question(GLICURRENT).info '                            center input field info on screen
        _PRINTSTRING (145, 320), "PRESS ESC WHEN FINISHED ENTERING INFORMATION" 'inform user how to exit inputs
        COLOR _RGB32(255, 255, 0) '                                            set color to yellow
        _PRINTSTRING (210, 340), "(yellow fields are optional)" '              inform user which fields are optional
        question(GLICURRENT).response = GLIOUTPUT$(GLICURRENT) '               save user inputs in real time
        IF required% AND GLICURRENT = requiredinput% THEN '                    was this field skipped and required?
            COLOR _RGB32(255, 0, 0) '                                          set color to bright red
            _PRINTSTRING (210, 400), "** THIS FIELD IS REQUIRED **" '          inform user this field is reuired
        END IF
        GLIUPDATE '                                                            update all graphic inputs on screen
        _DISPLAY '                                                             display current state of screen
    LOOP UNTIL INKEY$ = CHR$(27) '                                             keep looping until ESC pressed
    required% = FALSE '                                                        reset required flag
    FOR count% = 1 TO UBOUND(question) '                                       cycle through input array
        IF RTRIM$(question(count%).response) = "" AND_
            question(count%).required THEN '                                   was a required field left blank?
            BEEP '                                                             yes, get user's attention
            required% = TRUE '                                                 set required flag
            requiredinput% = count% '                                          remember which input is required
            GLIFORCE count% '                                                  force cursor to this input
            EXIT FOR '                                                         leave FOR...NEXT loop
        END IF
    NEXT count%
LOOP UNTIL NOT required% '                                                     keep looping until all required have been entered
GLICLOSE 0, TRUE '                                                             close all inputs and remove from screen
_DISPLAY

DATA "First Name: ","Please enter customer's first name",1,-1
DATA "Last Name : ","Please enter customer's last name",1,-1
DATA "Address   : ","Please enter customer's street address",7,-1
DATA "City      : ","Please enter customer's city of residence",1,-1
DATA "State     : ","Please enter customer's state of residence",65,-1
DATA "Zip Code  : ","Please enter customer's city zip code",10,-1
DATA "Home Phone: ","Please enter customer's home phone number",26,-1
DATA "Work Phone: ","Please enter customer's work phone number",26,0
DATA "Cell Phone: ","Please enter customer's cell phone number",26,0
DATA "Email     : ","Please enter customer's email address",7,0
DATA "Password  : ","Please enter customer's password",131,-1
DATA "Age       : ","Please enter customer's age",2,0
DATA "Married?  : ","Please enter customer's marital status (Y or N)",65,0

'$INCLUDE:'glinput.bi'

