'editor wall/ceil/bottom 3D Alpha 2


SCREEN _NEWIMAGE(1024, 768, 32)
'   24 =     25 =     27 =   26 = 


'$INCLUDE:'saveimage.bi'
TYPE Button
    active AS _BYTE
    time AS _BYTE
    text AS STRING * 14
    x AS INTEGER
    y AS INTEGER
    imgA AS LONG 'aktivni tlacitko
    imgB AS LONG 'neaktivni tlacitko
END TYPE

TYPE Texture
    img AS LONG
    path AS STRING
END TYPE


'pro SAVEMAP ----------------------------------
TYPE MAP_HEAD
    Identity AS STRING * 5 'MAP2D, nebo MAP3D                                                     5 B
    Nr_of_Textures AS LONG 'pocet textur v souboru                                                4 B
    Nr_of_Vertexes AS LONG 'pocet vrcholu v souboru                                               4 B
    DataStart AS LONG 'dodatecny udaj o mistu v souboru, kde zacinaji data textur                 4 B
    VertexStart AS LONG 'dodatecny udaj o mistu v souboru, kde zacinaji data vrcholu              4 B
END TYPE


TYPE Vertex
    Flag AS _UNSIGNED _BYTE 'typ, udavajici, jestli na mape v danem miste je zed, strop, podlaha, nebo stena a strop....  podle toho z ktereho pole zaznam pochazi
    X1 AS SINGLE
    Y1 AS SINGLE
    Z1 AS SINGLE
    X2 AS SINGLE
    Y2 AS SINGLE
    Z2 AS SINGLE
    X3 AS SINGLE
    Y3 AS SINGLE
    Z3 AS SINGLE
    X4 AS SINGLE
    Y4 AS SINGLE
    Z4 AS SINGLE
    Texture_Nr AS LONG
END TYPE


'upgrade 01u14-2ba
TYPE InfoPlus
    Height_From AS SINGLE 'vyskova pozice - start
    Height_To AS SINGLE 'vyskova pozice - konec  u stropu a podlah v rovince to bude stejne
    TexturesPerObject AS _UNSIGNED _BYTE ' pocet teles, pres ktere je jedna textura
    TextureEffect AS _UNSIGNED _BYTE 'cislo efektu pro texturu
END TYPE


CONST SaveMap3D$ = "MAP3D"
' pro SAVEMAP konec----------------------------




'GridEndX a GridEndY bude mozne nastavit tlacitkem Grid, pote ulozit do INI souboru


DIM SHARED StartDrawX, EndDrawX, StartDrawy, EndDrawy, TextureIN, GridXResolution, GridYResolution, GridRGB32Color~&, GridVisibility, GridShowComments, GridCommentsTime 'urcujici promenne pro kresbu mrizky

'nove sdilene promenne ohledne doplnkoveho pole InfoPlus (IP):
DIM SHARED Img_Height_From, Img_Height_To, Img_Textures_per_Object, Img_Texture_Effect, Ceil_Height_From, Ceil_Height_To, Ceil_Textures_per_Object, Ceil_Texture_Effect, Floor_Height_From, Floor_Height_To, Floor_Textures_per_Object, Floor_Texture_Effect
DIM SHARED ObjectIN, INSERT_SETUP

LoadINI

'PRINT GridXResolution, GridYResolution: SLEEP

REDIM SHARED Grid_img(GridXResolution, GridYResolution) AS LONG 'puvodne pro cislo snimku, nevedomky pouzito pro zed. Cili pro zed,
REDIM SHARED Grid_Ceil(GridXResolution, GridYResolution) AS LONG 'cislo snimku pro strop
REDIM SHARED Grid_Floor(GridXResolution, GridYResolution) AS LONG 'cislo snimku pro podlahu
REDIM SHARED Grid_Obj(GridXResolution, GridYResolution) AS LONG 'cislo objektu
REDIM SHARED Grid_typ(GridXResolution, GridYResolution) AS LONG
REDIM SHARED Grid_SND(GridXResolution, GridYResolution) AS LONG


'doplnkova pole nesouci informace o vyskove pozici zdi/podlah/stropu, poctu textur na teleso a texturovem efektu
REDIM SHARED IP_Img(GridXResolution, GridYResolution) AS InfoPlus
REDIM SHARED IP_Ceil(GridXResolution, GridYResolution) AS InfoPlus
REDIM SHARED IP_Floor(GridXResolution, GridYResolution) AS InfoPlus


REDIM SHARED Texture(0) AS Texture
DIM SHARED Button(16) AS Button
DIM SHARED COPY_OR_INSERT_Right_click_menu(3) AS _UNSIGNED INTEGER
DIM SHARED Icony(12) AS LONG, DIALOG AS _BYTE, TextureStart AS INTEGER, TextureEnd AS INTEGER, TextureSelected AS INTEGER, LAYERS_SETUP AS INTEGER, KEYBOARDAGENT AS LONG, DRAW_MOUSE_SETUP, MemorizeTimer
MemorizeTimer = TIMER
'StartDrawX = 1
'StartDrawy = 1
'EndDrawX = 36
'EndDrawy = 35




Button(0).active = 0: Button(0).time = 0: Button(0).text = "Okÿ": Button(0).x = 612: Button(0).y = 580 'pro aktivaci nastav DIALOG na 2
Button(1).active = 0: Button(1).time = 0: Button(1).text = "Add Texture": Button(1).x = 945: Button(1).y = 680
Button(14).active = 0: Button(14).time = 0: Button(14).text = "Delete Texture": Button(14).x = 945: Button(14).y = 720
Button(6).active = 0: Button(6).time = 0: Button(6).text = "Add Object": Button(6).x = 885: Button(6).y = 680
Button(7).active = 0: Button(7).time = 0: Button(7).text = "Delete Object": Button(7).x = 885: Button(7).y = 720
Button(8).active = 0: Button(8).time = 0: Button(8).text = "Rotate Object": Button(8).x = 825: Button(8).y = 680
Button(2).active = 0: Button(2).time = 0: Button(2).text = "Wall Height": Button(2).x = 825: Button(2).y = 720
Button(3).active = 0: Button(3).time = 0: Button(3).text = "Load Map": Button(3).x = 765: Button(3).y = 680
Button(4).active = 0: Button(4).time = 0: Button(4).text = "Save Map": Button(4).x = 765: Button(4).y = 720
Button(5).active = 0: Button(5).time = 0: Button(5).text = "New Map": Button(5).x = 705: Button(5).y = 680
Button(9).active = 0: Button(9).time = 0: Button(9).text = "Set Grid": Button(9).x = 705: Button(9).y = 720
Button(10).active = 0: Button(10).time = 0: Button(10).text = "Draw Floor": Button(10).x = 645: Button(10).y = 680
Button(11).active = 0: Button(11).time = 0: Button(11).text = "Draw Ceiling": Button(11).x = 645: Button(11).y = 720
Button(12).active = 1: Button(12).time = 0: Button(12).text = "Draw Wall": Button(12).x = 585: Button(12).y = 680
Button(13).active = 0: Button(13).time = 0: Button(13).text = "Quit": Button(13).x = 585: Button(13).y = 720
Button(15).text = "Yes": Button(15).x = 412: Button(15).y = 380
Button(16).text = "Noÿ": Button(16).x = 480: Button(16).y = 380
'DIALOG = 1



Icony(1) = LOADICO("ico\left.ico", 3)
Icony(2) = LOADICO("ico\right.ico", 3)
Icony(3) = LOADICO("ico\up.ico", 3)
Icony(4) = LOADICO("ico\dn.ico", 3)
Icony(5) = LOADICO("ico\ot.ico", 4)
Icony(6) = LOADICO("ico\film.ico", 2)

'pro funkci Browse
Icony(7) = LOADICO("ico\invalid.ico", 7)
Icony(8) = LOADICO("ico\ko.ico", 1)
Icony(9) = LOADICO("ico\oke.ico", 1)
Icony(10) = LOADICO("ico\sup.ico", 7)
Icony(11) = LOADICO("ico\sdn.ico", 7)
TextureIN = Icony(6)
Icony(12) = ROTO(90)
'_CLEARCOLOR _RGB32(0, 0, 0), Icony(12)
TextureIN = 0


'Init_Screen
Create_Buttons 'vytvori tlacitka a jejich kresbu
'Texture(0).img = _LOADIMAGE("textures\a.jpg", 32)
'Texture(1).img = _LOADIMAGE("textures\a.jpg", 32)
'Texture(2).img = _LOADIMAGE("textures\a.jpg", 32)
'Texture(3).img = _LOADIMAGE("textures\a.jpg", 32)
'Texture(4).img = _LOADIMAGE("textures\dub.jpg", 32)
'Texture(5).img = _LOADIMAGE("textures\a.jpg", 32)
'Texture(6).img = _LOADIMAGE("textures\dub.jpg", 32)
'Texture(7).img = _LOADIMAGE("textures\a.jpg", 32)
'Texture(8).img = _LOADIMAGE("textures\dub.jpg", 32)

TextureStart = 0: TextureEnd = 6
'Grid_img(10, 10) = _SCREENIMAGE
'Grid_typ(10, 10) = 1
'Grid_rot(10, 10) = 45

DO

    '  WHILE _MOUSEINPUT: WEND

    Init_Screen
    Init_Objects



    k& = _KEYDOWN(32)
    IF k& THEN KEYBOARDAGENT = 1 ELSE KEYBOARDAGENT = 0



    SELECT CASE Place_Buttons
        CASE 1
            New_Texture_Name$ = Browse("JPGBMPGIFPNG")
            'odfiltrovat cesty



            new_texture = _LOADIMAGE(New_Texture_Name$, 32) 'spusti program na prochazeni souboru na disku a umozni zvolit texturu
            IF new_texture < -1 THEN
                IF Texture(0).img < -1 THEN REDIM _PRESERVE Texture(UBOUND(Texture) + 1) AS Texture
                Texture(UBOUND(Texture)).img = new_texture
                Texture(UBOUND(Texture)).path = New_Texture_Name$

                '                CLS: PRINT Texture(UBOUND(Texture)).path: _DISPLAY: SLEEP

                TextureStart = UBOUND(Texture) - 6: TextureEnd = UBOUND(Texture)

            END IF
            Reset_Mouse

        CASE 2: Wall_Height: Reset_Mouse

        CASE 3: IF IS_EMPTY_GRID THEN LOAD_MAP (Browse("MAP")) ELSE DialogW "Save this MAP?", 5: LOAD_MAP (Browse("MAP")): Reset_Mouse
        CASE 4: DialogW "Save MAP as:", 2: Reset_Mouse 'SAVE_MAP ("testC.map") 'ulozeni mapy, dodelat dotaz na jmeno mapy, testy souborove pritomnosti a tak dale
        CASE 5: DialogW "", 4: Reset_Mouse 'NEW MAP
        CASE 6: New_Object$ = Browse("OBJ"): Reset_Mouse 'NewObject = LOADOBJECT (Browse("OBJ"))

        CASE 9: SetGrid: Reset_Mouse
        CASE 10 'floor strop
            Button(10).active = 1: Button(11).active = 0: Button(12).active = 0: Reset_Mouse 'rozliseni musi resit Init_Screen


        CASE 11 ' ceiling podlaha
            Button(11).active = 1: Button(10).active = 0: Button(12).active = 0: Reset_Mouse


        CASE 12 'wall zed
            Button(12).active = 1: Button(10).active = 0: Button(11).active = 0: Reset_Mouse

        CASE 13: DialogW "Save work and exit?", 1: Reset_Mouse
        CASE 14: DELETE_TEXTURE: Reset_Mouse


        CASE 15:

        CASE 16: DIALOG = 0
    END SELECT

    _DISPLAY
    PCOPY _DISPLAY, 10
    _LIMIT 20
LOOP




SUB Init_Objects
    'this is now developed




    FOR pas = 63 TO 428 STEP 73
        _PUTIMAGE (pas, 670), Icony(12)
    NEXT pas




END SUB

FUNCTION RightClickMenu (c() AS STRING, X AS INTEGER, Y AS INTEGER) 'vrati -1 pro Esc, jinak 1 az ubound pole
    PCOPY 10, _DISPLAY
    _FONT 16
    FOR Search_Max_Width = LBOUND(c) TO UBOUND(c)
        IF Max_Width < _PRINTWIDTH(c(Search_Max_Width)) THEN Max_Width = _PRINTWIDTH(c(Search_Max_Width))
    NEXT

    Max_Height = (_FONTHEIGHT * UBOUND(c)) + 10
    Max_Width = Max_Width + 10


    FreeX = _WIDTH - X - 10
    FreeY = _HEIGHT - Y - 10
    IF FreeX > Max_Width THEN placeX = X + 10 ELSE placeX = X - 10 - Max_Width
    IF FreeY > Max_Height THEN placeY = Y + 10: ELSE placeY = Y - 10 - Max_Height
    LINE (placeX, placeY)-(placeX + Max_Width, placeY + Max_Height), _RGB32(70, 70, 70), BF
    LINE (placeX, placeY)-(placeX + Max_Width, placeY + Max_Height), _RGB32(155, 155, 155), B
    LINE (placeX + 2, placeY + 2)-(placeX + Max_Width - 2, placeY + Max_Height - 2), _RGB32(155, 155, 155), B
    by = placeY + 5
    _PRINTMODE _FILLBACKGROUND
    sel = LBOUND(c)
    REM _MOUSEMOVE placeX, placeY

    DIM tmp AS LONG

    DO UNTIL tmp OR _KEYHIT = 27
        DO WHILE _MOUSEINPUT
            sel = sel + _MOUSEWHEEL
        LOOP
        by = placeY + 5
        FOR W = LBOUND(c) TO UBOUND(c)
            L = Max_Width / _FONTWIDTH - LEN(c(W)) - 1 'in graphic mode: (Max_Width - _PRINTWIDTH(c(W))) / _FONTWIDTH - 10
            Text$ = c(W) + STRING$(L, " ")
            IF _MOUSEX >= placeX AND _MOUSEX <= placeX + Max_Width THEN
                IF _MOUSEY >= placeY AND _MOUSEY <= placeY + Max_Height THEN
                    sel = _CEIL((_MOUSEY - placeY) / 16)
                END IF
            END IF
            IF sel > UBOUND(c) THEN sel = UBOUND(c)
            IF sel < LBOUND(c) THEN sel = LBOUND(c)
            IF W = sel THEN COLOR _RGB32(255, 255, 0), _RGB32(0, 0, 255) ELSE COLOR _RGB32(255), _RGB32(70, 70, 70)
            _PRINTSTRING (placeX + 7, by), Text$
            by = by + _FONTHEIGHT
            IF _MOUSEBUTTON(1) THEN tmp = sel: EXIT FOR
            i$ = INKEY$
            SELECT CASE i$
                CASE CHR$(0) + CHR$(72): sel = sel - 1
                CASE CHR$(0) + CHR$(80): sel = sel + 1
                CASE CHR$(13): tmp = sel: EXIT FOR
                CASE CHR$(27): tmp = -1: EXIT DO
            END SELECT
        NEXT
        _DISPLAY

        RightClickMenu = tmp
    LOOP
    Reset_Mouse
END FUNCTION





SUB Comment_Window (C() AS STRING, X AS INTEGER, Y AS INTEGER)
    IF TextureIN >= -1 THEN EXIT SUB
    Yellow& = _NEWIMAGE(20, 20, 32)
    a = _DEST
    _DEST Yellow&
    CLS , _RGB32(255, 255, 0)
    _DEST a

    _FONT 8
    FOR Search_Max_Width = LBOUND(C) TO UBOUND(C)
        IF Max_Width < _PRINTWIDTH(C(Search_Max_Width)) THEN Max_Width = _PRINTWIDTH(C(Search_Max_Width))
    NEXT
    Max_Height = (_FONTHEIGHT * UBOUND(C)) + 10
    Max_Width = Max_Width + 10

    PRINT Max_Width, Max_Height 'asi ok

    'tedko: Kdyz neni dost mista od X vlevo, umisti komentar doprava. Pokud neni dost mista pro komentar nad Y, umisti ho pod Y.

    FreeX = _WIDTH - X - Max_Width - 10 '     kolik je volneho mista v ose x od x doprava
    FreeY = _HEIGHT - Y - Max_Height - 10 '    kolik je volneho mista v ose y od y dolu

    IF FreeX > Max_Width THEN placeX = X + 10 ELSE placeX = X - 10 - Max_Width
    IF FreeY > Max_Height THEN placeY = Y + 10 ELSE placeY = Y - 10 - Max_Height
    LINE (placeX, placeY)-(placeX + Max_Width, placeY + Max_Height), _RGB32(255, 255, 0), BF
    LINE (placeX, placeY)-(placeX + Max_Width, placeY + Max_Height), _RGB32(127, 127, 127), B
    LINE (placeX + 2, placeY + 2)-(placeX + Max_Width - 2, placeY + Max_Height - 2), _RGB32(127, 127, 127), B

    IF placeY < Y THEN
        _MAPTRIANGLE (0, 0)-(19, 0)-(19, 19), Yellow& TO(placeX + (Max_Width / 2) - 30, placeY + Max_Height)-(placeX + (Max_Width / 2) + 30, placeY + Max_Height)-(X, Y)
        LINE (placeX + (Max_Width / 2) - 30, placeY + Max_Height)-(X, Y), _RGB32(127, 127, 127)
        LINE (placeX + (Max_Width / 2) + 30, placeY + Max_Height)-(X, Y), _RGB32(127, 127, 127)
    END IF

    IF placeY > Y THEN
        _MAPTRIANGLE (0, 0)-(19, 0)-(19, 19), Yellow& TO(placeX + (Max_Width / 2) - 30, placeY)-(placeX + (Max_Width / 2) + 30, placeY)-(X, Y)
        LINE (placeX + (Max_Width / 2) - 30, placeY)-(X, Y), _RGB32(127, 127, 127)
        LINE (placeX + (Max_Width / 2) + 30, placeY)-(X, Y), _RGB32(127, 127, 127)
    END IF

    'spocitam stred kazde vety a tam to napisu
    _PRINTMODE _KEEPBACKGROUND
    COLOR _RGB32(0, 0, 0)
    FOR PrintInfo = LBOUND(C) TO UBOUND(C)
        PrintPosition = (Max_Width - _PRINTWIDTH(C(PrintInfo))) / 2

        FOR TextEdit = 1 TO LEN(C(PrintInfo))
            COLOR _RGB32(0, 0, 0)
            ch$ = MID$(C(PrintInfo), TextEdit, 1)
            IF ch$ = UCASE$(ch$) AND ch$ <> ":" THEN COLOR _RGB32(255, 0, 0)
            IF ASC(ch$) >= 48 AND ASC(ch$) <= 57 THEN COLOR _RGB32(6, 44, 255)
            _PRINTSTRING ((8 * TextEdit) - 8 + placeX + PrintPosition, placeY + _FONTHEIGHT * PrintInfo - 1), ch$
        NEXT
    NEXT

    _FREEIMAGE Yellow&
END SUB


SUB Wall_Height

    LINE (198, 200)-(822, 568), _RGB32(70, 70, 70), BF
    LINE (198, 200)-(822, 568), _RGB32(155, 155, 155), B
    LINE (200, 202)-(820, 566), _RGB32(155, 155, 155), B
    _FONT 8
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (450, 205), "Height Setup"
    LINE (200, 215)-(820, 215), _RGB32(155, 155, 155)
    DvojSipka = _LOADIMAGE("ico/dvojsipka.bmp", 32)
    _CLEARCOLOR _RGB32(255, 255, 255), DvojSipka
    PCOPY _DISPLAY, 9
    OldRoto = rotos
    DO
        PCOPY 9, _DISPLAY
        WHILE _MOUSEINPUT: WEND
        _PUTIMAGE (450, 220), DvojSipka
        '        IF Img_Textures_per_Object = 1 THEN aft$ = " object" ELSE aft$ = " objects"
        _PRINTSTRING (230, 233), "Textures per 1 Object: " + STR$(Img_Textures_per_Object)
        '-------------------------------------------------------------------------------------------------
        'nastavovaci veticka pro nastaveni vysky zdi od do
        _PRINTSTRING (230, 263), "Set WALL height from: " + LTRIM$(STR$(Img_Height_From))
        _PRINTSTRING (230, 293), "Set WALL height to: " + LTRIM$(STR$(Img_Height_To))
        _PUTIMAGE (450, 250), DvojSipka: _PUTIMAGE (450, 280), DvojSipka


        'nastavovaci veticka pro nastaveni vysky zeme od do
        _PRINTSTRING (230, 323), "Set FLOOR height from: " + LTRIM$(STR$(Floor_Height_From))
        _PRINTSTRING (230, 353), "Set FLOOR height to: " + LTRIM$(STR$(Floor_Height_To))
        _PUTIMAGE (450, 310), DvojSipka: _PUTIMAGE (450, 340), DvojSipka


        'nastavovaci veticka pro nastaveni vysky stropu od do
        _PRINTSTRING (230, 383), "Set CEILING height from: " + LTRIM$(STR$(Ceil_Height_From))
        _PRINTSTRING (230, 413), "Set CEILING height to: " + LTRIM$(STR$(Ceil_Height_To))
        _PUTIMAGE (450, 370), DvojSipka: _PUTIMAGE (450, 400), DvojSipka


        _PRINTSTRING (230, 443), "Rotate texture angle: " + STR$(rotos) '+ "            degrees"
        IF rotos > 360 THEN rotos = 0


        _PUTIMAGE (450, 430), DvojSipka

        _PRINTSTRING (230, 470), "View rotated texture"

        '_PRINTSTRING (600, 233), "Apply texture filter:" 'efect, bude tu dalsi ROLLMENU



        _PRINTSTRING (470, 470), "Reset all to default"

        LINE (225, 465)-(395, 480), _RGB32(255, 255, 255), B
        LINE (465, 465)-(635, 480), _RGB32(255, 255, 255), B


        oke = LOADICO("ico/oke.ico", 1)
        bck = LOADICO("ico/ko.ico", 1)
        _CLEARCOLOR 0, oke
        _CLEARCOLOR 0, bck


        IF ONPOS(_MOUSEX, _MOUSEY, 300, 500, 385, 530) THEN LINE (300, 500)-(385, 530), _RGBA32(170, 170, 170, 60), BF: IF _MOUSEBUTTON(1) THEN SaveINI: complete = 1 'OK
        LINE (300, 500)-(385, 530), _RGB32(255, 255, 255), B
        _PUTIMAGE (300, 500), oke
        _PRINTSTRING (333, 513), "Done"

        IF ONPOS(_MOUSEX, _MOUSEY, 640, 500, 725, 530) THEN
            LINE (640, 500)-(725, 530), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN '             BACK
                Img_Textures_per_Object = 1
                Img_Height_From = -2
                Img_Height_To = 2
                Floor_Height_From = -2
                Floor_Height_To = -2
                Ceil_Height_From = 2
                Ceil_Height_To = 2
                rotos = 0
                EXIT SUB
            END IF
        END IF

        LINE (640, 500)-(725, 530), _RGB32(255, 255, 255), B
        _PUTIMAGE (640, 500), bck
        _PRINTSTRING (673, 513), "Back"




        'upgrade pro copy styl (mozna doplnit i DELETE styl?)
        REDIM copy_style(1 TO 2) AS STRING
        copy_style(1) = "Rewrite ALL (walls, floors, objects, ceilings) in destination area"
        copy_style(2) = "Rewrite JUST ACTIVE object (if is active button WALL, rewrite WALLs...)"


        _PRINTSTRING (600, 225), " Insert/Copy setup"
        LINE (595, 220)-(750, 235), _RGB32(255), B
        IF ONPOS(_MOUSEX, _MOUSEY, 595, 200, 750, 235) THEN
            LINE (595, 220)-(750, 235), _RGBA32(127, 127, 127, 100), BF
            IF _MOUSEBUTTON(1) THEN
                PCOPY 0, 10
                Reset_Mouse
                INSERT_SETUP = 0

                DO UNTIL INSERT_SETUP > 0
                    INSERT_SETUP = RightClickMenu(copy_style(), _MOUSEX, _MOUSEY)
                LOOP
                _FONT 8
                COLOR _RGB32(255), _RGB32(70)
            END IF
        END IF


        'new software construction

        Img_Textures_per_Object = Img_Textures_per_Object + DoubleArrow(450, 220)
        Img_Height_From = Img_Height_From + DoubleArrow(450, 250)
        Img_Height_To = Img_Height_To + DoubleArrow(450, 280)
        Floor_Height_From = Floor_Height_From + DoubleArrow(450, 310)
        Floor_Height_To = Floor_Height_To + DoubleArrow(450, 340)
        Ceil_Height_From = Ceil_Height_From + DoubleArrow(450, 370)
        Ceil_Height_To = Ceil_Height_To + DoubleArrow(450, 400)
        rotos = rotos + DoubleArrow(450, 430)

        IF TextureIN < -1 THEN
            IF OldRoto <> rotos THEN
                IF NewTexture& < -1 THEN _FREEIMAGE NewTexture&
                NewTexture& = ROTO(rotos): OldRoto = rotos
            END IF
        END IF



        IF ONPOS(_MOUSEX, _MOUSEY, 225, 465, 395, 480) THEN
            LINE (225, 465)-(395, 480), _RGBA32(127, 127, 127, 100), BF
            IF _MOUSEBUTTON(1) THEN
                IF NewTexture& < -1 THEN
                    _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), NewTexture&: _DISPLAY: SLEEP 2
                END IF
            END IF
        END IF


        IF ONPOS(_MOUSEX, _MOUSEY, 465, 465, 635, 480) THEN
            LINE (465, 465)-(635, 480), _RGBA32(127, 127, 127, 100), BF
            IF _MOUSEBUTTON(1) THEN
                Img_Textures_per_Object = 1
                Img_Height_From = -2
                Img_Height_To = 2
                Floor_Height_From = -2
                Floor_Height_To = -2
                Ceil_Height_From = 2
                Ceil_Height_To = 2
                rotos = 0
            END IF
        END IF


        _DISPLAY
    LOOP UNTIL INKEY$ = CHR$(27) OR complete

    IF NewTexture& < -1 THEN
        u = UBOUND(Texture)
        REDIM _PRESERVE Texture(u + 1) AS Texture
        NTN$ = GET_NEW_TEXTURE_NAME
        Texture(u + 1).img = NewTexture&
        Texture(u + 1).path = NTN$

        'SteveMcNeil's saveimage utility 'older version, not JPG
        res = SaveImage(Texture(u + 1).path, NewTexture&, 0, 0, _WIDTH(NewTexture&), _HEIGHT(NewTexture&))
    END IF



END SUB

FUNCTION GET_NEW_TEXTURE_NAME$
    z$ = "Rotated_texture"
    DO
        GET_NEW_TEXTURE_NAME$ = ".\textures\" + z$ + STR$(nr) + ".PNG"
        nr = nr + 1
    LOOP UNTIL _FILEEXISTS(GET_NEW_TEXTURE_NAME$) = 0
END FUNCTION


FUNCTION ROTO& (angle AS SINGLE) 'modified ROTOZOOM
    actual = _DEST
    tmp& = _NEWIMAGE(_WIDTH(TextureIN), _HEIGHT(TextureIN), 32)
    _DEST tmp&
    CLS , 0 'for transparent background
    _DEST actual
    DIM px(3) AS INTEGER, py(3) AS INTEGER, w AS INTEGER, h AS INTEGER
    DIM sinr AS SINGLE, cosr AS SINGLE, i AS _BYTE
    w = _WIDTH(TextureIN): h = _HEIGHT(TextureIN)
    x = w / 2: y = h / 2
    px(0) = -w \ 2: py(0) = -h \ 2: px(3) = w \ 2: py(3) = -h \ 2
    px(1) = -w \ 2: py(1) = h \ 2: px(2) = w \ 2: py(2) = h \ 2
    sinr = SIN(angle / 57.2957795131): cosr = COS(angle / 57.2957795131)
    FOR i = 0 TO 3
        x2 = (px(i) * cosr + sinr * py(i)) + x: y2 = (py(i) * cosr - px(i) * sinr) + y
        px(i) = x2: py(i) = y2
    NEXT
    _MAPTRIANGLE (0, 0)-(0, h - 1)-(w - 1, h - 1), TextureIN TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2)), tmp&
    _MAPTRIANGLE (0, 0)-(w - 1, 0)-(w - 1, h - 1), TextureIN TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2)), tmp&

    ROTO& = tmp&
END FUNCTION


FUNCTION DoubleArrow (x AS INTEGER, y AS INTEGER) 'just for calling "DvojSipka"
    IF _MOUSEX >= x AND _MOUSEX < x + 21 AND _MOUSEY >= y + 3 AND _MOUSEY < y + 32 THEN '21x36 is image size
        IF _MOUSEY < y + 18 THEN LINE (x, y + 3)-(x + 21, y + 15), _RGBA32(127, 127, 127, 100), BF
        IF _MOUSEY > y + 18 THEN LINE (x, y + 20)-(x + 21, y + 32), _RGBA32(127, 127, 127, 100), BF

        IF _MOUSEBUTTON(1) = -1 THEN
            IF _MOUSEY < y + 18 THEN DoubleArrow = 1: _DELAY .1
            IF _MOUSEY > y + 18 THEN DoubleArrow = -1: _DELAY .1
        END IF
    END IF

END FUNCTION


SUB DELETE_TEXTURE 'odstrani texturu ze seznamu textur.
    ' TextureIN je sdilena promenna vracejici cislo zvolene textury

    'nejprve otestuju pole Grid(X,Y).img jestli tam je tato hodnota pouzita, pak oskenuju pole Texture(N).img, kde je tato hodnota pouzita, a tu smazu.
    'podle testu funkce LOADIMAGE, dojde ke smazani jedine, konkretni ikony. Pokud je stejny obrazek nacten jako dalsi ikona, ma uz jine ID a zustane.

    'test polr Grid:
    TYPE swap
        v1 AS LONG
        v2 AS LONG
    END TYPE

    REDIM swp(0) AS swap
    '   REDIM Tex(0) AS LONG
    'zkusim jen rychlou opravu rozlisenim podle rezimu editoru, stim, ze toto funguje pro wall mode, tak jen udelam dalsi 2 kopie podle tlacitka podle jejich hodnoty .active


    IF Button(12).active THEN

        FOR Gsx = LBOUND(Grid_img, 1) TO UBOUND(Grid_img, 1)
            FOR Gsy = LBOUND(Grid_img, 2) TO UBOUND(Grid_img, 2)
                value = Grid_img(Gsx, Gsy)
                IF value = TextureIN THEN
                    REDIM _PRESERVE swp(used) AS swap
                    swp(used).v1 = Gsx
                    swp(used).v2 = Gsy
                    used = used + 1
                END IF
        NEXT Gsy, Gsx



        FOR scn = LBOUND(Texture) TO UBOUND(Texture)
            IF Texture(scn).img = TextureIN THEN DelRec = scn: EXIT FOR 'je mozna jen jedna shoda!
        NEXT

        FOR EraseGrid = LBOUND(swp) TO UBOUND(swp)
            a1 = swp(EraseGrid).v1
            a2 = swp(EraseGrid).v2
            Grid_img(a1, a2) = 0: Grid_typ(a1, a2) = 0
        NEXT
        ERASE swp
        _DELAY .3
        GOTO test
    END IF

    IF Button(11).active THEN

        FOR Gsx = LBOUND(Grid_Ceil, 1) TO UBOUND(Grid_Ceil, 1)
            FOR Gsy = LBOUND(Grid_Ceil, 2) TO UBOUND(Grid_Ceil, 2)
                value = Grid_Ceil(Gsx, Gsy)
                IF value = TextureIN THEN
                    REDIM _PRESERVE swp(used) AS swap
                    swp(used).v1 = Gsx
                    swp(used).v2 = Gsy
                    used = used + 1
                END IF
        NEXT Gsy, Gsx


        FOR scn = LBOUND(Texture) TO UBOUND(Texture)
            IF Texture(scn).img = TextureIN THEN DelRec = scn: EXIT FOR 'je mozna jen jedna shoda!
        NEXT

        'vlastni vymaz
        FOR EraseGrid = LBOUND(swp) TO UBOUND(swp)
            a1 = swp(EraseGrid).v1
            a2 = swp(EraseGrid).v2
            Grid_Ceil(a1, a2) = 0: Grid_typ(a1, a2) = 0 'bude chtit upgrade podle kombinace poli
        NEXT
        ERASE swp

        _DELAY .3 'nutne, jinak na jedno kliknuti smazes osm az deset prdeli textur
        GOTO test
    END IF


    IF Button(10).active THEN
        FOR Gsx = LBOUND(Grid_Floor, 1) TO UBOUND(Grid_Floor, 1)
            FOR Gsy = LBOUND(Grid_Floor, 2) TO UBOUND(Grid_Floor, 2)
                value = Grid_Floor(Gsx, Gsy)
                IF value = TextureIN THEN
                    REDIM _PRESERVE swp(used) AS swap
                    swp(used).v1 = Gsx
                    swp(used).v2 = Gsy
                    used = used + 1
                END IF
        NEXT Gsy, Gsx

        'pole swp ted obsahuje indexy v1 a v2, kde se nachazi tato textura na mrizce. Velikost swp urcuje pocet vyskytu. OK

        FOR scn = LBOUND(Texture) TO UBOUND(Texture)
            IF Texture(scn).img = TextureIN THEN DelRec = scn: EXIT FOR 'je mozna jen jedna shoda!
        NEXT

        'vlastni vymaz
        FOR EraseGrid = LBOUND(swp) TO UBOUND(swp)
            a1 = swp(EraseGrid).v1
            a2 = swp(EraseGrid).v2
            Grid_Floor(a1, a2) = 0: Grid_typ(a1, a2) = 0 'bude chtit upgrade podle kombinace poli
        NEXT
        ERASE swp
        _DELAY .3 'nutne, jinak na jedno kliknuti smazes osm az deset prdeli textur
        GOTO test
    END IF


    'test na pritomnost v ostatnich polich
    test:
    FOR scn1 = LBOUND(Grid_img, 1) TO UBOUND(Grid_img, 1)
        FOR scn2 = LBOUND(Grid_img, 2) TO UBOUND(Grid_img, 2)
            IF Grid_img(scn1, scn2) = TextureIN THEN Is_in_img = 1
            IF Grid_Floor(scn1, scn2) = TextureIN THEN Is_in_floor = 1
            IF Grid_Ceil(scn1, scn2) = TextureIN THEN Is_in_ceil = 1
    NEXT: NEXT

    IF Button(10).active AND Is_in_ceil = 0 AND Is_in_img = 0 THEN GOTO killimage ELSE EXIT SUB 'floor
    IF Button(11).active AND Is_in_img = 0 AND Is_in_floor = 0 THEN GOTO killimage ELSE EXIT SUB 'ceil
    IF Button(12).active AND Is_in_ceil = 0 AND Is_in_floor = 0 THEN GOTO killimage ELSE EXIT SUB 'wall


    killimage:


    IF Texture(DelRec).img < -1 THEN _FREEIMAGE Texture(DelRec).img
    Texture(DelRec).img = 0: Texture(DelRec).path = ""

    i = 0
    REDIM NT(0) AS LONG
    REDIM Ntt(0) AS STRING
    FOR EraseNULL = LBOUND(Texture) TO UBOUND(Texture)
        record = Texture(EraseNULL).img
        IF record < -1 THEN
            REDIM _PRESERVE NT(i) AS LONG
            REDIM _PRESERVE Ntt(i) AS STRING
            NT(i) = record
            Ntt(i) = Texture(EraseNULL).path
            i = i + 1
        END IF
    NEXT

    REDIM Texture(UBOUND(NT)) AS Texture
    FOR reload = LBOUND(NT) TO UBOUND(NT)
        Texture(reload).img = NT(reload)
        Texture(reload).path = Ntt(reload)
    NEXT reload

    ERASE NT
    ERASE Ntt
    EXIT SUB

    CLS
    PRINT "pocet prvku pole texture:"; UBOUND(Texture)
    FOR k = LBOUND(Texture) TO UBOUND(Texture)
        PRINT "Zaznam: "; k; "Hodnota ( spravne < 1): "; Texture(k).img
    NEXT k
    PRINT "Hodnota pro TextureStart: "; TextureStart
    PRINT "Hodnota pro TextureEnd: "; TextureEnd
    _DISPLAY
    SLEEP




END SUB

FUNCTION Browse$ (mask AS STRING)
    'pro ucely programu bude prochazet pouze slozku \Textures

    'limited acces routine in this version
    SELECT CASE mask$
        CASE "JPGBMPGIFPNG": path$ = ".\textures\*.*": text$ = "Select texture:": dir$ = "TEXTURES": path2$ = ".\textures\"
        CASE "OBJ": path$ = ".\obj\*.obj": text$ = "Select object:": dir$ = "OBJ": path2$ = ".\obj\"
        CASE "MAP": path$ = ".\map\*.map": text$ = "Select map:": dir$ = "MAP": path2$ = ".\map\"
    END SELECT

    LINE (222, 166)-(824, 568), _RGB32(70, 70, 70), BF
    LINE (222, 166)-(824, 568), _RGB32(200, 200, 200), B
    LINE (224, 168)-(822, 566), _RGB32(200, 200, 200), B


    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (250 + _PRINTWIDTH(text$) / 2, 190), text$
    _PRINTSTRING (643, 190), "Preview: "

    LINE (250, 210)-(500, 530), _RGB32(255, 255, 255), B

    'ramecek pro nahled
    LINE (550, 210)-(796, 530), _RGB32(255, 255, 255), B





    'kontrola existence danych podadresaru

    IF _DIREXISTS(".\" + dir$) = 0 THEN MKDIR dir$
    CHDIR dir$

    'vypis do swapovaciho souboru pres DIR
    IF _FILEEXISTS("__swap-.txt") THEN KILL "__swap-.txt"
    c$ = "dir *.* > __swap-.txt  /B"

    SHELL _HIDE c$
    IF _FILEEXISTS("__swap-.txt") THEN
        REDIM rek(0) AS STRING
        f = FREEFILE
        OPEN "__swap-.txt" FOR INPUT AS #f
        DO UNTIL EOF(f)
            LINE INPUT #f, rek(i)
            REDIM _PRESERVE rek(UBOUND(rek) + 1) AS STRING
            i = i + 1
        LOOP
        CLOSE #f
        '    KILL "__swap-.txt"
    ELSE
        SCREEN 0
        PRINT "Fatal error: Can not creating swap file using DIR on "; _CWD$; " program line 952."
        _DISPLAY
        SLEEP 3
        SYSTEM
    END IF
    CHDIR ".."

    'filtrace podle masky v pripade, ze jde o textury - v budoucnu i filtrace souboru OBJ podle hlavicky souboru a souboru MAP podle hlavicky v souboru
    i = 0
    REDIM R(0) AS STRING
    FOR masc = 1 TO LEN(mask) STEP 3
        m$ = MID$(mask, masc, 3)
        FOR f = LBOUND(rek) TO UBOUND(rek)
            IF UCASE$(RIGHT$(rek(f), 3)) = m$ THEN
                R(i) = rek(f)
                REDIM _PRESERVE R(UBOUND(R) + 1) AS STRING
                i = i + 1
            END IF
    NEXT f, masc
    ERASE rek

    rr = UBOUND(R)
    IF rr > 1 THEN rr = rr - 1

    REDIM _PRESERVE R(rr) AS STRING


    _CLEARCOLOR 0, Icony(8)
    _FONT 16
    _PRINTSTRING (455, 543), "Back"
    LINE (420, 533)-(500, 563), , B
    _PUTIMAGE (420, 533), Icony(8)
    LINE (420, 533)-(500, 563), _RGBA32(70, 70, 70, 200), BF


    _CLEARCOLOR 0, Icony(9)
    _PUTIMAGE (250, 533), Icony(9) 'zelena fajfka ok
    LINE (260, 533)-(295, 563), _RGBA32(70, 70, 70, 190), BF


    _CLEARCOLOR 0, Icony(10)
    _PUTIMAGE (475, 210), Icony(10) 'sipka nahoru
    LINE (475, 214)-(495, 230), _RGBA32(70, 70, 70, 190), BF


    _CLEARCOLOR 0, Icony(11)
    _PUTIMAGE (475, 510), Icony(11) 'sipka dolu
    LINE (475, 510)-(495, 525), _RGBA32(70, 70, 70, 190), BF

    LINE (475, 228)-(495, 510), _RGB32(127, 127, 127), BF 'sedy pruh mezi sipkami

    PruhL = 30 'delka bileho ukazatele / pruhu mezi sipkami vpravo
    PrepocetLS = (480 - 228) / UBOUND(r)


    Sel = 0
    sh_s = LBOUND(R)
    sh_e = sh_s + 20
    IF sh_e > UBOUND(R) THEN sh_e = UBOUND(R)
    'startovni nastaveni
    PCOPY _DISPLAY, 1
    DO
        PCOPY 1, _DISPLAY
        inmouse = 0
        DO WHILE _MOUSEINPUT: mwh = mwh + _MOUSEWHEEL: inmouse = 1: LOOP
        i$ = INKEY$


        '        LOCATE 1, 1: PRINT _MOUSEX, _MOUSEY: _DISPLAY
        pruhStart = (Sel * PrepocetLS) + 228
        LINE (480, pruhStart)-(490, pruhStart + PruhL), _RGB32(100, 100, 120), BF 'ty vole. Na prvni pokus. Nechapu.
        IF ONPOS(_MOUSEX, _MOUSEY, 480, pruhStart, 490, pruhStart + PruhL) THEN

            IF beginmousey = 0 THEN beginmousey = _MOUSEY
            IF _MOUSEBUTTON(1) THEN
                IF _MOUSEY < beginmousey THEN i$ = CHR$(0) + CHR$(72)
                IF _MOUSEY > beginmousey THEN i$ = CHR$(0) + CHR$(80)

            END IF
        ELSE
            beginmousey = 0
        END IF

        'podpora pro mys:
        IF inmouse THEN
            IF ONPOS(_MOUSEX, _MOUSEY, 250, 220, 400, 530) THEN 'doplnek - vyber souboru v okne mysi' X2 ze 475 na 400

                Sel = sh_s + _CEIL((_MOUSEY - 222) / 16)
                IF _MOUSEBUTTON(1) THEN i$ = CHR$(13)
            END IF
        END IF

        mb1 = _MOUSEBUTTON(1)

        Sel = Sel + mwh
        mwh = 0 'tato konstrukce je ok

        _FONT 16
        COLOR _RGB32(255, 255, 255)

        _PRINTSTRING (455, 543), "Back"
        LINE (420, 533)-(500, 563), , B
        IF ONPOS(_MOUSEX, _MOUSEY, 420, 533, 500, 563) THEN
            _PUTIMAGE (420, 533), Icony(8)
            LINE (420, 533)-(500, 563), _RGBA32(255, 255, 255, 60), BF
            IF mb1 THEN i$ = CHR$(27)
        END IF

        _PRINTSTRING (285, 543), "  Ok"
        LINE (250, 533)-(330, 563), , B
        IF ONPOS(_MOUSEX, _MOUSEY, 250, 533, 330, 563) THEN
            _PUTIMAGE (250, 533), Icony(9)
            LINE (250, 533)-(330, 563), _RGBA32(255, 255, 255, 60), BF
            IF mb1 THEN i$ = CHR$(13)
        END IF

        _FONT 8
        IF ONPOS(_MOUSEX, _MOUSEY, 475, 214, 495, 230) THEN
            _PUTIMAGE (475, 210), Icony(10)
            IF mb1 THEN i$ = CHR$(0) + CHR$(72)
        END IF

        IF ONPOS(_MOUSEX, _MOUSEY, 475, 510, 495, 525) THEN
            _PUTIMAGE (475, 510), Icony(11)
            IF mb1 THEN i$ = CHR$(0) + CHR$(80)
        END IF
        IF mb1 THEN
            mb1 = 0
            _DELAY .1
        END IF

        SELECT CASE i$
            CASE CHR$(0) + CHR$(72) ' up
                Sel = Sel - 1
            CASE CHR$(0) + CHR$(80) 'dn
                Sel = Sel + 1
            CASE CHR$(13)

                IF UBOUND(R) > 0 THEN 'pri prazdne slozce nic nedelej, ukonci prohlizec

                    IF mask$ = "JPGBMPGIFPNG" THEN
                        pokus = _LOADIMAGE(path2$ + R(Sel), 32)
                        IF pokus < -1 THEN Browse$ = ".\textures\" + R(Sel): _FREEIMAGE pokus: EXIT FUNCTION
                    END IF
                    IF mask$ = "MAP" AND MAP_IS_SUPPORTED(".\map\" + R(Sel)) THEN Browse$ = ".\map\" + R(Sel): EXIT FUNCTION
                ELSE
                    EXIT FUNCTION
                END IF

            CASE CHR$(27)
                Browse$ = "": EXIT FUNCTION
        END SELECT

        IF Sel < sh_s THEN sh_s = sh_s - 1
        IF Sel < LBOUND(R) THEN Sel = LBOUND(R)
        IF Sel > sh_e THEN sh_s = sh_s + 1
        IF Sel > UBOUND(R) THEN Sel = UBOUND(R)

        IF sh_s > UBOUND(R) - 20 THEN sh_s = UBOUND(R) - 20
        IF sh_s < LBOUND(R) THEN sh_s = LBOUND(R)
        sh_e = sh_s + 20
        IF sh_e > UBOUND(R) THEN sh_e = UBOUND(R)


        shw = -1
        FOR show = sh_s TO sh_e
            shw = shw + 1
            IF Sel = show THEN 'reseni pro misto, kde je oznacena polozka
                COLOR _RGB32(255, 255, 0)

                ven$ = R(show)
                IF LEN(ven$) > 28 THEN ven$ = LEFT$(ven$, 25) + "..."
                _PRINTSTRING (250, 220 + (shw * 15)), ven$

                IF Viewed = 0 THEN


                    SELECT CASE mask$
                        CASE "JPGBMPGIFPNG" 'PRO TEXTURY
                            s& = _LOADIMAGE(path2$ + R(Sel))
                            IF s& < -1 THEN
                                _PUTIMAGE (551, 211)-(795, 529), s&: Viewed = 1
                            ELSE
                                _PUTIMAGE (551, 211)-(795, 529), Icony(7): Viewed = 0 'pokud je neplatny format souboru
                            END IF

                        CASE "MAP"
                            MapImage& = FAST_MAP_INFO(path2$ + R(Sel))
                            _PUTIMAGE (551, 211)-(795, 529), MapImage&: Viewed = 1



                    END SELECT




                END IF

            ELSE COLOR _RGB32(255, 255, 255) 'reseni pro otatni polozky

                ven$ = R(show)
                IF LEN(ven$) > 28 THEN ven$ = LEFT$(ven$, 25) + "..."
                _PRINTSTRING (250, 220 + (shw * 15)), ven$

                IF Viewed THEN
                    Viewed = 0
                    SELECT CASE mask$
                        CASE "JPGBMPGIFPNG"
                            _FREEIMAGE s&
                        CASE "MAP"
                            _FREEIMAGE MapImage&
                    END SELECT
                END IF
            END IF
        NEXT show
        _DISPLAY
        _LIMIT 50
    LOOP


END FUNCTION

FUNCTION MAP_IS_SUPPORTED (pathmap AS STRING) '1 = is, 0 = unsupported
    IF _FILEEXISTS(pathmap) THEN
        REDIM MH AS MAP_HEAD
        g = FREEFILE
        OPEN pathmap FOR BINARY AS #g
        GET #g, , MH
        IF MH.Identity = "MAP3D" AND MH.Nr_of_Textures THEN MAP_IS_SUPPORTED = 1
        CLOSE #g
    END IF
END FUNCTION






FUNCTION ONPOS (x, y, x1, y1, x2, y2)
    IF x > x1 AND x < x2 AND y > y1 AND y < y2 THEN ONPOS = 1
END FUNCTION


FUNCTION WHOIS (x, y)


    IF Grid_img(x, y) THEN Is_in_img = 1
    IF Grid_Floor(x, y) THEN Is_in_floor = 1
    IF Grid_Ceil(x, y) THEN Is_in_ceil = 1

    IF Is_in_img = 0 AND Is_in_floor = 0 AND Is_in_ceil = 0 THEN WHOIS = 0
    IF Is_in_img = 1 AND Is_in_floor = 0 AND Is_in_ceil = 0 THEN WHOIS = 1
    IF Is_in_img = 0 AND Is_in_floor = 1 AND Is_in_ceil = 0 THEN WHOIS = 2
    IF Is_in_img = 0 AND Is_in_floor = 0 AND Is_in_ceil = 1 THEN WHOIS = 3
    IF Is_in_img = 1 AND Is_in_floor = 1 AND Is_in_ceil = 0 THEN WHOIS = 12
    IF Is_in_img = 1 AND Is_in_floor = 0 AND Is_in_ceil = 1 THEN WHOIS = 13
    IF Is_in_img = 0 AND Is_in_floor = 1 AND Is_in_ceil = 1 THEN WHOIS = 23
    IF Is_in_img AND Is_in_floor AND Is_in_ceil THEN WHOIS = 123

END FUNCTION


SUB Delete_Objects_in_area (sx AS INTEGER, sy AS INTEGER, ex AS INTEGER, ey AS INTEGER)
    IF sx < ex THEN SWAP sx, ex
    IF sy < ey THEN SWAP sy, ey
    FOR y = sy TO ey
        FOR x = sx TO ex
            Grid_Obj(x, y) = 0
    NEXT x, y
END SUB

SUB Delete_Sounds_in_area (sx AS INTEGER, sy AS INTEGER, ex AS INTEGER, ey AS INTEGER)
    IF sx < ex THEN SWAP sx, ex
    IF sy < ey THEN SWAP sy, ey
    FOR y = sy TO ey
        FOR x = sx TO ex
            Grid_SND(x, y) = 0
    NEXT x, y
END SUB


SUB Add_Sound_to_area (sx AS INTEGER, sy AS INTEGER, ex AS INTEGER, ey AS INTEGER) 'dodatecne se musi doplnit jak to ma prehrat.
    IF SoundIN THEN
        FOR y = sy TO ey
            FOR x = sx TO ex
                Grid_SND(x, y) = SoundIN
        NEXT x, y
    END IF
END SUB

SUB DialogW (Message AS STRING, ID)
    DIALOG = 1
    PCOPY _DISPLAY, 1
    DO
        '512, 384

        Init_Screen
        PCOPY 1, _DISPLAY
        WHILE _MOUSEINPUT: WEND

        SELECT CASE ID
            CASE 1
                LINE (398, 343)-(624, 424), _RGB32(155, 127, 127), BF
                LINE (398, 343)-(624, 424), _RGB32(255, 255, 255), B
                LINE (400, 345)-(622, 422), _RGB32(255, 255, 255), B
                _PRINTMODE _KEEPBACKGROUND
                stred = 112 - _PRINTWIDTH(Message) / 2
                _PRINTSTRING (400 + stred, 360), Message
                P = Place_Buttons
                _CLEARCOLOR 0, Icony(5)
                _PUTIMAGE (570, 380), Icony(5)
                IF P = 16 THEN GOTO after
                IF P = 15 THEN

                    'SAVEMAP jeste neexistuje
                    from1 = 1
                    Message$ = "Save MAP as:"
                    GOTO savedialog ' skoci na dotaz na jmeno pod kterym to ma ulozit
                    after:
                    FOR ers = 1 TO 16
                        _FREEIMAGE Button(ers).imgA
                        _FREEIMAGE Button(ers).imgB
                        IF ers <= UBOUND(Icony) THEN _FREEIMAGE Icony(ers)
                    NEXT ers
                    SYSTEM
                END IF
                ' IF P = 16 THEN DIALOG = 0: EXIT DO

            CASE 2
                savedialog: 'small spaghetti block..... :-D


                LINE (398, 343)-(624, 424), _RGB32(155, 127, 127), BF
                LINE (398, 343)-(624, 424), _RGB32(255, 255, 255), B
                LINE (400, 345)-(622, 422), _RGB32(255, 255, 255), B
                LINE (398, 370)-(624, 370), _RGB32(255, 255, 255)
                LINE (398, 390)-(624, 390), _RGB32(255, 255, 255)


                'malba tlacitek 15 = yes, 16 = no

                _PUTIMAGE (420, 388), Button(15).imgB
                _PUTIMAGE (545, 388), Button(16).imgB


                _PRINTMODE _KEEPBACKGROUND
                _PRINTSTRING (465, 355), Message 'spocitano na text "Save MAP as:"
                DIM Nam AS STRING



                DO UNTIL LEN(Nam$)
                    WHILE _MOUSEINPUT: WEND
                    IF _MOUSEX >= 398 AND _MOUSEX <= 624 AND _MOUSEY >= 370 AND _MOUSEY <= 390 THEN
                        _MOUSESHOW "text" 'jsi v prostoru textoveho pole
                        IF _MOUSEBUTTON(1) THEN
                            _MOUSESHOW "default"
                            _KEYCLEAR
                            T = TIMER
                            PCOPY _DISPLAY, 5
                            DO UNTIL i$ = CHR$(13) AND LEN(Nam$)
                                PCOPY 5, _DISPLAY
                                WHILE _MOUSEINPUT: WEND
                                IF ONPOS(_MOUSEX, _MOUSEY, 420, 388, 470, 418) THEN
                                    _PUTIMAGE (420, 388), Button(15).imgA
                                    IF _MOUSEBUTTON(1) THEN

                                        IF LEN(Nam$) THEN EXIT DO
                                    END IF
                                END IF 'doplnit imgB

                                IF ONPOS(_MOUSEX, _MOUSEY, 545, 388, 595, 418) THEN
                                    _PUTIMAGE (545, 388), Button(16).imgA
                                    IF _MOUSEBUTTON(1) THEN DIALOG = 0: EXIT SUB
                                END IF


                                SELECT CASE TIMER - T
                                    CASE 0 TO .2: cursor$ = "-"
                                    CASE .21 TO .41: cursor$ = "/"
                                    CASE .42 TO .62: cursor$ = "|"
                                    CASE .63 TO .83: cursor$ = "\"
                                    CASE IS > .84: T = TIMER
                                END SELECT





                                IF LEN(Nam$) > 25 THEN Nam$ = LEFT$(Nam$, 25)
                                CursorPos = LEN(Nam$) * 8
                                _PRINTMODE _FILLBACKGROUND
                                COLOR _RGB32(255), _RGB32(125, 127, 127)
                                _PRINTSTRING (410, 378), Nam$ + cursor$

                                i$ = INKEY$
                                IF LEN(i$) THEN
                                    SELECT CASE ASC(i$)
                                        CASE 32 TO 126
                                            Nam$ = Nam$ + i$
                                        CASE 8
                                            Nam$ = LEFT$(Nam$, LEN(Nam$) - 1)
                                    END SELECT
                                END IF
                                _DISPLAY
                            LOOP
                        END IF

                    ELSE _MOUSESHOW "default"
                    END IF
                    _DISPLAY
                LOOP
                ONam$ = Nam$
                Nam$ = Nam$ + ".MAP"


                DO WHILE _FILEEXISTS(Nam$) = -1
                    rnr = rnr + 1
                    Nam$ = ONam$ + STR$(rnr) + ".MAP"
                LOOP

                SAVE_MAP (Nam$)

                IF from1 THEN GOTO after
                DIALOG = 0
                EXIT SUB

            CASE 3

                icon = LOADICO("ico/warn.ico", 4)
                _CLEARCOLOR 0, icon
                LINE (398, 343)-(624, 424), _RGB32(255, 0, 0), BF
                LINE (398, 343)-(624, 424), _RGB32(255, 255, 255), B
                LINE (400, 345)-(622, 422), _RGB32(255, 255, 255), B
                _PRINTMODE _FILLBACKGROUND
                COLOR _RGB32(255), _RGB32(255, 0, 0)

                _PRINTSTRING (500, 360), "Map is empty!"
                _PUTIMAGE (420, 370), icon
                _PUTIMAGE (500, 380), Button(0).imgB
                PCOPY _DISPLAY, 5

                DO UNTIL status
                    PCOPY 5, _DISPLAY
                    WHILE _MOUSEINPUT: WEND
                    IF ONPOS(_MOUSEX, _MOUSEY, 500, 390, 550, 420) THEN
                        _PUTIMAGE (500, 380), Button(0).imgA
                        IF _MOUSEBUTTON(1) THEN status = 1
                    END IF
                    _DISPLAY
                LOOP
                _FREEIMAGE icon
                EXIT SUB

            CASE 4 'New Map
                DIALOG = 0


                status = 0
                IF IS_EMPTY_TEXTURECACHE THEN
                    GOTO gridtest


                ELSE

                    icon = LOADICO("ico/ot.ico", 4)
                    _CLEARCOLOR 0, icon
                    LINE (398, 343)-(624, 424), _RGB32(255, 0, 0), BF
                    LINE (398, 343)-(624, 424), _RGB32(255, 255, 255), B
                    LINE (400, 345)-(622, 422), _RGB32(255, 255, 255), B
                    _PRINTMODE _FILLBACKGROUND
                    COLOR _RGB32(255), _RGB32(255, 0, 0)
                    _PRINTSTRING (425, 360), "Clear texture list?"
                    _PUTIMAGE (420, 380), icon


                    _PUTIMAGE (460, 385), Button(15).imgB
                    _PUTIMAGE (545, 385), Button(16).imgB



                    PCOPY _DISPLAY, 5
                    status = 0
                    DO UNTIL status
                        PCOPY 5, _DISPLAY
                        WHILE _MOUSEINPUT: WEND
                        IF ONPOS(_MOUSEX, _MOUSEY, 460, 385, 550, 420) THEN
                            _PUTIMAGE (460, 385), Button(15).imgA
                            IF _MOUSEBUTTON(1) THEN
                                CLEARTEXTURES
                                CLEARGRID
                                EXIT SUB
                            END IF
                        END IF

                        IF ONPOS(_MOUSEX, _MOUSEY, 545, 385, 645, 420) THEN
                            _PUTIMAGE (545, 385), Button(16).imgA
                            IF _MOUSEBUTTON(1) THEN GOTO gridtest 'status = 1
                        END IF

                        _DISPLAY
                    LOOP

                END IF







                gridtest:
                _DELAY .5
                IF IS_EMPTY_GRID = 0 THEN
                    'varovani, ze v polich Grid neco je, jestli to chces smazat

                    icon = LOADICO("ico/ot.ico", 4)
                    _CLEARCOLOR 0, icon
                    LINE (398, 343)-(624, 424), _RGB32(255, 0, 0), BF
                    LINE (398, 343)-(624, 424), _RGB32(255, 255, 255), B
                    LINE (400, 345)-(622, 422), _RGB32(255, 255, 255), B
                    _PRINTMODE _FILLBACKGROUND
                    COLOR _RGB32(255), _RGB32(255, 0, 0)
                    _PRINTSTRING (430, 360), "Delete all MAP data?"
                    _PUTIMAGE (420, 380), icon


                    _PUTIMAGE (460, 385), Button(15).imgB
                    _PUTIMAGE (545, 385), Button(16).imgB



                    PCOPY _DISPLAY, 5
                    status = 0
                    DO UNTIL status
                        PCOPY 5, _DISPLAY
                        WHILE _MOUSEINPUT: WEND
                        IF ONPOS(_MOUSEX, _MOUSEY, 460, 385, 550, 420) THEN
                            _PUTIMAGE (460, 385), Button(15).imgA
                            IF _MOUSEBUTTON(1) THEN CLEARGRID: status = 1
                        END IF


                        IF ONPOS(_MOUSEX, _MOUSEY, 545, 385, 645, 420) THEN
                            _PUTIMAGE (545, 385), Button(16).imgA
                            IF _MOUSEBUTTON(1) THEN status = 1
                        END IF

                        _DISPLAY
                    LOOP
                    _FREEIMAGE icon
                    EXIT SUB
                ELSE
                    EXIT SUB
                END IF

            CASE 5


                icon = LOADICO("ico/ot.ico", 4)
                _CLEARCOLOR 0, icon
                LINE (398, 343)-(624, 424), _RGB32(255, 0, 0), BF
                LINE (398, 343)-(624, 424), _RGB32(255, 255, 255), B
                LINE (400, 345)-(622, 422), _RGB32(255, 255, 255), B
                _PRINTMODE _FILLBACKGROUND
                COLOR _RGB32(255), _RGB32(255, 0, 0)
                _PRINTSTRING (430, 360), Message$
                _PUTIMAGE (420, 380), icon


                _PUTIMAGE (460, 385), Button(15).imgB
                _PUTIMAGE (545, 385), Button(16).imgB



                PCOPY _DISPLAY, 5
                status = 0
                DO UNTIL status
                    PCOPY 5, _DISPLAY
                    WHILE _MOUSEINPUT: WEND
                    IF ONPOS(_MOUSEX, _MOUSEY, 460, 385, 550, 420) THEN 'save
                        _PUTIMAGE (460, 385), Button(15).imgA
                        IF _MOUSEBUTTON(1) THEN
                            Message$ = "Save MAP as:"
                            GOTO savedialog
                            beforeload:

                            status = 1
                        END IF
                    END IF


                    IF ONPOS(_MOUSEX, _MOUSEY, 545, 385, 645, 420) THEN 'no
                        _PUTIMAGE (545, 385), Button(16).imgA
                        IF _MOUSEBUTTON(1) THEN status = 1
                    END IF

                    _DISPLAY
                LOOP
                _FREEIMAGE icon
                DIALOG = 0
                EXIT SUB
        END SELECT

        _LIMIT 60
        _DISPLAY
    LOOP

END SUB




SUB CLEARTEXTURES
    FOR w = LBOUND(Texture) TO UBOUND(Texture)
        IF Texture(w).img < -1 THEN
            _FREEIMAGE Texture(w).img
            Texture(w).img = 0
        END IF
    NEXT
    REDIM Texture(0) AS Texture
END SUB



SUB CLEARGRID
    FOR v = LBOUND(Grid_img, 1) TO UBOUND(Grid_img, 1)
        FOR w = LBOUND(Grid_img, 2) TO UBOUND(Grid_img, 2)
            Grid_img(v, w) = -1
            Grid_Ceil(v, w) = -1
            Grid_Floor(v, w) = -1 'byly nuly, coz je odkaz na texture(0), teda asi
            '            Grid_Obj(v, w) = 0
            Grid_typ(v, w) = 0
    NEXT w, v
END SUB


SUB Copy_contens_in_area (Rxs, Rys, Rxe, Rye)


    IF Rxs > Rxe THEN SWAP Rxs, Rxe
    IF Rys > Rye THEN SWAP Rys, Rye

    COPY_OR_INSERT_Right_click_menu(0) = Rxs
    COPY_OR_INSERT_Right_click_menu(1) = Rys
    COPY_OR_INSERT_Right_click_menu(2) = Rxe
    COPY_OR_INSERT_Right_click_menu(3) = Rye
END SUB


SUB Insert_contens_in_area (Rx, Ry)
    FOR i = 0 TO 3
        IF COPY_OR_INSERT_Right_click_menu(i) = 0 THEN empty = 1 ELSE empty = 0 '
    NEXT i
    IF empty THEN
        EXIT SUB
    ELSE
        FOR copyY = COPY_OR_INSERT_Right_click_menu(1) TO COPY_OR_INSERT_Right_click_menu(3)
            iX = 0
            FOR copyX = COPY_OR_INSERT_Right_click_menu(0) TO COPY_OR_INSERT_Right_click_menu(2)
                NewX = iX + Rx
                iX = iX + 1
                NewY = iY + Ry
                IF NewX > UBOUND(Grid_img, 1) THEN NewX = UBOUND(Grid_img, 1)
                IF NewY > UBOUND(Grid_img, 2) THEN NewY = UBOUND(Grid_img, 2)

                'upgrade: kopie se budou vkladat do mapy v zavislosti na nastaveni. Budto individualne, tedy jen zed/podlaha/strop/objekt, nebo jako celek
                SELECT CASE INSERT_SETUP '0 = vse (puvodni), 1 = individualne

                    CASE 0 'vse se prepise
                        Grid_img(NewX, NewY) = Grid_img(copyX, copyY)
                        IP_Img(NewX, NewY) = IP_Img(copyX, copyY)


                        Grid_Ceil(NewX, NewY) = Grid_Ceil(copyX, copyY)
                        IP_Ceil(NewX, NewY) = IP_Img(copyX, copyY)


                        Grid_Floor(NewX, NewY) = Grid_Floor(copyX, copyY)
                        IP_Floor(NewX, NewY) = IP_Img(copyX, copyY)


                        Grid_typ(NewX, NewY) = Grid_typ(copyX, copyY)
                        Grid_Obj(NewX, NewY) = Grid_Obj(copyX, copyY)

                    CASE 1 'prepise se jen konkretni typ podle stiskleho tlacitka
                        IF Button(10).active THEN
                            Grid_Floor(NewX, NewY) = Grid_Floor(copyX, copyY)
                            IP_Floor(NewX, NewY) = IP_Img(copyX, copyY)
                        END IF

                        IF Button(11).active THEN
                            Grid_Ceil(NewX, NewY) = Grid_Ceil(copyX, copyY)
                            IP_Ceil(NewX, NewY) = IP_Img(copyX, copyY)
                        END IF

                        IF Button(12).active THEN
                            Grid_img(NewX, NewY) = Grid_img(copyX, copyY)
                            IP_Img(NewX, NewY) = IP_Img(copyX, copyY)
                        END IF

                        IF ObjectIN THEN
                            Grid_Obj(NewX, NewY) = Grid_Obj(copyX, copyY)
                        END IF
                        Grid_typ(NewX, NewY) = Grid_typ(copyX, copyY)
                END SELECT

            NEXT copyX
            iY = iY + 1
        NEXT copyY
    END IF
END SUB




FUNCTION IS_EMPTY_GRID '1 = ano, je prazdna mapa, 0 = ne, na mape neco je
    IS_EMPTY_GRID = 1
    FOR v = LBOUND(Grid_img, 1) TO UBOUND(Grid_img, 1)
        FOR w = LBOUND(Grid_img, 2) TO UBOUND(Grid_img, 2)
            IF Grid_img(v, w) OR Grid_Ceil(v, w) OR Grid_Floor(v, w) THEN IS_EMPTY_GRID = 0 'docasne vyrazen grid OBJ
    NEXT w, v
END FUNCTION

FUNCTION IS_EMPTY_TEXTURECACHE '1 = ano, v poli textur nic neni, 1 = v poli textur neco je
    IS_EMPTY_TEXTURECACHE = 1
    FOR w = LBOUND(Texture) TO UBOUND(Texture)
        IF Texture(w).img < -1 THEN IS_EMPTY_TEXTURECACHE = 0: EXIT FUNCTION
    NEXT
END FUNCTION

SUB Reset_Mouse
    'reset mouseinputs from previous subs
    DO UNTIL _MOUSEBUTTON(1) = 0
        WHILE _MOUSEINPUT: WEND
    LOOP
    '--------------------------------
END SUB


SUB Init_Screen

    CLS , _RGB32(95, 95, 95)
    LINE (0, 668)-(1023, 767), _RGB32(70, 70, 70), BF


    LINE (923, 0)-(1023, 767), _RGB32(70, 70, 70), BF
    LINE (923, 0)-(1023, 668), _RGB32(255, 255, 255), B
    LINE (0, 668)-(1023, 767), _RGB32(255, 255, 255), B

    _PUTIMAGE (10, 700), Icony(1) 'sipka vlevo
    _PUTIMAGE (510, 700), Icony(2) ' vpravo
    _PUTIMAGE (950, 10), Icony(3) 'nahoru
    _PUTIMAGE (950, 610), Icony(4) 'dolu





    TextureInit = TextureStart
    FOR pas = 85 TO 505 STEP 70
        _PUTIMAGE (927, pas), Icony(6)
    NEXT pas

    'ikony foto textur
    i = 95

    IF TextureStart < LBOUND(Texture) THEN TextureStart = LBOUND(Texture)
    IF TextureEnd > UBOUND(Texture) THEN TextureEnd = UBOUND(Texture)


    FOR ShowTextures = TextureStart TO TextureEnd
        IF Texture(ShowTextures).img < -1 THEN 'pridano pri funkce DELETE TEXTURE

            '            PRINT Texture(ShowTextures).img, ShowTextures: _DISPLAY

            _PUTIMAGE (950, i)-(1000, i + 50), Texture(ShowTextures).img
            _PRINTMODE _KEEPBACKGROUND
            _PRINTSTRING (930, i), STR$(ShowTextures)

            i = i + 70
        END IF '                                 pridano
    NEXT

    DO WHILE _MOUSEINPUT: mwh = mwh + _MOUSEWHEEL: LOOP
    mwh = mwh + mwh

    kbd_agent$ = INKEY$
    IF SGN(mwh) > 0 THEN kbd_agent$ = CHR$(0) + CHR$(80)
    IF SGN(mwh) < 0 THEN kbd_agent$ = CHR$(0) + CHR$(72)
    mwh = 0


    IF TextureSelected < LBOUND(Texture) THEN TextureSelected = LBOUND(Texture)
    IF TextureStart > TextureSelected THEN TextureStart = TextureSelected
    IF TextureStart + 6 < UBOUND(Texture) THEN TextureEnd = TextureStart + 6 ELSE TextureEnd = UBOUND(Texture)
    '-----------------------

    IF _MOUSEX > 950 AND _MOUSEX < 997 AND _MOUSEY > 10 AND _MOUSEY < 57 THEN

        IF _MOUSEBUTTON(1) = 0 THEN LINE (950, 10)-(997, 57), _RGBA32(255, 255, 255, 60), BF
        IF _MOUSEBUTTON(1) THEN
            _PUTIMAGE (951, 11), Icony(3) 'nahoru
            LINE (950, 10)-(997, 57), _RGBA32(255, 255, 255, 60), BF
            TextureSelected = TextureSelected - 1
            IF TextureSelected < LBOUND(Texture) THEN TextureSelected = LBOUND(Texture)
            IF TextureStart > TextureSelected THEN TextureStart = TextureSelected
            IF TextureStart + 6 < UBOUND(Texture) THEN TextureEnd = TextureStart + 6 ELSE TextureEnd = UBOUND(Texture)
            _DELAY .1
        END IF
    END IF

    'posuv foto textur SIPKA DOLU

    IF _MOUSEX > 950 AND _MOUSEX < 997 AND _MOUSEY > 610 AND _MOUSEY < 657 THEN
        IF _MOUSEBUTTON(1) = 0 THEN LINE (950, 610)-(997, 657), _RGBA32(255, 255, 255, 60), BF
        IF _MOUSEBUTTON(1) THEN
            _PUTIMAGE (951, 611), Icony(4) 'dolu
            LINE (950, 610)-(997, 657), _RGBA32(255, 255, 255, 60), BF
            TextureSelected = TextureSelected + 1
            IF TextureSelected > UBOUND(Texture) THEN TextureSelected = UBOUND(Texture)
            IF TextureEnd < TextureSelected THEN TextureEnd = TextureSelected
            IF TextureEnd - 6 > LBOUND(Texture) THEN TextureStart = TextureEnd - 6 ELSE TextureStart = LBOUND(Texture)
            _DELAY .1
        END IF
    END IF



    'podpora ovladani fototextur z klavesnice
    IF _MOUSEX > 950 AND _MOUSEX < 997 AND _MOUSEY > 10 AND _MOUSEY < 657 THEN
        '        kbd_agent$ = INKEY$
        SELECT CASE kbd_agent$
            CASE CHR$(0) + CHR$(80) 'dolu
                _PUTIMAGE (951, 611), Icony(4) 'dolu
                LINE (950, 610)-(997, 657), _RGBA32(255, 255, 255, 60), BF
                TextureSelected = TextureSelected + 1
                IF TextureSelected > UBOUND(Texture) THEN TextureSelected = UBOUND(Texture)
                IF TextureEnd < TextureSelected THEN TextureEnd = TextureSelected
                IF TextureEnd - 6 > LBOUND(Texture) THEN TextureStart = TextureEnd - 6 ELSE TextureStart = LBOUND(Texture)


            CASE CHR$(0) + CHR$(72) 'nahoru
                _PUTIMAGE (951, 11), Icony(3) 'nahoru
                LINE (950, 10)-(997, 57), _RGBA32(255, 255, 255, 60), BF
                TextureSelected = TextureSelected - 1
                IF TextureSelected < LBOUND(Texture) THEN TextureSelected = LBOUND(Texture)
                IF TextureStart > TextureSelected THEN TextureStart = TextureSelected
                IF TextureStart + 6 < UBOUND(Texture) THEN TextureEnd = TextureStart + 6 ELSE TextureEnd = UBOUND(Texture)

                'upgrade - pridana podpora pro PGUP, PGDN, HOME a END       home 71, end 79
            CASE CHR$(0) + CHR$(71) 'home
                TextureStart = LBOUND(Texture)
                IF UBOUND(Texture) > TextureStart + 6 THEN TextureEnd = TextureStart + 6 ELSE TextureEnd = UBOUND(Texture)
                TextureSelected = LBOUND(Texture)

            CASE CHR$(0) + CHR$(79) 'end
                IF UBOUND(Texture) > 6 THEN
                    TextureEnd = UBOUND(Texture)
                    TextureStart = TextureEnd - 6
                ELSE TextureEnd = UBOUND(Texture)
                    TextureStart = LBOUND(Texture)
                END IF
                TextureSelected = UBOUND(Texture)

            CASE CHR$(0) + CHR$(73) 'pgup
                IF TextureStart - 6 > LBOUND(Texture) THEN
                    TextureStart = TextureStart - 6
                    TextureEnd = TextureStart + 6
                    TextureSelected = TextureSelected - 6
                ELSE
                    TextureStart = LBOUND(Texture)
                    TextureSelected = LBOUND(Texture)
                    IF UBOUND(Texture) > 6 THEN
                        TextureEnd = TextureStart + 6
                    ELSE
                        TextureEnd = UBOUND(Texture)
                    END IF
                END IF

            CASE CHR$(0) + CHR$(81) 'pgdn
                IF TextureEnd + 6 < UBOUND(Texture) THEN
                    TextureStart = TextureStart + 6
                    TextureEnd = TextureStart + 6
                    TextureSelected = TextureSelected + 6
                ELSE
                    TextureEnd = UBOUND(Texture)
                    TextureSelected = UBOUND(Texture)
                    IF UBOUND(Texture) > 6 THEN
                        TextureStart = TextureEnd - 6
                    ELSE
                        TextureStart = LBOUND(Texture)
                    END IF
                END IF
        END SELECT
    END IF

    SHARED TextureIN

    IF _MOUSEX > 929 AND _MOUSEX < 1020 AND _MOUSEBUTTON(1) THEN
        SELECT CASE _MOUSEY
            CASE 87 TO 154: TextureSelected = TextureStart + 0
            CASE 157 TO 225: TextureSelected = TextureStart + 1
            CASE 229 TO 295: TextureSelected = TextureStart + 2
            CASE 299 TO 366: TextureSelected = TextureStart + 3
            CASE 368 TO 435: TextureSelected = TextureStart + 4
            CASE 440 TO 506: TextureSelected = TextureStart + 5
            CASE 509 TO 578: TextureSelected = TextureStart + 6
        END SELECT
    END IF

    IF TextureSelected > UBOUND(Texture) THEN TextureSelected = UBOUND(Texture)
    TextureIN = Texture(TextureSelected).img 'pro vklad do mrizky


    SELECT CASE TextureSelected - TextureStart
        CASE 0: LINE (929, 87)-(1020, 154), _RGB32(255, 255, 0), B
        CASE 1: LINE (929, 157)-(1020, 225), _RGB32(255, 255, 0), B
        CASE 2: LINE (929, 229)-(1020, 295), _RGB32(255, 255, 0), B
        CASE 3: LINE (929, 299)-(1020, 366), _RGB32(255, 255, 0), B
        CASE 4: LINE (929, 368)-(1020, 435), _RGB32(255, 255, 0), B
        CASE 5: LINE (929, 440)-(1020, 506), _RGB32(255, 255, 0), B
        CASE 6: LINE (929, 509)-(1020, 578), _RGB32(255, 255, 0), B
    END SELECT


    IF GridVisibility THEN
        FOR mY = 18 TO 618 STEP 25
            FOR mx = 23 TO 873 STEP 25
                LINE (mx, mY)-(mx + 49, mY + 49), GridRGB32Color~&, B
        NEXT mx, mY
    END IF


    IF _MOUSEX > 23 AND _MOUSEX < 920 AND _MOUSEY > 18 AND _MOUSEY < 666 THEN
        SHARED memoryzex, memoryzey

        kbd_agent$ = INKEY$

        '...............   3.5 upgrade ................................
        IF _MOUSEBUTTON(2) THEN
            'nejrve vyber oblast, jako pri kliku levym tlacitkem, pak spust right clickmenu
            RightXstart = _MOUSEX
            RightYstart = _MOUSEY
            DO UNTIL _MOUSEBUTTON(2) = 0
                WHILE _MOUSEINPUT: WEND
                PCOPY 10, _DISPLAY
                IF _MOUSEX > 23 AND _MOUSEX < 920 AND _MOUSEY > 18 AND _MOUSEY < 666 THEN
                    LINE (RightXstart, RightYstart)-(_MOUSEX, _MOUSEY), , B
                END IF
                _DISPLAY
            LOOP
            RightXend = _MOUSEX
            RightYend = _MOUSEY

            'prepocet na souradnice pole:

            RxS = _CEIL((RightXstart - 23) / 25) + StartDrawX
            RyS = _CEIL((RightYstart - 18) / 25) + StartDrawy
            RxE = _CEIL((RightXend - 23) / 25) + StartDrawX
            RyE = _CEIL((RightYend - 18) / 25) + StartDrawy

            e = 0
            REDIM RightClick(1 TO 9) AS STRING
            RightClick(1) = "Delete all in this area" '                    OK
            RightClick(2) = "Break current texture into this objects" '    OK
            RightClick(3) = "Copy all in this area" '                      OK
            RightClick(4) = "Insert copyed contens to this area" '         OK
            RightClick(5) = "Set WALL/CEILING/FLOOR height in this area"
            RightClick(6) = "Flip textures in this area"
            RightClick(7) = "Delete Objects in this area"
            RightClick(8) = "Delete background sound in this area"
            RightClick(9) = "Add background sound to this area"

            DO UNTIL e
                e = RightClickMenu(RightClick(), _MOUSEX, _MOUSEY)
            LOOP


            SELECT CASE e
                CASE -1: Reset_Mouse: EXIT SUB ' aborted
                CASE 1: Delete_All_in_area RxS, RyS, RxE, RyE
                CASE 2: Break_Texture_in_area RxS, RyS, RxE, RyE
                CASE 3: Copy_contens_in_area RxS, RyS, RxE, RyE
                CASE 4: Insert_contens_in_area RxS, RyS
                CASE 5: Set_Height_in_area RxS, RyS, RxE, RyE
                CASE 6: Flip_textures_in_area RxS, RyS, RxE, RyE
                CASE 7: Delete_Objects_in_area RxS, RyS, RxE, RyE
                CASE 8: Delete_Sounds_in_area RxS, RyS, RxE, RyE
                CASE 9: Add_Sound_to_area RxS, RyS, RxE, RyE

            END SELECT
        END IF
        '-------------------------------------------------------------------

        IF LEN(kbd_agent$) THEN

            ' _DELAY .1
            IF memoryzex = 0 THEN memoryzex = _MOUSEX: memoryzey = _MOUSEY

            'doplnena podpora z klavesnice pokud je mys v tomto okne
            SELECT CASE kbd_agent$
                CASE CHR$(0) + CHR$(80) 'dolu
                    IF EndDrawy < UBOUND(Grid_img, 2) THEN StartDrawy = StartDrawy + 1: EndDrawy = StartDrawy + 35

                CASE CHR$(0) + CHR$(72) 'nahoru
                    StartDrawy = StartDrawy - 1: EndDrawy = StartDrawy + 35

                CASE CHR$(0) + CHR$(75) ' lft
                    StartDrawX = StartDrawX - 1: EndDrawX = StartDrawX + 36

                CASE CHR$(0) + CHR$(77) 'rght
                    IF EndDrawX < UBOUND(Grid_img, 1) THEN StartDrawX = StartDrawX + 1: EndDrawX = StartDrawX + 36
            END SELECT
            _KEYCLEAR




            IF _MOUSEX > memoryzex AND EndDrawX < UBOUND(Grid_img, 1) THEN StartDrawX = StartDrawX + 1: EndDrawX = StartDrawX + 36 'je to 25 sloupcu?
            IF _MOUSEX < memoryzex THEN StartDrawX = StartDrawX - 1: EndDrawX = StartDrawX + 36 'je to 25 sloupcu?

            IF _MOUSEY > memoryzey AND EndDrawy < UBOUND(Grid_img, 2) THEN StartDrawy = StartDrawy + 1: EndDrawy = StartDrawy + 35 'je to 15 radku? 'dn
            IF _MOUSEY < memoryzey THEN StartDrawy = StartDrawy - 1: EndDrawy = StartDrawy + 35 'je to 15 radku?                                       'up




        ELSE
            memoryzex = 0: memoryzey = 0
        END IF
    END IF

    IF StartDrawX > UBOUND(Grid_img, 1) THEN StartDrawX = UBOUND(Grid_img, 1)
    IF StartDrawX < LBOUND(Grid_img, 1) THEN StartDrawX = LBOUND(Grid_img, 1)
    IF StartDrawy > UBOUND(Grid_img, 2) THEN StartDrawy = UBOUND(Grid_img, 2)
    IF StartDrawy < LBOUND(Grid_img, 2) THEN StartDrawy = LBOUND(Grid_img, 2)

    EndDrawX = StartDrawX + 36
    EndDrawy = StartDrawy + 35

    IF EndDrawX > UBOUND(Grid_img, 1) THEN EndDrawX = UBOUND(Grid_img, 1)
    IF EndDrawy > UBOUND(Grid_img, 2) THEN EndDrawy = UBOUND(Grid_img, 2)



    '  END IF

    Px = _CEIL((_MOUSEX - 23) / 25) + StartDrawX
    Py = _CEIL((_MOUSEY - 18) / 25) + StartDrawy

    IF Px > UBOUND(Grid_typ, 1) THEN Px = UBOUND(Grid_typ, 1)
    IF Py > UBOUND(Grid_typ, 2) THEN Py = UBOUND(Grid_typ, 2)

    _PRINTMODE _FILLBACKGROUND
    _FONT 8

    SELECT CASE Grid_typ(Px, Py)
        'upgrade - hodnoty podle typu na miste: 1 = zed, 2 = floor, 3 = ceiling.   12 = zed + floor, 13 = zed + ceiling. 23 = floor + ceiling.  123 = zed, floor, ceiling
        CASE 1: t$ = " Zed, "
        CASE 2: t$ = " Zem, "
        CASE 3: t$ = " Strop, "
        CASE 4: t$ = " Nerotovany objekt, "
        CASE 5: t$ = " Objekt rotovany o " + STR$(rot) + "stupnu, "
        CASE 12: t$ = "Zed a strop, "
        CASE 13: t$ = "Zed a zem, "
        CASE 23: t$ = "Strop a zem, "
        CASE 123: t$ = "Zed, strop a zem, "
    END SELECT

    LS = LAYERS_SETUP

    IF LAYERS_SETUP = 2 THEN
        IF KEYBOARDAGENT THEN LS = 0 ELSE LS = 1
    END IF


    FOR dx = StartDrawX TO EndDrawX
        FOR dy = StartDrawy TO EndDrawy

            Kx = (dx * 25) + 23 - 25 - (25 * StartDrawX)
            Ky = (dy * 25) + 18 - 25 - (25 * StartDrawy)

            IF Kx < 922 AND Ky < 666 THEN

                IF Button(12).active THEN

                    Height_From = Img_Height_From
                    Height_To = Img_Height_To
                    Textures_po = Img_Textures_per_Object
                    Texture_Effect = Img_Texture_Effect

                    SELECT CASE LS
                        CASE 0
                            IF Grid_img(dx, dy) AND Grid_Floor(dx, dy) OR Grid_img(dx, dy) AND Grid_Ceil(dx, dy) OR Grid_img(dx, dy) AND Grid_Ceil(dx, dy) OR Grid_Floor(dx, dy) AND Grid_Ceil(dx, dy) THEN alfa = 0 ELSE alfa = 50

                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Floor(dx, dy)
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 255, 0, alfa), BF
                            END IF

                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Ceil(dx, dy)
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 0, 255, alfa), BF
                            END IF

                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_img(dx, dy) 'vlozi zdi
                            END IF

                        CASE 1
                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_img(dx, dy) 'vlozi zdi
                            END IF

                        CASE 3
                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 255, 0, 128), BF
                            END IF

                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 0, 255, 128), BF
                            END IF

                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGB32(255, 0, 0), BF
                            END IF

                        CASE 4
                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGB32(255, 0, 0), BF
                            END IF
                    END SELECT
                END IF
                '-----

                IF Button(11).active THEN ' rezim malovani stropu

                    Height_From = Ceil_Height_From
                    Height_To = Ceil_Height_To
                    Textures_po = Ceil_Textures_per_Object
                    Texture_Effect = Ceil_Texture_Effect


                    SELECT CASE LS
                        CASE 0

                            IF Grid_img(dx, dy) AND Grid_Floor(dx, dy) OR Grid_img(dx, dy) AND Grid_Ceil(dx, dy) OR Grid_img(dx, dy) AND Grid_Ceil(dx, dy) OR Grid_Floor(dx, dy) AND Grid_Ceil(dx, dy) THEN alfa = 0 ELSE alfa = 20
                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_img(dx, dy) 'vlozi zdi
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(255, 0, 0, alfa), BF
                            END IF

                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Floor(dx, dy) 'vlozeni stropu
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 0, 255, alfa), BF
                            END IF

                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Ceil(dx, dy) 'vlozeni podlah
                            END IF
                        CASE 1
                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Ceil(dx, dy) 'vlozeni podlah
                            END IF
                        CASE 3
                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 255, 0, 128), BF
                            END IF

                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 0, 255, 128), BF
                            END IF

                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGB32(255, 0, 0), BF
                            END IF
                        CASE 4
                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGB(0, 0, 255), BF
                            END IF
                    END SELECT
                END IF


                IF Button(10).active THEN ' podlaha   bottom

                    Height_From = Floor_Height_From
                    Height_To = Floor_Height_To
                    Textures_po = Floor_Textures_per_Object
                    Texture_Effect = Floor_Texture_Effect


                    SELECT CASE LS
                        CASE 0
                            IF Grid_img(dx, dy) AND Grid_Floor(dx, dy) OR Grid_img(dx, dy) AND Grid_Ceil(dx, dy) OR Grid_img(dx, dy) AND Grid_Ceil(dx, dy) OR Grid_Floor(dx, dy) AND Grid_Ceil(dx, dy) THEN alfa = 0 ELSE alfa = 50


                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_img(dx, dy) 'vlozi zdi
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(255, 0, 0, alfa), BF
                            END IF


                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Ceil(dx, dy) 'vlozeni podlah
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 255, 0, alfa), BF
                            END IF

                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Floor(dx, dy) 'vlozeni stropu
                            END IF


                        CASE 1
                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                _PUTIMAGE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), Grid_Floor(dx, dy) 'vlozeni stropu
                            END IF

                        CASE 3
                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 255, 0, 128), BF
                            END IF

                            IF Grid_Ceil(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGBA32(0, 0, 255, 128), BF
                            END IF

                            IF Grid_img(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGB32(255, 0, 0), BF
                            END IF
                        CASE 4
                            IF Grid_Floor(dx, dy) < -1 AND Kx > -2 AND Ky > -7 THEN
                                LINE (Kx + 1, Ky + 1)-(Kx + 23, Ky + 23), _RGB(0, 255, 0), BF
                            END IF
                    END SELECT
                END IF
            END IF
    NEXT dy, dx


    IF _MOUSEX > 23 AND _MOUSEX < 920 AND _MOUSEY > 18 AND _MOUSEY < 666 THEN
        SHARED OldMouseX, OldMouseY, MemorizeTimer


        REDIM Info_Array(1 TO 12) AS STRING
        Info_Array(1) = "texture nr:" + IS_Record(Px, Py) + " object type: " + t$

        IF Texture_Effect > 0 THEN TextureEfect$ = STR$(Texture_Effect) ELSE TextureEfect$ = "NONE"


        IMG_H_F$ = STR$(IP_Img(Px, Py).Height_From)
        IMG_H_T$ = STR$(IP_Img(Px, Py).Height_To)
        IF IP_Img(Px, Py).Height_From = IP_Img(Px, Py).Height_To THEN IMG_H_F$ = "UNUSED": IMG_H_T$ = "UNUSED"

        CEIL_H_F$ = STR$(IP_Ceil(Px, Py).Height_From)
        CEIL_H_T$ = STR$(IP_Ceil(Px, Py).Height_To)

        FLOOR_H_F$ = STR$(IP_Floor(Px, Py).Height_From)
        FLOOR_H_T$ = STR$(IP_Floor(Px, Py).Height_To)



        Info_Array(2) = "WALL height from:" + IMG_H_F$ + " height to:" + IMG_H_T$
        Info_Array(3) = "CEILING height from:" + CEIL_H_F$ + " height to:" + CEIL_H_T$
        Info_Array(4) = "FLOOR height from:" + FLOOR_H_F$ + " height to:" + FLOOR_H_T$

        Info_Array(5) = "total place 1 texture over" + STR$(Textures_po) + " objects"
        Info_Array(6) = "applied effect to texture: " + TextureEfect$
        Info_Array(7) = "----------------------------------"
        Info_Array(8) = "actual settings:"
        Info_Array(9) = "----------------------------------"
        Info_Array(10) = "WALL height from: " + STR$(Img_Height_From) + " to:" + STR$(Img_Height_To)
        Info_Array(11) = "FLOOR height from: " + STR$(Floor_Height_From) + " to:" + STR$(Floor_Height_To)
        Info_Array(12) = "CEILING height from: " + STR$(Ceil_Height_From) + " to:" + STR$(Ceil_Height_To)


        IF OldMouseX <> _MOUSEX OR OldMouseY <> _MOUSEY THEN OldMouseX = _MOUSEX: OldMouseY = _MOUSEY

        IF _MOUSEINPUT THEN MemorizeTimer = TIMER
        IF TIMER > MemorizeTimer + GridCommentsTime AND GridShowComments THEN
            COLOR _RGB32(0, 0, 0), _RGB32(255, 255, 0)
            IF LEN(t$) > 0 THEN Comment_Window Info_Array$(), _MOUSEX, _MOUSEY
            COLOR _RGB32(255, 255, 255), _RGB32(0, 0, 0)
        END IF

        IF _MOUSEBUTTON(1) AND TextureIN THEN
            SELECT CASE DRAW_MOUSE_SETUP
                CASE 0
                    IF Button(12).active THEN atyp = 1 'wall
                    IF Button(11).active THEN atyp = 2 'ceiling
                    IF Button(10).active THEN atyp = 3 'floor

                    SELECT CASE atyp
                        CASE 1:
                            Grid_img(Px, Py) = TextureIN: Grid_Ceil(Px, Py) = 0: Grid_Floor(Px, Py) = 0
                            IP_Img(Px, Py).Height_From = Img_Height_From
                            IP_Img(Px, Py).Height_To = Img_Height_To
                            IP_Img(Px, Py).TexturesPerObject = Img_Textures_per_Object
                            IP_Img(Px, Py).TextureEffect = Img_Texture_Effect

                        CASE 2:
                            Grid_Ceil(Px, Py) = TextureIN: Grid_img(Px, Py) = 0
                            IP_Ceil(Px, Py).Height_From = Ceil_Height_From
                            IP_Ceil(Px, Py).Height_To = Ceil_Height_To
                            IP_Ceil(Px, Py).TexturesPerObject = Ceil_Textures_per_Object
                            IP_Ceil(Px, Py).TextureEffect = Ceil_Texture_Effect

                        CASE 3:
                            Grid_Floor(Px, Py) = TextureIN: Grid_img(Px, Py) = 0
                            IP_Floor(Px, Py).Height_From = Floor_Height_From
                            IP_Floor(Px, Py).Height_To = Floor_Height_To
                            IP_Floor(Px, Py).TexturesPerObject = Floor_Textures_per_Object
                            IP_Floor(Px, Py).TextureEffect = Floor_Texture_Effect

                    END SELECT

                    Grid_typ(Px, Py) = WHOIS(Px, Py) 'atyp

                CASE 1

                    startX = _MOUSEX
                    startY = _MOUSEY
                    startpX = Px
                    startpY = Py
                    writeit = 0
                    DO UNTIL _MOUSEBUTTON(1) = 0
                        writeit = 1
                        WHILE _MOUSEINPUT: WEND
                        IF _MOUSEX > 23 AND _MOUSEX < 920 AND _MOUSEY > 18 AND _MOUSEY < 666 THEN
                            EndPX = _CEIL((_MOUSEX - 23) / 25) + StartDrawX
                            EndPY = _CEIL((_MOUSEY - 18) / 25) + StartDrawy

                            PCOPY 10, _DISPLAY
                            IF TextureIN < -1 THEN LINE (startX, startY)-(_MOUSEX, _MOUSEY), _RGB32(255, 255, 255), B
                        END IF
                        _DISPLAY
                    LOOP

                    IF Button(12).active THEN atyp = 1 'wall
                    IF Button(11).active THEN atyp = 2 'ceiling
                    IF Button(10).active THEN atyp = 3 'floor

                    IF startpX > EndPX THEN SWAP startpX, EndPX
                    IF startpY > EndPY THEN SWAP startpY, EndPY


                    IF writeit THEN
                        FOR ipy = startpY TO EndPY
                            FOR ipx = startpX TO EndPX

                                SELECT CASE atyp
                                    CASE 1:
                                        Grid_img(ipx, ipy) = TextureIN: Grid_Ceil(ipx, ipy) = 0: Grid_Floor(ipx, ipy) = 0
                                        IP_Img(ipx, ipy).Height_From = Img_Height_From
                                        IP_Img(ipx, ipy).Height_To = Img_Height_To
                                        IP_Img(ipx, ipy).TexturesPerObject = Img_Textures_per_Object
                                        IP_Img(ipx, ipy).TextureEffect = Img_Texture_Effect

                                    CASE 2:
                                        Grid_Ceil(ipx, ipy) = TextureIN: Grid_img(ipx, ipy) = 0
                                        IP_Ceil(ipx, ipy).Height_From = Ceil_Height_From
                                        IP_Ceil(ipx, ipy).Height_To = Ceil_Height_To
                                        IP_Ceil(ipx, ipy).TexturesPerObject = Ceil_Textures_per_Object
                                        IP_Ceil(ipx, ipy).TextureEffect = Ceil_Texture_Effect

                                    CASE 3:
                                        Grid_Floor(ipx, ipy) = TextureIN: Grid_img(ipx, ipy) = 0
                                        IP_Floor(ipx, ipy).Height_From = Floor_Height_From
                                        IP_Floor(ipx, ipy).Height_To = Floor_Height_To
                                        IP_Floor(ipx, ipy).TexturesPerObject = Floor_Textures_per_Object
                                        IP_Floor(ipx, ipy).TextureEffect = Floor_Texture_Effect
                                END SELECT

                                Grid_typ(ipx, ipy) = WHOIS(ipx, ipy) 'atyp
                        NEXT ipx, ipy
                    END IF
            END SELECT
        END IF

        IF _MOUSEBUTTON(3) THEN
            IF Button(12).active THEN Grid_img(Px, Py) = 0: Grid_typ(Px, Py) = WHOIS(Px, Py)
            IF Button(11).active THEN Grid_Ceil(Px, Py) = 0: Grid_typ(Px, Py) = WHOIS(Px, Py)
            IF Button(10).active THEN Grid_Floor(Px, Py) = 0: Grid_typ(Px, Py) = WHOIS(Px, Py)
        END IF
    END IF

    IF _MOUSEX < 23 OR _MOUSEX > 920 OR _MOUSEY < 18 OR _MOUSEY > 666 THEN
    END IF
END SUB


SUB Flip_textures_in_area (rxs AS INTEGER, rys AS INTEGER, rxe AS INTEGER, rye AS INTEGER) 'zatim funkcni jen pro styly 1,2,3

    PCOPY 0, 10

    REDIM styles(1 TO 3) AS STRING
    styles(1) = "Flip in X axis"
    styles(2) = "Flip in Y axis"
    styles(3) = "Flip on 180 degrees"

    Reset_Mouse
    DO UNTIL style > 0
        style = RightClickMenu(styles(), _MOUSEX, _MOUSEY)
    LOOP
    COLOR _RGB32(255), _RGB32(70)


    REDIM SWP(rxs TO rxe, rys TO rye) AS LONG

    IF Button(12).active THEN Atyp = 1 'wall
    IF Button(11).active THEN Atyp = 2 'ceiling
    IF Button(10).active THEN Atyp = 3 'floor

    FOR y = rys TO rye
        FOR x = rxs TO rxe
            SELECT CASE Atyp
                CASE 3: image = Grid_Floor(x, y)
                CASE 2: image = Grid_Ceil(x, y)
                CASE 1: image = Grid_img(x, y)
            END SELECT


            IF image < -1 AND style > 0 THEN
                W = _WIDTH(image) - 1: H = _HEIGHT(image) - 1
                IF style > 3 THEN SWAP W, H

                ROTO90 = _NEWIMAGE(W + 1, H + 1, 32)
                SELECT CASE style
                    CASE 0:
                        _PUTIMAGE , image, ROTO90
                    CASE 1:
                        _PUTIMAGE , image, ROTO90, (W, 0)-(0, H)
                    CASE 2:
                        _PUTIMAGE , image, ROTO90, (0, H)-(W, 0)
                    CASE 3:
                        _PUTIMAGE , image, ROTO90, (W, H)-(0, 0)

                    CASE 4:
                        imag = MEM_ROTO_90(image)
                        _PUTIMAGE , imag, ROTO90
                        _FREEIMAGE imag

                    CASE 5:
                        imag = MEM_ROTO_90(image)
                        _PUTIMAGE , imag, ROTO90, (0, H)-(W, 0)
                        _FREEIMAGE imag

                    CASE 6:
                        imag = MEM_ROTO_90(image)
                        _PUTIMAGE , imag, ROTO90, (W, 0)-(0, H)
                        _FREEIMAGE imag


                    CASE 7:
                        imag = MEM_ROTO_90(image)
                        _PUTIMAGE , imag, ROTO90, (W, H)-(0, 0)
                        _FREEIMAGE imag
                END SELECT

                SWP(x, y) = _COPYIMAGE(ROTO90, 32) ' ELSE SWP(y, x) = _COPYIMAGE(ROTO90, 32)
                _FREEIMAGE ROTO90
            END IF
        NEXT x
    NEXT y


    SELECT CASE style
        CASE 1
            SELECT CASE Atyp
                CASE 1
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe
                            Grid_img(cx, y) = SWP(x, y)
                            Grid_typ(cx, y) = WHOIS(cx, y)
                            cx = cx - 1
                        NEXT x
                    NEXT y
                    ERASE SWP

                CASE 2
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe
                            Grid_Ceil(cx, y) = SWP(x, y)
                            Grid_typ(cx, y) = WHOIS(cx, y)
                            cx = cx - 1
                        NEXT x
                    NEXT y
                    ERASE SWP

                CASE 3
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe
                            Grid_Floor(cx, y) = SWP(x, y)
                            Grid_typ(cx, y) = WHOIS(cx, y)
                            cx = cx - 1
                        NEXT x
                    NEXT y
                    ERASE SWP
            END SELECT


        CASE 2
            SELECT CASE Atyp
                CASE 1
                    cy = rye
                    FOR y = rys TO rye
                        FOR x = rxs TO rxe
                            Grid_img(x, cy) = SWP(x, y)
                            Grid_typ(x, cy) = WHOIS(x, cy)
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP

                CASE 2
                    cy = rye
                    FOR y = rys TO rye
                        FOR x = rxs TO rxe
                            Grid_Ceil(x, cy) = SWP(x, y)
                            Grid_typ(x, cy) = WHOIS(x, cy)
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP

                CASE 3
                    cy = rye
                    FOR y = rys TO rye
                        FOR x = rxs TO rxe
                            Grid_Floor(x, cy) = SWP(x, y)
                            Grid_typ(x, cy) = WHOIS(x, cy)
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP
            END SELECT


        CASE 3
            SELECT CASE Atyp
                CASE 1
                    cy = rye
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe

                            Grid_img(cx, cy) = SWP(x, y)
                            Grid_typ(cx, cy) = WHOIS(cx, cy)
                            cx = cx - 1
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP

                CASE 2

                    cy = rye
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe

                            Grid_Ceil(cx, cy) = SWP(x, y)
                            Grid_typ(cx, cy) = WHOIS(cx, cy)
                            cx = cx - 1
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP

                CASE 3
                    cy = rye
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe
                            Grid_Floor(cx, cy) = SWP(x, y)
                            Grid_typ(cx, cy) = WHOIS(cx, cy)
                            cx = cx - 1
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP
            END SELECT


        CASE 4 'rotace o 90 stupnu - jen opis

            SELECT CASE Atyp
                CASE 1
                    cy = rye
                    REDIM SWP2(rxs TO rxe, rys TO rye) AS LONG
                    FOR y = rys TO rye
                        cx = rxe
                        FOR x = rxs TO rxe
                            SWP2(cx, y) = SWP(x, y)
                            cx = cx - 1
                        NEXT x
                        cy = cy - 1
                    NEXT y
                    ERASE SWP

                    wx = rxs
                    wy = rys

                    FOR y = rys TO rye
                        FOR x = rxs TO rxe
                            Grid_img(wx, wy) = SWP2(x, y)

                            'tento blocek mi trval 2 dny...
                            IF rxe - rxs <> rye - rys THEN
                                wy = wy + 1: IF wy > rxe THEN wy = rxs: wx = wx + 1
                            ELSE
                                wy = wy + 1: IF wy > rye THEN wy = rys: wx = wx + 1
                            END IF
                            '///////////////////////////////

                            ' IF wx > rye THEN wx = rys
                        NEXT x
                    NEXT y
                    ERASE SWP2

                CASE 2
                    FOR y = rys TO rye
                        FOR x = rxs TO rxe
                            Grid_Ceil(x, y) = SWP(x, y)
                            Grid_typ(x, y) = WHOIS(x, y)
                        NEXT x
                    NEXT y
                    ERASE SWP

                CASE 3
                    FOR y = rys TO rye
                        FOR x = rxs TO rxe
                            Grid_Floor(x, y) = SWP(x, y)
                            Grid_typ(x, y) = WHOIS(x, y)
                        NEXT x
                    NEXT y
                    ERASE SWP
            END SELECT
    END SELECT
END SUB

FUNCTION MEM_ROTO_90 (img AS LONG)
    DIM W AS LONG, H AS LONG
    W = _WIDTH(img)
    H = _HEIGHT(img)
    tmp& = _NEWIMAGE(H, W, 32)
    DIM m AS _MEM, m2 AS _MEM, m3 AS _MEM, k AS _UNSIGNED LONG, k3 AS _UNSIGNED LONG, X AS LONG, Y AS LONG, R AS _UNSIGNED _BYTE, G AS _UNSIGNED _BYTE, B AS _UNSIGNED _BYTE, A AS _UNSIGNED _BYTE, nR AS _UNSIGNED _BYTE, nG AS _UNSIGNED _BYTE, nB AS _UNSIGNED _BYTE
    m = _MEMIMAGE(img)
    m2 = _MEMIMAGE(tmp&)
    '  m3 = _MEMIMAGE(0)
    FOR Y = 0 TO H - 1
        FOR X = W - 1 TO 1 STEP -1
            _MEMGET m, m.OFFSET + (4 * (W - X + _WIDTH(img) * Y)), k
            '         _MEMGET m3, m3.OFFSET + (4 * (W - X + _WIDTH(img) * Y)), k3

            R = _RED32(k)
            G = _GREEN32(k)
            B = _BLUE32(k)
            A = _ALPHA32(k)
            nA = A / 2.55

            R3 = _RED32(k3)
            G3 = _GREEN32(k3)
            B3 = _BLUE32(k3)

            nR = NColor(R3, R, nA)
            nG = NColor(G3, G, nA)
            nB = NColor(B3, B, nA)

            k = _RGBA32(nR, nG, nB, 255)

            _MEMPUT m2, m2.OFFSET + (4 * (Y + _WIDTH(tmp&) * X)), k
    NEXT X, Y
    _MEMFREE m
    _MEMFREE m2
    '  _MEMFREE m3
    MEM_ROTO_90 = tmp&
END FUNCTION

FUNCTION NColor~& (Background AS _UNSIGNED _BYTE, Foreground AS _UNSIGNED _BYTE, Alpha AS SINGLE)
    NColor = Background - ((Background - Foreground) / 100) * Alpha
END FUNCTION


SUB Delete_All_in_area (sX AS INTEGER, sY AS INTEGER, eX AS INTEGER, eY AS INTEGER) 'smaze uplne vsechno v dane oblasti
    IF eY < sY THEN SWAP sY, eY
    IF eX < sX THEN SWAP sX, eX

    FOR Ky = sY TO eY
        FOR Kx = sX TO eX
            IP_Img(Kx, Ky).Height_From = 0
            IP_Img(Kx, Ky).Height_To = 0
            IP_Floor(Kx, Ky).Height_From = 0
            IP_Floor(Kx, Ky).Height_To = 0
            IP_Ceil(Kx, Ky).Height_From = 0
            IP_Ceil(Kx, Ky).Height_To = 0

            Grid_img(Kx, Ky) = 0
            Grid_Ceil(Kx, Ky) = 0
            Grid_Floor(Kx, Ky) = 0
            Grid_typ(Kx, Ky) = 0
            Grid_Obj(Kx, Ky) = 0
    NEXT Kx, Ky
END SUB


SUB Set_Height_in_area (rxs AS INTEGER, rys AS INTEGER, rxe AS INTEGER, rye AS INTEGER) 'zmeni zaznam v polich IP, bez ohledu na zvoleny rezim, proste podle tveho nastaveni v tomto SUB

    PCOPY 10, _DISPLAY
    COLOR _RGB32(255)
    LINE (198, 200)-(522, 568), _RGB32(70, 70, 70), BF
    LINE (198, 200)-(522, 568), _RGB32(155, 155, 155), B
    LINE (200, 202)-(520, 566), _RGB32(155, 155, 155), B
    _FONT 8
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (290, 205), "BLOCK Height Setup"
    LINE (200, 215)-(520, 215), _RGB32(155, 155, 155)
    DvojSipka = _LOADIMAGE("ico/dvojsipka.bmp", 32)
    _CLEARCOLOR _RGB32(255, 255, 255), DvojSipka
    PCOPY _DISPLAY, 9
    OldRoto = rotos

    BLOCK_Img_Textures_per_Object = Img_Textures_per_Object
    BLOCK_Img_Height_From = Img_Height_From
    BLOCK_Img_Height_To = Img_Height_To
    BLOCK_Floor_Height_From = Floor_Height_From
    BLOCK_Floor_Height_To = Floor_Height_To
    BLOCK_Ceil_Height_From = Ceil_Height_From
    BLOCK_Ceil_Height_To = Ceil_Height_To

    oke = LOADICO("ico/oke.ico", 1)
    bck = LOADICO("ico/ko.ico", 1)
    _CLEARCOLOR 0, oke
    _CLEARCOLOR 0, bck

    DO
        PCOPY 9, _DISPLAY
        WHILE _MOUSEINPUT: WEND
        '-------------------------------------------------------------------------------------------------
        'nastavovaci veticka pro nastaveni vysky zdi od do
        _PRINTSTRING (230, 263), "Set WALL height from: " + LTRIM$(STR$(BLOCK_Img_Height_From))
        _PRINTSTRING (230, 293), "Set WALL height to: " + LTRIM$(STR$(BLOCK_Img_Height_To))
        _PUTIMAGE (450, 250), DvojSipka: _PUTIMAGE (450, 280), DvojSipka


        'nastavovaci veticka pro nastaveni vysky zeme od do
        _PRINTSTRING (230, 323), "Set FLOOR height from: " + LTRIM$(STR$(BLOCK_Floor_Height_From))
        _PRINTSTRING (230, 353), "Set FLOOR height to: " + LTRIM$(STR$(BLOCK_Floor_Height_To))
        _PUTIMAGE (450, 310), DvojSipka: _PUTIMAGE (450, 340), DvojSipka


        'nastavovaci veticka pro nastaveni vysky stropu od do
        _PRINTSTRING (230, 383), "Set CEILING height from: " + LTRIM$(STR$(BLOCK_Ceil_Height_From))
        _PRINTSTRING (230, 413), "Set CEILING height to: " + LTRIM$(STR$(BLOCK_Ceil_Height_To))
        _PUTIMAGE (450, 370), DvojSipka: _PUTIMAGE (450, 400), DvojSipka
        COLOR _RGB32(255, 0, 0)
        _PRINTSTRING (230, 450), "WALL coordinates only are used"
        _PRINTSTRING (250, 460), "for collision detections!"
        COLOR _RGB32(255)

        BLOCK_Img_Textures_per_Object = BLOCK_Img_Textures_per_Object + DoubleArrow(450, 220)
        BLOCK_Img_Height_From = BLOCK_Img_Height_From + DoubleArrow(450, 250)
        BLOCK_Img_Height_To = BLOCK_Img_Height_To + DoubleArrow(450, 280)
        BLOCK_Floor_Height_From = BLOCK_Floor_Height_From + DoubleArrow(450, 310)
        BLOCK_Floor_Height_To = BLOCK_Floor_Height_To + DoubleArrow(450, 340)
        BLOCK_Ceil_Height_From = BLOCK_Ceil_Height_From + DoubleArrow(450, 370)
        BLOCK_Ceil_Height_To = BLOCK_Ceil_Height_To + DoubleArrow(450, 400)

        LINE (230, 500)-(315, 530), _RGB32(255, 255, 255), B
        _PUTIMAGE (230, 500), oke
        _PRINTSTRING (263, 513), "Done"
        IF ONPOS(_MOUSEX, _MOUSEY, 230, 500, 315, 530) THEN LINE (230, 500)-(315, 530), _RGBA32(170, 170, 170, 60), BF: IF _MOUSEBUTTON(1) THEN ok = 1 'OK


        LINE (400, 500)-(485, 530), _RGB32(255, 255, 255), B
        _PUTIMAGE (400, 500), bck
        _PRINTSTRING (433, 513), "Back"
        IF ONPOS(_MOUSEX, _MOUSEY, 400, 500, 485, 530) THEN LINE (400, 500)-(485, 530), _RGBA32(170, 170, 170, 60), BF: IF _MOUSEBUTTON(1) THEN EXIT SUB
        _DISPLAY
    LOOP UNTIL ok

    FOR y = rys TO rye
        FOR x = rxs TO rxe
            IP_Ceil(x, y).Height_From = BLOCK_Ceil_Height_From
            IP_Ceil(x, y).Height_To = BLOCK_Ceil_Height_To
            IP_Floor(x, y).Height_From = BLOCK_Floor_Height_From
            IP_Floor(x, y).Height_To = BLOCK_Floor_Height_To
            IP_Img(x, y).Height_From = BLOCK_Img_Height_From
            IP_Img(x, y).Height_To = BLOCK_Img_Height_To
    NEXT x, y
    _FREEIMAGE oke
    _FREEIMAGE bck
END SUB

SUB Break_Texture_in_area (Sx AS INTEGER, Sy AS INTEGER, Ex AS INTEGER, Ey AS INTEGER) 'vezme aktualni texturu, rozlozi ji na patricny pocet dilu, ulozi jako PNG a ty vlozi jako novou texturu a umisti do pole
    '                          X - start       Y - start       X - end        Y - end
    _AUTODISPLAY
    IF Ey < Sy THEN SWAP Ey, Sy
    IF Ex < Sx THEN SWAP Ex, Sx

    '    PRINT Sx, Sy, Ex, Ey
    '    SLEEP
    IF TextureIN > -2 THEN EXIT SUB
    'as LINE:                  (X start, Y start)      -         (X end, Y end)

    IF Ex = Sx THEN divideX = 1 ELSE divideX = (Ex - Sx) + 1
    IF Ey = Sy THEN divideY = 1 ELSE divideY = (Ey - Sy) + 1


    NewWidth = _WIDTH(TextureIN)
    NewHeight = _HEIGHT(TextureIN)

    DO UNTIL NewWidth MOD divideX = 0
        NewWidth = NewWidth + 1
    LOOP

    DO UNTIL NewHeight MOD divideY = 0
        NewHeight = NewHeight + 1
    LOOP

    Stexture = _NEWIMAGE(NewWidth, NewHeight, 32)
    _PUTIMAGE , TextureIN, Stexture

    width = NewWidth \ divideX
    height = NewHeight \ divideY

    DIM u AS LONG, StartTexture AS LONG
    u = UBOUND(Texture) + 1
    oldu = u
    '    PRINT width, height: SLEEP


    FOR y = 1 TO NewHeight - 1 STEP height
        FOR x = 1 TO NewWidth - 1 STEP width
            newTexture& = _NEWIMAGE(width, height, 32)
            _PUTIMAGE (0, 0)-(width - 1, height - 1), Stexture, newTexture&, (x, y)-(x + width - 1, y + height - 1)
            REDIM _PRESERVE Texture(u) AS Texture
            Texture(u).path = GET_NEW_TEXTURE_NAME
            Texture(u).img = newTexture&
            res = SaveImage(Texture(u).path, newTexture&, 0, 0, _WIDTH(newTexture&) - 1, _HEIGHT(newTexture&) - 1)
            u = u + 1
    NEXT x, y

    IF Button(12).active THEN Atyp = 1 'wall
    IF Button(11).active THEN Atyp = 2 'ceiling
    IF Button(10).active THEN Atyp = 3 'floor

    StartTexture = oldu

    x = 0: y = 0

    FOR y = Sy TO Ey
        FOR x = Sx TO Ex

            SELECT CASE Atyp

                CASE 1: Grid_img(x, y) = Texture(StartTexture + c).img
                CASE 2: Grid_Ceil(x, y) = Texture(StartTexture + c).img
                CASE 3: Grid_Floor(x, y) = Texture(StartTexture + c).img
            END SELECT
            Grid_typ(x, y) = WHOIS(x, y)
            StartTexture = StartTexture + 1
    NEXT x, y
    _FREEIMAGE Stexture
    Reset_Mouse
END SUB


FUNCTION IS_Record$ (r1 AS LONG, r2 AS LONG)
    REDIM a AS LONG
    IS_Record$ = ""


    FOR a = LBOUND(Texture) TO UBOUND(Texture)
        IF Button(12).active THEN
            IF Texture(a).img = Grid_img(r1, r2) THEN IS_Record$ = STR$(a)
        END IF
        IF Button(11).active THEN
            IF Texture(a).img = Grid_Ceil(r1, r2) THEN IS_Record$ = STR$(a)
        END IF
        IF Button(10).active THEN
            IF Texture(a).img = Grid_Floor(r1, r2) THEN IS_Record$ = STR$(a)
        END IF
    NEXT a
END FUNCTION


FUNCTION Place_Buttons

    IF DIALOG = 0 THEN ub = UBOUND(Button) - 2: us = LBOUND(Button) + 1 ELSE ub = UBOUND(Button): us = UBOUND(Button) - 1
    IF DIALOG = 2 THEN ub = 0: us = 0
    FOR p = us TO ub
        IF _MOUSEX > Button(p).x AND _MOUSEX < Button(p).x + 52 AND _MOUSEY > Button(p).y AND _MOUSEY < Button(p).y + 33 THEN
            IF _MOUSEBUTTON(1) = 0 THEN
                _PUTIMAGE (Button(p).x, Button(p).y), Button(p).imgA
            ELSE
                _PUTIMAGE (Button(p).x + 1, Button(p).y + 1), Button(p).imgA
                Place_Buttons = p
            END IF
        ELSE
            IF Button(p).active = 0 THEN _PUTIMAGE (Button(p).x, Button(p).y), Button(p).imgB
        END IF

        IF Button(p).active = 1 THEN _PUTIMAGE (Button(p).x, Button(p).y), Button(p).imgA
    NEXT p
END FUNCTION

SUB Create_Buttons
    SHARED font
    path$ = ENVIRON$("SYSTEMROOT") + "\fonts\arial.ttf"
    IF _FILEEXISTS(path$) = 0 THEN path$ = "arial.ttf"
    font = _LOADFONT(path$, 9, "BOLD")
    prd = _DEST
    oldfont = _FONT

    FOR c = LBOUND(Button) TO UBOUND(Button)

        m = INSTR(1, LTRIM$(RTRIM$(Button(c).text)), CHR$(32))
        D = LEN(LTRIM$(RTRIM$(Button(c).text)))
        IF m AND D >= 6 THEN
            text1$ = LEFT$(Button(c).text, m)
            text2$ = RIGHT$(RTRIM$(Button(c).text), D - m)

            x1 = 8 + (40 / LEN(text1$))
            x2 = 8 + (40 / LEN(text2$))
            y1 = 10
            y2 = 20
        ELSE
            text1$ = RTRIM$(Button(c).text)
            x1 = 8 + (40 / LEN(text1$))
            y1 = 15
            x2 = 0: y2 = 0: text2$ = ""
        END IF


        Button(c).imgA = _NEWIMAGE(52, 33, 32)
        _DEST Button(c).imgA
        _FONT font
        LINE (7, 7)-(49, 29), _RGB32(227, 227, 127), B
        LINE (8, 8)-(48, 28), _RGB32(127, 127, 127), BF
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING (x1, y1), text1$
        IF LEN(text2$) THEN _PRINTSTRING (x2, y2), text2$

        Button(c).imgB = _NEWIMAGE(52, 33, 32)
        _DEST Button(c).imgB
        _FONT font
        LINE (7, 7)-(49, 29), _RGB32(137, 137, 137), B
        LINE (8, 8)-(48, 28), _RGB32(107, 107, 107), BF
        _PRINTMODE _KEEPBACKGROUND
        COLOR _RGB32(1, 1, 1)
        _PRINTSTRING (x1, y1), text1$
        IF LEN(text2$) THEN _PRINTSTRING (x2, y2), text2$
        COLOR _RGB32(255, 255, 255)
    NEXT c

    _DEST prd
    _FONT oldfont

END SUB


SUB LoadINI
    file$ = "editor.ini"

    DIM row(22) AS STRING


    IF _FILEEXISTS(file$) THEN
        ff = FREEFILE
        OPEN file$ FOR INPUT AS #ff
        FOR r = 1 TO 22
            IF NOT EOF(ff) THEN
                LINE INPUT #ff, row(r)
            END IF
        NEXT r

        GridXResolution = VAL(_TRIM$(MID$(row(2), 40)))
        GridYResolution = VAL(_TRIM$(MID$(row(3), 40)))
        GridRGB32Color~& = VAL(_TRIM$(MID$(row(4), 40)))
        GridVisibility = VAL(_TRIM$(MID$(row(5), 40)))
        GridShowComments = VAL(_TRIM$(MID$(row(6), 40)))
        GridCommentsTime = VAL(_TRIM$(MID$(row(7), 40)))
        LAYERS_SETUP = VAL(_TRIM$(MID$(row(8), 40)))
        DRAW_MOUSE_SETUP = VAL(_TRIM$(MID$(row(9), 40)))

        'InfoPlus  - Walls

        Img_Height_From = VAL(_TRIM$(MID$(row(10), 40)))
        Img_Height_To = VAL(_TRIM$(MID$(row(11), 40)))
        Img_Textures_per_Object = VAL(_TRIM$(MID$(row(12), 40)))
        Img_Texture_Effect = VAL(_TRIM$(MID$(row(13), 40)))

        'InfoPlus - Ceils

        Ceil_Height_From = VAL(_TRIM$(MID$(row(14), 40)))
        Ceil_Height_To = VAL(_TRIM$(MID$(row(15), 40)))
        Ceil_Textures_per_Object = VAL(_TRIM$(MID$(row(16), 40)))
        Ceil_Texture_Effect = VAL(_TRIM$(MID$(row(17), 40)))

        'InfoPlus - Floors

        Floor_Height_From = VAL(_TRIM$(MID$(row(18), 40)))
        Floor_Height_To = VAL(_TRIM$(MID$(row(19), 40)))
        Floor_Textures_per_Object = VAL(_TRIM$(MID$(row(20), 40)))
        Floor_Texture_Effect = VAL(_TRIM$(MID$(row(21), 40)))

        'Setup - copy style for rightclick / copy  -> righclick / insert  (0 = rewrite objects, walls, floors and ceilings, 1 = rewrite JUST SELECTED)
        INSERT_SETUP = VAL(_TRIM$(MID$(row(22), 40)))


    ELSE 'ini file not exists, so write it using default settings
        DIM klr AS _UNSIGNED LONG
        klr = _RGB32(255, 255, 255)
        klr$ = STR$(klr)

        ff = FREEFILE
        OPEN file$ FOR OUTPUT AS #ff
        PRINT #ff, "Commented INI file: Program use byte positions 41++ to read on every row. Read not first row and read not first 40 characters on rows!"
        PRINT #ff, "SET MAP X RESOLUTION:"; TAB(40); "100"
        PRINT #ff, "SET MAP Y RESOLUTION:"; TAB(40); "100"
        PRINT #ff, "SET MAP COLOR RGB32:"; TAB(40); klr$
        PRINT #ff, "SET MAP VISIBILITY:"; TAB(40); "1"
        PRINT #ff, "SHOW COMMENTS ON MAP:"; TAB(40); "1"
        PRINT #ff, "TIME BEFORE SHOW COMMENTS:"; TAB(40); "2"
        PRINT #ff, "LAYERS SETUP (0 TO 4):"; TAB(40); "0"
        PRINT #ff, "MOUSE DRAW SETTING (0 or 1):"; TAB(40); "0"

        PRINT #ff, "Walls - Height From (-2 default):"; TAB(40); "-2"
        PRINT #ff, "Walls - Height To (2 default):"; TAB(40); "2"
        PRINT #ff, "Walls - Walls to 1 texture (1):"; TAB(40); "1"
        PRINT #ff, "Walls - texture effect (0 def):"; TAB(40); "0"

        PRINT #ff, "Ceiling - Height From (2 default):"; TAB(40); "2"
        PRINT #ff, "Ceiling - Height To (2 default):"; TAB(40); "2"
        PRINT #ff, "Ceiling - Walls to 1 texture (1):"; TAB(40); "1"
        PRINT #ff, "Ceiling - texture effect (0 def):"; TAB(40); "0"

        PRINT #ff, "Floors - Height From (-2 default):"; TAB(40); "-2"
        PRINT #ff, "Floors - Height To (-2 default):"; TAB(40); "-2"
        PRINT #ff, "Floors - Walls to 1 texture (1):"; TAB(40); "1"
        PRINT #ff, "Floors - texture effect (0 def):"; TAB(40); "0"

        PRINT #ff, "Copy/Insert function setup: (0 or 1):"; TAB(40); "1"

        GridXResolution = 100
        GridYResolution = 100
        GridRGB32Color~& = _RGB32(255, 255, 255)
        GridVisibility = 1
        GridShowComments = 1
        GridCommentsTime = 2
        LAYERS_SETUP = 0
        DRAW_MOUSE_SETUP = 0

        Img_Height_From = -2
        Img_Height_To = 2
        Img_Textures_per_Object = 1
        Img_Texture_Effect = 0
        Ceil_Height_From = 2
        Ceil_Height_To = 2
        Ceil_Textures_per_Object = 1
        Ceil_Texture_Effect = 0
        Floor_Height_From = -2
        Floor_Height_To = -2
        Floor_Textures_per_Object = 1
        Floor_Texture_Effect = 0
        INSERT_SETUP = 1
    END IF


END SUB


SUB SetGrid

    PCOPY _DISPLAY, 2

    'nacteni soucasne barvy mrizky
    R = _RED32(GridRGB32Color~&)
    G = _GREEN32(GridRGB32Color~&)
    B = _BLUE32(GridRGB32Color~&)
    V = GridVisibility
    GridWidth = UBOUND(Grid_img, 1)
    GridHeight = UBOUND(Grid_img, 2)

    LINE (198, 200)-(822, 568), _RGB32(70, 70, 70), BF
    LINE (198, 200)-(822, 568), _RGB32(155, 155, 155), B
    LINE (200, 202)-(820, 566), _RGB32(155, 155, 155), B
    _FONT 8
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (480, 205), "Grid Setup"
    plus = LOADICO("ico\plus.ico", 4)
    minus = LOADICO("ico\minus.ico", 4)
    ok = LOADICO("ico\ok.ico", 6)
    DvojSipka = _LOADIMAGE("ico/dvojsipka.bmp", 32)
    oke = LOADICO("ico/oke.ico", 1)
    bck = LOADICO("ico/ko.ico", 1)


    _CLEARCOLOR 0, oke
    _CLEARCOLOR 0, bck

    _CLEARCOLOR _RGB32(255, 255, 255), DvojSipka
    _CLEARCOLOR 0, ok
    _PRINTSTRING (220, 245), "Grid Color Setup:   R"
    _PRINTSTRING (220, 270), "                    G"
    _PRINTSTRING (220, 295), "                    B"

    _PUTIMAGE (400, 240), minus
    _PUTIMAGE (660, 240), plus
    _PUTIMAGE (400, 265), minus
    _PUTIMAGE (660, 265), plus
    _PUTIMAGE (400, 290), minus
    _PUTIMAGE (660, 290), plus
    LINE (700, 245)-(750, 295), _RGB32(R, G, B), BF

    _PRINTSTRING (220, 335), "       Show Grid:"
    '    IF V THEN _PUTIMAGE (380, 328), ok
    LINE (380, 330)-(395, 345), _RGB32(255, 255, 255), B

    _PRINTSTRING (220, 375), "Grid (MAP) width:   " + STR$(GridWidth)
    LINE (380, 370)-(420, 385), _RGB32(255, 255, 255), B

    _PRINTSTRING (210, 415), "Grid (MAP) height:   " + STR$(GridHeight)
    LINE (380, 410)-(420, 425), _RGB32(255, 255, 255), B


    _PRINTSTRING (565, 335), "Show comments:"
    IF GridShowComments THEN _PUTIMAGE (700, 328), ok
    LINE (700, 330)-(715, 345), _RGB32(255, 255, 255), B

    'upgrade: v014-2

    LINE (465, 400)-(780, 400), _RGB32(127, 127, 200)
    _PRINTSTRING (257, 455), "Layers mode:"
    _PRINTSTRING (484, 415), "Mouse mode:"




    '    GridShowComments = 0
    _PRINTSTRING (510, 375), "Time before comments:"
    '    IF GridShowComments THEN _PUTIMAGE (700, 328), ok
    LINE (700, 370)-(740, 385), _RGB32(255, 255, 255), B
    _PUTIMAGE (740, 360), DvojSipka 'pro nastaveni casu komentare
    IF GridShowComments = 0 THEN LINE (500, 360)-(770, 395), _RGBA32(70, 70, 70, 210), BF

    'umisteni dvoojsipek pro snizovani / zvysovani ciselnych hodnot
    _PUTIMAGE (422, 360), DvojSipka 'width nastaveni
    _PUTIMAGE (422, 400), DvojSipka 'height nastaveni

    PCOPY _DISPLAY, 1
    comments = GridShowComments
    commtime = GridCommentsTime
    visible = GridVisibility
    GridWidt = GridWidth
    GridHeigh = GridHeight

    OldResX = GridXResolution
    OldResY = GridYResolution

    DO
        PCOPY 1, _DISPLAY
        WHILE _MOUSEINPUT: WEND
        ROLLMENU 385, 455 'UPGRADE 01U14-2
        ROLLMENU_MOUSE 584, 415


        'ovladani povoleni zobrazeni komentaru
        IF ONPOS(_MOUSEX, _MOUSEY, 700, 330, 715, 345) THEN 'show comments ctverecek
            LINE (700, 330)-(715, 345), _RGBA32(255, 255, 255, 70), BF

            IF _MOUSEBUTTON(1) THEN
                IF comments = 0 THEN comments = 1 ELSE comments = 0
                _DELAY .2
            END IF

        END IF

        IF comments THEN
            IF ONPOS(_MOUSEX, _MOUSEY, 745, 365, 754, 373) THEN
                LINE (745, 365)-(754, 373), _RGB32(170, 170, 170), B
                IF _MOUSEBUTTON(1) THEN commtime = commtime + 1: _DELAY .2
            END IF


            IF ONPOS(_MOUSEX, _MOUSEY, 745, 381, 754, 388) THEN
                LINE (745, 381)-(754, 388), _RGB32(170, 170, 170), B 'drobny ctverecek
                IF _MOUSEBUTTON(1) THEN commtime = commtime - 1: _DELAY .2
            END IF

            IF commtime > 50 THEN commtime = 50
            IF commtime < 0 THEN commtime = 0

            COLOR , _RGB32(70, 70, 70)
            '  LINE (700, 325)-(715, 345), _RGB32(70, 70, 70), BF
            LINE (700, 330)-(715, 345), _RGB32(255, 255, 255), B


            'tohle nejak poresit aby to neukazovalo tisiciny

            LINE (702, 372)-(738, 384), _RGB32(70, 70, 70), BF

            'kontrola delky casu a pripadne zkraceni:
            cmt$ = __USING$(commtime / 10, 3)
            _PRINTSTRING (710, 375), cmt$

            _PUTIMAGE (700, 328), ok
        ELSE
            LINE (700, 325)-(715, 345), _RGB32(70, 70, 70), BF
            LINE (700, 330)-(715, 345), _RGBA32(255, 255, 255, 70), BF
            LINE (700, 330)-(715, 345), _RGB32(255, 255, 255), B
            LINE (500, 360)-(770, 395), _RGBA32(70, 70, 70, 210), BF
        END IF


        'ovladani nastaveni velikosti mapy
        IF ONPOS(_MOUSEX, _MOUSEY, 380, 330, 395, 345) THEN
            LINE (380, 330)-(395, 345), _RGBA32(255, 255, 255, 70), BF

            IF _MOUSEBUTTON(1) THEN
                IF visible = 0 THEN visible = 1 ELSE visible = 0
                _DELAY .2
            END IF
        END IF

        IF visible THEN
            _PUTIMAGE (380, 328), ok
        END IF


        'ovladani sipek pro velikost mapy WIDTH
        IF ONPOS(_MOUSEX, _MOUSEY, 426, 366, 435, 373) THEN
            LINE (426, 366)-(435, 373), _RGB32(170, 170, 170), B
            IF _MOUSEBUTTON(1) THEN GridWidt = GridWidt + 1: _DELAY .02
        END IF

        IF ONPOS(_MOUSEX, _MOUSEY, 426, 382, 435, 389) THEN
            LINE (426, 382)-(435, 389), _RGB32(170, 170, 170), B
            IF _MOUSEBUTTON(1) THEN GridWidt = GridWidt - 1: _DELAY .02
        END IF

        IF GridWidt < 10 THEN GridWidt = 10
        IF GridWidt > 999 THEN GridWidt = 999

        LINE (383, 371)-(419, 384), _RGB32(70, 70, 70), BF
        _PRINTSTRING (220, 375), "Grid (MAP) width:   " + STR$(GridWidt)


        'ovladani sipek pro velikost mapy HEIGHT
        IF ONPOS(_MOUSEX, _MOUSEY, 426, 407, 435, 414) THEN
            LINE (426, 407)-(435, 414), _RGB32(170, 170, 170), B
            IF _MOUSEBUTTON(1) THEN GridHeigh = GridHeigh + 1: _DELAY .02
        END IF

        IF ONPOS(_MOUSEX, _MOUSEY, 426, 423, 435, 430) THEN
            LINE (426, 423)-(435, 430), _RGB32(170, 170, 170), B
            IF _MOUSEBUTTON(1) THEN GridHeigh = GridHeigh - 1: _DELAY .02
        END IF

        IF GridHeigh < 10 THEN GridHeigh = 10
        IF GridHeigh > 999 THEN GridHeigh = 999

        LINE (382, 411)-(416, 423), _RGB32(70, 70, 70), BF
        _PRINTSTRING (210, 415), "Grid (MAP) height:   " + STR$(GridHeigh)

        'ovladani Tahla R -
        IF ONPOS(_MOUSEX, _MOUSEY, 400, 240, 415, 255) THEN
            LINE (400, 240)-(415, 255), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN R = R - 1: _DELAY .02
        END IF
        IF R < 0 THEN R = 0
        IF R > 255 THEN R = 255

        'ovladani Tahla G -
        IF ONPOS(_MOUSEX, _MOUSEY, 400, 265, 415, 280) THEN
            LINE (400, 265)-(415, 280), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN G = G - 1: _DELAY .02
        END IF
        IF G < 0 THEN G = 0
        IF G > 255 THEN G = 255

        'ovladani Tahla B -
        IF ONPOS(_MOUSEX, _MOUSEY, 400, 290, 415, 305) THEN
            LINE (400, 290)-(415, 305), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN B = B - 1: _DELAY .02
        END IF
        IF B < 0 THEN B = 0
        IF B > 255 THEN B = 255

        '========
        'ovladani Tahla R +
        IF ONPOS(_MOUSEX, _MOUSEY, 660, 240, 675, 255) THEN
            LINE (660, 240)-(675, 255), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN R = R + 1: _DELAY .02
        END IF
        IF R < 0 THEN R = 0
        IF R > 255 THEN R = 255

        'ovladani Tahla G +
        IF ONPOS(_MOUSEX, _MOUSEY, 660, 265, 675, 280) THEN
            LINE (660, 265)-(675, 280), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN G = G + 1: _DELAY .02
        END IF
        IF G < 0 THEN G = 0
        IF G > 255 THEN G = 255

        'ovladani Tahla B +
        IF ONPOS(_MOUSEX, _MOUSEY, 660, 290, 675, 305) THEN
            LINE (660, 290)-(675, 305), _RGBA32(170, 170, 170, 60), BF
            IF _MOUSEBUTTON(1) THEN B = B + 1: _DELAY .02
        END IF
        IF B < 0 THEN B = 0
        IF B > 255 THEN B = 255


        'vykresleni tahel
        LINE (430, 297)-(645, 297), _RGB32(0, 0, 255)
        LINE (430, 273)-(645, 273), _RGB32(0, 255, 0)
        LINE (430, 247)-(645, 247), _RGB32(255, 0, 0)

        posR = 430 + (215 * (R / 255))
        posG = 430 + (215 * (G / 255))
        posB = 430 + (215 * (B / 255))


        LINE (posR - 3, 244)-(posR + 3, 250), _RGB32(255, 0, 0), BF
        LINE (posG - 3, 270)-(posG + 3, 276), _RGB32(0, 255, 0), BF
        LINE (posB - 3, 294)-(posB + 3, 300), _RGB32(0, 0, 255), BF
        LINE (700, 245)-(750, 295), _RGB32(R, G, B), BF

        'vklad konecnych tlacitek a moznosti uniku z klavesnice pres Esc

        inky$ = INKEY$
        IF inky$ = CHR$(27) THEN GOTO frimg


        IF ONPOS(_MOUSEX, _MOUSEY, 300, 500, 385, 530) THEN LINE (300, 500)-(385, 530), _RGBA32(170, 170, 170, 60), BF: IF _MOUSEBUTTON(1) THEN EXIT DO
        LINE (300, 500)-(385, 530), _RGB32(255, 255, 255), B
        _PUTIMAGE (300, 500), oke
        _PRINTSTRING (333, 513), "Done"






        IF ONPOS(_MOUSEX, _MOUSEY, 640, 500, 725, 530) THEN LINE (640, 500)-(725, 530), _RGBA32(170, 170, 170, 60), BF: IF _MOUSEBUTTON(1) THEN GOTO frimg
        LINE (640, 500)-(725, 530), _RGB32(255, 255, 255), B
        _PUTIMAGE (640, 500), bck
        _PRINTSTRING (673, 513), "Back"



        REM        LOCATE 1, 1: PRINT _MOUSEX, _MOUSEY
        PCOPY _DISPLAY, 2
        _DISPLAY
    LOOP


    'Warning = 0
    IF OldResX > GridWidt OR OldResY > GridHeigh THEN 'zmena pole na nizsi hodnoty, test, jestli je v tomto poli zaznam
        SOUND 450, .1


    IF _
       is_subset(grid_img(), gridwidt, gridheigh) or_
       is_subset(grid_ceil(), gridwidt, gridheigh) or_
       is_subset(grid_floor(), gridwidt, gridheigh) then Warning = 1
    END IF

    '-----------------------------------------------
    '        Warning = 1
    '
    '       FOR testY = 1 TO OldResY
    '           FOR testX = 1 TO OldResX
    '               IF testY > GridHeigh OR testX > GridWidt THEN
    '                   IF Grid_img(testX, testY) < 0 OR Grid_Ceil(testX, testY) < 0 OR Grid_Floor(testX, testY) < 0 THEN Warning = 1: GOTO hlaseni
    '               END IF
    '       NEXT testX, testY
    '   END IF
    '-------------------------------------------------


    '    Warning = 1 'pro testovani!
    hlaseni:
    IF Warning THEN 'dialog s varovanim. Dalsi cast = souhlas - ano, zmensit pole i se ztratou dat
        PCOPY 2, _DISPLAY
        Warn = LOADICO("ico/warn.ico", 6)
        '        _CLEARCOLOR _RGB32(0, 0, 0), Warn
        _CLEARCOLOR 0, Warn
        LINE (348, 300)-(648, 410), _RGB32(255, 0, 0), BF
        LINE (348, 300)-(648, 410), _RGB32(255, 255, 255), B
        LINE (350, 302)-(646, 408), _RGB32(255, 255, 255), B
        _PUTIMAGE (370, 320), Warn
        _PRINTSTRING (430, 310), "Warning:"
        _PRINTSTRING (430, 330), "Some objects, walls, ceil-"
        _PRINTSTRING (430, 340), "ings or floors are in area"
        _PRINTSTRING (430, 350), "now set as out of map.    "
        _PRINTSTRING (430, 360), "This delete it. Continue? "
        LINE (430, 378)-(500, 398), _RGB32(70, 70, 70), BF
        LINE (550, 378)-(620, 398), _RGB32(70, 70, 70), BF
        LINE (430, 378)-(500, 398), _RGB32(255, 255, 255), B
        LINE (550, 378)-(620, 398), _RGB32(255, 255, 255), B


        _PUTIMAGE (430, 373), oke: _PUTIMAGE (550, 373), bck
        _PRINTSTRING (430, 386), "     Yes            No"
        PCOPY _DISPLAY, 2
        DO
            PCOPY 2, _DISPLAY
            i$ = INKEY$
            IF i$ = CHR$(27) THEN _FREEIMAGE Warn: GOTO frimg 'esc abortuje vse
            IF i$ = CHR$(13) THEN EXIT DO '     enter potvrdi vse
            WHILE _MOUSEINPUT: WEND
            _PRINTMODE _FILLBACKGROUND
            LOCATE 1, 1: PRINT _MOUSEX, _MOUSEY
            IF ONPOS(_MOUSEX, _MOUSEY, 430, 378, 500, 398) THEN
                LINE (430, 378)-(500, 398), _RGBA32(255, 255, 255, 70), BF
                IF _MOUSEBUTTON(1) THEN EXIT DO
            END IF

            IF ONPOS(_MOUSEX, _MOUSEY, 550, 378, 620, 398) THEN
                LINE (550, 378)-(620, 398), _RGBA32(255, 255, 255, 70), BF
                IF _MOUSEBUTTON(1) THEN _FREEIMAGE Warn: GOTO frimg
            END IF
            _DISPLAY
        LOOP
    END IF


    RESIZE_ARR2 Grid_img(), GridWidt, GridHeigh
    RESIZE_ARR2 Grid_Ceil(), GridWidt, GridHeigh
    RESIZE_ARR2 Grid_Floor(), GridWidt, GridHeigh
    RESIZE_ARR2 Grid_Obj(), GridWidt, GridHeigh
    RESIZE_ARR2 Grid_typ(), GridWidt, GridHeigh
    RESIZE_INFOPLUS


    GridXResolution = GridWidt
    GridYResolution = GridHeigh
    GridShowComments = comments
    GridVisibility = visible
    GridCommentsTime = commtime / 10
    GridRGB32Color~& = _RGB32(R, G, B)
    SaveINI

    frimg:
    _FREEIMAGE plus
    _FREEIMAGE minus
    _FREEIMAGE ok
    _FREEIMAGE DvojSipka
    _FREEIMAGE oke
    _FREEIMAGE bck
END SUB

FUNCTION __USING$ (Value AS SINGLE, lenght AS INTEGER)
    IF LEFT$(STR$(Value), 2) = " ." THEN Value$ = "0" + _TRIM$(STR$(Value)) ELSE Value$ = _TRIM$(STR$(Value))
    IF LEN(Value$) >= lenght THEN __USING$ = LEFT$(Value$, lenght) ELSE __USING$ = Value$ + STRING$(lenght - LEN(Value$), "0")
    IF INSTR(1, Value$, ".") = 0 AND LEN(Value$) < lenght THEN __USING$ = Value$ + _TRIM$(".") + STRING$(lenght - LEN(Value$) - 1, "0")
END FUNCTION


SUB RESIZE_INFOPLUS 'MOZNA TO BUDE DELAT BORDEL! POUZITO PRESERVE!

    REDIM _PRESERVE IP_Img(UBOUND(Grid_img, 1), UBOUND(Grid_img, 2)) AS InfoPlus
    REDIM _PRESERVE IP_Ceil(UBOUND(Grid_img, 1), UBOUND(Grid_img, 2)) AS InfoPlus
    REDIM _PRESERVE IP_Floor(UBOUND(Grid_img, 1), UBOUND(Grid_img, 2)) AS InfoPlus

END SUB


SUB SaveINI
    file$ = "editor.ini"
    ff = FREEFILE
    OPEN file$ FOR OUTPUT AS #ff
    PRINT #ff, "Commented INI file: Program use byte positions 41++ to read on every row. Read not first row and read not first 40 characters on rows!"
    PRINT #ff, "SET MAP X RESOLUTION:"; TAB(40); GridXResolution
    PRINT #ff, "SET MAP Y RESOLUTION:"; TAB(40); GridYResolution
    PRINT #ff, "SET MAP COLOR RGB32:"; TAB(40); STR$(GridRGB32Color~&)
    PRINT #ff, "SET MAP VISIBILITY:"; TAB(40); GridVisibility
    PRINT #ff, "SHOW COMMENTS ON MAP:"; TAB(40); GridShowComments
    PRINT #ff, "TIME BEFORE SHOW COMMENTS:"; TAB(40); GridCommentsTime
    PRINT #ff, "LAYERS SETTINGS (0 - 4):"; TAB(40); LAYERS_SETUP
    PRINT #ff, "MOUSE DRAW SETTING (0 or 1):"; TAB(40); DRAW_MOUSE_SETUP

    PRINT #ff, "Walls - Height From (-2 default):"; TAB(40); Img_Height_From
    PRINT #ff, "Walls - Height To (2 default):"; TAB(40); Img_Height_To
    PRINT #ff, "Walls - Walls to 1 texture (1):"; TAB(40); Img_Textures_per_Object
    PRINT #ff, "Walls - texture effect (0 def):"; TAB(40); Img_Texture_Effect

    PRINT #ff, "Ceiling - Height From (2 default):"; TAB(40); Ceil_Height_From
    PRINT #ff, "Ceiling - Height To (2 default):"; TAB(40); Ceil_Height_To
    PRINT #ff, "Ceiling - Walls to 1 texture (1):"; TAB(40); Ceil_Textures_per_Object
    PRINT #ff, "Ceiling - texture effect (0 def):"; TAB(40); Ceil_Texture_Effect

    PRINT #ff, "Floors - Height From (-2 default):"; TAB(40); Floor_Height_From
    PRINT #ff, "Floors - Height To (-2 default):"; TAB(40); Floor_Height_To
    PRINT #ff, "Floors - Walls to 1 texture (1):"; TAB(40); Floor_Textures_per_Object
    PRINT #ff, "Floors - texture effect (0 def):"; TAB(40); Floor_Texture_Effect
    PRINT #ff, "Copy/Insert function setup: (0 or 1):"; TAB(40); INSERT_SETUP

    CLOSE #ff
END SUB

SUB RESIZE_ARR2 (Grid() AS LONG, New_Ubound_A AS LONG, New_Ubound_B AS LONG) 'for 2 dimensional arrays, because _PRESERVE for 2D arrays is.......oh my god.
    DIM swp(New_Ubound_A, New_Ubound_B) AS LONG
    FOR a = LBOUND(Grid, 1) TO UBOUND(Grid, 1)
        FOR b = LBOUND(Grid, 2) TO UBOUND(Grid, 2)
            aa = -1: bb = -1
            IF a <= UBOUND(swp, 1) THEN aa = a
            IF b <= UBOUND(swp, 2) THEN bb = b
            IF aa >= 0 AND bb >= 0 THEN swp(aa, bb) = Grid(a, b)
    NEXT b, a

    REDIM Grid(New_Ubound_A, New_Ubound_B) AS LONG
    FOR a = LBOUND(swp, 1) TO UBOUND(swp, 1)
        FOR b = LBOUND(swp, 2) TO UBOUND(swp, 2)
            Grid(a, b) = swp(a, b)
    NEXT b, a
    ERASE swp
END SUB

SUB SAVE_MAP (filename AS STRING) 'vytvori binarni MAP soubor



    filename$ = ".\MAP\" + filename$ 'uprava aby to ukladal do slozky MAP

    'test, jestli pole textur vubec neco obsahuji:
    FOR testTextures = LBOUND(Texture) TO UBOUND(Texture)
        IF Texture(testTextures).img < -1 THEN pass = 1: EXIT FOR ELSE pass = 0
    NEXT testTextures

    IF pass THEN
        DIM MH AS MAP_HEAD
        '       DIM Vertex(0) AS Vertex
        id$ = "MAP3D"

        'test poctu relevantnich zaznamu:
        rec = 0
        FOR a = LBOUND(Grid_img, 1) TO UBOUND(Grid_img, 1)
            FOR b = LBOUND(Grid_img, 2) TO UBOUND(Grid_img, 2)
                IF Grid_img(a, b) THEN rec = rec + 1
                IF Grid_Floor(a, b) THEN rec = rec + 1
                IF Grid_Ceil(a, b) THEN rec = rec + 1
        NEXT b, a

        s1 = 0

        DIM siz(UBOUND(Texture)) AS LONG, totalSize AS LONG
        FOR s = LBOUND(Texture) TO UBOUND(Texture)
            s1 = s1 + LEN(REMOVE_PATH$(Texture(s).path))
            s1 = s1 + 4 'pro velikost souboru LONG
            s1 = s1 + 4 'pro velikost delky jmena typu LONG
            ff2 = FREEFILE

            OPEN Texture(s).path FOR BINARY AS #ff2
            siz(s) = LOF(ff2)
            CLOSE #ff2
            totalSize = totalSize + siz(s)
        NEXT s


        MH.Identity = SaveMap3D$
        MH.Nr_of_Textures = UBOUND(Texture) + 1 'protoze zaznam cislo 0 pro texturu take obsahuje 1 texturu
        MH.Nr_of_Vertexes = rec
        MH.DataStart = 21 + s1 'hlava ma 21 bytu
        MH.VertexStart = MH.DataStart + totalSize
        '----- Hlava je pripravena ---------- File header ready

        ff = FREEFILE
        OPEN filename$ FOR OUTPUT AS #ff: CLOSE #ff
        OPEN filename$ FOR BINARY AS #ff
        PUT #ff, , MH

        DIM NameLenght AS LONG
        FOR SaveNamesLenght = LBOUND(Texture) TO UBOUND(Texture)
            NameLenght = LEN(REMOVE_PATH(Texture(SaveNamesLenght).path))
            PUT #ff, , NameLenght
        NEXT
        'ukladani velikosti souboru ' saving files sizes
        DIM FSize AS LONG
        FOR SaveNamesLenght = LBOUND(Texture) TO UBOUND(Texture)
            FSize = siz(SaveNamesLenght)
            PUT #ff, , FSize
        NEXT

        'ukladani jmen souboru'  saving files names
        FOR SaveFilesNames = LBOUND(Texture) TO UBOUND(Texture)
            nam$ = SPACE$((LEN(REMOVE_PATH(Texture(SaveFilesNames).path))))
            nam$ = REMOVE_PATH(Texture(SaveFilesNames).path)
            PUT #ff, , nam$
        NEXT SaveFilesNames

        'nasleduje zkopirovani binarnich dat textur 'copying files datas to MAP file
        FOR Copy_Binary_Texture_Data = LBOUND(siz) TO UBOUND(siz)
            ff2 = FREEFILE
            OPEN Texture(Copy_Binary_Texture_Data).path FOR BINARY AS #ff2
            fbd$ = SPACE$(LOF(ff2))
            GET #ff2, , fbd$
            CLOSE #ff2
            PUT #ff, , fbd$
        NEXT


        'zmena oproti verzi 01U13: Nasleduji dve hodnoty LONG udavajici vysku a sirku mapy, pote nasleduji 3 kopie map GRID v LONG, udavajici -1 = neni textura, nebo cislo textury

        'save grid (map) size
        DIM W AS LONG, H AS LONG, Texture_Nr AS LONG

        W = UBOUND(Grid_img, 1) 'je li sirka jednoho ctverce .5, nelze jinak
        H = UBOUND(Grid_img, 2)

        PUT #ff, , W
        PUT #ff, , H

        'nejprve zpracuju zdi. Toto pole umoznuje jednu texturu na jeden blok zdi v teto verzi.
        'save walls infos

        FOR RecordWallsY = LBOUND(Grid_img, 2) TO UBOUND(Grid_img, 2) - 1
            FOR RecordWallsX = LBOUND(Grid_img, 1) TO UBOUND(Grid_img, 1) - 1
                IF Grid_img(RecordWallsX, RecordWallsY) THEN
                    Texture_Nr = GET_TEXTURE_NR(Grid_img(RecordWallsX, RecordWallsY)) + 1 'cislo textury
                    '     PRINT RecordWallsX, RecordWallsY: _DISPLAY: SLEEP
                ELSE
                    Texture_Nr = -1
                END IF
                PUT #ff, , Texture_Nr
            NEXT
        NEXT



        've stejne smycce, protoze tato pole maji stejne velikosti, zpracuji i pole zemi (floor)
        'save floors infos

        FOR RecordFloorY = LBOUND(Grid_Floor, 2) TO UBOUND(Grid_Floor, 2) - 1
            FOR RecordFloorX = LBOUND(Grid_Floor, 1) TO UBOUND(Grid_Floor, 1) - 1
                IF Grid_Floor(RecordFloorX, RecordFloorY) THEN
                    Texture_Nr = GET_TEXTURE_NR(Grid_Floor(RecordFloorX, RecordFloorY)) + 1 'cislo textury
                ELSE
                    Texture_Nr = -1
                END IF
                PUT #ff, , Texture_Nr
            NEXT
        NEXT
        'nakonec to same pro strop:
        'save ceilings infos

        FOR RecordCeilY = LBOUND(Grid_Ceil, 2) TO UBOUND(Grid_Ceil, 2) - 1
            FOR RecordCeilX = LBOUND(Grid_Ceil, 1) TO UBOUND(Grid_Ceil, 1) - 1
                IF Grid_Ceil(RecordCeilX, RecordCeilY) THEN
                    Texture_Nr = GET_TEXTURE_NR(Grid_Ceil(RecordCeilX, RecordCeilY)) + 1 'cislo textury
                ELSE
                    Texture_Nr = -1
                END IF
                PUT #ff, , Texture_Nr
            NEXT
        NEXT


        'in future next areas: Sound infos, objects infos


    ELSE DialogW "MAP IS EMPTY!", 3

    END IF
END SUB

FUNCTION GET_TEXTURE_NR (rec AS LONG)
    FOR x = LBOUND(Texture) TO UBOUND(Texture)
        Tnr = Texture(x).img
        IF Tnr = rec THEN GET_TEXTURE_NR = x: EXIT FUNCTION
    NEXT
END FUNCTION

FUNCTION REMOVE_PATH$ (path$)
    REMOVE_PATH$ = MID$(path$, _INSTRREV(path$, "\") + 1)
END FUNCTION

FUNCTION Sload& (fileName AS STRING)
    Sload& = _LOADIMAGE(fileName$, 32)
END FUNCTION



SUB LOAD_MAP (filename AS STRING) 'load images as software textures + other infos
    IF _FILEEXISTS(filename) THEN
        DIM RH AS MAP_HEAD
        '        DIM Vertex AS Vertex

        ff = FREEFILE
        OPEN filename$ FOR BINARY AS #ff
        GET #ff, , RH
        IF RH.Identity <> "MAP3D" THEN PRINT "Unsupported MAP format.": EXIT SUB 'unsupported file format

        PRINT "V souboru je:"; RH.Nr_of_Textures; "textur" 'Nr Textures in file                   4 B
        PRINT "V souboru je:"; RH.Nr_of_Vertexes; "vrcholu" 'Nr Vertexes in file                  4 B
        PRINT "Zacatek dat textur: "; RH.DataStart 'Data texture in file start offset             4 B
        PRINT "Zacatek dat vrcholu: "; RH.VertexStart 'Vertexes in file start offset              4 B

        _DISPLAY


        DIM FileNamesLenght(RH.Nr_of_Textures) AS LONG
        FOR R = 1 TO RH.Nr_of_Textures
            GET #ff, , FileNamesLenght(R)
        NEXT R


        DIM FileSize(RH.Nr_of_Textures) AS LONG
        FOR R = 1 TO RH.Nr_of_Textures
            GET #ff, , FileSize(R)
        NEXT R


        DIM FileName(RH.Nr_of_Textures) AS STRING
        FOR R = 1 TO RH.Nr_of_Textures
            FileName(R) = SPACE$(FileNamesLenght(R))
            GET #ff, , FileName(R)
        NEXT R

        SP$ = "TEXTURES\"

        IF _DIREXISTS("TEXTURES") = 0 THEN MKDIR "TEXTURES"

        FOR R = 1 TO RH.Nr_of_Textures
            ff2 = FREEFILE
            OPEN SP$ + FileName(R) FOR OUTPUT AS #ff2 'doplneno SP$
            CLOSE #ff2
            OPEN SP$ + FileName(R) FOR BINARY AS #ff2
            record$ = SPACE$(FileSize(R))
            GET #ff, , record$
            PUT #ff2, , record$
            record$ = ""
            CLOSE #ff2
        NEXT R

        REDIM Texture(RH.Nr_of_Textures - 1) AS Texture

        FOR R = 1 TO RH.Nr_of_Textures
            Texture(R - 1).img = Sload(SP$ + FileName(R)) 'index udava poradi textury v souboru, pridano SP$
            Texture(R - 1).path = SP$ + FileName(R)
        NEXT R


        DIM W AS LONG, H AS LONG
        GET #ff, , W
        GET #ff, , H


        REDIM Grid_img(W, H) AS LONG
        REDIM Grid_Floor(W, H) AS LONG
        REDIM Grid_Ceil(W, H) AS LONG
        REDIM Grid_typ(W, H) AS LONG

        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                GET #ff, , record&
                IF record& > -1 THEN
                    Grid_img(Lx, Ly) = Texture(record& - 1).img
                END IF
        NEXT Lx, Ly

        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                GET #ff, , record&
                IF record& > -1 THEN
                    Grid_Floor(Lx, Ly) = Texture(record& - 1).img
                END IF
        NEXT Lx, Ly


        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                GET #ff, , record&
                IF record& > -1 THEN
                    Grid_Ceil(Lx, Ly) = Texture(record& - 1).img
                END IF
        NEXT Lx, Ly
        CLOSE #ff

        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                T = WHOIS(Lx, Ly)
                Grid_typ(Lx, Ly) = T
        NEXT Lx, Ly


    ELSE 'file not found
        EXIT SUB
    END IF


    StartDrawX = 0: EndDrawX = 36
    StartDrawy = 0: EndDrawy = 35
END SUB


SUB ROLLMENU (X AS INTEGER, y AS INTEGER)
    WHILE _MOUSEINPUT: WEND

    _PRINTSTRING (X, y), CHR$(31)
    LINE (X - 5, y - 5)-(X + 355, y + 14), _RGB32(255, 255, 255), B

    REDIM Roll(4) AS STRING
    Roll(0) = "Show all layers. Separate it using ALPHA" 'to jak to je ted
    Roll(1) = "Show actual layer only" '                 ukaze jen vrstvu na kterou je preply, ostatni nezobrazi
    Roll(2) = "Show actual layer, SPACE for show all" '  ukaze jen aktualni vrstvu, po stisku mezerniku i ostatni vrstvy
    Roll(3) = "Don't show textures, use QUADS, all layers" 'misto textur pouzije LINE BF, zobrazi vsechny vrstvy
    Roll(4) = "Don't show textures, use QUAD, one layer" 'misto textur pouzije LINE BF, vzdy jen aktualni vrstvu
    _PRINTSTRING (X + 20, y), Roll(LAYERS_SETUP)

    IF ONPOS(_MOUSEX, _MOUSEY, X - 10, y - 10, X + 10, y + 10) THEN

        LINE (X, y - 3)-(X + 8, y + 10), _RGBA32(127, 127, 127, 120), BF

        IF _MOUSEBUTTON(1) THEN
            DIM my AS INTEGER
            _KEYCLEAR
            _DELAY .3
            DO
                PCOPY 2, _DISPLAY
                LINE (X - 5, y - 10)-(X + 356, y + (20 * (UBOUND(Roll) + 1))), _BACKGROUNDCOLOR, BF
                LINE (X - 5, y - 10)-(X + 356, y + (20 * (UBOUND(Roll) + 1))), _RGB32(255), B
                Ypoz = y + (20 * LAYERS_SETUP)
                LINE (X - 3, Ypoz - 5)-(X + 353, Ypoz + 15), _RGB32(200), B
                i$ = INKEY$
                SELECT CASE i$
                    CASE CHR$(0) + CHR$(72) ' up
                        LAYERS_SETUP = LAYERS_SETUP - 1
                    CASE CHR$(0) + CHR$(80) 'dn
                        LAYERS_SETUP = LAYERS_SETUP + 1
                END SELECT
                IF LAYERS_SETUP < LBOUND(Roll) THEN LAYERS_SETUP = UBOUND(Roll)
                IF LAYERS_SETUP > UBOUND(Roll) THEN LAYERS_SETUP = LBOUND(Roll)
                FOR s = LBOUND(Roll) TO UBOUND(Roll)
                    _PRINTSTRING (X + 20, y + (20 * s)), Roll(s)
                NEXT
                WHILE _MOUSEINPUT: WEND
                my = _CEIL(_MOUSEY - y - 5) / 20
                IF ONPOS(_MOUSEX, _MOUSEY, X - 5, y - 5, X + 365, y + 90) THEN
                    LOCATE 1, 1: PRINT my
                    LAYERS_SETUP = my
                    IF _MOUSEBUTTON(1) THEN MouseSel = 1
                END IF

                REM   _PRINTSTRING (X + 20, y), Roll(LAYERS_SETUP)

                'vyjede roleta s nabidkou

                _DISPLAY
                _LIMIT 50
            LOOP UNTIL i$ = CHR$(13) OR MouseSel = 1
        END IF

    ELSE
        activ = 0
    END IF
END SUB

SUB ROLLMENU_MOUSE (X AS INTEGER, y AS INTEGER)
    WHILE _MOUSEINPUT: WEND

    _PRINTSTRING (X, y), CHR$(31)
    LINE (X - 5, y - 5)-(X + 155, y + 14), _RGB32(255, 255, 255), B

    REDIM Roll(1) AS STRING
    Roll(0) = "Single squares" 'to jak to je ted
    Roll(1) = "In blocks" '          malovat v blocich
    _PRINTSTRING (X + 20, y), Roll(DRAW_MOUSE_SETUP)

    IF ONPOS(_MOUSEX, _MOUSEY, X - 10, y - 10, X + 10, y + 10) THEN

        LINE (X, y - 3)-(X + 8, y + 10), _RGBA32(127, 127, 127, 120), BF

        IF _MOUSEBUTTON(1) THEN
            DIM my AS INTEGER
            _KEYCLEAR
            _DELAY .3
            DO
                PCOPY 2, _DISPLAY
                LINE (X - 5, y - 10)-(X + 156, y + (20 * (UBOUND(Roll) + 1))), _BACKGROUNDCOLOR, BF
                LINE (X - 5, y - 10)-(X + 156, y + (20 * (UBOUND(Roll) + 1))), _RGB32(255), B
                Ypoz = y + (20 * DRAW_MOUSE_SETUP)
                LINE (X - 3, Ypoz - 5)-(X + 153, Ypoz + 15), _RGB32(200), B
                i$ = INKEY$
                SELECT CASE i$
                    CASE CHR$(0) + CHR$(72) ' up
                        DRAW_MOUSE_SETUP = DRAW_MOUSE_SETUP - 1
                    CASE CHR$(0) + CHR$(80) 'dn
                        DRAW_MOUSE_SETUP = DRAW_MOUSE_SETUP + 1
                END SELECT
                IF DRAW_MOUSE_SETUP < LBOUND(Roll) THEN DRAW_MOUSE_SETUP = UBOUND(Roll)
                IF DRAW_MOUSE_SETUP > UBOUND(Roll) THEN DRAW_MOUSE_SETUP = LBOUND(Roll)
                FOR s = LBOUND(Roll) TO UBOUND(Roll)
                    _PRINTSTRING (X + 20, y + (20 * s)), Roll(s)
                NEXT
                WHILE _MOUSEINPUT: WEND
                my = _CEIL(_MOUSEY - y - 5) / 20
                IF ONPOS(_MOUSEX, _MOUSEY, X - 5, y - 5, X + 165, y + 90) THEN
                    '                    LOCATE 1, 1: PRINT my
                    DRAW_MOUSE_SETUP = my
                    IF _MOUSEBUTTON(1) THEN MouseSel = 1
                END IF

                REM   _PRINTSTRING (X + 20, y), Roll(LAYERS_SETUP)

                'vyjede roleta s nabidkou

                _DISPLAY
                _LIMIT 50
            LOOP UNTIL i$ = CHR$(13) OR MouseSel = 1
        END IF

    ELSE
        activ = 0
    END IF
END SUB


FUNCTION FAST_MAP_INFO& (MAP_File_Name AS STRING)
    IF _FILEEXISTS(MAP_File_Name) THEN
        DIM RH AS MAP_HEAD
        '        DIM Vertex AS Vertex

        ff = FREEFILE
        OPEN MAP_File_Name$ FOR BINARY AS #ff
        GET #ff, , RH
        IF RH.Identity <> "MAP3D" THEN PRINT "Unsupported MAP format.": EXIT FUNCTION 'unsupported file format


        SEEK #ff, RH.VertexStart + 1

        DIM W AS LONG, H AS LONG
        GET #ff, , W
        GET #ff, , H

        tmp& = _NEWIMAGE(W * 5, H * 5 + 70, 32)
        pred = _DEST
        _DEST tmp&
        FOR Lx = 1 TO W
            FOR Ly = 1 TO H
                GET #ff, , record&
                IF record& > -1 THEN
                    LINE (Lx * 5, Ly * 5)-(Lx * 5 + 5, Ly * 5 + 5), _RGB32(255), BF
                END IF
        NEXT Ly, Lx



        FOR Lx = 1 TO W
            FOR Ly = 1 TO H
                GET #ff, , record&
                IF record& > -1 THEN
                    IF POINT(Lx, Ly) <> _RGB32(255) THEN LINE (Lx * 5, Ly * 5)-(Lx * 5 + 5, Ly * 5 + 5), _RGB32(255, 255, 0), BF
                END IF
        NEXT Ly, Lx


        FOR Lx = 1 TO W
            FOR Ly = 1 TO H
                GET #ff, , record&
                IF record& > -1 THEN
                    LINE (Lx * 5, Ly * 5)-(Lx * 5 + 5, Ly * 5 + 5), _RGBA32(255, 0, 0, 50), BF
                END IF
        NEXT Ly, Lx

        _PRINTMODE _KEEPBACKGROUND
        COLOR _RGB32(100, 255, 255)

        _PRINTSTRING (10, H * 5 + 5), "Map contains" + STR$(RH.Nr_of_Textures) + " textures." 'pocet textur v souboru                                                4 B
        _PRINTSTRING (10, H * 5 + 25), "Map use" + STR$(RH.Nr_of_Vertexes) + " objects." 'pocet vrcholu v souboru                                               4 B
        _PRINTSTRING (10, H * 5 + 45), "MAP size:" + STR$(LOF(ff)) + " bytes."


        _DEST pred

        FAST_MAP_INFO& = tmp&
    END IF
END FUNCTION

FUNCTION IS_SUBSET (array() AS LONG, RangeAX, RangeAY) 'pokud pole obsahuje hodnotu v rozsahu od RangeAX, RangeAY do UBOUND1, UBOUND2, pak funkce vrati 1
    MaxX = UBOUND(array, 1)
    MaxY = UBOUND(array, 2)
    MinX = LBOUND(array, 1)
    MinY = LBOUND(array, 2)
    IF RangeAX > MaxX OR RangeAY > MaxY THEN EXIT FUNCTION
    IF RangeAX < MinX OR RangeAY < MinY THEN EXIT FUNCTION
    FOR ty = RangeAY TO MaxY
        FOR Tx = RangeAX TO MaxX
            IF array(Tx, ty) THEN IS_SUBSET = 1: EXIT FUNCTION
    NEXT Tx, ty
END FUNCTION

'$INCLUDE:'saveimage.bm'
'$INCLUDE:'editor.bm'

