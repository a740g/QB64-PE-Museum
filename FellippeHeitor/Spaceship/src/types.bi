'Spaceship - constants, types and shared state
'This file is pure ASCII on purpose: CP437 characters are always written with CHR$().

CONST FIXED_DT = 1 / 60

'Screen layout (text cells)
CONST PLAY_TOP = 2
CONST PLAY_BOTTOM = 24

'Pools
CONST MAX_EN = 160
CONST MAX_BUL = 240
CONST MAX_PK = 12
CONST MAX_FX = 240
CONST MAX_STARS = 24
CONST MAX_DEFS = 80
CONST MAX_EVENTS = 300
CONST MAX_BACK = 6
CONST MAX_SONGS = 12
CONST MAX_CHAPTERS = 40
CONST MAX_SECTORS = 8
CONST PATH_LEN = 600

'Game states
CONST ST_TITLE = 1
CONST ST_OPTIONS = 2
CONST ST_CONTROLS = 3
CONST ST_SCORES = 4
CONST ST_SECTORSEL = 5
CONST ST_BRIEFING = 6
CONST ST_PLAY = 7
CONST ST_TALLY = 8
CONST ST_GAMEOVER = 9
CONST ST_NAMEENTRY = 10
CONST ST_ENDING = 11
CONST ST_ZEN = 12
CONST ST_ZENTALLY = 13
CONST ST_QUIT = 99

'Input actions
CONST A_UP = 1
CONST A_DOWN = 2
CONST A_LEFT = 3
CONST A_RIGHT = 4
CONST A_FIRE = 5
CONST A_SPECIAL = 6
CONST A_SELECT = 7
CONST A_START = 8
CONST A_COUNT = 8

'Collision map kinds (cell code = kind * 1000 + index)
CONST MAP_PICKUP = 1
CONST MAP_ENEMY = 2
CONST MAP_EBULLET = 3
CONST MAP_TERRAIN = 4

'Pickup kinds
CONST PK_LIFE = 1
CONST PK_ENERGY = 2
CONST PK_SHIELD = 3
CONST PK_FREEZE = 4
CONST PK_WEAPON = 5
CONST PK_BOMB = 6
CONST PK_MISSILE = 7
CONST PK_OVERDRIVE = 8
CONST PK_CELL = 9
CONST PK_STAR = 10
CONST PK_COUNT = 10

'Specials (inventory slots)
CONST SP_FREEZE = 1
CONST SP_BOMB = 2
CONST SP_MISSILE = 3
CONST SP_OVERDRIVE = 4
CONST SP_COUNT = 4

'Movement behaviors
CONST MV_PATTERN = 1
CONST MV_STRAIGHT = 2
CONST MV_SINE = 3
CONST MV_DIVE = 4
CONST MV_HOVER = 5
CONST MV_DRIFT = 6
CONST MV_ORBIT = 7
CONST MV_FOLLOW = 8
CONST MV_ATTACHED = 9
CONST MV_ANCHORED = 10
CONST MV_MIRROR = 11
CONST MV_ESCAPE = 12
CONST MV_BOSS = 13
CONST MV_EGG = 14
CONST MV_MINE = 15
CONST MV_LAYER = 16
CONST MV_DRILLER = 17
CONST MV_GATE = 18
CONST MV_LIGHTNING = 19
CONST MV_JELLY = 20
CONST MV_PHANTOM = 21

'Fire patterns
CONST FR_NONE = 0
CONST FR_BEAM = 1
CONST FR_AIMED = 2
CONST FR_SPREAD3 = 3
CONST FR_RING8 = 4
CONST FR_ZAP = 5
CONST FR_SPORE = 6
CONST FR_BURST = 7

'Bullet kinds
CONST BK_LASER = 1
CONST BK_DIAG = 2
CONST BK_MISSILE = 3
CONST BK_BEAM = 4
CONST BK_SHOT = 5
CONST BK_SPORE = 6
CONST BK_ZAP = 7

'On-death actions
CONST OD_NONE = 0
CONST OD_SPLIT = 1
CONST OD_SHRAPNEL = 2

'Boss AIs
CONST AI_NONE = 0
CONST AI_AMOEBA = 1
CONST AI_ROACH = 2
CONST AI_LEVIATHAN = 3
CONST AI_DREAD = 4
CONST AI_HIVE = 5
CONST AI_CARRIER = 6
CONST AI_AMOEBA_S = 7

'Level goals
CONST GOAL_KILLS = 1
CONST GOAL_SURVIVE = 2
CONST GOAL_DISTANCE = 3
CONST GOAL_BOSS = 4
CONST GOAL_COLLECT = 5

'Terrain styles
CONST TER_NONE = 0
CONST TER_ROCK = 1
CONST TER_FORTRESS = 2
CONST TER_ORGANIC = 3

'Difficulty
CONST DIFF_EASY = 1
CONST DIFF_NORMAL = 2
CONST DIFF_HARD = 3

'Level event commands
CONST EV_TIP = 1
CONST EV_WAVE = 2
CONST EV_SPAWN = 3
CONST EV_PICKUP = 4
CONST EV_BOSS = 5
CONST EV_POOL = 6
CONST EV_MESSAGE = 7
CONST EV_TERRAIN = 8
CONST EV_FOG = 9
CONST EV_STORM = 10
CONST EV_PICKUPS = 11
CONST EV_STEP = 12

'Dreadnought part offsets (must match the DREAD sprite in data/sprites.txt)
CONST DREAD_CORE_X = 17
CONST DREAD_CORE_Y = 5

'Player
CONST GRACE_TIME = 2
CONST DEMO_IDLE = 15 'seconds of title-screen idle before the attract-mode demo
CONST DEMO_LENGTH = 20 'seconds the demo plays before the title comes back

'Zen mode
CONST MAX_ZEN_STARS = 70
CONST MAX_ZEN_OBJS = 48
CONST MAX_ZEN_SCENES = 80
CONST MAX_ZEN_AREAS = 10
CONST OVER_MAX = 50 'most overcharge the ship can hold (half a bar)
CONST ZEN_CENTER = 25 'the ship's half-row while the view scrolls (screen center)
CONST ZEN_VMAX = 24 'top vertical speed, half-rows per second
CONST ZEN_V_INTENT = 3.5 'how quickly the smoothed up/down intent follows the keys (per second)
CONST ZEN_V_FOLLOW = 3 'how quickly the speed follows that intent (lower = floatier)
CONST ZEN_PORTAL_EVERY = 20 'the portal drifts past about this often (seconds at cruising speed)
CONST ZEN_HINT_AFTER = 90 'seconds of searching before the gauge shows the portal's height
CONST SHIP_COLOR = 14

'Effects
CONST FX_EXPLO = 1
CONST FX_TEXT = 2
CONST FX_PART = 3

'Songs
CONST SONG_TITLE = 1
CONST SONG_BOSS = 2
CONST SONG_SECTOR1 = 3
CONST SONG_SECTOR2 = 4
CONST SONG_SECTOR3 = 5
CONST SONG_SECTOR4 = 6
CONST SONG_SECTOR5 = 7
CONST SONG_FINAL = 8
CONST SONG_ENDING = 9
CONST SONG_BONUS = 10
CONST SONG_ZEN = 11

TYPE SpriteType
    Nm AS STRING * 16
    W AS INTEGER
    H AS INTEGER
    Frames AS INTEGER
    CharOfs AS LONG
END TYPE

TYPE EnemyDefType
    Nm AS STRING * 16
    Title AS STRING * 24
    Sprite AS INTEGER
    Sprite2 AS INTEGER
    HP AS SINGLE
    Pts AS LONG
    Clr AS INTEGER
    ColorPat AS STRING * 64
    ColorSteps AS INTEGER
    Move AS INTEGER
    Speed AS SINGLE
    SpeedMax AS SINGLE
    Spread AS SINGLE
    VSpeed AS SINGLE
    Amp AS SINGLE
    Period AS SINGLE
    Pattern AS STRING * 64
    PatSteps AS INTEGER
    PatFlip AS _BYTE
    Reverse AS _BYTE
    Chase AS _BYTE
    Fire AS INTEGER
    FireRate AS SINGLE
    BulletSpeed AS SINGLE
    Wounded AS INTEGER
    OnDeath AS INTEGER
    DeathDef AS INTEGER
    DeathCount AS INTEGER
    DropChance AS INTEGER
    DropKind AS INTEGER
    Boss AS INTEGER
    AI AS INTEGER
    Invuln AS _BYTE
    Ghost AS _BYTE
    Knock AS SINGLE
    Touch AS _BYTE
    FrameRate AS SINGLE
    Pool AS _BYTE
END TYPE

TYPE EnemyType
    Active AS _BYTE
    DefID AS INTEGER
    Sprite AS INTEGER
    X AS SINGLE
    Y AS SINGLE
    VX AS SINGLE
    VY AS SINGLE
    HP AS SINGLE
    MaxHP AS SINGLE
    Pts AS LONG
    Frame AS INTEGER
    FrameT AS DOUBLE
    Clr AS INTEGER
    ColorPat AS STRING * 64
    ColorSteps AS INTEGER
    ColorStep AS INTEGER
    Pattern AS STRING * 64
    PatSteps AS INTEGER
    PatStep AS INTEGER
    Move AS INTEGER
    Speed AS SINGLE
    Reverse AS _BYTE
    Chase AS _BYTE
    CanShoot AS _BYTE
    NextFire AS DOUBLE
    StepT AS DOUBLE
    Born AS DOUBLE
    Phase AS SINGLE
    BaseY AS SINGLE
    Parent AS INTEGER
    OffX AS SINGLE
    OffY AS SINGLE
    Param AS SINGLE
    State AS INTEGER
    StateT AS DOUBLE
    FlashT AS DOUBLE
    Visible AS _BYTE
    Pool AS _BYTE
    Invuln AS _BYTE
    Cloaked AS _BYTE
    W AS INTEGER
    H AS INTEGER
    Boss AS INTEGER
END TYPE

TYPE BulletType
    Active AS _BYTE
    Owner AS _BYTE
    Kind AS INTEGER
    X AS SINGLE
    Y AS SINGLE
    DX AS SINGLE
    DY AS SINGLE
    Size AS INTEGER
    Ch AS STRING * 1
    Clr AS INTEGER
    Born AS DOUBLE
    Life AS SINGLE
    Damage AS SINGLE
    Pierce AS _BYTE
    LastHit AS INTEGER
    Target AS INTEGER
    Src AS INTEGER
END TYPE

TYPE PickupType
    Active AS _BYTE
    Kind AS INTEGER
    X AS SINGLE
    Y AS SINGLE
    Speed AS SINGLE
    Sprite AS INTEGER
    Clr AS INTEGER
    ColorStep AS INTEGER
    Spent AS _BYTE
    Scripted AS _BYTE
END TYPE

TYPE FXType
    Active AS _BYTE
    Kind AS INTEGER
    X AS SINGLE
    Y AS SINGLE
    DX AS SINGLE
    DY AS SINGLE
    Born AS DOUBLE
    Life AS SINGLE
    Clr AS INTEGER
    Ch AS STRING * 1
    Txt AS STRING * 12
    Big AS _BYTE
END TYPE

TYPE StarType
    X AS SINGLE
    Y AS SINGLE
    Speed AS INTEGER
    Clr AS INTEGER
    Ch AS STRING * 1
END TYPE

TYPE ZenStarType
    X AS SINGLE
    Y AS SINGLE
    Layer AS INTEGER '1 far, 2 middle, 3 near
    Clr AS INTEGER
    Ch AS STRING * 1
END TYPE

TYPE ZenObjType
    Active AS _BYTE
    Sprite AS INTEGER
    X AS SINGLE
    Y AS SINGLE 'screen row when the view is at CamY = 0 (see zen.bm)
    Depth AS SINGLE '0 = infinitely far, 1 = as close as the near stars
    Clr AS INTEGER
    Seen AS _BYTE 'has been on screen (counted for the tally)
END TYPE

TYPE ZenSceneType
    Gap AS SINGLE 'seconds (at cruising speed) after the previous scene
    Sprite AS INTEGER
    Depth AS SINGLE
    Clr AS INTEGER
    Row AS SINGLE
END TYPE

TYPE ZenAreaType
    Nm AS STRING * 32
    CamFrom AS SINGLE 'view positions (rows) this area covers; negative is up
    CamTo AS SINGLE
    FirstScene AS INTEGER
    LastScene AS INTEGER
    Scene AS INTEGER
    NextAt AS SINGLE
END TYPE

TYPE ZenStateType
    CamY AS SINGLE 'vertical view offset in rows
    Speed AS SINGLE 'cruising speed multiplier (1 = normal)
    Dist AS SINGLE
    MapTop AS SINGLE 'how far the view can scroll up and down
    MapBot AS SINGLE
    Area AS INTEGER
    AreaT AS DOUBLE 'when the current area's name started showing
    VMoveT AS DOUBLE 'last time the view scrolled
    'The portal: it sits at one height on the map and drifts past every so often
    PortalCam AS SINGLE 'view position where it shows at PortalRow
    PortalRow AS SINGLE
    PortalX AS SINGLE
    PortalOn AS _BYTE 'currently drifting across
    PortalNext AS SINGLE 'distance at which it comes by again
    Found AS _BYTE 'touched: the ship is blasting off
    FoundT AS SINGLE 'seconds adrift when it was found
    Visited AS LONG 'one bit per area
    Seen AS INTEGER 'scenery that came into view
    LastReal AS DOUBLE
    DCam AS SINGLE 'view and ship movement this frame, in rows
    DShip AS SINGLE
    VY AS SINGLE 'vertical speed in half-rows per second (builds up while up/down is held)
    VIn AS SINGLE 'smoothed up/down intent, -1 to 1
END TYPE

TYPE BackType
    Active AS _BYTE
    Sprite AS INTEGER
    X AS SINGLE
    Y AS SINGLE
    Speed AS SINGLE
    Clr AS INTEGER
END TYPE

TYPE PlayerType
    X AS SINGLE
    Y AS SINGLE
    Size AS INTEGER
    Alive AS _BYTE
    Dying AS _BYTE
    DeathT AS DOUBLE
    DeathMsg AS STRING * 20
    Lives AS INTEGER
    Energy AS SINGLE
    Over AS SINGLE 'overcharge: gun energy above full, from energy cells; spent before Energy
    Score AS LONG
    NextLife AS LONG
    Weapon AS INTEGER
    Shield AS _BYTE
    ShieldT AS DOUBLE
    LastDamage AS DOUBLE
    LastGrow AS DOUBLE
    LastShot AS DOUBLE
    CurSpecial AS INTEGER
    Freeze AS _BYTE
    FreezeT AS DOUBLE
    OverdriveEnd AS DOUBLE
    SmokeT AS DOUBLE
    MovingRight AS _BYTE
    MuzzleT AS DOUBLE
    Combo AS INTEGER
    ComboT AS DOUBLE
    Recharge AS _BYTE
    SlideIn AS _BYTE
    RechargeT AS DOUBLE
    LastEnergyUp AS DOUBLE
    LastSpecialT AS DOUBLE
    PrevX AS INTEGER
    PrevY AS INTEGER
    MoveDY AS INTEGER
    FiredThisTick AS _BYTE
    Continues AS INTEGER
    ExitPhase AS INTEGER
    ExitT AS DOUBLE
    ExitV AS SINGLE
    Bank AS INTEGER 'zen mode: 0 level, 1-2 wings drawn closer together while sliding up or down
    ExitX0 AS SINGLE
    ExitY0 AS SINGLE
    ExitDur AS SINGLE
    ExitVX AS SINGLE 'velocity while gathering leftover pickups after the goal
    ExitVY AS SINGLE
END TYPE

TYPE GameType
    State AS INTEGER
    PrevState AS INTEGER
    T AS DOUBLE
    ET AS DOUBLE
    Paused AS _BYTE
    Difficulty AS INTEGER
    ChapterIdx AS INTEGER
    StartChapter AS INTEGER
    StarInterval AS SINGLE
    StarBase AS SINGLE
    FlashUntil AS DOUBLE
    FlashClr AS _UNSIGNED LONG
    MsgText AS STRING * 40
    MsgUntil AS DOUBLE
    MsgClr AS INTEGER
    MenuSel AS INTEGER
    StateT AS DOUBLE
    WeKilledFirst AS _BYTE
    LastEnemyShot AS DOUBLE
    Mute AS _BYTE
    MusicVol AS INTEGER
    SfxVol AS INTEGER
    Fullscreen AS _BYTE
    Unlocked AS INTEGER
    God AS _BYTE
    Acc AS DOUBLE
    LastReal AS DOUBLE
    TipText AS STRING * 120
    TipUntil AS DOUBLE
    BannerText AS STRING * 80
    BannerUntil AS DOUBLE
    WarningUntil AS DOUBLE
    BossIdx AS INTEGER
    BossMax AS SINGLE
    BossTitle AS STRING * 24
    BossDeadT AS DOUBLE
    BossX AS SINGLE
    BossY AS SINGLE
    BossW AS SINGLE
    BossH AS SINGLE
    LastStepT AS DOUBLE
    ColorTick AS LONG
    LastLifeT AS DOUBLE
    LastEnergyT AS DOUBLE
    LastShieldT AS DOUBLE
    LastFreezeT AS DOUBLE
    LastWeaponT AS DOUBLE
    LastBombT AS DOUBLE
    LastMissileT AS DOUBLE
    LastOverdriveT AS DOUBLE
    NextPickupRoll AS DOUBLE
    Ending AS _BYTE
    NewHigh AS INTEGER
    EntryName AS STRING * 3
    EntryPos AS INTEGER
    TopMsg AS STRING * 32
    TopMsgUntil AS DOUBLE
    TopMsgT AS DOUBLE 'when the top-bar message appeared (it slides in from there)
    Demo AS _BYTE 'attract mode: the autopilot plays while the title screen is idle
    DemoEnd AS DOUBLE
    DemoAbort AS _BYTE
    IdleT AS DOUBLE 'last time any key or button was touched
    Parallax AS _BYTE 'stars slide the other way when the ship climbs or dives (-parallax)
END TYPE

TYPE LevelType
    File AS STRING * 64
    Nm AS STRING * 60
    Sector AS INTEGER
    Song AS INTEGER
    GoalType AS INTEGER
    GoalN AS SINGLE
    Progress AS SINGLE
    StepInterval AS SINGLE
    PoolMax AS INTEGER
    PoolKinds AS INTEGER
    T AS DOUBLE
    Started AS _BYTE
    Terrain AS INTEGER
    TerSpeed AS SINGLE
    TerMinGap AS INTEGER
    TerMaxH AS INTEGER
    TerOfs AS SINGLE
    Fog AS _BYTE
    Storm AS _BYTE
    StormRate AS SINGLE
    NextStorm AS DOUBLE
    Backdrop AS INTEGER
    GoalDone AS _BYTE
    Countdown AS DOUBLE
    BossQueue AS STRING * 120
    BossPending AS INTEGER
    BossSpawnT AS DOUBLE
    BossSeen AS _BYTE
    Kills AS LONG
    Shots AS LONG
    Hits AS LONG
    Damage AS INTEGER
    Collected AS INTEGER
    Pickups AS _BYTE
    Bonus AS _BYTE
    EventCount AS INTEGER
    LoopFrom AS SINGLE
    LoopTo AS SINGLE
    ChapterNo AS INTEGER
    ShowNameT AS DOUBLE
    StartScore AS LONG
    TallyBonus AS LONG
END TYPE

TYPE EventType
    T AS SINGLE
    T0 AS SINGLE
    Period AS SINGLE
    UntilT AS SINGLE
    Cmd AS INTEGER
    Arg AS STRING * 120
    Done AS _BYTE
END TYPE

TYPE ChapterType
    File AS STRING * 64
    Sector AS INTEGER
    Nm AS STRING * 60
    Bonus AS _BYTE
    Num AS INTEGER
END TYPE

TYPE SectorType
    Nm AS STRING * 40
    Brief AS STRING * 600
    FirstChapter AS INTEGER
END TYPE

TYPE ScoreType
    Nm AS STRING * 3
    Score AS LONG
    Chapter AS INTEGER
END TYPE

TYPE TestType
    Active AS _BYTE
    Fast AS _BYTE
    Limit AS DOUBLE
    ShotEvery AS DOUBLE
    NextShot AS DOUBLE
    ShotDir AS STRING * 200
    ShotNo AS LONG
    Errors AS LONG
    Frames AS LONG
    Bot AS _BYTE
    BotT AS DOUBLE
    BotTargetY AS SINGLE
    Deaths AS INTEGER
    LogFile AS STRING * 200
    MaxChapter AS INTEGER
    StopAtChapter AS INTEGER
    Windowed AS _BYTE '-window: skip fullscreen this run (saved setting untouched)
END TYPE

'---------------------------------------------------------------------------
DIM SHARED Game AS GameType
DIM SHARED Ply AS PlayerType
DIM SHARED Lvl AS LevelType
DIM SHARED Test AS TestType

DIM SHARED Sprites(1 TO 120) AS SpriteType
DIM SHARED SpriteCount AS INTEGER
REDIM SHARED SprChar(1 TO 1) AS _UNSIGNED _BYTE
REDIM SHARED SprCol(1 TO 1) AS _BYTE
DIM SHARED SprUsed AS LONG

DIM SHARED Defs(1 TO MAX_DEFS) AS EnemyDefType
DIM SHARED DefCount AS INTEGER

DIM SHARED En(1 TO MAX_EN) AS EnemyType
DIM SHARED Bul(1 TO MAX_BUL) AS BulletType
DIM SHARED Pk(1 TO MAX_PK) AS PickupType
DIM SHARED FX(1 TO MAX_FX) AS FXType
DIM SHARED Stars(1 TO MAX_STARS) AS StarType
DIM SHARED Back(1 TO MAX_BACK) AS BackType
DIM SHARED ZenStars(1 TO MAX_ZEN_STARS) AS ZenStarType
DIM SHARED ZenObjs(1 TO MAX_ZEN_OBJS) AS ZenObjType
DIM SHARED ZenScenes(1 TO MAX_ZEN_SCENES) AS ZenSceneType
DIM SHARED ZenSceneCount AS INTEGER
DIM SHARED ZenAreas(1 TO MAX_ZEN_AREAS) AS ZenAreaType
DIM SHARED ZenAreaCount AS INTEGER
DIM SHARED Zen AS ZenStateType
DIM SHARED Ev(1 TO MAX_EVENTS) AS EventType

DIM SHARED ScreenMap(1 TO 80, 1 TO 25) AS INTEGER
DIM SHARED TerTop(1 TO 81) AS INTEGER
DIM SHARED TerBot(1 TO 81) AS INTEGER

DIM SHARED PoolDef(1 TO 8) AS INTEGER
DIM SHARED PoolWeight(1 TO 8) AS INTEGER

DIM SHARED SpecialCount(1 TO SP_COUNT) AS INTEGER
DIM SHARED SpecialMax(1 TO SP_COUNT) AS INTEGER
DIM SHARED SpecialName(1 TO SP_COUNT) AS STRING

DIM SHARED PathX(0 TO PATH_LEN - 1) AS SINGLE
DIM SHARED PathY(0 TO PATH_LEN - 1) AS SINGLE
DIM SHARED PathHead AS INTEGER

DIM SHARED Chapters(1 TO MAX_CHAPTERS) AS ChapterType
DIM SHARED ChapterCount AS INTEGER
DIM SHARED Sectors(1 TO MAX_SECTORS) AS SectorType
DIM SHARED SectorCount AS INTEGER

DIM SHARED HighScores(1 TO 10) AS ScoreType

'Input
DIM SHARED InHeld(1 TO A_COUNT) AS _BYTE
DIM SHARED InPrev(1 TO A_COUNT) AS _BYTE
DIM SHARED InPressed(1 TO A_COUNT) AS _BYTE
DIM SHARED KeyBind1(1 TO A_COUNT) AS LONG
DIM SHARED KeyBind2(1 TO A_COUNT) AS LONG
DIM SHARED PadBind(1 TO A_COUNT) AS INTEGER
DIM SHARED ActionName(1 TO A_COUNT) AS STRING
DIM SHARED PadDevice AS INTEGER
DIM SHARED PadName AS STRING
DIM SHARED KeyHitBuffer AS LONG
DIM SHARED EscPressed AS _BYTE

'Audio
DIM SHARED Songs(1 TO MAX_SONGS) AS LONG
DIM SHARED SongName(1 TO MAX_SONGS) AS STRING
DIM SHARED CurrentSong AS INTEGER
DIM SHARED SndCatchEnergy AS LONG, SndFullRecharge AS LONG, SndShieldAppear AS LONG
DIM SHARED SndShieldOn AS LONG, SndShieldOff AS LONG, SndLaser1 AS LONG, SndLaser2 AS LONG
DIM SHARED SndShipDamage AS LONG, SndShipGrow AS LONG, SndEnergyUp AS LONG
DIM SHARED SndExplosion AS LONG, SndOutOfEnergy AS LONG, SndExtraLife AS LONG
DIM SHARED SndIntercom AS LONG, SndBlizzard AS LONG
DIM SHARED SndSiren AS LONG, SndPickup AS LONG, SndMenuMove AS LONG, SndMenuSelect AS LONG
DIM SHARED SndBomb AS LONG, SndMissile AS LONG, SndWeaponUp AS LONG, SndZap AS LONG
DIM SHARED SndBossDeath AS LONG, SndBeep AS LONG

'Images
DIM SHARED ShieldImages(1 TO 10) AS LONG
DIM SHARED SmokeImages(1 TO 3) AS LONG
DIM SHARED LogoImages(1 TO 16) AS LONG
DIM SHARED LifeBarImage AS LONG
DIM SHARED BossBarImage AS LONG
DIM SHARED ShieldIdx AS INTEGER
DIM SHARED ShieldIdxT AS DOUBLE

DIM SHARED BoomChars AS STRING
DIM SHARED CtlWaiting AS INTEGER
DIM SHARED TestMenuScript AS STRING
DIM SHARED ShowDebug AS _BYTE
DIM SHARED ShipCX(1 TO 12) AS INTEGER, ShipCY(1 TO 12) AS INTEGER, ShipCC(1 TO 12) AS INTEGER, ShipN AS INTEGER
DIM SHARED BasePath AS STRING
DIM SHARED Sep AS STRING
