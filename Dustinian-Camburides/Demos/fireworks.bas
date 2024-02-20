'FIREWORK.BAS
'============

'DESCRIPTION
'-----------
'   A fireworks screensaver for QBasic.

'AUTHOR
'------
'   Dustinian Camburides

'PLATFORM
'--------
'   Written in QB64. I hope to make it QBasic-compatible, but no work on that yet.

'VERSION
'-------
'1.0, 2022-09-08: First working version.
'1.1, 2023-07-04: Changed hues by month.

'META
'----
'$DYNAMIC

'USER-DEFINED TYPES
'------------------
TYPE Particle
    X0 AS SINGLE 'Current X value of particle (current frame) (used to draw flare point).
    Y0 AS SINGLE 'Current Y value of particle (current frame) (used to draw flare point).
    X1 AS SINGLE 'Previous X value of particle (last frame) (used to draw bright trail).
    Y1 AS SINGLE 'Previous Y value of particle (last frame) (used to draw bright trail).
    X2 AS SINGLE 'Previous X value of particle (frame before last) (used to draw dim trail).
    Y2 AS SINGLE 'Previous Y value of particle (frame before last) (used to draw dim trail).
    Angle AS SINGLE 'Trajectory of particle (degrees).
    Velocity AS SINGLE 'Velocity of particle (pixels per frame).
    Stage AS INTEGER 'Stage of particle (a particle with one or more stages left will "burst" when the fuse is 0).
    Hue AS INTEGER 'The hue of the particle (this the bright color, the program assumes that (Hue MINUS 8) is the dim color).
    Fuse AS INTEGER 'The number of frames left before the particle bursts or burns out.
END TYPE

TYPE Hue
    Brighter AS INTEGER
    Dimmer AS INTEGER
END TYPE

'SUBS
'----
DECLARE SUB Initialize_Hues (Hues() AS Hue)
DECLARE SUB Remove_Particle (Particles() AS Particle, ID AS INTEGER)
DECLARE SUB Append_Particle (Particles() AS Particle, New_Particle AS Particle)
DECLARE SUB Particle_Burst (Current AS Particle, Past AS Particle)
DECLARE SUB Particle_Move (Current AS Particle)
DECLARE SUB Particle_Draw (Current AS Particle, Hues() AS Hue)
DECLARE FUNCTION NewX! (X AS SINGLE, Angle AS SINGLE, Distance AS SINGLE)
DECLARE FUNCTION NewY! (Y AS SINGLE, Angle AS SINGLE, Distance AS SINGLE)
DECLARE FUNCTION RandomBetween% (Minimum AS INTEGER, Maximum AS INTEGER)

'CONSTANTS
'---------
CONST X_MIN = 250 'Minimum X value of firework launch point.
CONST X_MAX = 425 'Maximum X value of firework launch point.
CONST Y_MIN = 350 'Minimum Y value of firework launch point.
CONST Y_MAX = 350 'Maximum Y value of firework launch point.
CONST ANGLE_MIN = 135 'Mimimum angle of firework launch (degrees) (MINUS 180).
CONST ANGLE_MAX = 225 'Maximum angle of firework launch (degrees) (MINUS 180).
CONST VELOCITY_MIN = 5 'Minimum velocity of firework launch (pixels per frame).
CONST VELOCITY_MAX = 12 'Maximum velocity of firework launch (pixels per frame).
CONST STAGE_MIN = 1 'Minimum stages of firework at launch (will burst until 0).
CONST STAGE_MAX = 2 'Maximum stages of firework at launch (will burst until 0).
CONST FUSE_MIN = 20 'Minimum frames the firework will last until the next stage.
CONST FUSE_MAX = 30 'Maximum frames the firework will last until the next stage.
CONST BURST_MIN = 15 'Minimum number of particles that will be produced by a burst.
CONST BURST_MAX = 25 'Maximum number of particles that will be produced by a burst.
CONST DELAY = .04 'The number of seconds between snowflake recalculation / re-draw... QBasic can't detect less than 0.04 seconds...
CONST NEWFIREWORKODDS = 11 'The odds a new firework will be launched.

'VARIABLES
'---------
DIM sngStart AS SINGLE 'The timer at the start of the delay loop.
DIM intParticle AS INTEGER 'The current particle being worked in the loop.
DIM intChildParticles AS INTEGER 'The number of child particles being created after a burst.
DIM intChildParticle AS INTEGER 'The current child particle being worked in the loop.
DIM Fireworks(0) AS Particle 'All of the particles in the fireworks show.
DIM New_Particle AS Particle 'The new particle being created at launch.
DIM Hues(0) AS Hue 'An array of brighter / dimmer firework hues.

'PROCEDURES
'----------

'INITIALIZE SCREEN: Set the screen to mode 9.
'Active page (where the cls, pset, and line commands occur) of 0 and a v
'Visible page (that the user sees) of 1.
'640 X 350
SCREEN 9, , 0, 1: CLS

PLAY "mb"

'INITIALIZE HUES
CALL Initialize_Hues(Hues())

'INITIALIZE TIMER
TIMER ON: RANDOMIZE TIMER

'LOOP EVERY FRAME
WHILE INKEY$ = ""
    'Reset current particle...
    intParticle = LBOUND(Fireworks)
    'Start timer...
    sngStart = TIMER
    'If we generate a random number within the new firework odds...
    IF RandomBetween%(1, 100) <= NEWFIREWORKODDS THEN
        'Launch a new firework...
        New_Particle.X0 = RandomBetween%(X_MIN, X_MAX)
        New_Particle.Y0 = RandomBetween%(Y_MIN, Y_MAX)
        New_Particle.X1 = New_Particle.X0
        New_Particle.Y1 = New_Particle.Y0
        New_Particle.X2 = New_Particle.X0
        New_Particle.Y2 = New_Particle.Y0
        New_Particle.Angle = RandomBetween%(ANGLE_MIN, ANGLE_MAX) - 180
        New_Particle.Velocity = RandomBetween%(VELOCITY_MIN, VELOCITY_MAX)
        New_Particle.Stage = RandomBetween(STAGE_MIN, STAGE_MAX)
        New_Particle.Hue = RandomBetween(LBOUND(Hues), UBOUND(Hues))
        New_Particle.Fuse = RandomBetween(FUSE_MIN, FUSE_MAX)
        SOUND INT(RND * 10) * 10 + 37, RND * 0.1
        CALL Append_Particle(Fireworks(), New_Particle)
    END IF
    'For each particle...
    WHILE intParticle <= UBOUND(Fireworks)
        'If the fuse is zero...
        IF Fireworks(intParticle).Fuse = 0 AND Fireworks(intParticle).Stage > 0 THEN
            'Burst the particle...
            SOUND INT(RND * 10) * 10 + 37, RND * 0.1
            intChildParticles = RandomBetween%(BURST_MIN, BURST_MAX)
            FOR intChildParticle = 0 TO intChildParticles
                CALL Particle_Burst(New_Particle, Fireworks(intParticle))
                CALL Append_Particle(Fireworks(), New_Particle)
            NEXT intChildParticle
        END IF
        'If the fuse is > -2...
        IF Fireworks(intParticle).Fuse > -2 THEN
            'Draw the particle...
            CALL Particle_Move(Fireworks(intParticle))
            CALL Particle_Draw(Fireworks(intParticle), Hues())
            'MAYBE ONLY INCREMENT PARTICLES HERE?
            intParticle = intParticle + 1 'WE'RE SKIPPING FRAMES SOMETIMES HERE...
        ELSE
            CALL Remove_Particle(Fireworks(), intParticle)
        END IF
    WEND
    'Wait for the delay to pass before starting over...
    WHILE (TIMER < (sngStart + DELAY)) AND (TIMER >= sngStart)
    WEND
    'Copy the active page (where we just drew the snow) to the visible page...
    PCOPY 0, 1
    'Clear the active page for the next frame...
    CLS
WEND
TIMER OFF
PCOPY 0, 1
END

SUB Initialize_Hues (Hues() AS Hue)
    'Sets the hues by month using the default 16-color palette.
    SELECT CASE VAL(LEFT$(DATE$, 2))
        CASE 2 'February
            'Pink and White
            REDIM Hues(1) AS Hue
            Hues(0).Brighter = 13: Hues(0).Dimmer = 5
            Hues(1).Brighter = 15: Hues(1).Dimmer = 7
        CASE 3 'March
            'Green and White
            REDIM Hues(1) AS Hue
            Hues(0).Brighter = 10: Hues(0).Dimmer = 2
            Hues(1).Brighter = 15: Hues(1).Dimmer = 7
        CASE 7 'July
            'Red, White, and Blue
            REDIM Hues(2) AS Hue
            Hues(0).Brighter = 12: Hues(0).Dimmer = 4
            Hues(1).Brighter = 15: Hues(1).Dimmer = 7
            Hues(2).Brighter = 9: Hues(2).Dimmer = 1
        CASE 12 'December
            'Red and Green
            REDIM Hues(1) AS Hue
            Hues(0).Brighter = 12: Hues(0).Dimmer = 4
            Hues(1).Brighter = 10: Hues(1).Dimmer = 2
        CASE ELSE
            'All colors 9-15
            REDIM Hues(6) AS Hue
            Hues(0).Brighter = 9: Hues(0).Dimmer = 1
            Hues(1).Brighter = 10: Hues(1).Dimmer = 2
            Hues(2).Brighter = 11: Hues(2).Dimmer = 3
            Hues(3).Brighter = 12: Hues(3).Dimmer = 4
            Hues(4).Brighter = 13: Hues(4).Dimmer = 5
            Hues(5).Brighter = 14: Hues(5).Dimmer = 6
            Hues(6).Brighter = 15: Hues(6).Dimmer = 7
    END SELECT
END SUB

SUB Remove_Particle (Particles() AS Particle, ID AS INTEGER)
    'Note: This would be a lot easier with PRESERVE, but I want to be QB1.1/4.5 compatible... one day.
    DIM intMember AS INTEGER
    'Create a place to save the data...
    DIM Temp(LBOUND(Particles) TO UBOUND(Particles) - 1) AS Particle
    'Save the data before the ID...
    FOR intMember = LBOUND(Particles) TO ID - 1
        Temp(intMember) = Particles(intMember)
    NEXT intMember
    'Save the data after the ID...
    FOR intMember = ID + 1 TO UBOUND(Particles)
        Temp(intMember - 1) = Particles(intMember)
    NEXT intMember
    'Re-create the array with one less row...
    REDIM Particles(LBOUND(Temp) TO UBOUND(Temp)) AS Particle
    'Re-load the saved data back into the original array...
    FOR intMember = LBOUND(Temp) TO UBOUND(Temp)
        Particles(intMember) = Temp(intMember)
    NEXT intMember
    SOUND INT(RND * 16) * 10 + 37, RND * 0.01
END SUB

SUB Append_Particle (Particles() AS Particle, New_Particle AS Particle)
    'Note: This would be a lot easier with PRESERVE, but I want to be QB1.1/4.5 compatible... one day.
    DIM intMember AS INTEGER
    'Create a place to save the data...
    DIM Temp(LBOUND(Particles) TO UBOUND(Particles)) AS Particle
    'Save the data...
    FOR intMember = LBOUND(Particles) TO UBOUND(Particles)
        Temp(intMember) = Particles(intMember)
    NEXT intMember
    'Re-create the array with one additional row...
    REDIM Particles(LBOUND(Temp) TO UBOUND(Temp) + 1) AS Particle
    'Re-load the saved data back into the original array...
    FOR intMember = LBOUND(Temp) TO UBOUND(Temp)
        Particles(intMember) = Temp(intMember)
    NEXT intMember
    'Put the new particle at the end...
    Particles(UBOUND(Particles)) = New_Particle
END SUB

SUB Particle_Burst (Current AS Particle, Past AS Particle)
    'Basically set the child particle (after the burst) to the properties of its parent.
    Current.X0 = Past.X0
    Current.Y0 = Past.Y0
    Current.X1 = Past.X0
    Current.Y1 = Past.Y0
    Current.X2 = Past.X0
    Current.Y2 = Past.Y0
    Current.Angle = RandomBetween%(0, 359)
    Current.Velocity = RandomBetween%(2, 4)
    Current.Stage = Past.Stage - 1
    Current.Hue = Past.Hue
    Current.Fuse = RandomBetween(10, 20)
END SUB

SUB Particle_Move (Current AS Particle)
    'Move the tail forward.
    Current.X2 = Current.X1
    Current.X1 = Current.X0
    Current.Y2 = Current.Y1
    Current.Y1 = Current.Y0
    'Move the particle along its current trajectory.
    IF Current.Fuse > 0 THEN
        Current.X0 = NewX!(Current.X0, Current.Angle, Current.Velocity)
        Current.Y0 = NewY!(Current.Y0, Current.Angle, Current.Velocity)
    END IF
    'Burn Fuse
    Current.Fuse = Current.Fuse - 1
END SUB

SUB Particle_Draw (Current AS Particle, Hues() AS Hue)
    'Draw oldest segment
    LINE (Current.X2, Current.Y2)-(Current.X1, Current.Y1), Hues(Current.Hue).Dimmer
    'If the fuse hasn't been burnt out for more than one turn...
    IF Current.Fuse > -1 THEN
        'Draw newest segment
        LINE (Current.X1, Current.Y1)-(Current.X0, Current.Y0), Hues(Current.Hue).Brighter
        'If the fuse isn't burnt out...
        IF Current.Fuse > 0 THEN
            'Draw flare
            PSET (Current.X0, Current.Y0), 15
        END IF
    ELSE
        SOUND INT(RND * 1000) + 37, RND * 0.01
    END IF
END SUB

FUNCTION NewX! (X AS SINGLE, Angle AS SINGLE, Distance AS SINGLE)
    NewX! = X + SIN(Angle * 3.141592 / 180) * Distance
END FUNCTION

FUNCTION NewY! (Y AS SINGLE, Angle AS SINGLE, Distance AS SINGLE)
    NewY = Y! + ((COS(Angle! * 3.141592 / 180) * Distance!) * -1)
END FUNCTION

FUNCTION RandomBetween% (Minimum AS INTEGER, Maximum AS INTEGER)
    RandomBetween% = CINT(Minimum + (RND * (Maximum - Minimum)))
END FUNCTION
