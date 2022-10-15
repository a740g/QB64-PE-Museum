DefInt A-Z

Type Coord
    row As Integer
    col As Integer
End Type

Type Rectangle
    min As Coord
    max As Coord
End Type

'--------------------------------------------------------------------------
' The KeyMap TYPE stores keyboard/controller button mappings for each player.
'--------------------------------------------------------------------------
Type KeyMap
    playerIndex As Integer '--- Index of the PLAYER() the KeyMap is bound to.
    deviceIndex As Integer '--- Device number the KeyMap is bound to.
    inputType As Integer '--- One of the INPUT_TYPE_{...} values.  Defines the input type on the input device (e.g. button/axis)
    inputAction As String '--- One of the INPUT_ACTION_{...} values. Determines the action the input triggers.
    inputIndex As Single '--- Button/axis index on the device
    axisMin As Single '--- Minimum value the axis must return to trigger action.
    axisMax As Single '--- Maximum value the axis must return to trigger action.
    value As Single '--- Current raw value of the input. Used to determine if the inputAction should be triggered.
    inputName As String '--- On-screen display name of the input.
    needsRelease As Integer '--- 1 = Require a release event before the action can be triggered again, 0 = action may be triggered
End Type

'--- Initialize global key map array that will store all button mappings
Dim Shared KEY_MAP(1 To 64) As KeyMap
Dim Shared KEY_MAPS: KEY_MAPS = 0 '--- Increments as key mappings are added to track the max KEY_MAP index to use

'--------------------------------------------------------------------------
' Input Types are used to identify the what type of input a KeyMap is for.
' This allows different methods to be called for checking/handling the values
' since different inputs have different ranges.
'--------------------------------------------------------------------------
Dim Shared INPUT_TYPE_UNASSIGNED: INPUT_TYPE_UNASSIGNED = 0
Dim Shared INPUT_TYPE_BUTTON: INPUT_TYPE_BUTTON = 1
Dim Shared INPUT_TYPE_AXIS: INPUT_TYPE_AXIS = 2
Dim Shared INPUT_TYPE_WHEEL: INPUT_TYPE_WHEEL = 3

'--------------------------------------------------------------------------
' Input Actions are used to indicate what action a KeyMap should perform
' on the Player's sprite when it is triggering an event.
'--------------------------------------------------------------------------
Dim Shared INPUT_ACTION_NONE As String: INPUT_ACTION_NONE = ""
Dim Shared INPUT_ACTION_LEFT As String: INPUT_ACTION_LEFT = "Move Left"
Dim Shared INPUT_ACTION_RIGHT As String: INPUT_ACTION_RIGHT = "Move Right"
Dim Shared INPUT_ACTION_JUMP As String: INPUT_ACTION_JUMP = "Jump"
Dim Shared INPUT_ACTION_SPIKEBALL As String: INPUT_ACTION_SPIKEBALL = "Spikeball Attack"

'--- Useful when array searching to indicate no index was found.
Dim Shared NULL_INDEX: NULL_INDEX = -1

'--------------------------------------------------------------------------
' The GameState TYPE stores global game state information and settings.
'--------------------------------------------------------------------------
Type GameState
    soundEnabled As Integer '--- 1 = Enable sound effects, 0 = Disable all sound
    loadedLevel As Integer '--- Currently loaded game level. 0 = none loaded.
    nextLevel As Integer '--- Game level to load. Increments as levels are completed.
    levelTitle As String '--- Title of the currently loaded level.
    gravity As Integer '--- Global gravity direction to combine with Sprite gravity settings.
    frameRate As Integer '--- Framerate the game loop runs at in frames-per-second.
    frameCount As _Integer64 '--- Total number of frames that have passed since the level started
    playerCount As Integer '--- Number of active players to load into the level
End Type

'--- Initialize global game state
Dim Shared GAME_STATE As GameState
GAME_STATE.soundEnabled = 1
GAME_STATE.loadedLevel = 0
GAME_STATE.nextLevel = 1
GAME_STATE.gravity = 1
GAME_STATE.frameRate = 18
GAME_STATE.playerCount = 0

'--------------------------------------------------------------------------
' Debugging variables for tracking information, changing values has no functional impact.
'--------------------------------------------------------------------------
Dim Shared DEBUG_ON: DEBUG_ON = 0 '--- 1 = Display messages from as Debug...() SUBs, 0 = Hide messages
Dim Shared DEBUG_SPRITE_INDEX: DEBUG_SPRITE_INDEX = NULL_INDEX '--- For tracking sprite index values
Dim Shared DEBUG_CALLER As String: DEBUG_CALLER = "NONE" '--- For tracking calling SUBs (stack tracing)

'--------------------------------------------------------------------------
' Dimensions of the screen
'--------------------------------------------------------------------------
Dim Shared SCREEN_AREA As Rectangle
SCREEN_AREA.min.row = 1
SCREEN_AREA.min.col = 1
SCREEN_AREA.max.row = 30
SCREEN_AREA.max.col = 80

'--------------------------------------------------------------------------
' Dimensions of the game play area, leaves 2 rows for stats
'--------------------------------------------------------------------------
Dim Shared GAME_AREA As Rectangle
GAME_AREA.min.row = 1
GAME_AREA.min.col = 1
GAME_AREA.max.row = 28
GAME_AREA.max.col = 80

'--------------------------------------------------------------------------
' Color Palette Aliases
'--------------------------------------------------------------------------
Dim Shared CLR_BLACK: CLR_BLACK = 0
Dim Shared CLR_BLUE: CLR_BLUE = 1
Dim Shared CLR_GREEN: CLR_GREEN = 2
Dim Shared CLR_CYAN: CLR_CYAN = 3
Dim Shared CLR_RED: CLR_RED = 4
Dim Shared CLR_MAGENTA: CLR_MAGENTA = 5
Dim Shared CLR_BROWN: CLR_BROWN = 6
Dim Shared CLR_WHITE: CLR_WHITE = 7
Dim Shared CLR_GRAY: CLR_GRAY = 8
Dim Shared CLR_LT_BLUE: CLR_LT_BLUE = 9
Dim Shared CLR_LT_GREEN: CLR_LT_GREEN = 10
Dim Shared CLR_LT_CYAN: CLR_LT_CYAN = 11
Dim Shared CLR_LT_RED: CLR_LT_RED = 12
Dim Shared CLR_LT_MAGENTA: CLR_LT_MAGENTA = 13
Dim Shared CLR_YELLOW: CLR_YELLOW = 14
Dim Shared CLR_LT_WHITE: CLR_LT_WHITE = 15

'--------------------------------------------------------------------------
' The Player TYPE stores information about each player during game play.
'--------------------------------------------------------------------------
Type Player
    enabled As Integer '--- 1 = Player is enabled, 2 = Player is disabled
    spriteIndex As Integer '--- Stores the index values of the player sprites in the SPRITES() array.
    spriteColor As Integer '--- Color the player's default sprite should be.
    startRow As Integer '--- Stores the spawn row position of the player
    startCol As Integer '--- Stores the spawn col position of the player
    score As Integer '--- Total score the player has earned.
    maxJumpDistance As Integer '--- Max number of cols a player can jump
    jumpDistance As Integer '--- Stores the remaining number of jump cols during jumps
    deviceIndex As Integer '--- Input device index number for the player's controller (or other input device)
End Type

Dim Shared PLAYER(1 To 4) As Player '--- Stores the index values of the player sprites in the SPRITES() array.
Dim Shared PLAYER_MAX: PLAYER_MAX = 0 '--- Number of active players in the game

PLAYER(1).spriteColor = CLR_YELLOW
PLAYER(1).maxJumpDistance = 9

PLAYER(2).spriteColor = CLR_LT_BLUE
PLAYER(2).maxJumpDistance = 9

PLAYER(3).spriteColor = CLR_LT_CYAN
PLAYER(3).maxJumpDistance = 9

PLAYER(4).spriteColor = CLR_LT_MAGENTA
PLAYER(4).maxJumpDistance = 9

'--------------------------------------------------------------------------
' Sprite Type Constants: Used to identify select Sprite structs.
'--------------------------------------------------------------------------
Dim Shared SPRITE_TYPE_NONE: SPRITE_TYPE_NONE = 0
Dim Shared SPRITE_TYPE_PLAYER: SPRITE_TYPE_PLAYER = 1
Dim Shared SPRITE_TYPE_PLAYER_SPIKEBALL: SPRITE_TYPE_PLAYER_SPIKEBALL = 2
Dim Shared SPRITE_TYPE_PLAYER_DRAINED: SPRITE_TYPE_PLAYER_DRAINED = 3
Dim Shared SPRITE_TYPE_ENEMY1: SPRITE_TYPE_ENEMY1 = 4
Dim Shared SPRITE_TYPE_FIRE: SPRITE_TYPE_FIRE = 5
Dim Shared SPRITE_TYPE_EXTRA_LIFE: SPRITE_TYPE_EXTRA_LIFE = 6
Dim Shared SPRITE_TYPE_SPIKE: SPRITE_TYPE_SPIKE = 7
Dim Shared SPRITE_TYPE_SLIDE_L: SPRITE_TYPE_SLIDE_L = 8
Dim Shared SPRITE_TYPE_SLIDE_R: SPRITE_TYPE_SLIDE_R = 9
Dim Shared SPRITE_TYPE_NEXT_LEVEL: SPRITE_TYPE_NEXT_LEVEL = 10
'--- Highest index of the SPRINT_TYPE constants above.
Dim Shared SPRITE_TYPES_MAX: SPRITE_TYPES_MAX = 10

'--------------------------------------------------------------------------
' Sprite Movement Type Constants: Used to determine how sprites are moved.
'--------------------------------------------------------------------------
Dim Shared SPRITE_MOVE_NONE: SPRITE_MOVE_NONE = 0
Dim Shared SPRITE_MOVE_PLAYER_CONTROLLED: SPRITE_MOVE_PLAYER_CONTROLLED = 1
Dim Shared SPRITE_MOVE_LR_RANDOM_GROUND: SPRITE_MOVE_LR_RANDOM_GROUND = 2

'--------------------------------------------------------------------------
' Character Collision Behavior Constants: Used to determine player collision behavior
'--------------------------------------------------------------------------
Dim Shared CHAR_COLLISION_NONE: CHAR_COLLISION_NONE = 0
Dim Shared CHAR_COLLISION_SOLID: CHAR_COLLISION_SOLID = 1
Dim Shared CHAR_COLLISION_DEATH: CHAR_COLLISION_DEATH = 2
Dim Shared CHAR_COLLISION_ENEMY_DEATH: CHAR_COLLISION_ENEMY_DEATH = 3
Dim Shared CHAR_COLLISION_EXTRA_LIFE: CHAR_COLLISION_EXTRA_LIFE = 4
Dim Shared CHAR_COLLISION_NEXT_LEVEL: CHAR_COLLISION_NEXT_LEVEL = 5
Dim Shared CHAR_COLLISION_PUSH_LEFT: CHAR_COLLISION_PUSH_LEFT = 6
Dim Shared CHAR_COLLISION_PUSH_RIGHT: CHAR_COLLISION_PUSH_RIGHT = 7
Dim Shared CHAR_COLLISION_VERTICAL_DEATH: CHAR_COLLISION_VERTICAL_DEATH = 8
Dim Shared CHAR_COLLISION_VERTICAL_ENEMY_DEATH: CHAR_COLLISION_VERTICAL_ENEMY_DEATH = 9
'--- Highest index of the CHAR_COLLISION constants above
Dim Shared CHAR_COLLISION_MAX: CHAR_COLLISION_MAX = 9

'--------------------------------------------------------------------------
' The Sprite TYPE stores the state of each Sprite instance during game play.
'--------------------------------------------------------------------------
Type Sprite
    spriteType As Integer '--- Use SPRITE_TYPE_{...} constant. Defines the type of sprite.
    moveType As Integer '--- Use SPRITE_MOVE_{...} constant. Defines sprite movement behavior.
    frames As String '--- String containing 1 or more characters used to render the sprite, in animation order.
    frame As Integer '--- Current animation frame. Stores index of the char to display from the frames property. Range 1 to maxFrame.
    maxFrame As Integer '--- Length of the frames property
    frameRate As Integer '--- Number of game frames between Sprite animation frames.
    frameRateTimer As Integer '--- Tracks frames between Sprite animations. Decrements from frameRate to 0.
    charColor As Integer '--- Use CLR_{...} constant.  Defines sprite color.
    gravity As Integer '--- 1 = sprite affected by gravity, 0 = sprite not affected by gravity, -1 = sprite floats up
    gravityTimer As Integer '--- Number of game frames to suspend gravity effects.
    nextSpriteType As Integer '--- Use SPRITE_TYPE_{...} constant. Changes the current sprite to this SPRITE_TYPES template. SPRITE_TYPE_NONE = no change.
    nextSpriteTypeTimer As Integer '--- Number of frames to wait before changing the sprite to the value in nextSpriteType.
    lives As Integer '--- Stores the health of number of lives remaining for a sprite.
    position As Coord '--- Row/col position in the GAME_AREA Rectangle bounds to render sprite. Set row or col to 0 to disable sprite.
    velocity As Coord '--- Number of chars to move the row/col of the sprite during the next frame.
    moveTo As Coord '--- Used internally as the sprite is being moved and velocity is being applied. Do not modify directly.
    moveTimer As Integer '--- Number of game frames to disallow automatic or player controlled movement.
    friction As Integer '--- Amount of velocity reduction to apply each frame when on a solid. Defaults to 1.
    playerIndex As Integer '--- Index of the PLAYER() that controls the sprite. 0 = not player controlled (default).
    playerPoints As Integer '--- Number of points to award a player if on death of this sprite
    collisionBelow As Integer '--- Stores the CHAR_COLLISION_{...} type between the sprite and the char gravitationally below it. Needed for several checks, so this improves performance by caching it.
    spriteBelowIndex As Integer '--- Index of the sprite gravitationally below this sprite, or NULL_INDEX for none.
    levelDataChar As String '--- Character used in level data files to represent the given sprite type.
End Type

Dim Shared SPRITES(1000) As Sprite '--- Array to store all active game sprites
Dim Shared SPRITE_COUNT: SPRITE_COUNT = 0 '--- Number of active sprites.  Increment as they are added.

'--------------------------------------------------------------------------
' Array with 1 of each SPRITE_TYPE_{...} as the index.
' Used as templates for making new sprites, and for getting the attributes
' of each SPRITE_TYPE_{...}
'--------------------------------------------------------------------------
Dim Shared SPRITE_TYPES(SPRITE_TYPES_MAX + 1) As Sprite

'--- Apply default settings to all SPRITE_TYPES, can be overridden below.
For spriteType = 0 To SPRITE_TYPES_MAX
    SPRITE_TYPES(spriteType).friction = 1
    SPRITE_TYPES(spriteType).frame = 1
Next spriteType

'--- Null Sprite template
SPRITE_TYPES(SPRITE_TYPE_NONE).spriteType = SPRITE_TYPE_NONE
'--- Player Sprite template
SPRITE_TYPES(SPRITE_TYPE_PLAYER).spriteType = SPRITE_TYPE_PLAYER
SPRITE_TYPES(SPRITE_TYPE_PLAYER).moveType = SPRITE_MOVE_PLAYER_CONTROLLED
SPRITE_TYPES(SPRITE_TYPE_PLAYER).frames = ""
SPRITE_TYPES(SPRITE_TYPE_PLAYER).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_PLAYER).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_PLAYER).charColor = CLR_YELLOW
SPRITE_TYPES(SPRITE_TYPE_PLAYER).gravity = 1
SPRITE_TYPES(SPRITE_TYPE_PLAYER).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_PLAYER).lives = 9
SPRITE_TYPES(SPRITE_TYPE_PLAYER).levelDataChar = ""
'--- Player Spikeball Sprite template
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).spriteType = SPRITE_TYPE_PLAYER_SPIKEBALL
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).frames = ""
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).charColor = CLR_LT_WHITE
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).gravity = 1
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).nextSpriteType = SPRITE_TYPE_PLAYER_DRAINED
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).nextSpriteTypeTimer = 5
SPRITE_TYPES(SPRITE_TYPE_PLAYER_SPIKEBALL).levelDataChar = ""
'--- Player Drained Sprite template (can't use attacks)
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).spriteType = SPRITE_TYPE_PLAYER_DRAINED
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).moveType = SPRITE_MOVE_PLAYER_CONTROLLED
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).frames = ""
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).charColor = CLR_LT_RED
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).gravity = 1
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).nextSpriteType = SPRITE_TYPE_PLAYER
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).nextSpriteTypeTimer = 16
SPRITE_TYPES(SPRITE_TYPE_PLAYER_DRAINED).levelDataChar = ""
'---  Enemy1 Sprite template
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).spriteType = SPRITE_TYPE_ENEMY1
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).moveType = SPRITE_MOVE_LR_RANDOM_GROUND
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).frames = "•ў"
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).maxFrame = 2
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).frameRate = 5
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).charColor = CLR_GREEN
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).gravity = 1
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).playerPoints = 50
SPRITE_TYPES(SPRITE_TYPE_ENEMY1).levelDataChar = "O"
'--- Fire Sprite template
SPRITE_TYPES(SPRITE_TYPE_FIRE).spriteType = SPRITE_TYPE_FIRE
SPRITE_TYPES(SPRITE_TYPE_FIRE).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_FIRE).frames = ".;'.;`"
SPRITE_TYPES(SPRITE_TYPE_FIRE).maxFrame = 6
SPRITE_TYPES(SPRITE_TYPE_FIRE).frameRate = 1
SPRITE_TYPES(SPRITE_TYPE_FIRE).charColor = CLR_LT_RED
SPRITE_TYPES(SPRITE_TYPE_FIRE).gravity = 0
SPRITE_TYPES(SPRITE_TYPE_FIRE).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_FIRE).levelDataChar = "F"
'--- Extra Life Sprite Template
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).spriteType = SPRITE_TYPE_EXTRA_LIFE
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).frames = ""
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).charColor = CLR_LT_CYAN
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).gravity = 1
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).playerPoints = 200
SPRITE_TYPES(SPRITE_TYPE_EXTRA_LIFE).levelDataChar = ""
'--- Spike Sprite template
SPRITE_TYPES(SPRITE_TYPE_SPIKE).spriteType = SPRITE_TYPE_SPIKE
SPRITE_TYPES(SPRITE_TYPE_SPIKE).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_SPIKE).frames = "і"
SPRITE_TYPES(SPRITE_TYPE_SPIKE).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_SPIKE).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_SPIKE).charColor = CLR_LT_CYAN
SPRITE_TYPES(SPRITE_TYPE_SPIKE).gravity = 0
SPRITE_TYPES(SPRITE_TYPE_SPIKE).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_SPIKE).levelDataChar = "і"
'--- Slide Right Sprite template
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).spriteType = SPRITE_TYPE_SLIDE_R
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).frames = "\"
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).charColor = CLR_BROWN
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).gravity = 0
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_SLIDE_R).levelDataChar = "\"
'--- Slide Left Sprite template
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).spriteType = SPRITE_TYPE_SLIDE_L
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).frames = "/"
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).charColor = CLR_BROWN
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).gravity = 0
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_SLIDE_L).levelDataChar = "/"
'--- Next Level Sprite template
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).spriteType = SPRITE_TYPE_NEXT_LEVEL
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).moveType = SPRITE_MOVE_NONE
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).frames = "°"
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).maxFrame = 1
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).frameRate = 0
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).charColor = CLR_LT_MAGENTA
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).gravity = 0
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).gravityTimer = 0
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).playerPoints = 100
SPRITE_TYPES(SPRITE_TYPE_NEXT_LEVEL).levelDataChar = "°"

'--------------------------------------------------------------------------
' Sprite collision mappings.
' The 1st index is the Sprite that is moving.
' The 2nd index is the Sprite at the movement destination.
' Value is the collision behavior FROM THE PERSPECTIVE OF THE 1st Sprite.
'
' This means CHAR_COLLISION_DEATH causes the 1st sprite to die,
' and CHAR_COLLISION_ENEMY_DEATH causes the 2nd sprite to die.
'--------------------------------------------------------------------------
Dim Shared COLLISIONS(SPRITE_TYPES_MAX, SPRITE_TYPES_MAX) As Integer
'--- Player movement collisions
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_FIRE) = CHAR_COLLISION_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_EXTRA_LIFE
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_VERTICAL_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_PUSH_LEFT
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_PUSH_RIGHT
COLLISIONS(SPRITE_TYPE_PLAYER, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_NEXT_LEVEL
'--- Player Spikeball movement collisions
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_FIRE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_EXTRA_LIFE
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_PUSH_LEFT
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_PUSH_RIGHT
COLLISIONS(SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_NEXT_LEVEL
'--- Player Drained movement collisions
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_FIRE) = CHAR_COLLISION_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_EXTRA_LIFE
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_VERTICAL_DEATH
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_PUSH_LEFT
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_PUSH_RIGHT
COLLISIONS(SPRITE_TYPE_PLAYER_DRAINED, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_NEXT_LEVEL
'--- Enemy1 movement collisions
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_DEATH
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_FIRE) = CHAR_COLLISION_VERTICAL_DEATH
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_VERTICAL_DEATH
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_PUSH_LEFT
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_PUSH_RIGHT
COLLISIONS(SPRITE_TYPE_ENEMY1, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_SOLID
'--- Fire movement collisions
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_VERTICAL_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_FIRE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_FIRE, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_SOLID
'--- Extra Life movement collisions
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_EXTRA_LIFE
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_EXTRA_LIFE
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_EXTRA_LIFE
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_FIRE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_PUSH_LEFT
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_PUSH_RIGHT
COLLISIONS(SPRITE_TYPE_EXTRA_LIFE, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_SOLID
'--- Spike movement collisions
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_PLAYER) = CHAR_COLLISION_VERTICAL_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_PLAYER_SPIKEBALL) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_PLAYER_DRAINED) = CHAR_COLLISION_VERTICAL_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_ENEMY1) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_FIRE) = CHAR_COLLISION_ENEMY_DEATH
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_EXTRA_LIFE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_SPIKE) = CHAR_COLLISION_SOLID
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_SLIDE_L) = CHAR_COLLISION_PUSH_LEFT
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_SLIDE_R) = CHAR_COLLISION_PUSH_RIGHT
COLLISIONS(SPRITE_TYPE_SPIKE, SPRITE_TYPE_NEXT_LEVEL) = CHAR_COLLISION_DEATH

Dim Shared DEAD_SPLAT$: DEAD_SPLAT$ = "_"

'--------------------------------------------------------------------------
' Keyboard input mappings
'--------------------------------------------------------------------------
If DEBUG_ON Then
    Key(1) On
    On Key(1) ToggleGravity
End If

Key(2) On
On Key(2) ToggleSound

Key(10) On
On Key(10) ExitGame

KEY 15, Chr$(0) + Chr$(1)
On Key(15) ExitGame
Key(15) On



'--------------------------------------------------------------------------
' Start Program Execution
'--------------------------------------------------------------------------
SetDisplayMode
IntroVid
WaitForPlayersToJoin

While GAME_STATE.nextLevel > 0 And GAME_STATE.nextLevel < 11
    LoadLevelData
    RunMainGameLoop

    If GAME_STATE.nextLevel = 0 Then
        DeadVid
        GAME_STATE.nextLevel = 1
    End If
Wend

System

'--------------------------------------------------------------------------
' Keyboard input handlers
'--------------------------------------------------------------------------
Sub ToggleGravity
    GAME_STATE.gravity = GAME_STATE.gravity * -1
End Sub

Sub ExitGame
    System
End Sub

Sub ToggleSound
    If GAME_STATE.soundEnabled = 0 Then GAME_STATE.soundEnabled = 1 Else GAME_STATE.soundEnabled = 0
End Sub

'--------------------------------------------------------------------------
' Displays a waiting screen where players press a button on their input
' device to join the game. As players join, the input device and key
' mappings for the player's controls are displayed.
'
' After all players have joined, a continuation key is pressed to continue.
'--------------------------------------------------------------------------
Sub WaitForPlayersToJoin
    Cls 0
    PrintAt 2, 1, 10, "Waiting for players...Press any button to join."
    PrintAt 3, 1, 10, "Press Esc to quit."
    Color

    _KeyClear
    ClearInkey

    '--- Wait for player input until Esc is pressed and there is at least 1 player
    Do
        For deviceIndex = 1 To _Devices
            '--- Check if the device has any input events
            If _DeviceInput(deviceIndex) Then
                deviceName$ = _Device$(deviceIndex)

                '--- Detect Button presses on any devices with buttons
                If InStr(deviceName$, "[BUTTON]") > 0 And InStr(deviceName$, "[MOUSE]") = 0 Then
                    For btnIndex = 1 To _LastButton(deviceIndex)
                        '--- Detect any button other than SpaceBar (btnIndex 2) as a player joining
                        If _ButtonChange(btnIndex) = -1 And btnIndex <> 58 Then
                            If GAME_STATE.playerCount = 0 Then PrintAt 3, 1, 10, "Press Space to start, or Esc to quit.": Print: Print
                            SetPlayerInputs deviceIndex
                        End If
                    Next btnIndex
                End If
            End If
        Next deviceIndex
    Loop Until InKey$ = " " And GAME_STATE.playerCount > 0
End Sub

'--------------------------------------------------------------------------
' Add a new KeyMap to the KEY_MAP array and increment the KEY_MAPS counter.
'
' @param playerIndex Index of the PLAYER() the KeyMap is bound to.
' @param deviceIndex Device number the KeyMap is bound to.
' @param inputAction$ One of the INPUT_ACTION_{...} values. Determines the action the input triggers.
' @param inputType One of the INPUT_TYPE_{...} values.  Defines the input type on the input device (e.g. button/axis)
' @param inputIndex Button/axis index on the device
' @param axisMin! Minimum value the axis must return to trigger action.
' @param axisMax! Maximum value the axis must return to trigger action.
' @param inputName$ On-screen display name of the input.
'--------------------------------------------------------------------------
Sub AddKeyMap (playerIndex, deviceIndex, inputAction$, inputType, inputIndex, axisMin!, axisMax!, inputName$)
    KEY_MAPS = KEY_MAPS + 1
    KEY_MAP(KEY_MAPS).playerIndex = playerIndex
    KEY_MAP(KEY_MAPS).deviceIndex = deviceIndex
    KEY_MAP(KEY_MAPS).inputAction = inputAction$
    KEY_MAP(KEY_MAPS).inputType = inputType
    KEY_MAP(KEY_MAPS).inputIndex = inputIndex
    KEY_MAP(KEY_MAPS).axisMax = axisMax!
    KEY_MAP(KEY_MAPS).axisMin = axisMin!
    KEY_MAP(KEY_MAPS).inputName = inputName$
End Sub

'--------------------------------------------------------------------------
' Adds a new player and their input device and automatically configures
' the control mappings based on the type of device detected.  Renders
' the final mappings on-screen. Also prevents the deviceIndex from being
' mapped to more than one player at a time by performing no action if the
' deviceIndex is already in use.
'
' @param deviceIndex Device number (see _DEVICEINPUT) to map to the
'--------------------------------------------------------------------------
Sub SetPlayerInputs (deviceIndex)
    '--- Don't assign controller if it is already assigned to another player
    For p = 1 To GAME_STATE.playerCount
        If PLAYER(p).deviceIndex = deviceIndex Then Exit Sub
    Next p

    '--- The controller is available, add a new player
    GAME_STATE.playerCount = GAME_STATE.playerCount + 1
    playerIndex = GAME_STATE.playerCount
    PLAYER(playerIndex).deviceIndex = deviceIndex

    '--- Keep track of the starting KeyMap index so all new KeyMaps
    '--- can be displayed after all the buttons/axis are mapped.
    startingKeyMap = KEY_MAPS + 1
    deviceName$ = GetDeviceName$(deviceIndex)

    '--- Auto-configure the input device button mappings by the detected device name
    '--- More Controller type configurations can be added here.
    Select Case deviceName$
        Case "Controller (XBOX 360 For Windows)", "Controller (Xbox One For Windows)", "Controller (Rock Candy Gamepad for Xbox 360)"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_LEFT, INPUT_TYPE_AXIS, 1, -1, -0.7, "Joystick Left"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_RIGHT, INPUT_TYPE_AXIS, 1, 0.7, 1, "Joystick Right"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_JUMP, INPUT_TYPE_BUTTON, 1, -1, -1, "A Button"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_SPIKEBALL, INPUT_TYPE_BUTTON, 3, -1, -1, "X Button"
        Case "Microsoft SideWinder Precision Pro (USB)"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_LEFT, INPUT_TYPE_AXIS, 1, -1, -0.5, "Joystick Left"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_RIGHT, INPUT_TYPE_AXIS, 1, 0.5, 1, "Joystick Right"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_JUMP, INPUT_TYPE_BUTTON, 5, -1, -1, "A Button"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_SPIKEBALL, INPUT_TYPE_BUTTON, 1, -1, -1, "Joystick Trigger 1"
        Case "USB Gamepad "
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_LEFT, INPUT_TYPE_AXIS, 1, -1, -0.7, "D-Pad Left"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_RIGHT, INPUT_TYPE_AXIS, 1, 0.7, 1, "D-Pad Right"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_JUMP, INPUT_TYPE_BUTTON, 3, -1, -1, "B Button"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_SPIKEBALL, INPUT_TYPE_BUTTON, 1, -1, -1, "Y Button"
        Case "KEYBOARD"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_LEFT, INPUT_TYPE_BUTTON, 332, -1, -1, "Left Arrow Key"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_RIGHT, INPUT_TYPE_BUTTON, 334, -1, -1, "Right Arrow Key"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_JUMP, INPUT_TYPE_BUTTON, 329, -1, -1, "Up Arrow Key"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_SPIKEBALL, INPUT_TYPE_BUTTON, 337, -1, -1, "Down Arrow Key"
        Case Else '--- Generic controller config
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_LEFT, INPUT_TYPE_AXIS, 1, -1, -0.7, "Axis Left"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_RIGHT, INPUT_TYPE_AXIS, 1, 0.7, 1, "Axis Right"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_JUMP, INPUT_TYPE_BUTTON, 1, -1, -1, "Button 1"
            AddKeyMap playerIndex, deviceIndex, INPUT_ACTION_SPIKEBALL, INPUT_TYPE_BUTTON, 2, -1, -1, "Button 2"
    End Select

    '--- Display the newly added player and key mappings
    Color PLAYER(playerIndex).spriteColor
    Print " PLAYER"; Str$(playerIndex); ": "; deviceName$; " #"; LTrim$(Str$(deviceIndex))
    For k = startingKeyMap To KEY_MAPS
        Print KEY_MAP(k).inputAction; ": "; KEY_MAP(k).inputName
    Next k
    Print
End Sub

'--------------------------------------------------------------------------
' Extracts the user-friendly display name of an input device. See _DEVICE$()
' for details on the source string from which this extracts the name.
'
' @param deviceIndex Device number from _DEVICEINPUT to return the name for.
'--------------------------------------------------------------------------
Function GetDeviceName$ (deviceIndex)
    TmpStr$ = _Device$(deviceIndex)
    GetDeviceName$ = Replace$(TmpStr$, "[CONTROLLER]", "")
    GetDeviceName$ = Replace$(TmpStr$, "[NAME]", "")
    GetDeviceName$ = Replace$(TmpStr$, "[BUTTON]", "")
    GetDeviceName$ = Replace$(TmpStr$, "[AXIS]", "")
    GetDeviceName$ = Replace$(TmpStr$, "[", "")
    GetDeviceName$ = Replace$(TmpStr$, "]", "")
End Function

'--------------------------------------------------------------------------
' Run the main game loop for the currently loaded level. LoadLevelData
' must be called before this.
'
' @param gameLevel% Number of the game level to start.
'--------------------------------------------------------------------------
Sub RunMainGameLoop
    ClearInkey
    GAME_STATE.frameCount = 0

    ' Keep running the game loop until the GAME_STATE.nextLevel changes from
    ' its original value. 0 indicates game over/quit
    While GAME_STATE.nextLevel = GAME_STATE.loadedLevel
        ChangeSpritesToNextSpriteType
        RenderSprites
        RenderStatusLine
        _Limit GAME_STATE.frameRate
        CheckSpecialCollisions
        GetKeyInput
        MoveSprites
        GAME_STATE.frameCount = GAME_STATE.frameCount + 1
    Wend
End Sub

'--------------------------------------------------------------------------
' Prints the status line at the bottom of the screen. Displays the
' level title, and each player's remaining lives and scores.
'--------------------------------------------------------------------------
Sub RenderStatusLine
    PrintAt SCREEN_AREA.max.row, 73, 7, "Esc=Quit"
    PrintAt SCREEN_AREA.max.row, 1, 15, "Level" + Str$(GAME_STATE.loadedLevel) + " - " + GAME_STATE.levelTitle

    For p = 1 To PLAYER_MAX
        Color PLAYER(p).spriteColor
        Print "  ="; LTrim$(Str$(SPRITES(PLAYER(p).spriteIndex).lives)) + " $"; LTrim$(Str$(PLAYER(p).score));
    Next p

End Sub


'--------------------------------------------------------------------------
' Reads level data from a file in the .\DATA subfolder. Loads the level
' stored in the GAME_STATE.nextLevel and then updates the
' GAME_STATE.loadedLevel upon success.
'--------------------------------------------------------------------------
Sub LoadLevelData
    '--- Open level data file
    file$ = ".\DATA\LEV_" + LTrim$(Str$(GAME_STATE.nextLevel)) + ".DAT"
    Open file$ For Input As #1

    '--- First line has the title of the level to be returned
    Input #1, GAME_STATE.levelTitle
    DisplayLevelTitle "Level" + Str$(GAME_STATE.nextLevel) + " - " + GAME_STATE.levelTitle
    Cls 0

    '--- Read/render file data to the screen
    For row = GAME_AREA.min.row To GAME_AREA.max.row
        Input #1, levelData$
        PrintAt row, 1, 7, levelData$
    Next row

    '--- Close the file handle
    Close #1

    '--- Update/reset variables storing level-specific data
    GAME_STATE.loadedLevel = GAME_STATE.nextLevel
    SPRITE_COUNT = 0
    PLAYER_MAX = 0

    '--- Clear any previous player movement values
    For p = 1 To GAME_STATE.playerCount
        spriteIndex = PLAYER(p).spriteIndex
        SPRITES(spriteIndex).velocity.row = 0
        SPRITES(spriteIndex).velocity.col = 0
    Next p

    ParseLevelData

    '--- Clear all player key inputs from requiring key releases
    ClearInkey
    For k = 1 To KEY_MAPS
        KEY_MAP(k).needsRelease = 0
        KEY_MAP(k).value = 0
    Next k
End Sub

'--------------------------------------------------------------------------
' Displays a level title screen for a few seconds
'
' @param title$ Level title text to display on screen
'--------------------------------------------------------------------------
Sub DisplayLevelTitle (title$)
    Cls 0
    ClearInkey
    PrintAt 10, 10, 15, title$
    _Delay 3
    ClearInkey
End Sub

'--------------------------------------------------------------------------
' Initializes the game state by parsing the raw level data on the screen.
' Creates sprites, and converts the characters to the proper color and
' in-game characters to be displayed while playing.
'--------------------------------------------------------------------------
Sub ParseLevelData
    char$ = ""

    Dim groundTexture$(3)
    groundTexture$(0) = "Ы"
    groundTexture$(1) = "±"
    groundTexture$(2) = "І"

    For row = 1 To GAME_AREA.max.row
        For col = 1 To GAME_AREA.max.col
            char$ = CharAt$(row, col)

            '--- Process chars that need to be changed
            Select Case char$
                Case "Ы" '--- Solid ground (random texture)
                    Color CLR_GRAY
                    char$ = groundTexture$(Int(Rnd * 3))
                Case "±"
                    Color CLR_CYAN
                Case "І"
                    Color CLR_LT_BLUE
                Case "Я"
                    Color CLR_GRAY
                Case "", "T" '--- Torch [T]
                    Color CLR_YELLOW
                    char$ = ""
                Case "S" '--- Solid color ground (untextured)
                    Color CLR_GRAY
                    char$ = "Ы"
                Case Else
                    Color CLR_GRAY
            End Select

            spriteType = GetSpriteType(char$)
            If spriteType Then
                '--- Process Sprite chars
                AddSprite spriteType, row, col
            Else
                '--- Process chars that need to change
                '--- into chars that would conflict with Sprites
                '--- if processed before the sprite detection.
                Select Case char$
                    Case "P" '--- Pole [P]
                        Color CLR_YELLOW
                        char$ = "і" '--- Conflicts with Spike sprite
                End Select
            End If

            If Asc(char$) > 96 And Asc(char$) < 123 Then
                char$ = UCase$(char$)
            End If

            Locate row, col: Print char$
        Next col
    Next row
End Sub

'--------------------------------------------------------------------------
' Returns the index of the SPRITES() array element at a specified
' row and column, or NULL_INDEX for none.
'
' @param row Game area row to check for sprites.
' @param col Game area col to check for sprites.
' @return Returns an index for referencing the SPRITES() array, of the sprite at the specified row/col.
'--------------------------------------------------------------------------
Function GetSpriteIndexAt (row, col)
    GetSpriteIndexAt = NULL_INDEX

    For index = 0 To SPRITE_COUNT - 1
        If SPRITES(index).position.row = row And SPRITES(index).position.col = col Then
            GetSpriteIndexAt = index
        End If
    Next index
End Function


'--------------------------------------------------------------------------
' Iterates all Sprites in the SPRITES() array, decrements their
' nextSpriteTimer until it reaches 0, and then calls to change them
' to their next sprite type.  Ignored if nextSpriteType is empty/0.
'--------------------------------------------------------------------------
Sub ChangeSpritesToNextSpriteType
    For index = 0 To SPRITE_COUNT - 1
        '--- Count nextSpriteTimer down if it is set
        If SPRITES(index).nextSpriteTypeTimer > 0 Then
            SPRITES(index).nextSpriteTypeTimer = SPRITES(index).nextSpriteTypeTimer - 1
        End If

        If SPRITES(index).nextSpriteType And SPRITES(index).nextSpriteTypeTimer < 1 Then
            SpriteChangeType index
        End If
    Next index
End Sub

'--------------------------------------------------------------------------
' Changes a Sprite to the SPRITE_TYPE_{...} value specified in its
' .nextSpriteType property, and copies over the properties
' that are necessary for the new Sprite.
'
' @param index Sprite index of the Sprite to be changed
'--------------------------------------------------------------------------
Sub SpriteChangeType (index)
    Dim oldSprite As Sprite
    Dim newSprite As Sprite

    If SPRITES(index).nextSpriteType <> SPRITE_TYPE_NONE Then
        oldSprite = SPRITES(index)
        newSprite = SPRITE_TYPES(oldSprite.nextSpriteType)

        '--- Sprite type-specific changes here
        Select Case newSprite.spriteType
            Case SPRITE_TYPE_PLAYER, SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_PLAYER_DRAINED
                newSprite.lives = oldSprite.lives
                newSprite.gravityTimer = oldSprite.gravityTimer
                newSprite.playerIndex = oldSprite.playerIndex
                If newSprite.spriteType = SPRITE_TYPE_PLAYER Then
                    newSprite.charColor = PLAYER(oldSprite.playerIndex).spriteColor
                End If
        End Select

        '--- Changes that carry over for all types.
        newSprite.position = oldSprite.position
        newSprite.velocity = oldSprite.velocity
        newSprite.moveTo = oldSprite.moveTo

        SPRITES(index) = newSprite
    End If
End Sub


'--------------------------------------------------------------------------
' Process movement for all active sprites.
' Gets called by game loop once per frame.
'--------------------------------------------------------------------------
Sub MoveSprites
    For index = 0 To SPRITE_COUNT - 1
        '--- Only move sprite if it is alive and in a valid game area position
        If SpriteIsActive(SPRITES(index)) Then
            SpriteUpdateCollisionBelow index
            SpriteApplyGravity index

            '--- Apply automatic or player-controlled SPRITE_MOVE_{...} types
            Select Case SPRITES(index).moveType
                Case SPRITE_MOVE_LR_RANDOM_GROUND
                    SpriteMoveLRRandomGround index
                Case SPRITE_MOVE_PLAYER_CONTROLLED
                    SpriteMovePlayerControlled index
            End Select

            '--- Move the Sprite using the new velocity values
            SpriteChangeMoveTarget index, SPRITES(index).position.row + SPRITES(index).velocity.row, SPRITES(index).position.col + SPRITES(index).velocity.col
        End If
    Next index
End Sub

'--------------------------------------------------------------------------
' Applies gravity to a Sprite based on the game state gravity and the
' Sprite's gravity combined.
'
' @param index Sprite index to apply gravity to.
'--------------------------------------------------------------------------
Sub SpriteApplyGravity (index)
    rowBelow = SPRITES(index).position.row + Sgn(GAME_STATE.gravity)
    spriteBelowIndex = SPRITES(index).spriteBelowIndex
    collisionBelow = SPRITES(index).collisionBelow

    '---Player landing on solid ground/slides ends jump
    If SPRITES(index).playerIndex And SPRITES(index).gravityTimer > 0 Then
        '--- Stop player from floating up any more after the initial jump (which got processed in the previous frame)
        SPRITES(index).velocity.row = 0

        If collisionBelow = CHAR_COLLISION_SOLID Or collisionBelow = CHAR_COLLISION_PUSH_LEFT Or collisionBelow = CHAR_COLLISION_PUSH_RIGHT Then
            '--- End jump if NOT jumping over another player
            If spriteBelowIndex = NULL_INDEX Then
                SPRITES(index).gravityTimer = 0
            ElseIf SPRITES(spriteBelowIndex).playerIndex < 1 Then
                SPRITES(index).gravityTimer = 0
            End If
        End If
    End If

    '--- Apply gravity based on sprite settings
    If SPRITES(index).gravityTimer = 0 Then
        If SPRITES(index).gravity Then

            '--- Apply friction from ground when there is gravity
            If rowBelow >= GAME_AREA.min.row And rowBelow <= GAME_AREA.max.col Then
                '--- Only check friction if it is a non-zero value
                If SPRITES(index).friction Then
                    '--- Apply friction if it is not a "frictionless" push collision
                    If collisionBelow <> CHAR_COLLISION_NONE Then
                        SPRITES(index).velocity.col = SPRITES(index).velocity.col - SPRITES(index).friction * Sgn(SPRITES(index).velocity.col)
                    End If
                End If
            End If

            '--- Only apply gravity when not on a solid surface/object
            If collisionBelow <> CHAR_COLLISION_SOLID Then
                totalGravity = SPRITES(index).gravity * GAME_STATE.gravity

                If GAME_STATE.gravity > 0 Then
                    SPRITES(index).velocity.row = GetMin(SPRITES(index).velocity.row + totalGravity, totalGravity)
                ElseIf GAME_STATE.gravity < 0 Then
                    SPRITES(index).velocity.row = GetMax(SPRITES(index).velocity.row + totalGravity, totalGravity)
                End If
            End If
        End If
    Else
        SPRITES(index).gravityTimer = SPRITES(index).gravityTimer - 1
    End If
End Sub

'--------------------------------------------------------------------------
' Updates the collisionBelow property of a Sprite.  Several movement and
' collision checks need to check what type of collision is gravitationally
' under a Sprite, so this caches the result so it doesn't have to be
' recomputed each time.  Currently gets called by SpriteApplyGravity and
' SpriteAllowMove.
'
' @param index SPRITES() array index of the sprite to update.
'--------------------------------------------------------------------------
Sub SpriteUpdateCollisionBelow (index)
    rowBelow = SPRITES(index).position.row + Sgn(GAME_STATE.gravity)
    SPRITES(index).spriteBelowIndex = GetSpriteIndexAt(rowBelow, SPRITES(index).position.col)
    SPRITES(index).collisionBelow = GetCollisionType(index, SPRITES(index).spriteBelowIndex, CharAt$(rowBelow, SPRITES(index).position.col))
End Sub

'--------------------------------------------------------------------------
' Apply automatic AI left/right velocity changes to a Sprite.  Avoids
' falling off ledges or moving into hazards, and otherwise moves in slow,
' random side-to-side increments. Used for Sprites having a moveType
' value of SPRITE_MOVE_LR_RANDOM_GROUND.
'
' @param index Sprite index to move.
'--------------------------------------------------------------------------
Sub SpriteMoveLRRandomGround (index)
    If SPRITES(index).moveTimer < 1 Then
        '--- Only move once every 4 to 15 game frames
        SPRITES(index).moveTimer = Int(Rnd * 12) + 4
        '--- Move randomly 1 left, 1 right, or stay put (1/3 chance of each)
        SPRITES(index).velocity.col = Int(Rnd * 3) - 1

        '--- Check for solid ground just below where the sprite should move.
        rowBelow = SPRITES(index).position.row + 1
        colBelow = SPRITES(index).position.col + Sgn(SPRITES(index).velocity.col)

        '--- If it's not solid ground or an attack on the player, cancel moving there
        collisionBelow = GetCollisionType(index, GetSpriteIndexAt(rowBelow, colBelow), CharAt$(rowBelow, colBelow))
        If collisionBelow <> CHAR_COLLISION_SOLID And collisionBelow <> CHAR_COLLISION_ENEMY_DEATH Then
            SPRITES(index).velocity.col = 0
        End If
    Else
        SPRITES(index).moveTimer = SPRITES(index).moveTimer - 1
    End If
End Sub

'--------------------------------------------------------------------------
' Handle keyboard input from the player and apply actions to player
' controlled Sprites.
'
' @param spriteIndex SPRITES() array index of the player-controlled Sprite.
'--------------------------------------------------------------------------
Sub SpriteMovePlayerControlled (spriteIndex)
    Dim keyMap As KeyMap
    Dim player As Player

    SPRITES(spriteIndex).velocity.col = 0

    For k = 1 To KEY_MAPS
        keyMap = KEY_MAP(k)
        playerIndex = keyMap.playerIndex
        player = PLAYER(playerIndex)

        If spriteIndex = player.spriteIndex Then
            If CheckKeyInput(keyMap) Then
                Select Case keyMap.inputAction
                    Case INPUT_ACTION_LEFT
                        If SPRITES(spriteIndex).moveTimer = 0 Then
                            SPRITES(spriteIndex).moveTimer = 2
                            SPRITES(spriteIndex).velocity.col = -1
                        End If
                    Case INPUT_ACTION_RIGHT
                        If SPRITES(spriteIndex).moveTimer = 0 Then
                            SPRITES(spriteIndex).moveTimer = 2
                            SPRITES(spriteIndex).velocity.col = 1
                        End If
                    Case INPUT_ACTION_JUMP
                        '--- Check what is gravitationally below the player
                        collisionBelow = SPRITES(spriteIndex).collisionBelow

                        '--- Only jump when on solid ground or slides
                        If collisionBelow = CHAR_COLLISION_SOLID Or collisionBelow = CHAR_COLLISION_PUSH_LEFT Or collisionBelow = CHAR_COLLISION_PUSH_RIGHT Then
                            '--- Require jump key to be released before jumping again
                            KeyMapSetNeedsRelease 1, playerIndex, INPUT_ACTION_JUMP
                            PLAYER(playerIndex).jumpDistance = player.maxJumpDistance
                            SPRITES(spriteIndex).velocity.row = Sgn(GAME_STATE.gravity) * -1
                            SPRITES(spriteIndex).gravityTimer = 16
                        End If
                    Case INPUT_ACTION_SPIKEBALL
                        If SPRITES(spriteIndex).spriteType <> SPRITE_TYPE_PLAYER_DRAINED Then
                            KeyMapSetNeedsRelease 1, playerIndex, INPUT_ACTION_SPIKEBALL '--- Must release key before attacking again

                            SPRITES(spriteIndex).nextSpriteType = SPRITE_TYPE_PLAYER_SPIKEBALL
                            SPRITES(spriteIndex).nextSpriteTypeTimer = 0
                            SPRITES(spriteIndex).velocity.col = 0
                        End If
                End Select
            End If
        End If
    Next k

    If SPRITES(spriteIndex).moveTimer > 0 Then
        SPRITES(spriteIndex).moveTimer = SPRITES(spriteIndex).moveTimer - 1
    End If
End Sub

'--------------------------------------------------------------------------
' Require or unrequire an input to be released (meaning it falls out of
' range for active input) before further input events will be treated as active.
' Used for inputs where you don't want the player to hold the button/axis and
' have the action happen continuously until they release the button/axis first.
'
' @param needRelease 1=Require input to be released, 0=Remove release requirement
' @param playerIndex PLAYER() array Player instance whose input is being modified
' @param inputAction$ INPUT_ACTION_{...} type for which the button release requirement will be applied.
'--------------------------------------------------------------------------
Sub KeyMapSetNeedsRelease (needsRelease, playerIndex, inputAction$)
    For k = 1 To KEY_MAPS
        If KEY_MAP(k).playerIndex = playerIndex And KEY_MAP(k).inputAction = inputAction$ Then
            KEY_MAP(k).needsRelease = needsRelease
        End If
    Next k
End Sub

'--------------------------------------------------------------------------
' Main function for moving a Sprite's position during a frame.
' Use this to initiate collision-safe moves to a Sprite:
'
' * Handles keeping the requested position within the GAME_AREA bounds.
' * Sets the .moveTo property to the bounded requested position.
' * Calls for handling all collisions along the way.
'
' @param spriteIndex Index of the Sprite to move.
' @param row Game area row to attempt to move the sprite to.
' @param col Game area col to attempt to move the sprite to.
'--------------------------------------------------------------------------
Sub SpriteChangeMoveTarget (spriteIndex, row, col)
    '--- Store original position so we can tell if the Sprite moved
    originalRow = SPRITES(spriteIndex).position.row
    originalCol = SPRITES(spriteIndex).position.col

    '--- Limit the move target to be withing the game area bounds
    SPRITES(spriteIndex).moveTo.row = GetMax(GAME_AREA.min.row, GetMin(GAME_AREA.max.row, row))
    SPRITES(spriteIndex).moveTo.col = GetMax(GAME_AREA.min.col, GetMin(GAME_AREA.max.col, col))

    '--- Move toward the new target
    SpriteMoveTowardTarget spriteIndex

    '--- If the sprite moved and did not leave a "dead splat" clear the spot it was in
    If originalRow <> SPRITES(spriteIndex).position.row Or originalCol <> SPRITES(spriteIndex).position.col Then
        If SpriteIsActive(SPRITES(spriteIndex)) And CharAt$(originalRow, originalCol) <> DEAD_SPLAT$ Then PrintAt originalRow, originalCol, 0, " "
    End If
End Sub

'--------------------------------------------------------------------------
' Moves the sprite 1 unit toward its .moveTo property coordinates,
' and calls for collision handling. This ensures that all collisions
' along the movement path will be handled by moving in a straight line,
' one unit at a time.
'
' @param spriteIndex Index of the Sprite to move.
'--------------------------------------------------------------------------
Sub SpriteMoveTowardTarget (spriteIndex)
    Dim sprite As Sprite
    sprite = SPRITES(spriteIndex)

    '--- Get the distance (in character units) to the target row/col
    rowsRemaining = sprite.moveTo.row - sprite.position.row
    colsRemaining = sprite.moveTo.col - sprite.position.col
    stepsRemaining = GetMax(Abs(rowsRemaining), Abs(colsRemaining))

    '--- Only continue if the move target is not yet reached
    If stepsRemaining > 0 Then
        '--- Move one unit toward the target row/col in a straight line
        newRow = sprite.position.row + CInt(rowsRemaining / stepsRemaining)
        newCol = sprite.position.col + CInt(colsRemaining / stepsRemaining)

        CheckCollision spriteIndex, newRow, newCol
    End If
End Sub

'--------------------------------------------------------------------------
' Gets the CHAR_COLLISION_{...} constant for a collision between a
' specified Sprite and an optional target Sprite and/or character.
'
' @param spriteIndex Index of the Sprite to compare as the source sprite.
' @param targetSpriteIndex Index of the Sprite to as the destination sprite.
'                          Can be set to NULL_INDEX to skip sprite collision checking
' @param targetChar$ Single character to compare as the collision destination.
' @return CHAR_COLLISION_{...} constant indicating the collision type.
'--------------------------------------------------------------------------
Function GetCollisionType (spriteIndex, targetSpriteIndex, targetChar$)
    '--- Get type of collision at the target row/col
    If targetSpriteIndex <> NULL_INDEX Then
        GetCollisionType = COLLISIONS(SPRITES(spriteIndex).spriteType, SPRITES(targetSpriteIndex).spriteType)
    Else
        Select Case targetChar$
            Case " ", DEAD_SPLAT$
                GetCollisionType = CHAR_COLLISION_NONE
            Case Else
                GetCollisionType = CHAR_COLLISION_SOLID
        End Select
    End If
End Function

'--------------------------------------------------------------------------
' Checks a Sprite for collisions at a specified position, and applies
' the appropriate collision result (e.g. blocking, death, next level, etc).
' Typically called by the SpriteMoveTowardTarget and not directly.
'
' IMPORTANT: THE row/col PARAMS MUST NOT BE MORE THAN 1 UNIT AWAY FROM
'            THE Sprite's .position property!
'
' @param spriteIndex Index of the Sprite to check for collisions.
' @param row Destination row to check for collisions.
' @param col Destination col to check for collisions.
'--------------------------------------------------------------------------
Sub CheckCollision (spriteIndex, row, col)
    Dim sprite As Sprite
    sprite = SPRITES(spriteIndex)

    Dim targetSprite As Sprite
    targetSpriteIndex = GetSpriteIndexAt(row, col)
    If targetSpriteIndex <> NULL_INDEX Then targetSprite = SPRITES(targetSpriteIndex)

    collisionType = GetCollisionType(spriteIndex, targetSpriteIndex, CharAt$(row, col))

    '--- Handling for all collision types
    Select Case collisionType
        Case CHAR_COLLISION_NONE
            SpriteAllowMove spriteIndex, row, col
        Case CHAR_COLLISION_SOLID
            SpriteBlockMove spriteIndex, row, col
        Case CHAR_COLLISION_DEATH
            SpriteDeath spriteIndex, targetSpriteIndex
        Case CHAR_COLLISION_ENEMY_DEATH
            SpriteDeath targetSpriteIndex, spriteIndex
            SpriteAllowMove spriteIndex, row, col
        Case CHAR_COLLISION_EXTRA_LIFE
            If targetSprite.spriteType = SPRITE_TYPE_EXTRA_LIFE Then
                SpriteDeath targetSpriteIndex, spriteIndex
                SpriteExtraLife spriteIndex
            End If
            If sprite.spriteType = SPRITE_TYPE_EXTRA_LIFE Then
                SpriteDeath spriteIndex, targetSpriteIndex
                SpriteExtraLife targetSpriteIndex
            Else
                SpriteAllowMove spriteIndex, row, col
            End If
        Case CHAR_COLLISION_NEXT_LEVEL
            GAME_STATE.nextLevel = GAME_STATE.nextLevel + 1
            SpriteDeath targetSpriteIndex, spriteIndex
            SpriteAllowMove spriteIndex, row, col
        Case CHAR_COLLISION_PUSH_LEFT
            SPRITES(spriteIndex).velocity.col = -1
            SpriteChangeMoveTarget spriteIndex, row, col - 1
        Case CHAR_COLLISION_PUSH_RIGHT
            SPRITES(spriteIndex).velocity.col = 1
            SpriteChangeMoveTarget spriteIndex, row, col + 1
        Case CHAR_COLLISION_VERTICAL_DEATH
            If sprite.position.row <> row Then
                SpriteDeath spriteIndex, targetSpriteIndex
            Else
                SpriteBlockMove spriteIndex, row, col
            End If
        Case CHAR_COLLISION_VERTICAL_ENEMY_DEATH
            If sprite.position.row <> row Then
                SpriteDeath targetSpriteIndex, spriteIndex
                SpriteAllowMove spriteIndex, row, col
            Else
                SpriteBlockMove spriteIndex, row, col
            End If
        Case Else
            SpriteBlockMove spriteIndex, row, col
    End Select
End Sub

'--------------------------------------------------------------------------
' Similar to CheckCollision but handles non-movement cases such as the
' Spikeball that attacks the spaces to its sides.  Add any special collision
' cases here where the Sprites are not technically touching but collision
' rules should be applied.
'--------------------------------------------------------------------------
Sub CheckSpecialCollisions
    For index = 0 To SPRITE_COUNT - 1
        Dim sprite As Sprite: sprite = SPRITES(index)

        Select Case sprite.spriteType
            Case SPRITE_TYPE_PLAYER_SPIKEBALL
                '--- Spikeball attacks directly to left/right, check for collisions on both
                For colOffset = -1 To 1 Step 2
                    targetIndex = GetSpriteIndexAt(sprite.position.row, sprite.position.col + colOffset)

                    '--- If a sprite is found and a spikeball collision kills it, then kill it
                    If targetIndex <> NULL_INDEX Then
                        If COLLISIONS(sprite.spriteType, SPRITES(targetIndex).spriteType) = CHAR_COLLISION_ENEMY_DEATH Then
                            SpriteDeath targetIndex, index
                        End If
                    End If
                Next colOffset
        End Select

    Next index
End Sub

'--------------------------------------------------------------------------
' Apply an allowable move to a Sprite's' .position property.
' Typically called by SUB CheckCollision after collision handling,
' and not directly.
'
' @param spriteIndex Index of the Sprite to move.
' @param row New row position to apply to the Sprite.
' @param col New col position to apply to the Sprite.
'--------------------------------------------------------------------------
Sub SpriteAllowMove (spriteIndex, row, col)
    SPRITES(spriteIndex).position.row = row
    SPRITES(spriteIndex).position.col = col

    SpriteUpdateCollisionBelow spriteIndex

    '--- Check if this is a player sprite
    If SPRITES(spriteIndex).playerIndex Then
        playerIndex = SPRITES(spriteIndex).playerIndex

        '--- Check if the player is currently jumping
        If SPRITES(spriteIndex).gravityTimer > 0 Then

            '--- Reduce the remaining jump distance allowed
            PLAYER(playerIndex).jumpDistance = PLAYER(playerIndex).jumpDistance - 1

            '--- End the jump if the jump distance runs out
            If PLAYER(playerIndex).jumpDistance = 0 Then SPRITES(spriteIndex).gravityTimer = 0
        End If
    End If

    SpriteMoveTowardTarget spriteIndex
End Sub

'--------------------------------------------------------------------------
' Block a move to a Sprite's position at a requested position.
' Typically called by SUB CheckCollision after collision handling.
'
' * Changes the requested move to an appropriate alternative position.
' * Alters the Sprite .velocity property based on the nature of the block.
' * Retries an alternative move based on the angle/velocity/surroundings.
'
' @param spriteIndex Index of the moving Sprite to block.
' @param row Blocked row the sprite is trying to move to.
' @param col Blocked col the sprite is trying to move to.
'--------------------------------------------------------------------------
Sub SpriteBlockMove (spriteIndex, row, col)
    Dim sprite As Sprite: sprite = SPRITES(spriteIndex)

    If sprite.position.row <> row And sprite.position.col <> col Then
        '--- Blocked on an angle. First try a quick check on either side for empty spaces.
        If GetCollisionType(spriteIndex, NULL_INDEX, CharAt$(sprite.position.row, col)) = CHAR_COLLISION_NONE Then emptyHorizontal = 1 Else emptyHorizontal = 0
        If GetCollisionType(spriteIndex, NULL_INDEX, CharAt$(row, sprite.position.col)) = CHAR_COLLISION_NONE Then emptyVertical = 1 Else emptyVertical = 0

        '--- Since the angle is blocked, try the best horizontal or vertical move.
        If emptyVertical And emptyHorizontal = 0 Then
            SPRITES(spriteIndex).velocity.col = 0
            SpriteChangeMoveTarget spriteIndex, row, sprite.position.col '--- Only vertical move is empty, go there
        ElseIf emptyHorizontal And emptyVertical = 0 Then
            SPRITES(spriteIndex).velocity.row = 0
            SpriteChangeMoveTarget spriteIndex, sprite.position.row, col '--- Only horizontal move is empty, go there
        ElseIf Abs(sprite.velocity.row) > Abs(sprite.velocity.col) Then
            SPRITES(spriteIndex).velocity.col = 0
            SpriteChangeMoveTarget spriteIndex, row, sprite.position.col '--- Stronger vertical velocity, move vertical
        ElseIf Abs(sprite.velocity.col) > Abs(sprite.velocity.row) Then
            SPRITES(spriteIndex).velocity.row = 0
            SpriteChangeMoveTarget spriteIndex, sprite.position.row, col '--- Stronger horizontal velocity, move horizontal
        Else
            SPRITES(spriteIndex).velocity.col = 0 '--- Perfect 45-degree collision, favor vertical movement (gravity)
            SpriteChangeMoveTarget spriteIndex, sprite.position.row, sprite.position.col
        End If
    ElseIf sprite.position.row <> row Then
        SPRITES(spriteIndex).velocity.row = 0 '--- Vertical block. Stop vertical velocity and further movement.
        SpriteChangeMoveTarget spriteIndex, sprite.position.row, sprite.position.col
    ElseIf sprite.position.col <> col Then
        SPRITES(spriteIndex).velocity.col = 0 '--- Horizontal block. Stop horizontal velocity and further movement.
        SpriteChangeMoveTarget spriteIndex, sprite.position.row, sprite.position.col
    End If
End Sub

'--------------------------------------------------------------------------
' Adds a life to a sprite and processes any other sprite-specific
' extra life behaviors.
'
' @param spriteIndex Index of the Sprite to move.
'--------------------------------------------------------------------------
Sub SpriteExtraLife (spriteIndex)
    SPRITES(spriteIndex).lives = SPRITES(spriteIndex).lives + 1

    Select Case SPRITES(spriteIndex).spriteType
        Case SPRITE_TYPE_PLAYER, SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_PLAYER_DRAINED
            If GAME_STATE.soundEnabled = 1 Then Play "MB T200 O1 L64 CDEFGAB>CDEFGAB>C"
    End Select
End Sub

'--------------------------------------------------------------------------
' Deducts 1 life from the sprite and disables it if dead. Defines
' replacement chars and colors for dead sprites. Called after death
' collision detections.
'
' @param spriteIndex Index of the Sprite that should lose a life.
'--------------------------------------------------------------------------
Sub SpriteDeath (spriteIndex, causedByIndex)
    SPRITES(spriteIndex).lives = SPRITES(spriteIndex).lives - 1
    Dim sprite As Sprite: sprite = SPRITES(spriteIndex)
    Dim causedBySprite As Sprite: causedBySprite = SPRITES(causedByIndex)

    replacementChar$ = " " '--- Default replacement char (empty space)
    replacementColor = CLR_BLACK '--- Default replacement color

    '--- Award player points if they caused the death of this sprite
    If causedBySprite.playerIndex Then
        PLAYER(causedBySprite.playerIndex).score = PLAYER(causedBySprite.playerIndex).score + sprite.playerPoints
    End If

    Select Case sprite.spriteType
        Case SPRITE_TYPE_PLAYER, SPRITE_TYPE_PLAYER_SPIKEBALL, SPRITE_TYPE_PLAYER_DRAINED
            '--- Move the Sprite back to the player's original starting position
            playerIndex = sprite.playerIndex
            SPRITES(spriteIndex).position.row = PLAYER(playerIndex).startRow
            SPRITES(spriteIndex).position.col = PLAYER(playerIndex).startCol
            SPRITES(spriteIndex).moveTo.row = PLAYER(playerIndex).startRow
            SPRITES(spriteIndex).moveTo.col = PLAYER(playerIndex).startCol
            SPRITES(spriteIndex).velocity.row = 0
            SPRITES(spriteIndex).velocity.col = 0

            '--- Replace the template's .lives value with the deducted value
            If GAME_STATE.soundEnabled Then Play "MB O0 T120 L4 C"
            If SPRITES(spriteIndex).lives < 1 Then GAME_STATE.nextLevel = 0

            '--- Leave a splat the same color as the player was
            PrintAt sprite.position.row, sprite.position.col, sprite.charColor, DEAD_SPLAT$
        Case SPRITE_TYPE_ENEMY1
            '--- Show a red splat for dead Enemy1 sprites
            If GAME_STATE.soundEnabled Then Play "MB O0 T120 L16 E-"
            replacementColor = CLR_GREEN
            replacementChar$ = DEAD_SPLAT$
    End Select

    '--- Disable the Sprite if it is out of lives
    If SPRITES(spriteIndex).lives < 1 Then SpriteDisable spriteIndex, replacementChar$, replacementColor
End Sub

'--------------------------------------------------------------------------
' Disables a sprite to remove it from rendering, movement, and collision
' tests. Sets position, moveTo, and velocity to empty values and optionally
' prints a replacement character where the spite was located.
'
' @param spriteIndex Index of the Sprite to disable.
' @param replacementChar$ Char to print where the sprite was located
' @param replacementColor CLR_{...} constant of the color to use for the replacementChar$.
'--------------------------------------------------------------------------
Sub SpriteDisable (spriteIndex, replacementChar$, replacementColor)
    PrintAt SPRITES(spriteIndex).position.row, SPRITES(spriteIndex).position.col, replacementColor, replacementChar$
    SPRITES(spriteIndex).position.row = 0
    SPRITES(spriteIndex).position.col = 0
    SPRITES(spriteIndex).moveTo.row = 0
    SPRITES(spriteIndex).moveTo.col = 0
    SPRITES(spriteIndex).velocity.row = 0
    SPRITES(spriteIndex).velocity.col = 0
End Sub

'--------------------------------------------------------------------------
' Render all active sprites to the screen and update their animation frames.
'--------------------------------------------------------------------------
Sub RenderSprites
    Dim sprite As Sprite

    For index = 0 To SPRITE_COUNT - 1
        sprite = SPRITES(index)

        '--- Only render on-screen sprites.
        If SpriteIsActive(sprite) Then
            '--- Only animate sprite if framerate is above 0
            If SPRITES(index).frameRate Then
                SPRITES(index).frameRateTimer = (SPRITES(index).frameRateTimer + 1) Mod SPRITES(index).frameRate

                '--- Animate next frame when frameRateTimer cycles to 0
                If SPRITES(index).frameRateTimer = 0 Then
                    SPRITES(index).frame = SPRITES(index).frame + 1
                    If SPRITES(index).frame > SPRITES(index).maxFrame Then SPRITES(index).frame = 1
                End If
            End If

            SPRITES(index).charColor = AnimateSpriteColor(sprite)
            RenderSprite sprite
        End If
    Next index
End Sub

'--------------------------------------------------------------------------
' Draws a Sprite on the screen at its stored position using the Sprite's
' current animation frame and color.
'
' @param sprite Sprite to be rendered on the screen.
'--------------------------------------------------------------------------
Sub RenderSprite (sprite As Sprite)
    PrintAt sprite.position.row, sprite.position.col, sprite.charColor, Mid$(sprite.frames, sprite.frame, 1)
End Sub

'--------------------------------------------------------------------------
' Tests if a sprite has lives remaining and is not off-screen. Use before
' calling any sprite rendering, moving, or collision testing.
'
' @param sprite Sprite to test. 1 = active, 0 = inactive/disabled
'--------------------------------------------------------------------------
Function SpriteIsActive (sprite As Sprite)
    If sprite.lives > 0 And sprite.position.row > 0 And sprite.position.col > 0 Then
        SpriteIsActive = 1
    Else
        SpriteIsActive = 0
    End If
End Function

'--------------------------------------------------------------------------
' Returns the next charColor property value for a Sprite to be rendered
' based on its spriteType property.
'
' @param sprite Sprite being animated.
' @return New value to be assigned to the sprite's charColor.
'--------------------------------------------------------------------------
Function AnimateSpriteColor (sprite As Sprite)
    Select Case sprite.spriteType
        Case SPRITE_TYPE_PLAYER_SPIKEBALL
            If sprite.charColor = CLR_LT_WHITE Then
                AnimateSpriteColor = CLR_LT_RED
            Else
                AnimateSpriteColor = CLR_LT_WHITE
            End If
        Case SPRITE_TYPE_FIRE
            colorRandomizer = Int(Rnd * 2)
            If colorRandomizer = 0 Then AnimateSpriteColor = CLR_RED
            If colorRandomizer = 1 Then AnimateSpriteColor = CLR_LT_RED
        Case SPRITE_TYPE_EXTRA_LIFE
            TempN = (sprite.charColor + 1) Mod 15
            If TempN = 0 Then AnimateSpiteColor = 1 Else AnimateSpiteColor = TempN
        Case Else
            AnimateSpriteColor = sprite.charColor
    End Select
End Function

'--------------------------------------------------------------------------
' Initializes a new sprite into the global SPRITES array and increments
' the SPRITE_COUNT so all initialized Sprites can be tracked.
'
' @param spriteType% One of the SPRITE_TYPE_{...} constants to specify the type.
' @param row% Row of the sprite's starting position.
' @param col% Col of the sprite's starting position.
'--------------------------------------------------------------------------
Sub AddSprite (spriteType%, row%, col%)
    '--- Clone sprite from the SPRITE_TYPE template
    Dim template As Sprite
    template = SPRITE_TYPES(spriteType%)
    SPRITES(SPRITE_COUNT) = template

    '--- Randomize frame positions and frameTimer so everything isn't in unison.
    SPRITES(SPRITE_COUNT).frame = Int(Rnd * template.maxFrame) + 1
    SPRITES(SPRITE_COUNT).frameRateTimer = Int(Rnd * template.frameRate)

    '--- Set the sprite position
    SPRITES(SPRITE_COUNT).position.row = row%
    SPRITES(SPRITE_COUNT).position.col = col%

    '--- Default to 1 life if none specified
    If template.lives = 0 Then SPRITES(SPRITE_COUNT).lives = 1

    '--- Register the SPRITES() index value of player sprites so we know which ones they are.
    If spriteType% = SPRITE_TYPE_PLAYER Then

        PLAYER_MAX = PLAYER_MAX + 1
        PLAYER(PLAYER_MAX).spriteIndex = SPRITE_COUNT
        PLAYER(PLAYER_MAX).startRow = row%
        PLAYER(PLAYER_MAX).startCol = col%
        SPRITES(SPRITE_COUNT).playerIndex = PLAYER_MAX
        SPRITES(SPRITE_COUNT).charColor = PLAYER(PLAYER_MAX).spriteColor
        SPRITE_COUNT = SPRITE_COUNT + 1

        '--- Recursively add player sprites until all players are added
        If (PLAYER_MAX < GAME_STATE.playerCount) Then
            AddSprite SPRITE_TYPE_PLAYER, row%, col%
        End If
    Else
        '--- Update sprite count so we know how many there are
        SPRITE_COUNT = SPRITE_COUNT + 1
    End If
End Sub

'--------------------------------------------------------------------------
' Returns the SPRITE_TYPE_{sprite_type} constant that specifies
' which type of sprite a character is.
'
' @param char$ Character to determing the sprite type for.
' @return Returns one of the SPRITE_TYPE global constants.
'--------------------------------------------------------------------------
Function GetSpriteType (char$)
    GetSpriteType = SPRITE_TYPE_NONE

    '--- Search all characters in all the SpriteTypes animation frames
    If char$ <> " " Then
        For spriteType = 1 To SPRITE_TYPES_MAX
            If SPRITE_TYPES(spriteType).levelDataChar = char$ Then
                GetSpriteType = spriteType
                Exit For
            End If
        Next spriteType
    End If
End Function

'--------------------------------------------------------------------------
' Plays the dumb little intro video when the game starts.  Can be bypassed
' by pressing a key on the keyboard.
'--------------------------------------------------------------------------
Sub IntroVid
    Cls 0
    m$ = "ASCII-MAN  "
    ClearInkey

    Play "MB O1 T160 P2 L8GG16F16B-G>CCC+D<G L16 GFGB-GFG"

    '--- Animate the letters dropping 1 at a time into the title
    For col = 1 To Len(m$)
        char$ = Right$(Left$(m$, col), 1)
        For row = 1 To 14
            If char$ <> "" Then Color 10 Else Color 14
            If row > 1 Then Locate row - 1, col + 30: Print " ";
            Locate row, col + 30: Print char$;
            _Limit 50
            If InKey$ <> "" Then Exit Sub
        Next row
    Next col

    '--- Animate drawing the horizontal bars
    Color 9
    For col = 1 To 80
        Locate 20, col: Print "Д";
        _Limit 180
        If InKey$ <> "" Then Exit Sub
    Next col
    For col = 1 To 80
        Locate 10, col: Print "Д";
        _Limit 180
        If InKey$ <> "" Then Exit Sub
    Next col

    '--- Animate ASCIIMAN running to the right
    Color 14
    For col = 42 To 80
        Locate 14, col - 1: Print " ";
        Locate 14, col: Print "";
        _Limit 30
        If InKey$ <> "" Then Exit Sub
    Next col
    Locate 14, 80: Print " ";

    '--- Animate the random char/color distortion blob at the top
    For i = 1 To 270
        r = Int(Rnd * 6) + 1
        c = Int(Rnd * 9) + 35
        Color (Int(Rnd * 15) + 1)
        Locate r, c: Print Chr$(Int(Rnd * 200) + 50);
        _Limit 180
        If InKey$ <> "" Then Exit Sub
    Next i

    '--- Make a giant ASCIIMAN appear where the distortion blob was
    Color 14
    Locate 1, 35: Print "  ЬЫЫЫЬ  ";
    Locate 2, 35: Print "ЬЫЫюЫюЫЫЬ";
    Locate 3, 35: Print "ЫЫЫЫЫЫЫЫЫ";
    Locate 4, 35: Print "ЫЫ ЯЯЯ ЫЫ";
    Locate 5, 35: Print "ЯЫЫ   ЫЫЯ";
    Locate 6, 35: Print "  ЯЫЫЫЯ  ";

    Color 15
    Locate 28, 30: Print "Press Any Key To Begin";
    Pause
End Sub

Sub DeadVid
    Cls 0
    Color CLR_LT_RED
    m$ = "Game Over"
    For col = 1 To Len(m$)
        char$ = Right$(Left$(m$, col), 1)
        For row = 1 To 14
            If row > 1 Then Locate row - 1, col + 30: Print " ";
            Locate row, col + 30: Print char$;
            _Limit 50
        Next row
    Next col

    Pause
End Sub


'==========================================================================
'                     GENERIC UTILITY FUNCTIONS
'==========================================================================

'--------------------------------------------------------------------------
' Clear the keyboard input buffer.
'--------------------------------------------------------------------------
Sub ClearInkey
    While InKey$ <> "": Wend
    While _DeviceInput: Wend
End Sub

'--------------------------------------------------------------------------
' Pause execution until any key is pressed.
'--------------------------------------------------------------------------
Sub Pause
    Sleep
    ClearInkey
End Sub

'--------------------------------------------------------------------------
' Initialize the screen to the proper mode and display settings.  Only
' needs to be run once when the program starts.
'--------------------------------------------------------------------------
Sub SetDisplayMode
    Screen 12: Cls 0
    _FullScreen _SquarePixels
End Sub

'--------------------------------------------------------------------------
' Print text using a specified position and color.
'
' @param row% Screen row to start printing the text
' @param col% Screen col to start printing the text
' @param text$ Text to render
'--------------------------------------------------------------------------
Sub PrintAt (row, col, textColor, text$)
    Color textColor
    Locate row, col
    Print text$;
End Sub

'--------------------------------------------------------------------------
' Replaces all instances of the [Find] sub-string with the [Add] sub-string
' within the [Text] string.
'
' @param Text The input string; the text that's being manipulated.
' @param Find The specified sub-string; the string sought within the [Text] string.
' @param Add The sub-string that's being added to the [Text] string.
'--------------------------------------------------------------------------
Function Replace$ (Text As String, Find As String, Add As String)
    Dim lngLocation As Long 'The address of the [Find] substring within the [Text] string.
    Dim strBefore As String 'The characters before the string to be replaced.
    Dim strAfter As String 'The characters after the string to be replaced.

    '--- INITIALIZE:
    lngLocation = InStr(1, Text, Find)

    '--- PROCESSING:
    '--- While [Find] appears in [Text]...
    While lngLocation
        'Extract all text before the [Find] substring:
        strBefore = Left$(Text, lngLocation - 1)
        'Extract all text after the [Find] substring:
        strAfter = Right$(Text, ((Len(Text) - (lngLocation + Len(Find) - 1))))
        'Return the substring:
        Text = strBefore + Add + strAfter
        'Locate the next instance of [Find]:
        lngLocation = InStr(1, Text, Find)
        'Next instance of [Find]...
    Wend

    '--- OUTPUT:
    Replace$ = Text
End Function

'--------------------------------------------------------------------------
' Reads a character from the screen at the specified position.
'
' @param row% Screen row to read.
' @param col% Screen col to read.
'--------------------------------------------------------------------------
Function CharAt$ (row, col)
    If row < GAME_AREA.min.row Or row > GAME_AREA.max.row Or col < GAME_AREA.min.col Or col > GAME_AREA.max.col Then
        CharAt$ = " "
    Else
        CharAt$ = Chr$(Screen(row, col))
    End If
End Function

'--------------------------------------------------------------------------
' Get the maximum of 2 integer values.
'
' @param valueA First value to compare.
' @param valueB Second value to compare.
' @return Maximum value between valueA and valueB
'--------------------------------------------------------------------------
Function GetMax (valueA, valueB)
    If (valueA > valueB) Then GetMax = valueA Else GetMax = valueB
End Function

'--------------------------------------------------------------------------
' Get the minimum of 2 integer values.
'
' @param valueA First value to compare.
' @param valueB Second value to compare.
' @return Minimum value between valueA and valueB
'--------------------------------------------------------------------------
Function GetMin (valueA, valueB)
    If (valueA < valueB) Then GetMin = valueA Else GetMin = valueB
End Function

'--------------------------------------------------------------------------
' Checks to see if a KeyMap's value indicates it is currently being pressed
' and hasn't been set to require release before receiving input again.
' To require a key to be released, call SUB KeyMapSetNeedsRelease
' anywhere in the game loop.
'
' @param keyMap KeyMap instance to check for input events.
'--------------------------------------------------------------------------
Function CheckKeyInput (keyMap As KeyMap)
    CheckKeyInput = 0

    If keyMap.needsRelease = 0 Then
        If keyMap.value >= keyMap.axisMin And keyMap.value <= keyMap.axisMax Then
            CheckKeyInput = 1
        End If
    End If
End Function

'--------------------------------------------------------------------------
' Reads input events from keyboards and game controllers and updates
' the values in the KEY_MAP array with the results.
'
' NOTE: Instead of checking KeyMap values directly for button/axis
' input events, use the FUNCTION CheckKeyInput(keyMap)
' which also verifies a key release is not required first.
'--------------------------------------------------------------------------
Sub GetKeyInput
    '--- Check for the first device with an input event
    deviceIndex = _DeviceInput

    While deviceIndex
        '--- Check all buttons on the device for events
        For b = 1 To _LastButton(deviceIndex)
            buttonChange! = _ButtonChange(b)
            If buttonChange! <> 0 Then
                SetKeyInput deviceIndex, INPUT_TYPE_BUTTON, b, buttonChange!
            End If
        Next

        '--- Update all axis on the device with the current readings
        For a = 1 To _LastAxis(deviceIndex)
            SetKeyInput deviceIndex, INPUT_TYPE_AXIS, a, _Axis(a)
        Next

        '--- Get the next device with an input event
        deviceIndex = _DeviceInput
    Wend
End Sub

'--------------------------------------------------------------------------
' Updates the KEY_MAP array with a new value, and clears the needsRelease
' field if the new value indicates the input event has stopped. Should be
' called when new input events are detected.
'
' @param deviceIndex Device number read from _DEVICEINPUT that has the new value.
' @param inputType One of INPUT_TYPE_{...} constants that the new value is for.
' @param inputIndex Button or Axis index on the device that the new value is for.
' @param value! New KeyMap input value to store.
'--------------------------------------------------------------------------
Sub SetKeyInput (deviceIndex, inputType, inputIndex, value!)
    '--- Check each player's inputs for events
    For k = 1 To KEY_MAPS
        If KEY_MAP(k).deviceIndex = deviceIndex And KEY_MAP(k).inputType = inputType And KEY_MAP(k).inputIndex = inputIndex Then
            KEY_MAP(k).value = value!

            '--- Clear the "need release" setting when the input value falls out of range
            If KEY_MAP(k).needsRelease Then
                If KEY_MAP(k).value < KEY_MAP(k).axisMin Or KEY_MAP(k).value > KEY_MAP(k).axisMax Then
                    KEY_MAP(k).needsRelease = 0
                End If
            End If
        End If
    Next k
End Sub

'--------------------------------------------------------------------------
' Clears the screen, displays a message, and terminates the program.
' Use when outputting debugging information when troubleshooting.
'
' @param msg$ Debugging output to display on-screen
'--------------------------------------------------------------------------
Sub Debug (msg$)
    If DEBUG_ON Then
        PrintAt SCREEN_AREA.max.row - 1, 1, 10, msg$
    End If
End Sub

'--------------------------------------------------------------------------
' Displays all the properties of a Sprite on-screen and pauses.
' Useful when debugging Sprite values.
'
' @param sprite Sprite data to display.
'--------------------------------------------------------------------------
Sub DebugSprite (sprite As Sprite)
    If DEBUG_ON Then
        Locate 1, 1
        Color 7, 0
        Print "spriteType: " + Str$(sprite.spriteType)
        Print "moveType: " + Str$(sprite.moveType)
        Print "frames: " + sprite.frames
        Print "frame: " + Str$(sprite.frame)
        Print "maxFrame: " + Str$(sprite.maxFrame)
        Print "frameRate: " + Str$(sprite.frameRate)
        Print "frameRateTimer: " + Str$(sprite.frameRateTimer)
        Print "charColor: " + Str$(sprite.charColor)
        Print "gravity: " + Str$(sprite.gravity)
        Print "gravityTimer: " + Str$(sprite.gravityTimer)
        Print "position.row: " + Str$(sprite.position.row)
        Print "position.col: " + Str$(sprite.position.col)
        Print "velocity.row: " + Str$(sprite.velocity.row)
        Print "velocity.col: " + Str$(sprite.velocity.col)
        Print "moveTo.row: " + Str$(sprite.moveTo.row)
        Print "moveTo.col: " + Str$(sprite.moveTo.col)
        Print "moveTimer: " + Str$(sprite.moveTimer)
        Print "lives: " + Str$(sprite.lives)
        Pause
        System
    End If
End Sub

'--------------------------------------------------------------------------
' Displays all the coordinate properties of a Sprite on-screen.
' Useful when debugging Sprite values. This was needed because the
' VWatch debugger can't handle nested user-defined TYPEs like Coord.
'
' @param spriteIndex Index of the Sprite in the SPRITES() array to display.
'--------------------------------------------------------------------------
Sub DebugSpriteCoords (spriteIndex, msg$)
    If DEBUG_ON Then
        Dim sprite As Sprite
        sprite = SPRITES(spriteIndex)

        Locate SCREEN_AREA.max.row - 1, 1
        Print msg$;
        Print " i:" + Str$(spriteIndex);
        Print " p.r:" + Str$(sprite.position.row);
        Print " p.c:" + Str$(sprite.position.col);
        Print " m.r:" + Str$(sprite.moveTo.row);
        Print " m.c:" + Str$(sprite.moveTo.col);
        Print " v.r:" + Str$(sprite.velocity.row);
        Print " v.c:" + Str$(sprite.velocity.col);
        Print " ";
    End If
End Sub

