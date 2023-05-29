' *** Video  and performance settings. ***
RANDOMIZE TIMER
bignumber = 500000
screenwidth = 640
screenheight = 480

SCREEN _NEWIMAGE(screenwidth, screenheight, 32)
InputImageWidth = 158
InputImageHeight = 127
TextureImage& = _LOADIMAGE("qb64bee.png") '<<<< Image from top of QB64 Forum

CLS

' *** Initialize counters and array sizes. ***
numquadletorig = bignumber
numquadletfaceon = bignumber
numquadletclip = bignumber
numquadletclipwork = bignumber
numquadletdepthsort = bignumber
numquadletencpoint = bignumber
numquadletintpointpair = bignumber
numquadletfinal = bignumber

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

' *** Define quadlet arrays and structures. ***
' *** A quadlet is a collection of three points plus a color. ***

' quadlet vectors defined in three-space.
DIM quadletorig(numquadletorig, 13)

' quadlet vectors after discarding outfacing members.
DIM quadletfaceon(numquadletfaceon, 13)

' quadlet vectors clipped by view planes.
DIM quadletclip(numquadletclip, 13)
DIM quadletclipwork(numquadletclipwork, 13)

' quadlet vectors sorted by painter's algorithm.
DIM quadletdepthsort(numquadletdepthsort, 13)

' Final quadlet vectors.
DIM quadletfinal(numquadletfinal, 13)
DIM quadletfinaldotnhat(numquadletfinal, 4)
DIM quadletfinaldotnhat.old(numquadletfinal, 4)

' Final quadlet vectors projected onto infinite uv two-space.
DIM quadletfinalpuv(numquadletfinal, 9)
DIM quadletfinalpuv.old(numquadletfinal, 9)

' quadlet projections adjusted for screen uv two-space.
DIM quadletfinalpuvs(numquadletfinal, 8)
DIM quadletfinalpuvs.old(numquadletfinal, 8)

' *** Set mathematical constants. ***

pi = 3.1415926536
ee = 2.7182818285

mainstart:

' *** Initialize user input variables. ***

key$ = ""
mousekey$ = ""

substart:

' *** Zero counters and array sizes. ***

numquadletorig = 0
numquadletfaceon = 0
numquadletclip = 0
numquadletclipwork = 0
numquadletfinal = 0
pcountquadletorig = 0

' *** Constants and switch control. ***

' Perspective and animation switches/defaults.
fovd = -256
nearplane(4) = 3
farplane(4) = -100
rightplane(4) = 0
leftplane(4) = 0
topplane(4) = 0
bottomplane(4) = 0
centerx = screenwidth / 2
centery = screenheight / 2
speedconst = 50
falsedepth = 0
zoom = 30
togglehud = 1
toggleculling = 1
toggletimeanimate = -1
uhat(1) = 0.5153403: uhat(2) = -0.8556501: uhat(3) = -0.0478264
vhat(1) = 0.5077848: vhat(2) = 0.2599198: vhat(3) = 0.8213382
zoom = 1.95
camx = 22.01997
camy = 16.0585
camz = -4.492386
GOSUB genscheme.3denvquadlets
numquadletorig = pcountquadletorig

' Move objects to accomodate initial camera position.
IF camx <> 0 AND camy <> 0 AND camz <> 0 THEN
    FOR i = 1 TO numquadletorig
        quadletorig(i, 1) = quadletorig(i, 1) + camx
        quadletorig(i, 2) = quadletorig(i, 2) + camy
        quadletorig(i, 3) = quadletorig(i, 3) + camz
        quadletorig(i, 4) = quadletorig(i, 4) + camx
        quadletorig(i, 5) = quadletorig(i, 5) + camy
        quadletorig(i, 6) = quadletorig(i, 6) + camz
        quadletorig(i, 7) = quadletorig(i, 7) + camx
        quadletorig(i, 8) = quadletorig(i, 8) + camy
        quadletorig(i, 9) = quadletorig(i, 9) + camz
        quadletorig(i, 10) = quadletorig(i, 10) + camx
        quadletorig(i, 11) = quadletorig(i, 11) + camy
        quadletorig(i, 12) = quadletorig(i, 12) + camz
    NEXT
END IF

CLS
GOSUB redraw

COLOR 14
LOCATE 15, 15: PRINT "WELCOME"

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
    'GOSUB mouseprocess
    GOSUB keyprocess
    IF toggletimeanimate = 1 THEN
        FOR delaycount = 1 TO globaldelay: NEXT
    END IF
LOOP
' *** End main loop. ***

' *** Main graphics sequence. ***
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
GOSUB quadlet.filter.faceon
GOSUB copy.quadlets.faceon.clip
GOSUB clip.quadlets.viewplanes
GOSUB copy.quadlets.clip.depthsort
GOSUB quadlets.depthsort.routine
GOSUB copy.quadlets.depthsort.final
GOSUB project.quadlets
GOSUB depth.adjust.quadlets
GOSUB draw.all.objects
GOSUB store.screen.projections
RETURN

' *** Begin function definitions. ***

' Comment out the conents of this gosub for non-QB64 compiler.
'mouseprocess:
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
'RETURN

' *** Keyboard input. ***
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
    CASE "t"
        toggletimeanimate = -toggletimeanimate
    CASE "f"
        GOTO substart
    CASE "g"
        GOTO mainstart
    CASE "`"
        globaldelayinit = globaldelay
    CASE " "
        togglehud = -togglehud
        CLS
    CASE "c"
        toggleculling = -toggleculling
        CLS
    CASE "/"
        OPEN "uvn.txt" FOR OUTPUT AS #1
        PRINT #1, uhat(1); uhat(2); uhat(3)
        PRINT #1, vhat(1); vhat(2); vhat(3)
        PRINT #1, nhat(1); nhat(2); nhat(3)
        PRINT #1, camx, camy, camz
        CLOSE #1
    CASE CHR$(27)
        END
END SELECT
RETURN

' *** Convert graphics from uv-cartesian coordinates to monitor coordinates. ***
convert:
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
FOR i = 1 TO numquadletorig
    quadletorig(i, 1) = quadletorig(i, 1) + uhat(1) * 1 / zoom
    quadletorig(i, 2) = quadletorig(i, 2) + uhat(2) * 1 / zoom
    quadletorig(i, 3) = quadletorig(i, 3) + uhat(3) * 1 / zoom
    quadletorig(i, 4) = quadletorig(i, 4) + uhat(1) * 1 / zoom
    quadletorig(i, 5) = quadletorig(i, 5) + uhat(2) * 1 / zoom
    quadletorig(i, 6) = quadletorig(i, 6) + uhat(3) * 1 / zoom
    quadletorig(i, 7) = quadletorig(i, 7) + uhat(1) * 1 / zoom
    quadletorig(i, 8) = quadletorig(i, 8) + uhat(2) * 1 / zoom
    quadletorig(i, 9) = quadletorig(i, 9) + uhat(3) * 1 / zoom
    quadletorig(i, 10) = quadletorig(i, 10) + uhat(1) * 1 / zoom
    quadletorig(i, 11) = quadletorig(i, 11) + uhat(2) * 1 / zoom
    quadletorig(i, 12) = quadletorig(i, 12) + uhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.uhat.minus:
FOR i = 1 TO numquadletorig
    quadletorig(i, 1) = quadletorig(i, 1) - uhat(1) * 1 / zoom
    quadletorig(i, 2) = quadletorig(i, 2) - uhat(2) * 1 / zoom
    quadletorig(i, 3) = quadletorig(i, 3) - uhat(3) * 1 / zoom
    quadletorig(i, 4) = quadletorig(i, 4) - uhat(1) * 1 / zoom
    quadletorig(i, 5) = quadletorig(i, 5) - uhat(2) * 1 / zoom
    quadletorig(i, 6) = quadletorig(i, 6) - uhat(3) * 1 / zoom
    quadletorig(i, 7) = quadletorig(i, 7) - uhat(1) * 1 / zoom
    quadletorig(i, 8) = quadletorig(i, 8) - uhat(2) * 1 / zoom
    quadletorig(i, 9) = quadletorig(i, 9) - uhat(3) * 1 / zoom
    quadletorig(i, 10) = quadletorig(i, 10) - uhat(1) * 1 / zoom
    quadletorig(i, 11) = quadletorig(i, 11) - uhat(2) * 1 / zoom
    quadletorig(i, 12) = quadletorig(i, 12) - uhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.vhat.plus:
FOR i = 1 TO numquadletorig
    quadletorig(i, 1) = quadletorig(i, 1) + vhat(1) * 1 / zoom
    quadletorig(i, 2) = quadletorig(i, 2) + vhat(2) * 1 / zoom
    quadletorig(i, 3) = quadletorig(i, 3) + vhat(3) * 1 / zoom
    quadletorig(i, 4) = quadletorig(i, 4) + vhat(1) * 1 / zoom
    quadletorig(i, 5) = quadletorig(i, 5) + vhat(2) * 1 / zoom
    quadletorig(i, 6) = quadletorig(i, 6) + vhat(3) * 1 / zoom
    quadletorig(i, 7) = quadletorig(i, 7) + vhat(1) * 1 / zoom
    quadletorig(i, 8) = quadletorig(i, 8) + vhat(2) * 1 / zoom
    quadletorig(i, 9) = quadletorig(i, 9) + vhat(3) * 1 / zoom
    quadletorig(i, 10) = quadletorig(i, 10) + vhat(1) * 1 / zoom
    quadletorig(i, 11) = quadletorig(i, 11) + vhat(2) * 1 / zoom
    quadletorig(i, 12) = quadletorig(i, 12) + vhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.vhat.minus:
FOR i = 1 TO numquadletorig
    quadletorig(i, 1) = quadletorig(i, 1) - vhat(1) * 1 / zoom
    quadletorig(i, 2) = quadletorig(i, 2) - vhat(2) * 1 / zoom
    quadletorig(i, 3) = quadletorig(i, 3) - vhat(3) * 1 / zoom
    quadletorig(i, 4) = quadletorig(i, 4) - vhat(1) * 1 / zoom
    quadletorig(i, 5) = quadletorig(i, 5) - vhat(2) * 1 / zoom
    quadletorig(i, 6) = quadletorig(i, 6) - vhat(3) * 1 / zoom
    quadletorig(i, 7) = quadletorig(i, 7) - vhat(1) * 1 / zoom
    quadletorig(i, 8) = quadletorig(i, 8) - vhat(2) * 1 / zoom
    quadletorig(i, 9) = quadletorig(i, 9) - vhat(3) * 1 / zoom
    quadletorig(i, 10) = quadletorig(i, 10) - vhat(1) * 1 / zoom
    quadletorig(i, 11) = quadletorig(i, 11) - vhat(2) * 1 / zoom
    quadletorig(i, 12) = quadletorig(i, 12) - vhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.nhat.plus:
FOR i = 1 TO numquadletorig
    quadletorig(i, 1) = quadletorig(i, 1) + nhat(1) * 1 / zoom
    quadletorig(i, 2) = quadletorig(i, 2) + nhat(2) * 1 / zoom
    quadletorig(i, 3) = quadletorig(i, 3) + nhat(3) * 1 / zoom
    quadletorig(i, 4) = quadletorig(i, 4) + nhat(1) * 1 / zoom
    quadletorig(i, 5) = quadletorig(i, 5) + nhat(2) * 1 / zoom
    quadletorig(i, 6) = quadletorig(i, 6) + nhat(3) * 1 / zoom
    quadletorig(i, 7) = quadletorig(i, 7) + nhat(1) * 1 / zoom
    quadletorig(i, 8) = quadletorig(i, 8) + nhat(2) * 1 / zoom
    quadletorig(i, 9) = quadletorig(i, 9) + nhat(3) * 1 / zoom
    quadletorig(i, 10) = quadletorig(i, 10) + nhat(1) * 1 / zoom
    quadletorig(i, 11) = quadletorig(i, 11) + nhat(2) * 1 / zoom
    quadletorig(i, 12) = quadletorig(i, 12) + nhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.nhat.minus:
FOR i = 1 TO numquadletorig
    quadletorig(i, 1) = quadletorig(i, 1) - nhat(1) * 1 / zoom
    quadletorig(i, 2) = quadletorig(i, 2) - nhat(2) * 1 / zoom
    quadletorig(i, 3) = quadletorig(i, 3) - nhat(3) * 1 / zoom
    quadletorig(i, 4) = quadletorig(i, 4) - nhat(1) * 1 / zoom
    quadletorig(i, 5) = quadletorig(i, 5) - nhat(2) * 1 / zoom
    quadletorig(i, 6) = quadletorig(i, 6) - nhat(3) * 1 / zoom
    quadletorig(i, 7) = quadletorig(i, 7) - nhat(1) * 1 / zoom
    quadletorig(i, 8) = quadletorig(i, 8) - nhat(2) * 1 / zoom
    quadletorig(i, 9) = quadletorig(i, 9) - nhat(3) * 1 / zoom
    quadletorig(i, 10) = quadletorig(i, 10) - nhat(1) * 1 / zoom
    quadletorig(i, 11) = quadletorig(i, 11) - nhat(2) * 1 / zoom
    quadletorig(i, 12) = quadletorig(i, 12) - nhat(3) * 1 / zoom
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

' *** Define functions for quadlet manipulation. ***

timeanimate:
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

compute.viewplanes:
' Define normal vectors to all view planes.
nearplane(1) = -nhat(1)
nearplane(2) = -nhat(2)
nearplane(3) = -nhat(3)
farplane(1) = nhat(1)
farplane(2) = nhat(2)
farplane(3) = nhat(3)
rightplane(1) = (screenheight / 4) * fovd * uhat(1) - (screenheight / 4) * (screenwidth / 4) * nhat(1)
rightplane(2) = (screenheight / 4) * fovd * uhat(2) - (screenheight / 4) * (screenwidth / 4) * nhat(2)
rightplane(3) = (screenheight / 4) * fovd * uhat(3) - (screenheight / 4) * (screenwidth / 4) * nhat(3)
mag = SQR((rightplane(1)) ^ 2 + (rightplane(2)) ^ 2 + (rightplane(3)) ^ 2)
rightplane(1) = rightplane(1) / mag
rightplane(2) = rightplane(2) / mag
rightplane(3) = rightplane(3) / mag
leftplane(1) = -(screenheight / 4) * fovd * uhat(1) - (screenheight / 4) * (screenwidth / 4) * nhat(1)
leftplane(2) = -(screenheight / 4) * fovd * uhat(2) - (screenheight / 4) * (screenwidth / 4) * nhat(2)
leftplane(3) = -(screenheight / 4) * fovd * uhat(3) - (screenheight / 4) * (screenwidth / 4) * nhat(3)
mag = SQR((leftplane(1)) ^ 2 + (leftplane(2)) ^ 2 + (leftplane(3)) ^ 2)
leftplane(1) = leftplane(1) / mag
leftplane(2) = leftplane(2) / mag
leftplane(3) = leftplane(3) / mag
topplane(1) = (screenwidth / 4) * fovd * vhat(1) - (screenheight / 4) * (screenwidth / 4) * nhat(1)
topplane(2) = (screenwidth / 4) * fovd * vhat(2) - (screenheight / 4) * (screenwidth / 4) * nhat(2)
topplane(3) = (screenwidth / 4) * fovd * vhat(3) - (screenheight / 4) * (screenwidth / 4) * nhat(3)
mag = SQR((topplane(1)) ^ 2 + (topplane(2)) ^ 2 + (topplane(3)) ^ 2)
topplane(1) = topplane(1) / mag
topplane(2) = topplane(2) / mag
topplane(3) = topplane(3) / mag
bottomplane(1) = -(screenwidth / 4) * fovd * vhat(1) - (screenheight / 4) * (screenwidth / 4) * nhat(1)
bottomplane(2) = -(screenwidth / 4) * fovd * vhat(2) - (screenheight / 4) * (screenwidth / 4) * nhat(2)
bottomplane(3) = -(screenwidth / 4) * fovd * vhat(3) - (screenheight / 4) * (screenwidth / 4) * nhat(3)
mag = SQR((bottomplane(1)) ^ 2 + (bottomplane(2)) ^ 2 + (bottomplane(3)) ^ 2)
bottomplane(1) = bottomplane(1) / mag
bottomplane(2) = bottomplane(2) / mag
bottomplane(3) = bottomplane(3) / mag
RETURN

quadlet.filter.faceon:
pcountquadletfaceon = 0
FOR i = 1 TO numquadletorig
    Ax = quadletorig(i, 4) - quadletorig(i, 1)
    Ay = quadletorig(i, 5) - quadletorig(i, 2)
    Az = quadletorig(i, 6) - quadletorig(i, 3)
    Bx = quadletorig(i, 7) - quadletorig(i, 1)
    By = quadletorig(i, 8) - quadletorig(i, 2)
    Bz = quadletorig(i, 9) - quadletorig(i, 3)
    centroidx = (1 / 3) * (quadletorig(i, 1) + quadletorig(i, 4) + quadletorig(i, 7))
    centroidy = (1 / 3) * (quadletorig(i, 2) + quadletorig(i, 5) + quadletorig(i, 8))
    centroidz = (1 / 3) * (quadletorig(i, 3) + quadletorig(i, 6) + quadletorig(i, 9))
    PanelNormx = Ay * Bz - Az * By
    PanelNormy = Az * Bx - Ax * Bz
    PanelNormz = Ax * By - Ay * Bx
    mag = SQR(PanelNormx ^ 2 + PanelNormy ^ 2 + PanelNormz ^ 2)
    PanelNormx = PanelNormx / mag
    PanelNormy = PanelNormy / mag
    PanelNormz = PanelNormz / mag
    panelnormdotnhat = PanelNormx * nhat(1) + PanelNormy * nhat(2) + PanelNormz * nhat(3)
    cullpoint = PanelNormx * centroidx + PanelNormy * centroidy + PanelNormz * centroidz
    IF panelnormdotnhat >= cullpoint THEN
        pcountquadletfaceon = pcountquadletfaceon + 1
        quadletfaceon(pcountquadletfaceon, 1) = quadletorig(i, 1)
        quadletfaceon(pcountquadletfaceon, 2) = quadletorig(i, 2)
        quadletfaceon(pcountquadletfaceon, 3) = quadletorig(i, 3)
        quadletfaceon(pcountquadletfaceon, 4) = quadletorig(i, 4)
        quadletfaceon(pcountquadletfaceon, 5) = quadletorig(i, 5)
        quadletfaceon(pcountquadletfaceon, 6) = quadletorig(i, 6)
        quadletfaceon(pcountquadletfaceon, 7) = quadletorig(i, 7)
        quadletfaceon(pcountquadletfaceon, 8) = quadletorig(i, 8)
        quadletfaceon(pcountquadletfaceon, 9) = quadletorig(i, 9)
        quadletfaceon(pcountquadletfaceon, 10) = quadletorig(i, 10)
        quadletfaceon(pcountquadletfaceon, 11) = quadletorig(i, 11)
        quadletfaceon(pcountquadletfaceon, 12) = quadletorig(i, 12)
        quadletfaceon(pcountquadletfaceon, 13) = quadletorig(i, 13)
    ELSE
        IF toggleculling = 1 THEN
            pcountquadletfaceon = pcountquadletfaceon + 1
            quadletfaceon(pcountquadletfaceon, 1) = quadletorig(i, 1)
            quadletfaceon(pcountquadletfaceon, 2) = quadletorig(i, 2)
            quadletfaceon(pcountquadletfaceon, 3) = quadletorig(i, 3)
            quadletfaceon(pcountquadletfaceon, 4) = quadletorig(i, 4)
            quadletfaceon(pcountquadletfaceon, 5) = quadletorig(i, 5)
            quadletfaceon(pcountquadletfaceon, 6) = quadletorig(i, 6)
            quadletfaceon(pcountquadletfaceon, 7) = quadletorig(i, 7)
            quadletfaceon(pcountquadletfaceon, 8) = quadletorig(i, 8)
            quadletfaceon(pcountquadletfaceon, 9) = quadletorig(i, 9)
            quadletfaceon(pcountquadletfaceon, 10) = quadletorig(i, 10)
            quadletfaceon(pcountquadletfaceon, 11) = quadletorig(i, 11)
            quadletfaceon(pcountquadletfaceon, 12) = quadletorig(i, 12)
            quadletfaceon(pcountquadletfaceon, 13) = _RGB(50, 50, 50)
        END IF
    END IF
NEXT
numquadletfaceon = pcountquadletfaceon
RETURN

copy.quadlets.faceon.clip:
FOR i = 1 TO numquadletfaceon
    quadletclip(i, 1) = quadletfaceon(i, 1)
    quadletclip(i, 2) = quadletfaceon(i, 2)
    quadletclip(i, 3) = quadletfaceon(i, 3)
    quadletclip(i, 4) = quadletfaceon(i, 4)
    quadletclip(i, 5) = quadletfaceon(i, 5)
    quadletclip(i, 6) = quadletfaceon(i, 6)
    quadletclip(i, 7) = quadletfaceon(i, 7)
    quadletclip(i, 8) = quadletfaceon(i, 8)
    quadletclip(i, 9) = quadletfaceon(i, 9)
    quadletclip(i, 10) = quadletfaceon(i, 10)
    quadletclip(i, 11) = quadletfaceon(i, 11)
    quadletclip(i, 12) = quadletfaceon(i, 12)
    quadletclip(i, 13) = quadletfaceon(i, 13)
NEXT
numquadletclip = numquadletfaceon
RETURN

clip.quadlets.viewplanes:
givenplanex = nearplane(1)
givenplaney = nearplane(2)
givenplanez = nearplane(3)
givenplaned = nearplane(4)
GOSUB clip.quadlets.givenplane
GOSUB copy.quadlets.clipwork.clip
givenplanex = rightplane(1)
givenplaney = rightplane(2)
givenplanez = rightplane(3)
givenplaned = rightplane(4)
GOSUB clip.quadlets.givenplane
GOSUB copy.quadlets.clipwork.clip
givenplanex = leftplane(1)
givenplaney = leftplane(2)
givenplanez = leftplane(3)
givenplaned = leftplane(4)
GOSUB clip.quadlets.givenplane
GOSUB copy.quadlets.clipwork.clip
givenplanex = topplane(1)
givenplaney = topplane(2)
givenplanez = topplane(3)
givenplaned = topplane(4)
GOSUB clip.quadlets.givenplane
GOSUB copy.quadlets.clipwork.clip
givenplanex = bottomplane(1)
givenplaney = bottomplane(2)
givenplanez = bottomplane(3)
givenplaned = bottomplane(4)
GOSUB clip.quadlets.givenplane
GOSUB copy.quadlets.clipwork.clip
RETURN

clip.quadlets.givenplane:
FOR i = 1 TO numquadletclip
    quadletclipwork(i, 1) = quadletclip(i, 1)
    quadletclipwork(i, 2) = quadletclip(i, 2)
    quadletclipwork(i, 3) = quadletclip(i, 3)
    quadletclipwork(i, 4) = quadletclip(i, 4)
    quadletclipwork(i, 5) = quadletclip(i, 5)
    quadletclipwork(i, 6) = quadletclip(i, 6)
    quadletclipwork(i, 7) = quadletclip(i, 7)
    quadletclipwork(i, 8) = quadletclip(i, 8)
    quadletclipwork(i, 9) = quadletclip(i, 9)
    quadletclipwork(i, 10) = quadletclip(i, 10)
    quadletclipwork(i, 11) = quadletclip(i, 11)
    quadletclipwork(i, 12) = quadletclip(i, 12)
    quadletclipwork(i, 13) = quadletclip(i, 13)
    pcountquadletclipwork = numquadletclip
NEXT
'pcountquadletclipwork = 0
'FOR i = 1 TO numquadletclip
'    quadletclip1dotgivenplane = quadletclip(i, 1) * givenplanex + quadletclip(i, 2) * givenplaney + quadletclip(i, 3) * givenplanez - givenplaned
'    quadletclip2dotgivenplane = quadletclip(i, 4) * givenplanex + quadletclip(i, 5) * givenplaney + quadletclip(i, 6) * givenplanez - givenplaned
'    quadletclip3dotgivenplane = quadletclip(i, 7) * givenplanex + quadletclip(i, 8) * givenplaney + quadletclip(i, 9) * givenplanez - givenplaned
'    gamma12 = quadletclip2dotgivenplane / quadletclip1dotgivenplane
'    gamma23 = quadletclip3dotgivenplane / quadletclip2dotgivenplane
'    gamma31 = quadletclip1dotgivenplane / quadletclip3dotgivenplane
'    A12x = (quadletclip(i, 1) - quadletclip(i, 4)) / (1 - gamma12)
'    A12y = (quadletclip(i, 2) - quadletclip(i, 5)) / (1 - gamma12)
'    A12z = (quadletclip(i, 3) - quadletclip(i, 6)) / (1 - gamma12)
'    B12x = gamma12 * A12x
'    B12y = gamma12 * A12y
'    B12z = gamma12 * A12z
'    A23x = (quadletclip(i, 4) - quadletclip(i, 7)) / (1 - gamma23)
'    A23y = (quadletclip(i, 5) - quadletclip(i, 8)) / (1 - gamma23)
'    A23z = (quadletclip(i, 6) - quadletclip(i, 9)) / (1 - gamma23)
'    B23x = gamma23 * A23x
'    B23y = gamma23 * A23y
'    B23z = gamma23 * A23z
'    A31x = (quadletclip(i, 7) - quadletclip(i, 1)) / (1 - gamma31)
'    A31y = (quadletclip(i, 8) - quadletclip(i, 2)) / (1 - gamma31)
'    A31z = (quadletclip(i, 9) - quadletclip(i, 3)) / (1 - gamma31)
'    B31x = gamma31 * A31x
'    B31y = gamma31 * A31y
'    B31z = gamma31 * A31z
'    A12dotgivenplane = A12x * givenplanex + A12y * givenplaney + A12z * givenplanez
'    B12dotgivenplane = B12x * givenplanex + B12y * givenplaney + B12z * givenplanez
'    A23dotgivenplane = A23x * givenplanex + A23y * givenplaney + A23z * givenplanez
'    B23dotgivenplane = B23x * givenplanex + B23y * givenplaney + B23z * givenplanez
'    A31dotgivenplane = A31x * givenplanex + A31y * givenplaney + A31z * givenplanez
'    B31dotgivenplane = B31x * givenplanex + B31y * givenplaney + B31z * givenplanez
'    IF A12dotgivenplane > 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane > 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 1)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 2)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 3)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 4)
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 5)
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 6)
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 7)
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 8)
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 9)
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'        panelinview = 1
'    END IF
'    IF A12dotgivenplane > 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane < 0 AND A31dotgivenplane < 0 AND B31dotgivenplane > 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 1)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 2)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 3)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 1) - B31x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 2) - B31y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 3) - B31z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 7) - B23x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 8) - B23y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 9) - B23z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 1)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 2)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 3)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 4)
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 5)
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 6)
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 7) - B23x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 8) - B23y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 9) - B23z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'    END IF
'    IF A12dotgivenplane < 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane < 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 7)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 8)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 9)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 1) - B31x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 2) - B31y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 3) - B31z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 4)
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 5)
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 6)
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 4)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 5)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 6)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 1) - B31x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 2) - B31y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 3) - B31z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 4) - B12x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 5) - B12y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 6) - B12z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'    END IF
'    IF A12dotgivenplane > 0 AND B12dotgivenplane < 0 AND A23dotgivenplane < 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane > 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 1)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 2)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 3)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 4) - B12x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 5) - B12y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 6) - B12z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 7)
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 8)
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 9)
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 7)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 8)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 9)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 4) - B12x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 5) - B12y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 6) - B12z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 7) - B23x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 8) - B23y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 9) - B23z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'    END IF
'    IF A12dotgivenplane > 0 AND B12dotgivenplane < 0 AND A23dotgivenplane < 0 AND B23dotgivenplane < 0 AND A31dotgivenplane < 0 AND B31dotgivenplane > 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 1)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 2)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 3)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 4) - B12x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 5) - B12y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 6) - B12z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 1) - B31x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 2) - B31y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 3) - B31z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'    END IF
'    IF A12dotgivenplane < 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane < 0 AND A31dotgivenplane < 0 AND B31dotgivenplane < 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 4)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 5)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 6)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 7) - B23x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 8) - B23y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 9) - B23z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 4) - B12x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 5) - B12y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 6) - B12z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 13) = quadletclip(i, 13)
'    END IF
'    IF A12dotgivenplane < 0 AND B12dotgivenplane < 0 AND A23dotgivenplane < 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane < 0 THEN
'        pcountquadletclipwork = pcountquadletclipwork + 1
'        quadletclipwork(pcountquadletclipwork, 1) = quadletclip(i, 7)
'        quadletclipwork(pcountquadletclipwork, 2) = quadletclip(i, 8)
'        quadletclipwork(pcountquadletclipwork, 3) = quadletclip(i, 9)
'        quadletclipwork(pcountquadletclipwork, 4) = quadletclip(i, 7) - B23x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 5) = quadletclip(i, 8) - B23y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 6) = quadletclip(i, 9) - B23z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 7) = quadletclip(i, 1) - B31x + givenplaned * givenplanex
'        quadletclipwork(pcountquadletclipwork, 8) = quadletclip(i, 2) - B31y + givenplaned * givenplaney
'        quadletclipwork(pcountquadletclipwork, 9) = quadletclip(i, 3) - B31z + givenplaned * givenplanez
'        quadletclipwork(pcountquadletclipwork, 10) = quadletclip(i, 10)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 11)
'        quadletclipwork(pcountquadletclipwork, 11) = quadletclip(i, 12)
'        quadletclipwork(pcountquadletclipwork, 12) = quadletclip(i, 13)
'    END IF
'NEXT
RETURN

copy.quadlets.clipwork.clip:
FOR i = 1 TO pcountquadletclipwork
    quadletclip(i, 1) = quadletclipwork(i, 1)
    quadletclip(i, 2) = quadletclipwork(i, 2)
    quadletclip(i, 3) = quadletclipwork(i, 3)
    quadletclip(i, 4) = quadletclipwork(i, 4)
    quadletclip(i, 5) = quadletclipwork(i, 5)
    quadletclip(i, 6) = quadletclipwork(i, 6)
    quadletclip(i, 7) = quadletclipwork(i, 7)
    quadletclip(i, 8) = quadletclipwork(i, 8)
    quadletclip(i, 9) = quadletclipwork(i, 9)
    quadletclip(i, 10) = quadletclipwork(i, 10)
    quadletclip(i, 11) = quadletclipwork(i, 11)
    quadletclip(i, 12) = quadletclipwork(i, 12)
    quadletclip(i, 13) = quadletclipwork(i, 13)
NEXT
numquadletclip = pcountquadletclipwork
RETURN

copy.quadlets.clip.depthsort:
FOR i = 1 TO numquadletclip
    quadletdepthsort(i, 1) = quadletclip(i, 1)
    quadletdepthsort(i, 2) = quadletclip(i, 2)
    quadletdepthsort(i, 3) = quadletclip(i, 3)
    quadletdepthsort(i, 4) = quadletclip(i, 4)
    quadletdepthsort(i, 5) = quadletclip(i, 5)
    quadletdepthsort(i, 6) = quadletclip(i, 6)
    quadletdepthsort(i, 7) = quadletclip(i, 7)
    quadletdepthsort(i, 8) = quadletclip(i, 8)
    quadletdepthsort(i, 9) = quadletclip(i, 9)
    quadletdepthsort(i, 10) = quadletclip(i, 10)
    quadletdepthsort(i, 11) = quadletclip(i, 11)
    quadletdepthsort(i, 12) = quadletclip(i, 12)
    quadletdepthsort(i, 13) = quadletclip(i, 13)
NEXT
numquadletdepthsort = numquadletclip
RETURN

quadlets.depthsort.routine:
FOR i = (numquadletdepthsort) TO 1 STEP -1
    FOR j = 1 TO i - 1
        centroidx = (1 / 3) * (quadletdepthsort(j, 1) + quadletdepthsort(j, 4) + quadletdepthsort(j, 7) + quadletdepthsort(j, 10))
        centroidy = (1 / 3) * (quadletdepthsort(j, 2) + quadletdepthsort(j, 5) + quadletdepthsort(j, 8) + quadletdepthsort(j, 11))
        centroidz = (1 / 3) * (quadletdepthsort(j, 3) + quadletdepthsort(j, 6) + quadletdepthsort(j, 9) + quadletdepthsort(j, 12))
        centdepthj0 = centroidx ^ 2 + centroidy ^ 2 + centroidz ^ 2
        centroidx = (1 / 3) * (quadletdepthsort(j + 1, 1) + quadletdepthsort(j + 1, 4) + quadletdepthsort(j + 1, 7) + quadletdepthsort(j + 1, 10))
        centroidy = (1 / 3) * (quadletdepthsort(j + 1, 2) + quadletdepthsort(j + 1, 5) + quadletdepthsort(j + 1, 8) + quadletdepthsort(j + 1, 11))
        centroidz = (1 / 3) * (quadletdepthsort(j + 1, 3) + quadletdepthsort(j + 1, 6) + quadletdepthsort(j + 1, 9) + quadletdepthsort(j + 1, 12))
        centdepthj1 = centroidx ^ 2 + centroidy ^ 2 + centroidz ^ 2
        IF centdepthj0 < centdepthj1 THEN
            temp1 = quadletdepthsort(j, 1)
            temp2 = quadletdepthsort(j, 2)
            temp3 = quadletdepthsort(j, 3)
            temp4 = quadletdepthsort(j, 4)
            temp5 = quadletdepthsort(j, 5)
            temp6 = quadletdepthsort(j, 6)
            temp7 = quadletdepthsort(j, 7)
            temp8 = quadletdepthsort(j, 8)
            temp9 = quadletdepthsort(j, 9)
            temp10 = quadletdepthsort(j, 10)
            temp11 = quadletdepthsort(j, 11)
            temp12 = quadletdepthsort(j, 12)
            temp13 = quadletdepthsort(j, 13)
            quadletdepthsort(j, 1) = quadletdepthsort(j + 1, 1)
            quadletdepthsort(j, 2) = quadletdepthsort(j + 1, 2)
            quadletdepthsort(j, 3) = quadletdepthsort(j + 1, 3)
            quadletdepthsort(j, 4) = quadletdepthsort(j + 1, 4)
            quadletdepthsort(j, 5) = quadletdepthsort(j + 1, 5)
            quadletdepthsort(j, 6) = quadletdepthsort(j + 1, 6)
            quadletdepthsort(j, 7) = quadletdepthsort(j + 1, 7)
            quadletdepthsort(j, 8) = quadletdepthsort(j + 1, 8)
            quadletdepthsort(j, 9) = quadletdepthsort(j + 1, 9)
            quadletdepthsort(j, 10) = quadletdepthsort(j + 1, 10)
            quadletdepthsort(j, 11) = quadletdepthsort(j + 1, 11)
            quadletdepthsort(j, 12) = quadletdepthsort(j + 1, 12)
            quadletdepthsort(j, 13) = quadletdepthsort(j + 1, 13)
            quadletdepthsort(j + 1, 1) = temp1
            quadletdepthsort(j + 1, 2) = temp2
            quadletdepthsort(j + 1, 3) = temp3
            quadletdepthsort(j + 1, 4) = temp4
            quadletdepthsort(j + 1, 5) = temp5
            quadletdepthsort(j + 1, 6) = temp6
            quadletdepthsort(j + 1, 7) = temp7
            quadletdepthsort(j + 1, 8) = temp8
            quadletdepthsort(j + 1, 9) = temp9
            quadletdepthsort(j + 1, 10) = temp10
            quadletdepthsort(j + 1, 11) = temp11
            quadletdepthsort(j + 1, 12) = temp12
            quadletdepthsort(j + 1, 13) = temp13
        END IF
    NEXT
NEXT
RETURN

copy.quadlets.depthsort.final:
FOR i = 1 TO numquadletclip
    quadletfinal(i, 1) = quadletdepthsort(i, 1)
    quadletfinal(i, 2) = quadletdepthsort(i, 2)
    quadletfinal(i, 3) = quadletdepthsort(i, 3)
    quadletfinal(i, 4) = quadletdepthsort(i, 4)
    quadletfinal(i, 5) = quadletdepthsort(i, 5)
    quadletfinal(i, 6) = quadletdepthsort(i, 6)
    quadletfinal(i, 7) = quadletdepthsort(i, 7)
    quadletfinal(i, 8) = quadletdepthsort(i, 8)
    quadletfinal(i, 9) = quadletdepthsort(i, 9)
    quadletfinal(i, 10) = quadletdepthsort(i, 10)
    quadletfinal(i, 11) = quadletdepthsort(i, 11)
    quadletfinal(i, 12) = quadletdepthsort(i, 12)
    quadletfinal(i, 13) = quadletdepthsort(i, 13)
NEXT
numquadletfinal = numquadletdepthsort
RETURN

project.quadlets:
FOR i = 1 TO numquadletfinal
    quadletfinaldotnhat(i, 1) = quadletfinal(i, 1) * nhat(1) + quadletfinal(i, 2) * nhat(2) + quadletfinal(i, 3) * nhat(3)
    quadletfinaldotnhat(i, 2) = quadletfinal(i, 4) * nhat(1) + quadletfinal(i, 5) * nhat(2) + quadletfinal(i, 6) * nhat(3)
    quadletfinaldotnhat(i, 3) = quadletfinal(i, 7) * nhat(1) + quadletfinal(i, 8) * nhat(2) + quadletfinal(i, 9) * nhat(3)
    quadletfinaldotnhat(i, 4) = quadletfinal(i, 10) * nhat(1) + quadletfinal(i, 11) * nhat(2) + quadletfinal(i, 12) * nhat(3)
    quadletfinalpuv(i, 1) = quadletfinal(i, 1) * uhat(1) + quadletfinal(i, 2) * uhat(2) + quadletfinal(i, 3) * uhat(3)
    quadletfinalpuv(i, 2) = quadletfinal(i, 1) * vhat(1) + quadletfinal(i, 2) * vhat(2) + quadletfinal(i, 3) * vhat(3)
    quadletfinalpuv(i, 3) = quadletfinal(i, 4) * uhat(1) + quadletfinal(i, 5) * uhat(2) + quadletfinal(i, 6) * uhat(3)
    quadletfinalpuv(i, 4) = quadletfinal(i, 4) * vhat(1) + quadletfinal(i, 5) * vhat(2) + quadletfinal(i, 6) * vhat(3)
    quadletfinalpuv(i, 5) = quadletfinal(i, 7) * uhat(1) + quadletfinal(i, 8) * uhat(2) + quadletfinal(i, 9) * uhat(3)
    quadletfinalpuv(i, 6) = quadletfinal(i, 7) * vhat(1) + quadletfinal(i, 8) * vhat(2) + quadletfinal(i, 9) * vhat(3)
    quadletfinalpuv(i, 7) = quadletfinal(i, 10) * uhat(1) + quadletfinal(i, 11) * uhat(2) + quadletfinal(i, 12) * uhat(3)
    quadletfinalpuv(i, 8) = quadletfinal(i, 10) * vhat(1) + quadletfinal(i, 11) * vhat(2) + quadletfinal(i, 12) * vhat(3)
NEXT
RETURN

depth.adjust.quadlets:
FOR i = 1 TO numquadletfinal
    quadletfinalpuvs(i, 1) = quadletfinalpuv(i, 1) * fovd / quadletfinaldotnhat(i, 1)
    quadletfinalpuvs(i, 2) = quadletfinalpuv(i, 2) * fovd / quadletfinaldotnhat(i, 1)
    quadletfinalpuvs(i, 3) = quadletfinalpuv(i, 3) * fovd / quadletfinaldotnhat(i, 2)
    quadletfinalpuvs(i, 4) = quadletfinalpuv(i, 4) * fovd / quadletfinaldotnhat(i, 2)
    quadletfinalpuvs(i, 5) = quadletfinalpuv(i, 5) * fovd / quadletfinaldotnhat(i, 3)
    quadletfinalpuvs(i, 6) = quadletfinalpuv(i, 6) * fovd / quadletfinaldotnhat(i, 3)
    quadletfinalpuvs(i, 7) = quadletfinalpuv(i, 7) * fovd / quadletfinaldotnhat(i, 4)
    quadletfinalpuvs(i, 8) = quadletfinalpuv(i, 8) * fovd / quadletfinaldotnhat(i, 4)
NEXT
RETURN

draw.all.objects:
GOSUB plotmode.3denvquadlets
' Replace basis vector triad.
x = 50 * xhatp.old(1): y = 50 * xhatp.old(2): GOSUB convert
LINE (centerx, centery)-(x, y), 0
x = 50 * yhatp.old(1): y = 50 * yhatp.old(2): GOSUB convert
LINE (centerx, centery)-(x, y), 0
x = 50 * zhatp.old(1): y = 50 * zhatp.old(2): GOSUB convert
LINE (centerx, centery)-(x, y), 0
x = 50 * xhatp(1): y = 50 * xhatp(2): GOSUB convert
LINE (centerx, centery)-(x, y), xhat(4)
x = 50 * yhatp(1): y = 50 * yhatp(2): GOSUB convert
LINE (centerx, centery)-(x, y), yhat(4)
x = 50 * zhatp(1): y = 50 * zhatp(2): GOSUB convert
LINE (centerx, centery)-(x, y), zhat(4)
COLOR _RGB(255, 255, 255)
LOCATE 26, 2: PRINT "- MOVE -"
COLOR _RGB(255, 255, 255)
LOCATE 27, 2: PRINT " q W e"
LOCATE 28, 2: PRINT " A S D"
COLOR _RGB(255, 255, 255)
LOCATE 25, 68: PRINT "-   VIEW   -"
COLOR _RGB(255, 255, 255)
LOCATE 26, 68: PRINT "  8  "
LOCATE 27, 68: PRINT "4   6"
LOCATE 28, 68: PRINT "  2  "
COLOR _RGB(255, 255, 255)
LOCATE 26, 75: PRINT "7   9"
LOCATE 27, 75: PRINT "     "
LOCATE 28, 75: PRINT "1   3"
LOCATE 27, 21: PRINT "SPACE = toggle PAINT,  ESC = quit."
LOCATE 28, 21: PRINT "C or c = toggle backface culling."
LOCATE 1, 18: PRINT "Press G or g to reset with random colors."
RETURN

store.screen.projections:
xhatp.old(1) = xhatp(1): xhatp.old(2) = xhatp(2)
yhatp.old(1) = yhatp(1): yhatp.old(2) = yhatp(2)
zhatp.old(1) = zhatp(1): zhatp.old(2) = zhatp(2)
numquadletfinal.old = numquadletfinal
RETURN

' *** Define functions for plot modes. ***

plotmode.3denvquadlets:
hudflagtemp = -1
redoplot:
CLS
FOR i = 1 TO numquadletfinal
    ' Draw new graphics.
    x = zoom * quadletfinalpuvs(i, 1): y = zoom * quadletfinalpuvs(i, 2)
    Px3 = x: Py3 = y
    GOSUB convert
    u3 = x: v3 = y

    x = zoom * quadletfinalpuvs(i, 3): y = zoom * quadletfinalpuvs(i, 4)
    Px2 = x: Py2 = y
    GOSUB convert
    u2 = x: v2 = y

    x = zoom * quadletfinalpuvs(i, 5): y = zoom * quadletfinalpuvs(i, 6)
    Px1 = x: Py1 = y
    GOSUB convert
    u1 = x: v1 = y

    x = zoom * quadletfinalpuvs(i, 7): y = zoom * quadletfinalpuvs(i, 8)
    Px4 = x: Py4 = y
    GOSUB convert
    u4 = x: v4 = y

    _MAPTRIANGLE (0, 0)-(InputImageWidth, InputImageHeight)-(0, InputImageHeight), TextureImage& TO(u1, v1)-(u2, v2)-(u3, v3)
    _MAPTRIANGLE (0, 0)-(InputImageWidth, InputImageHeight)-(InputImageWidth, 0), TextureImage& TO(u1, v1)-(u2, v2)-(u4, v4)

    'LINE (u1, v1)-(u2, v2), 15
    'LINE (u2, v2)-(u3, v3), 15
    'LINE (u3, v3)-(u1, v1), 15
    'centu = (1 / 3) * (u1 + u2 + u3)
    'centv = (1 / 3) * (v1 + v2 + v3)
    'IF togglehud = 1 THEN
    '    ' Paint triangles.
    '    PAINT (centu, centv), quadletfinal(i, 10), 15

    '    'Very hacky bug detection.
    '    'Check if the unused pixel at 1,1 has color.
    '    IF SCREEN(1, 1) <> bgcol THEN
    '        hudflagtemp = 1
    '        togglehud = -1
    '        GOTO redoplot
    '    END IF

    'END IF
    'LINE (u1, v1)-(u2, v2), quadletfinal(i, 10)
    'LINE (u2, v2)-(u3, v3), quadletfinal(i, 10)
    'LINE (u3, v3)-(u1, v1), quadletfinal(i, 10)

NEXT
IF hudflagtemp = 1 THEN
    togglehud = 1
END IF
RETURN

' *** Define functions for generation schemes. ***

genscheme.3denvquadlets:
pcountquadletorig = 0
'cubes
cubesidelength = 5
cubecenterx = 40: cubecentery = 0: cubecenterz = -25: GOSUB genscheme.3denvquadlets.makecube
cubecenterx = 20: cubecentery = 15: cubecenterz = -15: GOSUB genscheme.3denvquadlets.makecube
cubecenterx = 0: cubecentery = 0: cubecenterz = -15: GOSUB genscheme.3denvquadlets.makecube
'panels
'panelsidelength = 5
'panel1color = INT(RND * 14) + 1
'panel2color = INT(RND * 14) + 1
'panelcenterx = 0: panelcentery = 0: panelcenterz = -50
'GOSUB genscheme.3denvquadlets.makecheckerpanel
RETURN

'genscheme.3denvquadlets.makecheckerpanel:
'FOR i = -panelsidelength * 10 TO panelsidelength * 10 STEP 2 * panelsidelength
'    FOR j = -panelsidelength * 10 TO panelsidelength * 10 STEP 2 * panelsidelength
'        basepointx = panelcenterx - panelsidelength + i
'        basepointy = panelcentery + panelsidelength + j
'        basepointz = panelcenterz + panelsidelength
'        rightpointx = panelcenterx - panelsidelength + i
'        rightpointy = panelcentery - panelsidelength + j
'        rightpointz = panelcenterz + panelsidelength
'        leftpointx = panelcenterx + panelsidelength + i
'        leftpointy = panelcentery + panelsidelength + j
'        leftpointz = panelcenterz + panelsidelength
'        panelcolor = panel1color
'        GOSUB create.original.quadangle
'        basepointx = panelcenterx + panelsidelength + i
'        basepointy = panelcentery + panelsidelength + j
'        basepointz = panelcenterz + panelsidelength
'        rightpointx = panelcenterx - panelsidelength + i
'        rightpointy = panelcentery - panelsidelength + j
'        rightpointz = panelcenterz + panelsidelength
'        leftpointx = panelcenterx + panelsidelength + i
'        leftpointy = panelcentery - panelsidelength + j
'        leftpointz = panelcenterz + panelsidelength
'        panelcolor = panel2color
'        GOSUB create.original.quadangle
'    NEXT
'NEXT
'RETURN

genscheme.3denvquadlets.makecube:
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz - cubesidelength
cornerpointx = cubecenterx - cubesidelength
cornerpointy = cubecentery - cubesidelength
cornerpointz = cubecenterz - cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.quadangle
'basepointx = cubecenterx - cubesidelength
'basepointy = cubecentery + cubesidelength
'basepointz = cubecenterz - cubesidelength
'rightpointx = cubecenterx + cubesidelength
'rightpointy = cubecentery - cubesidelength
'rightpointz = cubecenterz - cubesidelength
'leftpointx = cubecenterx - cubesidelength
'leftpointy = cubecentery - cubesidelength
'leftpointz = cubecenterz - cubesidelength
'GOSUB create.original.quadangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
cornerpointx = cubecenterx - cubesidelength
cornerpointy = cubecentery - cubesidelength
cornerpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.quadangle
'basepointx = cubecenterx - cubesidelength
'basepointy = cubecentery + cubesidelength
'basepointz = cubecenterz + cubesidelength
'rightpointx = cubecenterx - cubesidelength
'rightpointy = cubecentery - cubesidelength
'rightpointz = cubecenterz - cubesidelength
'leftpointx = cubecenterx - cubesidelength
'leftpointy = cubecentery - cubesidelength
'leftpointz = cubecenterz + cubesidelength
'GOSUB create.original.quadangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery - cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
cornerpointx = cubecenterx + cubesidelength
cornerpointy = cubecentery - cubesidelength
cornerpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.quadangle
'basepointx = cubecenterx - cubesidelength
'basepointy = cubecentery - cubesidelength
'basepointz = cubecenterz + cubesidelength
'rightpointx = cubecenterx + cubesidelength
'rightpointy = cubecentery - cubesidelength
'rightpointz = cubecenterz - cubesidelength
'leftpointx = cubecenterx + cubesidelength
'leftpointy = cubecentery - cubesidelength
'leftpointz = cubecenterz + cubesidelength
'GOSUB create.original.quadangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz + cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
cornerpointx = cubecenterx + cubesidelength
cornerpointy = cubecentery - cubesidelength
cornerpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.quadangle
'basepointx = cubecenterx + cubesidelength
'basepointy = cubecentery + cubesidelength
'basepointz = cubecenterz + cubesidelength
'rightpointx = cubecenterx - cubesidelength
'rightpointy = cubecentery - cubesidelength
'rightpointz = cubecenterz + cubesidelength
'leftpointx = cubecenterx + cubesidelength
'leftpointy = cubecentery - cubesidelength
'leftpointz = cubecenterz + cubesidelength
'GOSUB create.original.quadangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery - cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery + cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
'cornerpointx = cubecenterx - cubesidelength
'cornerpointy = cubecentery - cubesidelength
'cornerpointz = cubecenterz - cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.quadangle
'basepointx = cubecenterx + cubesidelength
'basepointy = cubecentery - cubesidelength
'basepointz = cubecenterz + cubesidelength
'rightpointx = cubecenterx + cubesidelength
'rightpointy = cubecentery + cubesidelength
'rightpointz = cubecenterz - cubesidelength
'leftpointx = cubecenterx + cubesidelength
'leftpointy = cubecentery + cubesidelength
'leftpointz = cubecenterz + cubesidelength
'GOSUB create.original.quadangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery + cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
cornerpointx = cubecenterx - cubesidelength
cornerpointy = cubecentery + cubesidelength
cornerpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.quadangle
'basepointx = cubecenterx + cubesidelength
'basepointy = cubecentery + cubesidelength
'basepointz = cubecenterz + cubesidelength
'rightpointx = cubecenterx - cubesidelength
'rightpointy = cubecentery + cubesidelength
'rightpointz = cubecenterz - cubesidelength
'leftpointx = cubecenterx - cubesidelength
'leftpointy = cubecentery + cubesidelength
'leftpointz = cubecenterz + cubesidelength
'GOSUB create.original.quadangle
RETURN

create.original.quadangle:
shrinkfactor = 1
centorigx = (1 / 3) * (basepointx + rightpointx + leftpointx)
centorigy = (1 / 3) * (basepointy + rightpointy + leftpointy)
centorigz = (1 / 3) * (basepointz + rightpointz + leftpointz)
basepointx = centorigx + (shrinkfactor) * (basepointx - centorigx)
basepointy = centorigy + (shrinkfactor) * (basepointy - centorigy)
basepointz = centorigz + (shrinkfactor) * (basepointz - centorigz)
rightpointx = centorigx + (shrinkfactor) * (rightpointx - centorigx)
rightpointy = centorigy + (shrinkfactor) * (rightpointy - centorigy)
rightpointz = centorigz + (shrinkfactor) * (rightpointz - centorigz)
leftpointx = centorigx + (shrinkfactor) * (leftpointx - centorigx)
leftpointy = centorigy + (shrinkfactor) * (leftpointy - centorigy)
leftpointz = centorigz + (shrinkfactor) * (leftpointz - centorigz)
cornerpointx = centorigx + (shrinkfactor) * (cornerpointx - centorigx)
cornerpointy = centorigy + (shrinkfactor) * (cornerpointy - centorigy)
cornerpointz = centorigz + (shrinkfactor) * (cornerpointz - centorigz)
pcountquadletorig = pcountquadletorig + 1
quadletorig(pcountquadletorig, 1) = basepointx
quadletorig(pcountquadletorig, 2) = basepointy
quadletorig(pcountquadletorig, 3) = basepointz
quadletorig(pcountquadletorig, 4) = rightpointx
quadletorig(pcountquadletorig, 5) = rightpointy
quadletorig(pcountquadletorig, 6) = rightpointz
quadletorig(pcountquadletorig, 7) = leftpointx
quadletorig(pcountquadletorig, 8) = leftpointy
quadletorig(pcountquadletorig, 9) = leftpointz
quadletorig(pcountquadletorig, 10) = cornerpointx
quadletorig(pcountquadletorig, 11) = cornerpointy
quadletorig(pcountquadletorig, 12) = cornerpointz
quadletorig(pcountquadletorig, 13) = panelcolor
RETURN

