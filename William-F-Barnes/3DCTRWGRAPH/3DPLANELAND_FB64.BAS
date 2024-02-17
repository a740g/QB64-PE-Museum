'#lang "qb" '...for freebasic compiler. Must disable for QB64 features.

' *** Video  and performance settings. ***
RANDOMIZE TIMER
bignumber = 500000
screenwidth = 640
screenheight = 480
SCREEN 12
CLS
bgcol = SCREEN(1, 1)

' *** Initialize counters and array sizes. ***
numtripletorig = bignumber
numtripletfaceon = bignumber
numtripletclip = bignumber
numtripletclipwork = bignumber
numtripletdepthsort = bignumber
numtripletencpoint = bignumber
numtripletintpointpair = bignumber
numtripletfinal = bignumber

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

' *** Define triplet arrays and structures. ***
' *** A triplet is a collection of three points plus a color. ***

' Triplet vectors defined in three-space.
DIM tripletorig(numtripletorig, 10)

' Triplet vectors after discarding outfacing members.
DIM tripletfaceon(numtripletfaceon, 10)

' Triplet vectors clipped by view planes.
DIM tripletclip(numtripletclip, 10)
DIM tripletclipwork(numtripletclipwork, 10)

' Triplet vectors sorted by painter's algorithm.
DIM tripletdepthsort(numtripletdepthsort, 10)

' Final triplet vectors.
DIM tripletfinal(numtripletfinal, 10)
DIM tripletfinaldotnhat(numtripletfinal, 3)
DIM tripletfinaldotnhat.old(numtripletfinal, 3)

' Final triplet vectors projected onto infinite uv two-space.
DIM tripletfinalpuv(numtripletfinal, 7)
DIM tripletfinalpuv.old(numtripletfinal, 7)

' Triplet projections adjusted for screen uv two-space.
DIM tripletfinalpuvs(numtripletfinal, 6)
DIM tripletfinalpuvs.old(numtripletfinal, 6)

' *** Set mathematical constants. ***

pi = 3.1415926536
ee = 2.7182818285

mainstart:

' *** Initialize user input variables. ***

key$ = ""
mousekey$ = ""

substart:

' *** Zero counters and array sizes. ***

numtripletorig = 0
numtripletfaceon = 0
numtripletclip = 0
numtripletclipwork = 0
numtripletfinal = 0
pcounttripletorig = 0

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
GOSUB genscheme.3denvtriplets
numtripletorig = pcounttripletorig

' Move objects to accomodate initial camera position.
IF camx <> 0 AND camy <> 0 AND camz <> 0 THEN
    FOR i = 1 TO numtripletorig
        tripletorig(i, 1) = tripletorig(i, 1) + camx
        tripletorig(i, 2) = tripletorig(i, 2) + camy
        tripletorig(i, 3) = tripletorig(i, 3) + camz
        tripletorig(i, 4) = tripletorig(i, 4) + camx
        tripletorig(i, 5) = tripletorig(i, 5) + camy
        tripletorig(i, 6) = tripletorig(i, 6) + camz
        tripletorig(i, 7) = tripletorig(i, 7) + camx
        tripletorig(i, 8) = tripletorig(i, 8) + camy
        tripletorig(i, 9) = tripletorig(i, 9) + camz
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
GOSUB triplet.filter.faceon
GOSUB copy.triplets.faceon.clip
GOSUB clip.triplets.viewplanes
GOSUB copy.triplets.clip.depthsort
GOSUB triplets.depthsort.routine
GOSUB copy.triplets.depthsort.final
GOSUB project.triplets
GOSUB depth.adjust.triplets
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
FOR i = 1 TO numtripletorig
    tripletorig(i, 1) = tripletorig(i, 1) + uhat(1) * 1 / zoom
    tripletorig(i, 2) = tripletorig(i, 2) + uhat(2) * 1 / zoom
    tripletorig(i, 3) = tripletorig(i, 3) + uhat(3) * 1 / zoom
    tripletorig(i, 4) = tripletorig(i, 4) + uhat(1) * 1 / zoom
    tripletorig(i, 5) = tripletorig(i, 5) + uhat(2) * 1 / zoom
    tripletorig(i, 6) = tripletorig(i, 6) + uhat(3) * 1 / zoom
    tripletorig(i, 7) = tripletorig(i, 7) + uhat(1) * 1 / zoom
    tripletorig(i, 8) = tripletorig(i, 8) + uhat(2) * 1 / zoom
    tripletorig(i, 9) = tripletorig(i, 9) + uhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.uhat.minus:
FOR i = 1 TO numtripletorig
    tripletorig(i, 1) = tripletorig(i, 1) - uhat(1) * 1 / zoom
    tripletorig(i, 2) = tripletorig(i, 2) - uhat(2) * 1 / zoom
    tripletorig(i, 3) = tripletorig(i, 3) - uhat(3) * 1 / zoom
    tripletorig(i, 4) = tripletorig(i, 4) - uhat(1) * 1 / zoom
    tripletorig(i, 5) = tripletorig(i, 5) - uhat(2) * 1 / zoom
    tripletorig(i, 6) = tripletorig(i, 6) - uhat(3) * 1 / zoom
    tripletorig(i, 7) = tripletorig(i, 7) - uhat(1) * 1 / zoom
    tripletorig(i, 8) = tripletorig(i, 8) - uhat(2) * 1 / zoom
    tripletorig(i, 9) = tripletorig(i, 9) - uhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.vhat.plus:
FOR i = 1 TO numtripletorig
    tripletorig(i, 1) = tripletorig(i, 1) + vhat(1) * 1 / zoom
    tripletorig(i, 2) = tripletorig(i, 2) + vhat(2) * 1 / zoom
    tripletorig(i, 3) = tripletorig(i, 3) + vhat(3) * 1 / zoom
    tripletorig(i, 4) = tripletorig(i, 4) + vhat(1) * 1 / zoom
    tripletorig(i, 5) = tripletorig(i, 5) + vhat(2) * 1 / zoom
    tripletorig(i, 6) = tripletorig(i, 6) + vhat(3) * 1 / zoom
    tripletorig(i, 7) = tripletorig(i, 7) + vhat(1) * 1 / zoom
    tripletorig(i, 8) = tripletorig(i, 8) + vhat(2) * 1 / zoom
    tripletorig(i, 9) = tripletorig(i, 9) + vhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.vhat.minus:
FOR i = 1 TO numtripletorig
    tripletorig(i, 1) = tripletorig(i, 1) - vhat(1) * 1 / zoom
    tripletorig(i, 2) = tripletorig(i, 2) - vhat(2) * 1 / zoom
    tripletorig(i, 3) = tripletorig(i, 3) - vhat(3) * 1 / zoom
    tripletorig(i, 4) = tripletorig(i, 4) - vhat(1) * 1 / zoom
    tripletorig(i, 5) = tripletorig(i, 5) - vhat(2) * 1 / zoom
    tripletorig(i, 6) = tripletorig(i, 6) - vhat(3) * 1 / zoom
    tripletorig(i, 7) = tripletorig(i, 7) - vhat(1) * 1 / zoom
    tripletorig(i, 8) = tripletorig(i, 8) - vhat(2) * 1 / zoom
    tripletorig(i, 9) = tripletorig(i, 9) - vhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.nhat.plus:
FOR i = 1 TO numtripletorig
    tripletorig(i, 1) = tripletorig(i, 1) + nhat(1) * 1 / zoom
    tripletorig(i, 2) = tripletorig(i, 2) + nhat(2) * 1 / zoom
    tripletorig(i, 3) = tripletorig(i, 3) + nhat(3) * 1 / zoom
    tripletorig(i, 4) = tripletorig(i, 4) + nhat(1) * 1 / zoom
    tripletorig(i, 5) = tripletorig(i, 5) + nhat(2) * 1 / zoom
    tripletorig(i, 6) = tripletorig(i, 6) + nhat(3) * 1 / zoom
    tripletorig(i, 7) = tripletorig(i, 7) + nhat(1) * 1 / zoom
    tripletorig(i, 8) = tripletorig(i, 8) + nhat(2) * 1 / zoom
    tripletorig(i, 9) = tripletorig(i, 9) + nhat(3) * 1 / zoom
NEXT
RETURN

strafe.objects.nhat.minus:
FOR i = 1 TO numtripletorig
    tripletorig(i, 1) = tripletorig(i, 1) - nhat(1) * 1 / zoom
    tripletorig(i, 2) = tripletorig(i, 2) - nhat(2) * 1 / zoom
    tripletorig(i, 3) = tripletorig(i, 3) - nhat(3) * 1 / zoom
    tripletorig(i, 4) = tripletorig(i, 4) - nhat(1) * 1 / zoom
    tripletorig(i, 5) = tripletorig(i, 5) - nhat(2) * 1 / zoom
    tripletorig(i, 6) = tripletorig(i, 6) - nhat(3) * 1 / zoom
    tripletorig(i, 7) = tripletorig(i, 7) - nhat(1) * 1 / zoom
    tripletorig(i, 8) = tripletorig(i, 8) - nhat(2) * 1 / zoom
    tripletorig(i, 9) = tripletorig(i, 9) - nhat(3) * 1 / zoom
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

' *** Define functions for triplet manipulation. ***

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

triplet.filter.faceon:
pcounttripletfaceon = 0
FOR i = 1 TO numtripletorig
    Ax = tripletorig(i, 4) - tripletorig(i, 1)
    Ay = tripletorig(i, 5) - tripletorig(i, 2)
    Az = tripletorig(i, 6) - tripletorig(i, 3)
    Bx = tripletorig(i, 7) - tripletorig(i, 1)
    By = tripletorig(i, 8) - tripletorig(i, 2)
    Bz = tripletorig(i, 9) - tripletorig(i, 3)
    centroidx = (1 / 3) * (tripletorig(i, 1) + tripletorig(i, 4) + tripletorig(i, 7))
    centroidy = (1 / 3) * (tripletorig(i, 2) + tripletorig(i, 5) + tripletorig(i, 8))
    centroidz = (1 / 3) * (tripletorig(i, 3) + tripletorig(i, 6) + tripletorig(i, 9))
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
        pcounttripletfaceon = pcounttripletfaceon + 1
        tripletfaceon(pcounttripletfaceon, 1) = tripletorig(i, 1)
        tripletfaceon(pcounttripletfaceon, 2) = tripletorig(i, 2)
        tripletfaceon(pcounttripletfaceon, 3) = tripletorig(i, 3)
        tripletfaceon(pcounttripletfaceon, 4) = tripletorig(i, 4)
        tripletfaceon(pcounttripletfaceon, 5) = tripletorig(i, 5)
        tripletfaceon(pcounttripletfaceon, 6) = tripletorig(i, 6)
        tripletfaceon(pcounttripletfaceon, 7) = tripletorig(i, 7)
        tripletfaceon(pcounttripletfaceon, 8) = tripletorig(i, 8)
        tripletfaceon(pcounttripletfaceon, 9) = tripletorig(i, 9)
        tripletfaceon(pcounttripletfaceon, 10) = tripletorig(i, 10)
    ELSE
        IF toggleculling = 1 THEN
            pcounttripletfaceon = pcounttripletfaceon + 1
            tripletfaceon(pcounttripletfaceon, 1) = tripletorig(i, 1)
            tripletfaceon(pcounttripletfaceon, 2) = tripletorig(i, 2)
            tripletfaceon(pcounttripletfaceon, 3) = tripletorig(i, 3)
            tripletfaceon(pcounttripletfaceon, 4) = tripletorig(i, 4)
            tripletfaceon(pcounttripletfaceon, 5) = tripletorig(i, 5)
            tripletfaceon(pcounttripletfaceon, 6) = tripletorig(i, 6)
            tripletfaceon(pcounttripletfaceon, 7) = tripletorig(i, 7)
            tripletfaceon(pcounttripletfaceon, 8) = tripletorig(i, 8)
            tripletfaceon(pcounttripletfaceon, 9) = tripletorig(i, 9)
            tripletfaceon(pcounttripletfaceon, 10) = 8
        END IF
    END IF
NEXT
numtripletfaceon = pcounttripletfaceon
RETURN

copy.triplets.faceon.clip:
FOR i = 1 TO numtripletfaceon
    tripletclip(i, 1) = tripletfaceon(i, 1)
    tripletclip(i, 2) = tripletfaceon(i, 2)
    tripletclip(i, 3) = tripletfaceon(i, 3)
    tripletclip(i, 4) = tripletfaceon(i, 4)
    tripletclip(i, 5) = tripletfaceon(i, 5)
    tripletclip(i, 6) = tripletfaceon(i, 6)
    tripletclip(i, 7) = tripletfaceon(i, 7)
    tripletclip(i, 8) = tripletfaceon(i, 8)
    tripletclip(i, 9) = tripletfaceon(i, 9)
    tripletclip(i, 10) = tripletfaceon(i, 10)
NEXT
numtripletclip = numtripletfaceon
RETURN

clip.triplets.viewplanes:
givenplanex = nearplane(1)
givenplaney = nearplane(2)
givenplanez = nearplane(3)
givenplaned = nearplane(4)
GOSUB clip.triplets.givenplane
GOSUB copy.triplets.clipwork.clip
givenplanex = rightplane(1)
givenplaney = rightplane(2)
givenplanez = rightplane(3)
givenplaned = rightplane(4)
GOSUB clip.triplets.givenplane
GOSUB copy.triplets.clipwork.clip
givenplanex = leftplane(1)
givenplaney = leftplane(2)
givenplanez = leftplane(3)
givenplaned = leftplane(4)
GOSUB clip.triplets.givenplane
GOSUB copy.triplets.clipwork.clip
givenplanex = topplane(1)
givenplaney = topplane(2)
givenplanez = topplane(3)
givenplaned = topplane(4)
GOSUB clip.triplets.givenplane
GOSUB copy.triplets.clipwork.clip
givenplanex = bottomplane(1)
givenplaney = bottomplane(2)
givenplanez = bottomplane(3)
givenplaned = bottomplane(4)
GOSUB clip.triplets.givenplane
GOSUB copy.triplets.clipwork.clip
RETURN

clip.triplets.givenplane:
pcounttripletclipwork = 0
FOR i = 1 TO numtripletclip
    tripletclip1dotgivenplane = tripletclip(i, 1) * givenplanex + tripletclip(i, 2) * givenplaney + tripletclip(i, 3) * givenplanez - givenplaned
    tripletclip2dotgivenplane = tripletclip(i, 4) * givenplanex + tripletclip(i, 5) * givenplaney + tripletclip(i, 6) * givenplanez - givenplaned
    tripletclip3dotgivenplane = tripletclip(i, 7) * givenplanex + tripletclip(i, 8) * givenplaney + tripletclip(i, 9) * givenplanez - givenplaned
    gamma12 = tripletclip2dotgivenplane / tripletclip1dotgivenplane
    gamma23 = tripletclip3dotgivenplane / tripletclip2dotgivenplane
    gamma31 = tripletclip1dotgivenplane / tripletclip3dotgivenplane
    A12x = (tripletclip(i, 1) - tripletclip(i, 4)) / (1 - gamma12)
    A12y = (tripletclip(i, 2) - tripletclip(i, 5)) / (1 - gamma12)
    A12z = (tripletclip(i, 3) - tripletclip(i, 6)) / (1 - gamma12)
    B12x = gamma12 * A12x
    B12y = gamma12 * A12y
    B12z = gamma12 * A12z
    A23x = (tripletclip(i, 4) - tripletclip(i, 7)) / (1 - gamma23)
    A23y = (tripletclip(i, 5) - tripletclip(i, 8)) / (1 - gamma23)
    A23z = (tripletclip(i, 6) - tripletclip(i, 9)) / (1 - gamma23)
    B23x = gamma23 * A23x
    B23y = gamma23 * A23y
    B23z = gamma23 * A23z
    A31x = (tripletclip(i, 7) - tripletclip(i, 1)) / (1 - gamma31)
    A31y = (tripletclip(i, 8) - tripletclip(i, 2)) / (1 - gamma31)
    A31z = (tripletclip(i, 9) - tripletclip(i, 3)) / (1 - gamma31)
    B31x = gamma31 * A31x
    B31y = gamma31 * A31y
    B31z = gamma31 * A31z
    A12dotgivenplane = A12x * givenplanex + A12y * givenplaney + A12z * givenplanez
    B12dotgivenplane = B12x * givenplanex + B12y * givenplaney + B12z * givenplanez
    A23dotgivenplane = A23x * givenplanex + A23y * givenplaney + A23z * givenplanez
    B23dotgivenplane = B23x * givenplanex + B23y * givenplaney + B23z * givenplanez
    A31dotgivenplane = A31x * givenplanex + A31y * givenplaney + A31z * givenplanez
    B31dotgivenplane = B31x * givenplanex + B31y * givenplaney + B31z * givenplanez
    IF A12dotgivenplane > 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane > 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 1)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 2)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 3)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 4)
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 5)
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 6)
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 7)
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 8)
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 9)
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
        panelinview = 1
    END IF
    IF A12dotgivenplane > 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane < 0 AND A31dotgivenplane < 0 AND B31dotgivenplane > 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 1)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 2)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 3)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 1) - B31x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 2) - B31y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 3) - B31z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 7) - B23x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 8) - B23y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 9) - B23z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 1)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 2)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 3)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 4)
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 5)
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 6)
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 7) - B23x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 8) - B23y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 9) - B23z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
    END IF
    IF A12dotgivenplane < 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane < 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 7)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 8)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 9)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 1) - B31x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 2) - B31y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 3) - B31z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 4)
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 5)
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 6)
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 4)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 5)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 6)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 1) - B31x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 2) - B31y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 3) - B31z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 4) - B12x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 5) - B12y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 6) - B12z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
    END IF
    IF A12dotgivenplane > 0 AND B12dotgivenplane < 0 AND A23dotgivenplane < 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane > 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 1)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 2)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 3)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 4) - B12x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 5) - B12y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 6) - B12z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 7)
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 8)
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 9)
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 7)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 8)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 9)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 4) - B12x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 5) - B12y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 6) - B12z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 7) - B23x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 8) - B23y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 9) - B23z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
    END IF
    IF A12dotgivenplane > 0 AND B12dotgivenplane < 0 AND A23dotgivenplane < 0 AND B23dotgivenplane < 0 AND A31dotgivenplane < 0 AND B31dotgivenplane > 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 1)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 2)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 3)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 4) - B12x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 5) - B12y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 6) - B12z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 1) - B31x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 2) - B31y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 3) - B31z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
    END IF
    IF A12dotgivenplane < 0 AND B12dotgivenplane > 0 AND A23dotgivenplane > 0 AND B23dotgivenplane < 0 AND A31dotgivenplane < 0 AND B31dotgivenplane < 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 4)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 5)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 6)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 7) - B23x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 8) - B23y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 9) - B23z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 4) - B12x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 5) - B12y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 6) - B12z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
    END IF
    IF A12dotgivenplane < 0 AND B12dotgivenplane < 0 AND A23dotgivenplane < 0 AND B23dotgivenplane > 0 AND A31dotgivenplane > 0 AND B31dotgivenplane < 0 THEN
        pcounttripletclipwork = pcounttripletclipwork + 1
        tripletclipwork(pcounttripletclipwork, 1) = tripletclip(i, 7)
        tripletclipwork(pcounttripletclipwork, 2) = tripletclip(i, 8)
        tripletclipwork(pcounttripletclipwork, 3) = tripletclip(i, 9)
        tripletclipwork(pcounttripletclipwork, 4) = tripletclip(i, 7) - B23x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 5) = tripletclip(i, 8) - B23y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 6) = tripletclip(i, 9) - B23z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 7) = tripletclip(i, 1) - B31x + givenplaned * givenplanex
        tripletclipwork(pcounttripletclipwork, 8) = tripletclip(i, 2) - B31y + givenplaned * givenplaney
        tripletclipwork(pcounttripletclipwork, 9) = tripletclip(i, 3) - B31z + givenplaned * givenplanez
        tripletclipwork(pcounttripletclipwork, 10) = tripletclip(i, 10)
    END IF
NEXT
RETURN

copy.triplets.clipwork.clip:
FOR i = 1 TO pcounttripletclipwork
    tripletclip(i, 1) = tripletclipwork(i, 1)
    tripletclip(i, 2) = tripletclipwork(i, 2)
    tripletclip(i, 3) = tripletclipwork(i, 3)
    tripletclip(i, 4) = tripletclipwork(i, 4)
    tripletclip(i, 5) = tripletclipwork(i, 5)
    tripletclip(i, 6) = tripletclipwork(i, 6)
    tripletclip(i, 7) = tripletclipwork(i, 7)
    tripletclip(i, 8) = tripletclipwork(i, 8)
    tripletclip(i, 9) = tripletclipwork(i, 9)
    tripletclip(i, 10) = tripletclipwork(i, 10)
NEXT
numtripletclip = pcounttripletclipwork
RETURN

copy.triplets.clip.depthsort:
FOR i = 1 TO numtripletclip
    tripletdepthsort(i, 1) = tripletclip(i, 1)
    tripletdepthsort(i, 2) = tripletclip(i, 2)
    tripletdepthsort(i, 3) = tripletclip(i, 3)
    tripletdepthsort(i, 4) = tripletclip(i, 4)
    tripletdepthsort(i, 5) = tripletclip(i, 5)
    tripletdepthsort(i, 6) = tripletclip(i, 6)
    tripletdepthsort(i, 7) = tripletclip(i, 7)
    tripletdepthsort(i, 8) = tripletclip(i, 8)
    tripletdepthsort(i, 9) = tripletclip(i, 9)
    tripletdepthsort(i, 10) = tripletclip(i, 10)
NEXT
numtripletdepthsort = numtripletclip
RETURN

triplets.depthsort.routine:
FOR i = (numtripletdepthsort) TO 1 STEP -1
    FOR j = 1 TO i - 1
        centroidx = (1 / 3) * (tripletdepthsort(j, 1) + tripletdepthsort(j, 4) + tripletdepthsort(j, 7))
        centroidy = (1 / 3) * (tripletdepthsort(j, 2) + tripletdepthsort(j, 5) + tripletdepthsort(j, 8))
        centroidz = (1 / 3) * (tripletdepthsort(j, 3) + tripletdepthsort(j, 6) + tripletdepthsort(j, 9))
        centdepthj0 = centroidx ^ 2 + centroidy ^ 2 + centroidz ^ 2
        centroidx = (1 / 3) * (tripletdepthsort(j + 1, 1) + tripletdepthsort(j + 1, 4) + tripletdepthsort(j + 1, 7))
        centroidy = (1 / 3) * (tripletdepthsort(j + 1, 2) + tripletdepthsort(j + 1, 5) + tripletdepthsort(j + 1, 8))
        centroidz = (1 / 3) * (tripletdepthsort(j + 1, 3) + tripletdepthsort(j + 1, 6) + tripletdepthsort(j + 1, 9))
        centdepthj1 = centroidx ^ 2 + centroidy ^ 2 + centroidz ^ 2
        IF centdepthj0 < centdepthj1 THEN
            temp1 = tripletdepthsort(j, 1)
            temp2 = tripletdepthsort(j, 2)
            temp3 = tripletdepthsort(j, 3)
            temp4 = tripletdepthsort(j, 4)
            temp5 = tripletdepthsort(j, 5)
            temp6 = tripletdepthsort(j, 6)
            temp7 = tripletdepthsort(j, 7)
            temp8 = tripletdepthsort(j, 8)
            temp9 = tripletdepthsort(j, 9)
            temp10 = tripletdepthsort(j, 10)
            tripletdepthsort(j, 1) = tripletdepthsort(j + 1, 1)
            tripletdepthsort(j, 2) = tripletdepthsort(j + 1, 2)
            tripletdepthsort(j, 3) = tripletdepthsort(j + 1, 3)
            tripletdepthsort(j, 4) = tripletdepthsort(j + 1, 4)
            tripletdepthsort(j, 5) = tripletdepthsort(j + 1, 5)
            tripletdepthsort(j, 6) = tripletdepthsort(j + 1, 6)
            tripletdepthsort(j, 7) = tripletdepthsort(j + 1, 7)
            tripletdepthsort(j, 8) = tripletdepthsort(j + 1, 8)
            tripletdepthsort(j, 9) = tripletdepthsort(j + 1, 9)
            tripletdepthsort(j, 10) = tripletdepthsort(j + 1, 10)
            tripletdepthsort(j + 1, 1) = temp1
            tripletdepthsort(j + 1, 2) = temp2
            tripletdepthsort(j + 1, 3) = temp3
            tripletdepthsort(j + 1, 4) = temp4
            tripletdepthsort(j + 1, 5) = temp5
            tripletdepthsort(j + 1, 6) = temp6
            tripletdepthsort(j + 1, 7) = temp7
            tripletdepthsort(j + 1, 8) = temp8
            tripletdepthsort(j + 1, 9) = temp9
            tripletdepthsort(j + 1, 10) = temp10
        END IF
    NEXT
NEXT
RETURN

copy.triplets.depthsort.final:
FOR i = 1 TO numtripletclip
    tripletfinal(i, 1) = tripletdepthsort(i, 1)
    tripletfinal(i, 2) = tripletdepthsort(i, 2)
    tripletfinal(i, 3) = tripletdepthsort(i, 3)
    tripletfinal(i, 4) = tripletdepthsort(i, 4)
    tripletfinal(i, 5) = tripletdepthsort(i, 5)
    tripletfinal(i, 6) = tripletdepthsort(i, 6)
    tripletfinal(i, 7) = tripletdepthsort(i, 7)
    tripletfinal(i, 8) = tripletdepthsort(i, 8)
    tripletfinal(i, 9) = tripletdepthsort(i, 9)
    tripletfinal(i, 10) = tripletdepthsort(i, 10)
NEXT
numtripletfinal = numtripletdepthsort
RETURN

project.triplets:
FOR i = 1 TO numtripletfinal
    tripletfinaldotnhat(i, 1) = tripletfinal(i, 1) * nhat(1) + tripletfinal(i, 2) * nhat(2) + tripletfinal(i, 3) * nhat(3)
    tripletfinaldotnhat(i, 2) = tripletfinal(i, 4) * nhat(1) + tripletfinal(i, 5) * nhat(2) + tripletfinal(i, 6) * nhat(3)
    tripletfinaldotnhat(i, 3) = tripletfinal(i, 7) * nhat(1) + tripletfinal(i, 8) * nhat(2) + tripletfinal(i, 9) * nhat(3)
    tripletfinalpuv(i, 1) = tripletfinal(i, 1) * uhat(1) + tripletfinal(i, 2) * uhat(2) + tripletfinal(i, 3) * uhat(3)
    tripletfinalpuv(i, 2) = tripletfinal(i, 1) * vhat(1) + tripletfinal(i, 2) * vhat(2) + tripletfinal(i, 3) * vhat(3)
    tripletfinalpuv(i, 3) = tripletfinal(i, 4) * uhat(1) + tripletfinal(i, 5) * uhat(2) + tripletfinal(i, 6) * uhat(3)
    tripletfinalpuv(i, 4) = tripletfinal(i, 4) * vhat(1) + tripletfinal(i, 5) * vhat(2) + tripletfinal(i, 6) * vhat(3)
    tripletfinalpuv(i, 5) = tripletfinal(i, 7) * uhat(1) + tripletfinal(i, 8) * uhat(2) + tripletfinal(i, 9) * uhat(3)
    tripletfinalpuv(i, 6) = tripletfinal(i, 7) * vhat(1) + tripletfinal(i, 8) * vhat(2) + tripletfinal(i, 9) * vhat(3)
NEXT
RETURN

depth.adjust.triplets:
FOR i = 1 TO numtripletfinal
    tripletfinalpuvs(i, 1) = tripletfinalpuv(i, 1) * fovd / tripletfinaldotnhat(i, 1)
    tripletfinalpuvs(i, 2) = tripletfinalpuv(i, 2) * fovd / tripletfinaldotnhat(i, 1)
    tripletfinalpuvs(i, 3) = tripletfinalpuv(i, 3) * fovd / tripletfinaldotnhat(i, 2)
    tripletfinalpuvs(i, 4) = tripletfinalpuv(i, 4) * fovd / tripletfinaldotnhat(i, 2)
    tripletfinalpuvs(i, 5) = tripletfinalpuv(i, 5) * fovd / tripletfinaldotnhat(i, 3)
    tripletfinalpuvs(i, 6) = tripletfinalpuv(i, 6) * fovd / tripletfinaldotnhat(i, 3)
NEXT
RETURN

draw.all.objects:
GOSUB plotmode.3denvtriplets
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
COLOR 14
LOCATE 26, 2: PRINT "- MOVE -"
COLOR 15
LOCATE 27, 2: PRINT " q W e"
LOCATE 28, 2: PRINT " A S D"
COLOR 14
LOCATE 25, 68: PRINT "-   VIEW   -"
COLOR 15
LOCATE 26, 68: PRINT "  8  "
LOCATE 27, 68: PRINT "4   6"
LOCATE 28, 68: PRINT "  2  "
COLOR 7
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
numtripletfinal.old = numtripletfinal
RETURN

' *** Define functions for plot modes. ***

plotmode.3denvtriplets:
hudflagtemp = -1
redoplot:
CLS
FOR i = 1 TO numtripletfinal
    ' Draw new graphics.
    x = zoom * tripletfinalpuvs(i, 1): y = zoom * tripletfinalpuvs(i, 2)
    'x1 = x: y1 = y
    GOSUB convert
    u1 = x: v1 = y
    x = zoom * tripletfinalpuvs(i, 3): y = zoom * tripletfinalpuvs(i, 4)
    'x2 = x: y2 = y
    GOSUB convert
    u2 = x: v2 = y
    x = zoom * tripletfinalpuvs(i, 5): y = zoom * tripletfinalpuvs(i, 6)
    'x3 = x: y3 = y
    GOSUB convert
    u3 = x: v3 = y
    LINE (u1, v1)-(u2, v2), 15
    LINE (u2, v2)-(u3, v3), 15
    LINE (u3, v3)-(u1, v1), 15
    centu = (1 / 3) * (u1 + u2 + u3)
    centv = (1 / 3) * (v1 + v2 + v3)
    IF togglehud = 1 THEN
        ' Paint triangles.
        PAINT (centu, centv), tripletfinal(i, 10), 15

        'Very hacky bug detection.
        'Check if the unused pixel at 1,1 has color.
        IF SCREEN(1, 1) <> bgcol THEN
            hudflagtemp = 1
            togglehud = -1
            GOTO redoplot
        END IF

    END IF
    LINE (u1, v1)-(u2, v2), tripletfinal(i, 10)
    LINE (u2, v2)-(u3, v3), tripletfinal(i, 10)
    LINE (u3, v3)-(u1, v1), tripletfinal(i, 10)
NEXT
IF hudflagtemp = 1 THEN
    togglehud = 1
END IF
RETURN

' *** Define functions for generation schemes. ***

genscheme.3denvtriplets:
pcounttripletorig = 0
'cubes
cubesidelength = 5
cubecenterx = 40: cubecentery = 0: cubecenterz = -25: GOSUB genscheme.3denvtriplets.makecube
cubecenterx = 20: cubecentery = 15: cubecenterz = -15: GOSUB genscheme.3denvtriplets.makecube
cubecenterx = 0: cubecentery = 0: cubecenterz = -15: GOSUB genscheme.3denvtriplets.makecube
'panels
panelsidelength = 5
panel1color = INT(RND * 14) + 1
panel2color = INT(RND * 14) + 1
panelcenterx = 0: panelcentery = 0: panelcenterz = -50
'GOSUB genscheme.3denvtriplets.makecheckerpanel
RETURN

genscheme.3denvtriplets.makecheckerpanel:
FOR i = -panelsidelength * 10 TO panelsidelength * 10 STEP 2 * panelsidelength
    FOR j = -panelsidelength * 10 TO panelsidelength * 10 STEP 2 * panelsidelength
        basepointx = panelcenterx - panelsidelength + i
        basepointy = panelcentery + panelsidelength + j
        basepointz = panelcenterz + panelsidelength
        rightpointx = panelcenterx - panelsidelength + i
        rightpointy = panelcentery - panelsidelength + j
        rightpointz = panelcenterz + panelsidelength
        leftpointx = panelcenterx + panelsidelength + i
        leftpointy = panelcentery + panelsidelength + j
        leftpointz = panelcenterz + panelsidelength
        panelcolor = panel1color
        GOSUB create.original.triangle
        basepointx = panelcenterx + panelsidelength + i
        basepointy = panelcentery + panelsidelength + j
        basepointz = panelcenterz + panelsidelength
        rightpointx = panelcenterx - panelsidelength + i
        rightpointy = panelcentery - panelsidelength + j
        rightpointz = panelcenterz + panelsidelength
        leftpointx = panelcenterx + panelsidelength + i
        leftpointy = panelcentery - panelsidelength + j
        leftpointz = panelcenterz + panelsidelength
        panelcolor = panel2color
        GOSUB create.original.triangle
    NEXT
NEXT
RETURN

genscheme.3denvtriplets.makecube:
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz - cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.triangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz - cubesidelength
GOSUB create.original.triangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.triangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
GOSUB create.original.triangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery - cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.triangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery - cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
GOSUB create.original.triangle
basepointx = cubecenterx - cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz + cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.triangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery - cubesidelength
rightpointz = cubecenterz + cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
GOSUB create.original.triangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery - cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery + cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery - cubesidelength
leftpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.triangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery - cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx + cubesidelength
rightpointy = cubecentery + cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
GOSUB create.original.triangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz - cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery + cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx + cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
panelcolor = INT(RND * 14) + 1
GOSUB create.original.triangle
basepointx = cubecenterx + cubesidelength
basepointy = cubecentery + cubesidelength
basepointz = cubecenterz + cubesidelength
rightpointx = cubecenterx - cubesidelength
rightpointy = cubecentery + cubesidelength
rightpointz = cubecenterz - cubesidelength
leftpointx = cubecenterx - cubesidelength
leftpointy = cubecentery + cubesidelength
leftpointz = cubecenterz + cubesidelength
GOSUB create.original.triangle
RETURN

create.original.triangle:
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
pcounttripletorig = pcounttripletorig + 1
tripletorig(pcounttripletorig, 1) = basepointx
tripletorig(pcounttripletorig, 2) = basepointy
tripletorig(pcounttripletorig, 3) = basepointz
tripletorig(pcounttripletorig, 4) = rightpointx
tripletorig(pcounttripletorig, 5) = rightpointy
tripletorig(pcounttripletorig, 6) = rightpointz
tripletorig(pcounttripletorig, 7) = leftpointx
tripletorig(pcounttripletorig, 8) = leftpointy
tripletorig(pcounttripletorig, 9) = leftpointz
tripletorig(pcounttripletorig, 10) = panelcolor
RETURN
