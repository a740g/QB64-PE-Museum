'compile game data: used to precreate all the data into a single file to load in game
'doing this to cut down on main program clutter

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


CONST FALSE = 0, TRUE = NOT FALSE
DIM SHARED I(127) AS Items
DIM SHARED L(30) AS _UNSIGNED INTEGER
DIM SHARED M(64) AS Monsters, GF(5) AS SINGLE
DIM SHARED World(127, 127) AS Tiles
DIM SHARED Place(27, 45, 45) AS Tiles, PD(-1 TO 27) AS Place_Data, Stairs(127) AS Stair_Data
DIM SHARED Chest(63) AS Treasure_Chest, NPC(127) AS Non_Playable_Character, Script(362) AS STRING
DIM SHARED NPCDialog(127, 8) AS Messaging
DIM SHARED Messages(400, 1) AS INTEGER
DIM SHARED Lines(400, 8) AS INTEGER 'dialog for NPCs
DIM SHARED File$(27)
DIM SHARED SA(10) AS Cords 'selection arrow positions
DIM SHARED BSA(4) AS Cords 'battle selection arrow positions
DIM SHARED LS(63) AS Name_Select 'used for selecting Hero Name
DIM SHARED Shop(16, 10) AS _BYTE
DIM SHARED Doors(24) AS Door_Data
DIM SHARED Spells(16) AS STRING 'Spell names
DIM SHARED MZG(19, 4) AS _BYTE 'Monsters by Zone Group
DIM SHARED Map_Music(-1 TO 30) AS _BYTE
DIM SHARED KeyCodes(134) AS KeyCodeData
DIM SHARED Entrance(80) AS Stair_Data
' _KEYHIT Keyboard Codes
'
'Esc  F1    F2    F3    F4    F5    F6    F7    F8    F9    F10   F11   F12   Sys  ScL Pause
' 27 15104 15360 15616 15872 16128 16384 16640 16896 17152 17408 34048 34304 +316 +302 +019
'`~  1!  2@  3#  4$  5%  6^  7&  8*  9(  0) -_ =+ BkSp   Ins   Hme   PUp   NumL   /     *    -
'126 33  64  35  36  37  94  38  42  40  41 95 43   8   20992 18176 18688  +300  47    42   45
' 96 49  50  51  52  53  54  55  56  57  48 45 61
'Tab Q   W   E   R   T   Y   U   I   O   P  [{  ]}  \|   Del   End   PDn   7Hme  8/?   9PU   +
' 9  81  87  69  82  84  89  85  73  79  80 123 125 124 21248 20224 20736 18176 18432 18688 43
'   113 119 101 114 116 121 117 105 111 112  91  93  92                    55    56    57
'CapL   A   S   D   F   G   H   J   K   L   ;:  '" Enter                   4/?-   5    6/-?
'+301  65  83  68  70  71  72  74  75  76   58  34  13                    19200 19456 19712  E
'      97 115 100 102 103 104 106 107 108   59  39                    52    53    54   n
'Shift   Z   X   C   V   B   N   M   ,<  .>  /?    Shift       ?           1End  2/?   3PD   t
'+304    90  88  67  86  66  78  77  60  62  63    +303      18432        20224 20480 20736  e
'       122 120  99 118  98 110 109  44  46  47                             49    50    51   r
'Ctrl   Win  Alt     Spacebar      Alt  Win  Menu  Ctrl   ?-    ?   -?      0Ins       .Del
'+306  +311 +308        32        +307 +312 +319   +305 19200 20480 19712   20992     21248  13
'                                                                            48         46
'
'     Lower value = LCase/NumLock On __________________ + = add 100000

KeyCodesData:
DATA "ESC",27,"F1",15104,"F2",15360,"F3",15616,"F4",15872,"F5",16128,"F6",16384,"F7",16640,"F8",16896
DATA "F9",17152,"F10",17408,"F11",34048,"F12",34304,"PrntScrn",100316,"ScrlLock",100302,"Pause",100019
DATA "`",96,"1",49,"2",50,"3",51,"4",52,"5",53,"6",54,"7",55,"8",56,"9",57,"0",48,"-",45,"=",61,"BackSpce",8
DATA "Insert",20992,"Home",18176,"PgUp",18688,"NumLock",100300,"/",47,"*",42,"~",126,"!",33,"@",64,"#",35
DATA "$",36,"%",37,"^",94,"&",38,"*",42,"(",40,")",41,"_",95,"+",43,"TAB",9,"Q",81,"W",87,"E",69,"R",82
DATA "T",84,"Y",89,"U",85,"I",73,"O",79,"P",80,"[",91,"]",93,"\",92,"A",65,"S",83,"D",68,"F",70,"G",71
DATA "H",72,"J",74,"K",75,"L",76,";",59,"'",39,"Enter",13,"L-Shift",100304,"Z",90,"X",88,"C",67,"V",86
DATA "B",66,"N",78,"M",77,",",44,".",46,"R-Shift",100303,"L-Ctrl",100306,"L-Win",100311,"L-Alt",100308
DATA "SpaceBar",32,"R-Alt",100307,"R-Win",100312,"Menu",100319,"R-Ctrl",100305,"q",113,"w",119,"e",101,"r",114
DATA "t",116,"y",121,"u",117,"i",105,"o",111,"p",112,"{",123,"}",125,"|",124,"Del",21248,"End",20224,"PgDn",20736
DATA "a",97,"s",115,"d",100,"f",102,"g",103,"h",104,"j",106,"k",107,"l",108,":",58,"z",122,"x",120,"c",99
DATA "v",118,"b",98,"n",110,"m",109,"<",60,">",62,"?",63,"UP-Arrow",18432,"Lt-Arrow",19200,"Dn-Arrow",20480,"Rt-Arrow",19712

MapMusicData:
DATA -1,0,1,0,3,3,3,3,5,5,5,5,6,7,3,3,6,6,6,6,8,3,6,6,0,0,3,3

SpellNames:
DATA Heal,Hurt,Sleep,Radiant,StopSpell,Outside,Return,Repel,HealMore,HurtMore,Strength,Quicken

MapTiledatafiles:
DATA Castle_Tantegel_0,Castle_Tantegel_1,Castle_Tantegel_2,Brecconary_0,Brecconary_1,Cantlin_0,Cantlin_1
DATA Dragon_Castle_0,Dragon_Castle_1,Dragon_Castle_2,Dragon_Castle_3,East_Bridge_Cave_0,Edricks_cave_0
DATA Garinham_0,Garinham_1,Garins_Cave_0,Garins_Cave_1,Garins_Cave_2,Garins_Cave_3,Hauksness_0,Kol_0
DATA Mountain_cave_0,Mountain_cave_1,Rain_Staff_Shrine_0,Rainbow_Temple_0,Rimuldar_0,Rimuldar_1
'exit perimeter
DATA 7,7,38,38,13,13,24,24,14,17,26,28,7,7,38,38,7,7,38,38,7,7,36,37,7,7,36,37,10,12,33,31,12,11,33,32
DATA 4,4,32,40,8,8,36,37,17,6,24,37,16,7,27,38,12,12,33,33,12,12,33,33,11,10,32,31,13,13,29,28,12,12,33,33
DATA 16,16,27,26,11,13,32,34,11,11,36,36,13,13,28,28,13,13,28,28,15,15,26,26,16,14,27,25,7,7,38,36
'castle and town entry points, to be loaded after stairs
EntryPoints:
DATA 0,18,37,3,8,22,5,21,7,7,13,22,13,12,27,19,12,23,20,31,36,25,37,22
'cave and temple entry points
CaveEntryPoints:
DATA 36,20,89,9,112,52,112,57,37,65,116,117
'place lighting lit or unlit
IsLit:
DATA 1,1,1,1,1,1,1,1,1,0,0,1,0,0,1,1,0,0,0,0,1,1,0,0,1,1,1,1
'Building Entry Points; start map, x,y, dest map,x,y  (77 total)
BuildingEntryPoints:
'Brecconary(2); item shop, fairy water girl (entrances)
DATA 3,29,13,4
DATA 3,30,31,4
'Cantlin(3); empty left, empty right, large center area(+26)
DATA 5,9,10,6
DATA 5,34,10,6
DATA 5,18,18,6
DATA 5,18,21,6
DATA 5,18,22,6
DATA 5,18,23,6
DATA 5,18,24,6
DATA 5,18,25,6
DATA 5,18,26,6
DATA 5,18,27,6
DATA 5,18,28,6
DATA 5,18,29,6
DATA 5,18,30,6
DATA 5,22,18,6
DATA 5,23,18,6
DATA 5,24,18,6
DATA 5,25,18,6
DATA 5,25,19,6
DATA 5,25,20,6
DATA 5,25,21,6
DATA 5,25,22,6
DATA 5,25,23,6
DATA 5,25,24,6
DATA 5,25,28,6
DATA 5,25,29,6
DATA 5,25,30,6
DATA 5,20,30,6
DATA 5,23,30,6
'Garinham(2);entrances
DATA 13,30,23,14
DATA 13,16,15,14
'Rimuldar(2);key sales man(+3), other building(+2)
DATA 25,13,11,26
DATA 25,12,12,26
DATA 25,11,13,26
DATA 25,18,28,26
DATA 25,19,28,26

BuildingExitpoints:
'Brecconary inside(2); exits
DATA 4,29,14,3
DATA 4,30,30,3
'Cantlin inside(3);exits(+30)
DATA 6,10,10,5
DATA 6,34,11,5
DATA 6,17,18,5
DATA 6,17,21,5
DATA 6,17,22,5
DATA 6,17,23,5
DATA 6,17,24,5
DATA 6,17,25,5
DATA 6,17,26,5
DATA 6,17,27,5
DATA 6,17,28,5
DATA 6,17,29,5
DATA 6,17,30,5
DATA 6,18,17,5
DATA 6,22,17,5
DATA 6,23,17,5
DATA 6,24,17,5
DATA 6,25,17,5
DATA 6,26,18,5
DATA 6,26,19,5
DATA 6,26,20,5
DATA 6,26,21,5
DATA 6,26,22,5
DATA 6,26,23,5
DATA 6,26,24,5
DATA 6,26,28,5
DATA 6,26,29,5
DATA 6,26,30,5
DATA 6,18,31,5
DATA 6,20,31,5
DATA 6,23,31,5
DATA 6,25,31,5
'Garinham inside(2);exits
DATA 14,30,24,13
DATA 14,16,14,13
'Rimuldar exits(2);(+2),(+2)
DATA 26,12,11,25
DATA 26,11,12,25
DATA 26,18,27,25
DATA 26,19,27,25

StairData:
'castle Tentagel #1-#4
DATA 0,15,15,1,3
DATA 0,37,37,2,4
DATA 1,22,22,2,1
DATA 2,16,22,1,2
'Over World; caves\temples\shrines #5-#10
'edricks cave #5
DATA -1,29,13,2,11
'Rain Staff shrine#6
DATA -1,82,2,2,84
'East Bridge cave north entrance(aka swamp cave)#7
DATA -1,105,45,2,57
'east bridge cave south#8
DATA -1,105,50,2,58
'Mountain cave#9
DATA -1,30,58,2,79
'Rainbow Temple#10
DATA -1,109,110,2,85
'edricks cave #11-#13
DATA 12,17,8,1,5
DATA 12,26,17,2,13
DATA 12,25,37,1,12
'Dragon castle #14-#16
DATA 7,17,25,2,17
DATA 7,28,25,2,23
DATA 7,23,12,2,25
'#17-#26
DATA 8,22,12,1,14
DATA 8,28,13,2,30
DATA 8,15,16,2,27
DATA 8,26,19,2,35
DATA 8,32,19,2,40
DATA 8,26,21,2,42
DATA 8,21,25,1,15
DATA 8,15,26,2,32
DATA 8,30,27,1,16
DATA 8,21,31,2,29
'#27-#55
DATA 9,5,5,1,19
DATA 9,8,5,2,31
DATA 9,10,5,1,26
DATA 9,13,5,1,18
DATA 9,27,5,1,28
DATA 9,5,6,1,24
DATA 9,14,6,2,34
DATA 9,22,7,1,33
DATA 9,9,9,1,20
DATA 9,25,9,1,39
DATA 9,21,11,2,51
DATA 9,27,12,2,50
DATA 9,5,13,2,36
DATA 9,14,13,1,21
DATA 9,6,14,2,43
DATA 9,13,14,1,22
DATA 9,20,14,1,41
DATA 9,20,20,2,54
DATA 9,24,20,1,47
DATA 9,29,20,1,48
DATA 9,13,21,2,45
DATA 9,7,22,2,46
DATA 9,25,25,2,52
DATA 9,12,27,1,38
DATA 9,5,29,1,37
DATA 9,6,36,1,49
DATA 9,16,36,2,52
DATA 9,37,37,1,44
DATA 9,31,37,2,56
'#56
DATA 10,17,36,1,55
'East bridge cave #57,#58
DATA 11,18,7,1,7
DATA 11,18,36,1,8
'Garinham #59
DATA 13,32,13,2,60
'Garins cave 0 #60,#61
DATA 15,18,22,1,59
DATA 15,13,29,2,64
'Cave 1 #62-#67
DATA 16,16,16,2,68
DATA 16,27,16,2,69
DATA 16,26,17,1,61
DATA 16,20,21,2,72
DATA 16,16,25,2,74
DATA 16,27,25,2,73
'cave 2 #68-#74
DATA 17,27,14,1,62
DATA 17,31,14,1,63
DATA 17,22,18,2,75
DATA 17,23,22,2,76
DATA 17,19,24,1,65
DATA 17,31,26,1,67
DATA 17,15,30,1,66
'cave 3 #75,#76
DATA 18,17,21,1,70
DATA 18,22,21,1,71
'Mt Cave 0 #77-#80
DATA 21,14,14,2,81
DATA 21,20,19,2,82
DATA 21,14,21,1,9
DATA 21,26,26,2,83
'Cave 1 #81-83
DATA 22,14,14,1,77
DATA 22,20,19,1,78
DATA 22,26,26,1,80
'Rain Staff shire #84
DATA 23,20,25,1,6
'rainbow temple #85
DATA 24,17,19,1,10

world:
'castles,towns
DATA 44,44,1,49,49,7,3,3,13,105,11,20,49,42,3,103,73,25,26,90,19,74,103,5
'caves/temples
DATA 82,2,23,29,13,12,105,45,11,105,50,11,30,58,21,109,110,24
'Battle selection values aka Territory
DATA 3,3,2,2,3,5,4,5,3,2,1,2,3,3,4,5,4,1,0,0,1,3,4,5,5,1,1,12,9,6,6,6,5,5,4,12,12,7,7,7,10,9,8,12,12,12,8,7,10,10,11,12,13,13,9,8,11,11,12,13,13,12,9,9
'special locations(edricks token, golem fight)
DATA 2,84,114,1,74,101,2
'Special locations in towns\castles\caves,Green Dragon fight(3), Flute(4),(Dragon Castle throne(5), Secret stair(6)
DATA 4,11,22,21,3,20,21,18,4,7,23,13,6,7,23,11,5

Doors:
'Tantegel throne room
DATA 1,18,21,0
'tantegel court yard
DATA 0,12,21,0
DATA 0,26,14,0
'Brecconary
DATA 3,29,14,0
'Garinham
DATA 13,30,23,0
'Garinham inside
DATA 14,17,19,0
'Garinham Cave
DATA 15,29,28,0
'Kol
DATA 20,19,24,0
DATA 20,13,26,0
'Cantlin
DATA 5,33,16,0
DATA 5,11,28,0
DATA 5,15,32,0
DATA 5,21,32,0
DATA 5,22,32,0
'Rimuldar
DATA 25,29,29,0
DATA 25,30,31,0
'Dragonlord castle
DATA 7,17,19,0
DATA 7,28,19,0

items:
DATA Fist,0,0,"Bamboo Pole",10,2,Club,60,4,"Copper Sword",180,10,"Hand Axe",560,15,"Broad Sword",1500,20,"Flame Sword",9800,28,"Erdrick's Sword",0,40
DATA "Loin Cloth",0,0,Cloths,20,2,"Leather Armor",70,4,"Chain Mail",300,10,"Half Plate",1000,16,"Full Plate",3000,24,"Magic Armor",7700,24,"Erdrick's Armor",0,28
DATA None,0,0,"Small Sheild",90,4,"Large Shield",800,10,"Silver Shield",14800,20,"Erdrick's Shield",0,26
DATA Torch,8,0,Herbs,24,0,Wings,70,0,"Dragon's Scale",20,2,"Fairy Water",38,0,"Magic Key",53,0,"Tablet",0,0
DATA "Fairy Flute",0,0,"Cursed Belt",360,0,"Silver Harp",0,0,"Spell Book",0,0,"Fighter's Ring",0,0,"Death Necklace",2600,0
DATA "Rain Staff",0,0,"Rainbow Drop",0,0,"Sunlight Stones",0,0,"Magic Key",52,0,"Gwaelin's Love",0,0,"Edrick's Token",0,0,"Hidden Passage",0,0
DATA 1,7,23,47,110,220,450,800,1300,2000,2900,4000,5500,7500,10000,13000,16000,19000,22000,26000,30000,34000,38000,42000,46000,50000,54000,58000,62000,65000,65500
DATA .25,.375,.5,1,1.4

MonsterZoneGroups:
DATA 0,1,0,1,0
DATA 1,0,1,2,1
DATA 0,3,2,3,1
DATA 1,1,2,3,4
DATA 3,4,5,5,6
DATA 3,4,5,6,11
DATA 5,6,11,12,14
DATA 11,12,13,14,14
DATA 13,15,18,18,24
DATA 15,21,18,21,24
DATA 21,22,23,26,28
DATA 23,26,27,28,16
DATA 26,27,28,29,31
DATA 29,30,31,31,32
DATA 8,9,10,11,12
DATA 17,18,19,20,23
DATA 29,30,31,32,33
DATA 32,33,34,34,35
DATA 32,35,36,36,37
DATA 3,4,6,7,7

Monsters:
DATA Slime,5,3,3,,,240,,4,1,1,,,,,1
DATA "Red Slime",7,3,4,,,240,,4,1,2,,,,,1
DATA Drakee,9,6,6,,,240,,4,2,2,,,,,1
DATA Ghost,11,8,7,,,240,,16,3,4,,,,,1
DATA Magician,11,12,13,4,,,,4,4,11,,,2,127,1
DATA Magidrakee,14,14,15,8,,,,4,5,11,,,2,127,1
DATA Scorpion,18,16,20,,,240,,4,6,15,,,,,1
DATA Druin,20,18,22,,,240,,8,7,15,,,,,1
DATA Poltergeist,18,20,23,10,,,,24,8,17,,,2,191,1
DATA Droll,24,24,25,,,224,,8,10,24,,,,,1
DATA Drakeema,22,26,20,16,32,,,24,11,19,1,63,2,127,1
DATA Skeleton,28,22,30,,,240,,16,11,29,,,,,1
DATA Warlock,28,22,30,24,48,16,,8,13,34,3,63,2,127,1
DATA "Metal Scorpion",36,42,22,,,240,,8,14,39,,,,,1
DATA Wolf,40,30,34,,16,240,,8,16,49,,,,,1
DATA Wraith,44,34,36,16,112,,,16,17,59,1,63,,,1
DATA "Metal Slime",10,255,4,6,240,240,240,4,115,5,,,2,191,1
DATA Specter,40,38,36,28,48,16,,16,18,69,3,63,2,191,1
DATA Wolflord,50,36,38,36,64,112,,8,20,79,5,127,,,1
DATA Druinlord,47,40,35,30,240,,,16,20,84,1,191,2,63,1
DATA Drollmagi,52,50,38,48,32,32,,4,22,89,5,127,,,2
DATA Wyvern,56,48,42,,64,240,,8,24,99,,,,,2
DATA "Rogue Scorpion",60,90,35,,112,240,,8,26,109,,,,,2
DATA "Wraith Knight",68,56,46,48,80,,48,16,28,119,1,191,,,2
DATA Golem,120,60,70,,240,240,240,,5,9,,,,,2
DATA Goldman,48,40,50,,208,240,,4,6,255,,,,,2
DATA Knight,76,78,55,60,96,112,,4,33,129,5,127,,,2
DATA Magiwyvern,78,68,58,60,32,,,8,34,139,3,127,,,2
DATA "Demon Knight",79,64,50,,240,240,240,60,37,149,,,,,2
DATA Werewolf,86,70,60,,112,240,,28,40,154,,,,,2
DATA "Green Dragon",88,74,65,,112,240,32,8,45,159,,,16,63,3
DATA Starwyvern,86,80,65,80,128,,16,8,43,159,9,192,16,63,3
DATA Wizard,80,70,65,80,240,112,240,8,50,164,,,2,127,3
DATA "Axe Knight",94,82,70,80,240,48,16,4,54,164,3,63,,,3
DATA "Blue Dragon",98,84,70,,240,240,112,8,60,149,,,16,63,3
DATA Stoneman,100,40,160,,32,240,112,4,65,139,,,,,4
DATA "Armored Knight",105,86,90,110,240,112,16,8,70,139,9,191,10,63,4
DATA "Red Dragon",120,90,100,80,240,112,240,8,100,139,3,63,16,63,4
DATA "Dragonlord",90,75,100,80,240,240,240,,,,5,63,10,191,4
DATA "Dragon Lord",140,200,130,,240,240,240,,,,,,17,127,4
DATA "King!",200,224,255,192,255,255,255,92,11,191,10,191,5

Treasure:
DATA 1,18,18,64,120,1,19,18,21,1,1,20,15,26,1
DATA 0,9,21,63,13,0,10,22,63,13,0,9,23,63,13,0,11,23,63,13
DATA 2,20,23,36,1
DATA 12,26,31,27,0
DATA 14,21,18,63,20,14,22,18,21,1,14,21,19,22,1
DATA 15,23,11,22,1,15,24,11,63,20,15,25,11,63,15
DATA 17,14,14,29,1,17,26,19,30,1
DATA 9,10,10,7,1
DATA 10,18,18,22,1,10,18,19,63,755,10,19,19,26,1,10,18,20,23,1,10,19,20,28,1,10,20,20,22,1
DATA 20,27,32,20,1,20,27,33,63,16000,20,27,34,30,1
DATA 21,27,19,22,1
DATA 22,16,16,31,1,22,17,16,21,1,22,15,20,62,0,22,27,23,63,17
DATA 23,19,20,35,1
DATA 24,22,20,34,1

ShopItemLists:
'Brecannary armory
DATA 6,1,2,3,9,10,17
'Brecannary tool shop
DATA 3,22,21,24
'Garinham tool shop
DATA 3,22,21,24
'Garinham Armory
DATA 7,2,3,4,10,11,12,18
'Kol armory
DATA 5,3,4,12,13,17
'Kol Item Shop
DATA 4,22,21,24,23
'Rimuldar armory
DATA 6,3,4,5,12,13,14
'Cantlin Armory Main
DATA 6,1,2,3,9,10,18
'Cantlin tool Shop 1
DATA 2,21,22
'Cantlin tool shop 2
DATA 2,24,23
'Cantlin Armory secondary
DATA 2,6,19
'Cantlin Armory Third
DATA 4,5,6,13,14


Scriptlines:
DATA "#E hath woken up."
DATA "Thou art dead."
DATA "Thou art strong enough! Why can thou not defeat the Dragonlord?"
DATA "If thou art planning to take a rest, first see King Lorik."
DATA "#P held the Rainbow Drop toward the sky.&p But no rainbow appeared here."
DATA "Good morning. Thou hast had a good night's sleep I hope."
DATA "I shall see thee again."
DATA "Good morning. Thou seems to have spent a good night."
DATA "Good night."
DATA "Okay. Good-bye, traveler."
DATA "Welcome to the traveler's Inn. Room and board is #NG GOLD per night. Dost thou want a room?&Y"
DATA "All the best to thee."
DATA "There are no stairs here."
DATA "Thou cannot enter here."
DATA "There is no one there."
DATA "I thank thee. Won't thou buy one more bottle?&Y"
DATA "Will thou buy some Fairy Water for #NG GOLD to keep the Dragonlord's minions away?&Y"
DATA "I will see thee later."
DATA "Thou hast not enough money."
DATA "I am sorry, but I cannot sell thee anymore."
DATA "Here,take this key. Dost thou wish to purchase more?&Y"
DATA "Magic keys! They will unlock any door. Dost thou wish to purchase one for #NG GOLD?&Y"
DATA "I am sorry. A curse is upon thy body."
DATA "Thou hast no possessions."
DATA "Wilt thou sell anything else?&Y"
DATA "I cannot buy it."
DATA "Thou said the #I. I will buy thy #I for #NG GOLD. Is that all right?&Y"
DATA "What art thou selling?"
DATA "I will be waiting for thy next visit."
DATA "Dost thou want anything else?&Y"
DATA "Thou cannot hold more Herbs."
DATA "Thou cannot carry anymore."
DATA "Thou hast not enough money."
DATA "The #I? Thank you very much."
DATA "What dost thou want?"
DATA "Welcome. We deal in tools. What can I do for thee?"
DATA "Oh, yes? That's too bad."
DATA "Is that Okay.?&Y"
DATA "We deal in weapons and armor. Dost thou wish to buy anything today?&Y"
DATA "The #I?"
DATA "Then I will buy thy #I for #NG GOLD."
DATA "Sorry. Thou hast not enough money."
DATA "Dost thou wish to buy anything more?&Y"
DATA "What dost thou wish to buy?"
DATA "I thank thee."
DATA "Please, come again."
DATA "#P chanted the spell of #S."
DATA "#P cannot yet use the spell."
DATA "Thy MP is too low."
DATA "But nothing happened."
DATA "REPEL has lost its effect."
DATA "A torch can be used only in dark places."
DATA "#P sprinkled the Fairy Water over his body."
DATA "The Fairy Water has lost its effect."
DATA "The Wings of the Wyvern cannot be used here."
DATA "#P threw The Wings of the Wyvern up into the sky."
DATA "#P donned the scale of the dragon."
DATA "Thou art already wearing the scale of the dragon."
DATA "#P blew the Fairies' Flute."
DATA "Nothing of use has yet been given to thee."
DATA "#P put on the Fighter's Ring."
DATA "#P adjusted the position of the Fighter's Ring."
DATA "#P held the #I tightly."
DATA "#P played a sweet melody on the harp."
DATA "#P put on the #I and was cursed!."
DATA "Thy body is being squeezed."
DATA "The #I is squeezing thy body."
DATA "Cursed one, be gone!"
DATA "I am looking for the castle cellar. I heard it is not easily found."
DATA "Thou must have a key to open a door."
DATA "To become strong enough to face future trials thou must first battle many foes."
DATA "King Lorik will record thy deeds in his Imperial Scroll so thou may return to thy quest later."
DATA "When the sun and rain meet, a Rainbow Bridge shall appear."
DATA "Never does a brave person steal."
DATA "There was a time when Brecconary was a paradise. Then the Dragonlord's minions came."
DATA "Let us wish the warrior well!"
DATA "May the light be thy strength!"
DATA "If thy Hit Points are high enough, by all means, enter."
DATA "We are merchants who have traveled much in this land. Many of our colleagues have been killed by servants of the Dragonlord."
DATA "Rumor has it that entire towns have been destroyed by the Dragonlord's servants."
DATA "Welcome to Tantegel Castle."
DATA "In Garinham,look for the grave of Garin. Thou must push on a wall of darkness there."
DATA "A word of advice."
DATA "Save thy money for more expensive armor."
DATA "Listen to what people say. It can be of great help."
DATA "Beware the bridges!"
DATA "Danger grows when thou crosses."
DATA "There is a town where magic keys can be purchased."
DATA "Some say that Garin's grave is home to a Silver Harp."
DATA "Enter where thou can."
DATA "Welcome! Enter the shop and speak to its keeper across the desk."
DATA "Thou art most welcome in Brecconary."
DATA "Watch thy Hit Points when in the Poisonous Marsh."
DATA "Go north to the seashore, then follow the coastline west until thou hath reached Garinham."
DATA "No,I am not Princess Gwaelin."
DATA "Please,save us from the minions of the Dragonlord."
DATA "See King Lorik when thy experience levels are raised."
DATA "Art thou the descendant of Erdrick? Hast thou any proof?"
DATA "Within sight of Tantegel Castle to the south is Charlock,"
DATA "The fortress of the Dragonlord."
DATA "This bath cures rheumatism."
DATA "East of Hauksness there is a town, 'tis said, where one may purchase weapons of extraordinary quality."
DATA "Rimuldar is the place to buy keys."
DATA "Hast thou seen Nester? I think he may need help."
DATA "Dreadful is the South Island."
DATA "Great strength and skill and wit only will bring thee back from that place."
DATA "Golem is afraid of the music of the flute, so 'tis said."
DATA "This is the village of Kol."
DATA "In legends it is said that fairies know how to put Golem to sleep."
DATA "The harp attracts enemies. Stay away from the grave in Garinham."
DATA "I'm too busy. Ask the other guard."
DATA "I suggest making a map if thy path leads into the darkness."
DATA "Once there was a town called Hauksness far to the south,but I do not know if it still exists."
DATA "I hate people! Go! Leave me!"
DATA "They say that Erdrick's armor was hidden long ago."
DATA "Many believe that Princess Gwaelin is hidden away in a cave."
DATA "I have heard of one named Nester. Dost thou know such a one?"
DATA "Garin, a wandering minstrel of legendary fame, is said to have built this town."
DATA "Welcome to Garinham. May thy stay be a peaceful one."
DATA "It is said that the Princess was kidnapped and taken eastward."
DATA "Come buy my radishes! They are fresh and cheap. Buy thy radishes today!"
DATA "To learn how proof may be obtained that thy ancestor was the great Erdrick, see a man in this very town."
DATA "'Tis said that Erdrick's sword could cleave steel."
DATA "Welcome to Cantlin, the castle town."
DATA "What shall I get for thy dinner?"
DATA "I know nothing."
DATA "I'm Nester. Hey, where am I? No, don't tell me!"
DATA "Grandfather used to say that his friend, Wynn, had buried something of great value at the foot of a tree behind his shop."
DATA "It is said that many have held Erdrick's armor."
DATA "The last to have it was a fellow named Wynn."
DATA "My Grandfather Wynn once had a shop on the east side of Hauksness."
DATA "Welcome!"
DATA "Who art thou? Leave at once or I will call my friends."
DATA "I am Orwick, and I am waiting for my girl friend."
DATA "The scales of the Dragonlord are as hard as steel."
DATA "Over the western part of this island Erdrick created a rainbow."
DATA "'Tis also said that he entered the darkness from a hidden entrance in the room of the Dragonlord."
DATA "Thou shalt find the Stones of Sunlight in Tantegel Castle, if thou has not found them yet."
DATA "Welcome to the town of Rimuldar."
DATA "No, I have no tomatoes. I have no tomatoes today."
DATA "You are #P? It has been long since last we met."
DATA "Good day,I am Howard. Four steps south of the bath in Kol thou shalt find a magic item."
DATA "Before long the enemy will arrive."
DATA "Heed my warning! Travel not to the south for there the monsters are fierce and terrible."
DATA "In this world is there any sword that can pierce the scales of the Dragonlord?"
DATA "Orwick is late again. I'm starving."
DATA "Many have been the warriors who have perished on this quest."
DATA "But for thee I wish success, #P."
DATA "Hast thou found the flute?"
DATA "Hast thou been to the southern island?"
DATA "'Tis said that the Dragonlord hath claws that can cleave iron and fiery breath that can melt stone."
DATA "Dost thou still wish to go on?"
DATA "This is a magic place. Hast thou found a magic temple?"
DATA "When entering the cave, take with thee a torch."
DATA "Go to the town of Cantlin."
DATA "I have heard that powerful enemies live there."
DATA "Thou art truly brave."
DATA "In this temple do the sun and rain meet."
DATA "Howard had it, but he went to Rimuldar and never returned."
DATA "To the south, I believe, there is a town called Rimuldar."
DATA "That is good."
DATA "No one will say thou art afraid."
DATA "Go to the south."
DATA "Where oh where can I find Princess Gwaelin?"
DATA "Thank you for saving the Princess."
DATA "Oh, my dearest Gwaelin!"
DATA "I hate thee, #P."
DATA "Tell King Lorik that the search for his daughter hath failed."
DATA "I am almost gone...."
DATA "Who touches me?"
DATA "I see nothing, nor can I hear."
DATA "Dost thou know about Princess Gwaelin?&Y"
DATA "Half a year now hath passed since the Princess was kidnapped by the enemy."
DATA "Never does the King speak of it, but he must be suffering much."
DATA "#P, please save the Princess."
DATA "Oh, brave #P."
DATA "I have been waiting long for one such as thee."
DATA "Thou hast no business here. Go away."
DATA "If thou art cursed, come again."
DATA "I will free thee from thy curse."
DATA "Now, go."
DATA "Though thou art as brave as thy ancestor, #P, thou cannot defeat the great Dragonlord with such weapons."
DATA "Thou shouldst come here again."
DATA "Finally thou hast obtained it, #P."
DATA "Is that a wedding ring?"
DATA "Thou seems too young to be married."
DATA "All true warriors wear a ring."
DATA "#P's coming was foretold by legend. May the light shine upon this brave warrior."
DATA "Thou may go and search."
DATA "From Tantegel Castle travel 70 leagues to the south and 40 to the east."
DATA "It's a legend."
DATA "Thy bravery must be proven."
DATA "Thus, I propose a test."
DATA "There is a Silver Harp that beckons to the creatures of the Dragonlord."
DATA "Bring this to me and I will reward thee with the Staff of Rain."
DATA "Thou hast brought the harp. Good."
DATA "In thy task thou hast failed. Alas, I fear thou art not the one Erdrick predicted would save us."
DATA "Go now!"
DATA "Now the sun and rain shall meet and the Rainbow Drop passes to thy keeping."
DATA "Thou art brave indeed to rescue me, #P."
DATA "I am Gwaelin, daughter of Lorik."
DATA "But thou must."
DATA "Princess Gwaelin embraces thee."
DATA "I'm so happy!"
DATA "Forever shall I be grateful for the gift of my daughter returned to her home, #P. Accept my thanks."
DATA "Now, Gwaelin, come to my side."
DATA "Gwaelin then whispers:"
DATA "Wait a moment, please. I would give a present to #P."
DATA "Please accept my love, #P."
DATA "Please give me thy #I."
DATA "Even when we two are parted by great distances, I shall be with thee."
DATA "Farewell, #P."
DATA "I love thee, #P."
DATA "Dost thou love me, #P?&Y"
DATA "When thou art finished preparing for thy departure, please see me. I shall wait."
DATA "I am greatly pleased that thou hast returned, #P."
DATA "Before reaching thy next level of experience thou must gain #NX."
DATA "If thou dies I can bring thee back for another attempt without loss of thy deeds to date."
DATA "Goodbye now, #P. Take care and tempt not the Fates."
DATA "Will thou take me to the castle?&Y"
DATA "Take the Treasure Chest."
DATA "Welcome, #P. I am the Dragonlord--King of Kings."
DATA "I give thee now a chance to share this world and to rule half of it if thou will now stand beside me."
DATA "What sayest thou? Will the great warrior stand with me?&Y"
DATA "Thou art a fool!"
DATA "Then half of this world is thine, half of the darkness, and...."
DATA "Thy journey is over."
DATA "Take now a long, long rest."
DATA "Hahahaha...."
DATA "If thou would take the #I, thou must now discard some other item."
DATA "Dost thou wish to have the #I?&Y"
DATA "Thou hast given up thy #I."
DATA "What shall thou drop?&D"
DATA "Thou hast dropped thy #I."
DATA "And obtained the #I."
DATA "That is much too important to throw away."
DATA "#P searched the ground all about."
DATA "But there found nothing."
DATA "There is a treasure box."
DATA "#P discovers the #I."
DATA "Feel the wind blowing from behind the throne."
DATA "There is nothing to take here, #P."
DATA "Of GOLD thou hast gained #NG."
DATA "Fortune smiles upon thee, #P."
DATA "Thou hast found the #I."
DATA "Unfortunately, it is empty."
DATA "Heed my voice, #P, for this is Gwaelin."
DATA "To reach the next level thou must raise thy Experience by #NX. My hope is with thee."
DATA "From where thou art now, my castle lies.."
DATA "#NN to the north and.."
DATA "#NS to the south and.."
DATA "#NE to the east."
DATA "#NW to the west."
DATA "A #E draws near!"
DATA "The #E is running away."
DATA "The #E attacked before #P was ready."
DATA "#P attacks!"
DATA "The #E's Hits have been reduced by #NH."
DATA "The attack failed and there was no loss of Hit Points!"
DATA "Command?"
DATA "That cannot be used in battle."
DATA "But that spell hath been blocked."
DATA "The spell will not work."
DATA "Thou hast put the #E to sleep."
DATA "The #E's spell hath been blocked."
DATA "Thou hast done well in defeating the #E."
DATA "Thy Experience increases by #NP."
DATA "Thy GOLD increases by #ND."
DATA "Courage and wit have served thee well."
DATA "Thou hast been promoted to the next level."
DATA "Thou hast learned a new spell."
DATA "Quietly Golem closes his eyes and settles into sleep."
DATA "#E looks happy.'"
DATA "#P started to run away."
DATA "But was blocked in front."
DATA "#P used the Herb."
DATA "The #E is asleep."
DATA "The #E attacks!"
DATA "Thy Hits decreased by #NH."
DATA "A miss! No damage hath been scored!"
DATA "#E chants the spell of #S."
DATA "#P's spell is blocked."
DATA "The #E is breathing fire."
DATA "If thou hast collected all the Treasure Chests, a key will be found."
DATA "Once used, the key will disappear, but the door will be open and thou may pass through."
DATA "East of this castle is a town where armor, weapons, and many other items may be purchased."
DATA "Return to the Inn for a rest if thou art wounded in battle, #P."
DATA "Sleep heals all."
DATA "Descendant of Erdrick, listen now to my words."
DATA "It is told that in ages past Erdrick fought demons with a Ball of Light."
DATA "Then came the Dragonlord who stole the precious globe and hid it in the darkness."
DATA "Now, #P, thou must help us recover the Ball of Light and restore peace to our land."
DATA "The Dragonlord must be defeated."
DATA "Take now whatever thou may find in these Treasure Chests to aid thee in thy quest."
DATA "Then speak with the guards, for they have much knowledge that may aid thee."
DATA "May the light shine upon thee, #P."
DATA "The tablet reads as follows:"
DATA "I am Erdrick and thou art my descendant."
DATA "Three items were needed to reach the Isle of Dragons, which is south of Brecconary."
DATA "I gathered these items, reached the island, and there defeated a creature of great evil."
DATA "Now I have entrusted the three items to three worthy keepers."
DATA "Their descendants will protect the items until thy quest leads thee to seek them out."
DATA "When a new evil arises, find the three items, then fight!"
DATA "Excellent move!"
DATA "#P? This is Gwaelin. Know that thou hath reached the final level."
DATA "Thou art asleep."
DATA "Thou art still asleep."
DATA "#P awakes."
DATA "The #E hath recovered."
DATA "It is dodging!"
DATA "There is no door here."
DATA "Thou hast not a key to use."
DATA "Death should not have taken thee, #P."
DATA "I will give thee another chance."
DATA "Thy power increases by #NA."
DATA "Thy Response Speed increases by #NR."
DATA "Thy Maximum Hit points increase by #NB."
DATA "Thy Maximum Magic points increase by #NM."
DATA "To reach the next level, thy Experience must increase by #NX."
DATA "Now, go, #P!"
DATA "Thou hast failed and thou art cursed."
DATA "Leave at once!"
DATA "...."
DATA "Really?"
DATA "I am glad thou hast returned. All our hopes are riding on thee."
DATA "See me again when thy level has increased."
DATA "The Dragonlord revealed his true self!"
DATA "Thou hast found the Ball of Light."
DATA "Radiance streams forth as thy hands touch the object and hold it aloft."
DATA "Across the land spreads the brilliance until all shadows are banished and peace is restored."
DATA "The legends have proven true."
DATA "Thou art indeed of the line of Erdrick."
DATA "It is thy right to rule over this land."
DATA "Will thou take my place?"
DATA "#P thought carefully before answering."
DATA "I cannot,"
DATA "said #P."
DATA "If ever I am to rule a country, it must be a land that I myself find."
DATA "Gwaelin said:"
DATA "Please, wait."
DATA "I wish to go with thee on thy journey."
DATA "May I travel as thy companion?"
DATA "Hurrah! Hurrah! Long live #P!"
DATA "Thou hast brought us peace, again."
DATA "Come now, King Lorik awaits."
DATA "And thus the tale comes to an end...."
DATA "unless the dragons return again."
DATA "Will thou tell me now of thy deeds so they won't be forgotten?&Y"
DATA "Thy deeds have been recorded on the Imperial Scrolls of Honor."
DATA "Dost thou wish to continue thy quest?&Y"
DATA "Rest then for awhile."
DATA "Go #P!"
DATA "Please push RESET, hold it in, then turn off the POWER."
DATA "If you turn the power off first, the Imperial Scroll of Honor containing your deeds may be lost."
DATA "Unfortunately, NO deeds were recorded on Imperial Scroll number #N."
DATA "CONGRATULATIONS"
DATA "THOU HAST RESTORED PEACE UNTO THE WORLD"
DATA "BUT THERE ARE MANY ROADS YET TO TRAVEL"
DATA "MAY THE LIGHT SHINE UPON THEE DRAGON WARRIOR"
DATA "And I would like to have something of thine--a token."
DATA "Sorry, I am speechless"
DATA "The #Es MP is too low."
'NPC data
'  MAP, X,Y,Sprite,Moves?,Dialog array handle,facing
NPCs: 'Castle Tantegel---------------------------
DATA 1,17,17,9,0,0,0
DATA 1,20,17,10,0,1,0
DATA 1,17,20,13,0,2,3
DATA 1,19,20,13,0,4,1
DATA 1,21,19,13,-1,3,0
'---------------------
DATA 0,15,8,13,-1,5,0
DATA 0,32,9,20,0,6,0
DATA 0,35,13,19,0,7,0
DATA 0,33,17,14,-1,8,0
DATA 0,27,21,15,-1,9,0
DATA 0,34,23,13,0,10,0
DATA 0,34,29,14,0,11,0
DATA 0,16,14,13,0,12,0
DATA 0,16,16,13,0,13,2
DATA 0,19,19,18,-1,14,0
DATA 0,10,16,17,0,15,0
DATA 0,10,20,13,-1,16,0
DATA 0,16,21,19,-1,17,0
DATA 0,15,32,20,-1,18,0
DATA 0,14,33,20,-1,19,0
DATA 0,23,28,13,0,20,0
DATA 0,25,27,13,-1,21,0
DATA 0,28,34,15,0,22,0
DATA 0,17,35,13,0,23,3
DATA 0,20,35,13,0,24,1
'----------------------
DATA 2,20,24,15,0,25,0
'----------------------Brecconary
DATA 3,36,9,14,0,26,0
DATA 3,13,12,20,0,27,0
DATA 3,12,15,19,0,28,0
DATA 3,9,21,18,0,29,0
DATA 3,28,18,18,0,30,0
DATA 3,32,18,15,0,31,0
DATA 3,29,21,20,-1,32,0
DATA 3,36,21,13,0,33,0
DATA 3,27,24,14,-1,34,0
DATA 3,14,25,15,-1,35,0
DATA 3,18,29,20,0,36,0
DATA 3,11,30,14,-1,37,0
DATA 3,18,34,13,-1,38,0
DATA 3,21,30,18,-1,39,0
DATA 3,21,35,19,-1,40,0
DATA 3,28,30,18,-1,41,0
DATA 3,28,31,18,-1,42,0
DATA 3,19,18,14,-1,43,0
'-----------------------
DATA 4,32,12,19,0,44,0
DATA 4,33,33,20,0,45,0
'-----------------------Garinham
DATA 13,15,23,15,-1,46,0
DATA 13,18,24,20,0,47,0
DATA 13,15,30,19,-1,48,0
DATA 13,20,30,14,-1,49,0
DATA 13,30,24,17,-1,50,0
DATA 13,24,25,18,-1,51,0
DATA 13,23,31,20,0,52,0
DATA 13,30,28,20,0,53,0
DATA 13,27,14,15,0,54,0
'------------------------
DATA 14,16,18,13,0,55,0
DATA 14,18,18,13,0,56,0
DATA 14,16,21,18,-1,57,0
DATA 14,22,19,20,0,58,0
DATA 14,25,18,19,0,59,0
DATA 14,26,21,15,-1,60,0
'------------------------Kol
DATA 20,13,13,15,0,61,0
DATA 20,23,13,19,-1,62,0
DATA 20,31,16,20,0,63,0
DATA 20,18,18,14,-1,64,0
DATA 20,25,21,13,-1,65,0
DATA 20,31,20,15,-1,66,0
DATA 20,14,24,15,0,67,0
DATA 20,17,24,18,-1,68,0
DATA 20,34,24,20,0,69,0
DATA 20,32,25,14,-1,70,0
DATA 20,26,26,18,-1,71,0
DATA 20,23,27,19,-1,72,0
DATA 20,19,31,20,-1,73,0
DATA 20,32,31,15,-1,74,0
DATA 20,26,33,20,0,75,0
DATA 20,13,35,13,0,76,0
'-----------------------Rimuldar
DATA 25,35,8,18,0,77,0
DATA 25,10,12,20,0,78,0
DATA 25,31,15,20,0,79,0
DATA 25,19,16,18,0,80,0
DATA 25,23,16,19,0,81,0
DATA 25,31,19,14,-1,82,0
DATA 25,21,20,18,-1,83,0
DATA 25,14,21,15,0,84,0
DATA 25,16,23,13,-1,85,0
DATA 25,30,22,19,-1,86,0
DATA 25,24,26,20,0,87,0
DATA 25,32,27,14,-1,88,0
DATA 25,28,31,15,0,89,0
DATA 25,23,34,14,-1,90,0
DATA 25,8,34,19,0,91,0
'-------------------------
DATA 26,12,15,15,0,92,0
DATA 26,11,31,15,0,93,0
DATA 26,12,29,17,-1,94,0
DATA 26,14,29,16,-1,95,0
DATA 26,11,32,14,-1,96,0
'------------------------Cantlin
DATA 5,15,10,20,0,97,0
DATA 5,29,12,20,-1,98,0
DATA 5,22,13,13,-1,99,0
DATA 5,34,13,15,0,100,0
DATA 5,9,14,18,0,101,0
DATA 5,29,16,13,-1,102,0
DATA 5,9,19,20,0,103,0
DATA 5,14,19,20,0,104,0
DATA 5,31,19,13,-1,105,0
DATA 5,29,20,19,0,106,0
DATA 5,11,21,19,-1,107,0
DATA 5,17,21,19,-1,108,0
DATA 5,32,22,20,-1,109,0
DATA 5,27,23,18,-1,110,0
DATA 5,29,29,15,0,111,0
DATA 5,34,33,20,0,112,0
DATA 5,10,34,20,0,113,0
DATA 5,21,35,15,0,114,0
DATA 5,11,12,13,-1,115,0
'-----------------------
DATA 6,22,23,15,-1,116,0
'--------------------------Rain Shrine
DATA 23,20,20,15,0,117,0
'--------------------------Rainbow Temple
DATA 24,21,20,15,0,118,0
'DragonLord
DATA 10,23,31,11,0,119,0


'Dialog Data: Line count, lines ...
Dialogs:
'No Stairs Here message 0
DATA 1,13
'No one to talk to Message 1
DATA 1,15
'Nothing to find searching 2
DATA 2,237,238
'cannot use spells 3
DATA 1,48
'no item to use 4
DATA 1,60
'no door to open 5
DATA 1,311
'no item to take 6
DATA 1,242

'อออออออออออออออออออออออออออออออออThrone Room Charactersอออออออออออออออออออออออออออออออออออออออออออ
'kings Introductory monologue 7 ---------------------kings dialog---------------
DATA 8,289,290,291,292,293,294,295,296
'Kings second dialog when returning, tells needed EXP for level up then save or not 8
DATA 3,216,217,348
'Player chooses to SAVE 9
DATA 2,349,350
'Kings dialog to continue game or quit 10
DATA 1,350
'player chooses to quit 11
DATA 1,351
'player chooses to continue playing 12
DATA 1,219
'Kings Dialog when loading game 13
DATA 4,216,217,326,219
'Kings Dialog when done with intro monologue before leaving thrown room 14
DATA 1,215
'King thanks player for returning Princess 15
DATA 2,205,206
'King asks player if they want to save 16
DATA 1,348

'princess monologue  17
DATA 3,200,201,220
'she is so happy! 18
DATA 1,204
'player wont take her to castle(But thou must) 19
DATA 2,202,220
'player says yes(plays music between lines) 20
DATA 1,203
'upon being returned to castle after king thanks player 21
DATA 5,207,208,209,211,212
'when talked to after being returned 1st time 22
DATA 1,213
'from 2nd time onward yes\no 23
DATA 1,214

'Gaurd Roaming Throne Room
'asks if player know about the princess 24
DATA 1,172
'player says no 25
DATA 3,173,174,175
'player says yes 26
DATA 1,175
'if player has Princess/saved princess 27
DATA 1,176

'Left Hand Gaurd Throne Room
'before you first leave throne room 28
DATA 3,286,287,288
're-entering throne room 29
DATA 2,83,84

'Right Hand Gaurd Throne Room
'before you first leave throne room 30
DATA 2,284,285
're-entering throne room 31
DATA 1,85
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'ออออออออออออออออออออออออออออออTanTegel Castle Courtyardอออออออออออออออออออออออออออออออออออออออออออ
'Guard North side stairs 32
DATA 1,72
'Guard North side stairs 33
DATA 1,4
'girl in center 34
DATA 1,164
'boy in center 35
DATA 1,75
'merchant 1 bottom left 36
DATA 1,79
'merchant 2 bottom left 37
DATA 1,80
'Guard in treasure room 38
DATA 1,74
'Boy above treasure room 39
DATA 1,71
'Guard roaming in north of stairs 40
DATA 1,70
'Red Guard roaming north right 41
DATA 1,69
'Girl north right 42
DATA 2,73,191
'Guard outside damage floor room 43
DATA 1,78
'Wizard right side 44
DATA 2,76,77
'Red Gaurd in damage room 45
DATA 1,82
'Guard roaming right of pool 46
DATA 1,154
'Guard standing right of pool
'before saving princess 47
DATA 1,164
'after saving princess 48
DATA 1,167
'Key sales man 49
DATA 1,22
'player says no 50
DATA 1,18
'player says yes 51
DATA 1,21
'Player doesn't have the gold 52
DATA 2,19,18
'Player has too many keys 53
DATA 2,20,18
'Wizard bottom right 54
DATA 1,188
'Guard left of exit 55
DATA 1,81
'Guard right of exit 56
DATA 1,81
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'อออออออออออออออออออออออออออออTanTegel celarอออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Wizard in castle celar
'before taking the chest 57
DATA 2,177,221
'after taking chest 58
DATA 1,178
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'อออออออออออออออออออออออออออออออออออBrecconaryอออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Red guard in top right corner 59
DATA 2,86,87
'Armory shopkeep 60
DATA 1,39
'player answers no 61
DATA 1,46
'player answers yes 62
DATA 1,44
'player selects item to buy 63
DATA 2,40,38
'player answer no 64
DATA 2,37,43
'player answers yes and has enough gold 65
DATA 2,45,43
'player answers yes with too little gold to buy 66
DATA 2,42,43
'player has a weapon or armor already 67
DATA 2,41,38
'Woman Standing outside shop 68
DATA 1,91
'Boy at entrance of town 69
DATA 1,92
'Boy in room 70
DATA 1,88
'Wizard in room
'Not cursed 71
DATA 1,179
'Cursed 72
DATA 2,180,181
'Roaming Merchant 73
DATA 1,96
'Guard far right in town 74
DATA 1,97
'Red Guard Roaming 75
DATA 2,147,148
'Roaming Wizard 76
DATA 1,93
'Inn Keeper 77
DATA 1,11
'player says no 78
DATA 1,10
'player says yes 79
DATA 1,9
'after player `wakes`80
DATA 2,8,7
'Roaming Red Guard in Inn 81
DATA 1,89
'Guard in Inn 82
DATA 2,168,169
'Roaming Boy 83
DATA 1,94
'Roaming girl 84
DATA 1,95
'Roaming boy across bridge 85
DATA 2,99,100
'Boy across bridge 86
DATA 1,90
'Roaming Red Guard 87
DATA 1,98
'Girl selling fairy water 88
DATA 1,17
'player says no 89
DATA 1,12
'player says yes 90
DATA 1,16
'player has no gold 91
DATA 1,19
'players inventory is full 92
DATA 1,32
'Tool shop keep 93
DATA 1,36
'player choses Sell 94
DATA 1,28
'player chooses sell with no items 95
DATA 2,24,29
'player picks item 96
DATA 1,27
'player chooses no 97
DATA 1,25
'player chooses yes 98
DATA 1,25
'player chooses Buy 99
DATA 1,35
'Player picks an item 100
DATA 2,34,30
'player doesn't have the gold 101
DATA 2,19,30
'Player cannot carry any more Herbs 102
DATA 2,31,30
'Player cannot carry any more items 103
DATA 2,32,30
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'อออออออออออออออออออออออออออออออออออออGarinhamอออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Roaming Wizard by item shop 104
DATA 1,118
'tool shopkeep 105
DATA 1,36
'player choses Sell 106
DATA 1,28
'player chooses sell with no items 107
DATA 2,24,29
'player picks item 108
DATA 1,27
'player chooses no 109
DATA 1,25
'player chooses yes 110
DATA 1,25
'player chooses Buy 111
DATA 1,35
'Player picks an item 112
DATA 2,34,30
'player doesn't have the gold 113
DATA 2,19,30
'Player cannot carry any more Herbs 114
DATA 2,31,30
'Player cannot carry any more items 115
DATA 2,32,30
'Wizard south of entrace 116
DATA 1,116
'Roaming Red Gaurd 117
DATA 1,117
'Roaming girl 118
DATA 1,119
'Roaming Boy 119
DATA 1,120
'Armory shop keep 120
DATA 1,39
'player answers no 121
DATA 1,46
'player answers yes 122
DATA 1,44
'player selects item to buy 123
DATA 2,40,38
'player answer no 124
DATA 2,37,43
'player answers yes and has enough gold 125
DATA 2,45,43
'player answers yes with too little gold to buy 126
DATA 2,42,43
'player has a weapon or armor already 127
DATA 2,41,38
'Inn Keeper 128
DATA 1,11
'player says no 129
DATA 1,10
'player says yes 130
DATA 1,9
'after player `wakes`131
DATA 2,8,7
'Wizard by the cave entrace 132
DATA 1,110
'ออออออออออออออออออออออออออออออPeople inside building in Garinhamออออออออออออออออออออออออออออออออออ
'Left Guard in little room 133
DATA 1,111
'right Guard in little room 134
DATA 1,111
'Roaming Boy 135
DATA 1,113
'merchant in middle of room 136
DATA 1,112
'Roaming Girl 137
DATA 1,114
'Roaming Wizard 138
DATA 1,115
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'อออออออออออออออออออออออออออออออออออออออออ Kol อออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Wizard in top left 139
DATA 1,140
'girl by fountain 140
DATA 1,101
'Inn Keeper 141
DATA 1,11
'player says no 142
DATA 1,10
'player says yes 143
DATA 1,9
'after player `wakes`144
DATA 2,8,7
'Roaming Red gaurd 145
DATA 1,104
'Roaming Gaurd 146
DATA 1,107
'Roaming Wizard 147
DATA 1,109
'Wizard in room 148
DATA 1,149
'player says no 149
DATA 1,159
'player says yes 150
DATA 1,155
'Roaming boy behind door 151
DATA 1,98
'Armory shop keep 152
DATA 1,39
'player answers no 153
DATA 1,46
'player answers yes 154
DATA 1,44
'player selects item to buy 155
DATA 2,40,38
'player answer no 156
DATA 2,37,43
'player answers yes and has enough gold 157
DATA 2,45,43
'player answers yes with too little gold to buy 158
DATA 2,42,43
'player has a weapon or armor already 159
DATA 2,41,38
'Red Gaurd at Armory 160
DATA 1,102
'Roaming Boy courtyard 161
DATA 2,105,106
'Roaming girl in courtyard 162
DATA 1,96
'Roaming merchant 163
DATA 1,150
'player says no 164
DATA 1,160
'player says yes 165
DATA 1,156
'Wizard at entrace 166
DATA 1,108
'tool shopkeep 167
DATA 1,36
'player choses Sell 168
DATA 1,28
'player chooses sell with no items 169
DATA 2,24,29
'player picks item 170
DATA 1,27
'player chooses no 171
DATA 1,25
'player chooses yes 172
DATA 1,25
'player chooses Buy 173
DATA 1,35
'Player picks an item 174
DATA 2,34,30
'player doesn't have the gold 175
DATA 2,19,30
'Player cannot carry any more Herbs 176
DATA 2,31,30
'Player cannot carry any more items 177
DATA 2,32,30
'Gaurd bottom left town 178
DATA 1,103
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'ออออออออออออออออออออออออออออออออออออ Rimuldar ออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Boy in Top right 179
DATA 1,134
'Merchant by the key seller 180
DATA 1,132
'Armory shop keep 181
DATA 1,39
'player answers no 182
DATA 1,46
'player answers yes 183
DATA 1,44
'player selects item to buy 184
DATA 2,40,38
'player answer no 185
DATA 2,37,43
'player answers yes and has enough gold 186
DATA 2,45,43
'player answers yes with too little gold to buy 187
DATA 2,42,43
'player has a weapon or armor already 188
DATA 2,41,38
'Roaming boy in room 189
DATA 1,98
'Girl in room 190
DATA 1,133
'roaming Red Gaurd in Armory 191
DATA 1,135
'Roaming Boy 192
DATA 1,139
'Wizard on island 193
DATA 2,136,137
'Roaming Gaurd 194
DATA 1,138
'Roaming girl 195
DATA 1,140
'Inn Keeper 196
DATA 1,11
'player says no 197
DATA 1,10
'player says yes 198
DATA 1,9
'after player `wakes`199
DATA 2,8,7
'Roaming Red Gaurd in INN 200
DATA 1,141
'Wizard in INN 201
DATA 1,142
'roaming Red gaurd 202
DATA 1,187
'Girl south left town 203
DATA 1,146
'อออออออออออออออออออออออออออออInside building in Rimuldarอออออออออออออออออออออออออออออออออออออออออ
'Key sales man 204
DATA 1,22
'player says no 205
DATA 1,18
'player says yes 206
DATA 1,21
'Player doesn't have the gold 207
DATA 2,19,18
'Player has too many keys 208
DATA 2,20,18
'Wizard behind desk 209
DATA 1,153
'player says no 210
DATA 1,163
'player says yes 211
DATA 1,158
'Boy roaming 212
DATA 1,144
'roaming girl 213
DATA 1,143
'roaming Red Gaurd 214
DATA 1,145
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'ออออออออออออออออออออออออออออออออออออออ Cantlin อออออออออออออออออออออออออออออออออออออออออออออออออออ
'Inn Keeper 215
DATA 1,11
'player says no 216
DATA 1,10
'player says yes 217
DATA 1,9
'after player `wakes`218
DATA 2,8,7
'Armory shop keep 219
DATA 1,39
'player answers no 220
DATA 1,46
'player answers yes 221
DATA 1,44
'player selects item to buy 222
DATA 2,40,38
'player answer no 223
DATA 2,37,43
'player answers yes and has enough gold 224
DATA 2,45,43
'player answers yes with too little gold to buy 225
DATA 2,42,43
'player has a weapon or armor already 226
DATA 2,41,38
'Roaming Gaurd at town entrance 227
DATA 1,124
'Key sales man 228
DATA 1,22
'player says no 229
DATA 1,18
'player says yes 230
DATA 1,21
'Player doesn't have the gold 231
DATA 2,19,18
'Player has too many keys 232
DATA 2,20,18
'Boy item shop keep 233
DATA 1,36
'player choses Sell 234
DATA 1,28
'player chooses sell with no items 235
DATA 2,24,29
'player picks item 236
DATA 1,27
'player chooses no 237
DATA 1,25
'player chooses yes 238
DATA 1,25
'player chooses Buy 239
DATA 1,35
'Player picks an item 240
DATA 2,34,30
'player doesn't have the gold 241
DATA 2,19,30
'Player cannot carry any more Herbs 242
DATA 2,31,30
'Player cannot carry any more items 243
DATA 2,32,30
'Roaming Gaurd below armory 244
DATA 2,129,130
'Mercant behind desk 245
DATA 1,121
'item shop keep 246
DATA 1,36
'player choses Sell 247
DATA 1,28
'player chooses sell with no items 248
DATA 2,24,29
'player picks item 249
DATA 1,27
'player chooses no 250
DATA 1,25
'player chooses yes 251
DATA 1,25
'player chooses Buy 252
DATA 1,35
'Player picks an item 253
DATA 2,34,30
'player doesn't have the gold 254
DATA 2,19,30
'Player cannot carry any more items 255
DATA 2,32,30
'Armory shop keep 256
DATA 1,39
'player answers no 257
DATA 1,46
'player answers yes 258
DATA 1,44
'player selects item to buy 259
DATA 2,40,38
'player answer no 260
DATA 2,37,43
'player answers yes and has enough gold 261
DATA 2,45,43
'player answers yes with too little gold to buy 262
DATA 2,42,43
'player has a weapon or armor already 263
DATA 2,41,38
'Girl selling fairy water 264
DATA 1,17
'player says no 265
DATA 1,12
'player says yes 266
DATA 1,16
'player has no gold 267
DATA 1,19
'players inventory is full 268
DATA 1,32
'Roaming Girl 1 269
DATA 1,125
'Roaming Girl 2 270
DATA 1,126
'Roaming Merchant 271
DATA 1,128
'roaming boy 272
DATA 1,127
'Wizard behind desk 273
DATA 1,123
'Armory shop keep 274
DATA 1,39
'player answers no 275
DATA 1,46
'player answers yes 276
DATA 1,44
'player selects item to buy 277
DATA 2,40,38
'player answer no 278
DATA 2,37,43
'player answers yes and has enough gold 279
DATA 2,45,43
'player answers yes with too little gold to buy 280
DATA 2,42,43
'player has a weapon or armor already 281
DATA 2,41,38
'Roaming Merchant in room 282
DATA 1,131
'Roaming Wizard in damage area 283
DATA 4,76,77,189,190
'Gaurd roaming top left town 284
DATA 2,151,152
'player says no 285
DATA 2,161,162
'player says yes 286
DATA 1,157
'Wizard inside building 287
DATA 1,122
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'อออออออออออออออออออออออออออออออRain shrineออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Wizard before geting harp 288
DATA 4,192,193,194,195
'after player gets harp 289
DATA 3,196,177,221
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'อออออออออออออออออออออออออออออออRainbow templeอออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Wizard before prof obtained 290
DATA 2,197,198
'After player finds token 291
DATA 2,73,189
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
'Dragon Lord 292
DATA 4,222,177,223,224
'player says no 293  (battle ensues)
DATA 1,225
'player says yes 294
DATA 1,324
'player says no 295 (battle ensues)
DATA 1,225
'player says yes 296 (game over)
DATA 5,226,218,227,228,229

'beating dragonlord 1st form 297
DATA 1,327
'defeated dragonlord 298
DATA 3,328,329,330

'after defeating dragonlord all npcs in towns 299
DATA 1,344
'after defeating dragonlord all shopkeeps 300
DATA 1,343
'after defeating dragonlord all NPCs in castle 301
DATA 1,345

'player returns to castle talks to king 302
DATA 8,331,332,333,334,335,336,337,338
'if player saved princess 303
DATA 4,339,340,341,342
'player says no 304 (goes back to yes no)
DATA 2,202,342
'player says yes 305
DATA 1,204
'all done 306
DATA 2,346,347
'missing princess line(s)
'player does not love her 307(but thou MUST!)
DATA 2,202,214
'when using Gwaelin's love 308
DATA 2,247,248
'Gwaelin's love gives position when in Over World 309
DATA 1,249
'gives north value 310
DATA 1,250
'gives south value 311
DATA 1,251
'gives east value 312
DATA 1,252
'gives west value 313
DATA 1,253

'Missing King Line(s)
'After player dies 314
DATA 4,313,314,319,320

'Action lines
'Trys to open door without a key 315
DATA 1,312
'uses Wyvern wings 316
DATA 1,56
'trys to uses Wyvern Wings in cave 317
DATA 1,55
'Trys to use a torch in lit area 318
DATA 1,52
'Player puts on a Dragon's Scale 319
DATA 1,57
'Player trys to put on a dragon's scale more than once 320
DATA 1,58
'uses fairy water 321
DATA 1,53
'uses an herb 322
DATA 1,276
'trys to use a key with no door 323
DATA 1,311
'When 'taking' a chest 324
DATA 2,244,245
'when a chest is empty 325
DATA 1,246
'when reading the tablet 326
DATA 7,297,298,299,300,301,302,303
'when casting a spell with no effect 327
DATA 1,50
'when casting a spell 328
DATA 1,47
'when putting on the cursed belt\necklace 329
DATA 2,65,66
'after putting on the cursed belt\necklace 330
DATA 1,67
'uses the Fairies' Flute 331
DATA 1,59
'Fairies' Flute only works on golem 332
DATA 1,272
'The enemy is asleep 333
DATA 1,277
'tries to open door with no key 334
DATA 1,312
'Player opens a chest containing gold 335
DATA 1,243
'player opens a chest with an item while inventory is full 336
DATA 2,230,231
'player chooses not to keep item from chest 337
DATA 1,232
'player chooses to drop an item to keep item from chest 338
DATA 1,233
'after player decides what to drop 339
DATA 1,234
'what player collects after droping 340
DATA 1,235
'Player searches an finds something 341
DATA 1,237
'player finds a treasure box 342
DATA 1,239
'player finds an item 343
DATA 1,240
'player feels wind behind dragonlord throne 344
DATA 1,241
'player trys to cast a spell with no MP 345
DATA 1,49

'player trys to run away from battle 346
DATA 1,274
'player is blocked from running 347
DATA 1,275
'player enters fight 348
DATA 1,254
'promts player for battle commands 349
DATA 1,260
'player attacks and hits 350
DATA 1,258
'player attacks and missed 351
DATA 1,259
'monster attacks 352
DATA 1,278
'monster attack misses 353
DATA 1,280
'monster runs away 354
DATA 1,255
'monster attacks first 355
DATA 1,256
'Excellent attack 356
DATA 1,304
'monster dodged the attack 357
DATA 1,310
'player tries to use an item in battle 358
DATA 1,261
'player uses silver harp while in a battle 359
DATA 1,273
'players spell does not work 360
DATA 1,263
'using Gwaelin's love at final level 361
DATA 1,305
'Talking to king at final level 362
DATA 1,3
'Enemy attack hits player  363
DATA 1,279
'Player has defeated enemy 364
DATA 1,266
'player gains in experiance and gold 365
DATA 2,267,268
'player goes up a level 366
DATA 2,269,270
'player gains in strength stat 367
DATA 1,315
'player gains new spell 368
DATA 1,271
'player get killed in battle 369
DATA 1,2
'player is asleep 370
DATA 1,306
'player is still asleep 371
DATA 1,307
'player wakes up 372
DATA 1,308
'players spell is blocked 373
DATA 1,262
'mosnter cast spell 374
DATA 1,281
'monsters spell is blocked 375
DATA 1,265
'monster is put to sleep 376
DATA 1,264
'monster wakes up 377
DATA 1,309
'monsters MP is too low 378
DATA 1,362
'monster is breathing fire 379
DATA 1,283
'monster is still asleep 380
DATA 1,277
'player gains in agility stat 381
DATA 1,316
'player gains in hp stat 382
DATA 1,317
'player gains in mp stat 383
DATA 1,318

SelectionArrow:
DATA 13,4,13,6,13,8,13,10,21,4,21,6,21,8,21,10,0,0,0,0
BattleSelectionArrow:
DATA 13,4,13,6,21,4,21,6
LetterSelection:
DATA 6,11,65,8,11,66,10,11,67,12,11,68,14,11,69,16,11,70,18,11,71,20,11,72,22,11,73,24,11,74,26,11,75,6,13,76,8,13,77,10,13,78,12,13,79,14,13,80,16,13,81,18,13,82,20,13,83,22,13,84,24,13,85,26,13,86,6,15,87,8,15,88,10,15,89,12,15,90,14,15,45,16,15,39,18,15,33,20,15,63,22,15,40,24,15,41,26,15,32,6,17,97,8,17,98,10,17,99,12,17,100,14,17,101,16,17,102,18,17,103,20,17,104,22,17,105,24,17,106,26,17,107,6,19,108,8,19,109,10,19,110,12,19,111,14,19,112,16,19,113,18,19,114,20,19,115,22,19,116,24,19,117,26,19,118,6,21,119,8,21,120,10,21,121,12,21,122,14,21,44,16,21,46,18,21,0,24,21,0

'END OF DATA---------------------------------------------------------------------------------------
RESTORE MonsterZoneGroups
FOR i%% = 0 TO 19
    FOR j%% = 0 TO 4
        READ MZG(i%%, j%%)
    NEXT j%%
NEXT i%%

RESTORE SelectionArrow
FOR i%% = 1 TO 10
    READ SA(i%%).X, SA(i%%).Y
NEXT i%%

RESTORE BattleSelectionArrow
FOR i%% = 1 TO 4
    READ BSA(i%%).X, BSA(i%%).Y
NEXT i%%

RESTORE LetterSelection
FOR i%% = 1 TO 63
    READ temp%%
    LS(i%%).X = temp%% - 1 'offset correction, each location is 1 to big(Opps!)
    READ LS(i%%).Y, LS(i%%).C
NEXT i%%

RESTORE NPCs
FOR i%% = 0 TO 119
    READ MAP%%, X%%, Y%%, ID%%, M%%, DID%%, F%%
    NPC(i%%).Map = MAP%%
    NPC(i%%).X = X%%
    NPC(i%%).Y = Y%%
    NPC(i%%).Sprite_ID = ID%%
    NPC(i%%).Can_Move = M%%
    NPC(i%%).Lines = DID%% 'points to NPCs current monologue index
    NPC(i%%).Facing = F%%
NEXT i%%

RESTORE Dialogs
FOR i% = 0 TO 383 'id
    READ L%%
    ' NPCDialog(i%%, 1).LineCount = L%%
    Messages(i%, 0) = i%
    Messages(i%, 1) = L%%
    FOR k%% = 0 TO L%% - 1 'Lines spoken
        READ lin%
        Lines(i%, k%%) = lin%
        PRINT i%; k%%; lin%
    NEXT k%%
NEXT i%
_DELAY .5

'load tile data for all castles, towns, caves, temples
RESTORE MapTiledatafiles:
FOR i%% = 0 TO 26
    READ File$(i%%)
NEXT i%%

FOR i%% = 0 TO 26
    READ Sx%%, Sy%%, Ex%%, Ey%%
    OPEN "data\" + File$(i%%) + ".dat" FOR BINARY AS #1
    FOR k%% = 0 TO 45
        FOR j%% = 0 TO 45
            IF j%% = Sx%% THEN Place(i%%, j%%, k%%).Is_Exit = TRUE: l% = l% + 1
            IF j%% = Ex%% THEN Place(i%%, j%%, k%%).Is_Exit = TRUE: l% = l% + 1
            IF k%% = Sy%% THEN Place(i%%, j%%, k%%).Is_Exit = TRUE: l% = l% + 1
            IF k%% = Ey%% THEN Place(i%%, j%%, k%%).Is_Exit = TRUE: l% = l% + 1
            GET #1, , Place(i%%, j%%, k%%).Sprite_ID
            IF INKEY$ = CHR$(27) THEN END
    NEXT j%%, k%%
    CLOSE
    l% = 0
    IF INKEY$ = CHR$(27) THEN OPEN "temp.dat" FOR BINARY AS #1: PUT #1, , Place(): CLOSE: END
NEXT i%%
'-----------------------------------------------------
'Load Entry Points for towns\castles and caves\temples
RESTORE EntryPoints
FOR i%% = 0 TO 7
    READ MAP%%, X%%, Y%%
    PD(MAP%%).Start_X = X%%
    PD(MAP%%).Start_Y = Y%%
NEXT i%%

RESTORE CaveEntryPoints
FOR i%% = 0 TO 5
    READ X%%, Y%%
    World(X%%, Y%%).Is_Cave = TRUE
NEXT i%%

RESTORE IsLit
FOR i%% = -1 TO 26
    READ X%%
    IF X%% = 1 THEN PD(i%%).Is_Lit = TRUE ELSE PD(i%%).Is_Lit = FALSE
NEXT i%%
'-----------------------------------------------------
'load shop item lists
RESTORE ShopItemLists
FOR i%% = 1 TO 12
    READ c%%
    FOR j%% = 1 TO c%%
        READ k%%
        Shop(i%%, j%%) = k%%
    NEXT j%%
NEXT i%%
'------------------------------------------------------
'Load The World tile data
RESTORE world
OPEN "DATA\worldmap_tiles2.dat" FOR BINARY AS #1
FOR y~%% = 0 TO 121
    FOR x~%% = 0 TO 121
        GET #1, , World(x~%%, y~%%).Sprite_ID ' Load the Tile sprite ids for the world map
        SELECT CASE World(x~%%, y~%%).Sprite_ID
            CASE 0, 4, 8, 9, 37 'grasslands,bridges,stairs(indoor),chest
                World(x~%%, y~%%).Encounter_rate = 6
            CASE 2, 5 'hills, desert
                World(x~%%, y~%%).Encounter_rate = 16
            CASE ELSE
                World(x~%%, y~%%).Encounter_rate = 8
        END SELECT
NEXT x~%%, y~%%
CLOSE

FOR i%% = 0 TO 7
    READ X%%, Y%%, ID%%
    World(X%%, Y%%).Is_Town = ID%%
NEXT i%%
FOR i%% = 0 TO 5
    READ X%%, Y%%, ID%%
    World(X%%, Y%%).Is_Cave = ID%%
NEXT i%%

FOR i%% = 0 TO 7
    FOR j%% = 0 TO 7
        X1%% = 16 * j%%
        Y1%% = 16 * i%%
        READ Z%% 'encouter territory
        FOR Y%% = 0 TO 15
            FOR X%% = 0 TO 15
                World(X1%% + X%%, Y1%% + Y%%).Territory = Z%%
        NEXT X%%, Y%%
NEXT j%%, i%%
'Overworld specials
READ S%%
FOR i%% = 1 TO S%%
    READ X%%, Y%%, ID%%
    World(X%%, Y%%).Has_Special = ID%%
NEXT i%%
'specials for towns\caves\castle
READ S%%
FOR i%% = 1 TO S%%
    READ MAP%%, X%%, Y%%, ID%%
    Place(MAP%%, X%%, Y%%).Has_Special = ID%%
NEXT i%%

'------------------------------------------------------

'Load Stair data
RESTORE StairData
FOR i%% = 1 TO 85
    READ MAP%%, X1%%, Y1%%, D%%, L%%
    Stairs(i%%).X = X1%% 'when using stairs this mirrors stairs locations, when entering a town
    Stairs(i%%).Y = Y1%% 'or castle, this is where you first appear.
    Stairs(i%%).Link = L%%
    Stairs(i%%).Direction = D%%
    Stairs(i%%).Map = MAP%%
    IF MAP%% >= 0 THEN Place(MAP%%, X1%%, Y1%%).Is_Stairs = i%% ELSE World(X1%%, Y1%%).Is_Stairs = i%%
NEXT i%%
'------------------------------------------------------

'load items XP level requirements, Group factor, and monsters
RESTORE items
FOR i%% = 0 TO 40
    READ I(i%%).Nam, I(i%%).Valu, I(i%%).Power
NEXT i%%
FOR i%% = 0 TO 30
    READ L(i%%)
NEXT i%%
FOR i%% = 1 TO 5
    READ GF(i%%)
NEXT i%%

RESTORE Monsters
FOR i%% = 0 TO 40
    READ M(i%%).Nam, M(i%%).Strength, M(i%%).Agility, M(i%%).Max_Hp, M(i%%).Max_Mp, M(i%%).SlpResist
    READ M(i%%).StpSplResist, M(i%%).HurtResist, M(i%%).Evasion, M(i%%).Exp, M(i%%).Gold, M(i%%).Attk1
    READ M(i%%).Attk1Prob, M(i%%).Attk2, M(i%%).Attk2Prob, M(i%%).Group
    ' PRINT i%%; M(i%%).Nam
NEXT i%%
'------------------------------------------------------
'load treasure chests
RESTORE Treasure
FOR i%% = 0 TO 33
    READ MAP%%, X1%%, Y1%%, ID%%, C%
    Chest(i%%).Map = MAP%%
    Chest(i%%).X = X1%%
    Chest(i%%).Y = Y1%%
    Chest(i%%).Treasure = ID%%
    Chest(i%%).Count = C%
    Chest(i%%).Opened = 0
    Place(MAP%%, X1%%, Y1%%).Has_Special = 7 + i%%
NEXT i%%
'------------------------------------------------------
'load door data
RESTORE Doors
FOR i%% = 0 TO 17
    READ MAP%%, X1%%, Y1%%, ID%%
    Doors(i%%).Map = MAP%%
    Doors(i%%).X = X1%%
    Doors(i%%).Y = Y1%%
    Doors(i%%).Opened = ID%%
NEXT i%%
'------------------------------------------------------
'load game script
RESTORE Scriptlines
FOR i% = 1 TO 362
    READ Script(i%)
NEXT i%
'------------------------------------------------------
'Load spell names
RESTORE SpellNames
FOR i% = 1 TO 12
    READ Spells(i%)
NEXT i%
'------------------------------------------------------
'load map musics
RESTORE MapMusicData
FOR i% = -1 TO 26
    READ Map_Music(i%)
NEXT i%
'------------------------------------------------------
'Load key code names for custom controls
RESTORE KeyCodesData
FOR i~%% = 0 TO 133
    READ KeyCodes(i~%%).Nam, KeyCodes(i~%%).Value
    IF i~%% < 22 THEN PRINT KeyCodes(i~%%).Nam; "-"; KeyCodes(i~%%).Value
NEXT i~%%
'------------------------------------------------------
'Load Entrance and exit data for buildings
RESTORE BuildingEntryPoints
FOR i%% = 1 TO 37
    READ Entrance(i%%).Map, Entrance(i%%).X, Entrance(i%%).Y, Entrance(i%%).Link
    Place(Entrance(i%%).Map, Entrance(i%%).X, Entrance(i%%).Y).Is_Entrance = i%%
NEXT i%%
RESTORE BuildingExitpoints
FOR i%% = 38 TO 77
    READ Entrance(i%%).Map, Entrance(i%%).X, Entrance(i%%).Y, Entrance(i%%).Link
    Place(Entrance(i%%).Map, Entrance(i%%).X, Entrance(i%%).Y).Building_Exit = i%%
NEXT i%%
'------------------------------------------------------

IF _FILEEXISTS("GameDataV1_1b.dat") THEN KILL "GameDataV1_1b.dat"
OPEN "GameDataV1_1b.dat" FOR BINARY AS #1
PUT #1, , World()
PUT #1, , Place()
PUT #1, , I()
PUT #1, , L()
PUT #1, , GF()
PUT #1, , M()
PUT #1, , Stairs()
PUT #1, , PD()
PUT #1, , Chest()
FOR i% = 1 TO 362
    L~%% = LEN(Script(i%))
    PUT #1, , L~%%
    PUT #1, , Script(i%)
NEXT
PUT #1, , NPC()
PUT #1, , Lines()
PUT #1, , SA()
PUT #1, , BSA()
PUT #1, , LS()
PUT #1, , Messages()
PUT #1, , Shop()
PUT #1, , Doors()
FOR i% = 1 TO 12
    L~%% = LEN(Spells(i%))
    PUT #1, , L~%%
    PUT #1, , Spells(i%)
NEXT
PUT #1, , MZG()
PUT #1, , Map_Music()
PUT #1, , KeyCodes()
PUT #1, , Entrance()
CLOSE #1
