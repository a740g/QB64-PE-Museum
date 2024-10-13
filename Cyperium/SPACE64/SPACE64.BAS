'-----------------------------------------------------------------------------------------------------
' QB64 game by Cyperium
' https://wiki.qb64.org/wiki/A_Small_Game_Tutorial
'-----------------------------------------------------------------------------------------------------

DEFLNG A-Z
OPTION _EXPLICIT
OPTION BASE 1
'$STATIC

_TITLE "Space 64"

DIM asteroidx(100), asteroidy(100), asteroidspeed(100)

$RESIZE:SMOOTH
SCREEN 13
_FULLSCREEN _SQUAREPIXELS , _SMOOTH

DIM y AS INTEGER, x AS INTEGER
DIM c AS INTEGER, k AS INTEGER
DIM lives AS INTEGER, explosion AS INTEGER
DIM collected AS INTEGER, numAsteroids AS INTEGER
DIM asteroid AS INTEGER, removeAsteroid AS INTEGER
DIM shipX AS INTEGER, shipY AS INTEGER
DIM expl AS INTEGER, rand AS INTEGER
DIM heart AS INTEGER, heartSpeed AS SINGLE, heartX AS INTEGER, heartY AS INTEGER
DIM number AS INTEGER, numberSpeed AS SINGLE, numberX AS INTEGER, numberY AS INTEGER
DIM ship AS LONG, obstacle AS LONG, life AS LONG

DATA 000,000,000,000,000,000,000,000,000,000
DATA 000,000,015,015,015,015,015,000,000,000
DATA 000,015,015,015,015,007,007,015,000,000
DATA 000,015,015,015,015,015,015,015,015,000
DATA 000,015,015,015,015,015,015,015,015,015
DATA 000,015,015,015,015,015,015,015,015,000
DATA 000,000,015,015,015,015,015,015,000,000
DATA 000,000,000,000,000,000,000,000,000,000
DATA 000,000,000,000,000,000,000,000,000,000
DATA 000,000,000,000,000,000,000,000,000,000

FOR y = 1 TO 10
    FOR x = 1 TO 10

        READ c
        PSET (x, y), c
    NEXT
NEXT

ship = _NEWIMAGE(11, 11, 13)

_PUTIMAGE (1, 1)-(10, 10), , ship, (1, 1)-(10, 10)

CLS

DATA 000,000,000,000,000,000,000,000,000,000
DATA 000,000,000,006,006,006,000,000,000,000
DATA 000,000,006,006,006,006,006,000,000,000
DATA 000,006,012,006,006,006,006,006,000,000
DATA 000,006,006,006,006,012,006,006,000,000
DATA 000,006,006,006,006,006,006,006,000,000
DATA 000,000,006,006,012,006,006,000,000,000
DATA 000,000,006,006,006,006,000,000,000,000
DATA 000,000,000,006,006,000,000,000,000,000
DATA 000,000,000,000,000,000,000,000,000,000

FOR y = 1 TO 10
    FOR x = 1 TO 10

        READ c
        PSET (x, y), c
    NEXT
NEXT

obstacle = _NEWIMAGE(11, 11, 13)

_PUTIMAGE (1, 1)-(10, 10), , obstacle, (1, 1)-(10, 10)

CLS

DATA 000,000,000,000,000,000,000,000,000,000
DATA 000,000,004,004,000,004,004,000,000,000
DATA 000,004,012,012,004,012,012,004,000,000
DATA 000,004,012,012,012,012,012,004,000,000
DATA 000,004,012,012,012,012,012,004,000,000
DATA 000,004,012,012,012,012,012,004,000,000
DATA 000,000,004,012,012,012,004,000,000,000
DATA 000,000,000,004,012,004,000,000,000,000
DATA 000,000,000,000,004,000,000,000,000,000
DATA 000,000,000,000,000,000,000,000,000,000


FOR y = 1 TO 10
    FOR x = 1 TO 10

        READ c
        PSET (x, y), c
    NEXT
NEXT

life = _NEWIMAGE(11, 11, 13)

_PUTIMAGE (1, 1)-(10, 10), , life, (1, 1)-(10, 10)

CLS

lives = 3

shipX = 10 'we set the x position of the ship to 10 and the y position is set
shipY = 95 'at the middle of the screen (middle of the ship is 5 hence 100-5=95).

DO

    _LIMIT 60
    CLS

    IF explosion = 0 THEN
        _PUTIMAGE (shipX, shipY), ship 'let's only display it when explosion = 0

        'we can make some fire behind the ship by randomly setting some red pixels behind it.
        FOR k = 1 TO 10: PSET (shipX - INT(RND * 5), shipY + INT(RND * 6) + 2), 4: NEXT
    END IF


    'display lives:
    IF lives > 0 THEN
        FOR k = 1 TO lives
            _PUTIMAGE (k * 10, 0), life
        NEXT

    END IF

    'display number of numbers collected:
    _PRINTSTRING (0, 2), LTRIM$(STR$(collected))


    IF _KEYDOWN(CVI(CHR$(0) + "H")) THEN shipY = shipY - 1
    IF _KEYDOWN(CVI(CHR$(0) + "P")) THEN shipY = shipY + 1
    IF _KEYDOWN(CVI(CHR$(0) + "K")) THEN shipX = shipX - 1
    IF _KEYDOWN(CVI(CHR$(0) + "M")) THEN shipX = shipX + 1
    IF _KEYDOWN(27) THEN END


    IF shipX + 10 > 319 THEN shipX = 319 - 10
    IF shipX < 0 THEN shipX = 0
    IF shipY + 10 > 199 THEN shipY = 199 - 10
    IF shipY < 0 THEN shipY = 0


    IF numAsteroids > 0 THEN
        FOR asteroid = 1 TO numAsteroids

            _PUTIMAGE (asteroidx(asteroid), asteroidy(asteroid)), obstacle

            IF explosion = 0 THEN 'this is added so that the ship doesn't explode twice (it is invulnerable for a while)

                IF shipX + 10 >= asteroidx(asteroid) AND shipX <= asteroidx(asteroid) + 10 THEN
                    IF shipY + 10 >= asteroidy(asteroid) AND shipY <= asteroidy(asteroid) + 10 THEN


                        explosion = 1
                        lives = lives - 1

                    END IF
                END IF

            END IF

            asteroidx(asteroid) = asteroidx(asteroid) - asteroidspeed(asteroid)



            IF asteroidx(asteroid) < 0 - 10 THEN
                removeAsteroid = asteroid
            END IF


        NEXT
    END IF


    IF removeAsteroid <> 0 THEN
        FOR k = removeAsteroid TO numAsteroids
            asteroidx(k) = asteroidx(k + 1)
            asteroidy(k) = asteroidy(k + 1)
            asteroidspeed(k) = asteroidspeed(k + 1)
        NEXT
        numAsteroids = numAsteroids - 1
        removeAsteroid = 0
    END IF




    IF explosion = 1 THEN
        expl = expl + 1

        FOR k = 1 TO expl
            PSET (shipX - INT(RND * k), shipY - INT(RND * k)), INT(RND * 255)
            PSET (shipX + INT(RND * k), shipY + INT(RND * k)), INT(RND * 255)
            PSET (shipX - INT(RND * k), shipY + INT(RND * k)), INT(RND * 255)
            PSET (shipX + INT(RND * k), shipY - INT(RND * k)), INT(RND * 255)
        NEXT
        IF expl > 30 THEN expl = 0: explosion = 0
    END IF


    rand = INT(RND * (30 - (collected * 3))) + 1 '(collected*3) makes the asteroids more frequent
    IF rand = 1 THEN
        numAsteroids = numAsteroids + 1
        asteroidx(numAsteroids) = 319 + 10
        asteroidy(numAsteroids) = INT(RND * 219) + 1
        asteroidspeed(numAsteroids) = RND * 1.5 + .5 + ((collected + 1) / 50) '(collected+1)/50 makes them faster
    END IF



    IF heart = 0 THEN 'only if heart is 0 should we create one (it is already created otherwise)
        rand = INT(RND * 1000) + 1 'very seldom does a heart arrive
        IF rand = 1 THEN
            heart = 1
            heartX = 319 + 10
            heartY = INT(RND * 219) + 1
            heartSpeed = RND * 1.5 + .5
        END IF
    END IF

    'here we display the heart and handles the collision for the heart:
    IF heart = 1 THEN
        _PUTIMAGE (heartX, heartY), life
        heartX = heartX - heartSpeed

        IF heartX < -10 THEN heart = 0 'remove it if it goes outside the screen.

        IF shipX + 10 >= heartX AND shipX <= heartX + 10 THEN
            IF shipY + 10 >= heartY AND shipY <= heartY + 10 THEN
                'it collided with the heart!
                heart = 0 'set heart to 0 to remove it
                lives = lives + 1 'add 1 to lives

            END IF
        END IF

    END IF

    'we do the same for the numbers as with the heart:
    IF number = 0 THEN
        rand = INT(RND * 500) + 1 'very seldom does a number arrive
        IF rand = 1 THEN
            number = 1
            numberX = 319 + 10
            numberY = INT(RND * 219) + 1
            numberSpeed = RND * 1.5 + .5
        END IF
    END IF

    'here we display the number and handle the collision for the number:
    IF number = 1 THEN
        _PRINTSTRING (numberX, numberY), STR$(collected + 1) 'we use printstring to represent the number
        numberX = numberX - numberSpeed
        IF numberX < -10 THEN number = 0
        IF shipX + 10 >= numberX AND shipX <= numberX + 10 THEN
            IF shipY + 10 >= numberY AND shipY <= numberY + 10 THEN
                'it collided with the number!
                collected = collected + 1 'add one to the collected numbers
                number = 0 'set number to 0 to remove it
            END IF
        END IF
    END IF



    'loose:
    IF lives < 0 THEN
        LOCATE 10, 15: PRINT "GAME OVER"
        _DISPLAY: END
    END IF

    'win:
    IF collected = 9 THEN
        LOCATE 10, 16: PRINT "YOU WIN"
        _DISPLAY: END
    END IF



    _DISPLAY
LOOP

