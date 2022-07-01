'$INCLUDE:'spritetop.bi'

CONST NUMBARRELS = 25

DIM barrels%(NUMBARRELS)
DIM barrel%
DIM mario%
DIM dksheet%
DIM count%
DIM background&

SCREEN _NEWIMAGE(800, 600, 32)
CLS
RANDOMIZE TIMER
background& = _LOADIMAGE("backg.png", 32)
dksheet% = SPRITESHEETLOAD("dkong.png", 64, 64, _RGB(0, 255, 0))
barrel% = SPRITENEW(dksheet%, 38, DONTSAVE)
mario% = SPRITENEW(dksheet%, 1, DONTSAVE)
_PUTIMAGE (0, 0), background&
SPRITEANIMATESET barrel%, 38, 41
SPRITEANIMATION barrel%, ANIMATE, FORWARDLOOP
SPRITECOLLIDETYPE barrel%, PIXELDETECT
SPRITECOLLIDETYPE mario%, PIXELDETECT
FOR count% = 1 TO NUMBARRELS
    barrels%(count%) = SPRITECOPY(barrel%)
    SPRITEPUT INT(RND(1) * 200) + 50, INT(RND(1) * 100) + 50, barrels%(count%)
    SPRITESPEEDSET barrels%(count%), RND(3) - RND(3) + 3
    SPRITEDIRECTIONSET barrels%(count%), INT(RND(1) * 360)
    SPRITEMOTION barrels%(count%), MOVE
NEXT count%
SPRITEFREE barrel%
DO
    _LIMIT 32
    _PUTIMAGE (0, 0), background&
    FOR count% = 1 TO NUMBARRELS
        SPRITEPUT 399, 299, mario%
        SPRITEPUT MOVE, MOVE, barrels%(count%)
        IF SPRITEX(barrels%(count%)) <= 0 THEN SPRITEREVERSEX barrels%(count%)
        IF SPRITEX(barrels%(count%)) >= _WIDTH(_DEST) THEN SPRITEREVERSEX barrels%(count%)
        IF SPRITEY(barrels%(count%)) <= 0 THEN SPRITEREVERSEY barrels%(count%)
        IF SPRITEY(barrels%(count%)) >= _HEIGHT(_DEST) THEN SPRITEREVERSEY barrels%(count%)
    NEXT count%
    IF SPRITECOLLIDE(mario%, ALLSPRITES) THEN
        SPRITEPUT MOVE, MOVE, SPRITECOLLIDEWITH(mario%)
        SPRITESET mario%, 4
    ELSE
        SPRITESET mario%, 1
    END IF
    _DISPLAY
LOOP UNTIL INKEY$ <> ""

'$INCLUDE:'sprite.bi'

