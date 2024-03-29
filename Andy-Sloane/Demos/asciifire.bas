_DEFINE A-Z AS LONG
OPTION _EXPLICIT

DIM screenWidth AS LONG: screenWidth = _WIDTH
DIM screenHeight AS LONG: screenHeight = _HEIGHT
DIM screenChars AS LONG: screenChars = screenWidth * screenHeight
DIM bufferSize AS LONG: bufferSize = screenWidth * (screenHeight + 1) - 1

DIM b(0 TO bufferSize + 1) AS LONG

DO
    LOCATE 1, 1
    DIM j AS LONG: FOR j = 1 TO bufferSize
        IF j < screenChars THEN
            b(j) = (b(j + 79) + b(j + 80) + b(j) + b(j - 1) + b(j + 81)) \ 5
        ELSE
            IF INT(RND * 4) THEN
                b(j) = 0
            ELSE
                b(j) = 512
            END IF
        END IF

        IF j <= 1920 THEN
            SELECT CASE (j MOD 80)
                CASE 0
                    PRINT CHR$(ASC("  .:*#$H@    ", b(j) \ 32 + 1))

                CASE 79
                    PRINT CHR$(ASC("  .:*#$H@    ", b(j) \ 32 + 1));

                CASE ELSE
                    PRINT CHR$(ASC("  .:*#$H@    ", b(j) \ 32 + 1));
            END SELECT
        END IF
    NEXT j

    _LIMIT 30
LOOP UNTIL _KEYHIT = 27

SYSTEM
