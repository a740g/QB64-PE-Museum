'$EXEICON:'sanctum.ico'
'REM $include:'Color32.BI'

Const Aquamarine = _RGB32(127, 255, 212)
Const Blue = _RGB32(0, 0, 255)
Const BlueViolet = _RGB32(138, 43, 226)
Const Chocolate = _RGB32(210, 105, 30)
Const Cyan = _RGB32(0, 255, 255)
Const DarkBlue = _RGB32(0, 0, 139)
Const DarkGoldenRod = _RGB32(184, 134, 11)
Const DarkGray = _RGB32(169, 169, 169)
Const DarkKhaki = _RGB32(189, 183, 107)
Const DeepPink = _RGB32(255, 20, 147)
Const DodgerBlue = _RGB32(30, 144, 255)
Const ForestGreen = _RGB32(34, 139, 34)
Const Gray = _RGB32(128, 128, 128)
Const Green = _RGB32(0, 128, 0)
Const Indigo = _RGB32(75, 0, 130)
Const Ivory = _RGB32(255, 255, 240)
Const LightSeaGreen = _RGB32(32, 178, 170)
Const LimeGreen = _RGB32(50, 205, 50)
Const Magenta = _RGB32(255, 0, 255)
Const PaleGoldenRod = _RGB32(238, 232, 170)
Const Red = _RGB32(255, 0, 0)
Const RoyalBlue = _RGB32(65, 105, 225)
Const SaddleBrown = _RGB32(139, 69, 19)
Const Sienna = _RGB32(160, 82, 45)
Const SlateGray = _RGB32(112, 128, 144)
Const Snow = _RGB32(255, 250, 250)
Const Sunglow = _RGB32(255, 207, 72)
Const SunsetOrange = _RGB32(253, 94, 83)
Const Teal = _RGB32(0, 128, 128)
Const White = _RGB32(255, 255, 255)
Const Yellow = _RGB32(255, 255, 0)

' Constants.
pi = 3.1415926536
ee = 2.7182818285

' Scale.
Dim bignumber As Long
bignumber = 3000000

' Video.
'SCREEN _NEWIMAGE(640, 480, 32)
Screen _NewImage(800, 600, 32)
'SCREEN _NEWIMAGE(1024, 768, 32)
_FullScreen
_MouseHide
screenwidth = _Width
screenheight = _Height

' Camera orientation vectors.
Dim uhat(3), vhat(3), nhat(3)

' Basis vectors defined in three-space.
Dim xhat(3), yhat(3), zhat(3)
xhat(1) = 1: xhat(2) = 0: xhat(3) = 0
yhat(1) = 0: yhat(2) = 1: yhat(3) = 0
zhat(1) = 0: zhat(2) = 0: zhat(3) = 1

' Group structure.
Type VectorGroupElement
    Identity As Long
    Pointer As Long
    Lagger As Long
    FirstVector As Long
    LastVector As Long
    GroupName As String * 50
    Visible As Integer
    ForceAnimate As Integer
    COMFixed As Integer
    COMx As Single ' Center of mass
    COMy As Single
    COMz As Single
    ROTx As Single ' Center of rotation
    ROTy As Single
    ROTz As Single
    REVx As Single ' Revolution speed
    REVy As Single
    REVz As Single
    DIMx As Single ' Maximum volume
    DIMy As Single
    DIMz As Single
End Type
Dim VectorGroup(bignumber) As VectorGroupElement

' World vectors.
Dim vec(bignumber, 3) ' Relative Position
Dim vec3Dpos(bignumber, 3) ' Position
Dim vec3Dvel(bignumber, 3) ' Linear velocity
Dim vec3Dacc(bignumber, 3) ' Linear acceleration
Dim vec3Danv(bignumber, 3) ' Angular velocity
Dim vec3Dvis(bignumber) ' Visible toggle
Dim vec2D(bignumber, 2) ' Projection onto 2D plane
Dim vec3Dcolor(bignumber) As Long ' Original color
Dim vec2Dcolor(bignumber) As Long ' Projected color

' Clipping planes.
Dim nearplane(4), farplane(4), rightplane(4), leftplane(4), topplane(4), bottomplane(4)

' State.
Randomize Timer
nearplane(4) = 1
farplane(4) = -100
rightplane(4) = 0 '*' fovd * (nhat(1) * rightplane(1) + nhat(2) * rightplane(2) + nhat(3) * rightplane(3))
leftplane(4) = 0
topplane(4) = 0
bottomplane(4) = 0
midscreenx = screenwidth / 2
midscreeny = screenheight / 2
fovd = -256
numgroupvisible = 0
numvectorvisible = 0
groupidticker = 0
vecgroupid = 0
vectorindex = 0
rotspeed = 1 / 33
linspeed = 3 / 2
timestep = .001
camx = -40
camy = 30
camz = 40
uhat(1) = -.2078192: uhat(2) = -.9781672: uhat(3) = 0
vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
toggletimeanimate = 1
toggleinvertmouse = -1
togglehud = 1

' Prime main loop.
GoSub initialize.objects
GoSub redraw

' Begin main loop.
fpstimer = Int(Timer)
fps = 0
Do
    GoSub redraw
    GoSub mouseprocess
    GoSub keyprocess

    fps = fps + 1
    tt = Int(Timer)
    If tt = fpstimer + 1 Then
        fpstimer = tt
        fpsreport = fps
        fps = 0
    End If

    _Display
    _KeyClear
    _Limit 30
Loop

System

' Gosubs.

redraw:
GoSub normalize.screen.vectors
GoSub calculate.clippingplanes
GoSub compute.visible.groups
GoSub plot.visible.vectors
Return

mouseprocess:
'mx = 0
'my = 0
'DO WHILE _MOUSEINPUT
'    mx = mx + _MOUSEMOVEMENTX
'    my = my + _MOUSEMOVEMENTY
'    IF _MOUSEWHEEL > 0 THEN GOSUB rotate.clockwise
'    IF _MOUSEWHEEL < 0 THEN GOSUB rotate.counterclockwise
'    IF mx > 0 THEN
'        GOSUB rotate.uhat.plus: GOSUB normalize.screen.vectors
'    END IF
'    IF mx < 0 THEN
'        GOSUB rotate.uhat.minus: GOSUB normalize.screen.vectors
'    END IF
'    IF my > 0 THEN
'        IF toggleinvertmouse = -1 THEN
'            GOSUB rotate.vhat.plus: GOSUB normalize.screen.vectors
'        ELSE
'            GOSUB rotate.vhat.minus: GOSUB normalize.screen.vectors
'        END IF
'    END IF
'    IF my < 0 THEN
'        IF toggleinvertmouse = -1 THEN
'            GOSUB rotate.vhat.minus: GOSUB normalize.screen.vectors
'        ELSE
'            GOSUB rotate.vhat.plus: GOSUB normalize.screen.vectors
'        END IF
'    END IF
'    mx = 0
'    my = 0
'LOOP
Return

keyprocess:
If _KeyDown(119) = -1 Or _KeyDown(18432) = -1 Then GoSub strafe.camera.nhat.minus ' w or uparrow
If _KeyDown(115) = -1 Or _KeyDown(20480) = -1 Then GoSub strafe.camera.nhat.plus ' s or downarrow
If _KeyDown(97) = -1 Then GoSub strafe.camera.uhat.minus ' a
If _KeyDown(100) = -1 Then GoSub strafe.camera.uhat.plus ' d
If _KeyDown(56) = -1 Then GoSub rotate.vhat.plus: GoSub normalize.screen.vectors ' 8
If _KeyDown(50) = -1 Then GoSub rotate.vhat.minus: GoSub normalize.screen.vectors ' 2
If _KeyDown(19200) = -1 Or _KeyDown(52) = -1 Then GoSub rotate.uhat.minus: GoSub normalize.screen.vectors ' 4
If _KeyDown(19712) = -1 Or _KeyDown(54) = -1 Then GoSub rotate.uhat.plus: GoSub normalize.screen.vectors ' 6
If _KeyDown(55) = -1 Then GoSub rotate.clockwise ' 7
If _KeyDown(57) = -1 Then GoSub rotate.counterclockwise ' 9
If _KeyDown(49) = -1 Then GoSub rotate.uhat.minus: GoSub normalize.screen.vectors: GoSub rotate.clockwise ' 1
If _KeyDown(51) = -1 Then GoSub rotate.uhat.plus: GoSub normalize.screen.vectors: GoSub rotate.counterclockwise ' 3
If _KeyDown(113) = -1 Then GoSub strafe.camera.vhat.minus ' q
If _KeyDown(101) = -1 Then GoSub strafe.camera.vhat.plus ' e

key$ = InKey$
If (key$ <> "") Then
    Select Case key$
        Case "x"
            uhat(1) = 0: uhat(2) = 1: uhat(3) = 0
            vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
        Case "X"
            uhat(1) = 0: uhat(2) = -1: uhat(3) = 0
            vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
        Case "y"
            uhat(1) = -1: uhat(2) = 0: uhat(3) = 0
            vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
        Case "Y"
            uhat(1) = 1: uhat(2) = 0: uhat(3) = 0
            vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
        Case "z"
            uhat(1) = 1: uhat(2) = 0: uhat(3) = 0
            vhat(1) = 0: vhat(2) = 1: vhat(3) = 0
            GoSub normalize.screen.vectors
        Case "Z"
            uhat(1) = 0: uhat(2) = 1: uhat(3) = 0
            vhat(1) = 1: vhat(2) = 0: vhat(3) = 0
        Case "]"
            farplane(4) = farplane(4) - 1
        Case "["
            farplane(4) = farplane(4) + 1
        Case " "
            togglehud = -togglehud
        Case "t"
            toggletimeanimate = -toggletimeanimate
        Case "i"
            toggleinvertmouse = -toggleinvertmouse
        Case "v"
            Open "snapshot-camera.txt" For Output As #1
            Print #1, camx, camy, camz
            Print #1, uhat(1), uhat(2), uhat(3)
            Print #1, vhat(1), vhat(2), vhat(3)
            Close #1
        Case Chr$(27)
            System
        Case "n"
            VectorGroup(closestgroup).COMFixed = 1
            For vectorindex = VectorGroup(closestgroup).FirstVector To VectorGroup(closestgroup).LastVector
                vec3Dvel(vectorindex, 1) = (Rnd - .5) * 200
                vec3Dvel(vectorindex, 2) = (Rnd - .5) * 200
                vec3Dvel(vectorindex, 3) = (Rnd - .5) * 200
            Next
        Case "k"
            p = VectorGroup(closestgroup).Pointer
            l = VectorGroup(closestgroup).Lagger
            VectorGroup(l).Pointer = p
            If (p <> -999) Then
                VectorGroup(p).Lagger = l
            End If
        Case "b"
            tilesize = 5
            ' Determine last object id.
            p = 1
            Do
                k = VectorGroup(p).Identity
                p = VectorGroup(k).Pointer
                If (p = -999) Then Exit Do
            Loop
            lastobjectid = k
            vectorindex = VectorGroup(lastobjectid).LastVector
            ' Create new group.
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = -999
            VectorGroup(vecgroupid).Lagger = lastobjectid
            VectorGroup(vecgroupid).GroupName = "Block"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = tilesize / 2
            VectorGroup(vecgroupid).DIMy = tilesize / 2
            VectorGroup(vecgroupid).DIMz = tilesize / 2
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For r = 1 To 400
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = camx + -20 * nhat(1) + (Rnd - .5) * tilesize
                vec3Dpos(vectorindex, 2) = camy + -20 * nhat(2) + (Rnd - .5) * tilesize
                vec3Dpos(vectorindex, 3) = camz + -20 * nhat(3) + (Rnd - .5) * tilesize
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = Lime
                Else
                    vec3Dcolor(vectorindex) = Purple
                End If
                GoSub integratecom
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
            VectorGroup(lastobjectid).Pointer = vecgroupid
    End Select
End If
Return

convert:
' Convert graphics from uv-cartesian coordinates to monitor coordinates.
x0 = x: y0 = y
x = x0 + midscreenx
y = -y0 + midscreeny
Return

rotate.uhat.plus:
uhat(1) = uhat(1) + nhat(1) * rotspeed
uhat(2) = uhat(2) + nhat(2) * rotspeed
uhat(3) = uhat(3) + nhat(3) * rotspeed
Return

rotate.uhat.minus:
uhat(1) = uhat(1) - nhat(1) * rotspeed
uhat(2) = uhat(2) - nhat(2) * rotspeed
uhat(3) = uhat(3) - nhat(3) * rotspeed
Return

rotate.vhat.plus:
vhat(1) = vhat(1) + nhat(1) * rotspeed
vhat(2) = vhat(2) + nhat(2) * rotspeed
vhat(3) = vhat(3) + nhat(3) * rotspeed
Return

rotate.vhat.minus:
vhat(1) = vhat(1) - nhat(1) * rotspeed
vhat(2) = vhat(2) - nhat(2) * rotspeed
vhat(3) = vhat(3) - nhat(3) * rotspeed
Return

rotate.counterclockwise:
v1 = vhat(1)
v2 = vhat(2)
v3 = vhat(3)
vhat(1) = vhat(1) + uhat(1) * rotspeed
vhat(2) = vhat(2) + uhat(2) * rotspeed
vhat(3) = vhat(3) + uhat(3) * rotspeed
uhat(1) = uhat(1) - v1 * rotspeed
uhat(2) = uhat(2) - v2 * rotspeed
uhat(3) = uhat(3) - v3 * rotspeed
Return

rotate.clockwise:
v1 = vhat(1)
v2 = vhat(2)
v3 = vhat(3)
vhat(1) = vhat(1) - uhat(1) * rotspeed
vhat(2) = vhat(2) - uhat(2) * rotspeed
vhat(3) = vhat(3) - uhat(3) * rotspeed
uhat(1) = uhat(1) + v1 * rotspeed
uhat(2) = uhat(2) + v2 * rotspeed
uhat(3) = uhat(3) + v3 * rotspeed
Return

strafe.camera.uhat.plus:
camx = camx + uhat(1) * linspeed
camy = camy + uhat(2) * linspeed
camz = camz + uhat(3) * linspeed
Return

strafe.camera.uhat.minus:
camx = camx - uhat(1) * linspeed
camy = camy - uhat(2) * linspeed
camz = camz - uhat(3) * linspeed
Return

strafe.camera.vhat.plus:
camx = camx + vhat(1) * linspeed
camy = camy + vhat(2) * linspeed
camz = camz + vhat(3) * linspeed
Return

strafe.camera.vhat.minus:
camx = camx - vhat(1) * linspeed
camy = camy - vhat(2) * linspeed
camz = camz - vhat(3) * linspeed
Return

strafe.camera.nhat.plus:
camx = camx + nhat(1) * linspeed
camy = camy + nhat(2) * linspeed
camz = camz + nhat(3) * linspeed
Return

strafe.camera.nhat.minus:
camx = camx - nhat(1) * linspeed
camy = camy - nhat(2) * linspeed
camz = camz - nhat(3) * linspeed
Return

normalize.screen.vectors:
uhatmag = Sqr(uhat(1) * uhat(1) + uhat(2) * uhat(2) + uhat(3) * uhat(3))
uhat(1) = uhat(1) / uhatmag: uhat(2) = uhat(2) / uhatmag: uhat(3) = uhat(3) / uhatmag
vhatmag = Sqr(vhat(1) * vhat(1) + vhat(2) * vhat(2) + vhat(3) * vhat(3))
vhat(1) = vhat(1) / vhatmag: vhat(2) = vhat(2) / vhatmag: vhat(3) = vhat(3) / vhatmag
uhatdotvhat = uhat(1) * vhat(1) + uhat(2) * vhat(2) + uhat(3) * vhat(3)
' The normal vector points toward the eye.
nhat(1) = uhat(2) * vhat(3) - uhat(3) * vhat(2)
nhat(2) = uhat(3) * vhat(1) - uhat(1) * vhat(3)
nhat(3) = uhat(1) * vhat(2) - uhat(2) * vhat(1)
nhatmag = Sqr(nhat(1) * nhat(1) + nhat(2) * nhat(2) + nhat(3) * nhat(3))
nhat(1) = nhat(1) / nhatmag: nhat(2) = nhat(2) / nhatmag: nhat(3) = nhat(3) / nhatmag
Return

calculate.clippingplanes:
' Calculate normal vectors to all clipping planes.
h2 = screenheight / 2
w2 = screenwidth / 2
nearplane(1) = -nhat(1)
nearplane(2) = -nhat(2)
nearplane(3) = -nhat(3)
farplane(1) = nhat(1)
farplane(2) = nhat(2)
farplane(3) = nhat(3)
rightplane(1) = h2 * fovd * uhat(1) - h2 * w2 * nhat(1)
rightplane(2) = h2 * fovd * uhat(2) - h2 * w2 * nhat(2)
rightplane(3) = h2 * fovd * uhat(3) - h2 * w2 * nhat(3)
mag = Sqr(rightplane(1) * rightplane(1) + rightplane(2) * rightplane(2) + rightplane(3) * rightplane(3))
rightplane(1) = rightplane(1) / mag
rightplane(2) = rightplane(2) / mag
rightplane(3) = rightplane(3) / mag
leftplane(1) = -h2 * fovd * uhat(1) - h2 * w2 * nhat(1)
leftplane(2) = -h2 * fovd * uhat(2) - h2 * w2 * nhat(2)
leftplane(3) = -h2 * fovd * uhat(3) - h2 * w2 * nhat(3)
mag = Sqr(leftplane(1) * leftplane(1) + leftplane(2) * leftplane(2) + leftplane(3) * leftplane(3))
leftplane(1) = leftplane(1) / mag
leftplane(2) = leftplane(2) / mag
leftplane(3) = leftplane(3) / mag
topplane(1) = w2 * fovd * vhat(1) - h2 * w2 * nhat(1)
topplane(2) = w2 * fovd * vhat(2) - h2 * w2 * nhat(2)
topplane(3) = w2 * fovd * vhat(3) - h2 * w2 * nhat(3)
mag = Sqr(topplane(1) * topplane(1) + topplane(2) * topplane(2) + topplane(3) * topplane(3))
topplane(1) = topplane(1) / mag
topplane(2) = topplane(2) / mag
topplane(3) = topplane(3) / mag
bottomplane(1) = -w2 * fovd * vhat(1) - h2 * w2 * nhat(1)
bottomplane(2) = -w2 * fovd * vhat(2) - h2 * w2 * nhat(2)
bottomplane(3) = -w2 * fovd * vhat(3) - h2 * w2 * nhat(3)
mag = Sqr(bottomplane(1) * bottomplane(1) + bottomplane(2) * bottomplane(2) + bottomplane(3) * bottomplane(3))
bottomplane(1) = bottomplane(1) / mag
bottomplane(2) = bottomplane(2) / mag
bottomplane(3) = bottomplane(3) / mag
Return

compute.visible.groups:
closestdist2 = 10000000
closestgroup = 1
fp42 = farplane(4) * farplane(4)

k = 1
k = VectorGroup(k).Identity
Do ' iterates k

    VectorGroup(k).Visible = 0

    dx = VectorGroup(k).COMx - camx
    dy = VectorGroup(k).COMy - camy
    dz = VectorGroup(k).COMz - camz

    dist2 = dx * dx + dy * dy + dz * dz

    If dist2 < fp42 Then

        groupinview = 1
        If dx * nearplane(1) + dy * nearplane(2) + dz * nearplane(3) - nearplane(4) < 0 Then groupinview = 0
        'IF dx * farplane(1) + dy * farplane(2) + dz * farplane(3) - farplane(4) < 0 THEN groupinview = 0
        If dx * rightplane(1) + dy * rightplane(2) + dz * rightplane(3) - rightplane(4) < 0 Then groupinview = 0
        If dx * leftplane(1) + dy * leftplane(2) + dz * leftplane(3) - leftplane(4) < 0 Then groupinview = 0
        If dx * topplane(1) + dy * topplane(2) + dz * topplane(3) - topplane(4) < 0 Then groupinview = 0
        If dx * bottomplane(1) + dy * bottomplane(2) + dz * bottomplane(3) - bottomplane(4) < 0 Then groupinview = 0
        If groupinview = 1 Then

            If (dist2 < closestdist2) Then
                closestdist2 = dist2
                closestgroup = k
            End If

            VectorGroup(k).Visible = 1

            If (toggletimeanimate = 1) Then
                vecgroupid = k
                GoSub timeanimate
            End If

            For i = VectorGroup(k).FirstVector To VectorGroup(k).LastVector
                GoSub clip.project.vectors
            Next

        Else
            ' Force animation regardless of clipping.
            If (VectorGroup(k).ForceAnimate = 1) Then
                vecgroupid = k
                GoSub timeanimate
            End If
        End If
    Else
        ' Force animation regardless of distance from camera.
        If (VectorGroup(k).ForceAnimate = 1) Then
            vecgroupid = k
            GoSub timeanimate
        End If
    End If
    k = VectorGroup(k).Pointer
    If k = -999 Then Exit Do
    k = VectorGroup(k).Identity
Loop
Return

clip.project.vectors: ' requires i
vec(i, 1) = vec3Dpos(i, 1) - camx
vec(i, 2) = vec3Dpos(i, 2) - camy
vec(i, 3) = vec3Dpos(i, 3) - camz
fogswitch = -1
vec3Dvis(i) = 0
vectorinview = 1
' Perform view plane clipping.
If vec(i, 1) * nearplane(1) + vec(i, 2) * nearplane(2) + vec(i, 3) * nearplane(3) - nearplane(4) < 0 Then vectorinview = 0
If vec(i, 1) * farplane(1) + vec(i, 2) * farplane(2) + vec(i, 3) * farplane(3) - farplane(4) < 0 Then vectorinview = 0
If vec(i, 1) * farplane(1) + vec(i, 2) * farplane(2) + vec(i, 3) * farplane(3) - farplane(4) * .85 < 0 Then fogswitch = 1
If vec(i, 1) * rightplane(1) + vec(i, 2) * rightplane(2) + vec(i, 3) * rightplane(3) - rightplane(4) < 0 Then vectorinview = 0
If vec(i, 1) * leftplane(1) + vec(i, 2) * leftplane(2) + vec(i, 3) * leftplane(3) - leftplane(4) < 0 Then vectorinview = 0
If vec(i, 1) * topplane(1) + vec(i, 2) * topplane(2) + vec(i, 3) * topplane(3) - topplane(4) < 0 Then vectorinview = 0
If vec(i, 1) * bottomplane(1) + vec(i, 2) * bottomplane(2) + vec(i, 3) * bottomplane(3) - bottomplane(4) < 0 Then vectorinview = 0
If vectorinview = 1 Then
    vec3Dvis(i) = 1
    ' Project vectors onto the screen plane.
    vec3Ddotnhat = vec(i, 1) * nhat(1) + vec(i, 2) * nhat(2) + vec(i, 3) * nhat(3)
    vec2D(i, 1) = (vec(i, 1) * uhat(1) + vec(i, 2) * uhat(2) + vec(i, 3) * uhat(3)) * fovd / vec3Ddotnhat
    vec2D(i, 2) = (vec(i, 1) * vhat(1) + vec(i, 2) * vhat(2) + vec(i, 3) * vhat(3)) * fovd / vec3Ddotnhat
    If fogswitch = 1 Then vec2Dcolor(i) = Gray Else vec2Dcolor(i) = vec3Dcolor(i)
End If
Return

timeanimate: ' requires vecgroupid
dt = timestep

xcom = VectorGroup(vecgroupid).COMx
ycom = VectorGroup(vecgroupid).COMy
zcom = VectorGroup(vecgroupid).COMz
xrot = VectorGroup(vecgroupid).ROTx
yrot = VectorGroup(vecgroupid).ROTy
zrot = VectorGroup(vecgroupid).ROTz
xrev = VectorGroup(vecgroupid).ROTx
yrev = VectorGroup(vecgroupid).ROTy
zrev = VectorGroup(vecgroupid).ROTz
xdim = VectorGroup(vecgroupid).DIMx
ydim = VectorGroup(vecgroupid).DIMy
zdim = VectorGroup(vecgroupid).DIMz

If (VectorGroup(vecgroupid).COMFixed = 0) Then GoSub resetcom

For vectorindex = VectorGroup(vecgroupid).FirstVector To VectorGroup(vecgroupid).LastVector

    ' Linear velocity update
    ax = vec3Dacc(vectorindex, 1)
    ay = vec3Dacc(vectorindex, 2)
    az = vec3Dacc(vectorindex, 3)
    If (ax <> 0) Then vec3Dvel(vectorindex, 1) = vec3Dvel(vectorindex, 1) + ax * dt
    If (ay <> 0) Then vec3Dvel(vectorindex, 2) = vec3Dvel(vectorindex, 2) + ay * dt
    If (az <> 0) Then vec3Dvel(vectorindex, 3) = vec3Dvel(vectorindex, 3) + az * dt

    ' Linear position update with periodic boundaries inside group dimension
    vx = vec3Dvel(vectorindex, 1)
    vy = vec3Dvel(vectorindex, 2)
    vz = vec3Dvel(vectorindex, 3)
    If (vx <> 0) Then
        px = vec3Dpos(vectorindex, 1) + vx * dt
        If Abs(px - xcom) > xdim Then
            If (px > xcom) Then
                px = xcom - xdim
            Else
                px = xcom + xdim
            End If
        End If
        vec3Dpos(vectorindex, 1) = px
    End If
    If (vy <> 0) Then
        py = vec3Dpos(vectorindex, 2) + vy * dt
        If Abs(py - ycom) > ydim Then
            If (py > ycom) Then
                py = ycom - ydim
            Else
                py = ycom + ydim
            End If
        End If
        vec3Dpos(vectorindex, 2) = py
    End If
    If (vz <> 0) Then
        pz = vec3Dpos(vectorindex, 3) + vz * dt
        If Abs(pz - zcom) > zdim Then
            If (pz > zcom) Then
                pz = zcom - zdim
            Else
                pz = zcom + zdim
            End If
        End If
        vec3Dpos(vectorindex, 3) = pz
    End If

    ' Rotation update
    If (xrot <> 0) Then
        anv = vec3Danv(vectorindex, 1)
        yy = vec3Dpos(vectorindex, 2) - yrot
        zz = vec3Dpos(vectorindex, 3) - zrot
        y = yy * Cos(timestep * anv) - zz * Sin(timestep * anv)
        z = yy * Sin(timestep * anv) + zz * Cos(timestep * anv)
        vec3Dpos(vectorindex, 2) = y + yrot
        vec3Dpos(vectorindex, 3) = z + zrot
    End If
    If (yrot <> 0) Then
        anv = vec3Danv(vectorindex, 2)
        xx = vec3Dpos(vectorindex, 1) - xrot
        zz = vec3Dpos(vectorindex, 3) - zrot
        x = xx * Cos(timestep * anv) + zz * Sin(timestep * anv)
        z = -xx * Sin(timestep * anv) + zz * Cos(timestep * anv)
        vec3Dpos(vectorindex, 1) = x + xrot
        vec3Dpos(vectorindex, 3) = z + zrot
    End If
    If (zrot <> 0) Then
        anv = vec3Danv(vectorindex, 3)
        xx = vec3Dpos(vectorindex, 1) - xrot
        yy = vec3Dpos(vectorindex, 2) - yrot
        x = xx * Cos(timestep * anv) - yy * Sin(timestep * anv)
        y = xx * Sin(timestep * anv) + yy * Cos(timestep * anv)
        vec3Dpos(vectorindex, 1) = x + xrot
        vec3Dpos(vectorindex, 2) = y + yrot
    End If

    ' Revolution update
    If (xrev <> 0) Then
        anv = xrev
        yy = vec3Dpos(vectorindex, 2) - ycom
        zz = vec3Dpos(vectorindex, 3) - zcom
        y = yy * Cos(timestep * anv) - zz * Sin(timestep * anv)
        z = yy * Sin(timestep * anv) + zz * Cos(timestep * anv)
        vec3Dpos(vectorindex, 2) = y + ycom
        vec3Dpos(vectorindex, 3) = z + zcom
    End If
    If (yrev <> 0) Then
        anv = yrev
        xx = vec3Dpos(vectorindex, 1) - xcom
        zz = vec3Dpos(vectorindex, 3) - zcom
        x = xx * Cos(timestep * anv) + zz * Sin(timestep * anv)
        z = -xx * Sin(timestep * anv) + zz * Cos(timestep * anv)
        vec3Dpos(vectorindex, 1) = x + xcom
        vec3Dpos(vectorindex, 3) = z + zcom
    End If
    If (zrev <> 0) Then
        anv = zrev
        xx = vec3Dpos(vectorindex, 1) - xcom
        yy = vec3Dpos(vectorindex, 2) - ycom
        x = xx * Cos(timestep * anv) - yy * Sin(timestep * anv)
        y = xx * Sin(timestep * anv) + yy * Cos(timestep * anv)
        vec3Dpos(vectorindex, 1) = x + xcom
        vec3Dpos(vectorindex, 2) = y + ycom
    End If

    If (VectorGroup(vecgroupid).COMFixed = 0) Then GoSub integratecom
Next
If (VectorGroup(vecgroupid).COMFixed = 0) Then GoSub calculatecom
Return

integratecom: ' requires vecgroupid
VectorGroup(vecgroupid).COMx = vec3Dpos(vectorindex, 1) + VectorGroup(vecgroupid).COMx
VectorGroup(vecgroupid).COMy = vec3Dpos(vectorindex, 2) + VectorGroup(vecgroupid).COMy
VectorGroup(vecgroupid).COMz = vec3Dpos(vectorindex, 3) + VectorGroup(vecgroupid).COMz
Return

calculatecom: ' requires vecgroupid
f = 1 + VectorGroup(vecgroupid).LastVector - VectorGroup(vecgroupid).FirstVector
VectorGroup(vecgroupid).COMx = VectorGroup(vecgroupid).COMx / f
VectorGroup(vecgroupid).COMy = VectorGroup(vecgroupid).COMy / f
VectorGroup(vecgroupid).COMz = VectorGroup(vecgroupid).COMz / f
Return

resetcom: ' requires vecgroupid
VectorGroup(vecgroupid).COMx = 0
VectorGroup(vecgroupid).COMy = 0
VectorGroup(vecgroupid).COMz = 0
Return

plot.visible.vectors:
GoSub plot.vectors
GoSub plot.hud
Return

plot.vectors:
Cls
numgroupvisible = 0
numvectorvisible = 0
k = 1
k = VectorGroup(k).Identity
Do
    If (VectorGroup(k).Visible = 1) Then
        numgroupvisible = numgroupvisible + 1
        For i = VectorGroup(k).FirstVector To VectorGroup(k).LastVector - 1
            If (vec3Dvis(i) = 1) Then
                numvectorvisible = numvectorvisible + 1
                If k = closestgroup Then col = Yellow Else col = vec2Dcolor(i)
                x = vec2D(i, 1): y = vec2D(i, 2): GoSub convert: x1 = x: y1 = y
                x = vec2D(i + 1, 1): y = vec2D(i + 1, 2): GoSub convert: x2 = x: y2 = y
                If ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) < 225 Then
                    Line (x1, y1)-(x2, y2), col
                Else
                    Circle (x1, y1), 1, col
                End If
            End If
        Next
    End If
    k = VectorGroup(k).Pointer
    If k = -999 Then Exit Do
    k = VectorGroup(k).Identity
Loop
Return

plot.hud:
' Redraw compass.
x = 30 * (xhat(1) * uhat(1) + xhat(2) * uhat(2) + xhat(3) * uhat(3)): y = 30 * (xhat(1) * vhat(1) + xhat(2) * vhat(2) + xhat(3) * vhat(3)): GoSub convert
Line (midscreenx, midscreeny)-(x, y), Red
x = 30 * (yhat(1) * uhat(1) + yhat(2) * uhat(2) + yhat(3) * uhat(3)): y = 30 * (yhat(1) * vhat(1) + yhat(2) * vhat(2) + yhat(3) * vhat(3)): GoSub convert
Line (midscreenx, midscreeny)-(x, y), Green
x = 30 * (zhat(1) * uhat(1) + zhat(2) * uhat(2) + zhat(3) * uhat(3)): y = 30 * (zhat(1) * vhat(1) + zhat(2) * vhat(2) + zhat(3) * vhat(3)): GoSub convert
Line (midscreenx, midscreeny)-(x, y), Blue
If togglehud = 1 Then
    Color LimeGreen
    Locate 2, 2: Print "- View Info -"
    Color DarkKhaki
    Locate 3, 2: Print "FPS:"; fpsreport
    Locate 4, 2: Print "Vectors:"; numvectorvisible
    Locate 5, 2: Print "Groups:"; numgroupvisible
    Locate 6, 2: Print "Depth:"; -farplane(4)
    Locate 7, 2: Print "Adjust via [ ]"
    Color LimeGreen
    Locate 9, 2: Print "- Camera -"
    Color DarkKhaki
    Locate 10, 2: Print Int(camx); Int(camy); Int(camz)
    Color LimeGreen
    Locate 12, 2: Print "- Closest: -"
    Color DarkKhaki
    Locate 13, 2: Print LTrim$(RTrim$(VectorGroup(closestgroup).GroupName))
    Color LimeGreen
    a$ = "MOVE - ALIGN": Locate 2, screenwidth / 8 - Len(a$): Print a$
    Color DarkKhaki
    a$ = "q w e - x y z": Locate 3, screenwidth / 8 - Len(a$): Print a$
    a$ = "a s d - X Y Z": Locate 4, screenwidth / 8 - Len(a$): Print a$
    a$ = "i = invert ms": Locate 5, screenwidth / 8 - Len(a$): Print a$
    Color LimeGreen
    a$ = "- ROTATE -": Locate 7, screenwidth / 8 - Len(a$): Print a$
    Color DarkKhaki
    a$ = "7 8 9 Mouse": Locate 8, screenwidth / 8 - Len(a$): Print a$
    a$ = "4 5 6   +  ": Locate 9, screenwidth / 8 - Len(a$): Print a$
    a$ = "1 2 3 Wheel": Locate 10, screenwidth / 8 - Len(a$): Print a$
    Color LimeGreen
    a$ = "- CONTROL -": Locate 12, screenwidth / 8 - Len(a$): Print a$
    Color DarkKhaki
    a$ = "t = Stop time": Locate 13, screenwidth / 8 - Len(a$): Print a$
    a$ = "b = Create": Locate 14, screenwidth / 8 - Len(a$): Print a$
    a$ = "n = Destroy": Locate 15, screenwidth / 8 - Len(a$): Print a$
    a$ = "k = Delete": Locate 16, screenwidth / 8 - Len(a$): Print a$
    Color LimeGreen
    a$ = "SPACE = Hide Info": Locate (screenheight / 16) - 3, (screenwidth / 8) / 2 - Len(a$) / 2: Print a$
Else
    Color LimeGreen
    a$ = "You See: " + LTrim$(RTrim$(VectorGroup(closestgroup).GroupName)): Locate (screenheight / 16) - 3, (screenwidth / 8) / 2 - Len(a$) / 2: Print a$
End If
Return

'groupidfromname: ' requires n$, returns k
'k = 1
'k = VectorGroup(k).Identity
'DO ' iterates k
'    IF n$ = LTRIM$(RTRIM$(VectorGroup(k).GroupName)) THEN EXIT DO
'    k = VectorGroup(k).Pointer
'    IF k = -999 THEN EXIT DO
'    k = VectorGroup(k).Identity
'LOOP
'RETURN

' Data.

initialize.objects:
vectorindex = 0
groupidticker = 0
gridsize = 550
tilesize = 15

'__AAA
groupidticker = groupidticker + 1
vecgroupid = groupidticker
VectorGroup(vecgroupid).Identity = vecgroupid
VectorGroup(vecgroupid).Pointer = vecgroupid + 1
VectorGroup(vecgroupid).Lagger = vecgroupid - 1 ' Fancy way to say 0.
VectorGroup(vecgroupid).GroupName = "__AAA"
VectorGroup(vecgroupid).Visible = 0
VectorGroup(vecgroupid).COMFixed = 1
VectorGroup(vecgroupid).DIMx = 5
VectorGroup(vecgroupid).DIMy = 5
VectorGroup(vecgroupid).DIMz = 5
VectorGroup(vecgroupid).FirstVector = vectorindex + 1
For r = 1 To 1
    vectorindex = vectorindex + 1
    vec3Dpos(vectorindex, 1) = 0
    vec3Dpos(vectorindex, 2) = 0
    vec3Dpos(vectorindex, 3) = -1000
    vec3Dcolor(vectorindex) = White
    GoSub integratecom
Next
VectorGroup(vecgroupid).LastVector = vectorindex
GoSub calculatecom

'Dirt
h = 5
For w = 1 To 5
    For u = -gridsize To gridsize Step tilesize
        For v = -gridsize To gridsize Step tilesize
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Dirt"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = 35
            VectorGroup(vecgroupid).DIMy = 35
            VectorGroup(vecgroupid).DIMz = 35
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For i = u To u + tilesize Step h
                For j = v To v + tilesize Step h
                    If Rnd > 1 - w / 5 Then
                        vectorindex = vectorindex + 1
                        vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                        vec3Dpos(vectorindex, 2) = j + Rnd * h - Rnd * h
                        vec3Dpos(vectorindex, 3) = -(w - 1) * 70 - Rnd * 70
                        vec3Dvis(vectorindex) = 0
                        If Rnd > .5 Then
                            vec3Dcolor(vectorindex) = DarkGoldenRod
                        Else
                            If Rnd > .5 Then
                                vec3Dcolor(vectorindex) = SaddleBrown
                            Else
                                vec3Dcolor(vectorindex) = Sienna
                            End If
                        End If
                        GoSub integratecom
                    End If
                Next
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
    Next
Next

'Grass and Puddles
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = -gridsize To gridsize Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Grass and Puddles"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = 3
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 2) = j + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 3) = .5 + 1 * Cos((i - 15) * .08) - 1 * Cos((j - 6) * .12)
                vec3Dvis(vectorindex) = 0
                If vec3Dpos(vectorindex, 3) > 0 Then
                    If Rnd > .5 Then
                        vec3Dcolor(vectorindex) = Green
                    Else
                        vec3Dcolor(vectorindex) = ForestGreen
                    End If
                Else
                    vec3Dvel(vectorindex, 1) = (Rnd - .5) * 20
                    vec3Dvel(vectorindex, 2) = (Rnd - .5) * 20
                    vec3Dvel(vectorindex, 3) = (Rnd - .5) * 20
                    If Rnd > .2 Then
                        vec3Dcolor(vectorindex) = LightSeaGreen
                    Else
                        vec3Dcolor(vectorindex) = Blue
                    End If
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Grave
thickness = 2.5
span = 20
height = 30
crux = 22
For xloc = -90 To -290 Step -60
    For yloc = 0 To 180 Step 45
        For k = 0 To height
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Grave"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = thickness
            VectorGroup(vecgroupid).DIMy = thickness
            VectorGroup(vecgroupid).DIMz = thickness
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For i = -thickness To thickness Step thickness / 2
                For j = -thickness To thickness Step thickness / 2
                    vectorindex = vectorindex + 1
                    vec3Dpos(vectorindex, 1) = xloc + i + (Rnd - .5) * 2
                    vec3Dpos(vectorindex, 2) = yloc + j + (Rnd - .5) * 2
                    vec3Dpos(vectorindex, 3) = k + (Rnd - .5) * 2
                    vec3Dvis(vectorindex) = 0
                    If Rnd > .5 Then
                        vec3Dcolor(vectorindex) = SlateGray
                    Else
                        vec3Dcolor(vectorindex) = DarkGray
                    End If
                    GoSub integratecom
                Next
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
        For j = -span / 2 To -thickness
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Grave"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = thickness
            VectorGroup(vecgroupid).DIMy = thickness
            VectorGroup(vecgroupid).DIMz = thickness
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For k = -thickness To thickness Step thickness / 2
                For i = -thickness To thickness Step thickness / 2
                    vectorindex = vectorindex + 1
                    vec3Dpos(vectorindex, 1) = xloc + i + (Rnd - .5) * 2
                    vec3Dpos(vectorindex, 2) = yloc + j + (Rnd - .5) * 2
                    vec3Dpos(vectorindex, 3) = crux + k + (Rnd - .5) * 2
                    vec3Dvis(vectorindex) = 0
                    If Rnd > .5 Then
                        vec3Dcolor(vectorindex) = SlateGray
                    Else
                        vec3Dcolor(vectorindex) = DarkGray
                    End If
                    GoSub integratecom
                Next
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
        For j = thickness To span / 2
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Grave"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = thickness
            VectorGroup(vecgroupid).DIMy = thickness
            VectorGroup(vecgroupid).DIMz = thickness
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For k = -thickness To thickness Step thickness / 2
                For i = -thickness To thickness Step thickness / 2
                    vectorindex = vectorindex + 1
                    vec3Dpos(vectorindex, 1) = xloc + i + (Rnd - .5) * 2
                    vec3Dpos(vectorindex, 2) = yloc + j + (Rnd - .5) * 2
                    vec3Dpos(vectorindex, 3) = crux + k + (Rnd - .5) * 2
                    vec3Dvis(vectorindex) = 0
                    If Rnd > .5 Then
                        vec3Dcolor(vectorindex) = SlateGray
                    Else
                        vec3Dcolor(vectorindex) = DarkGray
                    End If
                    GoSub integratecom
                Next
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
    Next
Next

'Heaven's Bottom Layer
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = -gridsize To gridsize Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Heaven's Bottom Layer"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = 3
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 2) = j + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 3) = 420 - Rnd
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = BlueViolet
                Else
                    vec3Dcolor(vectorindex) = Cyan
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Hell Spawn
For u = -gridsize To gridsize Step tilesize
    For v = -gridsize To gridsize Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Hell Spawn"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = 35
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step tilesize / 5
            For j = v To v + tilesize Step tilesize / 5
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + (Rnd - .5) * tilesize
                vec3Dpos(vectorindex, 2) = j + (Rnd - .5) * tilesize
                vec3Dpos(vectorindex, 3) = -350 - Rnd * 70
                vec3Dvel(vectorindex, 1) = 0
                vec3Dvel(vectorindex, 2) = 0
                vec3Dvel(vectorindex, 3) = 400 * Rnd
                vec3Dvis(vectorindex) = 0
                If Rnd > .2 Then
                    vec3Dcolor(vectorindex) = Red
                Else
                    vec3Dcolor(vectorindex) = DarkGoldenRod
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
        VectorGroup(vecgroupid).COMz = -350 - 35
    Next
Next

'Icewall East
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = 0 To 70 Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Icewall East"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = tilesize / 2
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = gridsize + tilesize / 2
                vec3Dpos(vectorindex, 2) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 3) = j + Rnd * h - Rnd * h
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = White
                Else
                    vec3Dcolor(vectorindex) = Ivory
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Icewall South
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = 0 To 70 Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Icewall South"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = tilesize / 2
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = -gridsize
                vec3Dpos(vectorindex, 2) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 3) = j + Rnd * h - Rnd * h
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = White
                Else
                    vec3Dcolor(vectorindex) = Ivory
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Icewall North
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = 0 To 70 Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Icewall North"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = tilesize / 2
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 2) = gridsize + tilesize / 2
                vec3Dpos(vectorindex, 3) = j + Rnd * h - Rnd * h
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = White
                Else
                    vec3Dcolor(vectorindex) = Ivory
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Icewall West
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = 0 To 70 Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Icewall West"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = tilesize / 2
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 2) = -gridsize
                vec3Dpos(vectorindex, 3) = j + Rnd * h - Rnd * h
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = White
                Else
                    vec3Dcolor(vectorindex) = Ivory
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Lake of Fire
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = -gridsize To gridsize Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Lake of Fire"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = tilesize / 2
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 2) = j + Rnd * h - Rnd * h
                vec3Dpos(vectorindex, 3) = -350 - 70 - Rnd
                vec3Dvis(vectorindex) = 0
                If Rnd > .2 Then
                    vec3Dcolor(vectorindex) = Red
                Else
                    vec3Dcolor(vectorindex) = Indigo
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Megalith
ctrx = -90
ctry = -320
ctrz = 4
w = 8
h = 256
dens = 100
For k = 1 To h Step w
    For i = -h / 20 + k / 20 To h / 20 - k / 20 Step w
        For j = -h / 20 + k / 20 To h / 20 - k / 20 Step w
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Megalith"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = w / 2
            VectorGroup(vecgroupid).DIMy = w / 2
            VectorGroup(vecgroupid).DIMz = w / 2
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For q = 1 To dens
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = ctrx + i + (Rnd - .5) * w
                vec3Dpos(vectorindex, 2) = ctry + j + (Rnd - .5) * w
                vec3Dpos(vectorindex, 3) = ctrz + k + (Rnd - .5) * w
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = Cyan
                Else
                    vec3Dcolor(vectorindex) = Teal
                End If
                GoSub integratecom
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
    Next
Next

'Pyramid
ctrx = -90
ctry = -120
ctrz = 4
w = 8
h = 56
dens = 50
For k = 1 To h Step w
    For i = -h / 2 + k / 2 To h / 2 - k / 2 Step w
        For j = -h / 2 + k / 2 To h / 2 - k / 2 Step w
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Pyramid"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = tilesize / 2
            VectorGroup(vecgroupid).DIMy = tilesize / 2
            VectorGroup(vecgroupid).DIMz = tilesize / 2
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For q = 1 To dens
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = ctrx + i + (Rnd - .5) * w
                vec3Dpos(vectorindex, 2) = ctry + j + (Rnd - .5) * w
                vec3Dpos(vectorindex, 3) = ctrz + k + (Rnd - .5) * w
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = DarkGoldenRod
                Else
                    vec3Dcolor(vectorindex) = GoldenRod
                End If
                GoSub integratecom
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
    Next
Next

'Rain
For u = -gridsize To gridsize Step tilesize
    For v = -gridsize To gridsize Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Rain"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = 35
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step tilesize '/ 3
            For j = v To v + tilesize Step tilesize '/ 3
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + (Rnd - .5) * tilesize
                vec3Dpos(vectorindex, 2) = j + (Rnd - .5) * tilesize
                vec3Dpos(vectorindex, 3) = Rnd * 70
                vec3Dvel(vectorindex, 1) = 0
                vec3Dvel(vectorindex, 2) = 0
                vec3Dvel(vectorindex, 3) = -400 * Rnd
                vec3Dvis(vectorindex) = 0
                If Rnd > 5 Then
                    vec3Dcolor(vectorindex) = Aquamarine
                Else
                    vec3Dcolor(vectorindex) = DodgerBlue
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
        VectorGroup(vecgroupid).COMz = 35
    Next
Next

'Sky
h = 2
For u = -gridsize To gridsize Step tilesize
    For v = -gridsize To gridsize Step tilesize
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Sky"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = tilesize / 2
        VectorGroup(vecgroupid).DIMy = tilesize / 2
        VectorGroup(vecgroupid).DIMz = 3
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For i = u To u + tilesize Step h
            For j = v To v + tilesize Step h
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = i + (Rnd - Rnd) * h
                vec3Dpos(vectorindex, 2) = j + (Rnd - Rnd) * h
                vec3Dpos(vectorindex, 3) = 70 + (Rnd - Rnd) * h
                vec3Dvel(vectorindex, 1) = (Rnd - Rnd) * 2
                vec3Dvel(vectorindex, 2) = (Rnd - Rnd) * 2
                vec3Dvel(vectorindex, 3) = (Rnd - Rnd) * 2
                vec3Danv(vectorindex, 1) = 0
                vec3Danv(vectorindex, 2) = 0
                vec3Danv(vectorindex, 3) = 0
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = Snow
                Else
                    vec3Dcolor(vectorindex) = RoyalBlue
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Stars
h = 5
For w = 1 To 5
    For u = -gridsize To gridsize Step tilesize
        For v = -gridsize To gridsize Step tilesize
            groupidticker = groupidticker + 1
            vecgroupid = groupidticker
            VectorGroup(vecgroupid).Identity = vecgroupid
            VectorGroup(vecgroupid).Pointer = vecgroupid + 1
            VectorGroup(vecgroupid).Lagger = vecgroupid - 1
            VectorGroup(vecgroupid).GroupName = "Stars"
            VectorGroup(vecgroupid).Visible = 0
            VectorGroup(vecgroupid).COMFixed = 1
            VectorGroup(vecgroupid).DIMx = tilesize / 2
            VectorGroup(vecgroupid).DIMy = tilesize / 2
            VectorGroup(vecgroupid).DIMz = tilesize / 2
            VectorGroup(vecgroupid).FirstVector = vectorindex + 1
            For i = u To u + tilesize Step h
                For j = v To v + tilesize Step h
                    If Rnd > 1 - w / 5 Then
                        vectorindex = vectorindex + 1
                        vec3Dpos(vectorindex, 1) = i + Rnd * h - Rnd * h
                        vec3Dpos(vectorindex, 2) = j + Rnd * h - Rnd * h
                        vec3Dpos(vectorindex, 3) = w * 70 + Rnd * 70
                        vec3Dvis(vectorindex) = 0
                        If Rnd > .5 Then
                            vec3Dcolor(vectorindex) = GhostWhite
                        Else
                            If Rnd > .5 Then
                                vec3Dcolor(vectorindex) = White
                            Else
                                vec3Dcolor(vectorindex) = DarkGray
                            End If
                        End If
                        GoSub integratecom
                    End If
                Next
            Next
            VectorGroup(vecgroupid).LastVector = vectorindex
            GoSub calculatecom
        Next
    Next
Next

'Sun
radius = 10
dx = .0628
dy = .0628
xl = 0: xr = 2 * pi
yl = 0: yr = pi
xrange = 1 + Int((-xl + xr) / dx)
yrange = 1 + Int((-yl + yr) / dy)
For i = 1 To xrange Step 10
    For j = 1 To yrange Step 10
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Sun"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = radius
        VectorGroup(vecgroupid).DIMy = radius
        VectorGroup(vecgroupid).DIMz = radius
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For u = i To i + 10 Step 1
            For v = j To j + 10 Step 1
                vectorindex = vectorindex + 1
                theta = u * dx - dx
                phi = v * dy - dy
                vec3Dpos(vectorindex, 1) = radius * Sin(phi) * Cos(theta)
                vec3Dpos(vectorindex, 2) = radius * Sin(phi) * Sin(theta)
                vec3Dpos(vectorindex, 3) = 90 + radius * Cos(phi)
                vec3Dvis(vectorindex) = 0
                If Rnd > .5 Then
                    vec3Dcolor(vectorindex) = Sunglow
                Else
                    vec3Dcolor(vectorindex) = SunsetOrange
                End If
                GoSub integratecom
            Next
        Next
        GoSub integratecom
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Moon
radius = 4
au = 60
dx = (2 * pi / radius) * .05
dy = (2 * pi / radius) * .05
xl = 0: xr = 2 * pi
yl = 0: yr = pi
xrange = 1 + Int((-xl + xr) / dx)
yrange = 1 + Int((-yl + yr) / dy)
groupidticker = groupidticker + 1
vecgroupid = groupidticker
VectorGroup(vecgroupid).Identity = vecgroupid
VectorGroup(vecgroupid).Pointer = vecgroupid + 1
VectorGroup(vecgroupid).Lagger = vecgroupid - 1
VectorGroup(vecgroupid).GroupName = "Moon"
VectorGroup(vecgroupid).Visible = 0
VectorGroup(vecgroupid).ForceAnimate = 1
VectorGroup(vecgroupid).COMFixed = 0
VectorGroup(vecgroupid).ROTx = 0
VectorGroup(vecgroupid).ROTy = 0
VectorGroup(vecgroupid).ROTz = 90
VectorGroup(vecgroupid).REVx = 1.5
VectorGroup(vecgroupid).REVy = 0
VectorGroup(vecgroupid).REVz = 0
VectorGroup(vecgroupid).DIMx = 2 * radius + 1
VectorGroup(vecgroupid).DIMy = 2 * radius + 1
VectorGroup(vecgroupid).DIMz = 2 * radius + 1
VectorGroup(vecgroupid).FirstVector = vectorindex + 1
For i = 1 To xrange
    For j = 1 To yrange
        vectorindex = vectorindex + 1
        theta = i * dx - dx
        phi = j * dy - dy
        vec3Dpos(vectorindex, 1) = au + radius * Sin(phi) * Cos(theta)
        vec3Dpos(vectorindex, 2) = radius * Sin(phi) * Sin(theta)
        vec3Dpos(vectorindex, 3) = 90 + radius * Cos(phi)
        vec3Danv(vectorindex, 1) = 0
        vec3Danv(vectorindex, 2) = 0
        vec3Danv(vectorindex, 3) = 1.5
        vec3Dvis(vectorindex) = 0
        If Rnd > .5 Then
            vec3Dcolor(vectorindex) = Gray
        Else
            vec3Dcolor(vectorindex) = PaleGoldenRod
        End If
        GoSub integratecom
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Waves or Particles? (1)
For i = 1 To 5 Step 1
    For k = 1 To 5 Step 1
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Waves or Particles?"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = 4
        VectorGroup(vecgroupid).DIMy = 1
        VectorGroup(vecgroupid).DIMz = 4
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For u = i To i + 1 Step .05
            For v = k To k + 1 Step .05
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = 70 + 7 * u
                vec3Dpos(vectorindex, 2) = 80 + 1 * Cos((u ^ 2 - v ^ 2))
                vec3Dpos(vectorindex, 3) = 10 + 7 * v
                vec3Dvis(vectorindex) = 0
                If vec3Dpos(vectorindex, 2) < 80 Then
                    vec3Dcolor(vectorindex) = DarkBlue
                Else
                    vec3Dcolor(vectorindex) = DeepPink
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'Waves or Particles? (2)
For i = 1 To 5 Step 1
    For k = 1 To 5 Step 1
        groupidticker = groupidticker + 1
        vecgroupid = groupidticker
        VectorGroup(vecgroupid).Identity = vecgroupid
        VectorGroup(vecgroupid).Pointer = vecgroupid + 1
        VectorGroup(vecgroupid).Lagger = vecgroupid - 1
        VectorGroup(vecgroupid).GroupName = "Particles or Waves?"
        VectorGroup(vecgroupid).Visible = 0
        VectorGroup(vecgroupid).COMFixed = 1
        VectorGroup(vecgroupid).DIMx = 4
        VectorGroup(vecgroupid).DIMy = 1
        VectorGroup(vecgroupid).DIMz = 4
        VectorGroup(vecgroupid).FirstVector = vectorindex + 1
        For u = i To i + 1 Step .05
            For v = k To k + 1 Step .05
                vectorindex = vectorindex + 1
                vec3Dpos(vectorindex, 1) = -7 * u
                vec3Dpos(vectorindex, 2) = 80 + 1 * Cos(2 * ((u - 7) ^ 2 - (v - 5) ^ 2))
                vec3Dpos(vectorindex, 3) = 10 + 7 * v
                vec3Dvis(vectorindex) = 0
                If vec3Dpos(vectorindex, 2) < 80 Then
                    vec3Dcolor(vectorindex) = Magenta
                Else
                    vec3Dcolor(vectorindex) = Chocolate
                End If
                GoSub integratecom
            Next
        Next
        VectorGroup(vecgroupid).LastVector = vectorindex
        GoSub calculatecom
    Next
Next

'__ZZZ
groupidticker = groupidticker + 1
vecgroupid = groupidticker
VectorGroup(vecgroupid).Identity = vecgroupid
VectorGroup(vecgroupid).Pointer = -999
VectorGroup(vecgroupid).Lagger = vecgroupid - 1
VectorGroup(vecgroupid).GroupName = "__ZZZ"
VectorGroup(vecgroupid).COMFixed = 1
VectorGroup(vecgroupid).FirstVector = vectorindex + 1
For r = 1 To 1
    vectorindex = vectorindex + 1
    vec3Dpos(vectorindex, 1) = 0
    vec3Dpos(vectorindex, 2) = 0
    vec3Dpos(vectorindex, 3) = -1000
    vec3Dcolor(vectorindex) = White
    GoSub integratecom
Next
VectorGroup(vecgroupid).LastVector = vectorindex
GoSub calculatecom
Return
