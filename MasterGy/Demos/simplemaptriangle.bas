'creating hardware images of different colors (you can also use loadimage(...,33) . These will be the sides of the brick
temp = _NEWIMAGE(1, 1, 32): _DEST temp: PSET (0, 0), _RGB32(255, 0, 0): t1 = _COPYIMAGE(temp, 33): _FREEIMAGE temp
temp = _NEWIMAGE(1, 1, 32): _DEST temp: PSET (0, 0), _RGB32(0, 255, 0): t2 = _COPYIMAGE(temp, 33): _FREEIMAGE temp
temp = _NEWIMAGE(1, 1, 32): _DEST temp: PSET (0, 0), _RGB32(0, 0, 255): t3 = _COPYIMAGE(temp, 33): _FREEIMAGE temp
temp = _NEWIMAGE(1, 1, 32): _DEST temp: PSET (0, 0), _RGB32(255, 0, 255): t4 = _COPYIMAGE(temp, 33): _FREEIMAGE temp
temp = _NEWIMAGE(1, 1, 32): _DEST temp: PSET (0, 0), _RGB32(255, 255, 0): t5 = _COPYIMAGE(temp, 33): _FREEIMAGE temp
temp = _NEWIMAGE(1, 1, 32): _DEST temp: PSET (0, 0), _RGB32(0, 255, 255): t6 = _COPYIMAGE(temp, 33): _FREEIMAGE temp


sc = _NEWIMAGE(800, 800, 32): SCREEN sc: _DEST sc

'draw_cube params
'values 1,2,3 are the coordinate points
'values 4,5,6 are the dimensions of the brick (width, length, height)
'values 7-12 you will draw these harweres textures on the side of the brick
'13 angle, rotating XY plane
'14 angle, rotating XZ plane

DO: _LIMIT 30

    draw_brick 10, 10, -50, 5, 5, 5, t1, t2, t3, t4, t5, t6, rotating, rotating
    draw_brick -10, 10, -50, 5, 5, 5, t1, t2, t3, t4, t5, t6, rotating, 0
    draw_brick 10, -10, -50, 5, 5, 5, t1, t2, t3, t4, t5, t6, 0, rotating
    draw_brick -10, -10, -50, 5, 5, 10, t1, t2, t3, t4, t5, t6, rotating, rotating
    rotating = rotating + .1
    _DISPLAY

LOOP UNTIL _KEYHIT = 27

SYSTEM

SUB draw_brick (x, y, z, sizex, sizey, sizez, t0, t1, t2, t3, t4, t5, rota, rotb)
    DIM c(2): c(0) = x: c(1) = y: c(2) = z
    DIM size(2): size(0) = sizex: size(1) = sizey: size(2) = sizez
    DIM t(5): t(0) = t0: t(1) = t1: t(2) = t2: t(3) = t3: t(4) = t4: t(5) = t5
    DIM p(3, 2), pc(7, 2), sq(3) AS _UNSIGNED _BYTE

    FOR t = 0 TO 7
        FOR c = 0 TO 2: pc(t, c) = size(c) * (SGN(t AND 2 ^ c) * 2 - 1): NEXT c
        rotate_2d pc(t, 0), pc(t, 1), rota
        rotate_2d pc(t, 0), pc(t, 2), rotb
        FOR c = 0 TO 2: pc(t, c) = pc(t, c) + c(c): NEXT c
    NEXT t

    FOR t = 0 TO 5
        FOR q = 0 TO 3: s = VAL(MID$("-0246-1357-0145-2367-0123-4567", 2 + t * 5 + q, 1))
        FOR b = 0 TO 2: p(q, b) = pc(s, b): NEXT b, q
        wtext = _WIDTH(t(t)) - 1: htext = _HEIGHT(t(t)) - 1
        _MAPTRIANGLE (0, 0)-(wtext, 0)-(0, htext), t(t) TO(p(0, 0), p(0, 1), p(0, 2))-(p(1, 0), p(1, 1), p(1, 2))-(p(2, 0), p(2, 1), p(2, 2)), , _SMOOTH
        _MAPTRIANGLE (wtext, htext)-(wtext, 0)-(0, htext), t(t) TO(p(3, 0), p(3, 1), p(3, 2))-(p(1, 0), p(1, 1), p(1, 2))-(p(2, 0), p(2, 1), p(2, 2)), , _SMOOTH
    NEXT t
END SUB

SUB rotate_2d (x, y, ang)
    x1 = x * COS(ang) - y * SIN(ang): y1 = x * SIN(ang) + y * COS(ang): x = x1: y = y1
END SUB
