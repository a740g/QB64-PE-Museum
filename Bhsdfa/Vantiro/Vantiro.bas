REM Made by Bhsdfa!
REM File creation date: 27-Aug-24 (1:02 PM BRT)
REM Apps used: TILED e QB64pe
REM TILED: https://www.mapeditor.org/    -=-    QB64pe: https://qb64phoenix.com/
REM Vantiro.bas:
'$DYNAMIC
$RESIZE:ON
Icon = _LOADIMAGE("assets/pc/vantirologo.png")
_ICON Icon, Icon
_TITLE "Vantiro"
MenuTransitionImage = _NEWIMAGE(32, 32, 32)
CONST PI = 3.14159265359
CONST PIDIV180 = PI / 180
RANDOMIZE TIMER
DIM SHARED MainScreen
DIM SHARED SecondScreen
MainScreen = _NEWIMAGE(1230, 662, 32)
SecondScreen = _NEWIMAGE(1230, 662, 32)
SCREEN MainScreen
_DEST MainScreen
TYPE Mouse
    x AS LONG
    y AS LONG
    x1 AS LONG
    y1 AS LONG
    x2 AS LONG
    y2 AS LONG
    xbz AS DOUBLE
    ybz AS DOUBLE
    xaz AS DOUBLE
    yaz AS DOUBLE
    click AS INTEGER
    click2 AS INTEGER
    scroll AS INTEGER
END TYPE
DIM SHARED Mouse AS Mouse
TYPE Map
    MaxWidth AS LONG
    MaxHeight AS LONG
    Layers AS LONG
    TileSize AS LONG
    Title AS STRING
    TextureSize AS LONG
    Triggers AS LONG
END TYPE
DIM SHARED Map AS Map
TYPE Entity
    x AS DOUBLE
    y AS DOUBLE
    x1 AS LONG
    y1 AS LONG
    x2 AS LONG
    y2 AS LONG
    size AS DOUBLE
    sizeFirst AS DOUBLE
    xm AS DOUBLE
    ym AS DOUBLE
    rotation AS DOUBLE
    health AS DOUBLE
    healthFirst AS DOUBLE
    damage AS DOUBLE
    attacking AS INTEGER
    attackcooldown AS INTEGER
    tick AS INTEGER
    active AS INTEGER
    DistanceFromPlayer AS INTEGER
    weight AS DOUBLE
    maxspeed AS INTEGER
    speeding AS DOUBLE
    knockback AS DOUBLE
    onfire AS INTEGER
    special AS STRING
    SpecialDelay AS DOUBLE
    DamageCooldown AS DOUBLE
    DamageTaken AS DOUBLE
END TYPE
TYPE DefEntity
    maxspeed AS DOUBLE
    maxhealth AS INTEGER
    minhealth AS INTEGER
    maxdelay AS INTEGER
    mindelay AS INTEGER
    tickrate AS INTEGER
    mindamage AS INTEGER
    maxdamage AS INTEGER
    size AS INTEGER
END TYPE
DIM SHARED ZombieMax AS LONG
DIM SHARED VileMax AS INTEGER
DIM SHARED SnarkMax AS INTEGER
DIM SHARED SummonerMax AS INTEGER
PlayerSkin = 1
DIM SHARED PlayerSprite(4)
DIM SHARED PlayerHand(4)
PlayerSprite(1) = _LOADIMAGE("assets/pc/player/player1.png")
PlayerHand(1) = _LOADIMAGE("assets/pc/player/hand1.png")

PlayerSprite(2) = _LOADIMAGE("assets/pc/player/player2.png")
PlayerHand(2) = _LOADIMAGE("assets/pc/player/hand1.png")

PlayerSprite(3) = _LOADIMAGE("assets/pc/player/player3.png")
PlayerHand(3) = _LOADIMAGE("assets/pc/player/hand3.png")

PlayerSprite(4) = _LOADIMAGE("assets/pc/player/player4.png")
PlayerHand(4) = _LOADIMAGE("assets/pc/player/hand4.png")

BloodDrop = _LOADIMAGE("assets/pc/Blooddrop.png")

DIM SHARED PlayerDamage
DIM SHARED PlayerDeath
PlayerDamage = _SNDOPEN("assets/pc/player/sounds/au.wav")
PlayerDeath = _SNDOPEN("assets/pc/player/sounds/ua.wav")
FlameThrowerSound = _SNDOPEN("assets/pc/sounds/interior_fire01_stereo.wav")

DIM SHARED ZombieWalk(4)
ZombieWalk(1) = _SNDOPEN("assets/pc/mobs/sounds/headless_1.wav")
ZombieWalk(2) = _SNDOPEN("assets/pc/mobs/sounds/headless_2.wav")
ZombieWalk(3) = _SNDOPEN("assets/pc/mobs/sounds/headless_3.wav")
ZombieWalk(4) = _SNDOPEN("assets/pc/mobs/sounds/headless_4.wav")

DIM SHARED ZombieShot(16)
ZombieShot(1) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_01.wav")
ZombieShot(2) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_02.wav")
ZombieShot(3) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_03.wav")
ZombieShot(4) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_04.wav")
ZombieShot(5) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_05.wav")
ZombieShot(6) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_06.wav")
ZombieShot(7) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_07.wav")
ZombieShot(8) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_08.wav")
ZombieShot(9) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_09.wav")
ZombieShot(10) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_10.wav")
ZombieShot(11) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_11.wav")
ZombieShot(12) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_12.wav")
ZombieShot(13) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_13.wav")
ZombieShot(14) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_14.wav")
ZombieShot(15) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_15.wav")
ZombieShot(16) = _SNDOPEN("assets/pc/mobs/sounds/shot/been_shot_16.wav")




ZombieMax = 190
DIM SHARED Zombie(ZombieMax) AS Entity
DIM SHARED DefZombie AS DefEntity
DefZombie.maxspeed = 820
DefZombie.size = 26
DefZombie.tickrate = 15
DefZombie.maxdamage = 10
DefZombie.mindamage = 4
DefZombie.maxhealth = 100
DefZombie.minhealth = 70


TYPE Player
    x AS DOUBLE
    y AS DOUBLE
    xb AS DOUBLE
    yb AS DOUBLE
    x1 AS LONG
    x2 AS LONG
    y1 AS LONG
    y2 AS LONG
    size AS INTEGER
    xm AS DOUBLE
    ym AS DOUBLE
    Rotation AS DOUBLE
    TouchX AS INTEGER
    TouchY AS INTEGER
    Health AS DOUBLE
    DamageToTake AS INTEGER
    DamageCooldown AS INTEGER
    Armor AS DOUBLE
    shooting AS DOUBLE
    weapon1id AS INTEGER
    weapon2id AS INTEGER
END TYPE
PlayerLimit = 1
DIM SHARED Player(PlayerLimit) AS Player
TYPE PlayerMembers
    x AS DOUBLE
    y AS DOUBLE
    xo AS DOUBLE
    yo AS DOUBLE
    xbe AS DOUBLE
    ybe AS DOUBLE
    angle AS SINGLE
    xvector AS DOUBLE
    yvector AS DOUBLE
    mode AS DOUBLE
    visible AS DOUBLE
    speed AS DOUBLE
    angleanim AS DOUBLE
    distanim AS DOUBLE
END TYPE
DIM SHARED PlayerMember(2) AS PlayerMembers
TYPE Raycast
    x AS DOUBLE
    y AS DOUBLE
    angle AS DOUBLE
    damage AS DOUBLE
    knockback AS DOUBLE
    owner AS INTEGER
END TYPE
DIM SHARED Ray AS Raycast
DIM SHARED RayM(3) AS Raycast
TYPE Tiles
    ID AS LONG
    solid AS INTEGER
    animationframe AS INTEGER
    rend_spritex AS LONG
    rend_spritey AS LONG
    PlayerStand AS INTEGER
    associated AS INTEGER
    x1y1 AS INTEGER
    x2y1 AS INTEGER
    x1y2 AS INTEGER
    x2y2 AS INTEGER
    fragile AS INTEGER
    transparent AS INTEGER
END TYPE
TYPE Weapon
    x AS DOUBLE
    y AS DOUBLE
    xm AS DOUBLE
    ym AS DOUBLE
    visible AS INTEGER
    cangrab AS INTEGER
    rotation AS DOUBLE
    wtype AS INTEGER
    shooting AS INTEGER
END TYPE
DIM SHARED Gun(2) AS Weapon
DIM SHARED GunDisplay(2) AS Weapon
TYPE Menu
    x1d AS DOUBLE
    x2d AS DOUBLE
    y1d AS DOUBLE
    y2d AS DOUBLE
    x1 AS LONG
    x2 AS LONG
    y1 AS LONG
    y2 AS LONG
    Colors AS LONG
    red AS INTEGER
    green AS INTEGER
    blue AS INTEGER
    text AS STRING
    textsize AS INTEGER
    hex AS STRING
    style AS INTEGER
    clicktogo AS STRING
    extra AS INTEGER
    extra2 AS INTEGER
    extra3 AS INTEGER
    visual AS INTEGER
    visual2 AS STRING
    d_hover AS INTEGER
    d_clicked AS INTEGER
    OffsetY AS DOUBLE
    OffsetX AS DOUBLE
END TYPE
TYPE Hud
    x1 AS LONG
    x2 AS LONG
    y1 AS LONG
    y2 AS LONG
    x AS DOUBLE
    y AS DOUBLE
    xm AS DOUBLE
    ym AS DOUBLE
    xbe AS DOUBLE
    ybe AS DOUBLE
    rotation AS DOUBLE
    rotationbe AS DOUBLE
    rotationoffset AS DOUBLE
    stringered AS LONG
    size AS LONG
    textsize AS INTEGER
END TYPE
TYPE Trigger
    x1 AS DOUBLE
    y1 AS DOUBLE
    x2 AS DOUBLE
    y2 AS DOUBLE
    sizex AS DOUBLE
    sizey AS DOUBLE
    class AS STRING
    val1 AS DOUBLE
    val2 AS DOUBLE
    val3 AS DOUBLE
    val4 AS DOUBLE
    text AS STRING
    textspeed AS DOUBLE
    triggername AS STRING
    needclick AS INTEGER
END TYPE
VantiroTitulo = _LOADIMAGE("assets/pc/Vantiro.png")
Background1 = _LOADIMAGE("assets/pc/Background.png")
DIM SHARED Hud(9) AS Hud
DIM SHARED Minimap AS Hud
TXTGlint = _LOADIMAGE("assets/begs world/textures/glint.png")
DIM SHARED MenuMax
MenuMax = 64
DIM SHARED Menu(MenuMax) AS Menu
DIM SHARED MenuAnim AS Menu
FOR i = 1 TO MenuMax
    Menu(i).x1 = 0: Menu(i).x2 = 0: Menu(i).y1 = 0: Menu(i).y2 = 0: Menu(i).Colors = 0: Menu(i).red = 0: Menu(i).green = 0: Menu(i).blue = 0
    Menu(i).text = " "
    Menu(i).textsize = -1
    Menu(i).hex = ""
    Menu(i).style = 0
    Menu(i).clicktogo = ""
    Menu(i).extra = 0
    Menu(i).d_hover = 0
    Menu(i).d_clicked = 0
NEXT
DIM SHARED Colors AS LONG
Begsfont$ = "assets\begs world\mouse.ttf"
DIM SHARED BegsFontSizes(1024)
DIM SHARED MenusImages(128)
FOR i = 1 TO 1024
    BegsFontSizes(i) = _LOADFONT(Begsfont$, i, "")
NEXT
CanLeave = 0
ToLoad$ = "menu"
ToLoad2$ = "menu"
GOSUB load
_DEST MainScreen
DO
    _LIMIT 75
    CLS
    GOSUB MenuSystem
    _DISPLAY
LOOP WHILE quit = 0
'Input "Select a map", Map$
Map$ = "Forest"
CLS
MinimapTxtSize = 8
MapLoaded = LoadMapSettings(Map$)
DIM SHARED Trigger(Map.Triggers) AS Trigger
MinimapIMG = _NEWIMAGE(Map.MaxWidth * 8, Map.MaxHeight * 8, 32)

DIM SHARED Tile(Map.MaxWidth + 20, Map.MaxHeight + 20, Map.Layers) AS Tiles
MapLoaded = LoadMap(Map$)
DIM SHARED LastPart AS INTEGER
DIM SHARED Tileset

Tileset = _LOADIMAGE("assets/pc/tileset.png")


E_KeyIcon = _LOADIMAGE("assets/pc/items/ekeyicon.png")

Guns_Pistol = _LOADIMAGE("assets/pc/items/pistol.png")
Guns_Shotgun = _LOADIMAGE("assets/pc/items/shotgun.png")
Guns_SMG = _LOADIMAGE("assets/pc/items/smg.png")
Guns_Flame = _LOADIMAGE("assets/pc/items/flamethrower.png")
Guns_Grenade = _LOADIMAGE("assets/pc/items/grenade.png")
HudSelected = _LOADIMAGE("assets/pc/Selected.png")
HudNotSelected = _LOADIMAGE("assets/pc/NotSelected.png")
HudNoAmmo = _LOADIMAGE("assets/pc/NoAmmo.png")

Zombie = _LOADIMAGE("assets/pc/mobs/zombie.png")
ZombieRunner = _LOADIMAGE("assets/pc/mobs/fastzombie.png")
ZombieSlower = _LOADIMAGE("assets/pc/mobs/slowzombie.png")
ZombieBomber = _LOADIMAGE("assets/pc/mobs/bomberzombie.png")
ZombieBiohazard = _LOADIMAGE("assets/pc/mobs/zombie.png") ' GIVE ME IMAGE
ZombieBrute = _LOADIMAGE("assets/pc/mobs/zombie.png") 'GIVE ME IMAGE
ZombieFire = _LOADIMAGE("assets/pc/mobs/firezombie.png")

ShellShotgunAmmo = _LOADIMAGE("assets/pc/items/shotgunammo.png")
PistolShellAmmo = _LOADIMAGE("assets/pc/items/pistolammo.png")
GasCanAmmo = _LOADIMAGE("assets/pc/items/gascan.png")


DIM SHARED WallShot
WallShot = _LOADIMAGE("assets/pc/items/wallshot.png")
GlassShard = _LOADIMAGE("assets/pc/items/glassshard.png")
DIM SHARED Bloodsplat
BloodsplatGreen = _LOADIMAGE("assets/pc/items/bloodsplatgreen.png")
BloodsplatRed = _LOADIMAGE("assets/pc/items/bloodsplatred.png")
Gib_Skull = _LOADIMAGE("assets/pc/items/skull.png")
Gib_Bone = _LOADIMAGE("assets/pc/items/bone.png")
DIM SHARED Bloodonground
Bloodonground = _LOADIMAGE("assets/pc/items/bloodonground.png")
Guns_Sound_PistolShot = _SNDOPEN("assets/pc/sounds/pistolshot.wav")
Guns_Sound_ShotgunShot = _SNDOPEN("assets/pc/sounds/shotgunshot.wav")

DIM SHARED FireParticles(3)
FireParticle = _LOADIMAGE("assets/pc/items/fire1.png")
FireParticles(1) = _LOADIMAGE("assets/pc/items/fire1.png")
FireParticles(2) = _LOADIMAGE("assets/pc/items/fire2.png")
FireParticles(3) = _LOADIMAGE("assets/pc/items/fire3.png")

DIM SMGSounds(3)
SMGSounds(1) = _SNDOPEN("assets/pc/sounds/hks1.wav")
SMGSounds(2) = _SNDOPEN("assets/pc/sounds/hks2.wav")
SMGSounds(3) = _SNDOPEN("assets/pc/sounds/hks3.wav")

DIM ShellSounds(3)
ShellSounds(1) = _SNDOPEN("assets/pc/sounds/sshell1.wav")
ShellSounds(2) = _SNDOPEN("assets/pc/sounds/sshell2.wav")
ShellSounds(3) = _SNDOPEN("assets/pc/sounds/sshell3.wav")
DIM PistolShellSounds(3)
PistolShellSounds(1) = _SNDOPEN("assets/pc/sounds/pl_shell1.wav")
PistolShellSounds(2) = _SNDOPEN("assets/pc/sounds/pl_shell2.wav")
PistolShellSounds(3) = _SNDOPEN("assets/pc/sounds/pl_shell3.wav")

DIM BloodSounds(6)
BloodSounds(1) = _SNDOPEN("assets/pc/sounds/flesh1.wav")
BloodSounds(2) = _SNDOPEN("assets/pc/sounds/flesh2.wav")
BloodSounds(3) = _SNDOPEN("assets/pc/sounds/flesh3.wav")
BloodSounds(4) = _SNDOPEN("assets/pc/sounds/flesh5.wav")
BloodSounds(5) = _SNDOPEN("assets/pc/sounds/flesh6.wav")
BloodSounds(6) = _SNDOPEN("assets/pc/sounds/flesh7.wav")
DIM SHARED GlassShadder(3)
GlassShadder(1) = _SNDOPEN("assets/pc/sounds/bustglass1.wav")
GlassShadder(2) = _SNDOPEN("assets/pc/sounds/bustglass2.wav")
GlassShadder(3) = _SNDOPEN("assets/pc/sounds/bustglass3.wav")
DIM GlassSound(4)
GlassSound(1) = _SNDOPEN("assets/pc/sounds/glass1.wav")
GlassSound(2) = _SNDOPEN("assets/pc/sounds/glass2.wav")
GlassSound(3) = _SNDOPEN("assets/pc/sounds/glass3.wav")
GlassSound(4) = _SNDOPEN("assets/pc/sounds/glass4.wav")

HudImageHealth = _NEWIMAGE(128, 128, 32)
Hud_Health_Icon = _LOADIMAGE("assets/pc/BloodIcon.png")
Hud_Health_Fluid = _LOADIMAGE("assets/pc/BloodHealth.png")

SND_Explosion = _SNDOPEN("assets/pc/sounds/explode.mp3")
Particle_Shotgun_Shell = _LOADIMAGE("assets/pc/items/shotgunshell.png")
Particle_Pistol_Shell = _LOADIMAGE("assets/pc/items/pistolshell.png")
Particle_Smoke = _LOADIMAGE("assets/pc/items/smoke.png")
Particle_Explosion = _LOADIMAGE("assets/pc/items/explosion.png")
DIM SHARED CameraX AS DOUBLE
DIM SHARED CameraY AS DOUBLE
DIM SHARED CameraXM AS DOUBLE
DIM SHARED CameraYM AS DOUBLE
DIM SHARED Zoom AS DOUBLE
TYPE Particle
    x AS DOUBLE
    y AS DOUBLE
    z AS DOUBLE
    txt AS INTEGER
    xm AS DOUBLE
    ym AS DOUBLE
    zm AS DOUBLE
    froozen AS INTEGER
    rotation AS DOUBLE
    rotationspeed AS DOUBLE
    visible AS INTEGER
    partid AS STRING
    playwhatsound AS STRING
    BloodColor AS STRING
    special AS INTEGER
END TYPE
DIM SHARED GrenadeMax
DIM SHARED FireMax
FireMax = 80
GrenadeMax = 8
DIM SHARED BloodPart(32) AS Particle
DIM SHARED ParticlesMax
DIM SHARED BloodMax
DIM SHARED LastBlood
ParticlesMax = 816
DIM SHARED Grenade(GrenadeMax) AS Particle
DIM SHARED Fire(FireMax) AS Particle
DIM SHARED Part(ParticlesMax) AS Particle


HudAmmo = _NEWIMAGE(300, 300, 32)
DIM SHARED PlayerInteract
FlameAmmoMax = 300
SMGAmmoMax = 550
ShotgunAmmoMax = 80
GrenadeAmmoMax = 6
DIM SHARED PlayerHealth
GOSUB RestartEverything
PlayerSkin2 = PlayerSkin


DO
    LastHealth = Player(1).Health
    IF FlameAmmo > FlameAmmoMax THEN FlameAmmo = FlameAmmoMax
    IF SMGAmmo > SMGAmmoMax THEN SMGAmmo = SMGAmmoMax
    IF ShotgunAmmo > ShotgunAmmoMax THEN ShotgunAmmo = ShotgunAmmoMax
    IF GrenadeAmmo > GrenadeAmmoMax THEN GrenadeAmmo = GrenadeAmmoMax
    Mouse.scroll = 0
    _KEYCLEAR
    DO WHILE _MOUSEINPUT
        Mouse.x = _MOUSEX
        Mouse.y = _MOUSEY
        Mouse.click = _MOUSEBUTTON(1)
        Mouse.click2 = _MOUSEBUTTON(2)
        IF _MOUSEWHEEL <> 0 THEN Mouse.scroll = _MOUSEWHEEL
    LOOP
    PlayerInteract = 0
    IF PlayerInteract = 0 AND _KEYDOWN(101) = -1 AND PlayerInteractPre = 0 THEN PlayerInteract = 1
    PlayerInteractPre = _KEYDOWN(101)
    IF _KEYDOWN(15104) AND delay = 0 AND debug = 1 THEN HideUI = HideUI + 1: delay = 20: IF HideUI = 2 THEN HideUI = 0
    IF _KEYDOWN(17408) AND delay = 0 AND debug = 1 THEN NoAI = NoAI + 1: delay = 20: IF NoAI = 2 THEN NoAI = 0
    IF _KEYDOWN(118) AND delay = 0 AND debug = 1 THEN Noclip = Noclip + 1: delay = 20: IF Noclip = 2 THEN Noclip = 0
    IF _KEYDOWN(106) AND delay = 0 AND debug = 1 THEN
        delay = 30
        FOR i = 1 TO ZombieMax
            Zombie(i).health = -1
        NEXT
    END IF
    IF Player(1).Health > 101 THEN Player(1).Health = Player(1).Health - 0.05
    IF Player(1).Health < -1 THEN Player(1).Health = -1

    _LIMIT 62
    CLS
    ff% = ff% + 1
    IF TIMER - start! >= 1 THEN fps% = ff%: ff% = 0: start! = TIMER
    IF delay > 0 THEN delay = delay - 1
    IF ShootDelay > 0 THEN ShootDelay = ShootDelay - 1
    'Camera Control
    IF _KEYDOWN(114) AND debug = 1 THEN Player(1).Health = 100: PlayerCantMove = 0: DeathTimer = 0
    GOSUB RenderSprites
    GOSUB ParticleLogic
    IF PlayerCantMove = 0 THEN GOSUB PlayerMovement
    GOSUB HandsCode
    GOSUB GrenadeLogic
    IF NoAI = 0 THEN GOSUB ZombieAI
    GOSUB RenderMobs
    GOSUB RenderPlayer
    Player(1).shooting = 0
    GOSUB GunCode
    GOSUB Fire
    GOSUB RenderLayer3
    GOSUB TriggerPlayer

    CameraXM = CameraXM / 1.1
    CameraYM = CameraYM / 1.1
    IF Freecam = 0 THEN CameraX = (Player(1).x / Map.TileSize) - (_WIDTH / (Map.TileSize * 2)): CameraY = (Player(1).y / Map.TileSize) - (_HEIGHT / (Map.TileSize * 2)): CameraX = CameraX + CameraXM / 100: CameraY = CameraY + CameraYM / 100

    ' If Debug = 1 Then Tile(Fix(Player(1).x / Map.TileSize), Fix(Player(1).y / Map.TileSize), 1).PlayerStand = 1
    IF _KEYDOWN(15616) AND delay = 0 THEN debug = debug + 1: delay = 20: IF debug = 2 THEN debug = 0
    IF _KEYDOWN(102) AND delay = 0 AND debug = 1 THEN Freecam = Freecam + 1: delay = 20: IF Freecam = 2 THEN Freecam = 0
    IF Freecam = 1 THEN
        IF _KEYDOWN(19200) THEN CameraX = CameraX - 0.1
        IF _KEYDOWN(19712) THEN CameraX = CameraX + 0.1
        IF _KEYDOWN(18432) THEN CameraY = CameraY - 0.1
        IF _KEYDOWN(20480) THEN CameraY = CameraY + 0.1
    END IF
    Player(1).Health = Player(1).Health - Player(1).DamageToTake: Player(1).DamageToTake = 0
    IF Player(1).Health <= 0 AND DeathTimer = 0 THEN DeathTimer = 1
    IF DeathTimer > 0 THEN GOSUB PlayerDeath
    IF Mouse.scroll = -1 AND PlayerCantMove = 0 THEN HudChange = 1: WantSlot = 0
    IF Mouse.scroll = 1 AND PlayerCantMove = 0 THEN HudChange = -1: WantSlot = 0

    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(ShadeRed, 0, 0, DayAmount), BF
    IF WaveWait > 0 THEN GOSUB WaveChange
    GOSUB DrawHud
    IF HideUI = 0 THEN GOSUB MiniMapCode
    IF WaveBudget = 0 THEN GOSUB WaveChange
    IF Wave = 16 THEN GOSUB TurningDay

    IF HideUI = 0 THEN _PUTIMAGE (_WIDTH - 128, _HEIGHT - 128)-(_WIDTH, _HEIGHT), HudImageHealth
    _DISPLAY
    GOSUB HealthHud
    IF _WINDOWHASFOCUS THEN GOSUB ResizeScreen

LOOP
HealthHud:
ValueDis = ABS(PlayerHealth - Player(1).Health)
IF Player(1).Health > PlayerHealth THEN PlayerHealth = PlayerHealth + (ValueDis / 20)
IF Player(1).Health < PlayerHealth THEN PlayerHealth = PlayerHealth - (ValueDis / 20)

IF LastHealth > Player(1).Health THEN
    FOR x = 1 TO FIX(FIX((LastHealth) - INT(Player(1).Health)) / 4)
        LastBloodPart = LastBloodPart + 1: IF LastBloodPart > 32 THEN LastBloodPart = 1
        BloodPart(LastBloodPart).x = 64 ' Int(Rnd * _Width(HeartPercent))
        BloodPart(LastBloodPart).y = _WIDTH(HeartPercent)
        BloodPart(LastBloodPart).xm = INT(RND * 100) - 50
        BloodPart(LastBloodPart).ym = -(80 + INT(RND * 50))
        BloodPart(LastBloodPart).visible = 1
    NEXT
END IF
IF LastHealth <> Player(1).Health THEN
    FontSizeUse = 60
    IF Player(1).Health < 0 THEN Player(1).Health = 0
    Text$ = LTRIM$(STR$(FIX(PlayerHealth)) + "%")
    GOSUB HudText
    HeartThx = thx
    HeartThy = thy
    IF HeartPercent <> 0 THEN _FREEIMAGE HeartPercent
    HeartPercent = _COPYIMAGE(ImgToMenu)
    _SETALPHA 64, _RGBA32(1, 1, 1, 1) TO _RGBA32(255, 255, 255, 255), HeartPercent
END IF
_DEST HudImageHealth
LINE (0, 0)-(_WIDTH, _HEIGHT), _RGB32(0, 0, 0), BF
FOR i = 1 TO 32
    IF BloodPart(i).visible = 1 THEN
        BloodPart(i).x = BloodPart(i).x + BloodPart(i).xm / 10
        BloodPart(i).y = BloodPart(i).y + BloodPart(i).ym / 10
        IF BloodPart(i).x > _WIDTH THEN BloodPart(i).x = _WIDTH: BloodPart(i).xm = -BloodPart(i).xm
        IF BloodPart(i).x < 0 THEN BloodPart(i).x = 0: BloodPart(i).xm = -BloodPart(i).xm
        IF BloodPart(i).ym > 0 THEN RotoZoom BloodPart(i).x, BloodPart(i).y, BloodDrop, 1.5, BloodPart(i).xm / 15
        IF BloodPart(i).ym < 0 THEN RotoZoom BloodPart(i).x, BloodPart(i).y, BloodDrop, 1.5, 180 + BloodPart(i).xm / 15
        IF BloodPart(i).y > _WIDTH(HeartPercent) + 10 THEN BloodPart(i).visible = 0
        IF BloodPart(i).y < -32 THEN BloodPart(i).visible = 0
    END IF
NEXT
RotHeartDisplay = -(Player(1).xm / 6)
IF RotHeartDisplay > 45 THEN RotHearDisplay = 45
IF RotHeartDisplay < -45 THEN RotHearDisplay = -45
RotoZoom _WIDTH / 2 + (Player(1).xm / 50), ((ABS(PlayerHealth - 100) * (_HEIGHT / 100))), Hud_Health_Fluid, 2.2, RotHeartDisplay
'_PutImage ((_Width / 2) + (_Width(HeartPercent) / 2), (_Height / 2) + (_Height(HeartPercent) / 2)), HeartPercent
_PUTIMAGE ((_WIDTH / 2) - HeartThx / 2, (_HEIGHT / 2) - HeartThy / 2), HeartPercent
IF PlayerIsOnFire > 0 THEN firechoosen = (INT(RND * 3) + 1): _PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), FireParticles(firechoosen)

_PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), Hud_Health_Icon

_DEST MainScreen
_CLEARCOLOR _RGB32(0, 255, 0), HudImageHealth
IF Player(1).Health < 60 AND ShadeRed > ABS(60 - Player(1).Health) THEN ShadeRed = ShadeRed - 1
IF Player(1).Health < 60 AND ShadeRed < ABS(60 - Player(1).Health) THEN ShadeRed = ShadeRed + 1
IF Player(1).Health > 60 AND ShadeRed > 0 THEN ShadeRed = ShadeRed - 1
RETURN

RestartEverything:
SizeDelayMinimap = 6
Hud(1).rotation = 200
Wave = 0
WaveWait = 0
WaveBudget = 0
FlameAmmo = 0
SMGAmmo = 150
ShotgunAmmo = 20
GrenadeAmmo = 1
'Generate Minimap Texture
GOSUB GenerateMiniMap
PlayerOnFire = 0
RayM(1).x = (_WIDTH / 2) - (_HEIGHT / 2)
RayM(1).y = 0
RayM(2).x = (_WIDTH / 2) + (_HEIGHT / 2)
RayM(2).y = _HEIGHT
MiniMapGoBack = 20
DayAmount = 128
Player(1).x = 2064 * 2
Player(1).y = 2064 * 2
Player(1).size = 25
GunDisplay(1).visible = 1
GunDisplay(1).wtype = 2
Mouse.click = 0
FOR i = 1 TO GrenadeMax
    Grenade(i).x = 64
    Grenade(i).y = 64
    Grenade(i).z = 1
    Grenade(i).xm = 64
    Grenade(i).ym = 64
    Grenade(i).froozen = 0
    Grenade(i).rotation = 0
    Grenade(i).rotationspeed = 0
    Grenade(i).visible = 0
NEXT
FOR i = 1 TO ZombieMax
    Zombie(i).active = 0
    Zombie(i).onfire = 0
NEXT

FOR i = 1 TO FireMax
    Fire(i).visible = 0
    Fire(i).txt = 0
    Fire(i).xm = 0
    Fire(i).ym = 0
    Fire(i).froozen = 0
NEXT
RenderLayer1 = 1
RenderLayer2 = 1
RenderLayer3 = 1
delay = 100

FOR i = 1 TO ParticlesMax
    Part(i).froozen = 0
    Part(i).visible = 0
NEXT
Zoom = 1
PlayerCantMove = 0
DeathTimer = 0
PlayerIsOnFire = 0
Player(1).Health = 105
PlayerHealth = 105
Player(1).DamageToTake = 0
RETURN

TurningDay:
IF Player(1).Health <= 0 THEN Wave = 1
IF DelayUntilStart > 0 THEN DelayUntilStart = DelayUntilStart - 1
IF DelayUntilStart = 0 AND DayAmount > 0 THEN DayAmount = DayAmount / 1.005
IF DayAmount < 20 AND Tile(FIX(Player(1).x / Map.TileSize), FIX(Player(1).y / Map.TileSize), 1).ID = 66 THEN PlayerIsOnFire = 5

IF DayAmount < 1 THEN DayAmount = 0
IF DayAmount = 0 AND Player(1).Health > 0 THEN
    IF Showtext = 1 THEN WaveDisplayY = -thy * 2
    Showtext = 2
    Darkening = Darkening + 0.5
    IF Darkening > 400 THEN SYSTEM
    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, Darkening), BF

    Text$ = "Rest Well."
    FontSizeUse = 70
    GOSUB HudText

    dist = (ABS(WaveDisplayY - _WIDTH / 2) / 50): WaveDisplayY = WaveDisplayY + 1 / (dist / 15)
    WaveDisplayTHX = thx: WaveDisplayTHY = thy
    _PUTIMAGE (_WIDTH / 2 - WaveDisplayTHX / 2, WaveDisplayY - WaveDisplayTHY / 2), ImgToMenu

    Text$ = ("They will return tomorrow...")
    FontSizeUse = 40
    GOSUB HudText

    WaveDisplayTHX = thx
    _PUTIMAGE (_WIDTH / 2 - WaveDisplayTHX / 2, WaveDisplayY + WaveDisplayTHY / 2), ImgToMenu

END IF
IF Showtext = 1 THEN
    Text$ = "Go inside the house."
    FontSizeUse = 70
    GOSUB HudText

    dist = (ABS(WaveDisplayY - _WIDTH / 2) / 50): WaveDisplayY = WaveDisplayY + 1 / (dist / 15)
    WaveDisplayTHX = thx: WaveDisplayTHY = thy
    _PUTIMAGE (_WIDTH / 2 - WaveDisplayTHX / 2, WaveDisplayY - WaveDisplayTHY / 2), ImgToMenu

    Text$ = ("The sun is coming.")
    FontSizeUse = 40
    GOSUB HudText

    WaveDisplayTHX = thx
    _PUTIMAGE (_WIDTH / 2 - WaveDisplayTHX / 2, WaveDisplayY + WaveDisplayTHY / 2), ImgToMenu
END IF

RETURN

MiniMapCode:
RenderZombiesMinimap = 1
UpdateMiniMap = UpdateMiniMap - 1
IF UpdateMiniMap < 0 THEN GOSUB GenerateMiniMap
IF MiniMapGoBack > 0 THEN MiniMapGoBack = MiniMapGoBack - 1
CheckMiniMapKey = 0
IF CheckMiniMapKey = 0 AND _KEYDOWN(9) = -1 AND CheckMiniMapKeyPre = 0 THEN CheckMiniMapKey = 1
CheckMiniMapKeyPre = _KEYDOWN(9)
IF CheckMiniMapKey = 1 THEN ToggleMinimapBig = ToggleMinimapBig + 1: IF ToggleMinimapBig = 2 THEN ToggleMinimapBig = 0
IF MiniMapGoBack = 1 THEN ToggleMinimapBig = 0: CheckMiniMapKey = 1
IF ToggleMinimapBig = 1 AND CheckMiniMapKey = 1 THEN
    RayM(1).x = Minimap.x1: RayM(1).y = Minimap.y1
    RayM(1).damage = (_WIDTH / 2) - (_HEIGHT / 2)
    RayM(1).knockback = 0: RayM(1).owner = 1
    RayM(2).x = Minimap.x2: RayM(2).y = Minimap.y2
    RayM(2).damage = (_WIDTH / 2) + (_HEIGHT / 2)
    RayM(2).knockback = _HEIGHT
    RayM(2).owner = 1
    MiniMapGoBack = 360
END IF
IF ToggleMinimapBig = 0 AND CheckMiniMapKey = 1 THEN
    RayM(1).x = Minimap.x1: RayM(1).y = Minimap.y1
    RayM(1).damage = _WIDTH - 200
    RayM(1).knockback = 0: RayM(1).owner = 1
    RayM(2).x = Minimap.x2: RayM(2).y = Minimap.y2
    RayM(2).damage = _WIDTH
    RayM(2).knockback = 200
    RayM(2).owner = 1
    MiniMapGoBack = 0
END IF
FOR i = 1 TO 2
    IF RayM(i).owner = 1 THEN
        dx = RayM(i).x - RayM(i).damage: dy = RayM(i).y - RayM(i).knockback
        rotation = ATan2(dy, dx) ' Angle in radians
        RayM(i).angle = (rotation * 180 / PI) + 90
        IF RayM(i).angle > 180 THEN RayM(i).angle = RayM(i).angle - 179.9
        xvector = SIN(RayM(i).angle * PIDIV180): yvector = -COS(RayM(i).angle * PIDIV180)
        RayM(i).x = RayM(i).x + xvector * (0.1 + (Distance(RayM(i).x, RayM(i).y, RayM(i).damage, RayM(i).knockback) / 5))
        RayM(i).y = RayM(i).y + yvector * (0.1 + (Distance(RayM(i).x, RayM(i).y, RayM(i).damage, RayM(i).knockback) / 5))
        IF INT(RayM(i).x) = INT(RayM(i).damage) AND INT(RayM(i).y) = INT(RayM(i).knockback) THEN RayM(i).owner = 0
    END IF
NEXT
Minimap.x1 = RayM(1).x
Minimap.y1 = RayM(1).y
Minimap.x2 = RayM(2).x
Minimap.y2 = RayM(2).y
IF MiniMapGoBack = 0 THEN MinimapSize = INT((Minimap.x2 - Minimap.x1) / SizeDelayMinimap): IF SizeDelayMinimap < 6 THEN SizeDelayMinimap = SizeDelayMinimap + 0.5
IF MiniMapGoBack <> 0 THEN MinimapSize = INT((Minimap.x2 - Minimap.x1) / SizeDelayMinimap): IF SizeDelayMinimap > 2 THEN SizeDelayMinimap = SizeDelayMinimap - 1
Offset = ABS((INT(Player(1).xm) + INT(Player(1).ym) / 2) / 10) + 100 + MinimapSize
_PUTIMAGE (Minimap.x1, Minimap.y1)-(Minimap.x2, Minimap.y2), MinimapIMG, MainScreen, ((Player(1).x / 8) - Offset, (Player(1).y / 8) - Offset)-((Player(1).x / 8) + Offset, (Player(1).y / 8) + Offset)
LINE (Minimap.x1, Minimap.y1)-(Minimap.x2, Minimap.y2), _RGBA32(0, 255, 0, UpdateMiniMap / 1.5), BF
RETURN

GenerateMiniMap:
UpdateMiniMap = 30
_DEST MinimapIMG
FOR x = 0 TO Map.MaxWidth
    FOR y = 0 TO Map.MaxHeight
        z = 1
        xs = x * MinimapTxtSize
        ys = y * MinimapTxtSize
        IF Tile(x, y, z).ID <> 0 THEN _PUTIMAGE (xs, ys)-(xs + (MinimapTxtSize), ys + (MinimapTxtSize)), Tileset, MinimapIMG, (Tile(x, y, z).rend_spritex * Map.TextureSize, Tile(x, y, z).rend_spritey * Map.TextureSize)-(Tile(x, y, z).rend_spritex * Map.TextureSize + (Map.TextureSize - 1), Tile(x, y, z).rend_spritey * Map.TextureSize + (Map.TextureSize - 1))
        LINE (xs, ys)-(xs + (MinimapTxtSize), ys + (MinimapTxtSize)), _RGBA32(0, 0, 0, 64), BF
        z = 2
        IF Tile(x, y, z).ID <> 0 THEN _PUTIMAGE (xs, ys)-(xs + (MinimapTxtSize), ys + (MinimapTxtSize)), Tileset, MinimapIMG, (Tile(x, y, z).rend_spritex * Map.TextureSize, Tile(x, y, z).rend_spritey * Map.TextureSize)-(Tile(x, y, z).rend_spritex * Map.TextureSize + (Map.TextureSize - 1), Tile(x, y, z).rend_spritey * Map.TextureSize + (Map.TextureSize - 1))
    NEXT
NEXT
IF RenderZombiesMinimap = 1 THEN
    FOR i = 1 TO ZombieMax
        IF Zombie(i).active = 1 THEN
            IF Zombie(i).special = "Runner" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(255, 0, 255), BF
            IF Zombie(i).special = "Brute" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(255, 0, 0), BF
            IF Zombie(i).special = "Slower" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(64, 0, 64), BF
            IF Zombie(i).special = "Bomber" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(128, 128, 128), BF
            IF Zombie(i).special = "Fire" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(255, 128, 0), BF
            IF Zombie(i).special = "Biohazard" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(0, 255, 0), BF
            IF Zombie(i).special = "Normal" THEN LINE (Zombie(i).x1 / 8, Zombie(i).y1 / 8)-(Zombie(i).x2 / 8, Zombie(i).y2 / 8), _RGB32(28, 125, 46), BF
        END IF
    NEXT
END IF
LINE (Player(1).x1 / 8, Player(1).y1 / 8)-(Player(1).x2 / 8, Player(1).y2 / 8), _RGB32(255, 255, 255), BF
_DEST MainScreen
RETURN


Fire:
FOR i = 1 TO FireMax
    IF Fire(i).visible > 0 THEN
        IF Fire(i).froozen > Fire(i).visible THEN Fire(i).visible = Fire(i).visible + 1: IF Fire(i).froozen = Fire(i).visible THEN Fire(i).froozen = 0
        Fire(i).x = Fire(i).x + (Fire(i).xm / 10)
        Fire(i).y = Fire(i).y + (Fire(i).ym / 10)
        Fire(i).xm = Fire(i).xm / 1.01
        Fire(i).ym = Fire(i).ym / 1.01
        '    RotoZoom ETSX(Fire(i).x), ETSY(Fire(i).y), FireParticle(Int(Rnd * 3) + 1), 0.1 + (Fire(i).visible / 10), Int(Rnd * 10) - 5
        Size = 0.1 + Fire(i).visible
        _PUTIMAGE (ETSX(Fire(i).x) - Size, ETSY(Fire(i).y) - Size)-(ETSX(Fire(i).x) + Size, ETSY(Fire(i).y) + Size), FireParticle
        IF Fire(i).txt = 0 THEN
            FOR z = 1 TO ZombieMax
                IF Zombie(z).active = 1 THEN IF Distance(Fire(i).x, Fire(i).y, Zombie(z).x, Zombie(z).y) < (Size * 2) THEN Zombie(z).onfire = Fire(i).visible * 5
            NEXT
        END IF
        IF INT(RND * 20) = 3 THEN Fire(i).visible = Fire(i).visible - 1
        IF Fire(i).visible > 10 AND Fire(i).txt <> 4 AND Distance(Fire(i).x, Fire(i).y, Player(1).x, Player(1).y) < INT(Size * 1.5) THEN PlayerIsOnFire = 10 * Fire(i).visible
        IF Fire(i).visible > 20 AND FIX(Fire(i).visible / 1.5) > 5 AND INT(RND * 10) = 3 THEN
            FireLast = FireLast + 1: IF FireLast > FireMax THEN FireLast = 1
            Fire(FireLast).txt = Fire(i).txt
            Fire(i).visible = Fire(i).visible - 5
            Fire(FireLast).froozen = FIX(Fire(i).visible * 2.5)
            Fire(FireLast).visible = 2
            Fire(FireLast).x = Fire(i).x + (INT(RND * 30) - 15) * 2
            Fire(FireLast).y = Fire(i).y + (INT(RND * 30) - 15) * 2
            FOR k = 1 TO FireMax
                IF k <> i THEN
                    IF Distance(Fire(i).x, Fire(i).y, Fire(k).x, Fire(k).y) < (Size * 2) THEN Fire(FireLast).visible = 5
                END IF
            NEXT
        END IF
        IF Fire(i).visible = 0 THEN
            Fire(i).txt = 0
            Fire(i).xm = 0
            Fire(i).ym = 0
            Fire(i).froozen = 0
        END IF
    END IF

NEXT
RETURN






ResizeScreen:
IF ResizeDelay > 0 THEN ResizeDelay = ResizeDelay - 1
IF _RESIZE AND ResizeDelay = 0 AND _WINDOWHASFOCUS THEN
    CLS
    SCREEN SecondScreen
    _FREEIMAGE MainScreen
    ScreenSizeX = _RESIZEWIDTH
    ScreenSizeY = _RESIZEHEIGHT
    IF ScreenSizeX < 128 THEN ScreenSizeX = 128
    IF ScreenSizeY < 128 THEN ScreenSizeY = 128
    MainScreen = _NEWIMAGE(ScreenSizeX, ScreenSizeY, 32)
    SCREEN MainScreen

    ResizeDelay = 5
END IF
RETURN

TriggerPlayer:
FOR i = 1 TO Map.Triggers
    IF TriggerPlayerCollide(Player(1), Trigger(i)) THEN
        SELECT CASE Trigger(i).class
            CASE "TP"
                Player(1).x = Trigger(i).val1 * 2
                Player(1).y = Trigger(i).val2 * 2
            CASE "DoorUse"
                IF PlayerInteract = 1 THEN
                    DoorX = FIX(((Trigger(i).x2 + Trigger(i).x1) / 2) / Map.TileSize)
                    DoorY = FIX(((Trigger(i).y2 + Trigger(i).y1) / 2) / Map.TileSize)
                    Trigger(i).val3 = Trigger(i).val3 + 1: IF Trigger(i).val3 > 1 THEN Trigger(i).val3 = 0
                    IF Trigger(i).val3 = 0 THEN Tile(DoorX, DoorY, 2).ID = Trigger(i).val1: Tile(DoorX, DoorY, 2).solid = 1
                    IF Trigger(i).val3 = 1 THEN Tile(DoorX, DoorY, 2).ID = Trigger(i).val2: Tile(DoorX, DoorY, 2).solid = 0
                    IDTOTEXTURE = Tile(DoorX, DoorY, 2).ID: Tile(DoorX, DoorY, 2).rend_spritey = 0
                    DO
                        IF IDTOTEXTURE > 16 THEN Tile(DoorX, DoorY, 2).rend_spritey = Tile(DoorX, DoorY, 2).rend_spritey + 1: IDTOTEXTURE = IDTOTEXTURE - 16
                        Tile(DoorX, DoorY, 2).rend_spritex = IDTOTEXTURE
                    LOOP WHILE IDTOTEXTURE > 16
                END IF
        END SELECT
    END IF
NEXT
RETURN


PlayerDeath:
IF DeathTimer = 1 THEN _SNDPLAY PlayerDeath
IF DeathTimer < 1000 THEN DeathTimer = DeathTimer + 3
Hud(1).ym = DeathTimer * 2
IF INT(RND * 6) + 1 = 3 AND DeathTimer < 400 THEN SpawnBloodParticle Player(1).x - 20 + INT(RND * 21), Player(1).y - 20 + INT(RND * 21), -180 + INT(RND * 361), 20, "red": Part(LastPart).xm = INT(RND * 500) - 250: Part(LastPart).ym = INT(RND * 500) - 250: Part(LastPart).zm = INT(Part(LastPart).zm / 4)
DayAmount = DayAmount + 1
PlayerCantMove = 1
IF DayAmount > 480 THEN GOSUB RestartEverything
RETURN

WaveChange:

RANDOMIZE TIMER
IF WaveWait = 0 THEN
    WaveWait = 600: WaveDisplayY = -thy: Wave = Wave + 1: WaveBudget = (Wave * 7) + INT(RND * 22)
    IF WaveBudget > 128 THEN WaveBudget = 128
END IF
IF Wave = 16 THEN WaveWait = -9999999: DelayUntilStart = 2000: Showtext = 1: WaveDisplayY = -thy * 2: GOTO EndWaveCode
IF WaveWait = 1 THEN
    DayAmount = DayAmount - 1
    FOR i = 1 TO WaveBudget
        CreateZombie:
        Special = 0
        IF INT(RND * 3) + 1 = 1 THEN Special = 1
        IF Special = 1 THEN SpecialType = INT(RND * 6) + 1

        IF Special <> 1 THEN
            Rand = INT(RND * 60)
            IF Rand = 25 THEN
                Zombie(i).size = INT(RND * (DefZombie.size - 20 + 1)) + 20 ' DefZombie.size
            ELSE
                Zombie(i).size = DefZombie.size
            END IF
            Zombie(i).active = 1
            Zombie(i).maxspeed = INT(RND * (500 - 300 + 1)) + 300
            Zombie(i).damage = INT(RND * (6 - 2 + 1)) + 2
            Zombie(i).speeding = INT(RND * (20 - 10 + 1)) + 10
            Zombie(i).knockback = INT(RND * (8 - 5 + 1)) + 5
            Zombie(i).special = "Normal"
            Zombie(i).health = INT(RND * (DefZombie.maxhealth - DefZombie.minhealth + 1)) + DefZombie.minhealth
            Zombie(i).weight = 1
        END IF
        IF Special = 1 THEN
            Zombie(i).active = 1
            SELECT CASE SpecialType
                CASE 1 ' Runner
                    Rand = INT(RND * 20120)
                    Zombie(i).size = INT(RND * (34 - 25 + 1)) + 25
                    Zombie(i).health = INT(RND * (INT(DefZombie.maxhealth / 1.5) - FIX(DefZombie.minhealth / 1.5) + 1)) + FIX(DefZombie.minhealth / 2)
                    Zombie(i).maxspeed = INT(RND * (1100 - 900 + 1)) + 900
                    Zombie(i).damage = INT(RND * (8 - 2 + 1)) + 2
                    Zombie(i).speeding = INT(RND * (45 - 30 + 1)) + 30
                    Zombie(i).knockback = INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).special = "Runner"
                    Zombie(i).weight = 1
                CASE 2 ' Brute
                    Rand = INT(RND * 8)
                    IF Rand = 3 THEN GOTO CreateZombie
                    Zombie(i).size = INT(RND * (100 - 70 + 1)) + 70
                    Zombie(i).health = INT(RND * ((DefZombie.maxhealth + 300) - DefZombie.minhealth + 1)) + DefZombie.minhealth + (Zombie(i).size * 2)
                    Zombie(i).maxspeed = INT(RND * (600 - 500 + 1)) + 500
                    Zombie(i).damage = INT(RND * (80 - 40 + 1)) + 40
                    Zombie(i).speeding = INT(RND * (20 - 10 + 1)) + 10
                    Zombie(i).knockback = INT(RND * (50 - 30 + 1)) + 30
                    Zombie(i).special = "Brute"
                    Zombie(i).weight = 20
                CASE 3 ' Slower
                    Zombie(i).size = INT(RND * (34 - 25 + 1)) + 25
                    Zombie(i).health = INT(RND * (INT(DefZombie.maxhealth + 20) - FIX(DefZombie.minhealth) + 1)) + FIX(DefZombie.minhealth)
                    Zombie(i).damage = INT(RND * (30 - 20 + 1)) + 20
                    Zombie(i).maxspeed = DefZombie.maxspeed
                    Zombie(i).speeding = INT(RND * (7 - 4 + 1)) + 4
                    Zombie(i).weight = 2
                    Zombie(i).knockback = INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).special = "Slower"
                CASE 4 ' Bomber
                    Rand = INT(RND * 12)
                    IF Rand = 7 THEN GOTO CreateZombie

                    Zombie(i).size = INT(RND * (34 - 25 + 1)) + 25
                    Zombie(i).health = INT(RND * (INT(DefZombie.maxhealth / 2) - FIX(DefZombie.minhealth / 2) + 1)) + FIX(DefZombie.minhealth / 2)
                    Zombie(i).maxspeed = INT(RND * (850 - 700 + 1)) + 700
                    Zombie(i).damage = INT(RND * (10 - 2 + 1)) + 2
                    Zombie(i).speeding = INT(RND * (30 - 20 + 1)) + 20
                    Zombie(i).knockback = INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).special = "Bomber"
                    Zombie(i).weight = 2
                CASE 5 ' Fire
                    Rand = INT(RND * 20)
                    IF Rand = 9 THEN GOTO CreateZombie

                    Zombie(i).size = INT(RND * (37 - 27 + 1)) + 27
                    Zombie(i).health = INT(RND * (INT(DefZombie.maxhealth) - FIX(DefZombie.minhealth) + 1)) + FIX(DefZombie.minhealth)
                    Zombie(i).maxspeed = INT(RND * (850 - 500 + 1)) + 500
                    Zombie(i).damage = INT(RND * (10 - 2 + 1)) + 2
                    Zombie(i).speeding = INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).knockback = INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).special = "Fire"
                    Zombie(i).weight = 1
                CASE 6 ' Biohazard
                    Rand = INT(RND * 200)
                    Zombie(i).size = INT(RND * (37 - 27 + 1)) + 27
                    Zombie(i).health = INT(RND * (INT(DefZombie.maxhealth) - FIX(DefZombie.minhealth) + 1)) + FIX(DefZombie.minhealth)
                    Zombie(i).maxspeed = INT(RND * (850 - 500 + 1)) + 500
                    Zombie(i).damage = INT(RND * (10 - 2 + 1)) + 2
                    Zombie(i).speeding = INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).knockback = -INT(RND * (10 - 5 + 1)) + 5
                    Zombie(i).special = "Biohazard"
                    Zombie(i).weight = 2
            END SELECT
        END IF
        Zombie(i).x = 4 + INT(RND * (Map.MaxWidth - 8))
        Zombie(i).y = 4 + INT(RND * (Map.MaxHeight - 8))
        IF Tile(FIX(Zombie(i).x), FIX(Zombie(i).y), 2).solid = 1 THEN GOTO CreateZombie
        Zombie(i).x = Zombie(i).x * Map.TileSize
        Zombie(i).y = Zombie(i).y * Map.TileSize
        Zombie(i).healthFirst = Zombie(i).health
        Zombie(i).sizeFirst = Zombie(i).size
    NEXT
END IF
IF WaveWait > 0 THEN WaveWait = WaveWait - 1
Text$ = "Wave: " + STR$(Wave)
FontSizeUse = 70
GOSUB HudText
dist = (ABS(WaveDisplayY - _WIDTH / 2) / 50): WaveDisplayY = WaveDisplayY + 1 / (dist / 15)
WaveDisplayTHX = thx: WaveDisplayTHY = thy
_PUTIMAGE (_WIDTH / 2 - WaveDisplayTHX / 2, WaveDisplayY - WaveDisplayTHY / 2), ImgToMenu
Text$ = (_TRIM$(STR$(WaveBudget)) + " Infecteds coming...")
FontSizeUse = 40
GOSUB HudText
WaveDisplayTHX = thx
_PUTIMAGE (_WIDTH / 2 - WaveDisplayTHX / 2, WaveDisplayY + WaveDisplayTHY / 2), ImgToMenu
EndWaveCode:
RETURN


DrawHud:
IF DelayHud > 0 THEN DelayHud = DelayHud - 1
IF DelayHud > 0 THEN HudChange = 0
IF DelayHud = 0 AND HudChange <> 0 THEN DelayHud = 18: Hud(1).xm = HudChange * 700: Hud(1).ym = -300
IF HudChange <> 0 THEN SlotRotation = SlotRotation + HudChange * 20
SlotRotation = SlotRotation / 1.1
HudSlotSelected = HudSlotSelected + HudChange
HudSize = _WIDTH + _HEIGHT
Hud(1).x = _WIDTH / 2 + (Hud(1).xm / 10) + INT(Player(1).xm / 4)
Hud(1).y = _HEIGHT + (Hud(1).ym / 10) + INT(Player(1).ym / 6)
Hud(1).xm = Hud(1).xm / 1.025
Hud(1).ym = Hud(1).ym / 1.025

'If HudChangeOld = 0 And HudChange <> 0 Then Hud(1).rotation = Hud(1).rotation + HudChange * 5
HudChangeOld = HudChange
Hud(1).rotation = Hud(1).rotation + SlotRotation 'Hud(1).rotation + Distance

HighestHudAmount = 9999999
FOR i = 2 TO 6
    Hud(i).xm = Hud(i).xm / 1.05
    Hud(i).ym = Hud(i).ym / 1.05

    degree = i * 72
    Hudxv = SIN((Hud(1).rotation + degree) * PIDIV180)
    Hudyv = -COS((Hud(1).rotation + degree) * PIDIV180)
    Hud(i).x = (Hud(1).x + Hudxv * 128)
    Hud(i).y = (Hud(1).y + Hudyv * 64)
    IF Hud(i).y < HighestHudAmount THEN HighestHudAmount = Hud(i).y: HighestHud = i

NEXT
IF HudChange = 0 THEN HudTopDistance = (Hud(HighestHud).x - Hud(1).x)
Hud(1).rotation = Hud(1).rotation - (HudTopDistance) / 7.5
HudChange = 0
FOR i = 2 TO 6
    Hud(i).size = 32
    Hud(i).x1 = Hud(i).x - Hud(i).size + Hud(i).xm
    Hud(i).x2 = Hud(i).x + Hud(i).size + Hud(i).xm
    Hud(i).y1 = Hud(i).y - Hud(i).size + Hud(i).ym
    Hud(i).y2 = Hud(i).y + Hud(i).size + Hud(i).ym
    Side0 = HighestHud - 2: IF Side0 <= 1 THEN Side0 = Side0 + 5
    Side3 = HighestHud + 2: IF Side3 >= 7 THEN Side3 = Side3 - 5

    Side1 = HighestHud - 1: IF Side1 = 1 THEN Side1 = 6
    Side2 = HighestHud + 1: IF Side2 = 7 THEN Side2 = 2
    IF HideUI = 0 THEN
        IF i = HighestHud THEN _MAPTRIANGLE (0, 0)-(16, 32)-(32, 0), HudSelected TO(Hud(i).x1, Hud(i).y2)-(Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2) ' Line (Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2), _RGB32(255, 255, 255): Line (Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2), _RGB32(255, 255, 255)
        IF i = Side1 THEN _MAPTRIANGLE (0, 0)-(16, 32)-(32, 0), HudNotSelected TO(Hud(i).x2, Hud(i).y1)-(Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2) ' Line (Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2), _RGB32(255, 255, 255): Line (Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2), _RGB32(255, 255, 255)
        IF i = Side2 THEN _MAPTRIANGLE (0, 0)-(16, 32)-(32, 0), HudNotSelected TO(Hud(i).x1, Hud(i).y1)-(Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2) ' Line (Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2), _RGB32(255, 255, 255): Line (Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2), _RGB32(255, 255, 255)
        IF i = Side3 THEN _MAPTRIANGLE (0, 0)-(16, 32)-(32, 0), HudNotSelected TO(Hud(i).x2, Hud(i).y1)-(Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2) ' Line (Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2), _RGB32(255, 255, 255): Line (Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2), _RGB32(255, 255, 255)
        IF i = Side0 THEN _MAPTRIANGLE (0, 0)-(16, 32)-(32, 0), HudNotSelected TO(Hud(i).x1, Hud(i).y1)-(Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2) ' Line (Hud(1).x, Hud(1).y)-(Hud(i).x1, Hud(i).y2), _RGB32(255, 255, 255): Line (Hud(1).x, Hud(1).y)-(Hud(i).x2, Hud(i).y2), _RGB32(255, 255, 255)
        _PUTIMAGE (Hud(1).x - 5, Hud(1).y - 5)-(Hud(1).x + 5, Hud(1).y + 5), PlayerHand(1)
        '  If i <> HighestHud Then Line (Hud(1).x, Hud(1).y)-(Hud(i).x, Hud(i).y), _RGB32(255, 255, 255)
        IF i = HighestHud THEN LINE (Hud(i).x1, Hud(i).y1)-(Hud(i).x2, Hud(i).y2), _RGB32(255, 255, 255), BF
        IF i <> HighestHud THEN LINE (Hud(i).x1, Hud(i).y1)-(Hud(i).x2, Hud(i).y2), _RGB32(128, 128, 128), BF


        IF i = 2 THEN
            _PUTIMAGE (Hud(i).x1, Hud(i).y1)-(Hud(i).x2, Hud(i).y2), Guns_Pistol

            percent = CalculatePercentage(SMGAmmoMax, SMGAmmo) / 10
            pc = FIX(percent * 25.5)
            pc2 = ABS(pc - 255)
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x2, Hud(i).y2), _RGB32(0, 0, 0), BF
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x1 + (percent * 6.4), Hud(i).y2), _RGB32(pc2, pc, 0), BF
        END IF
        IF i = 3 THEN
            _PUTIMAGE ((Hud(i).x + Hud(i).xm) - (_WIDTH(Guns_Shotgun) / 4), (Hud(i).y + Hud(i).ym) - (_HEIGHT(Guns_Shotgun) / 4))-(Hud(i).x + Hud(i).xm + (_WIDTH(Guns_Shotgun) / 4), Hud(i).y + Hud(i).ym + (_HEIGHT(Guns_Shotgun) / 4)), Guns_Shotgun
            percent = CalculatePercentage(ShotgunAmmoMax, ShotgunAmmo) / 10
            pc = FIX(percent * 25.5)
            pc2 = ABS(pc - 255)
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x2, Hud(i).y2), _RGB32(0, 0, 0), BF
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x1 + (percent * 6.4), Hud(i).y2), _RGB32(pc2, pc, 0), BF

        END IF
        IF i = 4 THEN
            _PUTIMAGE (Hud(i).x1, Hud(i).y1)-(Hud(i).x2, Hud(i).y2), Guns_SMG
            percent = CalculatePercentage(SMGAmmoMax, SMGAmmo) / 10
            pc = FIX(percent * 25.5)
            pc2 = ABS(pc - 255)
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x2, Hud(i).y2), _RGB32(0, 0, 0), BF
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x1 + (percent * 6.4), Hud(i).y2), _RGB32(pc2, pc, 0), BF

        END IF
        IF i = 5 THEN
            _PUTIMAGE (Hud(i).x1, Hud(i).y1)-(Hud(i).x2, Hud(i).y2), Guns_Grenade
            percent = CalculatePercentage(GrenadeAmmoMax, GrenadeAmmo) / 10
            pc = FIX(percent * 25.5)
            pc2 = ABS(pc - 255)
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x2, Hud(i).y2), _RGB32(0, 0, 0), BF
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x1 + (percent * 6.4), Hud(i).y2), _RGB32(pc2, pc, 0), BF

        END IF
        IF i = 6 THEN
            _PUTIMAGE (Hud(i).x1, Hud(i).y1)-(Hud(i).x2, Hud(i).y2), Guns_Flame
            percent = CalculatePercentage(FlameAmmoMax, FlameAmmo) / 10
            pc = FIX(percent * 25.5)
            pc2 = ABS(pc - 255)
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x2, Hud(i).y2), _RGB32(0, 0, 0), BF
            LINE (Hud(i).x1, Hud(i).y2 - (Hud(i).size / 5))-(Hud(i).x1 + (percent * 6.4), Hud(i).y2), _RGB32(pc2, pc, 0), BF

        END IF
    END IF
NEXT
RETURN

HudText:
_FONT BegsFontSizes(FontSizeUse)
thx = _PRINTWIDTH(Text$)
thy = _FONTHEIGHT(BegsFontSizes(FontSizeUse))
IF ImgToMenu <> 0 THEN _FREEIMAGE ImgToMenu
ImgToMenu = _NEWIMAGE(thx * 3, thy * 3, 32)
_DEST ImgToMenu
_CLEARCOLOR _RGB32(0, 0, 0): _PRINTMODE _KEEPBACKGROUND: _FONT BegsFontSizes(FontSizeUse): PRINT Text$
_DEST MainScreen
_FONT BegsFontSizes(20)
RETURN





GrenadeLogic:
FOR i = 1 TO GrenadeMax
    IF Grenade(i).visible = 0 THEN GOTO EndOfGrenadeLogic
    Grenade(i).x = Grenade(i).x + (Grenade(i).xm / 10)
    Grenade(i).y = Grenade(i).y + (Grenade(i).ym / 10)
    Grenade(i).z = Grenade(i).z + (Grenade(i).zm / 10)
    IF Grenade(i).z > 0 THEN Grenade(i).zm = Grenade(i).zm - 2
    IF Grenade(i).z < 0 AND Grenade(i).zm < 0 THEN
        _SNDPLAYCOPY ShellSounds(INT(1 + RND * 3)), 0.25
        Grenade(i).zm = INT(Grenade(i).zm * -0.5)
        Grenade(i).xm = INT(Grenade(i).xm / 2): Grenade(i).ym = INT(Grenade(i).ym / 2)

    END IF
    IF Grenade(i).froozen = -1 THEN
        x1 = FIX(Grenade(i).x / Map.TileSize) - 3
        x2 = FIX(Grenade(i).x / Map.TileSize) + 3
        y1 = FIX(Grenade(i).y / Map.TileSize) - 3
        y2 = FIX(Grenade(i).y / Map.TileSize) + 3
        IF x1 < 0 THEN x1 = 0
        IF y1 < 0 THEN y1 = 0
        IF x2 > Map.MaxWidth THEN x2 = Map.MaxWidth
        IF y2 > Map.MaxHeight THEN y2 = Map.MaxHeight

        FOR x = x1 TO x2
            FOR y = y1 TO y2
                IF Tile(x, y, 2).fragile = 1 THEN
                    FOR o = 1 TO 5
                        Part(LastPart).x = x * Map.TileSize + INT(RND * Map.TileSize): Part(LastPart).y = y * Map.TileSize + INT(RND * Map.TileSize): Part(LastPart).z = 2: Part(LastPart).xm = INT(RND * 128) - 64: Part(LastPart).ym = INT(RND * 128) - 64: Part(LastPart).zm = 2 + INT(RND * 7)
                        Part(LastPart).froozen = -30: Part(LastPart).visible = 1600: Part(LastPart).partid = "GlassShard": Part(LastPart).playwhatsound = "Glass"
                        Part(LastPart).rotation = INT(RND * 360) - 180: Part(LastPart).rotationspeed = INT(RND * 60) - 30: LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
                    NEXT
                    IF Tile(x, y, 2).ID = 56 THEN _SNDPLAYCOPY GlassShadder(INT(1 + RND * 3)), 0.4
                    Tile(x, y, 2).ID = 0
                    Tile(x, y, 2).solid = 0
                    Tile(x, y, 2).rend_spritex = 0
                    Tile(x, y, 2).rend_spritey = 0
                END IF

            NEXT
        NEXT
        Grenade(i).visible = 0
        Grenade(i).froozen = 0
        Explosion Grenade(i).x, Grenade(i).y, 100, 350
        CIRCLE (ETSX(Grenade(i).x), ETSY(Grenade(i).y)), 200, _RGB32(255, 255, 255)
        _SNDPLAY SND_Explosion
    END IF
    IF Grenade(i).froozen < 0 THEN Grenade(i).froozen = Grenade(i).froozen + 1
    IF FIX(Grenade(i).z) <= 0 THEN Grenade(i).z = 0
    IF Grenade(i).xm > 0 THEN Grenade(i).xm = Grenade(i).xm - 1
    IF Grenade(i).ym > 0 THEN Grenade(i).ym = Grenade(i).ym - 1
    IF Grenade(i).xm < 0 THEN Grenade(i).xm = Grenade(i).xm + 1
    IF Grenade(i).ym < 0 THEN Grenade(i).ym = Grenade(i).ym + 1
    IF Tile(FIX((Grenade(i).x + 8) / Map.TileSize), FIX(Grenade(i).y / Map.TileSize), 2).solid = 1 THEN Grenade(i).xm = Grenade(i).xm * -1.1: Grenade(i).ym = 0
    IF Tile(FIX((Grenade(i).x - 8) / Map.TileSize), FIX(Grenade(i).y / Map.TileSize), 2).solid = 1 THEN Grenade(i).xm = Grenade(i).xm * -1.1: Grenade(i).ym = 0
    IF Tile(FIX(Grenade(i).x / Map.TileSize), FIX((Grenade(i).y + 8) / Map.TileSize), 2).solid = 1 THEN Grenade(i).xm = 0: Grenade(i).ym = Grenade(i).ym * -1.1
    IF Tile(FIX(Grenade(i).x / Map.TileSize), FIX((Grenade(i).y - 8) / Map.TileSize), 2).solid = 1 THEN Grenade(i).xm = 0: Grenade(i).ym = Grenade(i).ym * -1.1
    Grenade(i).rotation = Grenade(i).rotation + Grenade(i).rotationspeed
    IF Grenade(i).rotationspeed > 0 THEN Grenade(i).rotationspeed = Grenade(i).rotationspeed - 1
    IF Grenade(i).rotationspeed < 0 THEN Grenade(i).rotationspeed = Grenade(i).rotationspeed + 1
    RotoZoom ETSX(Grenade(i).x), ETSY(Grenade(i).y), Guns_Grenade, .6 + (Grenade(i).z / 50), Grenade(i).rotation + 90
    EndOfGrenadeLogic:
NEXT
RETURN




RenderMobs:
FOR i = 1 TO ZombieMax
    IF Zombie(i).active = 1 THEN
        '  If debug = 1 Then

        SELECT CASE Zombie(i).special
            CASE "Runner"
                'If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(255, 0, 255), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), ZombieRunner, Zombie(i).size / 90, Zombie(i).rotation
            CASE "Brute"
                '  If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(255, 0, 0), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), ZombieBrute, Zombie(i).size / 90, Zombie(i).rotation
            CASE "Slower"
                '  If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(64, 0, 64), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), ZombieSlower, Zombie(i).size / 90, Zombie(i).rotation
            CASE "Bomber"
                ' If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(128, 128, 128), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), ZombieBomber, Zombie(i).size / 90, Zombie(i).rotation
            CASE "Fire"
                ' If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(255, 128, 0), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), ZombieFire, Zombie(i).size / 90, Zombie(i).rotation
            CASE "Biohazard"
                '  If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(0, 255, 0), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), ZombieBiohazard, Zombie(i).size / 90, Zombie(i).rotation

            CASE "Normal"
                '   If Debug = 1 Then Line (ETSX(Zombie(i).x1), ETSY(Zombie(i).y1))-(ETSX(Zombie(i).x2), ETSY(Zombie(i).y2)), _RGB32(255, 255, 128), BF
                RotoZoom ETSX(Zombie(i).x), ETSY(Zombie(i).y), Zombie, Zombie(i).size / 90, Zombie(i).rotation

        END SELECT






        ' End If

    END IF
NEXT
RETURN


ZombieAI:
FOR i = 1 TO ZombieMax
    IF Zombie(i).active = 1 THEN
        IF Zombie(i).special <> "" AND Zombie(i).DistanceFromPlayer < 900 THEN
            IF Zombie(i).special = "Runner" THEN IF Zombie(i).tick > 0 THEN Zombie(i).tick = Zombie(i).tick - 1
            IF Zombie(i).special = "Fire" THEN
                IF Zombie(i).DistanceFromPlayer < 450 AND INT(RND * 10) = 4 THEN
                    FireLast = FireLast + 1: IF FireLast > FireMax THEN FireLast = 1
                    Fire(FireLast).visible = 40: Fire(FireLast).froozen = 800
                    Fire(FireLast).x = Zombie(i).x + (INT(RND * 8) - 4): Fire(FireLast).y = Zombie(i).y + (INT(RND * 8) - 4)
                    Fire(FireLast).txt = 1: speed = (90 + INT(RND * 80))
                    angle = Zombie(i).rotation + INT(RND * 10) - 5: Fire(FireLast).xm = SIN(angle * PIDIV180) * speed
                    Fire(FireLast).ym = -COS(angle * PIDIV180) * speed
                END IF
                IF INT(RND * 40) = 23 THEN
                    FireLast = FireLast + 1: IF FireLast > FireMax THEN FireLast = 1
                    Fire(FireLast).x = Zombie(i).x + (INT(RND * 30) - 15) * 2
                    Fire(FireLast).txt = 1
                    Fire(FireLast).y = Zombie(i).y + (INT(RND * 30) - 15) * 2
                    IF Distance(Fire(FireLast).x, Fire(FireLast).y, Player(1).x, Player(1).y) > 80 THEN
                        Fire(FireLast).xm = INT(RND * 100) - 50: Fire(FireLast).ym = INT(RND * 100) - 50
                        IF INT(RND * 100) = 54 THEN
                            Fire(FireLast).froozen = 500 + INT(RND * 250): Fire(FireLast).visible = 10
                        ELSE
                            Fire(FireLast).froozen = 70 + INT(RND * 120): Fire(FireLast).visible = 10
                        END IF
                    END IF
                END IF
            END IF
            IF Zombie(i).special = "Bomber" THEN
                IF Zombie(i).DistanceFromPlayer < 500 AND Zombie(i).DistanceFromPlayer > 6 THEN
                    Zombie(i).SpecialDelay = Zombie(i).SpecialDelay + 1
                    IF Zombie(i).SpecialDelay < 120 THEN
                        Zombie(i).size = Zombie(i).size * 1.001: IF Zombie(i).sizeFirst + 20 < Zombie(i).size THEN Zombie(i).size = Zombie(i).sizeFirst + 20
                    END IF
                    IF Zombie(i).SpecialDelay > 120 THEN
                        Zombie(i).size = Zombie(i).size * 1.05: IF Zombie(i).size > 120 THEN Zombie(i).size = 120
                        Zombie(i).health = (Zombie(i).health / 1.1) - 0.1
                    END IF
                ELSE
                    IF Zombie(i).SpecialDelay > 0 THEN Zombie(i).SpecialDelay = Zombie(i).SpecialDelay - 1
                    dif = Zombie(i).sizeFirst - Zombie(i).size
                    Zombie(i).size = Zombie(i).size + (dif / 10)
                    dif = Zombie(i).healthFirst - Zombie(i).health
                    Zombie(i).health = Zombie(i).health + (dif / 10)
                END IF
            END IF
        END IF
        'Burn
        IF Zombie(i).special <> "Fire" THEN
            IF Zombie(i).onfire > 0 THEN
                Zombie(i).onfire = Zombie(i).onfire - 1
                IF INT(RND * 6) = 2 THEN
                    Zombie(i).health = Zombie(i).health - 2
                    FireLast = FireLast + 1: IF FireLast > FireMax THEN FireLast = 1
                    Fire(FireLast).visible = 6
                    Fire(FireLast).froozen = 20
                    Fire(FireLast).txt = 0
                    Fire(FireLast).x = Zombie(i).x + (INT(RND * 30) - 15) * 2
                    Fire(FireLast).y = Zombie(i).y + (INT(RND * 30) - 15) * 2
                    Fire(FireLast).xm = (Zombie(i).xm / 10) + (INT(RND * 30) - 15) * 2
                    Fire(FireLast).ym = (Zombie(i).ym / 10) + (INT(RND * 30) - 15) * 2
                END IF
            END IF
        END IF

        IF Zombie(i).DamageTaken > 0 THEN
            FOR S = 1 TO INT(Zombie(i).DamageTaken / 4)
                SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, Steps, "green"
            NEXT
            Zombie(i).health = Zombie(i).health - Zombie(i).DamageTaken: Zombie(i).DamageTaken = 0
        END IF

        IF Zombie(i).tick > 0 THEN Zombie(i).tick = Zombie(i).tick - 1
        Zombie(i).x = Zombie(i).x + Zombie(i).xm / 100: Zombie(i).y = Zombie(i).y + Zombie(i).ym / 100
        Zombie(i).x1 = Zombie(i).x - Zombie(i).size: Zombie(i).x2 = Zombie(i).x + Zombie(i).size: Zombie(i).y1 = Zombie(i).y - Zombie(i).size: Zombie(i).y2 = Zombie(i).y + Zombie(i).size

        Zombie(i).xm = Zombie(i).xm + FIX(SIN(Zombie(i).rotation * PIDIV180) * Zombie(i).speeding)
        Zombie(i).ym = Zombie(i).ym + FIX(-COS(Zombie(i).rotation * PIDIV180) * Zombie(i).speeding)
        IF Zombie(i).xm > Zombie(i).maxspeed THEN Zombie(i).xm = Zombie(i).maxspeed
        IF Zombie(i).ym > Zombie(i).maxspeed THEN Zombie(i).ym = Zombie(i).maxspeed
        IF Zombie(i).xm < -Zombie(i).maxspeed THEN Zombie(i).xm = -Zombie(i).maxspeed
        IF Zombie(i).ym < -Zombie(i).maxspeed THEN Zombie(i).ym = -Zombie(i).maxspeed
        Zombie(i).xm = Zombie(i).xm / (1.010 + (Zombie(i).speeding / 2000))
        Zombie(i).ym = Zombie(i).ym / (1.010 + (Zombie(i).speeding / 2000))
        IF CollisionWithWallsEntity(Zombie(i)) THEN
        END IF
        IF Zombie(i).tick = 0 THEN
            IF INT(RND * 60) = 27 AND Zombie(i).DistanceFromPlayer < 400 THEN _SNDPLAYCOPY ZombieWalk(INT(RND * 4) + 1), 0.08

            o = 1: DO
                o = o + 1
                IF i <> o AND Zombie(o).active = 1 THEN
                    dist = Distance(Zombie(i).x, Zombie(i).y, Zombie(o).x, Zombie(o).y)
                    IF dist < Zombie(i).size THEN
                        dx = Zombie(i).x - Zombie(o).x: dy = Zombie(i).y - Zombie(o).y
                        RotDist = ATan2(dy, dx) ' Angle in radians
                        RotDist = (RotDist * 180 / PI) + 90
                        IF RotDist > 180 THEN RotDist = RotDist - 179.9
                        Zombie(i).xm = Zombie(i).xm - FIX(SIN(RotDist * PIDIV180) * 350)
                        Zombie(i).ym = Zombie(i).ym - FIX(-COS(RotDist * PIDIV180) * 350)

                    END IF
                END IF

            LOOP WHILE o <> ZombieMax

            Zombie(i).tick = DefZombie.tickrate + (INT(RND * 20) - 10)
            dx = Zombie(i).x - Player(1).x: dy = Zombie(i).y - Player(1).y
            Zombie(i).rotation = ATan2(dy, dx) ' Angle in radians
            Zombie(i).rotation = (Zombie(i).rotation * 180 / PI) + 90 + (-20 + INT(RND * 40))
            IF Zombie(i).rotation > 180 THEN Zombie(i).rotation = Zombie(i).rotation - 179.9
            Zombie(i).DistanceFromPlayer = INT(Distance(Zombie(i).x, Zombie(i).y, Player(1).x, Player(1).y))
            IF Zombie(i).DistanceFromPlayer < (Zombie(i).size * 1.8) THEN
                IF Zombie(i).attacking = 0 THEN Zombie(i).attacking = INT(Zombie(i).knockback / 3)
                IF Zombie(i).attacking = INT(Zombie(i).knockback / 3) THEN
                    Zombie(i).xm = Zombie(i).xm / 15
                    Zombie(i).ym = Zombie(i).ym / 15
                    Player(1).DamageToTake = INT(RND * (DefZombie.maxdamage - DefZombie.mindamage + 1)) + DefZombie.mindamage
                    PlayerTakeDamage Player(1), Zombie(i).x, Zombie(i).y, Player(1).DamageToTake, Zombie(i).knockback
                    Player(1).DamageToTake = 0
                END IF
            END IF
            IF Zombie(i).attacking > 0 THEN Zombie(i).attacking = Zombie(i).attacking - 1
        END IF
        IF Zombie(i).health <= 0 THEN
            Zombie(i).SpecialDelay = 0 '     ------------------- Ammo Dropping --------------------
            IF Zombie(i).special = "Fire" THEN SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "GasAmmo"
            IF Zombie(i).special = "Bomber" THEN SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "GrenadeAmmo"
            IF INT(RND * 2) + 1 = 2 THEN
                IF Zombie(i).special = "Normal" THEN
                    Rand = INT(RND * 2) + 1
                    IF Rand = 1 THEN
                        SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "ShotgunAmmo"
                    ELSE
                        FOR y = 1 TO INT(RND * 2) + 1
                            SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "PistolAmmo"
                        NEXT
                    END IF
                END IF

            END IF
            IF Zombie(i).special = "Brute" THEN
                Rand = INT(RND * 4)
                FOR b = 1 TO Rand
                    SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 7, "ShotgunAmmo"
                    SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 7, "PistolAmmo"
                    IF INT(RND * 4) = 2 THEN SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "GrenadeAmmo"
                NEXT
            END IF
            IF Zombie(i).special = "Bomber" THEN
                Explosion Zombie(i).x, Zombie(i).y, 80, 320: _SNDPLAY SND_Explosion
                FOR b = 1 TO 50
                    SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, INT(RND * 70), "green"
                NEXT
            END IF
            IF Zombie(i).health <= -30 THEN SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "GibSkull"
            Zombie(i).active = 0
            Zombie(i).onfire = 0
            WaveBudget = WaveBudget - 1
            FOR o = 1 TO 10
                SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, Steps, "green"
                IF Zombie(i).health <= -30 AND INT(RND * 3) = 2 THEN SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "GibBone"
                IF Zombie(i).health >= -30 AND INT(RND * 8) = 2 THEN SpawnBloodParticle Zombie(i).x, Zombie(i).y, INT(RND * 360) - 180, 5, "GibBone"
            NEXT
        END IF
        IF Zombie(i).x < 0 OR Zombie(i).y < 0 THEN
            Zombie(i).x = 100: Zombie(i).y = 100: Zombie(i).ym = 0: Zombie(i).xm = 0
            Zombie(i).health = 0

            BEEP: PRINT "Zombie(" + STR$(i) + ") Out of bounds!!!!!!!!!!!!!!!!"
            _DISPLAY
            BEEP: BEEP
            _DELAY 0.6
        END IF
    END IF

NEXT
RETURN

ParticleLogic:
FOR i = 1 TO ParticlesMax
    IF Part(i).visible = 0 THEN GOTO EndOfParticleLogic
    IF Part(i).playwhatsound = "Blood" AND Part(i).froozen = 0 THEN
        dist = Distance(Player(1).x, Player(1).y, Part(i).x, Part(i).y)
        IF dist > 900 THEN Part(i).visible = Part(i).visible - 1
        IF dist < 600 AND Player(1).Health > 0 THEN

            IF dist < 30 AND Part(i).partid = "BloodSplat" THEN
                LastBloodPart = LastBloodPart + 1: IF LastBloodPart > 32 THEN LastBloodPart = 1
                BloodPart(LastBloodPart).x = 64 ' Int(Rnd * _Width(HeartPercent))
                BloodPart(LastBloodPart).y = -8
                BloodPart(LastBloodPart).xm = INT(RND * 100) - 50
                BloodPart(LastBloodPart).ym = 80 + INT(RND * 50)
                BloodPart(LastBloodPart).visible = 1
                Part(i).visible = 0: Part(i).xm = 0: Part(i).ym = 0: Part(i).playwhatsound = "": Player(1).Health = Player(1).Health + 0.11: GOTO EndOfParticleLogic
            END IF
            IF dist < 25 AND Part(i).partid = "PistolAmmo" THEN SMGAmmo = SMGAmmo + 50: Part(i).playwhatsound = "": Part(i).visible = 0: Part(i).xm = 0: Part(i).ym = 0: GOTO EndOfParticleLogic
            IF dist < 25 AND Part(i).partid = "ShotgunAmmo" THEN ShotgunAmmo = ShotgunAmmo + 12: Part(i).playwhatsound = "": Part(i).visible = 0: Part(i).xm = 0: Part(i).ym = 0: GOTO EndOfParticleLogic
            IF dist < 25 AND Part(i).partid = "GasAmmo" THEN FlameAmmo = FlameAmmo + 50: Part(i).playwhatsound = "": Part(i).visible = 0: Part(i).xm = 0: Part(i).ym = 0: GOTO EndOfParticleLogic
            IF dist < 25 AND Part(i).partid = "GrenadeAmmo" THEN GrenadeAmmo = GrenadeAmmo + 1: Part(i).playwhatsound = "": Part(i).visible = 0: Part(i).xm = 0: Part(i).ym = 0: GOTO EndOfParticleLogic
            dx = Player(1).x - Part(i).x: dy = Player(1).y - Part(i).y
            Part(i).rotation = ATan2(dy, dx) ' Angle in radians
            Part(i).rotation = (Part(i).rotation * 180 / PI) + 90
            IF Part(i).rotation > 180 THEN Part(i).rotation = Part(i).rotation - 179.9
            Part(i).xm = Part(i).xm / 1.03
            Part(i).ym = Part(i).ym / 1.03
            Part(i).xm = Part(i).xm + -SIN(Part(i).rotation * PIDIV180) * 9 / (dist / 150)
            Part(i).ym = Part(i).ym + COS(Part(i).rotation * PIDIV180) * 9 / (dist / 150)
            Part(i).x = Part(i).x + (Part(i).xm / 10)
            Part(i).y = Part(i).y + (Part(i).ym / 10)
            Part(i).z = 3 / (dist / 70)
            IF Part(i).z > 15 THEN Part(i).z = 15
        END IF
    END IF

    IF Part(i).froozen <> 0 THEN
        Part(i).x = Part(i).x + (Part(i).xm / 10)
        Part(i).y = Part(i).y + (Part(i).ym / 10)
        Part(i).z = Part(i).z + (Part(i).zm / 10)
        IF Part(i).z > 0 THEN Part(i).zm = Part(i).zm - 1
        IF Part(i).z < 0 AND Part(i).zm < 0 THEN
            IF Part(i).playwhatsound = "ShotgunShell" THEN
                _SNDPLAYCOPY ShellSounds(INT(1 + RND * 3)), 0.2
                Part(i).zm = INT(Part(i).zm * -0.9)
                Part(i).xm = INT(Part(i).xm / 2): Part(i).ym = INT(Part(i).ym / 2)
                Part(i).froozen = -200
            END IF

            IF Part(i).playwhatsound = "PistolShell" THEN
                pistsndold = pistsnd
                pistsnd = INT(1 + RND * 3)
                IF pistsnd = pistsndold THEN pistsnd = INT(1 + RND * 3)
                _SNDPLAYCOPY PistolShellSounds(pistsnd), 0.25
                Part(i).zm = INT(Part(i).zm * -0.9)
                Part(i).xm = INT(Part(i).xm / 2): Part(i).ym = INT(Part(i).ym / 2)
                Part(i).froozen = -200
            END IF

            IF Part(i).playwhatsound = "Blood" THEN
                _SNDPLAYCOPY BloodSounds(INT(1 + RND * 6)), 0.1
                Part(i).zm = INT(Part(i).zm * -0.7)
                Part(i).xm = INT(Part(i).xm / 1.4): Part(i).ym = INT(Part(i).ym / 1.4)
                Part(i).froozen = -200
            END IF

            IF Part(i).playwhatsound = "Glass" THEN
                _SNDPLAYCOPY GlassSound(INT(1 + RND * 4)), 0.2
                Part(i).zm = INT(Part(i).zm * -0.9)
                Part(i).xm = INT(Part(i).xm / 2): Part(i).ym = INT(Part(i).ym / 2)
                Part(i).froozen = -200
            END IF
        END IF
        IF Part(i).froozen < 0 THEN Part(i).froozen = Part(i).froozen + 1
        IF FIX(Part(i).z) <= 0 THEN Part(i).z = 0
        IF Part(i).xm > 0 THEN Part(i).xm = Part(i).xm - 1
        IF Part(i).ym > 0 THEN Part(i).ym = Part(i).ym - 1
        IF Part(i).xm < 0 THEN Part(i).xm = Part(i).xm + 1
        IF Part(i).ym < 0 THEN Part(i).ym = Part(i).ym + 1

        x = FIX(Part(i).x / Map.TileSize)
        y = FIX(Part(i).y / Map.TileSize)
        IF x < 0 THEN x = 0
        IF y < 0 THEN y = 0
        IF x > Map.MaxWidth THEN x = Map.MaxWidth
        IF y > Map.MaxHeight THEN y = Map.MaxHeight

        IF Tile(x, y, 2).solid = 1 THEN Part(i).xm = 0: Part(i).ym = 0
        Part(i).rotation = Part(i).rotation + Part(i).rotationspeed
        IF Part(i).rotationspeed > 0 THEN Part(i).rotationspeed = Part(i).rotationspeed - 1
        IF Part(i).rotationspeed < 0 THEN Part(i).rotationspeed = Part(i).rotationspeed + 1
    END IF
    IF NOT Part(i).playwhatsound = "Blood" THEN Part(i).visible = Part(i).visible - 1
    '_PutImage (ETSX(Part(i).x), ETSY(Part(i).y)), Particle_Shotgun_Shell
    IF Part(i).visible > 0 THEN
        IF Part(i).partid = "PistolShell" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Particle_Pistol_Shell, 0.3 + (Part(i).z / 4), Part(i).rotation
        IF Part(i).partid = "ShotgunShell" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Particle_Shotgun_Shell, 0.3 + (Part(i).z / 4), Part(i).rotation
        IF Part(i).partid = "WallShot" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), WallShot, 0.8 + (Part(i).z / 4), Part(i).rotation
        IF Part(i).partid = "Smoke" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Particle_Smoke, 0.05 + (Part(i).z / 4), Part(i).rotation
        IF Part(i).partid = "Explosion" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Particle_Explosion, 0.1 + (Part(i).z / 4), Part(i).rotation
        IF Part(i).partid = "BloodSplat" THEN
            IF Part(i).BloodColor = "green" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), BloodsplatGreen, 1 + (Part(i).z / 4), Part(i).rotation
            IF Part(i).BloodColor = "red" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), BloodsplatRed, 1 + (Part(i).z / 4), Part(i).rotation

        END IF
        IF Part(i).partid = "GlassShard" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), GlassShard, 1 + (Part(i).z / 2), Part(i).rotation
        IF Part(i).partid = "GibSkull" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Gib_Skull, 2 + (Part(i).z / 3), Part(i).rotation
        IF Part(i).partid = "GibBone" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Gib_Bone, 2 + (Part(i).z / 3), Part(i).rotation
        IF Part(i).partid = "PistolAmmo" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), PistolShellAmmo, 1 + (Part(i).z / 3), Part(i).rotation
        IF Part(i).partid = "GrenadeAmmo" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), Guns_Grenade, 1 + (Part(i).z / 3), Part(i).rotation
        IF Part(i).partid = "ShotgunAmmo" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), ShellShotgunAmmo, 1 + (Part(i).z / 3), Part(i).rotation
        IF Part(i).partid = "GasAmmo" THEN RotoZoom ETSX(Part(i).x), ETSY(Part(i).y), GasCanAmmo, 1 + (Part(i).z / 3), Part(i).rotation

    END IF
    EndOfParticleLogic:
NEXT
RETURN



GunCode:
IF WeaponHeat > 0 THEN WeaponHeat = WeaponHeat - 1
IF WeaponHeat > 45 THEN WeaponHeat = 45
GOSUB LoadingFromSlots
FOR i = 1 TO 1
    o = -1
    IF GunDisplay(i).visible = 1 THEN
        o = o + 1
        GunDisplay(i).x = ((PlayerMember(i + o).x + PlayerMember(i * 2).x) / 2) 'Player(i).x + (Sin(Player(i).Rotation * PIDIV180) * 38)
        GunDisplay(i).y = ((PlayerMember(i + o).y + PlayerMember(i * 2).y) / 2) 'Player(i).y + (-Cos(Player(i).Rotation * PIDIV180) * 38)
        GunDisplay(i).x = GunDisplay(i).x + GunDisplay(i).xm
        GunDisplay(i).y = GunDisplay(i).y + GunDisplay(i).ym
        GunDisplay(i).xm = INT(GunDisplay(i).xm / 2)
        GunDisplay(i).ym = INT(GunDisplay(i).ym / 2)
        IF Player(1).shooting = 0 THEN FlameSoundPlaying = 0: _SNDSTOP FlameThrowerSound
        GOSUB Shooting
        IF Player(1).shooting = 1 THEN
            GunDisplay(i).xm = -INT(SIN(GunDisplay(i).rotation * PIDIV180) * GunForce * 2)
            GunDisplay(i).ym = -INT(-COS(GunDisplay(i).rotation * PIDIV180) * GunForce * 2)
            IF Aiming = 0 THEN
                CameraXM = CameraXM + -INT(SIN(GunDisplay(i).rotation * PIDIV180) * GunForce)
                CameraYM = CameraYM + -INT(-COS(GunDisplay(i).rotation * PIDIV180) * GunForce)
            END IF
            IF Aiming = 1 THEN
                CameraXM = CameraXM + -INT(SIN(GunDisplay(i).rotation * PIDIV180) * (GunForce / 2))
                CameraYM = CameraYM + -INT(-COS(GunDisplay(i).rotation * PIDIV180) * (GunForce / 2))
            END IF
            Hud(1).xm = Hud(1).xm - INT(SIN(GunDisplay(i).rotation * PIDIV180) * GunForce) * 5
            Hud(1).ym = Hud(1).ym - INT(-COS(GunDisplay(i).rotation * PIDIV180) * GunForce) * 2
            Hud(HighestHud).xm = Hud(HighestHud).xm - INT(SIN(GunDisplay(i).rotation * PIDIV180) * GunForce)
            Hud(HighestHud).ym = Hud(HighestHud).ym - INT(-COS(GunDisplay(i).rotation * PIDIV180) * GunForce)

        END IF
        dx = Player(i).x - GunDisplay(i).x: dy = Player(i).y - GunDisplay(i).y
        GunDisplay(i).rotation = ATan2(dy, dx) ' Angle in radians
        GunDisplay(i).rotation = (GunDisplay(i).rotation * 180 / PI) + 90
        IF GunDisplay(i).rotation > 180 THEN GunDisplay(i).rotation = GunDisplay(i).rotation - 180
        'GunDisplay(i).rotation = Player(i).Rotation + 90
        IF debug = 1 THEN LINE (ETSX(GunDisplay(i).x - 16), ETSY(GunDisplay(i).y - 16))-(ETSX(GunDisplay(i).x + 16), ETSY(GunDisplay(i).y + 16)), _RGBA32(255, 255, 255, 75), BF
        IF GunDisplay(i).wtype = 1 THEN RotoZoom ETSX(GunDisplay(i).x), ETSY(GunDisplay(i).y), Guns_Pistol, .3, GunDisplay(i).rotation + 90
        IF GunDisplay(i).wtype = 2 THEN RotoZoom ETSX(GunDisplay(i).x), ETSY(GunDisplay(i).y), Guns_Shotgun, .45, GunDisplay(i).rotation + 90
        IF GunDisplay(i).wtype = 3 THEN RotoZoom ETSX(GunDisplay(i).x), ETSY(GunDisplay(i).y), Guns_SMG, .5, GunDisplay(i).rotation + 90
        IF GunDisplay(i).wtype = 4 THEN RotoZoom ETSX(GunDisplay(i).x), ETSY(GunDisplay(i).y), Guns_Grenade, .6, GunDisplay(i).rotation + 90
        IF GunDisplay(i).wtype = 5 THEN RotoZoom ETSX(GunDisplay(i).x), ETSY(GunDisplay(i).y), Guns_Flame, .6, GunDisplay(i).rotation + 90
    END IF
NEXT
RETURN

Shooting:
IF Mouse.click AND ShootDelay = 0 AND PlayerCantMove = 0 THEN
    Player(1).shooting = 1
    IF GunDisplay(1).wtype = 1 AND SMGAmmo = 0 THEN
        Player(1).shooting = 0

    END IF
    IF GunDisplay(1).wtype = 2 AND ShotgunAmmo = 0 THEN
        Player(1).shooting = 0

    END IF
    IF GunDisplay(1).wtype = 3 AND SMGAmmo = 0 THEN
        Player(1).shooting = 0

    END IF
    IF GunDisplay(1).wtype = 4 AND GrenadeAmmo = 0 THEN
        Player(1).shooting = 0

    END IF
    IF GunDisplay(1).wtype = 5 AND FlameAmmo = 0 THEN
        Player(1).shooting = 0
        _SNDSTOP FlameThrowerSound
    END IF


    IF GunDisplay(1).wtype = 1 AND SMGAmmo > 0 THEN
        _SNDPLAYCOPY Guns_Sound_PistolShot, 0.3: IF raycasting(GunDisplay(1).x, GunDisplay(1).y, GunDisplay(1).rotation + (INT(RND * 3) - 1), 14, 1) THEN BEEP
        LINE (ETSX(GunDisplay(1).x), ETSY(GunDisplay(1).y))-(ETSX(Ray.x), ETSY(Ray.y)), _RGB32(255, 0, 0)
        ShootDelay = 14: GunForce = 10
        Part(LastPart).x = GunDisplay(1).x: Part(LastPart).y = GunDisplay(1).y: Part(LastPart).z = 2 + INT(RND * 2)
        Part(LastPart).xm = INT(RND * 80) - 40
        Part(LastPart).ym = INT(RND * 80) - 40
        Part(LastPart).zm = 2 + INT(RND * 4)
        Part(LastPart).froozen = 12: Part(LastPart).visible = 800
        Part(LastPart).partid = "PistolShell": Part(LastPart).playwhatsound = "PistolShell"
        Part(LastPart).rotation = INT(RND * 360) - 180
        Part(LastPart).rotationspeed = INT(RND * 60) - 30
        LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
    END IF

    IF GunDisplay(1).wtype = 2 AND ShotgunAmmo > 0 THEN
        _SNDPLAYCOPY Guns_Sound_ShotgunShot, 0.3: GunForce = 50
        ShotgunAmmo = ShotgunAmmo - 1
        FOR S = 1 TO 5
            IF raycasting(GunDisplay(1).x, GunDisplay(1).y, GunDisplay(1).rotation - (INT(RND * 20) - 10), 10, 1) THEN BEEP
            LINE (ETSX(GunDisplay(1).x), ETSY(GunDisplay(1).y))-(ETSX(Ray.x), ETSY(Ray.y)), _RGB32(255, 0, 0)
        NEXT
        ShootDelay = 50
        Part(LastPart).x = GunDisplay(1).x: Part(LastPart).y = GunDisplay(1).y: Part(LastPart).z = 3 + INT(RND * 2)
        Part(LastPart).xm = INT(RND * 120) - 60: Part(LastPart).ym = INT(RND * 120) - 60: Part(LastPart).zm = 2 + INT(RND * 4)
        Part(LastPart).froozen = 12: Part(LastPart).visible = 800
        Part(LastPart).partid = "ShotgunShell": Part(LastPart).playwhatsound = "ShotgunShell"
        Part(LastPart).rotation = INT(RND * 360) - 180
        Part(LastPart).rotationspeed = INT(RND * 60) - 30
        LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
    END IF

    IF GunDisplay(1).wtype = 3 AND SMGAmmo > 0 THEN
        _SNDPLAYCOPY SMGSounds(1 + INT(RND * 3)), 0.125
        SMGAmmo = SMGAmmo - 1: GunForce = 13
        WeaponHeat = WeaponHeat + 4
        IF raycasting(GunDisplay(1).x, GunDisplay(1).y, GunDisplay(1).rotation + ((INT(RND * INT(WeaponHeat / 2)) - INT(WeaponHeat / 4)) + INT(RND * 10) - 5), 8, 1) THEN BEEP

        LINE (ETSX(GunDisplay(1).x), ETSY(GunDisplay(1).y))-(ETSX(Ray.x), ETSY(Ray.y)), _RGB32(255, 0, 0): ShootDelay = 6
        Part(LastPart).x = GunDisplay(1).x: Part(LastPart).y = GunDisplay(1).y: Part(LastPart).z = 2 + INT(RND * 2)
        Part(LastPart).xm = INT(RND * 120) - 60: Part(LastPart).ym = INT(RND * 120) - 60: Part(LastPart).zm = 1 + INT(RND * 5)
        Part(LastPart).froozen = 12: Part(LastPart).visible = 800
        Part(LastPart).partid = "PistolShell": Part(LastPart).playwhatsound = "PistolShell"
        Part(LastPart).rotation = INT(RND * 360) - 180
        Part(LastPart).rotationspeed = INT(RND * 60) - 30
        LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
    END IF


    IF GunDisplay(1).wtype = 4 AND GrenadeAmmo > 0 THEN
        GrenadeAmmo = GrenadeAmmo - 1
        ShootDelay = 30
        GunForce = 35
        'LastGrenade = LastGrenade + 1
        LastGrenade = LastGrenade + 1: IF LastGrenade > GrenadeMax THEN LastGrenade = 1
        Grenade(LastGrenade).x = GunDisplay(1).x
        Grenade(LastGrenade).y = GunDisplay(1).y
        Grenade(LastGrenade).z = 15
        Force = Distance(Mouse.x, Mouse.y, _WIDTH / 2, _HEIGHT / 2) / 3: IF Force > 200 THEN Force = 200
        Grenade(LastGrenade).xm = SIN(GunDisplay(1).rotation * PIDIV180) * Force
        Grenade(LastGrenade).ym = -COS(GunDisplay(1).rotation * PIDIV180) * Force
        Grenade(LastGrenade).zm = 15 + INT(RND * 20)
        Grenade(LastGrenade).rotation = -5 + INT(RND * 10)
        Grenade(LastGrenade).rotationspeed = -30 + INT(RND * 15)
        Grenade(LastGrenade).visible = 1
        Grenade(LastGrenade).froozen = -160
    END IF

    IF GunDisplay(1).wtype = 5 AND FlameAmmo > 0 THEN

        IF FlameSoundPlaying = 0 THEN _SNDVOL FlameThrowerSound, 0.09: _SNDLOOP FlameThrowerSound
        FlameSoundPlaying = 1
        FlameAmmo = FlameAmmo - 1
        ShootDelay = 2
        GunForce = 6
        FireLast = FireLast + 1: IF FireLast > FireMax THEN FireLast = 1
        Fire(FireLast).visible = 2
        Fire(FireLast).froozen = 100
        Fire(FireLast).txt = 0
        Fire(FireLast).x = GunDisplay(1).x + (INT(RND * 8) - 4)
        Fire(FireLast).y = GunDisplay(1).y + (INT(RND * 8) - 4)

        speed = (70 + INT(RND * 80))
        angle = GunDisplay(1).rotation + INT(RND * 40) - 20
        Fire(FireLast).xm = SIN(angle * PIDIV180) * speed
        Fire(FireLast).ym = -COS(angle * PIDIV180) * speed
    END IF





END IF
RETURN

LoadingFromSlots:
'If _KeyDown(49) Then WantSlot = 2
'If _KeyDown(50) Then WantSlot = 3
'If _KeyDown(51) Then WantSlot = 4
IF HighestHud = 2 THEN
    GunDisplay(1).wtype = 1
    PlayerMember(1).angleanim = -36: PlayerMember(1).distanim = 40
    PlayerMember(2).angleanim = 36: PlayerMember(2).distanim = 40

END IF

IF HighestHud = 3 THEN
    GunDisplay(1).wtype = 2
    PlayerMember(1).angleanim = -29: PlayerMember(1).distanim = 67
    PlayerMember(2).angleanim = 50: PlayerMember(2).distanim = 42
END IF
IF HighestHud = 4 THEN
    GunDisplay(1).wtype = 3
    PlayerMember(1).angleanim = -29: PlayerMember(1).distanim = 67
    PlayerMember(2).angleanim = 50: PlayerMember(2).distanim = 42
END IF

IF HighestHud = 5 THEN
    GunDisplay(1).wtype = 4
    PlayerMember(1).angleanim = -29: PlayerMember(1).distanim = 67
    PlayerMember(2).angleanim = 50: PlayerMember(2).distanim = 42
END IF

IF HighestHud = 6 THEN
    GunDisplay(1).wtype = 5
    PlayerMember(1).angleanim = -29: PlayerMember(1).distanim = 67
    PlayerMember(2).angleanim = 50: PlayerMember(2).distanim = 42
END IF


RETURN



HandsCode:
'Xbe and 'Ybe
ArmLeftOrigin = Player(1).Rotation + 90
ArmRightOrigin = Player(1).Rotation - 90
PlayerMember(1).xo = SIN(ArmLeftOrigin * PIDIV180)
PlayerMember(1).yo = -COS(ArmLeftOrigin * PIDIV180)
PlayerMember(2).xo = SIN(ArmRightOrigin * PIDIV180)
PlayerMember(2).yo = -COS(ArmRightOrigin * PIDIV180)
xo1 = Player(1).x + PlayerMember(1).xo * 32
yo1 = Player(1).y + PlayerMember(1).yo * 32
xo2 = Player(1).x + PlayerMember(2).xo * 32
yo2 = Player(1).y + PlayerMember(2).yo * 32
IF debug = 1 THEN
    LINE (ETSX(xo1) - 2, ETSY(yo1) - 2)-(ETSX(xo1) + 2, ETSY(yo1) + 2), _RGB32(255, 0, 255), BF
    LINE (ETSX(xo2) - 2, ETSY(yo2) - 2)-(ETSX(xo2) + 2, ETSY(yo2) + 2), _RGB32(255, 0, 255), BF
END IF
PlayerMember(1).xo = Player(1).x + PlayerMember(1).xo * 32
PlayerMember(1).yo = Player(1).y + PlayerMember(1).yo * 32
PlayerMember(2).xo = Player(1).x + PlayerMember(2).xo * 32
PlayerMember(2).yo = Player(1).y + PlayerMember(2).yo * 32

RotationDifference = ABS(Player(1).Rotation - PlayerRotOld)
IF RotationDifference > 90 THEN RotationDifference = 180 - RotationDifference
FOR i = 1 TO 2

    Angleadded = PlayerMember(i).angleanim + Player(1).Rotation ' If Angleadded > 180 Then Angleadded = Angleadded - 180
    PlayerMember(i).xbe = PlayerMember(i).xo + SIN((Angleadded) * PIDIV180) * PlayerMember(i).distanim
    PlayerMember(i).ybe = PlayerMember(i).yo + -COS((Angleadded) * PIDIV180) * PlayerMember(i).distanim
    IF debug = 1 THEN PRINT "Member(" + STR$(i) + "): "; Angleadded

    IF NOT PlayerMember(i).x = PlayerMember(i).xbe AND NOT PlayerMember(i).y = PlayerMember(i).ybe THEN
        dx = (PlayerMember(i).x - PlayerMember(i).xbe): dy = (PlayerMember(i).y - PlayerMember(i).ybe)
        PlayerMember(i).angle = ATan2(dy, dx) ' Angle in radians
        PlayerMember(i).angle = (PlayerMember(i).angle * 180 / PI) + 90
        IF PlayerMember(i).angle >= 180 THEN PlayerMember(i).angle = PlayerMember(i).angle - 179.9
    END IF

    IF INT(PlayerMember(i).x) = INT(PlayerMember(i).xbe) AND INT(PlayerMember(i).y) = INT(PlayerMember(i).ybe) THEN PlayerMember(i).xvector = 0: PlayerMember(i).yvector = 0
    IF debug = 1 THEN PRINT "MemberRot(" + STR$(i) + "): "; PlayerMember(i).angle
    PlayerMember(i).xvector = SIN(PlayerMember(i).angle * PIDIV180)
    PlayerMember(i).yvector = -COS(PlayerMember(i).angle * PIDIV180)
    moving2 = moving: IF moving2 > 12 THEN moving2 = 12
    IF moving2 > 0 THEN PlayerMember(i).speed = moving2 / 10 + Distance(PlayerMember(i).x, PlayerMember(i).y, PlayerMember(i).xbe, PlayerMember(i).ybe) / 20
    'Alterar este codigo, causa bug envolvendo 180 graus.
    'https://gamedev.stackexchange.com/questions/74986/how-can-i-find-the-difference-between-rotations-represented-as-angles-in-0-360
    IF moving = 0 THEN PlayerMember(i).speed = 0.2 + Distance(PlayerMember(i).x, PlayerMember(i).y, PlayerMember(i).xbe, PlayerMember(i).ybe) / 20
    IF moving > 0 THEN
        PlayerMember(i).x = PlayerMember(i).x - INT(Player(1).xm / moving2)
        PlayerMember(i).y = PlayerMember(i).y - INT(Player(1).ym / moving2)
    END IF
    ' If Int(PlayerMember(i).y) = Int(PlayerMember(i).ybe) Then PlayerMember(i).y = PlayerMember(i).ybe: PlayerMember(i).speed = 0
    'If Int(PlayerMember(i).x) = Int(PlayerMember(i).xbe) Then PlayerMember(i).x = PlayerMember(i).xbe: PlayerMember(i).speed = 0


    PlayerMember(i).x = PlayerMember(i).x + PlayerMember(i).xvector * PlayerMember(i).speed
    PlayerMember(i).y = PlayerMember(i).y + PlayerMember(i).yvector * PlayerMember(i).speed

    IF Distance(PlayerMember(i).x, PlayerMember(i).y, PlayerMember(i).xbe, PlayerMember(i).ybe) > 100 THEN PlayerMember(i).x = Player(1).x: PlayerMember(i).y = Player(1).y
    '_PutImage (PlayerMember(i).x - 8 - CameraX * Map.TileSize, PlayerMember(i).y - 8 - CameraY * Map.TileSize)-(PlayerMember(i).x + 8 - CameraX * Map.TileSize, PlayerMember(i).y + 8 - CameraY * Map.TileSize), PlayerHand
    IF debug = 1 THEN LINE (ETSX(PlayerMember(i).x), ETSY(PlayerMember(i).y))-(ETSX(PlayerMember(i).xbe), ETSY(PlayerMember(i).ybe)), _RGB(0, 0, 0)
    'Line (ETSX(PlayerMember(i).x), ETSY(PlayerMember(i).y))-(ETSX(PlayerMember(i).x), ETSY(PlayerMember(i).y)), _RGB(255, 255, 255)
NEXT
IF debug = 1 THEN LINE (ETSX(xo1), ETSY(yo1))-(ETSX(PlayerMember(1).x), ETSY(PlayerMember(1).y)), _RGB32(255, 255, 0)
IF debug = 1 THEN LINE (ETSX(xo2), ETSY(yo2))-(ETSX(PlayerMember(2).x), ETSY(PlayerMember(2).y)), _RGB32(255, 255, 0)

RETURN


PlayerMovement:
Aiming = 0
IF Mouse.click2 THEN
    Aiming = 1
    IF FIX(AimingTime) = 0 THEN AimingTime = 15
    AimingTime = AimingTime * 1.1
    IF AimingTime > 600 THEN AimingTime = 600
    CameraXM = CameraXM + (SIN(GunDisplay(1).rotation * PIDIV180) * (10 + (AimingTime / 20)))
    CameraYM = CameraYM + (-COS(GunDisplay(1).rotation * PIDIV180) * (10 + (AimingTime / 20)))
    Player(1).xm = INT(Player(1).xm / 1.1)
    Player(1).ym = INT(Player(1).ym / 1.1)
ELSE
    AimingTime = 0
END IF
Player(1).xb = Player(1).x
Player(1).yb = Player(1).y
PlayerRotOld = Player(1).Rotation
dx = INT(_WIDTH / 2) - Mouse.x: dy = INT(_HEIGHT / 2) - Mouse.y
Player(1).Rotation = ATan2(dy, dx) ' Angle in radians
Player(1).Rotation = (Player(1).Rotation * 180 / PI) + 90
IF debug = 1 THEN PRINT "Player Rotation: "; Player(1).Rotation
IF PlayerIsOnFire > 0 THEN
    PlayerIsOnFire = PlayerIsOnFire - 1
    IF INT(RND * 6) = 2 THEN
        Player(1).Health = Player(1).Health - 0.25

        FireLast = FireLast + 1: IF FireLast > FireMax THEN FireLast = 1
        Fire(FireLast).visible = 5
        Fire(FireLast).froozen = 18
        Fire(FireLast).x = Player(1).x + (INT(RND * 30) - 15) * 2
        Fire(FireLast).y = Player(1).y + (INT(RND * 30) - 15) * 2
        Fire(FireLast).txt = 4
        Fire(FireLast).xm = (-Player(1).xm) + (INT(RND * 30) - 15) * 2
        Fire(FireLast).ym = (-Player(1).ym) + (INT(RND * 30) - 15) * 2
    END IF
END IF
IF Player(1).Rotation > 180 THEN Player(1).Rotation = Player(1).Rotation - 180
IF INT(Player(1).Rotation) > -7 AND INT(Player(1).Rotation) < 1 AND Mouse.y > _HEIGHT / 2 THEN Player(1).Rotation = 180
'If Int(Player(1).Rotation) = -2 And Mouse.y > _Height / 2 Then Player(1).Rotation = 180
movingx = 0: movingy = 0: IF ismoving = 0 AND moving > 0 THEN moving = moving - 1
IF moving > 20 THEN moving = 20
ismoving = 0:
IF Player(1).TouchX = 0 THEN
    IF _KEYDOWN(100) THEN Player(1).xm = Player(1).xm - 3: movingx = 1: IF ismoving = 0 THEN moving = moving + 1: ismoving = 1
    IF _KEYDOWN(97) THEN Player(1).xm = Player(1).xm + 3: movingx = 1: IF ismoving = 0 THEN moving = moving + 1: ismoving = 1
END IF
IF Player(1).TouchY = 0 THEN
    IF _KEYDOWN(119) THEN Player(1).ym = Player(1).ym + 3: movingy = 1: IF ismoving = 0 THEN moving = moving + 1: ismoving = 1
    IF _KEYDOWN(115) THEN Player(1).ym = Player(1).ym - 3: movingy = 1: IF ismoving = 0 THEN moving = moving + 1: ismoving = 1
END IF
IF Player(1).TouchX > 0 THEN Player(1).TouchX = Player(1).TouchX - 1
IF Player(1).TouchX < 0 THEN Player(1).TouchX = Player(1).TouchX + 1
IF Player(1).TouchY > 0 THEN Player(1).TouchY = Player(1).TouchY - 1
IF Player(1).TouchY < 0 THEN Player(1).TouchY = Player(1).TouchY + 1
FOR i = 1 TO 5
    IF movingx = 0 THEN IF Player(1).xm < 0 THEN Player(1).xm = Player(1).xm + 1
    IF movingx = 0 THEN IF Player(1).xm > 0 THEN Player(1).xm = Player(1).xm - 1
    IF movingy = 0 THEN IF Player(1).ym < 0 THEN Player(1).ym = Player(1).ym + 1
    IF movingy = 0 THEN IF Player(1).ym > 0 THEN Player(1).ym = Player(1).ym - 1
NEXT
IF Player(1).xm < -70 THEN Player(1).xm = Player(1).xm + 5
IF Player(1).xm > 70 THEN Player(1).xm = Player(1).xm - 5
IF Player(1).ym < -70 THEN Player(1).ym = Player(1).ym + 5
IF Player(1).ym > 70 THEN Player(1).ym = Player(1).ym - 5


Player(1).y = Player(1).y - Player(1).ym / 10: Player(1).x = Player(1).x - Player(1).xm / 10
IF Player(1).y > Map.MaxHeight * Map.TileSize THEN Player(1).y = Map.MaxHeight * Map.TileSize
IF Player(1).y < Map.TileSize THEN Player(1).y = Map.TileSize
IF Player(1).x > Map.MaxWidth * Map.TileSize THEN Player(1).x = Map.MaxWidth * Map.TileSize
IF Player(1).x < Map.TileSize THEN Player(1).x = Map.TileSize

MakeHitBoxPlayer Player(1)
IF Noclip = 0 THEN IF CollisionWithWallsPlayer(Player(1)) THEN donebetween = 1
RETURN



RenderSprites:
rendcamerax1 = FIX(FIX(CameraX * Map.TileSize) / Map.TileSize)
rendcamerax2 = FIX((FIX(CameraX * Map.TileSize) + _RESIZEWIDTH) / Map.TileSize) + 1
rendcameray1 = FIX(FIX(CameraY * Map.TileSize) / Map.TileSize)
rendcameray2 = FIX((FIX(CameraY * Map.TileSize) + _RESIZEHEIGHT) / Map.TileSize) + 1
IF rendcamerax1 < 0 THEN rendcamerax1 = 0
IF rendcameray1 < 0 THEN rendcameray1 = 0
IF rendcamerax2 > Map.MaxWidth THEN rendcamerax2 = Map.MaxWidth
IF rendcameray2 > Map.MaxHeight THEN rendcameray2 = Map.MaxHeight

FOR x = rendcamerax1 TO rendcamerax2 'Map.MaxWidth
    FOR y = rendcameray1 TO rendcameray2 'Map.MaxHeight
        z = 1
        IF RenderLayer1 = 1 THEN IF Tile(x, y, z).ID <> 0 THEN _PUTIMAGE (WTS(x, CameraX), WTS(y, CameraY))-(WTS(x, CameraX) + (Map.TileSize * Zoom), WTS(y, CameraY) + (Map.TileSize * Zoom)), Tileset, 0, (Tile(x, y, z).rend_spritex * Map.TextureSize, Tile(x, y, z).rend_spritey * Map.TextureSize)-(Tile(x, y, z).rend_spritex * Map.TextureSize + (Map.TextureSize - 1), Tile(x, y, z).rend_spritey * Map.TextureSize + (Map.TextureSize - 1))
        z = 2
        IF RenderLayer2 = 1 THEN IF Tile(x, y, z).ID <> 0 THEN _PUTIMAGE (WTS(x, CameraX), WTS(y, CameraY))-(WTS(x, CameraX) + (Map.TileSize * Zoom), WTS(y, CameraY) + (Map.TileSize * Zoom)), Tileset, 0, (Tile(x, y, z).rend_spritex * Map.TextureSize, Tile(x, y, z).rend_spritey * Map.TextureSize)-(Tile(x, y, z).rend_spritex * Map.TextureSize + (Map.TextureSize - 1), Tile(x, y, z).rend_spritey * Map.TextureSize + (Map.TextureSize - 1))
    NEXT
NEXT
RETURN

RenderLayer3:
FOR x = rendcamerax1 TO rendcamerax2 'Map.MaxWidth
    FOR y = rendcameray1 TO rendcameray2 'Map.MaxHeight
        z = 3
        IF RenderLayer3 = 1 THEN IF Tile(x, y, z).ID <> 0 THEN _PUTIMAGE (WTS(x - 1, CameraX), WTS(y, CameraY))-(WTS(x - 1, CameraX) + (Map.TileSize * Zoom), WTS(y, CameraY) + (Map.TileSize * Zoom)), Tileset, 0, (Tile(x, y, z).rend_spritex * Map.TextureSize, Tile(x, y, z).rend_spritey * Map.TextureSize)-(Tile(x, y, z).rend_spritex * Map.TextureSize + (Map.TextureSize - 1), Tile(x, y, z).rend_spritey * Map.TextureSize + (Map.TextureSize - 1))
    NEXT
NEXT
RETURN

RenderPlayer:
FOR P = 1 TO PlayerLimit
    IF debug = 1 THEN LINE (ETSX(Player(P).x1), ETSY(Player(P).y1))-(ETSX(Player(P).x2), ETSY(Player(P).y2)), _RGB32(P * 120, 255, 255), BF
    RotoZoom ETSX(Player(P).x), ETSY(Player(P).y), PlayerSprite(PlayerSkin2), 0.25, Player(P).Rotation
    FOR i = 1 TO 2
        _PUTIMAGE (PlayerMember(i).x - 8 - CameraX * Map.TileSize, PlayerMember(i).y - 8 - CameraY * Map.TileSize)-(PlayerMember(i).x + 8 - CameraX * Map.TileSize, PlayerMember(i).y + 8 - CameraY * Map.TileSize), PlayerHand(PlayerSkin2)
    NEXT
NEXT
RETURN










MenuSystem:
DO
    Mouse.x = _MOUSEX
    Mouse.y = _MOUSEY
    Mouse.click = _MOUSEBUTTON(1)
LOOP WHILE _MOUSEINPUT
MenuClicking = 0
IF MenuClicking = 0 AND Mouse.click = 0 AND MenuClickingPre = 1 THEN MenuClicking = 1
MenuClickingPre = -Mouse.click
IF LastToUse < 0 THEN LastToUse = 0
IF Mouse.click = 0 THEN LastToUse = LastToUse * -1
IF delay > 0 THEN delay = delay - 1
Mouse.x1 = Mouse.x - 1: Mouse.x2 = Mouse.x + 1: Mouse.y1 = Mouse.y - 1: Mouse.y2 = Mouse.y + 1
DontRepeatFor = 0
IF ResizeDelay2 > 0 THEN ResizeDelay2 = ResizeDelay2 - 1
IF _RESIZE THEN GOSUB ScreenAdjustForSize
'MenuAnimCode:

FOR i = 1 TO 3
    IF RayM(i).owner = 1 THEN

        dx = RayM(i).x - RayM(i).damage: dy = RayM(i).y - RayM(i).knockback
        rotation = ATan2(dy, dx) ' Angle in radians
        RayM(i).angle = (rotation * 180 / PI) + 90
        IF RayM(i).angle > 180 THEN RayM(i).angle = RayM(i).angle - 179.9
        xvector = SIN(RayM(i).angle * PIDIV180): yvector = -COS(RayM(i).angle * PIDIV180)

        RayM(i).x = RayM(i).x + xvector * (1 + (Distance(RayM(i).x, RayM(i).y, RayM(i).damage, RayM(i).knockback) / 5))
        RayM(i).y = RayM(i).y + yvector * (1 + (Distance(RayM(i).x, RayM(i).y, RayM(i).damage, RayM(i).knockback) / 5))
    END IF
NEXT

FOR i = lasti TO 1 STEP -1
    IF DontRepeatFor = 1 OR CantClickAnymoreOnHud = 1 THEN EXIT FOR
    IF LastToUse > 0 THEN DontRepeatFor = 1: i = LastToUse
    IF Menu(i).d_hover > 32 THEN Menu(i).d_hover = Menu(i).d_hover - 2
    IF MenuAnim.extra < 29 AND UICollide(Mouse, Menu(i)) OR LastToUse > 0 THEN

        menx = INT((Menu(i).x1 + Menu(i).x2) / 2)
        meny = INT((Menu(i).y1 + Menu(i).y2) / 2)
        dx = menx - Mouse.x
        dy = meny - Mouse.y
        rotation = ATan2(dy, dx) ' Angle in radians
        TempAngle = (rotation * 180 / PI) + 90
        IF TempAngle > 180 THEN TempAngle = TempAngle - 179.5
        Menu(i).OffsetX = SIN(TempAngle * PIDIV180) * (Distance(menx, meny, Mouse.x, Mouse.y) / 17): Menu(i).OffsetY = -COS(TempAngle * PIDIV180) * (Distance(menx, meny, Mouse.x, Mouse.y) / 17)



        FOR o = 1 TO 5
            IF Menu(i).d_hover < 32 THEN Menu(i).d_hover = Menu(i).d_hover + 1
        NEXT
        DontRepeatFor = 1
        IF Mouse.click = -1 AND delay = 0 THEN
            _KEYCLEAR
            GOSUB MenuButtonStyle
            clicked = i
        END IF
        IF MenuClicking = 1 AND Menu(i).clicktogo <> "" THEN
            RayM(1).x = Menu(i).x1 + Menu(i).OffsetX
            RayM(1).y = Menu(i).y1 + Menu(i).OffsetY
            RayM(1).damage = 0
            RayM(1).knockback = 0
            RayM(1).owner = 1
            RayM(2).x = Menu(i).x2 + Menu(i).OffsetX
            RayM(2).y = Menu(i).y2 + Menu(i).OffsetY
            RayM(2).damage = _WIDTH
            RayM(2).knockback = _HEIGHT
            RayM(2).owner = 1
            RayM(3).x = ((Menu(i).x1 + Menu(i).x2) / 2) + Menu(i).OffsetX
            RayM(3).y = ((Menu(i).y1 + Menu(i).y2) / 2) + Menu(i).OffsetY
            RayM(3).damage = FIX(_WIDTH / 2)
            RayM(3).knockback = FIX(_HEIGHT / 2)
            RayM(3).owner = 1
            MenuClickedID = i
            MenuTransitionImage = _COPYIMAGE(MenusImages(MenuClickedID))
            MenuAnim.red = INT(Menu(i).red / 1.03)
            MenuAnim.green = INT(Menu(i).green / 1.03)
            MenuAnim.blue = INT(Menu(i).blue / 1.03)
            MenuAnim.extra = 255
            CanChangeMenu = 0

            IF Menu(i).clicktogo <> "" THEN
                ToLoad$ = Menu(i).clicktogo
            END IF
        END IF
    END IF
NEXT
FOR i = 1 TO lasti

    IF Menu(i).style = 3 AND Menu(i).d_clicked = 2 THEN GOSUB InputStyleKeyGet
NEXT
GOSUB MenuWhatClicked
IF CanChangeMenu = 0 THEN
    IF Loaded$ <> ToLoad$ THEN GOSUB load
    CanChangeMenu = 0


END IF


'Drawing Routine:
FOR i = 1 TO lasti
    Menu(i).x1 = Menu(i).x1 + Menu(i).OffsetX
    Menu(i).x2 = Menu(i).x2 + Menu(i).OffsetX
    Menu(i).y1 = Menu(i).y1 + Menu(i).OffsetY
    Menu(i).y2 = Menu(i).y2 + Menu(i).OffsetY

    FOR o = 1 TO 3
        IF Menu(i).d_hover < 0 THEN Menu(i).d_hover = Menu(i).d_hover + 1
    NEXT
    IF Menu(i).d_hover >= 4 THEN Menu(i).d_hover = Menu(i).d_hover - 4
    IF Menu(i).text <> "No Draw" THEN LINE ((Menu(i).x1 - Menu(i).d_hover / 4) - 16, (Menu(i).y1 - Menu(i).d_hover / 4) + 16)-((Menu(i).x2 + Menu(i).d_hover / 4) - 16, (Menu(i).y2 + Menu(i).d_hover / 4) + 16), _RGBA32(0, 0, 0, 100), BF
NEXT
FOR i = 1 TO lasti


    IF Menu(i).text <> "No Draw" THEN LINE (Menu(i).x1 - Menu(i).d_hover / 4, Menu(i).y1 - Menu(i).d_hover / 4)-(Menu(i).x2 + Menu(i).d_hover / 4, Menu(i).y2 + Menu(i).d_hover / 4), _RGB32(Menu(i).red, Menu(i).green, Menu(i).blue), BF
    IF Menu(i).style = 1 THEN IF Menu(i).text <> "W Bh" THEN IF Menu(i).text <> "No Draw" OR Menu(i).textsize < 2 THEN _PUTIMAGE ((Menu(i).x1 / 2 + Menu(i).x2 / 2) - _WIDTH(MenusImages(i)) / 2 - Menu(i).d_hover / 4, (Menu(i).y1 / 2 + Menu(i).y2 / 2) - _HEIGHT(MenusImages(i)) / 2 - Menu(i).d_hover / 4)-((Menu(i).x1 / 2 + Menu(i).x2 / 2) + _WIDTH(MenusImages(i)) / 2 + Menu(i).d_hover / 4, (Menu(i).y1 / 2 + Menu(i).y2 / 2) + _HEIGHT(MenusImages(i)) / 2 + Menu(i).d_hover / 4), MenusImages(i)
    IF Menu(i).style = 2 THEN
        _PUTIMAGE ((Menu(i).x1 / 2 + Menu(i).x2 / 2) - _WIDTH(MenusImages(i)) / 2 - Menu(i).d_hover / 4, (Menu(i).y1 / 2 + Menu(i).y2 / 2) - _HEIGHT(MenusImages(i)) / 2 - Menu(i).d_hover / 4)-((Menu(i).x1 / 2 + Menu(i).x2 / 2) + _WIDTH(MenusImages(i)) / 2 + Menu(i).d_hover / 4, (Menu(i).y1 / 2 + Menu(i).y2 / 2) + _HEIGHT(MenusImages(i)) / 2 + Menu(i).d_hover / 4), MenusImages(i)
        LINE (Menu(i).x1 + CalculatePercentage((Menu(i).x2 - Menu(i).x1), 5) - Menu(i).d_hover / 8, Menu(i).y1 + CalculatePercentage((Menu(i).y2 - Menu(i).y1), 48) - Menu(i).d_hover / 8)-(Menu(i).x2 - CalculatePercentage((Menu(i).x2 - Menu(i).x1), 5) + Menu(i).d_hover / 8, Menu(i).y2 - CalculatePercentage((Menu(i).y2 - Menu(i).y1), 48) + Menu(i).d_hover / 8), _RGBA32(0, 0, 0, 128), BF
        LINE (Menu(i).x1 + Menu(i).visual - CalculatePercentage((Menu(i).x2 - Menu(i).x1), 2), Menu(i).y1 + CalculatePercentage((Menu(i).y2 - Menu(i).y1), 5))-(Menu(i).x1 + Menu(i).visual + CalculatePercentage((Menu(i).x2 - Menu(i).x1), 2), Menu(i).y2 - CalculatePercentage((Menu(i).y2 - Menu(i).y1), 5)), _RGBA32(0, 255, 0, 128), BF
    END IF

    IF Menu(i).style = 3 THEN IF Menu(i).text <> "W Bh" OR Menu(i).text <> "No Draw" OR Menu(i).textsize < 2 THEN _PUTIMAGE ((Menu(i).x1 / 2 + Menu(i).x2 / 2) - _WIDTH(MenusImages(i)) / 2 - Menu(i).d_hover / 4, (Menu(i).y1 / 2 + Menu(i).y2 / 2) - _HEIGHT(MenusImages(i)) / 2 - Menu(i).d_hover / 4)-((Menu(i).x1 / 2 + Menu(i).x2 / 2) + _WIDTH(MenusImages(i)) / 2 + Menu(i).d_hover / 4, (Menu(i).y1 / 2 + Menu(i).y2 / 2) + _HEIGHT(MenusImages(i)) / 2 + Menu(i).d_hover / 4), MenusImages(i)


    Menu(i).x1 = Menu(i).x1 - Menu(i).OffsetX
    Menu(i).x2 = Menu(i).x2 - Menu(i).OffsetX
    Menu(i).y1 = Menu(i).y1 - Menu(i).OffsetY
    Menu(i).y2 = Menu(i).y2 - Menu(i).OffsetY
    Menu(i).OffsetX = Menu(i).OffsetX / 1.06
    Menu(i).OffsetY = Menu(i).OffsetY / 1.06
NEXT
'Loop While CanLeave = 0
FOR i = 1 TO 32
    IF Menu(i).extra3 <> 0 AND Menu(i).d_hover <> 0 THEN
    END IF
NEXT

IF MenuAnim.extra > 0 THEN

    MenuAnim.x1 = RayM(1).x
    MenuAnim.y1 = RayM(1).y
    MenuAnim.x2 = RayM(2).x
    MenuAnim.y2 = RayM(2).y


    IF FIX(MenuAnim.x1) <= 0 THEN IF FIX(MenuAnim.y1) <= 0 THEN RayM(1).owner = 0
    IF INT(MenuAnim.x2) >= _WIDTH THEN IF INT(MenuAnim.y2) >= _HEIGHT THEN RayM(2).owner = 0


    LINE (MenuAnim.x1, MenuAnim.y1)-(MenuAnim.x2, MenuAnim.y2), _RGBA32(MenuAnim.red, MenuAnim.green, MenuAnim.blue, MenuAnim.extra), BF
    '_SetAlpha Fix(MenuAnim.extra), MenusImages(MenuClickedID)
    'If Menu(MenuClickedID).text <> "W Bh" Or Menu(MenuClickedID).textsize < 2 Then _PutImage (RayM(3).x - _Width(MenusImages(MenuClickedID)) / 2, RayM(3).y - _Height(MenusImages(MenuClickedID)) / 2)-(RayM(3).x + _Width(MenusImages(MenuClickedID)) / 2, RayM(3).y + _Height(MenusImages(MenuClickedID)) / 2), MenusImages(MenuClickedID)
    _SETALPHA FIX(MenuAnim.extra), _RGBA32(1, 1, 1, 1) TO _RGB32(255, 255, 255, 255), MenuTransitionImage

    IF Menu(MenuClickedID).text <> "W Bh" OR Menu(MenuClickedID).textsize < 2 THEN _PUTIMAGE (RayM(3).x - _WIDTH(MenuTransitionImage) / 2, RayM(3).y - _HEIGHT(MenuTransitionImage) / 2)-(RayM(3).x + _WIDTH(MenuTransitionImage) / 2, RayM(3).y + _HEIGHT(MenuTransitionImage) / 2), MenuTransitionImage

    IF RayM(1).x <= 1 THEN
        IF RayM(1).y <= 1 THEN
            IF RayM(2).x >= _WIDTH - 1 THEN
                IF RayM(2).y >= _HEIGHT - 1 THEN
                    RayM(1).x = RayM(1).damage: RayM(2).x = RayM(2).damage
                    RayM(1).y = RayM(1).knockback: RayM(2).y = RayM(2).knockback
                    RayM(1).owner = 0: RayM(2).owner = 0: RayM(3).owner = 0
                    MenuAnim.extra = (MenuAnim.extra / 1.05) - 0.5
                    CanChangeMenu = 1
                END IF
            END IF
        END IF
    END IF

END IF
'_SetAlpha 255, MenusImages(MenuClickedID)
_SETALPHA 255, _RGBA32(1, 1, 1, 1) TO _RGB32(255, 255, 255, 255), MenuTransitionImage
RETURN

ScreenAdjustForSize:
IF ResizeDelay2 = 0 THEN
    CLS
    SCREEN SecondScreen
    _FREEIMAGE MainScreen
    sizexx = _RESIZEWIDTH
    sizeyy = _RESIZEHEIGHT
    IF sizexx < 128 THEN sizexx = 128
    IF sizeyy < 128 THEN sizeyy = 128
    MainScreen = _NEWIMAGE(sizexx, sizeyy, 32)
    SCREEN MainScreen
    FOR i = 1 TO lasti
        GOSUB redosize
        GOSUB redotexts
    NEXT
    ResizeDelay2 = 5
END IF
RETURN

MenuButtonStyle:
IF Menu(i).style = 1 THEN
    LastToUse = i
    Menu(i).d_hover = 50
    Menu(i).d_clicked = 1
END IF
IF Menu(i).style = 2 THEN
    LastToUse = i
    Menu(i).d_hover = 50
    Menu(i).extra3 = ((Mouse.x - Menu(i).x1) * 100) / (Menu(i).x2 - Menu(i).x1)
    IF Mouse.x < Menu(i).x1 THEN Menu(i).extra3 = 0
    IF Mouse.x > Menu(i).x2 THEN Menu(i).extra3 = 100
    Menu(i).visual = CalculatePercentage((Menu(i).x2 - Menu(i).x1), Menu(i).extra3)
    Menu(i).extra3 = Menu(i).extra3 * (Menu(i).extra2 / 100)
    Menu(i).text = RTRIM$(LTRIM$(STR$(Menu(i).extra3)))
    GOSUB redotexts
END IF
IF Menu(i).style = 3 THEN
    Menu(i).d_clicked = 2
    CantClickAnymoreOnHud = 1
END IF
RETURN

InputStyleKeyGet:
key$ = INKEY$
keyhit = _KEYHIT
IF keyhit = 8 THEN
    key$ = ""
    IF LEN(Menu(i).text) > 0 THEN Menu(i).text = MID$(Menu(i).text, 0, LEN(Menu(i).text))
    _DEST MainScreen
    GOSUB redotexts
END IF
IF keyhit = 13 THEN
    key$ = ""
    CantClickAnymoreOnHud = 0: Menu(i).d_clicked = 0: key$ = ""
    Menu(i).text = LTRIM$(RTRIM$(Menu(i).text))
END IF
IF key$ <> "" AND LEN(Menu(i).text) < Menu(i).extra2 THEN
    Menu(i).text = Menu(i).text + key$
    GOSUB redotexts
END IF
IF key$ <> "" AND LEN(Menu(i).text) >= Menu(i).extra2 THEN
    _NOTIFYPOPUP "Begs World", ("Text Limit for this box is " + LTRIM$(RTRIM$(STR$(Menu(i).extra2)))) + ".", "info"
END IF
_DEST MainScreen
RETURN

MenuWhatClicked:
webpage$ = "https://www.qb64phoenix.com/"
IF Loaded$ = "menu" THEN GOSUB Menu
IF Loaded$ = "choosedificulty" THEN GOSUB Difficulty

FOR i = 1 TO lasti
    Menu(i).d_clicked = 0
NEXT
RETURN
Menu:

_PUTIMAGE (0, 0)-(_WIDTH, _HEIGHT), Background1
menx = ((Menu(1).x2 + Menu(1).x1) / 2) + Menu(1).OffsetX
meny = ((Menu(1).y2 + Menu(1).y1) / 2) + Menu(1).OffsetY
_PUTIMAGE (menx - _WIDTH(VantiroTitulo) / 2, meny - _HEIGHT(VantiroTitulo) / 2)-(menx + _WIDTH(VantiroTitulo) / 2, meny + _HEIGHT(VantiroTitulo) / 2), VantiroTitulo
menx = ((Menu(4).x2 + Menu(4).x1) / 2) + Menu(4).OffsetX
meny = ((Menu(4).y2 + Menu(4).y1) / 2) + Menu(4).OffsetY
SkinRot = SkinRot / 1.005
SkinRot = SkinRot + RotateSkinSpeed
RotateSkinSpeed = RotateSkinSpeed / 1.05

RotoZoom menx, meny, PlayerSprite(PlayerSkin), 0.7, SkinRot
IF Menu(5).d_clicked = 1 THEN
    BEEP
    SYSTEM
END IF
IF Menu(3).d_clicked = 1 THEN
    quit = 1
END IF
IF Menu(4).d_clicked = 1 AND delay = 0 THEN
    delay = 10
    RotateSkinSpeed = INT(RND * 100) - 50
    _SNDPLAY PlayerDamage
END IF
IF Menu(6).d_clicked = 1 AND delay = 0 THEN
    delay = 20
    PlayerSkin = PlayerSkin - 1
    IF PlayerSkin < 1 THEN PlayerSkin = 1
    Menu(7).text = ("(" + STR$(PlayerSkin) + "/4)")
    i = 7
    GOSUB redotexts
END IF

IF Menu(8).d_clicked = 1 AND delay = 0 THEN
    delay = 20
    PlayerSkin = PlayerSkin + 1
    IF PlayerSkin > 4 THEN PlayerSkin = 4
    Menu(7).text = ("(" + STR$(PlayerSkin) + "/4)")
    i = 7
    GOSUB redotexts
END IF


RETURN

Difficulty:
IF Menu(2).d_clicked = 1 THEN
    GameDificulty = 0.5
    quit = 6
END IF

IF Menu(3).d_clicked = 1 THEN
    GameDificulty = 1
    quit = 6
END IF

IF Menu(4).d_clicked = 1 THEN
    GameDificulty = 2
    quit = 6
END IF


RETURN




RedoSlider:
Menu(i).visual = (Menu(i).extra3 * 100) / (Menu(i).x2 - Menu(i).x1)
Menu(i).text = RTRIM$(LTRIM$(STR$(Menu(i).extra3)))
GOSUB redotexts
RETURN

WarningWebsite:
IF Menu(5).d_clicked = 1 THEN ToLoad$ = ToLoad2$: GOSUB load
IF Menu(6).d_clicked = 1 THEN SHELL _HIDE _DONTWAIT webpage$: ToLoad$ = ToLoad2$: GOSUB load
RETURN
PlayerSettings:
IF Menu(17).d_clicked THEN
    username$ = Menu(4).text
    OPEN "assets/begs world/settings/PlayerSettings.bhconfig" FOR OUTPUT AS #1
    PRINT #1, Menu(4).text
    CLOSE #1
END IF
RETURN


load:
IF ToLoad$ = "Back$" THEN ToLoad$ = ToLoad2$
_DEST MainScreen
IF NOT _FILEEXISTS("assets/pc/menu/" + RTRIM$(LTRIM$(ToLoad$)) + ".bhmenu") THEN
    BEEP
    FileMissing$ = ToLoad$
    FileMissingtype$ = "Menu file"
    ToLoad$ = "warningfilemissing"
END IF
OPEN ("assets/pc/menu/" + RTRIM$(LTRIM$(ToLoad$)) + ".bhmenu") FOR INPUT AS #1
INPUT #1, lasti
FOR i = 1 TO lasti
    INPUT #1, i, Menu(i).x1d, Menu(i).y1d, Menu(i).x2d, Menu(i).y2d, Menu(i).Colors, Menu(i).text, Menu(i).textsize, Menu(i).style, Menu(i).clicktogo, Menu(i).extra, Menu(i).extra2
    GOSUB redosize
    Menu(i).textsize = Menu(i).y2 - Menu(i).y1
    Menu(i).red = _RED32(Menu(i).Colors)
    Menu(i).green = _GREEN32(Menu(i).Colors)
    Menu(i).blue = _BLUE32(Menu(i).Colors)
    Menu(i).OffsetX = 0
    Menu(i).OffsetY = 0
    GOSUB LoadingExtraSignatures
    IF NOT Menu(i).text = "W Bh" THEN GOSUB redotexts
NEXT
CLOSE #1
delay = 60
ToLoad2$ = Loaded$
Loaded$ = ToLoad$
Mouse.click = 0
FOR i = 1 TO MenuMax
    Menu(i).d_clicked = 0
    Menu(i).d_hover = 0
NEXT
RETURN
LoadingExtraSignatures:
IF Menu(i).text = "webpage$" THEN Menu(i).text = webpage$
IF Menu(i).text = "$username$" THEN Menu(i).text = username$
IF Menu(i).text = "$WhatMissingType$" THEN Menu(i).text = (FileMissingtype$ + " Not found!")
IF Menu(i).text = "$WhatMissing$" THEN Menu(i).text = (FileMissing$ + " Is missing!")

RETURN

redotexts:
IF Menu(i).text = "" THEN Menu(i).text = " "
IF ImgToMenu <> 0 THEN _FREEIMAGE ImgToMenu
'If MenusImages(i) <> 0 Then _FreeImage MenusImages(i)
IF Menu(i).textsize = -1 THEN Menu(i).textsize = Menu(i).y2 - Menu(i).y1
_FONT BegsFontSizes(Menu(i).textsize)
thx = _PRINTWIDTH(Menu(i).text)
thy = _FONTHEIGHT(BegsFontSizes(Menu(i).textsize))
ImgToMenu = _NEWIMAGE(thx * 3, thy * 3, 32)
_DEST ImgToMenu
_CLEARCOLOR _RGB32(0, 0, 0): _PRINTMODE _KEEPBACKGROUND: _FONT BegsFontSizes(Menu(i).textsize - 1): PRINT Menu(i).text + " "
IF MenusImages(i) <> 0 THEN _FREEIMAGE MenusImages(i)
MenusImages(i) = _NEWIMAGE(thx, thy, 32)
_DEST MainScreen
_PUTIMAGE (0, 0), ImgToMenu, MenusImages(i)
_FONT BegsFontSizes(20)
RETURN

redosize:
Menu(i).x1 = Menu(i).x1d * _WIDTH / 2
Menu(i).x2 = Menu(i).x2d * _WIDTH / 2
Menu(i).y1 = Menu(i).y1d * _HEIGHT / 2
Menu(i).y2 = Menu(i).y2d * _HEIGHT / 2
IF Menu(i).x1d < 0 THEN Menu(i).x1 = Menu(i).x1 * -1
IF Menu(i).x2d < 0 THEN Menu(i).x2 = Menu(i).x2 * -1
IF Menu(i).y1d < 0 THEN Menu(i).y1 = Menu(i).y1 * -1
IF Menu(i).y2d < 0 THEN Menu(i).y2 = Menu(i).y2 * -1
RETURN

SUB Explosion (x AS DOUBLE, y AS DOUBLE, strength AS DOUBLE, Size AS DOUBLE)
    FOR o = 1 TO 5
        Part(LastPart).x = x
        Part(LastPart).y = y
        Part(LastPart).z = 4
        Part(LastPart).xm = INT(RND * 512) - 256
        Part(LastPart).ym = INT(RND * 512) - 256
        Part(LastPart).zm = 8 + INT(RND * 10)
        Part(LastPart).froozen = -90
        Part(LastPart).visible = 30
        Part(LastPart).partid = "Smoke"
        Part(LastPart).playwhatsound = "None"
        Part(LastPart).rotation = INT(RND * 360) - 180
        Part(LastPart).rotationspeed = INT(RND * 128) - 64
        LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
    NEXT

    Part(LastPart).x = x
    Part(LastPart).y = y
    Part(LastPart).z = 1
    Part(LastPart).xm = INT(RND * 8) - 4
    Part(LastPart).ym = INT(RND * 8) - 4
    Part(LastPart).zm = 20 + INT(Size / 40)
    Part(LastPart).froozen = -64
    Part(LastPart).visible = 5
    Part(LastPart).partid = "Explosion"
    Part(LastPart).playwhatsound = "None"
    Part(LastPart).rotation = INT(RND * 360) - 180
    Part(LastPart).rotationspeed = INT(RND * 128) - 64
    LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0

    Part(LastPart).x = x
    Part(LastPart).y = y
    Part(LastPart).z = 25
    Part(LastPart).xm = INT(RND * 8) - 4
    Part(LastPart).ym = INT(RND * 8) - 4
    Part(LastPart).zm = 10
    Part(LastPart).froozen = -200
    Part(LastPart).visible = 90
    Part(LastPart).partid = "Smoke"
    Part(LastPart).playwhatsound = "None"
    Part(LastPart).rotation = INT(RND * 360) - 180
    Part(LastPart).rotationspeed = INT(RND * 100) - 50
    LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0


    FOR i = 1 TO ZombieMax
        IF Zombie(i).health > 0 THEN
            dist = Distance(x, y, Zombie(i).x, Zombie(i).y)
            IF dist < Size THEN
                Zombie(i).DamageTaken = INT(strength / (dist / 50))
            END IF
        END IF
    NEXT


    dist = Distance(x, y, Player(1).x, Player(1).y)
    IF dist < Size THEN
        'Player(1).DamageToTake = Int(strength / (dist / 30))
        PlayerTakeDamage Player(1), x, y, INT(strength / (dist / 30)), INT(dist / 10)
    END IF



END SUB


FUNCTION raycastingsimple (x AS DOUBLE, y AS DOUBLE, angle AS DOUBLE, limit AS INTEGER)

    DIM xvector AS DOUBLE: DIM yvector AS DOUBLE
    xvector = SIN(angle * PIDIV180): yvector = -COS(angle * PIDIV180)
    Ray.x = x: Ray.y = y
    DO
        limit = limit - 1
        Ray.x = Ray.x + xvector * 6: Ray.y = Ray.y + yvector * 6
        IF limit = 0 THEN EXIT DO
        tx = FIX((Ray.x) / Map.TileSize): ty = FIX((Ray.y) / Map.TileSize): IF Tile(tx, ty, 2).transparent = 0 THEN EXIT DO
    LOOP WHILE quit < 4
    raycastingsimple = 1
END FUNCTION



FUNCTION raycasting (x AS DOUBLE, y AS DOUBLE, angle AS DOUBLE, damage AS DOUBLE, owner AS DOUBLE)
    DIM xvector AS DOUBLE: DIM yvector AS DOUBLE
    xvector = SIN(angle * PIDIV180): yvector = -COS(angle * PIDIV180)
    Ray.x = x: Ray.y = y: Ray.owner = owner
    quit = 0
    DO
        Steps = Steps + 1
        steps2 = steps2 + 1
        Ray.x = Ray.x + xvector * 2: Ray.y = Ray.y + yvector * 2
        IF steps2 = 5 THEN
            tx = FIX((Ray.x) / Map.TileSize): ty = FIX((Ray.y) / Map.TileSize): IF Tile(tx, ty, 2).solid = 1 THEN
                quit = quit + 2
                IF Tile(tx, ty, 2).fragile = 1 THEN
                    FOR o = 1 TO 5
                        Part(LastPart).x = Ray.x
                        Part(LastPart).y = Ray.y
                        Part(LastPart).z = 2
                        Part(LastPart).xm = INT(RND * 128) - 64
                        Part(LastPart).ym = INT(RND * 128) - 64
                        Part(LastPart).zm = 2 + INT(RND * 7)
                        Part(LastPart).froozen = -20
                        Part(LastPart).visible = 900
                        Part(LastPart).partid = "GlassShard"
                        Part(LastPart).playwhatsound = "Glass"
                        Part(LastPart).rotation = INT(RND * 360) - 180
                        Part(LastPart).rotationspeed = INT(RND * 60) - 30
                        LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
                    NEXT
                    IF Tile(tx, ty, 2).ID = 56 THEN _SNDPLAYCOPY GlassShadder(INT(1 + RND * 3)), 0.4
                    Tile(tx, ty, 2).ID = 0
                    Tile(tx, ty, 2).solid = 0
                    'Tile(tx, ty, 2).rend_spritex = 0
                    'Tile(tx, ty, 2).rend_spritey = 0
                END IF
                IF Tile(tx, ty, 2).fragile = 0 THEN
                    Part(LastPart).x = Ray.x
                    Part(LastPart).y = Ray.y
                    Part(LastPart).z = 2
                    Part(LastPart).xm = 0
                    Part(LastPart).ym = 0
                    Part(LastPart).zm = 2 + INT(RND * 3)
                    Part(LastPart).froozen = -20
                    Part(LastPart).visible = 800
                    Part(LastPart).partid = "WallShot"
                    Part(LastPart).playwhatsound = "Wall"
                    Part(LastPart).rotation = INT(RND * 360) - 180
                    Part(LastPart).rotationspeed = INT(RND * 60) - 30
                    LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
                    EXIT DO
                END IF
            END IF
            steps2 = 0
            FOR i = 1 TO ZombieMax
                IF Zombie(i).active = 1 THEN
                    IF RayCollideEntity(Ray, Zombie(i)) THEN
                        IF INT(RND * 20) = 11 THEN _SNDPLAYCOPY ZombieShot(INT(RND * 16) + 1), 0.2
                        IF Zombie(i).DamageTaken = 0 THEN EntityTakeDamage Zombie(i), Ray.x, Ray.y, damage
                        changeofblood = INT(RND * 30)
                        IF changeofblood < damage + 5 THEN SpawnBloodParticle Ray.x, Ray.y, angle, Steps, "green"
                        IF GunDisplay(1).wtype = 2 THEN quit = quit + 1: IF damage > 0 THEN damage = damage - 1
                        IF GunDisplay(1).wtype <> 2 THEN quit = 99999
                    END IF
                END IF

            NEXT

        END IF
    LOOP WHILE quit < 7

    FOR i = 1 TO ZombieMax
        IF Zombie(i).active = 1 THEN
            Zombie(i).health = Zombie(i).health - Zombie(i).DamageTaken: Zombie(i).DamageTaken = 0
        END IF
    NEXT

END FUNCTION



SUB SpawnBloodParticle (x AS DOUBLE, y AS DOUBLE, angle AS DOUBLE, Steps AS LONG, BloodType AS STRING)
    LastPart = LastPart + 1: IF LastPart > ParticlesMax THEN LastPart = 0
    Part(LastPart).x = x
    Part(LastPart).y = y
    Part(LastPart).z = 2 + INT(RND * 12)
    rand = 20 + INT(RND * 100)
    Part(LastPart).xm = INT(SIN((angle + INT(RND * 40) - 20) * PIDIV180) * (rand))
    Part(LastPart).ym = INT(-COS((angle + INT(RND * 40) - 20) * PIDIV180) * (rand))
    Part(LastPart).zm = (2 + INT(RND * 14))
    Part(LastPart).froozen = -70
    Part(LastPart).visible = 2000

    Part(LastPart).BloodColor = BloodType
    Part(LastPart).partid = "BloodSplat"
    IF BloodType = "green" THEN Part(LastPart).froozen = -20
    Part(LastPart).playwhatsound = "Blood"
    IF Part(LastPart).BloodColor = "GibSkull" THEN Part(LastPart).partid = BloodType: Part(LastPart).playwhatsound = "Bone"
    IF Part(LastPart).BloodColor = "GibBone" THEN Part(LastPart).partid = BloodType: Part(LastPart).playwhatsound = "Bone"
    IF Part(LastPart).BloodColor = "PistolAmmo" THEN Part(LastPart).partid = BloodType: Part(LastPart).playwhatsound = "Blood"
    IF Part(LastPart).BloodColor = "ShotgunAmmo" THEN Part(LastPart).partid = BloodType: Part(LastPart).playwhatsound = "Blood"
    IF Part(LastPart).BloodColor = "GasAmmo" THEN Part(LastPart).partid = BloodType: Part(LastPart).playwhatsound = "Blood"
    IF Part(LastPart).BloodColor = "GrenadeAmmo" THEN Part(LastPart).partid = BloodType: Part(LastPart).playwhatsound = "Blood"

    Part(LastPart).rotation = INT(RND * 360) - 180
    Part(LastPart).rotationspeed = INT(RND * 60) - 30

END SUB


FUNCTION Distance (x1, y1, x2, y2)
    Distance = 0
    Dist = SQR(((x1 - x2) ^ 2) + ((y1 - y2) ^ 2))
    Distance = Dist
END FUNCTION
SUB PlayerTakeDamage (Player AS Player, X, Y, Damage, Knockback)
    dx = Player.x - X: dy = Player.y - Y
    Rotation = ATan2(dy, dx) ' Angle in radians
    Rotation = (Rotation * 180 / PI) + 90
    IF Rotation > 180 THEN Rotation = Rotation - 180
    xvector = SIN(Rotation * PIDIV180)
    yvector = -COS(Rotation * PIDIV180)
    Player.Health = Player.Health - Damage
    Player.xm = Player.xm / 5
    Player.ym = Player.ym / 5
    Player.ym = INT(Player.ym + yvector * (Damage * Knockback))
    Player.xm = INT(Player.xm + xvector * (Damage * Knockback))
    SpawnBloodParticle Player.x - Player.size + INT(RND * Player.size * 2), Player.y - Player.size + INT(RND * Player.size * 2), Rotation + 180, 2, "red"
    IF Player.Health > 0 THEN _SNDPLAY PlayerDamage
END SUB
SUB EntityTakeDamage (Player AS Entity, X, Y, Damage)
    dx = Player.x - X: dy = Player.y - Y
    Rotation = ATan2(dy, dx) ' Angle in radians
    Rotation = (Rotation * 180 / PI) + 90
    IF Rotation > 180 THEN Rotation = Rotation - 180
    xvector = SIN(Rotation * PIDIV180)
    yvector = -COS(Rotation * PIDIV180)
    Player.ym = INT(Player.ym - ((yvector * (Damage * 35) / Player.weight)))
    Player.xm = INT(Player.xm - ((xvector * (Damage * 35) / Player.weight)))
    IF (Player.health * 10) < Damage THEN gib = 1
    Player.DamageTaken = ABS(Damage)
    IF gib = 0 AND Player.health - Damage < 0 THEN Player.health = 0
END SUB



SUB MakeHitBoxPlayer (Player AS Player)
    Player.x1 = Player.x - Player.size: Player.x2 = Player.x + Player.size: Player.y1 = Player.y - Player.size: Player.y2 = Player.y + Player.size
END SUB

FUNCTION CollisionWithWallsPlayer (Player AS Player)
    CollisionWithWallsPlayer = 0
    PY1 = Player.y1 - Player.ym / 10: PY2 = Player.y2 - Player.ym / 10: PX1 = Player.x1 - Player.xm / 10: PX2 = Player.x2 - Player.xm / 10
    tx1 = FIX((PX1 - 1) / Map.TileSize): ty1 = FIX((PY1 + 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm > 0 THEN Player.x = Player.x + Player.xm / 10: Player.xm = -5: Player.TouchX = 3
    tx1 = FIX((PX1 - 1) / Map.TileSize): ty1 = FIX((PY2 - 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm > 0 THEN Player.x = Player.x + Player.xm / 10: Player.xm = -5: Player.TouchX = 3
    tx1 = FIX((PX2 + 1) / Map.TileSize): ty1 = FIX((PY1 + 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm < 0 THEN Player.x = Player.x + Player.xm / 10: Player.xm = 5: Player.TouchX = 3
    tx1 = FIX((PX2 + 1) / Map.TileSize): ty1 = FIX((PY2 - 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm < 0 THEN Player.x = Player.x + Player.xm / 10: Player.xm = 5: Player.TouchX = 3
    tx1 = FIX((PX1 + 10) / Map.TileSize): ty1 = FIX((PY1 - 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym > 0 THEN Player.y = Player.y + Player.ym / 10: Player.ym = -5: Player.TouchY = 3
    tx1 = FIX((PX1 + 10) / Map.TileSize): ty1 = FIX((PY2 + 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym < 0 THEN Player.y = Player.y + Player.ym / 10: Player.ym = 5: Player.TouchY = 3
    tx1 = FIX((PX2 - 10) / Map.TileSize): ty1 = FIX((PY1 - 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym > 0 THEN Player.y = Player.y + Player.ym / 10: Player.ym = -5: Player.TouchY = 3
    tx1 = FIX((PX2 - 10) / Map.TileSize): ty1 = FIX((PY2 + 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym < 0 THEN Player.y = Player.y + Player.ym / 10: Player.ym = 5: Player.TouchY = 3
    CollisionWithWallsPlayer = -1
END FUNCTION

FUNCTION CollisionWithWallsEntity (Player AS Entity)
    CollisionWithWallsEntity = 0
    PY1 = Player.y1 + Player.ym / 100: PY2 = Player.y2 + Player.ym / 100: PX1 = Player.x1 + Player.xm / 100: PX2 = Player.x2 + Player.xm / 100
    tx1 = FIX((PX1 - 1) / Map.TileSize): ty1 = FIX((PY1 + 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm < 0 THEN Player.x = Player.x - Player.xm / 100: Player.xm = 5
    tx1 = FIX((PX1 - 1) / Map.TileSize): ty1 = FIX((PY2 - 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm < 0 THEN Player.x = Player.x - Player.xm / 100: Player.xm = 5
    tx1 = FIX((PX2 + 1) / Map.TileSize): ty1 = FIX((PY1 + 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm > 0 THEN Player.x = Player.x - Player.xm / 100: Player.xm = -5
    tx1 = FIX((PX2 + 1) / Map.TileSize): ty1 = FIX((PY2 - 10) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.xm > 0 THEN Player.x = Player.x - Player.xm / 100: Player.xm = -5
    tx1 = FIX((PX1 + 10) / Map.TileSize): ty1 = FIX((PY1 - 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym < 0 THEN Player.y = Player.y - Player.ym / 100: Player.ym = 5
    tx1 = FIX((PX1 + 10) / Map.TileSize): ty1 = FIX((PY2 + 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym > 0 THEN Player.y = Player.y - Player.ym / 100: Player.ym = -5
    tx1 = FIX((PX2 - 10) / Map.TileSize): ty1 = FIX((PY1 - 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym < 0 THEN Player.y = Player.y - Player.ym / 100: Player.ym = 5
    tx1 = FIX((PX2 - 10) / Map.TileSize): ty1 = FIX((PY2 + 1) / Map.TileSize)
    IF Tile(tx1, ty1, 2).solid = 1 THEN IF Player.ym > 0 THEN Player.y = Player.y - Player.ym / 100: Player.ym = -5
    CollisionWithWallsEntity = -1
END FUNCTION



SUB Angle2Vector (Angle!, xv!, yv!)
    xv! = SIN(Angle! * PIDIV180)
    yv! = -COS(Angle! * PIDIV180)
END SUB

FUNCTION CalculatePercentage (Number AS DOUBLE, Percentage AS DOUBLE)
    DIM Result AS DOUBLE
    'Result = (Percentage / 100) * Number
    Result = (Percentage / Number) * 100
    CalculatePercentage = Result
END FUNCTION
FUNCTION ATan2 (y AS SINGLE, x AS SINGLE)
    DIM AtanResult AS SINGLE
    IF x = 0 THEN
        IF y > 0 THEN
            AtanResult = PI / 2
        ELSEIF y < 0 THEN
            AtanResult = -PI / 2
        ELSE
            AtanResult = 0
        END IF
    ELSE
        AtanResult = ATN(y / x)
        IF x < 0 THEN
            IF y >= 0 THEN AtanResult = AtanResult + PI
        ELSE AtanResult = AtanResult - PI
        END IF
    END IF
    ATan2 = AtanResult
END FUNCTION

FUNCTION ETSX (e)
    s = e - CameraX * Map.TileSize
    ETSX = INT(s)
END FUNCTION
FUNCTION ETSY (e)
    s = e - CameraY * Map.TileSize
    ETSY = INT(s)
END FUNCTION


FUNCTION WTS (w, Camera)
    s = (w - Camera) * Map.TileSize
    WTS = INT(s)
END FUNCTION

FUNCTION STW (s, m, Camera)
    w = (s / m) + Camera
    STW = w
END FUNCTION

SUB RotoZoom (X AS LONG, Y AS LONG, Image AS LONG, Scale AS SINGLE, Rotation AS SINGLE)
    DIM px(3) AS SINGLE: DIM py(3) AS SINGLE
    W& = _WIDTH(Image&): H& = _HEIGHT(Image&)
    px(0) = -W& / 2: py(0) = -H& / 2: px(1) = -W& / 2: py(1) = H& / 2
    px(2) = W& / 2: py(2) = H& / 2: px(3) = W& / 2: py(3) = -H& / 2
    sinr! = SIN(-Rotation / 57.2957795131): cosr! = COS(-Rotation / 57.2957795131)
    FOR i& = 0 TO 3
        x2& = (px(i&) * cosr! + sinr! * py(i&)) * Scale + X: y2& = (py(i&) * cosr! - px(i&) * sinr!) * Scale + Y
        px(i&) = x2&: py(i&) = y2&
    NEXT
    _MAPTRIANGLE (0, 0)-(0, H& - 1)-(W& - 1, H& - 1), Image& TO(px(0), py(0))-(px(1), py(1))-(px(2), py(2))
    _MAPTRIANGLE (0, 0)-(W& - 1, 0)-(W& - 1, H& - 1), Image& TO(px(0), py(0))-(px(3), py(3))-(px(2), py(2))
END SUB

SUB FireLogic

END SUB

FUNCTION LoadMapSettings (MapName AS STRING)
    LoadMapSettings = 0
    OPEN ("assets/pc/maps/" + MapName + ".map") FOR INPUT AS #1
    INPUT #1, trash$ 'Layers header
    INPUT #1, Map.Layers
    INPUT #1, trash$ 'Max Width for map
    INPUT #1, Map.MaxWidth
    INPUT #1, trash$ 'Max Height for map
    INPUT #1, Map.MaxHeight
    INPUT #1, trash$ 'Tile size per tile
    INPUT #1, Map.TileSize
    INPUT #1, trash$ 'Triggers on the map
    INPUT #1, Map.Triggers
    INPUT #1, trash$ 'Tile texture size
    INPUT #1, Map.TextureSize
    INPUT #1, currentlayer
    'Close #1
    LoadMapSettings = -1
    Map.TileSize = Map.TileSize * 4
END FUNCTION


FUNCTION LoadMap (MapName AS STRING)
    LoadMap = 0
    limit = Map.MaxHeight * Map.MaxWidth * Map.Layers
    FOR z = 1 TO Map.Layers
        FOR y = 0 TO Map.MaxHeight
            FOR x = 0 TO Map.MaxWidth
                ' If x <> Map.MaxWidth Then 'error happens because of the , at each line in the map file. the program interprets the line break as a "" string. please fix
                INPUT #1, Tile(x, y, z).ID
                IF Tile(x, y, z).ID = -404 THEN NVM = 1
                IF NVM = 1 THEN EXIT FOR
                IF z = 2 AND Tile(x, y, z).ID <> 0 THEN Tile(x, y, z).solid = 1
                IF Tile(x, y, z).ID = 0 THEN Tile(x, y, z).transparent = 1
                IDTOTEXTURE = Tile(x, y, z).ID
                IF Tile(x, y, z).ID = 56 THEN Tile(x, y, z).fragile = 1: Tile(x, y, z).transparent = 1
                DO
                    IF IDTOTEXTURE > 16 THEN
                        Tile(x, y, z).rend_spritey = Tile(x, y, z).rend_spritey + 1
                        IDTOTEXTURE = IDTOTEXTURE - 16
                    END IF
                    Tile(x, y, z).rend_spritex = IDTOTEXTURE - 1
                LOOP WHILE IDTOTEXTURE > 16
            NEXT
            IF NVM = 1 THEN EXIT FOR
        NEXT
        IF NVM = 1 THEN EXIT FOR
        IF NVM = 0 THEN IF z <> Map.Layers - 1 THEN INPUT #1, trash$
    NEXT
    INPUT #1, trash$
    INPUT #1, trash$
    INPUT #1, trash$
    INPUT #1, trash$
    FOR r = 1 TO Map.Triggers
        INPUT #1, Line$
        poss = INSTR(Line$, "name=") + 6
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).triggername = MID$(Line$, poss, endpos - poss)

        poss = INSTR(Line$, "x=") + 3
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).x1 = VAL(MID$(Line$, poss, endpos - poss)) * 2

        poss = INSTR(Line$, "y=") + 3
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).y1 = VAL(MID$(Line$, poss, endpos - poss)) * 2

        poss = INSTR(Line$, "width=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).sizex = VAL(MID$(Line$, poss, endpos - poss)) * 2

        poss = INSTR(Line$, "height=") + 8
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).sizey = VAL(MID$(Line$, poss, endpos - poss)) * 2

        Trigger(r).x2 = Trigger(r).x1 + Trigger(r).sizex
        Trigger(r).y2 = Trigger(r).y1 + Trigger(r).sizey
        INPUT #1, trash$

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).class = MID$(Line$, poss, endpos - poss)

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).val1 = VAL(MID$(Line$, poss, endpos - poss))

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).val2 = VAL(MID$(Line$, poss, endpos - poss))

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).val3 = VAL(MID$(Line$, poss, endpos - poss))

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).val4 = VAL(MID$(Line$, poss, endpos - poss))

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).needclick = VAL(MID$(Line$, poss, endpos - poss))

        INPUT #1, Line$
        poss = INSTR(Line$, "value=") + 7
        endpos = INSTR(poss, Line$, CHR$(34))
        Trigger(r).text = MID$(Line$, poss, endpos - poss)
        INPUT #1, trash$
        INPUT #1, trash$
    NEXT
    CLOSE #1
    LoadMap = -1
END FUNCTION

FUNCTION RayCollideEntity (Rect1 AS Raycast, rect2 AS Entity)
    RayCollideEntity = 0
    IF Rect1.x >= rect2.x1 THEN
        IF Rect1.x <= rect2.x2 THEN
            IF Rect1.y >= rect2.y1 THEN
                IF Rect1.y <= rect2.y2 THEN
                    RayCollideEntity = -1
                END IF
            END IF
        END IF
    END IF
END FUNCTION
FUNCTION UICollide (Rect1 AS Mouse, Rect2 AS Menu)
    UICollide = 0
    IF Rect1.x2 >= Rect2.x1 + Rect2.OffsetX THEN
        IF Rect1.x1 <= Rect2.x2 + Rect2.OffsetX THEN
            IF Rect1.y2 >= Rect2.y1 + Rect2.OffsetY THEN
                IF Rect1.y1 <= Rect2.y2 + Rect2.OffsetY THEN
                    UICollide = -1
                END IF
            END IF
        END IF
    END IF
END FUNCTION
FUNCTION TriggerPlayerCollide (Rect1 AS Player, Rect2 AS Trigger)
    TriggerPlayerCollide = 0
    IF Rect1.x2 >= Rect2.x1 THEN
        IF Rect1.x1 <= Rect2.x2 THEN
            IF Rect1.y2 >= Rect2.y1 THEN
                IF Rect1.y1 <= Rect2.y2 THEN
                    TriggerPlayerCollide = -1
                END IF
            END IF
        END IF
    END IF
END FUNCTION
