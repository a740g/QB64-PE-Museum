' https://qb64phoenix.com/forum/showthread.php?tid=2453

TYPE cartype
    vx AS DOUBLE
    vy AS DOUBLE
    x AS DOUBLE
    y AS DOUBLE

    x0 AS DOUBLE
    vy0 AS DOUBLE

    c AS LONG
END TYPE

DIM SHARED car(1) AS cartype
car(0).vx = 0
car(0).vy = 0
car(0).vy0 = 23
car(0).x0 = 150
car(0).x = car(0).x0
car(0).y = 400
car(0).c = _RGB32(0, 255, 0)

car(1).vx = 0
car(1).vy = 0
car(1).vy0 = 20
car(1).x0 = -150
car(1).x = car(1).x0
car(1).y = 800
car(1).c = _RGB32(0, 0, 255)

'car(2).vx = 0
'car(2).vy = 0
'car(2).vy0 = 0
'car(2).x0 = 0
'car(2).x = car(2).x0
'car(2).y = 1200
'car(2).c = _rgb(255,0,255)


DIM SHARED sw, sh, d, z0, p, q
d = 300
z0 = 100

sw = 800
sh = 600
SCREEN _NEWIMAGE(sw, sh, 32)

DIM i, j, x, y, vx, vy, s, ss
vx = 0
vy = 0
x = 0
y = 0

DO
    IF _RESIZE THEN
        sw = _RESIZEWIDTH - 20
        sh = _RESIZEHEIGHT - 20
        SCREEN _NEWIMAGE(sw, sh, 32)
    END IF

    CLS
    LOCATE 1, 1
    IF y > car(0).y AND y > car(1).y THEN PRINT "Steve ";
    IF car(0).y > y AND car(0).y > car(1).y THEN PRINT "Walter ";
    IF car(1).y > y AND car(1).y > car(0).y THEN PRINT "Cory ";
    PRINT "leads"


    '''road collision
    s = (500) * SIN((1 - y) * 0.001)

    IF x > (350 - s - 50) THEN
        vx = -0.8 * vy
        vy = vy * 0.4
    END IF
    IF x < (-350 - s + 50) THEN
        vx = 0.8 * vy
        vy = vy * 0.4
    END IF

    FOR i = 0 TO UBOUND(car)
        IF car(i).x > (350 - 50) THEN
            car(i).vx = -0.8 * car(i).vy
            car(i).vy = car(i).vy * 0.4
        END IF
        IF car(i).x < (-350 + 50) THEN
            car(i).vx = 0.8 * car(i).vy
            car(i).vy = car(i).vy * 0.4
        END IF
    NEXT

    '''car collision
    FOR i = 0 TO UBOUND(car)
        IF y > (car(i).y - 70 - 20) AND y < (car(i).y + 70) THEN
            
            ovy = vy
            'behind
            IF x + s > car(i).x - 50 AND x + s < car(i).x + 50 THEN
                vy = 0.8 * vy
                car(i).vy = car(i).vy + 0.8 * vy
            END IF
            
            'left
            IF x + s > car(i).x - 50 AND x + s < car(i).x - 25 THEN
                vx = -0.8 * (ovy + car(i).vy)
                car(i).vx = 0.8 * (ovy + car(i).vy)

                'right
            ELSEIF x + s < car(i).x + 50 AND x + s > car(i).x + 25 THEN
                vx = 0.8 * (ovy + car(i).vy)
                car(i).vx = 0.8 * (ovy - car(i).vy)
                
            END IF
        END IF
    NEXT
    
    
    
    'if vy > 0 then
    IF _KEYDOWN(19200) THEN vx = vx + 1
    IF _KEYDOWN(19712) THEN vx = vx - 1
    'end if
    
    IF _KEYDOWN(18432) THEN vy = vy + 0.1
    IF _KEYDOWN(20480) THEN vy = vy - 0.5

    x = x + vx
    y = y + vy

    IF vx > 0 THEN vx = vx - 0.1
    IF vx < 0 THEN vx = vx + 0.1

    IF vy > 0 THEN vy = vy - 0.01
    IF vy < 0 THEN vy = 0


    '''self driving cars
    FOR i = 0 TO UBOUND(car)
        IF car(i).vy < car(i).vy0 THEN car(i).vy = car(i).vy + 0.1
        IF car(i).vy > car(i).vy0 THEN car(i).vy = car(i).vy - 0.1

        IF car(i).x < car(i).x0 THEN car(i).vx = car(i).vx + 1
        IF car(i).x > car(i).x0 THEN car(i).vx = car(i).vx - 1
    NEXT


    FOR i = 0 TO UBOUND(car)
        car(i).x = car(i).x + car(i).vx
        car(i).y = car(i).y + car(i).vy

        IF car(i).vx > 0 THEN car(i).vx = car(i).vx - 0.1
        IF car(i).vx < 0 THEN car(i).vx = car(i).vx + 0.1

        IF car(i).vy > 0 THEN car(i).vy = car(i).vy - 0.01
        IF car(i).vy < 0 THEN car(i).vy = 0
    NEXT


    '''draw cars
    COLOR _RGB(255, 0, 0)
    box 0, -100, 20, 50, 70, 20
    box 0, -80, 20, 50, 35, 20

    FOR i = 0 TO UBOUND(car)
        IF car(i).y > y - 35 THEN
            COLOR car(i).c
            box x + s - car(i).x, -100, car(i).y - y, 50, 70, 20
            box x + s - car(i).x, -80, car(i).y - y, 50, 35, 20
        END IF
    NEXT


    '''draw road
    COLOR _RGB(255, 255, 255)
    FOR i = 1 TO 100 STEP 2
        s = (500) * SIN((i - y) * 0.001)
        box x + s - 350, -100, i * 50 - (y MOD 100), 50, 50, 50
        box x + s + 350, -100, i * 50 - (y MOD 100), 50, 50, 50
    NEXT

    'line (0, 115)-step(sw,0)

    _DISPLAY
    _LIMIT 50
LOOP UNTIL _KEYHIT = 27

SYSTEM


SUB box (x, y, z, w, l, h)
    proj x - w / 2, y - h / 2, z - l / 2
    PRESET (p, q)
    proj x + w / 2, y + h / 2, z - l / 2
    LINE -(p, q), , B

    proj x + w / 2, y + h / 2, z + l / 2
    LINE -(p, q)

    proj x - w / 2, y - h / 2, z + l / 2
    LINE -(p, q), , B

    proj x - w / 2, y - h / 2, z - l / 2
    LINE -(p, q)

    proj x - w / 2, y + h / 2, z - l / 2
    PRESET (p, q)
    proj x - w / 2, y + h / 2, z + l / 2
    LINE -(p, q)

    proj x + w / 2, y - h / 2, z - l / 2
    PRESET (p, q)
    proj x + w / 2, y - h / 2, z + l / 2
    LINE -(p, q)

    'proj x, y, z
    'circle (p, q), 2, _rgb(255,255,0)
END SUB

SUB proj (x, y, z)
    p = sw / 2 + x * d / (z + z0)
    q = sh / 2 - (y - 100) * d / (z + z0) - 200
END SUB
