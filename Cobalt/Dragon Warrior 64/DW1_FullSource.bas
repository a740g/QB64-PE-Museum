'Dragon Warrior 64, Final Update Release: 5/25/2020 1:35pm EST
'UniKorn ProDucKions
'Cobalt (AKA David)
'Bug fix Release Ver. 012(8/26/2021)

REM'$include:'DW1_Types.bas'
REM'$include:'DW1_Arrays.bas'
REM'$include:'DW1_Const.bas'
REM'$include:'DW1_Layers.bas'
REM'$include:'DW1_Timers.bas'

TYPE Player
    Nam AS STRING * 8 '24 'eventually
    HP AS _UNSIGNED _BYTE
    Max_HP AS _UNSIGNED _BYTE
    MP AS _UNSIGNED _BYTE
    Max_MP AS _UNSIGNED _BYTE
    Pack AS STRING * 32 '_MEM
    Items AS _BYTE 'items in pack
    Armor AS _BYTE
    Weapon AS _BYTE
    Shield AS _BYTE
    Scale AS _BYTE 'did the player use Dragon's Scale?
    Gold AS _UNSIGNED INTEGER
    Exp AS _UNSIGNED INTEGER
    Age AS _BYTE 'as player gains experiance levels they age, age negativliy affects stats.
    Strength AS _BYTE
    Agility AS _BYTE
    Luck AS _BYTE
    Level AS _BYTE
    Spells AS INTEGER
    WorldX AS _BYTE 'players location in over world
    WorldY AS _BYTE
    MapX AS _BYTE 'players location in a castle\town or cave\temple
    MapY AS _BYTE
    Map AS _BYTE 'where is player? -1 to 27 (-1 = over world map)
    Facing AS _BYTE
    WX AS _BYTE 'used when player is walking
    WY AS _BYTE
    Keys AS _BYTE 'number of keys player has (6max)
    Herbs AS _BYTE 'how many Herbs player has, different from items in pack
    Princess_Saved AS _BYTE 'has player saved Princess?
    Has_Princess AS _BYTE 'is player carring Princess?
    Has_Stones AS _BYTE 'does player have stones of sunlight?
    Has_Drop AS _BYTE 'does player have Rainbow drop
    Has_Harp AS _BYTE 'has player found cursed harp?
    Has_Token AS _BYTE 'has player found edricks token?
    Has_Staff AS _BYTE 'Has Player Found Staff Of Rain?
    Has_Flute AS _BYTE
    Cursed AS _BYTE 'did the player equip a cursed item?
    Def_Mod AS _BYTE 'adjusted defence modifier when cursed!
    HP_Mod AS _BYTE 'adjusted hit point modifier when cursed!
    Is_Repel AS _BYTE 'number of steps player has left of repeling weaker monsters
    Torched AS _BYTE 'is player using a torch to see
    Radiant AS _UNSIGNED _BYTE 'did player case radiant spell 80-3(200-120), 60-2(120-60), 60-1(60-0): 200 total steps of light
    Is_Asleep AS _BYTE 'did player get put to sleep?
    Is_Blocked AS _BYTE 'did player get spell stopped?
END TYPE

TYPE Monsters
    Nam AS STRING * 16
    Strength AS _UNSIGNED _BYTE
    Agility AS _UNSIGNED _BYTE
    Hp AS _UNSIGNED _BYTE
    Max_Hp AS _UNSIGNED _BYTE
    Mp AS _UNSIGNED _BYTE
    Max_Mp AS _UNSIGNED _BYTE
    SlpResist AS _UNSIGNED _BYTE
    StpSplResist AS _UNSIGNED _BYTE
    HurtResist AS _UNSIGNED _BYTE
    Evasion AS _UNSIGNED _BYTE
    Exp AS _UNSIGNED _BYTE
    Gold AS _UNSIGNED _BYTE
    Attk1 AS _BYTE 'special attack 1 - these are additional options to normal physical attack
    Attk1Prob AS _UNSIGNED _BYTE
    Attk2 AS _BYTE 'special attack 2
    Attk2Prob AS _UNSIGNED _BYTE
    Group AS _BYTE
    Is_Asleep AS _BYTE 'did monster get put to sleep?
    Is_Blocked AS _BYTE 'did monster get spell stopped?
END TYPE

TYPE GameData
    Y AS _BYTE
    X AS _BYTE
    Flag AS _BYTE 'triggered when player is moving
    JustLeft AS _BYTE 'if player just left town\castle don't reprocess location
    In_Place AS _BYTE 'player is in a town\castle
    LastMove AS LONG 'timer, if player doesn't press any keys his current stats display
    Menu AS _BYTE 'does player have the menu up?
    Selection AS _BYTE 'what selection did player make from menu
    Message AS INTEGER 'current message displayed via Controls menu
    Input_Wait AS _BYTE 'waiting for player input, after message display
    Action AS _BYTE 'what action is player currently performing?(talk,search,stair,take,door,spell,item)
    Lite_Level AS _BYTE 'how much light is there 0-none, 1-torch 2&3-Radiant
    Display_Status AS _BYTE
    Current_BGM AS _BYTE 'which music is currently in background
    f AS INTEGER 'number of cycles completed perframe(AKA:Frames Per Sec)
    SaveFile AS _BYTE 'Adventure log player is using to save 1-3
    MessageSpeed AS _BYTE 'how fast messages are displayed 1-3
    TextClick AS _BYTE 'Controls the 'typing' sound when displaying a message
    Price AS INTEGER ' price of item used in message processing
    ItemID AS _BYTE 'the item player is trying to buy from shop
    PrincessFlag AS _BYTE 'set the first time player talks to princess after rescue.
    Battle AS _BYTE 'what monster is player fighting
    Cast AS _BYTE 'what spell is player casting?
    Damage AS _BYTE 'how much damage was done by last attack, both monster and player
    ExcelHit AS _BYTE 'did player score an excellent hit?
    Old_Str AS _BYTE 'players strength before level up
    Old_Agl AS _BYTE 'players agility before level up
    Old_Mhp AS _UNSIGNED _BYTE 'players max health before level up
    Old_Mmp AS _UNSIGNED _BYTE 'players max magic before level up
    Sleeps AS _BYTE 'how many rounds has player been asleep?
    ControlType AS _BYTE 'player using Keyboard or Joypad?
    BGMVol AS SINGLE 'music volume
    SFXVol AS SINGLE 'Sound fx volume
    Device_Count AS _BYTE 'Total input Devices aviliable
    In_Building AS _BYTE 'is the player currently in a building?
    SkipIntro AS _BYTE ' if player has already watched intro allow skipping of intro
    GameOver_Bad AS _BYTE 'player sided with Dragon Lord... poor life choice!
    GameOver_Good AS _BYTE 'player defeated Dragon Lord
    GameOver_Great AS _BYTE 'Player defeated Dragon Lord and Saved Princess... Excellent choice!
    Attack_Bonus AS _BYTE 'player cast Strenthen +25% hit damage against monster
    Defence_Bonus AS _BYTE 'player cast quicken -25% hit damage from monster
END TYPE

TYPE ControllerKeys
    KBCon_Up AS LONG
    KBCon_Down AS LONG
    KBCon_Left AS LONG
    KBCon_Right AS LONG
    KBCon_Select AS LONG
    KBCon_Start AS LONG
    KBCon_A_Button AS LONG
    KBCon_B_Button AS LONG

    Control_Pad AS _BYTE 'which Gamepad\Joystick Device Is player Using?
    BAD_Pad AS _BYTE 'option for Buttons As Directions
    Joy_Up AS _BYTE 'axis for up
    Joy_Up_Val AS _BYTE 'axis value for up
    Joy_Down AS _BYTE 'axis for down
    Joy_Down_Val AS _BYTE 'axis value for down
    Joy_Left AS _BYTE 'axis for left
    Joy_Left_Val AS _BYTE 'axis value for left
    Joy_Right AS _BYTE 'axis for right
    Joy_Right_Val AS _BYTE 'axis value for right
    Joy_Select AS _BYTE
    Joy_Start AS _BYTE
    Joy_A_Button AS _BYTE
    Joy_B_Button AS _BYTE
    Joy_Button_Up AS _BYTE 'for people whos controllers give BUTTON states for direction keys
    Joy_Button_Down AS _BYTE 'or just want to use buttons for the direction keys.
    Joy_Button_Left AS _BYTE '""""
    Joy_Button_Right AS _BYTE 'however this fails to work so may not be implemented.
END TYPE

TYPE Non_Playable_Character
    Sprite_ID AS _BYTE
    X AS _BYTE 'NPCs location
    Y AS _BYTE
    Map AS _BYTE 'Which town\castle\cave do they live in
    Facing AS _BYTE
    Lines AS _BYTE 'What lines do they say
    Flag AS _BYTE 'used if they change what they say over time
    Can_Move AS _BYTE
    Moving AS _BYTE
    MX AS _BYTE 'used to adjust position when NPC is moving
    MY AS _BYTE '""""""""""""""""""""""""""""""""""""""""""
    Zone AS _BYTE 'controls NPC movement so they don't go walkabout
    Done AS _BYTE 'Is NPC no longer needed?
END TYPE

TYPE Tiles
    Sprite_ID AS _BYTE 'sprite used on tile
    Is_Town AS _BYTE 'Town ID/Castle ID
    Is_Cave AS _BYTE 'Cave ID
    Is_Stairs AS _BYTE 'Stairs ID
    Is_Entrance AS _BYTE 'Entrance to BUilding (value is entrance ID)
    Building_Exit AS _BYTE 'exit a building (Value is exit ID)
    Territory AS _BYTE 'Monster selection ID, determines which monster are picked for battle
    Is_Exit AS _BYTE 'does tile lead out of castle or town
    Encounter_rate AS _UNSIGNED _BYTE 'odds of engaging a monster
    Has_Special AS _BYTE 'does search find something here or is special battle here
    NPCZone AS _BYTE 'which NPC can walk here or a simple blocking tile to stop NPC.
END TYPE

TYPE Flags
    Has_Left_Throne_Room AS _BYTE 'set when Player first leave thrown room after starting game.
    Just_Started AS _BYTE 'Set when player first starts game
    Saved_Princess AS _BYTE 'Set after Player has Brought Princess back
    Has_Proof AS _BYTE 'Set when player finds proof of ancestry
    Made_Bridge AS _BYTE 'set after player uses Rainbow Drop and makes Bridge
    YNFlag AS _BYTE 'set if a message dialog needs a Yes or No response
    Dragon_King_Killed AS _BYTE
    Defeated_In_Battle AS _BYTE 'player was killed
    PlayClick AS _BYTE 'to play or not to play talking click.
    Defeated_Golem AS _BYTE
    Defeated_Green_Dragon AS _BYTE
    RainBow_Bridge_Done AS _BYTE 'has player made rainbow bridge
    Defeated_Axe_Knight AS _BYTE
    Found_Hidden_Stair AS _BYTE
    Found_DeathNecklace AS _BYTE 'Death necklace is a one time find, that curses player
END TYPE

TYPE Treasure_Chest
    Map AS _BYTE
    X AS _BYTE
    Y AS _BYTE
    Treasure AS _BYTE
    Count AS INTEGER
    Opened AS _BYTE
END TYPE

TYPE Stair_Data
    Map AS _BYTE 'where is the stairs
    X AS _BYTE 'stairs position
    Y AS _BYTE
    Direction AS _BYTE 'going up or down
    Link AS _BYTE 'links to which other stairs
END TYPE

TYPE Door_Data
    X AS _BYTE
    Y AS _BYTE
    Map AS _BYTE
    Opened AS _BYTE
END TYPE

TYPE Items
    Nam AS STRING * 16
    Valu AS INTEGER
    Power AS _BYTE
END TYPE

TYPE Menu_Data
    HName AS STRING * 8
    MesSpd AS _BYTE
    CurLvl AS _BYTE
END TYPE

TYPE Name_Select
    X AS _BYTE 'selection arrow X
    Y AS _BYTE 'Selection arrow Y
    C AS _BYTE 'Character associated with selection
END TYPE

TYPE Place_Data
    Start_X AS _BYTE 'when Entering where do you start.
    Start_Y AS _BYTE '
    Is_Lit AS _BYTE 'is a Torch or Radiant needed to see?
END TYPE


TYPE Cords
    X AS _BYTE
    Y AS _BYTE
END TYPE

TYPE Messaging
    LineCount AS _BYTE
    LineID AS _UNSIGNED _BYTE
END TYPE

TYPE KeyCodeData
    Nam AS STRING * 8
    Value AS LONG
END TYPE

TYPE DEVICE_Info
    Buttons AS INTEGER
    Axis_p AS _BYTE
END TYPE

DIM SHARED P AS Player 'Player stats and data
DIM SHARED G AS GameData 'game data
DIM SHARED F AS Flags 'game flags
DIM SHARED C AS ControllerKeys 'Custom controls
DIM SHARED I(127) AS Items 'Item data
DIM SHARED M(64) AS Monsters 'Monster stats and data
DIM SHARED L(30) AS _UNSIGNED INTEGER 'level ups
DIM SHARED GF(5) AS SINGLE 'group factor\used in determining escape posibilities
DIM SHARED SA(10) AS Cords 'selection arrow positions
DIM SHARED BSA(4) AS Cords 'selection arrow positions battle commands
DIM SHARED World(127, 127) AS Tiles 'World data
DIM SHARED Place(27, 45, 45) AS Tiles 'Map data
DIM SHARED PD(-1 TO 27) AS Place_Data 'Where the player starts, if map is prelit, ect
DIM SHARED Stairs(127) AS Stair_Data 'Where all stairs in game lead
DIM SHARED Chest(63) AS Treasure_Chest 'Where each chest is and what it contains
DIM SHARED Shop(16, 10) AS _BYTE
DIM SHARED Doors(24) AS Door_Data 'doors in game
DIM SHARED MZG(19, 4) AS _BYTE 'Monsters by Zone Group
DIM SHARED Entrance(80) AS Stair_Data 'entrances\exits to buildings

DIM SHARED NPC(127) AS Non_Playable_Character 'Data and controls for NPCs
DIM SHARED Messages(400, 1) AS INTEGER, Displayed AS _BYTE '0-line count, 1-LINES() ID
DIM SHARED Script(384) AS STRING 'All the lines spoken in the game by NPCs
DIM SHARED Lines(400, 8) AS INTEGER 'dialog for Messages 0-8 lines of script(9 max)

DIM SHARED Layer(64) AS LONG, DWFont AS LONG, Frame%%, SFX(32) AS LONG, BGM(-1 TO 27) AS LONG, Title AS LONG, Starting AS LONG, Frames%, MenuD(3) AS Menu_Data 'internal data
DIM SHARED Spells(16) AS STRING 'Spell names
DIM SHARED T(5) AS LONG 'game timers
DIM SHARED LS(63) AS Name_Select 'used for selecting Hero Name
DIM SHARED ClearLayerMaster AS _MEM, CLM$ 'Advanced Clearlayer data
DIM SHARED KeyCodes(134) AS KeyCodeData, DeviceData(16) AS DEVICE_Info
DIM SHARED Map_Music(-1 TO 30) AS _BYTE, Move_Delay AS SINGLE
DIM SHARED Quit_Game_Flag AS _BYTE 'when player chooses to quit game


CONST TRUE = -1, FALSE = NOT TRUE
CONST DOWN = 0, LEFT = 1, UP = 2, RIGHT = 3, SELECT_BUTTON = 4, START_BUTTON = 5, BUTTON_B = 6, BUTTON_A = 7
CONST Default_Key_Right = 19712, Default_Key_Left = 19200, Default_Key_Up = 18432, Default_Key_Down = 20480
CONST Default_A_Button = 32, Default_B_Button = 13, Default_Start_Button = 65, Default_Select_Button = 66
CONST MoveDown = 1, MoveLeft = 2, MoveUp = 3, MoveRight = 4, ESC_Key = 27
CONST SLUMBER = 3 'since sleep is already taken!
CONST STOPSPELL = 5, HEAL = 1, HEALMORE = 9, HURT = 2, HURTMORE = 10
CONST DEAD = 255, RANAWAY = -4, FIRE_LOW_LEVEL = 16, FIRE_HIGH_LEVEL = 17
CONST CASTSPELL = 374, ATTACK = 352, FIREBREATH = 379, NOTENOUGHMP = 378, MISSES = 353, BLOCKED = 375
CONST SPELLFAIL = 360, SPELLBLOCKED = 373, MISSED = 351, ITSAHIT = 350, ASLEEP = 376, ITSCRITICAL = 356
CONST DODGEDIT = 357
CONST DOOR_COUNT = 21, CHEST_COUNT = 34, ENCOUNTER_VALUE = 2

SCREEN _NEWIMAGE(640, 480, 32): RANDOMIZE TIMER

Layer(0) = _DISPLAY
Layer(1) = _NEWIMAGE(640, 480, 32)
Layer(2) = _NEWIMAGE(255 * 32, 255 * 32, 32) 'world map
Layer(5) = _NEWIMAGE(640, 480, 32) 'temp backup layer for menus
Layer(6) = _NEWIMAGE(352, 128, 32) 'temp layer to scroll text
Layer(7) = _NEWIMAGE(46 * 32, 46 * 32, 32) 'map layer
Layer(8) = _NEWIMAGE(46 * 32, 46 * 32, 32) 'NPC sprite layer
Layer(9) = _NEWIMAGE(640, 480, 32) 'debug info layer
Layer(11) = _NEWIMAGE(640, 480, 32) 'light mask for underground
Layer(12) = _NEWIMAGE(1472, 1472, 32) 'NPC sprite Clear layer
Layer(15) = _NEWIMAGE(640, 480, 32) 'Message handler text print layer
Layer(20) = _NEWIMAGE(640, 480, 32) 'Debug layer
Layer(21) = _NEWIMAGE(640, 480, 32) 'Custom Controller Click layer

_CLEARCOLOR _RGB32(0, 0, 0), Layer(12)
ClearLayerMaster = _MEMIMAGE(Layer(12)) '8667136bytes
CLM$ = _MEMGET(ClearLayerMaster, ClearLayerMaster.OFFSET, STRING * 8667136)

T(0) = _FREETIMER
T(1) = _FREETIMER
ON TIMER(T(0), .25) Frame_Change
ON TIMER(T(1), 1) FPS


PRINT "Loading...."
_DELAY .1
MFI_Loader "DragonWV1.MFI"

CONST CurrentVer~& = &HDA00DE69~& 'current Config file verison
CONST SaveVer~& = &HF1E3DAD0~& 'Current Saved File Version

INIT 'a bit of pre-run setup

Start_UP
_KEYCLEAR

Run_Title_Screen
CLS
GameStartMenu
Save_Config
_DELAY .125
'IF F.Just_Started THEN Init_Player
Build_Place_Layer Layer(7), P.Map 'setup the place(town\castle\cave) where player is


TIMER(T(0)) ON
G.LastMove = INT(TIMER)
_KEYCLEAR
ClearLayer Layer(5)

G.Current_BGM = Map_Music(1)
_SNDLOOP BGM(G.Current_BGM)
G.Battle = TRUE 'make sure this is set to -1 at begining

DO
    ExitFlag%% = Controls
    IF G.Flag THEN Move_Cycle
    IF G.Battle >= 0 THEN Nul%% = Battle(G.Battle)

    '---------------------cycle to cycle internal processing-----------------------
    IF P.Map >= 0 THEN Process_NPC
    IF INT(TIMER) = G.LastMove + 1 THEN G.Display_Status = TRUE
    '------------------------------------------------------------------------------

    '------------------------Display Building\Updating-----------------------------
    Build_Screen
    ' debug
    _PUTIMAGE (532, 0)-STEP(107, 479), Layer(20), Layer(1), (532, 0)-STEP(107, 479)
    _PUTIMAGE , Layer(1), Layer(0)
    '------------------------------------------------------------------------------
    _LIMIT 60

    IF Quit_Game_Flag THEN ExitFlag%% = TRUE 'player told king he wants to quit
    IF G.GameOver_Bad OR G.GameOver_Good OR G.GameOver_Great THEN ExitFlag%% = TRUE

LOOP UNTIL ExitFlag%% = TRUE
Fade_Out Layer(1)
FOR i%% = -1 TO 10
    IF _SNDPLAYING(BGM(i%%)) THEN _SNDSTOP BGM(i%%) 'shut off which ever music may be playing
NEXT i%%
PRINT G.GameOver_Bad; G.GameOver_Good; G.GameOver_Great
_DELAY 2
CLS

IF G.GameOver_Bad THEN
    PRINT "The Dragon Lord doth not share his power!"
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "Thou are destroyed!"
ELSEIF G.GameOver_Good THEN
    PRINT "The kingdom celebrates the destruction of the Dragon Lord,"
    PRINT "as peace returns through out the land!"
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "Meanwhile the king morns his lost daughter"
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "Whilst thou begins upon thy lonely task to find thy own"
    PRINT "kingdom to rule."
ELSEIF G.GameOver_Great THEN
    PRINT "The kingdom celebrates the destruction of the Dragon Lord,"
    PRINT "as peace returns through out the land!"
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "The King saddened to see his daughter go bestows upon thee a ship"
    PRINT "and crew to take thee to a new land to seek thy kingdom"
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "Years from hence, as thou Great-Great Grandson sits upon thy throne a"
    PRINT "dark shadow stretches across the land...."
    _DELAY .5
    PRINT "."
    _DELAY .5
    PRINT "but that is another tale...."
END IF
PRINT: PRINT: PRINT: PRINT
IF G.GameOver_Bad OR G.GameOver_Good OR G.GameOver_Great THEN PRINT "Game Over"


_FONT 16
TIMER(T(0)) OFF


FUNCTION NChance~%% (Load~%%)
    Result~%% = INT(RND * Load~%%)
    NChance = Result~%%
END FUNCTION

FUNCTION Critical%%
    Result%% = FALSE
    IF NChance(31) = 7 THEN Result%% = Player_AttackStrength - INT(Player_AttackStrength * NChance(255) / 512)
    IF Result%% < 0 THEN Result%% = 127 'max attack damage is 127
    Critical%% = Result%%
END FUNCTION

FUNCTION Dodge%% (Check~%%, Rate~%%)
    Result%% = FALSE
    IF NChance(Check~%%) < Rate~%% THEN Result%% = TRUE 'the attackee dodged the attacker
    Dodge = Result%%
END FUNCTION

FUNCTION Plink%% (ATT~%%, DEFN~%%)
    Result%% = FALSE
    IF ATT~%% < (2 + DEFN~%% \ 2) THEN Result%% = TRUE
    Plink = Result%%
END FUNCTION

FUNCTION NDamage%% (ATT~%%, DEFN~%%)
    Part1%% = ATT~%% - DEFN~%% / 2
    Part2%% = ((Part1%% + 1) * NChance(255)) / 256
    Dam%% = INT((Part1%% + Part2%%) / 4)
    IF Dam%% < 0 THEN Dam%% = 127 'limit damage to 127
    NDamage = Dam%%
END FUNCTION

FUNCTION Player_AttackStrength~%%
    Result~%% = INT(P.Strength) + I(P.Weapon).Power
    Player_AttackStrength~%% = Result~%%
END FUNCTION

FUNCTION Player_DefenceStrength~%%
    Result~%% = INT(P.Agility / 2) + I(P.Armor).Power + I(P.Shield).Power
    IF P.Scale THEN Result~%% = Result~%% + 2
    Player_DefenceStrength~%% = Result~%%
END FUNCTION

FUNCTION Monster_Plink (Mon%%)
    Result%% = FALSE
    Test1%% = INT(((5 / 2 + 1) * NChance(255) / 256) + 2) / 3
    Test2%% = INT(RND * (M(Mon%%).Strength + 4) / 6)
    IF Test1%% > Test2%% THEN Result%% = Test1%% ELSE Result%% = Test2%%
    Monster_Plink = Result%%
END FUNCTION

FUNCTION Player_Plink%%
    Result%% = FALSE
    IF NChance(100) < 50 THEN Result%% = TRUE
    Player_Plink = Result%%
END FUNCTION

FUNCTION Battle_Initiative%% (ID%%)
    'if false then enemy goes first else player goes first in battle
    IF (P.Agility * NChance(255)) < ((M(ID%%).Agility * NChance(255)) * GF(1)) THEN
        Result%% = FALSE 'Monster goes first
    ELSE
        Result%% = TRUE 'player Goes first
    END IF
    Battle_Initiative = Result%%
END FUNCTION

FUNCTION Monster_Flee%% (ID%%)
    IF P.Strength >= M(ID%%).Strength * 2 THEN
        IF NChance(64) < 7 THEN Result%% = TRUE ELSE Result%% = FALSE
    END IF
    Monster_Flee = Result%%
END FUNCTION

FUNCTION Player_Flee%% (ID%%)
    IF (P.Agility * NChance(255)) < ((M(ID%%).Agility * NChance(255)) * GF(M(ID%%).Group)) THEN
        Result%% = FALSE 'player is blocked
    ELSE
        Result%% = TRUE 'player Flees!
    END IF
    Player_Flee = Result%%
END FUNCTION

FUNCTION Player_Health_Status~%% (Ouch%%)
    Test% = P.HP - Ouch%%
    IF Test% <= 0 THEN 'did player get knocked off?
        Result~%% = DEAD 'sure did!
    ELSE
        Result~%% = P.HP - Ouch%%
    END IF
    Player_Health_Status = Result~%%
END FUNCTION

FUNCTION Monster_Health_Status~%% (ID%%, Ouch%%)
    Test% = M(ID%%).Hp - Ouch%%
    IF Test% <= 0 THEN 'did Monster get knocked off?
        Result~%% = DEAD 'sure did!
    ELSE
        Result~%% = M(ID%%).Hp - Ouch%%
    END IF
    Monster_Health_Status = Result~%%
END FUNCTION

FUNCTION Chance~%%
    Chance = INT(RND * 256)
END FUNCTION

SUB Screen_Flash
    _PUTIMAGE , Layer(0), Layer(5)
    FOR i%% = 0 TO 10 'Screen Flash
        _PUTIMAGE , Layer(5), Layer(0)
        _DELAY .05
        LINE (0, 0)-STEP(639, 479), _RGBA32(212, 212, 212, 127), BF
        _DELAY .025
    NEXT i%%
    _PUTIMAGE , Layer(5), Layer(0)
END SUB

SUB Screen_Flash_Damage
    _PUTIMAGE , Layer(0), Layer(5)
    FOR i%% = 0 TO 3 'Screen Flash
        _PUTIMAGE , Layer(5), Layer(0)
        _DELAY .01
        LINE (0, 0)-STEP(639, 479), _RGBA32(212, 212, 212, 127), BF
        _DELAY .01
    NEXT i%%
    _PUTIMAGE , Layer(5), Layer(0)
END SUB

FUNCTION Get_Mon_Gold~%% (ID%%)
    Result~%% = FALSE
    IF M(ID%%).Gold > 5 THEN
        Result~%% = M(ID%%).Gold * ((INT(RND * 25) + 75) / 100) 'gold varies by ~25%
    ELSE
        Result~%% = M(ID%%).Gold
    END IF
    Get_Mon_Gold = Result~%%
END FUNCTION

FUNCTION Get_Mon_HP~%% (ID%%)
    Result~%% = FALSE
    IF M(ID%%).Max_Hp > 5 THEN
        Result~%% = INT(RND * (M(ID%%).Max_Hp * .20)) + (M(ID%%).Max_Hp * .80) 'hp can vary by ~20%
    ELSE
        Result~%% = M(ID%%).Max_Hp
    END IF
    Get_Mon_HP = Result~%%
END FUNCTION

FUNCTION Get_Mon_MP~%% (ID%%)
    Result~%% = FALSE
    IF M(ID%%).Max_Mp > 10 THEN
        Result~%% = INT(RND * (M(ID%%).Max_Mp * .20)) + (M(ID%%).Max_Mp * .80) 'hp can vary by ~20%
    ELSE
        Result~%% = M(ID%%).Max_Mp
    END IF
    Get_Mon_MP = Result~%%
END FUNCTION

FUNCTION EXP_Required~%
    Result~% = L(P.Level) - P.Exp
    EXP_Required = Result~%
END FUNCTION

SUB Reset_Doors
    FOR i%% = 1 TO DOOR_COUNT - 1 'all doors except throne room one reset.
        Doors(i%%).Opened = FALSE
    NEXT i%%
END SUB

SUB Reset_Chests
    'the 3 chests in the Throne room do not reappear like all other chests
    FOR i%% = 3 TO 34
        Chest(i%%).Opened = FALSE
    NEXT i%%
END SUB

SUB Reset_Message_Layer
    Displayed = 0
    'ClearLayerADV Layer(15)
    ClearLayerTrans Layer(15)
END SUB

'------------------JoyStick\Pad Functions----------------------------
SUB Joy_Lock_Button (ID%%)
    ExitFlag%% = FALSE
    DO
        Nul%% = _DEVICEINPUT(C.Control_Pad)
        Nul%% = _BUTTON(ID%%)
        IF Nul%% = FALSE THEN ExitFlag%% = TRUE
    LOOP UNTIL ExitFlag%%
END SUB

SUB Joy_Lock_Axis (ID%%)
    ExitFlag%% = FALSE
    IF NOT G.ControlType THEN
        DO
            Nul%% = _DEVICEINPUT(C.Control_Pad)
            Nul%% = _AXIS(ID%%)
            IF Nul%% = FALSE THEN ExitFlag%% = TRUE
        LOOP UNTIL ExitFlag%%
        DO: LOOP WHILE _DEVICEINPUT(C.Control_Pad)
    END IF
END SUB

FUNCTION AxisPower%% (CJR%%, CJL%%, CJU%%, CJD%%)
    CJR%% = _AXIS(C.Joy_Right)
    CJL%% = _AXIS(C.Joy_Left)
    CJU%% = _AXIS(C.Joy_Up)
    CJD%% = _AXIS(C.Joy_Down)
    IF CJR%% = C.Joy_Right_Val THEN CJL%% = 0: CJR%% = TRUE ELSE CJR%% = 0
    IF CJD%% = C.Joy_Down_Val THEN CJU%% = 0: CJD%% = TRUE ELSE CJD%% = 0
    AxisPower = nul%%
END FUNCTION

SUB Save_Config
    IF _FILEEXISTS("DW1CS.CFG") THEN KILL "DW1CS.CFG"
    CF = FREEFILE
    OPEN "DW1CS.CFG" FOR BINARY AS #CF
    Ver~& = CurrentVer
    PUT #CF, , Ver~&
    PUT #CF, , C
    PUT #CF, , G.ControlType
    PUT #CF, , G.TextClick
    PUT #CF, , G.BGMVol
    PUT #CF, , G.SFXVol
    PUT #CF, , G.SkipIntro
    CLOSE #CF
END SUB

SUB Load_Config
    CF = FREEFILE
    OPEN "DW1CS.CFG" FOR BINARY AS #CF
    GET #CF, , Ver~&
    IF Ver~& <> CurrentVer THEN 'If the Config is not up to current version get last know version data and erase
        GET #CF, 1, C
        GET #CF, , G.ControlType
        GET #CF, , G.TextClick
        GET #CF, , G.BGMVol
        GET #CF, , G.SFXVol
        CLOSE #CF
        KILL "DW1CS.CFG"
    ELSE 'otherwise load data normally
        GET #CF, , C
        GET #CF, , G.ControlType
        GET #CF, , G.TextClick
        GET #CF, , G.BGMVol
        GET #CF, , G.SFXVol
        GET #CF, , G.SkipIntro
        CLOSE #CF
    END IF
END SUB

SUB Save_Game
    SF = FREEFILE
    OPEN "DW1.SV" + LTRIM$(STR$(G.SaveFile)) FOR BINARY AS #SF
    MenuD(G.SaveFile).CurLvl = P.Level 'get players current level before saving
    Ver~& = SaveVer
    PUT #SF, , Ver~&
    PUT #SF, , MenuD(G.SaveFile)
    PUT #SF, , NPC()
    PUT #SF, , P
    PUT #SF, , G
    PUT #SF, , F
    CLOSE #SF
END SUB

SUB Load_Game
    SF = FREEFILE
    PRINT G.SaveFile
    OPEN "DW1.SV" + LTRIM$(STR$(G.SaveFile)) FOR BINARY AS #SF
    GET #SF, , Ver~&
    IF Ver~& <> SaveVer THEN 'If the save file is not up to current version get last know version data and erase
        GET #SF, 1, MenuD(G.SaveFile)
        PRINT G.SaveFile
        GET #SF, , P
        GET #SF, , G
        GET #SF, , F
        PRINT LOC(SF)
        GET #SF, , NPC()
        CLOSE #SF
        PRINT G.SaveFile
        END
        KILL "DW1.SV" + LTRIM$(STR$(G.SaveFile))
        Save_Game 'resave the game with updated data\control version
    ELSE
        GET #SF, , MenuD(G.SaveFile)
        GET #SF, , NPC()
        GET #SF, , P
        GET #SF, , G
        GET #SF, , F
        CLOSE #SF
    END IF
    IF F.RainBow_Bridge_Done THEN
        World(65, 50).Sprite_ID = 4 'update the map
        _PUTIMAGE (128 + 32 * 65, 128 + 32 * 50)-STEP(31, 31), Layer(3), Layer(2), (1 + 17 * World(65, 50).Sprite_ID, 1)-STEP(15, 15)
    END IF
    IF F.Found_Hidden_Stair THEN
        Place(7, 23, 12).Sprite_ID = 8 'update the map
    END IF
    Doors(0).Opened = TRUE
    Chest(0).Opened = TRUE
    Chest(1).Opened = TRUE
    Chest(2).Opened = TRUE
    Reset_Chests 'remove throne room chest
    Reset_Doors ' and doors
    P.Is_Blocked = FALSE 'make sure player's spells are not blocked
END SUB

SUB FPS
    G.f = Frames%
    Frames% = 0
END SUB

SUB Change_BGM
    IF Map_Music(P.Map) <> G.Current_BGM THEN
        _SNDSTOP BGM(G.Current_BGM) 'stop the old music
        _DELAY .15
        G.Current_BGM = Map_Music(P.Map) ' store which music is now playing
        _SNDLOOP BGM(G.Current_BGM) ' start the new music
    END IF
END SUB
'-----------------------------------------------------------------------


FUNCTION Get_Input%% ()
    Result%% = TRUE '-1 for no input
    ' SELECT CASE G.ControlType
    '  CASE TRUE 'Keyboard input
    IF _KEYDOWN(C.KBCon_Up) THEN Result%% = UP
    IF _KEYDOWN(C.KBCon_Down) THEN Result%% = DOWN
    IF _KEYDOWN(C.KBCon_Left) THEN Result%% = LEFT
    IF _KEYDOWN(C.KBCon_Right) THEN Result%% = RIGHT
    IF _KEYDOWN(C.KBCon_Select) THEN Result%% = SELECT_BUTTON: DO: LOOP WHILE _KEYDOWN(C.KBCon_Select)
    IF _KEYDOWN(C.KBCon_Start) THEN Result%% = START_BUTTON: DO: LOOP WHILE _KEYDOWN(C.KBCon_Start)
    IF _KEYDOWN(C.KBCon_A_Button) THEN Result%% = BUTTON_A: DO: LOOP WHILE _KEYDOWN(C.KBCon_A_Button)
    IF _KEYDOWN(C.KBCon_B_Button) THEN Result%% = BUTTON_B: DO: LOOP WHILE _KEYDOWN(C.KBCon_B_Button)
    '  CASE FALSE 'joystick input
    IF C.Control_Pad THEN
        IF NOT G.Flag THEN DO: LOOP WHILE _DEVICEINPUT(C.Control_Pad)
        IF NOT C.BAD_Pad THEN
            nul%% = AxisPower(CJR%%, CJL%%, CJU%%, CJD%%) 'read directional axis values
            IF CJU%% THEN Result%% = UP
            IF CJD%% THEN Result%% = DOWN
            IF CJL%% THEN Result%% = LEFT
            IF CJR%% THEN Result%% = RIGHT
        ELSE
            IF _BUTTON(C.Joy_Button_Up) THEN Result%% = UP ': Joy_Lock_Button (C.Joy_Button_Up)
            IF _BUTTON(C.Joy_Button_Down) THEN Result%% = DOWN ': Joy_Lock_Button (C.Joy_Button_Down)
            IF _BUTTON(C.Joy_Button_Left) THEN Result%% = LEFT ': Joy_Lock_Button (C.Joy_Button_Left)
            IF _BUTTON(C.Joy_Button_Right) THEN Result%% = RIGHT ': Joy_Lock_Button (C.Joy_Button_Right)
        END IF
        IF _BUTTON(C.Joy_Select) THEN Result%% = SELECT_BUTTON: Joy_Lock_Button (C.Joy_Select)
        IF _BUTTON(C.Joy_Start) THEN Result%% = START_BUTTON: Joy_Lock_Button (C.Joy_Start)
        IF _BUTTON(C.Joy_A_Button) THEN Result%% = BUTTON_A: Joy_Lock_Button (C.Joy_A_Button)
        IF _BUTTON(C.Joy_B_Button) THEN Result%% = BUTTON_B: Joy_Lock_Button (C.Joy_B_Button)
    END IF
    ' END SELECT
    Get_Input = Result%%
END FUNCTION


FUNCTION Controls%%
    Result%% = FALSE
    KBD& = _KEYHIT
    C_Input%% = Get_Input

    'Testing line
    'IF KBD& AND F.Just_Started THEN G.LastMove = TIMER: F.Just_Started = FALSE: KBD& = 0 'NPC_Talk 0: G.LastMove = TIMER: F.Just_Started = FALSE: KBD& = 0
    'Main Game Lines
    IF (C_Input%% >= 0) AND F.Just_Started THEN
        F.PlayClick = G.TextClick
        NPC_Talk 0: G.LastMove = TIMER: F.Just_Started = FALSE: KBD& = 0
        _DELAY .0625
        DO: LOOP WHILE Get_Input >= 0 'try to catch instant menu popup after king speach bug
        F.PlayClick = FALSE 'try to catch text sound bug.
    END IF
    IF (C_Input%% >= 0) AND F.Defeated_In_Battle THEN NPC_Talk 0: G.LastMove = TIMER: F.Defeated_In_Battle = FALSE: KBD& = 0: DO: LOOP UNTIL Get_Input = -1


    IF C_Input%% = RIGHT AND (NOT G.Flag) THEN
        G.LastMove = INT(TIMER + .49): G.Display_Status = FALSE
        IF P.Facing <> RIGHT THEN P.Facing = RIGHT
        IF Move_Delay = 0 THEN
            Move_Delay = TIMER
        ELSEIF TIMER > Move_Delay + .125 THEN
            IF NOT Collision(1, 0) THEN G.Flag = TRUE
        END IF
    END IF
    IF C_Input%% = LEFT AND (NOT G.Flag) THEN
        G.LastMove = INT(TIMER + .49): G.Display_Status = FALSE
        IF P.Facing <> LEFT THEN P.Facing = LEFT
        IF Move_Delay = 0 THEN
            Move_Delay = TIMER
        ELSEIF TIMER > Move_Delay + .125 THEN
            IF NOT Collision(-1, 0) THEN G.Flag = TRUE
        END IF
    END IF
    IF C_Input%% = UP AND (NOT G.Flag) THEN
        G.LastMove = INT(TIMER + .49): G.Display_Status = FALSE
        IF P.Facing <> UP THEN P.Facing = UP
        IF Move_Delay = 0 THEN
            Move_Delay = TIMER
        ELSEIF TIMER > Move_Delay + .125 THEN
            IF NOT Collision(0, -1) THEN G.Flag = TRUE
        END IF
    END IF
    IF C_Input%% = DOWN AND (NOT G.Flag) THEN
        G.LastMove = INT(TIMER + .49): G.Display_Status = FALSE
        IF P.Facing <> DOWN THEN P.Facing = DOWN
        IF Move_Delay = 0 THEN
            Move_Delay = TIMER
        ELSEIF TIMER > Move_Delay + .125 THEN
            IF NOT Collision(0, 1) THEN G.Flag = TRUE
        END IF
    END IF

    IF C_Input%% = BUTTON_A AND (NOT G.Flag) THEN
        _SNDPLAY SFX(15)
        Process_Command Command_Window(Layer(1)), Layer(1)
    END IF

    IF C_Input%% = -1 THEN Move_Delay = 0 'no keys\buttons pressed

    'IF KBD& = 27 THEN Result%% = TRUE
    Controls = Result%%
END FUNCTION

SUB debug
    _PRINTSTRING (532, 0), "Rad:" + STR$(P.Radiant) + "  ", Layer(20)
    _PRINTSTRING (532, 16), "Map:" + STR$(P.Map) + "  ", Layer(20)
    _PRINTSTRING (532, 32), "MapX:" + STR$(P.MapX) + "  ", Layer(20)
    _PRINTSTRING (532, 48), "MapY:" + STR$(P.MapY) + "  ", Layer(20)
    _PRINTSTRING (532, 64), "WorldX:" + STR$(P.WorldX) + "  ", Layer(20)
    _PRINTSTRING (532, 80), "WorldY:" + STR$(P.WorldY) + "  ", Layer(20)
    _PRINTSTRING (532, 96), "Facing:" + STR$(P.Facing), Layer(20)
    _PRINTSTRING (532, 112), "Is_Lit:" + STR$(PD(P.Map).Is_Lit), Layer(20)
    IF P.Map >= 0 THEN _PRINTSTRING (532, 128), "Entry:" + STR$(Place(P.Map, P.MapX, P.MapY).Is_Entrance) + "  ", Layer(20)
    _PRINTSTRING (532, 144), "Territory:" + STR$(World(P.WorldX, P.WorldY).Territory) + "  ", Layer(20)
    _PRINTSTRING (532, 160), "Repel:" + STR$(P.Is_Repel) + "  ", Layer(20)
    IF P.Map >= 0 THEN _PRINTSTRING (532, 176), "HSpl:" + STR$(Place(P.Map, P.MapX, P.MapY).Has_Special) + "  ", Layer(20)
END SUB

'END OF LINE-----------------------------------------------------------

FUNCTION Battle%% (ID%%)
    BResult%% = FALSE 'used if player is fighting Golem, Green Dragon, or Dragonlord
    P.Is_Blocked = FALSE 'make sure player's spells are good to go at start
    G.Display_Status = TRUE 'display vitals
    ClearLayer Layer(5)
    _SNDSTOP BGM(G.Current_BGM)
    _SNDPLAY BGM(5)
    G.Battle = ID%% 'so message system know which monster name to use
    'determine HP at begining of battle
    M(ID%%).Hp = Get_Mon_HP(ID%%)
    M(ID%%).Mp = Get_Mon_MP(ID%%)
    G.Price = Get_Mon_Gold(ID%%)
    'Who gets to go First?
    Whos_First%% = Battle_Initiative(G.Battle) 'true value means monster goes first
    'Does Monster Flee right away?
    FleeCheck%% = Monster_Flee%%(G.Battle)

    DO: _DELAY .025: LOOP WHILE _SNDPLAYING(BGM(5))
    G.Current_BGM = 4
    _SNDLOOP BGM(4)

    IF NOT FleeCheck%% THEN 'monster did not flee so start battle
        DO
            'screen stuff-----------------------------------
            _PUTIMAGE , Layer(5), Layer(1)
            Build_Screen 'rebuild screen

            IF P.Map = -1 THEN 'draw battle ground in over world
                _PUTIMAGE (160, 128)-STEP(223, 223), Layer(16), Layer(1), (0, 0)-STEP(111, 111)
            ELSE 'player is in cave or DragonLords Castle, black out visable area
                _PUTIMAGE (160, 128)-STEP(223, 223), Layer(3), Layer(1), (307, 1)-STEP(15, 15)
            END IF

            Display_Monster_Sprite ID%% 'place monster sprite
            'debug
            _PUTIMAGE (532, 0)-STEP(107, 479), Layer(20), Layer(1), (532, 0)-STEP(107, 479)
            _PUTIMAGE , Layer(1), Layer(5) 'Display screen
            '------------------------------------------------
            '------------------Players side----------------------------------
            IF NOT Whos_First THEN 'if Monster did not go first or had its turn then players turn
                IF P.Is_Asleep THEN 'if asleep then make a throw to wake up
                    IF Awake_Throw THEN 'player wakes up!
                        null%% = Message_Handler(Layer(15), 372) 'player awakens!
                        P.Is_Asleep = FALSE
                        G.Sleeps = 0
                    ELSE 'player fails to wake
                        null%% = Message_Handler(Layer(15), 371) 'Player still snoozing!
                        G.Sleeps = G.Sleeps + 1 'number of turns player has been asleep
                        _DELAY .15
                    END IF
                END IF
                IF Attack_Result%% > -4 AND (NOT P.Is_Asleep) THEN 'player is still alive and not snoozing then attack!
                    Attack_Result%% = Player_Battle_Command(ID%%)
                    IF Attack_Result%% = -5 THEN Victory%% = TRUE: ExitFlag%% = TRUE 'player defeats the monster
                    IF Attack_Result%% = -4 THEN ExitFlag%% = TRUE 'player ran away
                    IF Attack_Result%% = -6 THEN Attack_Result%% = -1
                END IF
            END IF
            '---------------------Monsters side----------------------------------
            IF Attack_Result%% > -4 AND (NOT M(ID%%).Is_Asleep) THEN 'monster is still alive and not snoozing then it attacks!
                Attack_Result%% = Monsters_Attack(ID%%)
                IF Attack_Result%% = -5 THEN Defeat%% = TRUE: ExitFlag%% = TRUE 'player is defeated by the monster
                IF Attack_Result%% = -4 THEN ExitFlag%% = TRUE 'Monster ran away
            ELSEIF M(ID%%).Is_Asleep THEN 'if asleep then make a throw to wake up
                IF NChance(100) < 50 THEN 'did monster wake up?
                    IF G.Battle <> 24 THEN 'Golem does not wake up.
                        M(Mon%%).Is_Asleep = FALSE
                        null%% = Message_Handler(Layer(15), 377) 'monster wakes up
                    END IF
                ELSE 'monster still asleep
                    null%% = Message_Handler(Layer(15), 380) 'monster still sleeps
                END IF
            END IF
            IF Whos_First THEN Whos_First = FALSE 'monster had its first go now players turn
        LOOP UNTIL ExitFlag%%
    ELSE 'monster fled
        'screen stuff-----------------------------------
        _PUTIMAGE , Layer(5), Layer(1)
        Build_Screen 'rebuild screen
        IF P.Map = -1 THEN 'draw battle ground in over world
            _PUTIMAGE (160, 128)-STEP(223, 223), Layer(16), Layer(1), (0, 0)-STEP(111, 111)
        ELSE 'player is in cave or DragonLords Castle, black out visable area
            _PUTIMAGE (160, 128)-STEP(223, 223), Layer(3), L&, (307, 1)-STEP(15, 15)
        END IF
        Display_Monster_Sprite ID%% 'place monster sprite
        _PUTIMAGE , Layer(1), Layer(5) 'Display screen
        '------------------------------------------------
        Change_BGM
        M(ID%%).Is_Asleep = FALSE
        null%% = Message_Handler(Layer(15), 354) 'monster Ran Away!
        G.Battle = TRUE '-1 is not a monster (0-40)
        G.Attack_Bonus = FALSE 'turn off battle spells
        G.Defence_Bonus = FALSE
    END IF

    'Battle Results
    IF Defeat%% THEN
        Death_Return 'move the player back to the throne room and take half gold
        IF M(G.Battle).Is_Blocked THEN M(G.Battle).Is_Blocked = FALSE 'turn off spell block if player cast it successfully
        P.Is_Blocked = FALSE 'turn off spell block if affect by it
        G.Battle = TRUE '-1 is not a monster (0-40)
    ELSEIF Victory%% THEN
        null%% = Message_Handler(Layer(15), 364) 'Player defeated monster
        _SNDSTOP BGM(G.Current_BGM)
        _SNDPLAY SFX(6)
        DO: _DELAY .025: LOOP WHILE _SNDPLAYING(SFX(6))
        Change_BGM
        P.Gold = P.Gold + G.Price
        P.Exp = P.Exp + M(ID%%).Exp
        G.Input_Wait = TRUE
        null%% = Message_Handler(Layer(15), 365) 'Player gains in GP and E
        IF P.Exp >= L(P.Level) THEN 'player gains a level
            Draw_Stat_Window Layer(5)
            _SNDPLAY SFX(4)
            DO: LOOP WHILE _SNDPLAYING(SFX(4))
            G.Battle = TRUE 'set this to -1 to indicate no monster to fight
            Level_Up
        END IF
        BResult%% = TRUE 'needed if player is in battle with Golem, Green Dragon, or DragonLord
    ELSEIF Attack_Result%% = -4 THEN
        Change_BGM 'a runs away situation change bgm back.
    END IF

    Battle = BResult%%
    Reset_Message_Layer
    G.Battle = TRUE 'set this to -1 to indicate no monster to fight done here incase no levelup
END FUNCTION


FUNCTION Monsters_Attack%% (ID%%)
    Result%% = FALSE
    IF Monster_Flee(ID%%) THEN 'Give the monster a chance to run away
        IF NChance(100) < 7 THEN Final%% = RANAWAY 'since monster stayed to fight in first place reduce the chance to get away now.
    END IF

    IF Final%% <> RANAWAY THEN 'run the attack

        'Check For Attack Type: Special 1, Special 2, or normal phyical attack
        IF M(ID%%).Attk1Prob THEN 'does monster have a special attack 1? Sleep, StopSpell, Heal, and Healmore
            IF NChance(16) < M(ID%%).Attk1Prob THEN 'if so do they use it?
                Attack1%% = TRUE
                IF M(ID%%).Attk1 = SLUMBER AND P.Is_Asleep THEN Attack1%% = FALSE 'dont use if player already asleep
                IF M(ID%%).Attk1 = STOPSPELL AND P.Is_Blocked THEN Attack1%% = FALSE 'dont use if players spells already blocked
                IF M(ID%%).Attk1 = HEAL AND M(ID%%).Hp >= INT(M(ID%%).Max_Hp * .25) THEN Attack1%% = FALSE 'Dont heal if health is more than 25% max
                IF M(ID%%).Attk1 = HEALMORE AND M(ID%%).Hp >= INT(M(ID%%).Max_Hp * .25) THEN Attack1%% = FALSE 'Dont heal if health is more than 25% max

                IF Attack1%% THEN
                    IF NOT M(i%%).Is_Blocked THEN 'only if monster is not spell blocked
                        '      _SNDPLAY SFX(18)
                        G.Cast = M(ID%%).Attk1 'name of spell being used
                        SELECT CASE M(ID%%).Attk1
                            CASE SLUMBER 'always works
                                IF M(ID%%).Mp >= 2 THEN
                                    '         null%% = Message_Handler(Layer(15), 374)
                                    _SNDPLAY SFX(18)
                                    DO: LOOP WHILE _SNDPLAYING(SFX(18))
                                    P.Is_Asleep = TRUE: G.Sleeps = 1
                                    M(ID%%).Mp = M(ID%%).Mp - 2
                                    MSG% = CASTSPELL
                                ELSE
                                    MSG% = NOTENOUGHMP
                                END IF
                            CASE STOPSPELL '50\50 working if player does not have Edrick's armor
                                IF M(ID%%).Mp >= 2 THEN
                                    null%% = Message_Handler(Layer(15), 374)
                                    _SNDPLAY SFX(18)
                                    DO: LOOP WHILE _SNDPLAYING(SFX(18))
                                    IF P.Armor <> 15 THEN
                                        IF NChance(100) < 50 THEN P.Is_Blocked = TRUE: MSG% = CASTSPELL ELSE MSG% = SPELLFAIL
                                    ELSE 'player is wearing Erdrick's Armor
                                        MSG% = SPELLFAIL
                                    END IF
                                    M(ID%%).Mp = M(ID%%).Mp - 2
                                ELSE
                                    MSG% = NOTENOUGHMP
                                END IF
                            CASE HEAL
                                IF M(ID%%).Mp >= 4 THEN
                                    _SNDPLAY SFX(18)
                                    DO: LOOP WHILE _SNDPLAYING(SFX(18))
                                    M(ID%%).Mp = M(ID%%).Mp - 4
                                    M(ID%%).Hp = M(ID%%).Hp + NChance(7) + 20
                                    IF M(ID%%).Hp > M(ID%%).Max_Hp THEN M(ID%%).Hp = M(ID%%).Max_Hp
                                    MSG% = CASTSPELL
                                ELSE
                                    MSG% = NOTENOUGHMP
                                END IF
                            CASE HEALMORE
                                IF M(ID%%).Mp >= 10 THEN
                                    _SNDPLAY SFX(18)
                                    DO: LOOP WHILE _SNDPLAYING(SFX(18))
                                    M(ID%%).Mp = M(ID%%).Mp - 10
                                    M(ID%%).Hp = M(ID%%).Hp + NChance(15) + 85
                                    IF M(ID%%).Hp > M(ID%%).Max_Hp THEN M(ID%%).Hp = M(ID%%).Max_Hp
                                    MSG% = CASTSPELL
                                ELSE
                                    MSG% = NOTENOUGHMP
                                END IF
                        END SELECT
                    ELSE
                        null%% = Message_Handler(Layer(15), 374) 'message that monster trys to cast spell
                        _SNDPLAY SFX(18)
                        DO: LOOP WHILE _SNDPLAYING(SFX(18))
                        MSG% = SPELLSBLOCKED
                    END IF
                END IF
            END IF
        END IF

        IF NOT Attack1%% THEN 'If monster did not use special 1 then check for Special 2
            IF M(ID%%).Attk2Prob THEN 'does monster have a special attack 1? Sleep, StopSpell, Heal, and Healmore
                IF NChance(16) < M(ID%%).Attk2Prob THEN 'if so do they use it?
                    Attack2%% = TRUE
                    G.Cast = M(ID%%).Attk2 'name of spell being used
                    SELECT CASE M(ID%%).Attk2
                        CASE HURT
                            IF NOT M(ID%%).Is_Blocked THEN
                                _SNDPLAY SFX(18)
                                IF M(ID%%).Mp >= 2 THEN
                                    Hit%% = NChance(7) + 3
                                    IF G.Defence_Bonus THEN Hit%% = Hit%% * .75
                                    M(ID%%).Mp = M(ID%%).Mp - 2
                                    MSG% = CASTSPELL
                                ELSE
                                    MSG% = NOTENOUGHMP
                                END IF
                            ELSE
                                null%% = Message_Handler(Layer(15), 374) 'message that monster trys to cast spell
                                _SNDPLAY SFX(18)
                                DO: LOOP WHILE _SNDPLAYING(SFX(18))
                                MSG% = SPELLSBLOCKED
                            END IF
                        CASE HURTMORE
                            IF NOT M(ID%%).Is_Blocked THEN
                                _SNDPLAY SFX(18)
                                IF M(ID%%).Mp >= 5 THEN
                                    Hit%% = NChance(30) + 15
                                    IF G.Defence_Bonus THEN Hit%% = Hit%% * .75
                                    M(ID%%).Mp = M(ID%%).Mp - 5
                                    MSG% = CASTSPELL
                                ELSE
                                    MSG% = NOTENOUGHMP
                                END IF
                            ELSE
                                null%% = Message_Handler(Layer(15), 374) 'message that monster trys to cast spell
                                _SNDPLAY SFX(18)
                                DO: LOOP WHILE _SNDPLAYING(SFX(18))
                                MSG% = SPELLSBLOCKED
                            END IF
                        CASE FIRE_LOW_LEVEL
                            _SNDPLAY SFX(7)
                            Hit%% = NChance(7) + 16
                            IF G.Defence_Bonus THEN Hit%% = Hit%% * .75
                            MSG% = FIREBREATH
                        CASE FIRE_HIGH_LEVEL
                            _SNDPLAY SFX(7)
                            Hit%% = NChance(7) + 65
                            IF G.Defence_Bonus THEN Hit%% = Hit%% * .75
                            MSG% = FIREBREATH
                    END SELECT
                    IF M(ID%%).Attk2 = HURT OR M(ID%%).Attk2 = HURTMORE THEN 'if player has Magic armor or Erdrick's armor reduce damage from these attacks
                        IF P.Armor = 14 OR P.Armor = 15 THEN Hit%% = INT(Hit%% * .66)
                    ELSE 'only Erdrick's mighty armor can protect from Fire attacks!
                        IF P.Armor = 15 THEN Hit%% = INT(Hit%% * .66)
                    END IF
                END IF
            END IF
        END IF

        IF (NOT Attack1%%) AND (NOT Attack2%%) THEN 'Monster did not use special attacks so use physical attack
            IF Plink(M(ID%%).Strength, Player_DefenceStrength) THEN 'true if monster pulls a plink attack.
                Hit%% = Monster_Plink(ID%%)
                MSG% = ATTACK
                null%% = Message_Handler(Layer(15), MSG%)
                IF Hit%% THEN _SNDPLAY SFX(9) 'a hit
                DO: LOOP WHILE _SNDPLAYING(SFX(9))
                MSG% = 363
            ELSE
                Hit%% = NDamage(M(ID%%).Strength, Player_DefenceStrength) 'Get a hit value'
                IF G.Defence_Bonus THEN Hit%% = Hit%% * .75
                MSG% = ATTACK
                null%% = Message_Handler(Layer(15), MSG%)
                IF Hit%% THEN _SNDPLAY SFX(9) 'a hit
                DO: LOOP WHILE _SNDPLAYING(SFX(9))
                MSG% = 363
            END IF
            IF Hit%% = 0 THEN MSG% = MISSES

        END IF
        G.Damage = Hit%% 'for attack messages that need the damage amount

        'Process attack messages
        null%% = Message_Handler(Layer(15), MSG%)
        'process attack sound effects
        IF MSG% = MISSES THEN _SNDPLAY SFX(10) 'a miss
        'if hurt spell or breath fire was used display howmuch damage was done
        IF G.Cast = 2 OR G.Cast = 10 OR MSG% = FIREBREATH THEN _SNDPLAY SFX(9): null%% = Message_Handler(Layer(15), 363) 'a hit
        'if sleep or stopspell
        IF P.Is_Asleep AND Attack1%% THEN null%% = Message_Handler(Layer(15), 370) 'message that player is now asleep
        IF P.Is_Blocked AND Attack1%% THEN null%% = Message_Handler(Layer(15), 386) 'message that player's spells are now blocked
        'Attacks been made, see what happened!
        Results~%% = Player_Health_Status(Hit%%)
        IF Results~%% = DEAD THEN
            Final%% = -5 'DEAD 'tell main loop that player died from attack
        ELSE
            P.HP = Results~%%
            Final%% = Hit%% 'Tell main loop hits taken by player
        END IF
    ELSE
        _SNDPLAY SFX(1) 'running away
        null%% = Message_Handler(Layer(15), 354) 'Monster Runs Away.
    END IF

    Monsters_Attack = Final%%
END FUNCTION

FUNCTION Player_Attack%% (ID%%)
    Result%% = FALSE
    MSG% = FALSE
    Hit%% = Critical 'test for critical hit
    IF Hit%% THEN _SNDPLAY SFX(12): _DELAY .1: null%% = Message_Handler(Layer(15), 356): MSG% = ITSAHIT: _DELAY .1 'critical hit message
    IF Dodge(64, M(ID%%).Evasion) THEN MSG% = DODGEDIT 'monster can dodge even a critical hit!

    IF Hit%% = 0 THEN 'if player didn't score a critical hit then run normal hit
        null%% = Message_Handler(Layer(15), 387) 'player make an attack move

        IF Plink(Player_AttackStrength, M(ID%%).Agility) AND MSG% = 0 THEN 'is monster too powerful for player?
            IF Player_Plink THEN 'player makes a weak hit or missed completely
                Hit%% = 1
                _SNDPLAY SFX(9)
                MSG% = ITSAHIT
            ELSE 'missed completely
                _SNDPLAY SFX(10)
                MSG% = MISSED
                PPLink = PPLink + 1
            END IF
        END IF

        IF MSG% = 0 THEN 'run normal attack if no dodge or missed message
            _SNDPLAY SFX(9)
            Hit%% = NDamage(Player_AttackStrength, M(ID%%).Agility)
            IF G.Attack_Bonus THEN Hit%% = Hit%% * 1.25 'player cast Strengthen
            IF Hit%% < 0 THEN Hit%% = 127 'cap damage at 127(for signed BYTE)
            MSG% = ITSAHIT
        END IF
    END IF

    G.Damage = ABS(Hit%%)

    IF MSG% <> DODGEDIT THEN 'if the monster isn't dodgeing then run damage code
        _SNDPLAY SFX(9)
        Results~%% = Monster_Health_Status(ID%%, Hit%%)
        IF Results~%% = DEAD THEN
            Final%% = -5 'DEAD 'tell main loop that monster died from attack
        ELSE
            M(ID%%).Hp = Results~%%
            Final%% = Hit%% 'Tell main loop hits taken by monster
        END IF
    END IF

    IF MSG% = DODGEDIT THEN _SNDPLAY SFX(10) 'play missed sound fx if monster dodged attack
    null%% = Message_Handler(Layer(15), MSG%)
    Player_Attack = Final%%
END FUNCTION

FUNCTION Player_Spell_Attack%% (ID%%)
    Result%% = FALSE
    MSG% = FALSE
    IF P.Is_Blocked THEN
        MSG% = SPELLBLOCKED
        Final%% = -4
    ELSE
        Hit%% = Cast_Spell(Run_Spell(18, 3, Layer(1)))
        IF Hit%% >= 0 THEN 'player used an attack spell if hits returned are 0(monster dodged) or greater(damage done)
            Results~%% = Monster_Health_Status(ID%%, Hit%%)
            IF Results~%% = DEAD THEN
                Final%% = -5 'DEAD 'tell main loop that monster died from attack
            ELSE
                M(ID%%).Hp = Results~%%
                Final%% = Hit%% 'Tell main loop hits taken by monster
            END IF
        ELSE 'open end for sleep and stopspell and cancel
            IF Hit%% = -3 THEN MSG% = ASLEEP 'monster is asleep
            IF Hit%% = -1 THEN MSG% = BLOCKED 'monsters spells are blocked
            Final%% = -4
            IF Hit%% = -2 THEN Final%% = -1 'player canceled
        END IF
    END IF
    IF MSG% THEN null%% = Message_Handler(Layer(15), MSG%)
    Player_Spell_Attack = Final%%
END FUNCTION

FUNCTION Awake_Throw%%
    Result%% = FALSE
    'as per original game limits player can only spend max 6 turns asleep
    IF NChance(255) >= INT(127 - (21.2 * G.Sleeps)) THEN Result%% = TRUE 'player wakes up
    Awake_Throw = Result%%
END FUNCTION

FUNCTION Pick_Battle (Opt%%)
    Result%% = -1
    SELECT CASE INT(RND * 100)
        CASE 0 TO 19
            Result%% = MZG(Opt%%, 0)
        CASE 20 TO 39
            Result%% = MZG(Opt%%, 1)
        CASE 40 TO 59
            Result%% = MZG(Opt%%, 2)
        CASE 60 TO 79
            Result%% = MZG(Opt%%, 3)
        CASE 80 TO 99
            Result%% = MZG(Opt%%, 4)
        CASE ELSE 'not sure why this happens but make it lucky for the player.. sort of
            G.Price = INT(RND * 5) + 1
            null%% = Message_Handler(Layer(15), 335) '335 player finds gold
            P.Gold = P.Gold + G.Price
            G.Price = 0
            Result%% = -2
    END SELECT
    Pick_Battle = Result%%
END FUNCTION

SUB Display_Monster_Sprite (ID%%)
    'ordered by sprite group
    SELECT CASE ID%%
        CASE 0 'Slime
            _PUTIMAGE (160 + 96, 128 + 96)-STEP(37, 35), Layer(17), Layer(1), (5, 2)-STEP(18, 17)
        CASE 1 'Red Slime
            _PUTIMAGE (160 + 96, 128 + 96)-STEP(37, 35), Layer(17), Layer(1), (26, 2)-STEP(18, 17)
        CASE 16 'Metal Slime
            _PUTIMAGE (160 + 96, 128 + 96)-STEP(39, 35), Layer(17), Layer(1), (47, 2)-STEP(18, 17)
        CASE 2 'Drakee
            _PUTIMAGE (160 + 88, 128 + 72)-STEP(47, 65), Layer(17), Layer(1), (5, 23)-STEP(23, 32)
        CASE 5 'Magidrakee
            _PUTIMAGE (160 + 88, 128 + 72)-STEP(47, 65), Layer(17), Layer(1), (31, 23)-STEP(23, 32)
        CASE 10 'Drakeema
            _PUTIMAGE (160 + 88, 128 + 72)-STEP(47, 65), Layer(17), Layer(1), (57, 23)-STEP(23, 32)
        CASE 3 'Ghost
            _PUTIMAGE (160 + 88, 128 + 60)-STEP(47, 85), Layer(17), Layer(1), (5, 59)-STEP(23, 42)
        CASE 8 'Poltergeist
            _PUTIMAGE (160 + 88, 128 + 60)-STEP(47, 85), Layer(17), Layer(1), (31, 59)-STEP(23, 42)
        CASE 17 'Specter
            _PUTIMAGE (160 + 88, 128 + 60)-STEP(47, 85), Layer(17), Layer(1), (57, 59)-STEP(23, 42)
        CASE 4 'Magician
            _PUTIMAGE (160 + 74, 128 + 66)-STEP(71, 69), Layer(17), Layer(1), (6, 107)-STEP(35, 34)
        CASE 12 'Warlock
            _PUTIMAGE (160 + 74, 128 + 66)-STEP(71, 69), Layer(17), Layer(1), (44, 105)-STEP(35, 36)
        CASE 32 'Wizard
            _PUTIMAGE (160 + 74, 128 + 66)-STEP(71, 69), Layer(17), Layer(1), (82, 105)-STEP(35, 36)
        CASE 6 'Scorpion
            _PUTIMAGE (160 + 76, 128 + 80)-STEP(81, 65), Layer(17), Layer(1), (6, 145)-STEP(40, 31)
        CASE 13 'Metal Scorpion
            _PUTIMAGE (160 + 76, 128 + 80)-STEP(81, 65), Layer(17), Layer(1), (49, 145)-STEP(40, 31)
        CASE 22 'Rogue Scorpion
            _PUTIMAGE (160 + 76, 128 + 80)-STEP(81, 65), Layer(17), Layer(1), (92, 145)-STEP(40, 31)
        CASE 7 'Druin
            _PUTIMAGE (160 + 76, 128 + 80)-STEP(71, 57), Layer(17), Layer(1), (6, 180)-STEP(35, 28)
        CASE 19 'Druinlord
            _PUTIMAGE (160 + 76, 128 + 80)-STEP(71, 57), Layer(17), Layer(1), (44, 180)-STEP(35, 28)
        CASE 9 'Droll
            _PUTIMAGE (160 + 88, 128 + 60)-STEP(63, 71), Layer(17), Layer(1), (6, 212)-STEP(31, 35)
        CASE 20 'Drollmagi
            _PUTIMAGE (160 + 88, 128 + 60)-STEP(63, 71), Layer(17), Layer(1), (40, 212)-STEP(31, 35)
        CASE 11 'Skeleton
            _PUTIMAGE (160 + 78, 128 + 56)-STEP(63, 93), Layer(17), Layer(1), (6, 251)-STEP(31, 46)
        CASE 15 'Wraith
            _PUTIMAGE (160 + 78, 128 + 56)-STEP(63, 93), Layer(17), Layer(1), (40, 251)-STEP(31, 46)
        CASE 23 'Wraith Knight
            _PUTIMAGE (160 + 78, 128 + 56)-STEP(67, 93), Layer(17), Layer(1), (74, 251)-STEP(33, 46)
        CASE 28 'Deamon Knight
            _PUTIMAGE (160 + 78, 128 + 56)-STEP(67, 93), Layer(17), Layer(1), (110, 251)-STEP(33, 46)
        CASE 14 'Wolf
            _PUTIMAGE (160 + 68, 128 + 62)-STEP(87, 83), Layer(17), Layer(1), (6, 301)-STEP(43, 41)
        CASE 18 'Wolflord
            _PUTIMAGE (160 + 68, 128 + 62)-STEP(87, 83), Layer(17), Layer(1), (52, 301)-STEP(43, 41)
        CASE 29 'Werewolf
            _PUTIMAGE (160 + 68, 128 + 62)-STEP(87, 83), Layer(17), Layer(1), (98, 301)-STEP(43, 41)
        CASE 21 'Wyvern
            _PUTIMAGE (160 + 70, 128 + 48)-STEP(73, 99), Layer(17), Layer(1), (6, 346)-STEP(36, 49)
        CASE 27 'Magiwyvern
            _PUTIMAGE (160 + 70, 128 + 48)-STEP(73, 99), Layer(17), Layer(1), (45, 346)-STEP(36, 49)
        CASE 31 'Starwyvern
            _PUTIMAGE (160 + 70, 128 + 48)-STEP(73, 99), Layer(17), Layer(1), (84, 346)-STEP(36, 49)
        CASE 24 'Golem
            _PUTIMAGE (160 + 64, 128 + 52)-STEP(93, 93), Layer(17), Layer(1), (55, 454)-STEP(46, 46)
        CASE 25 'GoldMan
            _PUTIMAGE (160 + 64, 128 + 52)-STEP(93, 93), Layer(17), Layer(1), (6, 454)-STEP(46, 46)
        CASE 35 'StoneMan
            _PUTIMAGE (160 + 64, 128 + 52)-STEP(93, 93), Layer(17), Layer(1), (104, 454)-STEP(46, 46)
        CASE 26 'Knight
            _PUTIMAGE (160 + 69, 128 + 58)-STEP(95, 91), Layer(17), Layer(1), (6, 405)-STEP(47, 45)
        CASE 33 'Axe Knight
            _PUTIMAGE (160 + 69, 128 + 52)-STEP(97, 103), Layer(17), Layer(1), (56, 399)-STEP(49, 51)
        CASE 36 'Armored Knight
            _PUTIMAGE (160 + 69, 128 + 52)-STEP(97, 103), Layer(17), Layer(1), (108, 399)-STEP(49, 51)
        CASE 30 'Green Dragon
            _PUTIMAGE (160 + 50, 128 + 70)-STEP(93, 75), Layer(17), Layer(1), (6, 507)-STEP(46, 37)
        CASE 34 'Blue Dragon
            _PUTIMAGE (160 + 40, 128 + 68)-STEP(119, 81), Layer(17), Layer(1), (55, 504)-STEP(59, 40)
        CASE 37 'Red Dragon
            _PUTIMAGE (160 + 40, 128 + 68)-STEP(119, 81), Layer(17), Layer(1), (117, 504)-STEP(59, 40)
        CASE 38 'Dragonlord 1st
            _PUTIMAGE (160 + 86, 128 + 70)-STEP(53, 75), Layer(17), Layer(1), (6, 601)-STEP(26, 37)
        CASE 39 'Dragon Lord 2nd
            _PUTIMAGE (160 + 24, 128 + 8)-STEP(147, 183), Layer(17), Layer(1), (64, 547)-STEP(73, 91)
        CASE 40 'King!
            _PUTIMAGE (160 + 86, 128 + 70)-STEP(51, 71), Layer(17), Layer(1), (6, 646)-STEP(25, 35)
    END SELECT
END SUB

SUB Add_To_Inventory (Item%%, Count%%)
    STATIC m AS _MEM 'no need to initialize/free it over and over
    STATIC Pack AS _OFFSET
    m = _MEM(P) 'Just change where you want to point it to.
    Pack = m.OFFSET + 12 '�move to where P .Pack starts at in memory

    Match%% = FALSE
    IF Item%% = 22 THEN 'herb
        P.Herbs = P.Herbs + 1
    ELSEIF Item%% = 26 THEN 'Key
        P.Keys = P.Keys + 1
    ELSE
        _MEMPUT m, Pack + P.Items * 2, Item%% 'POKE
        _MEMPUT m, Pack + P.Items * 2 + 1, Count%% 'POKE
        P.Items = P.Items + 1
    END IF
END SUB

FUNCTION Item_Count%% (Item%%)
    STATIC m AS _MEM 'no need to initialize/free it over and over
    STATIC Pack AS _OFFSET
    m = _MEM(P) 'Just change where you want to point it to.
    Pack = m.OFFSET + 12 '�move to where P .Pack starts at in memory
    Result%% = 0
    Result%% = _MEMGET(m, Pack + Item%% * 2 + 1, _BYTE)
    Item_Count = Result%%
END FUNCTION

FUNCTION Inventory_Item%% (Item%%)
    STATIC m AS _MEM 'no need to initialize/free it over and over
    STATIC Pack AS _OFFSET
    m = _MEM(P) 'Just change where you want to point it to.
    Pack = m.OFFSET + 12 '�move to where P .Pack starts at in memory
    Result%% = 0
    Result%% = _MEMGET(m, Pack + Item%% * 2, _BYTE)
    Inventory_Item = Result%%
END FUNCTION

SUB Remove_Inventory (Item%%, Count%%)
    STATIC m AS _MEM 'no need to initialize/free it over and over
    STATIC Pack AS _OFFSET
    m = _MEM(P) 'Just change where you want to point it to.
    Pack = m.OFFSET + 12 '�move to where P .Pack starts at in memory

    Match%% = -1
    FOR i%% = 0 TO 15 'find the item
        IF Item%% = _MEMGET(m, Pack + i%% * 2, _BYTE) THEN Match%% = i%%: i%% = 30
    NEXT i%%
    IF Match%% < 0 THEN
        'something went horribly wrong!
        PRINT Item%%: END
    ELSE
        temp%% = _MEMGET(m, Pack + Match%% * 2 + 1, _BYTE)
        temp%% = temp%% - Count%%

        IF temp%% = 0 THEN 'item is out so remove from inventory
            temp$ = _MEMGET(m, Pack, STRING * 32) 'get entire pack string
            temp$ = LEFT$(temp$, Match%% * 2) + MID$(temp$, 2 * Match%% + 3)
            P.Items = P.Items - 1

            l%% = LEN(temp$)
            FOR i%% = l%% TO 31 'pad temp$ to full 32 characters
                temp$ = temp$ + CHR$(0)
            NEXT i%%

            _MEMPUT m, Pack, temp$ 'put invetory back
        ELSE
            _MEMPUT m, Pack + Match%% * 2 + 1, temp%% 'put adjusted count back
        END IF
    END IF
END SUB

SUB Drop_Inventory (ID%%)
    STATIC m AS _MEM 'no need to initialize/free it over and over
    STATIC Pack AS _OFFSET
    m = _MEM(P) 'Just change where you want to point it to.
    Pack = m.OFFSET + 12 '�move to where P .Pack starts at in memory

    Match%% = -1
    FOR i%% = 0 TO 15 'find the item
        IF ID%% = _MEMGET(m, Pack + i%% * 2, _BYTE) THEN Match%% = i%%: i%% = 30
    NEXT i%%
    IF Match%% < 0 THEN
        'something went horribly wrong!
        PRINT item%%: END
    ELSE
        temp$ = _MEMGET(m, Pack, STRING * 32) 'get entire pack string
        temp$ = LEFT$(temp$, Match%% * 2) + MID$(temp$, 2 * Match%% + 3)

        P.Items = P.Items - 1

        l%% = LEN(temp$)
        FOR i%% = l%% TO 31 'pad temp$ to full 32 characters
            temp$ = temp$ + CHR$(0)
        NEXT i%%

        _MEMPUT m, Pack, temp$ 'put invetory back
    END IF
END SUB

SUB MFI_Loader (FN$)
    DIM Size(128) AS LONG, FOffset(128) AS LONG
    OPEN FN$ FOR BINARY AS #1
    GET #1, , c~%% 'retrieve number of files
    FOR I~%% = 1 TO c~%%
        GET #1, , FOffset(I~%%)
        GET #1, , Size(I~%%)
        FOffset&(I~%%) = FOffset&(I~%%) + 1
    NEXT I~%%
    Layer(22) = LoadGFX(FOffset(32), Size(32))
    'Adjust window,add title, and show music volume warning while finishing loading
    _SCREENMOVE 10, 10
    _TITLE "'Dragon Warrior 64' UniKorn ProDucKions 2020"
    Fade_InS Layer(22), 430, 182, 105, 149
    _KEYCLEAR
    Layer(10) = LoadGFX(FOffset(1), Size(1))
    Layer(3) = LoadGFX(FOffset(2), Size(2))
    Layer(4) = LoadGFX(FOffset(3), Size(3))
    Layer(13) = LoadGFX(FOffset(14), Size(14))
    Layer(14) = LoadGFX(FOffset(15), Size(15))
    Layer(16) = LoadGFX(FOffset(18), Size(18)) '_LOADIMAGE("battlefield.bmp", 32) 'battle window
    Layer(17) = LoadGFX(FOffset(17), Size(17)) '_LOADIMAGE("Monsters.bmp", 32) 'monster sheet
    Layer(23) = LoadGFX(FOffset(33), Size(33))
    Layer(24) = LoadGFX(FOffset(34), Size(34))
    Layer(25) = LoadGFX(FOffset(35), Size(35))
    Layer(26) = LoadGFX(FOffset(36), Size(36))
    Layer(27) = LoadGFX(FOffset(37), Size(37))

    BGM(-1) = LoadSFX(FOffset(4), Size(4)) 'Overworld theme
    BGM(0) = LoadSFX(FOffset(10), Size(10)) 'Tantengel Castle courtyard theme
    BGM(1) = LoadSFX(FOffset(12), Size(12)) 'Thone room theme
    BGM(3) = LoadSFX(FOffset(13), Size(13)) 'Town theme
    BGM(4) = LoadSFX(FOffset(22), Size(22)) 'Battle theme
    SFX(0) = LoadSFX(FOffset(5), Size(5)) 'Bumping into walls
    SFX(1) = LoadSFX(FOffset(8), Size(8)) 'run away from fight
    SFX(2) = LoadSFX(FOffset(9), Size(9)) 'using stairs
    SFX(3) = LoadSFX(FOffset(11), Size(11)) 'text printing
    SFX(4) = LoadSFX(FOffset(19), Size(19)) 'Level UP
    BGM(5) = LoadSFX(FOffset(20), Size(20)) 'Encounter
    SFX(6) = LoadSFX(FOffset(21), Size(21)) 'Battle Victory
    SFX(7) = LoadSFX(FOffset(23), Size(23)) 'Breath Fire
    SFX(8) = LoadSFX(FOffset(24), Size(24)) 'Fairy Flute
    SFX(9) = LoadSFX(FOffset(25), Size(25)) 'Battle Hit
    SFX(10) = LoadSFX(FOffset(26), Size(26)) 'Battle Miss
    SFX(11) = LoadSFX(FOffset(27), Size(27)) 'Stay at inn
    SFX(12) = LoadSFX(FOffset(28), Size(28)) 'Excellent hit
    SFX(13) = LoadSFX(FOffset(29), Size(29)) 'Open a chest
    SFX(14) = LoadSFX(FOffset(30), Size(30)) 'Open a door
    SFX(15) = LoadSFX(FOffset(31), Size(31)) 'Action beep

    SFX(16) = LoadSFX(FOffset(39), Size(39)) 'Barrier
    SFX(17) = LoadSFX(FOffset(40), Size(40)) 'Swamp
    SFX(18) = LoadSFX(FOffset(41), Size(41)) 'Cast Spell
    SFX(19) = LoadSFX(FOffset(42), Size(42)) 'Return\Wings
    SFX(20) = LoadSFX(FOffset(86), Size(86)) 'Silver Harp

    BGM(6) = LoadSFX(FOffset(43), Size(43)) 'Dungeon Level 1
    BGM(7) = LoadSFX(FOffset(44), Size(44)) 'Dungeon Level 2
    BGM(8) = LoadSFX(FOffset(45), Size(45)) 'Dungeon Level 3
    BGM(9) = LoadSFX(FOffset(46), Size(46)) 'Dungeon Level 4
    BGM(10) = LoadSFX(FOffset(47), Size(47)) 'Dungeon Level 5
    BGM(11) = LoadSFX(FOffset(48), Size(48)) 'Dungeon Level 6
    BGM(12) = LoadSFX(FOffset(49), Size(49)) 'Dungeon Level 7
    BGM(13) = LoadSFX(FOffset(50), Size(50)) 'Dungeon Level 8
    BGM(14) = LoadSFX(FOffset(51), Size(51)) 'Epilogue

    Starting = LoadSFX(FOffset(38), Size(38)) 'Startup Music

    Title = LoadSFX(FOffset(16), Size(16))
    LoadData FOffset(6), Size(6)
    DWFont = LoadFFX(FOffset(7), Size(7), 16)
    'Load Manual pages
    FOR i%% = 0 TO 33
        Layer(28 + i%%) = LoadGFX(FOffset(52 + i%%), Size(52 + i%%)) 'up to 85 items loaded now
    NEXT i%%

    CLOSE #1
    IF _FILEEXISTS("temp.dat") THEN KILL "temp.dat"
END SUB

FUNCTION LoadGFX& (Foff&, Size&)
    SEEK #1, Foff&
    LoadGFX& = _LOADIMAGE(INPUT$(Size&, 1), 32, "memory")
END FUNCTION

FUNCTION LoadFFX& (Foff&, Size&, Fize%%)
    SEEK #1, Foff&
    LoadFFX& = _LOADFONT(INPUT$(Size&, 1), Fize%%, "monospace, memory")
END FUNCTION

FUNCTION LoadSFX& (Foff&, Size&)
    SEEK #1, Foff&
    LoadSFX& = _SNDOPEN(INPUT$(Size&, 1), "memory")
END FUNCTION

SUB LoadData (Foff&, Size&)
    IF _FILEEXISTS("temp.dat") THEN KILL "temp.dat"
    OPEN "temp.dat" FOR BINARY AS #3
    dat$ = SPACE$(Size&)
    GET #1, Foff&, dat$
    PUT #3, , dat$
    CLOSE #3

    F1 = FREEFILE
    OPEN "temp.dat" FOR BINARY AS #F1
    GET #F1, , World()
    GET #F1, , Place()
    GET #F1, , I()
    GET #F1, , L()
    GET #F1, , GF()
    GET #F1, , M()
    GET #F1, , Stairs()
    GET #F1, , PD()
    GET #F1, , Chest()
    FOR i% = 1 TO 365
        GET #F1, , L~%%
        Script(i%) = SPACE$(L~%%)
        GET #F1, , Script(i%)
    NEXT i%
    GET #F1, , NPC()
    GET #F1, , Lines()
    GET #F1, , SA()
    GET #F1, , BSA()
    GET #F1, , LS()
    GET #F1, , Messages()
    GET #F1, , Shop()
    GET #F1, , Doors()
    FOR i%% = 1 TO 12
        GET #F1, , L~%%
        Spells(i%%) = SPACE$(L~%%)
        GET #F1, , Spells(i%%)
    NEXT
    GET #F1, , MZG()
    GET #F1, , Map_Music()
    GET #F1, , KeyCodes()
    GET #F1, , Entrance()
    CLOSE #F1
END SUB

SUB Run_Title_Screen
    _SNDLOOP Title
    _DEST Layer(1)
    COLOR _RGB32(234, 158, 34)
    DO
        'KBD& = _KEYHIT
        KBD& = Get_Input

        IF KBD& >= 0 AND Triggered%% THEN ExitFlag%% = TRUE
        IF KBD& >= 0 AND (NOT Triggered%%) THEN Triggered%% = TRUE: _DELAY .1: '_keyclear

        IF _SNDGETPOS(Title) >= 10 OR Triggered%% THEN
            _PUTIMAGE (0, 0)-STEP(512, 479), Layer(13), Layer(1), (0, 0)-STEP(255, 239)
            IF INT(RND * 100) > 97 THEN flare%% = TRUE
            Triggered%% = TRUE
            _PRINTSTRING (256 - 112, 304), "-PRESS ANY KEY-", Layer(1)
        ELSE
            _PUTIMAGE (0, 84)-STEP(512, 183), Layer(13), Layer(1), (0, 240)-STEP(255, 91)
        END IF

        IF flare%% THEN flare%% = Draw_Flare
        _PUTIMAGE , Layer(1), Layer(0)
        ClearLayer Layer(1)

        'Load World Map while Title Displays
        IF _SNDGETPOS(Title) < .25 AND (NOT World_BUILT%%) THEN Build_World_Layer Layer(2): World_BUILT%% = TRUE
        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    COLOR _RGB32(240, 240, 240)
    _DEST Layer(0)
    _SNDSTOP Title
    _DELAY .1
    _KEYCLEAR
END SUB

FUNCTION Draw_Flare%% ()
    STATIC Frame%%, Delayr%%, Direction%%
    Result%% = TRUE
    SELECT CASE Frame%%
        CASE 0
            _PUTIMAGE (387, 163), Layer(14), Layer(1), (0, 0)-(16, 24)
        CASE 1
            _PUTIMAGE (381, 151), Layer(14), Layer(1), (17, 0)-STEP(27, 47)
        CASE 2
            _PUTIMAGE (367, 132), Layer(14), Layer(1), (49, 1)-STEP(55, 83)
        CASE 3
            _PUTIMAGE (363, 118), Layer(14), Layer(1), (111, 1)-STEP(75, 119)
    END SELECT
    IF Direction%% THEN
        IF Delayr%% = 5 THEN Frame%% = Frame%% - 1: Delayr%% = 0
        IF Frame%% = -1 THEN Frame%% = 0: Direction%% = 0: Result%% = FALSE
    ELSE
        IF Delayr%% = 5 THEN Frame%% = Frame%% + 1: Delayr%% = 0
        IF Frame%% = 4 THEN Frame%% = 3: Direction%% = 1
    END IF
    Delayr%% = Delayr%% + 1
    Draw_Flare = Result%%
END FUNCTION
FUNCTION PickGameFile%% (Games%%)
    Result%% = FALSE
    DO
        _PUTIMAGE , Layer(5), Layer(1)
        SELECT CASE Games%%
            CASE 0 'all three availible
                Draw_Window 10, 17, 19, 7, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 1", Layer(1)
                _PRINTSTRING (16 * 12, 16 * 21), "ADVENTURE LOG 2", Layer(1)
                _PRINTSTRING (16 * 12, 16 * 23), "ADVENTURE LOG 3", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 4 THEN Selection%% = 3
            CASE 1 'slot 2 and 3
                Draw_Window 10, 17, 19, 5, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 2", Layer(1)
                _PRINTSTRING (16 * 12, 16 * 21), "ADVENTURE LOG 3", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 3 THEN Selection%% = 2
            CASE 2 'slot 1 and 3
                Draw_Window 10, 17, 19, 5, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 1", Layer(1)
                _PRINTSTRING (16 * 12, 16 * 21), "ADVENTURE LOG 3", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 3 THEN Selection%% = 2
            CASE 3 'slot 3
                Draw_Window 10, 17, 19, 3, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 3", Layer(1)
                IF Selection%% <> 1 THEN Selection%% = 1
            CASE 4 'slot 1 and 2
                Draw_Window 10, 17, 19, 5, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 1", Layer(1)
                _PRINTSTRING (16 * 12, 16 * 21), "ADVENTURE LOG 2", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 3 THEN Selection%% = 2
            CASE 5 'slot 2
                Draw_Window 10, 17, 19, 3, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 2", Layer(1)
                IF Selection%% <> 1 THEN Selection%% = 1
            CASE 6 'slot 1
                Draw_Window 10, 17, 19, 3, Layer(1)
                _PRINTSTRING (16 * 12, 16 * 19), "ADVENTURE LOG 1", Layer(1)
                IF Selection%% <> 1 THEN Selection%% = 1
        END SELECT
        IF Frame%% THEN Display_Selection_Arrow 11, 17 + (Selection%% * 2), Layer(1)

        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 60

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE DOWN
                Selection%% = Selection%% + 1
                '    Joy_Lock_Axis(c.joy_down)
                DO: LOOP WHILE Get_Input >= 0
            CASE UP
                Selection%% = Selection%% - 1
                '    Joy_Lock_Axis(c.joy_up)
                DO: LOOP WHILE Get_Input >= 0
            CASE BUTTON_A
                Display_Selection_Arrow 11, 17 + (Selection%% * 2), Layer(1) 'force arrow shown
                SELECT CASE Games%%
                    CASE 0 'no games so player can choose 1 to 3
                        Result%% = Selection%%
                    CASE 1 'only game 2 and 3 open
                        Result%% = Selection%% + 1
                    CASE 2 'game 1 and 3 open
                        IF Selection%% = 1 THEN Result%% = Selection%% ELSE Result%% = 3
                    CASE 3 'only game 3 open
                        Result%% = 3
                    CASE 4 'game 1 or 2 open
                        Result%% = Selection%%
                    CASE 5 'only game 2 open
                        Result%% = 2
                    CASE 6 'only game 1 open
                        Result%% = Selection%%
                END SELECT
                ExitFlag%% = TRUE
                DO: LOOP WHILE Get_Input >= 0
            CASE BUTTON_B 'cancel game start
                ExitFlag%% = TRUE
                DO: LOOP WHILE Get_Input >= 0
        END SELECT
    LOOP UNTIL ExitFlag%%

    PickGameFile%% = Result%%
END FUNCTION

SUB PickHeroName
    DIM n(8) AS STRING * 1
    FOR i%% = 1 TO 8: n(i%%) = "*": NEXT i%% 'Preset name to blank
    Selection%% = 1: CurrentLetter%% = 1

    DO
        _PUTIMAGE , Layer(5), Layer(1)
        Draw_Window 10, 5, 11, 5, Layer(1)
        IF CurrentLetter%% = 9 THEN CurrentLetter%% = 8: ExitFlag%% = TRUE 'if last character is set then exit
        _PRINTSTRING (16 * 14, 16 * 5), "NAME", Layer(1)
        _PUTIMAGE (16 * (11 + CurrentLetter%%), 16 * 7 + 8)-STEP(15, 15), Layer(3), Layer(1), (48, 18)-STEP(7, 7)
        FOR i%% = 1 TO 8
            _PRINTSTRING (16 * (11 + i%%), 16 * 7), n(i%%), Layer(1)
        NEXT i%%
        Draw_Window 4, 9, 23, 13, Layer(1)
        _PRINTSTRING (16 * 6, 16 * 11), "A B C D E F G H I J K", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 13), "L M N O P Q R S T U V", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 17), "a b c d e f g h i j k", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 19), "l m n o p q r s t u v", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 15), "W X Y Z - ' ! ? ( )  ", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 21), "w x y z , . BACK  END", Layer(1)
        IF Frame%% THEN Display_Selection_Arrow LS(Selection%%).X, LS(Selection%%).Y, Layer(1)
        _PUTIMAGE , Layer(1), Layer(0)

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE UP
                Selection%% = Selection%% - 11
                IF Selection%% < 1 THEN Selection%% = Selection%% + 11
            CASE DOWN
                Selection%% = Selection%% + 11
                IF Selection%% > 63 THEN Selection%% = Selection%% - 11
            CASE RIGHT
                Selection%% = Selection%% + 1
                IF Selection%% > 63 THEN Selection%% = 63
            CASE LEFT
                Selection%% = Selection%% - 1
                IF Selection%% < 1 THEN Selection%% = 1
            CASE BUTTON_A
                SELECT CASE Selection%%
                    CASE 62
                        IF CurrentLetter%% > 1 THEN CurrentLetter%% = CurrentLetter%% - 1
                    CASE 63
                        ExitFlag%% = TRUE
                    CASE ELSE
                        n(CurrentLetter%%) = CHR$(LS(Selection%%).C)
                        CurrentLetter%% = CurrentLetter%% + 1
                END SELECT
            CASE BUTTON_B
                IF CurrentLetter%% > 1 THEN CurrentLetter%% = CurrentLetter%% - 1
        END SELECT
        DO: LOOP WHILE Get_Input >= 0
        _LIMIT 60
    LOOP UNTIL ExitFlag%%

    FOR i%% = 1 TO 8 'set Hero name
        IF n(i%%) <> "*" THEN nam$ = nam$ + n(i%%) ELSE i%% = 9
    NEXT i%%
    P.Nam = nam$
END SUB

FUNCTION PickMessageSpeed%% (Current%%)
    Result%% = FALSE
    IF Current%% = 0 THEN Selection%% = 2 ELSE Selection%% = Current%%
    DO
        _PUTIMAGE , Layer(5), Layer(1)
        Draw_Window 8, 13, 17, 13, Layer(1)
        _PRINTSTRING (16 * 10, 16 * 14), "Which Message", Layer(1)
        _PRINTSTRING (16 * 10, 16 * 16), "Speed Do You", Layer(1)
        _PRINTSTRING (16 * 10, 16 * 18), "Want To Use?", Layer(1)
        _PRINTSTRING (16 * 15, 16 * 21), "FAST", Layer(1)
        _PRINTSTRING (16 * 15, 16 * 23), "NORMAL", Layer(1)
        _PRINTSTRING (16 * 15, 16 * 25), "SLOW", Layer(1)
        IF Frame%% THEN Display_Selection_Arrow 14, 19 + (Selection%% * 2), Layer(1)
        _PUTIMAGE , Layer(1), Layer(0)
        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE UP
                Selection%% = Selection%% - 1
                IF Selection%% = 0 THEN Selection%% = Selection%% + 1
            CASE DOWN
                Selection%% = Selection%% + 1
                IF Selection%% = 4 THEN Selection%% = Selection%% - 1
            CASE BUTTON_A
                ExitFlag%% = TRUE
                Result%% = Selection%%
            CASE BUTTON_B
                ExitFlag%% = TRUE
        END SELECT

        DO: LOOP WHILE Get_Input >= 0

        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    PickMessageSpeed = Result%%
END FUNCTION

FUNCTION CreateNewQuest%% (Games%%)
    Result%% = FALSE

    G.SaveFile = PickGameFile(Games%%) 'have player pick game slot(file) to use
    IF G.SaveFile THEN
        _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
        PickHeroName
        _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
        G.MessageSpeed = PickMessageSpeed(0)
    END IF
    IF G.MessageSpeed THEN Result%% = TRUE: Init_Player 'if player picked message speed then start game!

    MenuD(G.SaveFile).HName = P.Nam
    MenuD(G.SaveFile).MesSpd = G.MessageSpeed
    MenuD(G.SaveFile).CurLvl = 0 'new game so level 0

    CreateNewQuest = Result%%
END FUNCTION
FUNCTION RestoreGameFile%% (Games%%)
    Result%% = FALSE
    DO
        _PUTIMAGE , Layer(5), Layer(1)
        SELECT CASE Games%%
            CASE 7 'all three availible
                Draw_Window 6, 11, 23, 7, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 1:" + LEFT$(MenuD(1).HName, 4), Layer(1)
                _PRINTSTRING (16 * 8, 16 * 15), "ADVENTURE LOG 2:" + LEFT$(MenuD(2).HName, 4), Layer(1)
                _PRINTSTRING (16 * 8, 16 * 17), "ADVENTURE LOG 3:" + LEFT$(MenuD(3).HName, 4), Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 4 THEN Selection%% = 3
            CASE 1 'Game in slot 1 only
                Draw_Window 6, 11, 23, 3, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 1:" + LEFT$(MenuD(1).HName, 4), Layer(1)
                IF Selection%% <> 1 THEN Selection%% = 1
            CASE 2 'game in slot 2 only
                Draw_Window 6, 11, 23, 3, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 2:" + LEFT$(MenuD(2).HName, 4), Layer(1)
                IF Selection%% <> 1 THEN Selection%% = 1
            CASE 3 'Slot 1 and 2
                Draw_Window 6, 11, 23, 5, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 1:" + LEFT$(MenuD(1).HName, 4), Layer(1)
                _PRINTSTRING (16 * 8, 16 * 15), "ADVENTURE LOG 2:" + LEFT$(MenuD(2).HName, 4), Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 3 THEN Selection%% = 2
            CASE 4 'game in slot 3 only
                Draw_Window 6, 11, 23, 3, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 3:" + LEFT$(MenuD(3).HName, 4), Layer(1)
                IF Selection%% <> 1 THEN Selection%% = 1
            CASE 5 'slot 1 and 3
                Draw_Window 6, 11, 23, 5, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 1:" + LEFT$(MenuD(1).HName, 4), Layer(1)
                _PRINTSTRING (16 * 8, 16 * 15), "ADVENTURE LOG 3:" + LEFT$(MenuD(3).HName, 4), Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 3 THEN Selection%% = 2
            CASE 6 'slot 2 and 3
                Draw_Window 6, 11, 23, 5, Layer(1)
                _PRINTSTRING (16 * 8, 16 * 13), "ADVENTURE LOG 2:" + LEFT$(MenuD(2).HName, 4), Layer(1)
                _PRINTSTRING (16 * 8, 16 * 15), "ADVENTURE LOG 3:" + LEFT$(MenuD(3).HName, 4), Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 3 THEN Selection%% = 2
        END SELECT
        IF Frame%% THEN Display_Selection_Arrow 7, 11 + (Selection%% * 2), Layer(1)

        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 60

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE DOWN
                Selection%% = Selection%% + 1
            CASE UP
                Selection%% = Selection%% - 1
            CASE BUTTON_A
                Display_Selection_Arrow 11, 17 + (Selection%% * 2), Layer(1) 'force arrow shown
                SELECT CASE Games%%
                    CASE 7 'all games
                        Result%% = Selection%%
                    CASE 1 'game in slot 1 only
                        Result%% = Selection%%
                    CASE 2 'game in slot 2 only
                        Result%% = 2
                    CASE 3 'Slot 1 and 2
                        Result%% = Selection%%
                    CASE 4 'game in slot 3 only
                        Result%% = 3
                    CASE 5 'slot 1 and 3
                        IF Selection%% = 2 THEN Result%% = 3 ELSE Result%% = 1
                    CASE 6 'slot 2 and 3
                        Result%% = Selection%% + 1
                END SELECT
                ExitFlag%% = TRUE
            CASE BUTTON_B 'cancel game load
                ExitFlag%% = TRUE
        END SELECT
    LOOP UNTIL ExitFlag%%

    RestoreGameFile = Result%%
END FUNCTION

SUB CopyQuestFile (From%%, Where%%)
    OPEN "DW1.SV" + LTRIM$(STR$(From%%)) FOR BINARY AS #1
    Temp$ = SPACE$(LOF(1))
    GET #1, , Temp$
    CLOSE #1
    OPEN "DW1.SV" + LTRIM$(STR$(Where%%)) FOR BINARY AS #1
    PUT #1, , Temp$
    CLOSE #1
END SUB
SUB Display_EraseWindow (File%%)
    _PUTIMAGE , Layer(5), Layer(1)
    Draw_Window 6, 13, 19, 11, Layer(1)
    _PRINTSTRING (16 * 8, 16 * 15), MenuD(File%%).HName, Layer(1)
    _PRINTSTRING (16 * 8, 16 * 17), "LEVEL  " + STR$(MenuD(File%%).CurLvl), Layer(1)
    _PRINTSTRING (16 * 8, 16 * 19), "Do You Want To", Layer(1)
    _PRINTSTRING (16 * 8, 16 * 21), "Erase This", Layer(1)
    _PRINTSTRING (16 * 8, 16 * 23), "Character?", Layer(1)
END SUB

SUB Erase_AdventureLog (id%%)
    KILL "DW1.SV" + LTRIM$(STR$(id%%))
END SUB

FUNCTION Log_Check%%
    IF _FILEEXISTS("DW1.SV1") THEN GF%% = GF%% + 1: OPEN "DW1.SV1" FOR BINARY AS #1: GET #1, 5, MenuD(1): CLOSE #1
    IF _FILEEXISTS("DW1.SV2") THEN GF%% = GF%% + 2: OPEN "DW1.SV2" FOR BINARY AS #1: GET #1, 5, MenuD(2): CLOSE #1
    IF _FILEEXISTS("DW1.SV3") THEN GF%% = GF%% + 4: OPEN "DW1.SV3" FOR BINARY AS #1: GET #1, 5, MenuD(3): CLOSE #1
    Log_Check = GF%%
END FUNCTION

SUB GameStartMenu
    GF%% = Log_Check
    _SNDLOOP BGM(3)
    DO
        IF _KEYHIT = 9 THEN G.ControlType = NOT G.ControlType 'toggle between joypad control and keyboard control

        SELECT CASE GF%%
            CASE 0
                Draw_Window 4, 7, 23, 9, Layer(1)
                _PUTIMAGE (16 * 16 - 2, 2 * 16)-STEP(7 * 15 + 4, 1 * 15), Layer(3), Layer(1), (205, 35)-STEP(15, 15)
                _PRINTSTRING (16 * 6, 16 * 9), "BEGIN A NEW QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 11), "VOLUME CONTROLS", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 13), "CUSTOMIZE CONTROLS", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 15), "VIEW GAME MANUAL", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 5 THEN Selection%% = 4
            CASE 1 TO 6
                Draw_Window 4, 7, 23, 18, Layer(1)
                _PUTIMAGE (16 * 16 - 2, 2 * 16)-STEP(7 * 15 + 4, 1 * 15), Layer(3), Layer(1), (205, 35)-STEP(15, 15)
                _PRINTSTRING (16 * 6, 16 * 9), "CONTINUE A QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 11), "CHANGE MESSAGE SPEED", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 13), "BEGIN A NEW QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 15), "COPY A QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 17), "ERASE A QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 19), "VOLUME CONTROLS", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 21), "CUSTOMIZE CONTROLS", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 23), "VIEW GAME MANUAL", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 9 THEN Selection%% = 8
            CASE 7
                Draw_Window 4, 7, 23, 14, Layer(1)
                _PUTIMAGE (16 * 16 - 2, 2 * 16)-STEP(7 * 15 + 4, 1 * 15), Layer(3), Layer(1), (205, 35)-STEP(15, 15)
                _PRINTSTRING (16 * 6, 16 * 9), "CONTINUE A QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 11), "CHANGE MESSAGE SPEED", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 13), "ERASE A QUEST", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 15), "VOLUME CONTROLS", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 17), "CUSTOMIZE CONTROLS", Layer(1)
                _PRINTSTRING (16 * 6, 16 * 19), "VIEW GAME MANUAL", Layer(1)
                IF Selection%% = 0 THEN Selection%% = 1
                IF Selection%% = 7 THEN Selection%% = 6
        END SELECT
        IF Frame%% THEN Display_Selection_Arrow 5, 7 + (Selection%% * 2), Layer(1)

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE DOWN
                Selection%% = Selection%% + 1
            CASE UP
                Selection%% = Selection%% - 1
            CASE BUTTON_A
                Display_Selection_Arrow 5, 7 + (Selection%% * 2), Layer(1) 'force arrow shown
                DO: LOOP WHILE Get_Input >= 0

                SELECT CASE GF%%
                    CASE 0 'no games so player can only choose to start a new quest
                        SELECT CASE Selection%%
                            CASE 1
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                ExitFlag%% = CreateNewQuest(GF%%) 'start a new game!
                                IF ExitFlag%% THEN F.Just_Started = TRUE: Save_Game
                            CASE 2
                                Volume_Controls
                            CASE 3
                                Custom_Controls
                            CASE 4
                                Display_Manual
                        END SELECT
                        ClearLayer Layer(1)
                    CASE 1 TO 6 'full list of options
                        SELECT CASE Selection%%
                            CASE 1 'Continue a Quest!
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                G.SaveFile = RestoreGameFile(GF%%) 'have player pick game slot(file) to load
                                IF G.SaveFile THEN 'did player choose record to resume?
                                    Load_Game
                                    F.Just_Started = TRUE
                                    ClearLayer Layer(1)
                                    ExitFlag%% = TRUE
                                END IF
                            CASE 2 'Change Message Speed
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                G.SaveFile = RestoreGameFile(GF%%) 'have player pick game slot(file) to load message speed
                                OPEN "DW1.SV" + LTRIM$(STR$(G.SaveFile)) FOR BINARY AS #1: GET #1, 118, G.MessageSpeed
                                G.MessageSpeed = PickMessageSpeed(G.MessageSpeed)
                                PUT #1, 9, G.MessageSpeed 'save new message speed to header
                                PUT #1, 118, G.MessageSpeed 'save new message speed game flags
                                CLOSE #1
                                ClearLayer Layer(1)
                            CASE 3
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                ExitFlag%% = CreateNewQuest(GF%%)
                                IF ExitFlag%% THEN F.Just_Started = TRUE
                                ClearLayer Layer(1)
                            CASE 4 'Copy a Quest
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                GameFile%% = RestoreGameFile(GF%%) 'have player pick game slot(file) to load message speed
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                CopyFile%% = PickGameFile(GF%%) 'have player pick game slot(file) to use
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                IF Yes_NO_Box(20, 5, Layer(1)) THEN CopyQuestFile GameFile%%, CopyFile%%: GF%% = Log_Check
                                ClearLayer Layer(1)
                            CASE 5 'Erase a Quest
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                GameFile%% = RestoreGameFile(GF%%) 'have player pick game slot(file) to load message speed
                                IF GameFile%% THEN
                                    _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                    Display_EraseWindow GameFile%%
                                    _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                    IF Yes_NO_Box(20, 5, Layer(1)) THEN Erase_AdventureLog GameFile%%: GF%% = Log_Check
                                END IF
                                ClearLayer Layer(1)
                            CASE 6 'Volume Controls
                                ClearLayer Layer(1)
                                Volume_Controls
                            CASE 7 'Custom Controls
                                Custom_Controls
                            CASE 8 'show game manual booklet
                                Display_Manual
                        END SELECT
                        ClearLayer Layer(1)
                    CASE 7 'player can not copy or start new quest
                        SELECT CASE Selection%%
                            CASE 1 'Continue a Quest!
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                GameFile%% = RestoreGameFile(GF%%) 'have player pick game slot(file) to load
                            CASE 2 'Change Message Speed
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                GameFile%% = RestoreGameFile(GF%%) 'have player pick game slot(file) to load message speed
                                MenuD(GameFile%%).MesSpd = PickMessageSpeed(MenuD(GameFile%%).MesSpd)
                            CASE 3 'Erase a Quest
                                _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                GameFile%% = RestoreGameFile(GF%%) 'have player pick game slot(file) to load message speed
                                IF GameFile%% THEN
                                    _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                    Display_EraseWindow GameFile%%
                                    _PUTIMAGE , Layer(1), Layer(5) 'copy current screen to layer 5
                                    IF Yes_NO_Box(20, 5, Layer(1)) THEN Erase_AdventureLog GameFile%%: GF%% = Log_Check
                                END IF
                            CASE 4 'custom volume controls
                                ClearLayer Layer(1)
                                Volume_Controls
                            CASE 5 'Custom control setup
                                Custom_Controls
                            CASE 6 'display game manual
                                Display_Manual
                        END SELECT
                        ClearLayer Layer(1)
                END SELECT
        END SELECT
        DO: LOOP WHILE Get_Input >= 0
        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 60

    LOOP UNTIL ExitFlag%%
    _SNDSTOP BGM(3)
END SUB

SUB Volume_Controls
    STATIC BGMV AS SINGLE, SFXV AS SINGLE
    Selection%% = 1
    IF G.BGMVol = 0 AND G.SFXVol = 0 THEN BGMV = .1: SFXV = .1 ELSE BGMV = G.BGMVol: SFXV = G.SFXVol
    _DEST Layer(1)
    DO
        Draw_Window 3, 10, 28, 9, Layer(1)
        _PRINTSTRING (16 * 6, 16 * 11), "BGM VOL.", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 14), "SFX VOL.", Layer(1)
        _PRINTSTRING (16 * 6, 16 * 17), "MESSAGE CLICK   ON   OFF", Layer(1)
        IF Frame%% THEN Display_Selection_Arrow 5, 8 + (Selection%% * 3), Layer(1)
        IF G.TextClick THEN Display_Selection_Arrow 21, 17, Layer(1) ELSE Display_Selection_Arrow 26, 17, Layer(1)
        LINE (96, 196)-STEP(16 * 16, 16), _RGB32(0 + INT(255 * BGMV), 255 - INT(255 * BGMV), 0), BF
        LINE (96, 244)-STEP(16 * 16, 16), _RGB32(0 + INT(255 * SFXV), 255 - INT(255 * SFXV), 0), BF
        LINE (96 + (256 * BGMV), 194)-STEP(1, 20), _RGB32(224, 224, 224), B
        LINE (96 + (256 * SFXV), 242)-STEP(1, 20), _RGB32(224, 224, 224), B
        _PUTIMAGE , Layer(1), Layer(0)

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE DOWN
                Selection%% = Selection%% + 1
            CASE UP
                Selection%% = Selection%% - 1
            CASE LEFT
                SELECT CASE Selection%%
                    CASE 1
                        BGMV = BGMV - .05
                    CASE 2
                        SFXV = SFXV - .05
                    CASE 3
                        G.TextClick = TRUE
                END SELECT
            CASE RIGHT
                SELECT CASE Selection%%
                    CASE 1
                        BGMV = BGMV + .05
                    CASE 2
                        SFXV = SFXV + .05
                    CASE 3
                        G.TextClick = FALSE
                END SELECT
            CASE BUTTON_A, BUTTON_B
                ExitFlag%% = TRUE
        END SELECT

        IF BGMV < .05 THEN BGMV = .05
        IF SFXV < .05 THEN SFXV = .05
        IF BGMV > 1 THEN BGMV = 1
        IF SFXV > 1 THEN SFXV = 1
        IF Selection%% = 0 THEN Selection%% = 1
        IF Selection%% = 4 THEN Selection%% = 3

        FOR i%% = -1 TO 15
            _SNDVOL BGM(i%%), BGMV
        NEXT i%%
        _SNDVOL Title, BGMV
        FOR i%% = 0 TO 32
            _SNDVOL SFX(i%%), SFXV
        NEXT i%%

        DO: LOOP WHILE Get_Input >= 0
        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    G.BGMVol = BGMV
    G.SFXVol = SFXV
    _DEST Layer(0)
END SUB

SUB Display_Manual
    _PRINTMODE _KEEPBACKGROUND , Layer(1)
    _PUTIMAGE (10, 20)-STEP(614, 460), Layer(28 + Page%%), Layer(1), (0, 0)-STEP(619, 469)
    Fade_In Layer(1)
    DO
        C_Input%% = Get_Input

        SELECT CASE C_Input%%
            CASE LEFT
                IF Page%% > 0 THEN OldPage%% = Page%%: Page%% = Page%% - 1
            CASE RIGHT
                IF Page%% < 33 THEN OldPage%% = Page%%: Page%% = Page%% + 1
            CASE BUTTON_B
                ExitFlag%% = TRUE
        END SELECT
        DO: LOOP UNTIL Get_Input = -1

        _PRINTSTRING (20, 0), "Left-Right to Navagate, B Button-Exit.", Layer(1)
        _PUTIMAGE (10, 20)-STEP(614, 460), Layer(28 + Page%%), Layer(1), (0, 0)-STEP(619, 469)
        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    _PRINTMODE _FILLBACKGROUND , Layer(1)
END SUB

SUB Level_Up
    Result%% = Message_Handler(Layer(15), 366) 'level up
    G.Old_Str = P.Strength: G.Old_Agl = P.Agility: G.Old_Mhp = P.Max_HP: G.Old_Mmp = P.Max_MP 'store old values
    IF P.Level = 0 THEN 'Set stat increase for first level
        P.Strength = P.Strength + 4
        P.Agility = P.Agility + 5
        P.Luck = P.Luck + INT(RND * 3) + INT(0 + (P.Age - 25)) * (.4 + ((P.Age - 17) / 50) + .49)
        P.Max_HP = P.Max_HP + 5
        P.Max_MP = P.Max_MP + 2
    ELSE 'then random increases.
        Sadj = INT(RND * 9) + 1 - INT((-5 + (P.Age - 20)) * (.15 + ((P.Age - 17) / 100)) - .49)
        P.Strength = P.Strength + Sadj
        Aadj = INT(RND * 8) + 1 - INT((-8 + (P.Age - 20)) * (.4 + ((P.Age - 17) / 100)) - .49)
        P.Agility = P.Agility + Aadj
        P.Luck = P.Luck + INT(RND * 3) + INT(0 + (P.Age - 25)) * (.4 + ((P.Age - 17) / 50) + .49)
        P.Max_HP = P.Max_HP + INT(RND * (10 - (P.Age / 10))) + INT(P.Level \ 4) + 1
        P.Max_MP = P.Max_MP + INT(RND * (5 + (P.Age / 10))) + INT(P.Level \ 4) + 2
    END IF
    P.Level = P.Level + 1
    P.Age = 15 + INT(P.Level * 1.5 - .49)
    IF P.Strength - G.Old_Str > 0 THEN Result%% = Message_Handler(Layer(15), 367) 'level up
    IF P.Agility - G.Old_Agl > 0 THEN Result%% = Message_Handler(Layer(15), 381) 'level up
    IF P.Max_HP - G.Old_Mhp > 0 THEN Result%% = Message_Handler(Layer(15), 382) 'level up
    IF P.Max_MP - G.Old_Mmp > 0 THEN Result%% = Message_Handler(Layer(15), 383) 'level up


    Check_Level_Up_Spells
END SUB

SUB Check_Level_Up_Spells
    'give spells to player based on Max_MP
    'heal-restores 7-18hp
    IF P.Max_MP >= 4 AND (NOT _READBIT(P.Spells, 0)) THEN P.Spells = _SETBIT(P.Spells, 0): Result%% = Message_Handler(Layer(15), 368) '
    'hurt-hits enemy for 5-12hp
    IF P.Max_MP >= 10 AND (NOT _READBIT(P.Spells, 1)) THEN P.Spells = _SETBIT(P.Spells, 1): Result%% = Message_Handler(Layer(15), 368) '
    'sleep-puts enemy to sleep for up to 6 rounds
    IF P.Max_MP >= 20 AND (NOT _READBIT(P.Spells, 2)) THEN P.Spells = _SETBIT(P.Spells, 2): Result%% = Message_Handler(Layer(15), 368) '
    'radiant-generates light in caves radius x3 for 200 steps
    IF P.Max_MP >= 32 AND (NOT _READBIT(P.Spells, 3)) THEN P.Spells = _SETBIT(P.Spells, 3): Result%% = Message_Handler(Layer(15), 368) '
    'stopspell-prevents enemy from using magic including healing spells
    IF P.Max_MP >= 48 AND (NOT _READBIT(P.Spells, 4)) THEN P.Spells = _SETBIT(P.Spells, 4): Result%% = Message_Handler(Layer(15), 368) '
    'outside-teleports player out of a cave\temple
    IF P.Max_MP >= 52 AND (NOT _READBIT(P.Spells, 5)) THEN P.Spells = _SETBIT(P.Spells, 5): Result%% = Message_Handler(Layer(15), 368) '
    'return- teleports player back to Tantegel castle
    IF P.Max_MP >= 64 AND (NOT _READBIT(P.Spells, 6)) THEN P.Spells = _SETBIT(P.Spells, 6): Result%% = Message_Handler(Layer(15), 368) '
    'repel-stops attacks from monsters weaker than player for 128 steps
    IF P.Max_MP >= 80 AND (NOT _READBIT(P.Spells, 7)) THEN P.Spells = _SETBIT(P.Spells, 7): Result%% = Message_Handler(Layer(15), 368) '
    'HealMore-restores 70-110hp
    IF P.Max_MP >= 94 AND (NOT _READBIT(P.Spells, 8)) THEN P.Spells = _SETBIT(P.Spells, 8): Result%% = Message_Handler(Layer(15), 368) '
    'HurtMore-hits enemy for 58-65hp
    IF P.Max_MP >= 98 AND (NOT _READBIT(P.Spells, 9)) THEN P.Spells = _SETBIT(P.Spells, 9): Result%% = Message_Handler(Layer(15), 368) '
    'Strengthen-adds 1/4 bonus to players attack strength for duration of battle
    IF P.Max_MP >= 114 AND (NOT _READBIT(P.Spells, 10)) THEN P.Spells = _SETBIT(P.Spells, 10): Result%% = Message_Handler(Layer(15), 368) '
    'Quicken-adds 1/3 bonus to players defensive strength for duration of battle
    IF P.Max_MP >= 124 AND (NOT _READBIT(P.Spells, 11)) THEN P.Spells = _SETBIT(P.Spells, 11): Result%% = Message_Handler(Layer(15), 368) '
END SUB

SUB Init_Player
    '---------------Player starting stats-----------------------
    P.Max_HP = INT(RND * 8) + 12 'start 12-20hp
    P.HP = P.Max_HP
    IF INT(RND * 100) = 95 THEN P.Max_MP = INT(RND * 3) + 4 '1 in 100 chance of starting with magical powers
    IF P.Max_MP THEN P.Spells = _SETBIT(P.Spells, 0) 'give player HEAL if they start with magic
    P.MP = P.Max_MP
    P.Strength = INT(RND * 3) + 3 'determines base attack damage
    P.Agility = INT(RND * 3) + 3 'determines base defence\evasion
    P.Luck = INT(RND * 5) 'a "chance" bonus to hits and evasions
    P.Level = 0 'starting at base; first fight elevates to level 1, no xp gain though
    P.Age = 17 'level adds to age *1.5 (level 10 adds 15 to age, 20 adds 30, 30 adds 45, max age 72!)
    ' age affects Strength by subtracting INT((-5 + (Age - 20)) * (.15 + ((Age-17)/100))-.49)  ;  youth gives strength
    ' age affects Agility by subtracting INT((-8 + (Age - 20)) * (.4 + ((Age-17)/100))-.49)   ;  youth gives great agility, age loses agility quickly
    ' age affects Luck by adding (0 + (Age - 25)) * (.4 + ((Age-17)/50))  ;  age adds luck
    P.Weapon = 0 'adds to Attack strength , start with Fists
    P.Armor = 8 'adds to Defensive strength , start with Loin Cloth
    P.Shield = 16 'adds to Defensive strength , start with None
    P.Gold = 0
    P.Exp = 0
    P.WorldX = 44
    P.WorldY = 44
    P.MapX = 17 'when starting game player always starts here
    P.MapY = 18
    P.Map = 1
    P.Facing = UP 'have player facing the king
    P.Torched = 0
    P.Radiant = 0
    P.Is_Repel = -1
    '-----------------------------------------------------------
END SUB

SUB Draw_Stat_Window (L&)
    Draw_Window 2, 4, 7, 11, L&
    _PUTIMAGE (4 * 16 - 2, 4 * 16)-STEP(4 * 15 + 4, 1 * 15), Layer(3), L&, (205, 35)-STEP(15, 15)
    _PRINTSTRING (16 * 4, 16 * 4), LEFT$(P.Nam, 4), L&
    _PRINTSTRING (16 * 3, 16 * 6), "LV", L&
    _PRINTSTRING (16 * 3, 16 * 8), "HP", L&
    _PRINTSTRING (16 * 3, 16 * 10), "MP", L&
    _PRINTSTRING (16 * 3, 16 * 12), "G", L&
    _PRINTSTRING (16 * 3, 16 * 14), "E", L&
    _PRINTSTRING (16 * (9 - LEN(STR$(P.Level))), 16 * 6), STR$(P.Level), L&
    _PRINTSTRING (16 * (9 - LEN(STR$(P.HP))), 16 * 8), (STR$(P.HP)), L&
    _PRINTSTRING (16 * (9 - LEN(STR$(P.MP))), 16 * 10), STR$(P.MP), L&
    _PRINTSTRING (16 * (10 - LEN(STR$(P.Gold))), 16 * 12), LTRIM$(STR$(P.Gold)), L&
    _PRINTSTRING (16 * (10 - LEN(STR$(P.Exp))), 16 * 14), LTRIM$(STR$(P.Exp)), L&
END SUB

SUB Display_Player_Status (L&)
    Draw_Window 10, 6, 19, 21, L&
    _PRINTSTRING (16 * 16, 16 * 7), "NAME:" + RTRIM$(P.Nam), L&
    _PRINTSTRING (16 * 17, 16 * 9), "STRENGTH:", L&
    _PRINTSTRING (16 * 18, 16 * 11), "AGILITY:", L&
    _PRINTSTRING (16 * 15, 16 * 13), "MAXIMUM HP:", L&
    _PRINTSTRING (16 * 15, 16 * 15), "MAXIMUM MP:", L&
    _PRINTSTRING (16 * 13, 16 * 17), "ATTACK POWER:", L&
    _PRINTSTRING (16 * 12, 16 * 19), "DEFENSE POWER:", L&
    _PRINTSTRING (16 * 13, 16 * 21), "WEAPON:", L&
    _PRINTSTRING (16 * 14, 16 * 23), "ARMOR:", L&
    _PRINTSTRING (16 * 13, 16 * 25), "SHIELD:", L&
    V1$ = LTRIM$(STR$(P.Strength))
    _PRINTSTRING (16 * (26 + (3 - LEN(V1$))), 16 * 9), V1$, L&
    V1$ = LTRIM$(STR$(P.Agility))
    _PRINTSTRING (16 * (26 + (3 - LEN(V1$))), 16 * 11), V1$, L&
    Test% = P.Max_HP - P.HP_Mod
    IF Test% < 0 THEN
        V1$ = "1"
    ELSE
        V1$ = LTRIM$(STR$(P.Max_HP - P.HP_Mod))
    END IF
    _PRINTSTRING (16 * (26 + (3 - LEN(V1$))), 16 * 13), V1$, L&
    V1$ = LTRIM$(STR$(P.Max_MP))
    _PRINTSTRING (16 * (26 + (3 - LEN(V1$))), 16 * 15), V1$, L&
    V1$ = LTRIM$(STR$(Player_AttackStrength))
    _PRINTSTRING (16 * (26 + (3 - LEN(V1$))), 16 * 17), V1$, L&
    V1$ = LTRIM$(STR$(Player_DefenceStrength))
    _PRINTSTRING (16 * (26 + (3 - LEN(V1$))), 16 * 19), V1$, L&

    IF LEN(RTRIM$(I(P.Weapon).Nam)) < 9 THEN
        V1$ = RTRIM$(I(P.Weapon).Nam)
        _PRINTSTRING (16 * (20), 16 * 21), V1$, L&
    ELSE
        V1$ = MID$(I(P.Weapon).Nam, 1, INSTR(I(P.Weapon).Nam, CHR$(32)))
        _PRINTSTRING (16 * (20), 16 * 21), V1$, L&
        V2$ = RTRIM$(MID$(I(P.Weapon).Nam, INSTR(I(P.Weapon).Nam, CHR$(32))))
        _PRINTSTRING (16 * (20), 16 * 22), V2$, L&
    END IF

    IF LEN(RTRIM$(I(P.Armor).Nam)) < 9 THEN
        V1$ = RTRIM$(I(P.Armor).Nam)
        _PRINTSTRING (16 * (20), 16 * 23), V1$, L&
    ELSE
        V1$ = MID$(I(P.Armor).Nam, 1, INSTR(I(P.Armor).Nam, CHR$(32)))
        _PRINTSTRING (16 * (20), 16 * 23), V1$, L&
        V2$ = RTRIM$(MID$(I(P.Armor).Nam, INSTR(I(P.Armor).Nam, CHR$(32))))
        _PRINTSTRING (16 * (20), 16 * 24), V2$, L&
    END IF

    IF LEN(RTRIM$(I(P.Shield).Nam)) < 9 THEN
        V1$ = RTRIM$(I(P.Shield).Nam)
        _PRINTSTRING (16 * (20), 16 * 25), V1$, L&
    ELSE
        V1$ = MID$(I(P.Shield).Nam, 1, INSTR(I(P.Shield).Nam, CHR$(32)))
        _PRINTSTRING (16 * (20), 16 * 25), V1$, L&
        V2$ = RTRIM$(MID$(I(P.Shield).Nam, INSTR(I(P.Shield).Nam, CHR$(32))))
        _PRINTSTRING (16 * (20), 16 * 26), V2$, L&
    END IF

END SUB

SUB Death_Return
    Reset_Message_Layer
    P.Gold = P.Gold \ 2
    F.Defeated_In_Battle = TRUE
    P.Facing = UP
    P.HP = P.Max_HP
    P.MP = P.Max_MP
    P.Map = 1
    P.MapX = 17
    P.MapY = 18
    P.WorldX = 44
    P.WorldY = 44
    Build_Place_Layer Layer(7), P.Map
    Change_BGM
END SUB
SUB Draw_Command_Window (L&)
    Draw_Window 12, 2, 15, 9, Layer(1)
    _PUTIMAGE (16 * 16 - 2, 2 * 16)-STEP(7 * 15 + 4, 1 * 15), Layer(3), L&, (205, 35)-STEP(15, 15)
    _PRINTSTRING (16 * 16, 16 * 2), "COMMAND", L&
    _PRINTSTRING (16 * 14, 16 * 4), "TALK", L&
    _PRINTSTRING (16 * 14, 16 * 6), "STATUS", L&
    _PRINTSTRING (16 * 14, 16 * 8), "STAIRS", L&
    _PRINTSTRING (16 * 14, 16 * 10), "SEARCH", L&
    _PRINTSTRING (16 * 22, 16 * 4), "SPELL", L&
    _PRINTSTRING (16 * 22, 16 * 6), "ITEM", L&
    _PRINTSTRING (16 * 22, 16 * 8), "DOOR", L&
    _PRINTSTRING (16 * 22, 16 * 10), "TAKE", L&
END SUB

SUB Draw_Battle_Command_Window (L&)
    Draw_Window 12, 2, 15, 5, Layer(1)
    _PUTIMAGE (16 * 16 - 2, 2 * 16)-STEP(7 * 15 + 4, 1 * 15), Layer(3), L&, (205, 35)-STEP(15, 15)
    _PRINTSTRING (16 * 16, 16 * 2), "COMMAND", L&
    _PRINTSTRING (16 * 14, 16 * 4), "FIGHT", L&
    _PRINTSTRING (16 * 14, 16 * 6), "RUN", L&
    _PRINTSTRING (16 * 22, 16 * 4), "SPELL", L&
    _PRINTSTRING (16 * 22, 16 * 6), "ITEM", L&
END SUB

FUNCTION Yes_NO_Box%% (X%%, Y%%, L&)
    Result%% = FALSE
    selection%% = 1
    _PUTIMAGE , Layer(1), Layer(5) 'back up screen
    DO
        _PUTIMAGE , Layer(5), L&
        Draw_Window X%%, Y%%, 7, 5, L&
        _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 2)), "YES", L&
        _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 4)), "NO", L&
        IF Frame%% THEN Display_Selection_Arrow X%% + 1, Y%% + (selection%% * 2), L&
        _PUTIMAGE , L&, Layer(0)

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE UP
                selection%% = selection%% - 1
                IF selection%% = 0 THEN selection%% = 1
            CASE DOWN
                selection%% = selection%% + 1
                IF selection%% = 3 THEN selection%% = 2
            CASE BUTTON_A
                ExitFlag%% = TRUE
                IF selection%% = 1 THEN Result%% = TRUE
            CASE BUTTON_B
                ExitFlag%% = TRUE
        END SELECT
        DO: LOOP WHILE Get_Input >= 0

        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    _PUTIMAGE , Layer(5), Layer(1) 'restore screen
    Yes_NO_Box = Result%%
END FUNCTION

FUNCTION Buy_Sell_Box%% (X%%, Y%%, L&)
    Result%% = FALSE
    selection%% = 1
    _PUTIMAGE , Layer(1), Layer(5) 'back up screen
    DO
        _PUTIMAGE , Layer(5), L&
        Draw_Window X%%, Y%%, 7, 5, L&
        _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 2)), "BUY", L&
        _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 4)), "SELL", L&
        IF Frame%% THEN Display_Selection_Arrow X%% + 1, Y%% + (selection%% * 2), L&
        _PUTIMAGE , L&, Layer(0)
        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE UP
                selection%% = selection%% - 1
                IF selection%% = 0 THEN selection%% = 1
            CASE DOWN
                selection%% = selection%% + 1
                IF selection%% = 3 THEN selection%% = 2
            CASE BUTTON_A
                ExitFlag%% = TRUE
                IF selection%% = 1 THEN Result%% = TRUE
            CASE BUTTON_B
                ExitFlag%% = TRUE
        END SELECT

        DO: LOOP WHILE Get_Input >= 0

        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    _PUTIMAGE , Layer(5), Layer(1) 'restore screen
    Buy_Sell_Box = Result%%
END FUNCTION
FUNCTION Command_Window%% (L&)
    Result%% = FALSE
    Selection%% = 1

    DO
        Draw_Command_Window L&
        Draw_Stat_Window L&
        Display_Selection_Arrow SA(Selection%%).X, SA(Selection%%).Y, L&
        SELECT CASE Get_Input
            CASE UP
                IF Selection%% > 1 AND Selection%% <> 5 THEN Selection%% = Selection%% - 1
            CASE DOWN
                IF Selection%% < 8 AND Selection%% <> 4 THEN Selection%% = Selection%% + 1
            CASE LEFT
                IF Selection%% > 4 THEN Selection%% = Selection%% - 4
            CASE RIGHT
                IF Selection%% < 5 THEN Selection%% = Selection%% + 4
            CASE BUTTON_B
                ExitFlag%% = TRUE
            CASE BUTTON_A
                Result%% = Selection%%: ExitFlag%% = TRUE: _SNDPLAY SFX(15)
        END SELECT

        DO: LOOP WHILE Get_Input >= 0

        _PUTIMAGE , L&, Layer(0)
        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    Command_Window = Result%%
END FUNCTION

FUNCTION Battle_Command_Window%% (L&)
    Result%% = 0
    Selection%% = 1
    DO
        Draw_Battle_Command_Window L&
        Display_Selection_Arrow BSA(Selection%%).X, BSA(Selection%%).Y, L&

        SELECT CASE Get_Input
            CASE UP
                IF Selection%% > 1 OR Selection%% > 3 THEN Selection%% = Selection%% - 1
            CASE DOWN
                IF Selection%% < 2 OR Selection%% < 4 THEN Selection%% = Selection%% + 1
            CASE LEFT
                IF Selection%% > 2 THEN Selection%% = Selection%% - 2
            CASE RIGHT
                IF Selection%% < 3 THEN Selection%% = Selection%% + 2
            CASE BUTTON_B
                ExitFlag%% = TRUE
            CASE BUTTON_A
                Result%% = Selection%%: ExitFlag%% = TRUE: _SNDPLAY SFX(15)
        END SELECT

        DO: LOOP WHILE Get_Input >= 0

        _PUTIMAGE , L&, Layer(0)
        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    Battle_Command_Window = Result%%
END FUNCTION

SUB Run_Search (ID%%)
    SELECT CASE (ID%%)
        CASE 1 'edricks token
            G.ItemID = 39
            Result%% = Message_Handler(Layer(15), 343) 'found the token
            P.Has_Token = TRUE
            Add_To_Inventory 39, 1
        CASE 2 'golem fight
        CASE 3 'Dragon fight before getting to princess
        CASE 4 'Fairies' Flute
            G.ItemID = 28
            Result%% = Message_Handler(Layer(15), 343) 'found the flute
            P.Has_Flute = TRUE
            Add_To_Inventory 28, 1
        CASE 5 'hidden stair case
            G.ItemID = 40 'hidden stair ID
            IF NOT F.Found_Hidden_Stair THEN
                Result%% = Message_Handler(Layer(15), 343) 'found the hidden passage!
                F.Found_Hidden_Stair = TRUE
                Place(7, 23, 12).Sprite_ID = 8 'update the map
                _PUTIMAGE (0 + 32 * 23, 0 + 32 * 12)-STEP(31, 31), Layer(3), Layer(7), (1 + 17 * Place(ID%%, X%%, Y%%).Sprite_ID, 1)-STEP(15, 15)
            END IF
        CASE 6 'Feels wind behind stair case clue
            Result%% = Message_Handler(Layer(15), 344) 'feels wind behind throne
        CASE 7 TO 47 'player finds a chest(which can be seen anyway, but it still says you found one!)
            Result%% = Message_Handler(Layer(15), 342) 'found a chest
        CASE 99 'Erdrik's armor
            G.ItemID = 15
            Result%% = Message_Handler(Layer(15), 343) 'found the flute
            P.Armor = 15 'put on Erdricks armor, droping what ever armor player had
            Place(P.Map, P.MapX, P.MapY).Has_Special = 0
    END SELECT
END SUB

FUNCTION Is_Door%%
    Result%% = TRUE 'set result -1 cause door array starts at 0 to Door_Count-1
    SELECT CASE P.Facing 'adjust position to open door in adjacent tile from player
        CASE UP
            Offy%% = -1
        CASE DOWN
            Offy%% = 1
        CASE LEFT
            Offx%% = -1
        CASE RIGHT
            Offx%% = 1
    END SELECT
    FOR i%% = 0 TO DOOR_COUNT - 1 'see if there is a door in that location
        IF Doors(i%%).Map = P.Map THEN
            IF Doors(i%%).X = P.MapX + Offx%% AND Doors(i%%).Y = P.MapY + Offy%% THEN
                IF Doors(i%%).Opened = FALSE THEN 'don't reopen door
                    Result%% = i%%: i%% = 33 'a door has been found!
                END IF
            END IF
        END IF
    NEXT i%%
    Is_Door = Result%%
END FUNCTION

FUNCTION Run_Take%%
    Result%% = TRUE
    FOR i%% = 0 TO 34
        IF Chest(i%%).Map = P.Map THEN 'is this chest on same map as player
            IF Chest(i%%).X = P.MapX AND Chest(i%%).Y = P.MapY THEN 'is player standing on chest
                IF Chest(i%%).Opened = FALSE THEN 'has player already opened this chest
                    Result%% = i%%: i%% = 64
                END IF
            END IF
        END IF
    NEXT i%%
    Run_Take = Result%%
END FUNCTION


SUB Take_Chest (ID%%, Valu%)
    SELECT CASE ID%%
        CASE 7 'Erdrick's Sword
            IF P.Weapon = 7 THEN
                Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have Erdrick's Sword
            ELSE
                G.ItemID = 7
                Result%% = Message_Handler(Layer(15), 324) '
                P.Weapon = 7 'give player Erdrick's Sword, dropping what player already has.
            END IF
        CASE 27 'edrick's tablet
            G.ItemID = 27
            Result%% = Message_Handler(Layer(15), 324) '
            Use_Item 27
        CASE 62 'Death Necklace or 120gp
            IF F.Found_DeathNecklace = FALSE AND INT(RND * 18) = 13 THEN 'player gets Death necklace
                G.ItemID = 33: ID%% = 33
                Result%% = Message_Handler(Layer(15), 324) '
                F.Found_DeathNecklace = TRUE
                IF ID%% > 0 THEN
                    IF P.Items < 8 THEN 'if room for more then add it, do NOT add keys or herbs HERE
                        Add_To_Inventory ID%%, 1
                    ELSE 'players inventory is full
                        Result%% = Message_Handler(Layer(15), 336) 'chest is empty if you have too many herbs
                        IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player want to drop an item
                            Result%% = Message_Handler(Layer(15), 338) 'player chooses to drop an item
                            temp%% = G.ItemID
                            G.ItemID = Run_Item(18, 6, Layer(1))
                            Result%% = Message_Handler(Layer(15), 339) 'player choosen item to drop
                            Drop_Inventory G.ItemID
                            G.ItemID = temp%% 'restore item from chest
                            Add_To_Inventory ID%%, 1
                            Result%% = Message_Handler(Layer(15), 340) 'player picks up item
                        ELSE
                            Result%% = Message_Handler(Layer(15), 337) 'player chooses not to take item from chest
                        END IF
                    END IF
                END IF
            ELSE 'player gets 120gp
                G.Price = 120 'how much gold does player get
                P.Gold = P.Gold + G.Price
                Result%% = Message_Handler(Layer(15), 335) '
            END IF
        CASE 63 ' random gold (1\2 Valu to Valu)
            G.Price = INT(RND * (Valu% \ 2)) + (Valu% \ 2) 'how much gold does player get
            P.Gold = P.Gold + G.Price
            Result%% = Message_Handler(Layer(15), 335) '
        CASE 64 'fixed amount of gold
            G.Price = Valu%
            P.Gold = P.Gold + G.Price
            Result%% = Message_Handler(Layer(15), 335) '
        CASE ELSE 'normal items found
            G.ItemID = ID%%

            IF ID%% = 22 THEN 'is player getting an Herb?
                IF P.Herbs < 6 THEN
                    Result%% = Message_Handler(Layer(15), 324) '
                    Add_To_Inventory ID%%, 1
                ELSE
                    Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have too many herbs
                END IF

            ELSEIF ID%% = 26 THEN 'or is player getting a Magic Key
                IF P.Keys < 6 THEN
                    Result%% = Message_Handler(Layer(15), 324) '
                    Add_To_Inventory ID%%, 1
                ELSE
                    Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have too many keys
                END IF

                'Check Set Flags For Special Items(can only get once)
            ELSEIF ID%% = 36 AND P.Has_Stones THEN 'if player has already take then Stones of Sunlight
                Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have taken the Stones Already
            ELSEIF ID%% = 30 AND P.Has_Harp THEN
                Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have taken the harp Already
            ELSEIF ID%% = 34 AND P.Has_Staff THEN
                Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have taken the staff Already
            ELSEIF ID%% = 35 AND P.Has_Drop THEN
                Result%% = Message_Handler(Layer(15), 325) 'chest is empty if you have taken the Drop Already
                '----------------------------------------------------

            ELSE 'player must be getting something else.
                Result%% = Message_Handler(Layer(15), 324) '
                'Set special flags when Key items are found
                IF ID%% = 36 THEN P.Has_Stones = TRUE
                IF ID%% = 30 THEN P.Has_Harp = TRUE
                IF ID%% = 34 THEN P.Has_Staff = TRUE
                IF ID%% = 35 THEN P.Has_Drop = TRUE
                '------------------------------------------
                IF ID%% > 0 THEN
                    IF P.Items < 8 THEN 'if room for more then add it, do NOT add keys or herbs HERE
                        Add_To_Inventory ID%%, 1
                    ELSE 'players inventory is full
                        Result%% = Message_Handler(Layer(15), 336) 'chest is empty if you have too many herbs
                        IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player want to drop an item
                            Result%% = Message_Handler(Layer(15), 338) 'player chooses to drop an item
                            temp%% = G.ItemID
                            G.ItemID = Run_Item(18, 6, Layer(1))
                            Result%% = Message_Handler(Layer(15), 339) 'player choosen item to drop
                            Drop_Inventory G.ItemID
                            G.ItemID = temp%% 'restore item from chest
                            Add_To_Inventory ID%%, 1
                            Result%% = Message_Handler(Layer(15), 340) 'player picks up item
                        ELSE
                            Result%% = Message_Handler(Layer(15), 337) 'player chooses not to take item from chest
                        END IF
                    END IF
                END IF
            END IF
    END SELECT
END SUB

FUNCTION Count_Spells%%
    Result%% = FALSE
    FOR i%% = 0 TO 11
        IF _READBIT(P.Spells, i%%) THEN Result%% = Result%% + 1
    NEXT i%%
    Count_Spells = Result%%
END FUNCTION

FUNCTION Run_Spell%% (X%%, Y%%, L&)
    Result%% = FALSE
    Selection%% = 1
    _PUTIMAGE , Layer(1), Layer(5)
    Count%% = Count_Spells
    DO
        _PUTIMAGE , Layer(5), L&
        Draw_Window X%%, Y%%, 11, Count%% * 2 + 1, L&
        _PRINTSTRING (16 * (X%% + 3), 16 * Y%%), "SPELL", L&

        FOR j%% = 1 TO Count%%
            V1$ = RTRIM$(Spells(j%%))
            _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + ((j%%) * 2))), V1$, L&
        NEXT j%%

        IF Frame%% THEN Display_Selection_Arrow X%% + 1, Y%% + 2 + ((Selection%% - 1) * 2), L&
        _PUTIMAGE , L&, Layer(0)

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE UP
                Selection%% = Selection%% - 1
                IF Selection%% = 0 THEN Selection%% = 1
            CASE DOWN
                Selection%% = Selection%% + 1
                IF Selection%% = Count%% + 1 THEN Selection%% = Count%%
            CASE BUTTON_A
                ExitFlag%% = TRUE
                Result%% = Selection%%: _SNDPLAY SFX(15)
            CASE BUTTON_B
                ExitFlag%% = TRUE
                '     Result%% = TRUE 'exit spell routine
        END SELECT

        DO: LOOP WHILE Get_Input >= 0

        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    Run_Spell = Result%%
END FUNCTION

SUB Run_Stairs
    IF P.Map >= 0 THEN
        IF Place(P.Map, P.MapX, P.MapY).Is_Stairs THEN
            IF NOT F.Has_Left_Throne_Room THEN 'if player has just started game
                F.Has_Left_Throne_Room = TRUE
                Doors(0).Opened = TRUE 'door to throne room stays opened
                Chest(0).Opened = TRUE 'the three chests in throne room do not respawn
                Chest(1).Opened = TRUE
                Chest(2).Opened = TRUE
            END IF

            Fade_Out Layer(1)
            _SNDPLAY SFX(2) 'stair sound effect

            P.Map = Stairs(Place(P.Map, P.MapX, P.MapY).Is_Stairs).Link
            'get location information from the linked stair Record.
            P.MapX = Stairs(P.Map).X
            P.MapY = Stairs(P.Map).Y
            IF Stairs(P.Map).Map = -1 THEN
                P.WorldX = Stairs(P.Map).X: P.WorldY = Stairs(P.Map).Y
                P.Torched = FALSE 'torch and radiant go out when you enter overworld
                P.Radiant = FALSE
                Reset_Chests: Reset_Doors
            END IF
            P.Map = Stairs(P.Map).Map

            IF P.Map >= 0 THEN Build_Place_Layer Layer(7), P.Map
            IF PD(P.Map).Is_Lit = FALSE THEN 'Deal with lighting issues
                Create_Light_Mask 'turn lights out!
            ELSE
                Remove_light_mask 'turn light back on but
                P.Torched = FALSE 'turn radiant and
                P.Radiant = 0 '    torch off
            END IF

            Build_Screen
            Fade_In Layer(1)

            Change_BGM
            G.Menu = FALSE
        ELSE
            Result%% = Message_Handler(Layer(15), 0) 'no stairs here message
        END IF
    ELSE
        IF World(P.WorldX, P.WorldY).Is_Stairs THEN
            _SNDPLAY SFX(2) 'stair sound effect
            Fade_Out Layer(1)
            P.Map = Stairs(World(P.WorldX, P.WorldY).Is_Stairs).Link
            'get location information from the linked stair Record.
            P.MapX = Stairs(P.Map).X
            P.MapY = Stairs(P.Map).Y
            P.Map = Stairs(P.Map).Map

            IF P.Map >= 0 THEN Build_Place_Layer Layer(7), P.Map
            IF PD(P.Map).Is_Lit = FALSE THEN Create_Light_Mask ELSE Remove_light_mask: P.Radiant = 0

            G.Menu = FALSE
            Build_Screen
            Fade_In Layer(1)

            Change_BGM
            '   Reset_Chests
        ELSE
            Result%% = Message_Handler(Layer(15), 0) 'no stairs here message
        END IF
    END IF
END SUB

FUNCTION Cast_Spell%% (ID%%)
    Result%% = FALSE
    G.Cast = ID%%
    IF G.Battle >= 0 THEN In_Battle = TRUE ELSE In_Battle = FALSE
    SELECT CASE ID%%
        CASE 0 'player cancelled spell use
            Result%% = -2
        CASE 1 'Heal 7-18hp
            IF P.MP >= 4 THEN 'does player have enough MP to cast spell
                Result%% = Message_Handler(Layer(15), 328) '
                _SNDPLAY SFX(18)
                Screen_Flash
                P.MP = P.MP - 4
                P.HP = P.HP + INT(RND * 11) + 7
                IF P.HP > P.Max_HP THEN P.HP = P.Max_HP
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 2 'hurt 5-12hp
            IF P.MP >= 2 THEN 'does player have enough MP to cast spell
                Null%% = Message_Handler(Layer(15), 328) '
                IF In_Battle THEN 'a battle spell only works during battle
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    P.MP = P.MP - 2
                    damage%% = INT(RND * 7) + 5
                    Result%% = damage%%
                    IF Dodge(16, M(G.Battle).HurtResist) THEN Result%% = 0
                ELSE 'not in a battle
                    Null%% = Message_Handler(Layer(15), 327) '
                END IF
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 3 'sleep 2
            IF P.MP >= 2 THEN 'does player have enough MP to cast spell
                Null%% = Message_Handler(Layer(15), 328) '
                IF In_Battle THEN 'a battle spell only works during battle
                    P.MP = P.MP - 2
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    IF Dodge(16, M(G.Battle).SlpResist) THEN Result%% = 0 ELSE Result%% = -3: M(G.Battle).Is_Asleep = TRUE
                ELSE 'not in a battle
                    Null%% = Message_Handler(Layer(15), 327) '
                END IF
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 4 'radiant 3
            IF In_Battle THEN 'a battle spell only works during battle
                Null%% = Message_Handler(Layer(15), 358) '
            ELSE
                IF P.MP >= 3 THEN 'does player have enough MP to cast spell
                    Null%% = Message_Handler(Layer(15), 328) '
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    P.MP = P.MP - 3
                    P.Radiant = 200
                    Create_Light_Mask
                ELSE 'not enough MP to cast
                    Null%% = Message_Handler(Layer(15), 345) '
                END IF
            END IF
        CASE 5 'stopspell 2
            IF P.MP >= 2 THEN 'does player have enough MP to cast spell
                Null%% = Message_Handler(Layer(15), 328) '
                IF In_Battle THEN 'a battle spell only works during battle
                    P.MP = P.MP - 2
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    IF Dodge(16, M(G.Battle).StpSplResist) THEN Result%% = 0 ELSE Result%% = -4: M(G.Battle).Is_Blocked = TRUE
                ELSE 'not in a battle
                    Null%% = Message_Handler(Layer(15), 327) '
                END IF
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 6 'outside 6
            IF In_Battle THEN 'a battle spell only works during battle
                Null%% = Message_Handler(Layer(15), 358) '
            ELSE
                IF P.MP >= 6 THEN 'does player have enough MP to cast spell
                    Null%% = Message_Handler(Layer(15), 328) '
                    SELECT CASE P.Map
                        CASE 7 TO 12, 15 TO 22 'Exit a cave or unsafe town\castle
                            _SNDPLAY SFX(18)
                            Screen_Flash
                            P.MP = P.MP - 6
                            Fade_Out Layer(1)
                            P.Map = -1: G.JustLeft = TRUE
                            P.Radiant = 0 'turn out the lights
                            P.Torched = FALSE '""
                            Build_Screen
                            Fade_In Layer(1)
                            Change_BGM: Reset_Chests: Reset_Doors
                        CASE ELSE 'player is not in the overworld or a safe town.
                            Null%% = Message_Handler(Layer(15), 327) '
                    END SELECT
                ELSE 'not enough MP to cast
                    Null%% = Message_Handler(Layer(15), 345) '
                END IF
            END IF
        CASE 7 'return 8
            IF In_Battle THEN 'a battle spell only works during battle
                Null%% = Message_Handler(Layer(15), 358) '
            ELSE
                IF P.MP >= 8 THEN 'does player have enough MP to cast spell
                    Null%% = Message_Handler(Layer(15), 328) '
                    SELECT CASE P.Map
                        CASE -1 TO 6, 13, 14, 19, 20, 25, 26 'return to Tantegel castle from over world and towns
                            P.MP = P.MP - 8
                            P.WorldX = 43: P.WorldY = 44 'move player next to Tantegel Castle
                            Screen_Flash
                            _SNDPLAY SFX(19)
                            Fade_Out Layer(1)
                            DO: _LIMIT 10: LOOP WHILE _SNDPLAYING(SFX(19))
                            Build_Screen
                            Fade_In Layer(1)
                            Change_BGM: Reset_Chests: Reset_Doors
                        CASE ELSE 'player is not in the overworld or a safe town.
                            Null%% = Message_Handler(Layer(15), 327) '
                    END SELECT
                ELSE 'not enough MP to cast
                    Null%% = Message_Handler(Layer(15), 345) '
                END IF
            END IF
        CASE 8 'repel 2
            IF In_Battle THEN 'a battle spell only works during battle
                Null%% = Message_Handler(Layer(15), 358) '
            ELSE
                IF P.MP >= 2 THEN 'does player have enough MP to cast spell
                    Null%% = Message_Handler(Layer(15), 328) '
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    P.MP = P.MP - 2
                    P.Is_Repel = 127
                ELSE 'not enough MP to cast
                    Null%% = Message_Handler(Layer(15), 345) '
                END IF
            END IF
        CASE 9 'healmore 70-110hp 10
            IF P.MP >= 10 THEN 'does player have enough MP to cast spell
                Result%% = Message_Handler(Layer(15), 328) '
                _SNDPLAY SFX(18)
                Screen_Flash
                P.MP = P.MP - 10
                P.HP = P.HP + INT(RND * 25) + 75
                IF P.HP > P.Max_HP THEN P.HP = P.Max_HP
            ELSE 'not enough MP to cast
                Result%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 10 'hurtmore 58-65hp  5
            IF P.MP >= 5 THEN 'does player have enough MP to cast spell
                IF In_Battle THEN 'a battle spell only works during battle
                    Null%% = Message_Handler(Layer(15), 328) '
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    P.MP = P.MP - 5
                    damage%% = INT(RND * 58) + 7
                    Result%% = damage%%
                    IF Dodge(16, M(G.Battle).HurtResist) THEN Result%% = 0
                ELSE 'not in a battle
                    Null%% = Message_Handler(Layer(15), 327) '
                END IF
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 11 'strengthen 25
            IF P.MP >= 25 THEN 'does player have enough MP to cast spell
                Null%% = Message_Handler(Layer(15), 328) '
                IF In_Battle THEN 'a battle spell only works during battle
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    P.MP = P.MP - 25
                    Null%% = Message_Handler(Layer(15), 389) '
                    G.Attack_Bonus = TRUE
                ELSE 'not in a battle
                    Null%% = Message_Handler(Layer(15), 327) '
                END IF
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
        CASE 12 'quicken 30
            IF P.MP >= 30 THEN 'does player have enough MP to cast spell
                Null%% = Message_Handler(Layer(15), 328) '
                IF In_Battle THEN 'a battle spell only works during battle
                    _SNDPLAY SFX(18)
                    Screen_Flash
                    P.MP = P.MP - 30
                    Null%% = Message_Handler(Layer(15), 390) '
                    G.Defence_Bonus = TRUE
                ELSE 'not in a battle
                    Null%% = Message_Handler(Layer(15), 327) '
                END IF
            ELSE 'not enough MP to cast
                Null%% = Message_Handler(Layer(15), 345) '
            END IF
    END SELECT
    Cast_Spell = Result%%
END FUNCTION

SUB Process_Command (Opt%%, L&)
    Reset_Message_Layer
    IF Opt%% THEN
        _PUTIMAGE , L&, Layer(5)
        SELECT CASE Opt%%
            CASE 1 'talk
                IF G.TextClick THEN F.PlayClick = TRUE ELSE F.PlayClick = FALSE
                Test%% = Find_NPC
                IF Test%% < 120 THEN
                    'turn NPC to face player
                    IF NOT F.Dragon_King_Killed THEN
                        IF P.Facing = UP AND (NPC(Test%%).Facing <> DOWN) THEN NPC(Test%%).Facing = DOWN
                        IF P.Facing = RIGHT AND (NPC(Test%%).Facing <> LEFT) THEN NPC(Test%%).Facing = LEFT
                        IF P.Facing = DOWN AND (NPC(Test%%).Facing <> UP) THEN NPC(Test%%).Facing = UP
                        IF P.Facing = LEFT AND (NPC(Test%%).Facing <> RIGHT) THEN NPC(Test%%).Facing = RIGHT
                    END IF
                    Build_Screen
                    _PUTIMAGE , L&, Layer(5)
                    NPC_Talk Find_NPC
                ELSEIF Test%% = 120 THEN 'player is talking to princess in swamp cave prison
                    NPC_Talk 1
                    P.Has_Princess = TRUE
                ELSE
                    Result%% = Message_Handler(Layer(15), 1) 'No one there
                END IF
                IF F.PlayClick THEN F.PlayClick = FALSE
            CASE 2 'Status
                Display_Player_Status L&
                _PUTIMAGE , L&, Layer(0)
                DO: _LIMIT 60: LOOP UNTIL Get_Input = BUTTON_B OR Get_Input = BUTTON_A
            CASE 3 'Stairs
                Run_Stairs
            CASE 4 'search
                IF P.Map >= 0 THEN 'is player in a town\cave
                    T%% = Place(P.Map, P.MapX, P.MapY).Has_Special
                ELSE 'or in the overworld
                    T%% = World(P.WorldX, P.WorldY).Has_Special
                END IF

                IF T%% = 7 THEN 'if its a chest id then check the chest
                    IF Run_Take = TRUE THEN T%% = 0 'chest is already taken
                END IF

                IF T%% = 4 AND P.Has_Flute THEN T%% = 0 'if player already found flute then nothing to find
                IF T%% = 1 AND P.Has_Token THEN T%% = 0 'if player already found token then nothing to find

                IF T%% > 0 THEN
                    Result%% = Message_Handler(Layer(15), 341) 'found something
                    Run_Search T%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 2) 'found nothing message
                END IF
            CASE 5 'spell
                IF P.Spells THEN
                    Nul%% = Cast_Spell(Run_Spell(18, 3, Layer(1))) 'returns to nul if not in battle
                ELSE
                    Result%% = Message_Handler(Layer(15), 3) 'no spells yet
                END IF
                ExitFlag%% = TRUE
            CASE 6 'Items
                IF P.Items > 0 OR P.Herbs > 0 OR P.Keys > 0 THEN
                    Use_Item Run_Item(18, 6, Layer(1))
                    _PUTIMAGE , Layer(1), Layer(0)
                ELSE
                    Result%% = Message_Handler(Layer(15), 4) 'no items yet message
                END IF
            CASE 7 'Door
                Test%% = Is_Door
                IF Test%% >= 0 THEN
                    IF P.Keys > 0 THEN
                        Doors(Test%%).Opened = TRUE
                        _SNDPLAY SFX(14)
                        P.Keys = P.Keys - 1
                    ELSE
                        Result%% = Message_Handler(Layer(15), 334) 'you have no keys!
                    END IF
                ELSE
                    Result%% = Message_Handler(Layer(15), 5) 'no door here message
                END IF
            CASE 8 'take(chest)
                T%% = Run_Take%%
                IF T%% >= 0 THEN
                    _SNDPLAY SFX(13)
                    Take_Chest Chest(T%%).Treasure, Chest(T%%).Count
                    Chest(T%%).Opened = TRUE
                ELSE
                    Result%% = Message_Handler(Layer(15), 6) 'nothing to take message
                END IF
        END SELECT
    END IF
    _DELAY .125
    Reset_Message_Layer
END SUB

FUNCTION Player_Battle_Command%% (ID%%)
    Result%% = FALSE
    G.ExcelHit = FALSE
    DO
        null%% = Message_Handler(Layer(15), 349) 'Command
        SELECT CASE Battle_Command_Window(Layer(1))
            CASE 1 'attack
                Result%% = Player_Attack(ID%%)
                Exitflag%% = TRUE
            CASE 2 'run
                null%% = Message_Handler(Layer(15), 346) 'player attempts to flee
                IF Player_Flee(ID%%) THEN
                    Result%% = RANAWAY 'player managed to run away
                    _SNDPLAY SFX(1) 'run away sound effect
                ELSE
                    null%% = Message_Handler(Layer(15), 347) 'player was blocked
                END IF
                Exitflag%% = TRUE
            CASE 3 'Spell
                IF P.Spells THEN
                    Result%% = Player_Spell_Attack(ID%%)
                    IF Result%% <> -1 THEN Exitflag%% = TRUE
                    IF Result%% = -4 THEN Result%% = -6
                ELSE
                    Result%% = Message_Handler(Layer(15), 3) 'no spells yet
                END IF
            CASE 4 'item
                IF P.Items > 0 OR P.Herbs > 0 OR P.Keys > 0 THEN
                    Use_Item Run_Item(18, 6, Layer(1))
                    _PUTIMAGE , Layer(1), Layer(0)
                    Exitflag%% = TRUE
                ELSE
                    Result%% = Message_Handler(Layer(15), 4) 'no items yet message
                END IF
        END SELECT
    LOOP UNTIL Exitflag%% = TRUE 'run until player makes a valid choice
    Player_Battle_Command = Result%%
END FUNCTION

SUB NPC_Talk (ID%%)
    IF ID%% < 124 THEN Draw_Stat_Window Layer(1) 'display the stat window
    _PUTIMAGE , Layer(1), Layer(5)

    IF F.Dragon_King_Killed AND ID%% <> 124 THEN
        IF P.Map <> 0 THEN
            IF ID%% < 119 AND ID%% > 0 THEN ID%% = 122
            IF ID%% = 119 THEN ID%% = 391
        ELSE
            IF map = 0 THEN ID%% = 123 'everybody says these once DragonLord is defeated
        END IF
    END IF

    SELECT CASE ID%%
        CASE 0 'king

            IF F.Just_Started THEN 'if the game was just started\loaded

                IF F.Has_Left_Throne_Room = FALSE THEN 'if player has never left throne room then its a new game
                    Result%% = Message_Handler(Layer(15), 7) 'game intro message
                    F.Just_Started = FALSE
                ELSE
                    Result%% = Message_Handler(Layer(15), 13) 'restarted game message
                    F.Just_Started = FALSE
                END IF

            ELSEIF F.Has_Left_Throne_Room = FALSE THEN 'king finished speech but player hasn't used stairs yet.
                Result%% = Message_Handler(Layer(15), 14) 'havent left throne room yet

            ELSEIF P.Has_Princess THEN 'has saved princess
                Result%% = Message_Handler(Layer(15), 15) 'havent left throne room yet
                NPC_Talk 1
                P.Has_Princess = FALSE
                P.Princess_Saved = TRUE
                F.Saved_Princess = TRUE
                NPC_Talk 0

            ELSEIF F.Dragon_King_Killed THEN 'has beaten boss
                'This is now NPC_Talk 124

            ELSEIF F.Defeated_In_Battle THEN 'player was killed
                Result%% = Message_Handler(Layer(15), 314) 'after being defeated
                F.Defeated_In_Battle = FALSE
            ELSE
                Result%% = Message_Handler(Layer(15), 8) 'returned to king to save
                IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player want to save
                    Save_Game
                    Result%% = Message_Handler(Layer(15), 9) 'player saved
                ELSE
                    Result%% = Message_Handler(Layer(15), 10) 'does player want to keep playing?
                END IF
                IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player want to keep playing
                    Result%% = Message_Handler(Layer(15), 12) 'keeps playing
                ELSE
                    Result%% = Message_Handler(Layer(15), 11) 'quits
                    Quit_Game_Flag = TRUE
                END IF
            END IF
        CASE 1 'Princess
            IF P.Has_Princess THEN
                Result%% = Message_Handler(Layer(15), 21) 'returns princess to throne room
                Add_To_Inventory 38, 1 'Gwaelin's Love!
            ELSEIF P.Princess_Saved THEN
                IF G.PrincessFlag THEN 'has player already talked to princess after rescue?
                    Result%% = Message_Handler(Layer(15), 23) 'does player love princess?
                    DO
                        IF Yes_NO_Box(10, 5, Layer(1)) THEN '
                            Result%% = Message_Handler(Layer(15), 18) 'she is so happy!
                            ExitFlag%% = TRUE
                        ELSE
                            Result%% = Message_Handler(Layer(15), 307) 'no
                        END IF
                    LOOP UNTIL ExitFlag%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 22) '
                    G.PrincessFlag = TRUE
                END IF
            ELSEIF P.Has_Princess = FALSE AND P.Princess_Saved = FALSE THEN
                'ELSE
                Result%% = Message_Handler(Layer(15), 17) 'finds princess in cave
                DO
                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player take her back
                        Result%% = Message_Handler(Layer(15), 20) 'yes
                        _DELAY .33
                        Result%% = Message_Handler(Layer(15), 18) 'she is so happy!
                        ExitFlag%% = TRUE
                    ELSE
                        Result%% = Message_Handler(Layer(15), 19) 'no
                    END IF
                LOOP UNTIL ExitFlag%%
            END IF
        CASE 4 'Guard Roaming throne room
            IF P.Has_Princess OR P.Princess_Saved THEN
                Result%% = Message_Handler(Layer(15), 27) 'Pricess saved
            ELSE
                Result%% = Message_Handler(Layer(15), 24) 'just started
                IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player know about princess
                    Result%% = Message_Handler(Layer(15), 26) 'yes
                ELSE
                    Result%% = Message_Handler(Layer(15), 25) 'no, tell player
                END IF
            END IF
        CASE 3 'Left hand Gaurd throne room
            IF F.Has_Left_Throne_Room = FALSE THEN
                Result%% = Message_Handler(Layer(15), 28) '
            ELSE
                Result%% = Message_Handler(Layer(15), 29) '
            END IF
        CASE 2 'right hand gaurd throne room
            IF F.Has_Left_Throne_Room = FALSE THEN
                Result%% = Message_Handler(Layer(15), 30) '
            ELSE
                Result%% = Message_Handler(Layer(15), 31) '
            END IF
        CASE 5 'Gaurd Roaming North of Stairs
            Result%% = Message_Handler(Layer(15), 40) '
        CASE 6 'Key Sales Man
            G.Price = 85
            Result%% = Message_Handler(Layer(15), 49) '
            DO
                IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player know about princess
                    Result%% = Message_Handler(Layer(15), 51) 'yes
                    IF P.Keys < 6 THEN
                        IF P.Gold >= 85 THEN 'buys a key
                            P.Gold = P.Gold - 85
                            P.Keys = P.Keys + 1
                        ELSE
                            Result%% = Message_Handler(Layer(15), 52) 'Player has too little gold
                            ExitFlag%% = TRUE
                        END IF
                    ELSE
                        Result%% = Message_Handler(Layer(15), 53) 'Player has too many keys
                        ExitFlag%% = TRUE
                    END IF
                ELSE
                    Result%% = Message_Handler(Layer(15), 50) 'no,
                    ExitFlag%% = TRUE
                END IF
            LOOP UNTIL ExitFlag%%
            ExitFlag%% = FALSE
        CASE 7 'Girl by key store
            Result%% = Message_Handler(Layer(15), 42) '
        CASE 8 'Roaming Red Guard
            Result%% = Message_Handler(Layer(15), 41) '
        CASE 9 'Roaming Wizard right of stairs
            Result%% = Message_Handler(Layer(15), 44) '
        CASE 10 'Guard at damage floor room entrance
            Result%% = Message_Handler(Layer(15), 43) '
        CASE 11 'Red Guard in damage floor room
            Result%% = Message_Handler(Layer(15), 45) '
        CASE 12 'Guard north of stairs
            Result%% = Message_Handler(Layer(15), 32) '
        CASE 13 'Guard south of stairs
            Result%% = Message_Handler(Layer(15), 33) '
        CASE 14 'Boy in center
            Result%% = Message_Handler(Layer(15), 35) '
        CASE 15 'Girl above treasure room
            Result%% = Message_Handler(Layer(15), 39) '
        CASE 16 'guard in treasure room
            Result%% = Message_Handler(Layer(15), 38) '
        CASE 17 'girl in center area
            Result%% = Message_Handler(Layer(15), 34) '
        CASE 18 'merchant 1 bottom left
            Result%% = Message_Handler(Layer(15), 36) '
        CASE 19 'merchant 2 bottom left
            Result%% = Message_Handler(Layer(15), 37) '
        CASE 20 'Guard standing right of pool
            IF P.Princess_Saved THEN
                Result%% = Message_Handler(Layer(15), 48) '
            ELSE
                Result%% = Message_Handler(Layer(15), 47) '
            END IF
        CASE 21 'Guard Roaming right of pool
            Result%% = Message_Handler(Layer(15), 46) '
        CASE 22 'Wizard Bottom Right
            Result%% = Message_Handler(Layer(15), 54) 'restores players MP
            P.MP = P.Max_MP
            Screen_Flash
        CASE 23 'Guard Left of entrance
            Result%% = Message_Handler(Layer(15), 55) '
        CASE 24 'guard right of entrance
            Result%% = Message_Handler(Layer(15), 56) '
        CASE 25 'Wizard in castle cellar
            IF P.Has_Stones THEN
                Result%% = Message_Handler(Layer(15), 58) '
            ELSE
                Result%% = Message_Handler(Layer(15), 57) '
            END IF
            '������������������������������������End of Tantegel Castle NPCs������������������������������������
        CASE 26 'Red gaurd in top right corner
            Result%% = Message_Handler(Layer(15), 59) '
        CASE 27 'Armory shop keep
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) 'Hello this is the armory wish to buy?
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = FALSE: G.ItemID = TRUE
                    Result%% = Run_Shop(1, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) 'selected Item to buy
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it

                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold

                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 8 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 16 THEN Sell%% = 3: G.ItemID = P.Shield

                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE 'no need to sell anything
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 28 'woman standing in front of shop
            Result%% = Message_Handler(Layer(15), 68) '
        CASE 29 'boy at entrace of town
            Result%% = Message_Handler(Layer(15), 69) '
        CASE 30 'boy in room
            Result%% = Message_Handler(Layer(15), 70) '
        CASE 31 'wizard in room, removes curses
            IF P.Cursed THEN
                Result%% = Message_Handler(Layer(15), 72) '
            ELSE
                Result%% = Message_Handler(Layer(15), 71) '
            END IF
        CASE 32 'roaming merchant
            Result%% = Message_Handler(Layer(15), 73) '
        CASE 33 'guard to far right
            Result%% = Message_Handler(Layer(15), 74) '
        CASE 34 'Roaming red guard
            Result%% = Message_Handler(Layer(15), 75) '
        CASE 35 'roaming wizard
            Result%% = Message_Handler(Layer(15), 76) '
        CASE 36 'inn keep
            G.Price = 6
            Result%% = Message_Handler(Layer(15), 77) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to stay at the inn
                Result%% = Message_Handler(Layer(15), 79) '
                _SNDSTOP BGM(G.Current_BGM)
                Fade_Out Layer(1)
                _DELAY .10
                _SNDPLAY SFX(11)
                DO: LOOP WHILE _SNDPLAYING(SFX(11))
                IF P.Gold >= G.Price THEN
                    P.HP = P.Max_HP
                    P.MP = P.Max_MP
                    P.Gold = P.Gold - 6
                    _DELAY .33
                    Build_Screen
                    Fade_In Layer(1)
                    _SNDPLAY BGM(G.Current_BGM)
                    Result%% = Message_Handler(Layer(15), 80) '
                ELSE
                    Result%% = Message_Handler(Layer(15), 91) '
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 78) '
            END IF
        CASE 37 'Roaming Red guard in Inn
            Result%% = Message_Handler(Layer(15), 81) '
        CASE 38 'Guard in Inn
            Result%% = Message_Handler(Layer(15), 82) '
        CASE 39 'roaming boy
            Result%% = Message_Handler(Layer(15), 83) '
        CASE 40 'roaming girl
            Result%% = Message_Handler(Layer(15), 84) '
        CASE 41 'boy roaming across bridge
            Result%% = Message_Handler(Layer(15), 85) '
        CASE 42 'Boy standing across bridge
            Result%% = Message_Handler(Layer(15), 86) '
        CASE 43 'roaming Red guard
            Result%% = Message_Handler(Layer(15), 87) '
        CASE 44 'Girl selling fairy water
            G.Price = 38
            Result%% = Message_Handler(Layer(15), 88) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy fairy water
                DO
                    IF P.Gold >= 38 THEN 'player has enough gold
                        IF P.Items < 8 THEN 'player has room in pack
                            P.Gold = P.Gold - 38
                            Draw_Stat_Window Layer(5) 'update the stat window after purchase
                            Add_To_Inventory 25, 1 'add the item to players inventory
                            Result%% = Message_Handler(Layer(15), 90) '
                            IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                        ELSE 'player is out of room
                            Result%% = Message_Handler(Layer(15), 92) '
                            ExitFlag%% = TRUE
                        END IF
                    ELSE 'player lacks enough gold
                        Result%% = Message_Handler(Layer(15), 91) '
                        ExitFlag%% = TRUE
                    END IF
                LOOP UNTIL ExitFlag%%
            ELSE 'player says no
                Result%% = Message_Handler(Layer(15), 89) '
            END IF
        CASE 45 'Tool shop keep
            Result%% = Message_Handler(Layer(15), 93) '
            IF Buy_Sell_Box(10, 4, Layer(1)) THEN 'does player wish to buy
                '--------------player is buying items---------------------------------------
                Result%% = Message_Handler(Layer(15), 99) '
                DO
                    Item%% = Run_Shop(2, Layer(1))
                    G.ItemID = Item%%
                    IF Item%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        IF P.Gold > I(Item%%).Valu THEN 'dose player have the gold
                            IF P.Items < 8 AND Item%% <> 22 THEN 'does player have room or is player buying herbs

                                P.Gold = P.Gold - I(Item%%).Valu 'remove the cost from players purse
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                Add_To_Inventory Item%%, 1 'add the item to players inventory
                                Result%% = Message_Handler(Layer(15), 100) 'player buys item

                            ELSE 'players inventory is full or they are buying herbs

                                IF Item%% = 22 THEN 'if its a Herb then see if player has less than 6
                                    IF P.Herbs < 6 THEN 'can player hold more?
                                        P.Gold = P.Gold - I(Item%%).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        P.Herbs = P.Herbs + 1
                                        Result%% = Message_Handler(Layer(15), 100) 'player buys item
                                    ELSE 'player has too many herbs
                                        Result%% = Message_Handler(Layer(15), 102) '
                                    END IF
                                ELSE 'player has too many items
                                    Result%% = Message_Handler(Layer(15), 103) '
                                END IF
                            END IF

                        ELSE 'player hasn't the gold to buy
                            Result%% = Message_Handler(Layer(15), 101) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                    END IF
                LOOP UNTIL ExitFlag%%

            ELSE 'or is player going to sell
                '--------------------------Player is selling Items--------------------------------------
                IF P.Items OR P.Herbs OR P.Keys THEN
                    Result%% = Message_Handler(Layer(15), 94) '
                    DO
                        Item%% = Run_Item(18, 6, Layer(1))
                        IF Item%% < 0 THEN 'player canceled
                            ExitFlag%% = TRUE
                        ELSE
                            G.ItemID = Item%%
                            G.Price = INT(I(G.ItemID).Valu \ 2)
                            Result%% = Message_Handler(Layer(15), 96) '

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell
                                P.Gold = P.Gold + G.Price 'pay player
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase

                                IF G.ItemID = 22 THEN 'remove the item from players inventory
                                    P.Herbs = P.Herbs - 1
                                ELSEIF G.ItemID = 26 THEN
                                    P.Keys = P.Keys - 1
                                ELSE

                                    Drop_Inventory G.ItemID

                                END IF
                                Result%% = Message_Handler(Layer(15), 98) '
                            ELSE
                                Result%% = Message_Handler(Layer(15), 97) '
                            END IF

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell anything else
                                IF P.Items OR P.Herbs OR P.Keys THEN
                                    ExitFlag%% = FALSE
                                ELSE
                                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                                    ExitFlag%% = TRUE
                                END IF
                            ELSE
                                ExitFlag%% = TRUE
                            END IF
                        END IF
                    LOOP UNTIL ExitFlag%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                END IF
            END IF
            '������������������������������������End of Brecanary NPCs������������������������������������
        CASE 46 'roaming wizard by item shop
            Result%% = Message_Handler(Layer(15), 104) '
        CASE 47 'tool shop keep in Garinham
            Result%% = Message_Handler(Layer(15), 105) '
            IF Buy_Sell_Box(10, 4, Layer(1)) THEN 'does player wish to buy
                '--------------player is buying items---------------------------------------
                Result%% = Message_Handler(Layer(15), 99) '
                DO
                    Item%% = Run_Shop(3, Layer(1))
                    G.ItemID = Item%%
                    IF Item%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        IF P.Gold > I(Item%%).Valu THEN 'dose player have the gold
                            IF P.Items < 8 AND Item%% <> 22 THEN 'does player have room or is player buying herbs

                                P.Gold = P.Gold - I(Item%%).Valu 'remove the cost from players purse
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                Add_To_Inventory Item%%, 1 'add the item to players inventory
                                Result%% = Message_Handler(Layer(15), 100) 'player buys item

                            ELSE 'players inventory is full or they are buying herbs

                                IF Item%% = 22 THEN 'if its a Herb then see if player has less than 6
                                    IF P.Herbs < 6 THEN 'can player hold more?
                                        P.Gold = P.Gold - I(Item%%).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        P.Herbs = P.Herbs + 1
                                        Result%% = Message_Handler(Layer(15), 100) 'player buys item
                                    ELSE 'player has too many herbs
                                        Result%% = Message_Handler(Layer(15), 102) '
                                    END IF
                                ELSE 'player has too many items
                                    Result%% = Message_Handler(Layer(15), 103) '
                                END IF
                            END IF

                        ELSE 'player hasn't the gold to buy
                            Result%% = Message_Handler(Layer(15), 101) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                    END IF
                LOOP UNTIL ExitFlag%%

            ELSE 'or is player going to sell
                '--------------------------Player is selling Items--------------------------------------
                IF P.Items OR P.Herbs OR P.Keys THEN
                    Result%% = Message_Handler(Layer(15), 94) '
                    DO
                        Item%% = Run_Item(18, 6, Layer(1))
                        IF Item%% < 0 THEN 'player canceled
                            ExitFlag%% = TRUE
                        ELSE
                            G.ItemID = Item%%
                            G.Price = INT(I(G.ItemID).Valu \ 2)
                            Result%% = Message_Handler(Layer(15), 96) '

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell
                                P.Gold = P.Gold + G.Price 'pay player
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase

                                IF G.ItemID = 22 THEN 'remove the item from players inventory
                                    P.Herbs = P.Herbs - 1
                                ELSEIF G.ItemID = 26 THEN
                                    P.Keys = P.Keys - 1
                                ELSE

                                    Drop_Inventory G.ItemID

                                END IF
                                Result%% = Message_Handler(Layer(15), 98) '
                            ELSE
                                Result%% = Message_Handler(Layer(15), 97) '
                            END IF

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell anything else
                                IF P.Items OR P.Herbs OR P.Keys THEN
                                    ExitFlag%% = FALSE
                                ELSE
                                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                                    ExitFlag%% = TRUE
                                END IF
                            ELSE
                                ExitFlag%% = TRUE
                            END IF
                        END IF
                    LOOP UNTIL ExitFlag%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                END IF
            END IF
        CASE 48 'wizard south of entrance
            Result%% = Message_Handler(Layer(15), 116) '
        CASE 49 'Roaming Red Gaurd
            Result%% = Message_Handler(Layer(15), 117) '
        CASE 50 'Roaming girl
            Result%% = Message_Handler(Layer(15), 118) '
        CASE 51 'roaming boy
            Result%% = Message_Handler(Layer(15), 119) '
        CASE 52 'armory shop
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = Run_Shop(4, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) '
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it
                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold
                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 0 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 0 THEN Sell%% = 3: G.ItemID = P.Shield
                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 53 'inn keep
            G.Price = 25
            Result%% = Message_Handler(Layer(15), 77) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to stay at the inn
                IF P.Gold >= G.Price THEN
                    Result%% = Message_Handler(Layer(15), 79) '
                    P.HP = P.Max_HP
                    P.MP = P.Max_MP
                    P.Gold = P.Gold - 25
                    _DELAY .33
                    Result%% = Message_Handler(Layer(15), 80) '
                ELSE
                    Result%% = Message_Handler(Layer(15), 91) '
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 78) '
            END IF
        CASE 54 'Wizard by cave
            Result%% = Message_Handler(Layer(15), 132) '
        CASE 55 'left gaurd
            Result%% = Message_Handler(Layer(15), 133) '
        CASE 56 'right gaurd
            Result%% = Message_Handler(Layer(15), 134) '
        CASE 57 'roaming boy
            Result%% = Message_Handler(Layer(15), 135) '
        CASE 58 'merchant in middle
            Result%% = Message_Handler(Layer(15), 136) '
        CASE 59 'roaming Girl
            Result%% = Message_Handler(Layer(15), 137) '
        CASE 60 'Roaming wizard
            Result%% = Message_Handler(Layer(15), 138) '
            '������������������������������������End of Garinham  NPCs������������������������������������
        CASE 61 'wizard top left
            Result%% = Message_Handler(Layer(15), 139) '
        CASE 62 'girl by fountain
            Result%% = Message_Handler(Layer(15), 140) '
        CASE 63 'innkeep
            G.Price = 20
            Result%% = Message_Handler(Layer(15), 77) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to stay at the inn
                IF P.Gold >= G.Price THEN
                    Result%% = Message_Handler(Layer(15), 78) '
                    P.HP = P.Max_HP
                    P.MP = P.Max_MP
                    P.Gold = P.Gold - 20
                    _DELAY .33
                    Result%% = Message_Handler(Layer(15), 79) '
                ELSE
                    Result%% = Message_Handler(Layer(15), 91) '
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 80) '
            END IF
        CASE 64 'Roaming Red gaurd
            Result%% = Message_Handler(Layer(15), 145) '
        CASE 65 'Roaming Gaurd
            Result%% = Message_Handler(Layer(15), 146) '
        CASE 66 'roaming wizard
            Result%% = Message_Handler(Layer(15), 147) '
        CASE 67 'Wizard in room
            Result%% = Message_Handler(Layer(15), 148) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player
                Result%% = Message_Handler(Layer(15), 150) 'yes
            ELSE
                Result%% = Message_Handler(Layer(15), 149) 'no
            END IF
        CASE 68 'roaming boy behind door
            Result%% = Message_Handler(Layer(15), 151) '
        CASE 69 'armory shop keep
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = Run_Shop(5, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) '
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it
                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold
                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 0 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 0 THEN Sell%% = 3: G.ItemID = P.Shield
                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 70 'Red Gaurd at Armory
            Result%% = Message_Handler(Layer(15), 160) '
        CASE 71 'Roaming boy in courtyard
            Result%% = Message_Handler(Layer(15), 161) '
        CASE 72 'roaming girl in courtyard
            Result%% = Message_Handler(Layer(15), 162) '
        CASE 73 'Roaming merchant
            Result%% = Message_Handler(Layer(15), 163) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player
                Result%% = Message_Handler(Layer(15), 165) 'yes
            ELSE
                Result%% = Message_Handler(Layer(15), 164) 'no
            END IF
        CASE 74 'Wizard at entrace
            Result%% = Message_Handler(Layer(15), 166) '
        CASE 75 'tool shop
            Result%% = Message_Handler(Layer(15), 105) '
            IF Buy_Sell_Box(10, 4, Layer(1)) THEN 'does player wish to buy
                '--------------player is buying items---------------------------------------
                Result%% = Message_Handler(Layer(15), 99) '
                DO
                    Item%% = Run_Shop(6, Layer(1))
                    G.ItemID = Item%%
                    IF Item%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        IF P.Gold > I(Item%%).Valu THEN 'dose player have the gold
                            IF P.Items < 8 AND Item%% <> 22 THEN 'does player have room or is player buying herbs

                                P.Gold = P.Gold - I(Item%%).Valu 'remove the cost from players purse
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                Add_To_Inventory Item%%, 1 'add the item to players inventory
                                Result%% = Message_Handler(Layer(15), 100) 'player buys item

                            ELSE 'players inventory is full or they are buying herbs

                                IF Item%% = 22 THEN 'if its a Herb then see if player has less than 6
                                    IF P.Herbs < 6 THEN 'can player hold more?
                                        P.Gold = P.Gold - I(Item%%).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        P.Herbs = P.Herbs + 1
                                        Result%% = Message_Handler(Layer(15), 100) 'player buys item
                                    ELSE 'player has too many herbs
                                        Result%% = Message_Handler(Layer(15), 102) '
                                    END IF
                                ELSE 'player has too many items
                                    Result%% = Message_Handler(Layer(15), 103) '
                                END IF
                            END IF

                        ELSE 'player hasn't the gold to buy
                            Result%% = Message_Handler(Layer(15), 101) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                    END IF
                LOOP UNTIL ExitFlag%%

            ELSE 'or is player going to sell
                '--------------------------Player is selling Items--------------------------------------
                IF P.Items OR P.Herbs OR P.Keys THEN
                    Result%% = Message_Handler(Layer(15), 94) '
                    DO
                        Item%% = Run_Item(18, 6, Layer(1))
                        IF Item%% < 0 THEN 'player canceled
                            ExitFlag%% = TRUE
                        ELSE
                            G.ItemID = Item%%
                            G.Price = INT(I(G.ItemID).Valu \ 2)
                            Result%% = Message_Handler(Layer(15), 96) '

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell
                                P.Gold = P.Gold + G.Price 'pay player
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase

                                IF G.ItemID = 22 THEN 'remove the item from players inventory
                                    P.Herbs = P.Herbs - 1
                                ELSEIF G.ItemID = 26 THEN
                                    P.Keys = P.Keys - 1
                                ELSE

                                    Drop_Inventory G.ItemID

                                END IF
                                Result%% = Message_Handler(Layer(15), 98) '
                            ELSE
                                Result%% = Message_Handler(Layer(15), 97) '
                            END IF

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell anything else
                                IF P.Items OR P.Herbs OR P.Keys THEN
                                    ExitFlag%% = FALSE
                                ELSE
                                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                                    ExitFlag%% = TRUE
                                END IF
                            ELSE
                                ExitFlag%% = TRUE
                            END IF
                        END IF
                    LOOP UNTIL ExitFlag%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                END IF
            END IF
        CASE 76 'Gaurd bottom left town
            Result%% = Message_Handler(Layer(15), 178) '
            '����������������������������������---��End of Kol  NPCs----������������������������������������-
        CASE 77 'Boy in top right
            Result%% = Message_Handler(Layer(15), 179) '
        CASE 78 'merchant by key seller
            Result%% = Message_Handler(Layer(15), 180) '
        CASE 79 'armory shop keep
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = Run_Shop(7, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) '
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it
                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold
                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 0 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 0 THEN Sell%% = 3: G.ItemID = P.Shield
                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 80 'roaming boy in room
            Result%% = Message_Handler(Layer(15), 189) '
        CASE 81 'girl in room
            Result%% = Message_Handler(Layer(15), 190) '
        CASE 82 'roaming read gaurd in armory
            Result%% = Message_Handler(Layer(15), 191) '
        CASE 83 'Roaming boy
            Result%% = Message_Handler(Layer(15), 192) '
        CASE 84 'Wizard on island
            Result%% = Message_Handler(Layer(15), 193) '
        CASE 85 'roaming guard
            Result%% = Message_Handler(Layer(15), 194) '
        CASE 86 'roaming girl
            Result%% = Message_Handler(Layer(15), 195) '
        CASE 87 'inn keeper
            G.Price = 55
            Result%% = Message_Handler(Layer(15), 77) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to stay at the inn
                IF P.Gold >= G.Price THEN
                    Result%% = Message_Handler(Layer(15), 78) '
                    P.HP = P.Max_HP
                    P.MP = P.Max_MP
                    P.Gold = P.Gold - 55
                    _DELAY .33
                    Result%% = Message_Handler(Layer(15), 79) '
                ELSE
                    Result%% = Message_Handler(Layer(15), 91) '
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 80) '
            END IF
        CASE 88 'roaming red guard in INN
            Result%% = Message_Handler(Layer(15), 200) '
        CASE 89 'Wizard in INN
            Result%% = Message_Handler(Layer(15), 201) '
        CASE 90 'roaming Red gaurd
            Result%% = Message_Handler(Layer(15), 202) '
        CASE 91 'Girl south left town
            Result%% = Message_Handler(Layer(15), 203) '
        CASE 92 'Key Sales Man
            G.Price = 52
            Result%% = Message_Handler(Layer(15), 49) '
            DO
                IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player
                    Result%% = Message_Handler(Layer(15), 51) 'yes
                    IF P.Keys < 6 THEN
                        IF P.Gold >= G.Price THEN 'buys a key
                            P.Gold = P.Gold - G.Price
                            P.Keys = P.Keys + 1
                        ELSE
                            Result%% = Message_Handler(Layer(15), 52) 'Player has too little gold
                            ExitFlag%% = TRUE
                        END IF
                    ELSE
                        Result%% = Message_Handler(Layer(15), 53) 'Player has too many keys
                        ExitFlag%% = TRUE
                    END IF
                ELSE
                    Result%% = Message_Handler(Layer(15), 50) 'no,
                    ExitFlag%% = TRUE
                END IF
            LOOP UNTIL ExitFlag%%
            ExitFlag%% = FALSE
        CASE 93 'Wizard behind desk
            Result%% = Message_Handler(Layer(15), 209) '
            IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player
                Result%% = Message_Handler(Layer(15), 211) '
            ELSE
                Result%% = Message_Handler(Layer(15), 210) '
            END IF
        CASE 94 'roaming boy
            Result%% = Message_Handler(Layer(15), 212) '
        CASE 95 'roaming girl
            Result%% = Message_Handler(Layer(15), 213) '
        CASE 96 'roaming Red gaurd
            Result%% = Message_Handler(Layer(15), 214) '
            '����������������������������������-��End of Rimuldar NPCs--������������������������������������-
        CASE 97 'inn keeper
            G.Price = 100
            Result%% = Message_Handler(Layer(15), 77) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to stay at the inn
                IF P.Gold >= G.Price THEN
                    Result%% = Message_Handler(Layer(15), 78) '
                    P.HP = P.Max_HP
                    P.MP = P.Max_MP
                    P.Gold = P.Gold - 100
                    _DELAY .33
                    Result%% = Message_Handler(Layer(15), 79) '
                ELSE
                    Result%% = Message_Handler(Layer(15), 91) '
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 80) '
            END IF
        CASE 98 'Armory shopkeep
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = Run_Shop(8, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) '
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it
                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold
                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 0 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 0 THEN Sell%% = 3: G.ItemID = P.Shield
                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 99 'Roaming gaurd at entrance of town
            Result%% = Message_Handler(Layer(15), 227) '
        CASE 100 'Key Salesman
            G.Price = 98
            Result%% = Message_Handler(Layer(15), 49) '
            DO
                IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player
                    Result%% = Message_Handler(Layer(15), 51) 'yes
                    IF P.Keys < 6 THEN
                        IF P.Gold >= G.Price THEN 'buys a key
                            P.Gold = P.Gold - G.Price
                            P.Keys = P.Keys + 1
                        ELSE
                            Result%% = Message_Handler(Layer(15), 52) 'Player has too little gold
                            ExitFlag%% = TRUE
                        END IF
                    ELSE
                        Result%% = Message_Handler(Layer(15), 53) 'Player has too many keys
                        ExitFlag%% = TRUE
                    END IF
                ELSE
                    Result%% = Message_Handler(Layer(15), 50) 'no,
                    ExitFlag%% = TRUE
                END IF
            LOOP UNTIL ExitFlag%%
            ExitFlag%% = FALSE
        CASE 101 'Boy Item Shopkeep
            Result%% = Message_Handler(Layer(15), 105) '
            IF Buy_Sell_Box(10, 4, Layer(1)) THEN 'does player wish to buy
                '--------------player is buying items---------------------------------------
                Result%% = Message_Handler(Layer(15), 99) '
                DO
                    Item%% = Run_Shop(9, Layer(1))
                    G.ItemID = Item%%
                    IF Item%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        IF P.Gold > I(Item%%).Valu THEN 'dose player have the gold
                            IF P.Items < 8 AND Item%% <> 22 THEN 'does player have room or is player buying herbs

                                P.Gold = P.Gold - I(Item%%).Valu 'remove the cost from players purse
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                Add_To_Inventory Item%%, 1 'add the item to players inventory
                                Result%% = Message_Handler(Layer(15), 100) 'player buys item

                            ELSE 'players inventory is full or they are buying herbs

                                IF Item%% = 22 THEN 'if its a Herb then see if player has less than 6
                                    IF P.Herbs < 6 THEN 'can player hold more?
                                        P.Gold = P.Gold - I(Item%%).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        P.Herbs = P.Herbs + 1
                                        Result%% = Message_Handler(Layer(15), 100) 'player buys item
                                    ELSE 'player has too many herbs
                                        Result%% = Message_Handler(Layer(15), 102) '
                                    END IF
                                ELSE 'player has too many items
                                    Result%% = Message_Handler(Layer(15), 103) '
                                END IF
                            END IF

                        ELSE 'player hasn't the gold to buy
                            Result%% = Message_Handler(Layer(15), 101) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                    END IF
                LOOP UNTIL ExitFlag%%

            ELSE 'or is player going to sell
                '--------------------------Player is selling Items--------------------------------------
                IF P.Items OR P.Herbs OR P.Keys THEN
                    Result%% = Message_Handler(Layer(15), 94) '
                    DO
                        Item%% = Run_Item(18, 6, Layer(1))
                        IF Item%% < 0 THEN 'player canceled
                            ExitFlag%% = TRUE
                        ELSE
                            G.ItemID = Item%%
                            G.Price = INT(I(G.ItemID).Valu \ 2)
                            Result%% = Message_Handler(Layer(15), 96) '

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell
                                P.Gold = P.Gold + G.Price 'pay player
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase

                                IF G.ItemID = 22 THEN 'remove the item from players inventory
                                    P.Herbs = P.Herbs - 1
                                ELSEIF G.ItemID = 26 THEN
                                    P.Keys = P.Keys - 1
                                ELSE

                                    Drop_Inventory G.ItemID

                                END IF
                                Result%% = Message_Handler(Layer(15), 98) '
                            ELSE
                                Result%% = Message_Handler(Layer(15), 97) '
                            END IF

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell anything else
                                IF P.Items OR P.Herbs OR P.Keys THEN
                                    ExitFlag%% = FALSE
                                ELSE
                                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                                    ExitFlag%% = TRUE
                                END IF
                            ELSE
                                ExitFlag%% = TRUE
                            END IF
                        END IF
                    LOOP UNTIL ExitFlag%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                END IF
            END IF
        CASE 102 'Roaming Guard below armory
            Result%% = Message_Handler(Layer(15), 244) '
        CASE 103 'Merchant behind desk
            Result%% = Message_Handler(Layer(15), 245) '
        CASE 104 'Item Shop keep 2
            Result%% = Message_Handler(Layer(15), 105) '
            IF Buy_Sell_Box(10, 4, Layer(1)) THEN 'does player wish to buy
                '--------------player is buying items---------------------------------------
                Result%% = Message_Handler(Layer(15), 99) '
                DO
                    Item%% = Run_Shop(10, Layer(1))
                    G.ItemID = Item%%
                    IF Item%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        IF P.Gold > I(Item%%).Valu THEN 'dose player have the gold
                            IF P.Items < 8 AND Item%% <> 22 THEN 'does player have room or is player buying herbs

                                P.Gold = P.Gold - I(Item%%).Valu 'remove the cost from players purse
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                Add_To_Inventory Item%%, 1 'add the item to players inventory
                                Result%% = Message_Handler(Layer(15), 100) 'player buys item

                            ELSE 'players inventory is full or they are buying herbs

                                IF Item%% = 22 THEN 'if its a Herb then see if player has less than 6
                                    IF P.Herbs < 6 THEN 'can player hold more?
                                        P.Gold = P.Gold - I(Item%%).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        P.Herbs = P.Herbs + 1
                                        Result%% = Message_Handler(Layer(15), 100) 'player buys item
                                    ELSE 'player has too many herbs
                                        Result%% = Message_Handler(Layer(15), 102) '
                                    END IF
                                ELSE 'player has too many items
                                    Result%% = Message_Handler(Layer(15), 103) '
                                END IF
                            END IF

                        ELSE 'player hasn't the gold to buy
                            Result%% = Message_Handler(Layer(15), 101) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                    END IF
                LOOP UNTIL ExitFlag%%

            ELSE 'or is player going to sell
                '--------------------------Player is selling Items--------------------------------------
                IF P.Items OR P.Herbs OR P.Keys THEN
                    Result%% = Message_Handler(Layer(15), 94) '
                    DO
                        Item%% = Run_Item(18, 6, Layer(1))
                        IF Item%% < 0 THEN 'player canceled
                            ExitFlag%% = TRUE
                        ELSE
                            G.ItemID = Item%%
                            G.Price = INT(I(G.ItemID).Valu \ 2)
                            Result%% = Message_Handler(Layer(15), 96) '

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell
                                P.Gold = P.Gold + G.Price 'pay player
                                Draw_Stat_Window Layer(5) 'update the stat window after purchase

                                IF G.ItemID = 22 THEN 'remove the item from players inventory
                                    P.Herbs = P.Herbs - 1
                                ELSEIF G.ItemID = 26 THEN
                                    P.Keys = P.Keys - 1
                                ELSE

                                    Drop_Inventory G.ItemID

                                END IF
                                Result%% = Message_Handler(Layer(15), 98) '
                            ELSE
                                Result%% = Message_Handler(Layer(15), 97) '
                            END IF

                            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to sell anything else
                                IF P.Items OR P.Herbs OR P.Keys THEN
                                    ExitFlag%% = FALSE
                                ELSE
                                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                                    ExitFlag%% = TRUE
                                END IF
                            ELSE
                                ExitFlag%% = TRUE
                            END IF
                        END IF
                    LOOP UNTIL ExitFlag%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 95) 'player has no items to sell
                END IF
            END IF
        CASE 105 'Armory Secondary
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) '
            IF Yes_NO_Box(11, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = Run_Shop(11, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) '
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it
                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold
                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 0 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 0 THEN Sell%% = 3: G.ItemID = P.Shield
                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 106 'girl selling Fairy water
            G.Price = 38
            Result%% = Message_Handler(Layer(15), 88) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy fairy water
                DO
                    IF P.Gold >= 38 THEN 'player has enough gold
                        IF P.Items < 8 THEN 'player has room in pack
                            P.Gold = P.Gold - 38
                            Draw_Stat_Window Layer(5) 'update the stat window after purchase
                            Add_To_Inventory 25, 1 'add the item to players inventory
                            Result%% = Message_Handler(Layer(15), 90) '
                            IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy more
                        ELSE 'player is out of room
                            Result%% = Message_Handler(Layer(15), 92) '
                            ExitFlag%% = TRUE
                        END IF
                    ELSE 'player lacks enough gold
                        Result%% = Message_Handler(Layer(15), 91) '
                        ExitFlag%% = TRUE
                    END IF
                LOOP UNTIL ExitFlag%%
            ELSE 'player says no
                Result%% = Message_Handler(Layer(15), 89) '
            END IF
        CASE 107 'Roaming Girl 1
            Result%% = Message_Handler(Layer(15), 269) '
        CASE 108 'roaming girl 2
            Result%% = Message_Handler(Layer(15), 270) '
        CASE 109 'roaming Merchant
            Result%% = Message_Handler(Layer(15), 271) '
        CASE 110 'Roaming Boy
            Result%% = Message_Handler(Layer(15), 272) '
        CASE 111 'Wizard behind desk
            Result%% = Message_Handler(Layer(15), 273) '
        CASE 112 'Armory Shopkeep Third
            ExitFlag%% = FALSE
            Result%% = Message_Handler(Layer(15), 60) '
            IF Yes_NO_Box(11, 4, Layer(1)) THEN 'does player wish to buy something
                DO
                    Result%% = Run_Shop(12, Layer(1))
                    IF Result%% < 0 THEN
                        ExitFlag%% = TRUE
                    ELSE
                        G.ItemID = Result%%
                        Result%% = Message_Handler(Layer(15), 63) '
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN 'does player wish to buy it
                            IF P.Gold >= I(G.ItemID).Valu THEN 'player has enough gold
                                'check and see if player must sell something to buy
                                temp%% = G.ItemID 'backup the item player wishes to buy
                                IF G.ItemID < 8 AND P.Weapon <> 0 THEN Sell%% = 1: G.ItemID = P.Weapon
                                IF G.ItemID > 8 AND G.ItemID < 16 AND P.Armor <> 0 THEN Sell%% = 2: G.ItemID = P.Armor
                                IF G.ItemID > 16 AND G.ItemID < 21 AND P.Shield <> 0 THEN Sell%% = 3: G.ItemID = P.Shield
                                IF Sell%% THEN
                                    G.Price = INT(I(G.ItemID).Valu \ 2)
                                    Result%% = Message_Handler(Layer(15), 67) 'does player wish to sell current equipment
                                    IF Yes_NO_Box(10, 5, Layer(1)) THEN 'does player wish to sell it
                                        P.Gold = P.Gold + G.Price
                                        G.ItemID = temp%% 'restore the item player wants to buy
                                        SELECT CASE Sell%%
                                            CASE 1
                                                P.Weapon = G.ItemID
                                            CASE 2
                                                P.Armor = G.ItemID
                                            CASE 3
                                                P.Shield = G.ItemID
                                        END SELECT

                                        P.Gold = P.Gold - I(G.ItemID).Valu
                                        Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                        Result%% = Message_Handler(Layer(15), 65) '
                                    ELSE
                                        Result%% = Message_Handler(Layer(15), 64) '
                                    END IF
                                ELSE
                                    G.ItemID = temp%% 'restore purchased item
                                    IF G.ItemID < 8 THEN P.Weapon = G.ItemID 'player bought weapon
                                    IF G.ItemID > 8 AND G.ItemID < 16 THEN P.Armor = G.ItemID 'player bought armor
                                    IF G.ItemID > 16 AND G.ItemID < 21 THEN P.Shield = G.ItemID 'player bought shield
                                    P.Gold = P.Gold - I(G.ItemID).Valu
                                    Draw_Stat_Window Layer(5) 'update the stat window after purchase
                                    Result%% = Message_Handler(Layer(15), 65) '
                                END IF
                                '--------------------------------------------------
                            ELSE 'player lacks enough gold
                                Result%% = Message_Handler(Layer(15), 66) '
                            END IF
                        ELSE
                            Result%% = Message_Handler(Layer(15), 64) '
                        END IF
                        IF Yes_NO_Box(10, 4, Layer(1)) THEN ExitFlag%% = FALSE ELSE ExitFlag%% = TRUE 'does player wish to buy anything else
                    END IF
                LOOP UNTIL ExitFlag%%
                Result%% = Message_Handler(Layer(15), 61) 'please come again
            ELSE
                Result%% = Message_Handler(Layer(15), 61) '
            END IF
        CASE 113 'Roaming Merchant in room
            Result%% = Message_Handler(Layer(15), 282) '
        CASE 114 'Roaming Wizard in Damage area
            Result%% = Message_Handler(Layer(15), 283) '
        CASE 115 'Gaurd Roaming Top Left town
            Result%% = Message_Handler(Layer(15), 284) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN
                Result%% = Message_Handler(Layer(15), 286) '
            ELSE
                Result%% = Message_Handler(Layer(15), 285) '
            END IF
        CASE 116 'Wizard Inside Building
            Result%% = Message_Handler(Layer(15), 287) '
            '����������������������������������-��End of Cantlin NPCs--������������������������������������-
        CASE 117 'Rain Shrine Wizard
            IF P.Has_Harp THEN
                Result%% = Message_Handler(Layer(15), 289) 'Wizard Vanishes
                NPC(117).Done = TRUE
                Drop_Inventory 30 'he takes the harp with him
            ELSE
                Result%% = Message_Handler(Layer(15), 288) '
            END IF
        CASE 118 'Rainbow Temple Wizard
            IF P.Has_Token THEN
                IF P.Has_Stones AND P.Has_Staff THEN
                    Result%% = Message_Handler(Layer(15), 384) '
                    Drop_Inventory 34 'he takes the Sunlight Stones
                    Drop_Inventory 36 'he takes the Staff of Rain
                    Add_To_Inventory 35, 1 'He gives you the Rainbow Drop
                ELSE
                    Result%% = Message_Handler(Layer(15), 291) '
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 290) 'Player is kicked out of temple
                Fade_Out Layer(1)
                P.Map = -1: G.JustLeft = TRUE
                Remove_light_mask
                Build_Screen
                Fade_In Layer(1)
                Change_BGM: Reset_Chests: Reset_Doors
                P.Torched = FALSE 'torch and radiant go out when you enter overworld
                P.Radiant = FALSE
            END IF
        CASE 119 'DragonLord!
            Result%% = Message_Handler(Layer(15), 292) '
            IF Yes_NO_Box(10, 4, Layer(1)) THEN
                Result%% = Message_Handler(Layer(15), 294) '
                IF Yes_NO_Box(10, 4, Layer(1)) THEN 'Is player sure about this?
                    Result%% = Message_Handler(Layer(15), 296) 'game Over BAD
                    G.GameOver_Bad = TRUE
                ELSE
                    Result%% = Message_Handler(Layer(15), 295) 'Battle Ensues
                END IF
            ELSE
                Result%% = Message_Handler(Layer(15), 293) 'Battle Ensues
                IF Battle(38) THEN
                    NPC_Talk 120 'goto Dragon Lords 2nd form
                END IF
            END IF
        CASE 120 'DragonLord 1st form beaten
            Result%% = Message_Handler(Layer(15), 297) '
            IF Battle(39) THEN
                NPC_Talk 121 'goto Dragon Lords 2nd form defeat!
            END IF
        CASE 121 'DragonLord Defeated!!!
            Result%% = Message_Handler(Layer(15), 298) '
            F.Dragon_King_Killed = TRUE 'player has beaten game!
            'change NPC data for map 1(court yard) rewritting exsisting NPC data,
            Replace_Final_NPCs
            P.HP = P.Max_HP 'player is healed by Ball of Light
            P.MP = P.Max_MP
        CASE 122 'Renturning to castle! ALL NPC talk
            IF INT(RND * 100) > 50 THEN
                Result%% = Message_Handler(Layer(15), 299) '
            ELSE
                Result%% = Message_Handler(Layer(15), 300) '
            END IF
        CASE 123 'In Castle ALL NPC talk
            Result%% = Message_Handler(Layer(15), 301) '
        CASE 124 'Kings final Dialog
            _SNDSTOP BGM(G.Current_BGM)
            TIMER(T(0)) OFF 'turn timers off
            TIMER(T(1)) OFF
            G.GameOver_Good = TRUE
            Result%% = Message_Handler(Layer(15), 302) '
            IF P.Princess_Saved THEN
                G.GameOver_Good = FALSE
                G.GameOver_Great = TRUE
                NPC(18).X = 15
                Build_Screen
                _PUTIMAGE (532, 0)-STEP(107, 479), Layer(20), Layer(1), (532, 0)-STEP(107, 479)
                _PUTIMAGE (NPC(18).X * 32, NPC(18).Y * 32)-STEP(31, 31), Layer(4), Layer(0), (131, 183)-STEP(15, 15)
                _PUTIMAGE , Layer(1), Layer(5)
                Result%% = Message_Handler(Layer(15), 303) 'princess calls out
                'then walks from stairs to beside king
                FOR PW% = 0 TO 92
                    _PUTIMAGE , Layer(5), Layer(1)
                    _PUTIMAGE (NPC(18).X * 32 + PW%, NPC(18).Y * 32)-STEP(31, 31), Layer(4), Layer(1), (131, 183)-STEP(15, 15)
                    _PUTIMAGE , Layer(1), Layer(0)
                    _LIMIT 60
                NEXT PW%
                NPC(18).X = 18: NPC(18).Facing = DOWN
                _PUTIMAGE (NPC(18).X * 32 + NPC(18).MX, NPC(18).Y * 32 + NPC(18).MY)-STEP(31, 31), Layer(4), Layer(1), (3, 183)-STEP(15, 15)
                _PUTIMAGE , Layer(1), Layer(5)
                Result%% = Message_Handler(Layer(15), 389) '
                DO
                    IF Yes_NO_Box(10, 4, Layer(1)) THEN '
                        Result%% = Message_Handler(Layer(15), 305) '
                        ExitFlag%% = TRUE
                    ELSE
                        Result%% = Message_Handler(Layer(15), 304) 'But thou MUST!
                    END IF
                LOOP UNTIL ExitFlag%%
                P.Has_Princess = TRUE
                P.Facing = UP
            END IF
            Result%% = Message_Handler(Layer(15), 306) 'game Over Really GOOD!

            Build_Screen
            ' debug
            _PUTIMAGE (532, 0)-STEP(107, 479), Layer(20), Layer(1), (532, 0)-STEP(107, 479)
            _PUTIMAGE (NPC(7).X * 32 + NPC(7).MX, NPC(7).Y * 32 + NPC(7).MY)-STEP(31, 31), Layer(4), Layer(1), (131, 237)-STEP(15, 15)
            _PUTIMAGE (NPC(8).X * 32 + NPC(8).MX, NPC(8).Y * 32 + NPC(8).MY)-STEP(31, 31), Layer(4), Layer(1), (131, 237)-STEP(15, 15)
            _PUTIMAGE (NPC(12).X * 32 + NPC(12).MX, NPC(12).Y * 32 + NPC(12).MY)-STEP(31, 31), Layer(4), Layer(1), (131, 237)-STEP(15, 15)
            _PUTIMAGE (NPC(13).X * 32 + NPC(13).MX, NPC(13).Y * 32 + NPC(13).MY)-STEP(31, 31), Layer(4), Layer(1), (147, 237)-STEP(15, 15)
            _PUTIMAGE (NPC(15).X * 32 + NPC(15).MX, NPC(15).Y * 32 + NPC(15).MY)-STEP(31, 31), Layer(4), Layer(1), (147, 237)-STEP(15, 15)
            _PUTIMAGE (NPC(17).X * 32 + NPC(17).MX, NPC(17).Y * 32 + NPC(17).MY)-STEP(31, 31), Layer(4), Layer(1), (147, 237)-STEP(15, 15)
            _PUTIMAGE , Layer(1), Layer(0)
            _SNDPLAY BGM(14)
            _DELAY 10
        CASE 125 'using Gwaelin's love
            Result%% = Message_Handler(Layer(15), 308) '
            IF P.Map = -1 THEN 'only if player is in the over world display location from Castle
                Result%% = Message_Handler(Layer(15), 309) '
                IF P.WorldY - 44 < 0 THEN 'display north or south first
                    Result%% = Message_Handler(Layer(15), 311) '
                ELSE 'player is north or = castle
                    Result%% = Message_Handler(Layer(15), 310) '
                END IF
                IF P.WorldX - 44 < 0 THEN 'then display west or east
                    Result%% = Message_Handler(Layer(15), 313) '
                ELSE 'player is east or = castle
                    Result%% = Message_Handler(Layer(15), 312) '
                END IF
            END IF
            Result%% = Message_Handler(Layer(15), 22) '
        CASE 126 'Error Msg "I have nothing to say"
            Result%% = Message_Handler(Layer(15), 391) '
    END SELECT
    Reset_Message_Layer
END SUB

FUNCTION Run_Shop%% (ID%%, L&)
    X%% = 10: Y%% = 4
    Result%% = FALSE
    Selection%% = 1
    _PUTIMAGE , Layer(1), Layer(5)

    SELECT CASE ID%%
        CASE 1 'breconary armory shop
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 13, L&

                FOR i%% = 1 TO 6
                    IF LEN(RTRIM$(I(Shop(1, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(1, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(1, i%%)).Nam, 1, INSTR(I(Shop(1, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(1, i%%)).Nam, INSTR(I(Shop(1, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(1, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 7 THEN Selection%% = 6
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(1, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 2 'breconary item shop buy
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 7, L&
                FOR i%% = 1 TO 3
                    IF LEN(RTRIM$(I(Shop(2, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(2, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(2, i%%)).Nam, 1, INSTR(I(Shop(2, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(2, i%%)).Nam, INSTR(I(Shop(2, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(2, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        '      ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 4 THEN Selection%% = 3
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(2, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 3 'Garinham itemshop
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 7, L&
                FOR i%% = 1 TO 3
                    IF LEN(RTRIM$(I(Shop(3, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(3, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(3, i%%)).Nam, 1, INSTR(I(Shop(3, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(3, i%%)).Nam, INSTR(I(Shop(3, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(3, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 4 THEN Selection%% = 3
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(3, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 4 'Garinham armory
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 15, L&

                FOR i%% = 1 TO 7
                    IF LEN(RTRIM$(I(Shop(4, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(4, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(4, i%%)).Nam, 1, INSTR(I(Shop(4, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(4, i%%)).Nam, INSTR(I(Shop(4, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(4, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 8 THEN Selection%% = 7
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(4, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 5 'Kol armory
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 11, L&

                FOR i%% = 1 TO 5
                    IF LEN(RTRIM$(I(Shop(5, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(5, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(5, i%%)).Nam, 1, INSTR(I(Shop(5, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(5, i%%)).Nam, INSTR(I(Shop(5, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(5, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 6 THEN Selection%% = 5
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(5, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 6 'Kol Item shop
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 9, L&
                FOR i%% = 1 TO 4
                    IF LEN(RTRIM$(I(Shop(6, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(6, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(6, i%%)).Nam, 1, INSTR(I(Shop(6, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(6, i%%)).Nam, INSTR(I(Shop(6, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(6, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 5 THEN Selection%% = 4
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(6, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 7 'Rimuldar Armory
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 13, L&

                FOR i%% = 1 TO 6
                    IF LEN(RTRIM$(I(Shop(7, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(7, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(7, i%%)).Nam, 1, INSTR(I(Shop(7, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(7, i%%)).Nam, INSTR(I(Shop(7, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(7, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 7 THEN Selection%% = 6
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(7, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 8 'Cantlin Armory Main
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 13, L&

                FOR i%% = 1 TO 6
                    IF LEN(RTRIM$(I(Shop(8, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(8, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(8, i%%)).Nam, 1, INSTR(I(Shop(8, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(8, i%%)).Nam, INSTR(I(Shop(8, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(8, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 7 THEN Selection%% = 6
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(8, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 9 'Cantlin Item Shop 1
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 5, L&
                FOR i%% = 1 TO 2
                    IF LEN(RTRIM$(I(Shop(9, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(9, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(9, i%%)).Nam, 1, INSTR(I(Shop(9, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(9, i%%)).Nam, INSTR(I(Shop(9, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(9, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 3 THEN Selection%% = 2
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(9, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 10 'Cantlin Item Shop 2
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 5, L&
                FOR i%% = 1 TO 2
                    IF LEN(RTRIM$(I(Shop(10, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(10, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(10, i%%)).Nam, 1, INSTR(I(Shop(10, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(10, i%%)).Nam, INSTR(I(Shop(10, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(10, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 3 THEN Selection%% = 2
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(10, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 11 'Cantlin Armory secondary
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 5, L&
                FOR i%% = 1 TO 2
                    IF LEN(RTRIM$(I(Shop(11, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(11, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(11, i%%)).Nam, 1, INSTR(I(Shop(11, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(11, i%%)).Nam, INSTR(I(Shop(11, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(11, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 3 THEN Selection%% = 2
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(11, Selection%%)
                    CASE BUTTON_B
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT
                DO: LOOP WHILE Get_Input >= 0
                _LIMIT 60
            LOOP UNTIL ExitFlag%%
        CASE 12 'Cantlin Armory Third
            DO
                _PUTIMAGE , Layer(5), L&
                Draw_Window X%%, Y%%, 20, 9, L&
                FOR i%% = 1 TO 4
                    IF LEN(RTRIM$(I(Shop(12, i%%)).Nam)) < 9 THEN
                        V1$ = RTRIM$(I(Shop(12, i%%)).Nam)
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                    ELSE
                        V1$ = MID$(I(Shop(12, i%%)).Nam, 1, INSTR(I(Shop(12, i%%)).Nam, CHR$(32)))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2))), V1$, L&
                        V2$ = RTRIM$(MID$(I(Shop(12, i%%)).Nam, INSTR(I(Shop(12, i%%)).Nam, CHR$(32))))
                        _PRINTSTRING (16 * (13), 16 * (3 + (i%% * 2) + 1)), V2$, L&
                    END IF
                    V1$ = LTRIM$(STR$(I(Shop(12, i%%)).Valu))
                    _PRINTSTRING (16 * (30 - LEN(V1$)), 16 * (3 + (i%% * 2))), V1$, L&
                NEXT i%%
                IF Frame%% THEN Display_Selection_Arrow X%% + 1, 3 + (Selection%% * 2), L&
                _PUTIMAGE , L&, Layer(0)
                SELECT CASE Get_Input
                    CASE 27
                        ' ExitFlag%% = TRUE
                    CASE UP
                        Selection%% = Selection%% - 1
                        IF Selection%% = 0 THEN Selection%% = 1
                    CASE DOWN
                        Selection%% = Selection%% + 1
                        IF Selection%% = 5 THEN Selection%% = 4
                    CASE BUTTON_A
                        ExitFlag%% = TRUE
                        Result%% = Shop(12, Selection%%)
                    CASE _BUTTON
                        ExitFlag%% = TRUE
                        Result%% = TRUE 'exit shop routine
                END SELECT

                DO: LOOP WHILE Get_Input >= 0

                _LIMIT 60
            LOOP UNTIL ExitFlag%%
    END SELECT
    _PUTIMAGE , Layer(5), Layer(1)
    Run_Shop = Result%%
END FUNCTION

SUB Use_Item (Item%%)
    SELECT CASE Item%%
        CASE 21 'torch:provides 1 square light radius around player
            IF G.Battle >= 0 THEN
                Result%% = Message_Handler(Layer(15), 358) 'can not be used in battle
            ELSE
                IF PD(P.Map).Is_Lit = FALSE THEN
                    P.Torched = TRUE
                    Create_Light_Mask
                    Drop_Inventory Item%%
                ELSE
                    Result%% = Message_Handler(Layer(15), 318) 'why use a torch if its already light?
                END IF
            END IF
        CASE 22 'herbs:restore 23-30hp
            Result%% = Message_Handler(Layer(15), 322) '
            P.Herbs = P.Herbs - 1
            P.HP = P.HP + INT(RND * 8) + 23
            IF P.HP > P.Max_HP THEN P.HP = P.Max_HP - P.HP_Mod
        CASE 23 'wings:return player to castle
            IF G.Battle >= 0 THEN
                Result%% = Message_Handler(Layer(15), 358) 'can not be used in battle
            ELSE
                SELECT CASE P.Map
                    CASE 8, 9, 11, 12, 15 TO 18, 21, 22 'can't use here
                        Result%% = Message_Handler(Layer(15), 317) '
                    CASE ELSE
                        Result%% = Message_Handler(Layer(15), 316) '
                        P.Map = -1
                        P.WorldX = 43
                        P.WorldY = 44
                        Drop_Inventory Item%%
                        _SNDPLAY SFX(19)
                        Fade_Out Layer(1)
                        DO: _LIMIT 10: LOOP WHILE _SNDPLAYING(SFX(19))
                        Build_Screen
                        Fade_In Layer(1)
                        Change_BGM: Reset_Chests: Reset_Doors
                END SELECT
            END IF
        CASE 24 'dragon scale:adds 2 defence
            IF NOT P.Scale THEN
                Result%% = Message_Handler(Layer(15), 319) '
                P.Scale = TRUE 'player has donned the dragon's scale
            ELSE
                Result%% = Message_Handler(Layer(15), 320) '
            END IF
        CASE 25 'Fairy water:repels creatures weaker than player defence 128steps
            IF G.Battle >= 0 THEN
                Result%% = Message_Handler(Layer(15), 358) 'can not be used in battle
            ELSE
                Result%% = Message_Handler(Layer(15), 321) '
                Drop_Inventory Item%%
                P.Is_Repel = 127
            END IF
        CASE 26 'magic key:opens 1 door
            IF Is_Door THEN
            ELSE
            END IF
        CASE 27 'Edrick's tablet:tells player some information not inventoryable
            Result%% = Message_Handler(Layer(15), 326) '
        CASE 28 'fairy flute: puts Golem to sleep
            Result%% = Message_Handler(Layer(15), 331) '
            _SNDSTOP BGM(G.Current_BGM)
            _SNDPLAY SFX(8) 'a short melody
            DO: LOOP WHILE _SNDPLAYING(SFX(8))
            _SNDLOOP BGM(G.Current_BGM)
            IF G.Battle = 24 THEN
                Result%% = Message_Handler(Layer(15), 332) '
                M(G.Battle).Is_Asleep = TRUE
            ELSE
                Result%% = Message_Handler(Layer(15), 327) '
            END IF
        CASE 29 'Cursed Belt: nothing in actual game, reduces players defence(-15) cannot be removed
            G.ItemID = Item%%
            IF P.Cursed THEN
                Result%% = Message_Handler(Layer(15), 330) '
            ELSE
                Result%% = Message_Handler(Layer(15), 329) '
                P.Cursed = TRUE
                P.Def_Mod = P.Def_Mod + 15
            END IF
        CASE 30 'Silver harp: summons monster to fight
            IF G.Battle >= 0 THEN
                Result%% = Message_Handler(Layer(15), 359) 'can not be used in battle
            ELSE
                Result%% = Message_Handler(Layer(15), 388) 'player plays a sweet melody!
                _SNDSTOP BGM(G.Current_BGM)
                _SNDPLAY SFX(20) 'a short melody
                DO: LOOP WHILE _SNDPLAYING(SFX(20))
                Reset_Message_Layer 'clear the message for battle
                IF P.Map = -1 THEN
                    G.Battle = Pick_Battle(NChance(6)) 'pick a monster to fight Blue Slime(0) - MagiDrake(5)
                    IF G.Battle = 5 THEN G.Battle = 6 'though if it picks magidrake shift it to Scorpion, as per original game
                ELSE 'only works in the overworld
                    _SNDLOOP BGM(G.Current_BGM)
                    Result%% = Message_Handler(Layer(15), 327) 'but nothing happened
                END IF
            END IF
        CASE 31 'spell book: ???
        CASE 32 'Fighter's Ring: nothing in actual game, +4 strength here
        CASE 33 'Death Necklace: nothing in actual game, -25hp(min 1) -25defence(min 0) cannot be removed
            G.ItemID = Item%%
            IF P.Cursed THEN
                Result%% = Message_Handler(Layer(15), 330) '
            ELSE
                Result%% = Message_Handler(Layer(15), 329) '
                P.Cursed = TRUE
                P.Def_Mod = P.Def_Mod + 25
                P.HP_Mod = 25
                IF P.HP > P.Max_HP - P.HP_Mod THEN P.HP = P.Max_HP - P.HP_Mod
            END IF
        CASE 35 'Rainbow drop: creates rainbow bridge at a certain location
            IF G.Battle >= 0 THEN
                Result%% = Message_Handler(Layer(15), 358) 'can not be used in battle
            ELSE
                IF P.WorldX = 66 AND P.WorldY = 50 THEN
                    'make bridge
                    World(65, 50).Sprite_ID = 4 'update the map
                    _PUTIMAGE (128 + 32 * 65, 128 + 32 * 50)-STEP(31, 31), Layer(3), Layer(2), (1 + 17 * World(65, 50).Sprite_ID, 1)-STEP(15, 15)
                    F.RainBow_Bridge_Done = TRUE
                ELSE
                    Result%% = Message_Handler(Layer(15), 385) 'wrong location
                END IF
            END IF
        CASE 38 'Gwaelin's love: tells player needed XP, and distance from Tantegel castle
            IF G.Battle >= 0 THEN
                Result%% = Message_Handler(Layer(15), 358) 'can not be used in battle
            ELSE
                Result%% = Message_Handler(Layer(15), 308) ' Gwaelin gives Xp needed
                IF P.Map = -1 THEN 'if player is in over world
                    Result%% = Message_Handler(Layer(15), 309) '

                    'default(0 value) is NORTH and WEST
                    IF P.WorldY < 44 THEN
                        Result%% = Message_Handler(Layer(15), 311) 'south
                    ELSE
                        Result%% = Message_Handler(Layer(15), 310) 'north
                    END IF
                    IF P.WorldX < 44 THEN
                        Result%% = Message_Handler(Layer(15), 312) 'east
                    ELSE
                        Result%% = Message_Handler(Layer(15), 313) 'west
                    END IF

                END IF
                Result%% = Message_Handler(Layer(15), 22) ' Princess loves you! How sweet! ;p
            END IF
    END SELECT
END SUB

FUNCTION Run_Item%% (X%%, Y%%, L&)
    Result%% = -1
    Selection%% = 1
    _PUTIMAGE , Layer(1), Layer(5)
    IF P.Herbs THEN Count%% = Count%% + 1
    IF P.Keys THEN Count%% = Count%% + 1
    Count%% = Count%% + P.Items
    DO
        _PUTIMAGE , Layer(5), L&
        Draw_Window X%%, Y%%, 11, Count%% * 2 + 1, L&
        i%% = 0
        IF P.Herbs THEN
            _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 1 + (i%% * 2))), "Herbs", L&
            V1$ = LTRIM$(STR$(P.Herbs))
            _PRINTSTRING (16 * (28), 16 * (Y%% + 1 + (i%% * 2))), V1$, L&
            i%% = i%% + 1
        END IF
        IF P.Keys THEN
            _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 1 + (i%% * 2))), "Magic", L&
            _PRINTSTRING (16 * (X%% + 2), 16 * (Y%% + 2 + (i%% * 2))), " Keys", L&
            V1$ = LTRIM$(STR$(P.Keys))
            _PRINTSTRING (16 * (28), 16 * (Y%% + 1 + (i%% * 2))), V1$, L&
            i%% = i%% + 1
        END IF

        Offset%% = Y%% + 1 + (i%% * 2)

        FOR j%% = 0 TO P.Items - 1
            IF LEN(RTRIM$(I(Inventory_Item(j%%)).Nam)) < 9 THEN
                V1$ = RTRIM$(I(Inventory_Item(j%%)).Nam)
                _PRINTSTRING (16 * (X%% + 2), 16 * (Offset%% + ((j%%) * 2))), V1$, L&
            ELSE
                V1$ = MID$(I(Inventory_Item(j%%)).Nam, 1, INSTR(I(Inventory_Item(j%%)).Nam, CHR$(32)) - 1)
                _PRINTSTRING (16 * (X%% + 2), 16 * (Offset%% + ((j%%) * 2))), V1$, L&
                V2$ = RTRIM$(MID$(I(Inventory_Item(j%%)).Nam, INSTR(I(Inventory_Item(j%%)).Nam, CHR$(32))))
                _PRINTSTRING (16 * (X%% + 2), 16 * (Offset%% + ((j%%) * 2 + 1))), V2$, L&
            END IF
        NEXT j%%

        IF Frame%% THEN Display_Selection_Arrow X%% + 1, 7 + ((Selection%% - 1) * 2), L&
        _PUTIMAGE , L&, Layer(0)

        SELECT CASE Get_Input
            CASE 27
                ' ExitFlag%% = TRUE
            CASE UP
                Selection%% = Selection%% - 1
                IF Selection%% = 0 THEN Selection%% = 1
                Joy_Lock_Axis (C.Joy_Up)
            CASE DOWN
                Selection%% = Selection%% + 1
                IF Selection%% = P.Items + i%% + 1 THEN Selection%% = P.Items + i%%
                Joy_Lock_Axis (C.Joy_Down)
            CASE BUTTON_A
                ExitFlag%% = TRUE

                IF Selection%% = 1 AND P.Herbs THEN
                    Result%% = 22
                ELSEIF Selection%% = 1 AND P.Keys > 0 THEN
                    Result%% = 26
                ELSEIF Selection%% = 2 AND P.Keys > 0 AND P.Herbs > 0 THEN
                    Result%% = 26
                ELSE
                    Result%% = Inventory_Item(Selection%% - i%% - 1)
                END IF

            CASE BUTTON_B
                ExitFlag%% = TRUE
                Result%% = TRUE 'exit shop routine
        END SELECT
        _LIMIT 60
    LOOP UNTIL ExitFlag%%
    Run_Item = Result%%
END FUNCTION

FUNCTION Message_Handler (L&, MSG%)
    STATIC Processed AS STRING, LineCount AS _BYTE, CurrentLine AS _BYTE
    STATIC WLine(10) AS STRING * 22, Slowit AS _BYTE
    TotalLines%% = Messages(MSG%, 1) 'number of lines to display
    CurrentLine = 1

    DO
        CMSG% = Lines(Messages(MSG%, 0), DisplayedLines%%) 'Current MeSsaGe line
        IF INSTR(Script(CMSG%), "#") OR INSTR(Script(CMSG%), "&") THEN 'special needs character
            Processed = Process_Message_Coding$(Script(CMSG%)): Message_Length = LEN(Processed)
        ELSE
            Message_Length = LEN(Script(CMSG%))
            Processed = Script(CMSG%)
        END IF
        'check message length word wrap if needed
        IF Message_Length > 22 AND LineCount = 0 THEN LineCount = Process_Word_Wrap(WLine(), Processed)
        IF Message_Length <= 22 THEN LineCount = 1: WLine(1) = Processed
        DO

            IF Slowit = 1 * G.MessageSpeed THEN
                Slowit = 0: Current_Char = Current_Char + 1
                IF F.PlayClick AND (NOT _SNDPLAYING(SFX(3))) THEN _SNDPLAY SFX(3)
            END IF

            _PRINTSTRING (80, 304 + (16 * (Displayed))), MID$(WLine(CurrentLine), 1, Current_Char), L& 'print message 1 character at a time.

            IF Current_Char = LEN(RTRIM$(WLine(CurrentLine))) THEN CurrentLine = CurrentLine + 1: Current_Char = 0: Displayed = Displayed + 1
            IF Displayed = 8 THEN Scroll_Line L&: Displayed = Displayed - 1

            IF CurrentLine = LineCount + 1 THEN ExitFlag%% = TRUE
            _PUTIMAGE , Layer(5), Layer(1) 'throw the backup layer in
            Draw_Window 4, 18, 23, 9, Layer(1) 'add message area window
            _PUTIMAGE , L&, Layer(1) 'move text into window
            _PUTIMAGE , Layer(1), Layer(0) 'move that to screen

            _LIMIT 60
            '   IF _KEYHIT = 27 THEN ExitFlag%% = TRUE
            Slowit = Slowit + 1 'makes the message display at the set speed
        LOOP UNTIL ExitFlag%%

        ExitFlag%% = FALSE

        DisplayedLines%% = DisplayedLines%% + 1

        OFFY%% = CurrentLine: CurrentLine = 1: LineCount = 0: Displayed = Displayed + 1
        IF Displayed = 8 THEN Scroll_Line L&: Displayed = Displayed - 1
        IF DisplayedLines%% = TotalLines%% THEN 'are we done displaying message? or
            Completed%% = TRUE
        ELSE 'is there more of message to display
        END IF

        IF MSG% = 354 THEN G.Battle = TRUE 'Monster Ran away so have message pause.

        IF G.Input_Wait = FALSE THEN
            G.Input_Wait = TRUE
        ELSEIF G.Battle = TRUE THEN 'no delays if in battle values 0-40
            DO
                _PUTIMAGE , Layer(5), Layer(1) 'throw the backup layer in
                Draw_Window 4, 18, 23, 9, Layer(1) 'add message area window
                _PUTIMAGE , L&, Layer(1) 'move text into window
                IF Frame%% THEN Display_Waiting_Arrow 15, 18 + Displayed, Layer(1)
                _PUTIMAGE , Layer(1), Layer(0) 'move that to screen
                _LIMIT 60
            LOOP UNTIL Get_Input = BUTTON_A
            DO: LOOP WHILE Get_Input >= 0
        END IF

    LOOP UNTIL Completed%%
    Processed = "": Message_Length = 0: Result%% = FALSE
    CurrentLine = 0: WLine(1) = "": LineCount = 0 ': Displayed = 0
    Message_Handler = Result%%
    _DELAY .125
END FUNCTION

FUNCTION Process_Word_Wrap (Lines() AS STRING * 22, txt$)
    Result%% = 1: I%% = 1
    DO
        'start on character 22 and work back to a space
        x%% = 22: Space%% = FALSE
        DO
            IF MID$(txt$, x%%, 1) <> CHR$(32) THEN x%% = x%% - 1 ELSE Space%% = TRUE
            IF x%% = 0 AND I%% = 1 THEN PRINT "ERROR": END
        LOOP UNTIL Space%%
        Lines(I%%) = MID$(txt$, 1, x%%)
        txt$ = MID$(txt$, x%% + 1)
        I%% = I%% + 1
        IF LEN(txt$) <= 22 THEN GoodLength%% = TRUE
    LOOP UNTIL GoodLength%%
    Lines(I%%) = txt$ 'put the last of the text into a line
    Result%% = I%%
    Process_Word_Wrap = Result%%
END FUNCTION

SUB Scroll_Line (L&)
    ClearLayer Layer(6)
    _PUTIMAGE (0, 0), L&, Layer(6), (80, 320)-STEP(351, 111)
    _PUTIMAGE (80, 304), Layer(6), L&, (0, 0)-STEP(351, 127)
END SUB

FUNCTION Process_Message_Coding$ (Txt$)
    FOR i~%% = 1 TO LEN(Txt$) 'check message for formating
        IF MID$(Txt$, i~%%, 1) = "#" THEN 'indicates an insert
            SELECT CASE MID$(Txt$, i~%% + 1, 1)
                CASE "E" 'monster name
                    Result$ = Result$ + RTRIM$(M(G.Battle).Nam)
                    i~%% = i~%% + 1
                CASE "P" 'player name
                    Result$ = Result$ + RTRIM$(P.Nam)
                    i~%% = i~%% + 1
                CASE "I" 'item name
                    Result$ = Result$ + RTRIM$(I(G.ItemID).Nam)
                    i~%% = i~%% + 1
                CASE "N" 'number value
                    SELECT CASE MID$(Txt$, i~%% + 2, 1)
                        CASE "X" 'experiance required for next level
                            Result$ = Result$ + LTRIM$(STR$(EXP_Required))
                        CASE "P" 'exPeriance gained
                            Result$ = Result$ + LTRIM$(STR$(M(G.Battle).Exp))
                            G.Battle = TRUE 'set this to -1 to indicate no monster to fight, after using it to process exp
                        CASE "D" 'golD gained from fight
                            Result$ = Result$ + LTRIM$(STR$(G.Price))
                        CASE "G" 'gold
                            Result$ = Result$ + LTRIM$(STR$(G.Price))
                        CASE "H" 'hits
                            Result$ = Result$ + LTRIM$(STR$(G.Damage))
                        CASE "N" 'north
                            Result$ = Result$ + LTRIM$(STR$(ABS(P.WorldY - 44)))
                        CASE "S" 'south
                            Result$ = Result$ + LTRIM$(STR$(ABS(P.WorldY - 44)))
                        CASE "E" 'east
                            Result$ = Result$ + LTRIM$(STR$(ABS(P.WorldX - 44)))
                        CASE "W" 'west
                            Result$ = Result$ + LTRIM$(STR$(ABS(P.WorldX - 44)))
                        CASE "A" 'player attack strength increase
                            Result$ = Result$ + LTRIM$(STR$(P.Strength - G.Old_Str))
                        CASE "R" 'player response speed increase
                            Result$ = Result$ + LTRIM$(STR$(P.Agility - G.Old_Agl))
                        CASE "B" 'player hit point increase
                            Result$ = Result$ + LTRIM$(STR$(P.Max_HP - G.Old_Mhp))
                        CASE "M" 'player magic point increase
                            Result$ = Result$ + LTRIM$(STR$(P.Max_MP - G.Old_Mmp))
                    END SELECT
                    i~%% = i~%% + 2
                CASE "S" 'spell
                    Result$ = Result$ + RTRIM$(Spells(G.Cast))
                    i~%% = i~%% + 1
            END SELECT
        ELSEIF MID$(Txt$, i~%%, 1) = "&" THEN 'used to bypass the wait arrow if player's Yes No response is needed
            SELECT CASE MID$(Txt$, i~%% + 1, 1)
                CASE "Y" 'yes\no input box
                    Temp$ = MID$(Txt$, i~%% + 2)
                    i~%% = i~%% + 1 + LEN(Temp$)
                    G.Input_Wait = FALSE
            END SELECT
        ELSE
            Result$ = Result$ + MID$(Txt$, i~%%, 1)
        END IF
    NEXT i~%%
    Process_Message_Coding = Result$
END FUNCTION
SUB Draw_Window (X%%, Y%%, Xs%%, Ys%%, L&)
    'top corners of window
    _PUTIMAGE (X%% * 16, Y%% * 16)-STEP(15, 15), Layer(3), L&, (0, 18)-STEP(7, 7)
    _PUTIMAGE (X%% * 16 + Xs%% * 16, Y%% * 16)-STEP(15, 15), Layer(3), L&, (8, 18)-STEP(7, 7)
    'bottom corners of window
    _PUTIMAGE (X%% * 16, Y%% * 16 + Ys%% * 16)-STEP(15, 15), Layer(3), L&, (16, 18)-STEP(7, 7)
    _PUTIMAGE (X%% * 16 + Xs%% * 16, Y%% * 16 + Ys%% * 16)-STEP(15, 15), Layer(3), L&, (24, 18)-STEP(7, 7)
    'top and bottom of window
    FOR i%% = 1 TO Xs%% - 1
        _PUTIMAGE (X%% * 16 + i%% * 16, Y%% * 16)-STEP(15, 15), Layer(3), L&, (56, 18)-STEP(7, 7)
        _PUTIMAGE (X%% * 16 + i%% * 16, Y%% * 16 + Ys%% * 16)-STEP(15, 15), Layer(3), L&, (48, 18)-STEP(7, 7)
    NEXT i%%
    'left and right sides of window
    FOR i%% = 1 TO Ys%% - 1
        _PUTIMAGE (X%% * 16, Y%% * 16 + 16 * i%%)-STEP(15, 15), Layer(3), L&, (32, 18)-STEP(7, 7)
        _PUTIMAGE (X%% * 16 + Xs%% * 16, Y%% * 16 + 16 * i%%)-STEP(15, 15), Layer(3), L&, (40, 18)-STEP(7, 7)
    NEXT i%%
    'fill in window
    _PUTIMAGE ((X%% + 1) * 16, (Y%% + 1) * 16)-STEP((Xs%% - 1) * 16, (Ys%% - 1) * 16), Layer(3), L&, (307, 1)-STEP(15, 15)
END SUB

SUB ClearLayer (L&)
    old& = _DEST
    _DEST L&
    CLS ' ,0
    _DEST old&
END SUB

SUB ClearLayerTrans (L&)
    old& = _DEST
    _DEST L&
    CLS , 0
    _DEST old&
END SUB

'SUB ClearLayerADV (L&)
' STATIC ML1 AS _MEM
' ML1 = _MEMIMAGE(L&)
' _MEMPUT ML1, ML1.OFFSET, _MEMGET(ClearLayerMaster, ClearLayerMaster.OFFSET, STRING * 8667136)
'END SUB

SUB Display_Selection_Arrow (X%%, Y%%, L&)
    _PUTIMAGE (X%% * 16, Y%% * 16)-STEP(15, 15), Layer(3), L&, (64, 18)-STEP(7, 7)
END SUB

SUB Display_Waiting_Arrow (X%%, Y%%, L&)
    _PUTIMAGE (X%% * 16, Y%% * 16)-STEP(15, 15), Layer(3), L&, (72, 18)-STEP(7, 7)
END SUB

'mapping routines ------------------------------------------
SUB Copy_Map_Layer (L&, MX%%, MY%%)
    IF P.Map >= 0 THEN
        _PUTIMAGE (16, 16), L&, Layer(1), (MX%% * 32 - 240 + G.X, MY%% * 32 - 208 + G.Y)-STEP(495, 447)
    ELSE
        _PUTIMAGE (16, 16), L&, Layer(1), (128 + MX%% * 32 - 240 + G.X, 128 + MY%% * 32 - 208 + G.Y)-STEP(495, 447)
    END IF
END SUB

SUB Build_World_Layer (L&)
    FOR Y~%% = 0 TO 255
        FOR X~%% = 0 TO 255
            _PUTIMAGE (32 * X~%%, 32 * Y~%%)-STEP(31, 31), Layer(3), L&, (1 + 17 * 14, 1)-STEP(15, 15)
    NEXT X~%%, Y~%%
    FOR Y%% = 0 TO 121
        FOR X%% = 0 TO 121
            _PUTIMAGE (128 + 32 * X%%, 128 + 32 * Y%%)-STEP(31, 31), Layer(3), L&, (1 + 17 * World(X%%, Y%%).Sprite_ID, 1)-STEP(15, 15)
    NEXT X%%, Y%%
END SUB

SUB Build_Place_Layer (L&, ID%%)
    FOR Y%% = 0 TO 45
        FOR X%% = 0 TO 45
            _PUTIMAGE (0 + 32 * X%%, 0 + 32 * Y%%)-STEP(31, 31), Layer(3), L&, (1 + 17 * Place(ID%%, X%%, Y%%).Sprite_ID, 1)-STEP(15, 15)
    NEXT X%%, Y%%
END SUB

SUB Copy_NPC_Layer (L&, MX%%, MY%%)
    _PUTIMAGE (16, 16), L&, Layer(1), (MX%% * 32 - 240 + G.X, MY%% * 32 - 208 + G.Y)-STEP(495, 447)
END SUB

SUB Display_Chests (L&)
    FOR i%% = 0 TO CHEST_COUNT
        IF Chest(i%%).Map = P.Map AND (NOT Chest(i%%).Opened) THEN
            _PUTIMAGE (0 + 32 * Chest(i%%).X, 0 + 32 * Chest(i%%).Y)-STEP(31, 31), Layer(3), L&, (1 + 17 * 37, 1)-STEP(15, 15)
        END IF
    NEXT i%%
END SUB

SUB Display_Doors (L&)
    FOR i%% = 0 TO DOOR_COUNT
        IF Doors(i%%).Map = P.Map AND (NOT Doors(i%%).Opened) THEN
            _PUTIMAGE (0 + 32 * Doors(i%%).X, 0 + 32 * Doors(i%%).Y)-STEP(31, 31), Layer(3), L&, (1 + 17 * 38, 1)-STEP(15, 15)
        END IF
    NEXT i%%

    IF P.Map = 11 THEN 'if player has not saved Princess yet then display this sprite.
        IF P.Has_Princess = FALSE AND P.Princess_Saved = FALSE THEN
            _PUTIMAGE (0 + 32 * 23, 0 + 32 * 25)-STEP(31, 31), Layer(3), L&, (1 + 17 * 36, 1)-STEP(15, 15)
        END IF
    END IF

END SUB

SUB Create_Light_Mask
    'called when entering a cave, and when there is a change in light level
    ClearLayerTrans Layer(11)
    _DEST Layer(11)
    IF P.Torched OR (P.Radiant > 0) THEN 'check for a light situation
        IF P.Torched THEN 'player uses a torch, 1 square radius
            FOR i~%% = 0 TO 224
                LINE (256 - 32 - i~%%, 224 - 32 - i~%%)-STEP(95 + i~%% * 2, 95 + i~%% * 2), _RGBA32(0, 0, 0, 255), B
            NEXT i~%%
        END IF
        IF P.Radiant > 0 THEN 'does player have an active Radiant Spell?
            SELECT CASE P.Radiant
                CASE 0 'no illumination
                    FOR i~%% = 0 TO 240
                        LINE (256 - i~%%, 224 - i~%%)-STEP(31 + i~%% * 2, 31 + i~%% * 2), _RGBA32(0, 0, 0, 255), B
                    NEXT i~%%
                CASE 1 TO 60 '1 square , same as torch
                    FOR i~%% = 0 TO 224
                        LINE (256 - 32 - i~%%, 224 - 32 - i~%%)-STEP(95 + i~%% * 2, 95 + i~%% * 2), _RGBA32(0, 0, 0, 255), B
                    NEXT i~%%
                CASE 61 TO 120 '2 square radius
                    FOR i~%% = 0 TO 192
                        LINE (256 - 64 - i~%%, 224 - 64 - i~%%)-STEP(159 + i~%% * 2, 159 + i~%% * 2), _RGBA32(0, 0, 0, 255), B
                    NEXT i~%%
                CASE IS > 120 '3 square radius
                    FOR i~%% = 0 TO 160
                        LINE (256 - 96 - i~%%, 224 - 96 - i~%%)-STEP(223 + i~%% * 2, 223 + i~%% * 2), _RGBA32(0, 0, 0, 255), B
                    NEXT i~%%
            END SELECT
        END IF
    ELSE 'there is no light
        FOR i~%% = 0 TO 240
            LINE (256 - i~%%, 224 - i~%%)-STEP(31 + i~%% * 2, 31 + i~%% * 2), _RGBA32(0, 0, 0, 255), B
        NEXT i~%%
    END IF
    _DEST Layer(0)
END SUB

SUB Remove_light_mask
    ClearLayerTrans Layer(11)
END SUB

SUB Frame_Change
    IF Frame%% THEN Frame%% = 0 ELSE Frame%% = 1
END SUB

SUB Build_Screen
    IF P.Map >= 0 THEN L%% = 7: PMX%% = P.MapX: PMY%% = P.MapY ELSE L%% = 2: PMX%% = P.WorldX: PMY%% = P.WorldY
    Copy_Map_Layer Layer(L%%), PMX%% + WX%%, PMY%% + WY%%
    ClearLayerTrans Layer(8)
    Display_Chests Layer(8)
    Display_Doors Layer(8)
    Draw_NPC_Sprites 119, Layer(8) 'draw the NPCs throughout the world
    Copy_NPC_Layer Layer(8), PMX%% + WX%%, PMY%% + WY%%
    Draw_Player_Sprite Layer(1)
    IF P.Map >= 0 THEN _PUTIMAGE , Layer(11), Layer(1)
    IF G.Display_Status THEN Draw_Stat_Window Layer(1)
END SUB

'Draw Sprite Routines---------------------------------------
SUB Draw_Player_Sprite (L&)
    IF P.Weapon > 0 AND P.Shield > 16 THEN 'pick which sprite set to use
        Y1%% = 3 'has a shield and weapon
    ELSEIF P.Weapon THEN
        Y1%% = 1 'only has weapon
    ELSEIF P.Shield > 16 THEN 'No sheild is 16
        Y1%% = 2 'on has shield
    ELSE
        Y1%% = 0 'has nothing
    END IF
    IF P.Armor > 8 THEN Y1%% = Y1%% + 4 'player has armor
    IF P.Has_Princess THEN Y1%% = 8 'if player is returning princess over-ride tile set

    SX% = 3 + (Frame%% * 16) + (P.Facing * 32)
    SY% = 4 + (Y1%% * 18)
    _PUTIMAGE (256, 224)-STEP(31, 31), Layer(4), L&, (SX%, SY%)-STEP(15, 15)
END SUB

SUB Draw_NPC_Sprites (Count%%, L&)
    FOR i%% = 0 TO Count%%
        IF NOT NPC(i%%).Done THEN 'should the NPC's sprite be draw or are we done with them
            IF P.Map = NPC(i%%).Map THEN
                IF i%% <> 1 AND i%% <> 119 THEN
                    SX% = 3 + (Frame%% * 16) + (NPC(i%%).Facing * 32)
                    SY% = 4 + (NPC(i%%).Sprite_ID * 18)
                    _PUTIMAGE (NPC(i%%).X * 32 + NPC(i%%).MX, NPC(i%%).Y * 32 + NPC(i%%).MY)-STEP(31, 31), Layer(4), L&, (SX%, SY%)-STEP(15, 15)
                ELSEIF i%% = 1 AND (F.Saved_Princess OR P.Princess_Saved) THEN
                    SX% = 3 + (Frame%% * 16) + (NPC(i%%).Facing * 32)
                    SY% = 4 + (NPC(i%%).Sprite_ID * 18)
                    _PUTIMAGE (NPC(i%%).X * 32 + NPC(i%%).MX, NPC(i%%).Y * 32 + NPC(i%%).MY)-STEP(31, 31), Layer(4), L&, (SX%, SY%)-STEP(15, 15)
                ELSEIF i%% = 119 AND (NOT F.Dragon_King_Killed) THEN
                    SX% = 3 + (Frame%% * 16) + (NPC(i%%).Facing * 32)
                    SY% = 4 + (NPC(i%%).Sprite_ID * 18)
                    _PUTIMAGE (NPC(i%%).X * 32 + NPC(i%%).MX, NPC(i%%).Y * 32 + NPC(i%%).MY)-STEP(31, 31), Layer(4), L&, (SX%, SY%)-STEP(15, 15)
                END IF
            END IF
        END IF
    NEXT i%%
END SUB

'-----------------------------------------------------------

SUB Process_NPC
    FOR i%% = 0 TO 119
        IF NPC(i%%).Can_Move THEN 'only move NPC that are not stationary
            IF NPC(i%%).Moving THEN NPC_Move_Cycle i%%

            IF Chance < 3 AND NPC(i%%).Moving = 0 THEN 'start the NPC moving
                SELECT CASE NPC(i%%).Facing 'make sure NPC can move that direction
                    CASE UP
                        NPC_Blocked%% = NPC_Collision(i%%, 0, -1)
                    CASE DOWN
                        NPC_Blocked%% = NPC_Collision(i%%, 0, 1)
                    CASE LEFT
                        NPC_Blocked%% = NPC_Collision(i%%, -1, 0)
                    CASE RIGHT
                        NPC_Blocked%% = NPC_Collision(i%%, 1, 0)
                END SELECT
                IF NOT NPC_Blocked%% THEN NPC_Move_Cycle i%%
            END IF

            IF Chance < 3 AND NPC(i%%).Moving = 0 THEN Turn_NPC i%%
        END IF
        IF NPC(i%%).X = 0 THEN i%% = 122 'reached the end of NPC list
    NEXT i%%
END SUB

SUB NPC_Move_Cycle (who%%)
    NPC(who%%).Moving = NPC(who%%).Moving + 2
    IF NPC(who%%).Moving = 32 THEN Move_NPC who%%: NPC(who%%).Moving = 0
    SELECT CASE NPC(who%%).Facing
        CASE UP
            NPC(who%%).MY = -NPC(who%%).Moving
        CASE RIGHT
            NPC(who%%).MX = NPC(who%%).Moving
        CASE LEFT
            NPC(who%%).MX = -NPC(who%%).Moving
        CASE DOWN
            NPC(who%%).MY = NPC(who%%).Moving
    END SELECT
END SUB

SUB Move_NPC (who%%)
    SELECT CASE NPC(who%%).Facing
        CASE UP
            NPC(who%%).Y = NPC(who%%).Y - 1
        CASE DOWN
            NPC(who%%).Y = NPC(who%%).Y + 1
        CASE LEFT
            NPC(who%%).X = NPC(who%%).X - 1
        CASE RIGHT
            NPC(who%%).X = NPC(who%%).X + 1
    END SELECT
END SUB

SUB Turn_NPC (who%%)
    T~%% = Chance
    SELECT CASE T~%%
        CASE 0 TO 63
            NPC(who%%).Facing = UP
        CASE 64 TO 127
            NPC(who%%).Facing = DOWN
        CASE 128 TO 191
            NPC(who%%).Facing = LEFT
        CASE 192 TO 255
            NPC(who%%).Facing = RIGHT
    END SELECT
END SUB

FUNCTION NPC_Collision%% (Who%%, X%%, Y%%)
    Result%% = TRUE
    SELECT CASE Place(NPC(Who%%).Map, NPC(Who%%).X + X%%, NPC(Who%%).Y + Y%%).Sprite_ID
        CASE 0 TO 13
            Result%% = FALSE
    END SELECT

    'check for door collision
    FOR i%% = 0 TO 16
        IF Doors(i%%).Map = NPC(Who%%).Map THEN 'is door on same map
            IF Doors(i%%).X = NPC(Who%%).X + X%% AND Doors(i%%).Y = NPC(Who%%).Y + Y%% THEN 'is door in way of NPC
                IF Doors(i%%).Opened THEN 'is door open?
                    Result%% = FALSE
                ELSE 'door is shut
                    Result%% = TRUE
                    i%% = 18
                END IF
            END IF
        END IF
    NEXT i%%

    'dont let NPC leave map
    IF Place(NPC(Who%%).Map, NPC(Who%%).X + X%%, NPC(Who%%).Y + Y%%).Is_Exit THEN Result%% = TRUE

    IF NOT Result%% THEN 'check for NPC collision
        FOR i%% = 0 TO 119 '<--update when actual NPC count is known
            IF NPC(Who%%).X + X%% = NPC(i%%).X AND NPC(Who%%).Y + Y%% = NPC(i%%).Y AND NPC(Who%%).Map = NPC(i%%).Map THEN
                Result%% = TRUE: i%% = 122
            END IF
            IF NPC(i%%).X = 0 THEN i%% = 122 'no NPC can occupy a 0 location so we know we are past the last NPC
        NEXT i%%
    END IF

    IF NOT Result%% THEN 'check for collision with player
        IF NPC(Who%%).X + X%% = P.MapX AND NPC(Who%%).Y + Y%% = P.MapY AND NPC(Who%%).Map = P.Map THEN Result%% = TRUE
    END IF

    IF NOT Result%% THEN 'now check for collision with NPC blocking tile
        IF Place(NPC(Who%%).Map, NPC(Who%%).X + X%%, NPC(Who%%).Y + Y%%).NPCZone THEN Result%% = TRUE
    END IF

    IF NOT Result%% THEN 'now check for collision with Barrier tile(damage tile)
        IF Place(NPC(Who%%).Map, NPC(Who%%).X + X%%, NPC(Who%%).Y + Y%%).Sprite_ID = 7 THEN Result%% = TRUE
    END IF


    NPC_Collision = Result%%
END FUNCTION

FUNCTION Find_NPC%%
    Result%% = TRUE
    SELECT CASE P.Facing
        CASE UP
            Y%% = -1
        CASE DOWN
            Y%% = 1
        CASE LEFT
            X%% = -1
        CASE RIGHT
            X%% = 1
    END SELECT

    IF P.Map >= 0 THEN 'only check if in a town
        'if there is a "table" sprite between player and NPC then double the search distance
        IF Place(P.Map, P.MapX + X%%, P.MapY + Y%%).Sprite_ID = 33 THEN X%% = X%% * 2: Y%% = Y%% * 2
    END IF

    FOR i%% = 0 TO 119
        IF NPC(i%%).Map = P.Map THEN 'only check NPCs in same place
            IF NPC(i%%).X = P.MapX + X%% AND NPC(i%%).Y = P.MapY + Y%% THEN 'look for NPC infront of player
                Result%% = i%%: i%% = 121
            END IF
        END IF
    NEXT i%%

    IF Result%% = 117 AND NPC(117).Done THEN Result%% = 122 'Wizard in rain shrine Has fufilled his duty and left.

    IF P.Map = 1 AND P.Princess_Saved = FALSE AND Result%% = 1 THEN Result%% = -1 'don't talk to princess in throne room if not saved

    IF P.Map = 11 THEN 'special case for princess when still captured
        IF P.Has_Princess = FALSE AND P.Princess_Saved = FALSE THEN 'make sure player has not saved princess
            IF P.MapX = 23 AND P.MapY = 26 AND P.Facing = UP THEN 'player can only talk to her from below sprite
                Result%% = 120
            END IF
        END IF
    END IF

    IF Result%% = -1 THEN Result%% = 122
    Find_NPC = Result%%
END FUNCTION
SUB Move_Cycle
    STATIC Move AS _BYTE
    Move = Move + 2
    IF Move = 30 THEN Move = 0: G.Flag = FALSE
    SELECT CASE P.Facing
        CASE UP
            G.Y = -Move
        CASE RIGHT
            G.X = Move
        CASE LEFT
            G.X = -Move
        CASE DOWN
            G.Y = Move
    END SELECT
    IF Move = 0 THEN Move_Player
END SUB

SUB Move_Player
    STATIC ArmorHeal AS _BYTE
    IF P.Map >= 0 THEN 'moving player in a town\castle\cave
        SELECT CASE P.Facing
            CASE UP
                P.MapY = P.MapY - 1
            CASE DOWN
                P.MapY = P.MapY + 1
            CASE LEFT
                P.MapX = P.MapX - 1
            CASE RIGHT
                P.MapX = P.MapX + 1
        END SELECT
        Check_Location_Place
    ELSE 'moving player in the overworld
        SELECT CASE P.Facing
            CASE UP
                P.WorldY = P.WorldY - 1
            CASE DOWN
                P.WorldY = P.WorldY + 1
            CASE LEFT
                P.WorldX = P.WorldX - 1
            CASE RIGHT
                P.WorldX = P.WorldX + 1
        END SELECT
        IF G.JustLeft THEN G.JustLeft = FALSE
        IF G.In_Place THEN G.In_Place = FALSE
        Check_Location_World
    END IF
    'special checks when moving---------------------------------------------------
    IF P.Radiant THEN 'player used radiant spell for light so reduce it each step
        P.Radiant = P.Radiant - 1
        IF P.Radiant = 120 OR P.Radiant = 60 OR P.Radiant = 0 THEN Create_Light_Mask
    END IF
    IF P.Is_Repel >= 0 THEN 'player use Repel or Fairy water to keep weak monsters away.
        P.Is_Repel = P.Is_Repel - 1
    END IF
    IF P.Armor = 14 AND P.HP < P.Max_HP THEN 'magic armor heals every other step if needed
        ArmorHeal = ArmorHeal + 1
        IF ArmorHeal MOD 2 THEN P.HP = P.HP + 1
    END IF
    IF P.Armor = 15 AND P.HP < P.Max_HP THEN 'Erdrick's armor heals every step if needed
        P.HP = P.HP + 2
        IF P.HP > P.Max_HP THEN P.HP = P.Max_HP
    END IF
    '----------------------------------------------------------------------------

    IF P.HP = 0 THEN
        null%% = Message_Handler(Layer(15), 369) 'Player is Dead
        'return to king, loose 50% gold
        Death_Return 'move the player back to the throne room and take half gold
    END IF
END SUB

SUB Check_Location_World
    IF World(P.WorldX, P.WorldY).Is_Town AND G.In_Place = FALSE THEN
        P.Map = World(P.WorldX, P.WorldY).Is_Town
        Fade_Out Layer(1)
        IF P.Map = 1 THEN P.Map = 0
        P.MapX = PD(P.Map).Start_X
        P.MapY = PD(P.Map).Start_Y
        Build_Place_Layer Layer(7), P.Map
        Build_Screen
        Fade_In Layer(1)
        Change_BGM
        G.In_Place = TRUE
    ELSE
        IF NOT F.Dragon_King_Killed THEN 'the land is clear after he dies
            '----------check for enemy encounter-------------
            IF World(P.WorldX, P.WorldY).Territory = 0 THEN Zadj%% = 2 ELSE Zadj%% = 1 'Zone Adjustment. zone 0 rates are halfed
            IF NChance(World(P.WorldX, P.WorldY).Encounter_rate * Zadj%%) < ENCOUNTER_VALUE * Zadj%% THEN 'We have a encounter chance
                G.Battle = Pick_Battle(World(P.WorldX, P.WorldY).Territory)
                IF G.Battle <> -2 THEN
                    IF P.Is_Repel >= 0 THEN 'has player used Fairy water or the Repel Spell?
                        IF M(G.Battle).Strength <= (P.Agility \ 2) THEN G.Battle = -1 'monster was to week to break spell
                    END IF
                ELSE 'player found a few gold!
                    G.Battle = -1
                END IF
            END IF
            '------------------------------------------------
        END IF
    END IF

    IF World(P.WorldX, P.WorldY).Sprite_ID = 5 THEN _DELAY .05 'slow movement when crossing hills

    IF World(P.WorldX, P.WorldY).Sprite_ID = 6 AND P.Armor <> 15 THEN
        Screen_Flash_Damage
        IF NOT _SNDPLAYING(SFX(17)) THEN _SNDPLAY SFX(17)
        test% = P.HP - 2 'damage player when walking in marsh with out edricks armor
        IF test% <= 0 THEN P.HP = 0 ELSE P.HP = P.HP - 2
    END IF

    IF World(P.WorldX, P.WorldY).Has_Special = 2 AND (NOT F.Defeated_Golem) THEN 'Golem attack
        IF Battle(24) THEN 'fight the Golem
            F.Defeated_Golem = TRUE
            World(P.WorldX, P.WorldY).Has_Special = 0 'turn off speical after defeating Golem
        ELSE
            P.WorldY = P.WorldY - 1 ' move player back 1 space has to fight golem again
        END IF
    END IF

    IF World(P.WorldX, P.WorldY).Is_Cave THEN Run_Stairs

END SUB

SUB Check_Location_Place
    'automated checks
    IF Place(P.Map, P.MapX, P.MapY).Is_Exit THEN
        Fade_Out Layer(1)
        P.Map = -1: G.JustLeft = TRUE
        Remove_light_mask
        Build_Screen
        Fade_In Layer(1)
        Change_BGM: Reset_Chests: Reset_Doors
        P.Torched = FALSE 'torch and radiant go out when you enter overworld
        P.Radiant = FALSE
    ELSE

        IF Place(P.Map, P.MapX, P.MapY).Has_Special = 3 AND (NOT F.Defeated_Green_Dragon) THEN 'Green Dragon Fight
            _PUTIMAGE , Layer(1), Layer(5)
            IF Battle(30) THEN 'fight the green dragon
                F.Defeated_Green_Dragon = TRUE
            ELSE
                P.MapY = P.MapY - 1 ' move player back 1 space has to fight green dragon again
            END IF
        END IF

        IF Place(P.Map, P.MapX, P.MapY).Has_Special = 99 AND (NOT F.Defeated_Axe_Knight) THEN 'Axe Knight Fight
            _PUTIMAGE , Layer(1), Layer(5)
            IF Battle(33) THEN 'fight the green dragon
                F.Defeated_Axe_Knight = TRUE
            ELSE
                P.MapX = P.MapX - 1 ' move player back 1 space has to fight green dragon again
            END IF
        END IF

        IF Place(P.Map, P.MapX, P.MapY).Sprite_ID = 7 AND P.Armor <> 15 THEN
            test% = P.HP - 15 'damage player when walking over barrior
            Screen_Flash_Damage
            IF NOT _SNDPLAYING(SFX(16)) THEN _SNDPLAY SFX(16)
            IF test% <= 0 THEN P.HP = 0 ELSE P.HP = P.HP - 15
        END IF

        IF Place(P.Map, P.MapX, P.MapY).Is_Entrance THEN Enter_Building Place(P.Map, P.MapX, P.MapY).Is_Entrance
        IF Place(P.Map, P.MapX, P.MapY).Building_Exit THEN Exit_Building Place(P.Map, P.MapX, P.MapY).Building_Exit

        IF F.Dragon_King_Killed THEN 'Final Talk with king.. then game over.
            IF P.Map = 0 THEN
                IF (P.MapX = 18 OR P.MapX = 19) AND P.MapY = 16 THEN NPC_Talk 124
            END IF
        END IF

        IF NOT F.Dragon_King_Killed THEN 'the land is clear after he dies
            '----------check for enemy encounter-------------
            IF Place(P.Map, P.MapX, P.MapY).Territory > 0 THEN 'no Place map with encounters has a Territory of 0
                IF Chance < 8 * 4 THEN 'We have a encounter chance, places have a standard chance of battle for all tiles. 8/64ths (32/256)
                    G.Battle = Pick_Battle(Place(P.Map, P.MapX, P.MapY).Territory)
                    IF P.Is_Repel >= 0 THEN 'has player used Fairy water or the Repel Spell?
                        IF M(G.Battle).Strength <= (P.Agility \ 2) THEN G.Battle = -1 'monster was to week to break spell
                    END IF
                END IF
            END IF
            '------------------------------------------------
        END IF
    END IF

END SUB

FUNCTION Collision%% (X%%, Y%%)
    Result%% = TRUE
    IF P.Map >= 0 THEN 'check place map
        SELECT CASE Place(P.Map, P.MapX + X%%, P.MapY + Y%%).Sprite_ID
            CASE 0 TO 13
                Result%% = FALSE
            CASE ELSE
                'IF NOT _SNDPLAYING(SFX(0)) THEN _SNDPLAY SFX(0)
        END SELECT

        IF G.In_Building AND Result%% THEN 'give a check for the Building_Exit tile
            IF Place(P.Map, P.MapX + X%%, P.MapY + Y%%).Building_Exit THEN Result%% = FALSE
        END IF

        IF Place(P.Map, P.MapX + X%%, P.MapY + Y%%).Is_Entrance THEN Result%% = FALSE 'check for building entrance

        IF NOT Result%% THEN 'check for NPC collision
            FOR i%% = 0 TO 120 '<--update when actual NPC count is known
                IF P.MapX + X%% = NPC(i%%).X AND P.MapY + Y%% = NPC(i%%).Y AND P.Map = NPC(i%%).Map THEN
                    'Make sure its not an NPC that has fufilled his duty.
                    IF NOT NPC(i%%).Done THEN Result%% = TRUE: i%% = 122
                END IF
                IF NPC(i%%).X = 0 THEN i%% = 122 'no NPC can occupy a 0 location so we know we are past the last NPC
            NEXT i%%
        END IF

        'check for door collision
        FOR i%% = 0 TO DOOR_COUNT - 1
            IF Doors(i%%).Map = P.Map THEN 'is door on same map
                IF Doors(i%%).X = P.MapX + X%% AND Doors(i%%).Y = P.MapY + Y%% THEN 'is door in way of player
                    IF Doors(i%%).Opened THEN 'is door open?
                        Result%% = FALSE
                    ELSE 'door is shut
                        Result%% = TRUE
                    END IF
                    i%% = DOOR_COUNT + 1
                END IF
            END IF
        NEXT i%%
        IF Result%% THEN
            IF NOT _SNDPLAYING(SFX(0)) THEN _SNDPLAY SFX(0)
        END IF
    ELSE 'check world map
        SELECT CASE World(P.WorldX + X%%, P.WorldY + Y%%).Sprite_ID
            CASE 0 TO 13
                Result%% = FALSE
            CASE ELSE
                IF NOT _SNDPLAYING(SFX(0)) THEN _SNDPLAY SFX(0)
        END SELECT
    END IF
    Collision = Result%%
END FUNCTION

SUB Enter_Building (id%%)
    P.Map = Entrance(id%%).Link
    Build_Place_Layer Layer(7), P.Map
    G.In_Building = TRUE
END SUB

SUB Exit_Building (id%%)
    P.Map = Entrance(id%%).Link
    Build_Place_Layer Layer(7), P.Map
    G.In_Building = FALSE
END SUB

SUB Fade_Out (L&)
    FOR n! = 1 TO 0.00 STEP -0.05
        i2& = _COPYIMAGE(L&)
        DarkenImage i2&, n!
        _PUTIMAGE (0, 0), i2&
        _FREEIMAGE i2&
        _DELAY .03
    NEXT
END SUB

SUB Fade_In (L&)
    FOR n! = 0.01 TO 1 STEP 0.05
        i2& = _COPYIMAGE(L&)
        DarkenImage i2&, n!
        _PUTIMAGE (0, 0), i2&
        _FREEIMAGE i2&
        _DELAY .03
    NEXT
END SUB

SUB DarkenImage (Image AS LONG, Value_From_0_To_1 AS SINGLE)
    IF Value_From_0_To_1 <= 0 OR Value_From_0_To_1 >= 1 OR _PIXELSIZE(Image) <> 4 THEN EXIT SUB
    DIM Buffer AS _MEM: Buffer = _MEMIMAGE(Image) 'Get a memory reference to our image
    DIM Frac_Value AS LONG: Frac_Value = Value_From_0_To_1 * 65536 'Used to avoid slow floating point calculations
    DIM O AS _OFFSET, O_Last AS _OFFSET
    O = Buffer.OFFSET 'We start at this offset
    O_Last = Buffer.OFFSET + _WIDTH(Image) * _HEIGHT(Image) * 4 'We stop when we get to this offset
    'use on error free code ONLY!
    '$CHECKING:OFF
    DO
        _MEMPUT Buffer, O, _MEMGET(Buffer, O, _UNSIGNED _BYTE) * Frac_Value \ 65536 AS _UNSIGNED _BYTE
        _MEMPUT Buffer, O + 1, _MEMGET(Buffer, O + 1, _UNSIGNED _BYTE) * Frac_Value \ 65536 AS _UNSIGNED _BYTE
        _MEMPUT Buffer, O + 2, _MEMGET(Buffer, O + 2, _UNSIGNED _BYTE) * Frac_Value \ 65536 AS _UNSIGNED _BYTE
        O = O + 4
    LOOP UNTIL O = O_Last
    'turn checking back on when done!
    '$CHECKING:ON
    _MEMFREE Buffer
END SUB
SUB Get_JoyPads
    'load input device details Max:16
    G.Device_Count = _DEVICES
    IF G.Device_Count > 16 THEN G.Device_Count = 16 'limit total devices to 16
    FOR I%% = 1 TO G.Device_Count
        DeviceData(I%%).Buttons = _LASTBUTTON(I%%) ' number of buttons on the device
        DeviceData(I%%).Axis_p = _LASTAXIS(I%%) 'number of axis on the device
    NEXT I%%
END SUB

SUB Build_Custom_Control_Screen
    _PRINTMODE _KEEPBACKGROUND , Layer(1)
    'setup custom controls screen
    _PUTIMAGE (40, 32), Layer(10), Layer(0)
    'up arrow
    LINE (128, 128)-(32, 132), _RGB32(255, 127, 0), BF
    LINE (32, 132)-(36, 460), _RGB32(255, 127, 0), BF
    LINE (32, 460)-(212, 464), _RGB32(255, 127, 0), BF
    'left arrow
    LINE (92, 160)-(48, 164), _RGB32(92, 192, 0), BF
    LINE (48, 164)-(52, 416), _RGB32(92, 192, 0), BF
    LINE (48, 416)-(240, 420), _RGB32(92, 192, 0), BF
    'down arrow
    LINE (128, 212)-(64, 216), _RGB32(0, 127, 255), BF
    LINE (64, 216)-(68, 372), _RGB32(0, 127, 255), BF
    LINE (64, 372)-(256, 376), _RGB32(0, 127, 255), BF
    'right arrow
    LINE (176, 184)-(180, 240), _RGB32(0, 64, 160), BF
    LINE (80, 240)-(180, 244), _RGB32(0, 64, 160), BF
    LINE (80, 244)-(84, 326), _RGB32(0, 64, 160), BF
    LINE (80, 326)-(260, 330), _RGB32(0, 64, 160), BF
    'select
    LINE (264, 212)-(268, 460), _RGB32(255, 64, 0), BF
    LINE (264, 460)-(416, 464), _RGB32(255, 64, 0), BF
    'start
    LINE (328, 212)-(332, 416), _RGB32(212, 0, 16), BF
    LINE (328, 416)-(496, 420), _RGB32(212, 0, 16), BF
    'B Button
    LINE (426, 208)-(430, 256), _RGB32(64, 92, 212), BF
    LINE (340, 256)-(430, 260), _RGB32(64, 92, 212), BF
    LINE (340, 260)-(344, 376), _RGB32(64, 92, 212), BF
    LINE (340, 372)-(496, 376), _RGB32(64, 92, 212), BF
    'A Button
    LINE (496, 208)-(500, 272), _RGB32(80, 64, 180), BF
    LINE (356, 272)-(500, 276), _RGB32(80, 64, 180), BF
    LINE (356, 272)-(360, 328), _RGB32(80, 64, 180), BF
    LINE (356, 328)-(528, 332), _RGB32(80, 64, 180), BF
    'setup click layer  40,32 offset
    _DEST Layer(21)
    LINE (120, 124)-STEP(35, 30), _RGB(1, 0, 0), BF 'up
    LINE (120, 190)-STEP(35, 30), _RGB(2, 0, 0), BF 'down
    LINE (88, 158)-STEP(35, 30), _RGB(3, 0, 0), BF 'left
    LINE (156, 158)-STEP(35, 30), _RGB(4, 0, 0), BF 'right

    LINE (238, 192)-STEP(45, 20), _RGB(5, 0, 0), BF 'Select
    LINE (308, 192)-STEP(45, 20), _RGB(6, 0, 0), BF 'Start

    LINE (398, 172)-STEP(58, 60), _RGB(7, 0, 0), BF 'Button A
    LINE (468, 172)-STEP(58, 60), _RGB(8, 0, 0), BF 'Button B

    _PRINTSTRING (0, 0), "Click on the controller button you wish to customize, Press the new key.", Layer(0)
    _PRINTSTRING (0, 16), "Tab to switch Control type. When done click EXIT when done.", Layer(0)
    _PRINTSTRING (0, 32), "With a JOYPAD: TYPE I-use axis for movement, TYPE II-use buttons to move.", Layer(0)
    _PUTIMAGE , Layer(0), Layer(5)
    _PRINTMODE _FILLBACKGROUND , Layer(1)
END SUB

SUB Highlite_Select (ID%%)
    STATIC Factor%%
    IF ID%% THEN Factor%% = Factor%% + 16 'mouse over highlight color shift
    IF Factor%% >= 120 THEN Factor%% = 0
    SELECT CASE ID%% 'highlight which control mouse is over.
        CASE 1 'up
            LINE (32, 460)-(212, 464), _RGB32(255 - Factor%%, 127 + Factor%%, 0 + Factor%%), BF
        CASE 2 'down
            LINE (64, 372)-(256, 376), _RGB32(0 + Factor%%, 127 - Factor%%, 255 - Factor%%), BF
        CASE 3 'left
            LINE (48, 416)-(240, 420), _RGB32(92 + Factor%%, 192 - Factor%%, 0 + Factor%%), BF
        CASE 4 'right
            LINE (80, 326)-(260, 330), _RGB32(0 + Factor%%, 64 + Factor%%, 160 - Factor%%), BF
        CASE 5 'select
            LINE (264, 460)-(416, 464), _RGB32(255 - Factor%%, 64 + Factor%%, 0 - Factor%%), BF
        CASE 6 'start
            LINE (328, 416)-(496, 420), _RGB32(212 - Factor%%, 0 + Factor%%, 16 + Factor%%), BF
        CASE 7 'B
            LINE (340, 372)-(496, 376), _RGB32(64 + Factor%%, 92 + Factor%%, 212 - Factor%%), BF
        CASE 8 'A
            LINE (356, 328)-(528, 332), _RGB32(80 + Factor%%, 64 + Factor%%, 180 - Factor%%), BF
    END SELECT
END SUB

SUB Display_Keys (ID%%)
    IF ID%% THEN
        _PRINTSTRING (232, 76), "Keyboard"
        _PRINTSTRING (64, 440), ControlName(C.KBCon_Up)
        _PRINTSTRING (96, 352), ControlName(C.KBCon_Down)
        _PRINTSTRING (80, 396), ControlName(C.KBCon_Left)
        _PRINTSTRING (112, 308), ControlName(C.KBCon_Right)
        _PRINTSTRING (388, 308), ControlName(C.KBCon_A_Button)
        _PRINTSTRING (370, 352), ControlName(C.KBCon_B_Button)
        _PRINTSTRING (296, 440), ControlName(C.KBCon_Select)
        _PRINTSTRING (364, 396), ControlName(C.KBCon_Start)
    ELSE
        _PRINTSTRING (232, 76), "JoyPad-" + LTRIM$(STR$(C.Control_Pad))
        IF NOT C.BAD_Pad THEN
            IF C.Joy_Up = -22 THEN
                _PRINTSTRING (64, 440), "UnDefined"
            ELSE
                IF C.Joy_Up_Val < 0 THEN a$ = " -" ELSE a$ = " +"
                _PRINTSTRING (64, 440), "Axis:" + STR$(C.Joy_Up) + a$
            END IF
            IF C.Joy_Down = -22 THEN
                _PRINTSTRING (96, 352), "UnDefined"
            ELSE
                IF C.Joy_Down_Val < 0 THEN a$ = " -" ELSE a$ = " +"
                _PRINTSTRING (96, 352), "Axis:" + STR$(C.Joy_Down) + a$
            END IF
            IF C.Joy_Left = -22 THEN
                _PRINTSTRING (80, 396), "UnDefined"
            ELSE
                IF C.Joy_Left_Val < 0 THEN a$ = " -" ELSE a$ = " +"
                _PRINTSTRING (80, 396), "Axis:" + STR$(C.Joy_Left) + a$
            END IF
            IF C.Joy_Right = -22 THEN
                _PRINTSTRING (112, 308), "UnDefined"
            ELSE
                IF C.Joy_Right_Val < 0 THEN a$ = " -" ELSE a$ = " +"
                _PRINTSTRING (112, 308), "Axis:" + STR$(C.Joy_Right) + a$
            END IF
        ELSE
            IF C.Joy_Button_Up = -22 THEN
                _PRINTSTRING (64, 440), "UnDefined"
            ELSE
                _PRINTSTRING (64, 440), "Button:" + STR$(C.Joy_Button_Up) + a$
            END IF
            IF C.Joy_Button_Down = -22 THEN
                _PRINTSTRING (96, 352), "UnDefined"
            ELSE
                _PRINTSTRING (96, 352), "Button:" + STR$(C.Joy_Button_Down) + a$
            END IF
            IF C.Joy_Button_Left = -22 THEN
                _PRINTSTRING (80, 396), "UnDefined"
            ELSE
                _PRINTSTRING (80, 396), "Button:" + STR$(C.Joy_Button_Left) + a$
            END IF
            IF C.Joy_Button_Right = -22 THEN
                _PRINTSTRING (112, 308), "UnDefined"
            ELSE
                _PRINTSTRING (112, 308), "Button:" + STR$(C.Joy_Button_Right) + a$
            END IF
        END IF
        IF C.Joy_Select = -22 THEN _PRINTSTRING (296, 440), "UnDefined" ELSE _PRINTSTRING (296, 440), "Button:" + STR$(C.Joy_Select)
        IF C.Joy_Start = -22 THEN _PRINTSTRING (364, 396), "UnDefined" ELSE _PRINTSTRING (364, 396), "Button:" + STR$(C.Joy_Start)
        IF C.Joy_A_Button = -22 THEN _PRINTSTRING (388, 308), "UnDefined" ELSE _PRINTSTRING (388, 308), "Button:" + STR$(C.Joy_A_Button)
        IF C.Joy_B_Button = -22 THEN _PRINTSTRING (370, 352), "UnDefined" ELSE _PRINTSTRING (370, 352), "Button:" + STR$(C.Joy_B_Button)
    END IF
END SUB

FUNCTION Display_Exit_Controls%% (X%, Y%)
    IF X% > 540 AND X% < 620 AND Y% > 390 AND Y% < 425 THEN
        LINE (540, 390)-STEP(80, 35), _RGB32(255, 32, 8), BF
        _PRINTSTRING (550, 400), "EXIT", Layer(1)
        Result%% = TRUE
    ELSE
        LINE (540, 390)-STEP(80, 35), _RGB32(160, 72, 16), BF
        _PRINTSTRING (550, 400), "EXIT", Layer(1)
        Result%% = FALSE
    END IF
    Display_Exit_Controls = Result%%
END FUNCTION

SUB Display_BAD_Controller_Option
    IF C.BAD_Pad THEN
        LINE (500, 440)-STEP(130, 35), _RGB32(255, 16, 8), BF
        _PRINTSTRING (510, 450), "TYPE II", Layer(1)
        Result%% = TRUE
    ELSE
        LINE (500, 440)-STEP(130, 35), _RGB32(16, 72, 240), BF
        _PRINTSTRING (520, 450), "TYPE I", Layer(1)
        Result%% = FALSE
    END IF
END SUB

FUNCTION ControlName$ (id&)
    Result$ = "#ERROR#"
    FOR i~%% = 0 TO 133
        IF KeyCodes(i~%%).Value = id& THEN Result$ = KeyCodes(i~%%).Nam: i~%% = 135
    NEXT i~%%
    IF i~%% = 134 THEN Result$ = "Unknown#"
    ControlName = Result$
END FUNCTION

SUB Set_KeyBoard_Control (Master%%, KBD&)
    SELECT CASE Master%%
        CASE 1 'Up arrow
            IF KBD& THEN C.KBCon_Up = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 2 'down arrow
            IF KBD& THEN C.KBCon_Down = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 3 'left arrow
            IF KBD& THEN C.KBCon_Left = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 4 'right arrow
            IF KBD& THEN C.KBCon_Right = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 5 'select
            IF KBD& THEN C.KBCon_Select = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 6 'start
            IF KBD& THEN C.KBCon_Start = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 7 'b
            IF KBD& THEN C.KBCon_B_Button = KBD&: Master%% = FALSE 'unlock selection with key press
        CASE 8 'a
            IF KBD& THEN C.KBCon_A_Button = KBD&: Master%% = FALSE 'unlock selection with key press
    END SELECT
END SUB

FUNCTION Device_Name$ (ID%%)
    Result$ = "Error"
    Temp$ = _DEVICE$(ID%%)
    Start%% = INSTR(Temp$, "NAME") + 6
    Ends%% = INSTR(INSTR(Temp$, "NAME") + 6, Temp$, "]") - 1
    Result$ = MID$(Temp$, Start%%, Ends%% - Start%%)
    Device_Name = Result$
END FUNCTION

SUB Custom_Controls
    ClearLayer Layer(0)
    ClearLayer Layer(5)
    Build_Custom_Control_Screen
    _DEST Layer(1)
    _SOURCE Layer(21)
    DO

        KBD& = _KEYHIT
        IF KBD& < 0 THEN KBD& = 0 'handle button up `-` codes

        IF (NOT G.ControlType) AND Master%% THEN
            Nul%% = _DEVICEINPUT(C.Control_Pad)
            IF NOT C.BAD_Pad THEN
                IF Master%% > 4 THEN
                    FOR i%% = 1 TO _LASTBUTTON(C.Control_Pad)
                        IF _BUTTON(i%%) THEN Bselect%% = i%%: i%% = _LASTBUTTON(C.Control_Pad) + 1
                    NEXT i%%
                ELSE
                    FOR i%% = 1 TO _LASTAXIS(C.Control_Pad)
                        test%% = _AXIS(i%%)
                        IF test%% THEN Aselect%% = i%%: i%% = _LASTAXIS(C.Control_Pad)
                    NEXT i%%
                END IF
            ELSE
                FOR i%% = 1 TO _LASTBUTTON(C.Control_Pad)
                    IF _BUTTON(i%%) THEN Bselect%% = i%%: i%% = _LASTBUTTON(C.Control_Pad) + 1
                NEXT i%%
            END IF
        END IF

        _PUTIMAGE , Layer(5), Layer(1)
        Nul%% = _MOUSEINPUT
        X% = _MOUSEX: Y% = _MOUSEY
        Selection%% = _RED32(POINT(X%, Y%)) 'is mouse over anything?

        IF Master%% THEN Selection%% = Master%% 'keep selection locked until key press

        IF _MOUSEBUTTON(1) THEN
            IF NOT Master%% THEN Master%% = Selection%% 'if no Master selection set then set it.
            IF ExitSet%% THEN ExitFlag%% = TRUE
            IF X% > 500 AND X% < 630 AND Y% > 440 AND Y% < 475 THEN C.BAD_Pad = NOT C.BAD_Pad 'toggle controller directional type
            DO: nul% = _MOUSEINPUT: LOOP WHILE _MOUSEBUTTON(1)
        END IF

        IF Master%% AND G.ControlType THEN 'once player clicks and controller is Keyboard
            IF KBD& <> ESC_Key THEN
                Set_KeyBoard_Control Master%%, KBD&
            END IF
        ELSEIF Master%% AND (NOT G.ControlType) THEN 'once player clicks and controller is Joy Pad
            SELECT CASE Master%%
                CASE 1 'Up arrow
                    IF Aselect%% THEN
                        C.Joy_Up = Aselect%%
                        IF test%% < 0 THEN C.Joy_Up_Val = TRUE ELSE C.Joy_Up_Val = 1
                        Master%% = FALSE 'unlock selection with button press
                        Aselect%% = 0
                    ELSEIF Bselect%% AND C.BAD_Pad THEN
                        C.Joy_Button_Up = Bselect%%
                        Master%% = FALSE 'unlock selection with button press
                        Bselect%% = 0
                    END IF
                CASE 2 'Down arrow
                    IF Aselect%% THEN
                        C.Joy_Down = Aselect%%
                        IF test%% < 0 THEN C.Joy_Down_Val = TRUE ELSE C.Joy_Down_Val = 1
                        Master%% = FALSE 'unlock selection with button press
                        Aselect%% = 0
                    ELSEIF Bselect%% AND C.BAD_Pad THEN
                        C.Joy_Button_Down = Bselect%%
                        Master%% = FALSE 'unlock selection with button press
                        Bselect%% = 0
                    END IF
                CASE 3 'left arrow
                    IF Aselect%% THEN
                        C.Joy_Left = Aselect%%
                        IF test%% < 0 THEN C.Joy_Left_Val = TRUE ELSE C.Joy_Left_Val = 1
                        Master%% = FALSE 'unlock selection with button press
                        Aselect%% = 0
                    ELSEIF Bselect%% AND C.BAD_Pad THEN
                        C.Joy_Button_Left = Bselect%%
                        Master%% = FALSE 'unlock selection with button press
                        Bselect%% = 0
                    END IF
                CASE 4 'right arrow
                    IF Aselect%% THEN
                        C.Joy_Right = Aselect%%
                        IF test%% < 0 THEN C.Joy_Right_Val = TRUE ELSE C.Joy_Right_Val = 1
                        Master%% = FALSE 'unlock selection with button press
                        Aselect%% = 0
                    ELSEIF Bselect%% AND C.BAD_Pad THEN
                        C.Joy_Button_Right = Bselect%%
                        Master%% = FALSE 'unlock selection with button press
                        Bselect%% = 0
                    END IF
                CASE 5 'select
                    IF Bselect%% THEN C.Joy_Select = Bselect%%: Master%% = FALSE 'unlock selection with button press
                    Bselect%% = 0
                CASE 6 'start
                    IF Bselect%% THEN C.Joy_Start = Bselect%%: Master%% = FALSE 'unlock selection with button press
                    Bselect%% = 0
                CASE 7 'b
                    IF Bselect%% THEN C.Joy_B_Button = Bselect%%: Master%% = FALSE 'unlock selection with button press
                    Bselect%% = 0
                CASE 8 'a
                    IF Bselect%% THEN C.Joy_A_Button = Bselect%%: Master%% = FALSE 'unlock selection with button press
                    Bselect%% = 0
            END SELECT

        END IF

        IF KBD& = 9 THEN G.ControlType = NOT G.ControlType
        IF (NOT G.ControlType) AND C.Control_Pad = 0 THEN 'setup joy pad
            IF G.Device_Count <= 2 THEN 'is there a joy pad to use?
                Draw_Window 5, 7, 25, 3, Layer(1)
                _PRINTSTRING (16 * 6, 16 * 8), " NO OTHER DEVICE FOUND"
                _PRINTSTRING (16 * 12, 16 * 9 + 2), " PRESS TAB"
            ELSE
                Select_Device
            END IF
        END IF

        'Screen Updating
        Display_Keys G.ControlType
        Highlite_Select Selection%%
        ExitSet%% = Display_Exit_Controls(X%, Y%)
        IF NOT G.ControlType THEN Display_BAD_Controller_Option
        '---------------------------------------------------------------------------------------------------------
        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 30
        DO: LOOP WHILE _MOUSEINPUT
        IF (NOT G.ControlType) THEN DO: LOOP WHILE _DEVICEINPUT(C.Control_Pad)

    LOOP UNTIL ExitFlag%%

    _DEST Layer(0)
    _SOURCE Layer(0)
    'ClearlayerADV Layer(5)
    ClearLayerTrans Layer(5)
END SUB

SUB Select_Device
    'removing the first 2 devices, assuming keyboard=1 and mouse=2
    IF G.Device_Count > 3 THEN
        DO
            KBD$ = INKEY$
            _PUTIMAGE , Layer(5), Layer(1)
            Draw_Window 4, 7, 30, 1 + (G.Device_Count - 2) * 2, Layer(1)
            FOR i%% = 3 TO G.Device_Count
                temp$ = Device_Name$(i%%)
                _PRINTSTRING (16 * 12 - LEN(temp$) \ 2, 16 * (8 + (i%% - 3))), LTRIM$(STR$(i%%)) + "-" + temp$
            NEXT i%%
            _PRINTSTRING (16 * 6 + 8, 16 * (8 + (i%% - 3)) + 2), "Press Number of controller"
            _PUTIMAGE , Layer(1), Layer(0)
            _LIMIT 30
            IF VAL(KBD$) > 2 AND VAL(KBD$) <= G.Device_Count THEN C.Control_Pad = VAL(KBD$): ExitFlag%% = TRUE
            IF KBD$ = CHR$(27) THEN CLOSE: END
        LOOP UNTIL ExitFlag%%
    ELSE 'if there is only 1 control device to choose from auto assign
        C.Control_Pad = 3
    END IF
END SUB
SUB INIT
    _FONT DWFont, Layer(15)
    _FONT DWFont, Layer(1)
    _FONT DWFont, Layer(5)
    TIMER(T(0)) ON
    G.TextClick = TRUE
    F.Just_Started = TRUE
    F.PlayClick = FALSE
    G.Battle = TRUE
    G.Input_Wait = TRUE
    _CLEARCOLOR _RGB32(0, 128, 128), Layer(4)
    _CLEARCOLOR _RGB32(0, 0, 0), Layer(14)
    _CLEARCOLOR _RGB32(0, 128, 128), Layer(17)
    'Set Default controls
    C.KBCon_Up = Default_Key_Up
    C.KBCon_Down = Default_Key_Down
    C.KBCon_Left = Default_Key_Left
    C.KBCon_Right = Default_Key_Right
    C.KBCon_Select = Default_Select_Button
    C.KBCon_Start = Default_Start_Button
    C.KBCon_A_Button = Default_A_Button
    C.KBCon_B_Button = Default_B_Button
    C.Joy_Up = -22 'Undefined Joy Pad Controls
    C.Joy_Down = -22 'Undefined
    C.Joy_Left = -22 'Undefined
    C.Joy_Right = -22 'Undefined
    C.Joy_Button_Up = -22 'Undefined Joy Pad Controls
    C.Joy_Button_Down = -22 'Undefined
    C.Joy_Button_Left = -22 'Undefined
    C.Joy_Button_Right = -22 'Undefined
    C.Joy_Select = -22 'Undefined
    C.Joy_Start = -22 'Undefined
    C.Joy_A_Button = -22 'Undefined
    C.Joy_B_Button = -22 'Undefined
    Get_JoyPads 'load posible controller inputs
    IF _FILEEXISTS("DW1CS.CFG") THEN 'if there is an existing config file load it.
        Load_Config
        FOR i%% = -1 TO 15
            _SNDVOL BGM(i%%), G.BGMVol
        NEXT i%%
        _SNDVOL Title, G.BGMVol
        FOR i%% = 0 TO 32
            _SNDVOL SFX(i%%), G.SFXVol
        NEXT i%%
    ELSE
        G.ControlType = TRUE 'keyboard control
        IF G.BGMVol = 0 THEN G.BGMVol = .25 'safety feature!!!
        IF G.SFXVol = 0 THEN G.SFXVol = .25 'safety feature!!!
        _SNDVOL Title, .30
    END IF
    _SNDVOL Starting, 1 'intro sequence music volume.
    G.GameOver_Bad = FALSE
    G.GameOver_Good = FALSE
    G.GameOver_Great = FALSE
END SUB

SUB Start_UP
    Thanks:
    DATA "Fellippe Heitor","Code Hunter","STxAxTIC","Steve McNeill","Luke","KeyBone","Catherine(of YourePerfect.Studio)","The QB64 Team","The VG Resource","Ryan8bit's Formula Guide(GameFaqs.com)","and","Everybody on Discord"
    'http://www.thealmightyguru.com/Wiki/index.php?title=Dragon_Warrior

    IF G.SkipIntro THEN _PRINTSTRING (5, 460), "Press any key to skip when Music starts", Layer(0)
    _DELAY 4 'wait 4 seconds if player has not already seen it
    'Fade out Volume Warning
    Fade_OutS Layer(22), 430, 182, 105, 149
    ClearLayer Layer(1) 'clear the mix layer
    ClearLayer Layer(0) 'clear the screen
    _SNDPLAY Starting 'queue the music!
    RESTORE Thanks
    DO
        IF _SNDGETPOS(Starting) > 2 AND _SNDGETPOS(Starting) < 2.15 THEN Trigger1%% = TRUE 'fade in
        IF _SNDGETPOS(Starting) > 5 AND _SNDGETPOS(Starting) < 5.25 THEN Trigger2%% = TRUE 'fade out
        IF _SNDGETPOS(Starting) > 6.5 AND _SNDGETPOS(Starting) < 6.6 THEN Trigger3%% = TRUE 'fade in
        IF _SNDGETPOS(Starting) > 13 AND _SNDGETPOS(Starting) < 13.20 THEN Trigger4%% = TRUE 'fade out
        IF _SNDGETPOS(Starting) > 14.5 AND _SNDGETPOS(Starting) < 14.70 THEN Trigger5%% = TRUE 'fade in
        IF _SNDGETPOS(Starting) > 17 AND _SNDGETPOS(Starting) < 17.20 THEN Trigger6%% = TRUE 'fade out
        IF _SNDGETPOS(Starting) > 18.2 AND _SNDGETPOS(Starting) < 18.30 THEN Trigger7%% = TRUE 'fade in
        IF _SNDGETPOS(Starting) > 25 AND _SNDGETPOS(Starting) < 25.20 THEN Trigger8%% = TRUE 'fade out
        IF _SNDGETPOS(Starting) > 27.5 AND _SNDGETPOS(Starting) < 27.70 THEN Trigger9%% = TRUE 'fade in

        IF Trigger1%% THEN Fade_InS Layer(23), 626, 64, 7, 180: Trigger1%% = FALSE
        IF Trigger2%% THEN Fade_OutS Layer(23), 626, 64, 7, 180: Trigger2%% = FALSE
        IF Trigger3%% THEN Fade_InS Layer(24), 640, 480, 0, 0: Trigger3%% = FALSE
        IF Trigger4%% THEN Fade_OutS Layer(24), 640, 480, 0, 0: Trigger4%% = FALSE
        IF Trigger5%% THEN Fade_InS Layer(25), 194, 160, 223, 160: Trigger5%% = FALSE
        IF Trigger6%% THEN Fade_OutS Layer(25), 194, 160, 223, 160: Trigger6%% = FALSE
        IF Trigger7%% THEN Fade_InS Layer(26), 640, 292, 0, 94: Trigger7%% = FALSE
        IF Trigger8%% THEN Fade_OutS Layer(26), 640, 292, 0, 94: Trigger8%% = FALSE
        IF Trigger9%% THEN Fade_InS Layer(27), 440, 70, 100, 0: Trigger9%% = FALSE: Trigger10%% = TRUE

        IF Trigger10%% THEN
            READ n$
            LOCATE 6 + offx%%, 40 - LEN(n$) \ 2: PRINT n$
            offx%% = offx%% + 2
            IF offx%% = 24 THEN Trigger10%% = FALSE
            _DELAY 1
        END IF
        IF G.SkipIntro THEN
            _PRINTSTRING (5, 460), "Press any key to skip", Layer(0)
        END IF

        IF _KEYHIT AND G.SkipIntro THEN _SNDSTOP Starting
        _LIMIT 20
    LOOP WHILE _SNDPLAYING(Starting)
    G.SkipIntro = TRUE 'player has watched it.
    _PUTIMAGE , Layer(0), Layer(1)
    Fade_OutS Layer(1), 440, 70, 100, 0
END SUB

SUB Fade_InS (L&, Sx%, Sy%, Lx%, Ly%)
    _DEST Layer(1)
    FOR I~%% = 255 TO 0 STEP -5
        _PUTIMAGE (Lx%, Ly%), L&, Layer(1), (0, 0)-STEP(Sx% - 1, Sy% - 1)
        LINE (0, 0)-STEP(639, 479), _RGBA32(0, 0, 0, I~%%), BF
        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 26
    NEXT I~%%
    _DEST Layer(0)
END SUB

SUB Fade_OutS (L&, Sx%, Sy%, Lx%, Ly%)
    _DEST Layer(1)
    FOR I~%% = 0 TO 255 STEP 5
        _PUTIMAGE (Lx%, Ly%), L&, Layer(1), (0, 0)-STEP(Sx% - 1, Sy% - 1)
        LINE (0, 0)-STEP(639, 479), _RGBA32(0, 0, 0, I~%%), BF
        _PUTIMAGE , Layer(1), Layer(0)
        _LIMIT 102
    NEXT I~%%
    _DEST Layer(0)
END SUB

SUB Replace_Final_NPCs
    'changes some NPCs in the castle at end of game
    'the new king!(Imposter!! :) )
    NPC(6).X = 19: NPC(6).Y = 15: NPC(6).Facing = DOWN: NPC(6).Sprite_ID = 9: NPC(6).Can_Move = FALSE: NPC(6).MX = 0: NPC(6).MY = 0
    'trumpet playing gaurds
    NPC(7).X = 17: NPC(7).Y = 17: NPC(7).Facing = RIGHT: NPC(7).Sprite_ID = 13: NPC(7).Can_Move = FALSE: NPC(7).MX = 0: NPC(7).MY = 0
    NPC(8).X = 17: NPC(8).Y = 19: NPC(8).Facing = RIGHT: NPC(8).Sprite_ID = 13: NPC(8).Can_Move = FALSE: NPC(8).MX = 0: NPC(8).MY = 0
    NPC(12).X = 17: NPC(12).Y = 21: NPC(12).Facing = RIGHT: NPC(12).Sprite_ID = 13: NPC(12).Can_Move = FALSE: NPC(12).MX = 0: NPC(12).MY = 0
    NPC(13).X = 20: NPC(13).Y = 17: NPC(13).Facing = LEFT: NPC(13).Sprite_ID = 13: NPC(13).Can_Move = FALSE: NPC(13).MX = 0: NPC(13).MY = 0
    NPC(15).X = 20: NPC(15).Y = 19: NPC(15).Facing = LEFT: NPC(15).Sprite_ID = 13: NPC(15).Can_Move = FALSE: NPC(15).MX = 0: NPC(15).MY = 0
    NPC(17).X = 20: NPC(17).Y = 21: NPC(17).Facing = LEFT: NPC(17).Sprite_ID = 13: NPC(17).Can_Move = FALSE: NPC(17).MX = 0: NPC(17).MY = 0
    NPC(18).X = 1: NPC(18).Y = 15: NPC(18).Facing = LEFT: NPC(18).Sprite_ID = 10: NPC(18).Can_Move = FALSE: NPC(18).MX = 0: NPC(18).MY = 0
    NPC(20).X = 1: NPC(20).Y = 1: NPC(20).Facing = LEFT: NPC(20).Can_Move = FALSE
    NPC(22).X = 1: NPC(22).Y = 1: NPC(22).Facing = LEFT: NPC(22).Can_Move = FALSE

    NPC(14).X = 25: NPC(14).Y = 27

END SUB
