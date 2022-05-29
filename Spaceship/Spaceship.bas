'Spaceship, by @FellippeHeitor (2016)
'--------------------------------------------------------------------------
$Resize:Smooth

Declare Library
    Function GetUptime Alias GetTicks
End Declare

Const godMode = -1

If godMode Then _FullScreen
$ExeIcon:'./ship.ico'
_Icon
_ScreenMove _Middle
_Title "Spaceship"
DefLng A-Z

Dim Shared SONG(1 To 3) As Long
Path$ = "Audio\"
SONG(1) = _SndOpen(Path$ + "levelintro.ogg", "SYNC,PAUSE")
PlaySong SONG(1)

' declare constants and types
Const MaxStars = 15
Const MaxBeams = 10
Const MaxEnemyBeams = 10

Const ScreenMap.Bonus = 1
Const ScreenMap.Enemy = 2
Const ScreenMap.EnemyLaser = 3

Type ObjectsTYPE
    ID As Integer
    X As Single
    Y As Integer
    Width As Integer
    Height As Integer
    Color As Integer
    LastFrameUpdate As Double
    ColorPattern As String * 256
    ColorSteps As Integer
    CurrentColorStep As Integer
    Shape As String * 4000
    TotalShapes As Integer
    CurrentShape As Integer
    Points As Integer
    Hits As Integer
    IsVisible As _Byte
    RelativeSpeed As Integer
    Char As String * 1
    Size As Integer
    StartTime As Double
    MovePattern As String * 256
    MoveSteps As Integer
    CanReverse As _Byte
    Chase As _Byte
    CurrentMoveStep As Integer
    CanShoot As _Byte
End Type

'Variable declaration
Dim i, StartTime#, x, Found As _Byte, a$, TotalControllers As Integer
Dim ReturnedButton$, SavedDevice%, Dummy
Dim Shared GetButton.NotFound As _Byte, GetButton.Found As _Byte, GetButton.Multiple As _Byte

Dim x As Integer, y As Integer
Dim Shared ScreenMap(1 To 80, 1 To 25) As Double
Dim Shared GoalAchieved As _Byte, ChapterGoal As Integer
Dim Shared KilledEnemies As Integer, Countdown#
Dim Shared WeKilledFirst As _Byte
Dim Shared GameMode As _Byte
Dim Shared BossFight As _Byte
Dim Shared VisibleEnemies As Integer
Dim Collision As _Byte
Dim row As Single, RoundRow As Integer
Dim Shared BackupStarFieldSpeed As Double, StarFieldSpeed As Double
Dim Shared EnemiesSpeed As Double, BackupEnemiesSpeed As Double
Dim ShieldImages(1 To 10) As Long
Dim SmokeImages(1 To 3) As Long
Dim ShieldInitiated#, LastShieldImage As Integer
Dim x(1 To 8) As Integer, y(1 To 8) As Integer
Dim Shared MaxEnemies As Integer
Dim Shared Starfield(MaxStars) As ObjectsTYPE
Dim Shared Enemies(200) As ObjectsTYPE
Dim Shared Beams(MaxBeams) As ObjectsTYPE
Dim Shared EnemyBeams(MaxEnemyBeams) As ObjectsTYPE
Dim Shared Chapter, Energy As Single, Level
Dim ShieldCanvas, c, Boom$
Dim CarefulMessage#, EnergyWarning#
Dim Points, Lives As Integer, EnergyBars As Integer
Dim Shared Recharge As _Byte, Alive As _Byte, ShipSize As _Byte
Dim UpperLimit As Integer, LowerLimit As Integer, LeftLimit As Integer
Dim Shared ShipColor As Integer
Dim k$
Dim Shared Pause As _Byte
Dim Shield As _Byte, LastRecharge#
Dim Shared LastPause#, PauseOffset#
Dim Stars As _Byte, id As Integer, RechargeTime#
Dim move_stars_Last#, move_enemies_Last#
Dim LastEngineEnergy#, prevX As Integer, prevY As Integer
Dim Smoke As _Byte, Char$, ShotsFired As _Byte
Dim LaserAnimationStep As _Byte, Laser.X As Integer
Dim Laser.Y As Integer, j As Integer, drawIt As Integer
Dim Visible As _Byte, CheckEnemy As Integer, Boom.X As Integer
Dim Boom.Y As Integer, EnemyExplosion As _Byte
Dim ExplosionAnimationStep As _Byte, l As Integer
Dim L1 As _Byte, L2 As _Byte, L3 As _Byte
Dim NewBeam As Integer, LastBeam#, EnergyStat$
Dim LastEnemyBeam#
Dim EnergyWarningText As _Byte
Dim Shared Mute As _Byte
Dim Shared UseKeyboard As _Byte

Dim Shared Bonus.Active As _Byte, Bonus.Color As Integer
Dim Shared Bonus.X As Integer, Bonus.Y As Integer, Bonus.Shape$
Dim Shared Bonus.Speed#
Dim Shared Bonus.Width As Integer, Bonus.Height As Integer
Dim Shared Bonus.Type$
Dim Shared Bonus.ColorPattern As String
Dim Shared Bonus.ColorSteps As Integer
Dim Shared Bonus.CurrentColorStep As Integer

Dim ShieldColorIndex As Integer, LastShieldColor#
Dim x.offset!, Damage As _Byte, DeathMessage$
Dim PauseMessage$, bx As Integer, by As Integer
Dim brow!

'Animation uses ASCII character 7, which normally beeps when printed to the screen.
'Let's turn this behavior off:
_ControlChr Off

'Custom types:
Type DevType
    ID As Integer
    Name As String * 256
End Type

Type ButtonMapType
    ID As Long
    Name As String * 10
End Type

ReDim Shared MyDevices(0) As DevType
Dim Shared ChosenController

'Initialize ButtonMap for the assignment routine
Dim Shared ButtonMap(1 To 8) As ButtonMapType
i = 1
ButtonMap(i).Name = "START": i = i + 1
ButtonMap(i).Name = "SELECT": i = i + 1
ButtonMap(i).Name = "UP": i = i + 1
ButtonMap(i).Name = "DOWN": i = i + 1
ButtonMap(i).Name = "LEFT": i = i + 1
ButtonMap(i).Name = "RIGHT": i = i + 1
ButtonMap(i).Name = "FIRE": i = i + 1
ButtonMap(i).Name = "SPECIAL": i = i + 1

'Detection routine:
Print "Detecting your controller. Press any button..."
Print "(If you don't have a controller, press any key on your keyboard)"
StartTime# = GetTICKS
Do
    x& = _DeviceInput
    If x& = 1 Or x& > 2 Then
        'Keyboard is 1, Mouse is 2. Anything after that could be a controller.
        Found = -1
        Exit Do
    End If
    k = _KeyHit
    If k = 27 Then Exit Do
    If k <> 0 Then UseKeyboard = -1: Found = -1: Exit Do
Loop Until GetTICKS - StartTime# > 10

If Found = 0 Then
    Print "No controller detected."
    End
End If

If UseKeyboard = 0 Then
    For i = 1 To _Devices
        a$ = _Device$(i)
        If InStr(a$, "CONTROLLER") > 0 Or InStr(a$, "KEYBOARD") > 0 Then
            TotalControllers = TotalControllers + 1
            ReDim _Preserve Shared MyDevices(1 To TotalControllers) As DevType
            MyDevices(TotalControllers).ID = i
            MyDevices(TotalControllers).Name = a$
        End If
    Next i

    'IF godMode THEN ChosenController = 2: GOTO AssignKeys
    If TotalControllers > 1 Then
        'More than one controller found, user can choose which will be used
        '(though I highly suspect this bit will never be run)
        Print "Controllers found:"
        For i = 1 To TotalControllers
            Print i, MyDevices(i).Name
        Next i
        Do
            Input "Your choice (0 to quit): ", ChosenController
            If ChosenController = 0 Then End
        Loop Until ChosenController <= TotalControllers
    Else
        ChosenController = 1
    End If
Else
    TotalControllers = TotalControllers + 1
    ReDim _Preserve Shared MyDevices(1 To TotalControllers) As DevType
    MyDevices(TotalControllers).ID = 1
    MyDevices(TotalControllers).Name = "KEYBOARD"
    ChosenController = 1
End If

If ChosenController = 1 And InStr(_OS$, "WIN") = 0 Then UseKeyboard = -1

AssignKeys:
Cls
Locate 25, 1
Color 8
If Not UseKeyboard Then
    Print "Using "; RTrim$(MyDevices(ChosenController).Name);
Else
    Print "Using KEYBOARD";
End If
Print
If _FileExists("controller.dat") = 0 Then
    i = 0

    If UseKeyboard Then
        _KeyClear
    Else
        'Wait until all buttons in the deviced are released:
        Do
        Loop Until GetButton("", MyDevices(ChosenController).ID) = GetButton.NotFound
    End If

    'Start assignment
    Do
        i = i + 1
        If i > UBound(ButtonMap) Then Exit Do
        Redo:
        If Not UseKeyboard Then
            Print "PRESS BUTTON FOR '" + RTrim$(ButtonMap(i).Name) + "'...";

            'Read a button
            ReturnedButton$ = ""
            Do
            Loop Until GetButton(ReturnedButton$, 0) = GetButton.Found

            'Wait until all buttons in the deviced are released:
            Do
            Loop Until GetButton("", 0) = GetButton.NotFound

            ButtonMap(i).ID = CVI(ReturnedButton$)
        Else
            Print "PRESS A KEY FOR '" + RTrim$(ButtonMap(i).Name) + "'...";

            'Read a key
            k = 0
            Do While k <= 0: k = _KeyHit: Loop
            _KeyClear
            ReturnedButton$ = MKL$(k)
            ButtonMap(i).ID = CVL(ReturnedButton$)
        End If
        Print
    Loop
    Open "controller.dat" For Binary As #1
    Put #1, 1, MyDevices(ChosenController).ID
    Put #1, , ButtonMap()
    Close #1
Else
    Open "controller.dat" For Binary As #1
    Get #1, 1, SavedDevice%
    Get #1, , ButtonMap()
    Close #1
    If SavedDevice% <> MyDevices(ChosenController).ID Then
        On Error GoTo FileError
        Kill "controller.dat"
        On Error GoTo 0
        GoTo AssignKeys
    End If
    'FOR i = 1 TO UBOUND(Buttonmap)
    '    PRINT ButtonMap(i).Name; "="; ButtonMap(i).ID
    'NEXT
End If
GoTo DemoStart
Print
Print "Push START..."
Print "(DELETE to reassign keys)"
Do
    If _KeyHit = 21248 Then
        On Error GoTo FileError
        Kill "controller.dat"
        On Error GoTo 0
        GoTo AssignKeys
    End If
Loop Until GetButton("START", MyDevices(ChosenController).ID)

'Demo goes here: -----------------------------------------------------------------------------------
DemoStart:
Dummy = GetButton("", MyDevices(ChosenController).ID)
Randomize Timer

'Load audio
_PaletteColor 0, _RGBA32(0, 0, 0, 0)
_PaletteColor 1, _RGB32(55, 55, 55)
_DisplayOrder _Hardware , _Software

Restore SpaceshipLogo
titlecard& = RestoreImage&(_RGB32(233, 200, 94))
_PutImage (((_Width * _FontWidth) \ 2) - (_Width(titlecard&) \ 2), 100), titlecard&, 0

Print
Color 15
Load$ = "LOADING AUDIO"
_PrintString (41 - Len(Load$) / 2, 12), Load$
_Display

Dim SNDCatchEnergy, SNDFullRecharge, SNDShieldAPPEAR, SNDShieldON
Dim SNDLaser1, SNDLaser2, SNDShipDamage, SNDShipGrow, SNDEnergyUP
Dim SNDExplosion, SNDOutOfEnergy, SNDExtraLife, SNDShieldOFF
Dim SNDIntercom, SNDBlizzard

SNDBlizzard = _SndOpen(Path$ + "Blizzard.wav", "SYNC")
SNDIntercom = _SndOpen(Path$ + "Intercom.wav", "SYNC")
SNDCatchEnergy = _SndOpen(Path$ + "CatchEnergy.wav", "SYNC")
SNDFullRecharge = _SndOpen(Path$ + "FullRecharge.wav", "SYNC")
SNDShieldAPPEAR = _SndOpen(Path$ + "ShieldAPPEAR.wav", "SYNC")
SNDShieldON = _SndOpen(Path$ + "ShieldON.wav", "SYNC")
SNDShieldOFF = _SndOpen(Path$ + "ShieldOFF.wav", "SYNC")
SNDLaser1 = _SndOpen(Path$ + "Laser1.wav", "SYNC")
SNDLaser2 = _SndOpen(Path$ + "Laser2.wav", "SYNC")
SNDShipDamage = _SndOpen(Path$ + "ShipDamage.wav", "SYNC")
SNDShipGrow = _SndOpen(Path$ + "ShipGrow.wav", "SYNC")
SNDEnergyUP = _SndOpen(Path$ + "EnergyUP.wav", "SYNC")
SNDExplosion = _SndOpen(Path$ + "Explosion1.wav", "SYNC")
SNDOutOfEnergy = _SndOpen(Path$ + "OutOfEnergy.wav", "SYNC")
SNDExtraLife = _SndOpen(Path$ + "ExtraLife.wav", "SYNC")
SONG(2) = _SndOpen(Path$ + "bossfight.ogg", "SYNC,PAUSE")
SONG(3) = _SndOpen(Path$ + "level1.ogg", "SYNC,PAUSE")

PlaySong SONG(3)

'Generate smoke images --------------------------------------------
SmokeCanvas = _NewImage(3 * _FontWidth, _FontHeight, 32)
_Dest SmokeCanvas

Color _RGB32(89, 89, 89), _RGBA32(0, 0, 0, 0)
_PrintString (0, 0), Chr$(176) + Chr$(177)
Color _RGB32(144, 144, 144), _RGBA32(0, 0, 0, 0)
_PrintString (0, 0), Chr$(32) + Chr$(32) + Chr$(178)
SmokeImages(3) = _CopyImage(SmokeCanvas, 33)
Cls
Color _RGB32(89, 89, 89), _RGBA32(0, 0, 0, 0)
_PrintString (0, 0), Chr$(32) + Chr$(177) + Chr$(178)
Color _RGB32(144, 144, 144), _RGBA32(0, 0, 0, 0)
_PrintString (0, 0), Chr$(32) + Chr$(32) + Chr$(178)
SmokeImages(2) = _CopyImage(SmokeCanvas, 33)
Cls
Color _RGB32(89, 89, 89), _RGBA32(0, 0, 0, 0)
_PrintString (0, 0), Chr$(32) + Chr$(32) + Chr$(178)
Color _RGB32(144, 144, 144), _RGBA32(0, 0, 0, 0)
_PrintString (0, 0), Chr$(32) + Chr$(32) + Chr$(178)
SmokeImages(1) = _CopyImage(SmokeCanvas, 33)
_Dest 0
_FreeImage SmokeCanvas

'Generate shield images --------------------------------------------
ShieldCanvas = _NewImage(7 * _FontWidth, 4 * _FontHeight, 32)
_Dest ShieldCanvas
For c = 1 To 10
    Color _RGBA32(Rnd * 200 + 50, Rnd * 200 + 50, Rnd * 200 + 50, 25.5 * c)
    For i = 1 To 4
        _PrintString (0, _FontHeight * i - _FontHeight), String$(7, 176)
    Next i
    ShieldImages(c) = _CopyImage(ShieldCanvas, 33)
Next c
_FreeImage ShieldCanvas
_Dest 0

'Generate "life bar" image ------------------------------------------
LifeBarCanvas = _NewImage(80 * _FontWidth, _FontHeight, 32)
_Dest LifeBarCanvas
For i = 1 To 80
    Color _RGBA32(255, 0, 0, (150 * (i / 80)) + 105)
    _PrintString (i * _FontWidth - _FontWidth, 0), Chr$(219)
Next
LifeBarImage = _CopyImage(LifeBarCanvas, 33)
_FreeImage LifeBarCanvas
_Dest 0

Boom$ = Chr$(219) + Chr$(178) + Chr$(177) + Chr$(176) + Chr$(15) + Chr$(7) + Chr$(249) + Chr$(250)

Const Acceleration = .005
Const GraceTime = 2

Const EASY = 1
Const HARD = 2

RestartGame:
Erase Enemies
CarefulMessage# = -1.5
EnergyWarning# = -1
ShieldONMessage# = -1
ShieldOFFMessage# = -1
ShieldColorIndex = 1
x = 5
y = 25
Points = 0
Lives = 3
Energy = 0
EnergyBars = 0
Recharge = -1
Level = 1
Chapter = 1
SetLevel Chapter
Alive = -1
ShipSize = 2: UpperLimit = 6: LowerLimit = 47: LeftLimit = 5
InitialSetup = -1
ShipColor = 14
StarFieldSpeed = .08
WeKilledFirst = 0
GameMode = HARD

'Wait until all buttons are released:
Do
Loop Until GetButton("", 0) = GetButton.NotFound

Do
    k$ = InKey$
    If k$ = Chr$(27) Then EscExit = -1: Exit Do
    If UCase$(k$) = "M" Then Mute = Not Mute
    If godMode And UCase$(k$) = "F" Then Freeze = Not Freeze: If Freeze Then FreezeInitiated# = GetTICKS
    If Mute Then
        If Not Pause Then
            PauseSong
        End If
    Else
        If Not Pause Then
            If Not BossFight Then PlaySong SONG(Level + 2) Else PlaySong SONG(2)
        End If
    End If
    If godMode And UCase$(k$) = "L" Then PlaySound SNDFullRecharge: SetLevel Chapter + 1

    'Grab _BUTTON states using custom function GetButton:
    If Pause = 0 And Alive = -1 And Recharge = 0 Then
        If GetButton("UP", 0) Then If Energy And y > UpperLimit Then y = y - 1: Energy = Energy - .001
        If GetButton("DOWN", 0) Then If Energy And y < LowerLimit Then y = y + 1: Energy = Energy - .001
        If GetButton("LEFT", 0) Then
            If Energy And x > LeftLimit Then x = x - 1: Energy = Energy - .001
            MovingLeft = -1
        Else
            MovingLeft = 0
        End If

        If GetButton("RIGHT", 0) Then
            If Energy And x < 80 Then x = x + 1: Energy = Energy - .001
            MovingRight = -1
        Else
            MovingRight = 0
        End If

        If GetButton("FIRE", 0) Then GoSub ShotsFired

        If GetButton("SPECIAL", 0) And GetTICKS - LastSpecialUsed# > .3 And Alive Then
            Select Case CurrentSpecial
                Case 0 'Freeze
                    If totalfreeze > 0 Then
                        totalfreeze = totalfreeze - 1
                        Freeze = -1
                        FreezeInitiated# = GetTICKS
                        LastSpecialUsed# = GetTICKS
                    End If
            End Select
        End If

        If GetButton("SELECT", 0) And GetTICKS - LastSelect# > .3 And Alive Then
            LastSelect# = GetTICKS
        End If
    End If

    If GetButton("START", 0) And (GetUptime / 1000) - LastPause# > .3 Then
        Pause = Not Pause
        If Pause Then
            LastPause# = (GetUptime / 1000)
            PauseSong
            _DisplayOrder _Software , _Hardware
        Else
            PauseOffset# = PauseOffset# + ((GetUptime / 1000) - LastPause#)
            LastPause# = (GetUptime / 1000)
            If Not Mute Then
                If Not BossFight Then PlaySong SONG(Level + 2) Else PlaySong SONG(2)
            End If
            _DisplayOrder _Hardware , _Software
        End If
    End If

    'Display routines:
    Cls , 0
    Color , 0
    'Star field ------------------------------------------------------
    If Recharge Then
        StarFieldSpeed = StarFieldSpeed - Acceleration
        If StarFieldSpeed < 0 Then StarFieldSpeed = 0
        If Stars = 0 Then
            PlaySound SNDFullRecharge
            Stars = -1
            'actions
            For id = 1 To MaxStars
                CreateStar id, 0
            Next
        End If
        If GetTICKS - RechargeTime# > .03 Then
            RechargeTime# = GetTICKS
            Energy = Energy + 5
            If InitialSetup Then x = x + 1
        End If
        If Energy >= 100 Then Recharge = 0: InitialSetup = 0
    Else
        If MovingRight And Not Freeze Then
            StarFieldSpeed = StarFieldSpeed - Acceleration
            If StarFieldSpeed < 0 Then StarFieldSpeed = 0
            'EnemiesSpeed = EnemiesSpeed - Acceleration
            'IF EnemiesSpeed < 0 THEN EnemiesSpeed = 0
        ElseIf Not Freeze Then
            StarFieldSpeed = StarFieldSpeed + Acceleration
            If StarFieldSpeed > BackupStarFieldSpeed Then StarFieldSpeed = BackupStarFieldSpeed
            'EnemiesSpeed = EnemiesSpeed + Acceleration
            'IF EnemiesSpeed > BackupEnemiesSpeed THEN EnemiesSpeed = BackupEnemiesSpeed
        End If
    End If

    If GetTICKS - move_stars_Last# > StarFieldSpeed And Pause = 0 And Alive = -1 And Energy > 0 And Freeze = 0 Then
        move_stars_Last# = GetTICKS
        'move stars in the starfield array
        For id = 1 To MaxStars
            'move individual star
            Starfield(id).X = Starfield(id).X - Starfield(id).RelativeSpeed

            'if the star came out of the left edge, create a new star at the right edge
            If Starfield(id).X < 1 Then
                CreateStar id, -1
            End If
        Next

        ''Ship goes back if not intentionally moving forward:
        'IF x > LeftLimit AND MovingRight = 0 AND MovingLeft = 0 THEN x = x - 1
    End If

    If GetTICKS - move_enemies_Last# > EnemiesSpeed And Pause = 0 And Alive = -1 And Recharge = 0 And Freeze = 0 Then
        move_enemies_Last# = GetTICKS
        'move enemies
        For id = 1 To MaxEnemies
            'move individual enemy
            If Enemies(id).Hits > 0 Then
                Enemies(id).X = Enemies(id).X - Enemies(id).RelativeSpeed

                MoveY = CVI(Mid$(Enemies(id).MovePattern, (Enemies(id).CurrentMoveStep * 2) - 1, 2))
                If Enemies(id).Chase And Enemies(id).X <= x + 25 Then
                    If Enemies(id).Y < y / 2 Then MoveY = _Ceil(Rnd * 3) Else MoveY = -_Ceil(Rnd * 3)
                End If
                Enemies(id).CurrentMoveStep = Enemies(id).CurrentMoveStep Mod Enemies(id).MoveSteps + 1
                Enemies(id).Y = Enemies(id).Y + MoveY
                If MoveY <> 0 And GameMode = HARD Then Enemies(id).X = Enemies(id).X - 1

                If Enemies(id).CanReverse Then
                    'Enemies that reach a screen boundary will have their
                    'direction reversed
                    If Enemies(id).Y < 2 Then Enemies(id).Y = 2: ReverseEnemyPattern id
                    If Enemies(id).Y + (Enemies(id).Height - 1) > 24 Then
                        Enemies(id).Y = 24 - (Enemies(id).Height - 1)
                        ReverseEnemyPattern id
                    End If

                    'Sometimes their direction will be reversed randomly too
                    a% = _Ceil(Rnd * Enemies(id).MoveSteps)
                    If a% = Enemies(id).CurrentMoveStep Then ReverseEnemyPattern id
                End If

                'if the enemy came out of the screen or was killed,
                'create a new one at the right edge
                IF Enemies(id).X + Enemies(id).Width < 1 OR _
                    Enemies(id).Y + Enemies(id).Height < 2 OR _
                    Enemies(id).Y > 25 THEN
                    Enemies(id).Hits = 0
                    CreateEnemy id, Chapter
                End If

                If Enemies(id).CanShoot And WeKilledFirst Then
                    'Enemy shoots when aligned (or close to aligning) with hero:
                    '(Enemies only shoot if they've been attacked first)
                    'IF Enemies(id).X > x AND Enemies(id).X <= x + 30 THEN
                    '    IF Enemies(id).Y >= INT(y / 2) - 6 AND Enemies(id).Y <= INT(y / 2) + 6 THEN
                    '        ShootingID = id
                    '        GOSUB EnemyShotsFired
                    '    END IF
                    'END IF

                    'If enemy is visible, make it shoot:
                    If Enemies(id).IsVisible Then
                        ShootingID = id
                        GoSub EnemyShotsFired
                    End If
                End If
            End If
        Next
    End If

    If GetTICKS - LastEngineEnergy# > 10 Then
        LastEngineEnergy# = GetTICKS
        Energy = Energy - 0.001
    End If

    DrawElements

    'Recalculate ship position after move: -----------------------------
    If (x <> prevX Or y <> prevY) And Alive = -1 Then
        prevY = y
        If prevX < x Then Smoke = 3 Else Smoke = 0
        prevX = x

        row = y / 2
    End If

    RoundRow = _Ceil(row)
    If RoundRow <> row Then
        Char$ = Chr$(223)
    Else
        Char$ = Chr$(220)
    End If

    If ShotsFired And Alive Then
        'Diagonal fire animation - follows the ship
        LaserAnimationStep = LaserAnimationStep + 1
        Laser.X = x: Laser.Y = RoundRow

        If LaserAnimationStep > Len(Boom$) Then
            ShotsFired = 0
            LaserAnimationStep = 0
        Else
            j = 1
            x(j) = Laser.X + LaserAnimationStep: y(j) = Laser.Y + LaserAnimationStep: j = j + 1
            x(j) = Laser.X + LaserAnimationStep: y(j) = Laser.Y - LaserAnimationStep: j = j + 1

            'Diagonal fire
            For drawIt = 1 To 2
                Visible = -1
                If x(drawIt) < 1 Or x(drawIt) > 80 Then Visible = 0
                If y(drawIt) < 1 Or y(drawIt) > 25 Then Visible = 0
                Color ShipColor - 8
                If Visible Then
                    _PrintString (x(drawIt), y(drawIt)), Mid$(Boom$, LaserAnimationStep, 1)
                    'IF ScreenMap(x(drawIt), y(drawIt)) < 0 THEN
                    '    CheckEnemy = -ScreenMap(x(drawIt), y(drawIt))
                    '    Boom.X = Enemies(CheckEnemy).X
                    '    Boom.Y = Enemies(CheckEnemy).Y * 2
                    '    EnemyExplosion = -1
                    '    ExplosionAnimationStep = 0
                    '    KillEnemy CheckEnemy, ShipSize
                    '    Points = Points + Enemies(CheckEnemy).Points
                    '    PlaySound SNDExplosion
                    'ELSEIF ScreenMap(x(drawIt), y(drawIt)) = ScreenMap.Bonus THEN
                    '    Boom.X = x(drawIt)
                    '    Boom.Y = y(drawIt)
                    '    EnemyExplosion = -1
                    '    ExplosionAnimationStep = 0
                    '    Bonus.Active = 0
                    '    Points = Points + 50
                    '    PlaySound SNDExplosion
                    'END IF
                End If
            Next
        End If
    End If

    'Enemies' lasers:
    If Alive = -1 And Recharge = 0 And Pause = 0 And GameMode = HARD Then
        For i = 1 To MaxEnemyBeams
            If GetTICKS - EnemyBeams(i).StartTime < .8 Or Freeze Then 'Enemy laser beams last for .8 seconds
                l = 0
                For l = 0 To EnemyBeams(i).Size
                    If EnemyBeams(i).X + l <= 80 Then
                        If Enemies(EnemyBeams(i).ID).Color = -1 Then
                            Color _Ceil(Rnd * 14) + 1
                        ElseIf Enemies(EnemyBeams(i).ID).Color = -2 Then 'Custom color pattern
                            Color CVI(Mid$(Enemies(EnemyBeams(i).ID).ColorPattern, (Enemies(EnemyBeams(i).ID).CurrentColorStep * 2) - 1, 2))
                        Else
                            Color Enemies(EnemyBeams(i).ID).Color
                        End If
                        If GetTICKS - EnemyBeams(i).StartTime > .5 Then Color 1
                        If EnemyBeams(i).X + l > 0 And EnemyBeams(i).Y >= 2 And EnemyBeams(i).Y <= 25 Then
                            _PrintString (EnemyBeams(i).X + l, EnemyBeams(i).Y), EnemyBeams(i).Char
                            ScreenMap(EnemyBeams(i).X + l, EnemyBeams(i).Y) = ScreenMap.EnemyLaser + (i / 100)
                        End If
                    End If
                Next l
                If Not Freeze Then EnemyBeams(i).X = EnemyBeams(i).X - 1
            Else
                If Not Freeze Then EnemyBeams(i).X = -EnemyBeams(i).Size 'Invalidate this beam so a new one can be generated
            End If
        Next i
    End If

    'Front lasers:
    If Alive = -1 And Recharge = 0 And Pause = 0 Then
        For i = 1 To MaxBeams
            If GetTICKS - Beams(i).StartTime < .8 Then 'Laser beams last for .8 seconds
                For l = 0 To Beams(i).Size - 1
                    If Beams(i).X + l <= 80 Then
                        Color ShipColor - 8
                        If GetTICKS - Beams(i).StartTime < .2 Then Color 14
                        If GetTICKS - Beams(i).StartTime < .1 Then Color 15
                        If GetTICKS - Beams(i).StartTime > .5 Then Color 1
                        _PrintString (Beams(i).X + l, Beams(i).Y), Beams(i).Char
                        ThisPoint = Fix(ScreenMap(Beams(i).X + l, Beams(i).Y))
                        If ThisPoint < 0 Then
                            CheckEnemy = -ScreenMap(Beams(i).X + l, Beams(i).Y)
                            'Killed an enemy
                            Boom.X = Enemies(CheckEnemy).X
                            Boom.Y = Enemies(CheckEnemy).Y * 2
                            EnemyExplosion = -1
                            ExplosionAnimationStep = 0
                            KillEnemy CheckEnemy, ShipSize
                            'This laser beam can't kill another enemy,
                            'so we'll throw it out the screen:
                            Beams(i).X = 81
                            Points = Points + Enemies(CheckEnemy).Points
                            PointGoesUp! = 0: LastEarnedPoints = Enemies(CheckEnemy).Points
                            PlaySound SNDExplosion
                        ElseIf ThisPoint = ScreenMap.Bonus And GameMode = HARD Then
                            Boom.X = Beams(i).X + l
                            Boom.Y = Beams(i).Y * 2
                            EnemyExplosion = -1
                            ExplosionAnimationStep = 0
                            Bonus.Active = 0
                            'This laser beam can't kill another enemy,
                            'so we'll throw it out the screen:
                            Beams(i).X = 81
                            Points = Points + 50
                            PointGoesUp! = 0: LastEarnedPoints = 50
                            PlaySound SNDExplosion
                        ElseIf ThisPoint = ScreenMap.EnemyLaser Then
                            ThisEnemyBeam = (ScreenMap(Beams(i).X + l, Beams(i).Y) - ThisPoint) * 100
                            EnemyBeams(ThisEnemyBeam).X = -EnemyBeams(ThisEnemyBeam).Size
                            _Display
                        End If
                    End If
                Next l
                Beams(i).X = Beams(i).X + 1
            Else
                Beams(i).X = 81 'Invalidate this beam so a new one can be generated
            End If
        Next i
    End If

    'Draw ship:
    'Ü                              Ü
    ' ßÜÜ    ßÜ               ßÜ    Üß
    '  ÛÛß     ÛÛÜ            ß
    'Üß       Üßß
    '        ß
    If GetTICKS - LastShipGrow# < 1 Then
        Color _Ceil(Rnd * 14) + 1
    Else
        Color ShipColor
    End If

    If GetTICKS - LastDamage# < GraceTime Then
        BlinkShip%% = Not BlinkShip%%
        If BlinkShip%% Then Color 0
    End If

    If Alive Then
        If ShipSize = 1 Then
            If _Ceil(row) <> row Then
                _PrintString (x - 1, RoundRow - 1), Chr$(220)
                _PrintString (x - 1, RoundRow), Chr$(220) + Chr$(223)
                ShipMap$ = MKI$(x - 1) + MKI$(RoundRow - 1)
                ShipMap$ = ShipMap$ + MKI$(x - 1) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x) + MKI$(RoundRow)
            Else
                _PrintString (x - 1, RoundRow), Chr$(223) + Chr$(220)
                _PrintString (x - 1, RoundRow + 1), Chr$(223)
                ShipMap$ = MKI$(x - 1) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x - 1) + MKI$(RoundRow + 1)
            End If
        ElseIf ShipSize = 2 Then
            If _Ceil(row) <> row Then
                _PrintString (x - 4, RoundRow - 2), Chr$(220)
                _PrintString (x - 3, RoundRow - 1), Chr$(223) + Chr$(220) + Chr$(220)
                _PrintString (x - 2, RoundRow), Chr$(219) + Chr$(219) + Chr$(223)
                _PrintString (x - 4, RoundRow + 1), Chr$(220) + Chr$(223)
                ShipMap$ = MKI$(x - 4) + MKI$(RoundRow - 2)
                ShipMap$ = ShipMap$ + MKI$(x - 3) + MKI$(RoundRow - 1)
                ShipMap$ = ShipMap$ + MKI$(x - 2) + MKI$(RoundRow - 1)
                ShipMap$ = ShipMap$ + MKI$(x - 1) + MKI$(RoundRow - 1)
                ShipMap$ = ShipMap$ + MKI$(x - 2) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x - 1) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x - 4) + MKI$(RoundRow + 1)
                ShipMap$ = ShipMap$ + MKI$(x - 3) + MKI$(RoundRow + 1)
            Else
                _PrintString (x - 4, RoundRow - 1), Chr$(223) + Chr$(220)
                _PrintString (x - 2, RoundRow), Chr$(219) + Chr$(219) + Chr$(220)
                _PrintString (x - 3, RoundRow + 1), Chr$(220) + Chr$(223) + Chr$(223)
                _PrintString (x - 4, RoundRow + 2), Chr$(223)
                ShipMap$ = MKI$(x - 4) + MKI$(RoundRow - 1)
                ShipMap$ = ShipMap$ + MKI$(x - 3) + MKI$(RoundRow - 1)
                ShipMap$ = ShipMap$ + MKI$(x - 2) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x - 1) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x) + MKI$(RoundRow)
                ShipMap$ = ShipMap$ + MKI$(x - 3) + MKI$(RoundRow + 1)
                ShipMap$ = ShipMap$ + MKI$(x - 2) + MKI$(RoundRow + 1)
                ShipMap$ = ShipMap$ + MKI$(x - 1) + MKI$(RoundRow + 1)
                ShipMap$ = ShipMap$ + MKI$(x - 4) + MKI$(RoundRow + 2)

            End If
        End If
        If Bonus.Active Then
            If Bonus.Color = -1 Then
                Color _Ceil(Rnd * 14) + 1
            ElseIf Bonus.Color = -2 Then
                Color CVI(Mid$(Bonus.ColorPattern, (Bonus.CurrentColorStep * 2) - 1, 2))
            Else
                Color Bonus.Color
            End If
            _PrintString (x, RoundRow), Char$
        End If
    End If
    Color , 0

    'Collision detection (ship)
    If Alive Then
        Collision = 0
        StartCheck = 1
        Do
            Ship.X = CVI(Mid$(ShipMap$, StartCheck, 2))
            Ship.Y = CVI(Mid$(ShipMap$, StartCheck + 2, 2))
            Collision = ScreenMap(Ship.X, Ship.Y)
            If Collision Then Exit Do
            StartCheck = StartCheck + 4
            If StartCheck > Len(ShipMap$) Then Exit Do
        Loop

        'Check bonuses
        If Bonus.Active = -1 And Collision = ScreenMap.Bonus Then
            Select Case Bonus.Type$
                Case "LIFE"
                    Bonus.Active = 0
                    If ShipSize = 1 Then
                        PlaySound SNDShipGrow
                        ShipSize = 2: UpperLimit = 6: LowerLimit = 47: LeftLimit = 5
                        Energy = Energy + 5
                        If y < UpperLimit Then y = UpperLimit
                        If y > LowerLimit Then y = LowerLimit
                        If x < LeftLimit Then x = LeftLimit
                        LastShipGrow# = GetTICKS
                    Else
                        Lives = Lives + 1
                        PlaySound SNDExtraLife
                    End If
                Case "ENERGY"
                    If Bonus.Color = 10 Then
                        If GetTICKS - LastEnergyUP# > .2 Then
                            LastEnergyUP# = GetTICKS
                            PlaySound SNDEnergyUP
                            Energy = Energy + 5

                            If Energy >= 100 Then Bonus.Color = 8
                        End If
                    End If
                Case "SHIELD"
                    PlaySound SNDShieldON
                    ShieldColorIndex = 1
                    Shield = -1
                    ShieldONMessage# = GetTICKS
                    ShieldInitiated# = GetTICKS
                    Bonus.Active = 0
                Case "FREEZE"
                    If totalfreeze < 3 Then
                        PlaySound SNDShieldON
                        totalfreeze = totalfreeze + 1
                        Bonus.Active = 0
                    End If
            End Select
        End If

        'Check enemies
        If Collision < 0 And GetTICKS - LastDamage# > GraceTime Then
            'Negative value is the hit enemy id, with negative sign
            CheckEnemy = -Collision
            'Death by enemy (or severe damage)
            Points = Points + Enemies(CheckEnemy).Points
            PointGoesUp! = 0: LastEarnedPoints = Enemies(CheckEnemy).Points
            If ShipSize = 1 Then
                PlaySound SNDExplosion
                Bonus.Active = 0
                ExplosionAnimationStep = 0
                'Center explosion around collision area:
                Boom.X = Enemies(CheckEnemy).X
                Boom.Y = Enemies(CheckEnemy).Y * 2
                'Enemy dies too:
                KillEnemy CheckEnemy, ShipSize
                If Shield Then
                    ShieldOFFMessage# = GetTICKS
                    Shield = 0
                    Damage = -1
                    EnemyExplosion = -1
                Else
                    Alive = 0
                    DeathMessage$ = "    BUSTED!!   "
                    EnemyExplosion = 0
                End If
            Else
                PlaySound SNDExplosion
                Boom.X = Enemies(CheckEnemy).X
                Boom.Y = Enemies(CheckEnemy).Y * 2
                ExplosionAnimationStep = 0
                'Enemy dies too:
                KillEnemy CheckEnemy, ShipSize
                If Shield Then
                    ShieldOFFMessage# = GetTICKS
                    Shield = 0
                    Damage = -1
                    EnemyExplosion = -1
                Else
                    LastLife# = GetTICKS
                    LastDamage# = GetTICKS
                    Damage = -1
                    PlaySound SNDShipDamage
                    If Bonus.Type$ = "LIFE" Then Bonus.Color = 4
                    EnemyExplosion = -1
                    CarefulMessage# = GetTICKS
                    ShipSize = 1: UpperLimit = 4: LowerLimit = 49: LeftLimit = 2
                    Energy = Energy / 2
                End If
            End If 'Shipsize = 1
        ElseIf Collision = ScreenMap.EnemyLaser And GetTICKS - LastDamage# > GraceTime And Shield = 0 Then
            'Death by enemy laser (or severe damage)
            If ShipSize = 1 Then
                PlaySound SNDExplosion
                Bonus.Active = 0
                ExplosionAnimationStep = 0
                'Center explosion around collision area:
                Boom.X = Enemies(CheckEnemy).X
                Boom.Y = Enemies(CheckEnemy).Y * 2
                Alive = 0
                DeathMessage$ = "    BUSTED!!   "
                EnemyExplosion = 0
            Else
                PlaySound SNDExplosion
                Boom.X = Enemies(CheckEnemy).X
                Boom.Y = Enemies(CheckEnemy).Y * 2
                ExplosionAnimationStep = 0
                LastLife# = GetTICKS
                LastDamage# = GetTICKS
                Damage = -1
                PlaySound SNDShipDamage
                If Bonus.Type$ = "LIFE" Then Bonus.Color = 4
                EnemyExplosion = -1
                CarefulMessage# = GetTICKS
                ShipSize = 1: UpperLimit = 4: LowerLimit = 49: LeftLimit = 2
                Energy = Energy / 2
            End If 'Shipsize = 1
        End If 'Collision < 0
    End If 'Alive

    'Is a shield active?
    If Shield Then
        'Shields last for 30 seconds
        Select Case GetTICKS - ShieldInitiated#
            Case Is < 20: LastShieldImage = UBound(ShieldImages)
            Case Is < 25: LastShieldImage = UBound(ShieldImages) / 2
            Case Is < 30: LastShieldImage = 3
        End Select

        If (GetUptime / 1000) - LastShieldColor# > .05 Then
            LastShieldColor# = (GetUptime / 1000)
            ShieldColorIndex = ShieldColorIndex + 1
            If ShieldColorIndex > LastShieldImage Then ShieldColorIndex = 1
        End If
        If ShipSize = 1 Then x.offset! = 3.5 Else x.offset! = 5
        _PutImage ((x - x.offset!) * _FontWidth - _FontWidth, (row - 1.3) * _FontHeight - _FontHeight), ShieldImages(ShieldColorIndex), 0

        If GetTICKS - ShieldInitiated# > 30 Then Shield = 0: PlaySound SNDShieldOFF: ShieldOFFMessage# = GetTICKS
    End If

    If Freeze Then
        'Freeze mode lasts for 10 seconds
        If GetTICKS - FreezeInitiated# > 10 Then Freeze = 0: PlaySound SNDBlizzard

        'Or until no more enemies are on screen
        If VisibleEnemies = 0 Then Freeze = 0: PlaySound SNDBlizzard
    End If

    'If moving forward, draw a smoke trail behind the ship
    If Smoke Then
        If ShipSize = 1 Then x.offset! = 3.5 Else x.offset! = 5
        _PutImage ((x - x.offset!) * _FontWidth - _FontWidth, (row + .3) * _FontHeight - _FontHeight), SmokeImages(Smoke), 0
        Smoke = Smoke - 1
        If Smoke < 1 Then Smoke = 0
    End If

    '_TITLE STR$(x) + "," + STR$(y)

    If GetTICKS - CarefulMessage# < 1.5 Then
        Color 15, 4
        PauseMessage$ = " UNIT DAMAGED! "
        _PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, _Height \ 2), PauseMessage$
    End If

    If Pause Then
        Color 15, 1
        PauseMessage$ = "    PAUSED     "
        _PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, _Height \ 2), PauseMessage$

        If FadeStep = 0 Then FadeStep = 10
        Fade = Fade + FadeStep
        If Fade < 100 Then FadeStep = 10: Fade = 100
        If Fade > 255 Then FadeStep = -10: Fade = 255
        If titlecard& < -1 Then _FreeImage titlecard&
        Restore SpaceshipLogo
        titlecard& = RestoreImage&(_RGBA32(233, 200, 94, Fade))
        _PutImage (((_Width * _FontWidth) \ 2) - (_Width(titlecard&) \ 2), 100), titlecard&, 0
    End If

    GoSub UpdateStats

    'Check energy:
    If Alive = -1 And Energy = 0 Then
        Alive = 0
        EnemyExplosion = 0
        Shield = 0
        DeathMessage$ = " NO MORE ENERGY! "
        PlaySound SNDExplosion
        PlaySound SNDOutOfEnergy
        Bonus.Active = 0
        ExplosionAnimationStep = 0
        Boom.X = x
        Boom.Y = y / 2
    End If

    If Alive = 0 Or EnemyExplosion = -1 Then 'GO BOOM!
        bx = x: by = y: brow! = row
        x = Boom.X: y = Boom.Y: row = y / 2: RoundRow = _Ceil(row)
        'Explosion animation
        ExplosionAnimationStep = ExplosionAnimationStep + 1
        j = 1
        x(j) = x + ExplosionAnimationStep: y(j) = RoundRow + ExplosionAnimationStep: j = j + 1
        x(j) = x + ExplosionAnimationStep: y(j) = RoundRow - ExplosionAnimationStep: j = j + 1
        x(j) = x + ExplosionAnimationStep: y(j) = RoundRow: j = j + 1
        x(j) = x - ExplosionAnimationStep: y(j) = RoundRow - ExplosionAnimationStep: j = j + 1
        x(j) = x - ExplosionAnimationStep: y(j) = RoundRow + ExplosionAnimationStep: j = j + 1
        x(j) = x - ExplosionAnimationStep: y(j) = RoundRow: j = j + 1
        x(j) = x: y(j) = RoundRow - ExplosionAnimationStep: j = j + 1
        x(j) = x: y(j) = RoundRow + ExplosionAnimationStep: j = j + 1

        For drawIt = 1 To 8
            Visible = -1
            If x(drawIt) < 1 Or x(drawIt) > 80 Then Visible = 0
            If y(drawIt) < 1 Or y(drawIt) > 25 Then Visible = 0
            If EnemyExplosion Or Damage Then
                Select Case ExplosionAnimationStep
                    Case 1 To 4: Color 12: If Damage Then _PaletteColor 0, _RGB32(28, 28, 28)
                    Case 5 To 8: Color 4: If Damage Then _PaletteColor 0, _RGBA32(0, 0, 0, 0)
                End Select
                If ExplosionAnimationStep = 8 Then Damage = 0
            Else
                Select Case ExplosionAnimationStep
                    Case 1 To 3: Color 15: _PaletteColor 0, _RGB32(120, 120, 120)
                    Case 4 To 6: Color 11: _PaletteColor 0, _RGB32(255, 255, 255)
                    Case 7 To 8: Color 3: _PaletteColor 0, _RGBA32(0, 0, 0, 0)
                End Select
            End If
            If Visible Then
                _PrintString (x(drawIt), y(drawIt)), Mid$(Boom$, ExplosionAnimationStep, 1)
            End If
        Next
        Color , 0
        Select Case ExplosionAnimationStep
            Case 1 To 4
                Color 8
                IF x > 0 AND x <= 80 AND RoundRow > 0 AND RoundRow <= 25 THEN _
                    _PRINTSTRING (x, RoundRow), CHR$(176)
            Case 5 To 7
                Color 8
                IF x > 0 AND x <= 80 AND RoundRow > 0 AND RoundRow <= 25 THEN _
                    _PRINTSTRING (x, RoundRow), CHR$(15)
            Case 8
                IF x > 0 AND x <= 80 AND RoundRow > 0 AND RoundRow <= 25 THEN _
                    _PRINTSTRING (x, RoundRow), " "
        End Select

        'Show earned points
        PointGoesUp! = PointGoesUp! - .3
        If RoundRow + PointGoesUp! >= 2 And RoundRow + PointGoesUp! <= 25 And x >= 1 And x <= 77 Then
            Select Case Abs(Int(PointGoesUp!))
                Case 1 To 2: Color 15
                Case 3: Color 7
                Case 4: Color 8
            End Select
            _PrintString (x, RoundRow + PointGoesUp!), LTrim$(RTrim$(Str$(LastEarnedPoints)))
        End If

        x = bx: y = by: row = brow!: RoundRow = _Ceil(row)
        If EnemyExplosion Then
            If ExplosionAnimationStep = 8 Then EnemyExplosion = 0
        Else
            Color 15, 4
            _PrintString (_Width \ 2 - Len(DeathMessage$) \ 2, _Height \ 2), DeathMessage$
            If ExplosionAnimationStep = 8 Then
                Energy = 0
                GoSub UpdateStats
                _Display
                StopSong
                _Delay 1
                Lives = Lives - 1
                LastShipGrow# = GetTICKS
                Alive = -1
                Shield = 0
                Freeze = 0
                Bonus.Active = 0
                ShipSize = 2: UpperLimit = 6: LowerLimit = 47: LeftLimit = 5
                Stars = 0
                Recharge = -1: InitialSetup = -1
                For id = 1 To MaxEnemies
                    Enemies(id).Hits = 0
                    CreateEnemy id, Chapter
                Next
                ShowChapterName# = GetTICKS
                PlaySong SONG(Level + 2)
                x = 5
                y = 25
            Else
                _Display
                _Delay .05
            End If
        End If
    End If

    If Pause = 0 And Alive = -1 Then
        If GoalAchieved Then Countdown# = GetTICKS: GoalAchieved = 0
        If Countdown# > 0 And GetTICKS - Countdown# > 5 Then PlaySound SNDFullRecharge: SetLevel Chapter + 1
    End If

    _Display
    _Limit 30
Loop Until Lives < 0

If Lives < 0 Then
    Color 15, 4
    PauseMessage$ = "   GAME OVER   "
    _PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, _Height \ 2), PauseMessage$
End If

PauseMessage$ = "  Press Start  "
_PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, _Height \ 2 + 1), PauseMessage$
_Display

Do
    If _KeyHit = 27 Then System
Loop Until GetButton("START", MyDevices(ChosenController).ID)

GoTo RestartGame

End

ShotsFired:
'Find an empty laser beam slot
For NewBeam = 1 To MaxBeams
    If Beams(NewBeam).X = 0 Or Beams(NewBeam).X > 80 Then Exit For
Next
If NewBeam > MaxBeams Then Return 'No available beam slots

'Check for the last beam StartTime so
'we don't fire multiple lasers too quickly:
If GetTICKS - LastBeam# < .2 Then Return
LastBeam# = GetTICKS

If ShipSize = 1 Then Energy = Energy - .5 Else Energy = Energy - .8

'Laser sound:
If ShipSize = 1 Then PlaySound SNDLaser1 Else PlaySound SNDLaser2

ShotsFired = -1
Beams(NewBeam).X = x
Beams(NewBeam).Y = RoundRow
Beams(NewBeam).Size = ShipSize * 2
Beams(NewBeam).StartTime = GetTICKS
Beams(NewBeam).Char = Char$
Return

EnemyShotsFired:
'Find an empty laser beam slot
For NewBeam = 1 To MaxEnemyBeams
    If EnemyBeams(NewBeam).X <= 0 Or GetTICKS - EnemyBeams(NewBeam).StartTime > .8 Then Exit For
Next
If NewBeam > MaxEnemyBeams Then Return 'No available beam slots

'Check for the last beam StartTime so
'we don't fire multiple lasers too quickly:
If GetTICKS - LastEnemyBeam# < .5 Then Return
LastEnemyBeam# = GetTICKS

EnemyBeams(NewBeam).ID = ShootingID
EnemyBeams(NewBeam).X = Enemies(ShootingID).X
EnemyBeams(NewBeam).Y = Enemies(ShootingID).Y
EnemyBeams(NewBeam).Size = 2
EnemyBeams(NewBeam).StartTime = GetTICKS
EnemyBeams(NewBeam).Char = Chr$(220)
Return

UpdateStats:
Color , 1
_PrintString (1, 1), String$(80, 32)
Color ShipColor
_PrintString (2, 1), Chr$(220) + Chr$(223) + Chr$(220)
Color 15
If Lives >= 0 Then _PrintString (6, 1), "x" + Str$(Lives) Else _PrintString (6, 1), "x 0"
_PrintString (12, 1), Str$(Points)
If Energy > 100 Then Energy = 100
If Int(Energy) <= 0 Then Energy = 0
If Mute Then Color 0, 7: _PrintString (20, 1), " MUTE ": Color , 1

If totalfreeze > 0 Then
    Color 11
    _PrintString (65, 1), String$(totalfreeze, 15)
End If

Color 15
TimeRemaining# = GetTICKS - Countdown#
If Countdown# > 0 And TimeRemaining# > 0 And TimeRemaining# <= 5 Then
    _PrintString (60, 25), " NEXT MISSION IN" + Str$(Int(5 - TimeRemaining#)) + " "
Else
    If GetTICKS - ShowChapterName# < 2 Then
        Color 15, 1
        PauseMessage$ = " Chapter" + Str$(Chapter) + " "
        _PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, _Height \ 2 - 1), PauseMessage$
        Pipe = InStr(ChapterName$, "|")
        If Pipe = 0 Then
            _PrintString (_Width \ 2 - Len(ChapterName$) \ 2, _Height \ 2), ChapterName$
        Else
            SecondLine$ = Left$(ChapterName$, Pipe - 1) + " "
            ThirdLine$ = " " + Mid$(ChapterName$, Pipe + 1)
            _PrintString (_Width \ 2 - Len(SecondLine$) \ 2, _Height \ 2), SecondLine$
            _PrintString (_Width \ 2 - Len(ThirdLine$) \ 2, _Height \ 2 + 1), ThirdLine$
        End If
    Else
        If GetTICKS - LastTipUpdate# > 15 Then
            LastTipUpdate# = GetTICKS
            LastTipShown# = GetTICKS
            If ChapterTips.Position > 0 Then
                Start.Position = ChapterTips.Position + 1
                ChapterTips.Position = InStr(Start.Position, ChapterTips$, Chr$(0))
                If ChapterTips.Position > 0 Then
                    NextTip$ = Mid$(ChapterTips$, Start.Position, ChapterTips.Position - Start.Position)
                Else
                    NextTip$ = Mid$(ChapterTips$, Start.Position)
                End If
                PlaySound SNDIntercom
            Else
                NextTip$ = ""
            End If
        End If

        If GetTICKS - LastTipShown# < 5 Then
            If Len(NextTip$) Then
                ThirdLine$ = ""
                Colon = InStr(NextTip$, ":")
                Pipe = InStr(NextTip$, "|")
                If Pipe Then
                    SecondLine$ = Mid$(NextTip$, Colon + 1, Pipe - Colon - 1)
                    ThirdLine$ = Mid$(NextTip$, Pipe + 1)
                Else
                    SecondLine$ = Mid$(NextTip$, Colon + 1)
                End If
                Color 15, 1
                _PrintString (1, 22), " " + Left$(NextTip$, Colon) + " "
                _PrintString (1, 23), " " + SecondLine$ + " "
                If Pipe Then
                    _PrintString (1, 24), " " + ThirdLine$ + " "
                End If
            End If
        End If
    End If

    If Freeze And Alive Then
        FreezeLeft = 10 - (GetTICKS - FreezeInitiated#)
        Color 9, 0
        If FreezeLeft <= 3 Then Color 9 + 16
        _PrintString (2, 3), String$(FreezeLeft, 219) + String$(10 - FreezeLeft, 220)
        Color 11
        If FreezeLeft <= 3 Then Color 11 + 16
        _PrintString (2, 4), "TIME FREEZE"
    End If
End If

If GetTICKS - ShieldONMessage# < 1 Then
    Color 0, 7
    PauseMessage$ = " SHIELD ENGAGED "
    _PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, 1), PauseMessage$
End If

If GetTICKS - ShieldOFFMessage# < 1 Then
    Color 0, 7
    If GetTICKS - ShieldInitiated# > 20 Then PauseMessage$ = " SHIELD RELEASED " Else PauseMessage$ = " SHIELD DESTROYED "
    _PrintString (_Width \ 2 - Len(PauseMessage$) \ 2, 1), PauseMessage$
End If

Color , 1

If Energy <= 10 And Alive = -1 And Recharge = 0 Then
    Color 15, 4
    If GetTICKS - EnergyWarning# > 1 Then
        EnergyWarning# = GetTICKS
        EnergyWarningText = Not EnergyWarningText
        If EnergyWarningText Then
            WarningMessage$ = " LOW RESOURCES "
        Else
            WarningMessage$ = "    DANGER!    "
        End If
    End If
    _PrintString (_Width \ 2 - Len(WarningMessage$) \ 2, 1), WarningMessage$
End If

EnergyStat$ = String$(Energy / 10, 254)
EnergyStat$ = EnergyStat$ + String$(10 - Len(EnergyStat$), 249)
Select Case Energy
    Case 0 To 10: Color 28, 1
    Case 11 To 30: Color 12, 1
    Case 31 To 60: Color 14, 1
    Case 61 To 100: Color 10, 1
End Select
If GetTICKS - LastEnergyUP# <= .2 Then
    If EnergyBlinkColor = 10 Then EnergyBlinkColor = 9 Else EnergyBlinkColor = 10
    Color EnergyBlinkColor
End If
_PrintString (70, 1), EnergyStat$

If KilledEnemies < ChapterGoal Then
    '_PRINTSTRING (30, 1), STR$(KilledEnemies) + "/" + STR$(ChapterGoal)
    'EnemiesLeft$ = STRING$((KilledEnemies / ChapterGoal) * 80, 219)
    'COLOR 4
    '_PRINTSTRING (1, 25), EnemiesLeft$
    _PutImage (0, 24 * _FontHeight), LifeBarImage, 0, (0, 0)-Step((KilledEnemies / ChapterGoal) * (80 * _FontWidth), _FontHeight)
    HideLifeBar! = 0
Else
    If HideLifeBar! < _FontHeight Then
        HideLifeBar! = HideLifeBar! + .3
        _PutImage (0, 24 * _FontHeight + HideLifeBar!), LifeBarImage, 0
    End If
End If

Color , 0
Return

FileError:
Resume Next

'Images: ---------------------------------------------------------------------------
SpaceshipLogo:
Data 313,56,15B,34W,188B,5W,32B,6W,33B,*
Data 13B,37W,185B,8W,30B,8W,32B,*
Data 11B,39W,185B,8W,30B,8W,32B,*
Data 11B,40W,183B,9W,29B,9W,32B,*
Data 10B,41W,183B,9W,29B,9W,32B,*
Data 9B,42W,183B,9W,29B,9W,32B,*
Data 9B,42W,182B,9W,30B,8W,33B,*
Data 8B,43W,182B,9W,30B,8W,33B,*
Data 8B,42W,183B,9W,30B,7W,34B,*
Data 8B,42W,183B,9W,31B,4W,36B,*
Data 7B,10W,24B,9W,182B,9W,72B,*
Data 7B,9W,25B,9W,3B,26W,11B,23W,14B,26W,13B,20W,14B,28W,4B,26W,15B,3W,6B,26W,5B,*
Data 7B,9W,25B,8W,4B,28W,8B,26W,9B,31W,8B,25W,9B,32W,3B,28W,11B,7W,4B,28W,3B,*
Data 7B,8W,26B,8W,3B,30W,6B,28W,7B,33W,6B,27W,7B,33W,3B,29W,9B,8W,3B,30W,2B,*
Data 6B,9W,26B,7W,4B,31W,4B,29W,6B,34W,5B,28W,6B,34W,2B,31W,7B,9W,3B,31W,1B,*
Data 6B,9W,28B,2W,7B,31W,4B,30W,5B,35W,4B,28W,5B,35W,2B,31W,7B,9W,3B,31W,1B,*
Data 6B,9W,37B,32W,3B,30W,4B,36W,3B,30W,3B,36W,2B,32W,6B,9W,3B,32W,*
Data 5B,37W,9B,33W,3B,30W,4B,36W,3B,30W,3B,36W,1B,33W,5B,9W,3B,33W,*
Data 5B,39W,7B,33W,3B,29W,4B,36W,3B,30W,3B,36W,2B,33W,5B,9W,3B,33W,*
Data 5B,40W,6B,33W,3B,29W,4B,36W,3B,30W,3B,36W,2B,33W,5B,9W,3B,33W,*
Data 5B,40W,6B,33W,3B,29W,4B,36W,3B,30W,3B,34W,4B,33W,5B,9W,3B,33W,*
Data 5B,41W,4B,9W,15B,10W,22B,10W,3B,10W,18B,9W,2B,10W,12B,9W,2B,9W,29B,9W,15B,10W,4B,9W,3B,9W,15B,10W,*
Data 5B,41W,4B,9W,15B,9W,23B,9W,4B,9W,19B,9W,2B,9W,12B,9W,3B,9W,29B,9W,15B,9W,5B,9W,3B,9W,15B,9W,1B,*
Data 6B,40W,4B,9W,15B,9W,5B,27W,4B,9W,19B,8W,3B,30W,3B,32W,6B,9W,15B,9W,5B,9W,3B,9W,15B,9W,1B,*
Data 6B,40W,4B,9W,15B,9W,4B,28W,4B,9W,19B,7W,4B,30W,3B,33W,5B,9W,15B,9W,5B,9W,3B,9W,15B,9W,1B,*
Data 7B,39W,3B,9W,16B,9W,3B,29W,3B,9W,21B,5W,4B,31W,3B,34W,3B,9W,16B,9W,4B,9W,3B,9W,16B,9W,1B,*
Data 9B,37W,3B,9W,15B,9W,3B,29W,4B,9W,30B,30W,4B,34W,3B,9W,15B,9W,5B,9W,3B,9W,15B,9W,2B,*
Data 36B,9W,4B,9W,15B,9W,2B,30W,4B,9W,30B,30W,4B,34W,3B,9W,15B,9W,5B,9W,3B,9W,15B,9W,2B,*
Data 6B,2W,28B,9W,3B,9W,16B,9W,2B,30W,3B,9W,30B,30W,5B,34W,2B,9W,16B,9W,4B,9W,3B,9W,16B,9W,2B,*
Data 3B,7W,26B,9W,3B,9W,16B,9W,1B,31W,3B,9W,22B,2W,6B,30W,5B,34W,2B,9W,16B,9W,4B,9W,3B,9W,16B,9W,2B,*
Data 2B,8W,26B,9W,3B,9W,15B,9W,2B,30W,4B,9W,19B,7W,4B,29W,7B,33W,2B,9W,15B,9W,5B,9W,3B,9W,15B,9W,3B,*
Data 2B,8W,25B,9W,4B,9W,15B,9W,2B,30W,4B,9W,19B,7W,4B,27W,10B,32W,2B,9W,15B,9W,5B,9W,3B,9W,15B,9W,3B,*
Data 1B,9W,25B,9W,3B,9W,16B,9W,1B,31W,3B,9W,19B,9W,2B,26W,15B,29W,1B,9W,16B,9W,4B,9W,3B,9W,16B,9W,3B,*
Data 1B,9W,24B,10W,3B,9W,15B,9W,2B,9W,13B,8W,4B,9W,19B,8W,3B,9W,52B,9W,1B,9W,16B,9W,4B,9W,3B,9W,15B,9W,4B,*
Data 1B,42W,4B,33W,2B,30W,4B,36W,3B,28W,7B,34W,2B,9W,15B,9W,5B,9W,3B,33W,4B,*
Data 1B,42W,4B,33W,2B,30W,4B,36W,3B,29W,4B,36W,2B,9W,15B,9W,5B,9W,3B,33W,4B,*
Data 43W,3B,33W,2B,31W,3B,37W,2B,30W,4B,36W,1B,9W,16B,9W,4B,9W,3B,33W,5B,*
Data 42W,4B,33W,2B,30W,4B,36W,3B,30W,3B,36W,2B,9W,16B,8W,5B,9W,3B,33W,5B,*
Data 42W,4B,32W,3B,30W,4B,36W,3B,30W,3B,36W,2B,9W,15B,9W,5B,9W,3B,32W,6B,*
Data 41W,5B,31W,4B,30W,4B,36W,3B,30W,3B,35W,3B,9W,15B,9W,5B,9W,3B,31W,7B,*
Data 40W,5B,32W,4B,30W,4B,35W,4B,30W,2B,35W,3B,9W,16B,9W,4B,9W,3B,32W,7B,*
Data 1B,38W,6B,31W,6B,28W,6B,33W,6B,28W,3B,34W,4B,9W,16B,8W,5B,9W,3B,31W,8B,*
Data 1B,37W,7B,29W,8B,28W,6B,32W,7B,27W,5B,32W,6B,7W,17B,8W,6B,7W,4B,29W,10B,*
Data 2B,34W,8B,28W,11B,27W,7B,29W,10B,25W,6B,30W,8B,6W,19B,5W,8B,6W,4B,28W,12B,*
Data 44B,9W,220B,9W,31B,*
Data 44B,9W,220B,9W,31B,*
Data 44B,9W,220B,9W,31B,*
Data 43B,9W,220B,9W,32B,*
Data 43B,9W,220B,9W,32B,*
Data 43B,9W,220B,9W,32B,*
Data 43B,9W,220B,9W,32B,*
Data 42B,9W,220B,9W,33B,*
Data 42B,9W,220B,9W,33B,*
Data 42B,8W,221B,8W,34B,*
Data 43B,6W,223B,6W,35B,*
Data 44B,3W,226B,3W,37B,*

Function GetButton (Name$, DeviceID As Integer)
    Dim i As Integer
    Static LastDevice As Integer

    'Initialize SHARED variables used for return codes
    GetButton.NotFound = 0
    GetButton.Found = -1
    GetButton.Multiple = -2

    'DeviceID must always be passed in case there are multiple
    'devices to query; If only one, 0 can be passed in subsequent
    'calls to this function.
    If DeviceID Then
        LastDevice = DeviceID
    Else
        If LastDevice = 0 Then Error 5
    End If

    If UseKeyboard = 0 Then
        'Read the device's buffer:
        Do While _DeviceInput(LastDevice): Loop

        If Len(Name$) Then
            'If button Name$ is passed, we look for that specific ID.
            'If pressed, we return -1
            For i = 1 To UBound(ButtonMap)
                If UCase$(RTrim$(ButtonMap(i).Name)) = UCase$(Name$) Then
                    'Found the requested button's ID.
                    'Time to query the controller:
                    GetButton = _Button(ButtonMap(i).ID) 'Return result maps to .NotFound = 0 or .Found = -1
                    Exit Function
                End If
            Next i
        Else
            'Otherwise we return every button whose state is -1
            'Return is passed by changing Name$ and GetButton then returns -2
            For i = 1 To _LastButton(LastDevice)
                If _Button(i) Then Name$ = Name$ + MKI$(i)
            Next i
            If Len(Name$) = 0 Then Exit Function
            If Len(Name$) = 2 Then GetButton = GetButton.Found Else GetButton = GetButton.Multiple
        End If
    Else
        If Len(Name$) Then
            'If button Name$ is passed, we look for that specific ID.
            'If pressed, we return -1
            For i = 1 To UBound(ButtonMap)
                If UCase$(RTrim$(ButtonMap(i).Name)) = UCase$(Name$) Then
                    'Found the requested button's ID.
                    'Time to query the controller:
                    GetButton = _KeyDown(ButtonMap(i).ID) 'Return result maps to .NotFound = 0 or .Found = -1
                    Exit Function
                End If
            Next i
        End If
    End If
End Function

Sub CreateStar (id, create_at_edge)
    If create_at_edge Then
        'will create star at right edge, create values based on that
        Starfield(id).X = 80
    Else
        'will create stars scattered to fill the first frame, create values based on that
        Starfield(id).X = Int(Rnd * 80 + 1)
    End If
    Starfield(id).Y = Int(Rnd * 24 + 1) + 1
    'speed in pixels per frame, will be used later to have layers of stars that appear to move at different speeds.
    Starfield(id).RelativeSpeed = Int(Rnd * 3 + 1)

    Select Case Starfield(id).RelativeSpeed
        Case 1: Starfield(id).Color = 8: Starfield(id).Char = Chr$(250)
        Case 2: Starfield(id).Color = 8: Starfield(id).Char = Chr$(249)
        Case 3: Starfield(id).Color = 7: Starfield(id).Char = Chr$(249)
    End Select
End Sub

Sub CreateBonus
    Dim B%
    Shared ShipSize As _Byte, Shield As _Byte, SNDShieldAPPEAR, Recharge As _Byte
    Shared Freeze, SNDBlizzard
    Shared LastLife#, LastEnergy#, LastShield#, LastFreeze#
    Shared totalfreeze

    If Recharge Then Exit Sub

    B% = _Ceil(Rnd * 4)
    Select Case B%
        Case 1 'Life
            IF (GetTICKS - LastLife# > 60 AND ShipSize = 2) OR _
               (GetTICKS - LastLife# > 15 AND ShipSize = 1) THEN
                LastLife# = GetTICKS
                Bonus.Type$ = "LIFE"
                Bonus.Active = -1
                If ShipSize = 1 Then Bonus.Color = 4 Else Bonus.Color = 2
                Bonus.X = 80
                Bonus.Height = 3
                Bonus.Width = 7
                Bonus.Shape$ = Chr$(220) + Chr$(219) + Chr$(219) + Chr$(220) + Chr$(219) + Chr$(219) + Chr$(220) + Chr$(223) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(223) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(219) + Chr$(223) + Chr$(32) + Chr$(32)
                Bonus.Y = _Ceil(Rnd * (24 - Bonus.Height)) + 1
                Bonus.Speed# = .2
            End If
        Case 2 'Energy
            If GetTICKS - LastEnergy# > 20 Or Energy < 10 Then
                LastEnergy# = GetTICKS
                Bonus.Type$ = "ENERGY"
                Bonus.Active = -1
                Bonus.X = 80
                Bonus.Color = 10
                Bonus.Height = 3
                Bonus.Width = 10
                'Bonus.Shape$ = CHR$(218) + STRING$(4, 196) + CHR$(191) + " "
                'Bonus.Shape$ = Bonus.Shape$ + CHR$(179) + STRING$(4, 254) + CHR$(198) + CHR$(240)
                'Bonus.Shape$ = Bonus.Shape$ + CHR$(192) + STRING$(4, 196) + CHR$(217)
                Bonus.Shape$ = Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(219) + Chr$(254) + Chr$(254) + Chr$(254) + Chr$(254) + Chr$(254) + Chr$(254) + Chr$(254) + Chr$(219) + Chr$(8) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32)
                Bonus.Y = _Ceil(Rnd * (24 - Bonus.Height)) + 1
                Bonus.Speed# = .05
            End If
        Case 3 'Shield
            If GetTICKS - LastShield# > 120 And Shield = 0 Then
                PlaySound SNDShieldAPPEAR
                LastShield# = GetTICKS
                Bonus.Type$ = "SHIELD"
                Bonus.Active = -1
                Bonus.X = 80
                Bonus.Color = -1 'Makes it random
                Bonus.Height = 4
                Bonus.Width = 7
                Bonus.Shape$ = String$(7, 176)
                Bonus.Shape$ = Bonus.Shape$ + Chr$(176) + "     " + Chr$(176)
                Bonus.Shape$ = Bonus.Shape$ + Chr$(176) + "     " + Chr$(176)
                Bonus.Shape$ = Bonus.Shape$ + String$(7, 176)
                Bonus.Y = _Ceil(Rnd * (24 - Bonus.Height)) + 1
                Bonus.Speed# = .08
            End If
        Case 4 'Freeze power
            If GetTICKS - LastFreeze# > 90 And Freeze = 0 And totalfreeze < 3 Then
                PlaySound SNDBlizzard
                LastFreeze# = GetTICKS
                Bonus.Type$ = "FREEZE"
                Bonus.Active = -1
                Bonus.X = 80
                Bonus.Color = -2 'Custom colors
                m$ = MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(3) + MKI$(9) + MKI$(3) + MKI$(9) + MKI$(3)
                Bonus.ColorPattern = m$
                Bonus.ColorSteps = Len(m$) / 2
                Bonus.CurrentColorStep = 1
                Bonus.Height = 7
                Bonus.Width = 11
                Bonus.Shape$ = Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(9) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(9) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(9) + Chr$(32) + Chr$(4) + Chr$(249) + Chr$(92) + Chr$(32) + Chr$(31) + Chr$(32) + Chr$(47) + Chr$(249) + Chr$(4) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(4) + Chr$(196) + Chr$(16) + Chr$(15) + Chr$(17) + Chr$(196) + Chr$(4) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(4) + Chr$(249) + Chr$(47) + Chr$(32) + Chr$(30) + Chr$(32) + Chr$(92) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(9) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(32) + Chr$(4) + Chr$(32) + Chr$(9) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(9) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32)
                Bonus.Y = _Ceil(Rnd * (24 - Bonus.Height)) + 1
                Bonus.Speed# = .08
            End If
    End Select
End Sub

Sub ReverseEnemyPattern (id)
    For i = 1 To Enemies(id).MoveSteps
        MoveY = CVI(Mid$(Enemies(id).MovePattern, (i * 2) - 1, 2))
        Mid$(Enemies(id).MovePattern, (i * 2) - 1, 2) = MKI$(-MoveY)
    Next i
End Sub

Sub MakeEnemyEscape (id)
    'Some will go up, some will go down.
    If Enemies(id).Y > 12 Then
        m$ = MKI$(-1)
    Else
        m$ = MKI$(1)
    End If
    Enemies(id).CanReverse = 0
    Enemies(id).MovePattern = m$
    Enemies(id).MoveSteps = Len(m$) / 2
    Enemies(id).CurrentMoveStep = 1
    Enemies(id).CanShoot = 0
End Sub

Sub CreateEnemy (id, Chapter)
    Shared Energy As Single, RoundRow As Integer

    Dim a As _Byte
    If Bonus.Active = 0 Then CreateBonus
    Select Case Chapter
        Case 1
            If Enemies(id).Hits <= 0 Then
                Enemies(id).X = 80 + _Ceil(Rnd * 80)
                Enemies(id).Y = _Ceil(Rnd * 24) + 1
                Enemies(id).Color = 12
                Enemies(id).Points = 50
                Enemies(id).RelativeSpeed = 1 'INT(RND * 2 + 1)
                Enemies(id).Hits = 2
                Restore EnemyShip1
                GoSub LoadShape
                Enemies(id).CurrentShape = _Ceil(Rnd * 2)
                'Some will go up, some will go down.
                If Enemies(id).Y > 12 Then
                    m$ = MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1)
                Else
                    m$ = MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(1) + MKI$(1) + MKI$(1) + MKI$(1)
                End If
                Enemies(id).MovePattern = m$
                Enemies(id).CanReverse = -1
                Enemies(id).Chase = 0
                Enemies(id).MoveSteps = Len(m$) / 2
                Enemies(id).CurrentMoveStep = _Ceil(Rnd * Enemies(id).MoveSteps)
                Enemies(id).CanShoot = -1
            Else
                'Enemy not yet killed, so we'll turn it into its second form
                Enemies(id).Color = 4
                Enemies(id).Points = 25
                Enemies(id).RelativeSpeed = 2 'INT(RND * 2 + 1)
                Enemies(id).Shape = Chr$(32) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(222) + Chr$(219) + Chr$(176) + Chr$(221) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32)
                Enemies(id).TotalShapes = 1
                Enemies(id).CurrentShape = 1
                Enemies(id).Width = 5
                Enemies(id).Height = 3
                'Some will go up, some will go down.
                If Enemies(id).Y > 12 Then
                    m$ = MKI$(-1)
                Else
                    m$ = MKI$(1)
                End If
                Enemies(id).CanReverse = 0
                Enemies(id).MovePattern = m$
                Enemies(id).MoveSteps = Len(m$) / 2
                Enemies(id).CurrentMoveStep = _Ceil(Rnd * Enemies(id).MoveSteps)
                Enemies(id).CanShoot = 0
            End If
        Case 2
            If Enemies(id).Hits <= 0 Then
                Enemies(id).X = 80 + _Ceil(Rnd * 80)
                Enemies(id).Y = _Ceil(Rnd * 24) + 1
                Enemies(id).Color = -2
                Do
                    RandomColor = _Ceil(Rnd * 8) + 7
                Loop While RandomColor = ShipColor Or RandomColor = 8
                m$ = MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(8) + MKI$(8) + MKI$(8) + MKI$(8) + MKI$(8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8) + MKI$(RandomColor - 8)
                Enemies(id).ColorPattern = m$
                Enemies(id).ColorSteps = Len(m$) / 2
                Enemies(id).CurrentColorStep = 1
                Enemies(id).Points = 100
                Enemies(id).RelativeSpeed = _Ceil(Rnd * 2)
                Enemies(id).Hits = 2
                ThisDesign$ = Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(222) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(221) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32)
                ThisDesign$ = ThisDesign$ + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(222) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(8) + Chr$(219) + Chr$(221) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32) + Chr$(32) + Chr$(32) + Chr$(32)
                Enemies(id).Shape = ThisDesign$
                Enemies(id).TotalShapes = 2
                Enemies(id).CurrentShape = _Ceil(Rnd * 2)
                Enemies(id).Width = 15
                Enemies(id).Height = 5
                If Enemies(id).Y > 12 Then
                    m$ = MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(-1)
                Else
                    m$ = MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(1)
                End If
                Enemies(id).MovePattern = m$
                Enemies(id).CanReverse = -1
                Enemies(id).Chase = 0
                Enemies(id).MoveSteps = Len(m$) / 2
                Enemies(id).CurrentMoveStep = _Ceil(Rnd * Enemies(id).MoveSteps)
                Enemies(id).CanShoot = -1
            Else
                'Enemy not yet killed, will try to run away wounded
                Enemies(id).Color = 8
                Enemies(id).Points = 50
                Enemies(id).RelativeSpeed = 3 'INT(RND * 2 + 1)
                'Some will go up, some will go down.
                If Enemies(id).Y > 12 Then
                    m$ = MKI$(-1)
                Else
                    m$ = MKI$(1)
                End If
                Enemies(id).CanReverse = 0
                Enemies(id).MovePattern = m$
                Enemies(id).MoveSteps = Len(m$) / 2
                Enemies(id).CurrentMoveStep = _Ceil(Rnd * Enemies(id).MoveSteps)
                Enemies(id).CanShoot = 0
            End If
        Case 3
            If Enemies(id).Hits <= 0 Then
                Enemies(id).X = 80 + _Ceil(Rnd * 20)
                Enemies(id).Y = _Ceil(Rnd * 24) + 1
                Enemies(id).Color = 5
                Enemies(id).Hits = 1
                Enemies(id).Points = 50
                Enemies(id).RelativeSpeed = 1
                Enemies(id).Shape = Chr$(32) + Chr$(220) + Chr$(220) + Chr$(220) + Chr$(32) + Chr$(222) + Chr$(219) + Chr$(176) + Chr$(221) + Chr$(32) + Chr$(32) + Chr$(223) + Chr$(223) + Chr$(223) + Chr$(32)
                Enemies(id).TotalShapes = 1
                Enemies(id).CurrentShape = 1
                Enemies(id).Width = 5
                Enemies(id).Height = 3
                'Some will go up, some will go down.
                If Enemies(id).Y > 12 Then
                    m$ = MKI$(0) + MKI$(0) + MKI$(-1)
                Else
                    m$ = MKI$(0) + MKI$(0) + MKI$(1)
                End If
                Enemies(id).Chase = -1
                Enemies(id).CanReverse = -1
                Enemies(id).MovePattern = m$
                Enemies(id).MoveSteps = Len(m$) / 2
                Enemies(id).CurrentMoveStep = _Ceil(Rnd * Enemies(id).MoveSteps)
                Enemies(id).CanShoot = 0
            End If
        Case 4
            If Enemies(id).Hits <= 0 Then
                Enemies(id).X = 80 + _Ceil(Rnd * 80)
                Enemies(id).Y = _Ceil(Rnd * 24) + 1
                Enemies(id).Color = -2
                m$ = MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(9) + MKI$(3) + MKI$(9) + MKI$(3) + MKI$(9) + MKI$(3)
                Enemies(id).ColorPattern = m$
                Enemies(id).ColorSteps = Len(m$) / 2
                Enemies(id).CurrentColorStep = 1
                Enemies(id).Hits = 100
                Enemies(id).Points = 50
                Enemies(id).RelativeSpeed = 1
                Enemies(id).CurrentShape = 1 '_CEIL(RND * 2)
                Restore SpaceAmoeba
                GoSub LoadShape:
                'Some will go up, some will go down.
                m$ = MKI$(0) + MKI$(0) + MKI$(0) + MKI$(0) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1) + MKI$(-1)
                Enemies(id).Chase = 0
                Enemies(id).CanReverse = -1
                Enemies(id).MovePattern = m$
                If Enemies(id).Y <= 12 Then
                    ReverseEnemyPattern id
                End If
                Enemies(id).MoveSteps = Len(m$) / 2
                Enemies(id).CurrentMoveStep = _Ceil(Rnd * Enemies(id).MoveSteps)
                Enemies(id).CanShoot = -1
            End If
    End Select

    Exit Sub
    LoadShape:
    Read Enemies(id).Width, Enemies(id).Height, Enemies(id).TotalShapes
    For i = 1 To (Enemies(id).Width * Enemies(id).Height * Enemies(id).TotalShapes)
        Read ThisChar
        Asc(Enemies(id).Shape, i) = ThisChar
    Next
    Return

    EnemyShip1:
    Data 5,3,2,32,32,220,220,220,222,219,178,177,221,32,32,223,223,223,32,32,220,220,220,222,219,176,176,221,32,32,223,223,223

    SpaceAmoeba:
    Data 32,14,8
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,220,220,220,220,220,220,220,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,32,223,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,223,223,223,223,223,223,223,223,223,223,223,223,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,220,220,220,220,220,220,220,220,220,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,223,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,223,223,223,223,223,223,223,223,223,223,223,223,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,220,220,220,220,220,220,220,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,32,223,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,223,223,223,223,223,223,223,223,223,223,223,223,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,220,220,220,220,220,220,220,220,220,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,220,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,223,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,223,223,223,223,223,223,223,223,223,223,223,223,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,220,220,220,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,32,32,220,220,220,176,176,176,176,176,176,220,220,220,32,32,220,220,32,32,32,32,32,32,32,32,32,32,32,222,176,176,220,220,176,176,176,176,176,176,176,176,176,176,176,176,220,220,176,176,222,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,222,176,176,176,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,223,176,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,223,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,223,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,223,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,223,223,223,223,176,176,176,176,176,176,223,223,176,176,176,176,176,176,223,223,223,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,223,223,223,223,223,32,32,223,223,223,223,223,223,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,4,4,4,4,4,4,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,4,4,32,32,4,4,4,176,176,176,176,176,176,4,4,4,32,32,4,4,32,32,32,32,32,32,32,32,32,32,32,4,176,176,4,4,176,176,176,176,176,176,176,176,176,176,176,176,4,4,176,176,4,32,32,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,32,4,4,4,4,176,176,176,176,176,176,4,4,176,176,176,176,176,176,4,4,4,4,32,32,32,32,32,32,32,32,32,32,32,32,32,32,4,4,4,4,4,4,32,32,4,4,4,4,4,4,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,220,220,220,220,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,220,220,32,32,220,220,220,176,176,176,176,176,176,220,220,220,32,32,220,220,32,32,32,32,32,32,32,32,32,32,32,222,176,176,220,220,176,176,176,176,176,176,176,176,176,176,176,176,220,220,176,176,222,32,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,222,176,176,176,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,223,176,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,223,32,32,32,32,32,32,32,32,220,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,220,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,223,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,223,32,32,32,32,32,32,32,32,222,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,222,32,32,32,32,32,32,32,32,32,223,223,223,223,176,176,176,176,176,176,223,223,176,176,176,176,176,176,223,223,223,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,223,223,223,223,223,32,32,223,223,223,223,223,223,32,32,32,32,32,32,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,4,4,4,4,4,4,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,4,4,32,32,4,4,4,176,176,176,176,176,176,4,4,4,32,32,4,4,32,32,32,32,32,32,32,32,32,32,32,4,176,176,4,4,176,176,176,176,176,176,176,176,176,176,176,176,4,4,176,176,4,32,32,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,251,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,251,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,8,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,4,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,4,32,32,32,32,32,32,32,32,32,4,4,4,4,176,176,176,176,176,176,4,4,176,176,176,176,176,176,4,4,4,4,32,32,32,32,32,32,32,32,32,32,32,32,32,32,4,4,4,4,4,4,32,32,4,4,4,4,4,4,32,32,32,32,32,32,32,32,32

    Cockroach:
    Data 28,14,4
    Data 32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,220,220,220,220,220,220,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,220,176,176,176,176,176,176,220,32,178,32,32,32,32,32,32,32,32,178,178,178,178,32,32,32,32,178,220,176,176,178,176,176,178,176,176,220,178,32,32,32,32,178,178,178,178,32,32,32,32,178,178,178,32,220,176,176,178,176,176,176,176,178,176,176,220,32,178,178,178,32,32,32,32,32,32,32,32,32,32,32,178,176,176,178,176,176,176,176,176,176,178,176,176,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,176,176,176,178,176,176,176,176,178,176,176,176,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,176,176,176,178,176,176,178,176,176,176,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,223,176,178,176,176,176,176,178,176,223,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,223,176,178,176,176,178,176,223,32,32,178,32,32,32,32,32,32,32,178,178,178,32,32,32,32,178,32,32,32,223,223,223,223,223,223,32,32,32,178,32,32,32,32,178,178,178,32,32,32,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,178,178,178,32,32,32
    Data 32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,220,220,220,220,220,220,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,220,176,176,176,176,176,176,220,32,32,178,32,32,32,32,32,32,32,178,178,178,32,32,32,32,32,178,220,176,176,178,176,176,178,176,176,220,178,32,32,32,32,32,178,178,178,32,32,32,178,32,32,32,32,220,176,176,178,176,176,176,176,178,176,176,220,32,32,32,32,178,32,32,32,32,32,32,32,178,178,178,178,176,176,178,176,176,176,176,176,176,178,176,176,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,176,176,176,178,176,176,176,176,178,176,176,176,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,176,176,176,178,176,176,178,176,176,176,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,223,176,178,176,176,176,176,178,176,223,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,223,176,178,176,176,178,176,223,32,32,178,32,32,32,32,32,32,32,178,178,178,32,32,32,32,178,32,32,32,223,223,223,223,223,223,32,32,32,178,32,32,32,32,178,178,178,32,32,32,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,178,178,178,32,32,32
    Data 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,178,178,32,32,32,32,32,32,32,220,220,220,220,220,220,32,32,32,32,32,32,32,178,178,178,32,32,32,32,32,178,178,178,32,32,32,220,176,176,176,176,176,176,220,32,32,32,178,178,178,32,32,32,32,178,178,178,32,32,32,32,178,178,220,176,176,178,176,176,178,176,176,220,178,178,32,32,32,32,178,178,178,32,32,32,178,32,32,32,32,220,176,176,178,176,176,176,176,178,176,176,220,32,32,32,32,178,32,32,32,32,32,32,32,178,178,178,178,176,176,178,176,176,176,176,176,176,178,176,176,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,176,176,176,178,176,176,176,176,178,176,176,176,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,176,176,176,178,176,176,178,176,176,176,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,223,176,178,176,176,176,176,178,176,223,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,223,176,178,176,176,178,176,223,32,32,178,32,32,32,32,32,32,32,178,178,178,32,32,32,32,178,32,32,32,223,223,223,223,223,223,32,32,32,178,32,32,32,32,178,178,178,32,32,32,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,178,178,178,32,32,32
    Data 32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,32,32,220,220,220,220,220,220,32,32,32,32,178,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,220,176,176,176,176,176,176,220,32,32,178,32,32,32,32,32,32,32,178,178,178,32,32,32,32,32,178,220,176,176,178,176,176,178,176,176,220,178,32,32,32,32,32,178,178,178,32,32,32,178,32,32,32,32,220,176,176,178,176,176,176,176,178,176,176,220,32,32,32,32,178,32,32,32,32,32,32,32,178,178,178,178,176,176,178,176,176,176,176,176,176,178,176,176,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,176,176,176,178,176,176,176,176,178,176,176,176,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,223,176,176,176,178,176,176,178,176,176,176,223,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,223,176,178,176,176,176,176,178,176,223,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,32,32,223,176,178,176,176,178,176,223,32,32,178,32,32,32,32,32,32,32,178,178,178,32,32,32,32,178,32,32,32,223,223,223,223,223,223,32,32,32,178,32,32,32,32,178,178,178,32,32,32,178,178,178,178,32,32,32,32,32,32,32,32,32,32,32,32,32,32,178,178,178,178,32,32,32

End Sub

Sub DrawElements
    'Besides drawing elements, this sub fills the array ScreenMap,
    'which is used for lazy collision detection in the main game loop.

    Dim x As Integer, y As Integer, c As Integer
    Dim id As Integer, Char$
    Shared Pause As _Byte, Alive As _Byte, Visible As _Byte
    Shared StarFieldSpeed As Double, LastEnergyUP#
    Shared EnergyBlinkColor As _Byte
    Static LastBonusUpdate#

    'Stars
    For id = 1 To MaxStars
        Visible = -1
        If Starfield(id).X < 1 Or Starfield(id).X > 80 Then Visible = 0
        If Starfield(id).Y < 1 Or Starfield(id).Y > 25 Then Visible = 0
        If Visible Then
            Color Starfield(id).Color
            Char$ = Starfield(id).Char
            If StarFieldSpeed = 0 Then Char$ = Chr$(196)
            _PrintString (Starfield(id).X, Starfield(id).Y), Char$
        End If
    Next

    Erase ScreenMap
    'any bonus?
    If Bonus.Active = -1 Then
        If Bonus.Color = -1 Then
            'Random colors
            Color _Ceil(Rnd * 14) + 1
        ElseIf Bonus.Color = -2 Then 'Custom color pattern
            Color CVI(Mid$(Bonus.ColorPattern, (Bonus.CurrentColorStep * 2) - 1, 2))
            Bonus.CurrentColorStep = Bonus.CurrentColorStep Mod Bonus.ColorSteps + 1
        ElseIf (Bonus.Type$ = "ENERGY" And GetTICKS - LastEnergyUP# <= .2) Then
            If EnergyBlinkColor = 10 Then EnergyBlinkColor = 9 Else EnergyBlinkColor = 10
            Color EnergyBlinkColor
        Else
            Color Bonus.Color
        End If
        x = 1
        y = 1
        c = 1
        Do
            If Bonus.X + (x - 1) > 0 And Bonus.X + (x - 1) <= 80 Then 'Visible?
                Char$ = Mid$(Bonus.Shape$, c, 1)
                If Char$ = " " Then Char$ = ""
                _PrintString (Bonus.X + x - 1, Bonus.Y + y - 1), Char$
                If Char$ <> Chr$(32) Then ScreenMap(Bonus.X + x - 1, Bonus.Y + y - 1) = ScreenMap.Bonus
            End If
            c = c + 1
            If c > Len(Bonus.Shape$) Then Exit Do 'Incomplete shape
            x = x + 1
            If x > Bonus.Width Then x = 1: y = y + 1
            If y > Bonus.Height Then Exit Do
        Loop
    End If

    If GetTICKS - LastBonusUpdate# > Bonus.Speed# And Pause = 0 And Alive = -1 Then
        LastBonusUpdate# = GetTICKS
        Bonus.X = Bonus.X - 1
        If Bonus.X + Bonus.Width < 0 Then Bonus.Active = 0
    End If

    'enemies too
    VisibleEnemies = 0
    For id = 1 To MaxEnemies
        'Rotate enemy's shape frames
        If (GetUptime / 1000) - Enemies(id).LastFrameUpdate > .3 Then
            Enemies(id).LastFrameUpdate = (GetUptime / 1000)
            Enemies(id).CurrentShape = Enemies(id).CurrentShape Mod Enemies(id).TotalShapes + 1
        End If

        If Enemies(id).Color = -1 Then
            Color _Ceil(Rnd * 14) + 1
        ElseIf Enemies(id).Color = -2 Then 'Custom color pattern
            Color CVI(Mid$(Enemies(id).ColorPattern, (Enemies(id).CurrentColorStep * 2) - 1, 2))
            Enemies(id).CurrentColorStep = Enemies(id).CurrentColorStep Mod Enemies(id).ColorSteps + 1
        Else
            Color Enemies(id).Color
        End If
        x = 1
        y = 1
        c = 1
        AnyPartVisible = 0
        Enemies(id).IsVisible = 0
        TotalShapeChars = (Enemies(id).Width * Enemies(id).Height)
        ThisShape$ = Mid$(Enemies(id).Shape, Enemies(id).CurrentShape * TotalShapeChars - TotalShapeChars + 1, TotalShapeChars)
        Do
        IF Enemies(id).X + (x - 1) > 0 AND Enemies(id).X + (x - 1) <= 80 AND _
            Enemies(id).Y + (y - 1) > 1 AND Enemies(id).Y + (y - 1) <= 25 THEN 'Visible?
                AnyPartVisible = -1
                Char$ = Mid$(ThisShape$, c, 1)
                If Char$ <> " " Then
                    _PrintString (Enemies(id).X + x - 1, Enemies(id).Y + y - 1), Char$
                    ScreenMap(Enemies(id).X + x - 1, Enemies(id).Y + y - 1) = -id
                End If
            End If
            c = c + 1
            x = x + 1
            If x > Enemies(id).Width Then x = 1: y = y + 1
            If y > Enemies(id).Height Then Exit Do
        Loop
        If AnyPartVisible Then VisibleEnemies = VisibleEnemies + 1
        Enemies(id).IsVisible = -1
    Next
End Sub

Sub PlaySound (Handle&)
    If Handle& = 0 Or Mute Then Exit Sub

    _SndPlayCopy Handle&
End Sub

Sub PlaySong (Handle&)
    If Handle& = 0 Or Mute Then Exit Sub

    For i = 1 To UBound(SONG)
        If Handle& <> SONG(i) Then
            If SONG(i) Then _SndStop SONG(i)
        End If
    Next

    If Not _SndPlaying(Handle&) Then _SndLoop Handle&
End Sub

Sub PauseSong
    For i = 1 To UBound(SONG)
        If SONG(i) Then _SndPause SONG(i)
    Next
End Sub

Sub StopSong
    For i = 1 To UBound(SONG)
        If SONG(i) Then _SndStop SONG(i)
    Next
End Sub

Sub SetLevel (Which)
    Shared StarFieldSpeed As Double, EnemiesSpeed As Double
    Shared BackupStarFieldSpeed As Double
    Shared MaxEnemies As Integer, ShowChapterName#
    Shared ChapterName$
    Shared ChapterTips$, ChapterTips.Position

    TotalChapters = 3
    Recharge = -1
    Energy = 0
    GoalAchieved = 0
    KilledEnemies = 0
    Countdown# = 0
    BossFight = 0

    Select Case Which
        Case 1
            StarFieldSpeed = .08
            EnemiesSpeed = .08
            If MaxEnemies = 0 Then MaxEnemies = 10
            MaxEnemies = 10
            Chapter = Which
            For id = 1 To MaxEnemies
                If Enemies(id).Hits > 0 Then MakeEnemyEscape id Else CreateEnemy id, Chapter
            Next
            ChapterName$ = " LET THERE BE WAR! "
            ChapterTips$ = Chr$(0) + "BASE:BEST OF LUCK, CAPTAIN."
            ChapterTips$ = ChapterTips$ + Chr$(0) + "BASE:I SEE TEN OF THEM ON THE RADAR"
            ChapterTips$ = ChapterTips$ + Chr$(0) + "CAPTAIN:IT'S FUNNY... THEIR MOVEMENT|SEEMS RANDOM AT TIMES"
            ChapterTips$ = ChapterTips$ + Chr$(0) + "CAPTAIN:SOMETIMES I CAN ALMOST|BELIEVE THEY'RE COORDINATED"
            ChapterTips.Position = 1
            ShowChapterName# = GetTICKS
            ChapterGoal = 50
        Case 2
            StarFieldSpeed = .08
            EnemiesSpeed = .1
            ChapterName$ = " LOOKING FOR FLYING SAUCERS|IN THE SKY "
            ChapterTips$ = Chr$(0) + "BASE:WATCH OUT, CAPTAIN!|WE DON'T KNOW WHAT THEY CAN DO."
            ChapterTips$ = ChapterTips$ + Chr$(0) + "CAPTAIN:I CAN'T AFFORD A DAMAGED UNIT NOW"
            ChapterTips.Position = 1
            ShowChapterName# = GetTICKS
            ChapterGoal = 50
            Chapter = Which
            MaxEnemies = 10
            For id = 1 To MaxEnemies
                If Enemies(id).Hits > 0 Then MakeEnemyEscape id Else CreateEnemy id, Chapter
            Next
        Case 3
            StarFieldSpeed = .08
            EnemiesSpeed = .1
            Chapter = Which
            ChapterName$ = " KAMIKAZE FRENZY "
            ChapterTips$ = Chr$(0) + "BASE:THIS IS MADNESS!"
            ChapterTips$ = ChapterTips$ + Chr$(0) + "BASE:THESE PILOTS AREN'T AFRAID OF DYING"
            ChapterTips$ = ChapterTips$ + Chr$(0) + "CAPTAIN:I MUST NOT USE ALL MY SHIP'S ENERGY"
            ChapterTips.Position = 1
            ShowChapterName# = GetTICKS
            ChapterGoal = 100
            MaxEnemies = 10
            For id = 1 To MaxEnemies
                If Enemies(id).Hits > 0 Then MakeEnemyEscape id Else CreateEnemy id, Chapter
            Next
        Case 4
            StarFieldSpeed = .08
            EnemiesSpeed = .1
            Chapter = Which
            ChapterName$ = " SPACE AMOEBA "
            ChapterTips$ = Chr$(0) + "BASE:THESE ARE NOT METAL SHIPS, CAPTAIN!"
            ChapterTips$ = ChapterTips$ + Chr$(0) + "BASE:THESE CREATURES ARE RADIOACTIVE!"
            ChapterTips$ = ChapterTips$ + Chr$(0) + "CAPTAIN:I GOTTA DO WHAT I GOTTA DO.|LET THEM EAT LASER!"
            ChapterTips.Position = 1
            ShowChapterName# = GetTICKS
            ChapterGoal = 2
            For id = 1 To MaxEnemies
                If Enemies(id).Hits > 0 Then MakeEnemyEscape id
            Next
            MaxEnemies = 1
            CreateEnemy MaxEnemies, Chapter
            BossFight = -1
            PlaySong SONG(2)
        Case Else
            Chapter = 1
            SetLevel Chapter
    End Select

    BackupStarFieldSpeed = StarFieldSpeed
    BackupEnemiesSpeed = EnemiesSpeed
End Sub

Function GetTICKS#
    Static LastTICKS#

    If Not Pause Then
        LastTICKS# = (GetUptime / 1000) - PauseOffset#
    End If

    GetTICKS# = LastTICKS#
End Function

Sub KillEnemy (id, Strength)
    Enemies(id).Hits = Enemies(id).Hits - Strength
    Enemies(id).X = Enemies(id).X + 5
    If Enemies(id).Hits <= 0 Then
        KilledEnemies = KilledEnemies + 1
        WeKilledFirst = -1
        If KilledEnemies = ChapterGoal Then GoalAchieved = -1
    End If
    CreateEnemy id, Chapter
End Sub

Function RestoreImage& (PixelColor~&)
    'This function must be called after RESTORE is used to
    'point to the correct DATA block
    Read w
    Read h
    a& = _NewImage(w, h, 32)
    PrevDEST& = _Dest
    _Dest a&
    ih = 0: iw = 0
    Do
        Read b$
        If b$ = "*" Then
            ih = ih + 1
            iw = 0
            If ih = h Then Exit Do
        End If
        c% = Val(Left$(b$, Len(b$) - 1))
        If Right$(b$, 1) = "W" Then
            For p = iw To iw + c%
                PSet (p, ih), PixelColor~&
            Next
        End If
        iw = iw + c%
    Loop
    RestoreImage& = _CopyImage(a&, 33)
    _FreeImage a&
    _Dest PrevDEST&
End Function


