'GUI TEST PROGRAM
'Used to test functionality of GUI library

'$INCLUDE:'library/gui.bi'

$CONSOLE

GUI_init

ON ERROR GOTO DEBUG_ONERROR

gui_num = 25

DIM event AS GUI_event_generic
DIM m_event AS GUI_event_mouse
DIM menu_event AS GUI_event_element_menu
DIM k_event AS GUI_event_key
DIM basic_event AS GUI_event_element_basic
DIM radio_group AS GUI_event_element_radio_button_group

GUI_init_event event

DIM main_gui(gui_num) AS GUI_element 'create 25 GUI elements
DIM buttons(3) AS INTEGER
DIM labels(4) AS INTEGER 'Will hold the GUI numbers for 4 labels we have
DIM click_count(3) AS INTEGER
DIM base_menu(4) AS GUI_menu_item
'DIM sub_menus(5, 10) as GUI_menu_item
DIM file_menu(10) AS GUI_menu_item
DIM file_new_menu(10) AS GUI_menu_item
DIM file_new_csrc_menu(10) AS GUI_menu_item
DIM file_new_csrc_csrc_menu(10) AS GUI_menu_item
DIM file_new_csrc_csrc_csrc_menu(10) AS GUI_menu_item
DIM edit_menu(10) AS GUI_menu_item
DIM search_menu(10) AS GUI_menu_item
DIM tools_menu(10) AS GUI_menu_item
DIM help_menu(10) AS GUI_menu_item

'GUI(1) is our main dialog box and is going to be
g = 1
GUI_menu_init main_gui(g)
'main_gui(g).element_type = GUI_MENU
'GUI_init_element main_gui(g), "Menu"

main_gui(g).menu_padding = 2
main_gui(g).flags = main_gui(g).flags OR GUI_FLAG_SKIP OR GUI_FLAG_SHADOW OR GUI_FLAG_MENU_LAST_ON_RIGHT

m = 0
MEM_put_str base_menu(1).nam, "#File": base_menu(1).ident = "File "

m = m + 1: MEM_put_str file_menu(m).nam, "#New            ": file_menu(m).ident = "NEW  "
m = m + 1: MEM_put_str file_menu(m).nam, "#Open": file_menu(m).ident = "OPEN "
m = m + 1: MEM_put_str file_menu(m).nam, "#Connect": file_menu(m).ident = "CONEC"
m = m + 1: MEM_put_str file_menu(m).nam, "-": file_menu(m).ident = "-----"
m = m + 1: MEM_put_str file_menu(m).nam, "#Save": file_menu(m).ident = "SAVE "
m = m + 1: MEM_put_str file_menu(m).nam, "S#ave As": file_menu(m).ident = "SAVEA"
m = m + 1: MEM_put_str file_menu(m).nam, "-": file_menu(m).ident = "-----"
m = m + 1: MEM_put_str file_menu(m).nam, "#Exit": file_menu(m).ident = "EXIT "
GUI_attach_menu base_menu(1), m, _OFFSET(file_menu(1))

sm = sm + 1: MEM_put_str file_new_menu(sm).nam, "#C Source       ": file_new_menu(sm).ident = "CSRC "
sm = sm + 1: MEM_put_str file_new_menu(sm).nam, "C++ #Source     ": file_new_menu(sm).ident = "CPPSR"
sm = sm + 1: MEM_put_str file_new_menu(sm).nam, "-": file_new_menu(sm).ident = "-----"
sm = sm + 1: MEM_put_str file_new_menu(sm).nam, "#Plain Text     ": file_new_menu(sm).ident = "PLAIN"

GUI_attach_menu file_menu(2), sm, _OFFSET(file_new_menu(1))

sm = 0
sm = sm + 1: MEM_put_str file_new_csrc_menu(sm).nam, "#C Source       ": file_new_csrc_menu(sm).ident = "CSRC "
sm = sm + 1: MEM_put_str file_new_csrc_menu(sm).nam, "C++ #Source     ": file_new_csrc_menu(sm).ident = "CPPSR"
sm = sm + 1: MEM_put_str file_new_csrc_menu(sm).nam, "-": file_new_csrc_menu(sm).ident = "-----"
sm = sm + 1: MEM_put_str file_new_csrc_menu(sm).nam, "#Plain Text     ": file_new_csrc_menu(sm).ident = "PLAIN"

GUI_attach_menu file_new_menu(2), sm, _OFFSET(file_new_csrc_menu(1))

sm = 0
sm = sm + 1: MEM_put_str file_new_csrc_csrc_menu(sm).nam, "#C Source       ": file_new_csrc_csrc_menu(sm).ident = "CSRC "
sm = sm + 1: MEM_put_str file_new_csrc_csrc_menu(sm).nam, "C++ #Source     ": file_new_csrc_csrc_menu(sm).ident = "CPPSR"
sm = sm + 1: MEM_put_str file_new_csrc_csrc_menu(sm).nam, "-": file_new_csrc_csrc_menu(sm).ident = "-----"
sm = sm + 1: MEM_put_str file_new_csrc_csrc_menu(sm).nam, "#Plain Text     ": file_new_csrc_csrc_menu(sm).ident = "PLAIN"

GUI_attach_menu file_new_menu(4), sm, _OFFSET(file_new_csrc_csrc_menu(1))

sm = 0
sm = sm + 1: MEM_put_str file_new_csrc_csrc_csrc_menu(sm).nam, "#C Source       ": file_new_csrc_csrc_csrc_menu(sm).ident = "CSRC "
sm = sm + 1: MEM_put_str file_new_csrc_csrc_csrc_menu(sm).nam, "C++ #Source     ": file_new_csrc_csrc_csrc_menu(sm).ident = "CPPSR"
sm = sm + 1: MEM_put_str file_new_csrc_csrc_csrc_menu(sm).nam, "-": file_new_csrc_csrc_csrc_menu(sm).ident = "-----"
sm = sm + 1: MEM_put_str file_new_csrc_csrc_csrc_menu(sm).nam, "#Plain Text     ": file_new_csrc_csrc_csrc_menu(sm).ident = "PLAIN"

GUI_attach_menu file_new_csrc_csrc_menu(2), sm, _OFFSET(file_new_csrc_csrc_csrc_menu(1))


m = 0
MEM_put_str base_menu(2).nam, "#Edit": base_menu(2).ident = "Edit "

m = m + 1: MEM_put_str edit_menu(m).nam, "#Cut            ": edit_menu(m).ident = "CUT  "
m = m + 1: MEM_put_str edit_menu(m).nam, "C#opy": edit_menu(m).ident = "COPY "
m = m + 1: MEM_put_str edit_menu(m).nam, "#Paste": edit_menu(m).ident = "PASTE"
m = m + 1: MEM_put_str edit_menu(m).nam, "#Delete": edit_menu(m).ident = "DELET"
m = m + 1: MEM_put_str edit_menu(m).nam, "-": edit_menu(m).ident = "-----"
m = m + 1: MEM_put_str edit_menu(m).nam, "#Rename": edit_menu(m).ident = "RENAM"
m = m + 1: MEM_put_str edit_menu(m).nam, "#Select All": edit_menu(m).ident = "SELAL"
GUI_attach_menu base_menu(2), m, _OFFSET(edit_menu(1))

m = 0
MEM_put_str base_menu(3).nam, "#Search": base_menu(3).ident = "Searc"

m = m + 1: MEM_put_str search_menu(m).nam, "#Find           ": search_menu(m).ident = "FIND "
m = m + 1: MEM_put_str search_menu(m).nam, "Find #Next": search_menu(m).ident = "FINDN"
m = m + 1: MEM_put_str search_menu(m).nam, "Find #Previous": search_menu(m).ident = "FINDP"
m = m + 1: MEM_put_str search_menu(m).nam, "-": search_menu(m).ident = "-----"
m = m + 1: MEM_put_str search_menu(m).nam, "#Replace": search_menu(m).ident = "REPLA"
GUI_attach_menu base_menu(3), m, _OFFSET(search_menu(1))

m = 0
MEM_put_str base_menu(4).nam, "#Help": base_menu(4).ident = "Help "

m = m + 1: MEM_put_str help_menu(m).nam, "#Help           ": help_menu(m).ident = "HELP "
m = m + 1: MEM_put_str help_menu(m).nam, "-": help_menu(m).ident = "-----"
m = m + 1: MEM_put_str help_menu(m).nam, "#About     ": help_menu(m).ident = "ABOUT"
GUI_attach_menu base_menu(4), m, _OFFSET(help_menu(1))

GUI_attach_base_menu main_gui(g), 4, _OFFSET(base_menu(1))

g = g + 1
GUI_box_init main_gui(g)
MEM_put_str main_gui(g).nam, "Plain Box"
'main_gui(g).element_type = GUI_BOX
'GUI_init_element main_gui(g), "Plain Box"
main_gui(g).layer = -1 ' -- Set in background. Layer 0 is the default
' -- We don't want to be able to TAB to this gui element
' -- Don't draw box characters or box name, etc.
main_gui(g).flags = main_gui(g).flags OR GUI_FLAG_SKIP OR GUI_FLAG_HIDE

g = g + 1
GUI_input_box_init main_gui(g)
MEM_put_str main_gui(g).nam, "Input Box"
'main_gui(g).element_type = GUI_INPUT_BOX
'GUI_init_element main_gui(g), "Input Box"


g = g + 1
GUI_list_box_init main_gui(g)
MEM_put_str main_gui(g).nam, "List Box"
'main_gui(g).element_type = GUI_LIST_BOX
'GUI_init_element main_gui(g), "List Box"
main_gui(g).flags = main_gui(g).flags OR GUI_FLAG_SCROLL_V
list_Box = g

MEM_allocate_string_array main_gui(g).lines, 120
main_gui(g).length = 80
FOR x = 1 TO 80
    MEM_put_str_array main_gui(g).lines, x, "Str:" + STR$(x)
NEXT x
list_box_n = g
'main_gui(g).scroll_max_hors = 90 'Max horisontal column to scroll to

g = g + 1
GUI_checkbox_init main_gui(g)
MEM_put_str main_gui(g).nam, "CheckBox1"
'main_gui(g).element_type = GUI_CHECKBOX 'Initalize a few Checkbox's
'GUI_init_element main_gui(g), "CheckBox1"


g = g + 1
GUI_checkbox_init main_gui(g)
MEM_put_str main_gui(g).nam, "CheckBox2"

'main_gui(g).element_type = GUI_CHECKBOX 'Same as the last one
'GUI_init_element main_gui(g), "CheckBox2"

g = g + 1
GUI_button_init main_gui(g)
MEM_put_str main_gui(g).nam, "Button"
'main_gui(g).element_type = GUI_BUTTON 'Initalize some buttons -- Virtually the same as buttons
'GUI_init_element main_gui(g), "Button"
buttons(1) = g 'Store main_gui() number for later use

g = g + 1
GUI_button_init main_gui(g)
MEM_put_str main_gui(g).nam, "Button2"
'main_gui(g).element_type = GUI_BUTTON 'Same as before
'GUI_init_element main_gui(g), "Button2"
buttons(2) = g

g = g + 1
GUI_button_init main_gui(g)
MEM_put_str main_gui(g).nam, "Button3"
'main_gui(g).element_type = GUI_BUTTON 'Same as before
'GUI_init_element main_gui(g), "Button3"
buttons(3) = g


g = g + 1
GUI_drop_down_init main_gui(g)
MEM_put_str main_gui(g).nam, "Drop Down"
'main_gui(g).element_type = GUI_DROP_DOWN 'Initalize a drop-down selection
'GUI_init_element main_gui(g), "Drop Down"

'Just vertical scroll (No hoisontal)
'Draws shadow under box when drop-down is opened
main_gui(g).flags = main_gui(g).flags OR GUI_FLAG_SCROLL_V OR GUI_FLAG_SHADOW
main_gui(g).selected = 1 'Set the default selected item
'allocate space for the items in the drop-down
MEM_allocate_string_array main_gui(g).lines, 80
main_gui(g).length = 80 'Set the actual number of items in the drop down
FOR x = 1 TO 80 'Fill array with some items
    MEM_put_str_array main_gui(g).lines, x, "Str:" + STR$(x)
NEXT x


g = g + 1
GUI_drop_down_init main_gui(g)
MEM_put_str main_gui(g).nam, "Drop Down"
'main_gui(g).element_type = GUI_DROP_DOWN 'Almost exactly the same as before
'GUI_init_element main_gui(g), "Drop Down"
main_gui(g).flags = main_gui(g).flags OR GUI_FLAG_SCROLL_V OR GUI_FLAG_SHADOW
main_gui(g).selected = 1
MEM_allocate_string_array main_gui(g).lines, 80
main_gui(g).length = 80
FOR x = 1 TO 80
    MEM_put_str_array main_gui(g).lines, x, "Str:" + STR$(x)
NEXT x

FOR x = 1 TO 4 'group 0
    g = g + 1
    GUI_radio_button_init main_gui(g)
    MEM_put_str main_gui(g).nam, "Radio Button" + STR$(x)
    'main_gui(g).element_type = GUI_RADIO_BUTTON 'Initalize 4 radio buttons linked by their group number
    'GUI_init_element main_gui(g), "Radio Button" + str$(x)
NEXT x

FOR x = 1 TO 4 'group 1
    g = g + 1
    GUI_radio_button_init main_gui(g)
    MEM_put_str main_gui(g).nam, "Radio Button" + STR$(x)
    'main_gui(g).element_type = GUI_RADIO_BUTTON 'Same as before, but different group number
    'GUI_init_element main_gui(g), "Radio Button" + str$(x)
    main_gui(g).group = 1
NEXT x

FOR x = 1 TO 4
    g = g + 1
    GUI_label_init main_gui(g)
    'main_gui(g).element_type = GUI_LABEL 'Initalize 4 lables via a loop
    'GUI_init_element main_gui(g), ""
    MEM_put_str main_gui(g).text, "Label 1"
    labels(x) = g 'Store it's main_gui() element number for later use
NEXT x

g = g + 1
GUI_text_box_init main_gui(g)
MEM_put_str main_gui(g).nam, "Text Box"
'main_gui(g).element_type = GUI_TEXT_BOX 'Initalize a Text-Box
'GUI_init_element main_gui(g), "Text Box"
main_gui(g).flags = main_gui(g).flags OR GUI_FLAG_SCROLL_V OR GUI_FLAG_SCROLL_H
'We allocate 120 Lines for the array (main_gui(g).lines won't be allocated for you, but it may be reallocated if you allow it)
'Just set this to a reasonable value for your program.
MEM_allocate_string_array main_gui(g).lines, 120
'Setting this to zero (It's default) means main_gui(g).lines will be reallocated if needed
'The user could technically use all his memory if he allocates to many lines
'But he'll probably reach the max value for an INTEGER before that happens...
main_gui(g).max_lines = 0
main_gui(g).length = 10 'Only display 10 lines since only 10 lines will have data in the beginning
'Length will be dynamically changed based on the input (If a line is deleted, for instance, length will go down)
'Length will never go higher then max_lines though, unless max_lines = 0.
'You can set length without putting anything into the MEM_string_type's  in the main_gui(g).lines array

'scroll_max_hors represents the max hosisontal scroll distance (Or, the max length of each string you display)
main_gui(g).scroll_max_hors = 120

FOR x = 1 TO 10 'Fill the first 10 lines with some data.
    MEM_put_str_array main_gui(g).lines, x, "Str:" + STR$(x)
NEXT x

g = g + 1
GUI_input_box_init main_gui(g)
MEM_put_str main_gui(g).nam, "Input Box"
'main_gui(g).element_type = GUI_INPUT_BOX 'One extra Input box for good measure ;)
'GUI_init_element main_gui(g), "Input Box"

'Initialize placement
setup_gui main_gui()

'selected_gui = 0 'First selected gui element
selected_gui = list_Box
DO 'Main loop

    'Reduce CPU usage
    ' -- May need to be increased if there are tons of GUI elements, but low numbers seem to do fine
    ' -- This program has 25 GUI elements, probably more then you'll ever come across, so with that in mind
    ' The Limit doesn't need to be that big.
    _LIMIT 250

    'Check if we should update screen because an event happened or otherwise
    IF GUI_update_screen(main_gui(), gui_num, selected_gui) THEN
        'Redraw screen (May be improved in the future but currently redraws the entire screen)
        GUI_draw_element_array main_gui(), gui_num, selected_gui
    END IF

    GUI_handle_events

    DO WHILE GUI_events_in_queue
        GUI_read_event main_gui(), gui_num, selected_gui, event
        'GUI_debug_output "Reading event: " + str$(event.event_type)
        SELECT CASE event.event_type
            CASE GUI_EVENT_MOUSE
                GUI_get_mouse_event event, m_event
                IF ((m_event.count - 1) MOD 2) + 1 = 2 THEN
                    IF m_event.flags AND GUI_EVENT_MOUSE_LEFT_CLICK THEN
                        debug_print "Double Left click!"
                    ELSEIF m_event.flags AND GUI_EVENT_MOUSE_RIGHT_CLICK THEN
                        debug_print "Double Right Click!"
                    ELSEIF m_event.flags AND GUI_EVENT_MOUSE_MIDDLE_CLICK THEN
                        debug_print "Double Middle Click!"
                    END IF
                ELSEIF m_event.flags AND GUI_EVENT_MOUSE_SCROLL_DOWN OR m_event.flags AND GUI_EVENT_MOUSE_SCROLL_UP THEN
                    debug_print "Scroll detected"
                END IF
      
            CASE GUI_EVENT_KEY
                GUI_get_key_event event, k_event
                debug_print "Key event! : " + STR$(k_event.key_code)
                IF k_event.flags AND GUI_EVENT_KEY_TYPED THEN
                    MEM_put_str main_gui(labels(4)).text, CHR$(k_event.key_code)
                    main_gui(labels(4)).flags = main_gui(labels(4)).flags OR GUI_FLAG_UPDATED
                ELSEIF k_event.flags AND GUI_EVENT_KEY_RELEASED AND k_event.key_code = 27 THEN
                    exit_flag = -1
                END IF
        
            CASE GUI_EVENT_ELEMENT_BASIC
                GUI_get_element_basic_event event, basic_event
                IF basic_event.e_type = GUI_LABEL THEN
                    IF basic_event.flags AND GUI_EVENT_ELEMENT_LABEL_PRESSED THEN
                        IF ((basic_event.m_event.count - 1) MOD 2) + 1 = 2 THEN
                            MEM_put_str main_gui(labels(4)).text, "Label " + STR$(basic_event.gui_element) + " Double Clicked on!"
                        ELSE
                            MEM_put_str main_gui(labels(4)).text, "Label " + STR$(basic_event.gui_element) + " Clicked on!"
                        END IF
                        main_gui(labels(4)).flags = main_gui(labels(4)).flags OR GUI_FLAG_UPDATED
                    END IF
                ELSEIF basic_event.e_type = GUI_BUTTON THEN
                    IF basic_event.flags AND GUI_EVENT_ELEMENT_BUTTON_PRESSED THEN
                        MEM_put_str main_gui(labels(4)).text, "Button " + STR$(basic_event.gui_element) + " Was clicked"
                        main_gui(labels(4)).flags = main_gui(labels(4)).flags OR GUI_FLAG_UPDATED
                    END IF
                ELSEIF basic_event.e_type = GUI_LIST_BOX THEN
                    debug_print "Recieved list event!"
                    IF basic_event.flags AND GUI_EVENT_ELEMENT_LIST_BOX_PRESSED THEN
                        debug_print "Pressed event"
                        IF (basic_event.flags AND GUI_EVENT_ELEMENT_LIST_BOX_KEY_DOWN) OR (basic_event.flags AND GUI_EVENT_ELEMENT_LIST_BOX_CLICKED AND basic_event.m_event.count = 2) THEN
                            debug_print "Modifying label..."
                            MEM_put_str main_gui(labels(4)).text, "List box item " + STR$(main_gui(basic_event.gui_element).selected) + " was chosen!"
                            main_gui(labels(4)).flags = main_gui(labels(4)).flags OR GUI_FLAG_UPDATED
                        END IF
                    END IF
                ELSEIF basic_event.e_type = GUI_DROP_DOWN THEN
                    debug_print "Recieved drop down event!"
                    IF basic_event.flags AND GUI_EVENT_ELEMENT_DROP_DOWN_SEL_CHANGED THEN
                        MEM_put_str main_gui(labels(4)).text, "Drop Down item " + STR$(main_gui(basic_event.gui_element).selected) + " was chosen!"
                    END IF
                ELSEIF basic_event.e_type = GUI_CHECKBOX THEN
                    IF basic_event.flags AND GUI_EVENT_ELEMENT_CHECKBOX_CHANGED THEN
                        IF main_gui(basic_event.gui_element).flags AND GUI_FLAG_CHECKED THEN
                            MEM_put_str main_gui(labels(4)).text, "Checkbox #" + LTRIM$(RTRIM$(STR$(basic_event.gui_element))) + " was checked!"
                        ELSE
                            MEM_put_str main_gui(labels(4)).text, "Checkbox #" + LTRIM$(RTRIM$(STR$(basic_event.gui_element))) + " was unchecked!"
                        END IF
                    END IF
                END IF

            CASE GUI_EVENT_ELEMENT_MENU
                GUI_get_element_menu_event event, menu_event
                debug_print "Menu event recieved!"
                IF menu_event.flags AND GUI_EVENT_ELEMENT_MENU_SELECTED THEN
                    MEM_put_str main_gui(labels(4)).text, "Menu item " + menu_event.mident + " was selected!"
                    main_gui(labels(4)).flags = main_gui(labels(4)).flags OR GUI_FLAG_UPDATED
                    IF menu_event.mident = "EXIT " THEN exit_flag = -1
                END IF

            CASE GUI_EVENT_ELEMENT_RADIO_BUTTON_GROUP
                GUI_get_element_radio_b_g_event event, radio_group
                debug_print "Radio event recieved!"
                IF radio_group.flags AND GUI_EVENT_ELEMENT_RADIO_B_G_CHANGED THEN
                    MEM_put_str main_gui(labels(4)).text, "GUI" + STR$(radio_group.gui_element) + " from group" + STR$(radio_group.group) + " selected!"
                    main_gui(labels(4)).flags = main_gui(labels(4)).flags OR GUI_FLAG_UPDATED
                END IF

        END SELECT
    LOOP

    'Mouse events
    'GUI_mouse_range main_gui(), gui_num, selected_gui, event
  
    'if event.event_type > 0 then
    '  if event.event_type = GUI_EVENT_MOUSE then
    '    GUI_get_mouse_event event, m_event
    '  elseif event.event_type = GUI_EVENT_KEY then
    '    GUI_get_key_event event, k_event
    '  end if
    'end if

    'Keyboard input events
    'Returns the INKEY$ result it got in-case you want to do extra actions
    ' -- For this reason don't use INKEY$ or _MOUSEINPUT outside of the GUI functions
    'key$ = GUI_inkey$(main_gui(), gui_num, selected_gui)

    'SELECT CASE key$ 'In this example I'll do extra checking for the ESC key.
    '  CASE CHR$(27) 'ESC key
    '    exit_flag = -1
    'END SELECT

    'manage interactions here.
    'for x = 1 to 3 'This loop checks the three buttons we have
    '  if buttons(x) = g_clicked then
    '    click_count(x) = click_count(x) + 1
    '    'We're setting the string in a label and then marking it to be updated
    '    MEM_put_str main_gui(labels(x)).text, "Button" + str$(x) + " :" + str$(click_count(x)) + " Times!"
    '    'main_gui(labels(x)).updated = -1
    '    main_gui(labels(x)).flags = main_gui(labels(x)).flags OR GUI_FLAG_UPDATED
    '    'main_gui(buttons(x)).pressed = 0 'Reset the button to 0 so we don't end up catching it a second time
    '  end if
    'next x
    'if main_gui(1).flags AND GUI_FLAG_MENU_CHOSEN then 'Check our menu
    '  MEM_put_str main_gui(labels(4)).text, "Menu Chosen: " + main_gui(1).menu_choice
    '  main_gui(1).flags = main_gui(1).flags AND NOT GUI_FLAG_MENU_CHOSEN 'Reset the menu so we don't enter this IF again
    '  i$ = main_gui(1).menu_choice
    '  'main_gui(1).updated = -1 'set menu to updated
    '  main_gui(1).flags = main_gui(1).flags OR GUI_FLAG_UPDATED
    '  'Redraw screen so menu doesn't show before opening menu choice
    '  GUI_draw_element_array main_gui(), gui_num, selected_gui

    '  if i$ = "EXIT " then exit_flag = -1 '"EXIT " is for the EXIT menu option -- So set our exit_flag variable
    '  if i$ = "ABOUT" then
    '    'about_dialog
    '  end if
    '  if i$ = "RENAM" then
    '    'rename_file_GUI 0
    '  end if
    '  if i$ = "OPEN " then
    '    'prompt = prompt_dialog("Test Dialog"+chr$(13) + "Line 2", 10, OK_BUTTON OR CLOSE_BUTTON, OK_BUTTON)
    '  end if
    '  if i$ = "CONEC" then
    '    'Connect_To_FTP
    '  end if
    '  if i$ = "HELP " then
    '    'popup_dialog_gui "Not Implemented Yet."
    '  end if
    'end if
  
    'if _RESIZE then
    '  WIDTH _RESIZEWIDTH, _RESIZEHEIGHT
    '  setup_gui main_gui()
    '  main_gui(2).flags = main_gui(2).flags OR GUI_FLAG_UPDATED
  
    'end if
LOOP UNTIL exit_flag = -1 OR _EXIT

'Free the array of elements
GUI_free_element_array main_gui()
'GUI_free_event event

SYSTEM

DEBUG_ONERROR:
COLOR 7, 0
CLS
PRINT "ERROR N:"; ERR
PRINT "ERROR L:"; _ERRORLINE

END

SUB debug_print (p$)
    _DEST _CONSOLE
    PRINT p$
    _DEST 0
END SUB

SUB setup_gui (main_gui() AS GUI_element)
    g = 1 'Menu
    main_gui(g).row1 = 1
    main_gui(g).col1 = 1
    main_gui(g).col2 = _WIDTH(0)

    g = g + 1 'Background box
    main_gui(g).row1 = 2 'location
    main_gui(g).row2 = _HEIGHT(0)
    main_gui(g).col1 = 1
    main_gui(g).col2 = _WIDTH(0)

    g = g + 1 'Inbox box
    main_gui(g).row1 = 2
    main_gui(g).col1 = 1
    main_gui(g).col2 = _WIDTH(0) \ 2

    g = g + 1 'List box
    main_gui(g).row1 = 2
    main_gui(g).row2 = 10
    main_gui(g).col1 = _WIDTH(0) \ 2 + 1
    main_gui(g).col2 = _WIDTH(0)

    g = g + 1 'Checkbox 1
    main_gui(g).row1 = 6 'Location
    main_gui(g).col1 = 2

    g = g + 1 'Checkbox 2
    main_gui(g).row1 = 6
    main_gui(g).col1 = _WIDTH(0) \ 4

    g = g + 1 'Button 1
    main_gui(g).row1 = 7 'Location
    main_gui(g).col1 = 2 '((_WIDTH(0) \ 2) \ 3) - main_gui(g).nam.length \ 2

    g = g + 1 'Button 2
    main_gui(g).row1 = 7
    main_gui(g).col1 = ((_WIDTH(0) \ 2) \ 3) - main_gui(g).nam.length \ 2

    g = g + 1 'Button 3
    main_gui(g).row1 = 7
    main_gui(g).col1 = ((_WIDTH(0) \ 2) \ 3) * 2 - main_gui(g).nam.length \ 2

    g = g + 1 'Drop Down 1
    main_gui(g).row1 = 8
    main_gui(g).col1 = 2
    main_gui(g).row2 = 15 '<-- These cords will be used to draw the drop-down box when it is open
    main_gui(g).col2 = _WIDTH(0) \ 2 '<--

    g = g + 1 'Drop Down 2
    main_gui(g).row1 = 9
    main_gui(g).col1 = 2
    main_gui(g).row2 = _HEIGHT(0) - 1 'A larger row2 value will result in a bigger drop-down box
    main_gui(g).col2 = _WIDTH(0) \ 2

    FOR x = 1 TO 4
        g = g + 1 'Radio buttons
        main_gui(g).row1 = 9 + x
        main_gui(g).col1 = 2
    NEXT x

    FOR x = 1 TO 4
        g = g + 1 'Radio buttons
        main_gui(g).row1 = 14 + x
        main_gui(g).col1 = 2
    NEXT x

    FOR x = 1 TO 4
        g = g + 1 'Labels
        main_gui(g).row1 = 18 + x
        main_gui(g).col1 = 2
    NEXT x

    g = g + 1 'Text box
    main_gui(g).row1 = 11 'location
    main_gui(g).row2 = 22
    main_gui(g).col1 = _WIDTH(0) \ 2 + 1
    main_gui(g).col2 = _WIDTH(0)

    g = g + 1 'Input box
    main_gui(g).row1 = 23
    main_gui(g).col1 = 1
    main_gui(g).col2 = _WIDTH(0)

END SUB

'$INCLUDE:'library/gui.bm'
