' ******************************************************************************************************************
' * Big thanks to Terry Ritchie, MasterGy, bplus and S.McNeill for bits of code! *  { Project started Feb, 2024 }  *
' ******************************************************************************************************************
'  Mac Version: The 7 game chapters: Harvest Time, Comets, Rock Field, Landing & Recharge, Saucer Attack, The Cage & The Gauntlet
'  ***********
'                                                 >>>> ROCK JOCKEY 2.1 <<<<      >  UPGRADES and DEBUGS:  last updated 8/4/25: see below **
Option _Explicit '                               12/17/24, originally posted        -------------------   ********************
'                                                       by NakedApe              x  ADD PRACTICE MODE
Const SWIDTH = 1280, SHEIGHT = 720, LINEX = 140 '      aka Ted Kluger            x  FIX SHIP LOCKUPS AND BUGGY SHIP EXPLOSIONS
Const CENTX = SWIDTH \ 2, CENTY = SHEIGHT \ 2 '                                  x  DO GAMESPEED OPTIONS, SLOW, MED, FAST
Dim mainScreen As Long '                                                         x  PUT (NEARLY) ALL FLAGS INTO ARRAYS OR UDTs
mainScreen = _NewImage(SWIDTH, SHEIGHT, 32) '                                    x  FIX POINTER SHOWING ERROR using _MouseShow then _MouseHide
Screen mainScreen '                                                              x  REWORK THE FLAKY overlapped SOUND FADEOUTS WITH NEW 1&2 SNDFADES
Randomize Timer: _FullScreen _SquarePixels , _Smooth '
'
Type hiScore '                                                                   x  MAKE VAR TYPES MORE CONSISTANT, Capitalize Globals
    player As String '
    score As Integer '                                                           x  ADD METEOR SHOWER FROM ABOVE
    kRatio As Integer '                                                          x  PRIORITIZE SHIP-BOOM PARTICLE FOUNTAIN - green pixels!
    timeInBox As Integer '     NATIVE SCREENS STILL HAVE SOME ISSUES...
End Type '                     FINALIZE CHANGES TO SAUCERCONTROL                 x  ADD AN EVEN SLOWER MOUSE SENSITIVITY SETTING
'                                                                                X  ADD MOUSE USE ADVISORY - no up and down movement!
Type gridRock '                                                                  x  MAKE LANDING AND RECHARGING EASIER --
    x As Single '
    y As Single '                                                                x  IMPROVE RETRO THRUSTER STEERING -----
    rotAng As Integer '                                                          x  NO GOLD ROCKS @ EDGES
    col As _Unsigned Long '                                                      x  MAKE STATIC VARIABLES RESETTABLE FOR ROUND 2 / NEW GAME
    speed As Single '                                                            x  ADD BIG HINT TO PUZZLE AFTER 60 SECS w/ no progress
    yJiggle As _Byte '
    special As _Byte '                                                           x  FIX DOUBLE BOOMS @ COMETS ISSUE
    rotSign As _Byte '
    alive As _Byte '
End Type '
'                                                                                x  ADD THE GAUNTLET: Inside The Old Diamond Mine on Volcano Rock
Type comet '
    kind As String '                                                             x  FIX ADJUSTABILITY OF MAXROCKS AND MAXCOMETS
    x As Single '                                                                x  ADD OPTION TO BUY ANOTHER DRONE, "BuyIn" sub
    y As Single '                                                                x  ADD STAR/SCREEN SCROLLING TO LANDING TIME
    Vx As Single '
    Vy As Single '
    radius As Single '
    rotSpeed As Single '                                                         x  MAKE SETTINGS PAGE MORE PRESENTABLE, ADD DEFAULT VISIT @ START
    rotAng As Integer '
    rotSign As _Byte ' -1, 0, 1  clockwise, no rotation, C-clockwise             x  ADD <PLAY AGAIN?> AT END, RESETTABLE STATIC VARIABLES
    alive As _Byte
    col As _Unsigned Long '      body color                                      x  STAGGER GRID BETTER
    edge As _Unsigned Long '     outline color
End Type '
'                                                                                x  ADJUST SCORE BY DIFFICULTY - MORE POINTS FOR FASTER PLAY
Type ship '                                                                                                    - FEWER POINTS FOR EASIER
    kind As String '
    x As Single '                                                                x  CHANGED OUT 'TRUE' & 'FALSE' WITH '_TRUE' & '_FALSE', 5/20/25
    y As Single '                                                                x  CHANGED OUT 'AND' & 'OR' WITH '_ANDALSO' & '_ORELSE'
    Vx As Single '                                                               x  CENTERED SAUCER IN ITS WINDOW PROPERLY SO THE FILL COLOR WORKS RIGHT, 7/14/25
    Vy As Single '                                                               x  FOUND & KILLED MEMORY LEAKS IN RENDER_SAUCER SUB & OTHERS TOO, 7/23/25
    speed As Single '                                                            x  ELIMINATED NATIVE RESOLUTION OPTION, WAS TOO PROBLEMATIC, FOCUS ISSUES, 8/1/25
    power As Single '                                                            x  MADE FILE NAME CAPITALIZATION MATCH TO LOAD CORRECTLY FOR LINUX!
    chargeDelta As Single
    course As Integer '         vector angle for ship
    col As _Unsigned Long '
    radius As _Byte
    landed As _Byte
    charging As _Byte
    charged As _Byte
    inventory As _Byte
    shields As Single
    lapped As _Byte
    detached As _Byte
    blownUp As _Byte
End Type

Type rock
    kind As String
    x As Single
    y As Single
    Vx As Single '              vector pairs for rocks
    Vy As Single
    speed As Single
    size As _Byte '
    rotation As _Byte
    alive As _Byte '
    stayPainted As _Byte
    rotDir As String
    radius As Integer
    spinAngle As Integer
    spinSpeed As Integer '      0, 1, 2
    col As _Unsigned Long
End Type

Type XYPair: As Single x, y: End Type
Type rect: As Integer x1, y1, x2, y2: End Type ' rectangle def
Type bInfo: As Integer r, g, b, num: End Type '  boom info
Type particle: As Single x, y, Vx, Vy, brightness: End Type
Type Sector: As XYPair UL, UR, LL, LR: End Type '
Type debrisType: x As Single: y As Single: c As Long: End Type

Type spark '                    single spark definition
    Location As XYPair '        location of spark
    Vector As XYPair '          spark vector
    Velocity As Single '        velocity of spark (speed)
    Fade As Integer '           intensity of spark
    Lifespan As Integer '       lifespan of spark
End Type

Type sb '                               SUB toggles: #n controlled by subFlags() array
    doRocks As _Byte '      # 1
    doShip As _Byte '       # 2
    doFF As _Byte '         # 3         force field
    doDeflect As _Byte '    # 4
    doGrid As _Byte '       # 5
    checkGridCollisions As _Byte ' # 6
    checkFSC As _Byte '     # 7         check For Ship Collision
    doSparks As _Byte '     # 8
    doComets As _Byte '     # 9
    checkCometCollisions As _Byte '# 10
    trackShields As _Byte ' # 11
    go2Space As _Byte '     # 12
    rockMoving As _Byte '   # NA,       no 13, sequencing excludes this from SELECT CASE in main
    doFlyBy As _Byte '      # 14
    goDissolveFF As _Byte ' # 15
    doSaucers As _Byte '    # 16
    doTruck As _Byte '      # NA        ditto on 17
    doInstructs As _Byte '  # 18
    doSettings As _Byte '   # 19
    doShowers As _Byte '    # 20
    doVertGauge As _Byte '
    doPopUp As _Byte '
    doBuyIn As _Byte '
    doGauntlet As _Byte '   # 21
End Type

Type flag '                     event flags
    doRockMask As _Byte
    doPractice As _Byte
    doAutoShields As _Byte
    doCircle As _Byte
    shutBackDoor As _Byte
    shutFrontDoor As _Byte
    harpooned As _Byte '
    showMoonScape As _Byte
    fadeInRocks As _Byte
    landingTime As _Byte '      aka gravity based flight with main thrusters on
    detachRock As _Byte
    chargeDone As _Byte
    reduceGravity As _Byte
    regularChecks As _Byte '    gravity/landingTime flight vs no gravity/space flight
    fullScreen As _Byte
    fullScreenOff As _Byte
    speedUp As _Byte
    shipBoomDone As _Byte
    thrustersOn As _Byte
    settingsDone As _Byte '
    killFlyBy As _Byte
    warn As _Byte
    boomInProgress As _Byte
    gotPastLanding As _Byte
    highlight As _Byte
    fadeIn As _Byte
    toggle_SqrPix As _Byte
    fireworksInProgress As _Byte
End Type

Type sounds '                   some sound flags from early on
    fadeInComs As _Byte '
    fadeOutComs As _Byte
    fadeInGRID As _Byte
    fadeOutGrid As _Byte
    startFFloop As _Byte '
End Type

Type saucer '
    loc As XYPair
    commands As String '
    action As String
    loopNum As Integer '
    charCount As Integer '
    loopCounter As Integer '
    movesNum As Integer
    aspectSign As _Byte '
    rotAngSign As _Byte '
    getCommand As _Byte
    alive As _Byte
    shipRadius As Single '
    rotAngle As Single '
    aspect As Single '
    speed As Single '
    fillColor As _Unsigned Long
End Type

Type bullet '
    Active As Integer '
    x As Integer '
    y As Integer '
    Radius As Integer
    Speed As Single '
End Type

Type control
    hold As _Byte
    endIt As _Byte
    restart As _Byte
    clearStatics As _Byte
    pop As _Byte '          pop up
End Type

Type time
    overlap As Long
    gameStart As Long
    comets As Long
    grid As Long
    ThrustersOff As Long
    inCage As Integer
End Type

Type game '
    round As _Byte
    speed As Single
    score As Integer
    killRatio As Integer
    landingSpeed As Single
    diff_mult As Single '   difficulty multiplier
    cheater As _Byte
End Type
' ------------------------------------------------
Dim As gridRock matrix(1 To 20, 1 To 11)
Dim As comet comet(1 To 115) '
Dim As rect cBox, wBox
Dim As saucer saucer(12) '
Dim As Sector sector(1 To 8)
Dim As particle n(110), e(130), e2(110), sou(140), w(170)
Dim As String moves(18), j, shipType(1 To 12), rockType(1 To 14) '
Dim As Long starScape, saucerScape, miniMask, microMask, starScape3 '   images
Dim As Long shipImg, starScape2, HDWimg(1 To 9) '                       images
Dim As Long t5, t1, t2, t3, t4, interval '                              timers
Dim As Long timer1, timer2, timer3, timer4, inputTime, warnSnd '        timers
Dim As Integer toteSaucers, rockHeading, lockedAngle, spin2, c, shipNum, boomDelay
Dim As Integer popCount, realCourse, diffX, msX, sparkNum: sparkNum = 10 ' number of sparks to create at a time... rezX removed
Dim As Integer sparkLife, saucerKills, limit, maxComets: maxComets = 90: sparkLife = 25
Dim As _Byte sparkCycles, played, delayVO, bounceOffs
Dim As _Byte bannerON, closed, gauntletFlag(1 To 5), prezSector '
Dim As _Unsigned Long weakWallColor
Dim As Single xScroller, d, stepper: stepper = 2
Dim debris(5000) As debrisType '                    fireworks UDT
ReDim Bullet(0) As bullet, spark(0) As spark '      dynamic arrays for sparks & bullets
Dim Shared Control As control, Sounds As sounds '   UDTs
Dim Shared Ship As ship, Sb As sb, Flag As flag '   UDTs
Dim Shared I(28) As Long '                          image array
Dim Shared C(16) As _Unsigned Long '                color array
Dim Shared S(48) As Long '                          sound array
Dim Shared VO(1 To 47) As Long '                    voice-over array
Dim Shared rock(1 To 40) As rock '                  rock array
Dim Shared HiScore(5) As hiScore, Time As time, Game As game, boomInfo As bInfo '            more UDTs
Dim Shared As _Byte Target, Resetter(30), OneTimeSnd(4), SubFlags(1 To 21), stopCheck '      purple rock, bool flag arrays
Dim Shared As Long MoonScape, ViewScreen, Modern, ModernBig, ModernBigger, Menlo, MenloBig ' images, fonts
Dim Shared As Integer MaxRocks, CoAng, FPS, MX, MY, DTW, DTH: DTW = _DesktopWidth: DTH = _DesktopHeight
Dim Shared As Single GravityFactor, MouseSens '
' ------------------------------------------------
starScape3 = _NewImage(SWIDTH, SHEIGHT, 32) '    *  transfer screen
miniMask = _NewImage(42, 42, 32) '   for rocks   *  star-blocking masks
microMask = _NewImage(20, 20, 32) '  for comets  *
_Dest miniMask: Cls: _Dest microMask: Cls: _Dest 0
' ------------------------------------------------      ** STARTUP **
StartUp '                                        *  load assets and values
' ------------------------------------------------
timer1 = _FreeTimer '                            *      ** TIMERS **
On Timer(timer1, 2) FlipOnShip '                 *
timer2 = _FreeTimer '                            *
On Timer(timer2, 4.2) FlipOnSaucers '            *
timer3 = _FreeTimer '                            *
On Timer(timer3, 3.35) PlayLateVO '              *
timer4 = _FreeTimer '                            *
On Timer(timer4, .8) FlipOnBuyIn '               *
t1 = _FreeTimer '                                *
On Timer(t1, .25) FlipOnEast1 '                  *
t2 = _FreeTimer '                                *
On Timer(t2, 1.35) FlipOnSouth '                 *
t3 = _FreeTimer '                                *
On Timer(t3, 2.3) FlipOnNorth '   #3 & #5        *
t4 = _FreeTimer '                                *
On Timer(t4, 2.4) FlipOnWest '                   *
t5 = _FreeTimer '                                *
On Timer(t5, 2.3) FlipOnEast2 '                  *
interval = _FreeTimer '                          *
On Timer(interval, 6) ThreeTimersOn '            *
boomDelay = _FreeTimer '                         *
On Timer(boomDelay, .1) Delayedboom '            *
' ------------------------------------------------
SplashPage '                                     *  ** WELCOME SCREEN **  arcade game style
If Sb.doInstructs Then Instructions '            *
'Timer(timer2) On '    hot wire to Saucers
' >>>> *******************************************  >> ******** MAIN  LOOP ******** << ******************************************* <<<<

Do
    If Flag.speedUp Then '                                          accelerate game speed after POPUP
        If FPS <= 61 Then '
            FPS = FPS + stepper '
        Else If FPS > 60 Then Flag.speedUp = _FALSE
        End If
        stepper = 2 '
    End If
    If Sb.doPopUp Then _MouseShow Else _MouseHide '                 ** MOUSE POINTER CONTROL **
    If Not Sb.doPopUp _AndAlso Not _MouseHidden Then _MouseHide '   redundant but maybe not?

    'If Flag.fullScreen Then '
    ' _FullScreen _SquarePixels , _Smooth '                       ** FULLSCREEN SETTINGS ** DISABLED! better at _fullscreen
    ' Flag.fullScreen = _FALSE '                                  must be in the main loop or weird mousebutton issues occur in MacOS
    ' End If
    ' If Flag.fullScreenOff Then
    ' _FullScreen _Off
    ' _Delay .25
    ' _ScreenMove DTW / 2 - _Width / 2, DTH / 2 - _Height / 2
    '  _Title "R o c k   J o c k e y" '
    ' Flag.fullScreenOff = _FALSE
    ' End If
    If Flag.toggle_SqrPix Then
        If _FullScreen = 2 Then
            _FullScreen _Off: _FullScreen
        Else _FullScreen _SquarePixels , _Smooth
        End If
        Flag.toggle_SqrPix = _FALSE
    End If
    '                                                   ** GAME OVER CHECKS **
    If Ship.inventory <= -1 Then '                      ships all gone?
        Sb.doPopUp = _FALSE '                            buyIn sub trumps popUp sub
        Timer(timer4) On '                              triggers buyIn sub, "wanna buy a ship?"
    End If
    If Ship.power < 1 Then '                            (shields are monitored in the check subs)
        Ship.power = 1
        ShipBoom '                                      shipBoom tallies the ship.inventory
        Game.score = Game.score - 100 * Game.diff_mult 'boom penalty
    End If

    If Not Control.hold Then '                 ************************** ** GAME HOLD LOOP ** ***************************
        Cls
        _Limit FPS
        If (Not Flag.landingTime _AndAlso Not Sb.doGauntlet) _OrElse Sb.doFF Then '
            _PutImage (xScroller, 0), starScape '                   draw software backgrounds for screen scrolling
            If Not Control.endIt Then _PutImage (1281 + xScroller, 0), starScape2 '
        Else If Flag.landingTime Then
                xScroller = xScroller - .16 '                       ** SCROLL STARS ** to the left during landingTime
                _PutImage (xScroller, 0), starScape
                _PutImage (1281 + xScroller, 0), starScape2
                'If starScape3 <> 0 Then _FreeImage starScape3: starScape3 = 0
                PCopy _Display, starScape3 '                        save display screen for later use
                If xScroller < -1280 Then xScroller = 0
            End If
        End If

        If Sb.doGauntlet Then '
            _PutImage , I(26) '                                     show gauntletScreen backdrop
            If Flag.highlight Then _PutImage (65, 620), I(27) '     show diamond prize
        End If

        If Flag.landingTime _AndAlso Not Sb.doFF Then '             ** ROCK DROP LANDING HANDLER **
            If Ship.x > 468 _AndAlso Ship.x < 506 Then
                If Ship.y > 563 _AndAlso Ship.y < 587 Then '
                    Flag.doRockMask = _FALSE '                                           kill mask near landing spot
                    If Not Ship.detached Then _PutImage (Ship.x - 23, 535), miniMask '  block stars around landing zone when harpooned
                    If Not Ship.landed Then CheckLanding: _SndPlay S(2) '               clicks for landing warning, checkLanding determines if landed or not
                Else If Not Ship.detached Then Flag.doRockMask = _TRUE
                    Ship.landed = _FALSE '
                End If
            Else If Not Ship.detached Then Flag.doRockMask = _TRUE
                Ship.landed = _FALSE
            End If
            If Not Resetter(23) _AndAlso Ship.landed _AndAlso Ship.Vy = 0 _AndAlso Game.round = 1 Then '
                PrioritizeVO 12 '                                               "great landing..."
                Resetter(23) = _TRUE '
            End If
            If Timer - Time.ThrustersOff > 2 Then Flag.thrustersOn = _TRUE '     kill thrusters for 2 secs after landing
        End If

        If Sb.rockMoving Then '                                                 speed up to move rock
            FPS = 75 '
        Else If Not Sb.doPopUp _AndAlso Not Flag.speedUp _AndAlso Not Sb.doComets _AndAlso Not Flag.landingTime Then FPS = Game.speed ' ** NORMAL GAMESPEED **
        End If
        If Not Sb.rockMoving _AndAlso Flag.landingTime _AndAlso Not Sb.doPopUp Then FPS = Game.landingSpeed
        ' ---------------------------                                           ** FLAG EVENTS **
        If Not Control.endIt _AndAlso Not Sb.doSaucers _AndAlso Not Sb.doGauntlet Then SoundCenter '      sound events to check on
        If Not Sb.doFlyBy _AndAlso Flag.landingTime _AndAlso Not Flag.killFlyBy _AndAlso Int(Rnd * 135) = 50 Then Sb.doFlyBy = _TRUE: SubFlags(14) = _TRUE ' flyby conditions
        If Not Flag.harpooned _AndAlso rock(Target).col = C(3) Then Check4Harpoon '  if rock's green then check for harpoon
        ' ---------------------------
        c = 0 '
        Do '                                                                    ** SUB CONTROL **
            c = c + 1 '                                                          * (most subs) *
            If SubFlags(c) Then
                Select Case c '
                    Case 1: RockNav: DrawRocks: If Not Flag.harpooned Then Check4RockContact ' new, added IF
                    Case 2: ShipControl
                    Case 3: ForceFieldControl
                    Case 4: DeflectFF
                    Case 5: If Timer - Time.grid > 2 Then RunGRID
                    Case 6: CheckShipGRIDCollision
                    Case 7: Check4ShipROCKCollision
                    Case 8: If Not Flag.landingTime Then BlowUp
                    Case 9: RunCOMETS
                    Case 10: CheckShipCOMETCollision
                    Case 11: AutoShields
                    Case 12: Back2Space
                    Case 14: If Flag.landingTime _AndAlso Not Sb.doSaucers Then FlyBy
                    Case 15: DissolveFF
                    Case 16: SaucerControl
                    Case 18: Instructions
                    Case 19: Settings
                    Case 20: RunSHOWERS
                    Case 21: Gauntlet
                End Select
            End If
        Loop Until c = UBound(SubFlags)
        ' ---------------------------
        If Flag.landingTime _AndAlso rock(Target).stayPainted _AndAlso Not Control.endIt _AndAlso Not Sb.go2Space Then
            _PutImage (rock(Target).x - 20, rock(Target).y - 20), I(0) ' keep dumped rock image alive during popUp & timer2/post shipBoom
        End If
        If Flag.showMoonScape Then _PutImage (0, 530)-(1280, 720), MoonScape '  draw moonscape on top, activate truck/beacons
        If Flag.fadeIn Then '                                                   ** POST-MOONSCAPE RENDERS **
            _SndVol S(30), 0: _SndLoop S(30): d = 0 '
            Resetter(15) = _TRUE '                                               don't play landWithRock again
            For c = 255 To 0 Step -6 '   was -5                                 fade in scene after gauntlet
                _Limit 80 '
                If d < .008 Then d = d + .00016: _SndVol S(30), d
                _PutImage , starScape
                _PutImage (0, 530)-(1280, 720), MoonScape
                Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, c), BF '          increase black box transparency
                _Display
            Next
            Resetter(11) = _TRUE: Resetter(12) = _TRUE '                          fixes volume issue w/ restarting S(30)
            Flag.fadeIn = _FALSE
            FPS = 5
            Control.hold = _FALSE
            Flag.speedUp = _TRUE
            stepper = 1
        End If
        If Game.round > 1 _AndAlso Flag.landingTime _AndAlso Not Flag.boomInProgress Then '
            _PutImage (Ship.x - 20, Ship.y - 10), I(28) '                   player has diamond @ 2nd landing...
            _PutImage (0, 530)-(1280, 720), MoonScape '                     redraw moonscape to cover diamond image @ landing
        End If
        If ((Flag.landingTime _AndAlso Sb.doShip) _AndAlso (Ship.y > 450 _AndAlso Ship.y < 600)) _OrElse (Game.round > 1 _AndAlso Not Flag.boomInProgress) Then RedrawShip '
        If SubFlags(13) Then MoveTargetRock '                           ^^ above line prevents ship pixel damage from landingZone - mostly
        If Flag.showMoonScape Then DriveTruck
        If SubFlags(8) _AndAlso Flag.landingTime Then BlowUp '              put ship explosions after moonscape putImage during landingTime
        ' ---------------------------
        j = _Trim$(Left$(Str$(Ship.speed), 4)) '                            ** SHOW GAUGES **

        IF ship.speed > .1 _ANDALSO NOT flag.landingTime THEN_
        showHorzGauge 20, 30, ship.speed / 6.05, "SPEED  " + j, _RGB32(255, 83, 255)
        ShowHorzGauge 20, 62, Ship.power / 100, "POWER  " + Str$(Int(Ship.power)) + "%", _RGB32(61, 255, 78, 220)
        ShowHorzGauge 20, 94, Ship.shields / 100, "SHIELDS  " + Str$(Int(Ship.shields)) + "%", C(12)
        _Font Modern: Color C(16) '
        If Ship.inventory > -1 Then _PrintString (36, 130), "SHIPS LEFT:" + Str$(Ship.inventory)
        _Font ModernBigger: Color C(14) '
        If Game.score < 0 Then Game.score = 0
        If Not Flag.doPractice Then _PrintString (_Width - 135, 33), "SCORE: " + Str$(Game.score) '  show score during game
        _Font 16
        If Flag.landingTime _AndAlso Not Sb.doFF Then '                     ** SHIP CHARGING LANDING HANDLER **
            If Ship.x > 757 _AndAlso Ship.x < 766 Then
                If Ship.y > 568 _AndAlso Ship.y < 573 Then
                    If Ship.Vy < .65 _AndAlso Ship.Vy > 0 Then '            upside down motion
                        Ship.y = 571 '
                        Ship.x = 761
                        Ship.Vy = 0
                        Ship.course = -180 '                                straighten DOWN the ship
                        RedrawShip '                                        charge zone was blacking out some pixels @ landing
                        If Not Ship.detached Then
                            ShipBoom
                            PrioritizeVO 33 '                               "You can't recharge with the rock attached!"
                            GoTo EXIT_IF ' not hopping out here caused LOCKUPS cuz ship.landed then = _TRUE when it's NOT
                        End If
                        If Not Ship.charged Then '
                            Ship.charging = _TRUE
                            Sb.doVertGauge = _TRUE '
                        End If
                        Ship.landed = _TRUE ' this shuts down steering/spinning controls except thrusters
                    End If
                End If
            End If
        End If

        EXIT_IF: '                                                                  IF escape label
        If Not Ship.charging Then Resetter(26) = _FALSE: _SndVol S(21), .44 '       reset charging sound
        If Not Resetter(24) _AndAlso Ship.charging _AndAlso Ship.power >= 60 Then
            If _SndGetPos(S(21)) > 2 Then
                PrioritizeVO 14
                Resetter(24) = _TRUE '                                  charge complete voice over, done once only
            End If
        End If

        If Ship.landed _AndAlso Not Control.endIt Then '                ** SHIP LANDED AND CHARGING CONTROLS **
            _PrintMode _KeepBackground '
            PostLanding '                                               check conditions - pretty tricky logic and sequencing here...
            If Ship.charging _AndAlso Not Ship.charged Then
                If Sb.doVertGauge Then ShowVertGauge 870, 440 '
                _Font 8: Color C(12)
                _PrintString (751, 591), "CHARGING"
                If Ship.power <= 100 Then Ship.power = Ship.power + Ship.chargeDelta '  charging speed
                If Ship.shields < 100 Then Ship.shields = Ship.shields + .22
                QuickSound 21 '                                                         charging sounds <<<<
                If Ship.power >= 99 _AndAlso Not Resetter(26) Then
                    played = _FALSE '                                   turns back on thruster sounds in shipControl sub and quicksound sub
                    Ship.charging = _FALSE '
                    Resetter(26) = _TRUE '
                    Flag.killFlyBy = _TRUE '                                                    stop flybys after charging done
                    If Not Resetter(27) Then Game.score = Game.score + (200 * Game.diff_mult) ' points for charging up too!
                    Resetter(27) = _TRUE
                End If
            Else
                If Game.round = 1 Then PostLanding
                _Font 8: Color C(3)
                _PrintString (463, 595), "LANDED"
            End If
            _Font 16
        Else If _SndPlaying(S(21)) Then _SndStop S(21): played = _FALSE ' fail safe kill charge sound
        End If

        If Flag.reduceGravity _AndAlso GravityFactor > 0 Then '
            GravityFactor = GravityFactor - .0005 '         reduce gravity gently, tho mostly unseen
            If GravityFactor <= 0 Then
                Flag.reduceGravity = _FALSE
                GravityFactor = .036 '                      reset gravity
            End If
        End If '
        '
        If Not OneTimeSnd(1) _AndAlso Ship.shields < 25 Then '   shields warning VO reworked
            If Not IsVOPlaying Then '                       don't step on other VOs
                If Not _SndPlaying(S(23)) Then '            don't step on heaven sound
                    _SndPlay VO(24) '                       played once only, shields are low
                Else Timer(timer3) On: delayVO = 24 '       turn on VO delay timer, assign VO to play
                End If
            End If
            OneTimeSnd(1) = _TRUE '
        End If
        If Not OneTimeSnd(2) _AndAlso Ship.power < 25 Then '     power warning VO
            If Not IsVOPlaying Then
                If Not _SndPlaying(S(23)) Then
                    _SndPlay VO(25)
                Else Timer(timer3) On: delayVO = 25
                End If
            End If
            OneTimeSnd(2) = _TRUE '
        End If
        If (_SndPlaying(VO(24)) _OrElse _SndPlaying(VO(25))) _AndAlso _SndPlaying(S(23)) Then ' no VO jabber over heaven sound
            _SndStop VO(24): _SndStop VO(25)
        End If
        _Font ModernBig: Color C(14)
        If Ship.charged Then _UPrintString (694, 510), "PRESS <SPACEBAR> TO EJECT."
        If bannerON _AndAlso Ship.landed Then _UPrintString (407, 510), "FLY TO RECHARGE STATION." Else bannerON = _FALSE
    End If '
    '           **************************************************** BOTTOM OF GAME LOOP - HOLD POINT ********************************************

    If Not closed Then ' blocks too many F strokes from buffering & causing double buyIn sub calls - can't get _keyclear to work here
        Select Case _KeyHit '                                               ** USER INPUT **
            Case 27: If Not Flag.doPractice Then '                  <Esc> key: popUp or exit practice mode
                    Sb.doPopUp = _TRUE '                             >> All this is outside the GAME LOOP, so is always ON <<
                Else '                                              after a practice session, set up for game
                    TurnOnChecks
                    _SndPlay S(3)
                    Flag.doPractice = _FALSE
                    _SndStop S(28): _SndVol S(28), .0005
                    Resetter(6) = _FALSE
                    Ship.speed = 0: Ship.course = 0
                    Ship.x = CENTX: Ship.y = CENTY
                    Ship.power = 100
                    SplashPage
                End If '                                                                                            ** CHEAT KEYS **
            Case 109, 77: If Ship.inventory < 4 Then Ship.inventory = Ship.inventory + 1: Game.cheater = _TRUE '    m or M to add MORE ships
            Case 102, 70: Ship.inventory = Ship.inventory - 1: closed = _TRUE: inputTime = Timer '                  f or F for FEWER ships - for testing
            Case 113, 81: WrapUp: System '                                                                          q or Q for quick QUIT
        End Select
    End If
    _KeyClear
    If Timer - inputTime > .75 Then closed = _FALSE ' allow INPUT again above / only close after F key to prevent overload
    If Sb.doPopUp Then PopUp '                                  ** UNSTOPPABLE SUBS **
    If Sb.doBuyIn Then BuyIn
    If Control.endIt Then EndGame '
    _Font 16
    _Display '
Loop '               ************************************************* END MAIN ***************************************************

errHandler: Cls: Print "There's been an error"; Err; "on line"; _ErrorLine: Beep: _Delay 5: WrapUp: System '    ** ERROR HANDLER **
' -------------------------------------------------------------------------------------------------------------------------------------
Sub StartUp () '                                                  ****** SUBS ******

    Shared As Integer diffX, msX, maxComets ' rezX removed

    MaxRocks = 10 '                 default 10 rock easy setting
    If Control.restart Then Game.round = 0 Else Game.round = 1
    LoadColors: LoadSounds: LoadRocks: LoadImages: LoadFonts
    LoadShips: LoadVOs: LoadMoonScape: LoadViewScreen
    AssignMoves: AssignRocks: InitGRID: InitCOMETS
    _PrintMode _KeepBackground
    Flag.thrustersOn = _TRUE
    Flag.regularChecks = _TRUE
    Flag.fadeInRocks = _TRUE '
    Flag.doAutoShields = _TRUE
    Flag.doRockMask = _TRUE
    Sb.doTruck = _TRUE
    Sb.doShip = _TRUE: SubFlags(2) = _TRUE
    Sb.checkFSC = _TRUE: SubFlags(7) = _TRUE '
    Sb.doRocks = _TRUE: SubFlags(1) = _TRUE '
    Time.gameStart = 5
    Game.score = 0
    Game.speed = 60 '               start speed, needed for speedUp to start
    Game.landingSpeed = 60 '        default for medium play
    Game.cheater = _FALSE
    Ship.speed = 0
    Ship.shields = 100 '
    Ship.power = 100
    Ship.inventory = 7 '            reserve ships, default 7 - 5 for hard level, 10 for easy
    Ship.blownUp = 0 '              init or reset for new game
    Ship.chargeDelta = .21 '        charge speed
    GravityFactor = .036
    MouseSens = .225 '              initial mouse setting, #2
    msX = 140 ' #2 (middle) default button positions in Settings, rezX=202,fullscreen rez button - DISABLED <<<<
    diffX = 133 '                   easy difficulty
    maxComets = 75 '                easy
    Game.diff_mult = .9 '           ditto
End Sub
' -----------------------------------------
Sub WrapUp () '                             close up shop

    Dim c As Integer
    Shared As Long saucerScape, starScape3, shipImg
    Shared As Long mainScreen, microMask, miniMask, starScape, starScape2, HDWimg()
    Shared As Long t5, t1, t2, t3, t4, interval, timer1, timer2, timer3, timer4
    Shared As Integer boomDelay

    For c = 0 To UBound(I) '        freeImages
        On Error GoTo errHandler
        _FreeImage I(c)
    Next c
    For c = 1 To UBound(HDWimg) '   free hardware image array
        If HDWimg(c) <> -1 _AndAlso HDWimg(c) <> 0 Then _FreeImage HDWimg(c) ' needed to add checking or it crashed...
    Next c
    For c = 0 To UBound(S) '        close sounds
        _SndClose S(c)
    Next c
    For c = 1 To UBound(VO) '       close voice-overs
        _SndClose VO(c)
    Next c
    Screen 12
    _FreeImage mainScreen
    _FreeImage MoonScape '                          free other images
    _FreeImage ViewScreen: _FreeImage saucerScape
    _FreeImage shipImg: _FreeImage starScape
    _FreeImage starScape2: _FreeImage starScape3
    _FreeImage miniMask: _FreeImage microMask
    _Font 16 '                                      free fonts
    _FreeFont Menlo '                               fonts checked for errors @ loading
    _FreeFont MenloBig
    _FreeFont Modern
    _FreeFont ModernBig
    _FreeFont ModernBigger
    Timer(timer1) Free: Timer(timer2) Free '        free timers
    Timer(timer3) Free: Timer(timer4) Free
    Timer(t1) Free: Timer(t2) Free
    Timer(t3) Free: Timer(t4) Free
    Timer(interval) Free: Timer(t5) Free: Timer(boomDelay) Free
End Sub
' -----------------------------------------
Sub ResetFlags () '                 to prepare for another round of play or a NEW GAME

    Dim c As Integer

    Do: c = _MouseInput: Loop Until c = 0 ' clear mouse input
    For c = 0 To UBound(Resetter): Resetter(c) = _FALSE: Next c '    reset music flags array
    For c = 1 To UBound(SubFlags): SubFlags(c) = _FALSE: Next c '    reset all sub control flags
    Game.round = Game.round + 1 '   advance round number - from 0 for new game or higher for same game...
    Control.restart = _FALSE
    Sounds.startFFloop = _FALSE
    Ship.landed = _FALSE
    Ship.lapped = _FALSE
    Ship.detached = _FALSE
    Time.overlap = 0 '              overlap cycles for harvest
    Time.gameStart = 5 '            reset start time
    Sounds.fadeInComs = _FALSE '     reset comet fader flag
    Sounds.fadeOutComs = _FALSE
    Sounds.fadeInGRID = _FALSE
    Sounds.fadeOutGrid = _FALSE
    Flag.harpooned = _FALSE '        new - from startUp
    Flag.chargeDone = _FALSE
    Flag.shutBackDoor = _FALSE
    Flag.warn = _FALSE '             turns on comet fuzzy noise
    Flag.killFlyBy = _FALSE '        allow flyBys in all rounds
    Flag.detachRock = _FALSE '
    Flag.shutFrontDoor = _FALSE
    Flag.shutBackDoor = _FALSE
    Flag.showMoonScape = _FALSE
    Flag.landingTime = _FALSE
    Flag.gotPastLanding = _FALSE
    Flag.settingsDone = _FALSE '
    Sb.checkFSC = _TRUE: SubFlags(7) = _TRUE '
    Sb.doShip = _TRUE: SubFlags(2) = _TRUE
    Sb.doTruck = _TRUE
    Sb.doRocks = _TRUE: SubFlags(1) = _TRUE '
    Sb.doComets = _FALSE: Sb.doPopUp = _FALSE '                   turn off all chapters just in case
    Sb.doGrid = _FALSE: Sb.doSaucers = _FALSE: Sb.doFF = _FALSE
    If Control.clearStatics Then ' zero out static values for new game by running SUBs with clearStats flag ON
        SaucerControl: ForceFieldControl: EndGame: PopUp: BuyIn '
        DeflectFF: DissolveFF: MoveTargetRock: RunCOMETS: RunSHOWERS
        RunGRID: FlyBy: DrawRocks: Back2Space: ShowHorzGauge 0, 0, 0, "x", _RGB32(1)
        ShowVertGauge 0, 0: InitCOMETS: ManageBullets: DriveTruck
        Gauntlet: North: East1: South: West: East2
        Control.clearStatics = _FALSE
    End If
    InitCOMETS: InitGRID: AssignRocks: KillNoises ' <<<< re-init for new game
    Randomize Using Timer + 500 '                   a fresh seed for a new GO
End Sub
' -----------------------------------------
Sub ShipControl ()

    Static As Integer oldY, yCount, screwUps, alpha
    Static As Long pauseTime, showTime '
    Static As _Byte said, said2, show
    Dim As Integer spin, tempSpin, cX, antiHeading, dist, complete
    Dim As Integer xPointEnd, yPointEnd, xPointStart, yPointStart
    Dim As Single distance, d2
    Dim As _Byte leftClick, rightClick, rocket, c
    Shared As String shipType(), rockType()
    Shared As Integer lockedAngle, spin2, realCourse
    Shared As _Byte played, delayVO '
    Shared As Long miniMask, microMask, timer3
    ' -------------------------- target scan zone --------------------------
    If Sb.doRocks _AndAlso Not Flag.doPractice _AndAlso Not Sb.doBuyIn Then

        If Abs(Ship.x - rock(Target).x) < 10 Then ' check for ship and target rock overlap
            If Abs(Ship.y - rock(Target).y) < 10 Then
                If Not said _AndAlso Time.overlap = 16 Then
                    If Not IsVOPlaying Then '                               "scanning target," say it once to make it clear, don't drive user crazy
                        _SndPlay VO(1): said = _TRUE '                       played once only, shields are low
                    Else Timer(timer3) On: delayVO = 1 '                    turn on VO delay timer, assign VO to play
                        said = _TRUE
                    End If
                End If
                If Time.overlap < 400 Then
                    rock(Target).col = C(9) '                               orange during overlap
                    _SndPlay S(12) '                                        scanning sound
                End If
                If Time.overlap = 400 Then
                    rock(Target).col = C(3) '                                           green after sufficient time of overlap
                    If Not said2 Then _SndPlay VO(2): said2 = _TRUE: pauseTime = Timer ' done scanning, once
                    _SndStop (S(12))
                End If
                Time.overlap = Time.overlap + 1
                Ship.lapped = _TRUE
            End If
        Else Ship.lapped = _FALSE
            _SndStop (S(12))
        End If
    End If
    complete = (Time.overlap / 400) * 100
If time.overlap > 10 _AndAlso time.overlap <= 400 Then showHorzGauge CENTX - 50, _Height - 40,_
time.overlap / 400, Str$(complete) + "%  SCANNED", _RGB32(255, 116, 6)
    If Not Ship.lapped _AndAlso Time.overlap < 400 Then rock(Target).col = C(10) '   back to purple
    ' ----------------------------------------------------------------------
    If said2 _AndAlso Timer - pauseTime > 2.5 _AndAlso rock(Target).col = C(3) _AndAlso Not Flag.harpooned _AndAlso Sb.doRocks Then
        _SndPlay VO(5) '
        said2 = _FALSE '
    End If
    ' --------------------------
IF NOT leftClick _ANDALSO NOT rightClick _ANDALSO NOT _MOUSEMOVEMENTX _ANDALSO_
(NOT _KEYDOWN(19200) _ORELSE NOT _KEYDOWN(19712)) THEN ship.kind = shipType(4) '     back to normal ship
    ' --------------------------
    If _KeyDown(19200) _OrElse _KeyDown(97) _OrElse _KeyDown(65) Then '                   ** SIDE THRUSTER RIGHT **
        played = _FALSE: QuickSound 10 '
        Ship.kind = shipType(12)

        If Flag.landingTime Then '                                              vector changes during landing mode
            Select Case -Ship.course
                Case 315 To 359, 0 To 45: Ship.Vx = Ship.Vx - .03
                Case 135 To 225: Ship.Vx = Ship.Vx + .03
                Case 226 To 314: Ship.Vy = Ship.Vy + .025 '
                Case 46 To 134: Ship.Vy = Ship.Vy - .025
            End Select
        Else '                                                                  non-vector movement
            tempSpin = CoAng - 90 '                                             location via theta angle
            d2 = d2 + .7
            Ship.x = Cos(_D2R(tempSpin)) * d2 + Ship.x '
            Ship.y = Sin(_D2R(tempSpin)) * d2 + Ship.y
        End If
    End If
    If _KeyDown(19712) _OrElse _KeyDown(100) _OrElse _KeyDown(68) Then '                  ** SIDE THRUSTER LEFT **
        played = _FALSE: QuickSound 10 '
        Ship.kind = shipType(11)

        If Flag.landingTime Then
            Select Case -Ship.course
                Case 315 To 359, 0 To 45: Ship.Vx = Ship.Vx + .03
                Case 135 To 225: Ship.Vx = Ship.Vx - .03
                Case 226 To 314: Ship.Vy = Ship.Vy - .025 '
                Case 46 To 134: Ship.Vy = Ship.Vy + .025
            End Select
        Else
            tempSpin = CoAng + 90 '
            d2 = d2 + .7 '                                              add .7 pixels of distance each cycle
            Ship.x = Cos(_D2R(tempSpin)) * d2 + Ship.x '                get coordinates from theta angle
            Ship.y = Sin(_D2R(tempSpin)) * d2 + Ship.y
        End If
    End If
    ' --------------------------
IF NOT _KEYDOWN(19200) _ANDALSO NOT _KEYDOWN(97) _ANDALSO NOT _KEYDOWN(19712)_
_ANDALSO NOT _KEYDOWN(100) _ANDALSO NOT _KEYDOWN(68) _ANDALSO NOT _KEYDOWN(65) THEN
        If _SndPlaying(S(10)) Then
            _SndStop S(10)
            played = _FALSE '                                            kill side thruster loop, reset quickSound
        End If
    End If
    ' --------------------------
    Do While _MouseInput '                                                              ** MOUSE INPUT **
        If _MouseMovementX Then
            If Not Ship.landed _AndAlso Not Ship.charging Then cX = cX - _MouseMovementX '   no ship spinning when landed and/or charging
            If cX < 0 Then Ship.kind = shipType(9) '                                    left steering jet
            If cX > 0 Then Ship.kind = shipType(10) '                                   right steering jet
            If Abs(cX) > MouseSens * 80 Then cX = MouseSens * 80 * Sgn(cX) '            top end mouse governor!
            Ship.course = Ship.course + cX * MouseSens '                                mouseSens = mouse movement reducer
        End If
    Loop
    ' ----------------------
    MX = _MouseX: MY = _MouseY '
    If Game.round = 1 _AndAlso Sb.doRocks _AndAlso Not Sb.doPopUp Then
        yCount = yCount + 1 '                                                           ** MOUSE USE ADVISORY **
        If yCount > 40 Then yCount = 0: oldY = MY '                                     only for practice & first harvest
        If Abs(MY - oldY) > 130 Then screwUps = screwUps + 1: oldY = MY '
        If screwUps > 7 Then show = _TRUE: screwUps = -4: showTime = Timer: _SndPlay S(2)
        If show _AndAlso Timer - showTime < 2.35 Then
            If Timer - showTime > 1.9 Then alpha = alpha - 8
            _Font Menlo: Color _RGB32(255, 255, 0, alpha)
            _PrintString (CENTX - (_PrintWidth("TO STEER SHIP") \ 2), CENTY - 30), "TO STEER SHIP"
            _PrintString (CENTX - (_PrintWidth("MOVE MOUSE SIDE TO SIDE ONLY") \ 2), CENTY), "MOVE MOUSE SIDE TO SIDE ONLY"
        Else show = _FALSE: alpha = 255
        End If
    End If
    '                     \/ mousekeeping chores - seems to work inMac OS now...
    'If _FullScreen = 0 Then
    ' If MX > _Width - 100 _OrElse MX < 100 Then _MouseMove _Width \ 2, _Height \ 2
    ' If MY > _Height - 100 _OrElse MY < 100 Then _MouseMove _Width \ 2, _Height \ 2
    ' _MouseHide
    ' End If
    ' ---------------------
    If Ship.course >= 1 Then Ship.course = -359 '           allows for zero course
    If Ship.course < -359 Then Ship.course = 0 '
    CoAng = -Ship.course - 90 '                             fix angles - corrected CourseAngle: 0 is really 90 degrees (east)
    If CoAng < 0 Then CoAng = CoAng + 360
    '                                                       ****    >  SHIP NAVIGATION <     ****
    If Not Flag.landingTime Then '                          ** NON-LANDING NAV **  vector angle (theta) only
        distance = distance + Ship.speed '                  move the ship forward & backwards
        Ship.x = Cos(_D2R(CoAng)) * distance + Ship.x '     get coordinates from angle vector
        Ship.y = Sin(_D2R(CoAng)) * distance + Ship.y
        Ship.Vx = Cos(_D2R(CoAng)) * Ship.speed '           get last known vectors from corrected course - for use at landing time
        Ship.Vy = Sin(_D2R(CoAng)) * Ship.speed '
    End If
    ' ---------------------
    If Flag.chargeDone _AndAlso Flag.landingTime Then '          <<< TRICKY SPOT <<< BACK2SPACE AFTER RECHARGE TRIGGER <<<
        If Ship.y <= 6 _OrElse Ship.y > _Height - 45 Then '      break thru top border to go back to space, height - 45 keeps it outside FF box
            Flag.showMoonScape = _FALSE '                    and prevents accidentally triggering go2space flag again
            Sb.go2Space = _TRUE: SubFlags(12) = _TRUE '       ** CHANGED If ship.y <= 0 TO <= 6 to allow more cycles to check position **
            Flag.reduceGravity = _TRUE
        End If
    End If
    If Flag.landingTime Then '                              ** LANDING NAV - MOVE SHIP with vectors, not theta angle **
        Ship.x = Ship.x + Ship.Vx
        Ship.y = Ship.y + Ship.Vy
        If Ship.Vy < 3.5 _AndAlso Not Ship.landed _AndAlso Not Sb.doFF Then Ship.Vy = Ship.Vy + GravityFactor '   gravity factor
    End If
    ' ---------------------
    leftClick = _MouseButton(1) '
    rightClick = _MouseButton(2) '
    ' ---------------------
    If Flag.thrustersOn Then
        If leftClick _AndAlso Not Sb.doPopUp Then '              ** LEFT CLICK - speed up **
            Ship.kind = shipType(2) '                       main ship thruster
            Ship.power = Ship.power - .022 '
            played = _FALSE '                                reset quickSound
            If Not Flag.landingTime Then QuickSound 11 Else QuickSound 8
            If Not Flag.landingTime _AndAlso Ship.speed < 6 Then Ship.speed = Ship.speed + .02
            If Flag.landingTime Then
                realCourse = -Ship.course '                 corrected course
                Select Case realCourse '                    adjust y vectors
                    Case 0 To 45: Ship.Vy = Ship.Vy - .085
                    Case 46 To 84: Ship.Vy = Ship.Vy - .06
                    Case 96 To 135: Ship.Vy = Ship.Vy + .06
                    Case 136 To 225: Ship.Vy = Ship.Vy + .085
                    Case 226 To 264: Ship.Vy = Ship.Vy + .06
                    Case 276 To 315: Ship.Vy = Ship.Vy - .06
                    Case 316 To 360: Ship.Vy = Ship.Vy - .085
                End Select
                Ship.power = Ship.power - .036 '                burning up power
                Select Case realCourse
                    Case 3 To 22: Ship.Vx = Ship.Vx + .007 '    adjust x vectors
                    Case 23 To 45: Ship.Vx = Ship.Vx + .02
                    Case 46 To 67: Ship.Vx = Ship.Vx + .035 '   more sideways thrust, more vector change
                    Case 68 To 113: Ship.Vx = Ship.Vx + .055
                    Case 114 To 135: Ship.Vx = Ship.Vx + .035
                    Case 136 To 160: Ship.Vx = Ship.Vx + .02
                    Case 161 To 178: Ship.Vx = Ship.Vx + .007
                    Case 182 To 200: Ship.Vx = Ship.Vx - .007
                    Case 201 To 225: Ship.Vx = Ship.Vx - .02
                    Case 226 To 241: Ship.Vx = Ship.Vx - .035
                    Case 242 To 292: Ship.Vx = Ship.Vx - .055
                    Case 293 To 315: Ship.Vx = Ship.Vx - .035
                    Case 316 To 337: Ship.Vx = Ship.Vx - .02
                    Case 338 To 357: Ship.Vx = Ship.Vx - .007
                End Select
                '                                                                   ** FLAME ZONE **
                antiHeading = realCourse + 90 '                                     adjust for QB64
                If antiHeading > 360 Then antiHeading = antiHeading - 360
                dist = Int(Rnd * 20 + 11) '                                         distance for end of flames
                xPointEnd = dist * Cos(_D2R(antiHeading)) + Ship.x
                yPointEnd = dist * Sin(_D2R(antiHeading)) + Ship.y
                xPointStart = 6 * Cos(_D2R(antiHeading)) + Ship.x '                 6 is dist from center of ship
                yPointStart = 6 * Sin(_D2R(antiHeading)) + Ship.y
                rocket = _TRUE
            End If
        Else If Not Flag.landingTime _AndAlso rightClick Then '                     RIGHT CLICK - slow down - RETRO/NOSE THRUSTER at nose
                If Ship.speed > -1 Then Ship.speed = Ship.speed - .03 '             **********************************
                Ship.kind = shipType(1) '                                           NON-LANDING SEQUENCES
                Ship.power = Ship.power - .009
                played = _FALSE: QuickSound 9 '
            End If
        End If

        If rightClick _AndAlso Flag.landingTime _AndAlso Not Ship.charging Then '   LANDING SEQUENCE RETRO THRUSTER
            Ship.kind = shipType(1) '                                               *******************************
            Ship.power = Ship.power - .028
            played = _FALSE: QuickSound 9
            realCourse = -Ship.course '                                             easier to work with numbers...
            Select Case realCourse '                                                x/y vector adjusts for nose thruster during landingTime
                Case 0 To 45: Ship.Vy = Ship.Vy + .08: Ship.Vx = Ship.Vx - .02
                Case 46 To 77: Ship.Vy = Ship.Vy + .05: Ship.Vx = Ship.Vx - .05 '
                Case 78 To 113: Ship.Vx = Ship.Vx - .08:
                Case 114 To 135: Ship.Vy = Ship.Vy - .05: Ship.Vx = Ship.Vx - .05
                Case 136 To 157: Ship.Vy = Ship.Vy - .065: Ship.Vx = Ship.Vx - .035 '   Thanks to Ben C.K. for calling out this need!
                Case 158 To 173: Ship.Vy = Ship.Vy - .075: Ship.Vx = Ship.Vx - .02 '    Added upgraded controls here
                Case 174 To 179: Ship.Vy = Ship.Vy - .08: Ship.Vx = Ship.Vx - .012
                Case 180: Ship.Vy = Ship.Vy - .085 '                                    Updated more, 3/31/25 and 7/29/25
                Case 181 To 186: Ship.Vy = Ship.Vy - .08: Ship.Vx = Ship.Vx + .012
                Case 187 To 202: Ship.Vy = Ship.Vy - .075: Ship.Vx = Ship.Vx + .02
                Case 203 To 224: Ship.Vy = Ship.Vy - .065: Ship.Vx = Ship.Vx + .035
                Case 225 To 247: Ship.Vy = Ship.Vy - .05: Ship.Vx = Ship.Vx + .05
                Case 248 To 293: Ship.Vx = Ship.Vx + .08
                Case 294 To 315: Ship.Vy = Ship.Vy + .05: Ship.Vx = Ship.Vx + .05
                Case 316 To 359: Ship.Vy = Ship.Vy + .08: Ship.Vx = Ship.Vx + .02
            End Select
            If realCourse <= 183 _AndAlso realCourse >= 177 Then Ship.Vx = 0 '             line up the rocket, kill x motion when inverted and firing nose thruster <<<<
        End If '                              ^ fixed this, prvented micro adjustments to Vx, reduced range of zeroing out Vx <<<<
    End If

    If Not _MouseButton(1) Then
        If _SndPlaying(S(11)) Then _SndStop S(11): played = _FALSE '                 kill main thruster sounds, reset quickSound
        If _SndPlaying(S(8)) Then _SndStop S(8): played = _FALSE
    End If
    If Not _MouseButton(2) _AndAlso _SndPlaying(S(9)) Then _SndStop S(9): played = _FALSE ' stop nose thruster sound
    ' ---------------------
    spin = Ship.course '                                                            VARPRT$ command doesn't like array or UDT use ...using dummy var "spin"
    PReset (Ship.x, Ship.y), Ship.col
    Draw "TA=" + VarPtr$(spin) + Ship.kind '                                        draw the ship with rotation
    Paint (Ship.x, Ship.y - 1), C(3), Ship.col '                                    paint ship green inside - can't be exactly in the middle

    If Flag.harpooned Then
        If Flag.doRockMask Then _PutImage (Ship.x - 23, Ship.y - 23), miniMask '    blocks the starscape from inside the target rock
        If Not Flag.detachRock Then
            rock(Target).x = Ship.x '                                               same xy locations for ship & rock
            rock(Target).y = Ship.y
            spin2 = rock(Target).spinAngle + (Ship.course - lockedAngle) '          keep rock at same angle but change with ship now!
        End If

        If Ship.detached Then _PutImage (rock(Target).x - 22, rock(Target).y - 22), miniMask '
        PReset (rock(Target).x, rock(Target).y), rock(Target).col
        If Not Sb.rockMoving _AndAlso Not rock(Target).stayPainted Then Draw "TA=" + VarPtr$(spin2) + rock(Target).kind '  draw rock with ship or without and target(rock).alive
        PReset (Ship.x, Ship.y), Ship.col
        Draw "TA=" + VarPtr$(spin) + Ship.kind '                                draw ship
        Paint (Ship.x, Ship.y - 1), C(3), Ship.col
    End If

    If rocket Then '                                                            flame draw after ship & rock
        Line (xPointStart, yPointStart)-(xPointEnd, yPointEnd), C(12) '         center flame line
        Line (xPointStart + 1, yPointStart + 2)-(xPointEnd, yPointEnd), C(9) '  two V shaping lines
        Line (xPointStart - 1, yPointStart + 2)-(xPointEnd, yPointEnd), C(9)
        rocket = _FALSE
    End If
    ' --------------------------
    If Flag.regularChecks Then '                                                ** ON-SCREEN / OFF-SCREEN BEHAVIOR **
        If Ship.x < -5 _AndAlso Not Flag.shutFrontDoor Then Ship.x = _Width + 5 '                                normal
        If Ship.x < -5 _AndAlso Flag.shutFrontDoor Then Ship.x = 20: _SndPlayCopy S(2), .5 '                     bounce off left side during comets
        If Ship.x > _Width + 5 _AndAlso Flag.shutBackDoor Then Ship.x = _Width - 20: _SndPlayCopy S(2), .5 '     bounce off right side, round 2
        If Ship.x > _Width + 5 Then Ship.x = -4 '                                                           normal
        ' *************
        If Ship.y < -5 _AndAlso Not Flag.landingTime Then Ship.y = _Height + 5 '                                 normal behavior
        If Ship.y < -5 _AndAlso Flag.landingTime _AndAlso Not Flag.chargeDone _AndAlso Not Sb.go2Space Then Ship.y = 10: Ship.Vy = 0 '  can't fly off screen going up during landing *
        If Ship.y < -5 _AndAlso Ship.charged Then Ship.y = _Height + 5 '                                         special normal...
        If Ship.y > _Height + 5 _AndAlso Not Flag.landingTime Then Ship.y = -4 '                                 normal
        '
        If Ship.y > _Height - 117 _AndAlso Flag.landingTime _AndAlso Not Sb.go2Space _AndAlso Not Sb.doFF Then ShipBoom '  crash on moon surface
    Else ForceFieldControl '                                                                             ** FORCE FIELD CHALLENGE **
    End If '
End Sub
' -----------------------------------------
Sub SaucerControl () '                       a separate loop for drone battle

    Dim As Integer a, c, d, i, targetX, targetY, cSx, cSy ' corrected Saucer X & Y
    Dim As Integer angle(1 To 4), wide, high, numWaves, hitX, hitY
    Dim As _Byte initd, doBoom, playing, cycleCount, leftClick, rndDone
    Dim As Long outImg
    Dim As XYPair lo(1 To 4) '                              gun locations
    Shared As Integer toteSaucers, saucerKills, shipNum, limit
    Shared As Long saucerScape, starScape, starScape3, HDWimg(), mainScreen
    Shared As _Byte sparkCycles
    Shared spark() As spark, saucer() As saucer
    Shared As Single xScroller
    Static As _Byte adviceGiven

    PCopy starScape3, starScape '   <<<< new, copy custom landingTime screen to main background screen
    xScroller = 0 '                 reset scrolling so the screen doesn't jump cut
    If Control.clearStatics Then '
        initd = _FALSE
        doBoom = _FALSE
        cycleCount = 0
        Exit Sub
    End If

    If Not initd Then '
        wide = 1600: high = 900 '                   new rez 1600x900
        lo(1).x = 30: lo(1).y = 30 '                upper left        ** set gun locations **
        lo(2).x = wide - 30: lo(2).y = 30 '         upper right
        lo(3).x = 30: lo(3).y = high - 30 '         lower left
        lo(4).x = wide - 30: lo(4).y = high - 30 '  lower right
        Screen _NewImage(wide, high, 32) '          ** higher resolution **
        'If _FullScreen = 0 Then _ScreenMove DTW / 2 - _Width / 2, DTH / 2 - _Height / 2
        KillNoises '                                takes care of stuck thruster sound
        initd = _TRUE
        For i = 255 To 0 Step -4 '                  fade in scene
            _Limit 120 '                            control fade speed
            _PutImage , saucerScape
            _PutImage , ViewScreen
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            _Display
        Next
    End If
    _KeyClear: _PrintMode _KeepBackground
    _MouseMove _Width \ 2, _Height \ 2

    Do '
        If Not doBoom Then '                        assign saucers, advamce wave count, up limit when done with explosions only
            AssignSaucers
            numWaves = numWaves + 1
            limit = limit + Game.killRatio * .08 '                          speed up a bit each wave based on performance
            If numWaves < 6 Then toteSaucers = toteSaucers + shipNum '      track total saucers in sequence for kill ratio
        End If
        ' ---------------------------------
        Do
            _Limit limit '                                                  limit set by saucer quantity in assignSaucers sub
            'If _FullScreen = 0 Then _MouseShow: _MouseHide '                prevents pointer from appearing
            If d < 201 Then d = d + 1
            If Not adviceGiven _AndAlso d = 200 Then _SndPlay VO(37): adviceGiven = _TRUE '    targeting advice
            If Not Control.hold Then '                                      pause execution during a call to settings sub
                While _MouseInput: Wend
                targetX = _MouseX
                targetY = _MouseY
                leftClick = _MouseButton(1)
                Cls
                _PutImage , saucerScape '                                       stars
                Circle (targetX, targetY), 20, C(9) '                           target circle - gotta add 20 both ways for image corner vs, mouse x,y issue
                Line (targetX, targetY - 15)-(targetX, targetY + 15), C(4) '    crosshairs
                Line (targetX - 15, targetY)-(targetX + 15, targetY), C(4)
                Color C(14) '                                                               ** SCORE ZONE **
                _Font MenloBig
                _PrintString (_Width - 290, 53), "SCORE:  " + Str$(Game.score) '
                _Font ModernBigger
                _PrintString (140, 53), "TOTAL SAUCERS: " + Str$(toteSaucers)
                _PrintString (140, 73), "DESTROYED:     " + Str$(saucerKills)
                Game.killRatio = Int(saucerKills / toteSaucers * 100) '
                _PrintString (140, 93), "KILL RATIO:    " + Str$(Game.killRatio) + "%"
                ShowHorzGauge 140, 128, Ship.power / 100, "POWER  " + Str$(Int(Ship.power)) + "%", _RGB32(61, 255, 78, 220)
                ShowHorzGauge 140, 158, Ship.shields / 100, "SHIELDS  " + Str$(Int(Ship.shields)) + "%", C(12)
                ' -------------------------
                c = 0
                Do '                                                                        ** GUN ZONE **
                    c = c + 1
                    angle(c) = GETANGLE(lo(c).x, lo(c).y, targetX, targetY) '               get all four angles
                    RotateImage angle(c), I(1), outImg '                                    rotate and render all guns
                    _PutImage (lo(c).x - _Width(outImg) \ 2, lo(c).y - _Height(outImg) \ 2), outImg, 0
                Loop Until c = UBound(lo)
                ' -------------------------
                a = 0 '                                                             command string parse
                Do
                    a = a + 1 '                                                     increments thru saucers up to shipNum
                    If saucer(a).alive Then '                                       skip dead saucers
                        If saucer(a).getCommand Then
                            GetNextCommand a '                                      grab action letter and loopNum from command line
                            saucer(a).getCommand = _FALSE
                        End If
                        If saucer(a).loopCounter = saucer(a).loopNum Then '         if still churning thru single command don't reassign new command yet
                            saucer(a).getCommand = _TRUE
                            _Continue '                                             skip this cycle till new command retrieved
                        End If
                        saucer(a).loopCounter = saucer(a).loopCounter + 1 '         increment action counter up to loopNum
                        RenderSaucer a
                        _PutImage (saucer(a).loc.x, saucer(a).loc.y), HDWimg(a), 0 ' put saucers to screen
                    End If
                Loop Until a = shipNum '
                ' -------------------------
                If leftClick Then '                                                 ** MOUSE ACTION **
                    If cycleCount < 14 Then
                        cycleCount = cycleCount + 1
                        If Not playing Then _SndPlayCopy S(27), .12: playing = _TRUE '       laser blasts
                        a = 0 '
                        Do '                                        4 laser positions wuth 3 beams each
                            a = a + 1
                            Line (lo(a).x, lo(a).y)-(targetX, targetY), C(4) '              middle beam green
                            Line (lo(a).x + 2, lo(a).y + 2)-(targetX, targetY), C(14) '     side 1 yellow
                            Line (lo(a).x - 2, lo(a).y - 2)-(targetX, targetY), C(12) '     side 2 red
                        Loop Until a = 4

                        a = 0
                        Do '                                        check for hit...
                            a = a + 1
                            If saucer(a).alive Then
                                ' correct saucer location onscreen with cursor/target - as saucer image grows, upper right corner steps back
                                cSx = saucer(a).loc.x + 30 '
                                cSy = saucer(a).loc.y + 30 '
                                If targetX > cSx - 15 _AndAlso targetX < cSx + 15 Then
                                    If targetY > cSy - 15 _AndAlso targetY < cSy + 15 Then '
                                        _SndPlay S(Int(Rnd * 3 + 4)) '                  booms
                                        Game.score = Game.score + (75 * Game.diff_mult) '
                                        saucerKills = saucerKills + 1 '
                                        saucer(a).alive = _FALSE
                                        hitX = saucer(a).loc.x
                                        hitY = saucer(a).loc.y
                                        doBoom = _TRUE
                                        Exit Do '
                                    End If
                                End If
                            End If
                        Loop Until a = shipNum
                    End If
                End If
                ' -------------------------
                If Not leftClick Then playing = _FALSE: cycleCount = 0 '     kill sound,  reset laser fire time
                If doBoom Then
                    boomInfo.num = 20 '
                    boomInfo.r = 200 '
                    boomInfo.g = 220
                    boomInfo.b = 110 '
                    sparkCycles = sparkCycles + 1
                    If sparkCycles < boomInfo.num Then MakeSparks hitX + 28, hitY + 28
                    UpdateSparks
                    If sparkCycles >= boomInfo.num Then
                        doBoom = _FALSE
                        sparkCycles = 0
                        ReDim spark(0) As spark '           took a while to figure out to put this here! <<<<
                    End If
                End If
                ' -------------------------
                ManageBullets '                             enemy fire
                _PutImage , ViewScreen '                    window border for cockpit view
                _Display

                If _KeyDown(27) Then '                      popUp
                    Control.pop = _TRUE
                    _MouseShow
                    Control.hold = _TRUE
                    _KeyClear '
                End If
                If _KeyDown(115) _OrElse _KeyDown(83) Then numWaves = 6 '        <<<< <S> to skip saucers FOR TESTING ONLY <<<< CHEAT KEY <<<<
                ' ************************                  local sound events
                If Not Resetter(16) Then _SndLoop S(31): Resetter(16) = _TRUE '         loop saucer bg
                If Not Resetter(17) Then SndFade2 S(31), .001, .04, 0, 17 '             turn up saucer loop
                ' ************************
                If numWaves = 4 Then _SndPlay VO(20): _SndPlay S(35) ' unusual energy reading   ** SAUCER ROUNDS **
                If numWaves = 6 Then
                    Sb.doFF = _TRUE: SubFlags(3) = _TRUE '                              turn on force field sub
                    FPS = Game.speed '
                    Sb.doSaucers = _FALSE: SubFlags(16) = _FALSE
                    numWaves = 0 '                                                      reset static variables for next round
                    Ship.speed = 0
                    Screen mainScreen '                                                 back to lower resolution
                    'If _FullScreen = 0 Then _ScreenMove DTW \ 2 - _Width \ 2, DTH \ 2 - _Height \ 2
                    Cls '
                    initd = _FALSE '                                                    reset init flag
                    _Font 16
                    _FreeImage outImg '
                    _KeyClear
                    Exit Sub
                End If

                c = 0
                rndDone = _TRUE '                            check for done
                Do
                    c = c + 1
                    If saucer(c).alive Then
                        rndDone = _FALSE
                        Exit Do
                    End If
                Loop Until c = shipNum
            End If '                   -------- BOTTOM OF HOLD POINT --------
            If Control.pop Then PopUp
            If Sb.doInstructs Then Instructions
        Loop Until rndDone
    Loop
End Sub
' -----------------------------------------
Sub ForceFieldControl () '                    ship behavior and cage

    Dim As Integer b1, b2, i
    Static As Single c1, c2, a, b, ffTime
    Static As XYPair alien
    Static As _Byte play2, initFF, hintGiven
    Static As Integer c, cycles
    Dim As Long img, outimg
    Dim As _Byte minutes, seconds
    Dim secs$
    Shared As _Unsigned Long weakWallColor
    Shared As _Byte bounceOffs
    Shared As Long starScape, shipImg
    Shared As String shipType()

    If Control.clearStatics Then initFF = _FALSE: cycles = 0: c = 0: Exit Sub '
    If Not Resetter(20) Then _SndPlay S(34): Resetter(20) = _TRUE '  scary noise

    If Not initFF Then '
        bounceOffs = 0
        For i = 255 To 0 Step -3 '                                  fade in scene
            _Limit 130 '                                            control fade speed
            _PutImage , starScape
            _PutImage (CENTX - 20, CENTY + 50), shipImg
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            _Display
            initFF = _TRUE
        Next

        KillChecks: KillNoises
        alien.x = _Width + 50 '             put alien offstage right
        alien.y = _Height \ 2 - 25
        _SndStop S(31)
        Do '                                alien zooms in
            Cls
            _Limit 90
            alien.x = alien.x - 3
            _PutImage , starScape
            _PutImage (CENTX - 20, CENTY + 50), shipImg
            _PutImage (alien.x, alien.y), I(2) '
            _Display
        Loop Until alien.x <= _Width \ 2 - 60

        _SndPlay S(33) '                    shoot sound
        _SndPlay S(26) '                    swooping in sound
        a = 4: b = 2.58 '
        c = 0: FPS = 6
        Do '                                spinning force field animation
            Cls
            _Limit FPS '
            _PutImage , starScape
            _PutImage (CENTX - 20, CENTY + 50), shipImg
            alien.x = alien.x + 5
            _PutImage (alien.x, alien.y), I(2) '
            a = a * 1.019
            b = b * 1.019
            c = c + 5
            If FPS < 105 Then FPS = FPS + 2

            If img <> 0 Then _FreeImage img: img = 0 '  NEW NEW LEAKS PLUGGED!
            img = _NewImage(a, b, 32)
            If outimg <> 0 Then _FreeImage outimg: outimg = 0
            outimg = _NewImage(a, b, 32)

            _Dest img
            Line (1, 1)-(_Width - 1, _Height - 1), C(14), B
            If c > 30 Then Paint (_Width / 2, _Height / 2), _RGB32(255, 0, 0, 132), C(14)
            _Dest 0
            RotateImage c, img, outimg
            _PutImage (CENTX - _Width(outimg) / 2, CENTY - _Height(outimg) / 2), outimg
            _Display
        Loop Until c = 1445 '

        _FreeImage img: _FreeImage outimg '     <<<<<<<<<<<<<<
        If Not Resetter(19) Then _SndVol S(32), .025: _SndLoop S(32): Resetter(19) = _TRUE '      ~
        Ship.course = 0 '
        weakWallColor = C(14) '                 reset WeakWallColor  <<
        _SndPlay S(13) '                        warning beeps (4)
        Ship.x = CENTX: Ship.y = CENTY + 69
        Ship.speed = 0: Ship.course = 0 '
        ffTime = Timer
    End If '                    --------------  bottom of INITFF  -------------

    _Font Menlo: Color C(9)
    Time.inCage = Int(Timer - ffTime)
    If Not hintGiven _AndAlso Time.inCage > 60 _AndAlso bounceOffs < 4 Then _SndPlay VO(36): hintGiven = _TRUE '      ** HUGE HINT **
    _PrintMode _KeepBackground
    minutes = Int(Time.inCage / 60): seconds = Time.inCage Mod 60
    If Time.inCage < 10 Then
        _PrintString (_Width / 2 - _PrintWidth("XXXX SECONDS") / 2, _Height - 30), Str$(Time.inCage) + " SECONDS"
    Else
        If seconds < 10 Then secs$ = "0" + _Trim$(Str$(seconds)) Else secs$ = _Trim$(Str$(seconds))
        _PrintString (_Width / 2 - _PrintWidth("0:00") / 2, _Height - 30), _Trim$(Str$(minutes)) + ":" + secs$
    End If

    cycles = cycles + 1 '
    Select Case cycles '                    sound events
        Case 40: _SndPlay S(13)
        Case 98: play2 = _TRUE
        Case 100: _SndPlay VO(17)
        Case 340: play2 = _FALSE
        Case 350: _SndPlay VO(18)
        Case 450: _SndPlay VO(16)
        Case 750: _SndPlay S(3) '
            Flag.landingTime = _TRUE '       also true (main thrusters ON) if weak wall is hit
    End Select

    If play2 Then _SndPlay S(12)
    If Ship.x > _Width - LINEX Then Ship.x = _Width - (LINEX + 10): Ship.Vx = 0: Ship.Vy = 0: _SndPlay S(2) '   force field cage rules
    If Ship.y < 50 Then Ship.y = 60: Ship.Vy = 0: Ship.Vx = 0: _SndPlay S(2) '
    If Ship.y > _Height - 50 Then Ship.y = _Height - 60: Ship.Vy = 0: Ship.Vx = 0: _SndPlay S(2)
    If Not Sb.doDeflect Then Line (LINEX, 50)-(LINEX, _Height - 50), weakWallColor ' draw left cage side    ** WEAK WALL <<<<<  draw box
    Line (LINEX, 50)-(_Width - LINEX, 50), C(14) '          top line                                        ** DRAW FF CAGE **
    Line -(_Width - LINEX, _Height - 50), C(14) '           right side
    Line -(LINEX, _Height - 50), C(14) '                    bottom line
    '                                                       line effects
    If c1 < _Width - 320 Then c1 = c1 + 9 Else c1 = 0 '
    If c2 < _Height - 100 Then c2 = c2 + 5.82 Else c2 = 0 ' moving green balls over yellow lines
    If b2 < _Height - 100 Then b2 = b2 + c2
    If b1 < _Width - 50 Then b1 = b1 + c1
    Circle (LINEX + b1, 50), 3, C(4) '                      top
    Circle (LINEX + b1, _Height - 50), 3, C(4) '            bot
    Circle (_Width - LINEX - b1, 50), 3, C(4) '             top
    Circle (_Width - LINEX - b1, _Height - 50), 3, C(4) '   bot
    Circle (_Width - LINEX, _Height - 50 - b2), 3, C(4) '   right bot
    Circle (_Width - LINEX, 50 + b2), 3, C(4) '             right top
    If bounceOffs < 3 Then
        Circle (LINEX, 50 + b2), 3, C(4) '                  left top  ** WEAK WALL <<<<< moving balls
        Circle (LINEX, _Height - 50 - b2), 3, C(4) '        left bot  **
    Else
        If Not Resetter(29) Then _SndPlay S(20): Resetter(29) = _TRUE
    End If

    If Ship.x < LINEX Then '                             ** CONTACT WITH WEAK WALL **
        Sb.doFF = _FALSE: SubFlags(3) = _FALSE
        Flag.landingTime = _TRUE '                           turn on main thrusters
        Sb.doDeflect = _TRUE: SubFlags(4) = _TRUE '           do deflect sub
        Flag.regularChecks = _FALSE '
        If Ship.power < 7 _AndAlso bounceOffs > 4 Then Ship.power = Ship.power + 11 ' prevents blowing up in mid-stretch of weak wall glitch <<<<
    End If '
    _Font 16
End Sub
' -----------------------------------------
Sub DeflectFF () '                             draw lines, determine how much to spring

    Static As Single oldVx, decel '
    Static As _Byte initd, started
    Static As Integer redd, gren, busted
    Shared As _Unsigned Long weakWallColor
    Shared As _Byte bounceOffs
    Dim As _Unsigned Long WWCol

    If Control.clearStatics Then
        initd = _FALSE
        started = _FALSE
        busted = 0
        decel = 0
        Exit Sub
    End If

    If Not started Then
        redd = 225
        gren = 255
        started = _TRUE
        KillChecks '                            prevents boom sounds @ escaping...
    End If
    If Not initd Then oldVx = Ship.Vx: initd = _TRUE
    If Ship.x > LINEX - 10 _AndAlso Ship.x < LINEX _AndAlso Ship.Vx < 0 Then _SndPlay S(1) '      impact thump
    If _KeyDown(115) _OrElse _KeyDown(83) Then busted = 42 '                                                 to skip this chapter press <s> - for testing

    If Ship.x < 40 Then busted = busted + 1 '   track cycles in stretch zone
    If busted > 40 Then '                       FF broken! REDUCED FROM 50 TO 40
        busted = 0 '                            CLEANUP on the ** way out **
        decel = 0
        bounceOffs = 0
        Flag.landingTime = _FALSE '
        Sb.goDissolveFF = _TRUE: SubFlags(15) = _TRUE
        Flag.regularChecks = _TRUE '
        Sb.doDeflect = _FALSE: SubFlags(4) = _FALSE
        initd = _FALSE
        started = _FALSE
        _SndPlay S(24) '                        whip sound for breaking FF
        Ship.speed = 5 '                        zoom away
        oldVx = 0
        Game.score = Game.score + (350 * Game.diff_mult) '
    End If

    If Ship.x > LINEX - 30 Then WWCol = weakWallColor Else WWCol = C(12) '  weakened FF color vs. bright red when stretched tight
    Line (LINEX, 50)-(Ship.x, Ship.y + 2), WWCol '              draw 2-part FF line bent around ship deflection
    Line (LINEX, _Height - 50)-(Ship.x, Ship.y), WWCol
    If Ship.x < LINEX Then Ship.Vx = Ship.Vx + 2 - decel '      quick deceleration

    If Ship.Vx < .5 _AndAlso Ship.Vx > -.5 Then '                    spring back!
        Ship.Vx = -oldVx * 1.3 '
        If bounceOffs > 2 Then _SndPlay S(25) '                 do zoom sound
    End If

    If Ship.x > LINEX Then '                                    bounce back reset
        If decel < 1.8 Then decel = decel + .2 '                greater stretchiness each bounce-off by increasing Vx reduction
        bounceOffs = bounceOffs + 1
        If redd < 256 Then redd = redd + 4 '
        If gren > 11 Then gren = gren - 11 '
        weakWallColor = _RGB32(redd, gren, 0)
        Sb.doDeflect = _FALSE: SubFlags(4) = _FALSE
        Sb.doFF = _TRUE: SubFlags(3) = _TRUE
        initd = _FALSE
    End If
End Sub
' -----------------------------------------
Sub DissolveFF () ' this fades the force field and returns to rock harvest - with increased # of rocks

    Static As Single fader
    Static As _Byte initd
    Static As Integer c, adjuster, upperX, lowerX

    If Control.clearStatics Then initd = _FALSE: c = 0: Exit Sub
    If Not initd Then
        fader = 255
        _SndPlay S(23) '                        heaven sound
        c = 0
        initd = _TRUE
        adjuster = CENTY - Ship.y '             adjust line segment lengths of broken FF acc. to ship.y position
        If Sgn(adjuster) = 1 Then
            adjuster = (-CENTY + Ship.y) \ 5
            upperX = adjuster
            lowerX = -adjuster
        End If

        If Sgn(adjuster) = -1 Then
            adjuster = (Ship.y - CENTY) \ 5
            lowerX = adjuster
            upperX = -adjuster
        End If
    End If

    c = c + 1 '
    Line (LINEX, 50)-(_Width - LINEX, 50), _RGB32(255, 190, 0, fader) '     top line        ** draw FF cage **
    Line -(_Width - LINEX, _Height - 50), _RGB32(255, 190, 0, fader) '      right side
    Line -(LINEX, _Height - 50), _RGB32(255, 255, 0, fader) '               bottom line
    Line (LINEX, 50)-(36 + upperX, 205 - c), _RGB32(255, 0, 0, fader) '                     broken weak wall segments
    Line (LINEX, _Height - 50)-(48 + lowerX, _Height - 210 + c), _RGB32(255, 0, 0, fader)
    fader = fader - 1.65 ' was 1.4
    If fader < 30 Then '                    reset           ** END OF FIRST ROUND **        <<<< <<<< <<<< <<<< <<<<
        Sb.goDissolveFF = _FALSE: SubFlags(15) = _FALSE
        initd = _FALSE '                     reset init
        If MaxRocks < 30 Then MaxRocks = MaxRocks + 4 '     increase bouncing rock count
        Flag.fadeInRocks = _TRUE '                           flip on flags for new round
        Flag.doAutoShields = _TRUE
        Flag.doRockMask = _FALSE '                           masks come on after start of new round - rock fade in...
        rock(Target).stayPainted = _FALSE
        _SndStop S(32)
        Control.clearStatics = _TRUE '                       RESET statics for new ROUND only - no running startUp
        ResetFlags '
    End If
End Sub
' -----------------------------------------
Sub PostLanding ()

    Dim As _Byte i
    Shared As Long starScape2

    If _KeyDown(27) Then Sb.doPopUp = _TRUE '    in case you wanna popUp while landed
    If _KeyDown(32) _AndAlso Ship.charged Then '     blast off from charging station
        Ship.charged = _FALSE
        Ship.charging = _FALSE '                 done in main loop charging section <<<<
        Ship.landed = _FALSE
        Flag.chargeDone = _TRUE
        Sb.doTruck = _FALSE '                    turn off truck sub / landing beacons
        Ship.x = 761: Ship.y = 530
        _SndPlay S(20) '                        zap sound
        _SndPlay VO(23) '                       now leave orbit voice over
        If _SndPlaying(VO(14)) _AndAlso _SndPlaying(VO(23)) Then _SndStop VO(14) '           cut off "When you're done..." with "Now leave orbit..."
    End If
    If _KeyDown(32) _AndAlso Ship.x < 700 _AndAlso Not Ship.detached _AndAlso Game.round = 1 Then '    detach rock in drop zone (if the ship isn't at the charging station --> x check)
        RedrawShip
        Flag.detachRock = _TRUE '
        Flag.doRockMask = _FALSE
        Sb.rockMoving = _TRUE: SubFlags(13) = _TRUE
        Ship.detached = _TRUE
        _SndStop VO(12) '                       great landing, now press the space bar
        _SndPlay S(19) '                        hydraulic sound
    End If
    If Game.round > 1 Then '                    end of game fireworks
        Flag.thrustersOn = _FALSE
        Fireworks
        _SndStop S(47): _SndStop S(48)
        For i = 1 To 86: KeepScrolling .22: Next i ' scroll for a sec...
        PCopy _Display, starScape2
        Control.endIt = _TRUE
    End If
    _KeyClear
End Sub
' -----------------------------------------
Sub MoveTargetRock () '

    Static As Integer c
    Static As Single d, e, alpha
    Static As _Byte played '
    Shared As Integer spin2
    Shared As _Byte bannerON
    Dim As Integer xStart, yStart

    If Control.clearStatics Then '
        c = 0: d = 0
        e = 0: alpha = 0
        Exit Sub
    End If
    xStart = 326: yStart = 644 '                            location of laser station, green start color
    c = c + 1
    If c = 99 Then _SndLoop S(22) '                         tractor beam sound
    If c > 105 _AndAlso c < 205 Then
        rock(Target).y = rock(Target).y - .48 '             pick up rock, heat it up
        If d < 127 Then d = d + .88
        rock(Target).col = _RGB32(0, Int(127 + d), 0) '     change rock edge color dark green to bright green
        RedrawShip
    End If
    If c > 205 _AndAlso c <= 500 Then
        If Not played _AndAlso c > 240 Then
            _SndPlay VO(13) '                               recharge and instructions, played once only
            _SndPlay VO(15) '                               time staggered sounds for simultaneous play
            played = _TRUE
        End If
        rock(Target).col = C(4)
        rock(Target).x = rock(Target).x - .67 '                     slide over and fade in dark green body fill color, bake it
        PSet (rock(Target).x, rock(Target).y), rock(Target).col '
        Draw "TA=" + VarPtr$(spin2) + rock(Target).kind '           draw rock - gotta draw the rock before painting it
        PSet (rock(Target).x, rock(Target).y), C(0) '               erase center dot    <<<<
        If e < 255 Then e = e + 1.1
        Paint (rock(Target).x, rock(Target).y), _RGB32(0, 106, 0, Int(alpha + e)), C(4) ' fill rock w/ green
        RedrawShip
    End If

    If c = 390 Then bannerON = _TRUE '                               show instruction
    If c > 500 _AndAlso c < 642 Then '                               place rock and magically crystalize it
        rock(Target).y = rock(Target).y + .5
        PSet (rock(Target).x + Int((Rnd - Rnd) * 35), rock(Target).y + Int((Rnd - Rnd) * 33)), C(14) '      yellow fairy dust
        PSet (rock(Target).x + Int((Rnd - Rnd) * 35), rock(Target).y + Int((Rnd - Rnd) * 33)), C(16) '      brightwhite
        Circle (rock(Target).x + Int((Rnd - Rnd) * 30), rock(Target).y + Int((Rnd - Rnd) * 33)), 3, C(4) '  bright green circle
        Circle (rock(Target).x + Int((Rnd - Rnd) * 30), rock(Target).y + Int((Rnd - Rnd) * 33)), 3, C(3) '  dark green circle
        RedrawShip
    End If

    PSet (rock(Target).x, rock(Target).y), rock(Target).col '
    Draw "TA=" + VarPtr$(spin2) + rock(Target).kind '               draw rock

    If c > 110 _AndAlso c < 350 Then '                              attempt to block center dot
        Circle (rock(Target).x, rock(Target).y), 1, _RGB32(1)
        Paint (rock(Target).x, rock(Target).y), C(0), _RGB32(1)
    End If

    If c > 26 Then
        PSet (rock(Target).x, rock(Target).y), C(0) '    erase center dot  NOT WORKING for some reason, works elsewhere...  <<<<
        PSet (rock(Target).x - 1, rock(Target).y), C(0)
    End If

    If c >= 500 Then Paint (rock(Target).x, rock(Target).y), _RGB32(0, 98, 0), C(4)
    If c > 600 Then
        _PutImage (rock(Target).x - 20, rock(Target).y - 20), I(0) '                                        final rock overlay
        Circle (rock(Target).x + Int((Rnd - Rnd) * 20), rock(Target).y + Int((Rnd - Rnd) * 23)), 3, C(4) '  bright green circles
        Circle (rock(Target).x + Int((Rnd - Rnd) * 20), rock(Target).y + Int((Rnd - Rnd) * 23)), 3, C(3) '  dark green circles
    End If
    _PutImage (0, 530)-(1280, 720), MoonScape '                                 draw moonscape again to cover the rock edges upon landing
    If c > 99 Then
        Line (xStart, yStart)-(rock(Target).x - 15, rock(Target).y), C(14) '    lasers move rock
        Line (xStart, yStart)-(rock(Target).x + 15, rock(Target).y), C(14)
    End If
    If c > 642 Then '                                                           done, reset
        c = 0: d = 0: e = 0: alpha = 0
        Sb.rockMoving = _FALSE: SubFlags(13) = _FALSE
        bannerON = _FALSE
        rock(Target).stayPainted = _TRUE '                           triggers the new '3D' rock image in shipControl
        _SndStop S(22) '                                            kill tractor beam sound
    End If
End Sub
' -----------------------------------------
Sub CheckLanding () '                       rock drop checking

    Shared As String shipType()
    Shared As Integer diffX
    '                                                                                                               x and y position already checked in main loop
    If Ship.Vy < .85 _AndAlso Ship.Vy > 0 _AndAlso Abs(Ship.Vx) < .5 _AndAlso (-Ship.course >= 356 _OrElse -Ship.course <= 4) Then '    check y vector, x vector, ship orientation (upright)
        KillNoises
        _SndPlay S(3)
        Ship.kind = shipType(4)
        Ship.landed = _TRUE '
        Ship.Vx = 0: Ship.Vy = 0
        Ship.y = 564 '                      put it on the pad
        Ship.speed = 0: Ship.course = 0
        Flag.thrustersOn = _FALSE '          kill thrusters for 2 secs after landing
        Time.ThrustersOff = Timer '         start timer
        If Not Resetter(28) Then Game.score = Game.score + (500 * Game.diff_mult) '
        If Not Resetter(28) _AndAlso diffX = 277 Then Game.score = Game.score + 150 '        extra points for MEDIUM difficulty
        If Not Resetter(28) _AndAlso diffX = 413 Then Game.score = Game.score + 300 '        extra, extra bonus points for HARD difficulty...
        Resetter(28) = _TRUE
        RedrawShip '
    End If
End Sub
' -----------------------------------------
Sub Check4Harpoon ()

    Shared As Integer lockedAngle
    Dim spin As Integer
    '
    If Not Flag.harpooned _AndAlso Abs(Ship.x - rock(Target).x) < 10 Then '                  check for ship and target rock overlap
        If Abs(Ship.y - rock(Target).y) < 10 Then
            If _KeyDown(32) Then
                _SndPlay S(14)
                ' make the ship controls work on the rock, turn off drawRocks on target only
                rock(Target).rotation = _FALSE
                spin = rock(Target).spinAngle
                Draw "TA=" + VarPtr$(spin) + rock(Target).kind
                lockedAngle = Ship.course '
                Flag.harpooned = _TRUE
                Flag.shutBackDoor = _TRUE
                Game.score = Game.score + (500 * Game.diff_mult)
            End If
        End If
    End If
End Sub
' -----------------------------------------
Sub Check4RockContact () '                  circle proximity - collision detection
    '                                       Thanks, Terry Ritchie
    Shared As rect cBox, wBox
    Dim As _Byte c, w

    w = 0: c = 0 '                                              compare rock(c) to others, rocks (w)
    Do
        c = c + 1
        w = c
        Do
            w = w + 1
            cBox.x1 = rock(c).x - rock(c).radius '              calculate rectangular coordinates
            cBox.y1 = rock(c).y - rock(c).radius '              for rock c and rock w
            cBox.x2 = rock(c).x + rock(c).radius '
            cBox.y2 = rock(c).y + rock(c).radius
            wBox.x1 = rock(w).x - rock(w).radius
            wBox.y1 = rock(w).y - rock(w).radius
            wBox.x2 = rock(w).x + rock(w).radius
            wBox.y2 = rock(w).y + rock(w).radius
            If RectCollide(cBox, wBox) Then '                   rectangular collision?
                If CircCollide(rock(c), rock(w)) Then '         circle collision?
                    CheckRockCollision c, w '                   collision happened!
                    CheckFor3WayLockUp c, w
                End If
            End If
        Loop Until w = MaxRocks
    Loop Until c = MaxRocks - 1
End Sub
'------------------------------------------
Sub CheckFor3WayLockUp (c As _Byte, w As _Byte) '   rocks c & w are now possibly stuck, check for another culprit

    Dim As _Byte a, b, dummy

    a = 0
    dummy = c
    Do
        a = a + 1
        If a = 2 Then dummy = w '                   on second run thru check the w rock
        b = 0
        Do
            b = b + 1
            If b <> c _AndAlso b <> w Then '
                If CircCollide(rock(dummy), rock(b)) Then '
                    ' make all three vectors opposite vectors
                    _SndPlay S(2)
                    Repel3 b, c, w '                push the three apart
                End If
            End If
        Loop Until b = MaxRocks - 1
    Loop Until a = 2
End Sub
' -----------------------------------------
Sub Check4ShipROCKCollision () '

    Shared As rect cBox, wBox
    Shared As Integer rockHeading '
    Dim As Integer w '
    Static As _Byte played, oldW

    w = 0
    Do
        w = w + 1
        cBox.x1 = Ship.x - Ship.radius '                    calculate rectangular coordinates
        cBox.y1 = Ship.y - Ship.radius '                    for ship and rock w
        cBox.x2 = Ship.x + Ship.radius '
        cBox.y2 = Ship.y + Ship.radius
        wBox.x1 = rock(w).x - rock(w).radius
        wBox.y1 = rock(w).y - rock(w).radius
        wBox.x2 = rock(w).x + rock(w).radius
        wBox.y2 = rock(w).y + rock(w).radius
        If w <> Target Then '                               exclude the purple rock
            If RectCollide(cBox, wBox) Then '               rectangular collision?
                If CircCollide2(Ship, rock(w)) Then '       circle collision?
                    If Ship.shields <= 0 Then '             ship explodes when doAutoShields are spent
                        Ship.shields = 0
                        ShipBoom: Ship.power = 5 '                              prevent double ship
                        Game.score = Game.score - (100 * Game.diff_mult) '      boom penalty
                        Time.overlap = 0 '                                      reset overlap cycles
                        Exit Sub
                    ElseIf Not Flag.harpooned Then '                            bounce off with auto shields
                        _SndPlayCopy S(7), .27 '                                deflection sound
                        rockHeading = (Vec2Deg%(rock(w).Vx, rock(w).Vy)) '      both are in negative degrees
                        Ship.course = rockHeading - 45 '                        course change
                        If Ship.speed < 1 Then Ship.speed = 1.1
                        Flag.doCircle = _TRUE
                        Sb.trackShields = _TRUE: SubFlags(11) = _TRUE
                        Ship.shields = Ship.shields - .64 '
                        Game.score = Game.score - (2 * Game.diff_mult) '
                        Ship.power = Ship.power - .4
                    Else '                                                      ship/rock contact with harpooned rock
                        If oldW <> w Then played = _FALSE '                      rock takes ship's vector plus 8%
                        If Not played Then _SndPlayCopy S(1), .85: played = _TRUE '  a righteous loud thump
                        rock(w).Vx = Ship.Vx * 1.06 '                           bounce it! <<<< new new new
                        rock(w).Vy = -Ship.Vy * 1.06
                        oldW = w
                    End If
                End If
            End If
        End If
    Loop Until w = MaxRocks
End Sub
' -----------------------------------------
Sub CheckRockCollision (c As Integer, w As Integer) '       collisions between rock(c) & rock(w)

    Static As Integer oldC, oldW
    Dim As Integer hypot, overlap, push '

    Swap rock(c).Vx, rock(w).Vx '                           Thanks to ** Will Kluger ** for help with this routine
    Swap rock(c).Vy, rock(w).Vy '                           always swap colliding rocks vectors upon collision
    If Not _SndPlaying(S(1)) Then _SndPlayCopy S(1), .13 '  thump

    If c = oldC _AndAlso w = oldW Then '            ****** TROUBLE > if it's the same two rocks again, then push them apart
        hypot = FindHypot(rock(c), rock(w)) '                   calculate how far to push them, uses slow SQR() but only a little
        overlap = (rock(c).radius + rock(w).radius) - hypot
        push = overlap / 2 + 4 ' 3                                      # of pixels needed each way (x, y) to achieve separation (and a bit more)
        ' counter measures for pushing 2 rocks out of a stuck state  '  ** TROUBLESHOOTING ** OVERLAP BUZZER goes here **
        If rock(c).x > rock(w).x Then '                                 push locations apart based on relative position
            rock(c).x = rock(c).x + push
            rock(w).x = rock(w).x - push
        Else If rock(c).x <= rock(w).x Then
                rock(w).x = rock(w).x + push
                rock(c).x = rock(c).x - push
            End If
        End If
        If rock(c).y > rock(w).y Then
            rock(c).y = rock(c).y + push '
            rock(w).y = rock(w).y - push
        Else If rock(c).y <= rock(w).y Then
                rock(w).y = rock(w).y + push
                rock(c).y = rock(c).y - push
            End If
        End If
        oldC = 0 '                  reset rocks to compare
        oldW = 0
        Exit Sub '                  don't save old rock pair below, skip rotation change
    End If
    oldC = c: oldW = w '            save collision pair to compare to next cycle's pair
    ' ----------------------
    If rock(c).rotation Then '                                                                      flip rotation randomly
        If rock(c).rotDir = "clock" Then rock(c).rotDir = "cClock" Else rock(c).rotDir = "clock" '  rocks initially are 1 or 2 spinspeed
        If rock(c).spinSpeed = 2 Then rock(c).spinSpeed = 1
    End If
    If rock(w).rotation Then
        If rock(w).rotDir = "clock" Then rock(w).rotDir = "cClock" Else rock(w).rotDir = "clock"
        If rock(w).spinSpeed = 1 Then rock(w).spinSpeed = 2 Else rock(w).spinSpeed = 1 ' 2, 3
    End If
End Sub
' -----------------------------------------
Sub CheckShipCOMETCollision () '

    Shared As rect cBox, wBox
    Shared comet() As comet
    Dim As Integer w

    w = 0
    Do
        w = w + 1
        If comet(w).alive Then
            cBox.x1 = Ship.x - Ship.radius '                calculate rectangular coordinates
            cBox.y1 = Ship.y - Ship.radius '                for rock c and rock w
            cBox.x2 = Ship.x + Ship.radius '
            cBox.y2 = Ship.y + Ship.radius
            wBox.x1 = comet(w).x - comet(w).radius
            wBox.y1 = comet(w).y - comet(w).radius
            wBox.x2 = comet(w).x + comet(w).radius
            wBox.y2 = comet(w).y + comet(w).radius

            If RectCollide(cBox, wBox) Then '               rectangular collision?
                If CircCollide3(Ship, comet(w)) Then '      circle collision?
                    Ship.shields = Ship.shields - 4 '       shields
                    Game.score = Game.score - (25 * Game.diff_mult) '   score
                    Ship.power = Ship.power - 1.7 '         power
                    If Not Flag.boomInProgress Then '       mew mew mew <<<<
                        Sb.doSparks = _TRUE: SubFlags(8) = _TRUE: boomInfo.num = 6
                        boomInfo.r = 255: boomInfo.g = 168: boomInfo.b = 6 '    do comet explosion only
                    End If
                    comet(w).alive = _FALSE
                    _SndPlay S(Int(Rnd * 3 + 4))
                    If Ship.shields > 14 Then
                        Flag.doCircle = _TRUE '              show shield
                        Sb.trackShields = _TRUE: SubFlags(11) = _TRUE
                    End If

                    If Ship.shields <= 0 Then '
                        Ship.shields = 0 '                  prevent gauge from showing -1 on shields
                        Flag.doCircle = _FALSE
                        Sb.trackShields = _FALSE: SubFlags(11) = _FALSE
                        Sb.checkCometCollisions = _FALSE: SubFlags(10) = _FALSE
                        If Not Flag.boomInProgress Then ShipBoom: Ship.power = 5: Ship.shields = 5 ' adding power prevents double shipBooms
                        Game.score = Game.score - (100 * Game.diff_mult)
                    End If
                End If
            End If
        End If
    Loop Until w = UBound(comet)
End Sub
' -----------------------------------------
Sub CheckShipGRIDCollision () '

    Shared As rect cBox, wBox
    Shared As gridRock matrix()
    Dim As Integer row, column

    row = 0
    Do
        row = row + 1
        column = 0
        Do
            column = column + 1
            If matrix(column, row).alive Then
                cBox.x1 = Ship.x - Ship.radius '        calculate rectangular coordinates
                cBox.y1 = Ship.y - Ship.radius '        for rock c and rock w
                cBox.x2 = Ship.x + Ship.radius '
                cBox.y2 = Ship.y + Ship.radius
                wBox.x1 = matrix(column, row).x - 10 '  the radius of the tiny rocks
                wBox.y1 = matrix(column, row).y - 10
                wBox.x2 = matrix(column, row).x + 10
                wBox.y2 = matrix(column, row).y + 10

                If RectCollide(cBox, wBox) Then '                                           rectangular collision?
                    If CircCollide4(Ship, matrix(column, row)) Then '                       circle collision?
                        If matrix(column, row).col <> _RGB32(215, 165, 89, 110) Then '      if not bonus rocks then
                            Game.score = Game.score - (15 * Game.diff_mult)
                            Ship.shields = Ship.shields - 2.7
                            Ship.power = Ship.power - .7

                            If Ship.shields <= 0 Then '
                                Ship.shields = 0
                                Flag.doCircle = _FALSE
                                Sb.trackShields = _FALSE: SubFlags(11) = _FALSE
                                Sb.checkGridCollisions = _FALSE: SubFlags(6) = _FALSE
                                If Not Flag.boomInProgress Then ShipBoom: Ship.power = 5: Ship.shields = 5 '    <<<< NEW IF
                                Circle (Ship.x, Ship.y - 1), 18, C(0) '
                                Game.score = Game.score - (100 * Game.diff_mult)
                            End If

                            If Not Flag.boomInProgress Then ' new new new <<<< trying to get green pixels every time for ship explosions <<<<
                                Sb.doSparks = _TRUE: SubFlags(8) = _TRUE '        exploding gridrock
                                boomInfo.num = 7: boomInfo.r = 160 '            color of sparks
                                boomInfo.g = 160: boomInfo.b = 160 '
                            End If
                            _SndPlay S(Int(Rnd * 3 + 4)) '                      one of 3 boom sounds

                            If Ship.shields > 14 Then '       gauges turn off when moonscape rolls in, no more shields circle artifacts
                                Flag.doCircle = _TRUE '                          show shield
                                Sb.trackShields = _TRUE: SubFlags(11) = _TRUE
                            End If
                        Else '                                                  if bonus rocks then
                            _SndPlayCopy S(18), .15
                            If Ship.shields < 97 Then
                                Ship.shields = Ship.shields + 1.9 '
                                Game.score = Game.score + (50 * Game.diff_mult)
                                If Ship.power < 98 Then Ship.power = Ship.power + 1
                            Else If Ship.power < 97 Then Ship.power = Ship.power + 1.2 '
                            End If
                            Flag.doCircle = _FALSE
                        End If
                        matrix(column, row).alive = _FALSE
                        Sb.trackShields = _TRUE: SubFlags(11) = _TRUE
                    End If
                End If
            End If
        Loop Until column = 20
    Loop Until row = 11
End Sub
' -----------------------------------------
Sub InitCOMETS () '                         use the comets array for showers too

    Dim As Integer c
    Shared As comet comet()
    Shared rockType() As String
    Shared As Integer maxComets

    c = 0
    Do '
        c = c + 1 '
        If Game.round < 2 Then '
            comet(c).Vx = Rnd + 3 '
            comet(c).x = Int(Rnd * -750 - 30)
        Else
            comet(c).Vx = Rnd - 4 '
            comet(c).x = Int(Rnd * 750 + _Width) '
        End If
        comet(c).Vy = (Rnd * Sgn(Rnd - Rnd)) '
        comet(c).y = Int(Rnd * 680 + 35)
        comet(c).kind = rockType(1)
        comet(c).rotAng = Int(Rnd * 359 + 1)
        comet(c).rotSign = -1
        comet(c).radius = 9 ' was 10
        comet(c).rotSpeed = 7 + (Rnd * 9)
        comet(c).col = _RGB32(45, 32, 0)
        If c Mod 3 = 0 Then comet(c).col = _RGB32(82, 58, 0)
        comet(c).edge = _RGB32(218, 85, 6)
        comet(c).alive = _TRUE
    Loop Until c = maxComets '
End Sub
' -----------------------------------------
Sub RunCOMETS ()

    Dim As Integer c, d, spin, antiHeading, dist
    Dim As Integer xPointEnd, yPointEnd, xPointStart, yPointStart
    Dim As Double radians
    Dim As _Byte done
    Shared As comet comet()
    Shared As Long microMask
    Shared As Integer maxComets
    Static As _Byte cometRounds, initd

    If Control.clearStatics Then
        cometRounds = 0
        initd = _FALSE
        Exit Sub
    End If
    If Not initd Then FPS = 58: initd = _TRUE
    If Game.round > 1 Then Flag.shutFrontDoor = _TRUE
    c = 0
    Do
        c = c + 1
        If comet(c).alive Then '                                                        draw comets
            _PutImage (comet(c).x - 10, comet(c).y - 10), microMask
            PReset (comet(c).x, comet(c).y), comet(c).edge '                            outside of comet
            spin = Int(comet(c).rotAng)
            Draw "TA=" + VarPtr$(spin) + comet(c).kind
            PSet (comet(c).x, comet(c).y), _RGB32(0)
            If c Mod 2 = 0 Then Paint (comet(c).x + 1, comet(c).y + 1), comet(c).col, comet(c).edge ' only paint half cuz windows hates PAINT
            ' -----------------------------                                             opposite heading for flames
            antiHeading = (-Vec2Deg(comet(c).Vx, -comet(c).Vy)) '                       ** FLAME ZONE **     negative Vy here <<<<
            antiHeading = antiHeading + 90 '                                            adjust for QB64
            radians = _D2R(antiHeading)
            dist = Int(Rnd * 56 + 15) '                                                 distance for end of flames
            If c Mod 2 = 0 Then '                                                       half the comets have a tail
                xPointEnd = dist * Cos(radians) + comet(c).x
                yPointEnd = dist * Sin(radians) + comet(c).y
                xPointStart = 13 * Cos(radians) + comet(c).x '                          13 is dist from center of comet
                yPointStart = 13 * Sin(radians) + comet(c).y
                Line (xPointStart - 1, yPointStart)-(xPointEnd, yPointEnd), _RGB32(255, 0, 0) '         center flame line
                Line (xPointStart - 1, yPointStart - 2)-(xPointEnd, yPointEnd), comet(c).edge '         two V shaping lines
                Line (xPointStart - 1, yPointStart + 2)-(xPointEnd, yPointEnd), _RGB32(255, 194, 94)
            End If
            xPointStart = 7 * Cos(radians) + comet(c).x '                               side flames
            yPointStart = 7 * Sin(radians) + comet(c).y '                               rework points for side flames
            xPointEnd = (dist / 2.2) * Cos(radians) + comet(c).x
            yPointEnd = (dist / 2.2) * Sin(radians) + comet(c).y
            d = Int(Rnd * 3 + 1)
            If d = 1 Then
                Line (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 210, 102) ' outer flame lines
            Else Line (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 150, 132)
                If d = 2 Then
                    Line (xPointStart, yPointStart - 6)-(xPointEnd, yPointEnd - 6), _RGB32(255, 210, 102)
                    Line (xPointStart, yPointStart + 6)-(xPointEnd, yPointEnd + 6), _RGB32(255, 180, 142)
                End If
            End If
            Line (xPointStart, yPointStart + 8)-(xPointEnd, yPointEnd + 8), _RGB32(255, 132, 98)
        End If
    Loop Until c = maxComets '

    c = 0
    Do '                                        move comets
        c = c + 1
        comet(c).x = comet(c).x + comet(c).Vx
        comet(c).y = comet(c).y + comet(c).Vy
        comet(c).rotAng = comet(c).rotAng + comet(c).rotSpeed * comet(c).rotSign
        '   rules for comet runs
        If Game.round = 1 Then
            If comet(c).x > _Width + 50 Then comet(c).alive = _FALSE '
        Else
            If comet(c).x < -50 Then comet(c).alive = _FALSE '
        End If
        If comet(c).y > _Height + 40 _OrElse comet(c).y < -30 Then comet(c).alive = _FALSE
    Loop Until c = UBound(comet)

    done = _TRUE '                               assume done
    c = 0
    Do
        c = c + 1
        If comet(c).alive Then done = _FALSE '   check for done
    Loop Until c = UBound(comet)

    If done Then
        cometRounds = cometRounds + 1
        If cometRounds < 3 Then FPS = FPS + 4 '
        InitCOMETS '
        If (Game.round = 1 _AndAlso cometRounds = 3) _OrElse (Game.round > 1 _AndAlso cometRounds = 2) Then '  get out
            Sb.doComets = _FALSE: SubFlags(9) = _FALSE
            Flag.shutBackDoor = _FALSE
            InitShowers
            Sb.doShowers = _TRUE: SubFlags(20) = _TRUE '                      meteor shower
            cometRounds = 0
            initd = _FALSE
            If Game.round = 1 Then _SndPlay VO(11) Else _SndPlay VO(43) '   incoming rocks or diamond VO
            Time.grid = Timer '                                             track delay till running grid
        End If
    End If
End Sub
' -----------------------------------------
Sub InitGRID ()

    Dim As _Byte row, column
    Dim As Integer rand, rand2
    Shared matrix() As gridRock

    row = 0 '                                                       initialize matrix
    Do
        row = row + 1
        column = 0
        Do
            column = column + 1
            matrix(column, row).x = column * -80 - 80 ' was 65      X spacing
            If column Mod 2 = 0 Then
                matrix(column, row).y = (30 + 69 * row) - 85 '      even Y num columns staggered
            Else matrix(column, row).y = (65 * row) '               odd Y spacing
            End If

            If Game.round = 1 Then
                matrix(column, row).speed = 1
            Else matrix(column, row).speed = 1.25 '                 speed up grid for round 2 - if this sub is used again...
            End If
            matrix(column, row).rotAng = Int(Rnd * 358 + 1) '       initial rotation
            rand = Int(Rnd * 4 + 1): rand2 = Int(Rnd * 42 + 1) '
            If rand2 Mod 6 = 0 _AndAlso row <> 1 _AndAlso row <> 11 Then matrix(column, row).special = _TRUE '  speeders - No speeders offscreen
            If rand2 Mod 2 = 0 Then
                matrix(column, row).col = _RGB32(Rnd * 36 + 18) '   fill color / light grays
            Else matrix(column, row).col = _RGB32(0)
            End If

            If rand2 = 22 _OrElse rand2 = 16 Then '                                                  arbitrary rnds, 1 outa 21 odds
                If matrix(column, row).y > 20 _AndAlso matrix(column, row).y < _Height - 100 Then '  no goldies too close to top/bot edges
                    matrix(column, row).col = _RGB32(215, 165, 89, 110) '                       bonus orangy rocks <<
                End If
            End If

            matrix(column, row).alive = _TRUE '                      all rocks start alive
            Select Case rand '                                      half the rocks spin
                Case 1: matrix(column, row).rotSign = 1 '           some clockwise, some counter
                Case 2: matrix(column, row).rotSign = -1
                Case 3: matrix(column, row).rotSign = 0: matrix(column, row).yJiggle = -1 '     25% jiggle vertically
                Case 4: matrix(column, row).rotSign = 0
            End Select
            Select Case column
                Case 1: matrix(column, row).x = column * Int(Rnd * -120 + 40) - 80 '            spread out first couple / last couple columns
                Case 2: matrix(column, row).x = column * -80 + Int(Rnd * -90 + 65) - 80
                Case 19: matrix(column, row).x = column * -80 + Int(Rnd * -90) - 80
                Case 20: matrix(column, row).x = 20 * -80 + Int(Rnd * -120) - 80
            End Select
        Loop Until column = 20
    Loop Until row = 11
    matrix(20, 1).special = _FALSE '             this rock is used to track the end of the grid and can't be a speeder
End Sub
' -----------------------------------------
Sub RunGRID ()

    Shared As Long microMask
    Shared As gridRock matrix()
    Shared As String rockType()
    Dim As _Byte row, column, doneGrid
    Dim As Integer spin
    Static As _Byte worthPlayed
    Static As Single count, up, killSub

    If Control.clearStatics Then
        count = 0
        up = 0
        killSub = _FALSE
        Exit Sub
    End If
    Flag.shutFrontDoor = _FALSE '                    insurance
    '                                           ** MATRIX LOOPS **
    row = 0 '
    Do
        row = row + 1 '                             draw matrix
        column = 0
        Do
            column = column + 1
            If matrix(column, row).alive Then
                spin = matrix(column, row).rotAng

                _PutImage (matrix(column, row).x - 10, matrix(column, row).y - 10), microMask '      block the background stars
                PReset (matrix(column, row).x, matrix(column, row).y), _RGB32(130) '
                Draw "TA=" + VarPtr$(spin) + rockType(1)
                If matrix(column, row).col = _RGB32(215, 165, 89, 110) _OrElse matrix(column, row).col <> _RGB32(0) Then '       only paint speeders and non-black gridrocks
                    Paint (matrix(column, row).x + 1, matrix(column, row).y + 1), matrix(column, row).col, _RGB32(130) '    painting all slows performance big time
                End If
                PSet (matrix(column, row).x, matrix(column, row).y), _RGB32(0) '    kill middle pixel
            End If
        Loop Until column = 20
    Loop Until row = 11

    row = 0 '                                                                       move matrix
    Do
        row = row + 1
        column = 0
        Do
            column = column + 1
            If matrix(column, row).alive Then
                If Int(Rnd * 3 + 1) = 2 Then
                    matrix(column, row).x = matrix(column, row).x + matrix(column, row).speed + (Rnd - Rnd) '           wiggly X
                Else matrix(column, row).x = matrix(column, row).x + matrix(column, row).speed '
                End If
                If matrix(column, row).special Then matrix(column, row).x = matrix(column, row).x + .31 '               speeders
                If matrix(column, row).yJiggle Then matrix(column, row).y = matrix(column, row).y + (Rnd - Rnd) '       wiggly Y
                matrix(column, row).rotAng = matrix(column, row).rotAng + (Rnd * 2 + 1) * matrix(column, row).rotSign ' spin the rocks
                If matrix(column, row).x > _Width + 30 Then matrix(column, row).alive = _FALSE '     assign as dead when offscreen - ONE WAY ONLY CHECK <<<<
            End If
        Loop Until column = 20
    Loop Until row = 11
    ' ------------------                                        ** MOONSCAPE CONTROL **
    If matrix(20, 1).x > 2 Then '                               move moonScape to the right onto screen
        If count < 1281 Then
            count = count + 2.1
            _PutImage (-1280 + count, 633), MoonScape '         start it lower then move it up when done sliding over
            If Ship.y > 637 - up Then Ship.y = 637 - up '       keep ship above moonscape - ** SHIP CONTROLS ** <<<<
            If Ship.y < 10 Then Ship.y = 10 '                   keep ship below outer-space as warning to user
        End If
        If count > 600 _AndAlso count < 604 Then PrioritizeVO 9 '    gravity warning
        If (count > 1000 _AndAlso count < 1004) _AndAlso Ship.y > 440 Then _SndPlay VO(44) '
        If count >= 1280 _AndAlso up < 104 Then '   '
            up = up + 1: count = 1280 '                         new - count = 1280 - was jerking into place @ end <<<<
            _PutImage (1280 - count, 633 - up), MoonScape '     move moonscape up into position
            If Ship.y > 637 - up Then Ship.y = 637 - up '       keep ship above moonscape
            If Ship.y < 10 Then Ship.y = 10 '                   keep ship below outer-space as warning to user
        End If
        If up = 11 Then PrioritizeVO 10 '                       switching to landing mode
        If up = 52 Then _SndPlay S(40) '                        new timing <<<< gravity warning sound
        If up >= 101 Then '                                     if moonscape set then kill it
            Flag.showMoonScape = _TRUE
            Flag.landingTime = _TRUE
            If Not Flag.speedUp _AndAlso Not Sb.doPopUp Then FPS = Game.landingSpeed '   user determined landing speed **
            killSub = _TRUE '
        End If
    End If
    ' -----------------
    If matrix(3, 1).x > 130 _AndAlso Not worthPlayed Then
        PrioritizeVO 7 '                                        played once only - worth
        worthPlayed = _TRUE '                                    asteroid worth $$ VO here
    End If
    ' -----------------                                         check for done
    If matrix(20, 1).x > 100 Then '
        doneGrid = _TRUE '                                       assume done
        row = 0 '
        Do
            row = row + 1
            column = 0
            Do
                column = column + 1
                If matrix(column, row).alive Then
                    If Ship.x < matrix(20, 1).x Then
                        matrix(column, row).speed = 2.1 '       speed up at end
                        If matrix(20, 1).x > _Width - 180 Then Sounds.fadeOutGrid = _TRUE ' kill grid loop here
                    End If
                    If matrix(column, row).alive Then doneGrid = _FALSE '        if one's alive then not done yet
                End If
            Loop Until column = 20
        Loop Until row = 11
        If doneGrid _AndAlso killSub Then
            Sb.doGrid = _FALSE: SubFlags(5) = _FALSE '
            killSub = _FALSE '                       reset this all on the way out
            count = 0: up = 0
            InitGRID '                              reset grid
            KillChecks '                            turn off various checks during landing time
        End If
    End If
End Sub
' -----------------------------------------
Sub InitShowers ()

    Dim As _Byte c
    Shared As comet comet()
    Shared As String rockType()
    Shared As Integer maxComets

    c = 0
    Do '                                            initialize showers, using the comets array
        c = c + 1
        comet(c).Vx = (Rnd * Sgn(Rnd - Rnd)) '
        comet(c).Vy = Rnd * 2.6 + 1.7 '
        comet(c).x = Int(Rnd * 1280) '
        comet(c).y = -Int(Rnd * 15 + 10) '  -10
        comet(c).kind = rockType(14) '              tenny-weenie
        comet(c).rotAng = Int(Rnd * 359 + 1)
        comet(c).rotSign = -1
        comet(c).rotSpeed = 7 + (Rnd * 9)
        comet(c).edge = _RGB32(218, 85, 6) '        outer color
        comet(c).alive = _TRUE
    Loop Until c = maxComets '
End Sub
' -----------------------------------------
Sub RunSHOWERS ()

    Dim As Integer c, d, spin, antiHeading, dist
    Dim As Integer xPointEnd, yPointEnd, xPointStart, yPointStart
    Dim As Double radians
    Dim As _Byte done
    Shared As comet comet()
    Shared As Integer maxComets
    Static As _Byte cometRounds

    If Control.clearStatics Then cometRounds = 0: Exit Sub
    c = 0
    Do '                                                            draw showers
        c = c + 1
        If comet(c).alive Then
            PReset (comet(c).x, comet(c).y), comet(c).edge
            spin = Int(comet(c).rotAng)
            Draw "TA=" + VarPtr$(spin) + comet(c).kind
            PSet (comet(c).x, comet(c).y), _RGB32(0)
            ' ------------------------------------------                                opposite heading for flames
            antiHeading = (Vec2Deg(-comet(c).Vx, -comet(c).Vy)) '  ** FLAME ZONE **     negative Vy AND Vx here
            antiHeading = antiHeading + 90 '                                            adjust for QB64
            radians = _D2R(antiHeading)
            dist = Int(Rnd * 36 + 12) '                                                 distance for end of flames
            If c Mod 2 = 0 Then '                                                       half the comets have a big tail
                xPointEnd = dist * Cos(radians) + comet(c).x
                yPointEnd = dist * Sin(radians) + comet(c).y
                xPointStart = 13 * Cos(radians) + comet(c).x '                                      13 is dist from center of comet
                yPointStart = 13 * Sin(radians) + comet(c).y
                Line (xPointStart - 1, yPointStart - 8)-(xPointEnd, yPointEnd), _RGB32(255, 0, 0) ' center flame line
                Line (xPointStart - 1, yPointStart - 2)-(xPointEnd, yPointEnd), comet(c).edge '     two V shaping lines
                Line (xPointStart - 1, yPointStart + 2)-(xPointEnd, yPointEnd), _RGB32(255, 194, 94)
            End If
            xPointStart = 7 * Cos(radians) + comet(c).x '                                           side flames
            yPointStart = 7 * Sin(radians) + comet(c).y '                                           rework points for side flames
            xPointEnd = (dist / 2.2) * Cos(radians) + comet(c).x
            yPointEnd = (dist / 2.2) * Sin(radians) + comet(c).y
            d = Int(Rnd * 3 + 1)
            If d = 1 Then
                Line (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 210, 102)
            Else Line (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 150, 132)
                If d = 2 Then
                    Line (xPointStart, yPointStart - 6)-(xPointEnd, yPointEnd - 6), _RGB32(255, 210, 102)
                    Line (xPointStart, yPointStart - 6)-(xPointEnd, yPointEnd + 6), _RGB32(255, 180, 142)
                End If
            End If
            Line (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 132, 98) '  outer flame lines
        End If
    Loop Until c = maxComets ' -----------------

    c = 0
    Do '                                            move mini comets
        c = c + 1
        comet(c).x = comet(c).x + comet(c).Vx
        comet(c).y = comet(c).y + comet(c).Vy
        comet(c).rotAng = comet(c).rotAng + comet(c).rotSpeed * comet(c).rotSign
        If comet(c).y > _Height + 20 Then '                                         defines dead mini-comets - off screen
            comet(c).alive = _FALSE '
            Sounds.fadeOutComs = _TRUE '
        End If
        If comet(c).y > _Height / 2 + 100 Then
            If Game.round = 1 Then
                Sb.doGrid = _TRUE: SubFlags(5) = _TRUE '
                Sb.checkGridCollisions = _TRUE: SubFlags(6) = _TRUE ' don't start the grid too early, it slows down gameplay with both subs running!
                If comet(c).y > _Height - 100 Then Sounds.fadeInGRID = _TRUE '
            End If
        End If
    Loop Until c = maxComets
    ' ----------------------------
    done = _TRUE '                                   assume done
    c = 0
    Do
        c = c + 1
        If comet(c).alive Then done = _FALSE '       check for done
    Loop Until c = UBound(comet)
    If done Then
        Sb.doShowers = _FALSE: SubFlags(20) = _FALSE
        Sb.checkCometCollisions = _FALSE: SubFlags(10) = _FALSE
        If Game.round > 1 Then Sb.doGauntlet = _TRUE: SubFlags(21) = _TRUE: Flag.harpooned = _FALSE '
    End If
End Sub
' -----------------------------------------
Sub FlyBy ()

    Static As Integer flyX, flyY, rand, rand2 '
    Static As _Byte initd
    Static As Single adder, rotAng
    Static As _Unsigned Long shipCol
    Shared As String shipType()

    If Control.clearStatics Then initd = _FALSE: Exit Sub
    If Not initd Then
        rand = Int(Rnd * 2 + 1) '               50/50 right/left
        rand2 = Int(Rnd * 2 + 1)
        flyY = Int(Rnd * 230 + 30) '            start em a little lower
        initd = _TRUE
        If rand2 = 1 Then shipCol = C(3) Else shipCol = C(10)
        If rand = 1 Then '                      leftward
            rotAng = Int(Rnd * 42 + 35)
            adder = -3
            flyX = _Width + 10
        Else
            rotAng = Int(Rnd * -42 - 35) '      rightward
            adder = 3.1
            flyX = -10
        End If
    End If
    If rand = 1 Then
        rotAng = rotAng - .095 '
    Else rotAng = rotAng + .095
    End If

    flyX = flyX + adder
    flyY = flyY + (Rnd - Rnd) * .7
    If rotAng < 42 _AndAlso rotAng > -42 Then '
        flyY = flyY - 1
        If rand = 1 Then
            adder = -2.4
        Else adder = 2.4
        End If
    End If
    PSet (flyX, flyY), C(14)
    Draw "TA=" + VarPtr$(rotAng) + shipType(2)
    Paint (flyX, flyY - 1), shipCol, C(14)
    If flyX > _Width + 10 _OrElse flyX < -10 Then
        Sb.doFlyBy = _FALSE: SubFlags(14) = _FALSE
        initd = _FALSE
    End If

    If flyX >= Ship.x - 10 _AndAlso flyX <= Ship.x + 10 Then '   ** BOOM CHECK ** flyby ship collision with main ship?
        If flyY >= Ship.y - 10 _AndAlso flyY <= Ship.y + 10 Then
            ShipBoom
        End If
    End If
End Sub
' -----------------------------------------
Sub SoundCenter () '

    Shared As _Byte delayVO '
    Shared As Long timer3, warnSnd

    If Timer - Time.gameStart < 1 Then _SndVol S(28), .0005: Resetter(6) = _FALSE '                       NEW, don't restart harvestLoop loud
    If Flag.landingTime _AndAlso _SndPlaying(S(17)) Then _SndStop S(17) '                                     if top-last grid rock is blown up and grid loop never stops...
    ' self-terminating sound events    SndFade2 = snd, changeAmnt, goal, presVol, resetter(#) to kill
    If Not Resetter(5) _AndAlso Sb.doRocks Then _SndLoop S(28): Resetter(5) = _TRUE '                          loop harvest background
    If Not Resetter(6) _AndAlso Sb.doRocks Then SndFade2 S(28), .0003, .054, .001, 6 '                        turn up harvest loop
    If Not Resetter(7) _AndAlso Sb.doComets Then SndFade2 S(28), -.009, 0, .052, 7 '                          turn off harvest loop
    If Not Resetter(8) _AndAlso Sb.doComets Then _SndLoop S(29): Resetter(8) = _TRUE '                         loop comet background
    If Not Resetter(9) _AndAlso Sb.doComets Then SndFade1 S(29), .004, .35, 0, 9 '                            turn up comet loop
    If Not Resetter(10) _AndAlso (Sb.doGrid _OrElse Sb.doGauntlet) Then SndFade2 S(29), -.006, 0, .4, 10 '         turn off cl
    If Not Resetter(11) _AndAlso Flag.landingTime Then _SndLoop S(30): Resetter(11) = _TRUE '                  loop landing background
    If Not Resetter(12) _AndAlso Flag.landingTime Then SndFade1 S(30), .0001, .008, 0, 12 '                   turn up landing loop
    If Not Resetter(13) _AndAlso Sb.go2Space Then SndFade2 S(30), -.00011, 0, .009, 13 '                      turn off landing loop
    If Not Resetter(14) _AndAlso Sb.doFF Then SndFade2 S(31), -.003, 0, .05, 14 '                             turn off saucer loop
    If Not Resetter(15) _AndAlso Flag.landingTime Then _SndPlay VO(26): Resetter(15) = _TRUE: PrioritizeVO 26 'land with rock, KILL OTHER VOs

    If Timer - Time.gameStart > 1 _AndAlso Timer - Time.gameStart < 1.1 Then
        If Not OneTimeSnd(3) Then '
            _SndPlay VO(3) '                    "auto-Shields ON" in beginning
            OneTimeSnd(3) = _TRUE
        End If
    End If
    If Timer - Time.gameStart > 4 _AndAlso Timer - Time.gameStart < 4.1 Then
        If Not OneTimeSnd(4) Then '
            If Not IsVOPlaying Then '           "scanning target" VO can overlap this w/o VOcheck...
                _SndPlay VO(27) '               "first scan rock"
                OneTimeSnd(4) = _TRUE
            Else Timer(timer3) On
                delayVO = 27
                OneTimeSnd(4) = _TRUE '
            End If
        End If
    End If '
    ' ***********************************
    If Not Resetter(25) _AndAlso Ship.charged Then SndFade1 S(21), -.007, 0, .45, 25 '
    If Not Resetter(2) _AndAlso Flag.harpooned _AndAlso Not Sb.doPopUp Then '                                     added popUp protection
        Time.comets = Timer '                                                                        ** TRANSITION TO COMETS **
        Resetter(2) = _TRUE
        If _SndPlaying(VO(5)) Then _SndStop VO(5) '                                                     howToCapture
        _SndPlay (VO(8)) '                                                                              nice job and WARNING
        warnSnd = Timer
        Flag.warn = _TRUE
    End If
    If Not Control.endIt _AndAlso Flag.warn _AndAlso Timer - warnSnd > 4 Then _SndPlay S(16): Flag.warn = _FALSE ' warning beeper
    If _SndPlaying(S(16)) _AndAlso Not Control.endIt Then
        _SndLoop S(15) '                                                                                start comet sound low
        Sounds.fadeInComs = _TRUE '
    End If '                               ' was 7 secs below    -
    IF NOT Resetter(1) _ANDALSO TIMER - time.comets > 5 _ANDALSO flag.harpooned_
     _ANDALSO NOT sb.doRocks _ANDALSO NOT sb.doPopUp THEN '                                                    ** ACTIVATE COMETS **
        Sb.doComets = _TRUE: SubFlags(9) = _TRUE '                                                        release the hounds
        Sb.checkCometCollisions = _TRUE: SubFlags(10) = _TRUE
        Resetter(1) = _TRUE
    End If '
    If Not Resetter(18) _AndAlso Sounds.fadeInComs _AndAlso Not Control.endIt Then SndFade2 S(15), .002, .32, .001, 18 ' sound, changeAmnt, goal, presVol, resetter #
    If Not Resetter(21) _AndAlso Sounds.fadeOutComs Then SndFade2 S(15), -.0015, 0, .32, 21 '
    If Not Resetter(0) _AndAlso Sb.doGrid Then _SndLoop S(17): Resetter(0) = _TRUE '
    If Not Resetter(4) _AndAlso Sounds.fadeInGRID Then SndFade1 S(17), .001, .035, .01, 4 '
    If Not Resetter(3) _AndAlso Sounds.fadeOutGrid Then SndFade2 S(17), -.001, 0, .04, 3 '
    If Not OneTimeSnd(0) _AndAlso Flag.doPractice Then _SndPlay VO(34): OneTimeSnd(0) = _TRUE
End Sub
' -----------------------------------------
Sub SndFade1 (snd As Long, amount As Single, goal As Single, presVol As Single, a As _Byte)

    Static As _Byte loaded '
    Static As Single volume

    If Not loaded Then volume = presVol: loaded = _TRUE
    volume = volume + amount
    _SndVol snd, volume

    If Sgn(amount) = 1 _AndAlso volume >= goal Then '            if fade in
        Resetter(a) = _TRUE
        If Not Control.endIt Then loaded = _FALSE
    End If
    If Sgn(amount) = -1 _AndAlso volume <= 0.001 Then '          if fade out
        Resetter(a) = _TRUE
        loaded = _FALSE
        _SndStop snd
    End If
End Sub
' -----------------------------------------
Sub SndFade2 (snd As Long, amount As Single, goal As Single, presVol As Single, a As _Byte) '

    Static As _Byte loaded '
    Static As Single volume

    If Not loaded Then volume = presVol: loaded = _TRUE
    volume = volume + amount
    _SndVol snd, volume

    If Sgn(amount) = 1 _AndAlso volume >= goal Then '            if fade in
        Resetter(a) = _TRUE
        If Not Control.endIt Then loaded = _FALSE
    End If
    If Sgn(amount) = -1 _AndAlso volume <= 0.001 Then '          if fade out
        Resetter(a) = _TRUE
        loaded = _FALSE
        _SndStop snd
    End If
End Sub
' -----------------------------------------
Sub DrawStars () '                          starscape backdrops
    Dim As Integer c, d, v, w, x, y, z '
    Dim As Long virtual
    Shared As Long starScape, saucerScape, starScape2
    Data 3000,2000,16,46,330,5400,2500,30,100,500: '     num loops
    d = 0
    Do: d = d + 1
        Select Case d
            Case 1: virtual = _NewImage(1280, 720, 32)
                Read v, w, x, y, z
            Case 2: virtual = _NewImage(1280, 720, 32)
            Case 3: virtual = _NewImage(1600, 900, 32) '
                Read v, w, x, y, z
        End Select

        _Dest virtual
        c = 0: Do: c = c + 1 '
            PSet ((Int(Rnd * _Width)), Int(Rnd * _Height)), C(15) '                     whites
        Loop Until c = v
        c = 0: Do: c = c + 1
            PSet ((Int(Rnd * _Width)), Int(Rnd * _Height)), C(1) '                      grays
        Loop Until c = w
        c = 0: Do: c = c + 1
            PSet ((Int(Rnd * _Width)), Int(Rnd * _Height)), _RGB32(255, 67, 55, 124) '  reds
            Draw "S2U1R1D1L1"
        Loop Until c = x
        c = 0: Do: c = c + 1
            PSet ((Int(Rnd * _Width)), Int(Rnd * _Height)), _RGB32(0, 255, 0, 116) '    greens
            Draw "S2U1R1D1L1"
        Loop Until c = y
        c = 0: Do: c = c + 1
            PReset ((Int(Rnd * _Width)), Int(Rnd * _Height)), _RGB32(255, 255, 183, 120) '  big yellows
            Draw "S4U1R1D1L1"
        Loop Until c = z

        If d <> 3 Then
            _PutImage (Int(Rnd * 300 + 150), Int(Rnd * 450 + 100)), I(11) '             add heavenly bodies
            _PutImage (Int(Rnd * 300 + 900), Int(Rnd * 480 + 65)), I(12)
            _PutImage (Int(Rnd * 460 + 300), Int(Rnd * 450 + 140)), I(17)
        End If

        Select Case d '
            Case 1: starScape = _CopyImage(virtual, 32) '       software images
            Case 2: starScape2 = _CopyImage(virtual, 32) '
            Case 3: saucerScape = _CopyImage(virtual, 32) '
        End Select
        Cls '                                                   clear virtual screen
    Loop Until d = 3 '
    _Dest 0: _Font 16
    _FreeImage virtual
    Restore
End Sub
' -----------------------------------------
Sub DrawRocks () '                          spin and draw

    Dim As Integer c, spin
    Static As Single d
    Shared As Long miniMask

    If Control.clearStatics Then d = 0: Exit Sub
    c = 0
    Do
        c = c + 1
        If Flag.harpooned Then If c = Target Then _Continue '       drawing the target rock is done in shipControl sub

        If Flag.fadeInRocks Then '                                  fade in from dissolve sub
            If d < 171 Then d = d + .15
            If c <> Target Then
                rock(c).col = _RGB32(d)
            Else rock(c).col = _RGB32(205, 122, 255, d + 50)
            End If
            If d > 90 Then Flag.doRockMask = _TRUE
            If d > 169 Then Flag.fadeInRocks = _FALSE: d = 0 '       turn off, reset
        End If

        If rock(c).rotation Then
            If rock(c).rotDir = "cClock" Then rock(c).spinAngle = rock(c).spinAngle + rock(c).spinSpeed
        Else rock(c).spinAngle = rock(c).spinAngle - rock(c).spinSpeed
        End If
        If rock(c).spinAngle > 359 _OrElse rock(c).spinAngle < -359 Then rock(c).spinAngle = 0
        If Flag.doRockMask Then _PutImage (rock(c).x - rock(c).radius + 1, rock(c).y - rock(c).radius + 1), miniMask ' blocks the starscape from inside the rocks
        PReset (rock(c).x, rock(c).y), rock(c).col '
        spin = rock(c).spinAngle
        If rock(c).alive Then Draw "TA=" + VarPtr$(spin) + rock(c).kind '   only draw living rocks
        PSet (rock(c).x, rock(c).y), C(0) '                                 erase the center dot in rocks
    Loop Until c = MaxRocks
End Sub
' -----------------------------------------
Sub RockNav () '                            advance rocks and off-screen / on-screen controls

    Dim As Integer c

    Sb.doRocks = _FALSE: SubFlags(1) = _FALSE '                                           assume rocks are done
    c = 0
    Do
        c = c + 1
        If Flag.harpooned Then If c = Target Then _Continue
        rock(c).x = rock(c).x + rock(c).Vx * rock(c).speed '                            advance rocks
        rock(c).y = rock(c).y - rock(c).Vy * rock(c).speed '
        If Not Flag.harpooned Then
            If rock(c).x < -rock(c).radius * .7 Then rock(c).x = _Width + rock(c).radius * .7 - 1 ' on-screen / off-screen behavior
            If rock(c).x > _Width + rock(c).radius * .7 Then rock(c).x = -rock(c).radius * .7 + 1 '
            If rock(c).y < -rock(c).radius * .7 Then rock(c).y = _Height + rock(c).radius * .7 - 1 '
            If rock(c).y > _Height + rock(c).radius * .7 Then rock(c).y = -rock(c).radius * .7 + 1
        Else
            If rock(c).x < -rock(c).radius * .7 Then rock(c).alive = _FALSE '            on-screen / off-screen behavior AFTER HARPOONING
            If rock(c).x > _Width + rock(c).radius * .7 Then rock(c).alive = _FALSE '
            If rock(c).y < -rock(c).radius * .7 Then rock(c).alive = _FALSE '
            If rock(c).y > _Height + rock(c).radius * .7 Then rock(c).alive = _FALSE
        End If
        If rock(c).alive Then Sb.doRocks = _TRUE: SubFlags(1) = _TRUE '                   keep rocks going
        If Flag.harpooned Then rock(c).speed = 2.2 '                                    speed up other rocks after harpooning target
    Loop Until c = MaxRocks

    If Not Sb.doRocks Then '
        Sb.checkFSC = _FALSE: SubFlags(7) = _FALSE
    End If
End Sub
' -----------------------------------------
Sub Back2Space () '                         after rock drop & recharge
    Static As Integer d
    Shared As Long timer2

    If Control.clearStatics Then d = 0: Exit Sub
    d = d + 2
    _PutImage (rock(Target).x - 20, (rock(Target).y - 20) + d), I(0) ' keep rock image alive during back2space sub
    _PutImage (0, 533 + d), MoonScape '         move moonscape down
    If d > 180 Then '   delay this more to prevent shipboom post-charge @ top of screen     moonscape out of scene
        Flag.landingTime = _FALSE
        Flag.gotPastLanding = _TRUE
        rock(Target).stayPainted = _FALSE '
        Sb.go2Space = _FALSE: SubFlags(12) = _FALSE
        Flag.harpooned = _FALSE
        Ship.speed = 2.5
        Timer(timer2) On
        _SndPlay VO(19) '                       battleMode
        _SndStop S(30) '
        d = 0
    End If
End Sub
' -----------------------------------------
Function FindHypot% (circ1 As rock, circ2 As rock)
    Dim SideA% ' side A length of right triangle
    Dim SideB% ' side B length of right triangle
    SideA% = circ1.x - circ2.x '                                    calculate length of side A
    SideB% = circ1.y - circ2.y '                                    calculate length of side B
    FindHypot% = Int(Sqr(SideA% * SideA% + SideB% * SideB%)) '      calculate hypotenuse
End Function
' -----------------------------------------
Function Vec2Deg% (Vx As Single, Vy As Single) ' Turns vector pairs into negative degrees to work with program
    Vec2Deg% = -(360## + _R2D(_Atan2(Vx, Vy))) Mod 360## '   <<<< Steve McNeill's code <<<<
End Function '                                                   Thanx, Steve
' -----------------------------------------
Sub FlipOnShip '                            turn on ship after explosions
    Shared As Long timer1 '
    Shared As Sector sector()
    Shared As _Byte prezSector

    Sb.doShip = _TRUE: SubFlags(2) = _TRUE
    If Not Flag.doPractice Then TurnOnChecks '      added IF NOT...
    Flag.shipBoomDone = _FALSE '
    Flag.doAutoShields = _TRUE
    Ship.shields = 100
    Ship.power = 100: Ship.course = 0 '
    If Not Sb.doGauntlet Then Ship.x = CENTX: Ship.y = CENTY
    If Sb.doGauntlet Then
        Ship.x = 1000 + Int(Rnd * 250) '
        Ship.y = 550 + Int(Rnd * 60)
        prezSector = 1
        stopCheck = _FALSE
    End If
    Ship.speed = 0: Ship.Vx = 0: Ship.Vy = 0
    If Sb.doComets Then Ship.speed = 2
    If Sb.doGrid Then Ship.speed = 1
    If Flag.landingTime _AndAlso Not Sb.doFF Then Ship.y = 20
    Timer(timer1) Off
    Flag.boomInProgress = _FALSE '
End Sub
' -----------------------------------------
Sub FlipOnSaucers ()
    Shared As Long timer2
    Timer(timer2) Off
    Sb.doSaucers = _TRUE: SubFlags(16) = _TRUE
End Sub
' -----------------------------------------
Sub FlipOnBuyIn
    Shared As Long timer4
    Sb.doBuyIn = _TRUE
    Control.hold = _TRUE '                   hold game during buy ship offer
    Timer(timer4) Off
End Sub
' ----------------------------------------
Sub RedrawShip ()
    Dim spin As Integer
    spin = Ship.course
    PReset (Ship.x, Ship.y), Ship.col
    Draw "TA=" + VarPtr$(spin) + Ship.kind '
    Paint (Ship.x, Ship.y - 1), C(3), Ship.col
End Sub
' -----------------------------------------
Sub KillNoises () '                         after ship explodes, or other events, stop all thruster noises
    Shared played As _Byte
    If _SndPlaying(S(8)) _OrElse _SndPlaying(S(9)) _OrElse _SndPlaying(S(10)) _OrElse _SndPlaying(S(11)) Then
        _SndStop S(8): _SndStop S(9): _SndStop S(10): _SndStop S(11)
        played = _FALSE
    End If
End Sub
' -----------------------------------------
Sub KillChecks ()
    Sb.checkFSC = _FALSE: SubFlags(7) = _FALSE
    Sb.checkCometCollisions = _FALSE: SubFlags(10) = _FALSE
    Sb.checkGridCollisions = _FALSE: SubFlags(6) = _FALSE
End Sub
' -----------------------------------------
Sub TurnOnChecks ()
    If Sb.doRocks Then Sb.checkFSC = _TRUE: SubFlags(7) = _TRUE
    If Sb.doComets _OrElse Sb.doShowers Then Sb.checkCometCollisions = _TRUE: SubFlags(10) = _TRUE
    If Sb.doGrid Then Sb.checkGridCollisions = _TRUE: SubFlags(6) = _TRUE
End Sub
' -----------------------------------------
Sub AutoShields () '                        activated by sb.trackShields after a collision with autoShields turned ON
    Static As _Byte shieldCount
    shieldCount = shieldCount + 1
    If Flag.doCircle Then Circle (Ship.x, Ship.y - 1), 18, C(14)
    If shieldCount > 110 Then
        Sb.trackShields = _FALSE: SubFlags(11) = _FALSE
        shieldCount = 0
        Flag.doCircle = _FALSE '
    End If
End Sub
' -----------------------------------------
Sub BlowUp '                                tracks the sparks generation
    Shared As _Byte sparkCycles
    sparkCycles = sparkCycles + 1
    If sparkCycles < boomInfo.num Then MakeSparks Ship.x, Ship.y '
    UpdateSparks
End Sub
' -----------------------------------------
Sub ShowHorzGauge (x As Integer, y As Integer, amtDone As Single, gaugeLabel As String, col As _Unsigned Long) '

    Static As _Byte shieldDot, powerDot, toggle, toggle2, initd, initd2
    Static As Integer count, count2

    If Control.clearStatics Then initd = _FALSE: initd2 = _FALSE: Exit Sub
    Line (x, y)-(x + 100, y + 4), _RGB32(200, 200, 0), B '          yellow box
    Line (x + 50, y)-(x + 50, y - 5), C(14) '                       mid box line
    Line (x + 1, y + 1)-(x + 1 + (amtDone * 98), y + 3), col, BF '  filler color varies
    _Font Modern
    Color C(16)
    _PrintString (x + 50 - _PrintWidth(gaugeLabel) \ 2, y + 11), gaugeLabel

    If Not initd _AndAlso Ship.shields < 30 Then
        shieldDot = _TRUE
        toggle = 1
        initd = _TRUE
    End If
    If Not initd2 _AndAlso Ship.power < 30 Then
        powerDot = _TRUE
        toggle2 = 1
        initd2 = _TRUE
    End If
    If shieldDot Then
        count = count + 1
        If count Mod 100 = 0 Then toggle = -toggle
        If toggle = 1 Then
            Circle (135, 97), 5, C(12)
            Paint (135, 97), C(12), C(12)
        End If
        If Ship.shields > 29 Then
            shieldDot = _FALSE
            initd = _FALSE
            count = 0
        End If
    End If
    If powerDot Then
        count2 = count2 + 1
        If count2 Mod 100 = 0 Then toggle2 = -toggle2
        If toggle2 = 1 Then
            Circle (135, 65), 5, C(12)
            Paint (135, 65), C(12), C(12)
        End If
        If Ship.power > 29 Then
            powerDot = _FALSE
            initd2 = _FALSE
            count2 = 0
        End If
    End If '
    _Font 16
End Sub
' -----------------------------------------
Sub ShowVertGauge (locX As Integer, locY As Integer) '

    Static As _Byte initDone
    Static As Single startY, alphaDelta, yDelta
    Static As Integer botY, alpha '
    Dim As Single startPower
    Dim As Integer maxPower, duration, numSteps, alphaChange

    If Control.clearStatics Then initDone = _FALSE: Exit Sub

    If Not initDone Then
        botY = locY + 100 '                     physical screen location -  gauge height = 100
        startPower = Ship.power '               exisiting power level
        maxPower = 100 '                        ship's max allowable power
        alpha = 10 '                            beginning alpha level
        startY = botY - startPower '            start Y for moving line - top of red fill
        duration = maxPower - startPower '      total power change
        numSteps = duration / Ship.chargeDelta 'total cycles to full power
        alphaChange = 255 - alpha '             total alpha change
        alphaDelta = alphaChange / numSteps '   amount to change alpha level each cycle
        yDelta = duration / numSteps '          amount to change fill height
        initDone = _TRUE
    End If

    Circle (locX, locY), 6, _RGB32(205, 227, 122, alpha), _D2R(360), _D2R(180) '        top         YELLOW SHELL
    Circle (locX, botY), 6, _RGB32(205, 227, 122, alpha), _D2R(180), _D2R(0) '          bottom
    Line (locX - 6, locY)-(locX - 6, botY), _RGB32(205, 227, 122, alpha) '              sides
    Line (locX + 6, locY)-(locX + 6, botY), _RGB32(205, 227, 122, alpha)
    Circle (locX, locY), 5, _RGB32(2), _D2R(360), _D2R(180) '                           top         INVIZZO SHELL
    Circle (locX, botY), 5, _RGB32(2), _D2R(180), _D2R(0) '                             bottom
    Line (locX - 5, locY)-(locX - 5, botY), _RGB32(2) '                                 sides
    Line (locX + 5, locY)-(locX + 5, botY), _RGB32(2)
    startY = startY - yDelta '                                                          rising factor
    If alpha < 254 Then alpha = alpha + alphaDelta '                                    increase/decrease alpha
    Line (locX - 5, startY)-(locX + 5, startY), _RGB32(2) '                             moving line
    Paint (locX, botY - 3), _RGB32(255, 0, 0, alpha), _RGB32(2) '                       fill red

    If startY < locY - 20 Then '                                                        if done, then get this to run backwards to fade out
        alpha = 252
        alphaDelta = -alphaDelta * 2.7 '                                                fade out faster than fade in
        startY = startY + 200 '                                                         make startY well below "locY - 20" IF statement above
    End If

    If alpha < 10 Then ' was 10
        initDone = _FALSE '                                                              finish, reset for next charge
        Sb.doVertGauge = _FALSE
        Ship.charged = _TRUE '
        Resetter(25) = _FALSE '              << reset flag for recharge over, allows multiple charges / kills charge sound
    End If
End Sub
' -----------------------------------------
Sub QuickSound (c As Integer) '             how to play a sound inside a loop - isolate it
    Shared As _Byte played '
    If Not played Then _SndLoop S(c): played = _TRUE
End Sub
' -----------------------------------------
Sub Repel3 (b As _Byte, c As _Byte, w As _Byte) '   pushes the rocks apart - in theory
    Dim As _Byte count, g '
    Dim As Integer rockAngle
    count = 0
    Do
        count = count + 1
        If count = 1 Then g = b '
        If count = 2 Then g = c
        If count = 3 Then g = w
        rockAngle = Vec2Deg(rock(g).Vx, rock(g).Vy) '           get corrected course of rock
        rockAngle = rockAngle + 180 '                           give it opposite angle vector
        If rockAngle > 359 Then rockAngle = rockAngle - 360 '   correct the angle as needed
        rock(g).Vx = Cos(_D2R(rockAngle))
        rock(g).Vy = Sin(_D2R(rockAngle))
        rock(g).x = rock(g).x + rock(g).Vx * 3 '                bump the rock on its way
        rock(g).y = rock(g).y + rock(g).Vy * 3
    Loop Until count = 3
End Sub
' -----------------------------------------
Sub AssignRocks ()

    Dim Length As Single
    Dim As Integer c, rando
    Shared rockType() As String

    c = 0
    Do '
        c = c + 1
        rock(c).x = c * 60 '                                specific x locs to avoid bunching initially
        If c Mod 2 = 0 Then
            rock(c).y = c * 30 '                            y loc - ditto
        Else rock(c).y = c * 10
        End If
        rock(c).size = 2 '                                  all rocks big to start, 1 = small rock
        rock(c).alive = _TRUE '                              all rocks are alive!
        rock(c).radius = 22 '                               works well enough - sometimes they overlap, sometimes not quite touch...
        rock(c).col = C(15) '                               all rocks start white
        rock(c).speed = 1 '                                 use same rock speed for all or it looks wrong
        rock(c).rotDir = "clock" '                          first 6 rocks clockwise
        If c > 6 Then rock(c).rotDir = "cClock" '           next 6 counter-clockwise
        rock(c).spinAngle = 0 '                             zero spin angle at start
        rando = Int(Rnd * 2 + 1)
        If rando = 1 Then rock(c).rotation = _TRUE Else rock(c).rotation = _FALSE '   50/50 chance for rotation
        If rando = 2 Then rock(c).spinSpeed = 1 Else rock(c).spinSpeed = 2 '        50/50 chance fast/slow spin
        rock(c).Vx = (Int(Rnd * 5) + 1) * Sgn(Rnd - Rnd) '                          rnd vector (-5 to 5)
        rock(c).Vy = (Int(Rnd * 5) + 1) * Sgn(Rnd - Rnd) '
        Length = Sqr(rock(c).Vx * rock(c).Vx + rock(c).Vy * rock(c).Vy) '           length of vector
        rock(c).Vx = rock(c).Vx / Length '                                          normalize vector
        rock(c).Vy = rock(c).Vy / Length
        If c < 13 Then rock(c).kind = rockType(c + 1) Else rock(c).kind = rockType(Int(Rnd * 11 + 2)) '  random rock assignment - 10 different rocks
    Loop Until c = MaxRocks

    Target = Int(Rnd * MaxRocks + 1)
    If Not Flag.harpooned Then rock(Target).col = C(10) Else rock(Target).col = C(3) '
End Sub
' -----------------------------------------
Sub AssignMoves () '                        scripted saucer runs
    Shared As String moves() '                                                                                  leave space at beginning, always use entries of 3 chars!
    moves(1) = " c10 l10 c30 u20 d24 r20 d40 u42 c20 l10 c80 r30 u20 d30 l40 c10 r10 u48 c20 u20 c99 c99 c99" ' leave no space at the end!
    moves(2) = " c20 l16 c10 r20 c50 l30 c60 r30 c20 l30 c20 r90 u15 d25 u60 c99 c99 c99" '
    moves(3) = " c30 r08 c10 l16 c20 r30 d20 u20 c20 l20 d20 c30 u40 d20 c80 l50 r76 l40 u60 c99 c99 c99" '     u=up, d=down, l=left, r=right, c=coast (or any other unassigned char)
    moves(4) = " c40 d05 l05 c70 u10 r10 c50 d20 r20 l40 u20 c90 d25 c20 u40 c10 d10 l50 c99 c99 c99"
    moves(5) = " c55 l40 c50 r80 d10 c10 l30 r20 u30 d35 c60 u38 l70 c20 u20 c99 c99 c99"
    moves(6) = " c55 r20 c10 l50 c10 u15 c20 r30 d15 c70 d25 c08 u50 c10 d25 c20 u20 r40 d25 l40 r99 d20 c99 c99 c99"
    moves(7) = " c20 d05 c30 u12 c40 l60 c10 r70 l10 d07 c70 d35 c10 u60 c40 d25 l70 c99 c99 c99 c99"
    moves(8) = " c30 d20 u20 c10 l20 r40 c60 d25 c10 u20 r18 l76 d12 u18 c99 u45 c30 d35 c99 c99 c99"
    moves(9) = " c45 r10 c80 l20 c70 r20 c20 l45 c70 u25 r35 d25 c70 u40 l75 c99 c99 c99 c99" '
    moves(10) = " c25 l30 c60 r50 u30 d60 u30 c50 l40 c20 r40 l20 c60 u25 r08 l36 c10 d25 c10 r20 d40 r99 d20 c99 c99 c99" '
    moves(11) = " c10 r10 c10 l20 r10 c30 d15 u25 r08 l46 d35 u25 r38 c70 u70 c99 c99 c99"
    moves(12) = " c40 l01 u40 d80 u80 d80 u40 l30 r40 u40 d40 l10 c60 d10 l99 c99 c99 c99"
    moves(13) = " c30 r50 c25 l50 d20 l15 c10 u30 r15 l30 r30 l30 r30 d07 c60 u20 l30 r30 d80 c99 c99 c99"
    moves(14) = " c40 u10 c15 d10 c18 l15 c36 r40 c20 u10 l20 d20 c30 u30 d20 c20 l40 r35 c50 l80 d15 c99 c99 c99"
    moves(15) = " c55 r40 l40 c60 u30 d60 u30 c30 l15 r15 c20 u30 d30 l02 c60 d80 c99 c99 c99"
    moves(16) = " c50 l15 c10 r15 u30 r05 d60 c10 l10 u30 c20 l40 r40 r05 c60 r80 u35 c99 c99 c99"
    moves(17) = " c30 u20 l50 d20 r50 c30 d40 c20 u45 c20 r60 l60 d05 c55 l40 u60 r40 c99 c99 c99"
    moves(18) = " c30 r20 c10 l50 c10 u20 c20 r10 d20 r20 c70 u20 c10 d30 c20 u20 r40 d30 l40 u20 r60 d80 c99 c99"
End Sub
' -----------------------------------------
Sub AssignSaucers ()

    Shared As Integer shipNum, limit
    Shared moves() As String, saucer() As saucer
    Dim As Integer c, rand

    If Game.killRatio >= 75 Then shipNum = Int(Rnd * 3 + 6) Else shipNum = Int(Rnd * 5 + 4) '   set num of ships for attack run
    Select Case shipNum '                                                                       better shooting = more bad guys
        Case 4: limit = 72 '        frame rate adjustments for saucer quantity
        Case 5: limit = 71
        Case 6: limit = 70 '        I slowed these down a fair bit from a high of 76
        Case 7: limit = 69
        Case 8: limit = 68
        Case 9: limit = 67
    End Select
    c = 0
    Do
        c = c + 1
        rand = Int(Rnd * 18 + 1)
        saucer(c).commands = moves(rand)
        saucer(c).movesNum = rand
        saucer(c).loc.x = Int(Rnd * 400 + 1600 \ 2 - 200) '     fairly random start point near center
        saucer(c).loc.y = Int(Rnd * 300 + 900 \ 2 - 150) '
        CheckSaucerProx c '                                     check if same saucer patterns are too close to one another
        saucer(c).alive = _TRUE
        saucer(c).fillColor = C(12)
        saucer(c).aspect = .00001
        saucer(c).rotAngle = 0
        saucer(c).aspectSign = 1
        saucer(c).rotAngSign = 1
        saucer(c).speed = 1
        saucer(c).charCount = 0
        saucer(c).loopCounter = 0
        saucer(c).loopNum = 0
        saucer(c).action = ""
        saucer(c).shipRadius = 0
        saucer(c).getCommand = _TRUE
    Loop Until c = shipNum
End Sub
' -----------------------------------------
Sub LoadImages ()
    Dim c As Integer
    Dim col As _Unsigned Long

    I(0) = _LoadImage("Images/rock1.jpg")
    I(1) = _LoadImage("Images/gun1.jpg")
    I(2) = _LoadImage("Images/alien.jpg")
    I(3) = _LoadImage("Images/moonTruck.jpg")
    I(4) = _LoadImage("Images/mouseDemo.jpg") ' ------ intro images
    I(5) = _LoadImage("Images/keyDemo.jpg")
    I(6) = _LoadImage("Images/rocksDemo.jpg")
    I(7) = _LoadImage("Images/scanDemo.jpg")
    I(9) = _LoadImage("Images/chargeDemo.jpg")
    I(8) = _LoadImage("Images/landingDemo.jpg") ' -----------------
    I(10) = _LoadImage("Images/coolRocket.jpg")
    I(11) = _LoadImage("Images/galaxy1.jpg")
    I(12) = _LoadImage("Images/galaxy2.jpg")
    I(13) = _LoadImage("Images/aster2.jpeg")
    I(14) = _LoadImage("Images/aster4.jpeg")
    I(15) = _LoadImage("Images/aster1.jpeg")
    I(16) = _LoadImage("Images/aster3.jpeg")
    I(17) = _LoadImage("Images/quasar1.jpg")
    I(18) = _LoadImage("Images/saucer.jpeg")
    I(19) = _LoadImage("Images/oldSchool.jpg")
    I(20) = _LoadImage("Images/analogDials.jpg")
    I(21) = _LoadImage("Images/tubes.jpeg")
    I(22) = _LoadImage("Images/tapeRack.jpeg")
    I(23) = _LoadImage("Images/heavyMetal.jpg")
    I(24) = _LoadImage("Images/workStation.jpg")
    I(25) = _LoadImage("Images/servers.jpg")
    I(26) = _LoadImage("Images/gauntlet.jpg")
    I(27) = _LoadImage("Images/diamond.jpg")
    I(28) = _LoadImage("Images/diamond2.jpg")
    For c = 0 To UBound(I) '                    check for bad image handles
        If I(c) >= -1 Then '
            Beep: Cls: Print "Image File Error - on File #"; c '  terminate on error
            _Delay 3
            WrapUp: System
        End If
    Next
    For c = 0 To UBound(I) '                    make all image backgrounds transparent
        If c = 26 Then _Continue '              not ALL images - gauntlet has to be solid
        _Source I(c)
        col = Point(0, 0)
        _ClearColor col, I(c)
    Next c
End Sub
' -----------------------------------------
Sub LoadSounds ()
    Dim c As Integer
    S(0) = _SndOpen("Sounds/chirp.ogg")
    S(1) = _SndOpen("Sounds/epicThump.mp3"): _SndVol S(1), .7
    S(2) = _SndOpen("Sounds/click.ogg")
    S(3) = _SndOpen("Sounds/beeboop.ogg"): _SndVol S(3), .65
    S(4) = _SndOpen("Sounds/boom1.ogg"): _SndVol S(4), .5 'was .64
    S(5) = _SndOpen("Sounds/boom2.ogg"): _SndVol S(5), .24 ' .3
    S(6) = _SndOpen("Sounds/boom3.ogg"): _SndVol S(6), .24
    S(7) = _SndOpen("Sounds/deflect.ogg"): _SndVol S(7), .4
    S(8) = _SndOpen("Sounds/rocket.mp3"): _SndVol S(8), .1 '            MAIN THRUSTERS
    S(9) = _SndOpen("Sounds/quickBurst.mp3"): _SndVol S(9), .3 '
    S(10) = _SndOpen("Sounds/shortAir.mp3"): _SndVol S(10), .4 '        SIDE THRUSTERS
    S(11) = _SndOpen("Sounds/air.mp3"): _SndVol S(11), .13 '            OPEN SPACE THRUSTER SOUND
    S(12) = _SndOpen("Sounds/insectyShort.wav"): _SndVol S(12), .15
    S(13) = _SndOpen("Sounds/BBBB.mp3"): _SndVol S(13), .5
    S(14) = _SndOpen("Sounds/spaceHarpoon.mp3"): _SndVol S(14), .25
    S(15) = _SndOpen("Sounds/comets.mp3"): _SndVol S(15), .14 '
    S(16) = _SndOpen("Sounds/warning.mp3"): _SndVol S(16), .075
    S(17) = _SndOpen("Sounds/mysterio.wav"): _SndVol S(17), .01
    S(18) = _SndOpen("Sounds/bonus.mp3"): _SndVol S(18), .2
    S(19) = _SndOpen("Sounds/hydraulic.mp3"): _SndVol S(19), .23
    S(20) = _SndOpen("Sounds/zap.mp3"): _SndVol S(20), .25
    S(21) = _SndOpen("Sounds/charging.mp3"): _SndVol S(21), .25
    S(22) = _SndOpen("Sounds/fuzzyNoise.mp3"): _SndVol S(22), .25
    S(23) = _SndOpen("Sounds/heaven.mp3"): _SndVol S(23), .2
    S(24) = _SndOpen("Sounds/whip1.mp3"): _SndVol S(24), .2
    S(25) = _SndOpen("Sounds/zoom.mp3"): _SndVol S(25), .12
    S(26) = _SndOpen("Sounds/incoming.mp3"): _SndVol S(26), .4
    S(27) = _SndOpen("Sounds/laser.mp3"): _SndVol S(27), .3 '  ------------- loops
    S(28) = _SndOpen("Sounds/harvestLoop.mp3"): _SndVol S(28), .0005 ' was .001
    S(29) = _SndOpen("Sounds/cometLoop.ogg"): _SndVol S(29), .001
    S(30) = _SndOpen("Sounds/happy.mp3"): _SndVol S(30), 0
    S(31) = _SndOpen("Sounds/saucerLoop.mp3"): _SndVol S(31), .001
    S(32) = _SndOpen("Sounds/FFloop.mp3"): _SndVol S(32), .0034 ' ----------
    S(33) = _SndOpen("Sounds/flash.mp3"): _SndVol S(33), .25
    S(34) = _SndOpen("Sounds/ominous.mp3"): _SndVol S(34), .36
    S(35) = _SndOpen("Sounds/funkyAlarm2.mp3"): _SndVol S(35), .38
    S(36) = _SndOpen("Sounds/blast.mp3")
    S(37) = _SndOpen("Sounds/impact.mp3")
    S(38) = _SndOpen("Sounds/splashLoop.mp3"): _SndVol S(38), .25
    S(39) = _SndOpen("Sounds/controlRoom.mp3"): _SndVol S(39), .21
    S(40) = _SndOpen("Sounds/gravity.mp3"): _SndVol S(40), .11 '
    S(41) = _SndOpen("Sounds/erupt1.mp3")
    S(42) = _SndOpen("Sounds/erupt2.mp3")
    S(43) = _SndOpen("Sounds/erupt3.mp3")
    S(44) = _SndOpen("Sounds/erupt4.mp3")
    S(45) = _SndOpen("Sounds/erupt5.mp3")
    S(46) = _SndOpen("Sounds/ghostly.mp3"): _SndVol S(46), .001
    S(47) = _SndOpen("Sounds/cheers.mp3"): _SndVol S(47), .12
    S(48) = _SndOpen("sounds/fireworks.mp3"): _SndVol S(48), .16
    For c = 0 To UBound(S) '                                        check for bad sound handles
        If S(c) <= 0 Then '
            Beep: Cls: Print "Sound Load Error - on File #"; c '    terminate on error
            _Delay 3
            WrapUp: System
        End If
    Next
End Sub
' -----------------------------------------
Sub LoadVOs ()
    Dim c As Integer
    VO(1) = _SndOpen("VOs/scanning.mp3"): _SndVol VO(1), .15
    VO(2) = _SndOpen("VOs/doneScanning.mp3"): _SndVol VO(2), .15
    VO(3) = _SndOpen("VOs/shieldsOn.mp3"): _SndVol VO(3), .13 '
    VO(4) = _SndOpen("VOs/shieldsOff.mp3"): _SndVol VO(4), .15 '    unused
    VO(5) = _SndOpen("VOs/howToCapture.mp3"): _SndVol VO(5), .15
    VO(6) = _SndOpen("VOs/proceed.mp3"): _SndVol VO(6), .15 '       unused
    VO(7) = _SndOpen("VOs/worth.mp3"): _SndVol VO(7), .18
    VO(8) = _SndOpen("VOs/meteorites.mp3"): _SndVol VO(8), .18
    VO(9) = _SndOpen("VOs/gravityAhead.mp3"): _SndVol VO(9), .18
    VO(10) = _SndOpen("VOs/landingMode.mp3"): _SndVol VO(10), .18
    VO(11) = _SndOpen("VOs/rocks.mp3"): _SndVol VO(11), .22
    VO(12) = _SndOpen("VOs/detach.mp3"): _SndVol VO(12), .19
    VO(13) = _SndOpen("VOs/recharge.mp3"): _SndVol VO(13), .18
    VO(14) = _SndOpen("VOs/chargeDone.mp3"): _SndVol VO(14), .26
    VO(15) = _SndOpen("VOs/chargeAdvice.mp3"): _SndVol VO(15), .2
    VO(16) = _SndOpen("VOs/trapped.mp3"): _SndVol VO(16), .22
    VO(17) = _SndOpen("VOs/scanningUn.mp3"): _SndVol VO(17), .15
    VO(18) = _SndOpen("VOs/analysis.mp3"): _SndVol VO(18), .19
    VO(19) = _SndOpen("VOs/battleMode.mp3"): _SndVol VO(19), .18
    VO(20) = _SndOpen("VOs/unusual.mp3"): _SndVol VO(20), .3
    VO(21) = _SndOpen("VOs/leaving.mp3"): _SndVol VO(21), .16
    VO(22) = _SndOpen("VOs/remoteView.mp3"): _SndVol VO(22), .16
    VO(23) = _SndOpen("VOs/leaveOrbit.mp3"): _SndVol VO(23), .28
    VO(24) = _SndOpen("VOs/shieldsLow.mp3"): _SndVol VO(24), .19
    VO(25) = _SndOpen("VOs/lowPower.mp3"): _SndVol VO(25), .19 '
    VO(26) = _SndOpen("VOs/landWithRock.mp3"): _SndVol VO(26), .18
    VO(27) = _SndOpen("VOs/step1.mp3"): _SndVol VO(27), .18
    VO(28) = _SndOpen("VOs/remaining.mp3"): _SndVol VO(28), .2
    VO(29) = _SndOpen("VOs/SDestroyed.mp3"): _SndVol VO(29), .2
    VO(30) = _SndOpen("VOs/zero.mp3"): _SndVol VO(30), .2
    VO(31) = _SndOpen("VOs/one.mp3"): _SndVol VO(31), .2
    VO(32) = _SndOpen("VOs/two.mp3"): _SndVol VO(32), .2
    VO(33) = _SndOpen("VOs/rockAttached.mp3"): _SndVol VO(33), .2
    VO(34) = _SndOpen("VOs/endPractice.mp3"): _SndVol VO(34), .18
    VO(35) = _SndOpen("VOs/three.mp3"): _SndVol VO(35), .2
    VO(36) = _SndOpen("VOs/hint.mp3"): _SndVol VO(36), .25
    VO(37) = _SndOpen("VOs/targetAdvice.mp3"): _SndVol VO(37), .41 '
    VO(38) = _SndOpen("VOs/four.mp3"): _SndVol VO(38), .2 '
    VO(39) = _SndOpen("VOs/five.mp3"): _SndVol VO(39), .2 '
    VO(40) = _SndOpen("VOs/six.mp3"): _SndVol VO(40), .2 '
    VO(41) = _SndOpen("VOs/seven.mp3"): _SndVol VO(41), .2 '
    VO(42) = _SndOpen("VOs/eight.mp3"): _SndVol VO(42), .2 '
    VO(43) = _SndOpen("VOs/diamond.mp3"): _SndVol VO(43), .57 '      alert!
    VO(44) = _SndOpen("VOs/altWarn.mp3"): _SndVol VO(44), .24
    VO(45) = _SndOpen("VOs/exit.mp3"): _SndVol VO(45), .25
    VO(46) = _SndOpen("VOs/lava.mp3"): _SndVol VO(46), .2
    VO(47) = _SndOpen("VOs/nine.mp3"): _SndVol VO(47), .2
    For c = 1 To UBound(VO) '                                       check for bad VO handles
        If VO(c) <= 0 Then
            Beep: Cls: Print "Voice File Error - on File #"; c '    terminate on error
            _Delay 3
            WrapUp: System
        End If
    Next
End Sub
' -----------------------------------------
Sub LoadFonts ()
    Modern = _LoadFont("Fonts/futura.ttc", 10) '
    ModernBig = _LoadFont("Fonts/futura.ttc", 12)
    ModernBigger = _LoadFont("Fonts/futura.ttc", 15)
    Menlo = _LoadFont("Fonts/menlo.ttc", 15) ' was 16
    MenloBig = _LoadFont("Fonts/menlo.ttc", 22)
    '                                                           check for bad font handles
    If Modern <= 0 _OrElse ModernBig <= 0 _OrElse ModernBigger <= 0 _OrElse Menlo <= 0 _OrElse MenloBig <= 0 Then
        Beep: Cls: Print "Font Loading Error!" '                terminate on error
        _Delay 3
        WrapUp: System
    End If
End Sub
'------------------------------------------
Sub LoadShips ()
    Shared shipType() As String
    Shared C() As _Unsigned Long
    Shared shipImg As Long
    Dim temp As _Unsigned Long

    shipType(1) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BE11 BU3 BL1 C" + Str$(C(12)) + "U7" '          RETRO THRUSTERS
    shipType(2) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BR10 BD2 C" + Str$(C(12)) + "D7" '              forward thrust ship
    shipType(3) = "BU6 G5 F2 L3 G5 BE11 F4 G1 R2 F4 G3 L3 H3 G3 L3 H1 E1 D2 L5 BR11 BD2 D5" '   thrust damaged ship
    shipType(4) = "BU6 G11 BE11 F11 L8 H3 G3 L7" '                                              ship1
    shipType(5) = "BU6 BL7 G11 BR8 BE11 BR7 F11 BD11 BL8 L8 H3 G3 L7" '                         ship4
    shipType(6) = "BU6 BL4 G11 BR5 BE11 BR4 F11 BD7 BL5 L8 H3 G3 L7" '                          ship3
    shipType(7) = "BU6 BL2 G11 BR2 BE11 BR2 F11 BD3 BL2 L8 H3 G3 L7" '                          ship2
    shipType(8) = "BU6 G5 F2 L3 G5 BE11 F4 G1 R2 F4 G3 L3 H3 G3 L3 H1 E1 D2 L5 BR11" '          damaged ship
    shipType(9) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU11 BR6 C" + Str$(C(9)) + "L5" '               side jet left
    shipType(10) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU11 BR14 C" + Str$(C(9)) + "R5" '              "    "  right
    shipType(11) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU3 BL2 C" + Str$(C(11)) + "L7" '              side thruster left
    shipType(12) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU3 BR22 C" + Str$(C(11)) + "R7" '              "      "     right
    shipImg = _NewImage(40, 40, 32) '                                                           create one image of normal ship
    _Dest shipImg
    PReset (_Width / 2, _Height / 2), C(14) '
    Draw shipType(4)
    Paint (_Width / 2 + 1, _Height / 2 - 2), C(3), C(14) '
    PSet (_Width / 2, _Height / 2), C(3)
    _Source shipImg
    temp = Point(3, 3)
    _ClearColor temp, shipImg
    _Dest 0
    Ship.kind = shipType(4) '       initial ship assignments
    Ship.x = CENTX
    Ship.y = CENTY + 50
    Ship.course = 0 '
    Ship.col = C(14)
    Ship.radius = 8
End Sub
' -----------------------------------------
Sub LoadRocks ()
    Shared rockType() As String
    rockType(1) = "BU10 L5 G2 L1 D4 F1 D2 G2 D3 F4 R4 E1 F2 R2 E3 U5 R1 U7 H3 L5" '                 teeny
    rockType(2) = "BU18L4D2L2H3G2L1G2H1G2L2D3R1D4R1F1D2G2H1D2F3R2G2L2G3F3D3F4R3F2R3E2U1E1R2F5R4E5L1U4E3R1U3H2U1R5U5H2U3L1H1U1E1U1L3U4l1h2L1H2G3L2H1U1" ' Will rock!
    rockType(3) = "BU18 BL13 G6 D14 F4 D2 G4 D3 F6 R3 U2 R2 D1 R2 F3 R2 E3 R4 U1 R5 E7 R1 U12 L2 U3 R1 U3 H2 E2 U3 H5 L12 D2 L3 U1 L2 U1 L9"
    rockType(4) = "BU19 BL14 G6 D14 F4 D2 G4 D3 F6 R5 E2 R4 F2 R6 E6 D2 F5 E2 U7 R2 U6 H3 U4 E5 U6 H7 L12 D2 L8 U2 L8"
    rockType(5) = "BU17 BL20 D11 F6 G5 G4 F3 D9 R32 E8 U31 H7 L26 G7" '
    rockType(6) = "BU12 BL17 E4 R6 E6 R7 F15 R4 D6 G22 D4 L3 H6 L7 H7 U20 E4"
    rockType(7) = "BU22 R6 F17 R4 D6 D3 G17 L7 G6 L3 H9 U12 H13 U6 E6 R7 U2 R14 U1"
    rockType(8) = "BL9 BU14 E7 R7 U5 F12 L5 F13 D12 G7 L17 G11 H14 U12 E15 U2" '                    big rock
    rockType(9) = "BU14 R11 F10 R6 D11 L3 D5 G4 H7 G7 L7 G9 L4 H13 U9 E10 U4 E4 R14 D2" '           big rock 2
    rockType(10) = "BU4 BL22 BU7 E4 R8 E9 R7 F9 D9 F6 D6 G9 L4 D5 G4 L11 H5 U3 L8 U10 L2 U17" '
    rockType(11) = "BU17 BL20 D8 F8 G5 D2 G6 F6 R12 U6 F6 R10 E8 U5 H7 R5 E2 U7 H8 L20 G4 H4 G3"
    rockType(12) = "BU17 BL20 BD4 D8 F4 G6 F3 D9 F3 E4 F4 E6 F6 E3 F3 R3 E7 U4 E3 H4 U12 H7 G10 H9 L9 G3"
    rockType(13) = "BU17 BL20 BD7 D7 F6 G5 F6 L7 F6 R5 E3 R4 U2 F3 R3 F3 R4 E10 H5 E3 U9 E4 H8 L12 D2 L12 G6 L4"
    rockType(14) = "BU3 L3 G1 L1 D3 F1 D1 F2 R3 E2 R1 E2 U1 R1 U2 H3 L2 G3" '                       teeny tiny weeny
End Sub
' -----------------------------------------
Sub LoadColors () '
    Shared C() As _Unsigned Long
    C(0) = _RGB32(0) '                  black
    C(1) = _RGB32(90) '                 grey
    C(2) = _RGB32(147) '                light grey
    C(3) = _RGB32(0, 127, 0) '          dark green
    C(4) = _RGB32(0, 255, 0) '          green
    C(5) = _RGB32(0, 0, 150) '          blue
    C(6) = _RGB32(128, 183, 233) '      medium blue
    C(7) = _RGB32(105, 172, 222) '      pale blue
    C(8) = _RGB32(0, 133, 255) '        sky blue
    C(9) = _RGB32(255, 161, 72) '       orange
    C(10) = _RGB32(205, 122, 255) '     purple
    C(11) = _RGB32(255, 24, 50) '       red
    C(12) = _RGB32(255, 0, 0) '         bright red
    C(13) = _RGB32(255, 177, 255) '     pink
    C(14) = _RGB32(255, 255, 0) '       yellow
    C(15) = _RGB32(170) '               white
    C(16) = _RGB32(255) '               bright white
End Sub
' -----------------------------------------
Sub LoadMoonScape ()
    Dim As Long tempImg
    Dim As _Unsigned Long pix
    MoonScape = _NewImage(1281, 191, 32)
    tempImg = _LoadImage("Images/moonscape.jpg")
    _Source tempImg
    pix = Point(0, 0)
    _ClearColor pix, tempImg
    _PutImage , tempImg, MoonScape, (0, 530)-(1280, 720)
    _FreeImage tempImg
End Sub
' -----------------------------------------
Sub LoadViewScreen () '                     1600 x 900 HDWR view screen for saucerControl sub
    Dim c As Integer
    Dim temp As Long
    Dim As Integer wide, high
    wide = 1600: high = 900
    temp = _NewImage(wide, high, 32)
    _Dest temp
    Line (0, 0)-(wide - 1, high - 1), C(2), B '             outer border box
    Line (25, 25)-(wide - 25, high - 25), C(4), B '         inner border box
    Paint (2, 2), C(1), C(4) '                              fill in the view screen
    c = 0
    Do
        c = c + 1 '                                         rivets for Will! Black circles painted gray inside.
        Circle ((12 * (c * 4)) + 7, 12), 3, C(0) '          top
        Paint ((12 * (c * 4)) + 7, 12), C(2), C(0) '
        Circle (12, 9 * (c * 4)), 3, C(0) '                 left
        Paint (12, 9 * (c * 4)), C(2), C(0)
        Circle (wide - 13, 9 * (c * 4)), 3, C(0) '          right
        Paint (wide - 13, 9 * (c * 4)), C(2), C(0)
        Circle ((12 * (c * 4)) + 7, high - 12), 3, C(0) '   bot
        Paint ((12 * (c * 4)) + 7, high - 12), C(2), C(0) '
    Loop Until c = 32
    ViewScreen = _CopyImage(temp, 33) '      '              hardware image for sitting on top layer
    _Dest 0: _Font 16
    _FreeImage temp
End Sub
' -----------------------------------------
Sub MakeSparks (x As Integer, y As Integer) ' spark initiator <> Thanks Terry Ritchie for these routines
    '
    Shared spark() As spark '     dynamic array to hold sparks
    Shared sparkNum As Integer '  number of sparks to create at a time
    Shared sparkLife As Integer ' life span of spark in frames
    Dim CleanUp As Integer '      _TRUE is no life left in array
    Dim Count As Long '           spark counter
    Dim TopSpark As Long '        highest index in array
    Dim NewSpark As Long '        index in array to start adding new sparks

    CleanUp = _TRUE '                                          assume no life left in array
    Do '                                                      begin spark life check
        If spark(Count).Lifespan <> 0 Then '                  is this spark alive?
            CleanUp = _FALSE '                                 yes, array still has life
        End If
        Count = Count + 1 '                                   increment spark counter
    Loop Until Count > UBound(spark) _OrElse CleanUp = _FALSE '     leave when life found or end of array reached
    If CleanUp Then ReDim spark(0) As spark '                 if no life found then reset dynamic array
    TopSpark = UBound(spark) '                                identify array index starting point
    ReDim _Preserve spark(TopSpark + sparkNum + 1) As spark ' increase array while saving living sparks
    Count = 0 '                                               reset spark counter
    Randomize Timer '                                         seed RND generator
    Do '                                                      begin add spark loop
        Count = Count + 1 '                                   increment spark counter
        NewSpark = TopSpark + Count '                         next array index to use
        spark(NewSpark).Lifespan = sparkLife '                set spark life span
        spark(NewSpark).Location.x = x '                      set spark location
        spark(NewSpark).Location.y = y
        spark(NewSpark).Fade = 255 '                          set spark intensity
        spark(NewSpark).Velocity = Int(Rnd * 6) + 6 '         set random spark velocity
        spark(NewSpark).Vector.x = Rnd - Rnd '                set random spark vector
        spark(NewSpark).Vector.y = Rnd - Rnd
    Loop Until Count = sparkNum '                             leave when all sparks added
End Sub
'------------------------------------------
Sub UpdateSparks () '                       spark maintainer, by Terry Ritchie
    '                                       * Maintains any live sparks containied in the dynamic array
    Shared spark() As spark '               dynamic array to hold sparks
    Shared As _Byte sparkCycles
    Dim Count As Long '           spark counter
    Dim FC0 As _Unsigned Long '   spark fade colors
    Dim FC1 As _Unsigned Long
    Dim FC2 As _Unsigned Long
    Dim Fade0 As Integer '        spark fade color values
    Dim Fade1 As Integer
    Dim Fade2 As Integer
    Dim CleanUp As Integer '      _TRUE if no life left in array

    If UBound(spark) = 0 Then Exit Sub '                                          leave if array cleared
    CleanUp = _TRUE '                                                              assume no life left in array
    Do '                                                                          begin spark maintenance loop
        Count = Count + 1 '                                                       increment spark counter
        If spark(Count).Lifespan Then '                                           is this spark alive?
            CleanUp = _FALSE '                                                     yes, array still has life
            Fade0 = spark(Count).Fade '                                           set the intensity values
            Fade1 = spark(Count).Fade \ 2
            Fade2 = spark(Count).Fade \ 4
            FC0 = _RGB32(boomInfo.r, boomInfo.g, boomInfo.b, Fade0) '                               create the intensity colors
            FC1 = _RGB32(boomInfo.r, boomInfo.g, boomInfo.b, Fade1)
            FC2 = _RGB32(boomInfo.r, boomInfo.g, boomInfo.b, Fade2)
            PSet (spark(Count).Location.x, spark(Count).Location.y), FC0 '        create pixels with intensities
            PSet (spark(Count).Location.x + 1, spark(Count).Location.y), FC1
            PSet (spark(Count).Location.x - 1, spark(Count).Location.y), FC1
            PSet (spark(Count).Location.x, spark(Count).Location.y + 1), FC1
            PSet (spark(Count).Location.x, spark(Count).Location.y - 1), FC1
            PSet (spark(Count).Location.x + 1, spark(Count).Location.y + 1), FC2
            PSet (spark(Count).Location.x - 1, spark(Count).Location.y - 1), FC2
            PSet (spark(Count).Location.x - 1, spark(Count).Location.y + 1), FC2
            PSet (spark(Count).Location.x + 1, spark(Count).Location.y - 1), FC2
            spark(Count).Fade = spark(Count).Fade - 128 / spark(Count).Lifespan ' decrease spark intensity
            '* update spark location
            spark(Count).Location.x = spark(Count).Location.x + spark(Count).Vector.x * spark(Count).Velocity
            spark(Count).Location.y = spark(Count).Location.y + spark(Count).Vector.y * spark(Count).Velocity
            spark(Count).Velocity = spark(Count).Velocity * .9 '                  decrease spark velocity
            spark(Count).Lifespan = spark(Count).Lifespan - 1 '                   decrese spark life span
        End If
    Loop Until Count = UBound(spark) '                                            leave when last index reached
    If CleanUp Then '                                                             reset dynamic array if no life
        ReDim spark(0) As spark
        Sb.doSparks = _FALSE: SubFlags(8) = _FALSE
        sparkCycles = 0
    End If
End Sub
'------------------------------------------
Function CircCollide%% (Circ1 As rock, Circ2 As rock) '       Thanks, Terry Ritchie for these!
    '- Checks for the collision between two circular areas.     this is for rock to rock collisions
    Dim SideA% ' side A length of right triangle
    Dim SideB% ' side B length of right triangle
    Dim Hypot& ' hypotenuse squared length of right triangle (side C)
    CircCollide%% = 0 '                                     assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    If Hypot& <= (Circ1.radius + Circ2.radius) * (Circ1.radius + Circ2.radius) Then CircCollide = -1
End Function
' -----------------------------------------
Function CircCollide2%% (Circ1 As ship, Circ2 As rock) '      for ship to ROCK collisions
    Dim SideA% '
    Dim SideB% '
    Dim Hypot& '
    CircCollide2%% = 0 '                                      assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    If Hypot& <= (Circ1.radius + Circ2.radius) * (Circ1.radius + Circ2.radius) Then CircCollide2 = -1
End Function
' -----------------------------------------
Function CircCollide3%% (Circ1 As ship, Circ2 As comet) '      for ship to COMET collisions
    Dim SideA%
    Dim SideB%
    Dim Hypot&
    CircCollide3%% = 0 '                                      assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    If Hypot& <= (Circ1.radius + Circ2.radius) * (Circ1.radius + Circ2.radius) Then CircCollide3 = -1
End Function
' -----------------------------------------
Function CircCollide4%% (Circ1 As ship, Circ2 As gridRock) '      for ship to GRID collisions
    Dim SideA%
    Dim SideB%
    Dim Hypot&
    CircCollide4%% = 0 '                                      assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    If Hypot& <= (Circ1.radius + 10) * (Circ1.radius + 10) Then CircCollide4 = -1 '
End Function
' -----------------------------------------
Function RectCollide%% (Rect1 As rect, Rect2 As rect) '       Thanks, Terry Ritchie for this!
    '- Checks for the collision between two rectangular areas.
    RectCollide%% = 0 '                           assume no collision
    If Rect1.x2 >= Rect2.x1 Then '              rect 1 lower right X >= rect 2 upper left  X ?
        If Rect1.x1 <= Rect2.x2 Then '          rect 1 upper left  X <= rect 2 lower right X ?
            If Rect1.y2 >= Rect2.y1 Then '      rect 1 lower right Y >= rect 2 upper left  Y ?
                If Rect1.y1 <= Rect2.y2 Then '  rect 1 upper left  Y <= rect 2 lower right Y ?
                    RectCollide = -1 '          if all 4 IFs true then a collision must be happening
                End If
            End If
        End If
    End If
End Function
' -----------------------------------------
Sub RotateImage (Degree As Single, InImg As Long, OutImg As Long)
    '** This subroutine based on code provided by Rob (Galleon) on the QB64.NET website in 2009.
    Dim px(3) As Integer '     x vector values of four corners of image
    Dim py(3) As Integer '     saucer(c).loc.y vector values of four corners of image
    Dim Left As Integer '      left-most value seen when calculating rotated image size
    Dim Right As Integer '     right-most value seen when calculating rotated image size
    Dim Top As Integer '       top-most value seen when calculating rotated image size
    Dim Bottom As Integer '    bottom-most value seen when calculating rotated image size
    Dim RotWidth As Integer '  width of rotated image
    Dim RotHeight As Integer ' height of rotated image
    Dim WInImg As Integer '    width of original image
    Dim HInImg As Integer '    height of original image
    Dim Xoffset As Integer '   offsets used to move (0,0) back to upper left corner of image
    Dim Yoffset As Integer
    Dim COSr As Single '       cosine of radian calculation for matrix rotation
    Dim SINr As Single '       sine of radian calculation for matrix rotation
    Dim x As Single '          new x vector of rotated point
    Dim y As Single '          new saucer(c).loc.y vector of rotated point
    Dim v As Integer '         vector counter

    If OutImg Then _FreeImage OutImg '              free any existing image
    WInImg = _Width(InImg) '                        width of original image
    HInImg = _Height(InImg) '                       height of original image
    px(0) = -WInImg / 2 '                                                  -x,-saucer(c).loc.y ------------------- x,-saucer(c).loc.y
    py(0) = -HInImg / 2 '             Create points around (0,0)     px(0),py(0) |                 | px(3),py(3)
    px(1) = px(0) '                   that match the size of the                 |                 |
    py(1) = HInImg / 2 '              original image. This                       |        .        |
    px(2) = WInImg / 2 '              creates four vector                        |       0,0       |
    py(2) = py(1) '                   quantities to work with.                   |                 |
    px(3) = px(2) '                                                  px(1),py(1) |                 | px(2),py(2)
    py(3) = py(0) '                                                         -x,saucer(c).loc.y ------------------- x,saucer(c).loc.y
    SINr = Sin(-Degree / 57.2957795131) '           sine and cosine calculation for rotation matrix below
    COSr = Cos(-Degree / 57.2957795131) '           degree converted to radian, -Degree for clockwise rotation
    Do '                                            cycle through vectors
        x = px(v) * COSr + SINr * py(v) '           perform 2D rotation matrix on vector
        y = py(v) * COSr - px(v) * SINr '           https://en.wikipedia.org/wiki/Rotation_matrix
        px(v) = x '                                 save new x vector
        py(v) = y '                                 save new saucer(c).loc.y vector
        If px(v) < Left Then Left = px(v) '         keep track of new rotated image size
        If px(v) > Right Then Right = px(v)
        If py(v) < Top Then Top = py(v)
        If py(v) > Bottom Then Bottom = py(v)
        v = v + 1 '                                 increment vector counter
    Loop Until v = 4 '                              leave when all vectors processed
    RotWidth = Right - Left + 1 '                   calculate width of rotated image
    RotHeight = Bottom - Top + 1 '                  calculate height of rotated image
    Xoffset = RotWidth \ 2 '                        place (0,0) in upper left corner of rotated image
    Yoffset = RotHeight \ 2
    v = 0 '                                         reset corner counter
    Do '                                            cycle through rotated image coordinates
        px(v) = px(v) + Xoffset '                   move image coordinates so (0,0) in upper left corner
        py(v) = py(v) + Yoffset
        v = v + 1 '                                 increment corner counter
    Loop Until v = 4 '                              leave when all four corners of image moved
    OutImg = _NewImage(RotWidth, RotHeight, 32) '   create rotated image canvas
    '                                               map triangles onto new rotated image canvas
_MAPTRIANGLE (0, 0)-(0, HInImg - 1)-(WInImg - 1, HInImg - 1), InImg TO _
(px(0), py(0))-(px(1), py(1))-(px(2), py(2)), OutImg
_MAPTRIANGLE (0, 0)-(WInImg - 1, 0)-(WInImg - 1, HInImg - 1), InImg TO _
(px(0), py(0))-(px(3), py(3))-(px(2), py(2)), OutImg
End Sub
' -----------------------------------------
Function GETANGLE# (x1#, y1#, x2#, y2#) '                   Thanks to the QB64PE community for this
    '* Returns the angle in degrees from 0 to 359.9999.... between 2 given coordinate pairs.
    If y2# = y1# Then '                                       both Y values same?
        If x1# = x2# Then '                                   yes, both X values same?
            Exit Function '                                   yes, points are same, no angle
        End If
        If x2# > x1# Then '                                   second X value greater?
            GETANGLE# = 90 '                                  yes, then must be 90 degrees
        Else '                                                no, second X value is less
            GETANGLE# = 270 '                                 then must be 270 degrees
        End If
        Exit Function '                                       leave function
    End If
    If x2# = x1# Then '                                       both X values same?
        If y2# > y1# Then '                                   second Y value greater?
            GETANGLE# = 180 '                                 yes, then must be 180 degrees
        End If
        Exit Function '                                       leave function
    End If
    If y2# < y1# Then '                                       second Y value less?
        If x2# > x1# Then '                                   yes, second X value greater?
            GETANGLE# = Atn((x2# - x1#) / (y2# - y1#)) * -57.2957795131 ' yes, compute angle
        Else '                                                no, second X value less
            GETANGLE# = Atn((x2# - x1#) / (y2# - y1#)) * -57.2957795131 + 360 ' compute angle
        End If
    Else '                                                    no, second Y value greater
        GETANGLE# = Atn((x2# - x1#) / (y2# - y1#)) * -57.2957795131 + 180 ' compute angle
    End If
End Function
' -----------------------------------------
Sub GetNextCommand (c As Integer) '         used by saucer sub
    Shared saucer() As saucer

    saucer(c).loopCounter = 0
    saucer(c).loopNum = 0
    saucer(c).action = ""
    If saucer(c).charCount >= Len(saucer(c).commands) Then '    if at end of command line then that saucer is done
        saucer(c).alive = _FALSE '                               kind of a fail safe cuz render sub also kills saucer if ship is offscreen
        Exit Sub
    End If
    ' assign each separate command in command line
    saucer(c).charCount = saucer(c).charCount + 2 '                                     increment character counter  (skip space)
    saucer(c).action = LCase$(Mid$(saucer(c).commands, saucer(c).charCount, 1)) '       get the first char, the command letter: 'd,u,l,r' or 'c' for coast
    saucer(c).charCount = saucer(c).charCount + 1 '                                     move to next pair of chars - number of actions: loopNum
    saucer(c).loopNum = Val(Mid$(saucer(c).commands, saucer(c).charCount, 1)) * 10 '    turn the next char into tens column
    saucer(c).charCount = saucer(c).charCount + 1 '                                     skip the space in the string
    saucer(c).loopNum = saucer(c).loopNum + Val(Mid$(saucer(c).commands, saucer(c).charCount, 1)) '  turn this char into the ones value

    If saucer(c).action = "c" _AndAlso (saucer(c).loopNum > 58 _AndAlso saucer(c).loopNum < 90) Then
        FireBullet saucer(c).loc.x + 8, saucer(c).loc.y + 10 '                  drone fire at c60s and higher
    End If
End Sub
' -----------------------------------------
Sub ComeBack (action As String, c As Single) ' move saucers toward viewer

    Shared shipNum As Integer, saucer() As saucer '

    Select Case action '                                                        run action scripting
        Case "u": '                                                 UP
            saucer(c).aspect = saucer(c).aspect - .012 * saucer(c).aspectSign
            If saucer(c).aspect > .9 Then saucer(c).aspect = .9 '               nearly vertical
            If saucer(c).aspect <= .0000002 Then
                saucer(c).aspectSign = -saucer(c).aspectSign '                  switch up / down for continuity illusion
                saucer(c).aspect = .0000002 '                                   don't let the saucer(c).aspect get to zero - it goes haywire
                saucer(c).fillColor = C(10) ' was red
            End If
            ' ---------------------
        Case "d": '                                                 DOWN
            saucer(c).aspect = saucer(c).aspect + .012 * saucer(c).aspectSign
            If saucer(c).aspect > .9 Then saucer(c).aspect = .9 ' same as above
            If saucer(c).aspect <= .0000002 Then
                saucer(c).aspectSign = -saucer(c).aspectSign
                saucer(c).aspect = .0000002
                saucer(c).fillColor = C(4)
            End If
            ' ---------------------
        Case "r": '                                                 RIGHT
            saucer(c).rotAngle = saucer(c).rotAngle + 1.3
            If saucer(c).rotAngle > 80 Then saucer(c).rotAngle = 80
            ' ---------------------
        Case "l": '                                                 LEFT
            saucer(c).rotAngle = saucer(c).rotAngle - 1.3
            If saucer(c).rotAngle < -80 Then saucer(c).rotAngle = -80
    End Select
    ' ----------------------------
    If saucer(c).aspect <= 0 Then saucer(c).aspect = .0000001
    ' ----------------------------
    Select Case Abs(saucer(c).rotAngle) '                           >>> SIZE, SPEED CONTROLS VIA ROTANGLE <<<
        Case 0 To 5: saucer(c).speed = .3 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .035 ' was .07
        Case 5.00001 To 10: saucer(c).speed = .6 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .035
        Case 10.00001 To 15: saucer(c).speed = .9 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .033
        Case 15.00001 To 20: saucer(c).speed = 1.2 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .033
        Case 20.00001 To 26: saucer(c).speed = 1.6 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .028
        Case 26.00001 To 32: saucer(c).speed = 2.0 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .028
        Case 32.00001 To 38: saucer(c).speed = 2.4 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .025
        Case 38.00001 To 44: saucer(c).speed = 2.8 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .025
        Case 44.00001 To 50: saucer(c).speed = 3.0 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .02
        Case 50.00001 To 56: saucer(c).speed = 3.2 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .02
        Case 56.00001 To 62: saucer(c).speed = 3.4 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .017
        Case 62.00001 To 68: saucer(c).speed = 3.6 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .017
        Case 68.00001 To 74: saucer(c).speed = 4.0 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .015
        Case 74.00001 To 80: saucer(c).speed = 4.4 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .014
    End Select
    saucer(c).loc.x = saucer(c).loc.x + saucer(c).speed '                                   ** speed control **
    '                                                                                       EXCEPTIONS:
    If saucer(c).shipRadius < 1.15 Then saucer(c).shipRadius = saucer(c).shipRadius - .02 ' .02  NEW slow saucer growth initially
End Sub
' -----------------------------------------
Sub YControl (c As Integer) '
    Shared saucer() As saucer
    '                                                                                       ** UP / DOWN CONTROLS **
    If saucer(c).aspect > .029 Then '                                                       if the saucer(c).aspect angle is more than flat
        Select Case saucer(c).aspect '                                                      saucer ascends & descends faster at steeper angles
            Case .03 To .05: saucer(c).loc.y = saucer(c).loc.y + .3 * saucer(c).aspectSign '        once tilted, saucer keeps going
            Case .0500001 To .09: saucer(c).loc.y = saucer(c).loc.y + .6 * saucer(c).aspectSign
            Case .0900001 To .15: saucer(c).loc.y = saucer(c).loc.y + .9 * saucer(c).aspectSign
            Case .1500001 To .2: saucer(c).loc.y = saucer(c).loc.y + 1.5 * saucer(c).aspectSign
            Case .2000001 To .3: saucer(c).loc.y = saucer(c).loc.y + 2.3 * saucer(c).aspectSign
            Case .3000001 To .4: saucer(c).loc.y = saucer(c).loc.y + 3.0 * saucer(c).aspectSign
            Case .4000001 To .5: saucer(c).loc.y = saucer(c).loc.y + 3.8 * saucer(c).aspectSign
            Case .5000001 To .6: saucer(c).loc.y = saucer(c).loc.y + 4.2 * saucer(c).aspectSign
            Case .6000001 To .7: saucer(c).loc.y = saucer(c).loc.y + 4.6 * saucer(c).aspectSign
            Case .7000001 To .8: saucer(c).loc.y = saucer(c).loc.y + 5.2 * saucer(c).aspectSign
            Case .8000001 To .9: saucer(c).loc.y = saucer(c).loc.y + 5.8 * saucer(c).aspectSign
        End Select
    End If
End Sub
' -----------------------------------------
Sub RenderSaucer (c As Integer)

    Dim As Long virtual(9), outImg(9)
    Dim As Single x, y
    Shared saucer() As saucer
    Shared As Long HDWimg() '

    If virtual(c) <> 0 Then _FreeImage virtual(c): virtual(c) = 0 '                                 prevent memory leaks! <<<<
    virtual(c) = _NewImage(saucer(c).shipRadius * 2 + 30, saucer(c).shipRadius * 2 + 30, 32) '      size the virtual screens dynamically
    If outImg(c) <> 0 Then _FreeImage outImg(c): outImg(c) = 0 '
    outImg(c) = _NewImage(saucer(c).shipRadius * 2 + 30, saucer(c).shipRadius * 2 + 30, 32) '       doesn't seem to kill performance

    If saucer(c).loc.y < -58 _OrElse saucer(c).loc.y > 900 - 8_
    _OrElse saucer(c).loc.x >= 1600 + saucer(c).shipRadius + 20 _OrElse saucer(c).loc.x <= -58 Then ' off-screen saucer = dead
        saucer(c).alive = _FALSE '                                                                  turn off this saucer
    End If
    ' --------------------------
    If saucer(c).rotAngle > 0 Then saucer(c).rotAngSign = 1 '                   compensates for left or right turns
    If saucer(c).rotAngle < 0 Then saucer(c).rotAngSign = -1 '                  once turned, saucer keeps going
    ' --------------------------
    YControl c
    ComeBack saucer(c).action, c '                                              subs for saucer x and y movement, speed & size, aspect controls
    ' --------------------------                               ** RENDERING **
    _Dest virtual(c) '                                                          draw to virtual screen first, then rotate as needed
    x = _Width \ 2 - saucer(c).shipRadius \ 2: y = _Height \ 2 - saucer(c).shipRadius \ 2 ' CENTERED PROPERLY NOW! <<<<<<<<<<<<<<< **** !!!!
    Circle (x, y), saucer(c).shipRadius, C(14), 0, 6.283, saucer(c).aspect '    draw saucer centered

    If saucer(c).aspect > .003 Then ' was 4
        Paint (x, y), saucer(c).fillColor, C(14) '                only paint the inside when the ship's profile is an oval - not a line!
        If saucer(c).fillColor = C(4) Then '                                                c(4) is top - ship going down
            Circle (x, y), saucer(c).shipRadius * .8, C(0), 0, 6.283, saucer(c).aspect '    add some top o' saucer details
            Circle (x, y), saucer(c).shipRadius * .2, C(12), 0, 6.283, saucer(c).aspect
            Paint (x, y), C(14), C(12)
            If saucer(c).shipRadius > 14 Then
                Circle (x, y), saucer(c).shipRadius * .8, C(12), 0, , saucer(c).aspect '
                Paint (x, y), C(0), C(12)
            End If
        Else '                                                                              bottom o' saucer details - red fillcolor
            Circle (x, y), saucer(c).shipRadius * .8, C(14), 0, 6.283, saucer(c).aspect
            Circle (x, y), saucer(c).shipRadius * .74, C(14), 0, 6.283, saucer(c).aspect
            Circle (x, y), saucer(c).shipRadius * .3, C(4), 0, 6.283, saucer(c).aspect
            Paint (x, y), C(0), C(4)
        End If
    End If
    If saucer(c).aspect <= .066 Then '                                      draw arcs for top and bottom of saucer at flat saucer(c).aspect
        Circle (x, y), saucer(c).shipRadius, C(14), 3.14, 6.28, .11
        Circle (x, y), saucer(c).shipRadius, C(14), 6.28, 3.14, .09
        Paint (x, y), C(14), C(14) '
    End If
    ' --------------------------
    RotateImage saucer(c).rotAngle, virtual(c), outImg(c) '

    If HDWimg(c) <> 0 Then _FreeImage HDWimg(c): HDWimg(c) = 0
    HDWimg(c) = _CopyImage(outImg(c), 32) '                 convert to hardware image - no, stick with SOFTWARE - hides saucer image boxes in Windows!
    _FreeImage outImg(c) '
    _FreeImage virtual(c)
    _Font 16: _Dest 0
End Sub
' -----------------------------------------
Sub CheckSaucerProx (c As Integer) '                        c represents the current saucer assignment number
    '                                                       a is the lower selection number for comparison
    Shared shipNum As Integer, saucer() As saucer '         this sub checks same-saucer (both/many assigned the same moves(#)) proximity
    Dim As Integer a, count

    a = 0: count = 0
    Do
        count = count + 1
        a = c - count
        If a = 0 Then Exit Sub
        If saucer(c).movesNum = saucer(a).movesNum Then
            If Abs(saucer(c).loc.x - saucer(a).loc.x) < 90 Then '       if the current saucer is too close to an older saucer then
                If Sgn(saucer(c).loc.x - saucer(a).loc.x) < 1 Then '    if the difference is negative or zero then
                    saucer(c).loc.x = saucer(c).loc.x - 100 '
                Else
                    saucer(c).loc.x = saucer(c).loc.x + 100
                End If
            End If
            If Abs(saucer(c).loc.y - saucer(a).loc.y) < 80 Then
                If Sgn(saucer(c).loc.y - saucer(a).loc.y) < 1 Then
                    saucer(c).loc.y = saucer(c).loc.y - 90
                Else
                    saucer(c).loc.y = saucer(c).loc.y + 90
                End If
            End If
        End If
    Loop
End Sub
' -----------------------------------------
Sub ManageBullets () '                      ManageBullets & Star Shaking & Related Sounds & ScoreKeeping Chores
    '                                       Thanks, Terry Ritchie
    Shared Bullet() As bullet
    Shared As Long saucerScape
    Dim Index As Integer
    Static As _Byte wiggle, s, a, adder, initd

    If Control.clearStatics Then initd = _FALSE: Exit Sub
    If Not initd Then
        adder = 3
        a = 0
        s = 0
        initd = _TRUE
    End If

    Index = -1 '                                    reset index counter value
    Do '                                            begin array search loop
        Index = Index + 1 '                         increment array index counter
        If Bullet(Index).Active Then '              is this bullet active?
            If Bullet(Index).Radius < 360 Then '    only course adjust smaller circles to prevent wobble
                If Bullet(Index).x < 800 - 5 Then ' leave a range of OK centering to avoid over-adjusting center
                    Bullet(Index).x = Bullet(Index).x + Bullet(Index).Speed
                Else If Bullet(Index).x > 800 + 5 Then Bullet(Index).x = Bullet(Index).x - Bullet(Index).Speed
                End If

                If Bullet(Index).y < 450 - 5 Then
                    Bullet(Index).y = Bullet(Index).y + Bullet(Index).Speed
                Else If Bullet(Index).y > 450 + 5 Then Bullet(Index).y = Bullet(Index).y - Bullet(Index).Speed
                End If
            End If

            If Bullet(Index).Radius < 60 Then '                 circle growth
                Bullet(Index).Radius = Bullet(Index).Radius + 3
            Else
                If Bullet(Index).Radius > 59 _AndAlso Bullet(Index).Radius < 200 Then
                    Bullet(Index).Radius = Bullet(Index).Radius + 12
                Else
                    If Bullet(Index).Radius > 199 Then
                        Bullet(Index).Radius = Bullet(Index).Radius + 40
                    End If
                End If
            End If

            Bullet(Index).Speed = Bullet(Index).Speed * 1.05 '  increase speed slightly
            If Bullet(Index).Radius > 400 _AndAlso Bullet(Index).Radius < 406 Then
                _SndPlayCopy S(37), .35 '                       impact sound
                Game.score = Game.score - (10 * Game.diff_mult) '                 ** SCORE **
                If Ship.shields > 8 Then Ship.shields = Ship.shields - 1.8 '    ** SHIELDS - cannot blow up during saucer attacks **
                If Ship.power > 12 Then Ship.power = Ship.power - .6
                wiggle = _TRUE
            End If

            If wiggle Then '                                    shake starScape
                s = s + 1
                a = a + adder ' 3
                _PutImage (a, 0), saucerScape '                 move stars horizontally 9 pixels each way
                If a = 9 _OrElse a = -9 Then adder = -adder '
                If s = 22 Then
                    a = 0
                    s = 0
                    adder = 3
                    wiggle = _FALSE
                End If
            End If
            'Check to see if the circle has left the game screen
            If Bullet(Index).Radius > 700 Then ' '              has bullet gotten big enough?
                Bullet(Index).Active = 0 '                      yes, deactivate bullet
            Else '                                              no, bullet still on game screen
                Circle (Bullet(Index).x, Bullet(Index).y), Bullet(Index).Radius, C(12) '      draw the bullet
                CircleFill Bullet(Index).x, Bullet(Index).y, Bullet(Index).Radius, _RGB32(227, 50, 55, 43) '   paint the bullet circle
            End If
        End If
    Loop Until Index = UBound(Bullet) '                         leave when all indexes checked
End Sub
' -----------------------------------------
Sub FireBullet (x As Integer, y As Integer) '       Props to Terry Ritchie for this

    Shared Bullet() As bullet ' need access to player bullet array
    Dim Index As Integer ' array index counter

    Index = -1 '                                    reset index counter
    Do '                                            begin array search loop
        Index = Index + 1 '                         increment array index counter
    Loop Until Index = UBound(Bullet) _OrElse Bullet(Index).Active = 0 '     leave when inactive found or at end of array

    If Bullet(Index).Active Then '                  was an inactive array index found?
        Index = Index + 1 '                         no, increase the array index size
        ReDim _Preserve Bullet(Index) As bullet '   resize the array while preserving exisiting data
    End If

    Bullet(Index).x = x '                           new bullet's x coordinate
    Bullet(Index).y = y '                           new bullet's y coordinate
    Bullet(Index).Speed = 2 '                       new bullet's initial speed
    Bullet(Index).Radius = 3
    Bullet(Index).Active = 1 '                      this array index is active
    _SndPlayCopy S(36), .15 '                       awesome saucer bullet sound
End Sub
' -----------------------------------------
Sub DriveTruck () '                         now with flashing lights @ landing pad - oh boy
    Static As Single c, d
    Static As Integer i
    Static As _Byte sign
    Dim As Integer x, y

    If Control.clearStatics Then c = 0: d = 0: i = 0: Exit Sub
    x = 406: y = 563

    If Not Flag.fireworksInProgress Then c = c + .28 Else c = c + .65 ' account for slowdown during fireworks
    d = d + .006
    _PutImage (726 - c, 660 + d), I(3), 0
    ' -------------------------                     * SIRENS / BEACONS *
    If Not Ship.landed Then '
        Circle (x, y), 4, C(1), _D2R(360), _D2R(180), 1
        Circle (x + 161, y), 4, C(1), _D2R(360), _D2R(180), 1 '   location #2's
        Line (x - 4, y)-(x - 4, y + 4), C(1)
        Line (x - 4 + 161, y)-(x - 4 + 161, y + 4), C(1)
        Line (x + 4, y)-(x + 4, y + 4), C(1)
        Line (x + 4 + 161, y)-(x + 4 + 161, y + 4), C(1)
        Line (x - 4, y + 4)-(x + 4, y + 4), C(1)
        Line (x - 4 + 161, y + 4)-(x + 4 + 161, y + 4), C(1)
        i = i + 1: If i > 5000 Then i = 0
        If i = 1 Then sign = 1 '                        initialize sign
        If i Mod 15 = 0 Then sign = -sign '
        If sign = 1 Then
            Paint (x, y), C(12), C(1) '
            Paint (x + 161, y), C(14), C(1)
        Else
            Paint (x, y), C(14), C(1)
            Paint (x + 161, y), C(12), C(1)
        End If
    End If
    ' -------------------------
    If c > 1150 Then '          lots of cycles for the truck and beacons before shutting off sub
        c = 0: d = 0: i = 0
        Sb.doTruck = _FALSE
    End If
End Sub
' -----------------------------------------
Sub Instructions () '

    Dim As Integer c, d, i '
    Dim a$, b$, c$, d$, e$, f$ '
    Dim As _Byte oldMB, mb, count
    Shared As Long starScape

    a$ = "Press a key or mouse click to continue..."
    b$ = "WELCOME TO ROCK JOCKEY."
    c$ = "YOU'LL BE MANNING THE CONTROLS OF A POWERFUL SMART-DRONE."
    d$ = "SCAN & HARVEST THE VALUABLE PURPLE ASTEROIDS, THEN TAKE EM BACK TO BASE."
    e$ = "PRESS 'ESC' FOR SETTINGS / INTRO SCREEN / EXIT"
    f$ = "'SPACEBAR' TO CAPTURE ROCKS IN SPACE OR OFF-LOAD ROCKS WHEN LANDED."

    _SndLoop S(32): _SndVol S(32), .001 '   run sound
    Do
        c = c + 1
        _SndVol S(32), c * .001 '           turn it up
        _Limit 40
    Loop Until c = 36
    Cls
    _Display
    _Font Menlo: Color C(14)
    For i = 255 To 0 Step -4 '              fade in scene
        Cls
        _PutImage , starScape
        Color C(14)
        _PrintString (_Width \ 2 - _PrintWidth(b$) \ 2, 430), b$
        _PrintString (_Width \ 2 - _PrintWidth(c$) \ 2, 465), c$
        _PrintString (_Width \ 2 - _PrintWidth(d$) \ 2, 500), d$
        Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '      increase black box transparency
        _Display
        _Limit 80 '
    Next
    _Delay 3.7
    For d = 4 To 9 '                                                churn through demo images
        Cls
        _PutImage , starScape
        _PutImage (_Width \ 2 - _Width(I(d)) \ 2, 50), I(d)
        Color C(14)
        _PrintString (_Width \ 2 - _PrintWidth(b$) \ 2, 430), b$
        _PrintString (_Width \ 2 - _PrintWidth(c$) \ 2, 465), c$
        _PrintString (_Width \ 2 - _PrintWidth(d$) \ 2, 500), d$
        _PrintString (_Width \ 2 - _PrintWidth(e$) \ 2, 555), e$
        _PrintString (_Width \ 2 - _PrintWidth(f$) \ 2, 580), f$
        Color C(4)
        _Display

        oldMB = -1 '                        count as if the mouse is down to begin with
        Do
            _Limit 30 '                     Thanks to Steve McNeill for this wee mouse click code <<<<<<<<
            While _MouseInput: Wend
            mb = _MouseButton(1)
            If (mb _AndAlso Not oldMB) _OrElse InKey$ <> "" Then
                Exit Do
            End If
            oldMB = mb
            count = count + 1
            If count = 1 Then _PrintString (_Width \ 2 - _PrintWidth(a$) \ 2, 685), a$
            If count = 50 Then Line (_Width \ 2 - _PrintWidth(a$) \ 2, 680)-_
            (_Width \ 2 + _PrintWidth(a$) \ 2, 700), C(0), BF: count = -50 '    erasure box
            _PutImage (300, 680), starScape, 0, (300, 680)-(800, 720) '         new, re-star the blank text box w/ part of starScape <<<<
            _Display
        Loop
    Next

    Cls
    d = 0
    Do
        d = d + 1 '                                 d turns down music and changes alpha value
        Color _RGB32(255, 255, 140, d * .2) '       was 2 (1.2)
        _PrintString (_Width \ 2 - _PrintWidth("GOOD LUCK!") \ 2, 300), "GOOD LUCK!"
        _SndVol S(32), .05 - (d * .0009) '          turn down music loop
        _Display
        _Limit 40
    Loop Until d >= 55

    _KeyClear
    Sb.doInstructs = _FALSE: SubFlags(18) = _FALSE
    _SndStop S(32): _SndVol S(32), .038 '
    SplashPage
End Sub
' -----------------------------------------
Sub SplashPage () '

    Dim As Long splashImg, outImg, spaceP
    Dim As Integer c, i, x, y, adder, spin
    Dim As Single adder3, e, vol, d, xScroller, f
    Dim a$, b$
    Dim As _Byte done
    Shared As Long starScape, starScape2, shipImg
    Shared As String rockType()

    DrawStars '
    RotateImage 270, shipImg, outImg
    SoundOff '                                      kill any playing loops
    _SndLoop S(38): _SndVol S(38), 0: vol = .3 '    start fresh loop
    Control.hold = _TRUE
    Resetter(22) = _FALSE
    splashImg = _NewImage(1280, 720, 32)
    spaceP = _LoadFont("Fonts/spacePatrol.otf", 44)
    a$ = "Rock Jockey"
    b$ = "A c t i o n  &  A d v e n t u r e"
    _Dest splashImg
    _PutImage (400, 200), I(10) '   rocket
    _PutImage (960, 420), I(13) '   asteroid
    _PutImage (530, 380), I(14) '   asteroid
    _PutImage (120, 520), I(15) '   asteroid
    _PutImage (260, 400), I(16) '   asteroid
    _PutImage (1030, 270), I(18) '  saucer
    Color C(14): _Font spaceP
    _PrintMode _KeepBackground
    _UPrintString (_Width \ 2 - _PrintWidth(a$) \ 2, 48), a$
    Color C(12): _Font Menlo
    _UPrintString (_Width \ 2 - _PrintWidth(b$) \ 2, 114), b$
    Line (0, 0)-(_Width - 1, _Height - 1), C(3), B '            border
    Line (24, 24)-(_Width - 25, _Height - 25), C(3), B
    Paint (10, 10), C(5), C(3)
    _Font 16 '      <<<< THIS TOOK FOREVER - GOTTA DO A SYS _FONT INSIDE DIFFERENT _DESTS TO ALLOW FREEING FONTS! <<<< <<<<
    _Dest 0
    i = 255: c = 240
    adder = -2 '                    increments label fades
    adder3 = .6 '                   alien movement
    Cls
    _Display
    Do
        Cls '                    SndFade = snd, changeAmnt, goal, presVol, Resetter(#) to kill
        If Not Resetter(22) Then SndFade1 S(38), .002, .3, 0, 22
        e = e + adder3 '                                            moves alien ship
        If e > 50 _OrElse e < -180 Then adder3 = -adder3
        xScroller = xScroller - .25 '                               scroll stars to the left
        _PutImage (xScroller, 0), starScape
        _PutImage (1281 + xScroller, 0), starScape2
        If xScroller < -1280 Then xScroller = 0
        If d < 1450 Then
            d = d + 1.5
            _Font ModernBig: Color C(14)
            _UPrintString (-200 + d, 670), "TURN UP YOUR SPEAKERS"
            _PutImage (1300 - d, 150), outImg '                                 meandering ship
            If d > 570 Then f = f + .65: RotateImage -90 + f, shipImg, outImg ' spin ship a bit
        End If

        While _MouseInput: Wend '
        x = _MouseX: y = _MouseY
        '                                         ** MOUSE CLICKS **
        If _MouseButton(1) Then '                   box: PLAY GAME
            If x > 80 _AndAlso x < 170 Then
                If y > 300 _AndAlso y < 320 Then
                    If Not Sb.doFF _AndAlso Not Sb.doSaucers Then TurnOnChecks ' this affects rocks sub
                    SoundOn '                                       resume sound loops
                    Ship.course = 0: Ship.speed = 0 '               reset game
                    Ship.x = CENTX: Ship.y = CENTY
                    If Not Flag.settingsDone Then Sb.doSettings = _TRUE: SubFlags(19) = _TRUE ' new - run settings before play begins
                    Exit Do
                End If
            End If

            If x > 80 _AndAlso x < 240 Then '            box: INSTRUCTIONS
                If y > 340 _AndAlso y < 360 Then
                    Sb.doInstructs = _TRUE: SubFlags(18) = _TRUE
                    Exit Do '
                End If
            End If

            If x > 80 _AndAlso x < 160 Then '            box: PRACTICE
                If y > 380 _AndAlso y < 400 Then
                    If Time.gameStart < 6 Then '    only before game start can you practice
                        Flag.doPractice = _TRUE '    and time.gameStart initd to 5 @ starts/resets
                        KillChecks
                        Exit Do
                    End If
                End If
            End If

            If x > 80 _AndAlso x < 124 Then '            box: EXIT
                If y > 420 _AndAlso y < 440 Then '
                    _Font 16: _FreeFont spaceP
                    _FreeImage splashImg: _FreeImage outImg
                    WrapUp: System
                End If
            End If
        End If

        Color _RGB32(0, 255, 0, c): _Font Menlo
        _UPrintString (80, 300), "PLAY GAME" ' WAS 350
        _UPrintString (80, 340), "INSTRUCTIONS"
        _UPrintString (80, 380), "PRACTICE"
        _UPrintString (80, 420), "EXIT"
        c = c + adder '                             alpha changer value
        If c < 30 _OrElse c > 255 Then adder = -adder

        PReset (1130, 120), C(14) '                 spinning rock 1, right
        Draw "TA=" + VarPtr$(spin) + rockType(10)
        Paint (1128, 122), _RGB32(28), C(14)
        PSet (1130, 120), C(0)
        spin = spin + 1
        PReset (140, 120), C(14) '                  rock 2, left
        spin = -spin
        Draw "TA=" + VarPtr$(spin) + rockType(6) '
        Paint (141, 122), _RGB32(32), C(14)
        PSet (140, 120), C(0) '                     kill dot in center
        spin = -spin
        _PutImage (809, 460 + e * 1.5), I(2) '      move alien ship
        _PutImage , splashImg '                     backdrop last
        If Not done Then
            i = i - 4
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            If i < 10 Then done = _TRUE: _MouseShow '
        End If
        _Display
        _Limit 60 ' was 45 - too jerky, 60 is best
    Loop

    _KeyClear '                                                     prevents popUp at start
    For i = 0 To 255 Step 5
        Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '      quick fade out
        vol = vol - .005
        _SndVol S(38), vol
        _Display
        _Limit 100 '
    Next

    _Font 16: _FreeFont spaceP
    _FreeImage splashImg: _FreeImage outImg
    _MouseHide: _SndStop S(38)
    Sb.doPopUp = _FALSE: Control.hold = _FALSE
    FPS = 10: Flag.speedUp = _TRUE '

    If Flag.landingTime _AndAlso Not Sb.doFF _AndAlso Not Ship.landed Then '   put the ship back at the top
        Ship.x = CENTX: Ship.y = 20
        Ship.Vx = 0: Ship.Vy = 0: Ship.course = 0
    End If

End Sub
' -----------------------------------------
Sub Settings () '
    '
    Dim As Integer i, j, x, y
    Dim As Single vol
    Dim As _Byte changeMade '
    Shared As Integer diffX, msX, maxComets 'rezX,

    Control.hold = _TRUE '                               stop the game loop
    Cls , _RGB32(30, 102, 140)
    _MouseShow
    SoundOff: KillNoises
    _SndPlay S(39): vol = .25
    Color C(14)
    _Font MenloBig
    _UPrintString (50, 28), "SETTINGS"
    Color C(14) '
    Line (20, 60)-(_Width - 20, 60), C(6)
    _Font 8: Color C(9)
    _UPrintString (55, 234), "SLOWER" '
    _UPrintString (179, 234), "FASTER"
    _Font Menlo: Color C(14)
    _UPrintString (50, 208), "SET MOUSE SENSITIVITY"

    For j = 0 To 4
        If j <> 5 Then _UPrintString (46 + j * 40, 290), Str$(j)
        Circle (60 + j * 40, 270), 7, C(16) '                           0 to 4 buttons
        Paint (60 + j * 40, 270), C(0), C(16)
    Next j
    Paint (msX, 270), C(12), C(16) '                                    paint the existing selection #2
    Line (20, 325)-(_Width - 20, 325), C(6) '                           separator line
    _Font Menlo: Color C(14) '
    _UPrintString (50, 350), "DISPLAY SET TO _FULLSCREEN" '
    Color C(9)
    _UPrintString (40, 402), "(It doesn't ever lose focus)"
    Color C(14)
    Circle (160, 385), 7, C(16) ': Paint (202, 385), C(0), C(16) '        buttons
    'Circle (310, 385), 7, C(16): Paint (310, 385), C(0), C(16)
    Paint (160, 385), C(12), C(16) '                                   paint existing choice #3

    'If _FullScreen <> 0 Then
    _UPrintString (450, 350), "DOES THE SCREEN LOOK FUNNY? Try toggling the setting..." '   toggle SqrPix
    _Font 8: Color C(9)
    _UPrintString (450, 382), "_SQUARE PIXELS _SMOOTH:"
    _UPrintString (675, 382), "<<< CLICK THE BUTTON"
    Circle (652, 385), 7, C(16)
    If _FullScreen = 2 Then
        Paint (652, 385), C(4), C(16)
    Else Paint (652, 385), C(12), C(16)
    End If
    'End If
    _Display '

    _Font Menlo: Color C(14) '
    Line (20, 430)-(_Width - 20, 430), C(6)
    Line (1164, 430)-(_Width - 21, 430), C(6)
    _UPrintString (50, 448), "SET GAME DIFFICULTY"
    Color C(9)
    _UPrintString (116, 480), "EASY": _UPrintString (250, 480), "MEDIUM"
    _UPrintString (395, 480), "HARD"
    Circle (133, 514), 7, C(16): Paint (133, 514), C(0), C(16)
    Circle (277, 514), 7, C(16): Paint (277, 514), C(0), C(16)
    Circle (413, 514), 7, C(16): Paint (413, 514), C(0), C(16)
    Paint (diffX, 514), C(12), C(16) '                                  paint existing choice #4
    Line (20, 554)-(_Width - 20, 554), C(6) '
    Color C(14)
    Line (84, 590)-(172, 620), C(4), B
    Paint (100, 600), _RGB32(240, 0, 0, 140), C(4)
    _UPrintString (112, 598), "DONE"
    _PutImage (21, 70), I(19) '                                         row of analoggy images, ENIAC
    _PutImage (248, 70), I(20)
    _PutImage (445, 70), I(21) '                                        old school computery stuff
    _PutImage (642, 70), I(20)
    _PutImage (840, 70), I(22)
    _PutImage (1034, 70), I(19)
    _PutImage (644, 432), I(23)
    _PutImage (728, 432), I(23)
    _PutImage (821, 527), I(24)
    _PutImage (962, 436), I(25)
    Line (0, 0)-(_Width - 1, _Height - 1), C(3), B '                    border
    Line (17, 17)-(_Width - 18, _Height - 18), C(3), B
    Paint (10, 10), _RGB32(0, 74, 0), C(3)

    Do '                                                                ** BUTTON SELECTION **
        While _MouseInput: Wend
        x = _MouseX
        y = _MouseY
        If _MouseButton(1) Then '
            If y >= 263 _AndAlso y <= 277 Then '                             ** MOUSE SENSITIVITY **  0 to 4 buttons
                For j = 0 To 4
                    If x >= (60 + j * 40) - 8 _AndAlso x <= (60 + j * 40) + 8 Then ' selection made?
                        For i = 0 To 4
                            Paint (60 + i * 40, 271), C(0), C(16) '     black out all the cells
                        Next i
                        _SndPlay S(2)
                        Paint (60 + j * 40, 271), C(12), C(16) '        paint the selected cell
                        Select Case j '                                 set mouse multiplier
                            Case 0: MouseSens = .15
                            Case 1: MouseSens = .18
                            Case 2: MouseSens = .225
                            Case 3: MouseSens = .26
                            Case 4: MouseSens = .31
                        End Select
                        msX = 60 + j * 40
                        changeMade = _TRUE
                    End If
                Next j
            End If

            If y >= 380 _AndAlso y <= 395 Then
                'If x >= 194 _AndAlso x <= 209 Then '           DISABLED! FULLSCREEN IS BETTER!
                '  _SndPlay S(2)
                '  Paint (202, 385), C(12), C(16)
                '  Paint (310, 385), C(0), C(16)
                '  rezX = 202
                '  Flag.fullScreen = _TRUE '                    _FULLSCREEN _ON
                '  Flag.fullScreenOff = _FALSE
                '  changeMade = _TRUE
                '  ElseIf x >= 303 _AndAlso x <= 317 Then '     _FULLSCREEN _OFF  (NATIVE)
                '  _SndPlay S(2)
                '  Paint (202, 385), C(0), C(16)
                '  Paint (310, 385), C(12), C(16)
                '   rezX = 310
                '  Flag.fullScreenOff = _TRUE
                '  Flag.fullScreen = _FALSE
                '  changeMade = _TRUE
                If x >= 645 _AndAlso x <= 660 Then '             _SQR_PIX ON/OFF
                    If _FullScreen <> 0 Then
                        _SndPlay S(2)
                        Flag.toggle_SqrPix = _TRUE
                        If _FullScreen = 2 Then '               change the color
                            Paint (652, 385), C(12), C(16)
                        Else Paint (652, 385), C(4), C(16)
                        End If
                        changeMade = _TRUE
                    End If
                End If
            End If

            If y >= 507 _AndAlso y <= 521 Then '
                If x >= 126 _AndAlso x <= 140 Then '                 ** EASY **
                    _SndPlay S(2)
                    Paint (133, 514), C(12), C(16)
                    Paint (277, 514), C(0), C(16) '             8 ships total
                    Paint (413, 514), C(0), C(16)
                    diffX = 133
                    Game.diff_mult = .9 '                      subtract 10% on score for EASY
                    Game.speed = 52 '                           was 54
                    Game.landingSpeed = 45 '
                    MaxRocks = 10
                    If Not Flag.landingTime Then AssignRocks
                    maxComets = 75
                    If Not Sb.doComets Then InitCOMETS
                    Ship.inventory = 10 - Ship.blownUp
                    changeMade = _TRUE
                Else '
                    If x >= 270 _AndAlso x <= 285 Then '             ** MEDIUM **
                        _SndPlay S(2)
                        Paint (277, 514), C(12), C(16)
                        Paint (133, 514), C(0), C(16)
                        Paint (413, 514), C(0), C(16) '         6 ships total, set in startUp SUB
                        diffX = 277
                        Game.diff_mult = 1
                        Game.speed = 60
                        Game.landingSpeed = 60
                        MaxRocks = 12
                        If Not Flag.landingTime Then AssignRocks
                        maxComets = 90
                        If Not Sb.doComets Then InitCOMETS
                        Ship.inventory = 7 - Ship.blownUp '
                        changeMade = _TRUE
                    Else
                        If x >= 406 _AndAlso x <= 420 Then '         ** HARD **
                            _SndPlay S(2)
                            Paint (413, 514), C(12), C(16)
                            Paint (133, 514), C(0), C(16) '     4 ships total
                            Paint (277, 514), C(0), C(16)
                            diffX = 413
                            Game.diff_mult = 1.1 '             add 10% on score for HARD
                            Game.speed = 70
                            Game.landingSpeed = 72
                            MaxRocks = 14
                            If Not Flag.landingTime Then AssignRocks
                            maxComets = 115
                            If Not Sb.doComets Then InitCOMETS
                            Ship.inventory = 5 - Ship.blownUp '
                            changeMade = _TRUE
                        End If
                    End If
                End If
            End If
            If y >= 588 _AndAlso y <= 622 Then '
                If x >= 82 _AndAlso x <= 174 Then '                      DONE button
                    Paint (100, 600), _RGB32(0, 255, 0, 80), C(4)
                    Exit Do
                End If
            End If
            _Delay .17 '                                        prevents multiple click sounds
        End If ' - - - - - - - - - - - - - - - - - -            end of click loop checks
        _Display '
        _Limit 20
    Loop

    If changeMade Then
        _SndPlay S(3)
        Color C(14)
        _Font Menlo
        _UPrintString (54, 650), "SETTINGS ADJUSTED"
        _Display
        _Delay .7
    End If
    For i = 0 To 255 Step 4
        vol = vol - .004 '
        _SndVol S(39), vol '
        Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  quick fade out
        _Display
        _Limit 100 '
    Next
    _KeyClear: _MouseHide
    Control.hold = _FALSE '                                      resume main game loop
    FPS = 10: Ship.course = 0 '                                 set FPS for speedUp, zero out shipCourse
    Flag.speedUp = _TRUE
    Sb.doSettings = _FALSE: SubFlags(19) = _FALSE
    Flag.settingsDone = _TRUE '                                  track that it's been run
    Sb.doPopUp = _FALSE
    _SndStop S(39): _SndVol S(39), .21 '                        stop & reset volume for next time
    SoundOn: _Font 16
    If Not Sb.doFF _AndAlso Not Sb.doSaucers _AndAlso Not Sb.doGauntlet Then TurnOnChecks
    If Ship.speed > 2.7 Then Ship.speed = 2.7 '                                     ease back into the game if zooming before popUp
    If Time.gameStart = 5 Then Time.gameStart = Timer ' time.gameStart is set in resetFlags & startUp to 5 as a flag as not started yet
End Sub '                                                       & turned on here just before game start
' -----------------------------------------
Sub ShipBoom ()

    Shared As Long timer1, timer3
    Shared As _Byte delayVO, sparkCycles
    Shared spark() As spark

    KillNoises: KillChecks
    If Not Flag.shipBoomDone Then
        Ship.inventory = Ship.inventory - 1 '
        Ship.blownUp = Ship.blownUp + 1
        Flag.shipBoomDone = _TRUE
    End If
    Sb.doShip = _FALSE: SubFlags(2) = _FALSE
    sparkCycles = 0 '                           new new new - RESET BLOWUP SUB
    ReDim spark(0) As spark '                   new new new - RESET SPARKS FOR PRIORITY SHIPBOOM! <<<<
    Flag.boomInProgress = _TRUE ' <<<<<<<<< NEW
    Sb.doSparks = _TRUE: SubFlags(8) = _TRUE: boomInfo.num = 20: boomInfo.r = 0: boomInfo.g = 227: boomInfo.b = 0 '
    Flag.doCircle = _FALSE '                               sometimes created an artifact w/o this
    _SndPlay S(Int(Rnd * 3 + 4)) '
    If Ship.inventory >= -1 Then
        Timer(timer1) On ' <<<<<<<<<                    flip on ship timer - pause before reappearing
        If Not _SndPlaying(S(23)) Then '                don't step on heaven!
            If Not IsVOPlaying Then
                _SndPlay VO(29) '                       ** packaged sounds ** gotta play simultaneously **
                Select Case Ship.inventory '            "ship destroyed, n remaining"
                    Case -1: _SndPlay VO(30) '      0 ships
                    Case 0: _SndPlay VO(30) '       0
                    Case 1: _SndPlay VO(31) '       1
                    Case 2: _SndPlay VO(32) '       2
                    Case 3: _SndPlay VO(35) '       etc
                    Case 4: _SndPlay VO(38)
                    Case 5: _SndPlay VO(39)
                    Case 6: _SndPlay VO(40)
                    Case 7: _SndPlay VO(41)
                    Case 8: _SndPlay VO(42)
                    Case 9: _SndPlay VO(47)
                End Select
                _SndPlay VO(28) '       "remaining"          \/ cumbersome but effective?
            ELSE IF NOT _SNDPLAYING(VO(29)) _ANDALSO NOT _SNDPLAYING(VO(30)) _ANDALSO NOT_
             _SNDPLAYING(VO(31)) _ANDALSO NOT _SNDPLAYING(32) _ANDALSO NOT _SNDPLAYING(VO(35))_
              THEN TIMER(timer3) ON: delayVO = 29 '   then turn on VO delay timer, assign VO to play
            End If
        End If
    End If
End Sub
' -----------------------------------------
Sub EndGame () '

    Static As Integer count
    Shared As Single xScroller
    Shared As Long starScape, timer3, starScape2
    Dim As Integer k, c, e '
    Dim a$

    If Control.clearStatics Then count = 0: Exit Sub
    KillNoises
    Do: e = _MouseInput: Loop Until e = 0 '     clear mouse input
    Cls: Timer(timer3) Off
    _Limit 70
    If Game.round = 1 Then
        _PutImage , starScape, 0
    Else _PutImage , starScape2, 0
    End If
    a$ = "THANKS FOR PLAYING!"
    KillChecks
    Sb.doPopUp = _FALSE
    count = count + 1
    _Font MenloBig: Color C(14)
    _PrintString (_Width / 2 - (_PrintWidth(a$) / 2), _Height / 2 - 100), a$ '
    _Font 16
    If count > 82 Then
        For k = 0 To 255 Step 4
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, k), BF '  fade out
            _Display
            _Limit 50 '
        Next
        HighScore '                             check for hiScore and/or display it
        If Control.restart Then
            Control.clearStatics = _TRUE '
            count = 0
            Control.endIt = _FALSE
            SoundOff: KillNoises
            StartUp: ResetFlags
            SplashPage
            Exit Sub
        Else
            WrapUp '                            close all assets
            System '                            <<<< FINITO >>>>
        End If
    End If '
    _Font 16
End Sub
' -----------------------------------------
Sub HighScore () '

    Dim As _Byte c, d, addYrName, toggle, seconds, minutes
    Dim As Integer i, fileScore, fileKillRatio, fileTimeInBox, k
    Dim As String filePlayer
    Dim a$, b$, c$, d$, e$, newName$, secs$
    Dim As Long virtual
    Dim As Single count, vol
    Shared As Long starScape

    virtual = _NewImage(1280, 720, 32)
    _MouseHide
    For i = 0 To UBound(S): _SndStop S(i): Next i '    kill sounds

    If _FileExists("scores.txt") Then
        Open "scores.txt" For Input As #1
        '   read high scores from file to hiScore array
        For c = 0 To 4
            Input #1, filePlayer, fileScore, fileKillRatio, fileTimeInBox
            HiScore(c).player = filePlayer
            HiScore(c).score = fileScore
            HiScore(c).kRatio = fileKillRatio
            HiScore(c).timeInBox = fileTimeInBox
        Next c
    End If

    a$ = "CONGRATS! YOU MADE IT ONTO THE HIGH SCORE BOARD!"
    b$ = "Enter your name below to commemorate this moment forever."
    c$ = "- 15 character max - hit 'RETURN' when done -"
    e$ = "WANT TO PLAY AGAIN? (Press 'Y' or Right-Click for YES)"
    '       check for high score
    If _FileExists("scores.txt") Then
        If Game.score > HiScore(4).score _AndAlso Game.score > 0 Then '  if new score is > lowest HSBoard entry then
            addYrName = _TRUE
            _SndPlay S(20) '                zap sound
        End If
    Else If Game.score > 0 Then '
            addYrName = _TRUE
            _SndPlay S(20)
        End If
    End If
    _KeyClear

    If addYrName Then '                                             print strings
        Cls
        _PutImage , starScape
        Line (0, 0)-(_Width - 1, _Height - 1), C(3), B '            border
        Line (30, 30)-(_Width - 31, _Height - 31), C(3), B
        Paint (10, 10), C(5), C(3)
        _Font MenloBig: Color C(14)
        _PrintString (_Width / 2 - _PrintWidth(a$) / 2, 100), a$
        _PrintString (_Width / 2 - _PrintWidth(b$) / 2, 160), b$
        Color C(3)
        _PrintString (_Width / 2 - _PrintWidth(c$) / 2, 190), c$
        _Display
        toggle = 1
        i = 0
        Do '                                                        name input loop
            _Limit 30
            i = i + 1
            If i Mod 20 = 0 Then toggle = -toggle
            d$ = InKey$
            If d$ = Chr$(13) Then Exit Do '                         return = done
            If d$ = Chr$(8) Then '                                  if backspace is pressed...
                newName$ = Mid$(newName$, 1, Len(newName$) - 1)
            Else If Len(newName$) < 15 Then
                    newName$ = newName$ + d$
                End If
            End If
            Line (480, 285)-(780, 335), C(0), BF '                      erasure box for name
            Line (480, 285)-(780, 335), _RGB32(255, 161, 72, 115), B '  text box outline
            _Font MenloBig: Color C(4)
            _PrintString (_Width / 2 - _PrintWidth(newName$) / 2 - 14, 300), newName$ '     display new name
            If Len(newName$) < 1 Then
                Color C(14)
                _PrintString (_Width / 2 - 40, 300), Chr$(62) '       ">"
                If toggle = 1 Then Line (600, 297)-(617, 320), C(0), BF '   flashing prompt small erase box
            End If
            _Font 16
            _Display
        Loop
        newName$ = _Trim$(Mid$(newName$, 1, 15)) '                          limit to 15 characters
        If Game.cheater Then newName$ = newName$ + " *" '                   new new new <<<<
    End If
    ' load latest results from game play to index 6 in array
    HiScore(5).score = Game.score
    HiScore(5).player = newName$
    HiScore(5).kRatio = Game.killRatio
    HiScore(5).timeInBox = Time.inCage
    d = 5
    '   swap the positions
    If addYrName Then
        For c = 4 To 0 Step -1
            If HiScore(d).score > HiScore(c).score Then
                Swap HiScore(d).score, HiScore(c).score
                Swap HiScore(d).player, HiScore(c).player
                Swap HiScore(d).kRatio, HiScore(c).kRatio
                Swap HiScore(d).timeInBox, HiScore(c).timeInBox
                d = d - 1
            Else Exit For
            End If
        Next c
    End If
    '   write adjusted rankings to file
    If _FileExists("scores.txt") Then Close #1

    If addYrName Then
        Open "temp.txt" For Output As #2 '
        If _FileExists("scores.txt") Then Kill "scores.txt"
        For c = 0 To 4
            Write #2, HiScore(c).player, HiScore(c).score, HiScore(c).kRatio, HiScore(c).timeInBox '
        Next c
        Close #2
        Name "temp.txt" As "scores.txt" '                       tidy up
    End If

    If _FileExists("temp.txt") Then Kill "temp.txt" '           <<<<<<<<<<
    '   display results to virtual screen for reuse below
    If HiScore(0).score = 0 Then Exit Sub '                     skip displaying of high score if it's all zeros

    _Dest virtual
    Cls
    _PutImage , starScape
    Line (350, 150)-(940, 375), C(8), B
    Line (347, 147)-(943, 378), C(10), B
    Line (344, 144)-(946, 381), C(9), B
    _Font MenloBig
    Color C(9)
    _PrintString (_Width / 2 - _PrintWidth("HIGH SCORE BOARD") / 2, 90), "HIGH SCORE BOARD"
    _Font Menlo: Color C(14)
    _PrintMode _KeepBackground
    _PrintString (365, 172), "  Player" + Space$(11) + "     Score" + "          Kill%       Cage Time"
    Color C(4)
    _Font 16 '                                                  CAN'T USE ANY OLD FONT WITH PRINT USING!! <<<< !!

    For c = 0 To 4
        Locate 14 + c * 2, 48
        Print c + 1
        Locate 14 + c * 2, 50
        Print ") "; HiScore(c).player
        Locate 14 + c * 2, 74
        Print Using "#####"; HiScore(c).score
        Locate 14 + c * 2, 91
        Print Using "###%"; HiScore(c).kRatio
        Locate 14 + c * 2, 108
        minutes = Int(HiScore(c).timeInBox / 60): seconds = HiScore(c).timeInBox Mod 60
        If seconds < 10 Then secs$ = "0" + _Trim$(Str$(seconds)) Else secs$ = _Trim$(Str$(seconds))
        Print Using "#"; minutes;: Print ":"; secs$ '
    Next c
    If Game.cheater Then '                                      cheaters get labeled...
        Locate 26, 61
        Print "*";: Color C(14): Print " Extra ships were added with cheat code."
    End If
    _Display '
    _Dest 0 ' --------------------->
    Cls '
    For i = 255 To 0 Step -4 '                                  fade in scene
        _Limit 120 '
        _PutImage , virtual
        Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  increase black box transparency
        _Display
    Next
    _SndStop S(28): _SndVol S(28), .0005: _SndLoop S(28) '      silence & restart harvest loop   ' was .001
    count = -140 '                                              put alien off-left edge
    _KeyClear: _Font Menlo

    Do
        Cls
        While _MouseInput: Wend
        If _MouseButton(1) Then Exit Do
        _PutImage , virtual '                                   highScore table and background
        count = count + 1.35
        _PutImage (-80 + count, 560), I(2) '                    alien ship image
        If count > 1450 Then count = -100
        If vol < .058 Then vol = vol + .0005: _SndVol S(28), vol '  fade in sound

        '   Show player's stats if it's not a high score
        minutes = Int(Time.inCage / 60): seconds = Time.inCage Mod 60 '
        If seconds < 10 Then secs$ = "0" + _Trim$(Str$(seconds)) Else secs$ = _Trim$(Str$(seconds)) '   new <<<< get clock to look right
        i = _PrintWidth(Str$(Game.score)) + _PrintWidth("1:26") + _PrintWidth(Str$(Game.killRatio))
        If Not addYrName Then
            Color C(14)
            _PrintString (_Width / 2 - 220 - i / 2, _Height / 2 + 50), "> YOUR STATS >   Score: " + Str$(game.score)_
             + "   Kill%: " + Str$(game.killRatio) + "%   Cage Time: " + _Trim$(Str$(minutes)) + ":" + secs$ '          new <<<<
        End If
        Color C(10)
        _PrintString (_Width / 2 - _PrintWidth(e$) / 2, _Height / 2 + 100), e$ '    ** PLAY AGAIN? **
        k = k + 1
        If k > 50 Then '                                                            attention-grabbing bar
            Line (_Width / 2 - _PrintWidth(e$) / 2, _Height / 2 + 120)_
            -((_Width / 2 + _PrintWidth(e$) / 2) - 7, _Height / 2 + 120), C(4)
            If k > 100 Then k = 0
        End If
        d$ = InKey$
        If _MouseButton(2) _OrElse d$ = "y" _OrElse d$ = "Y" Then '                                  ** RESTART **
            Control.restart = _TRUE
            Game.killRatio = 0 '                                        gotta zero these out!
            Time.inCage = 0
            SoundOff
            Exit Do
        ElseIf d$ <> "" Then SoundOff: Exit Do
        End If

        Line (0, 0)-(_Width - 1, _Height - 1), C(3), B '                blue border
        Line (24, 24)-(_Width - 25, _Height - 25), C(3), B
        Paint (10, 10), C(5), C(3)
        _Display
        _Limit 45
    Loop

    For i = 0 To 255 Step 4
        Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '          quick fade out
        SndFade2 S(28), -.0006, 0, .00034, 0 '
        _Display
        _Limit 60 '
    Next
    _Font 16
    _FreeImage virtual '
End Sub
' -----------------------------------------
Sub PopUp ()

    Shared As Integer popCount
    Static As _Byte initd, painted, count '
    Dim a$, e%

    If Control.clearStatics Then
        initd = _FALSE
        count = 0
        painted = _FALSE
        Exit Sub
    End If

    KillNoises: Do: e% = _MouseInput: Loop Until e% = 0 '   kill thruster sounds & clear mouse input
    If Not initd Then KillChecks: initd = _TRUE ' <<<< PUTTING A MOUSEMOVE COMMAND HERE CAUSES POPUP TO STAY POPPED UP - forever!
    ' slow & stop game play while poppedUp
    If FPS > 10 Then FPS = FPS - 1
    If FPS <= 10 Then Control.hold = _TRUE '
    a$ = "ARE YOU SURE YOU WANT TO EXIT?"

    If Control.hold Then
        If count < 10 Then count = count + 1 '      use 'count' to track cycles, paint popUp only once after the hold so it's translucent not solid red
        While _MouseInput: Wend '                   needs mouseinput cuz main loop is on hold
        MX = _MouseX: MY = _MouseY
    End If
    If count < 2 Then '                             popUp painter
        _Font ModernBigger
        If popCount < 254 Then popCount = popCount + 6
        Line (_Width / 2 - 200, _Height / 2 - 60)-(_Width / 2 + 200, _Height / 2 + 100), C(15), B
        If Not Control.hold Then Paint (_Width / 2, _Height / 2), _RGB32(255, 0, 0, 40), C(15)
        If Control.hold _AndAlso Not painted Then Paint (_Width / 2, _Height / 2), _RGB32(255, 0, 0, 40), C(15): painted = _TRUE
        Color C(14): _PrintString (_Width / 2 - _PrintWidth(a$) / 2, _Height / 2 - 40), a$
        If Not Sb.doSaucers Then
            Color _RGB32(0, 255, 0, popCount)
        Else Color C(4)
        End If

        Line (_Width / 2 - 150, _Height / 2)-(_Width / 2 - 30, _Height / 2 + 30), C(15), B '        yes / no boxes
        Line (_Width / 2 + 30, _Height / 2)-(_Width / 2 + 150, _Height / 2 + 30), C(15), B '
        Line (_Width / 2 - 150, _Height / 2 + 50)-(_Width / 2 - 30, _Height / 2 + 80), C(15), B '   back 2 intro button
        Line (_Width / 2 + 30, _Height / 2 + 50)-(_Width / 2 + 150, _Height / 2 + 80), C(15), B '   settings button
        _PrintString (_Width / 2 - 103, _Height / 2 + 10), "YES"
        _PrintString (_Width / 2 + 80, _Height / 2 + 10), "NO"
        _PrintString (_Width / 2 - 142, _Height / 2 + 60), "INTRO SCREEN"
        _PrintString (_Width / 2 + 57, _Height / 2 + 60), "SETTINGS"
        If Sb.doSaucers Then _PutImage , ViewScreen
        _Display
    End If

    If _MouseButton(1) Then '                                                ** MOUSE INPUT **
        If MY > _Height / 2 - 2 _AndAlso MY < _Height / 2 + 32 Then
            If MX > _Width / 2 - 152 _AndAlso MX < _Width / 2 - 28 Then '            YES button
                Paint (_Width / 2 - 120, _Height / 2 + 10), C(3), C(15)
                _Display
                _Delay .1
                WrapUp: System
            Else If MX > _Width / 2 + 28 _AndAlso MX < _Width / 2 + 152 Then '  '    NO button
                    Paint (_Width / 2 + 120, _Height / 2 + 10), C(3), C(15)
                    _Display
                    _Delay .1
                    _MouseHide
                    Sb.doPopUp = _FALSE: Control.pop = _FALSE
                    If Not Sb.doFF _AndAlso Not Sb.doSaucers Then TurnOnChecks
                    Flag.speedUp = _TRUE
                    Control.hold = _FALSE
                    initd = _FALSE: painted = _FALSE
                    popCount = 0: count = 0
                    SoundOn
                End If
            End If
        End If

        If MY > _Height / 2 + 48 _AndAlso MY < _Height / 2 + 82 Then
            If MX > _Width / 2 - 152 _AndAlso MX < _Width / 2 - 28 Then '            INTRO button
                Paint (_Width / 2 - 100, _Height / 2 + 60), C(3), C(15)
                _Display
                _Delay .1
                Control.hold = _FALSE: Sb.doPopUp = _FALSE
                Control.pop = _FALSE
                popCount = 0: count = 0
                initd = _FALSE: painted = _FALSE
                SoundOff: SplashPage
            Else
                If MX > _Width / 2 + 28 _AndAlso MX < _Width / 2 + 152 Then '        SETTINGS button
                    Paint (_Width / 2 + 50, _Height / 2 + 60), C(3), C(15)
                    _Display
                    _Delay .1
                    Control.hold = _FALSE '
                    Sb.doPopUp = _FALSE
                    Control.pop = _FALSE
                    popCount = 0: count = 0
                    initd = _FALSE: painted = _FALSE
                    SoundOff: Settings
                End If
            End If
        End If
    End If
    If Flag.landingTime _AndAlso Not Sb.doFF _AndAlso Not Sb.doPopUp _AndAlso Not Ship.landed Then '   put the ship back at the top    <<<< THIS ISN'T BEHAVING RIGHT!!! <<<<<<<<<
        Ship.x = CENTX: Ship.y = 20
        Ship.Vx = 0: Ship.Vy = 0: Ship.course = 0
    End If
    _Font 16: _KeyClear '
End Sub
' -----------------------------------------
Sub SoundOff ()
    Dim As Integer c
    For c = 15 To UBound(S): _SndStop S(c): Next c
    For c = 1 To UBound(VO) - 3: _SndStop VO(c): Next c
End Sub
' -----------------------------------------
Sub SoundOn () '
    If Sb.doRocks Then _SndLoop S(28) '
    If Sb.doComets Then
        _SndLoop S(15): _SndLoop S(29)
    End If
    If Sb.doGrid Then _SndLoop S(17)
    If Flag.landingTime Then _SndLoop S(30)
    If Sb.doSaucers Then _SndLoop S(31)
    If Sb.doFF Then _SndLoop S(32)
End Sub
' -----------------------------------------
Sub CircleFill (CX As Integer, CY As Integer, R As Integer, C As _Unsigned Long) '  Thanx to S.McNeill & the QB64pe community for this
    'CX = center x coordinate ' CY = center y coordinate 'R = radius ' C = fill color
    Dim Radius As Integer, RadiusError As Integer
    Dim X As Integer, Y As Integer
    Radius = Abs(R)
    RadiusError = -Radius
    X = Radius
    Y = 0
    If Radius = 0 Then PSet (CX, CY), C: Exit Sub
    Line (CX - X, CY)-(CX + X, CY), C, BF
    While X > Y
        RadiusError = RadiusError + Y * 2 + 1
        If RadiusError >= 0 Then
            If X <> Y + 1 Then
                Line (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                Line (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            End If
            X = X - 1
            RadiusError = RadiusError - X * 2
        End If
        Y = Y + 1
        Line (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        Line (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    Wend
End Sub
' -----------------------------------------
Function IsVOPlaying%% '                    is any voice-over playing already?
    Dim As _Byte VOPlaying
    Dim As Integer c
    VOPlaying = _FALSE '                     assume false to start
    c = 0
    Do
        c = c + 1
        If _SndPlaying(VO(c)) Then VOPlaying = _TRUE
    Loop Until c = UBound(VO)
    IsVOPlaying%% = VOPlaying
End Function
' -----------------------------------------
Sub PlayLateVO '                            play VO after timer3 delay
    Shared As Long timer3
    Shared As _Byte delayVO
    If delayVO <> 29 Then
        _SndPlay VO(delayVO)
    Else
        _SndPlay VO(29) '               ** packaged sounds ** gotta play them simultaneously
        Select Case Ship.inventory '    "ship destroyed..."
            Case -1: _SndPlay VO(30) '  0
            Case 0: _SndPlay VO(30) '   0
            Case 1: _SndPlay VO(31) '   1
            Case 2: _SndPlay VO(32) '   2
            Case 3: _SndPlay VO(35) '   3
            Case 4: _SndPlay VO(38)
            Case 5: _SndPlay VO(39)
            Case 6: _SndPlay VO(40)
            Case 7: _SndPlay VO(41)
            Case 8: _SndPlay VO(42)
            Case 9: _SndPlay VO(47)
        End Select
        _SndPlay VO(28) '               remaining
    End If
    Timer(timer3) Off
End Sub
' -----------------------------------------
Sub PrioritizeVO (PVO As _Byte) '           kill other VOs, play Priority Voice Over
    Dim As _Byte c
    For c = 1 To UBound(VO)
        If _SndPlaying(VO(c)) Then _SndStop VO(c)
    Next c
    _SndPlay VO(PVO) '
End Sub
' -----------------------------------------
Sub BuyIn ()

    Dim a$, b$, j$, e%
    Shared As Long timer3, timer4
    Static As _Byte done
    Static As Integer c, d '

    If Control.clearStatics Then done = _FALSE: Exit Sub
    KillNoises: Do: e% = _MouseInput: Loop Until e% = 0 '   turn off thruster noises & clear mouse input
    a$ = "YOU USED UP ALL YOUR DRONES!"
    b$ = "DO YOU WANT TO BUY ANOTHER SHIP? (y/n)  >> COST: 1000 POINTS! <<"
    _Limit 50
    _Font MenloBig: Color C(14)
    Timer(timer4) Off: Timer(timer3) Off
    If Not done Then
        _PrintString (_Width / 2 - (_PrintWidth(a$) / 2), _Height / 2), a$
        _SndPlay S(0)
        If Game.score > 1000 Then
            _Font Menlo: Color C(4)
            _PrintString (_Width / 2 - (_PrintWidth(b$) / 2), _Height / 2 + 100), b$
        End If
        done = _TRUE
    End If

    If Game.score > 1000 Then '
        d = d + 1
        j$ = InKey$
        If d > 500 Then j$ = "n" '                  if no response, then end game
        If j$ = "y" _OrElse j$ = "Y" Then '              restart game
            Ship.inventory = Ship.inventory + 1 '   bestow ship
            Game.score = Game.score - 1000 '        subtract 1000 points
            Ship.power = 100: Ship.shields = 100
            Sb.doBuyIn = _FALSE
            _SndPlay S(13)
            TurnOnChecks
            c = 0: d = 0: j$ = "": done = _FALSE
            Control.hold = _FALSE '
        ElseIf j$ = "n" _OrElse j$ = "N" Then '
            Sb.doBuyIn = _FALSE
            Ship.inventory = 0
            Control.endIt = _TRUE '
            c = 0: d = 0: done = _FALSE
        End If
    Else c = c + 1
    End If
    If c > 170 Then '           wait a sec then endGame sub -> go to high score board
        Sb.doBuyIn = _FALSE
        Ship.inventory = 0
        Control.endIt = _TRUE '
        c = 0: d = 0: done = _FALSE
    End If
End Sub
' -----------------------------------------
Sub Gauntlet () '

    Dim As Single i
    Dim As Integer shipAng
    Shared As Sector sector()
    Shared As particle n(), e(), e2(), sou(), w()
    Shared As Long t1, t2, t3, t4, t5, interval, starScape, shipImg
    Shared As _Byte gauntletFlag(), prezSector, played
    Shared As String shipType()
    Static As Single c, d
    Static As _Byte initd, captured, said
    Static As Long start

    If Control.clearStatics Then
        c = 0: d = 0
        initd = _FALSE
        captured = _FALSE
        said = _FALSE
        Exit Sub
    End If

    If Not initd Then '                                             intro transition
        Flag.highlight = _TRUE
        Ship.charging = _TRUE '
        CoAng = -Ship.course - 90: shipAng = -CoAng - 90 '          adjust ship numbers
        SoundOff: _SndLoop S(46) '                                  spookyLoop
        played = _FALSE: QuickSound 8 '
        rock(Target).x = Ship.x: rock(Target).y = Ship.y '
        For i = 0 To 248 '                                          fade out scene
            _Limit Game.speed '
            Cls
            _SndVol S(46), c
            c = c + .00022 '
            _PutImage , starScape
            Ship.speed = Ship.speed + .1 '                          accelerate away
            Ship.x = Cos(_D2R(CoAng)) * Ship.speed + Ship.x '
            Ship.y = Sin(_D2R(CoAng)) * Ship.speed + Ship.y
            PReset (rock(Target).x, rock(Target).y), C(3) '         rock drop
            Draw "TA=" + VarPtr$(CoAng) + rock(Target).kind '       spins rock too
            PSet (rock(Target).x, rock(Target).y), C(0) '           kill dot in middle <<<<
            If c > .005 Then Paint (rock(Target).x, rock(Target).y), C(0), C(3) ' was .008
            rock(Target).y = rock(Target).y + 1.25 '                drop the rock
            PReset (Ship.x, Ship.y), Ship.col
            Draw "TA=" + VarPtr$(shipAng) + shipType(2) '           draw ship w/ thruster
            Paint (Ship.x, Ship.y - 1), C(3), Ship.col
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  fade box
            CoAng = CoAng - 1: shipAng = -CoAng - 90 '              NEW, CHANGE COURSE AS YOU FLY ON AUTO-PILOT
            _Display
            _SndVol S(8), .1 - c * 2.5
        Next

        _SndStop S(8): _SndVol S(8), .1 '                           reset thruster volume
        For i = 255 To 0 Step -4 '                                  fade in gauntlet scene
            _Limit 45 '
            _PutImage , I(26) '                                     gauntlet
            _PutImage (65, 620), I(27) '                            diamond
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            _Display
        Next
        _Delay .4
        ThreeTimersOn: Timer(interval) On '           start timers
        Flag.harpooned = _FALSE
        Flag.doRockMask = _FALSE
        start = Timer
        Timer(t3) On '                              turns on north blaster first, then east2 below
        prezSector = 1 '                            set start sector
        Ship.x = 1279: Ship.y = 600 '               put ship in sector1
        Ship.course = -270: Ship.speed = .9 '       auto pilot course, speed
        Do: c = _MouseInput: Loop Until c = 0 '     clear mouse input  <<<<
        initd = _TRUE: c = 0
        Ship.charging = _FALSE '
        _SndPlay VO(46)
    End If
    ' -------------------                                               render front-end
    If Timer - start > 1.15 Then Timer(t5) On '                         start east2 blaster staggered with north
    d = d + .2
    Circle (1255, 400 - d * 2.6), 4, _RGB32(255, 110, 225) '            bubbles in magma on right
    Paint (1255, 400 - d * 2.6), _RGB32(255, 110, 255, 225 - d * 1.5), _RGB32(255, 110, 225)
    Circle (1265, 380 - d * 2.7), 3, _RGB32(255, 100, 255)
    Paint (1265, 380 - d * 2.7), _RGB32(255, 100, 255, 225 - d * 2), _RGB32(255, 100, 255)
    Circle (1269, 410 - d * 2.4), 3, _RGB32(235, 80, 255)
    Paint (1269, 410 - d * 2.4), _RGB32(235, 80, 255, 225 - d * 2.5), _RGB32(235, 80, 255)
    If d > 180 Then d = 0

    If gauntletFlag(1) Then East1 '                 timed eruptions @ 5 stations
    If gauntletFlag(2) Then South
    If gauntletFlag(3) Then North
    If gauntletFlag(4) Then West
    If gauntletFlag(5) Then East2

    Select Case prezSector '                        navigation and impact checking
        Case 1: Sector1
        Case 2: Sector2
        Case 3: Sector3
        Case 4: Sector4
        Case 5: Sector5
        Case 6: Sector6
        Case 7: Sector7
        Case 8: Sector8
    End Select
    If prezSector = 6 Then
        SndFade2 S(46), -.0002, 0, .022, 0 '
        If Not captured Then
            If Ship.x > 50 _AndAlso Ship.x < 80 _AndAlso Ship.y > 605 _AndAlso Ship.y < 635 Then
                _SndPlay S(14) '                    harpoon sound
                _SndPlay S(18) '                    booty sound
                Game.score = Game.score + 1200 '    big points
                Flag.highlight = _FALSE
                captured = _TRUE
                Flag.shutFrontDoor = _FALSE
            End If
        End If
    End If
    If Flag.highlight Then '
        c = c + .36
        Circle (81, 632), 10 + c, _RGB32(255, 190, 25, 180 - c * 5.5) ' highlight diamond - not captured
        If c > 35 Then c = 0
    Else _PutImage (Ship.x - 20, Ship.y - 10), I(27) '          else diamond captured
        CoAng = -CoAng - 90
        PReset (Ship.x, Ship.y), Ship.col
        Draw "TA=" + VarPtr$(CoAng) + Ship.kind '               draw ship again so it's on top
        Paint (Ship.x, Ship.y - 1), C(3), Ship.col
        If Not said Then _SndPlay VO(45): said = _TRUE '         "exit left side"
    End If
End Sub
' -------------------
Sub North () '                  # 3, a repeater
    Shared As particle n()
    Static As Integer c
    Static As _Byte initd, reset_values, played '           Thanks to Steve McNeill for showing me how to streamline this routine
    Shared As Long t3 '                                     instead of three separate loops, one big one...
    Shared As _Byte gauntletFlag()

    If Control.clearStatics Then initd = _FALSE: c = 0: Exit Sub
    If Not initd Then reset_values = _TRUE: played = _FALSE: initd = _TRUE
    If Not played Then _SndPlayCopy S(41), .02: played = _TRUE
    c = -1
    Do
        c = c + 1
        If reset_values Then '                              init particles
            n(c).x = 561
            n(c).y = c * -5 + 146
            n(c).Vx = 0
            n(c).Vy = 9 + (Rnd - Rnd) / 4
            n(c).brightness = 255
        End If
        n(c).x = n(c).x + n(c).Vx '                         move em
        n(c).y = n(c).y + n(c).Vy
        If n(c).y > 136 _AndAlso n(c).y < 146 Then n(c).Vx = (Rnd - Rnd) * 4 '
        If n(c).y > 150 Then If n(c).brightness > 1 Then n(c).brightness = n(c).brightness - 12 '
        If n(c).y > 151 _AndAlso n(c).y < 300 Then
            If c Mod 2 = 0 Then
                Circle (n(c).x, n(c).y), 2, _RGB32(255, 90, 0, n(c).brightness) '       draw em
            Else Circle (n(c).x, n(c).y), 1, _RGB32(225, 180, 255, n(c).brightness)
            End If
        End If
    Loop Until c = UBound(n)

    If n(UBound(n)).y > 200 Then '
        reset_values = _TRUE
        initd = _FALSE
        gauntletFlag(3) = _FALSE
    Else reset_values = _FALSE
    End If
End Sub
' -------------------
Sub East1 () '                  # 1

    Static As Integer c
    Static As _Byte initd, reset_values, played
    Shared As Long t1
    Shared As particle e()
    Shared As _Byte gauntletFlag()

    If Control.clearStatics Then initd = _FALSE: c = 0: Exit Sub
    If Not initd Then reset_values = _TRUE: played = _FALSE: initd = _TRUE
    If Not played Then _SndPlayCopy S(43), .006, 1: played = _TRUE '         stereo right channel
    c = -1
    Do
        c = c + 1
        If reset_values Then
            e(c).x = c * 5 + 1004 '
            e(c).y = 472 '
            e(c).Vx = -13 - (Rnd - Rnd) / 2
            e(c).Vy = 0
            e(c).brightness = 255
        End If
        e(c).x = e(c).x + e(c).Vx
        e(c).y = e(c).y + e(c).Vy
        If e(c).x < 1004 _AndAlso e(c).x > 994 Then e(c).Vy = (Rnd - Rnd) * 2.9 ' was 2.3
        If e(c).x < 1000 Then If e(c).brightness > 1 Then e(c).brightness = e(c).brightness - 7 '
        If e(c).x < 1001 _AndAlso e(c).x > 630 _AndAlso e(c).y < 520 Then
            If c Mod 2 = 0 Then '
                Circle (e(c).x, e(c).y), 1, _RGB32(255, 255, 0, e(c).brightness)
            Else Circle (e(c).x, e(c).y), 2, _RGB32(255, 152, 33, e(c).brightness)
            End If
        End If
    Loop Until c = UBound(e)

    If e(UBound(e)).x < 800 Then
        reset_values = _TRUE
        initd = _FALSE
        Timer(t1) Off: gauntletFlag(1) = _FALSE
    Else reset_values = _FALSE
    End If
End Sub
' ------------------
Sub East2 () '                  # 5, a repeater
    Shared As particle e2()
    Static As Integer c
    Static As _Byte initd, reset_values, played
    Shared As _Byte gauntletFlag()

    If Control.clearStatics Then initd = _FALSE: c = 0: Exit Sub
    If Not initd Then reset_values = _TRUE: played = _FALSE: initd = _TRUE
    If Not played Then _SndPlayCopy S(42), .0094, -.7: played = _TRUE '      stereo left channel
    c = -1
    Do
        c = c + 1
        If reset_values Then
            e2(c).x = c * 5 + 301 '
            e2(c).y = 444 '
            e2(c).Vx = -10 - (Rnd - Rnd) / 4
            e2(c).Vy = 0
            e2(c).brightness = 255
        End If
        e2(c).x = e2(c).x + e2(c).Vx
        e2(c).y = e2(c).y + e2(c).Vy
        If e2(c).x < 300 _AndAlso e2(c).x > 290 Then e2(c).Vy = (Rnd - Rnd) * 6
        If e2(c).x < 305 Then If e2(c).brightness > 1 Then e2(c).brightness = e2(c).brightness - 13 '
        If e2(c).x < 298 _AndAlso e2(c).x > 150 Then
            If c Mod 2 = 0 Then '
                Circle (e2(c).x, e2(c).y), 1, _RGB32(255, 205, 155, e2(c).brightness)
            Else Circle (e2(c).x, e2(c).y), 2, _RGB32(255, 72, 33, e2(c).brightness)
            End If
        End If
    Loop Until c = UBound(e2)

    If e2(UBound(e2) - 30).x < 0 Then
        reset_values = _TRUE
        initd = _FALSE
        gauntletFlag(5) = _FALSE
    Else reset_values = _FALSE
    End If
End Sub
' -------------------
Sub South () '                      # 2

    Static As Integer c
    Static As _Byte initd, reset_values, played
    Shared As Long t2
    Shared As particle sou()
    Shared As _Byte gauntletFlag()

    If Control.clearStatics Then initd = _FALSE: c = 0: Exit Sub
    If Not initd Then reset_values = _TRUE: played = _FALSE: initd = _TRUE
    If Not played Then _SndPlayCopy S(44), .005, .7: played = _TRUE
    c = -1
    Do
        c = c + 1
        If reset_values Then
            sou(c).x = 710
            sou(c).y = c * 5 + 551
            sou(c).Vx = 0
            sou(c).Vy = -12 - (Rnd - Rnd) / 4
            sou(c).brightness = 255
        End If
        sou(c).x = sou(c).x + sou(c).Vx
        sou(c).y = sou(c).y + sou(c).Vy
        If sou(c).y < 555 _AndAlso sou(c).y > 545 Then sou(c).Vx = (Rnd - Rnd) * 4 ' was 3
        If sou(c).y < 552 Then If sou(c).brightness > 1 Then sou(c).brightness = sou(c).brightness - 6
        If sou(c).y < 549 _AndAlso sou(c).y > 180 _AndAlso sou(c).x < 766 Then
            If c Mod 2 = 0 Then
                Circle (sou(c).x, sou(c).y), 2, _RGB32(255, 150, 0, sou(c).brightness)
            Else Circle (sou(c).x, sou(c).y), 1, _RGB32(255, 200, 0, sou(c).brightness)
            End If
        End If
    Loop Until c = UBound(sou)

    If sou(UBound(sou)).y < 270 Then ' was 180
        reset_values = _TRUE
        initd = _FALSE
        Timer(t2) Off: gauntletFlag(2) = _FALSE
    Else reset_values = _FALSE
    End If
End Sub
' -------------------
Sub West () '                           # 4

    Static As Integer c
    Static As _Byte initd, reset_values, played
    Shared As Long t4
    Shared As particle w()
    Shared As _Byte gauntletFlag()

    If Control.clearStatics Then initd = _FALSE: c = 0: Exit Sub
    If Not initd Then reset_values = _TRUE: played = _FALSE: initd = _TRUE
    If Not played Then _SndPlayCopy S(45), .02, -1: played = _TRUE
    c = -1
    Do
        c = c + 1
        If reset_values Then
            w(c).x = c * -5 + 127 '
            w(c).y = 234
            w(c).Vx = 14 + (Rnd - Rnd) / 2
            w(c).Vy = 0
            w(c).brightness = 255
        End If
        w(c).x = w(c).x + w(c).Vx
        w(c).y = w(c).y + w(c).Vy
        If w(c).x > 127 _AndAlso w(c).x < 147 Then w(c).Vy = (Rnd - Rnd) * 3.2 '  2.8
        If w(c).x > 130 Then If w(c).brightness > 1 Then w(c).brightness = w(c).brightness - 4.25
        If w(c).x > 127 _AndAlso w(c).x < 770 _AndAlso w(c).y > 175 _AndAlso w(c).y < 300 Then
            If c Mod 2 = 0 Then
                Circle (w(c).x, w(c).y), 2, _RGB32(255, 170, 0, w(c).brightness) '
            Else Circle (w(c).x, w(c).y), 1, _RGB32(255, 250, 0, w(c).brightness)
            End If
        End If
    Loop Until c = UBound(w)

    If w(UBound(w)).x > 700 Then ' was 760
        reset_values = _TRUE
        initd = _FALSE
        Timer(t4) Off: gauntletFlag(4) = _FALSE
    Else reset_values = _FALSE
    End If
End Sub
' -----------------------------------------
Sub Sector1 ()
    Shared As _Byte prezSector
    '                                                   ALL SAFE
    Select Case Ship.x
        Case Is > 1280: Ship.x = 1272: Ship.speed = 0
        Case Is < 826: Ship.x = 826: Ship.speed = 0
    End Select
    Select Case Ship.y
        Case Is > 650: Ship.y = 650: Ship.speed = 0
        Case Is < 531: If Ship.x > 821 _AndAlso Ship.x < 979 Then prezSector = 2 Else Ship.y = 531: Ship.speed = 0 ' through to next sector...
    End Select
End Sub
' -----------------------------------------
Sub Sector2 ()
    Shared As _Byte prezSector, gauntletFlag()
    Shared As Integer boomDelay
    Shared As particle e(), sou()

    Select Case Ship.x
        Case Is > 974: Ship.x = 974: Ship.speed = 0
        Case Is < 634: Ship.x = 634: Ship.speed = 0
    End Select
    Select Case Ship.y
        Case Is > 524: If Ship.x > 822 _AndAlso Ship.x < 979 Then prezSector = 1 Else Ship.y = 524: Ship.speed = 0
        Case Is < 425: If Ship.x > 627 _AndAlso Ship.x < 775 Then prezSector = 3 Else Ship.y = 425: Ship.speed = 0
    End Select

    If gauntletFlag(1) Then '                                   east1 check
        If e(1).x < Ship.x Then '
            If PointInTriangle(Ship.x, Ship.y, 700, 420, 700, 526, 1000, 473) Then '
                If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE '
            End If
        End If
    End If

    If gauntletFlag(2) Then '
        If sou(1).y < Ship.y Then
            If PointInTriangle(Ship.x, Ship.y, 710, 546, 650, 418, 760, 420) Then
                If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE
            End If
        End If
    End If
End Sub
' -----------------------------------------
Sub Sector3 ()
    Shared As _Byte prezSector, gauntletFlag()
    Shared As Integer boomDelay
    Shared As particle sou()
    Select Case Ship.x
        Case Is > 769: If Ship.y > 300 _AndAlso Ship.y < 360 Then
                prezSector = 7
            Else Ship.x = 769: Ship.speed = 0 '                 hide in niche
            End If
        Case Is < 633: Ship.x = 633: Ship.speed = 0
    End Select
    Select Case Ship.y
        Case Is > 420: prezSector = 2
        Case Is < 300: prezSector = 4
    End Select

    If gauntletFlag(2) Then '
        If sou(1).y < Ship.y Then
            If PointInTriangle(Ship.x, Ship.y, 710, 546, 626, 300, 762, 300) Then
                If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE
            End If
        End If
    End If
End Sub
' -----------------------------------------
Sub Sector4 ()
    Shared As _Byte prezSector, gauntletFlag()
    Shared As Integer boomDelay
    Shared As particle w(), sou(), n()

    Select Case Ship.x
        Case Is > 769: Ship.x = 769: Ship.speed = 0
        Case Is < 154: Ship.x = 154: Ship.speed = 0
    End Select '
    Select Case Ship.y '
        Case Is > 295: If Ship.x > 627 _AndAlso Ship.x < 776 Then prezSector = 3
            If Ship.x > 147 _AndAlso Ship.x < 281 Then prezSector = 5
            If Ship.x > 280 _AndAlso Ship.x < 628 Then Ship.y = 295: Ship.speed = 0
        Case Is < 174: If Ship.x > 436 _AndAlso Ship.x < 496 Then prezSector = 8 Else Ship.y = 174: Ship.speed = 0 ' hide in niche
    End Select

    If gauntletFlag(3) Then '
        If Ship.x > 488 _AndAlso Ship.x < 623 Then '
            If n(1).y > Ship.y Then
                If PointInTriangle(Ship.x, Ship.y, 560, 153, 488, 300, 623, 300) Then
                    If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE
                End If
            End If
        End If
    End If
    If gauntletFlag(4) Then '
        If w(1).x > Ship.x _AndAlso Ship.x > 436 Then
            If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE: Exit Sub
        End If
        If w(1).x > Ship.x Then
            If PointInTriangle(Ship.x, Ship.y, 132, 232, 436, 169, 436, 299) Then '
                If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE
            End If
        End If
    End If
End Sub
' -----------------------------------------
Sub Sector5 ()
    Shared As _Byte prezSector, gauntletFlag()
    Shared As Integer boomDelay
    Shared As particle e2()
    Select Case Ship.x
        Case Is > 274: Ship.x = 274: Ship.speed = 0
        Case Is < 154: Ship.x = 154: Ship.speed = 0
    End Select
    Select Case Ship.y
        Case Is > 532: prezSector = 6 '
        Case Is < 300: prezSector = 4
    End Select

    If gauntletFlag(5) Then
        If e2(1).x < Ship.x Then
            If PointInTriangle(Ship.x, Ship.y, 293, 442, 142, 520, 142, 360) Then
                If Not stopCheck Then Timer(boomDelay) On: stopCheck = _TRUE
            End If
        End If
    End If
End Sub
' -----------------------------------------
Sub Sector6 ()
    Dim As Integer i
    Shared As _Byte prezSector '                 ALL SAFE
    Shared As Long timer1

    Select Case Ship.x
        Case 273 To 276: Ship.x = 272: Ship.speed = 0 '   hit right wall
        Case Is < -3: If Flag.highlight Then Ship.x = 5: Ship.speed = 0 ' hit left side w/o diamond
    End Select '

    If (Ship.x > 276 _OrElse Ship.x < -3) _AndAlso Not Flag.highlight Then
        Flag.landingTime = _TRUE
        Sb.doGauntlet = _FALSE: SubFlags(21) = _FALSE
        Flag.showMoonScape = _TRUE
        Flag.fadeIn = _TRUE
        Sb.doShip = _FALSE
        Timer(timer1) On
        GravityFactor = .042 '                                      new new new - add more gravity cuz fat diamond weighs more!
        KillNoises
        Control.hold = _TRUE '
        For i = 1 To 255 Step 4 '                                   fade out gauntlet scene
            _Limit 40 '
            Line (0, 0)-(_Width, _Height), _RGBA(0, 0, 0, i), BF '  decrease black box transparency
            _Display
        Next
    End If
    _SndStop S(46) '                        kill spooky loop if not already done

    Select Case Ship.y
        Case Is > 662: Ship.y = 662: Ship.speed = 0
        Case Is < 543: If Ship.x > 148 _AndAlso Ship.x < 533 Then prezSector = 5 Else Ship.y = 543: Ship.speed = 0
    End Select
End Sub
' -----------------------------------------
Sub Sector7 ()
    Shared As _Byte prezSector '              SAFE_NICHE 1 in Sector 3
    Select Case Ship.x
        Case Is > 802: Ship.x = 802: Ship.speed = 0 '
        Case Is < 775: prezSector = 3
    End Select
    Select Case Ship.y
        Case Is > 355: Ship.y = 355: Ship.speed = 0
        Case Is < 308: Ship.y = 308: Ship.speed = 0
    End Select
End Sub
' -----------------------------------------
Sub Sector8 ()
    Shared As _Byte prezSector '              SAFE_NICHE 2 in Sector 4
    Select Case Ship.x
        Case Is > 489: Ship.x = 489: Ship.speed = 0 '
        Case Is < 443: Ship.x = 443: Ship.speed = 0
    End Select
    Select Case Ship.y
        Case Is > 169: prezSector = 4
        Case Is < 147: Ship.y = 147: Ship.speed = 0
    End Select
End Sub
' -----------------------------------------
Function PointInTriangle%% (X%, Y%, X1%, Y1%, X2%, Y2%, X3%, Y3%) '     Big Thanks to MasterGy for this bit of code!
    Dim D1%, D2%, D3%
    D1% = (X% - X2%) * (Y1% - Y2%) - (X1% - X2%) * (Y% - Y2%) '         is point x,y bounded by triangle formed by other 3 points?
    D2% = (X% - X3%) * (Y2% - Y3%) - (X2% - X3%) * (Y% - Y3%)
    D3% = (X% - X1%) * (Y3% - Y1%) - (X3% - X1%) * (Y% - Y1%)
    PointInTriangle%% = (D1% > 0 _AndAlso D2% > 0 _AndAlso D3% > 0) _OrElse (D1% < 0 _AndAlso D2% < 0 _AndAlso D3% < 0)
End Function
' -----------------------------------------
Sub FlipOnEast1 (): Shared As _Byte gauntletFlag(): gauntletFlag(1) = _TRUE: End Sub
Sub FlipOnSouth (): Shared As _Byte gauntletFlag(): gauntletFlag(2) = _TRUE: End Sub
Sub FlipOnNorth (): Shared As _Byte gauntletFlag(): gauntletFlag(3) = _TRUE: End Sub
Sub FlipOnWest (): Shared As _Byte gauntletFlag(): gauntletFlag(4) = _TRUE: End Sub
Sub FlipOnEast2 (): Shared As _Byte gauntletFlag(): gauntletFlag(5) = _TRUE: End Sub
Sub Delayedboom (): Shared As Integer boomDelay: Timer(boomDelay) Off: ShipBoom: End Sub
Sub ThreeTimersOn (): Shared As Long t1, t2, t4: Timer(t1) On: Timer(t2) On: Timer(t4) On: End Sub
' -----------------------------------------
Sub Fireworks () ' _Title "Fireworks 3 translation to QB64 2017-12-26 bplus"    THANK YOU bplus FOR THIS ROUTINE!
    '                                                                           I used the 1st version - it's short & sweet.
    Const xmax = 1280
    Const ymax = 700
    Type placeType '
        x As Single
        y As Single
    End Type
    Type flareType
        x As Single
        y As Single
        dx As Single
        dy As Single
        c As Long
    End Type
    Dim As Integer flareMax, debrisMax, debrisStack, loopCount, i, nxt, rc, d
    Dim As Single rndcycle, angle, j, k, l
    j = 0: d = 0: k = .12: l = .16
    flareMax = 1000: debrisStack = 0: debrisMax = 5000
    Dim flare(flareMax) As flareType
    Dim burst As placeType
    Shared As debrisType debris()
    Shared As Long starScape
    Shared As Single xScroller

    _SndPlay S(47) '                                cheering
    For i = 1 To 140: KeepScrolling .18: Next i '   pause and scroll along
    _SndPlay S(48) '                                fireworks noises
    While 1
        rndcycle = Rnd * 30
        loopCount = 0
        burst.x = .75 * xmax * Rnd + .125 * xmax
        burst.y = .5 * ymax * Rnd + .125 * ymax
        While loopCount < 7
            Flag.fireworksInProgress = _TRUE
            Cls
            KeepScrolling .4 '             scroll faster during fireworks to account for slowness
            For i = 1 To 200 '              new burst using random old flames to sim burnout
                nxt = Int(Rnd * flareMax)
                angle = Rnd * _Pi(2)
                flare(nxt).x = burst.x + Rnd * 5 * Cos(angle)
                flare(nxt).y = burst.y + Rnd * 5 * Sin(angle)
                angle = Rnd * _Pi(2)
                flare(nxt).dx = Rnd * 15 * Cos(angle)
                flare(nxt).dy = Rnd * 15 * Sin(angle)
                rc = Int(Rnd * 3)
                If rc = 0 Then
                    flare(nxt).c = _RGB32(255, 100, 0)
                ElseIf rc = 1 Then
                    flare(nxt).c = _RGB32(0, 0, 255)
                Else
                    flare(nxt).c = _RGB32(255, 255, 255)
                End If
            Next
            For i = 0 To flareMax
                If flare(i).dy <> 0 Then '  while still moving vertically
                    Line (flare(i).x, flare(i).y)-Step(flare(i).dx, flare(i).dy), _RGB32(98, 98, 98)
                    flare(i).x = flare(i).x + flare(i).dx
                    flare(i).y = flare(i).y + flare(i).dy
                    Color flare(i).c
                    Circle (flare(i).x, flare(i).y), 1
                    flare(i).dy = flare(i).dy + .4 '    add  gravity
                    flare(i).dx = flare(i).dx * .95 '   add some air resistance
                    If flare(i).x < 0 _OrElse flare(i).x > xmax Then flare(i).dy = 0 '   outside of screen
                End If
            Next

            d = d + 1 '                                 <<<< OFF RAMP >>>>
            If d > 120 Then '                           plenty of fireworks
                k = k - .004: l = l - .0053 '           fade out clapping and fireworks sounds
                _SndVol S(47), k '
                _SndVol S(48), l
            End If
            _Display
            _Limit 46 '
            loopCount = loopCount + 1
        Wend
        If debrisStack < debrisMax Then
            For i = 1 To 20
                NewDebris i + debrisStack
            Next
            debrisStack = debrisStack + 20
        End If
        If k < 0 _OrElse l < 0 Then Flag.fireworksInProgress = _FALSE: Exit Sub '               EXIT after a firework cycle
    Wend
End Sub
' ------------------------------
Sub NewDebris (i As Integer)
    Dim As Single c
    Shared As debrisType debris()
    debris(i).x = Rnd * 1280
    debris(i).y = Rnd * 700
    c = Rnd * 255
    debris(i).c = _RGB32(c, c, c)
End Sub
' ------------------------------
Sub KeepScrolling (speed As Single) '                   runs in closed loops - for outro only
    Shared As Long starScape, MoonScape, starScape2
    Shared As Single xScroller
    Dim As Integer spin

    Cls
    _Limit 60
    xScroller = xScroller - speed '                     maintain the end scene on the moon...
    _PutImage (xScroller, 0), starScape '               scroll stars
    _PutImage (1281 + xScroller, 0), starScape2
    If xScroller < -1280 Then xScroller = 0
    _PutImage (Ship.x - 20, Ship.y - 10), I(28) '       diamond                                   *
    _PutImage (0, 530)-(1280, 720), MoonScape '         moon                                      *
    spin = Ship.course '                                                                          *
    PReset (Ship.x, Ship.y), Ship.col '                                                           *
    Draw "TA=" + VarPtr$(spin) + Ship.kind '            ship                                      *
    Paint (Ship.x, Ship.y - 1), C(3), Ship.col '                                                  *
    DriveTruck '                                        truck continuity                          *
    _Display '                                                                                    *
End Sub '                                                                                         *
' -------------------------------------------------------------------------------------------------

