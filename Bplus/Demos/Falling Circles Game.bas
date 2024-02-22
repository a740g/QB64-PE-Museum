$UNSTABLE:HTTP

DIM buzz, music, lose
music = _SNDOPEN(Download("https://opengameart.org/sites/default/files/newbattle.wav"), "memory")
buzz = _SNDOPEN(Download("https://opengameart.org/sites/default/files/buzz_0.ogg"), "memory")
lose = _SNDOPEN(Download("https://opengameart.org/sites/default/files/lose%20music%201%20-%201_0.wav"), "memory")
_SNDLOOP music
DIM AS LONG HX, HY, i, hits, score, Stars, nEnemies, Height
HX = 320: HY = 400: nStars = 1000: nEnemies = 50: Height = 480
DIM EX(nEnemies), EY(nEnemies), EC(nEnemies) AS _UNSIGNED LONG ' enemy stuff
SCREEN _NEWIMAGE(640, Height, 32)
Stars = _NEWIMAGE(640, Height, 32)
FOR i = 1 TO nStars
    PSET (INT(RND * 640), INT(RND * 480)), _RGB32(55 + RND * 200, 55 + RND * 200, 55 + RND * 200)
NEXT
_PUTIMAGE , 0, Stars
FOR i = 1 TO nEnemies
    EX(i) = INT(RND * 600 + 20): EY(i) = -2 * Height * RND + Height: EC(i) = _RGB32(55 + RND * 200, 55 + RND * 200, 55 + RND * 200)
NEXT
DO
    CLS
    _PUTIMAGE , Stars, 0
    PRINT "Hits:"; hits, "Score:"; score
    LINE (HX - 10, HY - 10)-STEP(20, 20), _RGB32(255, 255, 0), BF
    FOR i = 1 TO nEnemies ' the enemies
        CIRCLE (EX(i), EY(i)), 10, EC(i)
        IF SQR((EX(i) - HX) ^ 2 + (EY(i) - HY) ^ 2) < 20 THEN 'collision
            _SNDPAUSE music
            _SNDPLAY buzz
            _DELAY .5
            hits = hits + 1
            EX(i) = INT(RND * 600 + 20): EY(i) = -Height * RND ' move that bad boy!
            IF hits = 10 THEN
                PRINT "Too many hits, goodbye!"
                _SNDPLAY lose
                FadeOut
                END
            END IF
            _SNDLOOP music
        END IF
        EY(i) = EY(i) + INT(RND * 5)
        IF EY(i) > 470 THEN EX(i) = INT(RND * 600 + 20): EY(i) = -Height * RND: score = score + 1
    NEXT
    IF _KEYDOWN(20480) THEN HY = HY + 3
    IF _KEYDOWN(18432) THEN HY = HY - 3
    IF _KEYDOWN(19200) THEN HX = HX - 3
    IF _KEYDOWN(19712) THEN HX = HX + 3
    IF HX < 10 THEN HX = 10
    IF HX > 630 THEN HX = 630
    IF HY < 10 THEN HY = 10
    IF HY > 470 THEN HY = 470
    _DISPLAY
    _LIMIT 100
LOOP UNTIL _KEYDOWN(27): SLEEP
_SNDSTOP music

SUB FadeOut
    _DELAY 2
    DIM i
    FOR i = 1 TO 100
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(1, 1, 1, 5), BF
        _LIMIT 30
    NEXT i
    LOCATE 16, 35
    PRINT "Game Over"
END SUB

' Content of the HTTP response is returned.
FUNCTION Download$ (url AS STRING)
    DIM h AS LONG, content AS STRING, s AS STRING

    h = _OPENCLIENT("HTTP:" + url)

    WHILE NOT EOF(h)
        _LIMIT 60
        GET #h, , s
        content = content + s
    WEND

    CLOSE #h

    Download$ = content
END FUNCTION

