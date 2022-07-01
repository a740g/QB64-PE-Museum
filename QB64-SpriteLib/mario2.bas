'$INCLUDE:'spritetop.bi'

DIM dksheet%
DIM mario%
DIM background&
DIM count%
DIM girder%

SCREEN _NEWIMAGE(800, 600, 32)
CLS

dksheet% = SPRITESHEETLOAD("dkong.png", 64, 64, _RGB(0, 255, 0))
mario% = SPRITENEW(dksheet%, 1, SAVE)
girder% = SPRITENEW(dksheet%, 52, DONTSAVE)
SPRITEANIMATESET mario%, 1, 3
SPRITEANIMATION mario%, ANIMATE, FORWARDLOOP
SPRITESPEEDSET mario%, 3
SPRITEDIRECTIONSET mario%, 90
background& = _LOADIMAGE("backg.png", 32)
_PUTIMAGE (0, 0), background&
FOR count% = 0 TO 12
    SPRITESTAMP count% * 64, 300, girder%
NEXT count%
SPRITEPUT 199, 268, mario%
SPRITEMOTION mario%, MOVE
DO
    _LIMIT 16
    IF SPRITEX(mario%) <= 32 THEN
        SPRITEREVERSEX mario%
        SPRITEFLIP mario%, NONE
    END IF
    IF SPRITEX(mario%) >= _WIDTH(_DEST) - 32 THEN
        SPRITEREVERSEX mario%
        SPRITEFLIP mario%, HORIZONTAL
    END IF
    SPRITEPUT MOVE, MOVE, mario%
    _DISPLAY
LOOP UNTIL INKEY$ <> ""
SPRITEMOTION mario%, DONTMOVE
SPRITEANIMATION mario%, NOANIMATE, FORWARDLOOP
SPRITESET mario%, 16
SPRITEPUT SPRITEX(mario%), SPRITEY(mario%), mario%
_DISPLAY

'$INCLUDE:'sprite.bi'
