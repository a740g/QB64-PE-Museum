' ******************************************************************************************************************
' * Big thanks to Terry Ritchie, MasterGy, bplus and S.McNeill for bits of code! *  { Project started Feb, 2024 }  *         CHANGE OUT ROTATEIMAGE WITH ROTOZOOM???!! <<<<<<<<<
' ******************************************************************************************************************
'  The 7 game chapters: Harvest Time, Comets, Rock Field, Landing & Recharge, Saucer Attack, The Cage & The Gauntlet
'
'                                                 >>>> ROCK JOCKEY 2.0.1 <<<<    >  UPGRADES and DEBUGS:
OPTION _EXPLICIT '                                        1/5/25                  -------------------
CONST TRUE = -1, FALSE = NOT TRUE '                     by NakedApe              x  PRACTICE MODE
CONST SWIDTH = 1280, SHEIGHT = 720, LINEX = 140 '                                x  FIX SHIP LOCKUPS AND BUGGY SHIP EXPLOSIONS
CONST CENTX = SWIDTH / 2, CENTY = SHEIGHT / 2 '                                  x  DO GAMESPEED OPTIONS, SLOW, MED, FAST
DIM mainScreen AS LONG '                                                         x  PUT (NEARLY) ALL FLAGS INTO ARRAYS OR UDTs
mainScreen = _NEWIMAGE(SWIDTH, SHEIGHT, 32) '                                    x  FIX POINTER SHOWING ERROR using _MouseShow then _MouseHide
SCREEN mainScreen '                                                              x  REWORK THE FLAKY overlapped SOUND FADEOUTS WITH NEW 1&2 SNDFADES
RANDOMIZE TIMER: _FULLSCREEN _SQUAREPIXELS , _SMOOTH '                              >>>> ENABLE JOYSTICK, pending? <<<<
'                        >>>> ^causes non-full screen on Mac laptop <<<<
TYPE hiScore '                                                                   x  MAKE VAR TYPES MORE CONSISTANT, Capitalize Globals
    player AS STRING '
    score AS INTEGER '                                                           x  ADD METEOR SHOWER
    kRatio AS INTEGER '                                                          x  PRIORITIZE SHIP-BOOM PARTICLE FOUNTAIN - green pixels!
    timeInBox AS INTEGER '
END TYPE '                                                                       x  ADD AN EVEN SLOWER MOUSE SENSITIVITY SETTING
'                                                                                X  ADD MOUSE USE ADVISORY - no up and down movement!
TYPE gridRock '                                                                  x  MAKE LANDING AND RECHARGING EASIER --
    x AS SINGLE '
    y AS SINGLE '                                                                x  IMPROVE RETRO THRUSTER STEERING -----
    rotAng AS INTEGER '                                                          x  NO GOLD ROCKS @ EDGES
    col AS _UNSIGNED LONG '                                                      x  MAKE KEY STATIC VARIABLES RESETTABLE FOR ROUND 2 / NEW GAME
    speed AS SINGLE '                                                            x  ADD BIG HINT TO PUZZLE AFTER 60 SECS w/ no progress
    yJiggle AS _BYTE '
    special AS _BYTE '                                                           x  FIX DOUBLE BOOMS @ COMETS ISSUE
    rotSign AS _BYTE '
    alive AS _BYTE '
END TYPE '
'                                                                                x  ADD THE GAUNTLET: Inside The Old Diamond Mine on Volcano Rock
TYPE comet '
    kind AS STRING '                                                             x  FIX ADJUSTABILITY OF MAXROCKS AND MAXCOMETS
    x AS SINGLE '                                                                x  ADD OPTION TO BUY ANOTHER DRONE, "BuyIn" sub
    y AS SINGLE '                                                                x  ADD STAR/SCREEN SCROLLING TO LANDING TIME
    Vx AS SINGLE '
    Vy AS SINGLE '
    radius AS SINGLE '
    rotSpeed AS SINGLE '                                                         x  MAKE SETTINGS PAGE MORE PRESENTABLE, ADD DEFAULT VISIT @ START
    rotAng AS INTEGER '
    rotSign AS _BYTE ' -1, 0, 1  clockwise, no rotation, C-clockwise             x  ADD <PLAY AGAIN?> AT END
    alive AS _BYTE
    col AS _UNSIGNED LONG '      body color                                      x  STAGGER GRID BETTER
    edge AS _UNSIGNED LONG '     outline color
END TYPE '
'                                                                                x  ADJUST SCORE BY DIFFICULTY - MORE POINTS FOR FASTER PLAY
TYPE ship '                                                                                                    - FEWER POINTS FOR EASIER
    kind AS STRING '
    x AS SINGLE '
    y AS SINGLE '
    Vx AS SINGLE
    Vy AS SINGLE
    speed AS SINGLE
    power AS SINGLE
    chargeDelta AS SINGLE
    course AS INTEGER '         vector angle for ship
    col AS _UNSIGNED LONG '
    radius AS _BYTE
    landed AS _BYTE
    charging AS _BYTE
    charged AS _BYTE
    inventory AS _BYTE
    shields AS SINGLE
    lapped AS _BYTE
    detached AS _BYTE
    blownUp AS _BYTE
END TYPE

TYPE rock
    kind AS STRING
    x AS SINGLE
    y AS SINGLE
    Vx AS SINGLE '              vector pairs for rocks
    Vy AS SINGLE
    speed AS SINGLE
    size AS _BYTE '
    rotation AS _BYTE
    alive AS _BYTE '
    stayPainted AS _BYTE
    rotDir AS STRING
    radius AS INTEGER
    spinAngle AS INTEGER
    spinSpeed AS INTEGER '      0, 1, 2
    col AS _UNSIGNED LONG
END TYPE

TYPE XYPair: AS SINGLE x, y: END TYPE
TYPE rect: AS INTEGER x1, y1, x2, y2: END TYPE ' rectangle def
TYPE bInfo: AS INTEGER r, g, b, num: END TYPE '  boom info
TYPE particle: AS SINGLE x, y, Vx, Vy, brightness: END TYPE
TYPE Sector: AS XYPair UL, UR, LL, LR: END TYPE '
TYPE debrisType: x AS SINGLE: y AS SINGLE: c AS LONG: END TYPE

TYPE spark '                    single spark definition
    Location AS XYPair '        location of spark
    Vector AS XYPair '          spark vector
    Velocity AS SINGLE '        velocity of spark (speed)
    Fade AS INTEGER '           intensity of spark
    Lifespan AS INTEGER '       lifespan of spark
END TYPE

TYPE sb '                               SUB toggles: #n controlled by subFlags() array
    doRocks AS _BYTE '      # 1
    doShip AS _BYTE '       # 2
    doFF AS _BYTE '         # 3         force field
    doDeflect AS _BYTE '    # 4
    doGrid AS _BYTE '       # 5
    checkGridCollisions AS _BYTE ' # 6
    checkFSC AS _BYTE '     # 7         check For Ship Collision
    doSparks AS _BYTE '     # 8
    doComets AS _BYTE '     # 9
    checkCometCollisions AS _BYTE '# 10
    trackShields AS _BYTE ' # 11
    go2Space AS _BYTE '     # 12
    rockMoving AS _BYTE '   # NA,       no 13, sequencing excludes this from SELECT CASE in main
    doFlyBy AS _BYTE '      # 14
    goDissolveFF AS _BYTE ' # 15
    doSaucers AS _BYTE '    # 16
    doTruck AS _BYTE '      # NA        ditto on 17
    doInstructs AS _BYTE '  # 18
    doSettings AS _BYTE '   # 19
    doShowers AS _BYTE '    # 20
    doVertGauge AS _BYTE '
    doPopUp AS _BYTE '
    doBuyIn AS _BYTE '
    doGauntlet AS _BYTE '   # 21
END TYPE

TYPE flag '                     event flags
    doRockMask AS _BYTE
    doPractice AS _BYTE
    doAutoShields AS _BYTE
    doCircle AS _BYTE
    shutBackDoor AS _BYTE
    shutFrontDoor AS _BYTE
    harpooned AS _BYTE '
    showMoonScape AS _BYTE
    fadeInRocks AS _BYTE
    landingTime AS _BYTE '      aka gravity based flight with main thrusters on
    detachRock AS _BYTE
    chargeDone AS _BYTE
    reduceGravity AS _BYTE
    regularChecks AS _BYTE '    gravity/landingTime flight vs no gravity/space flight
    fullScreen AS _BYTE
    fullScreenOff AS _BYTE
    speedUp AS _BYTE
    shipBoomDone AS _BYTE
    thrustersOn AS _BYTE
    settingsDone AS _BYTE '
    killFlyBy AS _BYTE
    warn AS _BYTE
    boomInProgress AS _BYTE
    gotPastLanding AS _BYTE
    highlight AS _BYTE
    fadeIn AS _BYTE
    toggle_SqrPix AS _BYTE
END TYPE

TYPE sounds '                   some sound flags from early on
    fadeInComs AS _BYTE '
    fadeOutComs AS _BYTE
    fadeInGRID AS _BYTE
    fadeOutGrid AS _BYTE
    startFFloop AS _BYTE '
END TYPE

TYPE saucer '
    loc AS XYPair
    commands AS STRING '
    action AS STRING
    loopNum AS INTEGER '
    charCount AS INTEGER '
    loopCounter AS INTEGER '
    movesNum AS INTEGER
    aspectSign AS _BYTE '
    rotAngSign AS _BYTE '
    getCommand AS _BYTE
    alive AS _BYTE
    shipRadius AS SINGLE '
    rotAngle AS SINGLE '
    aspect AS SINGLE '
    speed AS SINGLE '
    fillColor AS _UNSIGNED LONG
END TYPE

TYPE bullet '
    Active AS INTEGER '
    x AS INTEGER '
    y AS INTEGER '
    Radius AS INTEGER
    Speed AS SINGLE '
END TYPE

TYPE control
    hold AS _BYTE
    endIt AS _BYTE
    restart AS _BYTE
    clearStatics AS _BYTE
    pop AS _BYTE '          pop up
END TYPE

TYPE time
    overlap AS LONG
    gameStart AS LONG
    comets AS LONG
    grid AS LONG
    ThrustersOff AS LONG
    inCage AS INTEGER
END TYPE

TYPE game '
    round AS _BYTE
    speed AS SINGLE
    score AS INTEGER
    killRatio AS INTEGER
    landingSpeed AS SINGLE
    diff_mult AS SINGLE '   difficulty multiplier
    cheater AS _BYTE
END TYPE
' ------------------------------------------------
DIM AS gridRock matrix(1 TO 20, 1 TO 11)
DIM AS comet comet(1 TO 115) '
DIM AS rect cBox, wBox
DIM AS saucer saucer(12) '
DIM AS Sector sector(1 TO 8)
DIM AS particle n(110), e(130), e2(110), sou(140), w(170)
DIM AS STRING moves(18), j, shipType(1 TO 12), rockType(1 TO 14) '
DIM AS LONG starScape, saucerScape, miniMask, microMask, starScape3 '   images
DIM AS LONG shipImg, starScape2, HDWimg(1 TO 9) '                       images
DIM AS LONG t5, t1, t2, t3, t4, interval '                              timers
DIM AS LONG timer1, timer2, timer3, timer4, inputTime, warnSnd '        timers
DIM AS INTEGER toteSaucers, rockHeading, lockedAngle, spin2, c, shipNum, boomDelay
DIM AS INTEGER popCount, realCourse, diffX, msX, rezX, sparkNum: sparkNum = 10 ' number of sparks to create at a time
DIM AS INTEGER sparkLife, saucerKills, limit, maxComets: maxComets = 90: sparkLife = 25
DIM AS _BYTE sparkCycles, played, delayVO, bounceOffs
DIM AS _BYTE bannerON, closed, gauntletFlag(1 TO 5), prezSector '
DIM AS _UNSIGNED LONG weakWallColor
DIM AS SINGLE xScroller, d, stepper: stepper = 2
DIM debris(5000) AS debrisType '                    fireworks UDT
REDIM Bullet(0) AS bullet, spark(0) AS spark '      dynamic arrays for sparks & bullets
DIM SHARED Control AS control, Sounds AS sounds '   UDTs
DIM SHARED Ship AS ship, Sb AS sb, Flag AS flag '   UDTs
DIM SHARED I(28) AS LONG '                          image array
DIM SHARED C(16) AS _UNSIGNED LONG '                color array
DIM SHARED S(48) AS LONG '                          sound array
DIM SHARED VO(1 TO 47) AS LONG '                    voice-over array
DIM SHARED rock(1 TO 40) AS rock '                  rock array
DIM SHARED HiScore(5) AS hiScore, Time AS time, Game AS game, boomInfo AS bInfo '            more UDTs
DIM SHARED AS _BYTE Target, Resetter(30), OneTimeSnd(4), SubFlags(1 TO 21), stopCheck '      purple rock, bool flag arrays
DIM SHARED AS LONG MoonScape, ViewScreen, Modern, ModernBig, ModernBigger, Menlo, MenloBig ' images, fonts
DIM SHARED AS INTEGER MaxRocks, CoAng, FPS, MX, MY, DTW, DTH: DTW = _DESKTOPWIDTH: DTH = _DESKTOPHEIGHT
DIM SHARED AS SINGLE GravityFactor, MouseSens '
' ------------------------------------------------
starScape3 = _NEWIMAGE(SWIDTH, SHEIGHT, 32) '    *  transfer screen
miniMask = _NEWIMAGE(42, 42, 32) '   for rocks   *  star-blocking masks
microMask = _NEWIMAGE(20, 20, 32) '  for comets  *
_DEST miniMask: CLS: _DEST microMask: CLS: _DEST 0
' ------------------------------------------------      ** STARTUP **
startUp '                                        *  load assets and values
' ------------------------------------------------
timer1 = _FREETIMER '                            *      ** TIMERS **
ON TIMER(timer1, 2) flipOnShip '                 *
timer2 = _FREETIMER '                            *
ON TIMER(timer2, 4.2) flipOnSaucers '            *
timer3 = _FREETIMER '                            *
ON TIMER(timer3, 3.35) playLateVO '              *
timer4 = _FREETIMER '                            *
ON TIMER(timer4, .8) flipOnBuyIn '               *
t1 = _FREETIMER '                                *
ON TIMER(t1, .25) flipOnEast1 '                  *
t2 = _FREETIMER '                                *
ON TIMER(t2, 1.35) flipOnSouth '                 *
t3 = _FREETIMER '                                *
ON TIMER(t3, 2.3) flipOnNorth '   #3 & #5        *
t4 = _FREETIMER '                                *
ON TIMER(t4, 2.4) flipOnWest '                   *
t5 = _FREETIMER '                                *
ON TIMER(t5, 2.3) flipOnEast2 '                  *
interval = _FREETIMER '                          *
ON TIMER(interval, 6) ThreeTimersOn '            *
boomDelay = _FREETIMER '                         *
ON TIMER(boomDelay, .1) delayedboom '            *
' ------------------------------------------------
splashPage '                                     *  ** WELCOME SCREEN **  arcade game style
IF Sb.doInstructs THEN instructions '            *
' >>>> *******************************************  >> ******** MAIN  LOOP ******** << ******************************************* <<<<
DO
    IF Flag.speedUp THEN '                          accelerate game speed after POPUP
        IF FPS <= 61 THEN '
            FPS = FPS + stepper '
        ELSE IF FPS > 60 THEN Flag.speedUp = FALSE
        END IF
        stepper = 2 '
    END IF
    IF Sb.doPopUp THEN _MOUSESHOW ELSE _MOUSESHOW: _MOUSEHIDE '     ** MOUSE POINTER CONTROL **
    ' // MouseHide needs MouseShow first to work in MacOS when a click is made at very top of screen - which activates the pointer //
    IF Flag.fullScreen THEN '
        _FULLSCREEN _SQUAREPIXELS , _SMOOTH '       ** FULLSCREEN SETTINGS **
        Flag.fullScreen = FALSE '                   must be in the main loop or weird mousebutton issues occur in MacOS
    END IF
    IF Flag.fullScreenOff THEN
        _FULLSCREEN _OFF
        _DELAY .25
        _SCREENMOVE DTW / 2 - _WIDTH / 2, DTH / 2 - _HEIGHT / 2
        _TITLE "R o c k   J o c k e y" '
        Flag.fullScreenOff = FALSE
    END IF
    IF Flag.toggle_SqrPix THEN
        IF _FULLSCREEN = 2 THEN
            _FULLSCREEN _OFF: _FULLSCREEN
        ELSE _FULLSCREEN _SQUAREPIXELS , _SMOOTH
        END IF
        Flag.toggle_SqrPix = FALSE
    END IF
    '                                                   ** GAME OVER CHECKS **
    IF Ship.inventory <= -1 THEN '                      ships all gone?
        Sb.doPopUp = FALSE '                            buyIn sub trumps popUp sub
        TIMER(timer4) ON '                              triggers buyIn sub, "wanna buy a ship?"
    END IF
    IF Ship.power < 1 THEN '                            (shields are monitored in the check subs)
        Ship.power = 1
        shipBoom '                                      shipBoom tallies the ship.inventory
        Game.score = Game.score - 100 * Game.diff_mult 'boom penalty
    END IF

    IF NOT Control.hold THEN '                 ************************** ** GAME HOLD LOOP ** ***************************
        CLS
        _LIMIT FPS
        IF (NOT Flag.landingTime AND NOT Sb.doGauntlet) OR Sb.doFF THEN '
            _PUTIMAGE (xScroller, 0), starScape '                   draw software backgrounds for screen scrolling
            IF NOT Control.endIt THEN _PUTIMAGE (1281 + xScroller, 0), starScape2 '
        ELSE IF Flag.landingTime THEN
                xScroller = xScroller - .16 '                       ** SCROLL STARS ** to the left during landingTime
                _PUTIMAGE (xScroller, 0), starScape
                _PUTIMAGE (1281 + xScroller, 0), starScape2
                PCOPY _DISPLAY, starScape3 '                        save display screen for later use
                IF xScroller < -1280 THEN xScroller = 0
            END IF
        END IF

        IF Sb.doGauntlet THEN '
            _PUTIMAGE , I(26) '                                     show gauntletScreen backdrop
            IF Flag.highlight THEN _PUTIMAGE (65, 620), I(27) '     show diamond prize
        END IF

        IF Flag.landingTime AND NOT Sb.doFF THEN '                  ** ROCK DROP LANDING HANDLER **
            IF Ship.x > 468 AND Ship.x < 506 THEN
                IF Ship.y > 563 AND Ship.y < 587 THEN '
                    Flag.doRockMask = FALSE '                                           kill mask near landing spot
                    IF NOT Ship.detached THEN _PUTIMAGE (Ship.x - 23, 535), miniMask '  block stars around landing zone when harpooned
                    IF NOT Ship.landed THEN checkLanding: _SNDPLAY S(2) '               clicks for landing warning, checkLanding determines if landed or not
                ELSE IF NOT Ship.detached THEN Flag.doRockMask = TRUE
                    Ship.landed = FALSE '
                END IF
            ELSE IF NOT Ship.detached THEN Flag.doRockMask = TRUE
                Ship.landed = FALSE
            END IF
            IF NOT Resetter(23) AND Ship.landed AND Ship.Vy = 0 AND Game.round = 1 THEN '
                prioritizeVO 12 '                                               "great landing..."
                Resetter(23) = TRUE '
            END IF
            IF TIMER - Time.ThrustersOff > 2 THEN Flag.thrustersOn = TRUE '     kill thrusters for 2 secs after landing
        END IF

        IF Sb.rockMoving THEN '                                                 speed up to move rock
            FPS = 75 '
            Else If Not sb.doPopUp And Not flag.speedUp And Not sb.doComets And_
            Not flag.landingTime Then FPS = game.speed '                        ** NORMAL GAMESPEED **
        END IF
        IF NOT Sb.rockMoving AND Flag.landingTime AND NOT Sb.doPopUp THEN FPS = Game.landingSpeed
        ' ---------------------------                                           ** FLAG EVENTS **
        IF NOT Control.endIt AND NOT Sb.doSaucers AND NOT Sb.doGauntlet THEN soundCenter '      sound events to check on
        If Not sb.doFlyBy And flag.landingTime And Not_
         flag.killFlyBy And Int(Rnd * 135) = 50 Then sb.doFlyBy = TRUE: subFlags(14) = true '   flyby conditions
        IF NOT Flag.harpooned AND rock(Target).col = C(3) THEN check4Harpoon '  if rock's green then check for harpoon
        ' ---------------------------
        c = 0 '
        DO '                                                                    ** SUB CONTROL **
            c = c + 1 '                                                          * (most subs) *
            IF SubFlags(c) THEN
                SELECT CASE c '
                    CASE 1: rockNav: drawRocks: IF NOT Flag.harpooned THEN check4RockContact ' new, added IF
                    CASE 2: shipControl
                    CASE 3: forceFieldControl
                    CASE 4: deflectFF
                    CASE 5: IF TIMER - Time.grid > 2 THEN runGRID
                    CASE 6: checkShipGRIDCollision
                    CASE 7: check4ShipROCKCollision
                    CASE 8: IF NOT Flag.landingTime THEN blowUp
                    CASE 9: runCOMETS
                    CASE 10: checkShipCOMETCollision
                    CASE 11: autoShields
                    CASE 12: back2Space
                    CASE 14: IF Flag.landingTime AND NOT Sb.doSaucers THEN flyBy
                    CASE 15: dissolveFF
                    CASE 16: saucerControl
                    CASE 18: instructions
                    CASE 19: settings
                    CASE 20: runSHOWERS
                    CASE 21: gauntlet
                END SELECT
            END IF
        LOOP UNTIL c = UBOUND(SubFlags)
        ' ---------------------------
        IF Flag.landingTime AND rock(Target).stayPainted AND NOT Control.endIt AND NOT Sb.go2Space THEN
            _PUTIMAGE (rock(Target).x - 20, rock(Target).y - 20), I(0) ' keep dumped rock image alive during popUp & timer2/post shipBoom
        END IF
        IF Flag.showMoonScape THEN _PUTIMAGE (0, 530)-(1280, 720), MoonScape '  draw moonscape on top, activate truck/beacons
        IF Flag.fadeIn THEN '                                                   ** POST-MOONSCAPE RENDERS **
            _SNDVOL S(30), 0: _SNDLOOP S(30): d = 0 '
            Resetter(15) = TRUE '                                               don't play landWithRock again
            FOR c = 255 TO 0 STEP -6 '   was -5                                 fade in scene after gauntlet
                _LIMIT 80 '
                IF d < .008 THEN d = d + .00016: _SNDVOL S(30), d
                _PUTIMAGE , starScape
                _PUTIMAGE (0, 530)-(1280, 720), MoonScape
                LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, c), BF '          increase black box transparency
                _DISPLAY
            NEXT
            Resetter(11) = TRUE: Resetter(12) = TRUE '                          fixes volume issue w/ restarting S(30)
            Flag.fadeIn = FALSE
            FPS = 5
            Control.hold = FALSE
            Flag.speedUp = TRUE
            stepper = 1
        END IF
        IF Game.round > 1 AND Flag.landingTime AND NOT Flag.boomInProgress THEN '
            _PUTIMAGE (Ship.x - 20, Ship.y - 10), I(28) '       player has diamond @ 2nd landing...
            _PUTIMAGE (0, 530)-(1280, 720), MoonScape '         redraw moonscape to cover diamond image @ landing
        END IF
        IF ((Flag.landingTime AND Sb.doShip) AND (Ship.y > 450 AND Ship.y < 600)) OR (Game.round > 1 AND NOT Flag.boomInProgress) THEN redrawShip '
        IF SubFlags(13) THEN moveTargetRock '                           ^^ above line prevents ship pixel damage from landingZone
        IF Flag.showMoonScape THEN driveTruck
        IF SubFlags(8) AND Flag.landingTime THEN blowUp '       put ship explosions after moonscape putImage during landingTime
        ' ---------------------------
        j = LEFT$(STR$(Ship.speed), 4) '                                ** SHOW GAUGES **
        j = _TRIM$(j)
        IF ship.speed > .1 AND NOT flag.landingTime THEN_
        showHorzGauge 20, 30, ship.speed / 6.05, "SPEED  " + j, _RGB32(255, 83, 255)
        showHorzGauge 20, 62, Ship.power / 100, "POWER  " + STR$(INT(Ship.power)) + "%", _RGB32(61, 255, 78, 220)
        showHorzGauge 20, 94, Ship.shields / 100, "SHIELDS  " + STR$(INT(Ship.shields)) + "%", C(12)
        _FONT Modern: COLOR C(16) '
        IF Ship.inventory > -1 THEN _PRINTSTRING (36, 130), "SHIPS LEFT:" + STR$(Ship.inventory)
        _FONT ModernBigger: COLOR C(14) '
        IF Game.score < 0 THEN Game.score = 0
        IF NOT Flag.doPractice THEN _PRINTSTRING (_WIDTH - 135, 33), "SCORE: " + STR$(Game.score) '  show score during game
        _FONT 16
        IF Flag.landingTime AND NOT Sb.doFF THEN '                      ** SHIP CHARGING LANDING HANDLER **
            IF Ship.x > 757 AND Ship.x < 766 THEN
                IF Ship.y > 568 AND Ship.y < 573 THEN
                    IF Ship.Vy < .65 AND Ship.Vy > 0 THEN '             upside down motion
                        Ship.y = 571 '
                        Ship.x = 761
                        Ship.Vy = 0
                        Ship.course = -180 '                            straighten DOWN the ship
                        redrawShip '                                    charge zone was blacking out some pixels @ landing
                        IF NOT Ship.detached THEN
                            shipBoom
                            prioritizeVO 33 '                          "You can't recharge with the rock attached!"
                            GOTO EXIT_IF ' not hopping out here caused LOCKUPS cuz ship.landed then = TRUE when it's NOT
                        END IF
                        IF NOT Ship.charged THEN '
                            Ship.charging = TRUE
                            Sb.doVertGauge = TRUE '
                        END IF
                        Ship.landed = TRUE ' this shuts down steering/spinning controls except thrusters
                    END IF
                END IF
            END IF
        END IF

        EXIT_IF: '                                                              cheater escape label
        IF NOT Ship.charging THEN Resetter(26) = FALSE: _SNDVOL S(21), .44 '    reset charging sound
        IF NOT Resetter(24) AND Ship.charging AND Ship.power >= 60 THEN
            IF _SNDGETPOS(S(21)) > 2 THEN
                prioritizeVO 14
                Resetter(24) = TRUE '                                charge complete voice over, done once only
            END IF
        END IF

        IF Ship.landed AND NOT Control.endIt THEN '                 ** SHIP LANDED AND CHARGING CONTROLS **
            _PRINTMODE _KEEPBACKGROUND '
            postLanding '                                            check conditions - pretty tricky logic and sequencing here...
            IF Ship.charging AND NOT Ship.charged THEN
                IF Sb.doVertGauge THEN showVertGauge 870, 440 '
                _FONT 8: COLOR C(12)
                _PRINTSTRING (751, 591), "CHARGING"
                IF Ship.power <= 100 THEN Ship.power = Ship.power + Ship.chargeDelta '  charging speed
                IF Ship.shields < 100 THEN Ship.shields = Ship.shields + .22
                quickSound 21 '                                                         charging sounds <<<<
                IF Ship.power >= 99 AND NOT Resetter(26) THEN
                    played = FALSE '                            turns back on thruster sounds in shipControl sub and quicksound sub
                    Ship.charging = FALSE '
                    Resetter(26) = TRUE '
                    Flag.killFlyBy = TRUE '                                                     stop flybys after charging done
                    IF NOT Resetter(27) THEN Game.score = Game.score + (200 * Game.diff_mult) ' points for charging up too!
                    Resetter(27) = TRUE
                END IF
            ELSE
                IF Game.round = 1 THEN postLanding
                _FONT 8: COLOR C(3)
                _PRINTSTRING (463, 595), "LANDED"
            END IF
            _FONT 16
        ELSE IF _SNDPLAYING(S(21)) THEN _SNDSTOP S(21): played = FALSE ' fail safe kill charge sound
        END IF

        IF Flag.reduceGravity AND GravityFactor > 0 THEN '
            GravityFactor = GravityFactor - .0005 '         reduce gravity gently, tho mostly unseen
            IF GravityFactor <= 0 THEN
                Flag.reduceGravity = FALSE
                GravityFactor = .036 '                      reset gravity
            END IF
        END IF '
        '
        IF NOT OneTimeSnd(1) AND Ship.shields < 25 THEN '   shields warning VO reworked
            IF NOT IsVOPlaying THEN '                       don't step on other VOs
                IF NOT _SNDPLAYING(S(23)) THEN '            don't step on heaven sound
                    _SNDPLAY VO(24) '                       played once only, shields are low
                ELSE TIMER(timer3) ON: delayVO = 24 '       turn on VO delay timer, assign VO to play
                END IF
            END IF
            OneTimeSnd(1) = TRUE '
        END IF
        IF NOT OneTimeSnd(2) AND Ship.power < 25 THEN '     power warning VO
            IF NOT IsVOPlaying THEN
                IF NOT _SNDPLAYING(S(23)) THEN
                    _SNDPLAY VO(25)
                ELSE TIMER(timer3) ON: delayVO = 25
                END IF
            END IF
            OneTimeSnd(2) = TRUE '
        END IF
        IF (_SNDPLAYING(VO(24)) OR _SNDPLAYING(VO(25))) AND _SNDPLAYING(S(23)) THEN ' no VO jabber over heaven sound
            _SNDSTOP VO(24): _SNDSTOP VO(25)
        END IF
        _FONT ModernBig: COLOR C(14)
        IF Ship.charged THEN _UPRINTSTRING (694, 510), "PRESS <SPACEBAR> TO EJECT."
        IF bannerON AND Ship.landed THEN _UPRINTSTRING (407, 510), "FLY TO RECHARGE STATION." ELSE bannerON = FALSE
    END IF '
    '           **************************************************** BOTTOM OF GAME LOOP - HOLD POINT ********************************************

    IF NOT closed THEN ' blocks too many F strokes from buffering & causing double buyIn sub calls - can't get _keyclear to work here
        SELECT CASE _KEYHIT '                                               ** USER INPUT **
            CASE 27: IF NOT Flag.doPractice THEN '                  <Esc> key: popUp or exit practice mode
                    Sb.doPopUp = TRUE '                             All this is outside the GAME LOOP, is always ON
                ELSE '                                              after a practice session, set up for game
                    turnOnChecks
                    _SNDPLAY S(3)
                    Flag.doPractice = FALSE
                    _SNDSTOP S(28): _SNDVOL S(28), .0005
                    Resetter(6) = FALSE
                    Ship.speed = 0: Ship.course = 0
                    Ship.x = CENTX: Ship.y = CENTY
                    Ship.power = 100
                    splashPage
                END IF '                                                                                            ** CHEAT KEYS **
            CASE 109, 77: IF Ship.inventory < 4 THEN Ship.inventory = Ship.inventory + 1: Game.cheater = TRUE ' m or M to add MORE ships
            CASE 102, 70: Ship.inventory = Ship.inventory - 1: closed = TRUE: inputTime = TIMER '               f or F for FEWER ships - for testing
            CASE 113, 81: wrapUp: SYSTEM '                                                                      q or Q for quick QUIT
        END SELECT
    END IF
    _KEYCLEAR
    IF TIMER - inputTime > .75 THEN closed = FALSE ' allow INPUT again above / only close after F key to prevent overload
    IF Sb.doPopUp THEN popUp '                                  ** UNSTOPPABLE SUBS **
    IF Sb.doBuyIn THEN buyIn
    IF Control.endIt THEN endGame '
    _FONT 16
    _DISPLAY '
LOOP '            **************************************************** END MAIN *******************************************************

errHandler: CLS: PRINT "There's been an error"; ERR; "on line"; _ERRORLINE: BEEP: _DELAY 5: SYSTEM '                ** ERROR HANDLER **
' -------------------------------------------------------------------------------------------------------------------------------------

SUB startUp () '                                                  ****** SUBS ******

    SHARED AS INTEGER diffX, msX, rezX, maxComets '

    MaxRocks = 10 '                 default 10 rock easy setting
    IF Control.restart THEN Game.round = 0 ELSE Game.round = 1
    loadColors: loadSounds: loadRocks: loadImages: loadFonts
    loadShips: loadVOs: loadMoonScape: loadViewScreen
    assignMoves: assignRocks: initGRID: initCOMETS
    _PRINTMODE _KEEPBACKGROUND
    Flag.thrustersOn = TRUE
    Flag.regularChecks = TRUE
    Flag.fadeInRocks = TRUE '
    Flag.doAutoShields = TRUE
    Flag.doRockMask = TRUE
    Sb.doTruck = TRUE
    Sb.doShip = TRUE: SubFlags(2) = TRUE
    Sb.checkFSC = TRUE: SubFlags(7) = TRUE '
    Sb.doRocks = TRUE: SubFlags(1) = TRUE '
    Time.gameStart = 5
    Game.score = 0
    Game.speed = 60 '               start speed, needed for speedUp to start
    Game.landingSpeed = 60 '        default for medium play
    Game.cheater = FALSE
    Ship.speed = 0
    Ship.shields = 100 '
    Ship.power = 100
    Ship.inventory = 7 '            reserve ships, default 7 - 5 for hard level, 10 for easy
    Ship.blownUp = 0 '              init or reset for new game
    Ship.chargeDelta = .21 '        charge speed
    GravityFactor = .036
    MouseSens = .225 '              initial mouse setting, #2
    msX = 140 '                     #2 (middle) default button positions in Settings
    rezX = 202 '                    fullscreen rez button
    diffX = 133 '                   easy difficulty
    maxComets = 75 '                easy
    Game.diff_mult = .9 '           ditto
END SUB
' -----------------------------------------
SUB resetFlags () '                 to prepare for another round of play or a NEW GAME

    DIM c AS INTEGER

    DO: c = _MOUSEINPUT: LOOP UNTIL c = 0 ' clear mouse input
    FOR c = 0 TO UBOUND(Resetter): Resetter(c) = FALSE: NEXT c '    reset music flags array
    FOR c = 1 TO UBOUND(SubFlags): SubFlags(c) = FALSE: NEXT c '    reset all sub control flags
    Game.round = Game.round + 1 '   advance round number - from 0 for new game or higher for same game...
    Control.restart = FALSE
    Sounds.startFFloop = FALSE
    Ship.landed = FALSE
    Ship.lapped = FALSE
    Ship.detached = FALSE
    Time.overlap = 0 '              overlap cycles for harvest
    Time.gameStart = 5 '            reset start time
    Sounds.fadeInComs = FALSE '     reset comet fader flag
    Sounds.fadeOutComs = FALSE
    Sounds.fadeInGRID = FALSE
    Sounds.fadeOutGrid = FALSE
    Flag.harpooned = FALSE '        new - from startUp
    Flag.chargeDone = FALSE
    Flag.shutBackDoor = FALSE
    Flag.warn = FALSE '             turns on comet fuzzy noise
    Flag.killFlyBy = FALSE '        allow flyBys in all rounds
    Flag.detachRock = FALSE '
    Flag.shutFrontDoor = FALSE
    Flag.shutBackDoor = FALSE
    Flag.showMoonScape = FALSE
    Flag.landingTime = FALSE
    Flag.gotPastLanding = FALSE
    Flag.settingsDone = FALSE '
    Sb.checkFSC = TRUE: SubFlags(7) = TRUE '
    Sb.doShip = TRUE: SubFlags(2) = TRUE
    Sb.doTruck = TRUE
    Sb.doRocks = TRUE: SubFlags(1) = TRUE '
    Sb.doComets = FALSE: Sb.doPopUp = FALSE '                   turn off all chapters just in case
    Sb.doGrid = FALSE: Sb.doSaucers = FALSE: Sb.doFF = FALSE
    IF Control.clearStatics THEN ' zero out static values for new game by running SUBs with clearStats flag ON
        saucerControl: forceFieldControl: endGame: popUp: buyIn '
        deflectFF: dissolveFF: moveTargetRock: runCOMETS: runSHOWERS
        runGRID: flyBy: drawRocks: back2Space: showHorzGauge 0, 0, 0, "x", _RGB32(1)
        showVertGauge 0, 0: initCOMETS: ManageBullets: driveTruck
        gauntlet: north: east1: south: west: east2
        Control.clearStatics = FALSE
    END IF
    initCOMETS: initGRID: assignRocks: killNoises ' <<<< re-init for new game
    RANDOMIZE USING TIMER + 500 '                   a fresh seed for a new GO
END SUB
' -----------------------------------------

SUB shipControl ()

    STATIC AS INTEGER oldY, yCount, screwUps, alpha
    STATIC AS LONG pauseTime, showTime '
    STATIC AS _BYTE said, said2, show
    DIM AS INTEGER spin, tempSpin, cX, antiHeading, dist, complete
    DIM AS INTEGER xPointEnd, yPointEnd, xPointStart, yPointStart
    DIM AS SINGLE distance, d2
    DIM AS _BYTE leftClick, rightClick, rocket, c
    SHARED AS STRING shipType(), rockType()
    SHARED AS INTEGER lockedAngle, spin2, realCourse
    SHARED AS _BYTE played, delayVO '
    SHARED AS LONG miniMask, microMask, timer3
    ' -------------------------- target scan zone --------------------------
    IF Sb.doRocks AND NOT Flag.doPractice AND NOT Sb.doBuyIn THEN
        IF Ship.x > rock(Target).x - 10 AND Ship.x < rock(Target).x + 10 THEN ' check for ship and target rock overlap
            IF Ship.y > rock(Target).y - 10 AND Ship.y < rock(Target).y + 10 THEN
                IF NOT said AND Time.overlap = 16 THEN
                    IF NOT IsVOPlaying THEN '                               "scanning target," say it once to make it clear, don't drive user crazy
                        _SNDPLAY VO(1): said = TRUE '                       played once only, shields are low <  &&
                    ELSE TIMER(timer3) ON: delayVO = 1 '                    turn on VO delay timer, assign VO to play
                        said = TRUE
                    END IF
                END IF
                IF Time.overlap < 400 THEN
                    rock(Target).col = C(9) '                               orange during overlap
                    _SNDPLAY S(12) '                                        scanning sound
                END IF
                IF Time.overlap = 400 THEN
                    rock(Target).col = C(3) '                                           green after sufficient time of overlap
                    IF NOT said2 THEN _SNDPLAY VO(2): said2 = TRUE: pauseTime = TIMER ' done scanning, once
                    _SNDSTOP (S(12))
                END IF
                Time.overlap = Time.overlap + 1
                Ship.lapped = TRUE
            END IF
        ELSE Ship.lapped = FALSE
            _SNDSTOP (S(12))
        END IF
    END IF
    complete = (Time.overlap / 400) * 100
    If time.overlap > 10 And time.overlap <= 400 Then showHorzGauge CENTX - 50, _Height - 40,_
     time.overlap / 400, Str$(complete) + "%  SCANNED", _RGB32(255, 116, 6)
    IF NOT Ship.lapped AND Time.overlap < 400 THEN rock(Target).col = C(10) '   back to purple
    ' ----------------------------------------------------------------------
    IF said2 AND TIMER - pauseTime > 2.5 AND rock(Target).col = C(3) AND NOT Flag.harpooned AND Sb.doRocks THEN
        _SNDPLAY VO(5) '
        said2 = FALSE '
    END IF
    ' --------------------------
IF NOT leftClick AND NOT rightClick AND NOT _MOUSEMOVEMENTX AND_
(NOT _KEYDOWN(19200) OR NOT _KEYDOWN(19712)) THEN ship.kind = shipType(4) '     back to normal ship
    ' --------------------------
    IF _KEYDOWN(19200) OR _KEYDOWN(97) OR _KEYDOWN(65) THEN '                   ** SIDE THRUSTER RIGHT **
        played = FALSE: quickSound 10 '
        Ship.kind = shipType(12)

        IF Flag.landingTime THEN '                                              vector changes during landing mode
            SELECT CASE -Ship.course
                CASE 315 TO 359, 0 TO 45: Ship.Vx = Ship.Vx - .03
                CASE 135 TO 225: Ship.Vx = Ship.Vx + .03
                CASE 226 TO 314: Ship.Vy = Ship.Vy + .025 '
                CASE 46 TO 134: Ship.Vy = Ship.Vy - .025
            END SELECT
        ELSE '                                                                  non-vector movement
            tempSpin = CoAng - 90 '                                             location via theta angle
            d2 = d2 + .7
            Ship.x = COS(_D2R(tempSpin)) * d2 + Ship.x '
            Ship.y = SIN(_D2R(tempSpin)) * d2 + Ship.y
        END IF
    END IF
    IF _KEYDOWN(19712) OR _KEYDOWN(100) OR _KEYDOWN(68) THEN '                  ** SIDE THRUSTER LEFT **
        played = FALSE: quickSound 10 '
        Ship.kind = shipType(11)

        IF Flag.landingTime THEN
            SELECT CASE -Ship.course
                CASE 315 TO 359, 0 TO 45: Ship.Vx = Ship.Vx + .03
                CASE 135 TO 225: Ship.Vx = Ship.Vx - .03
                CASE 226 TO 314: Ship.Vy = Ship.Vy - .025 '
                CASE 46 TO 134: Ship.Vy = Ship.Vy + .025
            END SELECT
        ELSE
            tempSpin = CoAng + 90 '
            d2 = d2 + .7 '                                              add .7 pixels of distance each cycle
            Ship.x = COS(_D2R(tempSpin)) * d2 + Ship.x '                get coordinates from theta angle
            Ship.y = SIN(_D2R(tempSpin)) * d2 + Ship.y
        END IF
    END IF
    ' --------------------------
IF NOT _KEYDOWN(19200) AND NOT _KEYDOWN(97) AND NOT _KEYDOWN(19712)_
AND NOT _KEYDOWN(100) AND NOT _KEYDOWN(68) AND NOT _KEYDOWN(65) THEN
        IF _SNDPLAYING(S(10)) THEN
            _SNDSTOP S(10)
            played = FALSE '                                            kill side thruster loop, reset quickSound
        END IF
    END IF
    ' --------------------------
    DO WHILE _MOUSEINPUT '                                                              ** MOUSE INPUT **
        IF _MOUSEMOVEMENTX THEN
            IF NOT Ship.landed AND NOT Ship.charging THEN cX = cX - _MOUSEMOVEMENTX '   no ship spinning when landed and/or charging
            IF cX < 0 THEN Ship.kind = shipType(9) '                                    left steering jet
            IF cX > 0 THEN Ship.kind = shipType(10) '                                   right steering jet
            IF ABS(cX) > MouseSens * 80 THEN cX = MouseSens * 80 * SGN(cX) '            top end mouse governor!
            Ship.course = Ship.course + cX * MouseSens '                                mouseSens = mouse movement reducer
        END IF
    LOOP
    ' ----------------------
    MX = _MOUSEX: MY = _MOUSEY '
    IF Game.round = 1 AND Sb.doRocks AND NOT Sb.doPopUp THEN
        yCount = yCount + 1 '                                                           ** MOUSE USE ADVISORY **
        IF yCount > 40 THEN yCount = 0: oldY = MY '                                     only for practice & first harvest
        IF ABS(MY - oldY) > 130 THEN screwUps = screwUps + 1: oldY = MY '
        IF screwUps > 7 THEN show = TRUE: screwUps = -4: showTime = TIMER: _SNDPLAY S(2)
        IF show AND TIMER - showTime < 2.35 THEN
            IF TIMER - showTime > 1.9 THEN alpha = alpha - 8
            _FONT Menlo: COLOR _RGB32(255, 255, 0, alpha)
            _PRINTSTRING (CENTX - (_PRINTWIDTH("TO STEER SHIP") \ 2), CENTY - 30), "TO STEER SHIP"
            _PRINTSTRING (CENTX - (_PRINTWIDTH("MOVE MOUSE SIDE TO SIDE ONLY") \ 2), CENTY), "MOVE MOUSE SIDE TO SIDE ONLY"
        ELSE show = FALSE: alpha = 255
        END IF
    END IF
    '                     \/ mousekeeping chores - for WINDOWS only, QB64PE has mousemove issues in MacOS: 1/4 sec delay
    $IF WIN THEN
        IF _FULLSCREEN = 0 THEN
            IF MX > _WIDTH - 100 OR MX < 100 THEN _MOUSEMOVE _WIDTH / 2, _HEIGHT / 2
            IF MY > _HEIGHT - 100 OR MY < 100 THEN _MOUSEMOVE _WIDTH / 2, _HEIGHT / 2
            _MOUSEHIDE
        END IF
    $END IF
    ' ---------------------
    IF Ship.course >= 1 THEN Ship.course = -359 '           allows for zero course
    IF Ship.course < -359 THEN Ship.course = 0 '
    CoAng = -Ship.course - 90 '                             fix angles - corrected CourseAngle: 0 is really 90 degrees (east)
    IF CoAng < 0 THEN CoAng = CoAng + 360
    '                                                       ****    >  SHIP NAVIGATION <     ****
    IF NOT Flag.landingTime THEN '                          ** NON-LANDING NAV **  vector angle (theta) only
        distance = distance + Ship.speed '                  move the ship forward & backwards
        Ship.x = COS(_D2R(CoAng)) * distance + Ship.x '     get coordinates from angle vector
        Ship.y = SIN(_D2R(CoAng)) * distance + Ship.y
        Ship.Vx = COS(_D2R(CoAng)) * Ship.speed '           get last known vectors from corrected course - for use at landing time
        Ship.Vy = SIN(_D2R(CoAng)) * Ship.speed '
    END IF
    ' ---------------------
    IF Flag.chargeDone AND Flag.landingTime THEN '          <<< TRICKY SPOT <<< BACK2SPACE AFTER RECHARGE TRIGGER <<<
        IF Ship.y <= 6 OR Ship.y > _HEIGHT - 45 THEN '      break thru top border to go back to space, height - 45 keeps it outside FF box
            Flag.showMoonScape = FALSE '                    and prevents accidentally triggering go2space flag again
            Sb.go2Space = TRUE: SubFlags(12) = TRUE '       ** CHANGED If ship.y <= 0 TO <= 6 to allow more cycles to check position **
            Flag.reduceGravity = TRUE
        END IF
    END IF
    IF Flag.landingTime THEN '                              ** LANDING NAV - MOVE SHIP with vectors, not theta angle **
        Ship.x = Ship.x + Ship.Vx
        Ship.y = Ship.y + Ship.Vy
        IF Ship.Vy < 3.5 AND NOT Ship.landed AND NOT Sb.doFF THEN Ship.Vy = Ship.Vy + GravityFactor '   gravity factor
    END IF
    ' ---------------------
    leftClick = _MOUSEBUTTON(1) '
    rightClick = _MOUSEBUTTON(2) '
    ' ---------------------
    IF Flag.thrustersOn THEN
        IF leftClick AND NOT Sb.doPopUp THEN '              ** LEFT CLICK - speed up **
            Ship.kind = shipType(2) '                       main ship thruster
            Ship.power = Ship.power - .022 '
            played = FALSE '                                reset quickSound
            IF NOT Flag.landingTime THEN quickSound 11 ELSE quickSound 8
            IF NOT Flag.landingTime AND Ship.speed < 6 THEN Ship.speed = Ship.speed + .02
            IF Flag.landingTime THEN
                realCourse = -Ship.course '                 corrected course
                SELECT CASE realCourse '                    adjust y vectors
                    CASE 0 TO 45: Ship.Vy = Ship.Vy - .085
                    CASE 46 TO 84: Ship.Vy = Ship.Vy - .06
                    CASE 96 TO 135: Ship.Vy = Ship.Vy + .06
                    CASE 136 TO 225: Ship.Vy = Ship.Vy + .085
                    CASE 226 TO 264: Ship.Vy = Ship.Vy + .06
                    CASE 276 TO 315: Ship.Vy = Ship.Vy - .06
                    CASE 316 TO 360: Ship.Vy = Ship.Vy - .085
                END SELECT
                Ship.power = Ship.power - .036 '                burning up power
                SELECT CASE realCourse
                    CASE 3 TO 22: Ship.Vx = Ship.Vx + .007 '    adjust x vectors
                    CASE 23 TO 45: Ship.Vx = Ship.Vx + .02
                    CASE 46 TO 67: Ship.Vx = Ship.Vx + .035 '   more sideways thrust, more vector change
                    CASE 68 TO 113: Ship.Vx = Ship.Vx + .055
                    CASE 114 TO 135: Ship.Vx = Ship.Vx + .035
                    CASE 136 TO 160: Ship.Vx = Ship.Vx + .02
                    CASE 161 TO 178: Ship.Vx = Ship.Vx + .007
                    CASE 182 TO 200: Ship.Vx = Ship.Vx - .007
                    CASE 201 TO 225: Ship.Vx = Ship.Vx - .02
                    CASE 226 TO 241: Ship.Vx = Ship.Vx - .035
                    CASE 242 TO 292: Ship.Vx = Ship.Vx - .055
                    CASE 293 TO 315: Ship.Vx = Ship.Vx - .035
                    CASE 316 TO 337: Ship.Vx = Ship.Vx - .02
                    CASE 338 TO 357: Ship.Vx = Ship.Vx - .007
                END SELECT
                '                                                                   ** FLAME ZONE **
                antiHeading = realCourse + 90 '                                     adjust for QB64
                IF antiHeading > 360 THEN antiHeading = antiHeading - 360
                dist = INT(RND * 20 + 11) '                                         distance for end of flames
                xPointEnd = dist * COS(_D2R(antiHeading)) + Ship.x
                yPointEnd = dist * SIN(_D2R(antiHeading)) + Ship.y
                xPointStart = 6 * COS(_D2R(antiHeading)) + Ship.x '                 6 is dist from center of ship
                yPointStart = 6 * SIN(_D2R(antiHeading)) + Ship.y
                rocket = TRUE
            END IF
        ELSE IF NOT Flag.landingTime AND rightClick THEN '                          RIGHT CLICK - slow down - RETRO/NOSE THRUSTER at nose
                IF Ship.speed > -1 THEN Ship.speed = Ship.speed - .03 '             **********************************
                Ship.kind = shipType(1) '                                           NON-LANDING SEQUENCES
                Ship.power = Ship.power - .009
                played = FALSE: quickSound 9 '
            END IF
        END IF

        IF rightClick AND Flag.landingTime AND NOT Ship.charging THEN '             LANDING SEQUENCE RETRO THRUSTER
            Ship.kind = shipType(1) '                                               *******************************
            Ship.power = Ship.power - .028
            played = FALSE: quickSound 9
            realCourse = -Ship.course '                                             easier to work with numbers...
            SELECT CASE realCourse '                                                x/y vector adjusts for nose thruster during landingTime
                CASE 0 TO 45: Ship.Vy = Ship.Vy + .08: Ship.Vx = Ship.Vx - .02
                CASE 46 TO 77: Ship.Vy = Ship.Vy + .05: Ship.Vx = Ship.Vx - .05 '
                CASE 78 TO 113: Ship.Vx = Ship.Vx - .08:
                CASE 114 TO 135: Ship.Vy = Ship.Vy - .05: Ship.Vx = Ship.Vx - .05
                CASE 136 TO 157: Ship.Vy = Ship.Vy - .065: Ship.Vx = Ship.Vx - .035 '   Thanks to Ben C.K. for calling out this need!
                CASE 158 TO 175: Ship.Vy = Ship.Vy - .075: Ship.Vx = Ship.Vx - .025 '   Added upgraded controls here
                CASE 176 TO 184: Ship.Vy = Ship.Vy - .085
                CASE 185 TO 202: Ship.Vy = Ship.Vy - .075: Ship.Vx = Ship.Vx + .025
                CASE 203 TO 224: Ship.Vy = Ship.Vy - .065: Ship.Vx = Ship.Vx + .035
                CASE 225 TO 247: Ship.Vy = Ship.Vy - .05: Ship.Vx = Ship.Vx + .05
                CASE 248 TO 293: Ship.Vx = Ship.Vx + .08
                CASE 294 TO 315: Ship.Vy = Ship.Vy + .05: Ship.Vx = Ship.Vx + .05
                CASE 316 TO 359: Ship.Vy = Ship.Vy + .08: Ship.Vx = Ship.Vx + .02
            END SELECT
            IF realCourse < 193 AND realCourse > 167 THEN Ship.Vx = 0 '             line up the rocket, kill x motion when inverted and firing nose thruster <<<<
        END IF
    END IF

    IF NOT _MOUSEBUTTON(1) THEN
        IF _SNDPLAYING(S(11)) THEN _SNDSTOP S(11): played = FALSE '                 kill main thruster sounds, reset quickSound
        IF _SNDPLAYING(S(8)) THEN _SNDSTOP S(8): played = FALSE
    END IF
    IF NOT _MOUSEBUTTON(2) AND _SNDPLAYING(S(9)) THEN _SNDSTOP S(9): played = FALSE ' stop nose thruster sound
    ' ---------------------
    spin = Ship.course '                                                            VARPRT$ command doesn't like array or UDT use ...using dummy var "spin"
    PRESET (Ship.x, Ship.y), Ship.col
    DRAW "TA=" + VARPTR$(spin) + Ship.kind '                                        draw the ship with rotation
    PAINT (Ship.x, Ship.y - 1), C(3), Ship.col '                                    paint ship green inside - can't be exactly in the middle

    IF Flag.harpooned THEN
        IF Flag.doRockMask THEN _PUTIMAGE (Ship.x - 23, Ship.y - 23), miniMask '    blocks the starscape from inside the target rock
        IF NOT Flag.detachRock THEN
            rock(Target).x = Ship.x '                                               same xy locations for ship & rock
            rock(Target).y = Ship.y
            spin2 = rock(Target).spinAngle + (Ship.course - lockedAngle) '          keep rock at same angle but change with ship now!
        END IF

        IF Ship.detached THEN _PUTIMAGE (rock(Target).x - 22, rock(Target).y - 22), miniMask '
        PRESET (rock(Target).x, rock(Target).y), rock(Target).col
        IF NOT Sb.rockMoving AND NOT rock(Target).stayPainted THEN DRAW "TA=" + VARPTR$(spin2) + rock(Target).kind '  draw rock with ship or without and target(rock).alive
        PRESET (Ship.x, Ship.y), Ship.col
        DRAW "TA=" + VARPTR$(spin) + Ship.kind '                                draw ship
        PAINT (Ship.x, Ship.y - 1), C(3), Ship.col
    END IF

    IF rocket THEN '                                                            flame draw after ship & rock
        LINE (xPointStart, yPointStart)-(xPointEnd, yPointEnd), C(12) '         center flame line
        LINE (xPointStart + 1, yPointStart + 2)-(xPointEnd, yPointEnd), C(9) '  two V shaping lines
        LINE (xPointStart - 1, yPointStart + 2)-(xPointEnd, yPointEnd), C(9)
        rocket = FALSE
    END IF
    ' --------------------------
    IF Flag.regularChecks THEN '                                                ** ON-SCREEN / OFF-SCREEN BEHAVIOR **
        IF Ship.x < -5 AND NOT Flag.shutFrontDoor THEN Ship.x = _WIDTH + 5 '                                normal
        IF Ship.x < -5 AND Flag.shutFrontDoor THEN Ship.x = 20: _SNDPLAYCOPY S(2), .5 '                     bounce off left side during comets
        IF Ship.x > _WIDTH + 5 AND Flag.shutBackDoor THEN Ship.x = _WIDTH - 20: _SNDPLAYCOPY S(2), .5 '     bounce off right side, round 2
        IF Ship.x > _WIDTH + 5 THEN Ship.x = -4 '                                                           normal
        ' *************
        IF Ship.y < -5 AND NOT Flag.landingTime THEN Ship.y = _HEIGHT + 5 '                                 normal behavior
        IF Ship.y < -5 AND Flag.landingTime AND NOT Flag.chargeDone AND NOT Sb.go2Space THEN Ship.y = 10: Ship.Vy = 0 '  can't fly off screen going up during landing *
        IF Ship.y < -5 AND Ship.charged THEN Ship.y = _HEIGHT + 5 '                                         special normal...
        IF Ship.y > _HEIGHT + 5 AND NOT Flag.landingTime THEN Ship.y = -4 '                                 normal
        '
        IF Ship.y > _HEIGHT - 117 AND Flag.landingTime AND NOT Sb.go2Space AND NOT Sb.doFF THEN shipBoom '  crash on moon surface
    ELSE forceFieldControl '                                                                             ** FORCE FIELD CHALLENGE **
    END IF '
END SUB
' -----------------------------------------
'                                           a separate loop for drone battle
SUB saucerControl () '

    DIM AS INTEGER a, c, d, i, targetX, targetY, cSx, cSy ' corrected Saucer X & Y
    DIM AS INTEGER angle(1 TO 4), wide, high, numWaves, hitX, hitY
    DIM AS _BYTE initd, doBoom, playing, cycleCount, leftClick, rndDone
    DIM AS LONG outImg
    DIM AS XYPair lo(1 TO 4) '                              gun locations
    SHARED AS INTEGER toteSaucers, saucerKills, shipNum, limit
    SHARED AS LONG saucerScape, starScape, starScape3, HDWimg(), mainScreen
    SHARED AS _BYTE sparkCycles
    SHARED spark() AS spark, saucer() AS saucer
    SHARED AS SINGLE xScroller
    STATIC AS _BYTE adviceGiven

    PCOPY starScape3, starScape '   <<<< new, copy custom landingTime screen to main background screen
    xScroller = 0 '                 reset scrolling so the screen doesn't jump cut
    IF Control.clearStatics THEN '
        initd = FALSE
        doBoom = FALSE
        cycleCount = 0
        EXIT SUB
    END IF

    IF NOT initd THEN '
        wide = 1600: high = 900 '                   new rez 1600x900
        lo(1).x = 30: lo(1).y = 30 '                upper left        ** set gun locations **
        lo(2).x = wide - 30: lo(2).y = 30 '         upper right
        lo(3).x = 30: lo(3).y = high - 30 '         lower left
        lo(4).x = wide - 30: lo(4).y = high - 30 '  lower right
        SCREEN _NEWIMAGE(wide, high, 32) '          ** higher resolution **
        IF _FULLSCREEN = 0 THEN _SCREENMOVE DTW / 2 - _WIDTH / 2, DTH / 2 - _HEIGHT / 2
        killNoises '                                takes care of stuck thruster sound
        initd = TRUE
        FOR i = 255 TO 0 STEP -4 '                  fade in scene
            _LIMIT 120 '                            control fade speed
            _PUTIMAGE , saucerScape
            _PUTIMAGE , ViewScreen
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            _DISPLAY
        NEXT
    END IF
    _KEYCLEAR: _PRINTMODE _KEEPBACKGROUND
    _MOUSEMOVE _WIDTH / 2, _HEIGHT / 2

    DO '
        IF NOT doBoom THEN '                        assign saucers, advamce wave count, up limit when done with explosions only
            assignSaucers
            numWaves = numWaves + 1
            limit = limit + Game.killRatio * .08 '                          speed up a bit each wave based on performance
            IF numWaves < 6 THEN toteSaucers = toteSaucers + shipNum '      track total saucers in sequence for kill ratio
        END IF
        ' ---------------------------------
        DO
            _LIMIT limit '                                                  limit set by saucer quantity in assignSaucers sub
            IF d < 201 THEN d = d + 1
            IF NOT adviceGiven AND d = 200 THEN _SNDPLAY VO(37): adviceGiven = TRUE '    targeting advice
            IF NOT Control.hold THEN '                                      pause execution during a call to settings sub
                WHILE _MOUSEINPUT: WEND
                targetX = _MOUSEX
                targetY = _MOUSEY
                leftClick = _MOUSEBUTTON(1)
                CLS
                _PUTIMAGE , saucerScape '                                       stars
                CIRCLE (targetX, targetY), 20, C(9) '                           target circle - gotta add 20 both ways for image corner vs, mouse x,y issue
                LINE (targetX, targetY - 15)-(targetX, targetY + 15), C(4) '    crosshairs
                LINE (targetX - 15, targetY)-(targetX + 15, targetY), C(4)
                COLOR C(14) '                                                               ** SCORE ZONE **
                _FONT MenloBig
                _PRINTSTRING (_WIDTH - 290, 53), "SCORE:  " + STR$(Game.score) '
                _FONT ModernBigger
                _PRINTSTRING (140, 53), "TOTAL SAUCERS: " + STR$(toteSaucers)
                _PRINTSTRING (140, 73), "DESTROYED:     " + STR$(saucerKills)
                Game.killRatio = INT(saucerKills / toteSaucers * 100) '
                _PRINTSTRING (140, 93), "KILL RATIO:    " + STR$(Game.killRatio) + "%"
                showHorzGauge 140, 128, Ship.power / 100, "POWER  " + STR$(INT(Ship.power)) + "%", _RGB32(61, 255, 78, 220)
                showHorzGauge 140, 158, Ship.shields / 100, "SHIELDS  " + STR$(INT(Ship.shields)) + "%", C(12)
                ' -------------------------
                c = 0
                DO '                                                                        ** GUN ZONE **
                    c = c + 1
                    angle(c) = GETANGLE(lo(c).x, lo(c).y, targetX, targetY) '               get all four angles
                    RotateImage angle(c), I(1), outImg '                                    rotate and render all guns
                    _PUTIMAGE (lo(c).x - _WIDTH(outImg) \ 2, lo(c).y - _HEIGHT(outImg) \ 2), outImg, 0
                LOOP UNTIL c = UBOUND(lo)
                ' -------------------------
                a = 0 '                                                             command string parse
                DO
                    a = a + 1 '                                                     increments thru saucers up to shipNum
                    IF saucer(a).alive THEN '                                       skip dead saucers
                        IF saucer(a).getCommand THEN
                            getNextCommand a '                                      grab action letter and loopNum from command line
                            saucer(a).getCommand = FALSE
                        END IF
                        IF saucer(a).loopCounter = saucer(a).loopNum THEN '         if still churning thru single command don't reassign new command yet
                            saucer(a).getCommand = TRUE
                            _CONTINUE '                                             skip this cycle till new command retrieved
                        END IF
                        saucer(a).loopCounter = saucer(a).loopCounter + 1 '         increment action counter up to loopNum
                        renderSaucer a
                    END IF
                LOOP UNTIL a = shipNum '
                ' -------------------------
                a = 0
                DO '                                                                display saucers
                    a = a + 1
                    IF saucer(a).alive THEN
                        _PUTIMAGE (saucer(a).loc.x, saucer(a).loc.y), HDWimg(a), 0
                    END IF
                LOOP UNTIL a = shipNum
                ' -------------------------
                IF leftClick THEN '                                                 ** MOUSE ACTION **
                    IF cycleCount < 14 THEN
                        cycleCount = cycleCount + 1
                        IF NOT playing THEN _SNDPLAYCOPY S(27), .12: playing = TRUE '       laser blasts
                        a = 0 '
                        DO '                                        4 laser positions wuth 3 beams each
                            a = a + 1
                            LINE (lo(a).x, lo(a).y)-(targetX, targetY), C(4) '              middle beam green
                            LINE (lo(a).x + 2, lo(a).y + 2)-(targetX, targetY), C(14) '     side 1 yellow
                            LINE (lo(a).x - 2, lo(a).y - 2)-(targetX, targetY), C(12) '     side 2 red
                        LOOP UNTIL a = 4

                        a = 0
                        DO '                                        check for hit...
                            a = a + 1
                            IF saucer(a).alive THEN
                                ' correct saucer location onscreen with cursor/target - as saucer image grows, upper right corner steps back
                                cSx = saucer(a).loc.x + 30 '
                                cSy = saucer(a).loc.y + 30 '
                                IF targetX > cSx - 15 AND targetX < cSx + 15 THEN
                                    IF targetY > cSy - 15 AND targetY < cSy + 15 THEN '
                                        _SNDPLAY S(INT(RND * 3 + 4)) '                  booms
                                        Game.score = Game.score + (75 * Game.diff_mult) '
                                        saucerKills = saucerKills + 1 '
                                        saucer(a).alive = FALSE
                                        hitX = saucer(a).loc.x
                                        hitY = saucer(a).loc.y
                                        doBoom = TRUE
                                        EXIT DO '
                                    END IF
                                END IF
                            END IF
                        LOOP UNTIL a = shipNum
                    END IF
                END IF
                ' -------------------------
                IF NOT leftClick THEN playing = FALSE: cycleCount = 0 '     kill sound,  reset laser fire time
                IF doBoom THEN
                    boomInfo.num = 20 '
                    boomInfo.r = 200 '
                    boomInfo.g = 220
                    boomInfo.b = 110 '
                    sparkCycles = sparkCycles + 1
                    IF sparkCycles < boomInfo.num THEN
                        MakeSparks hitX + 28, hitY + 28
                        UpdateSparks '
                    END IF
                    IF sparkCycles >= boomInfo.num THEN
                        doBoom = FALSE
                        sparkCycles = 0
                        REDIM spark(0) AS spark '           took a while to figure out to put this here! <<<<
                    END IF
                END IF
                ' -------------------------
                ManageBullets '                             enemy fire
                _PUTIMAGE , ViewScreen '                    window border for cockpit view
                _DISPLAY

                IF _KEYDOWN(27) THEN '                      popUp
                    Control.pop = TRUE
                    _MOUSESHOW
                    Control.hold = TRUE
                    _KEYCLEAR '
                END IF
                IF _KEYDOWN(115) THEN numWaves = 6 '        <<<< <S> to skip saucers FOR TESTING ONLY <<<< CHEAT KEY <<<<
                ' ************************                  local sound events
                IF NOT Resetter(16) THEN _SNDLOOP S(31): Resetter(16) = TRUE '          loop saucer bg
                IF NOT Resetter(17) THEN SndFade2 S(31), .001, .04, 0, 17 '             turn up saucer loop
                ' ************************
                IF numWaves = 4 THEN _SNDPLAY VO(20): _SNDPLAY S(35) ' unusual energy reading   ** SAUCER ROUNDS **
                IF numWaves = 6 THEN
                    Sb.doFF = TRUE: SubFlags(3) = TRUE '                                turn on force field sub
                    FPS = Game.speed '
                    Sb.doSaucers = FALSE: SubFlags(16) = FALSE
                    numWaves = 0 '                                                      reset static variables for next round
                    Ship.speed = 0
                    SCREEN mainScreen '                                                 back to lower resolution
                    IF _FULLSCREEN = 0 THEN _SCREENMOVE DTW / 2 - _WIDTH / 2, DTH / 2 - _HEIGHT / 2
                    CLS '
                    initd = FALSE '                                                     reset init flag
                    _FONT 16
                    _FREEIMAGE outImg '
                    _KEYCLEAR
                    EXIT SUB
                END IF

                c = 0
                rndDone = TRUE '                            check for done
                DO
                    c = c + 1
                    IF saucer(c).alive THEN
                        rndDone = FALSE
                        EXIT DO
                    END IF
                LOOP UNTIL c = shipNum
            END IF '                   -------- BOTTOM OF HOLD POINT --------
            IF Control.pop THEN popUp
            IF Sb.doInstructs THEN instructions
        LOOP UNTIL rndDone
    LOOP
END SUB
' -----------------------------------------
'                                           ship behavior and cage
SUB forceFieldControl () '

    DIM AS INTEGER b1, b2, i
    STATIC AS SINGLE c1, c2, a, b, ffTime
    STATIC AS XYPair alien
    STATIC AS _BYTE play2, initFF, hintGiven
    STATIC AS INTEGER c, cycles
    DIM AS LONG img, outimg
    DIM AS _BYTE minutes, seconds
    DIM secs$
    SHARED AS _UNSIGNED LONG weakWallColor
    SHARED AS _BYTE bounceOffs
    SHARED AS LONG starScape, shipImg
    SHARED AS STRING shipType()

    IF Control.clearStatics THEN initFF = FALSE: cycles = 0: c = 0: EXIT SUB '
    IF NOT Resetter(20) THEN _SNDPLAY S(34): Resetter(20) = TRUE '  scary noise

    IF NOT initFF THEN '
        bounceOffs = 0
        FOR i = 255 TO 0 STEP -3 '                                  fade in scene
            _LIMIT 130 '                                            control fade speed
            _PUTIMAGE , starScape
            _PUTIMAGE (CENTX - 20, CENTY + 50), shipImg
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            _DISPLAY
            initFF = TRUE
        NEXT

        killChecks: killNoises
        alien.x = _WIDTH + 50 '             put alien offstage right
        alien.y = _HEIGHT \ 2 - 25
        _SNDSTOP S(31)
        DO '                                alien zooms in
            CLS
            _LIMIT 90
            alien.x = alien.x - 3
            _PUTIMAGE , starScape
            _PUTIMAGE (CENTX - 20, CENTY + 50), shipImg
            _PUTIMAGE (alien.x, alien.y), I(2) '
            _DISPLAY
        LOOP UNTIL alien.x <= _WIDTH \ 2 - 60

        _SNDPLAY S(33) '                    shoot sound
        _SNDPLAY S(26) '                    swooping in sound
        a = 4: b = 2.58 '
        c = 0: FPS = 6
        DO '                                spinning force field animation
            CLS
            _LIMIT FPS '
            _PUTIMAGE , starScape
            _PUTIMAGE (CENTX - 20, CENTY + 50), shipImg
            alien.x = alien.x + 5
            _PUTIMAGE (alien.x, alien.y), I(2) '
            a = a * 1.019
            b = b * 1.019
            c = c + 5
            IF FPS < 105 THEN FPS = FPS + 2
            img = _NEWIMAGE(a, b, 32)
            outimg = _NEWIMAGE(a, b, 32)
            _DEST img
            LINE (1, 1)-(_WIDTH - 1, _HEIGHT - 1), C(14), B
            IF c > 30 THEN PAINT (_WIDTH / 2, _HEIGHT / 2), _RGB32(255, 0, 0, 132), C(14)
            _DEST 0
            RotateImage c, img, outimg
            _PUTIMAGE (CENTX - _WIDTH(outimg) / 2, CENTY - _HEIGHT(outimg) / 2), outimg
            _DISPLAY
        LOOP UNTIL c = 1445 '

        _FREEIMAGE img: _FREEIMAGE outimg
        IF NOT Resetter(19) THEN _SNDVOL S(32), .025: _SNDLOOP S(32): Resetter(19) = TRUE '      ~
        Ship.course = 0 '
        weakWallColor = C(14) '                 reset WeakWallColor  <<
        _SNDPLAY S(13) '                        warning beeps (4)
        Ship.x = CENTX: Ship.y = CENTY + 69
        Ship.speed = 0: Ship.course = 0 '
        ffTime = TIMER
    END IF '                    --------------  bottom of INITFF  -------------

    _FONT Menlo: COLOR C(9)
    Time.inCage = INT(TIMER - ffTime)
    IF NOT hintGiven AND Time.inCage > 60 AND bounceOffs < 4 THEN _SNDPLAY VO(36): hintGiven = TRUE '      ** HUGE HINT **
    _PRINTMODE _KEEPBACKGROUND
    minutes = INT(Time.inCage / 60): seconds = Time.inCage MOD 60
    IF Time.inCage < 10 THEN
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("XXXX SECONDS") / 2, _HEIGHT - 30), STR$(Time.inCage) + " SECONDS"
    ELSE
        IF seconds < 10 THEN secs$ = "0" + _TRIM$(STR$(seconds)) ELSE secs$ = _TRIM$(STR$(seconds))
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("0:00") / 2, _HEIGHT - 30), _TRIM$(STR$(minutes)) + ":" + secs$
    END IF

    cycles = cycles + 1 '
    SELECT CASE cycles '                    sound events
        CASE 40: _SNDPLAY S(13)
        CASE 98: play2 = TRUE
        CASE 100: _SNDPLAY VO(17)
        CASE 340: play2 = FALSE
        CASE 350: _SNDPLAY VO(18)
        CASE 450: _SNDPLAY VO(16)
        CASE 750: _SNDPLAY S(3) '
            Flag.landingTime = TRUE '       also true (main thrusters ON) if weak wall is hit
    END SELECT

    IF play2 THEN _SNDPLAY S(12)
    IF Ship.x > _WIDTH - LINEX THEN Ship.x = _WIDTH - (LINEX + 10): Ship.Vx = 0: Ship.Vy = 0: _SNDPLAY S(2) '   force field cage rules
    IF Ship.y < 50 THEN Ship.y = 60: Ship.Vy = 0: Ship.Vx = 0: _SNDPLAY S(2) '
    IF Ship.y > _HEIGHT - 50 THEN Ship.y = _HEIGHT - 60: Ship.Vy = 0: Ship.Vx = 0: _SNDPLAY S(2)
    IF NOT Sb.doDeflect THEN LINE (LINEX, 50)-(LINEX, _HEIGHT - 50), weakWallColor ' draw left cage side    ** WEAK WALL <<<<<  draw box
    LINE (LINEX, 50)-(_WIDTH - LINEX, 50), C(14) '          top line                                        ** DRAW FF CAGE **
    LINE -(_WIDTH - LINEX, _HEIGHT - 50), C(14) '           right side
    LINE -(LINEX, _HEIGHT - 50), C(14) '                    bottom line
    '                                                       line effects
    IF c1 < _WIDTH - 320 THEN c1 = c1 + 9 ELSE c1 = 0 '
    IF c2 < _HEIGHT - 100 THEN c2 = c2 + 5.82 ELSE c2 = 0 ' moving green balls over yellow lines
    IF b2 < _HEIGHT - 100 THEN b2 = b2 + c2
    IF b1 < _WIDTH - 50 THEN b1 = b1 + c1
    CIRCLE (LINEX + b1, 50), 3, C(4) '                      top
    CIRCLE (LINEX + b1, _HEIGHT - 50), 3, C(4) '            bot
    CIRCLE (_WIDTH - LINEX - b1, 50), 3, C(4) '             top
    CIRCLE (_WIDTH - LINEX - b1, _HEIGHT - 50), 3, C(4) '   bot
    CIRCLE (_WIDTH - LINEX, _HEIGHT - 50 - b2), 3, C(4) '   right bot
    CIRCLE (_WIDTH - LINEX, 50 + b2), 3, C(4) '             right top
    IF bounceOffs < 3 THEN
        CIRCLE (LINEX, 50 + b2), 3, C(4) '                  left top  ** WEAK WALL <<<<< moving balls
        CIRCLE (LINEX, _HEIGHT - 50 - b2), 3, C(4) '        left bot  **
    ELSE
        IF NOT Resetter(29) THEN _SNDPLAY S(20): Resetter(29) = TRUE
    END IF

    IF Ship.x < LINEX THEN '                             ** CONTACT WITH WEAK WALL **
        Sb.doFF = FALSE: SubFlags(3) = FALSE
        Flag.landingTime = TRUE '                           turn on main thrusters
        Sb.doDeflect = TRUE: SubFlags(4) = TRUE '           do deflect sub
        Flag.regularChecks = FALSE '
        IF Ship.power < 7 AND bounceOffs > 4 THEN Ship.power = Ship.power + 11 ' prevents blowing up in mid-stretch of weak wall glitch <<<<
    END IF '
    _FONT 16
END SUB
' -----------------------------------------
'                                           draw lines, determine how much to spring
SUB deflectFF () '

    STATIC AS SINGLE oldVx, decel '
    STATIC AS _BYTE initd, started
    STATIC AS INTEGER redd, gren, busted
    SHARED AS _UNSIGNED LONG weakWallColor
    SHARED AS _BYTE bounceOffs
    DIM AS _UNSIGNED LONG WWCol

    IF Control.clearStatics THEN
        initd = FALSE
        started = FALSE
        busted = 0
        decel = 0
        EXIT SUB
    END IF

    IF NOT started THEN
        redd = 225
        gren = 255
        started = TRUE
        killChecks '                            prevents boom sounds @ escaping...
    END IF
    IF NOT initd THEN oldVx = Ship.Vx: initd = TRUE
    IF Ship.x > LINEX - 10 AND Ship.x < LINEX AND Ship.Vx < 0 THEN _SNDPLAY S(1) '      impact thump
    IF _KEYDOWN(115) THEN busted = 42 '                                                 to skip this chapter press <s> - for testing

    IF Ship.x < 40 THEN busted = busted + 1 '   track cycles in stretch zone
    IF busted > 40 THEN '                       FF broken! REDUCED FROM 50 TO 40
        busted = 0 '                            CLEANUP on the ** way out **
        decel = 0
        bounceOffs = 0
        Flag.landingTime = FALSE '
        Sb.goDissolveFF = TRUE: SubFlags(15) = TRUE
        Flag.regularChecks = TRUE '
        Sb.doDeflect = FALSE: SubFlags(4) = FALSE
        initd = FALSE
        started = FALSE
        _SNDPLAY S(24) '                        whip sound for breaking FF
        Ship.speed = 5 '                        zoom away
        oldVx = 0
        Game.score = Game.score + (350 * Game.diff_mult) '
    END IF

    IF Ship.x > LINEX - 30 THEN WWCol = weakWallColor ELSE WWCol = C(12) '  weakened FF color vs. bright red when stretched tight
    LINE (LINEX, 50)-(Ship.x, Ship.y + 2), WWCol '              draw 2-part FF line bent around ship deflection
    LINE (LINEX, _HEIGHT - 50)-(Ship.x, Ship.y), WWCol
    IF Ship.x < LINEX THEN Ship.Vx = Ship.Vx + 2 - decel '      quick deceleration

    IF Ship.Vx < .5 AND Ship.Vx > -.5 THEN '                    spring back!
        Ship.Vx = -oldVx * 1.3 '
        IF bounceOffs > 2 THEN _SNDPLAY S(25) '                 do zoom sound
    END IF

    IF Ship.x > LINEX THEN '                                    bounce back reset
        IF decel < 1.8 THEN decel = decel + .2 '                greater stretchiness each bounce-off by increasing Vx reduction
        bounceOffs = bounceOffs + 1
        IF redd < 256 THEN redd = redd + 4 '
        IF gren > 11 THEN gren = gren - 11 '
        weakWallColor = _RGB32(redd, gren, 0)
        Sb.doDeflect = FALSE: SubFlags(4) = FALSE
        Sb.doFF = TRUE: SubFlags(3) = TRUE
        initd = FALSE
    END IF
END SUB
' -----------------------------------------

SUB dissolveFF () ' this fades the force field and returns to rock harvest - with increased # of rocks

    STATIC AS SINGLE fader
    STATIC AS _BYTE initd
    STATIC AS INTEGER c, adjuster, upperX, lowerX

    IF Control.clearStatics THEN initd = FALSE: c = 0: EXIT SUB
    IF NOT initd THEN
        fader = 255
        _SNDPLAY S(23) '                        heaven sound
        c = 0
        initd = TRUE
        adjuster = CENTY - Ship.y '             adjust line segment lengths of broken FF acc. to ship.y position
        IF SGN(adjuster) = 1 THEN
            adjuster = (-CENTY + Ship.y) \ 5
            upperX = adjuster
            lowerX = -adjuster
        END IF

        IF SGN(adjuster) = -1 THEN
            adjuster = (Ship.y - CENTY) \ 5
            lowerX = adjuster
            upperX = -adjuster
        END IF
    END IF

    c = c + 1 '
    LINE (LINEX, 50)-(_WIDTH - LINEX, 50), _RGB32(255, 190, 0, fader) '     top line        ** draw FF cage **
    LINE -(_WIDTH - LINEX, _HEIGHT - 50), _RGB32(255, 190, 0, fader) '      right side
    LINE -(LINEX, _HEIGHT - 50), _RGB32(255, 255, 0, fader) '               bottom line
    LINE (LINEX, 50)-(36 + upperX, 205 - c), _RGB32(255, 0, 0, fader) '                     broken weak wall segments
    LINE (LINEX, _HEIGHT - 50)-(48 + lowerX, _HEIGHT - 210 + c), _RGB32(255, 0, 0, fader)
    fader = fader - 1.65 ' was 1.4
    IF fader < 30 THEN '                    reset           ** END OF FIRST ROUND **        <<<< <<<< <<<< <<<< <<<<
        Sb.goDissolveFF = FALSE: SubFlags(15) = FALSE
        initd = FALSE '                     reset init
        IF MaxRocks < 30 THEN MaxRocks = MaxRocks + 4 '     increase bouncing rock count
        Flag.fadeInRocks = TRUE '                           flip on flags for new round
        Flag.doAutoShields = TRUE
        Flag.doRockMask = FALSE '                           masks come on after start of new round - rock fade in...
        rock(Target).stayPainted = FALSE
        _SNDSTOP S(32)
        Control.clearStatics = TRUE '                       RESET statics for new ROUND only - no running startUp
        resetFlags '
    END IF
END SUB
' -----------------------------------------
SUB postLanding ()

    DIM AS _BYTE i
    SHARED AS LONG starScape2

    IF _KEYDOWN(27) THEN Sb.doPopUp = TRUE '    in case you wanna popUp while landed
    IF _KEYDOWN(32) AND Ship.charged THEN '     blast off from charging station
        Ship.charged = FALSE
        Ship.charging = FALSE '                 done in main loop charging section <<<<
        Ship.landed = FALSE
        Flag.chargeDone = TRUE
        Sb.doTruck = FALSE '                    turn off truck sub / landing beacons
        Ship.x = 761: Ship.y = 530
        _SNDPLAY S(20) '                        zap sound
        _SNDPLAY VO(23) '                       now leave orbit voice over
        IF _SNDPLAYING(VO(14)) AND _SNDPLAYING(VO(23)) THEN _SNDSTOP VO(14) '           cut off "When you're done..." with "Now leave orbit..."
    END IF
    IF _KEYDOWN(32) AND Ship.x < 700 AND NOT Ship.detached AND Game.round = 1 THEN '    detach rock in drop zone (if the ship isn't at the charging station --> x check)
        redrawShip
        Flag.detachRock = TRUE '
        Flag.doRockMask = FALSE
        Sb.rockMoving = TRUE: SubFlags(13) = TRUE
        Ship.detached = TRUE
        _SNDSTOP VO(12) '                       great landing, now press the space bar
        _SNDPLAY S(19) '                        hydraulic sound
    END IF
    IF Game.round > 1 THEN '                    end of game fireworks
        Flag.thrustersOn = FALSE
        fireworks
        _SNDSTOP S(47): _SNDSTOP S(48)
        FOR i = 1 TO 86: keepScrolling .22: NEXT i ' scroll for a sec...
        starScape2 = _COPYIMAGE(_DISPLAY, 32)
        Control.endIt = TRUE
    END IF
    _KEYCLEAR
END SUB
' -----------------------------------------
SUB moveTargetRock () '

    STATIC AS INTEGER c
    STATIC AS SINGLE d, e, alpha
    STATIC AS _BYTE played '
    SHARED AS INTEGER spin2
    SHARED AS _BYTE bannerON
    DIM AS INTEGER xStart, yStart

    IF Control.clearStatics THEN '
        c = 0: d = 0
        e = 0: alpha = 0
        EXIT SUB
    END IF
    xStart = 326: yStart = 644 '                            location of laser station, green start color
    c = c + 1
    IF c = 99 THEN _SNDLOOP S(22) '                         tractor beam sound
    IF c > 105 AND c < 205 THEN
        rock(Target).y = rock(Target).y - .48 '             pick up rock, heat it up
        IF d < 127 THEN d = d + .88
        rock(Target).col = _RGB32(0, INT(127 + d), 0) '     change rock edge color dark green to bright green
        redrawShip
    END IF
    IF c > 205 AND c <= 500 THEN
        IF NOT played AND c > 240 THEN
            _SNDPLAY VO(13) '                               recharge and instructions, played once only
            _SNDPLAY VO(15) '                               time staggered sounds for simultaneous play
            played = TRUE
        END IF
        rock(Target).col = C(4)
        rock(Target).x = rock(Target).x - .67 '                     slide over and fade in dark green body fill color, bake it
        PSET (rock(Target).x, rock(Target).y), rock(Target).col '
        DRAW "TA=" + VARPTR$(spin2) + rock(Target).kind '           draw rock - gotta draw the rock before painting it
        PSET (rock(Target).x, rock(Target).y), C(0) '               erase center dot   STILL NOT BLOCKING CENTER DOT... <<<<
        IF e < 255 THEN e = e + 1.1
        PAINT (rock(Target).x, rock(Target).y), _RGB32(0, 106, 0, INT(alpha + e)), C(4) ' fill rock w/ green
        redrawShip
    END IF

    IF c = 390 THEN bannerON = TRUE '                               show instruction
    IF c > 500 AND c < 642 THEN '                                   place rock and magically crystalize it
        rock(Target).y = rock(Target).y + .5
        PSET (rock(Target).x + INT((RND - RND) * 35), rock(Target).y + INT((RND - RND) * 33)), C(14) '      yellow fairy dust
        PSET (rock(Target).x + INT((RND - RND) * 35), rock(Target).y + INT((RND - RND) * 33)), C(16) '      brightwhite
        CIRCLE (rock(Target).x + INT((RND - RND) * 30), rock(Target).y + INT((RND - RND) * 33)), 3, C(4) '  bright green circle
        CIRCLE (rock(Target).x + INT((RND - RND) * 30), rock(Target).y + INT((RND - RND) * 33)), 3, C(3) '  dark green circle
        redrawShip
    END IF

    PSET (rock(Target).x, rock(Target).y), rock(Target).col '
    DRAW "TA=" + VARPTR$(spin2) + rock(Target).kind '               draw rock
    PSET (rock(Target).x, rock(Target).y), C(0) '                 erase center dot   NOT WORKING for some reason, works elsewhere...

    IF c >= 500 THEN PAINT (rock(Target).x, rock(Target).y), _RGB32(0, 98, 0), C(4)
    IF c > 600 THEN
        _PUTIMAGE (rock(Target).x - 20, rock(Target).y - 20), I(0) '                                        final rock overlay
        CIRCLE (rock(Target).x + INT((RND - RND) * 20), rock(Target).y + INT((RND - RND) * 23)), 3, C(4) '  bright green circles
        CIRCLE (rock(Target).x + INT((RND - RND) * 20), rock(Target).y + INT((RND - RND) * 23)), 3, C(3) '  dark green circles
    END IF
    _PUTIMAGE (0, 530)-(1280, 720), MoonScape '                                 draw moonscape again to cover the rock edges upon landing
    IF c > 99 THEN
        LINE (xStart, yStart)-(rock(Target).x - 15, rock(Target).y), C(14) '    lasers move rock
        LINE (xStart, yStart)-(rock(Target).x + 15, rock(Target).y), C(14)
    END IF
    IF c > 642 THEN '                                                           done, reset
        c = 0: d = 0: e = 0: alpha = 0
        Sb.rockMoving = FALSE: SubFlags(13) = FALSE
        bannerON = FALSE
        rock(Target).stayPainted = TRUE '                           triggers the new '3D' rock image in shipControl
        _SNDSTOP S(22) '                                            kill tractor beam sound
    END IF
END SUB
' -----------------------------------------
SUB checkLanding () '                       rock drop checking

    SHARED AS STRING shipType()
    SHARED AS INTEGER diffX
    '                                                                                                               x and y position already checked in main loop
    IF Ship.Vy < .85 AND Ship.Vy > 0 AND ABS(Ship.Vx) < .5 AND (-Ship.course >= 356 OR -Ship.course <= 4) THEN '    check y vector, x vector, ship orientation (upright)
        killNoises
        _SNDPLAY S(3)
        Ship.kind = shipType(4)
        Ship.landed = TRUE '
        Ship.Vx = 0: Ship.Vy = 0
        Ship.y = 564 '                      put it on the pad
        Ship.speed = 0: Ship.course = 0
        Flag.thrustersOn = FALSE '          kill thrusters for 2 secs after landing
        Time.ThrustersOff = TIMER '         start timer
        IF NOT Resetter(28) THEN Game.score = Game.score + (500 * Game.diff_mult) '
        IF NOT Resetter(28) AND diffX = 277 THEN Game.score = Game.score + 150 '        extra points for MEDIUM difficulty
        IF NOT Resetter(28) AND diffX = 413 THEN Game.score = Game.score + 300 '        extra, extra bonus points for HARD difficulty...
        Resetter(28) = TRUE
        redrawShip '
    END IF
END SUB
' -----------------------------------------
SUB check4Harpoon ()

    SHARED AS INTEGER lockedAngle
    DIM spin AS INTEGER

    IF NOT Flag.harpooned AND Ship.x > rock(Target).x - 10 AND Ship.x < rock(Target).x + 10 THEN '  check for ship and target rock overlap
        IF Ship.y > rock(Target).y - 10 AND Ship.y < rock(Target).y + 10 THEN
            IF _KEYDOWN(32) THEN
                _SNDPLAY S(14)
                ' make the ship controls work on the rock, turn off drawRocks on target only
                rock(Target).rotation = FALSE
                spin = rock(Target).spinAngle
                DRAW "TA=" + VARPTR$(spin) + rock(Target).kind
                lockedAngle = Ship.course '
                Flag.harpooned = TRUE
                Flag.shutBackDoor = TRUE
                Game.score = Game.score + (500 * Game.diff_mult)
            END IF
        END IF
    END IF
END SUB
' -----------------------------------------
SUB check4RockContact () '                  circle proximity - collision detection
    '                                       Thanks, Terry Ritchie
    SHARED AS rect cBox, wBox
    DIM AS _BYTE c, w

    w = 0: c = 0 '                                              compare rock(c) to others, rocks (w)
    DO
        c = c + 1
        w = c
        DO
            w = w + 1
            cBox.x1 = rock(c).x - rock(c).radius '              calculate rectangular coordinates
            cBox.y1 = rock(c).y - rock(c).radius '              for rock c and rock w
            cBox.x2 = rock(c).x + rock(c).radius '
            cBox.y2 = rock(c).y + rock(c).radius
            wBox.x1 = rock(w).x - rock(w).radius
            wBox.y1 = rock(w).y - rock(w).radius
            wBox.x2 = rock(w).x + rock(w).radius
            wBox.y2 = rock(w).y + rock(w).radius
            IF RectCollide(cBox, wBox) THEN '                   rectangular collision?
                IF CircCollide(rock(c), rock(w)) THEN '         circle collision?
                    checkRockCollision c, w '                   collision happened!
                    checkFor3WayLockUp c, w
                END IF
            END IF
        LOOP UNTIL w = MaxRocks
    LOOP UNTIL c = MaxRocks - 1
END SUB
'------------------------------------------
SUB checkFor3WayLockUp (c AS _BYTE, w AS _BYTE) '   rocks c & w are now possibly stuck, check for another culprit

    DIM AS _BYTE a, b, dummy

    a = 0
    dummy = c
    DO
        a = a + 1
        IF a = 2 THEN dummy = w '                   on second run thru check the w rock
        b = 0
        DO
            b = b + 1
            IF b <> c AND b <> w THEN '
                IF CircCollide(rock(dummy), rock(b)) THEN '
                    ' make all three vectors opposite vectors
                    _SNDPLAY S(2)
                    repel3 b, c, w '                push the three apart
                END IF
            END IF
        LOOP UNTIL b = MaxRocks - 1
    LOOP UNTIL a = 2
END SUB
' -----------------------------------------
SUB check4ShipROCKCollision () '

    SHARED AS rect cBox, wBox
    SHARED AS INTEGER rockHeading '
    DIM AS INTEGER w '
    STATIC AS _BYTE played, oldW

    w = 0
    DO
        w = w + 1
        cBox.x1 = Ship.x - Ship.radius '                    calculate rectangular coordinates
        cBox.y1 = Ship.y - Ship.radius '                    for ship and rock w
        cBox.x2 = Ship.x + Ship.radius '
        cBox.y2 = Ship.y + Ship.radius
        wBox.x1 = rock(w).x - rock(w).radius
        wBox.y1 = rock(w).y - rock(w).radius
        wBox.x2 = rock(w).x + rock(w).radius
        wBox.y2 = rock(w).y + rock(w).radius
        IF w <> Target THEN '                               exclude the purple rock
            IF RectCollide(cBox, wBox) THEN '               rectangular collision?
                IF CircCollide2(Ship, rock(w)) THEN '       circle collision?
                    IF Ship.shields <= 0 THEN '             ship explodes when doAutoShields are spent
                        Ship.shields = 0
                        shipBoom: Ship.power = 5 '                              prevent double ship
                        Game.score = Game.score - (100 * Game.diff_mult) '        boom penalty
                        Time.overlap = 0 '                                      reset overlap cycles
                        EXIT SUB
                    ELSEIF NOT Flag.harpooned THEN '                            bounce off with auto shields
                        _SNDPLAYCOPY S(7), .27 '                                deflection sound
                        rockHeading = (Vec2Deg%(rock(w).Vx, rock(w).Vy)) '      both are in negative degrees
                        Ship.course = rockHeading - 45 '                        course change
                        IF Ship.speed < 1 THEN Ship.speed = 1.1
                        Flag.doCircle = TRUE
                        Sb.trackShields = TRUE: SubFlags(11) = TRUE
                        Ship.shields = Ship.shields - .64 '
                        Game.score = Game.score - (2 * Game.diff_mult) '
                        Ship.power = Ship.power - .4
                    ELSE '                                                      ship/rock contact with harpooned rock
                        IF oldW <> w THEN played = FALSE '                      rock takes ship's vector plus 8%
                        IF NOT played THEN _SNDPLAYCOPY S(1), .85: played = TRUE '  a righteous loud thump
                        rock(w).Vx = Ship.Vx * 1.06 '                           bounce it! <<<< new new new
                        rock(w).Vy = -Ship.Vy * 1.06
                        oldW = w
                    END IF
                END IF
            END IF
        END IF
    LOOP UNTIL w = MaxRocks
END SUB
' -----------------------------------------
SUB checkRockCollision (c AS INTEGER, w AS INTEGER) '       collisions between rock(c) & rock(w)

    STATIC AS INTEGER oldC, oldW
    DIM AS INTEGER hypot, overlap, push '

    SWAP rock(c).Vx, rock(w).Vx '                           Thanks to ** Will Kluger ** for help with this routine
    SWAP rock(c).Vy, rock(w).Vy '                           always swap colliding rocks vectors upon collision
    IF NOT _SNDPLAYING(S(1)) THEN _SNDPLAYCOPY S(1), .13 '  thump

    IF c = oldC AND w = oldW THEN '            ****** TROUBLE > if it's the same two rocks again, then push them apart
        hypot = findHypot(rock(c), rock(w)) '                   calculate how far to push them, uses slow SQR() but only a little
        overlap = (rock(c).radius + rock(w).radius) - hypot
        push = overlap / 2 + 4 ' 3                                      # of pixels needed each way (x, y) to achieve separation (and a bit more)
        ' counter measures for pushing 2 rocks out of a stuck state  '  ** TROUBLESHOOTING ** OVERLAP BUZZER goes here **
        IF rock(c).x > rock(w).x THEN '                                 push locations apart based on relative position
            rock(c).x = rock(c).x + push
            rock(w).x = rock(w).x - push
        ELSE IF rock(c).x <= rock(w).x THEN
                rock(w).x = rock(w).x + push
                rock(c).x = rock(c).x - push
            END IF
        END IF
        IF rock(c).y > rock(w).y THEN
            rock(c).y = rock(c).y + push '
            rock(w).y = rock(w).y - push
        ELSE IF rock(c).y <= rock(w).y THEN
                rock(w).y = rock(w).y + push
                rock(c).y = rock(c).y - push
            END IF
        END IF
        oldC = 0 '                  reset rocks to compare
        oldW = 0
        EXIT SUB '                  don't save old rock pair below, skip rotation change
    END IF
    oldC = c: oldW = w '            save collision pair to compare to next cycle's pair
    ' ----------------------
    IF rock(c).rotation THEN '                                                                      flip rotation randomly
        IF rock(c).rotDir = "clock" THEN rock(c).rotDir = "cClock" ELSE rock(c).rotDir = "clock" '  rocks initially are 1 or 2 spinspeed
        IF rock(c).spinSpeed = 2 THEN rock(c).spinSpeed = 1
    END IF
    IF rock(w).rotation THEN
        IF rock(w).rotDir = "clock" THEN rock(w).rotDir = "cClock" ELSE rock(w).rotDir = "clock"
        IF rock(w).spinSpeed = 1 THEN rock(w).spinSpeed = 2 ELSE rock(w).spinSpeed = 1 ' 2, 3
    END IF
END SUB
' -----------------------------------------
SUB checkShipCOMETCollision () '

    SHARED AS rect cBox, wBox
    SHARED comet() AS comet
    DIM AS INTEGER w

    w = 0
    DO
        w = w + 1
        IF comet(w).alive THEN
            cBox.x1 = Ship.x - Ship.radius '                calculate rectangular coordinates
            cBox.y1 = Ship.y - Ship.radius '                for rock c and rock w
            cBox.x2 = Ship.x + Ship.radius '
            cBox.y2 = Ship.y + Ship.radius
            wBox.x1 = comet(w).x - comet(w).radius
            wBox.y1 = comet(w).y - comet(w).radius
            wBox.x2 = comet(w).x + comet(w).radius
            wBox.y2 = comet(w).y + comet(w).radius

            IF RectCollide(cBox, wBox) THEN '               rectangular collision?
                IF CircCollide3(Ship, comet(w)) THEN '      circle collision?
                    Ship.shields = Ship.shields - 4 '       shields
                    Game.score = Game.score - (25 * Game.diff_mult) '   score
                    Ship.power = Ship.power - 1.7 '         power
                    IF NOT Flag.boomInProgress THEN '       mew mew mew <<<<
                        Sb.doSparks = TRUE: SubFlags(8) = TRUE: boomInfo.num = 6
                        boomInfo.r = 255: boomInfo.g = 168: boomInfo.b = 6 '    do comet explosion only
                    END IF
                    comet(w).alive = FALSE
                    _SNDPLAY S(INT(RND * 3 + 4))
                    IF Ship.shields > 14 THEN
                        Flag.doCircle = TRUE '              show shield
                        Sb.trackShields = TRUE: SubFlags(11) = TRUE
                    END IF

                    IF Ship.shields <= 0 THEN '
                        Ship.shields = 0 '                  prevent gauge from showing -1 on shields
                        Flag.doCircle = FALSE
                        Sb.trackShields = FALSE: SubFlags(11) = FALSE
                        Sb.checkCometCollisions = FALSE: SubFlags(10) = FALSE
                        IF NOT Flag.boomInProgress THEN shipBoom: Ship.power = 5: Ship.shields = 5 ' adding power prevents double shipBooms
                        Game.score = Game.score - (100 * Game.diff_mult)
                    END IF
                END IF
            END IF
        END IF
    LOOP UNTIL w = UBOUND(comet)
END SUB
' -----------------------------------------
SUB checkShipGRIDCollision () '

    SHARED AS rect cBox, wBox
    SHARED AS gridRock matrix()
    DIM AS INTEGER row, column

    row = 0
    DO
        row = row + 1
        column = 0
        DO
            column = column + 1
            IF matrix(column, row).alive THEN
                cBox.x1 = Ship.x - Ship.radius '        calculate rectangular coordinates
                cBox.y1 = Ship.y - Ship.radius '        for rock c and rock w
                cBox.x2 = Ship.x + Ship.radius '
                cBox.y2 = Ship.y + Ship.radius
                wBox.x1 = matrix(column, row).x - 10 '  the radius of the tiny rocks
                wBox.y1 = matrix(column, row).y - 10
                wBox.x2 = matrix(column, row).x + 10
                wBox.y2 = matrix(column, row).y + 10

                IF RectCollide(cBox, wBox) THEN '                                           rectangular collision?
                    IF CircCollide4(Ship, matrix(column, row)) THEN '                       circle collision?
                        IF matrix(column, row).col <> _RGB32(215, 165, 89, 110) THEN '      if not bonus rocks then
                            Game.score = Game.score - (15 * Game.diff_mult)
                            Ship.shields = Ship.shields - 2.7
                            Ship.power = Ship.power - .7

                            IF Ship.shields <= 0 THEN '
                                Ship.shields = 0
                                Flag.doCircle = FALSE
                                Sb.trackShields = FALSE: SubFlags(11) = FALSE
                                Sb.checkGridCollisions = FALSE: SubFlags(6) = FALSE
                                IF NOT Flag.boomInProgress THEN shipBoom: Ship.power = 5: Ship.shields = 5 '    <<<< NEW IF
                                CIRCLE (Ship.x, Ship.y - 1), 18, C(0) '
                                Game.score = Game.score - (100 * Game.diff_mult)
                            END IF

                            IF NOT Flag.boomInProgress THEN ' new new new <<<< trying to get green pixels every time for ship explosions <<<<
                                Sb.doSparks = TRUE: SubFlags(8) = TRUE '        exploding gridrock
                                boomInfo.num = 7: boomInfo.r = 160 '            color of sparks
                                boomInfo.g = 160: boomInfo.b = 160 '
                            END IF
                            _SNDPLAY S(INT(RND * 3 + 4)) '                      one of 3 boom sounds

                            IF Ship.shields > 14 THEN '       gauges turn off when moonscape rolls in, no more shields circle artifacts
                                Flag.doCircle = TRUE '                          show shield
                                Sb.trackShields = TRUE: SubFlags(11) = TRUE
                            END IF
                        ELSE '                                                  if bonus rocks then
                            _SNDPLAYCOPY S(18), .15
                            IF Ship.shields < 97 THEN
                                Ship.shields = Ship.shields + 1.9 '
                                Game.score = Game.score + (50 * Game.diff_mult)
                                IF Ship.power < 98 THEN Ship.power = Ship.power + 1
                            ELSE IF Ship.power < 97 THEN Ship.power = Ship.power + 1.2 '
                            END IF
                            Flag.doCircle = FALSE
                        END IF
                        matrix(column, row).alive = FALSE
                        Sb.trackShields = TRUE: SubFlags(11) = TRUE
                    END IF
                END IF
            END IF
        LOOP UNTIL column = 20
    LOOP UNTIL row = 11
END SUB
' -----------------------------------------
SUB initCOMETS () '                         use the comets array for showers too

    DIM AS INTEGER c
    SHARED AS comet comet()
    SHARED rockType() AS STRING
    SHARED AS INTEGER maxComets

    c = 0
    DO '
        c = c + 1 '
        IF Game.round < 2 THEN '
            comet(c).Vx = RND + 3 '
            comet(c).x = INT(RND * -750 - 30)
        ELSE
            comet(c).Vx = RND - 4 '
            comet(c).x = INT(RND * 750 + _WIDTH) '
        END IF
        comet(c).Vy = (RND * SGN(RND - RND)) '
        comet(c).y = INT(RND * 680 + 35)
        comet(c).kind = rockType(1)
        comet(c).rotAng = INT(RND * 359 + 1)
        comet(c).rotSign = -1
        comet(c).radius = 9 ' was 10
        comet(c).rotSpeed = 7 + (RND * 9)
        comet(c).col = _RGB32(45, 32, 0)
        IF c MOD 3 = 0 THEN comet(c).col = _RGB32(82, 58, 0)
        comet(c).edge = _RGB32(218, 85, 6)
        comet(c).alive = TRUE
    LOOP UNTIL c = maxComets '
END SUB
' -----------------------------------------

SUB runCOMETS ()

    DIM AS INTEGER c, d, spin, antiHeading, dist
    DIM AS INTEGER xPointEnd, yPointEnd, xPointStart, yPointStart
    DIM AS DOUBLE radians
    DIM AS _BYTE done
    SHARED AS comet comet()
    SHARED AS LONG microMask
    SHARED AS INTEGER maxComets
    STATIC AS _BYTE cometRounds, initd

    IF Control.clearStatics THEN
        cometRounds = 0
        initd = FALSE
        EXIT SUB
    END IF
    IF NOT initd THEN FPS = 58: initd = TRUE
    IF Game.round > 1 THEN Flag.shutFrontDoor = TRUE
    c = 0
    DO
        c = c + 1
        IF comet(c).alive THEN '                                                        draw comets
            _PUTIMAGE (comet(c).x - 10, comet(c).y - 10), microMask
            PRESET (comet(c).x, comet(c).y), comet(c).edge '                            outside of comet
            spin = INT(comet(c).rotAng)
            DRAW "TA=" + VARPTR$(spin) + comet(c).kind
            PSET (comet(c).x, comet(c).y), _RGB32(0)
            IF c MOD 2 = 0 THEN PAINT (comet(c).x + 1, comet(c).y + 1), comet(c).col, comet(c).edge ' only paint half cuz windows hates PAINT
            ' -----------------------------                                             opposite heading for flames
            antiHeading = (-Vec2Deg(comet(c).Vx, -comet(c).Vy)) '                       ** FLAME ZONE **     negative Vy here <<<<
            antiHeading = antiHeading + 90 '                                            adjust for QB64
            radians = _D2R(antiHeading)
            dist = INT(RND * 56 + 15) '                                                 distance for end of flames
            IF c MOD 2 = 0 THEN '                                                       half the comets have a tail
                xPointEnd = dist * COS(radians) + comet(c).x
                yPointEnd = dist * SIN(radians) + comet(c).y
                xPointStart = 13 * COS(radians) + comet(c).x '                          13 is dist from center of comet
                yPointStart = 13 * SIN(radians) + comet(c).y
                LINE (xPointStart - 1, yPointStart)-(xPointEnd, yPointEnd), _RGB32(255, 0, 0) '         center flame line
                LINE (xPointStart - 1, yPointStart - 2)-(xPointEnd, yPointEnd), comet(c).edge '         two V shaping lines
                LINE (xPointStart - 1, yPointStart + 2)-(xPointEnd, yPointEnd), _RGB32(255, 194, 94)
            END IF
            xPointStart = 7 * COS(radians) + comet(c).x '                               side flames
            yPointStart = 7 * SIN(radians) + comet(c).y '                               rework points for side flames
            xPointEnd = (dist / 2.2) * COS(radians) + comet(c).x
            yPointEnd = (dist / 2.2) * SIN(radians) + comet(c).y
            d = INT(RND * 3 + 1)
            IF d = 1 THEN
                LINE (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 210, 102) ' outer flame lines
            ELSE LINE (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 150, 132)
                IF d = 2 THEN
                    LINE (xPointStart, yPointStart - 6)-(xPointEnd, yPointEnd - 6), _RGB32(255, 210, 102)
                    LINE (xPointStart, yPointStart + 6)-(xPointEnd, yPointEnd + 6), _RGB32(255, 180, 142)
                END IF
            END IF
            LINE (xPointStart, yPointStart + 8)-(xPointEnd, yPointEnd + 8), _RGB32(255, 132, 98)
        END IF
    LOOP UNTIL c = maxComets '

    c = 0
    DO '                                        move comets
        c = c + 1
        comet(c).x = comet(c).x + comet(c).Vx
        comet(c).y = comet(c).y + comet(c).Vy
        comet(c).rotAng = comet(c).rotAng + comet(c).rotSpeed * comet(c).rotSign
        '   rules for comet runs
        IF Game.round = 1 THEN
            IF comet(c).x > _WIDTH + 50 THEN comet(c).alive = FALSE '
        ELSE
            IF comet(c).x < -50 THEN comet(c).alive = FALSE '
        END IF
        IF comet(c).y > _HEIGHT + 40 OR comet(c).y < -30 THEN comet(c).alive = FALSE
    LOOP UNTIL c = UBOUND(comet)

    done = TRUE '                               assume done
    c = 0
    DO
        c = c + 1
        IF comet(c).alive THEN done = FALSE '   check for done
    LOOP UNTIL c = UBOUND(comet)

    IF done THEN
        cometRounds = cometRounds + 1
        IF cometRounds < 3 THEN FPS = FPS + 4 '
        initCOMETS '
        IF (Game.round = 1 AND cometRounds = 3) OR (Game.round > 1 AND cometRounds = 2) THEN '  get out
            Sb.doComets = FALSE: SubFlags(9) = FALSE
            Flag.shutBackDoor = FALSE
            initShowers
            Sb.doShowers = TRUE: SubFlags(20) = TRUE '                      meteor shower
            cometRounds = 0
            initd = FALSE
            IF Game.round = 1 THEN _SNDPLAY VO(11) ELSE _SNDPLAY VO(43) '   incoming rocks or diamond VO
            Time.grid = TIMER '                                             track delay till running grid
        END IF
    END IF
END SUB
' -----------------------------------------
SUB initGRID ()

    DIM AS _BYTE row, column
    DIM AS INTEGER rand, rand2
    SHARED matrix() AS gridRock

    row = 0 '                                                       initialize matrix
    DO
        row = row + 1
        column = 0
        DO
            column = column + 1
            matrix(column, row).x = column * -80 - 80 ' was 65      X spacing
            IF column MOD 2 = 0 THEN
                matrix(column, row).y = (30 + 69 * row) - 85 '      even Y num columns staggered
            ELSE matrix(column, row).y = (65 * row) '               odd Y spacing
            END IF

            IF Game.round = 1 THEN
                matrix(column, row).speed = 1
            ELSE matrix(column, row).speed = 1.25 '                 speed up grid for round 2 - if this sub is used again...
            END IF
            matrix(column, row).rotAng = INT(RND * 358 + 1) '       initial rotation
            rand = INT(RND * 4 + 1): rand2 = INT(RND * 42 + 1) '
            IF rand2 MOD 6 = 0 AND row <> 1 AND row <> 11 THEN matrix(column, row).special = TRUE '  speeders - No speeders offscreen
            IF rand2 MOD 2 = 0 THEN
                matrix(column, row).col = _RGB32(RND * 36 + 18) '   fill color / light grays
            ELSE matrix(column, row).col = _RGB32(0)
            END IF

            IF rand2 = 22 OR rand2 = 16 THEN '                                                  arbitrary rnds, 1 outa 21 odds
                IF matrix(column, row).y > 20 AND matrix(column, row).y < _HEIGHT - 100 THEN '  no goldies too close to top/bot edges
                    matrix(column, row).col = _RGB32(215, 165, 89, 110) '                       bonus orangy rocks <<
                END IF
            END IF

            matrix(column, row).alive = TRUE '                      all rocks start alive
            SELECT CASE rand '                                      half the rocks spin
                CASE 1: matrix(column, row).rotSign = 1 '           some clockwise, some counter
                CASE 2: matrix(column, row).rotSign = -1
                CASE 3: matrix(column, row).rotSign = 0: matrix(column, row).yJiggle = -1 '     25% jiggle vertically
                CASE 4: matrix(column, row).rotSign = 0
            END SELECT
            SELECT CASE column
                CASE 1: matrix(column, row).x = column * INT(RND * -120 + 40) - 80 '            spread out first couple / last couple columns
                CASE 2: matrix(column, row).x = column * -80 + INT(RND * -90 + 65) - 80
                CASE 19: matrix(column, row).x = column * -80 + INT(RND * -90) - 80
                CASE 20: matrix(column, row).x = 20 * -80 + INT(RND * -120) - 80
            END SELECT
        LOOP UNTIL column = 20
    LOOP UNTIL row = 11
    matrix(20, 1).special = FALSE '             this rock is used to track the end of the grid and can't be a speeder
END SUB
' -----------------------------------------

SUB runGRID ()

    SHARED AS LONG microMask
    SHARED AS gridRock matrix()
    SHARED AS STRING rockType()
    DIM AS _BYTE row, column, doneGrid
    DIM AS INTEGER spin
    STATIC AS _BYTE worthPlayed
    STATIC AS SINGLE count, up, killSub

    IF Control.clearStatics THEN
        count = 0
        up = 0
        killSub = FALSE
        EXIT SUB
    END IF
    Flag.shutFrontDoor = FALSE '                    insurance
    '                                           ** MATRIX LOOPS **
    row = 0 '
    DO
        row = row + 1 '                             draw matrix
        column = 0
        DO
            column = column + 1
            IF matrix(column, row).alive THEN
                spin = matrix(column, row).rotAng

                _PUTIMAGE (matrix(column, row).x - 10, matrix(column, row).y - 10), microMask '      block the background stars
                PRESET (matrix(column, row).x, matrix(column, row).y), _RGB32(130) '
                DRAW "TA=" + VARPTR$(spin) + rockType(1)
                IF matrix(column, row).col = _RGB32(215, 165, 89, 110) OR matrix(column, row).col <> _RGB32(0) THEN '       only paint speeders and non-black gridrocks
                    PAINT (matrix(column, row).x + 1, matrix(column, row).y + 1), matrix(column, row).col, _RGB32(130) '    painting all slows performance big time
                END IF
                PSET (matrix(column, row).x, matrix(column, row).y), _RGB32(0) '    kill middle pixel
            END IF
        LOOP UNTIL column = 20
    LOOP UNTIL row = 11

    row = 0 '                                                                       move matrix
    DO
        row = row + 1
        column = 0
        DO
            column = column + 1
            IF matrix(column, row).alive THEN
                IF INT(RND * 3 + 1) = 2 THEN
                    matrix(column, row).x = matrix(column, row).x + matrix(column, row).speed + (RND - RND) '           wiggly X
                ELSE matrix(column, row).x = matrix(column, row).x + matrix(column, row).speed '
                END IF
                IF matrix(column, row).special THEN matrix(column, row).x = matrix(column, row).x + .31 '               speeders
                IF matrix(column, row).yJiggle THEN matrix(column, row).y = matrix(column, row).y + (RND - RND) '       wiggly Y
                matrix(column, row).rotAng = matrix(column, row).rotAng + (RND * 2 + 1) * matrix(column, row).rotSign ' spin the rocks
                IF matrix(column, row).x > _WIDTH + 30 THEN matrix(column, row).alive = FALSE '     assign as dead when offscreen - ONE WAY ONLY CHECK <<<<
            END IF
        LOOP UNTIL column = 20
    LOOP UNTIL row = 11
    ' ------------------                                        ** MOONSCAPE CONTROL **
    IF matrix(20, 1).x > 2 THEN '                               move moonScape to the right onto screen
        IF count < 1281 THEN
            count = count + 2.1
            _PUTIMAGE (-1280 + count, 633), MoonScape '         start it lower then move it up when done sliding over
            IF Ship.y > 637 - up THEN Ship.y = 637 - up '       keep ship above moonscape - ** SHIP CONTROLS ** <<<<
            IF Ship.y < 10 THEN Ship.y = 10 '                   keep ship below outer-space as warning to user
        END IF
        IF count > 600 AND count < 604 THEN prioritizeVO 9 '    gravity warning
        IF (count > 1000 AND count < 1004) AND Ship.y > 440 THEN _SNDPLAY VO(44) '
        IF count >= 1280 AND up < 104 THEN '   '
            up = up + 1: count = 1280 '                         new - count = 1280 - was jerking into place @ end <<<<
            _PUTIMAGE (1280 - count, 633 - up), MoonScape '     move moonscape up into position
            IF Ship.y > 637 - up THEN Ship.y = 637 - up '       keep ship above moonscape
            IF Ship.y < 10 THEN Ship.y = 10 '                   keep ship below outer-space as warning to user
        END IF
        IF up = 11 THEN prioritizeVO 10 '                       switching to landing mode
        IF up = 52 THEN _SNDPLAY S(40) '                        new timing <<<< gravity warning sound
        IF up >= 101 THEN '                                     if moonscape set then kill it
            Flag.showMoonScape = TRUE
            Flag.landingTime = TRUE
            IF NOT Flag.speedUp AND NOT Sb.doPopUp THEN FPS = Game.landingSpeed '   user determined landing speed **
            killSub = TRUE '
        END IF
    END IF
    ' -----------------
    IF matrix(3, 1).x > 130 AND NOT worthPlayed THEN
        prioritizeVO 7 '                                        played once only - worth
        worthPlayed = TRUE '                                    asteroid worth $$ VO here
    END IF
    ' -----------------                                         check for done
    IF matrix(20, 1).x > 100 THEN '
        doneGrid = TRUE '                                       assume done
        row = 0 '
        DO
            row = row + 1
            column = 0
            DO
                column = column + 1
                IF matrix(column, row).alive THEN
                    IF Ship.x < matrix(20, 1).x THEN
                        matrix(column, row).speed = 2.1 '       speed up at end
                        IF matrix(20, 1).x > _WIDTH - 180 THEN Sounds.fadeOutGrid = TRUE ' kill grid loop here
                    END IF
                    IF matrix(column, row).alive THEN doneGrid = FALSE '        if one's alive then not done yet
                END IF
            LOOP UNTIL column = 20
        LOOP UNTIL row = 11
        IF doneGrid AND killSub THEN
            Sb.doGrid = FALSE: SubFlags(5) = FALSE '
            killSub = FALSE '                       reset this all on the way out
            count = 0: up = 0
            initGRID '                              reset grid
            killChecks '                            turn off various checks during landing time
        END IF
    END IF
END SUB
' -----------------------------------------
SUB initShowers ()

    DIM AS _BYTE c
    SHARED AS comet comet()
    SHARED AS STRING rockType()
    SHARED AS INTEGER maxComets

    c = 0
    DO '                                            initialize showers, using the comets array
        c = c + 1
        comet(c).Vx = (RND * SGN(RND - RND)) '
        comet(c).Vy = RND * 2.6 + 1.7 '
        comet(c).x = INT(RND * 1280) '
        comet(c).y = -INT(RND * 15 + 10) '  -10
        comet(c).kind = rockType(14) '              tenny-weenie
        comet(c).rotAng = INT(RND * 359 + 1)
        comet(c).rotSign = -1
        comet(c).rotSpeed = 7 + (RND * 9)
        comet(c).edge = _RGB32(218, 85, 6) '        outer color
        comet(c).alive = TRUE
    LOOP UNTIL c = maxComets '
END SUB
' -----------------------------------------

SUB runSHOWERS ()

    DIM AS INTEGER c, d, spin, antiHeading, dist
    DIM AS INTEGER xPointEnd, yPointEnd, xPointStart, yPointStart
    DIM AS DOUBLE radians
    DIM AS _BYTE done
    SHARED AS comet comet()
    SHARED AS INTEGER maxComets
    STATIC AS _BYTE cometRounds

    IF Control.clearStatics THEN cometRounds = 0: EXIT SUB
    c = 0
    DO '                                                            draw showers
        c = c + 1
        IF comet(c).alive THEN
            PRESET (comet(c).x, comet(c).y), comet(c).edge
            spin = INT(comet(c).rotAng)
            DRAW "TA=" + VARPTR$(spin) + comet(c).kind
            PSET (comet(c).x, comet(c).y), _RGB32(0)
            ' ------------------------------------------                                opposite heading for flames
            antiHeading = (Vec2Deg(-comet(c).Vx, -comet(c).Vy)) '  ** FLAME ZONE **     negative Vy AND Vx here
            antiHeading = antiHeading + 90 '                                            adjust for QB64
            radians = _D2R(antiHeading)
            dist = INT(RND * 36 + 12) '                                                 distance for end of flames
            IF c MOD 2 = 0 THEN '                                                       half the comets have a big tail
                xPointEnd = dist * COS(radians) + comet(c).x
                yPointEnd = dist * SIN(radians) + comet(c).y
                xPointStart = 13 * COS(radians) + comet(c).x '                                      13 is dist from center of comet
                yPointStart = 13 * SIN(radians) + comet(c).y
                LINE (xPointStart - 1, yPointStart - 8)-(xPointEnd, yPointEnd), _RGB32(255, 0, 0) ' center flame line
                LINE (xPointStart - 1, yPointStart - 2)-(xPointEnd, yPointEnd), comet(c).edge '     two V shaping lines
                LINE (xPointStart - 1, yPointStart + 2)-(xPointEnd, yPointEnd), _RGB32(255, 194, 94)
            END IF
            xPointStart = 7 * COS(radians) + comet(c).x '                                           side flames
            yPointStart = 7 * SIN(radians) + comet(c).y '                                           rework points for side flames
            xPointEnd = (dist / 2.2) * COS(radians) + comet(c).x
            yPointEnd = (dist / 2.2) * SIN(radians) + comet(c).y
            d = INT(RND * 3 + 1)
            IF d = 1 THEN
                LINE (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 210, 102)
            ELSE LINE (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 150, 132)
                IF d = 2 THEN
                    LINE (xPointStart, yPointStart - 6)-(xPointEnd, yPointEnd - 6), _RGB32(255, 210, 102)
                    LINE (xPointStart, yPointStart - 6)-(xPointEnd, yPointEnd + 6), _RGB32(255, 180, 142)
                END IF
            END IF
            LINE (xPointStart, yPointStart - 8)-(xPointEnd, yPointEnd - 8), _RGB32(255, 132, 98) '  outer flame lines
        END IF
    LOOP UNTIL c = maxComets ' -----------------

    c = 0
    DO '                                            move mini comets
        c = c + 1
        comet(c).x = comet(c).x + comet(c).Vx
        comet(c).y = comet(c).y + comet(c).Vy
        comet(c).rotAng = comet(c).rotAng + comet(c).rotSpeed * comet(c).rotSign
        IF comet(c).y > _HEIGHT + 20 THEN '                                         defines dead mini-comets - off screen
            comet(c).alive = FALSE '
            Sounds.fadeOutComs = TRUE '
        END IF
        IF comet(c).y > _HEIGHT / 2 + 100 THEN
            IF Game.round = 1 THEN
                Sb.doGrid = TRUE: SubFlags(5) = TRUE '
                Sb.checkGridCollisions = TRUE: SubFlags(6) = TRUE ' don't start the grid too early, it slows down gameplay with both subs running!
                IF comet(c).y > _HEIGHT - 100 THEN Sounds.fadeInGRID = TRUE '
            END IF
        END IF
    LOOP UNTIL c = maxComets
    ' ----------------------------
    done = TRUE '                                   assume done
    c = 0
    DO
        c = c + 1
        IF comet(c).alive THEN done = FALSE '       check for done
    LOOP UNTIL c = UBOUND(comet)
    IF done THEN
        Sb.doShowers = FALSE: SubFlags(20) = FALSE
        Sb.checkCometCollisions = FALSE: SubFlags(10) = FALSE
        IF Game.round > 1 THEN Sb.doGauntlet = TRUE: SubFlags(21) = TRUE: Flag.harpooned = FALSE '
    END IF
END SUB
' -----------------------------------------
SUB flyBy ()

    STATIC AS INTEGER flyX, flyY, rand, rand2 '
    STATIC AS _BYTE initd
    STATIC AS SINGLE adder, rotAng
    STATIC AS _UNSIGNED LONG shipCol
    SHARED AS STRING shipType()

    IF Control.clearStatics THEN initd = FALSE: EXIT SUB
    IF NOT initd THEN
        rand = INT(RND * 2 + 1) '               50/50 right/left
        rand2 = INT(RND * 2 + 1)
        flyY = INT(RND * 230 + 30) '            start em a little lower
        initd = TRUE
        IF rand2 = 1 THEN shipCol = C(3) ELSE shipCol = C(10)
        IF rand = 1 THEN '                      leftward
            rotAng = INT(RND * 42 + 35)
            adder = -3
            flyX = _WIDTH + 10
        ELSE
            rotAng = INT(RND * -42 - 35) '      rightward
            adder = 3.1
            flyX = -10
        END IF
    END IF
    IF rand = 1 THEN
        rotAng = rotAng - .095 '
    ELSE rotAng = rotAng + .095
    END IF

    flyX = flyX + adder
    flyY = flyY + (RND - RND) * .7
    IF rotAng < 42 AND rotAng > -42 THEN '
        flyY = flyY - 1
        IF rand = 1 THEN
            adder = -2.4
        ELSE adder = 2.4
        END IF
    END IF
    PSET (flyX, flyY), C(14)
    DRAW "TA=" + VARPTR$(rotAng) + shipType(2)
    PAINT (flyX, flyY - 1), shipCol, C(14)
    IF flyX > _WIDTH + 10 OR flyX < -10 THEN
        Sb.doFlyBy = FALSE: SubFlags(14) = FALSE
        initd = FALSE
    END IF

    IF flyX >= Ship.x - 10 AND flyX <= Ship.x + 10 THEN '   ** BOOM CHECK ** flyby ship collision with main ship?
        IF flyY >= Ship.y - 10 AND flyY <= Ship.y + 10 THEN
            shipBoom
        END IF
    END IF
END SUB
' -----------------------------------------

SUB soundCenter () '

    SHARED AS _BYTE delayVO '
    SHARED AS LONG timer3, warnSnd

    IF TIMER - Time.gameStart < 1 THEN _SNDVOL S(28), .0005: Resetter(6) = FALSE '                       NEW, don't restart harvestLoop loud
    IF Flag.landingTime AND _SNDPLAYING(S(17)) THEN _SNDSTOP S(17) '                                     if top-last grid rock is blown up and grid loop never stops...
    ' self-terminating sound events    SndFade2 = snd, changeAmnt, goal, presVol, resetter(#) to kill
    IF NOT Resetter(5) AND Sb.doRocks THEN _SNDLOOP S(28): Resetter(5) = TRUE '                          loop harvest background
    IF NOT Resetter(6) AND Sb.doRocks THEN SndFade2 S(28), .0003, .054, .001, 6 '                        turn up harvest loop
    IF NOT Resetter(7) AND Sb.doComets THEN SndFade2 S(28), -.009, 0, .052, 7 '                          turn off harvest loop
    IF NOT Resetter(8) AND Sb.doComets THEN _SNDLOOP S(29): Resetter(8) = TRUE '                         loop comet background
    IF NOT Resetter(9) AND Sb.doComets THEN SndFade1 S(29), .004, .35, 0, 9 '                            turn up comet loop
    IF NOT Resetter(10) AND (Sb.doGrid OR Sb.doGauntlet) THEN SndFade2 S(29), -.006, 0, .4, 10 '         turn off cl
    IF NOT Resetter(11) AND Flag.landingTime THEN _SNDLOOP S(30): Resetter(11) = TRUE '                  loop landing background
    IF NOT Resetter(12) AND Flag.landingTime THEN SndFade1 S(30), .0001, .008, 0, 12 '                   turn up landing loop
    IF NOT Resetter(13) AND Sb.go2Space THEN SndFade2 S(30), -.00011, 0, .009, 13 '                      turn off landing loop
    IF NOT Resetter(14) AND Sb.doFF THEN SndFade2 S(31), -.003, 0, .05, 14 '                             turn off saucer loop
    IF NOT Resetter(15) AND Flag.landingTime THEN _SNDPLAY VO(26): Resetter(15) = TRUE: prioritizeVO 26 'land with rock, KILL OTHER VOs

    IF TIMER - Time.gameStart > 1 AND TIMER - Time.gameStart < 1.1 THEN
        IF NOT OneTimeSnd(3) THEN '
            _SNDPLAY VO(3) '                    "auto-Shields ON" in beginning
            OneTimeSnd(3) = TRUE
        END IF
    END IF
    IF TIMER - Time.gameStart > 4 AND TIMER - Time.gameStart < 4.1 THEN
        IF NOT OneTimeSnd(4) THEN '
            IF NOT IsVOPlaying THEN '           "scanning target" VO can overlap this w/o VOcheck...
                _SNDPLAY VO(27) '               "first scan rock"
                OneTimeSnd(4) = TRUE
            ELSE TIMER(timer3) ON
                delayVO = 27
                OneTimeSnd(4) = TRUE '
            END IF
        END IF
    END IF '
    ' ***********************************
    IF NOT Resetter(25) AND Ship.charged THEN SndFade1 S(21), -.007, 0, .45, 25 '
    IF NOT Resetter(2) AND Flag.harpooned AND NOT Sb.doPopUp THEN '                                     added popUp protection
        Time.comets = TIMER '                                                                        ** TRANSITION TO COMETS **
        Resetter(2) = TRUE
        IF _SNDPLAYING(VO(5)) THEN _SNDSTOP VO(5) '                                                     howToCapture
        _SNDPLAY (VO(8)) '                                                                              nice job and WARNING
        warnSnd = TIMER
        Flag.warn = TRUE
    END IF
    IF NOT Control.endIt AND Flag.warn AND TIMER - warnSnd > 4 THEN _SNDPLAY S(16): Flag.warn = FALSE ' warning beeper
    IF _SNDPLAYING(S(16)) AND NOT Control.endIt THEN
        _SNDLOOP S(15) '                                                                                start comet sound low
        Sounds.fadeInComs = TRUE '
    END IF '                               ' was 7 secs below    -
    IF NOT Resetter(1) AND TIMER - time.comets > 5 AND flag.harpooned_
     AND NOT sb.doRocks AND NOT sb.doPopUp THEN '                                                    ** ACTIVATE COMETS **
        Sb.doComets = TRUE: SubFlags(9) = TRUE '                                                        release the hounds
        Sb.checkCometCollisions = TRUE: SubFlags(10) = TRUE
        Resetter(1) = TRUE
    END IF '
    IF NOT Resetter(18) AND Sounds.fadeInComs AND NOT Control.endIt THEN SndFade2 S(15), .002, .32, .001, 18 ' sound, changeAmnt, goal, presVol, resetter #
    IF NOT Resetter(21) AND Sounds.fadeOutComs THEN SndFade2 S(15), -.0015, 0, .32, 21 '
    IF NOT Resetter(0) AND Sb.doGrid THEN _SNDLOOP S(17): Resetter(0) = TRUE '
    IF NOT Resetter(4) AND Sounds.fadeInGRID THEN SndFade1 S(17), .001, .035, .01, 4 '
    IF NOT Resetter(3) AND Sounds.fadeOutGrid THEN SndFade2 S(17), -.001, 0, .04, 3 '
    IF NOT OneTimeSnd(0) AND Flag.doPractice THEN _SNDPLAY VO(34): OneTimeSnd(0) = TRUE
END SUB
' -----------------------------------------
SUB SndFade1 (snd AS LONG, amount AS SINGLE, goal AS SINGLE, presVol AS SINGLE, a AS _BYTE)

    STATIC AS _BYTE loaded '
    STATIC AS SINGLE volume

    IF NOT loaded THEN volume = presVol: loaded = TRUE
    volume = volume + amount
    _SNDVOL snd, volume

    IF SGN(amount) = 1 AND volume >= goal THEN '            if fade in
        Resetter(a) = TRUE
        IF NOT Control.endIt THEN loaded = FALSE
    END IF
    IF SGN(amount) = -1 AND volume <= 0.001 THEN '          if fade out
        Resetter(a) = TRUE
        loaded = FALSE
        _SNDSTOP snd
    END IF
END SUB
' -----------------------------------------
SUB SndFade2 (snd AS LONG, amount AS SINGLE, goal AS SINGLE, presVol AS SINGLE, a AS _BYTE) '

    STATIC AS _BYTE loaded '
    STATIC AS SINGLE volume

    IF NOT loaded THEN volume = presVol: loaded = TRUE
    volume = volume + amount
    _SNDVOL snd, volume

    IF SGN(amount) = 1 AND volume >= goal THEN '            if fade in
        Resetter(a) = TRUE
        IF NOT Control.endIt THEN loaded = FALSE
    END IF
    IF SGN(amount) = -1 AND volume <= 0.001 THEN '          if fade out
        Resetter(a) = TRUE
        loaded = FALSE
        _SNDSTOP snd
    END IF
END SUB
' -----------------------------------------
SUB drawStars () '                          starscape backdrops
    DIM AS INTEGER c, d, v, w, x, y, z '
    DIM AS LONG virtual
    SHARED AS LONG starScape, saucerScape, starScape2
    DATA 3000,2000,16,46,330,5400,2500,30,100,500: '     num loops
    d = 0
    DO: d = d + 1
        SELECT CASE d
            CASE 1: virtual = _NEWIMAGE(1280, 720, 32)
                READ v, w, x, y, z
            CASE 2: virtual = _NEWIMAGE(1280, 720, 32)
            CASE 3: virtual = _NEWIMAGE(1600, 900, 32)
                READ v, w, x, y, z
        END SELECT

        _DEST virtual
        c = 0: DO: c = c + 1 '
            PSET ((INT(RND * _WIDTH)), INT(RND * _HEIGHT)), C(15) '                     whites
        LOOP UNTIL c = v
        c = 0: DO: c = c + 1
            PSET ((INT(RND * _WIDTH)), INT(RND * _HEIGHT)), C(1) '                      grays
        LOOP UNTIL c = w
        c = 0: DO: c = c + 1
            PSET ((INT(RND * _WIDTH)), INT(RND * _HEIGHT)), _RGB32(255, 67, 55, 124) '  reds
            DRAW "S2U1R1D1L1"
        LOOP UNTIL c = x
        c = 0: DO: c = c + 1
            PSET ((INT(RND * _WIDTH)), INT(RND * _HEIGHT)), _RGB32(0, 255, 0, 116) '    greens
            DRAW "S2U1R1D1L1"
        LOOP UNTIL c = y
        c = 0: DO: c = c + 1
            PRESET ((INT(RND * _WIDTH)), INT(RND * _HEIGHT)), _RGB32(255, 255, 183, 120) '  big yellows
            DRAW "S4U1R1D1L1"
        LOOP UNTIL c = z

        IF d <> 3 THEN
            _PUTIMAGE (INT(RND * 300 + 150), INT(RND * 450 + 100)), I(11) '             add heavenly bodies
            _PUTIMAGE (INT(RND * 300 + 900), INT(RND * 480 + 65)), I(12)
            _PUTIMAGE (INT(RND * 460 + 300), INT(RND * 450 + 140)), I(17)
        END IF

        SELECT CASE d
            CASE 1: starScape = _COPYIMAGE(virtual, 32) '       software images
            CASE 2: starScape2 = _COPYIMAGE(virtual, 32)
            CASE 3: saucerScape = _COPYIMAGE(virtual, 32)
        END SELECT
        CLS '                                                   clear virtual screen
    LOOP UNTIL d = 3
    _DEST 0: _FONT 16
    _FREEIMAGE virtual
    RESTORE
END SUB
' -----------------------------------------
SUB drawRocks () '                          spin and draw

    DIM AS INTEGER c, spin
    STATIC AS SINGLE d
    SHARED AS LONG miniMask

    IF Control.clearStatics THEN d = 0: EXIT SUB
    c = 0
    DO
        c = c + 1
        IF Flag.harpooned THEN IF c = Target THEN _CONTINUE '       drawing the target rock is done in shipControl sub

        IF Flag.fadeInRocks THEN '                                  fade in from dissolve sub
            IF d < 171 THEN d = d + .15
            IF c <> Target THEN
                rock(c).col = _RGB32(d)
            ELSE rock(c).col = _RGB32(205, 122, 255, d + 50)
            END IF
            IF d > 90 THEN Flag.doRockMask = TRUE
            IF d > 169 THEN Flag.fadeInRocks = FALSE: d = 0 '       turn off, reset
        END IF

        IF rock(c).rotation THEN
            IF rock(c).rotDir = "cClock" THEN rock(c).spinAngle = rock(c).spinAngle + rock(c).spinSpeed
        ELSE rock(c).spinAngle = rock(c).spinAngle - rock(c).spinSpeed
        END IF
        IF rock(c).spinAngle > 359 OR rock(c).spinAngle < -359 THEN rock(c).spinAngle = 0
        IF Flag.doRockMask THEN _PUTIMAGE (rock(c).x - rock(c).radius + 1, rock(c).y - rock(c).radius + 1), miniMask ' blocks the starscape from inside the rocks
        PRESET (rock(c).x, rock(c).y), rock(c).col '
        spin = rock(c).spinAngle
        IF rock(c).alive THEN DRAW "TA=" + VARPTR$(spin) + rock(c).kind '   only draw living rocks
        PSET (rock(c).x, rock(c).y), C(0) '                                 erase the center dot in rocks
    LOOP UNTIL c = MaxRocks
END SUB
' -----------------------------------------
SUB rockNav () '                            advance rocks and off-screen / on-screen controls

    DIM AS INTEGER c

    Sb.doRocks = FALSE: SubFlags(1) = FALSE '                                           assume rocks are done
    c = 0
    DO
        c = c + 1
        IF Flag.harpooned THEN IF c = Target THEN _CONTINUE
        rock(c).x = rock(c).x + rock(c).Vx * rock(c).speed '                            advance rocks
        rock(c).y = rock(c).y - rock(c).Vy * rock(c).speed '
        IF NOT Flag.harpooned THEN
            IF rock(c).x < -rock(c).radius * .7 THEN rock(c).x = _WIDTH + rock(c).radius * .7 - 1 ' on-screen / off-screen behavior
            IF rock(c).x > _WIDTH + rock(c).radius * .7 THEN rock(c).x = -rock(c).radius * .7 + 1 '
            IF rock(c).y < -rock(c).radius * .7 THEN rock(c).y = _HEIGHT + rock(c).radius * .7 - 1 '
            IF rock(c).y > _HEIGHT + rock(c).radius * .7 THEN rock(c).y = -rock(c).radius * .7 + 1
        ELSE
            IF rock(c).x < -rock(c).radius * .7 THEN rock(c).alive = FALSE '            on-screen / off-screen behavior AFTER HARPOONING
            IF rock(c).x > _WIDTH + rock(c).radius * .7 THEN rock(c).alive = FALSE '
            IF rock(c).y < -rock(c).radius * .7 THEN rock(c).alive = FALSE '
            IF rock(c).y > _HEIGHT + rock(c).radius * .7 THEN rock(c).alive = FALSE
        END IF
        IF rock(c).alive THEN Sb.doRocks = TRUE: SubFlags(1) = TRUE '                   keep rocks going
        IF Flag.harpooned THEN rock(c).speed = 2.2 '                                    speed up other rocks after harpooning target
    LOOP UNTIL c = MaxRocks

    IF NOT Sb.doRocks THEN '
        Sb.checkFSC = FALSE: SubFlags(7) = FALSE
    END IF
END SUB
' -----------------------------------------
SUB back2Space () '                         after rock drop & recharge
    STATIC AS INTEGER d
    SHARED AS LONG timer2

    IF Control.clearStatics THEN d = 0: EXIT SUB
    d = d + 2
    _PUTIMAGE (rock(Target).x - 20, (rock(Target).y - 20) + d), I(0) ' keep rock image alive during back2space sub
    _PUTIMAGE (0, 533 + d), MoonScape '         move moonscape down
    IF d > 180 THEN '   delay this more to prevent shipboom post-charge @ top of screen     moonscape out of scene
        Flag.landingTime = FALSE
        Flag.gotPastLanding = TRUE
        rock(Target).stayPainted = FALSE '
        Sb.go2Space = FALSE: SubFlags(12) = FALSE
        Flag.harpooned = FALSE
        Ship.speed = 2.5
        TIMER(timer2) ON
        _SNDPLAY VO(19) '                       battleMode
        _SNDSTOP S(30) '
        d = 0
    END IF
END SUB
' -----------------------------------------
FUNCTION findHypot% (circ1 AS rock, circ2 AS rock)
    DIM SideA% ' side A length of right triangle
    DIM SideB% ' side B length of right triangle
    SideA% = circ1.x - circ2.x '                                    calculate length of side A
    SideB% = circ1.y - circ2.y '                                    calculate length of side B
    findHypot% = INT(SQR(SideA% * SideA% + SideB% * SideB%)) '      calculate hypotenuse
END FUNCTION
' -----------------------------------------
FUNCTION Vec2Deg% (Vx AS SINGLE, Vy AS SINGLE) ' Turns vector pairs into negative degrees to work with program
    Vec2Deg% = -(360## + _R2D(_ATAN2(Vx, Vy))) MOD 360## '   <<<< Steve McNeill's code <<<<
END FUNCTION '                                                   Thanx, Steve
' -----------------------------------------
SUB flipOnShip '                            turn on ship after explosions
    SHARED AS LONG timer1 '
    SHARED AS Sector sector()
    SHARED AS _BYTE prezSector

    Sb.doShip = TRUE: SubFlags(2) = TRUE
    IF NOT Flag.doPractice THEN turnOnChecks '      added IF NOT...
    Flag.shipBoomDone = FALSE '
    Flag.doAutoShields = TRUE
    Ship.shields = 100
    Ship.power = 100: Ship.course = 0 '
    IF NOT Sb.doGauntlet THEN Ship.x = CENTX: Ship.y = CENTY
    IF Sb.doGauntlet THEN
        Ship.x = 1000 + INT(RND * 250) '
        Ship.y = 550 + INT(RND * 60)
        prezSector = 1
        stopCheck = FALSE
    END IF
    Ship.speed = 0: Ship.Vx = 0: Ship.Vy = 0
    IF Sb.doComets THEN Ship.speed = 2
    IF Sb.doGrid THEN Ship.speed = 1
    IF Flag.landingTime AND NOT Sb.doFF THEN Ship.y = 20
    TIMER(timer1) OFF
    Flag.boomInProgress = FALSE '
END SUB
' -----------------------------------------
SUB flipOnSaucers ()
    SHARED AS LONG timer2
    TIMER(timer2) OFF
    Sb.doSaucers = TRUE: SubFlags(16) = TRUE
END SUB
' -----------------------------------------
SUB flipOnBuyIn
    SHARED AS LONG timer4
    Sb.doBuyIn = TRUE
    Control.hold = TRUE '                   hold game during buy ship offer
    TIMER(timer4) OFF
END SUB
' ----------------------------------------
SUB redrawShip ()
    DIM spin AS INTEGER
    spin = Ship.course
    PRESET (Ship.x, Ship.y), Ship.col
    DRAW "TA=" + VARPTR$(spin) + Ship.kind '
    PAINT (Ship.x, Ship.y - 1), C(3), Ship.col
END SUB
' -----------------------------------------
SUB killNoises () '                         after ship explodes, or other events, stop all thruster noises
    SHARED played AS _BYTE
    IF _SNDPLAYING(S(8)) OR _SNDPLAYING(S(9)) OR _SNDPLAYING(S(10)) OR _SNDPLAYING(S(11)) THEN
        _SNDSTOP S(8): _SNDSTOP S(9): _SNDSTOP S(10): _SNDSTOP S(11)
        played = FALSE
    END IF
END SUB
' -----------------------------------------
SUB killChecks ()
    Sb.checkFSC = FALSE: SubFlags(7) = FALSE
    Sb.checkCometCollisions = FALSE: SubFlags(10) = FALSE
    Sb.checkGridCollisions = FALSE: SubFlags(6) = FALSE
END SUB
' -----------------------------------------
SUB turnOnChecks ()
    IF Sb.doRocks THEN Sb.checkFSC = TRUE: SubFlags(7) = TRUE
    IF Sb.doComets OR Sb.doShowers THEN Sb.checkCometCollisions = TRUE: SubFlags(10) = TRUE
    IF Sb.doGrid THEN Sb.checkGridCollisions = TRUE: SubFlags(6) = TRUE
END SUB
' -----------------------------------------
SUB autoShields () '                        activated by sb.trackShields after a collision with autoShields turned ON
    STATIC AS _BYTE shieldCount
    shieldCount = shieldCount + 1
    IF Flag.doCircle THEN CIRCLE (Ship.x, Ship.y - 1), 18, C(14)
    IF shieldCount > 110 THEN
        Sb.trackShields = FALSE: SubFlags(11) = FALSE
        shieldCount = 0
        Flag.doCircle = FALSE '
    END IF
END SUB
' -----------------------------------------
SUB blowUp '                                tracks the sparks generation
    SHARED AS _BYTE sparkCycles
    sparkCycles = sparkCycles + 1
    IF sparkCycles < boomInfo.num THEN MakeSparks Ship.x, Ship.y '
    UpdateSparks
END SUB
' -----------------------------------------
SUB showHorzGauge (x AS INTEGER, y AS INTEGER, amtDone AS SINGLE, gaugeLabel AS STRING, col AS _UNSIGNED LONG) '

    STATIC AS _BYTE shieldDot, powerDot, toggle, toggle2, initd, initd2
    STATIC AS INTEGER count, count2

    IF Control.clearStatics THEN initd = FALSE: initd2 = FALSE: EXIT SUB
    LINE (x, y)-(x + 100, y + 4), _RGB32(200, 200, 0), B '          yellow box
    LINE (x + 50, y)-(x + 50, y - 5), C(14) '                       mid box line
    LINE (x + 1, y + 1)-(x + 1 + (amtDone * 98), y + 3), col, BF '  filler color varies
    _FONT Modern
    COLOR C(16)
    _PRINTSTRING (x + 50 - _PRINTWIDTH(gaugeLabel) \ 2, y + 11), gaugeLabel

    IF NOT initd AND Ship.shields < 30 THEN
        shieldDot = TRUE
        toggle = 1
        initd = TRUE
    END IF
    IF NOT initd2 AND Ship.power < 30 THEN
        powerDot = TRUE
        toggle2 = 1
        initd2 = TRUE
    END IF
    IF shieldDot THEN
        count = count + 1
        IF count MOD 100 = 0 THEN toggle = -toggle
        IF toggle = 1 THEN
            CIRCLE (135, 97), 5, C(12)
            PAINT (135, 97), C(12), C(12)
        END IF
        IF Ship.shields > 29 THEN
            shieldDot = FALSE
            initd = FALSE
            count = 0
        END IF
    END IF
    IF powerDot THEN
        count2 = count2 + 1
        IF count2 MOD 100 = 0 THEN toggle2 = -toggle2
        IF toggle2 = 1 THEN
            CIRCLE (135, 65), 5, C(12)
            PAINT (135, 65), C(12), C(12)
        END IF
        IF Ship.power > 29 THEN
            powerDot = FALSE
            initd2 = FALSE
            count2 = 0
        END IF
    END IF '
    _FONT 16
END SUB
' -----------------------------------------
SUB showVertGauge (locX AS INTEGER, locY AS INTEGER) '

    STATIC AS _BYTE initDone
    STATIC AS SINGLE startY, alphaDelta, yDelta
    STATIC AS INTEGER botY, alpha '
    DIM AS SINGLE startPower
    DIM AS INTEGER maxPower, duration, numSteps, alphaChange

    IF Control.clearStatics THEN initDone = FALSE: EXIT SUB

    IF NOT initDone THEN
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
        initDone = TRUE
    END IF

    CIRCLE (locX, locY), 6, _RGB32(205, 227, 122, alpha), _D2R(360), _D2R(180) '        top         YELLOW SHELL
    CIRCLE (locX, botY), 6, _RGB32(205, 227, 122, alpha), _D2R(180), _D2R(0) '          bottom
    LINE (locX - 6, locY)-(locX - 6, botY), _RGB32(205, 227, 122, alpha) '              sides
    LINE (locX + 6, locY)-(locX + 6, botY), _RGB32(205, 227, 122, alpha)
    CIRCLE (locX, locY), 5, _RGB32(2), _D2R(360), _D2R(180) '                           top         INVIZZO SHELL
    CIRCLE (locX, botY), 5, _RGB32(2), _D2R(180), _D2R(0) '                             bottom
    LINE (locX - 5, locY)-(locX - 5, botY), _RGB32(2) '                                 sides
    LINE (locX + 5, locY)-(locX + 5, botY), _RGB32(2)
    startY = startY - yDelta '                                                          rising factor
    IF alpha < 254 THEN alpha = alpha + alphaDelta '                                    increase/decrease alpha
    LINE (locX - 5, startY)-(locX + 5, startY), _RGB32(2) '                             moving line
    PAINT (locX, botY - 3), _RGB32(255, 0, 0, alpha), _RGB32(2) '                       fill red

    IF startY < locY - 20 THEN '                                                        if done, then get this to run backwards to fade out
        alpha = 252
        alphaDelta = -alphaDelta * 2.7 '                                                fade out faster than fade in
        startY = startY + 200 '                                                         make startY well below "locY - 20" IF statement above
    END IF

    IF alpha < 10 THEN ' was 10
        initDone = FALSE '                                                              finish, reset for next charge
        Sb.doVertGauge = FALSE
        Ship.charged = TRUE '
        Resetter(25) = FALSE '              << reset flag for recharge over, allows multiple charges / kills charge sound
    END IF
END SUB
' -----------------------------------------
SUB quickSound (c AS INTEGER) '             how to play a sound inside a loop - isolate it
    SHARED AS _BYTE played '
    IF NOT played THEN _SNDLOOP S(c): played = TRUE
END SUB
' -----------------------------------------
SUB repel3 (b AS _BYTE, c AS _BYTE, w AS _BYTE) '   pushes the rocks apart - in theory
    DIM AS _BYTE count, g '
    DIM AS INTEGER rockAngle
    count = 0
    DO
        count = count + 1
        IF count = 1 THEN g = b '
        IF count = 2 THEN g = c
        IF count = 3 THEN g = w
        rockAngle = Vec2Deg(rock(g).Vx, rock(g).Vy) '           get corrected course of rock
        rockAngle = rockAngle + 180 '                           give it opposite angle vector
        IF rockAngle > 359 THEN rockAngle = rockAngle - 360 '   correct the angle as needed
        rock(g).Vx = COS(_D2R(rockAngle))
        rock(g).Vy = SIN(_D2R(rockAngle))
        rock(g).x = rock(g).x + rock(g).Vx * 3 '                bump the rock on its way
        rock(g).y = rock(g).y + rock(g).Vy * 3
    LOOP UNTIL count = 3
END SUB
' -----------------------------------------
SUB assignRocks ()

    DIM Length AS SINGLE
    DIM AS INTEGER c, rando
    SHARED rockType() AS STRING

    c = 0
    DO '
        c = c + 1
        rock(c).x = c * 60 '                                specific x locs to avoid bunching initially
        IF c MOD 2 = 0 THEN
            rock(c).y = c * 30 '                            y loc - ditto
        ELSE rock(c).y = c * 10
        END IF
        rock(c).size = 2 '                                  all rocks big to start, 1 = small rock
        rock(c).alive = TRUE '                              all rocks are alive!
        rock(c).radius = 22 '                               works well enough - sometimes they overlap, sometimes not quite touch...
        rock(c).col = C(15) '                               all rocks start white
        rock(c).speed = 1 '                                 use same rock speed for all or it looks wrong
        rock(c).rotDir = "clock" '                          first 6 rocks clockwise
        IF c > 6 THEN rock(c).rotDir = "cClock" '           next 6 counter-clockwise
        rock(c).spinAngle = 0 '                             zero spin angle at start
        rando = INT(RND * 2 + 1)
        IF rando = 1 THEN rock(c).rotation = TRUE ELSE rock(c).rotation = FALSE '   50/50 chance for rotation
        IF rando = 2 THEN rock(c).spinSpeed = 1 ELSE rock(c).spinSpeed = 2 '        50/50 chance fast/slow spin
        rock(c).Vx = (INT(RND * 5) + 1) * SGN(RND - RND) '                          rnd vector (-5 to 5)
        rock(c).Vy = (INT(RND * 5) + 1) * SGN(RND - RND) '
        Length = SQR(rock(c).Vx * rock(c).Vx + rock(c).Vy * rock(c).Vy) '           length of vector
        rock(c).Vx = rock(c).Vx / Length '                                          normalize vector
        rock(c).Vy = rock(c).Vy / Length
        IF c < 13 THEN rock(c).kind = rockType(c + 1) ELSE rock(c).kind = rockType(INT(RND * 11 + 2)) '  random rock assignment - 10 different rocks
    LOOP UNTIL c = MaxRocks

    Target = INT(RND * MaxRocks + 1)
    IF NOT Flag.harpooned THEN rock(Target).col = C(10) ELSE rock(Target).col = C(3) '
END SUB
' -----------------------------------------
SUB assignMoves () '                        scripted saucer runs
    SHARED AS STRING moves() '                                                                                  leave space at beginning, always use entries of 3 chars!
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
END SUB
' -----------------------------------------
SUB assignSaucers ()

    SHARED AS INTEGER shipNum, limit
    SHARED moves() AS STRING, saucer() AS saucer
    DIM AS INTEGER c, rand

    IF Game.killRatio >= 75 THEN shipNum = INT(RND * 3 + 6) ELSE shipNum = INT(RND * 5 + 4) '   set num of ships for attack run
    SELECT CASE shipNum '                                                                       better shooting = more bad guys
        CASE 4: limit = 72 '        frame rate adjustments for saucer quantity
        CASE 5: limit = 71
        CASE 6: limit = 70 '        I slowed these down a fair bit from a high of 76
        CASE 7: limit = 69
        CASE 8: limit = 68
        CASE 9: limit = 67
    END SELECT
    c = 0
    DO
        c = c + 1
        rand = INT(RND * 18 + 1)
        saucer(c).commands = moves(rand)
        saucer(c).movesNum = rand
        saucer(c).loc.x = INT(RND * 400 + 1600 \ 2 - 200) '     fairly random start point near center
        saucer(c).loc.y = INT(RND * 300 + 900 \ 2 - 150) '
        checkSaucerProx c '                                     check if same saucer patterns are too close to one another
        saucer(c).alive = TRUE
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
        saucer(c).getCommand = TRUE
    LOOP UNTIL c = shipNum
END SUB
' -----------------------------------------
SUB loadImages ()
    DIM c AS INTEGER
    DIM col AS _UNSIGNED LONG

    I(0) = _LOADIMAGE("Images/rock1.jpg")
    I(1) = _LOADIMAGE("Images/gun1.jpg")
    I(2) = _LOADIMAGE("Images/alien.jpg")
    I(3) = _LOADIMAGE("Images/moontruck.jpg")
    I(4) = _LOADIMAGE("Images/mouseDemo.jpg") ' ------ intro images
    I(5) = _LOADIMAGE("Images/keyDemo.jpg")
    I(6) = _LOADIMAGE("Images/rocksDemo.jpg")
    I(7) = _LOADIMAGE("Images/scanDemo.jpg")
    I(9) = _LOADIMAGE("Images/chargeDemo.jpg")
    I(8) = _LOADIMAGE("Images/landingDemo.jpg") ' -----------------
    I(10) = _LOADIMAGE("Images/coolRocket.jpg")
    I(11) = _LOADIMAGE("Images/galaxy1.jpg")
    I(12) = _LOADIMAGE("Images/galaxy2.jpg")
    I(13) = _LOADIMAGE("Images/aster2.jpeg")
    I(14) = _LOADIMAGE("Images/aster4.jpeg")
    I(15) = _LOADIMAGE("Images/aster1.jpeg")
    I(16) = _LOADIMAGE("Images/aster3.jpeg")
    I(17) = _LOADIMAGE("Images/quasar1.jpg")
    I(18) = _LOADIMAGE("Images/saucer.jpeg")
    I(19) = _LOADIMAGE("Images/oldSchool.jpg")
    I(20) = _LOADIMAGE("Images/analogDials.jpg")
    I(21) = _LOADIMAGE("Images/tubes.jpeg")
    I(22) = _LOADIMAGE("Images/tapeRack.jpeg")
    I(23) = _LOADIMAGE("Images/heavyMetal.jpg")
    I(24) = _LOADIMAGE("Images/workStation.jpg")
    I(25) = _LOADIMAGE("Images/servers.jpg")
    I(26) = _LOADIMAGE("Images/gauntlet.jpg")
    I(27) = _LOADIMAGE("Images/diamond.jpg")
    I(28) = _LOADIMAGE("Images/diamond2.jpg")
    FOR c = 0 TO UBOUND(I) '                    check for bad image handles
        IF I(c) >= -1 THEN '
            BEEP: CLS: PRINT "Image File Error - on File #"; c '  terminate on error
            _DELAY 3
            wrapUp: SYSTEM
        END IF
    NEXT
    FOR c = 0 TO UBOUND(I) '                    make all image backgrounds transparent
        IF c = 26 THEN _CONTINUE '              not ALL images - gauntlet has to be solid
        _SOURCE I(c)
        col = POINT(0, 0)
        _CLEARCOLOR col, I(c)
    NEXT c
END SUB
' -----------------------------------------
SUB loadSounds ()
    DIM c AS INTEGER
    S(0) = _SNDOPEN("Sounds/chirp.ogg")
    S(1) = _SNDOPEN("Sounds/epicthump.mp3"): _SNDVOL S(1), .7
    S(2) = _SNDOPEN("Sounds/click.ogg")
    S(3) = _SNDOPEN("Sounds/beeboop.ogg"): _SNDVOL S(3), .65
    S(4) = _SNDOPEN("Sounds/boom1.ogg"): _SNDVOL S(4), .5 'was .64
    S(5) = _SNDOPEN("Sounds/boom2.ogg"): _SNDVOL S(5), .24 ' .3
    S(6) = _SNDOPEN("Sounds/boom3.ogg"): _SNDVOL S(6), .24
    S(7) = _SNDOPEN("Sounds/deflect.ogg"): _SNDVOL S(7), .4
    S(8) = _SNDOPEN("Sounds/rocket.mp3"): _SNDVOL S(8), .1 '            MAIN THRUSTERS
    S(9) = _SNDOPEN("Sounds/quickburst.mp3"): _SNDVOL S(9), .3 '
    S(10) = _SNDOPEN("Sounds/shortair.mp3"): _SNDVOL S(10), .4 '        SIDE THRUSTERS
    S(11) = _SNDOPEN("Sounds/air.mp3"): _SNDVOL S(11), .13 '            OPEN SPACE THRUSTER SOUND
    S(12) = _SNDOPEN("Sounds/insectyShort.wav"): _SNDVOL S(12), .15
    S(13) = _SNDOPEN("Sounds/BBBB.mp3"): _SNDVOL S(13), .5
    S(14) = _SNDOPEN("Sounds/spaceHarpoon.mp3"): _SNDVOL S(14), .25
    S(15) = _SNDOPEN("Sounds/comets.mp3"): _SNDVOL S(15), .14 '
    S(16) = _SNDOPEN("Sounds/warning.mp3"): _SNDVOL S(16), .075
    S(17) = _SNDOPEN("Sounds/mysterio.wav"): _SNDVOL S(17), .01
    S(18) = _SNDOPEN("Sounds/bonus.mp3"): _SNDVOL S(18), .2
    S(19) = _SNDOPEN("Sounds/hydraulic.mp3"): _SNDVOL S(19), .23
    S(20) = _SNDOPEN("Sounds/zap.mp3"): _SNDVOL S(20), .25
    S(21) = _SNDOPEN("Sounds/charging.mp3"): _SNDVOL S(21), .25
    S(22) = _SNDOPEN("Sounds/fuzzyNoise.mp3"): _SNDVOL S(22), .25
    S(23) = _SNDOPEN("Sounds/heaven.mp3"): _SNDVOL S(23), .2
    S(24) = _SNDOPEN("Sounds/whip1.mp3"): _SNDVOL S(24), .2
    S(25) = _SNDOPEN("Sounds/zoom.mp3"): _SNDVOL S(25), .12
    S(26) = _SNDOPEN("Sounds/incoming.mp3"): _SNDVOL S(26), .4
    S(27) = _SNDOPEN("Sounds/laser.mp3"): _SNDVOL S(27), .3 '  ------------- loops
    S(28) = _SNDOPEN("Sounds/harvestloop.mp3"): _SNDVOL S(28), .0005 ' was .001
    S(29) = _SNDOPEN("Sounds/cometloop.ogg"): _SNDVOL S(29), .001
    S(30) = _SNDOPEN("Sounds/happy.mp3"): _SNDVOL S(30), 0
    S(31) = _SNDOPEN("Sounds/saucerloop.mp3"): _SNDVOL S(31), .001
    S(32) = _SNDOPEN("Sounds/ffloop.mp3"): _SNDVOL S(32), .0034 ' ----------
    S(33) = _SNDOPEN("Sounds/flash.mp3"): _SNDVOL S(33), .25
    S(34) = _SNDOPEN("Sounds/ominous.mp3"): _SNDVOL S(34), .36
    S(35) = _SNDOPEN("Sounds/funkyAlarm2.mp3"): _SNDVOL S(35), .38
    S(36) = _SNDOPEN("Sounds/blast.mp3")
    S(37) = _SNDOPEN("Sounds/impact.mp3")
    S(38) = _SNDOPEN("Sounds/splashLoop.mp3"): _SNDVOL S(38), .25
    S(39) = _SNDOPEN("Sounds/controlRoom.mp3"): _SNDVOL S(39), .21
    S(40) = _SNDOPEN("Sounds/gravity.mp3"): _SNDVOL S(40), .11 '
    S(41) = _SNDOPEN("Sounds/erupt1.mp3")
    S(42) = _SNDOPEN("Sounds/erupt2.mp3")
    S(43) = _SNDOPEN("Sounds/erupt3.mp3")
    S(44) = _SNDOPEN("Sounds/erupt4.mp3")
    S(45) = _SNDOPEN("Sounds/erupt5.mp3")
    S(46) = _SNDOPEN("Sounds/ghostly.mp3"): _SNDVOL S(46), .001
    S(47) = _SNDOPEN("Sounds/cheers.mp3"): _SNDVOL S(47), .12
    S(48) = _SNDOPEN("sounds/fireworks.mp3"): _SNDVOL S(48), .16
    FOR c = 0 TO UBOUND(S) '                                        check for bad sound handles
        IF S(c) <= 0 THEN '
            BEEP: CLS: PRINT "Sound Load Error - on File #"; c '    terminate on error
            _DELAY 3
            wrapUp: SYSTEM
        END IF
    NEXT
END SUB
' -----------------------------------------
SUB loadVOs ()
    DIM c AS INTEGER
    VO(1) = _SNDOPEN("VOs/scanning.mp3"): _SNDVOL VO(1), .15
    VO(2) = _SNDOPEN("VOs/doneScanning.mp3"): _SNDVOL VO(2), .15
    VO(3) = _SNDOPEN("VOs/shieldsOn.mp3"): _SNDVOL VO(3), .13 '
    VO(4) = _SNDOPEN("VOs/shieldsOff.mp3"): _SNDVOL VO(4), .15 '    unused
    VO(5) = _SNDOPEN("VOs/howToCapture.mp3"): _SNDVOL VO(5), .15
    VO(6) = _SNDOPEN("VOs/proceed.mp3"): _SNDVOL VO(6), .15 '       unused
    VO(7) = _SNDOPEN("VOs/worth.mp3"): _SNDVOL VO(7), .18
    VO(8) = _SNDOPEN("VOs/meteorites.mp3"): _SNDVOL VO(8), .18
    VO(9) = _SNDOPEN("VOs/gravity ahead.mp3"): _SNDVOL VO(9), .18
    VO(10) = _SNDOPEN("VOs/landingMode.mp3"): _SNDVOL VO(10), .18
    VO(11) = _SNDOPEN("VOs/rocks.mp3"): _SNDVOL VO(11), .22
    VO(12) = _SNDOPEN("VOs/detach.mp3"): _SNDVOL VO(12), .19
    VO(13) = _SNDOPEN("VOs/recharge.mp3"): _SNDVOL VO(13), .18
    VO(14) = _SNDOPEN("VOs/chargeDone.mp3"): _SNDVOL VO(14), .26
    VO(15) = _SNDOPEN("VOs/chargeAdvice.mp3"): _SNDVOL VO(15), .2
    VO(16) = _SNDOPEN("VOs/trapped.mp3"): _SNDVOL VO(16), .22
    VO(17) = _SNDOPEN("VOs/scanningUn.mp3"): _SNDVOL VO(17), .15
    VO(18) = _SNDOPEN("VOs/analysis.mp3"): _SNDVOL VO(18), .19
    VO(19) = _SNDOPEN("VOs/battlemode.mp3"): _SNDVOL VO(19), .18
    VO(20) = _SNDOPEN("VOs/unusual.mp3"): _SNDVOL VO(20), .3
    VO(21) = _SNDOPEN("VOs/leaving.mp3"): _SNDVOL VO(21), .16
    VO(22) = _SNDOPEN("VOs/remoteview.mp3"): _SNDVOL VO(22), .16
    VO(23) = _SNDOPEN("VOs/leaveOrbit.mp3"): _SNDVOL VO(23), .28
    VO(24) = _SNDOPEN("VOs/shieldsLow.mp3"): _SNDVOL VO(24), .19
    VO(25) = _SNDOPEN("VOs/lowPower.mp3"): _SNDVOL VO(25), .19 '
    VO(26) = _SNDOPEN("VOs/landWithRock.mp3"): _SNDVOL VO(26), .18
    VO(27) = _SNDOPEN("VOs/step1.mp3"): _SNDVOL VO(27), .18
    VO(28) = _SNDOPEN("VOs/remaining.mp3"): _SNDVOL VO(28), .2
    VO(29) = _SNDOPEN("VOs/SDestroyed.mp3"): _SNDVOL VO(29), .2
    VO(30) = _SNDOPEN("VOs/zero.mp3"): _SNDVOL VO(30), .2
    VO(31) = _SNDOPEN("VOs/one.mp3"): _SNDVOL VO(31), .2
    VO(32) = _SNDOPEN("VOs/two.mp3"): _SNDVOL VO(32), .2
    VO(33) = _SNDOPEN("VOs/rockAttached.mp3"): _SNDVOL VO(33), .2
    VO(34) = _SNDOPEN("VOs/endPractice.mp3"): _SNDVOL VO(34), .18
    VO(35) = _SNDOPEN("VOs/three.mp3"): _SNDVOL VO(35), .2
    VO(36) = _SNDOPEN("VOs/hint.mp3"): _SNDVOL VO(36), .25
    VO(37) = _SNDOPEN("VOs/targetAdvice.mp3"): _SNDVOL VO(37), .41 '
    VO(38) = _SNDOPEN("VOs/four.mp3"): _SNDVOL VO(38), .2 '
    VO(39) = _SNDOPEN("VOs/five.mp3"): _SNDVOL VO(39), .2 '
    VO(40) = _SNDOPEN("VOs/six.mp3"): _SNDVOL VO(40), .2 '
    VO(41) = _SNDOPEN("VOs/seven.mp3"): _SNDVOL VO(41), .2 '
    VO(42) = _SNDOPEN("VOs/eight.mp3"): _SNDVOL VO(42), .2 '
    VO(43) = _SNDOPEN("VOs/diamond.mp3"): _SNDVOL VO(43), .57 '      alert!
    VO(44) = _SNDOPEN("VOs/altWarn.mp3"): _SNDVOL VO(44), .24
    VO(45) = _SNDOPEN("VOs/exit.mp3"): _SNDVOL VO(45), .25
    VO(46) = _SNDOPEN("VOs/lava.mp3"): _SNDVOL VO(46), .2
    VO(47) = _SNDOPEN("VOs/nine.mp3"): _SNDVOL VO(47), .2
    FOR c = 1 TO UBOUND(VO) '                                       check for bad VO handles
        IF VO(c) <= 0 THEN
            BEEP: CLS: PRINT "Voice File Error - on File #"; c '    terminate on error
            _DELAY 3
            wrapUp: SYSTEM
        END IF
    NEXT
END SUB
' -----------------------------------------
SUB loadFonts ()
    Modern = _LOADFONT("Fonts/futura.ttc", 10) '
    ModernBig = _LOADFONT("Fonts/futura.ttc", 12)
    ModernBigger = _LOADFONT("Fonts/futura.ttc", 15)
    Menlo = _LOADFONT("Fonts/menlo.ttc", 15) ' was 16
    MenloBig = _LOADFONT("Fonts/menlo.ttc", 22)
    '                                                           check for bad font handles
    IF Modern <= 0 OR ModernBig <= 0 OR ModernBigger <= 0 OR Menlo <= 0 OR MenloBig <= 0 THEN
        BEEP: CLS: PRINT "Font Loading Error!" '                terminate on error
        _DELAY 3
        wrapUp: SYSTEM
    END IF
END SUB
'------------------------------------------
SUB loadShips ()
    SHARED shipType() AS STRING
    SHARED C() AS _UNSIGNED LONG
    SHARED shipImg AS LONG
    DIM temp AS _UNSIGNED LONG

    shipType(1) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BE11 BU3 BL1 C" + STR$(C(12)) + "U7" '          RETRO THRUSTERS
    shipType(2) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BR10 BD2 C" + STR$(C(12)) + "D7" '              forward thrust ship
    shipType(3) = "BU6 G5 F2 L3 G5 BE11 F4 G1 R2 F4 G3 L3 H3 G3 L3 H1 E1 D2 L5 BR11 BD2 D5" '   thrust damaged ship
    shipType(4) = "BU6 G11 BE11 F11 L8 H3 G3 L7" '                                              ship1
    shipType(5) = "BU6 BL7 G11 BR8 BE11 BR7 F11 BD11 BL8 L8 H3 G3 L7" '                         ship4
    shipType(6) = "BU6 BL4 G11 BR5 BE11 BR4 F11 BD7 BL5 L8 H3 G3 L7" '                          ship3
    shipType(7) = "BU6 BL2 G11 BR2 BE11 BR2 F11 BD3 BL2 L8 H3 G3 L7" '                          ship2
    shipType(8) = "BU6 G5 F2 L3 G5 BE11 F4 G1 R2 F4 G3 L3 H3 G3 L3 H1 E1 D2 L5 BR11" '          damaged ship
    shipType(9) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU11 BR6 C" + STR$(C(9)) + "L5" '               side jet left
    shipType(10) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU11 BR14 C" + STR$(C(9)) + "R5" '              "    "  right
    shipType(11) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU3 BL2 C" + STR$(C(11)) + "L7" '              side thruster left
    shipType(12) = "BU6 G11 BE11 F11 L8 H3 G3 L7 BU3 BR22 C" + STR$(C(11)) + "R7" '              "      "     right
    shipImg = _NEWIMAGE(40, 40, 32) '                                                           create one image of normal ship
    _DEST shipImg
    PRESET (_WIDTH / 2, _HEIGHT / 2), C(14) '
    DRAW shipType(4)
    PAINT (_WIDTH / 2 + 1, _HEIGHT / 2 - 2), C(3), C(14) '
    PSET (_WIDTH / 2, _HEIGHT / 2), C(3)
    _SOURCE shipImg
    temp = POINT(3, 3)
    _CLEARCOLOR temp, shipImg
    _DEST 0
    Ship.kind = shipType(4) '       initial ship assignments
    Ship.x = CENTX
    Ship.y = CENTY + 50
    Ship.course = 0 '
    Ship.col = C(14)
    Ship.radius = 8
END SUB
' -----------------------------------------
SUB loadRocks ()
    SHARED rockType() AS STRING
    rockType(1) = "BU10 L5 G2 L1 D4 F1 D2 G2 D3 F4 R4 E1 F2 R2 E3 U5 R1 U7 H3 L5" '                 teeny
    rockType(2) = "BU18L4D2L2H3G2L1G2H1G2L2D3R1D4R1F1D2G2H1D2F3R2G2L2G3F3D3F4R3F2R3E2U1E1R2F5R4E5L1U4E3R1U3H2U1R5U5H2U3L1H1U1E1U1L3U4l1h2L1H2G3L2H1U1" ' Will
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
END SUB
' -----------------------------------------
SUB loadColors () '
    SHARED C() AS _UNSIGNED LONG
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
END SUB
' -----------------------------------------
SUB loadMoonScape ()
    DIM AS LONG tempImg
    DIM AS _UNSIGNED LONG pix
    MoonScape = _NEWIMAGE(1281, 191, 32)
    tempImg = _LOADIMAGE("Images/moonscape.jpg")
    _SOURCE tempImg
    pix = POINT(0, 0)
    _CLEARCOLOR pix, tempImg
    _PUTIMAGE , tempImg, MoonScape, (0, 530)-(1280, 720)
    _FREEIMAGE tempImg
END SUB
' -----------------------------------------
SUB loadViewScreen () '                     1600 x 900 HDWR view screen for saucerControl sub
    DIM c AS INTEGER
    DIM temp AS LONG
    DIM AS INTEGER wide, high
    wide = 1600: high = 900
    temp = _NEWIMAGE(wide, high, 32)
    ViewScreen = _NEWIMAGE(wide, high, 32)
    _DEST temp
    LINE (0, 0)-(wide - 1, high - 1), C(2), B '             outer border box
    LINE (25, 25)-(wide - 25, high - 25), C(4), B '         inner border box
    PAINT (2, 2), C(1), C(4) '                              fill in the view screen
    c = 0
    DO
        c = c + 1 '                                         rivets for Will! Black circles painted gray inside.
        CIRCLE ((12 * (c * 4)) + 7, 12), 3, C(0) '          top
        PAINT ((12 * (c * 4)) + 7, 12), C(2), C(0) '
        CIRCLE (12, 9 * (c * 4)), 3, C(0) '                 left
        PAINT (12, 9 * (c * 4)), C(2), C(0)
        CIRCLE (wide - 13, 9 * (c * 4)), 3, C(0) '          right
        PAINT (wide - 13, 9 * (c * 4)), C(2), C(0)
        CIRCLE ((12 * (c * 4)) + 7, high - 12), 3, C(0) '   bot
        PAINT ((12 * (c * 4)) + 7, high - 12), C(2), C(0) '
    LOOP UNTIL c = 32
    ViewScreen = _COPYIMAGE(temp, 33) '      '              hardware image for sitting on top layer
    _DEST 0: _FONT 16
    _FREEIMAGE temp
END SUB
' -----------------------------------------
SUB MakeSparks (x AS INTEGER, y AS INTEGER) ' spark initiator <> Thanks Terry Ritchie for these routines
    '
    SHARED spark() AS spark '     dynamic array to hold sparks
    SHARED sparkNum AS INTEGER '  number of sparks to create at a time
    SHARED sparkLife AS INTEGER ' life span of spark in frames
    DIM CleanUp AS INTEGER '      TRUE is no life left in array
    DIM Count AS LONG '           spark counter
    DIM TopSpark AS LONG '        highest index in array
    DIM NewSpark AS LONG '        index in array to start adding new sparks

    CleanUp = TRUE '                                          assume no life left in array
    DO '                                                      begin spark life check
        IF spark(Count).Lifespan <> 0 THEN '                  is this spark alive?
            CleanUp = FALSE '                                 yes, array still has life
        END IF
        Count = Count + 1 '                                   increment spark counter
    LOOP UNTIL Count > UBOUND(spark) OR CleanUp = FALSE '     leave when life found or end of array reached
    IF CleanUp THEN REDIM spark(0) AS spark '                 if no life found then reset dynamic array
    TopSpark = UBOUND(spark) '                                identify array index starting point
    REDIM _PRESERVE spark(TopSpark + sparkNum + 1) AS spark ' increase array while saving living sparks
    Count = 0 '                                               reset spark counter
    RANDOMIZE TIMER '                                         seed RND generator
    DO '                                                      begin add spark loop
        Count = Count + 1 '                                   increment spark counter
        NewSpark = TopSpark + Count '                         next array index to use
        spark(NewSpark).Lifespan = sparkLife '                set spark life span
        spark(NewSpark).Location.x = x '                      set spark location
        spark(NewSpark).Location.y = y
        spark(NewSpark).Fade = 255 '                          set spark intensity
        spark(NewSpark).Velocity = INT(RND * 6) + 6 '         set random spark velocity
        spark(NewSpark).Vector.x = RND - RND '                set random spark vector
        spark(NewSpark).Vector.y = RND - RND
    LOOP UNTIL Count = sparkNum '                             leave when all sparks added
END SUB
'------------------------------------------
SUB UpdateSparks () '                       spark maintainer, by Terry Ritchie
    '                                       * Maintains any live sparks containied in the dynamic array
    SHARED spark() AS spark '               dynamic array to hold sparks
    SHARED AS _BYTE sparkCycles
    DIM Count AS LONG '           spark counter
    DIM FC0 AS _UNSIGNED LONG '   spark fade colors
    DIM FC1 AS _UNSIGNED LONG
    DIM FC2 AS _UNSIGNED LONG
    DIM Fade0 AS INTEGER '        spark fade color values
    DIM Fade1 AS INTEGER
    DIM Fade2 AS INTEGER
    DIM CleanUp AS INTEGER '      TRUE if no life left in array

    IF UBOUND(spark) = 0 THEN EXIT SUB '                                          leave if array cleared
    CleanUp = TRUE '                                                              assume no life left in array
    DO '                                                                          begin spark maintenance loop
        Count = Count + 1 '                                                       increment spark counter
        IF spark(Count).Lifespan THEN '                                           is this spark alive?
            CleanUp = FALSE '                                                     yes, array still has life
            Fade0 = spark(Count).Fade '                                           set the intensity values
            Fade1 = spark(Count).Fade \ 2
            Fade2 = spark(Count).Fade \ 4
            FC0 = _RGB32(boomInfo.r, boomInfo.g, boomInfo.b, Fade0) '                               create the intensity colors
            FC1 = _RGB32(boomInfo.r, boomInfo.g, boomInfo.b, Fade1)
            FC2 = _RGB32(boomInfo.r, boomInfo.g, boomInfo.b, Fade2)
            PSET (spark(Count).Location.x, spark(Count).Location.y), FC0 '        create pixels with intensities
            PSET (spark(Count).Location.x + 1, spark(Count).Location.y), FC1
            PSET (spark(Count).Location.x - 1, spark(Count).Location.y), FC1
            PSET (spark(Count).Location.x, spark(Count).Location.y + 1), FC1
            PSET (spark(Count).Location.x, spark(Count).Location.y - 1), FC1
            PSET (spark(Count).Location.x + 1, spark(Count).Location.y + 1), FC2
            PSET (spark(Count).Location.x - 1, spark(Count).Location.y - 1), FC2
            PSET (spark(Count).Location.x - 1, spark(Count).Location.y + 1), FC2
            PSET (spark(Count).Location.x + 1, spark(Count).Location.y - 1), FC2
            spark(Count).Fade = spark(Count).Fade - 128 / spark(Count).Lifespan ' decrease spark intensity
            '* update spark location
            spark(Count).Location.x = spark(Count).Location.x + spark(Count).Vector.x * spark(Count).Velocity
            spark(Count).Location.y = spark(Count).Location.y + spark(Count).Vector.y * spark(Count).Velocity
            spark(Count).Velocity = spark(Count).Velocity * .9 '                  decrease spark velocity
            spark(Count).Lifespan = spark(Count).Lifespan - 1 '                   decrese spark life span
        END IF
    LOOP UNTIL Count = UBOUND(spark) '                                            leave when last index reached
    IF CleanUp THEN '                                                             reset dynamic array if no life
        REDIM spark(0) AS spark
        Sb.doSparks = FALSE: SubFlags(8) = FALSE
        sparkCycles = 0
    END IF
END SUB
'------------------------------------------
FUNCTION CircCollide%% (Circ1 AS rock, Circ2 AS rock) '       Thanks, Terry Ritchie for these!
    '- Checks for the collision between two circular areas.     this is for rock to rock collisions
    DIM SideA% ' side A length of right triangle
    DIM SideB% ' side B length of right triangle
    DIM Hypot& ' hypotenuse squared length of right triangle (side C)
    CircCollide%% = 0 '                                     assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    IF Hypot& <= (Circ1.radius + Circ2.radius) * (Circ1.radius + Circ2.radius) THEN CircCollide = -1
END FUNCTION
' -----------------------------------------
FUNCTION CircCollide2%% (Circ1 AS ship, Circ2 AS rock) '      for ship to ROCK collisions
    DIM SideA% '
    DIM SideB% '
    DIM Hypot& '
    CircCollide2%% = 0 '                                      assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    IF Hypot& <= (Circ1.radius + Circ2.radius) * (Circ1.radius + Circ2.radius) THEN CircCollide2 = -1
END FUNCTION
' -----------------------------------------
FUNCTION CircCollide3%% (Circ1 AS ship, Circ2 AS comet) '      for ship to COMET collisions
    DIM SideA%
    DIM SideB%
    DIM Hypot&
    CircCollide3%% = 0 '                                      assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    IF Hypot& <= (Circ1.radius + Circ2.radius) * (Circ1.radius + Circ2.radius) THEN CircCollide3 = -1
END FUNCTION
' -----------------------------------------
FUNCTION CircCollide4%% (Circ1 AS ship, Circ2 AS gridRock) '      for ship to GRID collisions
    DIM SideA%
    DIM SideB%
    DIM Hypot&
    CircCollide4%% = 0 '                                      assume no collision
    SideA% = Circ1.x - Circ2.x '                            calculate length of side A
    SideB% = Circ1.y - Circ2.y '                            calculate length of side B
    Hypot& = SideA% * SideA% + SideB% * SideB% '            calculate hypotenuse squared
    IF Hypot& <= (Circ1.radius + 10) * (Circ1.radius + 10) THEN CircCollide4 = -1 '
END FUNCTION
' -----------------------------------------
FUNCTION RectCollide%% (Rect1 AS rect, Rect2 AS rect) '       Thanks, Terry Ritchie for this!
    '- Checks for the collision between two rectangular areas.
    RectCollide%% = 0 '                           assume no collision
    IF Rect1.x2 >= Rect2.x1 THEN '              rect 1 lower right X >= rect 2 upper left  X ?
        IF Rect1.x1 <= Rect2.x2 THEN '          rect 1 upper left  X <= rect 2 lower right X ?
            IF Rect1.y2 >= Rect2.y1 THEN '      rect 1 lower right Y >= rect 2 upper left  Y ?
                IF Rect1.y1 <= Rect2.y2 THEN '  rect 1 upper left  Y <= rect 2 lower right Y ?
                    RectCollide = -1 '          if all 4 IFs true then a collision must be happening
                END IF
            END IF
        END IF
    END IF
END FUNCTION
' -----------------------------------------
SUB RotateImage (Degree AS SINGLE, InImg AS LONG, OutImg AS LONG)
    '** This subroutine based on code provided by Rob (Galleon) on the QB64.NET website in 2009.
    DIM px(3) AS INTEGER '     x vector values of four corners of image
    DIM py(3) AS INTEGER '     saucer(c).loc.y vector values of four corners of image
    DIM Left AS INTEGER '      left-most value seen when calculating rotated image size
    DIM Right AS INTEGER '     right-most value seen when calculating rotated image size
    DIM Top AS INTEGER '       top-most value seen when calculating rotated image size
    DIM Bottom AS INTEGER '    bottom-most value seen when calculating rotated image size
    DIM RotWidth AS INTEGER '  width of rotated image
    DIM RotHeight AS INTEGER ' height of rotated image
    DIM WInImg AS INTEGER '    width of original image
    DIM HInImg AS INTEGER '    height of original image
    DIM Xoffset AS INTEGER '   offsets used to move (0,0) back to upper left corner of image
    DIM Yoffset AS INTEGER
    DIM COSr AS SINGLE '       cosine of radian calculation for matrix rotation
    DIM SINr AS SINGLE '       sine of radian calculation for matrix rotation
    DIM x AS SINGLE '          new x vector of rotated point
    DIM y AS SINGLE '          new saucer(c).loc.y vector of rotated point
    DIM v AS INTEGER '         vector counter

    IF OutImg THEN _FREEIMAGE OutImg '              free any existing image
    WInImg = _WIDTH(InImg) '                        width of original image
    HInImg = _HEIGHT(InImg) '                       height of original image
    px(0) = -WInImg / 2 '                                                  -x,-saucer(c).loc.y ------------------- x,-saucer(c).loc.y
    py(0) = -HInImg / 2 '             Create points around (0,0)     px(0),py(0) |                 | px(3),py(3)
    px(1) = px(0) '                   that match the size of the                 |                 |
    py(1) = HInImg / 2 '              original image. This                       |        .        |
    px(2) = WInImg / 2 '              creates four vector                        |       0,0       |
    py(2) = py(1) '                   quantities to work with.                   |                 |
    px(3) = px(2) '                                                  px(1),py(1) |                 | px(2),py(2)
    py(3) = py(0) '                                                         -x,saucer(c).loc.y ------------------- x,saucer(c).loc.y
    SINr = SIN(-Degree / 57.2957795131) '           sine and cosine calculation for rotation matrix below
    COSr = COS(-Degree / 57.2957795131) '           degree converted to radian, -Degree for clockwise rotation
    DO '                                            cycle through vectors
        x = px(v) * COSr + SINr * py(v) '           perform 2D rotation matrix on vector
        y = py(v) * COSr - px(v) * SINr '           https://en.wikipedia.org/wiki/Rotation_matrix
        px(v) = x '                                 save new x vector
        py(v) = y '                                 save new saucer(c).loc.y vector
        IF px(v) < Left THEN Left = px(v) '         keep track of new rotated image size
        IF px(v) > Right THEN Right = px(v)
        IF py(v) < Top THEN Top = py(v)
        IF py(v) > Bottom THEN Bottom = py(v)
        v = v + 1 '                                 increment vector counter
    LOOP UNTIL v = 4 '                              leave when all vectors processed
    RotWidth = Right - Left + 1 '                   calculate width of rotated image
    RotHeight = Bottom - Top + 1 '                  calculate height of rotated image
    Xoffset = RotWidth \ 2 '                        place (0,0) in upper left corner of rotated image
    Yoffset = RotHeight \ 2
    v = 0 '                                         reset corner counter
    DO '                                            cycle through rotated image coordinates
        px(v) = px(v) + Xoffset '                   move image coordinates so (0,0) in upper left corner
        py(v) = py(v) + Yoffset
        v = v + 1 '                                 increment corner counter
    LOOP UNTIL v = 4 '                              leave when all four corners of image moved
    OutImg = _NEWIMAGE(RotWidth, RotHeight, 32) '   create rotated image canvas
    '                                               map triangles onto new rotated image canvas
_MAPTRIANGLE (0, 0)-(0, HInImg - 1)-(WInImg - 1, HInImg - 1), InImg TO _
(px(0), py(0))-(px(1), py(1))-(px(2), py(2)), OutImg
_MAPTRIANGLE (0, 0)-(WInImg - 1, 0)-(WInImg - 1, HInImg - 1), InImg TO _
(px(0), py(0))-(px(3), py(3))-(px(2), py(2)), OutImg
END SUB
' -----------------------------------------
FUNCTION GETANGLE# (x1#, y1#, x2#, y2#) '                   Thanks to the QB64PE community for this
    '* Returns the angle in degrees from 0 to 359.9999.... between 2 given coordinate pairs.
    IF y2# = y1# THEN '                                       both Y values same?
        IF x1# = x2# THEN '                                   yes, both X values same?
            EXIT FUNCTION '                                   yes, points are same, no angle
        END IF
        IF x2# > x1# THEN '                                   second X value greater?
            GETANGLE# = 90 '                                  yes, then must be 90 degrees
        ELSE '                                                no, second X value is less
            GETANGLE# = 270 '                                 then must be 270 degrees
        END IF
        EXIT FUNCTION '                                       leave function
    END IF
    IF x2# = x1# THEN '                                       both X values same?
        IF y2# > y1# THEN '                                   second Y value greater?
            GETANGLE# = 180 '                                 yes, then must be 180 degrees
        END IF
        EXIT FUNCTION '                                       leave function
    END IF
    IF y2# < y1# THEN '                                       second Y value less?
        IF x2# > x1# THEN '                                   yes, second X value greater?
            GETANGLE# = ATN((x2# - x1#) / (y2# - y1#)) * -57.2957795131 ' yes, compute angle
        ELSE '                                                no, second X value less
            GETANGLE# = ATN((x2# - x1#) / (y2# - y1#)) * -57.2957795131 + 360 ' compute angle
        END IF
    ELSE '                                                    no, second Y value greater
        GETANGLE# = ATN((x2# - x1#) / (y2# - y1#)) * -57.2957795131 + 180 ' compute angle
    END IF
END FUNCTION
' -----------------------------------------
SUB getNextCommand (c AS INTEGER) '         used by saucer sub
    SHARED saucer() AS saucer

    saucer(c).loopCounter = 0
    saucer(c).loopNum = 0
    saucer(c).action = ""
    IF saucer(c).charCount >= LEN(saucer(c).commands) THEN '    if at end of command line then that saucer is done
        saucer(c).alive = FALSE '                               kind of a fail safe cuz render sub also kills saucer if ship is offscreen
        EXIT SUB
    END IF
    ' assign each separate command in command line
    saucer(c).charCount = saucer(c).charCount + 2 '                                     increment character counter  (skip space)
    saucer(c).action = LCASE$(MID$(saucer(c).commands, saucer(c).charCount, 1)) '       get the first char, the command letter: 'd,u,l,r' or 'c' for coast
    saucer(c).charCount = saucer(c).charCount + 1 '                                     move to next pair of chars - number of actions: loopNum
    saucer(c).loopNum = VAL(MID$(saucer(c).commands, saucer(c).charCount, 1)) * 10 '    turn the next char into tens column
    saucer(c).charCount = saucer(c).charCount + 1 '                                     skip the space in the string
    saucer(c).loopNum = saucer(c).loopNum + VAL(MID$(saucer(c).commands, saucer(c).charCount, 1)) '  turn this char into the ones value

    IF saucer(c).action = "c" AND (saucer(c).loopNum > 58 AND saucer(c).loopNum < 90) THEN
        FireBullet saucer(c).loc.x + 8, saucer(c).loc.y + 10 '                  drone fire at c60s and higher
    END IF
END SUB
' -----------------------------------------
SUB comeBack (action AS STRING, c AS SINGLE) ' move saucers toward viewer

    SHARED shipNum AS INTEGER, saucer() AS saucer '

    SELECT CASE action '                                                        run action scripting
        CASE "u": '                                                 UP
            saucer(c).aspect = saucer(c).aspect - .012 * saucer(c).aspectSign
            IF saucer(c).aspect > .9 THEN saucer(c).aspect = .9 '               nearly vertical
            IF saucer(c).aspect <= .0000002 THEN
                saucer(c).aspectSign = -saucer(c).aspectSign '                  switch up / down for continuity illusion
                saucer(c).aspect = .0000002 '                                   don't let the saucer(c).aspect get to zero - it goes haywire
                saucer(c).fillColor = C(10) ' was red
            END IF
            ' ---------------------
        CASE "d": '                                                 DOWN
            saucer(c).aspect = saucer(c).aspect + .012 * saucer(c).aspectSign
            IF saucer(c).aspect > .9 THEN saucer(c).aspect = .9 ' same as above
            IF saucer(c).aspect <= .0000002 THEN
                saucer(c).aspectSign = -saucer(c).aspectSign
                saucer(c).aspect = .0000002
                saucer(c).fillColor = C(4)
            END IF
            ' ---------------------
        CASE "r": '                                                 RIGHT
            saucer(c).rotAngle = saucer(c).rotAngle + 1.3
            IF saucer(c).rotAngle > 80 THEN saucer(c).rotAngle = 80
            ' ---------------------
        CASE "l": '                                                 LEFT
            saucer(c).rotAngle = saucer(c).rotAngle - 1.3
            IF saucer(c).rotAngle < -80 THEN saucer(c).rotAngle = -80
    END SELECT
    ' ----------------------------
    IF saucer(c).aspect <= 0 THEN saucer(c).aspect = .0000001
    ' ----------------------------
    SELECT CASE ABS(saucer(c).rotAngle) '                           >>> SIZE, SPEED CONTROLS VIA ROTANGLE <<<
        CASE 0 TO 5: saucer(c).speed = .3 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .035 ' was .07
        CASE 5.00001 TO 10: saucer(c).speed = .6 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .035
        CASE 10.00001 TO 15: saucer(c).speed = .9 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .033
        CASE 15.00001 TO 20: saucer(c).speed = 1.2 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .033
        CASE 20.00001 TO 26: saucer(c).speed = 1.6 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .028
        CASE 26.00001 TO 32: saucer(c).speed = 2.0 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .028
        CASE 32.00001 TO 38: saucer(c).speed = 2.4 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .025
        CASE 38.00001 TO 44: saucer(c).speed = 2.8 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .025
        CASE 44.00001 TO 50: saucer(c).speed = 3.0 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .02
        CASE 50.00001 TO 56: saucer(c).speed = 3.2 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .02
        CASE 56.00001 TO 62: saucer(c).speed = 3.4 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .017
        CASE 62.00001 TO 68: saucer(c).speed = 3.6 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .017
        CASE 68.00001 TO 74: saucer(c).speed = 4.0 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .015
        CASE 74.00001 TO 80: saucer(c).speed = 4.4 * saucer(c).rotAngSign
            saucer(c).shipRadius = saucer(c).shipRadius + .014
    END SELECT
    saucer(c).loc.x = saucer(c).loc.x + saucer(c).speed '                                   ** speed control **
    '                                                                                       EXCEPTIONS:
    IF saucer(c).shipRadius < 1.15 THEN saucer(c).shipRadius = saucer(c).shipRadius - .02 ' .02  NEW slow saucer growth initially
END SUB
' -----------------------------------------
SUB yControl (c AS INTEGER) '
    SHARED saucer() AS saucer
    '                                                                                       ** UP / DOWN CONTROLS **
    IF saucer(c).aspect > .029 THEN '                                                       if the saucer(c).aspect angle is more than flat
        SELECT CASE saucer(c).aspect '                                                      saucer ascends & descends faster at steeper angles
            CASE .03 TO .05: saucer(c).loc.y = saucer(c).loc.y + .3 * saucer(c).aspectSign '        once tilted, saucer keeps going
            CASE .0500001 TO .09: saucer(c).loc.y = saucer(c).loc.y + .6 * saucer(c).aspectSign
            CASE .0900001 TO .15: saucer(c).loc.y = saucer(c).loc.y + .9 * saucer(c).aspectSign
            CASE .1500001 TO .2: saucer(c).loc.y = saucer(c).loc.y + 1.5 * saucer(c).aspectSign
            CASE .2000001 TO .3: saucer(c).loc.y = saucer(c).loc.y + 2.3 * saucer(c).aspectSign
            CASE .3000001 TO .4: saucer(c).loc.y = saucer(c).loc.y + 3.0 * saucer(c).aspectSign
            CASE .4000001 TO .5: saucer(c).loc.y = saucer(c).loc.y + 3.8 * saucer(c).aspectSign
            CASE .5000001 TO .6: saucer(c).loc.y = saucer(c).loc.y + 4.2 * saucer(c).aspectSign
            CASE .6000001 TO .7: saucer(c).loc.y = saucer(c).loc.y + 4.6 * saucer(c).aspectSign
            CASE .7000001 TO .8: saucer(c).loc.y = saucer(c).loc.y + 5.2 * saucer(c).aspectSign
            CASE .8000001 TO .9: saucer(c).loc.y = saucer(c).loc.y + 5.8 * saucer(c).aspectSign
        END SELECT
    END IF
END SUB
' -----------------------------------------
SUB renderSaucer (c AS INTEGER)

    DIM AS LONG virtual(9), outImg(9)
    DIM AS SINGLE x, y
    SHARED saucer() AS saucer
    SHARED AS LONG HDWimg() '

    virtual(c) = _NEWIMAGE(saucer(c).shipRadius * 2 + 30, saucer(c).shipRadius * 2 + 30, 32) '      size the virtual screens dynamically
    outImg(c) = _NEWIMAGE(saucer(c).shipRadius * 2 + 30, saucer(c).shipRadius * 2 + 30, 32) '       doesn't seem to kill performance
    HDWimg(c) = _NEWIMAGE(saucer(c).shipRadius * 2 + 30, saucer(c).shipRadius * 2 + 30, 32) '       hardware image handle

    IF saucer(c).loc.y < -58 OR saucer(c).loc.y > 900 - 8 OR_
    saucer(c).loc.x >= 1600 + saucer(c).shipRadius + 20 OR saucer(c).loc.x <= -58 THEN '            off-screen saucer = dead
        saucer(c).alive = FALSE '                                                                   turn off this saucer
    END IF
    ' --------------------------
    IF saucer(c).rotAngle > 0 THEN saucer(c).rotAngSign = 1 '                   compensates for left or right turns
    IF saucer(c).rotAngle < 0 THEN saucer(c).rotAngSign = -1 '                  once turned, saucer keeps going
    ' --------------------------
    yControl c
    comeBack saucer(c).action, c '                                              subs for saucer x and y movement, speed & size, aspect controls
    ' --------------------------                                                ** RENDERING **
    _DEST virtual(c) '                                                          draw to virtual screen first, then rotate as needed
    x = _WIDTH / 2: y = _HEIGHT / 2
    CIRCLE (x, y), saucer(c).shipRadius, C(14), 0, 6.283, saucer(c).aspect '    draw saucer centered

    IF saucer(c).aspect > .003 THEN ' was 4
        $IF MAC THEN
            Paint (x, y), saucer(c).fillColor, C(14) '                      only paint the inside when the ship's profile is an oval - not a line!
        $END IF
        IF saucer(c).fillColor = C(4) THEN '                                                c(4) is top - ship going down
            CIRCLE (x, y), saucer(c).shipRadius * .8, C(0), 0, 6.283, saucer(c).aspect '    add some top o' saucer details
            CIRCLE (x, y), saucer(c).shipRadius * .2, C(12), 0, 6.283, saucer(c).aspect
            $IF MAC THEN
                Paint (x, y), C(14), C(12)
            $END IF
            IF saucer(c).shipRadius > 14 THEN
                CIRCLE (x, y), saucer(c).shipRadius * .8, C(12), 0, , saucer(c).aspect '
                PAINT (x, y), C(0), C(12)
            END IF
        ELSE '                                                                              bottom o' saucer details - red fillcolor
            CIRCLE (x, y), saucer(c).shipRadius * .8, C(14), 0, 6.283, saucer(c).aspect
            CIRCLE (x, y), saucer(c).shipRadius * .74, C(14), 0, 6.283, saucer(c).aspect
            CIRCLE (x, y), saucer(c).shipRadius * .3, C(4), 0, 6.283, saucer(c).aspect
            PAINT (x, y), C(0), C(4)
        END IF
    END IF
    IF saucer(c).aspect <= .066 THEN '                                      draw arcs for top and bottom of saucer at flat saucer(c).aspect
        CIRCLE (x, y), saucer(c).shipRadius, C(14), 3.14, 6.28, .11
        CIRCLE (x, y), saucer(c).shipRadius, C(14), 6.28, 3.14, .09
        $IF MAC THEN
            Paint (x, y), C(14), C(14) '
        $END IF
    END IF
    ' --------------------------
    RotateImage saucer(c).rotAngle, virtual(c), outImg(c) '
    HDWimg(c) = _COPYIMAGE(outImg(c), 32) '                 convert to hardware image - no, stick with SOFTWARE - hides saucer image boxes in Windows!
    _FREEIMAGE outImg(c) '
    _FREEIMAGE virtual(c)
    _FONT 16: _DEST 0
END SUB
' -----------------------------------------
SUB checkSaucerProx (c AS INTEGER) '                        c represents the current saucer assignment number
    '                                                       a is the lower selection number for comparison
    SHARED shipNum AS INTEGER, saucer() AS saucer '         this sub checks same-saucer (both/many assigned the same moves(#)) proximity
    DIM AS INTEGER a, count

    a = 0: count = 0
    DO
        count = count + 1
        a = c - count
        IF a = 0 THEN EXIT SUB
        IF saucer(c).movesNum = saucer(a).movesNum THEN
            IF ABS(saucer(c).loc.x - saucer(a).loc.x) < 90 THEN '       if the current saucer is too close to an older saucer then
                IF SGN(saucer(c).loc.x - saucer(a).loc.x) < 1 THEN '    if the difference is negative or zero then
                    saucer(c).loc.x = saucer(c).loc.x - 100 '
                ELSE
                    saucer(c).loc.x = saucer(c).loc.x + 100
                END IF
            END IF
            IF ABS(saucer(c).loc.y - saucer(a).loc.y) < 80 THEN
                IF SGN(saucer(c).loc.y - saucer(a).loc.y) < 1 THEN
                    saucer(c).loc.y = saucer(c).loc.y - 90
                ELSE
                    saucer(c).loc.y = saucer(c).loc.y + 90
                END IF
            END IF
        END IF
    LOOP
END SUB
' -----------------------------------------
SUB ManageBullets () '                      ManageBullets & Star Shaking & Related Sounds & ScoreKeeping Chores
    '                                       Thanks, Terry Ritchie
    SHARED Bullet() AS bullet
    SHARED AS LONG saucerScape
    DIM Index AS INTEGER
    STATIC AS _BYTE wiggle, s, a, adder, initd

    IF Control.clearStatics THEN initd = FALSE: EXIT SUB
    IF NOT initd THEN
        adder = 3
        a = 0
        s = 0
        initd = TRUE
    END IF

    Index = -1 '                                    reset index counter value
    DO '                                            begin array search loop
        Index = Index + 1 '                         increment array index counter
        IF Bullet(Index).Active THEN '              is this bullet active?
            IF Bullet(Index).Radius < 360 THEN '    only course adjust smaller circles to prevent wobble
                IF Bullet(Index).x < 800 - 5 THEN ' leave a range of OK centering to avoid over-adjusting center
                    Bullet(Index).x = Bullet(Index).x + Bullet(Index).Speed
                ELSE IF Bullet(Index).x > 800 + 5 THEN Bullet(Index).x = Bullet(Index).x - Bullet(Index).Speed
                END IF

                IF Bullet(Index).y < 450 - 5 THEN
                    Bullet(Index).y = Bullet(Index).y + Bullet(Index).Speed
                ELSE IF Bullet(Index).y > 450 + 5 THEN Bullet(Index).y = Bullet(Index).y - Bullet(Index).Speed
                END IF
            END IF

            IF Bullet(Index).Radius < 60 THEN '                 circle growth
                Bullet(Index).Radius = Bullet(Index).Radius + 3
            ELSE
                IF Bullet(Index).Radius > 59 AND Bullet(Index).Radius < 200 THEN
                    Bullet(Index).Radius = Bullet(Index).Radius + 12
                ELSE
                    IF Bullet(Index).Radius > 199 THEN
                        Bullet(Index).Radius = Bullet(Index).Radius + 40
                    END IF
                END IF
            END IF

            Bullet(Index).Speed = Bullet(Index).Speed * 1.05 '  increase speed slightly
            IF Bullet(Index).Radius > 400 AND Bullet(Index).Radius < 406 THEN
                _SNDPLAYCOPY S(37), .35 '                       impact sound
                Game.score = Game.score - (10 * Game.diff_mult) '                 ** SCORE **
                IF Ship.shields > 8 THEN Ship.shields = Ship.shields - 1.8 '    ** SHIELDS - cannot blow up during saucer attacks **
                IF Ship.power > 12 THEN Ship.power = Ship.power - .6
                wiggle = TRUE
            END IF

            IF wiggle THEN '                                    shake starScape
                s = s + 1
                a = a + adder ' 3
                _PUTIMAGE (a, 0), saucerScape '                 move stars horizontally 9 pixels each way
                IF a = 9 OR a = -9 THEN adder = -adder '
                IF s = 22 THEN
                    a = 0
                    s = 0
                    adder = 3
                    wiggle = FALSE
                END IF
            END IF
            'Check to see if the circle has left the game screen
            IF Bullet(Index).Radius > 700 THEN ' '              has bullet gotten big enough?
                Bullet(Index).Active = 0 '                      yes, deactivate bullet
            ELSE '                                              no, bullet still on game screen
                CIRCLE (Bullet(Index).x, Bullet(Index).y), Bullet(Index).Radius, C(12) '      draw the bullet
                CircleFill Bullet(Index).x, Bullet(Index).y, Bullet(Index).Radius, _RGB32(227, 50, 55, 43) '   paint the bullet circle
            END IF
        END IF
    LOOP UNTIL Index = UBOUND(Bullet) '                         leave when all indexes checked
END SUB
' -----------------------------------------
SUB FireBullet (x AS INTEGER, y AS INTEGER) '                   Props to Terry Ritchie for this

    SHARED Bullet() AS bullet ' need access to player bullet array
    DIM Index AS INTEGER ' array index counter

    Index = -1 '                                    reset index counter
    DO '                                            begin array search loop
        Index = Index + 1 '                         increment array index counter
    LOOP UNTIL Index = UBOUND(Bullet) OR Bullet(Index).Active = 0 '     leave when inactive found or at end of array

    IF Bullet(Index).Active THEN '                  was an inactive array index found?
        Index = Index + 1 '                         no, increase the array index size
        REDIM _PRESERVE Bullet(Index) AS bullet '   resize the array while preserving exisiting data
    END IF

    Bullet(Index).x = x '                           new bullet's x coordinate
    Bullet(Index).y = y '                           new bullet's y coordinate
    Bullet(Index).Speed = 2 '                       new bullet's initial speed
    Bullet(Index).Radius = 3
    Bullet(Index).Active = 1 '                      this array index is active
    _SNDPLAYCOPY S(36), .15 '                       awesome saucer bullet sound
END SUB
' -----------------------------------------
SUB driveTruck () '                         now with flashing lights @ landing pad - oh boy
    STATIC AS SINGLE c, d
    STATIC AS INTEGER i
    STATIC AS _BYTE sign
    DIM AS INTEGER x, y

    IF Control.clearStatics THEN c = 0: d = 0: i = 0: EXIT SUB
    x = 406: y = 563
    c = c + .28
    d = d + .006
    _PUTIMAGE (726 - c, 660 + d), I(3), 0
    ' -------------------------                     * SIRENS / BEACONS *
    IF NOT Ship.landed THEN '
        CIRCLE (x, y), 4, C(1), _D2R(360), _D2R(180), 1
        CIRCLE (x + 161, y), 4, C(1), _D2R(360), _D2R(180), 1 '   location #2's
        LINE (x - 4, y)-(x - 4, y + 4), C(1)
        LINE (x - 4 + 161, y)-(x - 4 + 161, y + 4), C(1)
        LINE (x + 4, y)-(x + 4, y + 4), C(1)
        LINE (x + 4 + 161, y)-(x + 4 + 161, y + 4), C(1)
        LINE (x - 4, y + 4)-(x + 4, y + 4), C(1)
        LINE (x - 4 + 161, y + 4)-(x + 4 + 161, y + 4), C(1)
        i = i + 1: IF i > 5000 THEN i = 0
        IF i = 1 THEN sign = 1 '                        initialize sign
        IF i MOD 15 = 0 THEN sign = -sign '
        IF sign = 1 THEN
            PAINT (x, y), C(12), C(1) '
            PAINT (x + 161, y), C(14), C(1)
        ELSE
            PAINT (x, y), C(14), C(1)
            PAINT (x + 161, y), C(12), C(1)
        END IF
    END IF
    ' -------------------------
    IF c > 1150 THEN '          lots of cycles for the truck and beacons before shutting off sub
        c = 0: d = 0: i = 0
        Sb.doTruck = FALSE
    END IF
END SUB
' -----------------------------------------
SUB instructions () '

    DIM AS INTEGER c, d, i '
    DIM a$, b$, c$, d$, e$, f$ '
    DIM AS _BYTE oldMB, mb, count
    SHARED AS LONG starScape

    a$ = "Press a key or mouse click to continue..."
    b$ = "WELCOME TO ROCK JOCKEY."
    c$ = "YOU'LL BE MANNING THE CONTROLS OF A POWERFUL SMART-DRONE."
    d$ = "SCAN & HARVEST THE VALUABLE PURPLE ASTEROIDS, THEN TAKE EM BACK TO BASE."
    e$ = "PRESS 'ESC' FOR SETTINGS / INTRO SCREEN / EXIT"
    f$ = "'SPACEBAR' TO CAPTURE ROCKS IN SPACE OR OFF-LOAD ROCKS WHEN LANDED."

    _SNDLOOP S(32): _SNDVOL S(32), .001 '   run sound
    DO
        c = c + 1
        _SNDVOL S(32), c * .001 '           turn it up
        _LIMIT 40
    LOOP UNTIL c = 36
    CLS
    _DISPLAY
    _FONT Menlo: COLOR C(14)
    FOR i = 255 TO 0 STEP -4 '              fade in scene
        CLS
        _PUTIMAGE , starScape
        COLOR C(14)
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(b$) \ 2, 430), b$
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(c$) \ 2, 465), c$
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(d$) \ 2, 500), d$
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '      increase black box transparency
        _DISPLAY
        _LIMIT 80 '
    NEXT
    _DELAY 3.7
    FOR d = 4 TO 9 '                                                churn through demo images
        CLS
        _PUTIMAGE , starScape
        _PUTIMAGE (_WIDTH \ 2 - _WIDTH(I(d)) \ 2, 50), I(d)
        COLOR C(14)
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(b$) \ 2, 430), b$
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(c$) \ 2, 465), c$
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(d$) \ 2, 500), d$
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(e$) \ 2, 555), e$
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(f$) \ 2, 580), f$
        COLOR C(4)
        _DISPLAY

        oldMB = -1 '                        count as if the mouse is down to begin with
        DO
            _LIMIT 30 '                     Thanks to Steve McNeill for this wee mouse click code <<<<<<<<
            WHILE _MOUSEINPUT: WEND
            mb = _MOUSEBUTTON(1)
            IF (mb AND NOT oldMB) OR INKEY$ <> "" THEN
                EXIT DO
            END IF
            oldMB = mb
            count = count + 1
            IF count = 1 THEN _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(a$) \ 2, 685), a$
            If count = 50 Then Line (_Width \ 2 - _PrintWidth(a$) \ 2, 680)-_
            (_Width \ 2 + _PrintWidth(a$) \ 2, 700), C(0), BF: count = -50 '    erasure box
            _PUTIMAGE (300, 680), starScape, 0, (300, 680)-(800, 720) '         new, re-star the blank text box w/ part of starScape <<<<
            _DISPLAY
        LOOP
    NEXT

    CLS
    d = 0
    DO
        d = d + 1 '                                 d turns down music and changes alpha value
        COLOR _RGB32(255, 255, 140, d * .2) '       was 2 (1.2)
        _PRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH("GOOD LUCK!") \ 2, 300), "GOOD LUCK!"
        _SNDVOL S(32), .05 - (d * .0009) '          turn down music loop
        _DISPLAY
        _LIMIT 40
    LOOP UNTIL d >= 55

    _KEYCLEAR
    Sb.doInstructs = FALSE: SubFlags(18) = FALSE
    _SNDSTOP S(32): _SNDVOL S(32), .038 '
    splashPage
END SUB
' -----------------------------------------

SUB splashPage () '

    DIM AS LONG splashImg, outImg, spaceP
    DIM AS INTEGER c, i, x, y, adder, spin
    DIM AS SINGLE adder3, e, vol, d, xScroller, f
    DIM a$, b$
    DIM AS _BYTE done
    SHARED AS LONG starScape, starScape2, shipImg
    SHARED AS STRING rockType()

    drawStars '
    RotateImage 270, shipImg, outImg
    soundOff '                                      kill any playing loops
    _SNDLOOP S(38): _SNDVOL S(38), 0: vol = .3 '    start fresh loop
    Control.hold = TRUE
    Resetter(22) = FALSE
    splashImg = _NEWIMAGE(1280, 720, 32)
    spaceP = _LOADFONT("Fonts/spacePatrol.otf", 44)
    a$ = "Rock Jockey"
    b$ = "A c t i o n  &  A d v e n t u r e"
    _DEST splashImg
    _PUTIMAGE (400, 200), I(10) '   rocket
    _PUTIMAGE (960, 420), I(13) '   asteroid
    _PUTIMAGE (530, 380), I(14) '   asteroid
    _PUTIMAGE (120, 520), I(15) '   asteroid
    _PUTIMAGE (260, 400), I(16) '   asteroid
    _PUTIMAGE (1030, 270), I(18) '  saucer
    COLOR C(14): _FONT spaceP
    _PRINTMODE _KEEPBACKGROUND
    _UPRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(a$) \ 2, 48), a$
    COLOR C(12): _FONT Menlo
    _UPRINTSTRING (_WIDTH \ 2 - _PRINTWIDTH(b$) \ 2, 114), b$
    LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), C(3), B '            border
    LINE (24, 24)-(_WIDTH - 25, _HEIGHT - 25), C(3), B
    PAINT (10, 10), C(5), C(3)
    _FONT 16 '      <<<< THIS TOOK FOREVER - GOTTA DO A SYS _FONT INSIDE DIFFERENT _DESTS TO ALLOW FREEING FONTS! <<<< <<<<
    _DEST 0
    i = 255: c = 240
    adder = -2 '                    increments label fades
    adder3 = .6 '                   alien movement
    CLS
    _DISPLAY
    DO
        CLS '                    SndFade = snd, changeAmnt, goal, presVol, Resetter(#) to kill
        IF NOT Resetter(22) THEN SndFade1 S(38), .002, .3, 0, 22
        e = e + adder3 '                                            moves alien ship
        IF e > 50 OR e < -180 THEN adder3 = -adder3
        xScroller = xScroller - .25 '                               scroll stars to the left
        _PUTIMAGE (xScroller, 0), starScape
        _PUTIMAGE (1281 + xScroller, 0), starScape2
        IF xScroller < -1280 THEN xScroller = 0
        IF d < 1450 THEN
            d = d + 1.5
            _FONT ModernBig: COLOR C(14)
            _UPRINTSTRING (-200 + d, 670), "TURN UP YOUR SPEAKERS"
            _PUTIMAGE (1300 - d, 150), outImg '                                 meandering ship
            IF d > 570 THEN f = f + .65: RotateImage -90 + f, shipImg, outImg ' spin ship a bit
        END IF

        WHILE _MOUSEINPUT: WEND '
        x = _MOUSEX: y = _MOUSEY
        '                                         ** MOUSE CLICKS **
        IF _MOUSEBUTTON(1) THEN '                   box: PLAY GAME
            IF x > 80 AND x < 170 THEN
                IF y > 300 AND y < 320 THEN
                    IF NOT Sb.doFF AND NOT Sb.doSaucers THEN turnOnChecks ' this affects rocks sub
                    soundOn '                                       resume sound loops
                    Ship.course = 0: Ship.speed = 0 '               reset game
                    Ship.x = CENTX: Ship.y = CENTY
                    IF NOT Flag.settingsDone THEN Sb.doSettings = TRUE: SubFlags(19) = TRUE ' new - run settings before play begins
                    EXIT DO
                END IF
            END IF

            IF x > 80 AND x < 240 THEN '            box: INSTRUCTIONS
                IF y > 340 AND y < 360 THEN
                    Sb.doInstructs = TRUE: SubFlags(18) = TRUE
                    EXIT DO '
                END IF
            END IF

            IF x > 80 AND x < 160 THEN '            box: PRACTICE
                IF y > 380 AND y < 400 THEN
                    IF Time.gameStart < 6 THEN '    only before game start can you practice
                        Flag.doPractice = TRUE '    and time.gameStart initd to 5 @ starts/resets
                        killChecks
                        EXIT DO
                    END IF
                END IF
            END IF

            IF x > 80 AND x < 124 THEN '            box: EXIT
                IF y > 420 AND y < 440 THEN '
                    _FONT 16: _FREEFONT spaceP
                    _FREEIMAGE splashImg: _FREEIMAGE outImg
                    wrapUp: SYSTEM
                END IF
            END IF
        END IF

        COLOR _RGB32(0, 255, 0, c): _FONT Menlo
        _UPRINTSTRING (80, 300), "PLAY GAME" ' WAS 350
        _UPRINTSTRING (80, 340), "INSTRUCTIONS"
        _UPRINTSTRING (80, 380), "PRACTICE"
        _UPRINTSTRING (80, 420), "EXIT"
        c = c + adder '                             alpha changer value
        IF c < 30 OR c > 255 THEN adder = -adder

        PRESET (1130, 120), C(14) '                 spinning rock 1, right
        DRAW "TA=" + VARPTR$(spin) + rockType(10)
        PAINT (1128, 122), _RGB32(28), C(14)
        PSET (1130, 120), C(0)
        spin = spin + 1
        PRESET (140, 120), C(14) '                  rock 2, left
        spin = -spin
        DRAW "TA=" + VARPTR$(spin) + rockType(6) '
        PAINT (141, 122), _RGB32(32), C(14)
        PSET (140, 120), C(0) '                     kill dot in center
        spin = -spin
        _PUTIMAGE (809, 460 + e * 1.5), I(2) '      move alien ship
        _PUTIMAGE , splashImg '                     backdrop last
        IF NOT done THEN
            i = i - 4
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            IF i < 10 THEN done = TRUE: _MOUSESHOW '
        END IF
        _DISPLAY
        _LIMIT 45
    LOOP

    _KEYCLEAR '                                                     prevents popUp at start
    FOR i = 0 TO 255 STEP 5
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '      quick fade out
        vol = vol - .005
        _SNDVOL S(38), vol
        _DISPLAY
        _LIMIT 100 '
    NEXT

    _FONT 16: _FREEFONT spaceP
    _FREEIMAGE splashImg: _FREEIMAGE outImg
    _MOUSEHIDE: _SNDSTOP S(38)
    Sb.doPopUp = FALSE: Control.hold = FALSE
    FPS = 10: Flag.speedUp = TRUE '
END SUB
' -----------------------------------------

SUB settings () '
    '
    DIM AS INTEGER i, j, x, y
    DIM AS SINGLE vol
    DIM AS _BYTE changeMade '
    SHARED AS INTEGER diffX, msX, rezX, maxComets

    Control.hold = TRUE '                               stop the game loop
    CLS , _RGB32(30, 102, 140)
    _MOUSESHOW
    soundOff: killNoises
    _SNDPLAY S(39): vol = .25
    COLOR C(14)
    _FONT MenloBig
    _UPRINTSTRING (50, 28), "SETTINGS"
    COLOR C(14) '
    LINE (20, 60)-(_WIDTH - 20, 60), C(6)
    _FONT 8: COLOR C(9)
    _UPRINTSTRING (55, 234), "SLOWER" '
    _UPRINTSTRING (179, 234), "FASTER"
    _FONT Menlo: COLOR C(14)
    _UPRINTSTRING (50, 208), "SET MOUSE SENSITIVITY"

    FOR j = 0 TO 4
        IF j <> 5 THEN _UPRINTSTRING (46 + j * 40, 290), STR$(j)
        CIRCLE (60 + j * 40, 270), 7, C(16) '                           0 to 4 buttons
        PAINT (60 + j * 40, 270), C(0), C(16)
    NEXT j
    PAINT (msX, 270), C(12), C(16) '                                    paint the existing selection #2
    LINE (20, 325)-(_WIDTH - 20, 325), C(6) '                           separator line
    _FONT 8: COLOR C(9)
    _UPRINTSTRING (80, 337), "(FOR PCs ONLY)"
    _FONT Menlo: COLOR C(14) '
    _UPRINTSTRING (50, 350), "DO YOU WANT FULLSCREEN OR NATIVE?" '
    CIRCLE (202, 385), 7, C(16): PAINT (202, 385), C(0), C(16) '        buttons
    CIRCLE (310, 385), 7, C(16): PAINT (310, 385), C(0), C(16)
    PAINT (rezX, 385), C(12), C(16) '                                   paint existing choice #3

    IF _FULLSCREEN <> 0 THEN
        _UPRINTSTRING (450, 350), "DOES THE SCREEN LOOK FUNNY? Try toggling the setting..." '   toggle SqrPix
        _FONT 8: COLOR C(9)
        _UPRINTSTRING (450, 382), "_SQUARE PIXELS _SMOOTH:"
        _UPRINTSTRING (675, 382), "<<< CLICK THE BUTTON"
        CIRCLE (652, 385), 7, C(16)
        IF _FULLSCREEN = 2 THEN
            PAINT (652, 385), C(4), C(16)
        ELSE PAINT (652, 385), C(12), C(16)
        END IF
    END IF
    _DISPLAY '

    _FONT Menlo: COLOR C(14) '
    LINE (20, 430)-(_WIDTH - 20, 430), C(6)
    LINE (1164, 430)-(_WIDTH - 21, 430), C(6)
    _UPRINTSTRING (50, 448), "SET GAME DIFFICULTY"
    COLOR C(9)
    _UPRINTSTRING (116, 480), "EASY": _UPRINTSTRING (250, 480), "MEDIUM"
    _UPRINTSTRING (395, 480), "HARD"
    CIRCLE (133, 514), 7, C(16): PAINT (133, 514), C(0), C(16)
    CIRCLE (277, 514), 7, C(16): PAINT (277, 514), C(0), C(16)
    CIRCLE (413, 514), 7, C(16): PAINT (413, 514), C(0), C(16)
    PAINT (diffX, 514), C(12), C(16) '                                  paint existing choice #4
    LINE (20, 554)-(_WIDTH - 20, 554), C(6) '
    COLOR C(14)
    LINE (84, 590)-(172, 620), C(4), B
    PAINT (100, 600), _RGB32(240, 0, 0, 140), C(4)
    _UPRINTSTRING (112, 598), "DONE"
    _PUTIMAGE (21, 70), I(19) '                                         row of analoggy images, ENIAC
    _PUTIMAGE (248, 70), I(20)
    _PUTIMAGE (445, 70), I(21) '                                        old school computery stuff
    _PUTIMAGE (642, 70), I(20)
    _PUTIMAGE (840, 70), I(22)
    _PUTIMAGE (1034, 70), I(19)
    _PUTIMAGE (644, 432), I(23)
    _PUTIMAGE (728, 432), I(23)
    _PUTIMAGE (821, 527), I(24)
    _PUTIMAGE (962, 436), I(25)
    LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), C(3), B '                    border
    LINE (17, 17)-(_WIDTH - 18, _HEIGHT - 18), C(3), B
    PAINT (10, 10), _RGB32(0, 74, 0), C(3)

    DO '                                                                ** BUTTON SELECTION **
        WHILE _MOUSEINPUT: WEND
        x = _MOUSEX
        y = _MOUSEY
        IF _MOUSEBUTTON(1) THEN '
            IF y >= 263 AND y <= 277 THEN '                             ** MOUSE SENSITIVITY **  0 to 4 buttons
                FOR j = 0 TO 4
                    IF x >= (60 + j * 40) - 8 AND x <= (60 + j * 40) + 8 THEN ' selection made?
                        FOR i = 0 TO 4
                            PAINT (60 + i * 40, 271), C(0), C(16) '     black out all the cells
                        NEXT i
                        _SNDPLAY S(2)
                        PAINT (60 + j * 40, 271), C(12), C(16) '        paint the selected cell
                        SELECT CASE j '                                 set mouse multiplier
                            CASE 0: MouseSens = .15
                            CASE 1: MouseSens = .18
                            CASE 2: MouseSens = .225
                            CASE 3: MouseSens = .26
                            CASE 4: MouseSens = .31
                        END SELECT
                        msX = 60 + j * 40
                        changeMade = TRUE
                    END IF
                NEXT j
            END IF

            IF y >= 380 AND y <= 395 THEN
                IF x >= 194 AND x <= 209 THEN
                    _SNDPLAY S(2)
                    PAINT (202, 385), C(12), C(16)
                    PAINT (310, 385), C(0), C(16)
                    rezX = 202
                    Flag.fullScreen = TRUE '                    _FULLSCREEN _ON
                    Flag.fullScreenOff = FALSE
                    changeMade = TRUE
                ELSEIF x >= 303 AND x <= 317 THEN '             _FULLSCREEN _OFF  (NATIVE)
                    _SNDPLAY S(2)
                    PAINT (202, 385), C(0), C(16)
                    PAINT (310, 385), C(12), C(16)
                    rezX = 310
                    Flag.fullScreenOff = TRUE
                    Flag.fullScreen = FALSE
                    changeMade = TRUE
                ELSEIF x >= 645 AND x <= 660 THEN '             _SQR_PIX ON/OFF
                    IF _FULLSCREEN <> 0 THEN
                        _SNDPLAY S(2)
                        Flag.toggle_SqrPix = TRUE
                        IF _FULLSCREEN = 2 THEN '               change the color
                            PAINT (652, 385), C(12), C(16)
                        ELSE PAINT (652, 385), C(4), C(16)
                        END IF
                        changeMade = TRUE
                    END IF
                END IF
            END IF

            IF y >= 507 AND y <= 521 THEN '
                IF x >= 126 AND x <= 140 THEN '                 ** EASY **
                    _SNDPLAY S(2)
                    PAINT (133, 514), C(12), C(16)
                    PAINT (277, 514), C(0), C(16) '             8 ships total
                    PAINT (413, 514), C(0), C(16)
                    diffX = 133
                    Game.diff_mult = .9 '                      subtract 10% on score for EASY
                    Game.speed = 52 '                           was 54
                    Game.landingSpeed = 45 '
                    MaxRocks = 10
                    IF NOT Flag.landingTime THEN assignRocks
                    maxComets = 75
                    IF NOT Sb.doComets THEN initCOMETS
                    Ship.inventory = 10 - Ship.blownUp
                    changeMade = TRUE
                ELSE '
                    IF x >= 270 AND x <= 285 THEN '             ** MEDIUM **
                        _SNDPLAY S(2)
                        PAINT (277, 514), C(12), C(16)
                        PAINT (133, 514), C(0), C(16)
                        PAINT (413, 514), C(0), C(16) '         6 ships total, set in startUp SUB
                        diffX = 277
                        Game.diff_mult = 1
                        Game.speed = 60
                        Game.landingSpeed = 60
                        MaxRocks = 12
                        IF NOT Flag.landingTime THEN assignRocks
                        maxComets = 90
                        IF NOT Sb.doComets THEN initCOMETS
                        Ship.inventory = 7 - Ship.blownUp '
                        changeMade = TRUE
                    ELSE
                        IF x >= 406 AND x <= 420 THEN '         ** HARD **
                            _SNDPLAY S(2)
                            PAINT (413, 514), C(12), C(16)
                            PAINT (133, 514), C(0), C(16) '     4 ships total
                            PAINT (277, 514), C(0), C(16)
                            diffX = 413
                            Game.diff_mult = 1.1 '             add 10% on score for HARD
                            Game.speed = 70
                            Game.landingSpeed = 72
                            MaxRocks = 14
                            IF NOT Flag.landingTime THEN assignRocks
                            maxComets = 115
                            IF NOT Sb.doComets THEN initCOMETS
                            Ship.inventory = 5 - Ship.blownUp '
                            changeMade = TRUE
                        END IF
                    END IF
                END IF
            END IF
            IF y >= 588 AND y <= 622 THEN '
                IF x >= 82 AND x <= 174 THEN '                      DONE button
                    PAINT (100, 600), _RGB32(0, 255, 0, 80), C(4)
                    EXIT DO
                END IF
            END IF
            _DELAY .17 '                                        prevents multiple click sounds
        END IF ' - - - - - - - - - - - - - - - - - -            end of click loop checks
        _DISPLAY '
        _LIMIT 20
    LOOP

    IF changeMade THEN
        _SNDPLAY S(3)
        COLOR C(14)
        _FONT Menlo
        _UPRINTSTRING (54, 650), "SETTINGS ADJUSTED"
        _DISPLAY
        _DELAY .7
    END IF
    FOR i = 0 TO 255 STEP 4
        vol = vol - .004 '
        _SNDVOL S(39), vol '
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  quick fade out
        _DISPLAY
        _LIMIT 100 '
    NEXT
    _KEYCLEAR: _MOUSEHIDE
    Control.hold = FALSE '                                      resume main game loop
    FPS = 10: Ship.course = 0 '                                 set FPS for speedUp, zero out shipCourse
    Flag.speedUp = TRUE
    Sb.doSettings = FALSE: SubFlags(19) = FALSE
    Flag.settingsDone = TRUE '                                  track that it's been run
    Sb.doPopUp = FALSE
    _SNDSTOP S(39): _SNDVOL S(39), .21 '                        stop & reset volume for next time
    soundOn: _FONT 16
    IF NOT Sb.doFF AND NOT Sb.doSaucers AND NOT Sb.doGauntlet THEN turnOnChecks
    IF Ship.speed > 2.7 THEN Ship.speed = 2.7 '                                     ease back into the game if zooming before popUp
    IF Time.gameStart = 5 THEN Time.gameStart = TIMER ' time.gameStart is set in resetFlags & startUp to 5 as a flag as not started yet
END SUB '                                                       & turned on here just before game start
' -----------------------------------------
SUB shipBoom ()

    SHARED AS LONG timer1, timer3
    SHARED AS _BYTE delayVO, sparkCycles
    SHARED spark() AS spark

    killNoises: killChecks
    IF NOT Flag.shipBoomDone THEN
        Ship.inventory = Ship.inventory - 1 '
        Ship.blownUp = Ship.blownUp + 1
        Flag.shipBoomDone = TRUE
    END IF
    Sb.doShip = FALSE: SubFlags(2) = FALSE
    sparkCycles = 0 '                           new new new - RESET BLOWUP SUB
    REDIM spark(0) AS spark '                   new new new - RESET SPARKS FOR PRIORITY SHIPBOOM! <<<<
    Flag.boomInProgress = TRUE ' <<<<<<<<< NEW
    Sb.doSparks = TRUE: SubFlags(8) = TRUE: boomInfo.num = 20: boomInfo.r = 0: boomInfo.g = 227: boomInfo.b = 0 '
    Flag.doCircle = FALSE '                               sometimes created an artifact w/o this
    _SNDPLAY S(INT(RND * 3 + 4)) '
    IF Ship.inventory >= -1 THEN
        TIMER(timer1) ON ' <<<<<<<<<                    flip on ship timer - pause before reappearing
        IF NOT _SNDPLAYING(S(23)) THEN '                don't step on heaven!
            IF NOT IsVOPlaying THEN
                _SNDPLAY VO(29) '                       ** packaged sounds ** gotta play simultaneously **
                SELECT CASE Ship.inventory '            "ship destroyed, n remaining"
                    CASE -1: _SNDPLAY VO(30) '      0 ships
                    CASE 0: _SNDPLAY VO(30) '       0
                    CASE 1: _SNDPLAY VO(31) '       1
                    CASE 2: _SNDPLAY VO(32) '       2
                    CASE 3: _SNDPLAY VO(35) '       etc
                    CASE 4: _SNDPLAY VO(38)
                    CASE 5: _SNDPLAY VO(39)
                    CASE 6: _SNDPLAY VO(40)
                    CASE 7: _SNDPLAY VO(41)
                    CASE 8: _SNDPLAY VO(42)
                    CASE 9: _SNDPLAY VO(47)
                END SELECT
                _SNDPLAY VO(28) '       "remaining"          \/ cumbersome but effective?
            ELSE IF NOT _SNDPLAYING(VO(29)) AND NOT _SNDPLAYING(VO(30)) AND NOT_
             _SNDPLAYING(VO(31)) AND NOT _SNDPLAYING(32) AND NOT _SNDPLAYING(VO(35))_
              THEN TIMER(timer3) ON: delayVO = 29 '   then turn on VO delay timer, assign VO to play
            END IF
        END IF
    END IF
END SUB
' -----------------------------------------
SUB wrapUp () '                             close up shop

    DIM c AS INTEGER
    SHARED AS LONG saucerScape, starScape3, shipImg
    SHARED AS LONG mainScreen, microMask, miniMask, starScape, starScape2, HDWimg()
    SHARED AS LONG t5, t1, t2, t3, t4, interval, timer1, timer2, timer3, timer4
    SHARED AS INTEGER boomDelay

    FOR c = 0 TO UBOUND(I) '        freeImages
        ON ERROR GOTO errHandler
        _FREEIMAGE I(c)
    NEXT c
    FOR c = 1 TO UBOUND(HDWimg) '   free hardware image array
        IF HDWimg(c) <> -1 AND HDWimg(c) <> 0 THEN _FREEIMAGE HDWimg(c) ' needed to add checking or it crashed...
    NEXT c
    FOR c = 0 TO UBOUND(S) '        close sounds
        _SNDCLOSE S(c)
    NEXT c
    FOR c = 1 TO UBOUND(VO) '       close voice-overs
        _SNDCLOSE VO(c)
    NEXT c
    _FREEIMAGE MoonScape '                          free other images
    _FREEIMAGE ViewScreen: _FREEIMAGE saucerScape
    _FREEIMAGE shipImg: _FREEIMAGE starScape
    _FREEIMAGE starScape2: _FREEIMAGE starScape3
    _FREEIMAGE miniMask: _FREEIMAGE microMask
    _FONT 16 '                                      free fonts
    _FREEFONT Menlo '                               fonts checked for errors @ loading
    _FREEFONT MenloBig
    _FREEFONT Modern
    _FREEFONT ModernBig
    _FREEFONT ModernBigger
    TIMER(timer1) FREE: TIMER(timer2) FREE '        free timers
    TIMER(timer3) FREE: TIMER(timer4) FREE
    TIMER(t1) FREE: TIMER(t2) FREE
    TIMER(t3) FREE: TIMER(t4) FREE
    TIMER(interval) FREE: TIMER(t5) FREE: TIMER(boomDelay) FREE
END SUB
' -----------------------------------------
SUB endGame () '

    STATIC AS INTEGER count
    SHARED AS SINGLE xScroller
    SHARED AS LONG starScape, timer3, starScape2
    DIM AS INTEGER k, c, e '
    DIM a$

    IF Control.clearStatics THEN count = 0: EXIT SUB
    killNoises
    DO: e = _MOUSEINPUT: LOOP UNTIL e = 0 '     clear mouse input
    CLS: TIMER(timer3) OFF
    _LIMIT 70
    IF Game.round = 1 THEN
        _PUTIMAGE , starScape, 0
    ELSE _PUTIMAGE , starScape2, 0
    END IF
    a$ = "THANKS FOR PLAYING!"
    killChecks
    Sb.doPopUp = FALSE
    count = count + 1
    _FONT MenloBig: COLOR C(14)
    _PRINTSTRING (_WIDTH / 2 - (_PRINTWIDTH(a$) / 2), _HEIGHT / 2 - 100), a$ '
    _FONT 16
    IF count > 82 THEN
        FOR k = 0 TO 255 STEP 4
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, k), BF '  fade out
            _DISPLAY
            _LIMIT 50 '
        NEXT
        highScore '                             check for hiScore and/or display it
        IF Control.restart THEN
            Control.clearStatics = TRUE '
            count = 0
            Control.endIt = FALSE
            soundOff: killNoises
            startUp: resetFlags
            splashPage
            EXIT SUB
        ELSE
            wrapUp '                            close all assets
            SYSTEM '                            <<<< FINITO >>>>
        END IF
    END IF '
    _FONT 16
END SUB
' -----------------------------------------

SUB highScore () '

    DIM AS _BYTE c, d, addYrName, toggle, seconds, minutes
    DIM AS INTEGER i, fileScore, fileKillRatio, fileTimeInBox, k
    DIM AS STRING filePlayer
    DIM a$, b$, c$, d$, e$, newName$, secs$
    DIM AS LONG virtual
    DIM AS SINGLE count, vol
    SHARED AS LONG starScape

    virtual = _NEWIMAGE(1280, 720, 32)
    _MOUSEHIDE
    FOR i = 0 TO UBOUND(S): _SNDSTOP S(i): NEXT i '    kill sounds

    IF _FILEEXISTS("scores.txt") THEN
        OPEN "scores.txt" FOR INPUT AS #1
        '   read high scores from file to hiScore array
        FOR c = 0 TO 4
            INPUT #1, filePlayer, fileScore, fileKillRatio, fileTimeInBox
            HiScore(c).player = filePlayer
            HiScore(c).score = fileScore
            HiScore(c).kRatio = fileKillRatio
            HiScore(c).timeInBox = fileTimeInBox
        NEXT c
    END IF

    a$ = "CONGRATS! YOU MADE IT ONTO THE HIGH SCORE BOARD!"
    b$ = "Enter your name below to commemorate this moment forever."
    c$ = "- 15 character max - hit 'RETURN' when done -"
    e$ = "WANT TO PLAY AGAIN? (Press 'Y' or Right-Click for YES)"
    '       check for high score
    IF _FILEEXISTS("scores.txt") THEN
        IF Game.score > HiScore(4).score AND Game.score > 0 THEN '  if new score is > lowest HSBoard entry then
            addYrName = TRUE
            _SNDPLAY S(20) '                zap sound
        END IF
    ELSE IF Game.score > 0 THEN '
            addYrName = TRUE
            _SNDPLAY S(20)
        END IF
    END IF
    _KEYCLEAR

    IF addYrName THEN '                                             print strings
        CLS
        _PUTIMAGE , starScape
        LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), C(3), B '            border
        LINE (30, 30)-(_WIDTH - 31, _HEIGHT - 31), C(3), B
        PAINT (10, 10), C(5), C(3)
        _FONT MenloBig: COLOR C(14)
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(a$) / 2, 100), a$
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(b$) / 2, 160), b$
        COLOR C(3)
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(c$) / 2, 190), c$
        _DISPLAY
        toggle = 1
        i = 0
        DO '                                                        name input loop
            _LIMIT 30
            i = i + 1
            IF i MOD 20 = 0 THEN toggle = -toggle
            d$ = INKEY$
            IF d$ = CHR$(13) THEN EXIT DO '                         return = done
            IF d$ = CHR$(8) THEN '                                  if backspace is pressed...
                newName$ = MID$(newName$, 1, LEN(newName$) - 1)
            ELSE IF LEN(newName$) < 15 THEN
                    newName$ = newName$ + d$
                END IF
            END IF
            LINE (480, 285)-(780, 335), C(0), BF '                      erasure box for name
            LINE (480, 285)-(780, 335), _RGB32(255, 161, 72, 115), B '  text box outline
            _FONT MenloBig: COLOR C(4)
            _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(newName$) / 2 - 14, 300), newName$ '     display new name
            IF LEN(newName$) < 1 THEN
                COLOR C(14)
                _PRINTSTRING (_WIDTH / 2 - 40, 300), CHR$(62) '       ">"
                IF toggle = 1 THEN LINE (600, 297)-(617, 320), C(0), BF '   flashing prompt small erase box
            END IF
            _FONT 16
            _DISPLAY
        LOOP
        newName$ = _TRIM$(MID$(newName$, 1, 15)) '                          limit to 15 characters
        IF Game.cheater THEN newName$ = newName$ + " *" '                   new new new <<<<
    END IF
    ' load latest results from game play to index 6 in array
    HiScore(5).score = Game.score
    HiScore(5).player = newName$
    HiScore(5).kRatio = Game.killRatio
    HiScore(5).timeInBox = Time.inCage
    d = 5
    '   swap the positions
    IF addYrName THEN
        FOR c = 4 TO 0 STEP -1
            IF HiScore(d).score > HiScore(c).score THEN
                SWAP HiScore(d).score, HiScore(c).score
                SWAP HiScore(d).player, HiScore(c).player
                SWAP HiScore(d).kRatio, HiScore(c).kRatio
                SWAP HiScore(d).timeInBox, HiScore(c).timeInBox
                d = d - 1
            ELSE EXIT FOR
            END IF
        NEXT c
    END IF
    '   write adjusted rankings to file
    IF _FILEEXISTS("scores.txt") THEN CLOSE #1

    IF addYrName THEN
        OPEN "temp.txt" FOR OUTPUT AS #2 '
        IF _FILEEXISTS("scores.txt") THEN KILL "scores.txt"
        FOR c = 0 TO 4
            WRITE #2, HiScore(c).player, HiScore(c).score, HiScore(c).kRatio, HiScore(c).timeInBox '
        NEXT c
        CLOSE #2
        NAME "temp.txt" AS "scores.txt" '                       tidy up
    END IF

    IF _FILEEXISTS("temp.txt") THEN KILL "temp.txt" '           <<<<<<<<<<
    '   display results to virtual screen for reuse below
    IF HiScore(0).score = 0 THEN EXIT SUB '                     skip displaying of high score if it's all zeros

    _DEST virtual
    CLS
    _PUTIMAGE , starScape
    LINE (350, 150)-(940, 375), C(8), B
    LINE (347, 147)-(943, 378), C(10), B
    LINE (344, 144)-(946, 381), C(9), B
    _FONT MenloBig
    COLOR C(9)
    _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("HIGH SCORE BOARD") / 2, 90), "HIGH SCORE BOARD"
    _FONT Menlo: COLOR C(14)
    _PRINTMODE _KEEPBACKGROUND
    _PRINTSTRING (365, 172), "  Player" + SPACE$(11) + "     Score" + "          Kill%       Cage Time"
    COLOR C(4)
    _FONT 16 '                                                  CAN'T USE ANY OLD FONT WITH PRINT USING!! <<<< !!

    FOR c = 0 TO 4
        LOCATE 14 + c * 2, 48
        PRINT c + 1
        LOCATE 14 + c * 2, 50
        PRINT ") "; HiScore(c).player
        LOCATE 14 + c * 2, 74
        PRINT USING "#####"; HiScore(c).score
        LOCATE 14 + c * 2, 91
        PRINT USING "###%"; HiScore(c).kRatio
        LOCATE 14 + c * 2, 108
        minutes = INT(HiScore(c).timeInBox / 60): seconds = HiScore(c).timeInBox MOD 60
        IF seconds < 10 THEN secs$ = "0" + _TRIM$(STR$(seconds)) ELSE secs$ = _TRIM$(STR$(seconds))
        PRINT USING "#"; minutes;: PRINT ":"; secs$ '
    NEXT c
    IF Game.cheater THEN '                                      cheaters get labeled...
        LOCATE 26, 61
        PRINT "*";: COLOR C(14): PRINT " Extra ships were added with cheat code."
    END IF
    _DISPLAY '
    _DEST 0 ' --------------------->
    CLS '
    FOR i = 255 TO 0 STEP -4 '                                  fade in scene
        _LIMIT 120 '
        _PUTIMAGE , virtual
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  increase black box transparency
        _DISPLAY
    NEXT
    _SNDSTOP S(28): _SNDVOL S(28), .0005: _SNDLOOP S(28) '      silence & restart harvest loop   ' was .001
    count = -140 '                                              put alien off-left edge
    _KEYCLEAR: _FONT Menlo

    DO
        CLS
        WHILE _MOUSEINPUT: WEND
        IF _MOUSEBUTTON(1) THEN EXIT DO
        _PUTIMAGE , virtual '                                   highScore table and background
        count = count + 1.35
        _PUTIMAGE (-80 + count, 560), I(2) '                    alien ship image
        IF count > 1450 THEN count = -100
        IF vol < .058 THEN vol = vol + .0005: _SNDVOL S(28), vol '  fade in sound

        '   Show player's stats if it's not a high score
        minutes = INT(Time.inCage / 60): seconds = Time.inCage MOD 60 '
        IF seconds < 10 THEN secs$ = "0" + _TRIM$(STR$(seconds)) ELSE secs$ = _TRIM$(STR$(seconds)) '   new <<<< get clock to look right
        i = _PRINTWIDTH(STR$(Game.score)) + _PRINTWIDTH("1:26") + _PRINTWIDTH(STR$(Game.killRatio))
        IF NOT addYrName THEN
            COLOR C(14)
            _PrintString (_Width / 2 - 220 - i / 2, _Height / 2 + 50), "> YOUR STATS >   Score: " + Str$(game.score)_
             + "   Kill%: " + Str$(game.killRatio) + "%   Cage Time: " + _Trim$(Str$(minutes)) + ":" + secs$ '          new <<<<
        END IF
        COLOR C(10)
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(e$) / 2, _HEIGHT / 2 + 100), e$ '    ** PLAY AGAIN? **
        k = k + 1
        IF k > 50 THEN '                                                            attention-grabbing bar
            Line (_Width / 2 - _PrintWidth(e$) / 2, _Height / 2 + 120)_
            -((_Width / 2 + _PrintWidth(e$) / 2) - 7, _Height / 2 + 120), C(4)
            IF k > 100 THEN k = 0
        END IF
        d$ = INKEY$
        IF _MOUSEBUTTON(2) OR d$ = "y" OR d$ = "Y" THEN '                                  ** RESTART **
            Control.restart = TRUE
            Game.killRatio = 0 '                                        gotta zero these out!
            Time.inCage = 0
            soundOff
            EXIT DO
        ELSEIF d$ <> "" THEN soundOff: EXIT DO
        END IF

        LINE (0, 0)-(_WIDTH - 1, _HEIGHT - 1), C(3), B '                blue border
        LINE (24, 24)-(_WIDTH - 25, _HEIGHT - 25), C(3), B
        PAINT (10, 10), C(5), C(3)
        _DISPLAY
        _LIMIT 45
    LOOP

    FOR i = 0 TO 255 STEP 4
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '          quick fade out
        SndFade2 S(28), -.0006, 0, .00034, 0 '
        _DISPLAY
        _LIMIT 60 '
    NEXT
    _FONT 16
    _FREEIMAGE virtual '
END SUB
' -----------------------------------------

SUB popUp ()

    SHARED AS INTEGER popCount
    STATIC AS _BYTE initd, painted, count '
    DIM a$, e%

    IF Control.clearStatics THEN
        initd = FALSE
        count = 0
        painted = FALSE
        EXIT SUB
    END IF

    killNoises: DO: e% = _MOUSEINPUT: LOOP UNTIL e% = 0 '   kill thruster sounds & clear mouse input
    IF NOT initd THEN killChecks: initd = TRUE ' <<<< PUTTING A MOUSEMOVE COMMAND HERE CAUSES POPUP TO STAY POPPED UP - forever!
    ' slow & stop game play while poppedUp
    IF FPS > 10 THEN FPS = FPS - 1
    IF FPS <= 10 THEN Control.hold = TRUE '
    a$ = "ARE YOU SURE YOU WANT TO EXIT?"

    IF Control.hold THEN
        IF count < 10 THEN count = count + 1 '      use 'count' to track cycles, paint popUp only once after the hold so it's translucent not solid red
        WHILE _MOUSEINPUT: WEND '                   needs mouseinput cuz main loop is on hold
        MX = _MOUSEX: MY = _MOUSEY
    END IF
    IF count < 2 THEN '                             popUp painter
        _FONT ModernBigger
        IF popCount < 254 THEN popCount = popCount + 6
        LINE (_WIDTH / 2 - 200, _HEIGHT / 2 - 60)-(_WIDTH / 2 + 200, _HEIGHT / 2 + 100), C(15), B
        IF NOT Control.hold THEN PAINT (_WIDTH / 2, _HEIGHT / 2), _RGB32(255, 0, 0, 40), C(15)
        IF Control.hold AND NOT painted THEN PAINT (_WIDTH / 2, _HEIGHT / 2), _RGB32(255, 0, 0, 40), C(15): painted = TRUE
        COLOR C(14): _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(a$) / 2, _HEIGHT / 2 - 40), a$
        IF NOT Sb.doSaucers THEN
            COLOR _RGB32(0, 255, 0, popCount)
        ELSE COLOR C(4)
        END IF

        LINE (_WIDTH / 2 - 150, _HEIGHT / 2)-(_WIDTH / 2 - 30, _HEIGHT / 2 + 30), C(15), B '        yes / no boxes
        LINE (_WIDTH / 2 + 30, _HEIGHT / 2)-(_WIDTH / 2 + 150, _HEIGHT / 2 + 30), C(15), B '
        LINE (_WIDTH / 2 - 150, _HEIGHT / 2 + 50)-(_WIDTH / 2 - 30, _HEIGHT / 2 + 80), C(15), B '   back 2 intro button
        LINE (_WIDTH / 2 + 30, _HEIGHT / 2 + 50)-(_WIDTH / 2 + 150, _HEIGHT / 2 + 80), C(15), B '   settings button
        _PRINTSTRING (_WIDTH / 2 - 103, _HEIGHT / 2 + 10), "YES"
        _PRINTSTRING (_WIDTH / 2 + 80, _HEIGHT / 2 + 10), "NO"
        _PRINTSTRING (_WIDTH / 2 - 142, _HEIGHT / 2 + 60), "INTRO SCREEN"
        _PRINTSTRING (_WIDTH / 2 + 57, _HEIGHT / 2 + 60), "SETTINGS"
        IF Sb.doSaucers THEN _PUTIMAGE , ViewScreen
        _DISPLAY
    END IF

    IF _MOUSEBUTTON(1) THEN '                                                ** MOUSE INPUT **
        IF MY > _HEIGHT / 2 - 2 AND MY < _HEIGHT / 2 + 32 THEN
            IF MX > _WIDTH / 2 - 152 AND MX < _WIDTH / 2 - 28 THEN '            YES button
                PAINT (_WIDTH / 2 - 120, _HEIGHT / 2 + 10), C(3), C(15)
                _DISPLAY
                _DELAY .1
                wrapUp: SYSTEM
            ELSE IF MX > _WIDTH / 2 + 28 AND MX < _WIDTH / 2 + 152 THEN '  '    NO button
                    PAINT (_WIDTH / 2 + 120, _HEIGHT / 2 + 10), C(3), C(15)
                    _DISPLAY
                    _DELAY .1
                    ' _MouseHide                                                                                NOT NEEDED <<<<<<<<<<<<<<<<<<<<<<
                    Sb.doPopUp = FALSE: Control.pop = FALSE
                    IF NOT Sb.doFF AND NOT Sb.doSaucers THEN turnOnChecks
                    Flag.speedUp = TRUE
                    Control.hold = FALSE
                    initd = FALSE: painted = FALSE
                    popCount = 0: count = 0
                    soundOn
                END IF
            END IF
        END IF

        IF MY > _HEIGHT / 2 + 48 AND MY < _HEIGHT / 2 + 82 THEN
            IF MX > _WIDTH / 2 - 152 AND MX < _WIDTH / 2 - 28 THEN '            INTRO button
                PAINT (_WIDTH / 2 - 100, _HEIGHT / 2 + 60), C(3), C(15)
                _DISPLAY
                _DELAY .1
                Control.hold = FALSE: Sb.doPopUp = FALSE
                Control.pop = FALSE
                popCount = 0: count = 0
                initd = FALSE: painted = FALSE
                soundOff: splashPage
            ELSE
                IF MX > _WIDTH / 2 + 28 AND MX < _WIDTH / 2 + 152 THEN '        SETTINGS button
                    PAINT (_WIDTH / 2 + 50, _HEIGHT / 2 + 60), C(3), C(15)
                    _DISPLAY
                    _DELAY .1
                    Control.hold = FALSE '
                    Sb.doPopUp = FALSE
                    Control.pop = FALSE
                    popCount = 0: count = 0
                    initd = FALSE: painted = FALSE
                    soundOff: settings
                END IF
            END IF
        END IF
    END IF
    IF Flag.landingTime AND NOT Sb.doFF AND NOT Sb.doPopUp AND NOT Ship.landed THEN '   put the ship back at the top
        Ship.x = CENTX: Ship.y = 20
        Ship.Vx = 0: Ship.Vy = 0: Ship.course = 0
    END IF
    _FONT 16: _KEYCLEAR '
END SUB
' -----------------------------------------
SUB soundOff ()
    DIM AS INTEGER c
    FOR c = 15 TO UBOUND(S): _SNDSTOP S(c): NEXT c
    FOR c = 1 TO UBOUND(VO) - 3: _SNDSTOP VO(c): NEXT c
END SUB
' -----------------------------------------
SUB soundOn () '
    IF Sb.doRocks THEN _SNDLOOP S(28) '
    IF Sb.doComets THEN
        _SNDLOOP S(15): _SNDLOOP S(29)
    END IF
    IF Sb.doGrid THEN _SNDLOOP S(17)
    IF Flag.landingTime THEN _SNDLOOP S(30)
    IF Sb.doSaucers THEN _SNDLOOP S(31)
    IF Sb.doFF THEN _SNDLOOP S(32)
END SUB
' -----------------------------------------
SUB CircleFill (CX AS INTEGER, CY AS INTEGER, R AS INTEGER, C AS _UNSIGNED LONG) '  Thanx to S.McNeill & the QB64pe community for this
    'CX = center x coordinate ' CY = center y coordinate 'R = radius ' C = fill color
    DIM Radius AS INTEGER, RadiusError AS INTEGER
    DIM X AS INTEGER, Y AS INTEGER
    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0
    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB
    LINE (CX - X, CY)-(CX + X, CY), C, BF
    WHILE X > Y
        RadiusError = RadiusError + Y * 2 + 1
        IF RadiusError >= 0 THEN
            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF
            X = X - 1
            RadiusError = RadiusError - X * 2
        END IF
        Y = Y + 1
        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    WEND
END SUB
' -----------------------------------------
FUNCTION IsVOPlaying%% '                    is any voice-over playing already?
    DIM AS _BYTE VOPlaying
    DIM AS INTEGER c
    VOPlaying = FALSE '                     assume false to start
    c = 0
    DO
        c = c + 1
        IF _SNDPLAYING(VO(c)) THEN VOPlaying = TRUE
    LOOP UNTIL c = UBOUND(VO)
    IsVOPlaying%% = VOPlaying
END FUNCTION
' -----------------------------------------
SUB playLateVO '                            play VO after timer3 delay
    SHARED AS LONG timer3
    SHARED AS _BYTE delayVO
    IF delayVO <> 29 THEN
        _SNDPLAY VO(delayVO)
    ELSE
        _SNDPLAY VO(29) '               ** packaged sounds ** gotta play them simultaneously
        SELECT CASE Ship.inventory '    "ship destroyed..."
            CASE -1: _SNDPLAY VO(30) '  0
            CASE 0: _SNDPLAY VO(30) '   0
            CASE 1: _SNDPLAY VO(31) '   1
            CASE 2: _SNDPLAY VO(32) '   2
            CASE 3: _SNDPLAY VO(35) '   3
            CASE 4: _SNDPLAY VO(38)
            CASE 5: _SNDPLAY VO(39)
            CASE 6: _SNDPLAY VO(40)
            CASE 7: _SNDPLAY VO(41)
            CASE 8: _SNDPLAY VO(42)
            CASE 9: _SNDPLAY VO(47)
        END SELECT
        _SNDPLAY VO(28) '               remaining
    END IF
    TIMER(timer3) OFF
END SUB
' -----------------------------------------
SUB prioritizeVO (PVO AS _BYTE) '           kill other VOs, play Priority Voice Over
    DIM AS _BYTE c
    FOR c = 1 TO UBOUND(VO)
        IF _SNDPLAYING(VO(c)) THEN _SNDSTOP VO(c)
    NEXT c
    _SNDPLAY VO(PVO) '
END SUB
' -----------------------------------------
SUB buyIn ()

    DIM a$, b$, j$, e%
    SHARED AS LONG timer3, timer4
    STATIC AS _BYTE done
    STATIC AS INTEGER c, d '

    IF Control.clearStatics THEN done = FALSE: EXIT SUB
    killNoises: DO: e% = _MOUSEINPUT: LOOP UNTIL e% = 0 '   turn off thruster noises & clear mouse input
    a$ = "YOU USED UP ALL YOUR DRONES!"
    b$ = "DO YOU WANT TO BUY ANOTHER SHIP? (y/n)  >> COST: 1000 POINTS! <<"
    _LIMIT 50
    _FONT MenloBig: COLOR C(14)
    TIMER(timer4) OFF: TIMER(timer3) OFF
    IF NOT done THEN
        _PRINTSTRING (_WIDTH / 2 - (_PRINTWIDTH(a$) / 2), _HEIGHT / 2), a$
        _SNDPLAY S(0)
        IF Game.score > 1000 THEN
            _FONT Menlo: COLOR C(4)
            _PRINTSTRING (_WIDTH / 2 - (_PRINTWIDTH(b$) / 2), _HEIGHT / 2 + 100), b$
        END IF
        done = TRUE
    END IF

    IF Game.score > 1000 THEN '
        d = d + 1
        j$ = INKEY$
        IF d > 500 THEN j$ = "n" '                  if no response, then end game
        IF j$ = "y" OR j$ = "Y" THEN '              restart game
            Ship.inventory = Ship.inventory + 1 '   bestow ship
            Game.score = Game.score - 1000 '        subtract 1000 points
            Ship.power = 100: Ship.shields = 100
            Sb.doBuyIn = FALSE
            _SNDPLAY S(13)
            turnOnChecks
            c = 0: d = 0: j$ = "": done = FALSE
            Control.hold = FALSE '
        ELSEIF j$ = "n" OR j$ = "N" THEN '
            Sb.doBuyIn = FALSE
            Ship.inventory = 0
            Control.endIt = TRUE '
            c = 0: d = 0: done = FALSE
        END IF
    ELSE c = c + 1
    END IF
    IF c > 170 THEN '           wait a sec then endGame sub -> go to high score board
        Sb.doBuyIn = FALSE
        Ship.inventory = 0
        Control.endIt = TRUE '
        c = 0: d = 0: done = FALSE
    END IF
END SUB
' -----------------------------------------
SUB gauntlet () '

    DIM AS SINGLE i
    DIM AS INTEGER shipAng
    SHARED AS Sector sector()
    SHARED AS particle n(), e(), e2(), sou(), w()
    SHARED AS LONG t1, t2, t3, t4, t5, interval, starScape, shipImg
    SHARED AS _BYTE gauntletFlag(), prezSector, played
    SHARED AS STRING shipType()
    STATIC AS SINGLE c, d
    STATIC AS _BYTE initd, captured, said
    STATIC AS LONG start

    IF Control.clearStatics THEN
        c = 0: d = 0
        initd = FALSE
        captured = FALSE
        said = FALSE
        EXIT SUB
    END IF

    IF NOT initd THEN '                                             intro transition
        Flag.highlight = TRUE
        Ship.charging = TRUE '
        CoAng = -Ship.course - 90: shipAng = -CoAng - 90 '          adjust ship numbers
        soundOff: _SNDLOOP S(46) '                                  spookyLoop
        played = FALSE: quickSound 8 '
        rock(Target).x = Ship.x: rock(Target).y = Ship.y '
        FOR i = 0 TO 248 '                                          fade out scene
            _LIMIT Game.speed '
            CLS
            _SNDVOL S(46), c
            c = c + .00022 '
            _PUTIMAGE , starScape
            Ship.speed = Ship.speed + .1 '                          accelerate away
            Ship.x = COS(_D2R(CoAng)) * Ship.speed + Ship.x '
            Ship.y = SIN(_D2R(CoAng)) * Ship.speed + Ship.y
            PRESET (rock(Target).x, rock(Target).y), C(3) '         rock drop
            DRAW "TA=" + VARPTR$(CoAng) + rock(Target).kind '       spins rock too
            IF c > .008 THEN PAINT (rock(Target).x, rock(Target).y), C(0), C(3)
            rock(Target).y = rock(Target).y + 1.25 '                drop the rock
            PRESET (Ship.x, Ship.y), Ship.col
            DRAW "TA=" + VARPTR$(shipAng) + shipType(2) '           draw ship w/ thruster
            PAINT (Ship.x, Ship.y - 1), C(3), Ship.col
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  fade box
            CoAng = CoAng - 1: shipAng = -CoAng - 90 '              NEW, CHANGE COURSE AS YOU FLY ON AUTO-PILOT
            _DISPLAY
            _SNDVOL S(8), .1 - c * 2.5
        NEXT

        _SNDSTOP S(8): _SNDVOL S(8), .1 '                           reset thruster volume
        FOR i = 255 TO 0 STEP -4 '                                  fade in gauntlet scene
            _LIMIT 45 '
            _PUTIMAGE , I(26) '                                     gauntlet
            _PUTIMAGE (65, 620), I(27) '                            diamond
            LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  increase black box transparency
            _DISPLAY
        NEXT
        _DELAY .4
        ThreeTimersOn: TIMER(interval) ON '           start timers
        Flag.harpooned = FALSE
        Flag.doRockMask = FALSE
        start = TIMER
        TIMER(t3) ON '                              turns on north blaster first, then east2 below
        prezSector = 1 '                            set start sector
        Ship.x = 1279: Ship.y = 600 '               put ship in sector1
        Ship.course = -270: Ship.speed = .9 '       auto pilot course, speed
        DO: c = _MOUSEINPUT: LOOP UNTIL c = 0 '     clear mouse input  <<<<
        initd = TRUE: c = 0
        Ship.charging = FALSE '
        _SNDPLAY VO(46)
    END IF
    ' -------------------                                               render front-end
    IF TIMER - start > 1.15 THEN TIMER(t5) ON '                         start east2 blaster staggered with north
    d = d + .2
    CIRCLE (1255, 400 - d * 2.6), 4, _RGB32(255, 110, 225) '            bubbles in magma on right
    PAINT (1255, 400 - d * 2.6), _RGB32(255, 110, 255, 225 - d * 1.5), _RGB32(255, 110, 225)
    CIRCLE (1265, 380 - d * 2.7), 3, _RGB32(255, 100, 255)
    PAINT (1265, 380 - d * 2.7), _RGB32(255, 100, 255, 225 - d * 2), _RGB32(255, 100, 255)
    CIRCLE (1269, 410 - d * 2.4), 3, _RGB32(235, 80, 255)
    PAINT (1269, 410 - d * 2.4), _RGB32(235, 80, 255, 225 - d * 2.5), _RGB32(235, 80, 255)
    IF d > 180 THEN d = 0

    IF gauntletFlag(1) THEN east1 '                 timed eruptions @ 5 stations
    IF gauntletFlag(2) THEN south
    IF gauntletFlag(3) THEN north
    IF gauntletFlag(4) THEN west
    IF gauntletFlag(5) THEN east2

    SELECT CASE prezSector '                        navigation and impact checking
        CASE 1: sector1
        CASE 2: sector2
        CASE 3: sector3
        CASE 4: sector4
        CASE 5: sector5
        CASE 6: sector6
        CASE 7: sector7
        CASE 8: sector8
    END SELECT
    IF prezSector = 6 THEN
        SndFade2 S(46), -.0002, 0, .022, 0 '
        IF NOT captured THEN
            IF Ship.x > 50 AND Ship.x < 80 AND Ship.y > 605 AND Ship.y < 635 THEN
                _SNDPLAY S(14) '                    harpoon sound
                _SNDPLAY S(18) '                    booty sound
                Game.score = Game.score + 1200 '    big points
                Flag.highlight = FALSE
                captured = TRUE
            END IF
        END IF
    END IF
    IF Flag.highlight THEN '
        c = c + .36
        CIRCLE (81, 632), 10 + c, _RGB32(255, 190, 25, 180 - c * 5.5) ' highlight diamond - not captured
        IF c > 35 THEN c = 0
    ELSE _PUTIMAGE (Ship.x - 20, Ship.y - 10), I(27) '          else diamond captured
        CoAng = -CoAng - 90
        PRESET (Ship.x, Ship.y), Ship.col
        DRAW "TA=" + VARPTR$(CoAng) + Ship.kind '               draw ship again so it's on top
        PAINT (Ship.x, Ship.y - 1), C(3), Ship.col
        IF NOT said THEN _SNDPLAY VO(45): said = TRUE '         "exit left side"
    END IF
END SUB
' -------------------
SUB north () '                  # 3, a repeater
    SHARED AS particle n()
    STATIC AS INTEGER c
    STATIC AS _BYTE initd, reset_values, played '           Thanks to Steve McNeill for showing me how to streamline this routine
    SHARED AS LONG t3 '                                     instead of three separate loops, one big one...
    SHARED AS _BYTE gauntletFlag()

    IF Control.clearStatics THEN initd = FALSE: c = 0: EXIT SUB
    IF NOT initd THEN reset_values = TRUE: played = FALSE: initd = TRUE
    IF NOT played THEN _SNDPLAYCOPY S(41), .02: played = TRUE
    c = -1
    DO
        c = c + 1
        IF reset_values THEN '                              init particles
            n(c).x = 561
            n(c).y = c * -5 + 146
            n(c).Vx = 0
            n(c).Vy = 9 + (RND - RND) / 4
            n(c).brightness = 255
        END IF
        n(c).x = n(c).x + n(c).Vx '                         move em
        n(c).y = n(c).y + n(c).Vy
        IF n(c).y > 136 AND n(c).y < 146 THEN n(c).Vx = (RND - RND) * 4 '
        IF n(c).y > 150 THEN IF n(c).brightness > 1 THEN n(c).brightness = n(c).brightness - 12 '
        IF n(c).y > 151 AND n(c).y < 300 THEN
            IF c MOD 2 = 0 THEN
                CIRCLE (n(c).x, n(c).y), 2, _RGB32(255, 90, 0, n(c).brightness) '       draw em
            ELSE CIRCLE (n(c).x, n(c).y), 1, _RGB32(225, 180, 255, n(c).brightness)
            END IF
        END IF
    LOOP UNTIL c = UBOUND(n)

    IF n(UBOUND(n)).y > 200 THEN '
        reset_values = TRUE
        initd = FALSE
        gauntletFlag(3) = FALSE
    ELSE reset_values = FALSE
    END IF
END SUB
' -------------------
SUB east1 () '                  # 1

    STATIC AS INTEGER c
    STATIC AS _BYTE initd, reset_values, played
    SHARED AS LONG t1
    SHARED AS particle e()
    SHARED AS _BYTE gauntletFlag()

    IF Control.clearStatics THEN initd = FALSE: c = 0: EXIT SUB
    IF NOT initd THEN reset_values = TRUE: played = FALSE: initd = TRUE
    IF NOT played THEN _SNDPLAYCOPY S(43), .006, 1: played = TRUE '         stereo right channel
    c = -1
    DO
        c = c + 1
        IF reset_values THEN
            e(c).x = c * 5 + 1004 '
            e(c).y = 472 '
            e(c).Vx = -13 - (RND - RND) / 2
            e(c).Vy = 0
            e(c).brightness = 255
        END IF
        e(c).x = e(c).x + e(c).Vx
        e(c).y = e(c).y + e(c).Vy
        IF e(c).x < 1004 AND e(c).x > 994 THEN e(c).Vy = (RND - RND) * 2.9 ' was 2.3
        IF e(c).x < 1000 THEN IF e(c).brightness > 1 THEN e(c).brightness = e(c).brightness - 7 '
        IF e(c).x < 1001 AND e(c).x > 630 AND e(c).y < 520 THEN
            IF c MOD 2 = 0 THEN '
                CIRCLE (e(c).x, e(c).y), 1, _RGB32(255, 255, 0, e(c).brightness)
            ELSE CIRCLE (e(c).x, e(c).y), 2, _RGB32(255, 152, 33, e(c).brightness)
            END IF
        END IF
    LOOP UNTIL c = UBOUND(e)

    IF e(UBOUND(e)).x < 800 THEN
        reset_values = TRUE
        initd = FALSE
        TIMER(t1) OFF: gauntletFlag(1) = FALSE
    ELSE reset_values = FALSE
    END IF
END SUB
' ------------------
SUB east2 () '                  # 5, a repeater
    SHARED AS particle e2()
    STATIC AS INTEGER c
    STATIC AS _BYTE initd, reset_values, played
    SHARED AS _BYTE gauntletFlag()

    IF Control.clearStatics THEN initd = FALSE: c = 0: EXIT SUB
    IF NOT initd THEN reset_values = TRUE: played = FALSE: initd = TRUE
    IF NOT played THEN _SNDPLAYCOPY S(42), .0094, -.7: played = TRUE '      stereo left channel
    c = -1
    DO
        c = c + 1
        IF reset_values THEN
            e2(c).x = c * 5 + 301 '
            e2(c).y = 444 '
            e2(c).Vx = -10 - (RND - RND) / 4
            e2(c).Vy = 0
            e2(c).brightness = 255
        END IF
        e2(c).x = e2(c).x + e2(c).Vx
        e2(c).y = e2(c).y + e2(c).Vy
        IF e2(c).x < 300 AND e2(c).x > 290 THEN e2(c).Vy = (RND - RND) * 6
        IF e2(c).x < 305 THEN IF e2(c).brightness > 1 THEN e2(c).brightness = e2(c).brightness - 13 '
        IF e2(c).x < 298 AND e2(c).x > 150 THEN
            IF c MOD 2 = 0 THEN '
                CIRCLE (e2(c).x, e2(c).y), 1, _RGB32(255, 205, 155, e2(c).brightness)
            ELSE CIRCLE (e2(c).x, e2(c).y), 2, _RGB32(255, 72, 33, e2(c).brightness)
            END IF
        END IF
    LOOP UNTIL c = UBOUND(e2)

    IF e2(UBOUND(e2) - 30).x < 0 THEN
        reset_values = TRUE
        initd = FALSE
        gauntletFlag(5) = FALSE
    ELSE reset_values = FALSE
    END IF
END SUB
' -------------------
SUB south () '                      # 2

    STATIC AS INTEGER c
    STATIC AS _BYTE initd, reset_values, played
    SHARED AS LONG t2
    SHARED AS particle sou()
    SHARED AS _BYTE gauntletFlag()

    IF Control.clearStatics THEN initd = FALSE: c = 0: EXIT SUB
    IF NOT initd THEN reset_values = TRUE: played = FALSE: initd = TRUE
    IF NOT played THEN _SNDPLAYCOPY S(44), .005, .7: played = TRUE
    c = -1
    DO
        c = c + 1
        IF reset_values THEN
            sou(c).x = 710
            sou(c).y = c * 5 + 551
            sou(c).Vx = 0
            sou(c).Vy = -12 - (RND - RND) / 4
            sou(c).brightness = 255
        END IF
        sou(c).x = sou(c).x + sou(c).Vx
        sou(c).y = sou(c).y + sou(c).Vy
        IF sou(c).y < 555 AND sou(c).y > 545 THEN sou(c).Vx = (RND - RND) * 4 ' was 3
        IF sou(c).y < 552 THEN IF sou(c).brightness > 1 THEN sou(c).brightness = sou(c).brightness - 6
        IF sou(c).y < 549 AND sou(c).y > 180 AND sou(c).x < 766 THEN
            IF c MOD 2 = 0 THEN
                CIRCLE (sou(c).x, sou(c).y), 2, _RGB32(255, 150, 0, sou(c).brightness)
            ELSE CIRCLE (sou(c).x, sou(c).y), 1, _RGB32(255, 200, 0, sou(c).brightness)
            END IF
        END IF
    LOOP UNTIL c = UBOUND(sou)

    IF sou(UBOUND(sou)).y < 270 THEN ' was 180
        reset_values = TRUE
        initd = FALSE
        TIMER(t2) OFF: gauntletFlag(2) = FALSE
    ELSE reset_values = FALSE
    END IF
END SUB
' -------------------
SUB west () '                           # 4

    STATIC AS INTEGER c
    STATIC AS _BYTE initd, reset_values, played
    SHARED AS LONG t4
    SHARED AS particle w()
    SHARED AS _BYTE gauntletFlag()

    IF Control.clearStatics THEN initd = FALSE: c = 0: EXIT SUB
    IF NOT initd THEN reset_values = TRUE: played = FALSE: initd = TRUE
    IF NOT played THEN _SNDPLAYCOPY S(45), .02, -1: played = TRUE
    c = -1
    DO
        c = c + 1
        IF reset_values THEN
            w(c).x = c * -5 + 127 '
            w(c).y = 234
            w(c).Vx = 14 + (RND - RND) / 2
            w(c).Vy = 0
            w(c).brightness = 255
        END IF
        w(c).x = w(c).x + w(c).Vx
        w(c).y = w(c).y + w(c).Vy
        IF w(c).x > 127 AND w(c).x < 147 THEN w(c).Vy = (RND - RND) * 3.2 '  2.8
        IF w(c).x > 130 THEN IF w(c).brightness > 1 THEN w(c).brightness = w(c).brightness - 4.25
        IF w(c).x > 127 AND w(c).x < 770 AND w(c).y > 175 AND w(c).y < 300 THEN
            IF c MOD 2 = 0 THEN
                CIRCLE (w(c).x, w(c).y), 2, _RGB32(255, 170, 0, w(c).brightness) '
            ELSE CIRCLE (w(c).x, w(c).y), 1, _RGB32(255, 250, 0, w(c).brightness)
            END IF
        END IF
    LOOP UNTIL c = UBOUND(w)

    IF w(UBOUND(w)).x > 700 THEN ' was 760
        reset_values = TRUE
        initd = FALSE
        TIMER(t4) OFF: gauntletFlag(4) = FALSE
    ELSE reset_values = FALSE
    END IF
END SUB
' -----------------------------------------
SUB sector1 ()
    SHARED AS _BYTE prezSector
    '                                                   ALL SAFE
    SELECT CASE Ship.x
        CASE IS > 1280: Ship.x = 1272: Ship.speed = 0
        CASE IS < 826: Ship.x = 826: Ship.speed = 0
    END SELECT
    SELECT CASE Ship.y
        CASE IS > 650: Ship.y = 650: Ship.speed = 0
        CASE IS < 531: IF Ship.x > 821 AND Ship.x < 979 THEN prezSector = 2 ELSE Ship.y = 531: Ship.speed = 0 ' through to next sector...
    END SELECT
END SUB
' -----------------------------------------
SUB sector2 ()
    SHARED AS _BYTE prezSector, gauntletFlag()
    SHARED AS INTEGER boomDelay
    SHARED AS particle e(), sou()

    SELECT CASE Ship.x
        CASE IS > 974: Ship.x = 974: Ship.speed = 0
        CASE IS < 634: Ship.x = 634: Ship.speed = 0
    END SELECT
    SELECT CASE Ship.y
        CASE IS > 524: IF Ship.x > 822 AND Ship.x < 979 THEN prezSector = 1 ELSE Ship.y = 524: Ship.speed = 0
        CASE IS < 425: IF Ship.x > 627 AND Ship.x < 775 THEN prezSector = 3 ELSE Ship.y = 425: Ship.speed = 0
    END SELECT

    IF gauntletFlag(1) THEN '                                   east1 check
        IF e(1).x < Ship.x THEN '
            IF PointInTriangle(Ship.x, Ship.y, 700, 420, 700, 526, 1000, 473) THEN '
                IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE '
            END IF
        END IF
    END IF

    IF gauntletFlag(2) THEN '
        IF sou(1).y < Ship.y THEN
            IF PointInTriangle(Ship.x, Ship.y, 710, 546, 650, 418, 760, 420) THEN
                IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE
            END IF
        END IF
    END IF
END SUB
' -----------------------------------------
SUB sector3 ()
    SHARED AS _BYTE prezSector, gauntletFlag()
    SHARED AS INTEGER boomDelay
    SHARED AS particle sou()
    SELECT CASE Ship.x
        CASE IS > 769: IF Ship.y > 300 AND Ship.y < 360 THEN
                prezSector = 7
            ELSE Ship.x = 769: Ship.speed = 0 '                 hide in niche
            END IF
        CASE IS < 633: Ship.x = 633: Ship.speed = 0
    END SELECT
    SELECT CASE Ship.y
        CASE IS > 420: prezSector = 2
        CASE IS < 300: prezSector = 4
    END SELECT

    IF gauntletFlag(2) THEN '
        IF sou(1).y < Ship.y THEN
            IF PointInTriangle(Ship.x, Ship.y, 710, 546, 626, 300, 762, 300) THEN
                IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE
            END IF
        END IF
    END IF
END SUB
' -----------------------------------------
SUB sector4 ()
    SHARED AS _BYTE prezSector, gauntletFlag()
    SHARED AS INTEGER boomDelay
    SHARED AS particle w(), sou(), n()

    SELECT CASE Ship.x
        CASE IS > 769: Ship.x = 769: Ship.speed = 0
        CASE IS < 154: Ship.x = 154: Ship.speed = 0
    END SELECT '
    SELECT CASE Ship.y '
        CASE IS > 295: IF Ship.x > 627 AND Ship.x < 776 THEN prezSector = 3
            IF Ship.x > 147 AND Ship.x < 281 THEN prezSector = 5
            IF Ship.x > 280 AND Ship.x < 628 THEN Ship.y = 295: Ship.speed = 0
        CASE IS < 174: IF Ship.x > 436 AND Ship.x < 496 THEN prezSector = 8 ELSE Ship.y = 174: Ship.speed = 0 ' hide in niche
    END SELECT

    IF gauntletFlag(3) THEN '
        IF Ship.x > 488 AND Ship.x < 623 THEN '
            IF n(1).y > Ship.y THEN
                IF PointInTriangle(Ship.x, Ship.y, 560, 153, 488, 300, 623, 300) THEN
                    IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE
                END IF
            END IF
        END IF
    END IF
    IF gauntletFlag(4) THEN '
        IF w(1).x > Ship.x AND Ship.x > 436 THEN
            IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE: EXIT SUB
        END IF
        IF w(1).x > Ship.x THEN
            IF PointInTriangle(Ship.x, Ship.y, 132, 232, 436, 169, 436, 299) THEN '
                IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE
            END IF
        END IF
    END IF
END SUB
' -----------------------------------------
SUB sector5 ()
    SHARED AS _BYTE prezSector, gauntletFlag()
    SHARED AS INTEGER boomDelay
    SHARED AS particle e2()
    SELECT CASE Ship.x
        CASE IS > 274: Ship.x = 274: Ship.speed = 0
        CASE IS < 154: Ship.x = 154: Ship.speed = 0
    END SELECT
    SELECT CASE Ship.y
        CASE IS > 532: prezSector = 6 '
        CASE IS < 300: prezSector = 4
    END SELECT

    IF gauntletFlag(5) THEN
        IF e2(1).x < Ship.x THEN
            IF PointInTriangle(Ship.x, Ship.y, 293, 442, 142, 520, 142, 360) THEN
                IF NOT stopCheck THEN TIMER(boomDelay) ON: stopCheck = TRUE
            END IF
        END IF
    END IF
END SUB
' -----------------------------------------
SUB sector6 ()
    DIM AS INTEGER i
    SHARED AS _BYTE prezSector '                 ALL SAFE
    SHARED AS LONG timer1
    SELECT CASE Ship.x
        CASE IS > 272: Ship.x = 272: Ship.speed = 0
        CASE IS < -3: IF Flag.highlight THEN '               <<<<<<<<<<<    left side exit
                Ship.x = 5
            ELSE
                Flag.landingTime = TRUE
                Sb.doGauntlet = FALSE: SubFlags(21) = FALSE
                Flag.showMoonScape = TRUE
                Flag.fadeIn = TRUE
                Sb.doShip = FALSE
                TIMER(timer1) ON
                killNoises
                Control.hold = TRUE '
                FOR i = 1 TO 255 STEP 4 '                                   fade out gauntlet scene
                    _LIMIT 40 '
                    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA(0, 0, 0, i), BF '  decrease black box transparency
                    _DISPLAY
                NEXT
            END IF
            _SNDSTOP S(46) '                        kill spooky loop if not already done
    END SELECT '
    SELECT CASE Ship.y
        CASE IS > 662: Ship.y = 662: Ship.speed = 0
        CASE IS < 543: IF Ship.x > 148 AND Ship.x < 533 THEN prezSector = 5 ELSE Ship.y = 543: Ship.speed = 0
    END SELECT
END SUB
' -----------------------------------------
SUB sector7 ()
    SHARED AS _BYTE prezSector '              SAFE_NICHE 1 in Sector 3
    SELECT CASE Ship.x
        CASE IS > 802: Ship.x = 802: Ship.speed = 0 '
        CASE IS < 775: prezSector = 3
    END SELECT
    SELECT CASE Ship.y
        CASE IS > 355: Ship.y = 355: Ship.speed = 0
        CASE IS < 308: Ship.y = 308: Ship.speed = 0
    END SELECT
END SUB
' -----------------------------------------
SUB sector8 ()
    SHARED AS _BYTE prezSector '              SAFE_NICHE 2 in Sector 4
    SELECT CASE Ship.x
        CASE IS > 489: Ship.x = 489: Ship.speed = 0 '
        CASE IS < 443: Ship.x = 443: Ship.speed = 0
    END SELECT
    SELECT CASE Ship.y
        CASE IS > 169: prezSector = 4
        CASE IS < 147: Ship.y = 147: Ship.speed = 0
    END SELECT
END SUB
' -----------------------------------------
FUNCTION PointInTriangle%% (X%, Y%, X1%, Y1%, X2%, Y2%, X3%, Y3%) '     Big Thanks to MasterGy for this bit of code!
    DIM D1%, D2%, D3%
    D1% = (X% - X2%) * (Y1% - Y2%) - (X1% - X2%) * (Y% - Y2%) '         is point x,y bounded by triangle formed by other 3 points?
    D2% = (X% - X3%) * (Y2% - Y3%) - (X2% - X3%) * (Y% - Y3%)
    D3% = (X% - X1%) * (Y3% - Y1%) - (X3% - X1%) * (Y% - Y1%)
    PointInTriangle%% = (D1% > 0 AND D2% > 0 AND D3% > 0) OR (D1% < 0 AND D2% < 0 AND D3% < 0)
END FUNCTION
' -----------------------------------------
SUB flipOnEast1 (): SHARED AS _BYTE gauntletFlag(): gauntletFlag(1) = TRUE: END SUB
SUB flipOnSouth (): SHARED AS _BYTE gauntletFlag(): gauntletFlag(2) = TRUE: END SUB
SUB flipOnNorth (): SHARED AS _BYTE gauntletFlag(): gauntletFlag(3) = TRUE: END SUB
SUB flipOnWest (): SHARED AS _BYTE gauntletFlag(): gauntletFlag(4) = TRUE: END SUB
SUB flipOnEast2 (): SHARED AS _BYTE gauntletFlag(): gauntletFlag(5) = TRUE: END SUB
SUB delayedboom (): SHARED AS INTEGER boomDelay: TIMER(boomDelay) OFF: shipBoom: END SUB
SUB ThreeTimersOn (): SHARED AS LONG t1, t2, t4: TIMER(t1) ON: TIMER(t2) ON: TIMER(t4) ON: END SUB
' -----------------------------------------
SUB fireworks () ' _Title "Fireworks 3 translation to QB64 2017-12-26 bplus"    THANK YOU bplus FOR THIS ROUTINE!
    '                                                                           I used the 1st version - it's short & sweet.
    CONST xmax = 1280
    CONST ymax = 700
    TYPE placeType '
        x AS SINGLE
        y AS SINGLE
    END TYPE
    TYPE flareType
        x AS SINGLE
        y AS SINGLE
        dx AS SINGLE
        dy AS SINGLE
        c AS LONG
    END TYPE
    DIM AS INTEGER flareMax, debrisMax, debrisStack, loopCount, i, nxt, rc, d
    DIM AS SINGLE rndcycle, angle, j, k, l
    j = 0: d = 0: k = .12: l = .16
    flareMax = 1000: debrisStack = 0: debrisMax = 5000
    DIM flare(flareMax) AS flareType
    DIM burst AS placeType
    SHARED AS debrisType debris()
    SHARED AS LONG starScape
    SHARED AS SINGLE xScroller

    _SNDPLAY S(47) '                                cheering
    FOR i = 1 TO 140: keepScrolling .18: NEXT i '   pause and scroll along
    _SNDPLAY S(48) '                                fireworks noises
    WHILE 1
        rndcycle = RND * 30
        loopCount = 0
        burst.x = .75 * xmax * RND + .125 * xmax
        burst.y = .5 * ymax * RND + .125 * ymax
        WHILE loopCount < 7
            CLS
            keepScrolling .4 '             scroll faster during fireworks to account for slowness
            FOR i = 1 TO 200 '              new burst using random old flames to sim burnout
                nxt = INT(RND * flareMax)
                angle = RND * _PI(2)
                flare(nxt).x = burst.x + RND * 5 * COS(angle)
                flare(nxt).y = burst.y + RND * 5 * SIN(angle)
                angle = RND * _PI(2)
                flare(nxt).dx = RND * 15 * COS(angle)
                flare(nxt).dy = RND * 15 * SIN(angle)
                rc = INT(RND * 3)
                IF rc = 0 THEN
                    flare(nxt).c = _RGB32(255, 100, 0)
                ELSEIF rc = 1 THEN
                    flare(nxt).c = _RGB32(0, 0, 255)
                ELSE
                    flare(nxt).c = _RGB32(255, 255, 255)
                END IF
            NEXT
            FOR i = 0 TO flareMax
                IF flare(i).dy <> 0 THEN '  while still moving vertically
                    LINE (flare(i).x, flare(i).y)-STEP(flare(i).dx, flare(i).dy), _RGB32(98, 98, 98)
                    flare(i).x = flare(i).x + flare(i).dx
                    flare(i).y = flare(i).y + flare(i).dy
                    COLOR flare(i).c
                    CIRCLE (flare(i).x, flare(i).y), 1
                    flare(i).dy = flare(i).dy + .4 '    add  gravity
                    flare(i).dx = flare(i).dx * .95 '   add some air resistance
                    IF flare(i).x < 0 OR flare(i).x > xmax THEN flare(i).dy = 0 '   outside of screen
                END IF
            NEXT

            d = d + 1 '                                 <<<< OFF RAMP >>>>
            IF d > 120 THEN '                           plenty of fireworks
                k = k - .004: l = l - .0053 '           fade out clapping and fireworks sounds
                _SNDVOL S(47), k '
                _SNDVOL S(48), l
            END IF
            _DISPLAY
            _LIMIT 46 '
            loopCount = loopCount + 1
        WEND
        IF debrisStack < debrisMax THEN
            FOR i = 1 TO 20
                NewDebris i + debrisStack
            NEXT
            debrisStack = debrisStack + 20
        END IF
        IF k < 0 OR l < 0 THEN EXIT SUB '               EXIT after a firework cycle
    WEND
END SUB
' ------------------------------
SUB NewDebris (i AS INTEGER)
    DIM AS SINGLE c
    SHARED AS debrisType debris()
    debris(i).x = RND * 1280
    debris(i).y = RND * 700
    c = RND * 255
    debris(i).c = _RGB32(c, c, c)
END SUB
' ------------------------------
SUB keepScrolling (speed AS SINGLE) '                   runs in closed loops - for outro only
    SHARED AS LONG starScape, MoonScape, starScape2
    SHARED AS SINGLE xScroller
    DIM AS INTEGER spin

    CLS
    _LIMIT 60
    xScroller = xScroller - speed '                     maintain the end scene on the moon...
    _PUTIMAGE (xScroller, 0), starScape '               scroll stars
    _PUTIMAGE (1281 + xScroller, 0), starScape2
    IF xScroller < -1280 THEN xScroller = 0
    _PUTIMAGE (Ship.x - 20, Ship.y - 10), I(28) '       diamond                                   *
    _PUTIMAGE (0, 530)-(1280, 720), MoonScape '         moon                                      *
    spin = Ship.course '                                                                          *
    PRESET (Ship.x, Ship.y), Ship.col '                                                           *
    DRAW "TA=" + VARPTR$(spin) + Ship.kind '            ship                                      *
    PAINT (Ship.x, Ship.y - 1), C(3), Ship.col '                                                  *
    driveTruck '                                        truck continuity                          *
    _DISPLAY '                                                                                    *
END SUB '                                                                                         *
' -------------------------------------------------------------------------------------------------
