'#lang "qb"

SCREEN 0

ScreenWidth = 640
ScreenHeight = 480


' *** Performance settings. ***

bignumber = 500000 ' Maximum objects per array (determined by memory).
globaldelay = 1000000 ' Loop damping factor.
RANDOMIZE TIMER

' *** Initialize counters and array sizes. ***

numparticleorig = bignumber
numparticlevisible = bignumber

' *** Define basis arrays and structures. ***

' Screen vectors in three-space.
' These vectors define the camera angle.
DIM uhat(1 TO 3), vhat(1 TO 3), nhat(1 TO 3)

' View clipping planes defined in three-space.
DIM nearplane(1 TO 4), farplane(1 TO 4), rightplane(1 TO 4), leftplane(1 TO 4), topplane(1 TO 4), bottomplane(1 TO 4)

' Basis vectors defined in three-space.
DIM xhat(1 TO 4), yhat(1 TO 4), zhat(1 TO 4)
xhat(1) = 1: xhat(2) = 0: xhat(3) = 0: xhat(4) = 4
yhat(1) = 0: yhat(2) = 1: yhat(3) = 0: yhat(4) = 2
zhat(1) = 0: zhat(2) = 0: zhat(3) = 1: zhat(4) = 1

' Basis vectors projected into uv two-space.
DIM xhatp(1 TO 2), yhatp(1 TO 2), zhatp(1 TO 2)
DIM xhatp.old(1 TO 2), yhatp.old(1 TO 2), zhatp.old(1 TO 2)

' *** Define particle arrays and structures. ***

' Particle vectors defined in three-space.
DIM vec(numparticleorig, 4)
DIM vecdotnhat(numparticleorig)
DIM vecdotnhatunit.old(numparticleorig)
DIM vecvisible(numparticlevisible, 4)
DIM vecvisibledotnhat(numparticlevisible)
DIM vecvisibledotnhatunit.old(numparticlevisible)

' Particle vectors projected onto infinite uv two-space.
DIM vecpuv(numparticleorig, 1 TO 2)
DIM vecpuv.old(numparticleorig, 1 TO 2)
DIM vecvisiblepuv(numparticlevisible, 1 TO 2)
DIM vecvisiblepuv.old(numparticlevisible, 1 TO 2)

' Particle projections adjusted for screen uv two-space.
DIM vecpuvs(numparticleorig, 1 TO 2)
DIM vecpuvs.old(numparticleorig, 1 TO 2)
DIM vecvisiblepuvs(numparticlevisible, 1 TO 2)
DIM vecvisiblepuvs.old(numparticlevisible, 1 TO 2)

' *** Set mathematical constants. ***

pi = 3.1415926536
ee = 2.7182818285

' *** Initialize user input variables. ***
key$ = ""
'mousekey$ = ""
genscheme$ = "3denvparticles"
plotmode$ = "3denvparticles"

' *** Zero counters and array sizes. ***

numparticleorig = 0
numparticlevisible = 0
pcountparticleorig = 0

' *** Constants and switch control. ***

' Perspective and animation switches/defaults.
fovd = -256
nearplane(4) = 3
farplane(4) = -200
rightplane(4) = 0 '*' fovd * (nhat(1) * rightplane(1) + nhat(2) * rightplane(2) + nhat(3) * rightplane(3))
leftplane(4) = 0
topplane(4) = 0
bottomplane(4) = 0
centerx = ScreenWidth / 2
centery = ScreenHeight / 2
speedconst = 50
falsedepth = .01
zoom = 30
timevar = 0
T = 0
uhat(1) = 0.8251367: uhat(2) = -0.564903: uhat(3) = -0.005829525
vhat(1) = 0.065519: vhat(2) = 0.08544215: vhat(3) = 0.9941866
zoom = 1.95
toggletimeanimate = 1
togglehud = 1
toggletimealert = 1
camx = 30
camy = 25
camz = -25
GOSUB genscheme.3denvparticles.init
numparticleorig = pcountparticleorig

' Move objects to accomodate initial camera position.
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) + camx
    vec(i, 2) = vec(i, 2) + camy
    vec(i, 3) = vec(i, 3) + camz
NEXT

GOSUB redraw

' *** Begin main loop. ***
DO
    IF toggletimeanimate = 1 THEN
        GOSUB timeanimate
        flagredraw = 1
    END IF
    IF flagredraw = 1 THEN
        GOSUB redraw
        flagredraw = -1
    END IF
    GOSUB mouseprocess
    GOSUB keyprocess
    IF toggletimeanimate = 1 THEN
        FOR delaycount = 1 TO globaldelay: NEXT
    END IF
LOOP
' *** End main loop. ***

' *** Begin function definitions. ***

' Comment out the conents of this gosub for non-QB64 compiler.
mouseprocess:
'DO
'    IF _MOUSEMOVEMENTX > 0 THEN
'        mousekey$ = "6"
'        GOSUB rotate.uhat.plus: GOSUB normalize.screen.vectors: flagredraw = 1
'    END IF
'    IF _MOUSEMOVEMENTX < 0 THEN
'        mousekey$ = "4"
'        GOSUB rotate.uhat.minus: GOSUB normalize.screen.vectors: flagredraw = 1
'    END IF
'    IF _MOUSEMOVEMENTY > 0 THEN
'        mousekey$ = "8"
'        GOSUB rotate.vhat.plus: GOSUB normalize.screen.vectors: flagredraw = 1
'    END IF
'    IF _MOUSEMOVEMENTY < 0 THEN
'        mousekey$ = "2"
'        GOSUB rotate.vhat.minus: GOSUB normalize.screen.vectors: flagredraw = 1
'    END IF
'    MouseLB = _MOUSEBUTTON(1)
'    MouseRB = _MOUSEBUTTON(2)
'LOOP WHILE _MOUSEINPUT
RETURN

keyprocess:
'IF mousekey$ <> "" THEN
'    key$ = mousekey$
'    mousekey$ = ""
'ELSE
key$ = INKEY$
'END IF
IF key$ <> "" THEN
    flagredraw = 1
END IF
SELECT CASE LCASE$(key$)
    CASE "8":
        GOSUB rotate.vhat.plus
    CASE "2":
        GOSUB rotate.vhat.minus
    CASE "4":
        GOSUB rotate.uhat.minus
    CASE "6":
        GOSUB rotate.uhat.plus
    CASE "7":
        GOSUB rotate.clockwise
    CASE "9":
        GOSUB rotate.counterclockwise
    CASE "1":
        GOSUB rotate.uhat.minus: GOSUB normalize.screen.vectors: GOSUB rotate.clockwise
    CASE "3":
        GOSUB rotate.uhat.plus: GOSUB normalize.screen.vectors: GOSUB rotate.counterclockwise
    CASE "w"
        GOSUB strafe.objects.nhat.plus
        GOSUB strafe.camera.nhat.plus
    CASE "s"
        GOSUB strafe.objects.nhat.minus
        GOSUB strafe.camera.nhat.minus
    CASE "a"
        GOSUB strafe.objects.uhat.plus
        GOSUB strafe.camera.uhat.plus
    CASE "d"
        GOSUB strafe.objects.uhat.minus
        GOSUB strafe.camera.uhat.minus
    CASE "q"
        GOSUB strafe.objects.vhat.plus
        GOSUB strafe.camera.vhat.plus
    CASE "e"
        GOSUB strafe.objects.vhat.minus
        GOSUB strafe.camera.vhat.minus
    CASE "x"
        uhat(1) = 0: uhat(2) = 1: uhat(3) = 0
        vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
    CASE "y"
        uhat(1) = 0: uhat(2) = 0: uhat(3) = 1
        vhat(1) = 1: vhat(2) = 0: vhat(3) = 0
    CASE "z"
        uhat(1) = 1: uhat(2) = 0: uhat(3) = 0
        vhat(1) = 0: vhat(2) = 1: vhat(3) = 0
    CASE ","
        nearplane(4) = nearplane(4) - 1
        IF nearplane(4) < 0 THEN nearplane(4) = 0
    CASE "."
        nearplane(4) = nearplane(4) + 1
    CASE "]"
        farplane(4) = farplane(4) - 1
    CASE "["
        farplane(4) = farplane(4) + 1
    CASE " "
        togglehud = -togglehud
        CLS
    CASE "t"
        toggletimeanimate = -toggletimeanimate
    CASE CHR$(27)
        END
END SELECT
RETURN

convert:
' Convert graphics from uv-cartesian coordinates to monitor coordinates.
x0 = x: y0 = y
x = x0 + centerx
y = -y0 + centery
RETURN

' *** Define functions for view translation and rotation. ***

rotate.uhat.plus:
uhat(1) = nhat(1) + speedconst * uhat(1)
uhat(2) = nhat(2) + speedconst * uhat(2)
uhat(3) = nhat(3) + speedconst * uhat(3)
RETURN

rotate.uhat.minus:
uhat(1) = -nhat(1) + speedconst * uhat(1)
uhat(2) = -nhat(2) + speedconst * uhat(2)
uhat(3) = -nhat(3) + speedconst * uhat(3)
RETURN

rotate.vhat.plus:
vhat(1) = nhat(1) + speedconst * vhat(1)
vhat(2) = nhat(2) + speedconst * vhat(2)
vhat(3) = nhat(3) + speedconst * vhat(3)
RETURN

rotate.vhat.minus:
vhat(1) = -nhat(1) + speedconst * vhat(1)
vhat(2) = -nhat(2) + speedconst * vhat(2)
vhat(3) = -nhat(3) + speedconst * vhat(3)
RETURN

rotate.counterclockwise:
v1 = vhat(1)
v2 = vhat(2)
v3 = vhat(3)
vhat(1) = uhat(1) + speedconst * vhat(1)
vhat(2) = uhat(2) + speedconst * vhat(2)
vhat(3) = uhat(3) + speedconst * vhat(3)
uhat(1) = -v1 + speedconst * uhat(1)
uhat(2) = -v2 + speedconst * uhat(2)
uhat(3) = -v3 + speedconst * uhat(3)
RETURN

rotate.clockwise:
v1 = vhat(1)
v2 = vhat(2)
v3 = vhat(3)
vhat(1) = -uhat(1) + speedconst * vhat(1)
vhat(2) = -uhat(2) + speedconst * vhat(2)
vhat(3) = -uhat(3) + speedconst * vhat(3)
uhat(1) = v1 + speedconst * uhat(1)
uhat(2) = v2 + speedconst * uhat(2)
uhat(3) = v3 + speedconst * uhat(3)
RETURN
RETURN

strafe.objects.uhat.plus:
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) + uhat(1) * 1 / zoom
    vec(i, 2) = vec(i, 2) + uhat(2) * 1 / zoom
    vec(i, 3) = vec(i, 3) + uhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.uhat.minus:
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) - uhat(1) * 1 / zoom
    vec(i, 2) = vec(i, 2) - uhat(2) * 1 / zoom
    vec(i, 3) = vec(i, 3) - uhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.vhat.plus:
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) + vhat(1) * 1 / zoom
    vec(i, 2) = vec(i, 2) + vhat(2) * 1 / zoom
    vec(i, 3) = vec(i, 3) + vhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.vhat.minus:
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) - vhat(1) * 1 / zoom
    vec(i, 2) = vec(i, 2) - vhat(2) * 1 / zoom
    vec(i, 3) = vec(i, 3) - vhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.nhat.plus:
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) + nhat(1) * 1 / zoom
    vec(i, 2) = vec(i, 2) + nhat(2) * 1 / zoom
    vec(i, 3) = vec(i, 3) + nhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.nhat.minus:
FOR i = 1 TO numparticleorig
    vec(i, 1) = vec(i, 1) - nhat(1) * 1 / zoom
    vec(i, 2) = vec(i, 2) - nhat(2) * 1 / zoom
    vec(i, 3) = vec(i, 3) - nhat(3) * 1 / zoom
NEXT
RETURN

strafe.camera.uhat.plus:
camx = camx + uhat(1) * 1 / zoom
camy = camy + uhat(2) * 1 / zoom
camz = camz + uhat(3) * 1 / zoom
RETURN

strafe.camera.uhat.minus:
camx = camx - uhat(1) * 1 / zoom
camy = camy - uhat(2) * 1 / zoom
camz = camz - uhat(3) * 1 / zoom
RETURN

strafe.camera.vhat.plus:
camx = camx + vhat(1) * 1 / zoom
camy = camy + vhat(2) * 1 / zoom
camz = camz + vhat(3) * 1 / zoom
RETURN

strafe.camera.vhat.minus:
camx = camx - vhat(1) * 1 / zoom
camy = camy - vhat(2) * 1 / zoom
camz = camz - vhat(3) * 1 / zoom
RETURN

strafe.camera.nhat.plus:
camx = camx + nhat(1) * 1 / zoom
camy = camy + nhat(2) * 1 / zoom
camz = camz + nhat(3) * 1 / zoom
RETURN

strafe.camera.nhat.minus:
camx = camx - nhat(1) * 1 / zoom
camy = camy - nhat(2) * 1 / zoom
camz = camz - nhat(3) * 1 / zoom
RETURN

' *** Define core functions. ***

timeanimate:
timevar = timevar + 1
IF timevar > 10 ^ 6 THEN timevar = 1
GOSUB genscheme.3denvparticles.timeanimate
RETURN

normalize.screen.vectors:
'normalize the two vectors that define the screen orientation
uhatmag = SQR(uhat(1) ^ 2 + uhat(2) ^ 2 + uhat(3) ^ 2)
uhat(1) = uhat(1) / uhatmag: uhat(2) = uhat(2) / uhatmag: uhat(3) = uhat(3) / uhatmag
vhatmag = SQR(vhat(1) ^ 2 + vhat(2) ^ 2 + vhat(3) ^ 2)
vhat(1) = vhat(1) / vhatmag: vhat(2) = vhat(2) / vhatmag: vhat(3) = vhat(3) / vhatmag
uhatdotvhat = uhat(1) * vhat(1) + uhat(2) * vhat(2) + uhat(3) * vhat(3)
IF SQR(uhatdotvhat ^ 2) > .0005 THEN
    CLS: COLOR 15: LOCATE 5, 5: PRINT "Screen vectors are not perpendicular. Press ESC to quit."
    'DO: LOOP UNTIL INKEY$ = CHR$(27): END
END IF
' Compute the normal vector to the view plane.
' The normal vector points toward the eye, away from view frustum.
nhat(1) = uhat(2) * vhat(3) - uhat(3) * vhat(2)
nhat(2) = uhat(3) * vhat(1) - uhat(1) * vhat(3)
nhat(3) = uhat(1) * vhat(2) - uhat(2) * vhat(1)
nhatmag = SQR(nhat(1) ^ 2 + nhat(2) ^ 2 + nhat(3) ^ 2)
nhat(1) = nhat(1) / nhatmag: nhat(2) = nhat(2) / nhatmag: nhat(3) = nhat(3) / nhatmag
RETURN

redraw:
GOSUB normalize.screen.vectors
GOSUB compute.viewplanes
' Project the three-space basis vectors onto the screen plane.
xhatp(1) = xhat(1) * uhat(1) + xhat(2) * uhat(2) + xhat(3) * uhat(3)
xhatp(2) = xhat(1) * vhat(1) + xhat(2) * vhat(2) + xhat(3) * vhat(3)
yhatp(1) = yhat(1) * uhat(1) + yhat(2) * uhat(2) + yhat(3) * uhat(3)
yhatp(2) = yhat(1) * vhat(1) + yhat(2) * vhat(2) + yhat(3) * vhat(3)
zhatp(1) = zhat(1) * uhat(1) + zhat(2) * uhat(2) + zhat(3) * uhat(3)
zhatp(2) = zhat(1) * vhat(1) + zhat(2) * vhat(2) + zhat(3) * vhat(3)
IF numparticleorig > 0 THEN
    GOSUB compute.visible.particles
    GOSUB project.particles
    GOSUB depth.adjust.particles
END IF
GOSUB draw.all.objects
GOSUB store.screen.projections
RETURN

compute.visible.particles:
numparticlevisible = 0
FOR i = 1 TO numparticleorig
    GOSUB clip.particle.viewplanes
NEXT
RETURN

clip.particle.viewplanes:
particleinview = 1
fogswitch = -1
' Perform standard view plane clipping and determine depth 'fog effect'.
givenplanex = nearplane(1)
givenplaney = nearplane(2)
givenplanez = nearplane(3)
givenplaned = nearplane(4)
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned < 0 THEN particleinview = 0
givenplanex = farplane(1)
givenplaney = farplane(2)
givenplanez = farplane(3)
givenplaned = farplane(4)
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned < 0 THEN particleinview = 0
'IF togglehud = -1 THEN
'*
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned * .9 < 0 THEN fogswitch = 1
'*
givenplanex = rightplane(1)
givenplaney = rightplane(2)
givenplanez = rightplane(3)
givenplaned = rightplane(4)
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned < 0 THEN particleinview = 0
givenplanex = leftplane(1)
givenplaney = leftplane(2)
givenplanez = leftplane(3)
givenplaned = leftplane(4)
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned < 0 THEN particleinview = 0
givenplanex = topplane(1)
givenplaney = topplane(2)
givenplanez = topplane(3)
givenplaned = topplane(4)
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned < 0 THEN particleinview = 0
givenplanex = bottomplane(1)
givenplaney = bottomplane(2)
givenplanez = bottomplane(3)
givenplaned = bottomplane(4)
IF vec(i, 1) * givenplanex + vec(i, 2) * givenplaney + vec(i, 3) * givenplanez - givenplaned < 0 THEN particleinview = 0
IF particleinview = 1 THEN
    numparticlevisible = numparticlevisible + 1
    vecvisible(numparticlevisible, 1) = vec(i, 1)
    vecvisible(numparticlevisible, 2) = vec(i, 2)
    vecvisible(numparticlevisible, 3) = vec(i, 3)
    vecvisible(numparticlevisible, 4) = vec(i, 4)
    IF fogswitch = 1 THEN vecvisible(numparticlevisible, 4) = 8
END IF
RETURN

project.particles:
' Project object vectors onto the screen plane.
FOR i = 1 TO numparticlevisible
    vecvisibledotnhat(i) = vecvisible(i, 1) * nhat(1) + vecvisible(i, 2) * nhat(2) + vecvisible(i, 3) * nhat(3)
    vecvisiblepuv(i, 1) = (vecvisible(i, 1) * uhat(1) + vecvisible(i, 2) * uhat(2) + vecvisible(i, 3) * uhat(3))
    vecvisiblepuv(i, 2) = (vecvisible(i, 1) * vhat(1) + vecvisible(i, 2) * vhat(2) + vecvisible(i, 3) * vhat(3))
NEXT
RETURN

depth.adjust.particles:
FOR i = 1 TO numparticlevisible
    vecvisiblepuvs(i, 1) = vecvisiblepuv(i, 1) * fovd / vecvisibledotnhat(i)
    vecvisiblepuvs(i, 2) = vecvisiblepuv(i, 2) * fovd / vecvisibledotnhat(i)
NEXT
RETURN

draw.all.objects:
GOSUB plotmode.3denvparticles
COLOR 7
'LOCATE 28, 23: PRINT "SPACE = toggle HUD,  ESC = quit."
IF togglehud = 1 THEN
    ' Replace basis vector triad.
    x = 50 * xhatp.old(1): y = 50 * xhatp.old(2): GOSUB convert
    'LINE (centerx, centery)-(x, y), 0
    x = 50 * yhatp.old(1): y = 50 * yhatp.old(2): GOSUB convert
    'LINE (centerx, centery)-(x, y), 0
    x = 50 * zhatp.old(1): y = 50 * zhatp.old(2): GOSUB convert
    'LINE (centerx, centery)-(x, y), 0
    x = 50 * xhatp(1): y = 50 * xhatp(2): GOSUB convert
    'LINE (centerx, centery)-(x, y), xhat(4)
    x = 50 * yhatp(1): y = 50 * yhatp(2): GOSUB convert
    'LINE (centerx, centery)-(x, y), yhat(4)
    x = 50 * zhatp(1): y = 50 * zhatp(2): GOSUB convert
    'LINE (centerx, centery)-(x, y), zhat(4)
    COLOR 14
    LOCATE 46, 2: PRINT "- MOVE -"
    COLOR 15
    LOCATE 47, 2: PRINT " q W e"
    LOCATE 48, 2: PRINT " A S D"
    COLOR 14
    LOCATE 45, 68: PRINT "-   VIEW   -"
    COLOR 15
    LOCATE 46, 68: PRINT "  8  "
    LOCATE 47, 68: PRINT "4   6"
    LOCATE 48, 68: PRINT "  2  "
    COLOR 7
    LOCATE 46, 75: PRINT "7   9"
    LOCATE 47, 75: PRINT "     "
    LOCATE 48, 75: PRINT "1   3"
    COLOR 7
    'LOCATE 3, 2: PRINT "- Particle Info -"
    'LOCATE 4, 2: PRINT "   Total:"; numparticleorig
    'LOCATE 5, 2: PRINT " Visible:"; numparticlevisible
    'LOCATE 6, 2: PRINT " Percent:"; INT(100 * numparticlevisible / numparticleorig)
    'LOCATE 3, 65: PRINT "- View Planes -"
    'LOCATE 4, 65: PRINT " Far dist:"; -farplane(4)
    'LOCATE 5, 65: PRINT " Near dist:"; nearplane(4)
    'LOCATE 6, 65: PRINT " [,] shift Far"
    'LOCATE 7, 65: PRINT " <,> shift Near"
END IF
IF toggletimealert = 1 THEN
    COLOR 7
    'LOCATE 1, 25: PRINT "Press 'T' to toggle animation."
END IF
RETURN

store.screen.projections:
xhatp.old(1) = xhatp(1): xhatp.old(2) = xhatp(2)
yhatp.old(1) = yhatp(1): yhatp.old(2) = yhatp(2)
zhatp.old(1) = zhatp(1): zhatp.old(2) = zhatp(2)
FOR i = 1 TO numparticlevisible
    vecvisiblepuvs.old(i, 1) = vecvisiblepuvs(i, 1)
    vecvisiblepuvs.old(i, 2) = vecvisiblepuvs(i, 2)
NEXT
RETURN

compute.viewplanes:
' Define normal vectors to all view planes.
nearplane(1) = -nhat(1)
nearplane(2) = -nhat(2)
nearplane(3) = -nhat(3)
farplane(1) = nhat(1)
farplane(2) = nhat(2)
farplane(3) = nhat(3)
rightplane(1) = (ScreenHeight / 4) * fovd * uhat(1) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(1)
rightplane(2) = (ScreenHeight / 4) * fovd * uhat(2) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(2)
rightplane(3) = (ScreenHeight / 4) * fovd * uhat(3) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(3)
mag = SQR((rightplane(1)) ^ 2 + (rightplane(2)) ^ 2 + (rightplane(3)) ^ 2)
rightplane(1) = rightplane(1) / mag
rightplane(2) = rightplane(2) / mag
rightplane(3) = rightplane(3) / mag
leftplane(1) = -(ScreenHeight / 4) * fovd * uhat(1) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(1)
leftplane(2) = -(ScreenHeight / 4) * fovd * uhat(2) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(2)
leftplane(3) = -(ScreenHeight / 4) * fovd * uhat(3) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(3)
mag = SQR((leftplane(1)) ^ 2 + (leftplane(2)) ^ 2 + (leftplane(3)) ^ 2)
leftplane(1) = leftplane(1) / mag
leftplane(2) = leftplane(2) / mag
leftplane(3) = leftplane(3) / mag
topplane(1) = (ScreenWidth / 4) * fovd * vhat(1) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(1)
topplane(2) = (ScreenWidth / 4) * fovd * vhat(2) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(2)
topplane(3) = (ScreenWidth / 4) * fovd * vhat(3) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(3)
mag = SQR((topplane(1)) ^ 2 + (topplane(2)) ^ 2 + (topplane(3)) ^ 2)
topplane(1) = topplane(1) / mag
topplane(2) = topplane(2) / mag
topplane(3) = topplane(3) / mag
bottomplane(1) = -(ScreenWidth / 4) * fovd * vhat(1) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(1)
bottomplane(2) = -(ScreenWidth / 4) * fovd * vhat(2) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(2)
bottomplane(3) = -(ScreenWidth / 4) * fovd * vhat(3) - (ScreenHeight / 4) * (ScreenWidth / 4) * nhat(3)
mag = SQR((bottomplane(1)) ^ 2 + (bottomplane(2)) ^ 2 + (bottomplane(3)) ^ 2)
bottomplane(1) = bottomplane(1) / mag
bottomplane(2) = bottomplane(2) / mag
bottomplane(3) = bottomplane(3) / mag
RETURN

plotmode.3denvparticles:
CLS
FOR i = 1 TO numparticlevisible
    x = zoom * vecvisiblepuvs(i, 1): y = zoom * vecvisiblepuvs(i, 2): GOSUB convert
    'PSET (x, y), vecvisible(i, 4)
    COLOR vecvisible(i, 4)

    '_PRINTSTRING (x, y), "*"

    xtext = (x0 + ScreenWidth / 2) * (80 / ScreenWidth)
    ytext = (ScreenHeight / 2 - y0) * (48 / ScreenHeight) + 1
    IF xtext < 1 THEN xtext = 1
    IF xtext > 80 THEN xtext = 80
    IF ytext < 1 THEN ytext = 1
    IF ytext > 48 THEN ytext = 48
    LOCATE ytext, xtext: PRINT "*"

NEXT
RETURN

genscheme.3denvparticles.init:
pcountparticleorig = 0
'particle grass
FOR i = -50 TO 50 STEP 1
    FOR j = -50 TO 50 STEP 1
        k = 0
        pcountparticleorig = pcountparticleorig + 1
        vec(pcountparticleorig, 1) = i + RND - RND
        vec(pcountparticleorig, 2) = j + RND - RND
        vec(pcountparticleorig, 3) = k - COS((i - 15) * .08) + COS((j - 6) * .12)
        IF COS((i - 15) * .08) + COS((j - 6) * .12) < .5 THEN
            vec(pcountparticleorig, 4) = 2
        ELSE
            IF RND > .2 THEN
                vec(pcountparticleorig, 4) = 9
            ELSE
                vec(pcountparticleorig, 4) = 1
            END IF
        END IF
    NEXT
NEXT
'particle sky
FOR i = -50 TO 50 STEP 1
    FOR j = -50 TO 50 STEP 1
        k = -50
        pcountparticleorig = pcountparticleorig + 1
        vec(pcountparticleorig, 1) = i + RND
        vec(pcountparticleorig, 2) = j + RND
        vec(pcountparticleorig, 3) = -k - RND
        IF RND > .5 THEN
            vec(pcountparticleorig, 4) = 9
        ELSE
            vec(pcountparticleorig, 4) = 15
        END IF
    NEXT
NEXT
'particle wave art 1
FOR i = 1 TO 5 STEP .05
    FOR k = 1 TO 5 STEP .05
        pcountparticleorig = pcountparticleorig + 1
        vec(pcountparticleorig, 1) = -7 * i
        vec(pcountparticleorig, 2) = 50 + 1 * COS(2 * ((i - 7) ^ 2 - (k - 5) ^ 2))
        vec(pcountparticleorig, 3) = 10 + 7 * k
        IF vec(pcountparticleorig, 2) < 50 THEN
            vec(pcountparticleorig, 4) = 13
        ELSE
            vec(pcountparticleorig, 4) = 4
        END IF
    NEXT
NEXT
'particle wave art 2
FOR i = 1 TO 5 STEP .05
    FOR k = 1 TO 5 STEP .05
        pcountparticleorig = pcountparticleorig + 1
        vec(pcountparticleorig, 1) = 7 * i
        vec(pcountparticleorig, 2) = 50 + 1 * COS((i ^ 2 - k ^ 2))
        vec(pcountparticleorig, 3) = 10 + 7 * k
        IF vec(pcountparticleorig, 2) < 50 THEN
            vec(pcountparticleorig, 4) = 2
        ELSE
            vec(pcountparticleorig, 4) = 1
        END IF
    NEXT
NEXT
'air ball
'FOR j = 1 TO 5
'    p1 = RND * 5
'    p2 = RND * 5
'    p3 = RND * 5
'    FOR i = -pi TO pi STEP .05 '.0005 for Menon demo
'        pcountparticleorig = pcountparticleorig + 1
'        vec(pcountparticleorig, 1) = 30 + 5 * COS(i) * SIN(p1 * i) + SIN(p3 * i)
'        vec(pcountparticleorig, 2) = 20 + 5 * SIN(i) * COS(p2 * i) + COS(p2 * i)
'        vec(pcountparticleorig, 3) = 20 - 5 * COS(i) * SIN(p3 * i) + SIN(p1 * i)
'        vec(pcountparticleorig, 4) = 6
'    NEXT
'NEXT
animpcountparticleflag = pcountparticleorig
'particle snake
FOR i = -pi TO pi STEP .005
    pcountparticleorig = pcountparticleorig + 1
    vec(pcountparticleorig, 1) = -10 + 5 * COS(i)
    vec(pcountparticleorig, 2) = -20 + 5 * SIN(i)
    vec(pcountparticleorig, 3) = 25 - 3 * COS(6 * i) * SIN(3 * i)
    vec(pcountparticleorig, 4) = 12
NEXT
'rain drops
FOR i = -50 TO 50 STEP 5
    FOR j = -50 TO 50 STEP 5
        k = 50
        pcountparticleorig = pcountparticleorig + 1
        vec(pcountparticleorig, 1) = i + RND
        vec(pcountparticleorig, 2) = j + RND
        vec(pcountparticleorig, 3) = k * RND
        IF RND > .66 THEN
            vec(pcountparticleorig, 4) = 9
        ELSE
            vec(pcountparticleorig, 4) = 7
        END IF
    NEXT
NEXT
RETURN

genscheme.3denvparticles.timeanimate:
T = timevar / 50
pcountparticleorig = animpcountparticleflag
'particle snake
FOR i = -pi TO pi STEP .005
    pcountparticleorig = pcountparticleorig + 1
    vec(pcountparticleorig, 1) = camx - 10 + 5 * COS(i + T)
    vec(pcountparticleorig, 2) = camy - 20 + 5 * SIN(i + T)
    vec(pcountparticleorig, 3) = camz + 25 - 3 * COS(6 * i + T) * SIN(3 * i + T)
    vec(pcountparticleorig, 4) = 12
NEXT
'rain drops
FOR i = -50 TO 50 STEP 5
    FOR j = -50 TO 50 STEP 5
        pcountparticleorig = pcountparticleorig + 1
        vec(pcountparticleorig, 1) = vec(pcountparticleorig, 1)
        vec(pcountparticleorig, 2) = vec(pcountparticleorig, 2)
        vec(pcountparticleorig, 3) = vec(pcountparticleorig, 3) - .3
        IF vec(pcountparticleorig, 3) < camz THEN vec(pcountparticleorig, 3) = vec(pcountparticleorig, 3) + 50
    NEXT
NEXT
RETURN



