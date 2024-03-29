OPTION _EXPLICIT
_TITLE "Carbonated Circle Fractal by bplus 2017-10-15"
' working from Ashish simple Circle Fractal

REDIM SHARED AS LONG cx(0), cy(0), cr(0)
DIM SHARED xmax, ymax
DIM SHARED AS LONG ci, r1, basey, nb, i, r
DIM antiGravity

nb = 60
DIM bx(nb), by(nb), br(nb), bdy(nb)
DIM bc~&(nb)

xmax = 700
ymax = 700

SCREEN _NEWIMAGE(xmax, ymax, 32)
_SCREENMOVE 290, 40
RANDOMIZE TIMER

r1 = 150
basey = ymax - r1 - 10
drawCircle xmax / 2, basey, r1
antiGravity = -.6

FOR i = 1 TO nb
    r = rand&(1, ci)
    bx(i) = cx(r): by(i) = rand(0, basey): br(i) = cr(r): bdy(i) = rand(-4, -2)
    bc~&(i) = _RGB32(RND * 155 + 100, RND * 155 + 100, RND * 155 + 100)
NEXT
CLS
DO
    WHILE 1
        CLS
        FOR i = 1 TO ci
            COLOR &HFF88DDDD
            CIRCLE (cx(i), cy(i)), cr(i)
        NEXT
        FOR i = 1 TO nb
            COLOR bc~&(i)
            CIRCLE (bx(i), by(i)), br(i)
            IF by(i) - 4 + br(i) < 0 THEN
                r = rand&(1, ci)
                bx(i) = cx(r)
                by(i) = cy(r)
                br(i) = cr(r)
                bdy(i) = rand&(-4, -2)
                bc~&(i) = _RGB32(rand&(100, 255), rand&(100, 255), rand&(100, 255))
            ELSE
                bdy(i) = bdy(i) + antiGravity
                by(i) = by(i) + bdy(i)
            END IF
        NEXT
        _DISPLAY
        _LIMIT 10
    WEND
LOOP

SUB drawCircle (x, y, r) ' draws fractal
    CIRCLE (x, y), r
    ci = ci + 1
    REDIM _PRESERVE cx(ci): cx(ci) = x
    REDIM _PRESERVE cy(ci): cy(ci) = y
    REDIM _PRESERVE cr(ci): cr(ci) = r
    IF r > 2 THEN
        drawCircle x + r, y, r / 2
        drawCircle x - r, y, r / 2
    END IF
END SUB

FUNCTION rand& (lo&, hi&)
    rand& = INT(RND * (hi& - lo& + 1)) + lo&
END FUNCTION

