OPTION _EXPLICIT '                                            no typos for variables if you please
_TITLE "Drop Menu more 2 function test" '                                            b+ 2023-06-27
'                                                                      Instigated by Dimster here:
'                         https://qb64phoenix.com/forum/showthread...7#pid17117
'    More! = 1. Highlite mouse overs  2. Handle extra long menu descriptions up to .5 screen width
'               So sorry Ultraman, no tool tips but extra long descriptions is better than nutt'n.

CONST ButtonW = 100, ButtonH = 20 '                   basic rectangle size for title of menu panel
TYPE BoxType '                                             to be used for MouseZone click checking
    AS STRING Label '                                                                   menu title
    AS LONG LeftX, TopY, BoxW, BoxH '                  left most, top most , box width, box height
END TYPE

DIM SHARED AS INTEGER NBoxes '                                           setting up a demo in main
NBoxes = 72 '                                                     exorbinant amount of menu titles
DIM SHARED Boxes(1 TO NBoxes) AS BoxType '                     data array for positions and labels
DIM AS INTEGER i, x, y, mz, nItems, choice '         index, positions, menu count, choice selected
REDIM menu$(1 TO 1) '                                     dynamic array to store quick menu's into
DIM s$ '                                                                         a string variable

SCREEN _NEWIMAGE(800, 600, 32) '                                                      screen stuff
_SCREENMOVE 250, 50 '   somewhere in middle of my laptop, you may prefer to change for your screen
_PRINTMODE _KEEPBACKGROUND '                               preserve background when printing stuff
CLS '                                           so we have solid black background for image saving

x = 0: y = 0 '                         set up boxes                   x, y for top left box corner
FOR i = 1 TO NBoxes
    Boxes(i).Label = "Box" + STR$(i) '                                            quick menu title
    Boxes(i).LeftX = x: Boxes(i).TopY = y '                                        top left corner
    Boxes(i).BoxW = ButtonW '                                        width to constant set for all
    Boxes(i).BoxH = ButtonH '                                       height to constant set for all
    IF (x + 2 * ButtonW) > _WIDTH THEN '           spread out the menu titles left right, top down
        x = 0: y = y + ButtonH '                     next title didn't fit across so start new row
    ELSE
        x = x + ButtonW '                                                        fits going across
    END IF
    DrawTitleBox i '                                                     draw the menu title panel
NEXT

DO
    mz = MouseZone% '                          reports which menu panel has been clicked and mouse
    IF mz THEN '                              quick make up a list of items for the menu title box
        nItems = INT(RND * 10) + 1 '                                 pick random 1 to 10 inclusive
        REDIM menu$(1 TO nItems) '                                          resize menu$ by nItems
        FOR i = 1 TO nItems '                                          menu option and description
            s$ = "Box" + STR$(mz) + " Menu Item:" + STR$(i) '               still needs to be less
            s$ = s$ + " with extra, extra, long description." '               than .5 screen width
            menu$(i) = s$ '                         item is described with fairly good width to it
        NEXT '                                                      his was alternate to tool tips
        choice = getButtonNumberChoice%(Boxes(mz).LeftX, Boxes(mz).TopY, menu$())
        IF choice = 0 THEN s$ = "You quit menu by clicking outside of it." ELSE s$ = menu$(choice)
        _MESSAGEBOX "Drop Menu Test", "Your Menu Choice was: " + s$, "info"
    END IF
    _LIMIT 30
LOOP UNTIL _KEYDOWN(27)

SUB DrawTitleBox (i) '                 draw a box according to shared Boxes array then print label
    LINE (Boxes(i).LeftX + 1, Boxes(i).TopY + 1)-STEP(ButtonW - 2, ButtonH - 2), &HFF550088, BF
    COLOR &HFFFFFFFF
    _PrintString (Boxes(i).LeftX + (ButtonW - _PrintWidth(Boxes(i).Label)) / 2, _
    Boxes(i).TopY + ButtonH / 2 - 8), Boxes(i).Label
END SUB

SUB DrawChoiceBox (highliteTF%, leftX, topY, BoxW AS INTEGER, S$) ' draw menu items for menu title
    IF highliteTF% THEN '                                reverse colors as mouse is over this item
        LINE (leftX, topY)-STEP(BoxW, ButtonH), &HFFAAAAAA, BF
        COLOR &HFF333333
        _PRINTSTRING (leftX + (BoxW - _PRINTWIDTH(S$)) / 2, topY + ButtonH / 2 - 8), S$
    ELSE
        LINE (leftX, topY)-STEP(BoxW, ButtonH), &HFF333333, BF
        COLOR &HFFAAAAAA
        _PRINTSTRING (leftX + (BoxW - _PRINTWIDTH(S$)) / 2, topY + ButtonH / 2 - 8), S$
    END IF
    LINE (leftX, topY)-STEP(BoxW, ButtonH), &HFF000000, B '             draw black box around item
END SUB

FUNCTION MouseZone% '                   returns the Shared Boxes() index clicked or 0 none clicked
    '                      Set the following up in your Main code of app
    'Type BoxType '                                         to be used for mouse click checking
    '   As Long LeftX, TopY, BoxW, BoxH '            left most, top most, box width, box height
    'End Type
    'Dim Shared As Integer NBoxes
    'Dim Shared Boxes(1 To NBoxes) As BoxType

    DIM AS INTEGER i, mb, mx, my

    WHILE _MOUSEINPUT: WEND '                                                           poll mouse
    mb = _MOUSEBUTTON(1) '                                                  looking for left click
    IF mb THEN
        _DELAY .25
        mx = _MOUSEX: my = _MOUSEY '                                        get the mouse position
        FOR i = 1 TO NBoxes '        see if its in a menu tile box from data in Shared Boxes array
            IF mx > Boxes(i).LeftX AND mx < Boxes(i).LeftX + Boxes(i).BoxW THEN
                IF my > Boxes(i).TopY AND my < Boxes(i).TopY + Boxes(i).BoxH THEN
                    MouseZone% = i: EXIT FUNCTION '                  yes a click in this box index
                END IF
            END IF
        NEXT
    END IF
END FUNCTION

FUNCTION getButtonNumberChoice% (BoxX AS INTEGER, BoxY AS INTEGER, choice$())
    '           This fucion uses Sub DrawChoiceBox (highliteTF%, leftX, topY, BoxW As Integer, S$)
    '                                     BoxX, BoxY are top left corner from the Menu Title Panel
    '                                           We will be drawing our Menu Items below that panel
    DIM AS INTEGER ub, lb, b '          choice$() boundaries and an index, b, to run through items
    DIM AS INTEGER longest '                             find the longest string length in choices
    DIM AS INTEGER menuW, menuX '  use menuWidth and menuX start box side so long menu strings fit
    DIM AS INTEGER mx, my, mb '                           mouse status of position and left button
    DIM AS LONG save '       we are saving the whole screen before drop down to redraw after click
    DIM AS LONG drawerDown '           save drawer down after animate dropping drawers for Dimster

    ub = UBOUND(choice$): lb = LBOUND(choice$) '                                  array boundaries
    FOR b = lb TO ub '                                               find longest string in choice
        IF LEN(choice$(b)) > longest THEN longest = LEN(choice$(b))
    NEXT
    IF (longest + 2) * 8 > ButtonW THEN '           don't use default button Width string too long
        menuW = (longest + 2) * 8 '             calculate the needed width, up to half screen fits
        IF BoxX < _WIDTH / 2 - 3 THEN '          -3 ?? wouldn't work right until took 3 off middle
            menuX = BoxX '                                  use the same left side of box to start
        ELSE
            menuX = BoxX + ButtonW - menuW '   right side box align minus menu width = x start box
        END IF
    ELSE
        menuW = ButtonW '                 use default sizes that fit nicely under menu title panel
        menuX = BoxX
    END IF
    save = _NEWIMAGE(_WIDTH, _HEIGHT, 32) '         save our beautiful screen before dropping menu
    _PUTIMAGE , 0, save

    '                                                         Animate dropping drawers for Dimster
    FOR b = lb TO ub ' clear any previous highlites
        DrawChoiceBox 0, menuX, BoxY + b * ButtonH, menuW, choice$(b)
        _DISPLAY
        _LIMIT 5
    NEXT
    drawerDown = _NEWIMAGE(_WIDTH, _HEIGHT, 32) '    save our beautiful screen after dropping menu
    _PUTIMAGE , 0, drawerDown

    DO '                                                                until a mouse click occurs
        _PUTIMAGE , drawerDown, 0 '             actually this is better to clear screen with image
        WHILE _MOUSEINPUT: WEND '                                                       poll mouse
        mx = _MOUSEX: my = _MOUSEY: mb = _MOUSEBUTTON(1)
        FOR b = lb TO ub '                scan through the box dimension to see if mouse is in one
            IF mx > menuX AND mx <= menuX + menuW THEN
                IF my >= BoxY + b * ButtonH AND my <= BoxY + b * ButtonH + ButtonH THEN
                    IF mb THEN '                                                  item is clicked!
                        _PUTIMAGE , save, 0 '                             put image of screen back
                        _FREEIMAGE save '                 throw out screen image so no memory leak
                        _FREEIMAGE drawerDown
                        '              delay before exit to give user time to release mouse button
                        '                               set function, restore autodisplay and exit
                        getButtonNumberChoice% = b: _DELAY .25: _AUTODISPLAY: EXIT FUNCTION
                    ELSE
                        '           indicate mouse over this menu item! draw highlight in box = -1
                        DrawChoiceBox -1, menuX, BoxY + b * ButtonH, menuW, choice$(b)
                        _DISPLAY
                    END IF
                END IF
            END IF
        NEXT
        IF mb THEN '                                   there was a click outside the menu = cancel
            _PUTIMAGE , save, 0 '                           put image before dropdown draw back up
            _FREEIMAGE save '                            leaving sub avoid memory leak, dump image
            _FREEIMAGE drawerDown
            '                          delay before exit to give user time to release mouse button
            '                                           set function, restore autodisplay and exit
            getButtonNumberChoice% = 0: _DELAY .25: _AUTODISPLAY: EXIT FUNCTION
        END IF
        _DISPLAY '     display was needed here to avoid blinking when redrawing the highlited item
        '_Limit 60
    LOOP '                                                              until a mouse click occurs
END FUNCTION
