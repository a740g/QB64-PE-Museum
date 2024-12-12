'===============
'BIGBALLDEMO.BAS
'===============
'Bouncing balls demo using vector reflection.
'By Dav, SEP 3rd/2024, for QB64 Phoenix Edition.

'===============
'About this demo
'===============

'This demo shows balls bouncing inside a bigger ball, and other balls
'bouncing on the outside.  It uses my FC SUB to draw all the balls.
'Use the mouse to move the big ball.  Press Any key to exit the demo.

'============================
'More details about this demo
'============================

'This demo was a challenge and a great learning experience for me.
'Instead of just reversing velocity direction when a ball hits an object,
'this demo uses 'vector reflection' to make them bounce realistically.
'When two balls collide, their velocity vector changes direction based on
'angle of impact, and the normal vector at the contact point.  Their
'reflection velocities are computed based on their sizes, and their x/y
'positions are adjusted to prevent overlapping after collision.

RANDOMIZE TIMER

SCREEN _NEWIMAGE(1000, 700, 32)

'=== defaults for the bigball ===
bigballsize = 200
bigballx = _WIDTH / 2
bigbally = _HEIGHT / 2

'=== arrays for inside balls ===
insidenum = 50 'num of inside balls
DIM insidex(insidenum) 'x positions of inside balls
DIM insidey(insidenum) 'ypositions of inside balls
DIM insidexv(insidenum) 'x velocities of inside balls
DIM insideyv(insidenum) 'y velocities of inside balls
DIM insidesize(insidenum) 'sizes of inside balls
DIM insideclr~&(insidenum) 'colors of inside balls

'=== arrays for outside balls ===
outsidenum = 150 'num of outside balls
DIM outsidex(outsidenum) 'x positions of outside balls
DIM outsidey(outsidenum) 'y positions of outside balls
DIM outsidexv(outsidenum) 'x velocities of outside balls
DIM outsideyv(outsidenum) 'y velocities of outside balls
DIM outsidesizes(outsidenum) 'sizes of outside balls
DIM outsideclr~&(outsidenum) 'colors of outside balls

'=== initialize inside balls ===
FOR i = 0 TO insidenum - 1
    insidesize(i) = 5 + (RND * 15) 'random size
    insideclr~&(i) = _RGBA(RND * 255, RND * 255, RND * 255, 200) 'color
    insidexv(i) = (RND * 2 + 1) * (2 * RND - 1) 'x velocity between -3 and 3
    insideyv(i) = (RND * 2 + 1) * (2 * RND - 1) 'y velocity between -3 and 3
NEXT

'=== initialize outside Balls ===
FOR j = 0 TO outsidenum - 1
    outsidesizes(j) = INT(RND * 26) + 5 'random size
    outsideclr~&(j) = _RGBA(RND * 225, RND * 225, RND * 225, 125) 'color
    outsidex(j) = INT(RND * _WIDTH) 'x position
    outsidey(j) = INT(RND * _HEIGHT) 'y position
    outsidexv(j) = (RND * 2 + 1) * (2 * RND - 1) 'x velocity between -3 and 3
    outsideyv(j) = (RND * 2 + 1) * (2 * RND - 1) 'y velocity between -3 and 3
NEXT

'=== draw a background image ===
FOR i = 1 TO 1000
    fc RND * _WIDTH, RND * _HEIGHT, 20, _RGBA(55 + (RND * 100), 55 + (RND * 150), 55 + (RND * 200), 30), 0
NEXT: back& = _COPYIMAGE(_DISPLAY)

'=== put mouse in middle of screen ===
_MOUSEMOVE _WIDTH / 2, _HEIGHT / 2

'=========
'MAIN LOOP
'=========

DO

    '=== put down background image ===
    CLS: _PUTIMAGE (0, 0), back&

    '=== get mouse input ===
    WHILE _MOUSEINPUT: WEND

    '=== assign bigball x/y to mouse x/y ===
    bigballx = _MOUSEX: bigbally = _MOUSEY

    '=== handle inside balls ===
    FOR i = 0 TO insidenum - 1
        '== move inside balls ==
        insidex(i) = insidex(i) + insidexv(i)
        insidey(i) = insidey(i) + insideyv(i)

        '=== check if they collide with bigball edge ===
        'calculate distance from the center x/y of bigball
        dis = SQR((insidex(i) - bigballx) ^ 2 + (insidey(i) - bigbally) ^ 2)

        'check if distance + insideball size exceeds bigball size
        IF dis + insidesize(i) > bigballsize THEN
            'calculate normal vector for reflection
            x = (insidex(i) - bigballx) / dis
            y = (insidey(i) - bigbally) / dis
            'calculate the reflection of velocity based impact angle
            vr = insidexv(i) * x + insideyv(i) * y
            'update velocity of insideball based on the normal
            insidexv(i) = insidexv(i) - 2 * vr * x
            insideyv(i) = insideyv(i) - 2 * vr * y
            'below prevents overlapping by pushing insideball back
            over = (dis + insidesize(i)) - bigballsize
            insidex(i) = insidex(i) - x * over
            insidey(i) = insidey(i) - y * over
        END IF

        '=== finally draw insideball ===
        fc insidex(i), insidey(i), insidesize(i), insideclr~&(i), 1
    NEXT

    '=== handle collisions of insideballs ===
    FOR i = 0 TO insidenum - 1
        FOR j = i + 1 TO insidenum - 1
            IF i <> j THEN
                'calculate distance between the two insideballs
                dx = insidex(j) - insidex(i)
                dy = insidey(j) - insidey(i)
                dis = SQR(dx * dx + dy * dy)
                'check for collision, if so...
                IF dis < (insidesize(i) + insidesize(j)) THEN
                    'calculate normal vector and overlapping distance
                    x = dx / dis: y = dy / dis 'normal
                    over = (insidesize(i) + insidesize(j)) - dis 'overlap distance
                    'move balls apart based on overlap amount
                    insidex(i) = insidex(i) - x * (over / 2)
                    insidey(i) = insidey(i) - y * (over / 2)
                    insidex(j) = insidex(j) + x * (over / 2)
                    insidey(j) = insidey(j) + y * (over / 2)
                    'reflect velocities based on collision
                    vr = (insidexv(j) - insidexv(i)) * x + (insideyv(j) - insideyv(i)) * y
                    'update ball velocities based on collision
                    insidexv(i) = insidexv(i) + vr * x: insideyv(i) = insideyv(i) + vr * y
                    insidexv(j) = insidexv(j) - vr * x: insideyv(j) = insideyv(j) - vr * y
                END IF
            END IF
        NEXT
    NEXT

    '=== handle Outside balls ===
    FOR j = 0 TO outsidenum - 1
        'draw outside ball
        fc outsidex(j), outsidey(j), outsidesizes(j), outsideclr~&(j), 1
        outsidex(j) = outsidex(j) + outsidexv(j)
        outsidey(j) = outsidey(j) + outsideyv(j)
        'these bounce the ball off the edges of screen.
        'if outsideballs hits the edge, reverse directions.
        IF outsidex(j) < outsidesizes(j) THEN
            outsidex(j) = outsidesizes(j): outsidexv(j) = -outsidexv(j)
        END IF
        IF outsidex(j) > _WIDTH - outsidesizes(j) THEN
            outsidex(j) = _WIDTH - outsidesizes(j): outsidexv(j) = -outsidexv(j)
        END IF
        IF outsidey(j) < outsidesizes(j) THEN
            outsidey(j) = outsidesizes(j): outsideyv(j) = -outsideyv(j)
        END IF
        IF outsidey(j) > _HEIGHT - outsidesizes(j) THEN
            outsidey(j) = _HEIGHT - outsidesizes(j): outsideyv(j) = -outsideyv(j)
        END IF

        '==== check for otsideball collision with bigball ===
        'calculate distance from center
        dis = SQR((outsidex(j) - bigballx) ^ 2 + (outsidey(j) - bigbally) ^ 2)
        IF dis < (bigballsize + outsidesizes(j)) THEN
            'calculate the normal vector
            x = (outsidex(j) - bigballx) / dis
            y = (outsidey(j) - bigbally) / dis
            'reflect the velocity off the normal vector
            vr = outsidexv(j) * x + outsideyv(j) * y
            outsidexv(j) = outsidexv(j) - 2 * vr * x
            outsideyv(j) = outsideyv(j) - 2 * vr * y
            'move outside ball back
            'calculate how much it's overlapping...
            over = (bigballsize + outsidesizes(j)) - dis
            'move it away from the bigball
            outsidex(j) = outsidex(j) + x * over
            outsidey(j) = outsidey(j) + y * over
        END IF
    NEXT

    '=== handle collisions between the outsideballs ===
    FOR i = 0 TO outsidenum - 1
        FOR j = i + 1 TO outsidenum - 1
            IF i <> j THEN
                'get distance between the two outside balls
                dx = outsidex(j) - outsidex(i)
                dy = outsidey(j) - outsidey(i)
                dis = SQR(dx * dx + dy * dy)
                'check for collision, if so...
                IF dis < (outsidesizes(i) + outsidesizes(j)) THEN
                    'calculate normal vector and overlapping distance
                    x = dx / dis: y = dy / dis
                    'total overlap distance
                    over = (outsidesizes(i) + outsidesizes(j)) - dis
                    'move balls apart based on overlap
                    outsidex(i) = outsidex(i) - x * (over / 2)
                    outsidey(i) = outsidey(i) - y * (over / 2)
                    outsidex(j) = outsidex(j) + x * (over / 2)
                    outsidey(j) = outsidey(j) + y * (over / 2)
                    'reflect velocities between balls
                    vr = (outsidexv(j) - outsidexv(i)) * x + (outsideyv(j) - outsideyv(i)) * y
                    'update velocities based on collision
                    outsidexv(i) = outsidexv(i) + vr * x
                    outsideyv(i) = outsideyv(i) + vr * y
                    outsidexv(j) = outsidexv(j) - vr * x
                    outsideyv(j) = outsideyv(j) - vr * y
                END IF
            END IF
        NEXT
    NEXT

    '=== draw the bigball ===
    fc bigballx, bigbally, bigballsize, _RGBA(100, 200, 255, 75), 0
    'draw an edge around it
    CIRCLE (bigballx, bigbally), bigballsize, _RGBA(255, 255, 255, 75)

    _DISPLAY
    _LIMIT 60

LOOP UNTIL INKEY$ <> ""


SUB fc (cx, cy, radius, clr~&, grad)
    'FC SUB by Dav
    'Draws filled circle at cx/cy with given radius and color.
    'If grad=1 it will create a gradient effect, otherwise it's a solid color.

    IF radius = 0 THEN EXIT SUB 'a safety bail (thanks bplus!)

    IF grad = 1 THEN
        red = _RED32(clr~&)
        grn = _GREEN32(clr~&)
        blu = _BLUE32(clr~&)
        alpha = _ALPHA32(clr~&)
    END IF
    r2 = radius * radius
    FOR y = -radius TO radius
        x = SQR(r2 - y * y)
        ' If doing gradient
        IF grad = 1 THEN
            FOR i = -x TO x
                dis = SQR(i * i + y * y) / radius
                red2 = red * (1 - dis) + (red / 2) * dis
                grn2 = grn * (1 - dis) + (grn / 2) * dis
                blu2 = blu * (1 - dis) + (blu / 2) * dis
                clr2~& = _RGBA(red2, grn2, blu2, alpha)
                LINE (cx + i, cy + y)-(cx + i, cy + y), clr2~&, BF
            NEXT
        ELSE
            LINE (cx - x, cy + y)-(cx + x, cy + y), clr~&, BF
        END IF
    NEXT
END SUB
