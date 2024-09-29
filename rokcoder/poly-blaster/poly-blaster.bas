'======================================================================================================================================================================================================
' Poly Blaster
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Programmed by RokCoder
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' Took original inspiration from Physics Balls (Android)
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' V0.1 - 17/09/2024 - First release
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' https://github.com/rokcoder-qb64/poly-blaster
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' https://www.rokcoder.com
' https://www.github.com/rokcoder
' https://www.facebook.com/rokcoder
' https://www.youtube.com/rokcoder
'======================================================================================================================================================================================================
' TODO
' The OpenGL rendering functions were put togethe quickly and are frankly quite terrible. The scope for optimisation there is huge! It works fine for me as it is so I doubt
' that I'll be revisiting it any time soon.
' Attaching icon doesn't work for some reason.
'======================================================================================================================================================================================================

$VersionInfo:CompanyName='RokSoft'
$VersionInfo:FileDescription='QB64 Poly Blaster'
$VersionInfo:InternalName='poly-blaster.exe'
$VersionInfo:ProductName='Poly Blaster'
$VersionInfo:OriginalFilename='poly-blaster.exe'
$VersionInfo:LegalCopyright='(c)2024 RokSoft'
$VersionInfo:FILEVERSION#=0,1,0,0
$VersionInfo:PRODUCTVERSION#=0,1,0,0

'======================================================================================================================================================================================================

Option _Explicit
Option _ExplicitArray

'======================================================================================================================================================================================================

Const FALSE = 0
Const TRUE = Not FALSE

Const SCREEN_WIDTH = 480 ' Resolution of the unscaled game area
Const SCREEN_HEIGHT = 360
Const GAME_WIDTH = 324
Const MAX_COLUMNS = 7

Const VERSION = 1

Const SFX_BOOP = 0
Const SFX_CLICK = 1
Const SFX_GAMEOVER = 2

Const STATE_NEWGAME = 0 ' Different game states used in the game
Const STATE_SCROLL_POLYGONS = 1
Const STATE_AIM = 2
Const STATE_FIRE = 3
Const STATE_NEXT_ROW = 4
Const STATE_GAMEOVER = 5
Const STATE_WAIT_TO_START = 6

Const TARGET_BALLS = 10 'Number of balls to display in trajectory
Const LONG_TARGET_BALLS = 40 'Number of balls to display in trajectory when using extended target

Const GRAVITY! = -1! * 0.4! ' This should just be -0.4. However the current version of QB64PE has a bug (#542) in the CONST eval code!

Const POLY_RADIUS = 20
Const MAX_POLYS = 100 'This should be calculated but is definitely more than enough for a screen full of polygons
Const BALL_RADIUS = 6
Const MAX_BALLS = 50
Const LAUNCH_VELOCITY = 22

Const MAX_BONUSES = 100 'This should be calculated but is definitely more than enough for a screen full of bonuses
Const BONUS_RADIUS = 10

Const PROB_PLUS_ONE = 30
Const PROB_PLUS_TWO = 15
Const PROB_TIMES_TWO = 30
Const PROB_GROW = 15
Const PROB_SHRINK = 15
Const PROB_TOTAL = PROB_PLUS_ONE + PROB_PLUS_TWO + PROB_TIMES_TWO + PROB_GROW + PROB_SHRINK

Const BONUS_PLUS_ONE = 0
Const BONUS_PLUS_TWO = 1
Const BONUS_TIMES_TWO = 2
Const BONUS_GROW = 3
Const BONUS_SHRINK = 4

Const EASY = 0
Const MEDIUM = 1
Const HARD = 2

'======================================================================================================================================================================================================

Type HISCORE
    easy As Long
    medium As Long
    hard As Long
End Type

Type GAME
    rowCount As Integer
    activeBalls As Integer
    totalBalls As Integer
    totalBonuses As Integer
    totalPolys As Integer
    fps As Integer
    score As Long
    level As Integer
    longTarget As Integer
End Type

Type VECTORF
    x As Single
    y As Single
End Type

Type TARGET
    velocity As VECTORF
End Type

Type BALL
    delay As Integer '      Frames before ball is active (i.e. before it launches)
    pos As VECTORF '        Position of ball
    vel As VECTORF '        Velocity of ball
    multiplier As Integer ' Two damage when active
    size As Integer '       Regular is 0 but can alsp be -1 or +1
    trail1 As VECTORF '     Position of first ball in trail
    trail2 As VECTORF '     Position of second ball in trail
    trail3 As VECTORF '     Position of third ball in trail
    active As Integer
End Type

Type POLYDATA
    pos As VECTORF
    sides As Integer
    scale As Single
    angle As Single
    hits As Integer
    rotation As Single
    size As Single
    hitEffect As Integer
    r As Single
    g As Single
    b As Single
End Type

Type BONUSDATA
    pos As VECTORF
    type As Integer
    hitEffect As Integer
    hits As Integer
    scaleOffset As Integer
    transparency As Single
End Type

Type STATE
    state As Integer
    substate As Integer
    counter As Integer
End Type

Type GLDATA
    initialised As Integer
    executing As Integer
    background As Long
    ovelay As Long
    bubbleText As Long
    bonuses As Long
    start As Long
    easy As Long
    normal As Long
    difficult As Long
    easy_hi As Long
    normal_hi As Long
    hard_hi As Long
End Type

Type SFX
    handle As Long
    oneShot As Integer
    looping As Integer
End Type

'======================================================================================================================================================================================================

' Not a fan of globals but this is QB64 so what can you do?

Dim Shared target As TARGET
Dim Shared poly(MAX_POLYS) As POLYDATA
Dim Shared bonus(MAX_BONUSES) As BONUSDATA
Dim Shared state As STATE
Dim Shared ball(MAX_BALLS) As BALL
Dim Shared glData As GLDATA
Dim Shared virtualScreen& ' Handle to virtual screen which is drawn to and then blitted/stretched to the main display
Dim Shared game As GAME ' General game data
Dim Shared sfx(3) As SFX
Dim Shared quit As Integer
Dim Shared exitProgram As Integer
Dim Shared hiscore&(3)
Dim Shared trajectory(LONG_TARGET_BALLS) As VECTORF

'===== Game loop ======================================================================================================================================================================================

PrepareGame
Do: _Limit (game.fps%)
    UpdateFrame
    _PutImage , virtualScreen&, 0, (0, 0)-(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) ' Copy from virtual screen to target screen which allows for automatic upscaling
    _Display
    If exitProgram Then _FreeImage virtualScreen&: System
Loop

'===== Error handling =================================================================================================================================================================================

fileReadError:
InitialiseHiscore
Resume Next

fileWriteError:
On Error GoTo 0
Resume Next

'===== One time initialisations =======================================================================================================================================================================

Sub PrepareGame
    Dim m%
    quit = _Exit
    exitProgram = FALSE
    _DisplayOrder _Software
    m% = Int((_DesktopHeight - 80) / SCREEN_HEIGHT) ' Ratio for how much we can scale the game up (integer values) whilst still fitting vertically on the screen
    virtualScreen& = _NewImage(SCREEN_WIDTH, SCREEN_HEIGHT, 32) ' This is the same resolution as the original arcade game
    Screen _NewImage(SCREEN_WIDTH * m%, SCREEN_HEIGHT * m%, 32) ' The screen we ultimately display is the defined size multiplied by a ratio as determined above
    Do: _Delay 0.5: Loop Until _ScreenExists
    _ScreenMove _Middle
    $Resize:Stretch
    _AllowFullScreen _SquarePixels , _Smooth
    _Title "Poly Blaster"
    $ExeIcon:'./assets/poly-blaster.ico'
    _Dest virtualScreen&
    game.fps% = 30 ' 30 frames per second
    Randomize Timer
    glData.executing = TRUE
    _DisplayOrder _Hardware , _GLRender , _Software
    LoadAllSFX
    ReadHiscore ' Read high scores from file (or create them if the file doesn't exist or can't be read)
    SetGameState STATE_WAIT_TO_START ' Set the game state in its initial state
    game.level% = MEDIUM
    game.longTarget% = FALSE
End Sub

'===== High score code ================================================================================================================================================================================

' ReadHiscores
' - Read high scores from local storage (with fallback to initialising data if there's an error while reading the file for any reason)
Sub ReadHiscore
    Dim handle&, s&, v%
    On Error GoTo fileReadError
    If Not _FileExists("scores.txt") Then InitialiseHiscore: Exit Sub
    handle& = FreeFile
    Open "scores.txt" For Input As #handle&
    Input #handle&, s&
    If EOF(handle&) Then
        ' This was a high score file containing only hard level high score (before a version number was introduced)
        hiscore&(EASY) = 0
        hiscore&(MEDIUM) = 0
        hiscore&(HARD) = s&
    Else
        v% = s&
        Input #handle&, hiscore&(EASY)
        Input #handle&, hiscore&(MEDIUM)
        Input #handle&, hiscore&(HARD)
    End If
    Close #handle&
    On Error GoTo 0
End Sub

' InitialiseHiscores
' - Set up default high score values
Sub InitialiseHiscore
    hiscore&(EASY) = 0
    hiscore&(MEDIUM) = 0
    hiscore&(HARD) = 0
End Sub

' WriteHiscores
' - Store high scores to local storage (trapping any errors that might occur - write-protected, out of space, etc)
Sub WriteHiscore
    Dim handle&
    On Error GoTo fileWriteError
    handle& = FreeFile
    Open "scores.txt" For Output As #handle&
    Print #handle&, VERSION
    Print #handle&, hiscore&(EASY)
    Print #handle&, hiscore&(MEDIUM)
    Print #handle&, hiscore&(HARD)
    Close #handle&
    On Error GoTo 0
End Sub

'===== Simple asset loading functions =================================================================================================================================================================

Sub AssetError (fname$)
    Screen 0
    Print "Unable to load "; fname$
    Print "Please make sure EXE is in same folder as poly-blaster.bas"
    Print "(Set Run/Output EXE to Source Folder option in the IDE before compiling)"
    End
End Sub

Function LoadImage& (fname$)
    Dim asset&, f$
    f$ = "./assets/" + fname$ + ".png"
    asset& = _LoadImage(f$, 32)
    If asset& = -1 Then AssetError (f$)
    LoadImage& = asset&
End Function

Function SndOpen& (fname$)
    Dim asset&, f$
    f$ = "./assets/" + fname$
    asset& = _SndOpen(f$)
    If asset& = -1 Then AssetError (f$)
    SndOpen& = asset&
End Function

'===== Sound manager ==================================================================================================================================================================================

Sub LoadSfx (sfx%, sfx$, oneShot%)
    sfx(sfx%).handle& = _SndOpen("assets/" + sfx$ + ".ogg")
    If sfx(sfx%).handle& = 0 Then AssetError sfx$
    sfx(sfx%).oneShot% = oneShot%
End Sub

Sub LoadAllSFX
    LoadSfx SFX_BOOP, "boop", TRUE
    LoadSfx SFX_CLICK, "click", TRUE
    LoadSfx SFX_GAMEOVER, "game over", TRUE
End Sub

Sub PlaySfx (sfx%)
    If sfx(sfx%).oneShot% Then
        _SndPlay sfx(sfx%).handle&
    Else
        _SndPlayCopy sfx(sfx%).handle&
    End If
End Sub

Sub PlaySfxLooping (sfx%)
    If sfx(sfx%).oneShot% Then
        _SndLoop sfx(sfx%).handle&
    End If
End Sub

Sub StopSfx (sfx%)
    If sfx(sfx%).oneShot% Then _SndStop sfx(sfx%).handle&
End Sub

Function IsPlayingSfx% (sfx%)
    IsPlayingSfx% = _SndPlaying(sfx(sfx%).handle&)
End Function

'======================================================================================================================================================================================================

Sub SetGameState (s%)
    state.state% = s%
    state.substate% = 0
    state.counter% = 0
    If s% = STATE_NEWGAME Then InitialiseGame: SetGameState STATE_NEXT_ROW
    If s% = STATE_NEXT_ROW Then AddRow: SetGameState STATE_SCROLL_POLYGONS
    If s% = STATE_GAMEOVER Then WriteHiscore
End Sub

Sub InitialiseGame
    game.rowCount% = 0
    game.totalBalls% = 0
    game.activeBalls% = 0
    game.totalPolys% = 0
    game.totalBonuses% = 0
    game.score& = 0
End Sub

'======================================================================================================================================================================================================

Sub UpdateFrame
    Do While _MouseInput: Loop
    If state.state% = STATE_SCROLL_POLYGONS Then ScrollPolygons: ScrollBonuses: UpdateAllPolys: UpdateAllBonuses
    If state.state% = STATE_AIM Then GetTargetDirection: UpdateAllPolys: UpdateAllBonuses
    If state.state% = STATE_FIRE Then LaunchBalls: UpdateAllPolys: UpdateAllBonuses
    If state.state% = STATE_GAMEOVER Then GameOver
    If state.state% = STATE_WAIT_TO_START Then WaitToStart
    state.counter% = state.counter% + 1
End Sub

'======================================================================================================================================================================================================

Function difficulty%
    Dim mousePos As VECTORF
    mousePos.x! = _MouseX - _Width(0) / 2
    mousePos.y! = _Height(0) / 2 - _MouseY
    Dim w%, h%, i%
    w% = 119 * _Width(0) / SCREEN_WIDTH
    h% = 20 * _Height(0) / SCREEN_HEIGHT
    difficulty% = -1
    If Not Abs(mousePos.x!) < w% Then Exit Function
    For i% = 0 To 2
        If mousePos.y! < -12 - 98 * i% + h% And mousePos.y! > -12 - 98 * i% - h% Then difficulty% = i%: Exit Function
    Next i%
End Function

Sub WaitToStart
    Static mouseDown%, selected%
    If _MouseButton(1) And Not mouseDown% Then
        selected% = difficulty%
    Else
        If Not _MouseButton(1) And mouseDown% Then
            If selected% > -1 Then
                If selected% = difficulty% Then
                    game.level% = selected%
                    SetGameState STATE_NEWGAME
                    mouseDown% = FALSE
                    selected% = -1
                    Exit Sub
                Else
                    selected% = -1
                End If
            End If
        End If
    End If
    mouseDown% = _MouseButton(1)
    If Not mouseDown% Then selected% = -1
End Sub

Sub GameOver
    If state.counter% = 30 Then SetGameState STATE_WAIT_TO_START
End Sub

'======================================================================================================================================================================================================

Sub GetTargetDirection
    ' Calculations ensure that ball trajectory passes through mouse pointer position
    Dim mousePos As VECTORF
    Dim screenScale!
    Dim launchAngle!
    Dim deltaPos As VECTORF
    screenScale! = _Width / _Width(0)
    mousePos.x! = screenScale! * (_MouseX - _Width(0) / 2)
    mousePos.y! = screenScale! * _MouseY
    deltaPos.x! = Abs(mousePos.x!)
    deltaPos.y! = -mousePos.y!
    If GRAVITY ^ 2 * deltaPos.x! ^ 2 = 0 Then
        launchAngle! = -_Pi / 2
    Else
        launchAngle! = Atn(-LAUNCH_VELOCITY ^ 2 / (GRAVITY * deltaPos.x!) - Sqr(LAUNCH_VELOCITY ^ 2 * (LAUNCH_VELOCITY ^ 2 + 2 * GRAVITY * deltaPos.y!) / (GRAVITY ^ 2 * deltaPos.x! ^ 2) - 1))
    End If
    target.velocity.x! = Cos(launchAngle!) * LAUNCH_VELOCITY
    target.velocity.y! = Sin(launchAngle!) * LAUNCH_VELOCITY
    If mousePos.x! < 0 Then target.velocity.x! = -target.velocity.x!
    If game.longTarget% Then CalculateTrajectory
    If _MouseButton(1) Then SetGameState STATE_FIRE
End Sub

Sub CalculateTrajectory
    Dim i%
    ball(0).vel = target.velocity
    ball(0).pos.x! = 0
    ball(0).pos.y! = _Height / 2
    ball(0).delay% = 0
    ball(0).size% = 0
    For i% = 0 To LONG_TARGET_BALLS
        trajectory(i%) = ball(0).pos
        UpdateBall ball(0)
    Next
End Sub

'======================================================================================================================================================================================================

Sub CreateBonus (bonus As BONUSDATA, xpos%)
    Dim r%
    r% = Int(Rnd * PROB_TOTAL)
    If r% < PROB_PLUS_ONE Then
        If game.totalBalls% + 1 > MAX_BALLS Then Exit Sub
        bonus.type = BONUS_PLUS_ONE
    Else
        r% = r% - PROB_PLUS_ONE
        If r% < PROB_PLUS_TWO Then
            If game.totalBalls% + 2 > MAX_BALLS Then Exit Sub
            bonus.type = BONUS_PLUS_TWO
        Else
            r% = r% - PROB_PLUS_TWO
            If r% < PROB_TIMES_TWO Then
                bonus.type = BONUS_TIMES_TWO
            Else
                r% = r% - PROB_TIMES_TWO
                If r% < PROB_GROW Then
                    bonus.type = BONUS_GROW
                Else
                    bonus.type = BONUS_SHRINK
                End If
            End If
        End If
    End If
    bonus.pos.x! = xpos%
    bonus.pos.y! = -200
    bonus.hitEffect% = 0
    bonus.hits% = 1
    bonus.scaleOffset% = game.totalBonuses% * 167
    bonus.transparency! = 1
    game.totalBonuses% = game.totalBonuses% + 1
End Sub

Sub ScrollBonuses
    Dim i%
    i% = 0
    While i% < game.totalBonuses%
        bonus(i%).pos.y! = bonus(i%).pos.y! + 3
        If bonus(i%).pos.y! > -200 + 7 * 45 Then
            bonus(i%).transparency! = bonus(i%).transparency! - 1.0 / 15
            If bonus(i%).transparency! < 0 Then
                game.totalBonuses% = game.totalBonuses% - 1
                bonus(i%) = bonus(game.totalBonuses%)
                _Continue
            End If
        End If
        i% = i% + 1
    Wend
End Sub

Sub UpdateAllBonuses
    Dim i%
    i% = 0
    While i% < game.totalBonuses%
        If bonus(i%).hitEffect% > 0 Then
            bonus(i%).hitEffect% = bonus(i%).hitEffect% - 2
            If bonus(i%).hitEffect% = 0 And bonus(i%).hits% <= 0 Then
                game.totalBonuses% = game.totalBonuses% - 1
                bonus(i%) = bonus(game.totalBonuses%)
                _Continue
            End If
        End If
        i% = i% + 1
    Wend
End Sub

Sub SpawnBallAtAngle (ball As BALL, angle%)
    Dim vel As VECTORF
    vel.x! = 6 * Sin(angle% * _Pi / 180)
    vel.y! = 6 * Cos(angle% * _Pi / 180)
    CreateBall ball.pos, 0, vel, 1, 0
End Sub

Sub HitBonus (bonus As BONUSDATA, ball As BALL)
    Select Case bonus.type%
        Case BONUS_PLUS_ONE
            If game.totalBalls% + 1 > MAX_BALLS Then Exit Sub
        Case BONUS_PLUS_TWO
            If game.totalBalls% + 2 > MAX_BALLS Then Exit Sub
        Case BONUS_TIMES_TWO
            If ball.multiplier% = 2 Then Exit Sub
        Case BONUS_GROW
            If ball.size% = 2 Then Exit Sub
        Case BONUS_SHRINK
            If ball.size% = -2 Then Exit Sub
    End Select

    Select Case bonus.type%
        Case BONUS_PLUS_ONE
            SpawnBallAtAngle ball, 0
        Case BONUS_PLUS_TWO
            SpawnBallAtAngle ball, -30
            SpawnBallAtAngle ball, 30
        Case BONUS_TIMES_TWO
            ball.multiplier% = 2
        Case BONUS_GROW
            ball.size% = ball.size% + 2
        Case BONUS_SHRINK
            ball.size% = ball.size% - 2
    End Select
    bonus.hits% = 0
    bonus.hitEffect% = 50
    PlaySfx SFX_BOOP
End Sub

Sub CheckForBallAgainstAllBonuses (ball As BALL)
    Dim id%
    id% = NearestBonusId%(ball)
    If id% > -1 Then
        HitBonus bonus(id%), ball
    End If
End Sub

Function NearestBonusId% (ball As BALL)
    Dim id%, nearestDistance2&, i%, distance2&
    Dim deltaVec As VECTORF
    id% = -1
    nearestDistance2& = (POLY_RADIUS + (BALL_RADIUS + ball.size%)) ^ 2 ' We're only interested when they are close enough to actually collide
    For i% = 0 To game.totalBonuses% - 1
        If bonus(i%).hits% > 0 Then ' This is here because a hit effect could be taking place even if the bonus has been destroyed
            VectorSub deltaVec, bonus(i%).pos, ball.pos
            distance2& = GetMagnitude2!(deltaVec)
            If distance2& < nearestDistance2& Then
                nearestDistance2& = distance2&
                id% = i%
            End If
        End If
    Next
    If nearestDistance2& < (BONUS_RADIUS + (BALL_RADIUS + ball.size%)) ^ 2 Then
        NearestBonusId% = id%
    Else
        NearestBonusId% = -1
    End If
End Function

'======================================================================================================================================================================================================

Sub AddRow
    Dim points%, columns%, distribution%(MAX_COLUMNS - 1), c%, p%, i%, m!, columnWidth!, deltaRot!
    columnWidth! = GAME_WIDTH / MAX_COLUMNS
    columns% = MAX_COLUMNS - game.rowCount% Mod 2
    points% = columns% + game.rowCount% * 3
    While points% > 0
        c% = Int(Rnd * columns%)
        p% = Int(Rnd * (points% - 1)) + 1
        distribution%(c%) = distribution%(c%) + p%
        points% = points% - p%
    Wend
    For i% = 0 To columns% - 1
        If distribution%(i%) > 0 Then
            If Rnd < game.rowCount% / 200 Then
                deltaRot! = Rnd * Int(game.rowCount% / 8) / 16 - Int(game.rowCount% / 8) / 32
            Else
                If Rnd * 100 < 5 Then
                    If Rnd * 100 < 50 Then
                        deltaRot! = -0.6 + Rnd * 0.3
                    Else
                        deltaRot! = 0.3 + Rnd * 0.3
                    End If
                Else
                    deltaRot! = 0
                End If
            End If
            CreatePoly poly(game.totalPolys%), -GAME_WIDTH / 2 + columnWidth! * (i% + (1 + game.rowCount% Mod 2) / 2), distribution%(i%), deltaRot!
        Else
            If game.rowCount% < 5 Then
                m! = 0.5
            Else
                If game.level = EASY Then
                    m! = 0.5
                ElseIf game.level = MEDIUM Then
                    If game.rowCount% < 35 Then
                        m! = 0.5 - (0.5 - 0.10) / 30 * (game.rowCount% - 4)
                    Else
                        m! = 0.10
                    End If
                Else
                    m! = 0.15
                End If
            End If
            If Rnd < m! Then
                CreateBonus bonus(game.totalBonuses%), -GAME_WIDTH / 2 + columnWidth! * (i% + (1 + game.rowCount% Mod 2) / 2)
            End If
        End If
    Next
    game.rowCount% = game.rowCount% + 1
End Sub

Sub CreatePoly (poly As POLYDATA, xpos%, hits%, deltaRot!)
    poly.pos.x! = xpos%
    poly.pos.y! = -200
    poly.scale! = 1
    poly.angle! = Rnd * 360
    poly.hits% = hits%
    poly.hitEffect% = 0
    poly.rotation! = deltaRot!
    poly.sides% = Int(Rnd * 5) + 3
    poly.size! = POLY_RADIUS
    poly.r! = 0.5 + Rnd / 2
    poly.g! = 0.5 + Rnd / 2
    poly.b! = 0.5 + Rnd / 2
    game.totalPolys% = game.totalPolys% + 1
End Sub

Sub HitPoly (poly As POLYDATA, damage%)
    Dim d%
    If damage% > poly.hits% Then
        d% = poly.hits%
    Else
        d% = damage%
    End If
    poly.hits% = poly.hits% - d%
    If poly.hits% <= 0 Then
        poly.hitEffect% = 50
    Else
        poly.hitEffect% = 20
    End If
    game.score& = game.score& + d% * 5
    If game.score& > hiscore&(game.level%) Then hiscore&(game.level%) = game.score&
End Sub

Sub ScrollPolygons
    Dim i%
    Dim over%
    over% = FALSE
    For i% = 0 To game.totalPolys% - 1
        poly(i%).pos.y! = poly(i%).pos.y! + 3
        If poly(i%).pos.y! > 140 Then
            over% = TRUE
        End If
    Next
    If state.counter% = 15 Then
        If over% Then
            SetGameState STATE_GAMEOVER
            PlaySfx SFX_GAMEOVER
        Else
            SetGameState STATE_AIM
        End If
    End If
End Sub

Sub UpdateAllPolys
    Dim i%
    i% = 0
    While i% < game.totalPolys%
        If poly(i%).hitEffect% > 0 Then
            poly(i%).hitEffect% = poly(i%).hitEffect% - 2
            If poly(i%).hitEffect% = 0 And poly(i%).hits% <= 0 Then
                game.totalPolys% = game.totalPolys% - 1
                poly(i%) = poly(game.totalPolys%)
                _Continue
            End If
        End If
        poly(i%).angle! = poly(i%).angle + poly(i%).rotation!
        i% = i% + 1
    Wend
End Sub

Function CheckForBallAgainstAllPolys% (ball As BALL)
    Dim id%
    CheckForBallAgainstAllPolys% = FALSE
    id% = NearestPolyId%(ball) ' In theory it's not necessarily going to be the closest poly in all cases - it's accurate enough for this game
    If id% > -1 Then
        Dim collision%, normal As VECTORF
        CheckBallAgainstPoly ball, id%, collision%, normal
        If collision% Then
            CheckForBallAgainstAllPolys% = TRUE
            CalculateBounceTrajectory ball.vel, normal
            If state.state% = STATE_FIRE Then HitPoly poly(id%), ball.multiplier%: PlaySfx SFX_CLICK
        End If
    End If
End Function

Sub CalculateBounceTrajectory (ballVelocity As VECTORF, unitNormal As VECTORF)
    Dim dotProduct!
    dotProduct! = ballVelocity.x! * unitNormal.x! + ballVelocity.y! * unitNormal.y!
    ballVelocity.x! = (ballVelocity.x! - 2 * dotProduct! * unitNormal.x) * 0.6
    ballVelocity.y! = (ballVelocity.y! - 2 * dotProduct! * unitNormal.y) * 0.6
    EnsureMinimumVelocity ballVelocity, 2
End Sub

Sub EnsureMinimumVelocity (velocity As VECTORF, minVel!)
    Dim v!
    v! = GetMagnitude(velocity)
    If v! < minVel! Then
        v! = (Rnd * 2 + 7.8) / v!
        velocity.x! = velocity.x! * v!
        velocity.y! = velocity.y! * v!
    End If
End Sub

Function NearestPolyId% (ball As BALL)
    Dim id%, nearestDistance2&, i%, distance2&
    Dim deltaVec As VECTORF
    id% = -1
    nearestDistance2& = (POLY_RADIUS + (BALL_RADIUS + ball.size%)) ^ 2 ' We're only interested when they are close enough to actually collide
    For i% = 0 To game.totalPolys% - 1
        If poly(i%).hits% > 0 Then ' This is here because a hit effect could be taking place even if the poly has been destroyed
            VectorSub deltaVec, poly(i%).pos, ball.pos
            distance2& = GetMagnitude2!(deltaVec)
            If distance2& < nearestDistance2& Then
                nearestDistance2& = distance2&
                id% = i%
            End If
        End If
    Next
    NearestPolyId% = id%
End Function

Sub CheckBallAgainstPoly (ball As BALL, polyIndex%, outCollision%, outNormal As VECTORF)
    outCollision% = FALSE
    Dim p1 As VECTORF, p2 As VECTORF
    Dim angle!, i%, p1CrossProductZ!, p2CrossProductZ!
    Dim pCentreDelta As VECTORF
    Dim ballCentreDelta As VECTORF
    Dim lineSegment As VECTORF, lineLength!, lineLength2!
    Dim dotProduct!
    Dim p1BallDelta As VECTORF
    Dim distance As VECTORF
    Dim nearestDistance!, nearestDistance2!
    VectorSub ballCentreDelta, ball.pos, poly(polyIndex%).pos
    ' Check against collision with sides of polygon
    angle! = poly(polyIndex%).angle! * _Pi / 180
    p1.x! = poly(polyIndex%).pos.x! + Cos(angle!) * poly(polyIndex%).size!
    p1.y! = poly(polyIndex%).pos.y! + Sin(angle!) * poly(polyIndex%).size!
    VectorSub pCentreDelta, p1, poly(polyIndex%).pos
    p1CrossProductZ! = pCentreDelta.x! * ballCentreDelta.y! - pCentreDelta.y! * ballCentreDelta.x!
    For i% = 0 To poly(polyIndex%).sides% - 1
        angle! = angle! + _Pi(2) / poly(polyIndex%).sides%
        p2.x! = poly(polyIndex%).pos.x! + Cos(angle!) * poly(polyIndex%).size!
        p2.y! = poly(polyIndex%).pos.y! + Sin(angle!) * poly(polyIndex%).size!
        VectorSub pCentreDelta, p2, poly(polyIndex%).pos
        p2CrossProductZ! = pCentreDelta.x! * ballCentreDelta.y! - pCentreDelta.y! * ballCentreDelta.x!
        ' Are we in the correct segment for collision with this line (using cross product to determine Z to test clockwise/anticlockwise for each point)?
        If p1CrossProductZ! > 0 And p2CrossProductZ! < 0 Then
            ' Find closest position to segment line
            Dim closest As VECTORF
            VectorSub lineSegment, p2, p1
            lineLength2! = GetMagnitude2!(lineSegment)
            lineLength! = Sqr(lineLength2!)
            VectorSub p1BallDelta, ball.pos, p1
            dotProduct! = (p1BallDelta.x! * lineSegment.x! + p1BallDelta.y! * lineSegment.y!) / lineLength2!
            ' Determine if this is within the bounds of the line
            If dotProduct! >= 0 And dotProduct! <= 1 Then
                closest.x! = p1.x! + dotProduct! * lineSegment.x!
                closest.y! = p1.y! + dotProduct! * lineSegment.y!
                VectorSub distance, closest, ball.pos
                nearestDistance2! = GetMagnitude2(distance)
                If nearestDistance2! < (BALL_RADIUS + ball.size%) ^ 2 Then
                    outCollision% = TRUE
                    ' Calculate normal of line for bounce calculations
                    outNormal.x! = lineSegment.y! / lineLength!
                    outNormal.y! = -lineSegment.x! / lineLength!
                    ' Push ball out of collision
                    nearestDistance! = Sqr(nearestDistance2!)
                    ball.pos.x! = ball.pos.x! + outNormal.x! * (((BALL_RADIUS + ball.size%) + 2) - nearestDistance!)
                    ball.pos.y! = ball.pos.y! + outNormal.y! * (((BALL_RADIUS + ball.size%) + 2) - nearestDistance!)
                    Exit Sub
                End If
            End If
        End If
        p1 = p2
        p1CrossProductZ! = p2CrossProductZ!
    Next
    ' Check against corners
    angle! = poly(polyIndex%).angle! * _Pi / 180
    For i% = 0 To poly(polyIndex%).sides% - 1
        p1.x! = poly(polyIndex%).pos.x! + Cos(angle!) * poly(polyIndex%).size!
        p1.y! = poly(polyIndex%).pos.y! + Sin(angle!) * poly(polyIndex%).size!
        VectorSub distance, ball.pos, p1
        nearestDistance2! = GetMagnitude2(distance)
        If nearestDistance2! < (BALL_RADIUS + ball.size%) ^ 2 Then
            outCollision% = TRUE
            nearestDistance! = Sqr(nearestDistance2!)
            outNormal.x! = distance.x! / nearestDistance!
            outNormal.y! = distance.y! / nearestDistance!
            ' Push ball out of collision
            ball.pos.x! = ball.pos.x! + outNormal.x! * (((BALL_RADIUS + ball.size%) + 2) - nearestDistance!)
            ball.pos.y! = ball.pos.y! + outNormal.y! * (((BALL_RADIUS + ball.size%) + 2) - nearestDistance!)
            Exit Sub
        End If
        angle! = angle! + _Pi(2) / poly(polyIndex%).sides%
    Next
End Sub

'======================================================================================================================================================================================================

Sub CreateBall (p As VECTORF, delay%, vel As VECTORF, multiplier%, size%)
    ball(game.totalBalls%).vel = vel
    ball(game.totalBalls%).pos = p
    ball(game.totalBalls%).multiplier% = multiplier%
    ball(game.totalBalls%).trail1 = ball(game.totalBalls%).pos
    ball(game.totalBalls%).trail2 = ball(game.totalBalls%).pos
    ball(game.totalBalls%).trail3 = ball(game.totalBalls%).pos
    ball(game.totalBalls%).delay% = delay%
    ball(game.totalBalls%).size% = size%
    ball(game.totalBalls%).active% = TRUE
    game.activeBalls% = game.activeBalls% + 1
    game.totalBalls% = game.totalBalls% + 1
End Sub

Sub LaunchBalls
    Dim i%, t%
    Dim p As VECTORF
    If state.counter% = 0 Then ' On the first frame, initialise all balls to launch in sequence
        p.x = 0
        p.y = _Height / 2
        If game.totalBalls% = 0 Then
            CreateBall p, i% * 4, target.velocity, 1, 0
        Else
            t% = game.totalBalls%
            game.totalBalls% = 0
            For i% = 0 To t% - 1
                CreateBall p, i% * 4, target.velocity, ball(i%).multiplier%, ball(i%).size%
            Next
        End If
    End If
    UpdateAllBalls
    If game.activeBalls% = 0 Then SetGameState STATE_NEXT_ROW
End Sub

Sub UpdateAllBalls
    Dim ball%
    ball% = 0
    While ball% < game.totalBalls%
        If ball(ball%).active Then
            UpdateBall ball(ball%)
            If ball(ball%).trail3.y! <= -200 Then
                ball(ball%).active = FALSE
                game.activeBalls% = game.activeBalls% - 1
            End If
        End If
        ball% = ball% + 1
    Wend
End Sub

Sub UpdateBall (ball As BALL)
    Dim i%
    Dim mag!, deltaMag!
    Dim unitVel As VECTORF
    If ball.delay% = 0 Then
        ball.trail3 = ball.trail2
        ball.trail2 = ball.trail1
        ball.trail1 = ball.pos
        ball.vel.y! = ball.vel.y! + GRAVITY!
        mag! = GetMagnitude!(ball.vel)
        unitVel.x! = ball.vel.x! / mag!
        unitVel.y! = ball.vel.y! / mag!
        deltaMag! = mag! / Ceiling(mag!)
        For i% = 1 To Ceiling(mag!)
            ball.pos.x! = ball.pos.x! + unitVel.x! * deltaMag!
            ball.pos.y! = ball.pos.y! + unitVel.y! * deltaMag!
            If state.state% = STATE_FIRE Then CheckForBallAgainstAllBonuses ball
            If CheckForBallAgainstAllPolys%(ball) Then
                Exit Sub ' We've collided with a poly so it's been updated and there's nothing else to do with this ball
            End If
            If Abs(ball.pos.x!) > GAME_WIDTH / 2 Then
                ball.vel.x! = -ball.vel.x!
                ball.pos.x! = Sgn(ball.pos.x!) * GAME_WIDTH / 2
                Exit Sub ' We've collided with a wall so it's been updated and there's nothing else to do with this ball
            End If
        Next
    Else
        ball.delay% = ball.delay% - 1
    End If
End Sub

'======================================================================================================================================================================================================

Function GetMagnitude! (vec As VECTORF)
    GetMagnitude! = Sqr(GetMagnitude2!(vec))
End Function

Function GetMagnitude2! (vec As VECTORF)
    GetMagnitude2! = vec.x! * vec.x! + vec.y! * vec.y!
End Function

Function Ceiling% (num!)
    Ceiling% = Abs(Int(0 - num!))
End Function

Sub VectorSub (vecOut As VECTORF, vec1 As VECTORF, vec2 As VECTORF)
    vecOut.x! = vec1.x! - vec2.x!
    vecOut.y! = vec1.y! - vec2.y!
End Sub

'======================================================================================================================================================================================================

Sub RenderBackground
    _glColor4f 1, 1, 1, 0
    _glEnable _GL_TEXTURE_2D
    _glBindTexture _GL_TEXTURE_2D, glData.background&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f -240, 180
    _glTexCoord2f 1, 1
    _glVertex2f 240, 180
    _glTexCoord2f 1, 0
    _glVertex2f 240, -180
    _glTexCoord2f 0, 0
    _glVertex2f -240, -180
    _glEnd
    _glDisable _GL_TEXTURE_2D
End Sub

Sub RenderOverlay
    Dim tex&
    _glColor4f 1, 1, 1, 1
    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _glBindTexture _GL_TEXTURE_2D, glData.ovelay&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f -240, 180
    _glTexCoord2f 1, 1
    _glVertex2f 240, 180
    _glTexCoord2f 1, 0
    _glVertex2f 240, -180
    _glTexCoord2f 0, 0
    _glVertex2f -240, -180
    _glEnd
    RenderHi 37, 117, glData.easy_hi&
    RenderHi 37, 17, glData.normal_hi&
    RenderHi 37, -83, glData.hard_hi&
    If game.level% = EASY Then
        tex& = glData.easy_hi&
    ElseIf game.level% = MEDIUM Then
        tex& = glData.normal_hi&
    Else
        tex& = glData.hard_hi&
    End If
    RenderHi 202 + _Width / 2, 117, tex&
    _glDisable _GL_BLEND
    _glDisable _GL_TEXTURE_2D
End Sub

Sub RenderHi (x%, y%, tex&)
    Dim halfw!, halfh!
    halfw! = 67 / 2
    halfh! = 42 / 2
    x% = x% - _Width / 2
    y% = y%
    _glBindTexture _GL_TEXTURE_2D, tex&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f x% - halfw!, y% + halfh!
    _glTexCoord2f 1, 1
    _glVertex2f x% + halfw!, y% + halfh!
    _glTexCoord2f 1, 0
    _glVertex2f x% + halfw!, y% - halfh!
    _glTexCoord2f 0, 0
    _glVertex2f x% - halfw!, y% - halfh!
    _glEnd
End Sub

Sub RenderStart
    Dim d%
    d% = difficulty%
    _glColor4f 1, 1, 1, 1
    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _glBindTexture _GL_TEXTURE_2D, glData.start&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f -103, 127
    _glTexCoord2f 1, 1
    _glVertex2f 103, 127
    _glTexCoord2f 1, 0
    _glVertex2f 103, -127
    _glTexCoord2f 0, 0
    _glVertex2f -103, -127
    _glEnd
    If d% = EASY Then _glColor3f 1, 1, 1 Else _glColor3f 0.5, 0.5, 0.5
    _glBindTexture _GL_TEXTURE_2D, glData.easy&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f -103, 127
    _glTexCoord2f 1, 1
    _glVertex2f 103, 127
    _glTexCoord2f 1, 0
    _glVertex2f 103, -127
    _glTexCoord2f 0, 0
    _glVertex2f -103, -127
    _glEnd
    If d% = MEDIUM Then _glColor3f 1, 1, 1 Else _glColor3f 0.5, 0.5, 0.5
    _glBindTexture _GL_TEXTURE_2D, glData.normal&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f -103, 127
    _glTexCoord2f 1, 1
    _glVertex2f 103, 127
    _glTexCoord2f 1, 0
    _glVertex2f 103, -127
    _glTexCoord2f 0, 0
    _glVertex2f -103, -127
    _glEnd
    If d% = HARD Then _glColor3f 1, 1, 1 Else _glColor3f 0.5, 0.5, 0.5
    _glBindTexture _GL_TEXTURE_2D, glData.difficult&
    _glBegin _GL_QUADS
    _glTexCoord2f 0, 1
    _glVertex2f -103, 127
    _glTexCoord2f 1, 1
    _glVertex2f 103, 127
    _glTexCoord2f 1, 0
    _glVertex2f 103, -127
    _glTexCoord2f 0, 0
    _glVertex2f -103, -127
    _glEnd
    _glDisable _GL_BLEND
    _glDisable _GL_TEXTURE_2D
End Sub

Sub RenderNumber (binding&, number&, centreX%, centreY%, charSize%, r%, g%, b%)
    Dim x%, d%, d$, tx!
    d$ = LTrim$(Str$(number&))
    d% = Len(d$)
    x% = centreX% + (d% - 1) * charSize% / 2
    _glColor4f r%, g%, b%, 1
    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _glBindTexture _GL_TEXTURE_2D, binding&
    _glBegin _GL_QUADS
    While d% > 0
        tx! = Val(Mid$(d$, d%, 1)) / 10
        _glTexCoord2f tx!, 1
        _glVertex2f x% - charSize% / 2, centreY% + charSize% / 2
        _glTexCoord2f tx! + 0.1, 1
        _glVertex2f x% + charSize% / 2, centreY% + charSize% / 2
        _glTexCoord2f tx! + 0.1, 0
        _glVertex2f x% + charSize% / 2, centreY% - charSize% / 2
        _glTexCoord2f tx!, 0
        _glVertex2f x% - charSize% / 2, centreY% - charSize% / 2
        d% = d% - 1
        x% = x% - charSize%
    Wend
    _glEnd
    _glDisable _GL_BLEND
    _glDisable _GL_TEXTURE_2D
End Sub

Sub SetGameOverTint (r!, g!, b!, a!)
    Dim j%
    If state.state% = STATE_GAMEOVER Or state.state% = STATE_WAIT_TO_START Then
        If state.state% = STATE_GAMEOVER Then
            j% = 40 - state.counter%
        Else
            j% = 10
        End If
        _glColor4f r! * j% / 40, g! * j% / 40, b! * j% / 40, a!
    Else
        _glColor4f r!, g!, b!, a!
    End If
End Sub

Sub RenderBonusEffects
    Dim i%
    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _glBindTexture _GL_TEXTURE_2D, glData.bonuses&
    For i% = 0 To game.totalBonuses% - 1
        If bonus(i%).hitEffect% > 0 Then
            _glPushMatrix
            _glTranslatef bonus(i%).pos.x!, bonus(i%).pos.y!, 0
            _glScalef 1 + (50 - bonus(i%).hitEffect%) / 6, 1 + (50 - bonus(i%).hitEffect%) / 6, 1
            _glColor4f 1, 1, 1, bonus(i%).hitEffect% / 50
            _glBegin _GL_QUADS
            _glTexCoord2f 0.2 * bonus(i%).type, 1
            _glVertex2f -BONUS_RADIUS, BONUS_RADIUS
            _glTexCoord2f 0.2 + 0.2 * bonus(i%).type, 1
            _glVertex2f BONUS_RADIUS, BONUS_RADIUS
            _glTexCoord2f 0.2 + 0.2 * bonus(i%).type, 0
            _glVertex2f BONUS_RADIUS, -BONUS_RADIUS
            _glTexCoord2f 0.2 * bonus(i%).type, 0
            _glVertex2f -BONUS_RADIUS, -BONUS_RADIUS
            _glEnd
            _glPopMatrix
        End If
    Next
    _glDisable _GL_BLEND
    _glDisable _GL_TEXTURE_2D
End Sub

Sub RenderBonuses
    Dim i%
    _glEnable _GL_TEXTURE_2D
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    _glBindTexture _GL_TEXTURE_2D, glData.bonuses&
    For i% = 0 To game.totalBonuses% - 1
        If bonus(i%).hits% > 0 Then
            _glPushMatrix
            _glTranslatef bonus(i%).pos.x!, bonus(i%).pos.y!, 0
            If state.state% = STATE_GAMEOVER Or state.state% = STATE_WAIT_TO_START Then
                _glScalef 1, 1, 1
            Else
                _glScalef 1 + 0.04 * Cos((bonus(i%).scaleOffset + Timer * 200) * _Pi / 180), 1 + 0.08 * Cos((bonus(i%).scaleOffset + Timer * 200) * _Pi / 180), 1
            End If
            SetGameOverTint 1, 1, 1, bonus(i%).transparency!
            _glBegin _GL_QUADS
            _glTexCoord2f 0.2 * bonus(i%).type, 1
            _glVertex2f -BONUS_RADIUS, BONUS_RADIUS
            _glTexCoord2f 0.2 + 0.2 * bonus(i%).type, 1
            _glVertex2f BONUS_RADIUS, BONUS_RADIUS
            _glTexCoord2f 0.2 + 0.2 * bonus(i%).type, 0
            _glVertex2f BONUS_RADIUS, -BONUS_RADIUS
            _glTexCoord2f 0.2 * bonus(i%).type, 0
            _glVertex2f -BONUS_RADIUS, -BONUS_RADIUS
            _glEnd
            _glPopMatrix
        End If
    Next
    _glDisable _GL_BLEND
    _glDisable _GL_TEXTURE_2D
End Sub

Sub RenderTarget
    Dim i%, j!
    Dim r!
    r! = 6
    If game.longTarget% Then
        For i% = 0 To LONG_TARGET_BALLS
            _glPushMatrix
            _glTranslatef trajectory(i%).x!, trajectory(i%).y!, 0
            _glScalef 1 - i% * (0.9 / LONG_TARGET_BALLS), 1 - i% * (0.9 / LONG_TARGET_BALLS), 1
            _glColor3f 1, 1, 0.7
            _glBegin _GL_TRIANGLE_FAN
            For j! = 0 To _Pi(2) Step .2
                _glVertex2f Cos(j!) * r!, Sin(j!) * r!
            Next
            _glEnd
            _glPopMatrix
        Next
    Else
        For i% = 0 To TARGET_BALLS
            _glPushMatrix
            _glTranslatef target.velocity.x! * i%, _Height / 2 + target.velocity.y! * i% + GRAVITY * i% * i% / 2, 0
            _glScalef 1 - i% * 0.03, 1 - i% * 0.03, 1
            _glColor3f 1, 1, 0.7
            _glBegin _GL_TRIANGLE_FAN
            For j! = 0 To _Pi(2) Step .2
                _glVertex2f Cos(j!) * r!, Sin(j!) * r!
            Next
            _glEnd
            _glPopMatrix
        Next
    End If
End Sub

Sub RenderBalls
    Dim i%, j!, k%, n%
    Dim r!
    Dim p(3) As VECTORF
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    For i% = 0 To game.totalBalls% - 1
        If ball(i%).active And ball(i%).delay% = 0 Then
            r! = BALL_RADIUS + ball(i%).size%
            p(0) = ball(i%).pos
            p(1) = ball(i%).trail1
            p(2) = ball(i%).trail2
            p(3) = ball(i%).trail3
            _glPushMatrix
            For k% = 3 To 1 Step -1
                For n% = 0 To 7
                    _glPushMatrix
                    _glTranslatef p(k%).x! + (p(k% - 1).x! - p(k%).x!) / 8 * n%, p(k%).y! + (p(k% - 1).y! - p(k%).y!) / 8 * n%, 0
                    _glScalef 1 - 0.3 * k% + 0.3 / 8 * n%, 1 - 0.3 * k% + 0.3 / 8 * n%, 1
                    _glColor4f 1, 1 - k% * 0.3 + n% * 0.3 / 8, 0, 1 - k% * 0.3 + n% * 0.3 / 8
                    _glBegin _GL_TRIANGLE_FAN
                    For j! = 0 To _Pi(2) Step .2
                        _glVertex2f Cos(j!) * r!, Sin(j!) * r!
                    Next
                    _glEnd
                    _glPopMatrix
                Next
            Next
            _glPopMatrix
            _glPushMatrix
            _glScalef 1, 1, 1
            _glTranslatef p(0).x!, p(0).y!, 0
            _glColor3f 1, 1, 0.7
            _glBegin _GL_TRIANGLE_FAN
            For j! = 0 To _Pi(2) Step .2
                _glVertex2f Cos(j!) * r!, Sin(j!) * r!
            Next
            _glEnd
            If ball(i%).multiplier = 2 Then
                _glColor3f 0.3, 0.3, 0.1
                _glBegin _GL_TRIANGLE_FAN
                For j! = 0 To _Pi(2) Step .2
                    _glVertex2f Cos(j!) * (r! - 2), Sin(j!) * (r! - 2)
                Next
                _glEnd
            End If
            _glPopMatrix
        End If
    Next
    _glDisable _GL_BLEND
End Sub

Sub RenderPolygonEffects
    Dim i%, j!
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    For i% = 0 To game.totalPolys% - 1
        If poly(i%).hitEffect% > 0 Then
            _glPushMatrix
            _glTranslatef poly(i%).pos.x!, poly(i%).pos.y!, 0
            _glRotatef poly(i%).angle!, 0, 0, 1
            If poly(i%).hits% > 0 Then
                _glColor4f poly(i%).r!, poly(i%).g!, poly(i%).b!, poly(i%).hitEffect% / 20
                _glScalef poly(i%).scale! * (1 + (20 - poly(i%).hitEffect%) / 10), poly(i%).scale! * (1 + (20 - poly(i%).hitEffect%) / 10), 1
            Else
                _glColor4f poly(i%).r!, poly(i%).g!, poly(i%).b!, poly(i%).hitEffect% / 50
                _glScalef poly(i%).scale! * (1 + (50 - poly(i%).hitEffect%) / 6), poly(i%).scale! * (1 + (50 - poly(i%).hitEffect%) / 6), 1
            End If
            _glBegin _GL_TRIANGLE_FAN
            For j! = 0 To _Pi(2) Step _Pi(2) / poly(i%).sides%
                _glVertex2f Cos(j!) * poly(i%).size!, Sin(j!) * poly(i%).size!
            Next
            _glEnd
            _glPopMatrix
        End If
    Next
    _glDisable _GL_BLEND
End Sub

Sub RenderPolygons
    Dim i%, j!
    _glEnable _GL_BLEND
    _glBlendFunc _GL_SRC_ALPHA, _GL_ONE_MINUS_SRC_ALPHA
    For i% = 0 To game.totalPolys% - 1
        If poly(i%).hits% > 0 Then
            _glPushMatrix
            _glTranslatef poly(i%).pos.x!, poly(i%).pos.y!, 0
            _glScalef poly(i%).scale!, poly(i%).scale!, 1
            _glRotatef poly(i%).angle!, 0, 0, 1
            _glColor3f 0, 0, 0
            _glBegin _GL_TRIANGLE_FAN
            For j! = 0 To _Pi(2) Step _Pi(2) / poly(i%).sides%
                _glVertex2f Cos(j!) * poly(i%).size!, Sin(j!) * poly(i%).size!
            Next
            _glEnd
            SetGameOverTint poly(i%).r!, poly(i%).g!, poly(i%).b!, 1
            _glBegin _GL_TRIANGLE_FAN
            For j! = 0 To _Pi(2) Step _Pi(2) / poly(i%).sides%
                _glVertex2f Cos(j!) * (poly(i%).size! - 2), Sin(j!) * (poly(i%).size! - 2)
            Next
            _glEnd
            _glPopMatrix
            RenderNumber glData.bubbleText&, poly(i%).hits%, poly(i%).pos.x!, poly(i%).pos.y!, 10, 0.1, 0.1, 0.1
        End If
    Next
    _glDisable _GL_BLEND
End Sub

'======================================================================================================================================================================================================

Sub RenderFrame
    RenderBackground
    RenderPolygonEffects
    RenderBonusEffects
    RenderPolygons
    RenderBonuses
    If state.state% = STATE_AIM Then RenderTarget
    If state.state% = STATE_FIRE Then RenderBalls
    RenderOverlay
    RenderNumber glData.bubbleText&, hiscore&(game.level%), 202, 86, 12, 0, 0, 0
    RenderNumber glData.bubbleText&, game.score&, 202, 23, 12, 0, 0, 0
    RenderNumber glData.bubbleText&, game.rowCount%, 202, -27, 12, 0, 0, 0
    RenderNumber glData.bubbleText&, game.totalBalls%, 202, -75, 12, 0, 0, 0
    RenderNumber glData.bubbleText&, hiscore&(EASY), 37 - _Width / 2, 86, 12, 0, 0, 0
    RenderNumber glData.bubbleText&, hiscore&(MEDIUM), 37 - _Width / 2, -14, 12, 0, 0, 0
    RenderNumber glData.bubbleText&, hiscore&(HARD), 37 - _Width / 2, -114, 12, 0, 0, 0
    If state.state% = STATE_WAIT_TO_START Then RenderStart
End Sub

'======================================================================================================================================================================================================

Function LoadTexture& (fileName$)
    LoadTexture& = LoadTextureInternal&(fileName$, FALSE, 0)
End Function

Function LoadTextureWithAlpha& (fileName$, rgb&)
    LoadTextureWithAlpha& = LoadTextureInternal&(fileName$, TRUE, rgb&)
End Function

Function LoadTextureInternal& (fileName$, useRgb%, rgb&)
    Dim img&, img2&, myTex&
    Dim m As _MEM
    img& = _LoadImage(fileName$, 32)
    img2& = _NewImage(_Width(img&), _Height(img&), 32)
    _PutImage (0, _Height(img&))-(_Width(img&), 0), img&, img2&
    If useRgb% Then _SetAlpha 0, rgb&, img2&
    _glGenTextures 1, _Offset(myTex&)
    _glBindTexture _GL_TEXTURE_2D, myTex&
    m = _MemImage(img2&)
    _glTexImage2D _GL_TEXTURE_2D, 0, _GL_RGBA, _Width(img&), _Height(img&), 0, _GL_BGRA_EXT, _GL_UNSIGNED_BYTE, m.OFFSET
    _MemFree m
    _FreeImage img&
    _FreeImage img2&
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MAG_FILTER, _GL_LINEAR
    _glTexParameteri _GL_TEXTURE_2D, _GL_TEXTURE_MIN_FILTER, _GL_NEAREST
    LoadTextureInternal& = myTex&
End Function

'======================================================================================================================================================================================================

Sub _GL
    If Not glData.executing% Then Exit Sub
    If Not glData.initialised% Then
        glData.initialised% = TRUE
        _glViewport 0, 0, _Width, _Height
        glData.ovelay& = LoadTexture&("assets/overlay.png")
        glData.background& = LoadTexture&("assets/background.png")
        glData.bubbleText& = LoadTexture&("assets/bubble-numbers.png")
        glData.bonuses& = LoadTexture&("assets/bonuses.png")
        glData.start& = LoadTexture&("assets/start.png")
        glData.easy& = LoadTexture&("assets/easy.png")
        glData.normal& = LoadTexture&("assets/normal.png")
        glData.difficult& = LoadTexture&("assets/difficult.png")
        glData.easy_hi& = LoadTexture&("assets/easy hi.png")
        glData.normal_hi& = LoadTexture&("assets/normal hi.png")
        glData.hard_hi& = LoadTexture&("assets/hard hi.png")
    End If
    _glMatrixMode _GL_PROJECTION
    _glLoadIdentity
    _glOrtho -_Width / 2, _Width / 2, -_Height / 2, _Height / 2, -5, 5
    _glMatrixMode _GL_MODELVIEW
    _glLoadIdentity
    _glClearColor 0, 0, 0, 1
    _glClear _GL_COLOR_BUFFER_BIT
    RenderFrame
    _glFlush
    If _Exit Then
        exitProgram = TRUE
    End If
End Sub

'======================================================================================================================================================================================================
