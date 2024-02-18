
'FOR SAVEMAP ----------------------------------
TYPE MAP_HEAD
    Identity AS STRING * 5
    Nr_of_Textures AS LONG
    Nr_of_Vertexes AS LONG
    DataStart AS LONG
    VertexStart AS LONG
END TYPE


TYPE Vertex
    Flag AS _UNSIGNED _BYTE
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




TYPE Object

    X AS SINGLE
    Y AS SINGLE
    Z AS SINGLE

    s AS LONG 'start record
    e AS LONG 'end record
    radius AS SINGLE
    radiusZ AS SINGLE
    PI AS SINGLE
END TYPE

TYPE mini
    L AS LONG
    Nr AS LONG
END TYPE

TYPE coordinates
    Xs AS LONG
    Ys AS LONG
    Xe AS LONG
    Ye AS LONG
    S AS LONG
    K AS LONG
END TYPE





REDIM SHARED ZDI(0) AS coordinates
REDIM SHARED MP(0) AS mini
REDIM SHARED OBJECT(0) AS Object


CONST CUBE = 1
CONST ZEM = 2
CONST ZED = 3
CONST ZIDLE = 4
CONST DOHLEDNOST = 60
CONST DRUNKMODE = 0 ' :-D Try set to 1, if you study this source




lX = 10: lY = 10: rXx = 310: rY = 10
ballX = 160: ballY = 10: mY = -1: IF RND * 10 > 5 THEN mX = 1 ELSE mX = -1
DIM SHARED dub AS LONG, aluminium AS LONG, radius AS DOUBLE

DIM SHARED RedColor AS LONG

tokno& = white
RedColor = RED




REDIM SHARED ColisMap(0, 0) AS LONG
DIM SHARED N
SCREEN _NEWIMAGE(_DESKTOPWIDTH, _DESKTOPHEIGHT, 32)

CX = 0: CY = 0: CZ = -1 '                                                          rotation center point - CAMERA



TYPE V
    X AS SINGLE '                                                                  source X points in standard view
    Y AS SINGLE '                                                                  source Y points in standard view
    Z AS SINGLE '                                                                  not use yet
    pi AS SINGLE '                                                                 start draw position on radius
    piH AS SINGLE '                                                                pi for point on circle circuit position for look up / dn
    piX AS SINGLE
    Radius AS SINGLE '                                                             radius (every point use own, but if is CX and CY in middle, are all the same)
    RadiusH AS SINGLE '                                                            radius floor / ceiling
    RadiusX AS SINGLE
    wX AS SINGLE '                                                                 working coordinates X
    wY AS SINGLE '                                                                 Y axis
    wZ AS SINGLE '                                                                 first Z. Used for view in previous program
    wZ2 AS SINGLE '                                                                second Z calculated from wZ
    T AS LONG '                                                                    texture number for current triangle
    Tm AS SINGLE '                                                                 texture multiplicier. 1 for one.
END TYPE

N = 0
DIM SHARED v(N) AS V
REDIM SHARED v2(0) AS V

DIM SHARED OldMouseX AS INTEGER, OldMouseY AS INTEGER
WHILE _MOUSEINPUT: WEND
_FULLSCREEN
_MOUSEMOVE _DESKTOPWIDTH / 2, _DESKTOPHEIGHT / 2
OldMouseX = _DESKTOPWIDTH / 2
OldMouseY = _DESKTOPHEIGHT / 2

_MOUSEHIDE


IF COMMAND$ <> "" THEN
    IF LCASE$(RIGHT$(COMMAND$, 4)) = ".map" THEN LOAD_MAP "map/" + COMMAND$ ELSE LOAD_MAP "map/" + COMMAND$ + ".map"
ELSE LOAD_MAP "map/demo000.map"
END IF


'pro nacteni textur objektu pouzij PMF rozbalene do podslozky TEXTURES
REM kostka = NEWOBJECT(CUBE, 12, 0, 14)
REM zidle0 = NEWOBJECT(ZIDLE, 12, 0, 14)
REM zidle1 = NEWOBJECT(ZIDLE, 40, 1, 25)
REM zidle2 = NEWOBJECT(ZIDLE, 76, 0, 11)
REM XZ_ROTATE zidle2, 5

_DISPLAYORDER _HARDWARE , _SOFTWARE

'on map start positions (PosY = 0)
posX = -5
posZ = -5


DO

    REM    room1Vol = VolumeAgent(12, 10, CX, CZ, 50)
    REM    _SNDVOL sount&, room1Vol

    REM IF room1Vol = 0 THEN _SNDVOL sount&, VolumeAgent(42, 20, CX, CZ, 50)

    IF DRUNKMODE THEN
        LOOPCOUNT = LOOPCOUNT + 1
        IF LOOPCOUNT MOD 2 = 0 THEN Select_Visible: LOOPCOUNT = 0
    ELSE
        Select_Visible
        IF Start = 0 THEN Find_Walls ZDI(): Start = 1
    END IF


    FOR r = LBOUND(v2) TO UBOUND(v2)
        LenX = v2(r).X - CX '                                                           calculate line lenght between CX and X - point (X1, X2...)
        LenY = v2(r).Y - CY
        LenZ = v2(r).Z - CZ '                                                           calculate line lenght between CY (center Y) and Y - point

        radius = SQR(LenX ^ 2 + LenZ ^ 2) '                                            calculate radius using Pythagoras
        radiusH = SQR(LenY ^ 2 + LenZ ^ 2)
        v2(r).Radius = radius
        v2(r).RadiusH = radiusH
        IF v2(r).pi = 0 THEN v2(r).pi = JK(CX, CZ, v2(r).X, v2(r).Z, radius) ' point on circle calculation based on binary circle    https://matematika.cz/jednotkova-kruznice,  this is for X / Z rotation
    NEXT r

    IF ABS(rot) > _PI(2) THEN rot = 0

    oldposZ = posZ
    oldposX = posX




    'upgrade: add mouse support!
    WHILE _MOUSEINPUT: WEND
    rot = rot + MOUSEMOVEMENTX / 20 '                                                      rot is move rotation X / Z
    roth = roth + MOUSEMOVEMENTY / 20 '

    IF roth > _PI / 3 THEN roth = _PI / 3 '                                                roth is rotation for Y / Z (look up and down)
    IF roth < -_PI / 3 THEN roth = -_PI / 3


    i$ = INKEY$
    SELECT CASE i$
        CASE CHR$(0) + CHR$(72): posZ = posZ + COS(rot) / 2: posX = posX - SIN(rot) / 2
        CASE CHR$(0) + CHR$(80): posZ = posZ - COS(rot) / 2: posX = posX + SIN(rot) / 2
        CASE CHR$(0) + CHR$(77): posZ = posZ + COS(rot + _PI / 2): posX = posX - SIN(rot + _PI / 2) ' sidestep
        CASE CHR$(0) + CHR$(75): posZ = posZ - COS(rot + _PI / 2): posX = posX + SIN(rot + _PI / 2) ' sidestep

        CASE "A", "a" '                look up/dn from keyboard
            roth = roth - .02
        CASE "Z", "z":
            roth = roth + .02
        CASE "S", "s": rotX = rotX - .02 ' rotace v ose X/Y
        CASE "X", "x": rotX = rotX + .02
        CASE CHR$(27): SYSTEM 'Destructor ("textures.pmf"): SYSTEM
    END SELECT
    IF _EXIT THEN SYSTEM 'Destructor ("textures.pmf")
    _KEYCLEAR

    'nova detekce kolize:

    'tohle na zdi necham, to funguje. Doplnim jeste nejakou obdelnikovou detekci pro konkretni objekty volane metodou NEWOBJECT
    IF ABS(posX) <> posX THEN
        IF ABS(posZ) <> posZ THEN


            IF oldposX > posX THEN xm = -.7
            IF oldposX < posX THEN xm = .7
            IF oldposZ > posZ THEN zm = -.7
            IF oldposZ < posZ THEN zm = .7
            ppx = _CEIL(ABS(posX + xm))
            ppy = _CEIL(ABS(posZ + zm))


            IF ppx > MAP_WIDTH THEN ppx = MAP_WIDTH: posX = oldposX
            IF ppy > MAP_HEIGHT THEN ppy = MAP_HEIGHT: posZ = oldposZ



            IF ColisMap(ppx, ppy) THEN posX = oldposX: posZ = oldposZ
        END IF
    END IF

    ggggg:

    IF _MOUSEBUTTON(1) THEN rot = rot - .02
    IF _MOUSEBUTTON(2) THEN rot = rot + .02

    CZ = -posZ 'This is very important. Note that you do not actually turn the camera in space, but you turn the space for camera.
    CX = -posX
    CY = -posy


    ' LOCATE 1, 1: PRINT MOUSEMOVEMENTX, MOUSEMOVEMENTY

    FOR r = LBOUND(v2) TO UBOUND(v2)

        x = CX + SIN(rot + v2(r).pi) * v2(r).Radius
        Z = CZ + COS(rot + v2(r).pi) * v2(r).Radius
        v2(r).wX = x + posX
        v2(r).wZ = Z '                   posZ is add later, after Z / Y calculation
        v2(r).wY = v2(r).Y + posy


        'STEP 2: rotate space for look to UP / DOWN (Z / Y) BUT USE CORRECT COORDINATES CALCULATED IN STEP 1 FOR ROTATION Z / X as in this program:


        LenY2 = v2(r).Y - CY
        LenZ2 = v2(r).wZ - CZ

        radiusH = SQR(LenY2 ^ 2 + LenZ2 ^ 2)
        v2(r).RadiusH = radiusH
        IF v2(r).piH = 0 THEN v2(r).piH = JK(CY, CZ, v2(r).Y, v2(r).wZ, radiusH) 'As you see here, JK! use previous calculated rotated coordinate wZ (working Z coordinate)
        z2 = CZ + COS(roth + v2(r).piH) * v2(r).RadiusH ' CX, CY, CZ is CAMERA. RadiusH is radius for point between floor and ceiling
        y2 = CY + SIN(roth + v2(r).piH) * v2(r).RadiusH

        'povolit, pokud je rotace jen Y/Z a X/Z
        v2(r).wY = y2 ' + posY      zakazano kvuli rotaci X/Y dal, jinak to povol a zakaz rotaci X/Y
        v2(r).wZ2 = z2 + posZ

        'extra - rotace X/Y (pro letecke simulatory napriklad):

        LenX3 = (v2(r).wX - posX) - CX
        LenY3 = v2(r).wY - CY
        radiusX = SQR(LenX3 ^ 2 + LenY3 ^ 2)
        v2(r).RadiusX = radiusX
        IF v2(r).piX = 0 THEN v2(r).piX = JK(CX, CY, (v2(r).wX - posX), (v2(r).wY), radiusX)
        x3 = CX + SIN(rotX + v2(r).piX) * v2(r).RadiusX
        y3 = CY + COS(rotX + v2(r).piX) * v2(r).RadiusX

        v2(r).wY = y3 + posy
        v2(r).wX = x3 + posX
        noX:
    NEXT r
    i$ = ""


    FOR zz = LBOUND(v2) + 1 TO UBOUND(v2) - 4 STEP 4
        IF v2(zz).T THEN

            img& = v2(zz).T
            w = _WIDTH(img&)
            h = _HEIGHT(img&)
            num = v2(zz).Tm
            IF num = 0 THEN num = 1
            _MAPTRIANGLE (0, h * num)-(w * num, h * num)-(0, 0), img& TO(v2(zz).wX, v2(zz).wY, v2(zz).wZ2)-(v2(zz + 1).wX, v2(zz + 1).wY, v2(zz + 1).wZ2)-(v2(zz + 2).wX, v2(zz + 2).wY, v2(zz + 2).wZ2), 0, _SMOOTHSHRUNK
            _MAPTRIANGLE (w * num, h * num)-(0, 0)-(w * num, 0), img& TO(v2(zz + 1).wX, v2(zz + 1).wY, v2(zz + 1).wZ2)-(v2(zz + 2).wX, v2(zz + 2).wY, v2(zz + 2).wZ2)-(v2(zz + 3).wX, v2(zz + 3).wY, v2(zz + 3).wZ2), 0, _SMOOTHSHRUNK
        END IF
    NEXT zz


    LINE (0, _DESKTOPHEIGHT)-(_DESKTOPWIDTH, _DESKTOPHEIGHT - 100), _RGB32(50, 50, 0), BF


    _DISPLAY
LOOP



SUB Select_Visible
    SHARED posX, posy, posZ, CX, CZ, rot, SEEZ
    i = 0: REDIM v2(0) AS V: j = 0
    T = TIMER
    REDIM V3(0) AS V
    REDIM MP(0) AS mini, v3 AS LONG
    DIM J AS LONG, I2 AS LONG, F AS LONG, DELTA AS LONG, mpi AS LONG, LenghtControl AS LONG ', LenX AS SINGLE, LenZ AS SINGLE, Lx AS SINGLE, L AS SINGLE, pi AS SINGLE, rCX AS LONG, rCZ AS LONG

    FOR F = LBOUND(OBJECT) + 1 TO UBOUND(OBJECT)
        LenX = OBJECT(F).X - CX
        LenZ = OBJECT(F).Z - CZ
        Lx = LenX * 1.7
        L = SQR(LenX ^ 2 + LenZ ^ 2)
        pi = JK!(CX, CZ, OBJECT(F).X, OBJECT(F).Z, L)
        rCX = OBJECT(F).X + SIN(rot + pi) * L
        rCZ = OBJECT(F).Z + COS(rot + pi) * L

        IF SQR((Lx * Lx) + (LenZ * LenZ)) < DOHLEDNOST THEN 'kruhova detekce
            i3 = UBOUND(v2)
            DELTA = OBJECT(F).e - OBJECT(F).s + 1
            IF DELTA > 1 THEN
                IF OBJECT(F).Z >= rCZ - 1 THEN
                    IF ABS(OBJECT(F).X - rCX) < DOHLEDNOST / 3 THEN
                        work = 1
                        IF work THEN
                            REDIM _PRESERVE v2(i3 + DELTA) AS V

                            J = (UBOUND(v2) - DELTA) + 1
                            Vzd = SQR(LenX * LenX + LenZ * LenZ)

                            REDIM _PRESERVE MP(mpi) AS mini
                            MP(mpi).Nr = F
                            MP(mpi).L = Vzd
                            mpi = mpi + 1
                            sh = 0

                            FOR I2 = OBJECT(F).s TO OBJECT(F).e
                                v2(J).X = v(I2).X
                                v2(J).Y = v(I2).Y
                                v2(J).Z = v(I2).Z
                                v2(J).pi = v(I2).pi
                                v2(J).piH = v(I2).piH
                                v2(J).piX = v(I2).piX
                                v2(J).Radius = v(I2).Radius
                                v2(J).RadiusH = v(I2).RadiusH
                                v2(J).RadiusX = v(I2).RadiusX
                                v2(J).wX = v(I2).wX
                                v2(J).wY = v(I2).wY
                                v2(J).wZ = v(I2).wZ
                                v2(J).wZ2 = v(I2).wZ2
                                v2(J).T = v(I2).T
                                v2(J).Tm = v(I2).Tm
                                J = J + 1
                            NEXT ' i2

                        END IF
                        skp:
                        u = u + 1
                    ELSE
                        unused = unused + 1

                    END IF
                ELSE unused = unused + 1


                END IF
            END IF
        END IF
    NEXT F
    LOCATE 2
    dofiltruj
END SUB





SUB dofiltruj
    EXIT SUB
    DIM A AS LONG, B AS LONG, I2 AS LONG, J AS LONG
    FOR A = LBOUND(MP) TO UBOUND(MP)
        PosZ = OBJECT(MP(A).Nr).Z
        Posx = OBJECT(MP(A).Nr).X
        L = MP(A).L

        pass = 0
        FOR B = LBOUND(MP) TO UBOUND(MP)
            PosZ2 = OBJECT(MP(B).Nr).Z
            Posx2 = OBJECT(MP(B).Nr).X
            LL = MP(B).L

            IF PosZ = PosZ2 AND Posx = Posx2 THEN
                IF L <= LL THEN pass = A
            END IF
        NEXT B

        IF pass THEN
            FOR I2 = OBJECT(MP(pass).Nr).s TO OBJECT(MP(pass).Nr).e
                J = J + 1
                REDIM _PRESERVE v2(J) AS V
                v2(J).X = v(I2).X
                v2(J).Y = v(I2).Y
                v2(J).Z = v(I2).Z
                v2(J).pi = v(I2).pi
                v2(J).piH = v(I2).piH
                v2(J).piX = v(I2).piX
                v2(J).Radius = v(I2).Radius
                v2(J).RadiusH = v(I2).RadiusH
                v2(J).RadiusX = v(I2).RadiusX
                v2(J).wX = v(I2).wX
                v2(J).wY = v(I2).wY
                v2(J).wZ = v(I2).wZ
                v2(J).wZ2 = v(I2).wZ2
                v2(J).T = v(I2).T
                v2(J).Tm = v(I2).Tm
            NEXT ' i2
        END IF

    NEXT A
    LOCATE 1, 1
END SUB


SUB Set_texture (num, start, eend, much)
    FOR s = start TO eend
        v(s).T = num
        v(s).Tm = much
    NEXT s
END SUB

FUNCTION Hload& (fileName AS STRING)
    h& = _LOADIMAGE(fileName$, 32)
    Hload& = _COPYIMAGE(h&, 33)
    _FREEIMAGE h&
END FUNCTION

FUNCTION SHload& (fileName AS STRING)
    h& = _LOADIMAGE(fileName$, 32)
    _SETALPHA 0, _RGB32(255, 255, 255) TO _RGB32(200, 200, 200), h&
    SHload& = _COPYIMAGE(h&, 33)
    _FREEIMAGE h&
END FUNCTION



FUNCTION JK! (cx, cy, px, py, R!)
    LenX! = cx - px
    LenY! = cy - py
    jR! = 1 / R!

    jX! = LenX! * jR!
    jY! = LenY! * jR!

    sinusAlfa! = jX!
    Alfa! = ABS(_ASIN(sinusAlfa!))

    Q = 1
    IF px >= cx AND py >= cy THEN Q = 1 ' select angle to quadrant
    IF px >= cx AND py <= cy THEN Q = 2
    IF px <= cx AND py <= cy THEN Q = 3
    IF px <= cx AND py >= cy THEN Q = 4
    SELECT CASE Q
        CASE 1: alfaB! = Alfa!
        CASE 2: alfaB! = _PI / 2 + (_PI / 2 - Alfa!)
        CASE 3: alfaB! = _PI + Alfa!
        CASE 4: alfaB! = _PI(1.5) + (_PI / 2 - Alfa!)
    END SELECT
    JK! = alfaB!
    IF alfaB! = 0 THEN BEEP
END FUNCTION


FUNCTION MOUSEMOVEMENTX
    SELECT CASE OldMouseX
        CASE IS > _MOUSEX: MOUSEMOVEMENTX = -1: _MOUSEMOVE OldMouseX, OldMouseY '= _MOUSEX
        CASE IS < _MOUSEX: MOUSEMOVEMENTX = 1: _MOUSEMOVE OldMouseX, OldMouseY '= _MOUSEX
        CASE ELSE: MOUSEMOVEMENTX = 0
    END SELECT
END FUNCTION

FUNCTION MOUSEMOVEMENTY
    SELECT CASE OldMouseY
        CASE IS > _MOUSEY: MOUSEMOVEMENTY = -1: _MOUSEMOVE OldMouseX, OldMouseY ' = _MOUSEY
        CASE IS < _MOUSEY: MOUSEMOVEMENTY = 1: _MOUSEMOVE OldMouseX, OldMouseY '= _MOUSEY
        CASE ELSE: MOUSEMOVEMENTY = 0
    END SELECT
END FUNCTION



SUB O_WALL (x, z, texture AS LONG, Wall_Typ)
    i = UBOUND(v)
    'pridam to jako objekt do pole objektu (modernizce 1B)

    SELECT CASE Wall_Typ 'urceni poctu vrcholu podle typu zdi
        CASE 1: Vr = 16 'samostatny blok zdi
        CASE 2, 3, 4, 5: Vr = 12
        CASE 6, 7: Vr = 8
        CASE 8: EXIT SUB
    END SELECT

    io = UBOUND(OBJECT) + 1
    REDIM _PRESERVE OBJECT(io) AS Object
    OBJECT(io).s = i + 1
    OBJECT(io).e = i + Vr
    OBJECT(io).X = x
    OBJECT(io).Y = 0
    OBJECT(io).Z = z '
    OBJECT(io).radius = SQR(0.5 ^ 2 + 0.5 ^ 2)



    REDIM _PRESERVE v(i + 16) AS V
    SELECT CASE Wall_Typ
        CASE 1

            v(i + 1).X = -.5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = .5 + z

            v(i + 2).X = .5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = .5 + z

            v(i + 3).X = -.5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = .5 + z

            v(i + 4).X = .5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = .5 + z


            'zadni stena
            v(i + 5).X = -.5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z - .5

            v(i + 6).X = .5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = -.5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z - .5

            v(i + 8).X = .5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5

            'levy bok
            v(i + 9).X = .5 + x
            v(i + 9).Y = -2
            v(i + 9).Z = z + .5

            v(i + 10).X = .5 + x
            v(i + 10).Y = -2
            v(i + 10).Z = z - .5

            v(i + 11).X = .5 + x
            v(i + 11).Y = 2
            v(i + 11).Z = z + .5

            v(i + 12).X = .5 + x
            v(i + 12).Y = 2
            v(i + 12).Z = z - .5

            'pravy bok
            v(i + 13).X = -.5 + x
            v(i + 13).Y = -2
            v(i + 13).Z = z + .5

            v(i + 14).X = -.5 + x
            v(i + 14).Y = -2
            v(i + 14).Z = z - .5

            v(i + 15).X = -.5 + x
            v(i + 15).Y = 2
            v(i + 15).Z = z + .5

            v(i + 16).X = -.5 + x
            v(i + 16).Y = 2
            v(i + 16).Z = z - .5

        CASE 2 'ok!

            'predni stena
            v(i + 1).X = .5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = .5 + z

            v(i + 2).X = -.5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = .5 + z

            v(i + 3).X = .5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = .5 + z

            v(i + 4).X = -.5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = .5 + z


            'zadni stena
            v(i + 5).X = .5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z - .5

            v(i + 6).X = -.5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = .5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z - .5

            v(i + 8).X = -.5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5

            'levy bok asi
            v(i + 9).X = .5 + x
            v(i + 9).Y = -2
            v(i + 9).Z = z + .5

            v(i + 10).X = .5 + x
            v(i + 10).Y = -2
            v(i + 10).Z = z - .5

            v(i + 11).X = .5 + x
            v(i + 11).Y = 2
            v(i + 11).Z = z + .5

            v(i + 12).X = .5 + x
            v(i + 12).Y = 2
            v(i + 12).Z = z - .5


        CASE 3


            v(i + 1).X = .5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = z + .5

            v(i + 2).X = .5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = z - .5

            v(i + 3).X = .5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = z + .5

            v(i + 4).X = .5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = z - .5

            'pravy bok
            v(i + 5).X = -.5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z + .5

            v(i + 6).X = -.5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = -.5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z + .5

            v(i + 8).X = -.5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5

            'predni stena
            v(i + 9).X = .5 + x
            v(i + 9).Y = -2
            v(i + 9).Z = .5 + z

            v(i + 10).X = -.5 + x
            v(i + 10).Y = -2
            v(i + 10).Z = .5 + z

            v(i + 11).X = .5 + x
            v(i + 11).Y = 2
            v(i + 11).Z = .5 + z

            v(i + 12).X = -.5 + x
            v(i + 12).Y = 2
            v(i + 12).Z = .5 + z


        CASE 4

            v(i + 1).X = .5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = .5 + z

            v(i + 2).X = -.5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = .5 + z

            v(i + 3).X = .5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = .5 + z

            v(i + 4).X = -.5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = .5 + z


            'zadni stena
            v(i + 5).X = .5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z - .5

            v(i + 6).X = -.5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = .5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z - .5

            v(i + 8).X = -.5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5

            'pravy bok
            v(i + 9).X = -.5 + x
            v(i + 9).Y = -2
            v(i + 9).Z = z + .5

            v(i + 10).X = -.5 + x
            v(i + 10).Y = -2
            v(i + 10).Z = z - .5

            v(i + 11).X = -.5 + x
            v(i + 11).Y = 2
            v(i + 11).Z = z + .5

            v(i + 12).X = -.5 + x
            v(i + 12).Y = 2
            v(i + 12).Z = z - .5

        CASE 5

            v(i + 1).X = .5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = z + .5

            v(i + 2).X = .5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = z - .5

            v(i + 3).X = .5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = z + .5

            v(i + 4).X = .5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = z - .5

            'pravy bok
            v(i + 5).X = -.5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z + .5

            v(i + 6).X = -.5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = -.5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z + .5

            v(i + 8).X = -.5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5

            'zadni stena
            v(i + 9).X = .5 + x
            v(i + 9).Y = -2
            v(i + 9).Z = z - .5

            v(i + 10).X = -.5 + x
            v(i + 10).Y = -2
            v(i + 10).Z = z - .5

            v(i + 11).X = .5 + x
            v(i + 11).Y = 2
            v(i + 11).Z = z - .5

            v(i + 12).X = -.5 + x
            v(i + 12).Y = 2
            v(i + 12).Z = z - .5









        CASE 6
            'texturovani opraveno
            'levy bok
            v(i + 1).X = .5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = z + .5

            v(i + 2).X = .5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = z - .5

            v(i + 3).X = .5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = z + .5

            v(i + 4).X = .5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = z - .5

            'pravy bok
            v(i + 5).X = -.5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z + .5

            v(i + 6).X = -.5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = -.5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z + .5

            v(i + 8).X = -.5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5





        CASE 7 'testovano, ok
            'asi predek

            v(i + 1).X = .5 + x
            v(i + 1).Y = -2
            v(i + 1).Z = .5 + z

            v(i + 2).X = -.5 + x
            v(i + 2).Y = -2
            v(i + 2).Z = .5 + z

            v(i + 3).X = .5 + x
            v(i + 3).Y = 2
            v(i + 3).Z = .5 + z

            v(i + 4).X = -.5 + x
            v(i + 4).Y = 2
            v(i + 4).Z = .5 + z


            'zadni stena
            v(i + 5).X = .5 + x
            v(i + 5).Y = -2
            v(i + 5).Z = z - .5

            v(i + 6).X = -.5 + x
            v(i + 6).Y = -2
            v(i + 6).Z = z - .5

            v(i + 7).X = .5 + x
            v(i + 7).Y = 2
            v(i + 7).Z = z - .5

            v(i + 8).X = -.5 + x
            v(i + 8).Y = 2
            v(i + 8).Z = z - .5



    END SELECT

    Set_texture texture&, i + 1, i + 16, 1
    N = N + 16
END SUB


SUB O_FLOOR (x, z, texture AS LONG)
    i = UBOUND(v)

    'pridat jako objekt
    io = UBOUND(OBJECT) + 1
    REDIM _PRESERVE OBJECT(io) AS Object
    OBJECT(io).s = i + 1 '         startovni pozice v poli V
    OBJECT(io).e = i + 4 '         koncova pozice v poli V
    OBJECT(io).X = x '             pozice podlahove krychle
    OBJECT(io).Y = y
    OBJECT(io).Z = z '
    OBJECT(io).radius = SQR(0.5 ^ 2 + 0.5 ^ 2)
    REDIM _PRESERVE v(i + 4) AS V
    'dno

    v(i + 1).X = -.5 + x
    v(i + 1).Y = -2
    v(i + 1).Z = z + .5

    v(i + 2).X = .5 + x
    v(i + 2).Y = -2
    v(i + 2).Z = z + .5

    v(i + 3).X = -.5 + x
    v(i + 3).Y = -2
    v(i + 3).Z = z - .5

    v(i + 4).X = .5 + x
    v(i + 4).Y = -2
    v(i + 4).Z = z - .5

    Set_texture texture&, i + 1, i + 4, 1
    N = N + 4
END SUB

SUB O_CEILING (x, z, texture AS LONG)
    i = UBOUND(v)

    'pridat jako objekt
    io = UBOUND(OBJECT) + 1
    REDIM _PRESERVE OBJECT(io) AS Object
    OBJECT(io).s = i + 1 '         startovni pozice v poli V
    OBJECT(io).e = i + 4 '         koncova pozice v poli V
    OBJECT(io).X = x '             pozice podlahove krychle
    OBJECT(io).Y = y
    OBJECT(io).Z = z '
    OBJECT(io).radius = SQR(0.5 ^ 2 + 0.5 ^ 2)

    REDIM _PRESERVE v(i + 4) AS V
    'dno

    v(i + 1).X = .5 + x
    v(i + 1).Y = 2
    v(i + 1).Z = z + .5

    v(i + 2).X = -.5 + x
    v(i + 2).Y = 2
    v(i + 2).Z = z + .5

    v(i + 3).X = .5 + x
    v(i + 3).Y = 2
    v(i + 3).Z = z - .5

    v(i + 4).X = -.5 + x
    v(i + 4).Y = 2
    v(i + 4).Z = z - .5

    Set_texture texture&, i + 1, i + 4, 1
    N = N + 4
END SUB


SUB XY_ROTATE (object_nr AS LONG, angle)
    start = OBJECT(object_nr).s
    eend = OBJECT(object_nr).e
    x = OBJECT(object_nr).X
    y = OBJECT(object_nr).Y
    z = OBJECT(object_nr).Z

    radius = OBJECT(object_nr).radius 'SQR((v(start).X - x) ^ 2 + (v(start).Y - y) ^ 2)



    FOR rot = start TO eend
        s = JK(x, y, v(rot).X, (v(rot).Y), radius)
        v(rot).X = x + (SIN(angle + s) * radius)
        v(rot).Y = y + (COS(angle + s) * radius)
    NEXT rot
END SUB

SUB XZ_ROTATE (object_nr AS LONG, angle)
    start = OBJECT(object_nr).s
    eend = OBJECT(object_nr).e
    x = OBJECT(object_nr).X
    y = OBJECT(object_nr).Y
    z = OBJECT(object_nr).Z
    radius = OBJECT(object_nr).radius
    FOR rot = start TO eend
        s = JK(x, z, v(rot).X, (v(rot).Z), radius)
        v(rot).X = x + (SIN(angle + s) * radius)
        v(rot).Z = z + (COS(angle + s) * radius)
    NEXT rot
END SUB

SUB YZ_ROTATE (object_nr AS LONG, angle)
    start = OBJECT(object_nr).s
    eend = OBJECT(object_nr).e
    x = OBJECT(object_nr).X
    y = OBJECT(object_nr).Y
    z = OBJECT(object_nr).Z
    radius = OBJECT(object_nr).radius
    FOR rot = start TO eend
        s = JK(y, z, v(rot).Y, (v(rot).Z), radius)
        v(rot).Y = y + (SIN(angle + s) * radius)
        v(rot).Z = z + (COS(angle + s) * radius)
    NEXT rot
END SUB

FUNCTION IS_VISIBLE (object_nr)
    SHARED posZ, posX
    lenx = ABS(posX) - ABS(OBJECT(object_nr).X)
    lenZ = ABS(posZ) - ABS(OBJECT(object_nr).Z)
    IF SQR((lenx ^ 2) + (lenZ ^ 2)) < DOHLEDNOST THEN IS_VISIBLE = 1 ELSE IS_VISIBLE = 0
END FUNCTION


SUB WALLZ (x1 AS SINGLE, y1 AS SINGLE, z1 AS SINGLE, x2 AS SINGLE, y2 AS SINGLE, z2 AS SINGLE)
    SHARED dlazba&
    i = UBOUND(v)
    REDIM _PRESERVE v(i + 24) AS V
    'predni stena

    v(i + 1).X = x1
    v(i + 1).Y = y1
    v(i + 1).Z = z1

    v(i + 2).X = x2
    v(i + 2).Y = y1
    v(i + 2).Z = z1

    v(i + 3).X = x1
    v(i + 3).Y = y2
    v(i + 3).Z = z1

    v(i + 4).X = x2
    v(i + 4).Y = y2
    v(i + 4).Z = z1


    'zadni stena
    v(i + 5).X = x1
    v(i + 5).Y = y1
    v(i + 5).Z = z2

    v(i + 6).X = x2
    v(i + 6).Y = y1
    v(i + 6).Z = z2

    v(i + 7).X = x1
    v(i + 7).Y = y2
    v(i + 7).Z = z2

    v(i + 8).X = x2
    v(i + 8).Y = y2
    v(i + 8).Z = z2

    'dno - spoj zdi v podlaze

    v(i + 9).X = x1
    v(i + 9).Y = y1
    v(i + 9).Z = z1

    v(i + 10).X = x2
    v(i + 10).Y = y1
    v(i + 10).Z = z1

    v(i + 11).X = x1
    v(i + 11).Y = y1
    v(i + 11).Z = z2

    v(i + 12).X = x2
    v(i + 12).Y = y1
    v(i + 12).Z = z2

    'vrch - horni spoj zdi

    v(i + 13).X = x1
    v(i + 13).Y = y2
    v(i + 13).Z = z1

    v(i + 14).X = x2
    v(i + 14).Y = y2
    v(i + 14).Z = z1

    v(i + 15).X = x1
    v(i + 15).Y = y2
    v(i + 15).Z = z2

    v(i + 16).X = x2
    v(i + 16).Y = y2
    v(i + 16).Z = z2

    'levy bok
    v(i + 17).X = x2
    v(i + 17).Y = y1
    v(i + 17).Z = z1

    v(i + 18).X = x2
    v(i + 18).Y = y1
    v(i + 18).Z = z2

    v(i + 19).X = x2
    v(i + 19).Y = y2
    v(i + 19).Z = z1

    v(i + 20).X = x2
    v(i + 20).Y = y2
    v(i + 20).Z = z2

    'pravy bok
    v(i + 21).X = x1
    v(i + 21).Y = y1
    v(i + 21).Z = z1

    v(i + 22).X = x1
    v(i + 22).Y = y1
    v(i + 22).Z = z2

    v(i + 23).X = x1
    v(i + 23).Y = y2
    v(i + 23).Z = z1

    v(i + 24).X = x1
    v(i + 24).Y = y2
    v(i + 24).Z = z2



    N = N + 24
    Set_texture dlazba&, i + 1, i + 24, 10

END SUB


SUB LOAD_MAP (filename AS STRING)
    IF _FILEEXISTS(filename) THEN
        DIM RH AS MAP_HEAD
        DIM Vertex AS Vertex

        ff = FREEFILE
        OPEN filename$ FOR BINARY AS #ff
        GET #ff, , RH
        IF RH.Identity <> "MAP3D" THEN EXIT SUB 'unsupported file format
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

        SP$ = "SWAPP\"

        IF _DIREXISTS("SWAPP") = 0 THEN MKDIR "SWAPP"

        FOR R = 1 TO RH.Nr_of_Textures
            ff2 = FREEFILE

            OPEN SP$ + FileName(R) FOR OUTPUT AS #ff2
            CLOSE #ff2
            OPEN SP$ + FileName(R) FOR BINARY AS #ff2
            record$ = SPACE$(FileSize(R))
            GET #ff, , record$
            PUT #ff2, , record$
            record$ = ""
            CLOSE #ff2
        NEXT R

        REDIM textures(RH.Nr_of_Textures) AS LONG

        FOR R = 1 TO RH.Nr_of_Textures
            textures(R) = Hload(SP$ + FileName(R)) 'index udava poradi textury v souboru, pridano SP$
        NEXT R

        DIM W AS LONG, H AS LONG
        GET #ff, , W
        GET #ff, , H

        SHARED MAP_WIDTH, MAP_HEIGHT
        MAP_WIDTH = W
        MAP_HEIGHT = H

        REDIM ColisMap(W, H) AS LONG
        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1

                GET #ff, , record&
                IF record& > -1 THEN
                    REDIM _PRESERVE recs(reci) AS LONG
                    recs(reci) = record&
                    reci = reci + 1
                    ColisMap(Lx, Ly) = 1
                END IF
        NEXT Lx, Ly

        reci = 0
        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                IF ColisMap(Lx, Ly) THEN
                    O_WALL Lx, Ly, textures(recs(reci)), WALL_TYPE(ColisMap(), Lx, Ly)
                    reci = reci + 1
                END IF
        NEXT Lx, Ly
        ERASE recs

        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                GET #ff, , record&
                IF record& > -1 THEN
                    '   PRINT Lx, Ly
                    IF ColisMap(Lx, Ly) = 0 THEN
                        O_FLOOR Lx, Ly, textures(record&)
                        'SLEEP
                    END IF
                END IF
        NEXT Lx, Ly


        FOR Ly = 0 TO H - 1
            FOR Lx = 0 TO W - 1
                GET #ff, , record&
                IF record& > -1 THEN
                    '   PRINT Lx, Ly
                    IF ColisMap(Lx, Ly) = 0 THEN
                        O_CEILING Lx, Ly, textures(record&)
                        '                    SLEEP
                    END IF
                END IF
        NEXT Lx, Ly
        CLOSE #ff
    ELSE 'file not found
        EXIT SUB
    END IF
END SUB

FUNCTION RED&
    R = _NEWIMAGE(100, 100, 32)
    C = _DEST
    _DEST R
    CLS , _RGBA32(255, 0, 0, 90)
    _DEST C
    RED& = _COPYIMAGE(R, 33)
    _FREEIMAGE R
END FUNCTION


FUNCTION TYP! (from AS SINGLE, tto AS SINGLE, value AS SINGLE) 'funguje jak ma, nemam jinou kopii, ale nepouzivam. Neresilo to muj problem, jak jsem doufal.
    '   tto = tto + 1 'nula je prvni hodnota, nebo to zapis v "lidksych cislech"
    tto = tto * 1000
    from = from * 1000
    value = value * 1000

    IF value < tto AND value > from THEN TYP! = value / 1000: EXIT FUNCTION
    IF value > tto THEN TYP! = (value MOD tto) / 1000: EXIT FUNCTION
    IF value < from THEN TYP! = (tto - ABS(value MOD tto)) / 1000: EXIT FUNCTION

END FUNCTION


SUB zapisV
    OPEN "PoleV.txt" FOR OUTPUT AS #1
    FOR W = LBOUND(OBJECT) TO UBOUND(OBJECT)
        PRINT #1, OBJECT(W).X; ","; OBJECT(W).Y; ","; OBJECT(W).Z; OBJECT(W).s; OBJECT(W).e
    NEXT
    CLOSE #1
END SUB


FUNCTION WALL_TYPE (W( x , y) AS LONG, Xp AS INTEGER, Yp AS INTEGER) 'urceno mimo okraje mapy
    WALL_TYPE = 1

    Xmin = LBOUND(W, 1)
    Xmax = UBOUND(W, 1)
    Ymin = LBOUND(W, 2)
    Ymax = UBOUND(W, 2)

    'v mistech, kde je soused se nezapisuji vrcholy pro texturovani

    IF Xp > Xmin AND Xmax > Xp + 1 AND Yp > Ymin AND Ymax > Yp + 1 THEN
        IF W(Xp + 1, Yp) = 0 AND W(Xp - 1, Yp) = 0 AND W(Xp, Yp + 1) = 0 AND W(Xp, Yp - 1) = 0 THEN WALL_TYPE = 1 'prazdno okolo ze vsech stran.
        IF W(Xp + 1, Yp) = 0 AND W(Xp - 1, Yp) = 1 AND W(Xp, Yp + 1) = 0 AND W(Xp, Yp - 1) = 0 THEN WALL_TYPE = 2 'vlevo je soused
        IF W(Xp + 1, Yp) = 0 AND W(Xp - 1, Yp) = 0 AND W(Xp, Yp + 1) = 0 AND W(Xp, Yp - 1) = 1 THEN WALL_TYPE = 3 'nahore je soused
        IF W(Xp + 1, Yp) = 1 AND W(Xp - 1, Yp) = 0 AND W(Xp, Yp + 1) = 0 AND W(Xp, Yp - 1) = 0 THEN WALL_TYPE = 4 'vpravo je soused
        IF W(Xp + 1, Yp) = 0 AND W(Xp - 1, Yp) = 0 AND W(Xp, Yp + 1) = 1 AND W(Xp, Yp - 1) = 0 THEN WALL_TYPE = 5 'dole je soused
        IF W(Xp + 1, Yp) = 0 AND W(Xp - 1, Yp) = 0 AND W(Xp, Yp + 1) = 1 AND W(Xp, Yp - 1) = 1 THEN WALL_TYPE = 6 'nahore i dole je soused
        IF W(Xp + 1, Yp) = 1 AND W(Xp - 1, Yp) = 1 AND W(Xp, Yp + 1) = 0 AND W(Xp, Yp - 1) = 0 THEN WALL_TYPE = 7 'vlevo a vpravo je soused
        IF W(Xp + 1, Yp) = 1 AND W(Xp - 1, Yp) = 1 AND W(Xp, Yp + 1) = 1 AND W(Xp, Yp - 1) = 1 THEN WALL_TYPE = 8 'sousedi vsude okolo. Netexturovat.
    END IF
END FUNCTION

SUB Find_Walls (C() AS coordinates)
    DIM x AS LONG, y AS LONG, i AS LONG, Start AS LONG, te AS LONG
    't = TIMER
    U1 = UBOUND(ColisMap, 1)
    U2 = UBOUND(ColisMap, 2)


    FOR y = 1 TO U2
        FOR x = 1 TO U1
            IF ColisMap(x, y) AND Start = 0 THEN Start = 1: C(i).Xs = x: C(i).Ys = y
            IF ColisMap(x, y) = 0 AND Start = 1 THEN
                Start = 0
                IF x - C(i).Xs > 1 THEN
                    C(i).Xe = x - 1: C(i).Ye = y: i = i + 1: REDIM _PRESERVE C(i) AS coordinates
                ELSE
                    C(i).Xs = 0
                END IF
            END IF
        NEXT x
    NEXT y

    FOR x = 1 TO U1
        FOR y = 1 TO U2
            IF ColisMap(x, y) AND Start = 0 THEN Start = 1: C(i).Ys = y: C(i).Xs = x
            IF ColisMap(x, y) = 0 AND Start = 1 THEN
                Start = 0
                IF y - C(i).Ys > 1 THEN
                    C(i).Ye = y - 1: C(i).Xe = x: i = i + 1: REDIM _PRESERVE C(i) AS coordinates
                ELSE
                    C(i).Ys = 0
                END IF
            END IF
        NEXT y
    NEXT x

    FOR H = LBOUND(OBJECT) TO UBOUND(OBJECT)
        FOR i = LBOUND(C) TO UBOUND(C)
            IF OBJECT(H).X = C(i).Xs AND OBJECT(H).Z = C(i).Ys THEN C(i).S = H
            IF OBJECT(H).X = C(i).Xe AND OBJECT(H).Z = C(i).Ye THEN C(i).K = H
    NEXT i, H
END SUB



FUNCTION VolumeAgent (centerX AS SINGLE, centerZ AS SINGLE, CamX, CamZ, Lenght AS SINGLE) 'vrati hlasitost v danem okruhu podle vzdalenosti
    Lx = CamX - centerX
    Lz = CamZ - centerZ
    act = SQR((Lx ^ 2) + (Lz ^ 2))
    IF Lenght >= act THEN
        PSET (CamX, CamZ)
        VolumeAgent = (Lenght - act) / (Lenght)
    END IF
END FUNCTION

FUNCTION Wall_Distance (i AS LONG)
    SHARED CX, CY, CZ
    Wall_Distance = 100
    IF ZDI(i).Xs <= CX AND ZDI(i).Xe >= CX OR ZDI(i).Ys <= CZ AND ZDI(i).Ye >= CZ THEN
        Wall_Distance = SQR((CX - ZDI(i).Xs) ^ 2 + (CZ - ZDI(i).Ys) ^ 2)
    END IF
END FUNCTION
