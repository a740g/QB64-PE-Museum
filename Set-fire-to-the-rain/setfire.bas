SCREEN _NEWIMAGE(800, 600, 32)

DO UNTIL _SCREENEXISTS: LOOP

$EXEICON:'./assets/Jaan-Jaak-Weather-Rain.ico'
'http://www.iconarchive.com/show/weather-icons-by-jaan-jaak/rain-icon.html
'Artist: Jaan-Jaak
'Iconset: Weather Icons (9 icons)
'License: CC Attribution-Share Alike 4.0
'Commercial usage: Allowed
_ICON

$VERSIONINFO:FILEVERSION#=0,0,0,1
$VERSIONINFO:PRODUCTVERSION#=0,0,0,1
$VERSIONINFO:CompanyName=Fellippe Heitor
$VERSIONINFO:FileDescription=Set Fire To The Rain game
$VERSIONINFO:FileVersion=0.1b
$VERSIONINFO:InternalName=setfire.bas
$VERSIONINFO:LegalCopyright=Open source
$VERSIONINFO:OriginalFilename=setfire.exe
$VERSIONINFO:ProductName=Set Fire To The Rain game
$VERSIONINFO:ProductVersion=0.1b
$VERSIONINFO:Comments=This is in no way shape or form endorsed by Adele. Made with QB64.
$VERSIONINFO:Web=http://www.qb64.net/forum/index.php?topic=14285.msg123566#msg123566

_TITLE "Set fire to the rain"

COLOR , 0

TYPE gridType
    x AS SINGLE
    y AS SINGLE
    xv AS SINGLE
    yv AS SINGLE
    size AS INTEGER
    color AS SINGLE
END TYPE

s = 10

DIM grid(1 TO INT(_WIDTH / s), 1 TO INT(_HEIGHT / s)) AS gridType
DIM rainDrops(1 TO 1000) AS gridType
DIM smoke(1 TO 1000) AS gridType, smokeIndex AS INTEGER

DIM SHARED bgmusic AS LONG, theFont AS LONG

theFont = _LOADFONT("ariblk.ttf", 32)
IF theFont > 0 THEN _FONT theFont

m$ = "Get ready..."
_PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2, _HEIGHT / 2 - _FONTHEIGHT / 2), m$

f$ = "./assets/setfire.mp3"
'from https://www.youtube.com/watch?v=sHosuM4TlFU
'http://www.mediafire.com/?jy4id9645i88kko
bgmusic = _SNDOPEN(f$, "vol,pause,setpos")

IF bgmusic > 0 THEN
    _SNDSETPOS bgmusic, 4.3
    _SNDPLAY bgmusic
END IF

GOSUB ResetRain

DO
    GOSUB resetFire

    start# = TIMER

    DO
        WHILE _MOUSEINPUT: WEND

        CLS

        FOR i = 1 TO UBOUND(smoke)
            IF smoke(i).color > 0 THEN
                LINE (smoke(i).x, smoke(i).y)-STEP(s - 1, s - 1), _RGB32(smoke(i).color, smoke(i).color, smoke(i).color), BF
                smoke(i).color = smoke(i).color - 10
                smoke(i).x = smoke(i).x
                smoke(i).y = smoke(i).y - s
            END IF
        NEXT

        GOSUB UpdateRain

        fullFire = -1
        FOR i = 1 TO UBOUND(grid, 1)
            FOR j = 1 TO UBOUND(grid, 2)
                IF grid(i, j).color > 0 THEN
                    LINE (grid(i, j).x, grid(i, j).y)-STEP(grid(i, j).size - 1, grid(i, j).size - 1), _RGB32(grid(i, j).color, map(grid(i, j).y, 0, _HEIGHT - 1, grid(i, j).color, grid(i, j).color / 3), 0), BF
                END IF
                IF grid(i, j).color < 255 THEN fullFire = 0
                IF grid(i, j).color > 245 THEN GOSUB addSmoke
            NEXT
        NEXT

        IF _MOUSEX > 0 AND _MOUSEY > 0 THEN
            i = INT(_MOUSEX / s) + 1
            j = INT(_MOUSEY / s) + 1
            IF _MOUSEBUTTON(1) THEN
                grid(i, j).color = 255
            END IF
        END IF

        radius = 2
        FOR i = 1 TO UBOUND(grid, 1)
            FOR j = 1 TO UBOUND(grid, 2)
                IF grid(i, j).color > 150 THEN
                    FOR k = -radius TO radius
                        FOR l = -radius TO radius
                            IF i + k < 1 OR j + l < 1 THEN GOTO skip
                            IF i + k > UBOUND(grid, 1) OR j + l > UBOUND(grid, 2) THEN GOTO skip
                            grid(i + k, j + l).color = grid(i + k, j + l).color + 2
                            IF grid(i + k, j + l).color > 255 THEN grid(i + k, j + l).color = 255
                            skip:
                        NEXT
                    NEXT
                ELSEIF grid(i, j).color = 0 THEN
                    FOR k = -radius TO radius
                        FOR l = -radius TO radius
                            IF i + k < 1 OR j + l < 1 THEN GOTO skip2
                            IF i + k > UBOUND(grid, 1) OR j + l > UBOUND(grid, 2) THEN GOTO skip2
                            grid(i + k, j + l).color = grid(i + k, j + l).color - 1.5
                            IF grid(i + k, j + l).color < 0 THEN grid(i + k, j + l).color = 0
                            skip2:
                        NEXT
                    NEXT
                END IF
            NEXT
        NEXT

        _PRINTSTRING (0, _HEIGHT - _FONTHEIGHT), STR$(INT(TIMER - start#)) + " s"

        k = _KEYHIT
        IF k = 27 THEN SYSTEM

        IF k = ASC("m") OR k = ASC("M") THEN
            mute = NOT mute
            IF bgmusic > 0 THEN
                IF _SNDPLAYING(bgmusic) THEN
                    _SNDPAUSE bgmusic
                    _SNDSETPOS bgmusic, 4.3
                END IF
            END IF
        END IF

        _LIMIT 60
        _DISPLAY
        IF bgmusic > 0 THEN
            IF NOT _SNDPLAYING(bgmusic) AND NOT mute THEN _SNDPLAY bgmusic
        END IF
    LOOP UNTIL fullFire

    finish# = TIMER

    IF bgmusic > 0 THEN
        _SNDSETPOS bgmusic, 64.5
        IF NOT _SNDPLAYING(bgmusic) AND NOT mute THEN _SNDPLAY bgmusic
    END IF

    WHILE _MOUSEBUTTON(1): i = _MOUSEINPUT: WEND
    GOSUB ResetRain
    DO
        WHILE _MOUSEINPUT: WEND

        CLS

        FOR i = 1 TO UBOUND(grid, 1)
            FOR j = 1 TO UBOUND(grid, 2)
                IF grid(i, j).color > 0 THEN
                    LINE (grid(i, j).x, grid(i, j).y)-STEP(grid(i, j).size, grid(i, j).size), _RGB32(grid(i, j).color, map(grid(i, j).y, 0, _HEIGHT - 1, grid(i, j).color, grid(i, j).color / 3), 0), BF
                    grid(i, j).color = grid(i, j).color - 4
                END IF
            NEXT
        NEXT

        GOSUB UpdateRain

        COLOR _RGB32(0, 0, 0), 0
        m$ = "All's burned. Adele's so proud of you."
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2 + 1, _HEIGHT / 2 - _FONTHEIGHT / 2 + 1), m$
        m$ = "It took you" + STR$(INT(finish# - start#)) + " seconds."
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2 + 1, _HEIGHT / 2 - _FONTHEIGHT / 2 + _FONTHEIGHT + 1), m$
        m$ = "Click anywhere to restart"
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2 + 1, _HEIGHT - _FONTHEIGHT + 1), m$

        COLOR _RGB32(255, 255, 255), 0
        m$ = "All's burned. Adele's so proud of you."
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2, _HEIGHT / 2 - _FONTHEIGHT / 2), m$
        m$ = "It took you" + STR$(INT(finish# - start#)) + " seconds."
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2, _HEIGHT / 2 - _FONTHEIGHT / 2 + _FONTHEIGHT), m$
        m$ = "Click anywhere to restart"
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(m$) / 2 + 1, _HEIGHT - _FONTHEIGHT), m$

        _LIMIT 30
        _DISPLAY

    LOOP UNTIL _MOUSEBUTTON(1) OR _KEYHIT <> 0


    IF bgmusic > 0 THEN
        _SNDSETPOS bgmusic, 4.3
        IF NOT _SNDPLAYING(bgmusic) AND NOT mute THEN _SNDPLAY bgmusic
    END IF
LOOP

UpdateRain:
FOR i = 1 TO UBOUND(rainDrops)
    rainDrops(i).y = rainDrops(i).y + rainDrops(i).yv
    rainDrops(i).yv = rainDrops(i).yv + .1
    rainDrops(i).x = rainDrops(i).x + rainDrops(i).xv
    rainDrops(i).xv = rainDrops(i).xv - .1
    IF rainDrops(i).y > _HEIGHT OR rainDrops(i).x < 0 THEN
        rainDrops(i).yv = 0
        rainDrops(i).xv = 0
        rainDrops(i).x = RND * _WIDTH * 2
        rainDrops(i).y = -RND * _HEIGHT
    END IF
    LINE (rainDrops(i).x, rainDrops(i).y)-STEP(-2, 5), _RGB32(0, 89, 155)

    k = INT((rainDrops(i).x - 1) / s) + 1
    l = INT((rainDrops(i).y + 5) / s) + 1
    IF k > 1 AND k < UBOUND(grid, 1) AND l > 1 AND l < UBOUND(grid, 2) THEN
        IF grid(k, l).color < 200 AND NOT fullFire THEN grid(k, l).color = 0
    END IF
NEXT
RETURN

resetFire:
FOR i = 1 TO UBOUND(grid, 1)
    FOR j = 1 TO UBOUND(grid, 2)
        grid(i, j).x = s * i - s
        grid(i, j).y = s * j - s
        grid(i, j).size = s
        grid(i, j).color = 0
    NEXT
NEXT
RETURN

ResetRain:
FOR i = 1 TO UBOUND(rainDrops)
    rainDrops(i).yv = 0
    rainDrops(i).xv = 0
    rainDrops(i).x = RND * _WIDTH * 2
    rainDrops(i).y = -(RND * (_HEIGHT * 2))
NEXT
RETURN

addSmoke:
IF j - 1 > 0 THEN
    IF grid(i, j - 1).color < 200 THEN
        smokeIndex = smokeIndex + 1
        IF smokeIndex > UBOUND(smoke) THEN smokeIndex = 1
        smoke(smokeIndex).x = i * s - s
        smoke(smokeIndex).y = (j - 1) * s - s
        smoke(smokeIndex).color = 100
    END IF
END IF
RETURN


FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

