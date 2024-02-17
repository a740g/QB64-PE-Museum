'$INCLUDE:'spritetop.bi'

DIM dksheet%
DIM mario%
DIM barrel%
DIM background&
DIM count%

SCREEN _NEWIMAGE(800, 600, 32)
CLS

dksheet% = SPRITESHEETLOAD("dkong.png", 64, 64, _RGB(0, 255, 0))
mario% = SPRITENEW(dksheet%, 1, SAVE)
barrel% = SPRITENEW(dksheet%, 67, SAVE)
SPRITEANIMATESET mario%, 1, 3
SPRITEANIMATION mario%, ANIMATE, FORWARDLOOP
SPRITESPEEDSET mario%, 1
SPRITEDIRECTIONSET mario%, 45
SPRITESPINSET mario%, 2
background& = _LOADIMAGE("backg.png", 32)
_PUTIMAGE (0, 0), background&
SPRITEPUT 199, 299, mario%
SPRITEMOTION mario%, MOVE
FOR count% = 1 TO 500
    _LIMIT 32
    IF count% = 250 THEN SPRITEDIRECTIONSET mario%, 135
    SPRITEPUT MOVE, MOVE, mario%
    SPRITEROTATE barrel%, SPRITEANGLE(barrel%, mario%)
    SPRITEPUT 399, 299, barrel%
    LOCATE 5, 1
    PRINT "Mario current spin  ="; SPRITEROTATION(mario%)
    PRINT "Barrel current spin ="; SPRITEROTATION(barrel%)
    _DISPLAY
NEXT count%
SPRITEMOTION mario%, DONTMOVE
SPRITEANIMATION mario%, NOANIMATE, FORWARDLOOP
SPRITEROTATE mario%, 0
SPRITESET mario%, 16
SPRITEPUT SPRITEX(mario%), SPRITEY(mario%), mario%
_DISPLAY

'$INCLUDE:'sprite.bi'
