'This is my starfield entry hacked down to 25 lines
'It needs a pretty fast computer...looks OK on my 1.5 GHz
'JKC 2003

$RESIZE:SMOOTH

TYPE star
    x AS INTEGER
    y AS INTEGER
    z AS INTEGER
END TYPE

DIM astar(0 TO 300) AS star
DIM oldstar(0 TO 300) AS star
FOR i = 0 TO 300
    astar(i).x = RND * 640
    astar(i).y = RND * 480
    astar(i).z = RND * 300
NEXT

SCREEN 11
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DO
    FOR i = 0 TO 300
        IF astar(i).z < 1 THEN astar(i).z = 300 ELSE astar(i).z = astar(i).z - 1
        FOR p% = 0 TO oldstar(i).z
            CIRCLE (oldstar(i).x, oldstar(i).y), p%, 0
            IF astar(i).z <> 300 THEN CIRCLE (INT(2 * astar(i).z + astar(i).x / (1 + astar(i).z / 30)), INT(astar(i).z + astar(i).y / (1 + astar(i).z / 30))), p%
        NEXT p%
        oldstar(i).x = INT(2 * astar(i).z + astar(i).x / (1 + astar(i).z / 30))
        oldstar(i).y = INT(astar(i).z + astar(i).y / (1 + astar(i).z / 30))
        oldstar(i).z = 5 / (1 + astar(i).z / 20)
    NEXT
    _LIMIT 60
LOOP UNTIL INKEY$ <> ""

SYSTEM
