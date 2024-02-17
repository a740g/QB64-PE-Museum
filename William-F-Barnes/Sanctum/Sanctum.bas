Option _Explicit

Do Until _ScreenExists: Loop
_Title "Sanctum 2022"

' Hardware.

'Screen _NewImage(640, 480, 32)
Screen _NewImage(800, 600, 32)
'Screen _NewImage(1024, 768, 32)

_FullScreen , _Smooth
_MouseHide

' Performance.
Dim Shared As Integer FPSTarget
FPSTarget = 60

' Color constants.
Const Aquamarine = _RGB32(127, 255, 212)
Const Black = _RGB32(0, 0, 0)
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
Const Lime = _RGB32(0, 255, 0)
Const LimeGreen = _RGB32(50, 205, 50)
Const Magenta = _RGB32(255, 0, 255)
Const PaleGoldenRod = _RGB32(238, 232, 170)
Const Purple = _RGB32(128, 0, 128)
Const Red = _RGB32(255, 0, 0)
Const RoyalBlue = _RGB32(65, 105, 225)
Const SaddleBrown = _RGB32(139, 69, 19)
Const Sienna = _RGB32(160, 82, 45)
Const SlateGray = _RGB32(112, 128, 144)
Const Snow = _RGB32(200, 200, 200) '''(255, 250, 250)
Const Sunglow = _RGB32(255, 207, 72)
Const SunsetOrange = _RGB32(253, 94, 83)
Const Teal = _RGB32(0, 128, 128)
Const White = _RGB32(255, 255, 255)
Const Yellow = _RGB32(255, 255, 0)

' Mathematical constants.
Const pi = 4 * Atn(1)
Const ee = Exp(1)

' Divine numbers.
Dim Shared bignumber As Long
Dim Shared WorldSeed As Long
bignumber = 10 ^ 7
WorldSeed = Int(Timer) '3

' Fundamental types.

Type Vector3
    x As Double
    y As Double
    z As Double
End Type

Type Vector2
    u As Double
    v As Double
End Type

Type Camera
    Position As Vector3
    Velocity As Vector3
    Acceleration As Vector3
    Shade As _Unsigned Long
End Type

Type GroupElement
    Identity As Long
    Label As String
    Pointer As Long
    Lagger As Long
    Volume As Vector3
    FirstVector As Long
    LastVector As Long
    Centroid As Vector3
    Velocity As Vector3
    Visible As Integer
    Distance2 As Double
    PlotMode As Integer
    FrameLength As Long
    ActiveFrame As Integer
End Type

Type ClusterElement
    Identity As Long
    Pointer As Long
    Lagger As Long
    FirstGroup As Long
    LastGroup As Long
    Centroid As Vector3
    Velocity As Vector3
    Acceleration As Vector3
    Visible As Integer
    MotionType As Integer
    Framed As Integer
    DeathTimer As Long
End Type

' World-specific types.

Type StrataElement
    Height As Double
    Label As String
    Shade As _Unsigned Long
End Type

Type PlateauElement
    Location As Vector3
    Radius As Double
End Type

' Vectors to specify points.
Dim Shared vec3Dpos(bignumber) As Vector3 ' Absolute position
Dim Shared vec3Dvel(UBound(vec3Dpos)) As Vector3 ' Linear velocity
Dim Shared vec3Dvis(UBound(vec3Dpos)) As Integer ' Visibility toggle
Dim Shared vec2D(UBound(vec3Dpos)) As Vector2 ' Projection onto 2D plane
Dim Shared vec3Dcolor(UBound(vec3Dpos)) As Long ' Original color
Dim Shared vec2Dcolor(UBound(vec3Dpos)) As Long ' Projected color

' A collection of vectors is a Group.
Dim Shared Group(UBound(vec3Dpos) / 10) As GroupElement
Dim Shared GroupIdTicker As Long
GroupIdTicker = 0

' Groups will eventually be sorted based on distance^2.
Dim Shared SortedGroups(1000) As Long
Dim Shared SortedGroupsCount As Integer

' A collection of groups is a Cluster.
Dim Shared ClusterIdTicker As Long
Dim Shared ClusterFillCounter As Integer
Dim Shared Cluster(UBound(Group) / 10) As ClusterElement
ClusterIdTicker = 0
ClusterFillCounter = 0

' Main terrain setup. This is a surface z=f(x,y).
Dim Shared WorldMesh(180, 180) As Double
Dim Shared WorldMeshAddress(UBound(WorldMesh, 1), UBound(WorldMesh, 2)) As Long

' Terrain elements are formally groups whose size and density are specified here.
Dim Shared BlockSize As Integer
Dim Shared BlockStep As Integer
BlockSize = 40
BlockStep = Int(BlockSize / 8)

' World features.
Dim Shared Strata(5) As StrataElement
Dim Shared CloudLayer(5) As StrataElement
Dim Shared Plateau(5) As PlateauElement
Dim Shared SunClusterAddress As Long
Dim Shared MoonClusterAddress As Long

' Fixed paths. Primary ticks are one per second, with total cycle of one day.
Dim Shared FixedPath(500, 86400) As Vector3
Dim Shared FixedPathIndexTicker As Long
FixedPathIndexTicker = 0

' Three-space basis vectors.
Dim Shared As Double xhat(3), yhat(3), zhat(3)
xhat(1) = 1: xhat(2) = 0: xhat(3) = 0
yhat(1) = 0: yhat(2) = 1: yhat(3) = 0
zhat(1) = 0: zhat(2) = 0: zhat(3) = 1

' Camera orientation vectors.
Dim Shared As Double uhat(3), vhat(3), nhat(3)

' Camera position.
Dim Shared PlayerCamera As Camera

' Field-of-view distance.
Dim Shared fovd As Double
fovd = -192

' Clipping planes.
Dim Shared As Double nearplane(4), farplane(4), rightplane(4), leftplane(4), topplane(4), bottomplane(4)
nearplane(4) = 1
farplane(4) = -256
rightplane(4) = -BlockSize / 2
leftplane(4) = -BlockSize / 2
topplane(4) = -BlockSize / 2
bottomplane(4) = -BlockSize / 2

' Temporary counters.
Dim Shared NumClusterVisible As Long
Dim Shared NumVectorVisible As Long
Dim Shared NumGroupVisible As Long

' Interface.
Dim Shared ToggleAnimate As Integer
Dim Shared FPSReport As Integer
Dim Shared ClosestGroup As Long

' Prime and start main loop.
Randomize WorldSeed
Call InitWorld
Call CreateWorld
Call InitCamera
Call MainLoop
End

' Subs and Functions

Sub MainLoop
    Dim fps As Integer
    Dim fpstimer As Long
    Dim tt As Long
    fps = 0
    fpstimer = Int(Timer)

    Do
        Call PlayerDynamics
        Call ComputeVisibleScene
        Call PlotWorld
        Call DisplayHUD
        Call DisplayMiniMap
        Call KeyDownProcess
        Call KeyHitProcess

        fps = fps + 1
        tt = Timer
        If (tt = fpstimer + 1) Then
            fpstimer = tt
            FPSReport = fps
            fps = 0
        End If

        _Display
        _Limit FPSTarget + 1
    Loop
End Sub

Sub InitWorld
    Dim k As Integer
    Dim As Double u, v, w

    k = 0
    k = k + 1: Strata(k).Height = -50: Strata(k).Label = "Water": Strata(k).Shade = RoyalBlue
    k = k + 1: Strata(k).Height = 0: Strata(k).Label = "Meadow": Strata(k).Shade = ForestGreen
    k = k + 1: Strata(k).Height = 50: Strata(k).Label = "Grassland": Strata(k).Shade = DarkKhaki
    k = k + 1: Strata(k).Height = 100: Strata(k).Label = "Rocky Terrain": Strata(k).Shade = DarkGoldenRod
    k = k + 1: Strata(k).Height = 150: Strata(k).Label = "Snowy Terrain": Strata(k).Shade = White

    k = 0
    k = k + 1: CloudLayer(k).Height = 140: CloudLayer(k).Label = "Dark Cloud": CloudLayer(k).Shade = SlateGray
    k = k + 1: CloudLayer(k).Height = 160: CloudLayer(k).Label = "Gray Cloud": CloudLayer(k).Shade = Gray
    k = k + 1: CloudLayer(k).Height = 180: CloudLayer(k).Label = "Azul Cloud": CloudLayer(k).Shade = DarkBlue
    k = k + 1: CloudLayer(k).Height = 200: CloudLayer(k).Label = "Heavy Cloud": CloudLayer(k).Shade = Snow
    k = k + 1: CloudLayer(k).Height = 220: CloudLayer(k).Label = "Icy Cloud": CloudLayer(k).Shade = Ivory

    u = Rnd * 2 * pi
    w = Sqr((UBound(WorldMesh, 1) / 2) ^ 2 + (UBound(WorldMesh, 2) / 2) ^ 2)
    For k = 1 To UBound(Plateau)
        Select Case k
            Case 1 ' Water
                u = u + pi / 2
                v = (w / 2) * (.8 + Rnd * .5)
                Plateau(k).Location.x = Int(v * Cos(u))
                Plateau(k).Location.y = Int(v * Sin(u))
                Plateau(k).Location.z = -250
            Case 2 ' Meadow
                Plateau(k).Location.x = 0
                Plateau(k).Location.y = 0
                Plateau(k).Location.z = Strata(k).Height
            Case Else
                u = u + pi / 2
                v = (w / 2) * (.8 + Rnd * .5)
                Plateau(k).Location.x = Int(v * Cos(u))
                Plateau(k).Location.y = Int(v * Sin(u))
                Plateau(k).Location.z = Strata(k).Height
        End Select
        Plateau(k).Radius = 15
    Next
End Sub

Sub CreateWorld
    Dim g As Long
    Dim k As Integer
    ' Initialize and populate list.
    k = 0
    k = k + 1: Call TextCenter(".:. Let there be light .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Initialize linked list)", k * 16, ForestGreen)
    g = NewGroup&(0, 0, 0, 0, 1, 0, 0)
    k = k + 2: Call TextCenter(".:. Let there be a firmament .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Using seed " + LTrim$(RTrim$(Str$(WorldSeed))) + ")", k * 16, ForestGreen)
    k = k + 1: Call TextCenter("(Generate random terrain)", k * 16, ForestGreen)
    g = CreateTerrainGroups&(g)
    k = k + 2: Call TextCenter(".:. Let the dry land appear; bring forth the grass .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Relax terrain mesh)", k * 16, ForestGreen)
    k = k + 1: Call TextCenter("(Fill terrain volumes)", k * 16, ForestGreen)
    k = k + 1: Call TextCenter("(Cover terrain surfaces)", k * 16, ForestGreen)
    g = CreateTerrainVectors&(g)
    g = CreateTerrainVolume&(g)
    g = CreateClover&(g)
    g = CreateFern&(g)
    g = CreateGrass&(g)
    k = k + 2: Call TextCenter(".:. Divide the day from the night .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Create celestial objects)", k * 16, ForestGreen)
    k = k + 1: Call TextCenter("(Create weather events)", k * 16, ForestGreen)
    g = CreateSun&(g)
    g = CreateMoon&(g)
    g = CreateTornado&(g)
    g = CreateWeather&(g)
    k = k + 2: Call TextCenter(".:. Let waters bring forth .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Create fish)", k * 16, ForestGreen)
    g = CreateFish&(g)
    k = k + 2: Call TextCenter(".:. Let us make man .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Initialize player)", k * 16, ForestGreen)
    k = k + 2: Call TextCenter(".:. ...blessed the seventh day and Sanctified it .:.", k * 16, DarkKhaki)
    k = k + 1: Call TextCenter("(Rest)", k * 16, ForestGreen)
    k = k + 3: Call TextCenter("PRESS ANY KEY", k * 16, Sunglow)
    Sleep
    _KeyClear
End Sub

' High-order clusters and groups.

Function CreateTerrainGroups& (LagAddressIn As Long)
    Dim g As Long
    Dim As Integer i, j, k
    Dim As Integer ii, jj
    Dim As Double u, v, w
    g = LagAddressIn

    ' Create world mesh and set extreme points.
    Dim tempworldmesh1(UBound(WorldMesh, 1), UBound(WorldMesh, 2))
    Dim tempworldmesh2(UBound(WorldMesh, 1), UBound(WorldMesh, 2), 2)

    u = 1 + .5 * (Rnd - .5)
    v = 1 + .5 * (Rnd - .5)
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)

            ' Overall slant of world.
            tempworldmesh2(i, j, 1) = (u * i + v * j - UBound(WorldMesh, 1) / 2 - UBound(WorldMesh, 2) / 2)

            ' Peaks and valleys.
            Select Case Rnd
                Case Is < .005
                    tempworldmesh2(i, j, 1) = tempworldmesh2(i, j, 1) - (100 + Rnd * 100)
                    tempworldmesh2(i, j, 2) = 1 ' fixed
                Case Is > .995
                    tempworldmesh2(i, j, 1) = tempworldmesh2(i, j, 1) + (100 + Rnd * 300)
                    tempworldmesh2(i, j, 2) = 1 ' fixed
                Case Else
                    tempworldmesh2(i, j, 1) = tempworldmesh2(i, j, 1) + 0
                    tempworldmesh2(i, j, 2) = 0 'free
            End Select

            ' Plateaus.
            For k = 1 To UBound(Plateau)
                ii = i - Plateau(k).Location.x - UBound(WorldMesh, 1) / 2
                jj = j - Plateau(k).Location.y - UBound(WorldMesh, 2) / 2
                If (ii ^ 2 + jj ^ 2 < Plateau(k).Radius ^ 2) Then
                    tempworldmesh2(i, j, 1) = Plateau(k).Location.z
                    tempworldmesh2(i, j, 2) = 1 ' fixed
                End If
            Next
        Next
    Next

    ' Relax the world mesh to generate terrain.
    Dim SmoothFactor As Integer
    SmoothFactor = 30
    For k = SmoothFactor To 1 Step -1
        For i = 1 To UBound(WorldMesh, 1)
            For j = 1 To UBound(WorldMesh, 2)
                tempworldmesh1(i, j) = tempworldmesh2(i, j, 1)
                ' Before last iteration, allow extreme points to relax.
                If (k = 1) Then tempworldmesh2(i, j, 2) = 0
            Next
        Next
        For i = 2 To UBound(WorldMesh, 1) - 1
            For j = 2 To UBound(WorldMesh, 2) - 1
                If (tempworldmesh2(i, j, 2) = 0) Then
                    tempworldmesh2(i, j, 1) = (1 / 4) * (tempworldmesh1(i - 1, j) + tempworldmesh1(i + 1, j) + tempworldmesh1(i, j - 1) + tempworldmesh1(i, j + 1))
                End If
            Next
        Next
    Next
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            WorldMesh(i, j) = tempworldmesh2(i, j, 1)
        Next
    Next

    ' Create terrain groups.
    Dim g0 As Long
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            u = BlockSize * (i - (UBound(WorldMesh, 1) / 2))
            v = BlockSize * (j - (UBound(WorldMesh, 2) / 2))
            w = WorldMesh(i, j)
            ' Store first address.
            If ((i = 1) And (j = 1)) Then g0 = g
            g = NewGroup&(g, u, v, w, 10, 0, 0)
            Group(g).Label = TerrainHeightLabel$(w)
            Group(g).Volume.x = BlockSize
            Group(g).Volume.y = BlockSize
            Group(g).Volume.z = Sqr(BlockSize * BlockSize + BlockSize * BlockSize)
            Group(g).PlotMode = 0
            WorldMeshAddress(i, j) = g
        Next
        Call ClusterPinch(g)
    Next
    Call ClusterPinch(g)

    CreateTerrainGroups& = g0
End Function

Function CreateTerrainVectors& (LagAddressIn As Long)
    Dim g As Long
    Dim As Integer i, j, k
    Dim As Integer ii, jj
    Dim Smoothfactor As Integer
    g = LagAddressIn

    ' Create fine-grain block mesh to relax terrain.
    Dim vindex As Long
    Dim BlockBins As Integer
    BlockBins = BlockSize / BlockStep
    Dim blockmesh1(BlockBins, BlockBins)
    Dim blockmesh2(BlockBins, BlockBins, 2)
    vindex = Group(Group(g).Lagger).LastVector
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)

            g = WorldMeshAddress(i, j)
            Group(g).FirstVector = vindex + 1

            ' For each world mesh location, use the block mesh whose boundary heights are determined by neighbors.
            For ii = 1 To UBound(blockmesh2, 1)
                For jj = 1 To UBound(blockmesh2, 2)

                    ' Lock boundaries.
                    If (ii = 1) Or (ii = UBound(blockmesh2, 1)) Then
                        blockmesh2(ii, jj, 2) = 1
                    End If
                    If (jj = 1) Or (jj = UBound(blockmesh2, 2)) Then
                        blockmesh2(ii, jj, 2) = 1
                    End If

                    ' Set boundary values.
                    If (i > 1) Then
                        If (ii = 1) Then
                            blockmesh2(ii, jj, 1) = -WorldMesh(i, j) + (1 / 2) * (WorldMesh(i, j) + WorldMesh(i - 1, j))
                        End If
                    End If
                    If (j > 1) Then
                        If (jj = 1) Then
                            blockmesh2(ii, jj, 1) = -WorldMesh(i, j) + (1 / 2) * (WorldMesh(i, j) + WorldMesh(i, j - 1))
                        End If
                    End If
                    If (i < UBound(WorldMesh, 1)) Then
                        If (ii = UBound(blockmesh2, 1)) Then
                            blockmesh2(ii, jj, 1) = -WorldMesh(i, j) + (1 / 2) * (WorldMesh(i, j) + WorldMesh(i + 1, j))
                        End If
                    End If
                    If (j < UBound(WorldMesh, 2)) Then
                        If (jj = UBound(blockmesh2, 2)) Then
                            blockmesh2(ii, jj, 1) = -WorldMesh(i, j) + (1 / 2) * (WorldMesh(i, j) + WorldMesh(i, j + 1))
                        End If
                    End If

                    ' Set extreme points.
                    If ((ii > 1) And (ii < UBound(blockmesh2, 1)) And (jj > 1) And (jj < UBound(blockmesh2, 1))) Then
                        Select Case Rnd
                            Case Is < .01
                                blockmesh2(ii, jj, 1) = -Rnd * 20
                                blockmesh2(ii, jj, 2) = 1 ' fixed
                            Case Is > .99
                                blockmesh2(ii, jj, 1) = Rnd * 20
                                blockmesh2(ii, jj, 2) = 1 ' fixed
                            Case Else
                                blockmesh2(ii, jj, 1) = 0
                                blockmesh2(ii, jj, 2) = 0 'free
                        End Select
                    End If

                    ' Copy mesh.
                    blockmesh1(ii, jj) = blockmesh2(ii, jj, 1)

                Next
            Next

            ' Relax mesh body.
            Smoothfactor = 30
            For k = Smoothfactor To 1 Step -1
                For ii = 2 To UBound(blockmesh1, 1) - 1
                    For jj = 2 To UBound(blockmesh1, 2) - 1
                        ' Before last iteration, allow extreme points to relax.
                        If (k = 5) Then blockmesh2(ii, jj, 2) = 0
                        If (blockmesh2(ii, jj, 2) = 0) Then
                            blockmesh2(ii, jj, 1) = (1 / 4) * (blockmesh1(ii - 1, jj) + blockmesh1(ii + 1, jj) + blockmesh1(ii, jj - 1) + blockmesh1(ii, jj + 1))
                        End If
                    Next
                Next

                ' Upate mesh with relaxed version.
                For ii = 1 To UBound(blockmesh1, 1)
                    For jj = 1 To UBound(blockmesh1, 2)
                        blockmesh1(ii, jj) = blockmesh2(ii, jj, 1)
                    Next
                Next
            Next

            ' Relax mesh boundaries once.
            For ii = 2 To UBound(blockmesh1, 1) - 1
                jj = 1
                blockmesh2(ii, jj, 1) = (1 / 3) * (blockmesh1(ii - 1, jj) + blockmesh1(ii + 1, jj) + blockmesh1(ii, jj + 1))
                jj = UBound(blockmesh1, 2)
                blockmesh2(ii, jj, 1) = (1 / 3) * (blockmesh1(ii - 1, jj) + blockmesh1(ii + 1, jj) + blockmesh1(ii, jj - 1))
            Next
            For jj = 2 To UBound(blockmesh1, 2) - 1
                ii = 1
                blockmesh2(ii, jj, 1) = (1 / 3) * (blockmesh1(ii + 1, jj) + blockmesh1(ii, jj - 1) + blockmesh1(ii, jj + 1))
                ii = UBound(blockmesh1, 1)
                blockmesh2(ii, jj, 1) = (1 / 3) * (blockmesh1(ii - 1, jj) + blockmesh1(ii, jj - 1) + blockmesh1(ii, jj + 1))
            Next

            ii = 1
            jj = 1
            blockmesh2(ii, jj, 1) = (1 / 2) * (blockmesh1(ii + 1, jj) + blockmesh1(ii, jj + 1))

            ii = UBound(blockmesh1, 1)
            jj = UBound(blockmesh1, 2)
            blockmesh2(ii, jj, 1) = (1 / 2) * (blockmesh1(ii - 1, jj) + blockmesh1(ii, jj - 1))

            ii = 1
            jj = UBound(blockmesh1, 2)
            blockmesh2(ii, jj, 1) = (1 / 2) * (blockmesh1(ii + 1, jj) + blockmesh1(ii, jj - 1))

            ii = UBound(blockmesh1, 1)
            jj = 1
            blockmesh2(ii, jj, 1) = (1 / 2) * (blockmesh1(ii - 1, jj) + blockmesh1(ii, jj + 1))

            ' Upate mesh with relaxed version.
            For ii = 1 To UBound(blockmesh1, 1)
                For jj = 1 To UBound(blockmesh1, 2)
                    blockmesh1(ii, jj) = blockmesh2(ii, jj, 1)
                Next
            Next

            ' Set particle positions relative to group center. Add random fuzz.
            Dim cc As _Unsigned Long
            Dim dd As _Unsigned Long
            For ii = 1 To UBound(blockmesh1, 1)
                For jj = 1 To UBound(blockmesh1, 2)
                    vindex = vindex + 1
                    vec3Dpos(vindex).x = BlockStep * ii - BlockSize / 2 + 3 * (Rnd - .5)
                    vec3Dpos(vindex).y = BlockStep * jj - BlockSize / 2 + 3 * (Rnd - .5)
                    vec3Dpos(vindex).z = blockmesh1(ii, jj)
                    cc = TerrainHeightShade~&(WorldMesh(i, j) + blockmesh1(ii, jj))
                    dd = TerrainHeightShade~&(WorldMesh(i, j) + blockmesh1(ii, jj) + BlockSize)
                    vec3Dcolor(vindex) = ShadeMix~&(cc, ShadeMix~&(cc, dd, blockmesh1(ii, jj) / 10), .5)
                Next
            Next

            Group(g).LastVector = vindex + 1 ''' why on earth is this +1?
        Next
    Next

    CreateTerrainVectors& = g
End Function

Function CreateTerrainVolume& (LagAddressIn As Long)
    Dim g As Long
    Dim As Integer i, j
    Dim k As Long
    Dim As Double u, v, z
    Dim groupcount As Integer
    Dim clustertick As Integer
    g = LagAddressIn
    groupcount = 0
    clustertick = 0
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            z = WorldMesh(i, j) + BlockSize / 2
            If (z < 0) Then
                groupcount = groupcount + 1
                u = BlockSize * (i - (UBound(WorldMesh, 1) / 2))
                v = BlockSize * (j - (UBound(WorldMesh, 2) / 2))
                g = NewCube&(g, "Water", 50, u, v, WorldMesh(i, j) - z / 2, BlockSize, BlockSize, -z, Blue, RoyalBlue, DarkBlue, 0, 0)
                For k = Group(g).FirstVector To Group(g).LastVector
                    vec3Dvel(k).x = (Rnd - .5) * .20
                    vec3Dvel(k).y = (Rnd - .5) * .20
                    vec3Dvel(k).z = 0
                Next
            End If
            clustertick = clustertick + 1
            If (clustertick = 12) Then
                clustertick = 0
                If (groupcount > 0) Then
                    groupcount = 0
                    Call ClusterPinch(g)
                End If
            End If
        Next
        Call ClusterPinch(g)
    Next
    Call ClusterPinch(g)

    groupcount = 0
    clustertick = 0
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            z = WorldMesh(i, j) + BlockSize / 2
            If (z > 0) Then
                groupcount = groupcount + 1
                u = BlockSize * (i - (UBound(WorldMesh, 1) / 2))
                v = BlockSize * (j - (UBound(WorldMesh, 2) / 2))
                g = NewCube&(g, "Dirt and Sand", 20, u, v, WorldMesh(i, j) / 2 - BlockSize / 4, BlockSize, BlockSize, WorldMesh(i, j), SaddleBrown, DarkKhaki, Sienna, 0, 0)
                g = NewCube&(g, "Dirt and Sand", 20, u, v, -50, BlockSize, BlockSize, 80, SaddleBrown, DarkKhaki, Sienna, 0, 0)
            End If
            clustertick = clustertick + 1
            If (clustertick = 12) Then
                clustertick = 0
                If (groupcount > 0) Then
                    groupcount = 0
                    Call ClusterPinch(g)
                End If
            End If
        Next
        Call ClusterPinch(g)
    Next
    Call ClusterPinch(g)

    groupcount = 0
    clustertick = 0
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            groupcount = groupcount + 1
            u = BlockSize * (i - (UBound(WorldMesh, 1) / 2))
            v = BlockSize * (j - (UBound(WorldMesh, 2) / 2))
            z = WorldMesh(i, j)
            If (z < 0) Then z = 0
            g = NewCube&(g, "Atmospheric Dust", 30, u, v, 100 + BlockSize * (3 - 1 / 2) + z, BlockSize, BlockSize, BlockSize * 3, DarkGray, White, Snow, 0, 0)
            clustertick = clustertick + 1
            If (clustertick = 12) Then
                clustertick = 0
                If (groupcount > 0) Then
                    groupcount = 0
                    Call ClusterPinch(g)
                End If
            End If
        Next
        Call ClusterPinch(g)
    Next
    Call ClusterPinch(g)

    CreateTerrainVolume& = g
End Function

Function CreateTornado& (LagAddressIn As Long)
    Dim As Integer n, k
    Dim As Double u, v, w, x0, y0, z0
    Dim As Long p, g
    Dim wi As Integer
    Dim wj As Integer
    g = LagAddressIn
    For n = 1 To 4
        u = Rnd * 2 * pi
        FixedPathIndexTicker = FixedPathIndexTicker + 1
        For p = 1 To 86400
            x0 = BlockSize * 30 * Cos(u + 2 * pi * (6 * 30) * (p - 1) / 86400)
            y0 = BlockSize * 30 * Sin(u + 2 * pi * (6 * 30) * (p - 1) / 86400)
            FixedPath(FixedPathIndexTicker, p).x = x0
            FixedPath(FixedPathIndexTicker, p).y = y0
            wi = 1 + Int(x0 / BlockSize + UBound(WorldMesh, 1) / 2)
            wj = 1 + Int(y0 / BlockSize + UBound(WorldMesh, 2) / 2)
            z0 = WorldMesh(wi, wj)
            If (z0 < 0) Then z0 = 0
            FixedPath(FixedPathIndexTicker, p).z = z0 + 50
        Next
        For k = 1 To 30
            u = Rnd * 100
            v = Rnd * u / 3
            w = Rnd * 2 * pi
            g = NewCube&(g, "Tornado", 35, v * Cos(w), v * Sin(w), u, 15, 15, 15, DarkGray, SunsetOrange, DarkGoldenRod, FixedPathIndexTicker, 0)
            Call SetParticleVelocity(g, -Sin(w), Cos(w), 0)
        Next
        Call ClusterPinch(g)
    Next
    CreateTornado& = g
End Function

Function CreateWeather& (LagAddressIn As Long)
    Dim As Integer n, k
    Dim As Double u, v, w, x0, y0, z0, tallness
    Dim As Long p, g
    Dim wi As Integer
    Dim wj As Integer
    g = LagAddressIn
    For n = 1 To 100
        FixedPathIndexTicker = FixedPathIndexTicker + 1
        u = Rnd * 2 * pi
        v = Rnd * .7 * BlockSize * Sqr((UBound(WorldMesh, 1) / 2) ^ 2 + (UBound(WorldMesh, 2) / 2) ^ 2)
        w = pi / 2
        tallness = Rnd * (CloudLayer(UBound(CloudLayer)).Height - CloudLayer(1).Height)
        For p = 1 To 86400
            x0 = v * Cos(u + 2 * pi * (1 * 30) * (p - 1) / 86400 + w)
            y0 = v * Sin(u + 4 * pi * (1 * 30) * (p - 1) / 86400)
            FixedPath(FixedPathIndexTicker, p).x = x0
            FixedPath(FixedPathIndexTicker, p).y = y0
            wi = 1 + Int(x0 / BlockSize + UBound(WorldMesh, 1) / 2)
            wj = 1 + Int(y0 / BlockSize + UBound(WorldMesh, 2) / 2)
            z0 = WorldMesh(wi, wj)
            If (z0 < 0) Then z0 = 0
            z0 = z0 + CloudLayer(1).Height + tallness
            FixedPath(FixedPathIndexTicker, p).z = z0
        Next
        For k = 1 To 20 '30
            u = Rnd * 80
            v = u
            w = Rnd * 2 * pi
            z0 = z0 + 10 * (Rnd - .5)
            g = NewCube&(g, CloudHeightLabel$(z0), 20, v * Cos(w), v * Sin(w), z0, BlockSize / 2, BlockSize / 2, BlockSize / 2, Red, Red, Red, FixedPathIndexTicker, 0)
            Call SetParticleVelocity(g, .01 * (Rnd - .5), .01 * (Rnd - .5), 0)
            For p = Group(g).FirstVector To Group(g).LastVector
                vec3Dcolor(p) = CloudHeightShade~&(Group(g).Centroid.z + vec3Dpos(p).z)
            Next
            Group(g).PlotMode = 0

            If (Rnd < .2) Then
                z0 = Group(g).Centroid.z
                g = NewCube&(g, "Rain", 20, v * Cos(w), v * Sin(w), z0 / 2 - BlockSize / 2, BlockSize / 2, BlockSize / 2, z0, Blue, RoyalBlue, DodgerBlue, 0, 0)
                Call SetParticleVelocity(g, 0, 0, -1)
            End If

        Next
        Call ClusterPinch(g)
    Next
    CreateWeather& = g
End Function

Function CreateClover& (LagAddressIn As Long)
    Dim As Long g, vindex
    Dim As Integer i, j
    Dim As Double x, y, z, u, t
    Dim As Integer pedals
    Dim As Double scale
    Dim As Double height
    g = LagAddressIn
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            z = WorldMesh(i, j)
            If (TerrainHeightIndex(z) = 1) Then
                If (Rnd < .1) Then
                    x = (Rnd - .5) * BlockSize + BlockSize * (i - (UBound(WorldMesh, 1) / 2))
                    y = (Rnd - .5) * BlockSize + BlockSize * (j - (UBound(WorldMesh, 2) / 2))
                    scale = 1 / (4 + Rnd * 3)
                    g = NewGroup&(g, x, y, z, 12, 0, 0)
                    Group(g).Label = "Clover"
                    Group(g).Volume.x = BlockSize
                    Group(g).Volume.y = BlockSize
                    Group(g).Volume.z = BlockSize
                    vindex = Group(Group(g).Lagger).LastVector
                    Group(g).FirstVector = vindex + 1
                    Group(g).PlotMode = 1
                    pedals = 2 + Int(Rnd * 4)
                    height = 2 + Rnd
                    t = Rnd * 2 * pi
                    For u = 0 To 2 * pi Step .1
                        vindex = vindex + 1
                        vec3Dpos(vindex).x = scale * ((Group(g).Volume.x) * (0 + Cos(pedals * u) * Cos(u))) * Cos(t)
                        vec3Dpos(vindex).y = scale * ((Group(g).Volume.y) * (0 + Cos(pedals * u) * Cos(u))) * Sin(t)
                        vec3Dpos(vindex).z = scale * ((Group(g).Volume.z) * (height + Cos(pedals * u) * Sin(u)))
                        Select Case pedals
                            Case 3
                                vec3Dcolor(vindex) = Magenta
                            Case Else
                                vec3Dcolor(vindex) = Lime
                        End Select
                    Next
                    For u = (Group(g).Volume.z) * height To 0 Step -(Group(g).Volume.z) * height / 10
                        vindex = vindex + 1
                        vec3Dpos(vindex).x = scale * (0 + (Rnd - .5))
                        vec3Dpos(vindex).y = scale * (0 + (Rnd - .5))
                        vec3Dpos(vindex).z = scale * (u)
                        vec3Dcolor(vindex) = LimeGreen
                    Next
                    Group(g).LastVector = vindex '''+ 1 ''' why on earth is this +1?
                    Call ClusterPinch(g)
                End If
            End If
        Next
    Next
    CreateClover& = g
End Function

Function CreateGrass& (LagAddressIn As Long)
    Dim As Long g, vindex
    Dim As Integer i, j, k
    Dim As Double x0, y0, x, y, z, u, t
    Dim As Double scale
    Dim As Double height
    g = LagAddressIn
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            z = WorldMesh(i, j)
            If (TerrainHeightIndex(z) = 2) Then
                For k = 1 To 5
                    If (Rnd < .5) Then
                        x = (Rnd - .5) * BlockSize + BlockSize * (i - (UBound(WorldMesh, 1) / 2))
                        y = (Rnd - .5) * BlockSize + BlockSize * (j - (UBound(WorldMesh, 2) / 2))
                        scale = 1 / (4 + Rnd * 3)
                        g = NewGroup&(g, x, y, z, 16, 0, 0)
                        Group(g).Label = "Grass"
                        Group(g).Volume.x = BlockSize
                        Group(g).Volume.y = BlockSize
                        Group(g).Volume.z = BlockSize
                        vindex = Group(Group(g).Lagger).LastVector
                        Group(g).FirstVector = vindex + 1
                        Group(g).PlotMode = 1
                        height = 1 + Rnd
                        t = Rnd * 2 * pi
                        x0 = BlockSize * 1 * (Rnd - .5)
                        y0 = BlockSize * 1 * (Rnd - .5)
                        For u = (Group(g).Volume.z) * height To 0 Step -(Group(g).Volume.z) * height / 5
                            vindex = vindex + 1
                            vec3Dpos(vindex).x = scale * (x0 + (Rnd - .5))
                            vec3Dpos(vindex).y = scale * (y0 + (Rnd - .5))
                            vec3Dpos(vindex).z = scale * (u)
                            vec3Dcolor(vindex) = ShadeMix~&(DarkGoldenRod, Sienna, Rnd)
                        Next
                        Group(g).LastVector = vindex '''+ 1 ''' why on earth is this +1?
                    End If
                Next
            End If
        Next
        Call ClusterPinch(g)
    Next
    CreateGrass& = g
End Function

Function CreateFern& (LagAddressIn As Long)
    Dim As Long g, vindex
    Dim As Integer i, j, k
    Dim As Double xx, yy, zz, x, y, z, t
    Dim As Double scale
    g = LagAddressIn
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            z = WorldMesh(i, j)
            If (TerrainHeightIndex(z) = 1) Then
                If (Rnd < .1) Then
                    x = (Rnd - .5) * BlockSize + BlockSize * (i - (UBound(WorldMesh, 1) / 2))
                    y = (Rnd - .5) * BlockSize + BlockSize * (j - (UBound(WorldMesh, 2) / 2))
                    scale = .05 + Rnd * .05
                    g = NewGroup&(g, x, y, z, 12, 0, 0)
                    Group(g).Label = "Fern"
                    Group(g).Volume.x = BlockSize
                    Group(g).Volume.y = BlockSize
                    Group(g).Volume.z = BlockSize
                    vindex = Group(Group(g).Lagger).LastVector
                    Group(g).FirstVector = vindex + 1
                    Group(g).PlotMode = 2
                    t = Rnd * 2 * pi
                    xx = 0
                    yy = xx
                    zz = 0
                    For k = 1 To 100
                        Select Case Rnd * 100
                            Case Is < 1
                                xx = 0
                                zz = .16 * zz
                            Case Is < 86
                                xx = .85 * xx + .04 * zz
                                zz = -.04 * xx + .85 * zz + 1.6
                            Case Is < 93
                                xx = .2 * xx - .26 * zz
                                zz = .23 * xx + .22 * zz + 1.6
                            Case Else
                                xx = -.15 * xx + .28 * zz
                                zz = .26 * xx + .24 * zz + .44
                        End Select
                        yy = xx
                        vindex = vindex + 1
                        vec3Dpos(vindex).x = scale * Group(g).Volume.x * xx * Cos(t)
                        vec3Dpos(vindex).y = scale * Group(g).Volume.y * yy * Sin(t)
                        vec3Dpos(vindex).z = scale * Group(g).Volume.z * zz
                        vec3Dcolor(vindex) = Lime
                    Next
                    Group(g).LastVector = vindex '''+ 1 ''' why on earth is this +1?
                    Call ClusterPinch(g)
                End If
            End If
        Next
    Next
    CreateFern& = g
End Function

Function CreateSun& (LagAddressIn As Long)
    Dim As Integer k
    Dim As Double xx, yy, zz, x0, y0, z0, phase
    Dim As Long p, g
    g = LagAddressIn
    FixedPathIndexTicker = FixedPathIndexTicker + 1
    For p = 1 To 86400
        phase = -2 * pi * (24) * (p - 1) / 86400 - pi / 2
        x0 = 5000 * Cos(phase)
        y0 = 0
        z0 = 3000 * Sin(phase)
        FixedPath(FixedPathIndexTicker, p).x = x0
        FixedPath(FixedPathIndexTicker, p).y = y0
        FixedPath(FixedPathIndexTicker, p).z = z0
    Next
    For k = 1 To 30
        Do
            xx = (Rnd - .5) * 6 * BlockSize
            yy = (Rnd - .5) * 6 * BlockSize
            zz = (Rnd - .5) * 6 * BlockSize
        Loop Until ((xx ^ 2 + yy ^ 2 + zz ^ 2) < (.5 * 6 * BlockSize) ^ 2)
        g = NewCube&(g, "Sun", 50, xx, yy, zz, BlockSize * 6, BlockSize * 6, BlockSize * 6, Red, Red, Red, FixedPathIndexTicker, 0)
        For p = Group(g).FirstVector To Group(g).LastVector
            vec3Dcolor(p) = ShadeMix~&(Sunglow, SunsetOrange, Rnd)
        Next
        Call SetParticleVelocity(g, .5 * (Rnd - .5), .5 * (Rnd - .5), .5 * (Rnd - .5))
        Group(g).PlotMode = 0
    Next
    SunClusterAddress = ClusterIdTicker
    Call ClusterPinch(g)
    CreateSun& = g
End Function

Function CreateMoon& (LagAddressIn As Long)
    Dim As Integer k
    Dim As Double xx, yy, zz, x0, y0, z0, phase
    Dim As Long p, g
    g = LagAddressIn
    FixedPathIndexTicker = FixedPathIndexTicker + 1
    For p = 1 To 86400
        phase = -2 * pi * (48) * (p - 1) / 86400 + pi / 2
        x0 = 0
        y0 = 4000 * Cos(phase)
        z0 = 2000 * Sin(phase)
        FixedPath(FixedPathIndexTicker, p).x = x0
        FixedPath(FixedPathIndexTicker, p).y = y0
        FixedPath(FixedPathIndexTicker, p).z = z0
    Next
    For k = 1 To 30
        Do
            xx = (Rnd - .5) * 5 * BlockSize
            yy = (Rnd - .5) * 5 * BlockSize
            zz = (Rnd - .5) * 5 * BlockSize
        Loop Until ((xx ^ 2 + yy ^ 2 + zz ^ 2) < (.5 * 5 * BlockSize) ^ 2)
        g = NewCube&(g, "Moon", 50, xx, yy, zz, 5 * BlockSize, 5 * BlockSize, 5 * BlockSize, Gray, DarkGray, SlateGray, FixedPathIndexTicker, 0)
        Group(g).PlotMode = 0
    Next
    MoonClusterAddress = ClusterIdTicker
    Call ClusterPinch(g)
    CreateMoon& = g
End Function

Function CreateFish& (LagAddressIn As Long)
    Dim As Integer n, m, wi, wj
    Dim As Double u, v, x0, y0, z0
    Dim As Long p, g, p0
    g = LagAddressIn
    For n = 1 To 12
        u = Rnd * 2 * pi
        FixedPathIndexTicker = FixedPathIndexTicker + 1
        For p = 1 To 86400
            x0 = BlockSize * Plateau(1).Location.x + BlockSize * (4 + Cos(2 * pi * n / 12)) * Cos(u + 2 * pi * (24 * 30) * (p - 1) / 86400)
            y0 = BlockSize * Plateau(1).Location.y + BlockSize * (4 + Cos(2 * pi * n / 12)) * Sin(u + 2 * pi * (24 * 30) * (p - 1) / 86400)
            FixedPath(FixedPathIndexTicker, p).x = x0
            FixedPath(FixedPathIndexTicker, p).y = y0
            wi = 1 + Int(x0 / BlockSize + UBound(WorldMesh, 1) / 2)
            wj = 1 + Int(y0 / BlockSize + UBound(WorldMesh, 2) / 2)
            z0 = WorldMesh(wi, wj) + 100 + 80 * Cos(2 * pi * n / 12) * Cos(2 * pi * (24 * 30) * (p - 1) / 86400)
            FixedPath(FixedPathIndexTicker, p).z = z0
        Next
        ' In the following group, there are 48 frames with 36 vectors per frame. The +1 offset is fishy, no pun.
        g = NewCube&(g, "Fish", 36 * (48 + 1), 0, 0, 0, BlockSize / 4, BlockSize / 4, BlockSize / 4, LimeGreen, SunsetOrange, DarkGoldenRod, FixedPathIndexTicker, 1)
        Group(g).FrameLength = 36
        u = 0
        For p = Group(g).FirstVector To Group(g).FirstVector + Group(g).FrameLength - 1
            u = u + 2 * pi / Group(g).FrameLength
            vec3Dpos(p).x = Group(g).Volume.x * (Cos(u) - Sin(u) ^ 2 / Sqr(2))
            vec3Dpos(p).y = 0
            vec3Dpos(p).z = Group(g).Volume.z * (Cos(u) * Sin(u))
        Next
        v = 0
        For m = 1 To 48
            v = v - 2 * pi / 48
            p0 = 0
            For p = Group(g).FirstVector + Group(g).FrameLength * (m) To Group(g).FirstVector + Group(g).FrameLength * (m + 1) - 1
                vec3Dpos(p).x = Cos(v) * vec3Dpos(Group(g).FirstVector + p0).x + Sin(v) * vec3Dpos(Group(g).FirstVector + p0).y
                vec3Dpos(p).y = -Sin(v) * vec3Dpos(Group(g).FirstVector + p0).x + Cos(v) * vec3Dpos(Group(g).FirstVector + p0).y
                vec3Dpos(p).z = vec3Dpos(Group(g).FirstVector + p0).z
                p0 = p0 + 1
            Next
        Next
        Call ClusterPinch(g)
    Next
    CreateFish& = g
End Function

Sub InitCamera
    ToggleAnimate = 1
    PlayerCamera.Position.x = 0
    PlayerCamera.Position.y = 0
    PlayerCamera.Position.z = 100 + 40 + WorldMesh(UBound(WorldMesh, 1) / 2, UBound(WorldMesh, 2) / 2)
    PlayerCamera.Velocity.x = 0
    PlayerCamera.Velocity.y = 0
    PlayerCamera.Velocity.z = .1
    PlayerCamera.Acceleration.x = 0
    PlayerCamera.Acceleration.y = 0
    PlayerCamera.Acceleration.z = -.5
    uhat(1) = 1: uhat(2) = 0: uhat(3) = 0
    vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
    Call CalculateScreenVectors
End Sub

Sub RegulateCamera
    Dim As Double dx, dy, t
    dx = -nhat(1)
    dy = -nhat(2)
    If ((dx > 0) And (dy > 0)) Then t = -pi / 2 + (Atn(dy / dx))
    If ((dx < 0) And (dy > 0)) Then t = -pi / 2 + pi + (Atn(dy / dx))
    If ((dx < 0) And (dy < 0)) Then t = -pi / 2 + pi + (Atn(dy / dx))
    If ((dx > 0) And (dy < 0)) Then t = -pi / 2 + 2 * pi + (Atn(dy / dx))
    uhat(1) = Cos(t): uhat(2) = Sin(t): uhat(3) = 0
    vhat(1) = 0: vhat(2) = 0: vhat(3) = 1
    Call CalculateScreenVectors
End Sub

' Terrain tools.

Function TerrainHeightIndex (z0 As Double)
    Dim j As Integer
    Dim h0 As Integer
    h0 = -1
    For j = 1 To UBound(Strata)
        If (z0 <= Strata(j).Height) Then
            h0 = j - 1
            Exit For
        End If
    Next
    If (h0 = -1) Then h0 = UBound(Strata)
    TerrainHeightIndex = h0
End Function

Function TerrainHeightShade~& (z0 As Double)
    Dim j As Integer
    Dim h0 As Integer
    h0 = -1
    For j = 1 To UBound(Strata)
        If (z0 <= Strata(j).Height) Then
            h0 = j - 1
            Exit For
        End If
    Next
    If (h0 = -1) Then h0 = UBound(Strata)
    Dim u As Double
    Dim v As Double
    Dim alpha As Double
    Dim sh1 As _Unsigned Long
    Dim sh2 As _Unsigned Long
    Select Case h0
        Case 0
            sh1 = Strata(1).Shade
            sh2 = Strata(1).Shade
            alpha = 0
        Case UBound(Strata)
            sh1 = Strata(h0).Shade
            sh2 = Strata(h0).Shade
            alpha = 0
        Case Else
            sh1 = Strata(h0).Shade
            sh2 = Strata(h0 + 1).Shade
            u = z0 - Strata(h0).Height
            v = Strata(h0 + 1).Height - Strata(h0).Height
            alpha = u / v
    End Select
    TerrainHeightShade~& = ShadeMix~&(sh1, sh2, alpha)
End Function

Function TerrainHeightLabel$ (z0 As Double)
    Dim TheReturn As String
    Dim j As Integer
    Dim h0 As Integer
    h0 = -1
    For j = 1 To UBound(Strata)
        If (z0 <= Strata(j).Height) Then
            h0 = j
            Exit For
        End If
    Next
    If (h0 = -1) Then h0 = UBound(Strata)
    Select Case h0
        Case 0
            TheReturn = Strata(1).Label
        Case UBound(Strata)
            TheReturn = Strata(h0).Label
        Case Else
            TheReturn = Strata(h0).Label
    End Select
    TerrainHeightLabel$ = TheReturn
End Function

Function CloudHeightShade~& (z0 As Double)
    Dim j As Integer
    Dim h0 As Integer
    h0 = -1
    For j = 1 To UBound(CloudLayer)
        If (z0 <= CloudLayer(j).Height) Then
            h0 = j - 1
            Exit For
        End If
    Next
    If (h0 = -1) Then h0 = UBound(CloudLayer)
    Dim u As Double
    Dim v As Double
    Dim alpha As Double
    Dim sh1 As _Unsigned Long
    Dim sh2 As _Unsigned Long
    Select Case h0
        Case 0
            sh1 = CloudLayer(1).Shade
            sh2 = CloudLayer(1).Shade
            alpha = 0
        Case UBound(CloudLayer)
            sh1 = CloudLayer(h0).Shade
            sh2 = CloudLayer(h0).Shade
            alpha = 0
        Case Else
            sh1 = CloudLayer(h0).Shade
            sh2 = CloudLayer(h0 + 1).Shade
            u = z0 - CloudLayer(h0).Height
            v = CloudLayer(h0 + 1).Height - CloudLayer(h0).Height
            alpha = u / v
    End Select
    CloudHeightShade~& = ShadeMix~&(sh1, sh2, alpha)
End Function

Function CloudHeightLabel$ (z0 As Double)
    Dim TheReturn As String
    Dim j As Integer
    Dim h0 As Integer
    h0 = -1
    For j = 1 To UBound(CloudLayer)
        If (z0 <= CloudLayer(j).Height) Then
            h0 = j
            Exit For
        End If
    Next
    If (h0 = -1) Then h0 = UBound(CloudLayer)
    Select Case h0
        Case 0
            TheReturn = CloudLayer(1).Label
        Case UBound(CloudLayer)
            TheReturn = CloudLayer(h0).Label
        Case Else
            TheReturn = CloudLayer(h0).Label
    End Select
    CloudHeightLabel$ = TheReturn
End Function

' Low-order groups.

Function NewCube& (LagAddressIn As Long, TheName As String, Weight As Integer, PosX As Double, PosY As Double, PosZ As Double, VolX As Double, VolY As Double, VolZ As Double, ShadeA As _Unsigned Long, ShadeB As _Unsigned Long, ShadeC As _Unsigned Long, TheDynamic As Integer, Framing As Integer)
    Dim k As Integer
    Dim g As Long
    Dim q As Long
    Dim vindex As Long
    q = LagAddressIn
    vindex = Group(q).LastVector
    g = NewGroup&(q, PosX, PosY, PosZ, 64, TheDynamic, Framing)
    Group(g).Label = TheName
    Group(g).Volume.x = VolX
    Group(g).Volume.y = VolY
    Group(g).Volume.z = VolZ
    Group(g).FirstVector = vindex + 1
    Group(g).PlotMode = 1
    For k = 1 To Weight
        vindex = vindex + 1
        vec3Dpos(vindex).x = (Rnd - .5) * VolX
        vec3Dpos(vindex).y = (Rnd - .5) * VolY
        vec3Dpos(vindex).z = (Rnd - .5) * VolZ
        If (Rnd > .5) Then
            vec3Dcolor(vindex) = ShadeA
        Else
            If (Rnd > .5) Then
                vec3Dcolor(vindex) = ShadeB
            Else
                vec3Dcolor(vindex) = ShadeC
            End If
        End If
    Next
    Group(g).LastVector = vindex
    NewCube& = g
End Function

Function NewWireCube& (LagAddressIn As Long, TheName As String, PosX As Double, PosY As Double, PosZ As Double, VolX As Double, VolY As Double, VolZ As Double, ShadeA As _Unsigned Long, TheDynamic As Integer)
    Dim g As Long
    Dim q As Long
    Dim vindex As Long
    q = LagAddressIn
    vindex = Group(q).LastVector
    g = NewGroup&(q, PosX, PosY, PosZ, 64, TheDynamic, 0)
    Group(g).Label = TheName
    Group(g).Volume.x = VolX
    Group(g).Volume.y = VolY
    Group(g).Volume.z = VolZ
    Group(g).FirstVector = vindex + 1
    Group(g).PlotMode = -1

    vindex = vindex + 1
    vec3Dpos(vindex).x = (0 - .5) * VolX
    vec3Dpos(vindex).y = (0 - .5) * VolY
    vec3Dpos(vindex).z = (0 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA
    vindex = vindex + 1
    vec3Dpos(vindex).x = (1 - .5) * VolX
    vec3Dpos(vindex).y = (0 - .5) * VolY
    vec3Dpos(vindex).z = (0 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA
    vindex = vindex + 1
    vec3Dpos(vindex).x = (0 - .5) * VolX
    vec3Dpos(vindex).y = (1 - .5) * VolY
    vec3Dpos(vindex).z = (0 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA
    vindex = vindex + 1
    vec3Dpos(vindex).x = (1 - .5) * VolX
    vec3Dpos(vindex).y = (1 - .5) * VolY
    vec3Dpos(vindex).z = (0 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA

    vindex = vindex + 1
    vec3Dpos(vindex).x = (0 - .5) * VolX
    vec3Dpos(vindex).y = (0 - .5) * VolY
    vec3Dpos(vindex).z = (1 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA
    vindex = vindex + 1
    vec3Dpos(vindex).x = (1 - .5) * VolX
    vec3Dpos(vindex).y = (0 - .5) * VolY
    vec3Dpos(vindex).z = (1 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA
    vindex = vindex + 1
    vec3Dpos(vindex).x = (0 - .5) * VolX
    vec3Dpos(vindex).y = (1 - .5) * VolY
    vec3Dpos(vindex).z = (1 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA
    vindex = vindex + 1
    vec3Dpos(vindex).x = (1 - .5) * VolX
    vec3Dpos(vindex).y = (1 - .5) * VolY
    vec3Dpos(vindex).z = (1 - .5) * VolZ
    vec3Dcolor(vindex) = ShadeA

    Group(g).LastVector = vindex
    NewWireCube& = g
End Function

' Linked list utility.

Function LatestGroupIdentity& (StartingID As Long)
    Dim TheReturn As Long
    Dim As Long p, q
    p = StartingID
    If (p = 0) Then
        q = 0
    Else
        Do
            q = p
            p = Group(q).Pointer
            If (p = -999) Then Exit Do
        Loop
    End If
    TheReturn = q
    LatestGroupIdentity& = TheReturn
End Function

Function LatestClusterIdentity& (StartingID As Long)
    Dim TheReturn As Long
    Dim As Long p, q
    p = StartingID
    If (p = 0) Then
        q = 0
    Else
        Do
            q = p
            p = Cluster(q).Pointer
            If (p = -999) Then Exit Do
        Loop
    End If
    TheReturn = q
    LatestClusterIdentity& = TheReturn
End Function

Function NewGroup& (LagAddressIn As Long, CenterX As Double, CenterY As Double, CenterZ As Double, ClusterSize As Integer, TheDynamic As Integer, Framing As Integer)
    Dim As Long g0
    g0 = LatestGroupIdentity&(LagAddressIn)
    GroupIdTicker = GroupIdTicker + 1
    Group(GroupIdTicker).Identity = GroupIdTicker
    Group(GroupIdTicker).Pointer = -999
    Group(GroupIdTicker).Lagger = g0
    Group(GroupIdTicker).Centroid.x = CenterX
    Group(GroupIdTicker).Centroid.y = CenterY
    Group(GroupIdTicker).Centroid.z = CenterZ
    Group(GroupIdTicker).FrameLength = 0
    Group(GroupIdTicker).ActiveFrame = 0
    If (Group(GroupIdTicker).Lagger <> 0) Then
        Group(g0).Pointer = GroupIdTicker
    End If

    ' Adjust corresponding cluster.
    ClusterFillCounter = ClusterFillCounter + 1
    If (ClusterFillCounter = 1) Then
        Call NewCluster(1, Group(GroupIdTicker).Identity, TheDynamic, Framing) '''
    End If
    If (ClusterFillCounter = ClusterSize) Then
        Call ClusterPinch(Group(GroupIdTicker).Identity)
    End If

    NewGroup& = Group(GroupIdTicker).Identity
End Function


Sub NewCluster (ClusterLagIn As Long, FirstGroupIn As Long, TheDynamic As Integer, Framing As Integer)
    Dim As Long k0
    If (ClusterIdTicker = 0) Then
        k0 = -1
    Else
        k0 = LatestClusterIdentity&(ClusterLagIn)
    End If
    ClusterIdTicker = ClusterIdTicker + 1
    Cluster(ClusterIdTicker).Identity = ClusterIdTicker
    Cluster(ClusterIdTicker).Pointer = -999
    Cluster(ClusterIdTicker).Lagger = k0
    Cluster(ClusterIdTicker).FirstGroup = FirstGroupIn
    Cluster(ClusterIdTicker).MotionType = TheDynamic
    Cluster(ClusterIdTicker).Framed = Framing
    If (ClusterIdTicker > 1) Then Cluster(k0).Pointer = ClusterIdTicker
End Sub



Sub RemoveGroup (TheAddressIn As Long)
    Dim As Long g, p, l, k, ci
    Dim As Integer f
    g = TheAddressIn

    f = 0
    k = 1
    Do
        If (Cluster(k).FirstGroup = g) And (Cluster(k).LastGroup <> g) Then
            f = 1
            ci = k
            Exit Do
        End If
        If (Cluster(k).FirstGroup <> g) And (Cluster(k).LastGroup = g) Then
            f = 2
            ci = k
            Exit Do
        End If
        If ((Cluster(k).LastGroup = g) And (Cluster(k).LastGroup = g)) Then
            f = 3
            ci = k
            Exit Do
        End If
        k = Cluster(k).Pointer
        If (k = -999) Then Exit Do
    Loop

    Select Case f
        Case 0
            p = Group(g).Pointer
            l = Group(g).Lagger
            Group(l).Pointer = p
            If (p <> -999) Then
                Group(p).Lagger = l
            End If

        Case 1
            p = Group(g).Pointer
            l = Group(g).Lagger
            Group(l).Pointer = p
            If (p <> -999) Then
                Group(p).Lagger = l
            End If

            Cluster(ci).FirstGroup = p
            Call ClusterCentroidCalc(ci)
        Case 2
            p = Group(g).Pointer
            l = Group(g).Lagger
            Group(l).Pointer = p
            If (p <> -999) Then
                Group(p).Lagger = l
            End If

            Cluster(ci).LastGroup = l
            Call ClusterCentroidCalc(ci)
        Case 3
            p = Group(g).Pointer
            l = Group(g).Lagger
            Group(l).Pointer = p
            If (p <> -999) Then
                Group(p).Lagger = l
            End If

            Call RemoveCluster(ci)
    End Select
End Sub

Sub RemoveCluster (TheAddressIn As Long)
    Dim As Long k, p, l
    k = TheAddressIn
    p = Cluster(k).Pointer
    l = Cluster(k).Lagger
    If (l <> -1) Then
        Cluster(l).Pointer = p
    End If
    If (p <> -999) Then
        Cluster(p).Lagger = l
    End If
End Sub

Sub ClusterPinch (TheLastGroup As Long)
    ClusterFillCounter = 0
    Cluster(ClusterIdTicker).LastGroup = TheLastGroup
    Call ClusterCentroidCalc(ClusterIdTicker)
End Sub

Sub ClusterCentroidCalc (TheCluster As Long)
    Dim As Long g
    Dim As Integer n
    Cluster(TheCluster).Centroid.x = 0
    Cluster(TheCluster).Centroid.y = 0
    Cluster(TheCluster).Centroid.z = 0
    g = Cluster(TheCluster).FirstGroup
    n = 0
    Do
        Cluster(TheCluster).Centroid.x = Cluster(TheCluster).Centroid.x + Group(g).Centroid.x
        Cluster(TheCluster).Centroid.y = Cluster(TheCluster).Centroid.y + Group(g).Centroid.y
        Cluster(TheCluster).Centroid.z = Cluster(TheCluster).Centroid.z + Group(g).Centroid.z
        n = n + 1
        If (g = Cluster(TheCluster).LastGroup) Then Exit Do
        g = Group(g).Pointer
    Loop
    Cluster(TheCluster).Centroid.x = Cluster(TheCluster).Centroid.x / n
    Cluster(TheCluster).Centroid.y = Cluster(TheCluster).Centroid.y / n
    Cluster(TheCluster).Centroid.z = Cluster(TheCluster).Centroid.z / n
End Sub

' Player Dynamics

Sub PlayerDynamics
    If (ToggleAnimate = 1) Then

        ' Player kinematics
        PlayerCamera.Velocity.x = PlayerCamera.Velocity.x + PlayerCamera.Acceleration.x
        PlayerCamera.Velocity.y = PlayerCamera.Velocity.y + PlayerCamera.Acceleration.y
        PlayerCamera.Velocity.z = PlayerCamera.Velocity.z + PlayerCamera.Acceleration.z
        PlayerCamera.Velocity.x = .95 * PlayerCamera.Velocity.x
        PlayerCamera.Velocity.y = .95 * PlayerCamera.Velocity.y
        PlayerCamera.Velocity.z = .95 * PlayerCamera.Velocity.z
        PlayerCamera.Position.x = PlayerCamera.Position.x + PlayerCamera.Velocity.x
        PlayerCamera.Position.y = PlayerCamera.Position.y + PlayerCamera.Velocity.y
        PlayerCamera.Position.z = PlayerCamera.Position.z + PlayerCamera.Velocity.z

        ' Terrain traversal.
        Dim As Double qi, qj
        Dim As Integer wi, wj
        qi = (PlayerCamera.Position.x) / BlockSize + UBound(WorldMesh, 1) / 2
        qj = (PlayerCamera.Position.y) / BlockSize + UBound(WorldMesh, 2) / 2
        wi = 1 + Int(qi)
        wj = 1 + Int(qj)
        If (wi < 1) Then wi = 1
        If (wj < 1) Then wj = 1
        If (wi > UBound(WorldMesh, 1)) Then wi = UBound(WorldMesh, 1)
        If (wj > UBound(WorldMesh, 2)) Then wj = UBound(WorldMesh, 2)
        If (PlayerCamera.Velocity.z = 0) Then
            PlayerCamera.Position.z = PlayerCamera.Position.z + .15 * ((40 + WorldMesh(wi, wj) - PlayerCamera.Position.z))
        End If

        ' Collision with ground after jump.
        If ((PlayerCamera.Velocity.z <> 0) And (PlayerCamera.Position.z < (40 + WorldMesh(wi, wj)))) Then
            PlayerCamera.Acceleration.z = 0
            PlayerCamera.Velocity.z = 0
        End If

        ' Collision with tornado.
        If (Group(ClosestGroup).Label = "Tornado") Then
            PlayerCamera.Velocity.x = (Rnd - .5) * 20
            PlayerCamera.Velocity.y = (Rnd - .5) * 20
            PlayerCamera.Velocity.z = 20
            PlayerCamera.Acceleration.z = -.5
        End If

        'Un-zoom camera.
        If ((fovd <> -192) And (_KeyDown(90) = 0) And (_KeyDown(122) = 0)) Then
            fovd = Int(.5 * (fovd - 192)) + 1
            farplane(4) = -256 'Int(.5 * (farplane(4) - 256))
            Call CalculateClippingPlanes(_Width, _Height)
        End If

    End If
End Sub

' Compute Visible Scene

Sub ComputeVisibleScene
    Dim As Long g, k
    Dim As Double dx, dy, dz
    Dim closestdist2 As Double
    Dim fp42 As Double
    Dim dist2 As Double
    Dim GroupInView As Integer
    ClosestGroup = 1
    closestdist2 = 10000000
    fp42 = farplane(4) * farplane(4)

    k = 1
    Do
        dx = Cluster(k).Centroid.x - PlayerCamera.Position.x
        dy = Cluster(k).Centroid.y - PlayerCamera.Position.y
        dz = Cluster(k).Centroid.z - PlayerCamera.Position.z
        dist2 = dx * dx + dy * dy + dz * dz
        '''
        If k = SunClusterAddress And Cluster(k).Centroid.z > 0 Then GoTo 100
        If k = MoonClusterAddress And Cluster(k).Centroid.z > 0 Then GoTo 100
        '''
        If (dist2 > 600 * 600) Then
            Cluster(k).Visible = 0
            If ((Cluster(k).MotionType <> 0) And (ToggleAnimate = 1)) Then
                Call EvolveCluster(k)
            End If
        Else
            '''
            100
            '''
            Cluster(k).Visible = 1
            g = Cluster(k).FirstGroup
            If ((Cluster(k).MotionType <> 0) And (ToggleAnimate = 1)) Then
                Call EvolveCluster(k)
            End If
            Do
                dx = Group(g).Centroid.x - PlayerCamera.Position.x
                dy = Group(g).Centroid.y - PlayerCamera.Position.y
                dz = Group(g).Centroid.z - PlayerCamera.Position.z
                dist2 = dx * dx + dy * dy + dz * dz
                Group(g).Visible = 0
                '''
                If k = SunClusterAddress Then GoTo 200
                If k = MoonClusterAddress Then GoTo 200
                '''

                If (dist2 < fp42) Then
                    '''
                    200
                    '''
                    GroupInView = 1
                    If dx * nearplane(1) + dy * nearplane(2) + dz * nearplane(3) - nearplane(4) < 0 Then GroupInView = 0
                    'IF dx * farplane(1) + dy * farplane(2) + dz * farplane(3) - farplane(4) < 0 THEN groupinview = 0 ''' Redundant
                    If dx * rightplane(1) + dy * rightplane(2) + dz * rightplane(3) - rightplane(4) < 0 Then GroupInView = 0
                    If dx * leftplane(1) + dy * leftplane(2) + dz * leftplane(3) - leftplane(4) < 0 Then GroupInView = 0
                    If dx * topplane(1) + dy * topplane(2) + dz * topplane(3) - topplane(4) < 0 Then GroupInView = 0
                    If dx * bottomplane(1) + dy * bottomplane(2) + dz * bottomplane(3) - bottomplane(4) < 0 Then GroupInView = 0
                    If (GroupInView = 1) Then
                        Group(g).Visible = 1
                        If (dist2 < closestdist2) Then
                            closestdist2 = dist2
                            ClosestGroup = g
                        End If
                        Group(g).Distance2 = dist2
                        If (ToggleAnimate = 1) And (Group(g).FrameLength = 0) Then Call EvolveVectors(g)

                        '''
                        If k = SunClusterAddress Or k = MoonClusterAddress Then
                            If PlayerCamera.Position.z < -40 Then
                                Call ProjectGroup(g, Group(g).FirstVector, Group(g).LastVector, 1)
                            Else
                                Call ProjectGroup(g, Group(g).FirstVector, Group(g).LastVector, 0)
                            End If
                        Else
                            If Group(g).FrameLength <> 0 And Group(g).ActiveFrame <> 0 Then
                                Call ProjectGroup(g, Group(g).FirstVector + Group(g).ActiveFrame * Group(g).FrameLength, Group(g).FirstVector + Group(g).ActiveFrame * Group(g).FrameLength + Group(g).FrameLength, 1)
                            Else
                                Call ProjectGroup(g, Group(g).FirstVector, Group(g).LastVector, 1)
                            End If
                        End If
                        '''

                    End If
                End If
                If (g = Cluster(k).LastGroup) Then Exit Do
                g = Group(g).Pointer
            Loop
        End If

        k = Cluster(k).Pointer
        If (k = -999) Then Exit Do
    Loop
End Sub

Sub CalculateScreenVectors
    Dim As Double mag
    mag = 1 / Sqr(uhat(1) * uhat(1) + uhat(2) * uhat(2) + uhat(3) * uhat(3))
    uhat(1) = uhat(1) * mag: uhat(2) = uhat(2) * mag: uhat(3) = uhat(3) * mag
    mag = 1 / Sqr(vhat(1) * vhat(1) + vhat(2) * vhat(2) + vhat(3) * vhat(3))
    vhat(1) = vhat(1) * mag: vhat(2) = vhat(2) * mag: vhat(3) = vhat(3) * mag
    nhat(1) = uhat(2) * vhat(3) - uhat(3) * vhat(2)
    nhat(2) = uhat(3) * vhat(1) - uhat(1) * vhat(3)
    nhat(3) = uhat(1) * vhat(2) - uhat(2) * vhat(1)
    Call CalculateClippingPlanes(_Width, _Height)
End Sub

Sub CalculateClippingPlanes (TheWidth As Double, TheHeight As Double)
    Dim As Double h2, w2, h2f, w2f, h2w2, mag
    h2 = TheHeight * .5
    w2 = TheWidth * .5
    h2f = h2 * fovd
    w2f = w2 * fovd
    h2w2 = h2 * w2
    nearplane(1) = -nhat(1)
    nearplane(2) = -nhat(2)
    nearplane(3) = -nhat(3)
    farplane(1) = nhat(1)
    farplane(2) = nhat(2)
    farplane(3) = nhat(3)
    rightplane(1) = h2f * uhat(1) - h2w2 * nhat(1)
    rightplane(2) = h2f * uhat(2) - h2w2 * nhat(2)
    rightplane(3) = h2f * uhat(3) - h2w2 * nhat(3)
    mag = 1 / Sqr(rightplane(1) * rightplane(1) + rightplane(2) * rightplane(2) + rightplane(3) * rightplane(3))
    rightplane(1) = rightplane(1) * mag
    rightplane(2) = rightplane(2) * mag
    rightplane(3) = rightplane(3) * mag
    leftplane(1) = -h2f * uhat(1) - h2w2 * nhat(1)
    leftplane(2) = -h2f * uhat(2) - h2w2 * nhat(2)
    leftplane(3) = -h2f * uhat(3) - h2w2 * nhat(3)
    mag = 1 / Sqr(leftplane(1) * leftplane(1) + leftplane(2) * leftplane(2) + leftplane(3) * leftplane(3))
    leftplane(1) = leftplane(1) * mag
    leftplane(2) = leftplane(2) * mag
    leftplane(3) = leftplane(3) * mag
    topplane(1) = w2f * vhat(1) - h2w2 * nhat(1)
    topplane(2) = w2f * vhat(2) - h2w2 * nhat(2)
    topplane(3) = w2f * vhat(3) - h2w2 * nhat(3)
    mag = 1 / Sqr(topplane(1) * topplane(1) + topplane(2) * topplane(2) + topplane(3) * topplane(3))
    topplane(1) = topplane(1) * mag
    topplane(2) = topplane(2) * mag
    topplane(3) = topplane(3) * mag
    bottomplane(1) = -w2f * vhat(1) - h2w2 * nhat(1)
    bottomplane(2) = -w2f * vhat(2) - h2w2 * nhat(2)
    bottomplane(3) = -w2f * vhat(3) - h2w2 * nhat(3)
    mag = 1 / Sqr(bottomplane(1) * bottomplane(1) + bottomplane(2) * bottomplane(2) + bottomplane(3) * bottomplane(3))
    bottomplane(1) = bottomplane(1) * mag
    bottomplane(2) = bottomplane(2) * mag
    bottomplane(3) = bottomplane(3) * mag
End Sub

Sub ProjectGroup (TheGroup As Long, LowIndex As Long, HighIndex As Long, GraySwitch As Integer)
    Dim As Vector3 vec(UBound(vec3Dpos))
    Dim As Integer vectorinview
    Dim As Double vec3ddotnhat
    Dim i As Long
    Dim f As Integer
    For i = LowIndex To HighIndex
        vec(i).x = Group(TheGroup).Centroid.x + vec3Dpos(i).x - PlayerCamera.Position.x
        vec(i).y = Group(TheGroup).Centroid.y + vec3Dpos(i).y - PlayerCamera.Position.y
        vec(i).z = Group(TheGroup).Centroid.z + vec3Dpos(i).z - PlayerCamera.Position.z
        f = -1
        vec3Dvis(i) = 0
        vectorinview = 1
        If vec(i).x * nearplane(1) + vec(i).y * nearplane(2) + vec(i).z * nearplane(3) - nearplane(4) < 0 Then vectorinview = 0
        'IF vec(i).x * farplane(1) + vec(i).y * farplane(2) + vec(i).z* farplane(3) - farplane(4) < 0 THEN vectorinview = 0
        If vec(i).x * farplane(1) + vec(i).y * farplane(2) + vec(i).z * farplane(3) - farplane(4) * .85 < 0 Then f = 1
        'IF vec(i).x * rightplane(1) + vec(i).y * rightplane(2) + vec(i).z * rightplane(3) - rightplane(4) < 0 THEN vectorinview = 0
        'IF vec(i).x * leftplane(1) + vec(i).y * leftplane(2) + vec(i).z * leftplane(3) - leftplane(4) < 0 THEN vectorinview = 0
        'IF vec(i).x * topplane(1) + vec(i).y * topplane(2) + vec(i).z * topplane(3) - topplane(4) < 0 THEN vectorinview = 0
        'IF vec(i).x * bottomplane(1) + vec(i).y * bottomplane(2) + vec(i).z* bottomplane(3) - bottomplane(4) < 0 THEN vectorinview = 0
        If (vectorinview = 1) Then
            vec3Dvis(i) = 1
            vec3ddotnhat = vec(i).x * nhat(1) + vec(i).y * nhat(2) + vec(i).z * nhat(3)
            vec2D(i).u = (vec(i).x * uhat(1) + vec(i).y * uhat(2) + vec(i).z * uhat(3)) * fovd / vec3ddotnhat
            vec2D(i).v = (vec(i).x * vhat(1) + vec(i).y * vhat(2) + vec(i).z * vhat(3)) * fovd / vec3ddotnhat
            If ((GraySwitch = 1) And (f = 1)) Then
                vec2Dcolor(i) = Gray
            Else
                vec2Dcolor(i) = vec3Dcolor(i)
            End If
        End If
    Next
End Sub

Sub EvolveCluster (TheCluster As Long)
    Dim u As Long
    Dim k As Long
    Dim As Single xx, yy, zz ' Needs to be single otherwise the fish flip flop. wtf?
    Dim As Double x0, y0 ', z0
    Dim As Double dx, dy, dz
    Dim As Double t
    Dim As Double v
    'Dim xx, yy, zz, x0, y0, dx, dy, dz, t, v As Double
    Select Case Cluster(TheCluster).MotionType
        Case 0
            ' Do nothing.

        Case -1
            ' Freefall and explode.
            Cluster(TheCluster).Velocity.x = Cluster(TheCluster).Velocity.x + Cluster(TheCluster).Acceleration.x
            Cluster(TheCluster).Velocity.y = Cluster(TheCluster).Velocity.y + Cluster(TheCluster).Acceleration.y
            Cluster(TheCluster).Velocity.z = Cluster(TheCluster).Velocity.z + Cluster(TheCluster).Acceleration.z
            dx = Cluster(TheCluster).Velocity.x
            dy = Cluster(TheCluster).Velocity.y
            dz = Cluster(TheCluster).Velocity.z
            If ((dx <> 0) Or (dy <> 0) Or (dz <> 0)) Then
                Call TranslateCluster(TheCluster, dx, dy, dz)
            End If
            Dim wi As Integer
            Dim wj As Integer
            wi = 1 + Int((Cluster(TheCluster).Centroid.x) / BlockSize + UBound(WorldMesh, 1) / 2)
            wj = 1 + Int((Cluster(TheCluster).Centroid.y) / BlockSize + UBound(WorldMesh, 2) / 2)
            If (Cluster(TheCluster).Centroid.z <= WorldMesh(wi, wj)) Then
                Cluster(TheCluster).Acceleration.x = 0
                Cluster(TheCluster).Acceleration.y = 0
                Cluster(TheCluster).Acceleration.z = 0
                Cluster(TheCluster).Velocity.x = 0
                Cluster(TheCluster).Velocity.y = 0
                Cluster(TheCluster).Velocity.z = 0
                Cluster(TheCluster).MotionType = -9
                Cluster(TheCluster).DeathTimer = Timer + 2
                k = Cluster(TheCluster).FirstGroup
                Do
                    Group(k).Volume.x = BlockSize * 3
                    Group(k).Volume.y = BlockSize * 3
                    Group(k).Volume.z = BlockSize * 3
                    For u = Group(k).FirstVector To Group(k).LastVector
                        vec3Dvel(u).x = (Rnd - .5) * .8
                        vec3Dvel(u).y = (Rnd - .5) * .8
                        vec3Dvel(u).z = (Rnd - 0) * .8
                    Next
                    If (k = Cluster(TheCluster).LastGroup) Then Exit Do
                    k = Group(k).Pointer
                Loop
            End If

        Case -2
            ' Freefall and stack.
            Cluster(TheCluster).Velocity.x = Cluster(TheCluster).Velocity.x + Cluster(TheCluster).Acceleration.x
            Cluster(TheCluster).Velocity.y = Cluster(TheCluster).Velocity.y + Cluster(TheCluster).Acceleration.y
            Cluster(TheCluster).Velocity.z = Cluster(TheCluster).Velocity.z + Cluster(TheCluster).Acceleration.z
            dx = Cluster(TheCluster).Velocity.x
            dy = Cluster(TheCluster).Velocity.y
            dz = Cluster(TheCluster).Velocity.z
            If ((dx <> 0) Or (dy <> 0) Or (dz <> 0)) Then
                Call TranslateCluster(TheCluster, dx, dy, dz)
            End If
            wi = 1 + Int((Cluster(TheCluster).Centroid.x) / BlockSize + UBound(WorldMesh, 1) / 2)
            wj = 1 + Int((Cluster(TheCluster).Centroid.y) / BlockSize + UBound(WorldMesh, 2) / 2)
            If (Cluster(TheCluster).Centroid.z <= WorldMesh(wi, wj)) Then
                Cluster(TheCluster).Acceleration.x = 0
                Cluster(TheCluster).Acceleration.y = 0
                Cluster(TheCluster).Acceleration.z = 0
                Cluster(TheCluster).Velocity.x = 0
                Cluster(TheCluster).Velocity.y = 0
                Cluster(TheCluster).Velocity.z = 0
                Cluster(TheCluster).MotionType = 0
                WorldMesh(wi, wj) = WorldMesh(wi, wj) + BlockSize / 3
            End If

        Case -9
            If (Timer >= Cluster(TheCluster).DeathTimer) Then
                Call RemoveCluster(TheCluster)
            End If

        Case Else
            ' Fixed path.
            ' Note: This chunk of code is subject to the midnight bug.
            t = Timer
            u = Int(t)
            v = t - u
            xx = v * FixedPath(Cluster(TheCluster).MotionType, u).x + (1 - v) * FixedPath(Cluster(TheCluster).MotionType, u - 1).x
            yy = v * FixedPath(Cluster(TheCluster).MotionType, u).y + (1 - v) * FixedPath(Cluster(TheCluster).MotionType, u - 1).y
            zz = v * FixedPath(Cluster(TheCluster).MotionType, u).z + (1 - v) * FixedPath(Cluster(TheCluster).MotionType, u - 1).z

            ' Choose frame based on derived velocity vector.
            If (Cluster(TheCluster).Framed = 1) Then
                k = Cluster(TheCluster).FirstGroup
                Do
                    If (Group(k).FrameLength <> 0) Then
                        x0 = Group(k).Centroid.x
                        y0 = Group(k).Centroid.y
                        'z0 = Group(k).Centroid.z
                        dx = xx - x0
                        dy = yy - y0
                        'dz = zz - z0
                        If ((dx > 0) And (dy > 0)) Then Group(k).ActiveFrame = 1 + Int(((48 / (2 * pi)) * (Atn(dy / dx))))
                        If ((dx < 0) And (dy > 0)) Then Group(k).ActiveFrame = 1 + 24 + Int(((48 / (2 * pi)) * (Atn(dy / dx))))
                        If ((dx < 0) And (dy < 0)) Then Group(k).ActiveFrame = 1 + 24 + Int(((48 / (2 * pi)) * (Atn(dy / dx))))
                        If ((dx > 0) And (dy < 0)) Then Group(k).ActiveFrame = 1 + 48 + Int(((48 / (2 * pi)) * (Atn(dy / dx))))
                    End If
                    If (k = Cluster(TheCluster).LastGroup) Then Exit Do
                    k = Group(k).Pointer
                Loop
            End If

            Call PlaceCluster(TheCluster, xx, yy, zz)

    End Select
End Sub

Sub PlaceCluster (TheCluster As Long, xc As Double, yc As Double, zc As Double)
    Dim As Long g
    Dim As Double x0, y0, z0
    x0 = Cluster(TheCluster).Centroid.x
    y0 = Cluster(TheCluster).Centroid.y
    z0 = Cluster(TheCluster).Centroid.z
    Cluster(TheCluster).Centroid.x = xc
    Cluster(TheCluster).Centroid.y = yc
    Cluster(TheCluster).Centroid.z = zc
    g = Cluster(TheCluster).FirstGroup
    Do
        Group(g).Centroid.x = Group(g).Centroid.x + xc - x0
        Group(g).Centroid.y = Group(g).Centroid.y + yc - y0
        Group(g).Centroid.z = Group(g).Centroid.z + zc - z0
        If (g = Cluster(TheCluster).LastGroup) Then Exit Do
        g = Group(g).Pointer
    Loop
End Sub

Sub TranslateCluster (TheCluster As Long, dx As Double, dy As Double, dz As Double)
    Dim As Long g
    g = Cluster(TheCluster).FirstGroup
    Do
        Group(g).Centroid.x = Group(g).Centroid.x + dx
        Group(g).Centroid.y = Group(g).Centroid.y + dy
        Group(g).Centroid.z = Group(g).Centroid.z + dz
        If (g = Cluster(TheCluster).LastGroup) Then Exit Do
        g = Group(g).Pointer
    Loop
    Cluster(TheCluster).Centroid.x = Cluster(TheCluster).Centroid.x + dx
    Cluster(TheCluster).Centroid.y = Cluster(TheCluster).Centroid.y + dy
    Cluster(TheCluster).Centroid.z = Cluster(TheCluster).Centroid.z + dz
End Sub

Sub EvolveVectors (TheGroup As Long)
    Dim As Long g
    Dim As Double xdim, ydim, zdim
    Dim As Double dx, dy, dz
    Dim As Double px, py, pz

    xdim = Group(TheGroup).Volume.x
    ydim = Group(TheGroup).Volume.y
    zdim = Group(TheGroup).Volume.z

    For g = Group(TheGroup).FirstVector To Group(TheGroup).LastVector

        ' Position update with periodic boundaries inside group volume.
        dx = vec3Dvel(g).x
        dy = vec3Dvel(g).y
        dz = vec3Dvel(g).z
        If (dx <> 0) Then
            px = vec3Dpos(g).x + dx
            If Abs(px) > xdim / 2 Then
                If (px > xdim / 2) Then
                    px = -xdim / 2
                Else
                    px = xdim / 2
                End If
            End If
            vec3Dpos(g).x = px
        End If
        If (dy <> 0) Then
            py = vec3Dpos(g).y + dy
            If Abs(py) > ydim / 2 Then
                If (py > ydim / 2) Then
                    py = -ydim / 2
                Else
                    py = ydim / 2
                End If
            End If
            vec3Dpos(g).y = py
        End If
        If (dz <> 0) Then
            pz = vec3Dpos(g).z + dz
            If Abs(pz) > zdim / 2 Then
                If (pz > zdim / 2) Then
                    pz = -zdim / 2
                Else
                    pz = zdim / 2
                End If
            End If
            vec3Dpos(g).z = pz
        End If
    Next
End Sub

Sub SetParticleVelocity (TheGroup As Long, vx As Double, vy As Double, vz As Double)
    Dim As Long j, m, n
    m = Group(TheGroup).FirstVector
    n = Group(TheGroup).LastVector
    For j = m To n
        vec3Dvel(j).x = vx
        vec3Dvel(j).y = vy
        vec3Dvel(j).z = vz
    Next
End Sub

' Sorting

Sub QuickSort (LowLimit As Long, HighLimit As Long)
    Dim As Long piv
    If (LowLimit < HighLimit) Then
        piv = Partition(LowLimit, HighLimit)
        Call QuickSort(LowLimit, piv - 1)
        Call QuickSort(piv + 1, HighLimit)
    End If
End Sub

Function Partition (LowLimit As Long, HighLimit As Long)
    Dim As Long i, j
    Dim As Double pivot, tmp
    pivot = Group(SortedGroups(HighLimit)).Distance2
    i = LowLimit - 1
    For j = LowLimit To HighLimit - 1
        tmp = Group(SortedGroups(j)).Distance2 - pivot
        If (tmp >= 0) Then
            i = i + 1
            Swap SortedGroups(i), SortedGroups(j)
        End If
    Next
    Swap SortedGroups(i + 1), SortedGroups(HighLimit)
    Partition = i + 1
End Function

'Sub BubbleSort
'    ' Antiquated but works fine.
'    Dim As Integer i, j
'    Dim As Double u, v
'    For j = SortedGroupsCount To 1 Step -1
'        For i = 2 To SortedGroupsCount
'            u = Group(SortedGroups(i - 1)).Distance2
'            v = Group(SortedGroups(i)).Distance2
'            If (u < v) Then
'                Swap SortedGroups(i - 1), SortedGroups(i)
'            End If
'        Next
'    Next
'End Sub

' Graphics

Sub PlotWorld
    Dim As Long g, k, p
    Dim j As Integer
    Dim lowlim, highlim As Long
    Dim x1 As Double
    Dim y1 As Double
    Dim x2 As Double
    Dim y2 As Double
    Dim clrtmp As _Unsigned Long
    Dim ThePlotMode As Integer

    NumClusterVisible = 0
    NumVectorVisible = 0

    SortedGroupsCount = 0
    k = 1
    Do
        If (Cluster(k).Visible = 1) Then
            NumClusterVisible = NumClusterVisible + 1
            g = Cluster(k).FirstGroup
            Do
                If (Group(g).Visible = 1) Then
                    SortedGroupsCount = SortedGroupsCount + 1
                    SortedGroups(SortedGroupsCount) = g
                End If
                If (g = Cluster(k).LastGroup) Then Exit Do
                g = Group(g).Pointer
            Loop
        End If
        k = Cluster(k).Pointer
        If (k = -999) Then Exit Do
    Loop
    NumGroupVisible = SortedGroupsCount

    Call QuickSort(1, SortedGroupsCount)
    'Call BubbleSort

    PlayerCamera.Shade = ShadeMix~&(PlayerCamera.Shade, _RGB32(_Red32(vec3Dcolor(Group(ClosestGroup).FirstVector)), _Green32(vec3Dcolor(Group(ClosestGroup).FirstVector)), _Blue32(vec3Dcolor(Group(ClosestGroup).FirstVector)), 200), .01)
    PlayerCamera.Shade = ShadeMix~&(PlayerCamera.Shade, _RGB32(0, 0, 0, 255), .01)
    Cls
    Line (0, 0)-(_Width, _Height), PlayerCamera.Shade, BF

    For j = 1 To SortedGroupsCount
        g = SortedGroups(j)
        ThePlotMode = Group(g).PlotMode

        If (ThePlotMode = -1) Then ' Wire cube
            Dim x3 As Double
            Dim y3 As Double
            Dim x4 As Double
            Dim y4 As Double
            p = Group(g).FirstVector
            clrtmp = vec2Dcolor(p)
            x1 = vec2D(p).u: y1 = vec2D(p).v: x2 = vec2D(p + 1).u: y2 = vec2D(p + 1).v: x3 = vec2D(p + 2).u: y3 = vec2D(p + 2).v: x4 = vec2D(p + 4).u: y4 = vec2D(p + 4).v
            Call CLine(x1, y1, x2, y2, clrtmp)
            Call CLine(x1, y1, x3, y3, clrtmp)
            Call CLine(x1, y1, x4, y4, clrtmp)
            x1 = vec2D(p + 3).u: y1 = vec2D(p + 3).v: x2 = vec2D(p + 1).u: y2 = vec2D(p + 1).v: x3 = vec2D(p + 2).u: y3 = vec2D(p + 2).v: x4 = vec2D(p + 7).u: y4 = vec2D(p + 7).v
            Call CLine(x1, y1, x2, y2, clrtmp)
            Call CLine(x1, y1, x3, y3, clrtmp)
            Call CLine(x1, y1, x4, y4, clrtmp)
            x1 = vec2D(p + 5).u: y1 = vec2D(p + 5).v: x2 = vec2D(p + 4).u: y2 = vec2D(p + 4).v: x3 = vec2D(p + 7).u: y3 = vec2D(p + 7).v: x4 = vec2D(p + 1).u: y4 = vec2D(p + 1).v
            Call CLine(x1, y1, x2, y2, clrtmp)
            Call CLine(x1, y1, x3, y3, clrtmp)
            Call CLine(x1, y1, x4, y4, clrtmp)
            x1 = vec2D(p + 6).u: y1 = vec2D(p + 6).v: x2 = vec2D(p + 4).u: y2 = vec2D(p + 4).v: x3 = vec2D(p + 7).u: y3 = vec2D(p + 7).v: x4 = vec2D(p + 2).u: y4 = vec2D(p + 2).v
            Call CLine(x1, y1, x2, y2, clrtmp)
            Call CLine(x1, y1, x3, y3, clrtmp)
            Call CLine(x1, y1, x4, y4, clrtmp)
        End If

        If Group(g).ActiveFrame = 0 Then
            lowlim = Group(g).FirstVector
            highlim = Group(g).LastVector - 1
        Else
            lowlim = Group(g).FirstVector + Group(g).FrameLength * (Group(g).ActiveFrame)
            highlim = Group(g).FirstVector + Group(g).FrameLength * (Group(g).ActiveFrame + 1) - 2
        End If

        For p = lowlim To highlim
            If (vec3Dvis(p) = 1) Then
                NumVectorVisible = NumVectorVisible + 1
                If (g = ClosestGroup) Then
                    clrtmp = Yellow
                Else
                    clrtmp = vec2Dcolor(p)
                End If
                Select Case ThePlotMode
                    Case 0
                        x1 = vec2D(p).u
                        y1 = vec2D(p).v
                        Call BlockPoint(x1, y1, clrtmp)
                    Case 1
                        x1 = vec2D(p).u
                        y1 = vec2D(p).v
                        x2 = vec2D(p + 1).u
                        y2 = vec2D(p + 1).v
                        If (((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) < 225) Then
                            Call CLine(x1, y1, x2, y2, clrtmp)
                            'CALL LineSmooth(x1, y1, x2, y2, clrtmp)
                        Else
                            Call CCircle(x1, y1, 1, clrtmp)
                            '''
                            'If p = highlim Then Call CCircle(x2, y2, 1, clrtmp)
                            '''
                        End If
                    Case 2
                        x1 = vec2D(p).u
                        y1 = vec2D(p).v
                        Call CCircle(x1, y1, 1, clrtmp)
                End Select
            End If
        Next
    Next

End Sub

Sub DisplayHUD
    Dim a As String
    Call LineSmooth(0, 0, 25 * (xhat(1) * uhat(1) + xhat(2) * uhat(2) + xhat(3) * uhat(3)), 25 * (xhat(1) * vhat(1) + xhat(2) * vhat(2) + xhat(3) * vhat(3)), _RGB32(255, 0, 0, 150))
    Call LineSmooth(0, 0, 25 * (yhat(1) * uhat(1) + yhat(2) * uhat(2) + yhat(3) * uhat(3)), 25 * (yhat(1) * vhat(1) + yhat(2) * vhat(2) + yhat(3) * vhat(3)), _RGB32(0, 255, 0, 150))
    Call LineSmooth(0, 0, 25 * (zhat(1) * uhat(1) + zhat(2) * uhat(2) + zhat(3) * uhat(3)), 25 * (zhat(1) * vhat(1) + zhat(2) * vhat(2) + zhat(3) * vhat(3)), _RGB32(30, 144, 255, 150))
    Call TextCenter(" Closest ", (1) * 16, LimeGreen)
    a = " " + Group(ClosestGroup).Label + " "
    Color DarkKhaki
    _PrintString (_Width / 2 - (Len(a) / 2) * 8, 2 * 16), a
    Color LimeGreen
    _PrintString ((1) * 8, _Height - (4) * 16), "   Movement   "
    Color DarkKhaki
    _PrintString ((1) * 8, _Height - (3) * 16), "  W  &/or  " + Chr$(30) + "  "
    _PrintString ((1) * 8, _Height - (2) * 16), "A S D    " + Chr$(17) + " " + Chr$(31) + " " + Chr$(16)
    Color LimeGreen
    _PrintString (_Width - (13) * 8, _Height - (4) * 16), "Orientation "
    Color DarkKhaki
    _PrintString (_Width - (13) * 8, _Height - (3) * 16), " Keypad 1-9 "
    If ((nhat(3) <> 0) Or (uhat(3) <> 0)) Then Color Red Else Color Gray
    _PrintString (_Width - (13) * 8, _Height - (2) * 16), "  5=Level   "
    Color LimeGreen
    _PrintString ((1) * 8, (1) * 16), "- Report -"
    Color DarkKhaki
    _PrintString ((1) * 8, (2) * 16), "FPS: " + LTrim$(RTrim$(Str$(FPSReport))) + "/" + LTrim$(RTrim$(Str$(FPSTarget)))
    _PrintString ((1) * 8, (3) * 16), "Particles: " + LTrim$(RTrim$(Str$(NumVectorVisible)))
    '_PrintString ((1) * 8, (5) * 16), "Clusters: " + LTrim$(RTrim$(Str$(NumClusterVisible)))
    '_PrintString ((1) * 8, (4) * 16), "Groups: " + LTrim$(RTrim$(Str$(NumGroupVisible)))
    Color LimeGreen
    _PrintString ((1) * 8, (10) * 16), "Abilities"
    Color DarkKhaki
    _PrintString ((1) * 8, (11) * 16), "F = throw"
    _PrintString ((1) * 8, (12) * 16), "B = build"
    _PrintString ((1) * 8, (13) * 16), "N = scramble"
    _PrintString ((1) * 8, (14) * 16), "K = delete"
    _PrintString ((1) * 8, (15) * 16), "Z = zoom"
    Color LimeGreen
    Call TextCenter(" SPACE = Ascend ", _Height - (2) * 16, LimeGreen)
End Sub

Sub TextCenter (TheText As String, TheHeight As Integer, TheShade As _Unsigned Long)
    Color TheShade
    _PrintString (_Width / 2 - (Len(TheText) / 2) * 8, TheHeight), TheText
End Sub

Sub DisplayMiniMap
    Dim As Integer i, j, wi, wj
    Dim As Double dx, dy, u, v
    Dim As String a
    Dim As _Unsigned Long Shade
    wi = 1 + Int((PlayerCamera.Position.x) / BlockSize + UBound(WorldMesh, 1) / 2)
    wj = 1 + Int((PlayerCamera.Position.y) / BlockSize + UBound(WorldMesh, 2) / 2)
    u = _Width / 2 - UBound(WorldMesh, 1)
    v = _Height / 2 - UBound(WorldMesh, 2)
    For i = 1 To UBound(WorldMesh, 1)
        For j = 1 To UBound(WorldMesh, 2)
            Shade = TerrainHeightShade~&(WorldMesh(i, j))
            Call CPset(i + u, j + v, _RGB32(_Red32(Shade), _Green32(Shade), _Blue32(Shade), 150))
        Next
    Next
    Call CCircle(wi + u, wj + v, 2, Red)
    Call LineSmooth(wi + u, wj + v, wi + u - 5 * nhat(1) * Sqr((fovd / -192)), wj + v - 5 * nhat(2) * Sqr((fovd / -192)), White)
    Color DarkKhaki, PlayerCamera.Shade
    _PrintString (_Width - UBound(WorldMesh, 1), UBound(WorldMesh, 2)), "x:" + LTrim$(RTrim$(Str$(Int(PlayerCamera.Position.x)))) + " " + "y:" + LTrim$(RTrim$(Str$(Int(PlayerCamera.Position.y)))) + " " + "z:" + LTrim$(RTrim$(Str$(Int(PlayerCamera.Position.z))))
    dx = -nhat(1)
    dy = -nhat(2)
    If ((dx > 0) And (dy > 0)) Then a = LTrim$(RTrim$(Str$(1 + Int(((180 / pi) * (Atn(dy / dx))))))) + Chr$(248)
    If ((dx < 0) And (dy > 0)) Then a = LTrim$(RTrim$(Str$(1 + 180 + Int(((180 / pi) * (Atn(dy / dx))))))) + Chr$(248)
    If ((dx < 0) And (dy < 0)) Then a = LTrim$(RTrim$(Str$(1 + 180 + Int(((180 / pi) * (Atn(dy / dx))))))) + Chr$(248)
    If ((dx > 0) And (dy < 0)) Then a = LTrim$(RTrim$(Str$(1 + 360 + Int(((180 / pi) * (Atn(dy / dx))))))) + Chr$(248)
    _PrintString (_Width - Len(a) * 8, UBound(WorldMesh, 2) - 16), a
End Sub

' Interface

Sub KeyDownProcess
    Dim As Double modifier
    modifier = 0.05

    If (_KeyDown(32) <> 0) Then ' Space
        PlayerCamera.Velocity.z = 5
        PlayerCamera.Acceleration.z = -.5
    End If
    If ((_KeyDown(87) <> 0) Or (_KeyDown(119) <> 0) Or (_KeyDown(18432) <> 0)) Then ' W or w or upparrow
        Call StrafeCameraNhat(-1, -1, 0)
        'If ((nhat(3) <> 0) Or (uhat(3) <> 0)) Then Call RegulateCamera
        If (ToggleAnimate = 1) Then
            PlayerCamera.Velocity.x = PlayerCamera.Velocity.x - modifier * nhat(1)
            PlayerCamera.Velocity.y = PlayerCamera.Velocity.y - modifier * nhat(2)
            'PlayerCamera.Velocity.z = PlayerCamera.Velocity.z - modifier * nhat(3)
        End If
    End If
    If ((_KeyDown(83) <> 0) Or (_KeyDown(115) <> 0) Or (_KeyDown(20480) <> 0)) Then ' S or s or downarrow
        Call StrafeCameraNhat(1, 1, 0)
        'If ((nhat(3) <> 0) Or (uhat(3) <> 0)) Then Call RegulateCamera
        If (ToggleAnimate = 1) Then
            PlayerCamera.Velocity.x = PlayerCamera.Velocity.x + modifier * nhat(1)
            PlayerCamera.Velocity.y = PlayerCamera.Velocity.y + modifier * nhat(2)
            'PlayerCamera.Velocity.z = PlayerCamera.Velocity.z + modifier * nhat(3)
        End If
    End If
    If ((_KeyDown(65) <> 0) Or (_KeyDown(97) <> 0)) Then ' A or a
        'If ((nhat(3) <> 0) Or (uhat(3) <> 0)) Then Call RegulateCamera
        Call StrafeCameraUhat(-1, -1, -1)
        If (ToggleAnimate = 1) Then
            PlayerCamera.Velocity.x = PlayerCamera.Velocity.x - modifier * uhat(1)
            PlayerCamera.Velocity.y = PlayerCamera.Velocity.y - modifier * uhat(2)
            'PlayerCamera.Velocity.z = PlayerCamera.Velocity.z - modifier * uhat(3)
        End If
    End If
    If ((_KeyDown(68) <> 0) Or (_KeyDown(100) <> 0)) Then ' D or d
        'If ((nhat(3) <> 0) Or (uhat(3) <> 0)) Then Call RegulateCamera
        Call StrafeCameraUhat(1, 1, 1)
        If (ToggleAnimate = 1) Then
            PlayerCamera.Velocity.x = PlayerCamera.Velocity.x + modifier * uhat(1)
            PlayerCamera.Velocity.y = PlayerCamera.Velocity.y + modifier * uhat(2)
            'PlayerCamera.Velocity.z = PlayerCamera.Velocity.z + modifier * uhat(3)
        End If
    End If
    If ((_KeyDown(81) <> 0) Or (_KeyDown(113) <> 0)) Then ' Q or q
        Call StrafeCameraVhat(1, 1, 1)
        If (ToggleAnimate = 1) Then
            PlayerCamera.Velocity.x = PlayerCamera.Velocity.x - modifier * vhat(1)
            PlayerCamera.Velocity.y = PlayerCamera.Velocity.y - modifier * vhat(2)
            PlayerCamera.Velocity.z = PlayerCamera.Velocity.z - modifier * vhat(3)
        End If
    End If
    If ((_KeyDown(69) <> 0) Or (_KeyDown(101) <> 0)) Then ' E or e
        Call StrafeCameraVhat(-1, -1, -1)
        If (ToggleAnimate = 1) Then
            PlayerCamera.Velocity.x = PlayerCamera.Velocity.x + modifier * vhat(1)
            PlayerCamera.Velocity.y = PlayerCamera.Velocity.y + modifier * vhat(2)
            PlayerCamera.Velocity.z = PlayerCamera.Velocity.z + modifier * vhat(3)
        End If
    End If
    If ((_KeyDown(90) <> 0) Or (_KeyDown(122) <> 0)) Then ' Z or z.
        fovd = fovd - 5
        If (fovd < -600) Then
            fovd = -600
        Else
            farplane(4) = farplane(4) - 5
        End If
        Call CalculateClippingPlanes(.5 * _Width, .5 * _Height)
    End If

    modifier = 0.0333
    If (_KeyDown(19200) <> 0) Or (_KeyDown(52) <> 0) Then Call RotateUhat(-modifier, -modifier, -modifier): Call CalculateScreenVectors ' 4
    If (_KeyDown(19712) <> 0) Or (_KeyDown(54) <> 0) Then Call RotateUhat(modifier, modifier, modifier): Call CalculateScreenVectors ' 6
    If (_KeyDown(56) <> 0) Then Call RotateVhat(modifier, modifier, modifier): Call CalculateScreenVectors ' 8
    If (_KeyDown(50) <> 0) Then Call RotateVhat(-modifier, -modifier, -modifier): Call CalculateScreenVectors ' 2
    If (_KeyDown(55) <> 0) Then Call RotateUV(-modifier, -modifier, -modifier) ' 7
    If (_KeyDown(57) <> 0) Then Call RotateUV(modifier, modifier, modifier) ' 9
    If (_KeyDown(49) <> 0) Then Call RotateUhat(-modifier, -modifier, -modifier): Call CalculateScreenVectors: Call RotateUV(-modifier, -modifier, -modifier) ' 1
    If (_KeyDown(51) <> 0) Then Call RotateUhat(modifier, modifier, modifier): Call CalculateScreenVectors: Call RotateUV(modifier, modifier, modifier) ' 3

    modifier = 0.0222
    Do While _MouseInput
        If (_MouseMovementX > 0) Then Call RotateUhat(modifier, modifier, modifier): Call CalculateScreenVectors
        If (_MouseMovementX < 0) Then Call RotateUhat(-modifier, -modifier, -modifier): Call CalculateScreenVectors
        If (_MouseMovementY > 0) Then Call RotateVhat(modifier, modifier, modifier): Call CalculateScreenVectors
        If (_MouseMovementY < 0) Then Call RotateVhat(-modifier, -modifier, -modifier): Call CalculateScreenVectors
    Loop
End Sub

Sub KeyHitProcess
    Dim As Long g, p
    Dim As Double x0, y0, z0
    Dim As Integer kh
    kh = _KeyHit
    If (kh <> 0) Then
        Select Case kh
            Case 27 ' Quit
                System

            Case 53 ' 5
                Call RegulateCamera

            Case Asc("b"), Asc("B")
                x0 = (PlayerCamera.Position.x - 40 * nhat(1))
                y0 = (PlayerCamera.Position.y - 40 * nhat(2))
                z0 = (PlayerCamera.Position.z - 40 * nhat(3))
                x0 = x0 - x0 Mod BlockSize / 3
                y0 = y0 - y0 Mod BlockSize / 3
                z0 = z0 - z0 Mod BlockSize / 3
                g = LatestGroupIdentity&(1)
                g = NewCube&(g, "Custom block", 100, x0, y0, z0, BlockSize / 3, BlockSize / 3, BlockSize / 3, Lime, Purple, Teal, -2, 0)
                g = NewWireCube&(g, "Custom block", x0, y0, z0, BlockSize / 3, BlockSize / 3, BlockSize / 3, Lime, -2)
                Cluster(ClusterIdTicker).Acceleration.x = 0
                Cluster(ClusterIdTicker).Acceleration.y = 0
                Cluster(ClusterIdTicker).Acceleration.z = -.15
                Call ClusterPinch(g)

            Case Asc("f"), Asc("F")
                x0 = (PlayerCamera.Position.x - 40 * nhat(1))
                y0 = (PlayerCamera.Position.y - 40 * nhat(2))
                z0 = (PlayerCamera.Position.z - 40 * nhat(3))
                g = LatestGroupIdentity&(1)
                g = NewCube&(g, "Potion", 150, x0, y0, z0, 10, 10, 10, Red, Purple, Teal, -1, 0)
                g = NewCube&(g, "Potion", 50, x0, y0, z0 + 10, 2, 2, 10, Blue, Purple, Teal, -1, 0)
                Cluster(ClusterIdTicker).Acceleration.x = 0
                Cluster(ClusterIdTicker).Acceleration.y = 0
                Cluster(ClusterIdTicker).Acceleration.z = -.15
                Cluster(ClusterIdTicker).Velocity.x = -5 * nhat(1)
                Cluster(ClusterIdTicker).Velocity.y = -5 * nhat(2)
                Cluster(ClusterIdTicker).Velocity.z = -5 * nhat(3)
                Call ClusterPinch(g)

            Case Asc("n"), Asc("N")
                For p = Group(ClosestGroup).FirstVector To Group(ClosestGroup).LastVector
                    vec3Dvel(p).x = (Rnd - .5) * .20
                    vec3Dvel(p).y = (Rnd - .5) * .20
                    vec3Dvel(p).z = (Rnd - .5) * .20
                Next

            Case Asc("k"), Asc("K")
                Call RemoveGroup(ClosestGroup)

            Case Asc("t"), Asc("T")
                ToggleAnimate = -ToggleAnimate
        End Select
    End If
    _KeyClear
End Sub

' Plotting and color tools.

Sub CLine (x0 As Double, y0 As Double, x1 As Double, y1 As Double, shade As _Unsigned Long)
    Line (_Width / 2 + x0, -y0 + _Height / 2)-(_Width / 2 + x1, -y1 + _Height / 2), shade
End Sub

Sub CPset (x0 As Double, y0 As Double, shade As _Unsigned Long)
    PSet (_Width / 2 + x0, -y0 + _Height / 2), shade
End Sub

Sub CCircle (x0 As Double, y0 As Double, rad As Double, shade As _Unsigned Long)
    Circle (_Width / 2 + x0, -y0 + _Height / 2), rad, shade
    'Color shade
    '_PrintString (_Width / 2 + x0, -y0 + _Height / 2), Chr$(219)
End Sub

Sub BlockPoint (x0 As Double, y0 As Double, shade As _Unsigned Long)
    Line (_Width / 2 + x0 - 3, -y0 + _Height / 2 - 3)-(_Width / 2 + x0 + 3, -y0 + _Height / 2 + 3), _RGB32(_Red32(shade), _Green32(shade), _Blue32(shade), 200), BF
    'Color shade
    '_PrintString (_Width / 2 + x0, -y0 + _Height / 2), Chr$(219)
End Sub

Function ShadeMix~& (shade0 As _Unsigned Long, shade1 As _Unsigned Long, weight As Double)
    ShadeMix~& = _RGB32((1 - weight) * _Red32(shade0) + weight * _Red32(shade1), (1 - weight) * _Green32(shade0) + weight * _Green32(shade1), (1 - weight) * _Blue32(shade0) + weight * _Blue32(shade1))
End Function

Sub LineSmooth (x0 As Single, y0 As Single, x1 As Single, y1 As Single, c As _Unsigned Long)
    ' source: https://en.wikipedia.org/w/index.php?title=Xiaolin_Wu%27s_line_algorithm&oldid=852445548
    ' translated: FellippeHeitor @ qb64.org
    ' bugfixed for alpha channel

    Dim plX As Integer, plY As Integer, plI

    Dim steep As _Byte
    steep = Abs(y1 - y0) > Abs(x1 - x0)

    If steep Then
        Swap x0, y0
        Swap x1, y1
    End If

    If x0 > x1 Then
        Swap x0, x1
        Swap y0, y1
    End If

    Dim dx, dy, gradient
    dx = x1 - x0
    dy = y1 - y0
    gradient = dy / dx

    If dx = 0 Then
        gradient = 1
    End If

    'handle first endpoint
    Dim xend, yend, xgap, xpxl1, ypxl1
    xend = _Round(x0)
    yend = y0 + gradient * (xend - x0)
    xgap = (1 - ((x0 + .5) - Int(x0 + .5)))
    xpxl1 = xend 'this will be used in the main loop
    ypxl1 = Int(yend)
    If steep Then
        plX = ypxl1
        plY = xpxl1
        plI = (1 - (yend - Int(yend))) * xgap
        GoSub plot

        plX = ypxl1 + 1
        plY = xpxl1
        plI = (yend - Int(yend)) * xgap
        GoSub plot
    Else
        plX = xpxl1
        plY = ypxl1
        plI = (1 - (yend - Int(yend))) * xgap
        GoSub plot

        plX = xpxl1
        plY = ypxl1 + 1
        plI = (yend - Int(yend)) * xgap
        GoSub plot
    End If

    Dim intery
    intery = yend + gradient 'first y-intersection for the main loop

    'handle second endpoint
    Dim xpxl2, ypxl2
    xend = _Round(x1)
    yend = y1 + gradient * (xend - x1)
    xgap = ((x1 + .5) - Int(x1 + .5))
    xpxl2 = xend 'this will be used in the main loop
    ypxl2 = Int(yend)
    If steep Then
        plX = ypxl2
        plY = xpxl2
        plI = (1 - (yend - Int(yend))) * xgap
        GoSub plot

        plX = ypxl2 + 1
        plY = xpxl2
        plI = (yend - Int(yend)) * xgap
        GoSub plot
    Else
        plX = xpxl2
        plY = ypxl2
        plI = (1 - (yend - Int(yend))) * xgap
        GoSub plot

        plX = xpxl2
        plY = ypxl2 + 1
        plI = (yend - Int(yend)) * xgap
        GoSub plot
    End If

    'main loop
    Dim x
    If steep Then
        For x = xpxl1 + 1 To xpxl2 - 1
            plX = Int(intery)
            plY = x
            plI = (1 - (intery - Int(intery)))
            GoSub plot

            plX = Int(intery) + 1
            plY = x
            plI = (intery - Int(intery))
            GoSub plot

            intery = intery + gradient
        Next
    Else
        For x = xpxl1 + 1 To xpxl2 - 1
            plX = x
            plY = Int(intery)
            plI = (1 - (intery - Int(intery)))
            GoSub plot

            plX = x
            plY = Int(intery) + 1
            plI = (intery - Int(intery))
            GoSub plot

            intery = intery + gradient
        Next
    End If

    Exit Sub

    plot:
    ' Change to regular PSET for standard coordinate orientation.
    Call CPset(plX, plY, _RGB32(_Red32(c), _Green32(c), _Blue32(c), plI * _Alpha32(c)))
    Return
End Sub

' Camera transformation

Sub RotateUhat (dx As Double, dy As Double, dz As Double)
    uhat(1) = uhat(1) + nhat(1) * dx
    uhat(2) = uhat(2) + nhat(2) * dy
    uhat(3) = uhat(3) + nhat(3) * dz
End Sub

Sub RotateVhat (dx As Double, dy As Double, dz As Double)
    vhat(1) = vhat(1) + nhat(1) * dx
    vhat(2) = vhat(2) + nhat(2) * dy
    vhat(3) = vhat(3) + nhat(3) * dz
End Sub

Sub RotateUV (dx As Double, dy As Double, dz As Double)
    Dim As Double v1, v2, v3
    v1 = vhat(1)
    v2 = vhat(2)
    v3 = vhat(3)
    vhat(1) = v1 + uhat(1) * dx
    vhat(2) = v2 + uhat(2) * dy
    vhat(3) = v3 + uhat(3) * dz
    uhat(1) = uhat(1) - v1 * dx
    uhat(2) = uhat(2) - v2 * dy
    uhat(3) = uhat(3) - v3 * dz
End Sub

Sub StrafeCameraUhat (dx As Double, dy As Double, dz As Double)
    PlayerCamera.Position.x = PlayerCamera.Position.x + uhat(1) * dx
    PlayerCamera.Position.y = PlayerCamera.Position.y + uhat(2) * dy
    PlayerCamera.Position.z = PlayerCamera.Position.z + uhat(3) * dz
End Sub

Sub StrafeCameraVhat (dx As Double, dy As Double, dz As Double)
    PlayerCamera.Position.x = PlayerCamera.Position.x + vhat(1) * dx
    PlayerCamera.Position.y = PlayerCamera.Position.y + vhat(2) * dy
    PlayerCamera.Position.z = PlayerCamera.Position.z + vhat(3) * dz
End Sub

Sub StrafeCameraNhat (dx As Double, dy As Double, dz As Double)
    PlayerCamera.Position.x = PlayerCamera.Position.x + nhat(1) * dx
    PlayerCamera.Position.y = PlayerCamera.Position.y + nhat(2) * dy
    PlayerCamera.Position.z = PlayerCamera.Position.z + nhat(3) * dz
End Sub

'''
