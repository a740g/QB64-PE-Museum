'FTP Client
'Matt Kilgore -- 2011/2013

'This program is free software, without any warranty of any kind.
'You are free to edit, copy, modify, and redistribute it under the terms
'of the Do What You Want Public License, Version 1, as published by Matt Kilgore
'See file COPYING that should have been included with this source.

'Basically -- You just do what you want. It's fairly simple.
'I wouldn't mind a mention if you use this code, but it's by no means required.

'DECLARE LIBRARY "SDLNet_Temp_Header"
'    FUNCTION bytes_left& (a AS LONG)
'END DECLARE

'DECLARE LIBRARY
'  FUNCTION fopen%& (file_name as string, mode as string) 'Mode "w" will create an empty file for writing
'END DECLARE

'Thanks to DAV and the Wiki for this code
'DECLARE LIBRARY
'  FUNCTION GetLogicalDriveStringsA(BYVAL nBuff AS LONG, lpbuff AS STRING)
'END DECLARE

$SCREENHIDE
$CONSOLE

CONST BOXES = 3 'Don't change
CONST g_menu_c = 5 'Number of global menu choices

CONST VER$ = "0.96"

'variable length strings via _MEM

TYPE string_type
    mem AS _MEM
    length AS LONG
    allocated AS LONG
    is_allocated AS _BYTE
END TYPE

TYPE array_type
    mem AS _MEM
    length AS LONG
    allocated AS LONG
    is_allocated AS _BYTE
    element_size AS INTEGER
END TYPE

TYPE box_type
    nam AS string_type

    row1 AS INTEGER 'location
    col1 AS INTEGER
    row2 AS INTEGER 'row2 not used for button/checkbox. for drop_down, it represents the number of rows in the selection box
    col2 AS INTEGER

    c1 AS _BYTE 'forcolor
    c2 AS _BYTE 'backcolor

    sc1 AS _BYTE 'selected color. -- not always used
    sc2 AS _BYTE

    text_box AS _BYTE '-1 then drawn as textbox (input box) -- always as row2 = row1 + 2
    text AS string_type 'text drawn inside the textbox
    text_position AS INTEGER 'position of the cursor
    text_offset AS INTEGER 'We display the string in the box starting at the text_offset character, to account for scrolling to the right
    hide AS _BYTE 'text will be drawn as "****" instead of "test"

    scroll AS _BYTE 'if -1 then scroll is drawn
    scroll_loc AS INTEGER 'various numbers needed to draw scroll

    multi_text_box AS _BYTE '-1 then drawn as a multiple line text-box (Not editable)
    selected AS INTEGER 'the line that is selected (Will be drawn in sc1,sc2

    length AS INTEGER 'number of options (now use multi_line.length

    offset AS INTEGER 'offset from the beginning that we will draw from
    shadow AS _BYTE 'if -1 then a shadow is drawn around the box

    button AS _BYTE 'if -1 then drawn as button.

    checkbox AS _BYTE 'if -1 then drawn as checkbox
    checked AS _BYTE 'represents checkbox state

    drop_down AS _BYTE 'drawn as drop_down.
    d_flag AS _BYTE 'if d_flag then dropdown box is drawn

    drop_row2 AS INTEGER 'bottom location of dropdown box

    menu AS _BYTE

    updated AS INTEGER 'if set, then information about this box has been updated

    multi_line AS array_type 'string array for multi-line text boxes
END TYPE

TYPE filedir_type
    'NOTE to myself -- GET RID OF DIR, not needed (Just check the flags, replace DIR in the printing sub, etc..
    dir AS STRING * 3 ' = "DIR" or "LNK" or ""
    nam AS string_type
    flag_cwd AS INTEGER 'dir flag
    flag_retr AS INTEGER 'file flag
    size AS LONG
    lin AS string_type
END TYPE

CONST OK_BUTTON = 1 'for prompt_dialog
CONST NO_BUTTON = 2
CONST CANCEL_BUTTON = 4
CONST CLOSE_BUTTON = 8
CONST YES_BUTTON = 16

COMMON SHARED scrnw, scrnh, scrn&
COMMON SHARED command_connect&, data_connect&, server$, username$, password$, port$
COMMON SHARED Remote_dir$, Local_dir$, temp_dir$
COMMON SHARED server_syst$
COMMON SHARED opper$, mx AS INTEGER, my AS INTEGER, but, mtimer AS SINGLE, mscroll AS SINGLE
COMMON SHARED locrow, loccol, butflag AS INTEGER
COMMON SHARED is_connected AS INTEGER, main_menu_len AS INTEGER, status$, crlf$, cmd$
COMMON SHARED pasv_mode AS INTEGER, cmd_mode AS INTEGER, err_flag, cmd_count
COMMON SHARED show_hidden_local AS INTEGER, show_hidden_remote AS INTEGER

COMMON SHARED main_gui_c1 AS INTEGER, main_gui_c2 AS INTEGER
COMMON SHARED main_gui_sel_c1 AS INTEGER, main_gui_sel_c2 AS INTEGER
COMMON SHARED status_c1 AS INTEGER, status_c2 AS INTEGER
COMMON SHARED menu_c1 AS INTEGER, menu_c2 AS INTEGER
COMMON SHARED menu_sel_c1 AS INTEGER, menu_sel_c2 AS INTEGER
COMMON SHARED menu_char_c AS INTEGER, file_non_sel AS INTEGER
COMMON SHARED box_c1 AS INTEGER, box_c2 AS INTEGER
COMMON SHARED box_sel_c1 AS INTEGER, box_sel_c2 AS INTEGER
COMMON SHARED CLI, CONFIG

DIM SHARED boxes(BOXES) AS box_type, selected_box
DIM SHARED Remote_files(500) AS filedir_type, Local_files(1000) AS filedir_type, sep$ 'Change this number for more files
DIM SHARED global_menu_sel, menu_sel, menu_max_len(g_menu_c), temp_menu_sel, menux AS box_type

scrnw = 80 'Default screen size. -- Is overwritten if a Config file is found
scrnh = 25 'Smaller then 80x25 is not recommended or garentied to work

crlf$ = CHR$(13) + CHR$(10)
status$ = "Not Connected."

a$ = "QWERTYUIOP????ASDFGHJKL?????ZXCVBNM" 'Credit to Galleon for the ALT key code stuff.
DIM SHARED alt_codes$(LEN(a$) + 16)
FOR x = 1 TO LEN(a$)
    alt_codes$(x + 15) = MID$(a$, x, 1)
NEXT x

_TITLE "FTP Client -- QB64"

CONFIG = -1 'If 0, it won't check for a config file
CLI = 0 'Start Command Line only if -1.

'colors
main_gui_c1 = 15
main_gui_c2 = 1
main_gui_sel_c1 = 0
main_gui_sel_c2 = 7
file_non_sel = 10
status_c1 = 0
status_c2 = 3
menu_c1 = 0
menu_c2 = 7
menu_sel_c1 = 7
menu_sel_c2 = 0
menu_char_c = 15
box_c1 = 0
box_c2 = 7
box_sel_c1 = 7
box_sel_c2 = 0

IF INSTR(_OS$, "[LINUX]") OR INSTR(_OS$, "[MACOSX]") THEN
    opper$ = "NIX"
    'Local_dir$ = "/" 'Root
    sep$ = "/"
    temp_dir$ = "/tmp"
ELSE
    opper$ = "WIN"
    'Local_dir$ = "C:\" 'C Drive
    sep$ = "\"
    temp_dir$ = ENVIRON$("temp")
END IF

'setup command line help system
RESTORE commands
READ cmd_count
DIM SHARED commands$(cmd_count), help$(cmd_count, 10), helplen(cmd_count)
FOR x = 1 TO cmd_count
    READ cm$
    commands$(x) = cm$
    DO
        READ a$
        IF a$ > "" THEN helplen(x) = helplen(x) + 1: help$(x, helplen(x)) = a$
    LOOP UNTIL a$ = ""
NEXT x
y = cmd_count
DO
    flag = 0
    FOR x = 1 TO y - 1
        IF commands$(x) > commands$(x + 1) THEN
            SWAP commands$(x), commands$(x + 1)
            FOR m = 1 TO 6
                SWAP help$(x, m), help$(x + 1, m)
            NEXT m
            SWAP helplen(x), helplen(x + 1)
            flag = -1
        END IF
    NEXT x
    y = y - 1
LOOP UNTIL flag = 0

'check COMMAND$
IF COMMAND$ > "" THEN
    cmdarg$ = LCASE$(COMMAND$)
    IF INSTR(cmdarg$, "-cli") THEN
        CLI = -1
    END IF
    IF INSTR(cmdarg$, "-gui") THEN
        CLI = 0
    END IF
    IF INSTR(cmdarg$, "-config") THEN
        CONFIG = -1
    END IF
    IF INSTR(cmdarg$, "-noconfig") THEN
        CONFIG = 0
    END IF
    IF INSTR(cmdargs$, "-h") OR INSTR(cmdargs$, "--help") THEN

    END IF
END IF

IF CLI THEN
    command_line
    SYSTEM
ELSE
    _CONSOLE OFF
    _SCREENSHOW
END IF

'Load config file
IF CONFIG THEN
    read_config_file
END IF

LOCATE , , 0
butflag = 0

setup_main_GUI
DIM s AS string_type
allocate_array boxes(1).multi_line, 120, LEN(s)
allocate_array boxes(2).multi_line, 120, LEN(s)

'setup menu

DIM SHARED Global_Menu$(g_menu_c), Menu$(g_menu_c, 9), Menun(g_menu_c)
g = 1
Global_Menu$(g) = " #File ": n = 1
Menu$(g, n) = " #Connect              ": n = n + 1
Menu$(g, n) = " #Disconnect           ": n = n + 1
Menu$(g, n) = " C#ommand Line         ": n = n + 1
Menu$(g, n) = "-": n = n + 1
Menu$(g, n) = " E#xit                 "
Menun(g) = n

g = g + 1: Global_Menu$(g) = " #Local ": n = 1
Menu$(g, n) = " #Refresh Files         ": n = n + 1
Menu$(g, n) = "-": n = n + 1
Menu$(g, n) = " R#ename File           ": n = n + 1
Menu$(g, n) = " #Delete File           ": n = n + 1
Menu$(g, n) = " #Show Hidden           ": n = n + 1
Menu$(g, n) = "-": n = n + 1
Menu$(g, n) = " #Make Directory        ": n = n + 1
Menu$(g, n) = " Re#name Directory      ": n = n + 1
Menu$(g, n) = " De#lete Directory      "
Menun(g) = n

g = g + 1: Global_Menu$(g) = " #Remote ": n = 1
Menu$(g, n) = " #Refresh Files         ": n = n + 1
Menu$(g, n) = "-": n = n + 1
Menu$(g, n) = " R#ename File           ": n = n + 1
Menu$(g, n) = " #Delete File           ": n = n + 1
Menu$(g, n) = " #Show Hidden           ": n = n + 1
Menu$(g, n) = "-": n = n + 1
Menu$(g, n) = " #Makes Directory       ": n = n + 1
Menu$(g, n) = " Re#name Directory      ": n = n + 1
Menu$(g, n) = " De#lete Directory      "
Menun(g) = n

g = g + 1: Global_Menu$(g) = " #Transfer ": n = 1
Menu$(g, n) = " #Send File        ": n = n + 1
Menu$(g, n) = " #Recieve File     "
Menun(g) = n

g = g + 1: Global_Menu$(g) = " #Help ": n = 1
Menu$(g, n) = " #Help                ": n = n + 1
Menu$(g, n) = " #Change Settings     ": n = n + 1
Menu$(g, n) = "-": n = n + 1
Menu$(g, n) = " #About               "
Menun(g) = n

FOR x = 1 TO g_menu_c
    FOR y = 1 TO Menun(x)
        IF LEN(Menu$(x, y)) > menu_max_len(x) THEN
            menu_max_len(x) = LEN(Menu$(x, y))
        END IF
    NEXT y
NEXT x

RANDOMIZE TIMER
status$ = "Not Connected."
main
free_gui_array boxes()
END

error_flag: 'rudimentary error checking. Simple but effective and only requires one error trap
err_flag = -1
RESUME NEXT

commands:
DATA 23
DATA "ECHO","Prints a line of text to the screen."," ","Syntax: ECHO string"," ","Where 'string' is any line of text.",
DATA "DIR","Prints the Remote directory structure"," ","Syntax: DIR [flags|--nlst]"," ","The 'flags' variable is not outlined because It's dependent on the server. What ever is specefied for flags will be passed directly to the server in a LIST command. --nlst forces the client to use NLST instead of LIST. If you don't get any text output or a error from the regular list, try using --nlst. You should note that NLST provides bare Dir/File names where as LIST (The default) Provides much more meaningfull data.",
DATA "CD","Changes the Remote directory"," ","Syntax: CD directory"," ","'directory' is the name of any valid directory on the Remote filesystem. To goto the parent directory, use the command 'CD ..'.",
DATA "PWD","Prints the current Remote directory"," ","Syntax: PWD"," ","PWD outputs the current Remote directory to the screen",
DATA "LDIR","Prints the Local directory structore"," ","Syntax: LDIR [flags]"," ","LDIR shell's out to the default directory list function for the system (ls for  Linux, dir for Windows). As a result, the flags variable is system dependent. The flags variable will be passed to the directory list function directly with no formatting.",
DATA "LCD","Changes the Local directory"," ","Syntax: LCD directory"," ","'directory' is the name of any valid directory on the Local filesystem. To goto the parent directory, use the command 'CD ..'.",
DATA "LPWD","Prints the current Local directory"," ","Syntax: LPWD"," ","LPWD outputs the current Local directory to the screen",
DATA "CONNECT","Used to connect to a FTP server"," ","Syntax: CONNECT [username[:password]@]ftp_server_address[:port]"," ","Using this command will disconnect from a FTP server if you're already connected to one, and then start a connection using the parameters you provided. It uses a FTP URL. You can leave off any of the parameters you wish besides the server address.",
DATA "DISCON","Used to disconnect from a FTP server"," ","Sytax: DISCON"," ","DISCON is used to disconnect for the current FTP server. (If the client is not connected then this command does nothing). This command is automatically done if you close the Client window or use the CONNECT command when you're already connected.",
DATA "PUT","Used to send a file to the FTP server"," ","Syntax: PUT Local_file_name"," ","PUT will send the file to the Current Remote directory (Assuming the FTP server allows you to do that).",
DATA "GET","Used to recieve a file from the FTP server"," ","Syntax: GET Remote_file_name"," ","GET will send a request to the FTP server to send the file specefied in 'Remote_file_name'. A status bar will come-up once the download starts, and the file will be saved with the same name to the current Local diectory.",
DATA "SCRIPT","Used to run a user written script"," ","Syntax: SCRIPT Local_file_name"," ","SCRIPT will run a file that contains a list of commands to run. The commands allowed to be used in the script are all the ones listed in the HELP command list, plus '@ECHO OFF' and '@ECHO ON' to turn echoing of commands on and off.",
DATA "RENAME","Used to rename a Remote File"," ","Syntax: RENAME Remote_file, New_name"," ","Where New_name is the new filename, and Remote_file is the original filename. It is recommended to have the names in quotes.",
DATA "LRENAME","Used to rename a Local File"," ","Syntax: LRENAME Local_file, New_name"," ","Where New_name is the new filename, and Local_file is the original filename. It is recommended to have the names in quotes.",
DATA "DEL","Used to delete a Remote File"," ","Syntax: DEL Remote_file"," ","This command will send a request to the server to delete Remote_file. Weither this command works or not depends on the file permissions of the file you are trying to delete and what the FTP server will allow.",
DATA "LDEL","Used to delete a Local File"," ","Syntax: LDEL Local_file"," ","This command will try to delete Local_file. It won't work if the user doesn't have permissions to delete the file.",
DATA "MKDIR","Used to make a Remote directory"," ","Syn1tax: MKDIR dir_name"," ","'dir_name' is the name for the new directry. Weither or not this command will succeed depends on your permission on the FTP server.",
DATA "LMKDIR","Used to make a Local directory"," ","Syntax: LMKDIR dir_name"," ","'dir_name; is the name for the new directory.",
DATA "RMDIR","Used to delete a Remote directory"," ","Syntax: RMDIR dir_name"," ","'dir_name' is the name of the directory to remove. Weither or not this command will succeed depends on your permission on the FTP server.",
DATA "LRMDIR","Used to delete a Local directory"," ","Syntax: LRMDIR dir_name"," ","'dir_name' is the name of the directory to remove. The directory will be deleted even if it has files in it.",
DATA "EXIT","Used to Exit from the CLI"," ","Syntax: EXIT"," ","If the command line was launched from start-up, then exit will close the program. If it was launched from the GUI then the Command line will exit to the GUI",
DATA "STATUS","Returns the status of the FTP connection"," ","Syntax: STATUS"," ","Prints the status of a FTP connection (Or 'No Connection' if you're not connected",
DATA "PAUSE","Waits for a keypress"," ","Syntax: PAUSE"," ","Prints the message 'Press Any Key to Continue' and then waits for a key press. Usefull in scripts",

FUNCTION move_to_next_gui (movement$, current_selected, gui() AS box_type, gui_num)
    'function moves to next gui based on
    selected_row = gui(current_selected).row1
    selected_col = gui(current_selected).col1
    new_col = -1 'distance from selected object
    new_row = -1
    new_gui = -1
    'DIM choices(UBOUND(gui)) AS INTEGER
    'things are judged by distance
    'in event that there are more then one selected item, which normally happens, we select the closer object

    SELECT CASE movement$
        CASE CHR$(0) + CHR$(72) 'up
            FOR x = 1 TO gui_num
                IF gui(x).row1 < selected_row AND gui(x).row1 >= new_row THEN
                    IF gui(x).col1 = new_col THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF new_col = -1 THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF gui(x).col1 < new_col THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    END IF
                END IF
            NEXT x
        CASE CHR$(0) + CHR$(80) 'down
            FOR x = 1 TO gui_num
                IF gui(x).row1 > selected_row AND (gui(x).row1 <= new_row OR new_row = -1) THEN
                    IF gui(x).col1 = new_col THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF new_col = -1 THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF gui(x).col1 < new_col THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    END IF
                END IF
            NEXT x
        CASE CHR$(0) + CHR$(75) 'left
            FOR x = 1 TO gui_num
                IF gui(x).col1 < selected_col AND (gui(x).col1 >= new_col) THEN
                    IF gui(x).row1 = new_row THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF new_row = -1 THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF gui(x).row1 > new_row THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    END IF
                END IF
            NEXT x
        CASE CHR$(0) + CHR$(77) 'right
            FOR x = 1 TO gui_num
                IF gui(x).col1 > selected_col AND (gui(x).col1 <= new_col OR new_col = -1) THEN
                    IF gui(x).row1 = new_row THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF new_row = -1 THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    ELSEIF gui(x).row1 < new_row THEN
                        new_gui = x
                        new_row = gui(x).row1
                        new_col = gui(x).col1
                    END IF
                END IF
            NEXT x
    END SELECT
    move_to_next_gui = new_gui
END FUNCTION

FUNCTION update_input_boxes (gui() AS box_type, sel AS INTEGER, ch$)
    IF gui(sel).text_box THEN
        SELECT CASE ch$
            CASE " " TO "~"
                add_character gui(sel), ch$
                update_input_boxes = -1
            CASE CHR$(8)
                del_character gui(sel)
                update_input_boxes = -1
            CASE CHR$(0) + CHR$(75)
                IF gui(sel).text_position > 0 THEN
                    gui(sel).text_position = gui(sel).text_position - 1
                    IF gui(sel).text_position < gui(sel).text_offset THEN
                        gui(sel).text_offset = gui(sel).text_offset - 1
                    END IF
                    update_input_boxes = -1
                END IF
            CASE CHR$(0) + CHR$(77)
                IF gui(sel).text_position < gui(sel).text.length THEN
                    gui(sel).text_position = gui(sel).text_position + 1
                    IF gui(sel).text_position > gui(sel).text_offset + (gui(sel).col2 - gui(sel).col1 - 1) THEN
                        gui(sel).text_offset = gui(sel).text_offset + 1
                    END IF
                    update_input_boxes = -1
                END IF
        END SELECT
    END IF
END FUNCTION

SUB draw_box (b AS box_type, sel) 'Draws box b -- this sub draws all the GUI parts
    'Draws a box
    IF b.text_box THEN
        IF b.shadow THEN
            FOR x = b.row1 + 1 TO b.row2 + 1
                FOR y = b.col1 + 2 TO b.col2 + 2
                    chr = SCREEN(x, y)
                    colo = SCREEN(x, y, 1)
                    LOCATE x, y
                    COLOR colo MOD 8, 0
                    PRINT CHR$(chr);
                NEXT y
            NEXT x
        END IF
        IF b.scroll THEN b.scroll_loc = INT((b.offset) / (b.length - (b.row2 - b.row1 - 1)) * (b.row2 - b.row1 - 4) + b.row1 + 2)
        n$ = get_str$(b.nam)
        COLOR b.c1, b.c2
        LOCATE b.row1, b.col1
        PRINT CHR$(218); CHR$(196); n$; STRING$(b.col2 - b.col1 - 2 - LEN(n$), 196); CHR$(191);
        FOR x = b.row1 + 1 TO b.row2 - 1
            LOCATE x, b.col1
            COLOR b.c1, b.c2
            PRINT CHR$(179); SPACE$(b.col2 - b.col1 - 1);

            IF b.scroll = 0 THEN
                PRINT CHR$(179);
            ELSE
                COLOR 7
                SELECT CASE x
                    CASE b.row1 + 1
                        COLOR 0, 7
                        PRINT CHR$(24);
                    CASE b.row2 - 1
                        COLOR 0, 7
                        PRINT CHR$(25);
                    CASE ELSE
                        COLOR 0, 7
                        IF b.scroll_loc = x THEN
                            PRINT CHR$(219);
                        ELSE
                            PRINT CHR$(176);
                        END IF
                END SELECT
            END IF
        NEXT x
        COLOR b.c1 MOD 8, b.c2
        LOCATE b.row2, b.col1
        PRINT CHR$(192); STRING$(b.col2 - b.col1 - 1, 196); CHR$(217);
        'if sel then color b.sc1, b.sc2 else COLOR b.c1, b.c2
        LOCATE b.row1 + 1, b.col1 + 1
        s$ = MID$(get_str$(b.text), b.text_offset + 1, b.col2 - b.col1 - 1)
        IF NOT b.hide THEN PRINT s$; ELSE PRINT STRING$(LEN(s$), "*");
    ELSEIF b.multi_text_box THEN
        IF b.shadow THEN
            FOR x = b.row1 + 1 TO b.row2 + 1
                FOR y = b.col1 + 2 TO b.col2 + 2
                    chr = SCREEN(x, y)
                    colo = SCREEN(x, y, 1)
                    LOCATE x, y
                    COLOR colo MOD 8, 0
                    PRINT CHR$(chr);
                NEXT y
            NEXT x
        END IF
        IF b.scroll THEN b.scroll_loc = INT((b.offset) / (b.length - (b.row2 - b.row1 - 1)) * (b.row2 - b.row1 - 4) + b.row1 + 2)
        n$ = get_str$(b.nam)
        COLOR b.c1, b.c2
        LOCATE b.row1, b.col1
        PRINT CHR$(218); CHR$(196); n$; STRING$(b.col2 - b.col1 - 2 - LEN(n$), 196); CHR$(191);
        FOR x = b.row1 + 1 TO b.row2 - 1
            LOCATE x, b.col1
            COLOR b.c1, b.c2
            PRINT CHR$(179); SPACE$(b.col2 - b.col1 - 1);

            IF b.scroll = 0 THEN
                PRINT CHR$(179);
            ELSE
                COLOR 7
                SELECT CASE x
                    CASE b.row1 + 1
                        COLOR 0, 7
                        PRINT CHR$(24);
                    CASE b.row2 - 1
                        COLOR 0, 7
                        PRINT CHR$(25);
                    CASE ELSE
                        COLOR 0, 7
                        IF b.scroll_loc = x THEN
                            PRINT CHR$(219);
                        ELSE
                            PRINT CHR$(176);
                        END IF
                END SELECT
            END IF
        NEXT x
        COLOR b.c1 MOD 8, b.c2
        LOCATE b.row2, b.col1
        PRINT CHR$(192); STRING$(b.col2 - b.col1 - 1, 196); CHR$(217);
        'FOR x = 1 to b.multi_line.length
        '  PRINT get_str_array$(b.multi_line, x)
        '  sleep
        'next x
        FOR x = 1 TO b.row2 - b.row1 - 1
            LOCATE x + b.row1, b.col1 + 1
            IF (b.selected - b.offset) = (x) THEN
                COLOR b.sc1, b.sc2
            ELSE
                COLOR b.c1, b.c2
            END IF
            PRINT MID$(get_str_array$(b.multi_line, x + b.offset - 1), 1, b.col2 - b.col1 - 1);
            'print "LINE"; x ; ": "; mid$(get_str_array$(b.multi_line, x + b.text_offset - 1), 1, b.row2 - b.row1 - 1);
            'sleep
        NEXT x
    ELSEIF b.button THEN
        LOCATE b.row1, b.col1
        IF sel THEN COLOR b.sc1, b.sc2 ELSE COLOR b.c1 MOD 8, b.c2
        PRINT "<";
        'IF sel THEN COLOR b.selcol, b.c2 ELSE COLOR b.c1 MOD 8, b.c2
        'COLOR b.c1 MOD 8, b.c2
        PRINT get_str$(b.nam);
        IF sel THEN COLOR b.sc1, b.sc2 ELSE COLOR b.c1 MOD 8, b.c2
        PRINT ">";
    ELSEIF b.checkbox THEN
        LOCATE b.row1, b.col1
        IF sel THEN COLOR b.sc1, b.sc2 ELSE COLOR b.c1 MOD 8, b.c2
        PRINT "[";
        IF b.checked THEN PRINT "X"; ELSE PRINT " ";
        PRINT "]";
        COLOR b.c1 MOD 8, b.c2
        PRINT get_str$(b.nam);
    ELSEIF b.drop_down THEN
        _CONTROLCHR OFF

        LOCATE b.row1, b.col1
        COLOR b.c1, b.c2
        IF b.d_flag THEN PRINT CHR$(218); ELSE PRINT "[";
        IF sel THEN COLOR b.sc1, b.sc2
        PRINT LEFT$(get_str$(b.nam) + SPACE$(b.col2 - b.col1), b.col2 - b.col1 - 2); CHR$(31);
        COLOR b.c1, b.c2
        IF b.d_flag THEN PRINT CHR$(191); ELSE PRINT "]";

        _CONTROLCHR ON
    END IF
END SUB

FUNCTION mouse_range (b() AS box_type, boxnum) 'Checks if mouse is in one of the boxes in b()
    'Returns the array number if it is in one of them
    mscroll = 0
    DO WHILE _MOUSEINPUT
        mscroll = mscroll + _MOUSEWHEEL
        mx = _MOUSEX
        my = _MOUSEY
        but = _MOUSEBUTTON(1)
    LOOP
    IF but = -1 AND butflag = -1 THEN
        but = 0
        EXIT FUNCTION
    ELSE
        butflag = 0
    END IF
    IF but = 0 THEN EXIT FUNCTION
    butflag = -1
    FOR x = 1 TO boxnum
        IF b(x).text_box THEN
            IF my <= b(x).row2 AND my >= b(x).row1 THEN
                IF mx >= b(x).col1 AND mx <= b(x).col2 THEN
                    mouse_range = x
                    IF my = b(x).row1 + 1 THEN
                        IF mx > b(x).col1 + 1 AND mx < b(x).col2 - 1 THEN
                            b(x).text_position = b(x).text_offset + mx - b(x).col1 - 1
                            IF b(x).text_position > b(x).text.length THEN
                                b(x).text_position = b(x).text.length
                            END IF
                            b(x).updated = -1
                        END IF
                    END IF
                    EXIT FUNCTION
                END IF
            END IF
        ELSEIF b(x).menu THEN
            IF my = b(x).row1 THEN
                b(x).updated = -1
                mouse_range = x
            END IF
        ELSEIF b(x).multi_text_box THEN
            IF my <= b(x).row2 AND my >= b(x).row1 THEN
                IF mx >= b(x).col1 AND mx <= b(x).col2 THEN
                    mouse_range = x
                    IF my = b(x).row1 + 1 THEN
                        IF mx > b(x).col1 + 1 AND mx < b(x).col2 - 1 THEN
                            b(x).text_position = b(x).text_offset + mx - b(x).col1 - 1
                            IF b(x).text_position > b(x).text.length THEN
                                b(x).text_position = b(x).text.length
                            END IF
                            b(x).updated = -1
                        END IF
                    END IF
                    EXIT FUNCTION
                END IF
            END IF
        ELSEIF b(x).button THEN
            IF my = b(x).row1 AND mx >= b(x).col1 AND mx <= b(x).col1 + LEN(get_str$(b(x).nam)) + 1 THEN
                mouse_range = x
                EXIT FUNCTION
            END IF
        ELSEIF b(x).checkbox THEN
            IF my = b(x).row1 AND mx >= b(x).col1 AND mx <= b(x).col1 + 2 + LEN(get_str$(b(x).nam)) THEN
                mouse_range = x
                EXIT FUNCTION
            END IF
        ELSEIF b(x).drop_down THEN
            IF my = b(x).row1 AND mx >= b(x).col1 AND mx <= b(x).col2 THEN
                mouse_range = x
                EXIT FUNCTION
            END IF
        END IF
    NEXT x
END FUNCTION

SUB dialog_disp (dialog$) 'Displays a dialog box with the text dialog$ inside
    IF NOT cmd_mode THEN
        DIM box AS box_type
        'box.nam = ""
        put_str box.nam, ""
        box.row1 = _HEIGHT(0) \ 2 - 1
        box.row2 = _HEIGHT(0) \ 2 + 1
        box.col1 = _WIDTH(0) \ 2 - (LEN(dialog$) + 2) \ 2
        box.col2 = _WIDTH(0) \ 2 + (LEN(dialog$) + 2) \ 2
        box.shadow = -1
        box.c1 = box_c1
        box.c2 = box_c2
        box.text_box = -1
        draw_box box, 0
        LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(dialog$) \ 2
    END IF
    PRINT dialog$
    IF NOT cmd_mode THEN
        _DISPLAY
        t# = TIMER
        DO: _LIMIT 100: LOOP UNTIL INKEY$ > "" OR TIMER - t# > 1.5
        free_gui_element box
    END IF
END SUB

FUNCTION prompt_dialog (dialog$, tim, buttons, default)
    'dialog$ will be printed above choices. If dialog$ contains CHR$(13), each one represents a new line
    'tim is seconds still close
    'if tim is reached, then default is returned
    gui_num = 0
    IF buttons AND OK_BUTTON THEN gui_num = gui_num + 1
    IF buttons AND NO_BUTTON THEN gui_num = gui_num + 1
    IF buttons AND CLOSE_BUTTON THEN gui_num = gui_num + 1
    IF buttons AND CANCEL_BUTTON THEN gui_num = gui_num + 1
    IF buttons AND YES_BUTTON THEN gui_num = gui_num + 1
    DIM gui(gui_num) AS box_type, main_Box AS box_type
    IF INSTR(dialog$, CHR$(13)) THEN
        rows_add = 0
        k$ = dialog$
        DO
            rows_add = rows_add + 1
            k$ = MID$(k$, INSTR((k$), CHR$(13)) + 1)
        LOOP UNTIL INSTR(k$, CHR$(13)) = 0
        rows_add = rows_add + 1
    ELSE
        rows_add = 1
    END IF

    DIM rows$(rows_add)
    IF INSTR(dialog$, CHR$(13)) THEN
        k$ = dialog$
        FOR x = 1 TO rows_add - 1
            rows$(x) = MID$(k$, 1, INSTR(k$, CHR$(13)) - 1)
            k$ = MID$(k$, INSTR(k$, CHR$(13)) + 1)
            IF LEN(rows$(x)) > box_width THEN box_width = LEN(rows$(x))
        NEXT x
        rows$(rows_add) = k$
        IF LEN(rows$(rows_add)) > box_width THEN box_width = LEN(rows$(rows_add))
    ELSE
        rows$(1) = dialog$
        box_width = LEN(rows$(1))
    END IF
    box_width = box_width + 4

    IF box_width < 40 THEN box_width = 40

    'main_Box.nam = ""
    put_str main_Box.nam, ""
    main_Box.text_box = -1
    main_Box.c1 = box_c1
    main_Box.c2 = box_c2
    main_Box.row1 = _HEIGHT(0) / 2 - 2
    main_Box.row2 = main_Box.row1 + 3 + rows_add
    IF tim > 0 THEN main_Box.row2 = main_Box.row2 + 1
    main_Box.col1 = _WIDTH(0) / 2 - box_width \ 2
    main_Box.col2 = main_Box.col1 + box_width
    main_Box.shadow = -1

    FOR x = 1 TO gui_num
        gui(x).button = -1
        gui(x).c1 = box_c1
        gui(x).c2 = box_c2
        gui(x).sc1 = box_sel_c1
        gui(x).sc2 = box_sel_c2
        gui(x).row1 = main_Box.row2 - 1
        gui(x).col1 = main_Box.col1 + ((main_Box.col2 - main_Box.col1) / (gui_num + 1)) * x
        IF NOT ok_flag AND (buttons AND OK_BUTTON) THEN
            ok_flag = -1
            'gui(x).nam = "OK"
            put_str gui(x).nam, "OK"
            gui(x).col1 = gui(x).col1 - 2
        ELSEIF NOT cancel_flag AND (buttons AND CANCEL_BUTTON) THEN
            cancel_flag = -1
            ' gui(x).nam = "CANCEL"
            put_str gui(x).nam, "CANCEL"
            gui(x).col1 = gui(x).col1 - 4
        ELSEIF NOT yes_flag AND (buttons AND YES_BUTTON) THEN
            yes_flag = -1
            ' gui(x).nam = "YES"
            put_str gui(x).nam, "YES"
            gui(x).col1 = gui(x).col1 - 2
        ELSEIF NOT no_flag AND (buttons AND NO_BUTTON) THEN
            no_flag = -1
            ' gui(x).nam = "NO"
            put_str gui(x).nam, "NO"
            gui(x).col1 = gui(x).col1 - 2
        ELSEIF NOT close_flag AND (buttons AND CLOSE_BUTTON) THEN
            close_flag = -1
            ' gui(x).nam = "CLOSE"
            put_str gui(x).nam, "CLOSE"
            gui(x).col1 = gui(x).col1 - 3
        END IF
    NEXT x

    update = -1
    curr = 1
    curc = 1
    t# = TIMER
    DO
        _LIMIT 100
        m = mouse_range(gui(), gui_num)
        IF m > 0 THEN
            s_box = m
            update = -1
            exit_flag = -1
        END IF
        IF update THEN
            update = 0
            _DISPLAY
            draw_box main_Box, 0
            COLOR box_c1, box_c2
            FOR x = 1 TO rows_add
                LOCATE main_Box.row1 + x, main_Box.col1 + (main_Box.col2 - main_Box.col1) / 2 - LEN(rows$(x)) / 2
                PRINT rows$(x);
            NEXT x
            'PRINT dialog$; STR$(gui_num);
            IF tim > 0 THEN
                s$ = "Dialog will close in" + STR$(tim - INT(TIMER - t#)) + " seconds..."
                LOCATE main_Box.row1 + 1 + rows_add, main_Box.col1 + (main_Box.col2 - main_Box.col1) / 2 - LEN(s$) / 2
                PRINT s$;
                LOCATE main_Box.row1 + 2 + rows_add, main_Box.col1
            ELSE
                LOCATE main_Box.row1 + 1 + rows_add, main_Box.col1
            END IF
            PRINT CHR$(195); STRING$(main_Box.col2 - main_Box.col1 - 1, 196); CHR$(180);
            FOR x = 1 TO gui_num
                draw_box gui(x), s_box = x
                IF s_box = x THEN
                    curr = gui(x).row1
                    curc = gui(x).col1 + 1
                END IF
            NEXT x
            _AUTODISPLAY
            LOCATE curr, curc, 1
        END IF
        a$ = INKEY$
        SELECT CASE a$
            CASE CHR$(9)
                s_box = (s_box MOD gui_num) + 1
                update = -1
            CASE CHR$(13)
                exit_flag = -1
            CASE CHR$(0) + CHR$(72), CHR$(0) + CHR$(80), CHR$(0) + CHR$(75), CHR$(0) + CHR$(77)
                new_gui = move_to_next_gui(a$, s_box, gui(), gui_num)
                IF new_gui > -1 THEN
                    s_box = new_gui
                    update = -1
                END IF
        END SELECT
        IF TIMER - t# > tsav THEN
            tsav = TIMER - t# + .2
            update = -1
        END IF
    LOOP UNTIL exit_flag OR (TIMER - t# > tim AND tim > 0)
    _DISPLAY
    IF TIMER - t# > tim AND tim > 0 THEN
        prompt_dialog = default
    ELSEIF get_str$(gui(s_box).nam) = "OK" THEN
        prompt_dialog = OK_BUTTON
    ELSEIF get_str$(gui(s_box).nam) = "CLOSE" THEN
        prompt_dialog = CLOSE_BUTTON
    ELSEIF get_str$(gui(s_box).nam) = "CANCEL" THEN
        prompt_dialog = CANCEL_BUTTON
    ELSEIF get_str$(gui(s_box).nam) = "NO" THEN
        prompt_dialog = NO_BUTTON
    ELSEIF get_str$(gui(s_box).nam) = "YES" THEN
        prompt_dialog = YES_BUTTON
    END IF
    LOCATE , , 0
    free_gui_element main_Box
    free_gui_array gui()
END FUNCTION

SUB setup_main_GUI () 'sets up the main GUI
    'if scrn& <> 0 then _FREEIMAGE scrn& 'prevent memory leak
    'scrn& = _NEWIMAGE(scrnw, scrnh, 0)
    'SCREEN scrn&

    'boxes(1).nam = "Local"
    put_str boxes(1).nam, "Local"
    boxes(1).col1 = 1
    boxes(1).col2 = _WIDTH(0) \ 2
    boxes(1).row1 = 2
    boxes(1).row2 = _HEIGHT(0) - 2
    boxes(1).c1 = main_gui_c1
    boxes(1).c2 = main_gui_c2
    boxes(1).sc1 = main_gui_sel_c1
    boxes(1).sc2 = main_gui_sel_c2
    boxes(1).scroll = -1
    'boxes(1).length = 0
    boxes(1).selected = 1
    boxes(1).multi_text_box = -1

    'boxes(2).nam = "Remote"
    put_str boxes(2).nam, "Remote"
    boxes(2).col1 = _WIDTH(0) \ 2 + 1
    boxes(2).col2 = _WIDTH(0)
    boxes(2).row1 = 2
    boxes(2).row2 = _HEIGHT(0) - 2
    boxes(2).c1 = main_gui_c1
    boxes(2).c2 = main_gui_c2
    boxes(2).sc1 = main_gui_sel_c1
    boxes(2).sc2 = main_gui_sel_c2
    boxes(2).scroll = -1
    'boxes(2).length = 0
    boxes(2).selected = 0
    boxes(2).multi_text_box = -1

    'boxes(3).nam = "MENU" 'Not actually drawn on the screen
    put_str boxes(3).nam, "MENU"
    boxes(3).row1 = 1
    boxes(3).row2 = 1
    boxes(3).col1 = 1
    boxes(3).col2 = scrnw
    boxes(3).menu = -1

    menux.c1 = menu_c1
    menux.c2 = menu_c2
END SUB

SUB update_scrn () 'updates screen
    COLOR 7, 1
    FOR x = 2 TO _HEIGHT(0) - 1
        LOCATE x, 1
        PRINT SPACE$(_WIDTH(0));
    NEXT x
    COLOR status_c1, status_c2
    LOCATE _HEIGHT(0), 1
    PRINT SPACE$(_WIDTH(0));
    LOCATE _HEIGHT(0), 1
    PRINT "Status: "; status$;
    IF selected_box = 1 THEN
        boxes(1).sc1 = main_gui_sel_c1
        boxes(1).sc2 = main_gui_sel_c2
        boxes(2).sc1 = file_non_sel
        boxes(2).sc2 = main_gui_c2
    ELSEIF selected_box = 2 THEN
        boxes(2).sc1 = main_gui_sel_c1
        boxes(2).sc2 = main_gui_sel_c2
        boxes(1).sc1 = file_non_sel
        boxes(1).sc2 = main_gui_c2
    ELSE
        boxes(1).sc1 = file_non_sel
        boxes(1).sc2 = main_gui_c2
        boxes(2).sc1 = file_non_sel
        boxes(2).sc2 = main_gui_c2
    END IF
    draw_box boxes(1), selected_box = 1
    draw_box boxes(2), selected_box = 2
    COLOR main_gui_c1, main_gui_c2
    LOCATE _HEIGHT(0) - 1, 1
    PRINT SPACE$(_WIDTH(0));
    LOCATE _HEIGHT(0) - 1, 1
    leng = _WIDTH(0) \ 2 - 1
    IF LEN(Local_dir$) < leng THEN
        PRINT Local_dir$;
    ELSE
        IF INSTR(Local_dir$, ":") THEN
            'Windows dir
            dir$ = LEFT$(Local_dir$, 3) + "..." + RIGHT$(Local_dir$, leng - 6)
        ELSE
            dir$ = "/..." + RIGHT$(Local_dir$, leng - 4)
        END IF
        PRINT dir$;
    END IF
    LOCATE _HEIGHT(0) - 1, leng + 3
    IF LEN(Remote_dir$) < leng THEN
        PRINT Remote_dir$;
    ELSE
        IF INSTR(Local_dir$, ":") THEN
            dir$ = LEFT$(Remote_dir$, 3) + "..." + RIGHT$(Remote_dir$, leng - 6)
        ELSE
            dir$ = "/..." + RIGHT$(Remote_dir$, leng - 4)
        END IF
        PRINT dir$;
    END IF

    IF selected_box = 3 THEN
        IF global_menu_sel > 0 AND temp_menu_sel = 0 THEN
            COLOR menu_c1, menu_c2
            LOCATE 1, 1
            PRINT SPACE$(_WIDTH(0));
            LOCATE 1, 1
            PRINT "  ";
            FOR x = 1 TO g_menu_c
                IF global_menu_sel = x THEN COLOR menu_sel_c1, menu_sel_c2: k = menu_sel_c1 ELSE COLOR menu_c1, menu_c2: k = menu_c1
                print_menu_no_hilight Global_Menu$(x)
            NEXT x
            draw_box menux, 0
            FOR x = 1 TO Menun(global_menu_sel)
                LOCATE menux.row1 + x, menux.col1 + 1
                IF menu_sel = x THEN
                    COLOR menu_sel_c1, menu_sel_c2: k = menu_sel_c1
                ELSE
                    COLOR menu_c1, menu_c2: k = menu_c1
                END IF
                IF Menu$(global_menu_sel, x) = "-" THEN
                    p = POS(0): LOCATE , p - 1
                    PRINT CHR$(195); STRING$(menu_max_len(global_menu_sel) - 1, 196); CHR$(180);
                ELSE
                    print_menu Menu$(global_menu_sel, x) + SPACE$(menu_max_len(global_menu_sel) - LEN(Menu$(global_menu_sel, x))), k
                END IF
            NEXT x
        ELSE
            COLOR menu_c1, menu_c2
            LOCATE 1, 1
            PRINT SPACE$(_WIDTH(0));
            LOCATE 1, 1
            PRINT "  ";
            FOR x = 1 TO g_menu_c
                IF temp_menu_sel = x THEN COLOR menu_sel_c1, menu_sel_c2: k = menu_sel_c1 ELSE COLOR menu_c1, menu_c2: k = menu_c1
                print_menu Global_Menu$(x), k
            NEXT x
        END IF
    ELSE
        COLOR menu_c1, menu_c2
        LOCATE 1, 1
        PRINT SPACE$(_WIDTH(0));
        LOCATE 1, 1
        PRINT "  ";
        FOR x = 1 TO g_menu_c
            print_menu_no_hilight Global_Menu$(x)
        NEXT x
    END IF
END SUB

SUB print_files (b AS box_type, f() AS filedir_type) 'Displays files f() in box b()
    'DIM s as string_type
    IF b.length > b.multi_line.length THEN
        reallocate_array b.multi_line, b.length + 2
    END IF
    FOR x = 1 TO b.multi_line.length 'b.row2 - b.row1 - 1
        IF x <= b.length THEN
            k$ = get_str$(f(x).nam)
            IF LEN(k$) > b.col2 - b.col1 - 4 THEN
                k$ = MID$(k$, 1, b.col2 - b.col1 - 4)
            ELSE
                k$ = k$ + SPACE$((b.col2 - b.col1 - 4) - LEN(k$))
            END IF
            IF f(x).flag_cwd AND f(x).flag_retr THEN
                k$ = k$ + "LNK"
            ELSEIF f(x).flag_cwd THEN
                k$ = k$ + "DIR"
            ELSE
                k$ = k$ + "   "
            END IF
            put_str_array b.multi_line, x - 1, k$
        ELSE
            put_str_array b.multi_line, x - 1, ""
        END IF
    NEXT x

    'free_string s
    'COLOR b.c1, b.c2
    'FOR x = 1 TO b.row2 - b.row1 - 1
    '  LOCATE x + b.row1, b.col1 + 1
    '  IF x + b.offset = b.selected AND selected THEN COLOR b.sc1, b.sc2 ELSE IF x + b.offset = b.selected THEN COLOR file_non_sel, b.c2 ELSE COLOR b.c1, b.c2
    '  IF x + b.offset <= b.length THEN PRINT USING "\" + SPACE$(b.col2 - b.col1 - 8) + "\ \ \ "; get_str$(f(x + b.offset).nam); f(x + b.offset).dir; ELSE PRINT SPACE$(b.col2 - b.col1 - 1);
    'NEXT x
END SUB

SUB print_menu_no_hilight (a$) 'Prints a$ without the '#' and no hilighting
    PRINT MID$(a$, 1, INSTR(a$, "#") - 1);
    PRINT MID$(a$, INSTR(a$, "#") + 1);
END SUB

SUB print_menu (a$, s) 'Prints a$ with the character after '#' hilighted in bright white
    PRINT MID$(a$, 1, INSTR(a$, "#") - 1);
    COLOR menu_char_c
    PRINT MID$(a$, INSTR(a$, "#") + 1, 1);
    COLOR s
    PRINT MID$(a$, INSTR(a$, "#") + 2);
END SUB

FUNCTION menu_len (a$) 'Length of menu item a$.
    'Just takes one away from the length if the string has a '#'`
    IF INSTR(a$, "#") THEN
        menu_len = LEN(a$) - 1
    ELSE
        menu_len = LEN(a$)
    END IF
END FUNCTION

FUNCTION menu_char$ (a$) 'Get's the hilighted character
    menu_char$ = MID$(a$, INSTR(a$, "#") + 1, 1)
END FUNCTION

SUB Connect_To_FTP () 'GUI for connecting to FTP and opens the connection with FTP server
    selected_gui = 1
    DIM main_ide AS box_type
    'main_ide.nam = "Connect to FTP Server"
    put_str main_ide.nam, "Connect to FTP Server"
    main_ide.c1 = box_c1
    main_ide.c2 = box_c2
    main_ide.text_box = -1
    main_ide.shadow = -1
    rows = 12
    cols = 46
    main_ide.row1 = _HEIGHT(0) \ 2 - rows \ 2
    main_ide.row2 = main_ide.row1 + rows
    main_ide.col1 = _WIDTH(0) \ 2 - cols \ 2
    main_ide.col2 = main_ide.col1 + cols

    DIM gui(5) AS box_type
    'DIM gui_text$(3)
    r = main_ide.row1 + 1
    c = main_ide.col1 + 4

    gui(1).row1 = main_ide.row1 + 1
    gui(1).col1 = main_ide.col1 + 3
    gui(1).row2 = gui(1).row1 + 2
    gui(1).col2 = gui(1).col1 + 40
    gui(1).text_box = -1
    gui(1).c1 = box_c1
    gui(1).c2 = box_c2
    gui(1).sc1 = box_c1
    gui(1).sc2 = box_c2
    'gui(1).nam = "Server"
    put_str gui(1).nam, "Server"

    gui(2).row1 = gui(1).row2 + 1
    gui(2).col1 = gui(1).col1
    gui(2).row2 = gui(2).row1 + 2
    gui(2).col2 = gui(2).col1 + 40
    gui(2).text_box = -1
    gui(2).c1 = box_c1
    gui(2).c2 = box_c2
    gui(2).sc1 = box_c1
    gui(2).sc2 = box_c2
    'gui(2).nam = "Username"
    put_str gui(2).nam, "Username"

    gui(3).row1 = gui(2).row2 + 1
    gui(3).col1 = gui(2).col1
    gui(3).row2 = gui(3).row1 + 2
    gui(3).col2 = gui(3).col1 + 40
    gui(3).text_box = -1
    gui(3).c1 = box_c1
    gui(3).c2 = box_c2
    gui(3).sc1 = box_c1
    gui(3).sc2 = box_c2
    'gui(3).nam = "Password"
    put_str gui(3).nam, "Password"
    gui(3).hide = -1

    gui(4).row1 = gui(3).row1 + 3
    'gui(4).nam = "Connect"
    put_str gui(4).nam, "Connect"
    gui(4).col1 = main_ide.col1 + cols \ 3 - LEN(get_str$(gui(4).nam)) \ 2
    gui(4).button = -1
    gui(4).c1 = box_c1
    gui(4).c2 = box_c2
    gui(4).sc1 = box_sel_c1
    gui(4).sc2 = box_sel_c2

    gui(5).row1 = gui(4).row1
    'gui(5).nam = "Quit"
    put_str gui(5).nam, "Quit"
    gui(5).col1 = gui(4).col1 + cols \ 3 - LEN(get_str$(gui(5).nam)) \ 2
    gui(5).button = -1
    gui(5).c1 = box_c1
    gui(5).c2 = box_c2
    gui(5).sc1 = box_sel_c1
    gui(5).sc2 = box_sel_c2
    LOCATE , , 1
    locrow = 1
    loccol = 1

    update = -1
    exit_gui_flag = 0
    DO
        _LIMIT 500
        m = mouse_range(gui(), 5)
        IF m <> selected_gui AND m > 0 THEN selected_gui = m: update = -1
        IF gui(selected_gui).updated THEN gui(selected_gui).updated = 0: update = -1
        IF but THEN
            IF selected_gui = 4 THEN
                server$ = get_str$(gui(1).text) 'gui_text$(1)
                IF INSTR(server$, ":") THEN
                    port$ = MID$(server$, INSTR(server$, ":") + 1)
                    server$ = MID$(server$, 1, INSTR(server$, ":") - 1)
                ELSE
                    port$ = "21"
                END IF
                username$ = get_str$(gui(2).text) ' gui_text$(2)
                password$ = get_str$(gui(3).text) 'gui_text$(3)

                Start_ftp_connect
                IF is_connected THEN LOCATE , , 0: _DISPLAY: exit_gui_flag = -1
                update = -1
            ELSEIF selected_gui = 5 THEN
                LOCATE , , 0
                _DISPLAY
                exit_gui_flag = -1
            END IF
        END IF
        a$ = INKEY$
        IF a$ > "" THEN
            test = update_input_boxes(gui(), selected_gui, a$)
            IF test THEN
                update = -1
            ELSE
                SELECT CASE a$
                    CASE CHR$(9)
                        selected_gui = selected_gui + 1
                        IF selected_gui > 5 THEN selected_gui = 1
                        update = -1
                    CASE CHR$(13)
                        IF selected_gui <= 3 THEN
                            selected_gui = selected_gui + 1
                            update = -1
                        ELSEIF selected_gui > 3 THEN
                            IF selected_gui = 4 THEN
                                'GOSUB connect
                                server$ = get_str$(gui(1).text) 'gui_text$(1)
                                IF INSTR(server$, ":") THEN
                                    port$ = MID$(server$, INSTR(server$, ":") + 1)
                                    server$ = MID$(server$, 1, INSTR(server$, ":") - 1)
                                ELSE
                                    port$ = "21"
                                END IF
                                username$ = get_str$(gui(2).text) 'gui_text$(2)
                                password$ = get_str$(gui(3).text) 'gui_text$(3)

                                Start_ftp_connect
                                IF is_connected THEN LOCATE , , 0: _DISPLAY: exit_gui_flag = -1
                                update = -1
                            ELSE
                                LOCATE , , 0
                                _DISPLAY
                                exit_gui_flag = -1

                            END IF
                        END IF
                END SELECT
            END IF
        END IF
        IF update THEN
            _DISPLAY
            update = 0
            update_scrn
            draw_box main_ide, 0
            FOR x = 1 TO 5
                draw_box gui(x), selected_gui = x
                IF x < 4 AND selected_gui = x THEN
                    locrow = gui(x).row1 + 1
                    loccol = gui(x).col1 + gui(x).text_position - gui(x).text_offset + 1
                ELSEIF selected_gui = x THEN
                    locrow = gui(x).row1
                    loccol = gui(x).col1 + 1
                END IF
            NEXT x

            LOCATE locrow, loccol
            _AUTODISPLAY
        END IF
    LOOP UNTIL exit_gui_flag

    free_gui_element main_ide
    free_gui_array gui()
END SUB

SUB rename_file_GUI (local_or_remote) 'Renames a local or remote file
    'local_or_remote = 0 -- local file rename
    'local_or_remote = 1 -- remote file rename

    IF local_or_remote = 0 AND is_connected = 0 THEN
        dialog_disp "Please connect to a server first."
        EXIT SUB
    END IF

    gui_num = 3 '1 text box, 3 buttons
    DIM box AS box_type, gui(gui_num) AS box_type
    'box.nam = "Rename file"
    put_str box.nam, "Rename file"
    box.row1 = _HEIGHT(0) \ 2 - 3
    box.row2 = box.row1 + 6
    box.col1 = _WIDTH(0) \ 2 - 30
    box.col2 = box.col1 + 60
    box.shadow = -1
    box.c1 = box_c1
    box.c2 = box_c2
    box.text_box = -1

    'gui(1).nam = "File Name"
    put_str gui(1).nam, "File Name"
    gui(1).row1 = box.row1 + 1
    gui(1).row2 = gui(1).row1 + 2
    gui(1).col1 = box.col1 + 5
    gui(1).col2 = box.col2 - 5
    gui(1).c1 = box_c1
    gui(1).c2 = box_c2
    gui(1).text_box = -1

    IF local_or_remote = 1 THEN
        'gui(2).nam = "Local File"
        put_str gui(2).nam, "Local File"
        gui(2).row1 = box.row2 - 1
        gui(2).c1 = box_c1
        gui(2).c2 = box_c2
        gui(2).sc1 = box_sel_c1
        gui(2).sc2 = box_sel_c2
        gui(2).button = -1
    ELSE
        'IF is_connected THEN
        'gui(2).nam = "Remote File"
        put_str gui(2).nam, "Remove File"
        gui(2).row1 = box.row2 - 1
        gui(2).c1 = box_c1
        gui(2).c2 = box_c2
        gui(2).sc1 = box_sel_c1
        gui(2).sc2 = box_sel_c2
        gui(2).button = -1
    END IF

    'gui(3).nam = "Close"
    put_str gui(3).nam, "Close"
    gui(3).row1 = box.row2 - 1
    gui(3).c1 = box_c1
    gui(3).c2 = box_c2
    gui(3).sc1 = box_sel_c1
    gui(3).sc2 = box_sel_c2
    gui(3).button = -1

    blen = box.col2 - box.col1
    b = blen \ 3
    gui(2).col1 = b - LEN(get_str$(gui(2).nam)) \ 2 + box.col1
    gui(3).col1 = b * 2 - LEN(get_str$(gui(3).nam)) \ 2 + box.col1
    'END IF

    update = -1
    selected_box = 1
    LOCATE , , 1
    locrow = 1
    loccol = 1
    IF local_or_remote = 1 THEN put_str gui(1).text, RTRIM$(get_str$(Local_files(boxes(1).selected).nam)) ELSE put_str gui(1).text, RTRIM$(get_str$(Remote_files(boxes(2).selected).nam))
    DO
        _LIMIT 500
        m = mouse_range(gui(), gui_num)
        IF m <> selected_box AND m > 0 THEN selected_box = m: update = -1
        IF gui(selected_box).updated THEN gui(selected_box).updated = 0: update = -1
        IF update THEN
            _DISPLAY
            update = 0
            draw_box box, 0
            FOR x = 1 TO gui_num
                draw_box gui(x), selected_box = x
                'IF x = 1 THEN
                '  LOCATE gui(x).row1 + 1, gui(x).col1 + 1
                '  PRINT RIGHT$(filename$, (gui(x).col2 - gui(x).col1) - 2);
                'END IF
                IF x = selected_box THEN
                    IF selected_box = 1 THEN
                        locrow = gui(x).row1 + 1
                        loccol = gui(x).col1 + gui(x).text_position - gui(x).text_offset + 1

                        'locrow = gui(x).row1 + 1
                        'loccol = gui(x).col1 + LEN(RIGHT$(filename$, (gui(x).col2 - gui(x).col1) - 2)) + 1
                    ELSE
                        locrow = gui(x).row1
                        loccol = gui(x).col1 + 1
                    END IF
                END IF
            NEXT x
            LOCATE locrow, loccol
            _AUTODISPLAY
        END IF
        k$ = INKEY$
        update = update_input_boxes(gui(), selected_box, k$)
        SELECT CASE k$
            CASE CHR$(9) 'tab
                selected_box = (selected_box MOD gui_num) + 1: update = -1
            CASE CHR$(13)
                IF selected_box = 1 THEN
                ELSEIF selected_box = 2 THEN
                    IF local_or_remote = 1 THEN
                        'rename local file
                        GOSUB rename_local_file
                    ELSE
                        Rename_remote_file_dir RTRIM$(get_str$(Remote_files(boxes(2).selected).nam)), get_str$(gui(1).text), -1
                    END IF
                    exit_flag = -1
                ELSEIF selected_box = 3 THEN
                    exit_flag = -1
                END IF
            CASE CHR$(27)
                exit_flag = -1
        END SELECT
        IF but THEN
            IF selected_box = 2 THEN
                IF local_or_remote = 1 THEN
                    GOSUB rename_local_file
                ELSE
                    Rename_remote_file_dir RTRIM$(get_str$(Remote_files(boxes(2).selected).nam)), get_str$(gui(1).text), -1
                END IF
                exit_flag = -1
            ELSEIF selected_box = 3 THEN
                exit_flag = -1
            END IF
        END IF
    LOOP UNTIL exit_flag
    _DISPLAY
    LOCATE , , 0
    EXIT SUB

    rename_local_file:
    ON ERROR GOTO error_flag
    err_flag = 0
    NAME RTRIM$(get_str$(Local_files(boxes(1).selected).nam)) AS get_str$(gui(1).text)
    IF err_flag THEN
        dialog_disp "Error changing name of Local file..."
    END IF
    refresh_Local_files
    exit_flag = -1
    RETURN
END SUB

SUB settings_dialog () 'Displays a dialog to change settings
    gui_num = 9
    DIM main_box AS box_type, gui(gui_num) AS box_type
    DIM ddsel(3), ddarr$(3, 20), ddlen(3)
    DIM drop_flag AS INTEGER, selsav(8, 2) AS INTEGER, backup(8, 2) AS INTEGER, rowback AS INTEGER, colback AS INTEGER
    'DIM text$(2)
    rowback = scrnh
    colback = scrnw

    ddarr$(1, 1) = "GUI Colors"
    ddarr$(1, 2) = "GUI Selection Colors"
    ddarr$(1, 3) = "Status Strip Colors"
    ddarr$(1, 4) = "Menu Colors"
    ddarr$(1, 5) = "Menu Selection Colors"
    ddarr$(1, 6) = "Dialog Colors"
    ddarr$(1, 7) = "Dialog Selection Colors"
    ddarr$(1, 8) = "Etc. Colors"
    selsav(1, 1) = main_gui_c1 + 1
    selsav(1, 2) = main_gui_c2 + 1
    selsav(2, 1) = main_gui_sel_c1 + 1
    selsav(2, 2) = main_gui_sel_c2 + 1
    selsav(3, 1) = status_c1 + 1
    selsav(3, 2) = status_c2 + 1
    selsav(4, 1) = menu_c1 + 1
    selsav(4, 2) = menu_c2 + 1
    selsav(5, 1) = menu_sel_c1 + 1
    selsav(5, 2) = menu_sel_c2 + 1
    selsav(6, 1) = box_c1 + 1
    selsav(6, 2) = box_c2 + 1
    selsav(7, 1) = box_sel_c1 + 1
    selsav(7, 2) = box_sel_c2 + 1
    selsav(8, 1) = menu_char_c + 1
    selsav(8, 2) = file_non_sel + 1
    FOR x = 1 TO 8
        FOR y = 1 TO 2
            backup(x, y) = selsav(x, y)
        NEXT y
    NEXT x
    ddarr$(2, 1) = "Black"
    ddarr$(2, 2) = "Dark Blue"
    ddarr$(2, 3) = "Dark Green"
    ddarr$(2, 4) = "Dark Cyan"
    ddarr$(2, 5) = "Dark Red"
    ddarr$(2, 6) = "Dark Magenta"
    ddarr$(2, 7) = "Dark Yellow"
    ddarr$(2, 8) = "Light Gray"
    ddarr$(2, 9) = "Dark Grey"
    ddarr$(2, 10) = "Blue"
    ddarr$(2, 11) = "Green"
    ddarr$(2, 12) = "Cyan"
    ddarr$(2, 13) = "Red"
    ddarr$(2, 14) = "Magenta"
    ddarr$(2, 15) = "Yellow"
    ddarr$(2, 16) = "White"
    ddarr$(3, 1) = "Black"
    ddarr$(3, 2) = "Dark Blue"
    ddarr$(3, 3) = "Dark Green"
    ddarr$(3, 4) = "Dark Cyan"
    ddarr$(3, 5) = "Dark Red"
    ddarr$(3, 6) = "Dark Magenta"
    ddarr$(3, 7) = "Dark Yellow"
    ddarr$(3, 8) = "Light Gray"
    ddarr$(3, 9) = "Dark Grey"
    ddarr$(3, 10) = "Blue"
    ddarr$(3, 11) = "Green"
    ddarr$(3, 12) = "Cyan"
    ddarr$(3, 13) = "Red"
    ddarr$(3, 14) = "Magenta"
    ddarr$(3, 15) = "Yellow"
    ddarr$(3, 16) = "White"
    ddlen(1) = 8
    ddsel(1) = 1
    ddlen(2) = 16
    ddsel(2) = selsav(1, 1)
    ddlen(3) = 8
    ddsel(3) = selsav(1, 2)

    GOSUB setup_box 'sets up gui cords and colors. it's a gosub because it is used again in the main loop

    main_box.text_box = -1
    'main_box.nam = "Settings"
    put_str main_box.nam, "Settings"
    main_box.shadow = -1

    gui(1).text_box = -1
    'gui(1).nam = ""
    put_str gui(1).nam, ""
    gui(1).shadow = -1

    gui(2).drop_down = -1

    gui(3).drop_down = -1

    gui(4).drop_down = -1

    gui(5).text_box = -1
    'gui(5).nam = "Rows"
    put_str gui(5).nam, "Rows"
    put_str gui(5).text, LTRIM$(RTRIM$(STR$(scrnh)))

    gui(6).text_box = -1
    'gui(6).nam = "Columns"
    put_str gui(6).nam, "Columns"
    put_str gui(6).text, LTRIM$(RTRIM$(STR$(scrnw)))

    gui(7).button = -1
    'gui(7).nam = "Change"
    put_str gui(7).nam, "Change"

    gui(8).button = -1
    'gui(8).nam = "Save"
    put_str gui(8).nam, "Save"

    gui(9).button = -1
    'gui(9).nam = "Exit"
    put_str gui(9).nam, "Exit"

    update = -1
    curr = 1
    curc = 1
    exit_flag = 0
    loaded = 1
    DO
        _LIMIT 1000
        m = mouse_range(gui(), gui_num)
        IF gui(s_box).updated THEN gui(s_box).updated = 0: update = -1
        IF m > 0 THEN
            IF (s_box = m AND m < 5 AND m > 1) THEN ' OR (m < 5 AND m > 1 AND my = gui(m).col2 - 1) THEN
                IF drop_flag = 0 THEN
                    drop_flag = -1
                    gui(1).row1 = gui(m).row1
                    gui(1).row2 = gui(1).row1 + ddlen(m - 1) + 1
                    IF gui(1).row2 > _HEIGHT(0) THEN gui(1).row2 = _HEIGHT(0)
                    gui(1).col1 = gui(m).col1
                    gui(1).col2 = gui(m).col2
                    gui(1).selected = ddsel(m - 1)
                    gui(s_box).d_flag = 0
                    gui(m).d_flag = -1
                ELSE
                    drop_flag = 0
                    gui(m).d_flag = 0
                    gui(1).row1 = 0
                    gui(1).row2 = 0
                    gui(1).col1 = 0
                    gui(1).col2 = 0
                    gui(1).c1 = 0

                END IF
            ELSEIF m = 1 THEN
                m = s_box
                IF my > gui(1).row1 THEN
                    IF ddsel(m - 1) = my - gui(1).row1 THEN

                        drop_flag = 0
                        gui(s_box).d_flag = 0
                        gui(1).row1 = 0
                        gui(1).row2 = 0
                        gui(1).col1 = 0
                        gui(1).col2 = 0
                    ELSE
                        ddsel(m - 1) = my - gui(1).row1
                        selsav(loaded, 1) = ddsel(2)
                        selsav(loaded, 2) = ddsel(3)

                    END IF
                END IF
            ELSE
                gui(s_box).d_flag = 0
                drop_flag = 0
                gui(1).row1 = 0
                gui(1).row2 = 0
                gui(1).col1 = 0
                gui(1).col2 = 0

            END IF
            s_box = m
            update = -1
        END IF
        IF but THEN 'mouse click
            IF drop_flag AND m <> s_box THEN
                drop_flag = 0
                gui(s_box).d_flag = 0
                update = -1
                gui(1).row1 = 0
                gui(1).row2 = 0
                gui(1).col1 = 0
                gui(1).col2 = 0
            END IF
        END IF
        IF ddsel(1) = 8 THEN ddlen(3) = 16 ELSE ddlen(3) = 8
        IF s_box = 2 THEN
            IF ddsel(s_box - 1) <> loaded THEN
                ddsel(2) = selsav(ddsel(s_box - 1), 1)
                ddsel(3) = selsav(ddsel(s_box - 1), 2)
                loaded = ddsel(s_box - 1)
                update = -1
            END IF
            selsav(loaded, 1) = ddsel(2)
            selsav(loaded, 2) = ddsel(3)
        END IF
        IF update THEN
            update = 0
            _DISPLAY
            update_scrn
            draw_box main_box, 0
            FOR x = 2 TO gui_num
                IF x < 5 THEN
                    put_str gui(x).nam, LEFT$(ddarr$(x - 1, ddsel(x - 1)), gui(x).col2 - gui(x).col1)
                END IF
                draw_box gui(x), s_box = x
                'IF x = 5 OR x = 6 THEN COLOR gui(x).c1, gui(x).c2: LOCATE gui(x).row1 + 1, gui(x).col1 + 1: PRINT text$(x - 4);
                IF s_box = x THEN
                    IF x < 5 OR x > 6 THEN 'dropdown or button
                        curr = gui(x).row1
                        curc = gui(x).col1 + 1
                    ELSEIF x = 5 OR x = 6 THEN 'text boxes
                        curr = gui(x).row1 + 1
                        curc = gui(x).col1 + gui(x).text_position - gui(x).text_offset + 1
                        'curr = gui(x).row1 + 1
                        'curc = gui(x).col1 + LEN(text$(x - 4)) + 1
                    END IF
                END IF
            NEXT x
            IF CONFIG = 0 THEN
                COLOR box_c1, box_c2
                s$ = "Note: right now CONFIG = 0. If this is default, run Client with -config 1"
                's$ = "Loaded=:" + STR$(loaded)
                LOCATE main_box.row2 - 1, main_box.col1 + 1
                PRINT s$;
            END IF
            IF ddsel(1) < 8 THEN
                COLOR selsav(ddsel(1), 1) - 1, selsav(ddsel(1), 2) - 1
                t$ = "Example Text in Selected Colors"
                LOCATE main_box.row1 + 6, main_box.col1 + (main_box.col2 - main_box.col1) \ 2 - LEN(t$) / 2
                PRINT t$;
            ELSE
                COLOR selsav(4, 1) - 1, selsav(4, 2) - 1
                LOCATE main_box.row1 + 6, main_box.col1 + 4
                PRINT " M";
                COLOR selsav(8, 1) - 1
                PRINT "e";
                COLOR selsav(4, 1) - 1
                PRINT "nu ALT character color ";

                COLOR selsav(8, 2) - 1, selsav(1, 2) - 1
                LOCATE main_box.row1 + 6, main_box.col1 + 30
                PRINT "   Selected GUI item.  ";
            END IF
            IF drop_flag THEN
                draw_box gui(1), 0
                draw_box gui(s_box), 1
                FOR x = 1 TO ddlen(s_box - 1)
                    IF x <> ddsel(s_box - 1) THEN COLOR gui(1).c1, gui(1).c2 ELSE COLOR gui(1).sc1, gui(1).sc2: curr = gui(1).row1 + x: curc = gui(1).col1 + 1
                    LOCATE gui(1).row1 + x, gui(1).col1 + 1
                    PRINT LEFT$(ddarr$(s_box - 1, x) + SPACE$(gui(1).col2 - gui(1).col1 - 1), gui(1).col2 - gui(1).col1 - 1);
                NEXT x
            END IF
            IF in_test THEN
                k = prompt_dialog("Keep these settings?", 10, YES_BUTTON OR NO_BUTTON, NO_BUTTON)
                IF k = NO_BUTTON THEN
                    scrnw = colback
                    scrnh = rowback
                    main_gui_c1 = backup(1, 1) - 1
                    main_gui_c2 = backup(1, 2) - 1
                    main_gui_sel_c1 = backup(2, 1) - 1
                    main_gui_sel_c2 = backup(2, 2) - 1
                    status_c1 = backup(3, 1) - 1
                    status_c2 = backup(3, 2) - 1
                    menu_c1 = backup(4, 1) - 1
                    menu_c2 = backup(4, 2) - 1
                    menu_sel_c1 = backup(5, 1) - 1
                    menu_sel_c2 = backup(5, 2) - 1
                    box_c1 = backup(6, 1) - 1
                    box_c2 = backup(6, 2) - 1
                    box_sel_c1 = backup(7, 1) - 1
                    box_sel_c2 = backup(7, 2) - 1
                    menu_char_c = backup(8, 1) - 1
                    file_non_sel = backup(8, 2) - 1

                    FOR x = 1 TO 8
                        FOR y = 1 TO 2
                            selsav(x, y) = backup(x, y)
                        NEXT y
                    NEXT x
                    put_str gui(5).text, LTRIM$(STR$(scrnh))
                    put_str gui(6).text, LTRIM$(STR$(scrnw))
                    setup_main_GUI
                    GOSUB setup_box
                    update_scrn
                ELSE
                    colback = scrnw
                    rowback = scrnh
                    FOR x = 1 TO 8
                        FOR y = 1 TO 2
                            backup(x, y) = selsav(x, y)
                        NEXT y
                    NEXT x
                END IF
                in_test = 0
                update = -1
            END IF
            _AUTODISPLAY
            LOCATE curr, curc, 1
        END IF
        k$ = INKEY$
        tes = update_input_boxes(gui(), s_box, k$)
        IF tes THEN update = -1
        SELECT CASE k$
            CASE CHR$(0) + CHR$(72) 'up
                IF drop_flag THEN
                    IF ddsel(s_box - 1) > 1 THEN
                        ddsel(s_box - 1) = ddsel(s_box - 1) - 1
                        selsav(loaded, 1) = ddsel(2)
                        selsav(loaded, 2) = ddsel(3)

                        update = -1
                    END IF
                END IF
            CASE CHR$(0) + CHR$(80) 'down
                IF drop_flag THEN
                    IF ddsel(s_box - 1) < ddlen(s_box - 1) THEN
                        ddsel(s_box - 1) = ddsel(s_box - 1) + 1
                        selsav(loaded, 1) = ddsel(2)
                        selsav(loaded, 2) = ddsel(3)

                        update = -1
                    END IF
                ELSEIF s_box > 1 AND s_box < 5 THEN
                    drop_flag = -1
                    gui(1).row1 = gui(s_box).row1
                    gui(1).row2 = gui(1).row1 + ddlen(s_box - 1) + 1
                    IF gui(1).row2 > _HEIGHT(0) THEN gui(1).row2 = _HEIGHT(0)
                    gui(1).col1 = gui(s_box).col1
                    gui(1).col2 = gui(s_box).col2
                    gui(1).selected = ddsel(s_box - 1)
                    gui(s_box).d_flag = -1
                    update = -1
                END IF
            CASE CHR$(13)
                IF drop_flag THEN
                    gui(s_box).d_flag = 0
                    drop_flag = 0
                    gui(1).row1 = 0
                    gui(1).row2 = 0
                    gui(1).col1 = 0
                    gui(1).col2 = 0
                    update = -1
                ELSEIF s_box > 5 THEN
                    but = -1
                    m = s_box
                END IF
            CASE CHR$(9)
                IF drop_flag THEN
                    gui(s_box).d_flag = 0
                    drop_flag = 0
                    gui(1).row1 = 0
                    gui(1).row2 = 0
                    gui(1).col1 = 0
                    gui(1).col2 = 0
                END IF
                s_box = (s_box MOD gui_num) + 1
                IF s_box = 1 THEN s_box = 2
                update = -1
            CASE CHR$(27)
                exit_flag = -1
        END SELECT
        IF but THEN
            IF m = 1 THEN

            ELSEIF m = 7 THEN
                scrnh = VAL(get_str$(gui(5).text))
                scrnw = VAL(get_str$(gui(6).text))
                main_gui_c1 = selsav(1, 1) - 1
                main_gui_c2 = selsav(1, 2) - 1
                main_gui_sel_c1 = selsav(2, 1) - 1
                main_gui_sel_c2 = selsav(2, 2) - 1
                status_c1 = selsav(3, 1) - 1
                status_c2 = selsav(3, 2) - 1
                menu_c1 = selsav(4, 1) - 1
                menu_c2 = selsav(4, 2) - 1
                menu_sel_c1 = selsav(5, 1) - 1
                menu_sel_c2 = selsav(5, 2) - 1
                box_c1 = selsav(6, 1) - 1
                box_c2 = selsav(6, 2) - 1
                box_sel_c1 = selsav(7, 1) - 1
                box_sel_c2 = selsav(7, 2) - 1
                menu_char_c = selsav(8, 1) - 1
                file_non_sel = selsav(8, 2) - 1

                setup_main_GUI
                GOSUB setup_box
                update_scrn
                update = -1
                in_test = -1
            ELSEIF m = 8 THEN
                k = prompt_dialog("Save current settings to FTP_Config.cfg in current directory?" + CHR$(13) + "Note: Make sure to apply your settings by clicking" + CHR$(13) + "the 'change' button before saving.", 0, YES_BUTTON OR NO_BUTTON, NO_BUTTON)
                IF k = YES_BUTTON THEN
                    write_config_file
                END IF
            ELSEIF m = 9 THEN
                exit_flag = -1
            END IF
        END IF
    LOOP UNTIL exit_flag
    LOCATE , , 0
    free_gui_element main_box
    free_gui_array gui()
    EXIT SUB

    setup_box:
    main_box.row1 = _HEIGHT(0) \ 2 - 8
    main_box.row2 = _HEIGHT(0) \ 2 + 8
    main_box.col1 = _WIDTH(0) \ 2 - 30
    main_box.col2 = _WIDTH(0) \ 2 + 30
    gui(2).row1 = main_box.row1 + 1
    gui(2).col1 = main_box.col1 + 10
    gui(2).col2 = gui(2).col1 + 40
    gui(3).row1 = main_box.row1 + 3
    gui(3).col1 = main_box.col1 + 5
    gui(3).col2 = gui(3).col1 + 20
    gui(4).row1 = main_box.row1 + 3
    gui(4).col1 = main_box.col2 - 25
    gui(4).col2 = gui(4).col1 + 20
    gui(5).row1 = main_box.row2 - 6
    gui(5).row2 = gui(5).row1 + 2
    gui(5).col1 = main_box.col1 + 2
    gui(5).col2 = gui(5).col1 + (main_box.col2 - main_box.col1) \ 2 - 3
    gui(6).row1 = main_box.row2 - 6
    gui(6).row2 = gui(6).row1 + 2
    gui(6).col1 = gui(5).col2 + 2
    gui(6).col2 = main_box.col2 - 2
    gui(7).row1 = main_box.row2 - 2
    gui(7).col1 = (main_box.col2 - main_box.col1) / 4 + main_box.col1 - 4
    gui(8).row1 = main_box.row2 - 2
    gui(8).col1 = ((main_box.col2 - main_box.col1) / 4) * 2 + main_box.col1 - 3
    gui(9).row1 = main_box.row2 - 2
    gui(9).col1 = ((main_box.col2 - main_box.col1) / 4) * 3 + main_box.col1 - 3
    main_box.c1 = box_c1
    main_box.c2 = box_c2
    gui(1).c1 = box_c1
    gui(1).c2 = box_c2
    gui(1).sc1 = box_sel_c1
    gui(1).sc2 = box_sel_c2
    gui(2).c1 = box_c1
    gui(2).c2 = box_c2
    gui(2).sc1 = box_sel_c1
    gui(2).sc2 = box_sel_c2
    gui(3).c1 = box_c1
    gui(3).c2 = box_c2
    gui(3).sc1 = box_sel_c1
    gui(3).sc2 = box_sel_c2
    gui(4).c1 = box_c1
    gui(4).c2 = box_c2
    gui(4).sc1 = box_sel_c1
    gui(4).sc2 = box_sel_c2
    gui(5).c1 = box_c1
    gui(5).c2 = box_c2
    gui(6).c1 = box_c1
    gui(6).c2 = box_c2
    gui(7).c1 = box_c1
    gui(7).c2 = box_c2
    gui(7).sc1 = box_sel_c1
    gui(7).sc2 = box_sel_c2
    gui(8).c1 = box_c1
    gui(8).c2 = box_c2
    gui(8).sc1 = box_sel_c1
    gui(8).sc2 = box_sel_c2
    gui(9).c1 = box_c1
    gui(9).c2 = box_c2
    gui(9).sc1 = box_sel_c1
    gui(9).sc2 = box_sel_c2

    RETURN
END SUB

SUB about_dialog () 'Displays 'about' box
    DIM box AS box_type, ok_button(1) AS box_type
    'box.nam = "About"
    put_str box.nam, "About"
    box.row1 = _HEIGHT(0) \ 2 - 3
    box.row2 = box.row1 + 7
    box.col1 = _WIDTH(0) \ 2 - 20
    box.col2 = _WIDTH(0) \ 2 + 20
    box.shadow = -1
    box.c1 = box_c1
    box.c2 = box_c2
    box.text_box = -1

    ok_button(1).button = -1
    ok_button(1).row1 = box.row2 - 1
    'ok_button(1).nam = "Close"
    put_str ok_button(1).nam, "Close"
    ok_button(1).col1 = box.col1 + (box.col2 - box.col1) \ 2 - 2
    ok_button(1).c1 = box_c1
    ok_button(1).c2 = box_c2
    ok_button(1).sc1 = box_sel_c1
    ok_button(1).sc2 = box_sel_c2

    update = -1
    exit_gui_flag = 0
    DO: _LIMIT 100
        m = mouse_range(ok_button(), 1)
        IF update THEN
            update = 0
            draw_box box, 0
            draw_box ok_button(1), 1
            COLOR box_c1, box_c2
            d$ = "FTP Client version " + VER$
            LOCATE box.row1 + 2, _WIDTH(0) \ 2 - LEN(d$) \ 2
            PRINT d$;
            d$ = "Written by Matt Kilgore in QB64"
            LOCATE box.row1 + 4, _WIDTH(0) \ 2 - LEN(d$) \ 2
            PRINT d$;
            _AUTODISPLAY
            LOCATE ok_button(1).row1, ok_button(1).col1 + 1, 1
        END IF
        IF m = 1 OR INKEY$ > "" THEN: LOCATE , , 0: exit_gui_flag = -1
    LOOP UNTIL exit_gui_flag
    free_gui_element box
    free_gui_array ok_button()
END SUB

SUB delete_file_GUI (local_or_remote AS INTEGER)
    'meaning of local_or_remote:
    'local_or_remote = 1 -- local
    'local_or_remote = 0 -- remote

    IF local_or_remote = 0 AND is_connected = 0 THEN
        dialog_disp "Please connect to a server first."
        EXIT SUB
    END IF

    IF local_or_remote = 0 THEN
        file$ = RTRIM$(get_str$(Remote_files(boxes(2).selected).nam))
    ELSE
        file$ = RTRIM$(get_str$(Local_files(boxes(1).selected).nam))
    END IF

    IF file$ = ".." THEN EXIT SUB 'we can't delete '..'

    prompt$ = "Do you really want to delete " + file$ + "?"
    response = prompt_dialog(prompt$, 0, YES_BUTTON OR NO_BUTTON, NO_BUTTON)

    IF response = YES_BUTTON THEN
        IF local_or_remote = 1 THEN
            delete_local_file file$
        ELSE
            delete_remote_file file$
        END IF
    END IF
END SUB

SUB read_config_file () 'If a Config file exists, then it loads the settings from it
    'config file a bit advanced. still not really though. Made to be editable outside of the program
    ON ERROR GOTO error_flag
    IF opper$ = "NIX" THEN
        OPEN "./FTP_Config.cfg" FOR INPUT AS #1
    ELSE
        OPEN "FTP_config.cfg" FOR INPUT AS #1
    END IF
    IF err_flag THEN
        CLOSE #1
        EXIT SUB
    END IF

    IF LOF(1) > 0 THEN
        DO WHILE NOT EOF(1)
            LINE INPUT #1, lin$
            lin$ = RTRIM$(LTRIM$(lin$))
            IF LEFT$(lin$, 1) <> "#" THEN
                var$ = LCASE$(LTRIM$(RTRIM$(MID$(lin$, 1, INSTR(lin$, "=") - 1))))
                val$ = LTRIM$(RTRIM$(MID$(lin$, INSTR(lin$, "=") + 1)))
                IF var$ = "box_c1" THEN
                    box_c1 = VAL(val$)
                ELSEIF var$ = "box_c2" THEN
                    box_c2 = VAL(val$)
                ELSEIF var$ = "box_sel_c1" THEN
                    box_sel_c1 = VAL(val$)
                ELSEIF var$ = "box_sel_c2" THEN
                    box_sel_c2 = VAL(val$)
                ELSEIF var$ = "file_non_sel" THEN
                    file_non_sel = VAL(val$)
                ELSEIF var$ = "main_gui_c1" THEN
                    main_gui_c1 = VAL(val$)
                ELSEIF var$ = "main_gui_c2" THEN
                    main_gui_c2 = VAL(val$)
                ELSEIF var$ = "main_gui_sel_c1" THEN
                    main_gui_sel_c1 = VAL(val$)
                ELSEIF var$ = "main_gui_sel_c2" THEN
                    main_gui_sel_c2 = VAL(val$)
                ELSEIF var$ = "menu_c1" THEN
                    menu_c1 = VAL(val$)
                ELSEIF var$ = "menu_c2" THEN
                    menu_c2 = VAL(val$)
                ELSEIF var$ = "menu_char_c" THEN
                    menu_char_c = VAL(val$)
                ELSEIF var$ = "menu_sel_c1" THEN
                    menu_sel_c1 = VAL(val$)
                ELSEIF var$ = "menu_sel_c2" THEN
                    menu_sel_c2 = VAL(val$)
                ELSEIF var$ = "scrnh" THEN
                    scrnh = VAL(val$)
                ELSEIF var$ = "scrnw" THEN
                    scrnw = VAL(val$)
                ELSEIF var$ = "status_c1" THEN
                    status_c1 = VAL(val$)
                ELSEIF var$ = "status_c2" THEN
                    status_c2 = VAL(val$)
                ELSEIF var$ = "scrnh" THEN
                    scrnh = VAL(val$)
                ELSEIF var$ = "scrnw" THEN
                    scrnw = VAL(val$)
                END IF
            END IF
        LOOP
    END IF
    CLOSE #1
END SUB

SUB write_config_file () 'Makes a Config file
    IF opper$ = "NIX" THEN
        OPEN "./FTP_Config.cfg" FOR OUTPUT AS #1
    ELSE
        OPEN "FTP_Config.cfg" FOR OUTPUT AS #1
    END IF
    PRINT #1, "# Configuration file for QB64 FTP Client"
    PRINT #1, ""
    PRINT #1, "box_c1="; box_c1
    PRINT #1, "box_c2="; box_c2
    PRINT #1, "box_sel_c1="; box_sel_c1
    PRINT #1, "box_Sel_c2="; box_sel_c2
    PRINT #1, "file_non_sel="; file_non_sel
    PRINT #1, "main_gui_c1="; main_gui_c1
    PRINT #1, "main_gui_c2="; main_gui_c2
    PRINT #1, "main_gui_sel_c1="; main_gui_sel_c1
    PRINT #1, "main_gui_sel_c2="; main_gui_sel_c2
    PRINT #1, "menu_char_c="; menu_char_c
    PRINT #1, "menu_c1="; menu_c1
    PRINT #1, "menu_c2="; menu_c2
    PRINT #1, "menu_sel_c1="; menu_sel_c1
    PRINT #1, "menu_Sel_c2="; menu_sel_c2
    PRINT #1, "status_c1="; status_c1
    PRINT #1, "status_c2="; status_c2
    PRINT #1, "scrnh="; scrnh
    PRINT #1, "scrnw="; scrnw
    CLOSE #1
END SUB

SUB command_line () 'Command line implimentation
    _AUTODISPLAY

    IF CLI THEN
        _DEST _CONSOLE
    END IF

    cmd_mode = -1
    exit_key$ = CHR$(27)
    COLOR 7, 0
    CLS
    prompt$ = "FTP> "

    DIM f$(5)
    f$(1) = "FTP Command Line Ver:" + VER$
    f$(2) = "Written in QB64 by Matt Kilgore"
    f$(3) = "Type 'HELP' for a list of commands"
    f$(4) = "Type 'HELP command' for help on 'command'"
    FOR x = 1 TO UBOUND(f$)
        PRINT f$(x)
    NEXT x
    get_new_dir
    DO
        cmd$ = ""
        PRINT prompt$;
        row = CSRLIN
        col = POS(0)
        update = -1
        cursor = 1
        exit_flag = 0
        IF NOT CLI THEN
            DO
                IF update THEN
                    update = 0
                    IF row + (LEN(cmd$) + col) \ _WIDTH(0) > _HEIGHT(0) - 1 THEN
                        LOCATE _HEIGHT(0)
                        DO
                            PRINT
                            row = row - 1
                        LOOP UNTIL row + (LEN(cmd$) + col) \ _WIDTH(0) <= _HEIGHT(0) - 1
                    END IF
                    LOCATE row, col
                    PRINT LEFT$(cmd$, _WIDTH(0) - col + 1);
                    IF LEN(cmd$) + col > _WIDTH(0) THEN
                        FOR x = 1 TO ((LEN(cmd$) + col) \ _WIDTH(0))
                            LOCATE row + x, 1
                            PRINT MID$(cmd$ + SPACE$(_WIDTH(0)), x * _WIDTH(0) - col + 2, _WIDTH(0));
                        NEXT x
                    END IF
                    IF LEN(cmd$) + col <= _WIDTH(0) THEN PRINT " ";
                    LOCATE row + (col + cursor - 2) \ (_WIDTH(0)), (col + cursor - 2) MOD _WIDTH(0) + 1, 1
                END IF
                a$ = INKEY$
                SELECT CASE a$
                    CASE " " TO "~"
                        IF LEN(cmd$) < 300 THEN
                            cmd$ = MID$(cmd$, 1, cursor - 1) + a$ + MID$(cmd$, cursor)
                            cursor = cursor + 1
                            update = -1
                        END IF
                    CASE CHR$(8)
                        IF cursor > 1 THEN
                            cmd$ = MID$(cmd$, 1, cursor - 2) + MID$(cmd$, cursor)
                            cursor = cursor - 1
                            update = -1
                        END IF
                    CASE CHR$(0) + CHR$(75)
                        IF cursor > 1 THEN cursor = cursor - 1: update = -1
                    CASE CHR$(0) + CHR$(77)
                        IF cursor <= LEN(cmd$) THEN cursor = cursor + 1: update = -1
                    CASE CHR$(22)
                        cmd$ = MID$(cmd$, 1, cursor - 1) + _CLIPBOARD$ + MID$(cmd$, cursor)
                        cmd$ = LEFT$(cmd$, 300)
                        update = update + 1
                    CASE CHR$(13), exit_key$
                        exit_flag = -1
                        PRINT
                    CASE CHR$(9) 'Tab menu
                        'cmd$ = LTRIM$(RTRIM$(cmd$))
                        Ucmd$ = UCASE$(LTRIM$(RTRIM$(cmd$)))
                        PRINT
                        IF INSTR(Ucmd$, " ") THEN
                        ELSE
                            PRINT "Possible Commands:"
                            FOR x = 1 TO cmds
                                IF LEFT$(commands$(x), LEN(Ucmd$)) = Ucmd$ THEN
                                    PRINT commands$(x),
                                END IF
                            NEXT x
                            PRINT
                        END IF
                        PRINT prompt$;
                        row = CSRLIN
                        col = POS(0)
                        update = -1
                END SELECT
            LOOP UNTIL exit_flag
        ELSE
            LINE INPUT ; cmd$
        END IF
        IF cmd$ > "" THEN
            cmd$ = LTRIM$(RTRIM$(cmd$))
            Ucmd$ = UCASE$(cmd$)
            'do something based on cmd$, or Ucmd$
            IF LEFT$(Ucmd$, 7) = "SCRIPT " THEN
                echo_flag = -1
                ON ERROR GOTO error_flag
                err_flag = 0
                OPEN MID$(cmd$, 8) FOR INPUT AS #1
                IF err_flag THEN
                    CLOSE #1
                    PRINT "Error opening script file."
                ELSE
                    IF LOF(1) > 0 THEN
                        DO
                            LINE INPUT #1, cmd$
                            'Ucmd$ = UCASE$(cmd$)
                            IF UCASE$(cmd$) <> "@ECHO ON" AND UCASE$(cmd$) <> "@ECHO OFF" THEN
                                IF echo_flag THEN PRINT prompt$; cmd$
                                Run_Cmd cmd$
                            ELSEIF UCASE$(cmd$) = "@ECHO ON" THEN
                                echo_flag = -1
                            ELSEIF UCASE$(cmd$) = "@ECHO OFF" THEN
                                echo_flag = 0
                            END IF
                        LOOP UNTIL EOF(1) OR cmd_mode = 0
                        CLOSE #1
                    END IF
                END IF
            ELSE
                Run_Cmd cmd$
            END IF
        END IF
    LOOP UNTIL a$ = exit_key$ OR cmd_mode = 0
    IF NOT CLI THEN _DISPLAY
    cmd_mode = 0
    LOCATE , , 0
END SUB

SUB Run_Cmd (cmd$) 'Runs Command Line command cmd$
    ucmd$ = UCASE$(cmd$)
    IF LEFT$(ucmd$, 5) = "ECHO " THEN
        PRINT MID$(cmd$, 6)
    ELSEIF LEFT$(ucmd$, 5) = "HELP " THEN
        c$ = MID$(ucmd$, 6)
        FOR x = 1 TO cmd_count
            IF commands$(x) = c$ THEN
                PRINT "HELP ON " + c$ + " COMMAND:"
                PRINT
                FOR m = 1 TO helplen(x)
                    h$ = help$(x, m)
                    IF NOT CLI THEN
                        DO
                            IF LEN(h$) > _WIDTH(0) THEN
                                st = 0
                                FOR s = _WIDTH(0) TO 1 STEP -1
                                    IF MID$(h$, s, 1) = " " THEN
                                        st = s
                                        EXIT FOR
                                    END IF
                                NEXT s
                                m$ = MID$(h$, 1, st)
                                h$ = MID$(h$, st + 1)
                            ELSE
                                m$ = h$
                                h$ = ""
                            END IF
                            PRINT m$
                        LOOP UNTIL h$ = ""
                    ELSE
                        PRINT h$
                    END IF
                NEXT m
            END IF
        NEXT x
    ELSEIF LEFT$(ucmd$, 4) = "HELP" THEN
        PRINT "Commands:"
        FOR x = 1 TO cmd_count
            PRINT commands$(x),
        NEXT x
        PRINT
    ELSEIF LEFT$(ucmd$, 4) = "EXIT" THEN
        cmd_mode = 0
        EXIT SUB
    ELSEIF LEFT$(ucmd$, 7) = "CONNECT" THEN
        txt$ = MID$(cmd$, 9)
        IF txt$ > "" THEN
            IF INSTR(txt$, "@") THEN
                server$ = MID$(txt$, INSTR(txt$, "@") + 1)
                left_s$ = MID$(txt$, 1, INSTR(txt$, "@") - 1)
            ELSE
                server$ = txt$
                left_s$ = ""
            END IF
            IF INSTR(server$, ":") THEN
                port$ = MID$(server$, INSTR(server$, ":") + 1)
                server$ = MID$(server$, 1, INSTR(server$, ":") - 1)
            ELSE
                port$ = "21"
            END IF
            IF left_s$ > "" THEN
                IF INSTR(left_s$, ":") THEN
                    username$ = MID$(left_s$, 1, INSTR(left_s$, ":") - 1)
                    password$ = MID$(left_s$, INSTR(left_s$, ":") + 1)
                ELSE
                    username$ = left_s$
                    password$ = ""
                END IF
            ELSE
                username$ = "anonymous"
                password$ = ""
            END IF

            Start_ftp_connect
        ELSE
            PRINT "Please call this command with paramaters for the FTP server to connect to"
            PRINT
        END IF
    ELSEIF LEFT$(ucmd$, 4) = "LDIR" THEN
        IF LEN(ucmd$) > 4 THEN
            flags$ = MID$(cmd$, 5)
        ELSE
            flags$ = ""
        END IF
        CLI_List_Local_Files flags$
    ELSEIF LEFT$(ucmd$, 3) = "LCD" THEN
        IF LEN(ucmd$) > 3 THEN
            ON ERROR GOTO error_flag
            err_flag = 0
            CHDIR MID$(cmd$, 5)
            IF err_flag THEN
                PRINT "Couldn't change to directory."
            END IF
            get_new_dir
        ELSE
            PRINT "Please specefy a directory to change to."
        END IF
    ELSEIF LEFT$(ucmd$, 3) = "DIR" THEN
        k$ = MID$(ucmd$, 4)
        IF INSTR(k$, "--NLIST") THEN
            unlist = -1
            flags$ = ""
        ELSE
            unlist = 0
            flags$ = MID$(cmd$, 4)
        END IF
        CLI_List_Remote_Files unlist, flags$
    ELSEIF LEFT$(ucmd$, 2) = "CD" THEN
        di$ = MID$(cmd$, 3)
        IF di$ > "" THEN
            change_remote_dir di$
        ELSE
            PRINT "Please include a directory to change to"
        END IF
    ELSEIF LEFT$(ucmd$, 3) = "PWD" THEN
        IF is_connected THEN Get_remote_dir: PRINT Remote_dir$ ELSE PRINT "Please connect to a FTP server first."
    ELSEIF LEFT$(ucmd$, 4) = "LPWD" THEN
        get_new_dir
        PRINT Local_dir$
    ELSEIF LEFT$(ucmd$, 6) = "STATUS" THEN
        PRINT status$
    ELSEIF LEFT$(ucmd$, 5) = "PAUSE" THEN
        PRINT "Press any key to continue..."
        DO: LOOP UNTIL INKEY$ > ""
    ELSEIF LEFT$(ucmd$, 6) = "SCRIPT" THEN
        echo_flag = -1
        ON ERROR GOTO error_flag
        err_flag = 0
        OPEN MID$(cmd$, 8) FOR INPUT AS #1
        IF err_flag THEN
            CLOSE #1
            PRINT "Error opening script file."
        ELSE
            IF LOF(1) > 0 THEN
                DO
                    LINE INPUT #1, cmd$
                    'Ucmd$ = UCASE$(cmd$)
                    IF UCASE$(cmd$) <> "@ECHO ON" AND UCASE$(cmd$) <> "@ECHO OFF" THEN
                        IF echo_flag THEN PRINT prompt$; cmd$
                        Run_Cmd cmd$
                    ELSEIF UCASE$(cmd$) = "@ECHO ON" THEN
                        echo_flag = -1
                    ELSEIF UCASE$(cmd$) = "@ECHO OFF" THEN
                        echo_flag = 0
                    END IF
                LOOP UNTIL EOF(1) OR cmd_mode = 0
                CLOSE #1
            END IF
        END IF
    ELSEIF LEFT$(ucmd$, 7) = "LRENAME" THEN
        n$ = RTRIM$(LTRIM$(MID$(cmd$, 8)))
        IF n$ > "" THEN
            IF LEFT$(n$, 1) = CHR$(34) THEN 'in quotes
                f_old$ = MID$(MID$(n$, 2), 1, INSTR(MID$(n$, 2), CHR$(34)) - 1)
                n$ = MID$(MID$(n$, 2), INSTR(MID$(n$, 2), CHR$(34)) + 1)
                n$ = MID$(n$, INSTR(n$, ","))
            ELSE
                f_old$ = MID$(n$, 1, INSTR(n$, ",") - 1)
                n$ = MID$(n$, INSTR(n$, ","))
            END IF
            IF n$ > "" THEN
                n$ = MID$(n$, 2)
                IF LEFT$(n$, 1) = CHR$(34) THEN
                    f_new$ = MID$(MID$(n$, 2), 1, INSTR(MID$(n$, 2), CHR$(34)) - 1)
                ELSE
                    f_new$ = LTRIM$(RTRIM$(n$))
                END IF
                ON ERROR GOTO error_flag
                err_flag = 0
                NAME f_old$ AS f_new$
                IF err_flag THEN
                    PRINT "Error changing name of Local file..."
                END IF
                refresh_Local_files
            ELSE
                PRINT "Please include a second file name to change to"
            END IF
        ELSE
            PRINT "Please include a file name, and a file name to change to."
        END IF
    ELSEIF LEFT$(ucmd$, 6) = "RENAME" THEN
        n$ = RTRIM$(LTRIM$(MID$(cmd$, 7)))
        IF n$ > "" THEN
            IF LEFT$(n$, 1) = CHR$(34) THEN 'in quotes
                f_old$ = MID$(MID$(n$, 2), 1, INSTR(MID$(n$, 2), CHR$(34)) - 1)
                n$ = MID$(MID$(n$, 2), INSTR(MID$(n$, 2), CHR$(34)) + 1)
                n$ = MID$(n$, INSTR(n$, ","))
            ELSE
                f_old$ = MID$(n$, 1, INSTR(n$, ",") - 1)
                n$ = MID$(n$, INSTR(n$, ","))
            END IF
            IF n$ > "" THEN
                n$ = RTRIM$(LTRIM$(MID$(n$, 2)))
                IF LEFT$(n$, 1) = CHR$(34) THEN
                    f_new$ = MID$(MID$(n$, 2), 1, INSTR(MID$(n$, 2), CHR$(34)) - 1)
                ELSE
                    f_new$ = LTRIM$(RTRIM$(n$))
                END IF
                IF is_connected THEN
                    Rename_remote_file_dir f_old$, f_new$, -1
                ELSE
                    dialog_disp "Please connect to a server first."
                END IF
            ELSE
                PRINT "Please include a second file name to change to"
            END IF
        ELSE
            PRINT "Please include a file name, and a file name to change to."
        END IF

    ELSEIF LEFT$(ucmd$, 3) = "GET" THEN
        fil$ = RTRIM$(LTRIM$(MID$(cmd$, 4)))
        IF LEFT$(fil$, 1) = CHR$(34) THEN
            fil$ = MID$(fil$, 2)
            fil$ = MID$(fil$, 1, INSTR(fil$, CHR$(34)) - 1)
        END IF
        IF fil$ > "" THEN
            get_file fil$
        ELSE
            PRINT "Please include a file name."
        END IF
    ELSEIF LEFT$(ucmd$, 3) = "PUT" THEN
        fil$ = RTRIM$(LTRIM$(MID$(cmd$, 4)))
        IF LEFT$(fil$, 1) = CHR$(34) THEN
            fil$ = MID$(fil$, 2)
            fil$ = MID$(fil$, 1, INSTR(fil$, CHR$(34)) - 1)
        END IF
        IF fil$ > "" THEN
            send_file fil$
        ELSE
            PRINT "Please include a file name."
        END IF
    ELSE
        PRINT "Command or file not found..."
    END IF
END SUB

SUB CLI_List_Local_Files (flags$) 'Lists the Local files in the current dir in the command line
    IF NOT CLI THEN
        f$ = temp_dir$ + sep$ + "filetemp.tmp"
        IF opper$ = "NIX" THEN
            SHELL _HIDE "ls " + flags$ + " > " + f$
        ELSEIF opper$ = "WIN" THEN
            SHELL _HIDE "cmd /c DIR " + flags$ + " > " + f$
        END IF
        OPEN f$ FOR INPUT AS #1
        c = 0
        DO WHILE NOT EOF(1)
            LINE INPUT #1, a$
            PRINT a$
            IF LEN(a$) > 0 THEN
                c = c + (LEN(a$) - 1) \ _WIDTH(0) + 1
            ELSE
                c = c + 1
            END IF
            IF c MOD (_HEIGHT(0) - 2) = 0 THEN
                PRINT "Press any key to continue...";
                DO: LOOP UNTIL INKEY$ > ""
                PRINT
            END IF
        LOOP
        CLOSE #1
    ELSE
        IF opper$ = "NIX" THEN
            SHELL _HIDE "ls " + flags$ '+ " > " + f$
        ELSEIF opper$ = "WIN" THEN
            SHELL _HIDE "cmd /c DIR " '+ flags$ + " > " + f$
        END IF
    END IF
END SUB

SUB CLI_List_Remote_Files (use_nlist, flags$) 'List files on remote directory
    IF NOT is_connected THEN PRINT "Please connect to a server first...": EXIT SUB

    start_PASV_mode
    IF data_connect& = 0 THEN PRINT "Could not start PASV mode...": EXIT SUB

    IF NOT use_nlist THEN upd$ = "LIST " + flags$ + crlf$
    IF use_nlist THEN upd$ = "NLST" + crlf$

    PUT command_connect&, , upd$
    a2$ = get_response_code$
    n$ = LEFT$(a2$, 3)
    SELECT CASE n$
        CASE "450", "500", "501", "502", "530"
            PRINT "Error, server doesn't support " + LEFT$(upd$, LEN(upd$) - 1)
            EXIT SUB
    END SELECT

    t# = TIMER
    DO: _LIMIT 1000
        GET data_connect&, , a$
        dirs$ = dirs$ + a$
        GET command_connect&, , b$
        b2$ = b2$ + b$
    LOOP UNTIL INSTR(b2$, crlf$) OR TIMER - t# > 10 OR NOT _CONNECTED(data_connect&)

    CLOSE data_connect&
    IF TIMER - t# > 10 THEN
        PRINT "Error: Server timed out when sending the Directory/Files list"
        EXIT SUB
    END IF
    IF b2$ = "" THEN b2$ = get_response_code$
    n$ = LEFT$(b2$, 3)
    SELECT CASE n$
        CASE "226", "250"
            c = 0
            d$ = dirs$
            DO
                a$ = MID$(d$, 1, INSTR(d$, crlf$) - 1)
                d$ = MID$(d$, INSTR(d$, crlf$) + 2)

                PRINT a$
                IF LEN(a$) > 0 THEN
                    c = c + (LEN(a$) - 1) \ _WIDTH(0) + 1
                ELSE
                    c = c + 1
                END IF
                IF c MOD (_HEIGHT(0) - 2) = 0 AND CLI = 0 THEN
                    PRINT "Press any key to continue...";
                    DO: LOOP UNTIL INKEY$ > ""
                    PRINT
                END IF
            LOOP UNTIL d$ = ""
        CASE "425", "426", "451"
            PRINT "Error, server doesn't support " + LEFT$(upd$, LEN(upd$) - 1)
            EXIT SUB

    END SELECT
END SUB

SUB change_remote_dir (dir$) 'Changes the remote directory to the selected dir
    IF is_connected THEN
        ch$ = "CWD " + LTRIM$(RTRIM$(dir$)) + crlf$
        PUT command_connect&, , ch$
        a$ = get_response_code$
        SELECT CASE LEFT$(a$, 3)
            CASE "500", "501", "502", "550", "530"
                dialog_disp "Error: The FTP server won't let you change the directory."
            CASE "421"
                dialog_disp "Error: FTP server disconnected."
                is_connected = 0
                CLOSE command_connect&
        END SELECT
    ELSEIF cmd_mode THEN PRINT "Please connect to a FTP server first."
    END IF
END SUB

SUB refresh_Local_files () 'Refreshes the local file listing
    boxes(1).length = 1
    boxes(1).selected = 1
    boxes(1).offset = 0
    put_str Local_files(boxes(1).length).nam, ".."
    Local_files(boxes(1).length).dir = "DIR"
    Local_files(boxes(1).length).flag_cwd = -1
    Local_files(boxes(1).length).flag_retr = 0
    IF opper$ = "NIX" THEN
        IF show_hidden_local THEN h$ = "a" ELSE h$ = ""
        SHELL _HIDE "ls -F" + h$ + " > /tmp/dirtmp.tmp"
        OPEN "/tmp/dirtmp.tmp" FOR INPUT AS #1
        DO WHILE NOT EOF(1)
            LINE INPUT #1, a$
            IF a$ > "" THEN
                IF RIGHT$(a$, 1) = "/" AND a$ <> "../" AND a$ <> "./" THEN
                    boxes(1).length = boxes(1).length + 1
                    put_str Local_files(boxes(1).length).nam, a$
                    Local_files(boxes(1).length).dir = "DIR"
                    Local_files(boxes(1).length).flag_cwd = -1
                    Local_files(boxes(1).length).flag_retr = 0
                END IF
                IF RIGHT$(a$, 1) = "@" THEN
                    boxes(1).length = boxes(1).length + 1
                    put_str Local_files(boxes(1).length).nam, LEFT$(a$, LEN(a$) - 1) + "/"
                    Local_files(boxes(1).length).dir = "DIR"
                    Local_files(boxes(1).length).flag_cwd = -1
                    Local_files(boxes(1).length).flag_retr = 0
                END IF
            END IF
        LOOP
        CLOSE #1

        OPEN "/tmp/dirtmp.tmp" FOR INPUT AS #1
        DO WHILE NOT EOF(1)
            LINE INPUT #1, a$
            IF a$ > "" THEN
                IF RIGHT$(a$, 1) <> "/" AND RIGHT$(a$, 1) <> "@" THEN
                    IF RIGHT$(a$, 1) = "*" THEN a$ = LEFT$(a$, LEN(a$) - 1)
                    boxes(1).length = boxes(1).length + 1
                    put_str Local_files(boxes(1).length).nam, a$
                    Local_files(boxes(1).length).dir = ""
                    Local_files(boxes(1).length).flag_cwd = 0
                    Local_files(boxes(1).length).flag_retr = -1
                END IF
            END IF
        LOOP
        CLOSE #1
        KILL "/tmp/dirtmp.tmp"
    ELSE 'I guess I better add that Windows code at some point...
        SHELL _HIDE "cmd /c DIR " + CHR$(34) + Local_dir$ + CHR$(34) + " /A:D /B > " + temp_dir$ + sep$ + "dirtmp.tmp"
        SHELL _HIDE "cmd /c DIR " + CHR$(34) + Local_dir$ + CHR$(34) + " /A:-D /B > " + temp_dir$ + sep$ + "filetmp.tmp"
        OPEN temp_dir$ + sep$ + "filetmp.tmp" FOR INPUT AS #1
        IF NOT EOF(1) THEN
            DO
                LINE INPUT #1, file$
                boxes(1).length = boxes(1).length + 1
                put_str Local_files(boxes(1).length).nam, file$
                Local_files(boxes(1).length).dir = ""
                Local_files(boxes(1).length).flag_cwd = 0
                Local_files(boxes(1).length).flag_retr = -1
            LOOP UNTIL EOF(1)
        END IF
        CLOSE #1
        KILL temp_dir$ + sep$ + "filetmp.tmp"
        OPEN temp_dir$ + sep$ + "dirtmp.tmp" FOR INPUT AS #1
        IF NOT EOF(1) THEN
            DO
                LINE INPUT #1, dir$
                boxes(1).length = boxes(1).length + 1
                put_str Local_files(boxes(1).length).nam, dir$ + sep$
                Local_files(boxes(1).length).dir = "DIR"
                Local_files(boxes(1).length).flag_cwd = -1
                Local_files(boxes(1).length).flag_retr = 0
            LOOP UNTIL EOF(1)
            CLOSE #1
        END IF
        KILL temp_dir$ + sep$ + "dirtmp.tmp"

    END IF
    sort_dir_listing Local_files(), boxes(1).length
    print_files boxes(1), Local_files()
END SUB

SUB get_new_dir () 'Uses SHELL to get the current dir
    IF opper$ = "NIX" THEN
        SHELL _HIDE "pwd > /tmp/dirtmp.tmp"
        OPEN "/tmp/dirtmp.tmp" FOR INPUT AS #1
        LINE INPUT #1, Local_dir$
        CLOSE #1
        KILL "/tmp/dirtmp.tmp"
    ELSEIF opper$ = "WIN" THEN
        SHELL _HIDE "cd > " + temp_dir$ + sep$ + "cdtemp.tmp"
        OPEN temp_dir$ + sep$ + "cdtemp.tmp" FOR INPUT AS #1
        LINE INPUT #1, Local_dir$
        CLOSE #1
        KILL temp_dir$ + sep$ + "cdtemp.tmp"
    END IF
END SUB

SUB send_file (file$) 'Sends local file to FTP server -- NOT IMPLEMENTED YET
    IF NOT cmd_mode THEN
        DIM box AS box_type
        'box.nam = "Send File"
        put_str box.nam, "Send File"
        box.row1 = _HEIGHT(0) \ 2 - 1
        box.row2 = _HEIGHT(0) \ 2 + 1
        box.col1 = _WIDTH(0) \ 2 - 25
        box.col2 = _WIDTH(0) \ 2 + 25
        box.shadow = -1
        box.c1 = box_c1
        box.c2 = box_c2
        box.text_box = -1
        draw_box box, 0
    END IF
    text$ = "Sending files is not yet possible, sorry."
    'IF is_connected THEN IF Local_files(boxes(1).selected).dir = "DIR" THEN text$ = "Error: Please select a file, not a directory." ELSE text$ = "Sending file..." ELSE text$ = "Please connect to a FTP Server first."
    IF NOT cmd_mode THEN LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
    PRINT text$
    IF NOT cmd_mode THEN _DISPLAY
    t# = TIMER
    IF NOT cmd_mode THEN DO: _LIMIT 100: LOOP UNTIL INKEY$ > "" OR TIMER - t# > 2
    EXIT SUB

    IF is_connected = 0 OR NOT Local_files(boxes(1).selected).flag_retr THEN
        t# = TIMER
        DO: _LIMIT 100: LOOP UNTIL INKEY$ > "" OR TIMER - t# > 1
        EXIT SUB
    END IF
    start_PASV_mode
    typei$ = "TYPE I" + crlf$
    PUT command_connect&, , typei$
    DO: _LIMIT 1000
        GET command_connect&, , b$
        b2$ = b2$ + b$
    LOOP UNTIL INSTR(b2$, crlf$)
    stor$ = "STOR " + RTRIM$(get_str$(Local_files(boxes(1).selected).nam)) + crlf$
    PUT command_connect&, , stor$
    DO: _LIMIT 1000
        GET command_connect&, , a$
        a2$ = a2$ + a$
        'IF LEFT$(a2$, 1) <> "2" AND INSTR(a2$, crlf$) THEN a2$ = MID$(a2$, INSTR(a2$, crlf$) + 2)
    LOOP UNTIL INSTR(a2$, crlf$)
    OPEN RTRIM$(get_str$(Local_files(boxes(1).selected).nam)) FOR BINARY AS #1
    dat$ = SPACE$(LOF(1))
    GET #1, , dat$

    PUT #data_connect&, , dat$

    CLOSE #1
    PRINT dat; LEN(dat$);
    DO
        x = bytes_left&(data_connect&)
        PRINT x;
        _DISPLAY
        _DELAY .05
    LOOP UNTIL x = 0
    CLOSE data_connect&
    PRINT dat;
    _DISPLAY
    SLEEP

    a2$ = ""
    draw_box box, 0
    text$ = "Waiting for Server to respond..."
    LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
    PRINT text$;
    _DISPLAY
    DO: _LIMIT 100
        GET command_connect&, , a$
        a2$ = a2$ + a$
    LOOP UNTIL INSTR(a2$, crlf$)
    IF LEFT$(a2$, 3) = "226" THEN
        text$ = "Sucessfully transfered!"
    ELSE
        text$ = "Transfer failed..."
    END IF
    SLEEP
    draw_box box, 0
    LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
    PRINT text$;
    t# = TIMER
    DO: _LIMIT 100: LOOP UNTIL INKEY$ > "" OR TIMER - t# > 1
    Update_Remote_Files
END SUB

SUB Update_Remote_Files () 'Refreshes the remote file listing
    IF NOT is_connected THEN boxes(2).length = 0: EXIT SUB
    IF NOT cmd_mode THEN
        DIM box AS box_type
        'box.nam = ""
        put_str box.nam, ""
        box.row1 = _HEIGHT(0) \ 2 - 1
        box.row2 = _HEIGHT(0) \ 2 + 1
        box.col1 = _WIDTH(0) \ 2 - 25
        box.col2 = _WIDTH(0) \ 2 + 25
        box.shadow = -1
        box.c1 = 0
        box.c2 = 7
        box.text_box = -1
        draw_box box, 0
        text$ = "Updating remote files list..."
        LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
    END IF
    PRINT text$;
    IF NOT cmd_mode THEN _DISPLAY
    upd$ = "PWD" + crlf$
    PUT command_connect&, , upd$
    a2$ = get_response_code$
    SELECT CASE LEFT$(a2$, 3)
        CASE "500", "501", "502", "550"
            Remote_dir$ = "FTP Serv doesn't support PWD"
        CASE "421"
            boxes(2).length = 0
            is_connected = 0
            CLOSE command_connect&
            status$ = "Not Connected."
            dialog_disp "Error: Server disconnected."
            EXIT SUB
    END SELECT
    Remote_dir$ = MID$(a2$, INSTR(a2$, CHR$(34)) + 1)
    Remote_dir$ = MID$(Remote_dir$, 1, INSTR(Remote_dir$, CHR$(34)) - 1)
    a2$ = ""
    start_PASV_mode
    IF data_connect& = 0 THEN EXIT SUB
    IF show_hidden_remote THEN h$ = "a" ELSE h$ = ""
    IF server_syst$ = "UNIX" THEN upd$ = "LIST -l" + h$ + crlf$ 'NLST was origonally used

    PUT command_connect&, , upd$
    a2$ = get_response_code$
    n$ = LEFT$(a2$, 3)
    SELECT CASE n$
        CASE "450", "500", "501", "502", "530"
            boxes(2).length = 2
            boxes(2).selected = 1
            boxes(2).offset = 0
            put_str Remote_files(1).nam, "FTP Server doesn't support LIST"
            put_str Remote_files(2).nam, "Try using the command line"
    END SELECT

    t# = TIMER

    DO
        _LIMIT 500
        GET data_connect&, , a$
        dirs$ = dirs$ + a$
        GET command_connect&, , b$
        b2$ = b2$ + b$
        'a5$ = a5$ + a$
    LOOP UNTIL INSTR(b2$, crlf$) OR TIMER - t# > 10 OR NOT _CONNECTED(data_connect&)

    CLOSE data_connect&
    'IF TIMER - t# > 10 THEN
    '  boxes(2).length = 2
    '  boxes(2).selected = 1
    '  boxes(2).offset = 0
    '
    '  Remote_files(1).nam = "FTP Server doesn't support NLST"
    '  Remote_files(2).nam = "Try using the command line"
    '  dialog_disp "Error: Server timed out when sending the Directory/Files list"
    '  EXIT SUB
    'END IF
    IF b2$ = "" THEN b2$ = get_response_code$ 'we have to make sure we got a response code
    n$ = LEFT$(b2$, 3)
    SELECT CASE n$
        CASE "226", "250", ""
            boxes(2).length = 1
            boxes(2).selected = 1
            boxes(2).offset = 0
            put_str Remote_files(1).nam, ".."
            Remote_files(1).dir = "DIR"
            Remote_files(1).flag_cwd = -1
            Remote_files(1).flag_retr = 0
            'OPEN temp_dir$ + sep$ + "temp.tmp" FOR OUTPUT AS #1
            'PRINT #1, dirs$
            'CLOSE #1
            IF LEN(dirs$) > 1 THEN
                'DO 'old NLST method
                '  di$ = MID$(dirs$, 1, INSTR(dirs$, crlf$) - 1)
                '  IF di$ <> "." AND di$ <> ".." THEN
                '    boxes(2).length = boxes(2).length + 1
                '    dirs$ = MID$(dirs$, INSTR(dirs$, crlf$) + 2)
                '    IF INSTR(di$, ".") THEN
                '      Remote_files(boxes(2).length).dir = ""
                '    ELSE
                '      Remote_files(boxes(2).length).dir = "DIR"
                '    END IF
                '    put_Str Remote_files(boxes(2).length).nam, di$
                '  END IF
                'LOOP UNTIL dirs$ = ""
                x = 0
                DO
                    di$ = MID$(dirs$, 1, INSTR(dirs$, crlf$) - 1)
                    dirs$ = MID$(dirs$, INSTR(dirs$, crlf$) + 2)
                    x = boxes(2).length + 1
                    put_str Remote_files(x).lin, di$
                    k = FTP_Parse_Line(Remote_files(x))
                    'IF Remote_files(x).flag_cwd AND Remote_files(x).flag_retr THEN
                    '  Remote_files(x).dir = "LNK"
                    'ELSEIF NOT Remote_files(x).flag_retr AND Remote_files(x).flag_cwd THEN
                    '  Remote_files(x).dir = "DIR"
                    'ELSE
                    '  Remote_files(x).dir = ""
                    'END IF
                    IF get_str$(Remote_files(x).nam) <> ".." AND get_str$(Remote_files(x).nam) <> "." AND get_str$(Remote_files(x).nam) > "" THEN boxes(2).length = x
                LOOP UNTIL dirs$ = ""
                sort_dir_listing Remote_files(), boxes(2).length
            END IF
        CASE "425", "426", "451"
            boxes(2).length = 2
            boxes(2).selected = 1
            boxes(2).offset = 0
            put_str Remote_files(1).nam, "FTP Server doesn't support NlST"
            put_str Remote_files(2).nam, "Try using the command line"
    END SELECT
    print_files boxes(2), Remote_files()
    update_scrn
END SUB

SUB start_PASV_mode () 'Call sub to start a PASV connect with FTP server on data_connect&
    pasv$ = "PASV" + crlf$
    PUT command_connect&, , pasv$
    'DO: _LIMIT 1000
    a2$ = get_response_code$
    SELECT CASE LEFT$(a2$, 3)
        CASE "500", "501", "502", "421", "530"
            dialog_disp "PASV Failed, disconnecting from server. Please try again."
            is_connected = 0
            status$ = "Not Connected."
            CLOSE command_connect&
            data_connect& = 0
            EXIT SUB
    END SELECT
    por$ = MID$(a2$, INSTR(a2$, "(") + 1)
    DIM ip$(4)
    FOR x = 1 TO 4
        ip$(x) = MID$(por$, 1, INSTR(por$, ",") - 1)
        por$ = MID$(por$, INSTR(por$, ",") + 1)
        ips$ = ips$ + ip$(x) + "."
    NEXT x
    ips$ = LEFT$(ips$, LEN(ips$) - 1)
    p1$ = MID$(por$, 1, INSTR(por$, ",") - 1)
    por$ = MID$(por$, INSTR(por$, ",") + 1)
    p2$ = MID$(por$, 1, INSTR(por$, ")") - 1)
    por$ = MID$(por$, INSTR(por$, ",") + 1)
    port$ = STR$(VAL(p1$) * 256 + VAL(p2$))
    data_connect& = _OPENCLIENT("TCP/IP:" + port$ + ":" + ips$)
END SUB

SUB get_file (file$) 'Gets a file from the FTP server and saves it in the local DIR
    'grab data in 1 MB chunks

    IF NOT cmd_mode THEN
        DIM box AS box_type
        'box.nam = n$
        put_str box.nam, n$
        box.row1 = _HEIGHT(0) \ 2 - 1
        box.row2 = _HEIGHT(0) \ 2 + 1
        box.col1 = _WIDTH(0) \ 2 - 25
        box.col2 = _WIDTH(0) \ 2 + 25
        box.shadow = -1
        box.c1 = box_c1
        box.c2 = box_c2
        box.text_box = -1
        draw_box box, 0
    END IF
    file$ = RTRIM$(file$)
    IF cmd_mode AND is_connected THEN PRINT "Getting file: "; Local_dir$ + sep$ + file$
    IF is_connected = 0 THEN text$ = "Please connect to a FTP Server first." ELSE text$ = "Recieving File...()"

    IF NOT cmd_mode THEN LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
    PRINT text$;
    IF NOT cmd_mode THEN _DISPLAY

    IF (is_connected = 0 AND NOT cmd_mode) THEN
        t# = TIMER
        DO: _LIMIT 100: LOOP UNTIL INKEY$ > "" OR TIMER - t# > 1
        EXIT SUB
    ELSEIF is_connected = 0 AND cmd_mode THEN
        EXIT SUB
    END IF

    file_size& = Remote_files(boxes(2).selected).size
    IF cmd_mode THEN PRINT "File size: "; file_size&
    start_PASV_mode

    IF data_connect& = 0 THEN EXIT SUB
    typei$ = "TYPE I" + crlf$
    PUT command_connect&, , typei$
    r$ = get_response_code$
    SELECT CASE LEFT$(r$, 3)
        CASE "421"
            dialog_disp "Error: FTP Server Disconnected."
            is_connected = 0
            CLOSE command_connect&, data_connect&
            EXIT SUB
    END SELECT

    retr$ = "RETR " + LTRIM$(file$) + crlf$
    PUT command_connect&, , retr$
    r$ = get_response_code$
    SELECT CASE LEFT$(r$, 3)
        CASE "450", "550"
            dialog_disp "Error: FTP Server refused to send the file"
            CLOSE data_connect&
            EXIT SUB
        CASE "500", "501", "530"
            dialog_disp "Error: FTP Server didn't reconise RETR command."
            CLOSE data_connect&
            EXIT SUB
    END SELECT
    sto$ = ""
    '_AUTODISPLAY
    OPEN RTRIM$(Local_dir$ + sep$ + file$) FOR BINARY AS #1
    'OPEN is way way WAY to slow...
    'file_offset = fopen(local_dir$ + sep$ + file$, "w")
    'data_buffer = _MEMNEW(1024 * 1024 * 1024) '1 MB
    'data_buf$ = space$(1024 * 1024 * 1024)
    e_flag_1 = 0
    e_flag_2 = 0
    t# = 0
    f_downloaded = 0
    BUFFER_LEN = 10 * 1024 * 1024 * 1024 '10 MB
    DO
        _LIMIT 100

        GET data_connect&, , filedat$

        IF filedat$ = "" AND e_flag_1 THEN e_flag_2 = -1
        filef$ = filef$ + filedat$

        GET command_connect&, , a$

        a2$ = a2$ + a$
        'IF (TIMER - t# > .1 AND NOT CLI) OR (TIMER - t# > .5) THEN
        IF LEN(filef$) > BUFFER_LEN THEN
            tsav# = TIMER - t#
            f_downloaded = f_downloaded + LEN(filef$)
            c = LEN(filef$)
            PUT #1, , filef$
            filef$ = ""
            kbpers = (c) / 1024 / tsav# 'c is how much we downloaded in our last loop

            IF file_size& = 0 THEN s$ = STR$(c) + " Bytes," ELSE s$ = STR$(INT(c / file_size& * 100) / 100) + "%,"

            text$ = "Recieving File...(" + s$ + STR$(kbpers) + " KB/s)"

            IF NOT cmd_mode THEN
                draw_box box, 0
                IF NOT CLI THEN
                    LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
                ELSE
                    LOCATE , 1
                END IF
            END IF
            PRINT text$
            IF NOT cmd_mode THEN _DISPLAY
            'PRINT "got here!!!!"
            'k = k + 1

            't# = TIMER
            'c = (LEN(filef$) - c1) * 10
            'IF c > 0 THEN kbpers = c / 1024 \ 1 ' ELSE kbpers = 0
            'c1 = LEN(filef$)
            'IF file_size& = 0 THEN s$ = STR$(c1) + " Bytes," ELSE s$ = STR$(INT(c1 / file_size& * 100) / 100) + "%,"

            'IF NOT cmd_mode THEN draw_box box, 0
            'text$ = "Recieving File...(" + s$ + STR$(kbpers) + " KB/s)"

            'IF NOT CLI THEN
            '  IF NOT cmd_mode THEN LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2 ELSE LOCATE , 1
            'ELSE
            '  PRINT CHR$(13); 'move cursor back
            'END IF
            'PRINT text$;
            'if not cmd_mode then _DISPLAY
            t# = TIMER
        END IF
        IF INSTR(a2$, crlf$) AND MID$(a2$, 4, 1) = "-" THEN
            DO
                sto$ = sto$ + MID$(a5$, 1, INSTR(a2$, crlf$) + 1)
                a2$ = MID$(a2$, INSTR(a2$, crlf$) + 2)
            LOOP UNTIL MID$(a2$, 4, 1) <> "-"
        END IF
        IF INSTR(a2$, crlf$) THEN e_flag_1 = -1
    LOOP UNTIL e_flag_2
    'PUT #1, , filef$
    CLOSE #1
    IF cmd_mode THEN PRINT
    SELECT CASE LEFT$(a2$, 3)
        CASE "226", "250"
            CLOSE data_connect&
            IF NOT cmd_mode THEN draw_box box, 0
            text$ = "File Sucessfully Recieved!"
            IF NOT cmd_mode THEN LOCATE box.row1 + 1, _WIDTH(0) \ 2 - LEN(text$) \ 2
            PRINT text$
            IF NOT cmd_mode THEN _DISPLAY
            IF NOT cmd_mode THEN
                t# = TIMER
                DO: _LIMIT 100: LOOP UNTIL INKEY$ > "" OR TIMER - t# > 1.5
                refresh_Local_files
            END IF
        CASE "425", "426", "451"
            CLOSE data_connect&
            KILL Local_dir$ + sep$ + RTRIM$(get_str$(Remote_files(boxes(2).selected).nam))
            dialog_disp "Error: File could not be recieved."

    END SELECT
    IF cmd_mode THEN PRINT "File Recieved"
END SUB

FUNCTION get_response_code$ () 'Get's a response code from the FTP server
    sto$ = ""
    t# = TIMER
    DO: _LIMIT 100
        GET command_connect&, , a$
        a5$ = a5$ + a$
        IF INSTR(a5$, crlf$) AND MID$(a5$, 4, 1) = "-" THEN
            IF cmd_mode THEN PRINT "Extended response..."
            DO
                sto$ = sto$ + MID$(a5$, 1, INSTR(a5$, crlf$) + 1)
                a5$ = MID$(a5$, INSTR(a5$, crlf$) + 2)
            LOOP UNTIL MID$(a5$, 4, 1) <> "-"
        END IF
        IF NOT _CONNECTED(command_connect&) OR TIMER - t# > 10 THEN a5$ = "421 Server Disconnected." + crlf$
    LOOP UNTIL INSTR(a5$, crlf$)
    IF sto$ = "" THEN
        r$ = MID$(a5$, 1, INSTR(a5$, crlf$) - 1)
    ELSE
        r$ = sto$ + MID$(a5$, 1, INSTR(a5$, crlf$) - 1)
    END IF
    IF cmd_mode THEN PRINT r$
    get_response_code$ = r$
END FUNCTION

SUB Rename_remote_file_dir (file$, newname$, file_dir) 'Renames a remote file
    'file_dir = -1 if a file
    'file_dir = 0 if a directory
    rf$ = "RNFR " + file$ + crlf$
    PUT #command_connect&, , rf$
    a2$ = get_response_code$
    SELECT CASE LEFT$(a2$, 3)
        CASE "450", "550", "501", "502", "503"
            dialog_disp "Error requesting name change..."
            EXIT SUB
        CASE "421"
            dialog_disp "Error change name, server closed connection"
            CLOSE #command_connect&
            is_connected = 0
            status$ = "Not Connected."
            EXIT SUB
    END SELECT
    nf$ = "RNTO " + newname$ + crlf$
    PUT #command_connect&, , nf$
    a2$ = get_response_code$
    SELECT CASE LEFT$(a2$, 3)
        CASE "552", "553", "500", "501", "502", "503", "530"
            dialog_disp "Error requesting name chance..."
            EXIT SUB
        CASE "421"
            dialog_disp "Error changing name, server closed connection"
            CLOSE #command_connect&
            is_connected = 0
            status$ = "Not Connected."
            EXIT SUB
    END SELECT
    dialog_disp "Name changed."
END SUB

SUB delete_remote_file (f$) 'Deletes remote file f$
    msg$ = "DELE " + RTRIM$(f$) + crlf$
END SUB

SUB delete_local_file (f$) 'Uses KILL. Deletes file f$
    err_flag = 0
    ON ERROR GOTO error_flag
    KILL RTRIM$(f$)
    ON ERROR GOTO 0
    IF err_flag THEN
        dialog_disp "Error deleting local file."
    END IF
END SUB

SUB Start_ftp_connect () 'Starts a FTP connection
    IF server$ = "" THEN dialog_disp "Please give a server name.": EXIT SUB
    IF username$ = "" THEN username$ = "anonymous" 'dialog_disp "Please give a Username.": EXIT SUB
    IF password$ = "" THEN password$ = "" 'dialog_disp "Please give a password.": EXIT SUB
    IF port$ = "" THEN port$ = "21" 'dialog_disp "Please give a port number.": EXIT SUB
    IF NOT cmd_mode THEN
        DIM disp_box AS box_type
        disp_box.row1 = _HEIGHT(0) \ 2 - 1
        disp_box.row2 = _HEIGHT(0) \ 2 + 1
        disp_box.c1 = 0
        disp_box.c2 = 7
        disp_box.text_box = -1
        'disp_box.nam = ""
        put_str disp_box.nam, ""
        disp_box.col1 = _WIDTH(0) \ 2 - 20
        disp_box.col2 = disp_box.col1 + 40
        disp_box.shadow = -1
    END IF
    text$ = "Connecting to FTP server..."
    IF NOT cmd_mode THEN
        draw_box disp_box, 0
        LOCATE disp_box.row1 + 1, disp_box.col1 + 20 - LEN(text$) \ 2
    END IF
    PRINT text$
    IF NOT cmd_mode THEN _DISPLAY
    is_connected = 0
    t# = TIMER
    IF command_connect& <> 0 THEN CLOSE command_connect&: command_connect& = 0
    command_connect& = _OPENCLIENT("TCP/IP:" + port$ + ":" + server$)
    IF command_connect& <> 0 THEN
        a2$ = get_response_code$
        SELECT CASE LEFT$(a2$, 3)
            CASE "120"
                text$ = MID$(a2$, 4)
                GOTO exit_f
            CASE "220" 'Good connection
            CASE "421" 'Bad connection
                text$ = "Error: FTP Service was closed by the Server"
        END SELECT
        a2$ = ""
        user$ = "USER " + username$ + crlf$
        pass$ = "PASS " + password$ + crlf$
        PUT command_connect&, , user$
        a2$ = get_response_code$
        IF TIMER - t# > 10 THEN GOTO exit_f
        n$ = LEFT$(a2$, 3)
        SELECT CASE n$
            CASE "530"
                text$ = "Error: Not logged in."
                GOTO exit_f
            CASE "500", "501"
                text$ = "Error: Server didn't reconize the syntax"
                GOTO exit_f
            CASE "421"
                text$ = "Error: FTP Service was closed by the Server" '
                GOTO exit_f
        END SELECT
        a2$ = ""
        IF n$ = "331" THEN
            PUT command_connect&, , pass$
            a2$ = get_response_code$
            n$ = LEFT$(a2$, 3)
            SELECT CASE n$
                CASE "202"
                    text$ = "Error: Password not needed or not supported."
                    GOTO exit_f
                CASE "530"
                    text$ = "Error: Password or Username incorrect."
                    GOTO exit_f
                CASE "500", "501", "503"
                    text$ = "Error: Server didn't reconize the syntax"
                    GOTO exit_f
                CASE "421"
                    text$ = "Error: FTP Service was closed by the Server" '
                    GOTO exit_f
                CASE "332"
                    text$ = "Error: Need account for login"
                    GOTO exit_f
            END SELECT
        END IF
        a2$ = ""
        is_connected = -1
        text$ = "Connected!"
        status$ = "Connected to " + server$
        syst$ = "SYST" + crlf$
        PUT command_connect&, , syst$
        a2$ = get_response_code$
        SELECT CASE LEFT$(a2$, 3)
            CASE "215"
                server_syst$ = MID$(a2$, INSTR(a2$, " ") + 1)
                server_syst$ = MID$(server_syst$, 1, INSTR(server_syst$, " ") - 1)
            CASE ELSE
                server_syst$ = "UNIX" 'Default
        END SELECT
        status$ = status$ + ", " + server_syst$
        IF NOT cmd_mode THEN Update_Remote_Files
    ELSE
        text$ = "Error Connecting..."
        exit_f:
        status$ = "Not Connected."
    END IF
    IF NOT cmd_mode THEN
        draw_box disp_box, 0
        LOCATE disp_box.row1 + 1, disp_box.col1 + 20 - LEN(text$) \ 2
    END IF
    PRINT text$
    IF NOT cmd_mode THEN _DISPLAY ELSE IF is_connected THEN PRINT "Server type: "; server_syst$
    free_gui_element disp_box
END SUB

SUB Get_remote_dir () 'Get's the remote DIR
    upd$ = "PWD" + crlf$
    PUT command_connect&, , upd$
    a2$ = get_response_code$
    SELECT CASE LEFT$(a2$, 3)
        CASE "500", "501", "502", "550"
            Remote_dir$ = "FTP Serv doesn't support PWD"
        CASE "421"
            Remote_dir$ = ""
            is_connected = 0
            CLOSE command_connect&
            status$ = "Not Connected."
            dialog_disp "Error: Server disconnected."
            EXIT SUB
    END SELECT
    Remote_dir$ = MID$(a2$, INSTR(a2$, CHR$(34)) + 1)
    Remote_dir$ = MID$(Remote_dir$, 1, INSTR(Remote_dir$, CHR$(34)) - 1)
END SUB

FUNCTION FTP_Parse_Line (f AS filedir_type)
    'Please see http://cr.yp.to/ftpparse.html
    'Implementatin of that C code in QB64 (With some modifications)
    f.flag_cwd = 0
    f.flag_retr = 0
    l$ = get_str$(f.lin)
    length = LEN(l$)
    IF LEN(l$) < 2 THEN EXIT FUNCTION 'Empty name
    a$ = LCASE$(LEFT$(l$, 1))
    SELECT CASE a$
        CASE "+" 'assume EPLF

        CASE "b", "c", "d", "l", "p", "s", "-" 'UNIX style
            'UNIX style is usually just a direct output from ls, which is meant to be human readable
            IF a$ = "d" THEN f.flag_cwd = -1
            IF a$ = "-" THEN f.flag_retr = -1
            IF a$ = "l" THEN f.flag_cwd = -1: f.flag_retr = -1

            state = 1
            i = 0
            FOR j = 2 TO length
                IF MID$(l$, j, 1) = " " AND MID$(l$, j - 1, 1) <> " " THEN
                    SELECT CASE state
                        CASE 1 'skip perm
                            state = 2
                        CASE 2 'skip nlink
                            state = 3
                            IF ((j - i) = 6) AND (MID$(l$, j, 1) = "f") THEN
                                state = 4
                            END IF
                        CASE 3 'skip uid

                            state = 4
                        CASE 4 'get size

                            f.size = VAL(MID$(l$, i, j - i))
                            state = 5
                        CASE 5 'find month

                            month_val = get_month(LCASE$(MID$(l$, i, j - i)))

                            IF month_val >= 0 THEN
                                state = 6
                            ELSE
                                f.size = VAL(MID$(l$, i, j - i))
                            END IF
                        CASE 6

                            mday = VAL(MID$(l$, i, j - i))
                            state = 7
                        CASE 7

                            'if ((j - i) = 4) and (mid$(l$, i + 1, 1) = ":") then
                            '  hours = val(mid$(l$, i, 1))
                            '  minutes = val(mid$(l$, i + 2, 2))
                            'elseif ((j - i) = 5) and (mid$(l$, 2, 1) = ":") then
                            '  hours = val(mid$(l$, i, 2))
                            '  minutes = val(mid$(l$, i + 3, 2))
                            'elseif (j - i) >= 3 then
                            '  year = val(mid$(l$, i, j - i))
                            'else
                            '  exit function
                            'end if
                            namelen = length - j
                            name_str$ = RIGHT$(l$, namelen)
                            put_str f.nam, name_str$
                            state = 8
                        CASE 8

                            ' uh...
                            ' Nothing left to do it seems. Not sure how we got here...
                    END SELECT
                    i = j + 1
                    DO WHILE ((i < length) AND (MID$(l$, i, 1) = " "))
                        i = i + 1
                    LOOP
                END IF
            NEXT j
            IF state <> 8 THEN EXIT FUNCTION

            IF LEFT$(l$, 1) = "l" THEN
                'for i = 0 to 3 + namelen
                '  if left$(name_str$, 4) = " -> " then
                '    namelen = i
                '  end if
                'next i
                k = INSTR(name_str$, " -> ")
                name_str$ = MID$(name_str$, 1, k - 1)
                put_str f.nam, name_str$
                namelen = LEN(name_str$)
            END IF

            IF LEFT$(l$, 1) = " " OR LEFT$(l$, 1) = "[" THEN
                IF namelen > 3 THEN
                    IF LEFT$(name_str$, 3) = "   " THEN
                        name_str$ = MID$(name_str$, 4)
                        put_str f.nam, name_str$
                        namelen = namelen - 3
                    END IF
                END IF
            END IF

            FTP_Parse_Line = -1
            EXIT FUNCTION
    END SELECT

    'MultiNet... What? Weird format...
    FOR i = 1 TO length
        IF MID$(l$, i, 1) = ";" THEN
            EXIT FOR
        END IF
    NEXT i

    IF i < length THEN
        name_str$ = MID$(name_str$, 1, i)
        namelen = i
        put_str f.nam, name_str$
        IF i > 4 THEN
            IF MID$(l$, i - 4, 4) = ".DIR" THEN
                name_str$ = MID$(name_str$, 1, namelen - 4)
                namelen = namelen - 4
                f.flag_cwd = -1
                put_str f.nam, name_str$
            END IF
        END IF
        IF NOT f.flag_cwd THEN
            f.flag_retr = -1
        END IF
        put_str f.nam, name_str$

        FTP_Parse_Line = -1
        EXIT FUNCTION
    END IF

    'MSDOS Format
    IF LEFT$(l$, 1) >= "0" AND LEFT$(l$, 1) <= "9" THEN
        i = 0
        j = 20

        'don't bother getting the date and time, I don't use it
        DO WHILE MID$(l$, j, 1) = " "
            j = j + 1
            IF j = length THEN EXIT FUNCTION
        LOOP
        IF MID$(l$, j, 1) = "<" THEN
            f.flag_cwd = -1
            DO WHILE MID$(l$, j, 1) <> " "
                j = j + 1
                IF j = length THEN EXIT FUNCTION
            LOOP
        ELSE
            i = j
            DO WHILE MID$(l$, j, 1) <> " "
                j = j + 1
                IF j = length THEN EXIT FUNCTION
            LOOP
            f.size = VAL(MID$(l$, i, j - i))
            f.flag_retr = -1
        END IF
        DO WHILE MID$(l$, j, 1) = " "
            j = j + 1
            IF j = length THEN EXIT FUNCTION
        LOOP
        namelen = length - j
        name_str$ = MID$(l$, j, namelen)
        put_str f.nam, name_str$
        FTP_Parse_Line = -1
        EXIT FUNCTION
    END IF

    FTP_Parse_Line = 0
END FUNCTION

FUNCTION get_month (m$)
    DIM months$(12)
    months$(1) = "jan"
    months$(2) = "feb"
    months$(3) = "mar"
    months$(4) = "apr"
    months$(5) = "may"
    months$(6) = "jun"
    months$(7) = "jul"
    months$(8) = "aug"
    months$(9) = "sep"
    months$(10) = "oct"
    months$(11) = "nov"
    months$(12) = "dec"
    IF LEN(m$) = 3 THEN
        FOR i = 1 TO 12
            IF m$ = months$(i) THEN get_month = i: EXIT FUNCTION
        NEXT i
    END IF
    get_month = -1
END FUNCTION

SUB sort_dir_listing (f() AS filedir_type, file_num)
    'quicksort type of thing. First, move all of the DIR's to the top (Ignore listing 1, as it's always ".."
    nex = 1
    DO: nex = nex + 1: LOOP UNTIL NOT f(nex).flag_cwd OR nex = file_num 'loop until f(nex) is not a directory
    m = nex + 1
    IF m < file_num THEN
        FOR x = m TO file_num 'loop through files
            IF f(x).flag_cwd THEN 'found a directory
                SWAP f(nex), f(x) 'swap the directory we found with the first entry that's not a directory, so we move the directory to the top
                DO: nex = nex + 1: LOOP UNTIL NOT f(nex).flag_cwd OR nex > file_num 'find the next non-directory
                x = nex + 1
            END IF
        NEXT x
    END IF
    'nex now equals the very last DIRectory
    '_AUTODISPLAY
    'cls
    'print "NEX="; nex
    'print "X  ="; x
    'sleep
    IF nex > 4 AND nex < file_num - 1 THEN
        quick_sort_filedir_type f(), 2, nex - 1
    END IF
    IF nex < file_num - 1 THEN
        quick_sort_filedir_type f(), nex, file_num
    END IF
END SUB

SUB quick_sort_filedir_type (f() AS filedir_type, low, high)
    IF low < high THEN
        IF high - low = 1 THEN
            IF LCASE$(get_str$(f(low).nam)) > LCASE$(get_str$(f(high).nam)) THEN
                SWAP f(low), f(high)
            END IF
        ELSE
            pivot = INT(RND * (high - low + 1)) + low
            SWAP f(high), f(pivot)
            p$ = LCASE$(get_str$(f(high).nam))
            DO
                l = low
                h = high
                DO WHILE (l < h) AND (LCASE$(get_str$(f(l).nam)) <= p$)
                    l = l + 1
                LOOP
                DO WHILE (h > l) AND (LCASE$(get_str$(f(h).nam)) >= p$)
                    h = h - 1
                LOOP
                IF l < h THEN
                    SWAP f(l), f(h)
                END IF
            LOOP WHILE l < h
            SWAP f(l), f(high)
            quick_sort_filedir_type f(), low, l - 1
            quick_sort_filedir_type f(), l + 1, high
        END IF
    END IF
END SUB

FUNCTION get_str$ (s AS string_type)
    '$CHECKING:OFF
    IF s.is_allocated <> 0 AND s.length > 0 THEN
        FOR x = 1 TO s.length
            get_s$ = get_s$ + _MEMGET(s.mem, s.mem.OFFSET + x - 1, STRING * 1)
        NEXT x
    END IF
    get_str$ = get_s$
    $CHECKING:ON
END FUNCTION

SUB put_str (s AS string_type, stri$)
    '$CHECKING:OFF
    IF NOT s.is_allocated OR s.allocated < LEN(stri$) THEN
        IF s.is_allocated THEN _MEMFREE s.mem
        s.mem = _MEMNEW(LEN(stri$) + 10) 'allocate 10 extra bytes
        s.allocated = LEN(stri$) + 10
        s.is_allocated = -1
    END IF
    _MEMPUT s.mem, s.mem.OFFSET, stri$
    s.length = LEN(stri$)
    $CHECKING:ON
END SUB

SUB add_character (b AS box_type, ch$)
    t$ = get_str$(b.text)
    t$ = MID$(t$, 1, b.text_position) + ch$ + MID$(t$, b.text_position + 1)
    'print "T="; t$;
    '_DISPLAY
    'sleep
    put_str b.text, t$
    b.text_position = b.text_position + 1
    IF b.text_position > b.text_offset + (b.col2 - b.col1 - 2) THEN
        b.text_offset = b.text_offset + 1
    END IF
END SUB

SUB del_character (b AS box_type)
    t$ = get_str$(b.text)
    IF LEN(t$) > 0 AND b.text_position > 0 THEN
        t$ = MID$(t$, 1, b.text_position - 1) + MID$(t$, b.text_position + 1)
        put_str b.text, t$
        b.text_position = b.text_position - 1
        IF b.text_position < b.text_offset THEN
            b.text_offset = b.text_offset - 1
        END IF
    END IF
END SUB

FUNCTION get_str_array$ (a AS array_type, array_number)
    DIM s AS string_type
    '$CHECKING:OFF
    _MEMGET a.mem, a.mem.OFFSET + array_number * LEN(s), s
    '_MEMCOPY a.mem, a.mem.OFFSET + array_number * LEN(string_type), LEN(string_type) TO m, m.OFFSET
    $CHECKING:ON

    get_str_array$ = get_str$(s)
END FUNCTION

'KEEP IN MIND, ST's _MEM value points to the same location as the array's one does
'USING ST RIGHT AFTER GETTING IT WILL CHANGE THE VALUE IN ARRAY
'MAKE A SAFE COPY OF ST FIRST IF YOU PLAN ON CHANGING IT WITHOUT CHANGING ARRAY VALUE
'Safe value's can be made by put_str temp_str, get_str$(st)
'Allocates a new string into temp_Str that you can use that is seperate from the array
SUB get_str_type_array (a AS array_type, array_number, st AS string_type)
    DIM m AS _MEM
    '$CHECKING:OFF
    m = _MEM(st)
    _MEMCOPY a.mem, a.mem.OFFSET + array_number * LEN(st), LEN(st) TO m, m.OFFSET
    $CHECKING:ON
END SUB

'SUB put_str_array (a AS array_type, array_number, s AS string_type)
''$CHECKING:OFF
'_MEMCOPY s.mem, s.mem.OFFSET, LEN(string_type) TO a.mem, a.mem.OFFSET + array_number * LEN(string_type)
''$CHECKING:ON
'END SUB

SUB put_str_array (a AS array_type, array_number, s$)
    '$CHECKING:OFF
    DIM st AS string_type
    _MEMGET a.mem, a.mem.OFFSET + array_number * LEN(st), st
    put_str st, s$
    _MEMPUT a.mem, a.mem.OFFSET + array_number * LEN(st), st

    $CHECKING:ON
END SUB

SUB get_filedir_type_array (a AS array_type, array_number, f AS filedir_type)
    DIM m AS _MEM
    '$CHECKING:OFF
    m = _MEM(f)
    _MEMCOPY a.mem, a.mem.OFFSET + array_number * LEN(f), LEN(f) TO m, m.OFFSET
    $CHECKING:ON
END SUB

SUB allocate_array (a AS array_type, number_of_elements, element_size)
    '$CHECKING:OFF
    IF NOT a.is_allocated THEN
        'not already allocated
        a.element_size = element_size
        a.length = number_of_elements
        a.is_allocated = -1
        a.allocated = number_of_elements * element_size
        a.mem = _MEMNEW(number_of_elements * element_size)
        _MEMFILL a.mem, a.mem.OFFSET, number_of_elements * element_size, 0 AS _BYTE
    ELSEIF a.element_size = element_size THEN
        reallocate_array a, number_of_elements
    END IF
    $CHECKING:ON
END SUB

SUB reallocate_array (a AS array_type, number_of_elements)
    DIM temp AS _MEM
    '$CHECKING:OFF
    IF NOT a.is_allocated THEN
        IF a.element_size > 0 THEN allocate_array a, number_of_elements, a.element_size ELSE ERROR 255
    ELSE 'reallocate
        IF number_of_elements * a.element_size < a.allocated THEN a.length = number_of_elements: EXIT SUB
        temp = a.mem
        a.mem = _MEMNEW(number_of_elements * a.element_size)
        _MEMFILL a.mem, a.mem.OFFSET, number_of_elements * a.element_size, 0 AS _BYTE
        _MEMCOPY temp, temp.OFFSET, a.allocated TO a.mem, a.mem.OFFSET

        s.allocated = number_of_elements * a.element_size

        _MEMFREE temp
    END IF

    $CHECKING:ON
END SUB

SUB free_gui_array (b() AS box_type)
    FOR x = 1 TO UBOUND(b)
        free_gui_element b(x)
    NEXT x
END SUB

SUB free_gui_element (b AS box_type)
    free_string b.nam
    free_string b.text
    free_array b.multi_line
END SUB

SUB free_array (a AS array_type)
    '$CHECKING:OFF
    IF a.is_allocated THEN
        _MEMFREE a.mem
        a.is_allocated = 0
        a.allocated = 0
    END IF
    $CHECKING:ON
END SUB

SUB free_string (s AS string_type)
    '$CHECKING:OFF
    IF s.is_allocated THEN
        _MEMFREE s.mem
        s.is_allocated = 0
        s.allocated = 0
    END IF
    $CHECKING:ON
END SUB

SUB main () 'main loop for GUI, etc.
    get_new_dir
    refresh_Local_files
    update = -1
    selected_box = 1
    print_files boxes(1), Local_files()
    print_files boxes(2), Remote_files()
    DO
        _LIMIT 200
        m = mouse_range(boxes(), BOXES) 'check key presses
        IF m > 0 THEN
            IF selected_box <> 3 THEN
                selected_box = m
                update = -1
            ELSEIF m <> 3 THEN
                IF my < menux.row1 OR my > menux.row2 OR mx < menux.col1 OR mx > menux.col2 THEN
                    selected_box = m
                    update = -1
                END IF
            END IF
        END IF
        IF but AND TIMER - mtimer > .1 THEN
            mtimer = TIMER
            'Click
            IF m > 0 AND m < 3 AND selected_box < 3 THEN
                IF mx > boxes(m).col1 AND mx < boxes(m).col2 THEN
                    IF my > boxes(m).row1 AND my < boxes(m).row2 THEN
                        selec = boxes(m).offset + my - boxes(m).row1
                        IF boxes(m).selected = selec THEN
                            IF Local_files(boxes(1).selected).flag_cwd AND m = 1 THEN
                                CHDIR RTRIM$(get_str$(Local_files(boxes(1).selected).nam))
                                get_new_dir
                                refresh_Local_files
                                update = -1
                            ELSEIF m = 2 THEN
                                IF is_connected THEN
                                    IF Remote_files(boxes(2).selected).flag_cwd THEN
                                        change_remote_dir RTRIM$(get_str$(Remote_files(boxes(2).selected).nam))
                                        Update_Remote_Files
                                        update = -1
                                    END IF
                                END IF
                            END IF
                        ELSE
                            boxes(m).selected = selec
                        END IF
                    END IF
                ELSEIF mx = boxes(m).col2 THEN 'Scroll bar
                    IF my = boxes(m).row1 + 1 THEN
                        IF boxes(m).selected > 1 THEN
                            update = -1
                            boxes(m).selected = boxes(m).selected - 1
                            IF boxes(m).offset + 1 > boxes(m).selected THEN
                                boxes(m).offset = boxes(m).offset - 1
                            END IF
                        END IF
                    ELSEIF my = boxes(m).row2 - 1 THEN
                        IF boxes(m).selected < boxes(m).length THEN
                            update = -1
                            boxes(m).selected = boxes(m).selected + 1
                            IF boxes(m).offset + (boxes(m).row2 - boxes(m).row1 - 1) < boxes(m).selected THEN
                                boxes(m).offset = boxes(m).offset + 1
                            END IF
                        END IF
                    ELSEIF my > boxes(m).scroll_loc THEN
                        IF boxes(m).selected < boxes(m).length THEN
                            update = -1
                            boxes(m).selected = boxes(m).selected + (boxes(m).row2 - boxes(m).row1)
                            IF boxes(m).selected > boxes(m).length THEN boxes(m).selected = boxes(m).length

                            IF boxes(m).offset + (boxes(m).row2 - boxes(m).row1 - 1) < boxes(m).selected THEN
                                boxes(m).offset = (boxes(m).selected - (boxes(m).row2 - boxes(m).row1 - 1))
                            END IF
                        END IF
                    ELSEIF my < boxes(m).scroll_loc THEN
                        IF boxes(m).selected > 1 THEN
                            update = 1
                            boxes(m).selected = boxes(m).selected - (boxes(m).row2 - boxes(m).row1)
                            IF boxes(m).selected <= 0 THEN boxes(m).selected = 1
                            IF boxes(m).offset + 1 > boxes(m).selected THEN
                                boxes(m).offset = boxes(m).selected - 1
                            END IF
                        END IF
                    END IF
                END IF
                IF boxes(selected_box).selected > boxes(selected_box).length THEN boxes(selected_box).selected = boxes(selected_box).length
            ELSEIF m = 3 THEN
                temp_menu_sel = 0
                k = 2
                FOR x = 1 TO g_menu_c
                    IF mx > k AND mx <= k + menu_len(Global_Menu$(x)) THEN
                        global_menu_sel = x
                        menu_sel = 1
                        menux.text_box = -1
                        'menux.nam = ""
                        put_str menux.nam, ""
                        menux.row1 = 2
                        menux.row2 = 3 + Menun(global_menu_sel)
                        menux.col1 = k
                        menux.col2 = menux.col1 + menu_max_len(global_menu_sel)
                        menux.c1 = menu_c1
                        menux.c2 = menu_c2
                        menux.shadow = -1
                        update = -1
                        EXIT FOR
                    END IF
                    k = k + menu_len(Global_Menu$(x))
                NEXT x
            END IF
            IF selected_box = 3 THEN
                IF my > menux.row1 AND my < menux.row2 THEN
                    IF mx > menux.col1 AND mx < menux.col2 THEN
                        sel = my - menux.row1
                        IF sel = menu_sel THEN
                            menu_clicked = -1
                        END IF
                        IF Menu$(global_menu_sel, sel) <> "-" THEN
                            menu_sel = sel
                            update = -1
                            menu_clicked = -1
                        END IF
                    END IF
                END IF
            END IF

        END IF
        IF mscroll <> 0 THEN 'scroll wheel
            boxes(selected_box).offset = boxes(selected_box).offset + mscroll
            IF boxes(selected_box).offset > (boxes(selected_box).length - (boxes(selected_box).row2 - boxes(selected_box).row1 - 1)) THEN boxes(selected_box).offset = boxes(selected_box).length - (boxes(selected_box).row2 - boxes(selected_box).row1 - 1)
            IF boxes(selected_box).offset < 0 THEN boxes(selected_box).offset = 0
            update = -1
        END IF
        a$ = INKEY$
        SELECT CASE a$
            CASE CHR$(0) + CHR$(72)
                IF selected_box < 3 THEN
                    IF boxes(selected_box).selected > 1 THEN update = -1: boxes(selected_box).selected = boxes(selected_box).selected - 1: IF boxes(selected_box).offset + 1 > boxes(selected_box).selected THEN boxes(selected_box).offset = boxes(selected_box).offset - 1
                ELSE
                    menu_sel = menu_sel - 1
                    IF menu_sel < 1 THEN menu_sel = Menun(global_menu_sel)
                    IF Menu$(global_menu_sel, menu_sel) = "-" THEN menu_sel = menu_sel - 1
                    update = -1
                END IF

            CASE CHR$(0) + CHR$(80)
                IF selected_box < 3 THEN
                    IF boxes(selected_box).selected < boxes(selected_box).length THEN update = -1: boxes(selected_box).selected = boxes(selected_box).selected + 1: IF boxes(selected_box).offset + (boxes(selected_box).row2 - boxes(selected_box).row1 - 1) < boxes(selected_box).selected THEN boxes(selected_box).offset = boxes(selected_box).offset + 1
                ELSEIF temp_menu_sel = 0 AND global_menu_sel > 0 THEN
                    menu_sel = (menu_sel MOD Menun(global_menu_sel)) + 1
                    IF Menu$(global_menu_sel, menu_sel) = "-" THEN menu_sel = menu_sel + 1
                    update = -1
                ELSEIF temp_menu_sel > 0 THEN
                    global_menu_sel = temp_menu_sel
                    temp_menu_sel = 0
                    menu_sel = 1
                    menux.text_box = -1
                    '        menux.nam = ""
                    put_str menux.nam, ""
                    menux.row1 = 2
                    menux.row2 = 3 + Menun(global_menu_sel)
                    menux.col1 = 2
                    FOR x = 1 TO global_menu_sel - 1
                        menux.col1 = menux.col1 + menu_len(Global_Menu$(x))
                    NEXT x

                    menux.col2 = menux.col1 + menu_max_len(global_menu_sel)
                    menux.c1 = menu_c1
                    menux.c2 = menu_c2
                    menux.shadow = -1
                    update = -1

                END IF
            CASE CHR$(0) + CHR$(75)
                IF selected_box < 3 THEN
                    selected_box = (selected_box MOD 2) + 1
                    update = -1
                ELSEIF selected_box = 3 AND temp_menu_sel = 0 AND global_menu_sel > 0 THEN
                    global_menu_sel = global_menu_sel - 1
                    IF global_menu_sel = 0 THEN global_menu_sel = g_menu_c
                    menu_sel = 1
                    menux.text_box = -1
                    '                menux.nam = ""
                    put_str menux.nam, ""
                    menux.row1 = 2
                    menux.row2 = 3 + Menun(global_menu_sel)
                    menux.col1 = 2
                    FOR x = 1 TO global_menu_sel - 1
                        menux.col1 = menux.col1 + menu_len(Global_Menu$(x))
                    NEXT x
                    menux.col2 = menux.col1 + menu_max_len(global_menu_sel)
                    menux.c1 = menu_c1
                    menux.c2 = menu_c2
                    menux.shadow = -1

                    update = -1
                ELSEIF temp_menu_sel > 0 THEN
                    temp_menu_sel = temp_menu_sel - 1
                    IF temp_menu_sel = 0 THEN temp_menu_sel = g_menu_c
                    update = -1
                END IF
            CASE CHR$(0) + CHR$(77)
                IF selected_box < 3 THEN
                    selected_box = (selected_box MOD 2) + 1
                    update = -1
                ELSEIF selected_box = 3 AND temp_menu_sel = 0 AND global_menu_sel > 0 THEN
                    global_menu_sel = (global_menu_sel MOD g_menu_c) + 1
                    menu_sel = 1
                    menux.text_box = -1
                    '        menux.nam = ""
                    put_str menux.nam, ""
                    menux.row1 = 2
                    menux.row2 = 3 + Menun(global_menu_sel)
                    menux.col1 = 2
                    FOR x = 1 TO global_menu_sel - 1
                        menux.col1 = menux.col1 + menu_len(Global_Menu$(x))
                    NEXT x

                    menux.col2 = menux.col1 + menu_max_len(global_menu_sel)
                    menux.c1 = menu_c1
                    menux.c2 = menu_c2
                    menux.shadow = -1
                    update = -1
                ELSEIF temp_menu_sel > 0 THEN
                    temp_menu_sel = temp_menu_sel + 1
                    IF temp_menu_sel = g_menu_c + 1 THEN temp_menu_sel = 1
                    update = -1
                END IF
            CASE CHR$(13) 'ENTER
                IF selected_box = 1 THEN 'Local File system
                    IF Local_files(boxes(1).selected).flag_cwd THEN
                        CHDIR RTRIM$(get_str$(Local_files(boxes(1).selected).nam))
                        get_new_dir
                        refresh_Local_files
                        update = -1
                    END IF
                ELSEIF selected_box = 2 THEN
                    IF is_connected THEN
                        IF Remote_files(boxes(2).selected).flag_cwd THEN
                            change_remote_dir RTRIM$(get_str$(Remote_files(boxes(2).selected).nam))
                            Update_Remote_Files
                            update = -1
                        END IF
                    END IF
                ELSEIF selected_box = 3 THEN
                    menu_clicked = -1
                END IF

            CASE CHR$(0) + CHR$(16) TO CHR$(0) + CHR$(50)
                k$ = alt_codes$(ASC(a$, 2))
                IF selected_box = 3 AND alt_flag_1 THEN
                    IF temp_menu_sel > 0 THEN
                        FOR x = 1 TO g_menu_c
                            IF UCASE$(k$) = UCASE$(menu_char$(Global_Menu$(x))) THEN
                                global_menu_sel = x
                                temp_menu_sel = 0
                                menu_sel = 1
                                menux.text_box = -1
                                '  menux.nam = ""
                                put_str menux.nam, ""
                                menux.row1 = 2
                                menux.row2 = 3 + Menun(global_menu_sel)
                                menux.col1 = 2
                                FOR x = 1 TO global_menu_sel - 1
                                    menux.col1 = menux.col1 + menu_len(Global_Menu$(x))
                                NEXT x
                                menux.col2 = menux.col1 + menu_max_len(global_menu_sel)
                                menux.c1 = menu_c1
                                menux.c2 = menu_c2
                                menux.shadow = -1
                                update = -1
                            END IF
                        NEXT x
                    ELSE
                        men = 0
                        FOR x = 1 TO Menun(global_menu_sel)
                            IF UCASE$(k$) = UCASE$(menu_char$(Menu$(global_menu_sel, x))) THEN
                                menu_sel = x
                                temp_menu_sel = 0
                                menu_clicked = -1
                                update = -1
                                men = -1
                            END IF
                        NEXT x
                        IF men = 0 THEN
                            FOR x = 1 TO g_menu_c
                                IF UCASE$(k$) = UCASE$(menu_char$(Global_Menu$(x))) THEN
                                    global_menu_sel = x
                                    temp_menu_sel = 0
                                    menu_sel = 1
                                    menux.text_box = -1
                                    '                menux.nam = ""
                                    put_str menux.nam, ""
                                    menux.row1 = 2
                                    menux.row2 = 3 + Menun(global_menu_sel)
                                    menux.col1 = 2
                                    FOR x = 1 TO global_menu_sel - 1
                                        menux.col1 = menux.col1 + menu_len(Global_Menu$(x))
                                    NEXT x
                                    menux.col2 = menux.col1 + menu_max_len(global_menu_sel)
                                    menux.c1 = menu_c1
                                    menux.c2 = menu_c2
                                    menux.shadow = -1
                                    update = -1
                                END IF
                            NEXT x
                        END IF
                    END IF

                END IF

            CASE CHR$(9) 'TAB
                selected_box = (selected_box MOD (BOXES - 1)) + 1
                update = -1
                'boxes(selected_box).selected = boxes(selected_box).offset + 1
            CASE CHR$(18)
                global_menu_sel = 2
                menu_sel = 1
                menu_clicked = -1

            CASE CHR$(0) + CHR$(73) ' PAGE UP
                IF sselected_box < 3 THEN
                    IF boxes(selected_box).selected > 1 THEN
                        update = 1
                        boxes(selected_box).selected = boxes(selected_box).selected - (boxes(selected_box).row2 - boxes(selected_box).row1)
                        IF boxes(selected_box).selected <= 0 THEN boxes(selected_box).selected = 1
                        IF boxes(selected_box).offset + 1 > boxes(selected_box).selected THEN
                            boxes(selected_box).offset = boxes(selected_box).selected - 1
                        END IF
                    END IF
                END IF
            CASE CHR$(0) + CHR$(81) ' PAGE DOWN
                IF selected_box < 3 THEN
                    IF boxes(selected_box).selected < boxes(selected_box).length THEN
                        update = -1
                        boxes(selected_box).selected = boxes(selected_box).selected + (boxes(selected_box).row2 - boxes(selected_box).row1)
                        IF boxes(selected_box).selected > boxes(selected_box).length THEN boxes(selected_box).selected = boxes(selected_box).length

                        IF boxes(selected_box).offset + (boxes(selected_box).row2 - boxes(selected_box).row1 - 1) < boxes(selected_box).selected THEN
                            boxes(selected_box).offset = (boxes(selected_box).selected - (boxes(selected_box).row2 - boxes(selected_box).row1 - 1))
                        END IF
                    END IF
                END IF
        END SELECT
        'Credit to Galleon for ALT key stuff
        keys = _KEYDOWN(100307) + _KEYDOWN(100308) * 2
        IF (keys) AND alt_flag_1 = 0 THEN 'Hold
            IF selected_box <> 3 THEN
                selected_box = 3
                temp_menu_sel = g_menu_c + 1
                update = -1
                'else
                '       selected_box = 4
                '           temp_menu_sel = 0
                '           update = -1
            END IF
            alt_flag_1 = -1
        END IF
        IF keys = 0 AND alt_flag_1 THEN 'Release
            IF temp_menu_sel > 0 AND temp_menu_sel < g_menu_c + 1 THEN
                selected_box = 4
                temp_menu_sel = 0
                update = -1
            ELSEIF temp_menu_sel = g_menu_c + 1 THEN
                temp_menu_sel = 1
                update = -1
            END IF
            alt_flag_1 = 0
        END IF
        IF menu_clicked THEN
            menu_clicked = 0
            selected_box = 4
            temp_menu_sel = 0
            update_scrn
            _DISPLAY 'So menu updates
            IF global_menu_sel = 1 THEN 'this is where we decide what to do based on what is selected in the menu
                IF menu_sel = 1 THEN
                    Connect_To_FTP
                    update = -1
                ELSEIF menu_sel = 2 THEN
                    is_connected = 0
                    CLOSE command_connect&
                    status$ = "Not Connected."
                    boxes(2).length = 0
                    update = -1
                ELSEIF menu_sel = 3 THEN
                    command_line
                    update_scrn
                    IF is_connected THEN Update_Remote_Files
                    refresh_Local_files
                    update = -1
                ELSEIF menu_sel = 5 THEN
                    SYSTEM
                END IF
            ELSEIF global_menu_sel = 2 THEN
                IF menu_sel = 1 THEN
                    refresh_Local_files
                    update = -1
                ELSEIF menu_sel = 3 THEN
                    rename_file_GUI 1 '1 = local rename file
                    refresh_Local_files
                    update = -1
                ELSEIF menu_sel = 4 THEN
                    delete_file_GUI 1 '1 = local delete file
                    update = -1
                ELSEIF menu_sel = 5 THEN
                    show_hidden_local = NOT show_hidden_local
                    refresh_Local_files
                    update = -1
                END IF
            ELSEIF global_menu_sel = 3 THEN
                IF menu_sel = 1 THEN
                    Update_Remote_Files
                    update = -1
                ELSEIF menu_sel = 3 THEN
                    rename_file_GUI 0 '0 = remote delete file
                    Update_Remote_Files
                    update = -1
                ELSEIF menu_sel = 4 THEN
                    delete_file_GUI 0 '0 = remote delete file
                    Update_Remote_Files
                    update = -1
                ELSEIF menu_sel = 5 THEN
                    show_hidden_remote = NOT show_hidden_remote
                    Update_Remote_Files
                    update = -1
                END IF
            ELSEIF global_menu_sel = 4 THEN
                IF menu_sel = 1 THEN
                    send_file get_str$(Local_files(boxes(2).selected).nam)
                    refresh_Local_files
                    update = -1
                ELSEIF menu_sel = 2 THEN
                    get_file get_str$(Remote_files(boxes(2).selected).nam)
                    refresh_Local_files
                    update = -1
                END IF
            ELSEIF global_menu_sel = 5 THEN
                IF menu_sel = 1 THEN 'help
                    test = prompt_dialog("Test", 10, OK_BUTTON OR CANCEL_BUTTON OR NO_BUTTON OR CLOSE_BUTTON OR YES_BUTTON, 10)
                ELSEIF menu_sel = 2 THEN
                    settings_dialog
                    IF is_connected THEN Update_Remote_Files
                    refresh_Local_files
                    update = -1
                ELSE
                    IF menu_sel = 4 THEN 'about
                        about_dialog
                        update = -1
                    END IF
                END IF
            END IF
            menu_clicked = 0
            selected_box = 4
            temp_menu_sel = 0
            global_menu_sel = 0
            menu_sel = 0
            update = -1
        END IF
        IF update THEN
            'draw_menu
            update_scrn

            _DISPLAY
            update = 0
        END IF
    LOOP 'UNTIL a$ = CHR$(27)
END SUB
