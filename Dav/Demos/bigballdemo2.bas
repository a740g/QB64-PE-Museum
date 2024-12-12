'================
'BIGBALLDEMO2.BAS
'================
'Bigger Bouncing balls demo using vector reflection.
'By Dav, SEP 16th/2024, for QB64 Phoenix Edition.

'===============
'About this demo
'===============

'This demo shows balls bouncing inside a bigger ball, which is inside
'a bigger outer ball. Between the big balls are more bouncing balls.
'There are more balls bouncing on the outside, so there are 3 layers
'of bouncing balls.  Use the mouse to drag the big middle ball, which
'will move the outer ball.  You will see that all the balls collide
'and reflect off each other.  It uses the FC SUB to draw all the balls.

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

'There are three collision SUB used in this program.  One to handle
'two balls colliding, one to bounce a ball off the inside of a larger
'ball, and one to bouce off the outside of a larger ball.

RANDOMIZE TIMER

SCREEN _NEWIMAGE(1000, 700, 32)

'=== defaults for the bigball ===
bigballsize = 190
bigballx = _WIDTH / 2
bigbally = _HEIGHT / 2

'=== defaults for the outer ball ===
outerballsize = 300 ' size of the outer ball
outerballx = _WIDTH / 2
outerbally = _HEIGHT / 2

'=== arrays for inside balls ===
insidenum = 45 'num of inside balls
DIM insidex(insidenum) 'x positions of inside balls
DIM insidey(insidenum) 'ypositions of inside balls
DIM insidexv(insidenum) 'x velocities of inside balls
DIM insideyv(insidenum) 'y velocities of inside balls
DIM insidesize(insidenum) 'sizes of inside balls
DIM insideclr~&(insidenum) 'colors of inside balls

'=== arrays for middle balls ===
middlenum = 125 'num of inside balls
DIM middlex(middlenum) 'x positions of inside balls
DIM middley(middlenum) 'ypositions of inside balls
DIM middlexv(middlenum) 'x velocities of inside balls
DIM middleyv(middlenum) 'y velocities of inside balls
DIM middlesize(middlenum) 'sizes of inside balls
DIM middleclr~&(middlenum) 'colors of inside balls

'=== arrays for outside balls ===
outsidenum = 125 'num of outside balls
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

'=== initialize middle balls ===
FOR i = 0 TO middlenum - 1
    middlex(i) = RND * (outerballsize - 50) + outerballx 'x position of middle ball
    middley(i) = RND * (outerballsize - 50) + outerbally 'y x position of middle ball
    middlexv(i) = (RND * 2 + 1) * (2 * RND - 1) 'x velocity between -3 and 3
    middleyv(i) = (RND * 2 + 1) * (2 * RND - 1) 'y velocity between -3 and 3
    middlesize(i) = 5 + (RND * 10) 'random size
    middleclr~&(i) = _RGBA(RND * 200, RND * 100, RND * 255, 170) 'color
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

        '=== check collision with the big ball ===
        Ball2BallInsideEdgeCollision insidex(i), insidey(i), insidesize(i), insidexv(i), insideyv(i), bigballx, bigbally, bigballsize

        '=== finally draw insideball ===
        fc insidex(i), insidey(i), insidesize(i), insideclr~&(i), 1

    NEXT

    '=== handle collisions of insideballs ===
    FOR i = 0 TO insidenum - 1
        FOR j = i + 1 TO insidenum - 1
            IF i <> j THEN
                Ball2BallCollision insidex(i), insidey(i), insidesize(i), insidexv(i), insideyv(i), insidex(j), insidey(j), insidesize(j), insidexv(j), insideyv(j)
            END IF
        NEXT
    NEXT

    '=== handle middle balls ===
    FOR i = 0 TO middlenum - 1
        '== move middle balls ==
        middlex(i) = middlex(i) + middlexv(i)
        middley(i) = middley(i) + middleyv(i)

        '=== Check for boundary with the outer ball ===
        Ball2BallInsideEdgeCollision middlex(i), middley(i), middlesize(i), middlexv(i), middleyv(i), outerballx, outerbally, outerballsize

        '=== Check middleball collision with the bigball ===
        Ball2BallOutsideEdgeCollision middlex(i), middley(i), middlesize(i), middlexv(i), middleyv(i), bigballx, bigbally, bigballsize

        '=== finally draw middle ball ===
        fc middlex(i), middley(i), middlesize(i), middleclr~&(i), 1
    NEXT

    '=== Handle middleball collisions with each other ===
    FOR i = 0 TO middlenum - 1
        FOR j = i + 1 TO middlenum - 1
            IF i <> j THEN
                Ball2BallCollision middlex(i), middley(i), middlesize(i), middlexv(i), middleyv(i), middlex(j), middley(j), middlesize(j), middlexv(j), middleyv(j)
            END IF
        NEXT
    NEXT

    '=== handle Outside balls ===
    FOR j = 0 TO outsidenum - 1

        'draw outside ball
        fc outsidex(j), outsidey(j), outsidesizes(j), outsideclr~&(j), 1

        outsidex(j) = outsidex(j) + outsidexv(j)
        outsidey(j) = outsidey(j) + outsideyv(j)

        '=== bounce outside balls off the screen edges
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

        '==== check for outside ball collision with outer ball ====
        Ball2BallOutsideEdgeCollision outsidex(j), outsidey(j), outsidesizes(j), outsidexv(j), outsideyv(j), outerballx, outerbally, outerballsize

    NEXT

    '=== handle collisions between outside balls ===
    FOR i = 0 TO outsidenum - 1
        FOR j = i + 1 TO outsidenum - 1
            IF i <> j THEN
                Ball2BallCollision outsidex(i), outsidey(i), outsidesizes(i), outsidexv(i), outsideyv(i), outsidex(j), outsidey(j), outsidesizes(j), outsidexv(j), outsideyv(j)
            END IF
        NEXT
    NEXT

    '=== check for collision between the bigball and the outer ball      ===
    '==== this keeps the bigball and outerball at the edge of each other ===
    dis = SQR((bigballx - outerballx) ^ 2 + (bigbally - outerbally) ^ 2)
    IF dis > (bigballsize / 2) THEN
        'calculate direction from bigball to outerball
        angle = _ATAN2(outerbally - bigbally, outerballx - bigballx)
        'make distance from center of bigball to edge of outerball
        newdis = outerballsize + (bigballsize / 2)
        'move the outer ball to exactly touch the big ball's edge
        outerballx = bigballx + COS(angle) * (newdis - outerballsize)
        outerbally = bigbally + SIN(angle) * (newdis - outerballsize)
    END IF

    '=== draw the outer ball ===
    fc outerballx, outerbally, outerballsize, _RGBA(200, 100, 255, 50), 0
    'draw an edge around it
    CIRCLE (outerballx, outerbally), outerballsize, _RGBA(255, 255, 255, 75)

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

    IF radius < 1 THEN EXIT SUB 'a safety bail (thanks bplus!)

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

SUB Ball2BallCollision (Ball1x, Ball1y, Ball1s, Ball1xv, Ball1yv, Ball2x, Ball2y, Ball2s, Ball2xv, Ball2yv)

    'This SUB handles ball to ball collision

    'calculate distance between the two balls
    dx = Ball2x - Ball1x
    dy = Ball2y - Ball1y
    dis = SQR(dx * dx + dy * dy)
    'check for collision, if so...
    IF dis < (Ball1s + Ball2s) THEN
        'calculate normal vector and overlapping distance
        x = dx / dis: y = dy / dis 'normal
        over = (Ball1s + Ball2s) - dis 'overlap distance
        'move balls apart based on overlap amount
        Ball1x = Ball1x - x * (over / 2)
        Ball1y = Ball1y - y * (over / 2)
        Ball2x = Ball2x + x * (over / 2)
        Ball2y = Ball2y + y * (over / 2)
        'reflect velocities based on collision
        vr = (Ball2xv - Ball1xv) * x + (Ball2yv - Ball1yv) * y
        'update ball velocities based on collision
        Ball1xv = Ball1xv + vr * x: Ball1yv = Ball1yv + vr * y
        Ball2xv = Ball2xv - vr * x: Ball2yv = Ball2yv - vr * y
    END IF
END SUB

SUB Ball2BallInsideEdgeCollision (Ball1x, Ball1y, Ball1s, Ball1xv, Ball1yv, BallEdgex, BallEdgey, BallEdgeSize)

    'This sub handles balls colliding with the inside edge of a larger ball

    dis = SQR((Ball1x - BallEdgex) ^ 2 + (Ball1y - BallEdgey) ^ 2)
    'check if iball collides with ball edge
    IF dis + Ball1s > BallEdgeSize THEN
        'calculate normal vector for reflection
        x = (Ball1x - BallEdgex) / dis
        y = (Ball1y - BallEdgey) / dis
        'calculate the reflection of velocity based impact angle
        vr = Ball1xv * x + Ball1yv * y
        'update velocity of inside ball based on the normal
        Ball1xv = Ball1xv - 2 * vr * x
        Ball1yv = Ball1yv - 2 * vr * y
        'push back to prevent overlapping
        over = (dis + Ball1s) - BallEdgeSize
        Ball1x = Ball1x - x * over
        Ball1y = Ball1y - y * over
    END IF
END SUB

SUB Ball2BallOutsideEdgeCollision (Ball1x, Ball1y, Ball1s, Ball1xv, Ball1yv, BallEdgex, BallEdgey, BallEdgeSize)

    'This sub handles balls colliding with the outside edge of a larger ball

    dis = SQR((Ball1x - BallEdgex) ^ 2 + (Ball1y - BallEdgey) ^ 2)
    IF dis < BallEdgeSize + Ball1s THEN
        'calculate normal vector for reflection
        x = (Ball1x - BallEdgex) / dis
        y = (Ball1y - BallEdgey) / dis
        'reflect velocity based on normal vector
        vr = Ball1xv * x + Ball1yv * y
        Ball1xv = Ball1xv - 2 * vr * x
        Ball1yv = Ball1yv - 2 * vr * y
        'move the middle ball out to prevent overlap
        over = (BallEdgeSize + Ball1s) - dis
        Ball1x = Ball1x + x * over
        Ball1y = Ball1y + y * over
    END IF
END SUB
