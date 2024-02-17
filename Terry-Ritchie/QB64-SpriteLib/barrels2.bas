'$INCLUDE:'spritetop.bi'

CONST NUMBARRELS = 10

DIM barrels%(NUMBARRELS)
DIM barrel%
DIM dksheet%
DIM count%
DIM girder%
DIM background&

SCREEN _NEWIMAGE(800, 600, 32)
CLS
RANDOMIZE TIMER
background& = _LOADIMAGE("backg.png", 32)
dksheet% = SPRITESHEETLOAD("dkong.png", 64, 64, _RGB(0, 255, 0))
barrel% = SPRITENEW(dksheet%, 38, DONTSAVE)
girder% = SPRITENEW(dksheet%, 52, DONTSAVE)
_PUTIMAGE (0, 0), background&
FOR count% = 0 TO 12
    SPRITESTAMP count% * 64, 100, girder%
    SPRITESTAMP count% * 64, 200, girder%
    SPRITESTAMP count% * 64, 300, girder%
NEXT count%
_FREEIMAGE background&
background& = _COPYIMAGE(_DEST)
SPRITEANIMATESET barrel%, 38, 41
SPRITEANIMATION barrel%, ANIMATE, FORWARDLOOP
FOR count% = 1 TO NUMBARRELS
    barrels%(count%) = SPRITECOPY(barrel%)
    SPRITEPUT INT(RND(1) * 600) + 100, (INT(RND(1) * 3) + 1) * 100 - 32, barrels%(count%)
    SPRITESPEEDSET barrels%(count%), RND(3) - RND(3) + 3
    SPRITEDIRECTIONSET barrels%(count%), 90
    SPRITEMOTION barrels%(count%), MOVE
NEXT count%
SPRITEFREE barrel%
DO
    _LIMIT 32
    _PUTIMAGE (0, 0), background&
    FOR count% = 1 TO NUMBARRELS
        SPRITEPUT MOVE, MOVE, barrels%(count%)
        IF SPRITEX(barrels%(count%)) <= 0 THEN SPRITEREVERSEX barrels%(count%)
        IF SPRITEX(barrels%(count%)) >= _WIDTH(_DEST) THEN SPRITEREVERSEX barrels%(count%)
    NEXT count%
    _DISPLAY
LOOP UNTIL INKEY$ <> ""

'$INCLUDE:'sprite.bi'

