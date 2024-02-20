SCREEN _NEWIMAGE(1024, 768, 32)

DEFLNG A-Z

VIEW PRINT 1 TO 10
_FONT 8




TYPE Area_Type

    '----------------------

    'image - the image this area represents, and this area alone
    'composite image - imported area from all parents NOT INCLUDING this object (so changes to this object can quickly be applied)
    '                  if this is highest element(eg. check-box) and a change occurs this area can be referenced quickly, if it included
    '                  the image and a change occurred then this image would be useless


    Col AS LONG

    Image_Changed AS LONG 'set to 1 if area changed
    Image AS LONG
    Composite_Image AS LONG




    '----------------------
    Child_Grid AS LONG 'if 0 then this area has no child grid
    '----------------------
    Grid AS LONG
    Height_Section AS LONG
    Width_Section AS LONG
    '----------------------
    Next_Area AS LONG
END TYPE







'for floating c

TYPE Grid_Type
    Parent_Area AS LONG



    Float_Within_Parent AS LONG
    Float_Group AS LONG
    'group allows more control, for instance, a start/system bar might always be on top
    Float_Level AS LONG
    Offset_X AS LONG 'only relevent for floating grids
    Offset_Y AS LONG


    First_Floating_Child AS LONG


    Rows AS LONG
    Columns AS LONG
    First_Width_Section AS LONG
    First_Height_Section AS LONG
    First_Area AS LONG
END TYPE
TYPE Section_Type
    Min_Pixels AS LONG
    Max_Pixels AS LONG
    Min_Percent AS SINGLE
    Max_Percent AS SINGLE
    Ideal_Ratio AS SINGLE
    '----------------------
    'collapse, push or scale rules go here
    '----------------------
    'user resizable options
    Side_A_Resizable AS LONG 'lhs/top
    Side_B_Resizable AS LONG 'rhs/bottom

    '----------------------
    Size_Pixels AS LONG
    '----------------------
    Test_Size_Pixels AS LONG
    '----------------------
    Next_Section AS LONG 'for next column/row's section
END TYPE

CONST RESIZABLE_BY_USER = 1


DIM SHARED Sections, Last_Section
DIM SHARED Grids, Last_Grid
DIM SHARED Areas, Last_Area

Last_Section = 1000
Last_Grid = 1000
Last_Area = 1000

REDIM SHARED Section(1 TO Last_Section) AS Section_Type
REDIM SHARED Grid(1 TO Last_Grid) AS Grid_Type
REDIM SHARED Area(1 TO Last_Area) AS Area_Type

DIM SHARED Empty_Grid AS Grid_Type
DIM SHARED Empty_Section AS Section_Type

'create grid
Grids = Grids + 1
g = Grids
Grid(g) = Empty_Grid

Grid(g).Parent_Area = 0
Grid(g).Float_Within_Parent = 1 'it effectively floats on our SCREEN
Grid(g).Offset_X = 0
Grid(g).Offset_Y = 0
Grid(g).Rows = 1
Grid(g).Columns = 1

Sections = Sections + 1: xs = Sections: Grid(g).First_Width_Section = xs
Sections = Sections + 1: ys = Sections: Grid(g).First_Height_Section = ys
Section(xs).Size_Pixels = _WIDTH(0)
Section(ys).Size_Pixels = _HEIGHT(0)

Areas = Areas + 1
a = Areas
Area(a).Grid = g
Area(a).Height_Section = ys
Area(a).Width_Section = xs
Grid(g).First_Area = a

root_area = a
root_grid = g


'###################################################################################################################################
' User Program Starts Here
'###################################################################################################################################


x = 3: y = 5
'create grid
g = Create_Grid(root_area, x, y)
'assign horizontal metrics
FOR x2 = 1 TO x
    s = Get_Grid_Section(g, x2, 0)
    'set metrics
    IF x2 = 2 THEN
        Section(s).Min_Pixels = 100
        Section(s).Max_Pixels = 128
    END IF
    IF x2 = 3 THEN
        Section(s).Min_Percent = 50
    END IF
    '...
NEXT
'assign vertical metrics
FOR y2 = 1 TO y
    s = Get_Grid_Section(g, 0, y2)
    'set metrics
    Section(s).Ideal_Ratio = y2
    '...
NEXT
Init_Grid g

main_grid = g

'create a grid inside this grid
a = Get_Area(g, 2, 3)
parent_area = a

x = 4: y = 4
'create grid
g = Create_Grid(parent_area, x, y)
'assign horizontal metrics
FOR x2 = 1 TO x
    s = Get_Grid_Section(g, x2, 0)
    'set metrics
    Section(s).Min_Pixels = 10

    IF x2 = 2 THEN
        'Section(s).Min_Pixels = 10
        '        Section(s).Max_Pixels = 128
    END IF
    IF x2 = 3 THEN
        Section(s).Min_Percent = 40
    END IF
    '...
NEXT
'assign vertical metrics
FOR y2 = 1 TO y
    s = Get_Grid_Section(g, 0, y2)
    'set metrics
    '  Section(s).Ideal_Ratio = y2
    '...
NEXT
Init_Grid g


'create a grid inside this grid
a = Get_Area(main_grid, 3, 4)
parent_area = a

x = 4: y = 4
'create grid
g = Create_Grid(parent_area, x, y)
'assign horizontal metrics
FOR x2 = 1 TO x
    s = Get_Grid_Section(g, x2, 0)
    'set metrics
    Section(s).Min_Pixels = 5
    IF x2 = 2 THEN
        'Section(s).Min_Pixels = 5
        '        Section(s).Max_Pixels = 128
    END IF
    IF x2 = 2 THEN
        Section(s).Min_Percent = 80
    END IF
    '...
NEXT
'assign vertical metrics
FOR y2 = 1 TO y
    s = Get_Grid_Section(g, 0, y2)
    'set metrics
    '  Section(s).Ideal_Ratio = y2
    '...
NEXT
Init_Grid g







''create a grid inside this grid
'a = Get_Area(g, 2, 3)
'parent_area = a

'x = 4: y = 4
''create grid
'g = Create_Grid(parent_area, x, y)
''assign horizontal metrics
'FOR x2 = 1 TO x
'    s = Get_Grid_Section(g, x2, 0)
'    'set metrics
'    IF x2 = 2 THEN
'        '       Section(s).Min_Pixels = 100
'        '        Section(s).Max_Pixels = 128
'    END IF
'    IF x2 = 3 THEN
'        Section(s).Min_Percent = 40
'    END IF
'    '...
'NEXT
''assign vertical metrics
'FOR y2 = 1 TO y
'    s = Get_Grid_Section(g, 0, y2)
'    'set metrics
'    '  Section(s).Ideal_Ratio = y2
'    '...
'NEXT
'Init_Grid g




TYPE STACK_TYPE
    Grid AS LONG
    base_x AS LONG
    base_y AS LONG
    ox AS LONG
    oy AS LONG
    row AS LONG
    col AS LONG
    area AS LONG
END TYPE


DIM SHARED stack(1 TO 1000) AS STACK_TYPE


TYPE Mouse_Pos_Type
    Area AS LONG
    Ax AS LONG
    Ay AS LONG
    Gx AS LONG 'this point's offset within its parent's grid
    Gy AS LONG



END TYPE

DIM SHARED MPos(1 TO 1000) AS Mouse_Pos_Type
DIM SHARED MPosI

DIM SHARED MB_DOWN_MPos(1 TO 1000) AS Mouse_Pos_Type
DIM SHARED MB_DOWN_MPosI




DIM SHARED MX, MY, MB, MW, MB_CLICK, MB_DOWN, MB_UP, MB_DOWN_SX, MB_DOWN_SY, MB_UP_SX, MB_UP_SY, MDRAG, MDRAG_BEGIN

MDRAG = 0

M_OVER_EDGE = 0
M_OVER_EDGE2 = 0

DO 'mainloop

    CLS , 0

    omb = MB
    MWheel = 0
    DO WHILE _MOUSEINPUT
        MX = _MOUSEX
        MY = _MOUSEY
        MW = MW + _MOUSEWHEEL
        MB = _MOUSEBUTTON(1): IF MB <> omb THEN EXIT DO
    LOOP
    MB_UP = 0: IF omb <> 0 AND MB = 0 THEN MB_UP = -1: MB_UP_SX = MX: MB_UP_SY = MY
    MB_DOWN = 0: IF omb = 0 AND MB <> 0 THEN MB_DOWN = -1: MB_DOWN_SX = MX: MB_DOWN_SY = MY

    MDRAG_BEGIN = 0
    IF MB THEN
        IF ABS(MX - MB_DOWN_SX) > 1 OR ABS(MY - MB_DOWN_SY) > 1 THEN
            IF MDRAG = 0 THEN
                MDRAG = -1
                MDRAG_BEGIN = -1

                '                MDRAG_BEGIN_SX = MX: MDRAG_BEGIN_SY = MY


                IF ABS(MX - MB_DOWN_SX) > 3 OR ABS(MY - MB_DOWN_SY) > 3 THEN 'imprecise
                    MDRAG_BEGIN_SX = MB_DOWN_SX: MDRAG_BEGIN_SY = MB_DOWN_SY
                ELSE
                    'precise, move from initial drag position
                    MDRAG_BEGIN_SX = MX: MDRAG_BEGIN_SY = MY
                END IF



            END IF
        END IF
    END IF



    MPosI = 0




    base_grid = root_grid

    sgi = 1
    sai = 1

    stack(sgi).Grid = base_grid
    stack(sgi).base_x = 0
    stack(sgi).base_y = 0


    'scan grid on stack





    enter_new_grid:

    stack(sgi).oy = stack(sgi).base_y
    stack(sgi).row = 1
    stack(sgi).col = 1
    stack(sgi).area = Grid(stack(sgi).Grid).First_Area


    DO
        stack(sgi).ox = stack(sgi).base_x
        DO
            'PRINT sgi, stack(sgi).row; stack(sgi).col, stack(sgi).ox; stack(sgi).oy





            'get temp area metrics
            a = stack(sgi).area
            x = Section(Area(a).Width_Section).Size_Pixels
            y = Section(Area(a).Height_Section).Size_Pixels
            sox = stack(sgi).ox: soy = stack(sgi).oy
            ox = sox - stack(sgi).base_x
            oy = soy - stack(sgi).base_y



            '        LOOP UNTIL stack(sgi).row > Grid(stack(sgi).Grid).Rows
            '        stack(sgi).row = 1: stack(sgi).col = stack(sgi).col + 1
            '            stack(sgi).oy = stack(sgi).oy + y
            '        LOOP UNTIL stack(sgi).col > Grid(stack(sgi).Grid).Columns

            IF M_OVER_EDGE THEN
                IF stack(sgi).Grid = M_OVER_EDGE_GRID THEN
                    Get_Grid_Size stack(sgi).Grid, gsx, gsy
                    IF (stack(sgi).row - 1) = M_OVER_EDGE_X THEN
                        LINE (stack(sgi).ox, stack(sgi).base_y)-(stack(sgi).ox, stack(sgi).base_y + gsy - 1), _RGBA(255, 255, 255, 255)
                    END IF
                    IF stack(sgi).row = M_OVER_EDGE_X THEN
                        LINE (stack(sgi).ox + x - 1, stack(sgi).base_y)-(stack(sgi).ox + x - 1, stack(sgi).base_y + gsy - 1), _RGBA(255, 255, 255, 255)
                    END IF
                    IF (stack(sgi).col - 1) = M_OVER_EDGE_Y THEN
                        LINE (stack(sgi).base_x, stack(sgi).oy)-(stack(sgi).base_x + gsx - 1, stack(sgi).oy), _RGBA(255, 255, 255, 255)
                    END IF
                    IF stack(sgi).col = M_OVER_EDGE_Y THEN
                        LINE (stack(sgi).base_x, stack(sgi).oy + y - 1)-(stack(sgi).base_x + gsx - 1, stack(sgi).oy + y - 1), _RGBA(255, 255, 255, 255)
                    END IF
                END IF
            END IF


            IF M_OVER_EDGE2 THEN
                IF stack(sgi).Grid = M_OVER_EDGE_GRID2 THEN
                    Get_Grid_Size stack(sgi).Grid, gsx, gsy
                    IF (stack(sgi).row - 1) = M_OVER_EDGE_X2 THEN
                        LINE (stack(sgi).ox, stack(sgi).base_y)-(stack(sgi).ox, stack(sgi).base_y + gsy - 1), _RGBA(0, 255, 0, 255)
                    END IF
                    IF stack(sgi).row = M_OVER_EDGE_X2 THEN
                        LINE (stack(sgi).ox + x - 1, stack(sgi).base_y)-(stack(sgi).ox + x - 1, stack(sgi).base_y + gsy - 1), _RGBA(0, 255, 0, 255)
                    END IF
                    IF (stack(sgi).col - 1) = M_OVER_EDGE_Y2 THEN
                        LINE (stack(sgi).base_x, stack(sgi).oy)-(stack(sgi).base_x + gsx - 1, stack(sgi).oy), _RGBA(0, 255, 0, 255)
                    END IF
                    IF stack(sgi).col = M_OVER_EDGE_Y2 THEN
                        LINE (stack(sgi).base_x, stack(sgi).oy + y - 1)-(stack(sgi).base_x + gsx - 1, stack(sgi).oy + y - 1), _RGBA(0, 255, 0, 255)
                    END IF
                END IF
            END IF





            'create image if necessary

            update = 0

            IF Area(a).Image = 0 THEN
                IF x < 1 OR y < 1 THEN Area(a).Image = _NEWIMAGE(1, 1): Area(a).Composite_Image = _NEWIMAGE(1, 1) ELSE Area(a).Image = _NEWIMAGE(x, y): Area(a).Composite_Image = _NEWIMAGE(x, y)
                update = 1
            ELSE
                IF x <> _WIDTH(Area(a).Image) OR y <> _HEIGHT(Area(a).Image) THEN
                    _FREEIMAGE Area(a).Image: _FREEIMAGE Area(a).Composite_Image
                    IF x < 1 OR y < 1 THEN Area(a).Image = _NEWIMAGE(1, 1): Area(a).Composite_Image = _NEWIMAGE(1, 1) ELSE Area(a).Image = _NEWIMAGE(x, y): Area(a).Composite_Image = _NEWIMAGE(x, y)
                    update = 1
                END IF
            END IF

            IF update THEN
                _DEST Area(a).Image
                LINE (x \ 4, y \ 4)-STEP(x \ 2, y \ 2), Area(a).Col, BF
                CIRCLE (x \ 2, y \ 2), x \ 2, Area(a).Col
                CIRCLE (x \ 2, y \ 2), y \ 2, Area(a).Col
                LINE (0, 0)-(x - 1, y - 1), Area(a).Col, B

                _DEST 0
            END IF




            '            PRINT sox, soy, x, y
            'record mouse location within area
            IF MX >= sox AND MX <= (sox + x - 1) THEN
                IF MY >= soy AND MY <= (soy + y - 1) THEN
                    MPosI = MPosI + 1
                    i = MPosI
                    MPos(i).Area = a: MPos(i).Ax = MX - sox: MPos(i).Ay = MY - soy
                    MPos(i).Gx = MX - sox + ox: MPos(i).Gy = MY - soy + oy
                END IF
            END IF



            '            MPosI=




            'inherit parent image (if it exists)
            IF sgi > 1 THEN
                '*****assume an update on the parent occurred******
                psgi = sgi - 1
                pa = stack(psgi).area
                'pox = stack(psgi).ox - stack(psgi).base_x
                'poy = stack(psgi).oy - stack(psgi).base_y
                'px = Section(Area(pa).Width_Section).Size_Pixels
                'py = Section(Area(pa).Height_Section).Size_Pixels

                '       PRINT pox; poy; Area(pa).Composite_Image

                _DONTBLEND Area(a).Composite_Image
                _PUTIMAGE (-ox, -oy), Area(pa).Composite_Image, Area(a).Composite_Image
                _BLEND Area(a).Composite_Image
                'apply parent's image onto parent composite to form our composite
                _PUTIMAGE (-ox, -oy), Area(pa).Image, Area(a).Composite_Image

                '        CLS
                '         PRINT RND * 10
                '          _PUTIMAGE (0, 0), Area(pa).Image
                '           PRINT ox, oy


                '            SLEEP

            ELSE




            END IF






            ox = stack(sgi).ox
            oy = stack(sgi).oy

            'assume we are the highest point on the tree



            'LINE (ox, oy)-STEP(x - 1, y - 1), Area(stack(sgi).area).Col, BF
            'LINE (ox, oy)-STEP(x - 1, y - 1), , B
            'SLEEP

            'does this area have an image and composite image? if not create one


            IF Area(stack(sgi).area).Child_Grid THEN
                osgi = sgi
                sgi = sgi + 1
                stack(sgi).Grid = Area(stack(osgi).area).Child_Grid
                stack(sgi).base_x = stack(osgi).ox
                stack(sgi).base_y = stack(osgi).oy

                GOTO enter_new_grid
                backstep:

            ELSE
                'no child grid, so we are highest point
                _PUTIMAGE (ox, oy), Area(a).Composite_Image
                _PUTIMAGE (ox, oy), Area(a).Image

            END IF



            'get temp area metrics
            x = Section(Area(stack(sgi).area).Width_Section).Size_Pixels
            y = Section(Area(stack(sgi).area).Height_Section).Size_Pixels


            stack(sgi).ox = stack(sgi).ox + x
            stack(sgi).area = Area(stack(sgi).area).Next_Area
            stack(sgi).row = stack(sgi).row + 1
        LOOP UNTIL stack(sgi).row > Grid(stack(sgi).Grid).Rows
        stack(sgi).row = 1: stack(sgi).col = stack(sgi).col + 1
        stack(sgi).oy = stack(sgi).oy + y
    LOOP UNTIL stack(sgi).col > Grid(stack(sgi).Grid).Columns
    IF sgi > 1 THEN
        sgi = sgi - 1
        GOTO backstep
    END IF





    LOCATE 1, 1

    frame = frame + 1
    PRINT "frame:"; frame


    PRINT MX, MY, MPosI
    FOR i = 1 TO MPosI
        PRINT "MPOS:"; MPos(i).Area; "("; MPos(i).Ax; ","; MPos(i).Ay; ")"
    NEXT



    'in order to display correct cursor, current location should be scanned to see if it is next to a region
    M_OVER_EDGE = 0
    IF MPosI THEN
        i = MPosI
        44

        a = MPos(i).Area
        Get_Area_Size a, x, y
        ox = MPos(i).Ax
        oy = MPos(i).Ay
        gox = MPos(i).Gx
        goy = MPos(i).Gy

        'how far from borders of area
        xx = 0: yy = 0

        IF ox <= 1 THEN xx = -1
        IF ox >= x - 2 THEN xx = 1
        IF oy <= 1 THEN yy = -1
        IF oy >= y - 2 THEN yy = 1
        PRINT "border check:"; xx; yy

        IF xx <> 0 OR yy <> 0 THEN
            'is this border common to a parent area
            g = Area(a).Grid
            Get_Grid_Size g, gx, gy
            xx2 = 0: yy2 = 0

            PRINT gox, goy

            IF gox <= 1 THEN xx2 = -1
            IF gox >= gx - 2 THEN xx2 = 1
            IF goy <= 1 THEN yy2 = -1
            IF goy >= gy - 2 THEN yy2 = 1

            PRINT "parent grid border check:"; xx2; yy2

            IF xx2 <> 0 OR yy2 <> 0 THEN
                IF Grid(g).Parent_Area = 0 THEN
                    PRINT "Edge of root frame!"
                    GOTO 99
                ELSE
                    'backtrace
                    i = i - 1
                    GOTO 44


                END IF
            END IF
            'record which edge this is for future highlighting and changes
            M_OVER_EDGE = -1
            M_OVER_EDGE_GRID = g

            M_OVER_EDGE_X = -1
            x = 0: n = 0
            s = Grid(g).First_Width_Section
            DO

                IF gox >= x - 2 AND gox <= x + 1 THEN M_OVER_EDGE_X = n: EXIT DO
                x = x + Section(s).Size_Pixels: n = n + 1
                s = Section(s).Next_Section
            LOOP WHILE s
            PRINT M_OVER_EDGE_X



            M_OVER_EDGE_Y = -1
            y = 0: n = 0
            s = Grid(g).First_Height_Section
            DO

                IF goy >= y - 2 AND goy <= y + 1 THEN M_OVER_EDGE_Y = n: EXIT DO
                y = y + Section(s).Size_Pixels: n = n + 1
                s = Section(s).Next_Section
            LOOP WHILE s
            PRINT M_OVER_EDGE_Y


            '            M_OVER_EDGE_X = 123 '0=lhs, 1=rhs of first section, etc







        END IF





    END IF
    99




    IF MB_DOWN THEN
        IF MPosI THEN
            i = MPosI
            MB_DOWN_AREA = MPos(i).Area
            MB_DOWN_Ax = MPos(i).Ax
            MB_DOWN_Ay = MPos(i).Ay

            FOR i2 = 1 TO MPosI: MB_DOWN_MPos(i2) = MPos(i2): NEXT: MB_DOWN_MPosI = MPosI

        ELSE
            MB_DOWN_AREA = 0
        END IF
    END IF

    CLICK = 0
    IF MB_UP THEN
        IF MDRAG = 0 THEN
            CLICK = -1








        END IF
    END IF

    IF MDRAG_BEGIN THEN
        '        PRINT "*********************"














        M_OVER_EDGE2 = 0
        IF MPosI THEN
            i = MB_DOWN_MPosI
            442

            a = MB_DOWN_MPos(i).Area
            Get_Area_Size a, x, y
            ox = MB_DOWN_MPos(i).Ax
            oy = MB_DOWN_MPos(i).Ay
            gox = MB_DOWN_MPos(i).Gx
            goy = MB_DOWN_MPos(i).Gy

            'how far from borders of area
            xx = 0: yy = 0

            IF ox <= 1 THEN xx = -1
            IF ox >= x - 2 THEN xx = 1
            IF oy <= 1 THEN yy = -1
            IF oy >= y - 2 THEN yy = 1
            PRINT "border check:"; xx; yy

            IF xx <> 0 OR yy <> 0 THEN
                'is this border common to a parent area
                g = Area(a).Grid
                Get_Grid_Size g, gx, gy
                xx2 = 0: yy2 = 0

                PRINT gox, goy

                IF gox <= 1 THEN xx2 = -1
                IF gox >= gx - 2 THEN xx2 = 1
                IF goy <= 1 THEN yy2 = -1
                IF goy >= gy - 2 THEN yy2 = 1

                PRINT "parent grid border check:"; xx2; yy2

                IF xx2 <> 0 OR yy2 <> 0 THEN
                    IF Grid(g).Parent_Area = 0 THEN
                        PRINT "Edge of root frame!"
                        GOTO 992
                    ELSE
                        'backtrace
                        i = i - 1
                        GOTO 442


                    END IF
                END IF
                'record which edge this is for future highlighting and changes
                M_OVER_EDGE2 = -1
                M_OVER_EDGE_GRID2 = g

                M_OVER_EDGE_X2 = -1
                x = 0: n = 0
                s = Grid(g).First_Width_Section
                DO

                    IF gox >= x - 2 AND gox <= x + 1 THEN M_OVER_EDGE_X2 = n: EXIT DO
                    x = x + Section(s).Size_Pixels: n = n + 1
                    s = Section(s).Next_Section
                LOOP WHILE s
                PRINT M_OVER_EDGE_X2



                M_OVER_EDGE_Y2 = -1
                y = 0: n = 0
                s = Grid(g).First_Height_Section
                DO

                    IF goy >= y - 2 AND goy <= y + 1 THEN M_OVER_EDGE_Y2 = n: EXIT DO
                    y = y + Section(s).Size_Pixels: n = n + 1
                    s = Section(s).Next_Section
                LOOP WHILE s
                PRINT M_OVER_EDGE_Y2


                '            M_OVER_EDGE_X = 123 '0=lhs, 1=rhs of first section, etc







            END IF
        END IF

        992





















    END IF 'drag begin


    IF MDRAG THEN


        IF M_OVER_EDGE2 THEN
            PRINT "-----------drag displacement--------------------------"



            dx = MX - MDRAG_BEGIN_SX
            dy = MY - MDRAG_BEGIN_SY
            PRINT dx, dy, MDRAG_BEGIN_SX


            PRINT "-------------------------------------"
            _DISPLAY


            'assume some stuff to make life easier:
            'horizontal movement

            'collapse method right, expand method left

            g = M_OVER_EDGE_GRID2

            IF M_OVER_EDGE_X2 <> -1 AND dx <> 0 THEN
                z = M_OVER_EDGE_X2
                n = Grid(g).Rows


                dx2 = dx
                DO WHILE dx2
                    IF dx2 > 0 THEN dx = 1 ELSE dx = -1
                    dx2 = dx2 - dx

                    IF dx > 0 THEN
                        FOR test = 1 TO 0 STEP -1
                            ok = 1
                            s = Grid(g).First_Width_Section
                            FOR i = 1 TO n
                                IF i = z + 1 THEN

                                    newsize = Section(s).Size_Pixels - dx

                                    IF test THEN
                                        Section(s).Test_Size_Pixels = newsize
                                    ELSE
                                        Section(s).Size_Pixels = newsize
                                    END IF


                                    FOR i2 = 1 TO Grid(g).Columns
                                        a = Get_Area(g, i, i2)
                                        g2 = Area(a).Child_Grid
                                        IF g2 THEN
                                            ok2 = Resize_Grid(g2, -1, 0, -dx, test)



                                            IF ok2 = 0 THEN ok = 0: EXIT FOR
                                        END IF
                                    NEXT
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    'PRINT "OK="; ok
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    'ok = 1
                                    IF ok = 0 THEN EXIT FOR


                                END IF
                                IF i = z THEN


                                    newsize = Section(s).Size_Pixels + dx

                                    IF test THEN
                                        Section(s).Test_Size_Pixels = newsize
                                    ELSE
                                        Section(s).Size_Pixels = newsize
                                    END IF


                                    FOR i2 = 1 TO Grid(g).Columns
                                        a = Get_Area(g, i, i2)
                                        g2 = Area(a).Child_Grid
                                        IF g2 THEN
                                            ok2 = Resize_Grid(g2, 1, 0, dx, test)
                                            IF ok2 = 0 THEN ok = 0: EXIT FOR
                                        END IF
                                    NEXT
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    'PRINT "OK_EXPAND="; ok
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    IF ok = 0 THEN EXIT FOR



                                END IF
                                s = Section(s).Next_Section
                            NEXT

                            IF test = 0 AND ok = 0 THEN END

                            IF ok = 0 THEN EXIT FOR

                            IF test = 0 THEN MDRAG_BEGIN_SX = MDRAG_BEGIN_SX + dx
                        NEXT test



                    END IF 'dx>0





                    IF dx < 0 THEN

                        FOR test = 1 TO 0 STEP -1
                            ok = 1
                            s = Grid(g).First_Width_Section
                            FOR i = 1 TO n
                                IF i = z THEN

                                    newsize = Section(s).Size_Pixels - ABS(dx)

                                    IF test THEN
                                        Section(s).Test_Size_Pixels = newsize
                                    ELSE
                                        Section(s).Size_Pixels = newsize
                                    END IF


                                    FOR i2 = 1 TO Grid(g).Columns
                                        a = Get_Area(g, i, i2)
                                        g2 = Area(a).Child_Grid
                                        IF g2 THEN
                                            ok2 = Resize_Grid(g2, 1, 0, -ABS(dx), test)
                                            IF ok2 = 0 THEN ok = 0: EXIT FOR
                                        END IF
                                    NEXT
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    'PRINT "OK="; ok
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    IF ok = 0 THEN EXIT FOR


                                END IF
                                IF i = z + 1 THEN



                                    newsize = Section(s).Size_Pixels + ABS(dx)

                                    IF test THEN
                                        Section(s).Test_Size_Pixels = newsize
                                    ELSE
                                        Section(s).Size_Pixels = newsize
                                    END IF


                                    FOR i2 = 1 TO Grid(g).Columns
                                        a = Get_Area(g, i, i2)
                                        g2 = Area(a).Child_Grid
                                        IF g2 THEN
                                            ok2 = Resize_Grid(g2, -1, 0, ABS(dx), test)
                                            IF ok2 = 0 THEN ok = 0: EXIT FOR
                                        END IF
                                    NEXT
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    'PRINT "OK_EXPAND="; ok
                                    'PRINT "&&&&&&&&&&&&&&&&&&&&&&&&&"
                                    IF ok = 0 THEN EXIT FOR







                                END IF
                                s = Section(s).Next_Section
                            NEXT
                            IF ok = 0 THEN EXIT FOR

                            IF test = 0 THEN MDRAG_BEGIN_SX = MDRAG_BEGIN_SX + dx

                        NEXT test



                    END IF 'dx<0







                LOOP







            END IF











        END IF







    END IF
    IF MB_UP THEN MDRAG = 0: M_OVER_EDGE2 = 0


    _DISPLAY
    _LIMIT 10
LOOP 'main loop
















END


oy = 0
FOR y2 = 1 TO y
    ox = 0

    FOR x2 = 1 TO x

        p = Get_Area(g, x2, y2)
        sx = Area(p).Width_Section: px = Section(sx).Size_Pixels
        sy = Area(p).Height_Section: py = Section(sy).Size_Pixels
        'PRINT oy;

        LINE (ox, oy)-(ox + px - 1, oy + py - 1), , B





        ox = ox + px
    NEXT

    oy = oy + py
NEXT





FUNCTION Section_Min_Pixels (s, Grid_Size_Pixels)
    pixels = Section(s).Min_Pixels
    percent! = Section(s).Min_Percent
    min = pixels
    IF percent! THEN
        pixels = Grid_Size_Pixels * percent!
        p! = Grid_Size_Pixels * percent! / 100
        IF INT(p!) = p! THEN
            pixels = p!
            IF pixels = 0 THEN min2 = 1
        ELSE
            pixels = INT(p!) + 1
        END IF
        IF pixels > min THEN min = pixels
    END IF
    Section_Min_Pixels = min
END FUNCTION

FUNCTION Section_Max_Pixels (s, Grid_Size_Pixels)
    pixels = Section(s).Max_Pixels
    percent! = Section(s).Max_Percent
    max = pixels
    IF percent! THEN
        pixels = Grid_Size_Pixels * percent!
        p! = Grid_Size_Pixels * percent! / 100
        IF INT(p!) = p! THEN
            pixels = p!
            IF pixels = 0 THEN min2 = 1
        ELSE
            pixels = INT(p!) + 1
        END IF
        IF max THEN
            IF pixels < max THEN max = pixels
        ELSE
            max = pixels
        END IF
    END IF
    IF max = 0 THEN max = 10000000
    Section_Max_Pixels = max
END FUNCTION




FUNCTION Resize_Grid (g, Side_X, Side_Y, Dif_Pixels, Test) 'neg. Dif_Pixels implies shrink
    Pixels = ABS(Dif_Pixels)

    'get parent area's size (or test size)
    pa = Grid(g).Parent_Area
    IF Test THEN
        pa_size = Section(Area(pa).Width_Section).Test_Size_Pixels
    ELSE
        pa_size = Section(Area(pa).Width_Section).Size_Pixels
    END IF



    IF Dif_Pixels > 0 THEN

        Num_Pixels = Pixels
        n = Grid(g).Rows

        IF Side_X = -1 THEN starti = 1: stopi = n: stepi = 1
        IF Side_X = 1 THEN starti = n: stopi = 1: stepi = -1

        FOR i = starti TO stopi STEP stepi
            s = Get_Grid_Section(g, i, 0)
            max = Section_Max_Pixels(s, pa_size)
            size = Section(s).Size_Pixels
            IF Test THEN Section(s).Test_Size_Pixels = size
            dif = max - size
            IF dif > 0 THEN 'can expand?
                IF Num_Pixels <= dif THEN
                    IF Test THEN
                        Section(s).Test_Size_Pixels = size + Num_Pixels: Num_Pixels = 0
                    ELSE
                        Section(s).Size_Pixels = size + Num_Pixels: Num_Pixels = 0
                    END IF
                ELSE
                    IF Test THEN
                        Section(s).Test_Size_Pixels = size + dif: Num_Pixels = Num_Pixels - dif
                    ELSE
                        Section(s).Size_Pixels = size + dif: Num_Pixels = Num_Pixels - dif
                    END IF
                END IF


                FOR i2 = 1 TO Grid(g).Columns
                    a = Get_Area(g, i, i2)
                    g2 = Area(a).Child_Grid
                    IF g2 THEN
                        ok = Resize_Grid(g2, Side_X, Side_Y, dif, Test)
                        IF ok = 0 THEN EXIT FUNCTION
                    END IF
                NEXT


            END IF


        NEXT
        IF Num_Pixels THEN EXIT FUNCTION
    END IF













    IF Dif_Pixels < 0 THEN

        Num_Pixels = Pixels
        n = Grid(g).Rows

        IF Side_X = -1 THEN starti = 1: stopi = n: stepi = 1
        IF Side_X = 1 THEN starti = n: stopi = 1: stepi = -1

        '    PRINT "dsfjewfjqwlerfrewl"

        FOR i = starti TO stopi STEP stepi
            s = Get_Grid_Section(g, i, 0)
            min = Section_Min_Pixels(s, pa_size)
            size = Section(s).Size_Pixels

            '        PRINT ">>"; Num_Pixels



            IF Test THEN Section(s).Test_Size_Pixels = size
            dif = size - min
            IF dif > 0 THEN
                IF Num_Pixels <= dif THEN
                    IF Test THEN
                        Section(s).Test_Size_Pixels = size - Num_Pixels: Num_Pixels = 0
                    ELSE
                        Section(s).Size_Pixels = size - Num_Pixels: Num_Pixels = 0
                    END IF
                ELSE
                    IF Test THEN
                        Section(s).Test_Size_Pixels = size - dif: Num_Pixels = Num_Pixels - dif
                    ELSE
                        Section(s).Size_Pixels = size - dif: Num_Pixels = Num_Pixels - dif
                    END IF
                END IF

                '            PRINT "<<"; Num_Pixels


                FOR i2 = 1 TO Grid(g).Columns
                    a = Get_Area(g, i, i2)
                    g2 = Area(a).Child_Grid
                    IF g2 THEN
                        ok = Resize_Grid(g2, Side_X, Side_Y, -dif, Test)
                        IF ok = 0 THEN EXIT FUNCTION
                    END IF
                NEXT


            END IF


        NEXT
        IF Num_Pixels THEN EXIT FUNCTION




    END IF


    Resize_Grid = -1
END FUNCTION


SUB Get_Grid_Size (g, x, y)
    x = 0
    s = Grid(g).First_Width_Section
    DO
        x = x + Section(s).Size_Pixels
        s = Section(s).Next_Section
    LOOP WHILE s
    y = 0
    s = Grid(g).First_Height_Section
    DO
        y = y + Section(s).Size_Pixels
        s = Section(s).Next_Section
    LOOP WHILE s
END SUB

SUB Get_Area_Size (a, x, y)
    x = Section(Area(a).Width_Section).Size_Pixels
    y = Section(Area(a).Height_Section).Size_Pixels
END SUB


SUB Init_Grid (g)

    x = Grid(g).Rows
    y = Grid(g).Columns

    'calculate metrics
    '-get parent area metrics

    'get metrics of parent area
    pa = Grid(g).Parent_Area

    psx = Area(pa).Width_Section
    psy = Area(pa).Height_Section
    px = Section(psx).Size_Pixels
    py = Section(psy).Size_Pixels
    PRINT px, py

    'parent metrics rules
    '1) set size to minimums (pixels or %, whatever is larger)
    '2) if it works, find ideal ratios and expand to ideal ratios



    TYPE si_type
        ideal AS LONG
        dif AS LONG
        dif_min AS LONG
        dif_max AS LONG
        new_size AS LONG
    END TYPE
    DIM si(1000) AS si_type




    FOR axis = 1 TO 2

        IF axis = 1 THEN n = x: ps = px ELSE n = y: ps = py


        flex = ps

        'calc ratio sum ---> all must have a ratio

        ratio_sum! = 0
        FOR i = 1 TO n
            IF axis = 1 THEN s = Get_Grid_Section(g, i, 0)
            IF axis = 2 THEN s = Get_Grid_Section(g, 0, i)

            ratio_sum! = ratio_sum! + Section(s).Ideal_Ratio
        NEXT
        PRINT ratio_sum!

        size = 0

        FOR i = 1 TO n

            IF axis = 1 THEN s = Get_Grid_Section(g, i, 0)
            IF axis = 2 THEN s = Get_Grid_Section(g, 0, i)


            min = -1
            min1 = Section(s).Min_Pixels
            min2! = Section(s).Min_Percent
            IF min1 THEN
                min = min1
            END IF
            IF min2! THEN
                '% to pixels
                p! = ps * min2! / 100
                'always round upwards
                IF INT(p!) = p! THEN
                    min2 = p!
                    IF min2 = 0 THEN min2 = 1
                ELSE
                    min2 = INT(p!) + 1
                END IF

                IF min <> -1 THEN
                    IF min2 > min1 THEN min = min2
                ELSE
                    min = min2
                END IF
            END IF




            max = -1
            max1 = Section(s).Max_Pixels
            max2! = Section(s).Max_Percent
            IF max1 THEN
                max = max1
            END IF
            IF max2! THEN
                '% to pixels
                p! = ps * max2! / 100
                'always round upwards
                IF INT(p!) = p! THEN
                    max2 = p!
                    IF max2 = 0 THEN max2 = 1
                ELSE
                    max2 = INT(p!) + 1
                END IF

                IF max <> -1 THEN
                    IF max2 < max1 THEN max = max2
                ELSE
                    max = max2
                END IF
            END IF
            IF min THEN flex = flex - min

            ideal = INT((Section(s).Ideal_Ratio / ratio_sum!) * ps) 'int used to avoid section overflow




            PRINT min, max, ideal

            'log these values
            'how far is ideal from what is possible?
            dif = 0: dif_max = 999999: dif_min = -ideal
            IF min <> -1 THEN
                IF ideal < min THEN
                    dif = min - ideal
                    dif_min = dif
                ELSE
                    dif_min = -(ideal - min)
                END IF
            END IF

            IF max <> -1 THEN
                IF ideal > max THEN
                    dif = -(ideal - max)
                    dif_max = dif
                ELSE
                    dif_max = max - ideal
                END IF
            END IF



            PRINT "dif_min:"; dif_min; "dif:"; dif; "dif_max:"; dif_max



            si(i).ideal = ideal
            si(i).dif = dif
            si(i).dif_min = dif_min
            si(i).dif_max = dif_max

            size = size + (ideal - dif)

        NEXT
        PRINT flex

        PRINT size, ps

        'is size too big? if so scale down
        'size too big

        'is solution possible? no-->drop percentages

        'yes:

        'ideal+dif_range*scale  + ideal2+dif_range2*scale = ps
        'so...
        '(dif_range + dif_range2) * s = ps - ideal - ideal2

        'should this be percent away from ideal dif or distance from current dif


        dif_range_sum = 0
        ps2 = ps
        FOR i = 1 TO n
            dif_range = -(si(i).dif - si(i).dif_min)
            PRINT "dif_range:"; dif_range


            dif_range_sum = dif_range_sum + (-(si(i).dif - si(i).dif_min))



            ps2 = ps2 - (si(i).ideal + si(i).dif)
        NEXT
        s! = ps2 / dif_range_sum

        PRINT s!

        new_size_sum = 0

        FOR i = 1 TO n
            new_size = INT(si(i).ideal + si(i).dif + (-(si(i).dif - si(i).dif_min)) * s!)
            si(i).new_size = new_size
            new_size_sum = new_size_sum + new_size
            PRINT new_size;
        NEXT
        PRINT

        extra = ps - new_size_sum
        'because of resize, size may be less than required
        'the 0 rule

        '**********************remove this later************************
        si(1).new_size = si(1).new_size + extra

        FOR i = 1 TO n
            IF extra THEN
                IF si(i).new_size = 0 THEN
                    'if si(i).max

                END IF
            END IF
        NEXT
        'the anything else rule
        'etc.

        'assign new sizes

        FOR i = 1 TO n
            IF axis = 1 THEN s = Get_Grid_Section(g, i, 0)
            IF axis = 2 THEN s = Get_Grid_Section(g, 0, i)
            Section(s).Size_Pixels = si(i).new_size
        NEXT





    NEXT axis




END SUB

FUNCTION Get_Area (Parent_Grid, X, Y)
    a = Grid(Parent_Grid).First_Area
    n = (Y - 1) * Grid(Parent_Grid).Rows + X
    FOR i = 2 TO n
        a = Area(a).Next_Area
    NEXT
    Get_Area = a
END FUNCTION

FUNCTION Create_Grid (Parent_Area, X, Y)
    pa = Parent_Area
    g = Grid_New

    'link
    Grid(g).Parent_Area = pa
    Area(pa).Child_Grid = g

    Grid(g).Rows = X
    Grid(g).Columns = Y

    s = Section_New
    Grid(g).First_Width_Section = s
    Section(s).Ideal_Ratio = 1
    FOR n = 2 TO X
        s2 = Section_New
        Section(s).Next_Section = s2
        s = s2
        Section(s).Ideal_Ratio = 1
    NEXT

    s = Section_New
    Grid(g).First_Height_Section = s
    Section(s).Ideal_Ratio = 1
    FOR n = 2 TO Y
        s2 = Section_New
        Section(s).Next_Section = s2
        s = s2
        Section(s).Ideal_Ratio = 1
    NEXT

    'create empty area structures
    a2 = -1
    FOR y2 = 1 TO Y
        IF y2 = 1 THEN sy = Grid(g).First_Height_Section ELSE sy = Section(sy).Next_Section
        FOR x2 = 1 TO X
            IF x2 = 1 THEN sx = Grid(g).First_Width_Section ELSE sx = Section(sx).Next_Section
            a = Area_New
            IF a2 = -1 THEN Grid(g).First_Area = a ELSE Area(a2).Next_Area = a
            a2 = a
            Area(a).Grid = g: Area(a).Width_Section = sx: Area(a).Height_Section = sy
        NEXT
    NEXT


    'get metrics of parent area
    'xs = Area(Parent_Area).Width_Section_Id
    'ys = Area(Parent_Area).Height_Section_Id
    Create_Grid = g



END FUNCTION



FUNCTION Grid_New
    Grids = Grids + 1
    Grid(Grids) = Empty_Grid
    Grid_New = Grids
END FUNCTION

FUNCTION Section_New
    Sections = Sections + 1
    Section(Sections) = Empty_Section
    Section_New = Sections
END FUNCTION

FUNCTION Area_New
    Areas = Areas + 1
    Area(Areas).Col = _RGBA(RND * 255, RND * 255, RND * 255, 128)
    Area_New = Areas
END FUNCTION

FUNCTION Get_Grid_Section (grid, x, y)
    IF x THEN s = Grid(grid).First_Width_Section: n = x ELSE s = Grid(grid).First_Height_Section: n = y
    FOR n2 = 2 TO n
        s = Section(s).Next_Section
    NEXT
    Get_Grid_Section = s
END FUNCTION


