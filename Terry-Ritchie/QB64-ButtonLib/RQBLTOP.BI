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
'RQBLTOP.BI
'
'Contains declarations - NNEDS TO BE INCLUDED AT THE TOP OF YOUR CODE
'
TYPE bi '                 button information
    x AS INTEGER '        x location of button      (set by BUTTONPUT)
    y AS INTEGER '        y location of button      (set by BUTTONPUT)
    xs AS INTEGER '       x size (width) of button  (set by BUTTONNEW)
    ys AS INTEGER '       y size (height) of button (set by BUTTONNEW)
    out AS LONG '         depressed image of button (set by BUTTONNEW, BUTTONFREE)
    in AS LONG '          pressed image of button   (set by BUTTONNEW, BUTTONFREE)
    bg AS LONG '          image behind button       (set by BUTTONPUT, BUTTONFREE)
    state AS INTEGER '    state of button           (set by BUTTONNEW, BUTTONTOGGLE)
    inuse AS INTEGER '    button is in use          (set by BUTTONNEW, BUTTONFREE)
    text AS STRING * 64 ' text of button            (set by ButtonText)
    fsize AS INTEGER '    font size of button       (set by ButtonText)
    font AS STRING * 64 ' font name of button       (set by ButtonText)
    shown AS INTEGER '    button shown first time   (set by BUTTONPUT)
    show AS INTEGER '     button on screen?         (set by BUTTONPUT)
    mouse AS INTEGER '    mouse status of button (1-left, 2-right, 3-hover)
END TYPE

REDIM bi(1) AS bi '                           array defining button information
DIM bchecking% '                              button checking status
