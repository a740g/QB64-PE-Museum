OPTION _EXPLICIT '                          Get into this habit and save yourself grief from Typos

_TITLE "Missile Command EnRitchied" '     another b+ mod 2023-06-24, replace distance with _Hypot.
'                                   I probably picked up this game at the JB forum some years ago.

'    Get Constants, Shared Variables and Arrays() declared. These Will Start with Capital Letters.
'        Get Main module variables and arrays declared with starting lower case letters for local.
'         This is what Option _Explicit helps, by forcing us to at least declare these before use.
'       While declaring, telling QB64 the Type we want to use, we can also give brief description.


CONST ScreenWidth = 800, ScreenHeight = 600 '                     for our custom screen dimensions
DIM AS INTEGER bombX, bombY '                          incoming bomb screen position to shoot down
DIM AS SINGLE bombDX, bombDY '                  DX and DY mean change in X position and Y position
DIM AS INTEGER missileX, missileY '                                               missile position
DIM AS SINGLE missileDX, missileDY '                            change X and Y of Missile position
DIM AS INTEGER hits, misses '                                                score hits and misses
DIM AS INTEGER mouseDistanceX, mouseDistanceY '       for calculations of missile DX, DY direction
DIM AS SINGLE distance '                                                                     ditto
DIM AS INTEGER radius '                                      drawing hits with target like circles
DIM AS INTEGER boolean '                         to shorten the code line with a bunch of OR tests

SCREEN _NEWIMAGE(ScreenWidth, ScreenHeight, 32) ' sets up a graphics screen with custom dimensions
'                                          the 32 is for _RGB32(red, green, blue, alpha) coloring.
'
_SCREENMOVE 250, 60 '             this centers screen in my laptop, you may need different numbers

InitializeForRound: '                             reset game and start a round with a bomb falling
CLS
bombX = RND * ScreenWidth '                                starts bomb somewhere across the screen
bombY = 0 '                                                           starts bomb at top of screen
bombDX = RND * 6 - 3 '                                  pick rnd dx = change in x between -3 and 3
bombDY = RND * 3 + 3 '                 pick rnd dy = change in y between 3 and 6,  > 0 for falling
missileX = ScreenWidth / 2 '                                  missile base at middle across screen
missileY = ScreenHeight - 4 '   missile launch point at missile base is nearly at bottom of screen
missileDX = 0 '                           missile is not moving awaiting mouse click for direction
missileDY = 0 '                                                                              ditto
distance = 0 '                                             distance of mouse click to missile base

DO
    'what's the score?
    _TITLE "Click mouse to intersect incoming   Hits:" + STR$(hits) + ", misses:" + STR$(misses)
    _PRINTSTRING (400, 594), "^" '                                 draw missle base = launch point
    WHILE _MOUSEINPUT: WEND '                                             poll mouse to get update
    IF _MOUSEBUTTON(1) THEN '               the mouse was clicked calc the angle from missile base
        mouseDistanceX = _MOUSEX - missileX
        mouseDistanceY = _MOUSEY - missileY

        'distance = (mouseDistanceX ^ 2 + mouseDistanceY ^ 2) ^ .5
        '                   rewrite the above line using _Hypot() which is hidden distance forumla
        distance = _HYPOT(mouseDistanceX, mouseDistanceY)

        missileDX = 5 * mouseDistanceX / distance
        missileDY = 5 * mouseDistanceY / distance
    END IF

    missileX = missileX + missileDX '                                      update missile position
    missileY = missileY + missileDY '                                                        ditto
    bombX = bombX + bombDX '                                                  update bomb position
    bombY = bombY + bombDY '                                                                 ditto

    '                     I am about to use a boolean variable to shorten a very long IF code line
    '                                 boolean is either 0 or -1 when next 2 statements are execued
    '                                            -1/0 or True/False is everything still in screen?
    boolean = missileX < 0 OR missileY < 0 OR bombX < 0 OR bombY < 0
    boolean = boolean OR missileX > ScreenWidth OR bombX > ScreenWidth OR bombY > ScreenHeight
    IF boolean THEN '                                                       done with this boolean
        '   reuse boolean to shorten another long code line checking if bomb and missile in screen
        boolean = bombY > ScreenHeight OR missileX < 0 OR missileY < 0 OR missileX > ScreenWidth
        IF boolean THEN misses = misses + 1
        GOTO InitializeForRound
    END IF

    '     if the distance between missle and bomb < 20 pixels then the missile got the bomb, a hit
    'If ((missileX - bombX) ^ 2 + (missileY - bombY) ^ 2) ^ .5 < 20 Then '  show  strike as target
    '                       rewrite the above line using _Hypot() which is hidden distance forumla
    IF _HYPOT(missileX - bombX, missileY - bombY) < 20 THEN

        FOR radius = 1 TO 20 STEP 4 '                        draw concetric circles to show strike
            CIRCLE ((missileX + bombX) / 2, (missileY + bombY) / 2), radius
            _LIMIT 60
        NEXT
        hits = hits + 1 '                                                    add hit to hits score
        GOTO InitializeForRound
    ELSE
        CIRCLE (missileX + 4, missileY), 2, &HFFFFFF00 '+4 center on ^ base  draw    missle yellow
        CIRCLE (bombX, bombY), 2, &HFF0000FF '                                      draw bomb blue
    END IF
    _LIMIT 20
LOOP
